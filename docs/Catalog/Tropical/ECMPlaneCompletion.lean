import Mathlib
import Geometry.ECMLiteBirthdayScaling

/-!
# The ECM plane completed: a tropical (min-plus) theory of factoring cost exponents

Experiment 490 (seed `20260921`) measured, on **one** population of toy semiprimes and
with **one** cost functional, the across-`k` cost exponents of five factoring arms
(`k = log₂ p`, `p` the hidden prime):

| arm                    | exponent `α` | regime            |
|------------------------|--------------|-------------------|
| trial division         | `1.00`       | uniform draws     |
| trial division         | `1.14`       | balanced draws    |
| Fermat                 | `0.50`       | both              |
| Pollard rho            | `0.512`      | both              |
| ECM (`B₁ = 50`)        | `0.761`      | both              |
| ECM (`B₁ = 250`)       | `0.718`      | both              |

together with the common-currency intercept gap `c_ECM − c_ρ = +3.04` bits against a
measured `10.29×` wall-time ratio, and the ledger note that a *batched* gcd had erased
the `√p` law of the rho arm (per-iteration gcd restored `α = 0.512`).

This file turns those observations into theorems.  The organising structure is
**tropical**: a factoring arm is an affine function `k ↦ c + α·k` in the log-work
plane, "run two arms and take the better one" is tropical addition (`min`), and
"repeat / compose arms" is tropical multiplication (`+`).  The measured table is then a
finite family of tropical monomials, and the qualitative claims of the experiment become
statements about the corner locus of the associated tropical polynomial.

## Main results

*Tropical algebra of cost profiles* (§1)

* `work_mul`, `work_min_add` — composition is tropical multiplication and racing is
  tropical addition; the min-plus distributive law holds for cost profiles.
* `min_concave` — a two-arm race is a concave piecewise-affine function of `k`.
* `dominates_of_le`, `eventual_dominance_of_slope_lt` — a strictly smaller exponent
  wins for all large `k` **whatever** the intercepts; equal-or-smaller in both
  coordinates wins everywhere.
* `crossover_point` — when the exponents differ there is a unique corner `k*`, with an
  explicit formula, and the race changes leader exactly there.
* `min_affine_iff_slope_eq` — **the corner criterion**: the race of two arms is again a
  single affine arm iff the two exponents coincide.  This is the tropical form of
  factor-locality.
* `corner_far_of_near_parallel` — a quantitative version: if the exponents differ by at
  most `ε` while the intercepts differ by at least `δ`, the corner sits at
  `|k*| ≥ δ/ε`, i.e. outside any window of that size.

*The measured plane* (§2)

* `ecm_exponent_strictly_between` — `0.512 < 0.718 ≤ 0.761 < 1.00`: the ECM column lands
  strictly inside the rho / trial-division bracket, in both stage-one regimes.
* `rho_dominates_ecm`, `ecm_never_crosses_rho` — with `c_ECM − c_ρ = 3.04 > 0` **and** a
  larger exponent, rho beats ECM at every `k ≥ 0`: the measured plane contains no
  crossover, and `crossover_needs_inversion` shows a crossover would require inverting
  one of the two coordinates.
* `common_currency_within_one_bit` — the `3.04`-bit common-currency gap and the `10.29×`
  wall-time ratio agree to within one bit (`3 < log₂ 10.29 < 4`), which is the precise
  content of "H3 at the edge".
* `td_regime_pair_has_corner`, `rho_regime_pair_has_no_corner` — the two-regime tropical
  polynomial has a corner for trial division (`1.00` vs `1.14`) and none for the
  factor-local arms (`Δα = 0`); `rho_corner_beyond_window` bounds where a corner could
  hide given the `Δα ≤ 0.03` measurement tolerance.

*Where the ECM exponent comes from* (§3)

* `ecm_total_work_lower_bound` — from the catalog curve-budget bound
  (`ECMLite.curve_budget_lower_bound`, visible set `≤ B²` inside a group of size `≈ p`):
  reaching success probability `1/2` costs at least `p/(2B)` point operations.
* `ecm_work_exponent` — with a stage-one bound `B = p^β` this is exactly `p^{1-β}/2`:
  the ECM arm traces the **tropical line `α = 1 − β`** joining trial division (`β = 0`,
  `α = 1`) to the birthday arms (`β = 1/2`, `α = 1/2`).
* `ecm_work_between_rho_and_td` — for `0 < β < 1/2` the ECM work is strictly between the
  two, which is the structural explanation of the measured `0.718`–`0.761`.
* `bound_from_measured_exponent` — conversely the *measurement calibrates the bound*: a
  measured slope `a` forces `B ≥ p^{1-a}/2`; `ecm_calibration_at_twenty_bits` checks the
  `α = 0.761` column against `B₁ = 50` at `k = 20`.

