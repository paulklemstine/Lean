import Mathlib
import Cryptography.BB84.ThresholdEnclosure
import Cryptography.BB84.PrivacyAmplification

/-!
# Finite-Key BB84 Bounds on a Certified Asymptotic Core

The catalog files `Cryptography.BB84.ThresholdEnclosure` and
`Cryptography.BB84.PrivacyAmplification` provide, respectively,

* an *integer certificate* calculus for the asymptotic Shor–Preskill key rate
  `r(Q) = log 2 - 2 · binEntropy Q` at rational `Q` (no floating point anywhere), and
* the *leftover-hash* Cauchy–Schwarz bound turning a collision-probability bound
  into a statistical distance to uniform.

This file glues the two into a genuine **finite-key** statement:

`measured QBER Q = 11 %  ⟹  ε-secure extractable length ≥ n·ρ − C·√(n·ln(1/ε)) − 2·log₂(1/ε) − 1`

with the *explicit rational* `ρ = 1/6000` bits per sifted bit, certified from an
823-digit integer inequality by way of a **Padé `[1/1]` logarithm bound**
`log x ≥ 2(x−1)/(x+1)`, which is strictly sharper than the naive `log x ≥ 1 − 1/x`
used in the catalog and is what makes the clean rational constant `1/6000` provable.

The last section extracts the deployment moral: with the standard
`C·√(n ln(1/ε))` statistical correction (`C = 10`, `ε = 2⁻⁵⁰`) the certified
finite-key length is **zero for every `n ≤ 10¹¹`**, while the asymptotic rate is
positive.  Only past `n ≥ 10¹²` does one recover half of the asymptotic rate.
So the asymptotic threshold is the wrong figure of merit for deployment.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): (H1) Every integer certificate `(den+num)·D ≤ den·N`
  for the rational QBER `a/(a+c)` upgrades from a *sign* statement to an explicit
  rational lower bound `r ≥ 2·num/((a+c)(2·den+num))` nats, via the Padé approximant
  of the logarithm.  (H2) That rational core survives contact with the finite-key
  machinery: leftover hashing costs exactly `2log₂(1/ε)` bits and the AEP costs
  `C√(n ln(1/ε))`.  (H3) The resulting break-even `n` is astronomically large at
  `Q = 11 %`, so the asymptotic threshold misdescribes deployment.
EXPERIMENT (Experimenter): Exact rational arithmetic on `N/D = 2^100·11^22·89^178/100^200`
  gives `N/D = 1.011718805686…`.  Naive `1 − 1/x` yields `r ≥ 1.15647·10⁻⁴` nats;
  the Padé bound `2(x−1)/(x+1)` yields `r ≥ 1.16319·10⁻⁴` nats (true value
  `1.16507·10⁻⁴`), i.e. the Padé bound recovers 94 % of the deficit of the naive
  bound.  In bits: `1.67811·10⁻⁴ > 1/6000 = 1.66667·10⁻⁴`; the naive bound gives
  `1.66843·10⁻⁴`, which survives `1/6000` only by 0.1 % — too tight to be robust,
  hence Padé.  Break-even: `n ρ² = C² ln(1/ε)` at `n ≈ 1.25·10¹¹`.
ANALYSIS (Analyst): The certificate → rate pipeline factors cleanly as
  (integer inequality) → (bound on the rational `N/D`) → (Padé) → (rational rate).
  Only the last step is analytic, and it is a one-dimensional monotonicity argument
  (`d/dx [log x − 2 + 4/(x+1)] = (x−1)²/(x(x+1)²) ≥ 0`).  The finite-key overhead is
  purely order-theoretic: `⌊·⌋₊` plus the leftover-hash exponential bound.
CRITIQUE (Critic): A real defect was found in the attached catalog file: the
  hypothesis `∑ p² ≤ 2^{-k}` of `privacyAmplification_exp_bound`, for `p` on `2^ℓ`
  points, is *unsatisfiable* whenever `ℓ < k` — precisely the advertised secure
  regime (`catalog_collision_hypothesis_vacuous` proves this).  We repair it by the
  universal-hashing collision bound `2^{-ℓ} + 2^{-k}`, which is satisfiable
  (`leftoverHash_hypothesis_satisfiable`) and yields the identical conclusion,
  since `2^ℓ(2^{-ℓ}+2^{-k}) − 1 = 2^{ℓ-k}` exactly.  Beyond that, the min-entropy
  accounting `Hmin ≥ n ρ − C√(n ln(1/ε))` is a
  *hypothesis* (`hAEP`), not a theorem: it is the physical input (asymptotic
  equipartition / statistical fluctuation analysis) that no purely arithmetic
  argument can supply.  It is carried explicitly in every statement, so nothing is
  smuggled in.  Degenerate cases: `n = 0` makes `finiteKeyBits = 0` (not negative),
  which is why the vanishing theorem is stated as `≤ 0`; `ε > 1` would make
  `log(1/ε) < 0` and the square root vacuous, so `ε ≤ 1` is required where used.
SYNTHESIS (PI): `log_pade_lower` (analytic core) + `secureKeyRate_ge_of_cert_pade`
  (certificate → rational rate) + `leftoverHash_eps_close` (catalog PA bound → ε) +
  `finiteKey_extraction` (main finite-key theorem) + the `Q = 11 %` parameter table.
