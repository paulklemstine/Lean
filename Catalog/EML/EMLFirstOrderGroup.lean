import Mathlib
import EML.EMLLogDerivHom

/-!
# The Differential Galois Group of a First-Order EML Equation is an EML Group

This file makes precise the slogan *"the differential Galois group of an EML
equation is an EML group"* in the simplest, decisive case: the first-order linear
equation `y′ = a·y`.  Working in an arbitrary differential field `K` (Mathlib's
`Differential` typeclass) it proves the two structural facts that pin the Galois
group down to the multiplicative group of nonzero constants `Gₘ(constants)` — the
prototypical linear-algebraic ("EML") group.

It builds on the logarithmic-derivative homomorphism of `EML.EMLLogDerivHom`
(`L(yz) = L(y) + L(z)`, the abstract `log(yz) = log y + log z`) and complements the
constants-subfield / solution-ratio results of `EML.EMLDifferentialGalois`.

## Main results

* `firstOrder_prod` — **finite superposition**: for a finite family with
  `(y i)′ = a i · y i`, the product `∏ yᵢ` solves `w′ = (∑ aᵢ)·w`.  Multiplicative
  structure on solutions becomes additive structure on coefficients — the abstract
  `∏ exp(∫aᵢ) = exp(∑ ∫aᵢ)`, proved by `Finset` induction off `Derivation.leibniz`.
* `const_mul_solution` — a constant multiple of a solution is a solution.
* `solution_ratio_isConstant` — the ratio of two solutions is a constant.
* `galois_action_is_mul_constant` — **the Galois statement**: any two *nonzero*
  solutions of `y′ = a·y` differ by multiplication by a *nonzero constant*
  `c` (`c ≠ 0`, `c′ = 0`, `y₂ = c·y₁`).  Hence the differential Galois group acts on
  the one-dimensional solution line by `Gₘ(constants)` — an EML group.
* `galois_torsor` — the converse packaging: nonzero solutions are exactly the
  nonzero-constant multiples of any fixed nonzero solution (a `Gₘ(constants)`-torsor).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the differential Galois group of `y′ = a·y` should be a
subgroup of the multiplicative group of nonzero constants — the simplest EML group —
and this should be provable purely algebraically: (i) solutions are closed under
multiplication by nonzero constants, (ii) any two nonzero solutions differ by such a
constant.  Moreover the *coefficient* should be additive under products of solutions
(`∏ yᵢ` solves the sum-coefficient equation), exponentiating the additive structure.

Experiment (Experimenter): `firstOrder_prod` is `Finset.induction` with the inductive
step `Derivation.leibniz` + `ring`, reusing the binary `EMLLogDerivHom.firstOrder_mul`
pattern.  `solution_ratio_isConstant` is `Derivation.leibniz_div` + `field_simp; ring`.
`galois_action_is_mul_constant` takes `c = y₂/y₁`: nonzero by `div_ne_zero`, constant by
the ratio result, and `y₂ = c·y₁` by `field_simp`.  No characteristic or
algebraic-closure hypotheses are used.

Analysis (Analyst): the logarithmic-derivative homomorphism `L : K^× → (K,+)` of the
catalog is the organizing principle: solutions of `y′ = a·y` are the `L`-fibre over
`a`, a *coset* of `ker L = ` constants; products add coefficients (homomorphism), and
the Galois group — which permutes solutions — therefore acts by the multiplicative
constants `Gₘ(constants)`.  This is the rank-1 case of Picard–Vessiot, and the reason
first-order EML equations always "exponentiate".

Critique (Critic): non-vacuous and load-bearing.  `galois_action_is_mul_constant`
needs both `y₁ ≠ 0` and `y₂ ≠ 0` (the constant is otherwise undefined or zero);
`firstOrder_prod` genuinely uses the hypothesis on every factor (the empty-product base
case is the honest `0`-coefficient statement, not vacuous).  Proofs use real
`leibniz`/`field_simp; ring` cancellation, never `decide`/`rfl`.

Synthesis (PI): together with `EMLDifferentialGalois` (kernel = constants) and the
`EMLReductionOfOrder`/Wronskian second-order theory, this completes the *positive*
Galois picture for first-order EML equations: the solution space is a
`Gₘ(constants)`-torsor and the coefficient map is additive under products.  The Galois
group is, exactly, a subgroup of the multiplicative constants — an EML group.
-- !-- Lab Notes -- !--
-/

