import Mathlib
import Bridges.InformationGeometry.FisherMetric
import Speculative.AutoResearch.PinskerInequality

/-!
# Relative entropy for distributions with zero mass

The finite information-geometric results of
`Bridges/InformationGeometry/FisherMetric.lean` (Gibbs' inequality, the Fisher
upper bound) and of `Speculative/AutoResearch/PinskerInequality.lean`
(`general_pinsker`) are all stated for *strictly positive* probability vectors.
This file removes that restriction, using the explicit absolute-continuity
convention

`AbsCont p q ↔ ∀ i, q i = 0 → p i = 0`,

which is exactly what makes the Lean-level convention `0 * Real.log (0/0) = 0`
agree with the measure-theoretic one (a coordinate with `q i = 0 < p i` would
have to contribute `+∞` and is therefore excluded).

## Main results

* `InformationGeometry.klDiv_nonneg_of_absCont` — Gibbs' inequality for
  nonnegative weight vectors with zero mass allowed.
* `InformationGeometry.change_of_measure` — the finite PAC-Bayes / Donsker–
  Varadhan change-of-measure inequality
  `∑ p f ≤ KL(p‖q) + log (∑ q exp f)` with zero mass allowed.
* `InformationGeometry.change_of_measure_tight` — the bound is attained (hence
  `KL` is the convex conjugate of `f ↦ log ∑ q exp f`) when `p` and `q` are
  mutually absolutely continuous.
* `InformationGeometry.change_of_measure_iff_absCont` — the change-of-measure
  bound holds for every tilt `f` exactly when `AbsCont p q`, so the
  absolute-continuity convention is necessary, not merely convenient.
* `InformationGeometry.pinsker_of_zero_mass` — Pinsker's inequality when `p` is
  allowed to vanish, obtained from the strictly positive case by a
  continuity argument.
* `InformationGeometry.pac_bayes_bound` — a PAC-Bayes style deviation bound
  obtained by combining change of measure with Pinsker.
-/

noncomputable section

open Finset

namespace InformationGeometry

variable {ι : Type*} [Fintype ι]

/-- Absolute continuity of `p` with respect to `q` for finite weight vectors. -/
def AbsCont (p q : ι → ℝ) : Prop := ∀ i, q i = 0 → p i = 0

/-- The support of a weight vector. -/
def supp (p : ι → ℝ) : Finset ι := univ.filter fun i => p i ≠ 0

theorem mem_supp {p : ι → ℝ} {i : ι} : i ∈ supp p ↔ p i ≠ 0 := by
  simp [supp]

/-- Only the support of `p` contributes to `klDiv p q`. -/
theorem klDiv_eq_sum_supp (p q : ι → ℝ) :
    klDiv p q = ∑ i ∈ supp p, p i * Real.log (p i / q i) := by
  rw [klDiv]
  refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
  intro i _ hi
  rw [mem_supp, not_not] at hi
  simp [hi]

/-- On the support of `p`, absolute continuity makes `q` strictly positive. -/
theorem pos_of_mem_supp {p q : ι → ℝ} (hq0 : ∀ i, 0 ≤ q i) (hac : AbsCont p q)
    {i : ι} (hi : i ∈ supp p) : 0 < q i := by
  rcases (hq0 i).lt_or_eq with h | h
  · exact h
  · exact absurd (hac i h.symm) (mem_supp.mp hi)

/-! ## Gibbs' inequality with zero mass -/

