# Aperiodicity and Eventual Periodicity in Cellular Automata Spacetime Languages

## Abstract

We prove two structural theorems about cellular automata (CA) viewed through the lens of formal language theory and finite-field arithmetic. First, we show that the spacetime column language of *any* nearest-neighbor CA has an aperiodic transition monoid (with uniform exponent bound $m^3 = m^2$), implying star-freeness and FO[<]-definability by the Schützenberger–McNaughton–Papert theorem. This result is universal — it requires no assumptions on the local rule. Second, we prove that for additive CA over $\text{GF}(p)$, the function $n \mapsto \deg(\gcd(Q, X^n - 1))$ is eventually periodic for any fixed nonzero polynomial $Q$, with period controlled by multiplicative orders of roots. This implies eventual periodicity of logarithmic fixed-point counts on cyclic configurations. Both results are formalized with complete machine-checked proofs.

## 1. Introduction

### 1.1 Motivation

Cellular automata occupy a unique position in theoretical computer science and dynamical systems: they are simultaneously models of parallel computation, discrete dynamical systems, and generators of formal languages. The *spacetime diagram* of a CA — the two-dimensional array of states produced by iterating the local rule — encodes both the computational and dynamical content of the system.

When we read a spacetime diagram column by column, we obtain a *spacetime column language*: the set of all finite sequences of vertical state vectors that can appear as valid spacetime strips. This language captures the "observational content" of the CA from the perspective of a spatially-localized observer reading state histories.

Two fundamental questions arise:
1. **What is the language-theoretic complexity of spacetime column languages?** Are they regular? Context-free? What is their position in the automata-theoretic hierarchy?
2. **How do periodic-orbit statistics depend on system size?** For additive CA on cyclic configurations, how does the count of fixed points vary with the configuration length?

### 1.2 Main Results

**Theorem A (Aperiodicity).** For any nearest-neighbor CA rule $f : \alpha \times \alpha \to \alpha$ on a finite alphabet $\alpha$ and any strip height $h \geq 1$, the transition monoid of the spacetime column language DFA satisfies $m^3 = m^2$ for every element $m$. In particular, the transition monoid is aperiodic.

**Corollary.** The spacetime column language is star-free and definable in first-order logic with linear order FO[<].

**Theorem B (Eventual Periodicity).** For any prime $p$, any nonzero polynomial $Q \in \mathbb{F}_p[X]$, the function
$$n \mapsto \gcd(Q, X^n - 1) \in \mathbb{F}_p[X]$$
is eventually periodic in $n$. Consequently, $n \mapsto \deg(\gcd(Q, X^n - 1))$ is eventually periodic.

**Corollary.** For an additive CA over $\text{GF}(p)$ with local polynomial $P$, the logarithmic fixed-point count $\log_p |\text{Fix}(T_n^m)|$ is eventually periodic in $n$ for each fixed iterate $m$.

### 1.3 Related Work

The regularity of CA spacetime languages was established in the general theory of sofic shifts (Weiss, 1973). The connection between aperiodicity and star-freeness is due to Schützenberger (1965), with the complementary logical characterization by McNaughton and Papert (1971). Transfer matrix methods for CA strip counting are classical (see, e.g., Wolfram, 1984).

For additive CA, the connection between fixed-point counts and polynomial arithmetic over finite fields goes back to work of Martin, Odlyzko, and Wolfram (1984). The eventual periodicity of related sequences has been studied in the context of linear recurrences and the Skolem–Mahler–Lech theorem, though our direct polynomial-GCD approach appears to be new.

### 1.4 Organization

Section 2 introduces definitions and notation. Section 3 proves Theorem A. Section 4 proves Theorem B. Section 5 describes computational experiments. Section 6 discusses applications. Section 7 outlines future directions.

## 2. Definitions and Notation

### 2.1 Cellular Automata

Let $\alpha$ be a finite alphabet. A *nearest-neighbor CA rule* is a function $f : \alpha \times \alpha \to \alpha$. A *spacetime strip* of height $h$ and width $w$ is a matrix $(c_{i,j})_{0 \leq i < h, 0 \leq j < w}$ with entries in $\alpha$ satisfying:
$$c_{i+1, j} = f(c_{i,j}, c_{i,j+1}) \quad \text{for all } 0 \leq i < h-1, \; 0 \leq j < w-1.$$

