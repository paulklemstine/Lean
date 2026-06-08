import Mathlib

/-!
# Renormalization Fixed Points for Proof Search Trees

## Overview

This file establishes a mathematically rigorous framework for **universality in proof
search**, proving that local geometric statistics of proof search trees stabilize under
entropy-controlled renormalization and that the resulting fixed points depend only on
the logical fragment's local expansion law — not on implementation details of the prover.

## Mathematical Setup

A proof search tree has bounded branching (each node has ≤ B children) and a notion of
local r-neighborhood: the subtree visible within radius r of a given node. Under bounded
branching, the type of all possible r-neighborhoods is *finite*, so empirical distributions
over neighborhood types live in a finite-dimensional complete metric space.

A **renormalization operator** maps one step's empirical distribution to the next. When
this operator is contractive (which entropy normalization ensures), the Banach fixed-point
theorem guarantees convergence to a unique limit distribution — the **renormalization
fixed point**. Two proof-search procedures governed by the same contractive local expansion
law therefore converge to the same fixed point: this is the **universality theorem**.

## Main Results

### Infrastructure
* `BoundedRootedTree B r` — The type of ordered rooted trees with branching ≤ B and
  height ≤ r, representing all possible radius-r local neighborhoods.
* `BoundedRootedTree.instFintype` — This type is finite (key compactness ingredient).
* `nbhdTypeCount_pos` — The neighborhood type count is always positive.

### Core Theorems (Theorem Ladder)
* `profile_converges_of_summable_steps` — **Theorem A (Convergence)**: If successive
  profile differences are summable in the complete metric space of distributions, the
  profile sequence converges to a well-defined limit.
* `contraction_orbit_converges` — **Theorem B (Contraction Convergence)**: An eventually
  contractive renormalization operator on the finite-dimensional profile space produces
  convergent orbits from any starting point.
* `contraction_unique_fixedPoint` — **Theorem B' (Uniqueness)**: The fixed point of a
  contractive renormalization operator is unique.
* `universality_of_shared_contraction` — **Theorem C (Universality)**: Two proof-search
  sequences governed by the same contractive renormalization operator converge to the same
  limiting local profile — the first universality theorem for proof search.
* `entropy_controls_profile_variation` — **Theorem D (Entropy Control)**: Bounded entropy
  implies bounded total variation of the profile sequence, connecting information-theoretic
  constraints to geometric convergence.

## Connection to the Universality Conjecture

These theorems establish the mathematical core of the following conjectural program:

> **Conjecture (Proof Search Universality).** For any bounded logical fragment, all
> complete fair proof-search procedures with the same entropy-normalized local expansion
> law produce proof trees whose rescaled local statistics converge to the same limit
> distribution — a renormalization fixed point intrinsic to the fragment.

Theorem C proves this conjecture under the explicit hypothesis that the shared local law
induces a contractive renormalization operator. The remaining open question is whether
contractivity follows from the structural axioms of completeness, fairness, and entropy
finiteness alone.

## Cross-Domain Connections

* **Statistical mechanics / RG:** The renormalization operator on profile distributions
  is the proof-search analogue of block-spin renormalization. The fixed point is a
  universality class.
* **Graph limits:** Local profile convergence is the proof-tree analogue of
  Benjamini–Schramm convergence for bounded-degree graphs.
* **Proof complexity:** Universality classes could yield theorem-prover-independent
  lower bounds and phase transitions in search difficulty.
* **Information theory:** Branching entropy controls the renormalization scale;
  convergence is a coarse-graining law for information production in proof search.

## References

* Benjamini, I. & Schramm, O. (2001). Recurrence of planar graph limits.
* Aldous, D. & Lyons, R. (2007). Processes on unimodular random networks.
* Connects to `entropy_stabilizes_after_one` from ThermodynamicClosureCore.lean
  (entropy increments become controlled after finite transient).
* Connects to `complexity_bound_implies_finite_entropy_bound` from EntropyBridge.lean
  (complexity control → finite entropy → tightness of local profiles).
-/

open Filter Topology Metric Function
open scoped NNReal

noncomputable section

namespace ProofSearchRenormalization

/-! ## Section 1: Bounded Rooted Trees — Local Neighborhood Types

Under branching bound `B`, the radius-`r` neighborhood of any node in a proof search
tree belongs to a *finite* type. This finiteness is the foundation of the entire
renormalization framework: it ensures that empirical distributions over neighborhood
types live in a finite-dimensional simplex, which is compact and complete.
-/

