# 📱 <오픈 마켓> 시연 영상

> 야곰 아카데미 구성원들과 함께 관리하는 네트워킹 오픈 마켓 앱

https://user-images.githubusercontent.com/71127966/160681372-0a3d4836-56d9-432b-bc5d-a276e3177915.mov

<br>

# ✨ 핵심 키워드

- MVC 패턴
- URLSession
- HTTP 통신
- Codable
- 비동기 이미지 다운로드 및 UIImageView 할당
- NSCache
- 무한 스크롤
- UIRefreshControl
- UICollectionView
- ImagePicker
- 스토리보드, 오토레이아웃

<br>

# ⚙️ [STEP 3] 상품 등록 UI, 기능 구현

<details>
<summary><h3>1️⃣ ImagePicker, RefreshControl, Keyboard 구현</h3></summary>

|🖼️ ImagePicker 기능|♻️ RefreshControl 기능|↕️ Keyboard 대응|
|:-:|:-:|:-:|
|![ImagePicker 기능](https://user-images.githubusercontent.com/71127966/161112789-f8bd631e-8e3d-494f-8363-64cba1a3f7ab.gif)|![RefreshControl 기능](https://user-images.githubusercontent.com/71127966/161114708-f5193b2c-1084-418c-8ce4-fe66fd3cceb3.gif)|![Keyboard 대응](https://user-images.githubusercontent.com/71127966/161109574-bdd6c677-7df1-41b7-a56e-bccaa444f277.gif)|
|imagePicker Cell 을 클릭하면<br>사진첩에서 사진을 추가할 수 있습니다.<br>정방형으로 크롭이 가능합니다.<br>사진은 최대 5장까지 추가할 수 있습니다.|화면의 edge 를 당겨서(pulling)<br>새로고침(refresh) 할 수 있습니다.<br>상품등록에 성공하면 Modal 이 내려가고<br>화면이 새로고침되며 추가한 상품을 보여줍니다.|사용자가 textField/textView 를 터치하면<br>입력하는 데이터에 알맞은 키보드가 올라옵니다.<br>콘텐츠가 키보드에 의해 가려지면,<br>화면이 올라오며 대응합니다.|

</details>

<details>
<summary><h3>2️⃣ 사용자가 의도한 pull to refresh 와 코드를 통한 programmatic refresh 구별하기</h3></summary>

- [UIRefreshControl](https://developer.apple.com/documentation/uikit/uirefreshcontrol) 기능을 구현한 부분에서, 사용자가 의도적으로 `pull to refresh` 하는 경우와, `상품 등록`에 성공해서 그 상품을 보여주기 위해 `programmatic refresh` 하는 경우를 분기 처리하기 위해 `isRefreshing` 프로퍼티를 활용했습니다.
  - `isRefreshing` 프로퍼티가 `false` 라면 -> 상품 등록에 성공한 것이므로, 해당 상품이 정상적으로 등록된 걸 보여주기 위해, TableView 최상단으로 이동시킵니다. 

- DispatchQueue.main.async 가 아니라, `asyncAfter(deadline: .now() + 0.5)`를 사용한 이유는 따로 기술 블로그에 정리했습니다.
  - [[iOS] 당겨서 새로고침(Pull to Refresh) 상용앱처럼 구현하는 방법](https://bicycleforthemind.tistory.com/39)
  
```swift
// handleRefreshControl() 메서드 내부 로직 중에서, reloadData() 가 위치한 부분

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    self.tableView.reloadData() // refresh 가 시작되면, Main Thread 에서 reloadData() 메서드 호출
    if self.refreshControl?.isRefreshing == false {
        self.scrollToTop(animated: false) // 상품 등록에 성공한 경우, TableView 의 최상단으로 이동
    }
    self.refreshControl?.endRefreshing()
}
```

</details>

<details>
<summary><h3>3️⃣ escaping 클로저에서 self 를 강한 참조하지 않도록 [weak self] 사용</h3></summary>

- escaping 클로저에서 `self`를 사용하는 경우, 클로저의 범위(scope) 수명 동안에는 self 에 대한 `강한 참조`를 유지합니다.
  - self 또한 참조 타입인 클로저의 `Reference Count(이하 RC)`를 1 증가시킵니다. 이로써 `클로저`와 `self` 사이에는 `강한 순환 참조`가 발생합니다.
  - 클로저의 실행이 완료되면, 클로저가 들고 있던 self 에 대한 강한 참조가 해제되면서, `self` 의 RC 가 1 감소합니다.
  - 하지만, 서버에 요청한 API 에 대한 응답이 정상적으로 돌아오지 않는다면, 클로저와 self 사이의 `강한 순환 참조`가 해결되지 않아 `메모리 누수`가 발생할 수 있습니다.

- 강한 순환 참조를 방지하기 위해, 클로저에서 `[self weak]`를 선언해 self 의 RC 가 올라가지 않도록 했습니다.
  - 프로젝트 전체에서 `self`를 사용하는 escaping 클로저 전체에 [self weak] 를 사용했습니다.
  - 📃 참고 블로그 [You don’t (always) need [weak self]](https://velog.io/@haanwave/Article-You-dont-always-need-weak-self)
  
```swift
// handleRefreshControl() 메서드 로직 중, 새로운 데이터를 서버에 요청하는 부분

APIExecutor().execute(request) { [weak self] (result: Result<ProductsListPage, Error>) in
    // weak self 사용으로 인해 self 가 옵셔널이 되므로, 옵셔널 바인딩을 통해 클로저 시작 시, self 에 대한 임시 강한 참조 생성
    guard let self = self else { return }
    
    switch result {
    case .success(let productsListPage):
        // 임시 강한 참조가 걸린 self 를 옵셔널 체이닝 없이 사용
        self.currentPageNo = productsListPage.pageNo
        self.hasNextPage = productsListPage.hasNext
        // ...
```

</details>

<details>
<summary><h3>4️⃣ UITextView 위에 커스텀 placeholder 구현 (🥕 당근마켓 참고)</h3></summary>

- 유명 앱인 `당근마켓`의 상품 등록 화면에서 구현된 `UITextView placeholder` 를 그대로 구현해보고 싶었습니다.
  - UIKit 의 [UITextView](https://developer.apple.com/documentation/uikit/uitextview)에는 기본적인 `placeholder` 기능이 없으므로, 직접 구현해야 했습니다.

- placeholder 역할을 할 별도의 UITextView 를 생성하며, 특정 프로퍼티를 아래와 같이 변경했습니다.
  - ⭐ `isUserInteractionEnabled` -> 가장 중요한 부분입니다. placeholder 역할을 하는 UITextView 가 `사용자의 터치`를 받으면 안 되므로, [isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled) 프로퍼티를 false 로 바꿔, 터치를 무시하도록 만들었습니다.
  - `textColor` -> 텍스트 색상은 placeholder 특유의 회색을 표현하기 위해, [UIColor.placeholderText](https://developer.apple.com/documentation/uikit/uicolor/3173134-placeholdertext) 색상 적용했습니다.
  - `backgroundColor` -> 배경은 투명한 색상인 [UIColor.clear](https://developer.apple.com/documentation/uikit/uicolor/1621945-clear) 적용하여, 콘텐츠를 가리지 않도록 했습니다.
  - `isScrollEnabled` -> 스크롤 가능 여부를 나타내는 [isScrollEnabled](https://developer.apple.com/documentation/uikit/uiscrollview/1619395-isscrollenabled)를 false 로 만들어서, 오토레이아웃으로 넓이을 잡아줄 수 있도록 했습니다.
  
```swift
// 커스텀 placeholder 역할을 해줄 UITextView 생성

private var descriptionsTextViewPlaceholder: UITextView = {
    let textView = UITextView()
    textView.text = "브랜드, 사이즈, 색상, 소재 등 물품에 대한 자세한 정보를 작성하면 판매확률이 올라가요!"
    textView.textColor = .placeholderText // 디폴트로 정의된 placeholder 색상 적용
    textView.font = .preferredFont(forTextStyle: .body)
    textView.backgroundColor = .clear // 투명한 배경색을 적용
    textView.isUserInteractionEnabled = false // 사용자의 터치를 받지 못하도록 interaction 프로퍼티를 false 처리
    textView.isScrollEnabled = false // 스크롤이 불가능하게 만들어서 오토레이아웃으로 넓이 잡아줄 수 있도록 처리
    textView.translatesAutoresizingMaskIntoConstraints = false // 코드로 오토레이아웃을 적용할 것이므로, 해당 프로퍼티는 false 처리
    return textView
}()

// 아래 메서드는 viewDidLoad() 에서 호출

private func configureDescriptionTextView() {
    // 프로젝트 내의 모든 IBOutlet 에서 강제 추출(!) 대신, 안전한 옵셔널(?) 처리를 해줬기에, 옵셔널 바인딩 필요
    guard let descriptionsTextView = descriptionsTextView else { return }
    descriptionsTextView.addSubview(descriptionsTextViewPlaceholder) // 기존 UITextView 위에 addSubview
    NSLayoutConstraint.activate([
        // widthAnchor 를 잡아주지 않으면, text 가 화면을 벗어남
        descriptionsTextViewPlaceholder.widthAnchor.constraint(equalTo: descriptionsTextView.widthAnchor),
        descriptionsTextViewPlaceholder.leadingAnchor.constraint(equalTo: descriptionsTextView.leadingAnchor),
        descriptionsTextViewPlaceholder.trailingAnchor.constraint(equalTo: descriptionsTextView.trailingAnchor),
        descriptionsTextViewPlaceholder.topAnchor.constraint(equalTo: descriptionsTextView.topAnchor),
        descriptionsTextViewPlaceholder.bottomAnchor.constraint(equalTo: descriptionsTextView.bottomAnchor)
    ])
}
```

|🥕 당근마켓 placeholder|모방한 placeholder 모습|
|:-:|:-:|
|<img src="https://user-images.githubusercontent.com/71127966/161421827-b1630006-868d-4896-a56d-59f38029511d.gif" width="320">|<img src="https://user-images.githubusercontent.com/71127966/161422065-0a4c59aa-f429-4c90-8b14-87107a16f612.gif" width="320">|

</details>

<br>

# ⚙️ [STEP 2] 상품 목록 UI, 무한 스크롤 구현

<details>
<summary><h3>1️⃣ Kingfisher 인터페이스를 참고한 setImage 메서드</h3></summary>

- 이미지 다운로드를 위한 `setImage 메서드`는 [Kingfisher 인터페이스](https://github.com/onevcat/Kingfisher#kingfisher-101)를 참고해서 만들었습니다.
  - `URL` 주소를 파라미터로 넣으면, `메모리 캐시`에 동일한 URL을 가진 이미지가 있는지 체크하고, 없다면 이미지를 다운로드해서 `UIImageView 에 할당`하는 메서드입니다.
  - `UIImageView` 타입의 extension 으로 메서드를 만들고, 테이블뷰/컬렉션뷰의 `cellForRowAt` 메서드가 호출될 때, cell 타입 스스로가 setImage 메서드를 호출해서 `비동기(async)`로 이미지를 다운받아 UIImageView 를 채우는 로직을 가지고 있습니다.

- 테이블뷰/컬렉션뷰의 스크롤을 빠른 속도로 내리면, `Cell 재사용` 로직 때문에 이미지가 바뀌는 이슈가 있었는데요, 그 해결 과정은 별도의 이슈( #6 )로 정리했습니다.
  - `취소 가능한 비동기 작업(Cancellable)`에 대해선 2️⃣번에 정리했습니다! 😄

```swift
extension UIImageView {
    
    func setImage(with url: URL, invalidImage: UIImage) -> Cancellable? {
        let cacheKey = url.absoluteString as NSString // URL 을 cacheKey 로 활용하기 위한 변환 과정
        
        // 해당 cacheKey 를 사용하는 이미지가 메모리 캐시에 존재한다면, 그 이미지를 꺼내 할당
        if let cachedImage = ImageCacheManager.shared.object(forKey: cacheKey) {
            self.image = cachedImage
            return nil // 이미지를 새롭게 다운받는 비동기 작업이 불필요하므로, nil 을 반환하며 메서드 종료
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }
            
            // 에러가 발생했고 그 에러가 Cell 의 재사용을 위한 prepareForReuse() 메서드 내의 비동기 작업 '취소(cancelled)'로 인한 것이 아니라면 ...
            if let error = error, error.localizedDescription != "cancelled" {
                DispatchQueue.main.async {
                    self.image = invalidImage // 미리 준비해둔 placeholder 이미지를 대신 할당
                }
                print("❌ 에러 : \(error.localizedDescription) 발생!")
                return
            } else {
                DispatchQueue.main.async {
                    guard let imageData = data,
                          let image = UIImage(data: imageData) else { return }
                    self.image = image
                    ImageCacheManager.shared.setObject(image, forKey: cacheKey) // 메모리 캐시에 URL 을 cacheKey 로 하는 이미지 저장
                }
            }
        }
        task.resume()
        return task // 이미지를 새롭게 다운받는 비동기 작업을 반환하며 메서드 종료
    }
}
```

</details>

<details>
<summary><h3>2️⃣ 취소 가능한 비동기 작업과 Cell 타입의 prepareForReuse() 활용</h3></summary>

- 위 1️⃣번에서 다뤘던 `setImage` 메서드는, 특이하게 `Cancellable?`을 반환합니다.
  - Cancellable 프로토콜을 준수하는 타입이 반환되고, 옵셔널을 붙여서 `nil`이 반환될 수도 있죠.
  - 반환시키는 task 는 원래 [URLSessionDataTask](https://developer.apple.com/documentation/foundation/urlsessiondatatask) 클래스 타입이지만, `추상화`를 위해 Cancellable 프로토콜을 채택하게 만들고, 그 프로토콜이 반환되는 것으로 표현했습니다.
  - Cancellable 프로토콜을 준수하려면, 오직 하나의 메서드 `cancel()` 만을 구현하면 됩니다.
  - 이때, `URLSessionDataTask` 클래스는 인스턴스 메서드로 이미 동일한 이름의 [cancel()](https://developer.apple.com/documentation/foundation/urlsessiontask/1411591-cancel) 메서드를 사용할 수 있습니다.

- UITableViewCell 타입에 프로퍼티로 `private var cancellableImageTask: Cancellable?` 를 생성해둡니다.
  - 그리고 `setImage` 메서드를 호출할 때 마다, 그 반환값을 cancellableImageTask 프로퍼티에 할당합니다.
  - 만약 다운로드 받아야 하는 이미지가 이미 `메모리 캐시`에 존재하면 cancellableImageTask 프로퍼티는 `nil`을 유지할 것이고, 비동기 작업이 완료되는 경우에도 `nil`이 될 것입니다.

- ☑️ 만약 테이블뷰의 스크롤을 빠르게 내리게 되면, Cell 타입이 `재사용`되면서, [prepareForReuse()](https://developer.apple.com/documentation/uikit/uitableviewcell/1623223-prepareforreuse) 메서드가 호출됩니다.
  - 이때, Cell 재사용을 위해 이미지를 비워주고(nil), 완료되지 않은 비동기 작업을 `취소(cancel)`시킵니다.
  - 이 방법을 통해, 스크롤을 빠르게 내리더라도, 이미지를 안정적으로 세팅할 수 있습니다.
  
```swift
protocol Cancellable {
    // Cancellable 프로토콜을 채택한 타입은 cancel() 메서드를 구현해야 함
    func cancel()
}

// URLSessionDataTask 클래스가 Cancellable 프로토콜 채택
extension URLSessionDataTask: Cancellable { }

final class ProductTableViewCell: UITableViewCell {
    // @IBOutlet 프로퍼티들 ...
    
    // ⭐️Cancellable 프로토콜을 준수하는 프로퍼티 cancellableImageTask 를 옵셔널로 선언!
    private var cancellableImageTask: Cancellable?
    
    // 이미지 다운로드에 실패하면 보여줄 UIImage 생성
    private let invalidImage: UIImage = {
        let invalidImage = UIImage(systemName: "xmark.icloud") ?? UIImage()
        return invalidImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
    }()
    
    override func prepareForReuse() {
        productThumbnail?.image = nil // 일단 이미지를 비워주고
        cancellableImageTask?.cancel() // ⭐️만약 완료되지 않은 비동기 작업이 있다면, 취소(cancel)함
    }
    
    func configureTableContent(with product: Product) {
        if let url = URL(string: product.thumbnail) {
            // cancellableImageTask 프로퍼티에 비동기 작업을 할당
            cancellableImageTask = productThumbnail?.setImage(
                with: url,
                invalidImage: invalidImage
            )
        }
        productName?.attributedText = product.attributedName
        productPrice?.attributedText = product.attributedPrice
        productBargainPrice?.attributedText = product.attributedBargainPrice
        productStock?.attributedText = product.attributedStock
    }
}
```

</details>
  
<details>
<summary><h3>3️⃣ 무한 스크롤을 위한 willDisplay 메서드 활용과 paginationBuffer 적용</h3></summary>
  
- UITableViewController 클래스의 [willDisplay](https://developer.apple.com/documentation/uikit/uitableviewdelegate/1614883-tableview) 메서드를 활용해서, 다음 Cell 들을 어느 타이밍에 테이블뷰에 추가할 것인지 결정했습니다.
  - 스크롤이 테이블뷰의 바닥에 닿기 전에, 미리 다음 페이지 정보를 다운로드하면, `버벅거림 없는 무한 스크롤`이 가능합니다.
  - 이때, `paginationBuffer`라는 이름의 프로퍼티를 선언해서, 개념을 구체화했습니다.
  - paginationBuffer 개념을 처음 만들 때, 페이지네이션이 중복으로 작동하는 이슈가 있었는데요, 그 해결 과정은 별도의 이슈( #4 )로 정리했습니다. 😄
  
```swift
final class ProductTableViewController: UITableViewController {
    
    private var currentPageNo: Int = 1
    private var hasNextPage: Bool = false
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let paginationBuffer = 3 // 테이블뷰의 마지막 Cell '2개' 위에서 다음 페이지 다운로드 시작
        // 만약 products.count 가 '10'이라면, 마지막 indexPath.row 는 '9'가 된다.
        // indexPath.row 가 '7'이 되는 시점은 마지막 Cell '2개' 위에 있는 Cell 이 화면에 보일 때가 된다.
        guard indexPath.row == products.count - paginationBuffer,
              hasNextPage == true else { return } // 다운로드받을 '다음 페이지'가 존재하는지도 확인 필요
        
        downloadProductsListPage(number: currentPageNo + 1)
    }
}
```

</details>

<details>
<summary><h3>4️⃣ TableViewCell 내부의 오토레이아웃 충돌 이슈 해결</h3></summary>

- 콘솔로그에 반복적으로 프린트되던 `오토레이아웃 관련 이슈`를 [WTFautolayout 사이트](https://www.wtfautolayout.com/)를 이용해서 해결했습니다.
  - `문제의 원인` -> 하나의 UI 컴포넌트에 중복으로 Constraint 를 적용해서, `우선순위 이슈`가 발생했습니다.
  - `해결 방법` -> 두 개의 Constraint 중 하나의 `우선순위(Priority)`를 750 으로 낮춰서 문제를 해결할 수 있었습니다.
  - 구체적인 내용은 별도의 이슈( #1 )로 정리했습니다. 😄

</details>

<br>

# ⚙️ [STEP 1] 모델/네트워킹 타입 구현

<details>
<summary><h3>1️⃣ HTTP Request 의 핵심 요소를 프로토콜로 정의</h3></summary>

- API 서버와 HTTP 네트워크를 진행하기 위한 `APIRequest`를 구현하기 위해, `공통적으로 필요한 프로퍼티(url, httpMethod, header, body)`를 `프로토콜`로 정의했습니다.
  - 구체적인 HTTP Request 에 해당하는 `APIRequestType` 구조체들이 모두 `APIRequest` 프로토콜을 채택하게 했습니다.
  - HTTP Request 의 핵심 요소를 프로토콜로 정의함으로써, 새로운 Request 를 만들어야 할 때도 프로토콜을 채택함으로써 확장이 편리하도록 만들었습니다.
  
```swift
// 구체적인 request 구조체들이 아래 프로토콜을 채택하고, 해당 프로퍼티를 구현하게 함
protocol APIRequest {
    
    var url: URL? { get }
    var httpMethod: HTTPMethod { get }
    var header: [String: String] { get }
    var body: Data? { get }
}

// 예시 - 상품 리스트 조회 (GET)
struct ProductsListPageRequest: APIRequest {
    
    private let pageNo: Int
    private let itemsPerPage: Int
    private let boundary: String
    
    // HTTP 통신의 기초가 되는 url, httpMethod, header, body 연산 프로퍼티 구현
    var url: URL? {
        return APIURL.productsListPage(pageNo, itemsPerPage).url
    }
    var httpMethod: HTTPMethod {
        return .get
    }
    var header: [String: String] {
        return ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
    }
    var body: Data? {
        return nil
    }
    
    init(pageNo: Int, itemsPerPage: Int) {
        self.pageNo = pageNo
        self.itemsPerPage = itemsPerPage
        self.boundary = "--\(UUID().uuidString)"
    }
}
```

</details>
  
<details>
<summary><h3>2️⃣ CodingKeys 열거형 🆚 convertFromSnakeCase</h3></summary>

- HTTP 네트워크를 위해 [Codable](https://developer.apple.com/documentation/swift/codable) 프로토콜을 채택한 `모델 타입`을 구현할 때, keyDecodingStrategy 중의 [convertFromSnakeCase](https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy/convertfromsnakecase) 전략과 `CodingKeys 열거형` 중에 어떤 것을 사용할 것인지 고민했습니다.
  - 조사해보니, 디코딩할 때는 `Strategy 가 먼저 적용`된 이후에 2순위로 CodingKeys 가 적용된다는 내용을 확인했습니다. [출처](https://stackoverflow.com/questions/49881621/the-convertfromsnakecase-strategy-doesnt-work-with-custom-codingkeys-in-swi)

- 프로젝트에서는 [스타일쉐어 Swift Style Guide #약어](https://github.com/StyleShare/swift-style-guide#%EC%95%BD%EC%96%B4) 기준에 따라 네이밍을 하고 있었는데요.
  - `thumbnailURL` 같은 상수 네이밍에서, `URL`을 대문자로 선언한 뒤에, `convertFromSnakeCase` 전략을 사용하면, `Url`로 변환되어 디코딩에 실패하는 결과로 이어졌습니다.
  - 따라서, 네이밍에서의 충돌을 피하려면, 둘 중 하나만 사용해야 했기에, 둘의 `장단점`을 비교해봤습니다.

- **convertFromSnakeCase 전략**
  - 🟢 장점 -> CodingKeys 를 매번 선언해줄 필요가 없어서, 모델의 코드가 간결해짐
  - 🔴 단점 -> 타입의 모든 프로퍼티가 반드시 lowerCamelCase 로 작성되어야 함

- **CodingKeys 열거형**
  - 🟢 장점 -> 커스터마이징이 수월해져서, 원하는 네이밍을 만들어낼 수 있음
  - 🔴 단점 -> 타입 밑에 매번 선언해줘야 해서 불편하고, 코드의 양이 많아짐

- 위 내용을 토대로, `CodingKeys` 열거형을 사용하는 것이 ‘확장성’이나 ‘유연성’에서 더 장점이 있다고 생각했습니다.
  - 참고로 [convertFromSnakeCase 공식문서](https://developer.apple.com/documentation/foundation/jsondecoder/keydecodingstrategy/convertfromsnakecase?changes=latest_minor)에 `“Acronyms(두문자어)”`은 제대로 처리하기 어렵다는 노트가 써있기도 합니다.
  - 그런 경우에는 CodingKeys 열거형을 사용하라고 적혀있는 점도 확인할 수 있었습니다. 😄

![image](https://user-images.githubusercontent.com/71127966/161547717-16c85865-6933-485a-b1f8-df1ceb0125f0.png)

```swift
// 모델 타입 중 하나인, ProductsListPage 구조체 예시
struct ProductsListPage: Codable {
    
    let pageNo: Int
    let itemsPerPage: Int
    let totalCount: Int
    let offset: Int
    let limit: Int
    let pages: [Product]
    let lastPage: Int
    let hasNext: Bool
    let hasPrev: Bool
    
    // CodingKeys 열거형은 외부에서 접근할 필요가 없으므로 private 접근제어 부여
    // nested 열거형의 이름인 "CodingKeys" 는 변경하면 안 됨!
    private enum CodingKeys: String, CodingKey {
        
        case pageNo = "page_no"
        case itemsPerPage = "items_per_page"
        case totalCount = "total_count"
        case lastPage = "last_page"
        case hasNext = "has_next"
        case hasPrev = "has_prev"
        case offset, limit, pages
    }
}
```

</details>
  
<details>
<summary><h3>3️⃣ 상품 정보 POST 관련 시행착오</h3></summary>

- `boundary` 시행착오
  - 네트워크 라이브러리를 사용하지 않고, HTTP Request 를 직접 구현해서 사용했습니다.
  - 이때, header 의 Content-Type 이 `multipart/form-data`인 경우, 각 엔티티를 구분하기 위해 `boundary`가 필요합니다.
  - [MDN 문서](https://developer.mozilla.org/ko/docs/Web/HTTP/Methods/POST)를 참고하면서 구현했으나, 디버깅에 꽤 시간이 소요됐습니다.
  - 이유를 찾고보니, `boundary 의 유형이 총 3가지`임을 구분하지 못해서 였습니다.
  - 또한, boundary 는 `multipart/form-data` 사용할 때만 필요하다는 것을 배웠습니다. [출처](https://stackoverflow.com/questions/3508338/what-is-the-boundary-in-multipart-form-data)

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/161554333-cf3e1da7-bb6b-4597-b181-0f54658b8d21.png" width="70%"></p> 

- `\"` 시행착오
  - 아래 이미지를 보면, name, filename 같은 파라미터에 `"field2"` 이런 식으로 String 이 들어가 있는 것을 보고, “field2” 로 넣어놨던 게 화근이었습니다.
  - “field2” 로 코드를 넣어두면, 실제 httpBody 에서는 `name=filed2` -> 이렇게 따옴표(")가 사라져버립니다. 그렇기 때문에 인위적으로 따옴표를 살려놔야 하는 것입니다.
  - 스위프트에서 따옴표를 String 의 경계선으로 인식하지 않게 하려면 `역슬래시(\)`와 함께 붙여쓰면 됩니다.
  - 즉, `"\"field2\""` -> 이렇게 입력해야 합니다. 👍🏻

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/161558120-7973013a-09a1-43d9-a725-6c52871bba02.png" width="70%"></p> 

- `CodingKeys` 시행착오
  - 상품 등록을 하려면 그 상품 정보를 params 라는 키 값에 대응하는 `JSON 객체`로 만들어서 httpBody 에 넣어줘야 합니다.
  - JSON 객체 만들어내기 위한 모델 타입인 NewProductInfo 다 구현해두고서, 가장 중요한 `CodingKeys 열거형`을 안 만들어서 네트워크 오류가 발생했습니다.
  - 다른 let 프로퍼티들은 괜찮은데, `discountedPrice`가 에러를 일으키는 주범이었습니다.
  - 그 이유는, JSON 객체로 보낼 때는 `스네이크 표기법`으로 상수 이름을 바꿔서 보내야 하는데, CodingKeys 열거형을 안 만들어놨으니 인코딩이 제대로 되지 않았던 것입니다. 😅

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/161558916-de44e112-d9b0-4d53-92f3-904b4ec754e5.png" width="70%"></p> 

- `filename` 시행착오
  - 서버 API 명세의 상품 등록 request 예시에는 "src"라는 키값에 대응되는 값으로 `"~.jpg"`로 끝나는 이름이 달려있고, [MDN 문서](https://developer.mozilla.org/ko/docs/Web/HTTP/Methods/POST)에도 `"~.txt"`로 표현되어 있습니다.
  - filename 키값에는 `파일 확장자명이 반드시 들어가야` 한다는 걸 배웠습니다.

<p align="left"><img src="https://user-images.githubusercontent.com/71127966/161561986-22a4f31d-5e9b-4537-aeab-2db72b8ce036.png" width="70%"></p>

</details>
