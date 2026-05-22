/-
# Tropical Gravitational Dynamics

A rigorous mathematical framework connecting tropical (min-plus) algebra to
causal propagation, discrete radial geometry, evolution operators, and
horizon fixed-point theorems.

## Key concepts
- **Tropical superposition**: idempotent aggregation via `min`
- **Radial cost metric**: cumulative edge-weight distance on ℕ-indexed lattice
- **Tropical Einstein evolution**: monotone min-plus initial value problem
- **Tropical Schwarzschild horizon**: fixed-point/threshold characterization

## Cross-domain connections
- Dynamic programming / Bellman equations
- Hamilton–Jacobi theory (idempotent linearization)
- Shortest-path algorithms on weighted graphs
- Tropical spectral theory and eigenpairs
-/

import Mathlib

open Finset

/-! ## Section 1: Tropical Superposition -/

/-- Tropical superposition: the min-plus analogue of quantum superposition.
    In the tropical semiring (ℝ, min, +), `min` plays the role of addition. -/
def tropSup (a b : ℝ) : ℝ := min a b

/-
Tropical superposition is idempotent: superposing a state with itself
    leaves it unchanged. This is the min-convention dual of
    `tropical_universal_idempotent` (which uses max).
-/
theorem tropSup_idempotent (a : ℝ) : tropSup a a = a := by
  exact min_self a

/-
Tropical superposition is monotone in its first argument.
-/
theorem tropSup_monotone_left {a b c : ℝ} (h : a ≤ b) :
    tropSup a c ≤ tropSup b c := by
  exact min_le_min h le_rfl

/-
Tropical superposition is monotone in its second argument.
-/
theorem tropSup_monotone_right {a b c : ℝ} (h : b ≤ c) :
    tropSup a b ≤ tropSup a c := by
  -- Since min is monotone in both arguments, we can apply this property directly.
  apply min_le_min; exact le_refl a; exact h

/-
Tropical superposition is commutative.
-/
theorem tropSup_comm (a b : ℝ) : tropSup a b = tropSup b a := by
  exact min_comm _ _

/-
Tropical superposition is associative.
-/
theorem tropSup_assoc (a b c : ℝ) :
    tropSup (tropSup a b) c = tropSup a (tropSup b c) := by
  exact min_assoc _ _ _

/-! ## Section 2: Radial Cost Metric on a Discrete Lattice -/

/-- Cumulative cost of traversing a discrete radial lattice from position `i` to `j`,
    with edge weights `w`. This defines a pseudo-metric structure when weights are nonneg. -/
noncomputable def radialCost (w : ℕ → ℝ) (i j : ℕ) : ℝ :=
  if i ≤ j then ∑ k ∈ Finset.Ico i j, w k
  else ∑ k ∈ Finset.Ico j i, w k

/-
The cost from a point to itself is zero.
-/
theorem radialCost_self (w : ℕ → ℝ) (i : ℕ) :
    radialCost w i i = 0 := by
  -- By definition of radialCost, when i = j, the sum is over an empty range, which is zero.
  simp [radialCost]

/-
The radial cost is symmetric.
-/
theorem radialCost_symm (w : ℕ → ℝ) (i j : ℕ) :
    radialCost w i j = radialCost w j i := by
  unfold radialCost;
  grind

/-
Triangle inequality for radial cost with nonnegative weights.
    This establishes that (ℕ, radialCost w) is a pseudo-metric space.
-/
theorem radialCost_triangle (w : ℕ → ℝ) (hw : ∀ k, 0 ≤ w k)
    (i j k : ℕ) :
    radialCost w i k ≤ radialCost w i j + radialCost w j k := by
  unfold radialCost;
  split_ifs <;> simp_all +decide [ Finset.sum_Ico_consecutive ];
  any_goals linarith;
  · exact le_add_of_le_of_nonneg ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Ico_subset_Ico_right ( by linarith ) ) fun _ _ _ => hw _ ) ( Finset.sum_nonneg fun _ _ => hw _ );
  · exact le_add_of_nonneg_of_le ( Finset.sum_nonneg fun _ _ => hw _ ) ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Ico_subset_Ico ( by linarith ) le_rfl ) fun _ _ _ => hw _ );
  · exact le_add_of_nonneg_of_le ( Finset.sum_nonneg fun _ _ => hw _ ) ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Ico_subset_Ico_right ( by linarith ) ) fun _ _ _ => hw _ );
  · exact le_add_of_le_of_nonneg ( Finset.sum_le_sum_of_subset_of_nonneg ( Finset.Ico_subset_Ico ( by linarith ) le_rfl ) fun _ _ _ => hw _ ) ( Finset.sum_nonneg fun _ _ => hw _ );
  · rw [ add_comm, Finset.sum_Ico_consecutive ] <;> linarith

/-
Radial cost is nonnegative when weights are nonnegative.
-/
theorem radialCost_nonneg (w : ℕ → ℝ) (hw : ∀ k, 0 ≤ w k) (i j : ℕ) :
    0 ≤ radialCost w i j := by
  unfold radialCost;
  split_ifs <;> exact Finset.sum_nonneg fun _ _ => hw _

