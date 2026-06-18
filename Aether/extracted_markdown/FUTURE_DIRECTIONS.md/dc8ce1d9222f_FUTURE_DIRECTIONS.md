# Future Directions — The Observation Complexity Cycle

## Synthesis

This cycle attacked the *information-theoretic gap* in the Observation framework
(`Catalog/Algebra/ObservationGap.lean`, `Catalog/Algebra/AdaptiveObservationGap.lean`).
Those files establish only the **one-sided** counting law: an observation system of
depth `n` can separate at most `2 ^ n` elements, and that bound is *achievable* on
`Fin (2 ^ n)`. What was missing is the **exact query complexity** for an arbitrary
finite type. We closed this gap in `Catalog/Algebra/ObservationComplexity.lean` with
the theorem that the minimal depth needed to distinguish every element of a finite
type `α` is exactly `Nat.clog 2 |α| = ⌈log₂ |α|⌉`, stated as an `IsLeast` fact
(`min_distinguishing_depth`).

The structural insight that drove the proof is that `Nat.clog` is the *exact* inverse
of `2 ^ ·` on powers (`Nat.clog_pow`, `Nat.le_pow_clog`). This lets us *transport*
both directions of the existing counting law into a single depth statement: the
cardinality bound `|α| ≤ 2 ^ n` becomes the depth lower bound by monotonicity of
`clog`, and the `Fin (2 ^ n)` sufficiency result becomes a general construction by
binary-encoding an embedding `α ↪ Fin (2 ^ n)`. A second, conceptual payoff is that
the *same* number `Nat.clog 2 |α|` is optimal for both the static and the adaptive
(decision-tree) models — the lower bound is proved for adaptive systems while the
matching upper bound is realized by a static one — so **adaptivity buys no speedup**
for the pure distinguishability task. The only genuine subtlety surfaced in the
generalization: the base-`k` version is sharp only for `k ≥ 2`, and the `k ≤ 1`
boundary (where `Nat.clog` collapses to `0`) had to be handled by an explicit case
split. That degenerate case is itself informative: a unary alphabet carries no
discriminative power, which is exactly why the logarithmic law needs `k ≥ 2`.

What did *not* work cleanly: an attempt to phrase the result as an `sInf` equality
between the static and adaptive optimal depths would have forced us to *pad* small
decision trees up to larger depths (a constructive operation on the `AdaptiveObs`
inductive type). Re-casting the statement as `IsLeast` sidestepped this entirely and
is in fact the stronger, cleaner statement. The padding operation remains an
interesting missing primitive (see Direction 3).

## Results Summary

- `distinguish_depth_ge_clog`: **proved** — any adaptive system distinguishing all of
  `α` has depth `≥ Nat.clog 2 |α|`; sharpens the catalog cardinality bound into a
  query lower bound.
- `exists_distinguishing_static`: **proved** — a static system of depth exactly
  `Nat.clog 2 |α|` distinguishes every finite type, generalizing
  `observation_can_suffice` from `Fin (2 ^ n)` to all finite types.
- `min_distinguishing_depth`: **proved** (flagship) — `Nat.clog 2 |α|` is the least
  depth admitting a distinguishing adaptive system; the exact query complexity, with
  adaptivity giving no advantage.
- `min_distinguishing_depth_fin100`: **proved** — concrete witness: separating the
  100 elements of `Fin 100` costs exactly 7 observations (`2^6 < 100 ≤ 2^7`).
- `generalized_observation_complexity`: **proved** — the base-`k` lower bound
  `Nat.clog k |α| ≤ n` for observations valued in a `k`-element type; sharp for
  `k ≥ 2`.

## Research Directions

### Direction 1: Sharp k-ary sufficiency (matching the generalized lower bound)
**Hypothesis**: For every finite type `α` and every finite alphabet `β` with
`|β| = k ≥ 2`, there exists a static `GenObsSys α β (Nat.clog k |α|)` whose profile is
injective; hence the exact `k`-ary query complexity is `Nat.clog k |α|`.
**Test**: Construct a base-`k` digit-extraction system on `Fin (k ^ n)` (the `k`-ary
analogue of `observation_can_suffice`), then pull it back along an embedding
`α ↪ Fin (k ^ n)` exactly as in `exists_distinguishing_static`. Prove the resulting
`IsLeast`.
**Why now**: We already proved the `k`-ary lower bound (`generalized_observation_complexity`)
and the Boolean construction (`exists_distinguishing_static`); the only missing piece
is a `Nat`-digit (rather than `testBit`) separation lemma. The key insight is that the
embedding-pullback proof is *base-agnostic* — only the concrete `Fin (k ^ n)` witness
changes.
**If true**: A complete base-`k` observation-complexity theorem, unifying Boolean and
multi-valued sensing under one logarithmic law.
**If false**: It would reveal that `Nat`-digit extraction fails to be injective at some
base, pointing to an arithmetic obstruction invisible in the Boolean case.

