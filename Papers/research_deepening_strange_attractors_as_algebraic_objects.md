# Strange Attractors as Algebraic Objects: Inverse Limits, Transfer Matrices, and the Spectral Form of Topological Entropy

**Aristotle**

*2026-08-11*

---

## Abstract

We develop a complete algebraic theory of symbolic strange attractors modelled on finite directed graphs, and we close the analytic–algebraic gap in that theory. Our starting point is a structure theorem with no hypotheses: for an arbitrary finite directed graph $E$ on a finite vertex set $V$, the space $\Lambda_E$ of infinite orbits is canonically homeomorphic to the inverse limit of the tower of finite path sets $\{P_n(E)\}_{n\ge 0}$ under the edge-deletion bonding maps, and the shift is realised on that tower. The limit is compact, Hausdorff and totally disconnected; when every vertex branches it is perfect, hence a Cantor set, and for the Lorenz template it is homeomorphic to $\{0,1\}^{\mathbb N}$ outright. Passing to the transfer matrix $A \in \{0,1\}^{V\times V}$, the $n$-periodic points of the shift are in bijection with closed walks of length $n$, so they are counted by $\operatorname{tr}(A^n)$, and Cayley–Hamilton forces this counting sequence to obey an integer linear recurrence of order at most $|V|$.

The main new results concern the topological entropy $h(E) = \lim_n n^{-1}\log|P_n(E)|$, which exists for every dead-end-free graph by Fekete subadditivity. We prove the **Spectral Entropy Theorem**: if the transfer matrix admits a strictly positive eigenvector with eigenvalue $\lambda$ (a *Perron datum*), then $h(E) = \log\lambda$. Three corollaries follow. (i) **Uniqueness of the Perron value**: any two positive eigenvectors have the same eigenvalue — the uniqueness half of Perron–Frobenius, derived by a purely dynamical argument. (ii) **Spectral bounds**: $1 \le \lambda \le |V|$. (iii) **Arithmeticity**: $\lambda$ is a root of the monic integral characteristic polynomial of $A$, hence $e^{h(E)}$ is an **algebraic integer**. We then remove the hypothesis by formalising the Collatz–Wielandt variational construction: every primitive finite digraph carries a Perron datum, its Perron value is the spectral radius, the corresponding eigenspace is a line, the value exceeds $1$ when $|V| \ge 2$ (so primitive attractors have strictly positive entropy), and all spectral statements become unconditional. Finally we prove the **Periodic Growth Theorem**: for primitive graphs, $n^{-1}\log \operatorname{tr}(A^n) \to h(E)$, which upgrades the conjugacy invariance of periodic-orbit counts to conjugacy invariance of the entropy and of the Perron value. Applied to the Lorenz template and a pruned variant we obtain $h = \log 2$ and $h = \log\varphi$ respectively, together with a purely algebraic proof that the two attractors are not topologically conjugate.

**Keywords:** strange attractor, inverse limit, subshift of finite type, transfer matrix, topological entropy, Perron–Frobenius theory, algebraic integer, Lorenz template.

---

## 1. Introduction

### 1.1 From a picture to a diagram

The Lorenz attractor is usually met as a *numerical* object: one integrates a vector field, plots an orbit, and estimates invariants — a fractal dimension, a Lyapunov exponent, an entropy. The geometric theory of the Lorenz flow, however, provides a route to an entirely different presentation. Strong contraction along the stable foliation collapses the flow onto a two-dimensional branched manifold, the *Lorenz template*, whose first-return map is one-dimensional. Coding the branches of the template turns orbits into infinite words and the return map into the shift; admissibility of words is governed by a finite directed graph. In this reduction, all of the surviving information is combinatorial.

This paper takes that reduction as a definition and asks what can be proved about the resulting objects *as algebra*. The answer is: essentially everything one wants, and with unexpected arithmetic rigidity at the end of it.

### 1.2 Summary of contributions

Write $E : V \times V \to \{\text{true},\text{false}\}$ for a directed graph on a finite vertex set $V$, and $A = A(E)$ for its $0/1$ transfer matrix.

1. **Inverse-limit theorem** (§3). $\Lambda_E \cong \varprojlim_n P_n(E)$, canonically and without hypotheses, compatibly with the shift; if $E$ has no dead ends the bonding maps are surjective.
2. **Topology** (§4). $\Lambda_E$ is compact, Hausdorff, totally disconnected; branching gives a closed-embedded Cantor set, uncountability, and perfectness. The Lorenz template gives $\Lambda \cong \{0,1\}^{\mathbb N}$.
3. **Counting and rationality** (§5). $n$-periodic points $\leftrightarrow$ closed walks $\leftrightarrow \operatorname{tr}(A^n)$; the sequence obeys the Cayley–Hamilton recurrence of $\chi_A$; the counts are conjugacy invariants.
4. **Entropy exists** (§6). Submultiplicativity plus Fekete; monotonicity; $h \le \log|V|$.
5. **Spectral form of entropy** (§7). $h = \log\lambda$ for any Perron datum; uniqueness of $\lambda$; $1\le\lambda\le|V|$; $e^h$ is an algebraic integer.
6. **Existence of Perron data** (§8). Collatz–Wielandt for primitive graphs; simplicity; spectral dominance; positivity of entropy.
7. **Periodic growth and conjugacy invariance** (§9). $n^{-1}\log\operatorname{tr}(A^n)\to h$; entropy and Perron value are conjugacy invariants; primitivity $\Leftrightarrow$ eventual positivity of $A^n$ $\Leftrightarrow$ topological mixing.
8. **Chaos** (§10) and **the two templates** (§11).

---

## 2. Definitions

Throughout, $V$ is a finite nonempty type and $E : V \times V \to \{\text{true},\text{false}\}$ a directed-graph edge relation; we write $u \to v$ for $E(u,v) = \text{true}$.

**Definition 2.1 (Finite path sets).** For $n \in \mathbb{N}$,
$$P_n(E) \;=\; \bigl\{\, w : \{0,\dots,n\} \to V \;\big|\; w_i \to w_{i+1} \text{ for all } i < n \,\bigr\},$$
the set of walks using exactly $n$ edges. Each $P_n(E)$ is finite, with $|P_0(E)| = |V|$.