-/

open Real Set Finset

noncomputable section

namespace BB84
namespace FiniteKey

/-! ## 1. The Padé `[1/1]` lower bound for the logarithm -/

/-- **Padé `[1/1]` lower bound.**  For `x ≥ 1`, `log x ≥ 2(x-1)/(x+1)`.
This is strictly sharper than `log x ≥ 1 - 1/x` for `x > 1`, and it is the
sharpening that turns the catalog's 823-digit integer certificate at `Q = 11 %`
into the clean rational rate `1/6000` bits per sifted bit.
The proof is the monotonicity of `f x = log x - 2 + 4/(x+1)`, whose derivative
`1/x - 4/(x+1)² = (x-1)²/(x(x+1)²)` is nonnegative. -/
theorem log_pade_lower (x : ℝ) (hx : 1 ≤ x) : 2 * (x - 1) / (x + 1) ≤ Real.log x := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le one_pos hx
  set f : ℝ → ℝ := fun t => Real.log t - 2 + 4 / (t + 1) with hf
  have hderiv : ∀ t ∈ interior (Set.Ici (1:ℝ)), HasDerivAt f (1/t - 4/(t+1)^2) t := by
    intro t ht
    rw [interior_Ici] at ht
    have ht0 : (0:ℝ) < t := lt_trans one_pos ht
    have h1 : HasDerivAt Real.log (1/t) t := by
      simpa [one_div] using Real.hasDerivAt_log (ne_of_gt ht0)
    have h2 : HasDerivAt (fun t : ℝ => (t + 1)) 1 t := (hasDerivAt_id t).add_const 1
    have h3 : HasDerivAt (fun t : ℝ => (t + 1)⁻¹) (-(1) / (t+1)^2) t :=
      h2.inv (by positivity)
    have h4 : HasDerivAt (fun t : ℝ => 4 * (t + 1)⁻¹) (4 * (-(1) / (t+1)^2)) t :=
      h3.const_mul 4
    have h5 := (h1.sub_const 2).add h4
    have heq : (1:ℝ)/t - 4/(t+1)^2 = 1/t + 4 * (-(1)/(t+1)^2) := by field_simp; ring
    rw [heq]
    have hfun : f = (fun t : ℝ => Real.log t - 2) + (fun t : ℝ => 4 * (t+1)⁻¹) := by
      funext s; simp [hf, div_eq_mul_inv]
    rw [hfun]
    exact h5
  have hmono : MonotoneOn f (Set.Ici (1:ℝ)) := by
    apply monotoneOn_of_deriv_nonneg (convex_Ici 1)
    · apply ContinuousOn.add
      · exact (Real.continuousOn_log.mono
          (by intro t ht; simp at ht ⊢; linarith)).sub continuousOn_const
      · apply ContinuousOn.div continuousOn_const (by fun_prop)
        intro t ht; simp at ht; linarith
    · intro t ht; exact (hderiv t ht).differentiableAt.differentiableWithinAt
    · intro t ht
      rw [(hderiv t ht).deriv]
      rw [interior_Ici] at ht
      have ht0 : (0:ℝ) < t := lt_trans one_pos ht
      rw [sub_nonneg, div_le_div_iff₀ (by positivity) (by positivity)]
      nlinarith [sq_nonneg (t-1)]
  have hf1 : f 1 = 0 := by simp [hf]; norm_num
  have hfx : 0 ≤ Real.log x - 2 + 4/(x+1) := by
    have h := hmono Set.self_mem_Ici (Set.mem_Ici.2 hx) hx
    rw [hf1] at h
    exact h
  rw [div_le_iff₀ (by linarith)]
  have h2 : 0 < x + 1 := by linarith
  have h3 : 0 ≤ (Real.log x - 2 + 4/(x+1)) * (x+1) := mul_nonneg hfx (le_of_lt h2)
  have h4 : (Real.log x - 2 + 4/(x+1)) * (x+1) = Real.log x * (x+1) - 2*(x+1) + 4 := by
    field_simp
  rw [h4] at h3
  linarith

/-- The Padé functional `x ↦ 2(x-1)/(x+1)` is monotone on `[1, ∞)`. -/
theorem pade_mono {y x : ℝ} (hy : 1 ≤ y) (hyx : y ≤ x) :
    2 * (y - 1) / (y + 1) ≤ 2 * (x - 1) / (x + 1) := by
  have hy0 : (0:ℝ) < y + 1 := by linarith
  have hx0 : (0:ℝ) < x + 1 := by linarith
  rw [div_le_div_iff₀ hy0 hx0]
  nlinarith

/-! ## 2. Integer certificate ⟹ explicit rational key rate -/

/-- **Certificate ⟹ explicit rational rate (Padé form).**
If the integer certificate `(den + num)·(a+c)^(2(a+c)) ≤ den·2^(a+c)·a^(2a)·c^(2c)`
holds — i.e. the rational `N/D` whose logarithm is `(a+c)·r(a/(a+c))` exceeds
`1 + num/den` — then the asymptotic BB84 key rate at the rational QBER `a/(a+c)`
admits the *explicit positive rational* lower bound

`r(a/(a+c)) ≥ 2·num / ((a+c)·(2·den + num))`  nats per sifted bit.

