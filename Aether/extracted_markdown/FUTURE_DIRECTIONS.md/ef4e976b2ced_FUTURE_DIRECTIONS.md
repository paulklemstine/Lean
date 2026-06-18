# Future Directions: Berggren Tree Ising Model

## 1. Full Contraction Proof for Subcritical Cavity Map

The current formalization establishes that the linearized cavity slope d·tanh(β)
is less than 1 below criticality. The natural next step is proving that the
full nonlinear cavity map f_β(m) = tanh(d·artanh(tanh(β)·m)) is a contraction
on [0,1] when d·tanh(β) < 1, so that iterates starting from any m₀ ∈ [0,1]
converge to 0 exponentially fast.

The key insight is that the cavity map is concave on [0,1] for β > 0, so
f_β(m) ≤ f_β'(0)·m = d·tanh(β)·m, giving geometric convergence at rate
d·tanh(β) per step.

Why now? The infrastructure for tanh/artanh is available in Mathlib, and our
file already has the fixed-point and slope results. The missing piece is a
mean-value theorem application for the cavity map, which requires showing
that artanh(tanh(β)·m) is well-defined on [0,1) — a condition ensured by
tanh(β) < 1.

## 2. Supercritical Spontaneous Magnetization via Bifurcation

Above β_c, the cavity map f_β develops a non-zero fixed point m*(β) > 0.
Formalizing this requires proving that f_β is a contraction on [ε, 1-ε] for
some ε > 0, or applying an intermediate value theorem argument: f_β(0) = 0,
f_β'(0) > 1, and f_β(1⁻) < 1, so by continuity there exists m* ∈ (0,1) with
f_β(m*) = m*.

The key insight is that this is a pitchfork bifurcation: the m=0 fixed point
loses stability at β_c and two symmetric fixed points ±m* emerge. This
structure is generic for ferromagnetic models on trees with symmetry.

Why now? Lean's intermediate value theorem (Mathlib's `intermediate_value_Icc`)
combined with our cavity map continuity (composition of tanh, artanh, and
multiplication, all continuous) should make this accessible.

## 3. Correlation Decay with Explicit Bounds

The correlation length ξ(β) = -1/ln(d·tanh(β)) should give exponential
decay of spin-spin correlations: ⟨σᵢσⱼ⟩ ≤ exp(-dist(i,j)/ξ(β)). On the
Berggren tree, dist(i,j) is the graph distance (number of edges on the
unique path). Formalizing this requires the cluster expansion or the cavity
recursion applied to two-point functions.

The key insight is that on a tree, the two-point function factors along the
unique path: ⟨σᵢσⱼ⟩ = ∏_{edges on path} tanh(β), giving
⟨σᵢσⱼ⟩ = tanh(β)^{dist(i,j)}. The correlation length follows as
ξ = -1/ln(tanh(β)), and the factor of d enters through the tree geometry
when considering the susceptibility sum.

Why now? The tree partition function recursion is already established, and
extending it to conditional expectations is a natural next step that stays
within the same algebraic framework.

## 4. Free Energy Per Site via Branching Recursion

The free energy per site f(β) = lim_{n→∞} (1/|V_n|) ln Z_n should be
computable in closed form using the recursion. For a d-ary tree of depth n,
|V_n| = (d^{n+1} - 1)/(d - 1), and the free energy satisfies
f(β) = ln(2cosh(β)) + [d/(d-1)]·ln(e^β + e^{-β}) plus corrections.

The key insight is that the ratio Z_{n+1}/Z_n^d can be tracked exactly through
the recursion, giving a convergent product formula for the free energy. The
non-amenability of the tree (d ≥ 2) means the surface-to-volume ratio is
positive, so boundary effects persist in the thermodynamic limit.

Why now? All the partition function identities needed are already proved in
our file. Computing the limit requires showing that ln(Z_n)/|V_n| converges,
which can be done via monotonicity arguments using the established positivity
results.

## 5. Berggren-Specific Arithmetic Correlations

The most novel direction: do the arithmetic properties of Berggren triples
(the Pythagorean equation a² + b² = c²) create detectable correlations in the
Ising model? Specifically, define an Ising model where the coupling J_{ij}
depends on the hypotenuse ratio c_i/c_j of adjacent triples. Does the
phase transition temperature depend on the growth rate of hypotenuses along
Berggren paths?

The key insight is that hypotenuses grow geometrically along any Berggren
path (the spectral radius of each Berggren matrix is 3+2√2 ≈ 5.83), so
arithmetic-dependent couplings J_{ij} ∝ (c_j/c_i)^α introduce a natural
energy scale that competes with the tree branching. For α > 0, larger
triples deeper in the tree have weaker coupling, potentially shifting β_c.

Why now? The Berggren tree structure (matrices, spectral properties) is
already formalized in the catalog, and our Ising framework handles arbitrary
coupling constants. Connecting these requires computing the spectral radius
of Berggren matrices, which is within reach of the existing linear algebra
infrastructure.
