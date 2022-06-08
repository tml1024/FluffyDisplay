// -*- Mode: Swift; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import CoreGraphics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NetServiceDelegate, NetServiceBrowserDelegate {

    struct Resolution {
        let width, height, ppi: Int32
        let hiDPI: Bool
        let description: String
        init(_ width: Int32, _ height: Int32, _ ppi: Int32, _ hiDPI: Bool, _ description: String) {
            self.width = width
            self.height = height
            self.ppi = ppi
            self.hiDPI = hiDPI
            self.description = description
        }
        init(_ width: Int, _ height: Int, _ ppi: Int, _ hiDPI: Bool, _ description: String) {
            self.init(Int32(width), Int32(height), Int32(ppi), hiDPI, description)
        }
    }

    let predefResolutions: [Resolution] = [
      // List from https://en.wikipedia.org/wiki/Graphics_display_resolution and
      // https://www.theverge.com/tldr/2016/3/21/11278192/apple-iphone-ipad-screen-sizes-pixels-density-so-many-choices

      Resolution(6016, 3384, 218, true,  "Apple Pro Display XDR"),
      Resolution(5120, 2880, 218, true,  "27-inch iMac with Retina 5K display"),
      Resolution(4096, 2304, 219, true,  "21.5-inch iMac with Retina 4K display"),
      Resolution(3840, 2400, 200, true,  "WQUXGA"),
      Resolution(3840, 2160, 200, true,  "UHD"),
      Resolution(3840, 1600, 200, true,  "WQHD+, UW-QHD+"),
      Resolution(3840, 1080, 200, true,  "DFHD"),
      Resolution(3072, 1920, 226, true,  "16-inch MacBook Pro with Retina display"),
      Resolution(2880, 1800, 220, true,  "15.4-inch MacBook Pro with Retina display"),
      Resolution(2560, 1600, 227, true,  "WQXGA, 13.3-inch MacBook Pro with Retina display"),
      Resolution(2560, 1440, 109, false, "27-inch Apple Thunderbolt display"),
      Resolution(2304, 1440, 226, true,  "12-inch MacBook with Retina display"),
      Resolution(2048, 1536, 150, false, "QXGA"),
      Resolution(2048, 1152, 150, false, "QWXGA"),
      Resolution(1920, 1200, 150, false, "WUXGA"),
      Resolution(1600, 1200, 125, false, "UXGA"),
      Resolution(1920, 1080, 102, false, "HD, 21.5-inch iMac"),
      Resolution(1680, 1050, 99,  false, "WSXGA+, Apple Cinema Display (20-inch), 20-inch iMac"),
      Resolution(1440, 900,  127, false, "WXGA+, 13.3-inch MacBook Air"),
      Resolution(1400, 1050, 125, false, "SXGA+"),
      Resolution(1366, 768,  135, false, "11.6-inch MacBook Air"),
      Resolution(1280, 1024, 100, false, "SXGA"),
      Resolution(1280, 800,  113, false, "13.3-inch MacBook Pro"),
    ]

    var activeDisplays = [Resolution]()

    // Represents one local virtual display
    struct VirtualDisplay {
        let number: Int
        let display: Any
    }

    var virtualDisplayCounter = 0
    var virtualDisplays = [Int: VirtualDisplay]()

    // Represents one (real) display on a peer running FluffyDisplay
    struct PeerDisplay {
        let number: Int
        let peer: String
        let resolution: Resolution
    }
    var peerDisplayCounter = 0
    var peerDisplays = [Int: PeerDisplay]()

    var statusBarItem: NSStatusItem!

    let newSubmenu = NSMenuItem(title: "New", action: nil, keyEquivalent: "")

    let autoSubmenu = NSMenuItem(title: "New on peer", action: nil, keyEquivalent: "")
    let autoMenu = NSMenu()

    let deleteSubmenu = NSMenuItem(title: "Delete", action: nil, keyEquivalent: "")
    let deleteMenu = NSMenu()

    let ns = NetService(domain: "local.", type: "_fi-iki-tml-flfd._tcp", name: "\(Host.current().localizedName ?? "?")")
    let browser = NetServiceBrowser()
    let queue = DispatchQueue(label: "networkIO")

    var discoveredServices = [String: NetService]()

    let beingDebugged = amIBeingDebugged()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let maxDisplays: Int32 = 5
        var activeDisplayIDs = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))
        var activeDisplayCount: UInt32 = 0

        if CGGetActiveDisplayList(UInt32(maxDisplays), &activeDisplayIDs, &activeDisplayCount) == .success {
            for i in (0...UInt32(activeDisplayCount)-1) {

                // Just use the current mode of the display
                if let mode = CGDisplayCopyDisplayMode(activeDisplayIDs[Int(i)]) {
                    let size = CGDisplayScreenSize(activeDisplayIDs[Int(i)])
                    activeDisplays.append(Resolution(Int32(mode.pixelWidth), Int32(mode.pixelHeight),
                                                     Int32(CGFloat(mode.pixelWidth) / size.width * 25.4),
                                                     mode.pixelWidth > mode.width,
                                                     CGDisplayIsBuiltin(activeDisplayIDs[Int(i)]) != 0 ? "Built-in Display" : "Display #\(i)"))
                }
            }
        }

        ns.delegate = self
        ns.publish(options: [.listenForConnections])
        ns.startMonitoring()

        browser.includesPeerToPeer = true
        browser.delegate = self
        browser.searchForServices(ofType: "_fi-iki-tml-flfd._tcp", inDomain: "local.")

        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             button.image = NSImage(named: "Icon")
        }

        let menu = NSMenu()
        let newMenu = NSMenu()

        var i = 0
        for size in predefResolutions {
            let item = NSMenuItem(title: "\(size.width)×\(size.height) (\(size.description))", action: #selector(newDisplay(_:)), keyEquivalent: "")
            item.tag = i
            newMenu.addItem(item)
            i += 1
        }

        newSubmenu.submenu = newMenu
        menu.addItem(newSubmenu)

        autoSubmenu.submenu = autoMenu
        menu.addItem(autoSubmenu)

        deleteSubmenu.submenu = deleteMenu
        menu.addItem(deleteSubmenu)

        // When we start we haven't found any other Macs and we don't have anythung to delete.
        autoSubmenu.isHidden = true
        deleteSubmenu.isHidden = true

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FluffyDisplay", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }

    @objc func newDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            if menuItem.tag >= 0 && menuItem.tag < predefResolutions.count {
                let resolution = predefResolutions[menuItem.tag]
                let name = "FluffyDisplay Virtual Display #\(virtualDisplayCounter)"
                if let display = createVirtualDisplay(resolution.width,
                                                      resolution.height,
                                                      resolution.ppi,
                                                      resolution.hiDPI,
                                                      name) {
                    virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display)
                    let menuItem = NSMenuItem(title: "\(name) (\(resolution.width)×\(resolution.height))",
                                                    action: #selector(deleteDisplay(_:)),
                                                    keyEquivalent: "")
                    menuItem.tag = virtualDisplayCounter
                    deleteMenu.addItem(menuItem)
                    deleteSubmenu.isHidden = false

                    virtualDisplayCounter += 1

                    // If we have created a new virtual display, this FluffyDisplay clearly is the
                    // "main" Mac and no other Mac will use a physical display on this Mac. So we
                    // don't need to advertise our displays.
                    ns.setTXTRecord(nil)
                }
            }
        }
    }

    @objc func newAutoDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            if menuItem.tag >= 0 && menuItem.tag < peerDisplays.count {
                if let peerDisplay = peerDisplays[menuItem.tag],
                   let display = createVirtualDisplay(peerDisplay.resolution.width,
                                                      peerDisplay.resolution.height,
                                                      peerDisplay.resolution.ppi,
                                                      peerDisplay.resolution.hiDPI,
                                                      peerDisplay.resolution.description) {
                    virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display)
                    let menuItem = NSMenuItem(title: peerDisplay.resolution.description,
                                              action: #selector(deleteDisplay(_:)),
                                              keyEquivalent: "")
                    menuItem.tag = virtualDisplayCounter
                    deleteMenu.addItem(menuItem)
                    deleteSubmenu.isHidden = false

                    virtualDisplayCounter += 1

                    // Advertise that we want the other Mac to connect to our new virtual display
                    // with Screen Sharing.
                    advertiseRequestToConnect(from: peerDisplay.peer, on: ns)
                }
            }
        }
    }

    @objc func deleteDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            virtualDisplays[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
            // We can clear our TXT record now
            ns.setTXTRecord(nil)
            
            if deleteMenu.numberOfItems == 0 {
                deleteSubmenu.isHidden = true
            }
        }
    }

    func stringInDict(_ dict: [String: Data], _ key: String) -> String? {
        if let d = dict[key] {
           return String(data: d, encoding: .utf8)
        }
        return nil
    }

    func intInDict(_ dict: [String: Data], _ key: String) -> Int? {
        if let s = stringInDict(dict, key) {
            return Int(s)
        }
        return nil
    }

    static func amIBeingDebugged() -> Bool {
        var info = kinfo_proc()
        var mib : [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        assert(junk == 0, "sysctl failed")
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }

    func advertiseDisplays(on service: NetService) {
        var txtDict = [String: Data]()
        var i = 0
        txtDict["ndisplays"] = "\(activeDisplays.count)".data(using: .utf8)
        for display in activeDisplays {
            txtDict["width\(i)"] = "\(display.width)".data(using: .utf8)
            txtDict["height\(i)"] = "\(display.height)".data(using: .utf8)
            txtDict["ppi\(i)"] = "\(display.ppi)".data(using: .utf8)
            let hiDPI = display.hiDPI ? 1 : 0
            txtDict["hidpi\(i)"] = "\(hiDPI)".data(using: .utf8)
            txtDict["name\(i)"] = "\(display.description)".data(using: .utf8)
            i += 1
        }
        setTXTRecord(type: "displays", with: txtDict, on: service)
    }

    func advertiseRequestToConnect(from source: String, on service: NetService) {
        let txtDict = ["source": source.data(using: .utf8)!];
        setTXTRecord(type: "request", with: txtDict, on: service)
    }

    func setTXTRecord(type: String, with txtDict: [String: Data], on service: NetService) {
        var dict = txtDict
        dict["--type"] = type.data(using: .utf8)
        let txtData = NetService.data(fromTXTRecord: dict)
        if service.setTXTRecord(txtData) {
            debug("Set txtRecord \(txtDictAsString(dict))")
        } else {
            debug("Did not set txtRecord \(txtDictAsString(dict))")
        }
    }

    func txtDictAsString(_ txtDict: [String: Data]) -> String {
        var result = ""
        for key in txtDict.keys.sorted() {
            if result != "" {
                result += ","
            }
            result += key + "=" + String(decoding: txtDict[key]!, as: UTF8.self)
        }
        return result
    }

    func debug(_ string: String) {
        if beingDebugged || ProcessInfo.processInfo.environment["FLUFFYDISPLAY_DEBUG"] != nil {
            print(string)
        }
    }

    // NetServiceDelegate

    func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
        debug("Did not publish: \(sender), because: \(errorDict)")
    }

    func netServiceDidPublish(_ sender: NetService) {
        advertiseDisplays(on: sender)
        debug("Published: \(sender)")
    }

    func netService(_ sender: NetService, didUpdateTXTRecord data: Data) {
        debug("Got updated TXT record of: \(sender.name): \(data.count) bytes");

        if sender.name != ns.name {
            let dict = NetService.dictionary(fromTXTRecord: data)
            debug("\(txtDictAsString(dict))")

            if let type = stringInDict(dict, "--type") {
                switch type {
                case "displays":
                    if  let ndisplays = intInDict(dict, "ndisplays") {
                        debug("\(sender.name) has \(ndisplays) display(s)")

                        // Delete old menu entries for the peer's displays
                        for item in autoMenu.items {
                            if let match = item.title.range(of: "^.* on \(sender.name)",
                                                            options: .regularExpression) {
                                if (!match.isEmpty) {
                                    peerDisplays[item.tag] = nil
                                    autoMenu.removeItem(item)
                                }
                            }
                        }

                        // Add new menu entries for them
                        for i in 0...ndisplays-1 {
                            if let width = intInDict(dict, "width\(i)"),
                               let height = intInDict(dict, "height\(i)"),
                               let ppi = intInDict(dict, "ppi\(i)"),
                               let hiDPI = intInDict(dict, "hidpi\(i)"),
                               let name = stringInDict(dict, "name\(i)") {
                                let hiDPIString = hiDPI == 0 ? "" : " (Retina)"
                                let title = "\(name) on \(sender.name): \(width) x \(height)\(hiDPIString)"
                                let item = NSMenuItem(title: title, action: #selector(newAutoDisplay(_:)), keyEquivalent: "")
                                item.tag = peerDisplayCounter
                                peerDisplays[peerDisplayCounter] = PeerDisplay(number: peerDisplayCounter,
                                                                               peer: sender.name,
                                                                               resolution: Resolution(width, height, ppi, hiDPI != 0, title))
                                autoMenu.addItem(item)
                                autoSubmenu.isHidden = false
                                peerDisplayCounter += 1
                            }
                        }
                    }
                case "request":
                    if let source = stringInDict(dict, "source") {
                        if source == ns.name {
                            // We now know that this Mac is not the "main" one, so we have no need
                            // for the newSubmenu, autoSubmenu, or deleteSubmenu on this Mac.
                            newSubmenu.isHidden = true
                            autoSubmenu.isHidden = true
                            deleteSubmenu.isHidden = true

                            debug("Will open Screen Sharing to \(sender.name).\(sender.domain)")
                            let configuration = NSWorkspace.OpenConfiguration()
                            configuration.createsNewApplicationInstance = true

                            if let url = URL(string: "vnc://\(sender.name).\(sender.domain)") {
                                NSWorkspace.shared.open(url, configuration: configuration) { application, error in
                                    if error != nil {
                                        self.debug("Opening the URL \(url) failed: \(error!)");
                                    }
                                }
                            }
                        }
                    }
                default:
                    debug("Unhandled TXT record type \(type)")
                }
            }
        }
    }

    func netServiceDidStop(_ sender: NetService) {
        debug("Stopped: \(sender)")
    }

    func netService(_ sender: NetService, didAcceptConnectionWith inputStream: InputStream, outputStream: OutputStream) {
        debug("Accepted connection: \(sender)")
        inputStream.close()
    }

    // NetServiceBrowserDelegate

    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        debug("Did not search: \(errorDict)")
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if service.name != ns.name {
            debug("Found: \(service.name)")
            discoveredServices[service.name] = service;
            service.delegate = self
            service.startMonitoring()
        }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        if service.name != ns.name {
            debug("Removed: \(service.name)")
            if discoveredServices[service.name] != nil {
                discoveredServices[service.name] = nil
            }
            if let item = autoMenu.item(withTitle: service.name) {
                autoMenu.removeItem(item)
                if autoMenu.numberOfItems == 0 {
                    autoSubmenu.isHidden = true
                }
            }
        }
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        debug("Did stop: \(browser)")
    }

}
