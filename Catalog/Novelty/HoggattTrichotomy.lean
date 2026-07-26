import Mathlib

/-!
# A Möbius trichotomy for the total d-Hoggatt numbers

The *total* d-Hoggatt numbers `H_d(n) = ∑_k H_d(n,k)` obey, for the classical
values of `d`, a first-order *multiplicative* recurrence of the shape
`(α n + β)·H(n+1) = (γ n + δ)·H(n)` with rational coefficients:

* `H_1(n) = 2 ^ n`   satisfies `1·H(n+1) = 2·H(n)`             (`α,β,γ,δ = 0,1,0,2`);
* `H_2(n) = Cₙ`      satisfies `(n+2)·H(n+1) = (4n+2)·H(n)`    (`α,β,γ,δ = 1,2,4,2`).

The previous cycle established the *sharp `d = 1` vs `d = 2` dichotomy*
(log-linear vs strictly log-convex).  Here we identify the exact algebraic
mechanism behind that dichotomy and turn it into a **trichotomy governed by a
single Möbius discriminant** `Δ = γβ − αδ`:

> For any positive real sequence obeying `(α n + β)·a(n+1) = (γ n + δ)·a(n)`
> with `α n + β > 0`, the sign of `Δ = γβ − αδ` controls the log-behaviour:
> `Δ > 0` gives **strict log-convexity**, `Δ = 0` gives **log-linearity**, and
> `Δ < 0` gives **strict log-concavity**.

The key structural fact is that the consecutive ratio `a(n+1)/a(n)` equals the
Möbius function `(γ n + δ)/(α n + β)`, whose forward difference has the
*`n`-independent* numerator `Δ`.  This constant is the abstract source of the
"positive coefficient gap" observed concretely in the Catalan discriminant
identity `(2n+1)(n+3)·Cₙ·Cₙ₊₂ = (n+2)(2n+3)·Cₙ₊₁²`.

The framework then explains a whole family of examples at once:

* Catalan numbers `Cₙ`               (`Δ = 6`)  — strictly log-convex;
* central binomial coefficients `C(2n,n)` (`Δ = 2`) — strictly log-convex;
* factorials `n!`                    (`Δ = 1`)  — strictly log-convex;
* powers `2 ^ n`                     (`Δ = 0`)  — log-linear;
* reciprocal factorials `1/n!`       (`Δ = −1`) — strictly log-concave.

In particular all three regimes of the trichotomy are realized, giving a "sharp
trichotomy" refining the earlier dichotomy.
-/

namespace HoggattHierarchy

/-! ## Log-behaviour predicates over `ℝ` -/

/-- A positive real sequence is *strictly log-convex*: `a(n+1)² < a(n)·a(n+2)`. -/
def StrictLogConvex (a : ℕ → ℝ) : Prop := ∀ n, a (n + 1) ^ 2 < a n * a (n + 2)

/-- A real sequence is *log-linear*: `a(n+1)² = a(n)·a(n+2)`. -/
def LogLinear (a : ℕ → ℝ) : Prop := ∀ n, a (n + 1) ^ 2 = a n * a (n + 2)

/-- A real sequence is *strictly log-concave*: `a(n)·a(n+2) < a(n+1)²`. -/
def StrictLogConcave (a : ℕ → ℝ) : Prop := ∀ n, a n * a (n + 2) < a (n + 1) ^ 2

/-- Strict log-convexity is incompatible with strict log-concavity. -/
theorem StrictLogConvex.not_strictLogConcave {a : ℕ → ℝ}
    (h : StrictLogConvex a) : ¬ StrictLogConcave a := by
  intro hc; exact (lt_asymm (h 0)) (hc 0)

/-- Strict log-convexity is incompatible with log-linearity. -/
theorem StrictLogConvex.not_logLinear {a : ℕ → ℝ}
    (h : StrictLogConvex a) : ¬ LogLinear a := by
  intro hl; exact (ne_of_lt (h 0)) (hl 0)

/-! ## The ratio criterion

A positive real sequence with strictly increasing consecutive ratios is
strictly log-convex.  This isolates the "ratio amplification" mechanism. -/

theorem strictLogConvex_of_ratio_strictMono {a : ℕ → ℝ}
    (hpos : ∀ n, 0 < a n)
    (hmono : ∀ n, a (n + 1) / a n < a (n + 2) / a (n + 1)) :
    StrictLogConvex a := by
  intro n
  have h := hmono n
  rw [div_lt_div_iff₀ (hpos _) (hpos _)] at h
  nlinarith [h]

/-! ## The Möbius trichotomy engine

Everything below flows from a single observation: under the recurrence, the
consecutive ratio is the Möbius function `(γ n + δ)/(α n + β)`. -/

/-- Under the multiplicative recurrence, the consecutive ratio equals the
Möbius function `(γ n + δ)/(α n + β)`. -/
theorem ratio_eq_mobius {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) :
    ∀ m : ℕ, a (m + 1) / a m = (γ * m + δ) / (α * m + β) := by
  intro m
  rw [div_eq_div_iff (hpos m).ne' (hden m).ne']
  linear_combination hrec m

