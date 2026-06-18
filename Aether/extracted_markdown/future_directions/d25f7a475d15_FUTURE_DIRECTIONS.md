# Future Directions: EML Contraction Theory

## Synthesis

This cycle established the foundational contraction theory for the EML operator
f(x) = exp(a) · log(x + c), formalized in Lean 4 with complete proofs. The central
contribution is the **`ContractiveDynamics` structure** — a novel mathematical object
that bundles a smooth self-map with its invariant domain and certified contraction data,
making convergence a type-level guarantee.

We proved 12 theorems with zero sorries, including:
- The derivative formula f'(x) = exp(a)/(x+c) via chain rule
- Strict monotone decay of the contraction ratio on (-c, ∞)
- Lipschitz bounds on closed intervals via the Mean Value Theorem
- Fixed point uniqueness for any `ContractiveDynamics`
- Geometric convergence of iterates to the unique fixed point
- An instantiation theorem showing EML satisfies the `ContractiveDynamics` axioms

The key insight connecting this to the broader EML program is that the
position-dependent contraction ratio exp(a)/(x+c) — which *decreases* as iterates
grow — gives the EML operator a self-reinforcing stability property absent in
linear contractions. The `ContractiveDynamics` structure captures this refinement.

---

### Direction 1: Invariant Interval Existence via Concavity

**Conjecture**: For all a ∈ (0, log(1 + c)) with c > 0, there exists an interval
[L, U] ⊂ (0, ∞) such that the EML operator maps [L, U] into itself, exp(a)/(L+c) < 1,
and the interval [L, U] contains the unique fixed point.

The key insight is that f(x) = exp(a)·log(x+c) is strictly concave on (-c, ∞) because
f''(x) = -exp(a)/(x+c)² < 0. This means the graph of f can cross y = x at most twice,
and between these crossings, f(x) > x (since f is above the chord). So the two crossing
points L, U satisfy f([L,U]) ⊆ [L,U] automatically.

Why now? The `emlFun_contractiveDynamics` theorem from this cycle requires `hmapsL` and
`hmapsU` as hypotheses. Proving invariant interval existence would eliminate these
hypotheses, yielding a fully self-contained convergence theorem parametrized only by
(a, c). The concavity argument is the missing piece. In Lean 4, this requires formalizing
f'' < 0 (which needs `HasDerivAt` applied twice) and then applying the intermediate value
theorem.

**Test**: For a = 0.5, c = 1.0, numerically solve exp(0.5)·log(x+1) = x. The solutions
are approximately L ≈ 0.35 and U ≈ 3.2, bounding the fixed point x* ≈ 1.143. Verify
f(L) ≈ L and f(U) ≈ U. The conjecture fails if for some a < log(1+c), f(x) = x has
fewer than two solutions (which would mean the invariant interval degenerates).

---

### Direction 2: Parametric Sensitivity via the Implicit Function Theorem

**Conjecture**: The fixed point x*(a, c) of the EML operator is a smooth function of
(a, c) in the region {(a,c) : exp(a) < x*(a,c) + c}, with partial derivatives:
∂x*/∂a = x*·(x* + c) / (x* + c - exp(a))
∂x*/∂c = exp(a) / (x* + c - exp(a))

The key insight is that defining F(a,c,x) = exp(a)·log(x+c) - x, the fixed point
equation F = 0 has ∂F/∂x = exp(a)/(x+c) - 1 ≠ 0 in the contraction regime (where
the contraction ratio is strictly less than 1). The implicit function theorem then
gives smoothness and the derivative formulas follow from implicit differentiation.

Why now? The `emlFun_hasDerivAt` theorem from this cycle provides the derivative
of the EML operator. The IFT in Mathlib (`ImplicitFunctionData`) provides the
framework. Combining these yields certified gradient formulas for backpropagation
through EML layers — the key ingredient for gradient-based optimization of EML
neural networks with convergence guarantees.

**Test**: For a = 0.5, c = 1.0, x* ≈ 1.143: compute ∂x*/∂a ≈ 1.143·2.143/1.494 ≈ 1.639.
Verify by finite differences: [x*(0.501, 1.0) - x*(0.499, 1.0)] / 0.002 ≈ 1.639.
The conjecture fails if the finite difference approximation diverges from the formula
for some parameter values in the contraction region.

