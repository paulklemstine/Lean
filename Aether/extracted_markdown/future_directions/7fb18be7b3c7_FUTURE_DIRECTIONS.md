# Future Directions

## Synthesis

This research cycle introduced the **dynamical core** — the largest invariant subset on which any finite-state endomorphism acts bijectively — and proved the **Core Bijectivity Theorem**, establishing that every cellular automaton contains a canonical reversible subsystem. We also formalized the **reversibility group** of shift-equivariant permutations and proved its key structural properties: closure under inversion, proper subgroup status, and commutativity of the shift-complement subgroup.

The most promising cross-domain connection is between the dynamical core and **tropical semiring theory** from the Catalog. The image tower stabilization is analogous to the idempotency property of tropical matrix powers: in both cases, iterated application reaches a fixed point that captures the "essential" structure. The core depth bound (≤ |α|) mirrors the stabilization bound for tropical matrix powers. This connection could lead to a tropical characterization of CA reversibility via min-plus linear algebra.

The reversibility group formalization connects naturally to the **Galois theory** already present in the Catalog (`Bridges/GaloisDeepLearning.lean`). The centralizer of the shift in the symmetric group is precisely the Galois group of the shift action, and the Galois correspondence between subgroups and invariant subspaces mirrors the correspondence between CA subalgebras and fixed-point sets. This bridge between discrete dynamics and Galois theory is the highest-potential direction.

---

### Direction 1: Linear CA Reversibility via Cyclotomic Polynomials

**Conjecture**: A linear cellular automaton over GF(2) with characteristic polynomial $p(x)$ is reversible on $\mathbb{Z}/n\mathbb{Z}$ if and only if $\gcd(p(x), x^n - 1) = 1$ in $\text{GF}(2)[x]$. For Rule 150 specifically, $p(x) = x^2 + x + 1$, so reversibility holds iff $3 \nmid n$.

**Test**: Compute the GF(2)-rank of the circulant matrix for Rule 150 on $\mathbb{Z}/n\mathbb{Z}$ for $n = 1, \ldots, 100$. Verify that the rank drops below $n$ exactly when $3 | n$. Then formalize the connection between circulant matrix determinants and polynomial GCDs over finite fields.

**Impact**: If true, this gives a complete algebraic characterization of linear CA reversibility, reducing a dynamical question to polynomial arithmetic. It would also connect CA theory to the rich Mathlib library on cyclotomic polynomials.

**Catalog References**: `Novelty/CAGalois.lean` (Rule 150 definition, shift-equivariance proof), `Novelty/DynCore.lean` (core bijectivity theorem)

**Proof Strategy**: (1) Formalize circulant matrices over arbitrary fields. (2) Prove that the determinant of a circulant matrix equals the product of polynomial evaluations at roots of unity. (3) Show that over GF(2), this product is nonzero iff the characteristic polynomial is coprime to $x^n - 1$. (4) Apply to Rule 150 with $p(x) = x^2 + x + 1$.

**Domain Bridges**: Algebra (cyclotomic polynomials) ↔ Computation (CA reversibility) ↔ EML (finite field arithmetic)

**Lineage**: Builds on `CAGalois.rule150`, `CAGalois.isShiftEquiv_rule150`, and the dynamical core theory from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Core Depth Distribution for Random Endomorphisms

**Conjecture**: For a uniformly random endomorphism $f : [N] \to [N]$, the expected core depth satisfies $\mathbb{E}[\text{coreDepth}(f)] = \Theta(\sqrt{N})$, and the core size satisfies $\mathbb{E}[|\text{core}(f)|] = \Theta(\sqrt{N})$.

**Test**: Sample 10,000 random endomorphisms for each $N \in \{10, 50, 100, 500, 1000\}$. Compute the average core depth and core size. Plot against $\sqrt{N}$ and verify the linear relationship. Then formalize the connection to the theory of random mappings (Flajolet-Odlyzko).

**Impact**: Connects the dynamical core to analytic combinatorics. The core depth distribution would characterize the "typical" information loss in random dynamical systems, with applications to hash function analysis and random Boolean networks.

**Catalog References**: `Novelty/DynCore.lean` (coreDepth definition and bound), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: (1) Model random endomorphisms as random functional graphs. (2) Use the Flajolet-Odlyzko theory of random mappings to show that the expected number of cyclic points (= core size) is $\sqrt{\pi N / 2} + O(1)$. (3) Relate core depth to the "tail length" in random mapping statistics. (4) Formalize the asymptotic bounds.

**Domain Bridges**: Computation (random algorithms) ↔ Novelty (dynamical core) ↔ Algebra (generating function methods)

**Lineage**: Builds on `DynCore.coreDepth_le_card` and the image tower stabilization theory from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Tropical Matrix Powers and the Image Tower

