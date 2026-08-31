/-
# GAP-L7 falsified and replaced: the extremal enumeration order is a *population*
# property, not a policy-level theorem

This file formalises the first half of the round-76 L7 deliverable: the
**falsification of "√N-descending is the extremal REORDER order"** and its
replacement by the *mass-sorting* theorem plus an exact **sign-flip law** with a
closed-form crossover.

## The action space

A `REORDER`-class policy commits, ex ante, to an enumeration `a₀, a₁, …` of the
candidate index set; test-blindness means the order may not consult the answers
of the probes it schedules.  Formally the object is a permutation of the slots
(`Equiv.Perm (Fin n)`), and the cost charged for a draw whose hit sits at slot
`i` is the number of probes `k+1` with `a k = i`.

## Main results

* `probeCost_masssort_le` (**L7-b, exchange theorem**) — the *mass-sorted*
  enumeration is extremal: if `w ∘ a` is antitone then no re-ordering of `a`
  has smaller expected probe cost.  This is the only order-optimality statement
  the action space supports; it says nothing about `√N`-descending.
* `pop_signflip` — for an arbitrary finite population of balance ratios
  `r = q/p ∈ [1,2)` the window-ascending policy beats the window-descending one
  **iff** `E[1/√r] < (2+√2)/4`; equivalently, in the reciprocal convention of
  the ledger, iff the crossover constant `crossoverRecip = 4 - 2√2 ≈ 1.1716` is
  passed (`crossoverRecip_eq`, `crossoverRecip_bounds`).
* `meanInvSqrt_eq` — for the uniform band `r ~ U[1, 1+δ]` the population mean is
  exactly `E[1/√r] = 2/(1+√(1+δ))` (computed from `∫ r^(-1/2)`).
* `signflip_uniform_band` — the **sign-flip law with closed-form crossover**:
  window-ascending beats window-descending on the band `U[1,1+δ]`
  **iff `δ > 80 - 56√2 ≈ 0.80404`**.
* `hard_balance_tilt`, `hard_balance_ratio` — at hard balance (`q < 2p`, i.e.
  `δ = 1`) the population tilt is exactly `√2 - 1 ≈ 0.4142` (bottom-heavy) and
  descending costs exactly `√2` times ascending.
* `L7_as_drafted_false` — the falsification proper: two admissible balanced
  populations on which the *same* two policies swap winners.  Hence no
  policy-level theorem can name a universal extremal order.

-- !-- Lab Notes -- !--
-- Verifier pools (n = 2400 / 2400 / 1600 / 500): hard-balanced generators come
-- out bottom-heavy with measured tilt z = 0.4095–0.4148 against the analytic
-- value √2 - 1 = 0.41421 proved here (`hard_balance_tilt`); narrow bands come
-- out top-heavy (z ≈ 0.65, matching `meanInvSqrt (1/2)`), descending extremal.
-- The paper-137 pool sits between the two, which is why 137's descending win
-- (asc/desc = 1.078x) is *refined* and not contradicted by this file.
-/
import Mathlib

namespace ReorderL7

open Finset

noncomputable section

/-! ## 1.  The REORDER action space and the exchange theorem -/

/-- Expected probe cost of the enumeration `a` against the slot-mass `w`:
the slot visited `k`-th is charged `k+1` probes. -/
def probeCost {n : ℕ} (w : Fin n → ℝ) (a : Equiv.Perm (Fin n)) : ℝ :=
  ∑ k : Fin n, ((k : ℝ) + 1) * w (a k)

/-- The probe index antivaries with any antitone mass. -/
lemma antivaryOn_index {n : ℕ} {g : Fin n → ℝ} (hg : Antitone g) :
    AntivaryOn (fun k : Fin n => ((k : ℝ) + 1)) g (Finset.univ : Finset (Fin n)) := by
  intro i _ j _ hlt
  have hji : j < i := by
    by_contra hcon
    push_neg at hcon
    exact absurd (hg hcon) (not_le.mpr hlt)
  have hle : ((j : ℕ) : ℝ) ≤ ((i : ℕ) : ℝ) := by
    exact_mod_cast (Fin.le_iff_val_le_val.mp hji.le)
  dsimp only
  linarith

