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
  - `textColor` -> 텍스트 색상은 placeholder 특유의 회색을 표현하기 위해, [UIColor.placeholderText](https://developer.apple.com/documentation/uikit/uicolor/3173134-placeholdertext) 색상 적용했습니다.
  - `backgroundColor` -> 배경은 투명한 색상인 [UIColor.clear](https://developer.apple.com/documentation/uikit/uicolor/1621945-clear) 적용하여, 콘텐츠를 가리지 않도록 했습니다.
  - ⭐ `isUserInteractionEnabled` -> 가장 중요한 처리입니다. placeholder 역할을 하는 UITextView 가 `사용자의 터치`를 받으면 안 되므로, [isUserInteractionEnabled](https://developer.apple.com/documentation/uikit/uiview/1622577-isuserinteractionenabled) 프로퍼티를 false 로 처리하여, 터치를 무시하도록 만들었습니다.
  
```swift
// 커스텀 placeholder 역할을 해줄 UITextView 생성

private var descriptionsTextViewPlaceholder: UITextView = {
    let textView = UITextView()
    textView.text = "브랜드, 사이즈, 색상, 소재 등 물품에 대한 자세한 정보를 작성하면 판매확률이 올라가요!"
    textView.textColor = .placeholderText // 디폴트로 정의된 placeholder 색상 적용
    textView.font = .preferredFont(forTextStyle: .body)
    textView.backgroundColor = .clear // 투명한 배경색을 적용
    textView.isUserInteractionEnabled = false // 사용자의 터치를 받지 못하도록 interaction 프로퍼티를 false 처리
    textView.isScrollEnabled = false
    textView.translatesAutoresizingMaskIntoConstraints = false // 코드로 오토레이아웃을 적용할 것이므로, 해당 프로퍼티는 false 처리
    textView.showsVerticalScrollIndicator = false
    textView.showsHorizontalScrollIndicator = false
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
<summary><h3>1️⃣ 작성 예정</h3></summary>

- segmented Control 관련 내용

</details>