**Conjecture**: For a linear CA over a tropical semiring, the image tower stabilization corresponds to the convergence of tropical matrix powers. Specifically, for a tropical circulant matrix $C$, the sequence $C, C^2, C^3, \ldots$ stabilizes at the same depth as the image tower of the induced map.

**Test**: Compute tropical matrix powers of the circulant matrices associated with Rules 170, 51, and 150 for $n = 5, 7, 11$. Compare the stabilization depth with the core depth of the corresponding CA on $\mathbb{Z}/n\mathbb{Z}$.

**Impact**: Would establish a formal bridge between tropical geometry and CA dynamics, unifying two different notions of "stabilization" in discrete mathematics.

**Catalog References**: `Tropical/TropicalOptimization.lean`, `Novelty/DynCore.lean`, `Bridges/AlgebraEMLClosureComputation.lean`

**Proof Strategy**: (1) Define tropical circulant matrices. (2) Prove that tropical matrix multiplication corresponds to min-plus convolution. (3) Show that the tropical eigenvalue (= growth rate) determines whether the power sequence stabilizes. (4) Connect to the CA image tower via a functorial construction.

**Domain Bridges**: Tropical (min-plus algebra) ↔ Novelty (dynamical core) ↔ Computation (matrix algorithms)

**Lineage**: Builds on `DynCore.imageTower_stabilizes` and the Tropical module from the Catalog.

**Ambition**: extension

---

### Direction 4: The Reversibility Group for Non-Binary Alphabets

**Conjecture**: For CAs on alphabet $\mathbb{Z}/p\mathbb{Z}$ (prime $p$) with radius $r$, the reversibility group contains a subgroup isomorphic to $\text{GL}(2r+1, \mathbb{F}_p)$, generated by the linear CAs. For $p = 2$, $r = 1$, this gives $\text{GL}(3, \mathbb{F}_2)$ of order 168 as a subgroup of the reversibility group.

**Test**: Enumerate all linear CAs (those defined by $\mathbb{F}_p$-linear local rules) for $p = 2, r = 1$ on $\mathbb{Z}/7\mathbb{Z}$. Compute the group generated by their global maps and verify it is isomorphic to $\text{GL}(3, \mathbb{F}_2)$.

**Impact**: Would reveal the "linear skeleton" inside the reversibility group, connecting CA theory to classical matrix group theory and providing a lower bound on the reversibility group's size.

**Catalog References**: `Novelty/CAGalois.lean` (RevGroup definition), `Algebra/AlgebraicTheoryOfAlgebra.lean`

**Proof Strategy**: (1) Define linear local rules as $\mathbb{F}_p$-linear maps $\mathbb{F}_p^{2r+1} \to \mathbb{F}_p$. (2) Show that composition of linear CAs corresponds to matrix multiplication. (3) Prove that the group of invertible linear CAs is isomorphic to a quotient of $\text{GL}(2r+1, \mathbb{F}_p)$.

**Domain Bridges**: Algebra (matrix groups) ↔ Novelty (CA reversibility) ↔ Cryptography (linear codes)

**Lineage**: Builds on `CAGalois.RevGroup` and `CAGalois.revGroup_ne_top` from this cycle.

**Ambition**: extension

---

### Direction 5: Garden of Eden Counting via Möbius Inversion

**Conjecture**: For a CA $f$ on $\mathbb{Z}/n\mathbb{Z}$ with alphabet $A$, the number of Garden of Eden configurations (those with no preimage) satisfies
$$|\text{GoE}(f, n)| = |A|^n - |A|^n \cdot \prod_{p | n} (1 - p^{-\text{nullity}_p(f)})$$
where $\text{nullity}_p(f)$ is the nullity of the induced CA on $\mathbb{Z}/p\mathbb{Z}$.

**Test**: Compute $|\text{GoE}|$ for Rule 150 on $\mathbb{Z}/n\mathbb{Z}$ for $n = 1, \ldots, 30$ and verify against the conjectured formula.

**Impact**: A closed-form expression for Garden of Eden counts would connect CA theory to number-theoretic functions (Möbius function, Euler's totient) and provide a quantitative measure of irreversibility.

**Catalog References**: `Catalog/Algebra/CellularAutomataReversibility.lean` (gardenOfEdenCount, reversible_iff_no_goe)

**Proof Strategy**: (1) Express the GoE count in terms of the transfer matrix determinant. (2) Factor the circulant determinant using roots of unity. (3) Apply Möbius inversion to relate the factorization to divisors of $n$.

**Domain Bridges**: Algebra (number theory) ↔ Novelty (CA dynamics) ↔ Computation (algorithmic counting)

**Lineage**: Builds on the Garden of Eden theory in `CellularAutomataReversibility.lean` and the dynamical core from this cycle.

**Ambition**: extension
