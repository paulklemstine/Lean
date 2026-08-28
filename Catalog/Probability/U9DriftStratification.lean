/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib
import Probability.U9DriftLocalDensity

/-!
# Stratifying the band-9 moduli by quadratic class: an exact variance accounting

Context (experiment 569, paper 216).  `Catalog/Probability/U9DriftLocalDensity.lean` shows
that the multiplicative bias of one modulus across `k` small primes,
`signProd e = ∏ i, (1 + ε i)` with `ε i = ±1` the quadratic characters, has mean `1` and
variance `2 ^ k - 1`: the between-modulus dispersion that forces the cluster bootstrap is
exponentially large.  Conjecture **C1** of `FUTURE_DIRECTIONS.md` (sub-conjecture **A**)
proposed to remove that dispersion by *stratifying* the moduli on the quadratic-class
statistic `∑_{p} χ_p(N)`, i.e. on the number of primes at which `N` is a residue.

This file closes the structural half of that conjecture.

* `U9Drift.strat_ss_decomposition` — the exact one-way ANOVA identity for an arbitrary
  finite population `Ω`, an arbitrary real-valued statistic `f` and an arbitrary
  stratifying map `key : Ω → κ`:
  `totalSS = withinSS + betweenSS`.  No balance assumption: fibres may have any sizes,
  including zero.
* `U9Drift.withinSS_le_totalSS` — hence stratification never increases the residual
  dispersion, and `U9Drift.betweenSS_le_totalSS`.
* `U9Drift.withinSS_eq_zero_of_fiberwise_constant` /
  `U9Drift.betweenSS_eq_totalSS_of_fiberwise_constant` — a statistic that is a function of
  the stratum key has *no* within-stratum dispersion at all.
* `U9Drift.signProd_eq_ite` and `U9Drift.signProd_eq_of_classCount_eq` — the multiplicative
  bias is a function of the quadratic-class count `classCount e = #{i | ε i = +1}` alone.
* `U9Drift.totalSS_signProd` — the population sum of squares of the bias is exactly
  `2 ^ k * (2 ^ k - 1)`, matching `variance_signProd`.
* `U9Drift.classCount_stratification_is_exact` — **the conjecture, proved**: stratifying by
  the quadratic-class count leaves zero within-stratum dispersion, so it accounts for the
  entire `2 ^ k - 1` between-modulus variance.
* `U9Drift.classCount_stratification_beats_coarse` — the accounting is not vacuous: the
  trivial (single-stratum) design leaves *all* of the dispersion unexplained, and for
  `k ≥ 1` that is a strictly positive amount.
-/

namespace U9Drift

open Finset

section Stratification

variable {Ω : Type*} [Fintype Ω] {κ : Type*} [DecidableEq κ]

/-- The stratum (fibre) of the stratifying map `key` above the label `c`. -/
def fiber (key : Ω → κ) (c : κ) : Finset Ω := univ.filter (fun x => key x = c)

/-- The mean of `f` over the stratum `c` (`0` on an empty stratum). -/
def fiberMean (f : Ω → ℚ) (key : Ω → κ) (c : κ) : ℚ :=
  (∑ x ∈ fiber key c, f x) / (fiber key c).card

/-- The mean of `f` over the whole population (`0` on an empty population). -/
def popMean (f : Ω → ℚ) : ℚ := (∑ x, f x) / (Fintype.card Ω)

/-- Total sum of squares: dispersion of `f` about the population mean. -/
def totalSS (f : Ω → ℚ) : ℚ := ∑ x, (f x - popMean f) ^ 2

/-- Within-stratum sum of squares. -/
def withinSS (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ) : ℚ :=
  ∑ c ∈ K, ∑ x ∈ fiber key c, (f x - fiberMean f key c) ^ 2

/-- Between-stratum sum of squares. -/
def betweenSS (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ) : ℚ :=
  ∑ c ∈ K, (fiber key c).card * (fiberMean f key c - popMean f) ^ 2

