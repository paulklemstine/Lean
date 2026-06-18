# Summary of changes for run 70f8df8c-0b20-4819-9baa-a5c75d8c3655
Researched the direction "Tropical valuation profiles of Berggren-tree lattice reduction for certified post-quantum key orbits" and produced fully verified Lean 4 artifacts.

**New Lean file** — `Catalog/Cryptography/TropicalBerggrenProfiles.lean` (30 theorems, 0 sorries, builds cleanly with only the standard axioms `propext`, `Classical.choice`, `Quot.sound`). It extends `Algebra/BerggrenLorentz/Core.lean` and connects to `Bridges/CategoricalTropicalUltrametric.lean`, `EML/LatticeTreeCorrespondence.lean`, and `Cryptography/NoetherianCertification.lean`. Main results:
- **Tropical (min-plus) algebra on ℤ**: commutativity, associativity, idempotency, and the defining distributive law (`tmul_tadd_distrib`).
- **Exact conserved charge**: the parity-valuation profile `(odd, 4∣·, odd)` is preserved by all three Berggren generators (`valProfile_invariant_A/B/C`), plus the finer fact that the whole residue vector mod 2 is pointwise fixed (`parity_mod2_invariant_*`).
- **2-adic ultrametric / tropicalization-as-valuation**: `min(v₂ x, v₂ y) ≤ v₂(x+y)` (`padicValInt_two_ultrametric`), giving the valuation profile `(0, ≥2, 0)` of every orbit point (`v2_profile`).
- **Tropical word cost**: additive under concatenation (`tropCost_append`) with certified two-sided depth bounds `3|w| ≤ tropCost w ≤ 5|w|`.
- **Certified termination / hardness**: strict hypotenuse growth `c < childB.c` and `5c < childB.c` for genuine Pythagorean triples (Ω(log c) reversal-depth lower bound).
- **Capstone (global orbit invariance)**: the profile and the Pythagorean condition are conserved along *arbitrary* words in the free monoid on {A,B,C} (`applyWord_preserves_profile`, `applyWord_preserves_pythag`), so every node reachable from the (3,4,5) seed is simultaneously a valid Pythagorean key and carries the conserved tropical 2-adic fingerprint (`seed_orbit_certified`).

**Lab notes**: inline `-- !-- Lab Notes -- !--` blocks throughout record the hypotheses, mod-2/mod-4 experiments, insights, and failure analysis (e.g. switching `ValProfile` from `Odd`/`4∣·` to `%`-residues to unblock `omega`, and inlining the Berggren child maps to keep the file self-contained).

**FUTURE_DIRECTIONS.md** (`Catalog/Cryptography/FUTURE_DIRECTIONS.md`): five bold, falsifiable conjectures with suggested first Lean experiments — exact tropical recurrence for the even-leg valuation, a finite-state automaton structure of the profile mod 2ᵏ, tropical cost as a sharp Θ(log c) depth oracle, ultrametric-driven collision-freeness of orbit hashing, and positivity as a fourth conserved charge yielding well-founded reduction.

Constraints respected: only standard Lean 4 code plus the required FUTURE_DIRECTIONS.md were produced (no articles, Python, HTML, or package files).