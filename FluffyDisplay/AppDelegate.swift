// -*- Mode: Swift; tab-width: 4; indent-tabs-mode: nil; c-basic-offset: 4; fill-column: 100 -*-

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    struct Resolution {
        let width, height, ppi: Int32
        let description: String
        init(_ width: Int32, _ height: Int32, _ ppi: Int32, _ description: String) {
            self.width = width
            self.height = height
            self.ppi = ppi
            self.description = description
        }
    }

    struct Display {
        let number: Int
        let display: Any
    }

    var displayCounter = 0
    var displays = [Int: Display]()

    let predefResolutions: [Resolution] = [
      // List from https://en.wikipedia.org/wiki/Graphics_display_resolution and
      // https://www.theverge.com/tldr/2016/3/21/11278192/apple-iphone-ipad-screen-sizes-pixels-density-so-many-choices

      // The ppi values for the generic resolutions are guesstimeted; the important point is that
      // 200 or more counts as "HiDPI" in createVirtualDisplay()
      Resolution(6016, 3384, 218, "Apple Pro Display XDR"),
      Resolution(5120, 2880, 218, "27-inch iMac with Retina 5K display"),
      Resolution(4096, 2304, 219, "21.5-inch iMac with Retina 4K display"),
      Resolution(3840, 2400, 200, "WQUXGA"),
      Resolution(3840, 2160, 200, "UHD"),
      Resolution(3840, 1600, 200, "WQHD+, UW-QHD+"),
      Resolution(3840, 1080, 200, "DFHD"),
      Resolution(3072, 1920, 226, "16-inch MacBook Pro with Retina display"),
      Resolution(2880, 1800, 220, "15.4-inch MacBook Pro with Retina display"),
      Resolution(2560, 1600, 227, "WQXGA, 13.3-inch MacBook Pro with Retina display"),
      Resolution(2560, 1440, 109, "27-inch Apple Thunderbolt display"),
      Resolution(2304, 1440, 226, "12-inch MacBook with Retina display"),
      Resolution(2048, 1536, 150, "QXGA"),
      Resolution(2048, 1152, 150, "QWXGA"),
      Resolution(1920, 1200, 150, "WUXGA"),
      Resolution(1600, 1200, 125, "UXGA"),
      Resolution(1920, 1080, 102, "HD, 21.5-inch iMac"),
      Resolution(1440, 900,  127, "WXGA+, 13.3-inch MacBook Air"),
      Resolution(1400, 1050, 125, "SXGA+"),
      Resolution(1366, 768,  135, "11.6-inch MacBook Air"),
      Resolution(1280, 1024, 100, "SXGA"),
      Resolution(1280, 800,  113, "13.3-inch MacBook Pro"),
    ]

    var statusBarItem: NSStatusItem!

    var deleteMenu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             button.image = NSImage(named: "Icon")
        }

        let menu = NSMenu()
        let newMenuItem = NSMenuItem(title: "New Virtual Display", action: nil, keyEquivalent: "")
        let newMenu = NSMenu()

        var i = 0
        for size in predefResolutions {
            let item = NSMenuItem(title: "\(size.width)×\(size.height) (\(size.description))", action: #selector(newDisplay(_:)), keyEquivalent: "")
            item.tag = i
            newMenu.addItem(item)
            i += 1
        }

        newMenuItem.submenu = newMenu
        menu.addItem(newMenuItem)

        let deleteMenuItem = NSMenuItem(title: "Delete Virtual Display", action: nil, keyEquivalent: "")
        deleteMenuItem.submenu = deleteMenu
        menu.addItem(deleteMenuItem)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FluffyDisplay", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusBarItem.menu = menu
    }
    
    @objc func newDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            if menuItem.tag >= 0 && menuItem.tag < predefResolutions.count {
                let resolution = predefResolutions[menuItem.tag]
                let name = "#\(displayCounter)"
                if let display = createVirtualDisplay(resolution.width, resolution.height, resolution.ppi, name) {
                    displays[displayCounter] = Display(number: displayCounter, display: display)
                    let deleteMenuItem = NSMenuItem(title: "\(name) (\(resolution.width)×\(resolution.height))", action: #selector(deleteDisplay(_:)), keyEquivalent: "")
                    deleteMenuItem.tag = displayCounter
                    deleteMenu.addItem(deleteMenuItem)
                    displayCounter += 1
                }
            }
        }
    }

    @objc func deleteDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            displays[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
        }
    }
}