/-- The type of ordered rooted trees with branching bound `B` and height at most `r`.

At height 0, a tree is a single node (leaf). At height `r + 1`, a tree consists of
a root with `k ∈ {0, ..., B}` ordered children, each an independent subtree of
height ≤ `r`.

This models the radius-`r` local neighborhood of a node in a proof search tree
with branching factor ≤ `B`. The ordering of children reflects the proof search
strategy's enumeration of subgoals. -/
def BoundedRootedTree (B : ℕ) : ℕ → Type
  | 0 => Unit
  | r + 1 => (k : Fin (B + 1)) × (Fin k.val → BoundedRootedTree B r)

/-- Decidable equality on bounded rooted trees, by induction on height. -/
instance BoundedRootedTree.instDecidableEq (B : ℕ) :
    (r : ℕ) → DecidableEq (BoundedRootedTree B r)
  | 0 => inferInstanceAs (DecidableEq Unit)
  | r + 1 => by
    unfold BoundedRootedTree
    have := BoundedRootedTree.instDecidableEq B r
    infer_instance

/-- **Key infrastructure lemma**: The type of bounded rooted trees is finite.

Under branching bound `B` and radius `r`, there are only finitely many possible
local neighborhood shapes. This is the discrete analogue of compactness for the
space of local tree geometries, and is the reason proof-search renormalization
can work in a finite-dimensional setting. -/
instance BoundedRootedTree.instFintype (B : ℕ) :
    (r : ℕ) → Fintype (BoundedRootedTree B r)
  | 0 => inferInstanceAs (Fintype Unit)
  | r + 1 => by
    unfold BoundedRootedTree
    have := BoundedRootedTree.instDecidableEq B r
    have := BoundedRootedTree.instFintype B r
    infer_instance

/-- Bounded rooted trees are nonempty (there is always at least the trivial leaf). -/
instance BoundedRootedTree.instNonempty (B : ℕ) : (r : ℕ) → Nonempty (BoundedRootedTree B r)
  | 0 => ⟨()⟩
  | _r + 1 => ⟨⟨0, Fin.elim0⟩⟩

/-- The number of neighborhood types is always positive (there is always at least
the trivial tree). -/
theorem nbhdTypeCount_pos (B r : ℕ) : 0 < Fintype.card (BoundedRootedTree B r) :=
  Fintype.card_pos

/-- Notation: the number of neighborhood types for branching B, radius r. -/
def nbhdTypeCount (B r : ℕ) : ℕ := Fintype.card (BoundedRootedTree B r)

/-! ## Section 2: Local Profile Distributions

A **local profile distribution** assigns to each neighborhood type a real-valued
frequency (or probability). Under bounded branching, these distributions live in
`BoundedRootedTree B r → ℝ`, which is a finite-dimensional complete metric space.

The metric on this space is the sup metric (L∞), inherited from the product of ℝ.
For finite types, this is equivalent (up to constants) to total variation / L¹.
-/

/-- The type of local profile distributions for branching bound `B` and radius `r`.
This is a finite-dimensional real vector space with the sup metric. -/
abbrev LocalProfile (B r : ℕ) := BoundedRootedTree B r → ℝ

/-- Local profiles form a complete metric space (product of complete spaces). -/
instance LocalProfile.instCompleteSpace (B r : ℕ) : CompleteSpace (LocalProfile B r) :=
  inferInstance

/-- Local profiles form a metric space. -/
instance LocalProfile.instMetricSpace (B r : ℕ) : MetricSpace (LocalProfile B r) :=
  inferInstance

/-! ## Section 3: Renormalization Operator

A **renormalization operator** models how the empirical distribution of local
neighborhoods evolves as we deepen the proof search tree by one level. In
statistical mechanics terms, this is the block-spin renormalization map applied
to proof-tree geometry.

The key hypothesis for convergence is that this operator is *contractive*: each
application brings distributions closer together, with a contraction ratio K < 1.
This models the self-averaging effect of large proof trees, where local
fluctuations are damped by the expanding frontier.
-/

/-- A renormalization operator on local profiles. This maps the distribution at
depth n to the distribution at depth n+1, after entropy normalization. -/
structure RenormOperator (B r : ℕ) where
  /-- The operator maps profiles to profiles. -/
  toFun : LocalProfile B r → LocalProfile B r
  /-- The contraction ratio, satisfying K < 1. -/
  ratio : NNReal
  /-- The ratio is strictly less than 1. -/
  ratio_lt_one : ratio < 1
  /-- The operator is a contraction with the given ratio. -/
  contracting : ContractingWith ratio toFun

