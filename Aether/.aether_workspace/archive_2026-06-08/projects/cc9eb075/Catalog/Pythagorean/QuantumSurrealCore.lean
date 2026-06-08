/-
# Quantum Surreal Numbers: Superposition over Non-Archimedean Fields

This module develops the theory of quantum states over graded basis sets,
modeling the interaction between quantum superposition and non-Archimedean
structure. The key insight: when basis elements carry a "scale" (modeling
surreal number birthdays or infinitesimal orders), the Born rule probability
splits into an observable part and an infinitesimal "dark probability" that
vanishes under the standard part map.

## Main Results

* `QState` — Quantum state over a finite basis with real amplitudes
* `ScaleDecomp` — Decomposition of basis into observable and infinitesimal sectors
* `prob_conservation` — Observable + infinitesimal probability = 1
* `observable_prob_le_one` — Observable probability is at most 1
* `observable_eq_one_iff_no_infinitesimal` — Characterization of fully observable states
* `BoolProjection` — Boolean-valued projection operators
* `born_rule_complementary` — Complementary projections exhaust probability
* `post_measurement_normalized` — Post-measurement states are properly normalized
-/

import Mathlib

open Finset BigOperators

/-! ## Section 1: Quantum States -/

/-- A quantum state over `Fin n` with real amplitudes satisfying the Born rule
normalization: ∑ᵢ |αᵢ|² = 1. This models a pure quantum state in an
n-dimensional Hilbert space. -/
structure QState (n : ℕ) where
  /-- Amplitude function assigning a real amplitude to each basis state -/
  amp : Fin n → ℝ
  /-- Born rule normalization: total probability equals 1 -/
  normalized : ∑ i : Fin n, (amp i) ^ 2 = 1

/-! ## Section 2: Scale Decomposition (Non-Archimedean Grading) -/

/-- A scale decomposition partitions the basis `Fin n` into two sectors:
- **Observable sector**: basis states at finite (standard) scale
- **Infinitesimal sector**: basis states at infinitesimal scale

This models the key structure of quantum surreal numbers: surreal-valued
basis elements are classified by whether their "birthday" (Conway's
construction day) yields an observable or infinitesimal contribution. -/
structure ScaleDecomp (n : ℕ) where
  /-- Predicate identifying observable (finite-scale) basis elements -/
  isObservable : Fin n → Bool

/-- The set of observable basis indices -/
def ScaleDecomp.obsSet (s : ScaleDecomp n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => s.isObservable i = true)

/-- The set of infinitesimal basis indices -/
def ScaleDecomp.infSet (s : ScaleDecomp n) : Finset (Fin n) :=
  Finset.univ.filter (fun i => s.isObservable i = false)

/-- Observable probability: the total Born-rule probability concentrated
in the observable sector. -/
def observableProb (ψ : QState n) (s : ScaleDecomp n) : ℝ :=
  ∑ i ∈ s.obsSet, (ψ.amp i) ^ 2

/-- Infinitesimal probability: the total Born-rule probability concentrated
in the infinitesimal sector. -/
def infinitesimalProb (ψ : QState n) (s : ScaleDecomp n) : ℝ :=
  ∑ i ∈ s.infSet, (ψ.amp i) ^ 2

/-- The observable and infinitesimal sets are disjoint -/
theorem obs_inf_disjoint (s : ScaleDecomp n) :
    Disjoint s.obsSet s.infSet := by
  simp only [ScaleDecomp.obsSet, ScaleDecomp.infSet]
  exact Finset.disjoint_filter.mpr (fun x _ h1 h2 => by simp_all)

/-- The observable and infinitesimal sets cover all of `Fin n` -/
theorem obs_inf_union (s : ScaleDecomp n) :
    s.obsSet ∪ s.infSet = Finset.univ := by
  ext x; simp [ScaleDecomp.obsSet, ScaleDecomp.infSet]

/-! ### Theorem 1: Probability Conservation -/

/-
Observable probability plus infinitesimal probability equals 1.
This is the quantum surreal analogue of unitarity.
-/
theorem prob_conservation (ψ : QState n) (s : ScaleDecomp n) :
    observableProb ψ s + infinitesimalProb ψ s = 1 := by
  rw [ ← ψ.normalized, observableProb, infinitesimalProb, ← Finset.sum_union ];
  · rw [ obs_inf_union ];
  · exact obs_inf_disjoint s

/-! ### Theorem 2: Observable Probability Bound -/

theorem observable_prob_le_one (ψ : QState n) (s : ScaleDecomp n) :
    observableProb ψ s ≤ 1 := by
  -- By definition of observable probability, we have observableProb ψ s = ∑ i ∈ s.obsSet, (ψ.amp i) ^ 2.
  rw [← prob_conservation ψ s];
  exact le_add_of_nonneg_right ( Finset.sum_nonneg fun _ _ => sq_nonneg _ )

/-! ### Theorem 3: Characterization of Fully Observable States -/

