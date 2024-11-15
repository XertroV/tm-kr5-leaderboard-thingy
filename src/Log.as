void log_trace(const string &in msg) {
    if (!S_ExtraLogging) return;
    trace(msg);
}
