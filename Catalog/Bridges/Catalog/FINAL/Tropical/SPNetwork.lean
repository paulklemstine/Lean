import Mathlib

/-!
# Tropical Series-Parallel Network Theory

This file establishes the foundations of tropical (min-plus) series-parallel network theory,
formalizing the compositional semantics of two-terminal series-parallel networks and proving
key structural theorems including:

* **Compositional tropical semantics**: effective distance decomposes as addition under
  series composition and minimum under parallel composition.
* **Tropical distributivity**: series distributes over parallel at the effective distance level,
  giving SP networks the structure of a tropical semiring action.
* **Path weight characterization**: the effective distance equals the minimum element of the
  multiset of all source-to-sink path weights — the fundamental bridge between combinatorial
  structure and tropical observables.
* **Tropical elimination theorem**: for concrete networks, eliminating internal vertices via
  the tropical Schur complement correctly computes boundary distances.

## Mathematical context

In the tropical (min-plus) semiring (ℕ, min, +), series-parallel networks provide a natural
compositional framework: series composition corresponds to tropical multiplication (addition
of distances), while parallel composition corresponds to tropical addition (minimum of
distances). The effective distance of an SP network is the shortest-path distance between
its two terminals.

## References

* Eppstein, D. "Parallel recognition of series-parallel graphs" (1992)
* Butkovič, P. "Max-linear Systems: Theory and Algorithms" (2010)
* Maclagan, D. and Sturmfels, B. "Introduction to Tropical Geometry" (2015)
-/

open Multiset

/-! ## Core Definitions -/

/-- A two-terminal series-parallel expression with natural number weights.
    This is the syntax tree representation of an SP network:
    - `atom w` represents a single edge of weight `w` connecting the two terminals
    - `series e₁ e₂` represents the series composition (concatenation) of two SP networks
    - `parallel e₁ e₂` represents the parallel composition of two SP networks -/
inductive SPExpr : Type where
  | atom : ℕ → SPExpr
  | series : SPExpr → SPExpr → SPExpr
  | parallel : SPExpr → SPExpr → SPExpr
  deriving Repr, DecidableEq

namespace SPExpr

/-! ## Effective Distance -/

/-- The effective distance of an SP network: the shortest-path distance
    between the two terminals.
    - For an atom, this is the edge weight.
    - For series composition, distances add (paths concatenate).
    - For parallel composition, we take the minimum (choose the shorter path). -/
def effDist : SPExpr → ℕ
  | atom w => w
  | series e₁ e₂ => e₁.effDist + e₂.effDist
  | parallel e₁ e₂ => min e₁.effDist e₂.effDist

/-! ## Compositional Semantics Theorems -/

/-- Series composition adds effective distances: the tropical multiplication law. -/
theorem effDist_series (e₁ e₂ : SPExpr) :
    (series e₁ e₂).effDist = e₁.effDist + e₂.effDist := rfl

/-- Parallel composition takes the minimum: the tropical addition law. -/
theorem effDist_parallel (e₁ e₂ : SPExpr) :
    (parallel e₁ e₂).effDist = min e₁.effDist e₂.effDist := rfl

/-- Atom effective distance is the weight itself. -/
theorem effDist_atom (w : ℕ) : (atom w).effDist = w := rfl

/-! ## Tropical Algebraic Properties -/

/-- Series composition is associative at the effective distance level. -/
theorem effDist_series_assoc (e₁ e₂ e₃ : SPExpr) :
    (series (series e₁ e₂) e₃).effDist = (series e₁ (series e₂ e₃)).effDist := by
  simp [effDist_series, Nat.add_assoc]

/-- Parallel composition is commutative at the effective distance level. -/
theorem effDist_parallel_comm (e₁ e₂ : SPExpr) :
    (parallel e₁ e₂).effDist = (parallel e₂ e₁).effDist := by
  simp [effDist_parallel, min_comm]

/-- Parallel composition is associative at the effective distance level. -/
theorem effDist_parallel_assoc (e₁ e₂ e₃ : SPExpr) :
    (parallel (parallel e₁ e₂) e₃).effDist = (parallel e₁ (parallel e₂ e₃)).effDist := by
  simp [effDist_parallel, min_assoc]

/-- **Tropical distributivity**: series distributes over parallel from the left.
    This is the fundamental algebraic identity `a + min(b, c) = min(a + b, a + c)`
    lifted to SP network semantics. -/
