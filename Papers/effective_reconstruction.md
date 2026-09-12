# Computational evidence — effective reconstruction

All numbers below were produced by `#eval` inside the project (Lean 4.28.0 /
Mathlib), using the definitions of `Catalog/Novelty/EffectiveDecoderSelection.lean`.
They are exploratory data, not proofs; every claim that appears in the `.lean`
files is proved there without `sorry`.

## 1. The diagonal trace channel on small inputs

`stepRun n` runs machine `(Nat.unpair n).1` (decoded as a `Nat.Partrec.Code`) on
input `(Nat.unpair n).1` for `(Nat.unpair n).2` steps; `obsDiag n` is the emitted
record (`a+1` on halting, `0` on a blank trace) and `fDiag n` the halting value
plus one.

`(n, obsDiag n, fDiag n)` for `n < 30`:

```
(0,0,0)  (1,1,1)  (2,0,0)  (3,0,0)  (4,1,1)  (5,2,3)  (6,0,0)  (7,0,0)
(8,0,0)  (9,1,1)  (10,2,3) (11,3,2) (12,0,0) (13,0,0) (14,0,0) (15,0,0)
(16,1,1) (17,2,3) (18,3,2) (19,4,2) (20,0,0) (21,0,0) (22,0,0) (23,0,0)
(24,0,0) (25,1,1) (26,2,3) (27,3,2) (28,4,2) (29,5,1)
```

Observations:

* non-blank traces are abundant: 1372 of the first 4000 inputs emit a non-blank
  record;
* they carry only 40 distinct non-blank records among `n < 4000` (41 records in
  total, counting the blank record `0`), i.e. fibres are large — exactly the
  situation where fibre constancy is a real constraint;
* the decoded values genuinely depend on the record (record `2 ↦ 3`,
  record `3 ↦ 2`, record `5 ↦ 1`), so the quantity `fDiag` is not constant and
  the decoding problem is not vacuous.

## 2. Fibre-constancy spot check

Exhaustive check of all pairs `n, m < 300`:

```
(List.range 300).all fun n => (List.range 300).all fun m =>
  (obsDiag n != obsDiag m) || (fDiag n == fDiag m)     -- ⇒ true
```

This is the finite shadow of `fibreConstant_diag`, which is proved in general
from determinism of `Nat.Partrec.Code.eval`.

## 3. Least preimages grow: the search has no computable bound

For each record `y` emitted below 4000, its least preimage:

```
(1,1) (2,5) (3,11) (4,19) (5,29) (6,41) (7,55) (8,71) (9,89) (11,154)
(13,181) (15,239) (17,305) (19,418) (21,461) (22,505) (23,551) (24,599)
(25,649) (27,755)
```

The least preimage grows quickly and irregularly in the record.  This is the
finite trace of `no_computable_bound_diag`: a computable bound on this search
would yield a computable selector, hence a computable decoder.

## 4. Budgeted decoders keep erring

The budget-`B` decoder `decB B y = fDiag (least n < B with obsDiag n = y)`
(blank `0` if the budget is exhausted) has, on the states `n < 3000`, error
counts

| budget `B` | 10  | 50  | 200 | 1000 | 2000 |
|------------|-----|-----|-----|------|------|
| errors     | 939 | 737 | 511 | 160  | 36   |

Errors shrink with the budget but never vanish: for every finite budget some
state is misdecoded.  This is the computational shadow of two proved theorems —
`no_computable_decoder_diag` (no total computable decoder at all) and
`diag_decoder_errors_infinite` (every computable decoder errs on an infinite
set, via the finite-patching principle).

## 5. Counterexample hunt

We tested whether a simple arithmetic function of the record could serve as the
computable preimage bound forbidden by `no_computable_bound_diag`.  Among the 40
non-blank records emitted below 4000, the least preimage exceeds

| candidate bound `b y` | `y` | `y²` | `2^y` |
|-----------------------|-----|------|-------|
| records with `leastPre y > b y` | 39 | 39 | 3 |

so the polynomial candidates fail immediately; the exponential candidate only
survives on this initial segment because the sample is bounded by 4000 (the
theorem shows no computable bound can work globally).  No counterexample to any
of the stated theorems was found.
