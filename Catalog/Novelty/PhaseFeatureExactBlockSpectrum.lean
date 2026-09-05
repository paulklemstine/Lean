import Novelty.PhaseFeatureSharpBlock

/-!
# The exact prime-block constant, and the ceiling for small primes (paper 150, fourth cycle)

## Research context

`Novelty.PhaseFeatureSharpBlock` proved the *inequality* half of the first future direction of
this thread: using the Gauss-sign dichotomy, the prime-`p` phase block `(cos_k, sin_k, QR)` is a
restricted isometry with constant `1 - δ` where `δ = √(2/(p-1))`, giving the lift ceiling
`3ε²/(1-δ)`.  Two questions were left open there:

1. **Exactness.**  Is `1 - δ` attained, i.e. is it really the smallest eigenvalue of the
   normalised block Gram, or merely a lower bound for it?
2. **Small primes.**  The numeric form of the ceiling was stated only for `p ≥ 13`, because the
   crude constant `1 - 2δ` is negative for `p < 11`.  With the sharp constant only `δ < 1` is
   needed, i.e. `p ≥ 5`.

This file settles both.

The key arithmetic observation is that the Gauss-sum bound is an *equality* once the dichotomy is
taken into account: for `p ≡ 3 (mod 4)` the Gauss sum is purely imaginary of modulus `√p`, so the
sine/QR coupling equals `√p` exactly, which normalised is exactly `δ = √(2/(p-1))`; symmetrically
for `p ≡ 1 (mod 4)` and the cosine channel.  Feeding the equality into an explicit two-feature
witness shows no constant larger than `1 - δ` can satisfy the restricted-isometry inequality.

## Main results

* `abs_dot_qrFeat_phaseSin_eq_of_three_mod_four`, `abs_dot_qrFeat_phaseCos_eq_of_one_mod_four` —
  the coupling is *exactly* `√p` in the active channel.
* `qr_phaseSin_gram_exact`, `qr_phaseCos_gram_exact` — normalised, the active coupling is exactly
  `gaussDelta p = √(2/(p-1))`.
* `stability_constant_le_of_exact_12`, `stability_constant_le_of_exact_02` — an exactly coupled
  pair caps every admissible restricted-isometry constant at `1 - δ` (explicit witness).
* `block_stability_constant_eq` — **exactness**: for every odd prime `p ≥ 5` the optimal
  restricted-isometry constant of the prime block is exactly `1 - gaussDelta p`, in both residue
  classes mod `4`.
* `phase_block_lift_ceiling_gaussDelta`, `phase_block_lift_ceiling_small_prime` — the ceiling
  `3ε²/(1 - gaussDelta p)`, valid for **all** odd primes `p ≥ 5`, and its numeric form
  `3ε²/0.292`.
* `small_prime_subthreshold_certificate`, `small_prime_H3_unreachable` — the exp-482 numbers with
  the small primes `5, 7, 11` included: nine blocks are capped at `0.01`, so the best achievable
  phase-augmented score from the `0.600` footprint dial is `0.604 < 0.70`.

## Lab notes (fourth cycle)

```
p     δ = √(2/(p-1))   1 - δ     per-block ceiling at ε = 0.01   coupling |⟨QR,·⟩| exact?
5      0.70711         0.29289          0.001024                yes (sine, p ≡ 1 mod 4: cos)
7      0.57735         0.42265          0.000710                yes (sine)
11     0.44721         0.55279          0.000543                yes (cosine)
13     0.40825         0.59175          0.000507                yes (cosine)
29     0.26726         0.73274          0.000409                yes (cosine)
nine blocks at ε = 0.01, worst constant (p = 5) :  9 · 3·10⁻⁴/0.292 = 0.00925 ≤ 0.01
best phase-augmented score from 0.600 :  0.604 < 0.70   (H3 refuted including small primes)
```
-/

open Finset
open Catalog.Novelty.PhaseFeatureLiftCeiling
open Catalog.Novelty.PhaseFeatureCharacterGram
open Catalog.Novelty.PhaseFeatureSharpBlock

