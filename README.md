# PropFinder 🏢

A high-performance, programmatic iOS application built with modern Swift architectures, demonstrating production-grade techniques for local caching, efficient image downsampling, and automated unit testing.

---

## 🛠️ Tech Stack & Architecture

This project is built using **Clean MVVM-R (Model-View-ViewModel-Repository)** architecture to strictly separate presentation, business logic, and data storage layers.

- **UI Framework:** UIKit (100% Programmatic UI via AutoLayout)
- **Concurrency:** Swift Async/Await (`Task`, `MainActor`)
- **Local Persistence:** Core Data
- **Testing Engine:** XCTest
- **Image Pipeline:** CoreGraphics Custom Downsampling with `NSCache`

---

## 📐 Architecture Blueprint

[ View Layer ] (UIKit, Programmatic AutoLayout)
│  ▲
▼  │  (Data Binding via Closures/State Machine)
[ ViewModel Layer ] (Business Logic, State Management)
│
▼  (Protocol Boundaries)
[ Repository Layer ] (Data Source Orchestration: Core Data)


---

## 🚀 Key Technical Highlights & Enhancements

### 1. High-Performance Image Optimization
To mitigate out-of-memory (OOM) crashes typical in heavy asset listing applications, images are not loaded uncompressed. Instead, a custom **ImageLoader utility uses CoreGraphics downsampling** to scale raw image dimensions down to the exact `UIImageView` bounds *prior* to parsing the image buffer into active device RAM.

### 2. Thread-Safe Eviction Caching
Instead of standard Swift collection structures, in-memory image caching is backed by `NSCache`. This provides automatic system memory eviction under low-memory pressure scenarios and safe multi-threaded concurrency out of the box.

### 3. Memory Leak Safeguards
All asynchronous data and image loading pipelines explicitly capture context closures through `[weak self]` declarations. This structurally eliminates strong reference cycles and maintains zero object accumulation during high-speed list scrolling.

### 4. Pure Programmatic Layouts
By removing Storyboards completely, the app benefits from rapid app launch execution, cleaner git version control histories, and zero storyboard-related runtime crashes.

---

## 🧪 Automated Testing

The business logic layer is fully covered by decoupled unit tests. We mock out our abstraction boundaries using a programmatic test spy engine to evaluate the View Model's deterministic finite-state machine transitions (`.loading`, `.success`, `.error`).

### Run the Suite
- Open `PropFinder.xcodeproj`
- Execute the Test shortcut: `⌘ + U`

---

## ⚙️ Requirements & Installation

- **iOS Version:** 15.0+
- **Xcode Version:** 13.0+
- **Swift Version:** 5.5+

### Setup Instruction
1. Clone the repository:
   ```bash
   git clone [https://github.com/yourusername/PropFinder.git](https://github.com/yourusername/PropFinder.git)
Open the project container file in Xcode:

Bash
cd PropFinder && open PropFinder.xcodeproj
Press ⌘ + R to run on your preferred simulator target.
