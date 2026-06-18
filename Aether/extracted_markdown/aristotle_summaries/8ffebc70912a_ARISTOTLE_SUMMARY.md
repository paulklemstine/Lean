# Summary of changes for run d3ab3269-4abd-457c-b4de-abaf6667eece
Researched the **functorial tropical certificate** direction for the Berggren–Lorentz monoid and delivered fully-verified Lean 4 results.

## New file: `Catalog/Algebra/BerggrenLorentz/TropicalCertificate.lean`
Builds cleanly with **0 sorries**; all main theorems use only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). It extends the existing `Algebra.BerggrenLorentz.Core` theory (Pythagorean triples / discrete Lorentz group O(2,1;ℤ)) with a genuinely tropical, functorial growth certificate:

- **Action setup**: `childGen` (the three Berggren generators indexed by `Fin 3`), `applyWord` (word action by iteration), `Bcount` (number of `B`-generators), and the invariant region `IsPosPythag` (positive Pythagorean triples).
- **Invariance**: `childGen_preserves` / `applyWord_preserves` — the positive-Pythagorean region is closed under the whole monoid action.
- **Per-step growth dichotomy** (the key experimental finding): `childGen_hyp_nonContract` (`A`, `C` never shrink the hypotenuse) and `childGen_hyp_triple_of_B` (`B` triples it).
- **Functorial tropical certificate**: `tropCert`, a monoid homomorphism from words `(List (Fin 3), ++, [])` into the min-plus tropical semiring `(Tropical (WithTop ℕ), *, 1)`, with `tropCert_append` (functoriality = certificate of a concatenation is the tropical product) and `tropCert_untrop` (its underlying value is exactly the `B`-count).
- **Main theorem** `applyWord_hyp_growth`: `3 ^ (Bcount w) · c ≤ hyp (applyWord w (a,b,c))` for every positive Pythagorean seed — a provable exponential lower bound read off functorially from the certificate (`applyWord_hyp_growth_trop` restates this via the certificate's value), with corollaries `seed_hyp_growth` and `pureB_exponential` (`5·3^n` growth along the pure-`B` geodesic).

**Lab Notes** are embedded as `-- !-- Lab Notes -- !--` comment blocks documenting the three hypotheses (growth dichotomy, telescoping, functoriality), the `#eval` experiments on the Berggren tree (pure-`A` branch is quadratic `5,13,25,41,61…`; `B`-branch ratio → 3+2√2), and the failure analysis (a perimeter-based certificate was abandoned in favor of the clean hypotenuse dichotomy).

## `Catalog/Algebra/BerggrenLorentz/FUTURE_DIRECTIONS.md`
Five bold, testable conjectures for follow-up cycles: (1) a matching two-sided `7^length` upper certificate; (2) exact tropical Lyapunov exponent `3+2√2`; (3) the certificate as a complete coarse orbit invariant; (4) lifting functoriality from the hypotenuse to the full `ℓ¹` size; (5) faithful tropical grading ⇒ word-problem hardness. Each is phrased to drop directly into Lean as a `sorry` target.

No prose articles, Python, widgets, or package files were produced, per the constraints. (Note: I added directory symlinks at the project root so the existing lib globs resolve the `Catalog/` source tree during builds.)