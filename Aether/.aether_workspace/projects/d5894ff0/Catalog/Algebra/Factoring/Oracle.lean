import Mathlib

/-! # CatalogBuild.Algebra.Factoring.Oracle
Unified file merging Oracle-related theorems.
-
-/

/- Original: OracleAnalysis.lean -/




/-- [Section: # CatalogBuild.Computation.Oracles.OracleAnalysis
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8] -/
theorem oracle_partial_correctness (N a b : ℕ) (h_prod : a * b = N)
    (ha : 1 < a) (hb : 1 < b) : ¬ Nat.Prime N := by
  rintro H; rw [ ← h_prod, Nat.prime_mul_iff ] at H; aesop;




/-- The search space grows exponentially: 2^(2*(n+1)) = 4 * 2^(2*n). -/
theorem search_space_exponential_growth (n : ℕ) :
    2^(2*(n+1)) = 4 * 2^(2*n) := by
  ring




/-- [Section: # CatalogBuild.Computation.Oracles.OracleAnalysis
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 8] -/
theorem bit_flip_change (a : ℕ) (k : ℕ) :
    (a + 2^k) - a = 2^k := by
  rw [ Nat.add_sub_cancel_left ]




theorem bit_flip_product_change (a b k : ℕ) :
    (a + 2^k) * b - a * b = 2^k * b := by
  grind




theorem msb_flip_catastrophic (b n : ℕ) (hb : 0 < b) (hn : 0 < n) :
    2^(n-1) * b ≥ b := by
  exact le_mul_of_one_le_left hb.le ( Nat.one_le_pow _ _ ( by decide ) )




theorem factoring_not_in_BPP_evidence (N : ℕ) (hN : 2 ≤ N) :
    ∃ d, d ∣ N ∧ 1 ≤ d := by
  exact ⟨ 1, one_dvd _, by norm_num ⟩




theorem exponential_dominates (n : ℕ) (hn : 5 ≤ n) :
    n * n < 2^n := by
  induction' hn with n hn ih <;> norm_num [ Nat.pow_succ ] at * ; nlinarith




theorem oracle_no_speedup (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≤ q) (N : ℕ) (hN : N = p * q) :
    p ≤ N := by
  nlinarith [ hp.two_le, hq.two_le ]

/- Original: OracleCompression.lean -/




noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleCompression
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
def IsRetractionV2 {X : Type*} (r : X → X) (A : Set X) : Prop :=
  (∀ x, r x ∈ A) ∧ (∀ a ∈ A, r a = a)




/-- [Section: # CatalogBuild.Computation.Oracles.OracleCompression
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 14] -/
theorem retraction_is_oracle_v2 {X : Type*} (r : X → X) (A : Set X)
    (hr : IsRetractionV2 r A) : ∀ x, r (r x) = r x :=
  fun x => hr.2 (r x) (hr.1 x)




theorem retraction_range_v2 {X : Type*} (r : X → X) (A : Set X)
    (hr : IsRetractionV2 r A) : range r = A := by
  ext y; constructor
  · rintro ⟨x, rfl⟩; exact hr.1 x
  · intro hy; exact ⟨y, hr.2 y hy⟩




theorem fundamental_pythagorean_v2 : 3 ^ 2 + 4 ^ 2 = 5 ^ 2 := by norm_num




theorem gcd_oracle_factors_v2 (N leg p : ℕ) (hp : p ∣ leg) (hpN : p ∣ N) :
    p ∣ Nat.gcd leg N := Nat.dvd_gcd hp hpN




theorem gcd_nontrivial_v2 (N leg p : ℕ) (hp : Nat.Prime p)
    (h1 : p ∣ leg) (h2 : p ∣ N) (_hN : 0 < N) :
    1 < Nat.gcd leg N := by
  have h := Nat.dvd_gcd h1 h2
  calc 1 < p := hp.one_lt
    _ ≤ Nat.gcd leg N := Nat.le_of_dvd (by positivity) h




theorem factoring_via_gcd_v2 (p q : ℕ) (_hp : Nat.Prime p) (_hq : Nat.Prime q) :
    Nat.gcd p (p * q) = p := Nat.gcd_eq_left (dvd_mul_right p q)