theorem effDist_series_parallel_left (e₁ e₂ e₃ : SPExpr) :
    (series e₁ (parallel e₂ e₃)).effDist =
      min (series e₁ e₂).effDist (series e₁ e₃).effDist := by
  simp [effDist_series, effDist_parallel, Nat.add_min_add_left]

/-- Right tropical distributivity: `min(a, b) + c = min(a + c, b + c)`. -/
theorem effDist_series_parallel_right (e₁ e₂ e₃ : SPExpr) :
    (series (parallel e₁ e₂) e₃).effDist =
      min (series e₁ e₃).effDist (series e₂ e₃).effDist := by
  simp [effDist_series, effDist_parallel, Nat.add_min_add_right]

/-- Parallel with itself is idempotent. -/
theorem effDist_parallel_self (e : SPExpr) :
    (parallel e e).effDist = e.effDist := by
  simp [effDist_parallel]

/-- Series with atom 0 is a left identity for effective distance. -/
theorem effDist_series_atom_zero_left (e : SPExpr) :
    (series (atom 0) e).effDist = e.effDist := by
  simp [effDist_series, effDist_atom]

/-- Series with atom 0 is a right identity for effective distance. -/
theorem effDist_series_atom_zero_right (e : SPExpr) :
    (series e (atom 0)).effDist = e.effDist := by
  simp [effDist_series, effDist_atom]

/-! ## Path Weight Multiset -/

/-- The multiset of all source-to-sink path weights.
    Each element of this multiset is the total weight of one path through the network.
    - An atom has exactly one path (the single edge).
    - Series composition produces the Minkowski sum: each path through the composition
      consists of a path through e₁ followed by a path through e₂.
    - Parallel composition produces the union: paths through either branch. -/
def pathWeights : SPExpr → Multiset ℕ
  | atom w => {w}
  | series e₁ e₂ => (e₁.pathWeights).bind (fun a => e₂.pathWeights.map (fun b => a + b))
  | parallel e₁ e₂ => e₁.pathWeights + e₂.pathWeights

/-- Number of source-to-sink paths. -/
def numPaths : SPExpr → ℕ
  | atom _ => 1
  | series e₁ e₂ => e₁.numPaths * e₂.numPaths
  | parallel e₁ e₂ => e₁.numPaths + e₂.numPaths

/-- An atom has exactly one path. -/
theorem numPaths_atom (w : ℕ) : (atom w).numPaths = 1 := rfl

/-- Every SP expression has at least one path. -/
theorem numPaths_pos (e : SPExpr) : 0 < e.numPaths := by
  induction e with
  | atom _ => exact Nat.one_pos
  | series _ _ ih₁ ih₂ => exact Nat.mul_pos ih₁ ih₂
  | parallel _ _ ih₁ _ => exact Nat.add_pos_left ih₁ _

/-- Path weights of an atom is a singleton. -/
theorem pathWeights_atom (w : ℕ) : (atom w).pathWeights = {w} := rfl

/-- Path weights of parallel composition is multiset sum (union). -/
theorem pathWeights_parallel (e₁ e₂ : SPExpr) :
    (parallel e₁ e₂).pathWeights = e₁.pathWeights + e₂.pathWeights := rfl

/-- Every SP expression has at least one path (the path multiset is nonempty). -/
theorem pathWeights_nonempty (e : SPExpr) : e.pathWeights ≠ 0 := by
  induction e with
  | atom w => simp [pathWeights]
  | series e₁ e₂ ih₁ ih₂ =>
    obtain ⟨a, ha⟩ := Multiset.exists_mem_of_ne_zero ih₁
    obtain ⟨b, hb⟩ := Multiset.exists_mem_of_ne_zero ih₂
    intro heq
    have hmem : a + b ∈ e₁.pathWeights.bind (fun a => e₂.pathWeights.map (fun b => a + b)) :=
      Multiset.mem_bind.mpr ⟨a, ha, Multiset.mem_map.mpr ⟨b, hb, rfl⟩⟩
    rw [show e₁.pathWeights.bind _ = (series e₁ e₂).pathWeights from rfl, heq] at hmem
    simp at hmem
  | parallel e₁ e₂ ih₁ _ =>
    obtain ⟨a, ha⟩ := Multiset.exists_mem_of_ne_zero ih₁
    intro heq
    have hmem : a ∈ e₁.pathWeights + e₂.pathWeights :=
      Multiset.mem_add.mpr (Or.inl ha)
    rw [show e₁.pathWeights + e₂.pathWeights = (parallel e₁ e₂).pathWeights from rfl, heq] at hmem
    simp at hmem

