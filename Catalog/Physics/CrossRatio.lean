import Algebra.BerggrenPhotonic.Defs

/-! # Cross-Ratio Invariance under Möbius Transformations

This module proves the fundamental theorem: the cross-ratio of four points is
invariant under Möbius transformations. This is the algebraic heart of the
Berggren–Photonic correspondence.

## Key Results

- `moebius_diff`: The difference of two Möbius-transformed points factors as
  `(ad - bc)(z - w) / ((cz + d)(cw + d))`.
- `cross_ratio_moebius_real`: Cross-ratio is invariant under Möbius transformations
  with nonzero determinant.
-/

noncomputable section



/-! ## Möbius Difference Lemma -/

/-
The difference of Möbius transforms factors cleanly: the numerator picks up the
    determinant factor `(ad - bc)`, while the denominator is the product of the
    individual denominators. This factorization is the key to cross-ratio invariance.
-/
theorem moebius_diff (a b c d z w : ℝ)
    (hz : c * z + d ≠ 0) (hw : c * w + d ≠ 0) :
    moebiusReal a b c d z - moebiusReal a b c d w =
    (a * d - b * c) * (z - w) / ((c * z + d) * (c * w + d)) := by
  unfold moebiusReal; rw [ div_sub_div ] <;> ring <;> aesop;

/-! ## Cross-Ratio Invariance -/

/-
**Cross-ratio is invariant under Möbius transformations.**

    For any Möbius transformation `z ↦ (az + b)/(cz + d)` with `ad - bc ≠ 0`,
    the cross-ratio of four points is preserved. This is the fundamental theorem
    of projective geometry restricted to the real projective line.
-/
theorem cross_ratio_moebius_real (a b c d z₁ z₂ z₃ z₄ : ℝ)
    (hdet : a * d - b * c ≠ 0)
    (h1 : c * z₁ + d ≠ 0) (h2 : c * z₂ + d ≠ 0)
    (h3 : c * z₃ + d ≠ 0) (h4 : c * z₄ + d ≠ 0)
    (h14 : z₁ ≠ z₄) (h23 : z₂ ≠ z₃) :
    cross_ratio (moebiusReal a b c d z₁) (moebiusReal a b c d z₂)
                (moebiusReal a b c d z₃) (moebiusReal a b c d z₄) =
    cross_ratio z₁ z₂ z₃ z₄ := by
  unfold cross_ratio moebiusReal;
  field_simp;
  rw [ div_eq_div_iff ];
  · grind;
  · grind;
  · exact mul_ne_zero ( sub_ne_zero_of_ne h14 ) ( sub_ne_zero_of_ne h23 )

/-- Cross-ratio invariance for integer matrix Möbius transformations. -/
theorem cross_ratio_moebius (M : Matrix (Fin 2) (Fin 2) ℤ)
    (z₁ z₂ z₃ z₄ : ℝ)
    (hdet : (M 0 0 : ℝ) * (M 1 1 : ℝ) - (M 0 1 : ℝ) * (M 1 0 : ℝ) ≠ 0)
    (h1 : (M 1 0 : ℝ) * z₁ + (M 1 1 : ℝ) ≠ 0)
    (h2 : (M 1 0 : ℝ) * z₂ + (M 1 1 : ℝ) ≠ 0)
    (h3 : (M 1 0 : ℝ) * z₃ + (M 1 1 : ℝ) ≠ 0)
    (h4 : (M 1 0 : ℝ) * z₄ + (M 1 1 : ℝ) ≠ 0)
    (h14 : z₁ ≠ z₄) (h23 : z₂ ≠ z₃) :
    cross_ratio (moebius M z₁) (moebius M z₂)
                (moebius M z₃) (moebius M z₄) =
    cross_ratio z₁ z₂ z₃ z₄ := by
  unfold moebius
  exact cross_ratio_moebius_real _ _ _ _ _ _ _ _ hdet h1 h2 h3 h4 h14 h23

end