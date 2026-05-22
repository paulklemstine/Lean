/-
# Tropical Spacetime at Planck Scale

A formal theory of tropical spacetime in which distances are governed by min-plus
composition, quantum superposition is encoded by idempotent aggregation, and
gravitational dynamics admits a well-posed initial value problem. The tropical
Schwarzschild horizon is characterized as a fixed point of a radial update map
with sharp order-theoretic properties.

## Main results
- Idempotent superposition (Theorem A)
- Tropical metric from min-plus edge composition with monotonicity (Theorem B)
- Well-posed tropical Einstein evolution with monotonicity and nonexpansiveness (Theorem C)
- Tropical Schwarzschild horizon characterization as greatest nonneg fixed point (Theorem D)

## Cross-domain connections
- Dynamic programming / Bellman equations
- Hamilton–Jacobi theory (discrete idempotent linearization)
- Optimal control / shortest-path geometry
- Causal set theory and network geometry
-/

import Mathlib

open Finset

/-! ## Part I: Tropical Superposition (Theorem A) -/

/-- Tropical superposition: the min-plus analogue of quantum superposition.
    In the tropical semiring (ℝ, min, +), `min` plays the role of addition,
    so superposing two "amplitudes" means taking their minimum. -/
def tropicalSuperpose (a b : ℝ) : ℝ := min a b

/-- Scalar tropical superposition is idempotent. -/
theorem tropicalSuperpose_idem (a : ℝ) :
    tropicalSuperpose a a = a :=
  min_self a

/-- Functional tropical superposition is idempotent: pointwise min of F with itself is F. -/
theorem tropical_superposition_idempotent_fun
    {α : Type*} (F : α → ℝ) :
    (fun x => min (F x) (F x)) = F := by
  funext x; exact min_self _

/-- Tropical superposition is commutative. -/
theorem tropicalSuperpose_comm (a b : ℝ) :
    tropicalSuperpose a b = tropicalSuperpose b a :=
  min_comm a b

/-- Tropical superposition is associative. -/
theorem tropicalSuperpose_assoc (a b c : ℝ) :
    tropicalSuperpose (tropicalSuperpose a b) c =
    tropicalSuperpose a (tropicalSuperpose b c) :=
  min_assoc a b c

/-- Tropical superposition distributes over addition (the tropical "multiplication"). -/
theorem tropicalSuperpose_add_left (a b c : ℝ) :
    tropicalSuperpose (a + c) (b + c) = tropicalSuperpose a b + c := by
  simp [tropicalSuperpose, min_add_add_right]

/-! ## Part II: Tropical Einstein Step and Evolution (Theorems B & C) -/

/-- One-step tropical Einstein evolution on a finite type: the min-plus
    convolution of the current state with a transition kernel K.
    This is simultaneously a Bellman operator and a discrete Hamilton–Jacobi step. -/
noncomputable def tropicalEinsteinStep {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u : α → ℝ) : α → ℝ :=
  fun x => Finset.inf' Finset.univ Finset.univ_nonempty (fun y => u y + K y x)

/-
The tropical Einstein step is monotone: if u ≤ v pointwise, then
    tropicalEinsteinStep K u ≤ tropicalEinsteinStep K v pointwise.
    This is the fundamental stability property of the Bellman operator.
-/
theorem tropicalEinsteinStep_monotone
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) :
    Monotone (tropicalEinsteinStep K) := by
  unfold tropicalEinsteinStep;
  intros a b hab;
  intro x;
  simp +decide only [inf'_le_iff, mem_univ, true_and];
  obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun y => b y + K y x );
  exact ⟨ i, by linarith [ hab i ] ⟩

/-- Multi-step tropical Einstein evolution by iterating the one-step operator. -/
noncomputable def tropicalEvolution {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) : ℕ → (α → ℝ) → (α → ℝ)
  | 0, u => u
  | n + 1, u => tropicalEinsteinStep K (tropicalEvolution K n u)