/-
The number of paths equals the cardinality of the path weight multiset.
-/
theorem numPaths_eq_card_pathWeights (e : SPExpr) :
    e.numPaths = Multiset.card e.pathWeights := by
  -- We will prove this by induction on `e`.
  induction' e with e1 e2 ih1 ih2;
  · exact Eq.symm (Nat.eq_of_beq_eq_true rfl);
  · erw [ show ( e2.series ih1 ).pathWeights = e2.pathWeights.bind fun a => ih1.pathWeights.map fun b => a + b from rfl, Multiset.card_bind ] ; simp +decide [ * ];
    exact ih2.symm ▸ ‹ih1.numPaths = ih1.pathWeights.card›.symm ▸ rfl;
  · -- For the parallel case, the number of paths is the sum of the number of paths in each component.
    simp [SPExpr.numPaths, SPExpr.pathWeights, *]

/-! ## Effective Distance = Minimum Path Weight

The fundamental path-distance theorem, stated in two parts:
1. The effective distance is achieved by some path (it's in the multiset).
2. The effective distance is ≤ every path weight (it's the minimum).
-/

/-
**Part 1**: The effective distance is achieved by some path in the network.
-/
theorem effDist_mem_pathWeights (e : SPExpr) :
    e.effDist ∈ e.pathWeights := by
  have h_ind : ∀ e : SPExpr, e.effDist ∈ e.pathWeights := by
    intro e;
    induction' e using SPExpr.recOn with e₁ e₂ ih₁ ih₂;
    · exact Multiset.mem_singleton_self _;
    · simp_all +decide [ SPExpr.effDist, SPExpr.pathWeights ];
      exact ⟨ _, ih₂, _, ‹_›, rfl ⟩;
    · grind +locals;
  exact h_ind e

/-
**Part 2**: The effective distance is at most every path weight.
-/
theorem effDist_le_of_mem_pathWeights (e : SPExpr) (w : ℕ) (hw : w ∈ e.pathWeights) :
    e.effDist ≤ w := by
  induction' e with e₁ e₂ ih₁ ih₂ generalizing w;
  · cases hw ; aesop;
    contradiction;
  · erw [ Multiset.mem_bind ] at hw;
    unfold SPExpr.effDist; obtain ⟨ a, ha, hw ⟩ := hw; rw [ Multiset.mem_map ] at hw; obtain ⟨ b, hb, rfl ⟩ := hw; exact add_le_add ( ih₂ a ha ) ( by solve_by_elim ) ;
  · grind +locals

/-- **The Fundamental Path–Distance Theorem (combined)**:
    The effective distance is the minimum element of the path weight multiset.
    That is, it is both achieved by some path and is ≤ all path weights. -/
theorem effDist_is_min_pathWeights (e : SPExpr) :
    e.effDist ∈ e.pathWeights ∧ ∀ w ∈ e.pathWeights, e.effDist ≤ w :=
  ⟨effDist_mem_pathWeights e, fun w hw => effDist_le_of_mem_pathWeights e w hw⟩

/-! ## Monotonicity Properties -/

/-- Series with a positive-weight edge strictly increases effective distance. -/
theorem effDist_series_pos (e : SPExpr) (w : ℕ) (hw : 0 < w) :
    e.effDist < (series e (atom w)).effDist := by
  simp [effDist_series, effDist_atom]; omega

/-- Parallel composition never increases effective distance beyond either component. -/
theorem effDist_parallel_le_left (e₁ e₂ : SPExpr) :
    (parallel e₁ e₂).effDist ≤ e₁.effDist := min_le_left _ _

theorem effDist_parallel_le_right (e₁ e₂ : SPExpr) :
    (parallel e₁ e₂).effDist ≤ e₂.effDist := min_le_right _ _

/-! ## Positive Weight Properties -/

/-- An SP expression has positive weights if all atom weights are positive. -/
def PositiveWeights : SPExpr → Prop
  | atom w => 0 < w
  | series e₁ e₂ => e₁.PositiveWeights ∧ e₂.PositiveWeights
  | parallel e₁ e₂ => e₁.PositiveWeights ∧ e₂.PositiveWeights

/-
SP expressions with positive weights have positive effective distance.
-/
theorem effDist_pos_of_positiveWeights (e : SPExpr) (h : e.PositiveWeights) :
    0 < e.effDist := by
  induction' e using SPExpr.recOn with e₁ e₂ ih₁ ih₂;
  · exact Nat.zero_lt_of_lt h;
  · cases h ; linarith! [ ‹e₂.PositiveWeights → 0 < e₂.effDist› ‹_›, ‹ih₁.PositiveWeights → 0 < ih₁.effDist› ‹_›, SPExpr.effDist_series e₂ ih₁ ];
  · cases h ; simp_all +decide [ SPExpr.effDist_parallel ]

/-! ## Tropical Elimination (Schur Complement) -/

/-- The boundary distance from source to sink in a 3-vertex graph {s, v, t}
    with edge weights w_sv, w_vt, and w_st, after eliminating the internal vertex v.
    This is the tropical Schur complement for the simplest non-trivial case. -/
def tropicalElim3 (w_sv w_vt w_st : WithTop ℕ) : WithTop ℕ :=
  min w_st (w_sv + w_vt)

/-- **Tropical elimination theorem for 3-vertex path graph**:
    When there is no direct edge from s to t, eliminating the internal vertex v
    correctly computes the boundary distance as the sum of edge weights along
    the unique path s → v → t. -/
theorem tropicalElim3_no_direct (w_sv w_vt : WithTop ℕ) :
    tropicalElim3 w_sv w_vt ⊤ = w_sv + w_vt := by
  simp [tropicalElim3]

/-
When there IS a direct edge, the elimination takes the minimum of the
    direct path and the two-hop path through the internal vertex.
    This is the fundamental step of Floyd-Warshall / tropical Gaussian elimination.
-/
theorem tropicalElim3_with_direct (a b c : ℕ) :
    tropicalElim3 (↑a) (↑b) (↑c) = ↑(min c (a + b)) := by
  norm_cast

/-
The tropical Schur complement of two series edges equals their sum:
    eliminating the middle vertex of s —w₁→ v —w₂→ t gives effective weight w₁ + w₂.
-/
theorem tropicalElim3_series (w₁ w₂ : ℕ) :
    tropicalElim3 (↑w₁) (↑w₂) ⊤ = ↑(w₁ + w₂) := by
  grind +locals

/-
The tropical Schur complement correctly identifies the minimum-weight path
    when both a direct and an indirect route exist.
-/
theorem tropicalElim3_parallel_series (w_direct w₁ w₂ : ℕ) :
    tropicalElim3 (↑w₁) (↑w₂) (↑w_direct) = ↑(min w_direct (w₁ + w₂)) := by
  convert tropicalElim3_with_direct w₁ w₂ w_direct

/-! ## Structural Properties -/

/-- The size of an SP expression (number of constructors). -/
def size : SPExpr → ℕ
  | atom _ => 1
  | series e₁ e₂ => 1 + e₁.size + e₂.size
  | parallel e₁ e₂ => 1 + e₁.size + e₂.size

/-- The depth of an SP expression (length of longest root-to-leaf path). -/
def depth : SPExpr → ℕ
  | atom _ => 0
  | series e₁ e₂ => 1 + max e₁.depth e₂.depth
  | parallel e₁ e₂ => 1 + max e₁.depth e₂.depth

/-- The effective distance is bounded by the total weight of all atoms
    (which is the weight of the "worst" path in a certain sense). -/
def totalWeight : SPExpr → ℕ
  | atom w => w
  | series e₁ e₂ => e₁.totalWeight + e₂.totalWeight
  | parallel e₁ e₂ => e₁.totalWeight + e₂.totalWeight

theorem effDist_le_totalWeight (e : SPExpr) : e.effDist ≤ e.totalWeight := by
  induction' e using SPExpr.recOn with e₁ e₂ ih₁ ih₂;
  · exact le_rfl;
  · exact Nat.add_le_add ih₂ ‹_›;
  · exact le_trans ( min_le_left _ _ ) ( le_trans ‹_› ( Nat.le_add_right _ _ ) )

/-! ## Tropical Semiring Structure Summary

The effective distance mapping establishes that two-terminal SP networks form
a model of the tropical semiring (ℕ, min, +):

- `effDist_parallel_comm`: min is commutative
- `effDist_parallel_assoc`: min is associative
- `effDist_parallel_self`: min is idempotent
- `effDist_series_assoc`: + is associative
- `effDist_series_atom_zero_left`: 0 is an identity for +
- `effDist_series_parallel_left`: + distributes over min from the left
- `effDist_series_parallel_right`: + distributes over min from the right

This makes the `effDist` function a tropical semiring homomorphism from SP expressions
to (ℕ, min, +), which is the foundation for tropical inverse theory.
-/

end SPExpr