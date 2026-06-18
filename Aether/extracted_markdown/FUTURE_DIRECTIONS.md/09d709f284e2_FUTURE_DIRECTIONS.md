# Future Directions — Strong Divisibility Sequences & Cryptographic Smoothness

These conjectures extend `Catalog/Cryptography/StrongDivisibilityRankSecurity.lean`, which
established (0 sorries, only `propext`/`Classical.choice`/`Quot.sound`):

- the abstract **strong divisibility sequence** (SDS) interface `IsSDS u`;
- `IsSDS.dvd_of_dvd`, `IsSDS.dvd_gcd_index`, `IsSDS.coprime_of_coprime_index`;
- SDS-free **primitive-prime disjointness** `IsPrimitivePrime.unique_index`,
  `primitivePrimes_disjoint`;
- the **smoothness lower bound** `card_le_primeFactors_prod`
  (`|S| ≤ ω(∏_{n∈S} u n)`);
- Fibonacci and Mersenne instances (`fib_isSDS`, `mersenne_isSDS`,
  `fib_coprime_of_coprime`, `mersenne_two_coprime_of_coprime`, `fib_distinct_primes_ge_four`).

Lab Note H1 isolated the key methodological lesson: *disjointness/counting of primitive
divisors is soft (needs no gcd-law); the hard, sequence-specific content is their **existence**
and the **multiplicity** (p-adic valuation) of the primes they contribute.* The directions
below target exactly that hard content.

## C1 — Abstract Carmichael/Zsygmondy existence for normalised growing SDS
**Conjecture.** Let `u : ℕ → ℕ` be a strong divisibility sequence with `u 1 = 1`, `u n ≥ 1`
for `n ≥ 1`, and strictly increasing for `n ≥ N₀`. Then there is `N₁` such that for all
`n ≥ N₁`, `∃ q, IsPrimitivePrime u q n`.
**Why testable.** Combined with `card_le_primeFactors_prod` it instantly upgrades the concrete
window bound to `ω(∏_{N₁ ≤ n ≤ M} u n) ≥ M − N₁ + 1`. Special instances to discharge first:
Fibonacci (`N₁ = 13`, the catalog's open `fib_carmichael` target) and Mersenne base `a ≥ 2`
(Bang–Zsygmondy, with the single exception `a = 2, n = 6`).

## C2 — Linear-growth smoothness for Fibonacci products
**Conjecture.** `∀ N, N − 12 ≤ ω(∏_{n=13}^{N} F n)` (each index `n ≥ 13` contributes a fresh
prime), and more sharply `ω(∏_{n=1}^{N} F n) = N − o(N)`.
**Falsifiable.** A single index `n ≥ 13` with no primitive prime divisor of `F n` refutes the
linear lower bound. The exact second-order term is an open, numerically checkable target.

## C3 — From set-counting to multiset-counting via Lifting-the-Exponent
**Conjecture.** Strengthen `card_le_primeFactors_prod` to the *total* number of prime factors
with multiplicity: for an SDS `u` admitting primitive divisors on `S`,
`∑_{n∈S} Ω(u n) ≥ ∑_{n∈S} (1 + v_p(n))` for the relevant Carmichael prime `p`, using the
lifting-the-exponent law `v_p(F_{p·m}) = v_p(F_m) + 1`
(cf. `Catalog/Algebra/Tropical_p_adic_..._Fibonacci_Primitive_Divisors`).
**Deliverable.** A lemma `IsSDS.lte`-style API + `Ω`-version of the smoothness bound.

## C4 — Cross-sequence (CRT) independence of entry points
**Conjecture.** Define the entry point `rank u q` (least `k>0` with `q ∣ u k`). For two SDS
`u, v` (e.g. Fibonacci and Mersenne base 2) the joint map `q ↦ (rank u q, rank v q)` is
"CRT-spread": for coprime moduli the simultaneous congruence system on entry points is always
solvable. Concretely: `rank u (q·q') = lcm (rank u q) (rank u q')` for coprime primes power-free
`q, q'` (extends `Novelty/FibCarmichaelStructure.fibEntry_coprime_mul` to arbitrary SDS).

## C5 — Conditional factoring-hardness from anti-smoothness
**Conjecture (cryptographic packaging).** Assuming C1 for Mersenne base `a`, the largest prime
factor `P⁺(a^n − 1)` satisfies `P⁺(a^n − 1) > n` for all `n ≥ N₁` (every term has a primitive
prime, and a primitive prime of `a^n − 1` is `≡ 1 mod n`, hence `≥ n + 1`).
**Formal target.** Prove `IsPrimitivePrime (fun n => a^n - 1) q n → n + 1 ≤ q` (primitive
primes are `≡ 1 (mod n)`), then conclude a non-smoothness guarantee usable as a parameter-safety
lemma for Lucas/Mersenne-based key generation.
