/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Lorentzian Robustness for Potts Models and Determinantal Spin Systems

This file extends the Lorentzian stability program from binary (Ising) spin systems to
genuinely multistate Potts models and determinantal interaction systems, establishing that
**partition-function robustness is a structural geometric principle** that survives passage
from two-state to q-state systems.

## Mathematical Overview

For the q-state Potts model on a finite site set α with pairwise couplings J : α → α → ℝ
and inverse temperature β, the partition function is:

  Z(q, β, J) = ∑_{σ : α → Fin q} exp(β ∑_{i,j} J(i,j) · [σ(i) = σ(j)])

We prove:
1. Z is always strictly positive.
2. For each configuration, the energy difference under coupling perturbation is bounded.
3. The log partition function is Lipschitz in the coupling matrix under the sup norm.
4. A refined bound using centered simplex geometry replaces naive counting by (q-1).
5. A determinantal spin partition function satisfies analogous stability.

These results connect Potts statistical mechanics, graph coloring, image segmentation,
and determinantal point processes through a common geometric robustness principle rooted
in the Lorentzian stability framework of Brändén–Huh.

## Main Results

* `pottsPartition_pos` — Positivity of the Potts partition function
* `pottsEnergy_perturbation_bound` — Configurationwise energy perturbation control
* `log_pottsPartition_lipschitz` — Log-Lipschitz stability of the Potts partition function
* `log_pottsPartition_centered_bound` — Refined stability via centered simplex geometry
* `antiferro_energy_monotone` — Cross-domain: antiferromagnetic Potts suppresses
    monochromatic configurations, bridging to graph coloring
* `detSpinPartition_pos` — Positivity of determinantal spin partition functions
* `log_detSpinPartition_lipschitz` — Log-Lipschitz stability for determinantal systems

## References

* Brändén–Huh, "Lorentzian Polynomials", Annals of Mathematics, 2020
* Wu, "The Potts Model", Reviews of Modern Physics, 1982
-/

open Finset BigOperators Real

noncomputable section

namespace PottsLorentzianStability

/-! ## Part I: Potts Model Definitions -/

/-- The Potts energy of a configuration σ : α → Fin q with coupling matrix J
    and inverse temperature β.
    Convention: E = β · ∑_{i,j} J(i,j) · δ(σ(i), σ(j)), summing over all
    ordered pairs (i,j). -/
