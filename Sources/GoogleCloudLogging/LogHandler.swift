import Logging
import Foundation
import ServiceContextModule
import GoogleCloudServiceContext

public struct GoogleCloudLogHandler: LogHandler {

    public let label: String

    public var metadata: Logger.Metadata = [:]
    public var metadataProvider: Logger.MetadataProvider?

    public var logLevel: Logger.Level

    public init(label: String, level: Logger.Level = .debug, metadata: Logger.Metadata = [:], metadataProvider: Logger.MetadataProvider? = nil) {
        self.label = label
        self.metadata = metadata
        self.logLevel = level
        self.metadataProvider = metadataProvider
    }

    public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { metadata[key] }
        set { metadata[key] = newValue }
    }

    public func log(level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, source: String, file: String, function: String, line: UInt) {
        let now = Date()

        var labels: [String: String] = [:]

        // Existing metdata
        labels.reserveCapacity(self.metadata.count)
        for (key, value) in self.metadata {
            labels[key] = value.description
        }

        // New metdata
        if let metadata = metadata {
            labels.reserveCapacity(metadata.count)
            for (key, value) in metadata {
                labels[key] = value.description
            }
        }
        if let metadataProvider = metadataProvider {
            let metadata = metadataProvider.get()
            labels.reserveCapacity(metadata.count)
            for (key, value) in metadata {
                labels[key] = value.description
            }
        }

        do {
            try SidecarLog(
                date: now,
                level: level,
                message: message,
                labels: labels,
                source: source,
                context: .current ?? .topLevel,
                file: file,
                function: function,
                line: line
            ).write()
        } catch {
            print("Error writing log: \(error)")
        }
    }
}
