import Mathlib

/-! # `number_theory_decide`: a verified small-case primality tactic

This file develops `number_theory_decide`, a tactic that discharges primality
goals `Nat.Prime n` for concrete `n` by *reflection* through a Boolean
trial-division test.

The point of interest is **soundness**: rather than trusting an opaque
decision procedure, we implement trial division explicitly as a `Bool`-valued
function `trialPrime` and *prove* it decides primality
(`trialPrime_correct`). The tactic then rewrites the goal along this proven
equivalence and evaluates the Boolean by `decide`. Soundness of the tactic is
exactly the content of `trialPrime_correct`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): A hand-rolled trial-division predicate
`trialPrime n = (2 ≤ n) && (no d with 2 ≤ d < n divides n)` is extensionally
equal to `Nat.Prime`, and this equivalence can back a reflective tactic.
Experiment (Experimenter): Implement `hasProperDivisor` via `List.range` /
`List.any`, define `trialPrime`, and prove
`trialPrime n = true ↔ Nat.Prime n` from `Nat.prime_def_lt`.
Analysis (Analyst): The forward and backward directions both hinge on
translating between `List.any … = true` and the bounded quantifier
`∀ m < n, m ∣ n → m = 1`. `Nat.prime_def_lt` is the bridge; `decide` finishes
the closed Boolean once reflection is applied.
Critique (Critic): The main theorem is `trialPrime_correct`, whose proof needs
`rcases`/`List` reasoning, not merely `decide`; the tactic's demonstrations are
secondary examples. No `native_decide` is used, so the kernel checks everything.
Synthesis (PI): `number_theory_decide` = rewrite by `trialPrime_correct` then
`decide`, with `omega`/`decide` fallbacks for arithmetic side goals.
-/

namespace NumberTheoryDecide

/-- `hasProperDivisor n` is `true` iff some `d` with `2 ≤ d < n` divides `n`. -/
def hasProperDivisor (n : ℕ) : Bool :=
  (List.range n).any (fun d => decide (2 ≤ d) && decide (d ∣ n))

/-- Boolean trial-division primality test. -/
def trialPrime (n : ℕ) : Bool :=
  decide (2 ≤ n) && !hasProperDivisor n

/-
Characterisation of `hasProperDivisor` as an existential.
-/
theorem hasProperDivisor_iff (n : ℕ) :
    hasProperDivisor n = true ↔ ∃ d, 2 ≤ d ∧ d < n ∧ d ∣ n := by
  simp +decide [ hasProperDivisor, List.any_eq_true ];
  exact ⟨ fun ⟨ x, hx₁, hx₂, hx₃ ⟩ => ⟨ x, hx₂, hx₁, hx₃ ⟩, fun ⟨ x, hx₂, hx₁, hx₃ ⟩ => ⟨ x, hx₁, hx₂, hx₃ ⟩ ⟩

/-- **Soundness of the trial-division test.** `trialPrime` decides `Nat.Prime`. -/
theorem trialPrime_correct (n : ℕ) : trialPrime n = true ↔ Nat.Prime n := by
  simp [trialPrime]
  constructor <;> intro h <;> rw [Nat.prime_def_lt'] at *
  · unfold hasProperDivisor at h; aesop
  · unfold hasProperDivisor; aesop

/-- The custom tactic: reflect a primality goal through the verified test and
evaluate, with arithmetic fallbacks. -/
macro "number_theory_decide" : tactic =>
  `(tactic| first
    | (rw [← NumberTheoryDecide.trialPrime_correct]; decide)
    | decide
    | omega)

/-! ## Soundness demonstrations -/

example : Nat.Prime 97 := by number_theory_decide

example : Nat.Prime 101 := by number_theory_decide

example : ¬ Nat.Prime 91 := by number_theory_decide

end NumberTheoryDecide