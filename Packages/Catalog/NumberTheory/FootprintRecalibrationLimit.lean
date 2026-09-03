import Catalog.NumberTheory.QuadraticDialIndependence

/-!
# No recalibration recovery: the exact ceiling of footprint reweighting

This file is the formal core of the round-45 #3 (exp 503) finding
**NO-RECAL-RECOVERY**.  The experimental question was: at tight `u`, the
predictive score built from the small-prime *footprint* of `x² − N` (the vector
of quadratic-residue dials `dial p N`, `p ≤ B`) drops.  Can *refitting the
footprint weights* `β` recover the drop?  Measured answer: no — the refit lands
*below* the unrefit zero-fit dial (paired gain `−0.0238`, 5/5 negative), while
the fitted `β` is nonetheless a stable structural object (rank stability
`0.869` split-half, `0.9433` LOPO) that is *informationally empty*.

Here we prove that this is not an artefact of the fitting procedure but a
theorem about the arithmetic of the dial features.

## Layer 1 — exact least-squares algebra on a finite design

* `mse_expand`, `mse_decomposition` — the exact bias/weight/residual splitting
  of the mean squared error of an affine footprint predictor `c + ∑ βᵢ xᵢ` on an
  *orthogonal design* (uncorrelated, centred features with variances `vᵢ`).
* `mse_zeroFit` — the "zero-fit dial" (no reweighting at all) has MSE exactly
  the variance of the target.
* `recalibration_ceiling` — **the ceiling**: for *every* intercept and *every*
  weight vector, the gain over the zero-fit dial is at most the footprint
  energy `∑ᵢ cov(f, xᵢ)² / vᵢ`, and this bound is attained.
* `gain_neg_of_cov_eq_zero` — if the footprint energy vanishes, then *every*
  nonzero reweighting is **strictly worse** than the zero-fit dial: refitting
  cannot recover, it can only lose.  Recovery is negative, exactly as measured.
* `mse_eq_of_weight_energy_eq`, `mse_neg_beta` — in that regime the loss depends
  on `β` only through `∑ vᵢ βᵢ²`: the *direction* of `β` is invisible to the
  data.  A `β` anti-correlated with the theory profile fits exactly as well as
  its own negation.  This is "stable but informationally empty" made precise.
* `energy_le_variance` — Bessel: the footprint can never explain more than the
  whole variance.
* `cov_sq_le_energy_mul` — Cauchy–Schwarz for the achievable covariance.

## Layer 2 — the arithmetic instance: QR dial footprints

The features are the centred dials `xᵢ(N) = dial pᵢ (Nᵢ) − 1` of
`Catalog.NumberTheory.QRDialLocalStatistics`.

* `avg_footprint`, `avg_footprint_mul`, `avg_footprint_sq` — the dial footprint
  is an orthogonal design with variances `vᵢ = (pᵢ − 1)/pᵢ`
  (`dialDesign_isOrthogonal`), an exact consequence of the joint uniformity
  proved in `Catalog.NumberTheory.QuadraticDialIndependence`.
* `cov_localTarget_eq_zero` — **the localisation theorem**: a target carried by
  the *complementary* (mid-prime / non-footprint) coordinates has exactly zero
  covariance with every small-prime footprint feature.
* `dial_footprint_no_recovery` — the packaged conclusion: for such a target, the
  zero-fit dial is the strict optimum among all reweightings; every nonzero
  refit `β` strictly loses `∑ᵢ vᵢ βᵢ²`, and the direction of `β` is
  unidentifiable.  No weighting of a small-prime footprint of any kind can
  capture content that lives in the mid primes.
-/

namespace ScaleSmoothness

open Finset

/-! ## Layer 1: exact least squares on an orthogonal design -/

section Design

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- Uniform average of a rational observable over a finite sample space. -/
def avg (g : Ω → ℚ) : ℚ := (∑ ω, g ω) / (Fintype.card Ω : ℚ)

/-- The footprint score with weights `β`: the linear part of the predictor. -/
def score (x : ι → Ω → ℚ) (β : ι → ℚ) (ω : Ω) : ℚ := ∑ i, β i * x i ω

/-- Mean squared error of the affine predictor `c + score x β`. -/
def mse (f : Ω → ℚ) (x : ι → Ω → ℚ) (c : ℚ) (β : ι → ℚ) : ℚ :=
  avg fun ω => (f ω - (c + score x β ω)) ^ 2

/-- Covariance of the target with the `i`-th (centred) feature. -/
def cov (f : Ω → ℚ) (x : ι → Ω → ℚ) (i : ι) : ℚ := avg fun ω => f ω * x i ω

