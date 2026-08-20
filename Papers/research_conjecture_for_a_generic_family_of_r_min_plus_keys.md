# The Recession Geometry of Min-Plus Digests: Exact Collision Cones, Hitting-Set Duality, and the Collapse of Tropical Hashing

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We give a complete geometric analysis of the fibers of the min-plus ("tropical") matrix–vector digest
$$D_A(m)_i \;=\; \min_{1 \le j \le k} \bigl( m_j + A_{ij} \bigr), \qquad A \in \mathbb{R}^{r \times k},\ m \in \mathbb{R}^k,$$
the hash primitive underlying proposals for tropical cryptographic schemes. Our results determine, for every key and every message, the recession cone of the polyhedral fiber cell through that message.

We prove four groups of results. First, a **universal lower bound**: for every key $A$ and every message $m$, the collision cone at $m$ — the set of directions $v$ with $D_A(m + sv) = D_A(m)$ for all $s \ge 0$ — spans a subspace of dimension at least $k - r$. Second, an **exactness theorem in general position**: if each digest component has a unique minimizing coordinate $p(i)$, the collision cone is precisely $\{ v \ge 0 : v_{p(i)} = 0 \}$, of span-dimension exactly $k - r$ when $p$ is injective; the general-position locus is nonempty for all $r \le k$ and open (an explicit $g/4$ perturbation bound), and strictness cannot be dropped. Third, a **combinatorial duality**: a coordinate set $S$ may be freely increased without changing the digest if and only if every component retains an active coordinate outside $S$; consequently the maximal coordinate collision cone has dimension exactly $k - \tau(A,m)$, where $\tau$ is the minimum size of a hitting set of the family of active sets. We show the natural transversal (system-of-distinct-representatives) formulation of this criterion is *false*, exhibiting a two-component key whose active family has no transversal yet admits a one-dimensional collision cone. Fourth, we **refute the conjectured bounded-alphabet security threshold**: for any key family with $r < k$ and any two-letter alphabet, two distinct messages collide, with no dependence whatsoever on any key-spread parameter; the threshold is exactly two letters, and it is sharp in $r$ because $r = k$ admits digests injective on a box. Finally we show that **inversion is a one-shot test**: the fiber over $y$ is nonempty iff the explicit canonical candidate $m^\star_j = \max_i(y_i - A_{ij})$ lies in it, and the same holds under box constraints, so no hardness for constrained tropical mining can originate in the min-plus structure itself.

**Keywords:** min-plus algebra, tropical semiring, hash function, recession cone, polyhedral fiber, hitting set, vertex cover, collision resistance, preimage attack.

---

## 1. Introduction

### 1.1 Motivation

The min-plus (tropical) semiring $(\mathbb{R} \cup \{+\infty\}, \min, +)$ replaces addition by minimum and multiplication by addition. Its linear algebra is the algebra of shortest paths, of discrete-event scheduling, and of the combinatorial degenerations studied in tropical geometry. It is also **piecewise linear rather than linear**, and this observation has motivated a line of proposals to build cryptographic primitives — key exchange, signatures, hash functions — on min-plus operations, on the intuition that classical algebraic cryptanalysis (Gaussian elimination, Gröbner bases, lattice reduction) has no obvious purchase there.

This paper analyses the simplest such primitive. Fix a key: a matrix $A \in \mathbb{R}^{r \times k}$. A message is a vector $m \in \mathbb{R}^k$. Its digest is the min-plus matrix–vector product
$$D_A(m)_i = \min_{j} (m_j + A_{ij}), \qquad i = 1, \dots, r.$$
Compression corresponds to $r < k$. The design hope is that the destruction of information at each $\min$ — each component reports one number and refuses to say which of $k$ inputs produced it — should make the map hard to invert and hard to collide.

Our thesis is that this hope is misplaced for a reason that is not algebraic but *convex-geometric*. The map $D_A$ is a concave piecewise linear map whose linearity domains are indexed by the choice of an active coordinate for each component. Each fiber is therefore a polyhedral complex, and the relevant question is not "can I solve the equations?" but "**what is the recession cone of a fiber cell?**". Once that question is asked, the answer is immediate and complete, and it is fatal for the primitive.

### 1.2 Contributions

1. **Universal collision cone** (Theorem 4.3). For every $A$ and every $m$, $\dim \operatorname{span} \mathcal{C}_A(m) \ge k - r$, where $\mathcal{C}_A(m)$ is the collision cone at $m$. This upgrades all known "there is a collision" statements to a continuum of dimension $k - r$ through every message.

2. **Exact cone under general position** (Theorems 5.2 and 5.3). Unique minimizers pin the cone down to a coordinate orthant; distinct minimizers make its span exactly $(k-r)$-dimensional. Non-vacuity (Proposition 5.4), openness with explicit modulus (Theorem 5.5) and necessity of strictness (Proposition 5.6) are all established.

