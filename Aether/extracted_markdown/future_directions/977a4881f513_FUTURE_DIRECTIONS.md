# Future Directions: Ordinal Rank as a Functor on GL Frames

This cycle's Lean artifact is `Catalog/Logic/GLRankCategory.lean`, which builds directly
on the Kripke-semantic core of Gödel–Löb provability logic in
`Catalog/Logic/GLKripke.lean`, `Catalog/Logic/PolymodalGL.lean`, and
`Catalog/Logic/GLRankStratification.lean`.

## Synthesis

The guiding hypothesis of this cycle was that the **ordinal rank** of a GL frame
(`GLFrame.rank`, defined in `PolymodalGL.lean` from converse well-foundedness) is not
merely an invariant of a single frame but behaves *functorially*: the order-theoretic
operations one performs on GL frames — modal duality, categorical products, and the
polymodal nesting of accessibility relations — should each collapse to an elementary
operation on ordinals. The cycle confirms this across three independent constructions
and isolates the abstract engine that powers them.

The structural insight that emerged is that **everything reduces to one general
set-theoretic fact about well-founded rank**: rank is monotone under shrinking the
relation (`IsWellFounded.rank_mono_of_subrel`) and, more generally, decreases along any
relation homomorphism (`IsWellFounded.rank_le_of_relHom`). From the homomorphism lemma
alone, the `≤` half of the product-rank theorem falls out by feeding it the two
coordinate projections, and the polymodal antitonicity theorem falls out by feeding it
the nesting inclusion `R (m) ⊆ R (n)`. Only the `≥` half of the product theorem needs a
genuinely frame-specific argument — a well-founded induction that extracts a synchronized
successor in each coordinate — and even there the engine reappears as the inductive
hypothesis. The modal-duality result (`◇^k univ = {rank ≥ k}`) is the exact set-complement
of the previously-proved Löb stratification `□^k ∅ = {rank < k}`, so consistency strength
and inconsistency depth are two sides of a single ordinal cut.

What failed instructively: the *monolithic* attempt to prove `prod_rank_eq_min` directly
by one well-founded induction stalled, because matching `⨆ succ` over product predecessors
against `min` of two component suprema forces the ordinal distributive law
`min (⨆ f) (⨆ g) = ⨆ min(f, g)`, which is painful over `Ordinal` (not a complete lattice).
Splitting into two inequalities sidestepped the distributive law entirely: the `≥`
direction instead uses `le_of_forall_lt` plus independent successor extraction in each
coordinate, which never needs to commute `min` past a supremum. This decomposition is the
reusable lesson — *prefer `le_of_forall_lt` + coordinatewise extraction over sup/min
distributivity when reasoning about ranks of product orders.*

## Results Summary

- `IsWellFounded.rank_mono_of_subrel`: proved — shrinking a well-founded relation can only
  lower ordinal ranks; the abstract backbone of the cycle.
- `IsWellFounded.rank_le_of_relHom`: proved — rank decreases along any relation
  homomorphism into another well-founded relation; generalizes the previous lemma to maps
  between different carriers.
- `GLFrame.diamondSet_iterate_univ_eq_compl_box`: proved — `◇^k univ = (□^k ∅)ᶜ`, modal
  duality lifted through iteration.
- `GLFrame.diamondSet_iterate_univ_eq_rank_ge`: proved — the diamond stratification
  `◇^k univ = {w | k ≤ rank w}`, the set-complement of the Löb stratification.
- `GLFrame.prod_rank_le` / `GLFrame.prod_rank_ge`: proved — the two halves of the product
  rank theorem.
- `GLFrame.prod_rank_eq_min`: proved — the rank of a synchronized categorical product is
  the pointwise minimum of coordinate ranks; rank turns categorical product into ordinal
  meet.
- `GLPFrame.rank_anti_in_level`: proved — polymodal rank is antitone in the modality index,
  the rank shadow of the GLP monotonicity axiom `[n]φ → [n+1]φ`.

## Research Directions

### Direction 1: Sequential composition gives ordinal addition
**Hypothesis**: Define the *sequential composition* `F ▷ G` of GL frames on the disjoint
union `F.World ⊕ G.World`, where the accessibility relation keeps the internal relations of
`F` and `G` and additionally makes every `F`-world see every `G`-world (and never the
reverse). Then `(F ▷ G).rank (inl a) = G.rank_sup + F.rank a` and
`(F ▷ G).rank (inr b) = G.rank b`, where `G.rank_sup = ⨆_b succ (G.rank b)` is the height
of `G`. In particular the maximal `F`-world has rank `G.rank_sup + (F's height − 1)`:
sequential composition realizes **ordinal addition**, the exact counterpart of the
product's ordinal **minimum**.
**Test**: Formalize `F ▷ G` as a `GLFrame` (transitivity needs the one-way cross edges to
compose correctly) and prove the two rank identities by well-founded induction, reusing
`IsWellFounded.rank_le_of_relHom` for the `inr` part. Disproof would be an explicit small
frame where the maximal-world rank is not `G.rank_sup + F.rank a`.
**Why now**: This cycle established that product = min via a clean two-inequality template;
the same template (`le_of_forall_lt` + successor extraction) transfers verbatim, and the
cross edges only add one more successor source per `F`-world.
The key insight is that the three basic monoidal operations on GL frames (product,
coproduct, sequential composition) should be exactly the three ordinal operations
(min, max, addition), making `rank` a homomorphism of ordered monoids.
**If true**: GL frames under these operations become a faithful diagrammatic calculus for
ordinal arithmetic below `ε₀`, and consistency-strength bookkeeping becomes literal ordinal
algebra.
**If false**: the place where additivity breaks pinpoints exactly how much non-locality
(cross edges) the rank invariant can absorb before it stops being compositional.

