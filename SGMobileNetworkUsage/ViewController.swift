//
//  ViewController.swift
//  SGMobileNetworkUsage
//
//  Created by Rajkumar Murugesan on 16/8/20.
//  Copyright © 2020 Rajkumar M. All rights reserved.
//

import UIKit

struct MobileNetworkUsage: Codable {
    var result:result
}

struct result: Codable {
    var records: [records]
}

struct records: Codable {
    var volume_of_mobile_data: String
    var quarter: String
    var _id: Int
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cardTableView: UITableView!
    
    let yearBegin = 2008
    let yearEnd = 2019
    
    var pictures = [UIImage] ()
    var titles = [String]()
    var cards = [String]()
    var totalUsage = [String]()
    var yearArr = [String]()
    var dataVolumeArr = [String]()
    var quaterArr = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GetDataFromURL{
            self.GetMobileNetworkUsageData(dataVolumeArray: self.dataVolumeArr, quaterArray: self.quaterArr)
            self.cards.append(contentsOf: self.yearArr)
            self.cardTableView.reloadData()
        }
        
        cardTableView.delegate = self
        cardTableView.dataSource = self
    }
    
    func GetDataFromURL(completed: @escaping () -> () ) {
        let jsonURLString = "https://data.gov.sg/api/action/datastore_search?resource_id=a807b7ab-6cad-4aa6-87d0-e283a7353a0f&limit=100"
        
        guard let url = URL(string: jsonURLString) else { return }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, err) in
            
            if err == nil {
                guard let data = data else { return }
                
                do{
                    let usage = try JSONDecoder().decode(MobileNetworkUsage.self, from: data)
                     
                    for index in 0..<usage.result.records.count{
                        let volumeOfMobileData = usage.result.records[index].volume_of_mobile_data
                        let quater = usage.result.records[index].quarter
                        
                        self.dataVolumeArr.append(volumeOfMobileData)
                        self.quaterArr.append(quater)
                    }
                    
                    DispatchQueue.main.async {
                        completed()
                    }
                    
                }
                catch let jsonErr {
                    print("Error in Json Decoding:", jsonErr)
                }
            }
        }.resume()
    }
    
    func GetMobileNetworkUsageData(dataVolumeArray: Array<String>, quaterArray: Array<String>) {
        var year = 0, prevYear = yearBegin
        var totVolume:Double = 0.0
        var oldData:Double = 0.0
        var picture = "noSign.png"
        
        for index in  0..<quaterArray.count{
            let tempArr = quaterArray[index].components(separatedBy: "-")
            year = Int(tempArr[0]) ?? 0

            if(year >= yearBegin && year <= yearEnd){
                
                if(year == prevYear){
                    let data = Double(dataVolumeArray[index])
                    totVolume = totVolume + data!
                    if(oldData > data!){
                        picture = "decreaseSign.png";
                    }
                    oldData = data!
                }
                else if(year != prevYear){
                    // add one year usage data into the array
                    totalUsage.append(String(totVolume))
                    yearArr.append(String(prevYear))
                    pictures.append(UIImage(named: picture)!)
                    
                    // For Q1 from the 2nd item
                    totVolume = 0.0
                    let data = Double(dataVolumeArray[index])
                    totVolume = totVolume + data!
                    oldData = data!
                    picture = "noSign.png"
                }
                 
               prevYear = year
            }
            
        }
    }

    // To set the TableView row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cards.count
    }
    
    // Cells going to use
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cardCell", for: indexPath) as! CardCell
        
        cell.configure(picture: pictures[indexPath.row], title: cards[indexPath.row], description: totalUsage[indexPath.row])
        
        return cell
    }
}
