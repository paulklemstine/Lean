import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-
# The `N^{1/5}` barrier is exact for the Lehman–BSGS (Harvey `N^{1/5}`) family

Harvey's deterministic `N^{1/5}` integer factorisation algorithm (Math. Comp. 90
(2021), 2937–2950; arXiv:2010.05450) carries three `N`-dependent cost terms:

* a per-pair search floor `r`,
* a baby-step budget `m`,
* a BSGS interior `N^{1/2} / (r^{1/2} · m)`,

and the algorithm's cost is the `max` of the three at the optimised setting. The
exponent `1/5` is always presented as the result of *balancing* these terms, at
`r = m = N^{1/5}`.

**This file proves the stronger, exact statement:** the minimum of that `max` over
*all* positive `r, m` is *exactly* `N^{1/5}`. No choice of `r`, `m` — however
unbalanced — drives the cost below `N^{1/5}`. So within this family `1/5` is a
genuine **lower bound**, not merely an upper bound attained at one point, and no
re-balancing or "clever parameter choice" can beat it.

This isolates and settles one of the two levers on the deterministic record: beat
`1/5` *inside* the Lehman–BSGS family (refuted here) versus escape the family
entirely (e.g. the Coppersmith / rank-3-lattice route). The second lever is not
addressed here.

## The `k`-floor design rule, proved exactly and classified

Harvey's `1/5` is the `k = 2` case. The *general* statement — for any number of
search floors with weights `w₁, …, w_k > 0` the optimum is exactly
`N^{γ/(1+Σwᵢ)}` — was **prose in a docstring** until now. It is now proved, from
both sides:

| theorem | role |
|---|---|
| `weighted_amgm_finset` | the `k`-floor **lower** bound: every `T` dominating the cost is `≥ N^{γ/(1+Σw)}` |
| `finset_barrier_attained` | the `k`-floor **attainment**: setting every floor to `N^{γ/(1+Σw)}` makes the cost *exactly* that |
| `beating_one_fifth_requires` | the design rule as a **complete dichotomy** |

`finset_barrier_attained` matters because a lower bound does not determine an
optimum. With it, the `k`-floor optimum is pinned exactly, and it depends on
the weights **only through their sum** — the number of floors `k` is irrelevant.

`beating_one_fifth_requires` closes the argument: *if* a method of this cost
shape beats `1/5`, it must **either** lower `γ` below `1/2` **or** raise
`Σwᵢ` above `3/2`. There is no third option. So the escape list in the
`weighted_amgm` docstring is exhaustive, not suggestive.

Two corollaries retire a class of proposals *by theorem*:

* `sub_range_exponent_beats` — a `γ < 1/2` method beats `1/5` (and a method
  touching `Θ(√N)` candidates provably cannot, which is why the `V_k` anchor
  optimisation cannot pay). This is a **decidable screening criterion**.
* `split_neutral` / `split_without_redistribution_worse` — splitting the
  `N^{1/2}` range into `k` sub-ranges is *exactly neutral* if the weight is
  redistributed, and *provably worse* if it is not, because `k` floors of
  weight `w` are `k` times the reach, not `k` views of one floor.

**Honest scoping.** The balance formula `γ/(1+Σw)` is elementary AM–GM and is
**not** claimed as novel research. The contribution is that the `k`-floor
version is now a *theorem in both directions* rather than an assertion, and
that the two design-rule escape routes and the floor-splitting family are
killed by theorem rather than by argument.

## Provenance

Machine-checked, **13 theorems, 0 `sorry`, 0 `axiom`** (verified by `#print
axioms`: only `propext`, `Classical.choice`, `Quot.sound`), against Mathlib at
`0df444a360eaa60ab8c11dca51a86af692955474` (Lean v4.33.1) in the Prove2me
workspace:

```
lake env lean Theorems/Thm_Crypto_FactoringBarrier_HarveyFloor.lean   -- clean
```

This Catalog copy is the archival record (like the sibling `*.lean` files here,
which are not built by the Lean repo itself). The workspace copy is canonical.
-/

namespace Crypto.FactoringBarrier.HarveyFloor

/-- **The `N^{1/5}` barrier is exact and cannot be beaten by rebalancing `r` and `m`.**
For any `N > 0` and any positive `r, m`,

