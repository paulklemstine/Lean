# Computational Evidence: Recurrence in Logistic Dynamics

## Small-case calculations

For the logistic transition `L(x) = (383/100)x(1-x)` started at `x₀ = 1/2`, the first iterates are:

| n | xₙ (decimal) | exact value when compact |
|---:|---:|---:|
| 0 | 0.500000000000 | 1/2 |
| 1 | 0.957500000000 | 383/400 |
| 2 | 0.155857062500 | 2493713/16000000 |
| 3 | 0.503896395719 | 12899747730400673/25600000000000000 |
| 4 | 0.957441853325 | — |
| 5 | 0.156060821667 | — |
| 6 | 0.504433373358 | — |
| 7 | 0.957424722119 | — |
| 8 | 0.156120848368 | — |
| 9 | 0.504591504349 | — |

Long iteration numerically approaches the three values approximately
`0.504666487408`, `0.957416597519`, and `0.156149315684`. The estimated multiplier of the third iterate around this cycle is `0.3298816964`, consistent with attraction. This numerical observation is evidence only; it is not used as an exact minimal-period proof.

## Counterexample hunt

The universal claim “every continuous interval self-map has dense periodic points” fails immediately for a constant map. For `f(x)=0`, every positive iterate of every state is `0`, so the only periodic state is `0`. A singleton is not dense in a nondegenerate interval or in the real line. This counterexample is established exactly in `Novelty/Consciousness/DejaVuMathematics.lean`.

The weaker claim “every continuous self-map of a nondegenerate compact interval has at least one periodic state” survives: the interval fixed-point theorem supplies a period-one state.

## Sequence-database search

No OEIS search is applicable. The principal objects are real-valued iterates depending on a parameter, not an integer sequence with a canonical encoding.

## Interpretation boundary

The experiment does not support identifying periodic-point density with a `70%` lifetime incidence. Topological density has no numerical value such as `0.70`; natural density requires a countable ordering; and probabilistic incidence requires a specified measure and observation protocol. At `r=3.83`, attraction toward a three-cycle concerns basin behavior, not the natural density of exact periodic points.