### Direction 2: Bounded morphisms preserve rank exactly
**Hypothesis**: If `f : F → G` is a surjective *bounded morphism* (p-morphism: `f` preserves
`R`, and whenever `G.R (f a) c` there is `b` with `F.R a b` and `f b = c`), then
`F.rank a = G.rank (f a)` for all `a` — not merely `≤`.
**Test**: Add the back-condition to the hypotheses of `IsWellFounded.rank_le_of_relHom` and
prove the reverse inequality by well-founded induction (the back-condition supplies, for
each `G`-successor of `f a`, an `F`-successor of `a` of at least that rank). A counterexample
would be a bounded morphism collapsing two incomparable worlds and changing a rank.
**Why now**: We already have the `≤` direction in full generality (`rank_le_of_relHom`); the
back-and-forth condition is precisely the extra hypothesis that should upgrade `≤` to `=`,
and the inductive skeleton is identical to the one used in `prod_rank_ge`.
The key insight is that rank is a *complete* invariant for the surjective-bounded-morphism
preorder on GL frames: it is monotone for arbitrary homomorphisms and rigid for the
structure-reflecting ones.
**If true**: rank descends to the category of GL frames and bounded morphisms, giving a
genuine functor to ordinals and a clean notion of "rank-equivalent" frames.
**If false**: the minimal failing morphism characterizes which quotients of a GL frame are
rank-distorting, refining the coarse `≤` bound.

### Direction 3: Sharp termination bound for iterated Löb
**Hypothesis**: For every finite GL frame, `F.rank w < (Nat.card F.World : Ordinal)` for all
`w`, and consequently `F.boxSet^[Nat.card F.World] (∅) = Set.univ`: after `card`-many Löb
iterations, falsity becomes universal, and `Nat.card` is essentially tight (a linear chain
of `n` worlds needs exactly `n` iterations).
**Test**: Prove `rank w < card` by strong induction (a strictly descending `R`-chain through
`w` has distinct worlds, so its length is `< card`), then combine with the existing
`GLFrame.boxSet_iterate_eq_rank_lt`. Tightness is witnessed by the chain frame `(Fin n, >)`.
**Why now**: `boxSet_iterate_eq_rank_lt` already equates `□^k ∅` with `{rank < k}`, so the
only missing ingredient is the finite bound `rank < card`; this cycle's diamond dual makes
the complementary statement `◇^card univ = ∅` immediate once the bound is in hand.
The key insight is that the ordinal rank of a finite frame is always a *natural number*
below its cardinality, so the transfinite stratification secretly terminates in finitely
many, explicitly bounded, steps.
**If false**: a frame with `rank ≥ card` would contradict finiteness of descending chains,
so a "failure" here would actually be a bug hunt that hardens the rank infrastructure.

### Direction 4: An ordinal distributive law for `Ordinal` suprema
**Hypothesis**: For families `f : ι → Ordinal`, `g : κ → Ordinal` over small index types,
`min (⨆ i, f i) (⨆ j, g j) = ⨆ p : ι × κ, min (f p.1) (f p.2)` (with the empty-index cases
handled by `⨆ ∅ = 0`). Equivalently, binary `min` distributes over arbitrary small `iSup`
in `Ordinal`.
**Test**: Prove it directly (`≤` is immediate; for `≥` use that `Ordinal` is a conditionally
complete linear order, splitting on which supremum is smaller and using
`Ordinal.lt_iSup_iff`). Then *re-derive* `prod_rank_eq_min` in one well-founded induction
via `rank_eq`, and check the two proofs agree.
**Why now**: The monolithic proof of `prod_rank_eq_min` stalled in this cycle precisely on
this missing lemma; isolating and proving it would both close that gap and add a reusable
ordinal-arithmetic tool absent from the current toolbox.
The key insight is that the obstruction we routed around (min/sup distributivity over a
non-complete lattice) is itself a clean, self-contained, and generally useful theorem.
**If true**: many ⨆-over-`min` manipulations on ranks become one-liners, and the product
theorem gets a second, more conceptual proof.
**If false**: a counterexample (necessarily exploiting non-attained suprema) would sharply
delimit how far frame-theoretic intuition about finite maxima extends to transfinite
suprema.
