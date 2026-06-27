import Foundation

@main
struct AppSanitizerTests {
    static func main() {
        let input: [[String: Any]] = [[
            "name": "app-image.zip",
            "kind": "large file",
            "path": "/Users/example/Documents/project/builds/app-image.zip",
            "paths": "/Users/example/Documents/project/builds/app-image.zip",
            "review_command": "cleanroom documents /Users/example/Documents/project/builds --limit 10",
            "apply_command": "cleanroom clean --apply --trash --yes",
            "mode": "fast",
            "summary": "File in Documents. Review before deleting or moving."
        ]]

        let sanitized = AppState.appFacingItemsForTesting(input)
        guard let item = sanitized.first else {
            fail("sanitized item missing")
        }

        expect(item["path"] as? String == "/Users/example/Documents/project/builds/app-image.zip", "path should be preserved")
        expect(item["paths"] as? String == "/Users/example/Documents/project/builds/app-image.zip", "paths should be preserved")
        expect(item["review_command"] == nil, "review_command should be hidden")
        expect(item["apply_command"] == nil, "apply_command should be hidden")
        expect(item["mode"] == nil, "mode should be hidden")
        expect(item["location"] as? String == "In Documents", "location should be derived from path")
    }

    private static func expect(_ condition: Bool, _ message: String) {
        if !condition {
            fail(message)
        }
    }

    private static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data("AppSanitizerTests failed: \(message)\n".utf8))
        Foundation.exit(1)
    }
}
