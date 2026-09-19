import Mathlib

/-!
# The sub-exponential stratum: a rigorous Dickman tail and an unconditional `L[1/2]` cost floor

Context (FACT round-26 #3, "SUBEXP-STRATUM", paper 90).  The round-26 experiment
tried to *measure* the fourth complexity stratum (sub-exponential sieves) at toy
scale and failed: with 2400 samples over six `(N, B)` cells the empirical
smooth-density / `ρ(u)` ratios scattered non-monotonically between `0.26` and
`9.3`, every bin underpowered at `±σ ≈ 100 %` relative, and the fitted cost
exponent `d(log₂ C)/d(log₂ N) = 0.024` was flat.  Two facts survived the null:

1. the *leading-term* Dickman surrogate `L(u) = exp(-u(log u + log log u - 1))`
   is quantitatively meaningless at the reachable `u` (a `12 ×` overshoot at
   `u = 3`), and
2. the smoothness of `x^2 - N` is not the smoothness of a random integer at toy
   scale.

The catalog already contains the `u ≤ 2` half of (1) (`Shared.DickmanFiniteCorrection`,
which computes `ρ` in closed form on `(1,2]` and proves a factor-`9` overshoot at
`u = 2`) and the first-moment half of (2) (`Shared.QSRelationPoolRandom`).  This
file pushes past both obstructions in the `u > 2` range, where no closed form for
`ρ` exists, by working with the *delay inequality* instead of the delay equation.

## Design: an upper class instead of the Dickman function itself

Mathlib has no Dickman function, and constructing it requires solving a delay
ODE.  We therefore isolate only what an *upper bound* argument needs:

`DickmanUpper ρ` : `ρ ≥ 0`, `ρ = 1` on `[0,1]`, `ρ` antitone on `[0,∞)`, and the
one-sided delay inequality `u · ρ u ≤ ∫_{u-1}^{u} ρ` for `u ≥ 1`.

The true Dickman function satisfies these with equality in the last clause, so
every bound proved here applies to it.  Crucially the class is **non-vacuous and
provably so**: `dickmanUpper_step_witness` exhibits an explicit member, so none
of the statements below is conditionally empty.

## Main results

* `DickmanUpper.step` — `ρ u ≤ ρ (u-1) / u` for `u ≥ 1`: the delay inequality
  turned into a contraction, via antitone integrability.
* `DickmanUpper.natCast_le_inv_factorial` — `ρ n ≤ 1 / n !`.
* `DickmanUpper.le_inv_factorial_floor` — `ρ u ≤ 1 / ⌊u⌋₊!` for all `u ≥ 0`.
* `log_three_lt`, `dickmanLead_three_gt` — the numerics: `log 3 < 1.1` and
  `L(3) > 0.54`.
* `dickmanLead_three_gt_five_mul_rho` — **the leading term overshoots by more
  than a factor `5` at `u = 3`** (the measured factor is `12`; `5` is what the
  rigorous tail bound `ρ 3 ≤ (1 - log 2)/3` can certify).
* `dickmanLead_four_gt_rho` — the overshoot persists at `u = 4`.
* `pow_self_le_factorial_mul_exp`, `DickmanUpper.le_exp_shape` — the `u^{-u}`
  *shape* of the surrogate is nevertheless rigorously correct:
  `ρ u ≤ exp (-⌊u⌋₊ (log ⌊u⌋₊ - 1)) = (e/⌊u⌋₊)^⌊u⌋₊`.
* `two_pow_le_factorial`, `sqrt_amgm_cost`, `cost_floor_model`,
  `DickmanUpper.cost_floor` — **the `L[1/2]` floor**: for the toy cost model
  `C(b) = e^b / ρ(L/b)` of a sieve with factor-base cut `B = e^b` on values of
  size `e^L`, every choice of `b` obeys
  `C(b) ≥ exp (2 √(L log 2) - 2 log 2)`.
  The experiment could not place the stratum empirically; this places its floor
  by proof, and the `√L` in the exponent is exactly the `L[1/2]` shape.
* `mul_log_sub_one_ge`, `cost_floor_model_sharp`, `cost_floor_model_sqrt_log` —
  the sharpened floor obtained from `n! ≥ (n/e)^n` through the Legendre transform
  of `x log x`: the model cost exponent is at least `2√(lL) - e^l` for every `l`,
  hence at least `√(2 L log L) - √L`, the `L[1/2]` shape with the correct
  logarithmic factor.
-/

namespace SubexpStratum

open Real Filter Topology

/-! ## The upper class for the Dickman function -/

/-- An upper envelope class for the Dickman function: non-negative, equal to `1`
on `[0,1]`, antitone, and satisfying the *one-sided* delay inequality
`u · ρ u ≤ ∫_{u-1}^u ρ`.  The Dickman function itself is a member (its delay
relation is an equality); `dickmanUpper_step_witness` shows the class is
non-empty unconditionally. -/
structure DickmanUpper (ρ : ℝ → ℝ) : Prop where
  nonneg : ∀ u, 0 ≤ ρ u
  unit : ∀ u, 0 ≤ u → u ≤ 1 → ρ u = 1
  anti : AntitoneOn ρ (Set.Ici (0 : ℝ))
  delay_le : ∀ u : ℝ, 1 ≤ u → u * ρ u ≤ ∫ t in (u - 1)..u, ρ t

/-- The class is non-vacuous: the indicator of `[0,1]` belongs to it.  (At `u = 1`
the delay inequality is an equality `1 = ∫_0^1 1`, so the witness is tight
exactly where it has to be.) -/
theorem dickmanUpper_step_witness :
    DickmanUpper (fun u => if u ≤ 1 then (1 : ℝ) else 0) := by
  constructor
  · intro u; dsimp only; split <;> norm_num
  · intro u _ hu; simp [hu]
  · intro a _ b _ hab
    dsimp only
    split_ifs with h1 h2 h2
    · exact le_rfl
    · exact absurd (le_trans hab h1) h2
    · norm_num
    · exact le_rfl
  · intro u hu
    have hnonneg : (0 : ℝ) ≤ ∫ t in (u - 1)..u, (if t ≤ 1 then (1 : ℝ) else 0) := by
      apply intervalIntegral.integral_nonneg (by linarith)
      intro t _
      dsimp only
      split <;> norm_num
    rcases eq_or_lt_of_le hu with h | h
    · -- `u = 1`: the integral is exactly `1`
      subst h
      have hcongr : (∫ t in ((1 : ℝ) - 1)..1, (if t ≤ 1 then (1 : ℝ) else 0))
          = ∫ _t in ((1 : ℝ) - 1)..1, (1 : ℝ) := by
        apply intervalIntegral.integral_congr
        intro t ht
        rw [Set.uIcc_of_le (by norm_num)] at ht
        simp only [Set.mem_Icc] at ht
        simp [ht.2]
      rw [hcongr]
      norm_num
    · have : ¬ (u ≤ 1) := not_le.2 h
      simpa [this] using hnonneg

/-- The explicit witness also satisfies the extra hypothesis `ρ 2 ≤ 1 - log 2`
used below, so the theorems carrying that hypothesis are not vacuous either. -/
theorem witness_rho_two_le :
    (fun u => if u ≤ 1 then (1 : ℝ) else 0) 2 ≤ 1 - Real.log 2 := by
  have h : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  norm_num
  linarith

namespace DickmanUpper

variable {ρ : ℝ → ℝ}

/-- Integrability on any interval inside `[0,∞)`, from antitonicity. -/
theorem integrable (hρ : DickmanUpper ρ) {a b : ℝ} (ha : 0 ≤ a) (hab : a ≤ b) :
    IntervalIntegrable ρ MeasureTheory.volume a b := by
  apply AntitoneOn.intervalIntegrable
  apply hρ.anti.mono
  rw [Set.uIcc_of_le hab]
  exact fun t ht => le_trans ha ht.1

/-- **The contraction step.**  The delay inequality plus antitonicity give
`ρ u ≤ ρ (u-1) / u`. -/
theorem step (hρ : DickmanUpper ρ) {u : ℝ} (hu : 1 ≤ u) : ρ u ≤ ρ (u - 1) / u := by
  have hu0 : (0 : ℝ) < u := lt_of_lt_of_le one_pos hu
  have hint : (∫ t in (u - 1)..u, ρ t) ≤ ρ (u - 1) := by
    have hle : (∫ t in (u - 1)..u, ρ t) ≤ ∫ _t in (u - 1)..u, ρ (u - 1) := by
      apply intervalIntegral.integral_mono_on (by linarith)
        (hρ.integrable (by linarith) (by linarith)) intervalIntegrable_const
      intro t ht
      obtain ⟨ht1, ht2⟩ := ht
      exact hρ.anti (Set.mem_Ici.2 (by linarith)) (Set.mem_Ici.2 (by linarith)) ht1
    simpa using hle
  have hd := hρ.delay_le u hu
  rw [le_div_iff₀ hu0]
  nlinarith

/-- `ρ n ≤ 1 / n !` for every natural `n`: super-exponential decay of the
Dickman tail, obtained by iterating the contraction step. -/
theorem natCast_le_inv_factorial (hρ : DickmanUpper ρ) (n : ℕ) :
    ρ n ≤ 1 / (Nat.factorial n : ℝ) := by
  induction n with
  | zero => simpa using le_of_eq (hρ.unit 0 le_rfl zero_le_one)
  | succ n ih =>
      have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
      have hstep : ρ ((n : ℝ) + 1) ≤ ρ ((n : ℝ) + 1 - 1) / ((n : ℝ) + 1) :=
        hρ.step (by linarith)
      rw [show ((n : ℝ) + 1 - 1) = (n : ℝ) by ring] at hstep
      have hfac : (0 : ℝ) < (Nat.factorial n : ℝ) := by
        exact_mod_cast n.factorial_pos
      have hmono : ρ (n : ℝ) / ((n : ℝ) + 1) ≤ (1 / (Nat.factorial n : ℝ)) / ((n : ℝ) + 1) := by
        gcongr
      have hval : (1 / (Nat.factorial n : ℝ)) / ((n : ℝ) + 1)
          = 1 / (Nat.factorial (n + 1) : ℝ) := by
        rw [Nat.factorial_succ]
        push_cast
        field_simp
      calc ρ ((n + 1 : ℕ) : ℝ) = ρ ((n : ℝ) + 1) := by push_cast; ring_nf
        _ ≤ (1 / (Nat.factorial n : ℝ)) / ((n : ℝ) + 1) := le_trans hstep hmono
        _ = 1 / (Nat.factorial (n + 1) : ℝ) := hval

/-- `ρ u ≤ 1 / ⌊u⌋₊!` for every `u ≥ 0`. -/
theorem le_inv_factorial_floor (hρ : DickmanUpper ρ) {u : ℝ} (hu : 0 ≤ u) :
    ρ u ≤ 1 / (Nat.factorial ⌊u⌋₊ : ℝ) := by
  have hfl : ((⌊u⌋₊ : ℕ) : ℝ) ≤ u := Nat.floor_le hu
  have h1 : ρ u ≤ ρ ((⌊u⌋₊ : ℕ) : ℝ) :=
    hρ.anti (Set.mem_Ici.2 (by positivity)) (Set.mem_Ici.2 hu) hfl
  exact h1.trans (hρ.natCast_le_inv_factorial _)

end DickmanUpper

/-! ## Numerical lemmas -/

theorem log_three_lt : Real.log 3 < 1.1 := by
  have he : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
  have h01 : (1.01 : ℝ) < Real.exp 0.01 := by
    have := Real.add_one_lt_exp (x := (0.01 : ℝ)) (by norm_num)
    linarith
  have hexp : Real.exp (0.1 : ℝ) = (Real.exp 0.01) ^ (10 : ℕ) := by
    rw [← Real.exp_nat_mul]; norm_num
  have h1 : (1.1046 : ℝ) < Real.exp 0.1 := by
    rw [hexp]
    calc (1.1046 : ℝ) < (1.01 : ℝ) ^ (10 : ℕ) := by norm_num
      _ < (Real.exp 0.01) ^ (10 : ℕ) := by gcongr
  have h11 : Real.exp 1.1 = Real.exp 1 * Real.exp 0.1 := by
    rw [← Real.exp_add]; norm_num
  have h3 : (3 : ℝ) < Real.exp 1.1 := by
    rw [h11]
    nlinarith [Real.exp_pos (1 : ℝ), Real.exp_pos (0.1 : ℝ)]
  calc Real.log 3 < Real.log (Real.exp 1.1) := Real.log_lt_log (by norm_num) h3
    _ = 1.1 := Real.log_exp _

/-- The leading-term Dickman surrogate, as in `Shared.DickmanFiniteCorrection`. -/
noncomputable def dickmanLead (u : ℝ) : ℝ :=
  Real.exp (-u * (Real.log u + Real.log (Real.log u) - 1))

theorem exp_neg_six_tenths_gt : (0.54 : ℝ) < Real.exp (-0.6) := by
  have h : (0.95 : ℝ) ≤ Real.exp (-0.05) := by
    have := Real.add_one_le_exp (x := (-0.05 : ℝ))
    linarith
  have hexp : Real.exp (-0.6 : ℝ) = (Real.exp (-0.05)) ^ (12 : ℕ) := by
    rw [← Real.exp_nat_mul]; norm_num
  rw [hexp]
  calc (0.54 : ℝ) < (0.95 : ℝ) ^ (12 : ℕ) := by norm_num
    _ ≤ (Real.exp (-0.05)) ^ (12 : ℕ) := by gcongr

theorem dickmanLead_three_gt : (0.54 : ℝ) < dickmanLead 3 := by
  have hl3 : (1 : ℝ) < Real.log 3 := by
    have h : Real.log (Real.exp 1) < Real.log 3 :=
      Real.log_lt_log (Real.exp_pos 1) (by nlinarith [Real.exp_one_lt_d9])
    simpa using h
  have hl3' : Real.log 3 < 1.1 := log_three_lt
  have hll : Real.log (Real.log 3) ≤ Real.log 3 - 1 :=
    Real.log_le_sub_one_of_pos (by linarith)
  have hexp : Real.exp (-0.6) < dickmanLead 3 := by
    apply Real.exp_lt_exp.2
    linarith
  linarith [exp_neg_six_tenths_gt]

/-! ## The leading term overshoots at `u = 3` and `u = 4` -/

/-- The rigorous tail value at `u = 3`, from one contraction step off the exact
value `ρ 2 = 1 - log 2` (the closed form proved in `DickmanFiniteCorrection`,
here carried as a hypothesis so that the statement stays inside the upper
class; the explicit witness of `dickmanUpper_step_witness` also satisfies it). -/
theorem rho_three_le {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ) (h2 : ρ 2 ≤ 1 - Real.log 2) :
    ρ 3 ≤ (1 - Real.log 2) / 3 := by
  have hstep := hρ.step (u := (3 : ℝ)) (by norm_num)
  norm_num at hstep
  linarith

theorem rho_four_le {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ) (h2 : ρ 2 ≤ 1 - Real.log 2) :
    ρ 4 ≤ (1 - Real.log 2) / 12 := by
  have hstep := hρ.step (u := (4 : ℝ)) (by norm_num)
  norm_num at hstep
  have h3 := rho_three_le hρ h2
  linarith

/-- **Finding 1, made rigorous at `u = 3`.**  The leading-term surrogate exceeds
five times the true Dickman value at `u = 3`.  (The measured overshoot is `12 ×`;
`5` is the part certified by the tail bound `ρ 3 ≤ (1 - log 2)/3`.) -/
theorem dickmanLead_three_gt_five_mul_rho {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ)
    (h2 : ρ 2 ≤ 1 - Real.log 2) : 5 * ρ 3 < dickmanLead 3 := by
  have h3 := rho_three_le hρ h2
  have hlog : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  linarith [dickmanLead_three_gt]

theorem dickmanLead_four_gt : (0.038 : ℝ) < dickmanLead 4 := by
  have hl2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hl2' : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have hl4 : Real.log 4 = 2 * Real.log 2 := by
    rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
  have hl4' : (1 : ℝ) < Real.log 4 := by rw [hl4]; linarith
  have hll : Real.log (Real.log 4) ≤ Real.log 4 - 1 :=
    Real.log_le_sub_one_of_pos (by linarith)
  have hexp : Real.exp (-3.1) ≤ dickmanLead 4 := by
    apply Real.exp_le_exp.2
    rw [hl4] at hll ⊢
    linarith
  have h : (0.9 : ℝ) ≤ Real.exp (-0.1) := by
    have := Real.add_one_le_exp (x := (-0.1 : ℝ)); linarith
  have hexp' : Real.exp (-3.1 : ℝ) = (Real.exp (-0.1)) ^ (31 : ℕ) := by
    rw [← Real.exp_nat_mul]; norm_num
  have hlow : (0.038 : ℝ) < Real.exp (-3.1) := by
    rw [hexp']
    calc (0.038 : ℝ) < (0.9 : ℝ) ^ (31 : ℕ) := by norm_num
      _ ≤ (Real.exp (-0.1)) ^ (31 : ℕ) := by gcongr
  linarith

/-- The overshoot persists at `u = 4`: the surrogate is still strictly above the
true value, as the experiment reported through `u ≈ 6`. -/
theorem dickmanLead_four_gt_rho {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ)
    (h2 : ρ 2 ≤ 1 - Real.log 2) : ρ 4 < dickmanLead 4 := by
  have h4 := rho_four_le hρ h2
  have hlog : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  linarith [dickmanLead_four_gt]

/-! ## The shape of the rigorous tail: `ρ(u) ≤ (e/n)^n` -/

/-- The elementary Stirling-type inequality `n^n ≤ n! · e^n`, proved by induction
from `(1 + 1/n)^n ≤ e`. -/
theorem pow_self_le_factorial_mul_exp (n : ℕ) :
    (n : ℝ) ^ n ≤ (Nat.factorial n : ℝ) * Real.exp n := by
  induction n with
  | zero => simp
  | succ n ih =>
      have hkey : ((n : ℝ) + 1) ^ n ≤ (Nat.factorial n : ℝ) * Real.exp n * Real.exp 1 := by
        rcases Nat.eq_zero_or_pos n with hn | hn
        · subst hn
          simp only [Nat.cast_zero, pow_zero, Nat.factorial_zero, Nat.cast_one, one_mul,
            Real.exp_zero]
          nlinarith [Real.add_one_le_exp (x := (1 : ℝ)), Real.exp_pos (1 : ℝ)]
        · have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
          have hfrac : ((1 : ℝ) + 1 / (n : ℝ)) ^ n ≤ Real.exp 1 := by
            have h1 : (1 : ℝ) + 1 / (n : ℝ) ≤ Real.exp (1 / (n : ℝ)) := by
              have := Real.add_one_le_exp (x := 1 / (n : ℝ)); linarith
            calc ((1 : ℝ) + 1 / (n : ℝ)) ^ n ≤ (Real.exp (1 / (n : ℝ))) ^ n := by
                  gcongr
              _ = Real.exp 1 := by
                  rw [← Real.exp_nat_mul]
                  field_simp
          have hsplit : ((n : ℝ) + 1) ^ n = (n : ℝ) ^ n * ((1 : ℝ) + 1 / (n : ℝ)) ^ n := by
            rw [← mul_pow]
            congr 1
            field_simp
          rw [hsplit]
          have hnn : (0 : ℝ) ≤ (n : ℝ) ^ n := by positivity
          have hfr0 : (0 : ℝ) ≤ ((1 : ℝ) + 1 / (n : ℝ)) ^ n := by positivity
          calc (n : ℝ) ^ n * ((1 : ℝ) + 1 / (n : ℝ)) ^ n
              ≤ ((Nat.factorial n : ℝ) * Real.exp n) * Real.exp 1 := by
                apply mul_le_mul ih hfrac hfr0 (by positivity)
            _ = (Nat.factorial n : ℝ) * Real.exp n * Real.exp 1 := by ring
      have hcast : ((n + 1 : ℕ) : ℝ) = (n : ℝ) + 1 := by push_cast; ring
      have hfac : (Nat.factorial (n + 1) : ℝ) = ((n : ℝ) + 1) * (Nat.factorial n : ℝ) := by
        rw [Nat.factorial_succ]; push_cast; ring
      rw [hcast, hfac, Real.exp_add, pow_succ]
      nlinarith [hkey, Real.exp_pos ((n : ℝ)), Real.exp_pos (1 : ℝ)]

/-- **The shape of the tail is right even though the leading term's value is
not.**  For `u ≥ 1` the Dickman upper class obeys `ρ u ≤ (e/n)^n` with
`n = ⌊u⌋₊`, i.e. `ρ u ≤ exp (-n (log n - 1))`: the `u^{-u}` shape that the
leading-term surrogate encodes is rigorously correct, while (by
`dickmanLead_three_gt_five_mul_rho`) its numerical value at reachable `u` is
not. -/
theorem DickmanUpper.le_exp_shape {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ) {u : ℝ} (hu : 1 ≤ u) :
    ρ u ≤ Real.exp (-((⌊u⌋₊ : ℝ) * (Real.log (⌊u⌋₊ : ℝ) - 1))) := by
  set n : ℕ := ⌊u⌋₊ with hn_def
  have hn1 : 1 ≤ n := (Nat.one_le_floor_iff u).2 hu
  have hn0 : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn1
  have hfacpos : (0 : ℝ) < (Nat.factorial n : ℝ) := by exact_mod_cast n.factorial_pos
  have hbound : ρ u ≤ 1 / (Nat.factorial n : ℝ) := hρ.le_inv_factorial_floor (by linarith)
  have hstir : (n : ℝ) ^ n ≤ (Nat.factorial n : ℝ) * Real.exp n := pow_self_le_factorial_mul_exp n
  have hpow : Real.exp ((n : ℝ) * Real.log (n : ℝ)) = (n : ℝ) ^ n := by
    rw [← Real.log_pow]
    exact Real.exp_log (by positivity)
  have hexpr : Real.exp (-((n : ℝ) * (Real.log (n : ℝ) - 1))) = Real.exp n / (n : ℝ) ^ n := by
    rw [← hpow, ← Real.exp_sub]
    congr 1
    ring
  rw [hexpr]
  rw [le_div_iff₀ (by positivity)]
  have h1 : ρ u * (n : ℝ) ^ n ≤ (1 / (Nat.factorial n : ℝ)) * ((Nat.factorial n : ℝ) * Real.exp n) := by
    apply mul_le_mul hbound hstir (by positivity) (by positivity)
  calc ρ u * (n : ℝ) ^ n ≤ (1 / (Nat.factorial n : ℝ)) * ((Nat.factorial n : ℝ) * Real.exp n) := h1
    _ = Real.exp n := by field_simp

/-! ## The `L[1/2]` cost floor -/

/-- `2 ^ n ≤ (n+1)!`. -/
theorem two_pow_le_factorial (n : ℕ) : 2 ^ n ≤ Nat.factorial (n + 1) := by
  induction n with
  | zero => simp [Nat.factorial]
  | succ n ih =>
      calc 2 ^ (n + 1) = 2 * 2 ^ n := by ring
        _ ≤ (n + 2) * 2 ^ n := Nat.mul_le_mul_right _ (by omega)
        _ ≤ (n + 2) * Nat.factorial (n + 1) := Nat.mul_le_mul_left _ ih
        _ = Nat.factorial (n + 2) := (Nat.factorial_succ (n + 1)).symm

/-- AM–GM in the form needed for the cost trade-off: `2√c ≤ b + c/b`. -/
theorem sqrt_amgm_cost {b c : ℝ} (hb : 0 < b) (hc : 0 ≤ c) :
    2 * Real.sqrt c ≤ b + c / b := by
  have hs : Real.sqrt c ^ 2 = c := Real.sq_sqrt hc
  rw [← sub_nonneg]
  have key : b + c / b - 2 * Real.sqrt c = (b - Real.sqrt c) ^ 2 / b := by
    field_simp
    nlinarith [hs]
  rw [key]
  positivity

/-- The pure model floor: for the toy sieve cost exponent `b + (u-2) log 2` with
`u = L/b` (`B = e^b` the factor-base cut, values of size `e^L`), every `b` obeys
the `L[1/2]` bound. -/
theorem cost_floor_model {L b : ℝ} (hL : 0 ≤ L) (hb : 0 < b) :
    2 * Real.sqrt (L * Real.log 2) - 2 * Real.log 2
      ≤ b + (L / b - 2) * Real.log 2 := by
  have hc : (0 : ℝ) ≤ L * Real.log 2 := by
    have : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
    positivity
  have h := sqrt_amgm_cost (b := b) (c := L * Real.log 2) hb hc
  have hdiv : L * Real.log 2 / b = (L / b) * Real.log 2 := by ring
  rw [hdiv] at h
  linarith

/-- **The stratum floor.**  For any member of the Dickman upper class with
`ρ(L/b) > 0`, the toy cost `C(b) = e^b / ρ(L/b)` of a sieve with factor-base
parameter `b = log B` on values of size `e^L` satisfies the sub-exponential
lower bound `C(b) ≥ exp (2√(L log 2) - 2 log 2)` — uniformly in `b`.  This is the
`L[1/2]` shape that the toy-scale measurement could not resolve. -/
theorem DickmanUpper.cost_floor {ρ : ℝ → ℝ} (hρ : DickmanUpper ρ) {L b : ℝ}
    (hb : 0 < b) (hbL : b ≤ L) (hpos : 0 < ρ (L / b)) :
    Real.exp (2 * Real.sqrt (L * Real.log 2) - 2 * Real.log 2)
      ≤ Real.exp b / ρ (L / b) := by
  set u : ℝ := L / b with hu_def
  have hL : 0 < L := lt_of_lt_of_le hb hbL
  have hu1 : 1 ≤ u := (one_le_div hb).2 hbL
  have hu0 : 0 ≤ u := by linarith
  set n : ℕ := ⌊u⌋₊ with hn_def
  have hn1 : 1 ≤ n := (Nat.one_le_floor_iff u).2 hu1
  have hfac : ρ u ≤ 1 / (Nat.factorial n : ℝ) := hρ.le_inv_factorial_floor hu0
  obtain ⟨m, hm⟩ : ∃ m : ℕ, n = m + 1 := ⟨n - 1, by omega⟩
  have hpow : (2 : ℝ) ^ m ≤ (Nat.factorial n : ℝ) := by
    have h := two_pow_le_factorial m
    rw [hm]
    exact_mod_cast h
  have hmu : u - 2 ≤ (m : ℝ) := by
    have h1 : u < (n : ℝ) + 1 := Nat.lt_floor_add_one u
    have h2 : ((m : ℝ) + 1) = (n : ℝ) := by rw [hm]; push_cast; ring
    linarith
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h2m : Real.exp ((u - 2) * Real.log 2) ≤ (2 : ℝ) ^ m := by
    have hrw : ((2 : ℝ)) ^ m = Real.exp ((m : ℝ) * Real.log 2) := by
      rw [← Real.log_pow, Real.exp_log (by positivity)]
    rw [hrw]
    exact Real.exp_le_exp.2 (by nlinarith)
  have hstep : Real.exp (b + (u - 2) * Real.log 2) ≤ Real.exp b / ρ u := by
    rw [Real.exp_add, le_div_iff₀ hpos]
    have hfacpos : (0 : ℝ) < (Nat.factorial n : ℝ) := by exact_mod_cast n.factorial_pos
    have hkey : ρ u * Real.exp ((u - 2) * Real.log 2) ≤ 1 := by
      have h3 : (0 : ℝ) < Real.exp ((u - 2) * Real.log 2) := Real.exp_pos _
      calc ρ u * Real.exp ((u - 2) * Real.log 2)
          ≤ (1 / (Nat.factorial n : ℝ)) * (Nat.factorial n : ℝ) := by
            apply mul_le_mul hfac (le_trans h2m hpow) h3.le (by positivity)
        _ = 1 := by field_simp
    nlinarith [Real.exp_pos b, hkey]
  have hfloor := cost_floor_model (L := L) (b := b) hL.le hb
  have hmono : Real.exp (2 * Real.sqrt (L * Real.log 2) - 2 * Real.log 2)
      ≤ Real.exp (b + (u - 2) * Real.log 2) := Real.exp_le_exp.2 (by rw [hu_def]; linarith)
  linarith [hstep]

/-! ## A sharper model floor, via the Legendre transform of `x log x`

The floor above spends the factorial on `n! ≥ 2^{n-1}`.  Using instead
`n! ≥ (n/e)^n` (`pow_self_le_factorial_mul_exp`) the model cost exponent becomes
`b + u (log u - 1)` with `u = L/b`, whose infimum has no closed form.  The
Legendre transform `u (log u - 1) = sup_l (l u - e^l)` turns it into a family of
closed-form floors, one per `l`, all of them tight at `u = e^l`; taking
`l = (log L)/2` produces the `√(L log L)` shape of the classical
`L[1/2]` running time.  Linking this sharper floor back to `ρ` through the floor
function `⌊·⌋₊` costs an `O(1)` shift and is left open. -/

/-- The Legendre/Young inequality `u (log u - 1) ≥ l u - e^l`, tight at
`u = e^l`. -/
theorem mul_log_sub_one_ge {u : ℝ} (hu : 0 < u) (l : ℝ) :
    l * u - Real.exp l ≤ u * (Real.log u - 1) := by
  set t : ℝ := u / Real.exp l with ht_def
  have hexp : (0 : ℝ) < Real.exp l := Real.exp_pos l
  have ht : 0 < t := by positivity
  have hkey : t - 1 ≤ t * Real.log t := by
    have h := Real.log_le_sub_one_of_pos (x := 1 / t) (by positivity)
    rw [one_div, Real.log_inv] at h
    have h' : -Real.log t ≤ 1 / t - 1 := by simpa [one_div] using h
    have := mul_le_mul_of_nonneg_left h' ht.le
    field_simp at this
    nlinarith [this]
  have hu_eq : u = t * Real.exp l := by
    rw [ht_def]
    field_simp
  have hlog : Real.log u = Real.log t + l := by
    rw [hu_eq, Real.log_mul (ne_of_gt ht) (ne_of_gt hexp), Real.log_exp]
  rw [hlog, hu_eq]
  nlinarith [hkey, hexp, ht]

/-- **The sharpened model floor.**  For every `l` and every factor-base parameter
`b > 0`, the cost exponent `b + u (log u - 1)` with `u = L/b` is at least
`2 √(l L) - e^l`.  With `l = (log L)/2` this is `√(2 L log L) - √L`, the
`L[1/2]` shape with the correct logarithmic factor. -/
theorem cost_floor_model_sharp {L b l : ℝ} (hL : 0 < L) (hb : 0 < b) (hl : 0 ≤ l) :
    2 * Real.sqrt (l * L) - Real.exp l ≤ b + (L / b) * (Real.log (L / b) - 1) := by
  have hu : 0 < L / b := by positivity
  have hyoung := mul_log_sub_one_ge hu l
  have hamgm : 2 * Real.sqrt (l * L) ≤ b + l * L / b :=
    sqrt_amgm_cost hb (by positivity)
  have hrw : l * L / b = l * (L / b) := by ring
  rw [hrw] at hamgm
  linarith

/-- The concrete choice `l = (log L)/2` in `cost_floor_model_sharp`: for `L ≥ 1`
the model cost exponent is at least `√(2 L log L) - √L`. -/
theorem cost_floor_model_sqrt_log {L b : ℝ} (hL : 1 ≤ L) (hb : 0 < b) :
    Real.sqrt (2 * (L * Real.log L)) - Real.sqrt L
      ≤ b + (L / b) * (Real.log (L / b) - 1) := by
  have hL0 : 0 < L := lt_of_lt_of_le one_pos hL
  have hlog : 0 ≤ Real.log L := Real.log_nonneg hL
  have hmain := cost_floor_model_sharp (L := L) (b := b) (l := Real.log L / 2) hL0 hb
    (by linarith)
  have hexp : Real.exp (Real.log L / 2) = Real.sqrt L := by
    rw [Real.sqrt_eq_rpow, Real.rpow_def_of_pos hL0]
    ring_nf
  have hsq : 2 * Real.sqrt (Real.log L / 2 * L) = Real.sqrt (2 * (L * Real.log L)) := by
    rw [show (2 : ℝ) * Real.sqrt (Real.log L / 2 * L)
        = Real.sqrt 4 * Real.sqrt (Real.log L / 2 * L) by
      rw [show Real.sqrt 4 = 2 by
        rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]],
      ← Real.sqrt_mul (by norm_num)]
    congr 1
    ring
  rw [hexp, hsq] at hmain
  exact hmain

end SubexpStratum