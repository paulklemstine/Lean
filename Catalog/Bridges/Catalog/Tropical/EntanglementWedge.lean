/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Entanglement Wedge Reconstruction

## Overview

We formalize a finite tropical analogue of the entanglement wedge reconstruction
principle from holography. Given a finite vertex set with a distance function,
a boundary/bulk partition, and a boundary subset `B`, we define the **entanglement
wedge** of `B` as the set of bulk vertices strictly closer to `B` than to its
boundary complement in the min-plus (tropical) distance.

## Main Definitions

* `distToFinset` — Minimum distance from a vertex to a finite set.
* `entanglementWedge` — Bulk vertices strictly closer to `B` than to `boundary \ B`.
* `boundaryObs` — Tropical convolution / boundary observation profile.
* `supportOn` — Support condition for surgery perturbations.

## Main Results

* `mem_entanglementWedge_iff` — Membership in the wedge ⟺ strict distance inequality.
* `not_mem_entanglementWedge_of_ge` — Reversed inequality excludes from wedge.
* `wedge_membership_stable_under_uniform_perturbation` — Wedge membership is stable
  under sufficiently small perturbations of the distance function.
* `wedge_surgery_detectable` — Surgery supported in the wedge with a unique argmin
  witness is detectable from boundary observations restricted to `B`.
* `wedge_reconstruction_from_boundary_profiles` — Under injectivity of argmin witnesses,
  equality of boundary observations implies equality of bulk states on the wedge.

## References

This builds on `reconstructs_bulk_from_boundary_profiles` from
`Catalog.Bridges.CausalHolography` and the GL₃ tropical Satake reconstruction
in `Catalog.Tropical.GL3Reconstruction`.
-/

set_option maxHeartbeats 400000

noncomputable section

open Finset

/-! ## Section 1: Core Definitions -/

/-- Minimum distance from a vertex `v` to a nonempty finite set `s`,
computed as `Finset.inf'` over the distance function. This is the
tropical (min-plus) distance from a point to a boundary region. -/
def distToFinset {V : Type*} (d : V → V → ℝ) (s : Finset V)
    (hs : s.Nonempty) (v : V) : ℝ :=
  s.inf' hs (fun b => d v b)

/-- The **entanglement wedge** of a boundary subset `B` relative to
`bulk` and `boundary`: the set of bulk vertices that are strictly closer
(in tropical/min-plus distance) to `B` than to the boundary complement
`boundary \ B`.

The strict inequality creates a robust "phase separation" that avoids
ambiguous tie vertices. -/
def entanglementWedge {V : Type*} [DecidableEq V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) : Finset V :=
  bulk.filter (fun v =>
    ∀ (hB : B.Nonempty) (hBc : (boundary \ B).Nonempty),
      distToFinset d B hB v < distToFinset d (boundary \ B) hBc v)

/-- The **boundary observation** (tropical convolution) of a bulk state
`φ` at a boundary point `b`. This is the min-plus transform:
  `Obs_B(φ)(b) = inf_{v ∈ bulk} (φ(v) + d(v, b))` -/
def boundaryObs {V : Type*} [DecidableEq V]
    (bulk : Finset V) (d : V → V → ℝ) (hbulk : bulk.Nonempty)
    (φ : V → ℝ) (b : V) : ℝ :=
  bulk.inf' hbulk (fun v => φ v + d v b)

