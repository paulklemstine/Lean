import Mathlib

/-!
# Positional–rate link: the two-layer occupancy model (exp 580 / paper 230)

This file formalises the structural content behind the round-80 experiment
"POSITIONAL-RATE-LINK" (exp 580).  The empirical situation is the following.
For each modulus `N` in a family, a scan produces a random number of *hits*
(the **rate layer**), and each hit sits at some position inside a scan window,
binned into deciles (the **positional layer**).  The pre-registered hypothesis
H1 was that the *shape* of the positional profile changes with the hit rate
(hit-rich versus hit-poor `N`'s).  The experiment refuted H1: the interaction
LRT did not fire (χ² = 51.31 on 49 df, p = 0.383, permutation p = 0.34) and the
pooled rich/poor KS statistic (D = 0.0462) did not survive multiplicity
correction.

The mathematics that makes such a null result meaningful is formalised here:

* `PositionalRateLink.TwoLayer` – a finite occupancy model: a positive rate
  `rate i` per index and a probability profile `prof i` over bins.
* `TwoLayer.rankOne_iff_homogeneous` – the expected occupancy matrix
  factorises as an outer product **iff** all positional profiles agree.  This is
  the exact algebraic content of the "no interaction" null hypothesis.
* `TwoLayer.interactionFree_iff_homogeneous` – vanishing of all `2 × 2`
  interaction contrasts (cross-product ratios) is likewise equivalent to profile
  homogeneity; this is the population version of the LRT that was run.
* `TwoLayer.strata_profiles_eq`, `TwoLayer.ks_zero` – under homogeneity, *any*
  stratification of the indices (in particular the rate terciles
  poor/mid/rich) produces exactly the same pooled positional profile, so the
  population KS statistic is `0`.
* `TwoLayer.strata_contrast_le_heterogeneity` – conversely the observable
  between-strata contrast is bounded by the profile heterogeneity, so a null
  KS result is informative about heterogeneity, not merely about power.
* `PositionalRateLink.law_total_variance`, `overdispersion`,
  `equidispersion_iff` – the rate layer alone carries overdispersion: for a
  finite mixture of conditionally equidispersed counts, the variance exceeds the
  mean exactly by the between-index variance of the rates.
* `overdispersion_without_profile_heterogeneity` and
  `profile_heterogeneity_without_equidispersion` – the two layers are
  *logically independent*: arbitrarily large overdispersion is compatible with a
  perfectly homogeneous positional layer, and maximal positional heterogeneity
  is compatible with exact equidispersion.  This is the formal counterpart of
  the paper-230 conclusion that the unexplained between-`N` rate variance is
  *not* carried by profile-shape heterogeneity.
-/

open Finset

namespace PositionalRateLink

/-- A finite two-layer occupancy model: each index `i` (a modulus `N` in the
experiment) has a positive expected hit count `rate i` (the *rate layer*) and a
probability distribution `prof i` over positional bins (the *positional
layer*). -/
structure TwoLayer (ι β : Type*) [Fintype ι] [Fintype β] where
  /-- expected number of hits produced by index `i` -/
  rate : ι → ℝ
  rate_pos : ∀ i, 0 < rate i
  /-- positional profile of index `i` over the bins -/
  prof : ι → β → ℝ
  prof_nonneg : ∀ i b, 0 ≤ prof i b
  prof_sum : ∀ i, ∑ b, prof i b = 1

namespace TwoLayer

variable {ι β : Type*} [Fintype ι] [Fintype β] (M : TwoLayer ι β)

/-- Expected occupancy of bin `b` by index `i`. -/
def occ (i : ι) (b : β) : ℝ := M.rate i * M.prof i b

/-- Occupancy pooled over a stratum `S`, with index weights `w`. -/
def pooled (w : ι → ℝ) (S : Finset ι) (b : β) : ℝ := ∑ i ∈ S, w i * M.occ i b

/-- Total expected number of hits contributed by a stratum. -/
def mass (w : ι → ℝ) (S : Finset ι) : ℝ := ∑ i ∈ S, w i * M.rate i

/-- Normalised pooled positional profile of a stratum: the object the
KS statistic compares between hit-rich and hit-poor terciles. -/
noncomputable def normProf (w : ι → ℝ) (S : Finset ι) (b : β) : ℝ :=
  M.pooled w S b / M.mass w S

lemma occ_row_sum (i : ι) : ∑ b, M.occ i b = M.rate i := by
  simp [occ, ← Finset.mul_sum, M.prof_sum]

lemma pooled_eq (w : ι → ℝ) (S : Finset ι) (b : β) :
    M.pooled w S b = ∑ i ∈ S, (w i * M.rate i) * M.prof i b := by
  simp only [pooled, occ]
  exact Finset.sum_congr rfl fun i _ => by ring

lemma pooled_sum (w : ι → ℝ) (S : Finset ι) : ∑ b, M.pooled w S b = M.mass w S := by
  simp only [pooled, mass, occ]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [← Finset.mul_sum, ← Finset.mul_sum, M.prof_sum i, mul_one]

/-!
### The algebra of "no interaction"
-/

/-- **Rank-one criterion.**  The expected occupancy matrix `occ` factorises as an
outer product `u i * v b` if and only if every index has the same positional
profile.  Equivalently: a rate layer and a positional layer multiply out to a
rank-one table precisely when the layers do not interact. -/
theorem rankOne_iff_homogeneous [Nonempty ι] :
    (∃ u : ι → ℝ, ∃ v : β → ℝ, ∀ i b, M.occ i b = u i * v b) ↔
      ∀ i j, M.prof i = M.prof j := by
  constructor
  · rintro ⟨u, v, huv⟩ i j
    funext b
    set sv := ∑ b, v b with hsv
    have key : ∀ k : ι, u k * sv = M.rate k := by
      intro k
      have hk := M.occ_row_sum k
      rw [← hk]
      simp [huv, ← Finset.mul_sum, hsv]
    have hsv0 : sv ≠ 0 := by
      intro h
      have hi := key i
      rw [h, mul_zero] at hi
      exact absurd hi.symm (ne_of_gt (M.rate_pos i))
    have hui : ∀ k : ι, M.prof k b = v b / sv := by
      intro k
      have h2 : u k * sv = M.rate k := key k
      have hu0 : u k ≠ 0 := by
        intro h
        rw [h, zero_mul] at h2
        exact (ne_of_gt (M.rate_pos k)) h2.symm
      have h1 : M.rate k * M.prof k b = u k * v b := huv k b
      rw [← h2] at h1
      have h3 : u k * (sv * M.prof k b) = u k * v b := by rw [← h1]; ring
      have h4 := mul_left_cancel₀ hu0 h3
      field_simp
      rw [mul_comm]
      exact h4
    rw [hui i, hui j]
  · intro h
    obtain ⟨i0⟩ := ‹Nonempty ι›
    exact ⟨fun i => M.rate i, fun b => M.prof i0 b, fun i b => by rw [occ, h i i0]⟩

/-- **Interaction-free criterion.**  All `2 × 2` cross-products of the occupancy
table agree (the population null of the interaction likelihood-ratio test) if
and only if the positional profiles are homogeneous across indices. -/
theorem interactionFree_iff_homogeneous :
    (∀ i j b c, M.occ i b * M.occ j c = M.occ i c * M.occ j b) ↔
      ∀ i j, M.prof i = M.prof j := by
  constructor
  · intro h i j
    funext b
    have hc : ∀ c, M.prof i b * M.prof j c = M.prof i c * M.prof j b := by
      intro c
      have hij := h i j b c
      simp only [occ] at hij
      have hmul : M.rate i * M.rate j * (M.prof i b * M.prof j c)
          = M.rate i * M.rate j * (M.prof i c * M.prof j b) := by
        ring_nf
        ring_nf at hij
        linarith
      exact mul_left_cancel₀ (mul_pos (M.rate_pos i) (M.rate_pos j)).ne' hmul
    have hsum := Finset.sum_congr rfl
      (fun c (_ : c ∈ (Finset.univ : Finset β)) => hc c)
    rw [← Finset.mul_sum, M.prof_sum j, mul_one, ← Finset.sum_mul, M.prof_sum i, one_mul] at hsum
    exact hsum
  · intro h i j b c
    have hij := h i j
    simp only [occ, hij]
    ring

/-!
### Stratification by the rate layer cannot move the positional profile
-/

/-- Under homogeneity the pooled occupancy of a stratum is its total mass times
the common profile. -/
theorem pooled_of_homogeneous {p : β → ℝ} (h : ∀ i, M.prof i = p) (w : ι → ℝ)
    (S : Finset ι) (b : β) : M.pooled w S b = M.mass w S * p b := by
  simp only [pooled, mass, occ, h, Finset.sum_mul]
  exact Finset.sum_congr rfl fun i _ => by ring

theorem normProf_of_homogeneous {p : β → ℝ} (h : ∀ i, M.prof i = p) (w : ι → ℝ)
    (S : Finset ι) (hS : M.mass w S ≠ 0) : M.normProf w S = p := by
  funext b
  rw [normProf, M.pooled_of_homogeneous h w S b, mul_comm, mul_div_assoc, div_self hS, mul_one]

/-- **Stratum invariance (H0).**  If the positional layer is homogeneous then any
two strata — in particular the hit-poor and hit-rich terciles — have identical
pooled positional profiles. -/
theorem strata_profiles_eq {p : β → ℝ} (h : ∀ i, M.prof i = p) (w : ι → ℝ)
    (S T : Finset ι) (hS : M.mass w S ≠ 0) (hT : M.mass w T ≠ 0) :
    M.normProf w S = M.normProf w T := by
  rw [M.normProf_of_homogeneous h w S hS, M.normProf_of_homogeneous h w T hT]

/-- Consequently the population Kolmogorov–Smirnov statistic between two rate
strata vanishes identically. -/
theorem ks_zero [LinearOrder β] {p : β → ℝ} (h : ∀ i, M.prof i = p) (w : ι → ℝ)
    (S T : Finset ι) (hS : M.mass w S ≠ 0) (hT : M.mass w T ≠ 0) (t : β) :
    |(∑ b ∈ Finset.univ.filter (· ≤ t), M.normProf w S b)
      - ∑ b ∈ Finset.univ.filter (· ≤ t), M.normProf w T b| = 0 := by
  rw [M.strata_profiles_eq h w S T hS hT]
  simp

theorem normProf_le {w : ι → ℝ} {S : Finset ι} (hw : ∀ i ∈ S, 0 ≤ w i)
    (hS : 0 < M.mass w S) {b : β} {U : ℝ} (hU : ∀ i, M.prof i b ≤ U) :
    M.normProf w S b ≤ U := by
  rw [normProf, div_le_iff₀ hS, M.pooled_eq]
  calc ∑ i ∈ S, (w i * M.rate i) * M.prof i b
      ≤ ∑ i ∈ S, (w i * M.rate i) * U :=
        Finset.sum_le_sum fun i hi =>
          mul_le_mul_of_nonneg_left (hU i) (mul_nonneg (hw i hi) (M.rate_pos i).le)
    _ = U * M.mass w S := by rw [← Finset.sum_mul, mass, mul_comm]

theorem le_normProf {w : ι → ℝ} {S : Finset ι} (hw : ∀ i ∈ S, 0 ≤ w i)
    (hS : 0 < M.mass w S) {b : β} {L : ℝ} (hL : ∀ i, L ≤ M.prof i b) :
    L ≤ M.normProf w S b := by
  rw [normProf, le_div_iff₀ hS, M.pooled_eq]
  calc L * M.mass w S = ∑ i ∈ S, (w i * M.rate i) * L := by
        rw [← Finset.sum_mul, mass, mul_comm]
    _ ≤ ∑ i ∈ S, (w i * M.rate i) * M.prof i b :=
        Finset.sum_le_sum fun i hi =>
          mul_le_mul_of_nonneg_left (hL i) (mul_nonneg (hw i hi) (M.rate_pos i).le)

/-- **Signal is bounded by heterogeneity.**  The between-strata positional
contrast in any bin never exceeds the spread of the individual profiles in that
bin.  Hence a small observed contrast bounds the amount of profile heterogeneity
that can be present, which is what makes the exp-580 null informative. -/
theorem strata_contrast_le_heterogeneity {w : ι → ℝ} {S T : Finset ι}
    (hwS : ∀ i ∈ S, 0 ≤ w i) (hwT : ∀ i ∈ T, 0 ≤ w i)
    (hS : 0 < M.mass w S) (hT : 0 < M.mass w T) {b : β} {L U : ℝ}
    (hL : ∀ i, L ≤ M.prof i b) (hU : ∀ i, M.prof i b ≤ U) :
    |M.normProf w S b - M.normProf w T b| ≤ U - L := by
  have h1 := M.le_normProf hwS hS hL
  have h2 := M.normProf_le hwS hS hU
  have h3 := M.le_normProf hwT hT hL
  have h4 := M.normProf_le hwT hT hU
  rw [abs_sub_le_iff]
  constructor <;> linarith

end TwoLayer

/-!
## The rate layer: overdispersion via the law of total variance
-/

section Dispersion

variable {ι : Type*} [Fintype ι]

/-- Mean of a finite mixture with weights `w` and conditional means `m`. -/
def mixMean (w m : ι → ℝ) : ℝ := ∑ i, w i * m i

/-- Variance of a finite mixture with weights `w`, conditional means `m` and
conditional variances `v`. -/
def mixVar (w m v : ι → ℝ) : ℝ := (∑ i, w i * (v i + m i ^ 2)) - (mixMean w m) ^ 2

/-- **Law of total variance** for a finite mixture: the total variance is the
mean conditional variance plus the variance of the conditional means. -/
theorem law_total_variance (w m v : ι → ℝ) (hw : ∑ i, w i = 1) :
    mixVar w m v = (∑ i, w i * v i) + ∑ i, w i * (m i - mixMean w m) ^ 2 := by
  set μ := mixMean w m with hμ
  have hsplit : ∑ i, w i * (v i + m i ^ 2) = (∑ i, w i * v i) + ∑ i, w i * m i ^ 2 := by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have hexp : ∑ i, w i * (m i - μ) ^ 2
      = (∑ i, w i * m i ^ 2) - 2 * μ * (∑ i, w i * m i) + μ ^ 2 * (∑ i, w i) := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring
  have hmean : (∑ i, w i * m i) = μ := rfl
  rw [mixVar, hsplit, hexp, hw, hmean]
  ring

/-- **Overdispersion is carried by the rate layer.**  For conditionally
equidispersed counts (`v = m`, e.g. conditionally Poisson) the mixture variance
is at least the mixture mean. -/
theorem overdispersion (w m : ι → ℝ) (hw : ∑ i, w i = 1) (hwnn : ∀ i, 0 ≤ w i) :
    mixMean w m ≤ mixVar w m m := by
  rw [law_total_variance w m m hw]
  have hnn : 0 ≤ ∑ i, w i * (m i - mixMean w m) ^ 2 :=
    Finset.sum_nonneg fun i _ => mul_nonneg (hwnn i) (sq_nonneg _)
  have h2 : (∑ i, w i * m i) = mixMean w m := rfl
  linarith [hnn, h2.ge]

/-- Equality in `overdispersion` holds exactly when the rate layer is
degenerate: all indices carrying weight share the same rate.  So *any* excess
dispersion forces genuine between-index rate variation. -/
theorem equidispersion_iff (w m : ι → ℝ) (hw : ∑ i, w i = 1) (hwnn : ∀ i, 0 ≤ w i) :
    mixVar w m m = mixMean w m ↔ ∀ i, w i ≠ 0 → m i = mixMean w m := by
  rw [law_total_variance w m m hw]
  have hmean : (∑ i, w i * m i) = mixMean w m := rfl
  rw [hmean]
  constructor
  · intro h i hi
    have hzero : ∑ j, w j * (m j - mixMean w m) ^ 2 = 0 := by linarith
    have hterm := (Finset.sum_eq_zero_iff_of_nonneg
      (fun j (_ : j ∈ (Finset.univ : Finset ι)) => mul_nonneg (hwnn j) (sq_nonneg _))).1 hzero i
      (Finset.mem_univ i)
    rcases mul_eq_zero.1 hterm with h1 | h2
    · exact absurd h1 hi
    · have := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h2
      linarith
  · intro h
    have hzero : ∑ i, w i * (m i - mixMean w m) ^ 2 = 0 := by
      refine Finset.sum_eq_zero fun i _ => ?_
      by_cases hi : w i = 0
      · simp [hi]
      · rw [h i hi]; ring
    linarith

end Dispersion

/-!
## The two layers are logically independent

The experiment's joint conclusion with round-80 #1 is that between-`N` rate
overdispersion is *not* carried by positional profile heterogeneity.  The two
theorems below show that no implication can hold in either direction.
-/

/-- **Arbitrarily large overdispersion with a perfectly homogeneous positional
layer.**  For every `C` there is a two-layer model whose positional profiles are
all equal, yet whose dispersion excess `Var − Mean` exceeds `C · Mean`. -/
theorem overdispersion_without_profile_heterogeneity (C : ℝ) :
    ∃ (M : TwoLayer (Fin 2) (Fin 2)) (w : Fin 2 → ℝ),
      (∀ i, 0 ≤ w i) ∧ (∑ i, w i = 1) ∧ (∀ i j, M.prof i = M.prof j) ∧
      C * mixMean w M.rate ≤ mixVar w M.rate M.rate - mixMean w M.rate := by
  set s : ℝ := 4 * |C| + 4 with hs
  have hsC : |C| ≤ s := by
    have := abs_nonneg C; simp only [hs]; linarith
  refine ⟨{ rate := ![1, 1 + s]
            rate_pos := by
              intro i
              fin_cases i
              · norm_num
              · have := abs_nonneg C
                simp only [hs]
                norm_num
                linarith
            prof := fun _ => ![1/2, 1/2]
            prof_nonneg := by intro i b; fin_cases b <;> norm_num
            prof_sum := by intro i; simp [Fin.sum_univ_two]; norm_num },
          ![1/2, 1/2], ?_, ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · simp [Fin.sum_univ_two]; norm_num
  · intro i j; rfl
  · have habs : 0 ≤ |C| := abs_nonneg C
    have hCle : C ≤ |C| := le_abs_self C
    simp only [mixMean, mixVar, Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one, hs]
    nlinarith [habs, hCle, sq_nonneg (|C| + 1), sq_nonneg C]

/-- **Maximal positional heterogeneity with exact equidispersion.**  There is a
two-layer model with constant rates (hence variance equal to mean: no
overdispersion at all) whose two positional profiles are mutually singular, i.e.
at total-variation distance `1`. -/
theorem profile_heterogeneity_without_equidispersion :
    ∃ (M : TwoLayer (Fin 2) (Fin 2)) (w : Fin 2 → ℝ),
      (∀ i, 0 ≤ w i) ∧ (∑ i, w i = 1) ∧
      mixVar w M.rate M.rate = mixMean w M.rate ∧
      (1 / 2) * ∑ b, |M.prof 0 b - M.prof 1 b| = 1 := by
  refine ⟨{ rate := fun _ => 1
            rate_pos := by intro i; norm_num
            prof := ![![1, 0], ![0, 1]]
            prof_nonneg := by intro i b; fin_cases i <;> fin_cases b <;> norm_num
            prof_sum := by intro i; fin_cases i <;> simp [Fin.sum_univ_two] },
          ![1/2, 1/2], ?_, ?_, ?_, ?_⟩
  · intro i; fin_cases i <;> norm_num
  · simp [Fin.sum_univ_two]; norm_num
  · simp [mixMean, mixVar, Fin.sum_univ_two]; norm_num
  · simp [Fin.sum_univ_two]
    norm_num

end PositionalRateLink