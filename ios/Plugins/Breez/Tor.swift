// Ref. https://github.com/iCepa/iCepa/blob/master/Extension/PacketTunnelProvider.swift
// Ref. https://github.com/iCepa/iCepa/blob/main/Shared/TorManager.swift 

import Foundation
import Flutter


class Tor : NSObject, FlutterPlugin {

    private var torThread: TorThread?;
    private var torController: TorController?;
    private var cookie: Data?;


    public static func register(with registrar: FlutterPluginRegistrar) {

	let TOR_CHANNEL  = "com.breez.client/tor"
	    let instance = Tor()
	    let channel = FlutterMethodChannel(name: TOR_CHANNEL, binaryMessenger: registrar.messenger())
	    registrar.addMethodCallDelegate(instance, channel: channel)

    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

	print("Tor.swift: handle")

	    guard (call.method == "startTorService") else {
		result(FlutterMethodNotImplemented);
		return;
	    }

	startTor(call: call, result: result)
    }


    func startTor(call: FlutterMethodCall, result: @escaping FlutterResult) {

	guard !(torThread?.isExecuting ?? false) else { return };
	print("Tor.swift: startTor: Starting tor.");

	let socksPort: UInt16	= 19150;
	let httpPort: UInt16	= 19151;
	let dnsPort: UInt16	= 19153;
	let controlPort: UInt16	= 19160;

	let configuration = TorConfiguration();
	configuration.cookieAuthentication =  true;
	configuration.options = [
	    "AutomapHostsOnResolve": "1",
	    "AvoidDiskWrites": "1",
	    "ClientOnly": "1",
	    "Log": "notice stdout",

	    // FIXME(nochiel) Robustness: If we set these to auto, Tor will ensure it finds an open port.
	    // We can then retrieve these open ports using TorController and pass them back to TorBloc as a result.
	    // "SocksPort": "auto",
	    // "ControlPort" : "auto",
	    // "HTTPTunnelPort" : "auto",
	    "SocksPort": "\(socksPort)",
	    "ControlPort" : "\(controlPort)",
	    "HTTPTunnelPort" : "\(httpPort)",
	    "DNSPort": "\(dnsPort)",
	]; configuration.cookieAuthentication = true;

	if let dataDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("tor", isDirectory: true) {
	    try? FileManager.default.removeItem(at: dataDirectory);
	    try? FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true);
	    guard FileManager.default.fileExists(atPath: dataDirectory.path) else {
		result(FlutterError(code: "FAIL",
			    message: "Breez could not create the Tor directory",
			    details: nil));
		return;
	    };
	    configuration.dataDirectory = dataDirectory;
	    // configuration.controlSocket = configuration.dataDirectory!.appendingPathComponent("control_port");
	};

	configuration.arguments = [
	    "--ignore-missing-torrc",
	    "--allow-missing-torrc",
	];


	if let cookieUrl = configuration.dataDirectory?.appendingPathComponent("control_auth_cookie") {
	    cookie = try? Data(contentsOf: cookieUrl);
	}

	torThread = TorThread(configuration: configuration);
	torThread?.start();
	print("Tor.swift: startTor: Starting tor thread.");

	DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                // do {
                // TODO(nochiel) TorInstallLoggingCallback using the breez logger?

                /*
                   self.torController = TorController(socketHost: "127.0.0.1", port: controlPort);	
                // self.torController = TorController(socketURL: configuration.controlSocket!);
                try self.torController?.connect();		// The operation couldn’t be completed. (Foundation._GenericObjCError error 0.) 

                guard let cookie = self.cookie else {
                result(FlutterError(code: "FAIL",
                    message: "Breez could not read the Tor cookie",
                    details: nil));
                    return;
                    };

            self.torController?.authenticate(with: cookie) { success, error in
                if let error = error {
                print("Tor.swift: torController.connect() failed to authenticate with cookie: \(error.localizedDescription)");
                }
            };
            print("Tor.swift: controller connected.");

            // TODO(nochiel) Robustness: set these to auto in the configuration and retrieve them 
            // from the controller after Tor has started.
            var observer: Any? = nil
            observer = controller?.addObserver(forCircuitEstablished: { (established) -> Void in
            guard established else { return }
            torController?.removeObserver(observer)

            controlAddress, socksAddress, httpAddress: String
            var infoKey = "net/listeners/control"
            var values = torController?.getInfoForKeys(infoKey)
            if(values.count >= 1) { 
            controlAddress = values[0]
            }

            infoKey = "net/listeners/socks"
            values = torController?.getInfoForKeys(infoKey)

            let config: NSMutableDictionary = [:]
            config["SOCKS"] = port
            config["Control"] = port
            config["HTTP"] = port

            })
                 */

            print("Tor.swift: returning config.");
            let config = [
                "SOCKS"	: "127.0.0.1:\(socksPort)",
                "Control"	: "127.0.0.1:\(controlPort)",
                "HTTP"	: "127.0.0.1:\(httpPort)",
            ];
            result(config);
            return;

            /*

               } catch let error as NSError {
               print("Tor.swift: error : \(error.localizedDescription)");
               result(FlutterError(code: "FAIL",
            message: "Breez could not start Tor: \(error.localizedDescription)",
            details: nil));

            }
             */
    }

    }

    func stop() {
        torController = nil;
        torThread = nil;
        cookie = nil;
    }

}