/-- **Sorted-order optimality (bare form).**  For an antitone mass the identity
enumeration minimises the expected probe cost among all permutations. -/
theorem sum_index_mul_le_comp_perm {n : ℕ} {g : Fin n → ℝ} (hg : Antitone g)
    (σ : Equiv.Perm (Fin n)) :
    ∑ k : Fin n, ((k : ℝ) + 1) * g k ≤ ∑ k : Fin n, ((k : ℝ) + 1) * g (σ k) :=
  (antivaryOn_index hg).sum_mul_le_sum_mul_comp_perm (by intro x _; exact Finset.mem_coe.mpr (Finset.mem_univ x))

/-- **L7-b, the exchange theorem.**  A REORDER policy is extremal exactly when it
*mass-sorts*: if the enumeration `a` visits the slots in nonincreasing order of
mass, then every other enumeration `b` costs at least as much.

Note what the statement does **not** say: nothing here privileges any particular
arithmetic order (`√N`-descending, ascending, wheel order …).  Which concrete
enumeration realises the mass-sort is a property of the *population* `w`. -/
theorem probeCost_masssort_le {n : ℕ} (w : Fin n → ℝ) (a b : Equiv.Perm (Fin n))
    (ha : Antitone (w ∘ a)) : probeCost w a ≤ probeCost w b := by
  have h := sum_index_mul_le_comp_perm ha (b.trans a.symm)
  simpa [probeCost, Function.comp, Equiv.trans_apply] using h

/-! ## 2.  The window model for hard-balanced semiprime generators

Write `N = p·q` with `p ≤ q` and balance ratio `r = q/p ∈ [1, 1+δ]`, so that
`p/√N = 1/√r`.  A generator that advertises `q < 2p` licenses the *balance
window* `[√N/√2, √N]`, which the policy commits to ex ante.  Measured in units
of `√N`, a window scan started at the bottom pays `1/√r - 1/√2` and a scan
started at the top pays `1 - 1/√r`. -/

/-- Cost (in units of `√N`) of the window-**ascending** policy on a draw of
balance ratio `r`. -/
def ascCost (r : ℝ) : ℝ := 1 / Real.sqrt r - 1 / Real.sqrt 2

/-- Cost (in units of `√N`) of the window-**descending** policy on a draw of
balance ratio `r`. -/
def descCost (r : ℝ) : ℝ := 1 - 1 / Real.sqrt r

/-- The crossover mean: the value of `E[1/√r]` at which the two window policies
are exactly tied. -/
def crossoverMean : ℝ := (2 + Real.sqrt 2) / 4

/-- The crossover constant in the reciprocal (`E[√r]`) convention of the ledger. -/
def crossoverRecip : ℝ := 4 - 2 * Real.sqrt 2

lemma sqrt2_pos : (0:ℝ) < Real.sqrt 2 := Real.sqrt_pos.mpr (by norm_num)

lemma sq_sqrt2 : Real.sqrt 2 * Real.sqrt 2 = 2 := Real.mul_self_sqrt (by norm_num)

/-- `crossoverRecip = 2 / (1 + 1/√2) = 4 - 2√2`, the closed form of the ledger's
`E[√r] = 1.1716` law. -/
theorem crossoverRecip_eq : 2 / (1 + 1 / Real.sqrt 2) = crossoverRecip := by
  have h2 := sq_sqrt2
  have hpos := sqrt2_pos
  rw [crossoverRecip]
  field_simp
  nlinarith [h2, hpos]

/-- The crossover constant is the reciprocal of the crossover mean. -/
theorem crossoverRecip_mul_crossoverMean : crossoverRecip * crossoverMean = 1 := by
  have h2 := sq_sqrt2
  rw [crossoverRecip, crossoverMean]
  nlinarith [h2]

/-- Numerical bracket: `1.1715 < 4 - 2√2 < 1.1716`. -/
theorem crossoverRecip_bounds : 1.1715 < crossoverRecip ∧ crossoverRecip < 1.1716 := by
  have h1 : Real.sqrt 2 < 1.41425 := by
    nlinarith [sq_sqrt2, sqrt2_pos]
  have h2 : (1.4142 : ℝ) < Real.sqrt 2 := by
    nlinarith [sq_sqrt2, sqrt2_pos]
  constructor <;> · rw [crossoverRecip]; linarith

/-! ### The population law: which order wins is a property of the population -/

