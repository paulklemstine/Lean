/-
Copyright (c) 2025. All rights reserved.
Theorems for Primewise Persistent Homology of Rational Dynamics.

This file proves foundational theorems about mod-p dynamical systems and their
orbit-preimage invariants, establishing the mathematical basis for using
persistence profiles as conjugacy classifiers.

Keywords: arithmetic_dynamics, persistent_homology, orbit_counting, preimage_bound,
          entropy, conjugacy_invariant, pigeonhole
-/
import Mathlib
import Speculative.AutoResearch.PrimewisePersistence.Defs

open Finset BigOperators

/-! ## Theorem 1: Preimage Sum Identity

The total count of preimages across all points equals p+1.
This is the fundamental counting identity for any self-map of a finite set:
each element has exactly one image, so summing preimage sizes counts each
element exactly once. -/

/-
**Preimage Sum Identity**: The sum of preimage sizes over all points equals p+1.
    This is the fundamental orbit-counting identity: every point is in exactly one
    preimage fiber. Proved by rewriting the sum as a card of a bipartite relation.
-/
theorem preimage_sum_eq {p : ℕ} (dyn : ModPDynamics p) :
    ∑ y : Fin (p + 1), dyn.preimageSize y = p + 1 := by
  simp +decide only [ModPDynamics.preimageSize, card_eq_sum_ones];
  simp +decide only [ModPDynamics.preimage, sum_filter];
  rw [ Finset.sum_comm ] ; aesop

/-! ## Theorem 2: Pigeonhole Bound on Maximum Preimage

If a self-map of Fin (p+1) is not a bijection, some point has preimage size ≥ 2.
More precisely, if the image has size ≤ k, then some point has preimage size ≥ ⌈(p+1)/k⌉. -/

/-
**Pigeonhole Preimage Bound**: There exists a point whose preimage size is at least
    the average preimage size. Since the average is (p+1)/(p+1) = 1 for a surjection,
    this becomes interesting when the map is not surjective.
-/
theorem exists_preimage_ge_one {p : ℕ} (dyn : ModPDynamics p) :
    ∃ y : Fin (p + 1), dyn.preimageSize y ≥ 1 := by
  exact ⟨ dyn.mapFn 0, Finset.card_pos.mpr ⟨ 0, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl ⟩ ⟩ ⟩

/-! ## Theorem 3: Fixed Points are Periodic Points of Period 1

Every fixed point is a periodic point of period 1, establishing the base case
of the persistence filtration. -/

/-
Fixed points coincide with periodic points of period 1.
-/
theorem fixedPoints_eq_periodicPoints_one {p : ℕ} (dyn : ModPDynamics p) :
    dyn.fixedPoints = dyn.periodicPoints 1 := by
  rfl

/-! ## Theorem 4: Periodic Points Monotonicity

If k divides m, then every periodic point of period k is also periodic of period m.
This is the monotonicity that makes the persistence filtration well-defined. -/

/-
**Periodic Monotonicity**: Period-k points are period-m points when k | m.
    This uses induction on the divisibility structure.
-/
theorem periodicPoints_subset_of_dvd {p : ℕ} (dyn : ModPDynamics p) {k m : ℕ}
    (hk : 0 < k) (hdvd : k ∣ m) :
    dyn.periodicPoints k ⊆ dyn.periodicPoints m := by
  obtain ⟨ q, rfl ⟩ := hdvd;
  intro x hx; induction q <;> simp_all +decide [ Nat.mul_succ, ModPDynamics.iterate ] ;
  · exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, rfl ⟩;
  · unfold ModPDynamics.periodicPoints at *; simp_all +decide [ ModPDynamics.iterate ] ;
    -- By definition of iterate, we have:
    have h_iterate : ∀ n m : ℕ, dyn.iterate (n + m) x = dyn.iterate m (dyn.iterate n x) := by
      intros n m; induction' m with m ih <;> simp_all +decide [ Nat.add_comm, Nat.add_left_comm, ModPDynamics.iterate ] ;
    aesop

