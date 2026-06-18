# Summary of changes for run 749fd9f5-001b-4401-a720-7507c2f2dcc7
## Reverse Mathematics of Ramsey's Theorem — RT²₂ formalized

I added a new, fully proved Lean file `Catalog/Logic/ReverseMathRamsey.lean` and a `FUTURE_DIRECTIONS.md` research file. The module builds cleanly (no warnings), contains **no `sorry`**, and the main results depend only on the permitted axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Theorem declarations (Step 1)
1. `infinite_pigeonhole_bool` — RT¹₂: every `c : ℕ → Bool` has an infinite constant fibre — **proved** — finite-codomain pigeonhole transported to `Set.Infinite`.
2. `infinite_pigeonhole` — RT¹ₖ: every `c : ℕ → Fin k` has an infinite constant fibre — **proved** — same argument over `Fin k` (the `0 < k` hypothesis turned out unnecessary and was removed).
3. `infinite_ramsey_pairs` — RT²₂: every two-colouring `c : ℕ → ℕ → Bool` of the pairs of ℕ admits an infinite homogeneous set — **proved** — the classical pivot construction: a strictly increasing sequence of pivots `pt n` with attached colours `color n` such that any later pivot is joined to `pt n` by `color n` (`color_pt`), then pigeonhole on `color`. This is the central object that reverse mathematics classifies and is absent from Mathlib.
4. `RT2_imp_RT1` — the reversal RT²₂ ⟹ RT¹₂ — **proved** — a genuine proof transformation: lift a one-colouring `f` to the pair colouring `fun _ j => f j`; a homogeneous set's tail above its minimum is a constant fibre of `f`.

Supporting lemmas (`upper_infinite`, `exists_color`, `nextSet`/`seqSet`/`pt`/`color` definitions, `mem_next_iff`, `pt_lt_succ`, `pt_strictMono`, `seqSet_subset_of_le`, `color_pt`) are all proved as well.

### Catalog synthesis
This extends the catalog's *finite/counting* Ramsey work (`HypergraphRamsey.hyper_ramsey_counting_lower_bound`, `Algebra/Recursion.lean`'s `RamseyProp_*`) to the *infinitary, set-existence* side that the reverse-mathematics hierarchy (RCA₀ / WKL₀ / ACA₀) actually measures.

### FUTURE_DIRECTIONS.md
Five testable, falsifiable conjectures (each with a "key insight" and "Why now?"): the full `RTⁿ_k` by exponent induction; the stable/cohesive decomposition `RT²₂ ↔ SRT²₂ + COH`; the non-implications `RT¹ ⇏ RT²₂` and Seetapun's `RT²₂ ⇏ ACA₀`; computable (`Δ⁰₃`/`low₂`) bounds on the homogeneous set; and recovering finite Ramsey from the infinite theorem by compactness, bridging back to the catalog's finite bounds.

Note on scope: formalizing the *metatheory* (the formal subsystems RCA₀/WKL₀/ACA₀ and a machine-checked separation, i.e. Seetapun's theorem proper) is a much larger undertaking; this cycle delivers the rigorous combinatorial heart (RT²₂ and RT¹) plus one reversal, and lays out the separation as a future direction.