namespace Catalog.Novelty.PhaseFeatureExactBlockSpectrum

/-! ## 1. The normalised Gauss coupling `δ = √(2/(p-1))` -/

/-- The normalised Gauss-sum coupling of the prime-`p` phase block. -/
noncomputable def gaussDelta (p : ℕ) : ℝ := Real.sqrt (2 / ((p : ℝ) - 1))

lemma gaussDelta_nonneg (p : ℕ) : 0 ≤ gaussDelta p := Real.sqrt_nonneg _

/-- For every prime `p ≥ 5` the coupling is `< 1`, so the sharp constant `1 - δ` is positive.
This is exactly the range in which the block ceiling is meaningful. -/
lemma gaussDelta_lt_one {p : ℕ} (hp5 : 5 ≤ p) : gaussDelta p < 1 := by
  have hp : (5 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp5
  have h : 2 / ((p : ℝ) - 1) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    linarith
  have hle : gaussDelta p ≤ Real.sqrt (1 / 2) := Real.sqrt_le_sqrt h
  have hsq : Real.sqrt (1 / 2) ^ 2 = 1 / 2 := Real.sq_sqrt (by norm_num)
  nlinarith [Real.sqrt_nonneg ((1 : ℝ) / 2)]

/-- The numeric envelope used for the small-prime certificate: `δ ≤ 0.708` for every `p ≥ 5`. -/
lemma gaussDelta_le_of_five_le {p : ℕ} (hp5 : 5 ≤ p) : gaussDelta p ≤ 0.708 := by
  have hp : (5 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp5
  have h : 2 / ((p : ℝ) - 1) ≤ 1 / 2 := by
    rw [div_le_div_iff₀ (by linarith) (by norm_num)]
    linarith
  have hle : gaussDelta p ≤ Real.sqrt (1 / 2) := Real.sqrt_le_sqrt h
  have hsq : Real.sqrt (1 / 2) ^ 2 = 1 / 2 := Real.sq_sqrt (by norm_num)
  nlinarith [Real.sqrt_nonneg ((1 : ℝ) / 2)]

/-! ## 2. The coupling is exactly `√p` in the active channel -/

section Exact

variable {p : ℕ} [Fact p.Prime]

private lemma norm_sq_eq_re_add_im (z : ℂ) : ‖z‖ ^ 2 = z.re ^ 2 + z.im ^ 2 := by
  rw [← Complex.normSq_eq_norm_sq]
  simp [Complex.normSq_apply]
  ring

/-- **Exact coupling, `p ≡ 3 (mod 4)`.**  The Gauss sum is purely imaginary of modulus `√p`, so
the sine channel carries the *whole* coupling: `|⟨QR, sin_k⟩| = √p`, with no loss in the
Cauchy–Schwarz step. -/
theorem abs_dot_qrFeat_phaseSin_eq_of_three_mod_four (hp : p ≠ 2) (h3 : p % 4 = 3)
    (k : ZMod p) (hk : k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseSin k)| = Real.sqrt p := by
  set g := gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) with hg
  have hre : g.re = 0 := gaussSum_re_eq_zero_of_mod_four_eq_three hp h3 k hk
  have hn : ‖g‖ ^ 2 = (p : ℝ) := norm_gaussSum_sq hp k hk
  have him : g.im ^ 2 = (p : ℝ) := by
    rw [norm_sq_eq_re_add_im, hre] at hn; linarith
  rw [dot_qrFeat_phaseSin_eq, ← him, Real.sqrt_sq_eq_abs]

/-- **Exact coupling, `p ≡ 1 (mod 4)`.**  Now the Gauss sum is real of modulus `√p` and the
cosine channel carries the whole coupling. -/
theorem abs_dot_qrFeat_phaseCos_eq_of_one_mod_four (hp : p ≠ 2) (h1 : p % 4 = 1)
    (k : ZMod p) (hk : k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseCos k)| = Real.sqrt p := by
  set g := gaussSum (chiC p) (ZMod.stdAddChar.mulShift k) with hg
  have him : g.im = 0 := gaussSum_im_eq_zero_of_mod_four_eq_one hp h1 k hk
  have hn : ‖g‖ ^ 2 = (p : ℝ) := norm_gaussSum_sq hp k hk
  have hre : g.re ^ 2 = (p : ℝ) := by
    rw [norm_sq_eq_re_add_im, him] at hn; linarith
  rw [dot_qrFeat_phaseCos_eq, ← hre, Real.sqrt_sq_eq_abs]

/-- Normalising by the feature energies `‖QR‖² = p - 1` and `‖sin_k‖² = p/2` turns the exact
coupling into exactly `gaussDelta p`. -/
theorem qr_phaseSin_gram_exact (hp : p ≠ 2) (hp3 : 3 ≤ p) (h3 : p % 4 = 3) (k : ZMod p)
    (hk : k ≠ 0) (hk2 : k + k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseSin k)|
      = gaussDelta p * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k))) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  have hpm : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hnum : gaussDelta p
      * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseSin k)))
      = Real.sqrt p := by
    rw [gaussDelta, sqnorm_qrFeat, sqnorm_phaseSin k hk2, ← Real.sqrt_mul hpm.le,
      ← Real.sqrt_mul (div_pos two_pos hpm).le]
    congr 1
    field_simp
  rw [hnum]
  exact abs_dot_qrFeat_phaseSin_eq_of_three_mod_four hp h3 k hk

