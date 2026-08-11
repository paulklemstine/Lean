# Computational evidence (thread `th_ac518134`, cycle 3)

Every number below was produced by `#eval` on the catalog's own semantics (`satC` for
the tag-sensitive models, `satV` for the valuated models introduced this cycle), inside
Lean 4 / Mathlib.  These are *exploratory* computations on finite formula samples: they
are not proofs, and the verified artifacts of this cycle are the sorry-free theorems in
`Catalog/Algebra/DepthDominationCriterion.lean` and
`Catalog/Algebra/ReflectionDepthSpectrum.lean`.

## 1. Inclusion of tag-sensitive theories, and the exact threshold `N ≤ 1`

Setting: two tags, height bound `N`, height functions with values in `{0, …, N + 2}`
(so `(N+3)²` height functions and `(N+3)⁴` ordered pairs).  Semantic inclusion
`T(c') ⊆ T(c)` was approximated by brute force over a sample of **676 formulas** — all
formulas generated from `⊥` by three rounds of `□₀ ·`, `□₁ ·`, `· → ·`.

Mismatches between a criterion and the sampled inclusion:

| `N` | pairs tested | conjectured criterion (pointwise + order preservation) | exact criterion `DepthDominates` |
|---|---|---|---|
| 0 | 81 | 0 | 0 |
| 1 | 256 | 0 | 0 |
| 2 | 625 | **24** | 0 |
| 3 | 1296 | 82 | 6 |

Reading of the table.

* `N = 0, 1`: the conjectured criterion is never wrong — this is the positive half of
  the theorem `conjecturedCriterion_sufficient_iff_le_one` (for `N ≤ 1` the conjecture
  is *true*).
* `N = 2`: the conjectured criterion first fails, on 24 pairs; the smallest depth
  vectors involved are `d = (0,1)`, `d' = (1,2)` — the witness formalized as
  `inclusion_order_criterion_false`, with separating formula
  `liftWitness 0 1 1 = □₀⊥ → (¬□₁⊥ → ¬□₁□₁⊥)`.  Together with the previous row this
  pins the threshold at exactly `N = 2`.
* `N = 3`: the 6 residual mismatches of the *exact* criterion are an artefact of the
  formula sample, not a counterexample.  All of them reduce to the two depth-vector
  pairs `((1,2),(2,3))` and `((2,1),(3,2))`, where the criterion (correctly) says "not
  included" while no formula of the sample separates the theories: the discriminator
  needed there has box depth `4`, beyond the sample.  These are precisely the pairs of
  the counterexample used at height `3` in `Combinatorics/DepthVectorInclusion.lean`.

## 2. The reflection depth of the block theories

Setting: the block models introduced this cycle, `satV (blockVal w)` on the worlds
`0, …, n`, one tag, one atom.  For each `(n, w)` with `w ≤ n ≤ 5` the largest `d ≤ 7`
was computed for which the depth-restricted reflection rule ("`⊢ □a` implies `⊢ a` for
all `a` of box depth `< d`") holds on a sample of **82 formulas** (all formulas built
from `⊥, atom 0` by two rounds of `□ ·`, `· → ·`, together with the probes `□^k(atom 0)`
and the boxed falsa `□^k ⊥` for `k ≤ 6`).

| `n \ w` | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| 0 | 0 | | | | | |
| 1 | 1 | 0 | | | | |
| 2 | 2 | 1 | 0 | | | |
| 3 | 3 | 2 | 1 | 0 | | |
| 4 | 4 | 3 | 2 | 1 | 0 | |
| 5 | 5 | 4 | 3 | 2 | 1 | 0 |

All **21** measured values agree with `n - w`, the value proved in
`spectrumSys_depthReflection_iff`.  (With a sample containing no probe the same sweep
saturates at the sample's maximal box depth for the small-`w` entries — the probes
`□^k(atom 0)` are exactly the missing witnesses, which is what suggested them as the
right family.)

In the same sweep the provable iterated boxed falsa were computed:

| `n` | `{k ≤ 6 : ⊢ □^k ⊥}` for every `w ≤ n` |
|---|---|
| 0 | `{1,2,3,4,5,6}` |
| 1 | `{2,3,4,5,6}` |
| 2 | `{3,4,5,6}` |
| 3 | `{4,5,6}` |
| 4 | `{5,6}` |

i.e. `{k : k > n}` regardless of `w`.  This is the computational form of
`provable_spectrumSys_boxPow_bot`, and it is what makes
`reflection_depth_not_determined_by_inconsistency_spectrum` possible: along a row of the
first table the reflection depth ranges over all of `0, …, n` while the inconsistency
spectrum is constant.

## 3. Sequences / OEIS

The only integer sequences appearing are `N + 1` (the length of a maximal inclusion
chain, `theoryIncl_pigeonhole`) and `n + 1` (the number of pairwise distinct block
theories of height `n`, `spectrumSys_shift_injective`).  Both are trivial, so no OEIS
lookup applies.

## 4. Counterexample hunt

The universal claims proved this cycle were each tested for counterexamples before being
formalized:

* `levelAgree_iff_depthDominates` — checked on all `(N+3)⁴` pairs of height functions on
  two tags for `N ≤ 4`: `0` mismatches between the two criteria (they agree as Boolean
  predicates, which is what the theorem asserts).
* `spectrumSys_depthReflection_iff` — the sweep of §2; no `(n, w)` with `w ≤ n ≤ 5`
  deviates from `n - w`.
* `spectrumSys_eq_iff` (rigidity) — for `n ≤ 4` and all `w, w' ≤ n` the sampled theories
  of `(n, w)` and `(n, w')` coincide only when `w = w'`, as the theorem predicts.
