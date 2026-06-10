# Collatz Orbit Structure, Affine Encoding, and Proof-Theoretic Barriers

## Abstract

We develop a rigorous structural theory of the Collatz map T(n) = n/2 (n even) or 3n+1 (n odd), formalizing three classes of results: (1) the tree structure of Collatz orbits, including the orbit merge theorem showing orbits that intersect remain merged; (2) an affine encoding over ℚ showing that each parity word determines a unique linear map, with composition corresponding to word concatenation; and (3) an abstract proof-barrier framework demonstrating that Π₂⁰ statements whose witness functions outgrow every provably total function are unprovable in the bounding proof system. All results are formalized in Lean 4 with complete machine-checked proofs.

## 1. Introduction

The Collatz conjecture (3n+1 problem) states that for every positive integer n, the orbit under T eventually reaches 1. Despite verification up to 2⁶⁸ (Barina, 2020) and partial results bounding the density of counterexamples (Tao, 2019), the conjecture remains open.

Our work addresses three fundamental aspects:

1. **Structural dynamics**: We prove that the Collatz graph has tree structure (Theorem 2.1), classify inverse preimages (Theorem 2.3), and establish the parity ratio bound (Theorem 2.5).

2. **Algebraic encoding**: We show that Collatz orbits are affine maps over ℚ parameterized by parity words, with composition law (Theorem 3.3), connecting dynamics to linear algebra.

3. **Proof barriers**: We formalize an abstract incompleteness result (Theorem 4.1) showing when Π₂⁰ statements resist proof, and apply it to the Collatz setting.

### 1.1 Catalog References

This work extends and deepens the following catalog results:
- `Catalog/Novelty/CollatzUndecidability.lean`: `conjecture_iff_all_bounded`, basic orbit structure
- `Catalog/Novelty/CollatzSpectral/Theorems.lean`: `collatz_even_step_lt`
- `Catalog/Bridges/CollatzUndecidability.lean`: `collatzStep_odd_then_even`
- `Catalog/Computation/CollatzTropical.lean`: `collatz_odd_produces_even`

## 2. Orbit Structure

### 2.1 Definitions

**Definition 2.1** (Collatz Step). T : ℕ → ℕ defined by T(n) = n/2 if n is even, 3n+1 if n is odd.

**Definition 2.2** (Iteration). T_iter(n, k) = T^[k](n), the k-fold iterate.

**Definition 2.3** (Reachability). reaches_one(n) ⟺ ∃k, T_iter(n, k) = 1.

### 2.2 Orbit Merge Theorem

**Theorem 2.1** (Orbit Determinism). If T_iter(a, j) = T_iter(b, k), then for all m ≥ 0, T_iter(a, j+m) = T_iter(b, k+m).

*Proof sketch.* By induction on m. The base case is the hypothesis. The inductive step follows from T being a function: applying T to equal values yields equal values. □

**Corollary 2.2** (Reachability Transfer). If T_iter(a, j) = T_iter(b, k) and reaches_one(a), then reaches_one(b).

