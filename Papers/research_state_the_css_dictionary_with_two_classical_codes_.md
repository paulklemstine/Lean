# The CSS Dictionary, Homological Distance, and the Hypercube Code

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We give a precise, three-way equivalence between the formulations of the Calderbank–Shor–Steane (CSS) construction that are habitually used interchangeably: an inclusion of nested classical linear codes $C_2 \subseteq C_1$, the matrix orthogonality condition $H_X H_Z^{\mathsf T} = 0$, and the isotropy (abelianness) of the generated Pauli stabilizer group with respect to the symplectic commutation form. The equivalences are identities of subspaces and groups, not numerical coincidences; the first two hold over an arbitrary field, and no finiteness of the generating set is used for the third. We then package a commuting pair of parity checks as a length-two chain complex whose homology is exactly the logical space, obtaining the dimension formula $k + \operatorname{rank} H_X + \operatorname{rank} H_Z = N$.

On top of this we define the operational CSS distance — the minimum weight of an undetectable Pauli error that is not a stabilizer — and prove that it equals $\min(d_X, d_Z)$, the minimum of the systolic and cosystolic distances, under the explicit nondegeneracy hypothesis that logical operators of both types exist. The key structural input is that the CSS stabilizer group is the *product* $\operatorname{rowspace} H_X \times \operatorname{rowspace} H_Z$, so that stabilizer membership is componentwise; this is what prevents a mixed $X/Z$ error from beating both single-sector minima.

We apply the framework in two directions. First, we construct the $\mathbb{F}_2$ incidence complex of the $n$-dimensional hypercube $Q_n$ from scratch, prove $\operatorname{rank}\partial_1 = 2^n - 1$ (equivalently $\beta_0 = 1$, connectivity) by a Hamming-weight induction, and obtain the unconditional parameters
$$\bigl[\bigl[\,n2^{\,n-1},\; 2^{\,n-1}(n-2)+1,\; 1\,\bigr]\bigr].$$
In particular the folk claim that the hypercube homological code encodes one logical qubit holds *only* at $n = 2$, and $k \ge 5$ for all $n \ge 3$; and the code's distance is $1$ despite the graph having girth $4$, because a graph code has no $Z$-checks and its primal distance is the minimum weight of a non-cut. Second, we prove a rank obstruction: an incidence matrix of a graph on vertex set $V$ satisfies $\operatorname{rank} M + 1 \le \lvert V\rvert$, so a CSS code with independent $X$-checks — the Steane code, for instance — admits no graph model on any vertex set. The framework is certified end to end by rederiving the Steane parameters $[[7,1,3]]$ from the Hamming check matrix alone.

**Keywords:** CSS codes, quantum error correction, chain complexes, homological codes, systole and cosystole, hypercube graph, stabilizer formalism, graph representability.

---

## 1. Introduction

The CSS construction is described, in the literature and in practice, in at least three mutually translated languages.

1. **Classical coding language.** Two nested binary linear codes $C_2 \subseteq C_1 \subseteq \mathbb{F}_2^N$ give a quantum code whose logical space is the quotient $C_1/C_2$.
2. **Matrix language.** Two parity-check matrices $H_X$ and $H_Z$ with $H_X H_Z^{\mathsf T} = 0$ give a quantum code whose parameter count is $k = N - \operatorname{rank} H_X - \operatorname{rank} H_Z$.
3. **Stabilizer language.** The $X$-type operators indexed by the rows of $H_X$ and the $Z$-type operators indexed by the rows of $H_Z$ generate an abelian subgroup of the Pauli group, whose joint $+1$ eigenspace is the code space.

Everyone knows these agree. The point of Section 3 is that "agree" can be made exact, and that doing so is worth the effort: statements are routinely *asserted* in one language and *tested* in another, and precisely this slippage is what allows false claims to survive.

A second slippage concerns geometry. A commuting pair $(H_X, H_Z)$ is a length-two chain complex, and homology counts logical qubits — the homological or topological code paradigm. It is then tempting to reason about a CSS code as though it were a geometric object with the full apparatus of a cell complex behind it. But "is a chain complex" is much weaker than "is the incidence complex of a space". Section 6 makes the gap concrete with a rank obstruction and two counterexamples.

The third slippage, the most damaging in practice, concerns distance. A homological code has two error sectors, and the code distance is the minimum of the two. Quoting the systole alone (or, for a graph code, the girth) is not a conservative approximation to the distance — it can overstate it arbitrarily. Section 5 defines the operational distance and proves the $\min(\text{systole}, \text{cosystole})$ theorem; Section 7 applies it to the hypercube and finds distance $1$ where folklore predicts $2^{n/2}$.

### 1.1. Contributions