This is the quantitative upgrade of the catalog's sign-only criterion
`secureKeyRate_ratio_pos_iff`, and is sharper than the `1 - 1/x` bound used for
`secureKeyRate_eleven_percent_gt` (which would give `num/((a+c)(den+num))`). -/
theorem secureKeyRate_ge_of_cert_pade (a c num den : ℕ) (ha : 0 < a) (hc : 0 < c)
    (hden : 0 < den)
    (hcert : (den + num) * ((a + c) ^ (2 * (a + c)))
      ≤ den * (2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c))) :
    (2 * num : ℝ) / (((a:ℝ) + c) * (2 * den + num))
      ≤ secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) := by
  have ha' : (0:ℝ) < a := by exact_mod_cast ha
  have hc' : (0:ℝ) < c := by exact_mod_cast hc
  have hden' : (0:ℝ) < den := by exact_mod_cast hden
  have hac : (0:ℝ) < (a:ℝ) + c := by linarith
  set D : ℝ := ((((a + c) ^ (2 * (a + c)) : ℕ)) : ℝ) with hD
  set N : ℝ := (((2 ^ (a + c) * a ^ (2 * a) * c ^ (2 * c) : ℕ)) : ℝ) with hN
  have hDpos : (0:ℝ) < D := by rw [hD]; push_cast; positivity
  have hNpos : (0:ℝ) < N := by rw [hN]; push_cast; positivity
  -- the certificate, as a real inequality
  have hcert' : ((den:ℝ) + num) * D ≤ (den:ℝ) * N := by
    rw [hD, hN]; exact_mod_cast hcert
  -- hence `N / D ≥ (den + num)/den ≥ 1`
  have hx : ((den:ℝ) + num) / den ≤ N / D := by
    rw [div_le_div_iff₀ hden' hDpos]
    linarith
  have hx1 : (1:ℝ) ≤ ((den:ℝ) + num) / den := by
    rw [le_div_iff₀ hden']
    have : (0:ℝ) ≤ (num:ℝ) := Nat.cast_nonneg num
    linarith
  have hx1' : (1:ℝ) ≤ N / D := le_trans hx1 hx
  -- the exact rate identity from the catalog
  have hrate : secureKeyRate ((a : ℝ) / ((a : ℝ) + c)) = ((a:ℝ) + c)⁻¹ * Real.log (N / D) := by
    rw [hD, hN]; exact secureKeyRate_ratio_eq a c ha hc
  rw [hrate]
  -- assemble
  have hpade : 2 * (num:ℝ) / (2 * den + num) ≤ Real.log (N / D) := by
    have h1 := pade_mono hx1 hx
    have h2 := log_pade_lower (N / D) hx1'
    have h3 : 2 * (((den:ℝ) + num) / den - 1) / (((den:ℝ) + num) / den + 1)
        ≤ Real.log (N / D) := le_trans h1 h2
    have h4 : 2 * (((den:ℝ) + num) / den - 1) / (((den:ℝ) + num) / den + 1)
        = 2 * (num:ℝ) / (2 * den + num) := by
      rw [div_eq_div_iff (by positivity) (by positivity)]
      field_simp
      ring
    rwa [h4] at h3
  rw [div_le_iff₀ (by positivity)]
  calc (2 * (num:ℝ))
      = (2 * (num:ℝ) / (2 * den + num)) * (2 * den + num) := by field_simp
    _ ≤ Real.log (N / D) * (2 * den + num) := by
        apply mul_le_mul_of_nonneg_right hpade (by positivity)
    _ = ((a:ℝ) + c)⁻¹ * Real.log (N / D) * (((a:ℝ) + c) * (2 * den + num)) := by
        field_simp

/-! ## 3. The certified rational core at `Q = 11 %` -/

/-- **Explicit rational key rate at `Q = 11 %` (nats).**
`r(0.11) ≥ 117/1005850 ≈ 1.16319·10⁻⁴` nats per sifted bit, obtained by feeding the
catalog's integer certificate `cert_rate_lower` (`10⁴·N > 10117·D`, an 823-digit
comparison) into the Padé bound.  Compare the catalog's `1/10⁴` from `1 - 1/x`. -/
theorem rate_eleven_percent_ge : (117 : ℝ) / 1005850 ≤ secureKeyRate (11 / 100) := by
  have hcert : (10000 + 117) * ((11 + 89) ^ (2 * (11 + 89)))
      ≤ 10000 * (2 ^ (11 + 89) * 11 ^ (2 * 11) * 89 ^ (2 * 89)) := by
    have h := cert_rate_lower
    omega
  have h := secureKeyRate_ge_of_cert_pade 11 89 117 10000 (by norm_num) (by norm_num)
    (by norm_num) hcert
  norm_num at h
  convert h using 2

/-- **Explicit rational key rate at `Q = 11 %` (bits).**
`r(0.11)/log 2 ≥ 1/6000` bits per sifted bit.  Certified from
`rate_eleven_percent_ge` together with `log 2 < 0.6931471808`; the true value is
`1.68084·10⁻⁴`, so `1/6000 = 1.66667·10⁻⁴` is an honest rational under-estimate. -/
theorem rateBits_eleven_percent_ge :
    (1 : ℝ) / 6000 ≤ secureKeyRate (11 / 100) / Real.log 2 := by
  have hlog2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hlog2pos : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rw [div_le_div_iff₀ (by norm_num) hlog2pos]
  have h := rate_eleven_percent_ge
  nlinarith [h, hlog2]

/-! ## 4. Leftover hashing: from collision probability to ε-security -/

/-- **ε-security of privacy amplification.**

Hypothesis (`hcoll`) is exactly what 2-universal hashing delivers: the hashed
`ℓ`-bit key has collision probability at most `2^{-ℓ} + 2^{-k}` when the source
has min-entropy at least `k` bits.  If the output length obeys the leftover-hash
budget `ℓ + 2 log₂(1/ε) ≤ k`, the output is then `ε`-close to uniform.

*Catalog repair.*  The catalog's `privacyAmplification_exp_bound` assumes instead
`∑ p² ≤ 2^{-k}` for a distribution on `2^ℓ` points.  By Cauchy–Schwarz any such
distribution has `∑ p² ≥ 2^{-ℓ}`, so that hypothesis is **unsatisfiable** exactly
in the advertised secure regime `ℓ < k` — the catalog statement is true but
vacuous there.  Replacing `2^{-k}` by the universal-hashing value `2^{-ℓ}+2^{-k}`
(see `leftoverHash_hypothesis_satisfiable`) restores content while giving the same
conclusion, since `2^ℓ(2^{-ℓ}+2^{-k}) − 1 = 2^{ℓ−k}` exactly.  We therefore build
on the catalog's Cauchy–Schwarz core `statDist_le_collision` directly. -/
theorem leftoverHash_eps_close {ℓ k : ℕ} (p : Fin (2 ^ ℓ) → ℝ)
    (hsum : ∑ i, p i = 1)
    (hcoll : ∑ i, (p i) ^ 2 ≤ (2 : ℝ) ^ (-(ℓ : ℤ)) + (2 : ℝ) ^ (-(k : ℤ)))
    {eps : ℝ} (heps : 0 < eps) (hlk : (ℓ : ℝ) + 2 * Real.logb 2 (1 / eps) ≤ k) :
    ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ eps := by
  have hcs := BB84.statDist_le_collision (M := 2 ^ ℓ) (by positivity) p hsum
  have hcollapse : ((2 ^ ℓ : ℕ):ℝ) * ((2:ℝ)^(-(ℓ:ℤ)) + (2:ℝ)^(-(k:ℤ))) - 1
      = (2:ℝ)^((ℓ:ℤ) - k) := by
    have h1 : ((2 ^ ℓ : ℕ):ℝ) = (2:ℝ)^((ℓ:ℤ)) := by push_cast; rw [zpow_natCast]
    rw [h1, mul_add, ← zpow_add₀ (by norm_num : (2:ℝ) ≠ 0),
      ← zpow_add₀ (by norm_num : (2:ℝ) ≠ 0)]
    simp
    ring_nf
  have hbase : ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ Real.sqrt ((2:ℝ) ^ ((ℓ:ℤ) - k)) := by
    refine le_trans hcs (Real.sqrt_le_sqrt ?_)
    rw [← hcollapse]
    have hM : (0:ℝ) ≤ ((2 ^ ℓ : ℕ):ℝ) := by positivity
    nlinarith [mul_le_mul_of_nonneg_left hcoll hM]
  have hlog : Real.logb 2 (1 / eps) = - Real.logb 2 eps := by
    rw [one_div, Real.logb_inv]
  have hkey : (2:ℝ) ^ ((ℓ:ℤ) - k) ≤ eps ^ 2 := by
    have h1 : (2:ℝ) ^ ((ℓ:ℤ) - k) = (2:ℝ) ^ (((ℓ:ℝ) - k)) := by
      rw [← Real.rpow_intCast]; push_cast; ring_nf
    have h2 : (2:ℝ) ^ ((2:ℝ) * Real.logb 2 eps) = eps ^ 2 := by
      rw [mul_comm, Real.rpow_mul (by norm_num),
        Real.rpow_logb (by norm_num) (by norm_num) heps, Real.rpow_two]
    rw [h1, ← h2]
    apply (Real.rpow_le_rpow_left_iff (by norm_num)).2
    rw [hlog] at hlk
    linarith
  calc ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ Real.sqrt ((2:ℝ) ^ ((ℓ:ℤ) - k)) := hbase
    _ ≤ Real.sqrt (eps ^ 2) := Real.sqrt_le_sqrt hkey
    _ = eps := Real.sqrt_sq heps.le

/-- **Collision probability is at least uniform.**  Any probability-normalized
vector on `2^ℓ` points has `∑ p² ≥ 2^{-ℓ}` (Cauchy–Schwarz).  Nonnegativity of `p`
is not needed. -/
theorem collision_ge_uniform {ℓ : ℕ} (p : Fin (2 ^ ℓ) → ℝ) (hsum : ∑ i, p i = 1) :
    (2:ℝ) ^ (-(ℓ : ℤ)) ≤ ∑ i, (p i) ^ 2 := by
  have hCS : (∑ i, (1:ℝ) * p i) ^ 2 ≤ (∑ _i : Fin (2 ^ ℓ), (1:ℝ) ^ 2) * (∑ i, (p i) ^ 2) :=
    Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun _ => 1) p
  simp [hsum] at hCS
  have hcard : ((2:ℝ) ^ (ℓ:ℕ)) * (∑ i, (p i) ^ 2) ≥ 1 := by simpa using hCS
  have h2 : (0:ℝ) < (2:ℝ) ^ (ℓ:ℕ) := by positivity
  rw [zpow_neg, zpow_natCast, inv_le_iff_one_le_mul₀ h2]
  linarith [hcard]