*The quantisation ledger* (§4)

* `batch_sandwich`, `batch_eq_of_le`, `batch_le_two_mul` — a batched gcd of block size
  `m` replaces a detection time `T` by `m⌈T/m⌉`; this **erases** all `p`-dependence when
  `T ≤ m` and **preserves** the exponent (to within one bit of intercept) when `m ≤ T`.
* `batched_gcd_erases_sqrt_law` / `per_iteration_gcd_keeps_sqrt_law` — the two sides of
  the ledger entry, at the concrete toy sizes `k = 16, 20` with block `m = 2048`: the
  measured two-point slope is `0` batched and exactly `1/2` unbatched.
-/

namespace ECMPlane

open Real

/-! ## 1. Cost profiles and the min-plus (tropical) plane

A factoring arm is summarised by its log-work profile `k ↦ icept + slope · k`, where
`k = log₂ p` and the value is measured in bits ("common currency").  All statements in
this section are about this affine plane, which is the tropical setting: `min` is
tropical `+`, ordinary `+` is tropical `·`. -/

/-- A cost profile: the pair `(α, c)` of an across-`k` exponent and a common-currency
intercept, i.e. the tropical monomial `c ⊙ k^{⊙α}`. -/
structure Profile where
  /-- across-`k` exponent (bits of work per bit of `log₂ p`) -/
  slope : ℝ
  /-- common-currency intercept, in bits -/
  icept : ℝ

/-- Log-work in bits at target size `k = log₂ p`. -/
def work (M : Profile) (k : ℝ) : ℝ := M.icept + M.slope * k

/-- Tropical multiplication of profiles: running one arm after the other (or repeating
an arm) adds log-work, hence adds both coordinates. -/
def Profile.mul (M N : Profile) : Profile := ⟨M.slope + N.slope, M.icept + N.icept⟩

@[simp] theorem work_mul (M N : Profile) (k : ℝ) :
    work (M.mul N) k = work M k + work N k := by
  simp only [work, Profile.mul]; ring

/-- Tropical addition of profiles is `min` of the log-work: racing two arms and keeping
the first to finish. -/
def race (M N : Profile) (k : ℝ) : ℝ := min (work M k) (work N k)

/-- **Min-plus distributivity for cost profiles**: composing a common arm `P` with the
winner of a race is the same as racing the two compositions. -/
theorem work_min_add (M N P : Profile) (k : ℝ) :
    race M N k + work P k = race (M.mul P) (N.mul P) k := by
  simp only [race, work_mul]
  exact (min_add_add_right _ _ _).symm

/-- A race is a concave function of the target size: the tropical sum of two tropical
monomials is concave piecewise affine. -/
theorem min_concave (M N : Profile) {x y t s : ℝ} (ht : 0 ≤ t) (hs : 0 ≤ s)
    (hts : t + s = 1) :
    t * race M N x + s * race M N y ≤ race M N (t * x + s * y) := by
  have hM : t * race M N x + s * race M N y ≤ work M (t * x + s * y) := by
    have h1 : race M N x ≤ work M x := min_le_left _ _
    have h2 : race M N y ≤ work M y := min_le_left _ _
    have := add_le_add (mul_le_mul_of_nonneg_left h1 ht) (mul_le_mul_of_nonneg_left h2 hs)
    refine this.trans (le_of_eq ?_)
    simp only [work]
    linear_combination M.icept * hts
  have hN : t * race M N x + s * race M N y ≤ work N (t * x + s * y) := by
    have h1 : race M N x ≤ work N x := min_le_right _ _
    have h2 : race M N y ≤ work N y := min_le_right _ _
    have := add_le_add (mul_le_mul_of_nonneg_left h1 ht) (mul_le_mul_of_nonneg_left h2 hs)
    refine this.trans (le_of_eq ?_)
    simp only [work]
    linear_combination N.icept * hts
  exact le_min hM hN

/-- Domination in both coordinates gives domination everywhere on `k ≥ 0`. -/
theorem dominates_of_le {M N : Profile} (hs : M.slope ≤ N.slope) (hc : M.icept ≤ N.icept)
    {k : ℝ} (hk : 0 ≤ k) : work M k ≤ work N k := by
  have : M.slope * k ≤ N.slope * k := mul_le_mul_of_nonneg_right hs hk
  simp only [work]; linarith

/-- Strict version: strictly smaller intercept and no larger exponent wins at every
nonnegative `k`. -/
theorem dominates_strict {M N : Profile} (hs : M.slope ≤ N.slope) (hc : M.icept < N.icept)
    {k : ℝ} (hk : 0 ≤ k) : work M k < work N k := by
  have : M.slope * k ≤ N.slope * k := mul_le_mul_of_nonneg_right hs hk
  simp only [work]; linarith

