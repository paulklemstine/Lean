/-
  # Strict single-crossing for the harmonic-bulk × steeper-edge kernel

  `Probability.HarmonicBulkSteeperEdge` proves that the window-implied exponent of a
  two-component (bulk × edge) power-law kernel is **antitone** in the window width:
  a narrower head window never reports a shallower exponent than a wider one
  (`implied_exponent_antitone`).  The inequality obtained there is non-strict, because the
  quasiconvexity input (`two_term_rpow_quasiconvex`) was proved through a non-strict
  weighted AM–GM.  This file closes that gap: for a genuine mixture (`0 < w < 1`,
  `a < b`) the window law is **strict**.

  ## Contents

  * `rpow_log_convex` / `rpow_log_strictConvex` — a single real power `x ↦ x ^ e` is convex
    in `log x`, strictly so when `e ≠ 0` (via strict convexity of `exp`).
  * `mixRatio_strict_log_convex` — the mixture-to-power-law ratio is *strictly* convex in
    the logarithmic variable: since `a < b`, at least one of the two exponents `c - a`,
    `c - b` is nonzero, so a strictly convex summand is always present.
  * `mixRatio_lt_of_crossed_strict` — **strict no-return.**  If the ratio is at or below a
    level at `k₁` and at or above it at some `k₀ > k₁`, then it is *strictly above* the
    level at every `k > k₀`.  The base file's no-return lemma needs a strict crossing;
    strict convexity upgrades a weak crossing to a strict one-sided conclusion.
  * `headMass_lt_mixHeadMass_of_match` — a pure power law matching the mixture on a window
    reports **strictly** less head mass on every narrower window.
  * `implied_exponent_strictAnti` — hence `c₂ < c₁`: narrower windows report *strictly*
    steeper implied exponents.  This closes direction 1 of the previous cycle's
    `FUTURE_DIRECTIONS.md`.
  * `no_mixture_matches_two_windows_with_equal_exponent` — the diagnostic consequence: two
    head windows reporting the *same* implied exponent certify that the kernel is not a
    bulk × edge mixture.
  * `harmonic_edge_mixture_window_exponents_strictAnti` — the capstone for the recorded
    harmonic-bulk / quadratic-edge kernel.

  The proof of the strict window law is structurally simpler than the non-strict one.  The
  strict no-return lemma shows that on the wide window `{1,…,m₂}` the discrepancy
  `d k = mix k - θ · pw c k` has a genuine single sign change: it is positive on an initial
  segment and strictly negative afterwards.  Each of the two possible positions of the
  narrow window relative to that sign change then yields a strict inequality.
-/
import Mathlib
import Probability.HarmonicBulkSteeperEdge

open Finset

namespace HarmonicBulkSteeperEdge

/-! ## Strict log-convexity of real powers -/

/-- A real power is convex in the logarithmic variable. -/
lemma rpow_log_convex (e : ℝ) {x y z lam : ℝ} (hx : 0 < x) (hy : 0 < y) (hz : 0 < z)
    (hlam0 : 0 < lam) (hlam1 : lam < 1)
    (hcomb : Real.log y = lam * Real.log x + (1 - lam) * Real.log z) :
    y ^ e ≤ lam * x ^ e + (1 - lam) * z ^ e := by
  have hxe : x ^ e = Real.exp (e * Real.log x) := by
    rw [Real.rpow_def_of_pos hx, mul_comm]
  have hye : y ^ e = Real.exp (e * Real.log y) := by
    rw [Real.rpow_def_of_pos hy, mul_comm]
  have hze : z ^ e = Real.exp (e * Real.log z) := by
    rw [Real.rpow_def_of_pos hz, mul_comm]
  have hkey : e * Real.log y = lam * (e * Real.log x) + (1 - lam) * (e * Real.log z) := by
    rw [hcomb]; ring
  have hconv := convexOn_exp.2 (Set.mem_univ (e * Real.log x)) (Set.mem_univ (e * Real.log z))
    hlam0.le (by linarith : (0:ℝ) ≤ 1 - lam) (by ring)
  simp only [smul_eq_mul] at hconv
  rw [hye, hxe, hze, hkey]
  exact hconv

