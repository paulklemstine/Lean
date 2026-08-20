/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Price of Universality V: the Rissanen `½ log n` lower bound

The falsifiability gate of the research thread: the upper bounds of
`UniversalRedundancy.Types` must be matched by a lower bound of the *known
minimax rate*.  For a `d`-parameter smooth class the classical rate is
`(d/2) log₂ n`.  Here we prove it, with explicit constants and no asymptotics,
for the one-parameter case `d = 1`: the memoryless binary (Bernoulli) class.

## Central Idea

By Part I the minimax redundancy is `log₂ Cₛ` with `Cₛ = ∑ₓ sup_θ p_θ x`.  For
the Bernoulli class the maximum likelihood of a string with `k` ones is
`(k/n)^k ((n-k)/n)^{n-k}`, and strings of the same *type* form a fibre of size
`C(n,k)`.  Two-sided Stirling bounds — Mathlib's `√(2πn)(n/e)^n ≤ n!` and the
antitonicity of the Stirling sequence, which gives `n! ≤ e √n (n/e)^n` — turn
each fibre contribution into

`C(n,k) (k/n)^k ((n-k)/n)^{n-k} ≥ √(2πn) / (e² √k √(n-k)) ≥ 1/(2√n)`,

and summing the `n-1` interior types gives `Cₛ ≥ (n-1)/(2√n) ≥ √n / 4`.

Hence the price of universality for the binary memoryless class is at least
`½ log₂ n − 2` bits — the Rissanen rate `(d/2) log₂ n` with `d = 1` — while
Part II gives the upper bound `2 log₂ (n+1)`.  Universality is therefore *not*
free, but it is only logarithmically expensive.

## Main Results

* `factorial_le_stirling_upper` — `m! ≤ e √m (m/e)^m` for `m ≥ 1`
* `type_term_lower` — every interior type contributes at least `1/(2√n)`
* `card_ones_fiber` — the type fibre `{x : Fin n → Bool | #ones = k}` has
  `C(n,k)` elements
* `sqrt_le_shtarkovSum_bernoulli` — `√n / 4 ≤ Cₛ` for the binary memoryless
  class, `n ≥ 2`
* `bernoulli_price_lower_bits` — every Kraft-compliant code pays at least
  `½ log₂ n − 2` bits of redundancy on some message against some Bernoulli
  source: the Rissanen rate is unavoidable
* `bernoulli_price_sandwich` — the two-sided statement
  `½ log₂ n − 2 ≤ log₂ Cₛ ≤ 2 log₂ (n+1)`

## Application Keywords

Rissanen redundancy, Stirling bounds, method of types, minimax lower bound,
Bernoulli class, universal coding
-/

import Catalog.MachineLearning.UniversalRedundancy.Types

open Finset Real

namespace UniversalRedundancy

/-! ## Two-sided Stirling bounds -/

/-- Explicit Stirling upper bound: `m! ≤ e·√m·(m/e)^m` for `m ≥ 1`, obtained
from the antitonicity of Mathlib's Stirling sequence. -/
theorem factorial_le_stirling_upper (m : ℕ) (hm : 1 ≤ m) :
    (Nat.factorial m : ℝ) ≤ Real.exp 1 * Real.sqrt m * ((m : ℝ) / Real.exp 1) ^ m := by
  obtain ⟨t, rfl⟩ : ∃ t, m = t + 1 := ⟨m - 1, by omega⟩
  have h := Stirling.stirlingSeq'_antitone (Nat.zero_le t)
  simp only [Function.comp] at h
  rw [Stirling.stirlingSeq_one] at h
  unfold Stirling.stirlingSeq at h
  have hpos : (0:ℝ) < Real.sqrt (2 * ((t+1 : ℕ) : ℝ)) * (((t+1:ℕ):ℝ) / Real.exp 1) ^ (t+1) := by
    have h1 : (0:ℝ) < ((t+1:ℕ) : ℝ) := by positivity
    have h2 : (0:ℝ) < Real.sqrt (2 * ((t+1 : ℕ) : ℝ)) := Real.sqrt_pos.mpr (by positivity)
    positivity
  rw [div_le_iff₀ hpos] at h
  refine le_trans h (le_of_eq ?_)
  have hs : Real.sqrt (2 * ((t+1 : ℕ) : ℝ)) = Real.sqrt 2 * Real.sqrt ((t+1:ℕ) : ℝ) :=
    Real.sqrt_mul (by norm_num) _
  rw [hs]
  have h2 : Real.sqrt 2 ≠ 0 := by positivity
  field_simp

