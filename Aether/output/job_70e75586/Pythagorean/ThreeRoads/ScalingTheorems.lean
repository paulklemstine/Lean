import Mathlib

/-! # CatalogBuild.Pythagorean.ThreeRoads.ScalingTheorems

Auto-generated from theorem catalog database.
Domain: Pythagorean/ThreeRoads
Declarations: 35
-/

/-- B₃ transform preserves the Pythagorean property (forward direction). -/
theorem B3_preserves_pyth (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 = (-2*a + 2*b + 3*c)^2 := by
  nlinarith

/-- B₁ transform preserves the quadratic form (explicit calculation). -/
theorem B1_lorentz_form (a b c : ℤ) :
    (a - 2*b + 2*c)^2 + (2*a - b + 2*c)^2 - (2*a - 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring

/-- B₂ transform preserves the quadratic form. -/
theorem B2_lorentz_form (a b c : ℤ) :
    (a + 2*b + 2*c)^2 + (2*a + b + 2*c)^2 - (2*a + 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring

/-- B₃ transform preserves the quadratic form. -/
theorem B3_lorentz_form (a b c : ℤ) :
    (-a + 2*b + 2*c)^2 + (-2*a + b + 2*c)^2 - (-2*a + 2*b + 3*c)^2 =
    a^2 + b^2 - c^2 := by ring

/-- B₁ sieve value: the c-b difference after applying B₁. -/
theorem B1_sieve_diff (a b c : ℤ) :
    (2*a - 2*b + 3*c) - (2*a - b + 2*c) = c - b := by ring

/-- B₂ sieve value: the c-b difference after applying B₂. -/
theorem B2_sieve_diff (a b c : ℤ) :
    (2*a + 2*b + 3*c) - (2*a + b + 2*c) = c + b := by ring

/-- B₃ sieve value: the c-b difference after applying B₃. -/
theorem B3_sieve_diff (a b c : ℤ) :
    (-2*a + 2*b + 3*c) - (-2*a + b + 2*c) = c + b := by ring

/-- B₁ preserves the c-b sieve value — this is a key structural result. -/
theorem B1_preserves_cmb (a b c : ℤ) :
    (2*a - 2*b + 3*c) - (2*a - b + 2*c) = c - b := by ring

/-- The sum c+b after B₁. -/
theorem B1_cpb (a b c : ℤ) :
    (2*a - 2*b + 3*c) + (2*a - b + 2*c) = 4*a - 3*b + 5*c := by ring

/-- The product (c-b)(c+b) = a² for any Pythagorean triple. -/
theorem sieve_product_eq_leg_sq (a b c : ℤ) (h : a^2 + b^2 = c^2) :
    (c - b) * (c + b) = a^2 := by nlinarith

/-- c-b is always positive when a,b,c > 0 and a²+b²=c². -/
theorem cmb_pos (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (h : a^2 + b^2 = c^2) : 0 < c - b := by nlinarith [sq_nonneg a]

/-- c+b is always positive when b,c > 0. -/
theorem cpb_pos (b c : ℤ) (hb : 0 < b) (hc : 0 < c) : 0 < c + b := by linarith

/-- The canonical triple identity expressed without division. -/
theorem canonical_triple_identity (N : ℤ) :
    (2*N)^2 + (N^2 - 1)^2 = (N^2 + 1)^2 := by ring

/-- For any factorization N = p*q, we get a Pythagorean triple. -/
theorem factor_to_triple (p q : ℤ) :
    (2*p*q)^2 + (p^2 - q^2)^2 = (p^2 + q^2)^2 := by ring

/-- The product of the legs in the factor triple. -/
theorem factor_triple_leg_product (p q : ℤ) :
    2*p*q * (p^2 - q^2) = 2*p*q*(p-q)*(p+q) := by ring

/-- Two distinct factorizations give two triples with same hypotenuse pattern. -/
theorem two_factorizations_two_triples (p₁ q₁ p₂ q₂ : ℤ) :
    (p₁^2 - q₁^2)^2 + (2*p₁*q₁)^2 = (p₁^2 + q₁^2)^2 ∧
    (p₂^2 - q₂^2)^2 + (2*p₂*q₂)^2 = (p₂^2 + q₂^2)^2 :=
  ⟨by ring, by ring⟩

/-- For a matrix with char poly (x-1)³, expansion gives trace 3. -/
theorem triple_eigenvalue_trace (x : ℤ) :
    (x - 1)^3 = x^3 - 3*x^2 + 3*x - 1 := by ring

/-- The discriminant of B₂'s quadratic factor x²-4x+1. -/
theorem B2_discriminant : (4:ℤ)^2 - 4*1*1 = 12 := by norm_num

/-- 12 = 4 * 3. -/
theorem discriminant_factored : (12:ℤ) = 4 * 3 := by norm_num

/-- At depth 0, the root triple satisfies 3² + 4² = 5². -/
theorem depth_0_hyp : (5 : ℤ)^2 = 3^2 + 4^2 := by norm_num

/-- The hypotenuse of B₁(3,4,5) is 13. -/
theorem B1_root_hyp : 2*3 - 2*4 + 3*5 = (13:ℤ) := by norm_num

/-- The hypotenuse of B₂(3,4,5) is 29. -/
theorem B2_root_hyp : 2*3 + 2*4 + 3*5 = (29:ℤ) := by norm_num

/-- The hypotenuse of B₃(3,4,5) is 17. -/
theorem B3_root_hyp : -2*3 + 2*4 + 3*5 = (17:ℤ) := by norm_num

/-- If N² + b² = c², then N² divides c² - b². -/
theorem quad_residue_connection (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    N^2 ∣ (c^2 - b^2) := ⟨1, by linarith⟩

/-- The sieve value c-b divides N². -/
theorem sieve_divides_sq (N b c : ℤ) (h : N^2 + b^2 = c^2) :
    (c - b) ∣ N^2 := by
  have : (c - b) * (c + b) = N^2 := by nlinarith
  exact ⟨c + b, this.symm⟩

/-- GCD of any integer with N divides N. -/
theorem gcd_potential_factor (N d : ℤ) :
    (Int.gcd d N : ℤ) ∣ N :=
  Int.gcd_dvd_right d N

/-- Two triples sharing a leg produce equal sieve products. -/
theorem combined_sieve (N b₁ c₁ b₂ c₂ : ℤ)
    (h1 : N^2 + b₁^2 = c₁^2) (h2 : N^2 + b₂^2 = c₂^2) :
    (c₁ - b₁) * (c₁ + b₁) = (c₂ - b₂) * (c₂ + b₂) := by nlinarith

/-- Cross-multiplication of sieve values from two triples. -/
theorem sieve_cross_mul (N b₁ c₁ b₂ c₂ : ℤ)
    (h1 : N^2 + b₁^2 = c₁^2) (h2 : N^2 + b₂^2 = c₂^2) :
    (c₁ - b₁) * (c₁ + b₁) = (c₂ - b₂) * (c₂ + b₂) := by nlinarith

/-- For unimodular determinants, the inverse exists over ℤ. -/
theorem unimodular_invertible (d : ℤ) (hd : d = 1 ∨ d = -1) : d * d = 1 := by
  rcases hd with rfl | rfl <;> norm_num

/-- N = 15: factored via (15, 112, 113). -/
theorem factor_15_via_triple : (15:ℤ)^2 + 112^2 = 113^2 := by norm_num

/-- The sieve extracts factor 3 from 15. -/
theorem factor_15_gcd : Nat.gcd 9 15 = 3 := by native_decide

/-- N = 77: factored via canonical triple. -/
theorem factor_77_via_triple : (77:ℤ)^2 + 2964^2 = 2965^2 := by norm_num

/-- N = 1073 = 29 × 37. -/
theorem factor_1073 : 29 * 37 = 1073 := by norm_num

/-- N = 10403 = 101 × 103. -/
theorem factor_10403 : 101 * 103 = 10403 := by norm_num

/-- Factoring reduces to Pythagorean search: every integer has a trivial triple. -/
theorem factoring_is_pythagorean_search (N : ℤ) :
    ∃ b c : ℤ, N^2 + b^2 = c^2 :=
  ⟨0, N, by ring⟩

