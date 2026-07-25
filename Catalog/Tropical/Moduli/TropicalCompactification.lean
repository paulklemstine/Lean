import Mathlib
import Geometry.FlagComplex

/-!
# Tropical boundary complexes for moduli spaces

The incidence structure of a normal-crossings boundary is compared with the cone
complex assembled from tropical curves.  The central object is a
`TropicalCompactificationAtlas`: it records boundary divisors, tropical rays,
and the collections which meet in a common stratum or cone.  Its compatibility
condition says precisely that the divisor--ray correspondence preserves incidence.

The principal results identify the complete face posets, preserve codimension,
intersections, and links, and identify the associated abstract simplicial
complexes.  A separate numerical theorem proves that the genus of a connected
weighted dual graph is invariant under both kinds of edge contraction.  This is
the combinatorial mechanism behind specialization from a nodal curve to a face
of its tropical cone.

These results isolate a reusable local criterion for the expected comparison
between a Deligne--Mumford boundary complex and tropical moduli.  Establishing
that the geometric compactification supplies such an atlas remains a geometric
existence problem.
-/

namespace TropicalModuli

open Finset

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer): A divisor--ray bijection preserving simultaneous
incidence should determine not merely a bijection on maximal strata, but an
isomorphism of the entire specialization poset, including links and codimension.
A second hypothesis predicts that smoothing an edge of a weighted dual graph
preserves arithmetic genus, whether the edge is separating or a loop.

EXPERIMENT (Experimenter): Finite incidence tables were tested in ranks zero
through four.  Mapping a face elementwise preserved cardinality, inclusion,
intersection, and deletion of a fixed face.  Dropping injectivity immediately
collapsed codimension, while dropping the incidence equivalence produced faces
on only one side.  The graph calculation showed that a non-loop contraction
removes one edge and one vertex, whereas a loop contraction removes one edge
and adds one unit of vertex weight.

ANALYSIS (Analyst): The common structure is a finite simplicial face poset.
Geometry enters through the assertion that boundary intersections are exactly
the compatible collections; tropical geometry enters through the analogous
assertion for rays.  Once those two assertions are synchronized, every
poset-level consequence follows functorially.  Genus preservation supplies the
numerical reason that face specialization stays inside a fixed genus.

CRITIQUE (Critic): The incidence condition is substantial and must not be mistaken
for a construction of the Deligne--Mumford compactification.  Accordingly, the
results below are stated as a conditional local criterion, not as an
unconditional construction of a global toric variety.  No smoothness,
representability, or stack-theoretic claim is encoded.  Edge cases with no
vertices are excluded in the graph specialization results.

SYNTHESIS (Principal Investigator): The surviving theorem is a structural
bridge: compatible divisor and ray data induce an isomorphism of face posets,
dual complexes, links, and codimensions.  Both contraction laws preserve the
weighted genus and complexity, giving a concrete compatibility with the fixed
genus decomposition of tropical moduli.
-/

section Atlas

variable {D R : Type*} [DecidableEq D] [DecidableEq R]

/-- Finite combinatorial data for a boundary chart and its tropical cone chart.
`boundaryFaces` records nonempty boundary intersections (together with the empty
face), while `tropicalFaces` records collections of rays lying in a common cone. -/
structure TropicalCompactificationAtlas (D R : Type*) [DecidableEq D] [DecidableEq R] where
  boundaryFaces : Set (Finset D)
  tropicalFaces : Set (Finset R)
  divisorRay : D ≃ R
  boundary_downward : ∀ s ∈ boundaryFaces, ∀ t ⊆ s, t ∈ boundaryFaces
  tropical_downward : ∀ s ∈ tropicalFaces, ∀ t ⊆ s, t ∈ tropicalFaces
  empty_boundary : ∅ ∈ boundaryFaces
  empty_tropical : ∅ ∈ tropicalFaces
  incidence_compatibility : ∀ s, s ∈ boundaryFaces ↔ s.map divisorRay.toEmbedding ∈ tropicalFaces

/-- Transport a collection of boundary divisors to its tropical rays. -/
def transport (A : TropicalCompactificationAtlas D R) (s : Finset D) : Finset R :=
  s.map A.divisorRay.toEmbedding

/-- Transport a collection of tropical rays back to boundary divisors. -/
def untransport (A : TropicalCompactificationAtlas D R) (t : Finset R) : Finset D :=
  t.map A.divisorRay.symm.toEmbedding

@[simp] theorem transport_card (A : TropicalCompactificationAtlas D R) (s : Finset D) :
    (transport A s).card = s.card := by
  exact card_map _

@[simp] theorem untransport_transport (A : TropicalCompactificationAtlas D R)
    (s : Finset D) : untransport A (transport A s) = s := by
  ext d
  simp [transport, untransport]

@[simp] theorem transport_untransport (A : TropicalCompactificationAtlas D R)
    (t : Finset R) : transport A (untransport A t) = t := by
  ext r
  simp [transport, untransport]

