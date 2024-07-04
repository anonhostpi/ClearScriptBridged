Prior posts from this mini-series:

* Turning PowerShell Into A Python Engine: [https://www.reddit.com/r/PowerShell/comments/192uavr/turning\_powershell\_into\_a\_python\_engine/](https://www.reddit.com/r/PowerShell/comments/192uavr/turning_powershell_into_a_python_engine/)
* Turning PowerShell Into A JavaScript Engine: [https://www.reddit.com/r/PowerShell/comments/1937hkv/turning\_powershell\_into\_a\_javascript\_engine/](https://www.reddit.com/r/PowerShell/comments/1937hkv/turning_powershell_into_a_javascript_engine/)
* Working On Turning PowerShell Into A Node.JS Engine: [https://www.reddit.com/r/PowerShell/comments/1djdql5/working_on_turning_powershell_into_a_nodejs_engine/](https://www.reddit.com/r/PowerShell/comments/1djdql5/working_on_turning_powershell_into_a_nodejs_engine/)
  * **TL;DR: [_Github gist_](https://gist.github.com/anonhostpi/7ebc4007f3f51e0f255c2408d33b1781)**
* Turning PowerShell into Node.JS: Week 1 Progress: [https://www.reddit.com/r/PowerShell/comments/1dpg8i8/turning_powershell_into_nodejs_week_1_progress/](https://www.reddit.com/r/PowerShell/comments/1dpg8i8/turning_powershell_into_nodejs_week_1_progress/)
  * **TL;DR: [_Old Github Repo_](https://gist.github.com/anonhostpi/njs-cjs-pwsh)**

# TL;DR:

```powershell
# I've reworked the structure of the project, and have given it a better name:
git clone https://github.com/anonhostpi/ClearScriptBridged.git
cd ClearScriptBridged
cd "analysis\weeklies\2024-W27"
. .\main.ps1

# $setup
# $paths

# $runtime
# $engine

# $dump
# $analysis
```

# Week 3: Knocking Out The Internal Bindings

I've updated my analysis script to help generate this post. Everything in blockquotes was generated using source code analysis. The lines following a blockquote are my comments on the generated data.

The data generated is a 2-part breakdown of the internal bindings in Node.JS. The first part is a list of where the bindings are registered in C++ land, and the second part is a list of where the bindings are used in JavaScript.

> The following bindings declarations/calls were only found in one of the two "lands":
> - Found only in C++ Land
>   - js_udp_wrap
>   - quic

It was found that these are only included in test files for Node.JS, and are not used in the main codebase. An effort to include them will be made, but not prioritized.

# Internal Binding: async_wrap

> Internal Binding: async_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\async_wrap.cc
>   - Register (731): node::AsyncWrap::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 11,12): S:\ClearScriptBridged\node\lib\internal\promise_hooks.js
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\trace_events_async_hooks.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 11,13,83,84,96): S:\ClearScriptBridged\node\lib\internal\async_hooks.js

This is a binding to the old AsyncWrap API. While it is deprecated, it is still used in the Node.JS codebase and is the basis for the newer AsyncHooks and promisication APIs. Its purpose is to provide hooks to track the lifecycle of asynchronous operations. It is used to handle various operations like file I/O, network I/O, timers, and more.

## Uses

**_promise_hooks.js_**: Lifecycle hooks for promises.
```
const { setPromiseHooks } = internalBinding('async_wrap');
```
**_trace_events_async_hooks.js_**: Integration with trace events.
```
const async_wrap = internalBinding('async_wrap');
// ...
const nativeProviders = new SafeSet(ObjectKeys(async_wrap.Providers));
// ...
nativeProviders.delete('PROMISE');
```
**_bootstrap\node.js_**: Initialization of the binding.
```
internalBinding('async_wrap').setupHooks(nativeHooks);
```
**_async_hooks.js_**: A less low-level API for async operations.
```
const async_wrap = internalBinding('async_wrap');
// ...
const {
  async_hook_fields,
  async_id_fields,
  execution_async_resources,
} = async_wrap;
// ...
const {
  pushAsyncContext: pushAsyncContext_,
  popAsyncContext: popAsyncContext_,
  executionAsyncResource: executionAsyncResource_,
  clearAsyncIdStack,
} = async_wrap;
// ...
const { registerDestroyHook } = async_wrap;
// ...
const {
  kInit, kBefore, kAfter, kDestroy, kTotals, kPromiseResolve,
  kCheck, kExecutionAsyncId, kAsyncIdCounter, kTriggerAsyncId,
  kDefaultTriggerAsyncId, kStackLength, kUsesExecutionAsyncResource,
} = async_wrap.constants;
// ...
async_wrap.queueDestroyAsyncId(asyncId);
// ...
async_wrap.async_ids_stack[offset * 2] = async_id_fields[kExecutionAsyncId];
async_wrap.async_ids_stack[offset * 2 + 1] = async_id_fields[kTriggerAsyncId];
// ...
async_id_fields[kExecutionAsyncId] = async_wrap.async_ids_stack[2 * offset];
async_id_fields[kTriggerAsyncId] = async_wrap.async_ids_stack[2 * offset + 1];
// ...
module.exports = {
  // ...
  constants: {
    kInit, kBefore, kAfter, kDestroy, kTotals, kPromiseResolve,
  },
  // ...
  clearAsyncIdStack,
  // ...
  registerDestroyHook,
  // ...
  asyncWrap: {
    Providers: async_wrap.Providers,
  },
}
```

# Internal Binding: blob

> Internal Binding: blob
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_blob.cc
>   - Register (585): node::Blob::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 27,30): S:\ClearScriptBridged\node\lib\internal\blob.js
>   - File (Lines: 91,1173): S:\ClearScriptBridged\node\lib\internal\url.js

# Internal Binding: block_list

> Internal Binding: block_list
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_sockaddr.cc
>   - Register (888): node::SocketAddressBlockListWrap::Initialize
> - JavaScript Land
>   - File (Lines: 11,31): S:\ClearScriptBridged\node\lib\internal\blocklist.js
>   - File (Lines: 12): S:\ClearScriptBridged\node\lib\internal\socketaddress.js

# Internal Binding: buffer

> Internal Binding: buffer
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_buffer.cc
>   - Register (1559): node::Buffer::Initialize
> - JavaScript Land
>   - File (Lines: 30,41): S:\ClearScriptBridged\node\lib\internal\webstreams\util.js
>   - File (Lines: 28,58): S:\ClearScriptBridged\node\lib\internal\util\comparisons.js
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js
>   - File (Lines: 27,30): S:\ClearScriptBridged\node\lib\internal\blob.js
>   - File (Lines: 34,40): S:\ClearScriptBridged\node\lib\internal\buffer.js
>   - File (Lines: 73,80,1216,1220): S:\ClearScriptBridged\node\lib\buffer.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js

# Internal Binding: builtins

> Internal Binding: builtins
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_builtins.cc
>   - Register (769): node::builtins::BuiltinLoader::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 15): S:\ClearScriptBridged\node\lib\internal\v8_prof_processor.js
>   - File (Lines: 121): S:\ClearScriptBridged\node\lib\internal\debugger\inspect_repl.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 37): S:\ClearScriptBridged\node\lib\internal\legacy\processbinding.js
>   - File (Lines: 199,201,447): S:\ClearScriptBridged\node\lib\internal\bootstrap\realm.js

# Internal Binding: cares_wrap

> Internal Binding: cares_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\cares_wrap.cc
>   - Register (2024): node::cares_wrap::Initialize
> - JavaScript Land
>   - File (Lines: 29): S:\ClearScriptBridged\node\lib\internal\dns\callback_resolver.js
>   - File (Lines: 63,65): S:\ClearScriptBridged\node\lib\tls.js
>   - File (Lines: 65): S:\ClearScriptBridged\node\lib\internal\dns\promises.js
>   - File (Lines: 31): S:\ClearScriptBridged\node\lib\internal\dns\utils.js
>   - File (Lines: 30): S:\ClearScriptBridged\node\lib\dns.js

# Internal Binding: config

> Internal Binding: config
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_config.cc
>   - Register (83): node::Initialize
> - JavaScript Land
>   - File (Lines: 35): S:\ClearScriptBridged\node\lib\internal\main\eval_string.js
>   - File (Lines: 73,80,1216,1220): S:\ClearScriptBridged\node\lib\buffer.js
>   - File (Lines: 7,297,304,308,310): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\is_main_thread.js
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 41,96,101): S:\ClearScriptBridged\node\lib\internal\bootstrap\web\exposed-window-or-worker.js
>   - File (Lines: 112,2323,2324): S:\ClearScriptBridged\node\lib\internal\util\inspect.js
>   - File (Lines: 49,85): S:\ClearScriptBridged\node\lib\internal\util\inspector.js
>   - File (Lines: 21,35,45): S:\ClearScriptBridged\node\lib\inspector.js
>   - File (Lines: 8,21): S:\ClearScriptBridged\node\lib\trace_events.js
>   - File (Lines: 19,35): S:\ClearScriptBridged\node\lib\internal\main\print_help.js
>   - File (Lines: 20,69): S:\ClearScriptBridged\node\lib\internal\bootstrap\web\exposed-wildcard.js
>   - File (Lines: 37,51,651,654): S:\ClearScriptBridged\node\lib\internal\console\constructor.js
>   - File (Lines: 11,13): S:\ClearScriptBridged\node\lib\internal\inspector_async_hook.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 52,390,398): S:\ClearScriptBridged\node\lib\internal\encoding.js