/-- A perturbation `φ'` is **supported on** `S` if `φ'` agrees with `φ`
outside `S`. This models surgery localized to a region. -/
def supportOn {V : Type*} (S : Set V) (φ φ' : V → ℝ) : Prop :=
  ∀ ⦃v⦄, v ∉ S → φ' v = φ v

/-! ## Section 2: Basic Distance Lemmas -/

/-- `distToFinset` is at most the distance to any member of the set. -/
theorem distToFinset_le {V : Type*} {d : V → V → ℝ} {s : Finset V}
    {hs : s.Nonempty} {v : V} {b : V} (hb : b ∈ s) :
    distToFinset d s hs v ≤ d v b :=
  Finset.inf'_le _ hb

/-- `distToFinset` is the greatest lower bound: if `c` is at most the distance
to every member, then `c ≤ distToFinset`. -/
theorem le_distToFinset {V : Type*} {d : V → V → ℝ} {s : Finset V}
    {hs : s.Nonempty} {v : V} {c : ℝ} (hc : ∀ b ∈ s, c ≤ d v b) :
    c ≤ distToFinset d s hs v :=
  Finset.le_inf' _ _ hc

/-- `distToFinset` is realized by some member of the set. -/
theorem distToFinset_exists_witness {V : Type*} [DecidableEq V]
    {d : V → V → ℝ} {s : Finset V} {hs : s.Nonempty} {v : V} :
    ∃ b ∈ s, distToFinset d s hs v = d v b :=
  Finset.exists_mem_eq_inf' hs (fun b => d v b)

/-! ## Section 3: Wedge Membership Characterization -/

/-- **Wedge membership criterion**: a bulk vertex `v` is in the entanglement
wedge of `B` if and only if its minimum distance to `B` is strictly less
than its minimum distance to the boundary complement `boundary \ B`. -/
theorem mem_entanglementWedge_iff
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty) :
    v ∈ entanglementWedge bulk boundary B d ↔
      distToFinset d B hB v < distToFinset d (boundary \ B) hBc v := by
  simp [entanglementWedge, hv, hB, hBc]

/-- **Boundary complement exclusion**: if the distance to `boundary \ B`
is at most the distance to `B`, then `v` is not in the wedge. -/
theorem not_mem_entanglementWedge_of_ge
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty)
    (hge : distToFinset d (boundary \ B) hBc v ≤ distToFinset d B hB v) :
    v ∉ entanglementWedge bulk boundary B d := by
  rw [mem_entanglementWedge_iff hv hB hBc]
  exact not_lt.mpr hge

/-
Wedge membership implies a positive separation gap.
-/
theorem wedge_gap_pos
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ} {v : V}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty)
    (hmem : v ∈ entanglementWedge bulk boundary B d) :
    0 < distToFinset d (boundary \ B) hBc v - distToFinset d B hB v := by
  exact sub_pos_of_lt ( by rwa [ mem_entanglementWedge_iff hv hB hBc ] at hmem )

/-! ## Section 4: Perturbation Stability -/

