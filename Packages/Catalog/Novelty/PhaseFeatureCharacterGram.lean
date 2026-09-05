import Novelty.PhaseFeatureLiftCeiling

/-!
# The arithmetic Gram matrix of root-position phase features (paper 150, exp 482)

## Research context

`Novelty.PhaseFeatureLiftCeiling` proves a purely statistical ceiling: a feature block whose
Gram matrix is near-diagonal and whose residual correlations are at most `ε` cannot lift `R²`
by more than `K ε² / (1 - δ(K-1))`.  That theorem is only useful if the two inputs — the
near-diagonality `δ` and the block structure — are actually *true* for the phase design used in
experiment 482.  This file proves them, from character theory.

The design of exp 482 attaches to a root position `r` the features

* `cos(2π k r / N)` and `sin(2π k r / N)`, here the real and imaginary parts of the standard
  additive character `ψ(kr)` of `ZMod N` (`phaseCos`, `phaseSin`),
* the quadratic-residue indicator `(r/p)` (`qrFeat`, the quadratic character of `ZMod p`).

## Main results

* `dot_phaseCos_phaseCos`, `dot_phaseSin_phaseSin`, `dot_phaseCos_phaseSin` — the **exact** Gram
  entries of the trigonometric part over a full period: `⟪cos_k, cos_l⟫` is `N/2` when
  `k = ±l ≠ 0`, and `0` otherwise, while `⟪cos_k, sin_l⟫ = 0` for *all* `k, l`.  The
  trigonometric part of the design is therefore an exactly orthogonal basis: `δ = 0` there.
* `sqnorm_phaseCos`, `sqnorm_phaseSin` — the diagonal `N/2`.
* `cross_prime_orthogonality` — the block structure: for distinct odd primes `p, q` the
  frequency-`q` phase (which is `p`-periodic) and the frequency-`p` phase (which is
  `q`-periodic) are *exactly* orthogonal over `ZMod (pq)`.  This is the CRT hypothesis of
  `gain_le_sum_block_gains`.
* `sqnorm_qrFeat` — the quadratic-residue feature has energy exactly `p - 1`.
* `norm_gaussSum_sq` — the Gauss-sum modulus `|g|² = p`, from `gaussSum_sq`.
* `dot_qrFeat_phaseCos_eq`, `abs_dot_qrFeat_phaseCos_le`, `abs_dot_qrFeat_phaseSin_le` — hence
  the only nonzero off-diagonal couplings of the block, those between the QR indicator and the
  phases, are bounded by `√p` in absolute value.
* `qr_phase_gram_bound` — normalised: the correlation between the QR indicator and any nonzero
  frequency phase is at most `√(2/(p-1))`; the arithmetic reason the design is near-orthogonal,
  and the reason the coupling *decays* with the prime.
* `gaussSum_re_eq_zero_of_mod_four_eq_three`, `gaussSum_im_eq_zero_of_mod_four_eq_one`,
  `dot_qrFeat_phaseCos_eq_zero_of_mod_four_eq_three`,
  `dot_qrFeat_phaseSin_eq_zero_of_mod_four_eq_one` — **the Gauss-sign dichotomy**: the QR/phase
  coupling lives entirely in one trigonometric channel, the sine when `p ≡ 3 mod 4` and the
  cosine when `p ≡ 1 mod 4`.  So each prime block has *one* nonzero off-diagonal entry, not two:
  half of the phase design is exactly orthogonal to the QR indicator, for arithmetic reasons.
* `phase_block_gram_offdiag` — the `3`-feature block `(cos_k, sin_k, QR)` has all off-diagonal
  correlations at most `0.41` once `p ≥ 13`.
* `phase_block_lift_ceiling` — **the capstone**: for `p ≥ 13` and any residual with per-feature
  correlation at most `ε`, no linear combination of the prime-`p` phase block lifts more than
  `3ε²/0.18` of the residual energy.  With the nine primes of exp 482 and `ε = 0.01` this is
  `0.015`, matching `subthreshold_certificate` in the companion file and the measured
  `+0.008 / +0.004`.

## Lab notes

```
Gram entries over a full period (N = modulus, k,l ≠ 0, k ≠ ±l)
  ⟪cos_k, cos_l⟫ = 0        ⟪cos_k, cos_k⟫ = N/2
  ⟪sin_k, sin_l⟫ = 0        ⟪sin_k, sin_k⟫ = N/2
  ⟪cos_k, sin_l⟫ = 0        (all k, l)
  ⟪QR, cos_k⟫  ≤ √p        ‖QR‖² = p - 1
  correlation(QR, cos_k) ≤ √(2/(p-1)):   p = 13 → 0.408, p = 29 → 0.267
```
-/