**Definition 2.2 (Bonding maps).** $\pi_n : P_{n+1}(E) \to P_n(E)$ restricts a walk to its first $n$ edges (*edge deletion*).

**Definition 2.3 (Orbit space).**
$$\Lambda_E \;=\; \bigl\{\, x : \mathbb{N}\to V \;\big|\; x_n \to x_{n+1} \text{ for all } n \,\bigr\} \ \subseteq\ V^{\mathbb N},$$
topologised as a subspace of the product of discrete copies of $V$. The **shift** is $\sigma(x)_n = x_{n+1}$.

**Definition 2.4 (Inverse limit).**
$$\varprojlim_n P_n(E) \;=\; \Bigl\{\, (f_n)_{n\in\mathbb N} \in \textstyle\prod_n P_n(E) \;\Big|\; \pi_n(f_{n+1}) = f_n \ \ \forall n \,\Bigr\}.$$

**Definition 2.5 (Transfer matrix).** $A = A(E) \in \mathbb{Z}^{V\times V}$, $A_{ij} = 1$ if $i\to j$ and $0$ otherwise. We use the same symbol for its images in $\mathbb{N}^{V\times V}$ and $\mathbb{R}^{V\times V}$.

**Definition 2.6 (Structural hypotheses).**
- $E$ has **no dead ends** if every vertex has out-degree $\ge 1$.
- $E$ is **branching** if every vertex has out-degree $\ge 2$ (branching $\Rightarrow$ no dead ends).
- $E$ is **primitive** if there is $N \ge 1$ such that for every $n \ge N$ and every ordered pair $(u,v)$ there is a walk of length *exactly* $n$ from $u$ to $v$.

**Definition 2.7 (Closed walks and periodic points).** $\mathrm{CW}_n(E) = \{w \in P_n(E) : w_0 = w_n\}$; $\mathrm{Per}_n(E) = \{x \in \Lambda_E : \sigma^n(x) = x\}$.

**Definition 2.8 (Conjugacy).** $E$ and $F$ are **conjugate** if there is a shift-equivariant bijection $\Lambda_E \to \Lambda_F$.

**Definition 2.9 (Perron datum).** A **Perron datum** for $E$ is a pair $(\lambda, v)$ with $v : V \to \mathbb{R}$ strictly positive in every coordinate and
$$\sum_{j\in V} A_{ij}\, v_j \;=\; \lambda\, v_i \qquad \text{for all } i \in V,$$
i.e. $Av = \lambda v$ with $v > 0$. We call $\lambda$ the **Perron value**.

**Definition 2.10 (Entropy).** For dead-end-free $E$ put $L_n = \log |P_n(E)|$ (finite and $\ge 0$, since $P_n(E) \ne \emptyset$) and
$$h(E) \;=\; \lim_{n\to\infty} \frac{L_n}{n}.$$
Existence of the limit is Theorem 6.2.

**Definition 2.11 (The two templates).** $V = \{\mathsf{L},\mathsf{R}\}$ (identified with $\{\text{false},\text{true}\}$).
- The **Lorenz template** $E_{\mathrm{Lor}}$: all four transitions allowed, $A_{\mathrm{Lor}} = \begin{pmatrix}1&1\\1&1\end{pmatrix}$.
- The **pruned template** $E_{\mathrm{pr}}$: the transition $\mathsf{R}\to\mathsf{R}$ forbidden, $A_{\mathrm{pr}} = \begin{pmatrix}1&1\\1&0\end{pmatrix}$.

---

## 3. The inverse-limit theorem

**Theorem 3.1 (Inverse Limit Theorem).** For every finite directed graph $E$ there is a canonical bijection
$$\Phi : \Lambda_E \;\xrightarrow{\ \sim\ }\; \varprojlim_n P_n(E), \qquad \Phi(x)_n = (x_0,\dots,x_n).$$

*Proof sketch.* $\Phi(x)_n$ is a walk because $x$ satisfies the edge condition at every index, and $\pi_n(\Phi(x)_{n+1}) = \Phi(x)_n$ by construction, so $\Phi$ lands in the limit. For the inverse, given a coherent family $(f_n)$, coherence says $f_{n+1}$ restricted to $\{0,\dots,n\}$ equals $f_n$; hence $x_n := (f_n)_n$ is well defined and satisfies $(f_m)_k = x_k$ for all $k \le m$ (induction on $m - k$). The edge condition $x_n \to x_{n+1}$ is the last edge condition of $f_{n+1}$. The two constructions are mutually inverse by extensionality. $\square$

**Theorem 3.2 (Shift on the tower).** $\Phi$ intertwines $\sigma$ with the map that deletes the first edge at every level: $\Phi(\sigma x)_n = (x_1,\dots,x_{n+1})$.

**Theorem 3.3 (Nondegeneracy).** If $E$ has no dead ends, every bonding map $\pi_n$ is surjective, and $P_n(E)\ne\emptyset$ for all $n$; consequently $|P_n(E)| \ge 1$ and $\Lambda_E \ne \emptyset$.

*Proof sketch.* Given $w \in P_n(E)$, choose an out-neighbour $v$ of $w_n$ and append it; the result lies in $P_{n+1}(E)$ and deletes back to $w$. Nonemptiness follows by iterating from any vertex. $\square$

Theorem 3.1 is the conceptual pivot: an infinite dynamical object is *identical to* a diagram of finite combinatorial objects. Every later theorem is an exploitation of that identification.

---

## 4. Topology of the limit

Give $V$ the discrete topology and $V^{\mathbb N}$ the product topology.

**Theorem 4.1 (Compactness).** $\Lambda_E$ is a closed subset of $V^{\mathbb N}$, hence compact; and it is Hausdorff and totally disconnected.

*Proof sketch.* $\Lambda_E = \bigcap_{n} \{x : E(x_n,x_{n+1})\}$, and each set in the intersection is the preimage of a clopen subset of $V\times V$ under the continuous evaluation $x \mapsto (x_n,x_{n+1})$. Closed subsets of a compact Hausdorff totally disconnected space inherit all three properties. $\square$

**Theorem 4.2 (Continuity of the dynamics).** $\sigma : \Lambda_E \to \Lambda_E$ is continuous, so $(\Lambda_E, \sigma)$ is a topological dynamical system.

