# Computational Evidence Stage — Justification for Skipping

The central result is an exact structural equivalence, not a numerical conjecture:
`Φ > 0` is equivalent to positivity of every admissible cut. The proof follows directly
from finite minimum attainment, so sampling small networks would not increase confidence
in the universal statement and no integer sequence or OEIS entry is involved.

The Lean development nevertheless checks all edge conditions symbolically: it proves that
nontrivial cuts exist for systems of size at least two, proves the minimum is attained, and
uses nonnegativity of every interaction weight to construct the weighted IIT system.
