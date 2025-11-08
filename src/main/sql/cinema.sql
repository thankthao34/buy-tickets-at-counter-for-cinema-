CREATE DATABASE IF NOT EXISTS cinema_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use  cinema_db;
CREATE TABLE tblUser (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  fullName     VARCHAR(255),
  birthday     DATE ,
  gender       VARCHAR(20) ,
  phone        VARCHAR(30) ,
  email        VARCHAR(255) ,
  username     VARCHAR(255) UNIQUE NOT NULL,
  password     VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'CUSTOMER'
);
CREATE TABLE tblCustomer (
  tbluserId INT PRIMARY KEY,
  FOREIGN KEY (tblUserid) REFERENCES tblUser (id) ON DELETE CASCADE
);
CREATE TABLE tblEmployee (
  tblUserid INT KEY,
  position  VARCHAR(255) NOT NULL,
  salary    float NOT NULL ,
  FOREIGN KEY (tblUserid) REFERENCES tblUser(id) ON DELETE CASCADE
);
CREATE TABLE tblTicketClerk (
  tblUserid INT PRIMARY KEY,
  code      VARCHAR(255) UNIQUE NOT NULL,
  kpi       float ,
  FOREIGN KEY (tblUserid) REFERENCES tblUser(id) ON DELETE CASCADE
);
CREATE TABLE tblMembershipCard (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  registrationDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  reward_points    FLOAT DEFAULT 0,
  cardNumber       VARCHAR(255) UNIQUE NOT NULL,
  tblCustomer_tblUserid INT NOT NULL,
  FOREIGN KEY (tblCustomer_tblUserid) REFERENCES tblCustomer(tblUserid) ON DELETE CASCADE
);

CREATE TABLE tblMovie (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  category  VARCHAR(255) ,
  description TEXT ,
  poster    VARCHAR(255) ,
  name      VARCHAR(255) NOT NULL,
  active    TINYINT NOT NULL DEFAULT 1
);
CREATE TABLE tblRoom (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  capacity  INT NOT NULL,
  description VARCHAR(255) ,
  name      VARCHAR(255) NOT NULL
);
CREATE TABLE tblSeat (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(255) NOT NULL,      -- mã ghế: A1, B5...
  position    VARCHAR(255) NULL,          -- hàng/cột nếu cần
  tblRoomid   INT NOT NULL,
  description VARCHAR(255) NULL,
  priceMultiplier FLOAT NOT NULL DEFAULT 1,
  FOREIGN KEY (tblRoomid) REFERENCES tblRoom(id) ON DELETE CASCADE
);
CREATE TABLE tblSchedule (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  tblMovieid INT NOT NULL,
  date      DATE NOT NULL,
  endTime   TIME NOT NULL,
  startTime TIME NOT NULL,
  tblRoomid INT NOT NULL,
  basePrice FLOAT NOT NULL,
  FOREIGN KEY (tblMovieid) REFERENCES tblMovie(id) ON DELETE CASCADE,
  FOREIGN KEY (tblRoomid)  REFERENCES tblRoom(id)  ON DELETE CASCADE
);
CREATE TABLE tblSeatSchedule (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  tblSeatid    INT NOT NULL,
  tblScheduleid INT NOT NULL,
  -- trạng thái thực tế triển khai
  status 	TINYINT(1) NOT NULL DEFAULT '1',
  FOREIGN KEY (tblSeatid)     REFERENCES tblSeat(id)       ON DELETE CASCADE,
  FOREIGN KEY (tblScheduleid) REFERENCES tblSchedule(id)   ON DELETE CASCADE
);
CREATE TABLE tblBill (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  pointEx     FLOAT DEFAULT 0,                 -- điểm quy đổi
  createDate  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tblCustomerid INT NULL,                      -- có thể NULL khi bán tại quầy cho khách lẻ
  FOREIGN KEY (tblCustomerid) REFERENCES tblCustomer(tblUserid) ON DELETE SET NULL,
  total_price FLOAT NOT NULL
);
CREATE TABLE tblTicket (
  id                INT AUTO_INCREMENT PRIMARY KEY,
  price             FLOAT NOT NULL,
  tblBillid         INT NOT NULL,
  tblSeatScheduleid INT NOT NULL,
  FOREIGN KEY (tblBillid)         REFERENCES tblBill(id)            ON DELETE CASCADE,
  FOREIGN KEY (tblSeatScheduleid) REFERENCES tblSeatSchedule(id)    ON DELETE RESTRICT
  );
  CREATE TABLE tblOfflineBill (
  tblBillid     INT PRIMARY KEY,
  tblTicketClerkid INT NOT NULL,
  FOREIGN KEY (tblBillid)       REFERENCES tblBill(id)        ON DELETE CASCADE,
  FOREIGN KEY (tblTicketClerkid) REFERENCES tblTicketClerk(tblUserid) ON DELETE RESTRICT
);

