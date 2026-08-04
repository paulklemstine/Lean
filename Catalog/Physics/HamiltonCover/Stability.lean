import Mathlib

/-!
# Exact local stability for near-optimal two-regular covers

This file advances the deterministic part of the optimal-Hamilton-cover program.
The proposed `2k + 1` stability bound is valid, but it has a sharper parity-sensitive
form: at a vertex of maximum target degree, a cover with `⌈Δ/2⌉ + k` two-regular
layers has exactly `2k + (Δ % 2)` repeated incidences.

The formulation uses finite edge sets and an arbitrary incidence relation, so it
applies without choosing a particular representation of graph edges.  Repeated
multiplicity is defined as the sum of layer-incidence cardinalities minus their
union cardinality.  The cover and containment assumptions identify that union
with the target incidences.
-/

namespace HamiltonCoverStability

variable {V E : Type*} [DecidableEq E]

/-- Edges of `F` incident with `v`. -/
def incidentEdges (incident : E → V → Prop) [DecidableRel incident]
    (F : Finset E) (v : V) : Finset E :=
  F.filter fun e => incident e v

/-- Degree in a finite edge set with respect to an incidence relation. -/
def incidenceDegree (incident : E → V → Prop) [DecidableRel incident]
    (F : Finset E) (v : V) : ℕ :=
  (incidentEdges incident F v).card

/-- Total multiplicity beyond first occurrence among the layer incidences at `v`. -/
def repeatedIncidence (incident : E → V → Prop) [DecidableRel incident]
    {m : ℕ} (layer : Fin m → Finset E) (v : V) : ℕ :=
  (∑ i, incidenceDegree incident (layer i) v) -
    (Finset.univ.biUnion (fun i => incidentEdges incident (layer i) v)).card

/-- If contained layers cover the target, their incidence blocks have exactly the
same union as the target's incidence set. -/
theorem incidence_union_eq_target
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) {m : ℕ} (layer : Fin m → Finset E)
    (hcontained : ∀ i, layer i ⊆ target)
    (hcover : ∀ e ∈ target, ∃ i, e ∈ layer i) (v : V) :
    Finset.univ.biUnion (fun i => incidentEdges incident (layer i) v) =
      incidentEdges incident target v := by
  ext e
  constructor
  · simp only [Finset.mem_biUnion, Finset.mem_univ, true_and, incidentEdges,
      Finset.mem_filter]
    rintro ⟨i, hei, hev⟩
    exact ⟨hcontained i hei, hev⟩
  · simp only [incidentEdges, Finset.mem_filter, Finset.mem_biUnion,
      Finset.mem_univ, true_and]
    rintro ⟨het, hev⟩
    obtain ⟨i, hei⟩ := hcover e het
    exact ⟨i, hei, hev⟩

/-- **Exact parity-sensitive local stability law.**
At a vertex of target degree `Δ`, a genuine edge cover by `⌈Δ/2⌉ + k`
two-regular layers has exactly `2k + (Δ mod 2)` repeated incidences. -/
theorem repeated_incidence_exact
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V) (Δ k : ℕ)
    (layer : Fin ((Δ + 1) / 2 + k) → Finset E)
    (hcontained : ∀ i, layer i ⊆ target)
    (hcover : ∀ e ∈ target, ∃ i, e ∈ layer i)
    (hdegree : incidenceDegree incident target v = Δ)
    (htwo : ∀ i, incidenceDegree incident (layer i) v = 2) :
    repeatedIncidence incident layer v = 2 * k + Δ % 2 := by
  rw [repeatedIncidence,
    incidence_union_eq_target incident target layer hcontained hcover v]
  change (∑ i, incidenceDegree incident (layer i) v) -
      incidenceDegree incident target v = 2 * k + Δ % 2
  simp_rw [htwo]
  rw [hdegree]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin,
    Nat.nsmul_eq_mul]
  omega

/-- The local part of the proposed near-optimal-cover stability conjecture:
repeated multiplicity at every maximum-degree vertex is at most `2k + 1`.
The exact theorem above shows when the final unit is present. -/
theorem repeated_incidence_le_two_mul_excess_add_one
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V) (Δ k : ℕ)
    (layer : Fin ((Δ + 1) / 2 + k) → Finset E)
    (hcontained : ∀ i, layer i ⊆ target)
    (hcover : ∀ e ∈ target, ∃ i, e ∈ layer i)
    (hdegree : incidenceDegree incident target v = Δ)
    (htwo : ∀ i, incidenceDegree incident (layer i) v = 2) :
    repeatedIncidence incident layer v ≤ 2 * k + 1 := by
  rw [repeated_incidence_exact incident target v Δ k layer hcontained hcover hdegree htwo]
  omega

/-- In the even-degree case the conjectured `+1` can be removed. -/
theorem repeated_incidence_even_degree
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V) (Δ k : ℕ)
    (layer : Fin ((Δ + 1) / 2 + k) → Finset E)
    (hcontained : ∀ i, layer i ⊆ target)
    (hcover : ∀ e ∈ target, ∃ i, e ∈ layer i)
    (hdegree : incidenceDegree incident target v = Δ)
    (htwo : ∀ i, incidenceDegree incident (layer i) v = 2)
    (heven : Even Δ) :
    repeatedIncidence incident layer v = 2 * k := by
  rw [repeated_incidence_exact incident target v Δ k layer hcontained hcover hdegree htwo]
  have hmod : Δ % 2 = 0 := Nat.even_iff.mp heven
  omega

/-- In the odd-degree case the upper bound is attained exactly. -/
theorem repeated_incidence_odd_degree
    (incident : E → V → Prop) [DecidableRel incident]
    (target : Finset E) (v : V) (Δ k : ℕ)
    (layer : Fin ((Δ + 1) / 2 + k) → Finset E)
    (hcontained : ∀ i, layer i ⊆ target)
    (hcover : ∀ e ∈ target, ∃ i, e ∈ layer i)
    (hdegree : incidenceDegree incident target v = Δ)
    (htwo : ∀ i, incidenceDegree incident (layer i) v = 2)
    (hodd : Odd Δ) :
    repeatedIncidence incident layer v = 2 * k + 1 := by
  rw [repeated_incidence_exact incident target v Δ k layer hcontained hcover hdegree htwo]
  obtain ⟨a, rfl⟩ := hodd
  omega

end HamiltonCoverStability