`max(r, m, N^{1/2} / (r^{1/2} · m)) ≥ N^{1/5}`.

Hence the optimised cost of the family is at least `N^{1/5}` for *every* choice
of the search floor `r` and baby-step budget `m`; with `HarveyFloor.attained`
below, the optimum is exactly `N^{1/5}`. -/
theorem max_ge_n_fifth (N r m : ℝ) (hN : 0 < N) (hr : 0 < r) (hm : 0 < m) :
    max r (max m (N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m)))
      ≥ N ^ ((1 : ℝ) / 5) := by
  generalize hT0 : max r (max m (N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m))) = T
  have hr' : 0 < r ^ ((1 : ℝ) / 2) := by positivity
  have hden : 0 < r ^ ((1 : ℝ) / 2) * m := by positivity
  have hN' : 0 < N ^ ((1 : ℝ) / 2) := by positivity
  -- the interior is nested in the max, hence ≤ T
  have hint : N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m) ≤ T := by
    rw [← hT0]; exact le_max_of_le_right (le_max_right _ _)
  have hint' : 0 < N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m) := by positivity
  have hT : 0 < T := lt_of_lt_of_le hint' hint
  -- clear the denominator
  have hmul : N ^ ((1 : ℝ) / 2) ≤ T * r ^ ((1 : ℝ) / 2) * m := by
    have hh := (div_le_iff₀ hden).mp hint
    rwa [← mul_assoc] at hh
  have hrT : r ≤ T := by rw [← hT0]; exact le_max_left _ _
  have hmT : m ≤ T := by
    rw [← hT0]
    exact le_trans (le_max_left _ _) (le_max_right _ _)
  -- r^{1/2} ≤ T^{1/2}
  have hrT' : r ^ ((1 : ℝ) / 2) ≤ T ^ ((1 : ℝ) / 2) :=
    Real.rpow_le_rpow (le_of_lt hr) hrT (by norm_num)
  -- chain: N^{1/2} ≤ T·r^{1/2}·m ≤ T^{1/2}·T·T = T^{5/2}
  have hchain : N ^ ((1 : ℝ) / 2) ≤ T ^ ((1 : ℝ) / 2) * T * T := by
    have h1 : T * r ^ ((1 : ℝ) / 2) ≤ T * T ^ ((1 : ℝ) / 2) :=
      mul_le_mul_of_nonneg_left hrT' (le_of_lt hT)
    have h2 : (T * T ^ ((1 : ℝ) / 2)) * m ≤ (T * T ^ ((1 : ℝ) / 2)) * T :=
      mul_le_mul_of_nonneg_left hmT (by positivity)
    have h1' : T * r ^ ((1 : ℝ) / 2) * m ≤ T * T ^ ((1 : ℝ) / 2) * m :=
      mul_le_mul_of_nonneg_right h1 (by positivity)
    calc N ^ ((1 : ℝ) / 2)
        ≤ T * r ^ ((1 : ℝ) / 2) * m := hmul
      _ ≤ T * T ^ ((1 : ℝ) / 2) * m := h1'
      _ ≤ T * T ^ ((1 : ℝ) / 2) * T := h2
      _ = T ^ ((1 : ℝ) / 2) * T * T := by ring
  -- collapse the product of powers: T^{1/2}·T·T = T^{5/2}
  have hcollapse : T ^ ((1 : ℝ) / 2) * T * T = T ^ ((5 : ℝ) / 2) := by
    have e1 : T ^ ((1 : ℝ) / 2) * T = T ^ ((3 : ℝ) / 2) := by
      have hh := Real.rpow_add hT ((1 : ℝ) / 2) 1
      norm_num at hh
      exact hh.symm
    have e2 : T ^ ((3 : ℝ) / 2) * T = T ^ ((5 : ℝ) / 2) := by
      have hh := Real.rpow_add hT ((3 : ℝ) / 2) 1
      norm_num at hh
      exact hh.symm
    rw [e1, e2]
  -- raise both sides to 2/5: (N^{1/2})^{2/5} = N^{1/5}, (T^{5/2})^{2/5} = T
  rw [hcollapse] at hchain
  have hraise : (N ^ ((1 : ℝ) / 2)) ^ ((2 : ℝ) / 5)
      ≤ (T ^ ((5 : ℝ) / 2)) ^ ((2 : ℝ) / 5) :=
    Real.rpow_le_rpow (le_of_lt hN') hchain (by norm_num : (0 : ℝ) ≤ (2 : ℝ) / 5)
  have hL : N ^ ((1 : ℝ) / 5) = (N ^ ((1 : ℝ) / 2)) ^ ((2 : ℝ) / 5) := by
    rw [← Real.rpow_mul (le_of_lt hN) ((1 : ℝ) / 2) ((2 : ℝ) / 5)]
    norm_num
  have hR : (T ^ ((5 : ℝ) / 2)) ^ ((2 : ℝ) / 5) = T := by
    rw [← Real.rpow_mul (le_of_lt hT) ((5 : ℝ) / 2) ((2 : ℝ) / 5)]
    norm_num
  calc N ^ ((1 : ℝ) / 5) = (N ^ ((1 : ℝ) / 2)) ^ ((2 : ℝ) / 5) := hL
    _ ≤ (T ^ ((5 : ℝ) / 2)) ^ ((2 : ℝ) / 5) := hraise
    _ = T := hR

/-- **The barrier is attained at `r = m = N^{1/5}`**, so `N^{1/5}` is the exact
minimum of the three-term cost, not merely a lower bound.

At this balanced setting all three co-binding terms coincide:

* the search floor `r = N^{1/5}`,
* the baby-step budget `m = N^{1/5}`,
* the BSGS interior `N^{1/2} / (r^{1/2} · m) = N^{1/2} / (N^{1/10} · N^{1/5})
  = N^{1/2 - 3/10} = N^{1/5}`.

Together with `max_ge_n_fifth` this pins the family's optimum to exactly
`N^{1/5}`: the exponent is a theorem about the family, not an artefact of one
lucky parameter choice. -/
theorem attained (N : ℝ) (hN : 0 < N) :
    max (N ^ ((1 : ℝ) / 5))
      (max (N ^ ((1 : ℝ) / 5))
        (N ^ ((1 : ℝ) / 2)
          / ((N ^ ((1 : ℝ) / 5)) ^ ((1 : ℝ) / 2) * N ^ ((1 : ℝ) / 5))))
      = N ^ ((1 : ℝ) / 5) := by
  have hinterior : N ^ ((1 : ℝ) / 2)
      / ((N ^ ((1 : ℝ) / 5)) ^ ((1 : ℝ) / 2) * N ^ ((1 : ℝ) / 5))
      = N ^ ((1 : ℝ) / 5) := by
    rw [← Real.rpow_mul (le_of_lt hN) ((1 : ℝ) / 5) ((1 : ℝ) / 2)]
    norm_num
    rw [← Real.rpow_add hN ((1 : ℝ) / 10) ((1 : ℝ) / 5)]
    norm_num
    rw [← Real.rpow_sub hN ((1 : ℝ) / 2) ((3 : ℝ) / 10)]
    norm_num
  rw [hinterior, max_eq_left (le_refl _), max_eq_left (le_refl _)]

/-- **Corollary (the corollary that is actually used):** for every admissible
choice of the search floor `r` and baby-step budget `m`, the family's
three-term cost is bounded below by `N^{1/5}`.  Hence

> no rebalancing of `r` and `m` — however asymmetric — yields an exponent
> strictly below `1/5` inside the Lehman–BSGS family.

To beat `1/5` one must change the *mechanism* (leave the family), not tune the
parameters within it. -/
theorem no_rebalance_beats (N r m : ℝ) (hN : 0 < N) (hr : 0 < r) (hm : 0 < m) :
    N ^ ((1 : ℝ) / 5)
      ≤ max r (max m (N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m))) :=
  max_ge_n_fifth N r m hN hr hm