/-- **Gibbs' inequality with zero mass allowed.** If `p` and `q` are nonnegative
and sum to `1`, and `p` is absolutely continuous with respect to `q`, then the
relative entropy is nonnegative. -/
theorem klDiv_nonneg_of_absCont (p q : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq0 : ∀ i, 0 ≤ q i) (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1)
    (hac : AbsCont p q) : 0 ≤ klDiv p q := by
  rw [klDiv_eq_sum_supp]
  have hterm : ∀ i ∈ supp p, p i - q i ≤ p i * Real.log (p i / q i) := by
    intro i hi
    have hpi : 0 < p i := lt_of_le_of_ne (hp0 i) (Ne.symm (mem_supp.mp hi))
    have hqi : 0 < q i := pos_of_mem_supp hq0 hac hi
    have hlog := Real.log_le_sub_one_of_pos (div_pos hqi hpi)
    rw [Real.log_div (ne_of_gt hqi) (ne_of_gt hpi)] at hlog
    rw [Real.log_div (ne_of_gt hpi) (ne_of_gt hqi)]
    have hkey : 1 - q i / p i ≤ Real.log (p i) - Real.log (q i) := by linarith
    have := mul_le_mul_of_nonneg_left hkey hpi.le
    have hcancel : p i * (1 - q i / p i) = p i - q i := by
      field_simp
    linarith [hcancel ▸ this]
  have h1 : ∑ i ∈ supp p, (p i - q i) ≤ ∑ i ∈ supp p, p i * Real.log (p i / q i) :=
    Finset.sum_le_sum hterm
  have h2 : ∑ i ∈ supp p, p i = 1 := by
    rw [← hps]
    refine Finset.sum_subset (Finset.subset_univ (supp p)) ?_
    intro i _ hi
    rw [mem_supp, not_not] at hi
    exact hi
  have h3 : ∑ i ∈ supp p, q i ≤ 1 := by
    rw [← hqs]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      fun i _ _ => hq0 i
  rw [Finset.sum_sub_distrib, h2] at h1
  linarith

/-! ## Change of measure -/

/-- The exponential partition function of `f` under `q` is positive. -/
theorem exp_partition_pos (q : ι → ℝ) (f : ι → ℝ) (hq0 : ∀ i, 0 ≤ q i)
    (hqs : ∑ i, q i = 1) : 0 < ∑ i, q i * Real.exp (f i) := by
  obtain ⟨j, -, hj⟩ : ∃ j ∈ univ, 0 < q j := by
    by_contra hcon
    push_neg at hcon
    have : ∑ i, q i ≤ 0 :=
      Finset.sum_nonpos fun i hi => hcon i hi
    rw [hqs] at this
    linarith
  refine lt_of_lt_of_le ?_ (Finset.single_le_sum
    (f := fun i => q i * Real.exp (f i))
    (fun i _ => mul_nonneg (hq0 i) (Real.exp_pos _).le) (Finset.mem_univ j))
  exact mul_pos hj (Real.exp_pos _)