# Internal Binding: constants

> Internal Binding: constants
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_constants.cc
>   - Register (1371): node::constants::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 51,58,60,286): S:\ClearScriptBridged\node\lib\internal\process\per_thread.js
>   - File (Lines: 23,32): S:\ClearScriptBridged\node\lib\internal\fs\promises.js
>   - File (Lines: 20,66): S:\ClearScriptBridged\node\lib\internal\crypto\diffiehellman.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js
>   - File (Lines: 16,23): S:\ClearScriptBridged\node\lib\internal\crypto\cipher.js
>   - File (Lines: 34,35,61): S:\ClearScriptBridged\node\lib\os.js
>   - File (Lines: 108): S:\ClearScriptBridged\node\lib\internal\fs\utils.js
>   - File (Lines: 74,80): S:\ClearScriptBridged\node\lib\dgram.js
>   - File (Lines: 44): S:\ClearScriptBridged\node\lib\internal\tls\secure-context.js
>   - File (Lines: 27): S:\ClearScriptBridged\node\lib\internal\fs\cp\cp-sync.js
>   - File (Lines: 37): S:\ClearScriptBridged\node\lib\internal\validators.js
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\modules\esm\formats.js
>   - File (Lines: 47,72): S:\ClearScriptBridged\node\lib\_tls_common.js
>   - File (Lines: 36): S:\ClearScriptBridged\node\lib\internal\fs\cp\cp.js
>   - File (Lines: 84,88,96): S:\ClearScriptBridged\node\lib\internal\webstreams\adapters.js
>   - File (Lines: 65,82): S:\ClearScriptBridged\node\lib\zlib.js
>   - File (Lines: 46,65): S:\ClearScriptBridged\node\lib\fs.js
>   - File (Lines: 33,41): S:\ClearScriptBridged\node\lib\internal\crypto\util.js
>   - File (Lines: 33): S:\ClearScriptBridged\node\lib\constants.js
>   - File (Lines: 42,48): S:\ClearScriptBridged\node\lib\crypto.js
>   - File (Lines: 12,25): S:\ClearScriptBridged\node\lib\internal\process\signal.js