/-- **The catalog's collision hypothesis is vacuous in the secure regime.**
For `ℓ < k` there is *no* normalized distribution on `2^ℓ` points with collision
probability `≤ 2^{-k}`; hence `privacyAmplification_exp_bound` has no instances
exactly where it is advertised to be strong.  This is why
`leftoverHash_eps_close` uses the universal-hashing form `2^{-ℓ} + 2^{-k}`. -/
theorem catalog_collision_hypothesis_vacuous {ℓ k : ℕ} (hlk : ℓ < k)
    (p : Fin (2 ^ ℓ) → ℝ) (hsum : ∑ i, p i = 1) :
    ¬ (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(k : ℤ))) := by
  intro hcoll
  have h1 := collision_ge_uniform p hsum
  have h2 : (2:ℝ) ^ (-(k : ℤ)) < (2:ℝ) ^ (-(ℓ : ℤ)) := by
    apply zpow_lt_zpow_right₀ (by norm_num)
    exact_mod_cast neg_lt_neg (by exact_mod_cast hlk)
  linarith

/-- **The repaired hypothesis is satisfiable.**  The uniform distribution on the
`ℓ`-bit output meets the universal-hashing collision bound `2^{-ℓ} + 2^{-k}`, so
`leftoverHash_eps_close` has instances for every `ℓ, k`. -/
theorem leftoverHash_hypothesis_satisfiable (ℓ k : ℕ) :
    (∑ _i : Fin (2 ^ ℓ), ((2 ^ ℓ : ℕ):ℝ)⁻¹) = 1 ∧
      (∑ _i : Fin (2 ^ ℓ), (((2 ^ ℓ : ℕ):ℝ)⁻¹) ^ 2)
        ≤ (2:ℝ) ^ (-(ℓ : ℤ)) + (2:ℝ) ^ (-(k : ℤ)) := by
  have hpos : (0:ℝ) < ((2 ^ ℓ : ℕ):ℝ) := by positivity
  have hcast : ((2 ^ ℓ : ℕ):ℝ) = (2:ℝ) ^ (ℓ:ℕ) := by push_cast; ring
  constructor
  · rw [Finset.sum_const]
    simp [Finset.card_univ]
  · rw [Finset.sum_const]
    simp [Finset.card_univ, hcast]
    have h2 : (0:ℝ) < (2:ℝ) ^ (ℓ:ℕ) := by positivity
    have h3 : ((2:ℝ) ^ (ℓ:ℕ)) * (((2:ℝ) ^ (ℓ:ℕ)) ^ 2)⁻¹ = ((2:ℝ) ^ (ℓ:ℕ))⁻¹ := by
      field_simp
    have h4 : (0:ℝ) < ((2:ℝ) ^ (k:ℕ))⁻¹ := by positivity
    rw [h3]
    linarith

