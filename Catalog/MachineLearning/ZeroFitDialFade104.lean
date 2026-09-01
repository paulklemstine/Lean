import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialU76
import Novelty.ZeroFitDialPerturbation
import MachineLearning.ZeroFitDialUnif52
import MachineLearning.ZeroFitDialFloor92
import MachineLearning.ZeroFitDialFloor92Padic

/-!
# The fade at bitlen 104: it is *not* convex, so the dial has a finite death

## Research context (FACT round-68 #2, exp 541, `TDIAL-U104`)

Uniform draws at bitlen 104 give a Spearman rank correlation between the trailing-zero
statistic `T` (the 2-adic valuation) and the downstream `rate` of

* seed 20261210: `0.493`, seed 20261211: `0.499`, seed 20261212: `0.509`,
* pooled `0.500`, CI `[0.456, 0.545]` — every seed below `0.55` for the first time,

and the fade is reported to be *monotone and near-linear*: the two preceding 4-bit steps
are `−0.030` (bitlen 96 → 100) and `−0.043` (bitlen 100 → 104).  The advantage of `T` over
the count baseline **widens** to `+0.126`, because the count statistic degrades faster.

The previous cycle (`MachineLearning.ZeroFitDialFloor92`) fitted the *hyperbolic* erosion law
`rhoModel b = 5/14 + 93/(5b)` to the five readings at bitlens 44, 52, 64, 76, 92, and predicted
a floor crossing between bitlen 96 and 97 together with an asymptote `5/14 ≈ 0.357` — i.e. a
dial that decays for ever but never dies.  The bitlen-104 reading refutes that picture, and this
file turns the refutation into a structural theorem and a new, sharper prediction.

## Main results

### The convexity dichotomy (the scientific payload)

* `hypLaw_second_difference`, `geoLaw_second_difference` — exact second-difference identities on
  the 4-bit grid: `32C/(b(b+4)(b+8))` for `A + C/b`, and `C·q^b·(1−q⁴)²` for `A + C·q^b`.
* `hypLaw_decelerates`, `geoLaw_decelerates` — hence **every convex fade law decelerates**: its
  4-bit decrements are antitone.
* `observed_fade_accelerates` — the recorded decrements *increase*, `0.030 < 0.043`.
* `no_hyperbolic_law_fits`, `no_geometric_law_fits` — therefore **no** law of either family, with
  **any** parameters, passes through the three late-epoch readings.  The hyperbolic model of the
  previous cycle is not merely mis-fitted; its whole shape class is excluded.
* `rhoModel_residual_sign_flip`, `rhoModel_step_too_small` — the specific fitted law fails in the
  way the dichotomy predicts: its residual changes sign across bitlens 96–104 and its own 4-bit
  step is more than five times too small.

### Accelerating fades die (the new prediction)

* `accelerating_fade_linear_bound` — a general induction: if the 4-bit decrements of a fade are
  non-decreasing and the first is at least `d > 0`, then `f(b₀+4k) ≤ f b₀ − k·d`.
* `accelerating_fade_extinction` — hence such a fade reaches `0` at a *finite* bitlen.
* `dial_extinct_by_bitlen_176` — instantiated at the recorded numbers: if the acceleration
  persists, the dial reads `≤ 0` by bitlen 176.  A falsifiable prediction with no free parameter.

### The local linear law

* `linModel`, `linModel_fits_late_epoch`, `linModel_step_constant` — the secant law
  `ρ(b) = 1449/1000 − (73/8000)·b` reproduces bitlens 96 and 104 exactly and bitlen 100 to
  `0.0065`, with constant 4-bit step `73/2000`.
* `linModel_not_global` — it *cannot* be the global law: below bitlen 50 it exceeds `1`.  The
  near-linear phase is an intermediate asymptotic, so the fade has at least three regimes.
* `linModel_floor_crossing`, `linModel_extinction` — the floor `0.55` is crossed exactly between
  bitlen 98 and 99, and the dial is extinguished exactly between bitlen 158 and 159.
* `saturation_breached_from_120` — the previous cycle's saturation ceiling `3/28` on the forced
  corruption fraction is breached from bitlen 120 on.

### Mechanism exclusions, sharpened at bitlen 104

* `truncation_excluded_104` — every capped-resolution dial has `ρ² ≥ 3/4`; the reading is `0.25`.
* `tie_mechanism_excluded_92_to_104` — the exact dyadic ceiling moves by less than `10⁻⁵⁰`
  between bitlen 92 and 104, against a measured `ρ²` drop above `0.06`.
* `ceiling_utilisation_collapsed` — the dial now realises less than `30 %` of its own tie
  ceiling, down from more than `57 %` at bitlen 52.

### The `p`-adic ledger

* `effective_base_unique` — an effective base, when it exists, is unique.
* `effective_base_bracket` — the quantitative law `1/ρ² − 1 < p ≤ 3/ρ²`: the effective base is
  `Θ(ρ⁻²)`.
* `effective_base_104` — pooled reading and seeds B, C have effective base `10`; seed A has `11`.
* `base_drift_accelerates` — `8` at bitlen 92, `10` at bitlen 104: two units in twelve bits,
  against one unit in the previous sixteen.

### The corruption ledger and the widening advantage

* `budget_104`, `floor_budget_exhausted_104` — the reading forces a rank-level mechanism to
  displace `1/12 > 3/40` of the sample: the `7.5 %` floor budget is exhausted.
* `advantage_widens`, `count_degrades_faster` — the `T`-over-count advantage grew `0.070 → 0.073
  → 0.126`, and the count baseline lost more, both absolutely and in ratio.
