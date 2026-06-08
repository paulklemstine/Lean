/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Berggren Tropical Lensing Duality

## Overview

We develop a three-layer theorem package establishing a canonical tropical geodesic
structure on height-truncated Berggren trees of primitive Pythagorean triples:

1. **Tropical Bellman Principle**: On any finite weighted DAG, shortest-path potentials
   exist and satisfy the Bellman optimality equation. These potentials are the *least*
   fixed points of the tropical transfer operator—the "optical metric" on the tree.

2. **Lensing Duality**: Arithmetic compatibility predicates on Berggren nodes define
   terminal penalties; backward tropical propagation yields the minimum-cost path to
   a compatible node. The resulting geodesic funnel is the arithmetic caustic.

3. **Certified Reconstruction**: From the tropical potential, greedy predecessor descent
   reconstructs an optimal path. If the terminal node is arithmetically compatible,
   the path yields a certified divisor witness.

## Mathematical Significance

This work reframes divisor-candidate search as shortest geodesic reconstruction
in a tropical metric geometry on Diophantine state trees, establishing a bridge
between Berggren tree dynamics, min-plus optimization, and certified arithmetic.

## Key Definitions

* `bellmanOp` — the tropical Bellman transfer operator on `V → WithTop ℕ`
* `BerggrenGen`, `applyGen` — Berggren generators on ℤ-triples
* `Compatible` — arithmetic compatibility: a coordinate of the triple divides `n`
* `extractDivisor` — extraction of certified divisor witnesses from compatible nodes
* `lensValue` — backward tropical propagation from compatible terminal nodes
-/

set_option maxHeartbeats 800000
set_option linter.unusedVariables false

namespace BerggrenTropicalLensing

open Finset WithTop

/-! ## Part 1: Finite DAG Shortest-Path Theory (Tropical Bellman Principle)

We establish shortest-path existence and Bellman optimality for finite weighted DAGs.
The vertex type is finite, edges respect a strict rank function, and edge weights
take values in `WithTop ℕ` (the tropical semiring with ⊤ = +∞).
-/

section TropicalBellman

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The Bellman operator on potentials `V → WithTop ℕ`.
    At the root it assigns cost 0; at other nodes it takes the minimum over
    predecessors of `φ(u) + w(u,v)`. -/
noncomputable def bellmanOp
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (φ : V → WithTop ℕ) : V → WithTop ℕ :=
  fun v =>
    if v = root then 0
    else (Finset.univ).inf (fun u => if adj u v then φ u + w u v else ⊤)

/-
The Bellman operator is monotone: if φ ≤ ψ pointwise, then bellmanOp φ ≤ bellmanOp ψ.
-/
theorem bellmanOp_mono
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (φ ψ : V → WithTop ℕ)
    (hle : ∀ v, φ v ≤ ψ v) :
    ∀ v, bellmanOp root adj w φ v ≤ bellmanOp root adj w ψ v := by
  intro v; by_cases hv : v = root <;> simp +decide [ *, bellmanOp ] ;
  intro b; exact (by
  refine' le_trans ( Finset.inf_le ( Finset.mem_univ b ) ) _;
  split_ifs <;> simp +decide [ *, add_le_add_left ])

/-- A potential φ is a Bellman super-solution (post-fixed point) if φ(root) ≥ 0 (i.e., root
    cost is at least 0) and for every non-root v, φ(v) ≥ min_u (φ(u) + w(u,v)).
    Super-solutions are over-estimates of the shortest-path distance. -/
def IsBellmanSuperSol
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (φ : V → WithTop ℕ) : Prop :=
  φ root = 0 ∧
  ∀ v, v ≠ root → φ v ≥ (Finset.univ).inf (fun u => if adj u v then φ u + w u v else ⊤)

/-- A potential φ is a Bellman fixed point if φ(root) = 0 and for every non-root v,
    φ(v) = min_u (φ(u) + w(u,v)). -/
def IsBellmanFixedPt
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (φ : V → WithTop ℕ) : Prop :=
  φ root = 0 ∧
  ∀ v, v ≠ root → φ v = (Finset.univ).inf (fun u => if adj u v then φ u + w u v else ⊤)

