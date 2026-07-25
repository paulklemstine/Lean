/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Fourier Analysis on Finite Cyclic Groups: Plancherel, Convolution, and Additive Energy

This file develops the discrete Fourier transform (`ZMod.dft`) toolkit that Mathlib leaves
unstated for finite cyclic groups and applies it to additive combinatorics.

Mathlib provides `ZMod.dft` (the discrete Fourier transform on `ZMod N`) together with the
Fourier inversion formula `ZMod.dft_dft`, but it does **not** provide:

  * the **convolution theorem** `𝓕(f ⋆ g) = 𝓕 f · 𝓕 g`,
  * **Plancherel / Parseval** `∑ₖ ‖𝓕 f k‖² = N · ∑ⱼ ‖f j‖²`, or
  * any link between Fourier analysis and `Finset.addEnergy` (additive energy).

We fill all three gaps and prove the central combinatorial identity of additive combinatorics:

      E[A] = (1 / N) · ∑ₖ ‖𝓕 1_A (k)‖⁴            (`addEnergy_eq_dft`)

i.e. the additive energy of a set `A ⊆ ℤ/Nℤ` is, up to the factor `1/N`, the fourth moment of
the Fourier transform of its indicator function. This is the Fourier-analytic backbone behind
Roth-type theorems and the Balog–Szemerédi–Gowers theorem.

-- !-- Lab Notes -- !--
HYPOTHESIS.  The additive energy `E[A]` should equal a fourth moment of the Fourier transform of
`1_A`, because `E[A] = ∑ₐ r(a)²` where `r = 1_A ⋆ 1_A`, and Parseval converts the `ℓ²` norm of
`r` into the `ℓ²` norm of `𝓕 r = (𝓕 1_A)²`.

EXPERIMENTAL PLAN.  Prove (1) character orthogonality, (2) the convolution theorem, (3) Plancherel,
then (4) identify `1_A ⋆ 1_A` with the representation-count function and assemble (1)-(4).

INSIGHT.  Mathlib's `ZMod.dft` uses the convention `𝓕 Φ k = ∑ⱼ stdAddChar(-(j·k)) · Φ j`, with the
normalizing `N` living on the *inverse* transform (`dft_dft = N • Φ(-·)`). Consequently Plancherel
carries the constant `N` on the spectral side, not `1/N`; the final energy identity therefore reads
`E[A] = N⁻¹ · ∑ₖ ‖𝓕 1_A k‖⁴`.
-- !-- End Lab Notes -- !--
-/

import Mathlib

namespace Catalog.Combinatorics.FourierFiniteGroups

open Finset ZMod
open scoped BigOperators ComplexConjugate

variable {N : ℕ} [NeZero N]

/-! ## Character orthogonality -/

/-- The conjugate of the standard additive character at `x` is its value at `-x`. -/
lemma conj_stdAddChar (x : ZMod N) :
    conj (stdAddChar x) = stdAddChar (-x) := by
  rw [AddChar.map_neg_eq_inv]
  exact (Complex.inv_eq_conj (AddChar.norm_apply _ _)).symm

/-- **Orthogonality of the standard additive character.** Summing `stdAddChar (t · i)` over all
`i` gives `N` if `t = 0` and `0` otherwise. -/
lemma stdAddChar_sum_mul (t : ZMod N) :
    ∑ i, stdAddChar (t * i) = if t = 0 then (N : ℂ) else 0 := by
  by_cases h : t = 0
  · subst h; simp [ZMod.card]
  · simp only [h, if_false]
    have h_nt : (AddChar.mulShift (stdAddChar : AddChar (ZMod N) ℂ) t) ≠ 1 :=
      ZMod.isPrimitive_stdAddChar N h
    rw [← AddChar.sum_eq_zero_of_ne_one h_nt]
    exact Finset.sum_congr rfl fun i _ => by rw [AddChar.mulShift_apply]

/-! ## Convolution and the convolution theorem -/

/-- Complex indicator function of a finset of `ZMod N`. -/
noncomputable def ind (s : Finset (ZMod N)) : ZMod N → ℂ := fun x => if x ∈ s then 1 else 0