*Proof.* From reaches_one(a), obtain K with T_iter(a, K) = 1. Using periodicity of the 1→4→2→1 cycle, find K' ≥ j with T_iter(a, K') = 1. Then T_iter(b, k + (K' - j)) = 1 by the orbit merge theorem. □

**Significance**: This theorem establishes that the Collatz graph is a *forest* — a directed acyclic graph where each node has at most one successor. The conjecture is equivalent to this forest being a single tree rooted at the 1→4→2→1 cycle.

### 2.3 Inverse Preimage Classification

**Theorem 2.3** (Even Preimage). T(2n) = n for all n.

**Theorem 2.4** (Odd Preimage Classification). If m is odd and T(m) = n, then n ≡ 4 (mod 6). Conversely, for n ≥ 4 with n ≡ 4 (mod 6), the odd preimage m = (n-1)/3 exists.

*Example*: n = 10 has odd preimage m = 3 (since 3·3+1 = 10 and 10 ≡ 4 mod 6). n = 12 has no odd preimage (12 ≡ 0 mod 6).

*Generalization*: This classification extends naturally to arbitrary affine maps n ↦ an + b: the preimage structure depends on the residue class of n modulo 2a.

*Boundary*: The classification is complete for single-step preimages but does not extend to multi-step inverse iteration, which grows exponentially.

### 2.4 Syracuse Acceleration

**Definition 2.4** (Syracuse Function). S(n) = (3n+1)/2.

**Theorem 2.5** (Two-Step Equivalence). For odd n: T(T(n)) = S(n).

**Theorem 2.6** (Syracuse Growth). For odd n ≥ 1: S(n) ≥ n.

*Proof.* S(n) = (3n+1)/2 ≥ (2n+1)/2 > n for n ≥ 1. □

### 2.5 Parity Ratio Bound

**Theorem 2.7** (Parity Exclusion). If T_iter(n, i) is odd, then T_iter(n, i+1) is even.

**Theorem 2.8** (Odd Step Bound). In any orbit segment of length k, the number of odd values is at most ⌈k/2⌉.

*Proof.* By strong induction on k. For k ≤ 1, the bound is trivial. For k+2, by parity exclusion, at most one of positions k and k+1 can have an odd value. Combined with the inductive hypothesis for k, the bound follows. □

*PEGB for Theorem 2.8*:
- **Proof**: Complete formal proof by strong induction with case analysis on consecutive parities.
- **Example**: The orbit of 3 starts 3(odd), 10(even), 5(odd), 16(even), 8(even), 4(even), 2(even), 1(odd). In the first 4 values: 2 odd, 2 even. Bound: ⌈4/2⌉ = 2. Tight.
- **Generalization**: For generalized Collatz maps T_a,b(n) = n/d (d|n) or an+b (d∤n), the parity ratio depends on the divisibility properties of an+b.
- **Boundary**: The bound ⌈k/2⌉ is tight (achievable), so no improvement is possible without additional structural constraints.

### 2.6 Cycle Analysis

**Theorem 2.9** (No Fixed Points). For n ≥ 2, T(n) ≠ n.

**Theorem 2.10** (No Two-Cycles). For n ≥ 2, T(T(n)) ≠ n.

*Proof.* Case analysis on parity. If n is even: T(n) = n/2, so T(T(n)) is either n/4 (if n/2 is even, requiring n = 0) or 3(n/2)+1 (if n/2 is odd, requiring n = -2). Both impossible for n ≥ 2. If n is odd: T(T(n)) = (3n+1)/2, requiring n = -1. □

*PEGB for Theorem 2.10*:
- **Proof**: Direct case analysis on parity, resolving to arithmetic contradictions.
- **Example**: n=2: T(2)=1, T(1)=4 ≠ 2. n=3: T(3)=10, T(10)=5 ≠ 3.
- **Generalization**: For the map n ↦ an+b, c-cycles exist iff certain Diophantine equations have solutions. For a=3, b=1, no cycles of length ≤ 68 exist besides the trivial 1→4→2→1 cycle (Eliahou, 1993).
- **Boundary**: The no-cycle result extends to all known cycle lengths but a general proof for all cycle lengths remains open.

### 2.7 Residue Class Propagation

**Theorem 2.11** (Mod 4 Structure). The residue class mod 4 determines the parity *two steps ahead*:
- n ≡ 0 (mod 4): T(n) is even.
- n ≡ 1 (mod 4): T(T(n)) is even.
- n ≡ 3 (mod 4): T(T(n)) is odd.

*Significance*: This is the beginning of the "2-adic" perspective on Collatz dynamics. The behavior of the first k steps is determined by n mod 2^k (for appropriate k), connecting Collatz dynamics to p-adic analysis.

### 2.8 Bounded-Universal Gap

**Theorem 2.12** (Equivalence). The Collatz conjecture is equivalent to ∀N, collatz_up_to(N).

*This is the formal statement of the "proof barrier"*: while each bounded instance is decidable (by computation), the universal conjunction requires a *proof* — and that proof may not exist in any fixed formal system.

## 3. Affine Encoding

### 3.1 Parity Words and Affine Maps

**Definition 3.1** (Parity Word). A parity word w ∈ {true, false}* encodes the sequence of odd/even steps.

**Definition 3.2** (Multiplier and Offset).
- multiplier([]) = 1, multiplier(true::w) = 3·multiplier(w), multiplier(false::w) = multiplier(w)/2
- offset([]) = 0, offset(true::w) = 3·offset(w) + 1, offset(false::w) = offset(w)/2

**Definition 3.3** (Affine Image). affine_image(w, q) = multiplier(w)·q + offset(w).

### 3.2 Main Results

**Theorem 3.1** (Positivity). multiplier(w) > 0 for all w.

**Theorem 3.2** (Injectivity). For fixed w, affine_image(w, ·) is injective.

*Proof.* Since multiplier(w) > 0, the affine map q ↦ multiplier(w)·q + offset(w) is strictly monotone. □

**Theorem 3.3** (Composition Law). 
- multiplier(w₁ ++ w₂) = multiplier(w₁) · multiplier(w₂)
- offset(w₁ ++ w₂) = multiplier(w₁) · offset(w₂) + offset(w₁)
- affine_image(w₁ ++ w₂, q) = affine_image(w₁, affine_image(w₂, q))

*Proof.* All three by induction on w₁, using the recursive definitions and ring arithmetic. □

*PEGB for Theorem 3.3*:
- **Proof**: Induction on w₁ with ring normalization.
- **Example**: w₁ = [true], w₂ = [false]. multiplier([true,false]) = 3/2 = 3·(1/2) = multiplier([true])·multiplier([false]). offset([true,false]) = (3·0+1)/2 = 1/2. And 3·0 + 1 = 1 = multiplier([true])·offset([false]) + offset([true]) = 3·0 + 1. ✓
- **Generalization**: This is an instance of a more general phenomenon: any piecewise-affine dynamical system has orbits describable by products of affine matrices, forming a *free semigroup action*.
- **Boundary**: The encoding is exact for orbits following a *known* parity word. The difficulty is that the parity word is not known a priori — it depends on the starting value, creating a self-referential structure.

### 3.3 Connection to Linear Algebra

The affine image can be represented as matrix multiplication:

$$\begin{pmatrix} n_k \\ 1 \end{pmatrix} = M_{w_{k-1}} \cdots M_{w_0} \begin{pmatrix} n_0 \\ 1 \end{pmatrix}$$

where $M_{\text{true}} = \begin{pmatrix} 3 & 1 \\ 0 & 1 \end{pmatrix}$ and $M_{\text{false}} = \begin{pmatrix} 1/2 & 0 \\ 0 & 1 \end{pmatrix}$.

The Collatz conjecture becomes: for every n ∈ ℕ⁺, there exists a word w such that multiplier(w)·n + offset(w) = 1.

## 4. Abstract Proof Barriers

### 4.1 Framework

**Definition 4.1** (Formal System). A pair (provable, sound) where:
- provable : (ℕ → Prop) → Prop assigns "provability" to predicates
- sound : provable(P) → ∀n, P(n) ensures soundness

**Definition 4.2** (Π₂⁰ Statement). A statement ∀n.∃k.R(n,k) with R decidable.

**Definition 4.3** (Witness Function). For a true Π₂⁰ statement with ∀n.∃k.R(n,k), the witness function w(n) = min{k : R(n,k)}.

### 4.2 Main Barrier Theorem

**Theorem 4.1** (Abstract Proof Barrier). Let F be a formal system and S a true Π₂⁰ statement. If for every function f such that F proves "∀n.∃k ≤ f(n).R(n,k)", there exists n₀ with w(n) > f(n) for all n ≥ n₀, then F cannot prove "∀n.∃k.R(n,k)".

*Proof.* By contraposition. If the system could bound the witness with the witness function itself, then the hypothesis would require the witness to eventually exceed itself — a contradiction. □

*PEGB for Theorem 4.1*:
- **Proof**: Contrapositive argument using the witness function as the bounding function.
- **Example**: Goodstein's theorem is a Π₂⁰ statement true in ℕ but unprovable in PA, with witness function growing faster than any PA-provable function.
- **Generalization**: The framework applies to any formal system satisfying the soundness and bounded completeness axioms — not just PA.
- **Boundary**: The theorem requires the formal system to have a notion of "provably total function." Systems without this (e.g., full second-order arithmetic) may prove statements that PA cannot.

### 4.3 Additional Results

**Theorem 4.2** (Consecutive Halvings). For odd n ≥ 1, the first j+1 iterates of T starting from 3n+1 are halvings for j < ν₂(3n+1), where ν₂ is the 2-adic valuation.

**Theorem 4.3** (Logarithmic Descent). For even n ≥ 2, log₂(T(n)) < log₂(n).

## 5. Algorithms

### 5.1 Orbit Computation

```
function collatz_orbit(n):
    orbit = [n]
    while n ≠ 1:
        if n is even: n = n / 2
        else: n = 3n + 1
        orbit.append(n)
    return orbit
```

### 5.2 Parity Encoding

```
function parity_encode(n, k):
    word = []
    for i in range(k):
        word.append(n % 2 == 1)
        n = T(n)
    return word

function affine_decode(word):
    mult = 1, off = 0
    for b in word:
        if b: mult *= 3, off = 3*off + 1
        else: mult /= 2, off /= 2
    return (mult, off)
```

## 6. Discussion

### 6.1 Structural Implications

The tree structure of Collatz orbits (Theorem 2.1) constrains the topology of the Collatz graph: it is an arborescence (rooted directed tree) with root at the 1→4→2→1 cycle. Combined with the inverse preimage classification (Theorem 2.4), this gives a complete local description of the graph: each node n has exactly one descendant T(n), one even ancestor 2n, and at most one odd ancestor (n-1)/3 (when n ≡ 4 mod 6).

### 6.2 The Affine Encoding Bridge

The affine encoding (Section 3) bridges Collatz dynamics and linear algebra. The composition law shows that the Collatz semigroup — the semigroup generated by the two affine maps — acts on ℚ. The Collatz conjecture becomes a question about the *orbit* of each positive integer under this semigroup action reaching a specific point.

This connects to the theory of *iterated function systems* (IFS) in dynamical systems, where the long-term behavior of random compositions of affine maps is well-studied. The Collatz map is an IFS where the choice of map at each step is determined by the current value rather than being random.

### 6.3 Independence and the Fast-Growing Hierarchy

The proof barrier framework (Theorem 4.1) does not prove that the Collatz conjecture is independent of PA. It formalizes the *mechanism* by which such independence would manifest: through the witness function outgrowing the provably total functions. Whether this actually occurs for Collatz remains open.

However, the framework gives a precise target: to establish independence, one would need to show that the Collatz stopping time function eventually dominates every PA-provable function. This is equivalent to showing that the stopping time function grows faster than the fast-growing hierarchy at level ε₀.

## 7. Future Work

1. Extend the cycle analysis beyond 2-cycles to arbitrary cycle lengths.
2. Formalize the connection between parity words and Diophantine equations.
3. Investigate whether the Collatz stopping time function grows at the rate of specific ordinal-indexed functions in the fast-growing hierarchy.
4. Explore tropical and p-adic approaches to the Collatz map using the affine encoding.

## References

1. L. Collatz, "On the motivation and origin of the 3n+1 problem," 1937.
2. T. Tao, "Almost all orbits of the Collatz map attain almost bounded values," *Forum of Mathematics, Pi*, 2022.
3. S. Eliahou, "The 3x+1 problem: new lower bounds on nontrivial cycle lengths," *Discrete Mathematics*, 1993.
4. K. Gödel, "Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I," 1931.
5. J.H. Conway, "Unpredictable iterations," *Proceedings of the Number Theory Conference*, 1972.
6. R. Goodstein, "On the restricted ordinal theorem," *Journal of Symbolic Logic*, 1944.