open Finset Complex
open Catalog.Novelty.PhaseFeatureLiftCeiling

namespace Catalog.Novelty.PhaseFeatureCharacterGram

/-! ## 1. The phase features and the character sum -/

section Phases

variable {N : ℕ} [NeZero N]

/-- The cosine phase feature at frequency `k`: the real part of `ψ(k r)`, i.e.
`cos(2π k r / N)`. -/
noncomputable def phaseCos (k r : ZMod N) : ℝ := (ZMod.stdAddChar (k * r)).re

/-- The sine phase feature at frequency `k`: `sin(2π k r / N)`. -/
noncomputable def phaseSin (k r : ZMod N) : ℝ := (ZMod.stdAddChar (k * r)).im

/-- Conjugation reverses the character. -/
lemma conj_stdAddChar (x : ZMod N) :
    (starRingEnd ℂ) (ZMod.stdAddChar x) = ZMod.stdAddChar (-x) := by
  have h1 : ‖ZMod.stdAddChar x‖ = 1 := by simp [ZMod.stdAddChar_apply]
  rw [← Complex.inv_eq_conj h1, ← AddChar.map_neg_eq_inv]

/-- The complete character sum: `Σ_r ψ(t r) = N` if `t = 0` and `0` otherwise. -/
lemma sum_stdAddChar_mul (t : ZMod N) :
    ∑ r : ZMod N, ZMod.stdAddChar (t * r) = if t = 0 then (N : ℂ) else 0 := by
  by_cases ht : t = 0
  · subst ht; simp [ZMod.card]
  · rw [if_neg ht]
    simpa [AddChar.mulShift_apply] using
      AddChar.sum_eq_zero_of_ne_one (ZMod.isPrimitive_stdAddChar N (a := t) ht)

/-- **Cosine Gram entries.** -/
theorem dot_phaseCos_phaseCos (k l : ZMod N) :
    dot (phaseCos k) (phaseCos l)
      = ((if k - l = 0 then (N : ℝ) else 0) + (if k + l = 0 then (N : ℝ) else 0)) / 2 := by
  have hre : ∀ r : ZMod N, phaseCos k r * phaseCos l r
      = ((ZMod.stdAddChar ((k - l) * r) + ZMod.stdAddChar ((k + l) * r)) / 2).re := by
    intro r
    have e1 : ZMod.stdAddChar ((k - l) * r)
        = ZMod.stdAddChar (k * r) * (starRingEnd ℂ) (ZMod.stdAddChar (l * r)) := by
      rw [conj_stdAddChar, ← AddChar.map_add_eq_mul]; congr 1; ring
    have e2 : ZMod.stdAddChar ((k + l) * r)
        = ZMod.stdAddChar (k * r) * ZMod.stdAddChar (l * r) := by
      rw [← AddChar.map_add_eq_mul]; congr 1; ring
    rw [e1, e2]
    simp [phaseCos, Complex.add_re, Complex.mul_re]
  rw [dot, Finset.sum_congr rfl (fun r _ => hre r), ← Complex.re_sum,
    ← Finset.sum_div, Finset.sum_add_distrib, sum_stdAddChar_mul, sum_stdAddChar_mul]
  by_cases h1 : k - l = 0 <;> by_cases h2 : k + l = 0 <;> simp [h1, h2]

/-- **Sine Gram entries.** -/
theorem dot_phaseSin_phaseSin (k l : ZMod N) :
    dot (phaseSin k) (phaseSin l)
      = ((if k - l = 0 then (N : ℝ) else 0) - (if k + l = 0 then (N : ℝ) else 0)) / 2 := by
  have hre : ∀ r : ZMod N, phaseSin k r * phaseSin l r
      = ((ZMod.stdAddChar ((k - l) * r) - ZMod.stdAddChar ((k + l) * r)) / 2).re := by
    intro r
    have e1 : ZMod.stdAddChar ((k - l) * r)
        = ZMod.stdAddChar (k * r) * (starRingEnd ℂ) (ZMod.stdAddChar (l * r)) := by
      rw [conj_stdAddChar, ← AddChar.map_add_eq_mul]; congr 1; ring
    have e2 : ZMod.stdAddChar ((k + l) * r)
        = ZMod.stdAddChar (k * r) * ZMod.stdAddChar (l * r) := by
      rw [← AddChar.map_add_eq_mul]; congr 1; ring
    rw [e1, e2]
    simp [phaseSin, Complex.sub_re, Complex.mul_re]
  rw [dot, Finset.sum_congr rfl (fun r _ => hre r), ← Complex.re_sum,
    ← Finset.sum_div, Finset.sum_sub_distrib, sum_stdAddChar_mul, sum_stdAddChar_mul]
  by_cases h1 : k - l = 0 <;> by_cases h2 : k + l = 0 <;> simp [h1, h2]

