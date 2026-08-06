# Submultiplicative Search Entropy and the Perron Root

### A bridge between the combinatorics of proof search, Fekete's subadditive lemma, and the spectral theory of nonnegative matrices

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

We develop a theory of *proof-search dimension*: a dimensionless invariant, taking values in $[0,1]$, that measures the asymptotic density of successful search prefixes inside an ambient finitely branching search tree. The theory rests on a single, extremely weak hypothesis. Calling a function $N : \mathbb{N} \to \mathbb{R}$ a **search profile** when $N(n) \ge 1$ for all $n$ and $N(m+n) \le N(m)N(n)$, we prove that the finite-scale rates $\log N(n)/n$ always converge, that the limit is the greatest lower bound of those rates, and that after normalization by $\log b$ the resulting **proof-search dimension** lies in $[0,1]$ whenever $N(n) \le b^n$. The infimum characterization gives the theory unusual practical force: *every* finite prefix count is a rigorous upper bound on the asymptotic dimension.

We then identify the invariant in the case of finite-state pruning. For a nonnegative $k \times k$ transition matrix $A$, the total path count $P(n) = \sum_{i,j}(A^n)_{ij}$ is shown to be submultiplicative, hence a search profile. If $A$ admits a strictly positive eigenvector $v$ with $0 < c \le v_i \le C$ for an eigenvalue $r > 0$ — the Perron situation of a strongly connected automaton — we prove a two-sided sandwich
$$c\,P(n) \;\le\; r^n \textstyle\sum_i v_i \;\le\; C\,P(n),$$
from which the **Bridge Theorem** follows: the entropy of the pruned search is exactly $\log r$, and its proof-search dimension relative to a $b$-ary ambient tree is $\log r/\log b$.

The bridge carries traffic in both directions. Combining the infimum characterization with the Bridge Theorem yields the purely linear-algebraic **Perron Domination Inequality** $r^n \le \sum_{i,j}(A^n)_{ij}$ valid for *every* $n$, with no asymptotics. Two worked instances close the paper: the scalar case, which recovers the classical similarity dimension $\log s/\log b$; and the two-state "no two consecutive expensive steps" automaton inside the binary tree, whose path counts are the Fibonacci numbers $F_{n+3}$, whose Perron root is the golden ratio $\varphi$, whose proof-search dimension is $\log\varphi/\log 2 \approx 0.6942$, and for which the domination inequality specializes to $\varphi^n \le F_{n+3}$.

**Keywords:** proof-search dimension, submultiplicative sequences, Fekete's subadditive lemma, entropy rate, nonnegative matrices, Perron root, finite-state pruning, golden ratio, Fibonacci numbers.

---

## 1. Introduction

### 1.1 The problem

Automated reasoning takes place in a tree. The root is a goal; each node offers finitely many inference steps; each step spawns a child. If every node offers exactly $b$ alternatives, the tree has $b^n$ nodes at depth $n$, and any exhaustive strategy is hopeless past very modest depths.

What makes search feasible in practice is *pruning*. A large majority of branches can be killed early: they introduce unsatisfiable side conditions, they loop, they violate a term ordering, they exceed a resource budget. Once killed, an entire subtree disappears. The surviving structure — the set of partial paths that are still candidates for extension to a complete proof — is a sparse, irregular subtree of the full $b$-ary tree.

The question this paper answers is: **how sparse, exactly?** We want a single number that quantifies the asymptotic density of the surviving subtree, that is robust to local irregularity, that is bounded by finite measurements, and that can be *computed* whenever the pruning rule is implementable in bounded memory.

### 1.2 The answer, in one line

The number is
$$\dim \;=\; \frac{1}{\log b}\lim_{n\to\infty}\frac{\log N(n)}{n},$$
where $N(n)$ counts surviving prefixes of length $n$. It always exists. It lies in $[0,1]$. For finite-state pruning it equals $\log r/\log b$, where $r$ is the Perron root of the pruning automaton's transition matrix.

### 1.3 Three strands

The development braids three classically separate threads.

* **Combinatorics of search trees.** The objects being measured are counts of accepted paths in a pruned tree, and the essential structural input is the fact that a path of length $m+n$ decomposes into a length-$m$ prefix and a length-$n$ suffix.
* **Real analysis.** The existence of the limit is Fekete's subadditive lemma (1923), applied to $a_n = \log N(n)$. The identification of the limit with the infimum is the part of Fekete's lemma that gives the theory its practical bite.
* **Spectral theory of nonnegative matrices.** Perron's theorem (1907) and its Frobenius extension (1912) supply, for a strongly connected automaton, a strictly positive eigenvector whose existence converts the asymptotic entropy into an explicit eigenvalue.

The point of the bridge is not that any of these three is difficult in isolation. It is that the composite object — the dimension of a proof-search space — is a genuinely new invariant whose finiteness, computability, and robustness all follow, and whose specialization to concrete pruning rules produces recognizable constants.

### 1.4 Contributions

1. The definition of a **search profile** and its **entropy rate** and **proof-search dimension**, with full proofs that the rate exists, equals the infimum of the finite-scale rates, is nonnegative, and yields a dimension in $[0,1]$ (Section 3).
2. **Submultiplicativity of matrix path counts** for arbitrary nonnegative square matrices (Theorem 4.3), a self-contained combinatorial rearrangement.
3. The **Perron sandwich** (Theorem 4.6): a positive eigenvector traps $P(n)$ between constant multiples of $r^n$, proved without spectral decomposition.
4. The **Bridge Theorem** (Theorem 5.2) and its dimension form (Corollary 5.3), identifying entropy with $\log r$ and dimension with $\log r/\log b$.
5. The **Perron Domination Inequality** (Theorem 5.6): $r^n \le \sum_{i,j}(A^n)_{ij}$ for all $n$ — an asymptotics-free consequence of an asymptotic theorem.
6. Worked instances: the scalar/similarity case (Section 6.1) and the Fibonacci automaton with dimension $\log\varphi/\log 2$ and the corollary $\varphi^n \le F_{n+3}$ (Section 6.2).

