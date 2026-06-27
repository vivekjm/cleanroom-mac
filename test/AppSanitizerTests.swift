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
            "size_kb": 1572864,
            "size": "1.5GB",
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

        let copied = AppState.appFacingSummaryTextForTesting(
            title: "Documents",
            activityMessage: "Documents found 1 item.",
            status: "Documents complete",
            items: [
                ReviewItem(
                    title: "app-image.zip",
                    detail: "cleanroom documents /Users/example/Documents/project/builds --limit 10",
                    size: "1.5GB",
                    badge: "Review",
                    path: "/Users/example/Documents/project/builds/app-image.zip"
                )
            ]
        )
        expect(copied.contains("/Users/example/Documents/project/builds/app-image.zip"), "copied details should include useful path")
        expect(!copied.contains("cleanroom documents"), "copied details should hide command text")

        let totalLabel = AppState.visibleReviewTotalLabelForTesting([
            ReviewItem(
                title: "app-image.zip",
                detail: "File in Documents. Review before deleting or moving.",
                size: "1.5GB",
                badge: "Review",
                path: "/Users/example/Documents/project/builds/app-image.zip",
                sizeKB: 1572864
            ),
            ReviewItem(
                title: "cache.bin",
                detail: "File in Documents. Review before deleting or moving.",
                size: "512MB",
                badge: "Review",
                path: "/Users/example/Documents/project/builds/cache.bin",
                sizeKB: 524288
            )
        ])
        expect(totalLabel == "2 items · 2.0GB listed", "visible review total should summarize listed file size")

        let folderItems = AppState.reviewItemsForTesting([[
            "name": "media-project",
            "kind": "directory",
            "path": "/Users/example/Documents/media-project",
            "size": "Open folder",
            "summary": "Folder size is checked only when you open a deeper review.",
            "review_command": "cleanroom documents /Users/example/Documents/media-project --limit 40"
        ]])
        expect(folderItems.first?.isFolder == true, "folder rows should be marked for in-app drill down")
        expect(folderItems.first?.path == "/Users/example/Documents/media-project", "folder drill down should preserve folder path")
        let folderAction = AppAction.folderReview(path: "/Users/example/Documents/media-project")
        expect(folderAction.title == "media-project", "folder review action should use the folder name")
        expect(folderAction.args == ["documents-fast", "/Users/example/Documents/media-project", "--limit", "40"], "folder review action should run a focused fast folder review")
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
