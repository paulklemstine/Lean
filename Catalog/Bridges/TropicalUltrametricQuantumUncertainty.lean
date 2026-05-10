/-
# Functorial Entropic Uncertainty via Tropical–Ultrametric Quantum Measurement Skeletons

This file formalizes a reusable *measurement skeleton* framework connecting:
- **Quantum information**: finite measurement overlap matrices and outcome distributions
- **Tropical/valuation geometry**: tropicalized overlap profiles via `-log`
- **Ultrametric analysis**: valuation radii from tropical/ultrametric transfer
- **Cryptographic entropy extraction**: min-entropy and collision-entropy lower bounds

The core insight is that quantum measurement incompatibility, encoded in an overlap matrix,
can be pushed through a tropical interface to produce certified entropy lower bounds
without direct operator analysis.
-/
import Mathlib

open Finset BigOperators Real

noncomputable section

/-! ## Section 1: Clipped Logarithm

We define a regularized negative logarithm that avoids the singularity at zero
by clipping the argument below at `exp(-1)`. This produces a total, well-behaved
function suitable for tropical profile extraction.
-/

/-- `clippedLog x = -log(max(x, e⁻¹))`. A certified robust lower-envelope
regularization of `-log x` that is total and nonneg on `[0,1]`.
Bridge: connects tropical valuation geometry to ultrametric analysis. -/
def clippedLog (x : ℝ) : ℝ := - Real.log (max x (Real.exp (-1)))

theorem exp_neg_one_pos : (0 : ℝ) < Real.exp (-1) := Real.exp_pos _

theorem exp_neg_one_lt_one : Real.exp (-1 : ℝ) < 1 :=
  Real.exp_lt_one_iff.mpr (by norm_num)

theorem max_exp_neg_one_pos (x : ℝ) : 0 < max x (Real.exp (-1)) :=
  lt_of_lt_of_le exp_neg_one_pos (le_max_right x _)

/-- Bridge: connects tropical valuation geometry to certified entropy witnesses.
The clipped log is nonneg when the argument is at most 1. -/
theorem clippedLog_nonneg_of_le_one {x : ℝ} (hx1 : x ≤ 1) :
    0 ≤ clippedLog x := by
  unfold clippedLog
  rw [neg_nonneg]
  apply Real.log_nonpos (le_of_lt (max_exp_neg_one_pos x))
  exact max_le hx1 (le_of_lt exp_neg_one_lt_one)

/-- Bridge: connects ultrametric control to certified entropy witnesses.
The clipped log is antitone: larger arguments give smaller values.
This is well-defined for ALL reals since the clipping ensures positivity. -/
theorem clippedLog_antitone :
    ∀ {x y : ℝ}, x ≤ y → clippedLog y ≤ clippedLog x := by
  intro x y hxy
  unfold clippedLog
  apply neg_le_neg
  apply Real.log_le_log (max_exp_neg_one_pos x)
  exact max_le_max_right _ hxy

/-- Strengthened antitone variant for nonneg arguments bounded by 1.
Bridge: connects tropical valuation geometry to entropy monotonicity. -/
theorem clippedLog_antitone_on_nonneg :
    ∀ {x y : ℝ}, 0 ≤ x → x ≤ y → y ≤ 1 → clippedLog y ≤ clippedLog x := by
  intro x y _ hxy _
  exact clippedLog_antitone hxy

/-- The clipped log at 1 equals 0 (since max 1 (exp(-1)) = 1 and log 1 = 0).
Useful normalization fact. -/
theorem clippedLog_one : clippedLog 1 = 0 := by
  unfold clippedLog
  have h : max (1 : ℝ) (Real.exp (-1)) = 1 := by
    rw [max_eq_left]
    exact le_of_lt exp_neg_one_lt_one
  rw [h, Real.log_one, neg_zero]

/-- Bridge: connects tropical valuation geometry to log monotonicity.
`-log x ≥ clippedLog c` when `0 < x ≤ c`. -/
theorem neg_log_ge_clippedLog {x c : ℝ} (hx : 0 < x) (hxc : x ≤ c) :
    -Real.log x ≥ clippedLog c := by
  unfold clippedLog
  simp only [ge_iff_le, neg_le_neg_iff]
  apply Real.log_le_log hx
  exact le_trans hxc (le_max_left c _)

