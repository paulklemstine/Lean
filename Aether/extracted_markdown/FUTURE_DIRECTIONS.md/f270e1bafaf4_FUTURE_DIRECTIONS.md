# Future Directions — The Fibonacci Apparition Lattice

## Synthesis

This cycle took a single orphaned catalog identity — `Nat.fib_gcd`
("Fib_gcd_identity"), already leveraged in
`Cryptography/FibonacciDivisibilityLattice.lean` to build the *rank of apparition*
`FibLattice.entry m` and the apparition law
`FibLattice.fib_dvd_iff_entry_dvd : m ∣ fib n ↔ entry m ∣ n` — and showed that this
one bridge lemma is enough to turn the rank of apparition into a genuine **lattice
homomorphism** of the divisibility order. The new file
`Cryptography/FibonacciApparitionLattice.lean` proves that `entry` is determined by the
set of indices it divides, is monotone for divisibility, and (the headline result)
*commutes with `lcm`*. The CRT corollary `entry_mul_coprime` then decomposes the
Fibonacci order of a composite modulus across its coprime factors — the structural
engine behind Lucas-sequence primality testing. Finally `entry_eq_iff_primitive`
welds this apparition theory directly onto the catalog's Carmichael primitive-divisor
program (`Shared/CarmichaelProof.lean`): a modulus `m` has `entry m = n` **iff** `m` is
a primitive divisor of `fib n`, recasting "primitive prime divisor of `fib n`" as
simply "prime with rank of apparition `n`".

## Results summary

All results live in `Cryptography/FibonacciApparitionLattice.lean`, namespace
`FibLattice`, sorry-free (axioms: `propext`, `Classical.choice`, `Quot.sound`):

- `eq_of_dvd_iff_dvd` — a natural number is determined by its set of multiples.
- `entry_unique` — the apparition law *characterizes* `entry`.
- `entry_eq_one_iff` — `entry m = 1 ↔ m = 1`.
- `entry_dvd_entry_of_dvd` — `entry` is monotone for divisibility.
- `entry_lcm` — **`entry (lcm m n) = lcm (entry m) (entry n)`** (the lattice homomorphism).
- `entry_mul_coprime` — CRT decomposition of the Fibonacci order over coprime factors.
- `entry_eq_iff_primitive` — `entry m = n ↔ m` is a primitive divisor of `fib n`.

## Research directions

### 1. The exact rank of apparition at a prime via the Legendre symbol
Conjecture: for an odd prime `p ≠ 5`, `entry p ∣ p - (5 / p)` where `(5 / p)` is the
Legendre symbol; equivalently `entry p ∣ p - 1` when `p ≡ ±1 (mod 5)` and
`entry p ∣ p + 1` when `p ≡ ±2 (mod 5)`. The key insight is that Binet's formula
becomes an identity in `𝔽_p` (or `𝔽_{p²}`), so the rank of apparition is exactly the
order of the golden-ratio unit in the relevant finite field, which divides the group
order `p ∓ 1`. Why now? We already have `entry` as a first-class object with a clean
characterization (`entry_eq_iff_primitive`) and a CRT decomposition
(`entry_mul_coprime`); reducing the prime case to a finite-field order computation would
let `entry_mul_coprime` lift the bound to *all* moduli, giving a fully verified Fibonacci
order oracle.

### 2. Sharp `lcm` law for prime powers and the full multiplicative formula
Conjecture: `entry (p ^ (k+1)) ∈ {entry (p^k), p · entry (p^k)}`, and combined with
`entry_lcm` this yields a closed multiplicative formula
`entry (∏ pᵢ^{eᵢ}) = lcm_i (entry (pᵢ^{eᵢ}))`. The key insight is that the "wall" of a
prime (the jump from `entry p` to `entry (p²)`) is governed by whether `p²` already
divides `fib (entry p)`, a single divisibility test rather than a search. Why now?
`entry_lcm` reduces the composite case to prime powers *for free*, so the only missing
ingredient is the prime-power ascent — a self-contained, falsifiable lemma that the
current file's machinery (`entry_dvd_entry_of_dvd`, `fib_dvd_iff_entry_dvd`) is built to
support.

### 3. Carmichael's theorem as surjectivity of `entry` onto `ℕ_{≥ 13}`
Conjecture: for every `n ≥ 13` there is a prime `p` with `entry p = n`; this is exactly
`fib_carmichael_composite` plus the prime case, recast through
`entry_eq_iff_primitive`. The key insight is that the open `sorry` in
`Shared/CarmichaelProof.lean` (composite `n > 10000`) is the statement that the apparition
map `p ↦ entry p` hits every large index, so a Zsygmondy/Carmichael-style growth argument
on `fib` can replace the finite `native_decide` certificate. Why now? `entry_eq_iff_primitive`
gives the precise reformulation that converts the analytic primitive-divisor problem into a
clean surjectivity statement about an object we now control algebraically.

### 4. Apparition lattices for general Lucas sequences `U(P, Q)`
Conjecture: every nondegenerate Lucas sequence `U_n(P, Q)` is a strong divisibility
sequence, so the entire `FibLattice` development — characterization, monotonicity,
`entry_lcm`, CRT decomposition — transfers verbatim with `fib` replaced by `U`. The key
insight is that *only* the gcd identity `gcd (U_m) (U_n) = U_{gcd m n}` is used downstream;
abstracting `FibLattice` over "any sequence satisfying the strong-divisibility identity"
makes the homomorphism results reusable across the whole `Cryptography` Lucas-test family.
Why now? Our proofs never touch the Fibonacci recurrence directly — they consume only
`fib_gcd`, `fib_dvd`, and injectivity above index 2 — so the generalization is a typeclass
refactor, not new mathematics.

### 5. A verified order-finding subroutine for Fibonacci-based hashing
Conjecture: `entry`, made computable via a bounded apparition search of length `≤ m² + 1`
(the Pisano-period pigeonhole already implicit in `entry_exists`), agrees with the
noncomputable `Nat.find` definition, giving an executable, *formally verified* rank-of-
apparition oracle. The key insight is that `entry_exists` already produces a repeat within
`m²` steps, so a fueled `decide`-style search is provably complete and `entry_lcm` lets the
oracle scale to large composite moduli by factoring. Why now? The catalog's Cryptography
track wants verified primitive primality tests; `entry_eq_iff_primitive` plus a computable
`entry` would deliver one with a machine-checked correctness proof rather than a trusted
implementation.
