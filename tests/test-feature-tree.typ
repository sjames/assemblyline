// Quick test of feature tree functionality
#import "packages/preview/assemblyline/main/lib/lib.typ": *

// Include features and configurations
#include "features/root.typ"
#include "features/authentication.typ"
#include "configurations.typ"

// Set active configuration
#set-active-config("CFG-EU")

// Explicitly render the feature tree
#feature-tree()
