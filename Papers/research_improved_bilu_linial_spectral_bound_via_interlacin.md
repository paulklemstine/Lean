# A Constructive Witness for Bilu–Linial Spectral Suppression: The Unbalanced 4-Cycle Attains Spectral Radius $\sqrt{2}$

## Abstract

For a graph $G$ with maximum degree $d$, the Bilu–Linial program asserts the existence of a signing $\sigma$ of its edges — an assignment of $\pm 1$ to each edge — such that the spectral radius of the resulting signed adjacency matrix is at most $2\sqrt{3(d-1)}$, far below the trivial upper bound $d$ obtained from the degree alone. The standard proof is probabilistic: it bounds the average, over all signings, of an even spectral moment, and infers the existence of a good signing without exhibiting one. In this paper we present the smallest fully explicit witness that signing genuinely suppresses the spectral radius. We study the *unbalanced 4-cycle*: the cycle $C_4$ on vertices $\{0,1,2,3\}$ with edges signed $+,+,+,-$ so that the product of signs around the cycle is $-1$. We prove by direct computation that its signed adjacency matrix $B$ satisfies $B^2 = 2I$, from which it follows that every eigenvalue $\mu$ has $\mu^2 = 2$ and hence $|\mu| = \sqrt{2}$. Since the graph is $2$-regular, the trivial degree bound only gives $|\mu| \le 2$, whereas the exact spectral radius is $\sqrt{2} < 2$ — a strict, deterministic improvement. We frame this example within the general theory, isolate the combinatorial heart of the Bilu–Linial bound (the growth rate of even closed walks), and discuss the path from the constant $3(d-1)$ toward the conjecturally optimal Ramanujan constant $d-1$.

**Keywords:** signed graph, signed adjacency matrix, spectral radius, Bilu–Linial theorem, unbalanced cycle, interlacing families, Ramanujan graph, spectral moments.

---

## 1. Introduction

### 1.1 Spectra of graphs and the resonance ceiling

Let $G = (V, E)$ be a finite simple graph on $n$ vertices. Its *adjacency matrix* $A \in \mathbb{R}^{n \times n}$ has $A_{ij} = 1$ if $\{i,j\} \in E$ and $A_{ij} = 0$ otherwise. Because $A$ is real symmetric, all of its eigenvalues are real; we write $\lambda_1 \ge \lambda_2 \ge \cdots \ge \lambda_n$, and call
$$\rho(A) = \max_i |\lambda_i|$$
the *spectral radius* of $G$. The spectral radius controls a great deal of a graph's global behavior — mixing rate, expansion, connectivity — and small spectral radius (relative to degree) is the hallmark of an *expander*, the class of sparse, highly connected graphs at the center of theoretical computer science and combinatorics.

If every vertex has degree at most $d$, a standard argument (Perron–Frobenius, or bounding absolute row sums) gives
$$\rho(A) \le d,$$
with equality when $G$ is $d$-regular. For a $d$-regular graph, then, the spectral radius sits exactly at its ceiling $d$. The Alon–Boppana theorem shows that one cannot do better than $2\sqrt{d-1} - o(1)$ for the *second* eigenvalue of an infinite family of $d$-regular graphs; graphs meeting this bound, with $\max(\lambda_2, |\lambda_n|) \le 2\sqrt{d-1}$, are the celebrated *Ramanujan graphs*.

### 1.2 Signings and the Bilu–Linial theorem

A **signing** of $G$ is a function $\sigma : E \to \{+1, -1\}$. The associated **signed adjacency matrix** $A_\sigma \in \mathbb{R}^{n \times n}$ is
$$
(A_\sigma)_{ij} =
\begin{cases}
\sigma(\{i,j\}) & \text{if } \{i,j\} \in E,\\
0 & \text{otherwise.}
\end{cases}
$$
Like $A$, the matrix $A_\sigma$ is real symmetric, so its eigenvalues are real and its spectral radius $\rho(A_\sigma)$ is well defined. Signing never increases the support of the matrix; it can only introduce cancellation among walks.