/-- Cyclic convolution of two functions on `ZMod N`. -/
noncomputable def conv (f g : ZMod N → ℂ) : ZMod N → ℂ := fun x => ∑ y, f y * g (x - y)

/-
**Convolution theorem.** The discrete Fourier transform turns convolution into pointwise
multiplication.
-/
lemma dft_conv (f g : ZMod N → ℂ) (k : ZMod N) :
    dft (conv f g) k = dft f k * dft g k := by
  -- By definition of convolution, we have:
  have h_conv : (𝓕 (conv f g)) k = ∑ x, (∑ y, f y * g (x - y)) * (stdAddChar (-k * x)) := by
    convert ZMod.dft_apply ( conv f g ) k using 1;
    simp +decide [ mul_comm, conv ];
  -- Reindex the inner sum: for fixed `y`, substitute `x = y + z` (use `Finset.sum_bij` / `Equiv.sum_comp` with the bijection `z ↦ y + z` on `ZMod N`, or `Finset.sum_nbij'` with inverse `x ↦ x - y`).
  have h_reindex : ∀ y : ZMod N, ∑ x : ZMod N, f y * g (x - y) * stdAddChar (-k * x) = f y * stdAddChar (-k * y) * ∑ z : ZMod N, g z * stdAddChar (-k * z) := by
    intro y; rw [ Finset.mul_sum _ _ _ ] ; rw [ ← Equiv.sum_comp ( Equiv.addRight y ) ] ; simp +decide [ mul_assoc, mul_left_comm, sub_eq_add_neg ] ;
    simp +decide [ mul_add, AddChar.map_add_eq_mul ];
  simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, ZMod.dft_apply ];
  rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => h_reindex _ ];
  exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_congr rfl fun _ _ => by ring )

/-! ## Plancherel / Parseval -/

/-
**Parseval's identity** (sesquilinear form).
-/
lemma parseval (f g : ZMod N → ℂ) :
    ∑ k, dft f k * conj (dft g k) = (N : ℂ) * ∑ j, f j * conj (g j) := by
  -- Apply Parseval's identity to the left-hand side of the equation.
  have h_parseval : ∑ k : ZMod N, (dft f k) * (starRingEnd ℂ (dft g k)) = N * ∑ j : ZMod N, f j * (starRingEnd ℂ (g j)) := by
    have h_sum : ∀ k : ZMod N, (dft f k) * (starRingEnd ℂ (dft g k)) = ∑ j : ZMod N, ∑ l : ZMod N, f j * (starRingEnd ℂ (g l)) * (stdAddChar (-(j * k))) * (stdAddChar (l * k)) := by
      intro k
      have h_expand : (dft f k) = ∑ j : ZMod N, f j * stdAddChar (-(j * k)) := by
        simp +decide [ ZMod.dft_apply, mul_comm ]
      have h_expand_conj : (starRingEnd ℂ (dft g k)) = ∑ l : ZMod N, (starRingEnd ℂ (g l)) * stdAddChar (l * k) := by
        rw [ ZMod.dft_apply, map_sum ];
        simp +decide [ mul_comm, conj_stdAddChar ]
      rw [h_expand, h_expand_conj];
      simp +decide only [Finset.sum_mul _ _ _, mul_sum, mul_left_comm, mul_assoc]
    -- Now use the orthogonality of the characters to simplify the inner sum.
    have h_inner : ∀ j l : ZMod N, ∑ k : ZMod N, (stdAddChar (-(j * k))) * (stdAddChar (l * k)) = if j = l then (N : ℂ) else 0 := by
      intro j l; split_ifs with h; simp_all +decide [ ← AddChar.map_add_eq_mul ] ;
      convert stdAddChar_sum_mul ( l - j ) using 1 ; ring;
      · simp +decide only [stdAddChar, mul_comm, AddChar.map_add_eq_mul];
      · rw [ if_neg ( sub_ne_zero_of_ne <| Ne.symm h ) ];
    -- Apply the orthogonality result to simplify the double sum.
    have h_double_sum : ∑ k : ZMod N, ∑ j : ZMod N, ∑ l : ZMod N, f j * (starRingEnd ℂ (g l)) * (stdAddChar (-(j * k))) * (stdAddChar (l * k)) = ∑ j : ZMod N, ∑ l : ZMod N, f j * (starRingEnd ℂ (g l)) * (if j = l then (N : ℂ) else 0) := by
      rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; intros ; rw [ ← Finset.sum_comm ] ; simp +decide [ ← h_inner, mul_assoc, Finset.mul_sum _ _ _ ] ;
    simp_all +decide [ Finset.mul_sum _ _ _, mul_assoc, mul_comm, mul_left_comm ];
  exact h_parseval

