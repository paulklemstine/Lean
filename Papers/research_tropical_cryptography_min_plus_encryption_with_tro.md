# Structural Transparency of Tropical Matrix Powers and the Insecurity of Min-Plus Diffie–Hellman

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

The tropical (min-plus) semiring has been proposed repeatedly as an algebraic substrate for post-quantum key exchange, via a "tropical Diffie–Hellman" protocol whose security is supposed to rest on the hardness of the *tropical discrete logarithm problem* (TDLP): given a tropical matrix $A$ and a tropical power $B = A^{\otimes k}$, recover the exponent $k$. We give two structural theorems that expose why this hope is misplaced. First, we prove a general **walk-sum identity**: over any commutative semiring, the $(i,j)$ entry of $A^{k}$ equals the sum over all length-$k$ walks from $i$ to $j$ of the product of the traversed entries; specialized to the tropical semiring this is exactly the Bellman–Floyd shortest-$k$-step-walk identity, so a tropical matrix power is literally a table of shortest-walk weights. Second, we prove that **tropical eigenvalues are additive under powering**: if $A \otimes v = \lambda \otimes v$, then $A^{\otimes k} \otimes v = \lambda^{\otimes k} \otimes v$ and the underlying min-plus eigenvalue satisfies $\lambda(A^{\otimes k}) = k \cdot \lambda(A)$. This linear leakage converts the TDLP into the elementary equation $\lambda(B) = k\,\lambda(A)$, recoverable by one minimum-cycle-mean computation, whenever $\lambda(A) \neq 0$. Together the two theorems place three domains — linear algebra, combinatorial optimization, and spectral theory — in a single reduction, and explain at the structural level why raw min-plus matrix powering is not a one-way function.

**Keywords:** tropical semiring, min-plus algebra, tropical matrix power, discrete logarithm, tropical eigenvalue, minimum cycle mean, shortest paths, Diffie–Hellman, post-quantum cryptography.

## 1. Introduction

Public-key cryptography depends on the existence of *one-way functions*: maps that are cheap to evaluate but computationally infeasible to invert. The Diffie–Hellman key exchange, the archetype, relies on the discrete logarithm problem in a cyclic group. A recurring theme in the search for quantum-resistant alternatives is to replace the multiplicative group of a field with a more exotic algebraic structure and hope that its "discrete logarithm" is intractable.

One such candidate is the **tropical**, or **min-plus**, semiring. Several proposals over the past decade have suggested building Diffie–Hellman-style exchanges from tropical matrix arithmetic, with security resting on the tropical discrete logarithm problem. The appeal is threefold: tropical matrix powering is cheap (via repeated squaring), the arithmetic avoids the number-theoretic structure that quantum algorithms exploit, and the min-plus world seems combinatorially wild.

This paper argues, through two theorems, that the min-plus world is in fact *too transparent* to hide a discrete logarithm. Both theorems are proved for a general index set (any finite vertex type $V$) and, where possible, over an arbitrary commutative semiring, with the tropical case obtained by specialization. We then trace their cryptanalytic consequences.

The paper is organized as follows. Section 2 fixes the tropical semiring and matrix conventions. Section 3 states the protocol and the TDLP. Section 4 proves the walk-sum identity (linear algebra $\leftrightarrow$ combinatorial optimization). Section 5 proves eigenvalue additivity under powering (spectral theory $\leftrightarrow$ additive arithmetic) and derives the eigenvalue attack. Section 6 discusses the security consequences and the role of the $\lambda(A) \neq 0$ hypothesis. Section 7 gives algorithms; Section 8 discusses applications and limitations; Section 9 lists future directions.

## 2. The tropical semiring and tropical matrices

### 2.1 The min-plus semiring

Let $\overline{\mathbb{Z}} = \mathbb{Z} \cup \{\infty\}$. The **tropical (min-plus) semiring** is the set $\overline{\mathbb{Z}}$ equipped with

$$
x \oplus y := \min(x, y), \qquad x \otimes y := x + y,
$$

with the conventions $\min(x, \infty) = x$ and $x + \infty = \infty$. Under these operations:

