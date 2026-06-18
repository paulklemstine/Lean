# Future Directions: Support-Shadow Complexity

## Synthesis

The theorems proved in this cycle establish support-shadow complexity as a viable framework for algebraic circuit lower bounds. We have shown that the shadow operator is subadditive under addition gates, monotone under multiplication gates, and recursively bounded for circuit evaluations. The computational experiments reveal a striking pattern: permanent supports exhibit linearly growing inflation ratios relative to KK minimizers, while elementary symmetric polynomials achieve exact KK optimality. These results open five concrete research directions, ranging from foundational extensions of classical KK theory to ambitious lower-bound programs that would resolve major open problems. The key unifying theme is that **extremal combinatorics provides a new lens for computational complexity**, one that sees structure invisible to rank-based and evaluation-based methods.

---

## Direction 1: Full Kruskal–Katona Theory for Multi-Index Families

**Conjecture:** There exists a total order $\prec$ on $\mathbb{N}^n$ (a multi-index colex order) such that for every $d$ and $m$, the initial segment of $\prec$ among degree-$d$ multi-indices minimizes the one-step shadow among all families of size $m$.

**Test:** Enumerate all families of size $m \le 10$ in degree $d \le 4$ with $n \le 4$ variables. Check whether the colex-initial segment always achieves the minimum shadow. A single counterexample refutes the conjecture; universal confirmation up to these bounds provides strong evidence.

**Impact:** This would extend the classical KK theorem from uniform set families to the full multi-index lattice, providing exact computable KK bounds for non-squarefree polynomial supports. This is essential for the shadow-gap program beyond the squarefree regime.

**Catalog References:**
- `Catalog/Pythagorean/IteratedShadowGeometry.lean`: `kthShadow`, `mem_kthShadow_iff`
- `Catalog/Bridges/Catalog/Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `kthShadow_elemSymm_eq`

**Proof Strategy:** The key insight is that the classical proof of KK uses a "compression" operator that pushes a family toward the initial segment while not increasing the shadow. For multi-indices, define compression $C_{ij}$: for each $\alpha$ with $\alpha(i) > 0$ and room to increment $\alpha(j)$, replace $\alpha$ with the compressed version. Prove that each compression does not increase the shadow (by an injection argument on shadow witnesses), then show that the limit of iterated compressions is the colex-initial segment.

**Why now?** The formal infrastructure for multi-index shadows (definitions, membership lemmas, semigroup laws) is now in place. The missing piece is the compression machinery, which is a finite combinatorial argument amenable to proof automation.

**Domain Bridges:** Extremal combinatorics → algebraic complexity (via explicit KK bounds for polynomial supports).

**Lineage:** Extends Kruskal (1963), Katona (1968), Clements–Lindström (1969).

**Ambition:** Grand challenge — would establish a foundational tool for the entire shadow-gap program.

---

## Direction 2: Cancellation-Aware Shadow Bounds for General Circuits

**Conjecture:** For any (non-monotone) algebraic circuit $C$ of size $s$ computing a polynomial $f$, there exists a shadow bound $|\mathrm{Sh}_1(\mathrm{supp}(f))| \le g(s, n, d)$ where $g$ is polynomial in $s$ and depends on the cancellation pattern.

**Test:** Construct small non-monotone circuits for polynomials with known support (e.g., determinant of 3×3 and 4×4 matrices). Compute the actual shadow and verify the bound. Check whether the permanent's shadow exceeds the bound for circuits of the expected size.

**Impact:** This would extend the shadow-gap framework from monotone to general circuits, the regime where P vs. NP type separations live.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`: `card_oneShadow_union_le`, `shadow_bound_of_supportCircuit`

**Proof Strategy:** The key insight is that cancellation in $f + g$ can only *reduce* the support: $\mathrm{supp}(f + g) \subseteq \mathrm{supp}(f) \cup \mathrm{supp}(g)$. So the monotone shadow bound is still an upper bound on the shadow of the actual support. The challenge is to prove *lower* bounds showing that the actual shadow cannot be too small. One approach: use the fact that if $f$ has few terms, then $\mathrm{supp}(f)$ is "small" in a KK sense, constraining the shadow from below.

**Why now?** The monotone case is proved. The next step is to handle the gap between $\mathrm{supp}(f + g)$ and $\mathrm{supp}(f) \cup \mathrm{supp}(g)$ by bounding how much cancellation can reduce the shadow.

**Domain Bridges:** Algebraic complexity → additive combinatorics (cancellation patterns as sumset structure).

**Lineage:** Builds on the shadow subadditivity theorem (this work) and Baur–Strassen (1983).

**Ambition:** Solid extension — directly builds on proved theorems.

---

## Direction 3: Shadow Isoperimetry for Newton Polytopes

**Conjecture:** Among all finite subsets $S \subseteq \mathbb{N}^n$ with $|S| = m$ and Newton polytope volume $V$, the minimum shadow size satisfies:

$$|\mathrm{Sh}_1(S)| \ge c \cdot m^{(n-1)/n}$$

for a constant $c$ depending on $n$ and $V$, analogous to the lattice isoperimetric inequality.

**Test:** For $n = 2, 3$, enumerate families of size $m \le 50$ with prescribed Newton polytope (e.g., simplex, cube, cross-polytope). Compute the shadow and check against the conjectured bound. Plot shadow size vs. polytope volume.

