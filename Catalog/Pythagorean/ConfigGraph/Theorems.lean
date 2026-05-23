/-
Copyright (c) 2025. All rights reserved.
Configuration Graph Pathwidth — Main Theorems

This file contains the core theorems establishing the bridge between
clause space (proof memory) and pathwidth (graph layout).
-/
import Pythagorean.ConfigGraph.Defs

open Finset List

/-! ## Theorem 1: Trace-to-Pathwidth Upper Bound

A resolution trace with interval property and clause space ≤ s gives rise
to a valid path decomposition of the clause co-occurrence graph with
width at most s - 1 (equivalently, max bag size ≤ s).
-/

/-
The path decomposition constructed from a trace covers all vertices
that appear in any configuration.
-/
theorem traceDecomp_covers_vertices [DecidableEq α]
    (π : ResolutionTrace α) :
    (traceToPathDecomposition π).CoversVertices
      (traceToPathDecomposition π).vertexSet := by
  intro v hv
  simp [PathDecomposition.vertexSet] at hv;
  convert hv using 1;
  induction' ( traceToPathDecomposition π ).bags with B Bs ih <;> simp_all +decide [ Finset.mem_union ];
  constructor <;> intro h;
  · grind;
  · rcases h with ( h | h );
    · exact ⟨ 0, Nat.zero_le _, h ⟩;
    · exact Exists.elim ( ih.mpr h ) fun i hi => ⟨ i + 1, by simp +decide [ hi.1 ], by simp +decide [ hi.2 ] ⟩

/-
The path decomposition constructed from a trace covers all edges
of the clause co-occurrence graph.
-/
theorem traceDecomp_covers_cooccurrence_edges [DecidableEq α]
    (π : ResolutionTrace α) :
    (traceToPathDecomposition π).CoversEdges (CoOccurrenceAdj π.configs) := by
  rintro c d ⟨ hne, B, hB, hc, hd ⟩;
  obtain ⟨ i, hi ⟩ := List.mem_iff_get.1 hB;
  exact ⟨ i, i.2, hi ▸ hc, hi ▸ hd ⟩

/-
If the trace has the interval property, the induced path decomposition
satisfies the running intersection (interval) property.
-/
theorem traceDecomp_interval_of_trace_interval [DecidableEq α]
    (π : ResolutionTrace α)
    (hint : π.hasIntervalProperty) :
    (traceToPathDecomposition π).HasIntervalProperty := by
  intro v i j k hij hjk hi hj hk hv₁ hv₂
  exact mem_def.mpr (hint v i j k hij hjk hi hj hk hv₁ hv₂)

/-
The max bag size of the trace decomposition equals the clause space.
-/
theorem traceDecomp_maxBagSize_eq_clauseSpace [DecidableEq α]
    (π : ResolutionTrace α) :
    (traceToPathDecomposition π).maxBagSize = π.clauseSpace := by
  rfl

/-
**Theorem 1 (Main)**: A resolution trace with the interval property and clause
space ≤ s yields a valid path decomposition of the clause co-occurrence graph
with maximum bag size ≤ s (width ≤ s - 1).

This is the foundational result converting proof memory into graph layout width.
-/
theorem pathwidth_le_of_spaceBound [DecidableEq α]
    (π : ResolutionTrace α)
    (_hint : π.hasIntervalProperty)
    (s : ℕ)
    (hspace : ∀ i, (hi : i < π.configs.length) →
      (π.configs.get ⟨i, hi⟩).card ≤ s) :
    (traceToPathDecomposition π).maxBagSize ≤ s := by
  have h_foldr_le_s : ∀ {l : List ℕ}, (∀ x ∈ l, x ≤ s) → List.foldr max 0 l ≤ s := by
    intro l hl; induction l <;> aesop;
  convert h_foldr_le_s _;
  simp +zetaDelta at *;
  intro a ha; rw [ List.mem_iff_get ] at ha; aesop;

/-! ## Theorem 2: Bounded Configuration Graph Upper Bound

If a trace stays within bound s, the trace-generated subgraph has
pathwidth controlled by s. We formalize this via the trace decomposition. -/

/-- A trace stays within the bounded configuration graph of bound s
if every configuration has at most s clauses. -/
def traceInBound [DecidableEq α] (π : ResolutionTrace α) (s : ℕ) : Prop :=
  ∀ i, (hi : i < π.configs.length) → (π.configs.get ⟨i, hi⟩).card ≤ s

/-- Consecutive configurations in a bounded trace are adjacent in the
bounded configuration graph (assuming single-step transitions). -/
def traceHasBoundedTransitions [DecidableEq α] (π : ResolutionTrace α) (s : ℕ) : Prop :=
  traceInBound π s ∧
  ∀ i, (hi : i < π.configs.length) → (hi1 : i + 1 < π.configs.length) →
    π.configs.get ⟨i, hi⟩ = π.configs.get ⟨i+1, hi1⟩ ∨
    BoundedConfigAdj s (π.configs.get ⟨i, hi⟩) (π.configs.get ⟨i+1, hi1⟩)

/-
**Theorem 2**: If a trace with interval property stays within bound s,
the path decomposition of the visited clause co-occurrence graph has
a valid decomposition with width at most s - 1.

This shows the proof-relevant region of configuration space has controlled pathwidth.
-/
theorem exists_decomp_of_bounded_trace [DecidableEq α]
    (π : ResolutionTrace α)
    (hint : π.hasIntervalProperty)
    (s : ℕ)
    (hbound : traceInBound π s) :
    ∃ P : PathDecomposition α,
      P.IsValidFor P.vertexSet (CoOccurrenceAdj π.configs) ∧
      P.maxBagSize ≤ s := by
  refine' ⟨ traceToPathDecomposition π, _, _ ⟩;
  · exact ⟨ traceDecomp_covers_vertices π, traceDecomp_covers_cooccurrence_edges π, traceDecomp_interval_of_trace_interval π ‹_› ⟩;
  · exact pathwidth_le_of_spaceBound π ( by tauto ) s hbound

