# Future Directions — ML Loss Landscape: Critical Points and Saddle Points

## Synthesis

This cycle formalized the analytic core of the *strict saddle property* that
underpins modern non-convex optimization. Rather than wrestle with multivariate
`iteratedFDeriv` Hessians, we encoded the directional Hessian curvature
`⟪v, ∇²f(x₀) v⟫` as the second derivative of the one-dimensional slice
`t ↦ f(x₀ + t·v)`. Against this minimal scaffold we proved, with zero `sorry`
and only the standard axioms (`propext`, `Classical.choice`, `Quot.sound`):

* `not_isLocalMin_of_neg_curvature` — a critical point with one strictly negative
  curvature direction is **not** a local minimum (strict saddle ⇒ saddle);
* `nonneg_curvature_of_isLocalMin` — the second-order necessary condition (the
  Hessian is positive semidefinite along critical directions at a minimum);
* `frequently_descent_of_neg_curvature` — the **escape** statement: strictly lower
  loss exists in every punctured neighborhood along the negative-curvature ray;
* `saddle_origin_not_localMin` — the canonical witness `f(x,y) = x² − y²`.

The load-bearing reduction is `isLocalMin_slice_of_isLocalMin`: local minimality
of the ambient loss descends to every slice, which lets the whole theory rest on
Mathlib's 1D second-derivative test `isLocalMax_of_deriv_deriv_neg`. The escape
theorem deliberately avoids the (only non-strict) local-max route, instead
deriving a contradiction from eventual constancy.

This connects to the catalog's spectral machinery: `SpectralSelfAdjoint.Basic`
(`rayleighQuotient`, `selfAdjointRayleigh`, eigenvalue positivity from
positive-definite quadratic forms) is the operator-theoretic sibling of
`curvature` — the Rayleigh quotient of the Hessian *is* the directional curvature.
A negative Rayleigh quotient is exactly a negative-curvature direction.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `not_isLocalMin_of_neg_curvature` | strict saddle ⇒ not local min | proved |
| `nonneg_curvature_of_isLocalMin` | local min ⇒ PSD curvature | proved |
| `frequently_descent_of_neg_curvature` | descent in every neighborhood | proved |
| `saddle_origin_not_localMin` | `x²−y²` origin is a saddle | proved |

## Research Directions

### 1. Rayleigh-quotient bridge: negative eigenvalue ⇒ negative curvature

State and prove that for a `C²` loss whose Hessian at a critical point is the
self-adjoint operator `H`, the directional curvature equals the Rayleigh quotient:
`curvature f x₀ v = ⟪v, H v⟫ / ‖v‖²` (suitably normalized), so a negative
eigenvalue of `H` yields a `v` with `curvature f x₀ v < 0`, hence — via
`not_isLocalMin_of_neg_curvature` — a saddle. **The key insight is** that the
slice-second-derivative `curvature` we defined is definitionally the Hessian
quadratic form along `v`, so the abstract spectral notion "indefinite Hessian"
collapses onto the concrete analytic notion we already control. *Why now?* The
catalog already contains `SpectralSelfAdjoint.selfAdjointRayleigh` and eigenvalue
positivity lemmas; wiring `curvature` to that quotient is a short, falsifiable
bridge (it fails iff the Hessian–slice identity is mis-stated) that immediately
upgrades all four theorems from "exists a bad direction" to "any negative
eigenvalue suffices."

### 2. Morse genericity: an indefinite quadratic has a saddle, never a minimum

Conjecture: for a symmetric bilinear `B` on `ℝⁿ` that is *not* positive
semidefinite, the unique critical point of `x ↦ ½ B(x,x)` is a strict saddle.
Formalize "almost all critical points are saddles" for the quadratic model by
showing the local-min set is empty unless `B ⪰ 0`. **The key insight is** that
indefiniteness is precisely the existence of `v` with `B(v,v) < 0`, which is our
`curvature < 0` hypothesis — so the Morse statement is a finite-dimensional
specialization, not new analysis. *Why now?* The 2D witness `saddle_origin_not_localMin`
is the `n = 2`, `B = diag(1,−1)` instance; generalizing to arbitrary indefinite
`B` is a clean, testable next step that exercises Mathlib's quadratic-form API.

### 3. Quantitative escape: a strict descent step of size ∝ |curvature|

Strengthen `frequently_descent_of_neg_curvature` from "frequently lower" to a
quantitative bound: there exists `t` with `0 < |t| < ε` and
`f(x₀ + t·v) ≤ f(x₀) − c·t²` for some `c > 0` depending on the curvature, under a
`C²` smoothness/Lipschitz-Hessian hypothesis. **The key insight is** that the
second-order Taylor remainder is `o(t²)`, so for small `t` the strictly negative
quadratic term `½ t² · curvature` dominates and gives an explicit per-step
decrease. *Why now?* This is the missing rung between our qualitative escape and
the SGD-in-polynomial-time claim: a single quantified descent lemma is exactly the
inductive step of escape-time analyses, and it is falsifiable by a concrete
counterexample if the remainder control is wrong.

### 4. Saddles are non-attracting fixed points of gradient flow

Model gradient descent as the discrete map `x ↦ x − η·∇f(x)` (or the flow) and
conjecture that a strict saddle is a *non-attracting* fixed point: its basin of
attraction has empty interior. **The key insight is** that the negative-curvature
eigendirection is an unstable manifold of the linearized dynamics, so the
Jacobian `I − η·H` has spectral radius `> 1` along `v`; instability of the linear
map forces escape. *Why now?* We already possess the negative-curvature witness
and the catalog's spectral toolkit; phrasing instability via the eigenvalue of
`I − η·H` turns a dynamical-systems claim into a linear-algebra fact we can test
on the `x²−y²` model first.

### 5. Overparameterization ⇒ degenerate-but-benign Hessians

For overparameterized models the Hessian at a global minimum is rank-deficient
(many zero eigenvalues / flat directions). Conjecture: such flat critical points
are *not* strict saddles (no negative curvature) yet also not isolated minima —
the zero set of the loss is a positive-dimensional manifold. **The key insight is**
that `curvature f x₀ v = 0` for `v` in the kernel of the Hessian is the boundary
case our `nonneg_curvature_of_isLocalMin` permits, so overparameterization lives
exactly at the `curvature = 0` frontier between saddle and strict minimum. *Why now?*
Our second-order necessary condition already isolates the `curvature ≥ 0` regime;
characterizing the `curvature = 0` flat directions is the natural, falsifiable
sequel that connects this landscape theory to the empirical "flat minima
generalize" phenomenon.
