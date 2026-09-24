# Vòng Đời Bầu Cử (Election Lifecycle)

Hệ thống bầu cử Blockchain của dự án hoạt động theo một vòng đời khép kín, minh bạch và an toàn. Vòng đời này được chia thành 3 giai đoạn chính nhằm đảm bảo tính hợp lệ của mọi lá phiếu:

## 1. Giai đoạn Chuẩn bị (Setup / Admin Phase)
- **Triển khai hợp đồng (Deploy)**: Hợp đồng `VotingCore` và các module liên quan được triển khai lên mạng lưới. Người triển khai tự động nắm quyền quản trị viên (`Admin`).
- **Thêm Ứng cử viên (Add Candidates)**: Admin sử dụng module `CandidateManager` để thêm thông tin ứng cử viên vào hệ thống.
- **Đăng ký Cử tri (Voter Registry)**: Admin xét duyệt và cấp quyền cho các địa chỉ ví hợp lệ tham gia bỏ phiếu. Thao tác này đưa ví vào whitelist (có thể dùng `batchRegisterVoters` để thêm hàng loạt). Chỉ những cử tri trong danh sách này mới có quyền vote.
- **Lên lịch Bầu cử (Schedule Election)**: Admin dùng `ElectionScheduler` để thiết lập thời điểm **Bắt đầu** và **Kết thúc** của cuộc bầu cử. 

## 2. Giai đoạn Bỏ phiếu (Voting Phase)
- **Mở hòm phiếu**: Khi thời gian thực (block timestamp) chạm mốc thời gian bắt đầu. Lúc này hệ thống tự động khóa danh sách ứng cử viên (không được phép thêm/xóa nữa).
- **Tiến hành bỏ phiếu (Cast Vote)**: 
  - Cử tri sử dụng ví cá nhân kết nối vào hệ thống và gọi hàm `vote(candidateId)`.
  - Hợp đồng thông minh sẽ tự động kiểm tra 3 điều kiện:
    1. Cử tri đã được đăng ký hợp lệ chưa?
    2. Đã đến giờ bầu cử chưa / Bầu cử đã kết thúc chưa?
    3. Cử tri này đã bỏ phiếu trước đây chưa? (Chống double-voting).
  - Nếu thỏa mãn, phiếu sẽ được cộng cho ứng viên tương ứng, cử tri bị đánh dấu là "đã bầu", và một sự kiện (`VoteCast`) được phát ra lên blockchain.

## 3. Giai đoạn Kết thúc & Công bố (Ended & Tally Phase)
- **Đóng hòm phiếu**: Khi mốc thời gian vượt qua thời gian kết thúc, hợp đồng thông minh tự động từ chối mọi giao dịch gọi hàm `vote()` mới.
- **Kiểm phiếu minh bạch**: Do đặc thù blockchain, số phiếu (`voteCount`) được tự động kiểm đếm công khai và liên tục trong suốt quá trình. Bất kì ai cũng có thể truy vấn số phiếu hiện tại.
- **Công bố**: Frontend có thể gọi hàm để lấy danh sách kết quả hoặc người chiến thắng hiển thị lên giao diện (UI) chính thức.
