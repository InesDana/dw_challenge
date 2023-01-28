-- change data types in original tavle from all csv files without douplicates
ALTER TABLE reports
ALTER COLUMN "Page Created" TYPE timestamp USING "Page Created"::timestamp without time zone,
ALTER COLUMN "Post Created" TYPE timestamptz USING "Post Created"::timestamp with time zone,
ALTER COLUMN "Post Created Date" TYPE date USING "Post Created Date"::date,
ALTER COLUMN "Post Created Time" TYPE time USING "Post Created Time"::time;

UPDATE reports
SET "Total Interactions" = REPLACE("Total Interactions",',','');
ALTER TABLE reports
ALTER COLUMN "Total Interactions" TYPE int USING "Total Interactions"::int;


-- create table for database from reports table
CREATE TABLE pages AS
SELECT DISTINCT "Facebook Id","User Name","Page Name", "Page Category", "Page Admin Top Country", "Page Description", "Page Created"
FROM reports;
ALTER TABLE pages 
ADD CONSTRAINT pk_u PRIMARY KEY ("Facebook Id"); 

CREATE TABLE page_categories AS
SELECT DISTINCT "Page Category" FROM reports;
ALTER TABLE page_categories
ADD CONSTRAINT pk_page_cat PRIMARY KEY ("Page Category");

CREATE TABLE page_admin_country AS
SELECT DISTINCT "Page Admin Top Country" FROM reports;
ALTER TABLE page_admin_country
ADD CONSTRAINT pk_page_admin PRIMARY KEY ("Page Admin Top Country");

ALTER TABLE pages
ADD CONSTRAINT fk_page_page_cat FOREIGN KEY ("Page Category") REFERENCES page_categories("Page Category"),
ADD CONSTRAINT fk_page_page_admin FOREIGN KEY ("Page Admin Top Country") REFERENCES page_admin_country("Page Admin Top Country");

CREATE TABLE sponsors AS
SELECT DISTINCT "Sponsor Id", "Sponsor Name", "Sponsor Category" 
FROM reports WHERE "Sponsor Id" IS NOT NULL ;
ALTER TABLE sponsors 
ADD COLUMN id_intern SERIAL PRIMARY KEY;

CREATE TABLE video_type AS
SELECT DISTINCT "Type" FROM reports;
ALTER TABLE video_type
ADD CONSTRAINT pk_type PRIMARY KEY ("Type");

CREATE TABLE video_share_stat AS
SELECT DISTINCT "Video Share Status" 
FROM reports WHERE "Video Share Status" IS NOT NULL;
ALTER TABLE video_share_stat
ADD CONSTRAINT pk_video_share PRIMARY KEY ("Video Share Status");

CREATE TABLE urls AS
SELECT DISTINCT "URL"
FROM reports WHERE "URL" IS NOT NULL;
ALTER TABLE urls
ADD CONSTRAINT pk_url PRIMARY KEY ("URL");

CREATE TABLE links AS
SELECT DISTINCT "Link", "Link Text", "Final Link"
FROM reports WHERE "Link" IS NOT NULL;
ALTER TABLE links
ADD COLUMN id_intern SERIAL PRIMARY KEY;

CREATE TABLE posts AS
SELECT index, "Facebook Id", "Likes at Posting", "Post Created", "Type", 
"Total Interactions", "Likes", "Comments", "Shares", "Love", "Wow", "Haha", "Sad", "Angry", "Care", "Video Share Status", 
"Video Length", "URL", "Message", "Description", "Overperforming Score ", "Sponsor Id", "Sponsor Category", "Link", "Link Text"
FROM reports;

ALTER TABLE posts
ADD COLUMN sponsor_id int,
ADD COLUMN link_id int;

UPDATE posts 
SET link_id = id_intern FROM links
WHERE posts."Link" = links."Link" AND posts."Link Text" = links."Link Text";

UPDATE posts 
SET sponsor_id = id_intern FROM sponsors
WHERE posts."Sponsor Id" = sponsors."Sponsor Id" AND posts."Sponsor Category" = sponsors."Sponsor Category";

ALTER TABLE posts
DROP COLUMN "Link",
DROP COLUMN "Link Text",
DROP COLUMN "Sponsor Id",
DROP COLUMN "Sponsor Category";

ALTER TABLE posts
ADD CONSTRAINT pk_posts PRIMARY KEY ("index"),
ADD CONSTRAINT fk_posts_pages FOREIGN KEY ("Facebook Id") REFERENCES pages("Facebook Id"),
ADD CONSTRAINT fk_posts_video_type FOREIGN KEY ("Type") REFERENCES video_type("Type"),
ADD CONSTRAINT fk_posts_video_share FOREIGN KEY ("Video Share Status") REFERENCES video_share_stat("Video Share Status"),
ADD CONSTRAINT fk_posts_url FOREIGN KEY ("URL") REFERENCES urls("URL"),
ADD CONSTRAINT fk_posts_links FOREIGN KEY (link_id) REFERENCES links(id_intern),
ADD CONSTRAINT fk_posts_sponsors FOREIGN KEY (sponsor_id) REFERENCES sponsors(id_intern);