//
//  ChildModel.swift
//  ParentDemo
//
//  Created by ahmed gado on 10/5/20.
//  Copyright © 2020 ahmed gado. All rights reserved.
//

import Foundation
struct ChildModel: Codable {
    let id: String
    let name: String?
    let email: String?
    let lat: Double?
    let lang: Double?
}
