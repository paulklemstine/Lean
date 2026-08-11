# Adjacency–Degree Algebras, Cyclic Modules, and the Moment Rigidity of Graphs

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $G$ be a finite simple graph with adjacency matrix $A_G$ and diagonal degree matrix $D_G$. McKay proved that the collection of spectra of all polynomial functions of $A_G$ and $D_G$ determines a tree up to isomorphism. We study a *principal* — that is, single-scalar — refinement of this invariant: the family of **word moments** $m_G(w) = \mathbf 1^{\mathsf T} w(A_G, D_G)\mathbf 1$, where $w$ ranges over words in the two-letter alphabet $\{A, D\}$ and $\mathbf 1$ is the all-ones vector. We situate these moments inside the **adjacency–degree algebra** $\mathcal A(G) = \langle I, A_G, D_G\rangle$, its **cyclic module** $M_G = \mathcal A(G)\mathbf 1$, and the **orbit module** $U_G$ of automorphism-invariant vectors.

We establish the following. (i) $M_G \subseteq U_G$ for every finite simple graph, and $M_G$ equals the line $\mathbb R\mathbf 1$ if and only if $G$ is regular. (ii) All word moments are isomorphism invariants, and every word moment admits a caterpillar normal form: $\mathbf 1^{\mathsf T} D^{a_0}AD^{a_1}A\cdots AD^{a_n}\mathbf 1$ equals the sum over all walks of length $n$ of the degree decoration $\prod_i d_{p_i}^{a_i}$, i.e. a degree-decorated caterpillar homomorphism count. (iii) Moment equality forces equality of the order, the size, the degree distribution, the joint degree distribution along edges, and — in full generality — of *every* degree-decorated walk statistic; conversely those decorated walk counts recover all moments, so the two invariants have exactly the same discriminating strength. (iv) The moments are computed on the colour-refinement quotient: for any equitable colouring with quotient matrix $B$ and class-degree vector $\Delta$ one has $\mathbf 1^{\mathsf T} w(A,D)\mathbf 1 = \sum_\kappa |\kappa|\,(w(B,\Delta)\mathbf 1)_\kappa$. Hence the moment-rigidity class lies strictly inside the one-dimensional Weisfeiler–Leman hierarchy: it is blind on regular graphs of fixed degree and order, and already fails on an explicit connected, non-regular six-vertex pair. (v) Adjoining the all-ones matrix $J = \mathbf 1\mathbf 1^{\mathsf T}$ and passing to the ideal $\mathcal A(G)J\mathcal A(G)$ produces no new scalar data, since $\mathbf 1^{\mathsf T} XJY\mathbf 1 = (\mathbf 1^{\mathsf T} X\mathbf 1)(\mathbf 1^{\mathsf T} Y\mathbf 1)$. (vi) Positively, a degree-transitivity criterion yields $M_G = U_G$, which holds in particular for the infinite family of stars, and stars are determined by their moments.

Together these results delimit the determination theorem sharply and reduce the outstanding "principal McKay" statement for trees to a purely combinatorial reconstruction problem about decorated walk counts.

**Keywords:** adjacency matrix, degree matrix, cyclic module, graph moments, caterpillar homomorphism counts, colour refinement, Weisfeiler–Leman, spectral determination of trees, tight-binding Hamiltonian.

---

## 1. Introduction

### 1.1 Two operators on a network

Let $G = (V, E)$ be a finite simple graph. Its **adjacency matrix** $A_G \in \mathbb R^{V\times V}$ has entries
$$(A_G)_{uv} = \begin{cases} 1 & uv \in E,\\ 0 & \text{otherwise,}\end{cases}$$
and its **degree matrix** $D_G$ is the diagonal matrix with $(D_G)_{vv} = d_v := \deg_G(v)$.

Physically these are the two canonical ingredients of a tight-binding Hamiltonian on the network: $A_G$ is the hopping term, allowing an excitation to move along an edge, and $D_G$ is the most intrinsic on-site potential the graph itself supplies. The graph Laplacian $L_G = D_G - A_G$ is the simplest combination of the two, but there is no reason to stop there: any noncommutative polynomial in $A_G$ and $D_G$ is a legitimate observable, and one may ask how much of the network is encoded in the family of all such observables.

### 1.2 Cospectrality and McKay's theorem

The spectrum of $A_G$ alone is a weak invariant: cospectral non-isomorphic graphs are abundant, and asymptotically almost every tree has a cospectral mate. McKay's theorem repairs this in the tree world: the collection of spectra of *all* polynomial functions of $A_G$ and $D_G$ determines a tree up to isomorphism. Adding the degree potential is exactly enough to break tree cospectrality.

Spectra, however, are heavy objects. This paper studies the lightest possible shadow of McKay's data — a single real number per polynomial — and asks how much survives.

### 1.3 The principal invariant

