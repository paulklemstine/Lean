/-
  Packing-Isolating Sets in Finite Simple Graphs — Core Definitions

  We formalize, for finite simple graphs with decidable adjacency, the notions of
  *closed neighborhood*, *2-packing* and *isolating set*, and the combined notion
  of a *packing-isolating set* (a vertex set that is simultaneously a 2-packing and
  an isolating set).

  These build directly on `Mathlib.Combinatorics.SimpleGraph.Basic`
  (`SimpleGraph`, `neighborFinset`, `Adj`).

  * `closedNbhd G v`         : `{v} ∪ N(v)`, the closed neighborhood, as a `Finset`.
  * `nbhdSet G S`            : `⋃_{s ∈ S} closedNbhd G s`.
  * `IsTwoPacking G S`       : closed neighborhoods of distinct members of `S` are disjoint.
  * `IsIsolating G S`        : every edge has an endpoint in `nbhdSet G S`.
  * `IsPackingIsolating G S` : both of the above.

  Main basic facts:
  * `isTwoPacking_singleton`  : a single vertex is always a 2-packing.
  * `IsTwoPacking.subset`     : subsets of 2-packings are 2-packings.
  * `IsIsolating.superset`    : supersets of isolating sets are isolating.
  * `isIsolating_of_dominating` : dominating sets are isolating.

  -- !-- Lab Notes -- !--
  Hypothesis (Stage 1): the right primitive is the *closed* neighborhood; "2-packing"
    should be encoded as pairwise disjointness of closed neighborhoods (equivalent to
    pairwise distance ≥ 3) and "isolating" as edge-domination by `nbhdSet`.
  Experiment (Stage 2): defining everything over `Finset` with `[DecidableRel G.Adj]`
    keeps membership computable, which later powers a `decide`-checked boundary example.
  Analysis (Stage 3): `mem_closedNbhd` / `mem_nbhdSet` are the workhorse rewrite lemmas;
    once stated, the structural monotonicity lemmas fall out by plain set reasoning.
  Critique (Stage 4): none of these are vacuous — `isTwoPacking_singleton` needs the
    `u ≠ v` clause to avoid a self-disjointness obligation, and the monotonicity lemmas
    have the genuinely-correct direction (packings shrink, isolating sets grow).
-/
import Mathlib

open Finset SimpleGraph

namespace PackingIsolation

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Closed neighborhood of `v`: `v` together with its neighbors, as a `Finset`. -/
def closedNbhd (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) : Finset V :=
  insert v (G.neighborFinset v)

/-- Closed neighborhood of a set `S`: the union of the closed neighborhoods of its members. -/
def nbhdSet (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Finset V :=
  S.biUnion (closedNbhd G)

/-- `S` is a **2-packing**: the closed neighborhoods of distinct members are disjoint. -/
def IsTwoPacking (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ u ∈ S, ∀ v ∈ S, u ≠ v → Disjoint (closedNbhd G u) (closedNbhd G v)

/-- `S` is **isolating**: every edge has at least one endpoint in the closed neighborhood of `S`. -/
def IsIsolating (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  ∀ u v, G.Adj u v → u ∈ nbhdSet G S ∨ v ∈ nbhdSet G S

/-- A **packing-isolating set** is both a 2-packing and an isolating set. -/
def IsPackingIsolating (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Prop :=
  IsTwoPacking G S ∧ IsIsolating G S

instance decIsTwoPacking (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Decidable (IsTwoPacking G S) := by unfold IsTwoPacking; infer_instance

instance decIsIsolating (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Decidable (IsIsolating G S) := by unfold IsIsolating; infer_instance

instance decIsPackingIsolating (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) :
    Decidable (IsPackingIsolating G S) := by unfold IsPackingIsolating; infer_instance

variable {G : SimpleGraph V} [DecidableRel G.Adj]

/-- Membership in a closed neighborhood. -/
theorem mem_closedNbhd {v x : V} : x ∈ closedNbhd G v ↔ x = v ∨ G.Adj v x := by
  simp [closedNbhd, mem_neighborFinset]

/-- A vertex always lies in its own closed neighborhood. -/
theorem self_mem_closedNbhd (v : V) : v ∈ closedNbhd G v := by simp [closedNbhd]

/-- Membership in the closed neighborhood of a set. -/
theorem mem_nbhdSet {S : Finset V} {x : V} : x ∈ nbhdSet G S ↔ ∃ s ∈ S, x = s ∨ G.Adj s x := by
  simp [nbhdSet, closedNbhd, mem_neighborFinset]

/-- A single vertex is always a 2-packing (the disjointness condition is vacuous). -/
theorem isTwoPacking_singleton (v : V) : IsTwoPacking G {v} := by
  intro a ha b hb hab
  simp only [mem_singleton] at ha hb
  subst ha hb
  exact absurd rfl hab

/-- A subset of a 2-packing is a 2-packing. -/
theorem IsTwoPacking.subset {S T : Finset V} (hT : IsTwoPacking G T) (hST : S ⊆ T) :
    IsTwoPacking G S := fun u hu v hv h => hT u (hST hu) v (hST hv) h

/-- Enlarging an isolating set keeps it isolating. -/
theorem IsIsolating.superset {S T : Finset V} (hS : IsIsolating G S) (hST : S ⊆ T) :
    IsIsolating G T := by
  intro u v huv
  rcases hS u v huv with h | h
  · left; rw [mem_nbhdSet] at h ⊢; obtain ⟨s, hs, hx⟩ := h; exact ⟨s, hST hs, hx⟩
  · right; rw [mem_nbhdSet] at h ⊢; obtain ⟨s, hs, hx⟩ := h; exact ⟨s, hST hs, hx⟩

/-- A dominating set (whose closed neighborhood is the whole vertex set) is isolating. -/
theorem isIsolating_of_dominating {S : Finset V} (h : ∀ x : V, x ∈ nbhdSet G S) :
    IsIsolating G S := fun u _ _ => Or.inl (h u)

end PackingIsolation