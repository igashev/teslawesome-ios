//
//  TaskRetry.swift
//  Teslawsome
//
//  Created by Ivaylo Gashev on 11.10.22.
//

import Foundation

extension Task where Failure == Error {
    /// Retrying mechanism for a Task.
    /// - Parameters:
    ///   - priority: The priority of the task. Pass nil to use the priority from Task.currentPriority.
    ///   - maxRetryCount: How many times it has to retry before it succeeds.
    ///   - retryDelayInSeconds: How much time it has to wait before it executes the next attempt.
    ///   - retryIf: A condition on which to retry. Pass `nil` to retry on failure result.
    ///   - operation: An operation to run
    /// - Returns: Returns a result from the operation once it passes the condition.
    ///
    /// When `retryIf`is non-nil, this the operation will retry until the `retryIf` condition is met or when `maxRetryCount` is hit.
    /// When `retryIf`is nil, the operation will retry until it returns non-failure result.
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelayInSeconds: TimeInterval = 1,
        retryIf: ((Success) -> Bool)? = nil,
        operation: @Sendable @escaping () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            func sleep() async throws {
                let oneSecond = TimeInterval(1_000_000_000)
                let delay = UInt64(oneSecond * retryDelayInSeconds)
                try await Task<Never, Never>.sleep(nanoseconds: delay)
            }
            
            for _ in 0..<maxRetryCount {
                if let retryIf {
                    let result = try await operation()
                    if retryIf(result) {
                        try await sleep()
                    } else {
                        return result
                    }
                } else {
                    do {
                        return try await operation()
                    } catch {
                        try await sleep()
                    }
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
