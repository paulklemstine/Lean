# Computational Evidence

## Small-case calculations

The deterministic clock begins

| finite request n | clock value |
|---:|:---|
| 0 | 0 |
| 1 | 1 |
| 2 | 2 |
| 7 | 7 |
| 19 | 19 |

The two-level clock `ω·k + n` begins by blocks:

| block budget k | finite tail n | clock value |
|---:|---:|:---|
| 0 | 0 | 0 |
| 0 | 5 | 5 |
| 1 | 0 | ω |
| 1 | 3 | ω + 3 |
| 2 | 0 | ω·2 |
| 2 | 4 | ω·2 + 4 |

For each fixed k, increasing n is cofinal in the next limit `ω·k + ω`. Increasing k through all finite values is therefore cofinal in `ω·ω`.

The canonical dyadic surreal units provide a second table through their birthdays:

| unit | birthday |
|:---|:---|
| 1 | 1 |
| 1/2 | 2 |
| 1/4 | 3 |
| 1/8 | 4 |

## OEIS search results

No integer sequence central to the ordinal claims arises: the target data are ordinal block values rather than natural-number terms. Consequently no OEIS identifier is asserted.

## Counterexample hunt

The strongest naive reading—one finite computation itself lasts ω rounds—fails for every tested n and, structurally, for every natural n: its ordinal value is below ω. Likewise, testing fixed outer budgets k = 0, 1, 2 shows that arbitrary finite tails approach only `ω·k + ω`, never ω². These are boundary cases rather than counterexamples to the cofinal-supremum statements.

A terminology hazard was also tested: a single global bound on k cannot yield ω². The ω² result requires every individual outer choice to be finite while the family of allowed finite bounds is unbounded.

## Table interpretation

The tables are illustrative. The accompanying exact supremum and strict-bound theorems establish the universal claims; no claim depends on extrapolating from the displayed cases.
