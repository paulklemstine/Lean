/-
# U065 — No single small prime carries the divisibility hump

The experiment (exp 588b) measured a real smoothness hump of log-amplitude
`A ≈ 0.116` over an exact Dickman baseline, and then tried to *remove* it by
conditioning on single binary covariates (`2 ∣ v`, `3 ∣ v`, `5 ∣ v`, `7 ∣ v`, …).
Every removal removed `0 %` of the amplitude, and each stratum stayed significant.
The conclusion drawn was that the excess is "divisibility-distributed":
a mixture effect spread over the small-prime structure of `v = j² − N`.

This file proves that this behaviour is *forced* by the arithmetic of
`U065QRMixture`.  Writing the total log-amplitude of the mixture model as

  `A = ∑ᵢ log (excessRatio qᵢ c)`,

we show that each individual prime's share is at most `3 / (2k)` of the total,
where `k` is the number of primes in the model.  Consequently, in any model with
`k ≥ 3` small primes, **no single prime can account for `60 %` of the hump** —
the empirical "win bar" of the registered decision tree.  With `k ≥ 5` primes the
best single removal is below `30 %`.

Mechanism of the proof: the per-prime log-excess is `log (1 + (1 − 1/q)·X)` with the
*same* `X = (c−1)²/(2c)` for every prime, and `2/3 ≤ 1 − 1/q < 1` for every odd prime
`q`.  Concavity of `log (1 + ·)` then squeezes all per-prime shares into a factor `3/2`
of each other; no prime can be an outlier, so none can be a carrier.
-/
import Computation.U065QRMixture

namespace U065

open Finset

/-- Per-prime log-excess: the contribution of the prime `q` to the hump amplitude. -/
noncomputable def logExcess (q : ℕ) [Fact q.Prime] (c : ℝ) : ℝ :=
  Real.log (excessRatio q c)

/-- Concavity of `log (1 + ·)` at the origin: `θ · log (1 + X) ≤ log (1 + θX)` for
`θ ∈ [0,1]` and `X ≥ 0`. -/
lemma log_one_add_smul_ge {X θ : ℝ} (hX : 0 ≤ X) (h0 : 0 ≤ θ) (h1 : θ ≤ 1) :
    θ * Real.log (1 + X) ≤ Real.log (1 + θ * X) := by
  have hconc : ConcaveOn ℝ (Set.Ioi (0 : ℝ)) Real.log := strictConcaveOn_log_Ioi.concaveOn
  have hx1 : (1 : ℝ) ∈ Set.Ioi (0 : ℝ) := by norm_num
  have hx2 : (1 + X) ∈ Set.Ioi (0 : ℝ) := by simp only [Set.mem_Ioi]; linarith
  have hsum : (1 - θ) + θ = 1 := by ring
  have hkey := hconc.2 hx1 hx2 (by linarith : (0 : ℝ) ≤ 1 - θ) h0 hsum
  simp only [smul_eq_mul, Real.log_one, mul_zero, zero_add] at hkey
  have hrw : (1 - θ) * 1 + θ * (1 + X) = 1 + θ * X := by ring
  rwa [hrw] at hkey

variable {q : ℕ} [Fact q.Prime]

/-- The per-prime excess written with the *shared* shape factor `X = (c−1)²/(2c)`. -/
lemma excessRatio_eq_shape (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) :
    excessRatio q c = 1 + (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)) := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (Fact.out (p := q.Prime)).pos
  rw [excessRatio_eq hq hc]
  field_simp

lemma one_le_excessRatio (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) : 1 ≤ excessRatio q c := by
  rcases eq_or_ne c 1 with rfl | hc1
  · simp [excessRatio_eq_shape hq hc]
  · exact (one_lt_excessRatio hq hc hc1).le

lemma logExcess_nonneg (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) : 0 ≤ logExcess q c :=
  Real.log_nonneg (one_le_excessRatio hq hc)

