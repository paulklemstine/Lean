# Future Directions: The Adaptive Observation Gap

The file `Catalog/Algebra/AdaptiveObservationGap.lean` lifts the static observation
theory of `Catalog/Algebra/ObservationGap.lean` (`ObsSys`, `observation_pigeonhole`,
`observation_quotient_card_le`, `observation_can_suffice`) to **adaptive** decision-tree
observation systems. The decisive structural move was to recognise that the *transcript*
of answers, even when the queries are chosen adaptively, still lives in `Fin n → Bool`,
so the recursive tree `AdaptiveObs` collapses to the same `2^n` counting bound proved by
a different (structural-recursion) argument. The static theory re-enters as the
history-independent special case through the bridge `twins_ofStatic`. The following
conjectures push the same "one bit per query, no matter how cleverly asked" principle
further.

## 1. Tight adaptive sufficiency on every tree shape, not just `Fin (2^n)`

We proved `adaptive_can_suffice`: on `Fin (2^n)` *some* adaptive system separates all
elements. The sharper statement is a structural characterisation: an adaptive system
`O : AdaptiveObs α n` separates all elements **iff** its transcript map hits exactly
`Fintype.card α` distinct leaves, and this is achievable iff `α` admits an injection into
the set of length-`n` bitstrings *respecting any prescribed prefix-tree shape*. Concretely,
one would define the reachable-leaf finset `leaves O ⊆ (Fin n → Bool)` and prove
`Fintype.card α ≤ (leaves O).card ≤ 2^n` with both bounds tight.

The key insight is that adaptivity reshapes *which* `2^n` leaves are reachable but never
their number, so separation is a pure injectivity-into-leaves statement independent of the
adaptive policy. Why now? `AdaptiveObs.transcript` and `Fintype.card_le_of_injective` are
already in place; only a `Finset.image` of the transcript map and a leaf-counting recursion
on the tree are missing, both elementary.

## 2. Adaptivity gives no speed-up: the worst-case query lower bound

Define `adaptiveComplexity α` as the least `n` for which some `AdaptiveObs α n` separates
all elements, and (from the static side) `staticComplexity α` analogously. Conjecture:
for every finite `α`, `adaptiveComplexity α = staticComplexity α = ⌈log₂ |α|⌉`. The bridge
`twins_ofStatic` already gives `adaptiveComplexity ≤ staticComplexity`; the reverse needs
`adaptive_card_le_of_distinguishes` to force `n ≥ log₂ |α|` and a construction matching it.

The key insight is that the information-theoretic floor `⌈log₂ |α|⌉` is policy-independent:
adaptivity cannot reduce the number of queries below the entropy bound. Why now? The lower
bound is an immediate corollary of `adaptive_card_le_of_distinguishes`
(`2^n ≥ |α| ⇒ n ≥ ⌈log₂|α|⌉` via `Nat.lt_pow_iff_log_lt`), so only the matching upper-bound
construction (a balanced binary tree) remains.

## 3. Average-case twin abundance: most pairs are adaptive twins

The pigeonhole theorem is worst-case. Conjecture: for any `O : AdaptiveObs α n`, the number
of *ordered distinguishable pairs* satisfies
`#{(a,b) | O.transcript a ≠ O.transcript b} ≤ |α|² · (1 - 1/2^n)`, equivalently the number
of twin pairs is at least `|α|²/2^n`. This follows by Cauchy–Schwarz on the fibre sizes of
the transcript map: `Σ_classes |class|² ≥ |α|²/(#classes) ≥ |α|²/2^n`, using
`adaptive_quotient_card_le` for the `#classes ≤ 2^n` bound.

The key insight is that the quotient bound upgrades from "at least one twin pair exists" to
"a uniformly random pair is a twin with probability ≥ 1 − 2^n/|α|", so when `|α| ≫ 2^n`
indistinguishability is the generic case, not an exception. Why now? `adaptive_quotient_card_le`
already caps the class count, and Mathlib's `Finset.inner_mul_le_norm_mul_norm` /
`Finset.sum_div_card_le_sum_sq` supply the Cauchy–Schwarz step over fibres.

## 4. Generalized-alphabet adaptive trees and the `k^n` bound

Replace Boolean nodes by `k`-ary nodes: an adaptive system whose `m`-th query returns a value
in a fixed `k`-element type, branching into `k` subtrees. Conjecture: the transcript lives in
`Fin n → β` with `|β| = k`, so `adaptive_card_le_of_distinguishes` generalizes to
`|α| ≤ k^n`, exactly matching `ObservationGap.generalized_observation_pigeonhole`. The bridge
`ofStatic` should generalize to `GenObsSys`.

The key insight is that the entire argument is alphabet-agnostic: it only uses that the
transcript codomain is a fixed finite product, so the `k^n` law and its tightness transfer
verbatim. Why now? `ObservationGap.GenObsSys` and `generalized_observation_pigeonhole` already
exist; the adaptive `inductive` need only carry the branching type `β`, and every proof in the
current file ports by replacing `Bool` with `β` and `2` with `Fintype.card β`.

## 5. Infinite types: no finite adaptive system separates `ℕ`, and a computability gap

For infinite `α`, conjecture that no finite-depth adaptive system separates all elements
(directly: a depth-`n` transcript has finite range `≤ 2^n < ℵ₀`, so it cannot be injective on
an infinite type — a one-line consequence of `adaptive_card_le_of_distinguishes` recast via
`Set.Infinite`). The deeper conjecture restricts to *computable* nodes (each `p : α → Bool`
decidable): there exist decidable equivalence relations on `ℕ` whose classes cannot be
separated by any finite system of decidable predicates, with the minimal count tied to the
Turing degree of the relation.

The key insight is that the finite combinatorial obstruction (range size `< |α|`) and the
computability obstruction (no decidable predicate refines a sufficiently complex relation) are
two faces of the same observation gap, linking the pigeonhole theory to Gödel-style limits on
what a computable observer can ever distinguish. Why now? The cardinality half is immediate
from `adaptive_card_le_of_distinguishes`; the computability half is the natural entry point
into Mathlib's `Computability`/`Computable` and `Turing` libraries.
