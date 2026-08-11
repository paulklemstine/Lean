import Bridges.CRTSplitNoGoBirthday
import Bridges.CRTSplitNoGoGeneral

/-!
# The CRT-Split No-Go, Part VII: the birthday *window* and the exact Pollard reveal time

Part VI proved the exact birthday law `card_injPrefix` for orbit prefixes and derived its
lower half (`majority_collision_free`): at time `T` with `T (T+1) ≤ n` at least half of all
`n ^ n` maps of an `n`-element set still have a collision-free orbit prefix.  That is only one
side of a threshold.  This file closes the loop by proving the matching *upper* half — an
exponential tail — and it settles the easy half of the smoothness-regime conjecture by
computing the Pollard `p-1` reveal time exactly.

## Main results

* `card_injPrefix_le_exp` — the exact birthday product is dominated by a Gaussian tail:
  `#{f : collision-free prefix of length T+1} ≤ exp (-T(T+1)/(2n)) · n ^ n`.
  This is Conjecture 1 of the previous cycle's `FUTURE_DIRECTIONS.md`, now a theorem.
* `minority_collision_free` — consequently, once `4 n ≤ T (T+1)` (i.e. `T ≳ 2√n`) at most a
  quarter of all maps are collision-free.
* `birthday_window_zmod` — the two halves together, on the state space `ZMod p` of the reduced
  dynamics: the collision-free fraction passes from `≥ 1/2` to `≤ 1/4` inside the window
  `√p ≲ T ≲ 2√p`.  The first cycle closure — the only factor-revealing event, by Parts I–IV —
  therefore happens at `T ≍ √p = N^{1/4}`, exponentially far in `log N`.
* `pm1RevealTime_eq_min_orderOf` — for `N = p q` and a base `a` invertible mod both factors
  with *distinct* multiplicative orders, the least exponent `M > 0` at which
  `gcd (a^M - 1) N` is a nontrivial factor is **exactly** `min (ord_p a) (ord_q a)`.  Part V
  gave the `≥` half; the `≤` half is the Xor criterion applied at `M = min`.  This is the
  first half of Conjecture 4, now a theorem, and it identifies the cost of regime (b) with an
  invariant of the *hidden* factors, invisible from `N`.
* `pm1RevealTime_demo` — an in-kernel instance: for `N = 341371 = 631 · 541` and `a = 2` the
  reveal time is exactly `45 = ord_631 2`.
-/

namespace CRTSplitNoGo

open Finset

/-! ## Part A: the exponential tail of the birthday product -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Weierstrass' product inequality, upper half: a product of factors `1 - c i` with
`0 ≤ c i ≤ 1` is dominated by `exp (-∑ c i)`. -/
lemma prod_one_sub_le_exp_neg_sum (T : ℕ) (c : ℕ → ℝ)
    (h1 : ∀ i ∈ Finset.range T, c i ≤ 1) :
    ∏ i ∈ Finset.range T, (1 - c i) ≤ Real.exp (-∑ i ∈ Finset.range T, c i) := by
  have hstep : ∏ i ∈ Finset.range T, (1 - c i)
      ≤ ∏ i ∈ Finset.range T, Real.exp (-c i) := by
    refine Finset.prod_le_prod (fun i hi => by linarith [h1 i hi]) (fun i hi => ?_)
    have := Real.add_one_le_exp (-c i)
    linarith
  calc ∏ i ∈ Finset.range T, (1 - c i)
      ≤ ∏ i ∈ Finset.range T, Real.exp (-c i) := hstep
    _ = Real.exp (∑ i ∈ Finset.range T, -c i) := (Real.exp_sum _ _).symm
    _ = Real.exp (-∑ i ∈ Finset.range T, c i) := by rw [Finset.sum_neg_distrib]

