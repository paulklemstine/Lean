# Summary of changes for run e26faca4-2b61-462d-a413-41b51abecbd2
## Completed: Morita Invariance of Probe Complexity (κ)

### Formally Verified Mathematics (Lean 4)

All theorems are **fully proved** — zero `sorry` statements remain — and verified against only standard axioms (propext, Classical.choice, Quot.sound).

**Files:**
- `Pythagorean/ProbeComplexity/Defs.lean` — Core definitions (probe family, separating family, probe complexity)
- `Pythagorean/ProbeComplexity/Theorems.lean` — Foundation theorems (total family separates, upper bounds, capacity bounds, thin category theorem)
- `Pythagorean/ProbeComplexity/MoritaInvariance.lean` — **New: 8 theorems + 3 new definitions, all proved**

**Main Theorems Proved:**

1. **Equivalence Invariance** (`probeComplexity_eq_of_equivalence`): If C ≌ D then κ(C) = κ(D). Proved by transporting separating families along the equivalence functors using the counit natural isomorphism.

2. **Karoubi Upper Bound** (`probeComplexity_karoubi_le`): κ(Kar(C)) ≤ κ(C). A separating family on C lifts to Kar(C) by embedding probes as (Z, id). The key insight: composing a separator h₀ with the idempotent p produces a valid Karoubi morphism h₀ ≫ p that still separates, because p absorbs into Karoubi morphisms (p ≫ f = f).

3. **Karoubi Lower Bound** (`probeComplexity_le_karoubi`): κ(C) ≤ κ(Kar(C)). Restricting a separating family on Kar(C) to the underlying objects of C gives a separating family for C, using faithfulness of the toKaroubi embedding.

4. **Theorem A — Karoubi Invariance** (`probeComplexity_eq_karoubi`): κ(C) = κ(Kar(C)). The probe complexity is invariant under idempotent splitting.

5. **Theorem B — Morita Invariance** (`kappa_eq_of_karoubi_equivalence`): If Kar(C) ≌ Kar(D) then κ(C) = κ(D). Chains through κ(C) = κ(Kar(C)) = κ(Kar(D)) = κ(D).

6. **Split-Stability** (`every_separating_is_split_stable`): Every separating probe family on C is automatically split-stable — it extends to Kar(C) without size increase.

7. **Absorption Lemmas** (`karoubi_hom_left_absorb`, `karoubi_hom_right_absorb`): For Karoubi morphisms f : (X,p) → (Y,q), p ≫ f = f and f ≫ q = f.

8. **Monoid Specialization** (`kappa_singleObj_eq_karoubi`): For finite monoids M, κ(SingleObj M) = κ(Kar(SingleObj M)).

**New Definitions Introduced:**
- `FiniteHomCategory` — typeclass for categories with finite decidable hom-sets
- `SplitStableProbeFamily` — probe family that extends to Kar(C)
- `retractProfile` — combinatorial invariant of Karoubi objects
- Finiteness instances for Karoubi envelope (Fintype, DecidableEq, FiniteHomCategory)

### Other Deliverables

- **`ARTICLE.md`** — Popular-science article (~2500 words) explaining Morita invariance through the satellite-analyst metaphor
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, proofs, algorithms, experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 testable conjectures including the topos-generator conjecture and subadditivity
- **`demo.py`** — Constructs 5 finite categories, builds Karoubi envelopes, computes κ on both sides, prints comparison table (all match ✓)
- **`algorithms.py`** — Typed implementation of κ computation, Karoubi construction, and certified comparison
- **`applications.py`** — Applications to automata, representation theory, site comparison, and categorical semantics
- **`PACKAGE.json`** — JSON bundle of all artifacts for web templating