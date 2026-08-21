/-
# Cycle 4: from the line to the ensemble — box projections, ℓ∞ robustness of every quota rung

`Logic.KneeMedianProjection` identified the three-seed median with the metric projection of
the perturbed seed onto the interval spanned by the clean ones, proved that this projection
is firmly nonexpansive (`proj_firmly_nonexpansive`), and characterised it
(`proj_characterisation`).  Two questions were left standing by that cycle.

**(A) Is firmness a one-dimensional accident?**  `firm₂_comp_fails` showed that *composition*
of firmly nonexpansive maps behaves worse in the plane than on the line, which raises the
suspicion that the median's firmness itself is one-dimensional.  It is not.  §1 lifts the
whole picture to `ℝⁿ`: the **coordinatewise median** — equivalently the projection onto a
box `∏ᵢ [aᵢ, bᵢ]` — is firmly nonexpansive for the *Euclidean* structure of `ℝⁿ`
(`projBox_firmly_nonexpansive`), and it realises the Euclidean distance to the box
(`projBox_nearest`).  Contrast with `firm₂_comp_fails`: firmness survives the passage to
higher dimension; closure under composition does not.

**(B) What if *every* seed is perturbed at once?**  All robustness statements so far moved a
single seed.  §2 proves the median of three reals is nonexpansive for the **ℓ∞ norm** on the
ensemble (`med3L_linf`), and §3 lifts this to the entire quota ladder of an arbitrary finite
seed ensemble: for every feasible quota `m`,

  `|quotaBudget K m − quotaBudget K' m| ≤ ‖K − K'‖∞`   (`quota_ladder_linf`).

The proof is structural: pointwise monotonicity of the ladder (`quotaBudget_mono_pointwise`)
plus exact shift equivariance (`quotaBudget_shift_le`).  So the median rung is not special —
*every* order statistic of the ensemble is `1`-Lipschitz in the seeds — while the
*breakdown* behaviour of the rungs, established in `Logic.KneeQuotaScaling`, is what
separates them.  Lipschitz robustness and breakdown robustness are independent axes.
-/

import Mathlib
import Logic.KneeMedianProjection

namespace KneeProj

open Finset KneeMedian KneeQuota

/-! ## 1.  The coordinatewise median is the Euclidean projection onto a box -/

variable {n : ℕ}

/-- Squared Euclidean norm on `ℝⁿ`. -/
def sqn (x : Fin n → ℝ) : ℝ := ∑ i, (x i) ^ 2

/-- Projection onto the box `∏ᵢ [aᵢ, bᵢ]`: the coordinatewise clamp, i.e. the
coordinatewise median. -/
def projBox (a b x : Fin n → ℝ) : Fin n → ℝ := fun i => proj (a i) (b i) (x i)

/-- Firm nonexpansiveness in `ℝⁿ` for the Euclidean structure. -/
def FirmNEn (T : (Fin n → ℝ) → (Fin n → ℝ)) : Prop :=
  ∀ x y, sqn (T x - T y) + sqn ((x - T x) - (y - T y)) ≤ sqn (x - y)

/-- The box projection is the coordinatewise median. -/
theorem projBox_apply_eq_med3L {a b : Fin n → ℝ} (hab : ∀ i, a i ≤ b i) (x : Fin n → ℝ)
    (i : Fin n) : projBox a b x i = med3L (x i) (a i) (b i) :=
  proj_eq_med3L (hab i) (x i)

theorem projBox_mem {a b : Fin n → ℝ} (hab : ∀ i, a i ≤ b i) (x : Fin n → ℝ) (i : Fin n) :
    projBox a b x i ∈ Set.Icc (a i) (b i) := proj_mem (hab i) (x i)

/-- **Firm nonexpansiveness in `ℝⁿ`.**  The coordinatewise median is firmly nonexpansive for
the Euclidean norm: the one-dimensional Pythagorean budgets add up.  Firmness, unlike
closure under composition (`firm₂_comp_fails`), is *not* a one-dimensional accident. -/
theorem projBox_firmly_nonexpansive {a b : Fin n → ℝ} (hab : ∀ i, a i ≤ b i) :
    FirmNEn (projBox a b) := by
  intro x y
  have hpt : ∀ i : Fin n,
      (projBox a b x i - projBox a b y i) ^ 2
        + ((x i - projBox a b x i) - (y i - projBox a b y i)) ^ 2 ≤ (x i - y i) ^ 2 :=
    fun i => proj_firmly_nonexpansive (hab i) (x i) (y i)
  simp only [sqn, Pi.sub_apply]
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_le_sum fun i _ => hpt i

