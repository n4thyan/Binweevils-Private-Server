-- Binweevils Private Server Rewrite
-- Keys/indexes/auto-increment export generated from bwps.sql
--
-- Import this after 001_base_schema.sql.
-- It intentionally excludes all INSERT/player/catalogue data.

-- Phase 5 account-bootstrap compatibility keys.
--
-- The original generated file was still mostly empty, which meant the clean
-- schema created users/buddylist rows without auto-incrementing ids. MySQL 8
-- then rejected local account smoke-test inserts with:
--
--   Field 'id' doesn't have a default value
--
-- Keep this pass narrow until more runtime tables are tested.

ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_username_unique` (`username`);

ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `buddylist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `buddylist_owner_name_unique` (`ownerName`);

ALTER TABLE `buddylist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
