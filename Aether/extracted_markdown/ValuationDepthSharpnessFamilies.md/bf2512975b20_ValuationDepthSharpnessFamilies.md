# Valuation-Depth → Tropical Functor: Sharpness Families and Structural Recurrence

This note summarizes `Speculative/AutoResearch/ValuationDepthSharpnessFamilies.lean`,
which advances the valuation-depth → tropical-functor program by turning the verified
upper bound into a usable, falsifiable structural theory.

## Base upper bound used

The development is built directly on top of
`Bridges/ValuationDepthTropicalFunctor.lean`:

```
depth_eval_add_le :
  ∀ (X : DepthCarrier) (t : OpTree X.K),
    X.depth (t.eval X.add) ≤ OpTree.maxLeafDepth X.depth t + t.height
```

i.e. `depth (eval t) ≤ maxLeafDepth t + height t`, where `OpTree` is the type of finite
binary operation trees, `height`/`maxLeafDepth` are the structural measures, and a
`DepthCarrier` is any carrier whose binary operation obeys the unit-cost ultrametric law
`depth (add x y) ≤ max (depth x) (depth y) + 1`. The canonical sharp carrier is
`witnessCarrier = (ℕ, x ⊕ y = max x y + 1, id)`.

(The foundation file was reconstructed from its usage, since the program's two dependent
files imported it but it was absent from the project; with it restored,
`ValuationDepthFollowups.lean` compiles again.)

## Explicit term families

* `balanced k n` — perfect binary tree, `2^n` leaves, height `n` (reused).
* `caterpillar k n` — left chain, `n + 1` leaves, height `n` (reused).
* `gapFamily n := node (caterpillar 0 n) (leaf n)` — a **new** non-uniform mixed family.

## Structural recurrence lemmas (reusable estimator)

* `depth_eval_witness_leaf`, `depth_eval_witness_node` — the evaluated depth satisfies the
  max-plus recurrence `depth(node l r) = max (depth l) (depth r) + 1` on the unit-cost carrier.
* `maxLeafDepth_uniform`, `eval_witness_uniform` — closed forms for uniform trees.

## Exact / sharp results

* **Master sharpness** `sharpness_uniform`: for *every* tree all of whose leaves carry a
  single value `c` (predicate `OpTree.Uniform`), the upper bound is attained with equality
  on the unit-cost carrier:
  `depth (eval t) = maxLeafDepth t + height t`.
* **Two-sided sandwich** `depth_eval_witness_sandwich`: for *every* tree,
  `max (maxLeafDepth t) (height t) ≤ depth (eval t) ≤ maxLeafDepth t + height t`.
  The lower bound (`height_le_depth_eval_witness`, `maxLeafDepth_le_depth_eval_witness`) is new.
* **Families witness sharpness** `depth_eval_balanced_exact`, `depth_eval_caterpillar_exact`:
  both families are uniform (`balanced_uniform`, `caterpillar_uniform`), so
  `depth (eval (balanced b n)) = depth (eval (caterpillar b n)) = b + n = maxLeafDepth + height`.
  These give exact closed forms and witness sharpness of `depth_eval_add_le`.

## Falsifiability: the gap family

* `gapFamily_slack`: on `gapFamily n` the estimator over-estimates by **exactly** `n`,
  `depth (eval) + n = maxLeafDepth + height` (evaluated depth `n + 1`, estimator `2n + 1`).
* `gapFamily_strict`: hence for `n ≥ 1` the bound is strict.

So uniformity is essentially necessary for sharpness, and the slack can be arbitrarily
large — a concrete, proved counterexample rather than broken scaffolding.

## Packaging principle

* `estimator_certified_and_exact`: the structural quantity `maxLeafDepth + height` is
  (1) a certified upper bound on evaluated valuation depth for every carrier and every tree,
  and (2) exact on every uniform tree over the unit-cost carrier — a computable
  shape → valuation-depth prediction principle.

## Relation to the broader program

These results upgrade the one-directional bound `depth (eval t) ≤ maxLeafDepth + height`
into a precise characterization of equality (uniform shapes) plus quantitative slack
control (the gap family), giving the tropical-functor direction a falsifiable estimator:
tree shape certifies, and on uniform shapes exactly predicts, the valuation depth of the
evaluated value. All proofs are by structural induction on `OpTree`; no new semantic
frameworks, cross-domain analogies, or placeholders are introduced. Every theorem is
`sorry`-free and depends only on the standard axioms.
