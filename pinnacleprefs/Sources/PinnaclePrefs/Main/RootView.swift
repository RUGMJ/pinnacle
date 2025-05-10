import SwiftUI
import libroot
import Comet

struct SliderWithLabel: View {
    var label: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var valueFormat: String

    var body: some View {
        VStack {
            Text(label).multilineTextAlignment(.leading)
            HStack {
                Slider(value: $value, in: range, step: step) {
                    Text(label)
                }
                Text(String(format: valueFormat, value))
            }
        }
    }
}

struct RootView: View {
    @StateObject private var preferenceStorage = PreferenceStorage()
    
    var body: some View {
        Form {
            RespringButton()

            Section {
                Toggle("Enabled", isOn: $preferenceStorage.isEnabled)
                Toggle("Show App Labels", isOn: $preferenceStorage.showAppLabels)
            }

            Section {
                Toggle("Haptic Feedback", isOn: $preferenceStorage.hapticFeedback)
            }

            Section {
                Picker("Gesture Direction", selection: $preferenceStorage.activationGestureDirection) {
                    Text("Up").tag("up")
                    Text("Down").tag("down")
                    Text("Either").tag("both")
                }.pickerStyle(.segmented)

            } header: {
                Text("Gesture")
            }
            
            Section {
                Picker("Visual Indicator", selection: $preferenceStorage.indicator) {
                    Text("None").tag("none")
                    Text("Grabbers").tag("grabbers")
                    //Text("App Previews").tag("apps")
                }.pickerStyle(.segmented)

            } header: {
                Text("Indicator")
            }

            Section {
                SliderWithLabel(
                    label: "Fade Amount",
                    value: $preferenceStorage.fadeAmount,
                    range: 0...1,
                    step: 0.1,
                    valueFormat: "%.1f"
                )

                SliderWithLabel(
                    label: "Fade Duration",
                    value: $preferenceStorage.fadeDuration,
                    range: 0...2,
                    step: 0.1,
                    valueFormat: "%.1f"
                )

                SliderWithLabel(
                    label: "Icon Move Duration",
                    value: $preferenceStorage.iconMoveDuration,
                    range: 0...2,
                    step: 0.1,
                    valueFormat: "%.1f"
                )

                SliderWithLabel(
                    label: "Spring Damping",
                    value: $preferenceStorage.springDamping,
                    range: 0...2,
                    step: 0.1,
                    valueFormat: "%.1f"
                )

                SliderWithLabel(
                    label: "Spring Initial Velocity",
                    value: $preferenceStorage.springInitialVelocity,
                    range: 0...2,
                    step: 0.1,
                    valueFormat: "%.1f"
                )
            } header: {
                Text("Animation Settings")
            } footer: {
                Text("Spring Initial Velocity: Experiment default is 0\nSpring Damping: Experiment, 0.6 is similar to the original zenith\nIcon Move Duration: the amount of time it takes for icons to move (seconds)\nFade Duration: the amount of time it takes to fade / unfade (seconds)\nFade Amount: 0 - fully transparent, 1 - no fade")
            }

            Section {
                Button(action: {
                    try? FileManager.default.removeItem(atPath: jbRootPath("/var/mobile/Library/Pinnacle/stackData.plist"))
                }) {
                    Text("Reset Data")
                        .foregroundColor(.red)
                }
            } header: {
                Text("Danger")
            }

            Section {
                Link("Source Code", destination: URL(string: "https://github.com/RUGMJ/pinnacle")!)
                Link("Have an idea?", destination: URL(
                    string: "https://github.com/RUGMJ/pinnacle/issues/new?assignees=&labels=enhancement&projects=&template=feature_request.md&title=%5BFEAT%5D")!)
                Link("Found a bug?", destination: URL(
                    string: "https://github.com/RUGMJ/pinnacle/issues/new?assignees=&labels=bug&projects=&template=bug_report.md&title=%5BBUG%5D")!)
            } header: {
                Text("Links")
            }

            Section {
                Link("Janisbtw", destination: URL(string: "https://github.com/Janisbtw")!)
                Link("Nightwind", destination: URL(string: "https://twitter.com/NightwindDev")!)
                Link("Aka", destination: URL(string: "https://twitter.com/AKAExpress2")!)
            } header: {
                Text("Testers")
            }
        }
    }
}
