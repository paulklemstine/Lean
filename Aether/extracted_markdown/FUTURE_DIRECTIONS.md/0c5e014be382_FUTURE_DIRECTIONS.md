# Future Directions — Tropical Lipschitz Bounds for Arithmetic Height

## Synthesis

The file `Catalog/Bridges/TropicalArithmeticHeightBounds.lean` establishes a
quantitative bridge between two measures that previously lived in separate
corners of the catalog: the **arithmetic height** `ratArithHeight q = |q.num| + q.den`
on `ℚ` (from `Catalog/Bridges/ArithmeticVCDimension.lean`) and the
**valuation-depth / tropical cost** philosophy of `+1`-per-operation control
laws (from `Catalog/Computation/PadicValuationDepth.lean`, e.g. `vdepth_sum_le`,
`vdepth_prod_le`).

The central structural discovery is uniformity: arithmetic height is bounded by
the **product** of heights under *both* `+` and `*`
(`ratArithHeight_add_le`, `ratArithHeight_mul_le`), and is *exactly invariant*
under negation and inversion (`ratArithHeight_neg`, `ratArithHeight_inv`, the
latter even at `0`). Taking base-2 logarithms (`logHeight`) linearizes the
product law into the additive max-plus law `+1`-per-gate
(`logHeight_mul_le`, `logHeight_add_le`), which is *literally* the control law
of `vdepth`. This yields the two main bridge theorems:

* `height_eval_le_cost`: arithmetic height of an evaluated rational expression
  is bounded by a computable multiplicative cost.
* `logHeight_eval_le_tcost`: evaluation is **nonexpanding (Lipschitz)** from the
  tropical valuation-depth cost `tcost` into the arithmetic log-height — the
  "values" analogue of the "computations" depth bounds in `PadicValuationDepth`.

## Results Summary

