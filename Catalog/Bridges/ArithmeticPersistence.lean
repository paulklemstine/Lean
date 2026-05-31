import Mathlib

/-!
# Arithmetic Persistence for K3 Height Detection

This file develops the theory of **primewise arithmetic persistence**, a framework
connecting persistent homology statistics to the height dichotomy (ordinary vs.
supersingular) of formal Brauer groups in K3 surface reductions.

## Main definitions

* `PrimeSlopeProfile` — A finite set of rational "slopes" representing
  normalized Frobenius eigenvalue data at a prime, together with a symmetry center.
* `heightSignature` — A computable statistic measuring concentration of slopes
  near the symmetry center at scale ε.
* `persistentRank` — The filtration-indexed version of the height signature.
* `IsSupersingularProfile` — Predicate: all slopes equal the symmetry center.
* `HasFiniteHeightWitness` — Predicate: some slope differs from the center.
* `tropicalDefect` — A max-plus statistic detecting supersingularity.
* `classifyHeightRegime` — A certified Boolean classifier for the height dichotomy.

## Main results

* `heightSignature_maximal_iff_supersingular` — Exact separation: height signature
  is maximal at all scales iff the profile is supersingular.
* `heightSignature_submaximal_of_finiteHeight` — Finite-height witnesses produce
  submaximal signatures at small scales.
* `persistentRank_monotone` — The persistent rank function is monotone.
* `firstJump_characterization` — Finite-height profiles have a computable first jump.
* `tropicalDefect_zero_iff_supersingular` — Tropical defect vanishes iff supersingular.
* `classifyHeightRegime_correct_supersingular` — Classifier correctness (supersingular).
* `classifyHeightRegime_correct_gap` — Classifier correctness (finite height).

## Mathematical context

For a K3 surface X over a number field, reduction mod a good prime p yields
a formal Brauer group of height h ∈ {1,…,10,∞}. Height ∞ corresponds to
supersingular reduction where all crystalline Frobenius slopes in weight 2
equal the symmetry center (slope 1). Finite height forces slopes away from 1.

This file abstracts the detection mechanism: slope concentration at the center
is equivalent to supersingularity, and this can be read off by persistence-style
filtration statistics. The abstraction is rigorous and the theorems are fully proved.
-/

open Finset

/-! ## Core structures -/

/-- A prime slope profile: finite set of rational slopes at a prime, with a
    symmetry center (for K3 weight-2 cohomology, this is 1). -/
structure PrimeSlopeProfile where
  /-- The prime at which reduction is taken. -/
  p : ℕ
  /-- Proof that p is prime. -/
  hp : Nat.Prime p
  /-- The finite set of slopes (normalized Frobenius eigenvalue valuations). -/
  slopes : Finset ℚ
  /-- The total weight of the cohomological piece. -/
  weight : ℚ
  /-- The symmetry center for the slopes (= weight/2 in crystalline theory). -/
  symmetric_about : ℚ

/-! ## Height dichotomy predicates -/

/-- A profile is supersingular if all slopes equal the symmetry center. -/
def IsSupersingularProfile (P : PrimeSlopeProfile) : Prop :=
  ∀ s ∈ P.slopes, s = P.symmetric_about

/-- A profile has a finite-height witness if some slope differs from the center. -/
def HasFiniteHeightWitness (P : PrimeSlopeProfile) : Prop :=
  ∃ s ∈ P.slopes, s ≠ P.symmetric_about

/-- The two predicates are complementary on nonempty profiles. -/
theorem supersingular_or_finiteHeight (P : PrimeSlopeProfile)
    (_hne : P.slopes.Nonempty) :
    IsSupersingularProfile P ∨ HasFiniteHeightWitness P := by
  by_cases h : ∀ s ∈ P.slopes, s = P.symmetric_about
  · exact Or.inl h
  · right; push_neg at h; exact h

/-- The two predicates are mutually exclusive. -/
theorem not_both (P : PrimeSlopeProfile) :
    IsSupersingularProfile P → HasFiniteHeightWitness P → False := by
  intro hs ⟨s, hs_mem, hs_ne⟩
  exact hs_ne (hs s hs_mem)