omit [Fintype Ω] in
/-- The one-block shift identity: dispersion of `f` on a finite block `F` about an
arbitrary centre `m` splits into the dispersion about the block mean plus the squared
displacement of the block mean, weighted by the block size. -/
theorem block_ss_shift (F : Finset Ω) (f : Ω → ℚ) (m : ℚ) :
    ∑ x ∈ F, (f x - m) ^ 2
      = (∑ x ∈ F, (f x - (∑ y ∈ F, f y) / F.card) ^ 2)
        + F.card * ((∑ y ∈ F, f y) / F.card - m) ^ 2 := by
  set mF : ℚ := (∑ y ∈ F, f y) / F.card with hmF
  have hcenter : ∑ x ∈ F, (f x - mF) = 0 := by
    rcases Nat.eq_zero_or_pos F.card with h0 | hpos
    · simp [Finset.card_eq_zero.mp h0]
    · have hne : (F.card : ℚ) ≠ 0 := by positivity
      rw [Finset.sum_sub_distrib]
      rw [Finset.sum_const, nsmul_eq_mul, hmF]
      field_simp
      ring
  have hexp : ∀ x ∈ F, (f x - m) ^ 2
      = (f x - mF) ^ 2 + 2 * (mF - m) * (f x - mF) + (mF - m) ^ 2 := by
    intro x _
    ring
  rw [Finset.sum_congr rfl hexp]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib, ← Finset.mul_sum, hcenter,
    Finset.sum_const, nsmul_eq_mul]
  ring

/-- **Exact one-way ANOVA decomposition.**  For any finite population, any statistic and
any stratification whose labels lie in `K`, the total dispersion splits *exactly* into the
within-stratum and the between-stratum parts.  No balance or nonemptiness assumption. -/
theorem strat_ss_decomposition (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ)
    (hK : ∀ x, key x ∈ K) :
    totalSS f = withinSS f key K + betweenSS f key K := by
  have hmaps : ∀ x ∈ (univ : Finset Ω), key x ∈ K := fun x _ => hK x
  have hfib : ∑ c ∈ K, ∑ x ∈ fiber key c, (f x - popMean f) ^ 2
      = ∑ x, (f x - popMean f) ^ 2 :=
    Finset.sum_fiberwise_of_maps_to hmaps _
  have hblock : ∀ c ∈ K, ∑ x ∈ fiber key c, (f x - popMean f) ^ 2
      = (∑ x ∈ fiber key c, (f x - fiberMean f key c) ^ 2)
        + (fiber key c).card * (fiberMean f key c - popMean f) ^ 2 := by
    intro c _
    simpa [fiberMean] using block_ss_shift (fiber key c) f (popMean f)
  calc totalSS f = ∑ c ∈ K, ∑ x ∈ fiber key c, (f x - popMean f) ^ 2 := by
        rw [hfib]; rfl
    _ = ∑ c ∈ K, ((∑ x ∈ fiber key c, (f x - fiberMean f key c) ^ 2)
          + (fiber key c).card * (fiberMean f key c - popMean f) ^ 2) :=
        Finset.sum_congr rfl hblock
    _ = withinSS f key K + betweenSS f key K := by
        rw [Finset.sum_add_distrib]; rfl

theorem withinSS_nonneg (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ) :
    0 ≤ withinSS f key K := by
  refine Finset.sum_nonneg fun c _ => Finset.sum_nonneg fun x _ => ?_
  positivity

theorem betweenSS_nonneg (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ) :
    0 ≤ betweenSS f key K := by
  refine Finset.sum_nonneg fun c _ => ?_
  positivity

/-- **Stratification never hurts.**  The unexplained (within-stratum) dispersion is at most
the total dispersion, for every stratification. -/
theorem withinSS_le_totalSS (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ)
    (hK : ∀ x, key x ∈ K) : withinSS f key K ≤ totalSS f := by
  have := strat_ss_decomposition f key K hK
  have hb := betweenSS_nonneg f key K
  linarith

/-- Dually, the explained dispersion never exceeds the total. -/
theorem betweenSS_le_totalSS (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ)
    (hK : ∀ x, key x ∈ K) : betweenSS f key K ≤ totalSS f := by
  have := strat_ss_decomposition f key K hK
  have hw := withinSS_nonneg f key K
  linarith

/-- A statistic that is a function of the stratum label has no within-stratum dispersion. -/
theorem withinSS_eq_zero_of_fiberwise_constant (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ)
    (g : κ → ℚ) (hg : ∀ x, f x = g (key x)) : withinSS f key K = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  have hval : ∀ x ∈ fiber key c, f x = g c := by
    intro x hx
    have : key x = c := by simpa [fiber] using hx
    rw [hg x, this]
  rcases Finset.eq_empty_or_nonempty (fiber key c) with he | hne
  · simp [he]
  · have hcard : ((fiber key c).card : ℚ) ≠ 0 := by
      have : 0 < (fiber key c).card := Finset.card_pos.mpr hne
      positivity
    have hsum : ∑ x ∈ fiber key c, f x = (fiber key c).card * g c := by
      rw [Finset.sum_congr rfl hval, Finset.sum_const, nsmul_eq_mul]
    have hmean : fiberMean f key c = g c := by
      rw [fiberMean, hsum]
      field_simp
    refine Finset.sum_eq_zero fun x hx => ?_
    rw [hmean, hval x hx]
    ring

