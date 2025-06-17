# Blackjack-iOS

🃏 Project Overview: Blackjack-iOS (SwiftUI, Swift 6)

You’re starting fresh to build a clean, modular Blackjack app using SwiftUI on Mac M1, targeting iOS. You previously attempted this, but the split logic became complex. This time, we’re approaching it with smarter UI modeling and state management.

⸻

✅ Key Decisions & Design Patterns

🧠 Architecture
	•	Project name: Blackjack-iOS
	•	Using: Swift 6, SwiftUI, @Observable, Model-View separation
	•	Directory structure:

Blackjack-iOS/
├── Models/
├── Views/
├── ViewModels/
├── DevTools/   ← Dev Menu + Mock Data
├── Assets/
└── BlackjackApp.swift



⸻

🔧 Dev Menu Strategy

You want a robust Dev Menu to test every major game state in isolation, using mock data.

🌟 Key Use Cases in Dev Menu:
	1.	Initial Deal
	2.	Player Blackjack
	3.	Dealer Blackjack
	4.	Push (21 vs 21)
	5.	Player Bust
	6.	Dealer Draws & Busts
	7.	Dealer Wins
	8.	Push (equal score)

🔀 Split Flow (Cloning Card Positions)
	9.	Split Available
	10.	Split Chosen → Cards clone X/Y → Fan out
	11.	Split Hand 1 Playing
	12.	Split Hand 1 Stand
	13.	Split Hand 2 Playing
	14.	Split Hand 2 Stand
	15.	Split + Dealer Turn
	16.	Split End Game

🏁 End States
	17.	Player Wins
	18.	Dealer Wins
	19.	Push
	20.	Split Win

🎞 Animations / Visuals
	21.	Card Flip
	22.	Fan Slide-In
	23.	Spotlight
	24.	Split Expansion

🧪 Debug Tools
	25.	Reset UI
	26.	Toggle Face/Back
	27.	Manual Dealer Draw
	28.	Show GamePhase + Scores
	29.	Toggle Animation Speed

⸻

🧩 Split Logic Plan (Hardest Part)

You’re solving this with a smart technique called:

🔄 “Cloning Card Positions”

Copy the X/Y position of the original cards, overlay new fan stacks in the same position, animate them outward, and then begin split play.

Why?
	•	Prevents state explosion in ForEach
	•	Keeps animation clean
	•	Simplifies per-hand score tracking

⸻

🚀 What’s Next?

You’ll:
	•	Share old code snippets when we start each new feature
	•	Begin with DevScenario.swift and DevMenuView.swift
	•	Focus on mock-driven UI before real logic

The React version (Blackjack-React) will come later, so we’re designing everything in a modular, reusable way.

⸻

Let me know when you’re ready to build the first DevTools file — we’re all set!