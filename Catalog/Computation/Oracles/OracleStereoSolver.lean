/-! # CatalogBuild.Computation.Oracles.OracleStereoSolver

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 42
-/

import Mathlib

noncomputable section

/-- An oracle is an idempotent endomorphism. Consulting twice = consulting once. -/
structure SolverOracle (X : Type*) where
  apply : X → X
  idempotent : ∀ x, apply (apply x) = apply x


/-- The truth set (fixed points) of an oracle — the "frozen solution crystal." -/
def SolverOracle.truthSet {X : Type*} (O : SolverOracle X) : Set X :=
  {x | O.apply x = x}


/-- The identity oracle: everything is already a solution. -/
def SolverOracle.trivial (X : Type*) : SolverOracle X where
  apply := id
  idempotent _ := rfl


/-- A constant oracle: projects everything to a single solution. -/
def SolverOracle.constant {X : Type*} (c : X) : SolverOracle X where
  apply := fun _ => c
  idempotent _ := rfl


/-- **Theorem 1.1**: Every oracle output is a fixed point (a truth). -/
theorem SolverOracle.output_is_fixed {X : Type*} (O : SolverOracle X) (x : X) :
    O.apply x ∈ O.truthSet := by
  simp [SolverOracle.truthSet, O.idempotent]


/-- **Theorem 1.2**: The range of an oracle equals its truth set. -/
theorem SolverOracle.range_eq_truth {X : Type*} (O : SolverOracle X) :
    range O.apply = O.truthSet := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact O.output_is_fixed x
  · intro hy; exact ⟨y, hy⟩


