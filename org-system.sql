CREATE TABLE `organizations` (
  `id` int(11) NOT NULL,
  `org_name` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `orgmembers` (
  `id` int(11) NOT NULL,
  `identifier` varchar(255) NOT NULL,
  `org_name` varchar(255) NOT NULL,
  `rank` int(11) NOT NULL,
  `characterName` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `org_markers` (
  `id` int(11) NOT NULL,
  `org_name` varchar(255) DEFAULT NULL,
  `markerName` varchar(255) DEFAULT NULL,
  `x` varchar(255) DEFAULT NULL,
  `y` varchar(255) DEFAULT NULL,
  `z` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `organizations`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `orgmembers`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `org_markers`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `organizations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `orgmembers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

ALTER TABLE `org_markers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;