/-- The cosine-channel version of `qr_phaseSin_gram_exact`. -/
theorem qr_phaseCos_gram_exact (hp : p ≠ 2) (hp3 : 3 ≤ p) (h1 : p % 4 = 1) (k : ZMod p)
    (hk : k ≠ 0) (hk2 : k + k ≠ 0) :
    |dot (qrFeat (p := p)) (phaseCos k)|
      = gaussDelta p * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k))) := by
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast lt_of_lt_of_le (by norm_num) hp3
  have hpm : (0 : ℝ) < (p : ℝ) - 1 := by linarith
  have hnum : gaussDelta p
      * (Real.sqrt (sqnorm (qrFeat (p := p))) * Real.sqrt (sqnorm (phaseCos k)))
      = Real.sqrt p := by
    rw [gaussDelta, sqnorm_qrFeat, sqnorm_phaseCos k hk2, ← Real.sqrt_mul hpm.le,
      ← Real.sqrt_mul (div_pos two_pos hpm).le]
    congr 1
    field_simp
  rw [hnum]
  exact abs_dot_qrFeat_phaseCos_eq_of_one_mod_four hp h1 k hk

end Exact

/-! ## 3. An exactly coupled pair caps the restricted-isometry constant -/

section Sharpness

variable {ι : Type*} [Fintype ι]

