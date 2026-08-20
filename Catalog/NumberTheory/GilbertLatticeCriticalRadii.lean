import Catalog.Shared.GilbertLatticeConstructions
import Catalog.Shared.GilbertLatticeConnectivity
import Catalog.Shared.GilbertLatticeLowerBound

/-!
# The two deterministic critical radii of the conditioned Gilbert model

The paper *Gilbert's disc model conditioned on the square lattice* studies, besides the
almost sure percolation threshold, two critical radii which are purely geometric:

* `GilbertLattice.Rmin`, the infimum of the radii `R` for which **some** placement of one
  point per cell of `ℤ²` produces an infinite connected component;
* `GilbertLattice.Rfull`, the infimum of the radii `R` for which **every** placement
  produces a connected graph (all points connected to each other).

This file assembles the results of the other files into two-sided bounds:

* `1/3 ≤ Rmin ≤ 1/2` (`GilbertLattice.Rmin_bounds`);
* `√17 / 2 ≤ Rfull ≤ √5` (`GilbertLattice.Rfull_bounds`).

The upper bound for `Rmin` comes from the *line configuration* (points of the rows `0`
and `1` placed alternately on the line `y = 1` at horizontal distance `1/2`), the lower
bound from the deterministic non-percolation result of `GilbertLatticeLowerBound.lean`.
The bounds for `Rfull` come from the *cut configuration* and from the fact that two
points of edge-adjacent cells are always at distance at most `√5`.
-/

namespace GilbertLattice

open Set

/-- The set of radii for which some placement of the points percolates. -/
def percolatingRadii : Set ℝ :=
  {R : ℝ | ∃ (C : Config) (c : ℤ × ℤ), {d : ℤ × ℤ | (gilbert R C).Reachable c d}.Infinite}

/-- The set of radii for which *some* placement of the points gives a connected graph
(all points connected to each other). -/
def connectedPlacementRadii : Set ℝ := {R : ℝ | ∃ C : Config, (gilbert R C).Connected}

/-- The set of radii for which every placement of the points gives a connected graph. -/
def fullyConnectedRadii : Set ℝ := {R : ℝ | ∀ C : Config, (gilbert R C).Connected}

/-- The critical radius for the existence of a percolating placement. -/
noncomputable def Rmin : ℝ := sInf percolatingRadii

/-- The critical radius above which some placement connects all the points. -/
noncomputable def Rconn : ℝ := sInf connectedPlacementRadii

/-- The critical radius above which all points are connected, whatever the placement. -/
noncomputable def Rfull : ℝ := sInf fullyConnectedRadii

lemma mem_percolatingRadii_of_half_lt {R : ℝ} (hR : 1 / 2 < R) : R ∈ percolatingRadii :=
  ⟨lineConfig, (0, 0), lineConfig_component_infinite hR⟩

lemma one_third_le_of_mem_percolatingRadii {R : ℝ} (hR : R ∈ percolatingRadii) :
    1 / 3 ≤ R := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨C, c, hc⟩ := hR
  exact not_infinite_component (C := C) hcon c hc

lemma percolatingRadii_nonempty : percolatingRadii.Nonempty :=
  ⟨1, mem_percolatingRadii_of_half_lt (by norm_num)⟩

lemma percolatingRadii_bddBelow : BddBelow percolatingRadii :=
  ⟨1 / 3, fun _ hR => one_third_le_of_mem_percolatingRadii hR⟩

/-- **Two-sided bound for the geometric critical radius.**  There is a placement of the
points percolating for every `R > 1/2`, and none for `R < 1/3`. -/
theorem Rmin_bounds : 1 / 3 ≤ Rmin ∧ Rmin ≤ 1 / 2 := by
  constructor
  · exact le_csInf percolatingRadii_nonempty fun _ hR => one_third_le_of_mem_percolatingRadii hR
  · have hsub : Ioi (1 / 2 : ℝ) ⊆ percolatingRadii := fun _ hR =>
      mem_percolatingRadii_of_half_lt hR
    have h1 : sInf percolatingRadii ≤ sInf (Ioi (1 / 2 : ℝ)) :=
      csInf_le_csInf percolatingRadii_bddBelow ⟨1, by norm_num⟩ hsub
    rwa [csInf_Ioi] at h1

lemma mem_fullyConnectedRadii_of_sqrt_five_lt {R : ℝ} (hR : Real.sqrt 5 < R) :
    R ∈ fullyConnectedRadii := fun C => connected_of_sqrt_five_lt C hR

