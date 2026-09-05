import Novelty.PhaseFeatureCharacterGram

/-!
# The sharp prime-block ceiling from the Gauss-sign dichotomy (paper 150, third cycle)

## Research context

`Novelty.PhaseFeatureCharacterGram` bounds the lift of a prime-`p` phase block by `3ε²/0.18`,
using the crude diagonal-dominance constant `1 - δ(K-1) = 1 - 2δ`.  That constant assumed *both*
off-diagonal couplings of the block are as large as the Gauss-sum bound allows.  The Gauss-sign
dichotomy proved in the same file says they are not: the quadratic-residue indicator is
*exactly* orthogonal to one of the two trigonometric channels, the cosine when `p ≡ 3 (mod 4)`
and the sine when `p ≡ 1 (mod 4)`.

This file exploits that.  With a single coupled pair the restricted-isometry constant is
`1 - δ` rather than `1 - 2δ` — the arithmetic-mean/geometric-mean bound `2xy ≤ x² + y²` replaces
the Cauchy–Schwarz pile-up — and the block ceiling improves by a factor `0.59/0.18 ≈ 3.3`.

## Main results

* `stability_three_single_coupling`, `stability_three_single_coupling_alt` — a three-feature
  design with only one coupled pair is a restricted isometry with the sharp constant `1 - δ`.
* `phase_block_stability_three_mod_four`, `phase_block_stability_one_mod_four` — the prime block
  satisfies that hypothesis, with the coupled pair determined by `p mod 4`.
* `phase_block_lift_ceiling_sharp` — **the sharp ceiling**: for every odd prime `p ≥ 13` the
  prime-`p` phase block lifts at most `3ε²/0.59` of the residual energy, whichever residue class
  mod `4` the prime lies in.
* `sharp_subthreshold_certificate`, `sharp_H3_unreachable` — the numeric consequences: the nine
  blocks of exp 482 are capped at `0.005` (down from `0.016`), so the best achievable
  phase-augmented score from the `0.600` footprint dial is `0.602`, against the registered `H3`
  bar of `0.70`.

## Lab notes (third cycle)

```
constant                     value        ceiling for 9 blocks at ε = 0.01
crude   1 - 2δ (δ = 0.41)     0.18                 0.0150
sharp   1 - δ  (δ = 0.41)     0.59                 0.0046
improvement factor            3.28
best phase-augmented score from 0.600 :  0.6018  <  0.70  (H3 refuted with margin)
```
-/

open Finset
open Catalog.Novelty.PhaseFeatureLiftCeiling
open Catalog.Novelty.PhaseFeatureCharacterGram

namespace Catalog.Novelty.PhaseFeatureSharpBlock

/-! ## 1. A three-feature design with a single coupled pair -/

section Stability

variable {ι : Type*} [Fintype ι]

