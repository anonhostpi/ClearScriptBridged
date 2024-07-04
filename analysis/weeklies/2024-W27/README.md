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

# Week 3: Knocking Out The Internal Bindings\

```
Internal Binding: async_wrap
- File: S:\ClearScriptBridged\node\src\async_wrap.cc
- Register: node::AsyncWrap::CreatePerContextProperties

Internal Binding: blob
- File: S:\ClearScriptBridged\node\src\node_blob.cc
- Register: node::Blob::CreatePerContextProperties

Internal Binding: block_list
- File: S:\ClearScriptBridged\node\src\node_sockaddr.cc
- Register: node::SocketAddressBlockListWrap::Initialize

Internal Binding: buffer
- File: S:\ClearScriptBridged\node\src\node_buffer.cc
- Register: node::Buffer::Initialize

Internal Binding: builtins
- File: S:\ClearScriptBridged\node\src\node_builtins.cc
- Register: node::builtins::BuiltinLoader::CreatePerContextProperties

Internal Binding: cares_wrap
- File: S:\ClearScriptBridged\node\src\cares_wrap.cc
- Register: node::cares_wrap::Initialize

Internal Binding: config
- File: S:\ClearScriptBridged\node\src\node_config.cc
- Register: node::Initialize

Internal Binding: constants
- File: S:\ClearScriptBridged\node\src\node_constants.cc
- Register: node::constants::CreatePerContextProperties

Internal Binding: contextify
- File: S:\ClearScriptBridged\node\src\node_contextify.cc
- Register: node::contextify::CreatePerContextProperties

Internal Binding: credentials
- File: S:\ClearScriptBridged\node\src\node_credentials.cc
- Register: node::credentials::Initialize

Internal Binding: crypto
- File: S:\ClearScriptBridged\node\src\node_crypto.cc
- Register: node::crypto::Initialize

Internal Binding: encoding_binding
- File: S:\ClearScriptBridged\node\src\encoding_binding.cc
- Register: node::encoding_binding::BindingData::CreatePerContextProperties

Internal Binding: errors
- File: S:\ClearScriptBridged\node\src\node_errors.cc
- Register: node::errors::Initialize

Internal Binding: fs
- File: S:\ClearScriptBridged\node\src\node_file.cc
- Register: node::fs::CreatePerContextProperties

Internal Binding: fs_dir
- File: S:\ClearScriptBridged\node\src\node_dir.cc
- Register: node::fs_dir::CreatePerContextProperties

Internal Binding: fs_event_wrap
- File: S:\ClearScriptBridged\node\src\fs_event_wrap.cc
- Register: node::FSEventWrap::Initialize

Internal Binding: heap_utils
- File: S:\ClearScriptBridged\node\src\heap_utils.cc
- Register: node::heap::Initialize

Internal Binding: http_parser
- File: S:\ClearScriptBridged\node\src\node_http_parser.cc
- Register: node::InitializeHttpParser

Internal Binding: http2
- File: S:\ClearScriptBridged\node\src\node_http2.cc
- Register: node::http2::Initialize

Internal Binding: icu
- File: S:\ClearScriptBridged\node\src\node_i18n.cc
- Register: node::i18n::CreatePerContextProperties

Internal Binding: inspector
- File: S:\ClearScriptBridged\node\src\inspector_js_api.cc
- Register: node::inspector::Initialize
- File: S:\ClearScriptBridged\node\src\node.cc
- Register: Initialize

Internal Binding: internal_only_v8
- File: S:\ClearScriptBridged\node\src\internal_only_v8.cc
- Register: node::internal_only_v8::Initialize

Internal Binding: js_stream
- File: S:\ClearScriptBridged\node\src\js_stream.cc
- Register: node::JSStream::Initialize

Internal Binding: js_udp_wrap
- File: S:\ClearScriptBridged\node\src\js_udp_wrap.cc
- Register: node::JSUDPWrap::Initialize

Internal Binding: messaging
- File: S:\ClearScriptBridged\node\src\node_messaging.cc
- Register: node::worker::CreatePerContextProperties

Internal Binding: mksnapshot
- File: S:\ClearScriptBridged\node\src\node_snapshotable.cc
- Register: node::mksnapshot::CreatePerContextProperties

Internal Binding: module_wrap
- File: S:\ClearScriptBridged\node\src\module_wrap.cc
- Register: node::loader::ModuleWrap::CreatePerContextProperties

Internal Binding: modules
- File: S:\ClearScriptBridged\node\src\node_modules.cc
- Register: node::modules::BindingData::CreatePerContextProperties

Internal Binding: options
- File: S:\ClearScriptBridged\node\src\node_options.cc
- Register: node::options_parser::Initialize

Internal Binding: os
- File: S:\ClearScriptBridged\node\src\node_os.cc
- Register: node::os::Initialize

Internal Binding: performance
- File: S:\ClearScriptBridged\node\src\node_perf.cc
- Register: node::performance::CreatePerContextProperties

Internal Binding: permission
- File: S:\ClearScriptBridged\node\src\permission\permission.cc
- Register: node::permission::Initialize

Internal Binding: pipe_wrap
- File: S:\ClearScriptBridged\node\src\pipe_wrap.cc
- Register: node::PipeWrap::Initialize

Internal Binding: process_methods
- File: S:\ClearScriptBridged\node\src\node_process_methods.cc
- Register: node::process::CreatePerContextProperties

Internal Binding: process_wrap
- File: S:\ClearScriptBridged\node\src\process_wrap.cc
- Register: node::ProcessWrap::Initialize

Internal Binding: profiler
- File: S:\ClearScriptBridged\node\src\inspector_profiler.cc
- Register: node::profiler::Initialize

Internal Binding: quic
- File: S:\ClearScriptBridged\node\src\quic\quic.cc
- Register: node::quic::CreatePerContextProperties

Internal Binding: report
- File: S:\ClearScriptBridged\node\src\node_report_module.cc
- Register: node::report::Initialize

Internal Binding: sea
- File: S:\ClearScriptBridged\node\src\node_sea.cc
- Register: node::sea::Initialize

Internal Binding: serdes
- File: S:\ClearScriptBridged\node\src\node_serdes.cc
- Register: node::serdes::Initialize

Internal Binding: signal_wrap
- File: S:\ClearScriptBridged\node\src\signal_wrap.cc
- Register: node::SignalWrap::Initialize

Internal Binding: spawn_sync
- File: S:\ClearScriptBridged\node\src\spawn_sync.cc
- Register: node::SyncProcessRunner::Initialize

Internal Binding: stream_pipe
- File: S:\ClearScriptBridged\node\src\stream_pipe.cc
- Register: node::InitializeStreamPipe

Internal Binding: stream_wrap
- File: S:\ClearScriptBridged\node\src\stream_wrap.cc
- Register: node::LibuvStreamWrap::Initialize

Internal Binding: string_decoder
- File: S:\ClearScriptBridged\node\src\string_decoder.cc
- Register: node::InitializeStringDecoder

Internal Binding: symbols
- File: S:\ClearScriptBridged\node\src\node_symbols.cc
- Register: node::symbols::Initialize

Internal Binding: task_queue
- File: S:\ClearScriptBridged\node\src\node_task_queue.cc
- Register: node::task_queue::Initialize

Internal Binding: tcp_wrap
- File: S:\ClearScriptBridged\node\src\tcp_wrap.cc
- Register: node::TCPWrap::Initialize

Internal Binding: timers
- File: S:\ClearScriptBridged\node\src\timers.cc
- Register: node::timers::BindingData::CreatePerContextProperties

Internal Binding: tls_wrap
- File: S:\ClearScriptBridged\node\src\crypto\crypto_tls.cc
- Register: node::crypto::TLSWrap::Initialize

Internal Binding: trace_events
- File: S:\ClearScriptBridged\node\src\node_trace_events.cc
- Register: node::NodeCategorySet::Initialize

Internal Binding: tty_wrap
- File: S:\ClearScriptBridged\node\src\tty_wrap.cc
- Register: node::TTYWrap::Initialize

Internal Binding: types
- File: S:\ClearScriptBridged\node\src\node_types.cc
- Register: node::InitializeTypes

Internal Binding: udp_wrap
- File: S:\ClearScriptBridged\node\src\udp_wrap.cc
- Register: node::UDPWrap::Initialize

Internal Binding: url
- File: S:\ClearScriptBridged\node\src\node_url.cc
- Register: node::url::BindingData::CreatePerContextProperties

Internal Binding: util
- File: S:\ClearScriptBridged\node\src\node_util.cc
- Register: node::util::Initialize

Internal Binding: uv
- File: S:\ClearScriptBridged\node\src\uv.cc
- Register: node::uv::Initialize

Internal Binding: v8
- File: S:\ClearScriptBridged\node\src\node_v8.cc
- Register: node::v8_utils::Initialize

Internal Binding: wasi
- File: S:\ClearScriptBridged\node\src\node_wasi.cc
- Register: node::wasi::InitializePreview1

Internal Binding: wasm_web_api
- File: S:\ClearScriptBridged\node\src\node_wasm_web_api.cc
- Register: node::wasm_web_api::Initialize

Internal Binding: watchdog
- File: S:\ClearScriptBridged\node\src\node_watchdog.cc
- Register: node::watchdog::Initialize

Internal Binding: webstorage
- File: S:\ClearScriptBridged\node\src\node_webstorage.cc
- Register: node::webstorage::Initialize

Internal Binding: worker
- File: S:\ClearScriptBridged\node\src\node_worker.cc
- Register: node::worker::CreateWorkerPerContextProperties

Internal Binding: zlib
- File: S:\ClearScriptBridged\node\src\node_zlib.cc
- Register: node::Initialize
```