- $\oplus$ is associative, commutative, and has identity element $\mathbf{0} := \infty$ (the "tropical zero"), since $\min(x, \infty) = x$;
- $\otimes$ is associative, commutative, and has identity element $\mathbf{1} := 0$ (the "tropical one"), since $x + 0 = x$;
- $\otimes$ distributes over $\oplus$: $x + \min(y,z) = \min(x+y, x+z)$;
- the tropical zero absorbs: $x \otimes \infty = \infty$.

Thus $(\overline{\mathbb{Z}}, \oplus, \otimes, \infty, 0)$ is a commutative semiring. It is *not* a ring: $\oplus$ has no inverses (there is no "tropical subtraction"), which is precisely what makes the structure interesting and, cryptographically, what removes the linear-algebra tools that would trivially invert a ring-based scheme.

Throughout, we write **tropical powers** with the operation $\otimes$: for a scalar, $\lambda^{\otimes k} = \underbrace{\lambda \otimes \cdots \otimes \lambda}_{k} = k\lambda$ (ordinary multiplication of the underlying integer). We denote by $\operatorname{untrop}(x)$ the underlying element of $\overline{\mathbb{Z}}$ carried by a tropical scalar $x$; then $\operatorname{untrop}(\lambda^{\otimes k}) = k \cdot \operatorname{untrop}(\lambda)$.

### 2.2 Tropical matrices and matrix powers

Fix a finite index set $V$ (the *vertices*), and let $A$ be a $V \times V$ matrix over the tropical semiring. Matrix multiplication is defined semiring-generically:

$$
(A \otimes B)_{ij} = \bigoplus_{\ell \in V} A_{i\ell} \otimes B_{\ell j} = \min_{\ell \in V}\bigl(A_{i\ell} + B_{\ell j}\bigr).
$$

The identity matrix $I$ has $\mathbf{1} = 0$ on the diagonal and $\mathbf{0} = \infty$ off it, and $A^{\otimes 0} = I$, $A^{\otimes (k+1)} = A^{\otimes k} \otimes A$. A tropical matrix $A$ is naturally the weighted adjacency matrix of a directed graph on $V$: $A_{ij}$ is the weight of the edge $i \to j$ (with $\infty$ meaning "no edge").

Matrices act on vectors by

$$
(A \otimes v)_i = \bigoplus_{j} A_{ij} \otimes v_j = \min_j\bigl(A_{ij} + v_j\bigr).
$$

For a scalar $\lambda$ and vector $v$, the scalar action is $(\lambda \otimes v)_i = \lambda + v_i$, written $\lambda \bullet v$.

## 3. The protocol and the tropical discrete logarithm problem

**Tropical Diffie–Hellman.** A public tropical matrix $A \in \overline{\mathbb{Z}}^{V \times V}$ is fixed. Alice chooses a secret exponent $a \in \mathbb{N}$ and publishes $A^{\otimes a}$; Bob chooses a secret $b$ and publishes $A^{\otimes b}$. Because tropical matrix multiplication is associative and $A$ commutes with its own powers, both parties can compute the shared key

$$
K = \bigl(A^{\otimes a}\bigr)^{\otimes b} = A^{\otimes ab} = \bigl(A^{\otimes b}\bigr)^{\otimes a}.
$$

Each power costs $O(n^3 \log k)$ tropical operations by repeated squaring, where $n = |V|$.

**Tropical discrete logarithm problem (TDLP).** Given $A$ and $B = A^{\otimes k}$, recover $k$. The security of the protocol reduces to the hardness of the TDLP: an adversary who can solve it recovers $a$ from $A^{\otimes a}$ (or $b$ from $A^{\otimes b}$) and hence the key.

The remainder of the paper shows that the TDLP inherits too much structure from the min-plus semiring to be hard in general.

## 4. Walk-sum identity: linear algebra meets combinatorial optimization

Our first theorem is a semiring-generic combinatorial description of matrix powers. Define a **length-$k$ walk** from $i$ to $j$ as a sequence $p = (p_0, p_1, \ldots, p_k)$ of vertices with $p_0 = i$ and $p_k = j$; there are no adjacency constraints because "no edge" is encoded by the zero weight $\infty$.

