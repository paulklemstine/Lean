import Mathlib
import Logic.TopoErrorMitigation.PersistentH0
/-!
# Stability of finite persistent zero-dimensional homology

This chapter isolates the metric mechanism behind stability of Vietoris--Rips
persistence.  Distances are compared on a common finite correspondence.  With
the convention that a Rips edge appears at radius `r` when its length is at most
`2r`, distortion `δ` gives an interleaving shift `δ / 2`.

For finite diagrams of equal cardinality, bottleneck distance is defined as the
infimum over all bijective matchings.  A pointwise matching estimate therefore
gives a bottleneck estimate.  Combining these statements yields a stability
certificate for a zero-dimensional persistence diagram represented by the
edges of a certified spanning tree.  The final section evaluates the pipeline
on two concrete two-point clouds.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A correspondence whose pairwise distances differ by
  at most `δ` induces a `δ/2` interleaving of radius-parametrized Rips graphs,
  and the same factor controls every matched zero-dimensional death time.
Experiment (Experimenter): The edge predicate was transported in both
  directions, then finite diagrams were compared through an explicit matching.
  Two-point clouds at distances two and three give equality in the bound.
Analysis (Analyst): The factor one half is not an artefact: it comes exactly
  from the radius convention `d ≤ 2r`.  The topological monotonicity theorem for
  connected components then converts relation inclusion into monotonicity of
  the zeroth Betti number.
Critique (Critic): The diagram theorem is deliberately restricted to equal
  finite cardinalities and explicit edge certificates; unmatched points and
  diagonal multiplicities require a separate theory of partial matchings.  The
  result is therefore a rigorous finite stability core, not a claim covering
  arbitrary compact metric spaces or higher homological degrees.
Synthesis (Principal Investigator): Correspondence distortion, Rips
  interleaving, component monotonicity, finite bottleneck matching, and a sharp
  concrete cloud calculation form one reusable pipeline.
-/

namespace Geometry.PersistentHomology

open Set
open TopoErrorMitigation

/-- A symmetric uniform comparison of two distance tables on the same labels. -/
def DistortionBound {ι : Type*} (d e : ι → ι → ℝ) (δ : ℝ) : Prop :=
  ∀ i j, |d i j - e i j| ≤ δ

/-- Radius-parametrized Vietoris--Rips edge relation. -/
def RipsEdge {ι : Type*} (d : ι → ι → ℝ) (r : ℝ) (i j : ι) : Prop :=
  d i j ≤ 2 * r

/-- Uniform distortion transports every Rips edge after shifting radius by
`δ/2`. -/
theorem ripsEdge_mono_of_distortion {ι : Type*} {d e : ι → ι → ℝ} {δ r : ℝ}
    (hδ : DistortionBound d e δ) :
    ∀ i j, RipsEdge d r i j → RipsEdge e (r + δ / 2) i j := by
  intro i j h
  rw [RipsEdge] at h ⊢
  have := hδ i j
  linarith [abs_le.mp this]

/-- The reverse transport is available from the same absolute distortion
bound, giving the two directions of an interleaving. -/
theorem ripsEdge_interleaving {ι : Type*} {d e : ι → ι → ℝ} {δ r : ℝ}
    (hδ : DistortionBound d e δ) :
    (∀ i j, RipsEdge d r i j → RipsEdge e (r + δ / 2) i j) ∧
    (∀ i j, RipsEdge e r i j → RipsEdge d (r + δ / 2) i j) := by
  constructor
  · exact ripsEdge_mono_of_distortion hδ
  · apply ripsEdge_mono_of_distortion
    intro i j
    rw [abs_sub_comm]
    exact hδ i j

/-- Along either arm of the Rips interleaving, the number of connected
components cannot increase.  This connects metric distortion to the existing
quotient-based persistence theorem for `H₀`. -/
theorem betti0_rips_stability_step {ι : Type*} {d e : ι → ι → ℝ} {δ r : ℝ}
    (hδ : DistortionBound d e δ)
    [Fintype (Quot (Relation.EqvGen (RipsEdge d r)))]
    [Fintype (Quot (Relation.EqvGen (RipsEdge e (r + δ / 2))))] :
    betti0 (RipsEdge e (r + δ / 2)) ≤ betti0 (RipsEdge d r) := by
  apply betti0_persistence
  exact ripsEdge_mono_of_distortion hδ