**Theorem 4.3 (Embedded Cantor set).** If $E$ is branching then for each $v_0 \in V$ there is a closed topological embedding $\{0,1\}^{\mathbb N} \hookrightarrow \Lambda_E$.

*Proof sketch.* Branching supplies, for each vertex $v$, two *distinct* out-neighbours $s_0(v) \ne s_1(v)$. Define $c(b)_0 = v_0$ and $c(b)_{n+1} = s_{b_n}(c(b)_n)$. This is an orbit by construction; it is injective because the first index where two binary sequences differ produces distinct vertices at the next coordinate; it is continuous because each coordinate depends on finitely many $b_i$; and a continuous injection from a compact space to a Hausdorff space is a closed embedding. $\square$

**Corollary 4.4 (Uncountability).** A branching attractor is uncountable, even though every $P_n(E)$ is finite.

**Theorem 4.5 (Perfectness).** If $E$ is branching, $\Lambda_E$ has no isolated points.

*Proof sketch.* Given $x$ and $n$, use branching to pick at step $n$ an out-neighbour *different* from $x_{n+1}$, then continue arbitrarily (possible since branching implies no dead ends). The resulting orbit agrees with $x$ up to index $n$ but differs at $n+1$, and cylinders form a neighbourhood basis. $\square$

**Corollary 4.6 (Cantor structure).** A branching symbolic attractor is a compact, perfect, totally disconnected, metrizable space: a Cantor set.

**Theorem 4.7 (Lorenz template).** $\Lambda_{E_{\mathrm{Lor}}} \cong \{0,1\}^{\mathbb N}$, by the map forgetting the (vacuous) edge conditions.

---

## 5. Counting: closed walks, traces, rationality

**Theorem 5.1 (Periodic points are closed walks).** For $n \ge 1$ there is a canonical bijection $\mathrm{Per}_n(E) \cong \mathrm{CW}_n(E)$.

*Proof sketch.* An orbit fixed by $\sigma^n$ satisfies $x_{k+n} = x_k$ for all $k$, hence is determined by $(x_0,\dots,x_{n-1})$ and repeats with period $n$; reading $x_0,\dots,x_n$ gives a closed walk. Conversely a closed walk extends periodically, and the edge condition at the wrap-around index holds precisely because $w_n = w_0$. The two maps are mutually inverse by reduction modulo $n$. $\square$

**Theorem 5.2 (Matrix counting).** $(A^n)_{ij}$ equals the number of $n$-edge walks from $i$ to $j$; hence
$$|P_n(E)| = \sum_{i,j\in V} (A^n)_{ij}, \qquad |\mathrm{CW}_n(E)| = \operatorname{tr}(A^n).$$

*Proof sketch.* Induction on $n$: walks of length $n+1$ from $i$ to $j$ are classified by their penultimate vertex $k$ with $k \to j$, giving a bijection onto $\bigsqcup_{k: k\to j} \{\text{walks } i\to k \text{ of length } n\}$, which is the matrix product. $\square$

**Theorem 5.3 (Conjugacy invariance of orbit counts).** If $E$ and $F$ are conjugate then $\operatorname{tr}(A(E)^n) = \operatorname{tr}(A(F)^n)$ for all $n\ge 1$.

*Proof sketch.* A shift-equivariant bijection restricts to a bijection $\mathrm{Per}_n(E) \to \mathrm{Per}_n(F)$; apply Theorems 5.1 and 5.2. $\square$

**Theorem 5.4 (Cayley–Hamilton recurrence).** Let $M$ be any $d\times d$ matrix over a commutative ring with characteristic polynomial $\chi_M(t) = \sum_{i=0}^{d} c_i t^i$ ($c_d = 1$). Then for every $k \ge 0$,
$$\sum_{i=0}^{d} c_i \operatorname{tr}\bigl(M^{k+i}\bigr) \;=\; 0 .$$

*Proof sketch.* Cayley–Hamilton gives $\chi_M(M) = 0$; multiply by $M^k$, expand, and take the trace, which is linear. $\square$

**Corollary 5.5 (Rationality, finite-graph form).** The periodic-orbit counting sequence $n \mapsto |\mathrm{Per}_n(E)|$ satisfies an integer linear recurrence of order at most $|V|$, with coefficients the characteristic-polynomial coefficients of the transfer matrix. Equivalently, its generating function is rational — the finite-graph shadow of rationality of the Artin–Mazur zeta function.

**Example 5.6 (Two-vertex templates).** For $M$ a $2\times2$ matrix, $\chi_M(t) = t^2 - (\operatorname{tr} M)t + \det M$, so
$$\operatorname{tr}(M^{k+2}) = (\operatorname{tr} M)\operatorname{tr}(M^{k+1}) - (\det M)\operatorname{tr}(M^{k}).$$
For $A_{\mathrm{Lor}}$: $\operatorname{tr} = 2$, $\det = 0$, giving $t_{k+2} = 2t_{k+1}$ and $\operatorname{tr}(A^n_{\mathrm{Lor}}) = 2^n$. For $A_{\mathrm{pr}}$: $\operatorname{tr} = 1$, $\det = -1$, giving $t_{k+2} = t_{k+1} + t_k$ with $t_1 = 1$, $t_2 = 3$: the **Lucas numbers** $1,3,4,7,11,18,\dots$, i.e. $\operatorname{tr}(A^n_{\mathrm{pr}}) = F_{n+1} + F_{n-1}$.

**Corollary 5.7 (Non-conjugacy).** $E_{\mathrm{Lor}}$ and $E_{\mathrm{pr}}$ are **not** topologically conjugate, since $\operatorname{tr}(A_{\mathrm{Lor}}^2) = 4 \ne 3 = \operatorname{tr}(A_{\mathrm{pr}}^2)$.

A finite computation — comparing two integers — separates two infinite chaotic systems.

---

## 6. Entropy exists

**Lemma 6.1 (Submultiplicativity).** $|P_{m+n}(E)| \le |P_m(E)|\cdot|P_n(E)|$.

*Proof sketch.* The map sending a walk of length $m+n$ to (its first $m$ edges, its last $n$ edges) is injective: the two halves overlap in the vertex at index $m$ and together determine every coordinate. $\square$

