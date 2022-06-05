# Tmux script to play with litestream live replication

## Part 1: Install litestrem beta

For now the latest release does not have this feature.

```
git clone https://benbjohnson/litestream
cd litestream

# build litestream
LITESTREAM_VERSION=0.4.0 go build -v -ldflags "-s -w -X 'main.Version=${LITESTREAM_VERSION}'"  -o dist/litestream ./cmd/litestream

# install litestream
cp dist/litestream ../bin
```

## Part 2: run litestream and play

`launcher.sh` includes the steps to run the primary and secondary litestream instances. 
There are 4 terminals configured to enable easy play.

Run `./launcher.sh` and then from the sqlite3 instances:

```
# in primary sqlite
sqlite> create table foo (id integer not null primary key, name varchar(55));

# in secondary sqlite
sqlite> select * from foo; # empty
sqlite> 

# in primary sqlite
sqlite> insert into foo (name) values ('bob');

# in secondary sqlite
sqlite> select * from foo; # returns boo
│1|bob
sqlite> 
```