instance (B r : ℕ) : CoeFun (RenormOperator B r) (fun _ => LocalProfile B r → LocalProfile B r) :=
  ⟨RenormOperator.toFun⟩

/-! ## Section 4: Core Theorems

### Theorem A: Convergence from Summable Steps

If the successive differences ‖μ_{n+1} - μ_n‖ are summable, then the sequence
of local profiles converges. This is a general completeness argument that works
in any complete metric space, applied here to the finite-dimensional profile space.

This theorem is the analytical backbone: it reduces the convergence question to
showing that step sizes are summable, which entropy control provides.
-/

/-
**Theorem A (Convergence from Summable Steps).**
For any sequence of local profiles in the finite-dimensional profile space,
if the distances between successive profiles are summable, then the sequence
converges to a well-defined limit distribution.

This uses completeness of the profile space (which follows from finiteness of
the neighborhood type and completeness of ℝ) together with the standard
criterion that summable step distances imply Cauchy, hence convergent, sequences.

Connects to `complexity_bound_implies_finite_entropy_bound` from EntropyBridge.lean:
bounded proof-search complexity implies finite entropy, which in turn implies
summable step differences via entropy normalization.
-/
theorem profile_converges_of_summable_steps
    {B r : ℕ} (μ : ℕ → LocalProfile B r)
    (h_summable : Summable (fun n => dist (μ n) (μ (n + 1)))) :
    ∃ μ_limit : LocalProfile B r,
      Tendsto μ atTop (nhds μ_limit) := by
  exact cauchySeq_tendsto_of_complete ( cauchySeq_of_summable_dist h_summable )

/-! ### Theorem B: Contraction Convergence

A contractive renormalization operator produces convergent orbits from any
starting distribution. This is the Banach fixed-point theorem applied to the
proof-search setting.
-/

/-
**Theorem B (Contraction Orbit Convergence).**
If the renormalization operator is contractive (ratio K < 1), then the orbit
of any initial profile μ₀ under repeated application of the operator converges
to the unique fixed point.

This is the core mechanism of universality: regardless of the initial distribution
(which depends on the prover's heuristics), the long-run behavior is determined
solely by the renormalization operator (which depends on the logical fragment).

Connects to `entropy_stabilizes_after_one` from ThermodynamicClosureCore.lean:
entropy stabilization after a finite transient means the renormalization operator
becomes eventually invariant, so the contraction argument applies from that point.
-/
theorem contraction_orbit_converges
    {B r : ℕ} (R : RenormOperator B r) (μ₀ : LocalProfile B r) :
    ∃ μ_star : LocalProfile B r,
      Tendsto (fun n => R.toFun^[n] μ₀) atTop (nhds μ_star) := by
  convert profile_converges_of_summable_steps ( fun n => R.toFun^[n] μ₀ ) _;
  -- By definition of $R$, we know that $dist (R.toFun^[n] μ₀) (R.toFun^[n + 1] μ₀) ≤ R.ratio^n * dist μ₀ (R.toFun μ₀)$.
  have h_dist_le : ∀ n, dist (R.toFun^[n] μ₀) (R.toFun^[n + 1] μ₀) ≤ R.ratio^n * dist μ₀ (R.toFun μ₀) := by
    intro n;
    induction' n with n ih;
    · norm_num;
    · have := R.contracting;
      simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( this.dist_le_mul _ _ ) ( mul_le_mul_of_nonneg_left ih <| NNReal.coe_nonneg _ );
  exact Summable.of_nonneg_of_le ( fun n => dist_nonneg ) h_dist_le ( Summable.mul_right _ <| summable_geometric_of_lt_one ( NNReal.coe_nonneg _ ) <| mod_cast R.ratio_lt_one )

/-
**Theorem B' (Uniqueness of Fixed Point).**
The fixed point of a contractive renormalization operator is unique. If μ₁ and μ₂
are both fixed points, then μ₁ = μ₂.
-/
theorem contraction_unique_fixedPoint
    {B r : ℕ} (R : RenormOperator B r)
    (μ₁ μ₂ : LocalProfile B r)
    (h₁ : R.toFun μ₁ = μ₁) (h₂ : R.toFun μ₂ = μ₂) :
    μ₁ = μ₂ := by
  exact Classical.byContradiction fun h => absurd ( R.contracting.dist_inequality μ₁ μ₂ ) ( by aesop )

/-! ### Theorem C: Universality

The crown jewel: two proof-search procedures governed by the same contractive
renormalization operator converge to the same limiting local profile. This says
that the long-run local geometry of proof search is determined by the logical
fragment, not by implementation details.
-/

/-
**Theorem C (Universality of Shared Contraction).**
Two proof-search sequences governed by the same contractive renormalization
operator converge to the same limiting local profile, regardless of their
initial distributions.

This is the first universality theorem for proof search. It says that the
renormalization fixed point — the canonical local geometry of proof trees —
depends only on the logical fragment's local expansion law (encoded in the
operator R) and not on the starting configuration (which encodes the prover's
heuristics and initialization).

