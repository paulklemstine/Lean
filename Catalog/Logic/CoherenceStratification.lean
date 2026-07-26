import Mathlib

/-! # CatalogBuild.Logic.CoherenceStratification

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25
-/

noncomputable section

/-- Coherence measure: C = 1 - H/n where H is spectral entropy and n is dimension. -/
def CoherenceVal (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  1 - H_spectral / n

/-- Spectral landscape entropy, dual to coherence. -/
def LandscapeVal (H_spectral : ℝ) (n : ℕ) (hn : 0 < n) : ℝ :=
  H_spectral / n

/-- The fundamental duality: coherence + landscape = 1. -/
theorem coherence_duality (H : ℝ) (n : ℕ) (hn : 0 < n) :
    CoherenceVal H n hn + LandscapeVal H n hn = 1 := by
  simp [CoherenceVal, LandscapeVal]

/-- Coherence is nonneg when spectral entropy ≤ n. -/
theorem coherence_nonneg' (H : ℝ) (n : ℕ) (hn : 0 < n) (hH : H ≤ n) :
    0 ≤ CoherenceVal H n hn := by
  unfold CoherenceVal
  have : H / (n : ℝ) ≤ 1 := div_le_one_of_le₀ hH (Nat.cast_nonneg n)
  linarith

/-- Coherence is at most 1 when spectral entropy ≥ 0. -/
theorem coherence_le_one' (H : ℝ) (n : ℕ) (hn : 0 < n) (hH : 0 ≤ H) :
    CoherenceVal H n hn ≤ 1 := by
  unfold CoherenceVal
  have : 0 ≤ H / (n : ℝ) := div_nonneg hH (Nat.cast_nonneg n)
  linarith

/-- Coherence lies in [0, 1] when spectral entropy ∈ [0, n]. -/
theorem coherence_bounded (H : ℝ) (n : ℕ) (hn : 0 < n)
    (hH0 : 0 ≤ H) (hHn : H ≤ n) :
    0 ≤ CoherenceVal H n hn ∧ CoherenceVal H n hn ≤ 1 :=
  ⟨coherence_nonneg' H n hn hHn, coherence_le_one' H n hn hH0⟩

/-- Restriction increases coherence: if we restrict k variables,
the remaining function has higher coherence when the spectral
entropy contracts proportionally. -/
theorem coherence_restriction_monotone (H H' : ℝ) (n k : ℕ)
    (hn : 0 < n) (hnk : 0 < n - k) (hk : k ≤ n)
    (hH' : H' / (↑(n - k) : ℝ) ≤ H / (↑n : ℝ)) :
    CoherenceVal H n hn ≤ CoherenceVal H' (n - k) hnk := by
  unfold CoherenceVal; linarith

/-- A coherence class at threshold γ: the set of all problems whose coherence ≥ γ.
We model this as a predicate on coherence values. -/
def InCoherenceClass (coherence_val : ℝ) (gamma : ℝ) : Prop :=
  coherence_val ≥ gamma

/-- Higher threshold ⟹ smaller class: NP_γ ⊆ NP_δ when γ ≥ δ. -/
theorem coherence_class_nested (c gamma delta : ℝ) (hgd : gamma ≥ delta) :
    InCoherenceClass c gamma → InCoherenceClass c delta := by
  intro h; unfold InCoherenceClass at *; linarith

/-- Every problem is in NP₀ (the class with threshold 0). -/
theorem coherence_class_zero (c : ℝ) (hc : 0 ≤ c) :
    InCoherenceClass c 0 := by
  unfold InCoherenceClass; linarith

/-- The coherence class at threshold 1 contains only maximally coherent problems. -/
theorem coherence_class_one (c : ℝ) :
    InCoherenceClass c 1 ↔ c ≥ 1 := by
  unfold InCoherenceClass; exact Iff.rfl

/-- Stratification: if a problem has coherence in (γ_low, γ_high),
then it's in class γ_low but not in class γ_high. -/
theorem strict_stratification (c gamma_high gamma_low : ℝ)
    (h_order : gamma_high > gamma_low)
    (h_in_low : InCoherenceClass c gamma_low)
    (h_not_high : ¬ InCoherenceClass c gamma_high) :
    gamma_low ≤ c ∧ c < gamma_high := by
  unfold InCoherenceClass at *
  constructor <;> linarith

/-- The four-level NP hierarchy is correctly nested. -/
theorem four_level_hierarchy (c : ℝ) (hc0 : 0 ≤ c) (hc1 : c ≤ 1) :
    (InCoherenceClass c 1 → InCoherenceClass c (3/4)) ∧
    (InCoherenceClass c (3/4) → InCoherenceClass c (1/2)) ∧
    (InCoherenceClass c (1/2) → InCoherenceClass c (1/4)) ∧
    (InCoherenceClass c (1/4) → InCoherenceClass c 0) := by
  unfold InCoherenceClass
  exact ⟨fun h => by linarith, fun h => by linarith, fun h => by linarith, fun h => by linarith⟩

/-- Key separation theorem: there exist coherence values that separate
adjacent levels. -/
theorem coherence_gap_exists (gamma1 gamma2 : ℝ) (h : gamma1 > gamma2) :
    ∃ c, InCoherenceClass c gamma2 ∧ ¬ InCoherenceClass c gamma1 := by
  use (gamma1 + gamma2) / 2
  unfold InCoherenceClass
  constructor <;> linarith

/-- Quantum coherence of a state via l1-norm of off-diagonals:
C_l1 = (Σ|αᵢ|)² - 1 for a state with real nonneg amplitudes. -/
def quantumCoherence_l1 {n : ℕ} (amplitudes : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ amplitudes i)
    (h_norm : ∑ i, amplitudes i ^ 2 = 1) : ℝ :=
  (∑ i, amplitudes i) ^ 2 - 1

/-- [Section: # CatalogBuild.Logic.CoherenceStratification
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25] -/
theorem quantum_coherence_nonneg {n : ℕ} (hn : 0 < n)
    (amplitudes : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ amplitudes i)
    (h_norm : ∑ i, amplitudes i ^ 2 = 1) :
    0 ≤ quantumCoherence_l1 amplitudes h_nonneg h_norm := by
  -- By the properties of the l1 norm, we know that (∑ i, amplitudes i)^2 ≥ ∑ i, amplitudes i^2.
  have h_l1_norm : (∑ i, amplitudes i)^2 ≥ ∑ i, amplitudes i^2 := by
    simpa only [ sq, Finset.sum_mul _ _ _ ] using Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_left ( Finset.single_le_sum ( fun i _ => h_nonneg i ) ( Finset.mem_univ i ) ) ( h_nonneg i );
  exact sub_nonneg_of_le ( by linarith )

/-- [Section: # CatalogBuild.Logic.CoherenceStratification
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 25] -/
theorem basis_state_zero_coherence {n : ℕ} (hn : 1 ≤ n)
    (amplitudes : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ amplitudes i)
    (h_norm : ∑ i, amplitudes i ^ 2 = 1)
    (j : Fin n) (h_basis : ∀ i, i ≠ j → amplitudes i = 0) :
    quantumCoherence_l1 amplitudes h_nonneg h_norm = 0 := by
  unfold quantumCoherence_l1;
  simp_all +decide [ Finset.sum_eq_single j ];
  cases h_norm <;> simp +decide [ * ]

theorem max_coherence_uniform {n : ℕ} (hn : 0 < n)
    (amplitudes : Fin n → ℝ)
    (h_nonneg : ∀ i, 0 ≤ amplitudes i)
    (h_norm : ∑ i, amplitudes i ^ 2 = 1)
    (h_uniform : ∀ i, amplitudes i = 1 / Real.sqrt n) :
    quantumCoherence_l1 amplitudes h_nonneg h_norm = n - 1 := by
  unfold quantumCoherence_l1; norm_num [ h_uniform ];
  norm_num [ mul_pow, hn.ne' ];
  norm_num [ sq, hn.ne' ]

theorem coherence_monotone_dephasing {n : ℕ}
    (a a' : Fin n → ℝ)
    (ha : ∀ i, 0 ≤ a i) (ha' : ∀ i, 0 ≤ a' i)
    (hn1 : ∑ i, a i ^ 2 = 1) (hn2 : ∑ i, a' i ^ 2 = 1)
    (h_dephase : ∀ i, a' i ≤ a i) :
    quantumCoherence_l1 a' ha' hn2 ≤ quantumCoherence_l1 a ha hn1 := by
  exact sub_le_sub_right ( pow_le_pow_left₀ ( Finset.sum_nonneg fun _ _ => ha' _ ) ( Finset.sum_le_sum fun _ _ => h_dephase _ ) _ ) _

/-- n-dimensional coherence for a tensor product state decomposes multiplicatively. -/
theorem tensor_coherence_decomposition
    {n m : ℕ} (hn : 0 < n) (hm : 0 < m)
    (a : Fin n → ℝ) (b : Fin m → ℝ)
    (ha : ∀ i, 0 ≤ a i) (hb : ∀ i, 0 ≤ b i)
    (ha_norm : ∑ i, a i ^ 2 = 1) (hb_norm : ∑ i, b i ^ 2 = 1) :
    let Sa := ∑ i, a i
    let Sb := ∑ i, b i
    (Sa * Sb) ^ 2 - 1 = (Sa ^ 2 - 1) + (Sb ^ 2 - 1) + (Sa ^ 2 - 1) * (Sb ^ 2 - 1) := by
  ring

theorem bell_state_coherence :
    let a : Fin 4 → ℝ := ![1 / Real.sqrt 2, 0, 0, 1 / Real.sqrt 2]
    (∑ i, a i) ^ 2 - 1 = 1 := by
  norm_num [ Fin.sum_univ_succ ] ; ring ; norm_num;

/-- Superposition provides search advantage: n - 1 > 0 for n > 1. -/
theorem superposition_search_advantage (n : ℕ) (hn : 1 < n) :
    (n : ℝ) - 1 > 0 := by
  exact sub_pos.mpr (Nat.one_lt_cast.mpr hn)

theorem ghz_coherence_dimension_independent :
    (Real.sqrt 2) ^ 2 - 1 = (1 : ℝ) := by
  norm_num +zetaDelta at *

/-- The quantum search exponent n(1-C)/2 lies in [0, n/2]. -/
theorem coherence_search_exponent (n : ℕ) (C : ℝ)
    (hn : 0 < n) (hC0 : 0 ≤ C) (hC1 : C ≤ 1) :
    0 ≤ (n : ℝ) * (1 - C) / 2 ∧ (n : ℝ) * (1 - C) / 2 ≤ n / 2 := by
  constructor
  · have : 0 ≤ (n : ℝ) := Nat.cast_nonneg n
    have : 0 ≤ 1 - C := by linarith
    positivity
  · have : 0 ≤ (n : ℝ) * C := by positivity
    linarith

/-- Conservation law: coherence + entropy rate = 1. -/
theorem coherence_entropy_conservation (C entropy_rate : ℝ)
    (h : C + entropy_rate = 1) : entropy_rate = 1 - C := by
  linarith

end