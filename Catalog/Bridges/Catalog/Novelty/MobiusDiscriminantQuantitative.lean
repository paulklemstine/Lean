import Mathlib

/-!
# The Möbius discriminant, quantitatively: exact identities and the
  boundary of the coefficient-only law

The previous cycle (`HoggattTrichotomy.lean`) isolated the scalar **Möbius
discriminant** `Δ = γβ − αδ` attached to a first-order multiplicative
recurrence `(α n + β)·a(n+1) = (γ n + δ)·a(n)` and proved that its *sign*
governs the log-behaviour of the sequence (strict log-convexity / log-linearity
/ strict log-concavity).

This cycle upgrades the *sign* law to *exact quantitative* identities, and then
probes the boundary of the theory in the contrarian spirit by **disproving** the
naive second-order generalization.

## Conjecture A — Quantitative discriminant law  (**PROVED**)

For a sequence obeying the recurrence, the pointwise discriminant
`D(n) = a(n)·a(n+2) − a(n+1)²` satisfies the *exact* identity

  `(α n + β)·(α (n+1) + β)·D(n) = Δ · a(n)·a(n+1)`   (`discriminant_exact`)

so `D(n)` is a fixed multiple of `Δ` at every index and its sign never
flips (`discriminant_sign_pos` / `_zero` / `_neg`).  (The description in the
research brief carried a typo in the right-hand side; the clean exact form is
the one above and is what we prove.)

## The Möbius ratio has forward difference with constant numerator `Δ`  (**PROVED**)

  `a(n+2)/a(n+1) − a(n+1)/a(n) = Δ / ((α n + β)·(α (n+1) + β))`
  (`ratio_forward_difference`)

making the "ratio-as-Möbius, constant-numerator" heuristic exact.

## Conjecture D — Tropical / valuation dequantization  (**PROVED**)

Writing the log-curvature `Δ²(log a)(n) = log a(n) − 2 log a(n+1) + log a(n+2)`,
we prove the *exact curvature ratio*

  `a(n)·a(n+2) / a(n+1)² = 1 + Δ / ((γ n + δ)·(α (n+1) + β))`
  (`curvature_ratio`)

hence `Δ²(log a)(n) = log (1 + Δ / ((γ n + δ)·(α (n+1) + β)))`
(`log_curvature`), and when `α, γ > 0` this tends to `0`
(`log_curvature_tendsto_zero`): the valuation `v = −log a` is asymptotically
affine, with the curvature defect controlled by `Δ`.

## Conjecture B — coefficient-only second-order discriminant  (**DISPROVED**)

For second-order recurrences `p·a(n+2) = q·a(n+1) + r·a(n)` we show the
conjectured "discriminant polynomial in the coefficients whose eventual sign
governs log-convexity" **cannot exist** in general.  The Fibonacci numbers obey
`a(n+2) = a(n+1) + a(n)` with *constant* coefficients `p = q = r = 1`, yet their
pointwise discriminant is `fib(n)·fib(n+2) − fib(n+1)² = (−1)^{n+1}`
(`fib_discriminant`, a form of Cassini's identity), which is `+1` and `−1`
infinitely often (`fib_discriminant_not_eventually_signed`).  No function of the
constant coefficients can be `+1` and `−1` simultaneously, so no coefficient-only
`Δ₂` governs the sign — the first-order case is genuinely special.
-/

namespace MobiusDiscriminant

open Filter Topology

/-! ## The exact discriminant identity (Conjecture A) -/

/-- **Conjecture A, exact identity.**  Under the first-order multiplicative
recurrence `(α n + β)·a(n+1) = (γ n + δ)·a(n)`, the pointwise discriminant
`D(n) = a(n)·a(n+2) − a(n+1)²` obeys the exact identity
`(α n + β)·(α (n+1) + β)·D(n) = Δ · a(n)·a(n+1)` with `Δ = γβ − αδ`.
No positivity is needed: this is a pure algebraic consequence of the recurrence
at `n` and `n+1`. -/
theorem discriminant_exact {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (n : ℕ) :
    (α * n + β) * (α * (n + 1) + β) * (a n * a (n + 2) - a (n + 1) ^ 2)
      = (γ * β - α * δ) * a n * a (n + 1) := by
  have h1 := hrec n
  have h2 := hrec (n + 1)
  push_cast at h2 ⊢
  linear_combination (a n * (α * (n : ℝ) + β)) * h2
    - ((α * ((n : ℝ) + 1) + β) * a (n + 1)) * h1

/-- **Discriminant sign law, positive regime.**  When `Δ > 0` the pointwise
discriminant is strictly positive at every index (strict log-convexity, made
pointwise and quantitative). -/
theorem discriminant_sign_pos {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : 0 < γ * β - α * δ) (n : ℕ) :
    0 < a n * a (n + 2) - a (n + 1) ^ 2 := by
  have key := discriminant_exact hrec n
  have hd0 := hden n
  have hd1 := hden (n + 1)
  have hQ : 0 < α * ((n : ℝ) + 1) + β := by push_cast at hd1; linarith
  have hd : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β) := mul_pos hd0 hQ
  have hrhs : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β)
      * (a n * a (n + 2) - a (n + 1) ^ 2) := by
    rw [key]; exact mul_pos (mul_pos hΔ (hpos n)) (hpos (n + 1))
  exact (mul_pos_iff_of_pos_left hd).mp hrhs

