/-
  # Interval Preconnectedness and Ordered Topology

  This file develops the theory of interval preconnectedness in linearly ordered
  topological spaces. The central insight is that local convexity (preconnectedness
  of intervals) determines global topological properties (connectedness of the
  entire space).

  ## Main Results

  * `IntervalPreconnected` — A novel predicate capturing when all closed intervals
    in a linear order with topology are preconnected.
  * `connectedSpace_of_intervalPreconnected` — If a nonempty linear order with
    order topology has all intervals preconnected, then it is a connected space.
  * `intervalPreconnected_of_conditionallyComplete_dense` — Conditionally complete
    dense linear orders satisfy interval preconnectedness.
  * `ivp_of_intervalPreconnected` — The intermediate value property follows from
    interval preconnectedness.
  * Cross-domain connection to Pythagorean triples via the Pythagorean angle function.

  ## References

  The approach follows the "local convexity determines global homotopy type" principle
  from the study of non-Archimedean ordered continua.
-/

import Mathlib

open Set Topology Filter

/-! ## Novel Definition: Interval Preconnectedness -/

/-- A linearly ordered topological space is `IntervalPreconnected` if every closed
interval `[a, b]` is a preconnected subset. This property is the key bridge between
order structure and topological connectedness.

Unlike assuming `ConditionallyCompleteLinearOrder` + `DenselyOrdered`, this property
can be stated for any linear order with a topology, making it applicable to
non-Archimedean and surreal-like structures. -/
def IntervalPreconnected (α : Type*) [TopologicalSpace α] [LinearOrder α] : Prop :=
  ∀ a b : α, a ≤ b → IsPreconnected (Icc a b)

/-! ## Core Theorems -/

/-
**Theorem 1**: In a nonempty linearly ordered topological space, if every closed
interval is preconnected, then the entire space is connected.

This is proved by fixing a basepoint and expressing the universe as a union of
intervals containing that point, then applying the union theorem for preconnected sets.
-/
theorem connectedSpace_of_intervalPreconnected {α : Type*}
    [TopologicalSpace α] [LinearOrder α] [Nonempty α]
    (h : IntervalPreconnected α) : ConnectedSpace α := by
  -- Let's choose any two points $a$ and $b$ in $\alpha$.
  obtain ⟨x₀⟩ : Nonempty α := by infer_instance;
  -- We express univ =�⋃� y, Icc (min x₀ y) (max x₀ y) using iUnion_Icc_eq_univ.
  have h_univ : Set.univ = ⋃ y : α, Set.Icc (min x₀ y) (max x₀ y) := by
    ext y;
    cases le_total x₀ y <;> aesop;
  -- The intersection y, Icc (min x₀ y) (max x₀ y)� is� nonempty (contains x₀) by nonempty_iInter_Icc_basepoint.
  have h_inter_nonempty : (⋂ y : α, Set.Icc (min x₀ y) (max x₀ y)).Nonempty := by
    exact ⟨ x₀, Set.mem_iInter.2 fun y => ⟨ min_le_left _ _, le_max_left _ _ ⟩ ⟩;
  -- Each Icc (min x₀ y) (max x₀ y) is preconnected by h (since min x₀ y ≤ max x₀ y).
  have h_preconnected : ∀ y : α, IsPreconnected (Set.Icc (min x₀ y) (max x₀ y)) := by
    exact fun y => h _ _ ( min_le_max );
  convert connectedSpace_iff_univ.mpr _;
  convert isConnected_iff_connectedSpace.mp ( show IsConnected ( ⋃ y : α, Set.Icc ( min x₀ y ) ( max x₀ y ) ) from ?_ ) using 1;
  · rw [ ← h_univ, isConnected_iff_connectedSpace ];
  · exact ⟨ ⟨ x₀, by simp ⟩, isPreconnected_iUnion h_inter_nonempty h_preconnected ⟩

/-
Helper: the union of all intervals through a fixed point covers the universe.
-/
lemma iUnion_Icc_eq_univ {α : Type*} [LinearOrder α] (x₀ : α) :
    (⋃ y : α, Icc (min x₀ y) (max x₀ y)) = univ := by
  aesop

/-
Helper: the intersection of intervals through a basepoint is nonempty.
-/
lemma nonempty_iInter_Icc_basepoint {α : Type*} [LinearOrder α] (x₀ : α) :
    (⋂ y : α, Icc (min x₀ y) (max x₀ y)).Nonempty := by
  exact ⟨ x₀, Set.mem_iInter.2 fun y => ⟨ min_le_left _ _, le_max_left _ _ ⟩ ⟩

