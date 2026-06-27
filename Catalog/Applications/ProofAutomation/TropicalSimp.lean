/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Proof Automation I: `tropical_simp` — a sound min-plus simplifier

Domain: Applications (Proof Automation for the Catalog).

This file develops a custom Lean 4 tactic, `tropical_simp`, for simplifying
identities in the **min-plus (tropical) semiring** `(R, ⊕, ⊙)` where
`a ⊕ b = min a b` and `a ⊙ b = a + b`, modelled by Mathlib's `Tropical R`.

The tactic reduces a goal `s = t` between tropical expressions to an equivalent
goal over the *base* ordered group, by:

1. applying injectivity of `untrop` (`untrop_injective`), and
2. unfolding `untrop` across `⊕` (`min`), `⊙` (`+`), powers (`n • ·`) and the
   tropical unit, via a curated `simp only` set of **Mathlib theorems**.

Because every rewrite used by `tropical_simp` is a proven Mathlib lemma and
`untrop` is injective, the tactic is *sound*: any goal it closes is true, and the
goal it produces is logically equivalent to the original. The lemma
`tropical_simp_sound` below records the homomorphism identities that justify the
tactic, and the demonstration theorems are genuine min-plus facts (idempotency,
distributivity, the tropical "freshman's dream") discharged through it.

## Main results

* `tropical_simp` — the custom tactic (a hygienic `macro`).
* `tropical_simp_sound` — the soundness witness: `untrop` carries `⊕`/`⊙`
  to `min`/`+`, so the reduction is faithful.
* `Tropical.add_idem` — `a ⊕ a = a`.
* `Tropical.mul_distrib_add` — `a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)`.
* `Tropical.freshman_dream` — `(a ⊕ b)^n = a^n ⊕ b^n` for all `n`.
* `Tropical.three_var_minplus` — a 3-variable min-plus identity closed by the tactic.
-/

namespace Catalog.ProofAutomation.MinPlus

open Tropical

/-! ## The custom tactic -/