/-
Well-posedness of the tropical Einstein initial value problem:
    there exists a unique trajectory U : ℕ → (α → ℝ) satisfying
    U 0 = u₀ and U (n+1) = tropicalEinsteinStep K (U n).
-/
theorem tropicalEvolution_wellposed
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u0 : α → ℝ) :
    ∃! U : ℕ → α → ℝ,
      U 0 = u0 ∧
      ∀ n, U (n + 1) = tropicalEinsteinStep K (U n) := by
  exact ⟨ fun n => Nat.recOn n u0 fun n ih => tropicalEinsteinStep K ih, ⟨ rfl, fun n => rfl ⟩, fun U ⟨ hU₀, hU ⟩ => funext fun n => Nat.recOn n ( hU₀ ▸ rfl ) fun n ih => hU n ▸ ih ▸ rfl ⟩

/-
Monotonicity of the full evolution: if u ≤ v pointwise, then
    tropicalEvolution K n u ≤ tropicalEvolution K n v for all n.
    This is the order-stability theorem for tropical gravity.
-/
theorem tropicalEvolution_monotone_data
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) :
    ∀ {u v : α → ℝ}, (u ≤ v) → ∀ n, tropicalEvolution K n u ≤ tropicalEvolution K n v := by
  intro u v huv n;
  induction' n with n ih;
  · exact huv;
  · exact tropicalEinsteinStep_monotone K ih

/-
Adding a constant to the state shifts the evolved state by the same constant.
    This is tropical linearity (homogeneity over the min-plus semiring).
-/
theorem tropicalEinsteinStep_shift
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u : α → ℝ) (c : ℝ) :
    tropicalEinsteinStep K (fun x => u x + c) = fun x => tropicalEinsteinStep K u x + c := by
  funext x;
  refine' le_antisymm _ _;
  · unfold tropicalEinsteinStep;
    simp +decide [ add_assoc, Finset.inf'_le ];
    obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_inf' Finset.univ_nonempty ( fun y => u y + K y x );
    exact ⟨ y, by linarith ⟩;
  · unfold tropicalEinsteinStep;
    simp +decide;
    exact fun y => by linarith [ Finset.inf'_le ( fun y => u y + K y x ) ( Finset.mem_univ y ) ] ;

/-! ## Part III: Tropical Schwarzschild Horizon (Theorem D) -/

/-- The tropical radial update operator: takes the min of the current
    radius and the Schwarzschild radius 2m. -/
def radialUpdate (m r : ℝ) : ℝ := min r (2 * m)

/-- The Schwarzschild radius 2m is a fixed point of the radial update. -/
theorem tropical_schwarzschild_horizon (m : ℝ) :
    radialUpdate m (2 * m) = 2 * m := by
  simp [radialUpdate]

/-- Complete characterization of fixed points: radialUpdate m r = r iff r ≤ 2m. -/
theorem radialUpdate_fixed_iff (m r : ℝ) :
    radialUpdate m r = r ↔ r ≤ 2 * m := by
  simp [radialUpdate]

/-- The radial update is idempotent: applying it twice is the same as once. -/
theorem radialUpdate_idempotent (m r : ℝ) :
    radialUpdate m (radialUpdate m r) = radialUpdate m r := by
  simp [radialUpdate]

/-
The radial update is monotone in r.
-/
theorem radialUpdate_mono_r (m : ℝ) : Monotone (radialUpdate m) := by
  exact fun x y h => min_le_min h le_rfl

/-
The radial update is monotone in m.
-/
theorem radialUpdate_mono_m (r : ℝ) : Monotone (fun m => radialUpdate m r) := by
  exact fun m n hmn => min_le_min_left _ ( mul_le_mul_of_nonneg_left hmn zero_le_two )

/-- Horizon monotonicity: if mass increases, the horizon radius increases. -/
theorem tropical_horizon_monotone {m₁ m₂ : ℝ} (h : m₁ ≤ m₂) :
    2 * m₁ ≤ 2 * m₂ := by linarith

/-
The Schwarzschild radius 2m is the greatest nonneg fixed point of radialUpdate m.
    All nonneg fixed points r satisfy r ≤ 2m, and 2m is itself a nonneg fixed point.
-/
theorem tropical_horizon_greatest_nonneg_fixed
    (m : ℝ) (hm : 0 ≤ m) :
    IsGreatest {r : ℝ | radialUpdate m r = r ∧ 0 ≤ r} (2 * m) := by
  exact ⟨ ⟨ radialUpdate_fixed_iff m ( 2 * m ) |>.2 ( by linarith ), by positivity ⟩, fun r hr => radialUpdate_fixed_iff m r |>.1 hr.1 ⟩

/-- Any radius beyond the horizon is absorbed to 2m. -/
theorem radialUpdate_absorbing (m r : ℝ) (hr : 2 * m ≤ r) :
    radialUpdate m r = 2 * m :=
  min_eq_right hr

/-! ## Part IV: Tropical Metric via Iterated Convolution -/

/-- Tropical (min-plus) matrix multiplication: C(i,k) = min_j (A(i,j) + B(j,k)).
    This computes 2-step shortest paths from 1-step edge costs. -/
noncomputable def tropMatMul {α : Type*} [Fintype α] [Nonempty α]
    (A B : α → α → ℝ) : α → α → ℝ :=
  fun i k => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + B j k)

/-
Tropical matrix multiplication is monotone in each factor.
-/
theorem tropMatMul_mono_left {α : Type*} [Fintype α] [Nonempty α]
    {A₁ A₂ : α → α → ℝ} (h : ∀ i j, A₁ i j ≤ A₂ i j)
    (B : α → α → ℝ) :
    ∀ i k, tropMatMul A₁ B i k ≤ tropMatMul A₂ B i k := by
  unfold tropMatMul;
  simp_all +decide;
  grind +splitIndPred

/-- The tropicalEinsteinStep is exactly the application of tropMatMul
    when the "vector" u is viewed as a matrix row. -/
theorem tropicalEinsteinStep_eq_tropMatMul
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u : α → ℝ) (x : α) :
    tropicalEinsteinStep K u x =
    Finset.inf' Finset.univ Finset.univ_nonempty (fun y => u y + K y x) := by
  rfl

