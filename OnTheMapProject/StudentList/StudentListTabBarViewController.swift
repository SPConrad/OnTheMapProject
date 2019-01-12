//
//  StudentListTabBarViewController.swift
//  OnTheMapProject
//
//  Created by Sean Conrad on 11/17/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//
//
//import UIKit
//
//class StudentListTabBarViewController: UITabBarController {
//    var students: [Student]!
//
//    var studentListVc: StudentListViewController?
//    var mapVc: MapViewController?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        students = [Student]()
//        // Do any additional setup after loading the view.
//    }
//
//    func getStudents()  {
//        print("get students")
//        ParseClient.sharedInstance().getStudentLocations(onSuccess: { (students) in
//            self.students = students
//        }, onFailure: { (error) in
//            print("error")
//        }, onComplete: {
//            print("on complete")
//        })
//    }
//
//    private func setup() {
//        studentListVc = self.viewControllers![0] as? StudentListViewController
//        mapVc = self.viewControllers![1] as? MapViewController
//    }
//
//    public func configure(_ studentView: StudentListViewType) {
//        setup()
//        switch studentView {
//        case .list:
//            print("list")
//        case .map:
//            print("map")
//        }
//    }
//
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        switch item.title {
//        case "Map":
//            print("Map")
//        case "List":
//            print("List")
//        default:
//            print("no-op")
//        }
//    }
//
//    func addNewLocation() {
//        if let addLocVc = UIStoryboard(name: "AddLocation", bundle: nil).instantiateViewController(withIdentifier: "AddLocation") as? AddLocationViewController {
//            self.present(addLocVc, animated: true, completion: nil)
//        } else {
//            print("Whoops")
//        }
//    }
//
//    func refresh() {
//
//    }
//
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//    }
//
//    enum StudentListViewType {
//        case list, map
//    }
//}