/-
**Plancherel's identity** in real `ℓ²`-norm form.
-/
lemma plancherel (f : ZMod N → ℂ) :
    ∑ k, ‖dft f k‖ ^ 2 = (N : ℝ) * ∑ j, ‖f j‖ ^ 2 := by
  convert congr_arg Complex.re ( parseval f f ) using 1;
  · norm_num [ Complex.mul_conj, Complex.normSq_eq_norm_sq ];
    norm_cast;
  · norm_num [ Complex.mul_conj, Complex.normSq_eq_norm_sq ];
    norm_cast ; norm_num

/-! ## Additive energy via Fourier -/

/-- Number of ordered pairs `(x, y) ∈ s × s` with `x + y = a`. -/
noncomputable def count (s : Finset (ZMod N)) (a : ZMod N) : ℕ :=
  #{xy ∈ s ×ˢ s | xy.1 + xy.2 = a}

/-
The self-convolution of an indicator counts representations as sums.
-/
lemma conv_ind (s : Finset (ZMod N)) (a : ZMod N) :
    conv (ind s) (ind s) a = (count s a : ℂ) := by
  unfold conv ind count;
  rw [ show ( Finset.filter ( fun xy => xy.1 + xy.2 = a ) ( s ×ˢ s ) ) = Finset.image ( fun y => ( y, a - y ) ) ( Finset.filter ( fun y => y ∈ s ∧ a - y ∈ s ) Finset.univ ) from ?_, Finset.card_image_of_injective _ fun x y hxy => by aesop ] ; norm_num [ Finset.sum_ite ];
  · exact congr_arg Finset.card ( by ext; aesop );
  · ext ⟨ x, y ⟩ ; aesop

/-
Additive energy is the sum of squares of representation counts.
-/
lemma addEnergy_eq_sum_count_sq (s : Finset (ZMod N)) :
    (Finset.addEnergy s s : ℝ) = ∑ a, (count s a : ℝ) ^ 2 := by
  norm_cast;
  rw [ Finset.addEnergy_eq_sum_sq ];
  rfl

/-- **Main theorem: additive energy as a fourth Fourier moment.**
For a set `A ⊆ ℤ/Nℤ`, the additive energy `E[A]` equals `N⁻¹` times the fourth moment of the
discrete Fourier transform of its indicator function. -/
theorem addEnergy_eq_dft (s : Finset (ZMod N)) :
    (Finset.addEnergy s s : ℝ) = (N : ℝ)⁻¹ * ∑ k, ‖dft (ind s) k‖ ^ 4 := by
  -- Start from `addEnergy_eq_sum_count_sq s`.
  have h1 : (Finset.addEnergy s s : ℝ) = ∑ a, (count s a : ℝ)^2 :=
    addEnergy_eq_sum_count_sq s
  -- By `conv_ind`, `count s a = ‖conv (ind s) (ind s) a‖`.
  have h2 : (Finset.addEnergy s s : ℝ) = ∑ a, ‖conv (ind s) (ind s) a‖^2 := by
    rw [ h1 ];
    exact Finset.sum_congr rfl fun x hx => by rw [ conv_ind ] ; norm_cast;
  convert congr_arg ( fun x : ℝ => ( N : ℝ ) ⁻¹ * x ) ( ( plancherel ( conv ( ind s ) ( ind s ) ) ) ) using 1;
  · rw [ h2, plancherel, inv_mul_eq_div, mul_div_cancel_left₀ _ ( Nat.cast_ne_zero.mpr <| NeZero.ne N ) ];
  · -- By `dft_conv`, `dft (conv (ind s)(ind s)) k = dft (ind s) k * dft (ind s) k`.
    have h3 : ∀ k, dft (conv (ind s) (ind s)) k = dft (ind s) k * dft (ind s) k :=
      fun k => dft_conv (ind s) (ind s) k
    have := plancherel ( conv ( ind s ) ( ind s ) ) ; simp_all +decide ;
    exact Or.inl ( Eq.trans ( Finset.sum_congr rfl fun _ _ => by ring ) this )

