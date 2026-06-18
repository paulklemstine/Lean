# Summary of changes for run 14e152a7-6c07-4fbb-8d1f-d746385229fa
## Summary

This cycle delivered a new, fully-proven Lean formalization of paraconsistent **dream logic**, repaired a broken build, and closed the prime-index case of Carmichael's primitive-divisor theorem. Everything compiles under Lean 4.28 / Mathlib v4.28.0.

### New deliverable: `Catalog/Logic/DreamLogic.lean` (sorry-free, axiom-clean)
A self-contained formalization of the Belnap–Dunn four-valued logic FDE as a "dream logic" where impossible objects (gluts, `B = ¬B`) coexist without collapse. Proven theorems (all with `-- !--` proof sketches and an `example` block):
- **Algebra**: `V4.neg_neg` (involution), `deMorgan_conj`/`deMorgan_disj` (De Morgan algebra), `neg_glut`.
- **Paraconsistency**: `explosion_fails` (a contradiction `{a,¬a}` does not entail an arbitrary `b`), `disjunctive_syllogism_fails`, `not_everything_entailed` (non-triviality), and the monotonicity of plain entailment `Entails.mono`.
- **Non-monotone "dream" consequence** `PEntails` (preferred-model, consistency-first): the headline `dream_nonmonotone` shows `q` follows from `{p∨q, ¬p}` but is **retracted** once the contradictory premise `p` is added (`ds_classically_valid` + `ds_retracted`). Plus the strengthening `dream_cautious_monotone` (cumulativity) and the boundary/contrast `classical_regime_explodes` (the classical two-valued regime trivializes under contradiction — exactly what the four-valued fallback avoids).

### Carmichael / Fibonacci chain — build repair and prime case closed
The catalog's Carmichael chain was unbuildable. I fixed the root causes:
- Corrected the misconfigured `srcDir` in `lakefile.toml` (it pointed at the wrong source root, so nothing built).
- Created the missing `Catalog/Shared/CarmichaelHelper.lean`, **proving from scratch** `fib_primitive_divisor_prime` (Carmichael's theorem for prime indices: every prime factor of `F(p)` is automatically primitive), which the whole chain depended on.
- Removed a spurious missing import in `Shared/Fib_gcd_identity.lean` and fixed a wrong import in `Speculative/CarmichaelPrimitiveDivisor.lean`.

As a result both priority targets (`Speculative/AutoResearch/CarmichaelComposite.lean` and `Shared/Fib_gcd_identity.lean`) now compile, as does `Speculative/CarmichaelPrimitiveDivisor.lean`.

### Remaining open `sorry` (documented, not introduced)
One pre-existing `sorry` remains in `Shared/CarmichaelProof.lean`: the infinite composite tail of Carmichael's theorem (`n > 10000`). This is genuinely research-level — it needs the Fibonacci cyclotomic value Φ(n), the divisor-product factorization, the lifting-the-exponent multiplicity bound, and the golden-ratio size estimate. The finite range `13 ≤ n ≤ 10000` is already machine-verified, and the prime case is now proven; only this deep tail is open. I added an explanatory comment at the site and made it Direction 1 of the future-work file.

### `FUTURE_DIRECTIONS.md`
Five testable, falsifiable conjectures, each with a "key insight" and "why now" justification: (1) closing the composite Carmichael tail via Fibonacci cyclotomic values; (2) classical recapture for dream consequence; (3) an AGM-style belief-retraction operator; (4) a parametric bilattice family with a paraconsistency↔fixed-point-of-negation bridge (cross-domain link to the entry-point structure in the Carmichael work); (5) a sound-and-complete proof calculus for FDE entailment.

All new theorems were verified to depend only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`).