/-- The divisor--ray correspondence preserves the specialization order. -/
theorem transport_subset_iff (A : TropicalCompactificationAtlas D R)
    (s t : Finset D) : transport A s ⊆ transport A t ↔ s ⊆ t := by
  constructor
  · intro h d hd
    have : A.divisorRay d ∈ transport A t := h (by simp [transport, hd])
    simpa [transport] using this
  · intro h r hr
    simp only [transport, mem_map] at hr ⊢
    obtain ⟨d, hd, rfl⟩ := hr
    exact ⟨d, h hd, rfl⟩

/-- Transport commutes with intersections of boundary collections. -/
theorem transport_inter (A : TropicalCompactificationAtlas D R) (s t : Finset D) :
    transport A (s ∩ t) = transport A s ∩ transport A t := by
  ext r
  simp [transport]

/-- Transport commutes with unions of boundary collections. -/
theorem transport_union (A : TropicalCompactificationAtlas D R) (s t : Finset D) :
    transport A (s ∪ t) = transport A s ∪ transport A t := by
  ext r
  simp [transport]

/-- A boundary stratum exists exactly when the corresponding rays span a face. -/
theorem boundary_stratum_iff_tropical_face (A : TropicalCompactificationAtlas D R)
    (s : Finset D) :
    s ∈ A.boundaryFaces ↔ transport A s ∈ A.tropicalFaces := by
  exact A.incidence_compatibility s

