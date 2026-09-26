🗳️ Hệ Thống Bầu Cử Blockchain
(Blockchain Voting System)
Hệ thống bầu cử phi tập trung được phát triển bởi Team 15 người trong đợt chạy nước rút 5 ngày. Dự án áp dụng công nghệ Blockchain (Smart Contracts) để đảm bảo tính minh bạch, toàn vẹn dữ liệu và tự động hóa quy trình bầu cử, đồng thời tuân thủ nghiêm ngặt quy trình quản lý mã nguồn chuẩn Web3.
🌟 Các tính năng chính
•	Quản lý ứng viên: Thêm mới và quản lý thông tin các ứng viên tranh cử.
•	Quản lý cử tri (Whitelist): Đăng ký cử tri đơn lẻ hoặc hàng loạt (batch register) giúp tối ưu phí gas. Kiểm tra chặt chẽ quyền bỏ phiếu.
•	Quản lý lịch trình: Tự động mở và đóng hòm phiếu theo cấu hình thời gian (timestamp) định sẵn. Hòm phiếu tự động khóa ở lần gọi hợp lệ đầu tiên.
•	Bỏ phiếu minh bạch: Mỗi cử tri hợp lệ chỉ được bỏ phiếu 1 lần duy nhất (chống double-vote). Dữ liệu được ghi vĩnh viễn trên blockchain và không thể sửa đổi.
📂 Cấu trúc dự án
Dự án được phân chia thành các module độc lập để dễ quản lý:
•	contracts/ Chứa toàn bộ Smart Contracts.
•	VotingCore.sol: Hợp đồng lõi điều phối toàn bộ hệ thống.
•	CandidateManager.sol: Hợp đồng quản lý ứng viên.
•	VoterRegistry.sol: Hợp đồng quản lý danh sách cử tri.
•	ElectionScheduler.sol: Hợp đồng quản lý thời gian diễn ra bầu cử.
•	test/ Chứa các kịch bản kiểm thử (test cases) cho nhóm hàm admin và nhóm hàm vote.
•	scripts/ Kịch bản triển khai (deploy) hợp đồng.
•	docs/ Tài liệu chi tiết của dự án (roadmap.md, vong-doi-bau-cu.md).
⚙️ Yêu cầu hệ thống (Prerequisites)
•	Trình duyệt web (Google Chrome, Cốc Cốc, Brave...) để chạy Remix IDE.
•	Nếu chạy môi trường cục bộ (Local): Cần cài đặt Node.js và Git.
🚀 Hướng dẫn Cài đặt & Chạy dự án
Dự án hỗ trợ 2 phương pháp chạy: Dành cho Demo (Remix IDE) và Dành cho Developer (Hardhat Local).
🌐 Cách 1: Chạy trực tiếp trên Remix IDE (Dễ nhất - Không cần Terminal)
Đề xuất dùng phương pháp này cho Nhóm 4 (Demo/Thuyết trình) để minh họa trực quan cách tương tác với Smart Contract.
Bước 1: Tải mã nguồn về máy
1.	Truy cập trang GitHub của dự án: https://github.com/binhdoan0201/project-voting
2.	Bấm vào nút màu xanh lá cây "Code" ở góc phải ➔ Chọn "Download ZIP".
3.	Giải nén file .zip vừa tải về máy tính của bạn.
Bước 2: Tải code lên Remix IDE
4.	Truy cập trình duyệt và mở Remix IDE (https://remix.ethereum.org/).
5.	Tại tab File Explorer (biểu tượng tệp tin ở góc trên bên trái), tạo một Workspace mới hoặc dùng mặc định.
6.	Bấm vào nút Upload file (biểu tượng tờ giấy có mũi tên hướng lên).
7.	Tìm đến thư mục contracts trong máy tính mà bạn vừa giải nén, bôi đen toàn bộ các file .sol (bao gồm VotingCore.sol, CandidateManager.sol, VoterRegistry.sol, ElectionScheduler.sol) và bấm Open để tải lên.
Bước 3: Biên dịch hợp đồng (Compile)
8.	Bấm đúp chuột để mở file VotingCore.sol trên Remix.
9.	Chuyển sang tab Solidity Compiler (biểu tượng chữ S ở menu thanh dọc ngoài cùng bên trái).
10.	Đảm bảo mục Compiler chọn phiên bản phù hợp (ví dụ: 0.8.24 hoặc khớp với dòng pragma solidity trong code).
11.	Bấm nút màu xanh dương "Compile VotingCore.sol".
12.	Nếu thành công, tab Compiler sẽ hiện biểu tượng dấu tích xanh lá cây, không có dòng báo lỗi màu đỏ.
Bước 4: Triển khai hợp đồng (Deploy)
13.	Chuyển sang tab Deploy & Run Transactions (biểu tượng logo Ethereum ở thanh bên trái).
14.	Tại mục Environment, chọn Remix VM (Cancun) hoặc Remix VM (Shanghai). (Đây là mạng blockchain ảo đã có sẵn 100 ETH giả để làm phí gas).
15.	Tại mục Contract, bấm vào menu thả xuống và tìm chọn chính xác hợp đồng VotingCore (vì đây là hợp đồng tổng chứa các module khác).
16.	Bấm nút màu cam "Deploy".
17.	Kéo xuống mục Deployed Contracts ở bên dưới, bấm mũi tên mở rộng để thấy các nút chức năng. Bây giờ bạn có thể tương tác thực tế (Thêm ứng viên, đăng ký cử tri, bỏ phiếu) trực tiếp trên giao diện!
💻 Cách 2: Chạy Local bằng Hardhat (Dành cho Code & QA Test)
Dành cho Nhóm 1, 2, 3 dùng để code, chạy file test tự động và kiểm tra luồng CI/CD.
1. Clone dự án về máy
git clone https://github.com/binhdoan0201/project-voting.git
cd project-voting
2. Cài đặt các gói phụ thuộc
npm install
(Lệnh này tự động cài đặt môi trường Hardhat và các công cụ Linter như Husky, Prettier, Solhint).
3. Biên dịch hợp đồng (Compile)
npx hardhat compile
4. Chạy kiểm thử tự động (Test)
npx hardhat test
(Yêu cầu: Đảm bảo toàn bộ test case chạy pass 100% trước khi đẩy code lên).
👥 Đội ngũ phát triển (5 Nhóm)
Dự án được phân chia công việc song song:
•	Nhóm 1 (Core Contract): Phụ trách viết VotingCore.sol, CandidateManager.sol, ElectionScheduler.sol.
•	Nhóm 2 (Registry & Tích hợp): Phụ trách viết VoterRegistry.sol, tối ưu gas (batch register) và ghép nối module.
•	Nhóm 3 (Test/QA): Phụ trách kiểm thử toàn diện, bắt bug nhóm hàm admin và hàm vote (double-vote, sai giờ).
•	Nhóm 4 (Frontend/Demo): Chuẩn bị kịch bản demo trên Remix, làm slide và thuyết trình.
•	Nhóm 5 (Docs/Quản lý): Viết README, Roadmap, quản lý quy trình Git, review Pull Request và canh deadline.
🤝 Hướng dẫn đóng góp (Contributing)
Tất cả các thành viên trong team BẮT BUỘC phải đọc kỹ file CONTRIBUTING.md trước khi tham gia viết code.
•	Quy trình Nhánh (Branching): Tuyệt đối không code hoặc push thẳng vào main hay develop. Mọi thay đổi phải làm trên nhánh riêng (VD: feature/registry-batch-check) và mở Pull Request (PR) vào develop.
•	Quy chuẩn Commit: Bắt buộc dùng Conventional Commits (feat:, fix:, test:, docs:).
•	Quy chuẩn Code: Sử dụng PascalCase cho Contract/Struct/Event và camelCase cho Function/Biến. Comment hàm bắt buộc theo chuẩn NatSpec.
•	Công cụ ép buộc (CI/CD):
•	Husky (pre-commit hook): Chặn commit nếu code sai convention (Solhint) hoặc chưa format (Prettier-Solidity).
•	GitHub Actions: CI tự động chạy compile + test. PR không thể merge nếu fail hoặc chưa có review chéo.