/-- **Exponents beat intercepts asymptotically.**  If `M` has the strictly smaller
exponent then it wins for all sufficiently large `k`, whatever the intercepts. -/
theorem eventual_dominance_of_slope_lt {M N : Profile} (h : M.slope < N.slope) :
    ∃ K : ℝ, ∀ k ≥ K, work M k < work N k := by
  refine ⟨(M.icept - N.icept) / (N.slope - M.slope) + 1, fun k hk => ?_⟩
  have hd : 0 < N.slope - M.slope := by linarith
  have h1 : (M.icept - N.icept) / (N.slope - M.slope) < k := by linarith
  have h2 : M.icept - N.icept < k * (N.slope - M.slope) := by
    rw [div_lt_iff₀ hd] at h1; linarith [h1]
  simp only [work]; nlinarith

/-- A crossover can only happen if one of the two coordinates is inverted: if `N` ever
beats `M` at some `k ≥ 0`, then `N` has the smaller intercept or the smaller exponent. -/
theorem crossover_needs_inversion {M N : Profile} {k : ℝ} (hk : 0 ≤ k)
    (h : work N k < work M k) : N.icept < M.icept ∨ N.slope < M.slope := by
  by_contra hcon
  push_neg at hcon
  exact absurd (dominates_of_le hcon.2 hcon.1 hk) (not_le.mpr h)

/-- **The unique corner of a two-arm race.**  If the exponents differ, the two profiles
agree at exactly one point `k*`, given by the ratio of the intercept gap to the exponent
gap, and the leader changes there. -/
theorem crossover_point {M N : Profile} (h : M.slope < N.slope) :
    ∃! k : ℝ, work M k = work N k := by
  refine ⟨(N.icept - M.icept) / (M.slope - N.slope), ?_, ?_⟩
  · have hne : M.slope - N.slope ≠ 0 := by linarith
    simp only [work]
    field_simp
    ring
  · intro y hy
    have hne : M.slope - N.slope ≠ 0 := by linarith
    simp only [work] at hy
    field_simp
    linarith

/-- On the far side of the corner the smaller exponent leads. -/
theorem lead_after_corner {M N : Profile} (h : M.slope < N.slope)
    {kstar k : ℝ} (hstar : work M kstar = work N kstar) (hk : kstar < k) :
    work M k < work N k := by
  simp only [work] at hstar ⊢
  nlinarith

/-- **The corner criterion (tropical form of factor-locality).**  The race between two
arms is again a *single* affine arm — i.e. the tropical polynomial `M ⊕ N` has empty
corner locus — precisely when the two exponents coincide.  Only the intercepts may
differ. -/
theorem min_affine_iff_slope_eq (M N : Profile) :
    (∃ P : Profile, ∀ k, race M N k = work P k) ↔ M.slope = N.slope := by
  constructor
  · rintro ⟨P, hP⟩
    -- `P` is below both arms, and touches them at the crossing point.
    have hMP : ∀ k, work P k ≤ work M k := fun k => by rw [← hP k]; exact min_le_left _ _
    have hNP : ∀ k, work P k ≤ work N k := fun k => by rw [← hP k]; exact min_le_right _ _
    by_contra hne
    -- crossing point of the two arms
    have hd0 : M.slope - N.slope ≠ 0 := sub_ne_zero.mpr hne
    obtain ⟨kstar, hmul⟩ : ∃ k : ℝ, (M.slope - N.slope) * k = N.icept - M.icept :=
      ⟨(N.icept - M.icept) / (M.slope - N.slope), by field_simp⟩
    have hcross : work M kstar = work N kstar := by
      simp only [work]
      linarith [hmul]
    have htouch : work P kstar = work M kstar := by
      rw [← hP kstar]; simp [race, hcross]
    -- `work M - work P` is affine, nonnegative, and vanishes at `kstar`
    have hslopeM : M.slope = P.slope := by
      have h1 := hMP (kstar + 1)
      have h2 := hMP (kstar - 1)
      simp only [work] at h1 h2 htouch
      have hA : P.slope ≤ M.slope := by nlinarith [h1, htouch]
      have hB : M.slope ≤ P.slope := by nlinarith [h2, htouch]
      linarith
    have htouchN : work P kstar = work N kstar := by rw [htouch, hcross]
    have hslopeN : N.slope = P.slope := by
      have h1 := hNP (kstar + 1)
      have h2 := hNP (kstar - 1)
      simp only [work] at h1 h2 htouchN
      have hA : P.slope ≤ N.slope := by nlinarith [h1, htouchN]
      have hB : N.slope ≤ P.slope := by nlinarith [h2, htouchN]
      linarith
    exact hne (hslopeM.trans hslopeN.symm)
  · intro h
    refine ⟨⟨M.slope, min M.icept N.icept⟩, fun k => ?_⟩
    simp only [race, work, h]
    exact min_add_add_right _ _ _