/-- **Sign-flip law, arbitrary finite population.**  For any finite population of
balance ratios `r i` with probability weights `π i`, the window-ascending policy
beats the window-descending one **iff** the population mean `E[1/√r]` lies below
the crossover mean `(2+√2)/4`.

This is the precise sense in which GAP-L7-as-drafted is a category error: the
inequality it asserts is not a statement about the action space at all, it is a
statement about the generator's `r`-law. -/
theorem pop_signflip {ι : Type*} (s : Finset ι) (pi r : ι → ℝ)
    (hpi : ∑ i ∈ s, pi i = 1) :
    (∑ i ∈ s, pi i * ascCost (r i) < ∑ i ∈ s, pi i * descCost (r i)) ↔
      ∑ i ∈ s, pi i * (1 / Real.sqrt (r i)) < crossoverMean := by
  have hA : ∑ i ∈ s, pi i * ascCost (r i)
      = (∑ i ∈ s, pi i * (1 / Real.sqrt (r i))) - 1 / Real.sqrt 2 := by
    simp only [ascCost, mul_sub]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hpi, one_mul]
  have hD : ∑ i ∈ s, pi i * descCost (r i)
      = 1 - ∑ i ∈ s, pi i * (1 / Real.sqrt (r i)) := by
    simp only [descCost, mul_sub, mul_one]
    rw [Finset.sum_sub_distrib, hpi]
  have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  rw [hA, hD, crossoverMean]
  constructor
  · intro h
    have : 1 / Real.sqrt 2 = Real.sqrt 2 / 2 := by
      field_simp; nlinarith [hs2]
    rw [this] at h
    linarith
  · intro h
    have : 1 / Real.sqrt 2 = Real.sqrt 2 / 2 := by
      field_simp; nlinarith [hs2]
    rw [this]
    linarith

/-! ## 3.  The uniform band `r ~ U[1, 1+δ]` : exact mean and closed-form crossover -/

/-- Population mean of `1/√r` for `r` uniform on `[1, 1+δ]`. -/
def meanInvSqrt (delta : ℝ) : ℝ := 2 / (1 + Real.sqrt (1 + delta))

lemma sqrt_one_add_pos {delta : ℝ} (h : 0 < delta) : 1 < Real.sqrt (1 + delta) := by
  have h1 : Real.sqrt 1 < Real.sqrt (1 + delta) :=
    Real.sqrt_lt_sqrt (by norm_num) (by linarith)
  simpa using h1

/-- The mean is the normalised integral of `r ↦ r^(-1/2)` over the band. -/
theorem meanInvSqrt_eq {delta : ℝ} (h : 0 < delta) :
    (1 / delta) * (∫ r in (1:ℝ)..(1 + delta), r ^ (-(1/2) : ℝ)) = meanInvSqrt delta := by
  have hint : (∫ r in (1:ℝ)..(1 + delta), r ^ (-(1/2) : ℝ))
      = 2 * (Real.sqrt (1 + delta) - 1) := by
    rw [integral_rpow (Or.inl (by norm_num))]
    rw [show (-(1/2:ℝ) + 1) = 1/2 by ring, ← Real.sqrt_eq_rpow, ← Real.sqrt_eq_rpow,
      Real.sqrt_one]
    ring
  have hs : Real.sqrt (1 + delta) * Real.sqrt (1 + delta) = 1 + delta :=
    Real.mul_self_sqrt (by linarith)
  have hgt : 1 < Real.sqrt (1 + delta) := sqrt_one_add_pos h
  rw [hint, meanInvSqrt]
  field_simp
  nlinarith [hs, hgt]

/-- The **population tilt** `z ∈ [0,1]`: the normalised position of the mean hit
inside the balance window.  `z < 1/2` is bottom-heavy (ascending extremal),
`z > 1/2` is top-heavy (descending extremal). -/
def tilt (delta : ℝ) : ℝ := (meanInvSqrt delta - 1 / Real.sqrt 2) / (1 - 1 / Real.sqrt 2)

