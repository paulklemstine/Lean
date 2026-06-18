# Future Directions: Tropical Compactification of Moduli Spaces

## 1. Tropical Polynomial Root Multiplicity and the Fundamental Theorem

The breakpoint count bound we proved (`TropPoly.breakpoint_count_le`) shows that
a tropical polynomial with n terms and distinct slopes has at most n-1 breakpoints.
The natural next step is to define **tropical root multiplicity** as the change in
slope at each breakpoint and prove the **Fundamental Theorem of Tropical Algebra**:
the sum of all tropical root multiplicities equals the degree of the tropical polynomial.

The key insight is that the multiplicity at a breakpoint x where slopes change from
s_i to s_j is exactly |s_j - s_i|, and the total multiplicity telescopes to
max(slopes) - min(slopes) = degree.

Why now? We have the convexity framework (`TropPoly.eval_convexOn`) and the
breakpoint finiteness result. The multiplicity definition is a straightforward
extension, and the telescoping argument reduces to a finite sum manipulation
that the current infrastructure can support.

## 2. Tropical Matrix Closure and the Floyd-Warshall Correspondence

Our tropical matrix algebra file establishes the semiring-like structure of
min-plus matrices. The critical next result is to define the **Kleene star**
(tropical matrix closure) A* = I ⊕ A ⊕ A² ⊕ ⋯ and prove that for matrices
without negative-weight cycles, A* converges in at most n-1 steps and computes
all-pairs shortest paths.

The key insight is that the tropical matrix power A^k at entry (i,j) gives the
minimum-weight k-hop path from i to j. By the pigeonhole principle, if there are
no negative cycles, any shortest path visits at most n-1 intermediate vertices,
so A^(n-1) already contains all shortest path weights.

Why now? The idempotent semiring structure (`tropAdd_idem`, `tropAdd_assoc`) is
in place. The convergence argument requires only showing that the decreasing
sequence A^k_{ij} stabilizes, which follows from the finiteness of the Fin n
index set combined with the well-ordering of WithTop ℝ.

## 3. Tropical Determinant and Permanent Coincidence via Sign Cancellation

In classical algebra, det(A) involves signs while permanent(A) does not. Over the
tropical semiring, both reduce to the same optimization problem: finding the
minimum-weight perfect matching. Formalizing this **tropical det = perm** identity
and connecting it to the Hungarian algorithm would bridge our matrix algebra with
combinatorial optimization.

The key insight is that in the tropical semiring, addition (= min) is idempotent,
so negative signs cannot cancel — the sign of each permutation term becomes
irrelevant. More precisely, for any permutation σ, the sign (-1)^σ acts trivially
under the tropicalization functor because min(a, a) = a.

Why now? The tropical matrix type and operations are defined. The connection to
permutation groups requires only Mathlib's `Equiv.Perm` and `Finset.univ` over
`Equiv.Perm (Fin n)`, which are mature parts of the library.

## 4. Legendre-Fenchel Duality for Tropical Polynomials

Our result `TropPoly.eval_eq_iSup` shows that tropical polynomial evaluation
equals the supremum of affine functions. This is precisely the **Legendre-Fenchel
transform** of a discrete measure. The conjecture is that the tropical polynomial
can be recovered from its Legendre dual, establishing a bijection between tropical
polynomials and their Newton polygons.

The key insight is that for convex piecewise-linear functions (which tropical
polynomials are), the Legendre-Fenchel transform is an involution. The dual of
max_i(a_i·x + b_i) is the convex hull of the points (a_i, b_i), which is
exactly the Newton polygon. This involution provides a canonical way to read
off the tropical polynomial from its Newton polygon.

Why now? The convexity result (`TropPoly.eval_convexOn`) and the iSup
characterization are proven. Mathlib has `ConvexOn` and support for convex
conjugates via `inner_le_Lnorm_mul_Lnorm` and related results. The remaining
gap is defining the tropical Legendre transform and showing involutivity for
piecewise-linear functions.

## 5. Tropical Compactification via Toric Fans

The original motivation — connecting tropical compactification of moduli spaces
to toric varieties — requires defining **tropical fans** as polyhedral complexes
satisfying the balancing condition. The conjecture is that every tropical curve
of genus g corresponds to a cone in the modular fan Δ_g, and the resulting toric
variety is the Deligne-Mumford compactification M̄_g.

The key insight is that the dual graph of a stable curve (with edge lengths going
to zero) naturally defines a tropical curve, and the combinatorial types of these
dual graphs stratify M̄_g. Each stratum corresponds to a cone in a fan, and the
toric variety of this fan recovers the compactification.

Why now? The foundations we have built — tropical polynomial theory, breakpoint
counting, matrix algebra — provide the computational backbone. The next step
requires defining polyhedral fans and the balancing condition, which are
geometric concepts that can be built from Mathlib's existing affine geometry
and polyhedral combinatorics modules.
