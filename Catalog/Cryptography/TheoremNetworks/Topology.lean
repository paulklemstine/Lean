import Catalog.Shared.RamseyTheory.TheoremNetworkTopology

/-!
# Topological limits for theorem co-citation networks

A theorem network is modeled by a finite corpus of co-citation sets.  Its simplices are
precisely the finite theorem sets contained in a common corpus entry.  This file derives
two consequences for topological data analysis: pairwise projection can fill a genuine
one-dimensional hole, and no positive polynomial lower law for Betti numbers can hold
uniformly across homological dimensions.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer), ranked by expected impact: (1) time-localized second-homology
classes predict independently labeled conceptual reorganizations; (2) sparse random
co-citation hypergraphs have universal normalized persistence diagrams; (3) cryptographic
proof corpora exhibit persistent cycles around interchangeable hardness assumptions;
(4) pairwise co-citation reconstructs higher-order citation data exactly under
conformality; (5) adding one sufficiently broad citation record can fill a pairwise
triangle without changing its one-skeleton; (6) a dimension-uniform positive law
`β_k ≳ n^(k+1)` is impossible for finite corpora.  The first three are bold empirical
conjectures; the last three are structural and falsifiable.

Experiment (Experimenter): the three-theorem corpus consisting of all three pairs was
compared with the corpus obtained by adding the triple.  The one-skeleton is complete
before the triple is added, but the two-simplex is absent.  The universal growth claim
was tested at the boundary dimension `k = n`, where no `(k+1)`-vertex face can exist.

Analysis (Analyst): conjectures (4)--(6) survive.  The pairwise graph forgets whether one
source jointly cited all three theorems.  Adding the triple changes the higher complex
while leaving an already-complete pairwise graph unchanged.  Finite vertex support also
forces every rank-presented Betti number to vanish in dimensions at least the vertex
count, contradicting every positive dimension-uniform lower power law.

Critique (Critic): a cycle is not, by itself, evidence of a school of mathematics, and a
filled two-simplex is not, by itself, a paradigm shift.  Those interpretations require
external labels and temporal validation.  The rank-only Betti presentation assumes the
usual boundary-rank interpretation; the conclusions here use only its unavoidable chain
dimension ceiling.  No asymptotic claim for a fixed dimension is refuted.

Synthesis (Principal Investigator): the verified boundary separates higher-order
co-citation from its pairwise shadow and replaces the proposed unqualified growth law by
a binomial upper bound with finite-dimensional vanishing.  A broader extension should
combine this structural layer with labeled temporal corpora and null models.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Classical Finset
open TheoremNetworkTopology

namespace TheoremNetworkTDA

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- Exact dimension-uniform power growth for a rank-presented Betti profile. -/
def ExactPowerLaw (C : Corpus V) (boundaryRank : ℕ → ℕ) : Prop :=
  ∀ k, bettiFromRanks C boundaryRank k = (Fintype.card V) ^ (k + 1)

/-- A positive constant-factor lower power law, required in every dimension. -/
def UniformPowerLowerLaw (C : Corpus V) (boundaryRank : ℕ → ℕ) : Prop :=
  ∃ a : ℕ, 0 < a ∧
    ∀ k, (Fintype.card V) ^ (k + 1) ≤ a * bettiFromRanks C boundaryRank k

/-
No nonempty finite theorem corpus has the proposed exact power law simultaneously
in every homological dimension.
-/
theorem no_exactPowerLaw [Nonempty V] (C : Corpus V) (boundaryRank : ℕ → ℕ) :
    ¬ ExactPowerLaw C boundaryRank := by
  intro h
  have h_at_top := h (Fintype.card V)
  exact (bettiFromRanks_ne_power_of_card_le C boundaryRank le_rfl) h_at_top

/-
Even allowing an arbitrary positive multiplicative constant cannot produce a
positive lower power law uniformly across all dimensions.
-/
theorem no_uniformPowerLowerLaw [Nonempty V]
    (C : Corpus V) (boundaryRank : ℕ → ℕ) :
    ¬ UniformPowerLowerLaw C boundaryRank := by
  intro h
  obtain ⟨a, _ha_pos, ha⟩ := h
  have h_contra := ha (Fintype.card V)
  rw [bettiFromRanks_eq_zero_of_card_le C boundaryRank le_rfl] at h_contra
  have hcard : 0 < Fintype.card V := Fintype.card_pos
  have hpow : 0 < (Fintype.card V) ^ (Fintype.card V + 1) := pow_pos hcard _
  omega

/-- Adding the joint triple citation to the triangle-boundary corpus. -/
def filledTriangleCorpus : Corpus (Fin 3) :=
  insert Finset.univ triangleBoundaryCorpus

/-
Corpus growth from pairwise records to a joint triple record is strict at the level
of simplicial complexes: the new record fills the missing two-simplex.
-/
theorem triangle_filling_strict :
    coCitationComplex triangleBoundaryCorpus ⊂
      coCitationComplex filledTriangleCorpus := by
  refine Finset.ssubset_iff_subset_ne.mpr ⟨?_, ?_⟩
  · apply coCitationComplex_mono
    intro W hW
    exact Finset.mem_insert_of_mem hW
  · intro heq
    apply univ_notMem_triangleBoundary
    rw [heq]
    apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_powerset.mpr (Finset.subset_univ _), ?_⟩
    exact ⟨Finset.univ, Finset.mem_insert_self _ _, Finset.Subset.rfl⟩

/-
The same update is invisible to the pairwise graph: both one-skeleta are complete.
-/
theorem triangle_filling_pairwise_invisible :
    coCitationGraph filledTriangleCorpus = coCitationGraph triangleBoundaryCorpus := by
  rw [coCitationGraph_triangleBoundary]
  ext x y
  constructor
  · rintro ⟨hxy, _W, _hW, _hx, _hy⟩
    exact hxy
  · intro hxy
    exact ⟨hxy, Finset.univ, Finset.mem_insert_self _ _,
      Finset.mem_univ x, Finset.mem_univ y⟩

/-
A filtered corpus gives persistent face inclusion between any two ordered times.
-/
theorem face_persists_in_filtered_corpus {ι : Type*} [Preorder ι]
    (C : ι → Corpus V) (hC : Monotone C) {s t : ι} (hst : s ≤ t)
    {S : Finset V} (hS : S ∈ coCitationComplex (C s)) :
    S ∈ coCitationComplex (C t) := by
  convert coCitationComplex_mono ( hC hst ) hS using 1

#check @no_uniformPowerLowerLaw
#check @triangle_filling_strict

example :
    (Finset.univ : Finset (Fin 3)) ∉ coCitationComplex triangleBoundaryCorpus ∧
    (Finset.univ : Finset (Fin 3)) ∈ coCitationComplex filledTriangleCorpus := by
  constructor
  · exact univ_notMem_triangleBoundary
  · apply Finset.mem_filter.mpr
    refine ⟨Finset.mem_powerset.mpr (Finset.subset_univ _), ?_⟩
    exact ⟨Finset.univ, Finset.mem_insert_self _ _, Finset.Subset.rfl⟩

end TheoremNetworkTDA