- **The CSS dictionary (Theorems 3.4, 3.5, 3.7, 3.8).** Kernel–row-space duality, the equivalence of nesting and matrix orthogonality, the $X\leftrightarrow Z$ transpose symmetry, and the equivalence of matrix orthogonality with isotropy of the generated Pauli group.
- **The chain-complex packaging and dimension formula (Theorems 4.2, 4.4).** Cycles are $\ker H_X$, boundaries are $\operatorname{rowspace} H_Z$, homology is $C_1/C_2$, and $k + \operatorname{rank} H_X + \operatorname{rank} H_Z = N$.
- **The distance theorem (Theorems 5.6, 5.7).** The stabilizer group is a product of row spaces; consequently $d = \min(d_X, d_Z)$ under explicit nondegeneracy hypotheses, and $d \ge 1$ whenever any logical error exists.
- **The hypercube incidence complex (Theorems 7.2, 7.3, 7.5, 7.7).** An explicit edge-normalised construction over $\mathbb{F}_2$; connectivity as a rank statement; $k = 2^{n-1}(n-2)+1$; $k = 1$ iff $n = 2$; and $d = 1$ for all $n \ge 2$.
- **The graph rank obstruction (Theorems 6.2, 6.4, 6.5).** $\operatorname{rank} M + 1 \le |V|$ for graph incidence matrices; the Steane code and the $1\times 1$ identity are not graph-representable; the hypercube boundary matrix is, extremally.
- **Certification on the Steane code (Section 8).** $[[7,1,3]]$ recovered from the framework, with the quantum Singleton comparison at the correct block length in both examples.

---

## 2. Setting and notation

Fix a field $K$. For a matrix $H \in K^{m \times N}$ we write $Hv$ for the matrix–vector product and $v \cdot w = \sum_i v_i w_i$ for the standard bilinear form on $K^N$. Index sets are allowed to be arbitrary finite types; nothing depends on an ordering.

**Definition 2.1 (Checked code).** The *code checked by* $H \in K^{m\times N}$ is
$$\mathcal{C}(H) = \ker H = \{v \in K^N : Hv = 0\},$$
a subspace of $K^N$.

**Definition 2.2 (Row space).** The *row space* of $H$ is the subspace generated by its rows,
$$\mathcal{R}(H) = \operatorname{im} H^{\mathsf T} = \{H^{\mathsf T} y : y \in K^m\} \subseteq K^N .$$

**Definition 2.3 (Orthogonal complement).** For a subspace $W \subseteq K^N$,
$$W^{\perp} = \{v \in K^N : w \cdot v = 0 \text{ for all } w \in W\}.$$
That $W^\perp$ is a subspace follows from bilinearity of the form.

**Definition 2.4 (Hamming weight).** For $a \in \mathbb{F}_2^N$, $\lvert a\rvert = \#\{i : a_i \ne 0\}$. For a pair $p = (a\mid b) \in \mathbb{F}_2^N \times \mathbb{F}_2^N$, the *Pauli weight* is
$$\lVert p \rVert = \#\{i : a_i \ne 0 \text{ or } b_i \ne 0\},$$
the size of the union of the supports.

Two immediate facts, used constantly: $\lvert a\rvert \le \lVert (a\mid b)\rVert$ and $\lvert b \rvert \le \lVert (a\mid b)\rVert$; and $\lVert p \rVert = 0$ iff $p = 0$, so $\lVert p \rVert \ge 1$ for $p \ne 0$.

---

## 3. The CSS dictionary

### 3.1. Nondegeneracy

**Lemma 3.1 (Nondegeneracy of the standard form).** $(K^N)^{\perp} = 0$.

*Proof sketch.* If $v \cdot w = 0$ for every $w$, take $w$ to range over the standard basis to conclude $v_i = 0$ for all $i$. $\square$

Nondegeneracy is the only property of the form that is used; in particular we never invoke $(W^\perp)^\perp = W$, which would require a dimension argument and is unnecessary below.

### 3.2. Kernel–row-space duality

**Theorem 3.2 (The checked code is an orthogonal complement).** For every $H \in K^{m\times N}$,
$$\mathcal{C}(H) = \mathcal{R}(H)^{\perp}.$$

*Proof sketch.* Both inclusions come from the adjunction $(H^{\mathsf T} y)\cdot v = y \cdot (Hv)$. If $Hv = 0$ then the right side vanishes for every $y$, so $v$ is orthogonal to every element $H^{\mathsf T}y$ of the row space. Conversely, if $v \perp \mathcal{R}(H)$ then $y \cdot (Hv) = 0$ for all $y \in K^m$, and nondegeneracy of the form on $K^m$ gives $Hv = 0$. $\square$

This is the precise bridge between the "quotient of nested codes" and "orthogonal complement" formulations: the classical code checked by $H$ is literally the dual of the code generated by $H$.

### 3.3. Nesting equals matrix orthogonality

**Theorem 3.3 (Dictionary, part 1).** For $H_X \in K^{m_X\times N}$ and $H_Z \in K^{m_Z \times N}$,
$$\mathcal{R}(H_Z) \subseteq \mathcal{C}(H_X) \iff H_X H_Z^{\mathsf T} = 0 .$$

*Proof sketch.* ($\Leftarrow$) Every element of $\mathcal{R}(H_Z)$ has the form $H_Z^{\mathsf T} y$, and $H_X H_Z^{\mathsf T} y = 0$. ($\Rightarrow$) Apply the inclusion to $H_Z^{\mathsf T} e_j$ for each standard basis vector $e_j \in K^{m_Z}$; the resulting identity $H_X H_Z^{\mathsf T} e_j = 0$, read coordinatewise, is exactly the vanishing of the $j$-th column of $H_X H_Z^{\mathsf T}$. $\square$

Combining Theorems 3.2 and 3.3, the mission-style formulation "$C_2 \subseteq C_1$ with $C_1 = \mathcal C(H_X)$, $C_2 = \mathcal R(H_Z)$" is *the same statement* as "$\mathcal R(H_Z) \perp \mathcal R(H_X)$", which is the same statement as "$H_X H_Z^{\mathsf T} = 0$".