### Direction 2: Weighted / cost-sensitive observations
**Hypothesis**: If query `i` costs `w i : ℕ`, the minimum *total cost* to distinguish
all of `α` is governed by a Kraft-style inequality `∑ 2^(-depth) ≤ 1`, and the optimal
cost equals the Huffman-code cost of the uniform distribution on `α`.
**Test**: Define `WeightedObs` extending `AdaptiveObs` with a cost annotation; prove a
Kraft inequality for the leaf depths of a distinguishing tree, then a Huffman-optimality
lower bound.
**Why now**: The decision-tree model `AdaptiveObs` already exposes per-branch structure,
and `min_distinguishing_depth` shows the *uniform-cost* optimum is `⌈log₂ |α|⌉`. The key
insight is that variable costs turn the flat `clog` bound into an entropy/Kraft bound —
the natural next refinement of "1 bit per query".
**If true**: Connects the observation framework to coding theory and entropy, a genuine
cross-domain bridge (Information Theory ↔ Algebra catalog).
**If false**: Would show decision trees over an abstract type lack enough structure for
Kraft, isolating exactly which probabilistic assumption is needed.

### Direction 3: Tree padding and the static/adaptive sInf equality
**Hypothesis**: If a distinguishing adaptive system of depth `n` exists, one of depth
`n + 1` exists too; consequently the achievable-depth set is upward closed and
`sInf {adaptive depths} = sInf {static depths} = Nat.clog 2 |α|`.
**Test**: Define `AdaptiveObs.pad : AdaptiveObs α n → AdaptiveObs α (n+1)` (append a
constant query), prove it preserves transcript injectivity, then derive the `sInf`
equality from `min_distinguishing_depth`.
**Why now**: We deliberately used `IsLeast` to avoid padding; making padding a first-class
operation closes that gap. The key insight is that upward closure is the one missing
lemma separating `IsLeast` from a full `sInf`/monotonicity characterization.
**If true**: A reusable `pad` primitive enabling monotone reasoning about all future
decision-tree results.
**If false**: Would expose a rigidity in the `AdaptiveObs` inductive encoding (e.g. depth
being intrinsic), motivating a depth-indexed-by-`≤` reformulation.

### Direction 4: Quotient-refinement complexity (partial information)
**Hypothesis**: To *refine* a given partition of `α` into `m` classes (rather than fully
separate all elements) the minimal depth is `Nat.clog 2 m`, where `m` is the number of
target classes.
**Test**: Generalize `min_distinguishing_depth` to a target `Setoid s` on `α`, replacing
"injective transcript" with "transcript refines `s`" and `|α|` with the number of
`s`-classes; reuse `refinement_monotone_separation` from `ObservationGap.lean`.
**Why now**: `ObservationGap.observation_quotient_card_le` and
`refinement_monotone_separation` already provide the quotient machinery; the key insight
is that full distinguishability is the special case `s = ⊥`, so the complexity theorem
should relativize to any target resolution.
**If true**: A complexity theory of *partial* observation, modeling sensors that only
need to resolve coarse state classes — directly relevant to the "adaptive observation
systems" motivation of this research line.
**If false**: Would indicate that intermediate partitions interact with adaptivity
differently than full separation, the first place adaptivity might actually help.

### Direction 5: Average-case (expected) query depth
**Hypothesis**: Under the uniform distribution on `α`, the minimum *expected* number of
queries of any distinguishing decision tree is `≥ log₂ |α| - O(1)` and is achieved
within `+1` of `⌈log₂ |α|⌉` by a balanced tree (Shannon–Fano).
**Test**: Define expected depth `𝔼[depth]` over leaves of an `AdaptiveObs` tree; prove a
Jensen/entropy lower bound and a balanced-tree upper bound.
**Why now**: `min_distinguishing_depth` settles the worst case exactly; the expected case
is the natural complement. The key insight is that the worst-case `clog` bound already
forces enough leaves, so the entropy lower bound follows from convexity of `2^(-x)` over
the leaf-depth multiset.
**If true**: Completes the worst-case/average-case picture, tightening the link to
Shannon entropy.
**If false**: Would reveal that abstract decision trees can beat the entropy bound on
average (impossible for prefix codes), signaling a modeling mismatch worth diagnosing.