/-
A quantum state has observable probability exactly 1 if and only if
all infinitesimal-sector amplitudes vanish.
-/
theorem observable_eq_one_iff_no_infinitesimal (ψ : QState n) (s : ScaleDecomp n) :
    observableProb ψ s = 1 ↔
    (∀ i, s.isObservable i = false → ψ.amp i = 0) := by
  constructor;
  · intro h i hi
    have h_inf_zero : infinitesimalProb ψ s = 0 := by
      linarith [ prob_conservation ψ s ];
    exact sq_eq_zero_iff.mp ( by rw [ show infinitesimalProb ψ s = ∑ i ∈ Finset.univ.filter ( fun i => s.isObservable i = false ), ( ψ.amp i ) ^ 2 by rfl ] at h_inf_zero; exact Finset.sum_eq_zero_iff_of_nonneg ( fun _ _ => sq_nonneg _ ) |>.1 h_inf_zero i ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ) );
  · intro h
    have h_sum : ∑ i, (ψ.amp i) ^ 2 = ∑ i ∈ s.obsSet, (ψ.amp i) ^ 2 := by
      rw [ ← Finset.sum_subset ( Finset.subset_univ s.obsSet ) ];
      unfold ScaleDecomp.obsSet; aesop;
    exact h_sum.symm.trans ψ.normalized

/-! ### Non-negativity of sector probabilities -/

theorem observable_prob_nonneg (ψ : QState n) (s : ScaleDecomp n) :
    0 ≤ observableProb ψ s := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem infinitesimal_prob_nonneg (ψ : QState n) (s : ScaleDecomp n) :
    0 ≤ infinitesimalProb ψ s := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ## Section 3: Projection Operators and Measurement -/

/-- A Boolean projection on `Fin n`: each basis element is either fully
projected (kept) or fully annihilated (removed). -/
structure BoolProjection (n : ℕ) where
  /-- Which basis elements survive the projection -/
  keep : Fin n → Bool

/-- The complement of a Boolean projection -/
def BoolProjection.complement (P : BoolProjection n) : BoolProjection n where
  keep := fun i => !P.keep i

/-- Apply a Boolean projection to a state's amplitudes -/
def BoolProjection.apply (P : BoolProjection n) (ψ : QState n) : Fin n → ℝ :=
  fun i => if P.keep i then ψ.amp i else 0

/-- Born-rule probability of a measurement outcome -/
def measureProb (P : BoolProjection n) (ψ : QState n) : ℝ :=
  ∑ i : Fin n, (P.apply ψ i) ^ 2

/-! ### Theorem 4: Complementary Projections Exhaust Probability -/

/-
For any Boolean projection P, the probability of outcome P plus the
probability of outcome ¬P equals 1.
-/
theorem born_rule_complementary (P : BoolProjection n) (ψ : QState n) :
    measureProb P ψ + measureProb P.complement ψ = 1 := by
  unfold measureProb; simp +decide [ BoolProjection.complement ] ; ring;
  rw [ ← Finset.sum_add_distrib, eq_comm ];
  convert ψ.normalized.symm using 2 ; unfold BoolProjection.apply ; aesop

/-! ### Theorem 5: Measurement Probability Bounds -/

theorem measure_prob_le_one (P : BoolProjection n) (ψ : QState n) :
    measureProb P ψ ≤ 1 := by
  exact le_trans ( Finset.sum_le_sum fun i _ => show ( if P.keep i then ψ.amp i else 0 ) ^ 2 ≤ ψ.amp i ^ 2 by split_ifs <;> nlinarith ) ( by linarith [ ψ.normalized ] )

theorem measure_prob_nonneg (P : BoolProjection n) (ψ : QState n) :
    0 ≤ measureProb P ψ := by
  exact Finset.sum_nonneg fun _ _ => sq_nonneg _

/-! ### Post-measurement normalization -/

/-- The squared norm of a projected state equals the measurement probability -/
def projectedNormSq (P : BoolProjection n) (ψ : QState n) : ℝ :=
  ∑ i : Fin n, (P.apply ψ i) ^ 2

/-- Post-measurement state: the projected state renormalized. -/
noncomputable def postMeasurementAmp (P : BoolProjection n) (ψ : QState n)
    (_hP : projectedNormSq P ψ ≠ 0) : Fin n → ℝ :=
  fun i => P.apply ψ i / Real.sqrt (projectedNormSq P ψ)

/-! ### Theorem 6: Post-Measurement Normalization -/

/-
After measurement and renormalization, the resulting state is properly
normalized. This is the projection postulate of quantum mechanics.
-/
theorem post_measurement_normalized (P : BoolProjection n) (ψ : QState n)
    (hP : projectedNormSq P ψ > 0) :
    ∑ i : Fin n, (postMeasurementAmp P ψ (ne_of_gt hP) i) ^ 2 = 1 := by
  unfold postMeasurementAmp;
  norm_num [ div_pow, ← Finset.sum_div _ _ _, hP.le, ne_of_gt hP ];
  exact div_self hP.ne'

