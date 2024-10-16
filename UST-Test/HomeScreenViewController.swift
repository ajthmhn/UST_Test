//
//  HomeScreenViewController.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import UIKit
import CoreData
import Network

class HomeScreenViewController: UIViewController, NetServiceBrowserDelegate, NetServiceDelegate {

    var devices: [Devices] = []
    var serviceBrowser: NetServiceBrowser!
    var discoveredServices: [NetService] = []
    var coreDataHelper = CoreDataHelper()
    
    @IBOutlet var tblList: UITableView!

       override func viewDidLoad() {
           super.viewDidLoad()
           
           Task {
               await loadDevicesFromCoreData()
           }
           
           DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
               self.startBrowsing()
           }
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "AirPlayDevices")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()
    
}

extension HomeScreenViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return devices.count
   }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.deviceCellId, for: indexPath) as! DeviceListCell
        let device = devices[indexPath.row]
        cell.lblName.text = device.name
        cell.lblDetails.text = device.ipAddress
        cell.lblStatus.text = device.status
        
       return cell
   }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: StryBrdIds.Details) as! DetailScreenCellViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension HomeScreenViewController{
    func startBrowsing() {
        serviceBrowser = NetServiceBrowser()
        serviceBrowser.delegate = self
        serviceBrowser.searchForServices(ofType: "_airplay._tcp", inDomain: "")
        
    }
  
 func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        service.delegate = self
        service.resolve(withTimeout: 5)
        discoveredServices.append(service)
    }
    
 func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print("Failed to resolve: \(sender), error: \(errorDict)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
             sender.resolve(withTimeout: 5)
         }
    }
    
 func netServiceDidResolveAddress(_ sender: NetService) {
        guard let ipAddress = resolveIPAddress(service: sender) else { return }
        
        Task {
            let status = await checkDeviceStatus(ipAddress: ipAddress)
            
            // Store device in CoreData
            await storeDeviceInCoreData(name: sender.name, ipAddress: ipAddress, status: status)
            
            // Reload table with updated devices
            await MainActor.run { [weak self] in
                Task {
                    await self?.loadDevicesFromCoreData()
                }
                
                if self?.devices.count == 0{
                    let label = UILabel()
                    label.text = "No devices available"
                    label.textAlignment = .center
                    label.textColor = UIColor.darkGray
                    label.sizeToFit()
                    label.frame = CGRect(x: (self?.tblList.frame.width)!/2, y: (self?.tblList.frame.height)!/2, width: (self?.tblList.frame.width)!, height: 50)

                    self?.tblList.backgroundView = label
                }else{
                    self?.tblList.backgroundView = nil
                }
                
                self?.tblList.reloadData()
            }
        }
    }
    
 func resolveIPAddress(service: NetService) -> String? {
        // Resolve IP Address from net service
        if let addresses = service.addresses {
            for address in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                let addressData = address as NSData
                if getnameinfo(addressData.bytes.assumingMemoryBound(to: sockaddr.self),
                               socklen_t(addressData.length),
                               &hostname, socklen_t(hostname.count),
                               nil, 0, NI_NUMERICHOST) == 0 {
                    return String(cString: hostname)
                }
            }
        }
        return nil
    }
    
    func checkDeviceStatus(ipAddress: String) async -> String {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "MonitorQueue")

        return await withCheckedContinuation { continuation in
            monitor.pathUpdateHandler = { path in
                let status: String
                if path.status == .satisfied {
                    status = "Reachable"
                } else {
                    status = "Un-Reachable"
                }
                
                // Cancel the monitor once we get the status update
                monitor.cancel()
                // Resume continuation with the status
                continuation.resume(returning: status)
            }
            
            // Start monitoring on the specified queue
            monitor.start(queue: queue)
        }
    }
    
    // Store device in CoreData
    func storeDeviceInCoreData(name: String, ipAddress: String, status: String) async {
        Task {
            try await coreDataHelper.addDevice(name: name, ipAddress: ipAddress, status: status)
        }
    }
    
    // Load devices from CoreData
     func loadDevicesFromCoreData() async {
         Task {
             self.devices = try await coreDataHelper.fetchAllDevices()
         }
    }
}
