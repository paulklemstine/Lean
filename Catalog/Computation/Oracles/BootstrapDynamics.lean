/-! # CatalogBuild.Computation.Oracles.BootstrapDynamics

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 25
-/

import Mathlib

noncomputable section

/-- Generalized bootstrap map at temperature T ≥ 0.
f_T(r) = (2 + T) r² - (1 + T) r³
At T=1: 3r² - 2r³ (standard bootstrap map).
At T=0: 2r² - r³. -/
def bootstrapT (T : ℝ) (r : ℝ) : ℝ := (2 + T) * r ^ 2 - (1 + T) * r ^ 3




/-- At T=1 the generalized map reduces to the standard bootstrap map. -/
theorem bootstrapT_one (r : ℝ) : bootstrapT 1 r = 3 * r ^ 2 - 2 * r ^ 3 := by
  unfold bootstrapT; ring




/-- r = 0 is always a fixed point for any temperature. -/
theorem bootstrapT_fixed_zero (T : ℝ) : bootstrapT T 0 = 0 := by
  simp [bootstrapT]




/-- r = 1 is always a fixed point for any temperature. -/
theorem bootstrapT_fixed_one (T : ℝ) : bootstrapT T 1 = 1 := by
  unfold bootstrapT; ring




/-- [Section: # CatalogBuild.Computation.Oracles.BootstrapDynamics
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 25] -/
theorem bootstrapT_critical_point (T : ℝ) (hT : -1 < T) :
    bootstrapT T (1 / (1 + T)) = 1 / (1 + T) := by
  unfold bootstrapT;
  grind




/-- [Section: # CatalogBuild.Computation.Oracles.BootstrapDynamics
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 25] -/
theorem bootstrapT_fixed_points (T : ℝ) (hT : 0 < T) (r : ℝ) :
    bootstrapT T r = r ↔ r = 0 ∨ r = 1 / (1 + T) ∨ r = 1 := by
  constructor <;> intro h;
  · exact Classical.or_iff_not_imp_left.2 fun hr => Classical.or_iff_not_imp_left.2 fun hr' => mul_left_cancel₀ ( sub_ne_zero_of_ne hr' ) <| mul_left_cancel₀ ( sub_ne_zero_of_ne hr ) <| by rw [ div_eq_inv_mul ] ; nlinarith [ mul_inv_cancel_left₀ ( by linarith : ( 1 + T ) ≠ 0 ) r, mul_inv_cancel_left₀ ( by linarith : ( 1 + T ) ≠ 0 ) 1, mul_inv_cancel₀ ( by linarith : ( 1 + T ) ≠ 0 ), mul_inv_cancel₀ ( by linarith : ( 1 + T ) ≠ 0 ), show bootstrapT T r = ( 2 + T ) * r ^ 2 - ( 1 + T ) * r ^ 3 from rfl ] ;
  · rcases h with ( rfl | rfl | rfl ) <;> unfold bootstrapT <;> norm_num [ ne_of_gt ( by linarith : 0 < 1 + T ) ] ; ring;
    -- Combine like terms and simplify the expression.
    field_simp
    ring




theorem bootstrapT_improves_above_critical (T : ℝ) (hT : 0 < T) (r : ℝ)
    (hr1 : 1 / (1 + T) < r) (hr2 : r < 1) :
    r < bootstrapT T r := by
  rw [ div_lt_iff₀ ( by linarith ) ] at hr1;
  unfold bootstrapT; nlinarith [ mul_pos ( sub_pos.2 hr1 ) ( sub_pos.2 hr2 ) ] ;




theorem bootstrapT_degrades_below_critical (T : ℝ) (hT : 0 < T) (r : ℝ)
    (hr1 : 0 < r) (hr2 : r < 1 / (1 + T)) :
    bootstrapT T r < r := by
  rw [ lt_div_iff₀ ( by linarith ) ] at hr2;
  unfold bootstrapT;
  nlinarith [ mul_lt_mul_of_pos_left hr2 hr1 ]




theorem critical_point_decreasing (T₁ T₂ : ℝ) (hT1 : 0 < T₁) (hT2 : T₁ < T₂) :
    1 / (1 + T₂) < 1 / (1 + T₁) := by
  gcongr




/-- The Lyapunov function V(r) = r²(1-r)². -/
def lyapunovV (r : ℝ) : ℝ := r ^ 2 * (1 - r) ^ 2




/-- V vanishes exactly at the stable fixed points. -/
theorem lyapunovV_zero_iff (r : ℝ) : lyapunovV r = 0 ↔ r = 0 ∨ r = 1 := by
  simp only [lyapunovV, mul_eq_zero, sq_eq_zero_iff, sub_eq_zero]
  tauto




/-- V is nonneg everywhere. -/
theorem lyapunovV_nonneg (r : ℝ) : 0 ≤ lyapunovV r := by
  unfold lyapunovV; positivity




/-- An operator is an oracle (idempotent). -/
def IsIdempotent {α : Type*} (P : α → α) : Prop := ∀ x, P (P x) = P x