/-- **Cosines and sines are exactly orthogonal**, at every pair of frequencies. -/
theorem dot_phaseCos_phaseSin (k l : ZMod N) : dot (phaseCos k) (phaseSin l) = 0 := by
  have hre : ∀ r : ZMod N, phaseCos k r * phaseSin l r
      = ((ZMod.stdAddChar ((k + l) * r) - ZMod.stdAddChar ((k - l) * r)) / 2).im := by
    intro r
    have e1 : ZMod.stdAddChar ((k - l) * r)
        = ZMod.stdAddChar (k * r) * (starRingEnd ℂ) (ZMod.stdAddChar (l * r)) := by
      rw [conj_stdAddChar, ← AddChar.map_add_eq_mul]; congr 1; ring
    have e2 : ZMod.stdAddChar ((k + l) * r)
        = ZMod.stdAddChar (k * r) * ZMod.stdAddChar (l * r) := by
      rw [← AddChar.map_add_eq_mul]; congr 1; ring
    rw [e1, e2]
    simp [phaseCos, phaseSin, Complex.sub_im, Complex.mul_im]
  rw [dot, Finset.sum_congr rfl (fun r _ => hre r), ← Complex.im_sum,
    ← Finset.sum_div, Finset.sum_sub_distrib, sum_stdAddChar_mul, sum_stdAddChar_mul]
  by_cases h1 : k - l = 0 <;> by_cases h2 : k + l = 0 <;> simp [h1, h2]

/-- The energy of a nonzero-frequency cosine feature is exactly `N/2`. -/
theorem sqnorm_phaseCos (k : ZMod N) (hk : k + k ≠ 0) :
    sqnorm (phaseCos k) = (N : ℝ) / 2 := by
  have h := dot_phaseCos_phaseCos k k
  rw [sub_self] at h
  rw [sqnorm, h, if_pos rfl, if_neg hk]
  ring

/-- The energy of a nonzero-frequency sine feature is exactly `N/2`. -/
theorem sqnorm_phaseSin (k : ZMod N) (hk : k + k ≠ 0) :
    sqnorm (phaseSin k) = (N : ℝ) / 2 := by
  have h := dot_phaseSin_phaseSin k k
  rw [sub_self] at h
  rw [sqnorm, h, if_pos rfl, if_neg hk]
  ring

/-- Distinct, non-opposite frequencies give exactly orthogonal cosine features. -/
theorem dot_phaseCos_phaseCos_eq_zero (k l : ZMod N) (h1 : k - l ≠ 0) (h2 : k + l ≠ 0) :
    dot (phaseCos k) (phaseCos l) = 0 := by
  rw [dot_phaseCos_phaseCos, if_neg h1, if_neg h2]; ring

/-- Distinct, non-opposite frequencies give exactly orthogonal sine features. -/
theorem dot_phaseSin_phaseSin_eq_zero (k l : ZMod N) (h1 : k - l ≠ 0) (h2 : k + l ≠ 0) :
    dot (phaseSin k) (phaseSin l) = 0 := by
  rw [dot_phaseSin_phaseSin, if_neg h1, if_neg h2]; ring

end Phases

/-! ## 2. Cross-prime block structure (the CRT hypothesis) -/

section CRT

