# Computational Evidence

## Small cases

The formal test family `hundredTest i`, indexed by `i : Fin 100`, uses 100 states. Reading the one-symbol word `[true]` reaches state `i`, whose output is zero. Lean proves uniformly that this word is a zero witness for every index and that the verified decision procedure returns `true`.

The file also checks the two-state parity automaton underlying Thue–Morse: `[true]` is accepted, `[true, false]` is a pumping-length witness, and the resulting accepted language is infinite.

## OEIS

The Thue–Morse sequence used as the concrete example is OEIS A010060, beginning

`0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0`.

## Counterexample hunt

The claim “if a DFA accepts any string, it accepts infinitely many strings” is false. The formal counterexample `singletonEmptyDFA` accepts exactly the empty word, so its language is nonempty and finite. The corrected theorem requires an accepted word of length at least the number of states.

## Verified table

| Family | Number of distinct automata | Witness | Expected result | Lean theorem |
|---|---:|---|---|---|
| `hundredTest` | 100 | `[true]` | zero occurs | `hundredTest_hasZero` |
| parity DFA | 1 | `[true]` | language nonempty | `parityDFA_accepts_nonempty` |
| parity DFA | 1 | `[true, false]` | language infinite | `parityDFA_accepts_infinite` |
| singleton-empty DFA | 1 | `[]` | nonempty but finite | `singletonEmptyDFA_nonempty_and_finite` |

No unchecked numerical computation is used as a proof; these results are kernel-checked in the Lean file.
