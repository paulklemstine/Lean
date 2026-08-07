/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Geometry.RischResidueLiouville

/-!
# Elementary integration of every rational function with split rational denominator

`Catalog/Geometry/RischResidueLiouville.lean` handles a *squarefree* split denominator
through the residue criterion.  This file removes the squarefreeness restriction and
proves the full Hermite-reduction statement in the catalog's EML syntax:

> If `D : ℚ[X]` is nonzero and splits into linear factors over `ℚ`, then for every
> numerator `p : ℚ[X]` there is an EML expression `F` with
> `F' (x) = p(x) / D(x)` at every real point where `D` does not vanish.

The proof is a two-level induction which mirrors the classical Hermite reduction:

* `singlePole_integrable` — induction on the pole order `m`, peeling one factor
  `X - a` off the numerator at a time.  The pieces produced are exactly the catalog's
  `LogarithmicPiece` (order one) and `HigherPolePiece` (order at least two), so the
  certified primitives of `EMLRisch` are reused verbatim.
* `splitDenominator_integrable` — strong induction on `deg D`.  Writing
  `D = (X - a)^m * H` with `H(a) ≠ 0` and `H = H(a) + (X - a) * H₁`, the identity
  `1/((x-a)^m H) = 1/(H(a)(x-a)^m) - H₁/(H(a)(x-a)^{m-1} H)`
  splits the problem into a single-pole part and a strictly smaller denominator.

This is the "canonical partial-fraction normalization" conjecture of the catalog's
future-directions list, in the case where the denominator splits over `ℚ`; the
non-split case genuinely needs an algebraic extension and is left open.
-/

noncomputable section

open Polynomial EMLDifferentialClosure

namespace RischSplit

/-! ## Expression-level combinators -/

/-- Difference of two catalog expressions. -/
def subExpr (F G : EMLRisch.Expr) : EMLRisch.Expr :=
  .add F (.mul (.const (-1)) G)

theorem hasDerivAt_addExpr {F G : EMLRisch.Expr} {u v x : ℝ}
    (hF : HasDerivAt (Expr.eval F) u x) (hG : HasDerivAt (Expr.eval G) v x) :
    HasDerivAt (Expr.eval (.add F G)) (u + v) x := by
  have h : Expr.eval (.add F G) = fun y => Expr.eval F y + Expr.eval G y := rfl
  rw [h]
  exact hF.add hG

theorem hasDerivAt_subExpr {F G : EMLRisch.Expr} {u v x : ℝ}
    (hF : HasDerivAt (Expr.eval F) u x) (hG : HasDerivAt (Expr.eval G) v x) :
    HasDerivAt (Expr.eval (subExpr F G)) (u - v) x := by
  have h : Expr.eval (subExpr F G) = fun y => Expr.eval F y + (-1) * Expr.eval G y := rfl
  rw [h, sub_eq_add_neg]
  exact hF.add (by simpa using hG.const_mul (-1 : ℝ))

/-! ## Antiderivatives of polynomials -/

/-- Every rational polynomial has a polynomial antiderivative. -/
theorem poly_antiderivative (p : ℚ[X]) : ∃ q : ℚ[X], derivative q = p := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq =>
    obtain ⟨qp, hqp⟩ := hp
    obtain ⟨qq, hqq⟩ := hq
    exact ⟨qp + qq, by simp [hqp, hqq]⟩
  | monomial n a =>
    refine ⟨C (a / (n + 1)) * X ^ (n + 1), ?_⟩
    simp only [derivative_mul, derivative_C, zero_mul, zero_add, derivative_X_pow,
      Nat.add_sub_cancel, ← mul_assoc, ← C_mul, ← C_mul_X_pow_eq_monomial]
    congr 2
    push_cast
    field_simp

/-- A polynomial integrand has an EML primitive, valid at every real point. -/
theorem poly_integrable (p : ℚ[X]) :
    ∃ F : EMLRisch.Expr, ∀ x : ℝ, HasDerivAt (Expr.eval F) (aeval x p) x := by
  obtain ⟨q, hq⟩ := poly_antiderivative p
  refine ⟨RischResidue.polyExpr q, fun x => ?_⟩
  have hfun : Expr.eval (RischResidue.polyExpr q) = fun y : ℝ => (aeval y q : ℝ) :=
    funext fun y => RischResidue.eval_polyExpr q y
  rw [hfun]
  set Q : ℝ[X] := q.map (algebraMap ℚ ℝ) with hQ
  have hQe : ∀ y : ℝ, (aeval y q : ℝ) = Q.eval y := by
    intro y; simp [hQ, aeval_def, eval_map]
  have hd : (derivative Q).eval x = (aeval x (derivative q) : ℝ) := by
    simp [hQ, Polynomial.derivative_map, aeval_def, eval_map]
  simp only [hQe]
  rw [← hq, ← hd]
  exact Q.hasDerivAt x