**Theorem 3.4 ($X\leftrightarrow Z$ symmetry).** $H_X H_Z^{\mathsf T} = 0 \iff H_Z H_X^{\mathsf T} = 0$.

*Proof sketch.* Transpose, using $(AB)^{\mathsf T} = B^{\mathsf T} A^{\mathsf T}$ and $(A^{\mathsf T})^{\mathsf T}=A$. $\square$

Thus the well-known $X/Z$ duality of CSS codes is no more and no less than the transpose symmetry of the orthogonality condition; in particular $\mathcal R(H_Z)\subseteq \mathcal C(H_X)$ iff $\mathcal R(H_X)\subseteq\mathcal C(H_Z)$.

### 3.4. Isotropy of the stabilizer group

From here we work over $\mathbb{F}_2$, where the stabilizer picture lives.

**Definition 3.5 (Symplectic form).** A phase-free Pauli operator on $N$ qubits is a pair $p = (a\mid b) \in \mathbb{F}_2^N\times \mathbb{F}_2^N$, where $a$ is the $X$-support and $b$ the $Z$-support. The *commutation form* is the bilinear map
$$\omega(p, q) = a_p \cdot b_q + a_q \cdot b_p \in \mathbb{F}_2 .$$
Two Pauli operators commute iff $\omega(p,q) = 0$; a set is *isotropic* iff $\omega$ vanishes on all pairs from it.

**Definition 3.6 (CSS stabilizer group).** Given $H_X, H_Z$ over $\mathbb{F}_2$, let
$$G(H_X,H_Z) = \bigl\{(h\mid 0): h \text{ a row of } H_X\bigr\} \cup \bigl\{(0\mid h): h \text{ a row of } H_Z\bigr\},$$
and let $\mathcal{S}(H_X, H_Z) = \operatorname{span}_{\mathbb{F}_2} G(H_X, H_Z)$, the stabilizer group written additively.

**Lemma 3.7 (Isotropy propagates from generators).** If $\omega$ vanishes on all pairs of elements of a set $G$, then it vanishes on all pairs of elements of $\operatorname{span} G$.

*Proof sketch.* For fixed $g\in G$, the set $\{q : \omega(g,q)=0\}$ is the kernel of a linear functional, hence a subspace containing $G$, hence containing $\operatorname{span} G$. Now for fixed $q \in \operatorname{span} G$, the set $\{p : \omega(p,q)=0\}$ is again the kernel of a linear functional and, by the previous step, contains $G$; so it contains $\operatorname{span} G$. Note the argument uses only linearity in each argument and never a basis or finiteness of $G$. $\square$

**Theorem 3.8 (Dictionary, part 3).** $\mathcal{S}(H_X, H_Z)$ is isotropic (i.e. the stabilizer group is abelian) if and only if $H_X H_Z^{\mathsf T} = 0$.

*Proof sketch.* ($\Leftarrow$) By Lemma 3.7 it suffices to check generators. Two $X$-type generators pair to $a_1\cdot 0 + a_2 \cdot 0 = 0$, and likewise two $Z$-type ones. An $X$-generator from row $i$ of $H_X$ against a $Z$-generator from row $j$ of $H_Z$ pairs to $(H_X)_i \cdot (H_Z)_j = (H_X H_Z^{\mathsf T})_{ij} = 0$. ($\Rightarrow$) Conversely, evaluating $\omega$ on exactly that pair of generators recovers the entry $(H_X H_Z^{\mathsf T})_{ij}$, which must therefore vanish for all $i,j$. $\square$

The reverse direction is what makes Theorem 3.8 a genuine equivalence rather than a one-way sufficiency: it cannot be satisfied vacuously, since it evaluates the form on explicit generators.

**Corollary 3.9 (The dictionary).** For binary parity checks $H_X, H_Z$ the following are equivalent:
1. $\mathcal R(H_Z) \subseteq \mathcal C(H_X)$ (nested classical codes $C_2 \subseteq C_1$);
2. $H_X H_Z^{\mathsf T} = 0$ (matrix orthogonality; equivalently $\mathcal R(H_X) \perp \mathcal R(H_Z)$);
3. $\mathcal S(H_X,H_Z)$ is abelian (isotropy of the stabilizer group).

---

## 4. The chain complex and the dimension formula

**Definition 4.1 (Length-two complex).** A *CSS complex* over $K$ is a pair of linear maps
$$A \xrightarrow{\;d_2\;} B \xrightarrow{\;d_1\;} C, \qquad d_1 \circ d_2 = 0 .$$
Its *cycles* are $Z = \ker d_1$, its *boundaries* are $B' = \operatorname{im} d_2 \subseteq Z$, its *homology* is $H = Z/B'$, and the number of *logical qubits* is $k = \dim H$. Its *zeroth Betti number* is $\beta_0 = \dim \operatorname{coker} d_1$.

**Theorem 4.2 (Dictionary, part 2: complexes are commuting check pairs).** Given $H_X \in K^{m_X\times N}$, $H_Z \in K^{m_Z\times N}$ with $H_X H_Z^{\mathsf T} = 0$, the maps
$$K^{m_Z} \xrightarrow{\;H_Z^{\mathsf T}\;} K^{N} \xrightarrow{\;H_X\;} K^{m_X}$$
form a CSS complex whose cycles are $C_1 = \mathcal{C}(H_X)$ and whose boundaries are $C_2 = \mathcal{R}(H_Z)$. Conversely, choosing bases turns any CSS complex of finite-dimensional spaces into such a pair.