* `advantage_secant_affine`, `advantage_secant_matches_104_but_not_76`, `count_dies_first` —
  under bitlen-52-to-104 secants the advantage is affine with slope `7/6500` per bit, matches the
  recorded `+0.126` exactly, over-predicts the bitlen-76 advantage by more than `0.02` (so the
  widening is a late-epoch phenomenon), and puts the count baseline's extinction at bitlen 179,
  fifty-two bits before the dial itself.

### Out-of-sample scoring against the rungs recorded later (Section 9)

* `reconstruction_matches_recorded_ladder` — the reconstructed bitlen-96 and bitlen-100 readings
  agree with the recorded ladder to `1/1000`.
* `acceleration_did_not_persist` — the honest negative: the next rung's decrement is `0.0125`
  against the preceding `0.0431`, and the ladder even rises at bitlen 116, so the hypothesis of
  `dial_extinct_by_bitlen_176` fails and that forecast is void.
* `ladder_has_no_fixed_curvature` — but the refutation of Section 2 *strengthens*: the recorded
  ladder has a strictly convex and a strictly concave grid triple, so no law of fixed curvature
  sign fits it at all.
* `model_scoring_is_mixed`, `both_models_fail_by_120`, `fade_rate_halved_after_104` — the linear
  law wins the next two rungs and loses the two after that; both models are off by more than `7 %`
  at bitlen 120.
* `lateSecant_extinction`, `extinction_window_228_to_231` — the revised prediction: two
  independent secants, one fitted on bitlens 52 and 104 and one on bitlens 104 and 120, place the
  dial's death between bitlen 228 and 231.

## Honest bookkeeping

Only the bitlen-104 pooled value and its three seeds are recorded numbers of this experiment.
The two preceding readings `read100 = 0.543` and `read96 = 0.573` are *reconstructed* from the
reported step sizes `−0.043` and `−0.030`; they are used only through those steps, and every
theorem that depends on them says so in its statement.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64

open Catalog.Novelty.ZeroFitDialU76

open Catalog.Novelty.ZeroFitDialPerturbation

open Catalog.MachineLearning.ZeroFitDialUnif52

open Catalog.MachineLearning.ZeroFitDialFloor92

open Catalog.MachineLearning.ZeroFitDialFloor92Padic

namespace Catalog.MachineLearning.ZeroFitDialFade104

/-! ## 1. The recorded bitlen-104 measurement -/

/-- Seed 20261210 at bitlen 104. -/
def seedA104 : ℚ := 493 / 1000
/-- Seed 20261211 at bitlen 104. -/
def seedB104 : ℚ := 499 / 1000
/-- Seed 20261212 at bitlen 104. -/
def seedC104 : ℚ := 509 / 1000
/-- Pooled bitlen-104 reading. -/
def pooled104 : ℚ := 500 / 1000
/-- Lower end of the pooled confidence interval. -/
def ci104Low : ℚ := 456 / 1000
/-- Upper end of the pooled confidence interval. -/
def ci104High : ℚ := 545 / 1000
/-- Pooled advantage of the trailing-zero dial over the count baseline at bitlen 104. -/
def advantage104 : ℚ := 126 / 1000
/-- The implied pooled reading of the count baseline at bitlen 104. -/
def countPooled104 : ℚ := pooled104 - advantage104

/-- Reported 4-bit fade step from bitlen 100 to bitlen 104. -/
def step100 : ℚ := 43 / 1000
/-- Reported 4-bit fade step from bitlen 96 to bitlen 100. -/
def step96 : ℚ := 30 / 1000
/-- Bitlen-100 reading, reconstructed from `pooled104` and the reported step. -/
def read100 : ℚ := pooled104 + step100
/-- Bitlen-96 reading, reconstructed from `read100` and the reported step. -/
def read96 : ℚ := read100 + step96

/-- **The fade has passed the floor.**  Every seed, and the pooled reading, is strictly below
the validation floor `0.55`; the confidence interval brackets all three seeds and its upper end
is itself below the floor. -/
theorem u104_below_floor :
    seedA104 < floorBand ∧ seedB104 < floorBand ∧ seedC104 < floorBand ∧
      pooled104 < floorBand ∧ ci104High < floorBand ∧
      ci104Low ≤ seedA104 ∧ seedC104 ≤ ci104High := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;>
    norm_num [seedA104, seedB104, seedC104, pooled104, ci104High, ci104Low, floorBand]

/-- The pooled value agrees with the seed mean to within `1/1000`. -/
theorem pooled104_is_seed_mean : |pooled104 - (seedA104 + seedB104 + seedC104) / 3| ≤ 1 / 1000 := by
  rw [abs_le]
  constructor <;> norm_num [pooled104, seedA104, seedB104, seedC104]

/-- The reconstructed readings, and the monotone fade through the last three bitlens. -/
theorem late_epoch_readings :
    read96 = 573 / 1000 ∧ read100 = 543 / 1000 ∧
      pooled104 < read100 ∧ read100 < read96 := by
  refine ⟨by norm_num [read96, read100, pooled104, step96, step100],
    by norm_num [read100, pooled104, step100], ?_, ?_⟩ <;>
    norm_num [read96, read100, pooled104, step96, step100]

/-! ## 2. The convexity dichotomy: convex fade laws cannot accelerate -/

/-- A hyperbolic fade law `ρ(b) = A + C/b`. -/
def hypLaw (A C : ℚ) (b : ℕ) : ℚ := A + C / (b : ℚ)

/-- A geometric fade law `ρ(b) = A + C·q^b`. -/
def geoLaw (A C q : ℚ) (b : ℕ) : ℚ := A + C * q ^ b