**Theorem 6.2 (Existence of entropy).** For dead-end-free $E$ the sequence $L_n = \log|P_n(E)|$ is subadditive and nonnegative, so by Fekete's lemma
$$h(E) = \lim_{n\to\infty}\frac{L_n}{n} = \inf_{n\ge1}\frac{L_n}{n}$$
exists and is finite.

**Theorem 6.3 (Bounds and monotonicity).** $0 \le h(E) \le \log|V|$; and if $E \subseteq F$ (every edge of $E$ is an edge of $F$) with both dead-end-free, then $h(E) \le h(F)$.

*Proof sketch.* A walk of length $n$ is determined by its $n+1$ vertices, so $|P_n(E)| \le |V|^{n+1}$; divide by $n$ and take limits, using $\log|V|^{(n+1)}/n \to \log|V|$. Monotonicity is immediate from $P_n(E) \subseteq P_n(F)$. $\square$

At this stage entropy is an *analytic* invariant (a limit) and the transfer matrix is an *algebraic* one (a table of integers), related only by inequalities. The next section identifies them.

---

## 7. The spectral form of the entropy

This section contains the central new theorem. Fix a Perron datum $(\lambda, v)$ for $E$ (Definition 2.9).

**Lemma 7.1 (Propagation to powers).** For all $n$ and all $i$, $\sum_j (A^n)_{ij} v_j = \lambda^n v_i$.

*Proof sketch.* Induction on $n$. The case $n=0$ is the identity matrix. For the step, write $(A^{n+1})_{ij} = \sum_k (A^n)_{ik}A_{kj}$, exchange the order of summation, apply the eigenvector equation at $k$, and pull out $\lambda$. $\square$

**Lemma 7.2 (Positivity of the value).** If $E$ has no dead ends then $\lambda > 0$.

*Proof sketch.* Pick $i$ and an out-neighbour $j_0$. All terms of $\sum_j A_{ij}v_j$ are $\ge 0$ and the $j_0$-term is $v_{j_0} > 0$, so the sum is positive; it equals $\lambda v_i$ with $v_i > 0$. $\square$

**Lemma 7.3 (Counting bounds).** Let $c = \min_i v_i > 0$, $C = \max_i v_i > 0$, $S = \sum_i v_i > 0$. Then for every $n$,
$$\frac{S}{C}\,\lambda^n \;\le\; |P_n(E)| \;\le\; \frac{S}{c}\,\lambda^n .$$

*Proof sketch.* Summing Lemma 7.1 over $i$ gives $\sum_{i,j}(A^n)_{ij}v_j = \lambda^n S$. Bounding $v_j$ below by $c$ and above by $C$ inside the double sum, and using $|P_n(E)| = \sum_{i,j}(A^n)_{ij}$ (Theorem 5.2), yields
$$c\,|P_n(E)| \;\le\; \lambda^n S \;\le\; C\,|P_n(E)|,$$
which rearranges to the claim. $\square$

**Theorem 7.4 (Spectral Entropy Theorem).** Let $E$ be a finite directed graph without dead ends carrying a Perron datum $(\lambda, v)$. Then
$$\boxed{\,h(E) = \log\lambda\,.}$$

*Proof sketch.* Taking logarithms in Lemma 7.3,
$$\log\tfrac{S}{C} + n\log\lambda \;\le\; L_n \;\le\; \log\tfrac{S}{c} + n\log\lambda .$$
Divide by $n$. Both bounding sequences are of the form $(a + n\log\lambda)/n = a/n + \log\lambda \to \log\lambda$, so by the squeeze theorem $L_n/n \to \log\lambda$. Since $L_n/n \to h(E)$ by Theorem 6.2 and limits in a Hausdorff space are unique, $h(E) = \log\lambda$. $\square$

Notice the economy: the *only* features of the eigenvector used are its minimum and maximum coordinates, and both are washed out by dividing by $n$. No irreducibility, no aperiodicity, no spectral gap is needed — only positivity.

**Theorem 7.5 (Uniqueness of the Perron value).** If $E$ is dead-end-free and $(\lambda,v)$, $(\mu,w)$ are Perron data for $E$, then $\lambda = \mu$.

*Proof sketch.* Both equal $e^{h(E)}$ by Theorem 7.4, since $\log$ is injective on $(0,\infty)$ and both values are positive by Lemma 7.2. $\square$

This is the uniqueness half of the Perron–Frobenius theorem, obtained by an argument that never mentions cones, fixed points, or irreducibility. The dynamics does the work: entropy is defined without reference to any eigenvector, so it arbitrates between competing ones.

**Corollary 7.6 (Spectral bounds).** For dead-end-free $E$ with a Perron datum, $1 \le \lambda \le |V|$.

*Proof sketch.* Upper: $\log\lambda = h(E) \le \log|V|$ (Theorem 6.3). Lower: let $i_0$ minimise $v$ and let $j_0$ be an out-neighbour of $i_0$; then $\lambda v_{i_0} = \sum_j A_{i_0 j}v_j \ge v_{j_0} \ge v_{i_0} > 0$. $\square$

### 7.1 Arithmetic rigidity

**Lemma 7.7 (Singularity).** If $(\lambda, v)$ is a Perron datum then $\det(\lambda I - A) = 0$ over $\mathbb{R}$.

*Proof sketch.* $v \ne 0$ and $(\lambda I - A)v = 0$; a square matrix with a nonzero kernel vector is singular. $\square$

**Theorem 7.8 (Arithmeticity of the Perron value).** The Perron value $\lambda$ of a finite directed graph is an **algebraic integer**: it is a root of the characteristic polynomial $\chi_{A}\in\mathbb{Z}[t]$ of the integral transfer matrix, which is monic of degree $|V|$.

*Proof sketch.* $\chi_A$ is monic with integer coefficients because $A$ has integer entries. Its image under $\mathbb{Z}\to\mathbb{R}$ is the characteristic polynomial of the real transfer matrix, whose evaluation at $\lambda$ is $\det(\lambda I - A) = 0$ by Lemma 7.7. Hence $\lambda$ satisfies a monic integral polynomial. $\square$

**Corollary 7.9 (Arithmeticity of the entropy).** For every symbolic attractor admitting a Perron datum, $e^{h(E)}$ is an algebraic integer; equivalently, $h(E)$ lies in the countable set $\{\log\alpha : \alpha \text{ an algebraic integer}, \alpha>0\}$.

