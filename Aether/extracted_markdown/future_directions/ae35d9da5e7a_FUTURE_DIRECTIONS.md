# Future Directions: Pythagorean Lattice Reduction for Integer Factoring

## Overview

This document outlines 5 concrete next research targets opened by the formalized bridge between Berggren dynamics, Pythagorean lattice geometry, and integer factoring. Each direction is specified with enough precision that a research team can pursue it with clear hypotheses and strategies.

---

## Direction 1: Sufficient Geometric Conditions for Factor-Revealing Shortest Vectors

**Goal**: Prove that for semiprimes $n = pq$ with $p, q$ of similar size, every shortest nonzero vector in the Berggren congruence lattice $L_n$ is factor-revealing.

**Hypothesis**: When $n = pq$ with $p/q \in [1/2, 2]$, the shortest vector $v$ in $L_n$ satisfies $\gcd(n, |v_0 - v_1|) \notin \{1, n\}$ with probability $\geq 1/2$ over choices of congruence class.

**Proof Strategy**:
1. Show that vectors arising from the factorization $n = pq$ via the Euclid parametrization have $\ell^1$-norm $O(\sqrt{n})$.
2. Prove a lower bound on the shortest vector length for vectors where $\gcd(n, |v_0 - v_1|) \in \{1, n\}$.
3. If the gap between these bounds is positive, the shortest vector must be factor-revealing.

**Lean Target**:
```lean
theorem semiprime_shortest_vector_factor_revealing
    (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q) (hpq : p ≤ q) (hbound : q ≤ 2 * p)
    (v : Fin 3 → ℤ)
    (hv : v ∈ BerggrenLatticeSet (p * q))
    (hmin : ∀ w ∈ BerggrenLatticeSet (p * q), w ≠ 0 → tripleNorm v ≤ tripleNorm w)
    (hpyth : PrimitiveTriple v) :
    FactorRevealing (p * q) v
```

**Cross-Domain**: Connects to the geometry of numbers (Minkowski bounds), lattice basis reduction theory, and cryptanalytic hardness assumptions for RSA.

---

## Direction 2: Berggren Semigroup Inside the Orthogonal Group of $x^2 + y^2 - z^2$

**Goal**: Formalize the Berggren matrices as elements of the integral orthogonal group $O(Q, \mathbb{Z})$ for the indefinite ternary quadratic form $Q(x,y,z) = x^2 + y^2 - z^2$, and characterize the semigroup they generate.

**Hypothesis**: The three Berggren generators $A, B, C$ generate a free semigroup of index $\leq 6$ in the group of $Q$-automorphisms preserving the positive cone $\{(a,b,c) : a,b,c > 0\}$.

**Proof Strategy**:
1. Formalize $Q$ as a `QuadraticForm ℤ (Fin 3 → ℤ)`.
2. Show $M^T Q M = Q$ for each Berggren matrix $M$, establishing membership in $O(Q, \mathbb{Z})$.
3. Prove the semigroup is free by showing word lengths are strictly increasing under the tree ordering.
4. Compute the index by analyzing cosets in the positive-cone stabilizer.

**Lean Target**:
```lean
def lorentzForm : QuadraticForm ℤ (Fin 3 → ℤ) := ...

theorem berggren_preserves_form (g : Fin 3) :
    ∀ v, lorentzForm (BerggrenStep g v) = lorentzForm v
```

**Cross-Domain**: Connects to arithmetic groups, reduction theory for indefinite forms, and the Oppenheim conjecture tradition in homogeneous dynamics.

---

## Direction 3: Binary Quadratic Forms and Class Group Methods

**Goal**: Connect Pythagorean-lattice witnesses to the theory of binary quadratic forms and class group computation, creating a bridge between the Berggren tree and Gauss composition.

**Hypothesis**: A primitive Pythagorean triple $(a, b, c)$ with $c^2 \equiv a^2 \pmod{n}$ naturally produces a binary quadratic form of discriminant $-4n$ (or a related discriminant) whose class in the form class group encodes the factorization.

**Proof Strategy**:
1. From $a^2 + b^2 = c^2$ and $n | (a^2 - b^2)$, construct the form $f(x,y) = nx^2 + 2bxy + \frac{b^2 - a^2}{n}y^2$.
2. Show this form has discriminant $4a^2$ and is properly equivalent to a reduced form.
3. Prove that the class of this form determines a nontrivial element of $\text{Cl}(\Delta)$ when $n$ is composite.
4. Connect form reduction to lattice basis reduction on the associated lattice.

