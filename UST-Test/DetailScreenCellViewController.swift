//
//  DetailScreenCellViewController.swift
//  UST-Test
//
//  Created by Ajith Mohan on 15/10/24.
//

import UIKit

class DetailScreenCellViewController: UIViewController {

    var fetchData = IPAddressFetcher()
    
    @IBOutlet var lblHead: UILabel!
    @IBOutlet var lblDetails: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        self.navigationController?.isNavigationBarHidden = false
        
        lblHead.text = "Loading.."
        
        Task{
            self.lblHead.text =  try await fetchData.fetchPublicIP()
            let detailsData = try await fetchData.fetchIPDetails(for: self.lblHead.text?.trimmingCharacters(in: .whitespaces) ?? "")
            
            if detailsData != nil{
                self.lblDetails.text = "Area : \(detailsData?.city ?? ""),\(detailsData?.region ?? ""),\(detailsData?.country ?? "")\n\nCompany: \(detailsData?.org ?? "")\n\nCareer: \(detailsData?.hostname ?? "")"
            }
        }
        
    }
    
    
   
    

}
