DROP TABLE IF EXISTS my_db.data;

CREATE TABLE my_db.data
(
    id        INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email     VARCHAR(50),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    timestampOne TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    timestampTwo TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS my_db.data_changelog;

CREATE TABLE my_db.data_changelog
(
    data_id        INT(6) PRIMARY KEY,
    email     VARCHAR(50),
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);