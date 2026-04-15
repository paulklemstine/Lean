/-! # CatalogBuild.Geometry.PAdic.PadicMobius

Auto-generated from theorem catalog database.
Domain: Geometry/PAdic
Declarations: 35
-/

import Mathlib

noncomputable section

/-- A p-adic Möbius transformation is given by a matrix [[a, b], [c, d]] with
coefficients in ℚ_p and nonzero determinant ad - bc ≠ 0. -/
structure PadicMobius (p : ℕ) [Fact (Nat.Prime p)] where
  a : ℚ_[p]
  b : ℚ_[p]
  c : ℚ_[p]
  d : ℚ_[p]
  det_ne_zero : a * d - b * c ≠ 0

namespace PadicMobius

variable {p : ℕ} [hp : Fact (Nat.Prime p)]

/-- The determinant of a Möbius transformation. -/

noncomputable def det (M : PadicMobius p) : ℚ_[p] := M.a * M.d - M.b * M.c

/-- Apply a Möbius transformation to an element of ℚ_p (when the denominator is nonzero). -/

noncomputable def apply (M : PadicMobius p) (z : ℚ_[p]) (h : M.c * z + M.d ≠ 0) : ℚ_[p] :=
  (M.a * z + M.b) / (M.c * z + M.d)

/-- The identity Möbius transformation. -/

noncomputable def id : PadicMobius p where
  a := 1
  b := 0
  c := 0
  d := 1
  det_ne_zero := by simp

/-
Composition of two Möbius transformations (matrix multiplication).
-/

noncomputable def inv (M : PadicMobius p) : PadicMobius p where
  a := M.d
  b := -M.b
  c := -M.c
  d := M.a
  det_ne_zero := by
    convert M.det_ne_zero using 1 ; ring

/-- A translation z ↦ z + t. -/

noncomputable def translation (t : ℚ_[p]) : PadicMobius p where
  a := 1
  b := t
  c := 0
  d := 1
  det_ne_zero := by simp

/-- A scaling z ↦ s·z for s ≠ 0. -/

noncomputable def scaling (s : ℚ_[p]) (hs : s ≠ 0) : PadicMobius p where
  a := s
  b := 0
  c := 0
  d := 1
  det_ne_zero := by simp [hs]

/-- The inversion z ↦ 1/z. -/

noncomputable def inversion : PadicMobius p where
  a := 0
  b := 1
  c := 1
  d := 0
  det_ne_zero := by simp

/-- The determinant of the identity is 1. -/

theorem det_id : (PadicMobius.id : PadicMobius p).det = 1 := by
  unfold det PadicMobius.id; ring

/-- The determinant of a composition is the product of determinants. -/

theorem det_comp (M N : PadicMobius p) :
    (comp M N).det = M.det * N.det := by
  unfold det comp; ring

/-- The determinant of the inverse. -/

theorem det_inv (M : PadicMobius p) :
    (inv M).det = M.det := by
  unfold det inv; ring

/-- The identity acts trivially. -/

theorem apply_id (z : ℚ_[p])
    (h : (PadicMobius.id : PadicMobius p).c * z + PadicMobius.id.d ≠ 0) :
    PadicMobius.id.apply z h = z := by
  unfold apply PadicMobius.id; simp

/-- Translation applies correctly. -/

theorem apply_translation (t z : ℚ_[p])
    (h : (translation t : PadicMobius p).c * z + (translation t).d ≠ 0) :
    (translation t).apply z h = z + t := by
  unfold apply translation; simp

/-- Scaling applies correctly. -/

theorem apply_scaling (s : ℚ_[p]) (hs : s ≠ 0) (z : ℚ_[p])
    (h : (scaling s hs : PadicMobius p).c * z + (scaling s hs).d ≠ 0) :
    (scaling s hs).apply z h = s * z := by
  unfold apply scaling; simp

/-! ## Section 2: Cross-Ratio -/

