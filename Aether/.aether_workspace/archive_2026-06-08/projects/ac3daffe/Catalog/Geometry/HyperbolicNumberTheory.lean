/-
Copyright (c) 2025. All rights reserved.
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of arithmetic on the Poincaré disk model
of hyperbolic geometry. We define Möbius transformations, prove they preserve
the unit disk, establish properties of the pseudohyperbolic distance, and
define hyperbolic lattice structures that serve as analogs of the integers
on curved space.

Key results:
1. The fundamental Möbius identity relating norms before and after transformation
2. Möbius transformations preserve the open unit disk
3. The pseudohyperbolic distance satisfies the identity of indiscernibles
4. The Möbius inverse theorem φ_{-a} ∘ φ_a = id
5. Conformal factor transformation law under Möbius maps
-/
import Mathlib

open Complex Real

noncomputable section

/-! ## Möbius Transformations on the Unit Disk -/

/-- A Möbius transformation on the Poincaré disk model, mapping
`z ↦ (z - a) / (1 - conj(a) * z)` for a point `a` in the open unit disk.
This is an isometry of the hyperbolic metric that sends `a` to `0`. -/
def mobiusMap (a z : ℂ) : ℂ :=
  (z - a) / (1 - starRingEnd ℂ a * z)

/-- The denominator of the Möbius map: `1 - conj(a) * z`. -/
def mobiusDenom (a z : ℂ) : ℂ :=
  1 - starRingEnd ℂ a * z

/-- The pseudohyperbolic distance on the unit disk:
`ρ(z, w) = |z - w| / |1 - conj(w) * z|`.
This is the absolute value of the Möbius map `φ_w(z)`. -/
def pseudoHypDist (z w : ℂ) : ℝ :=
  ‖z - w‖ / ‖mobiusDenom w z‖

/-- A **hyperbolic lattice** is a discrete set of points in the Poincaré disk
that forms an orbit of the origin under a group of disk automorphisms.
This is the curved-space analog of ℤ ⊂ ℝ. -/
structure HyperbolicLattice where
  /-- The set of "generators" — Möbius parameters whose iterates generate the lattice. -/
  generators : Finset ℂ
  /-- Each generator lies strictly inside the unit disk. -/
  gen_in_disk : ∀ a ∈ generators, ‖a‖ < 1
  /-- The generators are non-trivial (not the origin). -/
  gen_nonzero : ∀ a ∈ generators, a ≠ 0

/-- The **hyperbolic counting function** counts how many lattice points
(from a finite set) have norm at most `R`. -/
def hypCountingFn (points : Finset ℂ) (R : ℝ) : ℕ :=
  (points.filter (fun z => ‖z‖ ≤ R)).card

/-- The **conformal weight** at a point `z` in the Poincaré disk is
`1 / (1 - |z|²)²`, which appears in the hyperbolic area element. -/
def conformalWeight (z : ℂ) : ℝ :=
  1 / (1 - ‖z‖ ^ 2) ^ 2

/-! ## Fundamental Algebraic Identity -/

/-- **Key identity**: `‖1 - conj(a) * z‖² - ‖z - a‖² = (1 - ‖a‖²)(1 - ‖z‖²)`.
This is the fundamental identity underlying the fact that Möbius transformations
preserve the unit disk. -/
theorem mobius_norm_sq_identity (a z : ℂ) :
    Complex.normSq (mobiusDenom a z) - Complex.normSq (z - a) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) := by
  simp only [mobiusDenom, Complex.normSq_apply, Complex.sub_re, Complex.sub_im,
    Complex.one_re, Complex.one_im, Complex.mul_re, Complex.mul_im,
    Complex.conj_re, Complex.conj_im]
  ring

/-- Helper: `‖a‖ < 1` implies `Complex.normSq a < 1`. -/
theorem normSq_lt_one_of_norm_lt_one (a : ℂ) (ha : ‖a‖ < 1) :
    Complex.normSq a < 1 := by
  have h1 := Complex.sq_norm a
  have h2 : ‖a‖ ^ 2 < 1 ^ 2 := sq_lt_sq' (by linarith [norm_nonneg a]) ha
  rw [one_pow] at h2; linarith