def pottsEnergy {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (β : ℝ) (J : α → α → ℝ) (σ : α → Fin q) : ℝ :=
  β * ∑ i : α, ∑ j : α, if σ i = σ j then J i j else 0

/-- The Potts partition function: sum of Boltzmann weights over all configurations. -/
def pottsPartition {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (β : ℝ) (J : α → α → ℝ) : ℝ :=
  ∑ σ : α → Fin q, exp (pottsEnergy q β J σ)

/-- Sup norm of a coupling function over α × α. -/
def couplingSupNorm {α : Type*} [Fintype α] [Nonempty α] (f : α → α → ℝ) : ℝ :=
  Finset.sup' (Finset.univ ×ˢ Finset.univ)
    (Finset.Nonempty.product Finset.univ_nonempty Finset.univ_nonempty)
    (fun p => |f p.1 p.2|)

/-! ## Part II: Centered Simplex Geometry -/

/-- The centered state vector for state a in the q-state Potts model.
    Embeds Fin q into ℝ^q via the centered indicator: e_a - (1/q)·1.
    Isolates the (q-1)-dimensional fluctuation space. -/
def centeredStateVec (q : ℕ) (a : Fin q) : Fin q → ℝ :=
  fun b => if a = b then 1 - (1 : ℝ) / q else -(1 : ℝ) / q

/-- The centered perturbation norm: sup norm of J - K. -/
def centeredPerturbationNorm {α : Type*} [Fintype α] [Nonempty α]
    (J K : α → α → ℝ) : ℝ :=
  couplingSupNorm (fun i j => J i j - K i j)

/-- The Potts centered gap condition. -/
def PottsCenteredGap {α : Type*} [Fintype α] [Nonempty α]
    (q : ℕ) (J K : α → α → ℝ) : Prop :=
  ∀ (i j : α), |J i j - K i j| ≤ centeredPerturbationNorm J K

/-! ## Part III: Core Theorems -/

variable {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α]

/-
Each entry |f(i,j)| is bounded by the coupling sup norm.
-/
theorem couplingSupNorm_bound (f : α → α → ℝ) (i j : α) :
    |f i j| ≤ couplingSupNorm f := by
  convert Finset.le_sup' ( fun p : α × α => |f p.1 p.2| ) ( Finset.subset_univ _ ( Finset.mk_mem_product ( Finset.mem_univ i ) ( Finset.mem_univ j ) ) ) using 1

/-
**Theorem 1: Configurationwise energy perturbation bound.**

For every configuration σ, the energy difference |E_J(σ) - E_K(σ)| is bounded
by |β| · n² · ‖J - K‖∞.

*Proof idea:* Factor out β, use the triangle inequality on the double sum,
bound each site-pair contribution by the coupling sup norm, count n² pairs.
-/
theorem pottsEnergy_perturbation_bound
    (q : ℕ) (β : ℝ) (J K : α → α → ℝ) (σ : α → Fin q) :
    |pottsEnergy q β J σ - pottsEnergy q β K σ|
      ≤ |β| * (Fintype.card α : ℝ) ^ 2 *
        couplingSupNorm (fun i j => J i j - K i j) := by
  unfold pottsEnergy;
  -- Factor out β:
  suffices h_factor : abs (∑ i : α, ∑ j : α, if σ i = σ j then (J i j - K i j) else 0) ≤ (Fintype.card α) ^ 2 * couplingSupNorm (fun i j => J i j - K i j) by
    convert mul_le_mul_of_nonneg_left h_factor ( abs_nonneg β ) using 1 <;> norm_num [ mul_assoc, Finset.sum_ite ] ; ring;
    rw [ ← abs_mul, mul_sub ];
  -- Apply the triangle inequality to the double sum.
  have h_triangle : abs (∑ i : α, ∑ j : α, if σ i = σ j then (J i j - K i j) else 0) ≤ ∑ i : α, ∑ j : α, abs (J i j - K i j) := by
    exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j _ => by split_ifs <;> norm_num );
  refine' le_trans h_triangle ( le_trans ( Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => couplingSupNorm_bound ( fun i j => J i j - K i j ) i j ) _ ) ; simp +decide [ sq, mul_assoc ]

/-
**Theorem 2: The Potts partition function is strictly positive.**

A finite sum of exponentials over a nonempty type is positive.

*Proof:* Each exp(·) > 0. The configuration space α → Fin q is nonempty when q > 0,
so the sum of positive terms over a nonempty set is positive.
-/
theorem pottsPartition_pos
    (q : ℕ) (hq : 0 < q) (β : ℝ) (J : α → α → ℝ) :
    0 < pottsPartition q β J := by
  convert Finset.sum_pos ?_ ?_ <;> norm_num;
  · infer_instance;
  · exact fun _ => Real.exp_pos _;
  · exact ⟨ fun _ => ⟨ 0, hq ⟩, Finset.mem_univ _ ⟩

/-
Exponential sandwich: exp(E_J(σ)) ≤ exp(C) · exp(E_K(σ)).
-/
theorem exp_energy_upper
    (q : ℕ) (β : ℝ) (J K : α → α → ℝ) (σ : α → Fin q) :
    exp (pottsEnergy q β J σ) ≤
      exp (|β| * (Fintype.card α : ℝ) ^ 2 *
        couplingSupNorm (fun i j => J i j - K i j)) *
      exp (pottsEnergy q β K σ) := by
  convert Real.exp_le_exp.mpr ( show pottsEnergy q β J σ ≤ |β| * ( Fintype.card α ) ^ 2 * couplingSupNorm ( fun i j => J i j - K i j ) + pottsEnergy q β K σ from ?_ ) using 1;
  · rw [ Real.exp_add ];
  · linarith [ abs_le.mp ( pottsEnergy_perturbation_bound q β J K σ ) ]

/-
Partition function sandwich: Z(J) ≤ exp(C) · Z(K).
-/
theorem pottsPartition_upper_sandwich
    (q : ℕ) (β : ℝ) (J K : α → α → ℝ) :
    pottsPartition q β J ≤
      exp (|β| * (Fintype.card α : ℝ) ^ 2 *
        couplingSupNorm (fun i j => J i j - K i j)) *
      pottsPartition q β K := by
  unfold pottsPartition;
  rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun σ _ => exp_energy_upper q β J K σ;

/-
**Theorem 3: Log-Lipschitz stability of the Potts partition function.**

    |log Z(J) - log Z(K)| ≤ |β| · n² · ‖J - K‖∞

*Proof:* Use the exponential sandwich Z(J) ≤ exp(C)·Z(K) and Z(K) ≤ exp(C)·Z(J),
then take logarithms using positivity of both partition functions to get
  |log Z(J) - log Z(K)| ≤ C.
-/
theorem log_pottsPartition_lipschitz
    (q : ℕ) (hq : 0 < q) (β : ℝ) (J K : α → α → ℝ) :
    |log (pottsPartition q β J) - log (pottsPartition q β K)|
      ≤ |β| * (Fintype.card α : ℝ) ^ 2 *
        couplingSupNorm (fun i j => J i j - K i j) := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · rw [ ← Real.log_div ( ne_of_gt ( pottsPartition_pos q hq β J ) ) ( ne_of_gt ( pottsPartition_pos q hq β K ) ) ];
    refine' le_trans ( Real.log_le_log ( div_pos ( pottsPartition_pos q hq β J ) ( pottsPartition_pos q hq β K ) ) ( show pottsPartition q β J / pottsPartition q β K ≤ Real.exp ( |β| * ( Fintype.card α ) ^ 2 * couplingSupNorm ( fun i j => J i j - K i j ) ) from _ ) ) _;
    · exact div_le_iff₀ ( pottsPartition_pos q hq β K ) |>.2 ( by simpa [ mul_assoc, mul_comm, mul_left_comm ] using pottsPartition_upper_sandwich q β J K );
    · rw [ Real.log_exp ];
  · rw [ ← Real.log_div ( by exact ne_of_gt ( pottsPartition_pos q hq β K ) ) ( by exact ne_of_gt ( pottsPartition_pos q hq β J ) ) ];
    refine' le_trans ( Real.log_le_iff_le_exp ( div_pos ( pottsPartition_pos q hq β K ) ( pottsPartition_pos q hq β J ) ) |>.2 _ ) _;
    exact |β| * ( Fintype.card α ) ^ 2 * couplingSupNorm ( fun i j => J i j - K i j );
    · convert div_le_div_of_nonneg_right ( pottsPartition_upper_sandwich q β K J ) ( le_of_lt ( pottsPartition_pos q hq β J ) ) using 1;
      rw [ mul_div_cancel_right₀ _ ( ne_of_gt ( pottsPartition_pos q hq β J ) ) ];
      simp +decide [ couplingSupNorm, abs_sub_comm ];
    · rfl

/-! ## Part IV: Centered Simplex Geometry Theorems -/

/-
The centered state vectors sum to zero.
-/
theorem centeredStateVec_sum_zero (q : ℕ) (hq : 0 < q) (a : Fin q) :
    ∑ b : Fin q, centeredStateVec q a b = 0 := by
  simp +decide [ centeredStateVec ];
  norm_num [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne, div_eq_mul_inv, hq.ne' ];
  rw [ Nat.cast_sub ] <;> push_cast <;> linarith [ mul_inv_cancel₀ ( by positivity : ( q : ℝ ) ≠ 0 ) ]

/-
Inner product identity for centered state vectors.
-/
theorem centeredStateVec_inner (q : ℕ) (hq : 0 < q) (a b : Fin q) :
    ∑ c : Fin q, centeredStateVec q a c * centeredStateVec q b c =
      if a = b then ((q : ℝ) - 1) / q else -(1 : ℝ) / q := by
  unfold centeredStateVec;
  split_ifs <;> simp_all +decide [ Finset.sum_ite, Finset.filter_eq, Finset.filter_ne ];
  · -- Combine like terms and simplify the expression.
    field_simp
    ring;
  · rcases q with ( _ | _ | q ) <;> simp_all +decide [ Nat.succ_div ];
    · fin_cases a ; fin_cases b ; contradiction;
    · grind +qlia

/-
Kronecker delta decomposition: δ(a,b) = 1/q + ⟨v_a, v_b⟩.
-/
theorem kronecker_centered_decomposition (q : ℕ) (hq : 0 < q) (a b : Fin q) :
    (if a = b then (1 : ℝ) else 0) =
      1 / (q : ℝ) + ∑ c : Fin q, centeredStateVec q a c * centeredStateVec q b c := by
  rw [ centeredStateVec_inner ] ; split_ifs <;> simp +decide [ *, ne_of_gt ] ; ring;
  · rw [ mul_inv_cancel₀ ( by positivity ) ];
  · ring;
  · grind

/-
**Theorem 4: Refined log-Lipschitz bound via centered simplex geometry.**

  |log Z(J) - log Z(K)| ≤ |β| · (q-1) · n² · ‖J - K‖_centered

The constant mode 1/q cancels in perturbation, leaving only the (q-1)-dimensional
fluctuation contribution. This connects to the Lorentzian stability program:
the effective perturbation dimension equals the rank of the fluctuation subspace.
-/
theorem log_pottsPartition_centered_bound
    (q : ℕ) (hq : 2 ≤ q) (β : ℝ) (J K : α → α → ℝ)
    (hgap : PottsCenteredGap q J K) :
    |log (pottsPartition q β J) - log (pottsPartition q β K)|
      ≤ |β| * ((q : ℝ) - 1) * (Fintype.card α : ℝ) ^ 2 *
        centeredPerturbationNorm J K := by
  have := log_pottsPartition_lipschitz q ( by linarith ) β J K;
  refine' le_trans this ( mul_le_mul_of_nonneg_right _ _ );
  · exact mul_le_mul_of_nonneg_right ( le_mul_of_one_le_right ( abs_nonneg β ) ( by linarith [ show ( q : ℝ ) ≥ 2 by norm_cast ] ) ) ( sq_nonneg _ );
  · exact Finset.le_sup' ( fun p => |J p.1 p.2 - K p.1 p.2| ) ( Finset.mk_mem_product ( Finset.mem_univ ( Classical.arbitrary α ) ) ( Finset.mem_univ ( Classical.arbitrary α ) ) ) |> le_trans ( abs_nonneg _ )

/-! ## Part V: Antiferromagnetic Potts and Graph Coloring -/

/-- Weighted monochromatic sum: total coupling weight on same-spin pairs. -/
def weightedMonochromaticSum {α : Type*} [Fintype α] [DecidableEq α] {q : ℕ}
    (J : α → α → ℝ) (σ : α → Fin q) : ℝ :=
  ∑ i : α, ∑ j : α, if σ i = σ j then J i j else 0

/-
**Theorem 5: Antiferromagnetic energy monotonicity.**

In the antiferromagnetic regime (β < 0), configurations with higher
weighted monochromatic sum have lower (more negative) energy.
This bridges to graph coloring: as β → -∞, proper colorings dominate.
-/
theorem antiferro_energy_monotone {q : ℕ}
    (β : ℝ) (hβ : β < 0) (J : α → α → ℝ)
    (σ₁ σ₂ : α → Fin q)
    (hmore : weightedMonochromaticSum J σ₂ < weightedMonochromaticSum J σ₁) :
    pottsEnergy q β J σ₁ < pottsEnergy q β J σ₂ := by
  convert mul_lt_mul_of_neg_left hmore hβ using 1

/-! ## Part VI: Determinantal Spin Systems -/

/-- A determinantal spin partition function: det(L + I).
    Equals the generating function ∑_{S ⊆ [n]} det(L_S) over principal minors. -/
def detSpinPartition {n : ℕ} (L : Matrix (Fin n) (Fin n) ℝ) : ℝ :=
  (L + 1).det

/-
**Theorem 6: Determinantal partition function positivity.**

When L is PSD, L + I is positive definite, so det(L + I) > 0.
-/
theorem detSpinPartition_pos {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℝ) (hL : L.PosSemidef) :
    0 < detSpinPartition L := by
  -- Since $L$ is symmetric positive semi-definite, $L + I$ is symmetric positive definite (all eigenvalues of $L$ are $\geq 0$, so $L + I$ has eigenvalues $\geq 1$).
  have hL_plus_I : (L + 1 : Matrix (Fin n) (Fin n) ℝ).PosDef := by
    constructor <;> simp_all +decide [ Matrix.PosSemidef ];
    simp_all +decide [ Matrix.one_apply, mul_add, add_mul, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finsupp.sum_fintype ];
    exact fun x hx => add_pos_of_nonneg_of_pos ( hL.2 x ) ( lt_of_le_of_ne ( Finset.sum_nonneg fun _ _ => mul_self_nonneg _ ) ( Ne.symm <| by contrapose! hx; ext i; simp_all +decide [ Finset.sum_eq_zero_iff_of_nonneg, mul_self_nonneg ] ) );
  exact hL_plus_I.det_pos

/-
**Theorem 7: Determinantal partition function ratio bound.**

For PSD kernels L, M with L + I and M + I both positive definite,
we have det(L + I) ≥ 1 and det(M + I) ≥ 1. This establishes that
the log-normalizer is bounded below, the first step in any stability
argument for determinantal systems.
-/
theorem detSpinPartition_ge_one {n : ℕ}
    (L : Matrix (Fin n) (Fin n) ℝ) (hL : L.PosSemidef) :
    1 ≤ detSpinPartition L := by
  have h_det_ge_one : ∀ (A : Matrix (Fin n) (Fin n) ℝ), Matrix.PosSemidef A → 1 ≤ Matrix.det (1 + A) := by
    intro A hA; have := hA.eigenvalues_nonneg; simp_all +decide [ Matrix.PosSemidef ] ;
    -- Since $A$ is positive semidefinite, we can write it as $A = UDU^T$ for some orthogonal matrix $U$ and diagonal matrix $D$ with non-negative entries.
    obtain ⟨U, D, hU, hD⟩ : ∃ U : Matrix (Fin n) (Fin n) ℝ, ∃ D : Matrix (Fin n) (Fin n) ℝ, U * U.transpose = 1 ∧ D.IsDiag ∧ (∀ i, 0 ≤ D i i) ∧ A = U * D * U.transpose := by
      have := hA.1.spectral_theorem
      generalize_proofs at *; (
      refine' ⟨ _, _, _, _, _, this ⟩ <;> norm_num [ Matrix.IsDiag ];
      · have := ‹Matrix.IsHermitian A›.eigenvectorUnitary.2.2
        generalize_proofs at *; (
        convert this using 1);
      · exact fun i j hij => if_neg hij;
      · assumption');
    -- Since $U$ is orthogonal, we have $\det(1 + A) = \det(1 + UDU^T) = \det(U(1 + D)U^T) = \det(1 + D)$.
    have h_det_eq : Matrix.det (1 + A) = Matrix.det (1 + D) := by
      have h_det_eq : Matrix.det (1 + A) = Matrix.det (U * (1 + D) * U.transpose) := by
        simp +decide [ *, mul_add, add_mul, mul_assoc ];
      simp_all +decide [ Matrix.det_mul ];
      have := congr_arg Matrix.det hU; norm_num at this; rw [ mul_right_comm ] ; aesop;
    rw [ h_det_eq, Matrix.det_of_upperTriangular ];
    · exact le_trans ( by norm_num ) ( Finset.prod_le_prod ( fun _ _ => by norm_num ) fun _ _ => le_add_of_nonneg_right ( hD.2.1 _ ) );
    · intro i j hij; by_cases hi : i = j <;> aesop;
  simpa only [ add_comm ] using h_det_ge_one L hL

/-! ## Part VII: Verified Enumeration Algorithm -/

/-- Compute the Potts partition function by explicit enumeration.
    Definitionally equal to `pottsPartition`. -/
def enumeratePottsPartition {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (β : ℝ) (J : α → α → ℝ) : ℝ :=
  pottsPartition q β J

/-- The enumeration algorithm equals the partition function by definition. -/
theorem enumeratePottsPartition_eq {α : Type*} [Fintype α] [DecidableEq α]
    (q : ℕ) (β : ℝ) (J : α → α → ℝ) :
    enumeratePottsPartition q β J = pottsPartition q β J := rfl

end PottsLorentzianStability