/-! ## Section 3: Tropical Einstein Evolution -/

/-- One-step tropical Einstein evolution: a min-plus update combining
    the current value with the potential-shifted neighbor value.
    This is the tropical analogue of a discrete Hamilton–Jacobi step. -/
def tropEinsteinStep (V φ : ℕ → ℝ) (n : ℕ) : ℝ :=
  min (φ n) (V n + φ (n + 1))

/-
Well-posedness: the evolved state exists and is unique.
-/
theorem tropEinstein_wellposed (V φ : ℕ → ℝ) :
    ∃! ψ : ℕ → ℝ, ψ = tropEinsteinStep V φ := by
  exact ⟨ _, rfl, fun ψ hψ => hψ.symm ▸ rfl ⟩

/-
Monotonicity of one-step evolution: if initial data φ ≤ ψ pointwise,
    then evolved data preserves the ordering. This is the key stability property.
-/
theorem tropEinstein_monotone {V φ ψ : ℕ → ℝ}
    (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEinsteinStep V φ n ≤ tropEinsteinStep V ψ n := by
  -- By definition of $tropEinsteinStep$, we have:
  intros n
  simp [tropEinsteinStep];
  exact ⟨ Or.inl <| hφψ n, Or.inr <| hφψ _ ⟩

/-
The evolution operator is nonexpansive: it does not increase
    the pointwise gap between two initial data profiles.
-/
theorem tropEinstein_nonexpansive {V φ ψ : ℕ → ℝ} (n : ℕ) :
    tropEinsteinStep V φ n - tropEinsteinStep V ψ n ≤
    max (φ n - ψ n) (φ (n + 1) - ψ (n + 1)) := by
  unfold tropEinsteinStep;
  cases max_cases ( φ n - ψ n ) ( φ ( n + 1 ) - ψ ( n + 1 ) ) <;> cases min_cases ( φ n ) ( V n + φ ( n + 1 ) ) <;> cases min_cases ( ψ n ) ( V n + ψ ( n + 1 ) ) <;> linarith

/-- Multi-step tropical evolution by iterating the one-step operator. -/
def tropEvolve (V : ℕ → ℝ) : ℕ → (ℕ → ℝ) → (ℕ → ℝ)
  | 0, φ => φ
  | t + 1, φ => tropEinsteinStep V (tropEvolve V t φ)

/-
Uniqueness of multi-step evolution.
-/
theorem tropEvolve_unique (V : ℕ → ℝ) (t : ℕ) (φ : ℕ → ℝ) :
    ∃! ψ : ℕ → ℝ, ψ = tropEvolve V t φ := by
  exact ⟨ _, rfl, fun ψ hψ => hψ.symm ▸ rfl ⟩

/-
Multi-step evolution preserves monotonicity of initial data.
-/
theorem tropEvolve_monotone (V : ℕ → ℝ) (t : ℕ)
    {φ ψ : ℕ → ℝ} (hφψ : ∀ n, φ n ≤ ψ n) :
    ∀ n, tropEvolve V t φ n ≤ tropEvolve V t ψ n := by
  induction' t with t ih <;> simp_all +decide [ tropEvolve ];
  exact?

/-! ## Section 4: Tropical Schwarzschild Horizon -/

/-- Inward travel cost in a radial tropical spacetime. -/
def inwardCost (_m r : ℝ) : ℝ := r

/-- Outward travel cost in a radial tropical spacetime. -/
def outwardCost (m _r : ℝ) : ℝ := 2 * m

/-- The tropical radial update operator: takes the min of the current
    radius and the Schwarzschild radius 2m. Points beyond the horizon
    are "absorbed" to the horizon value. -/
def tropRadiusUpdate (m r : ℝ) : ℝ := min r (2 * m)

/-- The horizon predicate: inward and outward costs coincide. -/
def horizonPredicate (m r : ℝ) : Prop := inwardCost m r = outwardCost m r

/-
Existence and uniqueness of the nonneg horizon radius.
-/
theorem tropical_horizon_exists_unique (m : ℝ) (hm : 0 ≤ m) :
    ∃! r : ℝ, 0 ≤ r ∧ horizonPredicate m r := by
  -- The horizon predicate is satisfied if and only if r = 2 * m.
  use 2 * m
  simp [horizonPredicate, inwardCost, outwardCost];
  exact hm

/-
The Schwarzschild radius 2m is a fixed point of the tropical update.
-/
theorem tropical_horizon_fixed_point (m : ℝ) :
    tropRadiusUpdate m (2 * m) = 2 * m := by
  unfold tropRadiusUpdate; norm_num;

/-
Any radius beyond the horizon is absorbed to 2m.
-/
theorem tropical_horizon_absorbing (m r : ℝ) (hr : 2 * m ≤ r) :
    tropRadiusUpdate m r = 2 * m := by
  -- Apply the min_eq_right_iff lemma with the given hr.
  apply min_eq_right; exact hr

/-
The horizon is the least fixed point: any fixed point of the
    tropical radial update satisfies r ≤ 2m.
-/
theorem tropical_horizon_least_fixed (m r : ℝ)
    (hfix : tropRadiusUpdate m r = r) :
    r ≤ 2 * m := by
  exact hfix ▸ min_le_right _ _

/-
Complete characterization: the fixed points of tropRadiusUpdate are
    exactly the values r ≤ 2m.
-/
theorem tropical_horizon_fixed_iff (m r : ℝ) :
    tropRadiusUpdate m r = r ↔ r ≤ 2 * m := by
  -- By definition of tropRadiusUpdate, we have tropRadiusUpdate m r = min r (2 * m).
  simp [tropRadiusUpdate]

/-! ## Section 5: Finite-State Tropical Transfer Operator -/

/-- Min-plus matrix-vector product: the tropical analogue of a
    linear transfer operator on Fin (n+1). -/
noncomputable def tropTransfer {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ)
    (φ : Fin (n+1) → ℝ) : Fin (n+1) → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j + φ j)

