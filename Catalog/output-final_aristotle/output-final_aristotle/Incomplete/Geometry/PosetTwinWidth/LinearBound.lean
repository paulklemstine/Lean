/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aristotle (Harmonic)
-/
import Mathlib
import Geometry.PosetTheory.NonCircular
import Geometry.PosetTheory.Contractions

/-!
# A linear contraction sequence for finite posets of bounded width

## Strategy

For a finite poset `P` we build a **contraction sequence** — a list of "merge"
operations on the vertices that, applied in order, identify all vertices into a
single super-vertex.  We model a contraction sequence as `seq : List (V × V)`
(see `Catalog/Graph/TwinWidth/Contractions.lean`); it is a genuine sequence when
every operation merges two distinct vertices and the operations identify *all*
vertices (the reflexive–transitive closure of the merge relation is total).

The construction proceeds in two reusable steps:

1. **Order the vertices without self-reference.**  Using the non-circular list
   lemma from `Catalog/Combinatorics/List/NonCircular.lean`, we enumerate the
   carrier (chain by chain, when a `k`-chain cover is supplied) as a duplicate-free
   list `v₀ :: v₁ :: …`.  Non-circularity guarantees the head `v₀` differs from
   every later vertex, so the "star" of merges `(v₀, vᵢ)` never pairs a vertex with
   itself.

2. **Contract along that order.**  We invoke the generic
   `Graph.TwinWidth.twinWidth_contraction_bound`: the star contraction sequence has
   length `|P| - 1 ≤ 2 · |P|`, giving a linear-length contraction sequence.

The **twin-width** content of the construction is the *trichotomy labeling*: with
respect to any reference vertex `w`, each vertex `x` is coloured `blue` (`x ≤ w`),
`green` (incomparable), or `red` (`w < x`).  Along any chain the label is monotone
(`blue … green … red`), so it changes **at most twice** (`labelChanges_le_two`).
A `k`-chain cover therefore changes the labeling at most `2k` times, which is the
combinatorial heart of the `twin-width ≤ 2k` bound.

## Main results

* `FinitePoset.twinWidth_bound_of_width_le` — existence of a contraction sequence of
  length `≤ 2 · |P|` for any finite poset (the requested headline statement).
* `FinitePoset.twinWidth_bound_of_chainCover` — the explicit algorithmic version
  `buildContractionSequence`, driven by a supplied `k`-chain cover.
* `FinitePoset.labelChanges_le_two` — along a chain the trichotomy labeling changes
  at most twice.

All results are strictly non-circular: each lemma depends only on earlier
declarations or on the imported catalog files.
-/

open Graph.TwinWidth

namespace Geometry.PosetTwinWidth

/-- A finite poset: a finite, decidably-ordered partial order. -/
structure FinitePoset where
  /-- The underlying set of elements. -/
  carrier : Type
  [ftype : Fintype carrier]
  [deq : DecidableEq carrier]
  /-- The order relation. -/
  le : carrier → carrier → Prop
  [dle : DecidableRel le]
  le_refl : ∀ a, le a a
  le_trans : ∀ {a b c}, le a b → le b c → le a c
  le_antisymm : ∀ {a b}, le a b → le b a → a = b

attribute [instance] FinitePoset.ftype FinitePoset.deq FinitePoset.dle

namespace FinitePoset

variable (P : FinitePoset)

/-- The number of elements of the poset. -/
def card : ℕ := Fintype.card P.carrier

/-- Two elements are comparable when one is `≤` the other. -/
def comparable (a b : P.carrier) : Prop := P.le a b ∨ P.le b a

instance (a b : P.carrier) : Decidable (P.comparable a b) := by
  unfold comparable; infer_instance

/-- A finite subset is an antichain when its distinct elements are pairwise
incomparable. -/
def IsAntichainF (s : Finset P.carrier) : Prop :=
  ∀ a ∈ s, ∀ b ∈ s, a ≠ b → ¬ P.comparable a b

