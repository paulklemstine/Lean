# Computational evidence for the quintic type-channel row

All numbers below were computed by direct enumeration *before* the Lean development, to
fix the statements.  They are exploratory; the authoritative statements are the Lean
theorems in `Catalog/MachineLearning/QuinticTypeChannel/`, which prove the closed forms
exactly.

## 1. Class statistics and Shannon quantities of the five transitive quintic groups

Each row uses the conjugacy-class sizes of the group (probability `|class|/|G|`) for the
type observable, and the abelianization coset of each class for the coset observable.

| group | type histogram | `H(T)` | `H(C)` | `H(T,C)` | `I(T;C)` | gap `H(T)-I` |
|---|---|---|---|---|---|---|
| `C₅`  | `1/5, 4/5`                              | 0.7219 | 2.3219 | 2.3219 | **0.7219** | 0.0000 |
| `D₅`  | `1/10, 4/10, 5/10`                      | 1.3610 | 1.0000 | 1.3610 | **1.0000** | 0.3610 |
| `F₂₀` | `1/20, 4/20, 10/20, 5/20`               | 1.6805 | 2.0000 | 2.1805 | **1.5000** | 0.1805 |
| `A₅`  | `1/60, 15/60, 20/60, 24/60`             | 1.6555 | 0.0000 | 1.6555 | **0.0000** | 1.6555 |
| `S₅`  | `1,10,15,20,20,30,24` over 120          | 2.5573 | 1.0000 | 2.5573 | **1.0000** | 1.5573 |

The `I` column matches the reported Chebotarev measurements `0.7219, 1.0000, 1.5000, 0,
1.0000`.  The closed forms conjectured from these numbers,

```
H(T):  L - 8/5,   1/5 + L/2,   11/10 + L/4,   2/15 + 7M/20 + 5L/12,   7/5 + 5L/24 + 17M/40
       (L = log₂5 = 2.3219280948…,  M = log₂3 = 1.5849625007…)
```

evaluate to `0.7219280949, 1.3609640474, 1.6804820237, 1.6555402481, 2.5573440826`,
agreeing with the histogram computation to full double precision.  These closed forms are
the ones proved in `QuinticRow.lean` (`C5_Htype`, `D5_Htype`, `F20_Htype`, `A5_Htype`,
`S5_Htype`), together with explicit rational brackets.

## 2. Locating `D₅` quintics: square discriminant scan

For the trinomial family `x⁵ + a x + b` the discriminant is `256a⁵ + 3125b⁴`.  A
transitive quintic group lies in `A₅` exactly when this is a square, which is the cheap
filter separating `{C₅, D₅, F₂₀}`-in-`A₅` candidates (`D₅`, `A₅`) from `S₅`/`F₂₀` ones.
Scanning `|a|, |b| ≤ 60`:

```
square-disc pairs: 15 found, including
(-5,±12), (1,0), (4,0), (9,0), (11,±44), (16,0), (20,±16), (20,±32)
disc(x⁵+20x+32) = 4 096 000 000 = 64000²   ✔ square
disc(x⁵+20x+16) = 1 024 000 000 = 32000²   ✔ square   (the A₅ example)
disc(x⁵−x−1)    = 2869                     ✗ non-square (the S₅ example)
disc(x⁵−2)      = 50000                    ✗ non-square (the F₂₀ example)
```

So `x⁵ + 20x + 32` is inside `A₅`; its type histogram `{[1⁵] ≈ 0.10, [5] ≈ 0.40,
[1,2,2] ≈ 0.50}` then identifies the group as `D₅` (class sizes `1, 4, 5` out of 10), and
this is exactly the histogram proved in `DihedralD5.type_histogram`.

## 3. The quadratic subfield and the residue dial at `m* = 20`

Because `D₅ ⊆ A₅` the discriminant is a square, so the quadratic character attached to the
`C₂` abelianization cannot be the discriminant character.  It is the character of the
quadratic resolvent `K = ℚ(√−5)`, of fundamental discriminant `−20`.  Its Kronecker symbol
`(−20 | p)` depends only on `p mod 20`, with

```
split  (coset 0):  p ≡ 1, 3, 7, 9   (mod 20)
inert  (coset 1):  p ≡ 11, 13, 17, 19 (mod 20)
```

i.e. a four-to-one map from the eight units mod 20 onto `C₂`.  This fibre count is what
`ResidueDial.residueChar_fibers` verifies (by decision procedure inside Lean), and the
refinement theorem then gives `I(p mod 20; T) = I(T; coset) = 1` exactly — the measured
`1.0000` with no error term.

## 4. Counterexample hunt

* Does every quintic cell saturate `I = H(C)`?  **No** — the `F₂₀` cell has
  `I = 1.5 < 2 = H(C)`, because the class `[4]` splits evenly between the two generators
  of `C₄`.  This is now a theorem (`QuinticRow.F20_mutualInfo_lt_Hcoset`), and the general
  criterion is the converse theorem `mutualInfo_eq_Hcoset_iff_determines`.
* Is the gap always `H(T) - log₂|G^ab|`?  Only for saturating cells; for `C₅` and `F₂₀`
  the correct universal statement is `gap = H(T|C)` (`Joint.gap_eq`), which holds in all
  five rows.
* Does pairing two primes increase the transmitted information?  Monte-Carlo on the
  product coset says no (measured `1.0000` for `D₅`); this is now the theorem
  `PairLaw.pair_law`, `I = log₂|A|` independently of how many primes are combined.

## 5. OEIS

No new integer sequence arises: the only integer data are the conjugacy-class sizes
`(1,4,5)`, `(1,4,10,5)`, `(1,15,20,24)`, `(1,10,15,20,20,30,24)` of the transitive quintic
groups, which are standard character-table data rather than a sequence to look up.