# Internal Binding: contextify

> Internal Binding: contextify
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_contextify.cc
>   - Register (1855): node::contextify::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 181,185): S:\ClearScriptBridged\node\lib\repl.js
>   - File (Lines: 37,68): S:\ClearScriptBridged\node\lib\vm.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 19,30,37): S:\ClearScriptBridged\node\lib\internal\process\execution.js
>   - File (Lines: 11,20,32): S:\ClearScriptBridged\node\lib\internal\vm.js
>   - File (Lines: 32,61): S:\ClearScriptBridged\node\lib\internal\modules\esm\translators.js
>   - File (Lines: 22): S:\ClearScriptBridged\node\lib\internal\modules\esm\get_format.js

# Internal Binding: credentials

> Internal Binding: credentials
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_credentials.cc
>   - Register (504): node::credentials::Initialize
> - JavaScript Land
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 3,4): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\does_not_own_process_state.js
>   - File (Lines: 3,4): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\does_own_process_state.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 34,35,61): S:\ClearScriptBridged\node\lib\os.js

# Internal Binding: crypto

> Internal Binding: crypto
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_crypto.cc
>   - Register (95): node::crypto::Initialize
> - JavaScript Land
>   - File (Lines: 63,64,65,68,88): S:\ClearScriptBridged\node\lib\_tls_wrap.js
>   - File (Lines: 16): S:\ClearScriptBridged\node\lib\internal\crypto\hash.js
>   - File (Lines: 13): S:\ClearScriptBridged\node\lib\internal\crypto\scrypt.js
>   - File (Lines: 18): S:\ClearScriptBridged\node\lib\internal\crypto\ec.js
>   - File (Lines: 26): S:\ClearScriptBridged\node\lib\internal\crypto\keygen.js
>   - File (Lines: 20,66): S:\ClearScriptBridged\node\lib\internal\crypto\diffiehellman.js
>   - File (Lines: 16,23): S:\ClearScriptBridged\node\lib\internal\crypto\cipher.js
>   - File (Lines: 18): S:\ClearScriptBridged\node\lib\internal\crypto\cfrg.js
>   - File (Lines: 7): S:\ClearScriptBridged\node\lib\internal\crypto\certificate.js
>   - File (Lines: 31): S:\ClearScriptBridged\node\lib\internal\crypto\random.js
>   - File (Lines: 11): S:\ClearScriptBridged\node\lib\internal\crypto\hkdf.js
>   - File (Lines: 23): S:\ClearScriptBridged\node\lib\internal\crypto\rsa.js
>   - File (Lines: 33): S:\ClearScriptBridged\node\lib\internal\crypto\aes.js
>   - File (Lines: 17): S:\ClearScriptBridged\node\lib\internal\crypto\x509.js
>   - File (Lines: 13): S:\ClearScriptBridged\node\lib\internal\crypto\pbkdf2.js
>   - File (Lines: 14): S:\ClearScriptBridged\node\lib\internal\crypto\mac.js
>   - File (Lines: 47,72): S:\ClearScriptBridged\node\lib\_tls_common.js
>   - File (Lines: 33): S:\ClearScriptBridged\node\lib\internal\crypto\sig.js
>   - File (Lines: 33,41): S:\ClearScriptBridged\node\lib\internal\crypto\util.js
>   - File (Lines: 63,65): S:\ClearScriptBridged\node\lib\tls.js
>   - File (Lines: 42,48): S:\ClearScriptBridged\node\lib\crypto.js
>   - File (Lines: 21): S:\ClearScriptBridged\node\lib\internal\crypto\webcrypto.js
>   - File (Lines: 27): S:\ClearScriptBridged\node\lib\internal\crypto\keys.js

# Internal Binding: encoding_binding

> Internal Binding: encoding_binding
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\encoding_binding.cc
>   - Register (251): node::encoding_binding::BindingData::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 52,390,398): S:\ClearScriptBridged\node\lib\internal\encoding.js
>   - File (Lines: 3): S:\ClearScriptBridged\node\lib\internal\idna.js

# Internal Binding: errors