/-- **Sharp restricted isometry, coupled pair `(1,2)`.**  If feature `0` is exactly orthogonal
to the other two, the design constant is `1 - δ`, not `1 - 2δ`. -/
theorem stability_three_single_coupling (f : Fin 3 → ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (h01 : dot (f 0) (f 1) = 0) (h02 : dot (f 0) (f 2) = 0)
    (h12 : |dot (f 1) (f 2)| ≤ δ * (Real.sqrt (sqnorm (f 1)) * Real.sqrt (sqnorm (f 2))))
    (a : Fin 3 → ℝ) :
    (1 - δ) * (∑ k, (a k) ^ 2 * sqnorm (f k)) ≤ sqnorm (combo a f) := by
  set s1 := Real.sqrt (sqnorm (f 1)) with hs1def
  set s2 := Real.sqrt (sqnorm (f 2)) with hs2def
  have hs1 : s1 ^ 2 = sqnorm (f 1) := Real.sq_sqrt (sqnorm_nonneg _)
  have hs2 : s2 ^ 2 = sqnorm (f 2) := Real.sq_sqrt (sqnorm_nonneg _)
  have hs1n : 0 ≤ s1 := Real.sqrt_nonneg _
  have hs2n : 0 ≤ s2 := Real.sqrt_nonneg _
  have hexp : sqnorm (combo a f)
      = (a 0) ^ 2 * sqnorm (f 0) + (a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)
        + 2 * (a 1 * a 2 * dot (f 1) (f 2)) := by
    rw [sqnorm_combo]
    simp only [Fin.sum_univ_three]
    rw [dot_comm (f 1) (f 0), dot_comm (f 2) (f 0), dot_comm (f 2) (f 1), h01, h02]
    simp only [show dot (f 0) (f 0) = sqnorm (f 0) from rfl,
      show dot (f 1) (f 1) = sqnorm (f 1) from rfl,
      show dot (f 2) (f 2) = sqnorm (f 2) from rfl]
    ring
  have hQ : (∑ k, (a k) ^ 2 * sqnorm (f k))
      = (a 0) ^ 2 * sqnorm (f 0) + (a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2) := by
    simp [Fin.sum_univ_three]
  -- the coupled term is controlled by the arithmetic-geometric mean inequality
  have habs := abs_le.mp h12
  have hAM : 2 * ((|a 1| * s1) * (|a 2| * s2)) ≤ (|a 1| * s1) ^ 2 + (|a 2| * s2) ^ 2 := by
    nlinarith [sq_nonneg (|a 1| * s1 - |a 2| * s2)]
  have hcoup : -(δ * ((a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)))
      ≤ 2 * (a 1 * a 2 * dot (f 1) (f 2)) := by
    have h1 : |2 * (a 1 * a 2 * dot (f 1) (f 2))|
        ≤ δ * ((a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)) := by
      have hstep : |2 * (a 1 * a 2 * dot (f 1) (f 2))|
          = 2 * (|a 1| * |a 2| * |dot (f 1) (f 2)|) := by
        rw [abs_mul, abs_mul, abs_mul]
        simp
      rw [hstep]
      have hb : |a 1| * |a 2| * |dot (f 1) (f 2)| ≤ |a 1| * |a 2| * (δ * (s1 * s2)) :=
        mul_le_mul_of_nonneg_left h12 (by positivity)
      have hfin : 2 * (|a 1| * |a 2| * (δ * (s1 * s2)))
          ≤ δ * ((a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)) := by
        have hrw : (a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)
            = (|a 1| * s1) ^ 2 + (|a 2| * s2) ^ 2 := by
          rw [mul_pow, mul_pow, sq_abs, sq_abs, hs1, hs2]
        rw [hrw]
        have h2 : 2 * (|a 1| * |a 2| * (δ * (s1 * s2)))
            = δ * (2 * ((|a 1| * s1) * (|a 2| * s2))) := by ring
        rw [h2]
        exact mul_le_mul_of_nonneg_left hAM hδ
      linarith
    have := abs_le.mp h1
    linarith [this.1]
  have hQ0 : 0 ≤ (a 0) ^ 2 * sqnorm (f 0) :=
    mul_nonneg (sq_nonneg _) (sqnorm_nonneg _)
  rw [hexp, hQ]
  nlinarith [hcoup, hQ0, hδ]

/-- **Sharp restricted isometry, coupled pair `(0,2)`.**  The mirror case, used when
`p ≡ 1 (mod 4)` and the sine channel is the orthogonal one. -/
theorem stability_three_single_coupling_alt (f : Fin 3 → ι → ℝ) (δ : ℝ) (hδ : 0 ≤ δ)
    (h01 : dot (f 0) (f 1) = 0) (h12 : dot (f 1) (f 2) = 0)
    (h02 : |dot (f 0) (f 2)| ≤ δ * (Real.sqrt (sqnorm (f 0)) * Real.sqrt (sqnorm (f 2))))
    (a : Fin 3 → ℝ) :
    (1 - δ) * (∑ k, (a k) ^ 2 * sqnorm (f k)) ≤ sqnorm (combo a f) := by
  set s0 := Real.sqrt (sqnorm (f 0)) with hs0def
  set s2 := Real.sqrt (sqnorm (f 2)) with hs2def
  have hs0 : s0 ^ 2 = sqnorm (f 0) := Real.sq_sqrt (sqnorm_nonneg _)
  have hs2 : s2 ^ 2 = sqnorm (f 2) := Real.sq_sqrt (sqnorm_nonneg _)
  have hs0n : 0 ≤ s0 := Real.sqrt_nonneg _
  have hs2n : 0 ≤ s2 := Real.sqrt_nonneg _
  have hexp : sqnorm (combo a f)
      = (a 0) ^ 2 * sqnorm (f 0) + (a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2)
        + 2 * (a 0 * a 2 * dot (f 0) (f 2)) := by
    rw [sqnorm_combo]
    simp only [Fin.sum_univ_three]
    rw [dot_comm (f 1) (f 0), dot_comm (f 2) (f 0), dot_comm (f 2) (f 1), h01, h12]
    simp only [show dot (f 0) (f 0) = sqnorm (f 0) from rfl,
      show dot (f 1) (f 1) = sqnorm (f 1) from rfl,
      show dot (f 2) (f 2) = sqnorm (f 2) from rfl]
    ring
  have hQ : (∑ k, (a k) ^ 2 * sqnorm (f k))
      = (a 0) ^ 2 * sqnorm (f 0) + (a 1) ^ 2 * sqnorm (f 1) + (a 2) ^ 2 * sqnorm (f 2) := by
    simp [Fin.sum_univ_three]
  have hAM : 2 * ((|a 0| * s0) * (|a 2| * s2)) ≤ (|a 0| * s0) ^ 2 + (|a 2| * s2) ^ 2 := by
    nlinarith [sq_nonneg (|a 0| * s0 - |a 2| * s2)]
  have hcoup : -(δ * ((a 0) ^ 2 * sqnorm (f 0) + (a 2) ^ 2 * sqnorm (f 2)))
      ≤ 2 * (a 0 * a 2 * dot (f 0) (f 2)) := by
    have h1 : |2 * (a 0 * a 2 * dot (f 0) (f 2))|
        ≤ δ * ((a 0) ^ 2 * sqnorm (f 0) + (a 2) ^ 2 * sqnorm (f 2)) := by
      have hstep : |2 * (a 0 * a 2 * dot (f 0) (f 2))|
          = 2 * (|a 0| * |a 2| * |dot (f 0) (f 2)|) := by
        rw [abs_mul, abs_mul, abs_mul]
        simp
      rw [hstep]
      have hb : |a 0| * |a 2| * |dot (f 0) (f 2)| ≤ |a 0| * |a 2| * (δ * (s0 * s2)) :=
        mul_le_mul_of_nonneg_left h02 (by positivity)
      have hfin : 2 * (|a 0| * |a 2| * (δ * (s0 * s2)))
          ≤ δ * ((a 0) ^ 2 * sqnorm (f 0) + (a 2) ^ 2 * sqnorm (f 2)) := by
        have hrw : (a 0) ^ 2 * sqnorm (f 0) + (a 2) ^ 2 * sqnorm (f 2)
            = (|a 0| * s0) ^ 2 + (|a 2| * s2) ^ 2 := by
          rw [mul_pow, mul_pow, sq_abs, sq_abs, hs0, hs2]
        rw [hrw]
        have h2 : 2 * (|a 0| * |a 2| * (δ * (s0 * s2)))
            = δ * (2 * ((|a 0| * s0) * (|a 2| * s2))) := by ring
        rw [h2]
        exact mul_le_mul_of_nonneg_left hAM hδ
      linarith
    have := abs_le.mp h1
    linarith [this.1]
  have hQ1 : 0 ≤ (a 1) ^ 2 * sqnorm (f 1) :=
    mul_nonneg (sq_nonneg _) (sqnorm_nonneg _)
  rw [hexp, hQ]
  nlinarith [hcoup, hQ1, hδ]

end Stability

/-! ## 2. The prime block has a single coupled pair -/

section PrimeBlock

variable {p : ℕ} [Fact p.Prime]

/-- The Gauss-sum coupling bound, in the numeric form `0.41` valid for `p ≥ 13`. -/
lemma qr_coupling_le_of_thirteen_le (hp : p ≠ 2) (hp13 : 13 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseSin k)|
      ≤ (0.41 : ℝ) * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k)))
    ∧ |dot (qrFeat (p := p)) (phaseCos k)|
      ≤ (0.41 : ℝ) * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k))) := by
  have hp3 : 3 ≤ p := by omega
  have hp1 : (13 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp13
  have hdelta : Real.sqrt (2 / ((p : ℝ) - 1)) ≤ 0.41 := by
    have h1 : 2 / ((p : ℝ) - 1) ≤ 2 / 12 :=
      div_le_div_of_nonneg_left (by norm_num) (by linarith) (by linarith)
    calc Real.sqrt (2 / ((p : ℝ) - 1)) ≤ Real.sqrt (2 / 12) := Real.sqrt_le_sqrt h1
      _ ≤ 0.41 := by
          rw [show (0.41 : ℝ) = Real.sqrt (0.41 ^ 2) by rw [Real.sqrt_sq]; norm_num]
          exact Real.sqrt_le_sqrt (by norm_num)
  constructor
  · refine le_trans (qr_phaseSin_gram_bound hp hp3 k hk hk2) ?_
    exact mul_le_mul_of_nonneg_right hdelta (by positivity)
  · refine le_trans (qr_phase_gram_bound hp hp3 k hk hk2) ?_
    exact mul_le_mul_of_nonneg_right hdelta (by positivity)

/-- **Single-coupling stability for `p ≡ 3 (mod 4)`.**  The cosine channel is exactly orthogonal
to the quadratic-residue indicator, so only the sine/QR pair is coupled. -/
theorem phase_block_stability_three_mod_four (hp : p ≠ 2) (hp13 : 13 ≤ p) (h3 : p % 4 = 3)
    (k : ZMod p) (hk : k ≠ 0) (hk2 : k + k ≠ 0) (a : Fin 3 → ℝ) :
    (1 - (0.41 : ℝ)) * (∑ j, (a j) ^ 2 * sqnorm (phaseBlock k j))
      ≤ sqnorm (combo a (phaseBlock k)) := by
  refine stability_three_single_coupling (phaseBlock k) 0.41 (by norm_num) ?_ ?_ ?_ a
  · exact dot_phaseCos_phaseSin k k
  · show dot (phaseCos k) (qrFeat (p := p)) = 0
    rw [dot_comm]
    exact dot_qrFeat_phaseCos_eq_zero_of_mod_four_eq_three hp h3 k hk
  · show |dot (phaseSin k) (qrFeat (p := p))|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseSin k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseSin k)))]
    exact (qr_coupling_le_of_thirteen_le hp hp13 k hk hk2).1

