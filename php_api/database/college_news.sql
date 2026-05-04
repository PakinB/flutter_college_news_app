-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 04, 2026 at 04:29 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `college_news`
--

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text DEFAULT NULL,
  `summary` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `status` varchar(50) DEFAULT 'draft',
  `priority` varchar(50) DEFAULT 'normal',
  `target_type` varchar(50) DEFAULT NULL,
  `target_faculty_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `published_at` datetime DEFAULT NULL,
  `expired_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `content`, `summary`, `created_by`, `status`, `priority`, `target_type`, `target_faculty_id`, `created_at`, `updated_at`, `published_at`, `expired_at`) VALUES
(1, 'ปิดระบบชั่วคราว', 'ระบบจะปิดคืนนี้', 'แจ้งเตือนระบบ', 2, 'published', 'urgent', 'all', NULL, '2026-04-29 14:52:52', '2026-05-04 21:08:27', '2026-05-04 21:08:27', NULL),
(12, 'โครงการ \"การใช้เทคโนโลยี Generate AI\"', 'ณ ห้องประชุมรอดบางยาง ชั้น 3 ภ 2', '', 8, 'published', 'normal', 'faculty', 1, '2026-05-04 21:11:01', '2026-05-04 21:11:04', '2026-05-04 21:11:04', '2026-05-10 18:25:00'),
(13, 'ฟุตซอล กระชับมิตร คณะนิติศาสตร์', 'ฟุตซอลกระชับมิตร ระหว่าง รุ่นพี่(ศิษย์เก่า)พบกับ รุ่นน้อง\nในวันที่ 4 เมษายน 2568 เวลา 17:00 น. - 18:00น', '', 8, 'published', 'normal', 'faculty', 2, '2026-05-04 21:14:13', '2026-05-04 21:14:13', '2026-05-04 21:14:13', '2026-05-13 19:14:00'),
(14, 'Workshop วาดภาพระบายสีบนผ้า คณะนิเทศศาสตร์', 'บางแสนสุโข สุขี ณ ท่าช้าง workshop วาดภาพระบายสีบนผ้า ของคณะนิเทศศาสตร์\nวันเสาร์ที่ 7 มีนาคม 2569 เวลา 15:00 น ที่ ร้านท่าช้างบางแสน', '', 8, 'published', 'normal', 'faculty', 7, '2026-05-04 21:19:49', '2026-05-04 21:19:49', '2026-05-04 21:19:49', '2026-05-19 18:19:00'),
(15, 'โครงการมนต์เสน่ห์แห่งสงกรานต์ สุขชื่นบานศรีปทุม', 'ม่วนคัก มันส์จัด สาดความสุขต้อนรับสงกรานต์\nโครงการมนต์เสน่ห์แห่งสงกรานต์ สุขชื่นบานศรีปทุม\nในวันที่ 4 เมษายน 2568 เริ่ม 08:30น เป็นต้น ณ มหาวิทยาลัยศรีปทุม ชลบุรี', '', 8, 'published', 'normal', 'all', NULL, '2026-05-04 21:22:32', '2026-05-04 21:22:32', '2026-05-04 21:22:32', '2026-06-08 17:22:00'),
(16, 'พิธีประสาทปริญญา', 'พิธีประสาทปริญญา มหาวิทยาลัยศรีปทุม ชลบุรี ประจำปีการศึกษา 2567 \n1-31 ตุลาคม 2568\nจอง/วัดตัว/รับชุดครุย\nร้านค้าภายในมหาวิทยาลัย\n1-31 ตุลาคม 2568\nรายงารตัวผ่านเว็ปไซต์\nwww.chonburi.spu.ac.th', '', 8, 'published', 'urgent', 'all', NULL, '2026-05-04 21:26:23', '2026-05-04 21:26:23', '2026-05-04 21:26:23', '2026-05-20 17:25:00');

-- --------------------------------------------------------

--
-- Table structure for table `announcement_faculties`
--