Bilu and Linial proved the following landmark existence result, the engine behind their iterative construction of near-Ramanujan expanders.

> **Theorem (Bilu–Linial).** Every graph $G$ with maximum degree $d$ admits a signing $\sigma$ with
> $$\rho(A_\sigma) \le 2\sqrt{3(d-1)}\,\big(1 + o(1)\big).$$

The bound is remarkable: it replaces the degree ceiling $d$ with a quantity of order $\sqrt{d}$. The proof is via the *method of spectral moments*. For even $2k$,
$$\operatorname{tr}(A_\sigma^{2k}) = \sum_{i} \lambda_i(A_\sigma)^{2k} \ge \rho(A_\sigma)^{2k},$$
so an upper bound on the trace bounds the spectral radius. Averaging the trace over all $2^{|E|}$ signings — equivalently, over independent uniform $\pm 1$ signs — one finds
$$\mathbb{E}_\sigma \big[ \operatorname{tr}(A_\sigma^{2k}) \big] = \sum_{\text{closed walks } W \text{ of length } 2k} \mathbb{E}_\sigma\!\Big[\textstyle\prod_{e \in W} \sigma(e)^{m_e(W)}\Big],$$
where $m_e(W)$ is the number of times $W$ traverses edge $e$. Independence and $\mathbb{E}[\sigma(e)] = 0$ kill every term in which some edge is used an *odd* number of times; only **even closed walks** — those with all $m_e(W)$ even — survive. The number of such walks grows like $\big(3(d-1)\big)^k$ per vertex, which yields the constant $3(d-1)$ inside the square root. Finally, since the average of $\operatorname{tr}(A_\sigma^{2k})$ is bounded, *some* signing achieves at most the average — an existence conclusion.

### 1.3 The gap this paper addresses

The Bilu–Linial argument is nonconstructive at its core: it certifies that a good signing exists but does not exhibit one, and its guarantee is a statement about averages and asymptotics. It is natural to ask for a *concrete, exact* witness — a specific graph and a specific signing for which one can compute the spectral radius on the nose and observe it drop below the degree ceiling. Such a witness makes the abstract mechanism tangible: it shows cancellation of closed walks happening deterministically rather than merely on average.

We provide the minimal such witness.

**Main result (informal).** *The 4-cycle, signed so that the product of its edge signs is $-1$, has signed adjacency matrix $B$ with $B^2 = 2I$; consequently every eigenvalue $\mu$ satisfies $|\mu| = \sqrt{2}$, and the spectral radius $\sqrt{2}$ is strictly below the degree bound $2$.*

The value of this example is pedagogical and structural. It exhibits, in the smallest possible setting, the two ideas that drive the whole theory — (i) the balance/unbalance dichotomy of signed cycles and (ii) the cancellation of closed walks — while being verifiable by an entirely elementary matrix computation.

---

## 2. Definitions

Throughout, matrices act on $\mathbb{R}^n$ and $I$ denotes the identity matrix of the appropriate size.

**Definition 2.1 (Signed adjacency matrix).** Given a graph $G = (V,E)$ and a signing $\sigma : E \to \{+1,-1\}$, the signed adjacency matrix $A_\sigma$ is the symmetric $|V| \times |V|$ matrix with $(A_\sigma)_{ij} = \sigma(\{i,j\})$ when $\{i,j\} \in E$ and $0$ otherwise. In particular the diagonal is zero (no loops).

**Definition 2.2 (Spectral radius).** For a symmetric matrix $M$, $\rho(M) = \max\{ |\mu| : \mu \text{ an eigenvalue of } M\}$. Equivalently, $\mu$ is an eigenvalue if $Mv = \mu v$ for some $v \ne 0$.

**Definition 2.3 (Balance of a cycle).** A cycle $C$ with edges $e_1, \dots, e_\ell$ is *balanced* under $\sigma$ if $\prod_{i=1}^{\ell} \sigma(e_i) = +1$ and *unbalanced* if the product is $-1$. Balance is a switching invariant: replacing $\sigma$ by $v \mapsto \varepsilon(v)\,\sigma\,\varepsilon(\cdot)$ for any vertex flip $\varepsilon : V \to \{\pm 1\}$ (a *switching*) leaves every cycle's sign product unchanged. A signed graph whose every cycle is balanced is switching-equivalent to the all-$+$ signing and shares its spectrum; an unbalanced cycle can never be switched to all-$+$.

