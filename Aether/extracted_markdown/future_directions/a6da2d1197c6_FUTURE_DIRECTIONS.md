# Future Directions

## Synthesis

The formalization of the Jones polynomial via the Kauffman bracket opens multiple avenues for extending both the verified mathematical infrastructure and the computational applications. The five directions below form a coherent research program: Direction 1 completes the invariance proof by handling Reidemeister II, enabling Directions 2 and 3 to build higher-level structures (skein modules and colored Jones polynomials). Direction 4 targets the deep unknot detection theorem for alternating knots, while Direction 5 pushes into categorification (Khovanov homology), which subsumes and extends the Jones polynomial. Together, these directions trace a path from verified combinatorial topology toward certified topological quantum computation.

---

## Direction 1: Complete Reidemeister II Invariance with Arc-Level Diagram Model

**Conjecture:** A formalization of link diagrams with explicit arc connectivity (planar diagram codes) admits a provable Reidemeister II invariance theorem for the Kauffman bracket, via a two-step skein expansion at the two crossings of the R2 pair.

**Test:** Implement a `PDLinkDiagram` structure in Lean with:
- Arcs labeled by natural numbers
- Crossings specifying four incident arcs
- A computable `smoothAndCountLoops` function

Verify that `bracket_RII_invariant` can be proved for this richer model. Test on the unknot-with-R2-pair: a diagram with 2 crossings and the unknot as the simplified form. The bracket of the 2-crossing diagram should equal 1.

**Impact:** Completes the full invariance proof, making the Jones polynomial a certified knot invariant under all three Reidemeister moves.

**Catalog References:** `Geometry/KnotTheory/KauffmanBracket.lean`, `Geometry/KnotTheory/Defs.lean`

**Proof Strategy:** Model the R2 move as two crossings with opposite local geometry. Apply the skein relation at the first crossing to get two diagrams, one of which has a kink (R1 type) and the other has no crossing. Then apply R1 invariance on the kinked term and simplify. The algebraic identity $A \cdot (-A^3) \cdot \langle D_2 \rangle + A^{-1} \cdot \delta \cdot \langle D_2 \rangle = \langle D_2 \rangle$ captures the cancellation.

**Domain Bridges:** Combinatorial topology → Planar graph theory → Formal methods

**Lineage:** Extends `bracket_RI_positive`, `bracket_RI_negative`, `bracket_RIII_invariant`

**Ambition:** Extension (moderate difficulty, high foundational value)

---

## Direction 2: Skein Module Formalization

**Conjecture:** The Kauffman bracket skein module of $S^1 \times D^2$ (the solid torus) is isomorphic to $\mathbb{Z}[A^{\pm 1}]$ as a module, with basis given by the sequence of Chebyshev polynomials $\{e_n\}_{n \geq 0}$.

**Test:** Define the `SkeinModule` structure in Lean as a quotient of the free module on isotopy classes of framed links in a 3-manifold, modulo the Kauffman skein relation. Verify the solid torus case by:
1. Constructing the Chebyshev basis elements $e_n$ for $n = 0, 1, 2, 3$
2. Proving they satisfy the recurrence $e_{n+1} = A \cdot e_n - e_{n-1}$ (with appropriate framing)
3. Showing linear independence via evaluation on specific links

**Impact:** Provides the algebraic home for all quantum knot invariants. The skein module is the categorical shadow of the Temperley-Lieb algebra, and formalizing it opens the door to HOMFLY-PT and Kauffman 2-variable polynomials.

**Catalog References:** `Geometry/KnotTheory/KauffmanBracket.lean`

**Proof Strategy:** Define skein modules as a quotient type. The solid torus case reduces to showing that every framed link in the solid torus can be written as a linear combination of parallel copies of the core curve, using the skein relation to reduce crossings.

**Domain Bridges:** Knot theory → Representation theory → Topological quantum field theory

**Lineage:** Extends the Kauffman bracket formalization into 3-manifold topology

**Ambition:** Grand challenge (opens entire new area of formalized 3-manifold topology)

---

## Direction 3: Colored Jones Polynomial and the Volume Conjecture

**Conjecture:** The colored Jones polynomial $J_N(K; q)$ of the figure-eight knot satisfies the volume conjecture:
$$2\pi \lim_{N \to \infty} \frac{\log |J_N(K; e^{2\pi i / N})|}{N} = \text{Vol}(S^3 \setminus K) \approx 2.02988$$

