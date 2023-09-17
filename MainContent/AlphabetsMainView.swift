

import SwiftUI
import Dispatch
import AVFoundation

enum DataSource {
    case local
    case network
}

struct NumberView: View {
    @ObservedObject var numberViewModel: NumberViewModel
    @State private var isTitleVisible = false // State for title animation
    
    init(dataSource: DataSource) {
            self.numberViewModel = NumberViewModel(dataSource: dataSource)
            // ...
    }
    
    var body: some View {
        NavigationView {
            Group { // Use Group to conditionally display either content or error
                if numberViewModel.error != nil {
                    ErrorView(message: "Error loading numbers. Please try again later.")
                } else {
                    ContentView(dataViewModel: numberViewModel, dataItems: numberViewModel.numbers) { numberItem in
                        AnimatedLetterView(letter: numberItem.description)
                            .font(.custom("Comic Sans MS", size: UIScreen.main.bounds.height * 0.7))
                            .foregroundColor(.blue)
                            .accessibilityLabel(Text("Number \(numberItem.number)"))
                    }
                }
            }
            .animation(.default)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ColorfulTitleBar(title: "Numbers")
                }
            }
        }
    }
}


struct ColorfulTitleBar: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(5)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
        }
    }
}

// Add colorful background animations here
enum MenuItem: CaseIterable {
    case numbers, letters, words // Add more options as needed

    var title: String {
        switch self {
        case .numbers: return "Numbers"
        case .letters: return "Letters"
        case .words: return "Words"
        }
    }

    static var allCases: [MenuItem] {
        return [.numbers, .letters, .words] // Add more cases if needed
    }
}

@main
struct KidsLearningApp: App {
    @State private var isSplashPresented = true
    @State private var selectedMenuItem: MenuItem? = nil
    private var dataSource: DataSource = .local // Choose the data source configuration here


    var body: some Scene {
        WindowGroup {
            ZStack {
                if isSplashPresented {
                    SplashView()
                        .onAppear {
                            // Simulate a delay for the splash screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isSplashPresented = false
                                }
                            }
                        }
                } else {
                    StartupView(selectedMenuItem: $selectedMenuItem, dataSource: dataSource)
                        .onAppear {
                            selectedMenuItem = nil // Reset selectedMenuItem when the view appears
                        }
                }
            }
        }
    }
}

struct SplashView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        ZStack {
            // Background gradient with animation
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue, .green, .yellow, .pink, .orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Your splash screen content here, such as a logo or animated graphic
            Image(systemName: "star.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.white)
                .scaleEffect(2.0)
                .rotationEffect(.degrees(rotationAngle)) // Apply rotation effect
                .animation(
                    Animation.linear(duration: 5) // Slow initial rotation (5 seconds)
                        .repeatForever(autoreverses: false) // Repeat indefinitely
                )
                .onAppear {
                    // Gradually increase the rotation angle
                    withAnimation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        self.rotationAngle += 360
                    }
                }
        }
    }
}


struct StartupView: View {
    @Binding var selectedMenuItem: MenuItem?
    let gradientColors: [Color] = [.purple, .blue, .green, .yellow, .pink, .orange]
    let dataSource: DataSource // Add the data source parameter here

    init(selectedMenuItem: Binding<MenuItem?>, dataSource: DataSource) {
        self._selectedMenuItem = selectedMenuItem
        self.dataSource = dataSource // Initialize the data source
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient with animation
                LinearGradient(
                    gradient: Gradient(colors: gradientColors),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    // Title with animation
                    Text("Kids Learning App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .scaleEffect(selectedMenuItem == nil ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6))

                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(MenuItem.allCases, id: \.self) { item in
                                MenuItemView(item: item) {
                                    selectedMenuItem = item
                                }
                                .onTapGesture {
                                    selectedMenuItem = item
                                }
                                .background(
                                    NavigationLink("", destination: getContentView(), isActive: Binding<Bool>(
                                        get: { selectedMenuItem == item },
                                        set: { if !$0 { selectedMenuItem = nil } }
                                    ))
                                    .opacity(0)
                                    .buttonStyle(PlainButtonStyle())
                                )
                            }
                        }
                        .padding()
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
            return AnyView(NumberView(dataSource: dataSource))
        case .letters:
            return AnyView(AlphabetView(dataSource: dataSource))
        case .words:
            return AnyView(WordView(dataSource: dataSource))
        default:
            return AnyView(EmptyView())
        }
    }

}