/-- The birthday law of Part VI, rewritten as the classical birthday *product*
`∏_{i=1}^{T} (1 - i/n)` times the total number `n ^ n` of maps. -/
theorem card_injPrefix_eq_prod (a : α) (T : ℕ) (hT : T < Fintype.card α) :
    ((injPrefixFinset a T).card : ℝ)
      = (∏ i ∈ Finset.range T, (1 - ((i : ℝ) + 1) / Fintype.card α))
          * (Fintype.card α : ℝ) ^ (Fintype.card α) := by
  set n := Fintype.card α with hn
  have hnpos : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  rw [card_injPrefix a T hT]
  push_cast
  have hD : ((n - 1).descFactorial T : ℝ) = ∏ i ∈ Finset.range T, ((n : ℝ) - 1 - i) := by
    rw [Nat.descFactorial_eq_prod_range, Nat.cast_prod]
    refine Finset.prod_congr rfl (fun i hi => ?_)
    have hi' : i < T := Finset.mem_range.mp hi
    have h1 : i ≤ n - 1 := by omega
    have h2 : 1 ≤ n := by omega
    rw [Nat.cast_sub h1, Nat.cast_sub h2]
    push_cast
    ring
  have hfac : ∏ i ∈ Finset.range T, ((n : ℝ) - 1 - i)
      = (n : ℝ) ^ T * ∏ i ∈ Finset.range T, (1 - ((i : ℝ) + 1) / n) := by
    have hterm : ∀ i ∈ Finset.range T,
        ((n : ℝ) - 1 - i) = (n : ℝ) * (1 - ((i : ℝ) + 1) / n) := by
      intro i _
      field_simp
      ring
    rw [Finset.prod_congr rfl hterm, Finset.prod_mul_distrib, Finset.prod_const,
      Finset.card_range]
  have hpow : (n : ℝ) ^ T * (n : ℝ) ^ (n - T) = (n : ℝ) ^ n := by
    rw [← pow_add]
    congr 1
    omega
  rw [hD, hfac, ← hn, ← hpow]
  ring

/-- **The birthday tail (Conjecture 1 of the previous cycle).**  The number of maps of an
`n`-element set whose orbit prefix of length `T + 1` from a fixed seed is collision-free is at
most `exp (-T(T+1)/(2n)) · n ^ n`.  Collisions are thus *overwhelmingly* likely once
`T ≫ √n`: the birthday exponent `1/2` is sharp from above as well as from below. -/
theorem card_injPrefix_le_exp (a : α) (T : ℕ) (hT : T < Fintype.card α) :
    ((injPrefixFinset a T).card : ℝ)
      ≤ Real.exp (-((T * (T + 1) : ℝ) / (2 * Fintype.card α)))
          * (Fintype.card α : ℝ) ^ (Fintype.card α) := by
  set n := Fintype.card α with hn
  have hnpos : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hprod := prod_one_sub_le_exp_neg_sum T (fun i => ((i : ℝ) + 1) / n)
    (fun i hi => by
      have hi' : i < T := Finset.mem_range.mp hi
      rw [div_le_one hnR]
      have : (i : ℝ) + 1 ≤ n := by
        have : i + 1 ≤ n := by omega
        exact_mod_cast this
      linarith)
  rw [sum_range_succ_div T (n : ℝ)] at hprod
  have hpow : (0 : ℝ) ≤ (n : ℝ) ^ n := by positivity
  rw [card_injPrefix_eq_prod a T hT]
  exact mul_le_mul_of_nonneg_right hprod hpow

/-- `exp (-2) ≤ 1/4`: the numerical input to the quarter-threshold. -/
lemma exp_neg_two_le_quarter : Real.exp (-2 : ℝ) ≤ 1 / 4 := by
  have h1 : (2.7182818283 : ℝ) < Real.exp 1 := by
    have := Real.exp_one_gt_d9
    linarith
  have h2 : (4 : ℝ) ≤ Real.exp 2 := by
    have : Real.exp 2 = Real.exp 1 * Real.exp 1 := by
      rw [← Real.exp_add]; norm_num
    nlinarith
  have hpos : (0 : ℝ) < Real.exp 2 := Real.exp_pos 2
  rw [Real.exp_neg, inv_le_comm₀ hpos (by norm_num)]
  linarith