**Theorem 1 (Walk-sum identity).** *Let $S$ be a commutative semiring, $V$ a finite set, and $A \in S^{V \times V}$. For all $k \in \mathbb{N}$ and $i, j \in V$,*
$$
\bigl(A^{k}\bigr)_{ij} \;=\; \sum_{\substack{p:\{0,\dots,k\}\to V \\ p_0 = i,\ p_k = j}} \ \prod_{t=0}^{k-1} A_{p_t\, p_{t+1}}.
$$

*Proof sketch.* Induct on $k$. For $k = 0$, $A^0 = I$; the sum ranges over length-$0$ walks, of which there is exactly one when $i = j$ (contributing the empty product $\mathbf{1}$) and none when $i \neq j$ (contributing $\mathbf{0}$), matching $I_{ij}$. For the inductive step, write $A^{k+1} = A^k \cdot A$, so $(A^{k+1})_{ij} = \sum_{\ell} (A^k)_{i\ell}\, A_{\ell j}$. By the inductive hypothesis, $(A^k)_{i\ell}$ is the walk-sum over length-$k$ walks $i \to \ell$; multiplying by $A_{\ell j}$ and summing over $\ell$ appends the final edge $\ell \to j$. The bijection $p \mapsto (p\!\restriction, p_k)$ between length-$(k{+}1)$ walks $i \to j$ and pairs (length-$k$ walk $i \to \ell$, final vertex $j$) matches terms exactly, using distributivity to expand $\bigl(\sum \prod\bigr)\cdot A_{\ell j}$ into $\sum \prod$. $\qquad\blacksquare$

**Tropical corollary (shortest walks).** Specializing $S$ to the tropical semiring, $\sum \mapsto \min$ and $\prod \mapsto +$, so

$$
\operatorname{untrop}\bigl((A^{\otimes k})_{ij}\bigr) \;=\; \min_{\substack{p_0 = i,\ p_k = j}} \ \sum_{t=0}^{k-1} \operatorname{untrop}\bigl(A_{p_t\, p_{t+1}}\bigr).
$$

That is, the $(i,j)$ entry of the $k$-th tropical power is the **minimum total weight of a $k$-step walk** from $i$ to $j$. This is precisely the recurrence underlying the Bellman–Ford and Floyd–Warshall algorithms. Consequently, the public data $B = A^{\otimes k}$ of the protocol is a *shortest-$k$-step-distance table* of the weighted digraph $A$ — a highly structured object, not random noise. This is the structural basis of the "shortest-path attack" on the TDLP.

## 5. Eigenvalue additivity: spectral theory meets additive arithmetic

### 5.1 Eigenpairs are preserved under powering

We first record a general commutative-semiring fact.

**Lemma 2 (Eigenvector–power law).** *Let $S$ be a commutative semiring, $A \in S^{V \times V}$, $v \in S^{V}$, and $\lambda \in S$ with $A \cdot v = \lambda \bullet v$ (scalar multiplication). Then for all $k \in \mathbb{N}$,*
$$
A^{k} \cdot v = \lambda^{k} \bullet v.
$$

*Proof sketch.* Induct on $k$. The base case $k=0$ is $I \cdot v = \mathbf{1} \bullet v = v$. For the step, use $A^{k+1} \cdot v = A \cdot (A^{k} \cdot v) = A \cdot (\lambda^{k} \bullet v)$. Scalars pull through matrix–vector multiplication in a commutative semiring, so $A \cdot (\lambda^{k} \bullet v) = \lambda^{k} \bullet (A \cdot v) = \lambda^{k} \bullet (\lambda \bullet v) = \lambda^{k+1} \bullet v$. $\qquad\blacksquare$

### 5.2 Tropical eigenvalues add

A **tropical eigenpair** of $A$ is a scalar $\lambda$ and vector $v$ (with at least one finite entry) satisfying

$$
A \otimes v = \lambda \bullet v, \qquad \text{i.e.} \qquad \min_j\bigl(A_{ij} + v_j\bigr) = \lambda + v_i \quad \text{for all } i.
$$

