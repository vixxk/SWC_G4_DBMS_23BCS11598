SELECT
    mdf.date,
    SUM(CASE WHEN mad.paying_customer = 'no' THEN mdf.downloads ELSE 0 END) AS non_paying_downloads,
    SUM(CASE WHEN mad.paying_customer = 'yes' THEN mdf.downloads ELSE 0 END) AS paying_downloads
FROM ms_download_facts mdf
JOIN ms_user_dimension mud
    ON mdf.user_id = mud.user_id
JOIN ms_acc_dimension mad
    ON mud.acc_id = mad.acc_id
GROUP BY mdf.date
HAVING SUM(CASE WHEN mad.paying_customer = 'no' THEN mdf.downloads ELSE 0 END)
     > SUM(CASE WHEN mad.paying_customer = 'yes' THEN mdf.downloads ELSE 0 END)
ORDER BY mdf.date;