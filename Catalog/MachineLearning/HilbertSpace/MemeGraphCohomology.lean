/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Sheaf cohomology of meme propagation on social networks — base theory

This file develops the **cellular sheaf cohomology of the constant sheaf on a finite
graph**, the model of *meme propagation* on a social network.

## The model

A **social network** is a finite undirected graph, presented as a finite vertex type `V`
(the people), a finite edge type `E` (the communication channels), together with two
endpoint maps `src tgt : E → V`.

A **meme** is modelled as the constant sheaf `K` (a field of possible interpretations)
placed on every vertex, with the identity restriction along every edge.  A *0-cochain*
`f : V → K` assigns an interpretation to each person; a *1-cochain* `g : E → K` records a
discrepancy along each channel.  The **coboundary** operator

  `(δ f) e = f (tgt e) - f (src e)`

measures the failure of `f` to be consistent across a channel.

* `H⁰ = ker δ` — globally consistent interpretations (global sections of the sheaf).
* `H¹ = coker δ = (E → K) / range δ` — consistency obstructions.

## Main results in this file

* `MemeGraph.coboundary_const` — constant interpretations are always consistent.
* `MemeGraph.mem_H0_iff` — membership in `H⁰` is consistency across every channel.
* `MemeGraph.finrank_range_add_finrank_H0` — rank–nullity for the coboundary.
* `MemeGraph.finrank_H1` — dimension identity for the obstruction space.
* `MemeGraph.euler_characteristic` — `dim H⁰ − dim H¹ = |V| − |E|`.
* `MemeGraph.Adj`, `MemeGraph.compSetoid`, `MemeGraph.components` — adjacency, the
  connected-component setoid, and the number of connected components.
* `MemeGraph.H0_eq_of_reachable` — a consistent interpretation is constant on each
  connected component.

The disconnected computation of `dim H⁰` and `dim H¹` in terms of the number of
components lives in `MemeDisconnectedCohomology.lean`.
-/

namespace MemeGraph

open Module

variable {K : Type*} [Field K]
variable {V E : Type*} [Fintype V] [Fintype E] [DecidableEq V]

/-! ## The coboundary operator -/

/-- The **coboundary** (discrete gradient) of the constant sheaf on a finite graph with
endpoint maps `src tgt : E → V`.  It sends a 0-cochain `f : V → K` to the 1-cochain
measuring the discrepancy `f (tgt e) - f (src e)` along each edge `e`. -/
def coboundary (src tgt : E → V) : (V → K) →ₗ[K] (E → K) where
  toFun f := fun e => f (tgt e) - f (src e)
  map_add' f g := by funext e; simp; ring
  map_smul' c f := by funext e; simp; ring

omit [Fintype V] [Fintype E] [DecidableEq V] in
@[simp] theorem coboundary_apply (src tgt : E → V) (f : V → K) (e : E) :
    coboundary (K := K) src tgt f e = f (tgt e) - f (src e) := rfl

/-- `H⁰`, the space of globally consistent interpretations (global sections of the sheaf):
the kernel of the coboundary. -/
def H0 (src tgt : E → V) : Submodule K (V → K) := LinearMap.ker (coboundary (K := K) src tgt)

/-- `H¹`, the space of consistency obstructions (the cokernel of the coboundary). -/
abbrev H1 (src tgt : E → V) := (E → K) ⧸ LinearMap.range (coboundary (K := K) src tgt)

/-! ## Constant interpretations are consistent -/

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- A meme that means the *same* thing to everyone is globally consistent. -/
theorem coboundary_const (src tgt : E → V) (c : K) :
    coboundary (K := K) src tgt (fun _ => c) = 0 := by
  exact funext fun x => sub_self c

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- Constant interpretations lie in `H⁰`. -/
theorem const_mem_H0 (src tgt : E → V) (c : K) :
    (fun _ => c) ∈ H0 (K := K) src tgt := by
  exact coboundary_const src tgt c

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- Membership in `H⁰` means exactly consistency across every channel. -/
theorem mem_H0_iff (src tgt : E → V) (f : V → K) :
    f ∈ H0 (K := K) src tgt ↔ ∀ e : E, f (src e) = f (tgt e) := by
  unfold H0
  simp +decide [funext_iff, coboundary]
  grind

