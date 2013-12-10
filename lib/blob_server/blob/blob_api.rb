module BlobServer
	class BlobApi < AppRouterBase
		extend BlobUrlHelper

		get "/blob/v1", lambda{|env|
			Http.NotAllowed "listing blob server not allowed"
		}

		get "/blob", lambda{|env|
			Http.NotAllowed "listing blob server not allowed"
		}

		put "/blob/v1", lambda{|env|
			Http.NotAllowed "listing blob server not allowed"
		}

		put "/blob", lambda{|env|
			Http.NotAllowed "listing blob server not allowed"
		}

		get "/blob/v1/(:trafo.)*bucket_or_file.:format", lambda {|env|
			#env[nil][:trafo] = env["params"]["trafo"]
			#p "Trafo: #{env[nil][:trafo]}"
			accept = AcceptType.get(env, format(env))[0]
			data = BlobServer.transformation.run(:bucket => bucket(env), :id => file(env), :type => accept, :trafo => (env[nil][:trafo] || ""))
			data.response(true, env["HTTP_IF_NONE_MATCH"], env, env["HTTP_X_FILE"] === "yes")
		}

		get "/blob/v1/(:trafo.)*bucket_or_file", lambda {|env|
			#env[nil][:trafo] = env["params"]["trafo"]
			#p "No Format: #{env[nil][:trafo]}"
			accept = AcceptType.get(env, nil)[0]
			data = BlobServer.transformation.run(:bucket => bucket(env), :id => file(env), :type => accept, :trafo => (env[nil][:trafo] || ""))
			data.response(true, env["HTTP_IF_NONE_MATCH"], env, env["HTTP_X_FILE"] === "yes")
		}

		get "*any", lambda {|env|
			Http.NextApi
		}

		put "*any", lambda {|env|
			Http.NextApi
		}
	end
end