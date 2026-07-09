/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# The Mathematics of Memes: Viral Information Topology

This file develops a small, self-contained theory of **cellular sheaf cohomology on a
finite graph**, specialised to the *constant sheaf*, and connects it to the "meme
propagation" narrative of the research mission.

## The model

A **social network** is a finite directed graph: a finite vertex type `V` (the people),
a finite edge type `E` (the communication channels), together with two endpoint maps
`src tgt : E → V`.

A **meme** is modelled as the constant sheaf `K` (a field of possible interpretations)
placed on every vertex, with the identity restriction map on every edge.  A *0-cochain*
`f : V → K` assigns an interpretation to each person; a *1-cochain* `g : E → K` records a
discrepancy along each channel.  The **coboundary** operator

  `(δ f) e = f (tgt e) - f (src e)`

measures the failure of `f` to be consistent across a channel.

* `H⁰ = ker δ` is the space of **globally consistent interpretations** (sections of the
  sheaf).  Its dimension counts the number of *distinct interpretations* a meme can carry
  while remaining consistent — one per connected community.
* `H¹ = coker δ = (E → K) / range δ` is the space of **consistency obstructions**.  Its
  dimension counts the *interpretation steps* needed to cross between communities; it is
  the first Betti number (number of independent communication cycles).

## Main results (a dependency chain)

* `MemeSheaf.coboundary_const` — constant interpretations are always consistent.
* `MemeSheaf.finrank_range_add_finrank_H0` — rank–nullity for the coboundary.
* `MemeSheaf.finrank_H1` — dimension of the obstruction space.
* `MemeSheaf.euler_characteristic` — **`dim H⁰ − dim H¹ = |people| − |channels|`**.
* `MemeSheaf.finrank_H0_of_edgeless` — with no channels, every person is their own
  interpretation: `dim H⁰ = |people|` (maximal), `dim H¹ = 0`.
* `MemeSheaf.finrank_H0_of_connected` — a connected network carries exactly **one**
  interpretation: `dim H⁰ = 1`.
* `MemeSheaf.betti_one_of_connected` — for a connected network,
  `dim H¹ = |channels| − |people| + 1`, the number of independent cycles.
-/

namespace MemeSheaf

open Module

variable {K : Type*} [Field K]
variable {V E : Type*} [Fintype V] [Fintype E] [DecidableEq V]

/-! ## The coboundary operator -/

/-- The **coboundary** (discrete gradient) of the constant sheaf on a finite directed
graph with endpoint maps `src tgt : E → V`.  It sends a 0-cochain `f : V → K` to the
1-cochain measuring the discrepancy `f (tgt e) - f (src e)` along each edge `e`. -/
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

/-
A meme that means the *same* thing to everyone is globally consistent: the coboundary
of a constant 0-cochain vanishes.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem coboundary_const (src tgt : E → V) (c : K) :
    coboundary (K := K) src tgt (fun _ => c) = 0 := by
  exact funext fun x => sub_self c

/-
Constant interpretations lie in `H⁰`.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem const_mem_H0 (src tgt : E → V) (c : K) :
    (fun _ => c) ∈ H0 (K := K) src tgt := by
  exact coboundary_const src tgt c

/-
Membership in `H⁰` means exactly consistency across every channel.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem mem_H0_iff (src tgt : E → V) (f : V → K) :
    f ∈ H0 (K := K) src tgt ↔ ∀ e : E, f (src e) = f (tgt e) := by
  unfold H0;
  simp +decide [ funext_iff, coboundary ];
  grind

/-! ## Rank–nullity and the Euler characteristic -/

/-
**Rank–nullity for the coboundary.**  The dimension of the image plus the dimension of
`H⁰` equals the number of people.
-/
omit [Fintype E] [DecidableEq V] in
theorem finrank_range_add_finrank_H0 (src tgt : E → V) :
    finrank K (LinearMap.range (coboundary (K := K) src tgt))
      + finrank K (H0 (K := K) src tgt) = Fintype.card V := by
  convert LinearMap.finrank_range_add_finrank_ker (coboundary (K := K) src tgt) using 1
  simp

/-
**Dimension of the obstruction space.**  `dim H¹ = |channels| − dim (range δ)`.
-/
omit [Fintype V] [DecidableEq V] in
theorem finrank_H1 (src tgt : E → V) :
    finrank K (H1 (K := K) src tgt)
      + finrank K (LinearMap.range (coboundary (K := K) src tgt)) = Fintype.card E := by
  convert Submodule.finrank_quotient_add_finrank (LinearMap.range (coboundary (K := K) src tgt)) using 1
  simp

/-
**Euler characteristic / meme balance law.**  The number of distinct interpretations
minus the number of obstructions equals the number of people minus the number of channels:

  `dim H⁰ − dim H¹ = |people| − |channels|`.

This is the graph Euler characteristic, and it is a *topological invariant* of the social
network, independent of how the meme is interpreted.
-/
omit [DecidableEq V] in
theorem euler_characteristic (src tgt : E → V) :
    (finrank K (H0 (K := K) src tgt) : ℤ) - finrank K (H1 (K := K) src tgt)
      = (Fintype.card V : ℤ) - Fintype.card E := by
  have h1 := finrank_range_add_finrank_H0 ( K := K ) src tgt
  have h2 := finrank_H1 ( K := K ) src tgt;
  grind