/-! ## A single split pole of arbitrary order -/

/-- **Hermite reduction at one pole.**  For every numerator `p`, pole `a` and order `m`
there is an EML primitive of `p(x)/(x-a)^m`, valid off the pole. -/
theorem singlePole_integrable (a : ℚ) :
    ∀ (m : ℕ) (p : ℚ[X]), ∃ F : EMLRisch.Expr, ∀ x : ℝ, x ≠ (a : ℝ) →
      HasDerivAt (Expr.eval F) ((aeval x p : ℝ) / (x - (a : ℝ)) ^ m) x := by
  intro m
  induction m with
  | zero =>
    intro p
    obtain ⟨F, hF⟩ := poly_integrable p
    exact ⟨F, fun x _ => by simpa using hF x⟩
  | succ m ih =>
    intro p
    -- split off the value at the pole
    obtain ⟨p₁, hp₁⟩ : ∃ p₁ : ℚ[X], p = (X - C a) * p₁ + C (p.eval a) := by
      refine ⟨p /ₘ (X - C a), ?_⟩
      have hmod := Polynomial.modByMonic_add_div p (Polynomial.monic_X_sub_C a)
      rw [Polynomial.modByMonic_X_sub_C_eq_C_eval] at hmod
      linear_combination -hmod
    obtain ⟨F₁, hF₁⟩ := ih p₁
    -- the pure pole term, taken from the catalog's certified pieces
    obtain ⟨G, hG⟩ : ∃ G : EMLRisch.Expr, ∀ x : ℝ, x ≠ (a : ℝ) →
        HasDerivAt (Expr.eval G) (((p.eval a : ℚ) : ℝ) / (x - (a : ℝ)) ^ (m + 1)) x := by
      match m with
      | 0 =>
        refine ⟨(⟨p.eval a, a⟩ : EMLRisch.LogarithmicPiece).primitive, fun x hx => ?_⟩
        have h := EMLRisch.LogarithmicPiece.hasDerivAt_primitive ⟨p.eval a, a⟩ hx
        convert h using 1
        simp [EMLRisch.LogarithmicPiece.integrand, EMLRisch.Expr.qsmul, EMLRisch.Expr.shift,
          Expr.eval, div_eq_mul_inv, sub_eq_add_neg]
      | (k + 1) =>
        refine ⟨(⟨p.eval a, a, k⟩ : EMLRisch.HigherPolePiece).primitive, fun x hx => ?_⟩
        have h := EMLRisch.HigherPolePiece.hasDerivAt_primitive ⟨p.eval a, a, k⟩ hx
        convert h using 1
        simp [EMLRisch.HigherPolePiece.integrand, EMLRisch.HigherPolePiece.order,
          EMLRisch.Expr.qsmul, EMLRisch.Expr.shift, Expr.eval, div_eq_mul_inv, sub_eq_add_neg]
    refine ⟨.add F₁ G, fun x hx => ?_⟩
    have hsub : x - (a : ℝ) ≠ 0 := sub_ne_zero.mpr hx
    have hcomb := hasDerivAt_addExpr (hF₁ x hx) (hG x hx)
    convert hcomb using 1
    have : (aeval x p : ℝ)
        = (x - (a : ℝ)) * (aeval x p₁ : ℝ) + ((p.eval a : ℚ) : ℝ) := by
      conv_lhs => rw [hp₁]
      simp
    rw [this]
    field_simp
    ring

/-! ## Arbitrary split denominators -/

/-- The constant-denominator case. -/
theorem constant_denominator_integrable (D : ℚ[X]) (hD0 : D ≠ 0) (hdeg : D.natDegree = 0)
    (p : ℚ[X]) :
    ∃ F : EMLRisch.Expr, ∀ x : ℝ,
      HasDerivAt (Expr.eval F) ((aeval x p : ℝ) / (aeval x D : ℝ)) x := by
  obtain ⟨d, rfl⟩ : ∃ d, D = C d := ⟨D.coeff 0, Polynomial.eq_C_of_natDegree_eq_zero hdeg⟩
  have hd : d ≠ 0 := fun h => hD0 (by simp [h])
  obtain ⟨F, hF⟩ := poly_integrable (C d⁻¹ * p)
  refine ⟨F, fun x => ?_⟩
  convert hF x using 1
  simp only [map_mul, aeval_C, eq_ratCast, Rat.cast_inv]
  field_simp

