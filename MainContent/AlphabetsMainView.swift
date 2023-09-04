import SwiftUI
import Dispatch
import AVFoundation

@main
struct KidsLearningApp: App {
    var body: some Scene {
        WindowGroup {
            StartupView(contentView: AlphabetView()) // For Numbers
        }
    }
}

struct StartupView<T: View>: View {
    @State private var selectedMenuItem: MenuItem? = nil
    let contentView: T

    enum MenuItem {
        case numbers, letters, words, other1, other2 // Add more options as needed
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Text("Kids Learning App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)

                    VStack(spacing: 20) {
                        MenuItemView(title: "Numbers", image: "number.square.fill", color: Color.blue) {
                            selectedMenuItem = .numbers
                        }
                        MenuItemView(title: "Letters", image: "textformat.abc", color: Color.green) {
                            selectedMenuItem = .letters
                        }
                        MenuItemView(title: "Words", image: "book.fill", color: Color.orange) {
                            selectedMenuItem = .words
                        }
                        MenuItemView(title: "Other Option 1", image: "star.fill", color: Color.purple) {
                            selectedMenuItem = .other1
                        }
                        MenuItemView(title: "Other Option 2", image: "heart.fill", color: Color.red) {
                            selectedMenuItem = .other2
                        }
                        // Add more menu items as needed
                    }
                    .padding()

                    Spacer()
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
            // You can replace this with your alphabet view
            return AnyView(AlphabetView())
        case .words:
            return AnyView(WordView())
        case .other1:
            // Replace this with your other content view
            return AnyView(Text("Other Option 1 View"))
        case .other2:
            // Replace this with your other content view
            return AnyView(Text("Other Option 2 View"))
        default:
            return AnyView(EmptyView())
        }
    }
}

struct MenuItemView: View {
    let title: String
    let image: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
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

class NumberViewModel: ObservableObject {
    @Published var numbers: [NumberItem] = []

    init() {
        fetchNumbers()
    }

    func fetchNumbers() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/numbers.json") { // Replace with the actual API URL for numbers
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([NumberItem].self, from: data)
                        DispatchQueue.main.async {
                            self.numbers = decodedData
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


protocol ContentProtocol: Codable, Identifiable {
    var description: String { get }
}




struct NumberItem: ContentProtocol {
    let id: UUID
    let number: Int
    
    var description: String {
        return number.description    // You can customize this as needed
    }
    
}

struct NumberView: View {
    @ObservedObject var numberViewModel = NumberViewModel()

    var body: some View {
        ContentView(dataViewModel: numberViewModel, dataItems: numberViewModel.numbers) { numberItem in
            Text(numberItem.number.description)
                .font(.largeTitle)
                .foregroundColor(.blue)
        }
    }
}


struct WordItem: ContentProtocol {
    let id: UUID
    let word: String
    
    var description: String {
        return word // You can customize this as needed
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


struct AlphabetView: View {
    @ObservedObject var alphabetViewModel = AlphabetViewModel()

    var body: some View {
        ContentView(dataViewModel: alphabetViewModel, dataItems: alphabetViewModel.alphabets) { alphabetItem in
            Text(alphabetItem.letter) // Use alphabetItem.letter here
                .font(.largeTitle)
                .foregroundColor(.blue)
        }
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
    }
}

class WordViewModel: ObservableObject {
    @Published var words: [WordItem] = []

    init() {
        fetchWords()
    }

    func fetchWords() {
        if let url = URL(string: "https://raw.githubusercontent.com/arunnama/traindemo2/main/words.json") { // Replace with the actual API URL for words
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
        NavigationView {
            VStack {
                Text("Kids Learning App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)

                DataPageView(currentPage: $currentPage, dataItems: dataItems, dataItemViewBuilder: dataItemViewBuilder, ttsManager: ttsManager)
                    .frame(height: UIScreen.main.bounds.height * 0.7)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(20)
                    .padding()

                HStack {
                    Button(action: {
                        if currentPage < dataItems.count {
                            
                            let id = dataItems[currentPage].id
                            
                            ttsManager.speak(dataItems[currentPage] as! String)
                            
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
            .navigationBarTitle("", displayMode: .inline)
            .overlay(FloatingBubblesView(), alignment: .top)
        }
    }
}


struct DataPageView<T: ContentProtocol, DataItemView: View>: View {
    @Binding var currentPage: Int
    let dataItems: [T] // Change this line to use an array [T] instead of ArraySlice<T>
    let dataItemViewBuilder: (T) -> DataItemView
    var ttsManager: TextToSpeechManager

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(dataItems.indices, id: \.self) { index in
                dataItemViewBuilder(dataItems[index])
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