**Test:**
1. Implement $J_N(K; q)$ for torus knots $T(2,n)$ using the known closed formula
2. Compute $J_N(\text{figure-eight}; e^{2\pi i/N})$ for $N = 10, 20, 50, 100, 200, 500$
3. Verify convergence to $\text{Vol}(S^3 \setminus 4_1) / (2\pi)$ to precision $10^{-4}$
4. Formalize the colored Jones polynomial for small $N$ in Lean

**Impact:** The volume conjecture (Kashaev, Murakami-Murakami) is one of the deepest open problems connecting quantum topology to hyperbolic geometry. Even partial formalization would be groundbreaking.

**Catalog References:** `Geometry/KnotTheory/Jones.lean`, `Geometry/KnotTheory/Examples.lean`

**Proof Strategy:** The colored Jones polynomial can be defined via the $R$-matrix of $U_q(\mathfrak{sl}_2)$. For the figure-eight knot, use the explicit recurrence relation. Formalize the recurrence in Lean and verify numerically.

**Domain Bridges:** Knot theory → Quantum groups → Hyperbolic geometry → Number theory (algebraic integers)

**Lineage:** Generalizes the Jones polynomial (which is $J_2$) to all representations

**Ambition:** Grand challenge (paradigm-shifting connection between quantum and classical topology)

---

## Direction 4: Jones Polynomial Detects the Unknot for Alternating Knots

**Conjecture:** For any reduced alternating link diagram $D$ with $n > 0$ crossings, $V_D(t) \neq 1$.

**Test:**
1. Formalize the notion of "adequate diagram" (A-adequate and B-adequate)
2. Prove that the all-A state contributes the unique highest-degree term to the bracket (A-adequacy)
3. Prove that the all-B state contributes the unique lowest-degree term (B-adequacy)
4. Conclude that the bracket has breadth ≥ $4n > 0$, hence is non-constant
5. Conclude $V_D \neq 1$ since multiplying by a monomial preserves non-constancy

Verify computationally for all alternating knots up to 16 crossings using the knot tables.

**Impact:** Proves the Tait conjecture consequence that reduced alternating diagrams have minimal crossing number, and that the Jones polynomial detects unknottedness in this class.

**Catalog References:** `Geometry/KnotTheory/KauffmanBracket.lean` (bracket definition), existing `Catalog/Speculative/Knot/Alternating.lean` (partial formalization)

**Proof Strategy:** The key is formalizing adequacy: for the all-A state $s_A$, the loop count $\ell(s_A)$ is strictly greater than $\ell(s)$ for any state $s$ that differs from $s_A$ at exactly one crossing (this is A-adequacy). This ensures the $A^n$ coefficient of the bracket is $\pm \delta^{\ell(s_A)-1}$, which is nonzero.

**Domain Bridges:** Knot theory → Graph theory (Tait graphs, Tutte polynomial) → Combinatorics

**Lineage:** Builds on `bracket_RIII_invariant` and the state-sum framework

**Ambition:** Extension (follows established mathematical path, but requires significant new formalization)

---

## Direction 5: Khovanov Homology Categorification

**Conjecture:** Khovanov homology $Kh(K)$ categorifies the Jones polynomial: $\chi(Kh(K)) = V_K(t)$, where $\chi$ is the graded Euler characteristic. Moreover, Khovanov homology detects the unknot: $Kh(K) \cong Kh(\text{unknot})$ if and only if $K$ is the unknot.

**Test:**
1. Define the Khovanov chain complex for link diagrams with ≤ 5 crossings
2. Compute $Kh$ for the trefoil and figure-eight knot
3. Verify $\chi(Kh) = V$ in these cases
4. Formalize the Frobenius algebra structure underlying Khovanov homology
5. Verify unknot detection for all knots up to 14 crossings (computationally)

**Impact:** Khovanov homology is strictly stronger than the Jones polynomial. Its formalization would:
- Provide the first machine-verified categorification of a quantum invariant
- Open the path to formalized spectral sequences in topology
- Connect to the Rasmussen $s$-invariant and the Milnor conjecture

**Catalog References:** `Catalog/MachineLearning/Knot/Khovanov/FrobeniusAlgebra.lean` (existing partial formalization)

**Proof Strategy:** Define the chain complex using the cube of resolutions. The differential maps come from the Frobenius algebra structure on $\mathbb{Z}[x]/(x^2)$. The categorification theorem follows from careful bookkeeping of gradings.

**Domain Bridges:** Knot theory → Homological algebra → Category theory → Gauge theory (Floer homology)

**Lineage:** Categorifies all results in `Geometry/KnotTheory/`

**Ambition:** Grand challenge (opens entirely new area of formalized homological knot invariants)