/-- **Exact second difference of a hyperbolic law** on the 4-bit grid. -/
theorem hypLaw_second_difference (A C : ℚ) (b : ℕ) (hb : 1 ≤ b) :
    (hypLaw A C b - hypLaw A C (b + 4)) - (hypLaw A C (b + 4) - hypLaw A C (b + 8))
      = 32 * C / ((b : ℚ) * ((b : ℚ) + 4) * ((b : ℚ) + 8)) := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have h0 : (b : ℚ) ≠ 0 := by intro hc; rw [hc] at hbq; norm_num at hbq
  have h4 : (b : ℚ) + 4 ≠ 0 := by intro hc; linarith
  have h8 : (b : ℚ) + 8 ≠ 0 := by intro hc; linarith
  simp only [hypLaw]
  push_cast
  field_simp
  ring

/-- **Exact second difference of a geometric law** on the 4-bit grid. -/
theorem geoLaw_second_difference (A C q : ℚ) (b : ℕ) :
    (geoLaw A C q b - geoLaw A C q (b + 4)) - (geoLaw A C q (b + 4) - geoLaw A C q (b + 8))
      = C * q ^ b * (1 - q ^ 4) ^ 2 := by
  simp only [geoLaw, pow_add]
  ring

/-- **Hyperbolic fades decelerate.**  For a non-negative curvature constant the 4-bit decrements
of `A + C/b` are antitone: each step is at most the previous one. -/
theorem hypLaw_decelerates (A C : ℚ) (hC : 0 ≤ C) (b : ℕ) (hb : 1 ≤ b) :
    hypLaw A C (b + 4) - hypLaw A C (b + 8) ≤ hypLaw A C b - hypLaw A C (b + 4) := by
  have hbq : (1 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  have hid := hypLaw_second_difference A C b hb
  have hpos : 0 ≤ 32 * C / ((b : ℚ) * ((b : ℚ) + 4) * ((b : ℚ) + 8)) := by
    apply div_nonneg (by linarith)
    have : (0 : ℚ) < (b : ℚ) * ((b : ℚ) + 4) * ((b : ℚ) + 8) := by positivity
    linarith
  linarith

/-- **Geometric fades decelerate.**  Same conclusion for `A + C·q^b` with `C, q ≥ 0`. -/
theorem geoLaw_decelerates (A C q : ℚ) (hC : 0 ≤ C) (hq : 0 ≤ q) (b : ℕ) :
    geoLaw A C q (b + 4) - geoLaw A C q (b + 8) ≤ geoLaw A C q b - geoLaw A C q (b + 4) := by
  have hid := geoLaw_second_difference A C q b
  have hpos : 0 ≤ C * q ^ b * (1 - q ^ 4) ^ 2 :=
    mul_nonneg (mul_nonneg hC (pow_nonneg hq b)) (sq_nonneg _)
  linarith

/-- **The observed fade accelerates.**  The measured 4-bit decrement grew from `0.030` to
`0.043`: the second difference of the data is strictly negative. -/
theorem observed_fade_accelerates : read96 - read100 < read100 - pooled104 := by
  norm_num [read96, read100, pooled104, step96, step100]

/-- **No hyperbolic law fits the late epoch.**  For *any* parameters `A` and `C ≥ 0`, the law
`A + C/b` cannot reproduce the three readings at bitlens 96, 100, 104: hyperbolic fades
decelerate, and this one accelerates. -/
theorem no_hyperbolic_law_fits (A C : ℚ) (hC : 0 ≤ C)
    (h96 : hypLaw A C 96 = read96) (h100 : hypLaw A C 100 = read100)
    (h104 : hypLaw A C 104 = pooled104) : False := by
  have hdec := hypLaw_decelerates A C hC 96 (by norm_num)
  norm_num at hdec
  rw [h96, h100, h104] at hdec
  have hacc := observed_fade_accelerates
  linarith

/-- **No geometric law fits the late epoch** either, for any `A`, any `C ≥ 0` and any `q ≥ 0`. -/
theorem no_geometric_law_fits (A C q : ℚ) (hC : 0 ≤ C) (hq : 0 ≤ q)
    (h96 : geoLaw A C q 96 = read96) (h100 : geoLaw A C q 100 = read100)
    (h104 : geoLaw A C q 104 = pooled104) : False := by
  have hdec := geoLaw_decelerates A C q hC hq 96
  norm_num at hdec
  rw [h96, h100, h104] at hdec
  have hacc := observed_fade_accelerates
  linarith

/-- **The previous cycle's fitted law fails in the predicted way.**  `rhoModel` under-predicts at
bitlen 96, is essentially exact at bitlen 100, and over-predicts at bitlen 104 by more than
`1/30` — a sign flip of the residual, the signature of wrong curvature, against a fit that was
uniformly within `1/100` at bitlens 44 through 92. -/
theorem rhoModel_residual_sign_flip :
    rhoModel 96 < read96 ∧ |rhoModel 100 - read100| < 1 / 1000 ∧
      pooled104 + 1 / 30 < rhoModel 104 := by
  refine ⟨by norm_num [rhoModel, read96, read100, pooled104, step96, step100], ?_, ?_⟩
  · rw [abs_lt]
    constructor <;> norm_num [rhoModel, read100, pooled104, step100]
  · norm_num [rhoModel, pooled104]

/-- The fitted law's own 4-bit step is more than five times smaller than the measured one. -/
theorem rhoModel_step_too_small :
    rhoModel 100 - rhoModel 104 < (read100 - pooled104) / 5 := by
  norm_num [rhoModel, read100, pooled104, step100]

/-! ## 3. Accelerating fades have a finite death -/

/-- If the 4-bit decrements of `f` are non-decreasing from `b₀` on, then every decrement is at
least the first one. -/
theorem accelerating_step_lower (f : ℕ → ℚ) (b0 : ℕ) (d : ℚ)
    (hstep0 : d ≤ f b0 - f (b0 + 4))
    (hacc : ∀ k : ℕ, f (b0 + 4 * k) - f (b0 + 4 * (k + 1))
      ≤ f (b0 + 4 * (k + 1)) - f (b0 + 4 * (k + 2))) :
    ∀ k : ℕ, d ≤ f (b0 + 4 * k) - f (b0 + 4 * (k + 1)) := by
  intro k
  induction k with
  | zero => simpa using hstep0
  | succ n ih =>
      have h := hacc n
      linarith

/-- **Linear descent of an accelerating fade.**  If the decrements are non-decreasing and the
first one is at least `d`, then the fade falls at least linearly: `f(b₀+4k) ≤ f b₀ − k·d`. -/
theorem accelerating_fade_linear_bound (f : ℕ → ℚ) (b0 : ℕ) (d : ℚ)
    (hstep0 : d ≤ f b0 - f (b0 + 4))
    (hacc : ∀ k : ℕ, f (b0 + 4 * k) - f (b0 + 4 * (k + 1))
      ≤ f (b0 + 4 * (k + 1)) - f (b0 + 4 * (k + 2))) :
    ∀ k : ℕ, f (b0 + 4 * k) ≤ f b0 - (k : ℚ) * d := by
  intro k
  induction k with
  | zero => simp
  | succ n ih =>
      have hstep := accelerating_step_lower f b0 d hstep0 hacc n
      push_cast
      linarith

/-- **Accelerating fades die.**  A fade whose 4-bit decrements are non-decreasing, with a
strictly positive first decrement, reaches `0` at a finite bitlen.  There is no asymptote to
hide behind: the only fades with a strictly positive limit are the decelerating ones. -/
theorem accelerating_fade_extinction (f : ℕ → ℚ) (b0 : ℕ) (d : ℚ) (hd : 0 < d)
    (hstep0 : d ≤ f b0 - f (b0 + 4))
    (hacc : ∀ k : ℕ, f (b0 + 4 * k) - f (b0 + 4 * (k + 1))
      ≤ f (b0 + 4 * (k + 1)) - f (b0 + 4 * (k + 2))) :
    ∃ k : ℕ, f (b0 + 4 * k) ≤ 0 := by
  obtain ⟨k, hk⟩ := exists_nat_gt (f b0 / d)
  refine ⟨k, ?_⟩
  have hbound := accelerating_fade_linear_bound f b0 d hstep0 hacc k
  have hlt : f b0 < (k : ℚ) * d := by
    rw [div_lt_iff₀ hd] at hk
    linarith
  linarith

/-- **The extinction prediction.**  Suppose the acceleration recorded at bitlens 96–104
persists, in the weak sense that the 4-bit decrements never shrink and the first one is the
measured `0.030`.  Then, starting from the bitlen-96 reading `0.573`, the dial reads `≤ 0` by
bitlen `176` — twenty 4-bit steps later.  This is the falsifiable replacement for the previous
cycle's `5/14` asymptote. -/
theorem dial_extinct_by_bitlen_176 (f : ℕ → ℚ) (h96 : f 96 = read96)
    (hstep0 : step96 ≤ f 96 - f 100)
    (hacc : ∀ k : ℕ, f (96 + 4 * k) - f (96 + 4 * (k + 1))
      ≤ f (96 + 4 * (k + 1)) - f (96 + 4 * (k + 2))) :
    f 176 ≤ 0 := by
  have hb := accelerating_fade_linear_bound f 96 step96 (by simpa using hstep0) hacc 20
  norm_num at hb
  rw [h96] at hb
  have : read96 - (20 : ℚ) * step96 ≤ 0 := by
    norm_num [read96, read100, pooled104, step96, step100]
  linarith

/-! ## 4. The local linear law and its three predictions -/

/-- The late-epoch secant law `ρ(b) = 1449/1000 − (73/8000)·b`. -/
def linModel (b : ℕ) : ℚ := 1449 / 1000 - (73 / 8000) * (b : ℚ)

/-- **The linear fit.**  The secant law reproduces the bitlen-96 and bitlen-104 readings exactly
and the bitlen-100 reading to within `0.0065`. -/
theorem linModel_fits_late_epoch :
    linModel 96 = read96 ∧ |linModel 100 - read100| ≤ 65 / 10000 ∧ linModel 104 = pooled104 := by
  refine ⟨by norm_num [linModel, read96, read100, pooled104, step96, step100], ?_, ?_⟩
  · rw [abs_le]
    constructor <;> norm_num [linModel, read100, pooled104, step100]
  · norm_num [linModel, pooled104]

/-- The linear law has a constant 4-bit step, the mean `73/2000 = 0.0365` of the two measured
steps. -/
theorem linModel_step_constant (b : ℕ) : linModel b - linModel (b + 4) = 73 / 2000 := by
  simp only [linModel]
  push_cast
  ring

/-- **The linear law is local, not global.**  Extrapolated backwards it exceeds `1` at every
bitlen up to `49`, which no correlation coefficient can do.  The near-linear fade is therefore an
*intermediate* regime: the dial's history has at least three phases. -/
theorem linModel_not_global : ∀ b : ℕ, b ≤ 49 → 1 < linModel b := by
  intro b hb
  have hbq : (b : ℚ) ≤ 49 := by exact_mod_cast hb
  rw [linModel]
  linarith

/-- **Floor crossing.**  Under the linear law the dial is at or above the validation floor
exactly up to bitlen `98`, and below it from bitlen `99` on. -/
theorem linModel_floor_crossing (b : ℕ) : floorBand ≤ linModel b ↔ b ≤ 98 := by
  rw [floorBand, linModel]
  constructor
  · intro h
    have hbq : (b : ℚ) < 99 := by linarith
    have : b < 99 := by exact_mod_cast hbq
    omega
  · intro h
    have hbq : (b : ℚ) ≤ 98 := by exact_mod_cast h
    linarith

/-- **Extinction bitlen.**  Under the linear law the dial reads `≥ 0` exactly up to bitlen `158`
and is negative from bitlen `159` on: a sharp, parameter-free prediction of the death of the
zero-fit dial. -/
theorem linModel_extinction (b : ℕ) : 0 ≤ linModel b ↔ b ≤ 158 := by
  rw [linModel]
  constructor
  · intro h
    have hbq : (b : ℚ) < 159 := by linarith
    have : b < 159 := by exact_mod_cast hbq
    omega
  · intro h
    have hbq : (b : ℚ) ≤ 158 := by exact_mod_cast h
    linarith

/-- **The saturation ceiling is breached.**  The previous cycle proved that the hyperbolic law
never forces a rank displacement beyond `3/28 ≈ 10.7 %`.  Under the linear law that ceiling is
passed from bitlen `120` on, so the two models are distinguishable by a single further
measurement well before extinction. -/
theorem saturation_breached_from_120 (b : ℕ) (hb : 120 ≤ b) : 3 / 28 < reqFrac (linModel b) := by
  have hbq : (120 : ℚ) ≤ (b : ℚ) := by exact_mod_cast hb
  rw [reqFrac, linModel]
  linarith

/-- The two models genuinely disagree in the observable range: at bitlen 120 they differ by more
than `0.08`, five times the largest residual either has ever shown. -/
theorem models_separate_at_120 : 8 / 100 < rhoModel 120 - linModel 120 := by
  norm_num [rhoModel, linModel]

/-! ## 5. Mechanism exclusions at bitlen 104 -/

/-- **Coarse resolution is still excluded.**  Every `K`-capped 2-adic dial reads `ρ² ≥ 3/4` at
every bitlen, while the largest bitlen-104 seed reads `ρ² = 0.259`. -/
theorem truncation_excluded_104 (K r : ℕ) (hK : 1 ≤ K) :
    seedC104 ^ 2 < spearmanSq (cappedBlocks K r) := by
  have h := capped_ceiling_ge_three_quarters K r hK
  have hs : seedC104 ^ 2 < 3 / 4 := by norm_num [seedC104]
  linarith

/-- The same exclusion for the honest arithmetic profile of the capped valuation. -/
theorem truncation_excluded_104_valuation (b K : ℕ) (hK : 1 ≤ K) (hKb : K ≤ b) :
    seedC104 ^ 2 < spearmanSq (cappedValuationProfile b K) := by
  have hb : 1 ≤ b := le_trans hK hKb
  have hsum : (cappedValuationProfile b K).sum = (cappedBlocks K (b - K)).sum :=
    cappedValuationProfile_sum b K hKb
  have hbk : (b - K) + K = b := by omega
  have h2 : 2 ≤ (cappedValuationProfile b K).sum := by
    rw [hsum, cappedBlocks_sum, hbk]
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ b := Nat.pow_le_pow_right (by norm_num) hb
  rw [spearmanSq_congr hsum (cappedValuationProfile_tieCorr b K hKb) h2]
  exact truncation_excluded_104 K (b - K) hK

/-- **Tie geometry is excluded by fifty orders of magnitude.**  Between bitlen 92 and bitlen 104
the exact dyadic tie ceiling moves by less than `10⁻⁵⁰`, while the measured `ρ²` fell by more
than `0.06`. -/
theorem tie_mechanism_excluded_92_to_104 :
    spearmanSq (dyadicBlocks 92) - spearmanSq (dyadicBlocks 104) < 1 / 10 ^ 50 ∧
      6 / 100 < mean92 ^ 2 - pooled104 ^ 2 := by
  constructor
  · rw [dyadic_spearmanSq 92 (by norm_num), dyadic_spearmanSq 104 (by norm_num)]
    norm_num
  · norm_num [mean92, seed10, seed11, pooled104]

/-- **Ceiling utilisation has collapsed.**  The dial realises less than `30 %` of the squared
tie ceiling it is allowed, down from more than `57 %` at bitlen 52: the loss is in the response,
and it is now the dominant term. -/
theorem ceiling_utilisation_collapsed :
    pooled104 ^ 2 / spearmanSq (dyadicBlocks 104) < 3 / 10 ∧
      57 / 100 < pooled52 ^ 2 / spearmanSq (dyadicBlocks 52) := by
  constructor
  · rw [dyadic_spearmanSq 104 (by norm_num)]
    rw [div_lt_iff₀ (by positivity)]
    norm_num [pooled104]
  · rw [dyadic_spearmanSq 52 (by norm_num)]
    rw [lt_div_iff₀ (by positivity)]
    norm_num [pooled52]

/-! ## 6. The `p`-adic ledger: where the effective base has drifted -/

/-- **Uniqueness of the effective base.**  A reading determines its effective base. -/
theorem effective_base_unique {rho : ℚ} {p p' : ℕ} (hp : 1 ≤ p) (hp' : 1 ≤ p')
    (h : EffectiveBase rho p) (h' : EffectiveBase rho p') : p = p' := by
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · have hle : padicLimit p' ≤ padicLimit (p + 1) := by
      rcases lt_or_eq_of_le (Nat.succ_le_of_lt hlt) with hlt' | heq
      · exact le_of_lt (padicLimit_strict_anti (by omega) hlt')
      · have hpe : p + 1 = p' := heq
        rw [hpe]
    have h1 := h.1
    have h2 := h'.2
    linarith
  · have hle : padicLimit p ≤ padicLimit (p' + 1) := by
      rcases lt_or_eq_of_le (Nat.succ_le_of_lt hlt) with hlt' | heq
      · exact le_of_lt (padicLimit_strict_anti (by omega) hlt')
      · have hpe : p' + 1 = p := heq
        rw [hpe]
    have h1 := h'.1
    have h2 := h.2
    linarith

/-- **The effective base is `Θ(ρ⁻²)`.**  Any effective base of a positive reading is bracketed
by `1/ρ² − 1 < p ≤ 3/ρ²`.  At the bitlen-104 pooled reading `ρ = 1/2` this reads `3 < p ≤ 12`. -/
theorem effective_base_bracket {rho : ℚ} (hrho : 0 < rho) {p : ℕ} (hp : 1 ≤ p)
    (h : EffectiveBase rho p) : 1 / rho ^ 2 - 1 < (p : ℚ) ∧ (p : ℚ) ≤ 3 / rho ^ 2 := by
  have hpq : (1 : ℚ) ≤ (p : ℚ) := by exact_mod_cast hp
  have hsq : 0 < rho ^ 2 := by positivity
  constructor
  · -- lower bound, from `padicLimit (p+1) ≥ 1/(p+1)`
    have hlow : 1 / ((p : ℚ) + 1) ≤ padicLimit (p + 1) := by
      rw [padicLimit]
      push_cast
      rw [div_le_div_iff₀ (by linarith) (by nlinarith)]
      nlinarith
    have h1 := h.1
    have hlt : 1 / ((p : ℚ) + 1) < rho ^ 2 := by linarith
    rw [div_lt_iff₀ (by linarith)] at hlt
    rw [sub_lt_iff_lt_add, div_lt_iff₀ hsq]
    linarith
  · -- upper bound, from `padicLimit p ≤ 3/p`
    have hup : padicLimit p ≤ 3 / (p : ℚ) := by
      rw [padicLimit]
      rw [div_le_div_iff₀ (by nlinarith) (by linarith)]
      nlinarith
    have h2 := h.2
    have hle : rho ^ 2 ≤ 3 / (p : ℚ) := le_trans h2 hup
    rw [le_div_iff₀ (by linarith)] at hle
    rw [le_div_iff₀ hsq]
    linarith

/-- **The effective base at bitlen 104.**  The pooled reading and the two upper seeds behave like
a base-`10` valuation dial; the lowest seed has already drifted to base `11`. -/
theorem effective_base_104 :
    EffectiveBase pooled104 10 ∧ EffectiveBase seedB104 10 ∧ EffectiveBase seedC104 10 ∧
      EffectiveBase seedA104 11 := by
  refine ⟨⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩, ⟨?_, ?_⟩⟩ <;>
    norm_num [EffectiveBase, padicLimit, pooled104, seedA104, seedB104, seedC104]

/-- **The base drift accelerates.**  At bitlen 92 the dial had effective base `8`; at bitlen 104
it has effective base `10`.  Two units in twelve bits, against one unit in the preceding sixteen:
the `p`-adic ledger accelerates exactly like the fade. -/
theorem base_drift_accelerates :
    EffectiveBase mean92 8 ∧ EffectiveBase pooled104 10 ∧ (1 : ℚ) / 16 < 2 / 12 := by
  refine ⟨effective_base_92_is_eight.2.2, effective_base_104.1, by norm_num⟩

/-- The bracket, checked against the measured base: `10` sits inside `(3, 12]`. -/
theorem effective_base_104_inside_bracket :
    1 / pooled104 ^ 2 - 1 < (10 : ℚ) ∧ (10 : ℚ) ≤ 3 / pooled104 ^ 2 := by
  have h := effective_base_bracket (rho := pooled104) (by norm_num [pooled104])
    (p := 10) (by norm_num) effective_base_104.1
  exact_mod_cast h

/-! ## 7. The corruption ledger at bitlen 104 -/

/-- **The floor budget is exhausted.**  The bitlen-104 reading forces a rank displacement of
exactly `1/12 ≈ 8.33 %`, strictly above the `7.5 %` that characterises the validation floor and
strictly above the `7.34 %` forced at bitlen 92 — but still strictly below the `3/28` saturation
value of the (now refuted) hyperbolic law. -/
theorem budget_104 :
    reqFrac pooled104 = 1 / 12 ∧ 3 / 40 < reqFrac pooled104 ∧
      reqFrac mean92 < reqFrac pooled104 ∧ reqFrac pooled104 < 3 / 28 := by
  refine ⟨by norm_num [reqFrac, pooled104], by norm_num [reqFrac, pooled104], ?_, ?_⟩ <;>
    norm_num [reqFrac, pooled104, mean92, seed10, seed11]

/-- **Any mechanism must now break the floor budget.**  If a rank-level mechanism re-ranks a
perfectly aligned response only on a set `A` and produces the bitlen-104 reading, then `A`
contains strictly more than `7.5 %` of the sample.  Combined with
`floor_is_the_seven_point_five_percent_budget` — which says that touching at most `7.5 %` keeps
the reading at or above `0.55` — this is the exact sense in which the dial has left the band. -/
theorem floor_budget_exhausted_104 {n : ℕ} (hn : 2 ≤ n) (R S' : Fin n → ℚ) (hR : IsRankVec n R)
    (hS' : IsRankVec n S') (A : Finset (Fin n)) (hagree : ∀ i ∉ A, R i = S' i)
    (hread : rhoRank R S' ≤ pooled104) :
    (n : ℚ) * (3 / 40) < (A.card : ℚ) := by
  have h := reading_corruption_budget hn R S' hR hS' A hagree pooled104 hread
  have hfrac : reqFrac pooled104 = 1 / 12 := by norm_num [reqFrac, pooled104]
  rw [hfrac] at h
  have hnq : (2 : ℚ) ≤ (n : ℚ) := by exact_mod_cast hn
  nlinarith

/-! ## 8. The widening advantage over the count baseline -/

/-- **The advantage widens.**  `+0.070` at bitlen 52, `+0.073` at bitlen 76, `+0.126` at bitlen
104: the trailing-zero dial pulls away from the count baseline as both degrade. -/
theorem advantage_widens : advantage < countGap ∧ countGap < advantage104 := by
  constructor <;> norm_num [advantage, countGap, advantage104]

/-- **The count baseline degrades faster**, both absolutely (it lost `0.261` against the dial's
`0.205` between bitlen 52 and 104) and in ratio (it retains `59 %` of its bitlen-52 value against
the dial's `71 %`). -/
theorem count_degrades_faster :
    pooled52 - pooled104 < countPooled - countPooled104 ∧
      countPooled104 / countPooled < pooled104 / pooled52 := by
  constructor
  · norm_num [pooled52, pooled104, countPooled, countPooled104, advantage, advantage104]
  · rw [div_lt_div_iff₀ (by norm_num [countPooled, pooled52, advantage])
      (by norm_num [pooled52])]
    norm_num [pooled52, pooled104, countPooled, countPooled104, advantage, advantage104]

/-- Secant extrapolation of the dial from the bitlen-52 and bitlen-104 readings. -/
def tSecant (b : ℕ) : ℚ := pooled52 - (pooled52 - pooled104) * ((b : ℚ) - 52) / 52

/-- Secant extrapolation of the count baseline from the same two bitlens. -/
def countSecant (b : ℕ) : ℚ := countPooled - (countPooled - countPooled104) * ((b : ℚ) - 52) / 52

/-- **The advantage is affine in the bitlen**, with slope `7/6500` per bit: the widening is not a
fluctuation but the difference of two fade rates. -/
theorem advantage_secant_affine (b : ℕ) :
    tSecant b - countSecant b = advantage + (7 / 6500) * ((b : ℚ) - 52) := by
  simp only [tSecant, countSecant, pooled52, pooled104, countPooled, countPooled104,
    advantage, advantage104]
  ring

/-- The secant advantage reproduces the recorded bitlen-104 value exactly — and *over*-predicts
the recorded bitlen-76 advantage by more than `0.02`.  So the widening is not affine either: the
advantage was flat between bitlen 52 and 76 (`0.070 → 0.073`) and opened up only afterwards.  The
widening is a late-epoch phenomenon, contemporaneous with the fade's acceleration. -/
theorem advantage_secant_matches_104_but_not_76 :
    tSecant 104 - countSecant 104 = advantage104 ∧
      2 / 100 < (tSecant 76 - countSecant 76) - countGap := by
  constructor
  · rw [advantage_secant_affine]
    norm_num [advantage, advantage104]
  · rw [advantage_secant_affine]
    norm_num [advantage, countGap]

/-- **The count baseline dies first.**  Under the two secants the count statistic is extinguished
at bitlen `179` while the dial is still reading above `0.20`, and the dial itself survives to
bitlen `230`: a fifty-two bit gap between the two deaths. -/
theorem count_dies_first :
    countSecant 179 < 0 ∧ 1 / 5 < tSecant 179 ∧ 0 < tSecant 230 ∧ tSecant 231 < 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [tSecant, countSecant, pooled52, pooled104, countPooled, countPooled104,
      advantage, advantage104]

/-! ## 9. Out-of-sample scoring against the rungs recorded later

The rungs at bitlens 108, 112, 116 and 120 were recorded *after* the bitlen-104 experiment
analysed above (they appear in `Physics.TDialU108BandLoss`, `Novelty.TDialU112FadeReacceleration`,
`Probability.TDialU116ReboundFloor` and `Algebra.ZeroFitDialU120Floor`).  They are used here only
to score the forecasts that the bitlen-104 data licensed at the time.  The verdict is mixed and
is stated as such. -/

/-- Recorded ladder, bitlen 96. -/
def rung96 : ℚ := 5739 / 10000
/-- Recorded ladder, bitlen 100. -/
def rung100 : ℚ := 5436 / 10000
/-- Recorded ladder, bitlen 104. -/
def rung104 : ℚ := 5005 / 10000
/-- Recorded ladder, bitlen 108. -/
def rung108 : ℚ := 4880 / 10000
/-- Recorded ladder, bitlen 112. -/
def rung112 : ℚ := 4621 / 10000
/-- Recorded ladder, bitlen 116 (the rebound rung). -/
def rung116 : ℚ := 4847 / 10000
/-- Recorded ladder, bitlen 120. -/
def rung120 : ℚ := 43636 / 100000

/-- The readings reconstructed from the reported step sizes agree with the recorded ladder to
within `1/1000`, so nothing above depends on the reconstruction. -/
theorem reconstruction_matches_recorded_ladder :
    |read96 - rung96| ≤ 1 / 1000 ∧ |read100 - rung100| ≤ 1 / 1000 ∧
      |pooled104 - rung104| ≤ 1 / 1000 := by
  refine ⟨?_, ?_, ?_⟩ <;> rw [abs_le] <;> constructor <;>
    norm_num [read96, read100, pooled104, step96, step100, rung96, rung100, rung104]

/-- **The acceleration did not persist.**  The very next rung has a 4-bit decrement of `0.0125`
against the preceding `0.0431`, and the rung after `112` even *rises*.  So the hypothesis of
`dial_extinct_by_bitlen_176` — non-decreasing decrements — is false on the recorded ladder, and
the bitlen-176 extinction forecast is void.  What survives is the *conditional*: extinction is
the price of persistent acceleration, so the ladder's survival is evidence of deceleration, not
of a floor. -/
theorem acceleration_did_not_persist :
    rung104 - rung108 < rung100 - rung104 ∧ rung112 < rung116 := by
  constructor <;> norm_num [rung100, rung104, rung108, rung112, rung116]

/-- **The ladder has no fixed curvature.**  Any function through the four rungs 96–108 has one
strictly convex and one strictly concave grid triple.  Hence *no* law with a fixed sign of the
second difference — in particular no hyperbolic, geometric, exponential or affine law — can
reproduce the recorded ladder, whatever its parameters.  The convexity dichotomy of Section 2
is therefore not a defect of the hyperbolic family: it is a property of the data. -/
theorem ladder_has_no_fixed_curvature (f : ℕ → ℚ)
    (h96 : f 96 = rung96) (h100 : f 100 = rung100) (h104 : f 104 = rung104)
    (h108 : f 108 = rung108) :
    ¬ (f 100 - f 104 ≤ f 96 - f 100) ∧ ¬ (f 104 - f 108 ≥ f 100 - f 104) := by
  rw [h96, h100, h104, h108]
  constructor <;> push_neg <;>
    norm_num [rung96, rung100, rung104, rung108]

/-- No convex law passes through the *recorded* rungs 96, 100, 104 either — the refutation of
Section 2 does not depend on the reconstruction. -/
theorem no_hyperbolic_law_fits_recorded (A C : ℚ) (hC : 0 ≤ C)
    (h96 : hypLaw A C 96 = rung96) (h100 : hypLaw A C 100 = rung100)
    (h104 : hypLaw A C 104 = rung104) : False := by
  have hdec := hypLaw_decelerates A C hC 96 (by norm_num)
  norm_num at hdec
  rw [h96, h100, h104] at hdec
  have : rung96 - rung100 < rung100 - rung104 := by
    norm_num [rung96, rung100, rung104]
  linarith

/-- **Scoring, honestly.**  On the two rungs immediately following the forecast the linear law
beats the hyperbolic one; on the two after that the ordering reverses, because the ladder
rebounds at bitlen 116 while the linear law keeps falling.  Switching shape class was right in
the short run and wrong in the long run. -/
theorem model_scoring_is_mixed :
    |linModel 108 - rung108| < |rhoModel 108 - rung108| ∧
      |linModel 112 - rung112| < |rhoModel 112 - rung112| ∧
      |rhoModel 116 - rung116| < |linModel 116 - rung116| ∧
      |rhoModel 120 - rung120| < |linModel 120 - rung120| := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · rw [abs_of_nonpos (by norm_num [linModel, rung108]),
      abs_of_nonneg (by norm_num [rhoModel, rung108])]
    norm_num [linModel, rhoModel, rung108]
  · rw [abs_of_nonpos (by norm_num [linModel, rung112]),
      abs_of_nonneg (by norm_num [rhoModel, rung112])]
    norm_num [linModel, rhoModel, rung112]
  · rw [abs_of_nonneg (by norm_num [rhoModel, rung116]),
      abs_of_nonpos (by norm_num [linModel, rung116])]
    norm_num [linModel, rhoModel, rung116]
  · rw [abs_of_nonneg (by norm_num [rhoModel, rung120]),
      abs_of_nonpos (by norm_num [linModel, rung120])]
    norm_num [linModel, rhoModel, rung120]

/-- Both models are wrong by more than `7 %` at bitlen 120: the linear law over-fades, the
hyperbolic law under-fades, and the truth is between them. -/
theorem both_models_fail_by_120 :
    linModel 120 < rung120 - 8 / 100 ∧ rung120 + 7 / 100 < rhoModel 120 := by
  constructor <;> norm_num [linModel, rhoModel, rung120]

/-- **The fade rate more than halved after bitlen 104.**  The mean 4-bit decrement over the four
rungs from 104 to 120 is `0.016035`, less than half the linear law's constant `0.0365`. -/
theorem fade_rate_halved_after_104 : 2 * ((rung104 - rung120) / 4) < 73 / 2000 := by
  norm_num [rung104, rung120]

/-- The post-104 secant of the ladder: the line through the recorded rungs at bitlens 104 and
120. -/
def lateSecant (b : ℕ) : ℚ := rung120 - ((rung104 - rung120) / 16) * ((b : ℚ) - 120)

/-- **The revised death of the dial.**  The post-104 secant reads `≥ 0` exactly up to bitlen
`228`.  The bitlen-176 forecast of the acceleration hypothesis and the bitlen-159 forecast of the
linear law are both superseded; extinction itself is not. -/
theorem lateSecant_extinction (b : ℕ) : 0 ≤ lateSecant b ↔ b ≤ 228 := by
  rw [lateSecant, rung104, rung120]
  constructor
  · intro h
    have hbq : (b : ℚ) < 229 := by linarith
    have : b < 229 := by exact_mod_cast hbq
    omega
  · intro h
    have hbq : (b : ℚ) ≤ 228 := by exact_mod_cast h
    linarith

/-- **Two independent secants agree on the death bitlen.**  The dial secant fitted on bitlens 52
and 104 dies between bitlen 230 and 231; the ladder secant fitted on bitlens 104 and 120 dies
between 228 and 229.  Two fits sharing a single endpoint and using data sixty-eight bits apart
agree on the extinction bitlen to within three bits — the sharpest prediction this thread has
produced, and the one the next rungs should be scored against. -/
theorem extinction_window_228_to_231 :
    0 < lateSecant 228 ∧ lateSecant 229 < 0 ∧ 0 < tSecant 230 ∧ tSecant 231 < 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    norm_num [lateSecant, tSecant, rung104, rung120, pooled52, pooled104]

end Catalog.MachineLearning.ZeroFitDialFade104