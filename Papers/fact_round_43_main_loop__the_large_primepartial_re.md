# Computational evidence — round 43 (large primes are split primes)

These are exploratory Python computations. They are not formal proofs. The formal results are in
`Catalog/Novelty/LargePrimeSplitLegendre.lean`.

Test modulus: `N = 15916539906629 = 3188161 · 4992389` (a semiprime).

## Small cases
* `c = 3989570`: `c² − N = 128878271`, and this value is **prime**. So the round-43 example is a
  partial relation whose smooth part is `1` and whose single large prime is `r = 128878271`.
  `N^((r−1)/2) ≡ 1 (mod r)`. This is formalized as `round43_instance`. Lean proves primality
  with `norm_num` and derives the Legendre symbol from the general theorem.
* Sweep over `c ∈ [⌈√N⌉, ⌈√N⌉ + 3000)`: there are 7725 (prime, value) incidences with odd `p ∤ N`,
  and **7725/7725** of them are split.

## LP statistics (`B = 2000`, large-prime bound `L = 100·B`, 20 000 consecutive `c`)
| quantity | value |
|---|---|
| odd primes ≤ B | 302 |
| split primes ≤ B (`Q(B)`) | 149 |
| full relations (all primes ≤ B) | 365 |
| single-large-prime partials, `r ≤ L` | 2319 |
| large primes that are split | **2319 / 2319** |
| distinct large primes | 1859 |
| partials whose large prime repeats (pairable) | 460 |

## Reciprocity periodicity (`split_periodic_mod_four_N`)
For `N = 2..59`, each odd prime `p < 3000` with `p ∤ N` was paired with the next prime `q ≡ p (mod 4N)`.
The split status agreed in **24811/24811** cases. No counterexample was found.

## Counterexample hunt
No prime divisor of `c² − N` was inert in any sample. This matches the theorem. The boundary
`cubic_breaks_split_constraint` is already in the catalog: `5 ∣ 3³ − 2`, but `2` is not a square mod 5.

OEIS: not applicable. No integer sequence is the object of study here.