**Definition 2.4 (Degree and the trivial bound).** The degree of vertex $i$ in the (signed) graph is $\deg(i) = \sum_j |(A_\sigma)_{ij}|$, the number of incident edges. The maximum degree is $\Delta = \max_i \deg(i)$.

**Lemma 2.5 (Trivial spectral bound).** For any signing $\sigma$ and any eigenvalue $\mu$ of $A_\sigma$, $|\mu| \le \Delta$.

*Proof sketch.* Let $A_\sigma v = \mu v$ with $v \ne 0$, and choose a coordinate $i$ maximizing $|v_i|$. Reading off row $i$ of the eigenvalue equation, $\mu v_i = \sum_j (A_\sigma)_{ij} v_j$, so
$$|\mu|\,|v_i| \le \sum_j |(A_\sigma)_{ij}|\,|v_j| \le |v_i| \sum_j |(A_\sigma)_{ij}| = |v_i|\,\deg(i) \le |v_i|\,\Delta.$$
Dividing by $|v_i| > 0$ gives $|\mu| \le \Delta$. $\qquad\blacksquare$

This is the bound that signing aims to beat.

---

## 3. The Unbalanced 4-Cycle

Fix the vertex set $\{0,1,2,3\}$ and the cycle edges $\{0,1\}, \{1,2\}, \{2,3\}, \{3,0\}$. Assign signs
$$\sigma(\{0,1\}) = +1,\quad \sigma(\{1,2\}) = +1,\quad \sigma(\{2,3\}) = +1,\quad \sigma(\{3,0\}) = -1.$$

**Definition 3.1.** The signed adjacency matrix of this signing is
$$
B \;=\;
\begin{pmatrix}
0 & 1 & 0 & -1\\
1 & 0 & 1 & 0\\
0 & 1 & 0 & 1\\
-1 & 0 & 1 & 0
\end{pmatrix}.
$$

We record its basic structural properties.

**Proposition 3.2 (Well-formed signing).**
1. $B$ is symmetric: $B^{\mathsf T} = B$.
2. Every entry lies in $\{-1, 0, +1\}$.
3. The diagonal is zero: $B_{ii} = 0$ for all $i$ (no loops).

*Proof.* Immediate from inspection of the four rows. $\qquad\blacksquare$

**Proposition 3.3 (Unbalanced).** The product of the four edge signs around the cycle is
$$B_{01}\,B_{12}\,B_{23}\,B_{30} = (+1)(+1)(+1)(-1) = -1.$$
Hence the cycle is unbalanced; no switching can remove all of its minus signs.

### 3.1 The key computation

**Theorem 3.4 (Squaring identity).** $B^2 = 2I$.

*Proof.* We compute $(B^2)_{ij} = \sum_{k=0}^{3} B_{ik} B_{kj}$ directly.

*Diagonal.* For each $i$, $(B^2)_{ii} = \sum_k B_{ik}^2$ equals the number of neighbors of $i$ (each incident $\pm 1$ squares to $1$). Every vertex of $C_4$ has two neighbors, so $(B^2)_{ii} = 2$.

*Off-diagonal.* Take $i \ne j$. The entry $(B^2)_{ij}$ is a signed count of length-2 walks $i \to k \to j$. In $C_4$, two vertices at distance $2$ (namely $\{0,2\}$ and $\{1,3\}$) are joined by exactly two such walks, one through each common neighbor; adjacent vertices are joined by none, and there is no other case. For the diagonal pair $\{0,2\}$: the walks $0 \to 1 \to 2$ and $0 \to 3 \to 2$ contribute $B_{01}B_{12} = (+1)(+1) = +1$ and $B_{03}B_{32} = (-1)(+1) = -1$, summing to $0$. For $\{1,3\}$: the walks $1 \to 0 \to 3$ and $1 \to 2 \to 3$ contribute $B_{10}B_{03} = (+1)(-1) = -1$ and $B_{12}B_{23} = (+1)(+1) = +1$, again summing to $0$. All other off-diagonal entries vanish because the vertices are adjacent (distance $1$) and have no common neighbor in $C_4$. Hence $(B^2)_{ij} = 0$ for $i \ne j$.

