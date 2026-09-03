import Catalog.NumberTheory.FootprintRecalibrationLimit

/-!
# The exact recalibration ceiling for the structure correction

`Catalog.NumberTheory.FootprintRecalibrationLimit` proved the *qualitative* half
of the round-45 #3 (exp 503) finding NO-RECAL-RECOVERY: content living outside
the small-prime footprint is invisible to every reweighting of that footprint.
This file proves the *quantitative* half for the one target that actually
matters arithmetically — the **structure correction**
`C(N) = ∏_p (p − dial p N)/(p − 1)` of
`Catalog.NumberTheory.ScaleSmoothnessDispersion`, the exact multiplicative
smoothness bias of `x² − N`.

The structure correction is *not* orthogonal to the footprint: each dial carries
a nonzero amount of it.  We compute that amount exactly and show that it still
does not suffice.

## Main results

* `sum_localFactor_mul_dialFeature` — the exact local coupling
  `∑_N localFactor p N · (dial p N − 1) = −1`, i.e. covariance `−1/p`.
* `cov_structureCorrection` — **the exact footprint signal**:
  `cov(C, xᵢ) = −1/pᵢ`.  The theory profile of the optimal weights is therefore
  `βᵢ* = −1/(pᵢ − 1)`, a *negative*, `1/p`-shaped profile.
* `energy_structureCorrection` — **the exact recalibration ceiling**: the best
  achievable gain from refitting all footprint weights is
  `∑_p 1/(p(p−1))`.
* `variance_structureCorrection` — the total signal is
  `∏_p (1 + 1/(p(p−1))) − 1`.
* `structureCorrection_deficit_pos` / `energy_lt_variance_structureCorrection` —
  **the deficit theorem**: as soon as the footprint contains two primes, the
  ceiling is *strictly* below the variance.  The unreachable share is exactly
  the multi-prime interaction part `∏(1 + cₚ) − 1 − ∑ cₚ > 0` of the structure
  correction: no weighting of one-prime dial features can ever reach it.
* `structureCorrection_recalibration_ceiling` — the packaged statement: for
  every intercept and every weight vector the paired gain over the zero-fit dial
  is at most `∑ 1/(p(p−1))`, strictly less than the variance.
* `Example357` — the fully explicit instance `{3,5,7}`: ceiling `101/420`,
  variance `61/240`, deficit `101/420 < 61/240`.
-/

namespace ScaleSmoothness

open Finset

/-! ### A Weierstrass product inequality -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [Fintype ι] in
/-- Weierstrass: `1 + ∑ cᵢ ≤ ∏ (1 + cᵢ)` for nonnegative `c`. -/
theorem one_add_sum_le_prod_one_add (s : Finset ι) (c : ι → ℚ) (hc : ∀ i ∈ s, 0 ≤ c i) :
    1 + ∑ i ∈ s, c i ≤ ∏ i ∈ s, (1 + c i) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | insert i s hi ih =>
    rw [Finset.sum_insert hi, Finset.prod_insert hi]
    have h0 : 0 ≤ c i := hc i (Finset.mem_insert_self i s)
    have hsub : ∀ j ∈ s, 0 ≤ c j := fun j hj => hc j (Finset.mem_insert_of_mem hj)
    have hrest := ih hsub
    have hsum : 0 ≤ ∑ j ∈ s, c j := Finset.sum_nonneg hsub
    nlinarith

/-- **Quantitative Weierstrass.**  The linear approximation misses at least the
full interaction of one coordinate with all the others. -/
theorem one_add_sum_add_mul_le_prod_one_add (c : ι → ℚ) (hc : ∀ i, 0 ≤ c i) (i : ι) :
    1 + ∑ k, c k + c i * ∑ k ∈ univ.erase i, c k ≤ ∏ k, (1 + c k) := by
  have hsplit : (∏ k, (1 + c k)) = (1 + c i) * ∏ k ∈ univ.erase i, (1 + c k) :=
    (Finset.mul_prod_erase univ _ (mem_univ i)).symm
  have hssplit : c i + ∑ k ∈ univ.erase i, c k = ∑ k, c k :=
    Finset.add_sum_erase univ c (mem_univ i)
  have hrest : 1 + ∑ k ∈ univ.erase i, c k ≤ ∏ k ∈ univ.erase i, (1 + c k) :=
    one_add_sum_le_prod_one_add _ c fun k _ => hc k
  have hci : (0 : ℚ) < 1 + c i := by linarith [hc i]
  have hmul : (1 + c i) * (1 + ∑ k ∈ univ.erase i, c k)
      ≤ (1 + c i) * ∏ k ∈ univ.erase i, (1 + c k) :=
    mul_le_mul_of_nonneg_left hrest hci.le
  nlinarith [hc i]