/-! ## A combinatorial corollary: the trivial lower bound on additive energy -/

/-
The Fourier transform of an indicator at the trivial frequency `0` equals the cardinality.
-/
lemma dft_ind_zero (s : Finset (ZMod N)) :
    dft (ind s) 0 = (#s : ℂ) := by
  convert ZMod.dft_apply_zero ( ind s ) using 1;
  unfold ind; aesop;

/-- **Energy lower bound.** The additive energy of any set `A ⊆ ℤ/Nℤ` is at least `|A|⁴ / N`.
This is immediate from `addEnergy_eq_dft`: every spectral term `‖dft 1_A k‖⁴` is nonnegative, so the
sum is at least its `k = 0` term `‖dft 1_A 0‖⁴ = |A|⁴`. -/
theorem card_pow_four_div_le_addEnergy (s : Finset (ZMod N)) :
    (#s : ℝ) ^ 4 / N ≤ (Finset.addEnergy s s : ℝ) := by
  rw [ addEnergy_eq_dft ];
  convert mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun k _ => by positivity : ∀ k : ZMod N, k ∈ Finset.univ → 0 ≤ ‖𝓕 ( ind s ) k‖ ^ 4 ) ( Finset.mem_univ 0 ) ) ( inv_nonneg.2 ( Nat.cast_nonneg N ) ) using 1 ; norm_num [ dft_ind_zero ] ; ring

/-
-- !-- Lab Notes (synthesis) -- !--
OUTCOMES.
  * `stdAddChar_sum_mul` (orthogonality) reduces cleanly to Mathlib's `isPrimitive_stdAddChar`
    plus `AddChar.sum_eq_zero_of_ne_one`; the only subtlety was the strict-implicit binder in
    `AddChar.IsPrimitive` (apply it to the proof `t ≠ 0`, not to `t`).
  * `dft_conv` (convolution theorem): the reindexing `x = y + z` via `Equiv.addRight` plus
    additivity of `stdAddChar` was the crux; `Finset.sum_comm` handles the bookkeeping.
  * `parseval`/`plancherel`: Parseval over ℂ follows from orthogonality; the real `ℓ²` Plancherel
    is obtained by taking real parts (`Complex.mul_conj`, `Complex.normSq_eq_norm_sq`). The
    normalization constant `N` lands on the spectral side (the DFT convention puts `N` on inversion).
  * `addEnergy_eq_dft` (main): assembled from `addEnergy_eq_sum_sq` (Mathlib) + `conv_ind` +
    `plancherel` + `dft_conv`, using `𝓕(1_A ⋆ 1_A) = (𝓕 1_A)²`.
  * `card_pow_four_div_le_addEnergy`: the `k = 0` Fourier mode alone gives the textbook bound
    `E[A] ≥ |A|⁴/N` for free once the main identity is in place.

FAILURE ANALYSIS.
  * A first monolithic attempt at `addEnergy_eq_dft` without the `conv_ind` bridge lemma was
    unwieldy; separating the representation count from the analytic Plancherel step was decisive.
  * `Finset` reindexing tactics are brittle; stating `h_reindex` as an explicit per-`y` identity
    made the convolution theorem tractable.

VERIFICATION.  `#print axioms addEnergy_eq_dft` = [propext, Classical.choice, Quot.sound]; the file
compiles with 0 sorries, 0 errors, 0 warnings.
-- !-- End Lab Notes -- !--
-/

end Catalog.Combinatorics.FourierFiniteGroups