3. **Hitting-set duality** (Theorems 6.1, 6.3, 6.6). An exact local criterion for raisable coordinate sets, its reformulation as a hitting-set condition, the resulting exact formula $k - \tau(A,m)$ for the maximal coordinate cone dimension, and the refutation of the transversal (Hall/SDR) formulation (Proposition 6.4).

4. **Collapse of the bounded-alphabet defence** (Theorems 7.3, 7.4) and its sharpness (Theorem 7.5).

5. **Canonical inversion** (Theorems 8.2, 8.3), including the box-constrained case.

### 1.3 Organisation

Section 2 fixes notation. Section 3 records elementary monotonicity and invariance lemmas that drive everything else. Sections 4–8 contain the five groups of results. Section 9 reports computational evidence. Section 10 discusses cryptographic consequences, and Section 11 states open problems.

---

## 2. Setting and notation

Throughout, $k \ge 1$ and $r \ge 0$ are integers, $A \in \mathbb{R}^{r \times k}$ is a **key family** with entries $A_{ij}$ ($i \in \{1,\dots,r\}$, $j \in \{1,\dots,k\}$), and messages are vectors $m \in \mathbb{R}^k$. We write $\mathbb{R}^k_{\ge 0}$ for the nonnegative orthant and use $\le$ on vectors coordinatewise.

**Definition 2.1 (Digest).** The *$r$-component min-plus digest* of $m$ under $A$ is
$$D_A(m)_i \;=\; \min_{1 \le j \le k} \bigl( m_j + A_{ij} \bigr).$$

Two immediate facts, used constantly: $D_A(m)_i \le m_j + A_{ij}$ for all $j$, and $c \le D_A(m)_i$ whenever $c \le m_j + A_{ij}$ for all $j$. The minimum is attained because $k$ is finite.

**Definition 2.2 (Active set).** For a component $i$,
$$\mathrm{Act}_A(m, i) \;=\; \{\, j : m_j + A_{ij} = D_A(m)_i \,\} \;\ne\; \emptyset .$$
An element of $\mathrm{Act}_A(m,i)$ is called an *active* or *minimizing* coordinate, or a *certificate* for component $i$.

**Definition 2.3 (Collision cone).** The *collision cone* at $m$ is
$$\mathcal{C}_A(m) \;=\; \{\, v \in \mathbb{R}^k : D_A(m + sv) = D_A(m) \text{ for all } s \ge 0 \,\}.$$

$\mathcal{C}_A(m)$ is a closed cone containing $0$, and it is precisely the recession cone of the polyhedral cell of the fiber $D_A^{-1}(D_A(m))$ containing $m$: it consists of the directions along which one may travel to infinity without leaving the fiber. Its span-dimension is the natural measure of how badly the digest fails to be locally injective at $m$.

**Definition 2.4 (Collision support).** A set $S \subseteq \{1,\dots,k\}$ is a *collision support at $m$* if for every $t \in \mathbb{R}^k$ with $t \ge 0$ and $t_j = 0$ for all $j \notin S$ we have $D_A(m + t) = D_A(m)$. Write $\mathrm{Cone}(S) = \{ v \ge 0 : v_j = 0 \ \forall j \notin S \}$ for the associated coordinate orthant.

Note that $\mathrm{Cone}(S) \subseteq \mathcal{C}_A(m)$ whenever $S$ is a collision support, since $s v \in \mathrm{Cone}(S)$ for $s \ge 0$ and $v \in \mathrm{Cone}(S)$.

---

## 3. Two elementary lemmas

Everything in this paper rests on the following two observations.

**Lemma 3.1 (Monotonicity).** If $m \le m'$ coordinatewise, then $D_A(m)_i \le D_A(m')_i$ for every $i$.

*Proof.* For every $j$, $D_A(m)_i \le m_j + A_{ij} \le m'_j + A_{ij}$; take the minimum over $j$. $\square$

**Lemma 3.2 (Untouched-certificate invariance).** Let $t \ge 0$ and let $i$ be a component with a certificate $j_0 \in \mathrm{Act}_A(m,i)$ satisfying $t_{j_0} = 0$. Then $D_A(m + t)_i = D_A(m)_i$.

*Proof.* Upper bound: $D_A(m+t)_i \le (m + t)_{j_0} + A_{i j_0} = m_{j_0} + A_{ij_0} = D_A(m)_i$. Lower bound: for every $j$, $(m+t)_j + A_{ij} \ge m_j + A_{ij} \ge D_A(m)_i$, so $D_A(m)_i \le D_A(m+t)_i$. $\square$

Lemma 3.2 is the engine of every collision result below: *an increase that spares at least one certificate of every component is invisible to the digest.* Lemma 3.1 is the engine of the inversion results.

---

## 4. The universal collision cone

**Proposition 4.1 (Free coordinates).** For every $A$ and $m$ there is a collision support $S$ at $m$ with $|S| \ge k - r$.

