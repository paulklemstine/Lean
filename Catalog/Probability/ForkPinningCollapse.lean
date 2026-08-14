/-
# The quadratic collapse rate of the semiprime dial

`ForkPinningSemiprimeGeneral` computes the semiprime-level information exactly.  This file
bounds it, for *every* finite group, by an explicit rational function of `n = |G|`:

`I(class N ; [p splits ∨ q splits]) ≤ 1 / ((2n − 1)(n − 1))`,

so the dial decays like `O(1/n²)` while the prime-level information decays only like
`(log n)/n` — the collapse is quadratic in the order of the class group, for every finite
Galois group whatsoever.

The tool is a general `χ²` bound on mutual information (`log t ≤ t − 1` applied to each
Kullback–Leibler term):

* `ForkPinning.mutualInfo_le_chi2` : `I(X;Y) ≤ ∑ P(k,b)² / (P(k) P(b)) − 1`;
* `ForkPinning.semiprime_collapse_rate` : the `1/((2n−1)(n−1))` bound above, which for the
  conductor-7 cyclic cubic (`n = 3`) reads `I ≤ 0.1` nats against the exact `0.0504`.

Numerically the exact dial satisfies `n² I(n) → 1 − log 2 = 0.3069…`, so the bound
`n² I(n) ≤ n²/((2n−1)(n−1)) → 1/2` is off only by a constant factor.
-/

import Probability.ForkPinningSemiprimeGeneral

namespace ForkPinning

open Finset Real

/-! ## A `χ²` upper bound for mutual information -/

section Chi2

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ β : Type*} [Fintype κ] [DecidableEq κ] [Fintype β] [DecidableEq β]

/-- One `χ²` term: `r log (r / (p q)) ≤ r² / (p q) − r`. -/
lemma chi2_term_le {r p q : ℝ} (hr : 0 ≤ r) (hrp : r ≤ p) (hrq : r ≤ q) :
    r * Real.log r - r * Real.log p - r * Real.log q ≤ r * r / (p * q) - r := by
  rcases eq_or_lt_of_le hr with h0 | h0
  · rw [← h0]; simp
  · have hp : 0 < p := lt_of_lt_of_le h0 hrp
    have hq : 0 < q := lt_of_lt_of_le h0 hrq
    have hlog : Real.log (r / (p * q)) ≤ r / (p * q) - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    have hsplit : Real.log (r / (p * q)) = Real.log r - Real.log p - Real.log q := by
      rw [Real.log_div (ne_of_gt h0) (by positivity), Real.log_mul (ne_of_gt hp) (ne_of_gt hq)]
      ring
    rw [hsplit] at hlog
    have hmul := mul_le_mul_of_nonneg_left hlog (le_of_lt h0)
    have hfield : r * (r / (p * q) - 1) = r * r / (p * q) - r := by field_simp
    nlinarith [hmul, hfield]

/-- **The `χ²` bound.**  Mutual information never exceeds the `χ²`-divergence between the joint
law and the product of its marginals. -/
theorem mutualInfo_le_chi2 (X : Ω → κ) (Y : Ω → β) :
    mutualInfo X Y
      ≤ (∑ k : κ, ∑ b : β,
          prb (joint X Y) (k, b) * prb (joint X Y) (k, b) / (prb X k * prb Y b)) - 1 := by
  have hone : ∑ k : κ, ∑ b : β, prb (joint X Y) (k, b) = 1 := by
    rw [Finset.sum_congr rfl (fun k _ => sum_prb_joint X Y k)]
    exact sum_prb X
  have hterm := Finset.sum_le_sum (fun k (_ : k ∈ (univ : Finset κ)) =>
    Finset.sum_le_sum (fun b (_ : b ∈ (univ : Finset β)) =>
      chi2_term_le (prb_nonneg (joint X Y) (k, b)) (prb_joint_le_left X Y k b)
        (prb_joint_le_right X Y k b)))
  rw [← mutualInfo_eq_sum_kl X Y] at hterm
  have hsplit : ∑ k : κ, ∑ b : β,
      (prb (joint X Y) (k, b) * prb (joint X Y) (k, b) / (prb X k * prb Y b)
        - prb (joint X Y) (k, b))
      = (∑ k : κ, ∑ b : β,
          prb (joint X Y) (k, b) * prb (joint X Y) (k, b) / (prb X k * prb Y b))
        - ∑ k : κ, ∑ b : β, prb (joint X Y) (k, b) := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl (fun k _ => by rw [Finset.sum_sub_distrib])
  rw [hsplit, hone] at hterm
  exact hterm

