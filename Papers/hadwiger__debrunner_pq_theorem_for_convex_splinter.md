# Computational Evidence — `(p,q)` / Helly transversal core

The formalised results are *universally quantified structural* statements, so the
relevant "computational evidence" is small-case sanity of the definitions and of
the proved bounds, plus a counterexample hunt against the headline bound. All
checks below are consistent with the Lean theorems (which are the authoritative
verification).

## 1. Small cases of the elementary bound `τ ≤ |s| - q + 1`

`exists_transversal_of_pqProperty_full` claims: a family of nonempty sets with the
full `(|s|, q)`-property has a transversal of size `≤ |s| - q + 1`.

| `|s|` | `q` | bound `|s|-q+1` | reading |
|------:|----:|----------------:|---------|
| 3 | 2 | 2 | 2 of 3 sets share a point (1 piece) + 1 leftover = 2 |
| 3 | 3 | 1 | all 3 share a point → single piercing point |
| 5 | 3 | 3 | 3 share a point (1 piece) + 2 leftover = 3 |
| 5 | 5 | 1 | Helly-type total intersection |
| `n` | `n` | 1 | the `(n,n)`-case collapses to one point |

The `q = |s|` row is exactly the bridge `pqProperty_helly_transversal_one`
specialised away from geometry: full `(n,n)` ⇒ size-1 transversal.

## 2. Helly thresholds across set classes (the `d+1` vs `2d+1` story)

| `d` | convex threshold `d+1` | splinter threshold `2d+1` | gap |
|----:|-----------------------:|--------------------------:|----:|
| 1 | 2 | 3 | 1 |
| 2 | 3 | 5 | 2 |
| 3 | 4 | 7 | 3 |
| `d` | `d+1` | `2d+1` | `d` |

`convex_hasHellyNumber` proves the left column from Mathlib's `Convex.helly_theorem`
(`finrank ℝ (EuclideanSpace ℝ (Fin d)) = d`). The right column is taken as the
Arocha–Bracho–Montejano hypothesis in `splinter_pqProperty_transversal_one`; the
gap column `= d` is the quantitative content conjecture C3 aims to witness.

## 3. Counterexample hunt against the elementary bound

We probed whether the bound `|s| - q + 1` can be beaten downward in general
(i.e. whether the `(|s|, q)`-property forces something smaller). It cannot:
take `q` sets all equal to `{*}` and the remaining `|s| - q` sets pairwise
disjoint singletons; the `(|s|, q)`-property holds, and any transversal needs at
least `1 + (|s| - q)` points. So the bound is **tight** as a function of `|s|`
and `q` alone — confirming (Analyst note) that escaping the `|s|`-dependence
*requires* the Helly number, motivating C1.

No counterexample to any proved Lean statement was found; the Lean kernel check
(`#print axioms`, only `propext`/`Classical.choice`/`Quot.sound`) is the binding
verification.

## 4. OEIS

No integer sequence is intrinsic to these structural lemmas. The conjectural
fractional-Helly bound of C1 (`binom(p-1, h-1)`) is a binomial coefficient and
needs no OEIS lookup.

## Scope note

Evidence is intentionally brief: the deliverables are theorems, not computations,
and the universal statements are validated by the compiling, sorry-free Lean
files rather than by enumeration.
