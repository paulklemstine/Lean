# Computational Evidence — Proof Automation: Custom Lean 4 Tactics

Pre-proof computational landscape for the three tactics
(`tropical_simp`, `number_theory_decide`, `spectral_bound`).

## 1. `tropical_simp` (min-plus distributivity)

Small-case check of the scalar-distribution law `c + min b c = min (c+b) (c+c)`
and the list form `c + foldr min d l = foldr min (c+d) (map (c+·) l)`:

| `c` | `l`            | `c + foldr min d l` | `foldr min (c+d) (map (c+·) l)` |
|-----|----------------|---------------------|---------------------------------|
| 2   | `[3, 1, 4]`    | `2 + 1 = 3`         | `min(5, min(3, min(6, 2+d)))`=3 |
| -1  | `[0, 5]`       | `-1 + 0 = -1`       | `min(-1, min(4, -1+d))` = -1    |
| 10  | `[]`           | `10 + d`            | `10 + d`                        |

All instances agree → the identity is plausible for all lists; confirmed by the
inductive proof `scalar_foldr_min`.  Observed failure during experimentation:
AC-normalisation of nested `min` needs `min_left_comm`; without it `simp` stalls
on re-bracketed trees.

## 2. `number_theory_decide` (finite cases)

* `n² < 2ⁿ`: false for `n ∈ {2,3,4}` (4<4 false, 9<8 false, 16<16 false),
  flips true at `n = 5` (25 < 32) and stays true — so the correct hypothesis is
  `n ≥ 5`, matching `two_pow_gt_sq`.  (n=0: 0<1 ✓, n=1: 1<2 ✓ are incidental.)
* Fermat / Carmichael residue scan `nᵖ ≡ n (mod m)` over a full residue system:
  - `m = 5, p = 5`: holds for all `x ∈ ZMod 5` → `5 ∣ n⁵ − n`.
  - `m = 7, p = 7`: holds for all `x ∈ ZMod 7` → `7 ∣ n⁷ − n`.
  - `m = 6, p = 3`: `x³ − x = 0` for all `x ∈ ZMod 6` → `6 ∣ n³ − n`.
  - Counterexample hunt: `m = 4, p = 3` gives `2³ − 2 = 6 ≡ 2 ≠ 0 (mod 4)`, so
    `4 ∤ n³ − n` in general — confirms the modulus matters and the tactic
    correctly *fails* (does not prove) the false instance.

## 3. `spectral_bound` (eigenvalue magnitude)

Row-sum (∞-norm) bound `|λ| ≤ maxᵢ ∑ⱼ |Mᵢⱼ|` checked on explicit matrices:

| Matrix                   | row sums | bound | actual eigenvalues | `|λ| ≤ bound`? |
|--------------------------|----------|-------|--------------------|----------------|
| `[[1,2],[0,3]]`          | 3, 3     | 3     | 1, 3               | yes (3 ≤ 3)    |
| `[[2,0],[0,-2]]`         | 2, 2     | 2     | 2, −2              | yes (tight)    |
| `[[0,1],[1,0]]`          | 1, 1     | 1     | 1, −1              | yes (tight)    |
| `[[5,0],[0,1]]`          | 5, 1     | 5     | 5, 1               | yes            |

No counterexample found; the bound is tight on symmetric/diagonal cases.  This
motivated phrasing the certificate with an abstract bound `B ≥ ∑ⱼ|Mᵢⱼ|` so the
maximum instantiates `B`, avoiding `Finset.sup'` bookkeeping in the proof.

## Verdict

All three computational landscapes are consistent with the conjectured laws and
exposed the exact hypotheses needed (`n ≥ 5`; modulus = exponent or `6 | n³−n`;
abstract row-sum bound).  Proceeded to formal proof; all main theorems compile
with `0` sorries and only `propext / Classical.choice / Quot.sound`.