/-- **Cross-prime orthogonality.**  Over `ZMod (p q)` the phase at frequency `q` (a `p`-periodic
signal) and the phase at frequency `p` (a `q`-periodic signal) are exactly orthogonal: the
per-prime feature blocks of exp 482 form an orthogonal decomposition, which is exactly the
hypothesis of the block-additivity ceiling. -/
theorem cross_prime_orthogonality {p q : ℕ} [NeZero (p * q)] (hp : 3 ≤ p) (hq : 3 ≤ q)
    (hpq : p ≠ q) :
    dot (phaseCos ((q : ZMod (p * q)))) (phaseCos ((p : ZMod (p * q)))) = 0 := by
  have hp0 : 0 < p := by omega
  have hq0 : 0 < q := by omega
  have hlt : p + q < p * q := by nlinarith
  have hqlt : q < p * q := by nlinarith
  have hplt : p < p * q := by nlinarith
  have hsum : ((q : ZMod (p * q))) + ((p : ZMod (p * q))) ≠ 0 := by
    intro h
    have hc : ((q + p : ℕ) : ZMod (p * q)) = 0 := by push_cast; exact h
    have hd := (ZMod.natCast_eq_zero_iff (q + p) (p * q)).mp hc
    have hle := Nat.le_of_dvd (by omega) hd
    omega
  have hdiff : ((q : ZMod (p * q))) - ((p : ZMod (p * q))) ≠ 0 := by
    intro h
    rw [sub_eq_zero] at h
    have h2 : q % (p * q) = p % (p * q) := (ZMod.natCast_eq_natCast_iff q p (p * q)).mp h
    rw [Nat.mod_eq_of_lt hqlt, Nat.mod_eq_of_lt hplt] at h2
    exact hpq h2.symm
  exact dot_phaseCos_phaseCos_eq_zero _ _ hdiff hsum

end CRT

/-! ## 3. The quadratic-residue feature and the Gauss-sum coupling -/

section QR

variable {p : ℕ} [Fact p.Prime]

instance : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩

/-- The quadratic-residue indicator feature `r ↦ (r/p)`. -/
noncomputable def qrFeat (r : ZMod p) : ℝ := ((quadraticChar (ZMod p) r : ℤ) : ℝ)

/-- The quadratic character with complex values, used for the Gauss sum. -/
noncomputable def chiC (p : ℕ) [Fact p.Prime] : MulChar (ZMod p) ℂ :=
  (quadraticChar (ZMod p)).ringHomComp (Int.castRingHom ℂ)

lemma chiC_apply (r : ZMod p) : chiC p r = ((quadraticChar (ZMod p) r : ℤ) : ℂ) := rfl

/-- The quadratic-residue feature has energy exactly `p - 1`. -/
theorem sqnorm_qrFeat : sqnorm (qrFeat (p := p)) = (p : ℝ) - 1 := by
  have hval : ∀ r : ZMod p, qrFeat r * qrFeat r = 1 - (if r = 0 then (1 : ℝ) else 0) := by
    intro r
    by_cases hr : r = 0
    · subst hr; simp [qrFeat]
    · have h1 : (quadraticChar (ZMod p) r) ^ 2 = 1 := quadraticChar_sq_one hr
      have : qrFeat r * qrFeat r = (((quadraticChar (ZMod p) r ^ 2 : ℤ)) : ℝ) := by
        rw [qrFeat]; push_cast; ring
      rw [this, h1, if_neg hr]
      norm_num
  rw [sqnorm, dot, Finset.sum_congr rfl (fun r _ => hval r), Finset.sum_sub_distrib,
    Finset.sum_const, Finset.sum_ite_eq' univ (0 : ZMod p) (fun _ => (1 : ℝ))]
  simp [ZMod.card]

/-- The complex quadratic character is nontrivial. -/
lemma chiC_ne_one (hp : p ≠ 2) : chiC p ≠ 1 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by rw [ZMod.ringChar_zmod_n]; exact hp
  obtain ⟨a, ha⟩ := quadraticChar_exists_neg_one (F := ZMod p) hchar
  have ha0 : a ≠ 0 := by
    intro h0; rw [h0, quadraticChar_zero] at ha; norm_num at ha
  intro h
  have h1 : chiC p a = -1 := by rw [chiC_apply, ha]; norm_num
  have h2 : chiC p a = 1 := by
    rw [h]; exact MulChar.one_apply (isUnit_iff_ne_zero.mpr ha0)
  rw [h1] at h2
  norm_num at h2

/-- Shifting the standard character by a nonzero frequency keeps it primitive. -/
lemma mulShift_isPrimitive (k : ZMod p) (hk : k ≠ 0) :
    (ZMod.stdAddChar.mulShift k : AddChar (ZMod p) ℂ).IsPrimitive := by
  intro a ha
  rw [AddChar.mulShift_mulShift]
  exact ZMod.isPrimitive_stdAddChar p (a := k * a) (mul_ne_zero hk ha)

/-- The quadratic Gauss sum squares to `χ(-1) p`. -/
theorem gaussSum_sq_eq_chi_mul (hp : p ≠ 2) (k : ZMod p) (hk : k ≠ 0) :
    gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) ^ 2 = chiC p (-1) * (p : ℂ) := by
  have hq : (chiC p).IsQuadratic := (quadraticChar_isQuadratic (ZMod p)).comp _
  have hsq := gaussSum_sq (chiC_ne_one hp) hq (mulShift_isPrimitive k hk)
  rwa [show (Fintype.card (ZMod p) : ℂ) = (p : ℂ) by simp [ZMod.card]] at hsq