CREATE TABLE `announcement_faculties` (
  `announcement_id` int(11) NOT NULL,
  `faculty_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcement_faculties`
--

INSERT INTO `announcement_faculties` (`announcement_id`, `faculty_id`) VALUES
(12, 1),
(13, 2),
(14, 7);

-- --------------------------------------------------------

--
-- Table structure for table `attachments`
--

CREATE TABLE `attachments` (
  `id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `file_url` varchar(255) NOT NULL,
  `file_type` varchar(50) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attachments`
--

INSERT INTO `attachments` (`id`, `announcement_id`, `file_url`, `file_type`, `uploaded_at`) VALUES
(1, 1, 'file:///C:/Users/budph/Downloads/git%20team.pdf', 'pdf', '2026-04-29 14:56:47'),
(10, 12, 'http://localhost/flutter_college_news_app/php_api/images/announcement_12_5a5ea977267c5648.jpg', 'image/jpeg', '2026-05-04 21:11:01'),
(11, 13, 'http://localhost/flutter_college_news_app/php_api/images/announcement_13_b89a0e849a8fe082.png', 'image/png', '2026-05-04 21:14:14'),
(12, 14, 'http://localhost/flutter_college_news_app/php_api/images/announcement_14_efc79f8b6e193616.png', 'image/png', '2026-05-04 21:19:49'),
(13, 15, 'http://localhost/flutter_college_news_app/php_api/images/announcement_15_e4efe30e97faea80.png', 'image/png', '2026-05-04 21:22:32'),
(14, 16, 'http://localhost/flutter_college_news_app/php_api/images/announcement_16_8ab73a83fdf248ad.png', 'image/png', '2026-05-04 21:26:23');

-- --------------------------------------------------------

--
-- Table structure for table `faculties`
--

CREATE TABLE `faculties` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `faculties`
--

INSERT INTO `faculties` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'SIT', 'คณะเทคโนโลยีสารสนเทศ', '2026-04-28 18:13:46'),
(2, 'LAW', 'คณะนิติศาสตร์', '2026-04-28 18:13:46'),
(3, 'BUS', 'คณะบริหารธุรกิจ', '2026-04-28 18:13:46'),
(4, 'SLA', 'คณะศิลปศาสตร์', '2026-04-28 18:13:46'),
(5, 'ACC', 'คณะบัญชี', '2026-04-28 18:13:46'),
(6, 'LSC', 'คณะโลจิสติกส์และซัพพลายเชน', '2026-04-28 18:13:46'),
(7, 'CA', 'คณะนิเทศศาสคร์', '2026-04-28 18:13:46');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `announcement_id` int(11) NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `sent_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `announcement_id`, `is_read`, `sent_at`) VALUES
(1, 4, 1, 0, '2026-04-29 14:54:57'),
(2, 7, 1, 0, '2026-04-29 14:54:57'),
(3, 1, 1, 0, '2026-04-29 14:54:57'),
(4, 2, 1, 0, '2026-04-29 14:54:57');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(50) DEFAULT NULL,
  `faculty_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password`, `role`, `faculty_id`, `created_at`, `updated_at`) VALUES
(1, 'Pakin', 'pakin@gmail.com', '1234567', 'user', 4, '2026-04-28 18:16:18', '2026-04-28 18:17:25'),
(2, 'test', 'test@gmail.com', '1234567', 'admin', 4, '2026-04-28 18:16:18', '2026-04-28 18:17:38'),
(4, 'test3', 'test3@gmail.com', '$2y$10$cAWeandVHoeoQcp1C8JF6ehtHwxTg7O4t8wFX1BGGYxmG19Ho71ra', NULL, NULL, '2026-04-28 20:21:36', '2026-04-28 20:21:36'),
(7, 'test4', 'test4@gmail.com', '$2y$10$MIxP4H0QSZ5dArZArKMk7Ob7N744uwPmB.3oqLm4YUxZ5YxVNEEfm', 'user', 3, '2026-04-29 12:51:41', '2026-04-29 12:51:41'),
(8, 'Admin', 'admin@gmail.com', '$2y$10$q7ZWjnJy7KGAjbVB5ec/Iuk0PZXXeZPJyrxocphh5e2PA1pu42Bo6', 'admin', 1, '2026-04-29 17:14:10', '2026-05-04 21:11:33'),
(9, 'it', 'it@gmail.com', '$2y$10$wZLEsKuS4CKpS5kYDasnPOSK7AoHeCS0bCseyfMXWF0uIeQJ5F102', 'student', 1, '2026-04-29 19:32:47', '2026-05-04 21:29:20'),
(10, 'law', 'law@gmail.com', '$2y$10$nG65LhAxT9Jn4LPSyCYC8uWgsdCHGgiD.6Mgc7sYLwKV.xxnM.yTG', 'student', 2, '2026-04-29 20:04:56', '2026-04-29 20:04:56'),
(11, 'tc', 'tc@gmail.com', '$2y$10$ZnkMbLkZiIxF3p2fByv.oOX6RV79YpAF9RNXvNyIdHw/BlKDNM3Te', 'teacher', 1, '2026-04-29 20:06:09', '2026-04-29 20:06:53'),
(12, 'pr', 'pr@gmail.com', '$2y$10$S.JaDokFSq5ysIimVg.9.uI2Skay1S2mBjWv2LDqNvJ8oAK9SFLUq', 'pr', 1, '2026-04-29 20:08:44', '2026-04-29 20:08:59'),
(13, 'em', 'em@gmail.com', '$2y$10$mULVbkX5TjRXno1LsUUmke7N9zU65lHMgxJLf/F1.ltK9zTgW/dV2', 'employee', NULL, '2026-04-30 00:04:43', '2026-05-04 21:29:13'),
(14, 'CA', 'ca@gmail.com', '$2y$10$3fZywzBCwyuhGz/PCemAfOaxROEX2vo3JV2UkltkNltmDEYnEUsaO', 'student', 7, '2026-05-04 21:27:17', '2026-05-04 21:27:17'),
(15, 'admin1', 'admin1@gmail.com', '$2y$10$kk2kT0zaGHcsJi8b/xgmXeoyqZSExS3tAMYv8.H.lf9cRoRAMWzMq', 'admin', 1, '2026-05-04 21:27:42', '2026-05-04 21:28:51');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_announcement_creator` (`created_by`),
  ADD KEY `fk_announcement_faculty` (`target_faculty_id`);

--
-- Indexes for table `announcement_faculties`
--
ALTER TABLE `announcement_faculties`
  ADD PRIMARY KEY (`announcement_id`, `faculty_id`),
  ADD KEY `idx_announcement_faculties_faculty` (`faculty_id`);

--
-- Indexes for table `attachments`
--
ALTER TABLE `attachments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_announcement_attachment` (`announcement_id`);

--
-- Indexes for table `faculties`
--
ALTER TABLE `faculties`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user` (`user_id`),
  ADD KEY `fk_announcement` (`announcement_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `fk_user_faculty` (`faculty_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `attachments`
--
ALTER TABLE `attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `faculties`
--
ALTER TABLE `faculties`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `announcements`
--
ALTER TABLE `announcements`
  ADD CONSTRAINT `fk_announcement_creator` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `fk_announcement_faculty` FOREIGN KEY (`target_faculty_id`) REFERENCES `faculties` (`id`);

--
-- Constraints for table `announcement_faculties`
--
ALTER TABLE `announcement_faculties`
  ADD CONSTRAINT `fk_announcement_faculties_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_announcement_faculties_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attachments`
--
ALTER TABLE `attachments`
  ADD CONSTRAINT `fk_announcement_attachment` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `fk_announcement` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`),
  ADD CONSTRAINT `fk_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_faculty` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