/-- The p-adic cross-ratio of four points. -/

theorem fixed_point_equation (M : PadicMobius p) (z : ℚ_[p]) (h : M.c * z + M.d ≠ 0) :
    IsFixedPoint M z h ↔ M.c * z ^ 2 + (M.d - M.a) * z - M.b = 0 := by
  unfold PadicMobius.IsFixedPoint;
  unfold PadicMobius.apply;
  grind

/-- The discriminant of the fixed point equation. -/

noncomputable def fixedPointDiscriminant (M : PadicMobius p) : ℚ_[p] :=
  (M.a - M.d) ^ 2 + 4 * M.b * M.c

/-- The trace of a Möbius transformation. -/

noncomputable def trace (M : PadicMobius p) : ℚ_[p] := M.a + M.d

/-- The trace squared relates to the discriminant and determinant. -/

theorem trace_sq_and_discriminant (M : PadicMobius p) :
    M.fixedPointDiscriminant = M.trace ^ 2 - 4 * M.det := by
  unfold fixedPointDiscriminant trace det; ring

/-- A transformation is parabolic iff its discriminant is zero. -/

def isParabolic (M : PadicMobius p) : Prop :=
  M.fixedPointDiscriminant = 0

/-- A parabolic transformation satisfies trace² = 4·det. -/

theorem parabolic_iff_trace (M : PadicMobius p) :
    M.isParabolic ↔ M.trace ^ 2 = 4 * M.det := by
  unfold isParabolic
  rw [trace_sq_and_discriminant]
  constructor
  · intro h; exact sub_eq_zero.mp h
  · intro h; exact sub_eq_zero.mpr h

/-! ## Section 4: Ultrametric Properties -/

/-
The p-adic norm satisfies the ultrametric inequality: ‖x + y‖ ≤ max ‖x‖ ‖y‖.
-/

theorem padic_ultrametric (x y : ℚ_[p]) :
    ‖x + y‖ ≤ max ‖x‖ ‖y‖ := by
  exact Padic.nonarchimedean x y

/-
In p-adic geometry, "all triangles are isosceles": if ‖x‖ ≠ ‖y‖, then
    ‖x + y‖ = max ‖x‖ ‖y‖.
-/

theorem padic_isosceles (x y : ℚ_[p]) (h : ‖x‖ ≠ ‖y‖) :
    ‖x + y‖ = max ‖x‖ ‖y‖ := by
  exact Padic.add_eq_max_of_ne h

/-- The p-adic norm of a product. -/

theorem padic_norm_mul (x y : ℚ_[p]) :
    ‖x * y‖ = ‖x‖ * ‖y‖ :=
  norm_mul x y

/-
For a Möbius transformation with ‖c‖ < ‖d‖, the transformation maps
    the unit disk {z : ‖z‖ ≤ 1} to itself.
-/

theorem mobius_maps_unit_disk (M : PadicMobius p)
    (ha : ‖M.a‖ ≤ 1) (hb : ‖M.b‖ ≤ 1) (hc : ‖M.c‖ < 1) (hd : ‖M.d‖ = 1)
    (z : ℚ_[p]) (hz : ‖z‖ ≤ 1) (hdenom : M.c * z + M.d ≠ 0) :
    ‖M.apply z hdenom‖ ≤ 1 := by
  -- Applying the ultrametric inequality to the numerator and denominator.
  have h_num : ‖(M.a * z + M.b)‖ ≤ max (‖M.a * z‖) (‖M.b‖) := by
    exact padic_ultrametric (M.a * z) M.b
  have h_denom : ‖(M.c * z + M.d)‖ = 1 := by
    have h_denom : ‖M.c * z‖ < 1 := by
      simpa using lt_of_le_of_lt ( mul_le_of_le_one_right ( norm_nonneg _ ) hz ) hc;
    have := padic_isosceles ( M.c * z ) M.d;
    rw [ this ( by linarith ), hd, max_eq_right_of_lt h_denom ];
  simp_all +decide [ PadicMobius.apply, norm_mul ];
  cases h_num <;> nlinarith [ norm_nonneg ( M.a ), norm_nonneg ( M.b ), norm_nonneg z ]

