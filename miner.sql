create table attachments (
    id integer NOT NULL AUTO_INCREMENT,
    message_id integer NOT NULL,
    filename varchar(120),
    contenttype varchar(200),
    attachment LONGTEXT,
    PRIMARY KEY (id)
);

create table messages (
    id integer NOT NULL AUTO_INCREMENT,
    from_address varchar(255),
    subject varchar(255),
    received DATETIME,
    content LONGTEXT,
    PRIMARY KEY (id)
);

create table assets (
    message_id integer NOT NULL,
    creator varchar(30),
    asset LONGTEXT,
);