/-- **The witness of an exactly coupled pair.**  If two features are correlated *exactly* at
level `δ`, there is a coefficient pair whose energy budget is `2‖u‖²‖v‖²` and whose realized
energy is exactly `(1-δ)` times that budget: subtract the two normalised features with the sign
that makes the cross term maximally destructive. -/
lemma pair_witness (u v : ι → ℝ) (δ : ℝ) (hu : 0 < sqnorm u) (hv : 0 < sqnorm v)
    (hcoup : |dot u v| = δ * (Real.sqrt (sqnorm u) * Real.sqrt (sqnorm v))) :
    ∃ x y : ℝ, x ^ 2 * sqnorm u + y ^ 2 * sqnorm v = 2 * (sqnorm u * sqnorm v) ∧
      x ^ 2 * sqnorm u + y ^ 2 * sqnorm v + 2 * (x * y * dot u v)
        = (1 - δ) * (2 * (sqnorm u * sqnorm v)) := by
  set s := dot u v with hs
  set sgn : ℝ := if 0 ≤ s then -1 else 1 with hsgn
  have hsgn_sq : sgn ^ 2 = 1 := by
    rcases le_or_gt 0 s with h | h
    · rw [hsgn, if_pos h]; norm_num
    · rw [hsgn, if_neg (not_le.mpr h)]; norm_num
  have hsgn_s : sgn * s = -|s| := by
    rcases le_or_gt 0 s with h | h
    · rw [hsgn, if_pos h, abs_of_nonneg h]; ring
    · rw [hsgn, if_neg (not_le.mpr h), abs_of_neg h]; ring
  have hru : Real.sqrt (sqnorm u) ^ 2 = sqnorm u := Real.sq_sqrt hu.le
  have hrv : Real.sqrt (sqnorm v) ^ 2 = sqnorm v := Real.sq_sqrt hv.le
  refine ⟨Real.sqrt (sqnorm v), sgn * Real.sqrt (sqnorm u), ?_, ?_⟩
  · rw [mul_pow, hru, hrv, hsgn_sq]; ring
  · have h1 : Real.sqrt (sqnorm v) ^ 2 * sqnorm u
        + (sgn * Real.sqrt (sqnorm u)) ^ 2 * sqnorm v = 2 * (sqnorm u * sqnorm v) := by
      rw [mul_pow, hru, hrv, hsgn_sq]; ring
    have h2 : Real.sqrt (sqnorm v) * (sgn * Real.sqrt (sqnorm u)) * s
        = -(δ * (sqnorm u * sqnorm v)) := by
      have hre : Real.sqrt (sqnorm v) * (sgn * Real.sqrt (sqnorm u)) * s
          = (sgn * s) * (Real.sqrt (sqnorm u) * Real.sqrt (sqnorm v)) := by ring
      rw [hre, hsgn_s, hcoup]
      linear_combination (-δ * Real.sqrt (sqnorm v) ^ 2) * hru + (-δ * sqnorm u) * hrv
    linarith [h1, h2]

/-- **Sharpness, coupled pair `(1,2)`.**  If features `1` and `2` are correlated *exactly* at
level `δ`, then no constant larger than `1 - δ` can satisfy the restricted-isometry inequality.
No hypothesis whatsoever is needed on feature `0`, since the witness gives it coefficient zero. -/
theorem stability_constant_le_of_exact_12 (f : Fin 3 → ι → ℝ) (δ : ℝ)
    (h1 : 0 < sqnorm (f 1)) (h2 : 0 < sqnorm (f 2))
    (hcoup : |dot (f 1) (f 2)|
      = δ * (Real.sqrt (sqnorm (f 1)) * Real.sqrt (sqnorm (f 2))))
    (c : ℝ)
    (hc : ∀ a : Fin 3 → ℝ,
      c * (∑ l, (a l) ^ 2 * sqnorm (f l)) ≤ sqnorm (combo a f)) :
    c ≤ 1 - δ := by
  obtain ⟨x, y, hA, hB⟩ := pair_witness (f 1) (f 2) δ h1 h2 hcoup
  have hd11 : dot (f 1) (f 1) = sqnorm (f 1) := rfl
  have hd22 : dot (f 2) (f 2) = sqnorm (f 2) := rfl
  have hd21 : dot (f 2) (f 1) = dot (f 1) (f 2) := dot_comm _ _
  have hsum : (∑ l, ((![0, x, y] : Fin 3 → ℝ) l) ^ 2 * sqnorm (f l))
      = 2 * (sqnorm (f 1) * sqnorm (f 2)) := by
    simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    linarith [hA]
  have hcombo : sqnorm (combo (![0, x, y] : Fin 3 → ℝ) f)
      = (1 - δ) * (2 * (sqnorm (f 1) * sqnorm (f 2))) := by
    rw [sqnorm_combo]
    simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hd11, hd22, hd21]
    linarith [hB]
  have hkey := hc ![0, x, y]
  rw [hsum, hcombo] at hkey
  have hpos : 0 < 2 * (sqnorm (f 1) * sqnorm (f 2)) := by positivity
  exact le_of_mul_le_mul_right (by linarith) hpos

