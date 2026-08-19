# Computational Evidence — Sidon sets (Phase A, v19c)

All numbers below were produced by `#eval` inside this Lean 4 / Mathlib project
(evaluation, i.e. compiled execution — *not* kernel-checked theorems).  Every claim
that appears in the `.lean` files is proved separately and independently; this file
only records the exploration that guided the formalisation.

Definitions used for evaluation:

```lean
def f  (p k : ℕ) : ℕ  := 2*p*k + k^2 % p          -- the Erdős–Turán map
def et (p : ℕ) : List ℕ := (List.range p).map (f p)
def isSidonL (A : List ℕ) : Bool :=
  A.all fun a => A.all fun b => A.all fun c => A.all fun d =>
    (a+b != c+d) || ((a==c && b==d) || (a==d && b==c))
```

## 1. Small-case calculations: the Erdős–Turán set

| `p` | `etSet p`                              | `max` | `2p²` | Sidon? |
|-----|----------------------------------------|-------|-------|--------|
| 3   | `[0, 7, 13]`                           | 13    | 18    | yes    |
| 5   | `[0, 11, 24, 34, 41]`                  | 41    | 50    | yes    |
| 7   | `[0, 15, 32, 44, 58, 74, 85]`          | 85    | 98    | yes    |
| 11  | (11 elements)                          | 221   | 242   | yes    |
| 13  | (13 elements)                          | 313   | 338   | yes    |

This is the evidence for `ErdosTuran.etSet_isSidon`, `etSet_card` and `etSet_subset`.

## 2. Counterexample hunt: is primality really needed?

The universal claim "`etSet p` is Sidon for every `p`" is **false**; primality is
load-bearing:

| `p` | `etSet p`                                       | Sidon? |
|-----|-------------------------------------------------|--------|
| 4   | `[0, 9, 16, 25]`                                | **no** (`0 + 25 = 9 + 16`) |
| 9   | `[0, 19, 40, 54, 79, 97, 108, 130, 145]`        | **no** |

`p = 2` gives the two-element set `[0, 5]`, which is Sidon for trivial reasons; the
oddness hypothesis in `etSet_isSidon` is required by the proof method (inverting `2`
in `ZMod p`), not by the `p = 2` statement itself.  This is recorded in the file's
Lab Notes.

## 3. Counterexample hunt: which moduli survive?

Testing Sidon-ness of `etSet p` in the cyclic group `ℤ/Mℤ`:

| `p` | `M = 2p²` | `M = 2p² + 1` | `M = 4p²` |
|-----|-----------|---------------|-----------|
| 3   | yes       | **no**        | yes       |
| 5   | yes       | **no**        | yes       |
| 7   | yes       | **no**        | yes       |
| 11  | yes       | **no**        | yes       |
| 13  | yes       | **no**        | yes       |

This is what suggested conjecture (S1) of cycle 3 — that `2p²` is exactly the right
modulus — and it is now the theorem `ErdosTuran.etSet_isSidon_mod`.  The `2p² + 1`
column shows the result is sharp in the modulus and is *not* a soft consequence of
Sidon-ness in `ℤ`.

## 4. Exhaustive search: the largest Sidon subset of `{0, …, n-1}`

Brute force over all subsets:

| `n`            | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 |
|----------------|---|---|---|---|---|---|---|---|---|---|----|----|----|----|----|----|----|----|----|
| `maxSidonCard` | 0 | 1 | 2 | 2 | 3 | 3 | 3 | 4 | 4 | 4 | 4  | 4  | 5  | 5  | 5  | 5  | 5  | 6  | 6  |

(The value `maxSidonCard 18 = 6` was also reproduced by `#eval` of the project's own
`maxSidonCard` definition, confirming that the Lean definition computes what the
brute-force script computes.)

**OEIS.** The thresholds — the least `n` at which each value `k` first appears — are
`1, 2, 4, 7, 12, 18`.  Subtracting one gives `0, 1, 3, 6, 11, 17`, the initial terms of
the lengths of optimal Golomb rulers, [OEIS A003022](https://oeis.org/A003022)
(`1, 3, 6, 11, 17, 25, 34, 44, 55, …`).  This is the expected agreement: a Sidon subset
of `{0, …, n-1}` is exactly a Golomb ruler of length `≤ n - 1`.

**Consistency with the proved bounds.**  At `n = 18`, the theorem
`maxSidonCard_le_sqrt` gives `maxSidonCard 18 ≤ √36 + 1 = 7`, and the true value is `6`;
at `n = 12` it gives `≤ √24 + 1 = 5`, and the true value is `5` — the upper bound is
attained there.  The `Θ(√N)` sandwich is therefore not merely asymptotic bookkeeping:
its upper half is already tight at small `n`.

## 5. What the evidence did *not* show

The lower bound `√(N/8) < maxSidonCard N` is only claimed for `N ≥ 32`, and indeed at
`N = 18` it would read `1 < 6` (true but weak).  No counterexample to any statement
finally formalised was found; the two refuted statements above (`p` composite,
modulus `2p² + 1`) were *not* formalised, and are documented as boundaries instead.