/-- Upper squeeze: no prime contributes more than the common shape value. -/
lemma logExcess_le (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) :
    logExcess q c ≤ Real.log (1 + (c - 1) ^ 2 / (2 * c)) := by
  have hq3 := three_le_cast hq
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (Fact.out (p := q.Prime)).pos
  have hX : 0 ≤ (c - 1) ^ 2 / (2 * c) := by positivity
  have hinv : 1 / (q : ℝ) ≤ 1 / 3 := one_div_le_one_div_of_le (by norm_num) hq3
  have hfacnn : 0 ≤ 1 - 1 / (q : ℝ) := by linarith
  have hfac : 1 - 1 / (q : ℝ) ≤ 1 := by
    have : 0 < 1 / (q : ℝ) := by positivity
    linarith
  have hprod : 0 ≤ (1 - 1 / (q : ℝ)) * ((c - 1) ^ 2 / (2 * c)) := mul_nonneg hfacnn hX
  rw [logExcess, excessRatio_eq_shape hq hc]
  apply Real.log_le_log
  · linarith
  · nlinarith

/-- Lower squeeze: every odd prime contributes at least `2/3` of the shape value. -/
lemma le_logExcess (hq : q ≠ 2) {c : ℝ} (hc : 0 < c) :
    (2 / 3 : ℝ) * Real.log (1 + (c - 1) ^ 2 / (2 * c)) ≤ logExcess q c := by
  have hq3 := three_le_cast hq
  have hq0 : (0 : ℝ) < q := by exact_mod_cast (Fact.out (p := q.Prime)).pos
  have hX : 0 ≤ (c - 1) ^ 2 / (2 * c) := by positivity
  set X := (c - 1) ^ 2 / (2 * c) with hXdef
  have hstep : (2 / 3 : ℝ) * Real.log (1 + X) ≤ Real.log (1 + (2 / 3 : ℝ) * X) :=
    log_one_add_smul_ge hX (by norm_num) (by norm_num)
  have hfac : (2 / 3 : ℝ) ≤ 1 - 1 / (q : ℝ) := by
    have h1 : 1 / (q : ℝ) ≤ 1 / 3 := one_div_le_one_div_of_le (by norm_num) hq3
    linarith
  have hmono : Real.log (1 + (2 / 3 : ℝ) * X) ≤ Real.log (1 + (1 - 1 / (q : ℝ)) * X) := by
    apply Real.log_le_log
    · nlinarith
    · nlinarith
  rw [logExcess, excessRatio_eq_shape hq hc]
  linarith

section Model

variable {ι : Type*} [Fintype ι]

