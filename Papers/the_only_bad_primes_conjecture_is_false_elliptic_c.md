# Computational evidence

All numbers below were produced with `#eval` inside the project's Lean environment (exact
integer arithmetic).  Everything that is *claimed as a theorem* is proved separately and
sorry-free in `Catalog/Combinatorics/MordellDenominator{PointCount,Tripling,Barrier}.lean`;
the tables here are exploratory data that motivated those statements.

Setting: the Mordell curve `E_N : y² = x³ + N`, an integral point `P = (x, y)`, and a prime
`ℓ ≥ 5` of good reduction (`ℓ ∤ 6N`).

* layer 2 criterion : `ℓ ∣ den x(2P) ↔ ℓ ∣ x³ + N` (equivalently `ℓ ∣ y`);
* layer 3 criterion : `ℓ ∣ den x(3P) ↔ ℓ ∣ ψ₃(x) = 3x⁴ + 12Nx`.

## 1. The counting law for `N = 55`

`#roots₂(ℓ)` = number of `x mod ℓ` with `x³ + 55 ≡ 0`; `#roots₃(ℓ)` = number with
`3x⁴ + 12·55·x ≡ 0`.

| ℓ | ℓ mod 3 | #roots₂ | #roots₃ |
|---|---------|---------|---------|
| 5 | 2 | 1 | 1 |
| 7 | 1 | 3 | 1 |
| 11 | 2 | 1 | 1 |
| 13 | 1 | 0 | 4 |
| 17 | 2 | 1 | 2 |
| 19 | 1 | 0 | 4 |
| 23 | 2 | 1 | 2 |
| 29 | 2 | 1 | 2 |
| 31 | 1 | 0 | 1 |
| 37 | 1 | 0 | 1 |
| 41 | 2 | 1 | 2 |
| 43 | 1 | 0 | 1 |
| 47 | 2 | 1 | 2 |
| 53 | 2 | 1 | 2 |
| 59 | 2 | 1 | 2 |

Observations, each of which is now a theorem:

* `ℓ ≡ 2 (mod 3)` ⟹ `#roots₂ = 1` (`card_vanishingClasses_of_two_mod_three`).
* `ℓ ≡ 1 (mod 3)`, `ℓ ∤ N` ⟹ `#roots₂ ∈ {0, 3}` (`card_vanishingClasses_of_one_mod_three`).
* `ℓ ≡ 2 (mod 3)`, `ℓ ∤ N` ⟹ `#roots₃ = 2` (`card_vanishingClasses3_of_two_mod_three`);
  the rows `ℓ = 5, 11` have `#roots₃ = 1` precisely because `5, 11 ∣ 55` — the hypothesis
  `ℓ ∤ N` is necessary.
* `ℓ ≡ 1 (mod 3)`, `ℓ ∤ N` ⟹ `#roots₃ ∈ {1, 4}` (`card_vanishingClasses3_of_one_mod_three`).

## 2. Averages

`∑_{N mod ℓ} #roots₂(N, ℓ)` for `ℓ = 5, 7, 11, 13, 17, 19, 23, 29, 31, 37` gives
`5, 7, 11, 13, 17, 19, 23, 29, 31, 37` — exactly `ℓ` in each case, i.e. the average number of
denominator-producing classes is exactly `1` (`sum_card_vanishingClasses`).

## 3. The counterexample point `P = (9, 28)` on `E_55`

* `y = 28 = 2²·7`, so the only good prime at layer 2 is `7`; indeed
  `x(2P) = 2601/3136 = 2601/(2⁶·7²)`.  The producing classes mod `7` are `{1, 2, 4}` and
  `9 ≡ 2 (mod 7)` — the point sits in one of the three classes.
* `ψ₃(9) = 3·9⁴ + 12·55·9 = 25623 = 3³ · 13 · 73`, so the good primes at layer 3 are `13` and
  `73`; indeed `x(3P) = -2302089191/(3⁶·13²·73²)`.
* Consistency with the counting law: `roots₃(55, 13) = {0, 1, 3, 9}` and
  `roots₃(55, 73) = {0, 9, 65, 72}` — both contain `9`, and both have `4` elements
  (`13 ≡ 73 ≡ 1 mod 3`).
* `roots₂(55, 13) = ∅`, which is why `13` does **not** divide `den x(2P)` although it divides
  `den x(3P)`: each layer has its own cubic.

## 4. Counterexample hunt for the "only bad primes" claim

The claim "every prime dividing `den x(nP)` divides `Δ = -432N²`" fails already at `n = 2` for
`N = 55`, `P = (9,28)` (prime `7`), and the failure is not sporadic:

* every prime `ℓ ≥ 5` is realised as a good denominator prime at layer 2 (`N = ℓ² - 1`,
  `P = (1, ℓ)`) and at layer 3 (`N = 1 - ℓ³`, `P = (ℓ, 1)`);
* for every fixed `N`, all primes `ℓ ≡ 2 (mod 3)` are "active" at layer 2, an infinite set by
  Dirichlet.

No sequence from this data appeared in a form worth an OEIS lookup: the class counts are the
elementary sequences `1` (supersingular) and `0/3` (ordinary), determined by whether `-N` is a
cube mod `ℓ`.

## 5. Cycle 2: how many residues of `N` are active? (layer-2 vs layer-3 densities)

Exhaustive enumeration over all residues `c = N mod ℓ`, counting the residues for which the
layer has at least one producing `x`-class, and the total number of producing classes:

| `ℓ` | `ℓ mod 3` | `#{c : layer 2 active}` | `∑_c #V₂(c)` | `#{c : layer 3 active}` | `∑_c #V₃(c)` |
|-----|-----------|-------------------------|--------------|--------------------------|--------------|
| 5   | 2         | 5                       | 5            | 5                        | 9            |
| 7   | 1         | 3                       | 7            | 7                        | 13           |
| 11  | 2         | 11                      | 11           | 11                       | 21           |
| 13  | 1         | 5                       | 13           | 13                       | 25           |
| 19  | 1         | 7                       | 19           | 19                       | 37           |
| 31  | 1         | 11                      | 31           | 31                       | 61           |

The two patterns `#active₂ = (ℓ+2)/3` at ordinary primes (`= ℓ` at supersingular ones) and
`∑_c #V₃(c) = 2ℓ - 1` are now theorems
(`three_mul_card_activeResidues2_of_one_mod_three`, `activeResidues2_of_two_mod_three`,
`sum_card_V3` in `Catalog/Combinatorics/MordellDenominatorDensity.lean`); the rows `ℓ = 7, 13`
are additionally machine-checked inside Lean by exhaustive enumeration
(`counts_at_7_and_13`).  Interpretation: doubling has a positive density (`≈ 2/3`) of blind
residue classes at ordinary primes, while tripling has none — the free root `x ≡ 0` of
`ψ₃ = 3x(x³ + 4N)` is active for every `N`.
