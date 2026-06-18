# Future Directions: Formal Arithmetic Dynamics of Integer Polynomials

## Hypothesis 1: Reciprocal Sparse Polynomials Obey a Lehmer-Type Gap

**Conjecture.** Every monic reciprocal non-cyclotomic polynomial P ∈ ℤ[X] with at most 7 nonzero coefficients satisfies M(P) ≥ M(L), where L is Lehmer's polynomial.

**Why it might be true.** Among all known integer polynomials with small Mahler measure > 1, Lehmer's polynomial (which is reciprocal with 7 nonzero coefficients) achieves the smallest value. Reciprocal symmetry forces roots to pair as (α, 1/α), constraining the spectral structure. Sparse support further limits the root geometry. The combination of these constraints may force a rigid lower bound.

**Test.** Exhaustive enumeration of monic reciprocal integer polynomials with ≤ 7 nonzero coefficients up to degree 30 and coefficient bound ±2. For each, compute M(P) numerically and verify M(P) ≥ M(L) ≈ 1.17628. A single counterexample refutes the conjecture.

**Formalization path.** If computational evidence supports the conjecture for degree ≤ 20, formalize the exhaustive verification as a certified computation (using `native_decide` or interval arithmetic). The key Lean infrastructure needed: a computable `Polynomial.eval` for ℤ polynomials, certified root isolation, and a verified numerical Mahler measure bound.

**Impact.** A formal proof for bounded degree would be the first machine-checked progress on Lehmer's problem for a nontrivial family.

---

## Hypothesis 2: Entropy Rigidity for Polynomials with One Escaping Root

**Conjecture.** There exists a universal constant c > 0 such that if P ∈ ℤ[X] is monic irreducible with exactly one root α satisfying |α| > 1, then log M(P) = log|α| ≥ c.

**Why it might be true.** When only one root escapes the unit circle, the entire Mahler measure is concentrated in a single eigenvalue. By Dirichlet's unit theorem and the product formula, the escaping root satisfies strong arithmetic constraints. Salem numbers (real algebraic integers > 1 whose conjugates all lie on or inside the unit circle) are exactly this class, and Lehmer's conjecture for Salem numbers is known to be equivalent to the full conjecture.

**Test.** Systematic computation: enumerate monic irreducible integer polynomials of degree ≤ 20 with exactly one root of modulus > 1. Track the minimum log|α| achieved. If it converges to log M(L) ≈ 0.16236, this supports the conjecture with c = log M(L).

**Refutation.** A sequence of polynomials with one escaping root whose log|α| → 0 would refute the conjecture. Such a sequence would simultaneously resolve Lehmer's problem negatively.

**Impact.** Formal verification of this conjecture for fixed degree would reduce Lehmer's problem to the many-escaping-roots case, which is known to satisfy better bounds.

---

## Hypothesis 3: Tropical Support Lower Bound

**Conjecture.** For monic integer polynomials with a fixed support set S ⊂ {0, 1, ..., d} (i.e., nonzero coefficients only at positions in S), the minimal positive log Mahler measure is achieved by a polynomial with reciprocal coefficient symmetry (a_i = a_{d-i}).

**Why it might be true.** Reciprocal polynomials have the tightest root constraint: if α is a root, so is 1/α. This forces roots to cluster near the unit circle, minimizing max(0, log|α|). The tropical support (Newton polygon) determines the asymptotic root distribution; within a fixed support, reciprocal symmetry is the most constrained configuration.

**Test.** For each support set of size ≤ 7 and degree ≤ 12, enumerate all monic integer polynomials with coefficients in {−2, ..., 2} at the support positions. Compare the minimum Mahler measure for reciprocal vs. non-reciprocal polynomials.

**Refutation.** A non-reciprocal polynomial with fixed support achieving strictly smaller Mahler measure than all reciprocal polynomials with the same support.

**Impact.** Would establish reciprocal symmetry as a necessary condition for Lehmer extremals, reducing the search space dramatically.

---

## Hypothesis 4: Companion Matrix Spectral Gap Implies Coefficient Bounds

**Conjecture.** If P ∈ ℤ[X] is monic of degree d with log M(P) < ε for some ε > 0, then the spectral radius of the companion matrix C_P satisfies ρ(C_P) < 1 + f(ε, d) where f(ε, d) → 0 as ε → 0 for fixed d, and moreover the coefficients of P satisfy |a_i| ≤ g(ε, d) for an explicit function g.

**Why it might be true.** Small Mahler measure means roots cluster near the unit circle. By Vieta's formulas, the coefficients are elementary symmetric functions of the roots. When roots are near the unit circle, these symmetric functions are bounded by binomial coefficients. This is essentially Northcott's theorem made quantitative via spectral control.

**Test.** For each degree d ≤ 12 and target log M(P) < 0.5, compute the tightest coefficient bound achievable. Plot |a_i|_max vs. log M to extract the function g empirically. Compare with the theoretical bound from Northcott's theorem (already formalized in Mathlib).

**Refutation.** Finding a family of polynomials with log M → 0 but unbounded coefficients in any position.

**Impact.** An explicit, formally verified version of g(ε, d) would give a finite search algorithm for Lehmer's problem at each degree, converting the open problem into a (potentially enormous) finite computation.

---

## Hypothesis 5: Height–Entropy Equality Formalization

**Conjecture.** For every algebraic integer α, the identity

  deg(α) · h(α) = log M(minpoly_ℤ(α))

can be formalized in Lean 4 using Mathlib's algebraic number theory infrastructure plus at most 10 new lemmas.

**Why it might be true.** Both sides of the equation are well-defined in Mathlib:
- `Polynomial.logMahlerMeasure` is defined and connected to roots.
- `NumberField` and embeddings infrastructure exists.
- `minpoly` is defined and its properties are developed.
The gap is connecting these two worlds: showing that the Mahler measure of the minimal polynomial, defined as a circle integral, equals the sum of logarithmic absolute values over all archimedean embeddings, which is (up to normalization) the logarithmic Weil height.

**Test.** 
1. Formalize the identity for quadratic algebraic integers (degree 2), where the minimal polynomial has exactly 2 roots and the height is directly computable.
2. Extend to cubic algebraic integers.
3. Identify exactly which Mathlib lemmas bridge the gap for general degree.

**Refutation.** If the required Mathlib infrastructure (e.g., product formula, adelic heights) is more than 10 lemmas away from existing development, the "at most 10 new lemmas" claim fails. This is testable by dependency analysis.

**Impact.** Would create the first formal connection between Diophantine height theory and Mahler measure theory, enabling formal attacks on Lehmer's problem via height lower bounds (Dobrowolski, Voutier, etc.).