*Proof.* Choose, for each component $i$, one certificate $p(i) \in \mathrm{Act}_A(m,i)$. Let $S = \{1,\dots,k\} \setminus p(\{1,\dots,r\})$. The image $p(\{1,\dots,r\})$ has at most $r$ elements, so $|S| \ge k - r$. If $t \ge 0$ vanishes off $S$, then in particular $t_{p(i)} = 0$ for every $i$, and Lemma 3.2 applies componentwise. $\square$

To convert cardinality into dimension we use the following two facts about coordinate subspaces. Let $V_S = \{ v \in \mathbb{R}^k : v_j = 0 \ \forall j \notin S \}$.

**Lemma 4.2.** $\dim V_S = |S|$, and $\operatorname{span} \mathrm{Cone}(S) = V_S$.

*Proof.* $V_S$ is the kernel of the restriction map $\mathbb{R}^k \to \mathbb{R}^{S^c}$, which is surjective, so rank–nullity gives $\dim V_S = k - |S^c| = |S|$. For the span: $\mathrm{Cone}(S) \subseteq V_S$ is clear. Conversely, any $v \in V_S$ decomposes as $v = v^+ - v^-$ with $v^\pm_j = \max(\pm v_j, 0)$, and both $v^+$ and $v^-$ lie in $\mathrm{Cone}(S)$. $\square$

**Theorem 4.3 (Universal lower bound).** For every key family $A \in \mathbb{R}^{r \times k}$ and every message $m \in \mathbb{R}^k$,
$$\dim \operatorname{span} \mathcal{C}_A(m) \;\ge\; k - r .$$

*Proof.* Take $S$ as in Proposition 4.1. Then $V_S = \operatorname{span}\mathrm{Cone}(S) \subseteq \operatorname{span}\mathcal{C}_A(m)$, and $\dim V_S = |S| \ge k - r$ by Lemma 4.2. $\square$

**Corollary 4.4 (Universal collisions).** If $r < k$ then for every $A$ and every $m$ there exists $m' \ne m$ with $D_A(m') = D_A(m)$; indeed one may take $m' = m + e_q$ for a suitable coordinate $q$.

Here $q$ is any *unused* coordinate — one such that every component has a certificate different from $q$ — which exists whenever $r < k$ by the pigeonhole argument of Proposition 4.1. We record this separately, since it is exactly the object used in Section 7.

**Lemma 4.5 (Unused coordinate).** If $r < k$, then for every $A$ and $m$ there is a coordinate $q$ such that every component $i$ has a certificate $j \ne q$.

*Proof.* Choose certificates $p(i)$; the set $p(\{1,\dots,r\})$ has at most $r < k$ elements, so some $q$ lies outside it, and $p(i) \ne q$ for all $i$. $\square$

**Lemma 4.6 (Bump invariance).** If $q$ is unused at $m$ and $d \ge 0$, then $D_A(m + d\,e_q) = D_A(m)$.

*Proof.* $t = d\,e_q$ is nonnegative and vanishes at the certificate $j \ne q$ of each component; apply Lemma 3.2. $\square$

---

## 5. Exact dimension in general position

Theorem 4.3 is a lower bound. We now show it is tight on an open, nonempty set of data, and identify the cone exactly there.

**Definition 5.1 (Strict minimizers).** A map $p : \{1,\dots,r\} \to \{1,\dots,k\}$ is a *strict minimizer system* for $(A,m)$ if for every $i$ and every $j \ne p(i)$,
$$D_A(m)_i \;<\; m_j + A_{ij}.$$
Equivalently, $\mathrm{Act}_A(m,i) = \{p(i)\}$ for every $i$.

**Theorem 5.2 (Exact cone).** Assume $r \ge 1$ and let $p$ be a strict minimizer system for $(A,m)$. Then
$$\mathcal{C}_A(m) \;=\; \bigl\{\, v \in \mathbb{R}^k \;:\; v_j \ge 0 \ \forall j, \ \ v_{p(i)} = 0 \ \forall i \,\bigr\}.$$

*Proof.* ($\supseteq$) If $v \ge 0$ and $v_{p(i)} = 0$, then for $s \ge 0$ the displacement $sv$ is nonnegative and vanishes at the certificate $p(i)$ of component $i$; Lemma 3.2 gives $D_A(m + sv)_i = D_A(m)_i$.

($\subseteq$) Let $v \in \mathcal{C}_A(m)$ and fix any component $i$, with $c = D_A(m)_i$.

*No coordinate may decrease.* Suppose $v_{q} < 0$ for some $q$. Put
$$s = \frac{m_{q} + A_{iq} - c + 1}{-v_{q}} \;\ge\; 0 ,$$
so that $s\,v_{q} = c - m_{q} - A_{iq} - 1$. Then
$$D_A(m + sv)_i \;\le\; m_{q} + s v_{q} + A_{iq} \;=\; c - 1 \;<\; c = D_A(m + sv)_i,$$
using $v \in \mathcal{C}_A(m)$ in the last equality — a contradiction. Hence $v \ge 0$.