/-- **The finite PAC-Bayes change-of-measure inequality** (Donsker–Varadhan),
valid for nonnegative weight vectors with zero mass, under absolute
continuity. -/
theorem change_of_measure (p q : ι → ℝ) (f : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq0 : ∀ i, 0 ≤ q i) (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1)
    (hac : AbsCont p q) :
    ∑ i, p i * f i ≤ klDiv p q + Real.log (∑ i, q i * Real.exp (f i)) := by
  set Z : ℝ := ∑ i, q i * Real.exp (f i) with hZ
  have hZpos : 0 < Z := exp_partition_pos q f hq0 hqs
  set g : ι → ℝ := fun i => q i * Real.exp (f i) / Z with hg
  have hg0 : ∀ i, 0 ≤ g i := fun i =>
    div_nonneg (mul_nonneg (hq0 i) (Real.exp_pos _).le) hZpos.le
  have hgs : ∑ i, g i = 1 := by
    rw [hg, ← Finset.sum_div, ← hZ, div_self (ne_of_gt hZpos)]
  have hacg : AbsCont p g := by
    intro i hi
    refine hac i ?_
    rw [hg] at hi
    have := (div_eq_zero_iff.mp hi).resolve_right (ne_of_gt hZpos)
    exact (mul_eq_zero.mp this).resolve_right (ne_of_gt (Real.exp_pos _))
  have hnn := klDiv_nonneg_of_absCont p g hp0 hg0 hps hgs hacg
  have hsplit : klDiv p g = klDiv p q - ∑ i, p i * f i + Real.log Z := by
    rw [klDiv_eq_sum_supp, klDiv_eq_sum_supp]
    have hf : ∑ i, p i * f i = ∑ i ∈ supp p, p i * f i := by
      refine (Finset.sum_subset (Finset.subset_univ _) ?_).symm
      intro i _ hi
      rw [mem_supp, not_not] at hi
      simp [hi]
    rw [hf]
    have hlogZ : Real.log Z = ∑ i ∈ supp p, p i * Real.log Z := by
      rw [← Finset.sum_mul]
      have h2 : ∑ i ∈ supp p, p i = 1 := by
        rw [← hps]
        refine Finset.sum_subset (Finset.subset_univ (supp p)) ?_
        intro i _ hi
        rw [mem_supp, not_not] at hi
        exact hi
      rw [h2, one_mul]
    rw [hlogZ, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun i hi => ?_
    have hpi : 0 < p i := lt_of_le_of_ne (hp0 i) (Ne.symm (mem_supp.mp hi))
    have hqi : 0 < q i := pos_of_mem_supp hq0 hac hi
    have hgi : g i = q i * Real.exp (f i) / Z := rfl
    rw [hgi]
    have hrewrite : p i / (q i * Real.exp (f i) / Z)
        = p i / q i * Real.exp (-f i) * Z := by
      rw [Real.exp_neg]
      field_simp
    rw [hrewrite, Real.log_mul (by positivity) (ne_of_gt hZpos),
      Real.log_mul (by positivity) (by positivity), Real.log_exp]
    ring
  linarith

/-- **Tightness of the change-of-measure bound.**  When `p` and `q` are mutually
absolutely continuous, the choice `f = log (p/q)` turns `change_of_measure` into
an equality; hence `klDiv p q` is the supremum of `∑ p f - log ∑ q exp f`. -/
theorem change_of_measure_tight (p q : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq0 : ∀ i, 0 ≤ q i) (hps : ∑ i, p i = 1)
    (hac : AbsCont p q) (hca : AbsCont q p) :
    ∃ f : ι → ℝ,
      ∑ i, p i * f i = klDiv p q + Real.log (∑ i, q i * Real.exp (f i)) := by
  refine ⟨fun i => Real.log (p i / q i), ?_⟩
  have hZ : ∑ i, q i * Real.exp (Real.log (p i / q i)) = 1 := by
    rw [← hps]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases hpi : p i = 0
    · by_cases hqi : q i = 0
      · simp [hpi, hqi]
      · have hqpos : 0 < q i := lt_of_le_of_ne (hq0 i) (Ne.symm hqi)
        simp [hpi, Real.exp_zero, hqi]
        exact absurd (hca i hpi) hqi
    · have hqi : q i ≠ 0 := fun h => hpi (hac i h)
      have hqpos : 0 < q i := lt_of_le_of_ne (hq0 i) (Ne.symm hqi)
      have hppos : 0 < p i := lt_of_le_of_ne (hp0 i) (Ne.symm hpi)
      rw [Real.exp_log (div_pos hppos hqpos)]
      field_simp
  rw [hZ, Real.log_one, add_zero, klDiv]


/-- **Necessity of absolute continuity.**  If some coordinate has `q i = 0` but
`p i > 0`, the (Lean-finite) change-of-measure bound fails for an explicit
exponential tilt, so the hypothesis `AbsCont p q` in `change_of_measure` cannot
be dropped. -/
theorem change_of_measure_necessary (p q : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hqs : ∑ i, q i = 1) (hac : ¬ AbsCont p q) :
    ∃ f : ι → ℝ,
      klDiv p q + Real.log (∑ i, q i * Real.exp (f i)) < ∑ i, p i * f i := by
  classical
  rw [AbsCont] at hac
  push_neg at hac
  obtain ⟨j, hqj, hpj⟩ := hac
  have hpjpos : 0 < p j := lt_of_le_of_ne (hp0 j) (Ne.symm hpj)
  set t : ℝ := (klDiv p q + 1) / p j with ht
  refine ⟨fun i => if i = j then t else 0, ?_⟩
  have h1 : ∑ i, q i * Real.exp (if i = j then t else 0) = 1 := by
    rw [← hqs]
    refine Finset.sum_congr rfl fun i _ => ?_
    by_cases h : i = j
    · subst h; simp [hqj]
    · simp [h]
  have h2 : ∑ i, p i * (if i = j then t else 0) = p j * t := by
    rw [Finset.sum_eq_single j]
    · simp
    · intro b _ hb; simp [hb]
    · intro h; exact absurd (Finset.mem_univ j) h
  have h3 : p j * t = klDiv p q + 1 := by
    rw [ht]
    field_simp
  rw [h1, h2, h3, Real.log_one, add_zero]
  linarith

/-- **The change-of-measure bound characterises absolute continuity.** -/
theorem change_of_measure_iff_absCont (p q : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq0 : ∀ i, 0 ≤ q i) (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (∀ f : ι → ℝ,
        ∑ i, p i * f i ≤ klDiv p q + Real.log (∑ i, q i * Real.exp (f i)))
      ↔ AbsCont p q := by
  constructor
  · intro h
    by_contra hac
    obtain ⟨f, hf⟩ := change_of_measure_necessary p q hp0 hqs hac
    exact absurd (h f) (not_le.mpr hf)
  · intro hac f
    exact change_of_measure p q f hp0 hq0 hps hqs hac

/-! ## Pinsker's inequality with zero mass -/

/-- The relative entropy along the interpolation `p_e = (1-e)p + e q` is a
continuous function of `e` when `q` is strictly positive. -/
theorem continuous_klDiv_interp (p q : ι → ℝ) (hq : ∀ i, 0 < q i) :
    Continuous fun e : ℝ => klDiv (fun i => (1 - e) * p i + e * q i) q := by
  have hrw : (fun e : ℝ => klDiv (fun i => (1 - e) * p i + e * q i) q)
      = fun e : ℝ => ∑ i, (((1 - e) * p i + e * q i) *
          Real.log ((1 - e) * p i + e * q i)
          - ((1 - e) * p i + e * q i) * Real.log (q i)) := by
    funext e
    rw [klDiv]
    refine Finset.sum_congr rfl fun i _ => ?_
    set x : ℝ := (1 - e) * p i + e * q i with hx
    by_cases hx0 : x = 0
    · simp [hx0]
    · rw [Real.log_div hx0 (ne_of_gt (hq i))]
      ring
  rw [hrw]
  refine continuous_finset_sum _ fun i _ => ?_
  have hcont : Continuous fun e : ℝ => (1 - e) * p i + e * q i := by fun_prop
  exact (Real.continuous_mul_log.comp hcont).sub (hcont.mul continuous_const)

/-- **Pinsker's inequality with zero mass in `p`.**  For a nonnegative `p` and a
strictly positive `q`, both summing to one,
`(1/2) ‖p - q‖₁² ≤ KL(p ‖ q)`.  This generalises
`PinskerInequality.general_pinsker`, which requires `p` to be strictly
positive. -/
theorem pinsker_of_zero_mass (p q : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq : ∀ i, 0 < q i) (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    (1 / 2) * (∑ i, |p i - q i|) ^ 2 ≤ klDiv p q := by
  set L : ℝ := ∑ i, |p i - q i| with hL
  set F : ℝ → ℝ := fun e => klDiv (fun i => (1 - e) * p i + e * q i) q with hF
  have hFcont : Continuous F := continuous_klDiv_interp p q hq
  set G : ℝ → ℝ := fun e => (1 / 2) * ((1 - e) * L) ^ 2 with hG
  have hGcont : Continuous G := by fun_prop
  have hle : ∀ e ∈ Set.Ioo (0 : ℝ) 1, G e ≤ F e := by
    intro e he
    obtain ⟨he0, he1⟩ := he
    have hrpos : ∀ i, 0 < (1 - e) * p i + e * q i := by
      intro i
      have h1 : 0 ≤ (1 - e) * p i := mul_nonneg (by linarith) (hp0 i)
      have h2 : 0 < e * q i := mul_pos he0 (hq i)
      linarith
    have hrs : ∑ i, ((1 - e) * p i + e * q i) = 1 := by
      rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, hps, hqs]
      ring
    have hpin := PinskerInequality.general_pinsker
      (fun i => (1 - e) * p i + e * q i) q hrpos hq hrs hqs
    have hsum : ∑ i, |(1 - e) * p i + e * q i - q i| = (1 - e) * L := by
      rw [hL, Finset.mul_sum]
      refine Finset.sum_congr rfl fun i _ => ?_
      rw [show (1 - e) * p i + e * q i - q i = (1 - e) * (p i - q i) by ring,
        abs_mul, abs_of_nonneg (by linarith : (0:ℝ) ≤ 1 - e)]
    rw [hsum] at hpin
    simp only [hG, hF]
    exact hpin
  have hG0 : G 0 = (1 / 2) * L ^ 2 := by simp [hG]
  have hidL : (fun i => (1 - (0:ℝ)) * p i + (0:ℝ) * q i) = p := by
    funext i; ring
  have hF0 : F 0 = klDiv p q := by
    simp only [hF, hidL]
  have hlim : G 0 ≤ F 0 := by
    haveI hnb : (nhdsWithin (0 : ℝ) (Set.Ioo (0 : ℝ) 1)).NeBot := by
      rw [← mem_closure_iff_nhdsWithin_neBot, closure_Ioo (by norm_num : (0:ℝ) ≠ 1)]
      norm_num
    have tG : Filter.Tendsto G (nhdsWithin (0 : ℝ) (Set.Ioo (0 : ℝ) 1)) (nhds (G 0)) :=
      (hGcont.tendsto 0).mono_left nhdsWithin_le_nhds
    have tF : Filter.Tendsto F (nhdsWithin (0 : ℝ) (Set.Ioo (0 : ℝ) 1)) (nhds (F 0)) :=
      (hFcont.tendsto 0).mono_left nhdsWithin_le_nhds
    have hev : G ≤ᶠ[nhdsWithin (0 : ℝ) (Set.Ioo (0 : ℝ) 1)] F :=
      Filter.eventually_iff_exists_mem.mpr
        ⟨Set.Ioo (0 : ℝ) 1, self_mem_nhdsWithin, hle⟩
    exact le_of_tendsto_of_tendsto tG tF hev
  rw [hG0, hF0] at hlim
  exact hlim

/-- **A PAC-Bayes style deviation bound.**  Combining change of measure with the
zero-mass Pinsker inequality, for any bounded "loss" `f` the posterior mean is
controlled by the prior partition function and the relative entropy, and the
`L¹` distance between posterior and prior is controlled by the same quantity. -/
theorem pac_bayes_bound (p q : ι → ℝ) (f : ι → ℝ) (hp0 : ∀ i, 0 ≤ p i)
    (hq : ∀ i, 0 < q i) (hps : ∑ i, p i = 1) (hqs : ∑ i, q i = 1) :
    ∑ i, p i * f i ≤ klDiv p q + Real.log (∑ i, q i * Real.exp (f i)) ∧
      (∑ i, |p i - q i|) ^ 2 ≤ 2 * klDiv p q := by
  have hac : AbsCont p q := fun i hi => absurd hi (ne_of_gt (hq i))
  refine ⟨change_of_measure p q f hp0 (fun i => (hq i).le) hps hqs hac, ?_⟩
  have := pinsker_of_zero_mass p q hp0 hq hps hqs
  linarith


/-! ## A worked zero-mass example -/

/-- The deterministic distribution on two points is absolutely continuous with
respect to the uniform one, has a zero coordinate, and its relative entropy is
`log 2`. -/
theorem klDiv_deterministic_vs_uniform :
    klDiv (![1, 0] : Fin 2 → ℝ) ![1 / 2, 1 / 2] = Real.log 2 := by
  simp [klDiv, Fin.sum_univ_two]

/-- For that pair the zero-mass Pinsker inequality is valid but strict. -/
theorem pinsker_strict_deterministic_vs_uniform :
    (1 / 2) * (∑ i, abs ((![1, 0] : Fin 2 → ℝ) i - (![1 / 2, 1 / 2] : Fin 2 → ℝ) i)) ^ 2
      < klDiv (![1, 0] : Fin 2 → ℝ) ![1 / 2, 1 / 2] := by
  rw [klDiv_deterministic_vs_uniform]
  have hlhs : (1 / 2) *
      (∑ i, abs ((![1, 0] : Fin 2 → ℝ) i - (![1 / 2, 1 / 2] : Fin 2 → ℝ) i)) ^ 2
      = 1 / 2 := by
    norm_num [Fin.sum_univ_two]
  rw [hlhs]
  linarith [Real.log_two_gt_d9]

end InformationGeometry

end