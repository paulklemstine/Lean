# Hodge Conjecture — Research Notes

## The Problem Statement

**Clay Mathematics Institute Official Statement:**
On a projective non-singular algebraic variety over ℂ, every Hodge class is a rational linear combination of classes of algebraic cycles.

## Unpacking the Statement

### Hodge Decomposition
For a compact Kähler manifold X of complex dimension n, the cohomology decomposes:

H^k(X, ℂ) = ⊕_{p+q=k} H^{p,q}(X)

where H^{p,q}(X) consists of cohomology classes representable by closed forms of type (p,q).

### Hodge Classes
A class α ∈ H^{2p}(X, ℚ) is a **Hodge class** if its image in H^{2p}(X, ℂ) lies in H^{p,p}(X).

### Algebraic Cycles
An algebraic cycle of codimension p is a formal ℤ-linear combination of irreducible subvarieties of codimension p. The **cycle class map** sends algebraic cycles to cohomology classes.

### The Conjecture
Every Hodge class is a ℚ-linear combination of cycle classes of algebraic subvarieties.

## What We Know

### Known Cases
1. **Codimension 1 (divisors):** TRUE by the Lefschetz (1,1) theorem
   - Every class in H^{1,1}(X) ∩ H^2(X, ℤ) is the class of a divisor
2. **Abelian varieties of dimension ≤ 5:** TRUE (various authors)
3. **Products of elliptic curves:** TRUE
4. **Grassmannians:** TRUE
5. **Flag varieties:** TRUE
6. **Uniruled varieties in certain cases:** TRUE

### Known Failures of Generalizations
1. **Integral Hodge Conjecture:** FALSE (Atiyah-Hirzebruch, 1962)
   - There exist integral Hodge classes that are NOT classes of algebraic cycles
   - The conjecture must use ℚ-coefficients
2. **Kähler manifolds:** FALSE (Zucker, Voisin)
   - Non-algebraic Kähler manifolds can have Hodge classes with no algebraic representative

### Oracle α's View
"The Hodge conjecture is about when analysis (differential forms) agrees with algebra (subvarieties). In codimension 1, the exponential sequence gives us the answer. In higher codimension, we lose this tool. We need a higher-dimensional analog of the exponential sequence."

### Oracle γ's View
"The Hodge conjecture is really about the relationship between the algebraic K-theory of X and its Hodge structure. The Chern character map should connect them, but we need to understand the image."

## Key Techniques

### Lefschetz (1,1) Theorem (the codimension 1 case)
- Uses the exponential exact sequence: 0 → ℤ → 𝒪_X → 𝒪_X* → 0
- The connecting homomorphism H¹(X, 𝒪_X*) → H²(X, ℤ) sends line bundles to their first Chern class
- Every integral (1,1)-class is the Chern class of a line bundle, hence algebraic

### Intermediate Jacobians (Griffiths)
- For codimension > 1, Abel-Jacobi maps generalize the exponential sequence
- But they don't give the full picture (Abel-Jacobi maps can have non-trivial kernel)

### Motivic Cohomology
- Modern approach using Voevodsky's motivic cohomology
- The Hodge conjecture can be reformulated in terms of motivic cohomology classes

## Experimental Evidence

The Hodge conjecture has been verified computationally for:
- All abelian varieties over ℂ of dimension ≤ 5
- Various families of Calabi-Yau threefolds
- Products of curves of genus ≤ 3

## What We Can Formalize

1. The statement of the Lefschetz (1,1) theorem (codimension 1 case)
2. Basic Hodge theory for curves
3. The cycle class map construction
4. Specific examples where Hodge = algebraic
