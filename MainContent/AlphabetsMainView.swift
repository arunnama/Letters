import SwiftUI
import Dispatch
import AVFoundation

enum MenuItem: CaseIterable {
    case numbers, letters, words, other1, other2 // Add more options as needed

    var title: String {
        switch self {
        case .numbers: return "Numbers"
        case .letters: return "Letters"
        case .words: return "Words"
        case .other1: return "Other Option 1"
        case .other2: return "Other Option 2"
        }
    }

    static var allCases: [MenuItem] {
        return [.numbers, .letters, .words, .other1, .other2] // Add more cases if needed
    }
}


@main
struct KidsLearningApp: App {
    @State private var selectedMenuItem: MenuItem? = nil

    var body: some Scene {
        WindowGroup {
            StartupView(selectedMenuItem: $selectedMenuItem)
                .onAppear {
                    selectedMenuItem = nil // Reset selectedMenuItem when the view appears
                }
        }
    }
}

struct StartupView: View {
    @Binding var selectedMenuItem: MenuItem?

    var body: some View {
        NavigationView {
            VStack {
                Text("Kids Learning App")
                    .font(.largeTitle)
                    .padding(.top, 20)
                ScrollView {
                    VStack {
                        VStack(spacing: 20) {
                            ForEach(MenuItem.allCases, id: \.self) { item in
                                MenuItemView(item: item) {
                                    selectedMenuItem = item
                                }
                            }
                        }
                        .padding()
                        
                        Spacer()
                    }
                }
            }
            .background(
                NavigationLink("", destination: getContentView(), isActive: Binding<Bool>(
                    get: { selectedMenuItem != nil },
                    set: { if !$0 { selectedMenuItem = nil } }
                ))
                .opacity(0)
                .buttonStyle(PlainButtonStyle())
            )
        }
    }

    func getContentView() -> some View {
        switch selectedMenuItem {
        case .numbers:
            return AnyView(NumberView())
        case .letters:
            return AnyView(AlphabetView())
        case .words:
            return AnyView(WordView())
        case .other1:
            return AnyView(Text("Other Option 1 View"))
        case .other2:
            return AnyView(Text("Other Option 2 View"))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct MenuItemView: View {
    let item: MenuItem
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(item.color)
                    .frame(height: 150)

                VStack {
                    Image(systemName: item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)

                    Text(item.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

extension MenuItem {
    var color: Color {
        switch self {
        case .numbers: return .blue
        case .letters: return .green
        case .words: return .orange
        case .other1: return .purple
        case .other2: return .red
        }
    }

    var imageName: String {
        switch self {
        case .numbers: return "number.square.fill"
        case .letters: return "textformat.abc"
        case .words: return "book.fill"
        case .other1: return "star.fill"
        case .other2: return "heart.fill"
        }
    }
}

protocol ContentProtocol: Codable, Identifiable {
    var description: String { get }
}

struct NumberItem: ContentProtocol {
    let id = UUID()
    let number: Int

    var description: String {
        return number.description // You can customize this as needed
    }
}

struct NumberResponse: Codable {
    let numbers: [Int]
}

class NumberViewModel: ObservableObject {
    @Published var numbers: [NumberItem] = []

    init() {
        fetchNumbers()
    }

    func fetchNumbers() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/numbers.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(NumberResponse.self, from: data)
                        // Update the numbers property on the main thread
                        DispatchQueue.main.async {
                            self.numbers = decodedData.numbers.map { number in
                                NumberItem(number: number)
                            }
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

struct NumberView: View {
    @ObservedObject var numberViewModel = NumberViewModel()

    var body: some View {
        ContentView(dataViewModel: numberViewModel, dataItems: numberViewModel.numbers) { numberItem in
            AnimatedLetterView(letter: numberItem.description)
                .font(.custom("Comic Sans MS", size: UIScreen.main.bounds.height * 0.7))
                .foregroundColor(.blue)
        }
        .navigationBarTitle("Numbers", displayMode: .large)
    }
}

struct AlphabetData: Codable {
    let alphabets: [AlphabetItem]
}

struct AlphabetItem: ContentProtocol {
    let id = UUID()
    let letter: String

    var description: String {
        return letter // You can customize this as needed
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

struct AlphabetView: View {
    @ObservedObject var alphabetViewModel = AlphabetViewModel()

    var body: some View {
        ContentView(dataViewModel: alphabetViewModel, dataItems: alphabetViewModel.alphabets) { alphabetItem in
            Text(alphabetItem.letter)
                .font(.largeTitle)
                .foregroundColor(.blue)
        }
        .navigationBarTitle("Alphabets", displayMode: .large)
    }
}

struct WordItem: ContentProtocol {
    let id: UUID
    let word: String

    var description: String {
        return word // You can customize this as needed
    }
}

struct WordView: View {
    @ObservedObject var wordViewModel = WordViewModel()

    var body: some View {
        ContentView(dataViewModel: wordViewModel, dataItems: wordViewModel.words) { wordItem in
            Text(wordItem.word)
                .font(.largeTitle)
                .foregroundColor(.green)
        }
        .navigationBarTitle("Words", displayMode: .large)
    }
}

class WordViewModel: ObservableObject {
    @Published var words: [WordItem] = []

    init() {
        fetchWords()
    }

    func fetchWords() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/words.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([WordItem].self, from: data)
                        DispatchQueue.main.async {
                            self.words = decodedData
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

struct ContentView<T: ContentProtocol, DataViewModel: ObservableObject, DataItemView: View>: View {
    @State private var currentPage = 0

    @ObservedObject var ttsManager = TextToSpeechManager()
    @State private var isAutoScrolling = false
    @StateObject var timerManager = TimerManager()
    @ObservedObject var dataViewModel: DataViewModel

    let dataItems: [T]
    let dataItemViewBuilder: (T) -> DataItemView

    init(dataViewModel: DataViewModel, dataItems: [T], @ViewBuilder dataItemView: @escaping (T) -> DataItemView) {
        self.dataViewModel = dataViewModel
        self.dataItems = dataItems
        self.dataItemViewBuilder = dataItemView
    }

    var body: some View {
        VStack {
            DataPageView(currentPage: $currentPage, dataItems: dataItems, dataItemViewBuilder: dataItemViewBuilder, ttsManager: ttsManager)
                .frame(height: UIScreen.main.bounds.height * 0.7)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .padding()

            HStack {
                Button(action: {
                    if currentPage < dataItems.count {
                        ttsManager.speak(dataItems[currentPage].description)
                    }
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
                            if currentPage < dataItems.count - 1 {
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
        .overlay(FloatingBubblesView(), alignment: .top)
    }
}

struct DataPageView<T: ContentProtocol, DataItemView: View>: View {
    @Binding var currentPage: Int
    let dataItems: [T]
    let dataItemViewBuilder: (T) -> DataItemView
    var ttsManager: TextToSpeechManager

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(dataItems.indices, id: \.self) { index in
                AnimatedLetterView(letter: dataItems[index].description)
                    .font(.custom("Comic Sans MS", size: UIScreen.main.bounds.height * 0.7))
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: currentPage) { newValue in
            ttsManager.speak(dataItems[currentPage].description)
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


