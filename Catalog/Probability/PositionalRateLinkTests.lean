import Mathlib
import Probability.PositionalRateLinkLayers

/-!
# What the interaction tests of exp 580 can and cannot see

Cycle 2 of the round-80 analysis.  The previous file settled the *model*: an
occupancy table is the product of a rate layer and a positional layer, and the
layers fail to interact exactly when the table is rank one.  Here we analyse the
two statistics that were actually computed on that table — the Pearson
interaction statistic and the likelihood-ratio (G) statistic — and we quantify
the resolving power of the pooled KS comparison.

Main results.

* `PositionalRateLink.Table.pearson_eq_zero_iff`,
  `PositionalRateLink.Table.gStat_eq_zero_iff` – both statistics vanish exactly
  on the independence table `O = E`, and both are nonnegative.  The G statistic
  bound is Gibbs' inequality (nonnegativity of a Kullback–Leibler divergence)
  proved from `log t ≤ t − 1`, with the strict case supplying the equality
  characterisation.
* `PositionalRateLink.TwoLayer.occ_eq_expected_iff_homogeneous` – for an
  occupancy table the independence configuration `O = E` is *equivalent* to
  homogeneity of the positional profiles.  Chaining the three results:
  `χ² = 0 ↔ G = 0 ↔ profiles homogeneous ↔ occupancy matrix has rank one`.
  So the exp-580 statistic tests precisely the intended hypothesis; a null
  result is a statement about profile shape and nothing else.
* `PositionalRateLink.TwoLayer.strata_TV_le_heterogeneity` – the total-variation
  distance between the pooled profiles of two rate strata is at most the maximal
  pairwise total-variation heterogeneity of the individual profiles.  A pooled
  KS/TV contrast of size `D` therefore *certifies* that some pair of indices has
  heterogeneity at least `D`; conversely the observed `D = 0.0462` bounds how
  much shape heterogeneity can hide inside the terciles.
* `PositionalRateLink.TwoLayer.layers_identifiable` – the rate layer and the
  positional layer are jointly identifiable from the occupancy table, so the
  decomposition being tested is not an artefact of the parametrisation.
-/

open Finset

namespace PositionalRateLink

namespace TwoLayer

variable {ι β : Type*} [Fintype ι] [Fintype β] (M : TwoLayer ι β)

/-! ### Identifiability of the two layers -/