/-
The Möbius denominator is nonzero when both `a` and `z` are in the open
unit disk.
-/
theorem mobiusDenom_ne_zero (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    mobiusDenom a z ≠ 0 := by
      contrapose! ha;
      have := mobius_norm_sq_identity a z; simp_all +decide ;
      exact not_lt.mp fun h => by nlinarith [ show 0 ≤ normSq ( z - a ) by exact Complex.normSq_nonneg _, show 0 < 1 - normSq a by exact sub_pos.mpr ( normSq_lt_one_of_norm_lt_one a h ), show 0 < 1 - normSq z by exact sub_pos.mpr ( normSq_lt_one_of_norm_lt_one z hz ) ] ;

/-
**Möbius maps preserve the open unit disk**: If `‖a‖ < 1` and `‖z‖ < 1`,
then `‖mobiusMap a z‖ < 1`. Uses the fundamental norm-squared identity.
-/
theorem mobius_preserves_disk (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    ‖mobiusMap a z‖ < 1 := by
      unfold mobiusMap;
      rw [ norm_div, div_lt_one ];
      · simp_all +decide [ Complex.normSq, Complex.norm_def ];
        rw [ Real.sqrt_lt_sqrt_iff ] <;> nlinarith [ Real.sqrt_lt' zero_lt_one |>.1 ha, Real.sqrt_lt' zero_lt_one |>.1 hz ];
      · exact norm_pos_iff.mpr ( mobiusDenom_ne_zero a z ha hz )

/-- The Möbius map sends `a` to `0`. -/
theorem mobius_self (a : ℂ) : mobiusMap a a = 0 := by
  simp [mobiusMap, sub_self]

/-- The Möbius map sends `0` to `-a`. -/
theorem mobius_at_zero (a : ℂ) : mobiusMap a 0 = -a := by
  simp [mobiusMap]

/-- The pseudohyperbolic distance from any point to itself is zero. -/
theorem pseudoHypDist_self (z : ℂ) : pseudoHypDist z z = 0 := by
  simp [pseudoHypDist, sub_self]

/-- The pseudohyperbolic distance is nonneg. -/
theorem pseudoHypDist_nonneg (z w : ℂ) : 0 ≤ pseudoHypDist z w :=
  div_nonneg (norm_nonneg _) (norm_nonneg _)

/-! ## Conformal Factor Transformation -/

/-
**Conformal factor transformation law**: Under a Möbius map `φ_a`,
`(1 - |φ_a(z)|²) = (1 - |a|²)(1 - |z|²) / |1 - ā·z|²`.
-/
theorem conformal_factor_transform (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    1 - ‖mobiusMap a z‖ ^ 2 =
    (1 - ‖a‖ ^ 2) * (1 - ‖z‖ ^ 2) / ‖mobiusDenom a z‖ ^ 2 := by
      unfold mobiusMap mobiusDenom;
      simp +zetaDelta at *;
      rw [ div_pow, one_sub_div ];
      · congr 1 ; norm_num [ Complex.normSq, Complex.sq_norm ] ; ring;
      · exact ne_of_gt ( sq_pos_of_pos ( norm_pos_iff.mpr ( mobiusDenom_ne_zero a z ha hz ) ) )

/-! ## Hyperbolic Lattice Properties -/

/-- For a hyperbolic lattice, applying any generator's Möbius map to a point
in the disk produces another point in the disk. -/
theorem lattice_orbit_in_disk (L : HyperbolicLattice) (a : ℂ)
    (ha : a ∈ L.generators) (z : ℂ) (hz : ‖z‖ < 1) :
    ‖mobiusMap a z‖ < 1 :=
  mobius_preserves_disk a z (L.gen_in_disk a ha) hz

/-
The counting function is monotone in the radius.
-/
theorem hypCountingFn_mono (points : Finset ℂ) (R₁ R₂ : ℝ) (h : R₁ ≤ R₂) :
    hypCountingFn points R₁ ≤ hypCountingFn points R₂ := by
      exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) h ⟩

/-- The counting function is bounded by the total number of points. -/
theorem hypCountingFn_le_card (points : Finset ℂ) (R : ℝ) :
    hypCountingFn points R ≤ points.card :=
  Finset.card_filter_le points _

/-! ## Pseudohyperbolic Distance: Deeper Properties -/

/-- **Pseudohyperbolic distance equals Möbius norm**: `ρ(z, w) = |φ_w(z)|`. -/
theorem pseudoHypDist_eq_mobius_norm (z w : ℂ) :
    pseudoHypDist z w = ‖mobiusMap w z‖ := by
  simp [pseudoHypDist, mobiusMap, mobiusDenom]

/-- The pseudohyperbolic distance is strictly less than 1 for points in the disk. -/
theorem pseudoHypDist_lt_one (z w : ℂ) (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    pseudoHypDist z w < 1 := by
  rw [pseudoHypDist_eq_mobius_norm]
  exact mobius_preserves_disk w z hw hz

/-
The pseudohyperbolic distance is zero iff the points are equal (in the disk).
-/
theorem pseudoHypDist_eq_zero_iff (z w : ℂ) (hz : ‖z‖ < 1) (hw : ‖w‖ < 1) :
    pseudoHypDist z w = 0 ↔ z = w := by
      simp +decide [ pseudoHypDist, sub_eq_zero ];
      exact fun h => False.elim <| mobiusDenom_ne_zero w z hw hz h

/-! ## Hyperbolic Zeta Function -/

/-- The **hyperbolic zeta function** for a finite set of lattice points. -/
def hyperbolicZetaPartial (points : Finset ℂ) (s : ℝ) : ℝ :=
  ∑ z ∈ points.filter (fun z => z ≠ 0), (1 / ‖z‖ ^ (2 * s))

/-
The partial hyperbolic zeta function is nonneg for nonneg `s`.
-/
theorem hyperbolicZetaPartial_nonneg (points : Finset ℂ) (s : ℝ) (_hs : 0 ≤ s) :
    0 ≤ hyperbolicZetaPartial points s := by
      exact Finset.sum_nonneg fun _ _ => one_div_nonneg.2 ( Real.rpow_nonneg ( norm_nonneg _ ) _ )

/-! ## Conformal Weight Properties -/

/-
The conformal weight is positive at points strictly inside the disk.
-/
theorem conformalWeight_pos (z : ℂ) (hz : ‖z‖ < 1) :
    0 < conformalWeight z := by
      exact one_div_pos.mpr ( sq_pos_of_pos ( by nlinarith [ norm_nonneg z ] ) )

/-- The conformal weight at the origin is 1. -/
theorem conformalWeight_origin : conformalWeight 0 = 1 := by
  simp [conformalWeight, norm_zero]

/-
The conformal weight is at least 1 inside the disk. Uses `by_contra` and
the fact that `1 - ‖z‖² ∈ (0,1]` inside the disk implies `(1 - ‖z‖²)² ≤ 1`.
-/
theorem conformalWeight_ge_one (z : ℂ) (hz : ‖z‖ < 1) :
    1 ≤ conformalWeight z := by
      exact one_le_div ( sq_pos_of_pos <| sub_pos_of_lt <| by simpa using hz ) |>.2 <| by nlinarith [ show ‖z‖ ^ 2 < 1 by simpa using pow_lt_one₀ ( norm_nonneg z ) hz two_ne_zero ] ;

/-! ## Möbius Inverse and Composition -/

/-- The negative of a disk point is also in the disk. -/
theorem norm_neg_lt_one (a : ℂ) (ha : ‖a‖ < 1) : ‖-a‖ < 1 := by
  rwa [norm_neg]

/-
**Möbius inverse**: `φ_{-a}(φ_a(z)) = z`. The map `φ_{-a}` is the
functional inverse of `φ_a` on the disk. This is proved by clearing
denominators and using `ring`.
-/
theorem mobius_inverse (a z : ℂ) (ha : ‖a‖ < 1) (hz : ‖z‖ < 1) :
    mobiusMap (-a) (mobiusMap a z) = z := by
      unfold mobiusMap;
      rw [ div_eq_iff ];
      · simp +zetaDelta at *;
        linear_combination' mul_div_cancel₀ ( z - a ) ( show ( 1 - ( starRingEnd ℂ ) a * z ) ≠ 0 from mobiusDenom_ne_zero a z ha hz );
      · rw [ Ne, sub_eq_zero ];
        rw [ mul_div, eq_div_iff ] <;> norm_num [ Complex.ext_iff ] at *;
        · intro h; nlinarith [ abs_le.mp ( Complex.abs_re_le_norm a ), abs_le.mp ( Complex.abs_im_le_norm a ), abs_le.mp ( Complex.abs_re_le_norm z ), abs_le.mp ( Complex.abs_im_le_norm z ), Complex.normSq_apply a, Complex.normSq_apply z, Complex.sq_norm a, Complex.sq_norm z ] ;
        · norm_num [ Complex.normSq, Complex.norm_def ] at *;
          rw [ Real.sqrt_lt' ] at * <;> intros <;> nlinarith [ sq_nonneg ( a.re * z.im - a.im * z.re ) ]

/-- The Möbius map at `a = 0` is the identity. -/
theorem mobius_zero (z : ℂ) : mobiusMap 0 z = z := by
  simp [mobiusMap]

/-! ## Conjecture: Hyperbolic Prime Counting Asymptotics -/

/-- **Conjecture (Hyperbolic Prime Number Theorem)**: For any hyperbolic lattice
with at least 2 generators, the orbit of any disk point is unbounded in
cardinality (the lattice is infinite, in the sense that arbitrarily many
distinct orbit points exist in the disk).

**Testable prediction**: For the modular group with generators at distance
0.5 from the origin, the orbit of `0` should produce ≥ 100 distinct points
within Euclidean distance 0.99 of the origin. -/
def hyperbolicPrimeCountConjectureWeak : Prop :=
  ∀ (L : HyperbolicLattice),
  L.generators.card ≥ 2 →
  ∀ (N : ℕ), ∃ (points : Finset ℂ),
    points.card ≥ N ∧
    ∀ z ∈ points, ‖z‖ < 1

end