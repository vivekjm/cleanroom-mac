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
        let backendInput: [[String: Any]] = [[
            "title": "Review mode",
            "summary": "Dry-run mode. Nothing changed.",
            "status": "review-only"
        ]]
        let backendSanitized = AppState.appFacingItemsForTesting(backendInput)
        expect(backendSanitized.first?["summary"] as? String == "This is only a review until you choose Clean Now.", "backend cleanup wording should be normalized")
        expect(backendSanitized.first?["status"] as? String == "Review only", "backend status tokens should be friendly")
        let commandHintItems = AppState.reviewItemsForTesting([[
            "name": "Old cache",
            "summary": "Cache files can be rebuilt.\nPreview with:\ncleanroom caches --json\nApply command: cleanroom clean --apply --trash --yes",
            "size": "800MB"
        ]])
        expect(commandHintItems.first?.detail.isEmpty == false, "desktop row details should keep useful human guidance")
        expect(commandHintItems.first?.detail.contains("cleanroom") == false, "desktop row details should not expose command text")
        expect(commandHintItems.first?.detail.contains("--json") == false, "desktop row details should not expose flags")

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
        expect(folderAction.reviewLimitForTesting() == 40, "folder review should expose its current limit")
        expect(folderAction.expandedReviewLimitForTesting().args == ["documents-fast", "/Users/example/Documents/media-project", "--limit", "120"], "show more should expand an existing review limit")
        let unboundedAction = AppAction(title: "Custom Review", args: ["documents-fast", "/Users/example/Documents/media-project"])
        expect(unboundedAction.expandedReviewLimitForTesting().args == ["documents-fast", "/Users/example/Documents/media-project", "--limit", "120"], "show more should add a useful limit when one is missing")
        expect(AppState.shouldOpenReviewDetailsForTesting(itemCount: 2, status: 0), "successful reviews with rows should open the file list")
        expect(!AppState.shouldOpenReviewDetailsForTesting(itemCount: 0, status: 0), "successful empty reviews should not force-open details")
        expect(AppState.shouldOpenReviewDetailsForTesting(itemCount: 0, status: 1), "failed reviews should open details")
        expect(AppAction.storageRecord.title == "Storage Record", "desktop storage history label should be plain language")
        expect(AppAction.safetyPolicy.title == "Protection Guide", "desktop safety label should be plain language")
        expect(AppState.postCleanupActivityMessageForTesting().contains("Run Analyze Storage"), "post-cleanup flow should not imply a hidden storage analysis")

        let home = "/Users/example"
        let documentFile = ReviewItem(
            title: "old-installer.zip",
            detail: "File in Documents. Review before deleting or moving.",
            size: "2.0GB",
            badge: "Review",
            path: "/Users/example/Documents/downloads/old-installer.zip",
            sizeKB: 2097152
        )
        expect(AppState.canMoveReviewItemToTrashForTesting(documentFile, homePath: home), "regular Documents files should be eligible for app-side Trash")
        let libraryFile = ReviewItem(
            title: "Login Data",
            detail: "Protected profile data.",
            size: "10MB",
            badge: "Protected",
            path: "/Users/example/Library/Application Support/Google/Chrome/Default/Login Data",
            sizeKB: 10240
        )
        expect(!AppState.canMoveReviewItemToTrashForTesting(libraryFile, homePath: home), "protected Library profile data should not be eligible for app-side Trash")
        let folderRow = ReviewItem(
            title: "media-project",
            detail: "Folder size is checked only when you open a deeper review.",
            size: "Open folder",
            badge: "Review",
            path: "/Users/example/Documents/media-project",
            isFolder: true
        )
        expect(!AppState.canMoveReviewItemToTrashForTesting(folderRow, homePath: home), "folders should use drill down instead of direct Trash")
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
