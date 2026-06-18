# Future Directions: Tropical Amoebas, Ronkin Functions, and Maslov Dequantization

The file `Catalog/Tropical/AmoebaRonkin.lean` builds a computation-free core of amoeba
theory: the tropical polynomial (amoeba spine) `trop f (x) = max_i (log|c_i| + ⟨m_i,x⟩)` is
proved convex and piecewise-linear, its dominance (amoeba-complement) regions are proved
convex with constant integer slope (the order map), and the Maslov-deformed Ronkin function
`R_t(x) = t·log Σ_i exp(A_i(x)/t)` is shown to converge to the spine as `t → 0⁺` with the
explicit rate `|R_t − trop f| ≤ t·log N`. This realises the Maslov-dequantization theme of
`TSM.zeroTemperature_limit` (`SemiclassicalLimit.lean`) in the geometric amoeba setting, and
extends the log-sum-exp analysis of `LSEConvexity.lean`. Below are concrete, falsifiable
continuations.

## 1. Strict convexity of the deformed Ronkin function transverse to the recession cone

The theorem `ronkinDeform_convexOn` already proves `R_t` convex via the finite Hölder
inequality `∑_i u_i^a v_i^b ≤ (∑_i u_i)^a (∑_i v_i)^b`. The natural strengthening is
*strictness*: `R_t` should be **strictly convex** in every direction `v` that is not
orthogonal to all the differences `m_i − m_j`, with equality in Hölder forcing all the
ratios `exp(A_i(x)/t)/exp(A_i(y)/t)` to coincide. The key insight is that the Hölder
inequality is an equality exactly when the two summed vectors are proportional, which pins
down the directions of non-strictness to the lineality space `⋂_{i,j} (m_i − m_j)^⊥` — the
recession directions of the amoeba spine. Why now? The convexity proof already isolates the
Hölder step, so its equality case (`Finset.inner_le_weight_mul_Lp` equality conditions in
Mathlib) is the only missing ingredient, turning a qualitative result into a sharp
characterisation of where the Ronkin function fails to curve — precisely the spine itself.

## 2. The Legendre dual of the Ronkin function is the Newton polytope

Define the Legendre transform `R_t^*(p) = sup_x (⟨p,x⟩ − R_t(x))`. The conjecture is that as
`t → 0⁺`, `R_t^*` converges to the (negated) support function of the Newton polytope
`Δ_f = conv{m_i}`, i.e. `dom(trop f ^*) = Δ_f` and the order map of Theorem
`tropPoly_slope_on_dominant` sends each amoeba-complement component to a distinct lattice
vertex `m_k ∈ Δ_f`. The key insight is that the order map is exactly the subgradient of the
convex function `trop f`, so the amoeba complement is in bijection with the faces of `Δ_f`
hit by the Legendre dual. Why now? `LegendreDuality.lean` already provides the conjugation
infrastructure in this catalog, so the bijection "complement components ↔ Newton lattice
points" can be stated and tested on explicit small supports (e.g. `1 + z + w`, the line, with
three complement components and three vertices).

## 3. Quantitative spine separation and the tentacle count

Conjecture: the number of unbounded complement components ("tentacles") of the amoeba equals
the number of indices `k` whose dominance region `dominantRegion c m k` is nonempty and
unbounded, and this count is sandwiched between the number of Newton-polytope vertices and
the total number of lattice points of `Δ_f` (the classical bound of Forsberg–Passare–Tsikh).
The key insight is that nonemptiness of `dominantRegion c m k` is a *finite linear
feasibility* problem (a system `A_i − A_k ≤ 0`), hence decidably checkable, turning a
topological count into a Farkas-lemma certificate. Why now? The convexity already proved
makes each region a polyhedron, so Mathlib's linear-programming/`Convex` API can certify
(non)emptiness, giving a fully formal, falsifiable lower/upper bound on tentacle count.

## 4. Lipschitz and modulus-of-convexity control of the deformation

Conjecture: `R_t` is globally Lipschitz with constant `max_i ‖m_i‖₁` uniformly in `t`, and
the family `{R_t}_{t>0}` is equi-Lipschitz, so the convergence `R_t → trop f` of
`maslov_tendsto` is in fact **locally uniform**, not merely pointwise. The key insight is
that every `A_i` has gradient `m_i`, and a sup/log-sum-exp of functions with gradients in a
fixed bounded set inherits that gradient bound; combined with the pointwise rate
`t·log N`, equi-Lipschitzness upgrades pointwise to uniform-on-compacts convergence by
Arzelà–Ascoli. Why now? The explicit rate `maslov_dequantization_rate` is already in hand;
only a gradient bound is missing, and that is a direct `Finset.sup'`/`abs_sum` estimate.

## 5. Cross-domain bridge: amoeba spine = ground-state phase diagram

Conjecture: identifying the monomial index set with a configuration space `Ω` and `A_i(x)`
with `−H_i(x)` (energy with external field `x`), the amoeba spine `trop f` is exactly the
zero-temperature phase diagram of `SemiclassicalLimit.lean`, and each `dominantRegion c m k`
is a single thermodynamic phase. The key insight is that `maslov_tendsto` here and
`TSM.zeroTemperature_limit` there are the *same theorem* under the dictionary
`t = 1/β`, `R_t = −F(β)`, so amoeba complement components are in bijection with pure phases
and the order map is the magnetization/order parameter. Why now? Both halves are already
formalized in this catalog; a single bridging file could prove the dictionary as a chain of
`rfl`/`simp` identifications and export every amoeba theorem as a statistical-mechanics
theorem and vice versa — a genuine cross-domain unification.
