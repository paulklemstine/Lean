/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Stereographic Persistence: Topological Data Analysis on Spheres

This file formalizes the mathematical foundations for computing persistent homology
on spheres via stereographic projection. The key insight is that stereographic
projection maps spherical (geodesic) distances to conformally weighted Euclidean
distances, preserving the filtration structure needed for persistence computations.

## Main definitions

* `ConformalWeight` — A positive conformal weight function on a metric space
* `FilteredComplex` — An abstract filtered simplicial complex for persistence
* `PersistenceModule` — Abstract persistence module over a filtered complex
* `cechComplex` — Čech complex from a distance function

## Main results

* `conformal_factor_pos` — The stereographic conformal factor is strictly positive
* `conformal_factor_le_two` — The conformal factor is bounded above by 2
* `weighted_cech_containment` — Weighted Čech filtration containment
* `unweighted_cech_containment` — Reverse containment under weight lower bound
* `conformal_iso_preserves_cech` — Conformal isometry preserves Čech filtration
* `birth_time_preserved` — Filtration morphisms preserve birth times
* `interleaved_triangle` — Triangle inequality for interleaving distance

## References

* Edelsbrunner, H. and Harer, J. "Computational Topology", AMS 2010
* de Silva, V. and Carlsson, G. "Topological estimation using witness complexes", 2004
-/

import Mathlib

open Real BigOperators

noncomputable section

namespace StereographicPersistence

/-! ## Part 1: Conformal Weight Functions -/

/-- A conformal weight on a type `α` is a positive real-valued function
    used to modify a base metric conformally. -/
structure ConformalWeight (α : Type*) where
  /-- The weight function -/
  w : α → ℝ
  /-- Weights are strictly positive -/
  w_pos : ∀ x, 0 < w x

/-- The stereographic conformal factor for a point in ℝ^n,
    given by w(x) = 2 / (1 + ‖x‖²). -/
def stereoConformalFactor {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) : ℝ :=
  2 / (1 + ‖x‖ ^ 2)

/-- The denominator in the conformal factor is positive. -/
theorem one_plus_norm_sq_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    (0 : ℝ) < 1 + ‖x‖ ^ 2 := by positivity

