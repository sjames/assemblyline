// demo-feature-tree.typ
// Demonstration of the feature tree rendering functionality
#import "../packages/preview/assemblyline/main/lib/lib.typ": *

// Include features (this executes the content and registers them)
#include "features/root.typ"
#include "features/authentication.typ"

// Include configurations
#include "configurations.typ"

= Feature Tree Demonstration

== European Configuration (CFG-EU)
This configuration selects the Mobile Push + TOTP authentication method.

#set-active-config("CFG-EU")
#feature-tree()

#pagebreak()

== North American Configuration (CFG-NA)
This configuration selects the Biometric authentication method.

#set-active-config("CFG-NA")
#feature-tree()

#pagebreak()

== All Features (No Configuration)
View all features without a configuration filter.

#set-active-config(none)
#feature-tree()
