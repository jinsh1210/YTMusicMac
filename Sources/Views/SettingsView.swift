import SwiftUI

struct SettingsView: View {
    @AppStorage("floatingWidgetEnabled") private var floatingWidgetEnabled = true
    @AppStorage("floatingWidgetOnMinimize") private var floatingWidgetOnMinimize = true
    @AppStorage("floatingWidgetOnClose") private var floatingWidgetOnClose = true

    var body: some View {
        Form {
            Section("플로팅 위젯") {
                Toggle("플로팅 위젯 사용", isOn: $floatingWidgetEnabled)
                    .help("미니 플레이어 위젯을 화면 위에 항상 표시합니다")

                Toggle("최소화(Cmd+M) 시 위젯 표시", isOn: $floatingWidgetOnMinimize)
                    .disabled(!floatingWidgetEnabled)

                Toggle("창 닫기(Cmd+W) 시 위젯 표시 (백그라운드 재생)", isOn: $floatingWidgetOnClose)
                    .disabled(!floatingWidgetEnabled)
            }
        }
        .formStyle(.grouped)
        .frame(width: 400)
        .padding()
    }
}
