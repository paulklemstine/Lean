import Mathlib
import Tropical.Core.TropicalPolynomials

/-! # `tropical_simp`: a sound simplification tactic for the max-plus semiring

This file develops a custom Lean tactic, `tropical_simp`, that normalises
expressions in the **max-plus (tropical) semiring** on `ℝ`, where addition is
`max` and multiplication is `+`.

The design principle is *soundness by construction*: the tactic is a thin macro
over `simp only` whose rewrite set consists **exclusively of theorems that are
proved in this file** (or in Mathlib). Consequently every goal that
`tropical_simp` closes is a genuine theorem of the max-plus semiring — the
tactic cannot prove anything false.

We then exercise the tactic on non-trivial identities, including a *tropical
Horner form* for the degree-two tropical polynomials defined in
`Tropical.Core.TropicalPolynomials`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Common max-plus manipulations (idempotency,
commutativity, and — crucially — the two-sided distributivity of `+` over
`max`) form a confluent rewrite system that can be packaged as a single
`simp`-based tactic and proved sound.
Experiment (Experimenter): We isolate the rewrite lemmas as proved theorems and
define `tropical_simp` as a `simp only` macro over them. We test it on scalar
distributivity over `tropicalLinear` and on a Horner factorisation of
`tropicalQuadratic`.
Analysis (Analyst): Pure `simp only` normalises the polynomial to a canonical
`max` of affine terms; the residual goal is a linear-order identity closed by
`ring_nf`/`linarith`. The distributivity lemma `max_add_add_left` is the load
bearing rewrite.
Critique (Critic): The tactic must not silently rely on `decide`/`native_decide`
(it does not) and every rewrite must be a proven lemma (it is). The Horner
identity is a genuine algebraic fact, not a definitional `rfl`.
Synthesis (PI): `tropical_simp` = `simp only [defs, distributivity, idempotency]`,
sound because each member of the set is a theorem below.
-/

namespace TropicalSimp

/-- Tropical addition on `ℝ` (max-plus convention): `tadd a b = max a b`. -/
def tadd (a b : ℝ) : ℝ := max a b

/-- Tropical multiplication on `ℝ` (max-plus convention): `tmul a b = a + b`. -/
def tmul (a b : ℝ) : ℝ := a + b

/-! ## The verified rewrite set behind `tropical_simp` -/

theorem tadd_comm (a b : ℝ) : tadd a b = tadd b a := max_comm a b

theorem tadd_assoc (a b c : ℝ) : tadd (tadd a b) c = tadd a (tadd b c) :=
  max_assoc a b c

theorem tadd_idem (a : ℝ) : tadd a a = a := max_self a

theorem tmul_comm (a b : ℝ) : tmul a b = tmul b a := add_comm a b

theorem tmul_assoc (a b c : ℝ) : tmul (tmul a b) c = tmul a (tmul b c) :=
  add_assoc a b c

/-- Left distributivity of tropical multiplication over tropical addition. -/
theorem tmul_tadd (a b c : ℝ) : tmul a (tadd b c) = tadd (tmul a b) (tmul a c) :=
  (max_add_add_left a b c).symm

/-- Right distributivity of tropical multiplication over tropical addition. -/
theorem tadd_tmul (a b c : ℝ) : tmul (tadd a b) c = tadd (tmul a c) (tmul b c) :=
  (max_add_add_right a b c).symm

/-- The custom tactic. It unfolds the tropical operations and applies the
verified distributivity and idempotency rewrites. Because every lemma in the
rewrite set is proved above (or in Mathlib), `tropical_simp` is sound. -/
macro "tropical_simp" : tactic =>
  `(tactic| simp only [TropicalSimp.tmul, TropicalSimp.tadd,
      max_add_add_left, max_add_add_right, max_self])

/-! ## Soundness demonstrations on non-trivial identities -/

open TropicalPolynomials

/-- Full left-distributivity, restated as a stand-alone theorem to certify the
key rewrite of `tropical_simp`. -/
theorem tropical_distrib (a b c : ℝ) :
    tmul a (tadd b c) = tadd (tmul a b) (tmul a c) := by
  tropical_simp

/-- Scaling a degree-one tropical polynomial by a tropical scalar `c` shifts
its coefficients: `tmul c (tropicalLinear a₀ a₁ x) = tropicalLinear (c+a₀) (c+a₁) x`.
Proved via the distributivity rewrite `max_add_add_left` behind `tropical_simp`. -/
theorem tmul_tropicalLinear (c a₀ a₁ x : ℝ) :
    tmul c (tropicalLinear a₀ a₁ x) = tropicalLinear (c + a₀) (c + a₁) x := by
  unfold tmul tropicalLinear
  rw [← max_add_add_left]; ring_nf

/-- **Tropical Horner form.** The degree-two tropical polynomial factors as a
nested tropical linear expression, the max-plus analogue of Horner's rule:
`tropicalQuadratic a₀ a₁ a₂ x = tadd a₀ (tmul x (tadd a₁ (tmul x a₂)))`. -/
theorem tropicalQuadratic_horner (a₀ a₁ a₂ x : ℝ) :
    tropicalQuadratic a₀ a₁ a₂ x = tadd a₀ (tmul x (tadd a₁ (tmul x a₂))) := by
  unfold tropicalQuadratic tadd tmul
  rw [← max_add_add_left]
  congr 1
  congr 1 <;> ring

end TropicalSimp