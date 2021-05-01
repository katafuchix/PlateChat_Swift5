//
//  UtilManager.swift
//  matching
//
//  Created by k.katafuchi on 2017/03/19.
//  Copyright © 2018年 Re:Quest Co.,Ltd. All rights reserved.
//

import UIKit

class UtilManager {
    
    // UIViewからUIImageを生成
    public static func getUIImageFromUIView(_ myUIView:UIView) ->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(myUIView.frame.size, true, 0);//必要なサイズ確保
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.translateBy(x: -myUIView.frame.origin.x, y: -myUIView.frame.origin.y);
        myUIView.layer.render(in: context);
        let renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return renderedImage;
    }
    
    // 画像のリサイズ
    public static func getResizeImage(_ image:UIImage, resize:CGSize) -> UIImage {
        
        //UIGraphicsBeginImageContext(resize)
        UIGraphicsBeginImageContextWithOptions(resize, false, 0);
        image.draw(in: CGRect(x: 0, y: 0, width: resize.width, height: resize.height))
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizeImage!
    }
    
    /*
     画像を合成するクラスメソッド.
     */
    public static func ComposeUIImage(UIImageArray : [UIImage], width: CGFloat, height : CGFloat)->UIImage!{
        
        // 指定された画像の大きさのコンテキストを用意.
        //UIGraphicsBeginImageContext(CGSize(width:width, height:height))
        UIGraphicsBeginImageContextWithOptions(CGSize(width:width, height:height), false, 0);
        
        // UIImageのある分回す.
        for image : UIImage in UIImageArray {
            
            // コンテキストの中央に画像を描画する.
            image.draw(in: CGRect(x:(width-image.size.width)/2, y:(height-image.size.height)/2, width:image.size.width, height:image.size.height))
        }
        
        // コンテキストからUIImageを作る.
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // コンテキストを閉じる.
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // 日付の年で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func year(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(Calendar.Component.year, from: date)
    }
    
    // 日付の月で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func month(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.month, from: date)
    }
    
    // 日付の日で表される部分を整数型の値で返します
    // パラメータ
    //  date : 日付データ(NSDate型)を指定します
    //
    public static func day(date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.component(.day, from: date)
    }
    
    static func getAgeFromDate(_ date: Date) ->Int {
        return self.getAge(year(date: date), month(date:date), day(date:date))
    }
    
    // 年月日から年齢を求めるメソッド
    static func getAge(_ year:Int, _ month:Int, _ day:Int)->Int{
        let calendar = Calendar(identifier: .gregorian)
        let birthDate = DateComponents(calendar: calendar, year: year, month: month, day: day).date!
        let now = Date()
        let nowDate = DateComponents(calendar: calendar, year: UtilManager.year(date: now), month: UtilManager.month(date: now), day: UtilManager.day(date: now)).date!
        let age = calendar.dateComponents([.year], from: birthDate, to: nowDate).year!
        return age
    }
    
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        //formatter.calendar = gregorianCalendar
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    // ランダム
    public static func makeRandom(min: Int, max: Int) -> Int {
        let diff = max - min + 1
        let rdm = arc4random_uniform(UInt32(diff))
        return Int(rdm) + min
    }
    
    // trim
    public static func trim(_ str:String)->String {
        return str.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\t", with: "").replacingOccurrences(of: "\n", with: "")
    }
    
    /// クリップボードへのコピー
    public static func copyToClipboard(_ text: String) {
        UIPasteboard.general.setValue(text, forPasteboardType: "public.text")
    }

    public static func generateString(_ length: Int = 12) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
    }

    public static func getNowDateString() -> String {
        let now = Date() // 現在日時の取得

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP") // ロケールの設定
        dateFormatter.dateFormat = "yyyyMMdd_HH_mm_ss" // 日付フォーマットの設定
        return dateFormatter.string(from: now)
    }
}
