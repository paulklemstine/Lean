# Summary of changes for run f0a9b5b7-0750-4b94-8b65-9c757a959cd5
Created `Catalog/Novelty/GroupIsotopes.lean`, a single coherent, fully verified Lean 4 file (no `sorry`, only the standard axioms `propext`/`Classical.choice`/`Quot.sound`) that formalizes a modest, falsifiable fragment of the "periodic table of finite groups" idea.

Contents:
- `IsMinimalNormal N`: a structure defining a minimal normal subgroup (normal, nontrivial, no strictly smaller nontrivial normal subgroup), built on mathlib's `Subgroup.Normal`.
- `normal_subgroup_eq_top_of_simple`: in a simple group every nontrivial normal subgroup is `⊤`.
- `top_is_minimal_normal_of_simple`: in a simple group `⊤` is a minimal normal subgroup.
- `minimal_normal_eq_top_of_simple`: every minimal normal subgroup of a simple group equals `⊤` (so, together with the previous result, `⊤` is the unique minimal normal subgroup).
- `commutative_simple_group_prime_order`: a commutative simple group has prime order (`(Nat.card A).Prime`).
- `commutative_simple_group_isomorphic_zmod`: a commutative simple group is isomorphic to `Multiplicative (ZMod p)` for the prime `p = Nat.card A` (the `ZMod p` formulation).
- `composition_factor_set_does_not_determine_order`: the carefully stated counterexample/impossibility result. It exhibits `Multiplicative (ZMod 2)` and `Multiplicative (ZMod 4)`, two finite abelian 2-groups with the *same* prime support `(Nat.card ·).primeFactors = {2}` (i.e. the same set of composition-factor isomorphism types) but different orders `2 ≠ 4`, and hence not isomorphic. 

On the math: rather than asserting the false claim that composition factors can't determine order (by Jordan–Hölder the multiset of factors does determine the order), the docstring and theorem pin down the exact invariant being refuted — the *set* of composition-factor types (multiplicities forgotten), encoded as the prime support — and prove it genuinely fails to determine the order. This is the corrected negative result requested.

Verification: the file compiles with the project's mathlib; I confirmed it elaborates without errors, contains no `sorry`, and that the key theorems use only the permitted axioms.

Note: the file lives at `Catalog/Novelty/GroupIsotopes.lean` as requested. The `Novelty` directory is not wired into the project's `lakefile.toml` default targets (the existing files there are likewise standalone), so the file is verified by direct elaboration against mathlib rather than via a default `lake build` target.