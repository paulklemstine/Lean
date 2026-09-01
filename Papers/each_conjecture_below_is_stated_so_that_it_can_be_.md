# Computational Evidence — the Pell spine (`Catalog/Novelty/PellSpine*.lean`)

All conjectures in this cycle were screened numerically **before** formalisation.  Every
number quoted below is reproduced inside Lean by a `decide`-checked anchor lemma wherever it
is used in a proof; the wider searches (marked *exploratory*) were run in a scratch script
and are **not** machine-verified — they only guided which conjectures to attack.

## 1. The two sequences

`P n` (Pell, OEIS **A000129**) and `Q n` (half-companion Pell, OEIS **A001333**):

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|----|----|----|
| `P n` | 0 | 1 | 2 | 5 | 12 | 29 | 70 | **169** | 408 | 985 | 2378 | 5741 | 13860 |
| `Q n` | 1 | 1 | 3 | 7 | 17 | 41 | 99 | 239 | 577 | 1393 | 3363 | 8119 | 19601 |

`Q n ^ 2 - 2 * P n ^ 2 = (-1)^n` was checked for `n ≤ 11` (all `±1`), and `gcd (P n) (Q n) = 1`
for `n ≤ 11` (all `1`).  Both are now theorems (`pell_equation`, `pellP_coprime_pellQ`).

## 2. Counterexample hunt

| Conjecture screened | Verdict | Witness | Lean theorem |
|---|---|---|---|
| `n` prime ⇒ `P n` prime | **false** | `P 7 = 169 = 13²` | `not_pellP_prime_of_prime_index` |
| every `P n` squarefree | **false** | `P 7 = 13²` | `not_pellP_squarefree` |
| no `P n` (`n ≥ 2`) is a square | **false** | `P 7 = 13²` | `not_pellP_never_square` |
| `gcd (Q m) (Q n) = Q (gcd m n)` | **false** | `gcd (Q 3) (Q 6) = gcd 7 99 = 1 ≠ 7` | `not_pellQ_strong_divisibility` |
| `p ∣ P (p-1)` for odd primes | **false** | `p = 3`, `P 2 = 2` | `not_prime_dvd_pellP_pred` |
| `pellRank p ∣ p - 1` | **false** | `pellRank 3 = 4` | `not_pellRank_dvd_sub_one` |
| `pellRank (p²) = p · pellRank p` | **false** | `p = 13`: `pellRank 169 = 7 = pellRank 13` | `not_pellRank_sq` |
| hypotenuse of a near-isosceles triple is prime | **false** | `119² + 120² = 169²` | `not_nearIsosceles_hyp_prime` |
| `|√2 - Q n / P n| < 1/(3 P n²)` | **false** | `n = 1`: error `0.4142…` | `not_pell_approx_one_third` |
| `Q n / P n > √2` always | **false** | `n = 1`: `1 < √2` | `not_pell_ratio_above` |
| `gcd (P m) (P n) = P (gcd m n)` | survived → proved | — | `pellP_gcd` |

## 3. Ranks of apparition

`pellRank m` = least `n > 0` with `m ∣ P n` (computed by iterating the recursion mod `m`):

| m | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 |
|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|----|----|
| `pellRank m` | 1 | 2 | 4 | 4 | 3 | 4 | 6 | 8 | 12 | 6 | 12 | 4 | 7 | 6 | 12 | 16 | 8 | 12 | 20 | 12 |

For odd primes the rank always divided `p - 1` or `p + 1` in the sample
`p ≤ 59` — which is now the theorem `pellRank_dvd_sub_or_add`, proved from `pell_fermat_law`.
The `p = 3` line (`rank 4 ∤ 2`) is exactly the refutation `not_pellRank_dvd_sub_one`.

## 4. Pell–Wall–Sun–Sun primes (*exploratory* search)

Primes `p < 20000` with `p² ∣ P (pellRank p)`:  **13 and 31**.
Both are verified inside Lean as divisibility facts:
`pell_wall_sun_sun_thirteen : 13² ∣ P 7` and `pell_wall_sun_sun_thirtyone : 31² ∣ P 30`
(`P 30 = 107578520350 = 31² · 111946850`), and both give
`pellRank (p²) = pellRank p` (`two_pell_wall_sun_sun_primes`).
For the Fibonacci sequence no analogous prime is known below `10^17`.

## 5. Near-isosceles Pythagorean triples

`(a, a+1, c)` with `a² + (a+1)² = c²`, generated from odd spine indices
(`2a + 1 = Q (2k+1)`, `c = P (2k+1)`):

| k | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|---|
| legs | (0,1) | (3,4) | (20,21) | (119,120) | (696,697) | (4059,4060) | (23660,23661) |
| hyp `P (2k+1)` | 1 | 5 | 29 | 169 | 985 | 5741 | 33461 |
| hyp mod 4 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |

The `mod 4` column is now the theorem `nearIsosceles_hyp_mod_four`; the completeness of the
list is `nearIsosceles_iff`; and `169 = 13²` refutes primality of the hypotenuse.

## 6. Squares on the spine (*exploratory*)

Among `P n` for `n ≤ 60`, the perfect squares are exactly `P 1 = 1` and `P 7 = 169`
(consistent with Ljunggren's theorem).  Only the single value `P 7` is needed for the
formal refutation `not_pellP_never_square`.

## 7. Companion gcd table (drives `pellQ_gcd_law`)

`Q = 1, 1, 3, 7, 17, 41, 99, 239, 577, …` (indices `0 … 8`).  Entry `(m, n)` is
`gcd (Q m) (Q n)` for `1 ≤ m, n ≤ 8`:

| m \ n | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |
| 2 | 1 | 3 | 1 | 1 | 1 | 3 | 1 | 1 |
| 3 | 1 | 1 | 7 | 1 | 1 | 1 | 1 | 1 |
| 4 | 1 | 1 | 1 | 17 | 1 | 1 | 1 | 1 |
| 5 | 1 | 1 | 1 | 1 | 41 | 1 | 1 | 1 |
| 6 | 1 | 3 | 1 | 1 | 1 | 99 | 1 | 1 |
| 7 | 1 | 1 | 1 | 1 | 1 | 1 | 239 | 1 |
| 8 | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 577 |

Every off-diagonal entry is `1` except `(2,6)` and `(6,2)`, where the quotients `1` and `3`
are both odd and the value is `Q 2 = 3`.  In particular `(2,4)` is `1` although `2 ∣ 4`
(this is the counterexample formalised as `not_pellQ_dvd_iff_index_dvd`), and `(3,6)` is `1`
although `3 ∣ 6`.  The pattern read off this table is exactly what
`pellQ_gcd_law` proves for all `m, n`: the gcd is `Q (gcd m n)` when both index quotients
are odd, and `1` otherwise.  A brute-force check over all `0 ≤ m, n ≤ 8` inside Lean
(`#eval` over the same formula) returns an empty list of discrepancies.
