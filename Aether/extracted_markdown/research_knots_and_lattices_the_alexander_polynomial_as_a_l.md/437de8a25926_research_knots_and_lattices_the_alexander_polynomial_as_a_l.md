# The Alexander Polynomial as a Lattice Path Generating Function

## Abstract

We develop a formal theory of lattice paths in ℤ², focusing on their area statistics and algebraic structure. We prove three main results: (1) the **Area Complement Theorem**, establishing that the area of a lattice path plus the area of its step-complement equals the product of the step counts; (2) the **Area Shift Lemma**, showing that height offsets contribute linearly to the area with coefficient equal to the East step count; and (3) the **Path Count Theorem**, confirming that the number of lattice paths from (0,0) to (m,n) equals the binomial coefficient C(m+n, n). We introduce the novel concept of a **Knot Lattice** — a lattice path framework enriched with forbidden regions derived from knot diagrams — and conjecture that the Alexander polynomial of any knot equals the area-weighted generating function of valid paths in its knot lattice. All core theorems have been formally verified in Lean 4 with Mathlib.

**Keywords**: lattice paths, Alexander polynomial, knot invariants, q-binomial coefficients, area statistics, generating functions

## 1. Introduction

The Alexander polynomial Δ_K(t), introduced by Alexander in 1928, is a Laurent polynomial invariant of oriented knots and links. Classically computed from the presentation matrix of the knot group's commutator subgroup, it encodes fundamental topological information: the degree gives a lower bound on the knot genus, the polynomial evaluated at −1 gives the determinant of the knot, and its symmetry Δ_K(t) = Δ_K(t⁻¹) reflects the duality of the Seifert form.

Lattice paths — sequences of East (+1,0) and North (0,+1) steps in ℤ² — are among the most studied objects in enumerative combinatorics. Their counting theory, governed by binomial coefficients and their q-analogs, connects to partitions, Young tableaux, symmetric functions, and representation theory.

In this paper, we establish rigorous foundations for the area statistics of lattice paths and introduce a framework that connects these combinatorial objects to knot invariants. Our main contributions are:

1. A complete formal treatment of lattice path area, including the area shift lemma and the area complement theorem.
2. The definition of the **Knot Lattice** structure, which encodes knot diagram data as constraints on lattice paths.
3. A precise conjecture relating the Alexander polynomial to lattice path generating functions, with testable computational predictions.

## 2. Definitions

### 2.1 Lattice Paths

**Definition 2.1** (Lattice Step). A *lattice step* is either East (E) or North (N), corresponding to the vectors (+1,0) and (0,+1) in ℤ².

**Definition 2.2** (Lattice Path). A *lattice path* is a finite sequence p = (s₁, s₂, ..., s_ℓ) of lattice steps. We write countE(p) and countN(p) for the number of East and North steps, respectively. The path travels from (0,0) to (countE(p), countN(p)).

**Definition 2.3** (Area). The *area* of a lattice path is computed by the auxiliary function:

    areaAux(h, []) = 0
    areaAux(h, E :: p) = h + areaAux(h, p)
    areaAux(h, N :: p) = areaAux(h+1, p)

with area(p) = areaAux(0, p). Intuitively, each East step at height h contributes h unit squares to the area.

**Definition 2.4** (Step Complement). The *step complement* of a path p, denoted swap(p), is obtained by replacing each E with N and each N with E. If p goes from (0,0) to (m,n), then swap(p) goes from (0,0) to (n,m).

### 2.2 Knot Lattice

**Definition 2.5** (Knot Lattice). A *Knot Lattice* K consists of:
- A positive integer n (the crossing number)
- A Boolean predicate isForbidden : ℕ × ℕ → Bool on grid positions
- A function writheSigns : Fin(n) → {-1, +1} assigning signs to crossings

A lattice path p is *valid* in K if none of the positions visited by p (starting from the origin) are forbidden.

### 2.3 Path Counting

**Definition 2.6** (Path Count). The function pathCount(m, n) counts lattice paths from (0,0) to (m,n):

    pathCount(m, 0) = 1
    pathCount(0, n) = 1
    pathCount(m+1, n+1) = pathCount(m, n+1) + pathCount(m+1, n)

