# Future Directions: The Rank-of-Apparition as a Lattice Adjoint

## Synthesis

This cycle isolated and proved the *algebraic backbone* of the Fibonacci rank of
apparition. Building directly on the catalog file
`Cryptography/FibonacciDivisibilityLattice.lean` (the `FibLattice` namespace,
itself built on the single catalog identity `Nat.fib_gcd`), we showed that the
entry-point map `entry : (ℕ_{>0}, ∣) → (ℕ_{>0}, ∣)` is not merely a function but a
**structure-preserving morphism of divisibility lattices**. The new file is
`Cryptography/FibonacciEntryHomomorphism.lean`.

The unifying lens is an *adjunction*: the catalog apparition law
`fib_dvd_iff_entry_dvd : m ∣ fib n ↔ entry m ∣ n` is literally a Galois connection
between `(ℕ_{>0}, ∣)` and itself, with `entry` as left adjoint to `fib`. From this
single fact, every structural property fell out by pure order theory, with **no
further appeal to the Fibonacci recurrence**.

## Results Summary

All four results are proved with `sorry = 0` and depend only on the standard axioms
`propext, Classical.choice, Quot.sound`.

* `FibEntry.entry_one : entry 1 = 1` — the morphism is unital.
* `FibEntry.entry_dvd_of_dvd : a ∣ b → entry a ∣ entry b` — monotone for `∣`.
* `FibEntry.entry_lcm : entry (lcm a b) = lcm (entry a) (entry b)` — the central
  **join-homomorphism law**: rank of least-common-apparition = lcm of ranks.
* `FibEntry.entry_fib : 3 ≤ k → entry (fib k) = k` — `entry` retracts `fib`,
  exhibiting `fib` as a poset embedding of `(ℕ_{≥3}, ∣)`.

The decisive structural insight is that, being a *left* adjoint, `entry` preserves
joins (lcm) but is **not** expected to preserve meets (gcd) — which immediately
predicts the failure of any naive `entry (gcd a b) = gcd (entry a) (entry b)`.

## Research Directions

### 1. The meet defect: quantify failure of `entry (gcd a b) = gcd (entry a) (entry b)`

Conjecture: for all `a, b > 0`, `entry (gcd a b) ∣ gcd (entry a) (entry b)`, and
the quotient `gcd (entry a) (entry b) / entry (gcd a b)` can be arbitrarily large,
yet equals `1` whenever `a, b` are powers of a common prime.

The key insight is that a left adjoint preserves joins but only laxly interacts
with meets, so the *direction* of divisibility in the meet law is forced
(`entry (gcd) ∣ gcd (entry)`) even though equality must fail — the defect measures
exactly how far `entry` is from being a lattice isomorphism. Why now? We have just
proved the join law `entry_lcm` and the monotonicity `entry_dvd_of_dvd` from which
the easy inclusion is immediate; the falsifiable content (unbounded defect) is a
finite search away and would pin the morphism's type precisely.

### 2. Coprime multiplicativity and prime-power reduction

Conjecture: for coprime `a, b > 0`, `entry (a * b) = lcm (entry a) (entry b)`,
hence `entry m` is determined by its values `entry (p^e)` over the prime powers in
the factorization of `m`.

The key insight is that for coprime `a, b` we have `lcm a b = a * b`, so the
already-proven `entry_lcm` *specializes* to a full multiplicativity statement —
reducing the entire apparition function to prime-power data. Why now? This is the
lowest-hanging generalization of the theorem just proved: it converts a lattice law
into an arithmetic-function law and is the precise hypothesis needed to make
apparition ranks *computable* from a factorization, the workhorse of Lucas-sequence
primality certificates.

### 3. The Wall prime-power law and Wall–Sun–Sun primes

Conjecture: for every prime `p` there is `e₀ ≥ 1` with
`entry (p^(k+1)) = p * entry (p^k)` for all `k ≥ e₀`, and `e₀ = 1` unless `p` is a
Wall–Sun–Sun prime (none are known below `2^64`).

The key insight is that the prime-power ranks form a near-geometric ladder governed
by the `p`-adic valuation of `fib (entry p)`, so deviations from `e₀ = 1` are
exactly the Wall–Sun–Sun anomaly — a famous open condition tied to Fermat's Last
Theorem's first case. Why now? Directions 2 reduces all apparition data to prime
powers, so this ladder is the *only* remaining unknown; formalizing it would give a
Lean-verified statement of the Wall–Sun–Sun condition as a property of `entry`.

### 4. Generalization to arbitrary strong divisibility sequences

Conjecture: the apparition law, `entry_lcm`, and `entry_fib` hold verbatim for any
nondegenerate Lucas sequence `U_n` (and more generally any strong divisibility
sequence with `gcd(U_m, U_n) = U_{gcd(m,n)}` and `U` injective past a threshold),
with `fib` replaced by `U`.

The key insight is that *none* of our proofs used the Fibonacci recurrence — they
used only the gcd identity and injectivity — so the entire homomorphism package is
really a theorem about strong divisibility sequences abstracted from any particular
one. Why now? With the Fibonacci case fully verified as a template, abstracting the
hypotheses into a typeclass `StrongDivSeq` is a mechanical refactor that would
instantly cover Mersenne numbers, Lucas numbers, and elliptic divisibility
sequences — a genuine cross-domain bridge.

### 5. Primitive divisors via `entry_fib`: a route to the Carmichael tail

Conjecture: a prime `p` is a *primitive* prime divisor of `fib k` (dividing `fib k`
but no earlier `fib j`) if and only if `entry p = k`; consequently `fib k` has a
primitive divisor iff some prime has apparition rank exactly `k`.

The key insight is that `entry_fib` together with the apparition law converts the
analytic "primitive divisor" predicate into the purely structural equation
`entry p = k`, replacing a search over divisors of `fib k` by a statement about the
*fibers* of `entry`. Why now? The catalog's `Shared/CarmichaelProof.lean` still
carries one `sorry` (the composite tail `n > 10000` of Carmichael's primitive
divisor theorem); recasting primitivity as `entry p = k` reframes that open tail as
a surjectivity-of-`entry` question, a fundamentally more tractable structural
target than the current direct estimate.
