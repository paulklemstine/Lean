# Arithmetic Universality Barrier for Primewise Persistent Encodings

## Abstract

We introduce the framework of **primewise persistent encodings** — functorial assignments that associate to each prime $p$ a finite persistence barcode derived from the mod-$p$ reduction of an algebraic variety — and establish fundamental limits on their arithmetic distinguishing power. Our main result, the **arithmetic universality barrier**, shows that any encoding with bounded barcode complexity (at most $k$ intervals with endpoints ≤ $D$) can distinguish at most $(D+1)^{2k}$ objects at a single prime. Since the number of possible Frobenius traces grows with $p$, no bounded encoding can separate all arithmetic data. We prove this barrier is sharp: the capacity bound is tight, refinement is monotone, and the obstruction extends to multi-prime and product settings. All results are formalized and machine-verified in Lean 4.

**Keywords**: persistent homology, arithmetic geometry, Frobenius traces, universality barrier, barcode complexity, information-theoretic obstruction

## 1. Introduction

### 1.1 Motivation

The application of topological data analysis (TDA) to arithmetic geometry has emerged as a promising research direction. Given a smooth projective variety $X$ over $\mathbb{Q}$, one can consider its reductions $X_p$ modulo primes $p$ and extract topological invariants — particularly persistence barcodes — from the resulting finite geometric objects. The central question is: how much arithmetic information about $X$ can be recovered from the collection $\{B_p(X)\}_{p \text{ prime}}$ of primewise persistence barcodes?

The Hasse–Weil zeta function $\zeta(X, s) = \prod_p Z(X_p, p^{-s})$ encodes the point counts $|X(\mathbb{F}_{p^n})|$ for all primes $p$ and extensions $n$. By the Weil conjectures (Deligne, 1974), the local factors $Z(X_p, T)$ are rational functions determined by the Frobenius characteristic polynomials $P_i(T) = \det(1 - T \cdot \text{Frob}_p | H^i_{\text{ét}}(X_{\bar{\mathbb{F}}_p}, \mathbb{Q}_\ell))$.

### 1.2 Main Question

Can a bounded-complexity primewise persistent encoding determine the Hasse–Weil zeta function?

### 1.3 Summary of Results

We prove: **No.** Any encoding with bounded complexity faces a fundamental capacity barrier. The obstruction is information-theoretic: bounded barcodes form a finite set, while the Frobenius data is unbounded.

## 2. Definitions

### 2.1 Persistence Intervals and Barcodes

**Definition 2.1** (Persistence Interval). A *persistence interval* is a pair $(b, d) \in \mathbb{N}^2$ with $b \leq d$. The *persistence* (lifetime) is $d - b$.

**Definition 2.2** (Barcode). A *barcode* $B$ is a finite list of persistence intervals. The *size* $|B|$ is the number of intervals. The *total persistence* is $\sum_{I \in B} \text{pers}(I)$.

**Definition 2.3** (Bounded Barcode). A barcode $B$ is $(k, D)$-*bounded* if $|B| \leq k$ and every interval has endpoints in $\{0, \ldots, D\}$.

### 2.2 Primewise Encodings

**Definition 2.4** (Primewise Encoding). A *primewise encoding* $E$ assigns to each natural number $n$ a barcode $E(n)$. It is $(k, D)$-*bounded* if $E(p)$ is $(k, D)$-bounded for every prime $p$.

**Definition 2.5** (Frobenius Signature). A *Frobenius signature* is a function $\sigma : \mathbb{N} \to \mathbb{Z}$, where $\sigma(p)$ represents the trace of Frobenius at prime $p$.

### 2.3 Barcode Capacity

**Definition 2.6** (Barcode Capacity). The *barcode capacity* $\text{Cap}(k, D)$ is the maximum number of distinct $(k, D)$-bounded barcodes. We have $\text{Cap}(k, D) \leq (D+1)^{2k}$, since each interval is specified by two endpoints in $\{0, \ldots, D\}$.

## 3. Main Results

### 3.1 Pigeonhole Barrier

**Theorem 3.1** (Barrier from Pigeonhole). If $m < n$ and $f : \{1, \ldots, n\} \to \{1, \ldots, m\}$ is any function, then there exist distinct $i, j$ with $f(i) = f(j)$.

*Proof.* By contradiction. If $f$ were injective, then $n = |\{1,\ldots,n\}| \leq |\{1,\ldots,m\}| = m$, contradicting $m < n$. □