/-- Consequently such a stratification explains the entire dispersion. -/
theorem betweenSS_eq_totalSS_of_fiberwise_constant (f : Ω → ℚ) (key : Ω → κ) (K : Finset κ)
    (hK : ∀ x, key x ∈ K) (g : κ → ℚ) (hg : ∀ x, f x = g (key x)) :
    betweenSS f key K = totalSS f := by
  rw [strat_ss_decomposition f key K hK,
    withinSS_eq_zero_of_fiberwise_constant f key K g hg, zero_add]

end Stratification

/-! ## Application: the quadratic-class stratification of the multiplicative bias -/

/-- The quadratic-class count of a modulus: the number of small primes at which `N` is a
quadratic residue (`ε i = +1`, coded `e i = true`). -/
def classCount {k : ℕ} (e : Fin k → Bool) : ℕ := (univ.filter (fun i => e i = true)).card

theorem classCount_le {k : ℕ} (e : Fin k → Bool) : classCount e ≤ k := by
  simpa [classCount] using
    (Finset.card_filter_le (univ : Finset (Fin k)) (fun i => e i = true))

/-- The multiplicative bias collapses: it is `2 ^ k` when `N` is a residue at every prime of
the set and `0` as soon as it is a non-residue at one of them. -/
theorem signProd_eq_ite {k : ℕ} (e : Fin k → Bool) :
    signProd e = if ∀ i, e i = true then (2 : ℚ) ^ k else 0 := by
  by_cases h : ∀ i, e i = true
  · simp only [h]
    rw [signProd]
    rw [Finset.prod_congr rfl (fun i _ => by rw [h i]; norm_num : ∀ i ∈ univ,
      (1 + if e i then (1 : ℚ) else -1) = 2)]
    simp
  · simp only [h, if_neg, not_false_eq_true]
    push_neg at h
    obtain ⟨i, hi⟩ := h
    refine Finset.prod_eq_zero (Finset.mem_univ i) ?_
    have hif : e i = false := by simpa using hi
    simp [hif]

/-- The bias is a function of the quadratic-class count alone: this is exactly the
statistic sub-conjecture **A** proposed to stratify on. -/
theorem signProd_eq_classCount_fun {k : ℕ} (e : Fin k → Bool) :
    signProd e = if classCount e = k then (2 : ℚ) ^ k else 0 := by
  rw [signProd_eq_ite]
  have hiff : (∀ i, e i = true) ↔ classCount e = k := by
    constructor
    · intro h
      simp [classCount, Finset.filter_true_of_mem (fun i _ => h i)]
    · intro h i
      by_contra hi
      have hsub : (univ.filter (fun j => e j = true)) ⊂ (univ : Finset (Fin k)) := by
        refine Finset.ssubset_univ_iff.mpr ?_
        intro hEq
        have : i ∈ univ.filter (fun j => e j = true) := by rw [hEq]; exact Finset.mem_univ i
        exact hi (by simpa using this)
      have hlt := Finset.card_lt_card hsub
      simp only [Finset.card_univ, Fintype.card_fin] at hlt
      simp only [classCount] at h
      omega
  by_cases h : ∀ i, e i = true
  · simp [h, hiff.mp h]
  · have : ¬ classCount e = k := fun hc => h (hiff.mpr hc)
    simp [h, this]

