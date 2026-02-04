// json-helpers.typ
// JSON serialization utilities

/// Convert a value to JSON string representation
#let to-json-value(val) = {
  if val == none {
    "null"
  } else if type(val) == str {
    // Escape quotes and backslashes
    let escaped = val
      .replace("\\", "\\\\")
      .replace("\"", "\\\"")
      .replace("\n", "\\n")
      .replace("\r", "\\r")
      .replace("\t", "\\t")
    "\"" + escaped + "\""
  } else if type(val) == bool {
    if val { "true" } else { "false" }
  } else if type(val) == int or type(val) == float {
    str(val)
  } else if type(val) == array {
    let items = val.map(v => to-json-value(v))
    "[" + items.join(", ") + "]"
  } else if type(val) == dictionary {
    let pairs = ()
    for (k, v) in val {
      pairs.push(to-json-value(k) + ": " + to-json-value(v))
    }
    "{" + pairs.join(", ") + "}"
  } else {
    // Fallback for unknown types
    "\"" + str(val) + "\""
  }
}