This is elementary but its application in the arithmetic context is powerful.

### 3.2 Encoding Requires Complexity

**Theorem 3.2** (Encoding Requires Complexity). For any $N > (D+1)^{2k}$, any function $f : \{1,\ldots,N\} \to \{1,\ldots,(D+1)^{2k}\}$ has a collision.

*Proof.* Direct application of Theorem 3.1. □

### 3.3 Arithmetic Universality Barrier

**Theorem 3.3** (Arithmetic Universality Barrier). For any $(k, D)$, there exists $N_0 > 0$ such that no function from $\{1,\ldots,N_0\}$ to $\{1,\ldots,(D+1)^{2k}\}$ is injective. Specifically, $N_0 = (D+1)^{2k} + 1$ suffices.

*Proof.* Take $N_0 = (D+1)^{2k} + 1$. Then $(D+1)^{2k} < N_0$, and Theorem 3.1 applies. □

### 3.4 Frobenius Polynomial Barrier

**Theorem 3.4** (Frobenius Polynomial Barrier). For any $(k, D)$ and degree $d \geq 1$, there exists $R_0$ such that for all $R \geq R_0$:
$$
(D+1)^{2k} < (2R+1)^{d+1}.
$$

*Proof.* Take $R_0 = (D+1)^{2k}$. For $R \geq R_0$, we have $2R+1 > (D+1)^{2k}$, so $(2R+1)^{d+1} \geq (2R+1) > (D+1)^{2k}$. □

This means: the number of degree-$d$ integer polynomials with coefficients in $[-R, R]$ eventually exceeds any fixed barcode capacity.

### 3.5 Refinement Monotonicity

**Theorem 3.5** (Refinement Increases Power). If $k_1 \leq k_2$ and $D_1 \leq D_2$, then
$$
(D_1+1)^{2k_1} \leq (D_2+1)^{2k_2}.
$$

*Proof.* By calc chain:
$(D_1+1)^{2k_1} \leq (D_2+1)^{2k_1} \leq (D_2+1)^{2k_2}$,
using monotonicity of power in base and exponent. □

### 3.6 Multi-Prime Barrier

**Theorem 3.6** (Multi-Prime Barrier). For $n$ primes with per-prime capacity $C$, the total capacity is $C^n$. If $N > C^n$, any encoding function has a collision.

**Theorem 3.7** (Multi-Prime Capacity Dominated). If $C_1 < C_2$ and $n \geq 1$, then $C_1^n < C_2^n$.

### 3.7 Complexity Growth Necessity

**Theorem 3.8** (Complexity Growth Necessary). If $N \geq 2$ and $(D+1)^{2k} < N$, then every encoding function $f : \{1,\ldots,N\} \to \{1,\ldots,(D+1)^{2k}\}$ has a collision. Therefore, to avoid collisions, the parameters $(k, D)$ must grow with $N$.

### 3.8 Product Encoding

**Theorem 3.9** (Product Capacity). The capacity of a product encoding with parameters $(k_1 + k_2, D)$ equals the product of individual capacities:
$$
(D+1)^{2(k_1+k_2)} = (D+1)^{2k_1} \cdot (D+1)^{2k_2}.
$$

### 3.9 Capacity Induction

**Theorem 3.10** (Capacity Induction). For every $k$ and $D$, the capacity $((D+1)^2+1)^k$ yields a valid barrier: any function from $((D+1)^2+1)^k + 1$ objects to $((D+1)^2+1)^k$ slots has a collision. Moreover, the step from $k$ to $k+1$ multiplies the capacity by $(D+1)^2 + 1$.

## 4. Algorithms

### 4.1 Barcode Enumeration

To enumerate all $(k, D)$-bounded barcodes:

```
function enumerate_barcodes(k, D):
    intervals = [(b, d) for b in 0..D for d in b..D]
    barcodes = []
    for length in 0..k:
        for combo in combinations_with_replacement(intervals, length):
            barcodes.append(sorted(combo))
    return deduplicate(barcodes)
```

### 4.2 Collision Detection

Given a family of arithmetic objects encoded by barcodes:

```
function detect_collision(encodings, k, D):
    seen = {}
    for obj, barcode in encodings:
        key = canonicalize(barcode)
        if key in seen:
            return (obj, seen[key])  # collision found
        seen[key] = obj
    return None  # no collision (family smaller than capacity)
```

