# Future Directions: Tropical Moduli Curves

## 1. Tropical Marked Curves and the Full Dimension Formula

The edge bound |E| ≤ 3g − 3 we proved here is for *unmarked* stable tropical curves (no
marked points / leaves).  The natural generalization is the marked case: a stable tropical
curve of genus g with n marked points (modeled as half-edges or degree-1 vertices exempt
from the valence-3 stability condition) should satisfy |E| ≤ 3g − 3 + n, and this bound
is again achieved by trivalent graphs.

The key insight is that each marked point contributes exactly one additional degree of
freedom (its position on the edge it subdivides), and the stability condition becomes
2g(v) − 2 + val(v) > 0 at each vertex, where g(v) is the vertex genus.

**Why now?**  Our `CombType` abstraction already captures degree sequences with the
handshaking constraint.  Extending it with a partition of vertices into "internal" (degree ≥ 3)
and "marked" (degree 1) would require only a mild generalization of the same arithmetic
arguments, using the marked vertex count n in place of the stability lower bound.

## 2. Euler Characteristic and Connected Components

We defined genus as g = |E| − |V| + 1, which is correct only for connected graphs.
For disconnected graphs, the first Betti number is β₁ = |E| − |V| + c, where c is
the number of connected components.  Formalizing the connected-component count c and
proving β₁ ≥ 0 for arbitrary (possibly disconnected) graphs would require either
formalizing spanning forests or an inductive argument on edge deletion.

The key insight is that β₁ = 0 characterizes *forests* (acyclic graphs), generalizing
our genus-0-iff-tree result.  This connects directly to Mathlib's `SimpleGraph.IsAcyclic`
and would provide a bridge between our abstract `CombType` formulation and Mathlib's
graph theory library.

**Why now?**  Mathlib has `SimpleGraph.IsTree.card_edgeFinset` proving |E| + 1 = |V| for
trees, and `SimpleGraph.IsAcyclic` / `SimpleGraph.Connected`.  A formal proof that
connected + |E| = |V| − 1 implies tree (the converse of `card_edgeFinset`) would close
an important gap in the library and serve as the foundation for cycle rank computations.

## 3. Tropical Balancing Condition in ℤ^n

A tropical curve embedded in ℝ^n carries integer slope vectors on each edge.  The
*balancing condition* at each vertex states that the sum of outgoing primitive integer
direction vectors (weighted by edge multiplicities) equals zero in ℤ^n.  Formalizing
this requires defining:
- An embedding: edges → ℤ^n (primitive direction vectors)
- Edge multiplicities: edges → ℕ
- The balancing condition: at each vertex, ∑ w_e · d_e = 0 over incident edges

The key insight is that the balancing condition is what makes a metric graph into a
*tropical subvariety* of ℝ^n, analogous to the Cauchy–Riemann equations making a
smooth map into a holomorphic one.  This is the bridge between combinatorial tropical
curves and tropical algebraic geometry.

**Why now?**  The `CombType` structure already tracks vertex-edge incidence via degrees.
Adding direction vectors and multiplicities is a natural extension, and the balancing
condition is a finite linear algebra statement over ℤ that Lean can verify directly.

## 4. Contraction Morphisms and the Poset of Combinatorial Types

The combinatorial types of stable tropical curves of genus g form a partially ordered
set under *edge contraction*: contracting an edge e of a graph Γ yields a graph Γ/e
with one fewer edge and (unless e is a loop) one fewer vertex.  The genus is preserved
under contraction.

The key insight is that this poset structure directly mirrors the face poset of the
cone complex M_g^trop: contracting an edge corresponds to taking a codimension-1 face
of a cone.  Proving that contraction preserves genus and stability, and that the poset
is graded by the number of edges (= cone dimension), would formalize the combinatorial
structure of the tropical moduli space.

**Why now?**  Our `CombType` abstraction needs to be extended with an explicit edge
contraction operation.  The key lemma — genus is preserved under contraction — is a
simple Euler characteristic argument: contracting a non-loop edge decreases both |E|
and |V| by 1, so g = |E| − |V| + 1 is unchanged.

## 5. Tropical Torelli Map and the Metric Graph Laplacian

The tropical Torelli map sends a tropical curve to its *tropical Jacobian*, defined
via the Laplacian of the metric graph.  For a graph Γ with edge lengths, the
Laplacian L is a |V| × |V| matrix with L_{ij} = −1/ℓ(ij) for adjacent vertices
and L_{ii} = Σ_j 1/ℓ(ij).  The tropical Jacobian is the torus ℝ^g / Im(L^†),
where L^† is a generalized inverse.

The key insight is that the tropical Torelli map is *not* injective for g ≥ 3
(unlike the classical Torelli theorem), and the failure of injectivity is
controlled by the combinatorial type of the graph.  Formalizing the Laplacian
and the rank of the period matrix would make this failure precise.

**Why now?**  The `TropicalCurve` structure already carries edge lengths.  Defining
the graph Laplacian requires Mathlib's matrix API (`Matrix.of`), and computing its
rank is a finite-dimensional linear algebra problem.  The key obstruction is that
Mathlib's matrix theory over ℝ is well-developed, making this tractable.