/-- The stereographic conformal factor is strictly positive. -/
theorem conformal_factor_pos {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    0 < stereoConformalFactor x :=
  div_pos two_pos (one_plus_norm_sq_pos x)

/-- The stereographic conformal factor is at most 2. -/
theorem conformal_factor_le_two {n : ℕ} (x : EuclideanSpace ℝ (Fin n)) :
    stereoConformalFactor x ≤ 2 := by
  unfold stereoConformalFactor
  rw [div_le_iff₀ (one_plus_norm_sq_pos x)]
  linarith [sq_nonneg ‖x‖]

/-- The conformal factor at the origin equals exactly 2. -/
theorem conformal_factor_at_origin {n : ℕ} :
    stereoConformalFactor (0 : EuclideanSpace ℝ (Fin n)) = 2 := by
  unfold stereoConformalFactor
  simp [norm_zero]

/-- The conformal factor is monotone decreasing in the norm. -/
theorem conformal_factor_antitone {n : ℕ} (x y : EuclideanSpace ℝ (Fin n))
    (h : ‖x‖ ≤ ‖y‖) :
    stereoConformalFactor y ≤ stereoConformalFactor x := by
  unfold stereoConformalFactor
  apply div_le_div_of_nonneg_left (by positivity : (0 : ℝ) ≤ 2)
    (one_plus_norm_sq_pos x)
  have : ‖x‖ ^ 2 ≤ ‖y‖ ^ 2 := sq_le_sq' (by linarith [norm_nonneg x]) h
  linarith

/-- The conformal factor is bounded below when points are in a ball of radius R. -/
theorem conformal_factor_lower_bound {n : ℕ} (x : EuclideanSpace ℝ (Fin n))
    (R : ℝ) (hR : 0 ≤ R) (hx : ‖x‖ ≤ R) :
    2 / (1 + R ^ 2) ≤ stereoConformalFactor x := by
  unfold stereoConformalFactor
  apply div_le_div_of_nonneg_left (by norm_num : (0 : ℝ) ≤ 2) (by positivity)
  have : ‖x‖ ^ 2 ≤ R ^ 2 := sq_le_sq' (by linarith [norm_nonneg x]) hx
  linarith

/-- The stereographic conformal factor gives a valid ConformalWeight. -/
def stereoWeight (n : ℕ) : ConformalWeight (EuclideanSpace ℝ (Fin n)) where
  w := stereoConformalFactor
  w_pos := conformal_factor_pos

/-! ## Part 2: Weighted Distance -/

/-- The conformally weighted distance between two points. -/
def weightedDist {α : Type*} [PseudoMetricSpace α] (cw : ConformalWeight α) (x y : α) : ℝ :=
  cw.w x * cw.w y * dist x y

/-- The weighted distance is nonneg. -/
theorem weightedDist_nonneg {α : Type*} [PseudoMetricSpace α]
    (cw : ConformalWeight α) (x y : α) :
    0 ≤ weightedDist cw x y :=
  mul_nonneg (mul_nonneg (le_of_lt (cw.w_pos x)) (le_of_lt (cw.w_pos y))) dist_nonneg

/-- The weighted distance is symmetric. -/
theorem weightedDist_comm {α : Type*} [PseudoMetricSpace α]
    (cw : ConformalWeight α) (x y : α) :
    weightedDist cw x y = weightedDist cw y x := by
  unfold weightedDist; rw [dist_comm]; ring

/-- The weighted distance from a point to itself is zero. -/
theorem weightedDist_self {α : Type*} [PseudoMetricSpace α]
    (cw : ConformalWeight α) (x : α) :
    weightedDist cw x x = 0 := by
  unfold weightedDist; simp [dist_self]

/-! ## Part 3: Filtered Complexes and Persistence -/

/-- An abstract filtered simplicial complex indexed by ℝ. -/
structure FilteredComplex (V : Type*) where
  /-- Whether a simplex appears at filtration level ε -/
  inFiltration : Finset V → ℝ → Prop
  /-- The filtration is monotone in the parameter -/
  monotone : ∀ (σ : Finset V) (ε₁ ε₂ : ℝ), ε₁ ≤ ε₂ →
    inFiltration σ ε₁ → inFiltration σ ε₂
  /-- The empty simplex is always in the filtration -/
  empty_mem : ∀ ε, inFiltration ∅ ε

/-- The birth time of a simplex in a filtered complex. -/
def birthTime {V : Type*} (F : FilteredComplex V) (σ : Finset V) : ℝ :=
  sInf {ε : ℝ | F.inFiltration σ ε}

/-- A filtration morphism between two filtered complexes. -/
structure FiltrationMorphism {V W : Type*} [DecidableEq W]
    (F : FilteredComplex V) (G : FilteredComplex W) where
  vertexMap : V → W
  preserves : ∀ (σ : Finset V) (ε : ℝ),
    F.inFiltration σ ε → G.inFiltration (σ.image vertexMap) ε
  reflects : ∀ (σ : Finset V) (ε : ℝ),
    G.inFiltration (σ.image vertexMap) ε → F.inFiltration σ ε

/-- A filtration isomorphism induces equality of birth times.
    This is a key structural result: if two filtered complexes
    are isomorphic via a vertex map, their persistence diagrams agree. -/
theorem birth_time_preserved {V W : Type*} [DecidableEq W]
    (F : FilteredComplex V) (G : FilteredComplex W)
    (φ : FiltrationMorphism F G) (σ : Finset V) :
    birthTime F σ = birthTime G (σ.image φ.vertexMap) := by
  unfold birthTime
  congr 1
  ext ε
  exact ⟨φ.preserves σ ε, φ.reflects σ ε⟩

/-! ## Part 4: Čech Complex from a Distance Function -/

/-- The Čech complex of a point cloud with respect to a distance function.
    A simplex σ is in the filtration at level ε if every pair
    of points has distance at most 2ε. -/
def cechComplex {ι : Type*}
    (d : ι → ι → ℝ) : FilteredComplex ι where
  inFiltration σ ε := ∀ i ∈ σ, ∀ j ∈ σ, d i j ≤ 2 * ε
  monotone σ ε₁ ε₂ hle h i hi j hj :=
    le_trans (h i hi j hj) (by linarith)
  empty_mem ε i hi := by simp at hi

/-- Pointwise smaller distances give coarser Čech filtrations. -/
theorem cech_antitone_in_dist {ι : Type*}
    (d₁ d₂ : ι → ι → ℝ) (hle : ∀ i j, d₁ i j ≤ d₂ i j)
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex d₂).inFiltration σ ε →
    (cechComplex d₁).inFiltration σ ε :=
  fun h i hi j hj => le_trans (hle i j) (h i hi j hj)

