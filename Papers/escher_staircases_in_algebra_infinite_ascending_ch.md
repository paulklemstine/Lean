# Computational evidence

The decisive issue is containment direction, so only elementary small cases are needed.

| `n` | generator `2^n` | ideal `(2^n)` | relation to next ideal |
|---:|---:|---|---|
| 0 | 1 | all integers | `(2) ⊊ (1)` |
| 1 | 2 | even integers | `(4) ⊊ (2)` |
| 2 | 4 | multiples of 4 | `(8) ⊊ (4)` |
| 3 | 8 | multiples of 8 | `(16) ⊊ (8)` |
| 4 | 16 | multiples of 16 | `(32) ⊊ (16)` |

At each step, `2^(n+1)` is divisible by `2^n`, while `2^n` is not divisible by `2^(n+1)`. Hence the chain is descending and strict.

For the proposed integer-valued-polynomial family, the same constant polynomials give immediate tests. The constant polynomial `2^n` takes values in `2^n ℤ`, but not in `2^(n+1) ℤ`. Thus the claimed ascending containment fails at every tested—and indeed every—stage.

## Counterexample hunt

The universal motivating assertion is already contradicted at the first step: the constant polynomial `2` belongs to the value-divisibility ideal for `n = 1`, but it does not belong to the ideal for `n = 2`. Therefore `I_1 ⊆ I_2` is false.

The extra intersection condition based on zero supplies no discrimination: zero lies in every ideal, so it lies in every intersection of ideals.

## OEIS and plots

The generators are the standard powers-of-two sequence `1, 2, 4, 8, 16, …` (OEIS A000079). No plot is needed because the formal question is order-theoretic rather than asymptotic. The Lean development proves the general containment facts and the zero-intersection theorem, rather than relying on these calculations.