/-- **Strictly log-convex regime** (`Δ = γβ − αδ > 0`). -/
theorem strictLogConvex_of_recurrence {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hdisc : α * δ < γ * β) :
    StrictLogConvex a := by
  have hratio := ratio_eq_mobius hpos hden hrec
  apply strictLogConvex_of_ratio_strictMono hpos
  intro n
  rw [hratio n, hratio (n + 1), div_lt_div_iff₀ (hden n) (hden (n + 1))]
  push_cast
  nlinarith [hdisc]

/-- **Log-linear regime** (`Δ = γβ − αδ = 0`). -/
theorem logLinear_of_recurrence {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hdisc : α * δ = γ * β) :
    LogLinear a := by
  have hratio := ratio_eq_mobius hpos hden hrec
  intro n
  have key : a (n + 1) / a n = a (n + 2) / a (n + 1) := by
    rw [hratio n, hratio (n + 1), div_eq_div_iff (hden n).ne' (hden (n + 1)).ne']
    push_cast; nlinarith [hdisc]
  rw [div_eq_div_iff (hpos n).ne' (hpos (n + 1)).ne'] at key
  nlinarith [key]

/-- **Strictly log-concave regime** (`Δ = γβ − αδ < 0`). -/
theorem strictLogConcave_of_recurrence {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n)
    (hdisc : γ * β < α * δ) :
    StrictLogConcave a := by
  have hratio := ratio_eq_mobius hpos hden hrec
  intro n
  have key : a (n + 2) / a (n + 1) < a (n + 1) / a n := by
    rw [hratio n, hratio (n + 1), div_lt_div_iff₀ (hden (n + 1)) (hden n)]
    push_cast; nlinarith [hdisc]
  rw [div_lt_div_iff₀ (hpos (n + 1)) (hpos n)] at key
  nlinarith [key]

/-- **Möbius trichotomy.**  For a positive real sequence obeying the
multiplicative recurrence, the sign of the discriminant `Δ = γβ − αδ` decides
the entire log-behaviour: positive gives strict log-convexity, zero gives
log-linearity, negative gives strict log-concavity. -/
theorem mobius_trichotomy {a : ℕ → ℝ} {α β γ δ : ℝ}
    (hpos : ∀ n, 0 < a n)
    (hden : ∀ n : ℕ, 0 < α * n + β)
    (hrec : ∀ n : ℕ, (α * n + β) * a (n + 1) = (γ * n + δ) * a n) :
    (α * δ < γ * β → StrictLogConvex a) ∧
    (α * δ = γ * β → LogLinear a) ∧
    (γ * β < α * δ → StrictLogConcave a) :=
  ⟨fun h => strictLogConvex_of_recurrence hpos hden hrec h,
   fun h => logLinear_of_recurrence hpos hden hrec h,
   fun h => strictLogConcave_of_recurrence hpos hden hrec h⟩

/-! ## Concrete instances

We now feed the classical sequences into the engine.  Each application reduces
to (i) positivity, (ii) the multiplicative recurrence recast over `ℝ`, and
(iii) the numeric sign of the discriminant. -/

/-! ### Auxiliary Catalan facts (recast of the thread's engine) -/

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

/-! ### `d = 2`: the Catalan totals are strictly log-convex (`Δ = 6`) -/

theorem catalan_strictLogConvex :
    StrictLogConvex (fun n => (catalan n : ℝ)) := by
  apply strictLogConvex_of_recurrence
      (α := 1) (β := 2) (γ := 4) (δ := 2)
  · intro n; exact_mod_cast catalan_pos n
  · intro n; positivity
  · intro n
    have hr : ((n : ℝ) + 2) * (catalan (n + 1)) = 2 * (2 * (n : ℝ) + 1) * (catalan n) := by
      exact_mod_cast catalan_rec n
    linear_combination hr
  · norm_num

/-! ### Central binomial coefficients are strictly log-convex (`Δ = 2`) -/

theorem centralBinom_strictLogConvex :
    StrictLogConvex (fun n => (Nat.centralBinom n : ℝ)) := by
  apply strictLogConvex_of_recurrence
      (α := 1) (β := 1) (γ := 4) (δ := 2)
  · intro n; exact_mod_cast Nat.centralBinom_pos n
  · intro n; positivity
  · intro n
    have hr : ((n : ℝ) + 1) * (Nat.centralBinom (n + 1))
        = 2 * (2 * (n : ℝ) + 1) * (Nat.centralBinom n) := by
      exact_mod_cast Nat.succ_mul_centralBinom_succ n
    linear_combination hr
  · norm_num

/-! ### Factorials are strictly log-convex (`Δ = 1`) -/

theorem factorial_strictLogConvex :
    StrictLogConvex (fun n => (n.factorial : ℝ)) := by
  apply strictLogConvex_of_recurrence
      (α := 0) (β := 1) (γ := 1) (δ := 1)
  · intro n; exact_mod_cast Nat.factorial_pos n
  · intro n; norm_num
  · intro n
    have h : (n + 1).factorial = (n + 1) * n.factorial := Nat.factorial_succ n
    push_cast [h]; ring
  · norm_num