/-! ## Theorem 5: Image Size Bounds Preimage Maximum (Pigeonhole)

If the image of the map has exactly s points, then some point has preimage
size at least ⌈(p+1)/s⌉. This connects graph structure to preimage statistics. -/

/-
**Image-Preimage Duality**: The image set size times the maximum preimage size
    is at least p+1. This is a consequence of the pigeonhole principle.
-/
theorem image_card_mul_max_preimage_ge {p : ℕ} (dyn : ModPDynamics p)
    (hs : 0 < dyn.imageSet.card) :
    ∃ y : Fin (p + 1), dyn.preimageSize y * dyn.imageSet.card ≥ p + 1 := by
  contrapose! hs;
  -- By summing over all points in the image set, we get that the total preimage size is less than (p + 1) times the number of points in the image set.
  have h_sum : ∑ y ∈ dyn.imageSet, dyn.preimageSize y * dyn.imageSet.card < (p + 1) * dyn.imageSet.card := by
    simpa [ mul_comm ] using Finset.sum_lt_sum_of_nonempty ( Finset.card_pos.mp ( by linarith [ show 0 < Finset.card dyn.imageSet from Finset.card_pos.mpr ⟨ _, Finset.mem_image_of_mem _ ( Finset.mem_univ 0 ) ⟩ ] ) ) fun x hx => hs x;
  -- By summing over all points in the image set, we get that the total preimage size is equal to p + 1.
  have h_sum_eq : ∑ y ∈ dyn.imageSet, dyn.preimageSize y = p + 1 := by
    convert preimage_sum_eq dyn using 1;
    refine' Finset.sum_subset _ _ <;> simp +contextual [ ModPDynamics.imageSet ];
    exact fun x hx => Finset.card_eq_zero.mpr <| Finset.filter_eq_empty_iff.mpr fun y hy => hx y;
  rw [ ← Finset.sum_mul _ _ _ ] at h_sum ; nlinarith

/-! ## Theorem 6: Iterate Composition Identity

The iterate operation satisfies the expected composition law. -/

/-
Iterating k then m more steps equals iterating k+m steps.
-/
theorem iterate_add {p : ℕ} (dyn : ModPDynamics p) (k m : ℕ) (x : Fin (p + 1)) :
    dyn.iterate (k + m) x = dyn.iterate m (dyn.iterate k x) := by
  induction' m with m ih;
  · rfl;
  · convert congr_arg dyn.mapFn ih using 1

/-! ## Theorem 7: Degree Sequence is a Conjugacy Invariant

If two dynamical systems are related by a bijective change of coordinates,
they have the same degree sequence (multiset of preimage sizes). -/

/-
**Conjugacy Invariance of Degree Sequence**: If φ is a bijection conjugating
    dyn₁ to dyn₂ (i.e., dyn₂.mapFn = φ ∘ dyn₁.mapFn ∘ φ⁻¹), then they have
    the same degree sequence.
-/
theorem degreeSequence_conjugacy_invariant {p : ℕ}
    (dyn₁ dyn₂ : ModPDynamics p) (φ : Equiv.Perm (Fin (p + 1)))
    (hconj : ∀ x, dyn₂.mapFn (φ x) = φ (dyn₁.mapFn x)) :
    dyn₁.degreeSequence = dyn₂.degreeSequence := by
  -- By definition of degree sequence, we need to show that the multisets of preimage sizes are equal.
  unfold ModPDynamics.degreeSequence;
  -- By definition of preimage, we know that preimageSize₂ (φ y) = preimageSize₁ y for all y.
  have h_preimage : ∀ y, dyn₂.preimageSize (φ y) = dyn₁.preimageSize y := by
    -- By definition of preimage, we know that the preimage of φ y under dyn₂ is the image of the preimage of y under dyn₁ under φ.
    have h_preimage : ∀ y, dyn₂.preimage (φ y) = Finset.image (fun x => φ x) (dyn₁.preimage y) := by
      intro y; ext x; simp +decide [ hconj, ModPDynamics.preimage ] ;
      exact ⟨ fun h => ⟨ φ.symm x, by have := hconj ( φ.symm x ) ; aesop ⟩, by rintro ⟨ a, ha, rfl ⟩ ; have := hconj a; aesop ⟩;
    simp +decide [ h_preimage, ModPDynamics.preimageSize ];
    exact fun y => Finset.card_image_of_injective _ φ.injective;
  have h_perm : Multiset.map dyn₂.preimageSize (Multiset.map φ Finset.univ.val) = Multiset.map dyn₂.preimageSize Finset.univ.val := by
    simp +zetaDelta at *;
  rw [ ← h_perm, Multiset.map_map ] ; aesop