INSERT INTO tblUser
(fullName, birthday, gender, phone, email, username, password, role)
VALUES
('Nguyen Van A','2003-05-12','MALE','0900000001','a.seller@example.com','seller_a','pass123','SELLER'),
('Tran Thi B','2002-10-01','FEMALE','0911111112','b.seller@example.com','seller_b','pass123','SELLER'),
('Le Van C','2001-08-20','MALE','0922222223','c.seller@example.com','seller_c','pass123','SELLER');

INSERT INTO tblEmployee (tblUserid, position, salary)
SELECT id, 'Ticket Clerk', 8000000
FROM tblUser WHERE username = 'seller_a';

INSERT INTO tblTicketClerk (tblUserid, code, kpi)
SELECT id, 'TKC-0001', 0.0
FROM tblUser WHERE username = 'seller_a';

-- seller_b
INSERT INTO tblEmployee (tblUserid, position, salary)
SELECT id, 'Senior Ticket Clerk', 8500000
FROM tblUser WHERE username = 'seller_b';

INSERT INTO tblTicketClerk (tblUserid, code, kpi)
SELECT id, 'TKC-0002', 0.0
FROM tblUser WHERE username = 'seller_b';

-- seller_c
INSERT INTO tblEmployee (tblUserid, position, salary)
SELECT id, 'Ticket Clerk', 9000000
FROM tblUser WHERE username = 'seller_c';

INSERT INTO tblTicketClerk (tblUserid, code, kpi)
SELECT id, 'TKC-0003', 0.0
FROM tblUser WHERE username = 'seller_c';

INSERT INTO tblMovie (category, description, poster, name, active)
VALUES 
('Hành động', 'Một bộ phim hành động kịch tính với nhiều pha rượt đuổi.', '/assets/img/logo.png', 'Biệt Đội Báo Thù', 1),
('Hài', 'Phim hài gia đình vui nhộn cho cuối tuần.', '/webapp/assets/img/logo.png', 'Lật Mặt 7', 1),
('Kinh dị', 'Bộ phim kinh dị ám ảnh nhất năm 2025.', '/webapp/assets/img/logo.png', 'Ám Ảnh Kinh Hoàng', 0); -- Giả sử phim này không còn chiếu

INSERT INTO tblRoom (capacity, description, name)
VALUES 
(30, 'Phòng chiếu nhỏ, 5 hàng ghế', 'Phòng 1'),
(50, 'Phòng chiếu VIP', 'Phòng 2');

INSERT INTO tblSeat (name, position, tblRoomid, description, priceMultiplier)
VALUES 
-- Hàng A (Row A) - Giả sử đây là hàng thường
('A1', 'A-1', 1, 'Ghế hàng A', 1.0),
('A2', 'A-2', 1, 'Ghế hàng A', 1.0),
('A3', 'A-3', 1, 'Ghế hàng A', 1.2), -- Ghế giữa
('A4', 'A-4', 1, 'Ghế hàng A', 1.2), -- Ghế giữa
('A5', 'A-5', 1, 'Ghế hàng A', 1.0),
('A6', 'A-6', 1, 'Ghế hàng A', 1.0),

