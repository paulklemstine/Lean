import Mathlib

/-!
# Hamilton covers, incidence codes, and punctured linear systems

This file isolates two deterministic mechanisms behind efficient Hamilton covers.
A family of two-regular spanning layers is simultaneously:

* a constant-column-weight incidence code, which forces the maximum-degree lower bound; and
* after deleting one distinguished edge per layer, a family of punctured layers covering every
  edge except a small transversal.  When the layers are Hamilton cycles, these punctured layers
  are Hamilton paths and hence linear forests.

The theorem is deliberately stated for an arbitrary finite edge type and incidence relation.  It
therefore applies to simple graphs, multigraphs, and auxiliary graph systems without changing the
counting argument.
-/

namespace HamiltonCoverBridge

variable {V E I : Type*} [DecidableEq E]

/-- Number of edges in `F` incident with `v`. -/
def incidenceDegree (incident : E → V → Prop) [DecidableRel incident]
    (F : Finset E) (v : V) : ℕ :=
  (F.filter fun e => incident e v).card

/-- A layer is two-regular at every vertex (the local property of a Hamilton cycle). -/
def TwoRegular (incident : E → V → Prop) [DecidableRel incident]
    (C : Finset E) : Prop :=
  ∀ v, incidenceDegree incident C v = 2

/-- The layers cover the target edge set. -/
def Covers (target : Finset E) (layer : I → Finset E) : Prop :=
  ∀ e ∈ target, ∃ i, e ∈ layer i

/-- Delete one distinguished edge from every layer. -/
def puncture (layer : I → Finset E) (chosen : I → E) (i : I) : Finset E :=
  (layer i).erase (chosen i)

/-- The incidence code at a vertex: layer `i` contributes the incident edges in that layer. -/
def incidenceCode (incident : E → V → Prop) [DecidableRel incident]
    (layer : I → Finset E) (v : V) (i : I) : Finset E :=
  (layer i).filter fun e => incident e v

/-
A covered degree is bounded by the total Hamming weight of its incidence-code blocks.
-/
theorem degree_le_code_weight [Fintype I] [DecidableEq I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (layer : I → Finset E)
    (hcover : Covers target layer) (v : V) :
    incidenceDegree incident target v ≤
      ∑ i : I, (incidenceCode incident layer v i).card := by
  -- Each edge in the target set that is incident to $v$ is included in at least one of the incidence codes.
  have h_inclusion : target.filter (fun e => incident e v) ⊆ Finset.biUnion Finset.univ (fun i => (layer i).filter (fun e => incident e v)) := by
    intro e he; specialize hcover e; aesop;
  exact le_trans ( Finset.card_le_card h_inclusion ) ( Finset.card_biUnion_le )

/-
**Coding-theoretic lower bound for Hamilton covers.**
Every block of the incidence code of a two-regular layer has weight two.  Consequently a cover
of `d` edges incident with a vertex requires at least `⌈d/2⌉` layers.
-/
theorem ceil_half_degree_le_number_of_layers [Fintype I] [DecidableEq I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (layer : I → Finset E)
    (hcover : Covers target layer)
    (hregular : ∀ i, TwoRegular incident (layer i)) (v : V) :
    (incidenceDegree incident target v + 1) / 2 ≤ Fintype.card I := by
  have h_card : ∀ i, (incidenceCode incident layer v i).card = 2 := by
    exact fun i => hregular i v;
  exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by linarith [ show ( incidenceDegree incident target v ) ≤ ∑ i : I, ( incidenceCode incident layer v i |> Finset.card ) from degree_le_code_weight incident target layer hcover v, show ∑ i : I, ( incidenceCode incident layer v i |> Finset.card ) = 2 * Fintype.card I from by rw [ Finset.sum_congr rfl fun _ _ => h_card _ ] ; simp +decide [ mul_comm ] ] )

/-
Puncturing one edge in every layer loses no target edge outside the chosen transversal.
-/
theorem punctured_layers_cover_off_transversal [Fintype I] [DecidableEq I]
    (target : Finset E) (layer : I → Finset E) (chosen : I → E)
    (hcover : Covers target layer) :
    ∀ e ∈ target, e ∉ Finset.univ.image chosen →
      ∃ i, e ∈ puncture layer chosen i := by
  simp +zetaDelta at *;
  exact fun e he hne => by obtain ⟨ i, hi ⟩ := hcover e he; exact ⟨ i, Finset.mem_erase_of_ne_of_mem ( Ne.symm ( hne i ) ) hi ⟩ ;

/-
**Connector theorem.** A two-regular edge cover gives at once
(1) the sharp degree/2 obstruction, viewed as a Hamming-weight bound, and
(2) a punctured cover outside a transversal of at most one edge per layer.

For Hamilton-cycle layers, the punctured objects are Hamilton paths, so conclusion (2) is exactly
the deterministic bridge from Hamilton covers to linear-forest covers used in linear arboricity.
-/
theorem hamilton_cover_code_and_linear_system [Fintype I] [DecidableEq I]
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (layer : I → Finset E) (chosen : I → E)
    (hcover : Covers target layer)
    (hregular : ∀ i, TwoRegular incident (layer i)) (v : V) :
    (incidenceDegree incident target v + 1) / 2 ≤ Fintype.card I ∧
      (∀ e ∈ target, e ∉ Finset.univ.image chosen →
        ∃ i, e ∈ puncture layer chosen i) := by
  exact ⟨ ceil_half_degree_le_number_of_layers incident target layer hcover hregular v, punctured_layers_cover_off_transversal target layer chosen hcover ⟩

end HamiltonCoverBridge