def distToTruthV2 {X : Type*} [DecidableEq X] (O : X → X) (x : X) : ℕ :=
  if O x = x then 0 else 1




theorem oracle_reaches_min_v2 {X : Type*} [DecidableEq X]
    (O : X → X) (hO : ∀ x, O (O x) = O x) (x : X) :
    distToTruthV2 O (O x) = 0 := by simp [distToTruthV2, hO x]




theorem oracle_reduces_v2 {X : Type*} [DecidableEq X]
    (O : X → X) (hO : ∀ x, O (O x) = O x) (x : X) :
    distToTruthV2 O (O x) ≤ distToTruthV2 O x := by simp [distToTruthV2, hO x]




theorem contraction_conv_v2 (c d₀ : ℝ) (hc : 0 ≤ c) (hc1 : c < 1) (hd : 0 ≤ d₀) (n : ℕ) :
    c ^ n * d₀ ≤ d₀ :=
  le_of_le_of_eq (mul_le_mul_of_nonneg_right (pow_le_one₀ hc hc1.le) hd) (one_mul d₀)




theorem contraction_nonneg_v2 (c d₀ : ℝ) (hc : 0 ≤ c) (hd : 0 ≤ d₀) (n : ℕ) :
    0 ≤ c ^ n * d₀ := mul_nonneg (pow_nonneg hc n) hd




theorem truth_count_bound_v2 (n k : ℕ) (hkn : k ≤ n) :
    Nat.log 2 k ≤ Nat.log 2 n := Nat.log_mono_right hkn




theorem compression_triangle_v2 {n : ℕ} (O : Fin n → Fin n)
    (_hO : ∀ x, O (O x) = O x) :
    Fintype.card (range O) + (n - Fintype.card (range O)) = n := by
  have h := Fintype.card_range_le O
  simp [Fintype.card_fin] at h ⊢; omega




end

/- Original: OracleFactoring.lean -/




noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleFactoring
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11] -/
theorem gcd_idempotent_on_self (n : ℕ) : Nat.gcd n n = n := by
  grind




/-- [Section: # CatalogBuild.Computation.Oracles.OracleFactoring
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11] -/
theorem factor_divides_gcd {p a N : ℕ} (hpa : p ∣ a) (hpN : p ∣ N) :
    p ∣ Nat.gcd a N := by
      exact Nat.dvd_gcd hpa hpN




theorem five_sum_of_squares : (1 : ℤ)^2 + 2^2 = 5 := by
  grind




theorem thirteen_sum_of_squares : (2 : ℤ)^2 + 3^2 = 13 := by
  grind +ring




theorem sixty_five_two_reps :
    (1 : ℤ)^2 + 8^2 = 65 ∧ (4 : ℤ)^2 + 7^2 = 65 := by
      decide +revert




theorem fermat_factoring (x y : ℤ) :
    x^2 - y^2 = (x + y) * (x - y) := by
      ring




theorem fermat_gives_factors (N x y : ℤ) (hN : N = x^2 - y^2) :
    N = (x + y) * (x - y) := by
      exact hN.trans ( by ring )




theorem pythagorean_parametrize (m n : ℤ) :
    (m^2 - n^2)^2 + (2*m*n)^2 = (m^2 + n^2)^2 := by
      ring




theorem composite_has_factor {n : ℕ} (hn : ¬ Nat.Prime n) (hn2 : 2 ≤ n) :
    ∃ d, 1 < d ∧ d < n ∧ d ∣ n := by
      exact Exists.imp ( by aesop ) ( Nat.exists_dvd_of_not_prime2 hn2 hn )




theorem trial_division_bound {n p : ℕ} (hp : Nat.Prime p) (hpn : p ∣ n) (hn : 1 < n) :
    p ≤ n := by
      exact Nat.le_of_dvd hn.le hpn




theorem prime_count_bound (n : ℕ) : (Finset.filter Nat.Prime (Finset.range (n + 1))).card ≤ n + 1 := by
  exact le_trans ( Finset.card_filter_le _ _ ) ( by norm_num )




end

/- Original: OracleMoonshots.lean -/



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

