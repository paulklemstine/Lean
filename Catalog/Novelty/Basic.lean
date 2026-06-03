/-
# Poincaré Conjecture for Data: Manifold Detection via Persistent Homology

This module formalizes the key mathematical structures connecting persistent homology
to manifold detection.

## Main Results

* `rips_monotone` - VR complexes grow monotonically with ε
* `rips_complete_of_large_eps` - VR becomes complete simplex at large ε
* `nerve_rips_bridge` - Triangle inequality connects nerve covers to Rips edges
* `rips_zero_faces` - At scale 0, only singletons survive (metric space)
* `mem_rips_iff_birth` - Face membership characterized by birth time
-/

import Mathlib

open Finset Set

/-! ## Abstract Simplicial Complex -/

/-- An abstract simplicial complex on a type α is a downward-closed collection
    of finite subsets. -/
structure ASComplex (α : Type*) where
  faces : Set (Finset α)
  empty_mem : ∅ ∈ faces
  down_closed : ∀ {σ τ : Finset α}, σ ∈ faces → τ ⊆ σ → τ ∈ faces

namespace ASComplex

variable {α : Type*}

/-- The k-skeleton consists of all faces of dimension ≤ k. -/
def skeleton (K : ASComplex α) (k : ℕ) : Set (Finset α) :=
  {σ ∈ K.faces | σ.card ≤ k + 1}

end ASComplex

/-! ## Vietoris-Rips Complex -/

/-- The Vietoris-Rips complex of a finite pseudometric space at scale ε.
    A simplex σ is included iff σ ⊆ S and every pair of points in σ is within distance ε. -/
def RipsComplex {α : Type*} [PseudoMetricSpace α] (S : Finset α) (ε : ℝ) :
    ASComplex α where
  faces := {σ : Finset α | σ ⊆ S ∧ ∀ x ∈ σ, ∀ y ∈ σ, dist x y ≤ ε}
  empty_mem := ⟨empty_subset S, fun x hx => absurd hx (Finset.notMem_empty x)⟩
  down_closed := fun ⟨hσS, hσ⟩ hτσ =>
    ⟨hτσ.trans hσS, fun x hx y hy => hσ x (hτσ hx) y (hτσ hy)⟩

/-! ## Core Rips Complex Theorems -/

/-- **Monotonicity**: If ε₁ ≤ ε₂, every face of VR(S,ε₁) is a face of VR(S,ε₂).
    This is the filtration property that makes persistent homology possible. -/
theorem rips_monotone {α : Type*} [PseudoMetricSpace α] (S : Finset α) {ε₁ ε₂ : ℝ}
    (h : ε₁ ≤ ε₂) (σ : Finset α) :
    σ ∈ (RipsComplex S ε₁).faces → σ ∈ (RipsComplex S ε₂).faces :=
  fun ⟨hσS, hσ⟩ => ⟨hσS, fun x hx y hy => le_trans (hσ x hx y hy) h⟩