/-- **Discriminant sign law, zero regime.**  When `Δ = 0` the pointwise
discriminant vanishes identically (log-linearity). -/
theorem discriminant_sign_zero {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : γ * β - α * δ = 0) (n : ℕ) :
    a n * a (n + 2) - a (n + 1) ^ 2 = 0 := by
  have key := discriminant_exact hrec n
  have hd0 := hden n
  have hd1 := hden (n + 1)
  have hQ : 0 < α * ((n : ℝ) + 1) + β := by push_cast at hd1; linarith
  have hd : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β) := mul_pos hd0 hQ
  rw [hΔ] at key
  simp only [zero_mul] at key
  rcases mul_eq_zero.mp key with h | h
  · exact absurd h hd.ne'
  · exact h

/-- **Discriminant sign law, negative regime.**  When `Δ < 0` the pointwise
discriminant is strictly negative at every index (strict log-concavity). -/
theorem discriminant_sign_neg {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hΔ : γ * β - α * δ < 0) (n : ℕ) :
    a n * a (n + 2) - a (n + 1) ^ 2 < 0 := by
  have key := discriminant_exact hrec n
  have hd0 := hden n
  have hd1 := hden (n + 1)
  have hQ : 0 < α * ((n : ℝ) + 1) + β := by push_cast at hd1; linarith
  have hd : 0 < (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β) := mul_pos hd0 hQ
  have hrhs : (α * (n : ℝ) + β) * (α * ((n : ℝ) + 1) + β)
      * (a n * a (n + 2) - a (n + 1) ^ 2) < 0 := by
    rw [key]; nlinarith [mul_pos (hpos n) (hpos (n + 1)), hΔ]
  by_contra hc
  push_neg at hc
  nlinarith [mul_nonneg hd.le hc, hrhs]

/-! ## The Möbius ratio: forward difference with constant numerator `Δ` -/

/-- Under the recurrence the consecutive ratio equals the Möbius function
`(γ n + δ)/(α n + β)`. -/
theorem ratio_eq_mobius {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (m : ℕ) :
    a (m + 1) / a m = (γ * m + δ) / (α * m + β) := by
  rw [div_eq_div_iff (hpos m).ne' (hden m).ne']
  linear_combination hrec m

/-- **Exact forward difference of the Möbius ratio.**  The forward difference of
the consecutive ratio has the *`n`-independent* numerator `Δ = γβ − αδ`. -/
theorem ratio_forward_difference {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (n : ℕ) :
    a (n + 2) / a (n + 1) - a (n + 1) / a n
      = (γ * β - α * δ) / ((α * n + β) * (α * (n + 1) + β)) := by
  have r := ratio_eq_mobius hpos hden hrec
  rw [r n, r (n + 1)]
  have hd0 := hden n
  have hd1 := hden (n + 1)
  push_cast at hd1 ⊢
  rw [div_sub_div _ _ (by positivity) (by positivity),
      div_eq_div_iff (by positivity) (by positivity)]
  ring

/-! ## The exact curvature ratio (Conjecture D) -/

/-- **Conjecture D, exact curvature ratio.**  The "log-curvature ratio"
`a(n)·a(n+2)/a(n+1)²` equals `1 + Δ / ((γ n + δ)·(α (n+1) + β))`.  Since the
correction term tends to `0`, the curvature ratio tends to `1` and the
valuation is asymptotically affine. -/
theorem curvature_ratio {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hnum : ∀ n : ℕ, 0 < γ * n + δ)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (n : ℕ) :
    a n * a (n + 2) / (a (n + 1)) ^ 2
      = 1 + (γ * β - α * δ) / ((γ * n + δ) * (α * (n + 1) + β)) := by
  have key := discriminant_exact hrec n
  have h1 := hrec n
  have hd0 := hden n
  have eqn : (γ * n + δ) * (α * (n + 1) + β) * (a n * a (n + 2))
      = ((γ * n + δ) * (α * (n + 1) + β) + (γ * β - α * δ)) * (a (n + 1)) ^ 2 := by
    apply mul_left_cancel₀ hd0.ne'
    push_cast at key h1 ⊢
    linear_combination (γ * (n : ℝ) + δ) * key - (γ * β - α * δ) * a (n + 1) * h1
  have hp1 := hpos (n + 1)
  have hnn := hnum n
  have hd1 := hden (n + 1)
  have hQ : 0 < α * ((n : ℝ) + 1) + β := by push_cast at hd1; linarith
  have hden2 : 0 < (γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β) := mul_pos hnn hQ
  have hB2 : 0 < (a (n + 1)) ^ 2 := by positivity
  rw [show (1 : ℝ) + (γ * β - α * δ) / ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β))
        = ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β) + (γ * β - α * δ))
            / ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β))
        from by field_simp]
  rw [div_eq_div_iff hB2.ne' hden2.ne']
  push_cast at eqn ⊢
  linear_combination eqn