theorem SolverOracle.iterate_stable {X : Type*} (O : SolverOracle X)
    (n : ℕ) (hn : 1 ≤ n) : O.apply^[n] = O.apply := by
  induction hn <;> simp_all +decide [ Function.iterate_succ_apply' ];
  exact funext O.idempotent


/-- **Theorem 1.4**: The truth set of a constant oracle is a singleton. -/
theorem SolverOracle.constant_truth {X : Type*} (c : X) :
    (SolverOracle.constant c).truthSet = {c} := by
  ext x; simp [SolverOracle.truthSet, SolverOracle.constant]


/-- Inverse stereographic projection: ℝ → S¹ ⊂ ℝ² -/
def invStereoProj (t : ℝ) : ℝ × ℝ :=
  (2 * t / (1 + t ^ 2), (1 - t ^ 2) / (1 + t ^ 2))


/-- **Theorem 2.1**: Inverse stereo always maps to the unit circle. -/
theorem invStereoProj_on_circle (t : ℝ) :
    (invStereoProj t).1 ^ 2 + (invStereoProj t).2 ^ 2 = 1 := by
  simp only [invStereoProj]
  have h : (1 : ℝ) + t ^ 2 ≠ 0 := by positivity
  field_simp
  ring


/-- **Theorem 2.3 (Oracle-Stereo Round-Trip)**: The stereographic round-trip
is the identity — no information is lost. -/
theorem oracle_stereo_roundtrip (t : ℝ) :
    stereoProj (invStereoProj t) = t := by
  simp only [stereoProj, invStereoProj]
  have h : (1 : ℝ) + t ^ 2 > 0 := by positivity
  have hne : (1 : ℝ) + t ^ 2 ≠ 0 := ne_of_gt h
  field_simp
  ring


/-- **Theorem 2.4**: The y-coordinate of invStereo is bounded above by 1. -/
theorem invStereo_y_le_one (t : ℝ) : (invStereoProj t).2 ≤ 1 := by
  simp only [invStereoProj]
  have h : (0 : ℝ) < 1 + t ^ 2 := by positivity
  rw [div_le_one h]
  linarith [sq_nonneg t]


theorem invStereo_y_ge_neg_one (t : ℝ) : -1 ≤ (invStereoProj t).2 := by
  exact ( by rw [ invStereoProj ] ; rw [ le_div_iff₀ ] <;> nlinarith )


/-- **Theorem 2.6**: At t=0, invStereo gives the "north pole" (0,1). -/
theorem invStereo_at_zero : invStereoProj 0 = (0, 1) := by
  simp [invStereoProj]


/-- **Theorem 2.7**: At t=1, invStereo gives (1,0). -/
theorem invStereo_at_one : invStereoProj 1 = (1, 0) := by
  unfold invStereoProj; norm_num


/-- A Pythagorean triple (a, b, c) satisfies a² + b² = c². -/
def IsPythagoreanTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2


/-- **Theorem 3.1 (The Rational Oracle)**: For any integers p, q,
(2pq, q²-p², p²+q²) is a Pythagorean triple. -/
theorem rational_stereo_pythagorean (p q : ℤ) :
    IsPythagoreanTriple (2 * p * q) (q ^ 2 - p ^ 2) (p ^ 2 + q ^ 2) := by
  simp only [IsPythagoreanTriple]; ring


/-- **Theorem 3.3**: The (5,12,13) triple. -/
theorem pythagorean_51213 : IsPythagoreanTriple 5 12 13 := by
  simp only [IsPythagoreanTriple]; norm_num


/-- **Theorem 3.4**: The (8,15,17) triple. -/
theorem pythagorean_81517 : IsPythagoreanTriple 8 15 17 := by
  simp only [IsPythagoreanTriple]; norm_num


/-- **Theorem 3.5**: The (7,24,25) triple. -/
theorem pythagorean_72425 : IsPythagoreanTriple 7 24 25 := by
  simp only [IsPythagoreanTriple]; norm_num


/-- **Theorem 3.6 (Universality)**: The parametrization identity. -/
theorem pythagorean_parametrization_complete (m n : ℤ) :
    (2 * m * n) ^ 2 + (m ^ 2 - n ^ 2) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  ring


/-- **Theorem 3.7 (Sum of Two Squares Primes ≤ 100)**: 12 such primes. -/
theorem sum_two_squares_primes_count :
    (Finset.filter (fun p => Nat.Prime p ∧ (p % 4 = 1 ∨ p = 2))
      (Finset.range 101)).card = 12 := by native_decide


/-- **Experiment 1**: The Pythagorean identity holds for all small parameters. -/
theorem experiment_pythagorean_batch :
    ∀ p q : Fin 10,
      (2 * (p : ℤ) * q) ^ 2 + ((q : ℤ) ^ 2 - (p : ℤ) ^ 2) ^ 2 =
      ((p : ℤ) ^ 2 + (q : ℤ) ^ 2) ^ 2 := by
  intro p q; ring


/-- **Experiment 2**: The oracle-stereo roundtrip is exact at rationals. -/
theorem experiment_roundtrip (p q : ℤ) (hq : (q : ℝ) ≠ 0) :
    stereoProj (invStereoProj ((p : ℝ) / q)) = (p : ℝ) / q :=
  oracle_stereo_roundtrip _


/-- **Theorem 5.1 (Crystallization at Integers)**: sin(πn) = 0 for n ∈ ℤ. -/
theorem crystallization_integers (n : ℤ) : Real.sin (π * ↑n) = 0 := by
  rw [mul_comm]; exact sin_int_mul_pi n


/-- **Theorem 5.2**: Lattice points on x²+y²=25. -/
theorem lattice_point_25 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 25)
      (Finset.Icc (-5) 5 ×ˢ Finset.Icc (-5) 5)).card = 12 := by native_decide


/-- **Theorem 5.3**: Lattice points on x²+y²=1. -/
theorem lattice_point_1 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 1)
      (Finset.Icc (-1) 1 ×ˢ Finset.Icc (-1) 1)).card = 4 := by native_decide


/-- **Theorem 5.4**: r₂(3) = 0 — 3 is not a sum of two squares. -/
theorem no_lattice_points_3 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 3)
      (Finset.Icc (-2) 2 ×ˢ Finset.Icc (-2) 2)).card = 0 := by native_decide


