import Catalog.NumberTheory.QuadraticDialIndependence

/-!
# Why the per-`N` clustering dies at large `u`

The experiment of round-73 #4 (exp 562) left one phenomenon unexplained: the
per-`N` overdispersion of the smoothness rate is `D = 1.61 [1.50,1.73]` at the
bin `u ≈ 6` but `≈ 1.00` by the bins `u ≈ 7, 8`.  The exact results of
`Catalog.NumberTheory.ScaleSmoothnessDispersion` show that the *arithmetic* source
of the clustering — the structure correction `C(N)` — is completely
`u`-independent: its mean is exactly `1` and its variance is exactly
`dispersionBound a − 1` for every family of odd primes, with no reference to `u`
at all.  So the death of the clustering cannot be an arithmetic effect.

This file proves it is a *counting* effect.  In any mixture model in which the
number of smooth values found for a given `N` has conditional mean `λ·C(N)` and
conditional variance `λ·C(N)·(1 − q·C(N))` (the mean and variance of a count of
`n` independent trials of success probability `q·C(N)`, with `λ = n q`), the
dispersion index obeys the exact identity

  `Var = Mean · (1 + λ·(E[C²] − 1) − q·E[C²])`.

The arithmetic enters only through `E[C²] = dispersionBound a`, which is bounded
by `2`; the *observable* excess dispersion is proportional to the event rate `λ`.
At `u ≈ 6` the experiment had `λ` of order one and saw `D ≈ 1.6`; at `u ≈ 8` it
had `λ ≈ 18/4000 ≈ 0.005` and must see `D ≈ 1`, whatever the arithmetic.

## Main results

* `law_of_total_variance` — exact finite law of total variance for a mixture of
  finitely supported conditional distributions.
* `mixVar_eq` — the dispersion identity above.
* `dispersion_index_sub_one_abs_le` — `|Var/Mean − 1| ≤ λ (E[C²] − 1) + q E[C²]`.
* `smoothness_dispersion_identity` — the identity with `E[C²]` identified as the
  arithmetic quantity `dispersionBound a` for the structure correction of
  `x² − N`.
* `smoothness_dispersion_decays` — the payoff: for any family of distinct odd
  primes, `|Var − Mean| ≤ Mean · (λ + 2q)`.  The clustering is bounded by the
  event rate, uniformly in the smoothness bound, so it necessarily disappears
  where events become rare.
-/

namespace ScaleSmoothness

open Finset

/-! ### A finite law of total variance -/

variable {Ω : Type*} [Fintype Ω] {K : Type*} [Fintype K]

/-- Conditional mean of the value `val` under the conditional distribution `P ω`. -/
def condMean (P : Ω → K → ℚ) (val : K → ℚ) (ω : Ω) : ℚ := ∑ k, P ω k * val k

/-- Conditional variance of `val` under `P ω`. -/
def condVar (P : Ω → K → ℚ) (val : K → ℚ) (ω : Ω) : ℚ :=
  ∑ k, P ω k * (val k - condMean P val ω) ^ 2

/-- Mean of the mixture with weights `w`. -/
def mixMean (w : Ω → ℚ) (P : Ω → K → ℚ) (val : K → ℚ) : ℚ :=
  ∑ ω, w ω * condMean P val ω

/-- Variance of the mixture with weights `w`. -/
def mixVar (w : Ω → ℚ) (P : Ω → K → ℚ) (val : K → ℚ) : ℚ :=
  ∑ ω, w ω * ∑ k, P ω k * (val k - mixMean w P val) ^ 2

