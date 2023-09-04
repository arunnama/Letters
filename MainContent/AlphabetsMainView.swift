//
//  AlphabetsMainView.swift
//  Letters
//
//  Created by Arun Kumar Nama on 3/9/23.
//

import SwiftUI
import Dispatch

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

struct ContentView: View {
    @ObservedObject var alphabetViewModel = AlphabetViewModel()
    @State private var currentPage = 0
    @ObservedObject var ttsManager = TextToSpeechManager()
    @State private var isAutoScrolling = false // Track auto-scrolling state
    
    @StateObject var timerManager = TimerManager()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Alphabet Adventure")
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
                        timerManager.stopAutoScrolling() // Stop auto-scrolling
                        isAutoScrolling = false
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    .padding()
                    
                    Button(action: {
                        // Toggle auto-scrolling on play button
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
                            timerManager.stopAutoScrolling() // Stop auto-scrolling when paused
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
            .overlay(FloatingBubblesView(), alignment: .top) // Overlay bubbles
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
                AnimatedLetterView(letter: alphabets[index].letter) // Use AnimatedLetterView
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .onChange(of: currentPage) { newValue in
            // Speak the alphabet when currentPage changes
            ttsManager.speak(alphabets[newValue].letter)
        }
    }
}

struct AnimatedLetterView: View {
    let letter: String

    var body: some View {
        ZStack {
            Text(letter)
                .font(.custom("Comic Sans MS", size: 300)) // Increase the font size
                .foregroundColor(.blue)
                .scaleEffect(0.2) // Initial scale to 20%
                .opacity(0.2) // Initial opacity to 20%
                .animation(
                    Animation.easeInOut(duration: 0.5) // Customize the animation duration
                        .repeatCount(1, autoreverses: true) // Add a repeating bounce effect
                )
                .onAppear {
                    // Scale and fade in the letter with a funny animation
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

        // Add a scale-up animation when bubbleSize is large enough
        if bubbleSize >= 40 {
            withAnimation(Animation.easeInOut(duration: 0.5)) {
                bubbleSize = bubbleSize * 1.5
            }

            // Add a pop animation when bubbleSize reaches a certain threshold
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

@main
struct PageViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}



