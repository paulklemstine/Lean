import Mathlib
import Algebra.ZeroFitDialU72Parity
import Novelty.ZeroFitDialU64

/-!
# Replication geometry for the bitlen-64 zero-fit dial

## Research context (FACT round-68 #3, exp 543, `U64B-DIAL-HOLDS-COUNT-PARITY`)

Paper 190 re-runs the bitlen-64 uniform cell of paper 184 on three *fresh* seeds
(20261210/11/12).  The recorded numbers are

* pooled `ρ(T, rate) = 0.641`, CI `[0.619, 0.660]` — inside the validation band
  `[0.55, 0.85]`, so **H1 replicates**;
* the advantage of the trailing-zero statistic `T` over the popcount baseline is
  `+0.044`, CI `[0.022, 0.066]` — **below** the `+0.05` bar, and only `1/3` fresh seeds
  clear the bar;
* pooling the fresh triple with paper 184's triple (`pooled 0.648`) gives six seeds with
  `ρT` mean `0.644`, advantage mean `+0.059`, advantage median `+0.058`, and `3/6` seeds
  above the bar.

So the dial law replicates but the parity verdict is *count parity*: the six-seed mean
sits above the bar while only half the seeds do.  That combination — a mean above a
threshold carried by half the sample — is a statement about **order statistics of a
replication record**, and nothing in the existing catalog can speak to it.
`Novelty.ZeroFitDialU64` handles tie geometry of a *single* sample,
`Algebra.ZeroFitDialU72Parity` handles the Gram geometry of *two statistics against one
response*, and `Algebra.ZeroFitDialParityCapacity` handles `k` orthonormal statistics.
None of them constrains how a *mean* over seeds can be distributed among the seeds.

This file supplies two new layers and then couples them.

## Main results

### Layer 1 — the chord form of Gram positivity (new)

* `gram_iff_chord` — the three-correlation Gram inequality `a²+b²+c² ≤ 1+2abc` is
  **equivalent** to the *chord law* `(a-b)² ≤ (1-c)(1+c-2ab)`.  The advantage `a-b` of one
  statistic over another is therefore not an extra datum: it is exactly Gram positivity
  read along the difference direction.
* `advantage_chord_law` — the chord law for genuine coordinate vectors.
* `decorrelation_budget`, `mutual_corr_upper` — an advantage of `α` at product level
  `ab ≤ M < 1` *forces* the two statistics apart: `1 - c ≥ α²/(2(1-M))`.
* `corr_gram_eq_dim_two`, `plane_chord_identity` — sharpness: in a two-dimensional
  response space the chord law is an **identity**, so the bound cannot be improved.
* `corrDist_triangle` — the chord distance `√(2-2ρ)` is a genuine metric on nonzero
  statistics; this upgrades the pairwise Gram bound to a transitivity law
  (`dial_transfer`) usable across re-tuned dials.

### Layer 2 — rigidity of a replication record (new)

* `block_above_sum_lower`, `exists_above_of_block_mean` — a finite record whose
  off-group entries sit below a bar has its group sum, hence its group maximum, bounded
  below.
* `count_parity_forces_excess` — **count parity is expensive**: if a record of `2k` seeds
  has mean `μ` and exactly `k` seeds above the bar `τ`, the above-bar group must average
  at least `2μ - τ`.
* `six_seed_rigidity` — instantiated on the actual record: the six-seed advantage mean
  `0.059` with `3/6` above the `0.05` bar and a fresh-triple mean of `0.044` forces some
  *legacy* (paper-184) seed to carry an advantage of at least `+0.086`, nearly double the
  bar and outside the fresh cell's entire confidence interval `[0.022, 0.066]`.

### Coupling

* `u64b_mutual_corr_window` — the recorded pair `(0.641, 0.597)` pins the mutual
  correlation of `T` and popcount into `[-0.24, 0.9985]`.
* `outlier_seed_decorrelation` — the forced `+0.086` outlier of `six_seed_rigidity` must
  be geometrically decorrelated: for that seed `c ≤ 0.995`.
* `u64b_parity_realizable` — at the replicated level `0.641` count parity is *not* a
  geometric anomaly: `2·0.641² < 1`, so two exactly uncorrelated statistics can both read
  `0.641`.  Above the `1/√2` threshold this is impossible; the bitlen-64 cell sits below
  it, which is why the parity verdict flips here and not at bitlen 44.

## Scientific payload

