# Computational evidence — Quantum-Pythagorean-Walk

All computations below were run inside Lean 4 (`#eval`) on the same definitions that the
formal development uses (Berggren branch maps `A`, `B`, `C` acting on integer triples,
root `(3,4,5)`, walk words read right-to-left).  They guided the choice of theorems in
`Catalog/Physics/QuantumPythagoreanWalk/`; the theorems themselves are machine-checked and
do not rely on these evaluations.

## 1. The tree, small depths

```
A(3,4,5) = (5,12,13)     B(3,4,5) = (21,20,29)     C(3,4,5) = (15,8,17)
A²(3,4,5) = (7,24,25)    A³(3,4,5) = (9,40,41)     A⁴(3,4,5) = (11,60,61)
```

Slow branch (all `A`): hypotenuses `5, 13, 25, 41, 61, 85, …`, i.e. `2n² + 6n + 5`
(second differences constant `= 4`).  This is the family formalised as
`iterate_stepA_root` / `hyp_iterate_stepA_root`.  The first leg is `2n+3` and the even leg
`2n²+6n+4`.

Growth checks used to guess the two-sided estimate later proved
(`hyp_add_eight_le_branch`, `hyp_branch_le_seven_mul`):

| parent `(a,b,c)` | children `c` (A, B, C) | increments | ratios |
|---|---|---|---|
| (3,4,5) | 13, 29, 17 | +8, +24, +12 | 2.60, 5.80, 3.40 |
| (5,12,13) | 25, 73, 53 | +12, +60, +40 | 1.92, 5.62, 4.08 |
| (7,24,25) | 41, 137, 109 | +16, +112, +84 | 1.64, 5.48, 4.36 |

Over all `1093` nodes of depth `≤ 6`, the minimum increment observed is exactly `+8`
(attained at the root, `5 → 13`) and the maximum ratio observed is `5.828 < 7`.  Both proved
bounds are therefore correct and the additive one is attained.

## 2. Resonance counts (`N ∣ c`) by depth

Number of depth-`n` words with `65 ∣ c`:

| n | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| count | 0 | 0 | 1 | 1 | 2 | 14 |

The first resonance appears at depth `2` (node `(33,56,65)`; the second hypotenuse-`65`
node `(63,16,65)` appears at depth `3`); consistent with the proved
critical-depth bound `5·7ⁿ ≥ N` (here `5·7² = 245 ≥ 65`, while `5·7¹ = 35 < 65`, so depth
`≥ 2` is *forced* — the observed value is exactly the bound).

Depth-5 resonant nodes for `65` include
`(253,204,325)`, `(2537,816,2665)`, `(1073,264,1105)`, `(1643,924,1885)`, … .

## 3. Counterexample hunt for the collapse

For every ordered pair of the 14 depth-`≤5` resonant nodes for `N = 65` we computed
`gcd(a₁a₂ − b₁b₂, 65)` and `gcd(a₁a₂ + b₁b₂, 65)`.  The observed value pairs are exactly

```
(1, 65), (13, 5), (5, 13), (65, 1)
```

i.e. **every** pair either collapses onto a nontrivial factor (`5` or `13`) or is
degenerate in the precise sense of the hypotheses of `resonance_collapse`
(`N ∣ x − y` or `N ∣ x + y`), in which case the other gcd is the full `65`.  No pair
produced a "false" factor.  This is exactly the boundary encoded in the formal statement:
non-degeneracy is necessary, and the degenerate cases are visible.

Verified pair used in the Lean file: words `[1,0,0,0,0] → (253,204,325)` and
`[2,2,1,1,0] → (2537,816,2665)`, giving `gcd(253·2537 − 204·816, 65) = 13`
(`collapse_65`, proved by `decide`).

## 4. The `3 mod 4` obstruction, tested

