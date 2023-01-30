-- 20 pages with most posts and avrage views per post in descending order
SELECT "User Name","Page Admin Top Country",
	pages."Facebook Id",
	posts_per_page.count_posts, 
	ROUND(posts_per_page.sum_views/posts_per_page.count_posts, 2) AS views_per_post
FROM pages
INNER JOIN (SELECT "Facebook Id",COUNT(DISTINCT index) AS count_posts, SUM("Post Views") AS sum_views FROM posts
	GROUP BY "Facebook Id") AS posts_per_page
	ON pages."Facebook Id" = posts_per_page."Facebook Id"
ORDER BY count_posts DESC, views_per_post DESC, "Page Admin Top Country"
LIMIT 20;

-- posts, views, and reactions summary for DW-pages
SELECT "User Name",
	posts_per_page.count_posts, 
	posts_per_page.sum_likes,
	posts_per_page.sum_angry,
	posts_per_page.sum_interactions,
	posts_per_page.sum_interactions/posts_per_page.count_posts AS interactions_per_posts,
	ROUND(posts_per_page.sum_views/posts_per_page.count_posts, 2) AS views_per_post,
	to_char("Page Created", 'YYYY')
FROM pages
INNER JOIN (SELECT "Facebook Id",
				COUNT(DISTINCT index) AS count_posts, 
				SUM("Post Views") AS sum_views,
				SUM("Likes") AS sum_likes ,
				SUM("Total Interactions") AS sum_interactions,
				SUM("Angry") AS sum_angry
			FROM posts
			GROUP BY "Facebook Id") AS posts_per_page
ON pages."Facebook Id" = posts_per_page."Facebook Id"
WHERE pages."Page Name" LIKE '%DW%'
ORDER BY count_posts DESC, sum_interactions;

-- posts and reactions summary grouped by Admin country
SELECT "Page Admin Top Country",
	COUNT(DISTINCT pages."Facebook Id") AS count_pages,
	SUM(posts_per_page.count_posts) AS sum_posts_pages, 
	SUM(posts_per_page.sum_likes) AS sum_posts_likes,
	SUM(posts_per_page.sum_angry) AS sum_posts_angry,
	SUM(posts_per_page.sum_interactions) AS sum_posts_interactions,
	ROUND(AVG(posts_per_page.sum_interactions/posts_per_page.count_posts),2) AS avg_interactions_per_posts,
	ROUND(AVG(posts_per_page.sum_views/posts_per_page.count_posts), 2) AS avg_views_per_post
FROM pages
INNER JOIN (SELECT "Facebook Id",
				COUNT(DISTINCT index) AS count_posts, 
				SUM("Likes") AS sum_likes ,
				SUM("Total Interactions") AS sum_interactions,
				SUM("Angry") AS sum_angry,
				SUM("Post Views") AS sum_views
			FROM posts
			GROUP BY "Facebook Id"
		   	) AS posts_per_page
ON pages."Facebook Id" = posts_per_page."Facebook Id"
GROUP BY "Page Admin Top Country";

-- views per video type
SELECT "Type",
	COUNT(DISTINCT index) AS count_posts, 
	SUM("Likes") AS sum_likes ,
	SUM("Total Interactions") AS sum_interactions,
	SUM("Angry") AS sum_angry,
	SUM("Post Views") AS sum_views,
	AVG("Video Length")
FROM posts
GROUP BY "Type";

-- sponsors
-- sponsors with 10 highest counts of posts
SELECT COUNT(DISTINCT index) AS count_posts, 
	SUM("Total Interactions") AS sum_interactions,
	s."Sponsor Name", s."Sponsor Category"
FROM posts AS p 
INNER JOIN sponsors AS s 
ON p.sponsor_id = s.id_intern
GROUP BY s."Sponsor Name", s."Sponsor Category"
ORDER BY count_posts DESC
LIMIT 10;

-- post counts per pages with sponsors
SELECT 
	"Page Name", count_posts,
	ROUND(posts_per_page.sum_interactions/posts_per_page.count_posts,2) AS interactions_per_posts,
	ROUND(posts_per_page.sum_views/posts_per_page.count_posts, 2) AS views_per_post,
	count_sponsors,sponsor_names
FROM pages
INNER JOIN (SELECT "Facebook Id",
				COUNT(DISTINCT index) AS count_posts, 
				SUM("Total Interactions") AS sum_interactions,
				SUM("Post Views") AS sum_views,
				array_agg(DISTINCT "Sponsor Name") AS sponsor_names,
				COUNT(DISTINCT sponsor_id) AS count_sponsors
			FROM posts
			INNER JOIN sponsors ON posts.sponsor_id = sponsors.id_intern
			WHERE sponsor_id IS NOT NULL
			GROUP BY "Facebook Id"
		   	) AS posts_per_page
ON pages."Facebook Id" = posts_per_page."Facebook Id"
ORDER BY count_posts DESC;