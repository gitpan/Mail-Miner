create sequence attachments_seq;
create table attachments (
    id integer NOT NULL default nextval('attachments_seq'),
    message_id integer NOT NULL,
    filename varchar(120),
    contenttype varchar(200),
    encoding varchar(20),
    attachment TEXT,
    PRIMARY KEY (id)
);

create sequence messages_seq;
create table messages (
    id integer NOT NULL default nextval('messages_seq'),
    from_address varchar(255),
    subject varchar(255),
    received DATETIME,
    content TEXT,
    PRIMARY KEY (id)
);
create index message_from_ix on messages (from_address,id);
create index subject_ix on messages (subject,id);

create sequence assets_seq;
create table assets (
    message_id integer NOT NULL default nextval('assets_seq'),
    creator varchar(30),
    asset TEXT
);
create index creator_ix on assets (creator,message_id);
