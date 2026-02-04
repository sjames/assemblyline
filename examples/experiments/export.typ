// export.typ
// Standalone JSON exporter for AssemblyLine
// Usage: typst compile export.typ export.pdf
//        Then extract JSON from the PDF, or use typst-svg output

#import "../packages/preview/assemblyline/main/lib/lib.typ": *
#import "../packages/preview/assemblyline/main/lib/json-helpers.typ": to-json-value

// Include all specification files (same as main.typ)
#include "features/root.typ"
#include "features/authentication.typ"
#include "features/authorization.typ"
#include "features/user-management.typ"
#include "features/session-management.typ"
#include "features/audit-logging.typ"
#include "features/data-protection.typ"
#include "features/api-security.typ"
#include "features/monitoring.typ"

#include "use-cases/login.typ"
#include "use-cases/authorization.typ"
#include "diagrams/login-sequence.typ"
#include "diagrams/auth-service-ibd.typ"

#include "architecture.typ"
#include "configurations.typ"

// Set minimal page format
#set page(
  paper: "a4",
  margin: 1cm,
)
#set text(size: 8pt, font: "Courier New")
#set par(leading: 0.4em)

// Export JSON
#context {
  let reg = __registry.final()

  let elements = ()
  for (id, elem) in reg {
    let obj = (
      "\"id\": " + to-json-value(elem.id),
      "\"type\": " + to-json-value(elem.type),
      "\"title\": " + to-json-value(elem.at("title", default: none)),
      "\"tags\": " + to-json-value(elem.at("tags", default: (:))),
      "\"links\": " + to-json-value(elem.at("links", default: (:))),
      "\"parent\": " + to-json-value(elem.at("parent", default: none)),
      "\"concrete\": " + to-json-value(elem.at("concrete", default: none)),
      "\"group\": " + to-json-value(elem.at("group", default: none)),
    )
    elements.push("{" + obj.join(", ") + "}")
  }

  let json = "{\n  \"elements\": [\n    "
  json += elements.join(",\n    ")
  json += "\n  ]\n}"

  [```json]
  raw(json)
  [```]
}