/-- **Log-curvature identity (valuation form of Conjecture D).**  The second
difference of the logarithm equals the log of the exact curvature ratio. -/
theorem log_curvature {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hnum : ∀ n : ℕ, 0 < γ * n + δ)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) (n : ℕ) :
    Real.log (a n) + Real.log (a (n + 2)) - 2 * Real.log (a (n + 1))
      = Real.log (1 + (γ * β - α * δ) / ((γ * n + δ) * (α * (n + 1) + β))) := by
  have hcr := curvature_ratio hpos hden hnum hrec n
  rw [← hcr, Real.log_div (mul_pos (hpos n) (hpos (n + 2))).ne' (pow_pos (hpos (n + 1)) 2).ne',
     Real.log_mul (hpos n).ne' (hpos (n + 2)).ne', Real.log_pow]
  push_cast; ring

/-- **Asymptotic flatness (Conjecture D).**  When `α, γ > 0` the log-curvature
`Δ²(log a)(n)` tends to `0`, so the valuation `−log a` is asymptotically affine.
-/
theorem log_curvature_tendsto_zero {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hnum : ∀ n : ℕ, 0 < γ * n + δ)
    (hα : 0 < α) (hγ : 0 < γ)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) :
    Filter.Tendsto
      (fun n => Real.log (a n) + Real.log (a (n + 2)) - 2 * Real.log (a (n + 1)))
      Filter.atTop (nhds 0) := by
  have heq : (fun n => Real.log (a n) + Real.log (a (n + 2)) - 2 * Real.log (a (n + 1)))
      = (fun n : ℕ => Real.log (1 + (γ * β - α * δ)
          / ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β)))) := by
    funext n
    have := log_curvature hpos hden hnum hrec n
    push_cast at this ⊢
    convert this using 3
  rw [heq]
  have h1 : Tendsto (fun n : ℕ => γ * (n : ℝ) + δ) atTop atTop :=
    tendsto_atTop_add_const_right _ _ (tendsto_natCast_atTop_atTop.const_mul_atTop hγ)
  have h2 : Tendsto (fun n : ℕ => α * ((n : ℝ) + 1) + β) atTop atTop := by
    apply tendsto_atTop_add_const_right
    apply Tendsto.const_mul_atTop hα
    exact tendsto_atTop_add_const_right _ _ tendsto_natCast_atTop_atTop
  have hden' : Tendsto (fun n : ℕ => (γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β)) atTop atTop :=
    h1.atTop_mul_atTop₀ h2
  have hg : Tendsto (fun n : ℕ => (γ * β - α * δ)
      / ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β))) atTop (nhds 0) :=
    Tendsto.div_atTop tendsto_const_nhds hden'
  have h3 : Tendsto (fun n : ℕ => 1 + (γ * β - α * δ)
      / ((γ * (n : ℝ) + δ) * (α * ((n : ℝ) + 1) + β))) atTop (nhds 1) := by
    have := hg.const_add 1; simpa using this
  have := (Real.continuousAt_log (by norm_num : (1 : ℝ) ≠ 0)).tendsto.comp h3
  simpa [Real.log_one] using this

/-! ## Concrete instance of Conjecture A: the Catalan numbers (`Δ = 6`) -/

/-- Positivity of the Catalan numbers. -/
theorem catalan_pos (n : ℕ) : 0 < catalan n := by
  rw [catalan_eq_centralBinom_div]
  exact Nat.div_pos
    (Nat.le_of_dvd (Nat.centralBinom_pos _)
      (Nat.dvd_of_mod_eq_zero
        (by rw [Nat.mod_eq_zero_of_dvd]; simpa using Nat.succ_dvd_centralBinom n)))
    (Nat.succ_pos _)

