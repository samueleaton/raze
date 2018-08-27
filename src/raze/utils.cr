module Raze::Utils
  def self.parse_params(params : IO?)
    if params
      HTTP::Params.parse(params.gets_to_end)
    else
      HTTP::Params.parse("")
    end
  end

  def self.parse_params(params : String?)
    HTTP::Params.parse(params || "")
  end
end
