# Future Directions — Valuation-Depth → Tropical Functor

Derived from the verified results in
`Catalog/Bridges/ValuationDepthTropicalFunctor.lean` (foundations) and
`Catalog/Bridges/ValuationDepthFollowups.lean` (conjectures C1–C5).

This cycle proved, with 0 sorries:

* **C2** is fully settled: `lipschitz_constant_iff` and `unit_is_least_lipschitz_constant`
  show the constant `c` works for *every* depth carrier iff `1 ≤ c`, so the bridge's
  Lipschitz constant is intrinsically `1` (refuted at `c = 0` by
  `not_strict_ultrametric_witness`).
* **C1** is settled in sharp form: `balanced_meets_log_bound` (balanced reassociation meets
  `maxLeafDepth + ⌈log₂ numLeaves⌉`), `unbalanced_exceeds_log_bound` (an explicit caterpillar
  violates the naive bound), and `reassociation_exponential_gap` (same `2^n` leaf count gives
  balanced depth `n` vs. unbalanced depth `2^n - 1`).
* **C4/C5** are settled: `comp_eval_depth_le` extends the tree bound to composition,
  `comp_balanced_depth_eq` gives exact `d + n` depth for balanced composition of `2^n`
  depth-`d` maps, and `hensel_depth_eq_height_and_precision` gives depth `= k`,
  precision `= 2^k`.
* **C3** has its computational core: `depth_eval_add_le_strict` shows strict (idempotent)
  carriers incur *zero* height overhead.

The five conjectures below are the bold, falsifiable next steps.

---

## D1. Strictification is a genuine reflection (left adjoint), constructively

**Conjecture.** The inclusion of strict depth carriers (`IsStrict`) into all depth carriers
has a left adjoint `Strictify`, given concretely by saturating the depth under combination:
`depthₛ x := ⨅ {n | x is reachable by ≤ n combinations from depth-0 atoms}`. The unit
`η : X → Strictify X` is 1-Lipschitz and initial among maps to strict carriers.

**The key insight is** that `depth_eval_add_le_strict` already proves the *defining inequality*
of a strict object (no height overhead); a strictification therefore only has to quotient the
`+1` slack, which is a free/forgetful adjunction over the unit-cost monoid `(ℕ, max, +1)`.

**Why now?** We have proved both endpoints — the lax law with unit cost and the strict law with
zero cost — so the adjunction is the unique arrow between two already-formalized regimes; the
construction reduces to a fixpoint we can already evaluate on `balanced`/`caterpillar` trees.

**Falsifiable by:** exhibiting a depth carrier whose slack cannot be saturated to a strict
carrier with a 1-Lipschitz universal unit (i.e. a carrier where every strict quotient loses a
distinguishing combination).

---

## D2. Height is the *exact* depth for constant-leaf trees in any extremal carrier

**Conjecture.** For the unit-cost operation, every tree all of whose leaves equal `b`
evaluates to depth exactly `b + height t` (not merely `≤`). Consequently, among all binary
trees on a fixed multiset of `m` equal leaves, the evaluated depth is minimized *exactly* by
the minimum-height (balanced) tree, with value `b + ⌈log₂ m⌉`, and maximized by the
caterpillar, with value `b + (m - 1)`.

**The key insight is** that under `unitCostAdd = max · + 1` the value contribution and the
structural contribution decouple: `eval (node l r) = max (eval l) (eval r) + 1` collapses to
`b + max(height l)(height r) + 1` once leaves are constant, so depth = leaf value + height
*identically*.

**Why now?** `eval_balanced_unitCost` and `eval_caterpillar_unitCost` already prove the two
extremal instances of this identity; the general statement is one induction over `OpTree`
on a constant-leaf predicate away.

---

## D3. The functor is monoidal: depth of a product tree adds the multiplicative grade

**Conjecture.** Extend `DepthCarrier` with a multiplication `mul` satisfying
`depth (mul x y) = depth x + depth y` (the tropical `mul = +`). Then `depthTropMap` is a *lax
monoidal* functor into `(ℕ, max, +)`: it is unit-cost-lax for `add`/`max` and *strict* for
`mul`/`+`, and the combination-tree bound upgrades to a bound over mixed (+,×) trees where the
height cost counts only the `add`-nodes.

**The key insight is** that `tropicalization_base` already carries both `max` and `+`, so the
target is genuinely a semiring; the unit cost lives entirely on the additive side, making the
multiplicative side a strict (cost-free) monoidal structure.

**Why now?** The additive half is done (`depthTropMap_lax`); the multiplicative half is a
*strict* equality, the easiest kind of functoriality, so the monoidal upgrade is within reach
and would promote the bridge from a map to a genuine ⊗-functor.

---

## D4. A matching lower bound: the height overhead is unavoidable, not just attainable

**Conjecture.** For every `n` there is *no* depth carrier and tree with `2^n` leaves of equal
depth whose evaluated depth is below `maxLeafDepth + ⌈log₂(numLeaves)⌉ = maxLeafDepth + n`,
provided the carrier's `add` is associative and commutative on depth values. Equivalently, the
`balanced_meets_log_bound` inequality is *tight from below* across the whole associative class.

**The key insight is** that associativity forces a pigeonhole on combination order: with `2^n`
distinct unit-cost atoms, some atom must pass through at least `n` combinations, so its depth
contribution accrues `n` units regardless of reassociation.

**Why now?** We have proved the upper bound and the per-carrier sharpness
(`depth_balanced_overhead_tight`); the only missing piece is the cross-carrier lower bound,
turning a sharp example into a universal optimality theorem.

---

## D5. Hensel/Newton trees are characterized by depth = height among quadratic methods

**Conjecture.** Among iteration carriers with order-`q` convergence (`precision ↦ q · precision`
per step), the balanced doubling tree is the unique image under `depthTropFunctor` whose depth
equals its height for *every* `k`; higher-order methods (`q > 2`) compress height by
`⌈log_q 2⌉` but never below `1`, so quadratic Newton is the minimal-height-per-precision method
realizable by a strict balanced tree.

**The key insight is** that `hensel_depth_eq_height_and_precision` identifies precision `2^k`
with height `k`; replacing `2` by `q` replaces the base of the tree, so the depth↔precision
dictionary is exactly a change of logarithm base, pinning quadratic convergence as the `q = 2`
fixed point of the functor.

**Why now?** The `q = 2` case is fully proved and the `CompCarrier`/`doublingComp` machinery
generalizes verbatim to a `q`-ary branching tree, so the higher-order comparison is a direct
parametric extension of an existing theorem.