/-- The box projection realises the Euclidean distance to the box. -/
theorem projBox_nearest {a b : Fin n → ℝ} (hab : ∀ i, a i ≤ b i) (x y : Fin n → ℝ)
    (hy : ∀ i, y i ∈ Set.Icc (a i) (b i)) :
    sqn (x - projBox a b x) ≤ sqn (x - y) := by
  have hpt : ∀ i : Fin n, (x i - projBox a b x i) ^ 2 ≤ (x i - y i) ^ 2 := by
    intro i
    have h := proj_variational (hab i) (x i) (hy i)
    show (x i - proj (a i) (b i) (x i)) ^ 2 ≤ (x i - y i) ^ 2
    nlinarith [h]
  simp only [sqn, Pi.sub_apply]
  exact Finset.sum_le_sum fun i _ => hpt i

/-- Euclidean nonexpansiveness of the coordinatewise median (discard the residual). -/
theorem projBox_nonexpansive {a b : Fin n → ℝ} (hab : ∀ i, a i ≤ b i) (x y : Fin n → ℝ) :
    sqn (projBox a b x - projBox a b y) ≤ sqn (x - y) := by
  have h := projBox_firmly_nonexpansive hab x y
  have hnn : 0 ≤ sqn ((x - projBox a b x) - (y - projBox a b y)) :=
    Finset.sum_nonneg fun i _ => sq_nonneg _
  linarith

/-! ## 2.  Simultaneous perturbation of all three seeds: ℓ∞ nonexpansiveness -/

/-- The median is monotone in each of its three arguments simultaneously. -/
theorem med3L_mono₃ {a₁ a₂ b₁ b₂ c₁ c₂ : ℝ} (ha : a₁ ≤ a₂) (hb : b₁ ≤ b₂) (hc : c₁ ≤ c₂) :
    med3L a₁ b₁ c₁ ≤ med3L a₂ b₂ c₂ := by
  unfold med3L
  exact max_le_max (min_le_min ha hb) (min_le_min (max_le_max ha hb) hc)

/-- The median is translation equivariant (a special case of `med3L_map`). -/
theorem med3L_add (a b c d : ℝ) : med3L (a + d) (b + d) (c + d) = med3L a b c + d :=
  med3L_map (f := fun t => t + d) (fun _ _ h => by linarith) a b c