/-! ## Section 5: P-adic Disks and Limit Sets -/

/-- A p-adic disk (closed ball) in ℚ_p. -/

def padicDisk (center : ℚ_[p]) (r : ℝ) : Set ℚ_[p] :=
  {z | ‖z - center‖ ≤ r}

/-
In the p-adic world, two disks are either disjoint or one contains the other.
    This is a fundamental consequence of the ultrametric inequality.
-/

theorem padic_disk_dichotomy (a b : ℚ_[p]) (r s : ℝ) (hr : 0 < r) (hs : 0 < s) :
    Disjoint (padicDisk a r) (padicDisk b s) ∨
    padicDisk a r ⊆ padicDisk b s ∨
    padicDisk b s ⊆ padicDisk a r := by
  have := @IsUltrametricDist.closedBall_subset_trichotomy;
  specialize this a b r s;
  grind

/-- The orbit of a point under iteration of a Möbius transformation. -/

noncomputable def orbit (M : PadicMobius p) (z₀ : ℚ_[p]) : ℕ → ℚ_[p]
  | 0 => z₀
  | n + 1 =>
    let zn := orbit M z₀ n
    if h : M.c * zn + M.d ≠ 0
    then M.apply zn h
    else z₀

/-- The set of accumulation points of an orbit. -/

noncomputable def limitPoint (M : PadicMobius p) (z₀ : ℚ_[p]) : Set ℚ_[p] :=
  {w | ∀ ε > 0, ∃ n : ℕ, n > 0 ∧ ‖orbit M z₀ n - w‖ < ε}

/-! ## Section 6: Conformality and the Derivative -/

/-- The "derivative" of a Möbius transformation at a point z:
    det(M)/(cz+d)². -/

noncomputable def derivative (M : PadicMobius p) (z : ℚ_[p])
    (_h : M.c * z + M.d ≠ 0) : ℚ_[p] :=
  M.det / (M.c * z + M.d) ^ 2

/-
The chain rule for Möbius derivatives.
-/

theorem derivative_comp (M N : PadicMobius p) (z : ℚ_[p])
    (hN : N.c * z + N.d ≠ 0)
    (hMN : (comp M N).c * z + (comp M N).d ≠ 0)
    (hM : M.c * (N.apply z hN) + M.d ≠ 0) :
    derivative (comp M N) z hMN =
      derivative M (N.apply z hN) hM * derivative N z hN := by
  unfold PadicMobius.derivative;
  rw [ div_mul_div_comm, div_eq_div_iff ];
  · unfold PadicMobius.det PadicMobius.comp;
    unfold PadicMobius.apply;
    grind;
  · aesop;
  · aesop

/-
The p-adic norm of the derivative gives the local scaling factor.
-/

theorem norm_derivative (M : PadicMobius p) (z : ℚ_[p]) (h : M.c * z + M.d ≠ 0) :
    ‖derivative M z h‖ = ‖M.det‖ / ‖M.c * z + M.d‖ ^ 2 := by
  unfold PadicMobius.derivative;
  rw [ norm_div, norm_pow ]

/-
A Möbius transformation preserves the p-adic metric up to the derivative factor.
-/

theorem conformal_distortion (M : PadicMobius p)
    (z w : ℚ_[p])
    (hzd : M.c * z + M.d ≠ 0) (hwd : M.c * w + M.d ≠ 0) :
    ‖M.apply z hzd - M.apply w hwd‖ =
      ‖z - w‖ * ‖M.det‖ / (‖M.c * z + M.d‖ * ‖M.c * w + M.d‖) := by
  have h_apply_diff : M.apply z hzd - M.apply w hwd = (M.det * (z - w)) / ((M.c * z + M.d) * (M.c * w + M.d)) := by
    unfold PadicMobius.apply;
    rw [ div_sub_div _ _ hzd hwd ] ; unfold PadicMobius.det ; ring;
  simp_all +decide [ mul_comm, mul_assoc, mul_left_comm, div_eq_mul_inv, mul_inv_rev ]

