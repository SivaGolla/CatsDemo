# Cats Demo using The Cat API - Swift MVVM Example

This project demonstrates how to use [The Cat API](https://thecatapi.com/) to display a list of cat images in an iOS application. The app is built using the MVVM (Model-View-ViewModel) architecture pattern in Swift.

## Approach
- Simple closure callbacks are used for bindings to avoid significant FRP dependencies like Combine or RxSwift
- Model-View-ViewModel (MVVM) architectural pattern is used that offers offers several advantages like Separation of Concerns, maintainability, scalability, reusavility and testability
- NSCache is used for better image caching mechanism and memory optimisation
 
## Features

- Fetch and display a list of cat images from The Cat API
- Lazy loading of images with caching
- Mark cat images as favorites
- Asynchronous image loading with URLSession
- Prefetching data for a smooth scrolling experience

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/SivaGolla/CatsDemo.git
    cd the-cat-api-swift-mvvm
    ```

2. Open the project in Xcode:
    ```sh
    open TheCatAPI.xcodeproj
    ```

3. Build and run the project on your preferred iOS simulator or device.

## Usage

1. **Model**: Defines the data structures and handles network requests.
    ```swift
    struct CatBreed: Decodable {
        let id: String
        let url: String
        var isFavorite: Bool = false
    }
    ```    

2. **ViewModel**: Manages the data for the views and handles business logic.
    ```swift
    class CatsViewModel {
        var itemsDidChange: (() -> Void)?
        var serviceDidFailed: ((NetworkError) -> Void)?
        
        var catModels: [ACatViewModel] = []
            
        func fetchAllCatsWithFavs() {
            - Fetch all cat breeds
            - Fetch my favourites if any
            - Generates the catModels of type [ACatViewModel]
        }
            
        func cancelImageLoad(at indexPath: IndexPath) {
            - Cancel the image download that is in progress
        }
        
        func toggleFavourite(favID: String?, catBreed: CatBreed, type: FavOpType) {
            - Marks a cat as favourite or unfavourite 
        }
    }
    
    class ACatViewModel {
        - View model for each cat cell
    }
    
    class ACatDetailViewModel {
        - View model for a cat detail page
    }
    ```

3. **View**: Displays the data and handles user interactions.
    ```swift
    class CatsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        @IBOutlet weak var tableView: UITableView!
        
        let viewModel = CatImageViewModel()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            configureView()
            bindViewModel()
            viewModel.fetchAllCatsWithFavs()
        }
    }
    
    extension CatsViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching {
        
        - numberOfRowsInSection
        - cellForRowAt:
        - willDisplay: forRowAt:
        - prefetchRowsAt
        - cancelPrefetchingForRowsAt
        - didSelectRowAt
    }
    
    extension CatsViewController: CatTableViewCellDelegate {
        func toggleFavButton(favID: String?, catBreed: CatBreed, type: FavOpType) {
            - toggle user selection
        }
    }
    
    class ACatDetailViewController {
      - Presents a cat' details like the country, description, temperament etc
    }
    ```

4. **Network Manager**
- Executes a given URLRequest using NSURLSession. A generic method to fetch data of any type that conforms to Codable.


## Limitations and Solutions

- The Cat API does not provide paging. Hence all cats are loaded lazily using prefetching technique

- The content remains relatively static and does not require regular updates. Therefore, there is no need to implement dynamic update features such as pull-to-refresh.

- A separate navigation service, such as a router or coordinator, is not implemented because the app consists of only two screens.

- API Key: To access the images, an API key is required and you can get it from the [TheCatAPI](https://thecatapi.com/).   

- Implementing offline functionality by caching the list of cat information can enhance user experience and enable offline access. However, it also introduces additional complexity to the app.

- Localization support is not implemented since all APIs return only English responses.

## Areas for Enhancement

- Introduce search functionality enabling users to find specific cat breeds.

- Implement cat filtering based on specified criteria.

- Improve the error handling by providing meaningful error messages to users.

- Implement my favourites page so that user can view all his / her favourite cats.

- Implement simple analytics using voting feature

## Acknowledgments

- [The Cat API](https://thecatapi.com/) for providing the cat images.
- [MVVM pattern](https://en.wikipedia.org/wiki/Model–view–viewmodel) for structuring the project.