*Certified coordinates are frozen.* Suppose $v_{p(i)} > 0$. Strictness gives a uniform gap
$$g \;=\; \min_{j \ne p(i)} \min\bigl(1,\ m_j + A_{ij} - c\bigr) \;>\; 0 ,$$
and let $M = 1 + \max_j |v_j| > 0$. Take $s = g / (2M) > 0$, so $s M = g/2$, and set $d = \min(g/2,\ s\,v_{p(i)}) > 0$. We claim $(m + sv)_j + A_{ij} \ge c + d$ for every $j$. For $j = p(i)$: $(m + sv)_{p(i)} + A_{i p(i)} = c + s v_{p(i)} \ge c + d$. For $j \ne p(i)$: $m_j + A_{ij} \ge c + g$ while $|s v_j| \le sM = g/2$, so $(m+sv)_j + A_{ij} \ge c + g/2 \ge c + d$. Taking the minimum, $D_A(m + sv)_i \ge c + d > c$, contradicting $v \in \mathcal{C}_A(m)$. Hence $v_{p(i)} = 0$. $\square$

**Theorem 5.3 (Exact recession dimension).** Assume $r \ge 1$, let $p$ be a strict minimizer system for $(A,m)$, and suppose $p$ is injective. Then
$$\dim \operatorname{span} \mathcal{C}_A(m) \;=\; k - r .$$

*Proof.* By Theorem 5.2, $\mathcal{C}_A(m) = \mathrm{Cone}(S)$ with $S$ the complement of $p(\{1,\dots,r\})$. Injectivity gives $|p(\{1,\dots,r\})| = r$, so $|S| = k - r$, and Lemma 4.2 yields $\operatorname{span}\mathrm{Cone}(S) = V_S$ of dimension $k - r$. $\square$

Together with Theorem 4.3 this settles the exact recession dimension: **$k-r$ universally as a lower bound, and exactly $k-r$ in general position.** Two complements show the general-position hypothesis is neither vacuous nor removable.

**Proposition 5.4 (Non-vacuity).** For every $r \le k$ there exist $A$ and an injective strict minimizer system at $m = 0$. Explicitly, take $A_{ij} = 0$ if $j = \iota(i)$ and $A_{ij} = 1$ otherwise, where $\iota$ is any injection $\{1,\dots,r\} \hookrightarrow \{1,\dots,k\}$; then $D_A(0)_i = 0$ and $p = \iota$ is a strict minimizer system.

**Theorem 5.5 (Openness of the generic locus, with explicit modulus).** Suppose $p$ is a strict minimizer system for $(A,m)$ with uniform gap $g > 0$, i.e.
$$m_{p(i)} + A_{i p(i)} + g \;\le\; m_j + A_{ij} \qquad \text{for all } i \text{ and all } j \ne p(i).$$
If $|A'_{ij} - A_{ij}| < g/4$ for all $i,j$ and $|m'_j - m_j| < g/4$ for all $j$, then $p$ is still a strict minimizer system for $(A', m')$.

*Proof.* Fix $i$ and $j \ne p(i)$. We must show $D_{A'}(m')_i < m'_j + A'_{ij}$. Since $D_{A'}(m')_i \le m'_{p(i)} + A'_{i p(i)}$, it suffices that
$$m'_{p(i)} + A'_{i p(i)} \;<\; m'_j + A'_{ij}.$$
Each of the four perturbations moves its term by less than $g/4$, so the left side is less than $m_{p(i)} + A_{ip(i)} + g/2$ and the right side exceeds $m_j + A_{ij} - g/2 \ge m_{p(i)} + A_{ip(i)} + g/2$. $\square$

Thus the exactness theorem holds on a nonempty open set of pairs $(A, m)$: general position is a robust hypothesis, not a measure-zero artefact.

**Proposition 5.6 (Strictness is necessary).** With $k = 2$, $r = 1$, $A = 0$ and $m = 0$, the digest is $D(m) = \min(m_1, m_2)$ and the collision cone spans all of $\mathbb{R}^2$, of dimension $2 > k - r = 1$.

*Proof.* $D_A(0) = 0$ and both coordinates are active. For either standard basis vector $e_q$ and any $s \ge 0$, the other coordinate is an untouched certificate, so $s e_q \in \mathcal{C}_A(0)$ by Lemma 3.2. Since $e_1, e_2$ span $\mathbb{R}^2$, the span of the cone is everything. $\square$

Degeneracy therefore *enlarges* the collision cone. From an adversarial standpoint this is the correct direction: ties never help the designer.

---

## 6. Hitting-set duality and the true security parameter

Proposition 5.6 shows the number of components $r$ is the wrong bookkeeping device when active sets overlap. We now determine the right one.

**Theorem 6.1 (Exact local criterion).** A set $S \subseteq \{1,\dots,k\}$ is a collision support at $m$ **if and only if** every component retains an active coordinate outside $S$:
$$S \text{ is a collision support} \iff \forall i,\ \exists j \notin S,\ j \in \mathrm{Act}_A(m,i).$$