*Proof sketch.* $e^{h(E)} = e^{\log\lambda} = \lambda$ by Theorem 7.4 and positivity, then Theorem 7.8. $\square$

This is a genuine constraint. A priori, a limit of logarithms of integer counts divided by $n$ could be any nonnegative real; the algebraic presentation forbids all but countably many values, and pins the possible values, for a given vertex count $d$, to the roots of monic integer polynomials of degree $d$ with $0/1$ companion data.

---

## 8. Existence of Perron data: the Collatz–Wielandt construction

Theorem 7.4 is conditional on a positive eigenvector existing. We now construct one. Throughout this section $E$ is primitive (Definition 2.6) and $A$ its real transfer matrix.

**Lemma 8.1 (Primitivity is matrix positivity).** $E$ is primitive if and only if there is $N \ge 1$ with $(A^n)_{uv} \ge 1$ for all $n \ge N$ and all $u,v \in V$.

*Proof sketch.* Both directions are Theorem 5.2: walks of length $n$ from $u$ to $v$ are counted by $(A^n)_{uv}$, so existence of a walk is positivity of the entry. $\square$

Thus the combinatorial hypothesis used for mixing (§10) and the analytic hypothesis of Perron–Frobenius are literally the same condition.

**Lemma 8.2 (Primitive $\Rightarrow$ no dead ends).** Immediate from Lemma 8.1 with $n = N$: some walk leaves every vertex.

**Definition 8.3 (Collatz–Wielandt set).**
$$\mathcal{C} \;=\; \bigl\{\, (t,x) \in \mathbb{R}\times\mathbb{R}^V \;\big|\; x \in \Delta,\ \ t\,x_i \le (Ax)_i \ \forall i \,\bigr\},$$
where $\Delta = \{x \ge 0 : \sum_i x_i = 1\}$ is the standard simplex.

**Lemma 8.4 (Compactness).** $\mathcal{C}$ is compact and nonempty; moreover $(t,x)\in\mathcal{C}$ implies $0 \le t \le |V|$ when $x \in \Delta$ is nonzero.

*Proof sketch.* Closedness: $\Delta$ is closed and $x \mapsto Ax$ is continuous, so the defining inequalities cut out a closed set. Boundedness: summing $t x_i \le (Ax)_i$ over $i$ gives $t = t\sum_i x_i \le \sum_{i,j}A_{ij}x_j \le |V|\sum_j x_j = |V|$, since each column sum of $A$ is at most $|V|$. Nonemptiness: the uniform vector $u = (1/|V|,\dots,1/|V|)$ satisfies $(Au)_i \ge 1/|V| = u_i$ because $E$ has no dead ends, so $(1, u) \in \mathcal{C}$. $\square$

**Definition 8.5 (Collatz–Wielandt value).** $r = \max\{t : (t,x)\in\mathcal{C}\text{ for some }x\}$, attained by compactness; $r \ge 1$ by Lemma 8.4.

**Theorem 8.6 (A maximiser is an eigenvector).** If $(r,x) \in \mathcal{C}$ is a maximiser then $Ax = r x$.

*Proof sketch.* Set $w = Ax - rx \ge 0$ and suppose $w \ne 0$. Choose $k$ with all entries of $A^k$ positive (Lemma 8.1). Then $A^k w > 0$ strictly, coordinatewise. Put $z = A^k x$ and let $y = z/\|z\|_1 \in \Delta$. Applying $A^k$ to $Ax \ge rx$ and using $A^kA = AA^k$ gives $Ay - r y = A^k w/\|z\|_1 > 0$ strictly. By finiteness of $V$ there is $\varepsilon>0$ with $Ay \ge (r+\varepsilon)y$, so $(r+\varepsilon, y) \in \mathcal{C}$, contradicting maximality of $r$. Hence $w = 0$. $\square$

**Theorem 8.7 (Existence).** Every primitive finite directed graph carries a Perron datum.

*Proof sketch.* Take a maximiser $(r,x)$; Theorem 8.6 gives $Ax = rx$ with $x \in \Delta$, so $x \ge 0$ and $x \ne 0$. Positivity of every coordinate follows by applying $A^k$: $r^k x = A^k x > 0$ because $A^k > 0$ and $x$ is nonnegative and nonzero, and $r \ge 1 > 0$. $\square$

**Definition 8.8.** For primitive $E$, let $\lambda_{\mathrm{P}}(E)$ denote the (by Theorem 7.5 unique) Perron value.

Combining with §7 gives the unconditional forms:

**Theorem 8.9 (Unconditional spectral entropy).** For every primitive finite directed graph,
$$h(E) = \log\lambda_{\mathrm{P}}(E), \qquad e^{h(E)} = \lambda_{\mathrm{P}}(E) \text{ is an algebraic integer}, \qquad 1 \le \lambda_{\mathrm{P}}(E) \le |V|.$$

**Theorem 8.10 (Positive entropy).** If $E$ is primitive and $|V| \ge 2$, then $\lambda_{\mathrm{P}}(E) > 1$ and hence $h(E) > 0$.

*Proof sketch.* Let $N$ be a primitivity exponent, so $(A^N)_{ij}\ge 1$ for all $i,j$ and therefore $|P_N(E)| \ge |V|^2 \ge |V|$. Combined with the counting bound $|P_n(E)| \le \frac{S}{c}\lambda^n$ one gets $|V| \le \operatorname{const}\cdot\lambda^{N}$ for all primitivity exponents, and iterating $N \mapsto mN$ forces $\lambda > 1$ once $|V| \ge 2$; then $h = \log\lambda > 0$. $\square$

**Theorem 8.11 (Geometric simplicity).** For primitive $E$, if $Ay = \lambda_{\mathrm{P}}(E)\,y$ then $y$ is a scalar multiple of the positive Perron eigenvector. The $\lambda_{\mathrm{P}}$-eigenspace is a line.

*Proof sketch.* Given an eigenvector $y$ and the positive eigenvector $v$, consider $t = \min_i y_i/v_i$ attained at some $i_0$. The vector $y - t v$ is an eigenvector, nonnegative, with a zero coordinate. Applying a positive power $A^k$ would make it strictly positive unless it is zero; since $A^k(y-tv) = \lambda^k(y-tv)$ still has a zero coordinate at $i_0$, it must vanish, so $y = tv$. $\square$