> Internal Binding: errors
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_errors.cc
>   - Register (1310): node::errors::Initialize
> - JavaScript Land
>   - File (Lines: 51,58,60,286): S:\ClearScriptBridged\node\lib\internal\process\per_thread.js
>   - File (Lines: 29,56,146): S:\ClearScriptBridged\node\lib\internal\main\worker_thread.js
>   - File (Lines: 253): S:\ClearScriptBridged\node\lib\internal\modules\esm\worker.js
>   - File (Lines: 21): S:\ClearScriptBridged\node\lib\internal\source_map\source_map_cache.js
>   - File (Lines: 30): S:\ClearScriptBridged\node\lib\diagnostics_channel.js
>   - File (Lines: 19): S:\ClearScriptBridged\node\lib\internal\main\repl.js
>   - File (Lines: 11,13,83,84,96): S:\ClearScriptBridged\node\lib\internal\async_hooks.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 80): S:\ClearScriptBridged\node\lib\internal\test_runner\runner.js
>   - File (Lines: 8,19): S:\ClearScriptBridged\node\lib\internal\test_runner\harness.js
>   - File (Lines: 8,18,23): S:\ClearScriptBridged\node\lib\internal\modules\run_main.js
>   - File (Lines: 50): S:\ClearScriptBridged\node\lib\internal\debugger\inspect.js
>   - File (Lines: 19,30,37): S:\ClearScriptBridged\node\lib\internal\process\execution.js
>   - File (Lines: 21,29): S:\ClearScriptBridged\node\lib\internal\process\promises.js
>   - File (Lines: 19): S:\ClearScriptBridged\node\lib\internal\main\watch_mode.js
>   - File (Lines: 11,12): S:\ClearScriptBridged\node\lib\internal\promise_hooks.js
>   - File (Lines: 18): S:\ClearScriptBridged\node\lib\internal\cluster\child.js
>   - File (Lines: 35,37): S:\ClearScriptBridged\node\lib\internal\modules\esm\hooks.js
>   - File (Lines: 199,201,447): S:\ClearScriptBridged\node\lib\internal\bootstrap\realm.js
>   - File (Lines: 17): S:\ClearScriptBridged\node\lib\internal\main\test_runner.js
>   - File (Lines: 25): S:\ClearScriptBridged\node\lib\internal\source_map\prepare_stack_trace.js

# Internal Binding: fs

> Internal Binding: fs
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_file.cc
>   - Register (3488): node::fs::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 10): S:\ClearScriptBridged\node\lib\internal\net.js
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\modules\esm\formats.js
>   - File (Lines: 18): S:\ClearScriptBridged\node\lib\internal\fs\read\context.js
>   - File (Lines: 38,39,57): S:\ClearScriptBridged\node\lib\internal\modules\esm\resolve.js
>   - File (Lines: 46,65): S:\ClearScriptBridged\node\lib\fs.js
>   - File (Lines: 187,188,193,194,196): S:\ClearScriptBridged\node\lib\internal\http2\core.js
>   - File (Lines: 25,27,28): S:\ClearScriptBridged\node\lib\internal\fs\watchers.js
>   - File (Lines: 13,14): S:\ClearScriptBridged\node\lib\internal\fs\dir.js
>   - File (Lines: 23,32): S:\ClearScriptBridged\node\lib\internal\fs\promises.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js

# Internal Binding: fs_dir

> Internal Binding: fs_dir
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_dir.cc
>   - Register (466): node::fs_dir::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 13,14): S:\ClearScriptBridged\node\lib\internal\fs\dir.js

# Internal Binding: fs_event_wrap

> Internal Binding: fs_event_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\fs_event_wrap.cc
>   - Register (243): node::FSEventWrap::Initialize
> - JavaScript Land
>   - File (Lines: 25,27,28): S:\ClearScriptBridged\node\lib\internal\fs\watchers.js

# Internal Binding: heap_utils

> Internal Binding: heap_utils
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\heap_utils.cc
>   - Register (496): node::heap::Initialize
> - JavaScript Land
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js

# Internal Binding: http_parser

> Internal Binding: http_parser
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_http_parser.cc
>   - Register (1367): node::InitializeHttpParser
> - JavaScript Land
>   - File (Lines: 52): S:\ClearScriptBridged\node\lib\_http_server.js
>   - File (Lines: 31): S:\ClearScriptBridged\node\lib\_http_common.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js

# Internal Binding: http2

> Internal Binding: http2
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_http2.cc
>   - Register (3471): node::http2::Initialize
> - JavaScript Land
>   - File (Lines: 21): S:\ClearScriptBridged\node\lib\internal\http2\util.js
>   - File (Lines: 187,188,193,194,196): S:\ClearScriptBridged\node\lib\internal\http2\core.js
>   - File (Lines: 39): S:\ClearScriptBridged\node\lib\internal\http2\compat.js

# Internal Binding: icu

> Internal Binding: icu
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_i18n.cc
>   - Register (915): node::i18n::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 73,80,1216,1220): S:\ClearScriptBridged\node\lib\buffer.js
>   - File (Lines: 52,390,398): S:\ClearScriptBridged\node\lib\internal\encoding.js
>   - File (Lines: 112,2323,2324): S:\ClearScriptBridged\node\lib\internal\util\inspect.js

# Internal Binding: inspector

> Internal Binding: inspector
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\inspector_js_api.cc
>   - Register (402): node::inspector::Initialize
>   - File: S:\ClearScriptBridged\node\src\node.cc
>   - Register (1487): Initialize
> - JavaScript Land
>   - File (Lines: 11,13): S:\ClearScriptBridged\node\lib\internal\inspector_async_hook.js
>   - File (Lines: 37,51,651,654): S:\ClearScriptBridged\node\lib\internal\console\constructor.js
>   - File (Lines: 20,69): S:\ClearScriptBridged\node\lib\internal\bootstrap\web\exposed-wildcard.js
>   - File (Lines: 49,85): S:\ClearScriptBridged\node\lib\internal\util\inspector.js
>   - File (Lines: 26,31,168): S:\ClearScriptBridged\node\lib\internal\modules\esm\module_job.js
>   - File (Lines: 21,35,45): S:\ClearScriptBridged\node\lib\inspector.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js