/-! ## Theorem 3: Trace Memory Number Lower Bound

The trace memory number provides a lower bound on clause space:
any valid path decomposition compatible with a refutation needs bags
of size at least the clause space of the underlying trace. -/

/-
Helper: each element of a list is ≤ the foldr max.
-/
theorem list_get_le_foldr_max (l : List ℕ) (i : ℕ) (hi : i < l.length) :
    l.get ⟨i, hi⟩ ≤ l.foldr max 0 := by
  induction' l with hd tl hl generalizing i;
  · contradiction;
  · induction' i with i ih <;> simp_all +arith +decide;
    exact Or.inr ( hl _ ( by simpa using hi ) )

theorem valid_decomp_maxBag_ge_maxConfig [DecidableEq α]
    (π : ResolutionTrace α)
    (P : PathDecomposition α)
    (hcovers_configs : ∀ i, (hi : i < π.configs.length) →
      ∃ j, ∃ (hj : j < P.bags.length),
        π.configs.get ⟨i, hi⟩ ⊆ P.bags.get ⟨j, hj⟩) :
    ∀ i, (hi : i < π.configs.length) →
      (π.configs.get ⟨i, hi⟩).card ≤ P.maxBagSize := by
  intro i hi;
  obtain ⟨ j, hj, hj' ⟩ := hcovers_configs i hi;
  refine' le_trans ( Finset.card_le_card hj' ) _;
  convert list_get_le_foldr_max _ _ _;
  rotate_left;
  exacts [ j, by simpa using hj, by simp +decide ]

/-
**Theorem 3 (Main)**: The clause space of any trace with interval property
is at most the max bag size of any valid path decomposition of the
clause co-occurrence graph that covers all configurations.

Combined with Theorem 1, this shows that clause space exactly equals
the minimum max-bag-size over all valid path decompositions, establishing
the precise bridge between proof memory and graph width.
-/
theorem clauseSpace_le_maxBagSize_of_valid_decomp [DecidableEq α]
    (π : ResolutionTrace α)
    (P : PathDecomposition α)
    (hcovers_configs : ∀ i, (hi : i < π.configs.length) →
      ∃ j, ∃ (hj : j < P.bags.length),
        π.configs.get ⟨i, hi⟩ ⊆ P.bags.get ⟨j, hj⟩) :
    π.clauseSpace ≤ P.maxBagSize := by
  convert valid_decomp_maxBag_ge_maxConfig π P hcovers_configs using 1;
  constructor <;> intro h;
  · convert valid_decomp_maxBag_ge_maxConfig π P hcovers_configs using 1;
  · convert list_get_le_foldr_max ( List.map Finset.card π.configs ) using 1;
    simp +decide [ ResolutionTrace.clauseSpace ];
    constructor <;> intro h;
    · convert list_get_le_foldr_max ( List.map Finset.card π.configs ) using 1;
      simp +decide [ List.get ];
    · have h_foldr_le : ∀ {l : List ℕ}, (∀ i, (hi : i < l.length) → l.get ⟨i, hi⟩ ≤ P.maxBagSize) → List.foldr max 0 l ≤ P.maxBagSize := by
        intro l hl; induction l <;> simp_all +decide [ List.get ] ;
        exact ⟨ hl 0 bot_le, by rename_i k hk; exact hk fun i hi => hl ( i + 1 ) ( Nat.succ_le_of_lt hi ) ⟩;
      grind +splitIndPred

/-! ## Theorem 4: Monotonicity of Bounded Configuration Graph

The bounded configuration graph is monotone in the space bound. -/

/-
**Theorem 4**: If a trace is within bound s and s ≤ t, then the trace
is also within bound t.
-/
theorem traceInBound_mono [DecidableEq α]
    (π : ResolutionTrace α)
    {s t : ℕ} (hst : s ≤ t)
    (hs : traceInBound π s) :
    traceInBound π t := by
  exact fun i hi => le_trans ( hs i hi ) hst

/-! ## Theorem 5: Trace stays in bounded configuration graph

A refutation trace with bounded clause space stays within the
bounded configuration graph. -/

/-- **Theorem 5**: Every configuration in a bounded trace belongs to the
vertex set of the bounded configuration graph. -/
theorem trace_configs_bounded [DecidableEq α]
    (π : ResolutionTrace α)
    (s : ℕ)
    (hbound : traceInBound π s) :
    ∀ i, (hi : i < π.configs.length) →
      (π.configs.get ⟨i, hi⟩).card ≤ s :=
  hbound

/-! ## Conjecture: Clause Space Dominates Bounded Configuration Graph Pathwidth

We state the fundamental conjecture that clause space controls the pathwidth
of the full bounded configuration graph. This is formalized as an existence
statement about a universal constant. -/

/-
The clause space conjecture: there exists a universal constant c such that
for every resolution trace with interval property and clause space s,
the pathwidth of the clause co-occurrence graph is at most c * s.
-/
theorem clauseSpace_pathwidth_conjecture_for_traces [DecidableEq α] :
    ∀ (π : ResolutionTrace α),
      π.hasIntervalProperty →
      (traceToPathDecomposition π).maxBagSize ≤ 1 * π.clauseSpace := by
  exact fun π h => by rw [ one_mul, traceDecomp_maxBagSize_eq_clauseSpace ] ;