*Proof.* ($\Leftarrow$) Immediate from Lemma 3.2.

($\Rightarrow$) Suppose some component $i$ has $\mathrm{Act}_A(m,i) \subseteq S$; write $c = D_A(m)_i$. Every $j \notin S$ then satisfies $m_j + A_{ij} > c$, so
$$\varepsilon \;=\; \min_j \begin{cases} 1 & j \in S \\ \min(1,\ m_j + A_{ij} - c) & j \notin S \end{cases}$$
is strictly positive, and $m_j + A_{ij} \ge c + \varepsilon$ for all $j \notin S$. Let $t = \varepsilon \cdot \mathbf{1}_S$, a legal displacement. For $j \in S$: $(m+t)_j + A_{ij} \ge c + \varepsilon$ since $m_j + A_{ij} \ge c$. For $j \notin S$: $(m+t)_j + A_{ij} = m_j + A_{ij} \ge c + \varepsilon$. Hence $D_A(m + t)_i \ge c + \varepsilon > c$, so $S$ is not a collision support. $\square$

**Definition 6.2 (Hitting number).** A *hitting set* of $(A, m)$ is a set $H \subseteq \{1,\dots,k\}$ meeting every active set: $H \cap \mathrm{Act}_A(m,i) \ne \emptyset$ for all $i$. The *hitting number* is
$$\tau(A, m) \;=\; \min\{\, |H| : H \text{ a hitting set} \,\}.$$
Equivalently, $\tau$ is the vertex-cover number of the hypergraph on $\{1,\dots,k\}$ whose edges are the active sets. It is well defined because $\{1,\dots,k\}$ is itself a hitting set (active sets are nonempty).

Theorem 6.1 says precisely: **$S$ is a collision support iff $S^c$ is a hitting set.** Both of the following are then immediate.

**Theorem 6.3 (Hitting-set criterion).** For $0 \le d \le k$, a collision support of size at least $d$ exists **iff** $(A,m)$ admits a hitting set of size at most $k - d$.

*Proof.* Given a collision support $S$ with $|S| \ge d$, $S^c$ is a hitting set of size $k - |S| \le k - d$. Conversely, given a hitting set $H$ with $|H| \le k - d$, the set $H^c$ is a collision support of size $k - |H| \ge d$. $\square$

**Proposition 6.4 (The transversal formulation is false).** Hitting sets, not systems of distinct representatives, govern the geometry. Let $k = r = 2$, $m = 0$ and $A_{ij} = 0$ if $j = 1$, $A_{ij} = 1$ if $j = 2$ (both rows equal to $(0,1)$). Then $D_A(0) = (0,0)$ and $\mathrm{Act}_A(0,1) = \mathrm{Act}_A(0,2) = \{1\}$. The family $(\{1\},\{1\})$ admits **no** system of distinct representatives, yet $S = \{2\}$ is a collision support, so a one-dimensional collision cone exists.

*Proof.* Both components attain their minimum $0$ at coordinate $1$ and only there, since coordinate $2$ contributes $0 + 1 = 1 > 0$. A transversal would need injective $f$ with $f(i) \in \{1\}$ for $i = 1,2$, forcing $f(1) = f(2) = 1$, contradicting injectivity. Meanwhile $\{1\} \not\subseteq S = \{2\}$, so by Theorem 6.1 $S$ is a collision support. $\square$

The conceptual point: a transversal demands *distinct* certificates for distinct components, whereas the geometry only demands that each component retain *some* certificate outside $S$ — and components may share. Sharing certificates is precisely what makes $\tau$ smaller than $r$ and the collision cone larger.

**Lemma 6.5.** $\tau(A,m) \le r$ for all $A, m$.

*Proof.* The image of any choice function $i \mapsto p(i) \in \mathrm{Act}_A(m,i)$ is a hitting set of size at most $r$. $\square$

**Theorem 6.6 (Maximal coordinate cone has dimension exactly $k - \tau$).** The set $\{ |S| : S \text{ a collision support at } m \}$ has greatest element $k - \tau(A,m)$. Consequently
$$\max\{\, \dim V_S : S \text{ a collision support} \,\} \;=\; k - \tau(A,m), \qquad \text{and} \qquad \dim \operatorname{span}\mathcal{C}_A(m) \;\ge\; k - \tau(A,m).$$

*Proof.* Attainment: let $H$ be a hitting set with $|H| = \tau$; by Theorem 6.1, $H^c$ is a collision support of size $k - \tau$. Upper bound: if $S$ is a collision support, $S^c$ is a hitting set, so $\tau \le |S^c| = k - |S|$, giving $|S| \le k - \tau$. The dimension statements follow from Lemma 4.2 and $\mathrm{Cone}(S) \subseteq \mathcal{C}_A(m)$. $\square$