/-
Monotonicity of the tropical transfer operator.
-/
theorem tropTransfer_monotone {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ)
    {φ ψ : Fin (n+1) → ℝ} (hφψ : ∀ i, φ i ≤ ψ i) :
    ∀ i, tropTransfer W φ i ≤ tropTransfer W ψ i := by
  -- By definition of tropTransfer, we have:
  intro i
  simp [tropTransfer];
  exact fun j => ⟨ j, by linarith [ hφψ j ] ⟩

/-
Adding a constant to all inputs shifts the output by the same constant.
    This is the tropical analogue of linearity (homogeneity).
-/
theorem tropTransfer_shift {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ)
    (φ : Fin (n+1) → ℝ) (c : ℝ) :
    ∀ i, tropTransfer W (fun j => φ j + c) i = tropTransfer W φ i + c := by
  -- By definition of tropTransfer, we have:
  have h_def : ∀ i, tropTransfer W (fun j => φ j + c) i = Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j + (φ j + c)) := by
    exact?;
  simp_all +decide [ Finset.inf'_eq_csInf_image ];
  intro i; rw [ show ( Set.range fun j => W i j + ( φ j + c ) ) = ( fun x => x + c ) '' ( Set.range fun j => W i j + φ j ) from ?_ ] ; rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ] ;
  · exact ⟨ _, ⟨ _, ⟨ i, rfl ⟩, rfl ⟩ ⟩;
  · simp +decide [ tropTransfer ];
    exact fun a x hx => by linarith [ show ( Finset.inf' Finset.univ Finset.univ_nonempty fun j => W i j + φ j ) ≤ W i x + φ x from Finset.inf'_le _ ( Finset.mem_univ x ) ] ;
  · simp_all +decide [ tropTransfer ];
    intro w hw; obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => W i x + φ x ) ; use W i j + φ j + c; aesop;
  · ext; simp [Set.mem_range, Set.mem_image];
    exact ⟨ fun ⟨ y, hy ⟩ => ⟨ y, by linear_combination hy ⟩, fun ⟨ y, hy ⟩ => ⟨ y, by linear_combination hy ⟩ ⟩

/-! ## Section 6: Bridge Theorem — Evolution on Weighted Graph -/

/-- One-step min-plus evolution on a finite weighted digraph.
    This applies the tropical transfer operator, computing the
    minimum cost to reach each node in one additional step. -/
noncomputable def graphStep {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ)
    (φ : Fin (n+1) → ℝ) : Fin (n+1) → ℝ :=
  tropTransfer W φ

/-- Iterated graph evolution. -/
noncomputable def graphEvolve {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ) :
    ℕ → (Fin (n+1) → ℝ) → (Fin (n+1) → ℝ)
  | 0, φ => φ
  | t + 1, φ => graphStep W (graphEvolve W t φ)

/-
Iterated graph evolution preserves ordering.
-/
theorem graphEvolve_monotone {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ)
    (t : ℕ) {φ ψ : Fin (n+1) → ℝ} (hφψ : ∀ i, φ i ≤ ψ i) :
    ∀ i, graphEvolve W t φ i ≤ graphEvolve W t ψ i := by
  induction' t with t ih <;> simp_all +decide [ graphEvolve, graphStep ];
  exact fun i => tropTransfer_monotone _ ih i

/-
A constant potential is a tropical eigenvector with eigenvalue
    equal to the row minimum of W. Specifically, if φ is constant,
    then (tropTransfer W φ) i = (row-min of W at i) + φ j for any j.
-/
theorem tropTransfer_const {n : ℕ} (W : Fin (n+1) → Fin (n+1) → ℝ) (c : ℝ) :
    ∀ i, tropTransfer W (fun _ => c) i =
      Finset.inf' Finset.univ Finset.univ_nonempty (fun j => W i j) + c := by
  intro i
  unfold tropTransfer;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le ];
  · simpa using Finset.exists_min_image Finset.univ ( fun j => W i j ) ⟨ i, Finset.mem_univ i ⟩;
  · exact fun j => ⟨ j, le_rfl ⟩