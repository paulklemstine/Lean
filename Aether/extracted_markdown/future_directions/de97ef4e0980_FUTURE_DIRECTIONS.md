# Future Directions: Tropical Canonical Forms and Brill-Noether Theory

## 1. Complete the CPL-to-Tropical-Rational Representation Theorem

The theorem `cpl_is_tropical_rational` — that every continuous piecewise-linear function
is representable as a tropical rational function — remains the key open formalization target.
The key insight is that the inductive proof via "slope-change peeling" (subtracting a scaled
ReLU at the maximum breakpoint) reduces the breakpoint set by one at each step, but the
formal verification that the residual function has strictly fewer breakpoints requires a
delicate continuity argument at the peeled breakpoint. The helper infrastructure is now
complete (`tropical_rational_add_relu`, `cpl_affine_between_breakpoints`,
`affine_on_Ioo_of_locally_affine`), so the remaining work is purely about the inductive step.

**Why now?** The helper lemmas `tropical_rational_add_relu` and
`cpl_affine_between_breakpoints` established in this cycle provide exactly the tools needed:
the algebraic operation of adding a ReLU term to a tropical rational, and the analytic
fact that CPL functions are globally affine between breakpoints. The gap is a single
combinatorial argument about breakpoint elimination.

## 2. Minimal Tropical Rational Existence via Well-Founded Descent

The theorem `exists_unique_minimal_tropical_rational` requires showing that among all
tropical rational representations of a CPL function, there exists a canonical minimal one.
The key insight is that "minimality" (no common tropical factor) can be achieved by a
well-founded descent on the total number of terms in numerator and denominator: if a
common factor exists, dividing it out strictly reduces the term count while preserving
the evaluation. Uniqueness then follows from `canonical_tropical_poly_unique` applied
to the cross-multiplication identity.

**Why now?** The `canonical_tropical_poly_unique` theorem is already fully proved, so the
uniqueness half reduces to showing that cross-multiplication of minimal tropical rationals
produces canonical tropical polynomials. The existence half needs `cpl_is_tropical_rational`
plus the descent argument.

## 3. Tropical Brill-Noether Theory: Chip-Firing on Metric Graphs

The original research target — formalizing the tropical Brill-Noether theorem (ρ = g − (r+1)(g−d+r) ≥ 0)
— requires formalizing:
- Metric graphs (tropical curves) as connected graphs with edge lengths
- Divisors on metric graphs (formal sums of points)
- The chip-firing game and its connection to divisor rank
- The Jacobian variety of a tropical curve

The key insight is that the rank of a divisor on a metric graph can be characterized
via chip-firing moves, reducing the Brill-Noether condition to a combinatorial statement
about the existence of winning strategies in a chip-firing game. The formalization would
connect to our tropical polynomial infrastructure via the representation of chip configurations
as piecewise-linear functions on graphs.

**Why now?** The infrastructure for piecewise-linear functions (`IsUnivCPL`, canonical forms,
tropical polynomials) established here provides the analytic foundation. Extending to
functions on graphs rather than ℝ is the natural next step.

## 4. Tropical Convexity and Max-Plus Linear Algebra

A natural extension is formalizing tropical convexity: a set S ⊆ ℝⁿ is tropically convex
if for all x, y ∈ S and λ, μ ∈ ℝ with max(λ, μ) = 0, we have
max(λ + x, μ + y) ∈ S (where operations are componentwise).

The key insight is that tropically convex sets are exactly the "max-plus modules" — this
connects our tropical polynomial theory to the broader max-plus linear algebra framework.
Tropical polytopes (tropically convex hulls of finite point sets) can be described as
images of tropical polynomial maps, linking back to the `TropicalPoly.eval` formalization.

**Why now?** The `TropicalPoly.tmul` operation and its correctness theorem (`tmul_eval`)
already formalize the max-plus product structure in one dimension. The multivariate
generalization would extend `AffinePiece` to `AffinePieceMulti` with slope vectors,
and `TropicalPoly.eval` to a function ℝⁿ → ℝ.

## 5. Neural Network Equivalence Decidability via Tropical Methods

The theorem `relu_network_equiv_iff_canonical` shows that two univariate ReLU networks
compute the same function if and only if they share a canonical tropical rational form.
The key insight is that this immediately yields a DECISION PROCEDURE for univariate
ReLU network equivalence: compute canonical forms and compare. Formalizing the computability
of canonicalization (sorting by slope, removing non-essential terms) would yield a
certified decision procedure — a verified algorithm for neural network equivalence.

**Why now?** The theoretical foundation (`relu_network_equiv_iff_canonical`,
`relu_network_has_canonical_tropical_rational`, `canonical_tropical_poly_unique`) is complete
modulo `exists_unique_minimal_tropical_rational`. Once that gap is closed, the decision
procedure follows by extracting a computable canonicalization function from the existence proof.
