import Mathlib.Topology.MetricSpace.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Tactic

/-!
# Vietoris–Rips filtration skeleton

This file formalizes the first verified layer of a persistent homology /
Vietoris–Rips pipeline for finite (pseudo)metric spaces.

We work over a type `α` with `[PseudoMetricSpace α]`.  A *Vietoris–Rips simplex*
at scale `r` is a finite subset all of whose pairwise distances are bounded by
`r`.  We record the basic monotonicity, downward-closure and existence
properties, package the simplices at a fixed scale as a subtype, and define the
canonical scale-inclusion maps together with their functoriality
(identity and composition) laws.

This is intended as a foundation for later formalization of filtered simplicial
complexes and persistent homology.
-/

/-- A Vietoris–Rips simplex at scale `r` is a finite subset whose pairwise
distances are all bounded by `r`. -/
def VRSimplex {α : Type*} [PseudoMetricSpace α] (r : ℝ) (σ : Finset α) : Prop :=
  ∀ x ∈ σ, ∀ y ∈ σ, dist x y ≤ r

/-- Vietoris–Rips simplices are monotone in the scale parameter. -/
theorem VRSimplex_mono {α : Type*} [PseudoMetricSpace α]
    {r s : ℝ} (hrs : r ≤ s) {σ : Finset α} :
    VRSimplex r σ → VRSimplex s σ := by
  intro h x hx y hy
  exact le_trans (h x hx y hy) hrs

/-- Vietoris–Rips simplices are downward closed: any subset (face) of a VR
simplex is again a VR simplex. -/
theorem VRSimplex_of_subset {α : Type*} [PseudoMetricSpace α]
    {r : ℝ} {τ σ : Finset α} (hσ : VRSimplex r σ) (hτσ : τ ⊆ σ) :
    VRSimplex r τ := by
  intro x hx y hy
  exact hσ x (hτσ hx) y (hτσ hy)

/-- The empty set is a VR simplex at every scale. -/
theorem VRSimplex_empty {α : Type*} [PseudoMetricSpace α] {r : ℝ} :
    VRSimplex r (∅ : Finset α) := by
  intro x hx
  simp at hx

/-- Singletons are VR simplices at every nonnegative scale. -/
theorem VRSimplex_singleton {α : Type*} [PseudoMetricSpace α]
    {r : ℝ} (hr : 0 ≤ r) (x : α) :
    VRSimplex r ({x} : Finset α) := by
  intro a ha b hb
  rw [Finset.mem_singleton] at ha hb
  subst ha hb
  simpa using hr

/-- The collection of Vietoris–Rips simplices at scale `r`, packaged as a
subtype of `Finset α`. -/
def VRSimplices (α : Type*) [PseudoMetricSpace α] (r : ℝ) :=
  {σ : Finset α // VRSimplex r σ}

/-- The canonical inclusion of VR simplices induced by an inequality `r ≤ s`. -/
def scaleInclusion {α : Type*} [PseudoMetricSpace α]
    {r s : ℝ} (hrs : r ≤ s) :
    VRSimplices α r → VRSimplices α s :=
  fun σ => ⟨σ.1, VRSimplex_mono hrs σ.2⟩

/-- The scale inclusion preserves the underlying finite subset. -/
@[simp] theorem scaleInclusion_coe {α : Type*} [PseudoMetricSpace α]
    {r s : ℝ} (hrs : r ≤ s) (σ : VRSimplices α r) :
    (scaleInclusion hrs σ).1 = σ.1 := by
  rfl

/-- Identity law: the inclusion induced by `r ≤ r` is the identity. -/
theorem scaleInclusion_refl {α : Type*} [PseudoMetricSpace α]
    {r : ℝ} (σ : VRSimplices α r) :
    scaleInclusion (le_rfl : r ≤ r) σ = σ := by
  apply Subtype.ext
  rfl

/-- Composition law: scale inclusions compose along `r ≤ s ≤ t`. -/
theorem scaleInclusion_comp {α : Type*} [PseudoMetricSpace α]
    {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t)
    (σ : VRSimplices α r) :
    scaleInclusion (le_trans hrs hst) σ =
      scaleInclusion hst (scaleInclusion hrs σ) := by
  apply Subtype.ext
  rfl