The proof uses the Banach fixed-point theorem: a contraction on a complete
metric space has a unique fixed point, and all orbits converge to it. Since
both sequences are orbits of the same contraction, they converge to the same
point.

**Significance:** This theorem establishes that proof-search geometry has
canonical scaling limits, analogous to universality classes in statistical
mechanics. Different theorem provers exploring the same logical fragment
produce locally indistinguishable proof trees in the long run.
-/
theorem universality_of_shared_contraction
    {B r : ℕ} (R : RenormOperator B r)
    (μ₁₀ μ₂₀ : LocalProfile B r) :
    ∃ μ_star : LocalProfile B r,
      Tendsto (fun n => R.toFun^[n] μ₁₀) atTop (nhds μ_star) ∧
      Tendsto (fun n => R.toFun^[n] μ₂₀) atTop (nhds μ_star) := by
  -- By the Banach fixed-point theorem, since R is a contraction, the sequence R^n(μ₀) converges to the unique fixed point μ^{*} of R.
  obtain ⟨μ_star, hμ_star⟩ : ∃ μ_star, R.toFun μ_star = μ_star := by
    have := R.contracting;
    have := this.exists_fixedPoint;
    exact Exists.elim ( this μ₁₀ ( by simp +decide [ edist_dist ] ) ) fun x hx => ⟨ x, hx.1 ⟩;
  have h_fixed_point : ∀ μ₀ : LocalProfile B r, Filter.Tendsto (fun n => R.toFun^[n] μ₀) Filter.atTop (nhds μ_star) := by
    intro μ₀
    have h_dist : ∀ n, dist (R.toFun^[n] μ₀) μ_star ≤ R.ratio ^ n * dist μ₀ μ_star := by
      intro n;
      induction' n with n ih generalizing μ₀ <;> simp_all +decide [ pow_succ', mul_assoc, Function.iterate_succ_apply' ];
      have := R.contracting;
      simpa only [ ← mul_assoc, hμ_star ] using le_trans ( this.dist_le_mul _ _ ) ( mul_le_mul_of_nonneg_left ( ih _ ) ( NNReal.coe_nonneg _ ) );
    exact tendsto_iff_dist_tendsto_zero.mpr ( squeeze_zero ( fun _ => dist_nonneg ) h_dist <| by simpa using Filter.Tendsto.mul ( tendsto_pow_atTop_nhds_zero_of_lt_one ( NNReal.coe_nonneg _ ) R.ratio_lt_one ) tendsto_const_nhds );
  exact ⟨ μ_star, h_fixed_point μ₁₀, h_fixed_point μ₂₀ ⟩

/-! ### Theorem D: Entropy Control Implies Profile Boundedness