/-- Commuting oracles compose to form an oracle. -/
theorem commuting_oracles_compose {α : Type*} (P Q : α → α)
    (hP : IsIdempotent P) (hQ : IsIdempotent Q)
    (hcomm : ∀ x, P (Q x) = Q (P x)) :
    IsIdempotent (P ∘ Q) := by
  intro x
  simp [Function.comp]
  calc P (Q (P (Q x)))
      = P (P (Q (Q x))) := by rw [hcomm (Q x)]
    _ = P (Q (Q x)) := by rw [hP]
    _ = P (Q x) := by rw [hQ]




/-- The fixed point set of a composed oracle contains the intersection. -/
theorem composed_fixed_points {α : Type*} (P Q : α → α)
    (_hP : IsIdempotent P) (_hQ : IsIdempotent Q)
    (_hcomm : ∀ x, P (Q x) = Q (P x)) :
    {x | P x = x} ∩ {x | Q x = x} ⊆ {x | (P ∘ Q) x = x} := by
  intro x ⟨hxP, hxQ⟩
  simp only [mem_setOf_eq, Function.comp]
  rw [hxQ, hxP]




/-- The derivative of the standard bootstrap map at the stable fixed points is 0. -/
theorem bootstrap_derivative_zero_at_stable :
    (fun r : ℝ => 6 * r * (1 - r)) 0 = 0 ∧
    (fun r : ℝ => 6 * r * (1 - r)) 1 = 0 := by
  constructor <;> ring




/-- The derivative at r = 1/2 is 3/2 > 1, confirming instability. -/
theorem bootstrap_derivative_at_half :
    (fun r : ℝ => 6 * r * (1 - r)) (1/2) = 3/2 := by ring




theorem quadratic_convergence_near_one (e : ℝ) (he0 : 0 ≤ e) (he1 : e ≤ 1) :
    1 - (3 * (1 - e) ^ 2 - 2 * (1 - e) ^ 3) ≤ 3 * e ^ 2 := by
  nlinarith [ sq_nonneg ( e - 1 ) ]




/-- f(r) = 3r² - 2r³ satisfies the Hermite interpolation conditions. -/
theorem bootstrap_is_hermite :
    let f := fun r : ℝ => 3 * r ^ 2 - 2 * r ^ 3
    let f' := fun r : ℝ => 6 * r - 6 * r ^ 2
    f 0 = 0 ∧ f 1 = 1 ∧ f' 0 = 0 ∧ f' 1 = 0 := by
  simp only
  exact ⟨by ring, by ring, by ring, by ring⟩




/-- Cosine similarity between two vectors. -/
def cosineSim (n : ℕ) (u v : Fin n → ℝ) : ℝ :=
  (∑ i, u i * v i) / (Real.sqrt (∑ i, u i ^ 2) * Real.sqrt (∑ i, v i ^ 2))




theorem cosineSim_self (n : ℕ) (u : Fin n → ℝ)
    (hu : 0 < ∑ i, u i ^ 2) :
    cosineSim n u u = 1 := by
  -- By definition of cosineSimilarity, we have $\cos(\theta) = \frac{u \cdot u}{\|u\| \|u\|}$.
  unfold cosineSim
  field_simp [hu];
  rw [ Real.sq_sqrt hu.le ]




/-- **Generalized Phase Transition Theorem**:
For any temperature T > 0, the bootstrap map f_T has a critical point
at r* = 1/(1+T) such that quality improves above r* and degrades below. -/
theorem generalized_phase_transition (T : ℝ) (hT : 0 < T) :
    bootstrapT T (1 / (1 + T)) = 1 / (1 + T) ∧
    (∀ r, 1 / (1 + T) < r → r < 1 → r < bootstrapT T r) ∧
    (∀ r, 0 < r → r < 1 / (1 + T) → bootstrapT T r < r) := by
  exact ⟨bootstrapT_critical_point T (by linarith),
         fun r h1 h2 => bootstrapT_improves_above_critical T hT r h1 h2,
         fun r h1 h2 => bootstrapT_degrades_below_critical T hT r h1 h2⟩




/-- The standard bootstrap map has the symmetry f(1-r) = 1 - f(r). -/
theorem bootstrap_symmetry (r : ℝ) :
    3 * (1 - r) ^ 2 - 2 * (1 - r) ^ 3 = 1 - (3 * r ^ 2 - 2 * r ^ 3) := by
  ring




/-- The standard bootstrap map preserves [0,1]. -/
theorem bootstrap_maps_unit_interval (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) :
    0 ≤ 3 * r ^ 2 - 2 * r ^ 3 ∧ 3 * r ^ 2 - 2 * r ^ 3 ≤ 1 := by
  constructor <;> nlinarith [sq_nonneg r, sq_nonneg (1 - r)]




theorem bootstrap_iterates_in_unit (r : ℝ) (hr0 : 0 ≤ r) (hr1 : r ≤ 1) (n : ℕ) :
    0 ≤ (fun r => 3 * r ^ 2 - 2 * r ^ 3)^[n] r ∧
    (fun r => 3 * r ^ 2 - 2 * r ^ 3)^[n] r ≤ 1 := by
  induction n <;> simp_all +decide [ Function.iterate_succ_apply' ];
  constructor <;> nlinarith [ sq_nonneg ( ( Nat.iterate ( fun r : ℝ => 3 * r ^ 2 - 2 * r ^ 3 ) ‹_› r ) - 1 ) ]




end
