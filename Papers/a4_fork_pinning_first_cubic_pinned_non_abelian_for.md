# Computational evidence — A4-FORK-PINNING (paper 75, experiment 410)

All numbers below were produced by direct enumeration before the Lean
formalisation, and every *exact* value quoted here is proved in
`Catalog/Algebra/A4ForkPinning/`.

## 1. The field `x⁴ + 8x + 12` and its root-count signature

For every prime `3 < p < 100000` (9590 primes) we counted the roots of
`x⁴ + 8x + 12` in `𝔽_p` by brute force.

| # roots | count | frequency | `A₄`-class | predicted |
|---|---|---|---|---|
| 4 | 785  | 0.0819 | `e`            | 1/12 = 0.0833 |
| 1 | 6399 | 0.6673 | 3-cycles       | 8/12 = 0.6667 |
| 0 | 2406 | 0.2509 | `[2,2]`        | 3/12 = 0.2500 |
| 2 | **0**| 0.0000 | transpositions | **0** (no odd elements) |

The complete absence of 2-root primes is the empirical signature of
`Gal ⊆ A₄`; formally it is `A4ForkPinning.no_two_roots` (a finite check over all
of `S₄`), and the square discriminant `disc = 576²` is
`A4ForkPinning.quartic_disc`.

## 2. The cubic pinning is exact on the sample

For each of the 9590 primes we compared

```
F₀(p) = [#roots ∈ {4,0}]      vs      [p mod 9 ∈ {1,8}]
```

**Mismatches: 0.**  (The experiment reports the same on 22,996 primes.)  The
fork is therefore a deterministic function of `p mod 9`, which is what makes
`I(p mod 9 ; F₀) = H(1/3)` (`A4ForkPinning.info_mod9_V4_fork`).

Conditional identity rate inside the fibre: `P(#roots = 4 | F₀) = 785/3191 =
0.2460`, against the predicted `1/|V₄| = 1/4` — the input of the leakage law.

## 3. Entropy values (double precision) vs. the proved closed forms

| quantity | closed form (proved) | numeric | experiment |
|---|---|---|---|
| `I(p mod 9 ; F₀)` | `H(1/3)` | 0.9183 | 0.9188 |
| `I(p mod 9 ; F₁)` | `H(1/12) − (1/3)H(1/4)` | 0.1434 | 0.1419 |
| `H(F₁)` | `H(1/12)` | 0.4138 | — |
| AND (semiprime) | `H(1/9) − (1/3)H(1/3)` | 0.1972 | 0.1997 |
| OR (semiprime) | `H(5/9) − H(1/3)` | 0.0728 | 0.0688 |
| XOR (semiprime) | `H(4/9) − (2/3)H(1/3)` | 0.3789 | 0.3736 |
| split-count | `H(4/9,4/9,1/9) − H(1/3)` | 0.4739 | 0.4710 |
| which-factor | `0` | 0 | 0.0001 |

The Lean file additionally *verifies* the numerics of `H(1/3)` and `H(1/4)` by
integer power comparisons (`3^1000 < 2^1585`, `2^15849 < 3^10000`), giving
`0.918 < H(1/3) < 0.919` and `0.811 < H(1/4) < 0.812`
(`A4ForkPinning.hb_third_bounds`, `A4ForkPinning.hb_quarter_bounds`).

## 4. Finite group checks (all re-proved by `decide` in Lean)

* `⁅A₄,A₄⁆ = V₄` — checked on all 12·12 commutators, and each of the four
  elements of `V₄` is realised as a commutator;
* `|A₄| = 12`, `|V₄| = 4`, hence `|A₄^ab| = 3`;
* the six units mod 9 are `{1,2,4,5,7,8}`, the cubes are `{1,8}` (index 3);
* mod 3 the fork is invisible: each class mod 3 contains both cubes and
  non-cubes mod 9 (`A4ForkPinning.mod_three_flat`) — the conductor cannot be
  lowered from 9 to 3.

## 5. Sequence lookup

The rate vector `(1/12, 2/3, 1/4)` is the conjugacy-class distribution of `A₄`
(class sizes `1, 8, 3`); no OEIS lookup was needed beyond that standard datum,
and no new integer sequence arises in this experiment.

## 6. Counterexample hunt

* Searched for a prime `< 10⁵` violating `F₀ ⟺ p ≡ ±1 (mod 9)`: **none**.
* Searched for an even permutation of `Fin 4` fixing exactly two points:
  **none** (exhaustive over `S₄`, proved in Lean).
* Searched for a rational root of `z³ − 3z + 1`: none — proved in general
  (`A4ForkPinning.no_rat_root_cubic`).