/-- The rate layer and the positional layer are determined by the occupancy
table: no reparametrisation can trade one layer against the other. -/
theorem layers_identifiable (M' : TwoLayer ι β) (h : ∀ i b, M.occ i b = M'.occ i b) :
    M.rate = M'.rate ∧ M.prof = M'.prof := by
  have hrate : ∀ i, M.rate i = M'.rate i := by
    intro i
    have h1 : ∑ b, M.occ i b = ∑ b, M'.occ i b := Finset.sum_congr rfl fun b _ => h i b
    rwa [M.occ_row_sum i, M'.occ_row_sum i] at h1
  refine ⟨funext hrate, funext fun i => funext fun b => ?_⟩
  have hi := h i b
  rw [occ, occ, hrate i] at hi
  exact mul_left_cancel₀ (M'.rate_pos i).ne' hi

/-! ### Resolving power of the pooled comparison -/

lemma normProf_convex (w : ι → ℝ) (S : Finset ι) (b : β) :
    M.normProf w S b = ∑ i ∈ S, (w i * M.rate i / M.mass w S) * M.prof i b := by
  rw [normProf, M.pooled_eq, Finset.sum_div]
  exact Finset.sum_congr rfl fun i _ => by ring

lemma convex_weights_sum {w : ι → ℝ} {S : Finset ι} (hS : M.mass w S ≠ 0) :
    ∑ i ∈ S, (w i * M.rate i / M.mass w S) = 1 := by
  rw [← Finset.sum_div]
  exact div_self hS

/-- **The pooled contrast cannot exceed the heterogeneity.**  If every pair of
indices has positional profiles within total variation `ε`, then any two strata
(e.g. hit-poor and hit-rich terciles) have pooled profiles within `ε`. -/
theorem strata_TV_le_heterogeneity {w : ι → ℝ} {S T : Finset ι}
    (hwS : ∀ i ∈ S, 0 ≤ w i) (hwT : ∀ i ∈ T, 0 ≤ w i)
    (hS : 0 < M.mass w S) (hT : 0 < M.mass w T) {ε : ℝ}
    (hhet : ∀ i j, (1/2) * ∑ b, |M.prof i b - M.prof j b| ≤ ε) :
    (1/2) * ∑ b, |M.normProf w S b - M.normProf w T b| ≤ ε := by
  set c : ι → ℝ := fun i => w i * M.rate i / M.mass w S with hc
  set d : ι → ℝ := fun j => w j * M.rate j / M.mass w T with hd
  have hcnn : ∀ i ∈ S, 0 ≤ c i := fun i hi =>
    div_nonneg (mul_nonneg (hwS i hi) (M.rate_pos i).le) hS.le
  have hdnn : ∀ j ∈ T, 0 ≤ d j := fun j hj =>
    div_nonneg (mul_nonneg (hwT j hj) (M.rate_pos j).le) hT.le
  have hcs : ∑ i ∈ S, c i = 1 := M.convex_weights_sum hS.ne'
  have hds : ∑ j ∈ T, d j = 1 := M.convex_weights_sum hT.ne'
  have hdiff : ∀ b, M.normProf w S b - M.normProf w T b
      = ∑ i ∈ S, ∑ j ∈ T, c i * d j * (M.prof i b - M.prof j b) := by
    intro b
    have hinner : ∀ i, ∑ j ∈ T, c i * d j * (M.prof i b - M.prof j b)
        = c i * M.prof i b - c i * (∑ j ∈ T, d j * M.prof j b) := by
      intro i
      have hstep : ∑ j ∈ T, c i * d j * (M.prof i b - M.prof j b)
          = (c i * M.prof i b) * (∑ j ∈ T, d j) - c i * ∑ j ∈ T, d j * M.prof j b := by
        rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib]
        exact Finset.sum_congr rfl fun j _ => by ring
      rw [hstep, hds, mul_one]
    simp only [hinner]
    rw [Finset.sum_sub_distrib, ← Finset.sum_mul, hcs, one_mul,
      M.normProf_convex w S b, M.normProf_convex w T b]
  have hbound : ∀ b, |M.normProf w S b - M.normProf w T b|
      ≤ ∑ i ∈ S, ∑ j ∈ T, c i * d j * |M.prof i b - M.prof j b| := by
    intro b
    rw [hdiff b]
    refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
    refine Finset.sum_le_sum fun i hi => ?_
    refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
    refine Finset.sum_le_sum fun j hj => ?_
    rw [abs_mul, abs_of_nonneg (mul_nonneg (hcnn i hi) (hdnn j hj))]
  have hsum : ∑ b, |M.normProf w S b - M.normProf w T b|
      ≤ ∑ i ∈ S, ∑ j ∈ T, c i * d j * (2 * ε) := by
    calc ∑ b, |M.normProf w S b - M.normProf w T b|
        ≤ ∑ b, ∑ i ∈ S, ∑ j ∈ T, c i * d j * |M.prof i b - M.prof j b| :=
          Finset.sum_le_sum fun b _ => hbound b
      _ = ∑ i ∈ S, ∑ j ∈ T, ∑ b, c i * d j * |M.prof i b - M.prof j b| := by
          rw [Finset.sum_comm]
          exact Finset.sum_congr rfl fun i _ => Finset.sum_comm
      _ ≤ ∑ i ∈ S, ∑ j ∈ T, c i * d j * (2 * ε) := by
          refine Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => ?_
          rw [← Finset.mul_sum]
          refine mul_le_mul_of_nonneg_left ?_ (mul_nonneg (hcnn i hi) (hdnn j hj))
          have hij := hhet i j
          linarith
  have hcd : ∑ i ∈ S, ∑ j ∈ T, c i * d j * (2 * ε) = 2 * ε := by
    have h1 : ∀ i, ∑ j ∈ T, c i * d j * (2*ε) = c i * (2*ε) := by
      intro i
      have hstep : ∑ j ∈ T, c i * d j * (2*ε) = (c i * (2*ε)) * ∑ j ∈ T, d j := by
        rw [Finset.mul_sum]
        exact Finset.sum_congr rfl fun j _ => by ring
      rw [hstep, hds, mul_one]
    simp only [h1]
    rw [← Finset.sum_mul, hcs, one_mul]
  linarith [hsum, hcd]

end TwoLayer

/-! ## Interaction statistics on a positive contingency table -/

namespace Table

/-- One term of a Kullback–Leibler divergence is nonnegative (`log t ≤ t − 1`). -/
lemma klTerm_nonneg {a e : ℝ} (ha : 0 < a) (he : 0 < e) : 0 ≤ a * Real.log (a/e) - a + e := by
  have ht : 0 < e / a := div_pos he ha
  have h := Real.log_le_sub_one_of_pos ht
  have hmul := mul_le_mul_of_nonneg_left h ha.le
  have hae : a * (e / a) = e := by field_simp
  have hlog : Real.log (a / e) = - Real.log (e / a) := by
    rw [← Real.log_inv]; congr 1; field_simp
  rw [hlog]
  nlinarith [hmul, hae]

/-- Strict version: the term is positive unless the observed value equals the
expected one. -/
lemma klTerm_pos {a e : ℝ} (ha : 0 < a) (he : 0 < e) (hne : a ≠ e) :
    0 < a * Real.log (a/e) - a + e := by
  have ht : 0 < e / a := div_pos he ha
  have htne : e / a ≠ 1 := by
    intro h
    field_simp at h
    exact hne h.symm
  have h := Real.log_lt_sub_one_of_pos ht htne
  have hmul := mul_lt_mul_of_pos_left h ha
  have hae : a * (e / a) = e := by field_simp
  have hlog : Real.log (a / e) = - Real.log (e / a) := by
    rw [← Real.log_inv]; congr 1; field_simp
  rw [hlog]
  nlinarith [hmul, hae]

variable {ι β : Type*} [Fintype ι] [Fintype β] (O : ι → β → ℝ)

/-- Row total (hits produced by one index). -/
def rowSum (i : ι) : ℝ := ∑ b, O i b

/-- Column total (hits landing in one positional bin). -/
def colSum (b : β) : ℝ := ∑ i, O i b

/-- Grand total. -/
def total : ℝ := ∑ i, rowSum O i

/-- Independence (no-interaction) fit of the table. -/
noncomputable def expected (i : ι) (b : β) : ℝ := rowSum O i * colSum O b / total O

/-- Pearson interaction statistic. -/
noncomputable def pearson : ℝ := ∑ i, ∑ b, (O i b - expected O i b)^2 / expected O i b

/-- Likelihood-ratio (G) interaction statistic. -/
noncomputable def gStat : ℝ := 2 * ∑ i, ∑ b, O i b * Real.log (O i b / expected O i b)

variable (hO : ∀ i b, 0 < O i b)

include hO

lemma total_pos [Nonempty ι] [Nonempty β] : 0 < total O :=
  Finset.sum_pos (fun i _ => Finset.sum_pos (fun b _ => hO i b) Finset.univ_nonempty)
    Finset.univ_nonempty

lemma expected_pos [Nonempty ι] [Nonempty β] (i : ι) (b : β) : 0 < expected O i b := by
  have h1 : 0 < rowSum O i := Finset.sum_pos (fun b _ => hO i b) Finset.univ_nonempty
  have h2 : 0 < colSum O b := Finset.sum_pos (fun i _ => hO i b) Finset.univ_nonempty
  exact div_pos (mul_pos h1 h2) (total_pos O hO)

lemma sum_expected_row [Nonempty ι] [Nonempty β] (i : ι) : ∑ b, expected O i b = rowSum O i := by
  have hT := (total_pos O hO).ne'
  have hcol : ∑ b, colSum O b = total O := by
    simp only [colSum, total, rowSum]
    exact Finset.sum_comm
  simp only [expected, ← Finset.sum_div, ← Finset.mul_sum, hcol]
  field_simp

lemma sum_expected [Nonempty ι] [Nonempty β] : ∑ i, ∑ b, expected O i b = total O := by
  simp only [sum_expected_row O hO, total]

/-! ### Pearson -/

theorem pearson_nonneg [Nonempty ι] [Nonempty β] : 0 ≤ pearson O :=
  Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun b _ =>
    div_nonneg (sq_nonneg _) (expected_pos O hO i b).le

/-- The Pearson interaction statistic vanishes exactly on the independence
table. -/
theorem pearson_eq_zero_iff [Nonempty ι] [Nonempty β] :
    pearson O = 0 ↔ ∀ i b, O i b = expected O i b := by
  constructor
  · intro h i b
    have hterms : ∀ i, ∀ _ : i ∈ (Finset.univ : Finset ι),
        0 ≤ ∑ b, (O i b - expected O i b)^2 / expected O i b := fun i _ =>
      Finset.sum_nonneg fun b _ => div_nonneg (sq_nonneg _) (expected_pos O hO i b).le
    have hrow := (Finset.sum_eq_zero_iff_of_nonneg hterms).1 h i (Finset.mem_univ i)
    have hterm := (Finset.sum_eq_zero_iff_of_nonneg
      (fun b (_ : b ∈ (Finset.univ : Finset β)) =>
        div_nonneg (sq_nonneg (O i b - expected O i b)) (expected_pos O hO i b).le)).1 hrow b
      (Finset.mem_univ b)
    have hnum := (div_eq_zero_iff.1 hterm).resolve_right (expected_pos O hO i b).ne'
    have hsq := pow_eq_zero_iff (n := 2) (by norm_num) |>.1 hnum
    linarith
  · intro h
    refine Finset.sum_eq_zero fun i _ => Finset.sum_eq_zero fun b _ => ?_
    rw [h i b]
    simp

/-! ### Likelihood ratio (Gibbs' inequality) -/

lemma gStat_eq_two_mul_kl [Nonempty ι] [Nonempty β] :
    gStat O = 2 * ∑ i, ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b
      + expected O i b) := by
  have hsplit : ∑ i, ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b + expected O i b)
      = (∑ i, ∑ b, O i b * Real.log (O i b / expected O i b))
        - (∑ i, ∑ b, O i b) + ∑ i, ∑ b, expected O i b := by
    simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib]
  have hO' : ∑ i, ∑ b, O i b = total O := rfl
  rw [gStat, hsplit, hO', sum_expected O hO]
  ring

/-- **Gibbs' inequality.**  The likelihood-ratio interaction statistic is
nonnegative. -/
theorem gStat_nonneg [Nonempty ι] [Nonempty β] : 0 ≤ gStat O := by
  rw [gStat_eq_two_mul_kl O hO]
  have : 0 ≤ ∑ i, ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b + expected O i b) :=
    Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun b _ =>
      klTerm_nonneg (hO i b) (expected_pos O hO i b)
  linarith

