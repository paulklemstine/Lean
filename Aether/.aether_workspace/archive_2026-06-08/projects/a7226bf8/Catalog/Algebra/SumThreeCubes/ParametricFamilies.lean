import Mathlib

/-!
# Parametric Families on Cubic Surfaces

This file develops a formal theory of **constructible arithmetic on cubic surfaces**.
We define a parametric family of integer points on the cubic surface
  X_k : x³ + y³ + z³ = k
and study the *diagonal collapse family* (a, b) ↦ (a, b, -a-b) as the first
nontrivial example.

## Main definitions

* `ThreeCubeParamFamily` — a certified two-parameter family of integer points
* `diagonalCollapseFamily` — the classical family (a,b) ↦ (a, b, -a-b)
* `valueSet` — the set of integers representable via a parametric family
* `diagonalCubic` — the binary cubic form F(a,b) = -3ab(a+b)

## Main results

* `diagonalCollapseFamily_spec` — a³ + b³ + (-a-b)³ = -3ab(a+b)
* `sum_cubes_sub_three_mul_factor` — factorization identity
* `sum_cubes_eq_three_xyz_of_sum_zero` — hyperplane section theorem
* `diagonalCubic_S3_invariant` — S₃ symmetry
* `pairwise_coprime_factors_of_isCoprime` — pairwise coprimality
* `prime_dvd_diagonalCubic_of_coprime` — prime divisibility trichotomy
* `diagonalCubic_strictMono_right_pos` — strict monotonicity on positives
-/

open Int

/-! ## Core Definitions -/

/-- An integer `k` is representable as a sum of three cubes. -/
def SumThreeCubesRep' (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k

/-- A certified two-parameter family of integer points on cubic surfaces. -/
structure ThreeCubeParamFamily where
  x : ℤ → ℤ → ℤ
  y : ℤ → ℤ → ℤ
  z : ℤ → ℤ → ℤ
  value : ℤ → ℤ → ℤ
  cert : ∀ a b : ℤ, (x a b) ^ 3 + (y a b) ^ 3 + (z a b) ^ 3 = value a b

/-- The value set of a parametric family. -/
def valueSet (P : ThreeCubeParamFamily) : Set ℤ :=
  {k | ∃ a b : ℤ, P.value a b = k}

/-- The binary cubic form F(a,b) = -3ab(a+b). -/
def diagonalCubic (a b : ℤ) : ℤ := -3 * a * b * (a + b)

/-! ## Theorem 1: Certified Parametric Representation -/

/-- The fundamental identity: a³ + b³ + (-a-b)³ = -3ab(a+b). -/
theorem diagonalCollapseFamily_spec (a b : ℤ) :
    a ^ 3 + b ^ 3 + (-a - b) ^ 3 = -3 * a * b * (a + b) := by ring

/-- The diagonal collapse family: (a, b) ↦ (a, b, -a-b) with k = -3ab(a+b). -/
def diagonalCollapseFamily : ThreeCubeParamFamily where
  x := fun a _ => a
  y := fun _ b => b
  z := fun a b => -a - b
  value := fun a b => -3 * a * b * (a + b)
  cert := fun a b => by ring

/-- Membership in the value set of the diagonal collapse family. -/
theorem mem_valueSet_diagonalCollapse_iff (k : ℤ) :
    k ∈ valueSet diagonalCollapseFamily ↔
      ∃ a b : ℤ, k = -3 * a * b * (a + b) := by
  simp only [valueSet, Set.mem_setOf_eq, diagonalCollapseFamily]
  exact ⟨fun ⟨a, b, h⟩ => ⟨a, b, h.symm⟩, fun ⟨a, b, h⟩ => ⟨a, b, h.symm⟩⟩

/-- Every integer in the value set is representable as a sum of three cubes. -/
theorem diagonalCollapse_represents (k : ℤ) :
    k ∈ valueSet diagonalCollapseFamily →
      ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k := by
  rintro ⟨a, b, hab⟩
  exact ⟨a, b, -a - b, hab ▸ diagonalCollapseFamily.cert a b⟩

