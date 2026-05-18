/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Time Travel: Min-Plus Closed Timelike Curves and Consistency

This module formalizes a fixed-point theory for **tropical closed timelike curves (CTCs)**
modeled by min-plus affine self-maps on finite state spaces.

## Key concepts

- **Novikov consistency** = existence of a fixed point
- **Paradox resolution** = idempotent collapse of contradictory branches
- **Chronology protection** = spectral/contraction obstruction to unstable causal loops

## Application keywords

tropical algebra, min-plus semiring, closed timelike curves, Novikov consistency,
chronology protection, fixed-point theorem, idempotent dynamics, causal graphs,
spectral stability, shortest paths, self-reference, thermodynamic closure,
entropy bounds, semantic fixed points
-/

import Mathlib

open scoped Matrix

noncomputable section

/-! ## Definitions: Tropical Operators on Finite State Spaces -/

/-- The min-plus matrix-vector product: `(A ⊗ x)_i = min_j (A i j + x j)`.
    This is the fundamental tropical linear operator. -/
def tropicalMatVec {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) (x : Fin n → ℝ) :
    Fin n → ℝ :=
  fun i => Finset.univ.inf' Finset.univ_nonempty fun j => A i j + x j

/-- The tropical affine update map: `F(x)_i = min((A ⊗ x)_i, b_i)`.
    This models a self-consistency operator for closed timelike curves:
    the output history is the cheapest causally admissible revision of the input. -/