/-! ## Part 5: Stereographic Weighted Distance -/

/-- The stereographic weighted distance between two points in ℝ^n. -/
def stereoWeightedDist {n : ℕ} (x y : EuclideanSpace ℝ (Fin n)) : ℝ :=
  stereoConformalFactor x * stereoConformalFactor y * dist x y

/-- The stereographic weighted distance is nonnegative. -/
theorem stereoWeightedDist_nonneg {n : ℕ} (x y : EuclideanSpace ℝ (Fin n)) :
    0 ≤ stereoWeightedDist x y :=
  mul_nonneg (mul_nonneg (le_of_lt (conformal_factor_pos x))
    (le_of_lt (conformal_factor_pos y))) dist_nonneg

/-- The stereographic weighted distance is symmetric. -/
theorem stereoWeightedDist_comm {n : ℕ} (x y : EuclideanSpace ℝ (Fin n)) :
    stereoWeightedDist x y = stereoWeightedDist y x := by
  unfold stereoWeightedDist; rw [dist_comm]; ring

/-- The stereographic weighted distance is bounded by 4 · dist. -/
theorem stereoWeightedDist_le_four_dist {n : ℕ} (x y : EuclideanSpace ℝ (Fin n)) :
    stereoWeightedDist x y ≤ 4 * dist x y := by
  unfold stereoWeightedDist
  calc stereoConformalFactor x * stereoConformalFactor y * dist x y
      ≤ 2 * 2 * dist x y := by
        apply mul_le_mul_of_nonneg_right _ dist_nonneg
        exact mul_le_mul (conformal_factor_le_two x) (conformal_factor_le_two y)
          (le_of_lt (conformal_factor_pos y)) (by linarith)
    _ = 4 * dist x y := by ring

/-! ## Part 6: Weighted Čech Complex Containment -/

/-- **Forward containment**: If weight ≤ c for all points, and a simplex is in
    the unweighted Čech filtration at ε/c², then it is in the weighted filtration at ε. -/
theorem weighted_cech_containment {ι : Type*}
    (d : ι → ι → ℝ) (w : ι → ℝ)
    (c : ℝ) (hc : 0 < c)
    (hw_pos : ∀ i, 0 < w i) (hw_upper : ∀ i, w i ≤ c)
    (hd_nonneg : ∀ i j, 0 ≤ d i j)
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex d).inFiltration σ (ε / c ^ 2) →
    (cechComplex (fun i j => w i * w j * d i j)).inFiltration σ ε := by
  intro h i hi j hj
  have hdij := h i hi j hj
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  show w i * w j * d i j ≤ 2 * ε
  calc w i * w j * d i j
      ≤ c * c * d i j := by
        apply mul_le_mul_of_nonneg_right _ (hd_nonneg i j)
        exact mul_le_mul (hw_upper i) (hw_upper j)
          (le_of_lt (hw_pos j)) (by linarith)
    _ = c ^ 2 * d i j := by ring
    _ ≤ c ^ 2 * (2 * (ε / c ^ 2)) := by
        apply mul_le_mul_of_nonneg_left hdij (le_of_lt hc2)
    _ = 2 * ε := by field_simp

/-- **Reverse containment**: If weight ≥ c > 0 for all points, and a simplex is
    in the weighted Čech filtration at ε, then it is in the unweighted filtration
    at ε/c². -/
