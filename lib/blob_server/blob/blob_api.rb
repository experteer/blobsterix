module BlobServer
	class BlobApi < AppRouterBase
		extend BlobUrlHelper

		get "/blob", lambda{|env|
			Http.NotAllowed "listing blob server not allowed"
		}

		get "/blob/(:trafo/):bucket/*file.:format", lambda {|env|
			#p "Trafo: #{env[nil][:trafo]}"
			accept = AcceptType.get(env, format(env))[0]
			data = BlobServer.transformation.run(:bucket => bucket(env), :id => file(env), :type => accept, :trafo => (env[nil][:trafo] || ""))
			data.response(true, env["HTTP_IF_NONE_MATCH"], env, env["HTTP_X_FILE"] === "yes")
		}

		get "/blob/(:trafo/):bucket/*file", lambda {|env|
			#p "No Format: #{env[nil][:trafo]}"
			accept = AcceptType.get(env, nil)[0]
			data = BlobServer.transformation.run(:bucket => bucket(env), :id => file(env), :type => accept, :trafo => (env[nil][:trafo] || ""))
			data.response(true, env["HTTP_IF_NONE_MATCH"], env, env["HTTP_X_FILE"] === "yes")
		}

		get "*any", lambda {|env|
			Http.NextApi
		}
	end
end