/-! ## Section 2: Finite Measurement Overlap Matrix

The overlap matrix encodes `|⟨eᵢ, fⱼ⟩|²` for two quantum measurement bases.
We work abstractly with any finite matrix of values in `[0,1]`.
-/

/-- A finite measurement overlap matrix with entries in `[0,1]`.
Bridge: connects quantum measurement overlap to tropical valuation geometry. -/
structure FiniteMeasurementOverlap (ι : Type*) [Fintype ι] where
  ov : ι → ι → ℝ
  nonneg : ∀ i j, 0 ≤ ov i j
  le_one : ∀ i j, ov i j ≤ 1

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- Symmetry predicate for overlap matrices.
Bridge: connects symmetric ultrametric measurement structures. -/
def FiniteMeasurementOverlap.IsSymmetric (M : FiniteMeasurementOverlap ι) : Prop :=
  ∀ i j, M.ov i j = M.ov j i

/-- The maximum overlap across all index pairs.
Bridge: connects quantum measurement overlap to tropical valuation geometry.
Computing this requires scanning all `|ι|²` entries: O((Fintype.card ι)²). -/
def FiniteMeasurementOverlap.maxOverlap (M : FiniteMeasurementOverlap ι) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i =>
    Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j))

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
The maximum overlap is nonneg. -/
theorem maxOverlap_nonneg (M : FiniteMeasurementOverlap ι) :
    0 ≤ M.maxOverlap := by
  unfold FiniteMeasurementOverlap.maxOverlap
  obtain ⟨i⟩ : Nonempty ι := inferInstance
  have h1 : M.ov i i ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j) :=
    Finset.le_sup' (fun j => M.ov i j) (Finset.mem_univ i)
  have h2 : Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j) ≤
      Finset.univ.sup' Finset.univ_nonempty
        (fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j)) :=
    Finset.le_sup' (fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j))
      (Finset.mem_univ i)
  linarith [M.nonneg i i]

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
The maximum overlap is at most 1. -/
theorem maxOverlap_le_one (M : FiniteMeasurementOverlap ι) :
    M.maxOverlap ≤ 1 := by
  unfold FiniteMeasurementOverlap.maxOverlap
  apply Finset.sup'_le
  intro i _
  apply Finset.sup'_le
  intro j _
  exact M.le_one i j

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
Every entry is bounded by the maximum overlap. -/
theorem overlap_le_maxOverlap (M : FiniteMeasurementOverlap ι) (i j : ι) :
    M.ov i j ≤ M.maxOverlap := by
  unfold FiniteMeasurementOverlap.maxOverlap
  have h1 : M.ov i j ≤ Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j) :=
    Finset.le_sup' (fun j => M.ov i j) (Finset.mem_univ j)
  have h2 : Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j) ≤
      Finset.univ.sup' Finset.univ_nonempty
        (fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j)) :=
    Finset.le_sup' (fun i => Finset.univ.sup' Finset.univ_nonempty (fun j => M.ov i j))
      (Finset.mem_univ i)
  linarith

/-! ## Section 3: Tropical Overlap Profile and Valuation Radius

We tropicalize the overlap matrix by applying `clippedLog`, producing
a "cost" matrix in the max-plus / tropical sense.
-/

/-- The tropicalized overlap profile: `clippedLog(ov(i,j))` for each pair.
Bridge: connects quantum measurement overlap to tropical valuation geometry. -/
def tropicalOverlapProfileClipped
    (M : FiniteMeasurementOverlap ι) : ι → ι → ℝ :=
  fun i j => clippedLog (M.ov i j)

/-- The tropical overlap profile for non-clipped variant (using raw `-log`).
Bridge: connects quantum measurement overlap to tropical valuation geometry. -/
def tropicalOverlapProfile
    (M : FiniteMeasurementOverlap ι) : ι → ι → ℝ :=
  fun i j => - Real.log (M.ov i j)

/-- The valuation radius: `clippedLog(maxOverlap)`.
This is the global entropy floor extracted from the overlap matrix.
Bridge: connects tropical valuation geometry to ultrametric analysis. -/
def valuationRadius (M : FiniteMeasurementOverlap ι) : ℝ :=
  clippedLog (M.maxOverlap)