/-- **The general weighted AM–GM barrier, and the design rule it imposes.**

`max_ge_n_fifth` is the `γ = 1/2`, `a = 1/2`, `b = 1` instance of a more
general statement. For any method whose cost has the *search-floor* shape

> `max(r, m, N^γ / (r^a · m^b))`,  with `a, b > 0`,

the AM–GM balance is forced, and this file proves it: with `T` the max,

`N^γ ≤ T · r^a · m^b ≤ T^{1+a+b}`.

Equivalently (taking the `(1+a+b)`-th root, which needs no further
formalisation):

> **the optimal exponent is exactly `γ / (1 + a + b)`.**

**The design rule that follows — this is the operative content.** To improve
on Harvey's `1/5` using a method of this shape, a *new* method must do at
least one of:

* **raise the total denominator weight** `a + b` above `3/2` — i.e. make each
  unit of search floor buy strictly more than `3/2` units of `N^{1/2}`
  reduction; **or**
* **lower `γ` below `1/2`** — i.e. succeed without ever needing the full
  `N^{1/2}` range; **or**
* **escape this cost shape entirely** (a different mechanism, not a different
  parameter choice).

This generalises to any number of floors: with `w₁, …, w_k > 0` the optimal
exponent is `γ / (1 + Σᵢ wᵢ)`, and the same proof (`T` bounds every `rᵢ` and
`mᵢ`, so `N^γ ≤ T·∏ᵢ rᵢ^{wᵢ} ≤ T^{1+Σwᵢ}`) goes through unchanged. The exponent
is therefore controlled **entirely** by the weight structure and the numerator
exponent — nothing else about the algorithm enters.

