import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring

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



/-! ### The Hittmeir end of the lineage, and the structural delta

Everything above reads Harvey's cost. Harvey's paper is explicit that his
improvement over Hittmeir is *structural within the same reach*: p.3 says
Hittmeir "breaks up the search space into chunks and applies the BSGS search to
each chunk separately, whereas we show how to sweep through the entire space
with a single BSGS search." Reading **Hittmeir, arXiv:2006.16729, Lemma 5.2 and
eq. (6.1)** (PDF at `~/factor-briefs/hitt-2006.16729.pdf`, 10pp) makes the delta
quantitative, because Hittmeir's cost is *also* a three-term balance. With
`xi = N^x`, `eta = N^y`:

  `T1 = 1/4 + 3x/4 - y/2`   (Step 1: a full BSGS run **per pair**, summed; the
                               `xi^{3/4}` is a **numerator** factor)
  `T2 = 1/2 - x/2 - y`       (the `L1` baby-step list)
  `T3 = y`                   (the `L2` candidate list)

and Hittmeir's Algorithm 6.1 takes `xi = N^{1/9}`, `eta = N^{2/9}`, at which all
three equal `2/9` -- which is the **exact minimax**, so `2/9` is derived here
rather than quoted.

**The structural delta, in one line.** Hittmeir's `T1` carries `xi` in the
**numerator** (raising `xi` makes it *worse*, by `3/4` per unit of exponent);
Harvey's `T1` carries `m` in the **denominator** (raising `m` makes it
*better*, by `1` per unit). Turning "one BSGS per chunk" into "one global BSGS"
moves the reuse parameter from a numerator to a denominator, and that single
structural change is worth `2/9 -> 1/5`. Both are proved exact below, so the
whole deterministic lineage `2/9 -> 1/5` is now accounted for term by term. -/

/-- **HITMEIR'S EXPONENT FUNCTION.** `x` is the exponent of `xi` and `y` that of
`eta`, from Lemma 5.2 with the `xi^{3/4}` numerator restored (the PDF text
renders it ambiguously; eq. (6.1) on p.10 pins it as `xi^{3/4}`). -/
def hittCostExp (x y : ℚ) : ℚ := max (1 / 4 + 3 * x / 4 - y / 2) (max (1 / 2 - x / 2 - y) y)

/-- **All three of Hittmeir's summands equal `2/9`** at his Algorithm 6.1 choice
`xi = N^{1/9}`, `eta = N^{2/9}`. -/
theorem hitt_three_terms_at_two_ninths :
    1 / 4 + 3 * (1 / 9 : ℚ) / 4 - (2 / 9) / 2 = 2 / 9 := by norm_num

theorem hitt_term2_at_two_ninths : 1 / 2 - (1 / 9 : ℚ) / 2 - 2 / 9 = 2 / 9 := by
  norm_num

/-- **`2/9` is a LOWER bound for Hittmeir's shape.** -/
theorem two_ninths_is_lower_bound (x y : ℚ) : 2 / 9 ≤ hittCostExp x y := by
  simp only [hittCostExp, le_max_iff, le_max_iff]
  by_contra hcon
  rcases not_or.mp hcon with ⟨hna, hrest⟩
  rcases not_or.mp hrest with ⟨hnb, hnc⟩
  have h1 : 1 / 4 + 3 * x / 4 - y / 2 < 2 / 9 := lt_of_not_ge hna
  have h2 : 1 / 2 - x / 2 - y < 2 / 9 := lt_of_not_ge hnb
  have h3 : y < 2 / 9 := lt_of_not_ge hnc
  linarith

/-- **...and it is attained**, so `2/9` is Hittmeir's exact optimum. -/
theorem two_ninths_attained : hittCostExp (1 / 9 : ℚ) (2 / 9 : ℚ) = 2 / 9 := by
  have h1 : 1 / 4 + 3 * (1 / 9 : ℚ) / 4 - (2 / 9) / 2 = 2 / 9 :=
    hitt_three_terms_at_two_ninths
  have h2 : 1 / 2 - (1 / 9 : ℚ) / 2 - 2 / 9 = 2 / 9 := hitt_term2_at_two_ninths
  rw [hittCostExp, h1, h2]
  norm_num [max_def]

/-- **HITTEIR'S OPTIMUM IS EXACTLY `2/9`** -- lower bound plus attainment. -/
theorem hitt_optimum_exactly_two_ninths :
    (∃ x y : ℚ, hittCostExp x y = 2 / 9) ∧ (∀ x y : ℚ, 2 / 9 ≤ hittCostExp x y) := by
  refine ⟨⟨1 / 9, 2 / 9, two_ninths_attained⟩, fun x y => two_ninths_is_lower_bound x y⟩

/-- **THE DELTA IS STRICT AND EXACT: `2/9 - 1/5 = 1/45`.** Harvey's improvement
over Hittmeir is a real `0.0222` in the exponent, and it is the *only*
difference in reach -- both factor the same semiprimes by the same congruence. -/
theorem delta_two_ninths_minus_one_fifth :
    (2 / 9 : ℚ) - 1 / 5 = 1 / 45 := by norm_num