/-- Two moduli in the same quadratic-class stratum carry the same multiplicative bias. -/
theorem signProd_eq_of_classCount_eq {k : ℕ} {e e' : Fin k → Bool}
    (h : classCount e = classCount e') : signProd e = signProd e' := by
  rw [signProd_eq_classCount_fun, signProd_eq_classCount_fun, h]

/-- The population mean of the bias over the `2 ^ k` sign patterns is `1`
(`mean_signProd`, restated for the `popMean` of this file). -/
theorem popMean_signProd (k : ℕ) : popMean (fun e : Fin k → Bool => signProd e) = 1 := by
  have hcard : (Fintype.card (Fin k → Bool) : ℚ) = 2 ^ k := by
    simp
  rw [popMean, hcard]
  exact mean_signProd k

/-- The total sum of squares of the multiplicative bias is `2 ^ k * (2 ^ k - 1)`: the
unnormalised form of `variance_signProd`. -/
theorem totalSS_signProd (k : ℕ) :
    totalSS (fun e : Fin k → Bool => signProd e) = 2 ^ k * (2 ^ k - 1) := by
  have hexp : ∀ e : Fin k → Bool, (signProd e - 1) ^ 2
      = signProd e ^ 2 - 2 * signProd e + 1 := by
    intro e; ring
  rw [totalSS, popMean_signProd]
  rw [Finset.sum_congr rfl (fun e _ => hexp e)]
  rw [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
    sum_signProd_sq, sum_signProd, Finset.sum_const, nsmul_eq_mul]
  have hcard : ((univ : Finset (Fin k → Bool)).card : ℚ) = 2 ^ k := by
    simp
  rw [hcard, show (4 : ℚ) ^ k = 2 ^ k * 2 ^ k by rw [← mul_pow]; norm_num]
  ring

/-- **Sub-conjecture A, structural half: proved.**  Stratifying the moduli by the
quadratic-class count leaves *zero* within-stratum dispersion of the multiplicative bias,
so the stratification accounts for the whole between-modulus variance `2 ^ k - 1`. -/
theorem classCount_stratification_is_exact (k : ℕ) :
    withinSS (fun e : Fin k → Bool => signProd e) classCount (Finset.range (k + 1)) = 0 ∧
    betweenSS (fun e : Fin k → Bool => signProd e) classCount (Finset.range (k + 1))
      = 2 ^ k * (2 ^ k - 1) := by
  have hK : ∀ e : Fin k → Bool, classCount e ∈ Finset.range (k + 1) := by
    intro e
    exact Finset.mem_range.mpr (Nat.lt_succ_of_le (classCount_le e))
  have hg : ∀ e : Fin k → Bool,
      signProd e = (fun c : ℕ => if c = k then (2 : ℚ) ^ k else 0) (classCount e) :=
    fun e => signProd_eq_classCount_fun e
  refine ⟨withinSS_eq_zero_of_fiberwise_constant _ _ _
    (fun c : ℕ => if c = k then (2 : ℚ) ^ k else 0) hg, ?_⟩
  rw [betweenSS_eq_totalSS_of_fiberwise_constant _ _ _ hK
    (fun c : ℕ => if c = k then (2 : ℚ) ^ k else 0) hg, totalSS_signProd]

/-- The accounting is not vacuous: the trivial one-stratum design explains nothing, and for
`k ≥ 1` the amount left unexplained is strictly positive — exactly the dispersion the
class-count stratification removes. -/
theorem classCount_stratification_beats_coarse (k : ℕ) (hk : 1 ≤ k) :
    betweenSS (fun e : Fin k → Bool => signProd e) (fun _ => (0 : ℕ)) {0} = 0 ∧
    0 < withinSS (fun e : Fin k → Bool => signProd e) (fun _ => (0 : ℕ)) {0} := by
  have hK : ∀ e : Fin k → Bool, (fun _ => (0 : ℕ)) e ∈ ({0} : Finset ℕ) := by simp
  have hfib : fiber (fun _ : Fin k → Bool => (0 : ℕ)) 0 = univ := by
    ext e; simp [fiber]
  have hmean : fiberMean (fun e : Fin k → Bool => signProd e) (fun _ => (0 : ℕ)) 0
      = popMean (fun e : Fin k → Bool => signProd e) := by
    rw [fiberMean, popMean, hfib]
    congr 1
  have hbet : betweenSS (fun e : Fin k → Bool => signProd e) (fun _ => (0 : ℕ)) {0} = 0 := by
    rw [betweenSS]
    simp [hmean]
  refine ⟨hbet, ?_⟩
  have hdec := strat_ss_decomposition (fun e : Fin k → Bool => signProd e)
    (fun _ => (0 : ℕ)) {0} hK
  have htot : totalSS (fun e : Fin k → Bool => signProd e) = 2 ^ k * (2 ^ k - 1) :=
    totalSS_signProd k
  have hpos : (0 : ℚ) < 2 ^ k * (2 ^ k - 1) := by
    have h2 : (2 : ℚ) ^ 1 ≤ 2 ^ k := pow_le_pow_right₀ (by norm_num) hk
    have h1 : (0 : ℚ) < 2 ^ k - 1 := by
      have : (2 : ℚ) ^ 1 = 2 := by norm_num
      linarith [h2, this.symm.le]
    have h0 : (0 : ℚ) < 2 ^ k := by positivity
    exact mul_pos h0 h1
  rw [htot, hbet, add_zero] at hdec
  linarith [hdec, hpos]

end U9Drift