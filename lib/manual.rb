require 'json'

module Manual
  def encode_job(job)
    job.to_hash.to_json
  end

  def decode_job(encoded_job)
    JSON.parse(encoded_job).recursive_symbolized_keys
  end
end

class Hash
  def recursive_symbolized_keys
    res = {}
    self.each do |key, value|
      res[key] = case value
      when Array
        value.map { |v| v.is_a?(Hash) ? v.deep_symbolize_keys : v }
      when Hash
        value.recursive_symbolized_keys
      else
        value
      end
    end
    res
  end
end
