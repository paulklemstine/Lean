/-
# The Goldilocks Theorem: Dimension 3 and Gravitational Orbits

This file formalizes the connection between spatial dimension and the existence
of stable, closed gravitational orbits. The key results are:

1. **Goldilocks Theorem**: Among spatial dimensions n ≥ 2, dimension 3 is the
   unique dimension supporting stable orbits with rational apsidal angle ratio.

2. **Discrete Bertrand Classification**: Among integer force-law exponents
   -2 ≤ α ≤ 2, only α = -2 (inverse-square) and α = 1 (linear/Hooke) yield
   rational apsidal ratios, recovering Bertrand's theorem in the discrete case.

3. **Dimensional Orbit Trichotomy**: Dimensions partition into unstable (n ≥ 4),
   Goldilocks (n = 3), and precessing (n = 2) regimes.

## Mathematical Background

For a central force F(r) = -k·r^α, the apsidal angle for nearly circular orbits
is π/√(3+α). The orbit closes iff this angle is a rational multiple of π, i.e.,
iff √(3+α) is rational. In n spatial dimensions, gravity obeys an inverse (n-1)
power law, giving α = -(n-1) and apsidal ratio ρ(n) = √(4-n).
-/

import Mathlib

open Real

/-! ## Definitions -/

/-- The apsidal ratio for a central force F(r) = -k·r^α.
    For nearly circular orbits, the apsidal angle is π/ρ where ρ = √(3+α).
    The orbit closes iff ρ is rational. -/
noncomputable def bertrandApsidalRatio (α : ℤ) : ℝ := Real.sqrt (3 + (α : ℝ))

/-- The gravitational apsidal ratio in n spatial dimensions.
    Gravity in n dimensions follows F ∝ r^{-(n-1)}, so α = -(n-1)
    and ρ(n) = √(4-n). -/
noncomputable def gravApsidalRatio (n : ℕ) : ℝ := Real.sqrt (4 - (n : ℝ))

/-- A gravitational dimension record capturing the physical properties
    of orbital mechanics in n spatial dimensions. -/
structure GravitationalDimension where
  /-- The spatial dimension -/
  dim : ℕ
  /-- Dimension is at least 2 (need a plane for orbits) -/
  dim_ge_two : dim ≥ 2

/-- Predicate for a dimension supporting stable orbits:
    ρ(n) must be real and positive, i.e., 4-n > 0. -/
def StableOrbits (n : ℕ) : Prop := (4 : ℝ) - (n : ℝ) > 0

/-- Predicate for a dimension supporting closed orbits:
    ρ(n) must be rational. -/
def ClosedOrbits (n : ℕ) : Prop := ¬ Irrational (gravApsidalRatio n)

/-- Predicate for the "Goldilocks" property: stable AND closed orbits. -/
def GoldilocksProperty (n : ℕ) : Prop := StableOrbits n ∧ ClosedOrbits n

/-- The orbit trichotomy classification. -/
inductive OrbitRegime where
  | unstable   -- n ≥ 4: no stable circular orbits
  | goldilocks -- n = 3: stable closed orbits
  | precessing -- n = 2: stable but orbits precess (never close)
  deriving DecidableEq, Repr

/-! ## Key Irrationality Results -/

/-- √2 is irrational (from Mathlib). -/
theorem sqrt_two_irrational : Irrational (Real.sqrt 2) := irrational_sqrt_two

/-- √3 is irrational since 3 is prime. -/
theorem sqrt_three_irrational : Irrational (Real.sqrt 3) :=
  Nat.Prime.irrational_sqrt (by norm_num : Nat.Prime 3)

/-- √5 is irrational since 5 is prime. -/
theorem sqrt_five_irrational : Irrational (Real.sqrt 5) :=
  Nat.Prime.irrational_sqrt (by norm_num : Nat.Prime 5)

/-! ## Gravitational Apsidal Ratio Computations -/

/-- In dimension 3, the apsidal ratio is 1. -/
theorem gravApsidal_dim3 : gravApsidalRatio 3 = 1 := by
  unfold gravApsidalRatio
  simp only [Nat.cast_ofNat]
  norm_num

/-- In dimension 2, orbits are stable but not closed (√2 is irrational). -/
theorem dim2_stable : StableOrbits 2 := by
  simp [StableOrbits]; norm_num

theorem dim2_not_closed : ¬ClosedOrbits 2 := by
  simp only [ClosedOrbits, not_not]
  unfold gravApsidalRatio
  have : (4 : ℝ) - (2 : ℕ) = 2 := by norm_num
  rw [this]
  exact irrational_sqrt_two

/-- In dimension 3, orbits are stable and closed. -/
theorem dim3_goldilocks : GoldilocksProperty 3 := by
  refine ⟨?_, ?_⟩
  · simp [StableOrbits]; norm_num
  · simp [ClosedOrbits, gravApsidal_dim3]

/-- Dimensions ≥ 4 do not support stable orbits (4 - n ≤ 0). -/
theorem dim_ge4_unstable (n : ℕ) (hn : n ≥ 4) : ¬ StableOrbits n := by
  simp only [StableOrbits, not_lt]
  have : (n : ℝ) ≥ 4 := by exact_mod_cast hn
  linarith

/-! ## The Goldilocks Theorem -/