/-- **Strict** Weierstrass in the presence of two positive entries: the pairwise
interaction term is genuinely lost by the linear approximation. -/
theorem one_add_sum_lt_prod_one_add (c : ι → ℚ) (hc : ∀ i, 0 < c i) {i j : ι} (hij : i ≠ j) :
    1 + ∑ k, c k < ∏ k, (1 + c k) := by
  have hsplit : (∏ k, (1 + c k)) = (1 + c i) * ∏ k ∈ univ.erase i, (1 + c k) :=
    (Finset.mul_prod_erase univ _ (mem_univ i)).symm
  have hssplit : c i + ∑ k ∈ univ.erase i, c k = ∑ k, c k :=
    Finset.add_sum_erase univ c (mem_univ i)
  have hrest : 1 + ∑ k ∈ univ.erase i, c k ≤ ∏ k ∈ univ.erase i, (1 + c k) :=
    one_add_sum_le_prod_one_add _ c fun k _ => (hc k).le
  have hjmem : j ∈ univ.erase i := Finset.mem_erase.2 ⟨fun h => hij h.symm, mem_univ j⟩
  have hTpos : 0 < ∑ k ∈ univ.erase i, c k :=
    Finset.sum_pos' (fun k _ => (hc k).le) ⟨j, hjmem, hc j⟩
  have hci : 0 < 1 + c i := by linarith [hc i]
  have hmul : (1 + c i) * (1 + ∑ k ∈ univ.erase i, c k)
      ≤ (1 + c i) * ∏ k ∈ univ.erase i, (1 + c k) := by
    exact mul_le_mul_of_nonneg_left hrest hci.le
  nlinarith [hc i, hTpos]

/-! ### The exact coupling between the structure correction and the dials -/