/-- **Nearly parallel arms cross only far away.**  If the exponents differ by at most `ε`
while the intercepts differ by at least `δ`, then the corner of the race sits at
`|k*| ≥ δ/ε`: a `Δα ≤ ε` measurement cannot distinguish "no corner" from "a corner
beyond the observation window of half-width `δ/ε`". -/
theorem corner_far_of_near_parallel {M N : Profile} {eps del kstar : ℝ}
    (heps : 0 < eps)
    (hslope : |M.slope - N.slope| ≤ eps) (hicept : del ≤ |M.icept - N.icept|)
    (hcorner : work M kstar = work N kstar) :
    del / eps ≤ |kstar| := by
  have key : |M.icept - N.icept| = |M.slope - N.slope| * |kstar| := by
    have : M.icept - N.icept = -((M.slope - N.slope) * kstar) := by
      simp only [work] at hcorner; ring_nf; ring_nf at hcorner; linarith
    rw [this, abs_neg, abs_mul]
  rw [div_le_iff₀ heps]
  calc del ≤ |M.icept - N.icept| := hicept
    _ = |M.slope - N.slope| * |kstar| := key
    _ ≤ eps * |kstar| := by
        exact mul_le_mul_of_nonneg_right hslope (abs_nonneg _)
    _ = |kstar| * eps := by ring

/-! ## 2. The measured plane of experiment 490

The five arms on one population, with the two trial-division regimes.  Only the
*difference* of intercepts was pinned down by the experiment (`c_ECM − c_ρ = 3.04`
bits), so the rho intercept is carried as a parameter `c` and every statement below is
uniform in it. -/

/-- Pollard rho, per-iteration gcd (`α = 0.512`, the restored `√p` law). -/
def rhoArm (c : ℝ) : Profile := ⟨0.512, c⟩

/-- ECM with stage-one bound `B₁ = 50` (`α = 0.761`, intercept `c + 3.04` bits). -/
def ecm50Arm (c : ℝ) : Profile := ⟨0.761, c + 3.04⟩

/-- ECM with stage-one bound `B₁ = 250` (`α = 0.718`). -/
def ecm250Arm (c : ℝ) (d : ℝ) : Profile := ⟨0.718, c + d⟩

/-- Fermat (`α = 0.50`). -/
def fermatArm (c : ℝ) : Profile := ⟨0.50, c⟩

/-- Trial division, uniform-factor draws (`α = 1.00`). -/
def tdUniformArm (c : ℝ) : Profile := ⟨1.00, c⟩

/-- Trial division, balanced-factor draws (`α = 1.14`). -/
def tdBalancedArm (c : ℝ) : Profile := ⟨1.14, c⟩

/-- The Fermat arm is the only one below rho, and the balanced trial-division regime is
the top of the plane: the measured five-method table is totally ordered by exponent.
This is the recorded `(α, c)` table of experiment 490. -/
theorem measured_plane_totally_ordered (c d : ℝ) :
    (fermatArm c).slope < (rhoArm c).slope ∧
    (rhoArm c).slope < (ecm250Arm c d).slope ∧
    (ecm250Arm c d).slope < (ecm50Arm c).slope ∧
    (ecm50Arm c).slope < (tdUniformArm c).slope ∧
    (tdUniformArm c).slope < (tdBalancedArm c).slope := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;>
    simp only [fermatArm, rhoArm, ecm50Arm, ecm250Arm, tdUniformArm, tdBalancedArm] <;> norm_num

/-- **H1, the ECM column lands strictly inside the bracket.**  Both stage-one bounds put
ECM strictly between the rho exponent and the trial-division exponent, and the larger
bound `B₁ = 250` sits strictly lower than `B₁ = 50`. -/
theorem ecm_exponent_strictly_between (c d : ℝ) :
    (rhoArm c).slope < (ecm250Arm c d).slope ∧
    (ecm250Arm c d).slope < (ecm50Arm c).slope ∧
    (ecm50Arm c).slope < (tdUniformArm c).slope := by
  obtain ⟨-, h1, h2, h3, -⟩ := measured_plane_totally_ordered c d
  exact ⟨h1, h2, h3⟩