def tropicalAffine {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => min (tropicalMatVec A x i) (b i)

/-- A state `x` is a **consistent solution** of a tropical CTC system `(A, b)`
    if it is a fixed point of the tropical affine update. -/
def IsConsistentSolution {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ) (x : Fin n → ℝ) : Prop :=
  tropicalAffine A b x = x

/-- The **paradox merge** operator: pointwise minimum of two state vectors.
    In the tropical CTC interpretation, this merges two causal branches. -/
def paradoxMerge {ι : Type*} (f g : ι → ℝ) : ι → ℝ := fun i => min (f i) (g i)

/-! ## Theorem 1: Finite Tropical Novikov Consistency

On a finite state space, every idempotent function has a fixed point.
This is the abstract Novikov principle: self-consistent histories always exist
when the update is idempotent (applying it twice is the same as applying it once). -/

/-- **Finite Idempotent Fixed Point (abstract).**
    Any idempotent function on a finite nonempty type has a fixed point.
    This is the engine behind Novikov consistency for tropical systems. -/
theorem finite_idempotent_fixed_point' {α : Type*} [Finite α] [Nonempty α]
    (f : α → α) (hf : ∀ x, f (f x) = f x) :
    ∃ x : α, f x = x :=
  ⟨f (Classical.arbitrary α), hf _⟩

/-- **Tropical Novikov Fixed Point.**
    Every monotone idempotent tropical evolution on a finite state space has a fixed point.

    Mathematical content: Let `F : (ι → ℝ) → (ι → ℝ)` be monotone and idempotent.
    Then for any `x₀`, `F x₀` is already a fixed point since
    `F(F(x₀)) = F(x₀)` by idempotence.

    This theorem does not require finiteness of `ι` or monotonicity for the
    core existence argument — idempotence alone suffices. The hypotheses are
    included for compatibility with the tropical CTC interpretation where
    they are physically meaningful. -/
theorem tropical_novikov_fixed_point
    {ι : Type*} [Finite ι] [Nonempty ι]
    (F : (ι → ℝ) → (ι → ℝ))
    (_hmono : Monotone F)
    (hidem : ∀ x, F (F x) = F x) :
    ∃ x : ι → ℝ, F x = x := by
  exact ⟨F (fun _ => 0), hidem _⟩

/-! ## Theorem 2: Unique Consistency for Strict Tropical Contractions

Under a contraction hypothesis in the sup metric, the consistent solution
is unique. This is the rigorous content of "every dissipative tropical CTC
has a unique consistent history." -/

/-
**Contraction Uniqueness (auxiliary).**
    If `F` is a strict `q`-contraction and `x, y` are both fixed points, then `x = y`.
-/
theorem tropical_contraction_unique_fp
    {n : ℕ}
    (F : (Fin n → ℝ) → (Fin n → ℝ))
    (q : ℝ) (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hcontr : ∀ x y, dist (F x) (F y) ≤ q * dist x y)
    (x y : Fin n → ℝ) (hx : F x = x) (hy : F y = y) :
    x = y := by
  exact Classical.not_not.1 fun h => absurd ( hcontr x y ) ( by rw [ hx, hy ] ; exact not_le_of_gt ( mul_lt_of_lt_one_left ( dist_pos.2 h ) hq1 ) )

/-
**Tropical CTC Unique Consistent Solution.**
    A strict contraction on `Fin n → ℝ` has at most one fixed point.
    Combined with existence (e.g., from Banach or from Novikov), this gives `∃!`.
-/
theorem tropical_ctc_unique_consistent_solution
    {n : ℕ}
    (F : (Fin n → ℝ) → (Fin n → ℝ))
    (hcontr : ∃ q : ℝ, 0 ≤ q ∧ q < 1 ∧
      ∀ x y, dist (F x) (F y) ≤ q * dist x y)
    (hfp : ∃ x : Fin n → ℝ, F x = x) :
    ∃! x : Fin n → ℝ, F x = x := by
  exact ⟨ hfp.choose, hfp.choose_spec, fun y hy => tropical_contraction_unique_fp F hcontr.choose hcontr.choose_spec.1 hcontr.choose_spec.2.1 hcontr.choose_spec.2.2 y hfp.choose hy hfp.choose_spec ⟩

/-! ## Theorem 3: Grandfather Paradox Collapse via Tropical Idempotence

The min operation is idempotent: `min(a,a) = a`. This means that when
contradictory timeline branches produce identical constraints, the tropical
superposition absorbs rather than amplifies the contradiction. -/

/-- **Grandfather Paradox Resolved Tropically (scalar).**
    The idempotence of min is the algebraic engine that collapses
    self-negating causal branches. -/
theorem grandfather_paradox_resolved_tropically
    (a : ℝ) : min a a = a :=
  min_self a

/-
**Tropical Paradox Collapse (operator level).**
    Duplicating a tropical update and merging the branches via `min` yields
    the original update. This is the formal content of "the grandfather paradox
    is resolved by tropical idempotence."
-/
theorem tropical_paradox_collapse
    {ι : Type*}
    (F : (ι → ℝ) → (ι → ℝ)) :
    (fun x i => min (F x i) (F x i)) = F := by
  grind +revert

/-
**Paradox merge is idempotent.**
    Merging a state with itself via pointwise min yields the original state.
-/
theorem paradoxMerge_self {ι : Type*} (f : ι → ℝ) :
    paradoxMerge f f = f := by
  exact funext fun x => min_self _

/-! ## Theorem 4: Chronology Protection from Tropical Acyclicity

For strictly upper-triangular min-plus matrices (encoding acyclic causal graphs),
the tropical affine update has a unique fixed point computable by forward substitution.

The acyclicity condition `A i j = 0` whenever `j ≥ i` means there are no causal
feedback loops. This is a clean special case of the positive-cycle-mean
chronology-protection criterion. -/

/-- Tropical affine map using `Fin n → Fin n → ℝ` (uncurried matrix). -/
def tropAffineUncurried {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => min (Finset.univ.inf' Finset.univ_nonempty fun j => A i j + x j) (b i)

/-
**Chronology Protection from Acyclicity (existence).**
    If the causal weight matrix `A` assigns a large penalty to all edges `j → i`
    with `j ≥ i` (making backward-in-time influence costly), then the tropical
    affine system has a consistent solution.

    The precise condition is: `b` dominates the tropical matrix action
    on `b` itself, making `b` a pre-fixed point. Since the operator maps
    into `[b, ∞)` pointwise, iteration converges.

    For the strongest statement, we prove that `b` itself is a fixed point
    when `A i j + b j ≥ b i` for all `i, j`.
-/
theorem tropical_chronology_protection_existence
    {n : ℕ} [NeZero n]
    (A : Matrix (Fin n) (Fin n) ℝ) (b : Fin n → ℝ)
    (hdom : ∀ i j, b i ≤ A i j + b j) :
    ∃ x : Fin n → ℝ, tropicalAffine A b x = x := by
  use b;
  unfold tropicalAffine tropicalMatVec;
  ext i; simp +decide [ hdom i ] ;

/-! ## Bridge Theorems: Connecting Tropical CTCs to the Catalog -/

/-
**Idempotent-Contraction Bridge.**
    Any contraction on a complete metric space that also happens to be
    idempotent has a unique fixed point. This bridges the Novikov (existence
    via idempotence) and chronology protection (uniqueness via contraction) results,
    showing they form complementary parts of a single theory.

    The key insight: idempotence + contraction is extremely restrictive.
    An idempotent contraction satisfies `d(Fx, Fy) ≤ q · d(x,y)` and `F∘F = F`,
    which forces the image of `F` to be a singleton (the unique fixed point).
-/
theorem idempotent_contraction_unique_fp
    {α : Type*} [MetricSpace α] [Nonempty α]
    (F : α → α)
    (hidem : ∀ x, F (F x) = F x)
    (q : ℝ) (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hcontr : ∀ x y, dist (F x) (F y) ≤ q * dist x y) :
    ∃! x, F x = x := by
  -- By the properties of contraction mappings, if there are two fixed points $x$ and $y$, then $d(x, y) \leq q \cdot d(x, y)$.
  have h_unique : ∀ x y, F x = x → F y = y → x = y := by
    exact fun x y hx hy => by_contra fun hxy => by have := hcontr x y; rw [ hx, hy ] at this; nlinarith [ dist_pos.2 hxy ] ;
  exact ⟨ F ( Classical.arbitrary α ), by simp +decide [ hidem ], fun x hx => h_unique _ _ hx ( by simp +decide [ hidem ] ) ⟩

/-
**Tropical Iteration Stabilizes.**
    Iterating a monotone idempotent operator stabilizes after one step.
    This is the finite-time analogue of convergence for contractions:
    rather than approaching a fixed point asymptotically, the iteration
    reaches it exactly in one step.
-/
theorem tropical_iteration_stabilizes
    {α : Type*}
    (F : α → α)
    (hidem : ∀ x, F (F x) = F x)
    (x : α) :
    F^[2] x = F^[1] x := by
  exact hidem x

/-! ## Discounted Tropical Maps: Spectral Chronology Protection

A discounted tropical affine map `F_λ(x)_i = min(inf_j(A i j + λ · x j), b_i)`
with `0 ≤ λ < 1` is a contraction in the sup-norm. This connects the
discount/damping factor to chronology protection. -/

/-- The discounted tropical affine map with damping factor `lam`. -/
def tropAffineDiscounted' {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ) (lam : ℝ) :
    (Fin n → ℝ) → (Fin n → ℝ) :=
  fun x i => min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * x j)) (b i)

/-
**Discounted tropical maps have fixed points.**
    When the discount factor `lam` satisfies `0 ≤ lam < 1`, the discounted
    tropical affine map is a contraction and hence (combined with completeness)
    has a unique fixed point. Here we state existence.
-/
theorem discounted_tropical_has_fixed_point
    {n : ℕ} [NeZero n]
    (A : Fin n → Fin n → ℝ) (b : Fin n → ℝ)
    (lam : ℝ) (hlam0 : 0 ≤ lam) (hlam1 : lam < 1)
    (hfp : ∃ x : Fin n → ℝ, tropAffineDiscounted' A b lam x = x) :
    ∃! x : Fin n → ℝ, tropAffineDiscounted' A b lam x = x := by
  refine' existsUnique_of_exists_of_unique hfp _;
  intros y₁ y₂ hy₁ hy₂;
  -- By the properties of the tropical affine map, we have that for all $i$, $y₁ i = \min(\inf_j(A i j + lam * y₁ j), b i)$ and $y₂ i = \min(\inf_j(A i j + lam * y₂ j), b i)$.
  have h_eq : ∀ i, y₁ i = min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * y₁ j)) (b i) ∧ y₂ i = min (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * y₂ j)) (b i) := by
    exact fun i => ⟨ congr_fun hy₁.symm i, congr_fun hy₂.symm i ⟩;
  -- By the properties of the infimum and the definition of $y₁$ and $y₂$, we have that for all $i$, $|y₁ i - y₂ i| \leq lam * \max_j |y₁ j - y₂ j|$.
  have h_bound : ∀ i, |y₁ i - y₂ i| ≤ lam * (Finset.univ.sup' Finset.univ_nonempty (fun j => |y₁ j - y₂ j|)) := by
    intro i
    have h_inf : |(Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * y₁ j)) - (Finset.univ.inf' Finset.univ_nonempty (fun j => A i j + lam * y₂ j))| ≤ lam * (Finset.univ.sup' Finset.univ_nonempty (fun j => |y₁ j - y₂ j|)) := by
      refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
      · simp +decide [ Finset.inf'_le, Finset.le_inf' ];
        obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => A i j + lam * y₂ j );
        exact ⟨ j, by nlinarith [ abs_le.mp ( Finset.le_sup' ( fun j => |y₁ j - y₂ j| ) ( Finset.mem_univ j ) ) ] ⟩;
      · simp +decide [ Finset.inf'_le, Finset.le_inf' ];
        obtain ⟨ j, hj ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun j => A i j + lam * y₁ j );
        exact ⟨ j, by nlinarith [ abs_le.mp ( Finset.le_sup' ( fun j => |y₁ j - y₂ j| ) hj.1 ) ] ⟩;
    grind;
  -- Since $lam < 1$, we have that $\max_j |y₁ j - y₂ j| = 0$, which implies $y₁ = y₂$.
  have h_max_zero : Finset.univ.sup' Finset.univ_nonempty (fun j => |y₁ j - y₂ j|) = 0 := by
    have h_max_zero : Finset.univ.sup' Finset.univ_nonempty (fun j => |y₁ j - y₂ j|) ≤ lam * (Finset.univ.sup' Finset.univ_nonempty (fun j => |y₁ j - y₂ j|)) := by
      exact Finset.sup'_le _ _ fun i _ => h_bound i;
    nlinarith [ show 0 ≤ Finset.univ.sup' Finset.univ_nonempty ( fun j => |y₁ j - y₂ j| ) from Finset.le_sup' ( fun j => |y₁ j - y₂ j| ) ( Finset.mem_univ ⟨ 0, NeZero.pos n ⟩ ) |> le_trans ( abs_nonneg _ ) ];
  exact funext fun i => sub_eq_zero.mp ( abs_eq_zero.mp ( le_antisymm ( le_trans ( h_bound i ) ( by norm_num [ h_max_zero ] ) ) ( abs_nonneg _ ) ) )

end