/-- The shortest-path potential defined by well-founded recursion on the rank function.
    At the root it is 0; at other nodes it is the infimum over predecessors. -/
noncomputable def shortestPotential
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v) :
    V → WithTop ℕ :=
  fun v => WellFounded.fix (InvImage.wf rank Nat.lt_wfRel.wf) (fun v ih =>
    if v = root then 0
    else (Finset.univ).inf (fun u =>
      if h : adj u v then ih u (h_acyclic u v h) + w u v else ⊤)) v

/-
Unfolding lemma for shortestPotential.
-/
theorem shortestPotential_unfold
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v)
    (v : V) :
    shortestPotential root adj w rank h_acyclic v =
    if v = root then 0
    else (Finset.univ).inf (fun u =>
      if h : adj u v then shortestPotential root adj w rank h_acyclic u + w u v else ⊤) := by
  convert WellFounded.fix_eq _ _ v using 1

/-
shortestPotential assigns 0 to the root.
-/
theorem shortestPotential_root
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v) :
    shortestPotential root adj w rank h_acyclic root = 0 := by
  rw [ shortestPotential_unfold, if_pos rfl ]

/-
shortestPotential satisfies the Bellman equation at non-root nodes.
-/
theorem shortestPotential_bellman
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v)
    (v : V) (hv : v ≠ root) :
    shortestPotential root adj w rank h_acyclic v =
    (Finset.univ).inf (fun u =>
      if adj u v then shortestPotential root adj w rank h_acyclic u + w u v else ⊤) := by
  have := shortestPotential_unfold root adj w rank h_acyclic v;
  grind

/-
shortestPotential is a Bellman fixed point.
-/
theorem shortestPotential_is_fixed_pt
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v) :
    IsBellmanFixedPt root adj w (shortestPotential root adj w rank h_acyclic) := by
  constructor;
  · exact?;
  · -- Apply the definition of `shortestPotential` to conclude the proof.
    apply shortestPotential_bellman

/-- Helper: the Bellman inf comparison lemma. If f ≤ g pointwise, then
    Finset.univ.inf f ≤ Finset.univ.inf g. -/
theorem inf_le_inf_of_le {V : Type*} [Fintype V] {f g : V → WithTop ℕ}
    (h : ∀ u, f u ≤ g u) : Finset.univ.inf f ≤ Finset.univ.inf g :=
  Finset.inf_mono_fun (fun u _ => h u)

/-
shortestPotential is minimal among Bellman sub-solutions.
-/
theorem shortestPotential_minimal
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v)
    (ψ : V → WithTop ℕ)
    (hψ : IsBellmanSuperSol root adj w ψ) :
    ∀ v, shortestPotential root adj w rank h_acyclic v ≤ ψ v := by
  -- Apply the induction principle to v using the hypothesis that all u with rank u < rank v satisfy the goal.
  intro v
  apply (InvImage.wf rank Nat.lt_wfRel.wf).induction v;
  intro v ih
  by_cases hv : v = root;
  · simp +decide [ *, shortestPotential_root ];
  · rw [ shortestPotential_bellman root adj w rank h_acyclic v hv ];
    refine' le_trans _ ( hψ.2 v hv );
    nontriviality;
    exact inf_le_inf_of_le fun u => by split_ifs <;> [ exact add_le_add ( ih u ( h_acyclic u v ‹_› ) ) le_rfl; rfl ] ;

/-- **Theorem 1: Tropical Bellman Principle.**
    On any finite DAG with nonnegative edge weights and a distinguished root,
    there exists a shortest-path potential that:
    (1) assigns cost 0 to the root,
    (2) satisfies the Bellman optimality equation at every non-root node,
    (3) is the least potential satisfying the Bellman sub-solution inequality. -/
theorem exists_bellman_fixed_point
    (root : V)
    (adj : V → V → Prop) [DecidableRel adj]
    (w : V → V → WithTop ℕ)
    (rank : V → ℕ)
    (h_acyclic : ∀ u v, adj u v → rank u < rank v) :
    ∃ φ : V → WithTop ℕ,
      IsBellmanFixedPt root adj w φ ∧
      ∀ ψ : V → WithTop ℕ, IsBellmanSuperSol root adj w ψ → ∀ v, φ v ≤ ψ v := by
  exact ⟨_, shortestPotential_is_fixed_pt root adj w rank h_acyclic,
    fun ψ hψ => shortestPotential_minimal root adj w rank h_acyclic ψ hψ⟩

