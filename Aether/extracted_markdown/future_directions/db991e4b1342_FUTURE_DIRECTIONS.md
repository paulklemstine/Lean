# FUTURE_DIRECTIONS — Algebraic closure operators as tropical fixed-point systems

## Synthesis

This cycle built a genuine, fully verified bridge between **algebraic closure
theory** and **tropical / idempotent algebra**, realized as an *algorithm* rather
than an extensional black box. We modeled a finitely-generated (implicational /
forward-chaining) closure system on a finite type `α` by a single propagation
operator `step` on `Finset α`, and showed that its finite iteration is a bona
fide closure operator. The key structural payoff is that the same dynamics live
on the Boolean idempotent semimodule `α → Bool` (with `∨ = ⊕`, `∧ = ⊗`): the
tropical operator `T w = χ(step (supp w))` satisfies `supp (T w) = step (supp w)`,
its iterate computes the closure on supports (`supp_TIter`), and its fixed points
are *exactly* the closed sets (`T_fixed_iff_isClosed`, packaged as the bijection
`closedFixedEquiv`). This is the closure-theory ↔ tropical-dynamics dictionary the
concept asked for, and it is now machine-checked end to end (only `propext`,
`Classical.choice`, `Quot.sound`).

The technical heart was a reusable order-theoretic engine: any monotone
inflationary endomap of a finite powerset reaches a fixed point within
`card α + 1` iterations (`iterate_stabilizes`), proved by a cardinality potential
(`card_iterate_ge_of_strict`) together with fixed-point propagation
(`iterate_fixed_propagates`). The Critic's probing of the bound is recorded in the
lab notebook: `card α` alone is *insufficient* — when rules fire from the empty
premise the chain can stay strict for a full `card α` steps, so the `+1` slack is
genuinely required. This is the cleanest falsifiable boundary the cycle exposed.

What did *not* generalize naively: the **join**. Closed sets are closed under
intersection (`isClosed_inter`), which on weights is exactly the tropical product
`&&` = `⊗` = `min` (`T_fixed_and`), giving a meet-subsemilattice / sub-semimodule
structure. But the union of two closed sets need not be closed, so there is no
dual `T_fixed_or`; the correct join is `cl R (C ∪ D)`. This asymmetry — meet is
tropical-linear, join requires re-closing — is the structural insight that seeds
the next cycle's most promising directions (graded/min-plus weights and the
lattice structure of the fixed-point set).

## Results Summary

- `step_extensive`: proved — forward chaining is inflationary (`S ⊆ step R S`).
- `step_mono`: proved — forward chaining is monotone in the seed.
- `step_subset_univ`: proved — bookkeeping bound used for stabilization.
- `card_iterate_ge_of_strict`: proved — a strictly-increasing iterate chain grows in cardinality.
- `iterate_fixed_propagates`: proved — a fixed point of `f` is fixed by all later iterates.
- `iterate_stabilizes`: proved — monotone inflationary maps on a finite type stabilize in `card α + 1` steps.
- `cl_isClosed`: proved — the iterated closure is a fixed point (`R`-closed).
- `subset_cl`: proved — extensivity of the closure.
- `cl_mono`: proved — monotonicity of the closure.
- `cl_least`: proved — `cl R S` is the least closed set containing `S` (universal property).
- `isClosed_iff_cl_eq`: proved — closedness is fixed-point-ness of the closure.
- `cl_idempotent`: proved — idempotence of the closure.
- `closureOperator`: proved (definition) — packages `cl` as a Mathlib `ClosureOperator (Finset α)`.
- `closureOperator_isClosed_iff`: proved — order-theoretic closedness equals `R`-closedness.
- `supp_T`: proved — the tropical operator realizes `step` on supports.
- `supp_TIter`: proved — **main bridge**: iterating `T` computes the closure on supports.
- `T_fixed_iff_isClosed`: proved — tropical fixed points are exactly closed supports.
- `closedFixedEquiv`: proved (definition) — bijection closed sets ≃ `T`-fixed weights.
- `isClosed_inter`: proved — closed sets are closed under intersection (meet).
- `supp_and`: proved — pointwise `&&` of weights has support equal to the intersection.
- `T_fixed_and`: proved — fixed points are closed under the tropical product `⊗`/`min`.

## Research Directions

### Direction 1: Min-plus graded closure (derivation depth as tropical weight)
**Hypothesis**: Replacing `Bool` by `WithTop ℕ` and defining a min-plus operator
`T∞ w b = min (w b) (1 + min over rules (P,b) of max_{p∈P} w p)`, the least
fixed point `w*` from the seed indicator (0 on `S`, `⊤` elsewhere) satisfies
`{b | w* b ≠ ⊤} = cl R S` AND `w* b` equals the minimal number of forward-chaining
rounds needed to derive `b`.
**Test**: Formalize `T∞`, prove monotonicity/stabilization (the generic engine
`iterate_stabilizes` should port to any finite directed-complete order with a
cardinality-like potential), then prove the support equality and the depth
characterization by induction on rounds.
**Why now**: We already have the Boolean conjugacy `supp_T` and the stabilization
engine; only the value-tracking layer is new, and the `+1`-step boundary analysis
tells us exactly how depth accumulates.
**If true**: Closures come with a *certificate of cost* — a tropical (min-plus)
distance to derivability — turning the bridge from qualitative to quantitative and
connecting to shortest-path / Bellman-Ford tropical linear algebra.
**If false**: The failure would localize to rules with large premises (where
`max` over the premise breaks the additive grading), isolating exactly which rule
shapes admit a depth semantics.

