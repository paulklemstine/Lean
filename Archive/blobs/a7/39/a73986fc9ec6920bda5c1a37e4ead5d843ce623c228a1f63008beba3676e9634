# Future Directions — Fibonacci entry points & primitive divisors

This cycle delivered `Algebra/FibEntryPointReciprocity.lean`: a fully verified (0-sorry)
**sharpening of the classical entry-point bound** `z(p) ∣ p² − 1` into the two-sided
*law of apparition*

* `p ≡ ±1 (mod 5)` ⟹ `p ∣ F(p−1)` ⟹ `z(p) ∣ p−1`,
* `p ≡ ±2 (mod 5)` ⟹ `p ∣ F(p+1)` ⟹ `z(p) ∣ p+1`,

with the unconditional dichotomy `zfib_dvd_pred_or_succ`. The engine is a reusable
**ring-level Binet formula** `(a − b)·F(n) = aⁿ − bⁿ` (`fib_binet_ring`), instantiated in
`ZMod p` (residue case) and in `GF(p²)`/the algebraic closure via Frobenius (non-residue case).

The conjectures below are concrete and falsifiable; each is a candidate target for the next cycle.

## C1. The law of apparition is an exact equivalence
For a prime `p ∉ {2, 5}`:
`z(p) ∣ p − 1  ⟺  p % 5 ∈ {1, 4}`  and  `z(p) ∣ p + 1  ⟺  p % 5 ∈ {2, 3}`.
We proved the (⟸) directions. Conjecture: the (⟹) directions also hold, i.e. the two cases
are mutually exclusive at the level of `z(p)`. Test: show `z(p) ∤ p+1` whenever `p ≡ ±1 (mod 5)`
(equivalently `p ∤ F(p+1)`), which would follow from `gcd(F(p−1), F(p+1)) = F(gcd(p−1,p+1)) = F(2) = 1`
together with the residue case. This looks within reach using `Nat.fib_gcd`.

## C2. Generalize the reciprocity engine to all Lucas sequences
Let `U_n(P,Q)` be the Lucas sequence with `U_0=0, U_1=1, U_{n+1}=P·U_n − Q·U_{n+1}` and
discriminant `D = P² − 4Q`. Conjecture: for a prime `p ∤ 2QD`,
`p ∣ U_{p − (D|p)}`, hence `z_U(p) ∣ p − (D|p)` where `(D|p)` is the Legendre symbol.
The Fibonacci case is `P=1, Q=−1, D=5`. The proof should reuse a Binet identity
`(a−b)·U_n = aⁿ − bⁿ` for the roots of `x² = P·x − Q` over a commutative ring — a direct
generalization of `fib_binet_ring`. Pell numbers (`P=2,Q=−1,D=8`) give an immediate test case.

## C3. Cyclotomic lower bound for the Carmichael primitive-divisor tail
The open `sorry` in `Shared/CarmichaelProof.lean` (`fib_carmichael_composite`, composite
`n > 10000`) needs a size bound that survives abundant `n`. Define the primitive part
`Φ_n = ∏_{d∣n} F_d^{μ(n/d)}` (Möbius-weighted). Conjecture:
`α^{φ(n) − 1} ≤ Φ_n` where `α = (1+√5)/2`, together with the **structure theorem**: every
non-primitive prime divisor of `Φ_n` equals the largest prime factor `P(n)` and occurs to the
first power. Consequently `Φ_n > P(n) ≥ n` forces a primitive divisor for `n > 12`. This is the
sharp tool the naive product bound `F_n ∣ n·∏_{d<n,d∣n}F_d` lacks (that bound was checked to be
false unconditionally during this cycle).

## C4. Wall's question on the entry point modulo prime powers
Conjecture (Wall): for every prime `p`, `z(p²) = p · z(p)` — equivalently there is **no**
Wall–Sun–Sun prime, i.e. no prime with `p² ∣ F_{z(p)}`. Testable: verify `p² ∤ F_{p−(5|p)}`
for all primes `p < N` by `native_decide` and, structurally, show `z(p^{k+1}) = p · z(p^k)`
under the non-Wall–Sun–Sun hypothesis using lifting-the-exponent for Fibonacci (the catalog
already has `fib_lte`).

## C5. Density of "maximal" entry points
For `p ≡ ±1 (mod 5)` say `p` is *Fibonacci-maximal* if `z(p) = p − 1` (the largest value allowed
by C1). Conjecture: the set of Fibonacci-maximal primes has positive relative density among
primes `≡ ±1 (mod 5)`, predicted by an Artin-type heuristic (analogous to full-reptend primes).
Testable numerically; a Lean deliverable would formalize the counting function and prove
two-sided bounds on `#{p ≤ x : z(p) = p − 1}`.