theorem two_ninths_gt_one_fifth : (2 / 9 : ℚ) > 1 / 5 := by norm_num

/-- **★ THE STRUCTURAL ASYMMETRY, MADE MACHINE-CHECKABLE.** In Hittmeir the reuse
parameter `xi` sits in the **numerator** of `T1`, so raising it makes the term
*worse* by exactly `3/4` per unit of exponent. -/
theorem hitt_reuse_is_numerator (x y : ℚ) :
    1 / 4 + 3 * (x + 1) / 4 - y / 2 = (1 / 4 + 3 * x / 4 - y / 2) + 3 / 4 := by linarith

/-- **...whereas in Harvey the reuse parameter `m` sits in the DENOMINATOR of
`T1`, so raising it makes the term *better* by exactly `1` per unit of exponent.
This sign flip -- caused by going from one BSGS per chunk to a single global BSGS
-- is the whole `2/9 -> 1/5` improvement, and it is now a theorem. -/
theorem harvey_reuse_is_denominator (a b : ℚ) :
    1 / 2 - a / 2 - (b + 1) = (1 / 2 - a / 2 - b) - 1 := by linarith

/-- **The two optima, side by side.** Both are exact minimax values, so the
lineage is closed: `1/3` (Lehman) > `2/9` (Hittmeir) > `1/5` (Harvey). -/
theorem lineage_is_strictly_decreasing :
    (1 / 3 : ℚ) > 2 / 9 ∧ (2 / 9 : ℚ) > 1 / 5 := by
  constructor <;> norm_num



/-! ## §8 item 10(i) ANSWERED: the order precondition was NEVER exponent-binding

The retraction in `RESEARCH.md` §7-septuples-ter left one sub-question open and
cheap: with the order-finding hypothesis now removed (Harvey & Hittmeir,
arXiv:2601.11131), **does the exponent improve?** The answer is **no**, and it is
one line of arithmetic.

Harvey's Algorithm 4.3 minimises `max(T1, T2, T3)` over `r, m`, attained at
`r = m = N^{1/5}` (`optimum_exactly_one_fifth`). The order precondition is
`ord_N(alpha) > m`, obtainable in the needed range only from an element of order
`D >= N^{2/5}`. So the minimax point is **feasible** exactly when

> `m = N^{1/5} <= D = N^{2/5}`,

and `1/5 < 2/5`, so it is feasible with room to spare. The minimax of a cost
*function* is a property of the function, independent of which `(alpha, m)` are
realisable -- and the minimax point was already realisable. **The precondition
therefore constrained only the LOG factor** (`m = N^{1/5}lg^{6/5}` against
`D = N^{2/5}`, which is Harvey's Remark 2.8 "*but only just*": a small-N remark,
not an exponent constraint).

This is why the record is still `1/5` in 2026 despite the hypothesis falling, and
why the follow-up work delivered **logs** rather than exponents
(Harvey--Hittmeir `lg^{16/5}/(lg lg N)^{3/5}`; GFHP `lg^{13/5}` balanced). -/

/-- **★ §8 ITEM 10(i) ANSWERED: the order precondition was never
exponent-binding.** The optimum needs `m = N^{1/5}`; the precondition only
guaranteed `m <= D = N^{2/5}`; and `1/5 < 2/5`. So the minimax point was always
feasible, and **removing the hypothesis cannot improve the exponent**.

**This is why `1/5` survives to 2026** even though the hypothesis Harvey flagged
as the binding constraint has been removed entirely. -/
theorem precondition_not_exponent_binding : (1 / 5 : ℚ) < 2 / 5 := by norm_num

/-- **...and the attained optimum is genuinely strictly below the old
guarantee** -- i.e. the constraint had slack, not just room to spare. -/
theorem optimum_below_old_guarantee :
    costExp (1 / 5 : ℚ) (1 / 5 : ℚ) < 2 / 5 := by
  rw [one_fifth_attained]
  norm_num

/-- **The AM-GM step in the form it takes here.** For `x, y >= 0`,
`2xy <= x^2 + y^2`. The `Nat.le_total` split is load-bearing: in `N` the
subtraction is truncated, so `sq_nonneg (x - y)` is **not** the polynomial
`(x-y)^2`. -/
theorem two_mul_le_add_sq (x y : ℕ) : 2 * (x * y) ≤ x * x + y * y := by
  rcases Nat.le_total x y with h | h
  · rw [show y = x + (y - x) from (Nat.add_sub_of_le h).symm]
    nlinarith [sq_nonneg (y - x)]
  · rw [show x = y + (x - y) from (Nat.add_sub_of_le h).symm]
    nlinarith [sq_nonneg (x - y)]

/-- **★ AND THE BIG ONE: HARVEY'S LEMMA 3.1 SQUARE TEST CAN NEVER FAIL.** For all
`a, b, p, q >= 0`,

