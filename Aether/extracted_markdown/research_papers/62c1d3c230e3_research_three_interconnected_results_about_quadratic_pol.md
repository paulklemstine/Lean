# Discriminant Uniformity and Splitting Type Distribution for Quadratic Polynomials over Finite Fields

## Abstract

We establish three interconnected results about monic quadratic polynomials $x^2 + bx + c$ over finite fields $\mathbb{F}_p$ for odd primes $p$. First, the **Discriminant Uniformity Theorem**: the map $(b, c) \mapsto b^2 - 4c$ has fibers of constant size $p$, establishing perfect uniformity of the discriminant distribution. Second, we derive exact formulas for splitting type counts: among $p^2$ monic quadratics, exactly $p(p-1)/2$ are split, $p$ are ramified, and $p(p-1)/2$ are inert. Third, we prove that the split fraction converges to $1/2$ as $p \to \infty$, recovering the degree-2 case of the Chebotarev density theorem. All results are formalized in Lean 4 with complete machine-verified proofs. We introduce the notion of a **Discriminant Profile** as a novel abstraction for studying splitting type distributions across polynomial families and field sizes.

## 1. Introduction

The study of polynomial splitting over finite fields is central to algebraic number theory, coding theory, and cryptography. For a monic quadratic $f(x) = x^2 + bx + c$ over $\mathbb{F}_p$, the discriminant $\Delta = b^2 - 4c$ completely determines the factorization behavior: $f$ splits into two distinct linear factors when $\Delta$ is a nonzero square, has a repeated root when $\Delta = 0$, and remains irreducible when $\Delta$ is a non-square.

A fundamental but often unstated fact is that the discriminant map $(b, c) \mapsto b^2 - 4c$ distributes coefficient pairs perfectly uniformly across discriminant values. This uniformity is the algebraic engine behind the statistical regularity observed in splitting type distributions.

### 1.1 Main Results

**Theorem A (Discriminant Uniformity).** For any odd prime $p$ and any $d \in \mathbb{F}_p$,
$$|\{(b, c) \in \mathbb{F}_p^2 : b^2 - 4c = d\}| = p.$$

**Theorem B (Splitting Type Counts).** Among the $p^2$ monic quadratics over $\mathbb{F}_p$ ($p$ an odd prime):
- Exactly $p$ are ramified (discriminant zero).
- Exactly $p(p-1)/2$ are split (discriminant a nonzero square).
- Exactly $p(p-1)/2$ are inert (discriminant a non-square).

**Theorem C (Asymptotic Chebotarev).** The split fraction $p(p-1)/(2p^2) = (p-1)/(2p)$ converges to $1/2$ as $p \to \infty$, matching the probability that a uniformly random permutation in $S_2$ is the identity.

### 1.2 Novel Contributions

We introduce the **Discriminant Profile** structure, which packages the splitting type distribution data (counts of split, ramified, and inert polynomials together with their partition property) into a single mathematical object. This abstraction facilitates:
- Comparison of splitting statistics across different polynomial degrees.
- Tracking the evolution of splitting fractions as the field size grows.
- Cross-domain connections between algebraic fiber counting, probabilistic number theory, and Galois theory.

## 2. Definitions

### 2.1 Splitting Type

**Definition 2.1.** The *splitting type* of a monic polynomial $f \in \mathbb{F}_q[x]$ is an element of the set $\{\text{split}, \text{ramified}, \text{inert}\}$ defined by:
- $\text{split}$: $f$ factors completely into distinct linear factors.
- $\text{ramified}$: $f$ has a repeated root.
- $\text{inert}$: $f$ is irreducible.

For degree 2, this trichotomy is exhaustive and is determined entirely by the discriminant $\Delta = b^2 - 4c$:
$$\text{type}(f) = \begin{cases} \text{ramified} & \text{if } \Delta = 0, \\ \text{split} & \text{if } \Delta \neq 0 \text{ and } \Delta \in (\mathbb{F}_p^*)^2, \\ \text{inert} & \text{if } \Delta \notin (\mathbb{F}_p)^2. \end{cases}$$

### 2.2 Discriminant Profile

