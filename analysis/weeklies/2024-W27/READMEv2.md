Related posts to this mini-series:

* Turning PowerShell Into A Python Engine: [https://www.reddit.com/r/PowerShell/comments/192uavr/turning\_powershell\_into\_a\_python\_engine/](https://www.reddit.com/r/PowerShell/comments/192uavr/turning_powershell_into_a_python_engine/)
* Turning PowerShell Into A JavaScript Engine: [https://www.reddit.com/r/PowerShell/comments/1937hkv/turning\_powershell\_into\_a\_javascript\_engine/](https://www.reddit.com/r/PowerShell/comments/1937hkv/turning_powershell_into_a_javascript_engine/)

Prior posts from this series

* Working On Turning PowerShell Into A Node.JS Engine: https://www.reddit.com/r/PowerShell/comments/1djdql5/working\_on\_turning\_powershell\_into\_a\_nodejs\_engine/
   * **TL;DR:** [***Github gist***](https://gist.github.com/anonhostpi/7ebc4007f3f51e0f255c2408d33b1781)
* Week 1 Progress: https://www.reddit.com/r/PowerShell/comments/1dpg8i8/turning\_powershell\_into\_nodejs\_week\_1\_progress/
   * **TL;DR:** [***Old Github Repo***](https://gist.github.com/anonhostpi/njs-cjs-pwsh)
* Week 2 Progress: https://www.reddit.com/r/PowerShell/comments/1dv35de/turning\_powershell\_into\_nodejs\_week\_2\_progress/
   * **TL;DR:**



    # I've reworked the structure of the project, and have given it a better name:
    git clone 
    cd ClearScriptBridged
    cd "analysis\weeklies\2024-W27"
    . .\main.ps1
    
    # $setup
    # $paths
    
    # $runtime
    # $engine
    
    # $dump
    # $analysishttps://github.com/anonhostpi/ClearScriptBridged.git

# Week 3: Deno vs Node.JS

So while I was working on what I had originally planned for this week...

* [https://github.com/anonhostpi/ClearScriptBridged/tree/main/analysis/weeklies/2024-W27](https://github.com/anonhostpi/ClearScriptBridged/tree/main/analysis/weeklies/2024-W27)

...I came across the Deno engine. Deno is a Rust-based alternative to Node written by the same developer. The part that caught my eye is that Deno is explicitly designed to be embeddable:

* [https://docs.deno.com/runtime/manual/advanced/embedding\_deno/](https://docs.deno.com/runtime/manual/advanced/embedding_deno/)

However, its designed to be embedded in another Rust application, so to embed it in C#, I would have to write Rust FFIs in addition to C# bindings.

This is an option I would like to explore.

The only problem I've encountered so far is that due to Deno's novelty, the embedding API hasn't been well documented, so I would have to read through their source code to figure out how to embed it.

The fortunate part is that it is written in Rust, and Rust is arguably significantly less complex than C++.

I know this update is short. The next one will make up for it, since I will be wrapping up `internalBinding()`, so I can start digging into each of the bindings