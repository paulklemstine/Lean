# Computational Evidence — `5 ∣ a⁵ − a` and its sharpenings

## 1. Small-case calculations

Values of `a⁵ − a` for `a = 0 … 8`:

| a | a⁵    | a⁵ − a | (a⁵ − a)/5 | (a⁵ − a)/30 |
|---|-------|--------|-----------|-------------|
| 0 | 0     | 0      | 0         | 0           |
| 1 | 1     | 0      | 0         | 0           |
| 2 | 32    | 30     | 6         | 1           |
| 3 | 243   | 240    | 48        | 8           |
| 4 | 1024  | 1020   | 204       | 34          |
| 5 | 3125  | 3120   | 624       | 104         |
| 6 | 7776  | 7770   | 1554      | 259         |
| 7 | 16807 | 16800  | 3360      | 560         |
| 8 | 32768 | 32760  | 6552      | 1092        |

Every entry is divisible by 5 — and, strikingly, by **30**. This motivated the
sharpening `30 ∣ a⁵ − a` (2·3·5), which is proved in
`FermatFiveGeneralizations.lean`.

Negative arguments behave symmetrically since `(-a)⁵ − (-a) = -(a⁵ − a)`.

## 2. Sequence / OEIS

`(a⁵ − a)/30` for `a = 0,1,2,…` is `0, 0, 1, 8, 34, 104, 259, 560, 1092, …`,
matching the well-known polynomial values `C(a+2,5)·(…)`-type data; the raw
sequence `a⁵ − a = 0,0,30,240,1020,3120,…` is the fifth-power-minus-argument
sequence. No exotic sequence is needed — the divisibility is the point.

## 3. Counterexample hunt

Tested the universal claims on all residues:
- `∀ x : ZMod 5, x⁵ − x = 0` — verified by exhaustion (5 cases). No counterexample.
- `∀ x : ZMod 2, x⁵ − x = 0` and `∀ x : ZMod 3, x⁵ − x = 0` — verified. No counterexample.
- Last-digit check `a⁵ ≡ a (mod 10)` holds for every residue class `0..9`.

No counterexample exists to any stated conjecture; each finite check is the
load-bearing sub-step inside the corresponding integer/coprimality argument.

## 4. Inductive-step evidence

The identity driving the elementary proof,
`(n+1)⁵ − (n+1) − (n⁵ − n) = 5·(n⁴ + 2n³ + 2n² + n)`,
was checked numerically (e.g. `n=2`: `240 − 30 = 210 = 5·42`, and
`2⁴+2·2³+2·2²+2 = 16+16+8+2 = 42` ✓), confirming the additive-preservation
mechanism (H5) before formalisation.