/-- **The upper half of the birthday threshold.**  Once `4 n ≤ T (T+1)` — i.e. `T ≳ 2√n` — at
most a quarter of all maps of an `n`-element set are still collision-free.  Together with
`majority_collision_free` (at least a half when `T (T+1) ≤ n`) this pins the first cycle
closure at `T ≍ √n`. -/
theorem minority_collision_free (a : α) (T : ℕ) (hT : T < Fintype.card α)
    (h : 4 * Fintype.card α ≤ T * (T + 1)) :
    ((injPrefixFinset a T).card : ℝ) ≤ ((Fintype.card α : ℝ) ^ (Fintype.card α)) / 4 := by
  set n := Fintype.card α with hn
  have hnpos : 0 < n := by omega
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hle : (2 : ℝ) ≤ (T * (T + 1) : ℝ) / (2 * n) := by
    rw [le_div_iff₀ (by positivity)]
    have : ((4 * n : ℕ) : ℝ) ≤ ((T * (T + 1) : ℕ) : ℝ) := by exact_mod_cast h
    push_cast at this
    linarith
  have hmono : Real.exp (-((T * (T + 1) : ℝ) / (2 * n))) ≤ Real.exp (-2 : ℝ) :=
    Real.exp_le_exp.mpr (by linarith)
  have hpow : (0 : ℝ) ≤ (n : ℝ) ^ n := by positivity
  calc ((injPrefixFinset a T).card : ℝ)
      ≤ Real.exp (-((T * (T + 1) : ℝ) / (2 * n))) * (n : ℝ) ^ n :=
        card_injPrefix_le_exp a T hT
    _ ≤ (1 / 4) * (n : ℝ) ^ n :=
        mul_le_mul_of_nonneg_right (le_trans hmono exp_neg_two_le_quarter) hpow
    _ = ((n : ℝ) ^ n) / 4 := by ring

/-- **The birthday window on the reduced state space.**  On `ZMod p` — the state space of the
mod-`p` reduction of any `N`-explicit iteration (Fact 2) — the collision-free fraction of maps
is at least `1/2` for `T (T+1) ≤ p` and at most `1/4` for `4 p ≤ T (T+1)`.  So the first cycle
closure, which by Parts I–IV is the *only* factor-revealing event, occurs at `T ≍ √p`, i.e.
`N^{1/4}` for balanced `N = p q`: exponential in `log N`. -/
theorem birthday_window_zmod (p : ℕ) [NeZero p] (T₁ T₂ : ℕ) (hT₁ : T₁ < p) (hT₂ : T₂ < p)
    (h₁ : T₁ * (T₁ + 1) ≤ p) (h₂ : 4 * p ≤ T₂ * (T₂ + 1)) :
    ((p : ℝ) ^ p) / 2 ≤ ((injPrefixFinset (0 : ZMod p) T₁).card : ℝ) ∧
      ((injPrefixFinset (0 : ZMod p) T₂).card : ℝ) ≤ ((p : ℝ) ^ p) / 4 := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  refine ⟨?_, ?_⟩
  · have := majority_collision_free (0 : ZMod p) T₁ (by rw [hcard]; exact hT₁)
      (by rw [hcard]; exact h₁)
    rwa [hcard] at this
  · have := minority_collision_free (0 : ZMod p) T₂ (by rw [hcard]; exact hT₂)
      (by rw [hcard]; exact h₂)
    rwa [hcard] at this

/-! ## Part B: the Pollard `p-1` reveal time, exactly -/

/-- The first exponent at which the Pollard `p-1` test `gcd (a^M - 1, N)` exposes a factor
(`0` if it never does). -/
noncomputable def pm1RevealTime (N : ℕ) (a : ℤ) : ℕ :=
  sInf {M : ℕ | 0 < M ∧ RevealsFactor N (a ^ M - 1)}

/-- If `a` is invertible mod the prime `p` then its multiplicative order is positive. -/
lemma orderOf_pos_of_not_dvd {p : ℕ} (hp : p.Prime) {a : ℤ} (ha : ¬ (p : ℤ) ∣ a) :
    0 < orderOf ((a : ZMod p)) := by
  haveI : Fact p.Prime := ⟨hp⟩
  have hne : ((a : ZMod p)) ≠ 0 := by
    simpa [ZMod.intCast_zmod_eq_zero_iff_dvd] using ha
  exact orderOf_pos_iff.mpr (isOfFinOrder_iff_isUnit.mpr (IsUnit.mk0 _ hne))