Therefore $B^2 = 2I$. $\qquad\blacksquare$

The single negative edge is exactly what forces the two length-2 walks between opposite vertices to enter with opposite signs and cancel. This is the Bilu–Linial cancellation mechanism, made explicit and exact in the smallest case.

### 3.2 Consequences for the spectrum

**Theorem 3.5 (Eigenvalues squared).** If $Bv = \mu v$ for some $v \ne 0$, then $\mu^2 = 2$.

*Proof.* Apply $B$ twice: on one hand $B(Bv) = B(\mu v) = \mu (Bv) = \mu^2 v$; on the other hand $B(Bv) = B^2 v = 2Iv = 2v$ by Theorem 3.4. Subtracting, $(\mu^2 - 2)v = 0$. Choosing a coordinate $i$ with $v_i \ne 0$ and reading off that coordinate gives $(\mu^2 - 2)v_i = 0$, so $\mu^2 - 2 = 0$. $\qquad\blacksquare$

**Theorem 3.6 (Exact spectral radius).** Every eigenvalue $\mu$ of $B$ (with a nonzero eigenvector) satisfies
$$|\mu| = \sqrt{2}.$$
In particular $\rho(B) = \sqrt{2}$.

*Proof.* From $\mu^2 = 2$ (Theorem 3.5) we get $|\mu| = \sqrt{\mu^2} = \sqrt{2}$. $\qquad\blacksquare$

*(For completeness, one can verify all four eigenvalues explicitly: since $B$ is symmetric with $B^2 = 2I$, its minimal polynomial divides $x^2 - 2$, and as $B \ne \pm\sqrt2\, I$ both values occur; the spectrum is $\{\sqrt 2, \sqrt 2, -\sqrt 2, -\sqrt 2\}$.)*

### 3.3 Explicit eigenvectors and multiplicities

Because $B^2 = 2I$, the space $\mathbb{R}^4$ splits orthogonally into the $+\sqrt2$ and $-\sqrt2$ eigenspaces of $B$: writing $P_\pm = \tfrac12\big(I \pm \tfrac{1}{\sqrt2}B\big)$, one checks $P_+ + P_- = I$, $P_\pm^2 = P_\pm$, and $B P_\pm = \pm\sqrt2\, P_\pm$. Since $\operatorname{tr}(B) = 0$, the two eigenvalues occur with equal multiplicity, so each eigenspace is two-dimensional and the spectrum is exactly $\{+\sqrt2, +\sqrt2, -\sqrt2, -\sqrt2\}$.

Concretely, a direct substitution confirms that
$$v_+ = (1,\ \sqrt2,\ 1,\ 0)^{\mathsf T} \quad\text{satisfies}\quad Bv_+ = \sqrt2\, v_+,$$
since row by row $Bv_+ = (\sqrt2,\ 2,\ \sqrt2,\ 0)^{\mathsf T} = \sqrt2\,(1,\sqrt2,1,0)^{\mathsf T}$. Likewise
$$v_- = (1,\ -\sqrt2,\ 1,\ 0)^{\mathsf T} \quad\text{satisfies}\quad Bv_- = -\sqrt2\, v_-.$$
A second independent eigenvector in each eigenspace is obtained by exploiting the symmetry of the configuration; for instance $(1,\ 0,\ -1,\ -\sqrt2)^{\mathsf T}$ and $(1,\ 0,\ -1,\ \sqrt2)^{\mathsf T}$ complete the $+\sqrt2$ and $-\sqrt2$ eigenspaces respectively. Every one of these vectors is nonzero, so Theorem 3.6 applies to each and its eigenvalue has modulus exactly $\sqrt2$.