struct AlphabetView: View {
    @ObservedObject var alphabetViewModel: AlphabetViewModel
    @State private var isTitleVisible = false // State for title animation
    
    init(dataSource: DataSource) {
        self.alphabetViewModel = AlphabetViewModel(dataSource: dataSource)
    }
    
    var body: some View {
        NavigationView {
            Group { // Use Group for error handling
                if alphabetViewModel.error != nil {
                    ErrorView(message: "Error loading alphabets. Please try again later.")
                        .accessibilityLabel(Text("Error loading alphabets. Please try again later."))
                } else {
                    ContentView(dataViewModel: alphabetViewModel, dataItems: alphabetViewModel.alphabets) { alphabetItem in
                        AnimatedLetterView(letter: alphabetItem.letter)
                            .font(.custom("Comic Sans MS", size: UIScreen.main.bounds.height * 0.7))
                            .foregroundColor(.blue)
                            .accessibilityLabel(Text("Letter \(alphabetItem.letter)"))
                    }
                }
            }
            .animation(.default)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ColorfulTitleBar(title: "Alphabets")
                }
            }
        }
    }
}

class AlphabetViewModel: ObservableObject {
    @Published var alphabets: [AlphabetItem] = []
    @Published var error: Error?

    init(dataSource: DataSource) {
        if dataSource == .local {
            loadAlphabetsFromLocalJSON()
        } else {
            fetchAlphabets()
        }
    }

    func loadAlphabetsFromLocalJSON() {
        if let path = Bundle.main.path(forResource: "alphabets", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decodedData = try JSONDecoder().decode(AlphabetResponse.self, from: data)
                // Update the alphabets property on the main thread
                DispatchQueue.main.async {
                    self.alphabets = decodedData.alphabets
                }

            } catch {
                self.error = error
            }
        }
    }

    func fetchAlphabets() {
        if let url = URL(string: AppConstants.baseURL + AppConstants.apiEndpoint + "/alphabets.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(AlphabetResponse.self, from: data)
                        DispatchQueue.main.async {
                            self.alphabets = decodedData.alphabets
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.error = error
                        }
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }.resume()
        }
    }
}

struct AlphabetItem: ContentProtocol, Identifiable {
    let id = UUID()
    let letter: String

    var description: String {
        return letter
    }
}

struct AlphabetResponse: Codable {
    let alphabets: [AlphabetItem]
}

struct WordView: View {
    @ObservedObject var wordViewModel: WordViewModel

        
    init(dataSource: DataSource) {
        self.wordViewModel = WordViewModel(dataSource: dataSource)
    }

    
    var body: some View {
        NavigationView {
            Group { // Use Group for error handling
                if wordViewModel.error != nil {
                    Text("Error loading words. Please try again later.")
                        .accessibilityLabel(Text("Error loading words. Please try again later."))
                } else {
                    ContentView(dataViewModel: wordViewModel, dataItems: wordViewModel.words) { wordItem in
                        WordCardView(wordItem: wordItem)
                    }
                }
            }
            .animation(.default)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ColorfulTitleBar(title: "Words")
                }
            }
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
        //        case .other1: return .purple
        //        case .other2: return .red
        }
    }

    var imageName: String {
        switch self {
        case .numbers: return "number.square.fill"
        case .letters: return "textformat.abc"
        case .words: return "book.fill"
        //        case .other1: return "star.fill"
        //        case .other2: return "heart.fill"
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
    @Published var error: Error?
    
    init(dataSource: DataSource) {
        if dataSource == .local {
            loadNumbersFromLocalJSON()
        } else {
            fetchNumbers()
        }
    }
    
    func loadNumbersFromLocalJSON() {
        if let path = Bundle.main.path(forResource: "numbers", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decodedData = try JSONDecoder().decode(NumberResponse.self, from: data)
                self.numbers = decodedData.numbers.map { number in
                    NumberItem(number: number)
                }
            } catch {
                self.error = error
            }
        }
    }
    
    
    func fetchNumbers() {
        if let url = URL(string: AppConstants.baseURL + AppConstants.apiEndpoint + "/numbers.json") {
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
                        DispatchQueue.main.async {
                            self.error = error
                        }
                        // Set the error property on failure
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    } // Set the error property on network error
                }
            }.resume()
        }
    }
}

