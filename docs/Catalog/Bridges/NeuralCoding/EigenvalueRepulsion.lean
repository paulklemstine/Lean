import Mathlib

open Matrix

open Finset

/-! # CatalogBuild.Algebra.EigenvalueRepulsion

Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 22
-/

/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 22] -/
theorem vandermonde_det_eq_prod_diff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) :=
  Matrix.det_vandermonde v

/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 22] -/
theorem vandermonde_det_zero_iff {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det = 0 ↔ ∃ i j : Fin n, i ≠ j ∧ v i = v j := by
  -- By definition of Vandermonde determinant, if two eigenvalues are equal, say $v^i = v^j$ for some $i < j$, then the determinant is zero due to repeated columns.
  suffices h_suff : ∏ i : Fin n, ∏ j ∈ Finset.Ioi i, (v j - v i) = 0 ↔ ∃ i j, i < j ∧ v i = v j by
    rw [ vandermonde_det_eq_prod_diff, h_suff ];
    exact ⟨ fun ⟨ i, j, hij, h ⟩ => ⟨ i, j, ne_of_lt hij, h ⟩, fun ⟨ i, j, hij, h ⟩ => if hij' : i < j then ⟨ i, j, hij', h ⟩ else ⟨ j, i, lt_of_le_of_ne ( le_of_not_gt hij' ) ( Ne.symm hij ), h.symm ⟩ ⟩;
  norm_num [ Finset.prod_eq_zero_iff, sub_eq_zero ] ; aesop;

theorem vandermonde_det_sq {n : ℕ} (v : Fin n → ℝ) :
    (vandermonde v).det ^ 2 = ∏ i : Fin n, ∏ j ∈ Ioi i, (v j - v i) ^ 2 := by
  simp +decide only [vandermonde_det_eq_prod_diff, prod_pow]

-- Non-negative Boltzmann weight.

theorem vandermonde_det_sq_nonneg {n : ℕ} (v : Fin n → ℝ) :
    0 ≤ (vandermonde v).det ^ 2 := sq_nonneg _

theorem vandermonde_det_pos_of_strictMono {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) : 0 < (vandermonde v).det := by
  rw [ vandermonde_det_eq_prod_diff v ] ; exact Finset.prod_pos fun i hi => Finset.prod_pos fun j hj => sub_pos.2 <| hv <| Finset.mem_Ioi.1 hj;

theorem log_abs_vandermonde_eq_sum {n : ℕ} (v : Fin n → ℝ)
    (hv : StrictMono v) :
    Real.log |(vandermonde v).det| =
      ∑ i : Fin n, ∑ j ∈ Ioi i, Real.log (v j - v i) := by
  rw [ Matrix.det_vandermonde ];
  rw [ Finset.abs_prod, Real.log_prod ];
  · rw [ Finset.sum_congr rfl ] ; intros ; rw [ Finset.abs_prod ] ; rw [ Real.log_prod ] ; aesop;
    exact fun i hi => ne_of_gt <| abs_pos.mpr <| sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hi;
  · exact fun i _ => ne_of_gt <| abs_pos.mpr <| Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero.mpr <| hv.injective.ne <| ne_of_gt <| Finset.mem_Ioi.mp hj

theorem repulsion_stronger_at_higher_beta {x : ℝ} (hx0 : 0 < x) (hx1 : x < 1)
    {β₁ β₂ : ℝ} (hβ : β₁ < β₂) (hβ₁ : 0 < β₁) :
    x ^ β₂ < x ^ β₁ := by
  exact Real.rpow_lt_rpow_of_exponent_gt hx0 hx1 hβ

theorem vandermonde_two (a b : ℝ) :
    (vandermonde ![a, b]).det = b - a := by
  norm_num [ vandermonde, Matrix.det_fin_two ]

-- Symmetry of the squared gap under eigenvalue exchange.

theorem eigenvalue_gap_sq_symm (a b : ℝ) :
    (a - b) ^ 2 = (b - a) ^ 2 := by ring

noncomputable section

/-- The "repulsion factor" for a collection of n points on the real line.
This is |∏_{i<j} (vⱼ - vᵢ)|^β, the factor in the joint eigenvalue density
that causes repulsion. β = 1 (GOE), 2 (GUE), 4 (GSE). -/
def repulsionFactor (beta : ℝ) (ev : Fin n → ℝ) : ℝ :=
  |∏ i : Fin n, ∏ j ∈ Ioi i, (ev j - ev i)| ^ beta

/-- The Coulomb energy of n point charges on the real line.
E = -∑_{i<j} log|vᵢ - vⱼ|
This is the 2D electrostatic energy of unit charges confined to a line. -/
def coulombEnergy (ev : Fin n → ℝ) : ℝ :=
  -∑ i : Fin n, ∑ j ∈ Ioi i, Real.log |ev j - ev i|

/-- The confining potential energy in a quadratic well. -/
def confiningEnergy (ev : Fin n → ℝ) : ℝ :=
  ∑ i : Fin n, ev i ^ 2 / 2

/-- The total effective energy of the eigenvalue Coulomb gas.
For the GUE (β=2): E_total = -2 ∑_{i<j} log|vᵢ - vⱼ| + ∑ vᵢ²/2
This is the energy whose Boltzmann weight exp(-E) gives the joint eigenvalue density. -/
def totalEnergy (beta : ℝ) (ev : Fin n → ℝ) : ℝ :=
  beta * coulombEnergy ev + confiningEnergy ev

/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 22] -/
theorem repulsion_at_coincidence {n : ℕ} {beta : ℝ} (hbeta : 0 < beta) (ev : Fin n → ℝ)
    (i j : Fin n) (hij : i ≠ j) (heq : ev i = ev j) :
    repulsionFactor beta ev = 0 := by
      -- Since $ev i = ev j$, we have $(ev j - ev i) = 0$, so the product is zero.
      have h_zero : ∏ i : Fin n, ∏ j ∈ Ioi i, (ev j - ev i) = 0 := by
        cases lt_or_gt_of_ne hij <;> simp_all +decide [ Finset.prod_eq_zero_iff, sub_eq_zero ] ; aesop;
        exact ⟨ j, i, by assumption, by linarith ⟩
      simp [repulsionFactor, h_zero] at *;
      exact Real.zero_rpow hbeta.ne'

/-- [Section: # CatalogBuild.Algebra.EigenvalueRepulsion
Auto-generated from theorem catalog database.
Domain: Algebra
Declarations: 22] -/
theorem vandermonde_nonzero_iff_distinct {n : ℕ} (ev : Fin n → ℝ) :
    (vandermonde ev).det ≠ 0 ↔ Function.Injective ev := by
      convert Matrix.det_vandermonde_ne_zero_iff;
      infer_instance

theorem repulsion_eq_exp_neg_coulomb {n : ℕ} {beta : ℝ} (_hbeta : 0 ≤ beta)
    (ev : Fin n → ℝ) (hdist : Function.Injective ev) :
    repulsionFactor beta ev = Real.exp (-beta * coulombEnergy ev) := by
      unfold repulsionFactor coulombEnergy;
      rw [ Real.rpow_def_of_pos ] <;> norm_num;
      · rw [ mul_comm, Real.log_prod ];
        · exact congrArg _ ( Finset.sum_congr rfl fun i hi => by rw [ Real.log_prod ] ; intros j hj ; exact sub_ne_zero_of_ne <| hdist.ne <| by aesop );
        · exact fun i _ => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| hdist.ne <| ne_of_gt <| Finset.mem_Ioi.mp hj;
      · exact Finset.prod_ne_zero_iff.mpr fun i hi => Finset.prod_ne_zero_iff.mpr fun j hj => sub_ne_zero_of_ne <| hdist.ne <| by aesop;

theorem repulsionFactor_nonneg {n : ℕ} {beta : ℝ} (_hbeta : 0 ≤ beta)
    (ev : Fin n → ℝ) : 0 ≤ repulsionFactor beta ev := by
      exact Real.rpow_nonneg ( abs_nonneg _ ) _

theorem two_point_repulsion (beta : ℝ) (_hbeta : 0 ≤ beta) (a b : ℝ) :
    repulsionFactor beta ![a, b] = |b - a| ^ beta := by
      unfold repulsionFactor; simp +decide [ Fin.prod_univ_succ ] ;

theorem coulomb_energy_pair (a d : ℝ) (_hd : 0 < d) :
    coulombEnergy ![a, a + d] = -Real.log d := by
      unfold coulombEnergy; aesop;

/-- The three classical Dyson indices corresponding to the three division algebras
over the reals: ℝ (β=1), ℂ (β=2), ℍ (β=4). -/
inductive DysonIndex where
  | GOE : DysonIndex  -- β = 1, real symmetric matrices
  | GUE : DysonIndex  -- β = 2, complex Hermitian matrices
  | GSE : DysonIndex  -- β = 4, quaternionic self-dual matrices
  deriving DecidableEq, Repr

/-- The numerical value of each Dyson index. -/
def DysonIndex.toReal : DysonIndex → ℝ
  | .GOE => 1
  | .GUE => 2
  | .GSE => 4

theorem DysonIndex.toReal_pos (d : DysonIndex) : 0 < d.toReal := by
  cases d <;> simp [DysonIndex.toReal]

end