### 3.4 Strict improvement over the degree bound

**Proposition 3.7 (Degrees).** Every vertex has degree $2$: $\sum_j |B_{ij}| = 2$ for each $i$. Hence $\Delta = 2$.

**Corollary 3.8 (Degree bound is loose).** By Lemma 2.5, every eigenvalue of $B$ satisfies $|\mu| \le \Delta = 2$.

**Lemma 3.9.** $\sqrt{2} < 2$.

*Proof.* Both sides are nonnegative and $(\sqrt 2)^2 = 2 < 4 = 2^2$; squaring is monotone on nonnegatives. $\qquad\blacksquare$

**Theorem 3.10 (Strict, deterministic improvement).** For the unbalanced 4-cycle,
$$\rho(B) = \sqrt{2} \;<\; 2 = \Delta.$$
The actual spectral radius is strictly below the trivial maximum-degree bound. This improvement is exhibited by a single explicit signing, with no averaging, probability, or asymptotics.

*Proof.* Combine Theorem 3.6 (value $\sqrt2$), Corollary 3.8 (bound $\le 2$), and Lemma 3.9 ($\sqrt 2 < 2$). $\qquad\blacksquare$

For contrast, the *unsigned* 4-cycle (all edges $+1$) has spectrum $\{2, 0, 0, -2\}$ and spectral radius exactly $2$: it saturates the degree ceiling. The single sign flip that unbalances the cycle drops the resonance from $2$ to $\sqrt 2$, a reduction of about $29\%$.

---

## 4. Discussion: the general bound and its combinatorial heart

The 4-cycle is the atom of a much larger story. We sketch how it fits.

**The moment method and even walks.** As in §1.2, for even $2k$,
$$\rho(A_\sigma)^{2k} \le \operatorname{tr}(A_\sigma^{2k}) = \sum_{W} \prod_{e} \sigma(e)^{m_e(W)},$$
the sum ranging over closed walks $W$ of length $2k$. Averaging over uniform independent signs annihilates every walk with some odd $m_e(W)$, leaving only *even closed walks*. Thus
$$\mathbb{E}_\sigma\big[\operatorname{tr}(A_\sigma^{2k})\big] = \#\{\text{even closed walks of length } 2k\}.$$
The Bilu–Linial estimate is that this count is at most $n \cdot \big(3(d-1)\big)^k (1+o(1))$, whence some signing achieves $\rho(A_\sigma) \le 2\sqrt{3(d-1)}$ up to lower-order terms. The 4-cycle displays the mechanism concretely: in $B^2$, the odd walks between opposite vertices cancel, leaving only the even (backtracking) contributions on the diagonal.

**Averaging versus construction.** The averaging step is elementary and, in its modern form, fully unconditional: the best member of a family of signings always beats the family's *average* even moment. What remains — and where all the difficulty lives — is the purely combinatorial estimate on how fast even closed walks grow. The unbalanced 4-cycle is a case where we bypass averaging entirely and construct the good signing outright by unbalancing a cycle.

**A remark on switching.** One might worry that the improvement is an artifact of a poor choice of coordinates that a relabeling could undo. It cannot. Switching a signing by a vertex flip $\varepsilon : V \to \{\pm1\}$ conjugates $A_\sigma$ by the diagonal orthogonal matrix $\operatorname{diag}(\varepsilon)$, which preserves the entire spectrum, and it preserves the sign product of every cycle. Since the 4-cycle's sign product is $-1$, no switching can turn $B$ into the unsigned adjacency matrix (whose cycle product is $+1$). The two matrices are genuinely spectrally distinct: $\{\pm\sqrt2\}$ versus $\{\pm2, 0\}$. The suppression is intrinsic to the unbalanced class.

