DROP TABLE IF EXISTS `_generated_dailyAggregates`
;
CREATE TABLE `_generated_dailyAggregates` AS 
	SELECT 
		SUBSTR(app.datetime,0,11) AS date 
		,SUM(app.interval) AS dailyMinutesOn
		,SUM(app.appSwitchCount) AS dailyAppSwitchCount 
		,SUM(keyboard.keyCount) AS dailyKeyCount 
		,SUM(keyboard.keyZXCVCount) AS dailyKeyDeleteCount 
		,((SUM(keyboard.keyDeleteCount)*1.0) / SUM(keyboard.wordCount)) AS dailyDeletesPerWord 
		,SUM(keyboard.keyZXCVCount) AS dailyKeyZXCVCount 
		,SUM(keyboard.wordCount) AS dailyWordCount 
		,((SUM(keyboard.wordCount)*1.0) / SUM(app.interval)) AS dailyWordsPerMinute 
		,SUM(keyboard.keyDeleteRunCount) AS dailyKeyDeleteRunCount 
		,SUM(mouse.clickCount) AS dailyClickCount 
		,SUM(mouse.dragCount) AS dailyDragCount 
		,SUM(mouse.scrollCount) AS dailyScrollCount 
		,SUM(mouse.cursorDistance) AS dailyCursorDistance 
	FROM app 
	LEFT JOIN keyboard ON app.datetime = keyboard.datetime 
	LEFT JOIN mouse ON app.datetime = mouse.datetime 
	GROUP BY date 
	ORDER BY date
;

DROP TABLE IF EXISTS `_generated_hourlyAggregates`
;
CREATE TABLE `_generated_hourlyAggregates` AS 
	SELECT 
		SUBSTR(app.datetime,0,14) AS dateHour 
		,SUM(app.interval) AS hourlyMinutesOn
		,SUM(app.appSwitchCount) AS hourlyAppSwitchCount 
		,SUM(keyboard.keyCount) AS hourlyKeyCount 
		,SUM(keyboard.keyZXCVCount) AS hourlyKeyDeleteCount 
		,((SUM(keyboard.keyDeleteCount)*1.0) / SUM(keyboard.wordCount)) AS hourlyDeletesPerWord 
		,SUM(keyboard.keyZXCVCount) AS hourlyKeyZXCVCount 
		,SUM(keyboard.wordCount) AS hourlyWordCount 
		,((SUM(keyboard.wordCount)*1.0) / SUM(app.interval)) AS hourlyWordsPerMinute 
		,SUM(keyboard.keyDeleteRunCount) AS hourlyKeyDeleteRunCount 
		,SUM(mouse.clickCount) AS hourlyClickCount 
		,SUM(mouse.dragCount) AS hourlyDragCount 
		,SUM(mouse.scrollCount) AS hourlyScrollCount 
		,SUM(mouse.cursorDistance) AS hourlyCursorDistance 
	FROM app 
	LEFT JOIN keyboard ON app.datetime = keyboard.datetime 
	LEFT JOIN mouse ON app.datetime = mouse.datetime 
	GROUP BY dateHour 
	ORDER BY dateHour
;

DROP TABLE IF EXISTS `_generated_dailyMaxAggregates`
;
CREATE TABLE `_generated_dailyMaxAggregates` AS
	SELECT 'dailyMinutesOn' AS field,MAX(dailyMinutesOn) AS max,date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyAppSwitchCount',MAX(dailyAppSwitchCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyKeyCount',MAX(dailyKeyCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyKeyDeleteCount',MAX(dailyKeyDeleteCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyDeletesPerWord',MAX(dailyDeletesPerWord),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyKeyZXCVCount',MAX(dailyKeyZXCVCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyWordCount',MAX(dailyWordCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyWordsPerMinute',MAX(dailyWordsPerMinute),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyKeyDeleteRunCount',MAX(dailyKeyDeleteRunCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyClickCount',MAX(dailyClickCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyDragCount',MAX(dailyDragCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyScrollCount',MAX(dailyScrollCount),date FROM _generated_dailyAggregates
	UNION
	SELECT 'dailyCursorDistance',MAX(dailyCursorDistance),date FROM _generated_dailyAggregates
;

DROP TABLE IF EXISTS `_generated_hourlyMaxAggregates`
;
CREATE TABLE `_generated_hourlyMaxAggregates` AS
	SELECT 'hourlyMinutesOn' AS field,MAX(hourlyMinutesOn) AS max,dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyAppSwitchCount',MAX(hourlyAppSwitchCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyKeyCount',MAX(hourlyKeyCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyKeyDeleteCount',MAX(hourlyKeyDeleteCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyDeletesPerWord',MAX(hourlyDeletesPerWord),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyKeyZXCVCount',MAX(hourlyKeyZXCVCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyWordCount',MAX(hourlyWordCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyWordsPerMinute',MAX(hourlyWordsPerMinute),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyKeyDeleteRunCount',MAX(hourlyKeyDeleteRunCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyClickCount',MAX(hourlyClickCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyDragCount',MAX(hourlyDragCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyScrollCount',MAX(hourlyScrollCount),dateHour FROM _generated_hourlyAggregates
	UNION
	SELECT 'hourlyCursorDistance',MAX(hourlyCursorDistance),dateHour FROM _generated_hourlyAggregates
;