/-- **The smoothness regime, exactly (first half of Conjecture 4).**  For `N = p q` with `p ≠ q`
prime and a base `a` invertible modulo both factors whose two multiplicative orders *differ*,
the Pollard `p-1` reveal time is exactly the smaller of the two orders.  The cost is therefore
an invariant of the hidden factors — nothing about `N` itself bounds it. -/
theorem pm1RevealTime_eq_min_orderOf {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hne : p ≠ q)
    (a : ℤ) (hap : ¬ (p : ℤ) ∣ a) (haq : ¬ (q : ℤ) ∣ a)
    (hdiff : orderOf ((a : ZMod p)) ≠ orderOf ((a : ZMod q))) :
    pm1RevealTime (p * q) a = min (orderOf ((a : ZMod p))) (orderOf ((a : ZMod q))) := by
  set dp := orderOf ((a : ZMod p)) with hdp
  set dq := orderOf ((a : ZMod q)) with hdq
  have hdp0 : 0 < dp := orderOf_pos_of_not_dvd hp hap
  have hdq0 : 0 < dq := orderOf_pos_of_not_dvd hq haq
  -- the minimum is a reveal exponent
  have hmem : min dp dq ∈ {M : ℕ | 0 < M ∧ RevealsFactor (p * q) (a ^ M - 1)} := by
    refine ⟨lt_min hdp0 hdq0, (pollard_pm1_reveal_iff hp hq hne a (min dp dq)).mpr ?_⟩
    rcases lt_or_gt_of_ne hdiff with hlt | hlt
    · have hmin : min dp dq = dp := min_eq_left hlt.le
      left
      refine ⟨by rw [hmin], ?_⟩
      rw [hmin]
      intro hdvd
      exact absurd (Nat.le_of_dvd hdp0 hdvd) (by omega)
    · have hmin : min dp dq = dq := min_eq_right hlt.le
      right
      refine ⟨by rw [hmin], ?_⟩
      rw [hmin]
      intro hdvd
      exact absurd (Nat.le_of_dvd hdq0 hdvd) (by omega)
  refine le_antisymm (Nat.sInf_le hmem) ?_
  -- and nothing smaller is
  have hne' : {M : ℕ | 0 < M ∧ RevealsFactor (p * q) (a ^ M - 1)}.Nonempty := ⟨_, hmem⟩
  obtain ⟨hMpos, hMrev⟩ := Nat.sInf_mem hne'
  exact pollard_pm1_lower_bound hp hq hne a _ hMpos hMrev

set_option maxRecDepth 40000 in
/-- **In-kernel instance.**  On the CTST demo modulus `N = 341371 = 631 · 541` with base `2`,
the Pollard `p-1` reveal time is exactly `45`, the multiplicative order of `2` mod `631`
(the order of `2` mod `541` is `540`).  The reveal time is governed by the hidden factor. -/
theorem pm1RevealTime_demo : pm1RevealTime (631 * 541) 2 = 45 := by
  have hp : Nat.Prime 631 := by norm_num
  have hq : Nat.Prime 541 := by norm_num
  have h631 : orderOf ((2 : ℤ) : ZMod 631) = 45 := by
    have : (((2 : ℤ) : ZMod 631)) = (2 : ZMod 631) := by push_cast; ring
    rw [this]
    have h1 : (2 : ZMod 631) ^ 45 = 1 := by decide
    have h2 : ∀ m ∈ Nat.properDivisors 45, (2 : ZMod 631) ^ m ≠ 1 := by decide
    refine orderOf_eq_of_pow_and_pow_div_prime (by norm_num) h1 ?_
    intro r hr hrdvd
    have hrmem : 45 / r ∈ Nat.properDivisors 45 := by
      have hr1 : 1 < r := hr.one_lt
      have hdvd45 : (45 / r) ∣ 45 := Nat.div_dvd_of_dvd hrdvd
      refine Nat.mem_properDivisors.mpr ⟨hdvd45, ?_⟩
      exact Nat.div_lt_self (by norm_num) hr1
    exact h2 _ hrmem
  have h541 : orderOf ((2 : ℤ) : ZMod 541) = 540 := by
    have : (((2 : ℤ) : ZMod 541)) = (2 : ZMod 541) := by push_cast; ring
    rw [this]
    have h1 : (2 : ZMod 541) ^ 540 = 1 := by decide
    have h2 : ∀ m ∈ Nat.properDivisors 540, (2 : ZMod 541) ^ m ≠ 1 := by decide
    refine orderOf_eq_of_pow_and_pow_div_prime (by norm_num) h1 ?_
    intro r hr hrdvd
    have hrmem : 540 / r ∈ Nat.properDivisors 540 := by
      have hr1 : 1 < r := hr.one_lt
      have hdvd540 : (540 / r) ∣ 540 := Nat.div_dvd_of_dvd hrdvd
      refine Nat.mem_properDivisors.mpr ⟨hdvd540, ?_⟩
      exact Nat.div_lt_self (by norm_num) hr1
    exact h2 _ hrmem
  have := pm1RevealTime_eq_min_orderOf hp hq (by norm_num) (2 : ℤ)
    (by norm_num) (by norm_num) (by rw [h631, h541]; norm_num)
  rw [this, h631, h541]
  norm_num

end CRTSplitNoGo