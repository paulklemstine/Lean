import Mathlib

/-!
# Core objects of the RLHF alignment-drift catalogue

Domain: Algebra (convex analysis × information theory × alignment theory).

This file collects the base objects that the RLHF drift thread of the catalogue is
phrased in — finite probability vectors, the Gibbs (KL-regularised) policy, the
Kullback–Leibler divergence, the total-variation (`ℓ¹`) distance, and the first two
moment functionals of a reward — together with the elementary API used downstream.

The names and definitions follow the conventions of the RLHF drift files of the
catalogue (`RLHF.IsDist`, `RLHF.gibbsPolicy`, `RLHF.klDiv`, `RLHF.l1Dist`,
`RLHF.rewardRange`, `RLHF.mean`, `RLHF.variance`, ...), so the results proved here and
in `Algebra.RLHFMeanAbsoluteDeviation` / `Algebra.RLHFKLSecondOrder` speak about
exactly the same objects as `RLHF.kl_gibbs_le_variance` and
`RLHF.gibbs_l1_le_variance`.

Nothing in this file is deep; it exists so that the two research files that follow are
self-contained and compile.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-! ## 1. Finite probability vectors -/

/-- A probability vector on a finite type. -/
structure IsDist (p : Ω → ℝ) : Prop where
  nonneg : ∀ y, 0 ≤ p y
  total : ∑ y, p y = 1

/-- A strictly positive probability vector (full support). -/
structure IsPosDist (p : Ω → ℝ) : Prop where
  pos : ∀ y, 0 < p y
  total : ∑ y, p y = 1

theorem IsPosDist.isDist {p : Ω → ℝ} (hp : IsPosDist p) : IsDist p :=
  ⟨fun y => (hp.pos y).le, hp.total⟩

/-! ## 2. Moment functionals -/

/-- The mean `𝔼_p[f] = ∑ y, p y · f y`. -/
noncomputable def mean (p f : Ω → ℝ) : ℝ := ∑ y, p y * f y

/-- The variance `Var_p(f) = 𝔼_p[(f − 𝔼_p f)²]`. -/
noncomputable def variance (p f : Ω → ℝ) : ℝ := ∑ y, p y * (f y - mean p f) ^ 2

/-- The **mean absolute deviation** `MAD_p(f) = 𝔼_p|f − 𝔼_p f|`. -/
noncomputable def mad (p f : Ω → ℝ) : ℝ := ∑ y, p y * |f y - mean p f|

/-- The covariance `Cov_p(f, g) = 𝔼_p[(f − 𝔼_p f)(g − 𝔼_p g)]`. -/
noncomputable def cov (p f g : Ω → ℝ) : ℝ :=
  ∑ y, p y * ((f y - mean p f) * (g y - mean p g))

theorem variance_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ variance p f :=
  Finset.sum_nonneg fun y _ => mul_nonneg (hp.nonneg y) (sq_nonneg _)

theorem mad_nonneg {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) : 0 ≤ mad p f :=
  Finset.sum_nonneg fun y _ => mul_nonneg (hp.nonneg y) (abs_nonneg _)

/-- The centred first moment vanishes. -/
theorem sum_centered {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) :
    ∑ y, p y * (f y - mean p f) = 0 := by
  have h : ∀ y, p y * (f y - mean p f) = p y * f y - mean p f * p y := fun y => by ring
  rw [Finset.sum_congr rfl fun y _ => h y, Finset.sum_sub_distrib, ← Finset.mul_sum, hp.total]
  simp [mean]

/-- The expectation of a constant. -/
theorem sum_const_dist {p : Ω → ℝ} (hp : IsDist p) (c : ℝ) : ∑ _y : Ω, p _y * c = c := by
  rw [← Finset.sum_mul, hp.total, one_mul]

/-! ## 3. The Gibbs policy -/

/-- The partition function `Z_β = ∑ y, p y e^{r y / β}`. -/
noncomputable def partition (β : ℝ) (r p : Ω → ℝ) : ℝ := ∑ y, p y * Real.exp (r y / β)

/-- The KL-regularised (Gibbs) policy `π_β(y) ∝ p y · e^{r y / β}`. -/
noncomputable def gibbsPolicy (β : ℝ) (r p : Ω → ℝ) : Ω → ℝ :=
  fun y => p y * Real.exp (r y / β) / partition β r p

/-- The Kullback–Leibler divergence `KL(q ‖ p) = ∑ y, q y log (q y / p y)`. -/
noncomputable def klDiv (q p : Ω → ℝ) : ℝ := ∑ y, q y * Real.log (q y / p y)

/-- The `ℓ¹` (twice total-variation) distance. -/
noncomputable def l1Dist (q p : Ω → ℝ) : ℝ := ∑ y, |q y - p y|