end TropicalBellman

/-! ## Part 2: Berggren Tree Algebra

We define the Berggren generators over ℤ, prove they preserve the Pythagorean
property, and establish the strict hypotenuse increase that makes the truncated
tree a finite DAG.
-/

/-- The three Berggren generators for the ternary tree of primitive Pythagorean triples. -/
inductive BerggrenGen where
  | A | B | C
  deriving DecidableEq, Repr, Inhabited

instance : Fintype BerggrenGen where
  elems := {BerggrenGen.A, BerggrenGen.B, BerggrenGen.C}
  complete := by intro x; cases x <;> simp

/-- A Pythagorean triple over ℤ. -/
abbrev ZTriple := ℤ × ℤ × ℤ

/-- The Pythagorean property: a² + b² = c². -/
def IsPythagorean (t : ZTriple) : Prop :=
  t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-- Apply a Berggren generator to a triple.
    A = [1,-2,2; 2,-1,2; 2,-2,3],  B = [1,2,2; 2,1,2; 2,2,3],  C = [-1,2,2; -2,1,2; -2,2,3] -/
def applyGen : BerggrenGen → ZTriple → ZTriple
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
def rootTriple : ZTriple := (3, 4, 5)

/-- The root triple is Pythagorean. -/
theorem rootTriple_isPythagorean : IsPythagorean rootTriple := by
  unfold IsPythagorean rootTriple; norm_num

/-- Generator A preserves the Pythagorean property. -/
theorem genA_preserves (t : ZTriple) (h : IsPythagorean t) :
    IsPythagorean (applyGen .A t) := by
  obtain ⟨a, b, c⟩ := t
  unfold IsPythagorean applyGen at *
  nlinarith [h]

/-- Generator B preserves the Pythagorean property. -/
theorem genB_preserves (t : ZTriple) (h : IsPythagorean t) :
    IsPythagorean (applyGen .B t) := by
  obtain ⟨a, b, c⟩ := t
  unfold IsPythagorean applyGen at *
  nlinarith [h]

/-- Generator C preserves the Pythagorean property. -/
theorem genC_preserves (t : ZTriple) (h : IsPythagorean t) :
    IsPythagorean (applyGen .C t) := by
  obtain ⟨a, b, c⟩ := t
  unfold IsPythagorean applyGen at *
  nlinarith [h]

/-- Every Berggren generator preserves the Pythagorean property. -/
theorem gen_preserves_pythagorean (g : BerggrenGen) (t : ZTriple) (h : IsPythagorean t) :
    IsPythagorean (applyGen g t) := by
  cases g
  · exact genA_preserves t h
  · exact genB_preserves t h
  · exact genC_preserves t h

/-- **Key structural lemma**: Generator A strictly increases hypotenuse
    for triples with positive components where a < c and b < c. -/
theorem genA_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hac : a < c) (hbc : b < c) :
    c < (applyGen .A (a, b, c)).2.2 := by
  simp [applyGen]; nlinarith

/-- Generator B strictly increases hypotenuse for positive triples. -/
theorem genB_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (applyGen .B (a, b, c)).2.2 := by
  simp [applyGen]; nlinarith

/-- Generator C strictly increases hypotenuse for positive triples with a,b < c. -/
theorem genC_hyp_increase (a b c : ℤ) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (hac : a < c) (hbc : b < c) :
    c < (applyGen .C (a, b, c)).2.2 := by
  simp [applyGen]; nlinarith

/-- Apply a sequence of generators (a Berggren word) to the root triple. -/
def applyWord : List BerggrenGen → ZTriple
  | [] => rootTriple
  | g :: gs => applyGen g (applyWord gs)

/-- Every word yields a Pythagorean triple. -/
theorem word_preserves_pythagorean (w : List BerggrenGen) :
    IsPythagorean (applyWord w) := by
  induction w with
  | nil => exact rootTriple_isPythagorean
  | cons g gs ih => exact gen_preserves_pythagorean g _ ih