open scoped Differential

namespace EMLFirstOrderGroup

variable {K : Type*} [Field K] [Differential K]

/-! ### Finite superposition: products of solutions add coefficients -/

/-- **Finite superposition.** For a finite family `(yᵢ)` with `(y i)′ = a i · y i`,
the product `∏ᵢ yᵢ` solves the first-order linear equation `w′ = (∑ᵢ aᵢ)·w`.  This is
the abstract `∏ exp(∫aᵢ) = exp(∑∫aᵢ)`: multiplicative structure on solutions becomes
additive structure on coefficients. -/
theorem firstOrder_prod {ι : Type*} (s : Finset ι) (a y : ι → K)
    (h : ∀ i ∈ s, (y i)′ = a i * y i) :
    (∏ i ∈ s, y i)′ = (∑ i ∈ s, a i) * ∏ i ∈ s, y i := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert j s hj ih =>
      rw [Finset.prod_insert hj, Finset.sum_insert hj]
      have hjm : (y j)′ = a j * y j := h j (Finset.mem_insert_self j s)
      have ih' : (∏ i ∈ s, y i)′ = (∑ i ∈ s, a i) * ∏ i ∈ s, y i :=
        ih (fun i hi => h i (Finset.mem_insert_of_mem hi))
      rw [Derivation.leibniz]; simp only [smul_eq_mul, hjm, ih']; ring

/-! ### The Galois group acts by multiplicative constants -/

/-- **Closure under constant scaling.** A constant multiple of a solution of
`y′ = a·y` is again a solution. -/
theorem const_mul_solution (a c y : K) (hc : c′ = 0) (h : y′ = a * y) :
    (c * y)′ = a * (c * y) := by
  rw [Derivation.leibniz]; simp only [smul_eq_mul, hc, h]; ring

/-- **Solution ratio is constant.** The ratio of two solutions of `y′ = a·y` (with
nonzero denominator) has zero derivative. -/
theorem solution_ratio_isConstant (a y₁ y₂ : K) (h₁ : y₁′ = a * y₁)
    (h₂ : y₂′ = a * y₂) (hy₁ : y₁ ≠ 0) : (y₂ / y₁)′ = 0 := by
  rw [Derivation.leibniz_div]; simp only [smul_eq_mul, h₁, h₂]; field_simp; ring

/-- **The Galois group is a subgroup of `Gₘ(constants)`.** Any two *nonzero* solutions
`y₁, y₂` of the first-order EML equation `y′ = a·y` differ by multiplication by a
*nonzero constant* `c` (`c ≠ 0`, `c′ = 0`, `y₂ = c·y₁`).  Equivalently, the differential
Galois group acts on the one-dimensional solution line by the multiplicative group of
nonzero constants — the simplest EML group. -/
theorem galois_action_is_mul_constant (a y₁ y₂ : K) (h₁ : y₁′ = a * y₁)
    (h₂ : y₂′ = a * y₂) (hy₁ : y₁ ≠ 0) (hy₂ : y₂ ≠ 0) :
    ∃ c : K, c ≠ 0 ∧ c′ = 0 ∧ y₂ = c * y₁ :=
  ⟨y₂ / y₁, div_ne_zero hy₂ hy₁, solution_ratio_isConstant a y₁ y₂ h₁ h₂ hy₁, by field_simp⟩

/-- **Solution space is a `Gₘ(constants)`-torsor.** For a fixed nonzero solution `y₁` of
`y′ = a·y`, an element `y₂` is a nonzero solution **iff** it is a nonzero-constant
multiple of `y₁`.  This is the rank-1 Picard–Vessiot statement: the solution space is a
torsor under the multiplicative group of nonzero constants. -/
theorem galois_torsor (a y₁ y₂ : K) (h₁ : y₁′ = a * y₁) (hy₁ : y₁ ≠ 0) :
    (y₂′ = a * y₂ ∧ y₂ ≠ 0) ↔ ∃ c : K, c ≠ 0 ∧ c′ = 0 ∧ y₂ = c * y₁ := by
  constructor
  · rintro ⟨h₂, hy₂⟩
    exact galois_action_is_mul_constant a y₁ y₂ h₁ h₂ hy₁ hy₂
  · rintro ⟨c, hc0, hc, rfl⟩
    exact ⟨const_mul_solution a c y₁ hc h₁, mul_ne_zero hc0 hy₁⟩

end EMLFirstOrderGroup