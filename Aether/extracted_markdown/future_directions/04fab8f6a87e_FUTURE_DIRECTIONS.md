# Future Directions — Close Proofs: ReLU decision boundaries via tropical geometry

## Synthesis

The catalog already contained the *algebraic* half of the Zhang–Naitzat–Lim
correspondence in `MachineLearning.TropicalReLUBridge`: every one-hidden-layer
ReLU network output is a **tropical rational function** `f = p − q` (a difference
of two tropical/max-plus polynomials), and every tropical polynomial is convex.

This cycle adds the **analytic and convex-geometric** half in the new file
`MachineLearning.TropicalReLUBoundary`, which `import`s and builds directly on
the bridge file (reusing `affEval`, `IsTropPoly`, `IsTropRational`, `relu`,
`reluNet`, `decisionBoundary`, and the closure lemmas `IsTropPoly.add`,
`IsTropPoly.relu`, `IsTropPoly.convexOn`, and `reluNet_isTropRational`). The new
results are:

* **Continuity**: `affEval_continuous → IsTropPoly.continuous →
  IsTropRational.continuous`. The whole tropical-rational class is continuous.
* **Closed decision boundaries**: `IsTropRational.isClosed_decisionBoundary` —
  for *any* ReLU classifier the locus `{x | f x = 0}` is topologically closed,
  because it is `f ⁻¹' {0}` for a continuous `f`.
* **DC structure**: `IsTropRational.differenceOfConvex` and its specialization
  `reluNet_differenceOfConvex` show every ReLU network is a *difference of
  convex functions*, the exact object class of DC programming.
* **Vector-space closure**: `IsTropRational.neg`, `IsTropRational.add` show the
  DC/tropical-rational class is closed under negation and addition.
* **Adversarial frontier**: `exists_tropRational_not_convexOn` exhibits the
  explicit ReLU rational map `x ↦ −ReLU(x)` that is tropical rational but *not*
  convex, pinning down exactly where the base file's convexity theorem stops:
  convexity survives the polynomial level but is destroyed at the rational
  (network) level, while continuity and boundary-closedness survive.

## Results summary

| Theorem | Statement |
|---|---|
| `affEval_continuous` | affine functionals are continuous |
| `IsTropPoly.continuous` | tropical polynomials are continuous |
| `IsTropRational.continuous` | ReLU-network functions are continuous |
| `IsTropRational.isClosed_decisionBoundary` | ReLU decision boundaries are closed |
| `IsTropRational.neg`, `IsTropRational.add` | DC class is a sub-vector-space |
| `IsTropRational.differenceOfConvex`, `reluNet_differenceOfConvex` | ReLU = difference of convex |
| `exists_tropRational_not_convexOn` | convexity is lost at the rational level |

All main results compile with `sorry = 0` and depend only on
`propext`, `Classical.choice`, `Quot.sound`.

## Falsifiable research directions

### 1. The decision boundary has Lebesgue measure zero (it is a tropical hypersurface)

We proved the decision boundary `{x | f x = 0}` of a ReLU classifier is closed.
The natural strengthening is that, for a *generic* tropical-rational `f` (one
whose two polynomial parts are not identically equal on any open set), the
boundary has **Lebesgue measure zero** in `ℝ^d`. **The key insight is** that
`p − q` is piecewise-affine with finitely many linear pieces, so its zero set is
a finite union of affine slices, each of which is either everything (excluded by
genericity) or a measure-zero hyperplane patch. **Why now?** We already have
continuity and the explicit finite max-affine `Finset` witnesses from
`IsTropPoly`; combining them with Mathlib's `MeasureTheory` API for affine
subspaces makes this immediately attackable, and it is falsified by any single
`f` whose boundary contains an open ball.

### 2. Counting linear regions: a depth/width lower bound bridging to `ReLUDepthWidth`

Define the number of distinct affine pieces (the cardinality of the
`Finset` witness, minimized over witnesses) of a tropical polynomial, and prove
it is **sub-multiplicative under `IsTropPoly.add` and stable under
`IsTropPoly.relu`**, yielding an explicit upper bound `≤ ∏ (widths)` on the
number of linear regions of a depth-`L` ReLU network. **The key insight is** that
`IsTropPoly.add` indexes pieces by the *product* family `S ×ˢ T`, so region
count is controlled by products of layer widths — the tropical incarnation of the
Montúfar–Telgarsky region-counting bound. **Why now?** The product-family
construction is already proved (`sup'_add_sup'`), and the catalog's
`ReLUDepthWidth.Basic` supplies the matching depth-separation lower bound, so the
two files can be fused into a single quantitative depth-vs-width statement.

### 3. ReLU networks are globally Lipschitz with an explicit tropical constant

Conjecture: a tropical polynomial with affine family `S` is
`(max over S of ‖a‖)`-Lipschitz, hence every `reluNet` is Lipschitz with constant
bounded by a sum over hidden units of `|c i| · ‖A i‖`. **The key insight is** that
a finite `sup'` of `K`-Lipschitz functions is `K`-Lipschitz (the sup of equi-
Lipschitz maps), and affine `affEval (a,b)` is exactly `‖a‖`-Lipschitz. **Why
now?** The catalog's `Bridges.NeuralCompositionBridge` already packages
`lipschitz_max`, `lipschitz_add`, `lipschitz_sub`, `lipschitz_comp`; feeding the
tropical `Finset` witnesses into those lemmas gives a *certified* robustness
radius directly from the tropical representation — falsified by exhibiting any
witness family whose claimed constant is violated.

### 4. Tropical-rational = continuous piecewise-linear (a representation completeness theorem)

The bridge shows ReLU networks ⊆ tropical rational ⊆ continuous PL. Conjecture
the reverse inclusion: **every continuous piecewise-linear `f : ℝ^d → ℝ` with
finitely many polyhedral pieces is tropical rational**, i.e. `IsTropRational`
*characterizes* the CPWL class. **The key insight is** the classical fact that any
CPWL function is a finite combination of `max`/`min` of affine maps, and `min`
is `−max(−·)`, which our `IsTropRational.neg`/`IsTropRational.add` closure lemmas
already make expressible inside the class. **Why now?** With `neg` and `add`
closure proved this cycle, only a `min`/lattice-closure lemma and an induction on
the polyhedral decomposition remain — a self-contained, falsifiable target
(falsified by any CPWL `f` provably not of the form `p − q`).

### 5. DC decomposition is non-unique but the boundary is an invariant

Building on `differenceOfConvex`, conjecture that while the convex parts `(p,q)`
are highly non-unique (one may add any common convex `r`), the **decision
boundary `{p = q}` is an invariant** of the underlying classifier, and moreover
equals the non-differentiability locus of `max(p,q)` union the sign-change locus.
**The key insight is** that `decisionBoundary_eq_locus` already identifies the
boundary with `{p = q}` independently of the chosen `(p,q)`, and on that set
`max(p,q)` is attained by pieces of both parts simultaneously
(`decisionBoundary_on_tropHypersurface`). **Why now?** Both supporting lemmas
exist in the base file; formalizing the invariance turns the qualitative DC
picture into a rigorous statement that adversarial perturbations of the network
weights move the convex parts but not the (closed) boundary — directly testable
by perturbing a concrete `reluNet`.
