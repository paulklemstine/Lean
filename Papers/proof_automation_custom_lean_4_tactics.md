# Computational Evidence

## Small cases

The reflected trial-division procedure was evaluated by Lean while proving the closed examples in `Catalog/Logic/ProofAutomation/CustomTactics.lean`:

| Input | Boolean result represented by the theorem | Mathematical result |
|---:|:---:|:---|
| 97 | `true` | `Nat.Prime 97` |
| 91 | `false` | `¬ Nat.Prime 91` |

For 91, the search range includes 7 and `7 ∣ 91`, giving a concrete rejection witness. For 97, exhaustive divisors `2 ≤ d < 97` are rejected by kernel evaluation after applying the proved equivalence `trialPrime_correct`.

The tropical examples exercise nested distribution and absorption symbolically rather than by numerical sampling. The spectral result is universal and is checked from an arbitrary eigen-equation, so random floating-point eigenvalue calculations would add little assurance beyond the formal theorem.

## OEIS search

No integer sequence is conjectured or introduced, so an OEIS search is not applicable.

## Counterexample hunt

The principal universal claims are algebraic identities or theorem-backed implications. Lean checks them for arbitrary inputs. In particular, the spectral theorem requires a nonzero eigenvector and a uniform row-sum hypothesis; the proof uses both, avoiding the empty/vacuous eigenvector case. No counterexample was found, and all claims in the Lean file compile.

## Tables or plots

No plot is relevant: min-plus normalization is symbolic, primality evidence is discrete, and the spectral theorem supplies an exact inequality rather than an empirical approximation.