/-- `χ(-1) ≠ 0`. -/
lemma chiC_neg_one_ne_zero : chiC p (-1) ≠ 0 := by
  have hm1 : (-1 : ZMod p) ≠ 0 := neg_ne_zero.mpr one_ne_zero
  intro h
  have h0 : quadraticChar (ZMod p) (-1) = 0 := by
    have : ((quadraticChar (ZMod p) (-1) : ℤ) : ℂ) = 0 := by rw [← chiC_apply]; exact h
    exact_mod_cast this
  exact hm1 (quadraticChar_eq_zero_iff.mp h0)

/-- `|g|² = p` for the quadratic Gauss sum at any nonzero frequency. -/
theorem norm_gaussSum_sq (hp : p ≠ 2) (k : ZMod p) (hk : k ≠ 0) :
    ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)‖ ^ 2 = (p : ℝ) := by
  have hq : (chiC p).IsQuadratic := (quadraticChar_isQuadratic (ZMod p)).comp _
  have hnorm : ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) ^ 2‖ = (p : ℝ) := by
    rw [gaussSum_sq_eq_chi_mul hp k hk]
    rcases hq (-1) with h | h | h
    · exact absurd h chiC_neg_one_ne_zero
    · rw [h]; simp
    · rw [h]; simp
  rwa [norm_pow] at hnorm

/-- For `p ≡ 3 mod 4` the quadratic character sends `-1` to `-1`. -/
lemma chiC_neg_one_of_mod_four_eq_three (h3 : p % 4 = 3) : chiC p (-1) = -1 := by
  have hcard : Fintype.card (ZMod p) % 4 = 3 := by rw [ZMod.card]; exact h3
  have hns : ¬ IsSquare (-1 : ZMod p) := by
    intro hsq
    exact (FiniteField.isSquare_neg_one_iff.mp hsq) hcard
  have := quadraticChar_neg_one_iff_not_isSquare.mpr hns
  rw [chiC_apply, this]
  norm_num

/-- For `p ≡ 1 mod 4` the quadratic character sends `-1` to `1`. -/
lemma chiC_neg_one_of_mod_four_eq_one (h1 : p % 4 = 1) : chiC p (-1) = 1 := by
  have hcard : Fintype.card (ZMod p) % 4 ≠ 3 := by rw [ZMod.card]; omega
  have hsq : IsSquare (-1 : ZMod p) := FiniteField.isSquare_neg_one_iff.mpr hcard
  have hm1 : (-1 : ZMod p) ≠ 0 := neg_ne_zero.mpr one_ne_zero
  have := (quadraticChar_one_iff_isSquare hm1).mpr hsq
  rw [chiC_apply, this]
  norm_num

/-- **Gauss-sign dichotomy, part I.**  For `p ≡ 3 mod 4` the Gauss sum is purely imaginary. -/
theorem gaussSum_re_eq_zero_of_mod_four_eq_three (hp : p ≠ 2) (h3 : p % 4 = 3)
    (k : ZMod p) (hk : k ≠ 0) :
    (gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).re = 0 := by
  set g := gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) with hgdef
  have hsq : g ^ 2 = -(p : ℂ) := by
    rw [hgdef, gaussSum_sq_eq_chi_mul hp k hk, chiC_neg_one_of_mod_four_eq_three h3]
    ring
  have hp0 : (0 : ℝ) < p := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  have hre : g.re ^ 2 - g.im ^ 2 = -(p : ℝ) := by
    have := congrArg Complex.re hsq
    simpa [pow_two, Complex.mul_re, Complex.neg_re] using this
  have him : 2 * (g.re * g.im) = 0 := by
    have := congrArg Complex.im hsq
    simp [pow_two, Complex.mul_im, Complex.neg_im] at this
    linarith
  rcases mul_eq_zero.mp (by linarith : g.re * g.im = 0) with h | h
  · exact h
  · exfalso; rw [h] at hre; nlinarith [sq_nonneg g.re]