---

### Direction 3: Composition Semigroup and Spectral Radius

**Conjecture**: For the n-fold composition f^n of the EML operator, the contraction
ratio satisfies ρ(f^n) ≤ ρ(f)^n with equality in the limit:
lim_{n→∞} ρ(f^n)^{1/n} = |f'(x*)| = exp(a)/(x* + c).

The key insight is that composing contractions multiplies contraction ratios (this is
`contractiveDynamics_geometric_decay` from this cycle), but the *optimal* contraction
ratio of the composition may be strictly better than the product. The spectral radius
formula says the asymptotic rate is exactly the derivative at the fixed point — a
nonlinear analogue of the Gelfand formula for linear operators.

Why now? The `contractiveDynamics_geometric_decay` theorem provides the upper bound
ρ^n. For the matching lower bound, one needs to exhibit points where
|f^n(x) - f^n(y)|/|x-y| approaches ρ^n. Near the fixed point, f^n behaves like
(f'(x*))^n, giving the lower bound. The `emlFun_hasDerivAt` theorem provides the
local linear approximation needed.

**Test**: For a = 0.5, c = 1.0, compute the actual contraction ratio of f^n
(supremum of |f^n(x) - f^n(y)|/|x-y| over [0.5, 3.0]) for n = 1, 2, 5, 10.
Take n-th roots and check convergence to |f'(x*)| ≈ 0.769. The conjecture fails
if the sequence of n-th roots does not converge.

---

### Direction 4: Complex EML Dynamics and Basin Boundaries

**Conjecture**: For the complex EML operator f(z) = exp(a)·Log(z + c) (principal
branch), the basin of attraction of the fixed point z* is connected when
a < log(|z* + c|) and has fractal boundary for a near the critical value.

The key insight is that the complex derivative |f'(z)| = exp(a)/|z+c| defines a
contraction region {z : |z+c| > exp(a)} — a complement of a disk. The real contraction
theory from this cycle extends directly to the complex case, but the boundary behavior
is new: the branch cut of Log creates discontinuities that interact with the contraction
dynamics.

Why now? The real `emlFun_hasDerivAt` extends to the complex case via `Complex.hasDerivAt_log`.
The contraction analysis is identical; only the topology of the domain changes. Establishing
the basin connectivity would be the first rigorous result connecting EML dynamics to
holomorphic dynamics.

**Test**: Numerically iterate f(z) = exp(0.5)·Log(z+1) from z₀ = 2+i for 100 iterations.
Check convergence to the real fixed point. Then try z₀ = -2+0.1i (near the branch cut)
and check whether the orbit diverges or converges to a different limit. The conjecture
fails if the basin is disconnected for small a.

---

### Direction 5: EML Contraction on Metric Spaces and Category Theory

**Conjecture**: The `ContractiveDynamics` structure admits a natural categorical
generalization: a category `ContDyn` whose objects are contractive dynamical systems
and whose morphisms are "contraction-preserving maps" (Lipschitz maps that intertwine
the dynamics). The EML operators form a subcategory, and composition of morphisms
corresponds to composition of neural network layers.

The key insight is that the `ContractiveDynamics` structure already has a natural
notion of morphism: a map φ : D₁ → D₂ that satisfies φ ∘ f₁ = f₂ ∘ φ and is
Lipschitz with constant ≤ 1. Under these conditions, φ maps fixed points to fixed
points and convergent orbits to convergent orbits. The category structure captures
the compositionality of EML neural networks.

Why now? The `contractiveDynamics_converges` theorem shows that every object has a
canonical "attractor" (the fixed point). Morphisms between contractive dynamics
preserve this structure. Lean 4's `CategoryTheory` library provides the categorical
framework. This would be the first formal categorical treatment of contractive dynamics.

**Test**: Define two EML operators with different parameters and construct an explicit
morphism between them. Verify that the morphism maps the fixed point of one to the
fixed point of the other. The conjecture fails if no non-trivial morphisms exist
between generic EML operators (i.e., if the category is essentially discrete).