**Theorem 8.12 (Spectral dominance).** For primitive $E$, if $Ay = \mu y$ for a real $\mu$ and $y \ne 0$, then $|\mu| \le \lambda_{\mathrm{P}}(E)$; that is, $\lambda_{\mathrm{P}}(E)$ is the greatest real eigenvalue and equals the spectral radius restricted to real eigenvalues.

*Proof sketch.* Take $i_0$ maximising $|y_i|/v_i$, where $v$ is the positive eigenvector. Then
$$|\mu|\,|y_{i_0}| = \Bigl|\sum_j A_{i_0j}y_j\Bigr| \le \sum_j A_{i_0j}|y_j| \le \frac{|y_{i_0}|}{v_{i_0}}\sum_j A_{i_0j}v_j = \frac{|y_{i_0}|}{v_{i_0}}\lambda_{\mathrm{P}}v_{i_0} = \lambda_{\mathrm{P}}|y_{i_0}|,$$
and $|y_{i_0}| > 0$. $\square$

**Corollary 8.13.** The topological entropy of a primitive symbolic attractor is the logarithm of the spectral radius of its transfer matrix.

---

## 9. Periodic orbits grow at the entropy rate

Entropy counts *all* orbit segments; periodic orbits are a sparse subfamily. The classical theory says that for mixing subshifts of finite type the two growth rates agree. Here is the finite-graph proof.

**Lemma 9.1 (Upper bound).** For any Perron datum $(\lambda,v)$, every diagonal entry satisfies $(A^n)_{ii} \le \lambda^n$; hence $\operatorname{tr}(A^n) \le |V|\lambda^n$.

*Proof sketch.* From Lemma 7.1, $(A^n)_{ii}v_i \le \sum_j (A^n)_{ij}v_j = \lambda^n v_i$; divide by $v_i>0$ and sum over $i$. $\square$

**Lemma 9.2 (Lower bound via primitivity).** Suppose all entries of $A^m$ are $\ge 1$. Then for every $q$ and all $i,j,k$,
$$(A^q)_{jk} \;\le\; \bigl(A^{m+q+m}\bigr)_{ii},$$
and consequently
$$|P_q(E)| \;\le\; |V|^2\,\bigl|\mathrm{CW}_{q+2m}(E)\bigr| .$$

*Proof sketch.* Prefix a walk $i \to j$ of length $m$ and suffix a walk $k \to i$ of length $m$; the composite is a closed walk at $i$ of length $m+q+m$, and the association is injective on the middle segment. Summing $(A^q)_{jk}$ over the at most $|V|^2$ pairs $(j,k)$ gives the second inequality, using $\operatorname{tr}(A^{q+2m}) \ge (A^{q+2m})_{ii}$. $\square$

**Theorem 9.3 (Periodic Growth Theorem).** Let $E$ be primitive (hence dead-end-free) with Perron value $\lambda$. Then
$$\lim_{n\to\infty}\frac{\log|\mathrm{CW}_n(E)|}{n} \;=\; \log\lambda \;=\; h(E).$$

*Proof sketch.* Fix $m$ with $A^m \ge 1$ entrywise. The upper bound is Lemma 9.1: $|\mathrm{CW}_n| \le |V|\lambda^n$. For the lower bound, write $n = m+q+m$ with $q \ge 0$; Lemma 9.2 and the counting bound $|P_q| \ge (S/C)\lambda^q$ (Lemma 7.3) give
$$|\mathrm{CW}_n| \;\ge\; \frac{|P_q|}{|V|^2} \;\ge\; \frac{S/C}{|V|^2\lambda^{2m}}\;\lambda^{n} \;=\; a'\lambda^n$$
with $a' > 0$ independent of $n$. Taking logarithms and dividing by $n$ squeezes the sequence between $(\log a')/n + \log\lambda$ and $(\log|V|)/n + \log\lambda$, both tending to $\log\lambda$. $\square$

**Theorem 9.4 (Entropy is a conjugacy invariant).** If two primitive finite directed graphs are conjugate, their attractors have equal entropy.

*Proof sketch.* Conjugate systems have equal periodic-point counts (Theorem 5.3), hence equal sequences $|\mathrm{CW}_n|$ for $n\ge1$; by Theorem 9.3 both entropies are the common limit of $n^{-1}\log|\mathrm{CW}_n|$. $\square$

**Corollary 9.5 (Spectral rigidity).** Conjugate primitive attractors have the same Perron value, hence transfer matrices with a common dominant eigenvalue.

Together these close the loop: an analytic invariant (entropy) is computed by linear algebra, that linear algebra is pinned by an arithmetic constraint, and the whole package is invariant under topological conjugacy.

---

## 10. Chaos from primitivity

**Theorem 10.1 (Cylinder basis).** Every open subset $U \subseteq \Lambda_E$ and every $x \in U$ admit $m$ such that any orbit agreeing with $x$ on indices $0,\dots,m$ lies in $U$.

**Theorem 10.2 (Topological mixing).** If $E$ is primitive, then for all nonempty open $U, U' \subseteq \Lambda_E$ there is $N$ with $\sigma^n(U) \cap U' \ne \emptyset$ for all $n \ge N$.

