# Computational evidence

## Small finite instance

Take both groups to be `ZMod 5`, let the public homomorphism be the identity, and let the public target and witness be `2`. For challenge `true`, the affine reindexing sends each random tape `r` to `z = r + 2`:

| `r` | `z = r + 2 (mod 5)` | real commitment | real response |
|---:|---:|---:|---:|
| 0 | 2 | 0 | 2 |
| 1 | 3 | 1 | 3 |
| 2 | 4 | 2 | 4 |
| 3 | 0 | 3 | 0 |
| 4 | 1 | 4 | 1 |

The simulator indexed by `z` returns commitment `z - 2` and response `z`, so each row is exactly the corresponding real transcript. The map `r ↦ r + 2` is a permutation, hence all five simulated and real transcripts occur with the same multiplicity. For challenge `false`, the reindexing is the identity.

For extraction, two accepting responses at commitment `a` satisfy
`zFalse = a` and `zTrue = a + 2`; their difference is `2`, the witness.

These calculations are instances of the fully proved general theorems `real_eq_simulated_reindexed`, `perfect_zero_knowledge`, and `special_soundness` in `AffineDuality.lean`; they are not used as a substitute for the proof.

## Counterexample hunt and boundary cases

The theorem is algebraic and applies to every finite additive commutative group, not merely cyclic groups. The proof also checks both Boolean challenges by cases. The following potential failure modes are excluded by explicit hypotheses or by the statement:

- An alleged witness not mapping to the public target does not satisfy `IsWitness`, so the real/simulator equality is not claimed.
- Transcript-distribution equality requires finiteness because the formal distribution is the uniform multiset over all random tapes.
- Extraction requires two accepting responses with the same commitment and opposite challenges.
- No injectivity or surjectivity of the public homomorphism is needed.

No counterexample exists under these hypotheses because the Lean proof establishes the universal statement. If the shared-commitment condition is dropped, arbitrary accepting transcripts need not yield a witness by subtraction.

## OEIS and plots

No integer sequence arises naturally here, so an OEIS search and numerical plot would not be informative. The relevant finite data are permutations and transcript multiplicities; the table above displays the smallest nontrivial cyclic example large enough to make the affine reindexing visible.