/-! ## The edgeless network: maximal interpretation -/

/-
**A network with no channels has maximally many interpretations.**  With no
communication channels, every person is free to interpret the meme independently, so
`dim H⁰ = |people|`, which is the largest it can ever be.
-/
omit [Fintype E] [DecidableEq V] in
theorem finrank_H0_of_edgeless (src tgt : E → V) (hE : IsEmpty E) :
    finrank K (H0 (K := K) src tgt) = Fintype.card V := by
  convert finrank_range_add_finrank_H0 src tgt using 1;
  rw [ show ( coboundary ( K := K ) src tgt ).range = ⊥ by exact eq_bot_iff.mpr fun x hx => by obtain ⟨ y, rfl ⟩ := hx; exact by ext e; exact hE.elim e ] ; simp +decide

/-
With no channels there are no obstructions: `dim H¹ = 0`.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem finrank_H1_of_edgeless (src tgt : E → V) (hE : IsEmpty E) :
    finrank K (H1 (K := K) src tgt) = 0 := by
  unfold H1
  exact finrank_zero_of_subsingleton

/-! ## Connectivity: a single community carries a single interpretation -/

/-- Two people are **adjacent** if some communication channel joins them (in either
direction). -/
def Adj (src tgt : E → V) (u v : V) : Prop :=
  ∃ e : E, (src e = u ∧ tgt e = v) ∨ (src e = v ∧ tgt e = u)

/-- The network is **connected** when any two people are joined by a chain of channels. -/
def Connected (src tgt : E → V) : Prop :=
  ∀ u v : V, Relation.ReflTransGen (Adj src tgt) u v

/-
A consistent interpretation takes equal values on adjacent people.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem H0_eq_of_adj (src tgt : E → V) {f : V → K} (hf : f ∈ H0 (K := K) src tgt)
    {u v : V} (h : Adj src tgt u v) : f u = f v := by
  rw [ mem_H0_iff ] at hf; obtain ⟨ e, he ⟩ := h; cases he <;> aesop;

/-
A consistent interpretation takes equal values on connected people.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem H0_eq_of_reachable (src tgt : E → V) {f : V → K} (hf : f ∈ H0 (K := K) src tgt)
    {u v : V} (h : Relation.ReflTransGen (Adj src tgt) u v) : f u = f v := by
  induction h;
  · rfl;
  · rw [ ‹f u = f _›, H0_eq_of_adj src tgt hf ‹_› ]

/-
**In a connected network every consistent interpretation is constant.**
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem H0_const_of_connected (src tgt : E → V) (hc : Connected src tgt)
    {f : V → K} (hf : f ∈ H0 (K := K) src tgt) (u v : V) : f u = f v := by
  convert H0_eq_of_reachable src tgt hf ( hc u v ) using 1

/-- The constant-interpretation embedding `K → (V → K)`. -/
def constHom : K →ₗ[K] (V → K) where
  toFun c := fun _ => c
  map_add' a b := by funext v; simp
  map_smul' a b := by funext v; simp

omit [Fintype V] [DecidableEq V] in
theorem constHom_injective [Nonempty V] : Function.Injective (constHom (K := K) (V := V)) := by
  intro a b h; apply congrFun h (Classical.arbitrary V);

/-
In a connected network, `H⁰` is exactly the line of constant interpretations.
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem H0_eq_range_constHom_of_connected [Nonempty V] (src tgt : E → V)
    (hc : Connected src tgt) :
    H0 (K := K) src tgt = LinearMap.range (constHom (K := K) (V := V)) := by
  ext f;
  constructor <;> intro hf;
  · exact ⟨ f ( Classical.arbitrary V ), funext fun v => H0_const_of_connected src tgt hc hf v ( Classical.arbitrary V ) ▸ rfl ⟩;
  · obtain ⟨ c, rfl ⟩ := hf; exact const_mem_H0 src tgt c;

/-
**A connected network carries exactly one interpretation:** `dim H⁰ = 1`.
This is the meme that "means the same thing to everyone".
-/
omit [Fintype V] [Fintype E] [DecidableEq V] in
theorem finrank_H0_of_connected [Nonempty V] (src tgt : E → V) (hc : Connected src tgt) :
    finrank K (H0 (K := K) src tgt) = 1 := by
  rw [ H0_eq_range_constHom_of_connected src tgt hc ];
  convert LinearMap.finrank_range_of_inj ( constHom_injective : Function.Injective ( constHom ( K := K ) ( V := V ) ) );
  simp +decide

/-
**First Betti number of a connected network.**  Combining the Euler characteristic with
`dim H⁰ = 1`, the number of consistency obstructions of a connected meme network is exactly
the number of independent communication cycles:

  `dim H¹ = |channels| − |people| + 1`.
-/
omit [DecidableEq V] in
theorem betti_one_of_connected [Nonempty V] (src tgt : E → V) (hc : Connected src tgt) :
    (finrank K (H1 (K := K) src tgt) : ℤ) = (Fintype.card E : ℤ) - Fintype.card V + 1 := by
  have he := euler_characteristic ( K := K ) src tgt; have h0 := finrank_H0_of_connected ( K := K ) src tgt hc; rw [ h0 ] at he; omega;

end MemeSheaf