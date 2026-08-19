# Computational evidence

All numbers below were produced inside Lean.  The ones marked **kernel-checked** are theorems
in `Catalog/Applications/PoissonPairEvidence.lean` proved by `decide` (so the kernel actually
recomputed them); the ones marked *evaluated* come from `#eval` during exploration and are
reported as exploratory data only.

## 1. The model

For `G = ℤ/n` the characters are `ψ_k(x) = e^{2πikx/n}`, so

  `ψ_k(x) = 1  ⟺  n ∣ k·x`.

Under `FourierFA.isPoissonPair_iff_rectangle`, a nonempty pair `(S, T)` of subsets satisfies
Poisson summation exactly when

  (i) `n ∣ k·x` for every `x ∈ S`, `k ∈ T`  (all-ones block of the character table), and
  (ii) `|S| · |T| = n`  (maximal area).

`rectCount n` brute-forces all `2^n · 2^n` pairs of subsets of `ℤ/n` and counts those
satisfying (i) and (ii).

## 2. Small-case counts

| n | rectCount n | σ₀(n) (number of divisors) | status |
|---|-------------|----------------------------|--------|
| 1 | 1 | 1 | kernel-checked (`rectCount_one`) |
| 2 | 2 | 2 | kernel-checked (`rectCount_two`) |
| 3 | 2 | 2 | kernel-checked (`rectCount_three`) |
| 4 | 3 | 3 | kernel-checked (`rectCount_four`) |
| 5 | 2 | 2 | kernel-checked (`rectCount_five`) |
| 6 | 4 | 4 | kernel-checked (`rectCount_six`) |
| 7 | 2 | 2 | *evaluated* |
| 8 | 4 | 4 | *evaluated* |

The sequence `1, 2, 2, 3, 2, 4, 2, 4, …` is the divisor-counting function `σ₀`
(OEIS A000005), which is exactly the number of subgroups of the cyclic group `ℤ/n`.
This is the prediction of `FourierFA.card_poissonPairs` (nonempty Poisson pairs are in
bijection with subgroups), and it is what motivated proving the bijection rather than only
the existence statement.

## 3. Counterexample hunt

Two universal statements were deliberately stress-tested.

* *"Every twisted Poisson set is a coset."*  **False.**  The hunt succeeded immediately: for
  any nonempty `S` at all, Parseval produces weights `w` making the twisted identity hold
  (`FourierFA.twisted_of_nonempty`).  The smallest explicit non-coset witness is
  `S = {0,1} ⊆ ℤ/3`, since `|S| = 2` does not divide `3`; this is formalised as
  `FourierFA.twisted_counterexample_zmod_three`.  The statement is rescued by requiring
  unimodular weights (`FourierFA.twistedPoisson_converse`).

* *"Nonemptiness of `S` is superfluous in the converse."*  **False.**  `S = ∅` satisfies the
  Poisson identity against *every* `T` (both sides vanish); formalised as
  `FourierFA.isPoissonPair_empty`.  This is the only degenerate solution.

* *"Extremality for the uncertainty principle can happen away from cosets."*  No witness
  exists, for indicators (`FourierFA.donoho_stark_equality_iff_coset`) nor for general
  functions (`FourierFA.donoho_stark_equality_iff`: every extremal is a constant times a
  character restricted to a coset).  Consistency check with the table above: extremal
  supports in `ℤ/n` have size dividing `n`, matching the divisor counts.

## 4. What the data changed

The exact agreement with `σ₀(n)` — rather than a mere inequality `rectCount n ≥ σ₀(n)` —
indicated that no "extra" rectangles of maximal area exist, i.e. that the rectangle
characterisation is an equivalence and the correspondence with subgroups is a bijection.
Both were subsequently proved (`isPoissonPair_iff_rectangle`, `poissonPairEquivSubgroup`).
