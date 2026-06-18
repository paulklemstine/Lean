# Future Directions — Fibonacci Entry-Point Reciprocity

This cycle delivered `Catalog/Algebra/FibEntryPointReciprocity.lean`, a fully verified
(0 sorries) development of the **law of apparition** for Fibonacci numbers:

- `fib_p_eq_legendre` : `F_p ≡ (5/p) (mod p)` (Fibonacci Euler criterion).
- `fib_dvd_p_sub_legendre` : `p ∣ F_{p - (5/p)}` (reciprocity / apparition law).
- `fib_dvd_p_sub_one_of_residue`, `fib_dvd_p_add_one_of_nonresidue` : the two cases.
- `fib_dvd_psq_sub_one` / `fibEntry_dvd_psq_sub_one` : the Legendre-free corollary
  `z(p) ∣ p² − 1`.

The proof engine is the *golden ring* `R = (ℤ/p)[x]/(x²−x−1)`, the identity
`φⁿ = Fₙ·φ + Fₙ₋₁`, and the Frobenius endomorphism. The conjectures below are framed
to reuse this exact machinery.

## Conjecture 1 — Lucas Euler criterion (companion of `fib_p_eq_legendre`)
For every odd prime `p`, the Lucas numbers satisfy `L_p ≡ 1 (mod p)`.
**Testable form.** In the golden ring, `φᵖ + (1−φ)ᵖ = L_p` and the Frobenius twist
`sᵖ = (5/p)·s` (already proved here as `s_pow_p`) forces the `1`-coordinate to be `1`
independently of `(5/p)`. Combined with `fib_p_eq_legendre` this yields the sharp pair
`F_{p+1} ≡ (1+(5/p))/2`, `F_{p−1} ≡ (1−(5/p))/2 (mod p)`. Prove the full `2×2` apparition
table as one theorem.

## Conjecture 2 — Sharpness of the apparition divisor
The bound `z(p) ∣ p − (5/p)` is "almost tight": for a positive-density set of primes
`p`, `z(p) = p − (5/p)` exactly (the maximal-rank primes). More precisely, `(p−(5/p))/z(p)`
is bounded and equidistributes among small divisors.
**Testable form.** Define `apparitionIndex p := (p − (5/p)) / z(p)` and verify by
`decide`/`native_decide` over `p ≤ N` that it lies in a fixed finite set; conjecture the
limiting frequency of `apparitionIndex p = 1`.

## Conjecture 3 — General Lucas-sequence reciprocity (discriminant `D`)
Let `U_n` be the Lucas sequence of `x² − a x − b` with discriminant `D = a² + 4b`.
Then for every prime `p ∤ 2bD`, `p ∣ U_{p − (D/p)}`.
**Testable form.** Replicate the golden-ring construction with
`R_D = (ℤ/p)[x]/(x² − a x − b)`, `s = 2x − a` (so `s² = D`), and the same Frobenius
computation. The Fibonacci case is `a = b = 1`, `D = 5`. This generalizes the entire
file in one stroke and connects to `Catalog/Applications/FibonacciLucasBridge`.

## Conjecture 4 — Pisano period vs. entry point
For odd primes `p ≠ 5`, the Pisano period `π(p)` (the period of `F mod p`) satisfies
`π(p) = z(p) · ord_p(F_{z(p)+1})` and `π(p) ∣ p² − 1`, with `π(p)/z(p) ∈ {1, 2, 4}`.
**Testable form.** Prove `π(p) ∣ p² − 1` directly from `φ^{p²} = φ` in `R` (the same
two-fold Frobenius `iterateFrobenius R p 2` argument), then classify the ratio
`π(p)/z(p)` by the order of `φ`'s eigenvalue, bridging to
`Catalog/Applications/FibonacciPisanoRepresentation`.

## Conjecture 5 — Composite apparition and a Fibonacci pseudoprime criterion
A composite `n` coprime to `10` with `n ∣ F_{n − (5/n)}` (Jacobi symbol) is a *Fibonacci
pseudoprime*; these are exactly the Frobenius/Lucas pseudoprimes for `x² − x − 1`.
**Testable form.** Extend `fib_dvd_p_sub_legendre` from the Legendre symbol to the Jacobi
symbol for prime `p`, show the multiplicative gluing `z(mn) = lcm(z m, z n)` for coprime
`m, n` (reuse `fib_dvd_iff_fibEntry_dvd`), and characterize when the reciprocity
congruence survives to composites. This links to
`Catalog/Novelty/FibCarmichaelStructure` and the `CarmichaelComposite` priority target.