/-! ## 5. The finite-key length functional -/

/-- **Finite-key length functional (bits).**  The standard finite-key accounting:
`n` sifted bits at an asymptotic rate of `rho` bits each, minus the statistical
(AEP / fluctuation) correction `C·√(n · ln(1/ε))`.  All parameters `rho, C` are
*rational*: no floating point enters the chain. -/
def finiteKeyBits (rho C : ℚ) (n : ℕ) (eps : ℝ) : ℝ :=
  (n : ℝ) * (rho : ℝ) - (C : ℝ) * Real.sqrt ((n : ℝ) * Real.log (1 / eps))

/-- **Extractable length after privacy amplification (bits).**  The leftover-hash
lemma charges an additional `2 log₂(1/ε)` bits for ε-security. -/
def extractableBits (rho C : ℚ) (n : ℕ) (eps : ℝ) : ℝ :=
  finiteKeyBits rho C n eps - 2 * Real.logb 2 (1 / eps)

/-- Helper: `C·√x ≤ y` from the squared inequality. -/
theorem mul_sqrt_le_of_sq {C x y : ℝ} (hC : 0 ≤ C) (hy : 0 ≤ y) (h : C ^ 2 * x ≤ y ^ 2) :
    C * Real.sqrt x ≤ y := by
  have hrw : C * Real.sqrt x = Real.sqrt (C ^ 2 * x) := by
    rw [Real.sqrt_mul (sq_nonneg C), Real.sqrt_sq hC]
  rw [hrw]
  calc Real.sqrt (C ^ 2 * x) ≤ Real.sqrt (y ^ 2) := Real.sqrt_le_sqrt h
    _ = y := Real.sqrt_sq hy

/-- Helper: `y < C·√x` from the strict squared inequality. -/
theorem lt_mul_sqrt_of_sq {C x y : ℝ} (hC : 0 ≤ C) (hy : 0 ≤ y) (h : y ^ 2 < C ^ 2 * x) :
    y < C * Real.sqrt x := by
  have hrw : C * Real.sqrt x = Real.sqrt (C ^ 2 * x) := by
    rw [Real.sqrt_mul (sq_nonneg C), Real.sqrt_sq hC]
  rw [hrw]
  calc y = Real.sqrt (y ^ 2) := (Real.sqrt_sq hy).symm
    _ < Real.sqrt (C ^ 2 * x) := by
        apply (Real.sqrt_lt_sqrt (sq_nonneg y)) h