*Proof sketch.* $H_X H_Z^{\mathsf T} y = (H_X H_Z^{\mathsf T})y = 0$ for all $y$, which is $d_1 \circ d_2 = 0$. Cycles and boundaries are the definitions of $\mathcal C$ and $\mathcal R$. $\square$

**Corollary 4.3 (Logical space is the quotient of nested codes).** With the complex of Theorem 4.2,
$$k + \dim C_2 = \dim C_1, \qquad C_2 = \mathcal R(H_Z) \subseteq C_1 = \mathcal C(H_X),$$
so the logical space is canonically $C_1/C_2$.

**Theorem 4.4 (The CSS count).** Over a field,
$$k + \operatorname{rank} H_X + \operatorname{rank} H_Z = N .$$

*Proof sketch.* Rank–nullity for $H_X$ gives $\dim C_1 = N - \operatorname{rank} H_X$. The dimension of the row space of $H_Z$ is $\operatorname{rank} H_Z^{\mathsf T} = \operatorname{rank} H_Z$, using equality of row and column rank; this is the unique step where the field hypothesis is genuinely used — the equivalences of Section 3 hold over any commutative ring with a nondegenerate dot product. Substituting into Corollary 4.3 gives the identity. $\square$

Stated additively, $k + \operatorname{rank} H_X + \operatorname{rank} H_Z = N$ avoids truncated subtraction and is the form used in all applications below.

---

## 5. Distance

Throughout this section $H_X, H_Z$ are binary and commuting, and $N$ is the number of physical qubits.

**Definition 5.1 (Logical operators).** A vector $a \in \mathbb{F}_2^N$ is an *$X$-logical* if $H_Z a = 0$ and $a \notin \mathcal R(H_X)$: it is undetectable by the $Z$-checks yet is not a product of $X$-stabilizers. Dually, $b$ is a *$Z$-logical* if $H_X b = 0$ and $b \notin \mathcal R(H_Z)$.

**Definition 5.2 (Systole and cosystole).**
$$d_X = \min\{\lvert a\rvert : a \text{ an } X\text{-logical}\}, \qquad d_Z = \min\{\lvert b\rvert : b \text{ a } Z\text{-logical}\}.$$
These are the primal (systolic) and dual (cosystolic) distances: minimum weights of nonzero homology and cohomology classes respectively.

**Definition 5.3 (Undetectable errors and the CSS distance).** A Pauli operator $p = (a\mid b)$ is *undetectable* if $H_Z a = 0$ and $H_X b = 0$, i.e. it commutes with every stabilizer generator. The *CSS distance* is
$$d = \min\{\lVert p\rVert : p \text{ undetectable}, \ p \notin \mathcal S(H_X,H_Z)\}.$$

Definition 5.3 is *operational* and is not defined as $\min(d_X,d_Z)$: it lets mixed $X/Z$ errors compete. Theorem 5.7 is therefore a theorem, not an unfolding of definitions.

**Lemma 5.4 (Row combinations).** $H^{\mathsf T} y = \sum_i y_i H_i$, where $H_i$ is the $i$-th row of $H$.

**Theorem 5.5 (Structure of the stabilizer group).**
$$\mathcal S(H_X, H_Z) = \mathcal R(H_X) \times \mathcal R(H_Z).$$
Consequently $p \in \mathcal S(H_X,H_Z)$ iff $a \in \mathcal R(H_X)$ *and* $b \in \mathcal R(H_Z)$.

*Proof sketch.* ($\subseteq$) Each generator lies in the product, and the product is a subspace, so the span does. ($\supseteq$) Given $a = H_X^{\mathsf T}y$ and $b = H_Z^{\mathsf T}z$, Lemma 5.4 expresses $(a\mid 0) = \sum_i y_i \,((H_X)_i \mid 0)$ and $(0 \mid b) = \sum_j z_j\,(0\mid (H_Z)_j)$ as combinations of generators; add them. $\square$

Componentwise membership is exactly the fact needed to prevent a mixed error from being "accidentally trivial in a correlated way".

**Lemma 5.6 (Padding).** If both logical types exist then $d \le d_X$ and $d \le d_Z$.

*Proof sketch.* Let $a$ be a minimum-weight $X$-logical. Then $(a\mid 0)$ is undetectable ($H_Z a = 0$ and $H_X 0 = 0$) and is not a stabilizer, since by Theorem 5.5 that would force $a \in \mathcal R(H_X)$. Its Pauli weight is $\lvert a\rvert = d_X$. Dually for $d_Z$. $\square$

**Theorem 5.7 (The distance theorem).** Suppose both an $X$-logical and a $Z$-logical exist. Then
$$d = \min(d_X, d_Z).$$

*Proof sketch.* "$\le$" is Lemma 5.6. For "$\ge$", the competing set is nonempty (again by Lemma 5.6), so the minimum is attained by some undetectable non-stabilizer $p = (a\mid b)$ with $\lVert p\rVert = d$. By Theorem 5.5, $p \notin \mathcal S$ means $a \notin \mathcal R(H_X)$ or $b \notin \mathcal R(H_Z)$. In the first case $a$ is an $X$-logical (it satisfies $H_Z a = 0$ by undetectability), so $d_X \le \lvert a\rvert \le \lVert p\rVert = d$; in the second, symmetrically, $d_Z \le \lvert b \rvert \le d$. Either way $\min(d_X,d_Z) \le d$. $\square$

