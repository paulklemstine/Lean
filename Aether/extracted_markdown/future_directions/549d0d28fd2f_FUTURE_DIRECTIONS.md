# Future Directions: Fibonacci Entry Point Theory and Primitive Divisors

## 1. Full Carmichael Primitive Divisor Theorem

The entry point machinery developed here (fibEntryPoint, its divisibility property,
and the primitive divisor characterization) provides exactly the framework needed
to prove Carmichael's theorem: for all n ≥ 13, F(n) has a primitive prime divisor.

The key insight is that the entry point characterization reduces Carmichael's theorem
to showing that for each n ≥ 13, there exists a prime p with fibEntryPoint p = n,
which can be established by analyzing the "coprime part" of F(n) — the quotient after
removing all prime factors that appear in F(d) for proper divisors d | n.

Why now? The `isPrimitivePrimeDivisor_iff` theorem gives an exact algebraic criterion
for primitive divisors in terms of entry points. Combined with computational verification
for small cases (which Lean's `native_decide` can handle for n ≤ 10000) and analytic
growth bounds for large n, a complete proof is within reach.

## 2. Pisano Period Exact Formula

The `fib_periodic_mod` theorem establishes existence of periodicity mod m, but does not
characterize the minimal period π(m) (the Pisano period). A natural conjecture is:

**Conjecture**: For prime p ≠ 5, π(p) divides p² − 1. More precisely, π(p) divides
p − 1 if p ≡ ±1 (mod 5), and π(p) divides 2(p + 1) if p ≡ ±2 (mod 5).

The key insight is that the Fibonacci sequence mod p is governed by the splitting behavior
of x² − x − 1 in F_p, which depends on whether 5 is a quadratic residue mod p. This
connects Pisano periods to the Legendre symbol (5/p) and quadratic reciprocity.

Why now? The periodicity infrastructure is in place. The connection to quadratic residues
can leverage Mathlib's existing `ZMod.legendreSym` and `QuadraticReciprocity` machinery.

## 3. Fibonacci Representations and Zeckendorf's Theorem

Every positive integer has a unique representation as a sum of non-consecutive Fibonacci
numbers (Zeckendorf's theorem). This is a constructive result that connects to the
greedy algorithm for Fibonacci representations.

**Conjecture**: The Zeckendorf representation can be computed by the greedy algorithm,
and the number of terms in the representation of n is O(log n / log φ) where φ is the
golden ratio.

The key insight is that the proof of existence uses the entry point theory indirectly:
the gap condition (no consecutive Fibonacci numbers) is forced by the identity
F(k) + F(k+1) = F(k+2), which collapses adjacent terms. Uniqueness follows from
a counting argument using the Cassini identity proved here.

Why now? The `fib_cassini` identity and the strong induction pattern used in
`fib_periodic_mod` provide the exact proof technology needed. Mathlib's `Finset`
API handles the representation as a finite set of indices.

## 4. Entry Point and the ABC Conjecture for Fibonacci

A deep open question is whether the entry point function α(p) satisfies
α(p) > p^ε for some ε > 0 and all sufficiently large primes p. This is
related to the ABC conjecture applied to Fibonacci numbers.

**Conjecture**: For every ε > 0, there exist only finitely many primes p with
α(p) < p^ε (the "Wall-Sun-Sun prime" generalization).

The key insight is that if α(p) is very small relative to p, then F(α(p)) has
an unusually large prime factor relative to its size, creating tension with
the ABC conjecture. The entry point divisibility theorem proved here
(`fibEntryPoint_dvd`) is the foundational tool for any progress on this question.

Why now? While a full resolution likely requires ABC, partial results bounding
α(p) ≥ c·log(p) for an explicit constant c are accessible using the Pisano
period bounds and our periodicity theorem. Even formalizing the precise
relationship between entry points and ABC would be novel.

## 5. Generalized Entry Points for Lucas Sequences

The Fibonacci sequence is a special case of a Lucas sequence U_n(P, Q) with P = Q = 1.
The entry point theory generalizes: for any Lucas sequence, if p | U_n then α(p) | n.

**Conjecture**: For Lucas sequences U_n(P, Q) with Δ = P² − 4Q ≠ 0, the entry point
α(p) of a prime p ∤ 2QΔ satisfies: α(p) | p − (Δ/p), where (Δ/p) is the Legendre symbol.

The key insight is that the proof of `fibEntryPoint_dvd` used only the GCD property
(fib_dvd_of_dvd_gcd), which generalizes to all Lucas sequences via the analogous
identity gcd(U_m, U_n) = U_{gcd(m,n)}. The Cassini identity also generalizes:
U_{n+1}² − P·U_{n+1}·U_n + Q·U_n² = Q^n.

Why now? The proof architecture (entry point → divisibility → periodicity → primitive divisors)
is modular and transfers directly. Mathlib has partial infrastructure for general linear
recurrences that could serve as a foundation.