/-- **ℓ∞ robustness of the three-seed median.**  Perturbing *all three* seeds at once moves
the median by at most the largest single perturbation.  This strictly generalises the
one-seed estimate `med3_nonexpansive` of the previous cycle. -/
theorem med3L_linf (a b c a' b' c' : ℝ) :
    |med3L a b c - med3L a' b' c'| ≤ max |a - a'| (max |b - b'| |c - c'|) := by
  set d := max |a - a'| (max |b - b'| |c - c'| ) with hd
  have hda : |a - a'| ≤ d := le_max_left _ _
  have hdb : |b - b'| ≤ d := (le_max_left _ _).trans (le_max_right _ _)
  have hdc : |c - c'| ≤ d := (le_max_right _ _).trans (le_max_right _ _)
  have ha1 : a' ≤ a + d := by have := abs_le.1 hda; linarith [this.1, this.2]
  have hb1 : b' ≤ b + d := by have := abs_le.1 hdb; linarith [this.1, this.2]
  have hc1 : c' ≤ c + d := by have := abs_le.1 hdc; linarith [this.1, this.2]
  have ha2 : a ≤ a' + d := by have := abs_le.1 hda; linarith [this.1, this.2]
  have hb2 : b ≤ b' + d := by have := abs_le.1 hdb; linarith [this.1, this.2]
  have hc2 : c ≤ c' + d := by have := abs_le.1 hdc; linarith [this.1, this.2]
  have h1 : med3L a' b' c' ≤ med3L a b c + d := by
    calc med3L a' b' c' ≤ med3L (a + d) (b + d) (c + d) := med3L_mono₃ ha1 hb1 hc1
      _ = med3L a b c + d := med3L_add a b c d
  have h2 : med3L a b c ≤ med3L a' b' c' + d := by
    calc med3L a b c ≤ med3L (a' + d) (b' + d) (c' + d) := med3L_mono₃ ha2 hb2 hc2
      _ = med3L a' b' c' + d := med3L_add a' b' c' d
  rw [abs_le]
  constructor <;> linarith

/-! ## 3.  Every rung of the quota ladder is ℓ∞-nonexpansive -/

section Quota

variable {ι : Type*} [Fintype ι]

/-- Lowering every seed's knee can only lower the quota budget. -/
theorem quotaBudget_mono_pointwise {K K' : ι → ℕ} (h : ∀ i, K i ≤ K' i) {m : ℕ}
    (hm : m ≤ Fintype.card ι) : quotaBudget K m ≤ quotaBudget K' m := by
  refine quotaBudget_le_of_card (b := quotaBudget K' m) ?_
  refine (card_passSet_quotaBudget (K := K') hm).trans (Finset.card_le_card ?_)
  intro i hi
  simp only [passSet, mem_filter, mem_univ, true_and] at hi ⊢
  exact (h i).trans hi

/-- Shifting every seed by `d` shifts every rung of the ladder by at most `d`. -/
theorem quotaBudget_shift_le (K : ι → ℕ) (d : ℕ) {m : ℕ} (hm : m ≤ Fintype.card ι) :
    quotaBudget (fun i => K i + d) m ≤ quotaBudget K m + d := by
  refine quotaBudget_le_of_card (b := quotaBudget K m + d) ?_
  refine (card_passSet_quotaBudget (K := K) hm).trans (Finset.card_le_card ?_)
  intro i hi
  simp only [passSet, mem_filter, mem_univ, true_and] at hi ⊢
  omega

/-- **Every quota rung is `1`-Lipschitz for the ℓ∞ distance on ensembles.**  If no seed's
knee moves by more than `d`, then no rung of the quota ladder — the low tail, the median,
the certified budget — moves by more than `d`.  Lipschitz robustness therefore does *not*
distinguish the order statistics; only their breakdown points do
(`KneeQuota.median_breakdown_half` versus `KneeMedian.max3_unbounded`). -/
theorem quota_ladder_linf {K K' : ι → ℕ} {d m : ℕ} (hm : m ≤ Fintype.card ι)
    (h : ∀ i, K i ≤ K' i + d ∧ K' i ≤ K i + d) :
    quotaBudget K m ≤ quotaBudget K' m + d ∧ quotaBudget K' m ≤ quotaBudget K m + d := by
  constructor
  · exact (quotaBudget_mono_pointwise (fun i => (h i).1) hm).trans
      (quotaBudget_shift_le K' d hm)
  · exact (quotaBudget_mono_pointwise (fun i => (h i).2) hm).trans
      (quotaBudget_shift_le K d hm)

/-- The integer-valued ℓ∞ statement in absolute-value form. -/
theorem quota_ladder_linf_abs {K K' : ι → ℕ} {d m : ℕ} (hm : m ≤ Fintype.card ι)
    (h : ∀ i, K i ≤ K' i + d ∧ K' i ≤ K i + d) :
    |(quotaBudget K m : ℤ) - (quotaBudget K' m : ℤ)| ≤ (d : ℤ) := by
  obtain ⟨h1, h2⟩ := quota_ladder_linf hm h
  have h1' : (quotaBudget K m : ℤ) ≤ (quotaBudget K' m : ℤ) + (d : ℤ) := by exact_mod_cast h1
  have h2' : (quotaBudget K' m : ℤ) ≤ (quotaBudget K m : ℤ) + (d : ℤ) := by exact_mod_cast h2
  rw [abs_le]
  constructor <;> linarith

end Quota

/-! ## 4.  The recorded ensemble -/

/-- At the NET-48 knee set `{256, 224, 160}`, a simultaneous re-run that moves every seed by
at most one grid step (`32`) moves the median by at most one grid step. -/
theorem net48_median_grid_stability (a' b' c' : ℝ)
    (ha : |(256 : ℝ) - a'| ≤ 32) (hb : |(224 : ℝ) - b'| ≤ 32) (hc : |(160 : ℝ) - c'| ≤ 32) :
    |med3L (256 : ℝ) 224 160 - med3L a' b' c'| ≤ 32 :=
  (med3L_linf 256 224 160 a' b' c').trans (max_le ha (max_le hb hc))

/-- Sanity: the NET-48 median really is `224`. -/
theorem net48_med3L_value : med3L (256 : ℝ) 224 160 = 224 := by
  unfold med3L; norm_num

end KneeProj