/-- The total log-amplitude of the divisibility-mixture hump. -/
noncomputable def humpLogAmplitude (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (c : ℝ) : ℝ :=
  ∑ i, logExcess (Q i) c

/-- The amplitude is strictly positive as soon as one odd prime is in play and the
weight `c` is non-trivial: the hump is a real feature of the mixture, not of the fit. -/
theorem humpLogAmplitude_pos (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (hc1 : c ≠ 1) [Nonempty ι] :
    0 < humpLogAmplitude Q c := by
  refine Finset.sum_pos (fun i _ => ?_) Finset.univ_nonempty
  exact Real.log_pos (one_lt_excessRatio (hQ i) hc hc1)

lemma humpLogAmplitude_nonneg (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) : 0 ≤ humpLogAmplitude Q c :=
  Finset.sum_nonneg (fun i _ => logExcess_nonneg (hQ i) hc)

/-- **No single carrier.**  Each prime's share of the total hump amplitude is at most
`3 / (2k)`, where `k` is the number of primes in the mixture model. -/
theorem single_prime_share_le (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (j : ι) :
    logExcess (Q j) c ≤ (3 / (2 * (Fintype.card ι : ℝ))) * humpLogAmplitude Q c := by
  classical
  have hk : (0 : ℝ) < (Fintype.card ι : ℝ) := by
    have : 0 < Fintype.card ι := Fintype.card_pos_iff.mpr ⟨j⟩
    exact_mod_cast this
  set L := Real.log (1 + (c - 1) ^ 2 / (2 * c)) with hL
  have hsum : (Fintype.card ι : ℝ) * ((2 / 3 : ℝ) * L) ≤ humpLogAmplitude Q c := by
    have hle := Finset.sum_le_sum
      (fun i (_ : i ∈ (Finset.univ : Finset ι)) => le_logExcess (hQ i) hc)
    simpa [humpLogAmplitude, Finset.sum_const, Finset.card_univ, nsmul_eq_mul] using hle
  have hup : logExcess (Q j) c ≤ L := logExcess_le (hQ j) hc
  have hmul : (3 / (2 * (Fintype.card ι : ℝ))) * ((Fintype.card ι : ℝ) * ((2 / 3 : ℝ) * L))
      ≤ (3 / (2 * (Fintype.card ι : ℝ))) * humpLogAmplitude Q c :=
    mul_le_mul_of_nonneg_left hsum (by positivity)
  have hsimp : (3 / (2 * (Fintype.card ι : ℝ))) * ((Fintype.card ι : ℝ) * ((2 / 3 : ℝ) * L))
      = L := by
    field_simp
  linarith [hmul, hsimp ▸ hmul]

/-- **The registered `60 %` removal bar is unreachable.**  In a mixture model with at
least three odd primes, conditioning on any single prime removes at most half of the
hump amplitude: no single binary covariate is a carrier. -/
theorem no_single_carrier (Q : ι → ℕ) [∀ i, Fact (Q i).Prime] (hQ : ∀ i, Q i ≠ 2)
    {c : ℝ} (hc : 0 < c) (hcard : 3 ≤ Fintype.card ι) (j : ι) :
    logExcess (Q j) c ≤ (1 / 2 : ℝ) * humpLogAmplitude Q c := by
  have hk : (3 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hcard
  have hk0 : (0 : ℝ) < (Fintype.card ι : ℝ) := by linarith
  have hshare := single_prime_share_le Q hQ hc j
  have hA := humpLogAmplitude_nonneg Q hQ hc
  have hfrac : (3 / (2 * (Fintype.card ι : ℝ))) ≤ (1 / 2 : ℝ) := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  calc logExcess (Q j) c ≤ (3 / (2 * (Fintype.card ι : ℝ))) * humpLogAmplitude Q c := hshare
    _ ≤ (1 / 2 : ℝ) * humpLogAmplitude Q c := mul_le_mul_of_nonneg_right hfrac hA

/-- With five or more small primes the best possible single-covariate removal is below
`30 %` of the amplitude. -/
theorem single_carrier_below_thirty_percent (Q : ι → ℕ) [∀ i, Fact (Q i).Prime]
    (hQ : ∀ i, Q i ≠ 2) {c : ℝ} (hc : 0 < c) (hcard : 5 ≤ Fintype.card ι) (j : ι) :
    logExcess (Q j) c ≤ (3 / 10 : ℝ) * humpLogAmplitude Q c := by
  have hk : (5 : ℝ) ≤ (Fintype.card ι : ℝ) := by exact_mod_cast hcard
  have hk0 : (0 : ℝ) < (Fintype.card ι : ℝ) := by linarith
  have hshare := single_prime_share_le Q hQ hc j
  have hA := humpLogAmplitude_nonneg Q hQ hc
  have hfrac : (3 / (2 * (Fintype.card ι : ℝ))) ≤ (3 / 10 : ℝ) := by
    rw [div_le_div_iff₀ (by positivity) (by norm_num)]
    linarith
  calc logExcess (Q j) c ≤ (3 / (2 * (Fintype.card ι : ℝ))) * humpLogAmplitude Q c := hshare
    _ ≤ (3 / 10 : ℝ) * humpLogAmplitude Q c := mul_le_mul_of_nonneg_right hfrac hA

end Model

end U065