# Internal Binding: inspector_only_v8

> Internal Binding: internal_only_v8
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\internal_only_v8.cc
>   - Register (82): node::internal_only_v8::Initialize
> - JavaScript Land
>   - File (Lines: 26): S:\ClearScriptBridged\node\lib\internal\heap_utils.js

# Internal Binding: js_stream

> Internal Binding: js_stream
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\js_stream.cc
>   - Register (226): node::JSStream::Initialize
> - JavaScript Land
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\js_stream_socket.js

# Internal Binding: js_udp_wrap

> Internal Binding: js_udp_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\js_udp_wrap.cc
>   - Register (220): node::JSUDPWrap::Initialize

# Internal Binding: messaging

> Internal Binding: messaging
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_messaging.cc
>   - Register (1724): node::worker::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 41,96,101): S:\ClearScriptBridged\node\lib\internal\bootstrap\web\exposed-window-or-worker.js
>   - File (Lines: 34): S:\ClearScriptBridged\node\lib\internal\perf\usertiming.js
>   - File (Lines: 30): S:\ClearScriptBridged\node\lib\internal\webstreams\writablestream.js
>   - File (Lines: 43,90): S:\ClearScriptBridged\node\lib\internal\webstreams\readablestream.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js
>   - File (Lines: 23): S:\ClearScriptBridged\node\lib\internal\webstreams\transformstream.js
>   - File (Lines: 53): S:\ClearScriptBridged\node\lib\internal\abort_controller.js
>   - File (Lines: 16): S:\ClearScriptBridged\node\lib\internal\webstreams\transfer.js
>   - File (Lines: 31,41,44): S:\ClearScriptBridged\node\lib\internal\worker\io.js
>   - File (Lines: 11,14,24): S:\ClearScriptBridged\node\lib\internal\worker\js_transferable.js

# Internal Binding: mksnapshot

> Internal Binding: mksnapshot
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_snapshotable.cc
>   - Register (1635): node::mksnapshot::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 19): S:\ClearScriptBridged\node\lib\internal\v8\startup_snapshot.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 16,18): S:\ClearScriptBridged\node\lib\internal\main\mksnapshot.js

# Internal Binding: module_wrap

> Internal Binding: module_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\module_wrap.cc
>   - Register (1100): node::loader::ModuleWrap::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 22,39): S:\ClearScriptBridged\node\lib\internal\modules\esm\loader.js
>   - File (Lines: 32,61): S:\ClearScriptBridged\node\lib\internal\modules\esm\translators.js
>   - File (Lines: 7,297,304,308,310): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\is_main_thread.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 26,31,168): S:\ClearScriptBridged\node\lib\internal\modules\esm\module_job.js
>   - File (Lines: 29,56,146): S:\ClearScriptBridged\node\lib\internal\main\worker_thread.js
>   - File (Lines: 73): S:\ClearScriptBridged\node\lib\internal\main\check_syntax.js
>   - File (Lines: 55): S:\ClearScriptBridged\node\lib\internal\vm\module.js
>   - File (Lines: 14,21,23,45): S:\ClearScriptBridged\node\lib\internal\modules\esm\utils.js
>   - File (Lines: 199,201,447): S:\ClearScriptBridged\node\lib\internal\bootstrap\realm.js

# Internal Binding: modules

> Internal Binding: modules
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_modules.cc
>   - Register (452): node::modules::BindingData::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 10): S:\ClearScriptBridged\node\lib\internal\modules\package_json_reader.js
>   - File (Lines: 8,18,23): S:\ClearScriptBridged\node\lib\internal\modules\run_main.js

# Internal Binding: options

> Internal Binding: options
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_options.cc
>   - Register (1515): node::options_parser::Initialize
> - JavaScript Land
>   - File (Lines: 7): S:\ClearScriptBridged\node\lib\internal\options.js
>   - File (Lines: 19,35): S:\ClearScriptBridged\node\lib\internal\main\print_help.js
>   - File (Lines: 51,58,60,286): S:\ClearScriptBridged\node\lib\internal\process\per_thread.js

# Internal Binding: os

> Internal Binding: os
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_os.cc
>   - Register (433): node::os::Initialize
> - JavaScript Land
>   - File (Lines: 27): S:\ClearScriptBridged\node\lib\internal\navigator.js
>   - File (Lines: 617,909,939): S:\ClearScriptBridged\node\lib\internal\errors.js
>   - File (Lines: 34,35,61): S:\ClearScriptBridged\node\lib\os.js

# Internal Binding: performance

> Internal Binding: performance
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_perf.cc
>   - Register (402): node::performance::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 36): S:\ClearScriptBridged\node\lib\internal\perf\observe.js
>   - File (Lines: 17): S:\ClearScriptBridged\node\lib\internal\perf\event_loop_delay.js
>   - File (Lines: 15): S:\ClearScriptBridged\node\lib\internal\histogram.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 10): S:\ClearScriptBridged\node\lib\internal\perf\utils.js
>   - File (Lines: 9): S:\ClearScriptBridged\node\lib\internal\perf\event_loop_utilization.js
>   - File (Lines: 9): S:\ClearScriptBridged\node\lib\perf_hooks.js
>   - File (Lines: 31): S:\ClearScriptBridged\node\lib\internal\perf\nodetiming.js