---

## 2. Setting and motivation for the axioms

### 2.1 Search languages

Fix an ambient branching factor $b \ge 2$. A *search space* is a subtree $T$ of the full $b$-ary tree $\{1,\dots,b\}^*$, closed under taking prefixes: if a word $w$ is in $T$, so is every prefix of $w$. Elements of $T$ of length $n$ are the **successful prefixes of length $n$** — search states at depth $n$ that have survived pruning. We write
$$N(n) \;=\; \#\{w \in T : |w| = n\}.$$

Two properties of $N$ organize everything that follows.

**(P1) Nondegeneracy: $N(n) \ge 1$.** There is at least one live path at every depth. In a search for a proof that exists, this holds by definition; we take it as an axiom because without it the logarithms are undefined and the theory has nothing to measure.

**(P2) Submultiplicativity: $N(m+n) \le N(m)N(n)$.** Every surviving path of length $m+n$ is determined by its length-$m$ prefix (at most $N(m)$ choices) together with its length-$n$ continuation. In a *shift-invariant* search language — one in which the set of legal continuations from any live state is itself a search language of the same type, which is the situation for any rule whose applicability depends only on bounded local data — the number of continuations is at most $N(n)$. The inequality is typically strict, because most (prefix, suffix) pairs do not concatenate to a live word.

It is worth emphasizing how *little* (P1)–(P2) assume. There is no self-similarity, no monotonicity, no regularity, no algebraic structure, no recursion. The counts may fluctuate wildly. Nevertheless (P1)–(P2) alone force the existence of a well-defined asymptotic growth exponent.

### 2.2 Why a dimension and not a count

One might ask for the raw counts rather than an exponent. The answer is that the counts are not invariants: they depend on incidental encoding choices (how many nodes a single conceptual inference step is split into, whether trivial bookkeeping moves are recorded). The *exponent* is what survives. Rescaling depth by a constant factor $\lambda$ replaces $N(n)$ by roughly $N(\lambda n)$ and multiplies the entropy by $\lambda$; but if the ambient branching is rescaled compatibly, the ratio $h/\log b$ is unchanged. The dimension is the encoding-independent content of the counts.

---

## 3. Search profiles, entropy, and dimension

### 3.1 Definition

**Definition 3.1 (Search profile).** A **search profile** is a function $N : \mathbb{N} \to \mathbb{R}$ satisfying
1. $N(n) \ge 1$ for all $n \in \mathbb{N}$;
2. $N(m+n) \le N(m)\,N(n)$ for all $m, n \in \mathbb{N}$.

In particular $N(n) > 0$ for all $n$, so $\log N(n)$ is defined and $\log N(n) \ge 0$.

**Definition 3.2 (Finite-scale rate).** For $n \ge 1$, the **finite-scale rate** of $N$ at $n$ is
$$\mathrm{rate}(n) \;=\; \frac{\log N(n)}{n}.$$

**Lemma 3.3.** $\mathrm{rate}(n) \ge 0$ for all $n \ge 1$.

*Proof.* $\log N(n) \ge \log 1 = 0$ and $n > 0$. $\square$

**Definition 3.4 (Entropy rate).** The **entropy rate** (or growth rate) of a search profile $N$ is
$$h(N) \;=\; \inf_{n \ge 1} \mathrm{rate}(n) \;=\; \inf_{n\ge 1} \frac{\log N(n)}{n}.$$
By Lemma 3.3 the set $\{\mathrm{rate}(n) : n \ge 1\}$ is nonempty and bounded below by $0$, so the infimum exists and is finite.

### 3.2 Subadditivity of the logarithm

**Lemma 3.5.** If $N$ is a search profile then $a_n := \log N(n)$ is subadditive: $a_{m+n} \le a_m + a_n$.

*Proof.* Since $N(m+n) \le N(m)N(n)$ and both sides are positive, monotonicity of $\log$ gives $\log N(m+n) \le \log(N(m)N(n)) = \log N(m) + \log N(n)$. $\square$

This is the entire bridge between the multiplicative combinatorics and the additive analysis, and it is the reason the axioms were stated multiplicatively in the first place.

### 3.3 The Search Entropy Theorem

**Theorem 3.6 (Search Entropy Theorem).** Let $N$ be a search profile. Then
$$\lim_{n\to\infty} \frac{\log N(n)}{n} \;=\; h(N) \;=\; \inf_{n\ge 1}\frac{\log N(n)}{n},$$
and $h(N) \ge 0$. Moreover $h(N)$ is the greatest lower bound of the set of finite-scale rates $\{\mathrm{rate}(n): n \ge 1\}$.

*Proof sketch.* By Lemma 3.5, $a_n = \log N(n)$ is subadditive, and by Lemma 3.3 the ratios $a_n/n$ are bounded below by $0$. Fekete's subadditive lemma applies verbatim: for a subadditive sequence with $\inf_n a_n/n > -\infty$, one has $a_n/n \to \inf_n a_n/n$.

