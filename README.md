# social_app

Chào mừng bạn đến với dự án Flutter-Social-Media-App, một dự án xây dựng một mạng xã hội đơn giản.

## Features

Flutter-Social-Media-App có những tính năng chính như sau:

1. **Trang đăng nhập và đăng ký:** Người dùng có thể tạo tài khoản mới hoặc đăng nhập với tài khoản đã có.

2. **Sáng tạo bài đăng:** Người dùng có thể sáng tạo, sửa và xóa các bài đăng.

3. **Đăng bình luận:** Trên mỗi bài đăng, người dùng có thể tạo, sửa hoặc xóa bình luận.

4. **Thích bài viết:** Người dùng có thể thích các bài đăng.

5. **Hồ sơ người dùng:** Đây là nơi người dùng có thể theo dõi các thông tin và bài đăng của mình.

6. **Chuyển chủ đề màu:** Người dùng có thể chuyển đổi qua lại giữa chủ đề màu sáng hoặc tối cho ứng dụng.

7. **Bảng tin:** Đây là nơi người dùng có thể theo dõi các hoạt động trên ứng dụng.

## Để chạy được dự án này:

1. Bạn cần cài đặt Flutter SDK phiên bản mới nhất. Nếu chưa cài đặt thì bạn có thể thực hiện theo hướng dẫn [flutter.dev](https://flutter.dev/docs/get-started/install) .

2. Bạn cần cài đặt 1 IDE phù hợp với phiên bản mới nhất (Android Studio hay Visual Studio Core):
- https://developer.android.com/studio
- https://code.visualstudio.com/download

3. Cài đặt cái Plugin phù hợp (Flutter, Dart, Flutter PUB)

4. Tạo 1 dự án Firebase, hướng dẫn tại đây: [https://console.firebase.google.com](https://console.firebase.google.com/).

5. Trong dự án Firebase, Khởi tạo các dịch vụ Firebase Auth và Firebase Firestore.

6. Lưu ý:
- Khi cài đặt FireBase CLI, nên sử dụng phương thức npm (the Node Package Manager).
- Sau khi cài đặt, khởi chạy FireBase CLI bằng Command Promdt. Đăng nhập tài khoản FireBase bằng câu lệnh:
firebase login
- Tìm đến dự án FireBase cần kết nối bằng lệnh:
firebase projects:list
- Chạy lệnh sau để cài đặt Tool flutterfire_cli, bằng lệnh:
dart pub global activate flutterfire_cli
- Trong Command Promdt di chuyển đến thư mục chính chứa dự án Flutter-Social-Media-App, chạy lệnh:
flutterfire configure --project=TÊN DỰ ÁN FIREBASE
- Hệ thống sẽ tự tạo file cấu hình cho dịch vụ Firebase trong thư mục dự án Flutter-Social-Media-App (lib/firebase_options.dart).
  
7. Mở Android Studio, mở dự án Flutter-Social-Media-App, tại của sổ Terminal chạy lệnh:
Flutter pub get
Để tải và cập nhật lại tất cả Packages cần thiết cho dự án Flutter-Social-Media-App

9. Kết nối đến máy ảo hoặc máy vật lý Android và chạy ứng dụng.
    
## Back-End: Firebase

Flutter-Social-Media-App sử dụng các dịch vụ của Firebase làm nền tảng phụ trợ, tận dụng các tài nguyên do Firebase cung cấp để đảm bảo trải nghiệm người dùng mượt mà và đáng tin cậy. Các thiết lập Firebase bao gồm:

* **Firebase Auth:** Được sử dụng để xác thực người dùng, cho phép đăng ký và đăng nhập an toàn.
* **Firebase Firestore:** Chịu trách nhiệm lưu trữ thông tin người dùng, bài viết của người dùng và bình luận của người dùng. Đây là cơ sở dữ liệu thời gian thực giúp thông tin được đồng bộ hóa trên tất cả các thiết bị được kết nối.

## Contributing

Contributions are welcome! Feel free to open issues or send pull requests with improvements, bug fixes, or new features.