theorem unweighted_cech_containment {ι : Type*}
    (d : ι → ι → ℝ) (w : ι → ℝ)
    (c : ℝ) (hc : 0 < c)
    (hw_lower : ∀ i, c ≤ w i)
    (hd_nonneg : ∀ i j, 0 ≤ d i j)
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex (fun i j => w i * w j * d i j)).inFiltration σ ε →
    (cechComplex d).inFiltration σ (ε / c ^ 2) := by
  intro h i hi j hj
  have hdij : w i * w j * d i j ≤ 2 * ε := h i hi j hj
  have hc2 : (0 : ℝ) < c ^ 2 := by positivity
  show d i j ≤ 2 * (ε / c ^ 2)
  have key : c ^ 2 * d i j ≤ 2 * ε := calc
    c ^ 2 * d i j = c * c * d i j := by ring
    _ ≤ w i * w j * d i j := by
        apply mul_le_mul_of_nonneg_right _ (hd_nonneg i j)
        exact mul_le_mul (hw_lower i) (hw_lower j)
          (by linarith [hw_lower j]) (by linarith [hw_lower i])
    _ ≤ 2 * ε := hdij
  have h1 : d i j ≤ 2 * ε / c ^ 2 := by
    rw [le_div_iff₀' hc2]; linarith
  linarith [mul_div_assoc (2 : ℝ) ε (c ^ 2)]

/-! ## Part 7: Conformal Isometry Preserves Čech Filtration -/

/-- A conformal isometry preserves the Čech filtration exactly.
    If d₂(f(i), f(j)) = w(i) · w(j) · d₁(i,j), then the weighted Čech
    complex equals the standard Čech complex after applying f. -/
theorem conformal_iso_preserves_cech {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
    (d₁ : ι → ι → ℝ) (d₂ : κ → κ → ℝ) (w : ι → ℝ)
    (f : ι → κ) (_hf : Function.Injective f)
    (hiso : ∀ i j, d₂ (f i) (f j) = w i * w j * d₁ i j)
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex (fun i j => w i * w j * d₁ i j)).inFiltration σ ε ↔
    (cechComplex d₂).inFiltration (σ.image f) ε := by
  constructor
  · intro h k hk l hl
    rw [Finset.mem_image] at hk hl
    obtain ⟨i, hi, rfl⟩ := hk
    obtain ⟨j, hj, rfl⟩ := hl
    rw [hiso]
    exact h i hi j hj
  · intro h i hi j hj
    have h1 := h (f i) (Finset.mem_image_of_mem f hi) (f j) (Finset.mem_image_of_mem f hj)
    rwa [hiso] at h1

/-! ## Part 8: Persistence Module -/

/-- A persistence module tracks Betti numbers across filtration levels. -/
structure PersistenceModule where
  betti : ℝ → ℕ
  eventually_const : ∃ R, ∀ ε₁ ε₂, R ≤ ε₁ → ε₁ ≤ ε₂ → betti ε₁ = betti ε₂

/-- Two persistence modules are equivalent if Betti numbers agree everywhere. -/
def PersistenceModule.equiv (P Q : PersistenceModule) : Prop :=
  ∀ ε, P.betti ε = Q.betti ε

theorem PersistenceModule.equiv_refl (P : PersistenceModule) : P.equiv P :=
  fun _ => rfl

theorem PersistenceModule.equiv_symm {P Q : PersistenceModule}
    (h : P.equiv Q) : Q.equiv P :=
  fun ε => (h ε).symm

theorem PersistenceModule.equiv_trans {P Q R : PersistenceModule}
    (h1 : P.equiv Q) (h2 : Q.equiv R) : P.equiv R :=
  fun ε => (h1 ε).trans (h2 ε)

/-! ## Part 9: Interleaving Distance -/

/-- Two persistence modules are δ-interleaved if their Betti numbers agree
    up to a shift of δ. -/
def PersistenceModule.interleaved (P Q : PersistenceModule) (δ : ℝ) : Prop :=
  (∀ ε, P.betti ε ≤ Q.betti (ε + δ)) ∧ (∀ ε, Q.betti ε ≤ P.betti (ε + δ))

/-- 0-interleaving with self. -/
theorem PersistenceModule.interleaved_self (P : PersistenceModule) :
    P.interleaved P 0 := by
  constructor <;> intro ε <;> simp

/-- **Triangle inequality for the interleaving distance.**
    If P ~δ₁~ Q and Q ~δ₂~ R, then P ~(δ₁+δ₂)~ R.
    This shows interleaving distance is a pseudometric on persistence modules. -/
theorem PersistenceModule.interleaved_triangle {P Q R : PersistenceModule}
    {δ₁ δ₂ : ℝ}
    (h1 : P.interleaved Q δ₁) (h2 : Q.interleaved R δ₂) :
    P.interleaved R (δ₁ + δ₂) := by
  constructor
  · intro ε
    calc P.betti ε ≤ Q.betti (ε + δ₁) := h1.1 ε
      _ ≤ R.betti (ε + δ₁ + δ₂) := h2.1 (ε + δ₁)
      _ = R.betti (ε + (δ₁ + δ₂)) := by ring_nf
  · intro ε
    calc R.betti ε ≤ Q.betti (ε + δ₂) := h2.2 ε
      _ ≤ P.betti (ε + δ₂ + δ₁) := h1.2 (ε + δ₂)
      _ = P.betti (ε + (δ₁ + δ₂)) := by ring_nf

/-! ## Part 10: Main Application — Stereographic Persistence -/

/-- **Stereographic forward containment**: The weighted Čech complex at ε
    contains the unweighted Čech complex at ε/4, using the universal
    bound w(x) ≤ 2. -/
theorem stereo_persistence_forward
    {n : ℕ} {ι : Type*}
    (pts : ι → EuclideanSpace ℝ (Fin n))
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex (fun i j => dist (pts i) (pts j))).inFiltration σ (ε / 4) →
    (cechComplex (fun i j =>
      stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
      dist (pts i) (pts j))).inFiltration σ ε := by
  intro h i hi j hj
  show stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
    dist (pts i) (pts j) ≤ 2 * ε
  have hdij : dist (pts i) (pts j) ≤ 2 * (ε / 4) := h i hi j hj
  have h1 := conformal_factor_le_two (pts i)
  have h2 := conformal_factor_le_two (pts j)
  have hp2 := le_of_lt (conformal_factor_pos (pts j))
  calc stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
        dist (pts i) (pts j)
      ≤ 2 * 2 * dist (pts i) (pts j) := by
        apply mul_le_mul_of_nonneg_right _ dist_nonneg
        exact mul_le_mul h1 h2 hp2 (by linarith)
    _ = 4 * dist (pts i) (pts j) := by ring
    _ ≤ 4 * (2 * (ε / 4)) := by linarith
    _ = 2 * ε := by ring