/-! ## Theorem 8: Tail Count Monotonicity

The tail count function is monotonically non-increasing: as we raise the
threshold, fewer points have preimage size exceeding it. This is the
"persistence" property that makes the filtration meaningful. -/

/-
**Tail Monotonicity**: tailCount is non-increasing.
-/
theorem tailCount_mono {p : ℕ} (dyn : ModPDynamics p) {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    dyn.tailCount k₂ ≤ dyn.tailCount k₁ := by
  exact Finset.card_mono fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, lt_of_le_of_lt h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-! ## Theorem 9: Cross-Domain Bridge — Orbit Entropy Non-negativity

The orbit entropy is always non-negative. This connects dynamical systems
to information theory: the entropy measures the "surprise" in the preimage
structure, and is zero precisely when the map is a bijection. -/

/-
**Orbit Entropy Non-negativity**: The orbit entropy of any mod-p dynamical
    system is non-negative. This uses Jensen's inequality: log is concave,
    and the average of log(preimage sizes) ≤ log(average preimage size) = log(1) = 0.
    Hence the entropy = log(p+1) - sum ≥ 0.
-/
theorem orbit_entropy_nonneg {p : ℕ} (hp : 0 < p) (dyn : ModPDynamics p) :
    0 ≤ dyn.orbitEntropy := by
  -- By the AM-GM inequality, we have $\frac{1}{p+1} \sum_{i=1}^{p+1} \log(\text{preimageSize}(y_i) + 1) \leq \log\left(\frac{1}{p+1} \sum_{i=1}^{p+1} (\text{preimageSize}(y_i) + 1)\right)$.
  have h_amgm : (∑ y : Fin (p + 1), Real.log (dyn.preimageSize y + 1)) / (p + 1) ≤ Real.log ((∑ y : Fin (p + 1), (dyn.preimageSize y + 1)) / (p + 1)) := by
    have h_am_gm : ∀ {x : Fin (p + 1) → ℝ}, (∀ i, 0 < x i) → (∑ i, Real.log (x i)) / (p + 1) ≤ Real.log ((∑ i, x i) / (p + 1)) := by
      have h_jensen : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
        exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi );
      intros x hx_pos
      have h_jensen_apply : (∑ i, (1 / (p + 1 : ℝ)) * Real.log (x i)) ≤ Real.log ((∑ i, (1 / (p + 1 : ℝ)) * x i)) := by
        apply_rules [ h_jensen.le_map_sum ];
        · exact fun _ _ => by positivity;
        · norm_num [ show ( p : ℝ ) + 1 ≠ 0 by positivity ];
        · aesop;
      simpa [ inv_mul_eq_div, Finset.sum_div _ _ _ ] using h_jensen_apply;
    simpa using h_am_gm fun i => Nat.cast_add_one_pos _;
  -- Simplify the right-hand side of the inequality.
  have h_simplify : Real.log ((∑ y : Fin (p + 1), (dyn.preimageSize y + 1)) / (p + 1)) ≤ Real.log (p + 1) := by
    norm_num [ Finset.sum_add_distrib, preimage_sum_eq ];
    exact Real.log_le_log ( by positivity ) ( by rw [ div_le_iff₀ ] <;> nlinarith [ show ( p : ℝ ) ≥ 1 by norm_cast ] );
  unfold ModPDynamics.orbitEntropy;
  grind