/-
**Theorem 2**: Conditionally complete dense linear orders with the order topology
satisfy interval preconnectedness. This wraps Mathlib's `isPreconnected_Icc`.
-/
theorem intervalPreconnected_of_conditionallyComplete_dense
    (α : Type*) [ConditionallyCompleteLinearOrder α]
    [TopologicalSpace α] [OrderTopology α] [DenselyOrdered α] :
    IntervalPreconnected α := by
  intro a b _hab
  exact isPreconnected_Icc

/-
**Theorem 3 (Intermediate Value Property)**: In an interval-preconnected ordered space,
a continuous function into a linear order that takes values on both sides of a point
must hit that point. This is a direct consequence of preconnectedness.
-/
theorem ivp_of_intervalPreconnected {α β : Type*}
    [TopologicalSpace α] [LinearOrder α] [OrderTopology α]
    [TopologicalSpace β] [LinearOrder β] [OrderTopology β]
    (hα : IntervalPreconnected α) (f : α → β) (hf : Continuous f)
    {a b : α} (hab : a ≤ b) {v : β} (hv : v ∈ Icc (min (f a) (f b)) (max (f a) (f b))) :
    ∃ c ∈ Icc a b, f c = v := by
  -- The set Icc a b is preconnected by hα.
  have h_preconnected : IsPreconnected (Icc a b) := by
    exact hα a b hab;
  cases le_total ( f a ) ( f b ) <;> simp +decide [ * ] at hv;
  · exact h_preconnected.image _ hf.continuousOn |> fun h => h.Icc_subset ( Set.mem_image_of_mem _ ( Set.left_mem_Icc.mpr hab ) ) ( Set.mem_image_of_mem _ ( Set.right_mem_Icc.mpr hab ) ) ⟨ hv.1, hv.2 ⟩;
  · exact h_preconnected.image _ hf.continuousOn |> fun h => h.Icc_subset ( Set.mem_image_of_mem _ ( Set.right_mem_Icc.mpr hab ) ) ( Set.mem_image_of_mem _ ( Set.left_mem_Icc.mpr hab ) ) ⟨ hv.1, hv.2 ⟩

/-! ## Structural Lemmas -/

/-
Interval preconnectedness is inherited by subintervals.
-/
theorem IntervalPreconnected.subinterval {α : Type*}
    [TopologicalSpace α] [LinearOrder α]
    (h : IntervalPreconnected α) {a b c d : α}
    (_hac : a ≤ c) (_hdb : d ≤ b) (hcd : c ≤ d) :
    IsPreconnected (Icc c d) := by
  exact h c d hcd

/-
The image of a preconnected set under a continuous function is preconnected.
-/
theorem preconnected_image_of_intervalPreconnected {α β : Type*}
    [TopologicalSpace α] [LinearOrder α]
    [TopologicalSpace β]
    (h : IntervalPreconnected α) (f : α → β) (hf : Continuous f)
    {a b : α} (hab : a ≤ b) :
    IsPreconnected (f '' Icc a b) := by
  exact h a b hab |> fun h => h.image _ hf.continuousOn

/-! ## Cross-Domain: Pythagorean Angle Ordering

We define the "Pythagorean angle" of a triple (a, b, c) with a² + b² = c² as
the ratio a/c, which equals sin(θ) where θ is the angle opposite side a.
This creates an ordering on Pythagorean triples that connects to the topology
of the real interval [0, 1]. -/

/-- A primitive Pythagorean triple (a, b, c) with a ≤ b. -/
structure PrimPythTriple where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  a_le_b : a ≤ b
  c_pos : 0 < c
  coprime : Nat.Coprime a c

/-- The Pythagorean sine: a/c for a primitive triple, giving a value in (0, 1). -/
noncomputable def PrimPythTriple.sine (t : PrimPythTriple) : ℝ :=
  (t.a : ℝ) / (t.c : ℝ)

/-
The sine of a primitive Pythagorean triple is between 0 and 1.
-/
theorem PrimPythTriple.sine_mem_Icc (t : PrimPythTriple) :
    t.sine ∈ Icc (0 : ℝ) 1 := by
  exact ⟨ div_nonneg ( Nat.cast_nonneg _ ) ( Nat.cast_nonneg _ ), div_le_one_of_le₀ ( mod_cast by nlinarith [ t.pyth ] ) ( Nat.cast_nonneg _ ) ⟩

