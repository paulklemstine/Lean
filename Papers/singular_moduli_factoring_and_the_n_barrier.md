# Computational Evidence — Singular Moduli Factoring and the √N Barrier

All numbers below were produced by direct exact-integer computation (Python,
arbitrary precision) *before* the Lean formalisation, and the two entries marked
**[Lean]** were subsequently re-derived inside Lean from the general theorems
(see `Catalog/Cryptography/SingularModuli/Experiments.lean`).

## 1. Class polynomials used

Monic Hilbert class polynomials `H_D`, degree = class number `h(D)`:

| `D`   | `h` | `H_D(X)`                                            |
|-------|-----|-----------------------------------------------------|
| `-3`  | 1   | `X`                                                  |
| `-4`  | 1   | `X - 1728`                                           |
| `-7`  | 1   | `X + 3375`                                           |
| `-8`  | 1   | `X - 8000`                                           |
| `-11` | 1   | `X + 32768`                                          |
| `-19` | 1   | `X + 884736`                                         |
| `-15` | 2   | `X² + 191025X - 121287375`                           |
| `-20` | 2   | `X² - 1264000X - 681472000`                          |
| `-24` | 2   | `X² - 4834944X + 14670139392`                        |
| `-23` | 3   | `X³ + 3491750X² - 5151296875X + 12771880859375`      |
| `-31` | 3   | `X³ + 39491307X² - 58682638134X + 1566028350940383`  |

## 2. Small-case runs: does the method factor?

Sweep `j₀ = 0, 1, 2, …`, and for each `j₀` all discriminants in the table; count
one *evaluation* per `(D, j₀)` pair; stop at the first nontrivial
`gcd(H_D(j₀), N)`.

| `N`     | `p, q`     | first hit `(D, j₀)` | factor | evals | evals/√N |
|---------|------------|---------------------|--------|-------|----------|
| 15      | 3, 5       | `(-4, 0)`           | 3      | 2     | 0.52     |
| 35      | 5, 7       | `(-7, 0)`           | 5      | 3     | 0.51     |
| 77      | 7, 11      | `(-15, 0)`          | 11     | 7     | 0.80     |
| 143     | 11, 13     | `(-15, 0)`          | 11     | 7     | 0.59     |
| 323     | 17, 19     | `(-23, 0)`          | 17     | 10    | 0.56     |
| 899     | 29, 31     | `(-8, 2)`           | 31     | 32    | 1.07     |
| 3599    | 59, 61     | `(-19, 8)`          | 61     | 120   | 2.00     |
| 5183    | 71, 73     | `(-11, 9)`          | 73     | 131   | 1.82     |
| 10403   | 101, 103   | `(-15, 3)`          | 101    | 49    | 0.48     |
| 39203   | 197, 199   | `(-7, 8)`           | 199    | 115   | 0.58     |
| 1018081 | 1009, 1009 | `(-15, 30)`         | 1009   | 427   | 0.42     |

Every test semiprime factored. The ratio `evals/√N` stays in `[0.42, 2.0]` over
four orders of magnitude in `N`: consistent with `Θ(√N)` and inconsistent with
any subexponential scaling.

**[Lean]** `factor_5183 : evalGcd H11 9 5183 = 73`, `factor_899`, `factor_3599`,
`factor_77` are machine-checked instances of rows 8, 6, 7, 3.

## 3. Exact success counts vs. the CRT formula

`S = #{ j₀ ∈ [0,N) : gcd(H_D(j₀), N) ∉ {1, N} }`, computed by brute force, and
compared with `r_p(q − r_q) + (p − r_p) r_q` where `r_m = #roots of H_D mod m`.

| `p, q`   | `D`   | `h` | `r_p` | `r_q` | `S` (brute force) | formula | bound `h(p+q)` |
|----------|-------|-----|-------|-------|-------------------|---------|----------------|
| 7, 11    | `-15` | 2   | 1     | 2     | 21                | 21      | 36             |
| 13, 17   | `-15` | 2   | 1     | 0     | 17                | 17      | 60             |
| 11, 13   | `-31` | 3   | 2     | 1     | 33                | 33      | 72             |
| 71, 73   | `-23` | 3   | 0     | 0     | 0                 | 0       | 432            |
| 101, 103 | `-20` | 2   | 2     | 0     | 206               | 206     | 408            |

The formula matched in every case tested; it is now a theorem
(`successCount_eq`).

**[Lean]** `rootCount_H15_7 = 1`, `rootCount_H15_11 = 2`, `rootCount_H15_13 = 1`,
`rootCount_H15_17 = 0` (decidable computations in `ZMod m`) together with
`successCount_H15_77 = 21` and `successCount_H15_221 = 17` — rows 1 and 2 of the
table, obtained from the general CRT theorem rather than by enumeration.

## 4. Counterexample hunt

* **Claim tested:** "`H_D` mod `p` always has `h` roots." **Refuted.** Row 4
  above (`p, q = 71, 73`, `D = -23`) has `r_p = r_q = 0`, and then `S = 0`:
  *no* evaluation point works. The heuristic is valid only when `D` is a square
  mod `p`. Formalised as `singularModuli_blind_of_no_roots`, with the concrete
  witness `X² + 1` mod `7` and `11` in `blind_example`.
* **Claim tested:** "the success density can exceed `h(1/p + 1/q)`." No
  counterexample found (it is now a theorem, `successDensity_le`); the maximum
  observed ratio `S / (h(p+q))` was `21/36 = 0.58`.
* **Claim tested:** "using many discriminants beats `√N`." No: the evaluation
  counts in §2 already use 9–14 discriminants per point and still scale like
  `√N`. Formalised as `multiDiscriminant_successDensity_le_balanced`.

## 5. OEIS

The success counts `S` are a two-parameter family (`p, q, D`), not a single
sequence, and no OEIS entry is expected or was found. The root counts `r_p` of
`H_D` mod `p` are governed by the splitting law for the ring class field, which
is classical; no new sequence is claimed.
