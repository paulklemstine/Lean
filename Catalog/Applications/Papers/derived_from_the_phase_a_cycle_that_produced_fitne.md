# Computational Evidence — Mathematics as an Evolving Ecosystem

Fitness model: `f(T) = connections(T) · proofDensity(T) / axiomCount(T)`.
For Selberg data we use the special case `f(S) = degree(S) / conductor(S)`,
with the catalog product `degree` adds, `conductor` multiplies.

## 1. Sub-additivity of fitness under products (Conjecture 1)

Let `S₁ = (d₁, q₁)`, `S₂ = (d₂, q₂)` (degree, conductor). Then
`f(S₁×S₂) = (d₁+d₂)/(q₁q₂)` and `f(S₁)+f(S₂) = (d₁q₂+d₂q₁)/(q₁q₂)`.

| d₁ | q₁ | d₂ | q₂ | f(S₁×S₂)   | f(S₁)+f(S₂) | gap (≥0?) | strict? |
|----|----|----|----|------------|-------------|-----------|---------|
| 1  | 2  | 1  | 2  | 2/4 = 0.50 | 1.00        | 0.50      | yes     |
| 2  | 3  | 1  | 5  | 3/15= 0.20 | 0.866…      | 0.666…    | yes     |
| 1  | 1  | 1  | 1  | 2/1 = 2.00 | 2.00        | 0.00      | no (trivial factors) |
| 1  | 1  | 1  | 5  | 2/5 = 0.40 | 1.20        | 0.80      | q₁=1 ⇒ S₁ trivial; ≤ still holds |

Observation: the gap equals `(d₁(q₂−1) + d₂(q₁−1))/(q₁q₂) ≥ 0`, vanishing iff both
conductors are `1` (trivial factors). This is exactly the strict-vs-non-strict
boundary formalized in `selberg_product_fitness_subadditive` /
`selberg_product_fitness_strict`. No counterexample to `≤` was found.

## 2. Carrying capacity (Conjecture 2)

`niche_packing` bound `card E ≤ card N` is pigeonhole. For tightness we use
`standardTheory i = (connections := i, density := 1, axioms := 1)`, which is
injective in `i`, giving `card N` distinct theories.

**Counterexample hunt — succeeded.** Tightness *fails* at `n = 0`: there is no total
function `FoundationTheory → Fin 0` because `FoundationTheory` is inhabited but
`Fin 0` is empty. Hence `carrying_capacity_tight` carries the necessary hypothesis
`0 < n`. (This corner case was found by the prover's counterexample search and folded
into the statement.)

## 3. Open-ended ascent (Conjecture 4)

`canonicalLineage n` has fitness exactly `n + 1`:

| n | fitness |
|---|---------|
| 0 | 1 |
| 1 | 2 |
| 2 | 3 |
| … | … |

This is unbounded (`canonical_fitness_unbounded`), so there is no maximal-fitness
theory.

**Counterexample hunt — succeeded.** The naive claim "*any* strictly fitness-improving
lineage has fitness → ∞" is FALSE over ℚ: e.g. `g(n) = 1 − 1/(n+1)` is strictly
increasing yet bounded by `1`. Divergence is therefore *not* a consequence of strict
monotonicity; we prove the robust universal statement `evolution_escapes_finite`
(every improving lineage leaves any finite ecosystem) and separately *witness*
divergence with `canonicalLineage`.

## 4. Phase transition / apex (Conjectures 3, 5)

`fitness_lt_iff_cross` gives the exact comparison
`c·d·a' < c'·d'·a`. Concrete fertile point `zfc=(10,3,9)`, `zfc_lc=(20,5,12)`:
`(10·3)·12 = 360 < 900 = (20·5)·9`, so `f(zfc) < f(zfc_lc)` — verified in
`zfc_lc_strictly_fitter`. `fitness_max_unique` needs distinctness (`InjOn fitness`);
with a tie (two theories of equal fitness) the maximizer is non-unique — the guard
hypothesis is load-bearing.

## Notes

No external OEIS sequence is essential here (the canonical fitness sequence is just
`n+1`). All numeric claims above are reproduced as fully verified Lean theorems with
only the standard axioms `propext`, `Classical.choice`, `Quot.sound`.