/-- A real power with nonzero exponent is *strictly* convex in the logarithmic
variable. -/
lemma rpow_log_strictConvex {e : ℝ} (he : e ≠ 0) {x y z lam : ℝ} (hx : 0 < x) (hy : 0 < y)
    (hz : 0 < z) (hxz : x ≠ z) (hlam0 : 0 < lam) (hlam1 : lam < 1)
    (hcomb : Real.log y = lam * Real.log x + (1 - lam) * Real.log z) :
    y ^ e < lam * x ^ e + (1 - lam) * z ^ e := by
  have hxe : x ^ e = Real.exp (e * Real.log x) := by
    rw [Real.rpow_def_of_pos hx, mul_comm]
  have hye : y ^ e = Real.exp (e * Real.log y) := by
    rw [Real.rpow_def_of_pos hy, mul_comm]
  have hze : z ^ e = Real.exp (e * Real.log z) := by
    rw [Real.rpow_def_of_pos hz, mul_comm]
  have hlogne : Real.log x ≠ Real.log z := by
    intro hcon
    have := congrArg Real.exp hcon
    rw [Real.exp_log hx, Real.exp_log hz] at this
    exact hxz this
  have hne : e * Real.log x ≠ e * Real.log z := fun hcon => hlogne (mul_left_cancel₀ he hcon)
  have hkey : e * Real.log y = lam * (e * Real.log x) + (1 - lam) * (e * Real.log z) := by
    rw [hcomb]; ring
  have hconv := strictConvexOn_exp.2 (Set.mem_univ (e * Real.log x))
    (Set.mem_univ (e * Real.log z)) hne hlam0 (by linarith : (0:ℝ) < 1 - lam) (by ring)
  simp only [smul_eq_mul] at hconv
  rw [hye, hxe, hze, hkey]
  exact hconv

/-! ## Strict convexity of the mixture-to-power-law ratio -/

