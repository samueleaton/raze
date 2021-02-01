require "kilt"

# halt_plain, halt_json, halt_html

macro render(filename)
  Kilt.render({{filename}})
end
