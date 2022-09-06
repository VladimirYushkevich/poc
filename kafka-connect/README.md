### Kafka Connect

## Start

Create docker resources:

```
docker network create my-docker-network
```

We need to start `zookeper`, `kafka` and `kafka-connect`

```
docker-compose up -d
```

Check if it started:

```
nc -z localhost 29092
nc -z localhost 22181
nc -z localhost 8083
```

## Kafka commands

List kafka topics:

```
docker exec kafka /usr/bin/kafka-topics --bootstrap-server=localhost:29092  --list
```

Topic details:

```
docker exec kafka /usr/bin/kafka-topics --bootstrap-server=localhost:29092  --describe --topic __consumer_offsets
```

Read data:

```
docker exec kafka /usr/bin/kafka-console-consumer --bootstrap-server=localhost:29092 --topic mysql-data --from-beginning
```

Get consumer groups:

```
docker exec kafka /usr/bin/kafka-consumer-groups  --bootstrap-server localhost:29092 --list
```

Describe consumer group:

```
docker exec kafka /usr/bin/kafka-consumer-groups  --bootstrap-server localhost:29092 --describe --group console-consumer-70638
```

## Kafka connect

Create topic:

```
docker exec kafka /usr/bin/kafka-topics --bootstrap-server=localhost:29092 --create --topic mysql-data
```

Create connectors:

```
curl -XPOST -H 'Content-Type:application/json' -H 'Accept: application/json' --data-binary @./connectors/mysql-source.json localhost:8083/connectors
curl -XPOST -H 'Content-Type:application/json' -H 'Accept: application/json' --data-binary @./connectors/mysql-sink.json localhost:8083/connectors
```

Check status:

```
curl localhost:8083/connectors/mysql-source/status | jq
curl localhost:8083/connectors/mysql-sink/status | jq
```

Start reading data:

```
docker exec kafka /usr/bin/kafka-console-consumer --bootstrap-server=localhost:29092 --topic mysql-data --from-beginning
```

Create/Update record:

```
docker exec mysqldb mysql -u user --password=pass -e 'INSERT my_db.data (email) VALUES ("a@a.a");'
docker exec mysqldb mysql -u user --password=pass -e 'UPDATE my_db.data SET updatedAt = now() WHERE id = 1;'
```

See result:

```
docker exec mysqldb mysql -u user --password=pass -e 'SELECT * FROM my_db.data_changelog;'
```

## Stop

```
docker-compose down
```

## Resources

* [Full list of kafka connectors](https://docs.confluent.io/home/connect/self-managed/kafka_connectors.html)
* [Best kafka connectors](https://hevodata.com/learn/kafka-connectors/)
* [JDBC source connector](https://docs.confluent.io/kafka-connect-jdbc/current/source-connector/index.html)
* [JDBC sink connector](https://docs.confluent.io/kafka-connect-jdbc/current/sink-connector/index.html)
* [Kafka connect transformation](https://docs.confluent.io/platform/current/connect/transforms/overview.html)
* [Kafka connect REST API](https://docs.confluent.io/platform/current/connect/references/restapi.html)