/-! ## Section 7: The Bruhat-Tits Tree Connection -/

/-- A vertex in the Bruhat-Tits tree is represented by a homothety class
    of ℤ_p-lattices in ℚ_p². We model this abstractly. -/

structure BTVertex (p : ℕ) [Fact (Nat.Prime p)] where
  /-- Representative center in ℚ_p. -/
  center : ℚ_[p]
  /-- The "level" or scale parameter (as a ℤ-valued valuation). -/
  level : ℤ

/-- Two vertices are adjacent in the Bruhat-Tits tree if they differ by one level. -/

def BTAdjacent (v w : BTVertex p) : Prop :=
  (v.level - w.level = 1 ∨ v.level - w.level = -1) ∧
  ‖v.center - w.center‖ ≤ (p : ℝ) ^ (-min v.level w.level)

/-
PGL₂(ℚ_p) acts on the Bruhat-Tits tree, preserving adjacency.
-/

theorem mobius_preserves_bt_adjacency (M : PadicMobius p)
    (v w : BTVertex p) (hadj : BTAdjacent v w)
    (hv : M.c * v.center + M.d ≠ 0) (hw : M.c * w.center + M.d ≠ 0) :
    ∃ v' w' : BTVertex p,
      BTAdjacent v' w' ∧
      v'.center = M.apply v.center hv ∧
      w'.center = M.apply w.center hw := by
  unfold BTAdjacent at *;
  -- Let's denote the transformed centers as $v'$ and $w'$.
  set v' := M.apply v.center hv
  set w' := M.apply w.center hw;
  -- We need to show that the distance between $v'$ and $w'$ is less than or equal to $p^{-\min(v'.level, w'.level)}$.
  have h_dist : ‖v' - w'‖ ≤ (p : ℝ) ^ (-min v.level w.level) * ‖M.det‖ / (‖M.c * v.center + M.d‖ * ‖M.c * w.center + M.d‖) := by
    rw [ conformal_distortion ];
    gcongr ; aesop;
  -- Let's choose the levels of $v'$ and $w'$ such that the distance condition is satisfied.
  obtain ⟨k, hk⟩ : ∃ k : ℤ, ‖M.det‖ / (‖M.c * v.center + M.d‖ * ‖M.c * w.center + M.d‖) ≤ (p : ℝ) ^ k := by
    have h_frac_pow : ∀ x : ℝ, 0 < x → ∃ k : ℤ, x ≤ (p : ℝ) ^ k := by
      intro x hx_pos;
      rcases pow_unbounded_of_one_lt x ( show ( p : ℝ ) > 1 from mod_cast hp.1.one_lt ) with ⟨ k, hk ⟩ ; exact ⟨ k, hk.le ⟩;
    apply h_frac_pow;
    exact div_pos ( norm_pos_iff.mpr ( show M.det ≠ 0 from M.det_ne_zero ) ) ( mul_pos ( norm_pos_iff.mpr hv ) ( norm_pos_iff.mpr hw ) );
  refine' ⟨ ⟨ v', v.level - k ⟩, ⟨ w', w.level - k ⟩, _, rfl, rfl ⟩ ; simp_all +decide [ mul_div_assoc ];
  refine le_trans h_dist ?_;
  refine le_trans ( mul_le_mul_of_nonneg_left hk <| by positivity ) ?_;
  rw [ ← zpow_neg, ← zpow_add₀ ( Nat.cast_ne_zero.mpr hp.1.ne_zero ) ] ; ring_nf ; norm_num;
  rw [ ← zpow_neg ] ; ring_nf ; norm_num


end
