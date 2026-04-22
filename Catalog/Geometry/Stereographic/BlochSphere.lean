import Geometry.Stereographic.Basic
import Mathlib

/-! # CatalogBuild.Geometry.Stereographic.BlochSphere

Auto-generated from theorem catalog database.
Domain: Geometry/Stereographic
Declarations: 13
-/


noncomputable section

/-- The Bloch vector parameterized by stereographic coordinates (u, v) ∈ ℝ² -/
def blochVector (u v : ℝ) : Fin 3 → ℝ :=
  invStereoN (fun j : Fin 2 => if j.val = 0 then u else v)


/-- The Bloch vector lies on S² -/
theorem bloch_on_sphere (u v : ℝ) :
    ∑ i : Fin 3, (blochVector u v i) ^ 2 = 1 := by
  unfold blochVector; exact invStereoN_norm_sq _


/-- [Section: # The Bloch Sphere: Quantum Computing via Stereographic Projection
This file formalizes the connection between stereographic projection and
quantum computing through the Bloch sphere representation of qubits.
## Main Results
* `bloch_on_sphere` — Bloch vector lies on S²
* `fidelity_chordal_identity` — quantum fidelity ↔ chordal distance
* `pauli_x_flips_z` — X gate negates z-component
* `rotation_preserves_norm` — phase gate preserves norm
* `two_qubit_on_s3` — two-qubit states on S³] -/
theorem fidelity_chordal_identity {N : ℕ} (a b : Fin N → ℝ)
    (ha : ∑ i, a i ^ 2 = 1) (hb : ∑ i, b i ^ 2 = 1) :
    ∑ i, (a i - b i) ^ 2 = 2 - 2 * ∑ i, a i * b i := by
  simp +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, mul_assoc, ha, hb ];
  ring


/-- The Pauli X gate negates the z-component -/
theorem pauli_x_flips_z (u v : ℝ) :
    -(u^2 + v^2 - 1) / (1 + u^2 + v^2) = (1 - u^2 - v^2) / (1 + u^2 + v^2) := by
  ring


/-- Antipodal Bloch vectors have dot product -1 -/
theorem antipodal_dot_neg_one {N : ℕ} (a : Fin N → ℝ) (ha : ∑ i, a i ^ 2 = 1) :
    ∑ i, a i * (-a i) = -1 := by
  have : ∑ i : Fin N, a i * (-a i) = -(∑ i, a i ^ 2) := by
    rw [← Finset.sum_neg_distrib]
    apply Finset.sum_congr rfl; intro i _; ring
  linarith


theorem origin_maps_to_south_pole :
    invStereoN (fun _ : Fin 2 => (0 : ℝ)) (lastIdx 2) = -1 := by
  unfold invStereoN lastIdx;
  unfold stereoDenom sqNormFin; norm_num


theorem plus_state_on_equator :
    let y : Fin 2 → ℝ := fun j => if j.val = 0 then 1 else 0
    invStereoN y (lastIdx 2) = 0 := by
  unfold invStereoN;
  unfold lastIdx stereoDenom sqNormFin; norm_num [ Fin.sum_univ_succ ] ;


/-- Hadamard is an involution -/
theorem hadamard_involution (t : ℝ) (ht : t ≠ 1) (ht' : (t + 1) / (t - 1) ≠ 1) :
    ((t + 1) / (t - 1) + 1) / ((t + 1) / (t - 1) - 1) = t := by
  have h1 : t - 1 ≠ 0 := sub_ne_zero.mpr ht
  field_simp; ring


theorem bloch_distance_bounded {N : ℕ} (a b : Fin N → ℝ)
    (ha : ∑ i, a i ^ 2 = 1) (hb : ∑ i, b i ^ 2 = 1) :
    ∑ i, (a i - b i) ^ 2 ≤ 4 := by
  have h_dot_product : ∑ i, a i * b i ≥ -1 := by
    have := Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( a i + b i );
    simp_all +decide [ add_mul, mul_add, Finset.sum_add_distrib, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _, sq ];
    linarith;
  ring_nf;
  norm_num [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ] ; linarith


/-- Phase rotation preserves u² + v² -/
theorem rotation_preserves_norm (u v θ : ℝ) :
    (u * Real.cos θ - v * Real.sin θ) ^ 2 +
    (u * Real.sin θ + v * Real.cos θ) ^ 2 = u ^ 2 + v ^ 2 := by
  nlinarith [Real.sin_sq_add_cos_sq θ,
             sq_nonneg (u * Real.cos θ - v * Real.sin θ),
             sq_nonneg (u * Real.sin θ + v * Real.cos θ),
             sq_nonneg u, sq_nonneg v,
             sq_nonneg (Real.cos θ), sq_nonneg (Real.sin θ)]


/-- Phase rotation preserves z-component -/
theorem rotation_preserves_z (u v θ : ℝ) :
    (  (u * Real.cos θ - v * Real.sin θ)^2
     + (u * Real.sin θ + v * Real.cos θ)^2 - 1) *
    (1 + u^2 + v^2) =
    (u^2 + v^2 - 1) *
    (1 + (u * Real.cos θ - v * Real.sin θ)^2
       + (u * Real.sin θ + v * Real.cos θ)^2) := by
  have h := rotation_preserves_norm u v θ
  nlinarith


/-- Two-qubit states live on S³ -/
theorem two_qubit_on_s3 (y : Fin 3 → ℝ) :
    ∑ i : Fin 4, (invStereoN y i) ^ 2 = 1 :=
  invStereoN_norm_sq y


theorem maximally_mixed_origin (N : ℕ) :
    invStereoN (fun _ : Fin N => (0 : ℝ)) (lastIdx N) = -1 := by
  unfold lastIdx invStereoN stereoDenom;
  unfold sqNormFin; norm_num


end