/-- Numerical endgame of `type_term_lower`, isolated for elaboration speed. -/
private lemma type_term_endgame (k j : ℕ) (hk : 1 ≤ k) (hj : 1 ≤ j) (b : ℝ) (hb : 0 < b)
    (step3 : Real.sqrt (2 * π * ((k + j : ℕ) : ℝ))
      ≤ b * (Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j))) :
    1 / (2 * Real.sqrt ((k + j : ℕ) : ℝ)) ≤ b := by
  have hkR : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hjR : (0:ℝ) < (j:ℝ) := by exact_mod_cast hj
  have hnR : (0:ℝ) < ((k+j : ℕ) : ℝ) := by push_cast; linarith
  have hsn : (0:ℝ) < Real.sqrt ((k+j:ℕ):ℝ) := Real.sqrt_pos.mpr hnR
  have hsplit : Real.sqrt (2 * π * ((k+j : ℕ) : ℝ))
      = Real.sqrt (2 * π) * Real.sqrt ((k+j:ℕ):ℝ) := Real.sqrt_mul (by positivity) _
  have hnn : Real.sqrt ((k+j:ℕ):ℝ) * Real.sqrt ((k+j:ℕ):ℝ) = ((k+j:ℕ):ℝ) :=
    Real.mul_self_sqrt hnR.le
  have hgeom : Real.sqrt k * Real.sqrt j ≤ ((k+j:ℕ):ℝ) / 2 := by
    have h1 : Real.sqrt k * Real.sqrt j = Real.sqrt ((k:ℝ) * (j:ℝ)) :=
      (Real.sqrt_mul hkR.le _).symm
    have h2 : (k:ℝ) * (j:ℝ) ≤ (((k+j:ℕ):ℝ)/2)^2 := by
      push_cast; nlinarith [sq_nonneg ((k:ℝ) - j)]
    rw [h1]
    calc Real.sqrt ((k:ℝ) * j) ≤ Real.sqrt ((((k+j:ℕ):ℝ)/2)^2) := Real.sqrt_le_sqrt h2
      _ = ((k+j:ℕ):ℝ)/2 := Real.sqrt_sq (by positivity)
  have h2pi : (2.5:ℝ) ≤ Real.sqrt (2 * π) := by
    have hle : (2.5:ℝ)^2 ≤ 2 * π := by nlinarith [Real.pi_gt_d2]
    calc (2.5:ℝ) = Real.sqrt ((2.5:ℝ)^2) := (Real.sqrt_sq (by norm_num)).symm
      _ ≤ Real.sqrt (2 * π) := Real.sqrt_le_sqrt hle
  have he2 : Real.exp 1 ^ 2 ≤ 7.4 := by nlinarith [Real.exp_one_lt_d9, Real.exp_pos 1]
  rw [hsplit] at step3
  have hstep : (2.5:ℝ) * Real.sqrt ((k+j:ℕ):ℝ) ≤ b * (7.4 * (((k+j:ℕ):ℝ)/2)) := by
    have h1 : b * (Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j))
        ≤ b * (7.4 * (((k+j:ℕ):ℝ)/2)) := by
      have hprod : Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j) ≤ 7.4 * (((k+j:ℕ):ℝ)/2) := by
        have h3 : (0:ℝ) ≤ Real.sqrt k * Real.sqrt j := by positivity
        nlinarith [Real.exp_pos 1]
      exact mul_le_mul_of_nonneg_left hprod hb.le
    nlinarith [h2pi, hsn]
  rw [div_le_iff₀ (by positivity : (0:ℝ) < 2 * Real.sqrt ((k+j:ℕ):ℝ))]
  nlinarith [hstep, hnn, hsn, hb]

