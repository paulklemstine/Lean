# Computational evidence

The formal development concerns arbitrary finite languages, so the useful small cases are cardinality and threshold checks rather than empirical tests of a number-theoretic sequence. All numerical claims below are kernel-checked in `Cryptography/RamanujanOracleEvidence.lean`.

## Small cases

For a language with `n` statements, the formal theorem proves that there are `3^n` three-valued oracles and `2^n` Boolean truth assignments.

| n | three-valued oracles | Boolean semantics |
|---:|---:|---:|
| 0 | 1 | 1 |
| 1 | 3 | 2 |
| 2 | 9 | 4 |
| 3 | 27 | 8 |
| 4 | 81 | 16 |
| 5 | 243 | 32 |

The checked threshold calculations show that the cross-multiplied definition `19 n ≤ 20 k` requires at least 19 correct answers when `n = 20`, and at least 95 when `n = 100`.

## OEIS search

The oracle counts are the elementary geometric sequence `3^n` (OEIS A000244: 1, 3, 9, 27, 81, 243, ...) and the semantics counts are `2^n` (OEIS A000079: 1, 2, 4, 8, 16, 32, ...). No OEIS data is used in any proof.

## Counterexample hunt

The requested noncomputability assertion fails uniformly in every tested size and, by theorem, in every finite size: for each fixed semantics, `exactOracle` is a finite truth table with 100% accuracy. This is not merely experimental; `finite_language_has_accurate_oracle` proves it for arbitrary `n`.

Conversely, an adversarial truth assignment defeats every fixed oracle at every position. Thus no oracle can achieve 95% simultaneously for all semantics on any nonempty finite language (`no_uniform_accurate_oracle`).

## Table interpretation

The exponential counts do not establish noncomputability. They establish finite (though potentially enormous) table size. The actual diagonal obstruction arises only for the unbounded space `ℕ → Bool`, formalized by `no_enumeration_of_boolean_sequences`.