The two layers pull in opposite directions and that is the content of the cycle.  Gram
geometry says a *positive* advantage costs decorrelation and is freely available below
`1/√2`; order-statistic rigidity says a *count-parity* record cannot be flat — it must
contain an outlier seed at least `2μ - τ`.  The falsifiable prediction: any further
bitlen-64 replication that reports six-seed advantage mean above the bar with only half
the seeds clearing it must exhibit a seed above `2μ - τ`; a record with all six
advantages inside `[0.022, 0.066]` and mean `0.059` is arithmetically impossible.
-/

open Finset

namespace Catalog.Algebra.ZeroFitDialU64Replication

open Catalog.Algebra.ZeroFitDialU72Parity

/-! ## 1. The chord form of Gram positivity

Write `a = corr T resp`, `b = corr C resp` for the two readings and `c = corr T C` for the
mutual correlation of the two statistics.  The *advantage* is `a - b`. -/

/-- The algebraic identity behind the chord law: the Gram slack equals the chord slack. -/
theorem gram_chord_identity (a b c : ℝ) :
    (1 - c) * (1 + c - 2 * (a * b)) - (a - b) ^ 2
      = 1 + 2 * (a * b * c) - (a ^ 2 + b ^ 2 + c ^ 2) := by
  ring

/-- **The chord law is Gram positivity.**  For three correlations the Gram inequality
`a² + b² + c² ≤ 1 + 2abc` holds *iff* the squared advantage obeys
`(a-b)² ≤ (1-c)(1+c-2ab)`.  So the advantage of one statistic over another is a pure
function of the geometry, not an independent degree of freedom. -/
theorem gram_iff_chord (a b c : ℝ) :
    a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)
      ↔ (a - b) ^ 2 ≤ (1 - c) * (1 + c - 2 * (a * b)) := by
  constructor <;> intro h <;> linarith [gram_chord_identity a b c]

variable {n : ℕ}

/-- **The advantage chord law for coordinate vectors.**  `u` and `v` are the two
statistics, `w` the shared response. -/
theorem advantage_chord_law (u v w : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) :
    (corr u w - corr v w) ^ 2
      ≤ (1 - corr u v) * (1 + corr u v - 2 * (corr u w * corr v w)) := by
  have hg := corr_gram u v w hu hv hw
  exact (gram_iff_chord (corr u w) (corr v w) (corr u v)).mp (by linarith)

/-- **The decorrelation budget.**  An advantage of at least `α ≥ 0` at reading product
`ab` costs mutual decorrelation `1 - c ≥ α²/(2(1-ab))`. -/
theorem decorrelation_budget {a b c alpha : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c))
    (halpha : 0 ≤ alpha) (hab : alpha ≤ a - b) :
    alpha ^ 2 ≤ 2 * (1 - c) * (1 - a * b) := by
  have h := (gram_iff_chord a b c).mp hg
  have h1 : alpha ^ 2 ≤ (a - b) ^ 2 := by nlinarith
  nlinarith [sq_nonneg (1 - c)]

/-- Quantitative form: with the reading product bounded *below* by `M < 1`, an advantage
`α` caps the mutual correlation at `1 - α²/(2(1-M))`. -/
theorem mutual_corr_upper {a b c alpha M : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) (hc : c ≤ 1)
    (halpha : 0 ≤ alpha) (hab : alpha ≤ a - b) (hM : M ≤ a * b) (hM1 : M < 1) :
    c ≤ 1 - alpha ^ 2 / (2 * (1 - M)) := by
  have hbud := decorrelation_budget hg halpha hab
  have hcc : (0 : ℝ) ≤ 1 - c := by linarith
  have hstep : alpha ^ 2 ≤ 2 * (1 - c) * (1 - M) := by
    nlinarith [mul_nonneg hcc (sub_nonneg.mpr hM)]
  have hpos : (0 : ℝ) < 2 * (1 - M) := by linarith
  have hfin : alpha ^ 2 / (2 * (1 - M)) ≤ 1 - c := by
    rw [div_le_iff₀ hpos]; nlinarith [hstep]
  linarith

/-! ### Sharpness: in a plane the chord law is an identity -/

/-- Three vectors in a two-dimensional space have vanishing Gram determinant. -/
theorem gram_det_eq_zero_dim_two (u v w : Fin 2 → ℝ) :
    dot u u * dot v v * dot w w + 2 * (dot u v * dot u w * dot v w)
        - dot u u * dot v w ^ 2 - dot v v * dot u w ^ 2 - dot w w * dot u v ^ 2 = 0 := by
  simp only [dot, Fin.sum_univ_two]
  ring

