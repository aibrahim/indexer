require 'json'
module Api::V1
    class IndexingController < ApplicationController
        skip_before_filter :verify_authenticity_token

	    def indexpage
		    url = params["url"]
            indexer_results = Indexing.process_prefered(url)
            index_status = indexer_results[:status]
            index_msg = indexer_results[:msg]
            if index_status == 200 or index_status == 201
                final = Indexing.save_to_redis(url, index_msg)
                status = final[:status]
                res = final[:msg]
                render json: {msg: res}.to_json, status: status
            else
                render json: {msg: index_msg}.to_json, status: index_status
            end

        end
	
	    def query
		    url = params["url"]
            query_results = Indexing.query(url)
            status = query_results[:status]
            res = query_results[:msg]
            if status == 200 or status == 201
                render json: res.to_json, status: status
            else
                render json: {msg: res}.to_json, status: status
            end
	    end
    end
end 
