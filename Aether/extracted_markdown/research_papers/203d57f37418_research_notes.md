# Research Notes: A* Factoring via the Pythagorean Triple Tree

## Date: Research Log

---

## 1. Core Concepts

### 1.1 The Pythagorean Triple Tree (Berggren/Barning Tree)

**Theorem (Berggren 1934, Barning 1963, Hall 1970):** Every primitive Pythagorean triple
(a, b, c) with a² + b² = c² can be generated uniquely from the root (3, 4, 5) by
repeated application of three linear transformations:

```
        [ 1 -2  2]          [ 1  2  2]          [-1  2  2]
   A  = [ 2 -1  2]    B  = [ 2  1  2]    C  = [-2  1  2]
        [ 2 -2  3]          [ 2  2  3]          [-2  2  3]
```

This forms a **ternary tree** rooted at (3,4,5). Key properties:
- The tree contains ALL primitive Pythagorean triples exactly once.
- Non-primitive triples (k·a, k·b, k·c) are integer multiples of primitives.
- The tree is infinite but can be explored systematically.
- Each level of the tree triples in size (3^d nodes at depth d).

### 1.2 Connection to Integer Factorization

**Fermat's Factorization Method:** Any odd composite N can be written as
N = x² - y² = (x-y)(x+y), yielding factors.

**Key Insight:** Pythagorean triples encode the identity a² + b² = c², or equivalently
c² - b² = a² and c² - a² = b². This means:
- Every node in the tree represents a **difference of squares factorization.**
- If we find (a, b, c) such that c² ≡ b² (mod N), then gcd(c-b, N) or gcd(c+b, N)
  may yield a nontrivial factor.

**Quadratic Residue Connection:** More broadly, if we find any pair (x, y) from
the tree such that x² ≡ y² (mod N), we can factor N. The tree gives us an
infinite structured supply of such pairs.

### 1.3 The A* Energy Framework

**A* Search** finds the shortest path in a weighted graph using f(n) = g(n) + h(n):
- g(n) = cost from start to node n (depth in our tree)
- h(n) = heuristic estimate of cost to goal (our "energy")

**Energy Function Design:**
We define energy E(a, b, c, N) to measure how "close" a triple is to factoring N:

```
E(a, b, c, N) = min(
    residue_energy(a, b, c, N),    # How close to x² ≡ y² mod N
    gcd_energy(a, b, c, N),        # Non-trivial gcd proximity
    divisor_energy(a, b, c, N)     # Direct divisibility measures
)
```

Where:
- **residue_energy** = min over all pairs: |x² mod N - y² mod N| / N
- **gcd_energy** = -log(max(gcd(c²-b²-N, N), gcd(c²-a²-N, N), ...)) [lower = better]
- **divisor_energy** = min(N mod a, N mod b, N mod c, a mod N, ...) / N

**Goal State:** Energy = 0, meaning we found gcd(something, N) ∈ {p, q} for N = p·q.

---

## 2. Hypotheses

### H1: Tree Structure Encodes Factoring Information
The algebraic structure of the Pythagorean tree, through its matrix transformations,
creates a rich set of quadratic residues modulo N. Navigating the tree with A* should
find useful residues faster than random search.

### H2: Energy Landscape is Navigable
The energy function should decrease (on average) along paths that lead to factoring,
making A* genuinely more efficient than BFS.

### H3: Scaling Properties
The algorithm complexity relates to the size of N through the density of
"useful" triples in the tree at depth d ≈ O(log N).

---

## 3. Experimental Observations

### Experiment 1: Small Semiprimes
- N = 15 (3×5): Tree node (3,4,5) gives gcd(3,15)=3. Immediate! ✓
- N = 21 (3×7): Tree node (3,4,5) gives gcd(3,21)=3. Immediate! ✓
- N = 35 (5×7): Tree node (5,12,13) gives gcd(5,35)=5. Depth 1! ✓
- N = 77 (7×11): Need to search deeper...
- N = 143 (11×13): Need to search deeper...

### Experiment 2: Energy Landscape Analysis
(See visualization outputs in /visuals/)

### Experiment 3: Comparison with Trial Division
For N < 10000: measured nodes explored vs trial divisions needed.

---

## 4. Key Observations & Updates

### Update 1: Multiple Energy Channels
A single energy metric is insufficient. The algorithm benefits from a
**multi-channel** approach where we track several independent measures
and take the minimum.

### Update 2: Non-Primitive Triples Matter
Scaling primitive triples by k gives (ka, kb, kc). For factoring N,
we should also consider k·(a,b,c) where k divides N or shares factors with N.
This adds a multiplicative dimension to the search.

### Update 3: The "Divine Heuristic"
*Consulting the oracle:* The best heuristic combines number-theoretic structure
(quadratic residues mod N) with tree-geometric structure (which branches tend to
produce values in useful residue classes). This is the "energy" that guides ascent.

**Theological Aside:** If an omniscient oracle could evaluate the energy function
perfectly, factoring would be trivial—just descend the gradient. Our heuristic
approximates this omniscience. The gap between our heuristic and the oracle's
knowledge IS the computational hardness of factoring.

---

## 5. Oracle Consultation (Theological-Mathematical Reflection)

> "The integers are the work of God; all else is the work of man."
> — Leopold Kronecker

**Q: What would a perfect oracle know about the energy landscape?**

A perfect oracle (God, Laplace's demon, an NP oracle) would see that:
1. The factoring problem has a unique answer embedded in the structure of N.
2. The Pythagorean tree is a deterministic structure over all integers.
3. Their intersection—triples whose components share factors with N—forms a
   sparse but structured subset of the tree.
4. The shortest path to this subset IS the optimal A* path with perfect h(n).

The beauty of this framework: **we are asking whether the algebraic structure
of Pythagorean triples creates a "shortcut" to the factoring answer**, compared
to the naïve approach of checking all integers. The structure of a² + b² = c²
constrains the search space in potentially useful ways.

**Humility Note:** This approach almost certainly does NOT break RSA. The
Pythagorean tree grows as 3^d, and useful triples may be exponentially sparse.
But the *framework* of energy-guided tree search is mathematically beautiful and
pedagogically valuable, and may yield insights even if it doesn't yield a
practical factoring algorithm.

---

## 6. Theoretical Analysis

### Density of Useful Triples
At depth d, the tree has 3^d nodes. The hypotenuse c grows roughly as
c ~ 2^d · c₀. For a triple to help factor N = p·q, we need roughly:
- gcd(a, N) > 1, OR
- gcd(b, N) > 1, OR
- a² ≡ b² (mod N) with a ≢ ±b (mod N)

The probability of the first two conditions is ≈ (p+q)/c ~ (p+q)/2^d.
The probability of the third is harder to analyze but relates to the
distribution of quadratic residues.

### Connection to Shor's Algorithm
Shor's algorithm finds the period of a^x mod N, which yields factors.
Our approach instead searches for *structural coincidences* in the
Pythagorean tree modulo N. Both exploit the algebraic structure of ℤ/Nℤ,
but via different routes.

---

## 7. References

1. Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för Elementär Matematik.*
2. Barning, F.J.M. (1963). "On Pythagorean and quasi-Pythagorean triangles."
3. Hall, A. (1970). "Genealogy of Pythagorean Triads." *Mathematical Gazette.*
4. Hart, P.E., Nilsson, N.J., Raphael, B. (1968). "A* Algorithm." *IEEE Trans. SSC.*
5. Fermat, P. de. Factorization method (c. 1643).