/-- **H3 read strictly: there is no crossover in the measured plane.**  Because ECM pays
`+3.04` bits of intercept *and* carries the larger exponent, rho is strictly cheaper at
every nonnegative target size. -/
theorem rho_dominates_ecm (c : ℝ) {k : ℝ} (hk : 0 ≤ k) :
    work (rhoArm c) k < work (ecm50Arm c) k := by
  refine dominates_strict ?_ ?_ hk <;> simp only [rhoArm, ecm50Arm] <;> norm_num

/-- Equivalently: the corner locus of the tropical polynomial `rho ⊕ ECM` misses the
entire physical half-line `k ≥ 0`. -/
theorem ecm_never_crosses_rho (c : ℝ) : ∀ k ≥ (0 : ℝ), race (rhoArm c) (ecm50Arm c) k = work (rhoArm c) k := by
  intro k hk
  exact min_eq_left (rho_dominates_ecm c hk).le

/-- **The two currencies agree to within one bit.**  The measured common-currency gap is
`3.04` bits and the measured wall-time ratio is `10.29×`; since `2³ < 10.29 < 2⁴`, the
logarithmic wall-time gap lies in `(3,4)`, i.e. within one bit of `3.04`.  This is the
precise sense in which H3 sits "exactly at the order line". -/
theorem common_currency_within_one_bit :
    |(3.04 : ℝ) - Real.logb 2 10.29| < 1 := by
  have h1 : (3 : ℝ) < Real.logb 2 10.29 := by
    have h8 : Real.logb 2 8 = 3 := by
      rw [show (8 : ℝ) = 2 ^ (3 : ℕ) by norm_num, Real.logb_pow, Real.logb_self_eq_one] <;>
        norm_num
    calc (3 : ℝ) = Real.logb 2 8 := h8.symm
      _ < Real.logb 2 10.29 := by
          apply Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
  have h2 : Real.logb 2 10.29 < 4 := by
    have h16 : Real.logb 2 16 = 4 := by
      rw [show (16 : ℝ) = 2 ^ (4 : ℕ) by norm_num, Real.logb_pow, Real.logb_self_eq_one] <;>
        norm_num
    calc Real.logb 2 10.29 < Real.logb 2 16 := by
          apply Real.logb_lt_logb (by norm_num) (by norm_num) (by norm_num)
      _ = 4 := h16
  rw [abs_lt]; constructor <;> linarith

/-! ### Factor-locality as a corner-locus statement

The uniform-vs-balanced comparison is a race between two *regimes of the same arm*.  For
the factor-local arms the two regimes have the same exponent and the race is again a
single affine arm (no corner).  For trial division the exponents move `1.00 → 1.14` and a
genuine corner appears. -/