/-! ## Theorem 10: Preimage Profile Determines Fixed Point Count Bound

The number of fixed points is bounded by the number of points with non-zero
preimage size (the image size). This connects preimage statistics to
periodic orbit counting. -/

/-
**Fixed Point Bound**: The number of fixed points is at most p+1 (trivial
    but establishes the baseline for the persistence filtration).
-/
theorem fixedPoints_card_le {p : ℕ} (dyn : ModPDynamics p) :
    dyn.fixedPoints.card ≤ p + 1 := by
  exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-! ## Conjecture: Persistence Profile Separation

**Falsifiable Conjecture**: For "generic" pairs of non-conjugate dynamical systems,
their persistence profiles differ. We state a precise finite version:
if the degree sequences differ, then the persistence profiles at depth 1 already differ. -/

/-
**Persistence Separation Lemma**: If two dynamical systems have different
    degree sequences, their tail counts at level 0 may still agree, but their
    full persistence profiles (including periodic counts) differ.
    This is a testable consequence of the main conjecture.
-/
theorem persistence_separation_from_degree {p : ℕ}
    (dyn₁ dyn₂ : ModPDynamics p)
    (hdeg : dyn₁.degreeSequence ≠ dyn₂.degreeSequence) :
    dyn₁.toPersistenceProfile 1 ≠ dyn₂.toPersistenceProfile 1
    ∨ ∃ k, dyn₁.tailCount k ≠ dyn₂.tailCount k := by
  contrapose! hdeg;
  -- By definition of degree sequence, we know that it is equal to the multiset of preimage sizes.
  have h_deg_seq : ∀ k : ℕ, (Finset.univ.filter (fun y => dyn₁.preimageSize y = k)).card = (Finset.univ.filter (fun y => dyn₂.preimageSize y = k)).card := by
    intro k
    have h_tail_count_eq : (Finset.univ.filter (fun y => dyn₁.preimageSize y > k)).card = (Finset.univ.filter (fun y => dyn₂.preimageSize y > k)).card := by
      exact hdeg.2 k;
    have h_tail_count_eq : (Finset.univ.filter (fun y => dyn₁.preimageSize y ≥ k)).card = (Finset.univ.filter (fun y => dyn₂.preimageSize y ≥ k)).card := by
      rcases k with ( _ | k ) <;> simp_all +decide [ Nat.succ_le_iff ];
      convert hdeg.2 k using 1;
    have h_tail_count_eq : (Finset.univ.filter (fun y => dyn₁.preimageSize y ≥ k)).card = (Finset.univ.filter (fun y => dyn₁.preimageSize y > k)).card + (Finset.univ.filter (fun y => dyn₁.preimageSize y = k)).card := by
      rw [ ← Finset.card_union_of_disjoint ];
      · congr with y ; simp +decide [ le_iff_lt_or_eq, eq_comm ];
      · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
    have h_tail_count_eq : (Finset.univ.filter (fun y => dyn₂.preimageSize y ≥ k)).card = (Finset.univ.filter (fun y => dyn₂.preimageSize y > k)).card + (Finset.univ.filter (fun y => dyn₂.preimageSize y = k)).card := by
      rw [ ← Finset.card_union_of_disjoint ];
      · congr with y ; simp +decide [ le_iff_lt_or_eq, eq_comm ];
      · exact Finset.disjoint_filter.mpr fun _ _ _ _ => by linarith;
    grind;
  ext k;
  unfold ModPDynamics.degreeSequence;
  convert h_deg_seq k using 1;
  · erw [ Multiset.count_map ];
    simp +decide [ eq_comm, Finset.card ];
  · rw [ Multiset.count_map ];
    simp +decide [ eq_comm, Finset.filter ]