/-- The **footprint energy**: the part of the variance of `f` that the features
can explain, `∑ᵢ cov(f, xᵢ)² / vᵢ`. -/
def energy (f : Ω → ℚ) (x : ι → Ω → ℚ) (v : ι → ℚ) : ℚ := ∑ i, (cov f x i) ^ 2 / v i

/-- Variance of the target. -/
def variance (f : Ω → ℚ) : ℚ := avg (fun ω => (f ω) ^ 2) - (avg f) ^ 2

/-- The squared weight energy `∑ᵢ vᵢ βᵢ²` — the only functional of `β` that the
loss can see once the covariances vanish. -/
def weightEnergy (v β : ι → ℚ) : ℚ := ∑ i, v i * (β i) ^ 2

/-- An **orthogonal design**: centred features, pairwise uncorrelated, with
positive variances `v`. -/
structure IsOrthogonalDesign (x : ι → Ω → ℚ) (v : ι → ℚ) : Prop where
  centered : ∀ i, avg (x i) = 0
  orthogonal : ∀ i j, i ≠ j → avg (fun ω => x i ω * x j ω) = 0
  var : ∀ i, avg (fun ω => (x i ω) ^ 2) = v i
  var_pos : ∀ i, 0 < v i

theorem card_ne_zero : ((Fintype.card Ω : ℚ)) ≠ 0 := by
  have : 0 < Fintype.card Ω := Fintype.card_pos
  positivity

omit [Nonempty Ω] in
theorem avg_add (g h : Ω → ℚ) : avg (fun ω => g ω + h ω) = avg g + avg h := by
  simp [avg, Finset.sum_add_distrib, add_div]

omit [Nonempty Ω] in
theorem avg_sub (g h : Ω → ℚ) : avg (fun ω => g ω - h ω) = avg g - avg h := by
  simp [avg, Finset.sum_sub_distrib, sub_div]

omit [Nonempty Ω] in
theorem avg_const_mul (t : ℚ) (g : Ω → ℚ) : avg (fun ω => t * g ω) = t * avg g := by
  simp only [avg, ← Finset.mul_sum]
  ring

theorem avg_const (t : ℚ) : avg (fun _ : Ω => t) = t := by
  rw [avg, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_comm, mul_div_assoc,
    div_self card_ne_zero, mul_one]

omit [Nonempty Ω] in
theorem avg_sum {κ : Type*} [Fintype κ] (g : κ → Ω → ℚ) :
    avg (fun ω => ∑ k, g k ω) = ∑ k, avg (g k) := by
  simp [avg, Finset.sum_comm (s := (univ : Finset Ω)), Finset.sum_div]

omit [Nonempty Ω] [DecidableEq ι] in
/-- The score of an orthogonal design is centred. -/
theorem avg_score {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v) (β : ι → ℚ) :
    avg (score x β) = 0 := by
  have : avg (score x β) = ∑ i, avg (fun ω => β i * x i ω) := avg_sum _
  rw [this]
  refine Finset.sum_eq_zero fun i _ => ?_
  rw [avg_const_mul, hd.centered i, mul_zero]

omit [Nonempty Ω] [DecidableEq ι] in
/-- The covariance of the target with the score is `∑ βᵢ cov(f, xᵢ)`. -/
theorem avg_mul_score (f : Ω → ℚ) (x : ι → Ω → ℚ) (β : ι → ℚ) :
    avg (fun ω => f ω * score x β ω) = ∑ i, β i * cov f x i := by
  have h : (fun ω => f ω * score x β ω) = fun ω => ∑ i, β i * (f ω * x i ω) := by
    funext ω; simp [score, Finset.mul_sum]; ring_nf
  rw [h, avg_sum]
  exact Finset.sum_congr rfl fun i _ => avg_const_mul _ _