/-
`distToFinset` under a perturbed distance `d'` is within `ε` of the
original if all individual distances are within `ε`.
-/
theorem distToFinset_perturb_bound
    {V : Type*} [DecidableEq V]
    {d d' : V → V → ℝ} {s : Finset V} {hs : s.Nonempty}
    {v : V} {ε : ℝ}
    (hε : ∀ b ∈ s, |d v b - d' v b| < ε) :
    |distToFinset d s hs v - distToFinset d' s hs v| < ε := by
  refine' abs_sub_lt_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ b, hb₁, hb₂ ⟩ := distToFinset_exists_witness ( s := s ) ( d := d' ) ( hs := hs ) ( v := v );
    linarith [ abs_lt.mp ( hε b hb₁ ), distToFinset_le ( d := d ) ( s := s ) ( hs := hs ) ( v := v ) ( b := b ) hb₁ ];
  · obtain ⟨ b, hb₁, hb₂ ⟩ := distToFinset_exists_witness ( s := s ) ( d := d ) ( v := v );
    linarith [ abs_lt.mp ( hε b hb₁ ), show distToFinset d' s hs v ≤ d' v b from Finset.inf'_le _ hb₁ ]

/-
**Wedge membership stability**: if `v` is in the wedge with a gap
`δ = d_{Bᶜ}(v) - d_B(v)`, and the distance perturbation is bounded by
`ε < δ/2`, then `v` remains in the wedge under `d'`.

This is a tropical analogue of stability of causal/entanglement regions
under metric perturbation.
-/
theorem wedge_membership_stable_under_uniform_perturbation
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V}
    {d d' : V → V → ℝ} {v : V} {ε : ℝ}
    (hv : v ∈ bulk)
    (hB : B.Nonempty)
    (hBc : (boundary \ B).Nonempty)
    (_hmem : v ∈ entanglementWedge bulk boundary B d)
    (hεB : ∀ b ∈ B, |d v b - d' v b| < ε)
    (hεBc : ∀ b ∈ boundary \ B, |d v b - d' v b| < ε)
    (hgap : 2 * ε < distToFinset d (boundary \ B) hBc v - distToFinset d B hB v) :
    v ∈ entanglementWedge bulk boundary B d' := by
  have h_bound : |distToFinset d B hB v - distToFinset d' B hB v| < ε ∧ |distToFinset d (boundary \ B) hBc v - distToFinset d' (boundary \ B) hBc v| < ε := by
    exact ⟨ distToFinset_perturb_bound hεB, distToFinset_perturb_bound hεBc ⟩;
  exact mem_entanglementWedge_iff hv hB hBc |>.2 ( by linarith [ abs_lt.mp h_bound.1, abs_lt.mp h_bound.2 ] )

/-! ## Section 5: Boundary Observation Lemmas -/

/-- `boundaryObs` is at most `φ v + d v b` for any bulk vertex `v`. -/
theorem boundaryObs_le_of_mem {V : Type*} [DecidableEq V]
    {bulk : Finset V} {d : V → V → ℝ} {hbulk : bulk.Nonempty}
    {φ : V → ℝ} {b v : V} (hv : v ∈ bulk) :
    boundaryObs bulk d hbulk φ b ≤ φ v + d v b :=
  Finset.inf'_le _ hv

/-
`boundaryObs` equals `φ v + d v b` when `v` is the unique minimizer.
-/
theorem boundaryObs_eq_of_unique_argmin {V : Type*} [DecidableEq V]
    {bulk : Finset V} {d : V → V → ℝ} {hbulk : bulk.Nonempty}
    {φ : V → ℝ} {b v : V}
    (hv : v ∈ bulk)
    (huniq : ∀ w ∈ bulk, w ≠ v → φ v + d v b < φ w + d w b) :
    boundaryObs bulk d hbulk φ b = φ v + d v b := by
  refine' le_antisymm ( Finset.inf'_le _ hv ) ( _ );
  exact Finset.le_inf' _ _ fun w hw => if hw' : w = v then hw'.symm ▸ le_rfl else le_of_lt ( huniq w hw hw' )

/-
If the unique argmin changes value, the boundary observation changes.
-/
theorem boundaryObs_ne_of_unique_argmin_changed {V : Type*} [DecidableEq V]
    {bulk : Finset V} {d : V → V → ℝ} {hbulk : bulk.Nonempty}
    {φ φ' : V → ℝ} {b v : V}
    (hv : v ∈ bulk)
    (huniq : ∀ w ∈ bulk, w ≠ v → φ v + d v b < φ w + d w b)
    (huniq' : ∀ w ∈ bulk, w ≠ v → φ' v + d v b < φ' w + d w b)
    (hchange : φ' v ≠ φ v) :
    boundaryObs bulk d hbulk φ' b ≠ boundaryObs bulk d hbulk φ b := by
  grind +suggestions

/-! ## Section 6: Surgery Detectability -/

/-
**Wedge surgery detectability theorem**: if a surgery is supported in the
entanglement wedge of `B`, and there exists a vertex in the support with a
unique argmin witness visible from some `b ∈ B`, then the surgery is detectable
from boundary observations restricted to `B`.

This converts wedge membership into operational observability via a tropical
argmin uniqueness condition.
-/
theorem wedge_surgery_detectable
    {V : Type*} [DecidableEq V]
    {bulk B : Finset V} {d : V → V → ℝ}
    (_hbulk : bulk.Nonempty)
    {φ φ' : V → ℝ}
    (hwitness :
      ∃ v ∈ bulk, ∃ b ∈ B,
        (∀ w ∈ bulk, w ≠ v → φ v + d v b < φ w + d w b) ∧
        (∀ w ∈ bulk, w ≠ v → φ' v + d v b < φ' w + d w b) ∧
        φ' v ≠ φ v) :
    ∃ b ∈ B, boundaryObs bulk d _hbulk φ b ≠ boundaryObs bulk d _hbulk φ' b := by
  obtain ⟨ v, hv, b, hb, h₁, h₂, h₃ ⟩ := hwitness;
  exact ⟨b, hb, (boundaryObs_ne_of_unique_argmin_changed hv h₁ h₂ h₃).symm⟩

/-! ## Section 7: Wedge Reconstruction -/

/-
**Wedge reconstruction from boundary profiles**: under a unique argmin
witness hypothesis (injectivity), equality of boundary observations on `B`
implies equality of the bulk state on the entire wedge.

This is the finite tropical analogue of entanglement wedge reconstruction:
boundary data on `B` determines the bulk state throughout `Wedge(B)`.
-/
theorem wedge_reconstruction_from_boundary_profiles
    {V : Type*} [DecidableEq V]
    {bulk boundary B : Finset V} {d : V → V → ℝ}
    (hbulk : bulk.Nonempty)
    {φ φ' : V → ℝ}
    (hinj :
      ∀ v ∈ entanglementWedge bulk boundary B d,
        ∃ b ∈ B, ∀ w ∈ bulk, w ≠ v →
          φ v + d v b < φ w + d w b)
    (hinj' :
      ∀ v ∈ entanglementWedge bulk boundary B d,
        ∃ b ∈ B, ∀ w ∈ bulk, w ≠ v →
          φ' v + d v b < φ' w + d w b)
    (hobs :
      ∀ b ∈ B, boundaryObs bulk d hbulk φ b =
               boundaryObs bulk d hbulk φ' b) :
    ∀ v ∈ entanglementWedge bulk boundary B d, φ v = φ' v := by
  intros v hv;
  obtain ⟨ b, hb₁, hb₂ ⟩ := hinj v hv;
  obtain ⟨ b', hb₁', hb₂' ⟩ := hinj' v hv;
  have h_eq : boundaryObs bulk d hbulk φ b = φ v + d v b ∧ boundaryObs bulk d hbulk φ' b' = φ' v + d v b' := by
    apply And.intro;
    · exact boundaryObs_eq_of_unique_argmin ( Finset.mem_filter.mp hv |>.1 ) hb₂;
    · apply boundaryObs_eq_of_unique_argmin;
      · exact Finset.mem_filter.mp hv |>.1;
      · exact hb₂';
  have h_eq' : boundaryObs bulk d hbulk φ' b ≤ φ' v + d v b ∧ boundaryObs bulk d hbulk φ b' ≤ φ v + d v b' := by
    exact ⟨ boundaryObs_le_of_mem ( show v ∈ bulk from Finset.mem_filter.mp hv |>.1 ), boundaryObs_le_of_mem ( show v ∈ bulk from Finset.mem_filter.mp hv |>.1 ) ⟩;
  linarith [ hobs b hb₁, hobs b' hb₁' ]

/-! ## Section 8: Monotonicity and Order Properties -/

/-
Distance to a subset is at least the distance to a superset.
-/
theorem distToFinset_mono {V : Type*} [DecidableEq V]
    {d : V → V → ℝ} {s t : Finset V} {hs : s.Nonempty}
    (hst : s ⊆ t) (v : V) :
    distToFinset d t (Finset.Nonempty.mono hst hs) v ≤ distToFinset d s hs v := by
  grind +suggestions

/-
When `B` is empty, the wedge condition is vacuously true for all bulk vertices,
so the wedge equals the entire bulk set.
-/
theorem entanglementWedge_empty_eq_bulk {V : Type*} [DecidableEq V]
    (bulk boundary : Finset V) (d : V → V → ℝ) :
    entanglementWedge bulk boundary ∅ d = bulk := by
  unfold entanglementWedge;
  simp +decide

/-- The wedge is contained in the bulk. -/
theorem entanglementWedge_subset_bulk {V : Type*} [DecidableEq V]
    (bulk boundary B : Finset V) (d : V → V → ℝ) :
    entanglementWedge bulk boundary B d ⊆ bulk :=
  Finset.filter_subset _ _

end