**Definition 2.2.** A *discriminant profile* is a tuple $(n_S, n_R, n_I, N)$ where $n_S, n_R, n_I \in \mathbb{N}$ represent the counts of split, ramified, and inert polynomials respectively, and $N = n_S + n_R + n_I$ is the total family size. The *split fraction* is $n_S / N$.

### 2.3 Discriminant Fiber

**Definition 2.3.** For $d \in \mathbb{F}_p$, the *discriminant fiber* over $d$ is
$$F(d) = \{(b, c) \in \mathbb{F}_p^2 : b^2 - 4c = d\}.$$

### 2.4 Fiber Parametrization

**Definition 2.4.** For odd prime $p$ and $d \in \mathbb{F}_p$, the *fiber parametrization* is the map
$$\varphi_d : \mathbb{F}_p \to \mathbb{F}_p^2, \quad \varphi_d(b) = \left(b, \frac{b^2 - d}{4}\right).$$

## 3. Proofs

### 3.1 Discriminant Uniformity (Theorem A)

**Proof sketch.** The key observation is that $\varphi_d$ is a bijection from $\mathbb{F}_p$ to $F(d)$.

*Membership:* For any $b \in \mathbb{F}_p$, set $c = (b^2 - d)/4$ (well-defined since $4$ is invertible for $p \neq 2$). Then $b^2 - 4c = b^2 - 4 \cdot (b^2 - d)/4 = b^2 - (b^2 - d) = d$.

*Injectivity:* If $\varphi_d(b_1) = \varphi_d(b_2)$, then $(b_1, -) = (b_2, -)$, so $b_1 = b_2$.

*Surjectivity:* If $(b, c) \in F(d)$, then $b^2 - 4c = d$, so $4c = b^2 - d$, so $c = (b^2 - d)/4 = \varphi_d(b)_2$. Thus $(b, c) = \varphi_d(b)$.

Since $\varphi_d$ is a bijection $\mathbb{F}_p \xrightarrow{\sim} F(d)$, we have $|F(d)| = |\mathbb{F}_p| = p$. $\square$

**Remark.** The invertibility of $4$ is essential. For $p = 2$, the map $(b, c) \mapsto b^2 - 4c = b^2$ is constant in $c$, and the fiber structure is different (though the fiber cardinality is still $p = 2$ by a separate argument).

### 3.2 Splitting Type Counts (Theorem B)

**Proof of ramified count.** The ramified quadratics are exactly $F(0)$, and $|F(0)| = p$ by Theorem A. $\square$

**Proof of split/inert counts.** In $\mathbb{F}_p^*$ for odd prime $p$, the squaring map $x \mapsto x^2$ is exactly 2-to-1 (since $x^2 = (-x)^2$ and $x \neq -x$ for $x \neq 0$). Therefore the number of nonzero squares is $(p-1)/2$, and the number of non-squares is also $(p-1)/2$.

By Theorem A, each nonzero square $d$ contributes $|F(d)| = p$ split quadratics, giving $p \cdot (p-1)/2$ total. Similarly, each non-square contributes $p$ inert quadratics, giving $p \cdot (p-1)/2$ total. $\square$

**Verification.** $p(p-1)/2 + p + p(p-1)/2 = p(p-1) + p = p^2 = |\mathbb{F}_p^2|$. ✓

### 3.3 Asymptotic Chebotarev (Theorem C)

**Proof sketch.** The split fraction is
$$\frac{p(p-1)/2}{p^2} = \frac{p-1}{2p} = \frac{1}{2} - \frac{1}{2p}.$$

As $p \to \infty$, $1/(2p) \to 0$, so the fraction converges to $1/2$.

The connection to $S_2$: the symmetric group $S_2 = \{e, (12)\}$ has two conjugacy classes, each of size 1. The identity (cycle type $(1)(2)$) corresponds to the split case, and the transposition (cycle type $(12)$) corresponds to the inert case. Each has probability $1/|S_2| = 1/2$, matching the limiting split and inert fractions. $\square$

## 4. Algorithms

### 4.1 Discriminant Classification

```
Algorithm: ClassifyQuadratic(p, b, c)
Input: prime p, coefficients b, c ∈ F_p
Output: splitting type ∈ {split, ramified, inert}

1. Compute Δ = b² - 4c (mod p)
2. If Δ = 0, return ramified
3. Compute Δ^((p-1)/2) (mod p)  [Euler's criterion]
4. If result = 1, return split
5. Else return inert
```

