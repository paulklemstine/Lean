/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Configuration Graph Pathwidth — Proof Memory as Graph Layout

This file develops a graph-theoretic theory connecting resolution proof memory
(clause space) to the pathwidth of associated configuration graphs.

## Main Definitions

* `PathDecomp` — A path decomposition: a non-empty sequence of bags (finite sets)
* `PathDecomp.width` — Width of a path decomposition (max bag size minus one)
* `PathDecomp.HasIntervalProp` — The interval/connectedness property
* `PathDecomp.MonotoneProp` — Once an element leaves, it never returns
* `ConfigTrace` — A trace of configurations (bags of clauses)
* `ConfigTrace.clauseSpace` — Maximum configuration size in a trace

## Main Results

* `PathDecomp.maxBagCard_le_of_forall` — If all bags have card ≤ s, then maxBagCard ≤ s
* `PathDecomp.width_le_of_spaceBound` — Width ≤ s - 1 when all bags bounded by s
* `PathDecomp.monotone_implies_interval` — Monotone traces satisfy the interval property
* `pathwidth_of_regular_trace_le` — Combined: regular bounded trace → valid decomp of bounded width
* `confGraphBounded_mono` — Bounded configuration graphs are monotone in the space parameter
* `traceMemoryNumber_le_minClauseSpace` — Clause space lower-bounds trace memory number
-/

open List Finset

/-! ## Path Decompositions -/

/-- A path decomposition is a non-empty sequence of bags (finite sets of vertices).
This is the fundamental structure connecting proof memory to graph layout. -/
structure PathDecomp (α : Type*) where
  /-- The ordered sequence of bags -/
  bags : List (Finset α)
  /-- A path decomposition must have at least one bag -/
  bags_nonempty : bags ≠ []

namespace PathDecomp

variable {α : Type*} [DecidableEq α]

/-- Maximum bag cardinality across all bags in the decomposition -/
def maxBagCard (P : PathDecomp α) : ℕ :=
  P.bags.foldr (fun B w => max B.card w) 0

/-- Width of a path decomposition: maximum bag size minus one.
This matches the standard graph-theoretic convention. -/
def width (P : PathDecomp α) : ℕ := P.maxBagCard - 1

/-- The interval (connectedness) property: for each vertex v, the set of
bag indices containing v forms a contiguous interval. -/
def HasIntervalProp (P : PathDecomp α) : Prop :=
  ∀ (x : α) (i j k : ℕ) (hi : i < P.bags.length) (hj : j < P.bags.length)
    (hk : k < P.bags.length),
    i ≤ j → j ≤ k →
    x ∈ P.bags[i] → x ∈ P.bags[k] → x ∈ P.bags[j]

/-- The monotonicity property: once an element disappears from the bags,
it never returns. This models "regular" resolution traces where clauses
are never re-derived after erasure. -/
def MonotoneProp (P : PathDecomp α) : Prop :=
  ∀ (x : α) (i j : ℕ) (hi : i < P.bags.length) (hj : j < P.bags.length),
    i ≤ j → x ∈ P.bags[i] → x ∉ P.bags[j] →
    ∀ (k : ℕ) (hk : k < P.bags.length), j ≤ k → x ∉ P.bags[k]

/-- Two elements co-occur in some bag of the decomposition -/
def Cooccurs (P : PathDecomp α) (u v : α) : Prop :=
  ∃ (i : ℕ) (hi : i < P.bags.length), u ∈ P.bags[i] ∧ v ∈ P.bags[i]

/-! ### Width Bound Theorems -/

/-
Helper: foldr max over mapped list is at most s if all elements map to ≤ s.
-/
omit [DecidableEq α] in
theorem foldr_max_le (l : List (Finset α)) (s : ℕ)
    (h : ∀ B ∈ l, B.card ≤ s) :
    l.foldr (fun B w => max B.card w) 0 ≤ s := by
  induction' l with B l ih;
  · exact Nat.zero_le _;
  · grind

omit [DecidableEq α] in
/-- The maximum bag cardinality is bounded by any uniform bound on individual bags. -/
theorem maxBagCard_le_of_forall (P : PathDecomp α) (s : ℕ)
    (h : ∀ B ∈ P.bags, B.card ≤ s) :
    P.maxBagCard ≤ s := by
  exact foldr_max_le P.bags s h

/-
If all bags have cardinality at most s, then the width is at most s - 1.
-/
omit [DecidableEq α] in
theorem width_le_of_spaceBound (P : PathDecomp α) (s : ℕ)
    (h : ∀ B ∈ P.bags, B.card ≤ s) :
    P.width ≤ s - 1 := by
  exact Nat.sub_le_sub_right ( maxBagCard_le_of_forall P s h ) _

/-! ### Monotonicity implies the Interval Property -/

/-
**Monotone traces satisfy the interval property.**