Since $\tau \le r$ by Lemma 6.5, Theorem 6.6 refines Theorem 4.3, strictly so whenever active sets overlap. We therefore propose $\tau(A,m)$ — not $r$ — as the **local security parameter** of a min-plus digest: it is the exact codimension of the maximal coordinate collision cone, it is bounded by the number of components, and it drops whenever the key or the message creates ties.

---

## 7. No bounded-alphabet threshold

All of the above concerns real-valued messages. A natural defence is to restrict messages to a finite alphabet, on the intuition that the escaping ray of Theorem 4.3 must eventually leave the legal message space, and that this cut-off should be governed by a *key-spread* parameter such as $\max_{i,j} A_{ij} - \min_{i,j} A_{ij}$: collisions would appear only once the alphabet size exceeds the spread. We refute this. The correct threshold is **two letters**, with no dependence on the key at all.

**Lemma 7.1** (= Lemma 4.5). If $r < k$, then for every $A$ and every $m$ there is an unused coordinate $q$: every component has a certificate $j \ne q$.

**Lemma 7.2** (= Lemma 4.6). If $q$ is unused at $m$ and $d \ge 0$, then $D_A(m + d\,e_q) = D_A(m)$.

**Theorem 7.3 (Two-letter collision).** Let $r < k$, let $A \in \mathbb{R}^{r \times k}$ be arbitrary, and let $a < b$ be real numbers. Then there exist distinct messages $m, m' \in \{a, b\}^k$ with $D_A(m) = D_A(m')$.

*Proof.* Let $m$ be the constant message with all coordinates equal to $a$. By Lemma 7.1 there is an unused coordinate $q$ at $m$. Let $m' = m + (b-a) e_q$, i.e. $m'_q = b$ and $m'_j = a$ for $j \ne q$; both messages lie in $\{a,b\}^k$ and they differ at $q$ because $a \ne b$. By Lemma 7.2 with $d = b - a \ge 0$, $D_A(m') = D_A(m)$. $\square$

The construction involves no quantity derived from $A$. In particular, no key-spread parameter can control collision resistance: **the collision exists for every key**, and the colliding ray needs to travel not "far" but exactly one letter.

**Theorem 7.4 (Integer form).** Let $r < k$, let $A$ have integer entries, and let $B \ge 1$ be an integer. Then there are distinct messages $m, m' \in \{0, 1, \dots, B\}^k$ with $D_A(m) = D_A(m')$.

*Proof.* Apply Theorem 7.3 with $a = 0$, $b = 1$; the resulting messages are the all-zero vector and the indicator of an unused coordinate, both in $\{0,\dots,B\}^k$ since $B \ge 1$. $\square$

Sharpness has two sides. Over a one-letter alphabet the digest is vacuously injective (there is only one message), so the threshold $2$ cannot be lowered. And the hypothesis $r < k$ cannot be dropped.

**Theorem 7.5 (Sharpness in $r$).** For every $B \in \mathbb{R}$ and every $k$, there is a key family $A \in \mathbb{R}^{k \times k}$ whose digest is injective on the box $[0,B]^k$. Explicitly, $A_{ij} = 0$ if $i = j$ and $A_{ij} = B + 1$ otherwise; then $D_A(m)_i = m_i$ for every $m \in [0,B]^k$.

*Proof.* Fix $m \in [0,B]^k$ and $i$. Taking $j = i$ gives $D_A(m)_i \le m_i$. For $j \ne i$ we have $m_j + A_{ij} = m_j + B + 1 \ge B + 1 > B \ge m_i$, so every off-diagonal term exceeds $m_i$; hence $D_A(m)_i = m_i$. The digest is thus the identity on the box, in particular injective. $\square$

The transition is therefore located exactly at $r = k$ — and at $r = k$ the only known injective examples are, as the proof shows, essentially copies of the message. There is no compressing regime in which the min-plus digest resists collisions, over any alphabet.

---

## 8. Canonical inversion and constrained mining

We now turn from collisions to preimages: given $y \in \mathbb{R}^r$, find $m$ with $D_A(m) = y$. This is the analogue of *mining*. Naively the system
$$\min_j (m_j + A_{ij}) = y_i \qquad (i = 1,\dots,r)$$
is a disjunctive system: each equation splits into $k$ linear regions according to which coordinate is active, giving $k^r$ candidate patterns. We show no enumeration is needed.

**Definition 8.1 (Canonical candidate).** For $y \in \mathbb{R}^r$ set
$$m^\star_j \;=\; \max_{1 \le i \le r} \bigl( y_i - A_{ij} \bigr), \qquad j = 1, \dots, k$$
(assuming $r \ge 1$). Equivalently, $m^\star$ is the coordinatewise least vector satisfying all *inequality* constraints $m_j + A_{ij} \ge y_i$; indeed $m^\star_j \le m_j$ holds iff $y_i \le m_j + A_{ij}$ for all $i$.

**Theorem 8.2 (One-shot inversion).** For $r \ge 1$,
$$\bigl(\exists m : D_A(m) = y\bigr) \iff D_A(m^\star) = y .$$
Moreover, when the fiber is nonempty, $m^\star$ is its coordinatewise least element.