-- Hàng B (Row B)
('B1', 'B-1', 1, 'Ghế hàng B', 1.0),
('B2', 'B-2', 1, 'Ghế hàng B', 1.0),
('B3', 'B-3', 1, 'Ghế hàng B', 1.2), -- Ghế giữa
('B4', 'B-4', 1, 'Ghế hàng B', 1.2), -- Ghế giữa
('B5', 'B-5', 1, 'Ghế hàng B', 1.0),
('B6', 'B-6', 1, 'Ghế hàng B', 1.0),

-- Hàng C (Row C) - Giả sử đây là hàng VIP/trung tâm
('C1', 'C-1', 1, 'Ghế hàng C - VIP', 1.0),
('C2', 'C-2', 1, 'Ghế hàng C - VIP', 1.0),
('C3', 'C-3', 1, 'Ghế hàng C - VIP', 1.2), -- Ghế giữa
('C4', 'C-4', 1, 'Ghế hàng C - VIP', 1.2), -- Ghế giữa
('C5', 'C-5', 1, 'Ghế hàng C - VIP', 1.0),
('C6', 'C-6', 1, 'Ghế hàng C - VIP', 1.0),

-- Hàng D (Row D)
('D1', 'D-1', 1, 'Ghế hàng D', 1.0),
('D2', 'D-2', 1, 'Ghế hàng D', 1.0),
('D3', 'D-3', 1, 'Ghế hàng D', 1.2), -- Ghế giữa
('D4', 'D-4', 1, 'Ghế hàng D', 1.2), -- Ghế giữa
('D5', 'D-5', 1, 'Ghế hàng D', 1.0),
('D6', 'D-6', 1, 'Ghế hàng D', 1.0),

-- Hàng E (Row E)
('E1', 'E-1', 1, 'Ghế hàng E', 1.0),
('E2', 'E-2', 1, 'Ghế hàng E', 1.0),
('E3', 'E-3', 1, 'Ghế hàng E', 1.2), -- Ghế giữa
('E4', 'E-4', 1, 'Ghế hàng E', 1.2), -- Ghế giữa
('E5', 'E-5', 1, 'Ghế hàng E', 1.0),
('E6', 'E-6', 1, 'Ghế hàng E', 1.0);

INSERT INTO tblSchedule (tblMovieid, date, endTime, startTime, tblRoomid, basePrice)
VALUES 
-- Phim 'Biệt Đội Báo Thù' (id=1) chiếu tại 'Phòng 1' (id=1)
(1, '2025-10-22', '11:00:00', '09:00:00', 1, 80000.00),

-- Phim 'Lật Mặt 7' (id=2) chiếu tại 'Phòng 1' (id=1)
(2, '2025-10-22', '14:00:00', '12:00:00', 1, 85000.00),

-- Phim 'Biệt Đội Báo Thù' (id=1) chiếu tại 'Phòng 2' (id=2)
(1, '2025-10-22', '10:00:00', '08:00:00', 2, 120000.00);

-- Thêm TẤT CẢ 30 ghế của Phòng 1 (tblRoomid=1) vào Lịch chiếu 1 (tblScheduleid=1)
INSERT INTO tblSeatSchedule (tblSeatid, tblScheduleid, status)
SELECT 
    id, -- id của ghế
    1,  -- id của lịch chiếu (suất 9:00 phim Biệt Đội Báo Thù)
    1   -- status = 1 (còn trống)
FROM tblSeat
WHERE tblRoomid = 1; -- Chỉ lấy ghế của Phòng 1


-- Thêm TẤT CẢ 30 ghế của Phòng 1 (tblRoomid=1) vào Lịch chiếu 2 (tblScheduleid=2)
INSERT INTO tblSeatSchedule (tblSeatid, tblScheduleid, status)
SELECT 
    id, -- id của ghế
    2,  -- id của lịch chiếu (suất 12:00 phim Lật Mặt 7)
    1   -- status = 1 (còn trống)
FROM tblSeat
WHERE tblRoomid = 1; -- Chỉ lấy ghế của Phòng 1