/-- **Sharpness, coupled pair `(0,2)`.**  The same statement with the cosine channel active. -/
theorem stability_constant_le_of_exact_02 (f : Fin 3 → ι → ℝ) (δ : ℝ)
    (h0 : 0 < sqnorm (f 0)) (h2 : 0 < sqnorm (f 2))
    (hcoup : |dot (f 0) (f 2)|
      = δ * (Real.sqrt (sqnorm (f 0)) * Real.sqrt (sqnorm (f 2))))
    (c : ℝ)
    (hc : ∀ a : Fin 3 → ℝ,
      c * (∑ l, (a l) ^ 2 * sqnorm (f l)) ≤ sqnorm (combo a f)) :
    c ≤ 1 - δ := by
  obtain ⟨x, y, hA, hB⟩ := pair_witness (f 0) (f 2) δ h0 h2 hcoup
  have hd00 : dot (f 0) (f 0) = sqnorm (f 0) := rfl
  have hd22 : dot (f 2) (f 2) = sqnorm (f 2) := rfl
  have hd20 : dot (f 2) (f 0) = dot (f 0) (f 2) := dot_comm _ _
  have hsum : (∑ l, ((![x, 0, y] : Fin 3 → ℝ) l) ^ 2 * sqnorm (f l))
      = 2 * (sqnorm (f 0) * sqnorm (f 2)) := by
    simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    linarith [hA]
  have hcombo : sqnorm (combo (![x, 0, y] : Fin 3 → ℝ) f)
      = (1 - δ) * (2 * (sqnorm (f 0) * sqnorm (f 2))) := by
    rw [sqnorm_combo]
    simp only [Fin.sum_univ_three, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
    rw [hd00, hd22, hd20]
    linarith [hB]
  have hkey := hc ![x, 0, y]
  rw [hsum, hcombo] at hkey
  have hpos : 0 < 2 * (sqnorm (f 0) * sqnorm (f 2)) := by positivity
  exact le_of_mul_le_mul_right (by linarith) hpos

end Sharpness

/-! ## 4. The prime block: stability with the exact constant, down to `p = 5` -/

section PrimeBlock

variable {p : ℕ} [Fact p.Prime]

/-- The block is a restricted isometry with the *arithmetic* constant `1 - gaussDelta p`, for
every odd prime `p ≥ 5` — the crude `1 - 2δ` bound is vacuous below `p = 11`, this one is not. -/
theorem phase_block_stability_gaussDelta (hp : p ≠ 2) (hp5 : 5 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) (a : Fin 3 → ℝ) :
    (1 - gaussDelta p) * (∑ j, (a j) ^ 2 * sqnorm (phaseBlock k j))
      ≤ sqnorm (combo a (phaseBlock k)) := by
  have hp3 : 3 ≤ p := by omega
  have hodd : p % 4 = 1 ∨ p % 4 = 3 := by
    have hpp := (Fact.out : p.Prime)
    have h2 : p % 2 = 1 := by
      rcases hpp.eq_two_or_odd with h | h
      · omega
      · exact h
    omega
  rcases hodd with h1 | h3
  · -- cosine channel active, sine channel exactly orthogonal
    refine stability_three_single_coupling_alt (phaseBlock k) (gaussDelta p)
      (gaussDelta_nonneg p) ?_ ?_ ?_ a
    · exact dot_phaseCos_phaseSin k k
    · show dot (phaseSin k) (qrFeat (p := p)) = 0
      rw [dot_comm]
      exact dot_qrFeat_phaseSin_eq_zero_of_mod_four_eq_one hp h1 k hk
    · show |dot (phaseCos k) (qrFeat (p := p))|
        ≤ gaussDelta p * (Real.sqrt (sqnorm (phaseCos k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
      rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseCos k)))]
      exact qr_phase_gram_bound hp hp3 k hk hk2
  · -- sine channel active, cosine channel exactly orthogonal
    refine stability_three_single_coupling (phaseBlock k) (gaussDelta p)
      (gaussDelta_nonneg p) ?_ ?_ ?_ a
    · exact dot_phaseCos_phaseSin k k
    · show dot (phaseCos k) (qrFeat (p := p)) = 0
      rw [dot_comm]
      exact dot_qrFeat_phaseCos_eq_zero_of_mod_four_eq_three hp h3 k hk
    · show |dot (phaseSin k) (qrFeat (p := p))|
        ≤ gaussDelta p * (Real.sqrt (sqnorm (phaseSin k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
      rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseSin k)))]
      exact qr_phaseSin_gram_bound hp hp3 k hk hk2