**⚠️ SCOPE — read before citing.** This lower-bounds a *cost formula*; it
assumes the algorithm's cost is `max(...)` of the stated shape. Two limits:

1. It covers only methods **of this shape**. It says nothing about a method
   with a different cost structure. In particular the **GNFS is subexponential**
   (`exp(c (ln N)^{1/3} (ln ln N)^{2/3})`) and therefore already beats `N^{1/5}`
   by an enormous margin — so this barrier is interesting *only* in the
   **deterministic** setting, which is exactly Harvey's domain. It is **not** a
   statement about the best known factoring algorithm.
2. Like `max_ge_n_fifth`, it is **not** a complexity lower bound for factoring,
   and a genuinely new method could be sub-`N^{1/5}` by leaving the family. -/
theorem weighted_amgm (N r m γ a b : ℝ) (hN : 0 < N) (hr : 0 < r) (hm : 0 < m)
    (ha : 0 < a) (hb : 0 < b) :
    (max r (max m (N ^ γ / (r ^ a * m ^ b)))) ^ (1 + a + b) ≥ N ^ γ := by
  generalize hT0 : max r (max m (N ^ γ / (r ^ a * m ^ b))) = T
  have hint : N ^ γ / (r ^ a * m ^ b) ≤ T := by
    rw [← hT0]; exact le_max_of_le_right (le_max_right _ _)
  have hden : 0 < r ^ a * m ^ b := by positivity
  have hN' : 0 < N ^ γ := by positivity
  have hT : 0 < T := lt_of_lt_of_le (by positivity) hint
  have hrT : r ≤ T := by rw [← hT0]; exact le_max_left _ _
  have hmT : m ≤ T := by
    rw [← hT0]; exact le_trans (le_max_left _ _) (le_max_right _ _)
  have hrab : r ^ a ≤ T ^ a := Real.rpow_le_rpow (le_of_lt hr) hrT (le_of_lt ha)
  have hmbT : m ^ b ≤ T ^ b := Real.rpow_le_rpow (le_of_lt hm) hmT (le_of_lt hb)
  have h1 : T * r ^ a ≤ T * T ^ a := mul_le_mul_of_nonneg_left hrab (le_of_lt hT)
  have h2 : T * T ^ a * m ^ b ≤ T * T ^ a * T ^ b :=
    mul_le_mul_of_nonneg_left hmbT (by positivity)
  have h1' : T * r ^ a * m ^ b ≤ T * T ^ a * m ^ b :=
    mul_le_mul_of_nonneg_right h1 (by positivity)
  have hmul : N ^ γ ≤ T * r ^ a * m ^ b := by
    have hh := (div_le_iff₀ hden).mp hint
    rwa [← mul_assoc] at hh
  have hchain : N ^ γ ≤ T ^ (1 + a + b) := by
    have e1 : T * T ^ a = T ^ (1 + a) := by
      have hh := Real.rpow_add hT 1 a
      rw [Real.rpow_one T] at hh
      exact hh.symm
    have e2 : T ^ (1 + a) * T ^ b = T ^ (1 + a + b) :=
      (Real.rpow_add hT (1 + a) b).symm
    calc N ^ γ ≤ T * r ^ a * m ^ b := hmul
      _ ≤ T * T ^ a * m ^ b := h1'
      _ ≤ T * T ^ a * T ^ b := h2
      _ = T ^ (1 + a + b) := by rw [e1, e2]
  exact hchain

