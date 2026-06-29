# Berggren Lattice Reduction Duality via Triple-Tree Gram Semimodules and Certified Short-Basis Reconstruction

## Abstract

We establish a formal bridge between the Berggren semigroup of primitive Pythagorean triples and lattice reduction theory, formalized and verified in Lean 4 with Mathlib. For each primitive Pythagorean triple $(a,b,c)$ with $a^2+b^2=c^2$, we construct a rank-2 lattice with basis vectors $v_1=(a,b)$, $v_2=(b,c)$ and associated Gram matrix $G(a,b,c)$. We prove:

1. **Perfect square determinant identity**: $\det G(a,b,c) = (ac - b^2)^2$, showing the Gram determinant is always a perfect square.
2. **Universal trace monotonicity**: The Gram trace $a^2 + 2b^2 + c^2$ strictly increases under all three Berggren generators.
3. **Shortest norm monotonicity**: The minimum basis vector squared norm $c^2$ is nondecreasing under all generators.
4. **Determinant monotonicity with algebraic certificates**: $\det G$ increases under generators A and C, with explicit factorization proofs.
5. **Gram recognition theorem**: The Gram matrix is a complete invariant for positive Pythagorean triples.
6. **Path-level invariant theory**: Berggren paths preserve the Pythagorean property and positivity, and the path invariant determines the terminal lattice.

All results are formalized without `sorry` in ~430 lines of Lean 4. We also provide Python implementations of the reconstruction algorithm and Lagrange reduction applied to Berggren lattices.

## 1. Introduction

### 1.1 Background

The Berggren tree [Berggren 1934, Barning 1963, Hall 1970] enumerates all primitive Pythagorean triples via three $3\times 3$ integer matrices acting on the root triple $(3,4,5)$. The generators are:

$$M_A = \begin{pmatrix} 1 & -2 & 2 \\ 2 & -1 & 2 \\ 2 & -2 & 3 \end{pmatrix}, \quad
M_B = \begin{pmatrix} 1 & 2 & 2 \\ 2 & 1 & 2 \\ 2 & 2 & 3 \end{pmatrix}, \quad
M_C = \begin{pmatrix} -1 & 2 & 2 \\ -2 & 1 & 2 \\ -2 & 2 & 3 \end{pmatrix}$$

These matrices preserve the Lorentzian form $a^2 + b^2 - c^2$ and generate a free monoid acting transitively on primitive Pythagorean triples with positive entries.

### 1.2 Motivation

Lattice reduction theory, originating with Lagrange, Gauss, and developed into a modern algorithmic framework by Lenstra–Lenstra–Lovász (LLL), is central to computational number theory and post-quantum cryptography. We observe that the Berggren tree provides a natural source of structured lattice instances with controlled arithmetic properties, and develop the formal theory connecting these domains.

### 1.3 Contributions

Our main contributions are:
- The identification of the Berggren tree as a *dynamical source* of rank-2 lattice instances
- Exact algebraic factorizations certifying monotonicity of lattice invariants along tree branches
- A complete invariant (the Gram matrix) for positive Pythagorean lattices
- Certified reconstruction of reduced bases from Gram data
- Complete formal verification of all results in Lean 4

## 2. Definitions and Notation

### 2.1 Pythagorean Triples

A **primitive Pythagorean triple** is a triple $(a,b,c) \in \mathbb{Z}_{>0}^3$ satisfying $a^2 + b^2 = c^2$ with $\gcd(a,b) = 1$.

### 2.2 Berggren Generators

The three Berggren generators act on triples as:
- **Generator A**: $(a,b,c) \mapsto (a-2b+2c, \; 2a-b+2c, \; 2a-2b+3c)$
- **Generator B**: $(a,b,c) \mapsto (a+2b+2c, \; 2a+b+2c, \; 2a+2b+3c)$
- **Generator C**: $(a,b,c) \mapsto (-a+2b+2c, \; -2a+b+2c, \; -2a+2b+3c)$

### 2.3 Gram Matrix

For a triple $(a,b,c)$, define the **lattice basis matrix** $B = \begin{pmatrix} a & b \\ b & c \end{pmatrix}$ and the **Gram matrix**:

$$G(a,b,c) = B^\top B = \begin{pmatrix} a^2+b^2 & ab+bc \\ ab+bc & b^2+c^2 \end{pmatrix}$$

