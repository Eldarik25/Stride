//
//  Courses.swift
//  Courses
//
//  Created by Руслан on 02.08.2024.
//

import Foundation
import Alamofire
import SwiftyJSON
import UIKit

class Courses {
    
    func getMyCreateCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/my_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json[x]["days"].arrayValue.count
            let title = json[x]["title"].stringValue
            let price = json[x]["price"].intValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            let description = json[x]["desc"].stringValue
            let dataCreated = json[x]["created_at"].stringValue
            let authorName = json[x]["author"]["first_name"].stringValue
            let authorSurname = json[x]["author"]["last_name"].stringValue
            let authorID = json[x]["author"]["id"].intValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), id: id, description: description, dataCreated: dataCreated))
        }
        
        return courses

    }
    
    func getAllCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json["results"].arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json["results"][x]["days"].arrayValue.count
            let title = json["results"][x]["title"].stringValue
            let price = json["results"][x]["price"].intValue
            let id = json["results"][x]["id"].intValue
            let image = json["results"][x]["image"].stringValue
            let description = json["results"][x]["desc"].stringValue
            let dataCreated = json["results"][x]["created_at"].stringValue
            let authorName = json["results"][x]["author"]["first_name"].stringValue
            let authorSurname = json["results"][x]["author"]["last_name"].stringValue
            let authorID = json["results"][x]["author"]["id"].intValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: nil, id: id, description: description, dataCreated: dataCreated))
        }
        
        return courses
    }
    
    func getDaysInCourse(id: Int) async throws -> [CourseInfo] {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
        var days = [CourseInfo]()
        var modules = [Modules]()
        let daysCount = json["days"].arrayValue.count
        guard daysCount > 0 else {return [CourseInfo]()}
        
        for x in 0...daysCount - 1 {
            let idDay = json["days"][x]["id"].intValue
            let modulesCount = json["days"][x]["modules"].arrayValue.count
            
            for y in 0...modulesCount - 1 {
                let id = json["days"][x]["modules"][y]["id"].intValue
//                let text = json["days"][x]["modules"][y]["data"].stringValue
                let min = json["days"][x]["modules"][y]["time_to_pass"].intValue
                let title = json["days"][x]["modules"][y]["title"].stringValue
//                let image = json["days"][x]["modules"][y]["image"].stringValue
                let desc = json["days"][x]["modules"][y]["desc"].stringValue
                modules.append(Modules(text: nil, name: title, minutes: min, description: desc, id: id))
            }
            days.append(CourseInfo(day: idDay, modules: modules))
        }
        return days
    }
    
    
    func getCoursesByID(id: Int) async throws -> Course {
        let url = Constants.url + "api/v1/courses/\(id)/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        let daysCount = json["days"].arrayValue.count
        let title = json["title"].stringValue
        let price = json["price"].intValue
        let id = json["id"].intValue
        let image = json["image"].stringValue
        let description = json["desc"].stringValue
        let dataCreated = json["created_at"].stringValue
        let authorName = json["author"]["first_name"].stringValue
        let authorSurname = json["author"]["last_name"].stringValue
        let authorID = json["author"]["id"].intValue
        let course = Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)",idAuthor: authorID, price: price, imageURL: URL(string: image), id: id, description: description, dataCreated: dataCreated)
        return course
    }
    
    func saveInfoCourse(info: Course, method: HTTPMethod = .post) async throws -> Int {
        var url = Constants.url + "api/v1/courses/"
        if method == .patch {
            url += "\(info.id)/"
        }
        print(url)
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(info.imageURL!, withName: "image")
            multipartFormData.append(Data(info.nameCourse.utf8), withName: "title")
            multipartFormData.append(Data("\(info.price)".utf8), withName: "price")
            multipartFormData.append(Data(info.description.utf8), withName: "desc")
        }, to: url, method: method, headers: headers).serializingData().value
        let json = JSON(value)
        print(json)
        let idCourse = json["id"].intValue
        return idCourse
    }
    
    func buyCourse(id: Int) async throws  {
        let url = Constants.url + "api/v1/courses/\(id)/buy_course/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let data = AF.request(url, method: .post, headers: headers).serializingData()
        if await data.response.response?.statusCode != 201 {
            throw ErrorNetwork.runtimeError("Ошибка")
        }
    }
    
    func getBoughtCourses() async throws -> [Course] {
        let url = Constants.url + "api/v1/courses/my_bought_courses/"
        let headers: HTTPHeaders = ["Authorization": "Bearer \(User.info.token)"]
        let value = try await AF.request(url, headers: headers).serializingData().value
        let json = JSON(value)
        var courses = [Course]()
        
        let results = json.arrayValue
        guard results.isEmpty == false else {return []}
        
        for x in 0...results.count - 1 {
            let daysCount = json[x]["days"].arrayValue.count
            let title = json[x]["title"].stringValue
            let price = json[x]["price"].intValue
            let id = json[x]["id"].intValue
            let image = json[x]["image"].stringValue
            let description = json[x]["desc"].stringValue
            let dataCreated = json[x]["created_at"].stringValue
            let authorName = json[x]["author"]["first_name"].stringValue
            let authorSurname = json[x]["author"]["last_name"].stringValue
            let authorID = json[x]["author"]["id"].intValue
            courses.append(Course(daysCount: daysCount, nameCourse: title, nameAuthor: "\(authorName) \(authorSurname)", idAuthor: authorID, price: price, imageURL: URL(string: image), rating: nil, id: id, description: description, dataCreated: dataCreated))
        }
        print(courses)
        return courses
    }
    
    
}