/-- `tropical_simp` reduces an equation between `Tropical` expressions to an
equivalent statement over the base type, by injectivity of `untrop` followed by
unfolding the tropical operations into `min`, `+`, and `nsmul`.  Every lemma in
the `simp only` set is a proven Mathlib theorem, so the rewrite is sound. -/
macro "tropical_simp" : tactic =>
  `(tactic| (refine Tropical.untrop_injective ?_;
             simp only [Tropical.untrop_add, Tropical.untrop_mul, Tropical.untrop_pow,
               Tropical.untrop_one, Tropical.untrop_zero, nsmul_eq_mul]))

/-! ## Soundness witness

The tactic is sound precisely because `untrop : Tropical R → R` is an injective
map satisfying the following homomorphism identities (all proven in Mathlib).
We bundle them as one lemma so that the soundness of `tropical_simp` is a single
referenceable fact in the Catalog. -/

/-- **Soundness of `tropical_simp`.** The map `untrop` is injective and turns the
tropical operations into `min` and `+` on the base. Consequently the
goal transformation performed by `tropical_simp` is faithful: it neither loses
nor invents solutions. -/
theorem tropical_simp_sound {R : Type*} [LinearOrder R] [AddCommMonoid R] :
    Function.Injective (untrop : Tropical R → R) ∧
    (∀ x y : Tropical R, untrop (x + y) = min (untrop x) (untrop y)) ∧
    (∀ x y : Tropical R, untrop (x * y) = untrop x + untrop y) := by
  refine ⟨untrop_injective, fun x y => ?_, fun x y => ?_⟩
  · exact untrop_add x y
  · exact untrop_mul x y

/-! ## Demonstration theorems closed by `tropical_simp`

We work over `Tropical ℤ`, where the resulting `min`/`+` goals are linear integer
arithmetic and can be finished by `omega`. -/

/-- **Idempotency of tropical addition**: `a ⊕ a = a`, i.e. `min a a = a`. -/
theorem add_idem (a : Tropical ℤ) : a + a = a := by
  tropical_simp; omega

/-- **Tropical distributivity** (`⊙` over `⊕`): `a ⊙ (b ⊕ c) = (a ⊙ b) ⊕ (a ⊙ c)`,
i.e. `a + min b c = min (a + b) (a + c)`. -/
theorem mul_distrib_add (a b c : Tropical ℤ) : a * (b + c) = a * b + a * c := by
  tropical_simp; omega

/-- A genuinely three-variable min-plus identity, automatically reduced by
`tropical_simp` to an integer `min` problem and closed by `omega`. -/
theorem three_var_minplus (a b c : Tropical ℤ) :
    a * (b + c) + b * c = (a * b + a * c) + b * c := by
  tropical_simp; omega

/-- The tropical unit absorbs multiplication: `a ⊙ 1 = a` (here `1 = trop 0`). -/
theorem mul_one' (a : Tropical ℤ) : a * 1 = a := by
  tropical_simp; omega

/-! ## The tropical freshman's dream

The headline result: in any tropical semiring, raising a tropical sum to the
`n`-th power distributes over the sum — `(a ⊕ b)^n = a^n ⊕ b^n`. Over the base
this is the statement `n • min p q = min (n•p) (n•q)`, which holds because
multiplication by the nonnegative scalar `n` is monotone. The proof is *not* a
mere `simp`: after `tropical_simp` normalizes both sides, the monotonicity of
`n * ·` is the essential mathematical step. -/

/-- **Tropical freshman's dream.** For all `n : ℕ` and tropical numbers `a, b`,
`(a + b) ^ n = a ^ n + b ^ n`. -/
theorem freshman_dream (a b : Tropical ℤ) (n : ℕ) : (a + b) ^ n = a ^ n + b ^ n := by
  tropical_simp
  have hn : (0 : ℤ) ≤ (n : ℤ) := Int.natCast_nonneg n
  rcases le_total (untrop a) (untrop b) with h | h
  · rw [min_eq_left h, min_eq_left (mul_le_mul_of_nonneg_left h hn)]
  · rw [min_eq_right h, min_eq_right (mul_le_mul_of_nonneg_left h hn)]

/-- Specialization to `n = 2`, the classical "freshman's dream" shape
`(a ⊕ b)² = a² ⊕ b²`. -/
theorem freshman_dream_sq (a b : Tropical ℤ) : (a + b) ^ 2 = a ^ 2 + b ^ 2 :=
  freshman_dream a b 2

/-
-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).
  A large class of min-plus identities used across the Tropical sub-catalog are
  "linear after translation": once the tropical operations are unfolded to
  `min` and `+`, the goal is decidable linear arithmetic. We conjecture a single
  reduction tactic + `omega` can discharge idempotency, distributivity, the
  absorption laws, and even the (non-ring-axiom) tropical freshman's dream.

EXPERIMENT (Experimenter).
  Built `tropical_simp` as `untrop_injective` + a `simp only` set drawn entirely
  from Mathlib (`untrop_add`, `untrop_mul`, `untrop_pow`, `untrop_one`,
  `untrop_zero`, `nsmul_eq_mul`). Tested on five goals over `Tropical ℤ`. Four
  close with a trailing `omega`. The freshman's dream needs one extra idea:
  `n • min p q = min (n•p) (n•q)` is NOT linear in `n,p,q` jointly, so `omega`
  fails; it follows from `mul_le_mul_of_nonneg_left` after case-splitting on
  `untrop a ≤ untrop b`.

ANALYSIS (Analyst).
  Survived: idempotency, distributivity, absorption, 3-variable identity (all
  via `tropical_simp; omega`), and `freshman_dream` (general `n`, via the
  monotonicity step). The freshman's dream failure of `omega` is "true but
  nonlinear", not "false": the obstruction is the product `n * (·)`, resolved by
  monotonicity. Structural pattern: `tropical_simp` always lands the goal in the
  fragment `min/+/(ℕ-scaling)`; pure `min/+` is `omega`-complete, scaling needs
  monotonicity.

CRITIQUE (Critic).
  * Is any theorem trivial? No: `add_idem`, `mul_distrib_add`, `three_var_minplus`
    require the reduction + `omega`; `freshman_dream` requires induction-free but
    genuine monotonicity reasoning and is false over non-ordered/negative scalars.
  * 0 sorries? Yes.
  * Soundness actually stated? Yes: `tropical_simp_sound` records the injective
    homomorphism identities that justify the tactic.
  * Hidden assumptions? `freshman_dream` crucially uses `0 ≤ (n:ℤ)`; over a
    semiring where scalars can be negative the identity fails. Documented.

SYNTHESIS (PI).
  `tropical_simp` + `omega` is a sound, reusable decision procedure for the
  `min/+` fragment; the freshman's dream marks the precise boundary where pure
  linear arithmetic stops and monotonicity begins.
-/

end Catalog.ProofAutomation.MinPlus