*Proof.* ($\Leftarrow$) trivial. ($\Rightarrow$) Let $D_A(m) = y$. For every $i, j$ we have $y_i = D_A(m)_i \le m_j + A_{ij}$, so $m^\star_j \le m_j$ for all $j$ — this is the "least element" claim. By definition of $m^\star$, $y_i \le m^\star_j + A_{ij}$ for all $j$, hence $y_i \le D_A(m^\star)_i$. By monotonicity (Lemma 3.1) and $m^\star \le m$, $D_A(m^\star)_i \le D_A(m)_i = y_i$. Therefore $D_A(m^\star) = y$. $\square$

Inversion thus costs a single $O(rk)$ evaluation of the formula plus one digest computation to check it. The disjunction over active patterns disappears entirely, because the digest is monotone and the inequality region has a least point.

**Theorem 8.3 (Box-constrained mining is also a one-shot test).** Let $L, U \in \mathbb{R}^k$ and let $w_j = \max(m^\star_j, L_j)$. Then
$$\bigl(\exists m : L \le m \le U, \ D_A(m) = y\bigr) \iff \bigl( w \le U \text{ and } D_A(w) = y \bigr).$$

*Proof.* ($\Leftarrow$) $w$ itself is a witness, since $w \ge L$ by construction. ($\Rightarrow$) Let $m$ be a constrained solution. By Theorem 8.2, $m^\star \le m$; also $L \le m$; hence $w \le m \le U$. For the digest: $y_i \le m^\star_j + A_{ij} \le w_j + A_{ij}$ for all $j$, so $y_i \le D_A(w)_i$; and by monotonicity $D_A(w)_i \le D_A(m)_i = y_i$. $\square$

**Corollary 8.4.** Restricting the message space to a box (a bounded alphabet, or a nonce family given by independent coordinate ranges) does not make tropical preimage search harder: it remains a one-shot test.

The consequence for the complexity landscape is a negative one for the designer: **whatever hardness a constrained tropical mining problem possesses cannot originate in the min-plus structure.** The min-plus part is solved by an explicit formula, and the argument survives any *upward-closed* constraint set with a computable least point. Hardness must be engineered by nonce languages that break upward closure and force genuine disjunctive reasoning.

---

## 9. Computational evidence

The theoretical picture was cross-checked against exhaustive computation on integer instances, using the integer digest $D_A(m)_i = \min_j (A_{ij} + m_j)$, brute-force enumeration of coordinate subsets, and brute-force hitting numbers.

- **Worked instances.** For $A$ with rows $(0,3,5,2)$, $(4,1,7,6)$, $(9,8,2,3)$ at $m = 0$: the digest is $(0,1,2)$, active sets are $\{1\}$, $\{2\}$, $\{3\}$, so $\tau = 3$ and the maximal coordinate cone has dimension $1 = k - \tau = k - r$ — the generic case. For $A$ with rows $(0,0,5,2)$, $(0,1,7,6)$ at $m=0$: active sets are $\{1,2\}$ and $\{1\}$, so $\tau = 1$ and the maximal cone has dimension $3 > k - r = 2$ — overlap strictly improves the bound. For $A$ with both rows $(0,1)$ at $m = 0$: active sets are $\{1\},\{1\}$, $\tau = 1$, maximal cone dimension $1 > k - r = 0$ — the transversal counterexample of Proposition 6.4.

- **Randomised check of Theorem 6.6.** Over $400$ pseudorandom instances with $k = 4$ and $r \in \{1,2,3\}$, the maximal coordinate collision cone dimension equalled $k - \tau$ in every instance, and dominated $k - r$ in every instance.

- **Randomised check of Theorem 8.3.** Over $50$ pseudorandom instances with $k = 3$ and box $\{0,\dots,12\}^3$, exhaustive search for a boxed preimage agreed in every instance with the one-shot test at the single candidate $\max(m^\star, 0)$.

---

## 10. Discussion: consequences for tropical cryptography

The results assemble into a coherent verdict on min-plus digests as cryptographic hash functions.

**Collision resistance is impossible below $r = k$.** Not merely "collisions exist": through *every* message there is a $(k-r)$-dimensional cone of colliding directions, and over a two-letter alphabet an explicit colliding pair is produced by inspection of any single certificate assignment. A hash with $r < k$ compresses, so *every* compressing min-plus digest is collision-broken in constant time.

**The failure is structural, not parametric.** No choice of key entries can help, because the collision construction never inspects them: it only chooses one certificate per component and increments elsewhere. This is the precise sense in which the min-plus intuition — "min destroys information, so inversion is hard" — is backwards. Min destroys information about *which* coordinate is active, but it simultaneously guarantees that the *inactive* coordinates are ignored, and ignored coordinates are free parameters for the adversary.

