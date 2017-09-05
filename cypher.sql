CREATE CONSTRAINT ON (q:Question) ASSERT q.question_id IS UNIQUE;
CREATE CONSTRAINT ON (q:Question) ASSERT q.title IS UNIQUE;
CREATE CONSTRAINT ON (t:Tag) ASSERT t.name IS UNIQUE;
CREATE CONSTRAINT ON (d:Difficulty) ASSERT d.name IS UNIQUE;

LOAD CSV WITH HEADERS FROM 'https://rawgit.com/mingqianye/leetcode-mining/master/sorted_result.csv' AS line 
WITH line, SPLIT(line.`simlilar_questions`, '|') AS simlilar_questions, SPLIT(line.`tags`, '|') AS q_tags
UNWIND simlilar_questions AS similar_question
UNWIND q_tags AS tag

MERGE (q1:Question {question_id: line.`id`, title: line.`title`})
MERGE (d:Difficulty {name: line.`difficulty`})
MERGE (q2:Question {title: similar_question})
MERGE (t:Tag {name: tag})
MERGE (q1)-[:IS_SIMILAR_TO]-(q2)
MERGE (q1)-[:HAS_DIFFICULTY]->(d)
MERGE (q1)-[:HAS_TAG]->(t);
