# Future Directions — Fibonacci ranks of apparition & primitive prime divisors

This cycle established a fully-formalized rank-of-apparition toolkit
(`Catalog/Speculative/AutoResearch/FibonacciPrimitiveDivisors.lean`) and closed
the prime-index case of Carmichael's primitive divisor theorem
(`Catalog/Shared/CarmichaelHelper.lean`).  The composite case for large indices
(`> 10000`) remains the single open `sorry` in `Shared/CarmichaelProof.lean`.
The following conjectures are precise and falsifiable, ordered by ambition.

## C1. Law of apparition (rank divides `p ∓ 1`)
For a prime `p ≠ 2, 5`, the rank `fibRank p` divides `p - 1` if `p ≡ ±1 (mod 5)`
and divides `p + 1` if `p ≡ ±2 (mod 5)`.  Equivalently, `fibRank p ∣ p - (5/p)`
where `(5/p)` is the Legendre symbol.
*Test path:* work in `ZMod p`, identify `F` with the Binet matrix
`![![1,1],![1,0]]^n`, and use that this matrix has order dividing `p - (5/p)`
in `GL₂(ZMod p)`.  A computational sanity check over `p < 1000` is a cheap
first falsification gate.

## C2. Rank is "almost multiplicative"
For coprime `a, b > 0`, `fibRank (a*b)`-style statements fail, but the dual holds:
the *index* rank satisfies `fibRank` of a prime power `p^e` equals
`p^(e-1) * fibRank p` for all but finitely many "Wall–Sun–Sun" exceptions.
*Conjecture (testable):* for every prime `p < 10^6` and `e ≥ 1`,
`fibRank (p^e) = p^(e-1) * fibRank p`.  (A counterexample would be a
Wall–Sun–Sun prime — none are known.)

## C3. Primitive part lower bound (route to the open composite case)
Define the primitive part `Φ*(n) := ∏_{d ∣ n} (F d)^{μ(n/d)}` (Möbius inversion
of `F`).  Conjecture: for `n ≥ 30`, `Φ*(n) > n`.  This is the analytic engine
that would discharge the remaining `sorry` for composite `n > 10000`: every
primitive prime divisor of `F n` divides `Φ*(n)`, and the only non-primitive
prime that can divide `Φ*(n)` divides `n` to the first power, so `Φ*(n) > n`
forces a primitive divisor.
*Test path:* prove `|Φ*(n)| ≥ φ^{totient(n) - small}` via Binet, then compare to
`n`.  Verify the inequality computationally for `30 ≤ n ≤ 5000` first.

## C4. Full Carmichael from the lattice + bound
Combine C3 with the already-proved `primitive_iff_fibRank_eq` and
`fib_dvd_iff_fibRank_dvd` to obtain: for every `n ∉ {1, 2, 6, 12}`, `F n` has a
primitive prime divisor.  This is the classical theorem (Carmichael 1913) and
would replace BOTH the `native_decide` finite check and the large-`n` `sorry`
with a uniform proof.
*Falsifiable milestone:* state and prove the clean exceptional-set version
`(∀ n, primitiveDivisorExists (F n) ↔ n ∉ ({1,2,6,12} : Finset ℕ))`.

## C5. Lucas-sequence generalization
The rank toolkit used only strong divisibility (`Nat.fib_gcd`) and monotonicity.
Conjecture: for any nondegenerate Lucas sequence `U` with `gcd(U_m, U_n) = U_{gcd(m,n)}`
and eventual strict monotonicity, the analogues of `fibRank_dvd_index`,
`fib_dvd_iff_fibRank_dvd`, and `primitive_iff_fibRank_eq` hold verbatim.
*Test path:* abstract the three Fibonacci-specific inputs into a typeclass
`StrongDivSeq` and re-derive the toolkit; instantiate at `Pell` and `Mersenne`
to confirm reuse.