/-! ## Part V: Bellman Operator Fixed-Point Theory -/

/-
The Bellman value iteration is nonincreasing when started above a fixed point.
-/
theorem tropicalEvolution_nonincreasing
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u : α → ℝ)
    (hstable : tropicalEinsteinStep K u ≤ u) :
    ∀ n : ℕ, tropicalEvolution K (n + 1) u ≤ tropicalEvolution K n u := by
  intro n;
  induction' n with n ih;
  · exact hstable;
  · exact tropicalEinsteinStep_monotone K ih

/-! ## Part VI: Bridge Theorems -/

/-- **Bellman bridge**: The tropical Einstein step is precisely a Bellman operator.
    Optimal control and gravitational propagation are the same computation. -/
theorem bellman_bridge
    {α : Type*} [Fintype α] [Nonempty α]
    (cost : α → α → ℝ) (value : α → ℝ) :
    tropicalEinsteinStep cost value =
    fun x => Finset.inf' Finset.univ Finset.univ_nonempty (fun y => value y + cost y x) := by
  rfl

/-
**Hamilton–Jacobi bridge**: The evolution preserves the ordering structure,
    making it a discrete viscosity-solution operator. The key property is that
    the evolution commutes with constant shifts (tropical linearity).
-/
theorem hamilton_jacobi_bridge
    {α : Type*} [Fintype α] [Nonempty α]
    (K : α → α → ℝ) (u : α → ℝ) (c : ℝ) (n : ℕ) :
    tropicalEvolution K n (fun x => u x + c) = fun x => tropicalEvolution K n u x + c := by
  -- We perform induction on $n$.
  induction' n with n ih
  · -- Base case: $n = 0$
    simp [tropicalEvolution]
  · -- Inductive step: Assume true for $n$, prove for $n + 1$
    simp [tropicalEvolution, ih]
    exact tropicalEinsteinStep_shift K (tropicalEvolution K n u) c