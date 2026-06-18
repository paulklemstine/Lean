# Future Directions: Fibonacci–Pythagorean Number Theory and Ramsey Combinatorics

## What We Built

This cycle formalized connections between Fibonacci numbers, Pythagorean triples, and Ramsey theory in Lean 4, producing 13 fully-proved theorems with zero `sorry` across two new files, plus filling a critical sorry in the Ramsey LLL module and eliminating 12 sorries in the FiberGraph module.

The key results include: the Fibonacci sum-of-squares identity, Cassini's identity, the Pythagorean parametrization, Fibonacci modular periodicity (Pisano period existence), the sum-of-two-squares mod-4 obstruction, and the Ramsey configuration space nonemptiness theorem via the probabilistic method.

---

## Direction 1: Tight Fibonacci Entry Point Bounds

We proved that every prime divides some positive-index Fibonacci number. The classical result is much stronger: the entry point α(p) satisfies α(p) ≤ p + 1, with equality iff p ≡ ±2 (mod 5). Even stronger: α(p) | p - 1 when p ≡ ±1 (mod 5) and α(p) | 2(p + 1) when p ≡ ±2 (mod 5).

The key insight is that the Fibonacci sequence in the finite field F_p satisfies a linear recurrence whose characteristic polynomial x² - x - 1 splits or remains irreducible depending on the Legendre symbol (5/p). When it splits, the roots are (p-1)-th roots of unity by Fermat's little theorem, giving α(p) | p-1. When it doesn't split, one works in F_{p²} where the Frobenius endomorphism swaps the roots, giving α(p) | 2(p+1).

Why now? Our `fib_mod_periodic` proof already establishes the pigeonhole infrastructure for Fibonacci periodicity. The missing piece is connecting the Pisano period to the multiplicative structure of F_p via the characteristic polynomial of the Fibonacci recurrence. Mathlib's `ZMod` API and Frobenius endomorphism theory are now mature enough to support this.

## Direction 2: Primitive Pythagorean Triple Bijection

We proved that the (m²-n², 2mn, m²+n²) parametrization generates Pythagorean triples. The deeper theorem is that this is a *bijection* between pairs (m, n) with m > n > 0, gcd(m,n) = 1, m - n odd, and primitive Pythagorean triples (up to swapping legs).

The key insight is that Mathlib already has `PythagoreanTriple.isPrimitiveClassified_of_coprime`, which proves the classification over ℤ. The missing formalization is the ℕ-level bijection: extracting the unique (m, n) from a primitive triple and proving the round-trip properties. This requires careful handling of ℕ subtraction (m² - n² is only well-defined when m > n) and parity constraints.

Why now? The `PythagoreanClassification.lean` file establishes the forward direction (parameters → triple). The reverse direction would complete a full bijection theorem, which has applications in counting primitive triples below a bound (related to the Gauss circle problem).

## Direction 3: LLL-Based Ramsey Lower Bounds

We proved `ramsey_config_space_nonempty` using the first-moment method (2·C(n,k) < 2^C(k,2) implies existence). The full Lovász Local Lemma (LLL) gives a strictly stronger result: it only requires e·p·(d+1) ≤ 1 where d is the *local* dependency degree, not the total event count.

The key insight is that the dependency degree d = C(k,2)·C(n-2,k-2) grows like n^{k-2}, while the total event count C(n,k) grows like n^k. This polynomial gap means the LLL certifies R(k,k) > C·k·2^{k/2}, a factor of ~k better than the first-moment bound. Our `card_dependent_subsets_le` theorem already bounds d, and our edge-disjointness theorem establishes the independence structure.

Why now? The `RamseyLLL.lean` module now has a complete proof that the first-moment criterion implies nonemptiness. Upgrading to the full LLL requires formalizing the symmetric LLL (a purely combinatorial statement about dependency graphs) and plugging in the dependency bound. The framework is ready.

## Direction 4: Fibonacci–Lucas Hybrid Identities

Cassini's identity F(n)·F(n+2) - F(n+1)² = (-1)^{n+1} is one identity in a rich family connecting Fibonacci and Lucas numbers. The Lucas sequence L(n) satisfies L(n) = F(n-1) + F(n+1), and there are identities like F(2n) = F(n)·L(n), L(n)² - 5·F(n)² = 4·(-1)^n, and F(m+n) = F(m)·F(n+1) + F(m-1)·F(n).

The key insight is that these identities all arise from the matrix representation [[1,1],[1,0]]^n = [[F(n+1), F(n)], [F(n), F(n-1)]]. Formalizing this matrix identity in Lean would give a unified proof framework for the entire family. Mathlib's `Matrix.pow` and `Matrix.det` API can handle the 2×2 case directly.

Why now? Our Cassini identity proof uses direct induction. The matrix approach would be more powerful and compositional, yielding dozens of identities from a single base theorem. The `fib_sum_squares` identity also follows immediately from the matrix trace.

## Direction 5: Computational Verification of Carmichael's Theorem

The `CarmichaelComposite.lean` file in the project attempts to prove that for composite n ≥ 14, F(n) has a primitive prime divisor. The approach combines entry-point theory with computational verification of the "coprime part" of F(n). The file has a `native_decide` proof for n ≤ 10000 but relies on unproved helper files for the large-n case.

The key insight is that for composite n, F(n) always has a prime factor whose entry point equals n (not a proper divisor of n). The coprime-part computation `fibCoprimePart` removes all prime factors of F(d) for proper divisors d | n. If the result exceeds 1, a primitive divisor exists. For large n, growth bounds on Fibonacci numbers (F(n) > φ^{n-1} where φ = (1+√5)/2) combined with the bound on products of F(d) for d | n suffice.

Why now? Our `fib_entry_point_exists` and `fib_mod_periodic` theorems provide the foundation. The missing piece is the growth bound argument for large n, which requires formalizing the Binet formula approximation F(n) ≈ φ^n/√5 with explicit error bounds. Mathlib's `Real.rpow` and `Real.log` API can support this.