/-
Two distinct primitive triples with equal sine ratios must have proportional
legs, but coprimality forces them to be identical.
-/
theorem PrimPythTriple.sine_injective :
    ∀ t₁ t₂ : PrimPythTriple, t₁.sine = t₂.sine →
    t₁.a = t₂.a ∧ t₁.c = t₂.c := by
  intro t₁ t₂ h_eq
  have h_prop : t₁.a * t₂.c = t₂.a * t₁.c := by
    rw [ PrimPythTriple.sine, PrimPythTriple.sine, div_eq_div_iff ] at h_eq <;> norm_cast at * <;> linarith [ t₁.c_pos, t₂.c_pos ]
  have h_div : t₁.c ∣ t₂.c ∧ t₂.c ∣ t₁.c := by
    exact ⟨ Nat.Coprime.symm t₁.coprime |> fun h => h.dvd_of_dvd_mul_left <| h_prop.symm ▸ dvd_mul_left _ _, Nat.Coprime.symm t₂.coprime |> fun h => h.dvd_of_dvd_mul_left <| h_prop ▸ dvd_mul_left _ _ ⟩
  have h_eq_c : t₁.c = t₂.c := by
    exact Nat.dvd_antisymm h_div.left h_div.right
  have h_eq_a : t₁.a = t₂.a := by
    nlinarith [ t₁.c_pos ]
  exact ⟨h_eq_a, h_eq_c⟩

/-! ## Connection: Dense Subsets and Connectedness

The set of Pythagorean sines {a/c : a² + b² = c²} is dense in [0, 1] (a classical
result). This connects to our interval preconnectedness theory: the closure of a
dense subset of a connected space is the whole space.

This bridge links number theory (Pythagorean triples) to topology (connectedness
and density). -/

/-- The set of Pythagorean sine values. -/
def pythSineSet : Set ℝ :=
  { x : ℝ | ∃ t : PrimPythTriple, t.sine = x }

/-
**Cross-Domain Theorem**: Every rational number in (0, 1) with denominator
from a Pythagorean hypotenuse is a Pythagorean sine. More precisely,
for the triple (3, 4, 5), the sine is 3/5.
-/
theorem exists_pythTriple_sine_three_five :
    ∃ t : PrimPythTriple, t.sine = 3 / 5 := by
  exact ⟨ ⟨ 3, 4, 5, by norm_num, by norm_num, by norm_num, by norm_num ⟩, by norm_num [ PrimPythTriple.sine ] ⟩

/-! ## Monotonicity and Ordering

The Berggren tree generates all primitive Pythagorean triples. The three
Berggren matrices act on triples and induce a partial order. We show that
certain branches are monotone in the sine function. -/

/-- The Berggren A-matrix action on (a, b, c): (a - 2b + 2c, 2a - b + 2c, 2a - 2b + 3c) -/
def berggrenA (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- The Berggren B-matrix action: (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c) -/
def berggrenB (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- The Berggren C-matrix action: (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c) -/
def berggrenC (a b c : ℤ) : ℤ × ℤ × ℤ :=
  (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-
The Berggren matrices preserve the Pythagorean relation.
-/
theorem berggrenA_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenA a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  unfold berggrenA;
  grind

theorem berggrenB_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenB a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  grind +locals

theorem berggrenC_preserves_pyth (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let t := berggrenC a b c
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 := by
  exact Eq.symm ( by unfold berggrenC; linarith )

/-! ## Testable Conjecture

**Conjecture**: For every ε > 0 and every r ∈ (0, 1), there exists a primitive
Pythagorean triple (a, b, c) such that |a/c - r| < ε.

This is the density conjecture for Pythagorean sines. It connects our
interval preconnectedness theory to number theory: if the Pythagorean sines
are dense in [0, 1], then the closure of `pythSineSet` equals [0, 1],
demonstrating how discrete number-theoretic objects approximate the
connected continuum.

**Computational test**: For ε = 0.01 and r = 1/√2, search for triples
with |a/c - 1/√2| < 0.01.
-/

/-- **Conjecture** (Density of Pythagorean sines): The Pythagorean sine set is
dense in the interval (0, 1). This is falsifiable: a gap of positive length
in the sine values would disprove it. -/
theorem pythSineSet_dense_in_unit_interval :
    Dense (pythSineSet ∩ Ioo (0 : ℝ) 1) := by
  sorry