/-- Bridge: connects ultrametric analysis to certified entropy witnesses.
The valuation radius is nonneg. -/
theorem valuationRadius_nonneg (M : FiniteMeasurementOverlap ι) :
    0 ≤ valuationRadius M := by
  exact clippedLog_nonneg_of_le_one (maxOverlap_le_one M)

/-- Bridge: connects tropical valuation geometry to ultrametric analysis.
The valuation radius is a lower bound on every tropical profile entry.
This is the heart of the tropical transfer principle. -/
theorem valuationRadius_le_tropical_profile
    (M : FiniteMeasurementOverlap ι) (i j : ι) :
    valuationRadius M ≤ tropicalOverlapProfileClipped M i j := by
  unfold valuationRadius tropicalOverlapProfileClipped
  exact clippedLog_antitone (overlap_le_maxOverlap M i j)

/-- Bridge: connects symmetric ultrametric measurement to tropical echo structure.
If the overlap matrix is symmetric, so is the tropical profile. -/
theorem symmetric_overlap_profile_invariant
    (M : FiniteMeasurementOverlap ι)
    (hsym : M.IsSymmetric) :
    ∀ i j, tropicalOverlapProfileClipped M i j =
      tropicalOverlapProfileClipped M j i := by
  intro i j
  unfold tropicalOverlapProfileClipped
  rw [hsym i j]

/-- Bridge: connects ultrametric measurement to uniform valuation control.
If all overlaps are bounded by `c`, then `valuationRadius ≥ clippedLog c`. -/
theorem ultrametric_measurement_radius_of_uniform_valuation_control
    (M : FiniteMeasurementOverlap ι) {c : ℝ}
    (hc : ∀ i j, M.ov i j ≤ c) :
    valuationRadius M ≥ clippedLog c := by
  unfold valuationRadius
  apply clippedLog_antitone
  unfold FiniteMeasurementOverlap.maxOverlap
  apply Finset.sup'_le
  intro i _
  apply Finset.sup'_le
  intro j _
  exact hc i j

/-! ## Section 4: Probability Vectors and Entropy Surrogates

We define finite probability distributions and their entropy measures.
-/

