# Computational Evidence

The central claims are cardinality/diagonalization statements about *all* possible
ground truths (functions `ℕ → Bool`) and *all* possible oracles (functions
`ℕ → Option Bool`). These are infinitary universals whose truth is settled by the
counting argument rather than by any finite computation, so exhaustive search is not
meaningful. Nevertheless we sanity-check the constructive kernels of the proofs on
small cases.

## 1. The adversarial truth defeats a concrete oracle

Take the toy oracle `O n = some (n.testBit 0)` (predicts "true iff `n` is odd").
The adversarial truth `adv O n = !(O n)` should make `O` wrong at every `n`:

| n | O n            | adv O n | correct? |
|---|----------------|---------|----------|
| 0 | some false     | true    | no       |
| 1 | some true      | false   | no       |
| 2 | some false     | true    | no       |
| 3 | some true      | false   | no       |
| 4 | some false     | true    | no       |

Correct count on the first `N` statements: `0` for every `N`. This is exactly
`exists_truth_zero_hits`, and it drives running accuracy to `0`, refuting any fixed
accuracy guarantee (`no_oracle_high_accuracy_all_worlds`).

## 2. Block diagonalization hits each oracle infinitely often

`blockTruth F n = adv (F (Nat.unpair n).1) n`. The block of oracle `i` is
`{ n | (Nat.unpair n).1 = i }`. First few values of `Nat.unpair`:

| n | Nat.unpair n | block index |
|---|--------------|-------------|
| 0 | (0,0)        | 0           |
| 1 | (0,1)        | 0           |
| 2 | (1,0)        | 1           |
| 3 | (0,2)        | 0           |
| 4 | (1,1)        | 1           |
| 5 | (2,0)        | 2           |

Each index `i` recurs for infinitely many `n` (namely `n = Nat.pair i j`, all `j`),
so each oracle is defeated infinitely often by the single truth `blockTruth F`. This
is `family_errs_infinitely_often`.

## 3. Cardinality is decisive, not searchable

- Ground truths `ℕ → Bool` have cardinality `2 ^ ℵ₀` (continuum): `not_countable_truth`.
- Any program-enumerable family of oracles is indexed by `ℕ` (countable).
- A perfect oracle pins down exactly one truth (`perfect_unique`), so a countable
  family covers only countably many truths (`covered_countable`).

`2 ^ ℵ₀ > ℵ₀` (Cantor) then forces uncountably many uncovered truths
(`missed_uncountable`). No finite/OEIS search is applicable; the gap is a cardinality
gap. No counterexample exists (the proofs are complete and axiom-clean).
