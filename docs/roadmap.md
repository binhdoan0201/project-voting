# Roadmap Phát Triển Dự Án Bầu Cử Blockchain (5 Ngày)

Đây là lộ trình phát triển nhanh dự án Bầu Cử Blockchain dành cho team 15 người. Roadmap này giúp đảm bảo tiến độ và đồng bộ giữa 5 nhóm nhỏ.

## Ngày 1: Khởi tạo & Định hình (Foundation)
- **Nhóm 1-2 (Code)**: Viết code, tách các module theo chuẩn (VoterRegistry, CandidateManager, ElectionScheduler).
- **Nhóm 3 (QA/Test)**: Lên danh sách và viết khung các test case chuẩn bị cho hợp đồng.
- **Nhóm 4 (Demo)**: Lên kịch bản demo và outline slide trình bày.
- **Nhóm 5 (Docs/Git)**: Setup Repository, cấu hình `.github/CODEOWNERS`, bật branch protection và thiết lập CI (Continuous Integration).

## Ngày 2: Tích hợp & Kiểm thử sơ bộ
- **Nhóm 1-2**: Gộp toàn bộ các module lại thành `VotingCore.sol` hoàn chỉnh, tự compile và sửa lỗi cú pháp.
- **Nhóm 3**: Chạy test thực tế với code của Nhóm 1-2 trên Remix/Hardhat, ghi nhận bug và báo cáo.
- **Nhóm 4**: Dựng slide với nội dung chi tiết bám sát kịch bản.
- **Nhóm 5**: Viết `README.md`, hoàn thiện tài liệu `vong-doi-bau-cu.md` và `roadmap.md`. Tiến hành gộp nhánh (merge) lên `main`.

## Ngày 3: Sửa lỗi & Khớp nối (Critical Day)
*Đây là ngày quan trọng nhất của toàn bộ dự án.*
- **Nhóm 1-2**: Ưu tiên tối đa cho việc **Fix bug** do Nhóm 3 báo cáo.
- **Nhóm 3**: Test lại (Regression Test) ngay sau khi bug được fix để đảm bảo hệ thống không phát sinh lỗi mới.
- **Nhóm 4**: Tập demo lần 1 với contract thật, rà soát lại các bước thao tác để tránh lỗi bất ngờ.
- **Nhóm 5**: Hỗ trợ Nhóm 3 test thủ công trên Remix (nếu rảnh). Rà soát lại slide của Nhóm 4 cho khớp code.

## Ngày 4: Đóng băng Code & Tổng duyệt (Code Freeze)
- **Code Freeze**: Khoá toàn bộ code. Không ai được thêm tính năng mới, chỉ sửa lỗi nếu cực kỳ nghiêm trọng.
- **Nhóm 3**: Test hồi quy (test lại toàn bộ) lần cuối cùng.
- **Nhóm 4**: Tập demo lần 2, bấm giờ và diễn tập như lúc báo cáo thật.
- **Nhóm 5**: Rà soát lại toàn bộ tài liệu một lần nữa, chuẩn bị các file nộp bài cho giáo viên.

## Ngày 5: Báo cáo & Trình bày (Demo Day)
- **Nhóm 4**: Thuyết trình slide và thực hiện thao tác demo trực tiếp.
- **Nhóm 3**: Đứng máy dự phòng, sẵn sàng bắt bệnh ngay nếu lúc demo Remix gặp sự cố. Trả lời câu hỏi kỹ thuật.
- **Nhóm 1-2 & Nhóm 5**: Đảm bảo hậu cần, sẵn sàng giải đáp và backup nếu hội đồng hỏi sâu về logic code và quản lý Git.
