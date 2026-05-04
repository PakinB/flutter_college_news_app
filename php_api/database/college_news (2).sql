-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 04, 2026 at 01:27 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

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
(1, 'ปิดระบบชั่วคราว', 'ระบบจะปิดคืนนี้', 'แจ้งเตือนระบบ', 2, 'published', 'urgent', 'faculty', 2, '2026-04-29 14:52:52', '2026-04-29 20:04:18', '2026-04-29 20:04:18', NULL),
(3, 'LAW', 'LAW', 'LAW', 12, 'published', 'normal', 'faculty', 2, '2026-04-29 20:09:59', '2026-04-29 20:10:43', '2026-04-29 20:10:43', NULL),
(4, 'ALL', 'ALL', 'ALL', 8, 'published', 'normal', 'all', NULL, '2026-04-29 20:13:15', '2026-04-29 20:13:15', '2026-04-29 20:13:15', NULL),
(6, 'รออนุมัติ', 'รออนุมัติ', 'รออนุมัติ', 8, 'published', 'normal', 'all', NULL, '2026-04-29 21:46:43', '2026-04-29 21:46:57', '2026-04-29 21:46:57', NULL),
(7, 'testnew', 'testnew', 'testnew', 12, 'pending', 'normal', 'all', NULL, '2026-04-29 22:37:33', '2026-04-29 22:39:55', NULL, '2026-04-28 22:39:00'),
(8, 'test22', '2', '2', 11, 'published', 'normal', 'faculty', 1, '2026-04-29 22:46:44', '2026-04-29 22:47:26', '2026-04-29 22:47:26', NULL),
(9, 'nk', 'nk', 'nk', 8, 'published', 'normal', 'employee', NULL, '2026-04-30 00:06:10', '2026-04-30 00:06:27', '2026-04-30 00:06:26', NULL),
(10, 'testไฟล์+รูป', 'testไฟล์+รูป', 'testไฟล์+รูป', 8, 'published', 'normal', 'all', NULL, '2026-05-04 17:22:21', '2026-05-04 17:33:25', '2026-05-04 17:33:25', NULL),
(11, 'd', 'd', 'd', 8, 'published', 'normal', 'all', NULL, '2026-05-04 17:51:26', '2026-05-04 18:21:19', '2026-05-04 18:21:19', NULL);

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
(2, 9, 'http://localhost/flutter_college_news_app/php_api/images/announcement_9_8c7630156b63d628.png', 'image/png', '2026-04-30 00:06:10'),
(3, 10, 'http://localhost/flutter_college_news_app/php_api/images/announcement_10_7440c7b1131540c6.png', 'image/png', '2026-05-04 17:22:21'),
(4, 10, 'http://localhost/flutter_college_news_app/php_api/images/announcement_10_ba2dfc85dc8d8054.png', 'image/png', '2026-05-04 17:22:21'),
(5, 11, 'http://localhost/flutter_college_news_app/php_api/images/announcement_11_ad544ee621493f66.png', 'image/png', '2026-05-04 17:51:26'),
(6, 11, 'http://localhost/flutter_college_news_app/php_api/images/announcement_11_2c07587da8bc28b9.png', 'image/png', '2026-05-04 17:51:26'),
(7, 11, 'http://localhost/flutter_college_news_app/php_api/images/announcement_11_bb16c0d9e2a8a133.png', 'image/png', '2026-05-04 17:51:26'),
(8, 11, 'http://localhost/flutter_college_news_app/php_api/images/announcement_11_19de2844fb50b7b4.pdf', 'application/pdf', '2026-05-04 17:52:28'),
(9, 11, 'https://www.google.co.th/index.html', 'link/url', '2026-05-04 18:21:19');

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
(8, 'test5', 'test5@gmail.com', '$2y$10$q7ZWjnJy7KGAjbVB5ec/Iuk0PZXXeZPJyrxocphh5e2PA1pu42Bo6', 'admin', 1, '2026-04-29 17:14:10', '2026-04-29 17:14:34'),
(9, 'it@gmail.com', 'it@gmail.com', '$2y$10$wZLEsKuS4CKpS5kYDasnPOSK7AoHeCS0bCseyfMXWF0uIeQJ5F102', 'student', 1, '2026-04-29 19:32:47', '2026-04-29 19:32:47'),
(10, 'law', 'law@gmail.com', '$2y$10$nG65LhAxT9Jn4LPSyCYC8uWgsdCHGgiD.6Mgc7sYLwKV.xxnM.yTG', 'student', 2, '2026-04-29 20:04:56', '2026-04-29 20:04:56'),
(11, 'tc', 'tc@gmail.com', '$2y$10$ZnkMbLkZiIxF3p2fByv.oOX6RV79YpAF9RNXvNyIdHw/BlKDNM3Te', 'teacher', 1, '2026-04-29 20:06:09', '2026-04-29 20:06:53'),
(12, 'pr', 'pr@gmail.com', '$2y$10$S.JaDokFSq5ysIimVg.9.uI2Skay1S2mBjWv2LDqNvJ8oAK9SFLUq', 'pr', 1, '2026-04-29 20:08:44', '2026-04-29 20:08:59'),
(13, 'bk', 'bk@gmail.com', '$2y$10$mULVbkX5TjRXno1LsUUmke7N9zU65lHMgxJLf/F1.ltK9zTgW/dV2', 'employee', NULL, '2026-04-30 00:04:43', '2026-04-30 00:04:43');

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `attachments`
--
ALTER TABLE `attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

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