/-- The `L∞` distance between two birth--death points. -/
def diagramPointDist (p q : ℝ × ℝ) : ℝ :=
  max |p.1 - q.1| |p.2 - q.2|

/-- Bottleneck distance for two finite diagrams with the same indexing type.
It is the infimum of matching radii over all bijections of the indices. -/
noncomputable def finiteBottleneck {ι : Type*} (D E : ι → ℝ × ℝ) : ℝ :=
  sInf {ε : ℝ | 0 ≤ ε ∧ ∃ σ : ι ≃ ι, ∀ i, diagramPointDist (D i) (E (σ i)) ≤ ε}

/-- Any explicit bijective matching bounds finite bottleneck distance. -/
theorem finiteBottleneck_le_of_matching {ι : Type*} [Nonempty ι]
    (D E : ι → ℝ × ℝ) {ε : ℝ} (hε : 0 ≤ ε)
    (σ : ι ≃ ι) (hσ : ∀ i, diagramPointDist (D i) (E (σ i)) ≤ ε) :
    finiteBottleneck D E ≤ ε := by
  unfold finiteBottleneck
  apply csInf_le
  · exact ⟨0, fun x hx => hx.1⟩
  · exact ⟨hε, σ, hσ⟩

/-- A finite `H₀` diagram encoded by the edge lengths of a spanning-tree
certificate: all classes are born at zero, and an edge of length `w` kills a
class at Rips radius `w/2`. -/
noncomputable def treeH0Diagram {κ : Type*} (weight : κ → ℝ) : κ → ℝ × ℝ :=
  fun k => (0, weight k / 2)

/-- Stability of a certified tree presentation of zeroth persistence.  Pairing
the same tree edge in both clouds turns a uniform edge-length perturbation into
a bottleneck bound of `δ/2`. -/
theorem treeH0Diagram_stability {κ : Type*} [Nonempty κ]
    (w v : κ → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (h : ∀ k, |w k - v k| ≤ δ) :
    finiteBottleneck (treeH0Diagram w) (treeH0Diagram v) ≤ δ / 2 := by
  apply finiteBottleneck_le_of_matching _ _ (by linarith) (Equiv.refl κ)
  intro i
  simp [treeH0Diagram, diagramPointDist]
  exact (abs_sub_le_iff.mpr ⟨by linarith [abs_le.mp (h i)], by linarith [abs_le.mp (h i)]⟩)

/-- Distance table of a two-point cloud whose unique nonzero distance is `s`. -/
def twoPointDistance (s : ℝ) (i j : Bool) : ℝ :=
  if i = j then 0 else s

/-- The clouds with separations two and three have distortion at most one. -/
theorem twoPoint_distortion :
    DistortionBound (twoPointDistance 2) (twoPointDistance 3) 1 := by
  intro i j
  cases i <;> cases j <;> simp [twoPointDistance] <;> norm_num

/-- The distortion estimate is sharp on the pair of distinct points. -/
theorem twoPoint_distortion_sharp :
    |twoPointDistance 2 false true - twoPointDistance 3 false true| = (1 : ℝ) := by
  norm_num [twoPointDistance]

/-- Concrete persistence calculation: the unique finite `H₀` bars die at radii
one and three-halves, and their finite bottleneck distance is at most one-half. -/
theorem twoPoint_pipeline :
    finiteBottleneck (treeH0Diagram (fun _ : Unit => (2 : ℝ)))
      (treeH0Diagram (fun _ : Unit => (3 : ℝ))) ≤ (1 : ℝ) / 2 := by
  apply treeH0Diagram_stability
  · norm_num
  · intro k
    norm_num

end Geometry.PersistentHomology