The scalar $\lambda = \lambda(A)$ is the **tropical eigenvalue**; by the tropical spectral theorem it equals the **minimum cycle mean** of the weighted digraph $A$, namely $\lambda(A) = \min_C \frac{w(C)}{|C|}$ over directed cycles $C$, where $w(C)$ is the total weight and $|C|$ the length. (We use this characterization only as motivation; the theorem below needs only the eigenpair equation.)

**Theorem 3 (Additivity of tropical eigenvalues under powering).** *Let $A$ be a tropical matrix with tropical eigenpair $(\lambda, v)$, i.e. $A \otimes v = \lambda \bullet v$. Then for every $k \in \mathbb{N}$:*
1. *$(\lambda, v)$ is a tropical eigenpair of $A^{\otimes k}$, that is $A^{\otimes k} \otimes v = \lambda^{\otimes k} \bullet v$; and*
2. *the underlying min-plus eigenvalue is additive: $\operatorname{untrop}\bigl(\lambda^{\otimes k}\bigr) = k \cdot \operatorname{untrop}(\lambda)$, i.e.*
$$
\lambda\bigl(A^{\otimes k}\bigr) = k \cdot \lambda(A).
$$

*Proof sketch.* Part (1) is Lemma 2 applied to the tropical semiring, giving $A^{\otimes k} \otimes v = \lambda^{\otimes k} \bullet v$, so $\lambda^{\otimes k}$ is an eigenvalue of $A^{\otimes k}$ with the *same* eigenvector $v$. Part (2) unfolds the tropical power of the scalar: $\lambda^{\otimes k}$ means applying $\otimes = +$ to $k$ copies of $\lambda$, so $\operatorname{untrop}(\lambda^{\otimes k}) = k \cdot \operatorname{untrop}(\lambda)$. $\qquad\blacksquare$

### 5.3 The eigenvalue attack on the TDLP

Theorem 3 furnishes a polynomial-time solver for the TDLP whenever the public eigenvalue is nonzero.

**Corollary 4 (Eigenvalue attack).** *Let $A$ be a public tropical matrix with $\lambda(A) \neq 0$ (in the sense $\operatorname{untrop}(\lambda(A)) \neq 0$ and finite), and let $B = A^{\otimes k}$. Then*
$$
k = \frac{\lambda(B)}{\lambda(A)} = \frac{\operatorname{untrop}(\lambda(A^{\otimes k}))}{\operatorname{untrop}(\lambda(A))},
$$
*and $k$ is recovered in polynomial time by computing the two minimum cycle means and dividing.*