/-! ## Section 4: The Infinitesimal Sector is Unobservable -/

/-- The projection onto the observable sector -/
def observableProjection (s : ScaleDecomp n) : BoolProjection n where
  keep := s.isObservable

/-- The projection onto the infinitesimal sector -/
def infinitesimalProjection (s : ScaleDecomp n) : BoolProjection n where
  keep := fun i => !s.isObservable i

/-- The observable and infinitesimal projections are complementary -/
theorem obs_inf_complementary (s : ScaleDecomp n) :
    (observableProjection s).complement = infinitesimalProjection s := by
  simp [BoolProjection.complement, observableProjection, infinitesimalProjection]

/-! ### Theorem 7: Measurement probability equals sector probability -/

theorem measure_prob_eq_observable (ψ : QState n) (s : ScaleDecomp n) :
    measureProb (observableProjection s) ψ = observableProb ψ s := by
  unfold measureProb observableProb observableProjection;
  simp +decide [ ScaleDecomp.obsSet, BoolProjection.apply ];
  rw [ Finset.sum_filter ]

theorem measure_prob_eq_infinitesimal (ψ : QState n) (s : ScaleDecomp n) :
    measureProb (infinitesimalProjection s) ψ = infinitesimalProb ψ s := by
  unfold measureProb infinitesimalProb infinitesimalProjection;
  unfold BoolProjection.apply ScaleDecomp.infSet; simp +decide [ Finset.sum_ite ] ;

/-! ## Section 5: Quantum Probability Defect -/

/-- The probability defect: how much probability is lost to infinitesimal modes -/
def probDefect (ψ : QState n) (s : ScaleDecomp n) : ℝ :=
  1 - observableProb ψ s

/-! ### Theorem 8: Probability defect equals infinitesimal probability -/

theorem prob_defect_eq_infinitesimal (ψ : QState n) (s : ScaleDecomp n) :
    probDefect ψ s = infinitesimalProb ψ s := by
  exact sub_eq_iff_eq_add'.mpr ( by linarith [ prob_conservation ψ s ] )

theorem prob_defect_nonneg (ψ : QState n) (s : ScaleDecomp n) :
    0 ≤ probDefect ψ s := by
  exact sub_nonneg_of_le ( observable_prob_le_one ψ s )

/-! ### Theorem 9: Defect vanishes iff state is fully observable -/

theorem prob_defect_zero_iff (ψ : QState n) (s : ScaleDecomp n) :
    probDefect ψ s = 0 ↔ (∀ i, s.isObservable i = false → ψ.amp i = 0) := by
  rw [ probDefect, sub_eq_zero ];
  rw [ eq_comm, observable_eq_one_iff_no_infinitesimal ]

/-! ## Section 6: Quantum Surreal Inner Product -/

/-- Inner product of two quantum states -/
def qInnerProduct (ψ φ : QState n) : ℝ :=
  ∑ i : Fin n, ψ.amp i * φ.amp i

/-
Self-inner-product equals 1 (from normalization)
-/
theorem self_inner_product (ψ : QState n) :
    qInnerProduct ψ ψ = 1 := by
  convert ψ.normalized using 1;
  exact Finset.sum_congr rfl fun _ _ => by ring;

/-! ### Theorem 10: Cauchy-Schwarz for normalized quantum states -/

/-
The inner product of two normalized quantum states is bounded by 1
in absolute value. This is Cauchy-Schwarz specialized to the quantum setting.
-/
theorem quantum_cauchy_schwarz (ψ φ : QState n) :
    (qInnerProduct ψ φ) ^ 2 ≤ 1 := by
  -- Apply the Cauchy-Schwarz inequality: (∑ aᵢbᵢ)² ≤ (∑ aᵢ²)(∑ bᵢ²).
  have h_cauchy_schwarz : (∑ i, ψ.amp i * φ.amp i) ^ 2 ≤ (∑ i, (ψ.amp i) ^ 2) * (∑ i, (φ.amp i) ^ 2) := by
    exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  exact h_cauchy_schwarz.trans ( by rw [ ψ.normalized, φ.normalized ] ; norm_num )

/-! ## Section 7: Observable Overlap -/

/-- Observable inner product: inner product restricted to observable sector -/
def obsInnerProduct (ψ φ : QState n) (s : ScaleDecomp n) : ℝ :=
  ∑ i ∈ s.obsSet, ψ.amp i * φ.amp i

/-! ### Theorem 11: Observable Cauchy-Schwarz -/

/-
The observable overlap between two states is bounded by the geometric
mean of their observable probabilities. This is Cauchy-Schwarz restricted
to the observable sector.
-/
theorem obs_cauchy_schwarz (ψ φ : QState n) (s : ScaleDecomp n) :
    (obsInnerProduct ψ φ s) ^ 2 ≤ observableProb ψ s * observableProb φ s := by
  unfold obsInnerProduct observableProb;
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _