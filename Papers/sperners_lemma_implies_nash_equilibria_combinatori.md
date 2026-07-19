# Computational evidence

## Small cases

The formal files carry out the relevant finite calculations inside Lean.

| Instance | Result |
|---|---|
| Boolean path coloring with unequal endpoint colors | The number of color-changing edges is odd, hence at least one exists. |
| Matching Pennies, profile `(1/2, 1/2)` for both players | Every pure deviation has expected payoff `0`, so the profile is Nash. |
| Arbitrary Matching Pennies equilibrium | The Nash inequalities and probability-sum equations force `p(false) = q(false) = 1/2`; the remaining probabilities are also `1/2`. |
| Prisoner’s Dilemma, mutual defection | Every pure unilateral deviation has payoff no greater than staying with defection. |

These calculations are kernel-checked in `Sperner1D.lean` and `Nash.lean`; the Matching Pennies result is an exhaustive symbolic classification of all real-valued probability profiles, not a grid sample.

## OEIS search

No new integer sequence is central to the formalized claim. The parity invariant concerns the number of color changes in an arbitrary Boolean word and therefore does not define a single sequence without choosing a family of colorings. An OEIS lookup was consequently not applicable.

## Counterexample hunt

The exact formal analysis found no counterexample to the one-dimensional Sperner statements or to the claimed equilibria.

It did expose structural problems with the proposed general construction: the simplex of distributions over pure profiles is not the product of players’ mixed-strategy simplices, and a player index cannot generally serve as a strategy label. These are type/dimension mismatches rather than numerical counterexamples. The claimed general algorithm and `O(N^n)` bound were therefore not encoded as theorems.

## Numerical table for Matching Pennies

Against an opponent who plays `false` with probability `q`, player 1’s pure payoffs are:

| Pure action | Expected payoff |
|---|---:|
| `false` | `2q - 1` |
| `true` | `1 - 2q` |

Both can be best responses only at `q = 1/2`. The symmetric calculation for player 2 forces player 1’s probability to be `1/2`. Lean proves these equations from the full Nash definition in `matchingPennies_nash_probabilities`, then proves the biconditional classification in `matchingPennies_isNash_iff`.