### Direction 2: The fixed-point set is a complete lattice (Knaster–Tarski, concretely)
**Hypothesis**: `{w : α → Bool // T R w = w}` is a complete lattice under the
pointwise Boolean order, with meet `= &&` (already `T_fixed_and`) and join given by
`χ (cl R (supp w₁ ∪ supp w₂))`; this lattice is order-isomorphic to the lattice of
`R`-closed sets, and `closedFixedEquiv` is an order isomorphism.
**Test**: Define the join on fixed points via re-closure, prove the lattice laws,
and upgrade `closedFixedEquiv` to an `OrderIso`. Cross-check against Mathlib's
`ClosureOperator.closeds` complete-lattice instance for `closureOperator R`.
**Why now**: `isClosed_inter`, `cl_least`, and `closedFixedEquiv` already supply
meet, least-upper-bound machinery, and the bijection; only the order-preservation
and the asymmetric join remain.
**If true**: We obtain a concrete, computable Knaster–Tarski lattice whose
operations are tropical (meet) plus one closure call (join) — a clean
algorithmic model of the closed-set lattice.
**If false**: The obstruction is necessarily the join axioms; a counterexample
would reveal a rule system whose closed sets fail some lattice identity, sharpening
the hypotheses (e.g. requiring the rule set to be "join-stable").

### Direction 3: Reconstruction — recover the rule set from the operator
**Hypothesis**: For any monotone inflationary `f : Finset α → Finset α` whose closed
sets (`f S = S`) are closed under intersection, there is a rule set `R` with
`cl R = ` (the closure induced by `f`), and `R` can be taken canonical (one rule
`(C, b)` per closed `C` and `b ∈ f (insert ... )`). I.e. forward-chaining closures
are *exactly* the intersection-closed finite closure systems.
**Test**: Construct `R` from the closed-set family, prove `cl R S = ⋂ {C closed | S ⊆ C}`
using `cl_least` and `isClosed_inter`, and prove the round-trip `cl (rulesOf f) = closure f`.
**Why now**: `cl_least` + `isClosed_inter` already give the infimum
characterization on one side; this is the converse, and the catalog's
`AlgebraEMLReconstruction` Tannaka-style results suggest the uniqueness half is in reach.
**If true**: Completes the bridge into a *correspondence theorem*: implicational
rule systems ≃ intersection-closed closure operators, with tropical iteration as the
canonical computation.
**If false**: Some intersection-closed closure is not finitely implicational; the
counterexample pins down the exact expressive gap between rules and operators.

### Direction 4: Sharp stabilization time and its tightness
**Hypothesis**: The bound `card α + 1` in `iterate_stabilizes` is *tight*: there is
a rule set on `Fin n` and a seed whose forward-chaining chain is strict for exactly
`n` steps; moreover the optimal uniform bound is `n` (not `n+1`) whenever the seed
is nonempty, and `n+1` is needed only to absorb empty-premise "axiom" rules.
**Test**: Exhibit an explicit chain `∅ ⊊ {0} ⊊ {0,1} ⊊ … ` driven by rules
`({k}, k+1)` and `(∅, 0)`, and prove its length; then prove the conditional
improved bound `card α` for nonempty seeds.
**Why now**: The lab notebook already identifies empty-premise rules as the precise
reason the `+1` is needed; turning that observation into a tightness theorem is a
direct, falsifiable next step.
**If true**: We get the exact complexity of tropical closure iteration, a crisp
statement about idempotent-semimodule dynamics.
**If false**: A shorter universal bound would mean the cardinality potential is not
the right measure — pointing toward a finer (e.g. antichain-height) invariant.

### Direction 5: Tropical-linear (matrix) form and spectral reading
**Hypothesis**: When every rule has a singleton premise, `step` is literally a
Boolean-matrix action `T w = w ∨ M ⊗ w` for the relation matrix `M` of the rules,
and `cl` is the reflexive-transitive closure `M*` (Kleene star) in the Boolean
tropical semiring; closed sets are exactly the `M*`-stable vectors.
**Test**: Specialize `RuleSet` to singleton premises, define `M`, prove
`T R w = w ∨ M.mulVec w` (Boolean), and identify `cl` with `M*` via the existing
stabilization engine.
**Why now**: The operator is *already* written in tropical-tensor form in the file's
header comment; the singleton-premise restriction makes it genuinely matrix-linear,
and `iterate_stabilizes` gives the finite Kleene-star convergence for free.
**If true**: Connects the closure bridge to tropical linear algebra and the
Tropical catalog directory (Kleene stars, transitive closure), enabling spectral /
eigenvector statements about closure operators.
**If false**: The discrepancy isolates the role of multi-element premises, which are
precisely the *nonlinear* (hypergraph) part of forward chaining — clarifying where
the matrix picture must give way to a tensor/hypergraph picture.