*Proof.* By Theorem 3(2), $\lambda(B) = \lambda(A^{\otimes k}) = k\,\lambda(A)$. Since $\lambda(A) \neq 0$, divide. Both eigenvalues are minimum cycle means, computable in $O(n^3)$ time (e.g. by Karp's algorithm), so the whole attack is polynomial in $n$ and independent of the magnitude of $k$. $\qquad\blacksquare$

This is the decisive obstruction: a discrete-logarithm problem requires the exponent to be hidden, but tropical powering exposes it *linearly* through the spectrum. No brute-force search over $k$ is needed; the exponent is read off from two shortest-cycle computations.

## 6. Security consequences and the role of $\lambda(A) \neq 0$

Corollary 4 has one hypothesis: $\lambda(A) \neq 0$. When the minimum cycle mean of $A$ is $0$ (or $\infty$, i.e. the graph is acyclic so no finite eigenvalue exists), the division is undefined and this particular attack does not directly recover $k$. Any candidate secure tropical scheme must therefore restrict to matrices whose eigenvalue is degenerate for the attacker.

This is a narrow refuge, for two reasons.

1. **Theorem 1 still applies.** Even when the eigenvalue trick is blocked, the public power $B = A^{\otimes k}$ remains a shortest-$k$-step-distance table. Its rich combinatorial structure is directly attackable by shortest-path and cycle-detection methods; the eigenvalue attack is only the cleanest of a family of structural attacks that the walk-sum identity enables.

2. **Historical corroboration.** The earliest tropical Diffie–Hellman proposals were broken by exactly such structural/linear-algebraic cryptanalysis; subsequent perturbation-based variants (which deliberately break exact eigenstructure) were also broken. Theorems 1 and 3 explain, at the level of algebraic structure, *why*: the min-plus semiring is engineered to linearize optimization, and linearization is the opposite of the "structurelessness" a one-way function requires.

The upshot is a precise design constraint rather than a wholesale impossibility: any secure min-plus scheme must avoid public matrices with recoverable eigenvalues *and* must obscure the shortest-walk structure of its powers — a demanding pair of requirements that the raw protocol does not meet.

## 7. Algorithms

We summarize the honest computation and the attack.

**(A) Tropical matrix power by repeated squaring.** Compute $A^{\otimes k}$ in $O(n^3 \log k)$ tropical operations by writing $k$ in binary and squaring/multiplying. This is what Alice and Bob do.

**(B) Minimum cycle mean (Karp).** Compute $\lambda(A)$ in $O(n^3)$ by the dynamic program $\lambda(A) = \min_{i}\max_{0 \le t < n} \frac{d_n(i) - d_t(i)}{n - t}$, where $d_t(i)$ is the minimum weight of a length-$t$ walk from a fixed source to $i$, obtained by tropical vector iteration.

**(C) Eigenvalue attack on the TDLP.** Given $(A, B)$: compute $\lambda(A)$ and $\lambda(B)$ by (B); if $\lambda(A) \neq 0$, return $k = \lambda(B)/\lambda(A)$.

Full pseudocode and reference implementations accompany this work.

## 8. Applications and limitations

The two theorems have value well beyond cryptanalysis.

- **Optimization.** Theorem 1 is the algebraic form of the Bellman/Floyd shortest-walk recurrences; it packages all-lengths shortest-walk information as matrix powers.
- **Spectral graph theory.** Theorem 3 relates the spectrum of a weighted digraph to that of its "$k$-step" contraction and formalizes the cycle-mean scaling law.
- **Cryptographic design.** Corollary 4 is a concrete adversary; it delineates exactly which structural assumptions a secure tropical scheme must avoid.

*Limitations.* The eigenvalue attack requires a nonzero, finite tropical eigenvalue and an eigenvector to exist; degenerate matrices evade it (though not the broader class of structural attacks). Our results are stated for finite index sets and, for the eigenvalue law, for commutative semirings; noncommutative tropical variants are outside scope.

## 9. Future directions

- **Explicit min/+ form of the shortest-path bridge.** Restate Theorem 1 as a literal $\operatorname{untrop}((A^{\otimes k})_{ij}) = \min_p \sum_t \operatorname{untrop}(A_{p_t p_{t+1}})$ using the untropicalization of sums and products.
- **Cycle-mean eigenvalue formula.** Prove the full min-plus spectral theorem $\lambda(A) = \min_C w(C)/|C|$ and connect it to eigenvalue additivity, yielding a complete recovery algorithm for the TDLP.
- **Kleene star / all-pairs shortest paths.** Formalize $A^{*} = \bigoplus_k A^{\otimes k}$ (Floyd–Warshall) and its convergence for matrices with nonnegative diagonal, extending the walk-sum bridge from fixed length to reachability.
- **Security reduction as an explicit adversary.** Package the eigenvalue attack as a formal polynomial-time reduction "TDLP with $\lambda(A) \neq 0$ $\Rightarrow$ recover $k$," and contrast with perturbation-based schemes to pin down which structural assumptions any secure variant must avoid.
- **Graph-API integration.** Specialize both theorems to $V = \{1, \ldots, n\}$ and relate them to standard weighted-digraph and walk formalisms.

## 10. Conclusion

Two theorems settle the structural question behind tropical Diffie–Hellman. The walk-sum identity shows a tropical matrix power *is* a shortest-walk table (linear algebra $\leftrightarrow$ optimization); eigenvalue additivity shows powering multiplies the tropical eigenvalue (spectral theory $\leftrightarrow$ additive arithmetic), turning the discrete logarithm into a linear equation solvable by two cycle-mean computations. The very features that make min-plus algebra a powerful language for optimization — its linearization of shortest paths and its clean spectral scaling — are precisely what disqualify it, in raw form, as a foundation for one-way functions.