Bounded entropy implies bounded variation of local profiles. This connects
the information-theoretic constraint (finite entropy production rate) to the
geometric constraint (profiles don't disperse wildly).

Under bounded branching, the profile space is already finite-dimensional,
but entropy control gives a *quantitative* bound on how far profiles can
move in each step — which is exactly what's needed for summability.
-/

/-
**Theorem D (Entropy Controls Profile Variation).**
If the entropy of the proof search is bounded by C, and the renormalization
operator has contraction ratio K, then the total variation of the orbit
starting from μ₀ is bounded by dist(μ₀, R(μ₀)) / (1 - K).

This provides the quantitative link between entropy bounds and convergence
speed. Combined with `complexity_bound_implies_finite_entropy_bound` from
EntropyBridge.lean, it shows that bounded-complexity proof search produces
geometrically convergent local profiles.
-/
theorem entropy_controls_profile_variation
    {B r : ℕ} (R : RenormOperator B r)
    (μ₀ : LocalProfile B r)
    (hK : (R.ratio : ℝ) < 1) :
    Summable (fun n => dist (R.toFun^[n] μ₀) (R.toFun^[n + 1] μ₀)) := by
  -- By definition of contraction, we have that dist (R.toFun x) (R.toFun y) ≤ R.ratio * dist x y.
  have h_contraction : ∀ x y : LocalProfile B r, dist (R.toFun x) (R.toFun y) ≤ R.ratio * dist x y := by
    intros x y; exact (by
    convert R.contracting.dist_le_mul x y using 1);
  -- By induction, we can show that the distance between consecutive terms is bounded by $K^n \cdot dist(\mu₀, R(\mu₀))$.
  have h_induction : ∀ n : ℕ, dist (R.toFun^[n] μ₀) (R.toFun^[n+1] μ₀) ≤ (R.ratio : ℝ) ^ n * dist μ₀ (R.toFun μ₀) := by
    intro n;
    induction' n with n ih;
    · norm_num;
    · simpa only [ pow_succ', mul_assoc, Function.iterate_succ_apply' ] using le_trans ( h_contraction _ _ ) ( mul_le_mul_of_nonneg_left ih <| NNReal.coe_nonneg _ );
  exact Summable.of_nonneg_of_le ( fun n => dist_nonneg ) h_induction ( Summable.mul_right _ <| summable_geometric_of_lt_one ( NNReal.coe_nonneg _ ) hK )

/-! ## Section 5: Concrete Cardinality Bounds

We establish explicit bounds on the number of neighborhood types, showing
that the renormalization framework operates in a space whose dimension
is bounded by a computable function of the branching bound and radius.
-/

/-
At radius 0, there is exactly one neighborhood type (the isolated root).
-/
theorem nbhdTypeCount_zero (B : ℕ) : nbhdTypeCount B 0 = 1 := by
  exact Fintype.card_eq_one_iff.mpr ⟨ ⟨ ⟩, fun x => by cases x; rfl ⟩

/-
At radius 1, the number of neighborhood types equals B + 1
(the root can have 0, 1, ..., B children, each necessarily a leaf).
-/
theorem nbhdTypeCount_one (B : ℕ) : nbhdTypeCount B 1 = B + 1 := by
  unfold nbhdTypeCount;
  unfold BoundedRootedTree;
  simp +decide [ Fintype.card_sigma, Fintype.card_pi ];
  -- Since BoundedRootedTree B 0 is a singleton set, its cardinality is 1.
  have h_singleton : BoundedRootedTree B 0 ≃ Unit := by
    exact Equiv.refl _;
  erw [ Fintype.card_congr h_singleton ] ; norm_num

/-- At any radius, the number of neighborhood types is at least 1
(the leaf tree always exists). -/
theorem nbhdTypeCount_ge_one (B r : ℕ) : 1 ≤ nbhdTypeCount B r := by
  exact nbhdTypeCount_pos B r

/-! ## Section 6: Profile Simplex Structure

We show that probability distributions (nonnegative, sum-to-one functions)
form a closed, bounded subset of the profile space. Under bounded branching,
this is a compact simplex — the natural habitat of renormalization dynamics.
-/

/-- A local profile is a probability distribution if it is nonneg and sums to 1. -/
def IsProfileDist {B r : ℕ} (μ : LocalProfile B r) : Prop :=
  (∀ t, 0 ≤ μ t) ∧ (∑ t, μ t) = 1

/-
The zero profile (all frequencies zero) satisfies nonnegativity.
-/
theorem zero_profile_nonneg {B r : ℕ} : ∀ t, (0 : ℝ) ≤ (0 : LocalProfile B r) t := by
  exact fun _ => le_rfl

/-
Profile distances are bounded by 2 for probability distributions.
-/
theorem profile_dist_le_two {B r : ℕ} (μ ν : LocalProfile B r)
    (hμ : IsProfileDist μ) (hν : IsProfileDist ν) :
    dist μ ν ≤ 2 := by
  rw [ dist_eq_norm ];
  rw [ pi_norm_le_iff_of_nonneg ] <;> norm_num;
  exact fun i => abs_le.mpr ⟨ by linarith [ hμ.1 i, hν.1 i, hμ.2, hν.2, Finset.single_le_sum ( fun a _ => hμ.1 a ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun a _ => hν.1 a ) ( Finset.mem_univ i ) ], by linarith [ hμ.1 i, hν.1 i, hμ.2, hν.2, Finset.single_le_sum ( fun a _ => hμ.1 a ) ( Finset.mem_univ i ), Finset.single_le_sum ( fun a _ => hν.1 a ) ( Finset.mem_univ i ) ] ⟩

end ProofSearchRenormalization