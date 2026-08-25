# Computational evidence — destructive verification

All numbers below were produced by `#eval` inside the project's Lean environment
(exhaustive enumeration of every test on `Fin n`), using the definitions of
`Catalog/Combinatorics/DestructiveVerification*.lean`.  A *test* on `n` dishes
is a function `Fin n → Bool × Fin n`; there are `(2n)^n` of them, so exhaustive
enumeration is feasible up to `n = 4` (4096 tests).

The enumeration harness (reproducible by pasting into a scratch file that
imports `Combinatorics.DestructiveVerificationIndistinguishability`):

```lean
def pairsOf (n : ℕ) : List (Bool × Fin n) :=
  (List.finRange n).flatMap (fun j => [(true, j), (false, j)])
def tables (n : ℕ) : ℕ → List (List (Bool × Fin n))
  | 0 => [[]]
  | k + 1 => (tables n k).flatMap (fun l => (pairsOf n).map (fun p => p :: l))
def allTests (n : ℕ) : List (Fin n → Bool × Fin n) :=
  (tables n n).map (fun l d => l.getD d.1 (true, d))
```

## 1. Counting the three classes

| `n` | all tests `(2n)^n` | nondestructive | reversible | repeatable |
|-----|--------------------|----------------|------------|------------|
| 2   | 16                 | 4              | 8          | 10         |
| 3   | 216                | 8              | 48         | 78         |
| 4   | 4096               | 16             | 384        | —          |

Measured values (`#eval`): `(allTests 3).length = 216`,
`((allTests 3).filter isND).length = 8`,
`((allTests 3).filter isRev).length = 48`,
`((allTests 3).filter isRep).length = 78`.

* `8 = 2^3` and `4 = 2^2` match the theorem
  `DestructiveVerification.card_nondestructive` (`Nat.card {t // Nondestructive t} = 2 ^ n`).
* `48 = 2^3 · 3!` and `384 = 2^4 · 4!` matched the guess "verdict pattern × permutation", which was
  then **proved** as `DestructiveVerification.card_reversible`
  (`Nat.card {t // Reversible t} = 2^n * n!`).
* The repeatable counts (10, 78) follow no clean closed form we could identify;
  no OEIS match was pursued for them, and no claim is made about them.

## 2. Destruction depth

For each test and dish we computed the first index at which the transcript
(the verdict stream produced by re-running the test on its own residue) leaves
its initial value, and took the maximum over all tests and dishes:

| `n` | max destruction depth | rigidity bound `n - 1` |
|-----|-----------------------|------------------------|
| 2   | 1                     | 1                      |
| 3   | 2                     | 2                      |
| 4   | 3                     | 3                      |

This is exactly the content of the proved pair
`DestructiveVerification.transcript_rigid` (nothing can change at index `≥ n`
if it has not changed before) and `DestructiveVerification.depth_hierarchy`
(index `n - 1` is attained by the fuse test).  The data confirm both the bound
and its sharpness at every computed `n`.

## 3. Distinguishing delay (indistinguishability)

For each test and each ordered pair of dishes we computed the first index at
which the two transcripts disagree (skipping pairs that never disagree), and
took the maximum:

| `n` | max distinguishing delay | proved bound `n - 1` | conjectured sharp bound `n - 2` |
|-----|--------------------------|----------------------|---------------------------------|
| 2   | 0                        | 1                    | 0                               |
| 3   | 1                        | 2                    | 1                               |
| 4   | 2                        | 3                    | 2                               |
| 5   | ≥ 3 (witness below)      | 4                    | 3                               |

The `n = 5` witness is `DestructiveVerification.clockTest`: a 2-cycle and a
3-cycle with verdict pattern `T,F,T,F,T`; dishes `0` and `2` agree for three
runs and disagree on the fourth (`clock_distinguishing_delay`, proved by
`decide`).  It is exactly the Fine–Wilf extremal configuration
(`p + q - gcd p q - 1 = 2 + 3 - 1 - 1 = 3`).

**Interpretation.**  These data were collected while only the weaker bound `2n`
(`DestructiveVerification.transcript_indistinguishable`) was available; they
motivated the sharpened theorem
`DestructiveVerification.transcript_indistinguishable_card`, which proves the
threshold `n` (agreement on the first `n` runs implies agreement forever), i.e.
maximal delay at most `n - 1`.  The data suggest the truly sharp threshold is
`n - 1` runs (largest delay `n - 2`); that remaining gap of one is recorded
honestly as Conjecture 1 in `FUTURE_DIRECTIONS.md` and is *not* claimed as
proved.

## 4. Counterexample hunt

* "Repeatable ⇒ reversible?"  Refuted by enumeration at `n = 2` (10 repeatable
  vs 8 reversible tests) and then by the explicit burn test
  (`repeatable_not_reversible`).
* "Repeatable closed under composition?"  Refuted by the pair
  (`readTest`, `flipTest`) found by inspection of the `n = 2` table and proved
  as `repeatable_not_closed_under_seq`.
* "Certificates commute; do all tests?"  Refuted at `n = 2` and proved as
  `seq_not_comm`.
* No counterexample was found to the universal claims that were subsequently
  proved (`transcript_rigid`, `transcript_indistinguishable`,
  `transcript_characterization`).