# Internal Binding: permission

> Internal Binding: permission
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\permission\permission.cc
>   - Register (181): node::permission::Initialize
> - JavaScript Land
>   - File (Lines: 8): S:\ClearScriptBridged\node\lib\internal\process\permission.js

# Internal Binding: pipe_wrap

> Internal Binding: pipe_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\pipe_wrap.cc
>   - Register (254): node::PipeWrap::Initialize
> - JavaScript Land
>   - File (Lines: 63): S:\ClearScriptBridged\node\lib\child_process.js
>   - File (Lines: 64,67,72,77): S:\ClearScriptBridged\node\lib\net.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js
>   - File (Lines: 63,64,65,68,88): S:\ClearScriptBridged\node\lib\_tls_wrap.js

# Internal Binding: process_methods

> Internal Binding: process_methods
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_process_methods.cc
>   - Register (716): node::process::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 7,297,304,308,310): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\is_main_thread.js
>   - File (Lines: 3,4): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\does_own_process_state.js
>   - File (Lines: 51,58,60,286): S:\ClearScriptBridged\node\lib\internal\process\per_thread.js
>   - File (Lines: 3,4): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\does_not_own_process_state.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 21,35,45): S:\ClearScriptBridged\node\lib\inspector.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js

# Internal Binding: process_wrap

> Internal Binding: process_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\process_wrap.cc
>   - Register (344): node::ProcessWrap::Initialize
> - JavaScript Land
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js

# Internal Binding: profiler

> Internal Binding: profiler
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\inspector_profiler.cc
>   - Register (580): node::profiler::Initialize
> - JavaScript Land
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js
>   - File (Lines: 125): S:\ClearScriptBridged\node\lib\internal\test_runner\coverage.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js

# Internal Binding: quic

> Internal Binding: quic
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\quic\quic.cc
>   - Register (50): node::quic::CreatePerContextProperties

# Internal Binding: report

> Internal Binding: report
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_report_module.cc
>   - Register (235): node::report::Initialize
> - JavaScript Land
>   - File (Lines: 17): S:\ClearScriptBridged\node\lib\internal\process\report.js

# Internal Binding: sea

> Internal Binding: sea
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_sea.cc
>   - Register (643): node::sea::Initialize
> - JavaScript Land
>   - File (Lines: 6): S:\ClearScriptBridged\node\lib\sea.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 16,18): S:\ClearScriptBridged\node\lib\internal\main\mksnapshot.js
>   - File (Lines: 7): S:\ClearScriptBridged\node\lib\internal\util\embedding.js
>   - File (Lines: 5): S:\ClearScriptBridged\node\lib\internal\main\embedding.js

# Internal Binding: serdes

> Internal Binding: serdes
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_serdes.cc
>   - Register (541): node::serdes::Initialize
> - JavaScript Land
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js

# Internal Binding: signal_wrap

> Internal Binding: signal_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\signal_wrap.cc
>   - Register (177): node::SignalWrap::Initialize
> - JavaScript Land
>   - File (Lines: 12,25): S:\ClearScriptBridged\node\lib\internal\process\signal.js

# Internal Binding: spawn_sync

> Internal Binding: spawn_sync
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\spawn_sync.cc
>   - Register (1120): node::SyncProcessRunner::Initialize
> - JavaScript Land
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js

# Internal Binding: stream_pipe

> Internal Binding: stream_pipe
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\stream_pipe.cc
>   - Register (335): node::InitializeStreamPipe
> - JavaScript Land
>   - File (Lines: 187,188,193,194,196): S:\ClearScriptBridged\node\lib\internal\http2\core.js

# Internal Binding: stream_wrap

> Internal Binding: stream_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\stream_wrap.cc
>   - Register (418): node::LibuvStreamWrap::Initialize
> - JavaScript Land
>   - File (Lines: 64,67,72,77): S:\ClearScriptBridged\node\lib\net.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js
>   - File (Lines: 187,188,193,194,196): S:\ClearScriptBridged\node\lib\internal\http2\core.js
>   - File (Lines: 17,18): S:\ClearScriptBridged\node\lib\internal\stream_base_commons.js
>   - File (Lines: 16): S:\ClearScriptBridged\node\lib\internal\child_process\serialization.js
>   - File (Lines: 84,88,96): S:\ClearScriptBridged\node\lib\internal\webstreams\adapters.js

# Internal Binding: string_decoder

> Internal Binding: string_decoder
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\string_decoder.cc
>   - Register (345): node::InitializeStringDecoder
> - JavaScript Land
>   - File (Lines: 41): S:\ClearScriptBridged\node\lib\string_decoder.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js

# Internal Binding: symbols

> Internal Binding: symbols
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_symbols.cc
>   - Register (32): node::symbols::Initialize
> - JavaScript Land
>   - File (Lines: 63,64,65,68,88): S:\ClearScriptBridged\node\lib\_tls_wrap.js
>   - File (Lines: 37,68): S:\ClearScriptBridged\node\lib\vm.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 22,39): S:\ClearScriptBridged\node\lib\internal\modules\esm\loader.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 11,13,83,84,96): S:\ClearScriptBridged\node\lib\internal\async_hooks.js
>   - File (Lines: 11,20,32): S:\ClearScriptBridged\node\lib\internal\vm.js
>   - File (Lines: 11,31): S:\ClearScriptBridged\node\lib\internal\blocklist.js
>   - File (Lines: 14,21,23,45): S:\ClearScriptBridged\node\lib\internal\modules\esm\utils.js
>   - File (Lines: 11,14,24): S:\ClearScriptBridged\node\lib\internal\worker\js_transferable.js
>   - File (Lines: 31,41,44): S:\ClearScriptBridged\node\lib\internal\worker\io.js

