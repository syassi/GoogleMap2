//
//  ViewController.swift
//  MyMap
//
//  Created by Yasushi Saito on 2018/02/28.
//  Copyright © 2018年 SunQ. All rights reserved.
//

import UIKit
import GoogleMaps
//import MapKit

class ViewController: UIViewController , UITextFieldDelegate {
  
    private var locationManager: CLLocationManager!
    // 画面を動かした場合、更新したくないので、最初の1回に制御している
    private var initView: Bool = false
    // 検索用
    @IBOutlet weak var inputText: UITextField!
    // Googleマップ
    @IBOutlet weak var googleMap: GMSMapView!
    // MKMapView
    //@IBOuntlet weak appleMap: MKMapView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    // Text Fieldのdelegate通知先を設定
    inputText.delegate = self
    
    // 東京タワーを中心にして表示
    let camera = GMSCameraPosition.camera(withLatitude: 35.656773,                                                      longitude: 139.745460, zoom: 10)
    self.googleMap.camera = camera
    
    //青い点（現在地）表示
    self.googleMap.isMyLocationEnabled = true
    //現在地ボタン
    self.googleMap.settings.myLocationButton = true
    

    locationManager = CLLocationManager() // インスタンスの生成
    locationManager.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // キーボードを閉じる(1)
    textField.resignFirstResponder()
    
    // 入力された文字を取り出す(2)
    if let searchKey = textField.text {
      
      // 入力された文字をデバックエリアに表示(3)
      print(searchKey)
      
      // CLGeocoderインスタンスを取得(5)
      let geocoder = CLGeocoder()
      
      // 入力された文字から位置情報を取得(6)
      geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
        
        // 位置情報が存在する場合はunwarpPlacemarksに取り出す(7)
        if let unwarpPlacemarks = placemarks {
          
          // 1件目の情報を取り出す(8)
          if let firstPlacemark = unwarpPlacemarks.first {
            
            // 位置情報を取り出す(9)
            if let location = firstPlacemark.location {
              
              // 位置情報から緯度経度をtargetCoordinateに取り出す(10)
              let targetCoordinate = location.coordinate
              
              // 緯度経度をデバックエリアに表示(11)
              print(targetCoordinate)
                
                //ピンを立てる
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2DMake(targetCoordinate.latitude,targetCoordinate.longitude)
                marker.title = searchKey
                marker.map = self.googleMap
                
                //let pin = MKPointAnnotation()
                //pin.coordinate = targetCoordinate
                //pin.title = searchKey
                //self.appleMap.addAnnotation(pin)
                
              
                // 緯度経度を中心にして表示
                let camera = GMSCameraPosition.camera(withLatitude: targetCoordinate.latitude,                                                      longitude: targetCoordinate.longitude, zoom: 15)
                
                self.googleMap.camera = camera
                
                //self.appleMap.region = MKCoordinateRegionWithDistance(targetCoordinate, 500.0, 500.0)
                
                
                
                /*
                let eyeAltitude:CLLocationDistance = 200.0
                
                // 東京タワー
                let centerCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude:35.656660, longitude:139.745578)
        
                
                let mapCamera = MKMapCamera(lookingAtCenter: targetCoordinate, fromEyeCoordinate: centerCoordinate, eyeAltitude: eyeAltitude)
                
                self.dispMap.setCamera(mapCamera, animated: false)
                */
                
            }
          }
        }
      })
    }
    
    // デフォルト動作を行うのでtrueを返す(4)
    return true
  }
  
}

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !self.initView {
            // 初期描画時のマップ中心位置の移動
            let camera = GMSCameraPosition.camera(withTarget: (locations.last?.coordinate)!, zoom: 15)
            self.googleMap.camera = camera
            self.locationManager.stopUpdatingLocation()
            self.initView = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            // 許可を求めるコードを記述する（後述）
            locationManager.requestWhenInUseAuthorization() // 起動中のみの取得許可を求める
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            
            locationManager.startUpdatingLocation()
            
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            
            locationManager.startUpdatingLocation()
            
            break
        }
    }
}
