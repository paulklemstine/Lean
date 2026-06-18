# Computational Evidence — Sheaf-Theoretic Data Integration

Concept: a database with missing entries is a partial section of a sheaf; the sheaf
(gluing) condition governs consistent imputation, with
`P(sheaf) = (1 - r)^N`, where `r` is the missing rate and `N` the number of
independent overlapping consistency constraints (the concept proposes `N = C(n,k)`).

## 1. Small-case calculation of the probability law

For each of `N` independent cells, "present" has probability `1 - r`; the sheaf
condition holds iff all `N` are present, so the conjunction has probability the
product `(1 - r)^N`. Concretely (taking `N = C(n, 2)`, the number of column pairs):

| n  | C(n,2) | r=0.1      | r=0.3      | r=0.5      |
|----|--------|------------|------------|------------|
| 5  | 10     | 0.348678   | 0.028248   | 0.000977   |
| 10 | 45     | 0.008728   | ~3.0e-7    | ~2.8e-14   |
| 15 | 105    | 0.000016   | ~2.5e-16   | ~2.5e-32   |

(Values computed in Lean with `Float`; the exact symbolic statement is
`SheafProb.sheafProb_choose_eq`.)

**Observation.** For fixed `r > 0`, the probability collapses *exponentially* as the
number of columns (hence `C(n,2)`) grows — matching the conjecture "the probability
of consistent imputation drops exponentially with the number of overlapping
constraints." This is the content of `SheafProb.sheafProb_antitone`,
`SheafProb.sheafProb_strict_anti`, and `SheafProb.sheafProb_tendsto_zero`.

## 2. Independence / multiplicativity check

`(1-r)^{N+M} = (1-r)^N · (1-r)^M`: combining two disjoint constraint sets multiplies
the probabilities, confirming the "independent constraints" model. Formalized as
`SheafProb.sheafProb_mul`.

## 3. Counterexample hunt for the gluing model

The partial-section model `ι → Option α` was tested for:
* Existence of a gluing of compatible fragments — holds (`glue_extends_left/right`).
* Necessity of the overlap (compatibility) condition — *incompatible* fragments have
  **no** common extension. Example: `f 0 = some 0`, `g 0 = some 1` are incompatible
  and provably admit no common extension (`no_glue_of_incompatible`). This rules out
  the trivial reading "every pair of fragments glues."
* Uniqueness once support is the union of domains (`glue_unique`).

No counterexamples to the formalized claims were found; the conjecture's qualitative
predictions (exponential decay, necessity of overlap agreement) are reproduced.

## 4. Sequence note

`C(n,2) = 0,1,3,6,10,15,21,28,36,45,...` is OEIS A000217 (triangular numbers); the
exponents in the probability law are therefore the triangular numbers when `k = 2`.
No new integer sequence arises from the probability values themselves (they are
transcendental for generic `r`).