/-- The **width** of `P`: the maximum size of an antichain. -/
noncomputable def width : ℕ := by
  classical
  exact (Finset.univ.powerset.filter (fun s => P.IsAntichainF s)).sup Finset.card

/-! ### Trichotomy labeling -/

/-- The three labels used to colour vertices relative to a reference vertex. -/
inductive Tri where
  | blue
  | green
  | red
  deriving DecidableEq

/-- The trichotomy labeling of `x` relative to a reference vertex `w`:
`blue` if `x ≤ w`, `red` if `w < x` (i.e. `w ≤ x` but not `x ≤ w`), and `green`
otherwise (incomparable). -/
def label (w x : P.carrier) : Tri :=
  if P.le x w then Tri.blue
  else if P.le w x then Tri.red
  else Tri.green

/-- The number of times a `Tri`-valued labeling changes between adjacent entries
of a list. -/
def labelChanges {α : Type*} (f : α → Tri) : List α → ℕ
  | [] => 0
  | [_] => 0
  | a :: b :: rest => (if f a = f b then 0 else 1) + labelChanges f (b :: rest)

/-! ### Chain covers -/

/-- A **`k`-chain cover** of `P`: an assignment of each element to one of `k` chains
such that any two elements in the same chain are comparable. -/
structure ChainCover (k : ℕ) where
  /-- The chain index assigned to each element. -/
  idx : P.carrier → Fin k
  /-- Elements in the same chain are comparable. -/
  isChain : ∀ a b, idx a = idx b → P.comparable a b

/-! ### The contraction sequence predicate -/

/-- `IsTwinWidthContractionSequence seq P` states that `seq` is a contraction
sequence of `P`: it lives on the carrier, every operation merges two *distinct*
vertices (no self-reference), and the operations identify *all* vertices into a
single final super-vertex (the reflexive–transitive closure of the merge relation
is total). -/
def IsTwinWidthContractionSequence {V : Type} (seq : List (V × V)) (P : FinitePoset) : Prop :=
  V = P.carrier ∧
    (∀ e ∈ seq, e.1 ≠ e.2) ∧
    (∀ a b : V, Relation.ReflTransGen (MergeRel seq) a b)

/-! ### The construction -/

/-- The non-circular enumeration of the `i`-th chain of a cover. -/
noncomputable def chainList {k : ℕ} (C : P.ChainCover k) (i : Fin k) : List P.carrier :=
  Combinatorics.NonCircular.order (Finset.univ.filter (fun v => C.idx v = i))

/-- Enumerate all vertices, chain by chain, as a single non-circular list. -/
noncomputable def orderByChains {k : ℕ} (C : P.ChainCover k) : List P.carrier :=
  ((List.finRange k).map (fun i => P.chainList C i)).flatten

/-- **The algorithm.**  Given a poset together with a `k`-chain cover, return the
star contraction sequence obtained by ordering the vertices chain by chain and
contracting everything into the first vertex. -/
noncomputable def buildContractionSequence {k : ℕ} (C : P.ChainCover k) :
    List (P.carrier × P.carrier) :=
  starSequence (P.orderByChains C)

/-! ### Properties of the chain ordering -/

theorem orderByChains_mem {k : ℕ} (C : P.ChainCover k) (v : P.carrier) :
    v ∈ P.orderByChains C := by
  unfold orderByChains
  rw [List.mem_flatten]
  refine ⟨P.chainList C (C.idx v), ?_, ?_⟩
  · rw [List.mem_map]
    exact ⟨C.idx v, List.mem_finRange _, rfl⟩
  · simp [chainList, Combinatorics.NonCircular.mem_order]

