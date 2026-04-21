/-! # CatalogBuild.Physics.Classical.GEMEquations

Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 11
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.Classical.GEMEquations
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 11] -/
theorem gravity_em_ratio_bound :
    ∀ (G m_p m_e e_sq k_e : ℝ),
    G > 0 → m_p > 0 → m_e > 0 → e_sq > 0 → k_e > 0 →
    G * m_p * m_e / (k_e * e_sq) < k_e * e_sq / (G * m_p * m_e) →
    G * m_p * m_e < k_e * e_sq := by
  intro G m_p m_e e_sq k_e hG hm_p hm_e he_sq hk_e h; rw [ div_lt_div_iff₀ ] at h <;> nlinarith [ show 0 < G*m_p*m_e by positivity, show 0 < k_e*e_sq by positivity ] ;




/-- [Section: # CatalogBuild.Physics.Classical.GEMEquations
Auto-generated from theorem catalog database.
Domain: Physics/Classical
Declarations: 11] -/
theorem casimir_energy_monotone :
    ∀ (a₁ a₂ : ℝ) (C : ℝ),
    0 < a₁ → 0 < a₂ → a₁ < a₂ → C > 0 →
    -C / a₂ ^ 4 > -C / a₁ ^ 4 := by
  field_simp;
  intros; gcongr;




theorem casimir_energy_negative :
    ∀ (a : ℝ) (C : ℝ), 0 < a → C > 0 → -C / a ^ 4 < 0 := by
  exact fun a C ha hC => div_neg_of_neg_of_pos ( neg_neg_of_pos hC ) ( pow_pos ha 4 )




theorem warp_shaping_bounded :
    ∀ (f : ℝ → ℝ),
    (∀ x, 0 ≤ f x) →
    (∀ x, f x ≤ 1) →
    (∀ x, 0 ≤ f x ∧ f x ≤ 1) := by
  exact fun f hf₁ hf₂ x => ⟨ hf₁ x, hf₂ x ⟩




theorem warp_energy_scaling :
    ∀ (v R σ v' R' σ' : ℝ),
    0 < v → 0 < R → 0 < σ →
    v ≤ v' → R ≤ R' → σ ≤ σ' →
    0 < v' → 0 < R' → 0 < σ' →
    v ^ 2 * R ^ 2 * σ ≤ v' ^ 2 * R' ^ 2 * σ' := by
  intros; gcongr;




theorem gravitomagnetic_field_scaling :
    ∀ (G M ω c R : ℝ),
    G > 0 → M > 0 → ω > 0 → c > 0 → R > 0 →
    G * M * ω / (c ^ 2 * R) > 0 := by
  exact fun G M ω c R hG hM hω hc hR => by positivity;




theorem gemr_amplification :
    ∀ (B_standard Q : ℝ),
    B_standard > 0 → Q > 1 →
    Q * B_standard > B_standard := by
  exact fun B Q hB hQ => lt_mul_of_one_lt_left hB hQ




theorem levitation_equilibrium :
    ∀ (m g F_lev : ℝ),
    m > 0 → g > 0 →
    F_lev = m * g →
    F_lev > 0 := by
  exact fun m g F_lev hm hg hF_lev => hF_lev.symm ▸ mul_pos hm hg




theorem gravitomagnetic_levitation_bound :
    ∀ (m g v : ℝ),
    m > 0 → g > 0 → v > 0 →
    m * g / (m * v) = g / v := by
  exact fun m g v hm hg hv => mul_div_mul_left _ _ hm.ne'




theorem vdb_optimization :
    ∀ (R_outer R_inner : ℝ),
    0 < R_outer → 0 < R_inner → R_outer < R_inner →
    (R_outer / R_inner) ^ 2 < 1 := by
  exact fun R_outer R_inner hR_outer hR_inner hR => pow_lt_one₀ ( by positivity ) ( by rw [ div_lt_iff₀ hR_inner ] ; linarith ) ( by positivity )




theorem gem_coupling_positive :
    ∀ (G c : ℝ), G > 0 → c > 0 → G / c ^ 2 > 0 := by
  exact fun G c hG hc => div_pos hG ( sq_pos_of_pos hc )