/-- **Every rational function with split rational denominator is elementarily
integrable**, with an explicit EML primitive valid wherever the denominator is nonzero. -/
theorem splitDenominator_integrable :
    ∀ (n : ℕ) (D : ℚ[X]), D.natDegree ≤ n → D ≠ 0 → D.Splits →
      ∀ p : ℚ[X], ∃ F : EMLRisch.Expr, ∀ x : ℝ, (aeval x D : ℝ) ≠ 0 →
        HasDerivAt (Expr.eval F) ((aeval x p : ℝ) / (aeval x D : ℝ)) x := by
  intro n
  induction n with
  | zero =>
    intro D hDn hD0 _ p
    obtain ⟨F, hF⟩ := constant_denominator_integrable D hD0 (Nat.le_zero.mp hDn) p
    exact ⟨F, fun x _ => hF x⟩
  | succ n ih =>
    intro D hDn hD0 hsp p
    by_cases hdeg : D.natDegree = 0
    · obtain ⟨F, hF⟩ := constant_denominator_integrable D hD0 hdeg p
      exact ⟨F, fun x _ => hF x⟩
    have hdegne : D.degree ≠ 0 := by
      intro hd
      exact hdeg (Polynomial.natDegree_eq_zero_iff_degree_le_zero.mpr (le_of_eq hd))
    obtain ⟨a, ha⟩ := hsp.exists_eval_eq_zero hdegne
    set m := D.rootMultiplicity a with hm
    have hmpos : 0 < m := (Polynomial.rootMultiplicity_pos hD0).mpr ha
    obtain ⟨j, hj⟩ : ∃ j, m = j + 1 := ⟨m - 1, by omega⟩
    set H := D /ₘ (X - C a) ^ m with hHdef
    have hDeq : D = (X - C a) ^ m * H :=
      (Polynomial.pow_mul_divByMonic_rootMultiplicity_eq D a).symm
    have hH0 : H.eval a ≠ 0 :=
      Polynomial.eval_divByMonic_pow_rootMultiplicity_ne_zero a hD0
    have hHne : H ≠ 0 := fun h => hH0 (by simp [h])
    set H₁ := H /ₘ (X - C a) with hH₁def
    have hHsplit : H = C (H.eval a) + (X - C a) * H₁ := by
      have hmod := Polynomial.modByMonic_add_div H (Polynomial.monic_X_sub_C a)
      rw [Polynomial.modByMonic_X_sub_C_eq_C_eval] at hmod
      linear_combination -hmod
    set D' := (X - C a) ^ j * H with hD'def
    have hD'0 : D' ≠ 0 := mul_ne_zero (pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)) hHne
    have hHdvd : H ∣ D := ⟨(X - C a) ^ m, by rw [hDeq]; ring⟩
    have hD'split : D'.Splits :=
      ((Polynomial.Splits.X_sub_C a).pow j).mul (hsp.of_dvd hD0 hHdvd)
    have hdegD : D.natDegree = m + H.natDegree := by
      rw [hDeq, Polynomial.natDegree_mul (pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)) hHne,
        Polynomial.natDegree_pow, Polynomial.natDegree_X_sub_C, mul_one]
    have hD'deg : D'.natDegree ≤ n := by
      rw [hD'def, Polynomial.natDegree_mul (pow_ne_zero _ (Polynomial.X_sub_C_ne_zero a)) hHne,
        Polynomial.natDegree_pow, Polynomial.natDegree_X_sub_C, mul_one]
      omega
    obtain ⟨F₁, hF₁⟩ := singlePole_integrable a m (C (H.eval a)⁻¹ * p)
    obtain ⟨F₂, hF₂⟩ := ih D' hD'deg hD'0 hD'split (C (H.eval a)⁻¹ * p * H₁)
    refine ⟨subExpr F₁ F₂, fun x hx => ?_⟩
    have hDx : (aeval x D : ℝ) = (x - (a : ℝ)) ^ m * (aeval x H : ℝ) := by
      conv_lhs => rw [hDeq]
      simp
    have hu : x - (a : ℝ) ≠ 0 := by
      intro h
      apply hx
      rw [hDx, h, zero_pow (by omega), zero_mul]
    have hax : x ≠ (a : ℝ) := fun h => hu (by rw [h, sub_self])
    have hHx : (aeval x H : ℝ) ≠ 0 := by
      intro h
      apply hx
      rw [hDx, h, mul_zero]
    have hD'x : (aeval x D' : ℝ) = (x - (a : ℝ)) ^ j * (aeval x H : ℝ) := by
      rw [hD'def]
      simp
    have hD'ne : (aeval x D' : ℝ) ≠ 0 := by
      rw [hD'x]
      exact mul_ne_zero (pow_ne_zero _ hu) hHx
    have hcomb := hasDerivAt_subExpr (hF₁ x hax) (hF₂ x hD'ne)
    convert hcomb using 1
    have hHval : (aeval x H : ℝ)
        = ((H.eval a : ℚ) : ℝ) + (x - (a : ℝ)) * (aeval x H₁ : ℝ) := by
      conv_lhs => rw [hHsplit]
      simp
    have hh : ((H.eval a : ℚ) : ℝ) ≠ 0 := by exact_mod_cast hH0
    have e1 : (aeval x (C (H.eval a)⁻¹ * p) : ℝ)
        = ((H.eval a : ℚ) : ℝ)⁻¹ * (aeval x p : ℝ) := by
      simp only [map_mul, aeval_C, eq_ratCast, Rat.cast_inv]
    have e2 : (aeval x (C (H.eval a)⁻¹ * p * H₁) : ℝ)
        = ((H.eval a : ℚ) : ℝ)⁻¹ * (aeval x p : ℝ) * (aeval x H₁ : ℝ) := by
      simp only [map_mul, aeval_C, eq_ratCast, Rat.cast_inv]
    rw [hDx, hD'x, e1, e2, hj]
    rw [hHval]
    have huj : (x - (a : ℝ)) ^ (j + 1) = (x - (a : ℝ)) * (x - (a : ℝ)) ^ j := by ring
    rw [huj]
    have hHx' : ((H.eval a : ℚ) : ℝ) + (x - (a : ℝ)) * (aeval x H₁ : ℝ) ≠ 0 := by
      rw [← hHval]; exact hHx
    field_simp
    ring

/-- Packaged version: the primitive lies in the catalog's EML class. -/
theorem split_rational_has_EML_primitive (D : ℚ[X]) (hD : D ≠ 0)
    (hsplit : D.Splits) (p : ℚ[X]) :
    ∃ F : EMLRisch.Expr, IsEML (Expr.eval F) ∧
      ∀ x : ℝ, (aeval x D : ℝ) ≠ 0 →
        HasDerivAt (Expr.eval F) ((aeval x p : ℝ) / (aeval x D : ℝ)) x := by
  obtain ⟨F, hF⟩ := splitDenominator_integrable D.natDegree D le_rfl hD hsplit p
  exact ⟨F, ⟨F, rfl⟩, hF⟩

/-! ## Worked examples and the boundary of the splitting hypothesis -/

/-- For `1 / (x (x-1))` the residue at `0` is `-1`. -/
theorem residue_example_zero : RischResidue.residue {0, 1} (C 1) 0 = -1 := by
  rw [RischResidue.residue]
  norm_num [show ({0, 1} : Finset ℚ).erase 0 = {1} by decide]

/-- For `1 / (x (x-1))` the residue at `1` is `1`; the two residues sum to zero, as they
must for a rational function decaying like `x⁻²`. -/
theorem residue_example_one : RischResidue.residue {0, 1} (C 1) 1 = 1 := by
  rw [RischResidue.residue]
  norm_num [show ({0, 1} : Finset ℚ).erase 1 = {0} by decide]

/-- The splitting hypothesis is a genuine restriction: `x² + 1` does not split over `ℚ`,
so `splitDenominator_integrable` does not cover `1 / (x² + 1)`.  This marks exactly where
an algebraic extension of the constant field becomes necessary. -/
theorem not_splits_X_sq_add_one : ¬ ((X ^ 2 + C 1 : ℚ[X]).Splits) := by
  intro h
  obtain ⟨a, ha⟩ := h.exists_eval_eq_zero (by
    rw [Polynomial.degree_X_pow_add_C (by norm_num) (1 : ℚ)]
    norm_num)
  simp at ha
  nlinarith [sq_nonneg a]

end RischSplit