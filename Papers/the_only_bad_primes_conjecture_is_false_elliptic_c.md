# Computational evidence — cycle 6 (Mordell denominators and the modulus `N`)

All numbers below were produced with exact rational arithmetic on the group law of
`E_N : y² = x³ + N` (chord–tangent formulas over ℚ) and are reproduced *as theorems*
in the Lean files `Catalog/Applications/MordellCoprimeToModulus.lean` and
`Catalog/Applications/MordellSemiprimeFamily.lean` wherever they are used in a proof.
Entries marked *(exploratory)* are numerical observations only and are **not** claimed
as verified results.

## 1. The original counterexample orbit: `N = 55 = 5·11`, `P = (9,28)`

| n | den x(nP) | factorisation | contains 5 or 11? |
|---|-----------|---------------|-------------------|
| 1 | 1 | — | no |
| 2 | 3136 | 2⁶·7² | no |
| 3 | 656538129 | 3⁶·13²·73² | no |
| 4 | 21498536380459264 | 2⁸·7²·827²·1583² | no |
| 5 | 79691460700174682826015025 | 5²·(25-digit factor) | **yes (5²)** *(exploratory)* |

The prime `7` in `n = 2` is a prime of good reduction (`7 ∤ Δ = −432·55²`), which refutes the
"only bad primes" conjecture (cycle 1).  Note that the bad prime `5` *does* appear at `n = 5` —
consistent with the singular-locus law proved this cycle: `x(5P)` is not `5`-integral, i.e. the
point has already left the good-reduction locus mod `5`.  The second factor `11` never appears
in this range.

## 2. The new family `N(ℓ,t) = 4ℓ²t² − 1 = (2ℓt−1)(2ℓt+1)`, `P = (1, 2ℓt)`

| ℓ | t | N | factorisation | x(2P) | den x(2P) | gcd(den, N) | semiprime? |
|---|---|---|----------------|-------|-----------|-------------|-----------|
| 5 | 1 | 99 | 3²·11 | −791/400 | 2⁴·5² | 1 | no |
| 5 | 2 | 399 | 3·7·19 | −3191/1600 | 2⁶·5² | 1 | no |
| 5 | 3 | **899** | **29·31** | −799/400 | 2⁴·5² | 1 | **yes** |
| 5 | 9 | 8099 | 7·13·89 | −7199/3600 | 2⁴·3²·5² | 1 | no |
| 7 | 1 | 195 | 3·5·13 | −1559/784 | 2⁴·7² | 1 | no |
| 7 | 2 | 783 | 3³·29 | −6263/3136 | 2⁶·7² | 1 | no |
| 7 | 3 | **1763** | **41·43** | −1567/784 | 2⁴·7² | 1 | **yes** |
| 7 | 9 | 15875 | 5³·127 | −14111/7056 | 2⁴·3²·7² | 1 | no |
| 11 | 1 | 483 | 3·7·23 | −3863/1936 | 2⁴·11² | 1 | no |
| 11 | 9 | **39203** | **197·199** | −34847/17424 | 2⁴·3²·11² | 1 | **yes** |
| 13 | 1 | 675 | 3³·5² | −5399/2704 | 2⁴·13² | 1 | no |
| 13 | 3 | 6083 | 7·11·79 | −5407/2704 | 2⁴·13² | 1 | no |

Observations, all of which are proved in Lean this cycle:

* `ℓ² ∣ den x(2P)` in every row, and `ℓ` is a good prime (`ℓ ∤ N`);
* `gcd(den x(2P), N) = 1` in every row — no prime factor of `N` is ever visible;
* the three bold rows are honest semiprimes `N = pq` with `p, q` twin primes, i.e. genuine
  instances of the factoring set-up in which the conjecture was posed.

## 3. Counterexample hunt for the anti-factoring claim

Doubling orbit of `P = (1,42)` on `E_1763`, `1763 = 41·43`:

| k | digits of den x(2ᵏP) | gcd(den, 1763) | small primes dividing den |
|---|----------------------|----------------|---------------------------|
| 1 | 3 | 1 | 2, 7 |
| 2 | 16 | 1 | 2, 7, 11, 13 |
| 3 | 66 | 1 | 2, 7, 11, 13 |
| 4 | 266 | 1 | 2, 7, 11, 13 |
| 5 | 1069 | 1 | 2, 7, 11, 13 |
| 6 | 4278 | 1 | 2, 7, 11, 13 |

No counterexample to "`gcd(den x(2ᵏP), N) = 1`" was found; the theorem
`no_factor_of_N_in_doubling_orbit` explains why none can exist for a starting point whose
`x`-coordinate is coprime to `N` and odd `N`.  The denominators grow doubly exponentially
(digit counts ≈ ×4 per doubling), as expected from the quadratic growth of the canonical
height, so a search cannot be pushed much further; the Lean proof covers all `k`.

## 4. Sequences

The denominator sequences above are the squares `B_n²` of an elliptic divisibility sequence.
For `E_55, P = (9,28)` the values `1, 56, 25623, …` (square roots of the table in §1) were not
matched to an OEIS entry; no OEIS identification is claimed.

## 5. What the data does **not** show

The survey quoted in the mission statement ("`p` appears 54.5%, `q` appears 0%") is a
statement about specific ad-hoc points on 11 semiprime curves.  The data above suggests, and
the Lean theorem `bad_prime_dvd_den_double` proves, that a bad prime can only appear once the
point fails to be `p`-integral (as at `n = 5` in §1); it is not a phenomenon that can be
steered towards revealing a factor, since the whole doubling orbit of a `N`-unit point stays
coprime to `N`.