/-- Concrete computation: the three children of (3,4,5). -/
theorem children_of_root :
    applyGen .A rootTriple = (5, 12, 13) ∧
    applyGen .B rootTriple = (21, 20, 29) ∧
    applyGen .C rootTriple = (15, 8, 17) := by
  refine ⟨?_, ?_, ?_⟩ <;> simp [applyGen, rootTriple]

/-! ## Part 3: Arithmetic Compatibility and Divisor Extraction

We define arithmetic compatibility predicates connecting Berggren nodes to
divisor information for a target integer `n`.
-/

/-- A Berggren node is *compatible* with integer `n` if one of its leg coordinates
    is a nontrivial divisor of `n`. This is the primary arithmetic extraction predicate,
    implementing Instantiation I from the specification. -/
def Compatible (n : ℕ) (t : ZTriple) : Prop :=
  (1 < t.1.natAbs ∧ t.1.natAbs < n ∧ t.1.natAbs ∣ n) ∨
  (1 < t.2.1.natAbs ∧ t.2.1.natAbs < n ∧ t.2.1.natAbs ∣ n)

instance (n : ℕ) (t : ZTriple) : Decidable (Compatible n t) :=
  inferInstanceAs (Decidable (_ ∨ _))

/-- GCD-based compatibility (Instantiation II): gcd(n, a) or gcd(n, b) is nontrivial. -/
def GCDCompatible (n : ℕ) (t : ZTriple) : Prop :=
  (1 < Nat.gcd n t.1.natAbs ∧ Nat.gcd n t.1.natAbs < n) ∨
  (1 < Nat.gcd n t.2.1.natAbs ∧ Nat.gcd n t.2.1.natAbs < n)

instance (n : ℕ) (t : ZTriple) : Decidable (GCDCompatible n t) :=
  inferInstanceAs (Decidable (_ ∨ _))

/-- Extract a divisor witness from a compatible node using GCD.
    Picks the first coordinate's GCD that is nontrivial AND strictly less than n;
    otherwise falls back to the second coordinate's GCD. -/
def extractDivisor (n : ℕ) (t : ZTriple) : ℕ :=
  if 1 < Nat.gcd n t.1.natAbs ∧ Nat.gcd n t.1.natAbs < n then Nat.gcd n t.1.natAbs
  else Nat.gcd n t.2.1.natAbs

/-
**Divisor extraction soundness**: `extractDivisor` always returns a value that divides `n`.
-/
theorem extractDivisor_dvd (n : ℕ) (t : ZTriple) :
    extractDivisor n t ∣ n := by
  unfold extractDivisor;
  split_ifs <;> [ exact Nat.gcd_dvd_left _ _; exact Nat.gcd_dvd_left _ _ ]

/-
**Divisor extraction nontriviality**: if `GCDCompatible n t`, then
    `extractDivisor` returns a value > 1.
-/
theorem extractDivisor_nontrivial_lb (n : ℕ) (t : ZTriple)
    (h : GCDCompatible n t) :
    1 < extractDivisor n t := by
  rcases h with ( h | h ) <;> simp_all +decide [ extractDivisor ];
  grind

/-
**Divisor extraction upper bound**: `extractDivisor` returns a value ≤ n when n > 0.
-/
theorem extractDivisor_le (n : ℕ) (t : ZTriple) (hn : 0 < n) :
    extractDivisor n t ≤ n := by
  exact Nat.le_of_dvd hn ( extractDivisor_dvd n t )

/-
If 0 < a < n, then gcd(n, a) < n.
-/
theorem gcd_lt_of_pos_lt {n a : ℕ} (ha_pos : 0 < a) (ha : a < n) : Nat.gcd n a < n := by
  exact lt_of_le_of_lt ( Nat.le_of_dvd ha_pos ( Nat.gcd_dvd_right _ _ ) ) ha

/-
Full nontriviality: if `GCDCompatible n t` with `n > 1` and the relevant
    coordinate's natAbs < n, then extractDivisor is strictly between 1 and n.
-/
theorem extractDivisor_nontrivial (n : ℕ) (t : ZTriple)
    (h : GCDCompatible n t)
    (hn : 1 < n)
    (h_lt : t.1.natAbs < n ∨ t.2.1.natAbs < n) :
    1 < extractDivisor n t ∧ extractDivisor n t < n := by
  unfold extractDivisor; cases h_lt <;> cases h <;> aesop;