/-- **Stereographic reverse containment**: For points with bounded norms,
    the unweighted Čech complex at ε/c_min² contains the weighted one at ε. -/
theorem stereo_persistence_reverse
    {n : ℕ} {ι : Type*}
    (pts : ι → EuclideanSpace ℝ (Fin n))
    (R : ℝ) (hR : 0 ≤ R)
    (hpts : ∀ i, ‖pts i‖ ≤ R)
    (σ : Finset ι) (ε : ℝ) :
    (cechComplex (fun i j =>
      stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
      dist (pts i) (pts j))).inFiltration σ ε →
    (cechComplex (fun i j => dist (pts i) (pts j))).inFiltration
      σ (ε / (2 / (1 + R ^ 2)) ^ 2) := by
  intro h i hi j hj
  have hdij : stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
    dist (pts i) (pts j) ≤ 2 * ε := h i hi j hj
  have hcmin : (0 : ℝ) < 2 / (1 + R ^ 2) := by positivity
  have hcmin2 : (0 : ℝ) < (2 / (1 + R ^ 2)) ^ 2 := by positivity
  have hwi := conformal_factor_lower_bound (pts i) R hR (hpts i)
  have hwj := conformal_factor_lower_bound (pts j) R hR (hpts j)
  show dist (pts i) (pts j) ≤ 2 * (ε / (2 / (1 + R ^ 2)) ^ 2)
  have key : (2 / (1 + R ^ 2)) ^ 2 * dist (pts i) (pts j) ≤ 2 * ε := by
    calc (2 / (1 + R ^ 2)) ^ 2 * dist (pts i) (pts j)
        = (2 / (1 + R ^ 2)) * (2 / (1 + R ^ 2)) * dist (pts i) (pts j) := by ring
      _ ≤ stereoConformalFactor (pts i) * stereoConformalFactor (pts j) *
            dist (pts i) (pts j) := by
          apply mul_le_mul_of_nonneg_right _ dist_nonneg
          exact mul_le_mul hwi hwj (by positivity) (le_of_lt (conformal_factor_pos (pts i)))
      _ ≤ 2 * ε := hdij
  have h1 : dist (pts i) (pts j) ≤ 2 * ε / (2 / (1 + R ^ 2)) ^ 2 := by
    rw [le_div_iff₀' hcmin2]; linarith
  linarith [mul_div_assoc (2 : ℝ) ε ((2 / (1 + R ^ 2)) ^ 2)]

/-! ## Part 11: Persistence Pair Structure -/

/-- A persistence diagram entry: a birth-death pair. -/
structure PersistencePair where
  birth : ℝ
  death : ℝ
  birth_le_death : birth ≤ death

/-- The lifetime (persistence) of a topological feature. -/
def PersistencePair.lifetime (p : PersistencePair) : ℝ :=
  p.death - p.birth

/-- Lifetime is always nonneg. -/
theorem PersistencePair.lifetime_nonneg (p : PersistencePair) :
    0 ≤ p.lifetime :=
  sub_nonneg.mpr p.birth_le_death

/-- A persistence pair is significant if its lifetime exceeds a threshold. -/
def PersistencePair.isSignificant (p : PersistencePair) (threshold : ℝ) : Prop :=
  threshold ≤ p.lifetime

/-- Scaling birth and death by a positive constant preserves the ordering. -/
def PersistencePair.scale (p : PersistencePair) (c : ℝ) (hc : 0 < c) :
    PersistencePair where
  birth := c * p.birth
  death := c * p.death
  birth_le_death := mul_le_mul_of_nonneg_left p.birth_le_death (le_of_lt hc)

/-- Scaling multiplies lifetime by the scaling factor. -/
theorem PersistencePair.scale_lifetime (p : PersistencePair) (c : ℝ) (hc : 0 < c) :
    (p.scale c hc).lifetime = c * p.lifetime := by
  unfold lifetime scale; ring

/-- If a pair is significant at threshold t,
    its scaled version is significant at threshold c*t. -/
theorem PersistencePair.scale_significant (p : PersistencePair) (c : ℝ) (hc : 0 < c)
    (t : ℝ) (ht : p.isSignificant t) :
    (p.scale c hc).isSignificant (c * t) := by
  unfold isSignificant at *
  rw [scale_lifetime]
  exact mul_le_mul_of_nonneg_left ht (le_of_lt hc)

/-! ## Conjecture: Optimal Spherical Persistence Separation -/

/-
**Conjecture** (Stereographic Persistence Optimality):
    For any point cloud with minimum separation δ and norms bounded by R,
    the stereographic weighted distance between distinct points is
    at least δ · (2/(1+R²))².

    **Testable prediction**: For N = 100 random points on S² with minimum
    separation δ ≈ 0.2 and R = 2 (after stereographic projection),
    d_w(x,y) ≥ 0.2 · (2/5)² = 0.032 for all pairs.

    This can be falsified by finding a point cloud where the weighted
    distance between some pair is strictly less than δ · c_min².
-/
theorem conjecture_stereo_separation_bound
    {n : ℕ} {ι : Type*}
    (pts : ι → EuclideanSpace ℝ (Fin n))
    (R δ : ℝ) (hR : 0 ≤ R) (_hδ : 0 < δ)
    (hpts_bound : ∀ i, ‖pts i‖ ≤ R)
    (hpts_sep : ∀ i j, i ≠ j → δ ≤ dist (pts i) (pts j)) :
    ∀ i j, i ≠ j →
    δ * (2 / (1 + R ^ 2)) ^ 2 ≤ stereoWeightedDist (pts i) (pts j) := by
  intro i j hij
  refine le_trans ?_ (mul_le_mul_of_nonneg_right
    (mul_le_mul (conformal_factor_lower_bound _ _ hR (hpts_bound i))
      (conformal_factor_lower_bound _ _ hR (hpts_bound j)) ?_ ?_) dist_nonneg)
  · nlinarith [hpts_sep i j hij]
  · positivity
  · exact div_nonneg zero_le_two (add_nonneg zero_le_one (sq_nonneg _))

end StereographicPersistence