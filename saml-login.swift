import Cocoa
import WebKit
// Uso: saml-login <archivo-salida> <login-url> [marcador-exito]
// Abre el login SAML en una ventana, deja hacer MFA y, al llegar a la pagina
// de exito, escribe USER=.. y TOKEN=.. en <archivo-salida>. Codigo 0 = ok.
let a = CommandLine.arguments
let outPath = a.count > 1 ? a[1] : ""
let loginURL = a.count > 2 ? a[2] : ""
let marker = a.count > 3 ? a[3] : "sslvpn_success.shtml"

final class Ctrl: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate, NSWindowDelegate {
    var window: NSWindow!; var web: WKWebView!; var done = false
    func applicationDidFinishLaunching(_ n: Notification) {
        let r = NSRect(x: 0, y: 0, width: 520, height: 700)
        window = NSWindow(contentRect: r, styleMask: [.titled,.closable,.miniaturizable,.resizable],
                          backing: .buffered, defer: false)
        window.title = "USM VPN — Login SAML"; window.center(); window.delegate = self
        let wcfg = WKWebViewConfiguration()
        wcfg.websiteDataStore = WKWebsiteDataStore.nonPersistent()  // sesion efimera: sin cookies guardadas
        web = WKWebView(frame: r, configuration: wcfg)
        web.navigationDelegate = self; web.uiDelegate = self
        window.contentView = web; window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        if let u = URL(string: loginURL) { web.load(URLRequest(url: u)) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) { if !self.done { exit(4) } }
    }
    func capture(_ url: URL?) -> Bool {
        guard let url = url, url.absoluteString.contains(marker),
              let c = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let items = c.queryItems else { return false }
        var token: String? = nil, user: String? = nil
        for it in items { if it.name=="token" {token=it.value}; if it.name=="user" {user=it.value} }
        guard let t = token, t != "None", !t.isEmpty,
              let u = user, u != "None", !u.isEmpty else { return false }
        done = true
        let body = "USER=\(u)\nTOKEN=\(t)\n"
        if outPath.isEmpty { print(body, terminator:"") }
        else { try? body.write(toFile: outPath, atomically: true, encoding: .utf8) }
        NSApp.terminate(nil); return true
    }
    func webView(_ w: WKWebView, decidePolicyFor act: WKNavigationAction,
                 decisionHandler h: @escaping (WKNavigationActionPolicy)->Void) {
        if capture(act.request.url) { h(.cancel) } else { h(.allow) } }
    func webView(_ w: WKWebView, didCommit n: WKNavigation!) { _ = capture(w.url) }
    func webView(_ w: WKWebView, didFinish n: WKNavigation!) { _ = capture(w.url) }
    func windowWillClose(_ n: Notification) { if !done { exit(3) } }
}
let app = NSApplication.shared; let c = Ctrl()
app.delegate = c; app.setActivationPolicy(.regular); app.run()