theorem l1Dist_nonneg (q p : Ω → ℝ) : 0 ≤ l1Dist q p :=
  Finset.sum_nonneg fun _ _ => abs_nonneg _

variable [Nonempty Ω]

/-- The reward range `max r − min r`. -/
noncomputable def rewardRange (r : Ω → ℝ) : ℝ :=
  univ.sup' univ_nonempty r - univ.inf' univ_nonempty r

theorem partition_pos {β : ℝ} {r p : Ω → ℝ} (hp : IsPosDist p) : 0 < partition β r p :=
  Finset.sum_pos (fun y _ => mul_pos (hp.pos y) (Real.exp_pos _)) univ_nonempty

theorem mean_le_sup {p r : Ω → ℝ} (hp : IsDist p) : mean p r ≤ univ.sup' univ_nonempty r := by
  have h : ∀ y ∈ (univ : Finset Ω), p y * r y ≤ p y * univ.sup' univ_nonempty r :=
    fun y _ => mul_le_mul_of_nonneg_left (Finset.le_sup' r (mem_univ y)) (hp.nonneg y)
  have := Finset.sum_le_sum h
  rwa [← Finset.sum_mul, hp.total, one_mul] at this

theorem inf_le_mean {p r : Ω → ℝ} (hp : IsDist p) : univ.inf' univ_nonempty r ≤ mean p r := by
  have h : ∀ y ∈ (univ : Finset Ω), p y * univ.inf' univ_nonempty r ≤ p y * r y :=
    fun y _ => mul_le_mul_of_nonneg_left (Finset.inf'_le r (mem_univ y)) (hp.nonneg y)
  have := Finset.sum_le_sum h
  rwa [← Finset.sum_mul, hp.total, one_mul] at this

theorem rewardRange_nonneg (r : Ω → ℝ) : 0 ≤ rewardRange r := by
  obtain ⟨y⟩ := ‹Nonempty Ω›
  have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
  have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
  simp only [rewardRange]; linarith

omit [Nonempty Ω] in
/-- The mean minimises the mean square deviation: `Var_p(f) ≤ 𝔼_p[(f − c)²]` for every
centre `c`. -/
theorem variance_le_of_center {p : Ω → ℝ} (hp : IsDist p) (f : Ω → ℝ) (c : ℝ) :
    variance p f ≤ ∑ y, p y * (f y - c) ^ 2 := by
  have hexpand : ∀ y, p y * (f y - c) ^ 2
      = p y * (f y - mean p f) ^ 2 + 2 * (mean p f - c) * (p y * (f y - mean p f))
        + (mean p f - c) ^ 2 * p y := fun y => by ring
  rw [Finset.sum_congr rfl fun y _ => hexpand y, Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.mul_sum, ← Finset.mul_sum, sum_centered hp f, hp.total]
  have hsq : (0:ℝ) ≤ (mean p f - c) ^ 2 := sq_nonneg _
  simp only [variance, mul_zero, mul_one, add_zero]
  linarith

/-- **Popoviciu's inequality**: `Var_p(r) ≤ range(r)²/4`. -/
theorem variance_le_range_sq {p r : Ω → ℝ} (hp : IsDist p) :
    variance p r ≤ rewardRange r ^ 2 / 4 := by
  set c : ℝ := (univ.sup' univ_nonempty r + univ.inf' univ_nonempty r) / 2 with hc
  refine (variance_le_of_center hp r c).trans ?_
  have hpt : ∀ y ∈ (univ : Finset Ω), p y * (r y - c) ^ 2 ≤ p y * (rewardRange r ^ 2 / 4) := by
    intro y _
    refine mul_le_mul_of_nonneg_left ?_ (hp.nonneg y)
    have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
    have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
    simp only [rewardRange, hc]
    nlinarith [sq_nonneg (r y - c)]
  have hsum := Finset.sum_le_sum hpt
  rwa [← Finset.sum_mul, hp.total, one_mul] at hsum

/-- Every centred reward value is bounded by the reward range. -/
theorem abs_sub_mean_le_range {p r : Ω → ℝ} (hp : IsDist p) (y : Ω) :
    |r y - mean p r| ≤ rewardRange r := by
  have h1 : r y ≤ univ.sup' univ_nonempty r := Finset.le_sup' r (mem_univ y)
  have h2 : univ.inf' univ_nonempty r ≤ r y := Finset.inf'_le r (mem_univ y)
  have h3 := mean_le_sup (p := p) (r := r) hp
  have h4 := inf_le_mean (p := p) (r := r) hp
  rw [abs_le]
  simp only [rewardRange]
  constructor <;> linarith

end RLHF