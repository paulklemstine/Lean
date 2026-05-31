/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Persistent Homology of Loop-Filtered Divergence Complexes: Definitions

This file introduces the core definitions for a finite combinatorial model
capturing the relationship between persistent homology of loop-filtered
divergence complexes and renormalizability of quantum field theories.

## Main definitions

* `DivProfile` - Divergence profile for a QFT at bounded loop order
* `PersistData` - Persistence data linking cycles to generators
* `primDivFinset` / `primDivCount` - Primitive divergent types and their count
* `essentialFinset` / `persistBarCount` - Essential cycles and their count
* `TheorySystem` - A family of divergence profiles indexed by truncation level
* `IsRenormalizable` - The theory has bounded primitive divergent type count
* `LoopComplex` - Loop-filtered divergence complex for Euler defect theorem
-/

open Finset

/-! ## Divergence Profile -/

/-- A divergence profile encodes the combinatorial data of graph types in a
quantum field theory at bounded loop order. Each graph type `g : α` carries:
- `loopOrder g` : the loop number of the graph
- `supDiv g` : whether the graph is superficially divergent
- `prim g` : whether the graph is primitive (1PI, no subdivergences) -/
structure DivProfile (α : Type*) [Fintype α] [DecidableEq α] where
  loopOrder : α → ℕ
  supDiv : α → Bool
  prim : α → Bool

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The finset of primitive superficially divergent graph types. -/
def primDivFinset (D : DivProfile α) : Finset α :=
  Finset.univ.filter (fun g => D.supDiv g && D.prim g)

/-- Count of primitive superficially divergent types. -/
def primDivCount (D : DivProfile α) : ℕ :=
  (primDivFinset D).card

/-! ## Persistence Data -/

/-- Persistence data captures the homological structure linking essential
persistent 1-cycles to their generating primitive divergent types. -/
structure PersistData (α β : Type*) [Fintype α] [DecidableEq α]
    [Fintype β] [DecidableEq β] where
  essential : β → Bool
  generator : β → α

variable {β : Type*} [Fintype β] [DecidableEq β]

/-- The finset of essential persistent 1-cycles. -/
def essentialFinset (P : PersistData α β) : Finset β :=
  Finset.univ.filter (fun z => P.essential z)

/-- Count of persistent essential 1-bars. -/
def persistBarCount (P : PersistData α β) : ℕ :=
  (essentialFinset P).card

/-! ## Theory Systems and Renormalizability -/

/-- A theory system is a family of divergence profiles indexed by truncation
level n, representing the theory analyzed up to loop order n. -/
structure TheorySystem where
  GraphType : ℕ → Type*
  finInst : ∀ n, Fintype (GraphType n)
  decEqInst : ∀ n, DecidableEq (GraphType n)
  profile : ∀ n, @DivProfile (GraphType n) (finInst n) (decEqInst n)

/-- A theory is renormalizable if there exists a uniform bound on the
number of primitive superficially divergent types across all truncation levels. -/
def IsRenormalizable (T : TheorySystem) : Prop :=
  ∃ B : ℕ, ∀ n : ℕ, @primDivCount _ (T.finInst n) (T.decEqInst n) (T.profile n) ≤ B

/-- A theory has unbounded divergences if for every N,
there exists a truncation level with more than N primitive divergent types. -/
def HasUnboundedDivergences (T : TheorySystem) : Prop :=
  ∀ N : ℕ, ∃ n : ℕ, N < @primDivCount _ (T.finInst n) (T.decEqInst n) (T.profile n)

/-! ## Loop-Filtered Complex -/

/-- A loop-filtered divergence complex with vertices and edges. -/
structure LoopComplex (α : Type*) [DecidableEq α] where
  vertices : Finset α
  edges : Finset (α × α)
  filtration : α → ℕ
  edge_source_mem : ∀ e ∈ edges, e.1 ∈ vertices
  edge_target_mem : ∀ e ∈ edges, e.2 ∈ vertices
  no_self_loops : ∀ e ∈ edges, e.1 ≠ e.2

def vertexCount {α : Type*} [DecidableEq α] (C : LoopComplex α) : ℕ :=
  C.vertices.card

def edgeCount {α : Type*} [DecidableEq α] (C : LoopComplex α) : ℕ :=
  C.edges.card

/-! ## Toy model: φ⁴ in 4 dimensions -/

/-- The two primitive divergent residue types in φ⁴₄. -/
inductive Phi4Residue where
  | twoPoint : Phi4Residue
  | fourPoint : Phi4Residue
  deriving DecidableEq, Fintype

theorem phi4_residue_card : Fintype.card Phi4Residue = 2 := by decide

/-- The φ⁴₄ divergence profile on residue types. -/
def phi4ResidueProfile : DivProfile Phi4Residue where
  loopOrder := fun _ => 1
  supDiv := fun _ => true
  prim := fun _ => true

theorem phi4_primDivFinset_eq_univ :
    primDivFinset phi4ResidueProfile = Finset.univ := by
  ext x; simp [primDivFinset, phi4ResidueProfile]

theorem phi4_primDivCount_eq_two :
    primDivCount phi4ResidueProfile = 2 := by
  simp [primDivCount, phi4_primDivFinset_eq_univ]
  decide