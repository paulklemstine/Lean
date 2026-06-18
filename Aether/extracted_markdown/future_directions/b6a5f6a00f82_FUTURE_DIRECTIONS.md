# Future Directions: Tropical Brill-Noether Theory

## 1. Baker-Norine Riemann-Roch for Graphs

The Baker-Norine theorem states that for a divisor D on a graph G of genus g,
rank(D) - rank(K_G - D) = deg(D) - g + 1, where K_G is the canonical divisor.
Our chip-firing infrastructure (Laplacian sum-zero, degree invariance, linear
equivalence as equivalence relation) provides exactly the foundation needed.

The key insight is that the Laplacian kernel characterizes chip-firing equivalence
classes, and the degree invariance theorem we proved ensures the rank function
is well-defined on equivalence classes. Why now? We have all the algebraic
infrastructure for graph divisors formalized — what remains is the combinatorial
argument using q-reduced divisors (Dhar's burning algorithm) to establish the
existence and uniqueness of reduced representatives.

## 2. Full CDPR Theorem with Metric Structure

The Cools-Draisma-Payne-Robeva theorem in Core.lean currently proves the
combinatorial equivalence between CDPR allocations and ρ ≥ 0. The full
theorem requires showing that on a *generic* metric chain of loops, the
rank of the constructed divisor equals exactly r.

The key insight is that the genericity condition (distinct edge-length ratios,
formalized in Defs.lean as `MetricChainOfLoops.IsGeneric`) prevents accidental
rank jumps, ensuring the allocation-based construction achieves rank exactly r
and no more. Why now? The metric chain of loops structure and genericity
condition are already formalized in Defs.lean; what's needed is the tropical
linear series computation on metric graphs using the break divisor theory.

## 3. Specialization Inequality and Lifting

Baker's specialization lemma (abstracted in Defs.lean as `SpecializationDatum`)
states that rank does not decrease under tropicalization. The converse — the
lifting problem — asks when tropical divisors lift to algebraic ones with the
same rank. This would close the loop between tropical and classical
Brill-Noether theory.

The key insight is that the Serre duality we proved (ρ(g,r,d) = ρ(g,g-1-d+r,2g-2-d))
constrains which tropical divisors can possibly lift, since the duality must be
preserved by any faithful specialization. Why now? The abstract specialization
interface provides a clean framework for stating lifting conditions, and the
duality theorem gives computable necessary conditions for liftability.

## 4. Tropical Moduli Space Dimension

The Brill-Noether number ρ should equal the dimension of the tropical moduli
space W^r_d(Γ) for a general tropical curve Γ. Our strict monotonicity result
and boundary behavior (ρ < 0 for large genus) constrain when this space is
empty.

The key insight is that the monotonicity theorem (ρ is strictly increasing in d)
means the transition from empty to nonempty W^r_d happens at a single critical
degree, making the dimension theory particularly clean in the tropical setting.
Why now? The algebraic properties proven in Duality.lean give complete control
over the sign of ρ, which is the key input for tropical intersection theory
computations on the moduli space.

## 5. Chip-Firing Groups and Jacobians

The graph Laplacian we formalized defines a group homomorphism from
(V → ℤ) to GraphDivisor V. The cokernel of this map restricted to
degree-zero divisors is the Jacobian (or sandpile group) of the graph,
whose order equals the number of spanning trees by the matrix-tree theorem.

The key insight is that our Laplacian additivity theorem (graphLaplacian_add)
and the linear equivalence transitivity directly give the group structure
on divisor classes, and the Laplacian sum-zero property ensures the degree-zero
condition is well-defined on classes. Why now? The equivalence relation
(reflexivity, symmetry, transitivity all proved) means we can immediately
quotient to get the Jacobian as a type, and the matrix-tree theorem connection
would give a concrete computation of its cardinality.