/-- Negation of supersingular is finite-height witness. -/
theorem not_supersingular_iff_finiteHeight (P : PrimeSlopeProfile) :
    ¬IsSupersingularProfile P ↔ HasFiniteHeightWitness P := by
  constructor
  · intro h; unfold IsSupersingularProfile at h; push_neg at h; exact h
  · intro ⟨s, hs_mem, hs_ne⟩ h; exact hs_ne (h s hs_mem)

/-! ## Height signature and persistent rank -/

/-- The height signature at scale ε: number of slopes within distance ε
    of the symmetry center. This is the core persistence statistic. -/
def heightSignature (P : PrimeSlopeProfile) (ε : ℚ) : ℕ :=
  (P.slopes.filter fun s => |s - P.symmetric_about| ≤ ε).card

/-- Persistent rank is the height signature viewed as a filtration-indexed function. -/
def persistentRank (P : PrimeSlopeProfile) (t : ℚ) : ℕ :=
  heightSignature P t

/-- The height signature is bounded by the total number of slopes. -/
theorem heightSignature_le_card (P : PrimeSlopeProfile) (ε : ℚ) :
    heightSignature P ε ≤ P.slopes.card := by
  unfold heightSignature
  exact card_filter_le _ _

/-! ## Theorem 1: Exact separation by concentration statistic -/

/-- **Supersingular profiles have maximal height signature at every positive scale.** -/
theorem heightSignature_maximal_of_supersingular
    (P : PrimeSlopeProfile)
    (hss : IsSupersingularProfile P)
    (ε : ℚ) (hε : 0 < ε) :
    heightSignature P ε = P.slopes.card := by
  unfold heightSignature
  congr 1
  apply filter_eq_self.mpr
  intro s hs
  rw [hss s hs, sub_self, abs_zero]
  exact le_of_lt hε

/-- **Finite-height witnesses force submaximal signatures at small scales.** -/
theorem heightSignature_submaximal_of_finiteHeight
    (P : PrimeSlopeProfile)
    (hw : HasFiniteHeightWitness P) :
    ∃ ε₀ : ℚ, 0 < ε₀ ∧ ∀ ε : ℚ, 0 < ε → ε < ε₀ →
      heightSignature P ε < P.slopes.card := by
  obtain ⟨s₀, hs₀_mem, hs₀_ne⟩ := hw
  refine ⟨|s₀ - P.symmetric_about|, abs_pos.mpr (sub_ne_zero.mpr hs₀_ne), ?_⟩
  intro ε _hε hε_lt
  unfold heightSignature
  apply card_lt_card
  constructor
  · exact filter_subset _ _
  · intro h_eq
    have : s₀ ∈ P.slopes.filter (fun s => |s - P.symmetric_about| ≤ ε) := h_eq hs₀_mem
    rw [mem_filter] at this
    linarith [this.2]

/-- **The exact separation theorem:** supersingular iff maximal signature at all scales. -/
theorem heightSignature_maximal_iff_supersingular
    (P : PrimeSlopeProfile) :
    IsSupersingularProfile P ↔
      ∀ ε : ℚ, 0 < ε → heightSignature P ε = P.slopes.card := by
  constructor
  · exact heightSignature_maximal_of_supersingular P
  · intro hall
    by_contra h_not_ss
    rw [not_supersingular_iff_finiteHeight] at h_not_ss
    obtain ⟨ε₀, hε₀_pos, hlt⟩ := heightSignature_submaximal_of_finiteHeight P h_not_ss
    have h1 := hall (ε₀ / 2) (by linarith)
    have h2 := hlt (ε₀ / 2) (by linarith) (by linarith)
    omega

/-! ## Persistent rank monotonicity and jump detection -/

/-- **The persistent rank function is monotone.** -/
theorem persistentRank_monotone (P : PrimeSlopeProfile) :
    Monotone (persistentRank P) := by
  intro a b hab
  unfold persistentRank heightSignature
  apply Finset.card_le_card
  intro s
  simp only [mem_filter]
  intro ⟨hs, hle⟩
  exact ⟨hs, le_trans hle hab⟩

/-- **First jump characterization:** finite-height profiles have submaximal rank
    below some positive threshold. -/