If elements in a configuration trace never reappear after being erased
(the "regularity" condition in proof complexity), then the trace
automatically satisfies the interval axiom of path decompositions.

Proof sketch: Suppose x ∈ bags[i] and x ∈ bags[k] with i ≤ j ≤ k.
If x ∉ bags[j], then by monotonicity (applied at i, j), x ∉ bags[k].
This contradicts x ∈ bags[k].
-/
omit [DecidableEq α] in
theorem monotone_implies_interval (P : PathDecomp α) :
    P.MonotoneProp → P.HasIntervalProp := by
  intro h x i j k hi hj hk hij hjk hx hx';
  contrapose! h;
  intro H; have := H x i j hi hj hij hx h; aesop;

end PathDecomp

/-! ## Configuration Traces and Resolution -/

/-- A configuration trace models a sequence of memory states during a
resolution proof search. Each configuration is a finite set of clauses
currently held in memory. -/
structure ConfigTrace (α : Type*) where
  /-- The sequence of configurations -/
  configs : List (Finset α)
  /-- A trace must have at least one step -/
  configs_nonempty : configs ≠ []

namespace ConfigTrace

variable {α : Type*} [DecidableEq α]

/-- Convert a configuration trace to a path decomposition by using
configurations directly as bags. -/
def toPathDecomp (T : ConfigTrace α) : PathDecomp α where
  bags := T.configs
  bags_nonempty := T.configs_nonempty

/-- The clause space of a trace: the maximum number of clauses held
simultaneously at any step. -/
def clauseSpace (T : ConfigTrace α) : ℕ := T.toPathDecomp.maxBagCard

/-- A trace is regular (monotone) if no clause is re-derived after erasure. -/
def IsRegular (T : ConfigTrace α) : Prop := T.toPathDecomp.MonotoneProp

/-- A trace starts from the empty configuration. -/
def StartsEmpty (T : ConfigTrace α) : Prop :=
  T.configs.head T.configs_nonempty = ∅

/-- A trace achieves a goal element (e.g. the empty clause). -/
def Achieves (T : ConfigTrace α) (goal : α) : Prop :=
  goal ∈ T.configs.getLast T.configs_nonempty

/-- A trace is a refutation reaching a goal within space bound s. -/
structure IsRefutation (T : ConfigTrace α) (goal : α) (s : ℕ) : Prop where
  starts_empty : T.StartsEmpty
  achieves_goal : T.Achieves goal
  space_bound : ∀ B ∈ T.configs, B.card ≤ s

end ConfigTrace

/-! ## Bounded Configuration Graphs -/

/-- The bounded configuration graph adjacency: two configurations are
adjacent if they both have cardinality ≤ s and differ by exactly one element. -/
def confGraphBoundedAdj [DecidableEq α] (s : ℕ) (C₁ C₂ : Finset α) : Prop :=
  C₁.card ≤ s ∧ C₂.card ≤ s ∧ C₁ ≠ C₂ ∧
  (∃ x, C₂ = C₁ ∪ {x} ∨ C₂ = C₁ \ {x} ∨ C₁ = C₂ ∪ {x} ∨ C₁ = C₂ \ {x})

/-
Bounded configuration graphs are monotone: larger space bounds yield
more edges (supergraphs).
-/
theorem confGraphBounded_mono [DecidableEq α] {s t : ℕ} (hst : s ≤ t)
    (C₁ C₂ : Finset α) :
    confGraphBoundedAdj s C₁ C₂ → confGraphBoundedAdj t C₁ C₂ := by
  exact fun h => ⟨ le_trans h.1 hst, le_trans h.2.1 hst, h.2.2.1, h.2.2.2 ⟩

/-! ## Trace Memory Number and Clause Space -/

/-- The minimum clause space for refuting with a given goal over a set of traces. -/
noncomputable def minClauseSpace [DecidableEq α] (goal : α)
    (traces : Set (ConfigTrace α)) : ℕ :=
  sInf { s : ℕ | ∃ T ∈ traces, T.IsRegular ∧ ConfigTrace.IsRefutation T goal s }

/-- The trace memory number: the minimum width of any path decomposition
arising from a valid regular refutation trace. -/
noncomputable def traceMemoryNumber [DecidableEq α] (goal : α)
    (traces : Set (ConfigTrace α)) : ℕ :=
  sInf { w : ℕ | ∃ T ∈ traces, T.IsRegular ∧ T.Achieves goal ∧
    T.toPathDecomp.width ≤ w }

/-
**Trace memory number is at most the minimum clause space minus one.**

Any regular refutation trace with clause space s gives rise to a path
decomposition of width ≤ s - 1 (via monotone → interval property + width bound),
hence the infimum of widths is at most the infimum of clause spaces minus one.
-/
theorem traceMemoryNumber_le_minClauseSpace [DecidableEq α]
    (goal : α) (traces : Set (ConfigTrace α))
    (hexists : ∃ T ∈ traces, T.IsRegular ∧
      ∃ s, ConfigTrace.IsRefutation T goal s) :
    traceMemoryNumber goal traces ≤ minClauseSpace goal traces - 1 := by
  obtain ⟨T, hT_mem, hreg, h_s⟩ := hexists
  obtain ⟨s, hs⟩ := h_s
  have h_cs : minClauseSpace goal traces ∈ {s : ℕ | ∃ T ∈ traces, T.IsRegular ∧ T.IsRefutation goal s} := by
    convert Nat.sInf_mem _;
    exact ⟨ s, ⟨ T, hT_mem, hreg, hs ⟩ ⟩
  obtain ⟨T', hT'_mem, hreg', h_s'⟩ := h_cs
  have h_width : T'.toPathDecomp.width ≤ minClauseSpace goal traces - 1 := by
    apply PathDecomp.width_le_of_spaceBound T'.toPathDecomp (minClauseSpace goal traces) (fun B hB => h_s'.space_bound B hB)
  have h_trace : traceMemoryNumber goal traces ≤ minClauseSpace goal traces - 1 := by
    exact Nat.sInf_le ⟨ T', hT'_mem, hreg', h_s'.achieves_goal, h_width ⟩
  exact h_trace

/-! ## Main Theorem Package -/

variable {α : Type*} [DecidableEq α]

omit [DecidableEq α] in
/-- **Theorem 1 (Trace-to-Pathwidth Upper Bound):**
A regular refutation trace in clause space s yields a valid path decomposition
of the clause co-occurrence graph with width at most s - 1.

This is the foundational result converting proof memory into graph layout. -/
theorem pathwidth_of_regular_trace_le (T : ConfigTrace α) (s : ℕ)
    (hreg : T.IsRegular) (hspace : ∀ B ∈ T.configs, B.card ≤ s) :
    T.toPathDecomp.HasIntervalProp ∧ T.toPathDecomp.width ≤ s - 1 := by
  exact ⟨T.toPathDecomp.monotone_implies_interval hreg,
         T.toPathDecomp.width_le_of_spaceBound s hspace⟩

omit [DecidableEq α] in
/-
**Theorem 2 (Existence of Bounded-Width Path Decomposition):**
If there exists a regular refutation in clause space s, then there exists
a path decomposition with width ≤ s - 1.
-/
theorem exists_pathDecomp_of_refutation (goal : α) (s : ℕ)
    (h : ∃ T : ConfigTrace α, T.IsRegular ∧ ConfigTrace.IsRefutation T goal s) :
    ∃ P : PathDecomp α, P.HasIntervalProp ∧ P.width ≤ s - 1 := by
  obtain ⟨ T, hT₁, hT₂ ⟩ := h; use T.toPathDecomp; exact pathwidth_of_regular_trace_le T s hT₁ hT₂.space_bound;

/-- The visited configuration graph adjacency: two configurations are
adjacent if they appear consecutively in the trace. -/
def visitedGraphAdj (T : ConfigTrace α) (C₁ C₂ : Finset α) : Prop :=
  C₁ ≠ C₂ ∧
  ∃ (i : ℕ) (hi : i + 1 < T.configs.length),
    (T.configs[i] = C₁ ∧ T.configs[i + 1] = C₂) ∨
    (T.configs[i] = C₂ ∧ T.configs[i + 1] = C₁)

/-
**Theorem 3: Trace stays in bounded configuration graph.**
A trace with space bound s has all its transitions within the s-bounded
configuration graph (assuming transitions are single-element changes).
-/
theorem trace_in_confGraphBounded (T : ConfigTrace α) (s : ℕ)
    (hspace : ∀ B ∈ T.configs, B.card ≤ s)
    {C₁ C₂ : Finset α} (hadj : visitedGraphAdj T C₁ C₂)
    (hstep : ∃ x, C₂ = C₁ ∪ {x} ∨ C₂ = C₁ \ {x} ∨
                   C₁ = C₂ ∪ {x} ∨ C₁ = C₂ \ {x}) :
    confGraphBoundedAdj s C₁ C₂ := by
  grind +locals

/-! ## Conjecture: Clause Space Dominates Configuration Graph Pathwidth -/

/-- **Conjecture (stated formally):** There exists a universal constant c such that
for every unsatisfiable formula, the pathwidth of the bounded configuration graph
is at most c times the minimum clause space. -/
def clauseSpace_dominates_pathwidth_conjecture : Prop :=
  ∃ c : ℕ, 0 < c ∧
    ∀ (β : Type) (_ : DecidableEq β) (goal : β) (traces : Set (ConfigTrace β)),
      (∃ T ∈ traces, T.IsRegular ∧ ∃ s, ConfigTrace.IsRefutation T goal s) →
      ∃ P : PathDecomp β, P.HasIntervalProp ∧
        P.width ≤ c * @minClauseSpace β _ goal traces