### 2.4 Lattice Invariants

- **Gram trace**: $\mathrm{tr}(G) = a^2 + 2b^2 + c^2$
- **Gram determinant**: $\det(G) = (a^2+b^2)(b^2+c^2) - (ab+bc)^2$
- **Short norm**: $\mathrm{short}(G) = \min(a^2+b^2, \; b^2+c^2) = c^2$ (for Pythagorean triples)
- **Signature invariant**: $\sigma = ac - b^2$

## 3. Main Results

### 3.1 Perfect Square Determinant Identity (Theorem 1)

**Theorem 1.** *For any Pythagorean triple $(a,b,c)$ with $a^2+b^2=c^2$:*
$$\det G(a,b,c) = (ac - b^2)^2$$

**Proof sketch.** Direct algebraic expansion:
$$\det G = (a^2+b^2)(b^2+c^2) - (ab+bc)^2$$

Substituting $c^2 = a^2+b^2$ and expanding both sides, the identity reduces to a polynomial identity verified by `nlinarith` in Lean. $\square$

**Significance.** The Gram determinant is always a perfect square. The "signature invariant" $\sigma = ac - b^2$ captures the essential arithmetic of the lattice in a single integer.

### 3.2 Component Monotonicity (Theorem 2)

**Theorem 2.** *For any positive Pythagorean triple $(a,b,c)$ and any Berggren generator $g \in \{A,B,C\}$, the child triple $(a',b',c')$ satisfies $a' > a$, $b' > b$, $c' > c$.*

**Proof sketch.** For each generator, the differences $a'-a$, $b'-b$, $c'-c$ can be expressed in terms of positive quantities. The key auxiliary facts are:
- $b < c$ (from $a^2+b^2=c^2$ and $a>0$)
- $a < c$ (from $a^2+b^2=c^2$ and $b>0$)

For generator A: $a'-a = -2b+2c = 2(c-b) > 0$. For generator B: $a'-a = 2b+2c > 0$ (trivially). For generator C: $a'-a = -2a+2b+2c$ and $c > a$ gives $-2a+2c > 0$, combined with $2b > 0$. Similar arguments apply to $b$ and $c$ components. $\square$

### 3.3 Trace Monotonicity (Theorem 3)

**Theorem 3.** *For any positive Pythagorean triple $t$ and any Berggren generator $g$:*
$$\mathrm{tr}(G(t)) < \mathrm{tr}(G(g \cdot t))$$

**Proof.** Follows from Component Monotonicity (Theorem 2). Since $a' > a > 0$, $b' > b > 0$, $c' > c > 0$, we have $a'^2 > a^2$, $b'^2 > b^2$, $c'^2 > c^2$, and thus $a'^2+2b'^2+c'^2 > a^2+2b^2+c^2$. $\square$

### 3.4 Determinant Monotonicity (Theorem 4)

**Theorem 4.** *For generators $A$ and $C$: $(ac-b^2)^2 \leq (a'c'-b'^2)^2$.*

**Proof sketch (Generator A).** The key step is the algebraic factorization identity:

$$(a'c'-b'^2)^2 - (ac-b^2)^2 = 4b \cdot (3b^2 - ab - 3bc - ac) \cdot (2b - a - 3c)$$

This holds as a polynomial identity after substituting $c^2 = a^2+b^2$ and simplifying $a'c'-b'^2 = 5b^2-2ab-ac-6bc$.

**Sign analysis:**
- $b > 0$ (hypothesis)
- $3b^2 - ab - 3bc - ac = 3b(b-c) - a(b+c) \leq 0$ since $b < c$
- $2b - a - 3c \leq 0$ since $a > 0$ and $3c > 3b > 2b$

Thus the product is $4b \cdot (\text{nonpositive}) \cdot (\text{nonpositive}) \geq 0$. $\square$

**Proof sketch (Generator C).** The analogous factorization is:

$$(a'c'-b'^2)^2 - (ac-b^2)^2 = 4b \cdot (3b+3c-a) \cdot (2b^2+3bc-ab+ac)$$

All three factors are nonneg for positive Pythagorean triples. $\square$

**Remark.** Generator B does *not* satisfy determinant monotonicity in general. The counterexample $(99, 20, 101)$ has $|ac-b^2| = 9599$ but its B-child has $|a'c'-b'^2| = 8081 < 9599$.

### 3.5 Gram Recognition Theorem (Theorem 5)

**Theorem 5.** *If two positive Pythagorean triples $(a_1,b_1,c_1)$ and $(a_2,b_2,c_2)$ have equal Gram matrices, then $a_1=a_2$, $b_1=b_2$, $c_1=c_2$.*

**Proof sketch.** From $G(a_1,b_1,c_1) = G(a_2,b_2,c_2)$:
1. Entry $(0,0)$: $a_1^2+b_1^2 = a_2^2+b_2^2$, i.e., $c_1^2 = c_2^2$. Since $c_1,c_2 > 0$: $c_1 = c_2$.
2. Entry $(1,1)$: $b_1^2+c_1^2 = b_2^2+c_2^2$. With $c_1=c_2$: $b_1^2 = b_2^2$, so $b_1 = b_2$.
3. Then $a_1^2 = c_1^2-b_1^2 = c_2^2-b_2^2 = a_2^2$, so $a_1 = a_2$. $\square$

### 3.6 Path-Level Theory (Theorem 6)

**Theorem 6.** *Berggren paths preserve the Pythagorean property and positivity. If two paths produce the same path invariant, they yield the same terminal triple.*

**Proof.** By induction on the path length, using Theorems 1–2 for the inductive step. The path invariant includes the terminal triple, so equality of invariants implies equality of triples. $\square$

## 4. Algorithms

### 4.1 Gram Invariant Computation

```
Algorithm: ComputeGramInvariant(a, b, c)
Input: Pythagorean triple (a, b, c)
Output: GramInvariant(trace, det, g00, g01, g11)

1. g00 ← a² + b²         // = c²
2. g01 ← a·b + b·c       // = b(a+c)
3. g11 ← b² + c²
4. trace ← g00 + g11      // = a² + 2b² + c²
5. det ← (a·c - b²)²     // perfect square formula
6. return (trace, det, g00, g01, g11)

Time: O(M(n)) where M(n) = bit complexity of multiplying n-bit integers
Space: O(n)
```

### 4.2 Triple Reconstruction from Gram Data

```
Algorithm: ReconstructTriple(g00, g01, g11)
Input: Gram matrix entries
Output: (a, b, c) or FAIL

1. c ← isqrt(g00)         // c² = g00 = a²+b²
2. if c² ≠ g00: return FAIL
3. b ← isqrt(g11 - g00)   // b² = g11 - c²
4. if b² ≠ g11 - g00: return FAIL
5. a ← isqrt(g00 - b²)    // a² = c² - b²
6. if a² ≠ g00 - b²: return FAIL
7. if a·b + b·c ≠ g01: return FAIL
8. return (a, b, c)

Time: O(M(n)·log n) for integer square root
Space: O(n)
```

### 4.3 Lagrange Reduction of Berggren Basis

```
Algorithm: LagrangeReduce(v1, v2)
Input: Basis vectors v1=(a,b), v2=(b,c) from Pythagorean triple
Output: Reduced basis (u1, u2) with |u1| ≤ |u2|, |⟨u1,u2⟩| ≤ |u1|²/2

1. if ‖v1‖² > ‖v2‖²: swap(v1, v2)
2. repeat:
3.   q ← round(⟨v2,v1⟩ / ⟨v1,v1⟩)
4.   if q = 0: break
5.   v2 ← v2 - q·v1
6.   if ‖v2‖² < ‖v1‖²: swap(v1, v2)
7. return (v1, v2)

Time: O(log(max_norm)) iterations, O(M(n)) per iteration
Space: O(n)
Convergence: Guaranteed in O(log(c/a)) steps
```

## 5. Computational Experiments

### 5.1 Monotonicity Verification

We verified trace, determinant, and short-norm monotonicity for all 40 triples in the depth-3 Berggren tree (from root (3,4,5)):

| Metric | Generators Verified | Counterexamples |
|--------|-------------------|-----------------|
| Trace monotonicity | A, B, C (all) | None |
| Short norm monotonicity | A, B, C (all) | None |
| Det monotonicity | A, C | B fails at (99,20,101) |

### 5.2 Gram Recognition

All 40 triples in the depth-3 tree have distinct Gram matrices, confirming the recognition theorem computationally.

### 5.3 Growth Rates

Along the repeated-A branch, the trace grows approximately as $O(c^2)$ where $c$ grows linearly with depth (the sequence 5, 13, 25, 41, ... grows by $\approx 2\sqrt{c^2+b^2}$ per step). The determinant grows much faster, approximately as $(ac-b^2)^2 = O(c^4)$ per depth level.

| Depth | Triple | Trace | Det | Short Norm |
|-------|--------|-------|-----|-----------|
| 0 | (3,4,5) | 66 | 1 | 25 |
| 1A | (5,12,13) | 482 | 6241 | 169 |
| 2AA | (7,24,25) | 1826 | 160801 | 625 |
| 3AAA | (9,40,41) | 4962 | 1515361 | 1681 |

## 6. Applications

### 6.1 Structured Lattice Generation for Cryptography

The Berggren tree provides a deterministic generator of lattice instances with certified properties:
- **Known reduction behavior**: Monotonicity theorems guarantee invariant growth
- **Algebraic certificates**: Factorization identities provide proofs of reduction quality
- **Reproducibility**: Path encoding compactly represents the lattice instance
- **Parameterized hardness**: Depth in the tree controls the lattice invariants

### 6.2 Lattice Reduction Benchmarking

Berggren lattices provide a structured test suite for lattice reduction algorithms:
- Known optimal reductions (via Lagrange reduction in rank 2)
- Controlled invariant profiles for measuring algorithm performance
- Easy generation of instances with specific trace/det targets

## 7. Discussion

### 7.1 Limitations

1. **Rank 2**: The current theory is limited to rank-2 lattices. Extension to higher ranks requires different lattice constructions (e.g., from higher-dimensional Pythagorean-like equations or Lorentzian null vectors).

2. **Generator B**: Determinant monotonicity fails for generator B, limiting the class of paths with full invariant control.

3. **Primitivity vs. GL(2,ℤ) reduction**: The "reduction equivalence" in our theory is simpler than full Gauss/LLL reduction equivalence, since our lattices have distinguished bases.

### 7.2 Relation to Prior Work

- **Berggren tree theory** [Berggren 1934, Price 2008]: Our lattice interpretation appears new.
- **Binary quadratic forms** [Gauss, Zagier]: The Gram matrix can be viewed as defining a binary quadratic form; our recognition theorem is a family-specific completeness result.
- **Structured lattices in cryptography** [Micciancio & Regev 2009]: Our work provides a new family of structured instances, distinct from ideal lattices or NTRU lattices.

## 8. Future Work

1. **Rank-3 null-cone lift**: Extend to rank-3 lattices using the natural Lorentzian structure of the Berggren action on $\mathbb{R}^{2,1}$.
2. **Exact Gauss classification**: Classify the reduced Gram forms achievable by Berggren lattices within the Gauss theory of binary quadratic forms.
3. **Tropical monotonicity**: Encode growth rates in a tropical (min-plus) semimodule for simplified analysis.
4. **Cryptographic hardness**: Investigate whether Berggren lattice problems are provably hard, potentially yielding new average-case/worst-case reductions.
5. **Automata model**: Determine whether reduced bases correspond to recognizable path languages in the Berggren tree automaton.

## References

1. B. Berggren, "Pytagoreiska trianglar," *Tidskrift för Elementär Matematik, Fysik och Kemi*, 1934.
2. F.J.M. Barning, "Over pythagorese en bijna-pythagorese driehoeken en een generatieproces met behulp van unimodulaire matrices," *Math. Centrum Amsterdam Afd. Zuivere Wisk.*, ZW-011, 1963.
3. A. Hall, "Genealogy of Pythagorean Triads," *The Mathematical Gazette*, 54(390), 1970.
4. H. Price, "The Pythagorean Tree: A New Species," arXiv:0809.4324, 2008.
5. A.K. Lenstra, H.W. Lenstra Jr., L. Lovász, "Factoring polynomials with rational coefficients," *Mathematische Annalen*, 261, 515–534, 1982.
6. D. Micciancio, O. Regev, "Lattice-based Cryptography," in *Post-Quantum Cryptography*, Springer, 2009.
7. C.F. Gauss, *Disquisitiones Arithmeticae*, 1801.
8. D. Zagier, "Zetafunktionen und quadratische Körper," Springer-Verlag, 1981.