**Degeneracy helps the attacker.** The local invariant is the hitting number $\tau(A,m) \le r$, and the maximal coordinate collision cone has dimension exactly $k - \tau$. Overlapping active sets — which is what happens when keys have repeated or nearly repeated entries — reduce $\tau$ and enlarge the cone. There is no design pressure that makes degeneracy safe.

**Preimage resistance also fails, and monotonicity is why.** The whole disjunctive structure of the min-plus equations is short-circuited by a least element: the canonical candidate. Even under box constraints, the search collapses. Consequently, a proof-of-work scheme built on min-plus digests offers no work.

**Where the intuition was right.** The tropical semiring genuinely resists the *linear-algebraic* toolkit; Gaussian elimination has nothing to say here. The lesson is that a cryptographic primitive is not secured by the absence of one attack paradigm. Piecewise linear maps have their own natural analysis — convex and polyhedral geometry — and under that lens the min-plus digest is transparent. This mirrors a recurring history in tropical cryptography, where several proposed schemes fell to structural rather than algebraic attacks.

**Positive readings.** The same theorems can be read constructively outside cryptography. Theorem 6.1 is a clean characterisation of the invariance directions of a min-plus linear map, which is exactly the sensitivity analysis one wants for shortest-path and scheduling models: it says which arc costs or release times can be increased without perturbing the optimum, and by how much the analysis is limited (namely by the hitting number of the active hypergraph). Theorem 8.2 is a least-fixed-point inversion result of the kind familiar from residuation theory in max-plus algebra, and gives an $O(rk)$ solvability test for min-plus linear systems.

---

## 11. Open problems

1. **Full recession cone.** Theorem 6.6 determines the maximal *coordinate* cone. Is the full recession cone of the fiber cell through $m$ — including non-coordinate-aligned directions — also of dimension exactly $k - \tau(A,m)$, for every key and message? Randomised computation supports this without exception. A related global question: is the recession cone of the whole fiber of dimension $k - \min_{\text{cells}} \tau$?

2. **Complexity of the security parameter.** Deciding $\tau(A,m) \le d$ is a hypergraph vertex-cover question. Is it NP-complete when $r$ is part of the input? If so, the security parameter of a min-plus digest is well defined, universally too small to provide security, and yet not efficiently computable — an unusual combination.

3. **Measure and semialgebraic structure of the generic locus.** The set of pairs $(A, m)$ with unique and pairwise distinct minimizers is open (Theorem 5.5). Is it of full measure, and is its complement a semialgebraic set of computable degree, described by the vanishing of the differences $m_j + A_{ij} - m_{j'} - A_{ij'}$?

4. **Hardness by nonce language.** Theorem 8.3 shows box constraints preserve tractability, and the argument extends to any upward-closed constraint family with computable least point. Difference constraints $m_j - m_{j'} \le c$ are also expected to be tractable via shortest paths. Does preimage search become NP-complete once the nonce language admits arbitrary binary linear constraints, even for fixed $r$?

5. **Repaired primitives.** Does composing the min-plus digest with a non-monotone or non-piecewise-linear post-processing step restore any of the lost properties, or does the $(k-r)$-dimensional cone survive composition in a usable form for the adversary?

---

## Appendix: summary of results

| Statement | Content |
|---|---|
| Untouched-certificate invariance | A nonnegative bump sparing one certificate per component leaves the digest fixed. |
| Universal lower bound | $\dim \operatorname{span}\mathcal{C}_A(m) \ge k - r$ for all $A, m$. |
| Exact cone | With unique minimizers $p$: $\mathcal{C}_A(m) = \{v \ge 0 : v_{p(i)} = 0\}$. |
| Exact dimension | With unique and distinct minimizers: $\dim \operatorname{span}\mathcal{C}_A(m) = k - r$. |
| Non-vacuity, openness | Generic locus nonempty for $r \le k$; stable under $g/4$ perturbations. |
| Necessity of strictness | Zero key, $k=2$, $r=1$: cone spans $\mathbb{R}^2$, dimension $2 > 1$. |
| Exact local criterion | $S$ raisable iff every component keeps an active coordinate off $S$. |
| Hitting-set criterion | Cone of dimension $\ge d$ iff a hitting set of size $\le k - d$ exists. |
| Transversal formulation false | Rows $(0,1),(0,1)$, $m=0$: no SDR, yet a $1$-dimensional cone. |
| Exact coordinate-cone dimension | Maximal collision support has size exactly $k - \tau(A,m)$; $\tau \le r$. |
| Two-letter collision | $r<k$: distinct colliding messages over any $\{a,b\}$, any key. |
| Integer form | $r<k$, integer keys, $B \ge 1$: collision in $\{0,\dots,B\}^k$. |
| Sharpness in $r$ | $r = k$: an explicit key injective on $[0,B]^k$ (the identity digest). |
| One-shot inversion | Fiber nonempty iff $m^\star_j = \max_i(y_i - A_{ij})$ is a preimage; $m^\star$ is least. |
| Box-constrained mining | Decided by the single candidate $\max(m^\star, L)$. |