The nondegeneracy hypotheses are essential and not cosmetic: a minimum over an empty set is not a meaningful distance, and with the usual convention that it evaluates to $0$ the statement would degenerate silently. When $k = 0$ there are no logical operators at all and the distance is undefined; this is visible numerically.

**Proposition 5.8 (Positivity).** If some undetectable non-stabilizer error exists then $d \ge 1$.

*Proof sketch.* A minimiser $p$ is nonzero — the zero operator is a stabilizer — and $\lVert p\rVert \ge 1$ for $p \ne 0$. $\square$

---

## 6. Which CSS complexes come from a graph?

Any commuting pair is a chain complex (Theorem 4.2). The converse-style claim — that any binary CSS complex is realised by an actual $1$-complex with its standard incidence maps — is strictly stronger. We refute it.

**Definition 6.1 (Graph incidence matrix).** $M \in \mathbb{F}_2^{V\times E}$ *is a graph incidence matrix* if for every $e \in E$ there exist $u \neq v$ in $V$ with $M_{we} = [w = u] + [w = v]$ for all $w$: each column is the indicator of the two distinct endpoints of an edge.

Distinctness matters: allowing $u = v$ would admit loop columns, which are zero over $\mathbb{F}_2$, and destroy the obstruction below.

**Lemma 6.2 (Parity obstruction).** If $M$ is a graph incidence matrix then every column sums to zero, $\sum_{w} M_{we} = 0$; equivalently the all-ones vector $\mathbf 1$ lies in $\ker M^{\mathsf T}$.

*Proof sketch.* A column has exactly two ones, and $1 + 1 = 0$ in $\mathbb{F}_2$. $\square$

**Theorem 6.3 (Graph rank obstruction).** If $M \in \mathbb{F}_2^{V\times E}$ is a graph incidence matrix and $V \ne \emptyset$, then
$$\operatorname{rank} M + 1 \le \lvert V\rvert .$$
In particular the $X$-checks of a graph code are never independent.

*Proof sketch.* $\mathbf 1 \neq 0$, so by Lemma 6.2 $\dim\ker M^{\mathsf T} \ge 1$. Rank–nullity for $M^{\mathsf T}: \mathbb{F}_2^V \to \mathbb{F}_2^E$ gives $\operatorname{rank} M^{\mathsf T} + \dim \ker M^{\mathsf T} = \lvert V\rvert$, and $\operatorname{rank} M^{\mathsf T} = \operatorname{rank} M$. $\square$

**Theorem 6.4 (The Steane code is not a graph code).** The $3\times 7$ Hamming check matrix $H$ of Section 8 has $\operatorname{rank} H = 3$, equal to its number of rows, so it is not a graph incidence matrix — on any vertex set.

*Proof sketch.* A graph model on the check set as vertices would give $\operatorname{rank} H + 1 \le 3$ by Theorem 6.3, contradicting $\operatorname{rank} H = 3$. $\square$

**Theorem 6.5 (Minimal counterexample).** The $1\times 1$ identity matrix $[1]$ is a legitimate binary differential (with $d_2 = 0$ it is a chain complex) but is not a graph incidence matrix: its single column would have to mark two distinct vertices among one vertex.

**Proposition 6.6 (The obstruction is not vacuous).** The hypercube boundary matrix $\partial_1$ of Section 7 *is* a graph incidence matrix, and satisfies the bound of Theorem 6.3 with equality, $\operatorname{rank}\partial_1 + 1 = 2^n$ — equality because $Q_n$ is connected.

**Remark 6.7.** The obstruction is necessary but not sufficient. It says nothing about the $Z$-side and nothing about column weights beyond the parity shadow. A complete characterisation would demand every column of a $k$-dimensional simplicial boundary map to have weight exactly $k+1$ together with the face-compatibility relations; for $k = 1$ this reduces to "every column has weight $2$".

---

## 7. The hypercube incidence complex

### 7.1. Construction

**Definition 7.1.** For $n \ge 0$ let $V_n = \mathbb{F}_2^n$ be the vertex set of the $n$-cube, of size $2^n$, and let
$$E_n = \{(i, x) : i \in \{1,\dots,n\},\; x \in V_n,\; x_i = 0\}$$
be the *lower-endpoint normalised* edge set: the edge $(i,x)$ joins $x$ to $x + e_i$. Each geometric edge is named exactly once, and slicing off coordinate $i$ shows $\lvert E_n\rvert = n\,2^{\,n-1}$. The boundary matrix $\partial_1 \in \mathbb{F}_2^{V_n\times E_n}$ has
$$(\partial_1)_{v,(i,x)} = [v = x] + [v = x + e_i].$$
Over $\mathbb{F}_2$ no orientation data is needed.

Its transpose is the discrete derivative: for $f : V_n \to \mathbb{F}_2$,
$$(\partial_1^{\mathsf T} f)(i,x) = f(x) + f(x + e_i).$$

### 7.2. Connectivity as a rank statement

