# README
This is a tiny page indexer, which support two endpoints, one for indexing page and save results to backend db "redis in this case" and another to query saved results using url.

* API
curl examples:
index:
    curl -X POST -H "Content-Type: application/json" -d '{"url":"http://www.google.com"}' localhost:3000/v1/indexpage   
query: 
    curl -X POST -H "Content-Type: application/json" -d '{"url":"http://www.google.com"}' localhost:3000/v1/query

* Ruby version
    ruby 2.3.3p222 (2016-11-21 revision 56859)
    
* System dependencies
    redis
    
* Database start
    service redis start
    
* Deployment instructions
    bundle install
    rails s
