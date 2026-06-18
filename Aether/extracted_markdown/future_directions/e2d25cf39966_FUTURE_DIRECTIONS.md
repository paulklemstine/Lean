# Future Directions: Schanuel Conjecture Formal Framework

## Conjecture 1: Bounded-Degree Exponential Independence Heuristic

**Conjecture.** For every `n ≥ 1` and every tuple `z : Fin n → ℂ` of algebraic numbers that are `ℚ`-linearly independent, there is no nonzero polynomial `P ∈ ℚ[x₁, …, xₙ, y₁, …, yₙ]` of total degree at most `D(n) = 2n` such that `P(z₁, …, zₙ, e^{z₁}, …, e^{zₙ}) = 0`.

**Test.** Enumerate tuples of Gaussian integers `a + bi` with `|a|, |b| ≤ 10` and search for polynomial relations up to degree `2n` using the `search_exp_witnesses` algorithm. A single explicit witness disproves the conjecture for the given `D(n)`.

**Impact.** If true, this gives effective bounds on witness degrees, making the formal `NoExpWitnessUpToDeg` predicate computationally useful for certification. If false, the minimal-degree witness would reveal interesting structure about exponential algebraic geometry.

---

## Conjecture 2: Schanuel-Critical Tuples Require Transcendental Coordinates

**Conjecture.** If Schanuel's conjecture is false, any minimal counterexample (Schanuel-critical tuple) must contain at least one coordinate that is transcendental over `ℚ`. Equivalently, the Lindemann–Weierstrass consequence of Schanuel (our Theorem 1) holds unconditionally — a result already known classically, but whose formal proof from first principles (not via Schanuel) would be a significant contribution.

**Test.** Attempt to formalize the classical Lindemann–Weierstrass theorem directly in Lean 4 (without the Schanuel axiom). Success would confirm the conjecture's plausibility; failure would identify specific gaps in Mathlib's analytic infrastructure.

**Impact.** A direct formal proof of Lindemann–Weierstrass would complete the circle: our axiomatic derivation shows *structural correctness* (the theorem follows from Schanuel), while a direct proof would give *absolute certainty* (no axiom needed).

---

## Conjecture 3: Predimension Subadditivity Under Tuple Concatenation

**Conjecture.** Define the Schanuel predimension `δ(z) = (algebraic independence rank of {zᵢ, exp(zᵢ)}) - (ℚ-linear dimension of {zᵢ})`. Then for any two tuples `x` and `y`, the concatenation satisfies `δ(x ⊕ y) ≤ δ(x) + δ(y)`.

**Test.** Compute `δ` numerically for random pairs of algebraic tuples and their concatenations using the `compute_schanuel_predimension` function. Check whether the inequality holds across 10,000 random trials with Gaussian integer entries of absolute value ≤ 5.

**Impact.** Subadditivity of predimension is a key axiom in Hrushovski's amalgamation constructions. Formalizing it would connect our framework to model-theoretic methods and enable formal proofs about exponential algebraic closure operators.

---

## Conjecture 4: Ax–Schanuel for Formal Power Series

**Conjecture.** The formal analogue of Schanuel's conjecture holds for formal power series over `ℚ`: if `f₁, …, fₙ ∈ ℚ[[t]]` are `ℚ`-linearly independent, then the transcendence degree of `ℚ(f₁, …, fₙ, exp(f₁), …, exp(fₙ))` over `ℚ` is at least `n`. (This is Ax's theorem, proved in 1971.)

**Test.** Formalize the statement of Ax's theorem in Lean 4 using `PowerSeries` from Mathlib. Attempt to prove it — the proof uses differential algebra (the exponential function satisfies `exp' = exp`) and should be accessible with Mathlib's `PowerSeries` and `Derivation` APIs.

**Impact.** Ax's theorem is the only unconditionally proved case of Schanuel-type results in full generality. Formalizing it would provide the first verified instance of the Schanuel lower bound and serve as a foundation for formal functional transcendence theory.

---

## Conjecture 5: Witness Degree Growth Rate

**Conjecture.** For tuples `z` where exponential algebraic dependence exists (e.g., `z = (πi)` with the relation `exp(πi) + 1 = 0`), the minimum degree of an `ExpAlgDependenceWitness` in the combined variables `(z, exp(z))` grows at most polynomially in the height of the coefficients of `z` (when `z` consists of algebraic numbers). Specifically, for `z` with algebraic height at most `H`, the minimum witness degree is `O(H^{2n})`.

**Test.** For algebraic numbers of increasing height (rationals `p/q` with `max(|p|,|q|) ≤ H`), search for witnesses and record the minimum degree found. Plot degree vs. height and fit a polynomial model.

**Impact.** Effective degree bounds would transform the witness search from a heuristic tool into a decision procedure (for algebraic inputs). This connects to Baker's effective methods in transcendence theory and could yield explicit irrationality/transcendence measures.
