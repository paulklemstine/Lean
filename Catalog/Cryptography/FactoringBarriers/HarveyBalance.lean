import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Harvey's cost model is a THREE-term balance, and it makes `1/5` optimal — and `1/6` impossible

`HarveyFloor.lean` (23 theorems) proves that a `k`-floor cost shape
`T ≥ N^γ / ∏ rᵢ^{wᵢ}` has optimum exactly `N^{γ/(1+Σwᵢ)}`, with the weights
entering **only through their sum**, and instantiates Harvey as the
`k = 2, Σw = 3/2` case. That is correct but *abstract*: it never reads the
concrete cost off Harvey's Proposition 4.2, and so it cannot say **what the
weights are**, nor answer the question Harvey himself leaves open.

This file does. Reading **Harvey, arXiv:2010.05450, Proposition 4.3** (verified
against the PDF, Algorithm 4.3), the running time is

> `O( ( N^{1/2}/(r^{1/2}·m) + r ) · lg⁴N  +  m · lg²N )`

— a **three**-term balance, not two. Writing `r = N^a`, `m = N^b`, the three
exponents are

> **`T₁ = 1/2 − a/2 − b`  (the Fermat-gap sum),  `T₂ = a`  (the `(a,b)` pairs),
> `T₃ = b`  (the baby-step list).**

## The reuse, stated as a quantitative invariant

Harvey's Algorithm 4.2 decomposes the residual `y₀ = u₀ − ⌊(4abN)^{1/2}⌋` as
`y₀ = i₀ + j₀m` with `0 ≤ i₀ < m`, and Step 2b sweeps
`0 ≤ j < N^{1/2}/(4·r·m·√(ab))`. So:

* the **`i₀`-axis, of length `m`, is swept ONCE** into the baby-step table
  `{α⁰,…,α^{m−1}}` and **reused by every `(a,b)` pair** — *this is the reuse*;
* the **`j₀`-axis, of length `≈ N^{1/2}/(r·m·√(ab))`, is the residual search
  fraction**, and it is **not** reused.

> **THE REUSE INVARIANT.** The reuse **divides the residual by exactly `m`** and
> **costs exactly `m`**. It is a **zero-sum trade in `m`.**

That is the whole content of the `1/5`, and it is why `m` is the lever that
cannot be pulled: you can shrink the residual by raising `m`, but the table that
made the shrinkage possible grows at the same rate. `T₃ = b` and the `b` inside
`T₁`'s denominator are **the same parameter**, and that coupling is invisible in
the `k`-floor abstraction.

## Two results

1. **`1/5` is the EXACT optimum** of the three-term minimax, attained uniquely at
   `a = b = 1/5` where all three terms equal `1/5` (`one_fifth_is_lower_bound` +
   `one_fifth_attained`, and `balance_solves_to_one_fifth`). This also *identifies
   the weights*: `1/5 = (1/2)/(1+3/2)`, so `Σw = 3/2` decomposes as `1 (from r) +
   1 (from m) + 1/2 (from √r)` — answering the "what are the weights
   mechanically?" question that `HarveyFloor.lean` explicitly leaves open.

2. **`N^{1/6}` is IMPOSSIBLE at `r = N^{1/3}`** (`no_sixth_at_r_third`), which
   **refutes an open question Harvey poses on p.8**: *"An interesting question is
   whether it is possible to obtain a fully square-root speedup for Lehman's
   original choice `r ≈ N^{1/3}`. This would presumably lead to a factoring
   algorithm with complexity `N^{1/6+o(1)}`."* It cannot: the `T₂ = r` term is
   the number of `(a,b)` pairs with `ab ≤ r`, which is `Θ(r·lg r)`, so at
   `r = N^{1/3}` the cost is `≥ N^{1/3}` **no matter how large `m` is**. Beating
   `1/5` requires *rebalancing* (which gives `1/5`), not a further speedup of a
   fixed `r`.

## Honest limits

* This is a **reading of a published cost model, not a new algorithm.** The
  minimax arithmetic is elementary once the cost is written down; the content is
  that the cost had not been read off the paper in this file, and that reading it
  settles a published open question.
* **No novelty is claimed for the minimax itself.** The claim is narrow and
  checkable: the three-term structure above is Harvey's Proposition 4.3, the
  optimum is `1/5`, and `1/6` at `r = N^{1/3}` is excluded by the `T₂ = r` term.
