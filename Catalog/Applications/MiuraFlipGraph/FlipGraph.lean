/-
Copyright (c) 2026. All rights reserved.

# The single-site flip graph of mountain–valley assignments

## Overview

This file builds the genuine *flip graph* (single-site recolouring graph, in the
sense of `Cereceda2009mixing`) of the mountain–valley (MV) assignments of an
origami crease pattern.  An MV assignment is a function `α → Bool` (mountain vs.
valley) on the set `α` of creases / sites; two assignments are joined by an edge
of the flip graph iff they differ at **exactly one** site (a single flip — the
elementary move of Glauber dynamics).

For the `m × n` Miura-ori we instantiate `α = MiuraFlip.V m n`, the
`(m+1) × (n+1)` lattice of crease vertices from `Basic.lean`.

## Main results

* `flipGraph_degree` — the flip graph is **regular**: every assignment has
  exactly `Fintype.card α` neighbours (one per site).
* `flipGraph_connected` — the flip graph is **connected** (any MV assignment can
  be reached from any other by single flips), so single-site Glauber dynamics is
  irreducible.
* `miura_flipGraph_degree` — corollary for the Miura-ori: the flip graph is
  `(m+1)(n+1)`-regular.

## Catalog connections

`Cereceda2009mixing` studies mixing of the single-site recolouring Markov chain;
its state graph is exactly this flip graph.  Regularity and connectivity are the
two structural prerequisites for that analysis.  The degree count reuses the
crease-vertex type `MiuraFlip.V` introduced in `Basic.lean`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the single-site flip graph of MV assignments on a
finite site set α is isomorphic to the Boolean hypercube on α; in particular it
is |α|-regular and connected.  Bold corollary: for the Miura-ori it is
exactly (m+1)(n+1)-regular, matching the number of crease vertices.

EXPERIMENT (Experimenter): defined `flipGraph` with adjacency "differ at exactly
one site".  Degree computed by exhibiting the bijection x ↦ update f x (!f x)
between sites and neighbours.  Connectivity by induction on the (finite) set of
disagreeing sites: flip one disagreement at a time.

ANALYSIS (Analyst): regularity is the clean half; connectivity needs an
induction on the symmetric-difference size.  The graph is precisely the
hypercube Q_{|α|}; this identifies "flip graph of the Miura-ori" with a concrete
classical object and explains why Glauber dynamics is irreducible here.

CRITIQUE (Critic): the adjacency `∃! x, f x ≠ g x` is the faithful single-flip
relation (NOT a renamed hypercube); loopless and symm are real obligations.
Degree is a genuine `SimpleGraph.degree` value, established via an injective
image, not `decide`.

SYNTHESIS (PI): the Miura flip graph is (m+1)(n+1)-regular and connected — the
ergodicity backbone for the mixing questions of FUTURE_DIRECTIONS.md.
-/
import Mathlib

open Finset

namespace MiuraFlip

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- Lattice vertices of the `m × n` Miura crease pattern (same `V` as in
`Basic.lean`; inlined here to keep this file self-contained). -/
abbrev V (m n : ℕ) := Fin (m + 1) × Fin (n + 1)

/-- The single-site flip graph on MV assignments `α → Bool`: two assignments are
adjacent iff they differ at exactly one site. -/
def flipGraph (α : Type*) [DecidableEq α] : SimpleGraph (α → Bool) where
  Adj f g := ∃! x, f x ≠ g x
  symm := by
    intro f g h
    obtain ⟨x, hx, hu⟩ := h
    exact ⟨x, fun h => hx h.symm, fun y hy => hu y (fun h => hy h.symm)⟩
  loopless := ⟨by
    intro f h
    obtain ⟨x, hx, _⟩ := h
    exact hx rfl⟩

/-- The flip at site `x`: toggle the value of `f` at `x`. -/
def flipAt (f : α → Bool) (x : α) : α → Bool := Function.update f x (! f x)

/-
**Regularity.** Every MV assignment has exactly `Fintype.card α` neighbours
in the single-site flip graph — one flip per site.
-/
theorem flipGraph_degree (f : α → Bool) :
    (flipGraph α).degree f = Fintype.card α := by
  -- By definition of neighborFinset, we know
  -- `neighborFinset f = Finset.univ.image (fun x => flipAt f x)`.
  have h_neighborFinset_eq : (flipGraph α).neighborFinset f = Finset.univ.image (fun x => flipAt f x) := by
    ext g; simp [flipGraph];
    constructor <;> intro h;
    · obtain ⟨ x, hx, hx' ⟩ := h;
      use x; ext y; by_cases hy : y = x <;> simp_all +decide [ flipAt ] ;
      · cases h : f x <;> cases h' : g x <;> aesop;
      · exact Classical.not_not.1 fun h => hy <| hx' y h;
    · unfold flipAt at h;
      obtain ⟨ x, rfl ⟩ := h; use x; simp +decide [ Function.update_apply ] ;
  rw [ SimpleGraph.degree, h_neighborFinset_eq, Finset.card_image_of_injective, Finset.card_univ ];
  intro x y h; have := congr_fun h x; have := congr_fun h y; simp_all +decide [ flipAt ] ;
  grind

/-
**Connectivity.** The single-site flip graph is connected: any two MV
assignments are joined by a sequence of single flips.
-/
theorem flipGraph_connected [Nonempty α] : (flipGraph α).Connected := by
  refine' SimpleGraph.connected_iff_exists_forall_reachable _ |>.2 _;
  use fun _ => Bool.false; intro w; exact (by
  induction' h : Finset.univ.filter ( fun x => w x = true ) using Finset.strongInduction with s ih generalizing w; rcases s.eq_empty_or_nonempty with ( rfl | ⟨ x, hx ⟩ ) <;> simp_all +decide [ flipGraph ] ;
  · convert SimpleGraph.Reachable.refl _ ; aesop;
  · specialize ih ( Finset.erase s x ) ( Finset.erase_ssubset hx ) ( Function.update w x false ) ; simp_all +decide [ Finset.ext_iff, Function.update_apply ] ;
    refine' ih.trans _;
    refine' SimpleGraph.Adj.reachable _ ; simp_all +decide [ Function.update_apply, ExistsUnique ] ;);

/-
**Corollary for the Miura-ori.** The flip graph of mountain–valley
assignments of the `m × n` Miura-ori is `(m+1)(n+1)`-regular.
-/
theorem miura_flipGraph_degree (m n : ℕ) (f : V m n → Bool) :
    (flipGraph (V m n)).degree f = (m + 1) * (n + 1) := by
  convert flipGraph_degree f;
  simp +decide [ V ]

end MiuraFlip