**Theorem 7.2 (Cocycles are constants).** $\ker \partial_1^{\mathsf T} = \mathbb{F}_2 \cdot \mathbf 1$, the line of constant functions.

*Proof sketch.* ($\supseteq$) The constant function gives $1 + 1 = 0$ on every edge. ($\subseteq$) $f \in \ker \partial_1^{\mathsf T}$ means $f(x) = f(x+e_i)$ whenever $x_i = 0$. Applying this at $x + e_i$ upgrades it to invariance under flipping *any* coordinate, in either direction. Now induct on the Hamming weight of $x$: if $x = 0$ we are done; otherwise pick $i$ with $x_i \ne 0$, note that $x + e_i$ has strictly smaller weight, and use $f(x) = f(x + e_i) = f(0)$ by the induction hypothesis. Hence $f \equiv f(0)$ and $f = f(0)\cdot \mathbf 1$. $\square$

**Theorem 7.3 (Rank of the cube boundary).** $\operatorname{rank} \partial_1 + 1 = 2^n$; that is, $\operatorname{rank}\partial_1 = 2^n - 1$.

*Proof sketch.* By Theorem 7.2 the kernel of $\partial_1^{\mathsf T}$ is one-dimensional; rank–nullity on $\mathbb{F}_2^{V_n}$ gives $\operatorname{rank}\partial_1^{\mathsf T} + 1 = \lvert V_n \rvert = 2^n$, and $\operatorname{rank}\partial_1^{\mathsf T} = \operatorname{rank}\partial_1$. $\square$

**Corollary 7.4 (Connectivity).** $\beta_0 = \dim\operatorname{coker}\partial_1 = 2^n - \operatorname{rank}\partial_1 = 1$: the hypercube is connected. Connectivity is thus not an extra hypothesis but a consequence of the rank computation.

### 7.3. Parameters

The homological code of a graph is the CSS code with $H_X = \partial_1$ (one $X$-check per vertex) and $H_Z = 0$: a graph has no $2$-cells, hence no $Z$-checks. The middle space carries one qubit per edge, so $N = n 2^{n-1}$.

**Theorem 7.5 (Logical qubit count).** For the hypercube homological code,
$$k + 2^n = n\,2^{\,n-1} + 1, \qquad\text{i.e.}\qquad k = 2^{\,n-1}(n-2) + 1 \quad (n \ge 1).$$

*Proof sketch.* Theorem 4.4 with $\operatorname{rank}H_Z = 0$ gives $k = N - \operatorname{rank}\partial_1$; substitute $N = n2^{n-1}$ and Theorem 7.3. Equivalently, in the general form $k + \dim C = \dim B + \beta_0$ for a two-term complex, with $\dim C = 2^n$, $\dim B = n2^{n-1}$, $\beta_0 = 1$. $\square$

| $n$ | $N = n2^{n-1}$ | $\operatorname{rank}\partial_1$ | $k$ |
|---|---|---|---|
| 2 | 4 | 3 | 1 |
| 3 | 12 | 7 | 5 |
| 4 | 32 | 15 | 17 |
| 5 | 80 | 31 | 49 |
| 6 | 192 | 63 | 129 |

**Theorem 7.6 (When is $k = 1$?).** For $n \ge 1$, $k = 1$ if and only if $n = 2$. Moreover $k \ge 5$ for all $n \ge 3$.

*Proof sketch.* $n = 1$ gives $k = 0$ directly, $n=2$ gives $k=1$; for $n \ge 3$, $k = 2^{n-1}(n-2)+1 \ge 4\cdot 1 + 1 = 5$. $\square$

So the folk assertion "the hypercube complex encodes one logical qubit" is true exactly at the degenerate case $n = 2$, the square — and false, by an exponential margin, everywhere else.

### 7.4. The distance is one

**Theorem 7.7 (A single edge is not a cut).** Let $n \ge 2$ and let $i_0 \ne i_1$ be two directions. The indicator of the edge $(i_0, 0)$ is not in $\mathcal R(\partial_1)$; i.e. it is not a coboundary.

*Proof sketch.* Suppose it were $\partial_1^{\mathsf T} f$ for some vertex function $f$. Evaluate the coboundary identity $f(x)+f(x+e_i) = \delta_{(i,x),(i_0,0)}$ on the four edges of the square through $0$ spanned by directions $i_0, i_1$: the edges $(i_0,0)$, $(i_1,0)$, $(i_0, e_{i_1})$, $(i_1, e_{i_0})$. Their right-hand sides are $1,0,0,0$. Summing the four left-hand sides, each of the four vertex values $f(0), f(e_{i_0}), f(e_{i_1}), f(e_{i_0}+e_{i_1})$ appears exactly twice and cancels over $\mathbb{F}_2$. Hence $0 = 1$, a contradiction. $\square$

**Theorem 7.8 (Distance one).** For $n \ge 2$ the hypercube homological code has $d_X = 1$ and $d = 1$.

*Proof sketch.* With no $Z$-checks, every edge vector is undetectable in the $X$ sector, and by Theorem 7.7 the single-edge indicator is not a stabilizer; its weight is $1$. This gives $d_X \le 1$ and $d \le 1$. Proposition 5.8 rules out $0$. $\square$

