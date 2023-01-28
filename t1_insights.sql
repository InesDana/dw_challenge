SELECT "User Name","Page Admin Top Country",pages."Facebook Id",posts_per_page.count_posts, posts_per_page.sum_likes
FROM pages
INNER JOIN (SELECT "Facebook Id",COUNT(DISTINCT index) AS count_posts, SUM("Likes") AS sum_likes FROM posts
	GROUP BY "Facebook Id") AS posts_per_page
	ON pages."Facebook Id" = posts_per_page."Facebook Id"
ORDER BY count_posts DESC, sum_likes, "Page Admin Top Country"