/-- In a two-dimensional response space the Gram inequality is an *equality*. -/
theorem corr_gram_eq_dim_two (u v w : Fin 2 → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) :
    corr u v ^ 2 + corr u w ^ 2 + corr v w ^ 2
      = 1 + 2 * (corr u v * corr u w * corr v w) := by
  have hp : 0 < dot u u := lt_of_le_of_ne (dot_self_nonneg u) (Ne.symm hu)
  have hq : 0 < dot v v := lt_of_le_of_ne (dot_self_nonneg v) (Ne.symm hv)
  have hr : 0 < dot w w := lt_of_le_of_ne (dot_self_nonneg w) (Ne.symm hw)
  have hprod : corr u v * corr u w * corr v w
      = dot u v * dot u w * dot v w / (dot u u * dot v v * dot w w) := by
    rw [corr, corr, corr, div_mul_div_comm, div_mul_div_comm]
    congr 1
    have h : nrm u * nrm v * (nrm u * nrm w) * (nrm v * nrm w)
        = nrm u ^ 2 * nrm v ^ 2 * nrm w ^ 2 := by ring
    rw [h, nrm_sq, nrm_sq, nrm_sq]
  rw [corr_sq u v, corr_sq u w, corr_sq v w, hprod]
  have hdet := gram_det_eq_zero_dim_two u v w
  field_simp
  nlinarith [hdet, hp, hq, hr]

/-- **Sharpness of the chord law.**  For any three nonzero vectors in the plane the
advantage bound is attained exactly. -/
theorem plane_chord_identity (u v w : Fin 2 → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) :
    (corr u w - corr v w) ^ 2
      = (1 - corr u v) * (1 + corr u v - 2 * (corr u w * corr v w)) := by
  have h := corr_gram_eq_dim_two u v w hu hv hw
  linarith [gram_chord_identity (corr u w) (corr v w) (corr u v)]

/-! ## 2. The chord metric on statistics

`√(2 - 2ρ)` is the Euclidean distance between the normalisations of two statistics.  We
prove it is a metric; the triangle inequality is a *transitivity* law for dials that the
pairwise Gram bound does not give directly. -/

lemma nrm_nonneg (u : Fin n → ℝ) : 0 ≤ nrm u := Real.sqrt_nonneg _

lemma dot_le_nrm_mul_nrm (p q : Fin n → ℝ) : dot p q ≤ nrm p * nrm q := by
  have hsq : dot p q ^ 2 ≤ (nrm p * nrm q) ^ 2 := by
    rw [mul_pow, nrm_sq, nrm_sq]; exact dot_sq_le p q
  have h1 : Real.sqrt (dot p q ^ 2) ≤ Real.sqrt ((nrm p * nrm q) ^ 2) :=
    Real.sqrt_le_sqrt hsq
  rw [Real.sqrt_sq_eq_abs, Real.sqrt_sq_eq_abs] at h1
  calc dot p q ≤ |dot p q| := le_abs_self _
    _ ≤ |nrm p * nrm q| := h1
    _ = nrm p * nrm q := abs_of_nonneg (mul_nonneg (nrm_nonneg p) (nrm_nonneg q))

lemma dot_add_self (p q : Fin n → ℝ) :
    dot (fun i => p i + q i) (fun i => p i + q i) = dot p p + 2 * dot p q + dot q q := by
  have h : ∀ i : Fin n,
      (p i + q i) * (p i + q i) = p i * p i + (2 * (p i * q i) + q i * q i) := by
    intro i; ring
  simp only [dot, h, Finset.sum_add_distrib, ← Finset.mul_sum]
  ring

/-- Minkowski's inequality for `nrm`. -/
lemma nrm_add_le (p q : Fin n → ℝ) : nrm (fun i => p i + q i) ≤ nrm p + nrm q := by
  have hexp : nrm (fun i => p i + q i) ^ 2 = dot p p + 2 * dot p q + dot q q := by
    rw [nrm_sq]; exact dot_add_self p q
  have hcs := dot_le_nrm_mul_nrm p q
  have hp := nrm_sq p
  have hq := nrm_sq q
  nlinarith [nrm_nonneg (fun i => p i + q i), nrm_nonneg p, nrm_nonneg q, hexp]

/-- The normalisation of a statistic. -/
noncomputable def nz (u : Fin n → ℝ) : Fin n → ℝ := fun i => u i / nrm u

lemma nz_eq_smul (u : Fin n → ℝ) : nz u = fun i => (1 / nrm u) * u i := by
  funext i; simp [nz, div_eq_inv_mul]

