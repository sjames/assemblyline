// json-export.typ
// JSON Export functionality for AssemblyLine
// Usage: typst compile --input export-json=output.json main.typ
//        typst compile --input export-json=stdout main.typ

#import "lib.typ": __registry
#import "json-helpers.typ": to-json-value

/// Export the entire registry as JSON string
#let export-json-string() = context {
  let reg = __registry.final()

  let elements = ()
  for (id, elem) in reg {
    let obj = (
      "\"id\": " + to-json-value(elem.id),
      "\"type\": " + to-json-value(elem.type),
      "\"title\": " + to-json-value(elem.title),
      "\"tags\": " + to-json-value(elem.tags),
      "\"links\": " + to-json-value(elem.links),
      "\"parent\": " + to-json-value(elem.parent),
      "\"concrete\": " + to-json-value(elem.concrete),
      "\"group\": " + to-json-value(elem.group),
    )
    elements.push("{" + obj.join(", ") + "}")
  }

  let json = "{\n  \"elements\": [\n    "
  json += elements.join(",\n    ")
  json += "\n  ]\n}"

  json
}

/// Check if JSON export is requested and handle it
#let handle-json-export() = {
  // Check for --input export-json=... flag
  if "export-json" in sys.inputs {
    let target = sys.inputs.at("export-json")

    if target == "stdout" or target == "" {
      // Output to stdout (will appear in terminal when compiling)
      [
        #set page(margin: 0pt, height: auto)
        #set text(size: 8pt, font: "Courier New")

        ```json
        #export-json-string()
        ```
      ]
    } else {
      // Write to file
      // Note: Typst doesn't have direct file writing, so we output to the document
      // The user can extract this or pipe typst output
      [
        #set page(margin: 0pt, height: auto)
        #set text(size: 8pt, font: "Courier New")

        = JSON Export to: #target

        ```json
        #export-json-string()
        ```
      ]
    }

    // Stop processing (don't generate the full PDF)
    panic("JSON export complete. Check output for JSON data.")
  }
}
