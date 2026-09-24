# 🗳️ Hệ Thống Bầu Cử Blockchain (Blockchain Voting System)

Hệ thống bầu cử phi tập trung được phát triển bởi **Team 15 người** trong đợt chạy nước rút 5 ngày. Dự án áp dụng công nghệ Blockchain (Smart Contracts) để đảm bảo tính minh bạch, toàn vẹn dữ liệu và tự động hóa quy trình bầu cử, đồng thời tuân thủ nghiêm ngặt quy trình quản lý mã nguồn chuẩn Web3.

## 🌟 Các tính năng chính
- **Quản lý ứng viên:** Thêm mới và quản lý thông tin các ứng viên tranh cử.
- **Quản lý cử tri (Whitelist):** Đăng ký cử tri đơn lẻ hoặc hàng loạt (batch register) giúp tối ưu phí gas. Kiểm tra chặt chẽ quyền bỏ phiếu.
- **Quản lý lịch trình:** Tự động mở và đóng hòm phiếu theo cấu hình thời gian (timestamp) định sẵn. Hòm phiếu tự động khóa ở lần gọi hợp lệ đầu tiên.
- **Bỏ phiếu minh bạch:** Mỗi cử tri hợp lệ chỉ được bỏ phiếu 1 lần duy nhất (chống double-vote). Dữ liệu được ghi vĩnh viễn trên blockchain và không thể sửa đổi.

## 📂 Cấu trúc dự án
Dự án được phân chia thành các module độc lập để dễ quản lý:
- `contracts/`: Chứa toàn bộ Smart Contracts.
  - `VotingCore.sol`: Hợp đồng lõi điều phối toàn bộ hệ thống.
  - `CandidateManager.sol`: Hợp đồng quản lý ứng viên.
  - `VoterRegistry.sol`: Hợp đồng quản lý danh sách cử tri.
  - `ElectionScheduler.sol`: Hợp đồng quản lý thời gian diễn ra bầu cử.
- `test/`: Chứa các kịch bản kiểm thử (test cases) cho nhóm hàm admin và nhóm hàm vote.
- `scripts/`: Kịch bản triển khai (deploy) hợp đồng.
- `docs/`: Tài liệu chi tiết của dự án (`roadmap.md`, `vong-doi-bau-cu.md`).

## ⚙️ Yêu cầu hệ thống (Prerequisites)
Để chạy và đóng góp cho dự án trên máy cá nhân, bạn cần cài đặt:
- [Node.js](https://nodejs.org/) (phiên bản v16 trở lên)
- [Git](https://git-scm.com/)

## 🚀 Hướng dẫn cài đặt & Chạy dự án (Local)

**1. Clone dự án về máy**

    git clone https://github.com/binhdoan0201/project-voting.git
    cd project-voting

**2. Cài đặt các gói phụ thuộc**

    npm install

*(Lệnh này tự động cài đặt môi trường Hardhat và các công cụ quản lý code bắt buộc của dự án như Husky, Prettier, Solhint).*

**3. Biên dịch hợp đồng (Compile)**

    npx hardhat compile

**4. Chạy kiểm thử tự động (Test)**

    npx hardhat test

*(Yêu cầu: Đảm bảo toàn bộ test case từ Nhóm 3 chạy pass 100% trước khi tiến hành deploy hoặc demo).*

## 👥 Đội ngũ phát triển (5 Nhóm)
Dự án được phân chia công việc song song:
- **Nhóm 1 (Core Contract):** Phụ trách viết `VotingCore.sol`, `CandidateManager.sol`, `ElectionScheduler.sol`.
- **Nhóm 2 (Registry & Tích hợp):** Phụ trách viết `VoterRegistry.sol`, tối ưu gas (batch register) và ghép nối module.
- **Nhóm 3 (Test/QA):** Phụ trách kiểm thử toàn diện, bắt bug nhóm hàm admin và hàm vote (double-vote, sai giờ).
- **Nhóm 4 (Frontend/Demo):** Chuẩn bị kịch bản demo trên Remix, làm slide và thuyết trình.
- **Nhóm 5 (Docs/Quản lý):** Viết README, Roadmap, quản lý quy trình Git, review Pull Request và canh deadline.

## 🤝 Hướng dẫn đóng góp (Contributing)
Tất cả các thành viên trong team **BẮT BUỘC** phải đọc kỹ file [CONTRIBUTING.md](./CONTRIBUTING.md) trước khi tham gia viết code.

- **Quy trình Nhánh (Branching):** Tuyệt đối không code hoặc push thẳng vào `main` hay `develop`. Mọi thay đổi phải làm trên nhánh riêng (VD: `feature/registry-batch-check`) và mở Pull Request (PR) vào `develop`.
- **Quy chuẩn Commit:** Bắt buộc dùng Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`).
- **Quy chuẩn Code:** Sử dụng `PascalCase` cho Contract/Struct/Event và `camelCase` cho Function/Biến. Comment hàm bắt buộc theo chuẩn NatSpec.
- **Công cụ ép buộc (CI/CD):** 
  - **Husky (pre-commit hook):** Chặn commit nếu code sai convention (Solhint) hoặc chưa format (Prettier-Solidity).
  - **GitHub Actions:** CI tự động chạy compile + test. PR không thể merge nếu fail hoặc chưa có review chéo.