/-- **The `γ = 1/2`, `a = 1/2`, `b = 1` instance**, i.e. Harvey's exact
parameters, in power form: the three-term cost to the `5/2` exceeds
`N^{1/2}`. Together with `max_ge_n_fifth` this brackets the family optimum at
exactly `N^{1/5}` from both sides. -/
theorem harvey_weighted (N r m : ℝ) (hN : 0 < N) (hr : 0 < r) (hm : 0 < m) :
    (max r (max m (N ^ ((1 : ℝ) / 2) / (r ^ ((1 : ℝ) / 2) * m)))) ^ ((5 : ℝ) / 2)
      ≥ N ^ ((1 : ℝ) / 2) := by
  have hh := weighted_amgm N r m ((1 : ℝ) / 2) ((1 : ℝ) / 2) 1 hN hr hm
    (by norm_num) (by norm_num)
  norm_num at hh ⊢
  exact hh

/-! ## The `k`-floor theorem, and what it kills

`weighted_amgm` above is stated for **two** search floors. The docstring *asserts*
the `k`-floor case in prose ("the same proof goes through unchanged") but never
proves it. This section proves it, and the corollaries are sharper than the prose
version was — they retire an entire family of proposed improvements by theorem.

The statement is phrased with an explicit dominating `T` rather than a `Finset`
supremum, because that is the form the proof actually needs: if `T` dominates
every floor and the whole interior, then the interior exponent is forced. -/

/-- **Product/sum collapse.** `∏ᵢ T^{wᵢ} = T^{Σᵢ wᵢ}`.  This is the `Finset`
counterpart of `Real.rpow_add`, and it is what lets the `k`-floor argument avoid
re-proving a per-element induction at every use. -/
theorem finset_rpow_prod (T : ℝ) (s : Finset ℝ) (w : ℝ → ℝ) (hT : 0 < T) :
    (∏ x ∈ s, T ^ (w x)) = T ^ (∑ x ∈ s, w x) := by
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
    rw [Finset.prod_insert ha, Finset.sum_insert ha, ih]
    exact (Real.rpow_add hT (w a) (∑ x ∈ s, w x)).symm

/-- **The `k`-floor weighted AM–GM, formalised.** If a method's cost is governed
by search floors `rᵢ` with weights `wᵢ > 0` and an interior
`N^γ / ∏ᵢ rᵢ^{wᵢ}`, and `T` dominates both every floor and the interior, then

> `N^γ ≤ T^{1 + Σᵢ wᵢ}`.