/-- **Single-coupling stability for `p ≡ 1 (mod 4)`.**  Now the sine channel is the orthogonal
one and only the cosine/QR pair is coupled. -/
theorem phase_block_stability_one_mod_four (hp : p ≠ 2) (hp13 : 13 ≤ p) (h1 : p % 4 = 1)
    (k : ZMod p) (hk : k ≠ 0) (hk2 : k + k ≠ 0) (a : Fin 3 → ℝ) :
    (1 - (0.41 : ℝ)) * (∑ j, (a j) ^ 2 * sqnorm (phaseBlock k j))
      ≤ sqnorm (combo a (phaseBlock k)) := by
  refine stability_three_single_coupling_alt (phaseBlock k) 0.41 (by norm_num) ?_ ?_ ?_ a
  · exact dot_phaseCos_phaseSin k k
  · show dot (phaseSin k) (qrFeat (p := p)) = 0
    rw [dot_comm]
    exact dot_qrFeat_phaseSin_eq_zero_of_mod_four_eq_one hp h1 k hk
  · show |dot (phaseCos k) (qrFeat (p := p))|
      ≤ 0.41 * (Real.sqrt (sqnorm (phaseCos k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseCos k)))]
    exact (qr_coupling_le_of_thirteen_le hp hp13 k hk hk2).2