/-- The multiplicative Catalan recurrence `(n+2)·Cₙ₊₁ = 2(2n+1)·Cₙ`. -/
theorem catalan_rec (n : ℕ) :
    (n + 2) * catalan (n + 1) = 2 * (2 * n + 1) * catalan n := by
  convert Nat.mul_div_cancel' (Nat.succ_dvd_centralBinom (n + 1)) using 1
  · rw [catalan_eq_centralBinom_div]
  · rw [catalan_eq_centralBinom_div]
    nlinarith [Nat.div_mul_cancel
      (show n + 1 ∣ n.centralBinom from Nat.succ_dvd_centralBinom n),
      Nat.succ_mul_centralBinom_succ n]

/-- **Exact Catalan discriminant identity** (`Δ = 6`):
`(n+2)(n+3)·(Cₙ·Cₙ₊₂ − Cₙ₊₁²) = 6·Cₙ·Cₙ₊₁`.  A concrete instantiation of
`discriminant_exact` with `α,β,γ,δ = 1,2,4,2`. -/
theorem catalan_discriminant_exact (n : ℕ) :
    ((n : ℝ) + 2) * ((n : ℝ) + 3)
        * ((catalan n : ℝ) * catalan (n + 2) - (catalan (n + 1)) ^ 2)
      = 6 * (catalan n : ℝ) * catalan (n + 1) := by
  have hrec : ∀ m : ℕ, ((1 : ℝ) * m + 2) * ((fun k => (catalan k : ℝ)) (m + 1))
      = (4 * m + 2) * ((fun k => (catalan k : ℝ)) m) := by
    intro m
    simp only
    have h : ((m : ℝ) + 2) * (catalan (m + 1)) = 2 * (2 * (m : ℝ) + 1) * (catalan m) := by
      exact_mod_cast catalan_rec m
    linear_combination h
  have key := discriminant_exact (a := fun k => (catalan k : ℝ)) hrec n
  simp only at key
  linarith [key]

/-! ## Conjecture B is FALSE: the Fibonacci / Cassini obstruction -/

/-- **Cassini-type discriminant identity.**  The pointwise discriminant of the
Fibonacci numbers is `fib(n)·fib(n+2) − fib(n+1)² = (−1)^{n+1}`. -/
theorem fib_discriminant (n : ℕ) :
    (Nat.fib n : ℤ) * (Nat.fib (n + 2)) - (Nat.fib (n + 1)) ^ 2 = (-1) ^ (n + 1) := by
  have cassini : ∀ m : ℕ,
      (Nat.fib (m + 1) : ℤ) ^ 2 - (Nat.fib m : ℤ) * (Nat.fib (m + 2)) = (-1) ^ m := by
    intro m
    induction m with
    | zero => simp
    | succ k ih =>
      have h2 : (Nat.fib (k + 2) : ℤ) = Nat.fib k + Nat.fib (k + 1) := by
        exact_mod_cast Nat.fib_add_two
      have e1 : k + 1 + 1 = k + 2 := rfl
      have e2 : k + 1 + 2 = k + 3 := rfl
      rw [e1, e2, pow_succ]
      have h : (Nat.fib (k + 3) : ℤ) = Nat.fib (k + 1) + Nat.fib (k + 2) := by
        exact_mod_cast Nat.fib_add_two
      rw [h]
      linear_combination (-1 : ℤ) * ih + (Nat.fib (k + 2) : ℤ) * h2
  have h := cassini n
  linear_combination -h

/-- **Conjecture B fails.**  The Fibonacci discriminant is `+1` at odd indices
and `−1` at even indices, hence takes both signs infinitely often: for every
`N` there is an index `≥ N` where it is positive, and one where it is negative.
Because Fibonacci obeys a second-order recurrence with *constant* coefficients
`p = q = r = 1`, no function of the coefficients alone can be simultaneously `+1`
and `−1`, so no coefficient-only second-order discriminant `Δ₂` governs the sign
of the log-curvature. -/
theorem fib_discriminant_not_eventually_signed :
    (∀ N : ℕ, ∃ n ≥ N, 0 < (Nat.fib n : ℤ) * (Nat.fib (n + 2)) - (Nat.fib (n + 1)) ^ 2) ∧
    (∀ N : ℕ, ∃ n ≥ N, (Nat.fib n : ℤ) * (Nat.fib (n + 2)) - (Nat.fib (n + 1)) ^ 2 < 0) := by
  constructor
  · intro N
    refine ⟨2 * N + 1, by omega, ?_⟩
    rw [fib_discriminant]
    have h : (2 * N + 1 + 1) = 2 * (N + 1) := by ring
    rw [h, pow_mul]; norm_num
  · intro N
    refine ⟨2 * N + 2, by omega, ?_⟩
    rw [fib_discriminant]
    have h : (2 * N + 2 + 1) = 2 * (N + 1) + 1 := by ring
    rw [h, pow_succ, pow_mul]; norm_num

end MobiusDiscriminant