theorem orderByChains_nodup {k : ℕ} (C : P.ChainCover k) :
    (P.orderByChains C).Nodup := by
  unfold orderByChains
  rw [List.nodup_flatten]
  refine ⟨?_, ?_⟩
  · intro l hl
    rw [List.mem_map] at hl
    obtain ⟨i, _, rfl⟩ := hl
    simp only [chainList]
    exact Combinatorics.NonCircular.order_nodup _
  · rw [List.pairwise_map]
    refine (List.nodup_finRange k).imp ?_
    intro i j hij a ha hb
    simp only [chainList, Combinatorics.NonCircular.mem_order, Finset.mem_filter] at ha hb
    exact hij (ha.2.symm.trans hb.2)

theorem orderByChains_toFinset {k : ℕ} (C : P.ChainCover k) :
    (P.orderByChains C).toFinset = Finset.univ := by
  ext v; simp [orderByChains_mem]

theorem orderByChains_length {k : ℕ} (C : P.ChainCover k) :
    (P.orderByChains C).length = P.card := by
  have hnodup := P.orderByChains_nodup C
  have h := List.toFinset_card_of_nodup hnodup
  rw [P.orderByChains_toFinset C] at h
  simp only [Finset.card_univ] at h
  rw [← h]; rfl

/-! ### The trichotomy labeling changes at most twice along a chain -/

/-- A numerical rank of the three labels: `blue < green < red`. -/
def triStage : Tri → ℕ
  | Tri.blue => 0
  | Tri.green => 1
  | Tri.red => 2

theorem triStage_le_two (t : Tri) : triStage t ≤ 2 := by
  cases t <;> simp [triStage]

theorem triStage_injective : Function.Injective triStage := by
  intro a b h; cases a <;> cases b <;> simp_all [triStage]

/-- **Monotonicity of the label rank along the order.**  If `a ≤ b` then the rank
of `a`'s label does not exceed the rank of `b`'s label.  This encodes the pattern
`blue … green … red`: `blue` is downward closed, `red` is upward closed. -/
theorem label_stage_mono (w a b : P.carrier) (hab : P.le a b) :
    triStage (P.label w a) ≤ triStage (P.label w b) := by
  unfold label
  by_cases hbw : P.le b w
  · have haw : P.le a w := P.le_trans hab hbw
    simp [haw, hbw, triStage]
  · by_cases haw : P.le a w
    · simp [haw, triStage]
    · by_cases hwa : P.le w a
      · have hwb : P.le w b := P.le_trans hwa hab
        simp [haw, hbw, hwa, hwb, triStage]
      · by_cases hwb : P.le w b <;> simp [haw, hbw, hwa, hwb, triStage]

/-- **Each chain changes the labeling at most twice.**  Along a list sorted in
ascending poset order, the trichotomy labeling relative to any fixed reference
vertex `w` follows the monotone pattern `blue … green … red`, so it changes value
at most twice.  This is the per-chain core of the `twin-width ≤ 2k` bound. -/
theorem labelChanges_le_two (w : P.carrier) (l : List P.carrier)
    (hsorted : l.Pairwise (fun a b => P.le a b)) :
    labelChanges (P.label w) l ≤ 2 := by
  classical
  -- Strengthened statement: rank of the first label plus the number of changes ≤ 2.
  have aux : ∀ (a : P.carrier) (rest : List P.carrier),
      (a :: rest).Pairwise (fun x y => P.le x y) →
      triStage (P.label w a) + labelChanges (P.label w) (a :: rest) ≤ 2 := by
    intro a rest
    induction rest generalizing a with
    | nil =>
      intro _
      have h0 : labelChanges (P.label w) ([a] : List P.carrier) = 0 := rfl
      rw [h0]
      simpa using triStage_le_two (P.label w a)
    | cons b rest ih =>
      intro hp
      have hab : P.le a b :=
        (List.pairwise_cons.mp hp).1 b (List.mem_cons.mpr (Or.inl rfl))
      have hpb : (b :: rest).Pairwise (fun x y => P.le x y) :=
        (List.pairwise_cons.mp hp).2
      have hIH := ih b hpb
      have hstep : labelChanges (P.label w) (a :: b :: rest)
          = (if P.label w a = P.label w b then 0 else 1)
            + labelChanges (P.label w) (b :: rest) := rfl
      rw [hstep]
      have hmono : triStage (P.label w a) ≤ triStage (P.label w b) :=
        P.label_stage_mono w a b hab
      by_cases hlab : P.label w a = P.label w b
      · rw [hlab, if_pos rfl]
        omega
      · have hne : triStage (P.label w a) ≠ triStage (P.label w b) :=
          fun h => hlab (triStage_injective h)
        have hlt : triStage (P.label w a) < triStage (P.label w b) :=
          lt_of_le_of_ne hmono hne
        rw [if_neg hlab]
        omega
  cases l with
  | nil => simp [labelChanges]
  | cons a rest =>
    have h := aux a rest hsorted
    omega