end Chi2

/-! ## The collapse rate -/

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- **Quadratic collapse.**  For every finite group of order `n ≥ 2` the semiprime dial obeys
`I ≤ 1/((2n−1)(n−1))`: even a perfectly pinned prime-level fork degenerates at the semiprime
level at rate `O(1/n²)`. -/
theorem semiprime_collapse_rate (n : ℝ) (hcard : (Fintype.card G : ℝ) = n) (hn : 2 ≤ n) :
    mutualInfo (prodClass : G × G → G) splitORG ≤ 1 / ((2 * n - 1) * (n - 1)) := by
  have hn0 : (0 : ℝ) < n := by linarith
  have hchi := mutualInfo_le_chi2 (prodClass : G × G → G) splitORG
  have hB : ∀ s ∈ univ.erase (1 : G),
      (prb (joint (prodClass : G × G → G) splitORG) (s, true)
          * prb (joint (prodClass : G × G → G) splitORG) (s, true)
          / (prb (prodClass : G × G → G) s * prb (splitORG : G × G → Bool) true)
        + prb (joint (prodClass : G × G → G) splitORG) (s, false)
          * prb (joint (prodClass : G × G → G) splitORG) (s, false)
          / (prb (prodClass : G × G → G) s * prb (splitORG : G × G → Bool) false))
      = (2 / (n * n)) * (2 / (n * n)) / ((1 / n) * ((2 * n - 1) / (n * n)))
        + ((n - 2) / (n * n)) * ((n - 2) / (n * n))
            / ((1 / n) * ((n - 1) * (n - 1) / (n * n))) := by
    intro s hs
    rw [prb_joint_true_ne (Finset.ne_of_mem_erase hs),
      prb_joint_false_ne (Finset.ne_of_mem_erase hs), prb_prodClass,
      prb_splitORG_true, prb_splitORG_false, hcard]
  have hsum : (∑ s : G, ∑ b : Bool,
      prb (joint (prodClass : G × G → G) splitORG) (s, b)
        * prb (joint (prodClass : G × G → G) splitORG) (s, b)
        / (prb (prodClass : G × G → G) s * prb (splitORG : G × G → Bool) b))
      = 1 + 1 / ((2 * n - 1) * (n - 1)) := by
    simp_rw [Fintype.sum_bool]
    rw [sum_split_one, Finset.sum_congr rfl hB, prb_joint_true_one, prb_joint_false_one,
      prb_prodClass, prb_splitORG_true, prb_splitORG_false, Finset.sum_const,
      nsmul_eq_mul, card_erase_one, hcard]
    have h0 : n ≠ 0 := by intro h; linarith [h ▸ hn]
    have h1 : n - 1 ≠ 0 := by intro h; nlinarith
    have h2 : 2 * n - 1 ≠ 0 := by intro h; nlinarith
    have h1' : -1 + n ≠ 0 := by intro h; nlinarith
    have h2' : -1 + n * 2 ≠ 0 := by intro h; nlinarith
    have hu : (-1 + n * 2) * (-1 + n * 2)⁻¹ = 1 := mul_inv_cancel₀ h2'
    field_simp
    linear_combination (2 * n - 3) * hu
  rw [hsum] at hchi
  linarith

/-- For the conductor-7 cyclic cubic (`n = 3`) the collapse bound reads `I ≤ 1/10` nats,
against the exact value `log 3 − (5/9) log 5 − (2/9) log 2 = 0.0504…`. -/
theorem semiprime_collapse_rate_card_three (h : Fintype.card G = 3) :
    mutualInfo (prodClass : G × G → G) splitORG ≤ 1 / 10 := by
  have := semiprime_collapse_rate 3 (by rw [h]; norm_num) (by norm_num) (G := G)
  norm_num at this
  exact this

end ForkPinning