**Definition 1.1 (Word moment).** Let $\Sigma = \{A, D\}$ be a two-letter alphabet and interpret a word $w = \ell_1 \ell_2 \cdots \ell_k \in \Sigma^*$ as the matrix product
$$w(A_G, D_G) = M_{\ell_1} M_{\ell_2}\cdots M_{\ell_k}, \qquad M_A = A_G,\ M_D = D_G,$$
with the empty word giving the identity. The **word moment** of $w$ is the scalar
$$m_G(w) \;=\; \mathbf 1^{\mathsf T}\, w(A_G, D_G)\, \mathbf 1 \;=\; \sum_{u\in V}\sum_{v \in V} \bigl(w(A_G,D_G)\bigr)_{uv}.$$
The **moment data** of $G$ is the function $w \mapsto m_G(w)$ on $\Sigma^*$. Two graphs $G$, $G'$ are **moment-equivalent**, written $G \equiv_m G'$, if $m_G(w) = m_{G'}(w)$ for all $w \in \Sigma^*$.

This is the "principal version" alluded to in the abstract: instead of the whole spectrum of $w(A,D)$ we retain only its uniform-state expectation, the amplitude for the uniform state $\mathbf 1$ to survive the action of $w$.

### 1.4 Contributions and organisation

Section 2 introduces the adjacency–degree algebra, its cyclic module, and the orbit module, and proves the two structural bounds (Theorems 2.5 and 2.8). Section 3 proves invariance of the moments and computes the basic examples. Section 4 establishes the caterpillar normal form and the homomorphism-count interpretation (Theorem 4.3). Section 5 extracts the combinatorial consequences of moment equality: degree distribution, joint degree distribution, and general decorated walk statistics (Theorems 5.2, 5.5, 5.8). Section 6 proves the exact-equivalence theorem between moments and decorated walk counts (Theorem 6.2). Section 7 locates the invariant inside colour refinement (Theorems 7.3 and 7.4) and derives the negative results, including the connected non-regular six-vertex witness (Theorem 7.8). Section 8 shows that the $J$-ideal adds nothing (Theorem 8.1) and proves the positive results for degree-transitive graphs and stars (Theorems 8.3, 8.5) and the resulting dichotomy (Theorem 8.6). Section 9 gives algorithms and complexity. Section 10 discusses applications and Section 11 states the open conjectures.

Throughout, all graphs are finite, simple, and undirected; $n = |V|$; and all matrices are real.

---

## 2. The adjacency–degree algebra and its modules

### 2.1 Definitions

**Definition 2.1.** The **adjacency–degree algebra** of $G$ is the unital $\mathbb R$-subalgebra of $\mathbb R^{V\times V}$ generated by the two matrices:
$$\mathcal A(G) \;=\; \langle I, A_G, D_G\rangle \;=\; \operatorname{span}_{\mathbb R}\{\, w(A_G,D_G) : w \in \Sigma^*\,\}.$$

Note that $A_G$ and $D_G$ commute only in the regular case, so $\mathcal A(G)$ is genuinely noncommutative in general; the second description above holds because the linear span of the words is already closed under multiplication and contains $I$.

**Definition 2.2 (Cyclic module).** The **cyclic module** of $G$ is
$$M_G \;=\; \mathcal A(G)\,\mathbf 1 \;=\; \{\, X\mathbf 1 : X \in \mathcal A(G)\,\} \;\subseteq\; \mathbb R^V,$$
the $\mathbb R$-linear span of the vectors $w(A_G,D_G)\mathbf 1$.

$M_G$ is exactly the state space that the moment data can probe: $m_G(w) = \langle \mathbf 1, w(A,D)\mathbf 1\rangle$ is the inner product of $\mathbf 1$ with an element of $M_G$, and conversely $M_G$ is spanned by such vectors.

**Definition 2.3 (Orbit module).** Let $\operatorname{Aut}(G)$ be the automorphism group of $G$. The **orbit module** is
$$U_G \;=\; \{\, f : V \to \mathbb R \ \mid\ f(\sigma v) = f(v) \text{ for all } \sigma \in \operatorname{Aut}(G),\ v \in V \,\},$$
the space of functions constant on automorphism orbits.

### 2.2 The ceiling: $M_G \subseteq U_G$

**Definition 2.4.** Call a matrix $X \in \mathbb R^{V \times V}$ **equivariant** if $X_{\sigma u, \sigma v} = X_{uv}$ for all $\sigma \in \operatorname{Aut}(G)$ and $u,v \in V$.

The equivariant matrices form a unital subalgebra: closure under addition and scalars is clear; closure under multiplication follows by reindexing the internal sum along the bijection $\sigma$,
$$(XY)_{\sigma u,\sigma v} = \sum_{t} X_{\sigma u, t}Y_{t,\sigma v} = \sum_{s} X_{\sigma u,\sigma s}Y_{\sigma s,\sigma v} = \sum_s X_{us}Y_{sv} = (XY)_{uv};$$
and scalar matrices are equivariant because $\sigma$ is injective, so $\sigma u = \sigma v$ iff $u = v$.

**Theorem 2.5 (Ceiling).** For every finite simple graph $G$, $\ M_G \subseteq U_G$.

*Proof sketch.* Both generators are equivariant. For $A_G$ this is the definition of an automorphism, $u\sim v \iff \sigma u \sim \sigma v$. For $D_G$ it follows from $\deg(\sigma v) = \deg(v)$ together with injectivity of $\sigma$ for the off-diagonal entries. Since the equivariant matrices form a unital algebra containing both generators, $\mathcal A(G)$ consists entirely of equivariant matrices. Finally, if $X$ is equivariant then
$$(X\mathbf 1)(\sigma v) = \sum_{u} X_{\sigma v, u} = \sum_{u} X_{\sigma v, \sigma u} = \sum_u X_{vu} = (X\mathbf 1)(v),$$
so $X\mathbf 1 \in U_G$. $\square$

This inclusion is the fundamental limitation of the whole approach: no algebraic combination of hopping and degree potential can ever separate vertices that the automorphism group already identifies.

A convenient general tool for bounding $M_G$ from above is the following, which we use repeatedly.

**Proposition 2.6 (Stability criterion).** Let $N \subseteq \mathbb R^V$ be a linear subspace with $\mathbf 1 \in N$, $A_G N \subseteq N$, and $D_G N \subseteq N$. Then $M_G \subseteq N$.

*Proof sketch.* The set of matrices $X$ with $XN \subseteq N$ is a unital subalgebra of $\mathbb R^{V\times V}$ (closure under products is immediate, and scalar matrices act by scaling). It contains $A_G$ and $D_G$ by hypothesis, hence contains $\mathcal A(G)$; applying any of its elements to $\mathbf 1 \in N$ stays in $N$. $\square$

### 2.3 The floor: collapse detects regularity

**Definition 2.7.** $G$ is **$k$-regular** if $d_v = k$ for every $v \in V$.

**Theorem 2.8 (Floor).** $M_G = \mathbb R\mathbf 1$ if and only if $G$ is regular.

*Proof sketch.* ($\Rightarrow$) If $M_G$ is the line through $\mathbf 1$ then $D_G\mathbf 1 \in \mathbb R\mathbf 1$; but $(D_G\mathbf 1)(v) = d_v$, so $d_v = c$ for a constant $c$ and all $v$, i.e. $G$ is regular. ($\Leftarrow$) If $G$ is $k$-regular, consider the algebra $\mathcal C$ of matrices with constant row sums, i.e. $X\mathbf 1 \in \mathbb R\mathbf 1$. It is a unital subalgebra: if $X\mathbf 1 = c\mathbf 1$ and $Y\mathbf 1 = c'\mathbf 1$ then $(XY)\mathbf 1 = c'\,c\,\mathbf 1$, and sums and scalars behave. Both $A_G\mathbf 1 = k\mathbf 1$ and $D_G\mathbf 1 = k\mathbf 1$ lie in $\mathcal C$, so $\mathcal A(G)\subseteq \mathcal C$ and $M_G \subseteq \mathbb R \mathbf 1$; the reverse inclusion holds since $I \in \mathcal A(G)$. $\square$

Thus the cyclic module is a *regularity detector*: its dimension is $1$ precisely for regular graphs, and any nontrivial degree variation immediately enlarges it.

---

## 3. Moments: invariance and first computations

**Theorem 3.1 (Isomorphism invariance).** If $f : G \to G'$ is a graph isomorphism, then for every word $w$ and all $u,v \in V(G)$,
$$\bigl(w(A_{G'},D_{G'})\bigr)_{f(u)f(v)} = \bigl(w(A_G,D_G)\bigr)_{uv},$$
and consequently $m_{G'}(w) = m_G(w)$.

*Proof sketch.* For a single letter the claim is the defining property of an isomorphism (for $A$) and degree preservation plus injectivity (for $D$). Induct on the length of $w$, reindexing the internal summation in the matrix product along the bijection $f$. Summing the entrywise identity over $u$ and $v$ and reindexing once more gives the moment statement. $\square$

**Proposition 3.2 (Basic moments).** For every graph $G$ on $n$ vertices:

1. $m_G(\varepsilon) = \mathbf 1^{\mathsf T} I \mathbf 1 = n$ (empty word).
2. $m_G(D^k) = \mathbf 1^{\mathsf T} D^k \mathbf 1 = \sum_{v} d_v^{\,k}$, the $k$-th degree power sum.
3. $m_G(A^k) = \mathbf 1^{\mathsf T} A^k\mathbf 1 = \sum_{u,v} \#\{\text{walks } u \to v \text{ of length } k\}$, the total number of walks of length $k$.
4. $m_G(A) = \sum_v d_v = 2|E|$.
5. $m_G(DAD) = \sum_{u,v} A_{uv} d_u d_v = 2\sum_{uv\in E} d_u d_v$, the first genuinely degree-decorated moment.

*Proof sketch.* (1) and (2) follow because $D^k$ is diagonal with entries $d_v^k$. (3) is the standard interpretation of powers of the adjacency matrix as walk counts. (4) is (3) with $k=1$ combined with the handshake identity $\sum_v d_v = 2|E|$. (5) expands the triple product using diagonality of $D$: the $(u,v)$ entry of $DAD$ is $d_u A_{uv} d_v$. $\square$

Item (5) is the first place where the interaction between hopping and potential becomes visible; note that $\sum_{uv\in E} d_u d_v$ is precisely the quantity whose normalised version is the degree assortativity coefficient of network science.

---

## 4. Caterpillar normal form

Because $D$ is diagonal, adjacent $D$'s in a word merge into a power, and every word is of the shape

$$W(a) \;=\; D^{a_0}\,A\,D^{a_1}\,A\cdots A\,D^{a_n}, \qquad a = (a_0,\dots,a_n) \in \mathbb N^{n+1}.$$

**Definition 4.1 (Caterpillar word).** For $n \ge 0$ and $a \in \mathbb N^{n+1}$ let $W(a)$ be the matrix above. Every word $w \in \Sigma^*$ equals $W(a)$ for a (unique) choice of $n$ and $a$: read $w$ left to right, letting $n$ be the number of $A$'s and $a_i$ the number of $D$'s between the $i$-th and $(i+1)$-st $A$.

**Definition 4.2 (Decorated weight).** For a tuple $p = (p_0,\dots,p_n) \in V^{n+1}$ set
$$\operatorname{wt}_a(p) \;=\; \Bigl(\prod_{i=0}^{n-1} (A_G)_{p_i p_{i+1}}\Bigr)\cdot \prod_{i=0}^{n}\, d_{p_i}^{\,a_i}.$$
The first factor is the indicator that $p$ is a walk; the second is the **degree decoration**.

**Theorem 4.3 (Caterpillar expansion).** For all $n \ge 0$ and $a \in \mathbb N^{n+1}$,
$$m_G\bigl(W(a)\bigr) \;=\; \sum_{p \in V^{n+1}} \operatorname{wt}_a(p) \;=\; \sum_{\substack{p_0 \sim p_1 \sim \cdots \sim p_n}} \ \prod_{i=0}^{n} d_{p_i}^{\,a_i},$$
where the last sum ranges over all walks of length $n$ in $G$ (repetitions of vertices allowed).

*Proof sketch.* Induct on $n$. For $n=0$, $W(a) = D^{a_0}$ is diagonal and $\mathbf 1^{\mathsf T} D^{a_0}\mathbf 1 = \sum_v d_v^{a_0}$. For the induction step, first compute the vector $W(a)\mathbf 1$ coordinatewise:
$$\bigl(W(a)\mathbf 1\bigr)(u) \;=\; d_u^{\,a_0}\sum_{w \in V} (A_G)_{uw}\,\bigl(W(a')\mathbf 1\bigr)(w), \qquad a' = (a_1,\dots,a_n),$$
using diagonality of $D^{a_0}$; by the inductive hypothesis the inner vector is the decorated walk sum with fixed start $w$, and peeling the leading vertex off the decorated weight gives
$$\operatorname{wt}_a(u,w,q) = d_u^{\,a_0}\cdot (A_G)_{uw}\cdot \operatorname{wt}_{a'}(w,q).$$
Summing over $u$ produces the stated identity. $\square$

**Corollary 4.4 (Homomorphism-count form).** Writing $P_n$ for the path with $n+1$ vertices,
$$m_G\bigl(W(a)\bigr) \;=\; \sum_{\varphi \in \operatorname{Hom}(P_n, G)} \ \prod_{i=0}^{n} d_{\varphi(i)}^{\,a_i}.$$
Since $d_v^{\,a}$ counts the ordered ways of attaching $a$ legs at $v$, the right-hand side is the number of homomorphisms into $G$ of the **caterpillar** obtained from the spine $P_n$ by attaching $a_i$ legs at its $i$-th vertex. Thus *word moments are degree-decorated caterpillar homomorphism counts*.

**Corollary 4.5 (Undecorated specialisation).** With $a \equiv 0$ one has $W(0) = A^n$, so $m_G(A^n)$ is the number of walk-tuples of length $n$; plain walk counts are the trivially decorated case.

Caterpillars are the natural home of this invariant. It is a classical theme that homomorphism counts from a family $\mathcal F$ determine exactly the equivalence relation "indistinguishable by $\mathcal F$"; here $\mathcal F$ is the family of caterpillars, a strictly larger family than paths and strictly smaller than all trees.

---

## 5. What moment equality determines

Throughout this section $G$ on $V$ and $G'$ on $W$ satisfy $G \equiv_m G'$.

### 5.1 Order and size

**Proposition 5.1.** $|V| = |W|$ and $|E(G)| = |E(G')|$.

*Proof sketch.* Take $w = \varepsilon$ and $w = A$ in Proposition 3.2(1),(4). $\square$

### 5.2 Degree distribution

Write $n = |V| = |W|$. Every degree satisfies $0 \le d_v \le n-1$, so all degrees lie in the known finite node set $\{0,1,\dots,n-1\}$.

**Lemma (Polynomial test functions).** If $\sum_{v\in V} d_v^k = \sum_{w \in W} d_w^k$ for all $k \ge 0$, then for every real polynomial $q$,
$$\sum_{v\in V} q(d_v) \;=\; \sum_{w\in W} q(d_w).$$
Indeed, expanding $q(x) = \sum_{i \le \deg q} q_i x^i$ and exchanging the order of summation writes each side as $\sum_i q_i \cdot (\text{$i$-th power sum})$.

**Theorem 5.2 (Degree distribution).** For every $d \in \mathbb N$,
$$\#\{v \in V : d_v = d\} \;=\; \#\{w \in W : d_w = d\}.$$

*Proof sketch.* The pure-degree moments give equality of all power sums (Proposition 3.2(2)). Let $\ell_d$ be the Lagrange basis polynomial on the nodes $\{0,1,\dots,n-1\}$ with $\ell_d(d) = 1$ and $\ell_d(j) = 0$ for $j \ne d$, $j$ in the node set. Since every degree is a node, $\sum_v \ell_d(d_v)$ counts exactly the vertices of degree $d$; apply the test-function lemma to $q = \ell_d$. For $d \ge n$ both sides are $0$. $\square$

This is the base level of the colour-refinement hierarchy: moment equality implies equality of the initial degree colouring.

### 5.3 Joint degree distribution

**Definition 5.3.** The **edge statistic** attached to polynomials $q, r$ is
$$S_G(q,r) \;=\; \sum_{u,v\in V} (A_G)_{uv}\, q(d_u)\, r(d_v).$$

**Lemma 5.4.** $S_G(q,r) = \sum_{i,j} q_i r_j\, m_G(D^i A D^j)$, a finite linear combination of word moments. Hence $G\equiv_m G'$ implies $S_G(q,r) = S_{G'}(q,r)$ for all $q,r$.

*Proof sketch.* By Proposition 3.2(5) generalised, $m_G(D^iAD^j) = \sum_{u,v} (A_G)_{uv} d_u^i d_v^j$; expand $q$ and $r$ into monomials and exchange summations. $\square$

**Definition.** $N_{a,b}(G) = \#\{(u,v)\in V^2 : u\sim v,\ d_u = a,\ d_v = b\}$, the ordered count of edges with prescribed endpoint degrees.

**Theorem 5.5 (Joint degree distribution).** $N_{a,b}(G) = N_{a,b}(G')$ for all $a,b \in \mathbb N$.

*Proof sketch.* For $a,b < n$ take $q = \ell_a$, $r = \ell_b$, the Lagrange indicators of Theorem 5.2. Then $q(d_u)r(d_v)$ is the indicator of $\{d_u = a,\ d_v = b\}$ and $S_G(\ell_a,\ell_b) = N_{a,b}(G)$. Apply Lemma 5.4. For $a\ge n$ or $b \ge n$ both counts vanish. $\square$

### 5.4 Arbitrary decorated walk statistics

The two previous results are the cases $n = 0$ and $n = 1$ of a general statement.

**Definition 5.6.** For $n \ge 0$ and arbitrary weight functions $f_i : \mathbb N \to \mathbb R$ ($0 \le i \le n$), the **decorated walk statistic** is
$$T_G(n; f) \;=\; \sum_{p \in V^{n+1}}\Bigl(\prod_{i<n} (A_G)_{p_ip_{i+1}}\Bigr)\prod_{i\le n} f_i(d_{p_i}) \;=\; \sum_{p_0\sim\cdots\sim p_n}\ \prod_{i=0}^n f_i(d_{p_i}).$$

**Lemma 5.7 (Polynomial case).** If each $f_i$ is the evaluation of a polynomial $q_i$, then $T_G(n;f)$ is the finite linear combination $\sum_{a} \bigl(\prod_i q_{i,a_i}\bigr) m_G(W(a))$ of caterpillar moments, where $a$ ranges over exponent vectors bounded by the degrees of the $q_i$.

*Proof sketch.* Expand each $q_i$ into monomials, exchange the finitely many summations, and recognise each resulting inner sum as a decorated walk sum, i.e. as $m_G(W(a))$ by Theorem 4.3. $\square$

**Theorem 5.8 (All decorated walk statistics).** If $G \equiv_m G'$ then $T_G(n;f) = T_{G'}(n;f)$ for every $n$ and every family of *arbitrary* weight functions $f_i : \mathbb N \to \mathbb R$.

*Proof sketch.* Only the values $f_i(d)$ for $d < n$ (where $n = |V| = |W|$) are ever used, since all degrees are $< n$. Replace each $f_i$ by the interpolating polynomial $q_i$ of degree $< n$ agreeing with $f_i$ on $\{0,\dots,n-1\}$. This changes neither $T_G$ nor $T_{G'}$, and Lemma 5.7 applies. $\square$

**Definition 5.9 (Decorated walk count).** For a degree pattern $b = (b_0,\dots,b_n) \in \mathbb N^{n+1}$,
$$c_G(n;b) \;=\; \#\{\,p_0\sim p_1\sim\cdots\sim p_n \ :\ d_{p_i} = b_i \text{ for all } i\,\}.$$

**Corollary 5.10.** $G \equiv_m G'$ implies $c_G(n;b) = c_{G'}(n;b)$ for all $n$ and $b$.

*Proof sketch.* Take $f_i = \chi_{\{b_i\}}$ in Theorem 5.8; the product of indicators is the indicator that $p$ realises the pattern $b$. $\square$

Specialising to $n = 0$ recovers Theorem 5.2, and to $n = 1$ recovers Theorem 5.5.

---

## 6. Exact equivalence with decorated caterpillar counts

Corollary 5.10 says the moments are at least as strong as the decorated walk counts. The converse also holds, so they are equally strong.

**Lemma 6.1 (Regrouping).** For every $n$ and $a \in \mathbb N^{n+1}$,
$$m_G\bigl(W(a)\bigr) \;=\; \sum_{b \in \{0,\dots,n-1\}^{n+1}} c_G(n;b)\ \prod_{i=0}^{n} b_i^{\,a_i}.$$

*Proof sketch.* Partition the walks of length $n$ according to their degree pattern $b$ (a well-defined map into a finite set, since all degrees are below $|V|$) and apply Theorem 4.3; the decoration is constant on each class. $\square$

**Theorem 6.2 (Equivalence).** Let $G$ and $G'$ have the same number of vertices. Then
$$\bigl(\forall n,a\ \ m_G(W(a)) = m_{G'}(W(a))\bigr) \iff \bigl(\forall n,b\ \ c_G(n;b) = c_{G'}(n;b)\bigr).$$
Since every word is a caterpillar word, the left-hand side is exactly moment equivalence $G \equiv_m G'$.

*Proof sketch.* ($\Rightarrow$) is Corollary 5.10. ($\Leftarrow$) is Lemma 6.1: both sides of the regrouping formula range over the same finite index set of patterns because the vertex counts agree, and the coefficients $\prod_i b_i^{a_i}$ depend only on $b$ and $a$, not on the graph. $\square$

**Interpretation.** The linear-algebraic invariant (uniform-state expectations of noncommutative polynomials in hopping and potential) and the combinatorial invariant (numbers of walks realising a prescribed degree pattern) are literally the same invariant. Any determination theorem for one is a determination theorem for the other. This is the technical pivot that converts the "principal McKay" question into a pure reconstruction problem.

---

## 7. Locating the invariant: colour refinement and its failures

### 7.1 Equitable partitions

**Definition 7.1.** A colouring $c : V \to C$ is **equitable** if for all $u,v \in V$ with $c(u) = c(v)$ and every colour $\kappa \in C$,
$$\#\{\,x \in N(u) : c(x) = \kappa\,\} \;=\; \#\{\,x \in N(v) : c(x) = \kappa\,\}.$$
The stable colouring produced by **colour refinement** (one-dimensional Weisfeiler–Leman: start from the constant colouring, iteratively refine by the multiset of neighbour colours) is equitable.

**Proposition 7.2.** An equitable colouring is degree-preserving: $c(u) = c(v)$ implies $d_u = d_v$, since summing the class-wise neighbour counts over all colours yields the degree.

**Theorem 7.3 (Module bound).** Let $c$ be an equitable colouring of $G$ and let
$$C_c = \{\,f : V \to \mathbb R \mid c(u) = c(v) \Rightarrow f(u) = f(v)\,\}$$
be the space of functions constant on colour classes. Then $M_G \subseteq C_c$.

*Proof sketch.* Apply the stability criterion (Proposition 2.6). Clearly $\mathbf 1 \in C_c$. If $f \in C_c$ then $f = g\circ c$ for some $g : C \to \mathbb R$, and
$$(A_G f)(u) \;=\; \sum_{x\in N(u)} f(x) \;=\; \sum_{\kappa \in C} g(\kappa)\cdot \#\{x \in N(u) : c(x) = \kappa\},$$
which depends only on $c(u)$ by equitability; so $A_G f \in C_c$. Similarly $(D_G f)(u) = d_u f(u)$ depends only on $c(u)$ by Proposition 7.2. $\square$

Since the orbit partition is equitable, Theorem 7.3 refines Theorem 2.5: the cyclic module is squeezed inside the *coarsest stable refinement* $\subseteq$ orbit module.

### 7.2 Moments live on the quotient

**Definition.** Given an equitable colouring $c$ with a system of representatives $\rho : C \to V$ satisfying $c(\rho(c(v))) = c(v)$, define the **quotient matrix** $B \in \mathbb R^{C\times C}$ by
$$B_{\kappa\lambda} \;=\; \#\{\,x \in N(\rho(\kappa)) : c(x) = \lambda\,\}$$
and the **quotient degree matrix** $\Delta = \operatorname{diag}\bigl(d_{\rho(\kappa)}\bigr)_{\kappa\in C}$. Write $|\kappa|$ for the class size.

**Theorem 7.4 (Quotient formula).** For every word $w$,
$$w(A_G, D_G)\,\mathbf 1 \;=\; \bigl(w(B,\Delta)\,\mathbf 1\bigr)\circ c \qquad\text{and hence}\qquad m_G(w) \;=\; \sum_{\kappa \in C} |\kappa|\cdot \bigl(w(B,\Delta)\mathbf 1\bigr)_\kappa.$$

*Proof sketch.* Induct on the length of $w$. The base case is $\mathbf 1 = \mathbf 1\circ c$. For the inductive step, if $w(A,D)\mathbf 1 = h \circ c$ with $h = w(B,\Delta)\mathbf 1$, then for the letter $A$,
$$\bigl(A_G (h\circ c)\bigr)(v) = \sum_{\lambda} h(\lambda)\,\#\{x \in N(v): c(x) = \lambda\} = \sum_\lambda B_{c(v)\lambda}h(\lambda) = (Bh)(c(v)),$$
using equitability and the representative property; for the letter $D$ it follows from $d_v = d_{\rho(c(v))}$, again by Proposition 7.2 and the representative property. The moment formula is obtained by summing over $v$ and grouping by colour class. $\square$

**Corollary 7.5 (Quotient rigidity).** If $G$ and $G'$ carry equitable colourings by the same colour set with equal class sizes, equal quotient matrices $B = B'$, and equal class degrees $\Delta = \Delta'$, then $G \equiv_m G'$ — whether or not $G \cong G'$.

This is the precise sense in which *moment rigidity lies inside the amenable, compact, refinable hierarchy of colour refinement*: the invariant is a function of the colour-refinement quotient alone.

### 7.3 Negative results

**Theorem 7.6 (Regular blindness).** If $G$ is $k$-regular on $n$ vertices, then $w(A_G,D_G)\mathbf 1 = k^{|w|}\mathbf 1$ and hence
$$m_G(w) \;=\; k^{|w|}\, n \qquad\text{for every word } w.$$
Consequently any two $k$-regular graphs of the same order are moment-equivalent.

*Proof sketch.* Induct on $|w|$: both $A_G\mathbf 1 = k\mathbf 1$ and $D_G\mathbf 1 = k\mathbf 1$, and each letter multiplies a scalar multiple of $\mathbf 1$ by $k$. Then $m_G(w) = \mathbf 1^{\mathsf T}(k^{|w|}\mathbf 1) = k^{|w|}n$. $\square$

**Corollary 7.7 (Six-vertex regular witness).** The cycle $C_6$ and the disjoint union $2K_3$ of two triangles are both $2$-regular on six vertices, hence moment-equivalent, but not isomorphic: $C_6$ is triangle-free while $2K_3$ contains the triangle $\{0,1,2\}$.

One might hope that connectivity plus irregularity restores determination. It does not.

**Theorem 7.8 (Connected non-regular witness).** Let
$$H_1 = \bigl(\{0,\dots,5\},\ \{03,04,05,13,15,23,24\}\bigr), \qquad H_2 = \bigl(\{0,\dots,5\},\ \{01,02,05,15,23,24,34\}\bigr).$$
Then:

1. Both are connected and non-regular, with degree sequence $(3,3,2,2,2,2)$;
2. $H_1 \equiv_m H_2$: all adjacency–degree word moments agree;
3. $H_1 \not\cong H_2$: $H_1$ is triangle-free (indeed bipartite, with parts $\{0,1,2\}$ and $\{3,4,5\}$) while $H_2$ contains the triangle $\{2,3,4\}$.

*Proof sketch.* In $H_1$ the degrees are $d_0 = d_3 = 3$ and $d_1=d_2=d_4=d_5=2$; in $H_2$ they are $d_0 = d_2 = 3$ and $d_1=d_3=d_4=d_5=2$. Colour by degree: classes of size $2$ and $4$ in both graphs. The colouring is equitable in both cases, and with representatives $0$ (degree-$3$ class) and $1$ (degree-$2$ class), each graph has quotient matrix
$$B = \begin{pmatrix} 1 & 2\\ 1 & 1\end{pmatrix}$$
(the degree-$3$ representative has one neighbour of degree $3$ and two of degree $2$; the degree-$2$ representative has one of each) and class degrees $\Delta = \operatorname{diag}(3,2)$. Corollary 7.5 gives (2). Connectivity is a direct check, and (3) follows from the triangle count. $\square$

Combining with Theorem 6.2:

**Corollary 7.9.** The degree-decorated caterpillar counts do not determine connected graphs: $H_1$ and $H_2$ have $c_{H_1}(n;b) = c_{H_2}(n;b)$ for every length $n$ and every degree pattern $b$, are both connected, and are non-isomorphic.

This is the sharp statement of the invariant's expressive ceiling, and it occurs already at six vertices. Its first *small-order* failures beyond the regular ones are exactly of this equitable-quotient type.

---

## 8. Enlarging the algebra, and where determination succeeds

### 8.1 The $J$-ideal adds no scalars

Let $J = \mathbf 1\mathbf 1^{\mathsf T}$ be the all-ones matrix and consider the ideal $\mathcal A(G)\,J\,\mathcal A(G)$. On $M_G$ this ideal is very large — for connected graphs it acts as the full endomorphism algebra of the module, which is the algebraic content behind the principal reformulation. At the level of scalars, however:

**Theorem 8.1 (Ideal factorisation).** For all $X, Y \in \mathbb R^{V\times V}$,
$$\mathbf 1^{\mathsf T} X J Y \mathbf 1 \;=\; \bigl(\mathbf 1^{\mathsf T} X \mathbf 1\bigr)\bigl(\mathbf 1^{\mathsf T} Y \mathbf 1\bigr).$$

*Proof sketch.* Entrywise, $(XJY)_{uv} = \sum_{s,t} X_{us}J_{st}Y_{tv} = \bigl(\sum_s X_{us}\bigr)\bigl(\sum_t Y_{tv}\bigr)$ since $J_{st} = 1$ always. Summing over $u,v$ factorises the double sum. $\square$

**Corollary 8.2.** Every moment of an element of $\mathcal A(G) J \mathcal A(G)$ is a product of word moments. The principal moment data is exactly the word data; enlarging the generating set by $J$ gains nothing scalar.

### 8.2 A criterion for $M_G = U_G$

Interpolation, which was used above on numbers, can also be used on the operator $D$.

**Lemma (Degree indicators).** For each $d$, let $\ell_d$ be the Lagrange basis polynomial on $\{0,1,\dots,n-1\}$ with $\ell_d(d) = 1$ and $\ell_d(j)=0$ for other nodes $j$. Then
$$\ell_d(D_G)\mathbf 1 \;=\; \chi_{\{v\, :\, d_v = d\}} \in M_G,$$
because $D^i\mathbf 1$ is the vector $v \mapsto d_v^{\,i}$ and $M_G$ is a linear space containing all such vectors. Hence **every function of the degree lies in $M_G$**: the module always contains the whole degree-partition module.

**Theorem 8.3 (Degree-transitivity criterion).** If any two vertices of equal degree are exchanged by some automorphism — i.e. $d_u = d_v \Rightarrow \exists\sigma\in\operatorname{Aut}(G),\ \sigma(u) = v$ — then $M_G = U_G$.

*Proof sketch.* "$\subseteq$" is Theorem 2.5. For "$\supseteq$", let $f \in U_G$. If $d_u = d_v$, pick $\sigma$ with $\sigma(u) = v$; invariance gives $f(v) = f(\sigma u) = f(u)$. So $f$ is constant on degree classes, hence a function of the degree, hence in $M_G$ by the lemma. $\square$

**Definition 8.4.** The **star** $K_{1,n}$ has vertex set $\{0,1,\dots,n\}$ with centre $0$ adjacent to each of the $n$ leaves and no other edges; $\deg(0) = n$ and $\deg(i) = 1$ for $i \ne 0$.

**Theorem 8.5 (Stars).** For every $n$, $\ M_{K_{1,n}} = U_{K_{1,n}}$; and stars are determined by their moments: if $K_{1,n}\equiv_m K_{1,m}$ then $n = m$ and $K_{1,n} \cong K_{1,m}$.

*Proof sketch.* For the module identity, verify degree transitivity. Any two leaves are exchanged by the transposition swapping them, which is an automorphism since adjacency in the star only records "is the centre". The only case where a leaf and the centre share a degree is $n = 1$ (the star $K_2$), where the vertex swap is an automorphism. Theorem 8.3 applies. For determination, the empty word already gives $n+1 = |V(K_{1,n})| = |V(K_{1,m})| = m+1$. $\square$

Stars form an infinite family of trees on which the McKay-type determination holds unconditionally.

**Theorem 8.6 (The rigidity boundary).** All three of the following hold simultaneously:

1. **Determination:** for all $n,m$, if $K_{1,n} \equiv_m K_{1,m}$ then $K_{1,n} \cong K_{1,m}$.
2. **Regular failure:** $C_6 \equiv_m 2K_3$ but $C_6 \not\cong 2K_3$.
3. **Connected non-regular failure:** $H_1 \equiv_m H_2$, both connected and non-regular, but $H_1 \not\cong H_2$.

Item (1) is the positive edge of McKay's phenomenon; items (2) and (3) show that the tree hypothesis is not removable, not even after imposing connectivity and irregularity.

---

## 9. Algorithms and complexity

Let $G$ have $n$ vertices and $m$ edges, given by adjacency lists.

### 9.1 Computing the moment vector

The efficient way to compute $m_G(w)$ is never to form $w(A,D)$. Instead, propagate the vector $x \leftarrow \mathbf 1$ through the letters of $w$ from right to left:

- letter $A$: $x \leftarrow A x$, i.e. $x'(u) = \sum_{v\in N(u)} x(v)$ — cost $O(m)$;
- letter $D$: $x \leftarrow Dx$, i.e. $x'(u) = d_u x(u)$ — cost $O(n)$.

Finally $m_G(w) = \sum_u x(u)$. Total cost $O(|w|(n+m))$ and $O(n)$ working memory. Computing all moments of all words of length $\le L$ by sharing suffixes costs $O(2^{L}(n+m))$; computing all *caterpillar* moments with $n$ hops and exponents bounded by $E$ costs $O((E+1)^{n+1}(n+m))$ naively, and much less with memoisation over suffix exponent vectors.

### 9.2 Computing decorated walk counts

By Theorem 6.2 one may equally compute the counts $c_G(n;b)$. A dynamic program over the degree pattern does this in one sweep: let $\delta$ be the number of distinct degrees, and let $S_k[v]$ be the number of length-$k$ walks ending at $v$ with a prescribed prefix pattern. Then
$$S_{k+1}[u] \;=\; [\,d_u = b_{k+1}\,]\sum_{v \in N(u)} S_k[v],$$
initialised by $S_0[v] = [\,d_v = b_0\,]$, with $c_G(n;b) = \sum_u S_n[u]$. Cost $O(n\,m)$ for all patterns of a given length via a joint table indexed by (position, degree value): the number of *realisable* patterns of length $n$ is at most $\delta^{n+1}$, but the walk propagation itself is a single $O(m)$ pass per (length, degree) pair, giving $O(\delta\, n\, m)$ to fill the table of all patterns of length up to $n$ when organised as a product automaton.

### 9.3 Colour refinement and the certificate of failure

To decide whether the moments *can possibly* distinguish two graphs, run colour refinement on each (cost $O((n+m)\log n)$ with the standard partition-refinement implementation) and compare the stable class sizes and quotient matrices. By Corollary 7.5, if these agree the graphs are moment-equivalent and no further computation is needed. This gives a cheap *pre-test*: moments are worth computing only when colour refinement already separates the graphs, in which case they provide a compact numerical certificate of the separation.

### 9.4 Interpolation-based extraction

To recover the degree distribution or the joint degree distribution from raw moments, solve the linear systems of Theorems 5.2 and 5.5. The relevant matrices are Vandermonde on the nodes $0,1,\dots,n-1$; they are notoriously ill-conditioned in floating point, so exact rational arithmetic (or working directly with the combinatorial counts) is recommended for $n$ beyond about $20$.

---

## 10. Applications and interpretation

**Tight-binding physics.** The family $\{A + tD : t \in \mathbb R\}$ is the one-parameter family of tight-binding Hamiltonians on the network with degree-proportional on-site energies; $t = -1$ gives (minus) the graph Laplacian. The word moments are the uniform-state expectation values of all noncommutative observables built from hopping and potential, and Theorem 7.6 says that on a regular lattice the entire family degenerates: all such expectations are determined by degree, order, and word length alone. Structure only becomes visible when the potential is non-constant, i.e. when the lattice has defects, boundaries, or disorder in coordination number.

**Network fingerprinting.** The moments are strictly stronger than the degree sequence (they see the joint degree distribution) and strictly stronger than plain walk counts (which are the trivially decorated case). They are computable in a handful of sparse matrix-vector products and are permutation-invariant by construction, so they make natural graph descriptors. Theorem 5.5 says in particular that the assortativity profile is a moment-derived quantity.

**Graph learning.** Message-passing graph neural networks that aggregate neighbour features are, in their first rounds, computing precisely degree-decorated walk statistics. Theorem 6.2 identifies the moment invariant with those statistics exactly, and Theorem 7.3 caps its power at colour refinement. The pair $H_1, H_2$ of Theorem 7.8 is therefore a minimal, connected, non-regular certificate that no such architecture — and no algebraic invariant built from $A$ and $D$ alone in this way — can separate all connected graphs.

**Isomorphism testing.** Corollary 7.5 makes the moments useless as a refinement of colour refinement, but useful as a *numerical summary* of the refinement quotient: a few moments serve as a hash of the quotient data.

---

## 11. Open problems and future directions

The two central conjectures below are exactly the statements that the results above reduce to combinatorics.

**Conjecture 1 (Principal McKay theorem: moments determine trees).** If $T_1$ and $T_2$ are trees with $m_{T_1}(w) = m_{T_2}(w)$ for every word $w$ in $\{A,D\}$, then $T_1 \cong T_2$.

*Status.* Proved above for the star family (Theorem 8.5); exhaustive enumeration finds no counterexample among trees on at most twelve vertices, where undecorated walk counts already collide. By the equivalence theorem (Theorem 6.2) the moment invariant is *exactly* the family of degree-decorated caterpillar counts, so the statement is a purely combinatorial reconstruction problem: rebuild a tree from the number of walks realising each prescribed degree pattern, peeling leaves according to their decorated pattern multiplicities. The reduction from linear algebra to walk counts is a theorem rather than a heuristic, and the leaf-peeling induction requires no new analytic input — only the counts already proven invariant.

**Conjecture 2 (Forest module identity).** For every forest $F$, $\ M_F = U_F$.

*Status.* Proved above for stars and, more generally, for degree-transitive graphs (Theorem 8.3). The expected mechanism is that in a forest the iterated degree refinement already stabilises at the automorphism-orbit partition, so that the general inclusion $M_G \subseteq U_G$ of Theorem 2.5 becomes an equality. A proof would give the module-theoretic half of McKay's picture for all forests.

Further directions:

- **Classify the small-order failures.** Beyond the regular examples, the first failures are pairs sharing a colour-refinement quotient. Characterising the minimal such pairs — and in particular the ten-vertex integral switchings that are invisible to the cyclic module — would map the boundary precisely.
- **Quantitative rigidity.** How many moments (words of what length) suffice to separate two trees on $n$ vertices? A polynomial bound would turn Conjecture 1 into a practical isomorphism test for trees.
- **Higher-order analogues.** Replacing the pair $(A,D)$ by the tuple of $k$-tuple-indexed operators of the $k$-dimensional Weisfeiler–Leman hierarchy should yield a nested family of moment invariants; identifying the corresponding "decorated pattern counts" is the natural generalisation of Theorem 6.2.
- **Weighted and directed graphs.** Both the caterpillar expansion and the quotient formula are insensitive to symmetry of $A$; extending the determination results to weighted or directed settings, where $D$ splits into in- and out-degree matrices, appears feasible.
- **Spectral versus principal.** McKay's original invariant is the full spectra; the principal one is the uniform-state moments. Exactly which graphs are separated by the former but not the latter?

---

## 12. Summary of main results

| Result | Statement |
|---|---|
| Ceiling | $M_G \subseteq U_G$ for every finite simple graph |
| Floor | $M_G = \mathbb R\mathbf 1$ iff $G$ is regular |
| Invariance | All word moments are isomorphism invariants |
| Caterpillar expansion | $\mathbf 1^{\mathsf T} D^{a_0}A\cdots AD^{a_n}\mathbf 1 = \sum_{\text{walks}}\prod_i d_{p_i}^{a_i}$ |
| Degree recovery | Moment equality $\Rightarrow$ equal order, size, degree distribution |
| Joint degrees | Moment equality $\Rightarrow$ equal counts $N_{a,b}$ of edges by endpoint degrees |
| Walk statistics | Moment equality $\Rightarrow$ equality of every degree-decorated walk statistic |
| Equivalence | Moments $\iff$ degree-decorated walk counts (same order) |
| Quotient formula | $m_G(w) = \sum_\kappa |\kappa|\,(w(B,\Delta)\mathbf 1)_\kappa$ for equitable colourings |
| Regular blindness | $k$-regular on $n$ vertices $\Rightarrow m_G(w) = k^{|w|}n$ |
| Six-vertex failure | Explicit connected non-regular moment-equivalent non-isomorphic pair |
| $J$-ideal | $\mathbf 1^{\mathsf T} XJY\mathbf 1 = (\mathbf 1^{\mathsf T} X\mathbf 1)(\mathbf 1^{\mathsf T} Y\mathbf 1)$: no new scalars |
| Degree transitivity | Degree-transitive $\Rightarrow M_G = U_G$ |
| Stars | $M_{K_{1,n}} = U_{K_{1,n}}$, and moments determine stars |