/-- Every value gives a SumThreeCubesRep'. -/
theorem diagonalCollapse_sumThreeCubesRep (a b : ℤ) :
    SumThreeCubesRep' (-3 * a * b * (a + b)) :=
  ⟨a, b, -a - b, by ring⟩

/-! ## Theorem 5: Cross-Domain Bridge — Factorization and Hyperplane Sections -/

/-- The factorization: x³+y³+z³-3xyz = (x+y+z)(x²+y²+z²-xy-yz-zx). -/
theorem sum_cubes_sub_three_mul_factor (x y z : ℤ) :
    x ^ 3 + y ^ 3 + z ^ 3 - 3 * x * y * z =
      (x + y + z) * (x ^ 2 + y ^ 2 + z ^ 2 - x * y - y * z - z * x) := by ring

/-- On x+y+z=0, the sum of cubes equals 3xyz. -/
theorem sum_cubes_eq_three_xyz_of_sum_zero {x y z : ℤ}
    (h : x + y + z = 0) :
    x ^ 3 + y ^ 3 + z ^ 3 = 3 * x * y * z := by
  have := sum_cubes_sub_three_mul_factor x y z
  nlinarith [mul_eq_zero_of_left h (x ^ 2 + y ^ 2 + z ^ 2 - x * y - y * z - z * x)]

/-- The diagonal collapse arises from the hyperplane section x+y+z=0. -/
theorem diagonalCollapse_from_hyperplane_section (a b : ℤ) :
    a ^ 3 + b ^ 3 + (-a - b) ^ 3 = 3 * a * b * (-a - b) :=
  sum_cubes_eq_three_xyz_of_sum_zero (by ring)

/-- -3ab(a+b) = 3ab(-a-b). -/
theorem diagonalCubic_eq_hyperplane_form (a b : ℤ) :
    -3 * a * b * (a + b) = 3 * a * b * (-a - b) := by ring

/-! ## Theorem 2: S₃ Symmetry of the Binary Cubic Form -/

theorem diagonalCubic_symm_swap (a b : ℤ) :
    diagonalCubic a b = diagonalCubic b a := by
  simp only [diagonalCubic]; ring

theorem diagonalCubic_symm_cyclic₁ (a b : ℤ) :
    diagonalCubic a b = diagonalCubic (-a - b) a := by
  simp only [diagonalCubic]; ring

theorem diagonalCubic_symm_cyclic₂ (a b : ℤ) :
    diagonalCubic a b = diagonalCubic b (-a - b) := by
  simp only [diagonalCubic]; ring

theorem diagonalCubic_symm_cyclic₃ (a b : ℤ) :
    diagonalCubic a b = diagonalCubic a (-a - b) := by
  simp only [diagonalCubic]; ring

theorem diagonalCubic_symm_cyclic₄ (a b : ℤ) :
    diagonalCubic a b = diagonalCubic (-a - b) b := by
  simp only [diagonalCubic]; ring

/-- Full S₃ invariance of F(a,b) = -3ab(a+b). -/
theorem diagonalCubic_S3_invariant (a b : ℤ) :
    diagonalCubic a b = diagonalCubic b a ∧
    diagonalCubic a b = diagonalCubic (-a - b) a ∧
    diagonalCubic a b = diagonalCubic a (-a - b) :=
  ⟨diagonalCubic_symm_swap a b,
   diagonalCubic_symm_cyclic₁ a b,
   diagonalCubic_symm_cyclic₃ a b⟩

theorem diagonalCubic_zero_left (b : ℤ) : diagonalCubic 0 b = 0 := by
  simp [diagonalCubic]

theorem diagonalCubic_zero_right (a : ℤ) : diagonalCubic a 0 = 0 := by
  simp [diagonalCubic]

theorem diagonalCubic_neg_self (a : ℤ) : diagonalCubic a (-a) = 0 := by
  simp [diagonalCubic]

/-! ## Theorem 3: Coprimality and Divisibility Structure -/

theorem coprime_add_right_of_coprime {a b : ℤ} (h : IsCoprime a b) :
    IsCoprime a (a + b) := by
  convert h.add_mul_right_right 1 using 1 ; ring