## 3. Main Results

### 3.1 Area Shift Lemma

**Theorem 3.1** (Area Shift). For any height h ∈ ℕ and lattice path p:

    areaAux(h, p) = areaAux(0, p) + h · countE(p)

*Proof sketch.* By induction on p. The base case is trivial. For the East step case, we use the inductive hypothesis to decompose the recursive call, then verify the algebra. For the North step case, we apply the inductive hypothesis with height h+1 and again with height 1, reducing to arithmetic. □

This lemma has a clean combinatorial interpretation: starting at height h means every East step sees h additional unit squares below it. Since there are countE(p) East steps, the total additional area is h · countE(p).

**Corollary 3.2** (Q-Binomial Recurrence). The area-weighted generating function

    Q(m, n; q) = Σ_{paths p from (0,0) to (m,n)} q^{area(p)}

satisfies the recurrence:

    Q(m+1, n+1; q) = Q(m, n+1; q) + q^{m+1} · Q(m+1, n; q)

This follows from the first-step decomposition combined with the area shift lemma: if the first step is North, subsequent East steps are at height ≥ 1, adding m+1 to the area exponent (one for each of the m+1 remaining East steps).

### 3.2 Area Bound

**Theorem 3.3** (Area Bound). For any height h and path p:

    areaAux(h, p) ≤ (h + countN(p)) · countE(p)

*Proof sketch.* Induction on p. The East case uses the fact that the current height h is at most h + countN(rest), and the North case follows directly from the inductive hypothesis with h+1. □

Setting h = 0: **area(p) ≤ countN(p) · countE(p)**, i.e., the area of any lattice path fits within the bounding rectangle.

### 3.3 Area Complement Theorem

**Theorem 3.4** (Area Complement, Generalized). For any heights h, k ∈ ℕ and path p:

    areaAux(h, p) + areaAux(k, swap(p)) = h · countE(p) + k · countN(p) + countE(p) · countN(p)

*Proof sketch.* By induction on p, generalizing h and k. The key insight is the pair-counting argument: each pair (East step at position i, North step at position j) contributes 1 to exactly one of the two area computations, depending on their relative order. The total number of pairs is countE(p) · countN(p). □

**Corollary 3.5** (Area Complement). Setting h = k = 0:

    area(p) + area(swap(p)) = countE(p) · countN(p)

This identity is the combinatorial manifestation of the palindromic symmetry of the Gaussian binomial coefficient. It implies that the generating function Q(m, n; q) satisfies Q(m, n; q) = q^{mn} · Q(m, n; q⁻¹), which mirrors the symmetry Δ_K(t) = Δ_K(t⁻¹) of the Alexander polynomial.

### 3.4 Path Count Theorem

**Theorem 3.6** (Path Count). For all m, n ∈ ℕ:

    pathCount(m, n) = C(m+n, n)

*Proof sketch.* Double induction on m and n. The base cases pathCount(m, 0) = 1 = C(m, 0) and pathCount(0, n) = 1 = C(n, n) are immediate. The inductive step uses Pascal's rule: pathCount(m+1, n+1) = pathCount(m, n+1) + pathCount(m+1, n) = C(m+n+1, n+1) + C(m+n+1, n) = C(m+n+2, n+1). □

### 3.5 Unknot Validity

**Theorem 3.7**. All lattice paths are valid in the unknot lattice (which has no forbidden positions).

## 4. The Knot Lattice Conjecture

**Conjecture 4.1** (Lattice Path Alexander). For every oriented knot K with n crossings, there exists a Knot Lattice K_L with n crossings such that:

    Δ_K(t) = Σ_{valid paths p in K_L} (-1)^{w(p)} · t^{area(p)}

where w(p) is a writhe contribution determined by which forbidden regions the path's area intersects.

**Testable Prediction**: For the trefoil knot (3₁), with Alexander polynomial t⁻¹ − 1 + t, the knot lattice has crossings = 3 and forbidden positions at (1,2) and (2,1). The 20 lattice paths from (0,0) to (3,3), filtered by this forbidden region and weighted appropriately, should yield the trefoil's Alexander polynomial.