**Remark 7.9 (Where the girth went).** The cube graph has girth $4$, and $4$ is a genuine distance — the *dual* distance $d_Z$, the minimum weight of a nonzero cycle, since with $H_Z=0$ the trivial $Z$-operators are only the zero vector and the $Z$-logicals are the nonzero cycles. But $d = \min(d_X,d_Z) = \min(1,4) = 1$. A graph is a one-dimensional complex: it has cycles but no faces, so there are no $Z$-checks to constrain $X$-errors. Distance growth requires genuine $2$-cells, as in the toric code. The parameters of the hypercube homological code are
$$\bigl[\bigl[\,n2^{\,n-1},\; 2^{\,n-1}(n-2)+1,\; 1\,\bigr]\bigr],$$
not $[[\,\cdot,\,1,\,2^{n/2}]]$.

### 7.5. Bounds at the correct block length

**Theorem 7.10 (Quantum Singleton comparison).** With block length $N = n2^{n-1}$ — the number of physical *edge* qubits — the hypercube code satisfies $k + 2(d-1) \le N$ for all $n \ge 3$ and any $d \le 4$, with slack
$$N - k - 2(d-1) = 2^n - 2d + 1 .$$

*Proof sketch.* Substitute $k = N - 2^n + 1$ from Theorem 7.5 and simplify; $2^n \ge 8$ for $n \ge 3$. $\square$

The slack is exponential in $n$: the code is very far from quantum-MDS. The moral of the correction is methodological: reading the *cube dimension* $n$ as a block length makes the comparison meaningless, since $k$ already exceeds $n$ for $n \ge 3$.

---

## 8. Certification: the Steane code

A framework is only as good as the codes it can certify, so we run it on the standard nontrivial example.

Let $H \in \mathbb{F}_2^{3\times 7}$ be the parity-check matrix of the $[7,4,3]$ Hamming code, whose seven columns are the seven nonzero binary triples:
$$H = \begin{pmatrix} 1&0&1&0&1&0&1\\ 0&1&1&0&0&1&1\\ 0&0&0&1&1&1&1 \end{pmatrix}.$$

1. **Commutation.** $H H^{\mathsf T} = 0$: the Hamming code contains its dual. By Corollary 3.9 this is simultaneously the nesting $\mathcal R(H)\subseteq\mathcal C(H)$ and the abelianness of the stabilizer group, so $H_X = H_Z = H$ is a legitimate CSS pair.
2. **Rank.** $\operatorname{rank} H = 3$: the map $v \mapsto Hv$ is onto $\mathbb{F}_2^3$, since columns $1,2,4$ (the binary expansions of $1,2,4$) form an identity block.
3. **Dimension.** By Theorem 4.4, $k = 7 - 3 - 3 = 1$.
4. **Distance.** Every nonzero undetectable single-type error has weight at least $3$ — a finite check over the $2^7 = 128$ candidate vectors against the $2^3 = 8$ stabilizer combinations — and the codeword $X_1X_2X_3$ realises weight $3$. Hence $d_X = 3$; by the $H_X = H_Z$ symmetry, $d_Z = 3$; and by Theorem 5.7, $d = \min(3,3) = 3$.
5. **Bound.** $k + 2(d-1) = 1 + 4 = 5 < 7 = N$: the Singleton bound holds strictly, so the Steane code is not quantum-MDS.

Parameters: $[[7,1,3]]$.

**Comparison.** The hypercube graph code has exponentially many logical qubits and distance $1$; the Steane code has one logical qubit and distance $3$. Both are computed by the *same* definitions. The distinguishing structure is the presence of a nontrivial second sector of checks — and, by Theorem 6.4, the Steane code is not drawable as a graph at all.

---

## 9. Algorithms

All computations above are finite and effective. We record the three primitives.

**Algorithm A (Dictionary verification).** Input $H_X \in \mathbb{F}_2^{m_X\times N}$, $H_Z \in \mathbb{F}_2^{m_Z\times N}$. Compute $P = H_X H_Z^{\mathsf T}$ in $O(m_X m_Z N)$ operations and report $P = 0$. By Corollary 3.9 the same bit answers all three questions (nesting, orthogonality, abelianness), turning two exponential-looking checks — an inclusion of subspaces of size $2^{\operatorname{rank}H_Z}$ and a pairwise commutation test over a group of size $2^{\operatorname{rank}H_X + \operatorname{rank}H_Z}$ — into one matrix product.

**Algorithm B (Parameter computation).** Gaussian elimination over $\mathbb{F}_2$ gives $\operatorname{rank} H_X$ and $\operatorname{rank} H_Z$ in $O(mN\min(m,N))$ bit operations; then $k = N - \operatorname{rank}H_X - \operatorname{rank}H_Z$ by Theorem 4.4. This is polynomial, in contrast with distance.

**Algorithm C (Distance by sector enumeration).** By Theorem 5.7 the operational distance need not be searched over the full $4^N$ Pauli group: it suffices to compute $d_X$ and $d_Z$ separately and take the minimum. A direct implementation enumerates $\ker H_Z$ (size $2^{N - \operatorname{rank}H_Z}$), discards $\mathcal R(H_X)$, and minimises Hamming weight; dually for $d_Z$. The reduction is a genuine exponential saving in the exponent's constant, though computing the minimum distance of a code remains hard in general — for structured families (graph codes, cubes) the combinatorial arguments of Sections 6–7 replace enumeration entirely.

---

## 10. Discussion

