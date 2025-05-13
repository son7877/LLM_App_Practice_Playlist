//
//  Logger.swift
//  LLMPractice
//
//  Created by 안홍범 on 2025/05/13.
//

import Foundation
import OSLog

enum LogLevel: String {
    case debug = "🔍"
    case info = "ℹ️"
    case warning = "⚠️"
    case error = "❌"
    case critical = "🔥"
}

final class Logger {
    static let shared = Logger()
    private let logger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.llmpractice", category: "App")
    
    private init() {}
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function): \(message)"
        
        switch level {
        case .debug:
            os_log(.debug, log: logger, "%{public}@", logMessage)
        case .info:
            os_log(.info, log: logger, "%{public}@", logMessage)
        case .warning:
            os_log(.default, log: logger, "%{public}@", logMessage)
        case .error:
            os_log(.error, log: logger, "%{public}@", logMessage)
        case .critical:
            os_log(.fault, log: logger, "%{public}@", logMessage)
        }
        
        #if DEBUG
        print(logMessage)
        #endif
    }
    
    // 편의 메서드들
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
    
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }
}