### 4.2 Fiber Enumeration

```
Algorithm: EnumerateFiber(p, d)
Input: prime p, target discriminant d ∈ F_p
Output: list of (b, c) pairs with b² - 4c = d

1. Compute inv4 = modular_inverse(4, p)
2. For b = 0, 1, ..., p-1:
   a. c = (b² - d) * inv4 (mod p)
   b. Output (b, c)
```

## 5. Connections and Applications

### 5.1 Algebraic Number Theory

The splitting type of $x^2 + bx + c$ modulo a prime $p$ directly determines the splitting behavior of $p$ in the number field $\mathbb{Q}(\alpha)$ where $\alpha$ is a root of $x^2 + bx + c$. The discriminant uniformity theorem thus provides a concrete mechanism for the equidistribution predicted by the Chebotarev density theorem.

### 5.2 Coding Theory

Over $\mathbb{F}_q$, irreducible polynomials generate optimal cyclic codes. The exact count of irreducible (inert) quadratics — $q(q-1)/2$ — determines the number of distinct degree-2 cyclic codes over $\mathbb{F}_q$.

### 5.3 Cryptography

The difficulty of distinguishing quadratic residues from non-residues underlies the security of several cryptographic protocols. The uniformity of discriminant fibers ensures that the "discriminant fingerprint" of a random quadratic reveals no information about the coefficients beyond the discriminant value itself.

## 6. Discussion

### 6.1 The Cubic Frontier

For degree 3, the discriminant of $x^3 + bx + c$ is $\Delta = -4b^3 - 27c^2$. The fiber structure depends on whether the map $b \mapsto b^3$ is a bijection on $\mathbb{F}_p$, which occurs exactly when $\gcd(3, p-1) = 1$, i.e., $p \equiv 2 \pmod{3}$.

**Conjecture.** For $p \equiv 2 \pmod{3}$, the discriminant map $(b, c) \mapsto -4b^3 - 27c^2$ has uniform fibers of size $p$ over $\mathbb{F}_p$.

**Prediction.** For $p \equiv 1 \pmod{3}$ (e.g., $p = 7$), the fibers are NOT uniform. Specifically, the fiber over $0$ has a different cardinality than the generic fiber.

### 6.2 The Discriminant Profile as a Research Tool

The Discriminant Profile abstraction opens several research avenues:
1. **Degree-$n$ profiles**: Classify splitting types for general degree $n$ (where the Galois group is $S_n$) and compute exact profiles.
2. **Profile convergence**: Prove that degree-$n$ profiles converge to the cycle type distribution of $S_n$ as $p \to \infty$.
3. **Non-uniform profiles**: Characterize which polynomial families have non-uniform discriminant fibers, and what obstruction theory governs the failure of uniformity.

## 7. Future Work

The most promising direction is extending the fiber uniformity analysis to cubic polynomials, where the interplay between cubing maps and field arithmetic creates a richer structure. The $p \equiv 2 \pmod{3}$ case should be tractable using methods analogous to the quadratic case, while the $p \equiv 1 \pmod{3}$ case requires understanding the deviation from uniformity through the lens of $n$-th power residue theory.

A second direction is formalizing the Chebotarev density theorem itself, building on the splitting type counts established here as the base case. The degree-2 case connects to elementary character sum arguments, while higher degrees require the full machinery of class field theory.

## References

1. Ireland, K. and Rosen, M. *A Classical Introduction to Modern Number Theory*, Graduate Texts in Mathematics 84, Springer, 1990.
2. Serre, J.-P. *A Course in Arithmetic*, Graduate Texts in Mathematics 7, Springer, 1973.
3. Neukirch, J. *Algebraic Number Theory*, Grundlehren der Mathematischen Wissenschaften 322, Springer, 1999.
4. Bhargava, M. "The density of discriminants of quartic rings and fields," *Annals of Mathematics* 162 (2005), 1031–1063.
5. Katz, N. and Sarnak, P. *Random Matrices, Frobenius Eigenvalues, and Monodromy*, AMS Colloquium Publications 45, 1999.