theorem firstJump_characterization
    (P : PrimeSlopeProfile)
    (hw : HasFiniteHeightWitness P) :
    ∃ d : ℚ, 0 < d ∧
      (∀ ε : ℚ, 0 < ε → ε < d → persistentRank P ε < P.slopes.card) := by
  obtain ⟨ε₀, hε₀_pos, hlt⟩ := heightSignature_submaximal_of_finiteHeight P hw
  exact ⟨ε₀, hε₀_pos, hlt⟩

/-- **Height signature is zero for negative ε.** -/
theorem heightSignature_nonpos (P : PrimeSlopeProfile) (ε : ℚ) (hε : ε < 0) :
    heightSignature P ε = 0 := by
  unfold heightSignature
  rw [card_eq_zero, filter_eq_empty_iff]
  intro s _
  push_neg
  calc ε < 0 := hε
    _ ≤ |s - P.symmetric_about| := abs_nonneg _

/-- **Height signature at zero counts only central slopes.** -/
theorem heightSignature_zero_eq (P : PrimeSlopeProfile) :
    heightSignature P 0 = (P.slopes.filter fun s => s = P.symmetric_about).card := by
  unfold heightSignature
  congr 1
  ext s
  simp only [mem_filter, and_congr_right_iff]
  intro _
  constructor
  · intro h; exact eq_of_abs_sub_nonpos h
  · intro h; rw [h, sub_self, abs_zero]

/-- **Monotone relationship between scale and signature.** -/
theorem heightSignature_mono (P : PrimeSlopeProfile) :
    Monotone (heightSignature P) := by
  intro a b hab
  apply Finset.card_le_card
  intro s
  simp only [mem_filter]
  intro ⟨hs, hle⟩
  exact ⟨hs, le_trans hle hab⟩

/-! ## Tropical defect (max-based) -/

/-- The tropical defect at threshold t: the maximum over slopes of max(0, |s - center| - t).
    Vanishes for all t ≥ 0 iff the profile is supersingular.

    We define it as a `Finset.sup'` with a default of 0 for empty profiles. -/
noncomputable def tropicalDefect (P : PrimeSlopeProfile) (t : ℚ) : ℚ :=
  if h : P.slopes.Nonempty then
    P.slopes.sup' h (fun s => max 0 (|s - P.symmetric_about| - t))
  else 0