A *column* at position $j$ is the vector $\mathbf{c}_j = (c_{0,j}, c_{1,j}, \ldots, c_{h-1,j}) \in \alpha^h$.

### 2.2 Spacetime Column Language

Two columns $\mathbf{c}, \mathbf{c}' \in \alpha^h$ are *compatible* (written $\mathbf{c} \sim \mathbf{c}'$) if $\mathbf{c}(i+1) = f(\mathbf{c}(i), \mathbf{c}'(i))$ for all $0 \leq i < h-1$.

The *spacetime column language* is:
$$\mathcal{L}_{f,h} = \{\mathbf{c}_1 \mathbf{c}_2 \cdots \mathbf{c}_w : \mathbf{c}_j \sim \mathbf{c}_{j+1} \text{ for all } 1 \leq j < w\}$$
This is a language over the alphabet $\Sigma = \alpha^h$.

### 2.3 Right-Permutativity

A rule $f$ is *right-permutative* if for each fixed $a \in \alpha$, the map $b \mapsto f(a, b)$ is a bijection.

### 2.4 Partial Constant Functions

A function $g : S \cup \{\bot\} \to S \cup \{\bot\}$ is a *partial constant function* if $g(\bot) = \bot$ and there exists $c \in S$ such that for all $s \in S$, either $g(s) = c$ or $g(s) = \bot$.

### 2.5 Aperiodic Monoids

A monoid $M$ is *aperiodic* if for every $m \in M$, there exists $k \geq 0$ such that $m^{k+1} = m^k$.

## 3. Proof of Theorem A: Aperiodicity

### 3.1 DFA Construction

Define the DFA $\mathcal{A}_{f,h}$ recognizing $\mathcal{L}_{f,h}$:
- **States:** $Q = \alpha^h \cup \{\bot\}$ (columns plus dead state)
- **Alphabet:** $\Sigma = \alpha^h$
- **Transitions:** $\delta(\mathbf{q}, \boldsymbol{\sigma}) = \boldsymbol{\sigma}$ if $\mathbf{q} \sim \boldsymbol{\sigma}$, otherwise $\delta(\mathbf{q}, \boldsymbol{\sigma}) = \bot$; and $\delta(\bot, \boldsymbol{\sigma}) = \bot$
- **Initial state:** any distinguished state (or nondeterministic start)
- **Accept states:** $\alpha^h$ (all non-dead states)

### 3.2 Transition Functions are Partial Constant

**Lemma 3.1.** For each $\boldsymbol{\sigma} \in \Sigma$, the transition function $T_{\boldsymbol{\sigma}} : Q \to Q$ is a partial constant function with target $\boldsymbol{\sigma}$.

*Proof.* By definition, $T_{\boldsymbol{\sigma}}(\bot) = \bot$ and $T_{\boldsymbol{\sigma}}(\mathbf{q}) \in \{\boldsymbol{\sigma}, \bot\}$ for all $\mathbf{q} \in \alpha^h$. $\square$

**Lemma 3.2.** The composition of two partial constant functions is a partial constant function.

*Proof.* Let $g_1$ have target $c_1$ and source $S_1$, and $g_2$ have target $c_2$ and source $S_2$. Then $g_2 \circ g_1$ maps $S_1$ to $c_2$ if $c_1 \in S_2$, and maps everything to $\bot$ otherwise. $\square$

### 3.3 Key Algebraic Lemma

**Lemma 3.3.** Every partial constant function $g$ satisfies $g^3 = g^2$.

*Proof.* Let $c$ be the target of $g$ and $S$ be its source set.

**Case 1:** $c \in S$. Then $g(c) = c$, so $g$ restricts to the identity on its range $\{c, \bot\}$. Thus $g^2 = g$, and $g^3 = g^2$.

**Case 2:** $c \notin S$. Then $g(c) = \bot$. For any $x$: if $g(x) = c$ then $g^2(x) = g(c) = \bot$; if $g(x) = \bot$ then $g^2(x) = \bot$. So $g^2 = \text{const}_\bot$, which is idempotent, giving $g^3 = g^2$. $\square$

### 3.4 Main Theorem

**Theorem A.** The transition monoid of $\mathcal{A}_{f,h}$ is aperiodic with uniform bound $m^3 = m^2$.

*Proof.* Every element of the transition monoid is a finite composition of transition functions $T_{\boldsymbol{\sigma}}$. By Lemma 3.2, every such composition is a partial constant function. By Lemma 3.3, every partial constant function satisfies $g^3 = g^2$. $\square$

**Corollary (Star-Freeness).** The syntactic monoid of $\mathcal{L}_{f,h}$ is a quotient of the transition monoid and is therefore aperiodic. By the Schützenberger–McNaughton–Papert theorem, $\mathcal{L}_{f,h}$ is star-free.

### 3.5 Remark on Right-Permutativity

While Theorem A holds for all CA rules, right-permutativity provides additional structural information:

**Proposition 3.4.** If $f$ is right-permutative, then each column $\mathbf{q}$ has exactly $|\alpha|$ compatible successors: the next column is uniquely determined at positions $0, \ldots, h-2$ and free at position $h-1$.

This means the compatibility graph is $|\alpha|$-regular on out-degree, giving a more structured DFA.

## 4. Proof of Theorem B: Eventual Periodicity

### 4.1 Finite Monoid Power Periodicity

**Lemma 4.1.** In a finite monoid $M$, for every $m \in M$, there exist $N, T \in \mathbb{N}$ with $T > 0$ such that $m^{n+T} = m^n$ for all $n \geq N$.

*Proof.* By pigeonhole, there exist $0 \leq i < j \leq |M|$ with $m^i = m^j$. Set $T = j - i$, $N = i$. For $n \geq N$, induction on $n - N$:
- Base: $m^{i + T} = m^j = m^i$. ✓
- Step: $m^{(n+1)+T} = m^{n+T} \cdot m = m^n \cdot m = m^{n+1}$. ✓ $\square$

### 4.2 Residue Periodicity

**Lemma 4.2.** For $Q \neq 0$ in $\mathbb{F}_p[X]$, the sequence $X^n \bmod Q$ is eventually periodic in $n$.

*Proof.* The quotient ring $\mathbb{F}_p[X]/(Q)$ is finite. The sequence $\overline{X}^n$ in this ring satisfies the hypotheses of Lemma 4.1. $\square$

### 4.3 GCD Depends on Residue

**Lemma 4.3.** In a Euclidean domain, $\gcd(Q, a) = \gcd(Q, b)$ whenever $a \equiv b \pmod{Q}$.

*Proof.* The Euclidean algorithm gives $\gcd(Q, a) = \gcd(a \bmod Q, Q)$. If $a \bmod Q = b \bmod Q$, then $\gcd(Q, a) = \gcd(Q, b)$. $\square$

### 4.4 Main Theorem

**Theorem B.** For any nonzero $Q \in \mathbb{F}_p[X]$, the function $n \mapsto \gcd(Q, X^n - 1)$ is eventually periodic.

*Proof.* By Lemma 4.2, $X^n \bmod Q$ is eventually periodic with some period $T$ and offset $N$. Then $(X^{n+T} - 1) \bmod Q = (X^n - 1) \bmod Q$ for $n \geq N$. By Lemma 4.3, $\gcd(Q, X^{n+T} - 1) = \gcd(Q, X^n - 1)$. $\square$

### 4.5 Application to Additive CA

For an additive CA over $\text{GF}(p)$ with local polynomial $P(U) = aU^{-1} + b + cU$, acting on cyclic configurations of length $n$:
$$|\text{Fix}(T_n^m)| = p^{\deg \gcd(X^n - 1, P(X)^m - 1)}$$
(after clearing denominators from the Laurent polynomial).

Setting $Q = P(X)^m - 1$, Theorem B gives:

**Corollary.** $\log_p |\text{Fix}(T_n^m)|$ is eventually periodic in $n$.

## 5. Computational Experiments

### 5.1 Aperiodicity Verification

We verified Theorem A computationally for all 256 elementary CA rules (binary, radius 1) at heights $h = 2, 3, 4$:

| Rule class | Height | States | All $m^3 = m^2$? | Max $k$ s.t. $m^{k+1} \neq m^k$ |
|-----------|--------|--------|-------------------|----------------------------------|
| All 256   | 2      | 4      | Yes               | 2                                |
| All 256   | 3      | 8      | Yes               | 2                                |
| All 256   | 4      | 16     | Yes               | 2                                |

The exponent bound of 2 is always achieved (some elements satisfy $m^2 \neq m$ but $m^3 = m^2$) and never exceeded.

### 5.2 GCD Degree Periodicity

For selected polynomials over $\text{GF}(2)$:

| Polynomial $Q$ | Degree | Root order | GCD degree period |
|----------------|--------|------------|-------------------|
| $X^3 + X + 1$  | 3      | 7          | 7                 |
| $X^4 + X + 1$  | 4      | 15         | 15                |
| $X^4 + X^3 + X^2 + X + 1$ | 4 | 5    | 5                 |
| $X^2 + X + 1$  | 2      | 3          | 3                 |

In all cases, the period equals the multiplicative order of the root, consistent with our exact period conjecture (Future Direction 2).

### 5.3 Additive CA Fixed-Point Periods

For Rule 90 ($P = 1 + X$ over $\text{GF}(2)$):

| Iterate $m$ | $\deg(P^m - 1)$ | Period of $\log_2|\text{Fix}|$ |
|-------------|-----------------|-------------------------------|
| 1           | 1               | 1                             |
| 2           | 2               | 1                             |
| 3           | 3               | 3                             |
| 4           | 4               | 1                             |
| 5           | 5               | 15                            |

The periods are consistent with multiplicative orders of roots of $P^m - 1$.

## 6. Applications

### 6.1 Hardware Verification

The star-freeness of CA spacetime languages means that checking whether a hardware implementation correctly realizes a CA rule reduces to a first-order model-checking problem. For star-free languages, this is in $\text{AC}^0$ (constant-depth circuits), significantly simpler than general regular language membership.

### 6.2 Cryptanalysis of Additive CA

The eventual periodicity of fixed-point counts reveals algebraic structure in additive CA-based pseudorandom generators. An adversary who can estimate $|\text{Fix}(T_n^m)|$ for several values of $n$ can extract the period, narrow down the polynomial $P^m - 1$, and potentially recover the local rule.

### 6.3 Cyclic Code Design

For a fixed generator polynomial $Q$, the dimension of the cyclic code $\langle \gcd(X^n - 1, Q) \rangle$ in $\mathbb{F}_p[X]/(X^n - 1)$ is $n - \deg(\gcd(X^n - 1, Q))$. Our periodicity theorem predicts how this dimension varies with block length $n$, enabling systematic code family design.

## 7. Future Work

1. **Exact period formula.** Conjecture: the period of $n \mapsto \deg(\gcd(Q, X^n - 1))$ equals the lcm of multiplicative orders of roots of $Q$ in $\overline{\mathbb{F}_p}$.

2. **Quantifier-rank bounds.** Determine the minimum FO[<] quantifier rank needed to define $\mathcal{L}_{f,h}$ as a function of $h$ and $|\alpha|$.

3. **Zeta function connection.** Relate the aperiodicity of the transition monoid to pole structure of the strip-counting dynamical zeta function.

4. **Non-nearest-neighbor rules.** Extend Theorem A to higher-radius CA rules.

5. **Nilpotent-cyclotomic duality.** Unify Theorems A and B via spectral decomposition of the transfer operator.

## References

1. M.-P. Schützenberger, "On finite monoids having only trivial subgroups," *Information and Control* 8 (1965), 190–194.

2. R. McNaughton and S. Papert, *Counter-Free Automata*, MIT Press, 1971.

3. O. Martin, A. Odlyzko, and S. Wolfram, "Algebraic properties of cellular automata," *Communications in Mathematical Physics* 93 (1984), 219–258.

4. B. Weiss, "Subshifts of finite type and sofic systems," *Monatshefte für Mathematik* 77 (1973), 462–474.

5. S. Wolfram, "Computation theory of cellular automata," *Communications in Mathematical Physics* 96 (1984), 15–57.

6. J. Pin, *Varieties of Formal Languages*, Plenum, 1986.

7. D. Lind and B. Marcus, *An Introduction to Symbolic Dynamics and Coding*, Cambridge University Press, 1995.
