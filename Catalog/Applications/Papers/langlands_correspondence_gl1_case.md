# Computational Evidence — GL(1) Langlands (cyclotomic case)

Concise numerical support for the two theorems proved this cycle. All claims below are
*also* discharged formally (0 sorries) in `GaloisDuality.lean` / `QuadraticHecke.lean`; this
file records the small-case evidence that motivated and sanity-checked them.

## 1. Self-duality count: `#Gal(ℚ(ζₙ)/ℚ) = φ(n)`

| n | φ(n) = #Gal | #{1-dim Galois reps} | #{Dirichlet chars mod n} |
|---|------------|----------------------|--------------------------|
| 1 | 1 | 1 | 1 |
| 2 | 1 | 1 | 1 |
| 3 | 2 | 2 | 2 |
| 4 | 2 | 2 | 2 |
| 5 | 4 | 4 | 4 |
| 7 | 6 | 6 | 6 |
| 8 | 4 | 4 | 4 |
| 12 | 4 | 4 | 4 |

All three columns agree, the cardinality shadow of the isomorphisms
`langlandsGL1` and `galoisRepsEquivGalois`. (`#Gal` and `#reps` agreeing is exactly
`card_galois_reps_eq_card_galois`.)

## 2. Cyclicity at primes (`galois_cyclic_prime`)

`(ZMod p)ˣ` is cyclic for every prime `p` (a primitive root exists):

| p  | a primitive root g | order of g = p-1 |
|----|--------------------|------------------|
| 3  | 2 | 2 |
| 5  | 2 | 4 |
| 7  | 3 | 6 |
| 11 | 2 | 10 |
| 13 | 2 | 12 |

Hence `Gal(ℚ(ζₚ)/ℚ)` is cyclic, transported via `artinIso`.

## 3. Quadratic stratum: `#{x ∈ (ZMod p)ˣ : x² = 1} = 2` for odd `p`

| p  | solutions of x²=1 in (ZMod p)ˣ | count |
|----|--------------------------------|-------|
| 3  | {1, 2 = -1} | 2 |
| 5  | {1, 4 = -1} | 2 |
| 7  | {1, 6 = -1} | 2 |
| 11 | {1, 10 = -1} | 2 |
| 2  | {1}  (since 1 = -1) | 1 |

Count is uniformly `2` for odd `p` and drops to `1` at `p = 2`, confirming that the
hypothesis `p ≠ 2` in `card_units_sq_eq_one_prime` is load-bearing. Transporting across
`MulChar.mulEquivToUnitHom` and `galoisRepsEquivGalois` gives the matching counts of `2`
quadratic Hecke characters and `2` quadratic Galois representations
(`card_quadratic_dirichlet_prime`, `card_quadratic_galois_reps_prime`).

## Counterexample hunt
No counterexamples to the universal claims "#reps = φ(n)" and "two quadratic characters for
odd primes" were found over `n ≤ 50` / primes `p ≤ 50`. The `p = 2` boundary is the only
degeneration of the quadratic count, and it is excluded by hypothesis.
