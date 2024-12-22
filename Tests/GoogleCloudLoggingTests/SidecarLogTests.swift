import Testing
import Foundation
@testable import GoogleCloudLogging
@testable import Logging
import ServiceContextModule
import GoogleCloudServiceContext

@Suite struct SidecarLogTests {

    @Test func format() async throws {
        let log = await SidecarLog(
            date: Date(),
            level: .info,
            message: "Test",
            labels: [
                "key": "value",
            ],
            source: "logging.test",
            context: .topLevel,
            file: "test.swift",
            function: "testFormat",
            line: 32
        )

        let data = try log.outputData()

        let dictionaryUnwrapped = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let dictionary = try #require(dictionaryUnwrapped)

        #expect(dictionary["time"] as? String != nil)
        #expect(dictionary["severity"] as? String == "INFO")
        #expect(dictionary["message"] as? String == "Test")
        #expect(dictionary["logging.googleapis.com/labels"] as? [String: String] == ["key": "value", "logger": "logging.test"])
    }

    @Test func noSmoke() async throws {
        var context = ServiceContext.current ?? .topLevel
        context.trace = .init(id: 1, spanIDs: [2], isSampled: false)
        
        for level in Logger.Level.allCases {
            try await SidecarLog(
                date: Date(),
                level: level,
                message: "Test",
                labels: [
                    "key": "value",
                ],
                source: "logging.test",
                context: context,
                file: "test.swift",
                function: "testFormat",
                line: 32
            ).write()
        }
    }
}