omit [Nonempty Ω] in
/-- The second moment of the score on an orthogonal design is `∑ vᵢ βᵢ²`. -/
theorem avg_score_sq {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v) (β : ι → ℚ) :
    avg (fun ω => (score x β ω) ^ 2) = weightEnergy v β := by
  have h : (fun ω => (score x β ω) ^ 2)
      = fun ω => ∑ i, ∑ j, (β i * β j) * (x i ω * x j ω) := by
    funext ω
    simp only [score, sq, Finset.sum_mul, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by ring
  rw [h, avg_sum]
  refine (Finset.sum_congr rfl fun i _ => ?_).trans rfl
  rw [avg_sum]
  have : ∀ j ∈ (univ : Finset ι), avg (fun ω => (β i * β j) * (x i ω * x j ω))
      = if j = i then v i * (β i) ^ 2 else 0 := by
    intro j _
    rw [avg_const_mul]
    by_cases hij : j = i
    · subst hij
      have : (fun ω => x j ω * x j ω) = fun ω => (x j ω) ^ 2 := by funext ω; ring
      rw [if_pos rfl, this, hd.var j]; ring
    · rw [if_neg hij, hd.orthogonal i j (fun h => hij h.symm), mul_zero]
  rw [Finset.sum_congr rfl this, Finset.sum_ite_eq' univ i]
  simp

/-- **Exact expansion of the mean squared error** of an affine footprint
predictor on an orthogonal design. -/
theorem mse_expand {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    (f : Ω → ℚ) (c : ℚ) (β : ι → ℚ) :
    mse f x c β = avg (fun ω => (f ω) ^ 2) - 2 * c * avg f + c ^ 2
      - 2 * (∑ i, β i * cov f x i) + weightEnergy v β := by
  have hexp : (fun ω => (f ω - (c + score x β ω)) ^ 2)
      = fun ω => ((f ω) ^ 2 - (2 * c) * f ω) + ((c ^ 2 - 2 * (f ω * score x β ω))
        + ((score x β ω) ^ 2 + (2 * c) * score x β ω)) := by
    funext ω; ring
  have e1 : avg (fun ω => (f ω) ^ 2 - (2 * c) * f ω)
      = avg (fun ω => (f ω) ^ 2) - (2 * c) * avg f := by
    rw [avg_sub, avg_const_mul]
  have e2 : avg (fun ω => 2 * (f ω * score x β ω)) = 2 * ∑ i, β i * cov f x i := by
    rw [avg_const_mul, avg_mul_score]
  have e3 : avg (fun ω => (2 * c) * score x β ω) = 0 := by
    rw [avg_const_mul, avg_score hd, mul_zero]
  have e4 : avg (fun ω => (score x β ω) ^ 2 + (2 * c) * score x β ω) = weightEnergy v β := by
    rw [avg_add, avg_score_sq hd, e3, add_zero]
  have e5 : avg (fun ω => (c ^ 2 - 2 * (f ω * score x β ω))
        + ((score x β ω) ^ 2 + (2 * c) * score x β ω))
      = (c ^ 2 - 2 * ∑ i, β i * cov f x i) + weightEnergy v β := by
    rw [avg_add, avg_sub, avg_const, e2, e4]
  rw [mse, hexp, avg_add, e1, e5]
  ring

/-- **The decomposition theorem.**  The loss splits exactly into an intercept
term, a weight-misfit term and an irreducible residual `Var f − energy`. -/
theorem mse_decomposition {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    (f : Ω → ℚ) (c : ℚ) (β : ι → ℚ) :
    mse f x c β = (avg f - c) ^ 2 + (∑ i, v i * (β i - cov f x i / v i) ^ 2)
      + (variance f - energy f x v) := by
  rw [mse_expand hd]
  have hterm : ∑ i, v i * (β i - cov f x i / v i) ^ 2
      = ∑ i, (v i * (β i) ^ 2 - 2 * (β i * cov f x i) + (cov f x i) ^ 2 / v i) := by
    refine Finset.sum_congr rfl fun i _ => ?_
    have hv : v i ≠ 0 := ne_of_gt (hd.var_pos i)
    field_simp
    ring
  have hsplit : ∑ i, v i * (β i - cov f x i / v i) ^ 2
      = weightEnergy v β - 2 * (∑ i, β i * cov f x i) + energy f x v := by
    rw [hterm, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
      weightEnergy, energy]
  rw [hsplit, variance]
  ring

/-- The **zero-fit dial**: with no reweighting at all (`β = 0`) and the optimal
intercept, the loss is exactly the variance of the target. -/
theorem mse_zeroFit {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v) (f : Ω → ℚ) :
    mse f x (avg f) 0 = variance f := by
  rw [mse_expand hd]
  simp [weightEnergy, variance]
  ring

/-- **The recalibration ceiling.**  No intercept and no weight vector can beat
the zero-fit dial by more than the footprint energy. -/
theorem recalibration_ceiling {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    (f : Ω → ℚ) (c : ℚ) (β : ι → ℚ) :
    mse f x (avg f) 0 - mse f x c β ≤ energy f x v := by
  rw [mse_zeroFit hd, mse_decomposition hd]
  have h1 : (0 : ℚ) ≤ (avg f - c) ^ 2 := sq_nonneg _
  have h2 : (0 : ℚ) ≤ ∑ i, v i * (β i - cov f x i / v i) ^ 2 :=
    Finset.sum_nonneg fun i _ => mul_nonneg (le_of_lt (hd.var_pos i)) (sq_nonneg _)
  linarith

/-- The ceiling is attained: the optimal refit gains exactly the energy. -/
theorem recalibration_ceiling_attained {x : ι → Ω → ℚ} {v : ι → ℚ}
    (hd : IsOrthogonalDesign x v) (f : Ω → ℚ) :
    mse f x (avg f) 0 - mse f x (avg f) (fun i => cov f x i / v i) = energy f x v := by
  rw [mse_zeroFit hd, mse_decomposition hd]
  simp

/-- **Bessel's inequality** for the footprint design: the explainable energy
never exceeds the variance. -/
theorem energy_le_variance {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    (f : Ω → ℚ) : energy f x v ≤ variance f := by
  have h := mse_decomposition hd f (avg f) (fun i => cov f x i / v i)
  have hnn : 0 ≤ mse f x (avg f) (fun i => cov f x i / v i) :=
    div_nonneg (Finset.sum_nonneg fun ω _ => sq_nonneg _) (by positivity)
  simp only [sub_self] at h
  simp at h
  linarith [h ▸ hnn]

/-- **The exact paired gain in the empty regime.**  If the target is
uncorrelated with every footprint feature, the gain of the refit `(c, β)` over
the zero-fit dial is exactly `−((ᴱf − c)² + ∑ vᵢ βᵢ²)`. -/
theorem gain_eq_of_cov_eq_zero {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    {f : Ω → ℚ} (hcov : ∀ i, cov f x i = 0) (c : ℚ) (β : ι → ℚ) :
    mse f x (avg f) 0 - mse f x c β = -((avg f - c) ^ 2 + weightEnergy v β) := by
  rw [mse_zeroFit hd, mse_decomposition hd]
  have hz : ∀ i, cov f x i / v i = 0 := fun i => by rw [hcov i]; simp
  have henergy : energy f x v = 0 := by simp [energy, hcov]
  have hw : ∑ i, v i * (β i - cov f x i / v i) ^ 2 = weightEnergy v β := by
    rw [weightEnergy]
    exact Finset.sum_congr rfl fun i _ => by rw [hz i, sub_zero]
  rw [hw, henergy]
  ring

/-- **No recovery.**  If the target is uncorrelated with every footprint
feature, then *every* nonzero reweighting is strictly worse than the zero-fit
dial: the paired gain is exactly `−∑ vᵢ βᵢ² < 0`. -/
theorem gain_neg_of_cov_eq_zero {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    {f : Ω → ℚ} (hcov : ∀ i, cov f x i = 0) {β : ι → ℚ} (hβ : β ≠ 0) (c : ℚ) :
    mse f x (avg f) 0 - mse f x c β < 0 := by
  rw [mse_zeroFit hd, mse_decomposition hd]
  have hz : ∀ i, cov f x i / v i = 0 := fun i => by rw [hcov i]; simp
  have henergy : energy f x v = 0 := by simp [energy, hcov]
  obtain ⟨i, hi⟩ : ∃ i, β i ≠ 0 := by
    simpa using Function.ne_iff.1 hβ
  have hpos : 0 < ∑ j, v j * (β j - cov f x j / v j) ^ 2 := by
    refine Finset.sum_pos' (fun j _ => mul_nonneg (hd.var_pos j).le (sq_nonneg _))
      ⟨i, mem_univ i, ?_⟩
    rw [hz i, sub_zero]
    have : 0 < (β i) ^ 2 := by positivity
    exact mul_pos (hd.var_pos i) this
  have hsq : (0 : ℚ) ≤ (avg f - c) ^ 2 := sq_nonneg _
  rw [henergy]
  linarith

/-- **`β` is informationally empty.**  When the covariances vanish, the loss
depends on the weights only through `∑ vᵢ βᵢ²`: two weight vectors of the same
energy — for instance `β` and `−β`, or a `β` aligned with the theory `2/p`
profile and one anti-correlated with it — are indistinguishable. -/
theorem mse_eq_of_weight_energy_eq {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    {f : Ω → ℚ} (hcov : ∀ i, cov f x i = 0) (c : ℚ) {β γ : ι → ℚ}
    (h : weightEnergy v β = weightEnergy v γ) :
    mse f x c β = mse f x c γ := by
  rw [mse_expand hd, mse_expand hd, h]
  simp [hcov]

/-- In particular the sign of a fitted weight vector is unidentifiable. -/
theorem mse_neg_beta {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    {f : Ω → ℚ} (hcov : ∀ i, cov f x i = 0) (c : ℚ) (β : ι → ℚ) :
    mse f x c β = mse f x c (fun i => -β i) :=
  mse_eq_of_weight_energy_eq hd hcov c (by simp [weightEnergy])

omit [Nonempty Ω] [DecidableEq ι] in
/-- **Cauchy–Schwarz for the achievable covariance.**  The covariance of the
target with any score is controlled by the geometric mean of the weight energy
and the footprint energy. -/
theorem cov_sq_le_energy_mul {x : ι → Ω → ℚ} {v : ι → ℚ} (hd : IsOrthogonalDesign x v)
    (f : Ω → ℚ) (β : ι → ℚ) :
    (avg fun ω => f ω * score x β ω) ^ 2 ≤ weightEnergy v β * energy f x v := by
  rw [avg_mul_score]
  have hA : (0 : ℚ) ≤ weightEnergy v β :=
    Finset.sum_nonneg fun i _ => mul_nonneg (hd.var_pos i).le (sq_nonneg _)
  have hC : (0 : ℚ) ≤ energy f x v :=
    Finset.sum_nonneg fun i _ => div_nonneg (sq_nonneg _) (hd.var_pos i).le
  have key : ∀ t : ℚ, 0 ≤ t ^ 2 * weightEnergy v β
      - 2 * t * (∑ i, β i * cov f x i) + energy f x v := by
    intro t
    have hnn : (0 : ℚ) ≤ ∑ i, v i * (t * β i - cov f x i / v i) ^ 2 :=
      Finset.sum_nonneg fun i _ => mul_nonneg (hd.var_pos i).le (sq_nonneg _)
    have hexp : ∑ i, v i * (t * β i - cov f x i / v i) ^ 2
        = t ^ 2 * weightEnergy v β - 2 * t * (∑ i, β i * cov f x i) + energy f x v := by
      rw [weightEnergy, energy, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib,
        ← Finset.sum_add_distrib]
      refine Finset.sum_congr rfl fun i _ => ?_
      have hv : v i ≠ 0 := ne_of_gt (hd.var_pos i)
      field_simp
      ring
    linarith [hexp ▸ hnn]
  rcases eq_or_lt_of_le hA with h | h
  · have hzero : ∀ i ∈ (univ : Finset ι), v i * (β i) ^ 2 = 0 := by
      refine (Finset.sum_eq_zero_iff_of_nonneg fun i _ =>
        mul_nonneg (hd.var_pos i).le (sq_nonneg _)).1 ?_
      exact h.symm
    have hB : (∑ i, β i * cov f x i) = 0 := by
      refine Finset.sum_eq_zero fun i _ => ?_
      have := hzero i (mem_univ i)
      have hbi : β i = 0 := by
        rcases mul_eq_zero.1 this with h' | h'
        · exact absurd h' (ne_of_gt (hd.var_pos i))
        · exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h'
      simp [hbi]
    rw [hB, ← h]
    simp
  · have hk := key ((∑ i, β i * cov f x i) / weightEnergy v β)
    have hne : weightEnergy v β ≠ 0 := ne_of_gt h
    rw [div_pow, div_mul_eq_mul_div, mul_comm 2 ((∑ i, β i * cov f x i) / weightEnergy v β)] at hk
    field_simp at hk
    nlinarith [hk, h]

end Design

/-! ## Layer 2: the arithmetic instance — quadratic-residue dial footprints -/

section DialDesign

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The **centred dial feature** at the prime `p`: `dial p N − 1`, a `{−1,0,1}`
valued observable which is `+1` on quadratic residues, `−1` on nonresidues and
`0` at `N = 0`. -/
def dialFeature (p : ℕ) [NeZero p] (N : ZMod p) : ℚ := (dial p N : ℚ) - 1

/-- The dial feature has mean zero: this is the exact first moment `∑ dial = p`. -/
theorem sum_dialFeature (p : ℕ) [Fact p.Prime] :
    ∑ N : ZMod p, dialFeature p N = 0 := by
  have h : ∑ N : ZMod p, dialFeature p N
      = ((∑ N : ZMod p, dial p N : ℕ) : ℚ) - (Fintype.card (ZMod p) : ℚ) := by
    simp only [dialFeature, Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
      nsmul_eq_mul, mul_one]
    push_cast
    ring
  rw [h, sum_dial p, ZMod.card]
  ring

/-- The dial feature has second moment `p − 1`: this is the exact second moment
`∑ (dial p N)² = 2p − 1`. -/
theorem sum_dialFeature_sq (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, (dialFeature p N) ^ 2 = (p : ℚ) - 1 := by
  have h3 : 3 ≤ p := three_le_of_ne_two p hp
  have hsq : ((∑ N : ZMod p, (dial p N) ^ 2 : ℕ) : ℚ) = 2 * (p : ℚ) - 1 := by
    rw [sum_dial_sq p hp]
    push_cast [Nat.cast_sub (by omega : 1 ≤ 2 * p)]
    ring
  have hlin : ((∑ N : ZMod p, dial p N : ℕ) : ℚ) = (p : ℚ) := by rw [sum_dial p]
  have hterm : ∀ N : ZMod p,
      (dialFeature p N) ^ 2 = ((dial p N : ℚ)) ^ 2 - 2 * ((dial p N : ℚ)) + 1 := by
    intro N
    simp only [dialFeature]
    ring
  have hexp : ∑ N : ZMod p, (dialFeature p N) ^ 2
      = ((∑ N : ZMod p, (dial p N) ^ 2 : ℕ) : ℚ)
        - 2 * ((∑ N : ZMod p, dial p N : ℕ) : ℚ) + (Fintype.card (ZMod p) : ℚ) := by
    rw [Finset.sum_congr rfl fun N _ => hterm N, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.mul_sum, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one]
    push_cast
    ring
  rw [hexp, hsq, hlin, ZMod.card]
  ring

variable (a : ι → ℕ) [∀ i, Fact (a i).Prime]

/-- **Factorisation of sums over residue data.**  A sum of a product of local
observables over all residue data is the product of the local sums; this is the
independence engine behind everything below. -/
theorem sum_pi_prod (g : ∀ k, ZMod (a k) → ℚ) :
    ∑ N : (∀ k, ZMod (a k)), ∏ k, g k (N k) = ∏ k, ∑ x : ZMod (a k), g k x := by
  rw [Finset.prod_univ_sum]
  apply Finset.sum_congr
  · simp [Fintype.piFinset_univ]
  · intro N _
    rfl

/-- The footprint design attached to a set `s` of small primes: the family of
centred dials `N ↦ dial pᵢ (Nᵢ) − 1`, `i ∈ s`. -/
def dialFootprint (s : Finset ι) : {i // i ∈ s} → (∀ k, ZMod (a k)) → ℚ :=
  fun i N => dialFeature (a i.1) (N i.1)

/-- The exact variance `(p − 1)/p` of a centred dial feature. -/
def dialVar (s : Finset ι) : {i // i ∈ s} → ℚ :=
  fun i => ((a i.1 : ℚ) - 1) / (a i.1 : ℚ)

variable (hodd : ∀ i, a i ≠ 2)

include hodd

omit [Fintype ι] [DecidableEq ι] in
theorem three_le_a_cast (k : ι) : (3 : ℚ) ≤ (a k : ℚ) := by
  have h3 := three_le_of_ne_two (a k) (hodd k)
  exact_mod_cast h3

omit hodd in
/-- Every centred dial feature has mean zero on the residue data. -/
theorem avg_dialFootprint (s : Finset ι) (i : {i // i ∈ s}) :
    avg (dialFootprint a s i) = 0 := by
  have hprod : ∀ N : (∀ k, ZMod (a k)),
      dialFootprint a s i N = ∏ k, (if k = i.1 then dialFeature (a k) (N k) else 1) := by
    intro N
    rw [Finset.prod_ite_eq' univ i.1 (fun k => dialFeature (a k) (N k))]
    simp [dialFootprint]
  have hsum : ∑ N : (∀ k, ZMod (a k)), dialFootprint a s i N = 0 := by
    rw [Finset.sum_congr rfl fun N _ => hprod N,
      sum_pi_prod a (fun k x => if k = i.1 then dialFeature (a k) x else 1)]
    refine Finset.prod_eq_zero (mem_univ i.1) ?_
    simp only [reduceIte]
    exact sum_dialFeature (a i.1)
  rw [avg, hsum, zero_div]

omit hodd in
/-- Distinct primes give uncorrelated dial features: exact independence. -/
theorem avg_dialFootprint_mul (s : Finset ι) (i j : {i // i ∈ s}) (hij : i ≠ j) :
    avg (fun N => dialFootprint a s i N * dialFootprint a s j N) = 0 := by
  have hne : i.1 ≠ j.1 := fun h => hij (Subtype.ext h)
  have hprod : ∀ N : (∀ k, ZMod (a k)),
      dialFootprint a s i N * dialFootprint a s j N
        = ∏ k, ((if k = i.1 then dialFeature (a k) (N k) else 1)
            * (if k = j.1 then dialFeature (a k) (N k) else 1)) := by
    intro N
    rw [Finset.prod_mul_distrib, Finset.prod_ite_eq' univ i.1 (fun k => dialFeature (a k) (N k)),
      Finset.prod_ite_eq' univ j.1 (fun k => dialFeature (a k) (N k))]
    simp [dialFootprint]
  have hsum : ∑ N : (∀ k, ZMod (a k)),
      dialFootprint a s i N * dialFootprint a s j N = 0 := by
    rw [Finset.sum_congr rfl fun N _ => hprod N,
      sum_pi_prod a (fun k x => (if k = i.1 then dialFeature (a k) x else 1)
        * (if k = j.1 then dialFeature (a k) x else 1))]
    refine Finset.prod_eq_zero (mem_univ i.1) ?_
    simp only [if_neg hne, mul_one]
    exact sum_dialFeature (a i.1)
  rw [avg, hsum, zero_div]

/-- The variance of a centred dial feature is exactly `(p − 1)/p`. -/
theorem avg_dialFootprint_sq (s : Finset ι) (i : {i // i ∈ s}) :
    avg (fun N => (dialFootprint a s i N) ^ 2) = dialVar a s i := by
  have hprod : ∀ N : (∀ k, ZMod (a k)),
      (dialFootprint a s i N) ^ 2
        = ∏ k, (if k = i.1 then (dialFeature (a k) (N k)) ^ 2 else 1) := by
    intro N
    rw [Finset.prod_ite_eq' univ i.1 (fun k => (dialFeature (a k) (N k)) ^ 2)]
    simp [dialFootprint]
  have hlocal : ∀ k, (∑ x : ZMod (a k), if k = i.1 then (dialFeature (a k) x) ^ 2 else 1)
      = if k = i.1 then (a k : ℚ) - 1 else (a k : ℚ) := by
    intro k
    by_cases hk : k = i.1
    · simp only [if_pos hk]
      exact sum_dialFeature_sq (a k) (hodd k)
    · simp only [if_neg hk, Finset.sum_const, Finset.card_univ, ZMod.card, nsmul_eq_mul, mul_one]
  have hsum : ∑ N : (∀ k, ZMod (a k)), (dialFootprint a s i N) ^ 2
      = ((a i.1 : ℚ) - 1) * ∏ k ∈ univ.erase i.1, (a k : ℚ) := by
    rw [Finset.sum_congr rfl fun N _ => hprod N,
      sum_pi_prod a (fun k x => if k = i.1 then (dialFeature (a k) x) ^ 2 else 1),
      Finset.prod_congr rfl fun k _ => hlocal k,
      ← Finset.mul_prod_erase univ _ (mem_univ i.1)]
    simp only [reduceIte]
    congr 1
    exact Finset.prod_congr rfl fun k hk => by
      rw [if_neg (Finset.ne_of_mem_erase hk)]
  have hcard : ((Fintype.card (∀ k, ZMod (a k)) : ℚ)) = ∏ k, (a k : ℚ) := card_pi_zmod a
  have hsplit : (∏ k, (a k : ℚ)) = (a i.1 : ℚ) * ∏ k ∈ univ.erase i.1, (a k : ℚ) :=
    (Finset.mul_prod_erase univ _ (mem_univ i.1)).symm
  have hP : (∏ k ∈ univ.erase i.1, (a k : ℚ)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.2 fun k _ => ?_
    have := three_le_a_cast a hodd k
    linarith
  have hai : (a i.1 : ℚ) ≠ 0 := by
    have := three_le_a_cast a hodd i.1
    linarith
  rw [avg, hsum, hcard, hsplit, dialVar]
  field_simp

/-- **The dial footprint is an orthogonal design.**  Centred, exactly pairwise
uncorrelated, with variances `(p − 1)/p`.  This is the joint uniformity of
`Catalog.NumberTheory.QuadraticDialIndependence` in second-moment form. -/
theorem dialDesign_isOrthogonal (s : Finset ι) :
    IsOrthogonalDesign (dialFootprint a s) (dialVar a s) where
  centered i := avg_dialFootprint a s i
  orthogonal i j hij := avg_dialFootprint_mul a s i j hij
  var i := avg_dialFootprint_sq a hodd s i
  var_pos i := by
    have h3 := three_le_a_cast a hodd i.1
    rw [dialVar]
    apply div_pos <;> linarith

omit hodd

/-- A **local target**: an observable of the residue data that is a product of
per-prime factors, e.g. the structure correction of
`Catalog.NumberTheory.ScaleSmoothnessDispersion`. -/
def localTarget (h : ∀ k, ZMod (a k) → ℚ) : (∀ k, ZMod (a k)) → ℚ := fun N => ∏ k, h k (N k)

/-- **Localisation of the lost content.**  If the target is carried by the
primes *outside* the footprint `s` — the mid primes — then its covariance with
*every* footprint feature is exactly zero. -/
theorem cov_localTarget_eq_zero (s : Finset ι) (h : ∀ k, ZMod (a k) → ℚ)
    (hs : ∀ i ∈ s, ∀ x : ZMod (a i), h i x = 1) (i : {i // i ∈ s}) :
    cov (localTarget a h) (dialFootprint a s) i = 0 := by
  have hprod : ∀ N : (∀ k, ZMod (a k)),
      localTarget a h N * dialFootprint a s i N
        = ∏ k, (h k (N k) * (if k = i.1 then dialFeature (a k) (N k) else 1)) := by
    intro N
    rw [Finset.prod_mul_distrib, Finset.prod_ite_eq' univ i.1 (fun k => dialFeature (a k) (N k))]
    simp [localTarget, dialFootprint]
  have hsum : ∑ N : (∀ k, ZMod (a k)), localTarget a h N * dialFootprint a s i N = 0 := by
    rw [Finset.sum_congr rfl fun N _ => hprod N,
      sum_pi_prod a (fun k x => h k x * (if k = i.1 then dialFeature (a k) x else 1))]
    refine Finset.prod_eq_zero (mem_univ i.1) ?_
    simp only [reduceIte]
    rw [Finset.sum_congr rfl fun x _ => by rw [hs i.1 i.2 x, one_mul]]
    exact sum_dialFeature (a i.1)
  rw [cov, avg, hsum, zero_div]

include hodd in
/-- **NO-RECAL-RECOVERY, arithmetic form.**  For a target carried by the mid
primes, refitting the small-prime footprint weights cannot recover anything:
the paired gain of *any* refit `(c, β)` over the zero-fit dial is exactly
`−((𝔼f − c)² + ∑ᵢ ((pᵢ−1)/pᵢ) βᵢ²)`. -/
theorem dial_footprint_gain_eq (s : Finset ι) (h : ∀ k, ZMod (a k) → ℚ)
    (hs : ∀ i ∈ s, ∀ x : ZMod (a i), h i x = 1) (c : ℚ) (β : {i // i ∈ s} → ℚ) :
    mse (localTarget a h) (dialFootprint a s) (avg (localTarget a h)) 0
        - mse (localTarget a h) (dialFootprint a s) c β
      = -((avg (localTarget a h) - c) ^ 2 + weightEnergy (dialVar a s) β) :=
  gain_eq_of_cov_eq_zero (dialDesign_isOrthogonal a hodd s)
    (cov_localTarget_eq_zero a s h hs) c β

include hodd in
/-- Every nonzero reweighting of the small-prime footprint is **strictly worse**
than the unrefit zero-fit dial. -/
theorem dial_footprint_no_recovery (s : Finset ι) (h : ∀ k, ZMod (a k) → ℚ)
    (hs : ∀ i ∈ s, ∀ x : ZMod (a i), h i x = 1) (c : ℚ) {β : {i // i ∈ s} → ℚ} (hβ : β ≠ 0) :
    mse (localTarget a h) (dialFootprint a s) (avg (localTarget a h)) 0
      < mse (localTarget a h) (dialFootprint a s) c β := by
  have := gain_neg_of_cov_eq_zero (dialDesign_isOrthogonal a hodd s)
    (cov_localTarget_eq_zero a s h hs) hβ c
  linarith

include hodd in
/-- **`β` is a structural object without information.**  For a mid-prime target
the loss sees only `∑ᵢ ((pᵢ−1)/pᵢ) βᵢ²`; in particular a fitted weight vector and
its negation — one of which is anti-correlated with any prescribed theory
profile — are exactly equally good. -/
theorem dial_footprint_beta_unidentified (s : Finset ι) (h : ∀ k, ZMod (a k) → ℚ)
    (hs : ∀ i ∈ s, ∀ x : ZMod (a i), h i x = 1) (c : ℚ) (β : {i // i ∈ s} → ℚ) :
    mse (localTarget a h) (dialFootprint a s) c β
      = mse (localTarget a h) (dialFootprint a s) c (fun i => -β i) :=
  mse_neg_beta (dialDesign_isOrthogonal a hodd s) (cov_localTarget_eq_zero a s h hs) c β

end DialDesign

end ScaleSmoothness