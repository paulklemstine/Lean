# Future Directions: Symmetric-Power Euler Factor Theory

## Overview

The formal development establishes that the symmetric-power Euler factor
∏(1 − α^{n−k}β^k X) is a universal function of the trace t = α+β and
determinant d = αβ, not just as a whole product but **coefficientwise**.
This opens several precise, falsifiable lines of investigation.

---

## Hypothesis 1: Bounded Holonomicity

**Conjecture:** For each fixed j ≥ 1, the coefficient family
n ↦ c_{n,j}(t,d) = [X^j] Φ_n(t,d; X) satisfies a linear recurrence
of order exactly j+1 with coefficients that are themselves polynomials
in (t, d).

**Evidence:** Computational experiments (see `applications.py`) detect:
- j=1: order 2 recurrence (coefficients involve t, d)
- j=2: order 3 recurrence
- j=3: order 4 recurrence
- j=4: order 5 recurrence

This pattern "order = j+1" holds for all tested values of (t,d).

**Test:** Compute coefficient families for j ≤ 10 and n ≤ 100 over
several (t,d) values. Verify:
(a) The recurrence order is always j+1.
(b) The recurrence coefficients, as functions of (t,d), are the same
    universal polynomials regardless of which specific (t,d) is used.

**Falsification criterion:** Find a j and (t,d) where the minimal
recurrence order differs from j+1, or where the recurrence coefficients
are not polynomial in (t,d).

**Impact if true:** This would prove the entire coefficient system is
D-finite in the symmetric-power index n, enabling O(n) computation of
any individual coefficient (after O(j²) precomputation of the recurrence).

---

## Hypothesis 2: Palindromic Symmetry of Coefficient Polynomials

**Conjecture:** For each n, the Euler polynomial Φ_n(t,d;X) satisfies
a functional equation relating its coefficients:

c_{n,j}(t,d) = (-1)^{n+1} · d^{n(n+1)/2} · c_{n, n+1-j}(t, d) / d^{?}

More precisely, after appropriate renormalization by powers of d,
the coefficient sequence [c_{n,0}, ..., c_{n,n+1}] is palindromic
up to sign.

**Evidence:** The symbolic computation in Application 4 shows:
- Φ_2: coefficients [1, -(t²-d), (t²d - d²), -d³]
  → After dividing c_{2,j} by d^{j(j-1)/2}: palindromic up to sign.
- Similar patterns for Φ_3, Φ_4, Φ_5, Φ_6.

**Test:** Compute the renormalized coefficient vectors for n ≤ 20 and
check palindromicity. Determine the exact renormalization factor.

**Falsification criterion:** Find n where no renormalization makes
the coefficient sequence palindromic up to sign.

**Impact if true:** This would connect symmetric-power Euler factors to
the theory of self-dual L-functions and functional equations, providing
a new route to formal verification of functional equations for
symmetric-power L-functions.

---

## Hypothesis 3: Positivity after Chebyshev Change of Variables

**Conjecture:** After the substitution t → 2cos(θ)√d (i.e., working
at the edge of the unitary locus), the coefficient polynomials
E_{n,j}(t,d) have nonneg integer coefficients when expanded in
the basis {U_k(t/(2√d)) · d^m} where U_k is the k-th Chebyshev
polynomial of the second kind.

**Evidence:** At d=1, the coefficients c_{n,j}(t,1) specialize to
polynomials in t that are known to have positive coefficients in the
Chebyshev basis for small n. The weight multiset at d=1 becomes
{a^{n-k}(1/a)^k : k} = {a^{n-2k}}, which are characters of
SU(2) representations.

**Test:** For n ≤ 12 and all j, expand E_{n,j}(t,d) in the Chebyshev
basis and check for nonnegativity.

**Falsification criterion:** Find n, j where a Chebyshev coefficient is
negative.

**Impact if true:** This would establish a plethystic positivity result
connecting symmetric-power Euler factors to the combinatorics of
Schur positivity and representation-theoretic multiplicity formulas.

---

## Hypothesis 4: Rationality of the Bivariate Generating Function

**Conjecture:** The bivariate generating series

F(u, X) = ∑_{n≥0} Φ_n(t,d; X) · u^n

is a rational function of u (with coefficients in Z[t,d][[X]]).
Equivalently, for each fixed j, the single-variable series

F_j(u) = ∑_{n≥0} c_{n,j}(t,d) · u^n

is rational in u over Z[t,d].

**Evidence:** Hypothesis 1 (if true) implies each F_j(u) is rational,
since a sequence satisfying a linear recurrence with constant
coefficients has a rational generating function. The detected
recurrence orders j+1 predict the degree of the denominator of F_j.

**Test:** For j ≤ 6, compute the rational function F_j(u) from the
detected recurrence. Verify that the numerator and denominator
polynomials have integer coefficients in (t,d,u).

**Falsification criterion:** Find j where the generating function
is not rational (e.g., the recurrence coefficients depend on n,
making the sequence only D-finite, not C-finite).

**Impact if true:** This would place the entire theory within the
framework of rational generating functions and automata theory,
enabling efficient computation of asymptotics and p-adic
interpolation of Euler factor families.

---

## Hypothesis 5: Rank-3 Obstruction

**Conjecture:** The trace-determinant closure phenomenon is special to
rank 2. For GL₃, the analogous Euler factor
∏_{i+j+k=n} (1 − α^i β^j γ^k X)
does NOT depend only on the elementary symmetric polynomials
e₁ = α+β+γ, e₂ = αβ+αγ+βγ, e₃ = αβγ.

More precisely: there exist n ≥ 2 and two triples (α,β,γ), (α',β',γ')
with the same e₁, e₂, e₃ but different Euler factors.

**Evidence:** For rank 2, the key is that all power sums S_m = α^m + β^m
are determined by (e₁, e₂). For rank 3, S_m = α^m + β^m + γ^m is
determined by (e₁, e₂, e₃), but the weight multiset of Sym^n involves
monomials α^i β^j γ^k (i+j+k = n) whose power sums involve
∑ α^{mi} β^{mj} γ^{mk}, which are NOT just power sums of the
original eigenvalues. So the closure argument breaks down.

**Test:** For n = 2, compute the Sym² Euler factor for GL₃ at two
triples with the same characteristic polynomial. Check if the factors
differ.

For example: (α,β,γ) = (1, 2, 3) vs (α',β',γ') obtained by a
nontrivial permutation — wait, permutations preserve the Euler factor.
Need genuinely different roots of the same cubic.

Use x³ - 6x² + 11x - 6 = (x-1)(x-2)(x-3) and compare with a
different cubic with the same e₁=6, e₂=11, e₃=6... but the cubic
is uniquely determined by its coefficients! So for rank 3, the
Euler factor IS determined by the characteristic polynomial (trivially).

The question is really: is the Euler factor of Sym^n determined by
(e₁, e₂, e₃) in a UNIVERSAL way that does not require splitting?
This is true for rank 2 (our main theorem). For rank 3, it should
also be true (by the same representation-theoretic argument), but
the explicit recurrence structure is more complex.

**Revised conjecture:** The trace-determinant closure extends to rank 3,
but the recurrence structure becomes significantly more complex:
instead of a 2-step recurrence in n, it becomes a multi-step
recurrence involving all three elementary symmetric polynomials.

**Falsification criterion:** Exhibit a universal coefficient that
cannot be expressed as a polynomial in (e₁, e₂, e₃).

**Impact:** Understanding the rank-3 case is essential for
extending the theory to GL₃ automorphic forms and higher-rank
Langlands functoriality.