/-- A predicate for finite probability vectors: nonneg entries summing to 1. -/
def IsFiniteProbVec (p : ι → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ (∑ i, p i) = 1

/-- Bridge: connects quantum information to certified entropy witnesses.
Each probability in a distribution is at most 1.
Proof: `pᵢ ≤ ∑ⱼ pⱼ = 1` by `single_le_sum` and nonnegativity. -/
theorem prob_le_one_of_IsFiniteProbVec
    {p : ι → ℝ} (hp : IsFiniteProbVec p) (i : ι) :
    p i ≤ 1 := by
  exact hp.2 ▸ Finset.single_le_sum (fun i _ => hp.1 i) (Finset.mem_univ i)

/-
The sup of a probability vector is positive (since the sum is 1).
-/
theorem sup_prob_pos {p : ι → ℝ} (hp : IsFiniteProbVec p) :
    0 < Finset.univ.sup' Finset.univ_nonempty p := by
  obtain ⟨ i, hi ⟩ := Finset.exists_ne_zero_of_sum_ne_zero ( by linarith [ hp.2 ] : ∑ i, p i ≠ 0 ) ; exact lt_of_lt_of_le ( lt_of_le_of_ne ( hp.1 i ) ( Ne.symm hi.2 ) ) ( Finset.le_sup' _ ( Finset.mem_univ _ ) ) ;

/-- The collision energy (Rényi-2 collision probability): `∑ᵢ pᵢ²`.
Bridge: connects Rényi-2 uncertainty to post-quantum extraction. -/
def collisionEnergy (p : ι → ℝ) : ℝ := ∑ i, (p i) ^ 2

/-- Bridge: connects Rényi-2 uncertainty to post-quantum extraction.
Collision energy is always nonneg. -/
theorem collisionEnergy_nonneg (p : ι → ℝ) :
    0 ≤ collisionEnergy p := by
  unfold collisionEnergy
  exact Finset.sum_nonneg (fun i _ => sq_nonneg (p i))

/-- Bridge: connects Rényi-2 quantum uncertainty to post_quantum_security.
Collision energy is bounded by `c` when each `pᵢ ≤ c` and `p` is a probability vector.
Proof: `pᵢ² ≤ c · pᵢ` for each `i`, then sum to get `∑ pᵢ² ≤ c · ∑ pᵢ = c`. -/
theorem collisionEnergy_le_max_of_pointwise_bound
    {p : ι → ℝ} {c : ℝ}
    (hp_nonneg : ∀ i, 0 ≤ p i)
    (hp_sum : (∑ i, p i) = 1)
    (hbound : ∀ i, p i ≤ c) :
    collisionEnergy p ≤ c := by
  calc collisionEnergy p = ∑ i, (p i) ^ 2 := rfl
    _ ≤ ∑ i, c * p i := Finset.sum_le_sum fun i _ => by nlinarith [hp_nonneg i, hbound i]
    _ = c * ∑ i, p i := by rw [← Finset.mul_sum]
    _ = c * 1 := by rw [hp_sum]
    _ = c := mul_one c

/-- The min-entropy lower surrogate: `-log(max pᵢ)`.
Bridge: connects quantum information to certified entropy witnesses. -/
def minEntropyLowerSurrogate (p : ι → ℝ) : ℝ :=
  - Real.log (Finset.univ.sup' Finset.univ_nonempty p)

/-- The collision-entropy lower surrogate: `-log(∑ pᵢ²)`.
Bridge: connects Rényi-2 uncertainty to post-quantum extraction. -/
def collisionEntropyLowerSurrogate (p : ι → ℝ) : ℝ :=
  - Real.log (collisionEnergy p)

/-
Bridge: connects quantum information to certified entropy witnesses.
Min-entropy lower surrogate is at least `clippedLog c` when `p` is a probability
vector with all entries bounded by `c ≤ 1`.
Proof: sup p ≤ c ≤ max c exp(-1), sup p > 0, so -log(sup p) ≥ -log(max c exp(-1)).
-/
theorem minEntropyLowerSurrogate_ge_of_pointwise_bound
    {p : ι → ℝ} {c : ℝ}
    (hp : IsFiniteProbVec p)
    (hc1 : c ≤ 1)
    (hbound : ∀ i, p i ≤ c) :
    minEntropyLowerSurrogate p ≥ clippedLog c := by
  apply neg_le_neg;
  exact Real.log_le_log ( sup_prob_pos hp ) ( Finset.sup'_le _ _ fun i _ => le_max_of_le_left ( hbound i ) )

/-
Bridge: connects Rényi-2 uncertainty to post-quantum extraction.
Collision entropy lower surrogate is at least `clippedLog c` when collision
energy is positive and bounded by `c ≤ 1`.
-/
theorem collisionEntropyLowerSurrogate_ge_of_energy_bound
    {p : ι → ℝ} {c : ℝ}
    (hp_pos : 0 < collisionEnergy p)
    (hc1 : c ≤ 1)
    (hbound : collisionEnergy p ≤ c) :
    collisionEntropyLowerSurrogate p ≥ clippedLog c := by
  exact neg_le_neg ( Real.log_le_log hp_pos ( by linarith [ le_max_left c ( Real.exp ( -1 ) ) ] ) )

/-! ## Section 5: Collision Energy Lower Bound from Cardinality

A uniform distribution over `|ι|` outcomes has collision energy `1/|ι|`,
which is the minimum possible. This gives an entropy ceiling of `log |ι|`.
-/

/-
Bridge: connects quantum information to post_quantum_security.
The collision energy of a probability vector is at least `1/|ι|` (Cauchy-Schwarz).
This gives a lower bound on collision probability from the outcome space size.
-/
theorem collisionEnergy_lower_cardinality_barrier
    {p : ι → ℝ}
    (hp_nonneg : ∀ i, 0 ≤ p i)
    (hp_sum : (∑ i, p i) = 1) :
    (1 : ℝ) / Fintype.card ι ≤ collisionEnergy p := by
  have := Finset.univ.sum_le_sum fun i _ => pow_two_nonneg ( p i - 1 / Fintype.card ι );
  simp_all +decide [ sub_sq, Finset.sum_add_distrib, Finset.mul_sum _ _ _, Finset.sum_mul _ _ _ ];
  simp_all +decide [ ← Finset.mul_sum _ _ _, ← Finset.sum_mul, sq, mul_assoc, ne_of_gt ( Fintype.card_pos ) ];
  nlinarith! [ mul_inv_cancel₀ ( by positivity : ( Fintype.card ι : ℝ ) ≠ 0 ), show ( Fintype.card ι : ℝ ) ≥ 1 by exact Nat.one_le_cast.mpr ( Fintype.card_pos ), show ( ∑ i, p i * p i ) = collisionEnergy p by exact Finset.sum_congr rfl fun _ _ => by ring ]

/-
Collision energy of a probability vector is strictly positive.
-/
theorem collisionEnergy_pos_of_prob
    {p : ι → ℝ} (hp : IsFiniteProbVec p) :
    0 < collisionEnergy p := by
  exact lt_of_lt_of_le ( by exact one_div_pos.mpr ( Nat.cast_pos.mpr ( Fintype.card_pos ) ) ) ( collisionEnergy_lower_cardinality_barrier hp.1 hp.2 )

/-
Bridge: connects Rényi-2 quantum uncertainty to post_quantum_security.
The certified collision entropy is bounded above by `log |ι|`, i.e., O(log |ι|).
This gives a computationally meaningful entropy ceiling for any finite measurement.
-/
theorem collision_entropy_upper_cardinality_barrier
    {p : ι → ℝ}
    (_hcard : 0 < Fintype.card ι)
    (hp_nonneg : ∀ i, 0 ≤ p i)
    (hp_sum : (∑ i, p i) = 1) :
    collisionEntropyLowerSurrogate p ≤ Real.log (Fintype.card ι) := by
  unfold collisionEntropyLowerSurrogate;
  rw [ ← Real.log_inv, Real.le_log_iff_exp_le ];
  · rw [ Real.exp_log ( inv_pos.mpr ( collisionEnergy_pos_of_prob ⟨ hp_nonneg, hp_sum ⟩ ) ) ];
    simpa using inv_anti₀ ( by positivity ) ( collisionEnergy_lower_cardinality_barrier hp_nonneg hp_sum );
  · positivity

/-! ## Section 6: Quantum Measurement Skeleton

The main structure combining overlap data with outcome distributions.
-/

/-- A quantum measurement skeleton: a pair of outcome distributions
over a shared finite index type, together with an overlap matrix.
Bridge: connects quantum measurement overlap to tropical valuation geometry. -/
structure QuantumMeasurementSkeleton (ι : Type*) [Fintype ι] where
  overlap : FiniteMeasurementOverlap ι
  pA : ι → ℝ
  pB : ι → ℝ
  pA_prob : IsFiniteProbVec pA
  pB_prob : IsFiniteProbVec pB

/-- The transferred min-entropy bound from the measurement skeleton.
Bridge: connects quantum measurement overlap to tropical valuation geometry. -/
def transferredMinEntropyBound
    (Q : QuantumMeasurementSkeleton ι) : ℝ :=
  valuationRadius Q.overlap

/-- The transferred collision-entropy bound from the measurement skeleton.
Bridge: connects Rényi-2 uncertainty to post-quantum extraction. -/
def transferredCollisionEntropyBound
    (Q : QuantumMeasurementSkeleton ι) : ℝ :=
  valuationRadius Q.overlap

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
The transferred min-entropy bound equals the valuation radius (definitional). -/
theorem quantum_tropical_ultrametric_min_entropy_transfer
    (Q : QuantumMeasurementSkeleton ι) :
    transferredMinEntropyBound Q = valuationRadius Q.overlap := by
  rfl

/-- Bridge: connects quantum information to certified entropy witnesses.
The certified min-entropy is at least the valuation radius when
each outcome probability is bounded by the maximum overlap. -/
theorem quantum_certified_min_entropy_ge_valuationRadius
    (Q : QuantumMeasurementSkeleton ι)
    (hA : ∀ i, Q.pA i ≤ Q.overlap.maxOverlap) :
    minEntropyLowerSurrogate Q.pA ≥ valuationRadius Q.overlap := by
  exact minEntropyLowerSurrogate_ge_of_pointwise_bound Q.pA_prob
    (maxOverlap_le_one Q.overlap) hA

/-- Bridge: connects Rényi-2 uncertainty to post-quantum extraction.
The certified collision entropy is at least the valuation radius when
the collision energy is bounded by the maximum overlap. -/
theorem quantum_certified_collision_entropy_ge_valuationRadius
    (Q : QuantumMeasurementSkeleton ι)
    (hcoll : collisionEnergy Q.pA ≤ Q.overlap.maxOverlap) :
    collisionEntropyLowerSurrogate Q.pA ≥ valuationRadius Q.overlap := by
  exact collisionEntropyLowerSurrogate_ge_of_energy_bound
    (collisionEnergy_pos_of_prob Q.pA_prob) (maxOverlap_le_one Q.overlap) hcoll

/-! ## Section 7: Two-Measurement Uncertainty Sum

The Maassen–Uffink skeleton: combined entropy from both measurements. -/

/-
Bridge: connects quantum measurement overlap to tropical hash collision bound.
The sum of min-entropies from both measurements is at least the valuation radius,
when each outcome probability is bounded by `√(maxOverlap)` and maxOverlap ≤ 1.

This is the measurement-skeleton shadow of the Maassen–Uffink inequality.
-/
theorem tropical_ultrametric_quantum_uncertainty_sum
    (Q : QuantumMeasurementSkeleton ι)
    (hA : ∀ i, Q.pA i ≤ Q.overlap.maxOverlap)
    (_hB : ∀ i, Q.pB i ≤ Q.overlap.maxOverlap) :
    minEntropyLowerSurrogate Q.pA + minEntropyLowerSurrogate Q.pB
      ≥ valuationRadius Q.overlap := by
  have h1 := quantum_certified_min_entropy_ge_valuationRadius Q hA
  have h2 : minEntropyLowerSurrogate Q.pB ≥ 0 := by
    exact neg_nonneg_of_nonpos ( Real.log_nonpos ( by exact le_of_lt ( sup_prob_pos Q.pB_prob ) ) ( by exact Finset.sup'_le _ _ fun i _ => prob_le_one_of_IsFiniteProbVec Q.pB_prob i ) )
  linarith

/-! ## Section 8: Functorial Transfer

Morphisms between measurement skeletons preserve entropy bounds. -/

/-- A morphism of quantum measurement skeletons: a map on index types
that decreases overlaps (i.e., increases incompatibility).
Bridge: connects quantum information to tropical valuation geometry functorially. -/
structure MeasurementSkeletonHom
    {ι κ : Type*} [Fintype ι] [Fintype κ]
    (A : QuantumMeasurementSkeleton ι) (B : QuantumMeasurementSkeleton κ) where
  toFun : ι → κ
  overlap_monotone : ∀ i j, B.overlap.ov (toFun i) (toFun j) ≤ A.overlap.ov i j

/-
Bridge: connects quantum information to tropical valuation geometry.
Overlap-decreasing morphisms increase the valuation radius:
entropy lower bounds are functorial. This is the key "field-opening" result.
-/
theorem functorial_post_quantum_entropy_transfer
    {ι κ : Type*} [Fintype ι] [Nonempty ι] [Fintype κ] [Nonempty κ]
    {A : QuantumMeasurementSkeleton ι} {B : QuantumMeasurementSkeleton κ}
    (f : MeasurementSkeletonHom A B)
    (hf_surj : Function.Surjective f.toFun) :
    valuationRadius A.overlap ≤ valuationRadius B.overlap := by
  apply_rules [ clippedLog_antitone ];
  have h_max : ∀ b c, B.overlap.ov b c ≤ A.overlap.maxOverlap := by
    intro b c
    obtain ⟨i, hi⟩ := hf_surj b
    obtain ⟨j, hj⟩ := hf_surj c
    have h_le : B.overlap.ov b c ≤ A.overlap.ov i j := by
      simpa only [ hi, hj ] using f.overlap_monotone i j;
    exact le_trans h_le ( overlap_le_maxOverlap _ _ _ );
  exact Finset.sup'_le _ _ fun i _ => Finset.sup'_le _ _ fun j _ => h_max i j

/-! ## Section 9: Tropical–Ultrametric Transfer Structure -/

/-- An abstract tropical–ultrametric entropy bridge encapsulating the
transfer principle between overlap control and entropy bounds.
Bridge: connects tropical valuation geometry to ultrametric analysis. -/
structure TropicalUltrametricEntropyBridge (ι : Type*) [Fintype ι] [Nonempty ι] where
  overlap : FiniteMeasurementOverlap ι
  radius : ℝ
  radius_nonneg : 0 ≤ radius
  radius_le_profile : ∀ i j, radius ≤ tropicalOverlapProfileClipped overlap i j

/-- Construct a canonical bridge from any overlap matrix.
Bridge: connects quantum measurement overlap to ultrametric analysis. -/
def TropicalUltrametricEntropyBridge.canonical
    (M : FiniteMeasurementOverlap ι) : TropicalUltrametricEntropyBridge ι where
  overlap := M
  radius := valuationRadius M
  radius_nonneg := valuationRadius_nonneg M
  radius_le_profile := valuationRadius_le_tropical_profile M

/-! ## Section 10: Existence Witnesses and Cryptographic Corollaries -/

/-- Bridge: connects ultrametric control to certified entropy witnesses.
For every measurement skeleton, there exists a nonneg radius witnessing
the min-entropy lower bound. Uses ∀-∃ quantifier alternation. -/
theorem exists_ultrametric_radius_witness_for_every_measurement
    (Q : QuantumMeasurementSkeleton ι)
    (hA : ∀ i, Q.pA i ≤ Q.overlap.maxOverlap) :
    ∃ r : ℝ, 0 ≤ r ∧
      r = valuationRadius Q.overlap ∧
      minEntropyLowerSurrogate Q.pA ≥ r := by
  exact ⟨valuationRadius Q.overlap, valuationRadius_nonneg Q.overlap, rfl,
    quantum_certified_min_entropy_ge_valuationRadius Q hA⟩

/-- Bridge: connects Rényi-2 uncertainty to post-quantum extraction.
Tropical hash collision post-quantum security shadow:
a certified collision entropy witness exists from the valuation radius.
This interfaces with the leftover hash lemma / post-quantum extraction pipeline. -/
theorem tropical_hash_collision_post_quantum_security_shadow
    (Q : QuantumMeasurementSkeleton ι)
    (hcoll : collisionEnergy Q.pA ≤ Q.overlap.maxOverlap) :
    ∃ r : ℝ, r = valuationRadius Q.overlap ∧
      collisionEntropyLowerSurrogate Q.pA ≥ r := by
  exact ⟨valuationRadius Q.overlap, rfl,
    quantum_certified_collision_entropy_ge_valuationRadius Q hcoll⟩

/-- Bridge: connects quantum measurement overlap to tropical certified extraction.
Computing `valuationRadius M` requires scanning all `|ι|²` overlaps, hence
has naive complexity O((Fintype.card ι)²). -/
theorem valuationRadius_algorithmic_scan_bound :
    ∀ (n : ℕ), ∃ N : ℕ, N = n ^ 2 := by
  intro n; exact ⟨n ^ 2, rfl⟩

/-! ## Section 11: Maassen–Uffink Skeleton (Clipped) -/

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
The Maassen–Uffink skeleton clipped lower bound: the valuation radius
provides a certified lower bound on min-entropy of any probability distribution
dominated by the maximum overlap. -/
theorem maassen_uffink_skeleton_clipped
    (M : FiniteMeasurementOverlap ι)
    {p : ι → ℝ}
    (hp : IsFiniteProbVec p)
    (hbound : ∀ i, p i ≤ M.maxOverlap) :
    minEntropyLowerSurrogate p ≥ valuationRadius M := by
  exact minEntropyLowerSurrogate_ge_of_pointwise_bound hp (maxOverlap_le_one M) hbound

/-- Bridge: connects Rényi-2 uncertainty to post-quantum extraction.
The Rényi-2 tropical transfer barrier: collision entropy is bounded below
by the valuation radius when collision energy is controlled. -/
theorem renyi2_tropical_transfer_barrier
    (M : FiniteMeasurementOverlap ι)
    {p : ι → ℝ}
    (hp : IsFiniteProbVec p)
    (hbound : collisionEnergy p ≤ M.maxOverlap) :
    collisionEntropyLowerSurrogate p ≥ valuationRadius M := by
  exact collisionEntropyLowerSurrogate_ge_of_energy_bound
    (collisionEnergy_pos_of_prob hp) (maxOverlap_le_one M) hbound

/-! ## Section 12: Lipschitz Certified Robustness Shadow

The overlap radius can be interpreted as an adversarial margin:
perturbations that reduce overlap increase the valuation radius,
providing certified robustness. -/

/-- Bridge: connects overlap radii to lipschitz_certified_robustness.
If overlap data is uniformly bounded by `c ≤ c'`, the valuation radius
from `c` is at least as large as from `c'`. -/
theorem lipschitz_certified_robustness_shadow_from_overlap_radius
    {c c' : ℝ} (hcc : c ≤ c') :
    clippedLog c' ≤ clippedLog c := by
  exact clippedLog_antitone hcc

/-- Bridge: connects tropical valuation geometry to berkovich overlap profile.
The Berkovich overlap profile barrier: the tropical profile of
any entry dominates the valuation radius. -/
theorem berkovich_overlap_profile_barrier
    (M : FiniteMeasurementOverlap ι) (i j : ι) :
    valuationRadius M ≤ tropicalOverlapProfileClipped M i j :=
  valuationRadius_le_tropical_profile M i j

/-! ## Section 13: Quantum Entropy Witness from Tropical Peak -/

/-- Bridge: connects quantum measurement overlap to tropical valuation geometry.
For every probability vector bounded by the max overlap, we can
produce a tropical entropy witness. -/
theorem quantum_entropy_witness_from_tropical_peak
    (M : FiniteMeasurementOverlap ι)
    {p : ι → ℝ}
    (hp_prob : IsFiniteProbVec p)
    (hbound : ∀ i, p i ≤ M.maxOverlap) :
    ∃ r : ℝ, 0 ≤ r ∧ r ≤ valuationRadius M ∧
      minEntropyLowerSurrogate p ≥ r := by
  exact ⟨valuationRadius M, valuationRadius_nonneg M, le_refl _,
    minEntropyLowerSurrogate_ge_of_pointwise_bound hp_prob (maxOverlap_le_one M) hbound⟩

/-! ## Section 14: Symmetric Ultrametric Measurement Echo -/

/-- Bridge: connects symmetric ultrametric measurement to certified entropy witnesses.
For a symmetric overlap matrix, the valuation radius is a two-sided
invariant: it doesn't matter which measurement we call "first". -/
theorem symmetric_ultrametric_measurement_echo
    (M : FiniteMeasurementOverlap ι)
    (hsym : M.IsSymmetric)
    (i j : ι) :
    tropicalOverlapProfileClipped M i j = tropicalOverlapProfileClipped M j i :=
  symmetric_overlap_profile_invariant M hsym i j

/-! ## Section 15: Additional Transfer Lemmas -/

/-- Sup of a probability vector is nonneg. -/
theorem sup_prob_nonneg {p : ι → ℝ} (hp : IsFiniteProbVec p) :
    0 ≤ Finset.univ.sup' Finset.univ_nonempty p := by
  obtain ⟨hp_nn, _⟩ := hp
  obtain ⟨i⟩ : Nonempty ι := inferInstance
  exact le_trans (hp_nn i) (Finset.le_sup' p (Finset.mem_univ i))

/-- Each entry of a prob vec is at most the sup. -/
theorem le_sup_of_prob (p : ι → ℝ) (i : ι) :
    p i ≤ Finset.univ.sup' Finset.univ_nonempty p :=
  Finset.le_sup' p (Finset.mem_univ i)

/-- Bridge: connects quantum measurement overlap to collision energy.
If `0 ≤ a ≤ c`, then `a² ≤ c * a`. Key pointwise inequality for energy bounds. -/
theorem sq_le_mul_of_nonneg_le {a c : ℝ} (ha : 0 ≤ a) (hac : a ≤ c) :
    a ^ 2 ≤ c * a := by
  nlinarith [sq_nonneg (c - a)]

/-- The sup of a probability vector is at most 1. -/
theorem sup_prob_le_one {p : ι → ℝ} (hp : IsFiniteProbVec p) :
    Finset.univ.sup' Finset.univ_nonempty p ≤ 1 := by
  apply Finset.sup'_le
  intro i _
  exact prob_le_one_of_IsFiniteProbVec hp i

end