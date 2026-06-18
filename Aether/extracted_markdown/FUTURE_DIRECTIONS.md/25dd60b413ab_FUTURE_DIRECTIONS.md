# FUTURE DIRECTIONS

Follow-up conjectures arising from
`Catalog/Applications/EGFTropicalValuation.lean`
("Exponential generating functions induce a tropical valuation profile via
coefficient-support truncation").

This cycle established that the `X`-adic order `egfOrder = order ∘ egf` is a tropical
valuation on counting sequences: **exactly multiplicative** on the species/binomial-convolution
product (`egfOrder_binConv`), **ultrametric/min** on the species sum
(`min_egfOrder_le_egfOrder_add`, `egfOrder_ultrametric`), packaged as a **unital monoid
morphism** into the tropical semiring `Tropical ℕ∞` (`egfTrop_isMonoidMorphism`), with a
**derivative profile recurrence** (`egfOrder_le_shift_succ`, `shift_succ_eq_egfOrder`) and an
**atomic free grading** (`egfOrder_singleSeq`, `egfOrder_binConv_singleSeq`).

The conjectures below are stated to be directly formalizable and falsifiable.

## Conjecture 1 — Tropical semiring homomorphism (full bridge)
The map `egfTrop : (ℕ → ℚ) → Tropical ℕ∞` is a **semiring homomorphism** if the source is
equipped with `(binConv, +, deltaSeq, 0)` *and the target inequality is sharpened to an
equality on sums whose valuations differ*. Precisely: whenever
`egfOrder a ≠ egfOrder b`, then `egfTrop (fun n => a n + b n) = egfTrop a + egfTrop b`
(tropical addition = `min`). This is the additive analogue of `egfOrder_binConv` and would
upgrade the lax morphism `egfTrop_isMonoidMorphism` to a genuine `RingHom`-like object.
*Testable:* prove `egfOrder (fun n => a n + b n) = min (egfOrder a) (egfOrder b)` under
`egfOrder a ≠ egfOrder b` (Mathlib: `PowerSeries.order_add_of_order_ne`).

## Conjecture 2 — Newton-polygon convexity of the valuation profile
Define the iterated-derivative profile `P a k := egfOrder (fun n => a (n + k))`. Conjecture:
for any `a`, the profile is **eventually exactly linear of slope −1 then absorbed at `⊤`**;
formally, there is `m : ℕ∞` with `P a k = m - k` for `k ≤ m` (truncated subtraction in `ℕ∞`)
whenever `a i = 0` for all `i < m`, and `P a` is *tropically convex* as a function of `k`. The
proven `shift_succ_eq_egfOrder` is the base step (slope −1 once the constant term vanishes); the
conjecture is the global statement, i.e. the Newton polygon of the EGF is a single segment for
atomic species and convex in general.

## Conjecture 3 — Tropical valuation of the composition (substitution) of species
Joyal's substitution `F ∘ G` corresponds to EGF composition `(EGF F) ∘ (EGF G)` (when `G` has no
constant term, `egfOrder G ≥ 1`). Conjecture: the valuation is **multiplicative under
substitution at the bottom degree**:
`egfOrder (coeffSeq (F ∘ G)) = egfOrder (coeffSeq F) · egfOrder (coeffSeq G)`
whenever `egfOrder G ≥ 1` and `F` has a structure of the minimal nonzero `G`-degree. This would
make `egfOrder` a valuation compatible with the operadic/plethystic structure, not just the
product — i.e. tropical multiplication tracks the **composition depth**.

## Conjecture 4 — Ultrametric completion = formal power series
The valuative distance `d(a,b) := (egfOrder (fun n => a n - b n))` induces, via `q^{-d}` for any
`0 < q < 1`, an **ultrametric** on `ℕ → ℚ` (the strong triangle inequality is exactly
`egfOrder_ultrametric`). Conjecture: the metric completion of `(ℕ → ℚ, d)` is isometric to
`ℚ⟦X⟧` with its `X`-adic ultrametric, and `egf` extends to a **bi-Lipschitz isometry** of the
two completions. This realizes, concretely for EGFs, the catalog principle of
`Bridges/CategoricalTropicalUltrametric.lean` that tropical valuation data reconstructs an
ultrametric.

## Conjecture 5 — Tropical valuation detects polynomial species
A species `F` is a *polynomial species* (only finitely many sizes carry structures) iff its
counting sequence is eventually zero. Conjecture: this is detected tropically by the
**reversed valuation** `coOrder a := sup { n | a n ≠ 0 }` (the tropical valuation of the
"reflected" sequence), and the pair `(egfOrder a, coOrder a)` forms a **tropical interval
module** under `binConv`, with `egfOrder` additive (proved) and `coOrder` additive on products
with no zero divisors. *Testable:* `coOrder (binConv a b) = coOrder a + coOrder b` for finitely
supported `a, b`, the "top-degree" mirror of `egfOrder_binConv`.