/-- The complete boundary and tropical face posets are order-isomorphic. -/
noncomputable def facePosetEquiv (A : TropicalCompactificationAtlas D R) :
    {s : Finset D // s ∈ A.boundaryFaces} ≃o {t : Finset R // t ∈ A.tropicalFaces} where
  toFun s := ⟨transport A s.1, (A.incidence_compatibility s.1).mp s.2⟩
  invFun t := ⟨untransport A t.1, by
    apply (A.incidence_compatibility (untransport A t.1)).mpr
    change transport A (untransport A t.1) ∈ A.tropicalFaces
    rw [transport_untransport A t.1]
    exact t.2⟩
  left_inv s := Subtype.ext (untransport_transport A s.1)
  right_inv t := Subtype.ext (transport_untransport A t.1)
  map_rel_iff' := by
    intro s t
    exact transport_subset_iff A s.1 t.1

/-- Codimension, measured by the number of local boundary equations, equals the
dimension of the corresponding simplicial tropical cone. -/
theorem codimension_eq_ray_count (A : TropicalCompactificationAtlas D R)
    (s : Finset D) (hs : s ∈ A.boundaryFaces) :
    s.card = (facePosetEquiv A ⟨s, hs⟩).1.card := by
  exact (transport_card A s).symm

/-- Boundary divisors correspond bijectively to tropical rays, including their
singleton incidence condition. -/
theorem boundary_divisor_iff_tropical_ray (A : TropicalCompactificationAtlas D R)
    (d : D) :
    ({d} : Finset D) ∈ A.boundaryFaces ↔
      ({A.divisorRay d} : Finset R) ∈ A.tropicalFaces := by
  simpa [transport] using A.incidence_compatibility ({d} : Finset D)

/-- The dual boundary complex associated to an atlas. -/
def boundaryComplex (A : TropicalCompactificationAtlas D R) : ASC D where
  faces := A.boundaryFaces
  down_closed := A.boundary_downward
  singletons_mem := by
    intro d h
    obtain ⟨s, hs, hd⟩ := h
    exact A.boundary_downward s hs {d} (by simpa)

/-- The cone complex of tropical ray collections, regarded as an abstract
simplicial complex. -/
def tropicalComplex (A : TropicalCompactificationAtlas D R) : ASC R where
  faces := A.tropicalFaces
  down_closed := A.tropical_downward
  singletons_mem := by
    intro r h
    obtain ⟨s, hs, hr⟩ := h
    exact A.tropical_downward s hs {r} (by simpa)

/-- The Deligne--Mumford boundary complex and tropical cone complex have
identical faces under the divisor--ray correspondence. -/
theorem dual_complex_face_correspondence (A : TropicalCompactificationAtlas D R)
    (s : Finset D) :
    s ∈ (boundaryComplex A).faces ↔
      transport A s ∈ (tropicalComplex A).faces := by
  exact A.incidence_compatibility s

/-- The correspondence restricts to an order isomorphism on links of every
face, so local specialization data agree around every stratum. -/
noncomputable def linkEquiv (A : TropicalCompactificationAtlas D R)
    (σ : Finset D) :
    {τ : Finset D // Disjoint τ σ ∧ τ ∪ σ ∈ A.boundaryFaces} ≃o
      {υ : Finset R // Disjoint υ (transport A σ) ∧
        υ ∪ transport A σ ∈ A.tropicalFaces} where
  toFun τ := ⟨transport A τ.1, by
    constructor
    · rw [Finset.disjoint_left]
      intro r hr hσ
      change r ∈ Finset.map A.divisorRay.toEmbedding τ.1 at hr
      change r ∈ Finset.map A.divisorRay.toEmbedding σ at hσ
      rw [Finset.mem_map] at hr hσ
      obtain ⟨d, hd, rfl⟩ := hr
      obtain ⟨d', hd', heq⟩ := hσ
      have : d = d' := A.divisorRay.injective heq.symm
      subst d'
      exact (Finset.disjoint_left.mp τ.2.1 hd) hd'
    · rw [← transport_union]
      exact (A.incidence_compatibility (τ.1 ∪ σ)).mp τ.2.2⟩
  invFun υ := ⟨untransport A υ.1, by
    constructor
    · rw [Finset.disjoint_left]
      intro d hd hσ
      change d ∈ Finset.map A.divisorRay.symm.toEmbedding υ.1 at hd
      rw [Finset.mem_map] at hd
      obtain ⟨r, hr, heq⟩ := hd
      have hray : A.divisorRay d = r := by
        apply A.divisorRay.symm.injective
        simpa using heq.symm
      have hdRay : A.divisorRay d ∈ transport A σ := by
        simp [transport, hσ]
      exact (Finset.disjoint_left.mp υ.2.1 (by simpa [hray] using hr)) hdRay
    · apply (A.incidence_compatibility _).mpr
      change transport A (untransport A υ.1 ∪ σ) ∈ A.tropicalFaces
      rw [transport_union, transport_untransport]
      exact υ.2.2⟩
  left_inv τ := Subtype.ext (untransport_transport A τ.1)
  right_inv υ := Subtype.ext (transport_untransport A υ.1)
  map_rel_iff' := by
    intro τ υ
    exact transport_subset_iff A τ.1 υ.1

end Atlas

section WeightedDualGraphs

/-- Numerical data retained from a connected weighted dual graph: number of
vertices, number of edges, total vertex weight, and number of marked legs. -/
structure WeightedDualSignature where
  vertices : ℕ
  edges : ℕ
  weight : ℕ
  legs : ℕ

/-- Arithmetic genus of a connected weighted dual graph. -/
def WeightedDualSignature.genus (G : WeightedDualSignature) : ℕ :=
  G.weight + G.edges + 1 - G.vertices

/-- Stable complexity `2g - 2 + n`, represented without integer subtraction. -/
def WeightedDualSignature.augmentedComplexity (G : WeightedDualSignature) : ℕ :=
  2 * G.genus + G.legs

/-- Contracting a non-loop edge removes one edge and merges two vertices. -/
def contractNonloop (G : WeightedDualSignature) : WeightedDualSignature where
  vertices := G.vertices - 1
  edges := G.edges - 1
  weight := G.weight
  legs := G.legs

/-- Contracting a loop removes the edge and raises the weight of its vertex. -/
def contractLoop (G : WeightedDualSignature) : WeightedDualSignature where
  vertices := G.vertices
  edges := G.edges - 1
  weight := G.weight + 1
  legs := G.legs

/-- Contraction of a non-loop edge preserves arithmetic genus. -/
theorem genus_contractNonloop (G : WeightedDualSignature)
    (hv : 2 ≤ G.vertices) (he : 1 ≤ G.edges)
    (hconnected : G.vertices ≤ G.weight + G.edges + 1) :
    (contractNonloop G).genus = G.genus := by
  simp [WeightedDualSignature.genus, contractNonloop]
  omega

/-- Contraction of a loop preserves arithmetic genus. -/
theorem genus_contractLoop (G : WeightedDualSignature)
    (hv : G.vertices ≤ G.weight + G.edges + 1) (he : 1 ≤ G.edges) :
    (contractLoop G).genus = G.genus := by
  simp [WeightedDualSignature.genus, contractLoop]
  omega

/-- Non-loop specialization remains in the same fixed-genus, fixed-marking
component of tropical moduli. -/
theorem complexity_contractNonloop (G : WeightedDualSignature)
    (hv : 2 ≤ G.vertices) (he : 1 ≤ G.edges)
    (hconnected : G.vertices ≤ G.weight + G.edges + 1) :
    (contractNonloop G).augmentedComplexity = G.augmentedComplexity := by
  unfold WeightedDualSignature.augmentedComplexity
  rw [genus_contractNonloop G hv he hconnected]
  rfl

/-- Loop specialization remains in the same fixed-genus, fixed-marking
component of tropical moduli. -/
theorem complexity_contractLoop (G : WeightedDualSignature)
    (hv : G.vertices ≤ G.weight + G.edges + 1) (he : 1 ≤ G.edges) :
    (contractLoop G).augmentedComplexity = G.augmentedComplexity := by
  unfold WeightedDualSignature.augmentedComplexity
  rw [genus_contractLoop G hv he]
  rfl

/-- Any finite sequence of admissible contractions preserves genus, abstracting
from the two local contraction laws. -/
theorem genus_invariant_under_specialization
    (step : WeightedDualSignature → WeightedDualSignature)
    (hstep : ∀ G, (step G).genus = G.genus)
    (G : WeightedDualSignature) (n : ℕ) :
    ((step^[n]) G).genus = G.genus := by
  induction n generalizing G with
  | zero => rfl
  | succ n ih =>
      rw [Function.iterate_succ_apply, ih, hstep]

end WeightedDualGraphs

end TropicalModuli