lemma sqrt_seventeen_div_two_le_of_mem {R : ℝ} (hR : R ∈ fullyConnectedRadii) :
    Real.sqrt 17 / 2 ≤ R := by
  by_contra hcon
  push_neg at hcon
  have h17 : (0 : ℝ) ≤ 17 := by norm_num
  have hs : Real.sqrt 17 ^ 2 = 17 := Real.sq_sqrt h17
  have hsnn : (0 : ℝ) ≤ Real.sqrt 17 := Real.sqrt_nonneg 17
  have hRpos : 0 < R := by
    by_contra hle
    push_neg at hle
    obtain ⟨w⟩ := (hR cutConfig).preconnected (0, 0) (1, 0)
    cases w with
    | cons hadj w' => exact absurd (radius_pos_of_adj hadj) (not_lt.2 hle)
  have hR2 : R ^ 2 ≤ 17 / 4 := by nlinarith [hcon, hsnn, hs, hRpos]
  exact cutConfig_not_connected hR2 (hR cutConfig)

lemma fullyConnectedRadii_nonempty : fullyConnectedRadii.Nonempty := by
  refine ⟨3, mem_fullyConnectedRadii_of_sqrt_five_lt ?_⟩
  have : Real.sqrt 5 < 3 := by
    rw [show (3 : ℝ) = Real.sqrt 9 by rw [show (9 : ℝ) = 3 ^ 2 by norm_num,
      Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  exact this

lemma fullyConnectedRadii_bddBelow : BddBelow fullyConnectedRadii :=
  ⟨Real.sqrt 17 / 2, fun _ hR => sqrt_seventeen_div_two_le_of_mem hR⟩

/-- **Two-sided bound for the radius of full connectivity.**  Every placement gives a
connected graph as soon as `R > √5`, and the cut configuration is disconnected for every
`R ≤ √17 / 2 ≈ 2.0616`. -/
theorem Rfull_bounds : Real.sqrt 17 / 2 ≤ Rfull ∧ Rfull ≤ Real.sqrt 5 := by
  constructor
  · exact le_csInf fullyConnectedRadii_nonempty fun _ hR => sqrt_seventeen_div_two_le_of_mem hR
  · have hsub : Ioi (Real.sqrt 5) ⊆ fullyConnectedRadii := fun _ hR =>
      mem_fullyConnectedRadii_of_sqrt_five_lt hR
    have h1 : sInf fullyConnectedRadii ≤ sInf (Ioi (Real.sqrt 5)) :=
      csInf_le_csInf fullyConnectedRadii_bddBelow ⟨Real.sqrt 5 + 1, by simp⟩ hsub
    rwa [csInf_Ioi] at h1

/-! ## The intermediate radius: some placement connects everything -/

lemma connectedPlacement_subset_percolating :
    connectedPlacementRadii ⊆ percolatingRadii := by
  rintro R ⟨C, hC⟩
  refine ⟨C, (0, 0), ?_⟩
  have : {d : ℤ × ℤ | (gilbert R C).Reachable (0, 0) d} = Set.univ := by
    ext d
    simp [hC.preconnected (0, 0) d]
  rw [this]
  exact Set.infinite_univ

lemma fullyConnected_subset_connectedPlacement :
    fullyConnectedRadii ⊆ connectedPlacementRadii := fun _ hR => ⟨centerConfig, hR centerConfig⟩

lemma connectedPlacementRadii_nonempty : connectedPlacementRadii.Nonempty :=
  ⟨2, centerConfig, centerConfig_connected (by norm_num)⟩

/-- **Two-sided bound for the radius of a fully connected placement.**  The centred
configuration connects all the points as soon as `R > 1`, and below `1/3` no placement
even percolates. -/
theorem Rconn_bounds : 1 / 3 ≤ Rconn ∧ Rconn ≤ 1 := by
  constructor
  · refine le_csInf connectedPlacementRadii_nonempty fun R hR => ?_
    exact one_third_le_of_mem_percolatingRadii (connectedPlacement_subset_percolating hR)
  · have hsub : Ioi (1 : ℝ) ⊆ connectedPlacementRadii := fun R hR =>
      ⟨centerConfig, centerConfig_connected hR⟩
    have hbdd : BddBelow connectedPlacementRadii :=
      ⟨1 / 3, fun R hR =>
        one_third_le_of_mem_percolatingRadii (connectedPlacement_subset_percolating hR)⟩
    have h1 : sInf connectedPlacementRadii ≤ sInf (Ioi (1 : ℝ)) :=
      csInf_le_csInf hbdd ⟨2, by norm_num⟩ hsub
    rwa [csInf_Ioi] at h1

/-- The three geometric critical radii are ordered: `Rmin ≤ Rconn ≤ Rfull`. -/
theorem Rmin_le_Rconn_le_Rfull : Rmin ≤ Rconn ∧ Rconn ≤ Rfull := by
  constructor
  · exact csInf_le_csInf percolatingRadii_bddBelow connectedPlacementRadii_nonempty
      connectedPlacement_subset_percolating
  · refine csInf_le_csInf ?_ fullyConnectedRadii_nonempty
      fullyConnected_subset_connectedPlacement
    exact ⟨1 / 3, fun R hR =>
      one_third_le_of_mem_percolatingRadii (connectedPlacement_subset_percolating hR)⟩

end GilbertLattice