*Proof sketch.* Shrink $U$ and $U'$ to cylinders around chosen points $x$ and $x'$, of depths $m$ and $m'$. Primitivity supplies, for all large $n$, a walk of length exactly $n - m$ from $x_m$ to $x'_0$. Concatenating $x_0 \dots x_m$, that walk, and $x'_0 \dots x'_{m'}$, then continuing arbitrarily, gives a point of $U$ whose $n$-th shift lies in $U'$. $\square$

**Theorem 10.3 (Dense periodic orbits).** If $E$ is primitive, the periodic points are dense in $\Lambda_E$.

*Proof sketch.* Given $x$ and depth $m$, primitivity gives a walk from $x_m$ back to $x_0$ of some length $\ell$; the concatenation $x_0\dots x_m$ followed by that walk is a closed walk, which extends periodically to a periodic orbit agreeing with $x$ up to index $m$. $\square$

**Theorem 10.4 (Converse).** A dead-end-free graph whose attractor is topologically mixing is primitive. Hence for dead-end-free graphs, *primitivity $\Leftrightarrow$ topological mixing*.

*Proof sketch.* Apply mixing to the (open, nonempty) start cylinders $\{x_0 = u\}$ and $\{x_0 = v\}$; a point of the first whose $n$-shift lies in the second is exactly a walk of length $n$ from $u$ to $v$. $\square$

**Theorem 10.5 (Sensitive dependence).** If $E$ is branching then for every $x$ and every neighbourhood $U$ of $x$ there is $y \in U$ and a time at which $y$ and $x$ occupy different vertices — orbits are never locally determined by finite observation.

**Corollary 10.6 (Devaney chaos).** A primitive branching symbolic attractor is chaotic in Devaney's sense: topologically transitive (indeed mixing), with dense periodic orbits and sensitive dependence on initial conditions. Both Lorenz templates qualify.

The remarkable feature is the hypothesis: an entirely finite, decidable condition on a $0/1$ matrix — some power is positive — implies all three clauses of the Devaney definition, *and* is the hypothesis of the Perron–Frobenius theorem. Chaoticity and spectral dominance are the same condition read twice.

---

## 11. The two templates, computed

**Lorenz template.** $A = \begin{pmatrix}1&1\\1&1\end{pmatrix}$, $\chi(t) = t^2 - 2t$.
- $|P_n| = 2^{n+1}$, $\operatorname{tr}(A^n) = 2^n$, recurrence $t_{k+2} = 2t_{k+1}$.
- Perron datum $(2, (1,1))$; hence $\lambda_{\mathrm{P}} = 2$, and by uniqueness $2$ is the *only* eigenvalue with a positive eigenvector.
- $h = \log 2$; $e^h = 2$, an algebraic integer (a rational one).
- $\Lambda \cong \{0,1\}^{\mathbb N}$; primitive; branching; Devaney chaotic.

**Pruned template.** $A = \begin{pmatrix}1&1\\1&0\end{pmatrix}$, $\chi(t) = t^2 - t - 1$.
- $|P_n|$ is a Fibonacci number, $\operatorname{tr}(A^n) = L_n$ the Lucas numbers, recurrence $t_{k+2} = t_{k+1} + t_k$.
- Perron datum $(\varphi, (\varphi, 1))$ with $\varphi = \tfrac{1+\sqrt5}{2}$, verified by $\varphi^2 = \varphi + 1$; hence $\lambda_{\mathrm{P}} = \varphi$.
- $h = \log\varphi$; $e^h = \varphi$, an algebraic integer of degree $2$ — an *irrational* entropy exponent arising from a two-vertex graph.
- Primitive (since $A^2 = \begin{pmatrix}2&1\\1&1\end{pmatrix} > 0$), hence mixing with dense periodic orbits.

**Separation.** $\varphi < 2$, so $h(E_{\mathrm{pr}}) < h(E_{\mathrm{Lor}})$; independently, $\operatorname{tr}(A_{\mathrm{Lor}}^2) = 4 \ne 3 = \operatorname{tr}(A_{\mathrm{pr}}^2)$. Two different invariants — one analytic, one combinatorial — give the same conclusion: the attractors are not topologically conjugate. Deleting a single edge from a two-vertex graph changes the entropy from $\log 2 \approx 0.6931$ to $\log\varphi \approx 0.4812$, and turns a rational entropy exponent into a quadratic irrational.

---

## 12. Algorithms

All invariants above are computable from the adjacency matrix alone.

**A. Path and closed-walk counting.** Compute $A^n$ by repeated squaring in $O(|V|^\omega \log n)$ ring operations; then $|P_n| = \sum_{i,j}(A^n)_{ij}$ and $|\mathrm{Per}_n| = \operatorname{tr}(A^n)$. Entries grow like $\lambda^n$, so exact integer arithmetic costs an extra factor linear in $n$.

**B. Characteristic polynomial and recurrence extraction.** Faddeev–LeVerrier computes $\chi_A \in \mathbb{Z}[t]$ in $O(|V|^{4})$ operations (or $O(|V|^{\omega+1})$ with fast multiplication) using the recursion $M_0 = I$, $c_{d-k} = -\frac{1}{k}\operatorname{tr}(AM_{k-1})$, $M_k = AM_{k-1} + c_{d-k}I$. The coefficients are exactly the recurrence for $\operatorname{tr}(A^n)$ (Theorem 5.4), giving an $O(|V|)$-per-step method of extending the orbit-count sequence indefinitely — exponentially faster than matrix powering for long sequences.

**C. Perron value by power iteration / Collatz–Wielandt.** For primitive $A$, the iteration $x \leftarrow Ax/\|Ax\|_1$ converges geometrically to the positive eigenvector, with $\lambda \approx \|Ax\|_1$ (Rayleigh-type estimate); the convergence rate is the ratio of the second-largest to largest eigenvalue modulus. Simultaneously the *two-sided* Collatz–Wielandt bracket
$$\min_i \frac{(Ax)_i}{x_i} \;\le\; \lambda \;\le\; \max_i \frac{(Ax)_i}{x_i}$$
gives certified enclosures at every step for any strictly positive $x$ — a rigorous, cheap error bar on the entropy, since $h = \log\lambda$.

**D. Primitivity testing.** By Lemma 8.1, test positivity of $A^n$ for $n$ up to the Wielandt bound $|V|^2 - 2|V| + 2$; boolean matrix powering makes this $O(|V|^{3}\log |V|)$ in practice.

**E. Certified entropy.** Combining B and C: compute $\chi_A$, isolate its largest real root by Sturm sequences or interval Newton to any desired precision, and output $h = \log\lambda$ with a rigorous enclosure. The output is a *number-theoretic* object — the minimal polynomial of $e^h$ — not merely a floating-point estimate.

---

## 13. Applications and interpretation

**Certified invariants for chaotic flows.** Where a template (or a Markov partition) is available, entropy stops being an estimated quantity and becomes an algebraic one: the largest root of an explicit integer polynomial. Statements such as "the entropy of this attractor is exactly $\log\varphi$" become theorems, and questions such as "can this system have entropy $\log \pi$?" acquire a negative answer within the class.

**Distinguishing attractors.** Comparing two systems reduces to comparing finite data: characteristic polynomials, low-order trace sequences, or Perron values. A single trace comparison ($4$ versus $3$) suffices for the two Lorenz templates. This is the sharpest possible contrast with numerical discrimination, which must contend with error bars.

**Bifurcation as arithmetic.** In a family of templates, a parameter change that prunes an edge changes the characteristic polynomial and thus jumps the Perron value along the algebraic integers. Entropy plateaus and jumps in Lorenz-like families are, in this framework, transitions between roots of nearby integer polynomials. The observation that entropy of such families is constrained to a countable arithmetically structured set is a direct corollary of Theorem 7.8.

**Symbolic complexity and coding.** Since $|P_n| \asymp \lambda^n$, the number of distinguishable histories of length $n$ is determined to within a constant factor by $\lambda$. In coding terms $\log_2 \lambda$ is the capacity of the constrained channel defined by the graph — the Lorenz template being the unconstrained binary channel (capacity $1$ bit/symbol) and the pruned template the "no two consecutive $\mathsf{R}$" constraint (capacity $\log_2 \varphi \approx 0.694$ bits/symbol, the classical Fibonacci-run-length constraint).

**A dynamical proof in Perron–Frobenius theory.** Theorem 7.5 deserves separate mention: uniqueness of the positive eigenvalue, normally a consequence of irreducibility arguments, here follows because both candidate eigenvalues compute the same entropy. This is a structurally different proof, and it applies verbatim to any nonnegative *integral* matrix arising as a transfer matrix.

---

## 14. Discussion

Three features of the theory deserve emphasis.

*First, no hypotheses in the structure theorem.* The identification $\Lambda_E \cong \varprojlim P_n(E)$ needs nothing. Dead-end-freeness is needed only to make the tower nondegenerate and the entropy finite and nonnegative; primitivity only enters when one wants mixing, existence of Perron data, or the periodic growth rate.

*Second, the squeeze is the whole proof.* The Spectral Entropy Theorem might be expected to require the full strength of Perron–Frobenius, spectral gaps, or renewal theory. It requires only the observation that a positive eigenvector has a positive minimum and a finite maximum, and that constants die when divided by $n$. This is why the theorem holds for *any* Perron datum without irreducibility, and why the uniqueness corollary comes for free.

*Third, arithmetic constrains dynamics.* The step from "the entropy exists" to "$e^h$ is an algebraic integer" costs one line once the spectral form is available, but its content is substantial: a dynamical invariant is confined to a countable, arithmetically structured set. In the symbolic category this makes entropy an object of algebraic number theory. (The classical Lind theorem characterises the possible entropies of subshifts of finite type as logarithms of *Perron numbers*; the results here derive the algebraic-integrality half of that constraint directly from the inverse-limit picture and give, for each fixed graph, the explicit monic polynomial in question.)

**Limitations.** The theory is a theory of *symbolic* attractors. Reducing an actual smooth attractor to a finite graph requires a template or Markov partition — for the geometric Lorenz flow this is classical, but it is a hypothesis, not a theorem proved here. The invariants computed are those of the symbolic model: entropy, orbit counts, conjugacy class of the shift. Measure-theoretic invariants, dimension spectra, and the transverse Cantor structure's metric geometry lie outside the scope. Finally, "conjugacy" here means topological conjugacy of the shifts, coarser than flow equivalence with the original geometry.

---

## 15. Future directions

**Zeta functions in full.** The Cayley–Hamilton recurrence is the shadow of rationality of the Artin–Mazur zeta function $\zeta(t) = \exp\bigl(\sum_{n\ge1} |\mathrm{Per}_n| t^n/n\bigr) = 1/\det(I - tA)$. Proving the determinant formula directly, and then the functional equation for reversible templates, would complete the analytic picture. For the Lorenz template this yields $\zeta(t) = 1/(1-2t)$ and for the pruned one $\zeta(t) = 1/(1 - t - t^2)$.

**Non-primitive and reducible graphs.** The theory of irreducible components, the Frobenius period, and cyclic decompositions should give entropy as a maximum over the components' Perron values, with a corresponding decomposition of the attractor into basic sets — the symbolic analogue of the spectral decomposition of an Axiom A basic set.

**The realisation problem.** Which algebraic integers occur? Lind's theorem says exactly the Perron numbers. Reproving that characterisation within this framework — constructing, for each Perron number, a graph realising it — would turn the arithmetic constraint into an exact classification.

**Beyond one dimension.** Higher-dimensional shifts of finite type (graphs replaced by Wang tilings) lose most of the theory: entropy is no longer the logarithm of an algebraic number but any right-recursively-enumerable number. Identifying which parts of the inverse-limit machinery survive is a natural frontier.

**Templates for other attractors.** The Hénon and Rössler systems admit template descriptions in parameter regimes where they are hyperbolic. Instantiating the theory at their return graphs would produce certified entropies and algebraic separations for those families as well, and would allow comparing attractors across families by matching characteristic polynomials.

**Quantitative Perron bounds.** The counting bounds involve the eigenvector spread $C/c$. Making that spread explicit in terms of the graph (via Hilbert projective-metric contraction rates) would convert the qualitative limit $|P_n| \asymp \lambda^n$ into effective two-sided estimates with computable constants, and would give error bars on truncated entropy computations.

---

## 16. Conclusion

A chaotic attractor, presented through its symbolic dynamics, is not merely amenable to algebra — it *is* an algebraic object. It is the inverse limit of a tower of finite path sets under edge deletion, a Cantor set on which the shift acts. Its periodic orbits are the diagonal of the powers of a $0/1$ matrix and satisfy an integer linear recurrence read off from a characteristic polynomial. Its topological entropy, defined analytically as a growth rate, equals the logarithm of the unique positive eigenvalue of that matrix; the eigenvalue exists whenever the graph is primitive, is the spectral radius, has a one-dimensional eigenspace, exceeds $1$, and is an algebraic integer. Periodic orbits grow at exactly the entropy rate, so the entropy is a conjugacy invariant. And chaos in Devaney's sense is implied by a single finite condition — positivity of a power of the matrix — which is precisely the hypothesis of Perron–Frobenius.

Two attractors differing by one forbidden transition are separated by the inequality $4 \ne 3$, and by the gap between $\log 2$ and $\log\varphi$. That is what it means to treat a strange attractor as an algebraic object.