/-- **Law of total variance** (finite, exact): the variance of a mixture is the
average conditional variance plus the variance of the conditional means. -/
theorem law_of_total_variance (w : Ω → ℚ) (P : Ω → K → ℚ) (val : K → ℚ)
    (hP : ∀ ω, ∑ k, P ω k = 1) :
    mixVar w P val =
      (∑ ω, w ω * condVar P val ω) +
        ∑ ω, w ω * (condMean P val ω - mixMean w P val) ^ 2 := by
  rw [mixVar, ← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl fun ω _ => ?_
  set m := condMean P val ω with hm
  set E := mixMean w P val with hE
  have hzero : ∑ k, P ω k * (val k - m) = 0 := by
    have : ∑ k, P ω k * (val k - m) = (∑ k, P ω k * val k) - m * ∑ k, P ω k := by
      rw [Finset.mul_sum, ← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun k _ => by ring
    rw [this, hP ω, hm, condMean]
    ring
  have hexp : ∑ k, P ω k * (val k - E) ^ 2
      = (∑ k, P ω k * (val k - m) ^ 2) + 2 * (m - E) * (∑ k, P ω k * (val k - m))
        + (m - E) ^ 2 * ∑ k, P ω k := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun k _ => by ring
  rw [hexp, hzero, hP ω, condVar]
  ring

/-! ### The dispersion identity for a mixed count model -/

/-- **Dispersion identity.**  If the conditional mean is `λ C(ω)` and the
conditional variance is `λ C(ω) (1 − q C(ω))` — the moments of a count of `n`
independent trials of success probability `q C(ω)`, with `λ = n q` — and the
mixing law has `E[C] = 1`, then the mixture mean is `λ` and

  `Var = λ · (1 + λ (E[C²] − 1) − q E[C²])`. -/
theorem mixVar_eq (w : Ω → ℚ) (P : Ω → K → ℚ) (val : K → ℚ) (C : Ω → ℚ) (lam q : ℚ)
    (hP : ∀ ω, ∑ k, P ω k = 1) (hw : ∑ ω, w ω = 1)
    (hC : ∑ ω, w ω * C ω = 1)
    (hmean : ∀ ω, condMean P val ω = lam * C ω)
    (hvar : ∀ ω, condVar P val ω = lam * C ω * (1 - q * C ω)) :
    mixMean w P val = lam ∧
      mixVar w P val = lam * (1 + lam * ((∑ ω, w ω * (C ω) ^ 2) - 1)
        - q * ∑ ω, w ω * (C ω) ^ 2) := by
  have hM : mixMean w P val = lam := by
    rw [mixMean]
    calc ∑ ω, w ω * condMean P val ω = ∑ ω, lam * (w ω * C ω) :=
          Finset.sum_congr rfl fun ω _ => by rw [hmean ω]; ring
      _ = lam * ∑ ω, w ω * C ω := by rw [Finset.mul_sum]
      _ = lam := by rw [hC, mul_one]
  refine ⟨hM, ?_⟩
  rw [law_of_total_variance w P val hP, hM]
  have h1 : ∑ ω, w ω * condVar P val ω
      = lam * (∑ ω, w ω * C ω) - lam * q * ∑ ω, w ω * (C ω) ^ 2 := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun ω _ => by rw [hvar ω]; ring
  have h2 : ∑ ω, w ω * (condMean P val ω - lam) ^ 2
      = lam ^ 2 * (∑ ω, w ω * (C ω) ^ 2) - (lam ^ 2 * 2) * (∑ ω, w ω * C ω)
        + lam ^ 2 * (∑ ω, w ω) := by
    rw [Finset.mul_sum, Finset.mul_sum, Finset.mul_sum, ← Finset.sum_sub_distrib,
      ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun ω _ => by rw [hmean ω]; ring
  rw [h1, h2, hC, hw]
  ring

/-- **Excess dispersion is bounded by the event rate.**  With `S₂ = E[C²]`,
`|Var − λ·Mean-ratio| ≤ ...`: precisely, `|Var − Mean| ≤ Mean · (λ (S₂ − 1) + q S₂)`
whenever `Mean = λ ≥ 0`. -/
theorem dispersion_index_sub_one_abs_le (w : Ω → ℚ) (P : Ω → K → ℚ) (val : K → ℚ)
    (C : Ω → ℚ) (lam q : ℚ) (hlam : 0 ≤ lam)
    (hP : ∀ ω, ∑ k, P ω k = 1) (hw : ∑ ω, w ω = 1) (hC : ∑ ω, w ω * C ω = 1)
    (hmean : ∀ ω, condMean P val ω = lam * C ω)
    (hvar : ∀ ω, condVar P val ω = lam * C ω * (1 - q * C ω))
    (S₂ : ℚ) (hS₂ : ∑ ω, w ω * (C ω) ^ 2 = S₂) (hq : 0 ≤ q) (hS₂1 : 1 ≤ S₂) :
    |mixVar w P val - mixMean w P val| ≤ lam * (lam * (S₂ - 1) + q * S₂) := by
  obtain ⟨hM, hV⟩ := mixVar_eq w P val C lam q hP hw hC hmean hvar
  rw [hM, hV, hS₂]
  have hdiff : lam * (1 + lam * (S₂ - 1) - q * S₂) - lam
      = lam * (lam * (S₂ - 1) - q * S₂) := by ring
  rw [hdiff, abs_mul, abs_of_nonneg hlam]
  have hbound : |lam * (S₂ - 1) - q * S₂| ≤ lam * (S₂ - 1) + q * S₂ := by
    have h1 : 0 ≤ lam * (S₂ - 1) := mul_nonneg hlam (by linarith)
    have h2 : 0 ≤ q * S₂ := mul_nonneg hq (by linarith)
    rw [abs_le]
    constructor <;> linarith
  exact mul_le_mul_of_nonneg_left hbound hlam

/-! ### Specialisation to the smoothness of `x² − N` -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The uniform weights on the residue data of the prime family `a`. -/
noncomputable def uniformWeight (a : ι → ℕ) : (∀ i, ZMod (a i)) → ℚ :=
  fun _ => 1 / ∏ i, (a i : ℚ)

theorem sum_uniformWeight (a : ι → ℕ) [∀ i, Fact (a i).Prime] (hodd : ∀ i, a i ≠ 2) :
    ∑ N : (∀ i, ZMod (a i)), uniformWeight a N = 1 := by
  have hpos : (0 : ℚ) < ∏ i, (a i : ℚ) :=
    Finset.prod_pos fun i _ => by have := three_le_a a hodd i; linarith
  simp only [uniformWeight]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, card_pi_zmod a]
  field_simp

/-- Under the uniform law on residue data, the structure correction has mean `1`. -/
theorem uniform_mean_structureCorrection (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) :
    ∑ N : (∀ i, ZMod (a i)), uniformWeight a N * structureCorrection a N = 1 := by
  have hpos : (0 : ℚ) < ∏ i, (a i : ℚ) :=
    Finset.prod_pos fun i _ => by have := three_le_a a hodd i; linarith
  simp only [uniformWeight]
  simp only [one_div, ← Finset.mul_sum]
  rw [sum_structureCorrection a hodd]
  field_simp

/-- Under the uniform law, the second moment of the structure correction is exactly
the arithmetic quantity `dispersionBound a`. -/
theorem uniform_second_moment_structureCorrection (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) :
    ∑ N : (∀ i, ZMod (a i)), uniformWeight a N * (structureCorrection a N) ^ 2
      = dispersionBound a := by
  have hpos : (0 : ℚ) < ∏ i, (a i : ℚ) :=
    Finset.prod_pos fun i _ => by have := three_le_a a hodd i; linarith
  simp only [uniformWeight]
  simp only [one_div, ← Finset.mul_sum]
  rw [sum_structureCorrection_sq a hodd, prod_second_moment_eq a hodd]
  field_simp

/-- **The dispersion identity for `x² − N` smoothness counts.**  In the mixed count
model over residue data, the dispersion of the number of smooth values per `N` is
governed by the arithmetic quantity `dispersionBound a` and by the event rate
`λ` alone. -/
theorem smoothness_dispersion_identity (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) {K : Type*} [Fintype K]
    (P : (∀ i, ZMod (a i)) → K → ℚ) (val : K → ℚ) (lam q : ℚ)
    (hP : ∀ N, ∑ k, P N k = 1)
    (hmean : ∀ N, condMean P val N = lam * structureCorrection a N)
    (hvar : ∀ N, condVar P val N = lam * structureCorrection a N
      * (1 - q * structureCorrection a N)) :
    mixMean (uniformWeight a) P val = lam ∧
      mixVar (uniformWeight a) P val
        = lam * (1 + lam * (dispersionBound a - 1) - q * dispersionBound a) := by
  have h := mixVar_eq (uniformWeight a) P val (structureCorrection a) lam q hP
    (sum_uniformWeight a hodd) (uniform_mean_structureCorrection a hodd) hmean hvar
  rw [uniform_second_moment_structureCorrection a hodd] at h
  exact h

/-- **The clustering dies with the event rate.**  For any family of *distinct* odd
primes, the excess of the variance over the mean is at most `Mean·(λ + 2q)`.
Since the arithmetic factor `dispersionBound a` is capped at `2` uniformly in the
smoothness bound, an observed overdispersion can only be of size `O(λ)`: where
smooth events are rare (large `u`), the per-`N` clustering must vanish, even
though the underlying arithmetic bias is unchanged. -/
theorem smoothness_dispersion_decays (a : ι → ℕ) [∀ i, Fact (a i).Prime]
    (hodd : ∀ i, a i ≠ 2) (hinj : Function.Injective a) {K : Type*} [Fintype K]
    (P : (∀ i, ZMod (a i)) → K → ℚ) (val : K → ℚ) (lam q : ℚ)
    (hlam : 0 ≤ lam) (hq : 0 ≤ q)
    (hP : ∀ N, ∑ k, P N k = 1)
    (hmean : ∀ N, condMean P val N = lam * structureCorrection a N)
    (hvar : ∀ N, condVar P val N = lam * structureCorrection a N
      * (1 - q * structureCorrection a N)) :
    |mixVar (uniformWeight a) P val - mixMean (uniformWeight a) P val|
      ≤ lam * (lam + 2 * q) := by
  have hd2 : dispersionBound a ≤ 2 := dispersionBound_le_two a hodd hinj
  have hd1 : 1 ≤ dispersionBound a := by
    rcases isEmpty_or_nonempty ι with hι | hι
    · rw [dispersionBound]
      rw [Finset.univ_eq_empty, Finset.prod_empty]
    · obtain ⟨j⟩ := hι
      exact le_of_lt (one_lt_dispersionBound a hodd j)
  have hbase := dispersion_index_sub_one_abs_le (uniformWeight a) P val
    (structureCorrection a) lam q hlam hP (sum_uniformWeight a hodd)
    (uniform_mean_structureCorrection a hodd) hmean hvar (dispersionBound a)
    (uniform_second_moment_structureCorrection a hodd) hq hd1
  have hstep : lam * (lam * (dispersionBound a - 1) + q * dispersionBound a)
      ≤ lam * (lam + 2 * q) := by
    have h1 : lam * (dispersionBound a - 1) ≤ lam := by nlinarith
    have h2 : q * dispersionBound a ≤ 2 * q := by nlinarith
    nlinarith
  exact le_trans hbase hstep


/-! ### Non-vacuity: a single-trial Bernoulli realisation of the model -/

namespace BernoulliWitness

variable (a : ι → ℕ) [∀ i, Fact (a i).Prime] (q : ℚ)

/-- The conditional law of a single trial with success probability
`q · C(N)`. -/
def P (N : ∀ i, ZMod (a i)) : Bool → ℚ :=
  fun b => if b then q * structureCorrection a N else 1 - q * structureCorrection a N

/-- The value of a single trial: `1` on success, `0` on failure. -/
def val : Bool → ℚ := fun b => if b then 1 else 0

omit [DecidableEq ι] in
theorem P_sum (N : ∀ i, ZMod (a i)) : ∑ b, P a q N b = 1 := by
  simp [P]

omit [DecidableEq ι] in
theorem condMean_eq (N : ∀ i, ZMod (a i)) :
    condMean (P a q) val N = q * structureCorrection a N := by
  simp [condMean, P, val]

omit [DecidableEq ι] in
theorem condVar_eq (N : ∀ i, ZMod (a i)) :
    condVar (P a q) val N
      = q * structureCorrection a N * (1 - q * structureCorrection a N) := by
  simp only [condVar, condMean_eq, P, val, Fintype.sum_bool, if_pos,
    Bool.false_eq_true, if_false]
  ring

/-- The dispersion identity holds in the single-trial model, so the hypotheses of
`smoothness_dispersion_identity` are satisfiable with any rate `λ = q`. -/
theorem dispersion_identity (hodd : ∀ i, a i ≠ 2) :
    mixMean (uniformWeight a) (P a q) val = q ∧
      mixVar (uniformWeight a) (P a q) val
        = q * (1 + q * (dispersionBound a - 1) - q * dispersionBound a) :=
  smoothness_dispersion_identity a hodd (P a q) val q q (P_sum a q)
    (condMean_eq a q) (condVar_eq a q)

end BernoulliWitness

end ScaleSmoothness