**Cross-Domain**: Creates an interface between Shanks' class group method, the Berggren tree, and modern lattice-based approaches. Could lead to new subexponential factoring strategies.

---

## Direction 4: Verified Bounded Berggren Orbit Search Algorithm

**Goal**: Design, implement, and formally verify an algorithm that searches bounded Berggren orbits for congruences of squares, with proven completeness and complexity bounds.

**Hypothesis**: For any composite $n$, a breadth-first search of the Berggren tree up to depth $O(\log^2 n)$ produces a factor-revealing triple with constant probability.

**Proof Strategy**:
1. Formalize the Berggren tree as a `RBTree`-indexed structure with depth tracking.
2. Prove that the number of triples at depth $d$ is $3^d$ and their hypotenuses grow as $\Theta(\lambda^d)$ where $\lambda \approx 2 + \sqrt{3}$.
3. Show that among triples with hypotenuse $\leq N$, a positive proportion satisfy the congruence condition modulo $n$ by character sum estimates.
4. Convert the existence proof into a verified search algorithm with `DecidableEq` on the relevant quotient.

**Lean Target**:
```lean
def berggrenBFS (n : ℕ) (depth : ℕ) : List (Fin 3 → ℤ) := ...

theorem berggrenBFS_complete (n : ℕ) (hn : 1 < n) (hn_composite : ¬ Nat.Prime n) :
    ∃ d : ℕ, ∃ v ∈ berggrenBFS n d,
      EncodesCongruenceOfSquares n v ∧ PrimitiveTriple v
```

**Cross-Domain**: Connects to verified algorithm design, automata on trees, and experimental number theory. The depth bound connects to equidistribution on the modular group.

---

## Direction 5: Hidden Subgroup / Period-Finding Structure for Quantum Speedup

**Goal**: Investigate whether the Berggren lattice constraints admit a hidden subgroup problem (HSP) or period-finding formulation that enables genuine quantum speedup over classical lattice reduction.

**Hypothesis**: The congruence condition $n | (v_0^2 - v_1^2)$ on the Berggren orbit defines a subgroup of $(\mathbb{Z}/n\mathbb{Z})^* \times (\mathbb{Z}/n\mathbb{Z})^*$ that is hidden with respect to the Berggren group action, and its recovery via quantum Fourier transform on the Berggren tree graph yields a factor of $n$.

**Proof Strategy**:
1. Define the group $G$ generated by Berggren matrices modulo $n$, acting on $(\mathbb{Z}/n\mathbb{Z})^3$.
2. Characterize the stabilizer of the congruence condition as a subgroup $H \leq G$.
3. Show that recovery of $H$ from oracle access to the $G$-action constitutes an instance of the HSP.
4. Prove that the quantum Fourier transform on $G$ distinguishes cosets of $H$ with inverse-polynomial probability.
5. Establish that recovery of $H$ yields a congruence of squares and hence a factor.

**Lean Target (Conditional)**:
```lean
theorem quantum_berggren_factoring
    (HSP_solver : ∀ (G : Type) [Group G] [Fintype G] (H : Subgroup G),
      H)  -- abstract oracle
    (n : ℕ) (hn : 1 < n) (hn_composite : ¬ Nat.Prime n) :
    ∃ d : ℕ, d ∣ n ∧ d ≠ 1 ∧ d ≠ n
```

**Cross-Domain**: This is the most speculative direction but potentially the most impactful. It would establish a genuinely new quantum factoring approach distinct from Shor's algorithm, potentially with different circuit depth characteristics. Connects to quantum walks on Cayley graphs, non-abelian HSP, and quantum computational group theory.

---

## Implementation Priority

1. **Direction 1** (Geometric gap conditions) — Highest mathematical payoff, most tractable in Lean.
2. **Direction 4** (Verified search algorithm) — Most computationally concrete, enables experimental validation.
3. **Direction 2** (Orthogonal group embedding) — Foundational for the theory, connects to established mathematics.
4. **Direction 3** (Class group bridge) — Novel connection, moderate difficulty.
5. **Direction 5** (Quantum HSP) — Most speculative, requires careful formulation to avoid overclaiming.

---

## Team Directive

Each direction should be pursued by a sub-team with:
- A **formalization lead** responsible for Lean code and proof architecture.
- A **mathematical lead** responsible for proof strategy and correctness.
- A **computational lead** responsible for experiments, benchmarks, and algorithm implementation.

Teams should share results weekly and cross-pollinate: insights from Direction 2 (group structure) inform Direction 5 (quantum), while Direction 4 (algorithms) validates conjectures from Direction 1 (geometry).
