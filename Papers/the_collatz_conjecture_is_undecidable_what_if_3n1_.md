# Computational Evidence — Collatz reachability and independence

Companion to `Catalog/Logic/CollatzIndependence.lean`.

## 1. Small-case orbit calculations

The step map `T n = n/2` (even) / `3n+1` (odd). Orbits until reaching `1`:

| n | orbit | steps to 1 |
|---|-------|-----------|
| 1 | 1 | 0 |
| 2 | 2,1 | 1 |
| 3 | 3,10,5,16,8,4,2,1 | 7 |
| 6 | 6,3,10,5,16,8,4,2,1 | 8 |
| 7 | 7,22,11,34,17,52,26,13,40,20,10,5,16,8,4,2,1 | 16 |
| 2^k | 2^k, …, 2, 1 | k |

These match the concrete witnesses proved in the file
(`example : Reaches 6 := ⟨8, by decide⟩`, `Reaches 7 := ⟨16, _⟩`,
`reaches_pow_two`).

## 2. Cycle structure

The only known cycle is the trivial `1 → 4 → 2 → 1` (period 3), which *contains*
`1`. The theorem `cycle_not_reaching` requires the period to avoid `1`; this is
exactly the profile a nontrivial cyclic counterexample would need, and none is
known below `2^68`.

## 3. Counterexample hunt

Numerical verification of the Collatz statement has been carried out for all
`n < 2^68` with no divergent or nontrivial-cyclic orbit found. We therefore do
*not* expect (and did not find) a counterexample; the formalization treats the
truth of the statement as a hypothesis (`hCollatz : CollatzConj`) in the
independence theorem rather than proving it.

## 4. Sequence data

The stopping-time sequence (steps to reach 1) is OEIS **A006577**:
`0, 1, 7, 2, 5, 8, 16, 3, 19, 6, 14, 9, 9, 17, 17, 4, …` — consistent with the
table above.

## 5. Logical-side sanity checks

* `trivialTheory` (proves nothing) is a concrete inhabitant of `ArithTheory`,
  confirming the axiom bundle (modus ponens + soundness + second incompleteness)
  is consistent.
* The "true arithmetic" theory `Prov := id` satisfies soundness and modus ponens
  but *fails* `godel2` — as it must, since a complete theory proves its own
  consistency. This confirms `godel2` carries genuine content.
