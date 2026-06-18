# Future Directions: Schanuel's Conjecture Formalization

## 1. Full Lindemann-Weierstrass from Schanuel

The natural next step is proving `schanuel_implies_lindemann_weierstrass_full` — that Schanuel's Conjecture implies the full Lindemann-Weierstrass theorem: if α₁,...,αₙ are ℚ-linearly independent algebraic numbers, then exp(α₁),...,exp(αₙ) are algebraically independent over ℚ. The key insight is that this requires a "trdeg tower" lemma: if S ⊆ T generates an algebra where every element of S is algebraic, then trdeg(adjoin T) = trdeg(adjoin (T \ S)). This should follow from `Algebra.IsAlgebraic` transitivity properties already in Mathlib but requires careful subalgebra manipulation. Why now? The infrastructure for `AlgebraicIndependent` and `trdeg` in Mathlib is mature enough to support this argument, and the single-element case proved here validates the approach.

## 2. Schanuel implies algebraic independence of e and π

Conjecture: Under `SchanuelProperty`, the pair (e, π) is algebraically independent over ℚ. The proof would use SC with z = (1, iπ), observing that these are ℚ-linearly independent and exp gives (e, -1). Since -1 and 1 are rational, the trdeg ≥ 2 must come from e and iπ. The key insight is that algebraic independence of {e, iπ} over ℚ implies algebraic independence of {e, π} because i is algebraic over ℚ, so ℚ(e, iπ) is algebraic over ℚ(e, π) and vice versa. Why now? This would connect the formalization to one of the most famous open problems in number theory (whether e + π is irrational), demonstrating the power of SC as a unifying principle.

## 3. Conditional transcendence of iterated exponentials

Conjecture: Under `SchanuelProperty`, for any nonzero algebraic α, the tower e, eᵉ, eᵉᵉ, ... consists of algebraically independent elements. The key insight is that SC can be applied iteratively: at each stage, the previous tower elements are transcendental (by the Hermite-Lindemann consequence), and the new element exp(previous) adds a fresh transcendence degree because the previous elements, while transcendental, are "independent" from the exponential of the new input. Why now? The Hermite-Lindemann single case is now proved, providing the base case for the induction. The main challenge is formalizing the "cumulative independence" argument.

## 4. Unconditional results: direct proof of e transcendence

Rather than assuming SC, prove the transcendence of e directly in Lean using Hermite's classical argument (1873). The key insight is that Hermite's proof uses only integer polynomial evaluations and factorial divisibility — no advanced algebra. Specifically, for any polynomial f(x) with integer coefficients, the integral ∫₀^∞ f(t)e⁻ᵗ dt can be evaluated in terms of f and its derivatives at 0, leading to a contradiction if e = p/q. Why now? Mathlib has the necessary integration theory (`MeasureTheory.integral`) and polynomial infrastructure. This would complement the conditional results by providing an unconditional anchor point.

## 5. Ax-Schanuel for function fields

The Ax-Schanuel theorem (proved by James Ax, 1971) is the function field analogue of Schanuel's Conjecture: it holds unconditionally for formal power series and differential fields. The key insight is that Ax's proof is algebraic/differential-algebraic rather than transcendence-theoretic, using the Kolchin topology and differential dimension polynomials. Why now? Formalizing Ax-Schanuel would (a) provide a proved theorem in the same family as SC, (b) exercise Mathlib's differential algebra infrastructure, and (c) potentially provide tools for attacking SC itself via specialization arguments. The connection to o-minimal structures (Pila-Wilkie) makes this particularly timely for connections to model theory.