# Internal Binding: task_queue

> Internal Binding: task_queue
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_task_queue.cc
>   - Register (196): node::task_queue::Initialize
> - JavaScript Land
>   - File (Lines: 21,29): S:\ClearScriptBridged\node\lib\internal\process\promises.js
>   - File (Lines: 16): S:\ClearScriptBridged\node\lib\internal\process\task_queues.js
>   - File (Lines: 11,13,83,84,96): S:\ClearScriptBridged\node\lib\internal\async_hooks.js

# Internal Binding: tcp_wrap

> Internal Binding: tcp_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\tcp_wrap.cc
>   - Register (446): node::TCPWrap::Initialize
> - JavaScript Land
>   - File (Lines: 13): S:\ClearScriptBridged\node\lib\internal\cluster\round_robin_handle.js
>   - File (Lines: 64,67,72,77): S:\ClearScriptBridged\node\lib\net.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js
>   - File (Lines: 63,64,65,68,88): S:\ClearScriptBridged\node\lib\_tls_wrap.js

# Internal Binding: timers

> Internal Binding: timers
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\timers.cc
>   - Register (196): node::timers::BindingData::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 32): S:\ClearScriptBridged\node\lib\timers.js
>   - File (Lines: 85): S:\ClearScriptBridged\node\lib\internal\timers.js

# Internal Binding: tls_wrap

> Internal Binding: tls_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\crypto\crypto_tls.cc
>   - Register (2239): node::crypto::TLSWrap::Initialize
> - JavaScript Land
>   - File (Lines: 63,64,65,68,88): S:\ClearScriptBridged\node\lib\_tls_wrap.js

# Internal Binding: trace_events

> Internal Binding: trace_events
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_trace_events.cc
>   - Register (170): node::NodeCategorySet::Initialize
> - JavaScript Land
>   - File (Lines: 11): S:\ClearScriptBridged\node\lib\internal\http.js
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\trace_events_async_hooks.js
>   - File (Lines: 37,51,651,654): S:\ClearScriptBridged\node\lib\internal\console\constructor.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 23): S:\ClearScriptBridged\node\lib\internal\util\debuglog.js
>   - File (Lines: 8,21): S:\ClearScriptBridged\node\lib\trace_events.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js

# Internal Binding: tty_wrap

> Internal Binding: tty_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\tty_wrap.cc
>   - Register (157): node::TTYWrap::Initialize
> - JavaScript Land
>   - File (Lines: 31): S:\ClearScriptBridged\node\lib\tty.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js

# Internal Binding: types

> Internal Binding: types
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_types.cc
>   - Register (88): node::InitializeTypes
> - JavaScript Land
>   - File (Lines: 167): S:\ClearScriptBridged\node\lib\internal\test_runner\reporter\tap.js
>   - File (Lines: 58): S:\ClearScriptBridged\node\lib\internal\util\types.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js

# Internal Binding: udp_wrap

> Internal Binding: udp_wrap
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\udp_wrap.cc
>   - Register (839): node::UDPWrap::Initialize
> - JavaScript Land
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js
>   - File (Lines: 74,80): S:\ClearScriptBridged\node\lib\dgram.js
>   - File (Lines: 11,17): S:\ClearScriptBridged\node\lib\internal\dgram.js

# Internal Binding: url

> Internal Binding: url
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_url.cc
>   - Register (551): node::url::BindingData::CreatePerContextProperties
> - JavaScript Land
>   - File (Lines: 91,1173): S:\ClearScriptBridged\node\lib\internal\url.js
>   - File (Lines: 30): S:\ClearScriptBridged\node\lib\internal\modules\helpers.js
>   - File (Lines: 35,37): S:\ClearScriptBridged\node\lib\internal\modules\esm\hooks.js
>   - File (Lines: 63): S:\ClearScriptBridged\node\lib\url.js
>   - File (Lines: 38,39,57): S:\ClearScriptBridged\node\lib\internal\modules\esm\resolve.js

# Internal Binding: util