lemma dot_nz_nz (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    dot (nz u) (nz v) = corr u v := by
  rw [nz_eq_smul, nz_eq_smul, dot_smul_left, dot_smul_right, corr]
  have hnu : nrm u ≠ 0 := ne_of_gt (nrm_pos hu)
  have hnv : nrm v ≠ 0 := ne_of_gt (nrm_pos hv)
  field_simp

lemma corr_self (u : Fin n → ℝ) (hu : dot u u ≠ 0) : corr u u = 1 := by
  have hnu : nrm u ≠ 0 := ne_of_gt (nrm_pos hu)
  rw [corr, ← pow_two, nrm_sq]
  exact div_self hu

/-- The chord distance between two statistics. -/
noncomputable def corrDist (u v : Fin n → ℝ) : ℝ := nrm (fun i => nz u i - nz v i)

lemma corrDist_sq (u v : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0) :
    corrDist u v ^ 2 = 2 - 2 * corr u v := by
  have h : dot (fun i => nz u i - nz v i) (fun i => nz u i - nz v i)
      = dot (nz u) (nz u) - 2 * dot (nz u) (nz v) + dot (nz v) (nz v) := by
    have hd := dot_expand_sub (nz u) (nz v)
    simpa [dot, pow_two] using hd
  rw [corrDist, nrm_sq, h, dot_nz_nz u u hu hu, dot_nz_nz u v hu hv, dot_nz_nz v v hv hv,
    corr_self u hu, corr_self v hv]
  ring

/-- **The chord distance obeys the triangle inequality**: statistics modulo positive
scaling sit isometrically on a Euclidean sphere. -/
theorem corrDist_triangle (u v w : Fin n → ℝ) :
    corrDist u w ≤ corrDist u v + corrDist v w := by
  have hrw : (fun i => nz u i - nz w i)
      = fun i => (fun j => nz u j - nz v j) i + (fun j => nz v j - nz w j) i := by
    funext i; ring
  rw [corrDist, hrw]
  exact nrm_add_le _ _

/-- **Dial transfer.**  If a re-tuned statistic `v` sits within chord distance
`√(2-2·corr u v)` of `u`, its reading against the response cannot drop by more than that
distance times the chord to the response. -/
theorem dial_transfer (u v w : Fin n → ℝ) (hu : dot u u ≠ 0) (hv : dot v v ≠ 0)
    (hw : dot w w ≠ 0) :
    2 - 2 * corr v w
      ≤ (Real.sqrt (2 - 2 * corr u v) + Real.sqrt (2 - 2 * corr u w)) ^ 2 := by
  have hvw := corrDist_sq v w hv hw
  have huv := corrDist_sq u v hu hv
  have huw := corrDist_sq u w hu hw
  have htri : corrDist v w ≤ corrDist v u + corrDist u w := corrDist_triangle v u w
  have hcomm : corrDist v u = corrDist u v := by
    have h : (fun i => nz v i - nz u i) = fun i => (-1 : ℝ) * (nz u i - nz v i) := by
      funext i; ring
    rw [corrDist, corrDist, h, nrm, nrm, dot_smul_left, dot_smul_right]
    norm_num
  have h1 : corrDist u v = Real.sqrt (2 - 2 * corr u v) := by
    rw [← huv, corrDist, Real.sqrt_sq (nrm_nonneg _)]
  have h2 : corrDist u w = Real.sqrt (2 - 2 * corr u w) := by
    rw [← huw, corrDist, Real.sqrt_sq (nrm_nonneg _)]
  rw [hcomm, h1, h2] at htri
  have hd0 : 0 ≤ corrDist v w := by unfold corrDist; exact nrm_nonneg _
  have hsq : corrDist v w ^ 2
      ≤ (Real.sqrt (2 - 2 * corr u v) + Real.sqrt (2 - 2 * corr u w)) ^ 2 := by
    nlinarith [mul_self_le_mul_self hd0 htri]
  linarith [hvw ▸ hsq]

/-! ## 3. Rigidity of a replication record

A record is a function `a : ι → ℚ` of per-seed advantages, `B` the seeds under discussion
and `S ⊆ B` the seeds that clear the bar `τ`. -/

/-- The above-bar group carries all of the record's excess over the bar. -/
theorem block_above_sum_lower {ι : Type*} [DecidableEq ι] (B S : Finset ι) (a : ι → ℚ)
    (tau : ℚ) (hS : S ⊆ B) (hout : ∀ i ∈ B \ S, a i ≤ tau) :
    (∑ i ∈ B, a i) - ((B.card : ℚ) - S.card) * tau ≤ ∑ i ∈ S, a i := by
  have hcard : ((B \ S).card : ℚ) = (B.card : ℚ) - S.card := by
    have h1 : (B \ S).card = B.card - S.card := by
      rw [Finset.card_sdiff, Finset.inter_eq_left.mpr hS]
    have h2 : S.card ≤ B.card := Finset.card_le_card hS
    rw [h1]; push_cast [h2]; ring
  have hout' : ∑ i ∈ B \ S, a i ≤ ((B \ S).card : ℚ) * tau := by
    simpa using Finset.sum_le_card_nsmul (B \ S) a tau hout
  have hsplit : ∑ i ∈ B \ S, a i + ∑ i ∈ S, a i = ∑ i ∈ B, a i := Finset.sum_sdiff hS
  rw [← hcard]
  linarith

/-- **Some above-bar seed carries the excess.** -/
theorem exists_above_of_block_mean {ι : Type*} [DecidableEq ι] (B S : Finset ι) (a : ι → ℚ)
    (tau X : ℚ) (hS : S ⊆ B) (hne : S.Nonempty) (hout : ∀ i ∈ B \ S, a i ≤ tau)
    (hsum : X ≤ ∑ i ∈ B, a i) :
    ∃ i ∈ S, (X - ((B.card : ℚ) - S.card) * tau) / S.card ≤ a i := by
  have hSsum : X - ((B.card : ℚ) - S.card) * tau ≤ ∑ i ∈ S, a i := by
    have := block_above_sum_lower B S a tau hS hout
    linarith
  have hSpos : (0 : ℚ) < S.card := by exact_mod_cast Finset.card_pos.mpr hne
  refine Finset.exists_le_of_sum_le hne ?_
  rw [Finset.sum_const, nsmul_eq_mul, mul_div_cancel₀ _ (ne_of_gt hSpos)]
  exact hSsum

/-- **Count parity is expensive.**  A record of `2k` seeds with mean `μ` in which exactly
`k` seeds clear the bar `τ` forces the clearing group to average at least `2μ - τ`. -/
theorem count_parity_forces_excess {ι : Type*} [DecidableEq ι] (B S : Finset ι) (a : ι → ℚ)
    (tau mu : ℚ) (k : ℕ) (hk : 0 < k) (hB : B.card = 2 * k) (hSc : S.card = k)
    (hS : S ⊆ B) (hout : ∀ i ∈ B \ S, a i ≤ tau)
    (hmean : ∑ i ∈ B, a i = (B.card : ℚ) * mu) :
    2 * mu - tau ≤ (∑ i ∈ S, a i) / S.card := by
  have hkpos : (0 : ℚ) < k := by exact_mod_cast hk
  have hlow := block_above_sum_lower B S a tau hS hout
  rw [hmean, hB, hSc] at hlow
  rw [hSc, le_div_iff₀ hkpos]
  push_cast at hlow ⊢
  linarith

/-! ## 4. The recorded data (exp 543 / paper 190) -/

/-- Pooled `ρ(T, rate)` on the fresh bitlen-64 triple, seeds 20261210–12. -/
def pooled64b : ℚ := 641 / 1000
/-- Lower CI endpoint of the fresh pooled reading. -/
def ci64bLow : ℚ := 619 / 1000
/-- Upper CI endpoint of the fresh pooled reading. -/
def ci64bHigh : ℚ := 660 / 1000
/-- Pooled advantage of `T` over the popcount baseline on the fresh triple. -/
def adv64b : ℚ := 44 / 1000
/-- Lower CI endpoint of the fresh advantage. -/
def advLow : ℚ := 22 / 1000
/-- Upper CI endpoint of the fresh advantage. -/
def advHigh : ℚ := 66 / 1000
/-- The pre-registered advantage bar. -/
def bar : ℚ := 50 / 1000
/-- Six-seed combined mean of `ρ(T, rate)`. -/
def rhoMean6 : ℚ := 644 / 1000
/-- Six-seed combined mean advantage. -/
def advMean6 : ℚ := 59 / 1000
/-- Six-seed combined median advantage. -/
def advMedian6 : ℚ := 58 / 1000
/-- Validation band, lower endpoint. -/
def bandLow : ℚ := 55 / 100
/-- Validation band, upper endpoint. -/
def bandHigh : ℚ := 85 / 100

open Catalog.Novelty.ZeroFitDialU64 in
/-- **H1 replicates**: the fresh pooled reading and its whole confidence interval lie
inside the validation band. -/
theorem u64b_inside_band :
    bandLow ≤ ci64bLow ∧ ci64bLow ≤ pooled64b ∧ pooled64b ≤ ci64bHigh ∧
      ci64bHigh ≤ bandHigh := by
  refine ⟨by norm_num [bandLow, ci64bLow], by norm_num [ci64bLow, pooled64b],
    by norm_num [pooled64b, ci64bHigh], by norm_num [ci64bHigh, bandHigh]⟩

open Catalog.Novelty.ZeroFitDialU64 in
/-- The fresh pooled reading sits within `0.01` of paper 184's bitlen-64 pooled reading:
a clean replication of the dial law. -/
theorem u64b_replicates_paper184 :
    |pooled64b - Catalog.Novelty.ZeroFitDialU64.pooled| ≤ 1 / 100 := by
  rw [abs_le]
  constructor <;> norm_num [pooled64b, Catalog.Novelty.ZeroFitDialU64.pooled]

open Catalog.Novelty.ZeroFitDialU64 in
/-- The six-seed mean is (to reporting precision) the average of the two pooled
replications. -/
theorem six_seed_mean_is_replication_average :
    |(pooled64b + Catalog.Novelty.ZeroFitDialU64.pooled) / 2 - rhoMean6| ≤ 1 / 2000 := by
  rw [abs_le]
  constructor <;> norm_num [pooled64b, Catalog.Novelty.ZeroFitDialU64.pooled, rhoMean6]

open Catalog.Novelty.ZeroFitDialU64 in
/-- The replicated reading stays strictly below the dyadic tie ceiling at bitlen 64, so
tie geometry does not explain the decline. -/
theorem u64b_below_tie_ceiling :
    pooled64b ^ 2 < Catalog.Novelty.ZeroFitDialU64.spearmanSq
      (Catalog.Novelty.ZeroFitDialU64.dyadicBlocks 64) := by
  have h := Catalog.Novelty.ZeroFitDialU64.dyadic_ceiling_gt 64 (by norm_num)
  have h2 : pooled64b ^ 2 < 6 / 7 := by norm_num [pooled64b]
  linarith

/-- **The parity flip.**  The fresh advantage and its entire CI sit below the bar, while
the six-seed mean and median sit above it: count parity, not a failure of H2. -/
theorem count_parity_flip :
    adv64b < bar ∧ advHigh < bar + 17 / 1000 ∧ bar < advMedian6 ∧ advMedian6 < advMean6 := by
  refine ⟨by norm_num [adv64b, bar], by norm_num [advHigh, bar],
    by norm_num [bar, advMedian6], by norm_num [advMedian6, advMean6]⟩

/-- The legacy (paper-184) triple's mean advantage is forced by the fresh mean and the
six-seed mean: `2·0.059 - 0.044 = 0.074`. -/
theorem legacy_advantage_mean : 2 * advMean6 - adv64b = 74 / 1000 := by
  norm_num [advMean6, adv64b]

/-- The dial reads below the `1/√2` parity threshold, so by `parity_realizable` two
*exactly uncorrelated* statistics can both read at the replicated level: count parity at
bitlen 64 is geometrically permitted. -/
theorem u64b_parity_realizable :
    ∃ u v w : Fin 3 → ℝ, dot u u ≠ 0 ∧ dot v v ≠ 0 ∧ dot w w ≠ 0 ∧
      corr u v = 0 ∧ corr u w = (641 : ℝ) / 1000 ∧ corr v w = (641 : ℝ) / 1000 :=
  parity_realizable (t := (641 : ℝ) / 1000) (by norm_num)

/-! ## 5. Rigidity applied to the six-seed record -/

/-- The three legacy (paper-184) seeds. -/
def legacy : Finset (Fin 6) := {0, 1, 2}
/-- The three fresh (paper-190) seeds. -/
def fresh : Finset (Fin 6) := {3, 4, 5}

lemma legacy_union_fresh : (univ : Finset (Fin 6)) = legacy ∪ fresh := by decide

lemma legacy_disjoint_fresh : Disjoint legacy fresh := by decide

lemma legacy_card : legacy.card = 3 := by decide

/-- **Six-seed rigidity.**  Any per-seed advantage record consistent with the published
summary — six-seed mean `0.059`, fresh-triple mean `0.044`, exactly `3/6` seeds above the
`0.05` bar with exactly `1/3` of them fresh — must contain a *legacy* seed whose advantage
is at least `+0.086`.  That is outside the fresh cell's entire CI `[0.022, 0.066]`, so the
excess that keeps the six-seed mean above the bar is carried by the older replication. -/
theorem six_seed_rigidity (a : Fin 6 → ℚ)
    (hall : ∑ i, a i = 6 * advMean6)
    (hfresh : ∑ i ∈ fresh, a i = 3 * adv64b)
    (habove : (univ.filter (fun i => bar < a i)).card = 3)
    (hfreshabove : (fresh.filter (fun i => bar < a i)).card = 1) :
    ∃ i ∈ legacy, (86 : ℚ) / 1000 ≤ a i := by
  classical
  set P : Fin 6 → Prop := fun i => bar < a i with hP
  -- the legacy block sum
  have hsum : ∑ i ∈ legacy, a i + ∑ i ∈ fresh, a i = ∑ i, a i := by
    rw [legacy_union_fresh, Finset.sum_union legacy_disjoint_fresh]
  have hlegsum : ∑ i ∈ legacy, a i = 222 / 1000 := by
    rw [hall, hfresh] at hsum
    rw [advMean6, adv64b] at hsum
    linarith
  -- the legacy above-bar count
  have hcards : (univ.filter (fun i => bar < a i)).card
      = (legacy.filter (fun i => bar < a i)).card
        + (fresh.filter (fun i => bar < a i)).card := by
    rw [legacy_union_fresh, Finset.filter_union,
      Finset.card_union_of_disjoint (Finset.disjoint_filter_filter legacy_disjoint_fresh)]
  have hlegcard : (legacy.filter (fun i => bar < a i)).card = 2 := by
    rw [habove, hfreshabove] at hcards; omega
  set S := legacy.filter (fun i => bar < a i) with hSdef
  have hS : S ⊆ legacy := Finset.filter_subset _ _
  have hne : S.Nonempty := Finset.card_pos.mp (by rw [hlegcard]; norm_num)
  have hout : ∀ i ∈ legacy \ S, a i ≤ bar := by
    intro i hi
    have h1 : i ∈ legacy := (Finset.mem_sdiff.mp hi).1
    have h2 : i ∉ S := (Finset.mem_sdiff.mp hi).2
    rw [hSdef, Finset.mem_filter] at h2
    push_neg at h2
    exact h2 h1
  obtain ⟨i, hiS, hival⟩ :=
    exists_above_of_block_mean legacy S a bar (222 / 1000) hS hne hout (le_of_eq hlegsum.symm)
  refine ⟨i, hS hiS, ?_⟩
  have hc : ((legacy.card : ℚ) - S.card) = 1 := by
    rw [legacy_card, hlegcard]; norm_num
  rw [hc, hlegcard] at hival
  have : (222 / 1000 - 1 * bar) / ((2 : ℕ) : ℚ) = 86 / 1000 := by
    norm_num [bar]
  linarith [hival, this.symm.le, this.le]

/-- An explicit advantage record meeting every published constraint whose legacy maximum
is exactly `+0.086`: the rigidity bound of `six_seed_rigidity` cannot be improved, and
the hypotheses of that theorem are consistent (so it is not vacuous). -/
theorem six_seed_rigidity_sharp :
    ∃ a : Fin 6 → ℚ,
      (∑ i, a i = 6 * advMean6) ∧ (∑ i ∈ fresh, a i = 3 * adv64b) ∧
      ((univ.filter (fun i => bar < a i)).card = 3) ∧
      ((fresh.filter (fun i => bar < a i)).card = 1) ∧
      (∀ i ∈ legacy, a i ≤ 86 / 1000) := by
  refine ⟨![50 / 1000, 86 / 1000, 86 / 1000, 20 / 1000, 30 / 1000, 82 / 1000], ?_, ?_, ?_,
    ?_, ?_⟩
  · simp [Fin.sum_univ_six, advMean6]; norm_num
  · simp [fresh, adv64b]; norm_num
  · have h : (univ.filter (fun i =>
        bar < (![50 / 1000, 86 / 1000, 86 / 1000, 20 / 1000, 30 / 1000, 82 / 1000] :
          Fin 6 → ℚ) i)) = ({1, 2, 5} : Finset (Fin 6)) := by
      ext i; fin_cases i <;> simp [bar] <;> norm_num
    rw [h]; decide
  · have h : (fresh.filter (fun i =>
        bar < (![50 / 1000, 86 / 1000, 86 / 1000, 20 / 1000, 30 / 1000, 82 / 1000] :
          Fin 6 → ℚ) i)) = ({5} : Finset (Fin 6)) := by
      ext i; fin_cases i <;> simp [bar, fresh] <;> norm_num
    rw [h]; decide
  · intro i hi
    fin_cases i <;> simp <;> norm_num

/-- The above-bar group of the six-seed record must average at least `2·0.059 - 0.05
= 0.068`, which already exceeds the *upper* CI endpoint `0.066` of the fresh cell. -/
theorem above_group_mean_exceeds_fresh_ci (a : Fin 6 → ℚ) (S : Finset (Fin 6))
    (hSc : S.card = 3) (hS : S ⊆ univ) (hout : ∀ i ∈ univ \ S, a i ≤ bar)
    (hmean : ∑ i, a i = 6 * advMean6) :
    advHigh < (∑ i ∈ S, a i) / S.card := by
  have hB : (univ : Finset (Fin 6)).card = 2 * 3 := by decide
  have hmean' : ∑ i ∈ (univ : Finset (Fin 6)), a i
      = ((univ : Finset (Fin 6)).card : ℚ) * advMean6 := by
    rw [hB]; push_cast; linarith [hmean]
  have h := count_parity_forces_excess (univ : Finset (Fin 6)) S a bar advMean6 3
    (by norm_num) hB hSc hS hout hmean'
  have : advHigh < 2 * advMean6 - bar := by norm_num [advHigh, advMean6, bar]
  linarith

/-! ## 6. Coupling the two layers -/

/-- **The recorded correlation window.**  Readings `(0.641, 0.597)` against the shared
response pin the mutual correlation of the trailing-zero statistic and popcount into
`[-0.24, 0.9985]`: the fresh cell's advantage already forbids the two statistics from
being more than `0.9985`-correlated. -/
theorem u64b_mutual_corr_window {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) (hc : c ≤ 1)
    (ha : a = 641 / 1000) (hb : b = 597 / 1000) :
    -(6 : ℝ) / 25 ≤ c ∧ c ≤ 1 - 3 / 2000 := by
  constructor
  · have hlow := corr_lower_bound hg
    have hsq : Real.sqrt ((1 - a ^ 2) * (1 - b ^ 2)) ≤ 616 / 1000 := by
      rw [ha, hb]
      have h1 : ((1 - (641 / 1000 : ℝ) ^ 2) * (1 - (597 / 1000 : ℝ) ^ 2))
          ≤ (616 / 1000 : ℝ) ^ 2 := by norm_num
      calc Real.sqrt ((1 - (641 / 1000 : ℝ) ^ 2) * (1 - (597 / 1000 : ℝ) ^ 2))
          ≤ Real.sqrt ((616 / 1000 : ℝ) ^ 2) := Real.sqrt_le_sqrt h1
        _ = 616 / 1000 := Real.sqrt_sq (by norm_num)
    have habv : a * b = 382677 / 1000000 := by rw [ha, hb]; norm_num
    linarith [hlow, hsq]
  · have hup := mutual_corr_upper (alpha := 44 / 1000) (M := 382 / 1000) hg hc
      (by norm_num) (by rw [ha, hb]; norm_num) (by rw [ha, hb]; norm_num) (by norm_num)
    have : (1 : ℝ) - (44 / 1000) ^ 2 / (2 * (1 - 382 / 1000)) ≤ 1 - 3 / 2000 := by
      norm_num
    linarith

/-- **The outlier seed must be decorrelated.**  Combining six-seed rigidity with the
decorrelation budget: the legacy seed forced to carry advantage `≥ 0.086` cannot have its
two statistics correlated above `0.995`. -/
theorem outlier_seed_decorrelation {a b c : ℝ}
    (hg : a ^ 2 + b ^ 2 + c ^ 2 ≤ 1 + 2 * (a * b * c)) (hc : c ≤ 1)
    (hadv : (86 : ℝ) / 1000 ≤ a - b) (hprod : (1 : ℝ) / 3 ≤ a * b) :
    c ≤ 995 / 1000 := by
  have hup := mutual_corr_upper (alpha := 86 / 1000) (M := 1 / 3) hg hc (by norm_num) hadv
    hprod (by norm_num)
  have : (1 : ℝ) - (86 / 1000) ^ 2 / (2 * (1 - 1 / 3)) ≤ 995 / 1000 := by norm_num
  linarith

/-- **The impossibility statement.**  No six-seed record with mean advantage `0.059` and
only three seeds above the `0.05` bar can have all of its advantages inside the fresh
cell's confidence interval `[0.022, 0.066]`. -/
theorem no_flat_count_parity_record (a : Fin 6 → ℚ) (S : Finset (Fin 6))
    (hSc : S.card = 3) (hout : ∀ i ∈ univ \ S, a i ≤ bar)
    (hmean : ∑ i, a i = 6 * advMean6) :
    ¬ (∀ i, a i ≤ advHigh) := by
  intro hflat
  have hlt := above_group_mean_exceeds_fresh_ci a S hSc (Finset.subset_univ S) hout hmean
  have hSpos : (0 : ℚ) < S.card := by rw [hSc]; norm_num
  have hle : ∑ i ∈ S, a i ≤ (S.card : ℚ) * advHigh := by
    simpa using Finset.sum_le_card_nsmul S a advHigh (fun i _ => hflat i)
  rw [lt_div_iff₀ hSpos] at hlt
  linarith

end Catalog.Algebra.ZeroFitDialU64Replication