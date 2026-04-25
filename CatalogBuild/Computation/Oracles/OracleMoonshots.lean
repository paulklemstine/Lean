/-! # CatalogBuild.Computation.Oracles.OracleMoonshots

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleMoonshots
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15] -/
theorem fermat_sum_two_sq_5' : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 5 := ⟨1, 2, by norm_num⟩


/-- [Section: # CatalogBuild.Computation.Oracles.OracleMoonshots
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15] -/
theorem fermat_sum_two_sq_13' : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 13 := ⟨2, 3, by norm_num⟩


/-- [Section: # CatalogBuild.Computation.Oracles.OracleMoonshots
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 15] -/
theorem fermat_sum_two_sq_17' : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 17 := ⟨1, 4, by norm_num⟩


theorem fermat_sum_two_sq_29' : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 29 := ⟨2, 5, by norm_num⟩


theorem fermat_sum_two_sq_37' : ∃ a b : ℕ, a ^ 2 + b ^ 2 = 37 := ⟨1, 6, by norm_num⟩


theorem gaussian_factoring_info' :
    (1 ^ 2 + 8 ^ 2 = 65) ∧ (4 ^ 2 + 7 ^ 2 = 65) := by constructor <;> norm_num


theorem brahmagupta_fibonacci_v2 (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by ring


theorem proof_compression_ratio' (n : ℕ) (k : ℕ) (hk : 0 < k) :
    (n : ℚ) / k ≤ n := by
  have : (1 : ℚ) ≤ k := by exact_mod_cast hk
  have : (0 : ℚ) < k := by linarith
  calc (n : ℚ) / k ≤ n / 1 := by apply div_le_div_of_nonneg_left (by exact_mod_cast Nat.zero_le n) (by linarith) ‹(1 : ℚ) ≤ k›
    _ = n := by simp


def OraclesAgreeV2 {X : Type*} (O₁ O₂ : X → X) : Prop :=
  ∃ x, O₁ x = x ∧ O₂ x = x


def OraclesStronglyAgreeV2 {X : Type*} (O₁ O₂ : X → X) : Prop :=
  {x | O₁ x = x} = {x | O₂ x = x}


theorem strong_agreement_compose' {X : Type*} (O₁ O₂ : X → X)
    (_h1 : ∀ x, O₁ (O₁ x) = O₁ x) (_h2 : ∀ x, O₂ (O₂ x) = O₂ x)
    (hagree : OraclesStronglyAgreeV2 O₁ O₂) :
    ∀ x, O₁ x = x → O₂ x = x := by
  intro x hx
  have : x ∈ {x | O₁ x = x} := hx
  rw [hagree] at this; exact this


theorem truth_aware_compression' (n k : ℕ) (_hk : 0 < k) (hkn : k ≤ n) :
    Nat.log 2 k ≤ Nat.log 2 n := Nat.log_mono_right hkn


theorem sigmoid_positive (x b : ℝ) (_hx : 0 < x) (_hb : 0 < b) :
    0 < 1 / (1 + Real.exp (-b * x)) := by positivity


theorem nat_self_consistent' : ∀ n : ℕ, n + 0 = n := Nat.add_zero


theorem grand_unified_oracle' {n : ℕ} (_hn : 0 < n) (O : Fin n → Fin n)
    (_hO : ∀ x, O (O x) = O x) :
    (¬ Injective O) ↔ (Fintype.card (range O) < n) := by
  constructor <;> intro h <;> contrapose! h <;> simp_all +decide [ Finset.card_range, Fintype.card_subtype ];
  · -- Since the cardinality of the image is at least n and the domain has size n, the image must be the entire codomain.
    have h_image : Finset.image O Finset.univ = Finset.univ := by
      exact Finset.eq_of_subset_of_card_le ( Finset.subset_univ _ ) ( by simpa );
    exact Finite.injective_iff_surjective.mpr ( by simpa [ Finset.ext_iff ] using h_image );
  · rw [ Finset.card_image_of_injective _ h, Finset.card_fin ]


end
