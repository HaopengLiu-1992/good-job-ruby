require 'json'
class Manual
  def encode_job(job)
    job.to_hash.to_json
  end

  def decode_job(encoded_job)
    JSON.parse(encoded_job).deep_symbolize_keys
  end
end