**What the dictionary buys.** Each face of Corollary 3.9 is the natural home of a different task. Nesting is where the classical coding intuition lives (which classical codes can be paired?); orthogonality is where verification lives (one matrix product); isotropy is where the physics lives (the stabilizer group and its centraliser). Stating them as an identity of subspaces, rather than as a numerical coincidence, is what lets one move freely between the three without re-deriving anything.

**What the distance theorem buys.** It is easy to believe that a mixed error might be cheaper than any single-type error — after all, the trivial operators form a subgroup of the product group, and correlated cancellation is exactly how surprises usually arise. Theorem 5.5 shows that this particular cancellation cannot happen: the stabilizer group is a *product*, so triviality is componentwise. That single structural fact makes $d = \min(d_X, d_Z)$ true, and it is also precisely what fails for general (non-CSS) stabilizer codes, where the analogous reduction is unavailable.

**What the hypercube teaches.** Three separate errors compose in the folk claim: taking the systole (or worse, the girth) for the distance; taking the cube dimension for the block length; and taking connectivity-plus-symmetry as evidence of a small homology. Each is corrected by an exact statement here, and the corrected parameters $[[n2^{n-1}, 2^{n-1}(n-2)+1, 1]]$ tell a coherent story: a graph code with many independent cycles and no protection whatsoever in the primal sector.

**Scope and limits.** The equivalences of Section 3 hold over any commutative ring carrying a nondegenerate dot product; the field hypothesis enters only through equality of row and column rank in Theorem 4.4. The distance theorem needs both logical sectors to be nonempty; when $k = 0$ the minima are over empty sets and the notion degenerates. The graph obstruction of Theorem 6.3 is necessary, not sufficient.

---

## 11. Future work

1. **Bridgeless graphs and distance one.** For a finite graph $G$ with $\mathbb{F}_2$ incidence matrix $\partial_1$ and no $Z$-checks, we conjecture $d = 1$ iff $G$ has no bridge, and $d = 2$ iff $G$ has a bridge but no two parallel bridges (discarding isolated vertices). The key insight is that in a graph code the primal distance is not a systole at all but a *cosystole of the cut matroid*: $d_X$ is the minimum size of a non-cut, i.e. the girth of the bond matroid, which equals $1$ exactly when no single edge is a bond. The hypercube instance (Theorem 7.7) uses only that the chosen edge lies on a cycle — which is precisely bridgelessness — so the general statement is within reach of the same argument.

2. **Weight profiles and representability.** We conjecture that a binary matrix $M$ is the incidence matrix of a $k$-dimensional simplicial boundary map iff every column has weight exactly $k+1$ and the face-compatibility relations hold; for $k = 1$ this reduces to "every column has weight $2$". Consequently a binary CSS complex is graph-representable iff $H_X$ admits a column-weight-two form, and the rank bound $\operatorname{rank}H_X + 1 \le \#\text{rows}$ is necessary but not sufficient. The parity obstruction of Theorem 6.3 is only the degree-zero shadow of a whole family of weight constraints, one per skeleton dimension; the missing content is a normal-form algorithm turning a column-weight-two matrix into an explicit graph.

3. **No expander-free distance growth.** For every family of graph codes ($H_Z = 0$) we expect the distance to be bounded by a constant while $k$ grows linearly in $N$; genuine distance growth requires $2$-cells.

4. **Separating simplicial, cellular, and graph models.** The dimension theorem holds for an abstract complex over any field; realising every binary CSS complex by a *simplicial complex with its standard incidence maps* is substantially stronger and should not be conflated with viewing matrices as abstract differentials. One wants necessary and sufficient representability conditions, or a minimal counterexample beyond the two given here.

5. **Other meanings of "hypercube complex".** The cube graph, the filled cubical $n$-ball, its boundary sphere, and periodic cubical tori have different homology. Working out all four would isolate which object, if any, could have motivated a one-logical-qubit assertion — the filled ball is contractible, the boundary sphere has $H_{n-1} = \mathbb{F}_2$, and only in the periodic case does one get a toric-code-like family with growing distance.

6. **Bounds at the correct block length, systematically.** Theorem 7.10 compares against the quantum Singleton bound with $N = n2^{n-1}$; the same discipline should be applied to the quantum Hamming and Gilbert–Varshamov comparisons, and to families where $k/N$ and $d/N$ are both to be tracked.

---

## 12. Conclusion

Three formulations of the CSS construction — nested classical codes, orthogonal parity checks, abelian stabilizer group — are literally the same statement, and packaging a commuting check pair as a length-two chain complex makes the logical space the homology $C_1/C_2$ with $k + \operatorname{rank}H_X + \operatorname{rank}H_Z = N$. The operational distance of such a code is $\min(\text{systole},\text{cosystole})$, because the stabilizer group is a product of the two row spaces. Applying this to the $\mathbb{F}_2$ incidence complex of the $n$-cube — whose boundary matrix has rank exactly $2^n-1$, encoding connectivity — yields the parameters $[[n2^{n-1}, 2^{n-1}(n-2)+1, 1]]$: exponentially many logical qubits, and no error correction at all, notwithstanding girth $4$. Finally, not every binary CSS complex is a graph: a graph incidence matrix always obeys $\operatorname{rank}M + 1 \le |V|$, so codes with independent $X$-checks, the Steane code among them, have no graph model. The same machinery, run on the Steane code, returns $[[7,1,3]]$ exactly.
