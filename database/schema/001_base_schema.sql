-- Binweevils Private Server Rewrite
-- Schema-only export generated from bwps.sql
--
-- This file contains CREATE TABLE statements only.
-- It intentionally excludes all INSERT/player/catalogue data.
-- Keep legacy table names until PHP/runtime compatibility has been tested.

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- --------------------------------------------------------

--
-- Table structure for table `achievementcounters`
--

CREATE TABLE `achievementcounters` (
  `id` int(11) NOT NULL,
  `idx` int(11) NOT NULL,
  `counterId` int(11) NOT NULL,
  `counter` int(11) NOT NULL,
  `lastUpdated` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievements`
--

CREATE TABLE `achievements` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `typeId` int(11) NOT NULL,
  `order` int(11) NOT NULL,
  `module` text NOT NULL,
  `descriptionForMe` text NOT NULL,
  `descriptionForVisitors` text NOT NULL,
  `counterValue` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievementscompleted`
--

CREATE TABLE `achievementscompleted` (
  `id` int(11) NOT NULL,
  `idx` int(11) NOT NULL,
  `achievementId` mediumtext NOT NULL DEFAULT '1',
  `completedDate` date NOT NULL DEFAULT current_timestamp(),
  `is_it_new` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievementtags`
--

CREATE TABLE `achievementtags` (
  `id` int(11) NOT NULL,
  `tags` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievementtypes`
--

CREATE TABLE `achievementtypes` (
  `id` int(11) NOT NULL,
  `order` int(11) NOT NULL,
  `name` text NOT NULL,
  `colour` int(11) NOT NULL,
  `imageName` text NOT NULL,
  `description` text NOT NULL,
  `isLive` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `achievementtypetags`
--

CREATE TABLE `achievementtypetags` (
  `id` int(11) NOT NULL,
  `typeId` int(11) NOT NULL,
  `tagId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `appareltypes`
--

CREATE TABLE `appareltypes` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `name` text NOT NULL,
  `description` text NOT NULL,
  `paletteId` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `probability` int(11) NOT NULL,
  `minLevel` int(11) NOT NULL,
  `tycoonOnly` int(11) NOT NULL,
  `isLive` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bubblecompetitions`
--

CREATE TABLE `bubblecompetitions` (
  `id` int(11) NOT NULL,
  `compID` varchar(255) NOT NULL,
  `huntName` varchar(255) NOT NULL,
  `active` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `bubblehunts`
--

CREATE TABLE `bubblehunts` (
  `id` int(11) NOT NULL,
  `userID` varchar(255) NOT NULL,
  `compID` varchar(255) NOT NULL,
  `itemID` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `buddyalerts`
--

CREATE TABLE `buddyalerts` (
  `id` int(11) NOT NULL,
  `weevil` varchar(255) NOT NULL,
  `message` varchar(255) NOT NULL,
  `iconPath` varchar(255) NOT NULL,
  `time` int(255) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `buddylist`
--

CREATE TABLE `buddylist` (
  `id` int(11) NOT NULL,
  `ownerName` varchar(255) NOT NULL,
  `namesList` longtext NOT NULL DEFAULT '',
  `blockList` longtext NOT NULL DEFAULT '',
  `requestList` longtext NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `camerapics`
--

CREATE TABLE `camerapics` (
  `id` int(11) NOT NULL,
  `userIDX` int(11) NOT NULL,
  `fileName` text NOT NULL,
  `size` int(11) NOT NULL DEFAULT 1,
  `status` int(11) NOT NULL DEFAULT 1,
  `inCamera` int(11) NOT NULL DEFAULT 1,
  `inMagInProgress` int(11) NOT NULL DEFAULT 0,
  `inMagPublished` int(11) NOT NULL DEFAULT 0,
  `removedByMod` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `colourpalettes`
--

CREATE TABLE `colourpalettes` (
  `id` int(11) NOT NULL,
  `hexcolour` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `crosswords`
--

CREATE TABLE `crosswords` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `minLevel` int(11) NOT NULL DEFAULT 0,
  `configPath` text NOT NULL,
  `mulchReward` int(11) NOT NULL DEFAULT 400,
  `xpReward` int(11) NOT NULL DEFAULT 30
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `crossworduserprogress`
--

CREATE TABLE `crossworduserprogress` (
  `id` int(11) NOT NULL,
  `userID` text NOT NULL,
  `completed` int(11) NOT NULL DEFAULT 0,
  `gridID` int(11) NOT NULL,
  `progress` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `development`
--

CREATE TABLE `development` (
  `id` int(11) NOT NULL,
  `icon` text NOT NULL,
  `task` text NOT NULL,
  `status` text NOT NULL,
  `task-description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `game-logs`
--

CREATE TABLE `game-logs` (
  `id` int(11) NOT NULL,
  `weevilName` varchar(255) NOT NULL,
  `apiExecuted` varchar(255) DEFAULT NULL,
  `bannedUntil` varchar(255) DEFAULT NULL,
  `bannedFrom` varchar(255) DEFAULT NULL,
  `adminName` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `itemId` text DEFAULT NULL,
  `reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `game-rewards`
--

CREATE TABLE `game-rewards` (
  `id` int(11) NOT NULL,
  `idx` int(11) NOT NULL,
  `flumsMulch` varchar(255) NOT NULL DEFAULT '',
  `flumsXp` varchar(255) NOT NULL DEFAULT '',
  `flingXp` varchar(255) NOT NULL DEFAULT '',
  `castleMulch` varchar(255) NOT NULL DEFAULT '',
  `doshMulch` varchar(255) NOT NULL DEFAULT '',
  `tinkSeed` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gamebraintraining`
--

CREATE TABLE `gamebraintraining` (
  `qType` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `idx` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gameinvites`
--

CREATE TABLE `gameinvites` (
  `id` int(11) NOT NULL,
  `referrer` varchar(255) DEFAULT NULL,
  `weevil` varchar(255) DEFAULT NULL,
  `awarded` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gardeninventory`
--

CREATE TABLE `gardeninventory` (
  `id` int(11) NOT NULL,
  `ownerName` varchar(255) NOT NULL,
  `itemid` int(11) NOT NULL,
  `itemtype` int(11) NOT NULL,
  `colour` varchar(255) NOT NULL DEFAULT '-1',
  `isInGarden` int(11) NOT NULL DEFAULT 0,
  `roomid` int(11) NOT NULL DEFAULT 0,
  `plantedUnix` varchar(255) DEFAULT NULL,
  `x` int(11) NOT NULL DEFAULT 0,
  `z` int(11) NOT NULL DEFAULT 0,
  `r` int(11) NOT NULL DEFAULT 0,
  `wateredUnix` varchar(255) NOT NULL DEFAULT '',
  `harvestUnix` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `gardenitemtype`
--

CREATE TABLE `gardenitemtype` (
  `itemTypeID` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `configLocation` text COLLATE utf8_unicode_ci NOT NULL,
  `paletteId` int(11) NOT NULL,
  `defaultHexcolour` text COLLATE utf8_unicode_ci NOT NULL,
  `currency` text COLLATE utf8_unicode_ci NOT NULL,
  `price` int(11) NOT NULL,
  `previousCurrency` text COLLATE utf8_unicode_ci NOT NULL,
  `probability` int(11) NOT NULL,
  `name` text COLLATE utf8_unicode_ci NOT NULL,
  `description` text COLLATE utf8_unicode_ci NOT NULL,
  `expPoints` int(11) NOT NULL,
  `powerConsumption` int(11) NOT NULL,
  `boundRadius` int(11) NOT NULL,
  `minLevel` int(11) NOT NULL,
  `tycoonOnly` int(11) NOT NULL,
  `canDelete` int(11) NOT NULL,
  `canGroup` int(11) NOT NULL,
  `isLive` int(11) NOT NULL,
  `internalCategory` text COLLATE utf8_unicode_ci NOT NULL,
  `coolness` int(11) NOT NULL,
  `canBuy` int(11) NOT NULL DEFAULT 1,
  `purchases` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `itemtype`
--

CREATE TABLE `itemtype` (
  `itemTypeID` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `configLocation` varchar(255) NOT NULL,
  `shopType` varchar(255) NOT NULL DEFAULT 'nestco',
  `paletteId` int(11) NOT NULL DEFAULT -1,
  `defaultHexcolour` varchar(255) NOT NULL DEFAULT '-1',
  `currency` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `previousCurrency` varchar(255) DEFAULT NULL,
  `previousPrice` int(11) DEFAULT NULL,
  `probability` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `tags` varchar(255) NOT NULL,
  `description` varchar(255) NOT NULL,
  `deliveryTime` int(11) DEFAULT NULL,
  `expPoints` int(11) NOT NULL DEFAULT 0,
  `powerConsumption` int(11) DEFAULT NULL,
  `boundRadius` int(11) DEFAULT NULL,
  `collectionID` int(11) DEFAULT NULL,
  `minLevel` int(11) NOT NULL DEFAULT 1,
  `tycoonOnly` int(11) NOT NULL DEFAULT 0,
  `canDelete` int(11) DEFAULT NULL,
  `canGroup` int(11) DEFAULT NULL,
  `isLive` int(11) DEFAULT NULL,
  `internalCategory` varchar(255) DEFAULT NULL,
  `coolness` int(11) DEFAULT NULL,
  `ordering` int(11) DEFAULT NULL,
  `purchases` int(11) NOT NULL DEFAULT 0,
  `canBuy` int(11) NOT NULL DEFAULT 1,
  `canReward` int(11) NOT NULL DEFAULT 0,
  `requiresActivation` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `itemtypets`
--

CREATE TABLE `itemtypets` (
  `itemTypeID` int(11) NOT NULL,
  `fileName` text NOT NULL,
  `name` text NOT NULL,
  `description` text NOT NULL,
  `xp` int(11) NOT NULL DEFAULT 0,
  `minLevel` int(11) NOT NULL DEFAULT 3,
  `price` int(11) NOT NULL DEFAULT 0,
  `currency` text NOT NULL DEFAULT 'mulch',
  `internalCategory` text NOT NULL,
  `category` int(11) NOT NULL,
  `inventoryCategory` int(11) NOT NULL,
  `defaultHexColor` varchar(100) NOT NULL DEFAULT '-1',
  `probability` int(11) NOT NULL DEFAULT 127,
  `canBuy` int(11) NOT NULL DEFAULT 1,
  `purchases` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `leaderboardgames`
--

CREATE TABLE `leaderboardgames` (
  `id` int(11) NOT NULL,
  `game` varchar(255) NOT NULL,
  `maxScore` int(11) NOT NULL,
  `mulchReward` float NOT NULL DEFAULT 0,
  `xpReward` float NOT NULL DEFAULT 0,
  `itemReward` smallint(11) NOT NULL DEFAULT 0,
  `seedReward` smallint(11) DEFAULT 0,
  `eventPostTypeId` int(11) DEFAULT NULL,
  `minDelaySecs` int(11) DEFAULT 0,
  `max_mulch_per_day` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `leaderboardhighscores`
--

CREATE TABLE `leaderboardhighscores` (
  `id` int(11) NOT NULL,
  `gameId` int(11) NOT NULL,
  `playerIdx` int(11) NOT NULL,
  `highScore` int(11) NOT NULL,
  `lastTime` date NOT NULL,
  `highScoreTime` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `levels`
--

CREATE TABLE `levels` (
  `level` int(11) NOT NULL,
  `xpRequired` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `multiplayergames`
--

CREATE TABLE `multiplayergames` (
  `id` int(11) NOT NULL,
  `weevil` varchar(255) NOT NULL,
  `game` int(11) NOT NULL,
  `gamekey` varchar(255) NOT NULL,
  `lastplayed` bigint(20) NOT NULL DEFAULT 0,
  `wins` int(11) NOT NULL DEFAULT 0,
  `losses` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `nest`
--

CREATE TABLE `nest` (
  `id` int(11) NOT NULL,
  `ownerName` varchar(255) NOT NULL,
  `idx` int(11) NOT NULL,
  `lastUpdate` datetime NOT NULL DEFAULT current_timestamp(),
  `score` bigint(20) NOT NULL DEFAULT 0,
  `fuel` bigint(20) NOT NULL DEFAULT 80000,
  `gardenSize` int(11) NOT NULL DEFAULT 1,
  `dailyHarvest` varchar(255) NOT NULL DEFAULT '0,0',
  `plazaTimer` int(11) NOT NULL DEFAULT 0,
  `plantTimer` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `nestinfo`
--

CREATE TABLE `nestinfo` (
  `Weevil` varchar(255) NOT NULL,
  `locID` int(11) NOT NULL,
  `roomID` int(11) NOT NULL,
  `colour` text NOT NULL DEFAULT '0|0|0',
  `busOpen` int(11) NOT NULL DEFAULT 1,
  `signTxtClr` varchar(255) NOT NULL DEFAULT '-1',
  `signClr` varchar(255) NOT NULL DEFAULT '-1',
  `name` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `newspaperissues`
--

CREATE TABLE `newspaperissues` (
  `uniqueID` int(11) NOT NULL,
  `newspaperID` int(11) NOT NULL,
  `issueNum` int(11) NOT NULL,
  `issueName` text NOT NULL,
  `xml` int(11) NOT NULL,
  `published` int(11) NOT NULL,
  `approved` int(11) NOT NULL,
  `timestamp` date NOT NULL,
  `views` int(11) NOT NULL,
  `mark` int(11) NOT NULL,
  `votes` int(11) NOT NULL,
  `sticky` int(11) NOT NULL,
  `crispScore` int(11) NOT NULL,
  `moderatorName` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `newspapers`
--

CREATE TABLE `newspapers` (
  `newspaperID` int(11) NOT NULL,
  `userIDX` int(11) NOT NULL,
  `newspaperName` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `petacquiredskills`
--

CREATE TABLE `petacquiredskills` (
  `id` int(11) NOT NULL,
  `ownerID` varchar(255) NOT NULL,
  `petID` int(11) NOT NULL,
  `skillID` int(11) NOT NULL,
  `obedience` int(11) NOT NULL,
  `skillLevel` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pets`
--

CREATE TABLE `pets` (
  `id` int(11) NOT NULL,
  `ownerID` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `bedID` int(11) NOT NULL,
  `bowlID` int(11) NOT NULL,
  `bc` int(11) NOT NULL,
  `ac1` int(11) NOT NULL,
  `ac2` int(11) NOT NULL,
  `ec1` int(11) NOT NULL,
  `ec2` int(11) NOT NULL,
  `fuel` int(11) NOT NULL,
  `mentalEnergy` int(11) NOT NULL,
  `health` int(11) NOT NULL,
  `fitness` int(11) NOT NULL,
  `experience` int(11) NOT NULL,
  `adoptedDate` varchar(255) NOT NULL,
  `nameHash` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `puzzletypes`
--

CREATE TABLE `puzzletypes` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `gamePath` text NOT NULL,
  `configBasePath` text NOT NULL,
  `locName` text NOT NULL,
  `mainTableName` varchar(255) NOT NULL,
  `progressTableName` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `quests`
--

CREATE TABLE `quests` (
  `id` int(11) NOT NULL,
  `room` int(11) DEFAULT 0,
  `name` text NOT NULL,
  `UIpath` text DEFAULT NULL,
  `tycoonOnly` int(11) DEFAULT 1,
  `scoreBronze` int(11) DEFAULT 0,
  `scoreSilver` int(11) DEFAULT 0,
  `scoreGold` int(11) DEFAULT 0,
  `scorePlatinum` int(11) DEFAULT 0,
  `minLevel` int(11) DEFAULT 0,
  `price` int(11) DEFAULT 0,
  `isLive` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `questscompleted`
--

CREATE TABLE `questscompleted` (
  `id` int(11) NOT NULL,
  `idx` int(11) NOT NULL,
  `questID` int(11) NOT NULL,
  `highScore` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `questtasks`
--

CREATE TABLE `questtasks` (
  `id` int(11) NOT NULL,
  `questID` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `mulchReward` int(11) DEFAULT NULL,
  `doshReward` int(11) DEFAULT NULL,
  `xpReward` int(11) DEFAULT NULL,
  `itemReward` int(11) DEFAULT NULL,
  `eventPostTypeId` int(11) DEFAULT NULL,
  `taskType` text NOT NULL,
  `maxScore` int(11) DEFAULT NULL,
  `complete` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `redeemedcodes`
--

CREATE TABLE `redeemedcodes` (
  `id` int(11) NOT NULL,
  `useridx` int(11) NOT NULL,
  `code` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `rewardcodes`
--

CREATE TABLE `rewardcodes` (
  `id` int(11) NOT NULL,
  `code` text DEFAULT NULL,
  `item` int(11) DEFAULT NULL,
  `xp` int(11) NOT NULL DEFAULT 0,
  `mulch` int(11) NOT NULL DEFAULT 0,
  `seed` int(11) NOT NULL DEFAULT 0,
  `dosh` int(11) NOT NULL DEFAULT 0,
  `gardenItem` int(11) NOT NULL DEFAULT 0,
  `notes` text DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `redeemable` int(11) NOT NULL DEFAULT 1,
  `quantity` int(11) NOT NULL DEFAULT 999999999
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `seeds`
--

CREATE TABLE `seeds` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL DEFAULT 1,
  `tycoon` int(11) NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL,
  `fileName` text COLLATE utf8_unicode_ci NOT NULL,
  `name` text COLLATE utf8_unicode_ci NOT NULL,
  `price` int(11) NOT NULL,
  `mulchYield` int(11) NOT NULL,
  `xpYield` int(11) NOT NULL,
  `growTime` int(11) NOT NULL,
  `cycleTime` int(11) NOT NULL,
  `probability` int(11) NOT NULL,
  `radius` int(11) NOT NULL,
  `canBuy` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `singleplayergames`
--

CREATE TABLE `singleplayergames` (
  `gameID` int(11) NOT NULL,
  `gameName` text NOT NULL,
  `maxScore` int(11) NOT NULL,
  `mulchFactor` text NOT NULL,
  `xpFactor` text NOT NULL,
  `minXp` int(11) NOT NULL,
  `minMulch` int(11) NOT NULL,
  `isLive` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `singleplayergames_stats`
--

CREATE TABLE `singleplayergames_stats` (
  `userIdx` int(11) NOT NULL,
  `gameID` int(11) NOT NULL,
  `numPlays` int(11) NOT NULL,
  `bestScore` int(11) NOT NULL,
  `averageScore` int(11) NOT NULL,
  `last_played` varchar(255) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `specialmoves`
--

CREATE TABLE `specialmoves` (
  `id` int(11) NOT NULL,
  `weevilID` text NOT NULL,
  `moves` int(11) NOT NULL,
  `idx` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `task-completed`
--

CREATE TABLE `task-completed` (
  `taskID` int(11) NOT NULL,
  `questID` int(11) DEFAULT NULL,
  `score` int(11) NOT NULL,
  `mulchRewarded` int(11) NOT NULL,
  `xpRewarded` int(11) NOT NULL,
  `doshRewarded` int(11) NOT NULL,
  `itemNameRewarded` int(11) DEFAULT 0,
  `gardenItemNameRewarded` int(11) DEFAULT 0,
  `moveRewarded` varchar(11) COLLATE utf8_unicode_ci DEFAULT '',
  `deleted` varchar(11) COLLATE utf8_unicode_ci DEFAULT '',
  `completedAchievementsRewarded` varchar(11) COLLATE utf8_unicode_ci DEFAULT '',
  `bundleNameRewarded` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `requiresTycoon` int(11) DEFAULT 0,
  `canReward` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `task-completed2`
--

CREATE TABLE `task-completed2` (
  `taskID` int(11) NOT NULL,
  `questID` int(11) DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `mulchReward` int(11) DEFAULT NULL,
  `xpReward` int(11) DEFAULT NULL,
  `doshReward` int(11) DEFAULT NULL,
  `itemReward` int(11) DEFAULT NULL,
  `eventPostTypeId` int(11) DEFAULT NULL,
  `taskType` text COLLATE utf8_unicode_ci NOT NULL DEFAULT 'complete',
  `maxScore` int(11) DEFAULT NULL,
  `complete` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `taskscompletedbyusers`
--

CREATE TABLE `taskscompletedbyusers` (
  `id` int(11) NOT NULL,
  `weevilName` text NOT NULL,
  `tasks` text NOT NULL,
  `questID` int(11) DEFAULT NULL,
  `isComplete` int(11) DEFAULT 1,
  `idx` int(11) NOT NULL DEFAULT 0,
  `highScore` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `trackdetails`
--

CREATE TABLE `trackdetails` (
  `trackID` int(11) NOT NULL,
  `file` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `artist` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tycoonbusinesses`
--

CREATE TABLE `tycoonbusinesses` (
  `id` int(11) NOT NULL,
  `businessType` int(11) NOT NULL,
  `businessName` varchar(255) NOT NULL,
  `belongsTo` varchar(255) NOT NULL,
  `currencyType` int(11) NOT NULL,
  `total` int(11) NOT NULL DEFAULT 0,
  `collected` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `isModerator` int(11) NOT NULL DEFAULT 0,
  `sessionKey` varchar(255) NOT NULL,
  `loginKey` varchar(255) NOT NULL,
  `level` int(11) NOT NULL DEFAULT 1,
  `mulch` int(20) NOT NULL DEFAULT 5000,
  `dosh` int(255) NOT NULL DEFAULT 25,
  `tycoon` int(11) NOT NULL DEFAULT 1,
  `def` varchar(255) NOT NULL DEFAULT '101101406100171700',
  `xp` bigint(25) NOT NULL DEFAULT 0,
  `xp1` int(20) NOT NULL DEFAULT 0,
  `xp2` int(20) NOT NULL DEFAULT 30,
  `food` int(11) NOT NULL DEFAULT 100,
  `canSpeak` varchar(255) DEFAULT '0',
  `activated` int(11) NOT NULL DEFAULT 0,
  `lastLogin` bigint(20) NOT NULL,
  `curHat` varchar(255) NOT NULL DEFAULT '|1:-140,-140,-140',
  `invitedBy` text DEFAULT NULL,
  `active` int(11) NOT NULL DEFAULT 1,
  `bannedUntil` int(11) NOT NULL DEFAULT 0,
  `createdAt` bigint(20) NOT NULL,
  `loginIP` text DEFAULT NULL,
  `regIP` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `weevilgames`
--

CREATE TABLE `weevilgames` (
  `id` int(11) NOT NULL,
  `weevil` varchar(255) NOT NULL,
  `game` int(11) NOT NULL,
  `plays` int(11) NOT NULL DEFAULT 0,
  `total` int(11) DEFAULT 0,
  `lap1` int(11) DEFAULT 0,
  `lap2` int(11) DEFAULT 0,
  `lap3` int(11) DEFAULT 0,
  `lastplayed` varchar(255) DEFAULT '0',
  `key` varchar(255) DEFAULT '',
  `bronze` int(11) NOT NULL DEFAULT 0,
  `silver` int(11) NOT NULL DEFAULT 0,
  `gold` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `weevilhats`
--

CREATE TABLE `weevilhats` (
  `1` int(11) NOT NULL,
  `apparelId` int(11) NOT NULL,
  `ownerName` varchar(255) NOT NULL,
  `colour` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `weevilitems`
--

CREATE TABLE `weevilitems` (
  `ID` int(11) NOT NULL,
  `weevilID` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `colour` varchar(255) NOT NULL DEFAULT '0',
  `category` int(11) NOT NULL DEFAULT 0,
  `isInRoom` int(11) NOT NULL DEFAULT 0,
  `configName` varchar(255) NOT NULL,
  `roomId` int(11) NOT NULL DEFAULT 0,
  `position` int(11) NOT NULL DEFAULT 1,
  `fID` int(11) NOT NULL DEFAULT 0,
  `spot` int(11) NOT NULL DEFAULT 0,
  `internalCategory` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `wordsearches`
--

CREATE TABLE `wordsearches` (
  `id` int(11) NOT NULL,
  `name` text NOT NULL,
  `minLevel` int(11) NOT NULL DEFAULT 0,
  `configPath` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `wordsearchuserprogress`
--

CREATE TABLE `wordsearchuserprogress` (
  `id` int(11) NOT NULL,
  `userID` text NOT NULL,
  `completed` int(11) NOT NULL DEFAULT 0,
  `gridID` int(11) NOT NULL,
  `progress` longtext NOT NULL,
  `wordsFound` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