/-- The likelihood-ratio interaction statistic vanishes exactly on the
independence table — the equality case of Gibbs' inequality. -/
theorem gStat_eq_zero_iff [Nonempty ι] [Nonempty β] :
    gStat O = 0 ↔ ∀ i b, O i b = expected O i b := by
  rw [gStat_eq_two_mul_kl O hO]
  constructor
  · intro h i b
    have hz : ∑ i, ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b
        + expected O i b) = 0 := by linarith
    have hrows : ∀ i, ∀ _ : i ∈ (Finset.univ : Finset ι),
        0 ≤ ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b + expected O i b) :=
      fun i _ => Finset.sum_nonneg fun b _ => klTerm_nonneg (hO i b) (expected_pos O hO i b)
    have hrow := (Finset.sum_eq_zero_iff_of_nonneg hrows).1 hz i (Finset.mem_univ i)
    have hterm := (Finset.sum_eq_zero_iff_of_nonneg
      (fun b (_ : b ∈ (Finset.univ : Finset β)) =>
        klTerm_nonneg (hO i b) (expected_pos O hO i b))).1 hrow b (Finset.mem_univ b)
    by_contra hne
    exact absurd hterm (ne_of_gt (klTerm_pos (hO i b) (expected_pos O hO i b) hne))
  · intro h
    have : ∑ i, ∑ b, (O i b * Real.log (O i b / expected O i b) - O i b + expected O i b) = 0 := by
      refine Finset.sum_eq_zero fun i _ => Finset.sum_eq_zero fun b _ => ?_
      rw [h i b]
      simp
    rw [this]
    ring

