class JsonWebToken
  class << self
    # Encode a token with payload (customer_id, exp)
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secret_key_base)
    end
    
    # Decode a token and return the payload
    def decode(token)
      body = JWT.decode(token, Rails.application.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end
end 