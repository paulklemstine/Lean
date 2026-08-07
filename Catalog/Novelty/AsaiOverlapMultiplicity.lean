/-
# The overlap multiplicity of an approximate functional equation

This file continues the formalisation of the analytic skeleton of the paper
**"On the Second Moment of `L(1/2, As(f) × φ)`"** carried out in `Novelty.AsaiLargeSieve`,
`Novelty.AsaiLargeSieveGram`, `Novelty.AsaiSecondMoment`, `Novelty.AsaiMomentApplications`,
`Novelty.AsaiLargeSieveSharp` and `Novelty.AsaiSecondMomentLower`.  It settles the upper
half of conjecture **C6** of `FUTURE_DIRECTIONS.md`, together with its sharpness.

## What is proved here

The flagship second moment bound `AsaiSecondMoment.secondMoment_uniform` carries a factor
`J²`, where `J` is the number of blocks of the approximate functional equation, and comes
from a blind application of Cauchy–Schwarz over the blocks.  For *spectrally separated*
blocks `AsaiSecondMoment.secondMoment_disjoint_uniform` removes one factor `J`.  Conjecture
C6 asserted that neither `J²` nor `J` is the right parameter: the correct one is the
**overlap multiplicity**

`r = max_{n < N} #{j < J : A j n ≠ 0}`,

i.e. the largest number of blocks that are simultaneously active at a single coefficient.

* `AsaiSecondMoment.OverlapMultiplicity` — the definition.
* `AsaiSecondMoment.sum_normSq_aggregate_le_overlap` — the arithmetic heart: the `ℓ²`-mass
  of the aggregated coefficient vector `n ↦ ∑_j w j · A j n` is at most `r` times the
  weighted sum of the blockwise masses.  (For `r = 1` this is the *equality*
  `sum_normSq_aggregate_of_disjoint`; for `r = J` it is the pointwise Cauchy–Schwarz
  inequality that produces the flagship `J²`.)
* `AsaiSecondMoment.secondMoment_overlap_le` and `secondMoment_overlap_uniform` — the
  resulting second moment bounds `C · r · ∑_j |w j|²‖A j‖²` and `r · J · C · B`.
* `AsaiSecondMoment.secondMoment_overlap_lt_flagship` — whenever `r < J` (and the problem is
  non-degenerate) the new bound is *strictly* stronger than the flagship `J² · C · B`, so
  the exponent `2` on `J` is indeed never correct below the maximal overlap.
* `AsaiSecondMoment.secondMoment_overlap_of_disjoint` — the case `r = 1` recovers exactly the
  spectrally separated bound, so the new statement genuinely interpolates between the two
  previously proved extremes.
* `AsaiSecondMoment.secondMoment_overlap_attained` — an explicit instance with `r = J = 2` in
  which the bound `C · r · ∑_j |w j|²‖A j‖²` holds *with equality*, so the linear dependence
  on `r` cannot be improved.

The last section settles the companion conjecture C9: for *aligned* configurations (the `r`
active blocks carry the same value at each coefficient) the aggregation is lossless
(`sum_normSq_aggregate_aligned`), so Petersson quasi-orthogonality gives a matching lower
bound (`secondMoment_aligned_lower`) and, in the regime `2eN ≤ D`, the exact order
`∑_f |L f|² ≍ D · r · ∑_j ‖A j‖²` for every intermediate overlap `r`
(`secondMoment_aligned_order`).

Everything is proved for an arbitrary finite family of eigenvalue systems
`lam : ι → ℕ → ℂ`, of which the Hecke eigenvalues of the Asai lifts are one instance.
-/
import Mathlib
import Novelty.AsaiLargeSieve
import Novelty.AsaiSecondMoment
import Novelty.AsaiSecondMomentLower

open Finset Complex AsaiLargeSieve

namespace AsaiSecondMoment

variable {ι : Type*}

/-- The blocks of `A` have **overlap multiplicity at most `r`** on `[0,N)` if at every
coefficient `n < N` at most `r` of the `J` blocks are nonzero. -/
def OverlapMultiplicity (N J : ℕ) (A : ℕ → ℕ → ℂ) (r : ℕ) : Prop :=
  ∀ n ∈ Finset.range N, ((Finset.range J).filter (fun j => A j n ≠ 0)).card ≤ r

