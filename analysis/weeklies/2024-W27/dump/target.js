require("module").builtinModules.forEach( mod => {
    // check if globalThis already contains key mod
    console.log( mod )
    if( mod === "internal/main/prof_process" )
        return;
    if( globalThis[mod] === undefined ){
        // if not, add it
        try { globalThis[mod] = require(mod); } catch(e) { console.error(e); }
    } else {
        // if it does, find another name
        let i = 1;
        while( globalThis[`${mod}_${i}`] !== undefined )
            i++;
        try { globalThis[`${mod}_${i}`] = require(mod); } catch(e) { console.error(e); }
    }
})

Object.getOwnPropertyNames(globalThis).forEach(name => { console.log( name )})

// process.moduleLoadList.filter( item => item.startsWith("NativeModule") )
// process.moduleLoadList.filter( item => item.startsWith("Internal Binding") )