struct WordCardView: View {
    let wordItem: WordItem

    var body: some View {
        VStack {
            Text(wordItem.letter)
                .font(.system(size: 48)) // Increase text size
                .foregroundColor(.purple) // Use a bright color (purple in this example)
                .padding(.top, 20)

            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(wordItem.words, id: \.self) { word in
                        WordCard(word: word)
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(Color(red: 255/255, green: 223/255, blue: 186/255)) // Child-friendly background color
                .shadow(radius: 5)
                .padding()
        )
        .frame(maxWidth: .infinity)
        .padding()
        .background( // Add a gradient background
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .green]), // Use colorful gradient colors
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.8) // Adjust opacity
            .cornerRadius(20)
        )
        .animation(.spring()) // Add animation
    }
}

struct WordCard: View {
    let word: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.white)
                .shadow(radius: 5)
                .frame(height: 100)
            
            Text(word)
                .font(.title)
                .foregroundColor(.orange) // Use a bright color (orange in this example)
        }
    }
}



struct AlphabetData: Codable {
    let alphabets: [AlphabetItem]
}

struct WordItem: ContentProtocol, Identifiable {
    let id = UUID()
    let letter: String
    let words: [String]

    var description: String {
        return "\(letter): \(words.joined(separator: ", "))"
    }
}

struct WordResponse: Codable {
    let words: [String: [String]]
}

class WordViewModel: ObservableObject {
    @Published var words: [WordItem] = []
    @Published var error: Error?

    init(dataSource: DataSource) {
        if dataSource == .local {
            loadWordsFromLocalJSON()
        } else {
            fetchWords()
        }
    }
    
    func loadWordsFromLocalJSON() {
        if let path = Bundle.main.path(forResource: "words", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let decodedData = try JSONDecoder().decode(WordResponse.self, from: data)
                
                var wordItems: [WordItem] = []

                for (letter, words) in decodedData.words {
                    wordItems.append(WordItem(letter: letter, words: words))
                }

                // Sort the wordItems by letter to maintain order
                wordItems.sort { $0.letter < $1.letter }

                DispatchQueue.main.async {
                    self.words = wordItems
                }

            } catch {
                self.error = error
            }
        }
    }

    func fetchWords() {
        if let url = URL(string: AppConstants.baseURL + AppConstants.apiEndpoint + "/words.json") {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode(WordResponse.self, from: data)
                        var wordItems: [WordItem] = []

                        for (letter, words) in decodedData.words {
                            wordItems.append(WordItem(letter: letter, words: words))
                        }

                        // Sort the wordItems by letter to maintain order
                        wordItems.sort { $0.letter < $1.letter }

                        DispatchQueue.main.async {
                            self.words = wordItems
                        }
                    } catch {
                        DispatchQueue.main.async {
                            self.error = error
                        } // Set the error property on failure
                    }
                } else if let error = error {
                    DispatchQueue.main.async {
                        self.error = error
                    } // Set the error property on network error
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
                dataItemViewBuilder(dataItems[index])
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
    @State private var bubbleSize: CGFloat = CGFloat.random(in: 20...100)

    var body: some View {
        Circle()
            .frame(width: bubbleSize, height: bubbleSize)
            .foregroundColor(bubbleColor)
            .opacity(opacity)
            .position(x: xOffset, y: yOffset)
            .animation(
                Animation.linear(duration: Double.random(in: 5...20))
                    .repeatForever(autoreverses: false)
            )
            .onAppear {
                // Randomize initial position
                xOffset = CGFloat.random(in: -50...UIScreen.main.bounds.width - 50)
                yOffset = CGFloat.random(in: -50...UIScreen.main.bounds.height - 50)
            }
    }
}

struct ErrorView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
            .padding()
    }
}

extension Color {
    static func random() -> Color {
        return Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}

struct AppConstants {
    static let baseURL = "https://raw.githubusercontent.com"
    static let apiEndpoint = "/arunnama/traindemo2/main"
}