/-- Spectral separation is the case `r = 1` of bounded overlap. -/
theorem overlapMultiplicity_one_of_disjoint (N J : ℕ) (A : ℕ → ℕ → ℂ) (b : ℕ → ℕ)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    OverlapMultiplicity N J A 1 := by
  classical
  intro n hn
  have hsub : (Finset.range J).filter (fun j => A j n ≠ 0) ⊆ {b n} := by
    intro j hj
    rcases Finset.mem_filter.mp hj with ⟨hjJ, hjne⟩
    have : b n = j := by
      by_contra hcon
      exact hjne (hsupp j hjJ n hn hcon)
    simp [this]
  exact le_trans (Finset.card_le_card hsub) (by simp)

/-- **The pointwise mass inequality.**  At each coefficient at most `r` blocks contribute, so
Cauchy–Schwarz over the active blocks costs a factor `r` and not `J`. -/
theorem normSq_aggregate_pointwise_le (J r : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (n : ℕ)
    (hr : ((Finset.range J).filter (fun j => A j n ≠ 0)).card ≤ r) :
    ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      ≤ (r : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 := by
  classical
  set T := (Finset.range J).filter (fun j => A j n ≠ 0) with hT
  have hcollapse : ∑ j ∈ Finset.range J, w j * A j n = ∑ j ∈ T, w j * A j n := by
    refine (Finset.sum_subset (Finset.filter_subset _ _) ?_).symm
    intro j hj hjT
    have : A j n = 0 := by
      by_contra hcon
      exact hjT (Finset.mem_filter.mpr ⟨hj, hcon⟩)
    rw [this, mul_zero]
  have hCS : ‖∑ j ∈ T, w j * A j n‖ ^ 2 ≤ (T.card : ℝ) * ∑ j ∈ T, ‖w j * A j n‖ ^ 2 :=
    norm_sum_sq_le_card_mul T (fun j => w j * A j n)
  have hpartial : ∑ j ∈ T, ‖w j * A j n‖ ^ 2
      ≤ ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 := by
    have hrw : ∀ j, ‖w j * A j n‖ ^ 2 = ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 := by
      intro j; rw [norm_mul, mul_pow]
    simp only [hrw]
    refine Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _) ?_
    intro j _ _; positivity
  have hnonneg : (0 : ℝ) ≤ ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 :=
    Finset.sum_nonneg fun j _ => by positivity
  have hcard : (T.card : ℝ) ≤ (r : ℝ) := by exact_mod_cast hr
  calc ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      = ‖∑ j ∈ T, w j * A j n‖ ^ 2 := by rw [hcollapse]
    _ ≤ (T.card : ℝ) * ∑ j ∈ T, ‖w j * A j n‖ ^ 2 := hCS
    _ ≤ (r : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 := by
        refine mul_le_mul hcard hpartial (Finset.sum_nonneg fun j _ => by positivity) ?_
        exact le_trans (Nat.cast_nonneg _) hcard

/-- **The mass of the aggregated coefficient vector is controlled by the overlap.** -/
theorem sum_normSq_aggregate_le_overlap (N J r : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ)
    (hr : OverlapMultiplicity N J A r) :
    ∑ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      ≤ (r : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  classical
  have hpt : ∀ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      ≤ (r : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ‖A j n‖ ^ 2 :=
    fun n hn => normSq_aggregate_pointwise_le J r w A n (hr n hn)
  have hsum := Finset.sum_le_sum hpt
  refine hsum.trans_eq ?_
  rw [← Finset.mul_sum, Finset.sum_comm]
  congr 1
  exact Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]

/-- **Conjecture C6, upper half.**  The second moment of a family of central values admitting
an approximate functional equation with overlap multiplicity `r` is bounded by the large
sieve constant times `r` times the sum of the blockwise coefficient masses. -/
theorem secondMoment_overlap_le (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ) (hC : 0 ≤ C)
    (hLS : LargeSieve S lam N C) (J r : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (hL : AFE S lam N J w A L) (hr : OverlapMultiplicity N J A r) :
    ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ C * (r : ℝ) * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  have hrw : ∑ f ∈ S, ‖L f‖ ^ 2
      = ∑ f ∈ S, ‖linForm lam N (fun n => ∑ j ∈ Finset.range J, w j * A j n) f‖ ^ 2 :=
    Finset.sum_congr rfl fun f hf => by
      rw [afe_eq_linForm_aggregate S lam N J w A L hL hf]
  rw [hrw]
  refine (hLS _).trans ?_
  have := sum_normSq_aggregate_le_overlap N J r w A hr
  calc C * ∑ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, w j * A j n‖ ^ 2
      ≤ C * ((r : ℝ) * ∑ j ∈ Finset.range J,
            ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) :=
        mul_le_mul_of_nonneg_left this hC
    _ = C * (r : ℝ) * ∑ j ∈ Finset.range J,
            ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by ring

/-- Uniform form: with archimedean weights bounded by `1` and blockwise coefficient mass at
most `B`, the second moment is at most `r · J · C · B`.  The flagship theorem is the case
`r = J`, and `AsaiSecondMoment.secondMoment_disjoint_uniform` the case `r = 1`. -/
theorem secondMoment_overlap_uniform (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hC : 0 ≤ C) (hLS : LargeSieve S lam N C) (J r : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ)
    (L : ι → ℂ) (B : ℝ) (hL : AFE S lam N J w A L) (hr : OverlapMultiplicity N J A r)
    (hw : ∀ j ∈ Finset.range J, ‖w j‖ ≤ 1)
    (hB : ∀ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B) :
    ∑ f ∈ S, ‖L f‖ ^ 2 ≤ (r : ℝ) * (J : ℝ) * C * B := by
  rcases Nat.eq_zero_or_pos J with hJ | hJ
  · -- with no blocks every value vanishes and the bound is trivially `0 ≤ 0`
    subst hJ
    have hmain := secondMoment_overlap_le S lam N C hC hLS 0 r w A L hL hr
    simp only [Finset.range_zero, Finset.sum_empty, mul_zero] at hmain
    simpa using hmain
  have hB0 : 0 ≤ B := by
    have h0 : (0 : ℕ) ∈ Finset.range J := Finset.mem_range.mpr hJ
    exact le_trans (Finset.sum_nonneg fun n _ => by positivity) (hB 0 h0)
  refine (secondMoment_overlap_le S lam N C hC hLS J r w A L hL hr).trans ?_
  have hterm : ∀ j ∈ Finset.range J,
      ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 ≤ B := by
    intro j hj
    have h1 : (0 : ℝ) ≤ ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
      Finset.sum_nonneg fun n _ => by positivity
    have h2 : ‖w j‖ ^ 2 ≤ 1 := by nlinarith [norm_nonneg (w j), hw j hj]
    calc ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ 1 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := mul_le_mul_of_nonneg_right h2 h1
      _ = ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := one_mul _
      _ ≤ B := hB j hj
  have hsum : ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ (J : ℝ) * B := by
    have := Finset.sum_le_sum hterm
    simpa [Finset.sum_const, Finset.card_range, nsmul_eq_mul] using this
  calc C * (r : ℝ) * ∑ j ∈ Finset.range J,
          ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
      ≤ C * (r : ℝ) * ((J : ℝ) * B) := by
        refine mul_le_mul_of_nonneg_left hsum ?_
        positivity
    _ = (r : ℝ) * (J : ℝ) * C * B := by ring

/-- The overlap bound is **strictly** stronger than the flagship `J² · C · B` as soon as the
overlap is smaller than the number of blocks. -/
theorem secondMoment_overlap_lt_flagship (J r : ℕ) (C B : ℝ) (hC : 0 < C) (hB : 0 < B)
    (hrJ : r < J) :
    (r : ℝ) * (J : ℝ) * C * B < (J : ℝ) ^ 2 * C * B := by
  have h : (r : ℝ) < (J : ℝ) := by exact_mod_cast hrJ
  have hJ0 : (0 : ℝ) < (J : ℝ) := lt_of_le_of_lt (Nat.cast_nonneg r) h
  have key : 0 < ((J : ℝ) * ((J : ℝ) - (r : ℝ))) * (C * B) :=
    mul_pos (mul_pos hJ0 (by linarith)) (mul_pos hC hB)
  nlinarith [key]

/-- The case `r = 1` of the overlap bound recovers the spectrally separated bound of
`AsaiSecondMomentLower.lean`: the two statements are consistent, and the general theorem
interpolates between the two previously known extremes. -/
theorem secondMoment_overlap_of_disjoint (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (C : ℝ)
    (hC : 0 ≤ C) (hLS : LargeSieve S lam N C) (J : ℕ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (b : ℕ → ℕ) (hL : AFE S lam N J w A L)
    (hsupp : ∀ j ∈ Finset.range J, ∀ n ∈ Finset.range N, b n ≠ j → A j n = 0) :
    ∑ f ∈ S, ‖L f‖ ^ 2
      ≤ C * ∑ j ∈ Finset.range J, ‖w j‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  have h := secondMoment_overlap_le S lam N C hC hLS J 1 w A L hL
    (overlapMultiplicity_one_of_disjoint N J A b hsupp)
  simpa using h

/-- **The factor `r` is optimal.**  An explicit instance with `J = r = 2` in which the overlap
bound holds with equality: one form, one coefficient, two fully overlapping blocks. -/
theorem secondMoment_overlap_attained :
    ∃ (S : Finset Unit) (lam : Unit → ℕ → ℂ) (C : ℝ) (w : ℕ → ℂ) (A : ℕ → ℕ → ℂ)
      (L : Unit → ℂ),
      0 ≤ C ∧ LargeSieve S lam 1 C ∧ AFE S lam 1 2 w A L ∧
        OverlapMultiplicity 1 2 A 2 ∧
        ∑ f ∈ S, ‖L f‖ ^ 2
          = C * (2 : ℝ) * ∑ j ∈ Finset.range 2,
              ‖w j‖ ^ 2 * ∑ n ∈ Finset.range 1, ‖A j n‖ ^ 2 := by
  classical
  refine ⟨Finset.univ, fun _ _ => 1, 1, fun _ => 1, fun _ _ => 1, fun _ => 2,
    le_of_lt one_pos, ?_, ?_, ?_, ?_⟩
  · intro a
    simp [linForm]
  · intro f _
    simp [linForm]
  · intro n _
    simp
  · simp
    norm_num

/-! ## Conjecture C9: a matching lower bound at intermediate overlap

The upper bound above loses a factor `r`.  Is that loss real for `1 < r < J`, or only an
artefact of the pointwise Cauchy–Schwarz step?  It is real.  The extremal configuration is the
one in which the active blocks are *aligned*: at each coefficient `n` the `r` active blocks
carry the same value `c n`, so nothing cancels in the aggregation and the pointwise
Cauchy–Schwarz step is an equality.  Under Petersson quasi-orthogonality this produces a
lower bound of exactly the same shape as the upper bound, and hence the exact order
`∑_f |L f|² ≍ D · r · ∑_j ‖A j‖²` for every `r`. -/

/-- An AFE has **aligned overlap** with active sets `act` and profile `c` when the `j`-th
block takes the value `c n` at the coefficient `n` for every active index `j ∈ act n`, and
vanishes at the inactive ones. -/
def AlignedOverlap (N J : ℕ) (A : ℕ → ℕ → ℂ) (act : ℕ → Finset ℕ) (c : ℕ → ℂ) : Prop :=
  ∀ n ∈ Finset.range N, act n ⊆ Finset.range J ∧
    ∀ j ∈ Finset.range J, A j n = if j ∈ act n then c n else 0

/-- An aligned configuration with active sets of size `r` has overlap multiplicity `r`. -/
theorem overlapMultiplicity_of_aligned (N J r : ℕ) (A : ℕ → ℕ → ℂ) (act : ℕ → Finset ℕ)
    (c : ℕ → ℂ) (hal : AlignedOverlap N J A act c)
    (hcard : ∀ n ∈ Finset.range N, (act n).card ≤ r) :
    OverlapMultiplicity N J A r := by
  classical
  intro n hn
  obtain ⟨_, hval⟩ := hal n hn
  have hsub : (Finset.range J).filter (fun j => A j n ≠ 0) ⊆ act n := by
    intro j hj
    rcases Finset.mem_filter.mp hj with ⟨hjJ, hjne⟩
    by_contra hcon
    exact hjne (by rw [hval j hjJ, if_neg hcon])
  exact le_trans (Finset.card_le_card hsub) (hcard n hn)

/-- **The aggregation is lossless for aligned blocks.**  With unit weights the aggregated
coefficient at `n` is `r · c n`, so the aggregated `ℓ²`-mass is exactly `r` times the sum of
the blockwise masses — the pointwise Cauchy–Schwarz step of `normSq_aggregate_pointwise_le`
is an equality here. -/
theorem sum_normSq_aggregate_aligned (N J r : ℕ) (A : ℕ → ℕ → ℂ) (act : ℕ → Finset ℕ)
    (c : ℕ → ℂ) (hal : AlignedOverlap N J A act c)
    (hcard : ∀ n ∈ Finset.range N, (act n).card = r) :
    ∑ n ∈ Finset.range N, ‖∑ j ∈ Finset.range J, (1 : ℂ) * A j n‖ ^ 2
      = (r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
  classical
  have hpt : ∀ n ∈ Finset.range N,
      ‖∑ j ∈ Finset.range J, (1 : ℂ) * A j n‖ ^ 2
        = (r : ℝ) * ∑ j ∈ Finset.range J, ‖A j n‖ ^ 2 := by
    intro n hn
    obtain ⟨hsub, hval⟩ := hal n hn
    have hagg : ∑ j ∈ Finset.range J, (1 : ℂ) * A j n = (r : ℂ) * c n := by
      have h1 : ∑ j ∈ Finset.range J, (1 : ℂ) * A j n
          = ∑ j ∈ Finset.range J, (if j ∈ act n then c n else 0) :=
        Finset.sum_congr rfl fun j hj => by rw [one_mul, hval j hj]
      rw [h1, Finset.sum_ite_mem, Finset.inter_eq_right.mpr hsub, Finset.sum_const,
        hcard n hn, nsmul_eq_mul]
    have hblocks : ∑ j ∈ Finset.range J, ‖A j n‖ ^ 2 = (r : ℝ) * ‖c n‖ ^ 2 := by
      have h1 : ∑ j ∈ Finset.range J, ‖A j n‖ ^ 2
          = ∑ j ∈ Finset.range J, (if j ∈ act n then ‖c n‖ ^ 2 else 0) := by
        refine Finset.sum_congr rfl fun j hj => ?_
        rw [hval j hj]
        by_cases hj' : j ∈ act n <;> simp [hj']
      rw [h1, Finset.sum_ite_mem, Finset.inter_eq_right.mpr hsub, Finset.sum_const,
        hcard n hn, nsmul_eq_mul]
    rw [hagg, hblocks, norm_mul, mul_pow, Complex.norm_natCast]
    ring
  rw [Finset.sum_congr rfl hpt, ← Finset.mul_sum, Finset.sum_comm]

/-- **Conjecture C9, lower half.**  Under Petersson-type quasi-orthogonality, an aligned AFE
of overlap `r` has second moment at least `(D − eN) · r` times the sum of the blockwise
coefficient masses: the factor `r` of `secondMoment_overlap_le` is genuine, not an artefact
of Cauchy–Schwarz. -/
theorem secondMoment_aligned_lower (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (D e : ℝ)
    (h : QuasiOrthogonal S lam N D e) (J r : ℕ) (A : ℕ → ℕ → ℂ) (L : ι → ℂ)
    (act : ℕ → Finset ℕ) (c : ℕ → ℂ) (hL : AFE S lam N J (fun _ => 1) A L)
    (hal : AlignedOverlap N J A act c) (hcard : ∀ n ∈ Finset.range N, (act n).card = r) :
    (D - e * N) * ((r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2)
      ≤ ∑ f ∈ S, ‖L f‖ ^ 2 := by
  have hrw : ∑ f ∈ S, ‖L f‖ ^ 2
      = ∑ f ∈ S, ‖linForm lam N (fun n => ∑ j ∈ Finset.range J, (1 : ℂ) * A j n) f‖ ^ 2 :=
    Finset.sum_congr rfl fun f hf => by
      rw [afe_eq_linForm_aggregate S lam N J (fun _ => 1) A L hL hf]
  rw [hrw, ← sum_normSq_aggregate_aligned N J r A act c hal hcard]
  exact lowerBound_of_quasiOrthogonal S lam N D e h _

/-- **Conjecture C9, settled: the exact order at intermediate overlap.**  In the
Kloosterman-controlled regime `2eN ≤ D`, an aligned AFE of overlap `r` has
`∑_f |L f|² ≍ D · r · ∑_j ‖A j‖²`, between `D/2` and `3D/2` times it.  For `r = 1` this is the
spectrally separated case, for `r = J` the flagship case, and for `1 < r < J` it shows that
the interpolation of `secondMoment_overlap_le` is of the correct order. -/
theorem secondMoment_aligned_order (S : Finset ι) (lam : ι → ℕ → ℂ) (N : ℕ) (hN : 1 ≤ N)
    (D e : ℝ) (h : QuasiOrthogonal S lam N D e) (hreg : 2 * (e * N) ≤ D) (J r : ℕ)
    (A : ℕ → ℕ → ℂ) (L : ι → ℂ) (act : ℕ → Finset ℕ) (c : ℕ → ℂ)
    (hL : AFE S lam N J (fun _ => 1) A L) (hal : AlignedOverlap N J A act c)
    (hcard : ∀ n ∈ Finset.range N, (act n).card = r) :
    (D / 2) * ((r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2)
        ≤ ∑ f ∈ S, ‖L f‖ ^ 2 ∧
      ∑ f ∈ S, ‖L f‖ ^ 2
        ≤ (3 * D / 2) * ((r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) := by
  have hM0 : (0 : ℝ) ≤ ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
    Finset.sum_nonneg fun j _ => Finset.sum_nonneg fun n _ => by positivity
  have hrM0 : (0 : ℝ) ≤ (r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
    mul_nonneg (Nat.cast_nonneg r) hM0
  constructor
  · refine le_trans ?_
      (secondMoment_aligned_lower S lam N D e h J r A L act c hL hal hcard)
    have : D / 2 ≤ D - e * N := by linarith
    exact mul_le_mul_of_nonneg_right this hrM0
  · have hC0 : (0 : ℝ) ≤ D + e * N := quasiOrthogonal_const_nonneg S lam N D e hN h
    have hbound := secondMoment_overlap_le S lam N (D + e * N) hC0
      (largeSieve_of_quasiOrthogonal S lam N D e h) J r (fun _ => 1) A L hL
      (overlapMultiplicity_of_aligned N J r A act c hal fun n hn => le_of_eq (hcard n hn))
    have hsimp : ∑ j ∈ Finset.range J,
        ‖(1 : ℂ)‖ ^ 2 * ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
          = ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 := by
      simp
    rw [hsimp] at hbound
    refine hbound.trans ?_
    have hstep : (D + e * N) * (r : ℝ) ≤ (3 * D / 2) * (r : ℝ) := by
      have : D + e * N ≤ 3 * D / 2 := by linarith
      exact mul_le_mul_of_nonneg_right this (Nat.cast_nonneg r)
    calc (D + e * N) * (r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2
        ≤ (3 * D / 2) * (r : ℝ) * ∑ j ∈ Finset.range J, ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2 :=
          mul_le_mul_of_nonneg_right hstep hM0
      _ = (3 * D / 2) * ((r : ℝ) * ∑ j ∈ Finset.range J,
            ∑ n ∈ Finset.range N, ‖A j n‖ ^ 2) := by ring

end AsaiSecondMoment