## 5. Algorithms

### 5.1 Area Computation

```
function area(path):
    h = 0
    total = 0
    for step in path:
        if step == E:
            total += h
        else:
            h += 1
    return total
```

Time complexity: O(|path|). Space: O(1).

### 5.2 Path Enumeration

```
function enumerate_paths(m, n):
    if m == 0: yield [N]*n
    elif n == 0: yield [E]*m
    else:
        for p in enumerate_paths(m-1, n):
            yield [E] + p
        for p in enumerate_paths(m, n-1):
            yield [N] + p
```

Generates all C(m+n, n) paths. Time: O(C(m+n, n) · (m+n)).

### 5.3 Generating Function Computation

```
function q_binomial(m, n):
    poly = {area(p): count for p in enumerate_paths(m, n)}
    return poly
```

## 6. Discussion

### 6.1 Relation to Existing Work

The connection between the Alexander polynomial and combinatorics has been explored from several angles:

- **State sums**: Kauffman's state sum model expresses Δ_K(t) as a sum over states of a knot diagram, where each state is weighted by a product of local contributions. Our lattice path formulation can be viewed as a geometric realization of these states.

- **Matrix-tree theorem**: The Alexander polynomial is a determinant of the Dehn matrix, and the Lindström-Gessel-Viennot (LGV) lemma expresses determinants as signed sums over non-intersecting lattice path families. This provides a potential mechanism for the knot-to-lattice-path translation.

- **Partition functions**: The generating function Q(m, n; q) is the Gaussian binomial [m+n choose n]_q, which appears in the representation theory of quantum groups — the same algebraic structures that produce quantum knot invariants.

### 6.2 Implications

If Conjecture 4.1 holds, several consequences follow:

1. **Algorithmic**: The Alexander polynomial becomes computable by lattice path enumeration, potentially leading to new algorithms for large knots.

2. **Structural**: The palindromic symmetry Δ_K(t) = Δ_K(t⁻¹) would follow from the area complement theorem, providing a combinatorial proof of a topological fact.

3. **Generalization**: The framework naturally extends to higher-dimensional lattice paths, potentially connecting to colored Alexander polynomials and multivariable generalizations.

## 7. Formal Verification

All theorems in Sections 3.1–3.5 have been formally verified in Lean 4 using the Mathlib library. The formalization comprises approximately 300 lines of Lean code, with key definitions and theorems organized in the `LPath` namespace. All proofs use only standard axioms (propext, Classical.choice, Quot.sound).

The formal verification process revealed several subtleties:
- The area shift lemma requires careful generalization over the height parameter before induction.
- The complement theorem requires simultaneous generalization over two height parameters.
- The path count theorem relies on Mathlib's `Nat.choose_succ_succ` (Pascal's rule).

## 8. Future Work

1. **Computational verification**: Systematically test Conjecture 4.1 for all prime knots through 10 crossings.
2. **LGV connection**: Formalize the Lindström-Gessel-Viennot lemma and use it to connect knot matrices to lattice path determinants.
3. **Q-analog theory**: Formalize the Gaussian binomial coefficient as a polynomial and prove its recurrence from the area shift lemma.
4. **Higher invariants**: Extend the framework to the Jones polynomial using lattice paths with more complex step sets.

## References

1. Alexander, J.W. (1928). "Topological invariants of knots and links." *Transactions of the AMS*, 30(2), 275–306.
2. Kauffman, L.H. (1983). "Formal Knot Theory." *Mathematical Notes*, Princeton University Press.
3. Lindström, B. (1973). "On the vector representations of induced matroids." *Bull. London Math. Soc.*, 5, 85–90.
4. Gessel, I., Viennot, G. (1985). "Binomial determinants, paths, and hook length formulae." *Advances in Mathematics*, 58(3), 300–321.
5. Cromwell, P. (2004). *Knots and Links*. Cambridge University Press.
6. Stanley, R. (2012). *Enumerative Combinatorics*, Volume 1, 2nd ed. Cambridge University Press.