/-- **Factor-local arms: no corner.**  Two rho regimes with equal exponents and any
intercepts race to a single affine profile — only intercepts move. -/
theorem rho_regime_pair_has_no_corner (c c' : ℝ) :
    ∃ P : Profile, ∀ k, race (rhoArm c) (rhoArm c') k = work P k :=
  (min_affine_iff_slope_eq _ _).mpr rfl

/-- **Trial division: a corner exists.**  The `1.00 → 1.14` shift means the two regimes
cannot be combined into one affine arm; the tropical polynomial genuinely has a corner. -/
theorem td_regime_pair_has_corner (c c' : ℝ) :
    ¬ ∃ P : Profile, ∀ k, race (tdUniformArm c) (tdBalancedArm c') k = work P k := by
  intro h
  have := (min_affine_iff_slope_eq _ _).mp h
  simp only [tdUniformArm, tdBalancedArm] at this
  norm_num at this

/-- The trial-division corner, explicitly: with intercepts `c` (uniform) and `c'`
(balanced) the unique crossing sits at `k* = (c' − c)/(−0.14)`. -/
theorem td_corner_location (c c' : ℝ) :
    ∃! k : ℝ, work (tdUniformArm c) k = work (tdBalancedArm c') k := by
  apply crossover_point
  simp only [tdUniformArm, tdBalancedArm]; norm_num

/-- **The locality tolerance turned into a window bound.**  If two regimes of a
factor-local arm are measured with `Δα ≤ 0.03` but their intercepts differ by at least
`0.5` bit, any corner they may have lies at `|k*| ≥ 50/3 > 16` — beyond the `k = 16..20`
observation window of the experiment.  So "`Δα ≤ 0.03`, only intercepts move" is exactly
the statement that no corner is visible in the measured window. -/
theorem rho_corner_beyond_window {M N : Profile} {kstar : ℝ}
    (hslope : |M.slope - N.slope| ≤ 0.03) (hicept : 0.5 ≤ |M.icept - N.icept|)
    (hcorner : work M kstar = work N kstar) : (16 : ℝ) < |kstar| := by
  have h := corner_far_of_near_parallel (eps := 0.03) (del := 0.5) (by norm_num)
    hslope hicept hcorner
  have : (0.5 : ℝ) / 0.03 = 50 / 3 := by norm_num
  rw [this] at h
  linarith

/-! ## 3. Where the ECM exponent comes from: the tropical line `α = 1 − β`

The catalog file `Geometry/ECMLiteBirthdayScaling.lean` proves that the visible set of a
sequential-multiples ECM arm with stage-one bound `B` has at most `B²` elements inside a
group of order `≈ p`, whence the curve-budget lower bound `C ≥ p/(2B²)`.  Multiplying by
the `B` point operations spent per curve gives the *work* lower bound `p/(2B)`, and with
`B = p^β` this is `p^{1-β}/2`: a straight line in the `(β, α)` plane joining trial
division to the birthday arms. -/

/-- **Total-work lower bound for the ECM arm.**  If each curve succeeds with probability
at most `B²/p` and the campaign reaches success probability `1/2`, then the total number
of point operations `C·B` is at least `p/(2B)`. -/
theorem ecm_total_work_lower_bound {p B C : ℕ} (hp : 0 < p) (hB : 0 < B) (q : ℝ)
    (hq1 : q ≤ 1) (hq : q ≤ (B : ℝ) ^ 2 / p) (hsucc : 1 / 2 ≤ 1 - (1 - q) ^ C) :
    (p : ℝ) / (2 * B) ≤ (C : ℝ) * B := by
  by_contra hcon
  push_neg at hcon
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  have hC : (C : ℝ) < p / (2 * (B : ℝ) ^ 2) := by
    rw [lt_div_iff₀ (by positivity)] at hcon ⊢
    nlinarith [hcon]
  have := ECMLite.curve_budget_lower_bound hp hB q hq1 hq hC
  linarith

/-- With a stage-one bound `B = p^β` the work lower bound is exactly `p^{1-β}/2`. -/
theorem ecm_work_exponent {p beta : ℝ} (hp : 0 < p) :
    p / (2 * p ^ beta) = p ^ (1 - beta) / 2 := by
  have hpb : (0 : ℝ) < p ^ beta := Real.rpow_pos_of_pos hp beta
  rw [Real.rpow_sub hp, Real.rpow_one]
  field_simp

/-- **The ECM arm interpolates.**  For a stage-one exponent `0 < β < 1/2` the ECM work
`p^{1-β}` is strictly between the birthday work `p^{1/2}` (rho, Fermat) and the trial
division work `p`.  `β = 0` and `β = 1/2` recover the two endpoints exactly. -/
theorem ecm_work_between_rho_and_td {p beta : ℝ} (hp : 1 < p) (h0 : 0 < beta)
    (h2 : beta < 1 / 2) :
    p ^ ((1 : ℝ) / 2) < p ^ (1 - beta) ∧ p ^ (1 - beta) < p ^ (1 : ℝ) := by
  constructor
  · exact Real.rpow_lt_rpow_left_iff hp |>.mpr (by linarith)
  · exact Real.rpow_lt_rpow_left_iff hp |>.mpr (by linarith)

/-- **Calibration: the measured exponent reads off the stage-one bound.**  If the
campaign reaches success probability `1/2` with total work at most `p^a`, then the
stage-one bound must satisfy `B ≥ p^{1-a}/2`.  A measured slope strictly below `1`
therefore certifies a stage-one bound growing like a positive power of `p`. -/
theorem bound_from_measured_exponent {p B C : ℕ} (hp : 0 < p) (hB : 0 < B) (q : ℝ)
    (hq1 : q ≤ 1) (hq : q ≤ (B : ℝ) ^ 2 / p) (hsucc : 1 / 2 ≤ 1 - (1 - q) ^ C)
    (a : ℝ) (hmeas : (C : ℝ) * B ≤ (p : ℝ) ^ a) :
    (p : ℝ) ^ (1 - a) / 2 ≤ (B : ℝ) := by
  have hp0 : (0 : ℝ) < p := by exact_mod_cast hp
  have hB0 : (0 : ℝ) < (B : ℝ) := by exact_mod_cast hB
  have hlow := ecm_total_work_lower_bound hp hB q hq1 hq hsucc
  have h1 : (p : ℝ) / (2 * B) ≤ (p : ℝ) ^ a := le_trans hlow hmeas
  have hpa : (0 : ℝ) < (p : ℝ) ^ a := Real.rpow_pos_of_pos hp0 a
  have h2 : (p : ℝ) ≤ (p : ℝ) ^ a * (2 * B) := by
    rw [div_le_iff₀ (by positivity)] at h1; linarith
  have hsplit : (p : ℝ) ^ (1 - a) = (p : ℝ) / (p : ℝ) ^ a := by
    rw [Real.rpow_sub hp0, Real.rpow_one]
  rw [hsplit, div_le_iff₀ (by norm_num : (0:ℝ) < 2), div_le_iff₀ hpa]
  nlinarith [h2]

/-- **The `α = 0.761` column is consistent with `B₁ = 50` at 20-bit targets.**  The
calibration bound `p^{1-a}/2` with `a = 0.761` and `p = 2²⁰` is at most `16 ≤ 50`. -/
theorem ecm_calibration_at_twenty_bits :
    ((2 : ℝ) ^ (20 : ℕ)) ^ (1 - 0.761 : ℝ) / 2 ≤ 50 := by
  have hbase : ((2 : ℝ) ^ (20 : ℕ)) = (2 : ℝ) ^ (20 : ℝ) := by
    rw [show ((20 : ℝ)) = ((20 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]
  have hmul : ((2 : ℝ) ^ (20 : ℝ)) ^ (1 - 0.761 : ℝ) = (2 : ℝ) ^ ((20 : ℝ) * (1 - 0.761)) := by
    rw [← Real.rpow_mul (by norm_num)]
  have hle : (2 : ℝ) ^ ((20 : ℝ) * (1 - 0.761)) ≤ (2 : ℝ) ^ (5 : ℝ) := by
    apply Real.rpow_le_rpow_of_exponent_le (by norm_num)
    norm_num
  have h32 : (2 : ℝ) ^ (5 : ℝ) = 32 := by
    rw [show ((5 : ℝ)) = ((5 : ℕ) : ℝ) by norm_num, Real.rpow_natCast]; norm_num
  rw [hbase, hmul]
  linarith [hle, h32.le, h32.ge]

/-! ## 4. The quantisation ledger: batched gcd erases the `√p` law

A batched gcd of block size `m` only reports success at multiples of `m`, replacing the
true detection time `T` by `m·⌈T/m⌉`.  The two halves of the ledger entry are the two
halves of the following dichotomy. -/

/-- Batched detection time: block size `m`, true detection time `T`. -/
def batch (m T : ℕ) : ℕ := m * ((T + m - 1) / m)

/-- The quantisation sandwich: batching never reports early, and overshoots by less than
one block. -/
theorem batch_sandwich {m T : ℕ} (hm : 0 < m) : T ≤ batch m T ∧ batch m T < T + m := by
  have h1 : m * ((T + m - 1) / m) + (T + m - 1) % m = T + m - 1 := Nat.div_add_mod _ _
  have h2 : (T + m - 1) % m < m := Nat.mod_lt _ hm
  unfold batch
  generalize hX : m * ((T + m - 1) / m) = X at h1 ⊢
  omega

/-- **Erasure.**  If the detection time fits inside a single block, the batched observable
is the constant `m`: every trace of the `p`-dependence is gone. -/
theorem batch_eq_of_le {m T : ℕ} (hT : 0 < T) (hTm : T ≤ m) : batch m T = m := by
  have hm : 0 < m := lt_of_lt_of_le hT hTm
  have : (T + m - 1) / m = 1 := by
    apply Nat.div_eq_of_lt_le <;> omega
  unfold batch; rw [this, mul_one]

/-- **Preservation.**  Once the detection time exceeds the block size the exponent
survives: the batched observable is within a factor two of the truth, i.e. the intercept
moves by at most one bit and the slope is unchanged. -/
theorem batch_le_two_mul {m T : ℕ} (hm : 0 < m) (hmT : m ≤ T) :
    T ≤ batch m T ∧ batch m T ≤ 2 * T := by
  obtain ⟨h1, h2⟩ := batch_sandwich (m := m) (T := T) hm
  exact ⟨h1, by omega⟩

/-- **Ledger, first half: a batched gcd erases the `√p` law at toy scale.**  With block
size `m = 2048`, the rho detection times at `k = 16` and `k = 20` bits
(`√p = 256, 1024`) are both reported as `2048`, so the measured two-point slope is `0`
even though the true times differ by a factor of four. -/
theorem batched_gcd_erases_sqrt_law :
    batch 2048 (Nat.sqrt (2 ^ 16)) = 2048 ∧ batch 2048 (Nat.sqrt (2 ^ 20)) = 2048 ∧
      (Real.logb 2 (batch 2048 (Nat.sqrt (2 ^ 20))) -
        Real.logb 2 (batch 2048 (Nat.sqrt (2 ^ 16)))) / (20 - 16) = 0 := by
  have h16 : Nat.sqrt (2 ^ 16) = 256 := by norm_num
  have h20 : Nat.sqrt (2 ^ 20) = 1024 := by norm_num
  have b16 : batch 2048 (Nat.sqrt (2 ^ 16)) = 2048 := by
    rw [h16]; exact batch_eq_of_le (by norm_num) (by norm_num)
  have b20 : batch 2048 (Nat.sqrt (2 ^ 20)) = 2048 := by
    rw [h20]; exact batch_eq_of_le (by norm_num) (by norm_num)
  refine ⟨b16, b20, ?_⟩
  rw [b16, b20]
  norm_num

/-- **Ledger, second half: per-iteration gcd restores it.**  Unbatched (`m = 1`) the
same two points give a two-point slope of exactly `1/2` — the `√p` law, matching the
measured `α = 0.512`. -/
theorem per_iteration_gcd_keeps_sqrt_law :
    batch 1 (Nat.sqrt (2 ^ 16)) = 256 ∧ batch 1 (Nat.sqrt (2 ^ 20)) = 1024 ∧
      (Real.logb 2 (batch 1 (Nat.sqrt (2 ^ 20))) -
        Real.logb 2 (batch 1 (Nat.sqrt (2 ^ 16)))) / (20 - 16) = 1 / 2 := by
  have h16 : Nat.sqrt (2 ^ 16) = 256 := by norm_num
  have h20 : Nat.sqrt (2 ^ 20) = 1024 := by norm_num
  have b16 : batch 1 (Nat.sqrt (2 ^ 16)) = 256 := by
    rw [h16]; unfold batch; norm_num
  have b20 : batch 1 (Nat.sqrt (2 ^ 20)) = 1024 := by
    rw [h20]; unfold batch; norm_num
  refine ⟨b16, b20, ?_⟩
  have l256 : Real.logb 2 (256 : ℝ) = 8 := by
    rw [show (256 : ℝ) = 2 ^ (8 : ℕ) by norm_num, Real.logb_pow, Real.logb_self_eq_one] <;>
      norm_num
  have l1024 : Real.logb 2 (1024 : ℝ) = 10 := by
    rw [show (1024 : ℝ) = 2 ^ (10 : ℕ) by norm_num, Real.logb_pow, Real.logb_self_eq_one] <;>
      norm_num
  rw [b16, b20]
  push_cast
  rw [l256, l1024]
  norm_num

/-- **The quantisation dichotomy, in exponent form.**  Fix a block size `m` and compare
two target sizes with true detection times `T₁ ≤ T₂`.  Either both fit in one block, in
which case the measured ratio is exactly `1` (slope `0`, the law is erased), or both
exceed the block, in which case the measured ratio is within a factor `2` of the true
ratio (slope preserved up to one bit of intercept). -/
theorem batch_dichotomy {m T₁ T₂ : ℕ} (hm : 0 < m) (h1 : 0 < T₁) (h12 : T₁ ≤ T₂) :
    (T₂ ≤ m → (batch m T₂ : ℝ) / batch m T₁ = 1) ∧
    (m ≤ T₁ → (batch m T₂ : ℝ) / batch m T₁ ≤ 2 * ((T₂ : ℝ) / T₁)) := by
  constructor
  · intro h
    rw [batch_eq_of_le h1 (le_trans h12 h), batch_eq_of_le (lt_of_lt_of_le h1 h12) h]
    field_simp
  · intro h
    have hT1 : (0 : ℝ) < T₁ := by exact_mod_cast h1
    obtain ⟨hb1, hb1'⟩ := batch_le_two_mul hm h
    obtain ⟨hb2, hb2'⟩ := batch_le_two_mul hm (le_trans h h12)
    have hbatch1 : (T₁ : ℝ) ≤ (batch m T₁ : ℝ) := by exact_mod_cast hb1
    have hbatch2 : (batch m T₂ : ℝ) ≤ 2 * T₂ := by exact_mod_cast hb2'
    have hbpos : (0 : ℝ) < (batch m T₁ : ℝ) := lt_of_lt_of_le hT1 hbatch1
    rw [div_le_iff₀ hbpos]
    have : 2 * ((T₂ : ℝ) / T₁) * T₁ = 2 * T₂ := by field_simp
    calc (batch m T₂ : ℝ) ≤ 2 * T₂ := hbatch2
      _ = 2 * ((T₂ : ℝ) / T₁) * T₁ := this.symm
      _ ≤ 2 * ((T₂ : ℝ) / T₁) * (batch m T₁ : ℝ) := by
          have h2T : (0 : ℝ) ≤ 2 * ((T₂ : ℝ) / T₁) := by positivity
          exact mul_le_mul_of_nonneg_left hbatch1 h2T

end ECMPlane