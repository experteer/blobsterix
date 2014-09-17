module Blobsterix
  class AcceptType
    def self.parse(header, format)
      fields = (header || "").split(",")
      fields << (MimeMagic.by_extension(format) || MimeMagic.new("*/*")).type if format
      fields.map { |entry| AcceptType.new(entry.split(";")) }.sort { |a, b| b.score <=> a.score }
    end

    def self.get(env, format)
      parse(env["HTTP_ACCEPT"], format)
    end

    def initialize(*data)
      data = ["*/*"] if data.empty?
      @mimetype = data.flatten[0]
      set_q_factor_string(data.flatten[1] || "q=0.0")
      mediatype
      subtype
      score
    end

    def to_s
      @mimetype.to_s
    end

    def type
      @mimetype
    end

    def mediatype
      @mediatype ||= @mimetype.split("/")[0]
    end

    def subtype
      @subtype ||= @mimetype.split("/")[1]
    end

    def score
      @score ||= factor + (mediatype != "*" ? 1.0 : 0.0) + (subtype != "*" ? 1.0 : 0.0)
    end

    def factor
      @q_factor
    end

    def is?(other_type)
      return false unless other_type
      mediatype === other_type.mediatype || mediatype === "*" || other_type.mediatype === "*"
    end

    def equal?(other_type)
      return false unless other_type
      mediatype === other_type.mediatype && subtype === other_type.subtype # and factor == other_type.factor
    end

    private

    def set_q_factor_string(str)
      str.scanf("%c=%f")do|char, num|
        @q_factor = num if char === 'q'
      end
    end
  end
end