/-- **Hard balance (`q < 2p`, i.e. `δ = 1`) is bottom-heavy with tilt exactly
`√2 - 1 ≈ 0.41421`** — the analytic value the verifier measured as 0.4095–0.4148. -/
theorem hard_balance_tilt : tilt 1 = Real.sqrt 2 - 1 := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have hlt : (1.4142 : ℝ) < Real.sqrt 2 := by nlinarith [hs, hpos]
  have h1 : Real.sqrt (1 + 1) = Real.sqrt 2 := by norm_num
  have hden : (1 - 1 / Real.sqrt 2) ≠ 0 := by
    have : 1 / Real.sqrt 2 = Real.sqrt 2 / 2 := by field_simp; nlinarith [hs]
    rw [this]; intro hc; nlinarith [hc]
  have hnum : meanInvSqrt 1 - 1 / Real.sqrt 2 = (Real.sqrt 2 - 1) * (1 - 1 / Real.sqrt 2) := by
    rw [meanInvSqrt, h1]
    have hne : (1 + Real.sqrt 2) ≠ 0 := by positivity
    field_simp
    nlinarith [hs, hpos]
  rw [tilt, hnum, mul_div_assoc, div_self hden, mul_one]

/-- **Hard-balance ratio law.**  On a hard-balanced band the window-descending
policy costs exactly `√2` times the window-ascending policy. -/
theorem hard_balance_ratio :
    (1 - meanInvSqrt 1) = Real.sqrt 2 * (meanInvSqrt 1 - 1 / Real.sqrt 2) := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have h1 : Real.sqrt (1 + 1) = Real.sqrt 2 := by norm_num
  have hne : (1 + Real.sqrt 2) ≠ 0 := by positivity
  rw [meanInvSqrt, h1]
  field_simp
  nlinarith [hs, hpos]

/-- Monotonicity of the band mean: wider bands are more bottom-heavy. -/
theorem meanInvSqrt_strictAnti {a b : ℝ} (ha : 0 < a) (hab : a < b) :
    meanInvSqrt b < meanInvSqrt a := by
  have h1 : Real.sqrt (1 + a) < Real.sqrt (1 + b) :=
    Real.sqrt_lt_sqrt (by linarith) (by linarith)
  have h2 : 0 < Real.sqrt (1 + a) := Real.sqrt_pos.mpr (by linarith)
  rw [meanInvSqrt, meanInvSqrt]
  exact div_lt_div_of_pos_left (by norm_num) (by linarith) (by linarith)

/-- **The closed-form crossover band width** `δ* = 80 - 56√2`. -/
def crossoverWidth : ℝ := 80 - 56 * Real.sqrt 2

theorem crossoverWidth_bounds : 0.804 < crossoverWidth ∧ crossoverWidth < 0.805 := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  have h1 : Real.sqrt 2 < 1.4142136 := by nlinarith [hs, hpos]
  have h2 : (1.4142135 : ℝ) < Real.sqrt 2 := by nlinarith [hs, hpos]
  constructor <;> · rw [crossoverWidth]; linarith

lemma crossoverWidth_root_pos : (0:ℝ) < 7 - 4 * Real.sqrt 2 := by
  have hs : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos := sqrt2_pos
  nlinarith [hs, hpos]

/-- Algebraic core of the sign-flip law: with `s = √(1+δ)` the two window costs
compare exactly as `s` compares with `7 - 4√2`. -/
lemma window_cmp_iff_root {delta : ℝ} (h : 0 < delta) :
    (meanInvSqrt delta - 1 / Real.sqrt 2 < 1 - meanInvSqrt delta) ↔
      (7 - 4 * Real.sqrt 2 < Real.sqrt (1 + delta)) := by
  have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos2 := sqrt2_pos
  set s := Real.sqrt (1 + delta) with hsdef
  have hgt : 1 < s := sqrt_one_add_pos h
  have h1s : (0:ℝ) < 1 + s := by linarith
  have hinv : 1 / Real.sqrt 2 = Real.sqrt 2 / 2 := by field_simp; nlinarith [hs2]
  have hA : meanInvSqrt delta * (1 + s) = 2 := by
    rw [meanInvSqrt, ← hsdef]
    field_simp
  rw [hinv]
  constructor
  · intro hlt
    have h2 : (2 * meanInvSqrt delta) * (1 + s) < (1 + Real.sqrt 2 / 2) * (1 + s) :=
      mul_lt_mul_of_pos_right (by linarith) h1s
    nlinarith [hA, h2, hs2, hpos2]
  · intro hlt
    by_contra hcon
    push_neg at hcon
    have h2 : (1 + Real.sqrt 2 / 2) * (1 + s) ≤ (2 * meanInvSqrt delta) * (1 + s) :=
      mul_le_mul_of_nonneg_right (by linarith) (le_of_lt h1s)
    nlinarith [hA, h2, hs2, hpos2]

