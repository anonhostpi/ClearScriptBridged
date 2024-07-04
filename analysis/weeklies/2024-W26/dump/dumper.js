const CDP = require('chrome-remote-interface');
const yargs = require('yargs');
const fs = require('fs');

const { spawn } = require('child_process');
const { hideBin } = require('yargs/helpers');

const argv = yargs(hideBin(process.argv))
    .usage('Usage: $0 <inspected_script> <output_json>')
    .demandCommand(1, 'You need to specify an output directory')
    .argv;

class NodeDumper {
    #args = [
        '--expose-internals',
        '-r',
        'internal/test/binding'
    ]
    process;
    hasEnded; // Promise indicating that node has exited
    client;
    dump = {};

    constructor(
        target = argv._[0],
        output = argv._[1],
        host, port = 9223
    ){
        this.target = target;
        this.output = output;
        this.host = host;
        this.port = port;

        let inspect_arg = '--inspect-brk';

        const has = {
            "target" : target != null && target.toString().trim().length,
            "host" : host != null && host.toString().trim().length,
            "port" : port != null && port.toString().trim().length,
        }

        if( has.host || has.port ){
            inspect_arg += "=";

            if( has.host ){
                inspect_arg += has.port ? host + ":" : host;
            }
            if( has.port ){
                inspect_arg += port;
            }
        }

        this.#args.push(inspect_arg);

        if( has.target )
            this.#args.push( target );
    }

    start(){
        console.warn(`Spawning Node: node ${this.#args.join(" ")}`);
        this.process = spawn('node', this.#args);

        this.process.stdout.setEncoding('utf8');
        this.process.stdout.on('data', data => {
            console.log(`stdout: ${data}`)
        })

        return new Promise( startResolve => {
            const awaitStart = data => {
                if( data.toString().startsWith("Debugger listening") ){
                    console.warn(`stderr: ${data}`);
                    this.process.stderr.on('data', data => {
                        if( data.toString().startsWith("Debugger attached"))
                            console.warn(`stderr: ${data}`);
                        else if( data.toString().startsWith("Debugger ending"))
                            console.warn(`stderr: ${data}`);
                        else if( data.toString().startsWith("For help"))
                            console.warn(`stderr: ${data}`);
                        else
                            console.error(`stderr: ${data}`);
                    })
                    this.#dump( startResolve );
                } else {
                    console.error(`stdout: ${data}`);
                    this.process.stderr.once('data', awaitStart);
                }
            }

            this.process.stderr.once('data', awaitStart);
        })
    }

    #dump = async ( startResolve ) => {
        this.hasEnded = new Promise( endResolve => {
            this.process.on('close', (code, sig) => {
                if( code == null )
                    code = 0;
                fs.writeFileSync(
                    this.output,
                    JSON.stringify(this.dump, null, 2)
                )
                endResolve()
                console.warn(`Node exited with code ${code} via signal ${sig}`);
            })
        })

        this.client = await CDP({ /* host: this.host, */ port: this.port });

        const { Debugger } = this.client;

        Debugger.enable();

        let lastParsedScripts = 0;

        const checkCompletion = () => {
            if( Object.keys(this.dump).length === lastParsedScripts ){
                console.warn("\nDump complete");
                startResolve();
            } else {
                lastParsedScripts = Object.keys(this.dump).length;
                setTimeout(checkCompletion, 1000);
            }
        }

        Debugger.on('scriptParsed', async (params) => {
            console.warn( `Script Parsed! - [${params.scriptId}] ${params.url}` );
            const { scriptSource: source } = await Debugger.getScriptSource({ scriptId: params.scriptId });
            this.dump[ params.scriptId ] = {
                metadata: params,
                source
            }
        })

        setTimeout(checkCompletion, 1000);
    }

    async close(){
        console.warn("Closing Node");
        await this.client.close();
        this.process.kill( 'SIGINT' );
        await this.hasEnded;
    }
}

(async () => {
    const dumper = new NodeDumper();
    await dumper.start();
    await dumper.close();
    process.exit();
})()