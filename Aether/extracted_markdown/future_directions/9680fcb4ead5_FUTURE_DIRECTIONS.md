# Future Directions: The Geometry of Consensus

This cycle formalized a self-contained social-choice framework in
`Catalog/Bridges/SocialChoiceConsensus.lean` centered on the **consensus
(unanimity / Pareto) relation** `a ≻ b ⇔ every voter strictly prefers a to b`.
We proved that this rule is a strict partial order (`unanimity_irrefl`,
`unanimity_trans`), is Pareto efficient (`unanimity_pareto`), satisfies
independence of irrelevant alternatives (`unanimity_IIA`), and is
non-dictatorial (`unanimity_nondictatorial`) — yet **fails completeness**
(`unanimity_incomplete`). The accompanying `consensus_antitone` shows consensus
is order-theoretically *contractive*: enlarging the electorate can only shrink
the agreed-upon order. Together these isolate exactly the axiom (completeness)
that Arrow's impossibility theorem forces any Pareto/IIA/non-dictatorial rule to
surrender. Below are five testable, falsifiable directions that extend this work.

## 1. Arrow's theorem as a completeness obstruction

Formalize the full statement: with `≥ 3` alternatives, *any* aggregation rule
`F : Profile ι α → α → α → Prop` that always yields a **complete strict order**
and satisfies Pareto and IIA must have a dictator. The conjecture is that our
`unanimity_incomplete` is not an accident of the unanimity rule but the *generic*
failure mode — every completion of the consensus order reintroduces a dictator.
**The key insight is** that completeness is the unique "load-bearing" axiom: the
consensus relation already satisfies the other three, so Arrow's theorem is
precisely the statement that the partial consensus order has no
Pareto/IIA/anonymous *total extension*. **Why now?** We already have the four
axioms formalized as standalone, machine-checked predicates, so the remaining
work is the contrapositive decisive-coalition (ultrafilter) argument layered on
top of the existing `consensus`/`IsDictator` definitions, rather than a build
from scratch.

## 2. Ultrafilters as the curvature of decisive coalitions

Define `Decisive S` for a coalition `S : Finset ι` (or `Set ι`) by
`∀ prof a b, consensusOn S prof a b → F prof a b`, and conjecture that for a
complete Pareto/IIA rule the family of decisive coalitions forms an
**ultrafilter** on the voter set; on a finite electorate every ultrafilter is
principal, yielding the dictator. **The key insight is** that our
`consensus_antitone` lemma is exactly the *upward-closure* half of the
ultrafilter axioms ("a superset of a decisive set is decisive"), so the
"geometry/curvature" metaphor becomes literal: decisive coalitions are an
order-filter whose principal generator is the dictator. **Why now?** Mathlib
already has a mature `Ultrafilter` API, and our coalition restriction
`consensusOn` plus `consensus_antitone` give the monotonicity hooks needed to
connect to it directly.

## 3. Quantitative escape: bounded incompleteness and the price of consensus

Measure *how incomplete* consensus is by counting unranked pairs:
`gap(prof) = #{(a,b) : a ≠ b ∧ ¬consensus prof a b ∧ ¬consensus prof b a}`.
Conjecture a sharp lower bound `gap(prof) ≥ f(disagreement)` showing that any
nonzero voter disagreement forces a positive, quantifiable gap, with equality
characterizing "single-crossing"/near-unanimous profiles. **The key insight is**
that `unanimity_incomplete` exhibits the minimal nonzero gap (one pair, two
voters), so the general bound is a monotone interpolation between that extremal
profile and full unanimity. **Why now?** The relation is decidable on finite
`α`, so `gap` is a computable `Finset.card` and the bound can be stress-tested by
`decide`/`#eval` over small profiles before attempting the general proof.

## 4. Restricted domains restore completeness (single-peakedness)

Add a `SinglePeaked` predicate on profiles (preferences consistent with a common
linear ordering of alternatives) and conjecture that on the single-peaked domain
the **majority** relation is complete *and* transitive (Black's median-voter
theorem), so the Arrovian obstruction of Direction 1 vanishes. **The key insight
is** that single-peakedness is exactly the geometric hypothesis that flattens the
"curvature" of consensus — it forces the individual orders to lie on a line, so
their majority intersection no longer has incomparable pairs. **Why now?** Our
`Pref` structure already records each voter's order relationally, so a
single-peakedness hypothesis is a clean predicate over `Pref`, and the
median-voter construction reuses the existing `consensusOn`/coalition scaffolding.

## 5. Probabilistic consensus and the metric geometry of agreement

Replace the all-or-nothing consensus with a *fraction-of-voters* threshold
`consensusα t prof a b ⇔ (#{i : (prof i).lt a b}) / |ι| ≥ t` and study the order
type as `t` varies in `[1/2, 1]`. Conjecture a phase transition: there is a
critical `t* ` above which the relation is always acyclic (a strict partial
order) and below which Condorcet cycles can appear. **The key insight is** that
`consensus` is the `t = 1` endpoint and simple majority is `t = 1/2`, so the
acyclicity boundary is a one-parameter deformation interpolating between our
proven partial order and the classical Condorcet paradox — literally a curvature
parameter for consensus. **Why now?** With `consensusOn` and `consensus_antitone`
in place, the threshold family is a thin generalization (cardinalities of voter
subsets), and small-`|ι|` cases are again `decide`-checkable, giving immediate
empirical signal on where `t*` lies before a general proof.