Scanning all `1093` nodes of depth `≤ 6` we found **no** hypotenuse
divisible by `3`, `7`, `11`, `19`, or `23`; every hypotenuse factors into primes
`≡ 1 (mod 4)`, e.g. `325 = 5²·13`, `1105 = 5·13·17`, `2665 = 5·13·41`.  This suggested and
is now proved as `no_resonance_of_prime_three_mod_four` and, in exact form, the dichotomy
`resonance_exists_iff_isSquare_neg_one`.

## 5. Euler's two representations

`65 = 8² + 1² = 7² + 4²` gives the two hypotenuse-`65` nodes `(63,16,65)` and `(33,56,65)`;
`gcd(63·33 − 16·56, 65) = gcd(1183, 65) = 13`.  Formalised as `euler_collapse_65` /
`euler_collapse_65_value`.

## 6. Sequences

The slow-branch hypotenuse sequence `5, 13, 25, 41, 61, 85, 113, …` is the "centred square
numbers shifted" family `2n²+6n+5`; the hypotenuse sequence of the whole tree is the set of
integers all of whose prime factors are `≡ 1 (mod 4)` (with multiplicity constraints), which
matches the classical description of primitive Pythagorean hypotenuses.  No new OEIS lookup
was needed: both descriptions are classical, and both are now proved here in the exact form
used (`hyp_iterate_stepA_root`, `resonance_exists_iff_isSquare_neg_one`).

---

## 7. Cycle-3 data: prime powers, `ω = 3`, and the disagreement-set pattern

The following were computed by `#eval` on the same branch maps (exhaustive enumeration of
all nodes with hypotenuse below the stated bound, which is complete because the hypotenuse
grows by at least `8` per branch).  They guided this cycle's theorems; the theorems
themselves are machine-checked independently.

**Resonance multiplicity `r(N)` (words with hypotenuse *exactly* `N`).**

| `N` | factorisation | `ω(N)` | nodes found | `r(N)` |
|---|---|---|---|---|
| `325` | `5² · 13` | 2 | `(253,204,325)`, `(323,36,325)` | 2 |
| `625` | `5⁴` | 1 | `(527,336,625)` | 1 |
| `1105` | `5 · 13 · 17` | 3 | `(47,1104)`, `(817,744)`, `(943,576)`, `(1073,264)` | 4 |
| `5525` | `5² · 13 · 17` | 3 | 4 nodes | 4 |

This matches `r(N) = 2^{ω(N) − 1}` with `ω` counting *distinct* primes, including in the
non-squarefree cases `325`, `625`, `5525`.  The prime-power row is now a theorem
(`exists_unique_resonant_word_of_prime_pow`); the `ω = 3` rows remain conjectural as exact
counts, though the existence of a collapsing pair is proved (`universal_resonance_collapse`,
`collapse_1105`).

**Interference gcds at `N = 1105`.**  For the six unordered pairs of the four resonant
nodes, `gcd(a₁a₂ − b₁b₂, 1105)` equals

| pair (odd legs) | `(47,817)` | `(47,943)` | `(47,1073)` | `(817,943)` | `(817,1073)` | `(943,1073)` |
|---|---|---|---|---|---|---|
| gcd | `13` | `17` | `5` | `221 = 13·17` | `65 = 5·13` | `85 = 5·17` |

Every pair returns a *proper nontrivial* factor, and the six values are exactly the six
nonempty proper "disagreement sets" of the four sign vectors — the pattern predicted by
Conjecture 6.  At `N = 325` the unique pair returns `gcd = 25 = 5²`, i.e. the full `5`-part,
which is precisely the value `m = ordProj₅(325)` predicted by `universal_resonance_collapse`.

**Status update.**  The enumerated value `r(1105) = 4` is no longer only evidence: the count
`r(pqr) = 4` for three distinct primes `≡ 1 (mod 4)` is now proved unconditionally in
`Catalog/Physics/QuantumPythagoreanWalk/ThreePrimes.lean`
(`exactly_four_resonant_words`), via the Gaussian sign class `gclass`.  The remaining
numerical data above (`r(325) = 2`, `r(625) = 1`, `r(5525) = 4`) stay as evidence for the
non-squarefree form of Conjecture 1″, which is still open.
