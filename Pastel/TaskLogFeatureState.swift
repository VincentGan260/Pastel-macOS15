// ---------------------------------------------------------------------------
//  Fork modification notice — full attribution in NOTICE (repo root).
//  Community fork of Pastel-macOS (by EEliberto, Apache-2.0) for macOS 15.
//  Modified 2026-09-14 by VincentGan260: removed macOS 26 Liquid Glass
//  APIs; replaced with native macOS 15 SwiftUI containers/controls.
// ---------------------------------------------------------------------------
import Observation
import SwiftUI

@MainActor
@Observable
final class TaskLogFeatureState {
    var manualAppID = ""
    var manualVersionID = ""
    var manualNoUpdate = false
    var manualLatestDownloadedPath: String?
    var manualLatestDownloadedJobID: String?
}

struct DownloadErrorIndicator: View {
    let message: String
    let requiresSignIn: Bool
    let retry: () -> Void
    let signIn: () -> Void
    @State private var isShowingError = false

    var body: some View {
        HStack(spacing: 4) {
            Button {
                isShowingError.toggle()
            } label: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .frame(width: requiresSignIn ? 30 : 58, height: 26)
                    .contentShape(Capsule())
            }
            .buttonStyle(StablePressButtonStyle())
            .background(.regularMaterial, in: Capsule())
            .accessibilityLabel(String(localized: "查看下载错误"))
            .help(message)
            .popover(isPresented: $isShowingError, arrowEdge: .trailing) {
                VStack(alignment: .leading, spacing: 14) {
                    Label(String(localized: "下载失败"), systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .symbolRenderingMode(.multicolor)

                    Text(message)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack {
                        Spacer()
                        if requiresSignIn {
                            Button(String(localized: "登录")) {
                                isShowingError = false
                                signIn()
                            }
                        }
                        Button(String(localized: "重试下载")) {
                            isShowingError = false
                            retry()
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .padding(16)
                .frame(width: 320)
            }

            if requiresSignIn {
                Button {
                    isShowingError = false
                    signIn()
                } label: {
                    Label(String(localized: "登录"), systemImage: "person.crop.circle")
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .frame(width: 62, height: 26)
                        .contentShape(Capsule())
                }
                .buttonStyle(StablePressButtonStyle())
                .foregroundStyle(Color.accentColor)
                .background(.regularMaterial, in: Capsule())
                .help(message)
            }
        }
    }
}