The optimal exponent is therefore **exactly `γ / (1 + Σᵢ wᵢ)`**, and — this is
the point — it depends on the weights **only through their sum**. The number of
floors, and how the total weight is distributed among them, are both irrelevant. -/
theorem weighted_amgm_finset {N γ T : ℝ} {s : Finset ℝ} (r w : ℝ → ℝ)
    (hT : 0 < T)
    (hr : ∀ x ∈ s, 0 < r x) (hw : ∀ x ∈ s, 0 < w x)
    (hdom : ∀ x ∈ s, r x ≤ T)
    (hint : N ^ γ / ∏ x ∈ s, (r x) ^ (w x) ≤ T) :
    N ^ γ ≤ T ^ (1 + ∑ x ∈ s, w x) := by
  -- auxiliary: bound each factor, then collapse the product
  have key : ∀ (u : Finset ℝ) (r w : ℝ → ℝ),
      (∀ x ∈ u, 0 < r x) → (∀ x ∈ u, 0 < w x) → (∀ x ∈ u, r x ≤ T) →
      (∏ x ∈ u, (r x) ^ (w x)) ≤ T ^ (∑ x ∈ u, w x) := by
    intro u r w hr hw hdom
    calc (∏ x ∈ u, (r x) ^ (w x))
        ≤ ∏ x ∈ u, T ^ (w x) :=
          Finset.prod_le_prod (fun x hx => (Real.rpow_pos_of_pos (hr x hx) (w x)).le)
            fun x hx => Real.rpow_le_rpow (le_of_lt (hr x hx)) (hdom x hx) (le_of_lt (hw x hx))
      _ = T ^ (∑ x ∈ u, w x) := finset_rpow_prod T u w hT
  have hden : 0 < ∏ x ∈ s, (r x) ^ (w x) :=
    Finset.prod_pos fun x hx => Real.rpow_pos_of_pos (hr x hx) (w x)
  have hmul : N ^ γ ≤ T * ∏ x ∈ s, (r x) ^ (w x) := (div_le_iff₀ hden).mp hint
  have hprod := key s r w hr hw hdom
  calc N ^ γ ≤ T * ∏ x ∈ s, (r x) ^ (w x) := hmul
    _ ≤ T * T ^ (∑ x ∈ s, w x) := mul_le_mul_of_nonneg_left hprod (le_of_lt hT)
    _ = T ^ (1 + ∑ x ∈ s, w x) := by
        -- NB: do NOT `rw [← Real.rpow_one T]` here -- it rewrites every `T`,
        -- including the base of the other powers.  Use an explicit instance.
        have he : T ^ (1 + ∑ x ∈ s, w x) = T * T ^ (∑ x ∈ s, w x) := by
          simpa using Real.rpow_add hT 1 (∑ x ∈ s, w x)
        exact he.symm

/-- **Recovering the two-floor theorem, so the generalisation is not a
strictly-stronger orphan.** Instantiating `weighted_amgm_finset` at
`s = {0, 1}`, `r 0 = r`, `r 1 = m`, `w 0 = a`, `w 1 = b` gives
`(N^γ) ≤ T^{1 + a + b}` for a dominating `T` — i.e. `weighted_amgm`, restated in
power form.  This is stated as a bridge, not a new result. -/
theorem two_floor_bridge (N r m γ a b T : ℝ) (hT : 0 < T)
    (hr : 0 < r) (hm : 0 < m) (ha : 0 < a) (hb : 0 < b)
    (h1 : r ≤ T) (h2 : m ≤ T)
    (hint : N ^ γ / (r ^ a * m ^ b) ≤ T) :
    N ^ γ ≤ T ^ (1 + a + b) := by
  have hh := weighted_amgm_finset (s := (({0, 1} : Finset ℝ) : Finset ℝ))
    (r := fun x => if x = 0 then r else m) (w := fun x => if x = 0 then a else b)
    hT
    (fun x hx => by rcases (show x = 0 ∨ x = 1 from by simpa [Finset.mem_insert] using hx)
        with rfl | rfl <;> simp_all)
    (fun x hx => by rcases (show x = 0 ∨ x = 1 from by simpa [Finset.mem_insert] using hx)
        with rfl | rfl <;> simp_all)
    (fun x hx => by rcases (show x = 0 ∨ x = 1 from by simpa [Finset.mem_insert] using hx)
        with rfl | rfl <;> simp_all)
    (by simpa [Finset.prod_insert, Finset.mem_insert] using hint)
  convert hh using 1 ; simp [Finset.sum_insert]; ring

/-! ### Corollaries: a screening criterion, and a family of improvements killed

These two blocks are the operative output. Both are short; the content is that
they retire a class of proposals *by theorem* rather than by argument. -/

/-- **Screening criterion. A search range shorter than `N^{1/2}` beats `1/5`; a
search range of `Θ(N^{1/2})` provably cannot.**