/-- **Sign-flip law for uniform bands (the replacement statement L7').**
On the uniform balance band `r ~ U[1, 1+δ]` the window-ascending policy strictly
beats the window-descending one **iff** the band is wider than the closed-form
crossover `δ* = 80 - 56√2 ≈ 0.80404`.

Hard balance (`δ = 1`, i.e. `q < 2p`) is therefore ascending-extremal, while all
narrow bands (`δ < 0.804`) are descending-extremal: the extremal order *flips
sign* inside the admissible family of generators. -/
theorem signflip_uniform_band {delta : ℝ} (h : 0 < delta) :
    (meanInvSqrt delta - 1 / Real.sqrt 2 < 1 - meanInvSqrt delta) ↔ crossoverWidth < delta := by
  have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
  have hpos2 := sqrt2_pos
  have hc := crossoverWidth_root_pos
  have hs : Real.sqrt (1 + delta) * Real.sqrt (1 + delta) = 1 + delta :=
    Real.mul_self_sqrt (by linarith)
  have hspos : 0 < Real.sqrt (1 + delta) := by
    have := sqrt_one_add_pos h; linarith
  rw [window_cmp_iff_root h, crossoverWidth]
  constructor
  · intro hlt
    nlinarith [hs, hs2, hpos2, hspos, hc, hlt]
  · intro hlt
    nlinarith [hs, hs2, hpos2, hspos, hc, hlt]

/-! ## 4.  The falsification -/

/-- Numerical control of the narrow band `δ = 1/2`. -/
lemma meanInvSqrt_half_bounds : 0.8989 < meanInvSqrt (1/2) ∧ meanInvSqrt (1/2) < 0.8990 := by
  have hs : Real.sqrt (1 + 1/2) * Real.sqrt (1 + 1/2) = 1 + 1/2 :=
    Real.mul_self_sqrt (by norm_num)
  have hspos : (0:ℝ) < Real.sqrt (1 + 1/2) := Real.sqrt_pos.mpr (by norm_num)
  have hub : Real.sqrt (1 + 1/2) < 1.2248 := by nlinarith [hs, hspos]
  have hlb : (1.2247 : ℝ) < Real.sqrt (1 + 1/2) := by nlinarith [hs, hspos]
  have h1s : (0:ℝ) < 1 + Real.sqrt (1 + 1/2) := by linarith
  rw [meanInvSqrt]
  constructor
  · rw [lt_div_iff₀ h1s]; nlinarith [hub]
  · rw [div_lt_iff₀ h1s]; nlinarith [hlb]

/-- **GAP-L7 as drafted is false.**  There are two admissible balanced
populations — the hard-balanced band `q < 2p` (`δ = 1`) and a narrow band
(`δ = 1/2`) — on which the *same* pair of committed REORDER policies swap
winners: ascending strictly wins on the first, descending strictly wins on the
second.  Hence "√N-descending is extremal" cannot be a theorem of the REORDER
action space; the extremal order is fixed only after the generator's `r`-law
(the prior-shape channel `Λ`) is measured. -/
theorem L7_as_drafted_false :
    (meanInvSqrt 1 - 1 / Real.sqrt 2 < 1 - meanInvSqrt 1) ∧
      (1 - meanInvSqrt (1/2) < meanInvSqrt (1/2) - 1 / Real.sqrt 2) := by
  refine ⟨?_, ?_⟩
  · rw [signflip_uniform_band (by norm_num)]
    have := crossoverWidth_bounds.2
    linarith
  · have hs2 : Real.sqrt 2 * Real.sqrt 2 = 2 := sq_sqrt2
    have hpos2 := sqrt2_pos
    have hb := meanInvSqrt_half_bounds
    have hinv : 1 / Real.sqrt 2 < 0.70711 := by
      rw [div_lt_iff₀ hpos2]; nlinarith [hs2, hpos2]
    linarith [hb.1, hb.2, hinv]

end

end ReorderL7