/-- **Exactness.**  For every odd prime `p ≥ 5` the optimal restricted-isometry constant of the
prime-`p` phase block is *exactly* `1 - gaussDelta p`: the inequality of
`phase_block_stability_gaussDelta` holds, and every constant `c` for which it holds satisfies
`c ≤ 1 - gaussDelta p`.  This closes the exactness half of the first future direction of the
previous cycle: the sharp constant is attained, so the ceiling `3ε²/(1-δ)` cannot be improved by
any further Gram-based argument. -/
theorem block_stability_constant_eq (hp : p ≠ 2) (hp5 : 5 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) :
    (∀ a : Fin 3 → ℝ, (1 - gaussDelta p) * (∑ j, (a j) ^ 2 * sqnorm (phaseBlock k j))
        ≤ sqnorm (combo a (phaseBlock k)))
    ∧ (∀ c : ℝ, (∀ a : Fin 3 → ℝ, c * (∑ j, (a j) ^ 2 * sqnorm (phaseBlock k j))
        ≤ sqnorm (combo a (phaseBlock k))) → c ≤ 1 - gaussDelta p) := by
  have hp3 : 3 ≤ p := by omega
  have hodd : p % 4 = 1 ∨ p % 4 = 3 := by
    have hpp := (Fact.out : p.Prime)
    have h2 : p % 2 = 1 := by
      rcases hpp.eq_two_or_odd with h | h
      · omega
      · exact h
    omega
  refine ⟨phase_block_stability_gaussDelta hp hp5 k hk hk2, ?_⟩
  intro c hc
  have hposb := sqnorm_phaseBlock_pos (p := p) hp3 k hk2
  rcases hodd with h1 | h3
  · refine stability_constant_le_of_exact_02 (phaseBlock k) (gaussDelta p)
      (hposb 0) (hposb 2) ?_ c hc
    show |dot (phaseCos k) (qrFeat (p := p))|
      = gaussDelta p * (Real.sqrt (sqnorm (phaseCos k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseCos k)))]
    exact qr_phaseCos_gram_exact hp hp3 h1 k hk hk2
  · refine stability_constant_le_of_exact_12 (phaseBlock k) (gaussDelta p)
      (hposb 1) (hposb 2) ?_ c hc
    show |dot (phaseSin k) (qrFeat (p := p))|
      = gaussDelta p * (Real.sqrt (sqnorm (phaseSin k)) * Real.sqrt (sqnorm (qrFeat (p := p))))
    rw [dot_comm, mul_comm (Real.sqrt (sqnorm (phaseSin k)))]
    exact qr_phaseSin_gram_exact hp hp3 h3 k hk hk2