/-- **Gauss-sign dichotomy, part II.**  For `p ≡ 1 mod 4` the Gauss sum is real. -/
theorem gaussSum_im_eq_zero_of_mod_four_eq_one (hp : p ≠ 2) (h1 : p % 4 = 1)
    (k : ZMod p) (hk : k ≠ 0) :
    (gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).im = 0 := by
  set g := gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) with hgdef
  have hsq : g ^ 2 = (p : ℂ) := by
    rw [hgdef, gaussSum_sq_eq_chi_mul hp k hk, chiC_neg_one_of_mod_four_eq_one h1]
    ring
  have hp0 : (0 : ℝ) < p := by
    have := (Fact.out : p.Prime).pos
    exact_mod_cast this
  have hre : g.re ^ 2 - g.im ^ 2 = (p : ℝ) := by
    have := congrArg Complex.re hsq
    simpa [pow_two, Complex.mul_re] using this
  have him : 2 * (g.re * g.im) = 0 := by
    have := congrArg Complex.im hsq
    simp [pow_two, Complex.mul_im] at this
    linarith
  rcases mul_eq_zero.mp (by linarith : g.re * g.im = 0) with h | h
  · exfalso; rw [h] at hre; nlinarith [sq_nonneg g.im]
  · exact h

/-- The QR/phase coupling is the real part of a Gauss sum. -/
theorem dot_qrFeat_phaseCos_eq (k : ZMod p) :
    dot (qrFeat (p := p)) (phaseCos k)
      = (gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).re := by
  rw [gaussSum, Complex.re_sum, dot]
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [chiC_apply, AddChar.mulShift_apply, phaseCos, Complex.mul_re]
  simp [qrFeat]

/-- The QR/phase coupling with the sine feature is (minus) the imaginary part. -/
theorem dot_qrFeat_phaseSin_eq (k : ZMod p) :
    dot (qrFeat (p := p)) (phaseSin k)
      = (gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).im := by
  rw [gaussSum, Complex.im_sum, dot]
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [chiC_apply, AddChar.mulShift_apply, phaseSin, Complex.mul_im]
  simp [qrFeat]

/-- **The Gauss-sum bound.**  The QR indicator couples to a nonzero-frequency phase by at most
`√p` — the only source of non-orthogonality in the block. -/
theorem abs_dot_qrFeat_phaseCos_le (hp : p ≠ 2) (k : ZMod p) (hk : k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseCos k)| ≤ Real.sqrt p := by
  rw [dot_qrFeat_phaseCos_eq]
  have h1 : |(gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).re|
      ≤ ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)‖ := Complex.abs_re_le_norm _
  have h2 : ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)‖ = Real.sqrt p := by
    have := norm_gaussSum_sq hp k hk
    rw [← this, Real.sqrt_sq (norm_nonneg _)]
  rwa [h2] at h1

/-- The sine version of the Gauss-sum bound. -/
theorem abs_dot_qrFeat_phaseSin_le (hp : p ≠ 2) (k : ZMod p) (hk : k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseSin k)| ≤ Real.sqrt p := by
  rw [dot_qrFeat_phaseSin_eq]
  have h1 : |(gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)).im|
      ≤ ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)‖ := Complex.abs_im_le_norm _
  have h2 : ‖gaussSum (chiC p) (ZMod.stdAddChar.mulShift k)‖ = Real.sqrt p := by
    have := norm_gaussSum_sq hp k hk
    rw [← this, Real.sqrt_sq (norm_nonneg _)]
  rwa [h2] at h1

/-- **The coupling lives in one trigonometric channel.**  For `p ≡ 3 mod 4` the
quadratic-residue indicator is *exactly* orthogonal to every cosine phase: the whole Gauss-sum
coupling is carried by the sine channel. -/
theorem dot_qrFeat_phaseCos_eq_zero_of_mod_four_eq_three (hp : p ≠ 2) (h3 : p % 4 = 3)
    (k : ZMod p) (hk : k ≠ 0) : dot (qrFeat (p := p)) (phaseCos k) = 0 := by
  rw [dot_qrFeat_phaseCos_eq]
  exact gaussSum_re_eq_zero_of_mod_four_eq_three hp h3 k hk