/-- **Theorem 5.5**: r₂(5) = 8. -/
theorem lattice_points_5 :
    (Finset.filter (fun p : ℤ × ℤ => p.1 ^ 2 + p.2 ^ 2 = 5)
      (Finset.Icc (-3) 3 ×ˢ Finset.Icc (-3) 3)).card = 8 := by native_decide


/-- **Theorem 6.1**: The identity Möbius transform. -/
theorem mobius_identity (x : ℝ) : mobiusTransform 1 0 0 1 x = x := by
  simp [mobiusTransform]


theorem mobius_inversion_involution (x : ℝ) (hx : x ≠ 0) :
    mobiusTransform 0 1 1 0 (mobiusTransform 0 1 1 0 x) = x := by
  unfold mobiusTransform; aesop;


/-- **Theorem 6.3**: The modular S matrix has determinant 1. -/
theorem modular_S_det :
    Matrix.det !![( 0 : ℤ), -1; 1, 0] = 1 := by
  simp [Matrix.det_fin_two]


/-- **Theorem 6.4**: S² = -I in SL₂(ℤ). -/
theorem modular_S_squared :
    !![( 0 : ℤ), -1; 1, 0] * !![( 0 : ℤ), -1; 1, 0] = !![(-1 : ℤ), 0; 0, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;> simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- **Theorem 6.5**: (ST)³ = -I. -/
theorem modular_ST_cubed :
    !![( 0 : ℤ), -1; 1, 1] * !![( 0 : ℤ), -1; 1, 1] * !![( 0 : ℤ), -1; 1, 1] =
    !![(-1 : ℤ), 0; 0, -1] := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [Matrix.mul_apply, Fin.sum_univ_two]


/-- **Application 1**: The floor function is an oracle on integers. -/
theorem floor_oracle_idempotent (x : ℤ) : ⌊(x : ℝ)⌋ = x :=
  Int.floor_intCast x


/-- **Application 2**: The modular oracle: (x mod n) mod n = x mod n. -/
theorem mod_oracle_idempotent (x n : ℕ) : (x % n) % n = x % n :=
  Nat.mod_mod_of_dvd x (dvd_refl n)


/-- **Application 3**: The parity oracle is idempotent. -/
theorem parity_oracle_idempotent (x : ℕ) : (x % 2) % 2 = x % 2 := by omega


theorem gcd_oracle_idempotent (a b : ℕ) :
    Nat.gcd (Nat.gcd a b) b = Nat.gcd a b := by
  rw [ Nat.gcd_assoc, Nat.gcd_self ]


/-- **Grand Theorem (The Solution Lens)**: The stereographic round-trip
is the identity — the lens preserves all information. -/
theorem solution_lens_identity :
    ∀ t : ℝ, stereoProj (invStereoProj t) = t :=
  oracle_stereo_roundtrip


/-- **The Solution Lens Oracle**: The stereo round-trip is the identity oracle. -/
def solutionLensOracle : SolverOracle ℝ where
  apply := fun t => stereoProj (invStereoProj t)
  idempotent := by
    intro x; simp [solution_lens_identity]


/-- **Oracle-Lens Collapse**: O ∘ lens ∘ O = O. -/
theorem oracle_lens_collapse (O : SolverOracle ℝ) (x : ℝ) :
    O.apply (stereoProj (invStereoProj (O.apply x))) = O.apply x := by
  rw [solution_lens_identity]; exact O.idempotent x


/-- **The Frozen Crystal Theorem**: The truth set of the solution lens oracle
is all of ℝ — every point is a fixed point of the identity. -/
theorem frozen_crystal_is_everything :
    solutionLensOracle.truthSet = Set.univ := by
  ext x; simp [SolverOracle.truthSet, solutionLensOracle, solution_lens_identity]


end
