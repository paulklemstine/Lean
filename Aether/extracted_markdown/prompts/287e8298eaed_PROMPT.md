Complete a narrowly scoped Lean 4 formalization in `Catalog/Tropical/BerggrenTree/TropicalHeight.lean` that finishes the tropical-height core for the Berggren tree using the existing Berggren/Lorentz infrastructure. Do not expand to automorphic forms, generating functions, asymptotics, or broad path combinatorics unless the core theorems are already complete.

Primary goal: produce a compilable file with full proofs, no placeholders, and no interrupted theorem bodies.

Use the existing objects and lemmas from `Algebra.BerggrenLorentz.Core` whenever possible. Work with integer triples `(a,b,c)` as represented in the core library, and define the tropical height by
`tropHeight t = max t.1 (max t.2.1 t.2.2)`
or the equivalent coordinate notation matching the imported file.

The required theorem families are:

1. Tropical height collapses to the hypotenuse on positive Pythagorean triples.
   Prove a theorem of the form:
   `tropHeight_eq_hypotenuse : IsPosPythag t -> tropHeight t = c`
   with the exact statement adapted to the core library’s tuple/triple representation. The proof should explicitly use the core lemmas that the hypotenuse dominates both legs for positive Pythagorean triples.

2. Exact one-step child formulas.
   For each Berggren child `childA`, `childB`, `childC`, prove an exact theorem computing tropical height of the child on positive Pythagorean triples. Since `tropHeight = hypotenuse`, this should reduce to proving the explicit formula for the child hypotenuse coordinate already determined by the standard Berggren matrices. State these as concrete equalities, e.g. of the form
   `tropHeight (childA t) = ...`,
   `tropHeight (childB t) = ...`,
   `tropHeight (childC t) = ...`
   where the right-hand side is the explicit linear expression in parent coordinates.

3. Strict one-step monotonicity.
   Deduce for each child:
   `tropHeight t < tropHeight (childA t)`,
   `tropHeight t < tropHeight (childB t)`,
   `tropHeight t < tropHeight (childC t)`
   under the appropriate positivity hypotheses. Keep these proofs simple: rewrite by the exact formulas and use positivity of coordinates from the Berggren core.

Only after these are complete, optionally add a minimal path section:
- define `childStep : Fin 3 -> Triple -> Triple`;
- define `applyPath : List (Fin 3) -> Triple -> Triple` recursively;
- prove only the smallest useful theorem: if `p ≠ []` and `t` is a positive Pythagorean triple, then `tropHeight t < tropHeight (applyPath p t)`.
This path theorem should be by induction on the list, using the one-step monotonicity and any preservation lemmas already available in the core. Do not attempt stronger growth-rate bounds unless they fall out immediately.

Implementation guidance:
- First inspect `Algebra.BerggrenLorentz.Core` and reuse its exact names for positivity, Pythagorean predicates, child constructors, and coordinate formulas.
- Prefer short helper lemmas for coordinate projections of each child if needed.
- Avoid leaving theorem headers without proof terms.
- If tuple projections are cumbersome, introduce local notation or helper definitions, but keep the API small.
- The finished file should be self-contained and compile against mathlib plus the Berggren core import.

Deliverable: a fully proved Lean file formalizing the three theorem families above, with the optional path monotonicity theorem only if it can be completed cleanly after the one-step results.