/-- **Each interior type contributes at least `1/(2√n)`.**  This is the
quantitative heart of the Rissanen lower bound. -/
theorem type_term_lower (k j : ℕ) (hk : 1 ≤ k) (hj : 1 ≤ j) :
    1 / (2 * Real.sqrt ((k + j : ℕ) : ℝ))
      ≤ (((k + j).choose k : ℕ) : ℝ) * ((k:ℝ)/((k+j:ℕ):ℝ))^k * ((j:ℝ)/((k+j:ℕ):ℝ))^j := by
  have hkR : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hjR : (0:ℝ) < (j:ℝ) := by exact_mod_cast hj
  have hnR : (0:ℝ) < ((k+j : ℕ) : ℝ) := by push_cast; linarith
  have hkn : k ≤ k + j := by omega
  have hsub : k + j - k = j := by omega
  have hfact : (Nat.factorial (k+j) : ℝ)
      = (((k+j).choose k : ℕ) : ℝ) * (Nat.factorial k : ℝ) * (Nat.factorial j : ℝ) := by
    have h := Nat.choose_mul_factorial_mul_factorial hkn
    rw [hsub] at h
    exact_mod_cast h.symm
  have hlow := Stirling.le_factorial_stirling (k+j)
  have huk := factorial_le_stirling_upper k hk
  have huj := factorial_le_stirling_upper j hj
  set C : ℝ := (((k + j).choose k : ℕ) : ℝ) with hC
  have hCpos : 0 < C := by rw [hC]; exact_mod_cast Nat.choose_pos hkn
  set P : ℝ := ((k:ℝ)/((k+j:ℕ):ℝ))^k * ((j:ℝ)/((k+j:ℕ):ℝ))^j with hP
  have hPpos : 0 < P := by rw [hP]; positivity
  set Q : ℝ := ((k:ℝ)/Real.exp 1)^k * ((j:ℝ)/Real.exp 1)^j with hQ
  have hQpos : 0 < Q := by rw [hQ]; positivity
  have hident : (((k+j : ℕ) : ℝ) / Real.exp 1) ^ (k+j) * P = Q := by
    rw [hP, hQ, div_pow, div_pow, div_pow, div_pow, div_pow, pow_add, pow_add]
    field_simp
  have step1 : Real.sqrt (2 * π * ((k+j : ℕ) : ℝ)) * (((k+j:ℕ):ℝ) / Real.exp 1) ^ (k+j)
      ≤ C * (Real.exp 1 * Real.sqrt k * ((k:ℝ)/Real.exp 1)^k)
          * (Real.exp 1 * Real.sqrt j * ((j:ℝ)/Real.exp 1)^j) := by
    refine le_trans hlow ?_
    rw [hfact]
    have h1 : (Nat.factorial k : ℝ) * (Nat.factorial j : ℝ)
        ≤ (Real.exp 1 * Real.sqrt k * ((k:ℝ)/Real.exp 1)^k)
          * (Real.exp 1 * Real.sqrt j * ((j:ℝ)/Real.exp 1)^j) := by
      have hk0 : (0:ℝ) ≤ (Nat.factorial k : ℝ) := by positivity
      have hj0 : (0:ℝ) ≤ (Nat.factorial j : ℝ) := by positivity
      have hu0 : (0:ℝ) ≤ Real.exp 1 * Real.sqrt k * ((k:ℝ)/Real.exp 1)^k := by positivity
      nlinarith
    nlinarith [hCpos, h1]
  have step2 : Real.sqrt (2 * π * ((k+j : ℕ) : ℝ)) * Q
      ≤ (C * P) * (Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j)) * Q := by
    have hmul := mul_le_mul_of_nonneg_right step1 hPpos.le
    calc Real.sqrt (2 * π * ((k+j : ℕ) : ℝ)) * Q
        = Real.sqrt (2 * π * ((k+j : ℕ) : ℝ)) * ((((k+j:ℕ):ℝ) / Real.exp 1) ^ (k+j) * P) := by
          rw [hident]
      _ = (Real.sqrt (2 * π * ((k+j : ℕ) : ℝ)) * (((k+j:ℕ):ℝ) / Real.exp 1) ^ (k+j)) * P := by
          ring
      _ ≤ (C * (Real.exp 1 * Real.sqrt k * ((k:ℝ)/Real.exp 1)^k)
            * (Real.exp 1 * Real.sqrt j * ((j:ℝ)/Real.exp 1)^j)) * P := hmul
      _ = (C * P) * (Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j)) * Q := by rw [hQ]; ring
  have step3 : Real.sqrt (2 * π * ((k+j : ℕ) : ℝ))
      ≤ (C * P) * (Real.exp 1 ^ 2 * (Real.sqrt k * Real.sqrt j)) :=
    le_of_mul_le_mul_right (by linarith [step2]) hQpos
  have hCP : 0 < C * P := mul_pos hCpos hPpos
  have hgoal : 1 / (2 * Real.sqrt ((k + j : ℕ) : ℝ)) ≤ C * P :=
    type_term_endgame k j hk hj (C * P) hCP step3
  calc 1 / (2 * Real.sqrt ((k + j : ℕ) : ℝ)) ≤ C * P := hgoal
    _ = C * ((k:ℝ)/((k+j:ℕ):ℝ))^k * ((j:ℝ)/((k+j:ℕ):ℝ))^j := by rw [hP]; ring

