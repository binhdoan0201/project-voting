GIAI ĐOẠN 1: CHUẨN BỊ BẦU CỬ (Dùng Account 1 - Admin)

1. Thêm Ứng cử viên

Mở CandidateManager, tìm hàm addCandidate.
Nhập: "Obama", "Dang Dan Chu", "Lanh dao tot" -> Bấm Transact.
Tiếp tục nhập: "Trump", "Dang Cong Hoa", "Ty phu" -> Bấm Transact.
(Lúc này ID của Obama là 0, ID của Trump là 1).

2. Chốt danh sách

Tìm hàm lockCandidates bên CandidateManager -> Bấm Transact. (Mục đích: Không cho ai chèn thêm hoặc sửa thông tin ứng viên trong lúc đang bầu).

3. Mở cửa hòm phiếu

Mở ElectionScheduler, tìm hàm startElection -> Bấm Transact. (Lúc này hệ thống chính thức bắt đầu tính giờ, cử tri đã có thể vào vote).

GIAI ĐOẠN 2: TIẾN HÀNH BẦU CỬ (Đóng vai Cử tri)

1. Cử tri 1 đi bầu

Trên cùng bên trái Remix (phần Account), đổi sang Account số 2 (để đóng vai Cử tri 1).
Mở VotingCore, tìm hàm vote.
Nhập 0 (bầu cho Obama) -> Bấm Transact. (Sẽ báo tích xanh thành công).

2. Cử tri 1 gian lận bầu lần 2

Vẫn đang ở Account số 2, bạn cố tình nhập số 1 (bầu cho Trump) vào hàm vote -> Bấm Transact.
👉 Báo lỗi đỏ: "Ban da tham gia bau cu roi". (Hệ thống chặn thành công).

3. Cử tri 2 đi bầu

Trên phần Account, đổi sang Account số 3 (đóng vai Cử tri 2).
Trong hàm vote của VotingCore, nhập 0 (lại bầu cho Obama) -> Bấm Transact.

GIAI ĐOẠN 3: KẾT THÚC & XEM KẾT QUẢ

1. Đóng hòm phiếu (Phải dùng lại Account Admin)

Đổi Account về lại Account số 1 (Admin).
Mở ElectionScheduler, bấm nút endElection -> Bấm Transact. (Cuộc bầu cử chính thức kết thúc).

2. Cử tri đi muộn

Đổi sang Account số 4.
Cố tình gọi hàm vote (bầu cho số 1) trong VotingCore.
👉 Báo lỗi đỏ: "Cuoc bau cu chua bat dau hoac da ket thuc".

3. Xem kết quả chung cuộc

Mở CandidateManager, kéo xuống bấm vào nút màu xanh getAllCandidates.
Xem thông tin trả về, bạn sẽ thấy kết quả:
Ứng viên 0 (Obama): voteCount = 2
Ứng viên 1 (Trump): voteCount = 0