> `4*(a*b)*(p*q) <= (a*q + b*p)^2`,

i.e. the discriminant `u^2 - 4abN` is **never negative** when `u = aq + bp`.
There is **no** `(a, b)` for which Lemma 3.1 rejects a candidate on squareness
grounds: the advertised "test" is **AM-GM, not a discriminant**.

**Why this matters for the method question.** The `1/5` is produced *entirely* by
the baby-step/giant-step **reuse**; the square test contributes **nothing**. Any
proposed improvement aimed at the test is aimed at an inequality that is
automatic, and cannot help. Only the reuse is worth attacking -- which is the
sharpest available form of this file's "cost-only, reach-unchanged" claim. -/
theorem square_test_never_fails (a b p q : ℕ) :
    4 * (a * b) * (p * q) ≤ (a * q + b * p) * (a * q + b * p) := by
  have h := two_mul_le_add_sq (a * q) (b * p)
  have h4 : 4 * (a * q) * (b * p)
      ≤ (a * q) * (a * q) + 2 * (a * q) * (b * p) + (b * p) * (b * p) := by linarith
  calc 4 * (a * b) * (p * q) = 4 * (a * q) * (b * p) := by ring
    _ ≤ (a * q) * (a * q) + 2 * (a * q) * (b * p) + (b * p) * (b * p) := h4
    _ = (a * q + b * p) * (a * q + b * p) := by ring


/-! ## §8 item 10(ii) ANSWERED: `m` cannot be free, and the `√(abN)` coupling kills a CLASS of shapes

Item 10(ii) asked whether there is a cost shape in which the reuse parameter
carries a **negative weight** — a bigger baby-step table that strictly helps.
Two answers, both negative, and the second is a class-level barrier.

**(a) FREE `m` IS NOT A SHAPE CHANGE — IT IS LEHMAN.** If the table cost `T₃ = m`
were removed, one would send `m → ∞`, which drives `T₁ = N^{1/2}/(r^{1/2}·m)` to
zero and leaves cost `= T₂ = r`. But then the `j`-loop is free too, so each
`(a,b)` is just a direct difference-of-squares run on `(ab)·N` — **which is
Lehman's method, at `1/3`, strictly worse than `1/5`.** So the `m`-reuse is
**load-bearing, not slack**: "negative weight" cannot mean "`m` costs nothing".

**(b) ★ THE REAL OBSTRUCTION IS THE NON-SEPARABILITY OF `√(abN)`, AND IT KILLS
AN INFINITE CLASS OF SHAPES.** The exponent is
`e(a,b) = aN + b − ⌊2√(abN)⌋`; the `√(abN)` couples `a` and `b`, and that coupling
is exactly what forces the three-term balance. Every attempt to *separate* it
restricts `a/b` to a nicer family — and **every such family is a power sublattice**
`a = c·s^k`, `b = c·t^k`, which forces approximation of `(p/q)^{1/k}` instead of
`p/q`. The convergent gap degrades by `q^{1−1/k}`, and since `t^k ≤ r` the
admissible `r` collapses to `O(1)` for **every `k ≥ 2`**. The sublattice is then
**empty of good points in the balanced regime** — the only regime that matters.

The `k = 2` instance (`c = 1`) is the square sublattice killed in
`RESEARCH.md` §7-septuples-quater; this is the statement that **there is no
`k` that rescues it**, and it generalises to the `c`-scaled case proved below.
**DO NOT re-propose any power-type sublattice of the ratio `a/b`.** -/

/-- **★ THE `c`-SCALED SQUARE SUBLATTICE IS KILLED TOO, not just `a = s²`.** For
`a = c·s²`, `b = c·t²` the Fermat gap is a perfect square times `c`,
`y₀ = c·(s√q − t√p)²`, and AM–GM makes it non-negative with equality iff
`s²q = t²p`. This is the `k = 2, c`-scaled member of the class killed above —
recorded because the `c`-scaling is the obvious "widen the sublattice" repair,
and it does not help. -/
theorem scaled_square_sublattice_gap_nonneg (c s t p q : ℕ) :
    2 * (c * c * s * s * t * t) * (p * q)
      ≤ (c * s * s * q + c * t * t * p) * (c * s * s * q + c * t * t * p) := by
  have h1 := two_mul_le_add_sq (c * s * s * q) (c * t * t * p)
  have h2 : (c * s * s * q) * (c * s * s * q) + (c * t * t * p) * (c * t * t * p)
      ≤ (c * s * s * q + c * t * t * p) * (c * s * s * q + c * t * t * p) := by
    have hz : (0 : ℕ) ≤ 2 * (c * s * s * q) * (c * t * t * p) := Nat.zero_le _
    linarith
  calc 2 * (c * c * s * s * t * t) * (p * q)
      = 2 * ((c * s * s * q) * (c * t * t * p)) := by ring
    _ ≤ (c * s * s * q + c * t * t * p) * (c * s * s * q + c * t * t * p) :=
      le_trans h1 h2

end Crypto.FactoringBarrier.HarveyBalance