/-- For `p ≡ 1 mod 4` the coupling is carried entirely by the cosine channel: the
quadratic-residue indicator is exactly orthogonal to every sine phase. -/
theorem dot_qrFeat_phaseSin_eq_zero_of_mod_four_eq_one (hp : p ≠ 2) (h1 : p % 4 = 1)
    (k : ZMod p) (hk : k ≠ 0) : dot (qrFeat (p := p)) (phaseSin k) = 0 := by
  rw [dot_qrFeat_phaseSin_eq]
  exact gaussSum_im_eq_zero_of_mod_four_eq_one hp h1 k hk

/-- **Normalised Gauss-sum Gram bound.**  The correlation between the quadratic-residue
indicator and a nonzero-frequency phase is at most `√(2/(p-1))`: near-orthogonality of the
phase design is an arithmetic theorem, and the coupling decays like `p^{-1/2}`. -/
theorem qr_phase_gram_bound (hp : p ≠ 2) (hp3 : 3 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseCos k)|
      ≤ Real.sqrt (2 / ((p : ℝ) - 1))
        * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k))) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  have hnum : Real.sqrt (2 / ((p : ℝ) - 1))
      * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k)))
      = Real.sqrt p := by
    have hpm : (0 : ℝ) < (p : ℝ) - 1 := by linarith
    rw [sqnorm_qrFeat, sqnorm_phaseCos k hk2, ← Real.sqrt_mul hpm.le,
      ← Real.sqrt_mul (div_pos two_pos hpm).le]
    congr 1
    field_simp
  rw [hnum]
  exact abs_dot_qrFeat_phaseCos_le hp k hk

/-- The sine version. -/
theorem qr_phaseSin_gram_bound (hp : p ≠ 2) (hp3 : 3 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseSin k)|
      ≤ Real.sqrt (2 / ((p : ℝ) - 1))
        * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k))) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  have hnum : Real.sqrt (2 / ((p : ℝ) - 1))
      * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k)))
      = Real.sqrt p := by
    have hpm : (0 : ℝ) < (p : ℝ) - 1 := by linarith
    rw [sqnorm_qrFeat, sqnorm_phaseSin k hk2, ← Real.sqrt_mul hpm.le,
      ← Real.sqrt_mul (div_pos two_pos hpm).le]
    congr 1
    field_simp
  rw [hnum]
  exact abs_dot_qrFeat_phaseSin_le hp k hk

end QR

/-! ## 4. The three-feature prime block and its lift ceiling -/

section Block

variable {p : ℕ} [Fact p.Prime]

/-- The prime-`p` phase block of exp 482: cosine, sine and the quadratic-residue indicator. -/
noncomputable def phaseBlock (k : ZMod p) : Fin 3 → (ZMod p → ℝ)
  | 0 => phaseCos k
  | 1 => phaseSin k
  | 2 => qrFeat

@[simp] lemma phaseBlock_zero (k : ZMod p) : phaseBlock k 0 = phaseCos k := rfl
@[simp] lemma phaseBlock_one (k : ZMod p) : phaseBlock k 1 = phaseSin k := rfl
@[simp] lemma phaseBlock_two (k : ZMod p) : phaseBlock k 2 = qrFeat := rfl

lemma sqnorm_phaseBlock_pos (hp3 : 3 ≤ p) (k : ZMod p) (hk2 : k + k ≠ 0) :
    ∀ j, 0 < sqnorm (phaseBlock k j) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  intro j
  fin_cases j
  · show 0 < sqnorm (phaseCos k)
    rw [sqnorm_phaseCos k hk2]; linarith
  · show 0 < sqnorm (phaseSin k)
    rw [sqnorm_phaseSin k hk2]; linarith
  · show 0 < sqnorm (qrFeat (p := p))
    rw [sqnorm_qrFeat]; linarith