Proven with zero `sorry` and only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`):

1. `ratArithHeight_inv` — inversion is a height isometry on all of `ℚ` (no
   nonzero hypothesis).
2. `ratArithHeight_mul_le` — `H(ab) ≤ H(a)·H(b)`.
3. `ratArithHeight_add_le` — `H(a+b) ≤ H(a)·H(b)` (cross terms absorbed).
4. `logHeight_mul_le`, `logHeight_add_le` — tropical `+1`-per-gate laws.
5. `height_eval_le_cost`, `logHeight_eval_le_tcost` — the two bridge theorems.
6. Corollaries `height_certificate`, `height_add_compose_le`,
   `height_mul_compose_le` — computable certificate and compositionality.

---

## Direction 1 — Sharpness via a tropical lower bound

Conjecture: there is a matching family of expressions for which the bound
`logHeight (eval e) ≤ tcost e` is tight up to an additive `O(depth e)` slack —
i.e. the tropical cost is not merely an upper bound but the correct asymptotic
order. Concretely: for the "balanced product tree" `e_n` of `2^n` distinct
prime-reciprocal leaves, `logHeight (eval e_n) ≥ tcost e_n - c·n` for an
explicit constant `c`.

The key insight is that the additive cross terms `|num|·den` which we *discard*
in `ratArithHeight_add_le` are exactly zero (in log scale) for coprime
denominators, so multiplicative growth becomes exactly additive in log-height —
making the upper bound provably tight on coprime towers. Why now? The upper
bound `logHeight_mul_le` is already formalized; the matching lower bound only
needs `Nat.log` monotonicity plus a coprimality invariant on denominators, both
of which are elementary and present in Mathlib. This converts a one-sided
inequality into a genuine `Θ`-law, the first quantitatively tight statement in
this bridge.

## Direction 2 — From `ratArithHeight` to a genuine `ValuationDepthMeasure` instance

Conjecture: the assignment `f ↦ tcost` of a canonical straight-line program
computing `f` endows the function space `ℚ → ℚ` (restricted to rational
expressions) with a lawful `ValuationDepthMeasure ℚ ℚ` instance, i.e. it
satisfies `vdepth_zero`, `vdepth_add`, and `vdepth_mul` from
`Catalog/Computation/PadicValuationDepth.lean`.

The key insight is that `tcost` already obeys `tcost (add a b) = tcost a + tcost b + 1`
which dominates the required `max (tcost a) (tcost b) + 1`, so the max-plus
typeclass laws follow *for free* from the additive ones (since `max x y ≤ x + y`).
Why now? The `ValuationDepthMeasure` class and its consumers
(`ValDepthBounded`, `ValDepthClassSet`, `iUnion_eq_univ`) are already built and
proven in the catalog; supplying one new lawful instance immediately exports all
of that downstream theory (closure under `+`/`*`, the exhausting union) to
arithmetic-height-controlled rational computation, with no new heavy machinery.

## Direction 3 — Northcott-style finiteness of bounded-tcost outputs

Conjecture: for every depth/cost bound `B`, the set
`{ eval e | tcost e ≤ B }` of rationals reachable by tropical-cost-`≤ B`
expressions is **finite**, with an explicit cardinality bound of the form
`(2^(2^B+1)+1)^{?}`.

The key insight is that `logHeight (eval e) ≤ tcost e ≤ B` forces
`ratArithHeight (eval e) ≤ 2^(B+1)`, and only finitely many rationals have
bounded height (a Northcott-type finiteness, the rational shadow of
`finite_coordinateBounded_quantum_certified` in `ArithmeticVCDimension.lean`).
Why now? The catalog already proves height-bounded finiteness for coordinate
functions and ties it to VC/pseudo-dimension; routing our `logHeight_eval_le_tcost`
into that finiteness pipeline yields a *computational-complexity* input
(bounded tropical depth) to a *learning-theoretic* output (finite codebook,
bounded pseudo-dimension), completing a three-domain bridge
arithmetic ⇄ tropical ⇄ statistical-learning.

## Direction 4 — Ultrametric realization through `CategoricalTropicalUltrametric`

Conjecture: `logHeight` factors through an `UltraNormObj` (from
`Catalog/Bridges/CategoricalTropicalUltrametric.lean`) so that expression
evaluation becomes an honest `UltraBoundedMap`/`UltraLipschitzData` with explicit
Lipschitz constant `1` per gate, and the multiplicative `cost` realizes a
`TropBoundedMap` on the tropicalized object.

The key insight is that the `+1`-per-gate law is precisely the
non-expansiveness condition of the ultrametric morphisms already axiomatized in
that file, so `logHeight_mul_le`/`logHeight_add_le` are the hypotheses an
`UltraHom` needs — the categorical interface was *designed* for exactly this
shape of inequality. Why now? `TropObj`, `UltraNormObj`, `UltraHom`, and the
reconstruction functor `valuationReconstruct` are fully proven; packaging our
concrete height bounds as a morphism in that category turns a bag of
inequalities into a single structural statement (a functor from the syntax
category of `RatExpr` to the ultrametric category) that downstream functorial
lemmas can consume.

## Direction 5 — Multivariate expressions and a height-Lipschitz substitution calculus

Conjecture: extending `RatExpr` with finitely many variables `x_1,…,x_k` and a
substitution operator, the bound becomes
`logHeight (eval (subst σ e)) ≤ tcost e + Σ_i (occ_i e)·logHeight (σ x_i)`,
a fully compositional Lipschitz law under substitution.

The key insight is that substitution distributes over the gate structure, so the
per-gate `+1` accounting telescopes and each variable contributes its own
log-height weighted by occurrence count — substitution is *affine* in
log-height, not just bounded. Why now? The single-substitution corollaries
`height_add_compose_le`/`height_mul_compose_le` already isolate the base case;
generalizing to a variable context only requires an occurrence-count recursion
on `RatExpr`, and it upgrades the bridge from closed values to an entire
height-Lipschitz calculus suitable for analyzing arithmetic circuits with
shared inputs.