For completeness we recall the mechanism. Fix $m \ge 1$ and let $L = \inf_{n\ge1} a_n/n$. Given $\varepsilon > 0$, choose $m$ with $a_m/m < L + \varepsilon$. Write an arbitrary $n$ as $n = qm + s$ with $0 \le s < m$. Iterating subadditivity gives $a_n \le q\,a_m + a_s$, whence
$$\frac{a_n}{n} \;\le\; \frac{q m}{n}\cdot\frac{a_m}{m} \;+\; \frac{a_s}{n}.$$
As $n \to \infty$ with $m$ fixed, $qm/n \to 1$ and $a_s/n \to 0$ (there are only finitely many values of $a_s$). Hence $\limsup_n a_n/n \le a_m/m < L + \varepsilon$. Since $\varepsilon$ was arbitrary, $\limsup_n a_n/n \le L$. The reverse inequality $\liminf_n a_n/n \ge L$ is immediate from the definition of the infimum. Nonnegativity of $h(N)$ follows since every $\mathrm{rate}(n) \ge 0$. The greatest-lower-bound statement is the definition of the infimum together with the fact that the set is nonempty and bounded below. $\square$

**Remark 3.7 (Why the infimum matters).** The statement $h(N) = \inf_n \mathrm{rate}(n)$ is much stronger than "the limit exists." It says that
$$h(N) \;\le\; \frac{\log N(n)}{n} \qquad \text{for every } n \ge 1. \tag{3.1}$$
Any single finite computation of $N(n)$ therefore yields a *proved* upper bound on the asymptotic entropy, with no error term and no convergence assumption. This is unusual. In most asymptotic theories, a finite measurement is at best evidence. Here it is a theorem, and deeper computations only tighten it monotonically in the sense that the infimum over larger index sets is smaller. Inequality (3.1) is also, as we shall see in Section 5.4, the engine behind the Perron Domination Inequality.

### 3.4 Proof-search dimension

**Definition 3.8 (Proof-search dimension).** Let $N$ be a search profile and $b > 1$. The **proof-search dimension** of $N$ relative to ambient branching factor $b$ is
$$\dim_b(N) \;=\; \frac{h(N)}{\log b}.$$

**Theorem 3.9 (Dimension bounds).** Let $N$ be a search profile.
1. If $b \ge 1$ then $\dim_b(N) \ge 0$.
2. If $b > 1$ and $N(n) \le b^n$ for all $n$, then $\dim_b(N) \le 1$.

*Proof.* (1) $h(N) \ge 0$ by Theorem 3.6 and $\log b \ge 0$.
(2) Applying the hypothesis at $n = 1$ gives $N(1) \le b$, hence $\mathrm{rate}(1) = \log N(1) \le \log b$. By (3.1), $h(N) \le \mathrm{rate}(1) \le \log b$. Dividing by $\log b > 0$ gives $\dim_b(N) \le 1$. $\square$

The proof of (2) is a one-liner precisely because of the infimum characterization: the bound at scale $1$ already controls the asymptotics. More generally, $N(n) \le b^n$ for a single value of $n$ suffices.

**Remark 3.10 (Interpretation).** The formula $h/\log b$ is the *similarity dimension* of classical fractal geometry, transplanted. A self-similar set retaining $s$ of $b$ pieces at each scale has similarity dimension $\log s/\log b$; a search retaining $s$ of $b$ branches at each level has proof-search dimension $\log s/\log b$. The set of infinite live paths, viewed inside the boundary $\{1,\dots,b\}^{\mathbb{N}}$ of the ambient tree with the ultrametric $d(x,y) = b^{-|x \wedge y|}$ (where $x\wedge y$ is the longest common prefix), is a compact, typically Cantor-like set, and the entropy is measuring its box-counting size: the ball of radius $b^{-n}$ around a point is exactly the cylinder of depth $n$, and $N(n)$ is exactly the number of such balls needed to cover the boundary. That the entropy rate coincides with the *Hausdorff* dimension of this boundary is expected but requires a separate mass-distribution argument; see Section 8.

**Remark 3.11 (What the dimension does not see).** The dimension is a property of the counting function alone, hence of the *geometry* of the search space. It is invariant under any rearrangement of the tree that preserves the level counts. In particular two search instances may have identical profiles — hence identical dimension — while a fixed traversal policy (depth-first, say) finds a proof immediately in one and only after an arbitrarily long detour in the other. Search cost $=$ geometry $\times$ policy, and the dimension isolates the first factor. This is a feature: it quantifies exactly the part of the difficulty that no reordering can remove.

---

## 4. Finite-state pruning and nonnegative matrices

We now specialize to pruning rules with bounded memory, where the entropy becomes computable.

### 4.1 The transition matrix

Let the pruning rule be governed by a finite set of states $\{1,\dots,k\}$: the legality of a move depends only on the current state, and taking a legal move deterministically updates the state. Encode this by the **transition matrix** $A \in \mathbb{R}^{k\times k}$ with
$$A_{ij} \;=\; \#\{\text{legal moves carrying state } i \text{ to state } j\}.$$
Such a matrix is entrywise nonnegative. (We allow real nonnegative entries throughout; the combinatorial case is the integer one.)

**Lemma 4.1 (Nonnegativity of powers).** If $A_{ij} \ge 0$ for all $i,j$, then $(A^n)_{ij} \ge 0$ for all $n \ge 0$ and all $i,j$.

*Proof.* Induction on $n$. For $n = 0$, $A^0 = I$ has entries $0$ and $1$. For the step, $(A^{n+1})_{ij} = \sum_\ell (A^n)_{i\ell} A_{\ell j}$ is a sum of products of nonnegative reals. $\square$

**Definition 4.2 (Path count).** For a nonnegative $A \in \mathbb{R}^{k\times k}$, set
$$P(n) \;=\; \sum_{i=1}^k \sum_{j=1}^k (A^n)_{ij}.$$
When $A$ is an integer matrix, $P(n)$ is the number of accepted paths of length $n$ in the automaton, over all choices of initial and final state; $P(n) \ge 0$ by Lemma 4.1.

