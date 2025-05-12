//
//  PlayListViewModel.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/12.
//

import Foundation
import SwiftUI

class PlayListViewModel: ObservableObject {
    @Published var playList: [PlayList] = []
}

