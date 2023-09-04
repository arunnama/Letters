import SwiftUI
import Dispatch
import AVFoundation


import SwiftUI

@main
struct KidsLearningApp: App {
    var body: some Scene {
        WindowGroup {
            StartupView()
        }
    }
}

struct StartupView: View {
    @State private var showContentView = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Kids Learning App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    VStack(spacing: 20) {
                        MenuItemView(title: "Numbers", image: "number.square.fill", color: Color.blue, showContentView: $showContentView)
                        MenuItemView(title: "Letters", image: "textformat.abc", color: Color.green, showContentView: $showContentView)
                        MenuItemView(title: "Words", image: "book.fill", color: Color.orange, showContentView: $showContentView)
                        MenuItemView(title: "Other Option 1", image: "star.fill", color: Color.purple, showContentView: $showContentView)
                        MenuItemView(title: "Other Option 2", image: "heart.fill", color: Color.red, showContentView: $showContentView)
                        // Add more menu items as needed
                    }
                    .padding()

                    Spacer()
                }
            }
            .background(
                NavigationLink("", destination: ContentView(), isActive: $showContentView)
                    .opacity(0)
                    .buttonStyle(PlainButtonStyle())
            )
        }
    }
}


struct MenuItemView: View {
    let title: String
    let image: String
    let color: Color
    @Binding var showContentView: Bool

    var body: some View {
        Button(action: {
            showContentView = true // Show the content view when a menu item is tapped
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(color)
                    .frame(height: 150)

                VStack {
                    Image(systemName: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)

                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}


class AlphabetViewModel: ObservableObject {
    @Published var alphabets: [AlphabetItem] = []

    init() {
        fetchAlphabets()
    }

    func fetchAlphabets() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/alphabets.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(AlphabetData.self, from: data)
                        DispatchQueue.main.async {
                            self.alphabets = decodedData.alphabets
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                } else if let error = error {
                    print("Error fetching JSON data: \(error)")
                }
            }.resume()
        }
    }
}

//@main
//struct KidsLearningApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

class TextToSpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }

    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
    }
}

class TimerManager: ObservableObject {
    @Published var timer: DispatchSourceTimer?

    func startAutoScrolling(withInterval interval: TimeInterval, onPageChange: @escaping () -> Void) {
        let newTimer = DispatchSource.makeTimerSource()
        newTimer.schedule(deadline: .now() + interval, repeating: interval)
        newTimer.setEventHandler { [weak self] in
            onPageChange()
        }
        newTimer.resume()
        timer = newTimer
    }

    func stopAutoScrolling() {
        timer?.cancel()
        timer = nil
    }
}

struct AlphabetData: Codable {
    let alphabets: [AlphabetItem]
}

struct AlphabetItem: Codable, Identifiable {
    let id = UUID()
    let letter: String
}

struct ContentView: View {
    @State private var currentPage = 0
    @ObservedObject var ttsManager = TextToSpeechManager()
    @State private var isAutoScrolling = false
    @StateObject var timerManager = TimerManager()
    @ObservedObject var alphabetViewModel = AlphabetViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Kids Learning App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                AlphabetPageView(currentPage: $currentPage, alphabets: alphabetViewModel.alphabets, ttsManager: ttsManager)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding()

                HStack {
                    Button(action: {
                        ttsManager.speak(alphabetViewModel.alphabets[currentPage].letter)
                    }) {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(isAutoScrolling ? .gray : .blue)
                            .disabled(isAutoScrolling)
                    }
                    .padding()

                    Button(action: {
                        ttsManager.stopSpeaking()
                        timerManager.stopAutoScrolling()
                        isAutoScrolling = false
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .padding()

                    Button(action: {
                        isAutoScrolling.toggle()
                        if isAutoScrolling {
                            timerManager.startAutoScrolling(withInterval: 1.0) {
                                if currentPage < alphabetViewModel.alphabets.count - 1 {
                                    currentPage += 1
                                } else {
                                    isAutoScrolling = false
                                }
                            }
                        } else {
                            timerManager.stopAutoScrolling()
                        }
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(isAutoScrolling ? .gray : .blue)
                            .disabled(isAutoScrolling)
                    }
                    .padding()
                }

                Spacer()
            }
            .animation(.default)
            .navigationBarTitle("", displayMode: .inline)
            .overlay(FloatingBubblesView(), alignment: .top)
        }
    }
}

struct AlphabetPageView: View {
    @Binding var currentPage: Int
    var alphabets: [AlphabetItem]
    var ttsManager: TextToSpeechManager

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(alphabets.indices, id: \.self) { index in
                AnimatedLetterView(letter: alphabets[index].letter)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: currentPage) { newValue in
            ttsManager.speak(alphabets[newValue].letter)
        }
    }
}

struct AnimatedLetterView: View {
    let letter: String

    var body: some View {
        ZStack {
            Text(letter)
                .font(.custom("Comic Sans MS", size: 300))
                .foregroundColor(.blue)
                .scaleEffect(1.0)
                .opacity(1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatCount(1, autoreverses: true)
                )
                .onAppear {
                    withAnimation(Animation.easeOut(duration: 1).repeatForever(autoreverses: true)) {
                        self.scaleEffect(1.0)
                        self.opacity(1.0)
                    }
                }
        }
    }
}

struct FloatingBubblesView: View {
    var body: some View {
        ZStack {
            ForEach(0..<20) { _ in
                BubbleView()
            }
        }
    }
}

struct BubbleView: View {
    @State private var xOffset: CGFloat = CGFloat.random(in: -50...UIScreen.main.bounds.width - 50)
    @State private var yOffset: CGFloat = CGFloat.random(in: -50...UIScreen.main.bounds.height - 50)
    @State private var opacity: Double = 0.5
    @State private var bubbleColor: Color = Color.random()
    @State private var bubbleSize: CGFloat = CGFloat.random(in: 20...60)
    @State private var bubbleSpeed: Double = Double.random(in: 4...8)

    var body: some View {
        Circle()
            .foregroundColor(bubbleColor)
            .opacity(opacity)
            .frame(width: bubbleSize, height: bubbleSize)
            .offset(x: xOffset, y: yOffset)
            .animation(Animation.linear(duration: bubbleSpeed).repeatForever(autoreverses: true))
            .onAppear {
                animateBubble()
            }
    }

    func animateBubble() {
        let randomXOffset = CGFloat.random(in: -50...UIScreen.main.bounds.width - 50)
        let randomYOffset = CGFloat.random(in: -50...UIScreen.main.bounds.height - 50)

        withAnimation(Animation.linear(duration: bubbleSpeed).repeatForever(autoreverses: true)) {
            xOffset = randomXOffset
            yOffset = randomYOffset
            opacity = 0.2
            bubbleColor = Color.random()
            bubbleSize = CGFloat.random(in: 20...60)
        }

        if bubbleSize >= 40 {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                bubbleSize = bubbleSize * 1.5
            }

            if bubbleSize >= 100 {
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    bubbleSize = 0
                }
            }
        }
    }
}

extension Color {
    static func random() -> Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(red: red, green: green, blue: blue)
    }
}

//@main
//struct KidsLearningApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