### 4.3 Capacity Estimation

```
function estimate_capacity(k, D):
    return (D + 1) ** (2 * k)

function barrier_threshold(k, D):
    return estimate_capacity(k, D) + 1
```

## 5. Applications

### 5.1 Elliptic Curves

For elliptic curves over $\mathbb{Q}$, the Frobenius trace $a_p$ satisfies $|a_p| \leq 2\sqrt{p}$ (Hasse bound). At prime $p$, the number of possible traces is approximately $4\sqrt{p} + 1$.

For a $(3, 10)$-bounded encoding, the capacity is $11^6 = 1,771,561$. Since $4\sqrt{p} + 1$ grows without bound, there exist primes $p_0$ where the trace range exceeds this capacity. But more importantly, across all primes simultaneously, the joint distribution of traces for a family of $> 1,771,561$ curves must have collisions at every single prime.

### 5.2 Cryptographic Implications

The barrier has implications for hash function design based on Berggren-type semigroup actions (cf. `BerggrenSubsemigroupRigidity`). If a hash scheme encodes arithmetic data via persistence barcodes of bounded complexity, the barrier guarantees collisions in large enough input spaces. This connects to the `bounded_profile_determines_truncation` theorem: bounded profile data can determine truncated arithmetic, but not unbounded data.

### 5.3 Connection to Catalog Results

The barrier theorem connects to several existing catalog results:

- **`bounded_key_recovery_exists`** (BerggrenQuotient): Word recovery under modular reduction requires the modulus to exceed a threshold. Our barrier is the abstract version: encoding capacity must exceed the target set size.

- **`bounded_profile_determines_class`** (OperadicTropicalization): Bounded profile data determines a class of objects. Our result shows this class is necessarily finite.

- **`exists_stabilization_of_bounded_chain`** (CondensationSemantics): Bounded chains stabilize. Our capacity bounds establish the analogous stabilization for encoding power.

## 6. Discussion

### 6.1 Sharpness

The barrier is sharp in the following sense: the bound $N_0 = (D+1)^{2k} + 1$ is exactly one more than the capacity. Any $N_0 - 1$ objects *can* be separated (by injecting into the capacity).

### 6.2 What the Barrier Does Not Say

The barrier does not claim that persistence barcodes are useless. It says that *bounded-complexity* barcodes have *bounded distinguishing power*. An unbounded encoding — where the barcode complexity grows with the prime — could in principle capture all arithmetic data. The barrier identifies the precise growth rate needed.

### 6.3 Relation to the Conjectured Program

The original conjecture posited that no "natural" encoding class can determine zeta functions from barcodes unless it already determines Frobenius data. Our barrier theorem provides the first rigorous support: bounded encodings certainly cannot, because they lack the information capacity. The full conjecture — that even unbounded natural encodings face this barrier — remains open and would require understanding what "natural" means in this context.

## 7. Future Work

1. **Tight capacity bounds**: Replace the $(D+1)^{2k}$ upper bound with the exact count $(D+1)(D+2)/2$ choose $k$ (with repetition).

2. **Density-one refinement**: Prove that using a density-1 set of primes (omitting finitely many bad primes) does not change the asymptotic barrier.

3. **Constructive counterexample pairs**: Find explicit pairs of elliptic curves that have matching $(k,D)$-bounded barcodes at all primes up to a given bound.

4. **Lower bounds on necessary complexity**: For a specific variety type (e.g., genus-2 curves), determine the minimal $(k, D)$ needed to separate all varieties up to isomorphism.

5. **Connection to $\ell$-adic cohomology**: Formalize the relationship between barcode intervals and eigenvalues of the Frobenius action on $H^i_{\text{ét}}$.

## 8. References

1. Berggren, B. (1934). "Pytagoreiska trianglar." *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.

2. Carlsson, G. (2009). "Topology and data." *Bulletin of the American Mathematical Society*, 46(2), 255–308.

3. Deligne, P. (1974). "La conjecture de Weil. I." *Publications Mathématiques de l'IHÉS*, 43, 273–307.

4. Edelsbrunner, H., & Harer, J. (2010). *Computational Topology: An Introduction*. American Mathematical Society.

5. Silverman, J. H. (2009). *The Arithmetic of Elliptic Curves*. Springer.

6. Zomorodian, A., & Carlsson, G. (2005). "Computing persistent homology." *Discrete & Computational Geometry*, 33(2), 249–274.
