-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 22, 2025 at 05:23 PM
-- Server version: 10.5.27-MariaDB-cll-lve
-- PHP Version: 8.1.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `teky6584_api_raynor`
--

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `unit_price` decimal(10,2) NOT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `name` text NOT NULL,
  `unit_price` text NOT NULL,
  `image_url` text NOT NULL,
  `quantity` text NOT NULL,
  `address` text NOT NULL,
  `metode_pembayaran` varchar(255) NOT NULL,
  `opsi_pengiriman` varchar(255) NOT NULL,
  `total_bayar` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `username`, `name`, `unit_price`, `image_url`, `quantity`, `address`, `metode_pembayaran`, `opsi_pengiriman`, `total_bayar`, `created_at`) VALUES
(42, 'test', 'Indomie', '4000', 'https://th.bing.com/th/id/OIP.kHGLHO_L8MPHyWslkSrDQwHaHa?rs=1&pid=ImgDetMain', '1', 'ffff', 'Kartu Kredit', 'Ekspres', 24000.00, '2025-01-22 09:59:49');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `nama_toko` varchar(255) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `nama_toko`, `image_url`, `description`) VALUES
(11, 'kecap', 7000.00, 'jaya', 'https://th.bing.com/th/id/R.4bc8cab089f9697c673ade25003e7c4a?rik=ZamhaA2y5G90kw&riu=http%3a%2f%2fwww.waroengindo.sg%2fimage%2fcache%2fcatalog%2fProduct%2fbango+135ml-1200x1200.png&ehk=SWa9NPjwlkQepqkIaTztPeg6rHY75ktgj6BE00%2fCpts%3d&risl=&pid=ImgRaw&r=0', 'kecap manis'),
(12, 'terigu', 15000.00, 'jaya', 'https://1.bp.blogspot.com/-tsO8BR25Z4A/XxGy6u40VjI/AAAAAAAAAFA/RI2Emd3TsIE7oWqNKlMBaX4eZXpW1yDJACLcBGAsYHQ/s1600/kunci-biru-4_5887_id.png', 'tepung terigu'),
(36, 'Gula', 15000.00, 'jaya', 'https://uploads-ssl.webflow.com/6302549cb7ad659d9d1cdcca/6304ccbac431ad542bbdbfea_Rosebrand_Gula_Pasir_Kemasan_Hijau-thumbnail-540x540.png', 'Gula pasir'),
(40, 'Minyak 1L', 38000.00, 'jaya', 'https://th.bing.com/th/id/OIP.ObGEL4Q0QM2LQNwEiXBKFQAAAA?rs=1&pid=ImgDetMain', 'Minyak goreng 1L'),
(41, 'Indomie', 4000.00, 'jaya', 'https://th.bing.com/th/id/OIP.kHGLHO_L8MPHyWslkSrDQwHaHa?rs=1&pid=ImgDetMain', 'Indomie goreng');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `nama_toko` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `password`, `created_at`, `nama_toko`, `email`, `phone`) VALUES
(14, 'we', '$2y$10$lsXqH.vFE2bEVJxQN25uxegaByFly99Joz2oz7iPY9TBZGcFvEpSm', '2025-01-13 14:35:01', 'jaya', '123@gmail.com', '2312312323'),
(16, 'qw', '$2y$10$IQ5UI9wwlKfRF8gWinbFDeqblum7UpPW0NOU4lDGuXmSTlBOGvGiS', '2025-01-15 15:21:13', '111', 'qw@gmail.com', '12435454'),
(18, 'test', '$2y$10$VGr01T5f2PGUUtCbWyjF0OrB.JK3KPARsAu0giiqdXOECZtvfjZP.', '2025-01-22 09:57:05', NULL, 'test@gmail.com', 'jsdkjedksjdksjk');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