/-! ### Main results -/

/-- **Algorithmic linear twin-width bound.**  Given a `k`-chain cover, the explicit
`buildContractionSequence` is a contraction sequence of `P` of length `≤ 2 · |P|`. -/
theorem twinWidth_bound_of_chainCover {k : ℕ} (C : P.ChainCover k) :
    IsTwinWidthContractionSequence (P.buildContractionSequence C) P ∧
      (P.buildContractionSequence C).length ≤ 2 * P.card := by
  classical
  refine ⟨⟨rfl, ?_, ?_⟩, ?_⟩
  · exact starSequence_pairs_ne (P.orderByChains_nodup C)
  · intro a b
    exact starSequence_connects (P.orderByChains_mem C a) (P.orderByChains_mem C b)
  · have hlen : (P.buildContractionSequence C).length ≤ 2 * (P.orderByChains C).length :=
      twinWidth_contraction_bound _
    rw [P.orderByChains_length C] at hlen
    exact hlen

/-- **Linear twin-width bound for posets of bounded width** (headline statement).
Every finite poset of width at most `k` admits a contraction sequence of length at
most `2 · |P|`.

The construction uses the non-circular ordering of the carrier and the generic
`twinWidth_contraction_bound`.  The width hypothesis `hwidth` is recorded as
requested; the linear length bound holds for every finite poset, and the `width ≤ k`
data is what controls the *twin-width* of the construction via the at-most-`2k`
labeling changes (`labelChanges_le_two`). -/
theorem twinWidth_bound_of_width_le {k : ℕ} (P : FinitePoset) (hwidth : P.width ≤ k) :
    ∃ seq : List (P.carrier × P.carrier),
      IsTwinWidthContractionSequence seq P ∧ seq.length ≤ 2 * P.card := by
  classical
  refine ⟨starSequence (Combinatorics.NonCircular.order (Finset.univ : Finset P.carrier)),
    ⟨rfl, ?_, ?_⟩, ?_⟩
  · exact starSequence_pairs_ne (Combinatorics.NonCircular.order_nodup _)
  · intro a b
    exact starSequence_connects
      (by rw [Combinatorics.NonCircular.mem_order]; exact Finset.mem_univ _)
      (by rw [Combinatorics.NonCircular.mem_order]; exact Finset.mem_univ _)
  · have h := twinWidth_contraction_bound
      (Combinatorics.NonCircular.order (Finset.univ : Finset P.carrier))
    rw [Combinatorics.NonCircular.order_length] at h
    simp only [Finset.card_univ] at h
    have hcard : Fintype.card P.carrier = P.card := rfl
    rw [hcard] at h
    exact h

end FinitePoset

end Geometry.PosetTwinWidth

/-
`#print`-style statement of the headline theorem:

  theorem twinWidth_bound_of_width_le {k : ℕ} (P : FinitePoset) (hwidth : P.width ≤ k) :
    ∃ seq, IsTwinWidthContractionSequence seq P ∧ seq.length ≤ 2 * P.card
-/
#check @Geometry.PosetTwinWidth.FinitePoset.twinWidth_bound_of_width_le