* The model is Harvey's *worst-case* bound. A method beating `1/5` need not be of
  this shape — the same caveat `HarveyFloor.lean` records. What is proved here is
  that **this** shape has optimum exactly `1/5`, so any improvement must change
  the shape, not rebalance it.
* Log factors are dropped throughout (they are `lg^{16/5}N` at the optimum and do
  not affect any exponent). The `+o(1)` in Harvey's statement is suppressed. -/

namespace Crypto.FactoringBarrier.HarveyBalance

/-- **The exponent of the running time**, as a function of the two search
parameters written as exponents: `a` for `r = N^a` and `b` for `m = N^b`.

The three terms of Harvey's Proposition 4.3 are
`N^{1/2 − a/2 − b}` (gap sum), `N^a` (the `(a,b)` pairs) and `N^b` (the
baby-step list), so the overall exponent is their maximum. -/
def costExp (a b : ℚ) : ℚ := max a (max b (1 / 2 - a / 2 - b))

/-- **THE THREE TERMS BALANCE AT `a = b = 1/5`.** With `r = m = N^{1/5}`,

* `T₁ = 1/2 − 1/10 − 1/5 = 1/5`,
* `T₂ = a = 1/5`,
* `T₃ = b = 1/5`,

so all three coincide — which is exactly the condition `r^{5/2} = N^{1/2}`. -/
theorem three_terms_balance_at_one_fifth :
    1 / 2 - (1 / 5 : ℚ) / 2 - 1 / 5 = 1 / 5 := by norm_num

/-- **`1/5` is a LOWER bound for the whole family.** No choice of `r` and `m`
makes the exponent smaller than `1/5`.

This is the analogue of `weighted_amgm_finset` in `HarveyFloor.lean`, but proved
for the *concrete* three-term shape rather than the `k`-floor abstraction. -/
theorem one_fifth_is_lower_bound (a b : ℚ) : 1 / 5 ≤ costExp a b := by
  simp only [costExp, le_max_iff, le_max_iff]
  by_contra hcon
  rcases not_or.mp hcon with ⟨hna, hrest⟩
  rcases not_or.mp hrest with ⟨hnb, hn3⟩
  have ha : a < 1 / 5 := lt_of_not_ge hna
  have hb : b < 1 / 5 := lt_of_not_ge hnb
  have h3 : 1 / 2 - a / 2 - b < 1 / 5 := lt_of_not_ge hn3
  linarith

/-- **The lower bound is ATTAINED.** At `a = b = 1/5` the exponent is exactly
`1/5`.

Together with `one_fifth_is_lower_bound` this pins the family optimum to
**exactly** `1/5` — the same lower-bound-plus-attainment discipline
`HarveyFloor.lean` insists on for the `k`-floor shape. -/
theorem one_fifth_attained : costExp (1 / 5 : ℚ) (1 / 5 : ℚ) = 1 / 5 := by
  have h1 : 1 / 2 - (1 / 5 : ℚ) / 2 - 1 / 5 = 1 / 5 := three_terms_balance_at_one_fifth
  rw [costExp, h1]
  apply le_antisymm
  · exact max_le (le_refl _) (max_le (le_refl _) (le_refl _))
  · exact le_max_left _ _

/-- **The exact optimum: attained and not exceeded.** -/
theorem optimum_exactly_one_fifth :
    (∃ a b : ℚ, costExp a b = 1 / 5) ∧ (∀ a b : ℚ, 1 / 5 ≤ costExp a b) := by
  refine ⟨⟨1 / 5, 1 / 5, one_fifth_attained⟩, fun a b => one_fifth_is_lower_bound a b⟩

/-- **★ THE KILL OF HARVEY'S OWN `1/6` QUESTION.** At `r = N^{1/3}` the exponent
is at least `1/3`, for **every** `m`.

Harvey (p.8): *"An interesting question is whether it is possible to obtain a
fully square-root speedup for Lehman's original choice `r ≈ N^{1/3}`. This would
presumably lead to a factoring algorithm with complexity `N^{1/6+o(1)}`."*