/-- **Sign criterion for the finite-key length.**  For `n ≥ 1` the finite-key
length is strictly negative exactly when `n·rho² < C²·ln(1/ε)`: the statistical
correction dominates precisely below the break-even sample size `(C/rho)²·ln(1/ε)`. -/
theorem finiteKeyBits_neg_iff {rho C : ℚ} (hrho : 0 < rho) (hC : 0 ≤ C) {n : ℕ}
    (hn : 1 ≤ n) {eps : ℝ} :
    finiteKeyBits rho C n eps < 0 ↔ (n : ℝ) * (rho : ℝ) ^ 2 < (C : ℝ) ^ 2 * Real.log (1 / eps) := by
  have hn' : (1:ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
  have hn0 : (0:ℝ) < n := by linarith
  have hrho' : (0:ℝ) < (rho : ℝ) := by exact_mod_cast hrho
  have hC' : (0:ℝ) ≤ (C : ℝ) := by exact_mod_cast hC
  unfold finiteKeyBits
  constructor
  · intro h
    by_contra hcon
    push_neg at hcon
    have hle : (C:ℝ) * Real.sqrt ((n:ℝ) * Real.log (1 / eps)) ≤ (n:ℝ) * (rho:ℝ) := by
      apply mul_sqrt_le_of_sq hC' (by positivity)
      nlinarith [hcon]
    linarith
  · intro h
    have : (n:ℝ) * (rho:ℝ) < (C:ℝ) * Real.sqrt ((n:ℝ) * Real.log (1 / eps)) := by
      apply lt_mul_sqrt_of_sq hC' (by positivity)
      nlinarith [h]
    linarith

/-! ## 6. The main finite-key extraction theorem -/

/-- **Finite-key extraction (general form).**
Given
* an explicit rational asymptotic rate `rho` (bits/sifted bit) and a statistical
  correction constant `C`,
* the *entropy accounting hypothesis* `hAEP`: the adversary's min-entropy `k`
  (in bits) about the reconciled raw key is at least `n·rho − C√(n ln(1/ε))`
  (this is the physical AEP / fluctuation input; it is never assumed silently),
* nonnegativity of the resulting budget,

there is an output length `ℓ` at least `n·rho − C√(n ln(1/ε)) − 2log₂(1/ε) − 1`
such that *every* adversary distribution on the `ℓ`-bit key with collision
probability at most `2^{-k}` is `ε`-close to uniform.  In short:

`extractable ε-secure length ≥ n·rho − C·√(n·ln(1/ε)) − 2·log₂(1/ε) − 1`. -/
theorem finiteKey_extraction (rho C : ℚ) (n k : ℕ) {eps : ℝ} (heps : 0 < eps)
    (hAEP : finiteKeyBits rho C n eps ≤ (k : ℝ))
    (hnn : 0 ≤ extractableBits rho C n eps) :
    ∃ ℓ : ℕ, extractableBits rho C n eps - 1 ≤ (ℓ : ℝ) ∧
      ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) → (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
        ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ eps := by
  refine ⟨⌊extractableBits rho C n eps⌋₊, ?_, ?_⟩
  · have h := Nat.lt_floor_add_one (extractableBits rho C n eps)
    linarith
  · intro p hsum hcoll
    refine leftoverHash_eps_close p hsum hcoll heps ?_
    have h1 : (⌊extractableBits rho C n eps⌋₊ : ℝ) ≤ extractableBits rho C n eps :=
      Nat.floor_le hnn
    have h2 : extractableBits rho C n eps + 2 * Real.logb 2 (1 / eps)
        = finiteKeyBits rho C n eps := by
      unfold extractableBits; ring
    linarith

/-! ## 7. Instantiation at the measured QBER `Q = 11 %` -/

/-- The certified finite-key length at `Q = 11 %` never exceeds the asymptotic
Shor–Preskill budget `n·r(0.11)/log 2`: the rational core `1/6000` really is a
*lower* bound on the asymptotic rate, and the statistical correction only subtracts. -/
theorem finiteKeyBits_le_asymptotic (C : ℚ) (hC : 0 ≤ C) (n : ℕ) {eps : ℝ} :
    finiteKeyBits (1 / 6000) C n eps ≤ (n : ℝ) * (secureKeyRate (11 / 100) / Real.log 2) := by
  have hC' : (0:ℝ) ≤ (C : ℝ) := by exact_mod_cast hC
  have hsqrt : 0 ≤ Real.sqrt ((n:ℝ) * Real.log (1 / eps)) := Real.sqrt_nonneg _
  have hmain : (n:ℝ) * ((1:ℝ)/6000) ≤ (n : ℝ) * (secureKeyRate (11 / 100) / Real.log 2) := by
    apply mul_le_mul_of_nonneg_left rateBits_eleven_percent_ge (Nat.cast_nonneg n)
  unfold finiteKeyBits
  have hq : (((1 : ℚ) / 6000 : ℚ) : ℝ) = (1:ℝ) / 6000 := by norm_num
  rw [hq]
  nlinarith [mul_nonneg hC' hsqrt]

/-- **Finite-key BB84 at `Q = 11 %` (main instantiated theorem).**
At a measured QBER of exactly `11 %` — certified below threshold by the catalog's
823-digit integer certificate — with statistical correction constant `C ≥ 0` and
security parameter `ε ∈ (0,1]`, any min-entropy budget `k` compatible with the
AEP accounting yields an `ε`-secure extractable key of length at least

`n/6000 − C·√(n·ln(1/ε)) − 2·log₂(1/ε) − 1`  bits. -/
theorem bb84_finiteKey_eleven_percent (C : ℚ) (n k : ℕ) {eps : ℝ} (heps : 0 < eps)
    (hAEP : finiteKeyBits (1 / 6000) C n eps ≤ (k : ℝ))
    (hnn : 0 ≤ extractableBits (1 / 6000) C n eps) :
    ∃ ℓ : ℕ,
      (n : ℝ) / 6000 - (C : ℝ) * Real.sqrt ((n:ℝ) * Real.log (1 / eps))
          - 2 * Real.logb 2 (1 / eps) - 1 ≤ (ℓ : ℝ) ∧
      ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) → (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
        ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ eps := by
  obtain ⟨ℓ, hℓ, hsec⟩ := finiteKey_extraction (1 / 6000) C n k heps hAEP hnn
  refine ⟨ℓ, ?_, hsec⟩
  have hq : (((1 : ℚ) / 6000 : ℚ) : ℝ) = (1:ℝ) / 6000 := by norm_num
  unfold extractableBits finiteKeyBits at hℓ
  rw [hq] at hℓ
  have : (n:ℝ) * ((1:ℝ)/6000) = (n:ℝ)/6000 := by ring
  linarith [hℓ, this.symm.le, this.le]

/-! ## 8. Parameter table: `ε = 2⁻⁵⁰`, `C = 10` -/

/-- `ln(1/2⁻⁵⁰) = 50 log 2`. -/
theorem log_one_div_eps50 : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := by
  have h : (1:ℝ) / ((2:ℝ) ^ (-50 : ℤ)) = (2:ℝ) ^ (50:ℕ) := by
    rw [zpow_neg]
    norm_num
  rw [h, Real.log_pow]
  norm_num

/-- `log₂(1/2⁻⁵⁰) = 50`. -/
theorem logb_one_div_eps50 : Real.logb 2 (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 := by
  have h : (1:ℝ) / ((2:ℝ) ^ (-50 : ℤ)) = (2:ℝ) ^ (50:ℕ) := by
    rw [zpow_neg]
    norm_num
  rw [h, Real.logb_pow]
  norm_num [Real.logb_self_eq_one]

theorem log_two_bounds : 0.693 < Real.log 2 ∧ Real.log 2 < 0.694 :=
  ⟨lt_trans (by norm_num) Real.log_two_gt_d9, lt_trans Real.log_two_lt_d9 (by norm_num)⟩

/-- **The statistical correction dominates at realistic block sizes.**
With `C = 10` and `ε = 2⁻⁵⁰`, the certified finite-key length at `Q = 11 %` is
non-positive for *every* block size `n ≤ 10¹¹` — even though the asymptotic key
rate at `11 %` is certified strictly positive.  The asymptotic threshold is
therefore the wrong figure of merit for deployment. -/
theorem finiteKey_nonpos_below_1e11 (n : ℕ) (hn : n ≤ 10 ^ 11) :
    finiteKeyBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ 0 := by
  have hL : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := log_one_div_eps50
  obtain ⟨hlo, hhi⟩ := log_two_bounds
  rcases Nat.eq_zero_or_pos n with h0 | hpos
  · subst h0
    unfold finiteKeyBits
    norm_num
  · have hn' : (n : ℝ) ≤ 10 ^ 11 := by exact_mod_cast hn
    have hkey : (n : ℝ) * (((1:ℚ)/6000 : ℚ) : ℝ) ^ 2
        < ((10:ℚ) : ℝ) ^ 2 * Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) := by
      rw [hL]
      have hq : (((1 : ℚ) / 6000 : ℚ) : ℝ) = (1:ℝ) / 6000 := by norm_num
      rw [hq]
      have : (n:ℝ) * ((1:ℝ)/6000) ^ 2 ≤ 10 ^ 11 * ((1:ℝ)/6000) ^ 2 := by
        apply mul_le_mul_of_nonneg_right hn' (by positivity)
      have h2 : ((10:ℚ):ℝ) ^ 2 * (50 * Real.log 2) > 3465 := by
        push_cast
        nlinarith [hlo]
      have h3 : (10:ℝ) ^ 11 * ((1:ℝ)/6000) ^ 2 < 3465 := by norm_num
      linarith
    exact le_of_lt ((finiteKeyBits_neg_iff (by norm_num) (by norm_num) hpos).2 hkey)

/-- **Above break-even the certified rate recovers.**  For block sizes
`n ≥ 10¹²` the finite-key length at `Q = 11 %` (with `C = 10`, `ε = 2⁻⁵⁰`) is at
least *half* the asymptotic budget: `n/12000` bits. -/
theorem finiteKey_half_rate_above_1e12 (n : ℕ) (hn : 10 ^ 12 ≤ n) :
    (n : ℝ) / 12000 ≤ finiteKeyBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) := by
  have hL : Real.log (1 / ((2:ℝ) ^ (-50 : ℤ))) = 50 * Real.log 2 := log_one_div_eps50
  obtain ⟨hlo, hhi⟩ := log_two_bounds
  have hn' : (10:ℝ) ^ 12 ≤ (n : ℝ) := by exact_mod_cast hn
  have hn0 : (0:ℝ) < (n:ℝ) := by nlinarith
  unfold finiteKeyBits
  have hq : (((1 : ℚ) / 6000 : ℚ) : ℝ) = (1:ℝ) / 6000 := by norm_num
  have hq10 : (((10 : ℚ) : ℚ) : ℝ) = (10:ℝ) := by norm_num
  rw [hq, hq10, hL]
  have hcorr : (10:ℝ) * Real.sqrt ((n:ℝ) * (50 * Real.log 2)) ≤ (n:ℝ) / 12000 := by
    apply mul_sqrt_le_of_sq (by norm_num) (by positivity)
    have h1 : (10:ℝ) ^ 2 * ((n:ℝ) * (50 * Real.log 2)) ≤ 100 * ((n:ℝ) * (50 * 0.694)) := by
      nlinarith [hhi, hn0]
    have h2 : 100 * ((n:ℝ) * (50 * 0.694)) ≤ ((n:ℝ)/12000) ^ 2 := by
      have hsq : (10:ℝ) ^ 12 * (n:ℝ) ≤ (n:ℝ) * (n:ℝ) :=
        mul_le_mul_of_nonneg_right hn' hn0.le
      have h3 : (3470:ℝ) * (n:ℝ) ≤ (n:ℝ) ^ 2 / 144000000 := by nlinarith [hsq]
      nlinarith [h3]
    linarith
  linarith

/-- **Certified finite-key parameter table at `Q = 11 %`** (`C = 10`, `ε = 2⁻⁵⁰`).
For every block size `n ≥ 10¹²` there is an `ε`-secure extractable key of length at
least `n/12000 − 101` bits, valid for any min-entropy budget `k` meeting the AEP
accounting.  E.g. `n = 10¹²` gives ≥ 83 333 232 bits; `n = 10¹⁴` gives
≥ 8 333 333 232 bits.  Below `n = 10¹¹` (previous theorem) the guarantee is empty. -/
theorem bb84_finiteKey_table (n k : ℕ) (hn : 10 ^ 12 ≤ n)
    (hAEP : finiteKeyBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ (k : ℝ)) :
    ∃ ℓ : ℕ, (n : ℝ) / 12000 - 101 ≤ (ℓ : ℝ) ∧
      ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) → (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
        ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ (2:ℝ) ^ (-50 : ℤ) := by
  have hn' : (10:ℝ) ^ 12 ≤ (n : ℝ) := by exact_mod_cast hn
  have hhalf := finiteKey_half_rate_above_1e12 n hn
  have hlogb := logb_one_div_eps50
  have hnn : 0 ≤ extractableBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) := by
    unfold extractableBits
    rw [hlogb]
    nlinarith [hhalf, hn']
  obtain ⟨ℓ, hℓ, hsec⟩ :=
    finiteKey_extraction (1 / 6000) 10 n k (by positivity) hAEP hnn
  refine ⟨ℓ, ?_, hsec⟩
  unfold extractableBits at hℓ
  rw [hlogb] at hℓ
  linarith

/-! ## 9. Grand summary -/

/-- **Summary: end-to-end certified finite-key statement at `Q = 11 %`.**

1. The asymptotic rate at `11 %` QBER is at least the explicit rational
   `1/6000` bits per sifted bit (certified from an integer inequality, via Padé).
2. With `C = 10`, `ε = 2⁻⁵⁰`, the finite-key length is non-positive for all
   `n ≤ 10¹¹`.
3. For `n ≥ 10¹²` an `ε`-secure key of at least `n/12000 − 101` bits is extractable
   (given the AEP entropy accounting).

Together: the asymptotic threshold at `11 %` is genuinely below threshold, yet
provides *no* key at any realistic block size below `10¹¹` — the finite-key
correction, not the threshold, governs deployment. -/
theorem bb84_finiteKey_summary :
    ((1 : ℝ) / 6000 ≤ secureKeyRate (11 / 100) / Real.log 2) ∧
    (∀ n : ℕ, n ≤ 10 ^ 11 → finiteKeyBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ 0) ∧
    (∀ n k : ℕ, 10 ^ 12 ≤ n →
      finiteKeyBits (1 / 6000) 10 n ((2:ℝ) ^ (-50 : ℤ)) ≤ (k : ℝ) →
      ∃ ℓ : ℕ, (n : ℝ) / 12000 - 101 ≤ (ℓ : ℝ) ∧
        ∀ p : Fin (2 ^ ℓ) → ℝ, (∑ i, p i = 1) → (∑ i, (p i) ^ 2 ≤ (2:ℝ) ^ (-(ℓ:ℤ)) + (2:ℝ) ^ (-(k:ℤ))) →
          ∑ i, |p i - ((2 ^ ℓ : ℕ) : ℝ)⁻¹| ≤ (2:ℝ) ^ (-50 : ℤ)) :=
  ⟨rateBits_eleven_percent_ge, finiteKey_nonpos_below_1e11, bb84_finiteKey_table⟩

end FiniteKey
end BB84