/-- **Completeness**: When ε exceeds the diameter, every subset of S is a face. -/
theorem rips_complete_of_large_eps {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (ε : ℝ)
    (hε : ∀ x ∈ S, ∀ y ∈ S, dist x y ≤ ε)
    (σ : Finset α) (hσ : σ ⊆ S) : σ ∈ (RipsComplex S ε).faces :=
  ⟨hσ, fun x hx y hy => hε x (hσ hx) y (hσ hy)⟩

/-- **Filtration nesting**: The faces grow as ε increases. -/
theorem rips_filtration_nested {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    (RipsComplex S ε₁).faces ⊆ (RipsComplex S ε₂).faces :=
  fun _ hσ => rips_monotone S h _ hσ

/-- At scale 0, only singletons and the empty set are faces in a metric space. -/
theorem rips_zero_faces {α : Type*} [MetricSpace α] (S : Finset α) (σ : Finset α) :
    σ ∈ (RipsComplex S 0).faces → σ.card ≤ 1 := by
  intro ⟨_, hσ⟩
  by_contra h
  push_neg at h
  obtain ⟨a, ha, b, hb, hab⟩ := Finset.one_lt_card.mp h
  have hd := hσ a ha b hb
  have : a = b := dist_eq_zero.mp (le_antisymm hd dist_nonneg)
  exact hab this

/-- **Perturbation stability**: Increasing ε only adds faces. -/
theorem rips_perturbation {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) {ε δ : ℝ} (hδ : 0 ≤ δ)
    (σ : Finset α) (hσ : σ ∈ (RipsComplex S ε).faces) :
    σ ∈ (RipsComplex S (ε + δ)).faces :=
  rips_monotone S (le_add_of_nonneg_right hδ) σ hσ

/-! ## Covering and Packing Numbers -/

/-- A finite set C is an ε-cover of S if every point of S is within distance ε
    of some point in C. -/
def IsEpsCover {α : Type*} [PseudoMetricSpace α]
    (S : Finset α) (C : Finset α) (ε : ℝ) : Prop :=
  ∀ x ∈ S, ∃ c ∈ C, dist x c ≤ ε

/-- A finite set P is ε-separated if every pair of distinct points has distance > ε. -/
def IsEpsSeparated {α : Type*} [PseudoMetricSpace α]
    (P : Finset α) (ε : ℝ) : Prop :=
  ∀ x ∈ P, ∀ y ∈ P, x ≠ y → ε < dist x y

/-- **Self-covering**: S ε-covers itself for ε ≥ 0. -/
theorem self_cover {α : Type*} [PseudoMetricSpace α] (S : Finset α) {ε : ℝ}
    (hε : 0 ≤ ε) : IsEpsCover S S ε :=
  fun x hx => ⟨x, hx, by rw [dist_self]; exact hε⟩

/-- **Cover monotonicity**: Increasing ε preserves covers. -/
theorem cover_monotone {α : Type*} [PseudoMetricSpace α] (S C : Finset α)
    {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) (hC : IsEpsCover S C ε₁) :
    IsEpsCover S C ε₂ :=
  fun x hx => let ⟨c, hc, hd⟩ := hC x hx; ⟨c, hc, le_trans hd h⟩

/-- **Maximal packing = cover**: A maximal ε-separated subset is an ε-cover. -/
theorem maximal_packing_is_cover {α : Type*} [PseudoMetricSpace α]
    (S P : Finset α) (ε : ℝ)
    (hMax : ∀ x ∈ S, x ∉ P → ∃ p ∈ P, dist x p ≤ ε)
    (_hP : P ⊆ S) (hε : 0 ≤ ε) :
    IsEpsCover S P ε := by
  intro x hx
  by_cases hxP : x ∈ P
  · exact ⟨x, hxP, by rw [dist_self]; exact hε⟩
  · exact hMax x hx hxP

/-! ## Nerve-Rips Bridge -/

section NerveRips

variable {α : Type*} [PseudoMetricSpace α] [DecidableEq α]

/-
**Nerve-Rips bridge theorem**: If two cover centers c₁, c₂ both have a witness
    point x within ε of each, then {c₁, c₂} is an edge in VR(S, 2ε).
    This uses the triangle inequality: dist(c₁, c₂) ≤ dist(c₁, x) + dist(x, c₂) ≤ 2ε.
-/
theorem nerve_rips_bridge
    (S : Finset α) {ε : ℝ} (hε : 0 ≤ ε)
    {c₁ c₂ : α} (hc₁S : c₁ ∈ S) (hc₂S : c₂ ∈ S)
    {x : α} (hxc₁ : dist x c₁ ≤ ε) (hxc₂ : dist x c₂ ≤ ε) :
    ({c₁, c₂} : Finset α) ∈ (RipsComplex S (2 * ε)).faces := by
  constructor;
  · aesop_cat;
  · simp +zetaDelta at *;
    exact ⟨ ⟨ hε, by linarith [ dist_triangle_left c₁ c₂ x, dist_triangle_right c₁ c₂ x, dist_comm x c₁, dist_comm x c₂ ] ⟩, by linarith [ dist_triangle_left c₂ c₁ x, dist_triangle_right c₂ c₁ x, dist_comm x c₁, dist_comm x c₂ ], hε ⟩

/-
**Edge inclusion**: Close points form an edge in VR(S, ε).
-/
theorem rips_edge_of_close
    (S : Finset α) {ε : ℝ} (hε : 0 ≤ ε)
    {x y : α} (hx : x ∈ S) (hy : y ∈ S) (hxy : dist x y ≤ ε) :
    ({x, y} : Finset α) ∈ (RipsComplex S ε).faces := by
  refine' ⟨ _, _ ⟩;
  · grind +revert;
  · simp +decide [ *, dist_comm ]

end NerveRips

/-! ## Birth Time -/

section BirthTime

variable {α : Type*} [PseudoMetricSpace α]

/-- The birth time of a simplex is the maximum pairwise distance. -/
noncomputable def birthTime (σ : Finset α) : ℝ :=
  if h : σ.Nonempty then
    σ.sup' h (fun x => σ.sup' h (fun y => dist x y))
  else 0

/-
**Birth time characterization**: A face appears in VR(S, ε) iff ε ≥ its birth time.
-/
theorem mem_rips_iff_birth (S : Finset α) (σ : Finset α)
    (hσS : σ ⊆ S) (hσ : σ.Nonempty) (ε : ℝ) :
    σ ∈ (RipsComplex S ε).faces ↔ birthTime σ ≤ ε := by
  simp +decide [ birthTime, Finset.sup'_le_iff, Finset.le_sup'_iff, RipsComplex ];
  split_ifs ; simp +decide [ *, Finset.sup'_le_iff ]

end BirthTime

/-! ## Detection Threshold -/

/-- The sphere signature captures the homological profile of S^d. -/
structure SphereSignature where
  dim : ℕ
  connected : Prop
  hasTopCycle : Prop
  intermediateVanish : Prop

/-- Whether a signature matches S^d. -/
def SphereSignature.isSpherelike (b : SphereSignature) : Prop :=
  b.connected ∧ b.hasTopCycle ∧ b.intermediateVanish

/-- The Poincaré threshold: the infimum scale at which sphere-like topology appears. -/
noncomputable def poincareThreshold (detector : ℝ → SphereSignature) : ℝ :=
  sInf {ε : ℝ | 0 < ε ∧ (detector ε).isSpherelike}

/-- The volumetric detection threshold: n^{-1/d} scaling. -/
noncomputable def volumetricThreshold (n : ℕ) (d : ℕ) (vol : ℝ) : ℝ :=
  vol * (n : ℝ) ^ (-(1 : ℝ) / (d : ℝ))

/-
**Threshold positivity**: The volumetric threshold is positive.
-/
theorem volumetricThreshold_pos {n d : ℕ} {vol : ℝ}
    (hn : 0 < n) (hd : 0 < d) (hvol : 0 < vol) :
    0 < volumetricThreshold n d vol := by
  exact mul_pos hvol ( Real.rpow_pos_of_pos ( Nat.cast_pos.mpr hn ) _ )