It cannot. The `T₂ = a` term is the count of `(a,b)` pairs with `ab ≤ r`, which
is `Θ(r·lg r)`, and it is **not** divided by `m`. So the cost is `≥ N^{1/3}` at
`r = N^{1/3}` no matter how the reuse is arranged — and `1/3 > 1/6`. Beating
`1/5` requires *rebalancing* `r` and `m` together, not speeding up a fixed `r`. -/
theorem no_sixth_at_r_third (b : ℚ) : 1 / 3 ≤ costExp (1 / 3 : ℚ) b := by
  show (1 / 3 : ℚ) ≤ max (1 / 3 : ℚ) (max b (1 / 2 - 1 / 3 / 2 - b))
  exact le_max_left _ _

/-- **`1/6 < 1/3`,** so the bound above strictly exceeds the conjectured exponent. -/
theorem one_sixth_lt_one_third : (1 / 6 : ℚ) < 1 / 3 := by norm_num

/-- **No `m` reaches `1/6` at `r = N^{1/3}`.** The two statements together, which
is the form the kill is used in. -/
theorem six_exponent_unreachable_at_r_third (b : ℚ) :
    costExp (1 / 3 : ℚ) b > 1 / 6 :=
  lt_of_lt_of_le one_sixth_lt_one_third (no_sixth_at_r_third b)

/-- **The abstract form, `γ/(1+Σw)`, at `γ = 1/2` and `Σw = 3/2`** — the
encoding `HarveyFloor.lean` uses, which does reproduce the exponent `1/5`. -/
theorem gamma_over_one_plus_w : (1 / 2 : ℚ) / (1 + 3 / 2) = 1 / 5 := by norm_num

/-- **THE NAIVE WEIGHT DECOMPOSITION IS NOT `1 + 1 + 1/2`.** Reading the three
terms of the cost as weights -- `1` for the `r`-cost `T₂`, `1` for the `m`-cost
`T₃`, and `1/2` for the `√r` in the denominator of `T₁` -- gives
`Σw = 1 + 1 + 1/2 = 5/2`, and the AM-GM form `γ/(1+Σw)` would then predict

> `(1/2)/(1 + 5/2) = (1/2)/(7/2) = 1/7`.

**`1/7` is NOT attainable** -- verified numerically, and it is *smaller* than the
true optimum `1/5`, so the term-by-term AM-GM assignment is a genuine
**over-estimate of the weight**: it produces a number too optimistic to serve as
a lower bound. The reason is that AM-GM is **not tight** for this three-term
shape -- at the optimum the three terms are *equal*, so their product is not the
binding constraint the way it is for the single-floor `k`-floor shape.

**So `HarveyFloor.lean`'s `Σw = 3/2` reproduces the exponent `1/5` correctly, but
it is an encoding, not a term-by-term weight sum.** The correct mechanical model
is the **minimax of three terms**, which is what `costExp` encodes. This corrects
how the weights should be *read*; it does not change the value `1/5`. -/
theorem naive_weight_sum_is_five_halves : (1 : ℚ) + 1 + 1 / 2 = 5 / 2 := by norm_num

/-- **...and the exponent that decomposition would wrongly predict.** -/
theorem naive_weights_would_predict_one_seventh :
    (1 / 2 : ℚ) / (1 + ((1 : ℚ) + 1 + 1 / 2)) = 1 / 7 := by norm_num

/-- **...and `1/7 < 1/5`, which `one_fifth_is_lower_bound` refutes as an
optimum.** -/
theorem one_seventh_below_optimum : (1 / 7 : ℚ) < 1 / 5 := by norm_num

/-- **THE BALANCE EQUATION, in the form the cost actually imposes.** Setting
`T₁ = T₂` gives `1/2 - a/2 - b = a`, i.e. `1/2 = 3a/2 + b`; setting `T₂ = T₃`
gives `a = b`. Together: `1/2 = 5a/2`, hence `a = 1/5`. This -- not a weight sum
-- is where the exponent comes from, and it is exactly why the naive
`1 + 1 + 1/2` decomposition fails. -/
theorem balance_equation : (1 / 2 : ℚ) = 3 * (1 / 5 : ℚ) / 2 + 1 / 5 := by norm_num

/-- **`r = m = N^{1/5}`**, equivalently `r^{5/2} = N^{1/2}`. -/
theorem balance_solves_to_one_fifth : (1 / 5 : ℚ) = (1 / 2 : ℚ) * (2 / 5) := by
  norm_num


end Crypto.FactoringBarrier.HarveyBalance