/-- **The arithmetic block ceiling, valid for all odd primes `p ≥ 5`.**  Whatever linear
combination of `(cos_k, sin_k, QR)` is fitted, its lift over the baseline is at most
`3ε²/(1 - √(2/(p-1)))` of the residual energy. -/
theorem phase_block_lift_ceiling_gaussDelta (hp : p ≠ 2) (hp5 : 5 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) (e : ZMod p → ℝ) (ε : ℝ)
    (hcorr : ∀ j, (dot e (phaseBlock k j)) ^ 2
      ≤ ε ^ 2 * (sqnorm e * sqnorm (phaseBlock k j)))
    (a : Fin 3 → ℝ) :
    gain e (combo a (phaseBlock k)) ≤ ((3 : ℝ) * ε ^ 2 / (1 - gaussDelta p)) * sqnorm e := by
  have hp3 : 3 ≤ p := by omega
  have hcard : (Fintype.card (Fin 3) : ℝ) = 3 := by simp
  have h := span_gain_le e (phaseBlock k) ε (gaussDelta p)
    (sqnorm_phaseBlock_pos hp3 k hk2) hcorr (gaussDelta_lt_one hp5)
    (phase_block_stability_gaussDelta hp hp5 k hk hk2) a
  rwa [hcard] at h

/-- The numeric form of the small-prime ceiling: `3ε²/0.292` for every odd prime `p ≥ 5`,
including the primes `5, 7, 11` that the `p ≥ 13` certificates had to exclude. -/
theorem phase_block_lift_ceiling_small_prime (hp : p ≠ 2) (hp5 : 5 ≤ p) (k : ZMod p) (hk : k ≠ 0)
    (hk2 : k + k ≠ 0) (e : ZMod p → ℝ) (ε : ℝ)
    (hcorr : ∀ j, (dot e (phaseBlock k j)) ^ 2
      ≤ ε ^ 2 * (sqnorm e * sqnorm (phaseBlock k j)))
    (a : Fin 3 → ℝ) :
    gain e (combo a (phaseBlock k)) ≤ ((3 : ℝ) * ε ^ 2 / 0.292) * sqnorm e := by
  have h := phase_block_lift_ceiling_gaussDelta hp hp5 k hk hk2 e ε hcorr a
  have hδ : gaussDelta p ≤ 0.708 := gaussDelta_le_of_five_le hp5
  have hd : (0.292 : ℝ) ≤ 1 - gaussDelta p := by linarith
  have hmono : ((3 : ℝ) * ε ^ 2 / (1 - gaussDelta p)) ≤ ((3 : ℝ) * ε ^ 2 / 0.292) :=
    div_le_div_of_nonneg_left (by positivity) (by norm_num) hd
  exact le_trans h (mul_le_mul_of_nonneg_right hmono (sqnorm_nonneg e))

end PrimeBlock

/-! ## 5. Numeric consequences for exp 482, small primes included -/

section Numerics

/-- With the small primes `5, 7, 11` in the design the nine phase blocks of exp 482 are still
capped at `0.01` of the residual energy at the measured correlation scale `ε = 0.01`. -/
theorem small_prime_subthreshold_certificate :
    (9 : ℝ) * ((3 : ℝ) * (0.01 : ℝ) ^ 2 / 0.292) ≤ 0.01 := by
  norm_num

/-- Hence the best achievable phase-augmented score from the `0.600` footprint dial is `0.604`,
still far below the registered `H3` bar of `0.70` — the refutation does not depend on excluding
the small primes. -/
theorem small_prime_H3_unreachable :
    (0.600 : ℝ) + 0.01 * (1 - 0.600) < 0.70 := by
  norm_num

/-- The exact constants are strictly ordered in `p`: the block at `p = 5` is the worst case of
the design, and every larger prime has a strictly better ceiling. -/
theorem gaussDelta_strict_anti {p q : ℕ} (hp5 : 5 ≤ p) (hpq : p < q) :
    gaussDelta q < gaussDelta p := by
  have hp : (5 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp5
  have hq : (p : ℝ) < (q : ℝ) := by exact_mod_cast hpq
  have hlt : 2 / ((q : ℝ) - 1) < 2 / ((p : ℝ) - 1) := by
    rw [div_lt_div_iff₀ (by linarith) (by linarith)]
    linarith
  have hq0 : (0 : ℝ) < (q : ℝ) - 1 := by linarith
  exact Real.sqrt_lt_sqrt (le_of_lt (div_pos two_pos hq0)) hlt

end Numerics

end Catalog.Novelty.PhaseFeatureExactBlockSpectrum