/-- **The block Gram bound.**  For `p ≥ 13` every off-diagonal correlation of the three-feature
prime block is at most `0.41`: the cosine/sine pair is *exactly* orthogonal and the two
QR couplings obey the Gauss-sum bound `√(2/(p-1)) ≤ √(2/12) < 0.41`. -/
theorem phase_block_gram_offdiag (hp : p ≠ 2) (hp13 : 13 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    ∀ j l, j ≠ l → |dot (phaseBlock k j) (phaseBlock k l)|
      ≤ (0.41 : ℝ)
        * (Real.sqrt (sqnorm (phaseBlock k j)) * Real.sqrt (sqnorm (phaseBlock k l))) := by
  have hp3 : 3 ≤ p := by omega
  have hp1 : (13 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp13
  have hdelta : Real.sqrt (2 / ((p : ℝ) - 1)) ≤ 0.41 := by
    have h1 : 2 / ((p : ℝ) - 1) ≤ 2 / 12 :=
      div_le_div_of_nonneg_left (by norm_num) (by linarith) (by linarith)
    calc Real.sqrt (2 / ((p : ℝ) - 1)) ≤ Real.sqrt (2 / 12) := Real.sqrt_le_sqrt h1
      _ ≤ 0.41 := by
          rw [show (0.41 : ℝ) = Real.sqrt (0.41 ^ 2) by rw [Real.sqrt_sq]; norm_num]
          exact Real.sqrt_le_sqrt (by norm_num)
  -- the exactly orthogonal pair
  have hCS : |dot (phaseCos k) (phaseSin k)|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseCos k)) * Real.sqrt (sqnorm (phaseSin k))) := by
    rw [dot_phaseCos_phaseSin, abs_zero]; positivity
  have hSC : |dot (phaseSin k) (phaseCos k)|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseSin k)) * Real.sqrt (sqnorm (phaseCos k))) := by
    have h0 : dot (phaseSin k) (phaseCos k) = 0 := by
      rw [dot_comm]; exact dot_phaseCos_phaseSin k k
    rw [h0, abs_zero]; positivity
  -- the two Gauss-sum couplings
  have hQC : |dot (qrFeat (p := p)) (phaseCos k)|
      ≤ 0.41 * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k))) := by
    refine le_trans (qr_phase_gram_bound hp hp3 k hk hk2) ?_
    exact mul_le_mul_of_nonneg_right hdelta (by positivity)
  have hQS : |dot (qrFeat (p := p)) (phaseSin k)|
      ≤ 0.41 * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k))) := by
    refine le_trans (qr_phaseSin_gram_bound hp hp3 k hk hk2) ?_
    exact mul_le_mul_of_nonneg_right hdelta (by positivity)
  have hCQ : |dot (phaseCos k) (qrFeat (p := p))|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseCos k)) * Real.sqrt (sqnorm (qrFeat (p := p)))) := by
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseCos k)))]
    exact hQC
  have hSQ : |dot (phaseSin k) (qrFeat (p := p))|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseSin k)) * Real.sqrt (sqnorm (qrFeat (p := p)))) := by
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseSin k)))]
    exact hQS
  intro j l hjl
  fin_cases j <;> fin_cases l <;>
    first
      | exact absurd rfl hjl
      | exact hCS
      | exact hSC
      | exact hCQ
      | exact hSQ
      | exact hQC
      | exact hQS

/-- **Capstone: the prime block cannot lift more than `3ε²/0.18`.**  For `p ≥ 13`, whatever
linear combination of `(cos_k, sin_k, QR)` is fitted, its `R²` lift over the baseline is at most
`3ε²/0.18` of the residual energy, where `ε` bounds the individual residual correlations.  With
`ε = 0.01` and the nine primes of exp 482 the total is `0.015`. -/
theorem phase_block_lift_ceiling (hp : p ≠ 2) (hp13 : 13 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) (e : ZMod p → ℝ) (ε : ℝ)
    (hcorr : ∀ j, (dot e (phaseBlock k j)) ^ 2
      ≤ ε ^ 2 * (sqnorm e * sqnorm (phaseBlock k j)))
    (a : Fin 3 → ℝ) :
    gain e (combo a (phaseBlock k)) ≤ ((3 : ℝ) * ε ^ 2 / 0.18) * sqnorm e := by
  have hp3 : 3 ≤ p := by omega
  have hcard : (Fintype.card (Fin 3) : ℝ) = 3 := by simp
  have h := span_gain_le_of_gram e (phaseBlock k) ε 0.41 (by norm_num)
    (sqnorm_phaseBlock_pos hp3 k hk2) hcorr
    (phase_block_gram_offdiag hp hp13 k hk hk2) (by rw [hcard]; norm_num) a
  rw [hcard] at h
  norm_num at h ⊢
  convert h using 3

end Block

end Catalog.Novelty.PhaseFeatureCharacterGram