/-- **Exact local coupling.**  Summed over the residue classes mod `p`, the
product of the local structure correction with the centred dial is exactly `−1`:
a quadratic residue *lowers* the smoothness weight, by precisely `1/(p−1)`. -/
theorem sum_localFactor_mul_dialFeature (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∑ N : ZMod p, localFactor p N * dialFeature p N = -1 := by
  have h3 : 3 ≤ p := three_le_of_ne_two p hp
  have h3' : (3 : ℚ) ≤ (p : ℚ) := by exact_mod_cast h3
  have hp1 : ((p : ℚ) - 1) ≠ 0 := by linarith
  have hterm : ∀ N : ZMod p, localFactor p N * dialFeature p N
      = dialFeature p N - (dialFeature p N) ^ 2 / ((p : ℚ) - 1) := by
    intro N
    rw [localFactor, dialFeature]
    field_simp
    ring
  rw [Finset.sum_congr rfl fun N _ => hterm N, Finset.sum_sub_distrib, ← Finset.sum_div,
    sum_dialFeature p, sum_dialFeature_sq p hp, div_self hp1]
  ring

section Family

variable (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2)

include hodd

/-- **The exact footprint signal.**  The covariance of the structure correction
with the centred dial at `pᵢ` is exactly `−1/pᵢ`: the whole first-order content
of the smoothness bias visible to a single small prime. -/
theorem cov_structureCorrection (s : Finset ι) (i : {i // i ∈ s}) :
    cov (structureCorrection a) (dialFootprint a s) i = -1 / (a i.1 : ℚ) := by
  have hprod : ∀ N : (∀ k, ZMod (a k)),
      structureCorrection a N * dialFootprint a s i N
        = ∏ k, (localFactor (a k) (N k)
            * (if k = i.1 then dialFeature (a k) (N k) else 1)) := by
    intro N
    rw [Finset.prod_mul_distrib, Finset.prod_ite_eq' univ i.1 (fun k => dialFeature (a k) (N k))]
    simp [structureCorrection, dialFootprint]
  have hlocal : ∀ k, (∑ x : ZMod (a k),
      localFactor (a k) x * (if k = i.1 then dialFeature (a k) x else 1))
      = if k = i.1 then (-1 : ℚ) else (a k : ℚ) := by
    intro k
    by_cases hk : k = i.1
    · simp only [if_pos hk]
      exact sum_localFactor_mul_dialFeature (a k) (hodd k)
    · simp only [if_neg hk, mul_one]
      exact sum_localFactor (a k) (hodd k)
  have hsum : ∑ N : (∀ k, ZMod (a k)), structureCorrection a N * dialFootprint a s i N
      = (-1 : ℚ) * ∏ k ∈ univ.erase i.1, (a k : ℚ) := by
    rw [Finset.sum_congr rfl fun N _ => hprod N,
      sum_pi_prod a (fun k x => localFactor (a k) x
        * (if k = i.1 then dialFeature (a k) x else 1)),
      Finset.prod_congr rfl fun k _ => hlocal k,
      ← Finset.mul_prod_erase univ _ (mem_univ i.1)]
    simp only [reduceIte]
    congr 1
    exact Finset.prod_congr rfl fun k hk => by rw [if_neg (Finset.ne_of_mem_erase hk)]
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
  rw [cov, avg, hsum, hcard, hsplit]
  field_simp

/-- **The exact recalibration ceiling.**  The energy of the structure correction
in the footprint design is exactly `∑_p 1/(p(p−1))`. -/
theorem energy_structureCorrection (s : Finset ι) :
    energy (structureCorrection a) (dialFootprint a s) (dialVar a s)
      = ∑ i : {i // i ∈ s}, 1 / ((a i.1 : ℚ) * ((a i.1 : ℚ) - 1)) := by
  rw [energy]
  refine Finset.sum_congr rfl fun i _ => ?_
  have h3 := three_le_a_cast a hodd i.1
  have hai : (a i.1 : ℚ) ≠ 0 := by linarith
  have ha1 : ((a i.1 : ℚ) - 1) ≠ 0 := by linarith
  rw [cov_structureCorrection a hodd s i, dialVar]
  field_simp

/-- The mean structure correction is exactly `1`. -/
theorem avg_structureCorrection : avg (structureCorrection a) = 1 := by
  have hP : (∏ k, (a k : ℚ)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.2 fun k _ => ?_
    have := three_le_a_cast a hodd k
    linarith
  rw [avg, sum_structureCorrection a hodd, card_pi_zmod a, div_self hP]

/-- The variance of the structure correction is exactly
`∏_p (1 + 1/(p(p−1))) − 1`. -/
theorem variance_structureCorrection :
    variance (structureCorrection a) = dispersionBound a - 1 := by
  have hP : (∏ k, (a k : ℚ)) ≠ 0 := by
    refine Finset.prod_ne_zero_iff.2 fun k _ => ?_
    have := three_le_a_cast a hodd k
    linarith
  have h2 : avg (fun N => (structureCorrection a N) ^ 2) = dispersionBound a := by
    rw [avg, sum_structureCorrection_sq a hodd, prod_second_moment_eq a hodd, card_pi_zmod a,
      mul_comm, mul_div_assoc, div_self hP, mul_one]
  rw [variance, h2, avg_structureCorrection a hodd]
  ring

/-- **The deficit theorem.**  With two or more footprint primes the ceiling is
*strictly* below the variance: the interaction content of the structure
correction is unreachable by any reweighting of one-prime dial features. -/
theorem energy_lt_variance_structureCorrection {i j : ι} (hij : i ≠ j) :
    energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ)
      < variance (structureCorrection a) := by
  have hc : ∀ k : ι, (0 : ℚ) < 1 / ((a k : ℚ) * ((a k : ℚ) - 1)) := by
    intro k
    have := three_le_a_cast a hodd k
    have h1 : (0 : ℚ) < (a k : ℚ) * ((a k : ℚ) - 1) := by nlinarith
    positivity
  have hstrict := one_add_sum_lt_prod_one_add
    (fun k : ι => 1 / ((a k : ℚ) * ((a k : ℚ) - 1))) hc hij
  have hE : energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ)
      = ∑ k, 1 / ((a k : ℚ) * ((a k : ℚ) - 1)) := by
    rw [energy_structureCorrection a hodd univ]
    exact Finset.sum_coe_sort univ (fun k => 1 / ((a k : ℚ) * ((a k : ℚ) - 1)))
  rw [hE, variance_structureCorrection a hodd, dispersionBound]
  linarith

/-- **Quantitative deficit bound.**  The share of the structure correction that
*no* footprint reweighting can reach is at least the full interaction of any one
footprint prime with all the others:
`Var − ceiling ≥ (1/(p(p−1))) · ∑_{q ≠ p} 1/(q(q−1))`. -/
theorem structureCorrection_deficit_lower_bound (i : ι) :
    (1 / ((a i : ℚ) * ((a i : ℚ) - 1)))
        * ∑ k ∈ univ.erase i, 1 / ((a k : ℚ) * ((a k : ℚ) - 1))
      ≤ variance (structureCorrection a)
        - energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ) := by
  have hc : ∀ k : ι, (0 : ℚ) ≤ 1 / ((a k : ℚ) * ((a k : ℚ) - 1)) := by
    intro k
    have := three_le_a_cast a hodd k
    have h1 : (0 : ℚ) < (a k : ℚ) * ((a k : ℚ) - 1) := by nlinarith
    positivity
  have hq := one_add_sum_add_mul_le_prod_one_add
    (fun k : ι => 1 / ((a k : ℚ) * ((a k : ℚ) - 1))) hc i
  have hE : energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ)
      = ∑ k, 1 / ((a k : ℚ) * ((a k : ℚ) - 1)) := by
    rw [energy_structureCorrection a hodd univ]
    exact Finset.sum_coe_sort univ (fun k => 1 / ((a k : ℚ) * ((a k : ℚ) - 1)))
  rw [hE, variance_structureCorrection a hodd, dispersionBound]
  linarith

/-- **Packaged NO-RECAL-RECOVERY for the structure correction.**  For every
intercept `c` and every weight vector `β`, the paired gain over the unrefit
zero-fit dial is at most `∑_p 1/(p(p−1))`, and that ceiling is strictly below
the total signal as soon as the footprint contains two primes. -/
theorem structureCorrection_recalibration_ceiling {i j : ι} (hij : i ≠ j)
    (c : ℚ) (β : {k // k ∈ (univ : Finset ι)} → ℚ) :
    mse (structureCorrection a) (dialFootprint a univ)
          (avg (structureCorrection a)) 0
        - mse (structureCorrection a) (dialFootprint a univ) c β
      ≤ ∑ k, 1 / ((a k : ℚ) * ((a k : ℚ) - 1))
    ∧ (∑ k, 1 / ((a k : ℚ) * ((a k : ℚ) - 1))) < variance (structureCorrection a) := by
  have hE : energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ)
      = ∑ k, 1 / ((a k : ℚ) * ((a k : ℚ) - 1)) := by
    rw [energy_structureCorrection a hodd univ]
    exact Finset.sum_coe_sort univ (fun k => 1 / ((a k : ℚ) * ((a k : ℚ) - 1)))
  refine ⟨?_, ?_⟩
  · have := recalibration_ceiling (dialDesign_isOrthogonal a hodd univ)
      (structureCorrection a) c β
    rwa [hE] at this
  · have := energy_lt_variance_structureCorrection a hodd hij
    rwa [hE] at this

/-- The optimal footprint weights: `βᵢ* = −1/(pᵢ − 1)`, a negative `1/p`-shaped
profile, and it attains the ceiling exactly. -/
theorem optimal_weights_structureCorrection (s : Finset ι) (i : {i // i ∈ s}) :
    cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i
      = -1 / ((a i.1 : ℚ) - 1) := by
  have h3 := three_le_a_cast a hodd i.1
  have hai : (a i.1 : ℚ) ≠ 0 := by linarith
  have ha1 : ((a i.1 : ℚ) - 1) ≠ 0 := by linarith
  rw [cov_structureCorrection a hodd s i, dialVar]
  field_simp

/-- **The optimal profile is negative**, hence anti-correlated with any positive
"theory" profile such as `2/p`: the arithmetic forces the fitted weights to have
the opposite sign to the naive `2/p` shape. -/
theorem optimal_profile_anticorrelated (s : Finset ι) {i₀ : ι} (hi₀ : i₀ ∈ s) :
    ∑ i : {i // i ∈ s},
        (cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i)
          * (2 / (a i.1 : ℚ)) < 0 := by
  have hlt : ∀ i : {i // i ∈ s},
      (cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i)
        * (2 / (a i.1 : ℚ)) < 0 := by
    intro i
    have h3 := three_le_a_cast a hodd i.1
    rw [optimal_weights_structureCorrection a hodd s i]
    have h1 : (0 : ℚ) < 2 / (a i.1 : ℚ) := by positivity
    have h2 : (-1 : ℚ) / ((a i.1 : ℚ) - 1) < 0 := div_neg_of_neg_of_pos (by norm_num) (by linarith)
    exact mul_neg_of_neg_of_pos h2 h1
  have hne : (univ : Finset {i // i ∈ s}).Nonempty := ⟨⟨i₀, hi₀⟩, mem_univ _⟩
  calc ∑ i : {i // i ∈ s},
        (cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i) * (2 / (a i.1 : ℚ))
      < ∑ _i : {i // i ∈ s}, (0 : ℚ) :=
        Finset.sum_lt_sum_of_nonempty hne fun i _ => hlt i
    _ = 0 := by simp

/-- **A positively-weighted footprint refit is strictly worse than not refitting
at all.**  Because the true optimal profile is negative, *every* nonnegative,
somewhere-positive weight vector — in particular the theory `2/p` profile —
lands strictly below the unrefit zero-fit dial.  The measured negative paired
gain of a wrongly-signed recalibration is therefore forced, not accidental. -/
theorem positive_profile_gain_neg (s : Finset ι) (c : ℚ) (β : {i // i ∈ s} → ℚ)
    (hβ : ∀ i, 0 ≤ β i) {i₀ : {i // i ∈ s}} (hβ0 : 0 < β i₀) :
    mse (structureCorrection a) (dialFootprint a s) (avg (structureCorrection a)) 0
      < mse (structureCorrection a) (dialFootprint a s) c β := by
  have hd := dialDesign_isOrthogonal a hodd s
  have hvpos : ∀ i : {i // i ∈ s}, 0 < dialVar a s i := hd.var_pos
  have hwneg : ∀ i : {i // i ∈ s},
      cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i < 0 := by
    intro i
    have h3 := three_le_a_cast a hodd i.1
    rw [optimal_weights_structureCorrection a hodd s i]
    exact div_neg_of_neg_of_pos (by norm_num) (by linarith)
  have henergy : energy (structureCorrection a) (dialFootprint a s) (dialVar a s)
      = ∑ i, dialVar a s i
          * (cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i) ^ 2 := by
    rw [energy]
    refine Finset.sum_congr rfl fun i _ => ?_
    have hv : dialVar a s i ≠ 0 := ne_of_gt (hvpos i)
    field_simp
  have hkey : energy (structureCorrection a) (dialFootprint a s) (dialVar a s)
      < ∑ i, dialVar a s i
          * (β i - cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i) ^ 2 := by
    rw [henergy]
    refine Finset.sum_lt_sum (fun i _ => ?_) ⟨i₀, mem_univ i₀, ?_⟩
    · have hv := hvpos i
      have hw := hwneg i
      have hb := hβ i
      have hstep : (cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i) ^ 2
          ≤ (β i - cov (structureCorrection a) (dialFootprint a s) i / dialVar a s i) ^ 2 := by
        nlinarith [mul_nonneg hb (neg_nonneg.2 hw.le), sq_nonneg (β i)]
      exact mul_le_mul_of_nonneg_left hstep hv.le
    · have hv := hvpos i₀
      have hw := hwneg i₀
      have hstep : (cov (structureCorrection a) (dialFootprint a s) i₀ / dialVar a s i₀) ^ 2
          < (β i₀ - cov (structureCorrection a) (dialFootprint a s) i₀ / dialVar a s i₀) ^ 2 := by
        nlinarith [mul_pos hβ0 (neg_pos.2 hw), sq_nonneg (β i₀)]
      exact mul_lt_mul_of_pos_left hstep hv
  rw [mse_zeroFit hd, mse_decomposition hd]
  have hsq : (0 : ℚ) ≤ (avg (structureCorrection a) - c) ^ 2 := sq_nonneg _
  linarith

end Family

/-! ### The explicit instance `{3, 5, 7}` -/

namespace Example357

/-- The recalibration ceiling of the `{3,5,7}` footprint is exactly
`1/6 + 1/20 + 1/42 = 101/420 ≈ 0.2405`. -/
theorem energy_eq :
    energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ) = 101 / 420 := by
  rw [energy_structureCorrection a a_ne_two univ,
    Finset.sum_coe_sort univ (fun k => 1 / ((a k : ℚ) * ((a k : ℚ) - 1)))]
  simp [Fin.sum_univ_three, a]
  norm_num

/-- The total signal is `301/240 − 1 = 61/240 ≈ 0.2542`. -/
theorem variance_eq : variance (structureCorrection a) = 61 / 240 := by
  rw [variance_structureCorrection a a_ne_two, dispersionBound_eq]
  norm_num

/-- **The measured shape of NO-RECAL-RECOVERY.**  Even a perfectly refitted
`{3,5,7}` footprint reaches only `101/420` of the `61/240` of available signal:
the remaining `≈ 5.4 %` is pure multi-prime interaction and is unreachable by
any weighting. -/
theorem ceiling_lt_variance :
    energy (structureCorrection a) (dialFootprint a univ) (dialVar a univ)
      < variance (structureCorrection a) := by
  rw [energy_eq, variance_eq]
  norm_num

end Example357

end ScaleSmoothness