/-! ### `d = 1`: the powers `2 ^ n` are log-linear (`Δ = 0`) -/

theorem pow_two_logLinear :
    LogLinear (fun n => (2 : ℝ) ^ n) := by
  apply logLinear_of_recurrence
      (α := 0) (β := 1) (γ := 0) (δ := 2)
  · intro n; positivity
  · intro n; norm_num
  · intro n; ring
  · norm_num

/-! ### Reciprocal factorials `1/n!` are strictly log-concave (`Δ = −1`) -/

theorem inv_factorial_strictLogConcave :
    StrictLogConcave (fun n => 1 / (n.factorial : ℝ)) := by
  apply strictLogConcave_of_recurrence
      (α := 1) (β := 1) (γ := 0) (δ := 1)
  · intro n
    have : (0 : ℝ) < (n.factorial : ℝ) := by exact_mod_cast Nat.factorial_pos n
    positivity
  · intro n; positivity
  · intro n
    have h : ((n + 1).factorial : ℝ) = ((n : ℝ) + 1) * (n.factorial : ℝ) := by
      have := Nat.factorial_succ n; push_cast [this]; ring
    have hpos : (0 : ℝ) < (n.factorial : ℝ) := by exact_mod_cast Nat.factorial_pos n
    rw [h]; field_simp; ring
  · norm_num

/-! ## The sharp trichotomy

All three regimes are simultaneously realized by classical sequences, refining
the previously established `d = 1` vs `d = 2` dichotomy into a genuine
trichotomy anchored by the sign of the Möbius discriminant. -/

/-- **Sharp trichotomy.**  The Catalan totals are strictly log-convex, the
`d = 1` totals `2 ^ n` are log-linear, and the reciprocal factorials are
strictly log-concave — the three mutually exclusive regimes of the Möbius
discriminant are all inhabited. -/
theorem sharp_trichotomy :
    StrictLogConvex (fun n => (catalan n : ℝ)) ∧
    LogLinear (fun n => (2 : ℝ) ^ n) ∧
    StrictLogConcave (fun n => 1 / (n.factorial : ℝ)) :=
  ⟨catalan_strictLogConvex, pow_two_logLinear, inv_factorial_strictLogConcave⟩

/-- The three regimes are genuinely distinct: strict log-convexity of the
Catalan totals excludes both log-linearity and strict log-concavity. -/
theorem catalan_regime_strict :
    ¬ LogLinear (fun n => (catalan n : ℝ)) ∧
    ¬ StrictLogConcave (fun n => (catalan n : ℝ)) :=
  ⟨catalan_strictLogConvex.not_logLinear,
   catalan_strictLogConvex.not_strictLogConcave⟩

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The previous cycle proved a *sharp dichotomy* — `2 ^ n`
log-linear vs Catalan strictly log-convex — driven by an ad-hoc Catalan
discriminant identity whose two coefficients differed by the constant `3`.  We
hypothesized that this constant gap is not special to Catalan but is the shadow
of a single algebraic invariant attached to the underlying first-order
recurrence, and that its sign should govern a full trichotomy.

**Experiment.**  We abstracted the common shape of the classical recurrences to
`(α n + β)·a(n+1) = (γ n + δ)·a(n)`.  Computing the consecutive ratio gives the
Möbius function `(γ n + δ)/(α n + β)`, whose forward difference has numerator
exactly `Δ = γβ − αδ`, independent of `n` (`ratio_eq_mobius` plus the cross
-multiplied inequalities inside `strictLogConvex_of_recurrence` etc.).  Feeding
in Catalan (`Δ = 6`), central binomials (`Δ = 2`), factorials (`Δ = 1`),
`2 ^ n` (`Δ = 0`), and reciprocal factorials (`Δ = −1`) realizes all three
regimes.

**Analysis.**  The mysterious "constant 3" of the Catalan identity is exactly
the discriminant `Δ = 6` divided by the leading normalization; the general
invariant `Δ = γβ − αδ` is what actually controls log-behaviour.  Strict
convexity/concavity is *strict* precisely because `Δ ≠ 0` makes the ratio
strictly monotone; the log-linear boundary is the codimension-one locus
`Δ = 0`, occupied by the geometric sequence `2 ^ n`.

**Critique.**  Each regime theorem is genuinely strict (`<`, not `≤`) and the
exclusivity lemmas (`not_logLinear`, `not_strictLogConcave`) rule out
degeneracy.  The recurrence hypotheses are load-bearing: dropping positivity of
`α n + β` or of `a` breaks the ratio computation.  No result is proved by pure
`decide`/`norm_num`; the engine uses the ratio identity plus cross-multiplied
`nlinarith` steps.

**Synthesis.**  A single scalar `Δ = γβ − αδ` unifies the log-convexity theory
of the classical Hoggatt totals and of the surrounding combinatorial sequences,
upgrading the earlier dichotomy to a sharp, sign-indexed trichotomy.
-/

end HoggattHierarchy