/-
Compatible implies GCDCompatible (since a ∣ n implies gcd(n,a) ≥ a > 1).
-/
theorem compatible_imp_gcd_compatible (n : ℕ) (t : ZTriple) (h : Compatible n t) :
    GCDCompatible n t := by
  rcases h with ( h | h ) <;> simp_all +decide [ GCDCompatible ];
  · exact Or.inl ⟨ by rw [ Nat.gcd_eq_right h.2.2 ] ; linarith, by rw [ Nat.gcd_eq_right h.2.2 ] ; linarith ⟩;
  · exact Or.inr ⟨ by rw [ Nat.gcd_eq_right h.2.2 ] ; linarith, by rw [ Nat.gcd_eq_right h.2.2 ] ; linarith ⟩

/-! ## Part 4: Tropical Penalty and Lensing Operator

The penalty function assigns cost 0 to compatible nodes and ⊤ to incompatible ones.
The lensing operator propagates this penalty backward through the tree,
implementing a discrete Hamilton–Jacobi equation on the Berggren DAG.
-/

/-- Terminal penalty: 0 for compatible nodes, ⊤ otherwise.
    This is the refractive target condition in the tropical optics interpretation. -/
noncomputable def penalty (n : ℕ) (t : ZTriple) : WithTop ℕ :=
  if Compatible n t then 0 else ⊤

/-- The lensing value function: backward tropical propagation from compatible terminal nodes.
    At depth 0, returns the penalty. At depth d+1, takes the minimum of the local penalty
    and the best cost of reaching a compatible descendant through a Berggren generator. -/
noncomputable def lensValue (n : ℕ) (weight : ZTriple → ZTriple → WithTop ℕ)
    (depth : ℕ) (t : ZTriple) : WithTop ℕ :=
  match depth with
  | 0 => penalty n t
  | d + 1 =>
    min (penalty n t)
      (Finset.univ.inf fun g : BerggrenGen =>
        lensValue n weight d (applyGen g t) + weight t (applyGen g t))

/-- The lensing value at depth 0 equals the penalty. -/
theorem lensValue_zero (n : ℕ) (w : ZTriple → ZTriple → WithTop ℕ) (t : ZTriple) :
    lensValue n w 0 t = penalty n t := rfl

/-- **Lensing Bellman equation**: the value function satisfies a backward Bellman equation.
    This is the discrete Hamilton–Jacobi equation on the Berggren tree. -/
theorem lensValue_bellman (n : ℕ) (w : ZTriple → ZTriple → WithTop ℕ) (d : ℕ) (t : ZTriple) :
    lensValue n w (d + 1) t =
      min (penalty n t)
        (Finset.univ.inf fun g : BerggrenGen =>
          lensValue n w d (applyGen g t) + w t (applyGen g t)) := rfl

/-
If a node is compatible, its lensing value is 0 at any depth.
-/
theorem lensValue_compatible (n : ℕ) (w : ZTriple → ZTriple → WithTop ℕ)
    (d : ℕ) (t : ZTriple) (h : Compatible n t) :
    lensValue n w d t = 0 := by
  induction' d with d ih generalizing t <;> simp_all +decide [ lensValue ];
  · exact if_pos h;
  · unfold penalty; aesop;

/-
The lensing value is monotonically decreasing in depth:
    more search depth can only improve (lower) the value.
-/
theorem lensValue_mono_depth (n : ℕ) (w : ZTriple → ZTriple → WithTop ℕ)
    (d : ℕ) (t : ZTriple) :
    lensValue n w (d + 1) t ≤ lensValue n w d t := by
  induction' d with d ih generalizing t;
  · exact min_le_left _ _;
  · rw [ lensValue_bellman, lensValue_bellman ];
    gcongr ; aesop

/-! ## Part 5: Path Reconstruction and Certified Divisor Extraction

Given a finite-depth lensing computation with a compatible descendant,
we reconstruct the optimal path and extract a divisor witness.
This bridges tropical optimization to arithmetic certification.
-/

/-- A path in the Berggren tree is a word (list of generators). -/
abbrev BerggrenPath := List BerggrenGen