/-- **The sharp prime-block ceiling.**  For every odd prime `p ≥ 13` — in either residue class
modulo `4` — the prime-`p` phase block lifts at most `3ε²/0.59` of the residual energy.  This is
a factor `3.28` better than the `3ε²/0.18` of the crude bound, and the improvement is purely
arithmetic: it comes from the Gauss-sign dichotomy killing one off-diagonal Gram entry. -/
theorem phase_block_lift_ceiling_sharp (hp : p ≠ 2) (hp13 : 13 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) (e : ZMod p → ℝ) (ε : ℝ)
    (hcorr : ∀ j, (dot e (phaseBlock k j)) ^ 2
      ≤ ε ^ 2 * (sqnorm e * sqnorm (phaseBlock k j)))
    (a : Fin 3 → ℝ) :
    gain e (combo a (phaseBlock k)) ≤ ((3 : ℝ) * ε ^ 2 / 0.59) * sqnorm e := by
  have hp3 : 3 ≤ p := by omega
  have hcard : (Fintype.card (Fin 3) : ℝ) = 3 := by simp
  have hodd : p % 4 = 1 ∨ p % 4 = 3 := by
    have hpp := (Fact.out : p.Prime)
    have h2 : p % 2 = 1 := by
      rcases hpp.eq_two_or_odd with h | h
      · omega
      · exact h
    omega
  have hstab : ∀ a' : Fin 3 → ℝ,
      (1 - (0.41 : ℝ)) * (∑ j, (a' j) ^ 2 * sqnorm (phaseBlock k j))
        ≤ sqnorm (combo a' (phaseBlock k)) := by
    intro a'
    rcases hodd with h | h
    · exact phase_block_stability_one_mod_four hp hp13 h k hk hk2 a'
    · exact phase_block_stability_three_mod_four hp hp13 h k hk hk2 a'
  have h := span_gain_le e (phaseBlock k) ε 0.41
    (sqnorm_phaseBlock_pos hp3 k hk2) hcorr (by norm_num) hstab a
  rw [hcard] at h
  norm_num at h ⊢
  convert h using 3

end PrimeBlock

/-! ## 3. Numeric consequences for exp 482 -/

section Numerics

/-- With the sharp constant the nine prime blocks of exp 482 are capped at `0.005` of the
residual energy — a third of the crude `0.015`. -/
theorem sharp_subthreshold_certificate :
    (9 : ℝ) * ((3 : ℝ) * (0.01 : ℝ) ^ 2 / (1 - (0.41 : ℝ))) ≤ 0.005 := by
  norm_num

/-- Consequently the best achievable phase-augmented score from the `0.600` footprint dial is
`0.602`, against the registered `H3` bar of `0.70`: the refutation survives with a margin an
order of magnitude larger than the measured lift. -/
theorem sharp_H3_unreachable :
    (0.600 : ℝ) + 0.005 * (1 - 0.600) < 0.70 := by
  norm_num

/-- The improvement factor of the sharp constant over the crude one. -/
theorem sharp_improvement_factor :
    (3 : ℝ) < (1 - (0.41 : ℝ)) / (1 - (0.41 : ℝ) * ((3 : ℝ) - 1)) := by
  norm_num

end Numerics

end Catalog.Novelty.PhaseFeatureSharpBlock