**Toward the Ramanujan constant.** The factor $3$ in $3(d-1)$ is the fingerprint of *backtracking* walks — steps that immediately retrace themselves. Passing to *non-backtracking* closed walks, counted by the non-backtracking (Hashimoto) operator, is expected to remove this excess and lower the constant to $d-1$, yielding the conjecturally optimal signed bound
$$\rho(A_\sigma) \le 2\sqrt{d-1},$$
the Ramanujan floor. This is precisely the regime in which the interlacing-families technique of Marcus, Spielman, and Srivastava established the existence of bipartite Ramanujan graphs of every degree. The unbalanced cycle is the deterministic seed of that program: it shows that unbalancing a cycle forces the shortest closed walks to cancel, reproducing by construction the cancellation the probabilistic method achieves only on average.

---

## 5. Algorithms

We describe two explicit procedures suggested by the theory.

**Algorithm A (Verify the squaring identity and read off the spectrum).** Given the $4\times4$ matrix $B$, compute $B^2$ and check equality with $2I$; conclude $\rho(B) = \sqrt2$. This is an $O(1)$ certificate of Theorem 3.10.

**Algorithm B (Balance test and cycle unbalancing).** Given a signed graph, determine whether a cycle is balanced by multiplying its edge signs; to *construct* an improving signing on a graph containing a short cycle, flip exactly one edge of that cycle to make its sign-product $-1$. The balance test runs in $O(\ell)$ for a cycle of length $\ell$; locating a short cycle and unbalancing it is linear in the graph size once the cycle is known.

Full type-hinted implementations accompany this paper.

---

## 6. Applications

- **Expander construction.** Signed adjacency matrices with small spectral radius are the building blocks of iterative expander constructions (via graph lifts / $2$-lifts): a good signing of a base graph yields a larger graph with controlled second eigenvalue.
- **Error-correcting codes.** Expander graphs underlie fast-decodable expander codes; smaller spectral radius directly improves their parameters.
- **Physics and social networks.** Signed adjacency matrices model frustrated spin systems and networks with antagonistic ties; unbalance is exactly frustration, and spectral suppression measures how frustration damps collective modes.

---

## 7. Future Directions

1. **The even-walk constant is exactly $3(d-1)$.** For every graph of maximum degree $d$, the average over signings of the $2k$-th spectral moment grows like $(3(d-1))^k$ per vertex, a rate achieved by trees near a high-degree vertex. Averaging annihilates odd-crossing walks, leaving even closed walks whose growth is set by the branching factor $3(d-1)$ rather than the naive $d^2$. With the averaging half settled, the entire $2\sqrt{3(d-1)}$ bound reduces to this single walk-counting statement.

2. **Unbalance as the deterministic route to sub-degree spectra.** Every non-bipartite graph should admit an explicit signing — obtained by unbalancing a suitable odd cycle — whose spectral radius is strictly below the maximum degree, with the improvement controlled by the girth. An unbalanced cycle forces the shortest closed walks to cancel, reproducing deterministically the average-case cancellation of the probabilistic method. The 4-cycle ($\sqrt 2$ versus $2$) is the concrete witness.

3. **Non-backtracking moments reach the Ramanujan constant.** Replacing ordinary closed walks by non-backtracking ones in the moment method should lower the constant from $3(d-1)$ to the optimal $d-1$, giving a signing with $\rho(A_\sigma) \le 2\sqrt{d-1}$ for every $d$-regular graph; the backtracking steps are exactly the source of the excess factor $3$.

4. **Signings compose under graph lifts.** If a base graph has a signing with spectral radius $r$, then every $2$-lift should admit a signing with spectral radius at most $r$, and iterating produces an infinite family with a uniform spectral bound.

---

## 8. Conclusion

The unbalanced 4-cycle is the smallest fully explicit demonstration that signing a graph's edges can push its spectral radius below the degree ceiling. Its signed adjacency matrix squares to $2I$, pinning every eigenvalue to $\pm\sqrt2$ and the spectral radius to exactly $\sqrt2 < 2$. Behind this one-line computation lies the entire Bilu–Linial philosophy: a well-placed minus sign makes the shortest closed walks cancel. Reading the general theory through this lens isolates its combinatorial core — the growth rate of even closed walks — and points, via non-backtracking refinements, toward the optimal Ramanujan constant $2\sqrt{d-1}$.