/-! ## Types of binary strings -/

/-- The number of ones in a binary string. -/
def ones {n : ℕ} (x : Fin n → Bool) : ℕ := (univ.filter (fun i => x i = true)).card

lemma ones_le {n : ℕ} (x : Fin n → Bool) : ones x ≤ n := by
  unfold ones
  calc (univ.filter (fun i => x i = true)).card ≤ (univ : Finset (Fin n)).card :=
        Finset.card_filter_le _ _
    _ = n := by simp

lemma card_zeros {n : ℕ} (x : Fin n → Bool) :
    (univ.filter (fun i => x i = false)).card = n - ones x := by
  classical
  have h := Finset.card_filter_add_card_filter_not
    (s := (univ : Finset (Fin n))) (p := fun i => x i = true)
  have h2 : (univ.filter (fun i => ¬ (x i = true))) = univ.filter (fun i => x i = false) := by
    refine Finset.filter_congr fun i _ => ?_
    cases x i <;> simp
  rw [h2] at h
  simp only [Finset.card_univ, Fintype.card_fin] at h
  unfold ones
  omega

/-- **The type fibre has `C(n,k)` elements.** -/
theorem card_ones_fiber (n k : ℕ) :
    (univ.filter (fun x : Fin n → Bool => ones x = k)).card = n.choose k := by
  classical
  have hbij : (univ.filter (fun x : Fin n → Bool => ones x = k)).card
      = (Finset.powersetCard k (univ : Finset (Fin n))).card := by
    refine Finset.card_bij' (fun x _ => univ.filter (fun i => x i = true))
      (fun s _ => fun i => decide (i ∈ s)) ?_ ?_ ?_ ?_
    · intro x hx
      have hx' : ones x = k := (Finset.mem_filter.mp hx).2
      simp only [Finset.mem_powersetCard]
      exact ⟨Finset.subset_univ _, hx'⟩
    · intro s hs
      have hs' : s.card = k := (Finset.mem_powersetCard.mp hs).2
      refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
      have hfil : (univ.filter (fun i => (decide (i ∈ s)) = true)) = s := by
        ext i; simp
      unfold ones
      rw [hfil, hs']
    · intro x hx
      funext i
      simp
    · intro s hs
      ext i
      simp
  rw [hbij, Finset.card_powersetCard]
  simp

/-! ## The Bernoulli class and its Shtarkov sum -/

/-- The maximum-likelihood Bernoulli parameter of a string with `k` ones. -/
noncomputable def bernoulliParam (n k : ℕ) (hn : 0 < n) (hk : k ≤ n) : Simplex Bool :=
  ⟨fun b => if b then (k : ℝ) / n else ((n - k : ℕ) : ℝ) / n, by
    intro b
    have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    cases b <;> simp <;> positivity, by
    have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn
    have hsum : (k : ℝ) + ((n - k : ℕ) : ℝ) = (n : ℝ) := by
      have hnat : k + (n - k : ℕ) = n := by omega
      exact_mod_cast congrArg (fun m : ℕ => (m : ℝ)) hnat
    have hkey : (k : ℝ) / n + ((n - k : ℕ) : ℝ) / n = 1 := by
      rw [← add_div, hsum, div_self hnR.ne']
    simpa [Fintype.sum_bool] using hkey⟩

/-- The likelihood of a string under its own maximum-likelihood parameter. -/
lemma prob_bernoulliParam {n : ℕ} (hn : 0 < n) (x : Fin n → Bool) :
    (iidClass Bool n).prob (bernoulliParam n (ones x) hn (ones_le x)) x
      = ((ones x : ℝ) / n) ^ (ones x) * (((n - ones x : ℕ) : ℝ) / n) ^ (n - ones x) := by
  classical
  have hprod := prod_eq_prod_pow_countStat
    (g := fun b : Bool => (bernoulliParam n (ones x) hn (ones_le x)).1 b) (w := x)
  simp only [iidClass]
  rw [hprod, Fintype.prod_bool]
  have hct : ((countStat x true : Fin (n+1)) : ℕ) = ones x := rfl
  have hcf : ((countStat x false : Fin (n+1)) : ℕ) = n - ones x := card_zeros x
  rw [hct, hcf]
  simp only [bernoulliParam]
  norm_num

/-- **The Rissanen lower bound.**  For `n ≥ 2` the Shtarkov sum of the binary
memoryless class is at least `√n / 4`; hence the minimax redundancy is at least
`½ log₂ n − 2` bits. -/
theorem sqrt_le_shtarkovSum_bernoulli (n : ℕ) (hn : 2 ≤ n) :
    Real.sqrt n / 4 ≤ (iidClass Bool n).shtarkovSum := by
  classical
  have hn0 : 0 < n := by omega
  have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn0
  have hsn : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hnR
  set F : ℕ → Finset (Fin n → Bool) :=
    fun k => univ.filter (fun x : Fin n → Bool => ones x = k) with hF
  -- each fibre contributes at least 1/(2√n)
  have hfibre : ∀ k ∈ Finset.Icc 1 (n - 1),
      1 / (2 * Real.sqrt n) ≤ ∑ x ∈ F k, (iidClass Bool n).maxLik x := by
    intro k hk
    simp only [Finset.mem_Icc] at hk
    have hk1 : 1 ≤ k := hk.1
    have hkn : k < n := by omega
    set j := n - k with hj
    have hj1 : 1 ≤ j := by omega
    have hkj : k + j = n := by omega
    have hterm : ∀ x ∈ F k, ((k : ℝ) / n) ^ k * ((j : ℝ) / n) ^ j
        ≤ (iidClass Bool n).maxLik x := by
      intro x hx
      have hox : ones x = k := (Finset.mem_filter.mp hx).2
      have hp := prob_bernoulliParam hn0 x
      have hle := (iidClass Bool n).le_maxLik
        (bernoulliParam n (ones x) hn0 (ones_le x)) x
      rw [hp] at hle
      rw [hox] at hle
      have hnk : n - k = j := by omega
      rw [hnk] at hle
      exact hle
    have hcard : (F k).card = n.choose k := by rw [hF]; exact card_ones_fiber n k
    have hsum : ((n.choose k : ℕ) : ℝ) * (((k : ℝ) / n) ^ k * ((j : ℝ) / n) ^ j)
        ≤ ∑ x ∈ F k, (iidClass Bool n).maxLik x := by
      calc ((n.choose k : ℕ) : ℝ) * (((k : ℝ) / n) ^ k * ((j : ℝ) / n) ^ j)
          = ∑ _x ∈ F k, ((k : ℝ) / n) ^ k * ((j : ℝ) / n) ^ j := by
            rw [Finset.sum_const, hcard, nsmul_eq_mul]
        _ ≤ ∑ x ∈ F k, (iidClass Bool n).maxLik x :=
            Finset.sum_le_sum fun x hx => hterm x hx
    have hlow := type_term_lower k j hk1 hj1
    have hcast : ((k + j : ℕ) : ℝ) = (n : ℝ) := by rw [hkj]
    rw [hcast, hkj] at hlow
    calc 1 / (2 * Real.sqrt n) ≤ ((n.choose k : ℕ) : ℝ) * ((k:ℝ)/(n:ℝ))^k * ((j:ℝ)/(n:ℝ))^j :=
          hlow
      _ = ((n.choose k : ℕ) : ℝ) * (((k : ℝ) / n) ^ k * ((j : ℝ) / n) ^ j) := by ring
      _ ≤ ∑ x ∈ F k, (iidClass Bool n).maxLik x := hsum
  -- the fibres are disjoint
  have hdisj : (↑(Finset.Icc 1 (n-1)) : Set ℕ).PairwiseDisjoint F := by
    intro k _ l _ hkl
    refine Finset.disjoint_left.mpr fun x hx hx' => ?_
    have h1 : ones x = k := (Finset.mem_filter.mp hx).2
    have h2 : ones x = l := (Finset.mem_filter.mp hx').2
    exact hkl (h1 ▸ h2 ▸ rfl)
  have hunion : ∑ k ∈ Finset.Icc 1 (n-1), ∑ x ∈ F k, (iidClass Bool n).maxLik x
      ≤ (iidClass Bool n).shtarkovSum := by
    rw [← Finset.sum_biUnion hdisj]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun x _ _ => (iidClass Bool n).maxLik_nonneg x
  have hcount : ((Finset.Icc 1 (n-1)).card : ℝ) = (n : ℝ) - 1 := by
    rw [Nat.card_Icc]
    have : n - 1 + 1 - 1 = n - 1 := by omega
    rw [this]
    have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
      have : (1 : ℕ) ≤ n := by omega
      push_cast [Nat.cast_sub this]
      ring
    exact hcast
  have hsum_low : ((n : ℝ) - 1) * (1 / (2 * Real.sqrt n))
      ≤ ∑ k ∈ Finset.Icc 1 (n-1), ∑ x ∈ F k, (iidClass Bool n).maxLik x := by
    calc ((n : ℝ) - 1) * (1 / (2 * Real.sqrt n))
        = ∑ _k ∈ Finset.Icc 1 (n-1), 1 / (2 * Real.sqrt n) := by
          rw [Finset.sum_const, nsmul_eq_mul, hcount]
      _ ≤ ∑ k ∈ Finset.Icc 1 (n-1), ∑ x ∈ F k, (iidClass Bool n).maxLik x :=
          Finset.sum_le_sum hfibre
  have hnn : Real.sqrt n * Real.sqrt n = (n : ℝ) := Real.mul_self_sqrt hnR.le
  have hn2 : (2:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hfinal : Real.sqrt n / 4 ≤ ((n : ℝ) - 1) * (1 / (2 * Real.sqrt n)) := by
    refine le_of_mul_le_mul_right ?_ (by positivity : (0:ℝ) < 2 * Real.sqrt n)
    have h1 : Real.sqrt n / 4 * (2 * Real.sqrt n) = (n:ℝ)/2 := by
      field_simp
      nlinarith [hnn]
    have h2 : ((n:ℝ)-1) * (1 / (2 * Real.sqrt n)) * (2 * Real.sqrt n) = (n:ℝ)-1 := by
      field_simp
    rw [h1, h2]
    linarith
  linarith [hfinal, hsum_low, hunion]

/-- **The price of universality for the Bernoulli class is at least
`½ log₂ n − 2` bits.**  Every Kraft-compliant code has a message and a Bernoulli
source on which it exceeds the ideal code length by that much. -/
theorem bernoulli_price_lower_bits (n : ℕ) (hn : 2 ≤ n) :
    (1 / 2) * logb 2 n - 2 ≤ logb 2 (iidClass Bool n).shtarkovSum := by
  have hn0 : 0 < n := by omega
  have hnR : (0:ℝ) < (n:ℝ) := by exact_mod_cast hn0
  have hsn : (0:ℝ) < Real.sqrt n := Real.sqrt_pos.mpr hnR
  have hle := sqrt_le_shtarkovSum_bernoulli n hn
  have hlog : logb 2 (Real.sqrt n / 4) ≤ logb 2 (iidClass Bool n).shtarkovSum :=
    Real.logb_le_logb_of_le (by norm_num) (by positivity) hle
  have hsplit : logb 2 (Real.sqrt n / 4) = (1/2) * logb 2 n - 2 := by
    rw [Real.logb_div (by positivity) (by norm_num)]
    have h1 : logb 2 (Real.sqrt n) = (1/2) * logb 2 n := by
      unfold Real.logb
      rw [Real.log_sqrt hnR.le]
      ring
    have h2 : logb 2 (4:ℝ) = 2 := by
      rw [show (4:ℝ) = 2 ^ (2:ℕ) by norm_num, Real.logb_pow,
        Real.logb_self_eq_one (by norm_num)]
      ring
    rw [h1, h2]
  linarith [hsplit ▸ hlog]

/-! ## Matching upper bound and the sandwich -/

/-- The likelihood of a binary memoryless source depends on the string only
through its number of ones, so the type statistic has `n+1` values. -/
theorem shtarkovSum_bernoulli_le (n : ℕ) :
    (iidClass Bool n).shtarkovSum ≤ ((n : ℝ) + 1) := by
  classical
  have hstat := (iidClass Bool n).shtarkovSum_le_card_statistic
    (T := fun x : Fin n → Bool => (⟨ones x, by have := ones_le x; omega⟩ : Fin (n + 1)))
    ?_
  · refine le_trans hstat (le_of_eq ?_)
    simp
  · intro θ x y hxy
    have hones : ones x = ones y := congrArg Fin.val hxy
    have hx := prod_eq_prod_pow_countStat (g := fun b : Bool => θ.1 b) (w := x)
    have hy := prod_eq_prod_pow_countStat (g := fun b : Bool => θ.1 b) (w := y)
    have hxt : ((countStat x true : Fin (n+1)) : ℕ) = ones x := rfl
    have hyt : ((countStat y true : Fin (n+1)) : ℕ) = ones y := rfl
    have hxf : ((countStat x false : Fin (n+1)) : ℕ) = n - ones x := card_zeros x
    have hyf : ((countStat y false : Fin (n+1)) : ℕ) = n - ones y := card_zeros y
    simp only [iidClass]
    rw [hx, hy, Fintype.prod_bool, Fintype.prod_bool, hxt, hyt, hxf, hyf, hones]

/-- **The price of universality of the binary memoryless class, sandwiched.**
The lower bound is the Rissanen rate `½ log₂ n`; the upper bound is the method
of types.  Universality costs between `½ log₂ n − 2` and `log₂ (n+1)` bits — a
vanishing fraction of the `n`-bit message, but never zero. -/
theorem bernoulli_price_sandwich (n : ℕ) (hn : 2 ≤ n) :
    (1 / 2) * logb 2 n - 2 ≤ logb 2 (iidClass Bool n).shtarkovSum ∧
      logb 2 (iidClass Bool n).shtarkovSum ≤ logb 2 ((n : ℝ) + 1) := by
  refine ⟨bernoulli_price_lower_bits n hn, ?_⟩
  exact Real.logb_le_logb_of_le (by norm_num) (iidClass Bool n).shtarkovSum_pos
    (shtarkovSum_bernoulli_le n)

end UniversalRedundancy