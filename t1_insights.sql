-- posts per page in descending order
SELECT "User Name","Page Admin Top Country",pages."Facebook Id",posts_per_page.count_posts, posts_per_page.sum_likes
FROM pages
INNER JOIN (SELECT "Facebook Id",COUNT(DISTINCT index) AS count_posts, SUM("Likes") AS sum_likes FROM posts
	GROUP BY "Facebook Id") AS posts_per_page
	ON pages."Facebook Id" = posts_per_page."Facebook Id"
ORDER BY count_posts DESC, sum_likes, "Page Admin Top Country"

-- posts and reactions summary for Deutsche Welle pages
SELECT "User Name",
	posts_per_page.count_posts, 
	posts_per_page.sum_likes,
	posts_per_page.sum_angry,
	posts_per_page.sum_interactions,
	posts_per_page.sum_interactions/posts_per_page.count_posts AS interactions_per_posts,
	to_char("Page Created", 'YYYY')
FROM pages
INNER JOIN (SELECT "Facebook Id",
				COUNT(DISTINCT index) AS count_posts, 
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
	SUM(posts_per_page.sum_interactions/posts_per_page.count_posts) AS sum_interactions_per_posts
FROM pages
INNER JOIN (SELECT "Facebook Id",
				COUNT(DISTINCT index) AS count_posts, 
				SUM("Likes") AS sum_likes ,
				SUM("Total Interactions") AS sum_interactions,
				SUM("Angry") AS sum_angry
			FROM posts
			GROUP BY "Facebook Id"
		   	) AS posts_per_page
ON pages."Facebook Id" = posts_per_page."Facebook Id"
GROUP BY "Page Admin Top Country"

select "Page Name","Page Admin Top Country" from pages WHERE "Page Name" LIKE '%DW%'