/-! ## Rank–nullity and the Euler characteristic -/

omit [Fintype E] [DecidableEq V] in
/-- **Rank–nullity for the coboundary.** -/
theorem finrank_range_add_finrank_H0 (src tgt : E → V) :
    finrank K (LinearMap.range (coboundary (K := K) src tgt))
      + finrank K (H0 (K := K) src tgt) = Fintype.card V := by
  convert LinearMap.finrank_range_add_finrank_ker (coboundary (K := K) src tgt) using 1
  simp

omit [Fintype V] [DecidableEq V] in
/-- **Dimension of the obstruction space.** -/
theorem finrank_H1 (src tgt : E → V) :
    finrank K (H1 (K := K) src tgt)
      + finrank K (LinearMap.range (coboundary (K := K) src tgt)) = Fintype.card E := by
  convert Submodule.finrank_quotient_add_finrank
    (LinearMap.range (coboundary (K := K) src tgt)) using 1
  simp

omit [DecidableEq V] in
/-- **Euler characteristic / meme balance law.**  `dim H⁰ − dim H¹ = |V| − |E|`. -/
theorem euler_characteristic (src tgt : E → V) :
    (finrank K (H0 (K := K) src tgt) : ℤ) - finrank K (H1 (K := K) src tgt)
      = (Fintype.card V : ℤ) - Fintype.card E := by
  have h1 := finrank_range_add_finrank_H0 (K := K) src tgt
  have h2 := finrank_H1 (K := K) src tgt
  grind

/-! ## Adjacency and connected components -/

/-- Two people are **adjacent** if some communication channel joins them (in either
direction). -/
def Adj (src tgt : E → V) (u v : V) : Prop :=
  ∃ e : E, (src e = u ∧ tgt e = v) ∨ (src e = v ∧ tgt e = u)

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- Adjacency is symmetric. -/
theorem adj_symmetric (src tgt : E → V) : Symmetric (Adj src tgt) := by
  rintro u v ⟨e, h⟩
  exact ⟨e, h.symm⟩

/-- Reachability: the reflexive–transitive closure of adjacency. -/
def Reach (src tgt : E → V) : V → V → Prop := Relation.ReflTransGen (Adj src tgt)

/-- The **connected-component setoid**: two people are related when one is reachable from
the other by a chain of communication channels. -/
def compSetoid (src tgt : E → V) : Setoid V where
  r := Reach src tgt
  iseqv :=
    { refl := fun _ => Relation.ReflTransGen.refl
      symm := fun h => Relation.ReflTransGen.symmetric (adj_symmetric src tgt) h
      trans := fun h h' => Relation.ReflTransGen.trans h h' }

/-- The **number of connected components** of the social network. -/
noncomputable def components (src tgt : E → V) : ℕ :=
  Nat.card (Quotient (compSetoid src tgt))

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- A consistent interpretation takes equal values on adjacent people. -/
theorem H0_eq_of_adj (src tgt : E → V) {f : V → K} (hf : f ∈ H0 (K := K) src tgt)
    {u v : V} (h : Adj src tgt u v) : f u = f v := by
  rw [mem_H0_iff] at hf
  obtain ⟨e, he⟩ := h
  cases he <;> aesop

omit [Fintype V] [Fintype E] [DecidableEq V] in
/-- A consistent interpretation takes equal values on reachable (i.e. same-component)
people. -/
theorem H0_eq_of_reachable (src tgt : E → V) {f : V → K} (hf : f ∈ H0 (K := K) src tgt)
    {u v : V} (h : Reach src tgt u v) : f u = f v := by
  induction h with
  | refl => rfl
  | tail _ hstep ih => rw [ih, H0_eq_of_adj src tgt hf hstep]

end MemeGraph