> Internal Binding: util
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_util.cc
>   - Register (392): node::util::Initialize
> - JavaScript Land
>   - File (Lines: 14,21,23,45): S:\ClearScriptBridged\node\lib\internal\modules\esm\utils.js
>   - File (Lines: 11,14,24): S:\ClearScriptBridged\node\lib\internal\worker\js_transferable.js
>   - File (Lines: 11,20,32): S:\ClearScriptBridged\node\lib\internal\vm.js
>   - File (Lines: 37,51,651,654): S:\ClearScriptBridged\node\lib\internal\console\constructor.js
>   - File (Lines: 73,80,1216,1220): S:\ClearScriptBridged\node\lib\buffer.js
>   - File (Lines: 72,74,137,142,143,160,1388,1451): S:\ClearScriptBridged\node\lib\internal\modules\cjs\loader.js
>   - File (Lines: 65): S:\ClearScriptBridged\node\lib\util.js
>   - File (Lines: 26,31,168): S:\ClearScriptBridged\node\lib\internal\modules\esm\module_job.js
>   - File (Lines: 181,185): S:\ClearScriptBridged\node\lib\repl.js
>   - File (Lines: 15): S:\ClearScriptBridged\node\lib\internal\source_map\source_map_cache_map.js
>   - File (Lines: 112,2323,2324): S:\ClearScriptBridged\node\lib\internal\util\inspect.js
>   - File (Lines: 617,909,939): S:\ClearScriptBridged\node\lib\internal\errors.js
>   - File (Lines: 8,18,23): S:\ClearScriptBridged\node\lib\internal\modules\run_main.js
>   - File (Lines: 8,19): S:\ClearScriptBridged\node\lib\internal\test_runner\harness.js
>   - File (Lines: 19,30,37): S:\ClearScriptBridged\node\lib\internal\process\execution.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js
>   - File (Lines: 30): S:\ClearScriptBridged\node\lib\internal\test_runner\test.js
>   - File (Lines: 30,41): S:\ClearScriptBridged\node\lib\internal\webstreams\util.js
>   - File (Lines: 28,58): S:\ClearScriptBridged\node\lib\internal\util\comparisons.js
>   - File (Lines: 34,40): S:\ClearScriptBridged\node\lib\internal\buffer.js
>   - File (Lines: 68,86,138,158,194,208,222,303,317,338,405): S:\ClearScriptBridged\node\lib\internal\bootstrap\node.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js

# Internal Binding: uv

> Internal Binding: uv
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\uv.cc
>   - Register (140): node::uv::Initialize
> - JavaScript Land
>   - File (Lines: 64,67,72,77): S:\ClearScriptBridged\node\lib\net.js
>   - File (Lines: 17,18): S:\ClearScriptBridged\node\lib\internal\stream_base_commons.js
>   - File (Lines: 10,11): S:\ClearScriptBridged\node\lib\internal\js_stream_socket.js
>   - File (Lines: 11,17): S:\ClearScriptBridged\node\lib\internal\dgram.js
>   - File (Lines: 187,188,193,194,196): S:\ClearScriptBridged\node\lib\internal\http2\core.js
>   - File (Lines: 57,66,67,69,80,698,703,831,832): S:\ClearScriptBridged\node\lib\internal\util.js
>   - File (Lines: 25,27,28): S:\ClearScriptBridged\node\lib\internal\fs\watchers.js
>   - File (Lines: 45,52,53,54,55,56,61,75,80): S:\ClearScriptBridged\node\lib\internal\child_process.js
>   - File (Lines: 617,909,939): S:\ClearScriptBridged\node\lib\internal\errors.js
>   - File (Lines: 84,88,96): S:\ClearScriptBridged\node\lib\internal\webstreams\adapters.js

# Internal Binding: v8

> Internal Binding: v8
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_v8.cc
>   - Register (506): node::v8_utils::Initialize
> - JavaScript Land
>   - File (Lines: 41,47,48,52,60,105): S:\ClearScriptBridged\node\lib\v8.js

# Internal Binding: wasi

> Internal Binding: wasi
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_wasi.cc
>   - Register (1336): node::wasi::InitializePreview1
> - JavaScript Land
>   - File (Lines: 54,58): S:\ClearScriptBridged\node\lib\wasi.js

# Internal Binding: wasm_web_api

> Internal Binding: wasm_web_api
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_wasm_web_api.cc
>   - Register (210): node::wasm_web_api::Initialize
> - JavaScript Land
>   - File (Lines: 7,297,304,308,310): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\is_main_thread.js
>   - File (Lines: 41,96,101): S:\ClearScriptBridged\node\lib\internal\bootstrap\web\exposed-window-or-worker.js

# Internal Binding: watchdog

> Internal Binding: watchdog
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_watchdog.cc
>   - Register (437): node::watchdog::Initialize
> - JavaScript Land
>   - File (Lines: 5): S:\ClearScriptBridged\node\lib\internal\watchdog.js

# Internal Binding: webstorage

> Internal Binding: webstorage
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_webstorage.cc
>   - Register (706): node::webstorage::Initialize
> - JavaScript Land
>   - File (Lines: 8): S:\ClearScriptBridged\node\lib\internal\webstorage.js

# Internal Binding: worker

> Internal Binding: worker
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_worker.cc
>   - Register (1020): node::worker::CreateWorkerPerContextProperties
> - JavaScript Land
>   - File (Lines: 29,56,146): S:\ClearScriptBridged\node\lib\internal\main\worker_thread.js
>   - File (Lines: 75,78,122,143,214,421,432,437,450,483,638,655,677): S:\ClearScriptBridged\node\lib\internal\process\pre_execution.js
>   - File (Lines: 31,41,44): S:\ClearScriptBridged\node\lib\internal\worker\io.js
>   - File (Lines: 77): S:\ClearScriptBridged\node\lib\internal\worker.js
>   - File (Lines: 7,297,304,308,310): S:\ClearScriptBridged\node\lib\internal\bootstrap\switches\is_main_thread.js

# Internal Binding: zlib

> Internal Binding: zlib
> - C++ Land
>   - File: S:\ClearScriptBridged\node\src\node_zlib.cc
>   - Register (1463): node::Initialize
> - JavaScript Land
>   - File (Lines: 65,82): S:\ClearScriptBridged\node\lib\zlib.js