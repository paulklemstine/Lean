import Physics.SpectralLinkHomology.Core

/-!
# Cones are acyclic: vanishing reduced Euler characteristic

A **cone** over a complex `K` with a fresh apex `v` is the complex whose faces are
the faces of `K` together with their unions with `{v}`. Topologically a cone is
contractible, so it has trivial reduced homology. This file proves the elementary
*necessary* numerical consequence: the reduced Euler characteristic of a cone is
`0`.

This is the structural mechanism behind the spectral-radius rigidity statement:
saturating the bound `q_{r-1}(K) = t n - (t-1)(r+1)` forces the links of
`(r-t)`-faces to be cones, hence acyclic, hence with vanishing reduced homology.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For a cone, the apex pairs every face `F` (without the
apex) with `insert v F` (with the apex); these two faces have opposite-parity
cardinalities, so their contributions to the alternating face count cancel.
Experiment (Experimenter): define `cone v K`; the acyclicity proofs additionally
require the apex to be fresh (`hv : ∀ F ∈ K.faces, v ∉ F`). Split `reducedEuler`
over the disjoint union of "apex-free" and "apex-containing" faces; the second
sum is reindexed by `insert v`, injective on apex-free faces and shifting
cardinality by `1`.
Analysis (Analyst): the proof is a sign-reversing involution in disguise; the
freshness hypothesis is load-bearing (it makes `insert v` an injection raising the
cardinality by exactly one, and keeps the two pieces disjoint). Freshness is *not*
needed for `cone` to be a valid complex, so it is supplied separately.
Critique (Critic): the result is *necessary but not sufficient* for acyclicity —
the reduced Euler characteristic is only the alternating sum of Betti numbers.
We therefore label it honestly as the numerical shadow of trivial reduced
homology, not a full homology computation.
-/

namespace SpectralLinkHomology

open Finset

variable {V : Type*} [DecidableEq V]

/-- The cone over `K` with apex `v`: its faces are the faces of `K` together with
`insert v F` for each face `F`. (Apex freshness is *not* needed for this to be a
well-defined complex; it is supplied separately for the acyclicity results.) -/
def ASC.cone (v : V) (K : ASC V) : ASC V where
  faces := K.faces ∪ K.faces.image (insert v)
  empty_mem := mem_union_left _ K.empty_mem
  down_closed := by
    intro F G hF hGF
    rw [mem_union] at hF ⊢
    rcases hF with hF | hF
    · exact Or.inl (K.down_closed hF hGF)
    · rw [mem_image] at hF
      obtain ⟨F₀, hF₀, rfl⟩ := hF
      by_cases hvG : v ∈ G
      · -- `G` contains the apex: it is `insert v (G.erase v)`.
        right
        rw [mem_image]
        refine ⟨G.erase v, K.down_closed hF₀ ?_, ?_⟩
        · intro x hx
          rw [mem_erase] at hx
          have : x ∈ insert v F₀ := hGF hx.2
          rw [mem_insert] at this
          tauto
        · rw [insert_erase hvG]
      · -- `G` avoids the apex: it is a subset of `F₀`.
        left
        refine K.down_closed hF₀ ?_
        intro x hx
        have : x ∈ insert v F₀ := hGF hx
        rw [mem_insert] at this
        rcases this with h | h
        · exact absurd (h ▸ hx) hvG
        · exact h

/-- The apex-free faces and the apex-containing faces of a cone are disjoint. -/
theorem ASC.cone_faces_disjoint (v : V) (K : ASC V) (hv : ∀ F ∈ K.faces, v ∉ F) :
    Disjoint K.faces (K.faces.image (insert v)) := by
  rw [Finset.disjoint_left]
  intro F hF hF'
  rw [mem_image] at hF'
  obtain ⟨F₀, _, rfl⟩ := hF'
  exact hv _ hF (mem_insert_self v F₀)

/-- **Cones are acyclic (numerical shadow).** The reduced Euler characteristic of
a cone vanishes: the apex pairs faces of opposite cardinality parity. -/
theorem ASC.reducedEuler_cone (v : V) (K : ASC V) (hv : ∀ F ∈ K.faces, v ∉ F) :
    (ASC.cone v K).reducedEuler = 0 := by
  unfold ASC.reducedEuler ASC.cone
  rw [Finset.sum_union (ASC.cone_faces_disjoint v K hv)]
  rw [Finset.sum_image (by
    intro a ha b hb hab
    have hva : v ∉ a := hv _ ha
    have hvb : v ∉ b := hv _ hb
    have := congrArg (Finset.erase · v) hab
    simpa [Finset.erase_insert hva, Finset.erase_insert hvb] using this)]
  have hcard : ∀ F ∈ K.faces, ((-1 : ℤ)) ^ ((insert v F).card + 1)
      = - ((-1 : ℤ)) ^ (F.card + 1) := by
    intro F hF
    rw [Finset.card_insert_of_notMem (hv _ hF)]
    ring
  rw [Finset.sum_congr rfl hcard, Finset.sum_neg_distrib]
  ring

end SpectralLinkHomology