# When Cellular Automata Become Geometry: A New Way to See Computation

## The Simplest Machines That Can Do Anything

In 1983, Stephen Wolfram introduced a classification system for one-dimensional cellular automata — arguably the simplest computational systems imaginable. Picture a row of cells, each either black or white. At each tick of a clock, every cell looks at itself and its two neighbors, then decides whether to become black or white according to a fixed rule. There are exactly 256 such rules.

Wolfram noticed something remarkable. Despite their extreme simplicity, these 256 rules produce four qualitatively different types of behavior. Class 1 rules quickly die to uniform stillness. Class 2 rules settle into repeating patterns, like wallpaper. Class 3 rules generate apparent chaos — pseudorandom noise that never repeats. And Class 4 rules, the rarest and most mysterious, produce complex structures that move, interact, and compute.

The crown jewel is Rule 110. In 2004, Matthew Cook proved that Rule 110 is Turing-complete — it can simulate any computer program, given enough space and time. This means the boundary between simple repetition and universal computation can be crossed by the tiniest of machines.

But *why* does Rule 110 compute? What makes it different from Rule 0 (which kills everything) or Rule 204 (which preserves everything)? A new line of research suggests the answer lies not in the dynamic behavior of these automata, but in their algebraic geometry.

## Polynomials Over the Simplest Number System

The key insight is to stop thinking of cellular automata as dynamic processes and start thinking of them as polynomial equations.

Consider the two-element number system GF(2), which contains only 0 and 1, where 1 + 1 = 0. This isn't ordinary arithmetic — it's the arithmetic of Boolean logic, where addition is XOR and multiplication is AND. In this miniature number system, every function of three variables can be written as a polynomial of degree at most 3.

Take Rule 110. Its local update — the function that decides each cell's next state from its three-cell neighborhood — turns out to be the polynomial:

**g(a, b, c) = b + c + bc + abc**

This is not a metaphor. This is literally what Rule 110 computes, expressed in the algebra of GF(2). The polynomial has degree 3, the maximum possible for a three-variable function over GF(2).

This polynomial representation is called the *Algebraic Normal Form* (ANF), and every one of the 256 ECA rules has a unique ANF. The representation is computed by a discrete version of Möbius inversion — evaluating the rule at all eight possible inputs and extracting coefficients through a systematic inclusion-exclusion.

## The Fixed-Point Variety

Once we have polynomials, we can do geometry. The central geometric object is the *fixed-point variety*: the set of all states that the automaton leaves unchanged.

When we apply the rule to every cell in a cyclic array of length *n*, we get a polynomial map **f** : GF(2)^*n* → GF(2)^*n*. The fixed points — states where **f**(**s**) = **s** — are the solutions to a system of *n* polynomial equations over GF(2). In algebraic geometry, the solution set of polynomial equations is called a *variety*, and varieties have structure.

Here is where the mathematics becomes interesting. We discovered that the structure of this variety depends fundamentally on the algebraic degree of the rule:

**For degree ≤ 1 rules (additive rules), the fixed-point variety is a vector subspace.**

This is a genuine theorem, not an observation. If the local rule can be written as g(a, b, c) = αa + βb + γc — a linear function — then the global update is a linear map, and the set of fixed points is the kernel of a linear transformation. It inherits all the structure of linear algebra: it's closed under addition and scalar multiplication, and its size is always a power of 2.

But for nonlinear rules — those with degree 2 or 3 — the fixed-point set can have any cardinality. Rule 30, a chaotic Class 3 rule, has exactly 3 fixed points on a cycle of length 10. Three is not a power of 2. The fixed-point set of Rule 30 is not a subspace — it is a genuinely nonlinear variety.

## The Conjecture That Failed

The original hypothesis was seductive: perhaps the dimension of the fixed-point variety correlates with the Wolfram complexity class. Class 1 rules (simple death) would have dimension 0. Class 4 rules (universal computation) would have maximal dimension. The geometry of fixed points would *explain* the dynamics of computation.