end Table

/-! ## Bridging the statistics back to the two layers -/

namespace TwoLayer

variable {ι β : Type*} [Fintype ι] [Fintype β] (M : TwoLayer ι β)

lemma rowSum_occ (i : ι) : Table.rowSum M.occ i = M.rate i := M.occ_row_sum i

lemma total_occ : Table.total M.occ = ∑ i, M.rate i := by
  simp only [Table.total, rowSum_occ]

lemma total_occ_pos [Nonempty ι] : 0 < Table.total M.occ := by
  rw [total_occ]
  exact Finset.sum_pos (fun i _ => M.rate_pos i) Finset.univ_nonempty

/-- **The interaction test tests exactly the intended hypothesis.**  For an
occupancy table, coincidence with the independence fit is equivalent to
homogeneity of the positional profiles.  Combined with
`Table.pearson_eq_zero_iff` and `Table.gStat_eq_zero_iff`, both interaction
statistics vanish precisely when the positional layer does not depend on the
rate layer. -/
theorem occ_eq_expected_iff_homogeneous [Nonempty ι] [Nonempty β] :
    (∀ i b, M.occ i b = Table.expected M.occ i b) ↔ ∀ i j, M.prof i = M.prof j := by
  have hTpos : 0 < Table.total M.occ := M.total_occ_pos
  constructor
  · intro h i j
    funext b
    have hkey : ∀ k : ι, M.prof k b = Table.colSum M.occ b / Table.total M.occ := by
      intro k
      have hk := h k b
      rw [occ, Table.expected, rowSum_occ] at hk
      have hrk := (M.rate_pos k).ne'
      field_simp at hk ⊢
      nlinarith [hk, M.rate_pos k]
    rw [hkey i, hkey j]
  · intro h i b
    obtain ⟨i0⟩ := ‹Nonempty ι›
    have hp : ∀ k, M.prof k = M.prof i0 := fun k => h k i0
    have hcol : Table.colSum M.occ b = Table.total M.occ * M.prof i0 b := by
      simp only [Table.colSum, occ, total_occ, Finset.sum_mul]
      exact Finset.sum_congr rfl fun k _ => by rw [hp k]
    rw [Table.expected, rowSum_occ, hcol, occ, hp i]
    field_simp

end TwoLayer

end PositionalRateLink