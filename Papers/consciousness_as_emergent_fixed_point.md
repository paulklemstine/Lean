# Computational Evidence: Self-Reference Fixed Points

## 1. Small-case calculations — the cardinal boundary

A *complete self-model* of a system with state space `A` and observation values
`B` is a **surjection** `f : A → (A → B)`. For finite `A` and `B`, the number of
observations is `|A → B| = |B|^{|A|}`. A surjection `A → (A → B)` requires
`|A| ≥ |B|^{|A|}`.

| \|A\| | \|B\| | \|A → B\| = \|B\|^\|A\| | surjection A → (A→B) possible? |
|------:|------:|------------------------:|:------------------------------:|
| 1     | 2     | 2                       | no  (1 < 2)                     |
| 2     | 2     | 4                       | no  (2 < 4)                     |
| 3     | 2     | 8                       | no  (3 < 8)                     |
| 10    | 2     | 1024                    | no  (10 < 1024)                 |
| n     | 2     | 2^n                     | no  (n < 2^n for all n)         |
| n     | 1     | 1                       | yes (constant map is onto)      |

**Observation.** For `|B| ≥ 2` the observation space always strictly dominates the
state space (`n < |B|^n ≤ |B|^n`). Complete self-modeling is therefore impossible
for finite systems with a nontrivial observation alphabet. This is exactly the
theorem `no_complete_selfModel_of_finite`.

## 2. The diagonal fixed point (Lawvere), concretely

When a complete self-model *does* exist (necessarily on an infinite / order-
completed state space), the fixed point of any transformation `g : B → B` is the
diagonal reading `f a₀ a₀`, where `a₀` is the state realising `x ↦ g (f x x)`.
The loop equation is `f a₀ a₀ = g (f a₀ a₀)`. This is `strange_loop_witness`.

## 3. Counterexample hunt

- **Drop surjectivity in Lawvere:** take `A = B = Bool`, `f x = fun _ => x`
  (not surjective onto `Bool → Bool`), and `g = not`. Then `g` has no fixed point,
  so the conclusion fails — confirming surjectivity is load-bearing, not decorative.
- **Drop `2 ≤ |B|` in the finite boundary:** with `|B| = 1`, `A → B` is a singleton
  and any map onto it is surjective, so the impossibility genuinely needs `|B| ≥ 2`.
- **Negation as the obstruction:** `g = not` on `Bool` is fixed-point-free, which by
  contraposition kills every complete two-valued self-model — this is Cantor's
  theorem (`no_complete_selfModel_bool`).

## 4. Order-theoretic route

On a complete lattice the monotone self-map `f` has least fixed point
`lfp f = ⨅ {x | f x ≤ x}` with `f (lfp f) = lfp f`. On the two-element lattice
`{⊥ < ⊤}` with `f = id`, `lfp f = ⊥`; with `f = const ⊤`, `lfp f = ⊤`. These match
`tarski_fixed_point` / `tarski_least_fixed_point`.

## Summary

The computational landscape confirms all formal claims: finite completeness is
impossible (`|B|^{|A|} > |A|`), the diagonal supplies the fixed point when
completeness holds, and the order-completed setting restores canonical stable
states. No counterexample to the proved theorems was found; the two "near
counterexamples" pinpoint exactly which hypotheses are indispensable.