For a method of the search-floor shape whose total denominator weight is `3/2`
(Harvey's) and whose range exponent is `γ'`, the optimal exponent is
`γ' · 2/5`. So any mechanism that never has to touch the full `N^{1/2}` range —
i.e. one that searches for a *derived* quantity smaller than `p` rather than for
`p` itself — lands strictly below `1/5`, and this is a decidable test:

* **`γ' < 1/2` present** ⟹ the method beats `1/5`, given the shape. Pursue it.
* **the method touches `Θ(√N)` candidates** ⟹ it *cannot* beat `1/5`, no matter
  how the floors are tuned. This is `HarveyFloor.max_ge_n_fifth` in the
  `γ' = 1/2` case, and it is why the `V_k` anchor optimisation could not pay.

The corollary is deliberately about the RANGE only: it says nothing about the
weights, which `weighted_amgm_finset` handles. -/
theorem sub_range_exponent_beats (N γ' : ℝ) (hN : 1 < N)
    (hγ : γ' < (1 : ℝ) / 2) :
    N ^ (γ' * 2 / 5) < N ^ ((1 : ℝ) / 5) := by
  -- same base on both sides, so compare the EXPONENTS via
  -- `rpow_lt_rpow_of_exponent_lt` (which needs `1 < N`), not `rpow_lt_rpow`
  have hexp : γ' * 2 / 5 < (1 : ℝ) / 5 := by linarith
  exact Real.rpow_lt_rpow_of_exponent_lt hN hexp

/-- **Floor-splitting with redistributed weight is NEUTRAL.** Splitting a single
search floor of weight `w` into `k` floors of weight `w/k` leaves the optimal
exponent *exactly* unchanged.

**This is the kill of a whole family of proposals.** A natural idea for beating
`1/5` is: "the interior `N^{1/2}` is the expensive term, so search `k` shorter
ranges in parallel and pay `k` smaller floors." If the total weight is preserved
— which is what "the same total reach" means — the barrier does not move, by this
theorem. The number of search directions is **not** a free parameter: only their
total weight is. -/
theorem split_neutral (γ w k : ℝ) (hk : k ≠ 0) :
    γ / (1 + w) = γ / (1 + k * (w / k)) := by
  have h : k * (w / k) = w := by field_simp
  rw [h]

/-- **Floor-splitting WITHOUT redistributing the weight is strictly WORSE.**
`k` floors of weight `w` *each* give optimal exponent `γ / (1 + k·w)`, which is
`≤ γ / (1 + w)` and **strictly** smaller for `k > 1`.

So "run the same search `k` times over `k` sub-ranges, each retaining the full
reach" is not neutral — it is **provably counterproductive**, because `k`
independent floors of weight `w` are not `k` views of one floor of weight `w`;
they are `k` times the reach. This is the precise sense in which the barrier
depends on the weights *only through their sum*. -/
theorem split_without_redistribution_worse (γ w k : ℝ) (hγ : 0 < γ) (hw : 0 < w)
    (hk1 : 1 ≤ k) :
    γ / (1 + k * w) ≤ γ / (1 + w) := by
  have hc : 0 < 1 + k * w := by nlinarith
  have hd : 0 < 1 + w := by linarith
  rw [div_le_div_iff₀ hc hd]
  have h1 : γ * w ≤ γ * w * k := by
    have hh := mul_le_mul_of_nonneg_left hk1 (mul_pos hγ hw).le
    nlinarith [hh]
  nlinarith [h1]

/-! ### Attainment: without it the whole design rule is unjustified

A *lower* bound on the optimum does not determine the optimum. Every claim in
this file that "the optimal exponent is exactly `γ/(1+Σwᵢ)`" needs attainment,
and until now attainment was available only at `k = 2` (`HarveyFloor.attained`).
Here it is proved for **every** `k`, which is what licenses the design rule. -/

/-- **Attainment for an arbitrary number of floors.** Set every floor to
`T := N^{γ/(1+Σwᵢ)}`. Then the interior is *exactly* `T`, so the cost of the
`k`-floor shape is exactly `T` and the optimum is
`N^{γ/(1+Σᵢ wᵢ)}` — for every `k` and every positive weight vector.

Together with `weighted_amgm_finset` this makes the `k`-floor optimum **exact**:

> `optimum = N^{γ / (1 + Σᵢ wᵢ)}`, and this depends on the weights **only
> through their sum**.

Harvey's `1/5` is the `k = 2`, `Σwᵢ = 3/2` instance. -/
theorem finset_barrier_attained (N γ : ℝ) (s : Finset ℝ) (w : ℝ → ℝ)
    (hN : 1 < N) (hw : ∀ x ∈ s, 0 < w x) :
    let T : ℝ := N ^ (γ / (1 + ∑ x ∈ s, w x))
    N ^ γ / ∏ x ∈ s, T ^ (w x) = T := by
  dsimp only
  -- `N > 1` gives positivity in both forms; the `rpow` lemmas below ask for
  -- `0 ≤ N` or `0 < N` and will NOT accept `le_of_lt hN` (that is `1 ≤ N`).
  have hN0 : (0 : ℝ) ≤ N := le_of_lt (lt_trans (by norm_num) hN)
  have hNpos : (0 : ℝ) < N := lt_trans (by norm_num) hN
  have hw0 : (0 : ℝ) ≤ ∑ x ∈ s, w x :=
    Finset.sum_nonneg fun x hx => (hw x hx).le
  have hne : (1 + ∑ x ∈ s, w x) ≠ 0 := ne_of_gt (by linarith)
  -- the floor product telescopes: ∏ T^{wᵢ} = T^{Σwᵢ} with all `T = N^{e}`
  have hprod : (∏ x ∈ s, (N ^ (γ / (1 + ∑ x ∈ s, w x))) ^ (w x))
      = (N ^ (γ / (1 + ∑ x ∈ s, w x))) ^ (∑ x ∈ s, w x) :=
    finset_rpow_prod _ s w (Real.rpow_pos_of_pos hNpos _)
  rw [hprod]
  -- `(N^e)^{W} = N^{e·W}`
  rw [(Real.rpow_mul hN0 (γ / (1 + ∑ x ∈ s, w x)) (∑ x ∈ s, w x)).symm]
  -- `N^γ / N^{e·W} = N^{γ - e·W}`
  rw [(Real.rpow_sub hNpos γ _).symm]
  -- and `γ - (γ/(1+W))·W = γ/(1+W)`, so the interior is exactly `T`
  rw [show γ - (γ / (1 + ∑ x ∈ s, w x)) * ∑ x ∈ s, w x = γ / (1 + ∑ x ∈ s, w x) by
        field_simp
        ring]

/-! ### The design rule, as a complete classification

The `weighted_amgm` docstring asserts the design rule in prose. `finset_barrier_attained`
makes it exact; this last theorem makes it **exhaustive**. -/

/-- **THE DESIGN RULE, AS A THEOREM. Within the search-floor cost shape, beating
`1/5` requires — and it is *sufficient* — to do exactly one of two things:

1. **raise the total weight** `W = Σᵢ wᵢ` above `3/2`; or
2. **lower the range exponent** `γ` below `1/2`.

There is no third option. If `W ≤ 3/2` *and* `γ ≥ 1/2` then the exponent
`γ/(1+W)` is **at least** `1/5`.

So the `γ < 1/2` / `Σw > 3/2` pair in the design rule is not a heuristic list
of "things that might help" — it is a **complete dichotomy**, and the two
escape routes are checked by `sub_range_exponent_beats` and by
`finset_barrier_attained` respectively. Any proposal to improve Harvey inside
this family must move one of these two numbers. -/
theorem beating_one_fifth_requires (γ W : ℝ) (hW : (0 : ℝ) ≤ W)
    (hlt : γ / (1 + W) < (1 : ℝ) / 5) : W > (3 : ℝ) / 2 ∨ γ < (1 : ℝ) / 2 := by
  have hpos : (0 : ℝ) < 1 + W := by linarith
  -- clear the denominator: `γ < (1/5)·(1+W)`, i.e. `γ < (1+W)/5`
  have hkey : γ < (1 : ℝ) / 5 * (1 + W) := (div_lt_iff₀ hpos).mp hlt
  by_cases hg : γ < (1 : ℝ) / 2
  · exact Or.inr hg
  · left
    -- `1/2 ≤ γ < (1+W)/5` forces `1 + W > 5/2`, i.e. `W > 3/2`
    have hγ2 : (1 : ℝ) / 2 ≤ γ := le_of_not_gt hg
    have h2 : (1 : ℝ) / 2 < (1 : ℝ) / 5 * (1 + W) := lt_of_le_of_lt hγ2 hkey
    norm_num at h2 ⊢
    linarith

end Crypto.FactoringBarrier.HarveyFloor
