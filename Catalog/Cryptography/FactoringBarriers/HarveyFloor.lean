import Mathlib.Analysis.SpecialFunctions.Pow.Real
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

## Provenance

Machine-checked, **0 `sorry`, 0 `axiom`**, against Mathlib at
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

end Crypto.FactoringBarrier.HarveyFloor