The data demolish this hypothesis. Rule 110 — the Turing-complete rule — has exactly *one* fixed point on cycles of length up to 12. Dimension zero. Meanwhile, Rule 204 — the identity rule, which does absolutely nothing — has 2^*n* fixed points, every possible state. Maximal dimension.

Doing nothing is geometrically rich. Computing everything is geometrically sparse.

This negative result is itself illuminating. It tells us that computational complexity is not stored in the fixed-point variety. The power of Rule 110 lies not in its stable configurations but in its *transient dynamics* — the structures that move, collide, and interact before any fixed point is reached. The geometry of fixed points captures the automaton's *equilibrium*, not its *capacity for computation*.

## What the Algebra Does Reveal

The algebraic framework reveals a different kind of truth. The 256 ECA rules are not equally distributed across the degrees:

- **Degree 0**: 2 rules (0.8%) — the constant rules
- **Degree 1**: 14 rules (5.5%) — the linear/additive rules
- **Degree 2**: 112 rules (43.8%) — quadratic nonlinearity
- **Degree 3**: 128 rules (50.0%) — maximal nonlinearity

Exactly half of all ECA rules have the maximum possible algebraic degree. This is a reflection of a deeper combinatorial fact about Boolean functions: the majority of functions on three variables are "maximally complex" in their polynomial structure.

The additive rules form a particularly elegant class. There are only 14 of them (including trivial rules), and they include Rule 90 (the XOR rule, which generates Sierpiński triangles) and Rule 150. For these rules, the fixed-point variety is always a vector subspace, and its dimension can be computed exactly using linear algebra — specifically, by finding the null space of the matrix *M* - *I*, where *M* is the circulant update matrix.

For Rule 90 on cycles of various lengths, the fixed-point dimension oscillates in a pattern connected to number-theoretic properties of the cycle length. On length 6, there are 4 fixed points (dimension 2). On length 7, only 1 (dimension 0). This oscillation is governed by the greatest common divisor of the cycle length with certain characteristic polynomials over GF(2).

## A Bridge Between Worlds

The deeper significance of this work lies in the bridge it builds. Cellular automata have traditionally been studied by dynamicists and computer scientists. Algebraic geometry has been the domain of number theorists and abstract algebraists. By viewing ECA rules as polynomial maps over GF(2), we connect these two worlds.

The Algebraic Normal Form is not merely a re-encoding — it is a *change of perspective* that opens new questions. If the fixed-point variety doesn't capture complexity, what geometric invariant does? Perhaps the *orbit variety* — the set of periodic points of period *k* — grows at different rates for different complexity classes. Perhaps the *scheme structure* of the variety (which remembers multiplicities and infinitesimal information lost by the naive solution set) carries hidden data about computational capacity.

These questions sit at the intersection of algebraic geometry, dynamical systems theory, and theoretical computer science. They may not be answered by studying the 256 ECA rules alone — but the ECA rules provide the simplest, most concrete testing ground for ideas that could eventually reshape how we understand computation as a geometric phenomenon.

## The Shape of Computing

There is something philosophically striking about viewing computation through the lens of geometry. A Turing machine is usually imagined as a process — a tape being read, a head moving, symbols being written. But the algebraic perspective suggests that computation is also a *shape*: the shape of a polynomial map's orbits through a high-dimensional space over the simplest possible field.

Rule 110's Turing completeness means that every computable function is, in some precise sense, encoded in the orbits of a degree-3 polynomial map over GF(2). The simplest geometry contains the most complex computation.

This is perhaps the deepest lesson: complexity is not a property of the space (GF(2)^*n* is finite and structureless), nor of the polynomial (degree 3 is shared by 128 rules), but of the *interaction* between the polynomial and the cyclic structure of the boundary conditions. The geometry of computation emerges from this interaction — and we are only beginning to map its contours.