/-
**The Goldilocks Theorem**: Among spatial dimensions n ≥ 2,
    dimension 3 is the unique dimension with the Goldilocks property
    (stable and closed gravitational orbits).
-/
theorem goldilocks_unique (n : ℕ) (hn : n ≥ 2) :
    GoldilocksProperty n ↔ n = 3 := by
  constructor;
  · rintro ⟨ h₁, h₂ ⟩;
    rcases n with ( _ | _ | _ | _ | _ | n ) <;> norm_num [ StableOrbits, ClosedOrbits ] at *;
    · exact dim2_not_closed h₂;
    · linarith;
  · rintro rfl; exact dim3_goldilocks;

/-! ## Discrete Bertrand Classification -/

/-- For α = -2 (inverse-square law), the apsidal ratio is 1. -/
theorem bertrand_inverse_square : bertrandApsidalRatio (-2) = 1 := by
  unfold bertrandApsidalRatio
  simp; norm_num

/-- For α = 1 (Hooke's law), the apsidal ratio is 2. -/
theorem bertrand_hooke : bertrandApsidalRatio 1 = 2 := by
  unfold bertrandApsidalRatio
  simp only [Int.cast_one]
  rw [show (3 : ℝ) + 1 = 2 ^ 2 from by norm_num]
  exact Real.sqrt_sq (by norm_num : (2 : ℝ) ≥ 0)

/-- For α = -1, the apsidal ratio is √2, which is irrational. -/
theorem bertrand_alpha_neg1_irrational : Irrational (bertrandApsidalRatio (-1)) := by
  unfold bertrandApsidalRatio
  have : (3 : ℝ) + ((-1 : ℤ) : ℝ) = 2 := by norm_num
  rw [this]
  exact irrational_sqrt_two

/-- For α = 0, the apsidal ratio is √3, which is irrational. -/
theorem bertrand_alpha_0_irrational : Irrational (bertrandApsidalRatio 0) := by
  unfold bertrandApsidalRatio
  have : (3 : ℝ) + ((0 : ℤ) : ℝ) = 3 := by norm_num
  rw [this]
  exact sqrt_three_irrational

/-- For α = 2, the apsidal ratio is √5, which is irrational. -/
theorem bertrand_alpha_2_irrational : Irrational (bertrandApsidalRatio 2) := by
  unfold bertrandApsidalRatio
  have : (3 : ℝ) + ((2 : ℤ) : ℝ) = 5 := by norm_num
  rw [this]
  exact sqrt_five_irrational

/-- **Discrete Bertrand Classification**: Among integer force-law exponents
    -2 ≤ α ≤ 2, the apsidal ratio √(3+α) is rational if and only if
    α = -2 or α = 1. -/
theorem discrete_bertrand_classification (α : ℤ) (hlo : -2 ≤ α) (hhi : α ≤ 2) :
    ¬ Irrational (bertrandApsidalRatio α) ↔ α = -2 ∨ α = 1 := by
  constructor
  · intro hrat
    interval_cases α
    · left; rfl
    · exact absurd bertrand_alpha_neg1_irrational hrat
    · exact absurd bertrand_alpha_0_irrational hrat
    · right; rfl
    · exact absurd bertrand_alpha_2_irrational hrat
  · rintro (rfl | rfl)
    · rw [bertrand_inverse_square]; exact not_irrational_one
    · rw [bertrand_hooke]; exact Int.not_irrational 2

/-! ## Number Theory ↔ Physics Bridge -/

/-- **Number Theory—Physics Bridge**: The physical question "does dimension n
    support closed orbits?" reduces to the number-theoretic question
    "is √(4-n) rational?". -/
theorem closed_orbit_iff_sqrt_rational (n : ℕ) :
    ClosedOrbits n ↔ ¬ Irrational (Real.sqrt (4 - (n : ℝ))) := by
  rfl

/-! ## Escape Velocity and Full Goldilocks -/

/-- In n spatial dimensions, escape velocity is finite iff n ≥ 3. -/
def FiniteEscapeVelocity (n : ℕ) : Prop := n ≥ 3

/-- The full Goldilocks characterization: dimension 3 is the unique dimension
    with stable closed orbits AND finite escape velocity. -/
theorem goldilocks_full (n : ℕ) (hn : n ≥ 2) :
    (GoldilocksProperty n ∧ FiniteEscapeVelocity n) ↔ n = 3 := by
  constructor
  · intro ⟨hgold, _⟩
    exact (goldilocks_unique n hn).mp hgold
  · rintro rfl
    exact ⟨dim3_goldilocks, by simp [FiniteEscapeVelocity]⟩

/-! ## Extended Results -/

/-- For any prime p, √p is irrational. -/
theorem sqrt_prime_irrational (p : ℕ) (hp : Nat.Prime p) : Irrational (Real.sqrt p) :=
  hp.irrational_sqrt

/-- The "if" direction of General Bertrand Rationality:
    If 3+α = q² for some q ∈ ℚ≥0, then √(3+α) is rational. -/
theorem general_bertrand_if (α : ℝ) (_hα : α > -3) :
    (∃ q : ℚ, (q : ℝ) ≥ 0 ∧ 3 + α = (q : ℝ) ^ 2) →
    ¬ Irrational (Real.sqrt (3 + α)) := by
  rintro ⟨q, hq_nn, hq_eq⟩
  rw [hq_eq, Real.sqrt_sq hq_nn]
  exact Rat.not_irrational q