**Impact:** This would provide a geometric lower bound on shadows, independent of degree constraints. It connects the shadow-gap program to the rich theory of lattice point geometry and Ehrhart theory.

**Catalog References:**
- `Catalog/Bridges/Catalog/Pythagorean/CircuitLowerBounds/ShadowDecay.lean`: `kthShadow_subset_degreeSimplex`, `degreeSimplex_card`

**Proof Strategy:** The key insight is that the one-step shadow is a discrete analogue of the inner parallel body of the Newton polytope. For convex lattice polytopes, the number of interior lattice points is controlled by the Ehrhart polynomial. A discrete isoperimetric inequality on the lattice should relate the shadow size to the surface area of the Newton polytope, which in turn relates to the volume by the classical isoperimetric inequality.

**Why now?** The shadow operator is now formally defined on multi-index families, and the connection to Newton polytopes is established through the degree-simplex containment theorems. The missing link is a discrete isoperimetric inequality on the integer lattice, which is an active area of research in combinatorial geometry.

**Domain Bridges:** Algebraic complexity → convex geometry → Ehrhart theory.

**Lineage:** Builds on Bollobás–Leader lattice isoperimetry, Barvinok's lattice point theory.

**Ambition:** Grand challenge — would establish a deep geometric foundation for shadow bounds.

---

## Direction 4: Entropy Production Under Differentiation

**Conjecture:** Define the **shadow entropy** of a family $S$ as $H(S) = \log |\mathrm{Sh}_1(S)| - \log |S|$. For polynomials computed by circuits of size $s$:

$$H(\mathrm{supp}(f)) \le O(\log s)$$

while for the permanent:

$$H(\mathrm{PermSupp}(m)) \ge \Omega(\log m)$$

**Test:** Compute $H$ for all circuits of size $\le 8$ in $n \le 4$ variables. Verify the logarithmic bound. Compare with the permanent's entropy for $m = 2, \ldots, 6$.

**Impact:** An information-theoretic formulation would connect the shadow-gap program to communication complexity, information complexity, and the entropy method in combinatorics.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`: `card_oneShadow_le_mul_card`

**Proof Strategy:** The key insight is that the bound $|\mathrm{Sh}_1(S)| \le n \cdot |S|$ gives $H(S) \le \log n$ universally. For circuits, the multiplicative structure should constrain $H$ more tightly. Each add gate increases $|S|$ additively; each mul gate increases it multiplicatively. The entropy $H$ should decompose along the circuit DAG, giving a bound in terms of circuit depth and width.

**Why now?** The general bound $|\mathrm{Sh}_1| \le n|S|$ is proved. The circuit bound theorem provides the recursive structure needed for an entropy decomposition. The connection to statistical physics (support as microcanonical ensemble, shadow as accessible states) provides physical intuition.

**Domain Bridges:** Algebraic complexity → information theory → statistical physics.

**Lineage:** Builds on entropy methods in combinatorics (Shearer's lemma, entropy compression).

**Ambition:** Solid extension with speculative connections to physics.

---

## Direction 5: Compressed Support Semirings

**Conjecture:** Define a **support semiring** as a semiring whose elements are finite subsets of $\mathbb{N}^n$, with addition = union and multiplication = Minkowski sum. The shadow operator $\mathrm{Sh}_1$ is a derivation on this semiring in a suitable sense:

$$\mathrm{Sh}_1(A \oplus B) \supseteq \mathrm{Sh}_1(A) \oplus B \cup A \oplus \mathrm{Sh}_1(B)$$

A **compressed support semiring** restricts to KK-compressed families (colex-initial segments), and the shadow on this sub-semiring has optimal behavior.

**Test:** Verify the "derivation inequality" for all pairs $(A, B)$ with $|A|, |B| \le 10$ in $n \le 3$ variables. Check whether the inequality is tight for compressed families.

**Impact:** This would provide an algebraic framework for shadow complexity, allowing techniques from semiring theory and tropical algebra to be applied to circuit lower bounds.

**Catalog References:**
- `Pythagorean/CircuitLowerBounds/KruskalKatonaSupport.lean`: `map_add_mem_oneShadow_supportMul`, `supportMul`

**Proof Strategy:** The key insight is that the proved theorem `map_add_mem_oneShadow_supportMul` already establishes one direction of the derivation inequality ($\mathrm{Sh}_1(A) \oplus B \subseteq \mathrm{Sh}_1(A \oplus B)$). The other direction ($A \oplus \mathrm{Sh}_1(B) \subseteq \mathrm{Sh}_1(A \oplus B)$) follows by symmetry of the Minkowski sum. Combining both gives the full derivation inequality. The compressed sub-semiring requires showing that compression commutes with Minkowski addition — a nontrivial combinatorial result.

**Why now?** The Minkowski shadow theorem is proved. The derivation inequality is a direct consequence. The compressed sub-semiring construction requires the full multi-index KK theory (Direction 1) but can be developed in parallel.

**Domain Bridges:** Algebraic complexity → algebra (semiring theory) → tropical geometry.

**Lineage:** Builds on tropical semirings, support theory of polynomial multiplication.

**Ambition:** Solid extension with grand-challenge potential if combined with Direction 1.