### 4.2 Submultiplicativity of path counts

**Theorem 4.3 (Path counts are submultiplicative).** For every nonnegative $A \in \mathbb{R}^{k\times k}$ and all $m,n \ge 0$,
$$P(m+n) \;\le\; P(m)\,P(n).$$

*Proof.* Define, for each intermediate state $\ell$,
$$f(\ell) = \sum_{i}(A^m)_{i\ell} \quad(\text{length-}m \text{ paths ending at } \ell), \qquad g(\ell) = \sum_{j}(A^n)_{\ell j}\quad(\text{length-}n\text{ paths starting at }\ell).$$
Both are nonnegative by Lemma 4.1, and by exchanging summation orders,
$$P(m) = \sum_\ell f(\ell), \qquad P(n) = \sum_\ell g(\ell).$$
Expanding $A^{m+n} = A^m A^n$ entrywise and reordering the (finite) triple sum,
$$P(m+n) \;=\; \sum_i\sum_j\sum_\ell (A^m)_{i\ell}(A^n)_{\ell j} \;=\; \sum_\ell \Big(\sum_i (A^m)_{i\ell}\Big)\Big(\sum_j (A^n)_{\ell j}\Big) \;=\; \sum_\ell f(\ell)g(\ell).$$
On the other hand $P(m)P(n) = \big(\sum_\ell f(\ell)\big)\big(\sum_{\ell'} g(\ell')\big) = \sum_\ell f(\ell)\,\big(\sum_{\ell'}g(\ell')\big)$. Since all $g(\ell')\ge 0$, we have $g(\ell) \le \sum_{\ell'} g(\ell')$ for each $\ell$, and multiplying by $f(\ell)\ge 0$ and summing over $\ell$ gives
$$\sum_\ell f(\ell)g(\ell) \;\le\; \sum_\ell f(\ell)\Big(\sum_{\ell'}g(\ell')\Big) \;=\; P(m)P(n). \qquad\square$$

Conceptually: concatenation requires the endpoint of the first path to match the start of the second, whereas the product $P(m)P(n)$ pays for *all* pairings. The defect is exactly the mismatched pairs.

**Corollary 4.4 (Automaton profile).** If additionally $P(n) \ge 1$ for all $n$, then $P$ is a search profile in the sense of Definition 3.1, and Theorems 3.6 and 3.9 apply to it. (The condition $P(n) \ge 1$ holds, for instance, whenever $A$ is a nonzero nonnegative integer matrix with no zero row, or more simply whenever the automaton accepts at least one path of each length.)

### 4.3 Perron eigenvectors control path counts

**Lemma 4.5 (Eigenvectors of powers).** If $Av = rv$ then $A^n v = r^n v$ for all $n \ge 0$.

*Proof.* Induction: $A^0 v = v = r^0 v$, and $A^{n+1}v = A(A^n v) = A(r^n v) = r^n (Av) = r^n r v = r^{n+1}v$. $\square$

**Theorem 4.6 (Perron sandwich).** Let $A \in \mathbb{R}^{k\times k}$ be nonnegative, and suppose there exist $v \in \mathbb{R}^k$, constants $0 < c \le C$, and $r \in \mathbb{R}$ with
$$c \le v_i \le C \ \ \text{for all } i, \qquad Av = r\,v.$$
Then for every $n \ge 0$,
$$c\,P(n) \;\le\; r^n \sum_{i} v_i \;\le\; C\,P(n).$$

*Proof.* By Lemma 4.5, for each row index $i$,
$$\sum_j (A^n)_{ij}\,v_j \;=\; r^n v_i. \tag{4.1}$$
All entries $(A^n)_{ij}$ are nonnegative (Lemma 4.1).

*Lower bound.* Replacing $v_j$ by $c \le v_j$ in (4.1) decreases the left side termwise:
$$c\sum_j (A^n)_{ij} \;=\; \sum_j (A^n)_{ij}\,c \;\le\; \sum_j (A^n)_{ij} v_j \;=\; r^n v_i.$$
Summing over $i$ gives $c\,P(n) \le r^n\sum_i v_i$.

*Upper bound.* Replacing $v_j$ by $C \ge v_j$ increases it termwise:
$$r^n v_i \;=\; \sum_j (A^n)_{ij}v_j \;\le\; \sum_j (A^n)_{ij}\,C \;=\; C\sum_j (A^n)_{ij}.$$
Summing over $i$ gives $r^n\sum_i v_i \le C\,P(n)$. $\square$

The proof uses no spectral decomposition, no Jordan form, no complex analysis, and no assumption that $r$ is the *largest* eigenvalue. All that is needed is one eigenvector with coordinates bounded away from $0$ and $\infty$. In the classical Perron–Frobenius situation — $A$ irreducible (equivalently, the automaton strongly connected) — such a $v$ exists automatically, with $r$ equal to the spectral radius $\rho(A)$; the theorem above isolates the exact consequence of that theorem which the analysis requires.

**Remark 4.7.** The sandwich says $P(n) = \Theta(r^n)$ with explicit constants: writing $S = \sum_i v_i$,
$$\frac{S}{C}\,r^n \;\le\; P(n) \;\le\; \frac{S}{c}\,r^n.$$
Path counts are exponential with base exactly $r$, up to a bounded multiplicative fluctuation living in the interval $[S/C, S/c]$, whose width $C/c$ is the "spread" of the eigenvector.

---

## 5. The Bridge Theorem

### 5.1 A squeeze lemma

**Lemma 5.1 (Logarithmic squeeze).** Let $N : \mathbb{N}\to\mathbb{R}$, and suppose there are constants $0 < c' \le C'$ and $r > 0$ with
$$c'\,r^n \;\le\; N(n) \;\le\; C'\,r^n \qquad \text{for all } n.$$
Then $\displaystyle\lim_{n\to\infty}\frac{\log N(n)}{n} = \log r$.

*Proof.* For any constant $\kappa > 0$,
$$\frac{\log(\kappa\, r^n)}{n} \;=\; \frac{\log \kappa}{n} + \log r \;\longrightarrow\; \log r$$
as $n \to \infty$, since $\log\kappa/n \to 0$. Applying this to $\kappa = c'$ and $\kappa = C'$ and using monotonicity of $\log$ on the sandwich $c'r^n \le N(n) \le C'r^n$ (all quantities positive), the sequence $\log N(n)/n$ is squeezed between two sequences both converging to $\log r$. $\square$

### 5.2 The main theorem

**Theorem 5.2 (Bridge Theorem: linear algebra $\leftrightarrow$ search entropy).** Let $k \ge 1$, let $A \in \mathbb{R}^{k\times k}$ be nonnegative, and suppose $A$ admits an eigenvector $v$ with $0 < c \le v_i \le C$ for an eigenvalue $r > 0$. Then the normalized logarithmic growth rate of the path counts exists and equals $\log r$:
$$\lim_{n\to\infty} \frac{\log P(n)}{n} \;=\; \log r, \qquad P(n) = \sum_{i,j}(A^n)_{ij}.$$

*Proof.* Set $S = \sum_i v_i$. Since $k \ge 1$ and each $v_i \ge c > 0$, we have $S > 0$; also $C \ge v_1 \ge c > 0$. By Theorem 4.6,
$$\frac{S}{C}\,r^n \;\le\; P(n) \;\le\; \frac{S}{c}\,r^n$$
for every $n$, with $0 < S/C \le S/c$. Lemma 5.1 with $c' = S/C$, $C' = S/c$ gives the claim. $\square$

**Corollary 5.3 (Dimension form).** Under the hypotheses of Theorem 5.2, and for an ambient branching factor $b > 1$,
$$\lim_{n\to\infty}\frac{\log P(n)}{n\log b} \;=\; \frac{\log r}{\log b}.$$
That is, the proof-search dimension of a Perron-controlled finite-state pruned search inside a $b$-ary tree is $\log r/\log b$.

*Proof.* Divide the conclusion of Theorem 5.2 by the nonzero constant $\log b$. $\square$

### 5.3 Fekete meets Perron

**Theorem 5.4 (Identification of the Fekete rate).** Let $A$ be as in Theorem 5.2 and assume additionally $P(n) \ge 1$ for all $n$, so that $P$ is a search profile (Corollary 4.4). Then
$$h(P) \;=\; \inf_{n\ge 1}\frac{\log P(n)}{n} \;=\; \log r.$$

*Proof.* Theorem 3.6 says $\log P(n)/n \to h(P)$; Theorem 5.2 says $\log P(n)/n \to \log r$. Limits in $\mathbb{R}$ are unique. $\square$

**Corollary 5.5 (Dimension of the automaton profile).** With the same hypotheses and $b > 1$,
$$\dim_b(P) \;=\; \frac{\log r}{\log b}.$$

This is the sharpest form of the bridge: the Fekete infimum — a purely analytic object defined by an infimum over all scales — coincides with a purely algebraic one, the logarithm of a Perron eigenvalue.

### 5.4 Traffic in the reverse direction

The Fekete infimum characterization now pays an unexpected dividend.

**Theorem 5.6 (Perron Domination Inequality).** Let $A \in \mathbb{R}^{k\times k}$ ($k \ge 1$) be nonnegative with $P(n) \ge 1$ for all $n$, and suppose $A$ admits an eigenvector $v$ with $0 < c \le v_i \le C$ for an eigenvalue $r > 0$. Then for **every** $n \ge 0$,
$$r^n \;\le\; \sum_{i,j}(A^n)_{ij}.$$

*Proof.* For $n = 0$ the claim is $1 \le P(0)$, which is the hypothesis. Let $n \ge 1$. By Theorem 5.4, $h(P) = \log r$, and by the infimum characterization (3.1) applied to the search profile $P$,
$$\log r \;=\; h(P) \;\le\; \frac{\log P(n)}{n}.$$
Multiplying by $n > 0$ gives $n\log r \le \log P(n)$, i.e. $\log(r^n) \le \log P(n)$. Both $r^n > 0$ and $P(n) \ge 1 > 0$, so strict monotonicity of $\log$ on $(0,\infty)$ gives $r^n \le P(n)$. $\square$

**Remark 5.7.** Theorem 5.6 contains no limits, no asymptotics, and no error terms: it is a finite inequality about matrix powers, valid at every $n$. Yet the proof runs through an entropy that only exists in the limit. This is exactly the leverage provided by the infimum half of Fekete's lemma: an asymptotic quantity that is simultaneously a *uniform lower bound* on all finite-scale rates transfers information from $n = \infty$ back to every finite $n$. Direct proofs of $r^n \le P(n)$ are of course available (sum (4.1) over $i$ and use $v_i \le C$, $\sum_i v_i \ge kc$, then optimize), but they must be arranged by hand for each situation; the entropy route is uniform.

---

## 6. Worked instances

### 6.1 The scalar case: recovering the similarity dimension

Take $k = 1$ and $A = (s)$ with $s > 0$. This models a *uniformly self-similar* search: at each level, exactly $s$ of the available branches extend to a proof, with no state dependence.

**Proposition 6.1.** $P(n) = s^n$ for all $n \ge 0$.

*Proof.* $A^n = (s^n)$ by induction, and the sum of the entries of a $1\times 1$ matrix is its unique entry. $\square$

The vector $v = (1)$ is a strictly positive eigenvector with eigenvalue $r = s$ and $c = C = 1$, so Theorem 5.2 and Corollary 5.3 apply.

**Theorem 6.2 (Similarity dimension).** For $s > 0$ and $b > 1$, the uniform $s$-successful branching profile inside a $b$-ary tree has
$$\lim_{n\to\infty} \frac{\log P(n)}{n \log b} \;=\; \frac{\log s}{\log b}.$$

This is the classical similarity dimension. Some sanity checks: $s = b$ gives dimension $1$ (no pruning); $s = 1$ gives dimension $0$ (a single live path — pruning is complete and search is deterministic); $s = 2$, $b = 3$ gives $\log 2/\log 3 \approx 0.6309$, the dimension of the middle-thirds Cantor set. Formally, the boundary of the surviving tree in that case *is* a Cantor set. The general theory therefore strictly extends fractal similarity dimension, replacing exact self-similarity by mere submultiplicativity.

### 6.2 The Fibonacci pruning automaton and the golden ratio

Inside the **binary** search tree ($b = 2$), impose the pruning rule:

> *never use two "expensive" inference steps in a row.*

Concretely: at each node one of the two available moves is "expensive" (a case split, a heavy decision procedure, an instantiation of a costly lemma) and the other is "cheap"; the rule forbids consecutive expensive moves. One bit of memory suffices: state $1$ = "last move was cheap", state $2$ = "last move was expensive". From state $1$ both moves are legal (to state $1$ via the cheap one, to state $2$ via the expensive one); from state $2$ only the cheap move is legal (returning to state $1$). The transition matrix is
$$A = \begin{pmatrix} 1 & 1\\ 1 & 0\end{pmatrix}.$$

**Lemma 6.3.** $A^2 = A + I$.

*Proof.* $A^2 = \begin{pmatrix}2&1\\1&1\end{pmatrix} = \begin{pmatrix}1&1\\1&0\end{pmatrix} + \begin{pmatrix}1&0\\0&1\end{pmatrix}$. $\square$

**Proposition 6.4 (Fibonacci recursion for path counts).** $P(n+2) = P(n+1) + P(n)$ for all $n \ge 0$.

*Proof.* From Lemma 6.3, $A^{n+2} = A^n A^2 = A^n(A + I) = A^{n+1} + A^n$. Summing all entries (a linear operation) gives the recursion. $\square$

**Theorem 6.5 (Path counts are Fibonacci numbers).** With $F_1 = F_2 = 1$ and $F_{m+2} = F_{m+1} + F_m$,
$$P(n) \;=\; F_{n+3} \qquad\text{for all } n \ge 0.$$

*Proof.* Base cases: $P(0) = \sum_{i,j} I_{ij} = 2 = F_3$ and $P(1) = 1+1+1+0 = 3 = F_4$. The inductive step is Proposition 6.4 together with the Fibonacci recursion $F_{n+5} = F_{n+4} + F_{n+3}$. $\square$

Thus the number of surviving prefixes is $2, 3, 5, 8, 13, 21, 34, 55, 89, \dots$

**Lemma 6.6 (Golden eigenvector).** Let $\varphi = (1+\sqrt5)/2$, the positive root of $\lambda^2 = \lambda + 1$. Then
$$A\begin{pmatrix}\varphi\\1\end{pmatrix} = \begin{pmatrix}\varphi + 1\\ \varphi\end{pmatrix} = \varphi\begin{pmatrix}\varphi\\1\end{pmatrix},$$
using $\varphi^2 = \varphi + 1$. The eigenvector has coordinates bounded by $c = 1 \le v_i \le \varphi = C$, since $1 < \varphi$.

**Theorem 6.7 (Golden-ratio proof-search dimension).** The Fibonacci-pruned binary search space has proof-search dimension
$$\lim_{n\to\infty}\frac{\log P(n)}{n\log 2} \;=\; \frac{\log\varphi}{\log 2} \;\approx\; 0.694242.$$

*Proof.* Apply Corollary 5.3 with $k = 2$, $A$ as above (nonnegative), $v = (\varphi,1)$, $c = 1$, $C = \varphi$, $r = \varphi > 0$, $b = 2 > 1$. $\square$

**Interpretation.** A single bit of memory in the pruning rule reduces the dimension of the search space from $1$ to $\approx 0.6942$. Concretely, at depth $100$ the unpruned binary tree has $2^{100}\approx 1.27\times10^{30}$ nodes, while the pruned tree has $F_{103}\approx 1.5\times 10^{21}$ — a reduction by more than eight orders of magnitude, and the gap grows as $2^{n(1 - 0.6942)} = 2^{0.3058\,n}$. The point is that pruning does not change the problem from exponential to polynomial; it lowers the *base* of the exponential, and the dimension records precisely by how much.

**Corollary 6.8 (Golden powers are dominated by Fibonacci numbers).** For every $n \ge 0$,
$$\varphi^n \;\le\; F_{n+3}.$$

*Proof.* All hypotheses of Theorem 5.6 hold: $A$ is nonnegative, $P(n) = F_{n+3} \ge 1$ for all $n \ge 0$, and $(\varphi,1)$ is a positive eigenvector for $r = \varphi > 0$. So $\varphi^n \le P(n) = F_{n+3}$. $\square$

Numerically: $\varphi^{10}\approx 122.99 \le 233 = F_{13}$; $\varphi^{20}\approx 15127.0 \le 28657 = F_{23}$. The gap tends to the constant $F_{n+3}/\varphi^n \to \varphi^3/\sqrt5 \approx 1.894$, consistent with the sandwich constants $S/C = (\varphi+1)/\varphi \approx 1.618$ and $S/c = \varphi + 1 \approx 2.618$ of Remark 4.7. (Indeed $1.618 \le 1.894 \le 2.618$.)

---

## 7. Algorithms

The theory is constructive. We record the three computational procedures it supports.

### 7.1 Certified entropy bracketing

**Input:** a procedure computing $N(n)$ for a search profile; a depth budget $M$.
**Output:** a certified upper bound $\overline{h} = \min_{1\le n\le M}\log N(n)/n$ on the entropy, and (when the profile is known to be Perron-controlled with spread $C/c$) a matching lower bound.

By (3.1) the upper bound is unconditional: no matter how the profile behaves beyond depth $M$, the true entropy is at most $\overline h$. In the Perron-controlled case, Remark 4.7 also gives $\log P(n)/n \ge \log r + \log(S/C)/n$, so the finite-scale rate overestimates $\log r$ by at most $|\log(C/c)|/n$; the bracket has width $O(1/n)$ and is therefore explicitly certifiable.

Complexity: dominated by the cost of computing $N(n)$ for $n \le M$. For finite-state pruning with a $k \times k$ matrix, computing $P(1),\dots,P(M)$ by iterated multiplication costs $O(Mk^3)$ arithmetic operations, or $O(Mk^2)$ if one propagates the row-sum vector $u^{(n)} = A^n \mathbf{1}$ instead, since $P(n) = \mathbf{1}^\top u^{(n)}$ and $u^{(n+1)} = A u^{(n)}$.

### 7.2 Perron root by scaled power iteration

**Input:** a nonnegative $k\times k$ matrix $A$ with a positive eigenvector; a tolerance $\varepsilon$.
**Output:** the Perron root $r$ and its eigenvector $v$.

Iterate $x^{(n+1)} = A x^{(n)}/\|Ax^{(n)}\|_1$ from a positive start, and estimate $r$ by the Rayleigh-type quotient $\|Ax^{(n)}\|_1$. Under primitivity the convergence is geometric with ratio $|\lambda_2|/r$, where $\lambda_2$ is the second-largest eigenvalue in modulus; each iteration costs $O(k^2)$. The dimension is then $\log r/\log b$.

An attractive feature is that the output is *self-certifying*: given the computed $v$ (normalized so $\min_i v_i = c$, $\max_i v_i = C$) and the exact residual bounds $\underline r = \min_i (Av)_i/v_i$ and $\overline r = \max_i (Av)_i/v_i$, the Collatz–Wielandt inequalities give $\underline r \le r \le \overline r$, and Theorem 4.6 applied with $\underline r$ and $\overline r$ yields rigorous two-sided bounds on $P(n)$ for all $n$.

### 7.3 Automaton synthesis from a local pruning rule

**Input:** a pruning predicate depending on the last $w$ moves in a $b$-ary tree.
**Output:** the transition matrix of the corresponding automaton, and hence the dimension.

Take the state space to be the set of legal windows of length $w-1$, i.e. $\{1,\dots,b\}^{w-1}$ restricted to those that violate no constraint, and set $A_{uv} = 1$ when $v$ is obtained from $u$ by appending a legal symbol and dropping the first. The matrix has at most $b^{w-1}$ rows and at most $b$ nonzeros per row. This is the standard construction of a *sofic subshift* from a finite list of forbidden words; the resulting dimension $\log \rho(A)/\log b$ is the topological entropy of that subshift, normalized. The Fibonacci automaton of Section 6.2 is the case $b = 2$, $w = 2$, forbidden word "expensive-expensive".

---

## 8. Discussion

### 8.1 What has been achieved

Three claims deserve emphasis.

**Extreme generality of the existence theorem.** The Search Entropy Theorem assumes nothing beyond $N(n) \ge 1$ and submultiplicativity. It does not require the search space to be self-similar, or the branching to be uniform, or the pruning to be memoryless, or the counts to be monotone. In particular it applies to search spaces whose structure varies arbitrarily from level to level, provided only the composition inequality holds.

**Finite computations are theorems.** The identification of the limit with the infimum turns any finite prefix count into a proved upper bound. Combined with the Perron lower bound, this makes the dimension of a finite-state pruned search an explicitly bracketable quantity.

**A two-way bridge.** The reverse consequence — $r^n \le \sum_{i,j}(A^n)_{ij}$ for all $n$, specializing to $\varphi^n \le F_{n+3}$ — shows that the connection is not merely an application of linear algebra to combinatorics. Information flows back: an asymptotic entropy statement, because Fekete's limit is an infimum, yields uniform finite inequalities in linear algebra.

### 8.2 Relation to neighbouring theories

The framework sits at the intersection of several established bodies of work.

* **Symbolic dynamics.** For a finite-state pruning rule, the set of infinite accepted paths is exactly a *sofic shift*, and the entropy computed here is its topological entropy $\log\rho(A)$. The novelty is not the entropy formula but the *proof-search reading*: the ambient normalization by $\log b$, the interpretation of $\dim$ as a density of surviving proof attempts, and the extension of the existence statement to arbitrary submultiplicative profiles that need not come from any shift.
* **Fractal geometry.** Definition 3.8 is the similarity dimension, and Remark 3.10 explains the box-counting interpretation. The theory generalizes exact self-similarity to submultiplicativity, and Section 6.1 shows the generalization is conservative.
* **Branching processes.** A Galton–Watson tree with mean offspring $\mu$ has, almost surely on survival, boundary Hausdorff dimension $\log\mu/\log b$. The present theory is the deterministic analogue, with the Perron root playing the role of $\mu$; the ergodic extension conjectured in Section 9 would interpolate.
* **Proof complexity.** The dimension is a *lower-bound-friendly* quantity: it bounds below the number of nodes any complete search must in principle be prepared to examine, uniformly in the traversal policy. It is not a bound on the cost of a *particular* search, for the reason discussed in Remark 3.11.

### 8.3 Limitations

Three honest caveats.

1. **The positive-eigenvector hypothesis.** Theorem 5.2 assumes the existence of $v$ with $0 < c \le v_i \le C$. For irreducible nonnegative $A$ this is a consequence of Perron–Frobenius, but the reducible case is not covered: a block-triangular $A$ may have a spectral radius realized only on a subset of states, with no globally positive eigenvector.
2. **Dimension is not cost.** As emphasized, the invariant sees only the counting function.
3. **Hausdorff dimension is not yet established.** The box-counting/entropy identity is proved; the identification with Hausdorff dimension requires a mass-distribution argument (Section 9).

---

## 9. Future directions

### 9.1 Entropy dimension for genuinely submultiplicative search languages

Let $N(n)$ be the number of successful prefixes of length $n$ in a finitely branching search language with $N(n+m)\le N(n)N(m)$ and $N(n)\ge 1$. The normalized logarithmic growth rate exists and equals the infimum of the finite-scale rates — this half is settled above (Theorem 3.6). It is conjectured that, under a compatible ultrametric and a finite-type extension condition, this rate also equals the **Hausdorff dimension** of the infinite successful-path boundary. The key insight is that exact additivity of finite profiles is replaced by subadditivity while the relative-entropy normalization survives intact; the finite multiscale composition law identifies precisely which quantity must persist when exact self-similarity is weakened. The natural route is a mass-distribution principle applied to the measure defined by the Perron eigenvector on cylinders.

### 9.2 Ergodic branching and almost-sure dimension

For a stationary ergodic sequence of ambient and successful branching pairs $(B_n, S_n)$ with $1 \le S_n \le B_n$ and suitable logarithmic integrability, the almost-sure proof-search dimension should be
$$\frac{\mathbb{E}[\log S_0]}{\mathbb{E}[\log B_0]}.$$
The key insight is that logarithmic path volumes are additive cocycles, so their ratio converges by ergodic averaging (Birkhoff). The deterministic theory above supplies the exact finite-block identity whose random-block limit this predicts.

### 9.3 Dimension spectrum under finite-state pruning

For successful paths accepted by a strongly connected finite-state pruning automaton over a fixed $b$-ary tree, the dimension is $\log\rho(A)/\log b$ with $\rho(A)$ the spectral radius. Corollary 5.5 proves this under the explicit hypothesis of a strictly positive eigenvector; removing that hypothesis in favour of irreducibility requires the full Perron–Frobenius existence theorem. A separate route, covering even the reducible case, is **Gelfand's formula**: since $P(n)$ is the sum-of-entries norm of $A^n$ and that norm is submultiplicative (Theorem 4.3), one expects $h = \log\rho(A)$ for every nonnegative $A$ with $\rho(A) > 0$, via $\rho(A) = \lim_n\|A^n\|^{1/n}$.

A companion question is **realizability**: which numbers arise as $\log\rho(A)/\log b$? Since $\rho(A)$ ranges over Perron numbers of nonnegative integer matrices — a restrictive and well-understood class of algebraic integers — the conjecture is that every algebraic number arising as such a normalized Perron root is realized by a finite-state proof-search geometry. The insight is that scalar products of branching numbers generalize to matrix products, with Perron growth replacing ordinary multiplication.

### 9.4 Policy-sensitive search cost at fixed dimension

For every rational $d \in (0,1)$ and every computable unbounded $f$, there should exist two finitely branching search instances with the same successful-prefix dimension $d$ but deterministic depth-first discovery costs whose ratio exceeds $f(n)$ at infinitely many depths. The key insight is that dimension measures abundance whereas a policy measures ordering: adversarial rearrangement preserves all prefix counts while moving successful terminals arbitrarily late. The present entropy laws characterize the geometry sharply enough to isolate the independent contribution of traversal policy.

### 9.5 Stability under sparse adversarial perturbations

If two nonstationary branching profiles differ on a set of levels of asymptotic density zero, and their branching numbers are uniformly bounded above and bounded below away from unary degeneration, their limiting relative-entropy dimensions should agree whenever either limit exists. The key insight is that sparse changes contribute only sublinear error to both logarithmic volumes; repetition invariance and weighted composition supply the finite-block algebra needed to quantify the effect of exceptional blocks.

---

## 10. Conclusion

A proof-search space possesses a dimension. It exists under hypotheses so weak — nondegeneracy and submultiplicativity of prefix counts — that essentially any realistic search satisfies them. It is normalized to lie in $[0,1]$, with $0$ meaning "essentially a single path" and $1$ meaning "pruning has failed". Every finite measurement of prefix counts is a rigorous upper bound on it. And whenever the pruning rule is implementable with finite memory, the dimension is not an abstraction but an eigenvalue: take the transition matrix, compute its Perron root $r$, and read off $\log r/\log b$.

The theory is conservative — it recovers the classical similarity dimension in the uniform case — and it produces recognizable constants in the simplest nontrivial instance: forbidding two consecutive expensive inference steps in a binary search tree yields Fibonacci prefix counts, golden-ratio growth, and dimension $\log\varphi/\log 2 \approx 0.6942$. Running the bridge backwards recovers $\varphi^n \le F_{n+3}$, a finite inequality obtained from an asymptotic theorem because Fekete's limit is an infimum.

What the framework offers, beyond the specific theorems, is a way of thinking. Exponential growth is exponential growth, whether it occurs in a fractal, in the powers of a nonnegative matrix, or in the branching tree of everything one might try next. Once the three settings are recognized as the same setting, results transfer freely in every direction.
