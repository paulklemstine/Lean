import Geometry.NeuralCoding.ConformalPersistence

/-!
# Inverse stereographic persistence: a corrected formal statement

The proposed radial transform `2 d / (1 + d² / 4)` is not the spherical
geodesic distance between inverse stereographic images: that distance depends
on the norms of both endpoints, not only on their Euclidean separation.

This file builds on `ConformalPersistence`.  It proves that the catalog's exact
conformally weighted distance transports both Vietoris--Rips faces and Čech
faces without changing their filtration parameter.  It also gives a certified
one-dimensional counterexample to the proposed radial formula and records the
correct geodesic transform.
-/

noncomputable section

namespace InverseStereographicPersistence

open Finset
open ConformalPersistence

variable {n ι : ℕ}

/-- The radial formula proposed in the research mission. -/
def proposedRadialWeight (d : ℝ) : ℝ := 2 * d / (1 + d ^ 2 / 4)

/-- Spherical geodesic distance expressed as a function of chordal distance. -/
def geodesicFromChordal (c : ℝ) : ℝ := 2 * Real.arcsin (c / 2)

/-- The corrected weighted distance whose value is the spherical geodesic
 distance between inverse stereographic images. -/
def geodesicWeightedDist (x y : Fin n → ℝ) : ℝ :=
  geodesicFromChordal (weightedDist x y)

/-- A Vietoris--Rips face of a labelled point cloud, stated directly in terms
of all pairwise distances. -/
def ripsFace (d : (Fin n → ℝ) → (Fin n → ℝ) → ℝ)
    (X : Fin ι → (Fin n → ℝ)) (ε : ℝ) (σ : Finset (Fin ι)) : Prop :=
  ∀ i ∈ σ, ∀ j ∈ σ, d (X i) (X j) ≤ ε

/-- A Čech face: the closed balls of radius `ε` about the vertices have a
common center in the stereographic chart. -/
def cechFace (d : (Fin n → ℝ) → (Fin n → ℝ) → ℝ)
    (X : Fin ι → (Fin n → ℝ)) (ε : ℝ) (σ : Finset (Fin ι)) : Prop :=
  ∃ center : Fin n → ℝ, ∀ i ∈ σ, d center (X i) ≤ ε

/-- Exact conformal transport preserves every Vietoris--Rips face at the same
filtration parameter. -/
theorem ripsFace_chordal_iff_weighted
    (X : Fin ι → (Fin n → ℝ)) (ε : ℝ) (σ : Finset (Fin ι)) :
    ripsFace chordal X ε σ ↔ ripsFace weightedDist X ε σ := by
  unfold ripsFace
  simp only [chordal_eq_weighted]

/-- Exact conformal transport preserves every Čech face at the same filtration
parameter (with centers in the stereographic chart). -/
theorem cechFace_chordal_iff_weighted
    (X : Fin ι → (Fin n → ℝ)) (ε : ℝ) (σ : Finset (Fin ι)) :
    cechFace chordal X ε σ ↔ cechFace weightedDist X ε σ := by
  unfold cechFace
  simp only [chordal_eq_weighted]

/-- The correct geodesic-weighted distance is exactly the spherical geodesic
transform of the chordal distance. -/
theorem geodesicWeightedDist_eq (x y : Fin n → ℝ) :
    geodesicWeightedDist x y = geodesicFromChordal (chordal x y) := by
  unfold geodesicWeightedDist
  rw [chordal_eq_weighted]

/-- A point of the one-dimensional stereographic chart. -/
def linePoint (t : ℝ) : Fin 1 → ℝ := fun _ => t

/-- The projected Euclidean distance from `0` to `2` is exactly `2`. -/
theorem linePoint_euclidean_distance :
    Real.sqrt (euclDist2 (linePoint 0) (linePoint 2)) = 2 := by
  rw [show euclDist2 (linePoint 0) (linePoint 2) = 4 by
    simp [euclDist2, linePoint]
    norm_num]
  norm_num

/-- For that pair, the proposed radial formula evaluates to `2`. -/
theorem proposedRadialWeight_linePoint :
    proposedRadialWeight
      (Real.sqrt (euclDist2 (linePoint 0) (linePoint 2))) = 2 := by
  rw [linePoint_euclidean_distance]
  norm_num [proposedRadialWeight]

/-- The actual chordal distance for that pair is strictly less than `2`. -/
theorem chordal_linePoint_lt_two :
    chordal (linePoint 0) (linePoint 2) < 2 := by
  rw [chordal_eq_weighted]
  unfold weightedDist
  rw [linePoint_euclidean_distance]
  have h0 : nsq (linePoint 0) = 0 := by simp [nsq, linePoint]
  have h2 : nsq (linePoint 2) = 4 := by
    simp [nsq, linePoint]
    norm_num
  rw [h0, h2]
  norm_num
  have hs : (2 : ℝ) < Real.sqrt 5 := by
    rw [Real.lt_sqrt (by norm_num)]
    norm_num
  rw [div_lt_iff₀ (by positivity : 0 < Real.sqrt 5)]
  nlinarith

/-- Certified counterexample: the proposed radial formula is not the chordal
spherical distance induced by inverse stereographic projection. -/
theorem proposed_formula_counterexample :
    chordal (linePoint 0) (linePoint 2) ≠
      proposedRadialWeight
        (Real.sqrt (euclDist2 (linePoint 0) (linePoint 2))) := by
  rw [proposedRadialWeight_linePoint]
  exact ne_of_lt chordal_linePoint_lt_two

end InverseStereographicPersistence