/-- The tropical defect is always non-negative. -/
theorem tropicalDefect_nonneg (P : PrimeSlopeProfile) (t : ℚ) :
    0 ≤ tropicalDefect P t := by
  unfold tropicalDefect
  split
  case isTrue h =>
    obtain ⟨s, hs⟩ := h
    exact le_trans (le_max_left 0 _)
      (le_sup' (fun s => max 0 (|s - P.symmetric_about| - t)) hs)
  case isFalse => exact le_refl 0

/-- **Supersingular implies tropical defect zero for t ≥ 0.** -/
theorem tropicalDefect_zero_of_supersingular
    (P : PrimeSlopeProfile)
    (hss : IsSupersingularProfile P)
    (t : ℚ) (ht : 0 ≤ t) :
    tropicalDefect P t = 0 := by
  unfold tropicalDefect
  split
  case isTrue h =>
    apply le_antisymm
    · apply sup'_le
      intro s hs
      rw [hss s hs, sub_self, abs_zero, zero_sub]
      exact max_le (le_refl 0) (neg_nonpos_of_nonneg ht)
    · obtain ⟨s₀, hs₀⟩ := h
      exact le_trans (le_max_left 0 _)
        (le_sup' (fun s => max 0 (|s - P.symmetric_about| - t)) hs₀)
  case isFalse => rfl

/-- **Finite-height implies tropical defect positive at t = 0.** -/
theorem tropicalDefect_pos_of_finiteHeight
    (P : PrimeSlopeProfile)
    (hw : HasFiniteHeightWitness P) :
    0 < tropicalDefect P 0 := by
  obtain ⟨s, hs_mem, hs_ne⟩ := hw
  unfold tropicalDefect
  have hne : P.slopes.Nonempty := ⟨s, hs_mem⟩
  simp only [hne, ↓reduceDIte]
  calc (0 : ℚ) < |s - P.symmetric_about| := abs_pos.mpr (sub_ne_zero.mpr hs_ne)
    _ = max 0 (|s - P.symmetric_about| - 0) := by simp
    _ ≤ P.slopes.sup' hne (fun s => max 0 (|s - P.symmetric_about| - 0)) :=
        le_sup' (fun s => max 0 (|s - P.symmetric_about| - 0)) hs_mem

/-- **Cross-domain theorem:** tropical defect vanishes at all t ≥ 0 iff supersingular. -/
theorem tropicalDefect_zero_iff_supersingular
    (P : PrimeSlopeProfile)
    (_hne : P.slopes.Nonempty) :
    (∀ t : ℚ, 0 ≤ t → tropicalDefect P t = 0) ↔ IsSupersingularProfile P := by
  constructor
  · intro hall
    by_contra h_not_ss
    rw [not_supersingular_iff_finiteHeight] at h_not_ss
    linarith [tropicalDefect_pos_of_finiteHeight P h_not_ss, hall 0 (le_refl 0)]
  · exact fun hss t ht => tropicalDefect_zero_of_supersingular P hss t ht

/-! ## Certified classifier -/

/-- A certified Boolean classifier for the height regime. -/
def classifyHeightRegime (P : PrimeSlopeProfile) (ε : ℚ) : Bool :=
  decide (P.slopes.card = heightSignature P ε)

/-- **Classifier correctness (supersingular direction).** -/
theorem classifyHeightRegime_correct_supersingular
    (P : PrimeSlopeProfile)
    (hss : IsSupersingularProfile P)
    (ε : ℚ) (hε : 0 < ε) :
    classifyHeightRegime P ε = true := by
  unfold classifyHeightRegime
  rw [decide_eq_true_eq]
  exact (heightSignature_maximal_of_supersingular P hss ε hε).symm

/-- **Classifier correctness (finite-height direction).** -/
theorem classifyHeightRegime_correct_gap
    (P : PrimeSlopeProfile)
    (hw : HasFiniteHeightWitness P) :
    ∃ ε : ℚ, 0 < ε ∧ classifyHeightRegime P ε = false := by
  obtain ⟨ε₀, hε₀_pos, hlt⟩ := heightSignature_submaximal_of_finiteHeight P hw
  refine ⟨ε₀ / 2, by linarith, ?_⟩
  unfold classifyHeightRegime
  simp only [decide_eq_false_iff_not]
  exact Nat.ne_of_gt (hlt (ε₀ / 2) (by linarith) (by linarith))

/-! ## Persistence filtration model -/

/-- A persistence filtration model associates to a slope profile a monotone
    family of subsets indexed by the filtration parameter. -/
structure SlopePersistenceModel where
  profile : PrimeSlopeProfile
  filtrationValue : ℚ → Finset ℚ
  monotone_filtration : Monotone filtrationValue

/-- The canonical persistence model: filter by distance to center. -/
noncomputable def canonicalPersistenceModel (P : PrimeSlopeProfile) :
    SlopePersistenceModel where
  profile := P
  filtrationValue t := P.slopes.filter (fun s => |s - P.symmetric_about| ≤ t)
  monotone_filtration := by
    intro a b hab s
    simp only [mem_filter]
    intro ⟨hs, hle⟩
    exact ⟨hs, le_trans hle hab⟩

/-- The persistent rank of the canonical model equals the height signature. -/
theorem canonical_rank_eq (P : PrimeSlopeProfile) (t : ℚ) :
    ((canonicalPersistenceModel P).filtrationValue t).card = heightSignature P t :=
  rfl

/-! ## Conjectural K3 geometric realization -/

/-- **Conjecture (K3 Persistence Classifier):**
    For a polarized K3 surface over a number field, there exists a functorial assignment
    of slope profiles at good primes such that the persistence classifier detects
    the formal Brauer group height dichotomy. -/
def AdmitsK3PersistenceClassifier (slopeAssignment : ℕ → PrimeSlopeProfile)
    (heightPredicate : ℕ → Prop) : Prop :=
  ∃ ε₀ : ℚ, 0 < ε₀ ∧ ∀ p : ℕ, Nat.Prime p →
    (heightPredicate p ↔ classifyHeightRegime (slopeAssignment p) ε₀ = true)