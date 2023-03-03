//
//  damusApp.swift
//  damus
//
//  Created by William Casarin on 2022-04-01.
//

import SwiftUI


@main
struct damusApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @State var needs_setup = false;
//    @State var keypair: Keypair? = nil;
    @State var currentUserDid: String? = nil;

    var body: some View {
        Group {
            if let did = currentUserDid, !needs_setup {
                ContentView(keypair: Keypair(pubkey: "npub13gylqvxmy7wqhxc8m4nu6d5kpxswvhlg233ftruvncsg8th36fmsgu7nvk", privkey: "nsec1tkl594j5clqe0ugh0lcgw44sg9z47m562xyg0wtvw36ukz0es7dq0434t4"), currentUserDid: did)
            } else {
                SetupView()
                    .onReceive(handle_notify(.login)) { notif in
                        print("1 ---------------------> \(notif)")
                        needs_setup = false
                        currentUserDid = get_saved_CurrentDid()
                    }
            }
        }
        .onReceive(handle_notify(.logout)) { _ in
            print("2 ---------------------> ")
            try? clear_keypair()
            currentUserDid = nil
        }
        .onAppear {
            print("3 ---------------------> ")
            _ = isAppAlreadyLaunchedOnce()
            currentUserDid = get_saved_CurrentDid()
        }
    }
}

func isAppAlreadyLaunchedOnce() -> Bool {
    let defaults = UserDefaults.standard
    if let _ = defaults.string(forKey:"isAppAlreadyLaunchedOnce") {
        print("App already launched")
        return true
    } else {
        let d = DamusIdentity.shared()
        d.launchedOnce()
        defaults.set(true, forKey:"isAppAlreadyLaunchedOnce")
        print("App launched first time")
        return false
    }
}

func needs_setup() -> String? {
    print("needs_setup ===== \(needs_setup)")
    return get_saved_CurrentDid()
}
    
//func needs_setup() -> Keypair? {
//    return get_saved_keypair()
//}

