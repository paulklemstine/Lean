# Computational evidence

The formal target is finite and admits exact symbolic calculation; no external numerical program or unverified search is needed.

## Small cases: missing one bad location

If a verifier samples one of `n` locations uniformly and exactly one location detects cheating, `k` independent repetitions miss it with probability

| `n` | `k` | failure probability | claimed binary benchmark |
|---:|---:|---:|---:|
| 4 | 1 | `3/4` | `1/2` |
| 4 | 2 | `9/16` | `1/4` |
| 4 | 3 | `27/64` | `1/8` |
| 6 | 2 | `25/36` | `1/4` |
| 8 | 3 | `343/512` | `1/8` |

These are instances of `singleBadFailure n k = ((n-1)/n)^k`. The Lean theorems `four_check_failure`, `four_check_not_binary_sound`, and `no_fixed_repetition_half_bound` establish the relevant universal claims exactly over rational numbers.

## Small cases: Boolean masking

For ciphertext `c = m XOR r`, each fixed message and ciphertext has exactly one compatible randomness bit:

| message `m` | ciphertext `c` | unique randomness `r` |
|---:|---:|---:|
| false | false | false |
| false | true | true |
| true | false | true |
| true | true | false |

`mask_fiber_card` formally proves all four cases without an opaque computational decision procedure. Equal fiber sizes yield `uniform_mask_perfect_privacy`.

## Counterexample hunt

The universal privacy assertion for raw coordinate opening already fails at the smallest nonempty witness: a one-bit witness with two valid values. Challenging coordinate zero reveals whether the witness is `false` or `true`; this is formalized by `bit_opening_leaks`.

The advertised universal `2⁻ᵏ` soundness estimate fails for every positive `k` already at four proof locations, and the stronger theorem `no_fixed_repetition_half_bound` constructs a counterexample size `n = 2k+2` for every fixed repetition count.

## OEIS and plots

No OEIS search is relevant: the sequences here are elementary geometric powers with closed forms, not an unidentified integer sequence. A plot would add no information beyond monotonicity of `((n-1)/n)^k`; the exact rational table and universal Lean inequalities are more informative.
