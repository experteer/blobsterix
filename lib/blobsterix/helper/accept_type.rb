module BlobServer
	class AcceptType

		def self.parse(header, format)
			fields = (header||"").split(",")
			fields << (MimeMagic.by_extension(format) || MimeMagic.new("*/*")).type if format
			fields.map{|entry| AcceptType.new(entry.split(";"))}.sort {|a,b| b.score <=> a.score}
		end

		def self.get(env, format)
			parse(env["HTTP_ACCEPT"], format)
		end

		def initialize(*data)
			data = ["*/*"] if data.empty?
			@mimetype = data.flatten[0]
			set_q_factor_string(data[1] || "q=1.0")
			mediatype
			subtype
			score
		end

		def type()
			@mimetype
		end

		def mediatype()
			@mediatype ||= @mimetype.split("/")[0]
		end

		def subtype()
			@subtype ||= @mimetype.split("/")[1]
		end

		def score
			@score ||= @q_factor+(mediatype != "*" ? 1.0: 0.0)+(subtype != "*" ? 1.0: 0.0)
		end

		def factor
			@q_factor
		end

		def is? other_type
			mediatype === other_type.mediatype || mediatype === "*" || other_type.mediatype === "*"
		end

		def equal? other_type
			mediatype === other_type.mediatype and subtype === other_type.subtype# and factor == other_type.factor
		end

		private
		def set_q_factor_string(str)
			str.scanf("%c=%f"){|char, num|
				@q_factor = num if char === 'q'
			}
		end
	end
end