/-- **Strict log-convexity of the mixture ratio.**  For a genuine mixture (`0 < w < 1`,
`a < b`) the ratio `mixRatio w a b c` is strictly convex along the logarithmic scale: at
least one of the two exponents `c - a`, `c - b` is nonzero, hence contributes a strictly
convex summand. -/
lemma mixRatio_strict_log_convex {w a b c : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b)
    {i j l : ℕ} (hi : 1 ≤ i) (hij : i < j) (hjl : j < l) :
    ∃ lam : ℝ, 0 < lam ∧ lam < 1 ∧
      mixRatio w a b c j < lam * mixRatio w a b c i + (1 - lam) * mixRatio w a b c l := by
  have hj : 1 ≤ j := by omega
  have hl : 1 ≤ l := by omega
  have hx : (0:ℝ) < (i:ℝ) := by exact_mod_cast hi
  have hy : (0:ℝ) < (j:ℝ) := by exact_mod_cast hj
  have hz : (0:ℝ) < (l:ℝ) := by exact_mod_cast hl
  have hxy : (i:ℝ) < (j:ℝ) := by exact_mod_cast hij
  have hyz : (j:ℝ) < (l:ℝ) := by exact_mod_cast hjl
  have hxz : (i:ℝ) ≠ (l:ℝ) := by
    have : (i:ℝ) < (l:ℝ) := lt_trans hxy hyz
    exact ne_of_lt this
  set l1 := Real.log (i:ℝ) with hl1
  set l2 := Real.log (j:ℝ) with hl2
  set l3 := Real.log (l:ℝ) with hl3
  have h12 : l1 < l2 := Real.log_lt_log hx hxy
  have h23 : l2 < l3 := Real.log_lt_log hy hyz
  have hden : 0 < l3 - l1 := by linarith
  refine ⟨(l3 - l2) / (l3 - l1), div_pos (by linarith) hden, ?_, ?_⟩
  · rw [div_lt_one hden]; linarith
  · set lam := (l3 - l2) / (l3 - l1) with hlam
    have hlam0 : 0 < lam := div_pos (by linarith) hden
    have hlam1 : lam < 1 := by rw [hlam, div_lt_one hden]; linarith
    have hcomb : l2 = lam * l1 + (1 - lam) * l3 := by
      rw [hlam]; field_simp; ring
    have hcomb' : Real.log (j:ℝ) = lam * Real.log (i:ℝ) + (1 - lam) * Real.log (l:ℝ) := by
      rw [← hl1, ← hl2, ← hl3]; exact hcomb
    -- the two exponents cannot both vanish
    have hexp : c - a ≠ 0 ∨ c - b ≠ 0 := by
      by_contra hcon
      push_neg at hcon
      obtain ⟨h1, h2⟩ := hcon
      have : a = b := by linarith [sub_eq_zero.1 h1, sub_eq_zero.1 h2]
      linarith
    rw [mixRatio_eq w a b c hi, mixRatio_eq w a b c hj, mixRatio_eq w a b c hl]
    have hw1' : (0:ℝ) < 1 - w := by linarith
    rcases hexp with he | he
    · have hs := rpow_log_strictConvex (e := c - a) he hx hy hz hxz hlam0 hlam1 hcomb'
      have hc := rpow_log_convex (c - b) hx hy hz hlam0 hlam1 hcomb'
      nlinarith [mul_lt_mul_of_pos_left hs hw1', mul_le_mul_of_nonneg_left hc hw0.le]
    · have hs := rpow_log_strictConvex (e := c - b) he hx hy hz hxz hlam0 hlam1 hcomb'
      have hc := rpow_log_convex (c - a) hx hy hz hlam0 hlam1 hcomb'
      nlinarith [mul_lt_mul_of_pos_left hs hw0, mul_le_mul_of_nonneg_left hc hw1'.le]

/-- **Strict no-return.**  If the mixture-to-power-law ratio is at or below a level at
`k₁`, and at or above the same level at a later index `k₀`, then beyond `k₀` it is
strictly above the level. -/
lemma mixRatio_lt_of_crossed_strict {w a b c theta : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    (hab : a < b) {k₁ k₀ k : ℕ} (hk₁ : 1 ≤ k₁) (h₁₀ : k₁ < k₀) (h₀k : k₀ < k)
    (hlow : mixRatio w a b c k₁ ≤ theta) (hhigh : theta ≤ mixRatio w a b c k₀) :
    theta < mixRatio w a b c k := by
  obtain ⟨lam, hlam0, hlam1, hconv⟩ :=
    mixRatio_strict_log_convex (w := w) (a := a) (b := b) (c := c) hw0 hw1 hab hk₁ h₁₀ h₀k
  nlinarith [mul_le_mul_of_nonneg_left hlow hlam0.le]

/-! ## The strict single-crossing window law -/

/-- **Strict single-crossing window law.**  If a pure power law with exponent `c` matches
the head mass of a genuine bulk × edge mixture on the window `{1, …, m₂}`, then on every
narrower window it reports *strictly* less head mass than the mixture. -/
theorem headMass_lt_mixHeadMass_of_match {w a b c : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    (hab : a < b) {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (hmatch : headMass c n m₂ = mixHeadMass w a b n m₂) :
    headMass c n m₁ < mixHeadMass w a b n m₁ := by
  have hPn : 0 < headSum c n := headSum_pos (by omega)
  have hQn : 0 < mixHeadSum w a b n := mix_head_sum_pos hw0 hw1 (by omega)
  set theta : ℝ := mixHeadSum w a b n / headSum c n with htheta
  set d : ℕ → ℝ := fun k => mix w a b k - theta * pw c k with hd
  have hT : ∀ m : ℕ, ∑ k ∈ Finset.Icc 1 m, d k
      = mixHeadSum w a b m - theta * headSum c m := by
    intro m
    simp [hd, mixHeadSum, headSum, Finset.sum_sub_distrib, Finset.mul_sum]
  have hsign : ∀ k : ℕ, 1 ≤ k → d k = pw c k * (mixRatio w a b c k - theta) := by
    intro k hk
    have hp : (0:ℝ) < pw c k := pw_pos hk
    simp only [hd, mixRatio]
    field_simp
  have hTn : ∑ k ∈ Finset.Icc 1 n, d k = 0 := by
    rw [hT, htheta]
    field_simp
    ring
  have hTm₂ : ∑ k ∈ Finset.Icc 1 m₂, d k = 0 := by
    rw [hT, htheta]
    have hQm₂ : mixHeadSum w a b m₂ = (mixHeadSum w a b n / headSum c n) * headSum c m₂ := by
      have hm := hmatch
      rw [headMass, mixHeadMass, div_eq_div_iff (ne_of_gt hPn) (ne_of_gt hQn)] at hm
      field_simp
      linarith [hm]
    rw [hQm₂]
    ring
  -- Once the discrepancy is nonpositive it can never return to nonnegative before `m₂`.
  have hA : ∀ k₁ k₀ : ℕ, 1 ≤ k₁ → k₁ < k₀ → k₀ ≤ m₂ → d k₁ ≤ 0 → d k₀ < 0 := by
    intro k₁ k₀ hk1 h10 h0m hle
    by_contra hcon
    push_neg at hcon
    have hlow : mixRatio w a b c k₁ ≤ theta := by
      have hp : (0:ℝ) < pw c k₁ := pw_pos hk1
      have hs := hsign k₁ hk1
      nlinarith [hle, hs]
    have hhigh : theta ≤ mixRatio w a b c k₀ := by
      have hp : (0:ℝ) < pw c k₀ := pw_pos (by omega)
      have hs := hsign k₀ (by omega)
      nlinarith [hcon, hs]
    have htail : ∀ k ∈ Finset.Ioc m₂ n, 0 < d k := by
      intro k hk
      have hkgt : m₂ < k := (Finset.mem_Ioc.1 hk).1
      have hkone : 1 ≤ k := by omega
      have hratio : theta < mixRatio w a b c k :=
        mixRatio_lt_of_crossed_strict hw0 hw1 hab hk1 h10 (by omega) hlow hhigh
      have hp : (0:ℝ) < pw c k := pw_pos hkone
      have hs := hsign k hkone
      nlinarith [hratio, hs]
    have hpos : 0 < ∑ k ∈ Finset.Ioc m₂ n, d k := Finset.sum_pos htail ⟨n, by simp [h₂n]⟩
    have hsplit : ∑ k ∈ Finset.Icc 1 n, d k
        = ∑ k ∈ Finset.Icc 1 m₂, d k + ∑ k ∈ Finset.Ioc m₂ n, d k := sum_Icc_split d h₂n.le
    rw [hTn, hTm₂] at hsplit
    linarith
  -- the narrow-window discrepancy is strictly positive
  have hkey : 0 < ∑ k ∈ Finset.Icc 1 m₁, d k := by
    by_cases hall : ∀ k ∈ Finset.Icc 1 m₁, 0 < d k
    · exact Finset.sum_pos hall ⟨1, by simp [hm₁]⟩
    · push_neg at hall
      obtain ⟨k₁, hk₁mem, hk₁le⟩ := hall
      have hk₁1 : 1 ≤ k₁ := (Finset.mem_Icc.1 hk₁mem).1
      have hk₁m : k₁ ≤ m₁ := (Finset.mem_Icc.1 hk₁mem).2
      have hneg : ∀ k ∈ Finset.Ioc m₁ m₂, d k < 0 := by
        intro k hk
        have hk1 : m₁ < k := (Finset.mem_Ioc.1 hk).1
        have hk2 : k ≤ m₂ := (Finset.mem_Ioc.1 hk).2
        exact hA k₁ k hk₁1 (by omega) hk2 hk₁le
      have hsum : ∑ k ∈ Finset.Ioc m₁ m₂, d k < 0 :=
        Finset.sum_neg hneg ⟨m₂, by simp [h₁₂]⟩
      have hsplit : ∑ k ∈ Finset.Icc 1 m₂, d k
          = ∑ k ∈ Finset.Icc 1 m₁, d k + ∑ k ∈ Finset.Ioc m₁ m₂, d k := sum_Icc_split d h₁₂.le
      rw [hTm₂] at hsplit
      linarith
  rw [hT] at hkey
  have hthP : theta * headSum c n = mixHeadSum w a b n := by
    rw [htheta]; field_simp
  have hkey' : theta * headSum c m₁ < mixHeadSum w a b m₁ := by linarith
  have hprod : theta * headSum c m₁ * headSum c n = headSum c m₁ * mixHeadSum w a b n := by
    rw [← hthP]; ring
  rw [headMass, mixHeadMass, div_lt_div_iff₀ hPn hQn]
  linarith [mul_lt_mul_of_pos_right hkey' hPn, hprod]

/-- **The window-implied exponent is strictly antitone in the window width.**  For a
genuine bulk × edge mixture, a narrower head window reports a *strictly* steeper implied
exponent than a wider one. -/
theorem implied_exponent_strictAnti {w a b c₁ c₂ : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    (hab : a < b) {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (h₁ : headMass c₁ n m₁ = mixHeadMass w a b n m₁)
    (h₂ : headMass c₂ n m₂ = mixHeadMass w a b n m₂) :
    c₂ < c₁ := by
  by_contra hcon
  push_neg at hcon
  have hmono : headMass c₁ n m₁ ≤ headMass c₂ n m₁ :=
    headMass_le_of_exponent_le hcon hm₁ (by omega)
  have hstrict : headMass c₂ n m₁ < mixHeadMass w a b n m₁ :=
    headMass_lt_mixHeadMass_of_match hw0 hw1 hab hm₁ h₁₂ h₂n h₂
  rw [h₁] at hmono
  linarith

/-- **Diagnostic.**  Two distinct head windows can never report the *same* implied
exponent for a genuine bulk × edge mixture; equal implied exponents therefore certify
that the kernel is not such a mixture. -/
theorem no_mixture_matches_two_windows_with_equal_exponent {w a b c : ℝ} (hw0 : 0 < w)
    (hw1 : w < 1) (hab : a < b) {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n) :
    ¬ (headMass c n m₁ = mixHeadMass w a b n m₁ ∧
        headMass c n m₂ = mixHeadMass w a b n m₂) := by
  rintro ⟨h₁, h₂⟩
  exact absurd (implied_exponent_strictAnti hw0 hw1 hab hm₁ h₁₂ h₂n h₁ h₂) (lt_irrefl c)

/-- **Capstone.**  For the recorded harmonic-bulk / quadratic-edge kernel and any two
nested head windows, both windows report implied exponents strictly inside `(1, 2)`, and
the narrower window's exponent is *strictly* steeper. -/
theorem harmonic_edge_mixture_window_exponents_strictAnti {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁)
    (h₁₂ : m₁ < m₂) (h₂n : m₂ < n) :
    ∃ c₁ ∈ Set.Ioo (1:ℝ) 2, ∃ c₂ ∈ Set.Ioo (1:ℝ) 2,
      headMass c₁ n m₁ = mixHeadMass (54/127) 1 2 n m₁ ∧
      headMass c₂ n m₂ = mixHeadMass (54/127) 1 2 n m₂ ∧ c₂ < c₁ := by
  obtain ⟨c₁, hc₁, h₁⟩ := harmonic_edge_mixture_window_exponent (n := n) hm₁ (by omega)
  obtain ⟨c₂, hc₂, h₂⟩ := harmonic_edge_mixture_window_exponent (by omega : 1 ≤ m₂) h₂n
  exact ⟨c₁, hc₁, c₂, hc₂, h₁, h₂,
    implied_exponent_strictAnti (by norm_num) (by norm_num) (by norm_num) hm₁ h₁₂ h₂n h₁ h₂⟩

end HarmonicBulkSteeperEdge