/-- The cost of a path given a weight function on edges. -/
noncomputable def pathCost (w : ZTriple → ZTriple → WithTop ℕ) :
    ZTriple → BerggrenPath → WithTop ℕ
  | _, [] => 0
  | t, g :: gs =>
    let t' := applyGen g t
    w t t' + pathCost w t' gs

/-- The triple reached at the end of a path. -/
def pathEndpoint : ZTriple → BerggrenPath → ZTriple
  | t, [] => t
  | t, g :: gs => pathEndpoint (applyGen g t) gs

/-- The hypotenuse difference weight: cost of edge (t, t') is |c' - c|. -/
def hypWeight (t t' : ZTriple) : WithTop ℕ :=
  ↑(t'.2.2 - t.2.2).natAbs

/-- Path cost is 0 for the empty path. -/
@[simp] theorem pathCost_nil (w : ZTriple → ZTriple → WithTop ℕ) (t : ZTriple) :
    pathCost w t [] = 0 := rfl

/-- Path endpoint of empty path is the starting triple. -/
@[simp] theorem pathEndpoint_nil (t : ZTriple) : pathEndpoint t [] = t := rfl

/-
**Theorem 2 (Lensing Duality).**
    If the lensing value at depth d is finite (< ⊤), then there exists a path of
    length ≤ d from the current node to a compatible descendant whose total cost
    (path cost + terminal penalty) equals the lensing value. This establishes the
    duality between tropical propagation and shortest-path-to-compatible-node.
-/
theorem lensing_duality
    (n : ℕ) (w : ZTriple → ZTriple → WithTop ℕ)
    (d : ℕ) (t : ZTriple)
    (h_finite : lensValue n w d t < ⊤) :
    ∃ p : BerggrenPath,
      p.length ≤ d ∧
      Compatible n (pathEndpoint t p) ∧
      pathCost w t p + penalty n (pathEndpoint t p) = lensValue n w d t := by
  -- We will prove this by induction on $d$.
  induction' d with d ih generalizing t;
  · simp_all +decide [ lensValue ];
    unfold penalty at h_finite; aesop;
  · -- Consider two cases: when the penalty is finite and when it is infinite.
    by_cases h_penalty : penalty n t < ⊤;
    · use [];
      simp_all +decide [ penalty ];
      split_ifs at h_penalty ⊢ <;> simp_all +decide [ lensValue_bellman ];
      unfold penalty; aesop;
    · -- Since the penalty is not finite, the lensing value must be equal to the minimum of the costs of the children.
      have h_min_children : ∃ g : BerggrenGen, lensValue n w d (applyGen g t) + w t (applyGen g t) = lensValue n w (d + 1) t := by
        have h_min_children : lensValue n w (d + 1) t = Finset.univ.inf (fun g : BerggrenGen => lensValue n w d (applyGen g t) + w t (applyGen g t)) := by
          exact min_eq_right ( by aesop );
        have := Finset.exists_min_image Finset.univ ( fun g => lensValue n w d ( applyGen g t ) + w t ( applyGen g t ) ) ⟨ BerggrenGen.A, Finset.mem_univ _ ⟩;
        obtain ⟨ g, hg₁, hg₂ ⟩ := this; use g; simp_all +decide [ Finset.inf_eq_iInf ] ;
        exact le_antisymm ( le_iInf hg₂ ) ( iInf_le _ _ );
      obtain ⟨ g, hg ⟩ := h_min_children
      have h_lensing_finite : lensValue n w d (applyGen g t) < ⊤ := by
        contrapose! h_finite; aesop;
      obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := ih (applyGen g t) h_lensing_finite
      use g :: p
      simp [hp₁, hp₂, hp₃];
      exact ⟨ hp₂, by rw [ show pathCost w t ( g :: p ) = w t ( applyGen g t ) + pathCost w ( applyGen g t ) p from rfl ] ; rw [ show pathEndpoint t ( g :: p ) = pathEndpoint ( applyGen g t ) p from rfl ] ; rw [ ← hg, ← hp₃ ] ; abel1 ⟩

/-
**Theorem 3 (Certified Reconstruction with Divisor Witness).**
    If a compatible descendant exists within depth d (witnessed by finite lensing value),
    then reconstruction yields a path ending at a compatible node from which a
    nontrivial divisor of n can be extracted. This is the arithmetic optics theorem:
    tropical geodesic reconstruction produces certified divisor evidence.
-/
theorem certified_reconstruction
    (n : ℕ) (hn : 2 < n)
    (w : ZTriple → ZTriple → WithTop ℕ)
    (d : ℕ) (t : ZTriple)
    (h_finite : lensValue n w d t < ⊤) :
    ∃ p : BerggrenPath, ∃ endpoint : ZTriple,
      endpoint = pathEndpoint t p ∧
      p.length ≤ d ∧
      Compatible n endpoint ∧
      ∃ divisor : ℕ, divisor ∣ n ∧ 1 < divisor ∧ divisor < n := by
  obtain ⟨ p, hp ⟩ := lensing_duality n w d t h_finite;
  rcases hp.2.1 with h|h <;> simp_all +decide;
  · exact ⟨ p, hp.1, hp.2.1, _, h.2.2, h.1, h.2.1 ⟩;
  · exact ⟨ p, hp.1, hp.2.1, _, h.2.2, h.1, h.2.1 ⟩

/-! ## Part 6: Berggren Specialization — Concrete Instantiation

We instantiate the abstract framework for the Berggren tree rooted at (3,4,5)
with hypotenuse-difference weights, connecting abstract tropical optimization
to the concrete Diophantine structure.
-/

/-- The Berggren lensing value for integer n at depth d from the root (3,4,5). -/
noncomputable def berggrenLensValue (n : ℕ) (d : ℕ) : WithTop ℕ :=
  lensValue n hypWeight d rootTriple

/-- Concrete example: (3,4,5) is compatible with 15 because 3 ∣ 15 and 1 < 3 < 15. -/
theorem root_compatible_15 : Compatible 15 rootTriple := by
  left; constructor <;> [skip; constructor] <;> simp [rootTriple]

/-- The lensing value for n = 15 at any depth is 0, since the root is compatible. -/
theorem berggrenLens_15 (d : ℕ) : berggrenLensValue 15 d = 0 := by
  exact lensValue_compatible 15 hypWeight d rootTriple root_compatible_15

/-- Concrete example: (5, 12, 13) is compatible with 65 because 5 ∣ 65. -/
theorem childA_compatible_65 : Compatible 65 (applyGen .A rootTriple) := by
  left; constructor <;> [skip; constructor] <;> simp [applyGen, rootTriple]

/-
For n = 65, at depth ≥ 1 the lensing value from root is at most 8
    (the hypotenuse difference 13 - 5 = 8), since the A-child (5,12,13) is compatible.
-/
theorem berggrenLens_65_bound :
    berggrenLensValue 65 1 ≤ 8 := by
  simp +decide [ Finset.inf ]

/-
The root triple (3,4,5) is compatible with any composite n that has 3 or 4 as a factor
    and n > 4.
-/
theorem root_compatible_of_dvd (n : ℕ) (hn : 4 < n) (h : 3 ∣ n ∨ 4 ∣ n) :
    Compatible n rootTriple := by
  cases h <;> rw [ Compatible ];
  · exact Or.inl ⟨ by decide, by norm_num [ rootTriple ] ; linarith, by assumption ⟩;
  · exact Or.inr ⟨ by decide, hn, by assumption ⟩

/-! ## Part 7: Tropical Algebra Auxiliary Lemmas -/

/-- Addition in `WithTop ℕ` is monotone in the left argument. -/
theorem withTop_add_le_add_left {a b c : WithTop ℕ} (h : a ≤ b) :
    a + c ≤ b + c := by
  gcongr

/-- min is idempotent: min a a = a. -/
theorem min_self_eq (a : WithTop ℕ) : min a a = a := min_self a

/-- If penalty is 0 (compatible node), min with penalty gives 0. -/
theorem min_penalty_zero {a : WithTop ℕ} : min (0 : WithTop ℕ) a = 0 :=
  min_eq_left (zero_le a)

/-- ⊤ is absorbing for addition in WithTop ℕ. -/
@[simp] theorem withTop_top_add (a : WithTop ℕ) : (⊤ : WithTop ℕ) + a = ⊤ := by
  simp

end BerggrenTropicalLensing