theorem coprime_add_left_of_coprime {a b : ℤ} (h : IsCoprime a b) :
    IsCoprime b (a + b) := by
  convert h.symm.add_mul_left_right 1 using 1 ; ring

theorem pairwise_coprime_factors_of_isCoprime {a b : ℤ} (h : IsCoprime a b) :
    IsCoprime a b ∧ IsCoprime a (a + b) ∧ IsCoprime b (a + b) :=
  ⟨h, coprime_add_right_of_coprime h, coprime_add_left_of_coprime h⟩

theorem dvd_diagonalCubic_of_dvd_first {p a b : ℤ} (hp : p ∣ a) :
    p ∣ diagonalCubic a b := by
  exact dvd_mul_of_dvd_left ( dvd_mul_of_dvd_left ( dvd_mul_of_dvd_right hp _ ) _ ) _

theorem dvd_diagonalCubic_of_dvd_second {p a b : ℤ} (hp : p ∣ b) :
    p ∣ diagonalCubic a b := by
  rw [diagonalCubic_symm_swap]
  exact dvd_diagonalCubic_of_dvd_first hp

theorem dvd_diagonalCubic_of_dvd_sum {p a b : ℤ} (hp : p ∣ (a + b)) :
    p ∣ diagonalCubic a b := by
  exact dvd_mul_of_dvd_right hp _

theorem prime_dvd_diagonalCubic_of_coprime
    {p a b : ℤ} (hp : Prime p) (h3 : ¬ (p : ℤ) ∣ 3)
    (_hcop : IsCoprime a b)
    (hdvd : p ∣ diagonalCubic a b) :
    p ∣ a ∨ p ∣ b ∨ p ∣ (a + b) := by
  unfold diagonalCubic at hdvd;
  simp_all +decide [ hp.dvd_mul, dvd_neg ];
  tauto

/-! ## Theorem 4: Monotonicity and Counting -/

/-
For a > 0 and 0 < b₁ < b₂, we have 3ab₁(a+b₁) < 3ab₂(a+b₂).
-/
theorem diagonalCubic_lt_of_lt_of_pos {a b₁ b₂ : ℤ}
    (ha : 0 < a) (hb₁ : 0 < b₁) (hlt : b₁ < b₂) :
    3 * a * b₁ * (a + b₁) < 3 * a * b₂ * (a + b₂) := by
  nlinarith [ mul_lt_mul_of_pos_left hlt ha, mul_lt_mul_of_pos_left hlt hb₁ ]

/-- Injectivity on positive integers: for a > 0, b₁ > 0, b₂ > 0,
equal values of 3ab(a+b) force b₁ = b₂. -/
theorem diagonalCubic_injective_right_on_pos {a b₁ b₂ : ℤ}
    (ha : 0 < a) (hb₁ : 0 < b₁) (hb₂ : 0 < b₂)
    (hEq : 3 * a * b₁ * (a + b₁) = 3 * a * b₂ * (a + b₂)) :
    b₁ = b₂ := by
  rcases lt_trichotomy b₁ b₂ with h | h | h
  · exact absurd hEq (ne_of_lt (diagonalCubic_lt_of_lt_of_pos ha hb₁ h))
  · exact h
  · exact absurd hEq.symm (ne_of_lt (diagonalCubic_lt_of_lt_of_pos ha hb₂ h))

/-! ## Additional structural results -/

theorem three_dvd_diagonalCubic (a b : ℤ) : (3 : ℤ) ∣ diagonalCubic a b :=
  ⟨-(a * b * (a + b)), by simp [diagonalCubic]; ring⟩

theorem zero_mem_valueSet : (0 : ℤ) ∈ valueSet diagonalCollapseFamily :=
  ⟨0, 0, by simp [diagonalCollapseFamily]⟩

/-
The value set is closed under negation.
-/
theorem neg_mem_valueSet_of_mem {k : ℤ} (hk : k ∈ valueSet diagonalCollapseFamily) :
    -k ∈ valueSet diagonalCollapseFamily := by
  obtain ⟨ a, b, rfl ⟩ := hk;
  exact ⟨ -a, -b, by unfold diagonalCollapseFamily; ring ⟩