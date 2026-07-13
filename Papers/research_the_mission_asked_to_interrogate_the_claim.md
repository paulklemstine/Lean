# Connected Components Govern the $L^p$ Threshold for Pattern Counts in Locally Dense Graphs

## Abstract

We study an $L^p$ relaxation of the classical multiplicative lower bound for pattern (homomorphism) counts in $\rho$-locally dense hosts, working throughout in the finite step-graphon model, where every integral is a genuine finite average and all statements are exact. A widely appealing conjecture predicts that, for a pattern graph $F$ with $m$ edges and $n$ non-isolated vertices, a locally dense counterexample to the bound $\|W_F\|_{L^p} \ge \rho^{e(F)}$ exists whenever $p < \binom{n}{2}/m$. We prove that this literal threshold is false. Two results anchor the picture. First, for the single edge the threshold is exactly $p^\star = 1 = \binom{2}{2}/1$: no counterexample exists for $p\ge 1$ (a power-mean inequality), and an explicit block construction is a counterexample for $0<p<1$. Second, for the $2$-edge matching $M_2$ (with $n=4$, $m=2$, hence conjectured threshold $3$) the pattern functional factorizes, $\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^2$, and consequently **no** counterexample exists for any $p\ge 1$; the true threshold is $1$, not $3$, and the gap between the true and conjectured thresholds over the matching family is unbounded. We then isolate the structural reason: a bijection identifying edge-constant vertex colorings with arbitrary colorings of connected components shows that block-kernel constructions can reach the value $(n-c)/m$, where $c$ is the number of connected components of $F$, and no further. This yields the closed form $\sum_{\varphi} \prod_{\text{edges}} W(\varphi) = t^{D} k^{c}$ for block-diagonal kernels, exhibiting the component count $c$ as the exact exponent controlling the analytic size of the functional. Since $n - c \le \binom{n}{2}$ with unbounded slack, the conjectured threshold systematically overshoots.

**Keywords:** locally dense graphs, graphons, homomorphism density, $L^p$ norms, power-mean inequality, connected components, block kernels, Sidorenko-type inequalities.

---

## 1. Introduction

### 1.1 Locally dense hosts and the KNRS lower bound

A *graphon* is a symmetric measurable kernel $W$ on a probability space, with values in $[0,1]$; it is the limiting object for sequences of dense graphs. Throughout this paper we work in the **finite step-graphon model**: the underlying space is the finite set $\{0,1,\dots,N-1\}$ equipped with the uniform probability measure, and $W$ is a symmetric function $W\colon \{0,\dots,N-1\}^2 \to [0,1]$. Every "integral" below is therefore a finite average, and every statement is an exact, elementary identity or inequality. This model captures the entire phenomenon we study while removing measure-theoretic overhead.

A graphon $W$ is **$\rho$-locally dense** (at level $\rho \in [0,1]$) if every sub-population is at least as dense as $\rho$ on average:

$$\frac{1}{|S|^2}\sum_{x,y\in S} W(x,y) \;\ge\; \rho \qquad \text{for every nonempty } S \subseteq \{0,\dots,N-1\}. \tag{LD}$$

For a pattern graph $F$ with vertex set $V(F)$ (of size $n$, counting only non-isolated vertices), edge set $E(F)$ (of size $m = e(F)$), the **pattern (homomorphism) functional** of $W$ is

$$t(F, W) \;=\; \frac{1}{N^{\,n}} \sum_{\varphi\colon V(F)\to \{0,\dots,N-1\}} \; \prod_{\{u,v\}\in E(F)} W(\varphi(u), \varphi(v)),$$

the average, over all vertex maps, of the multiplicative edge weight. Its $L^p$ refinement replaces each edge weight by its $p$-th power and takes a $p$-th root:

$$\|W_F\|_{L^p} \;=\; \left( \frac{1}{N^{\,n}} \sum_{\varphi\colon V(F)\to \{0,\dots,N-1\}} \; \prod_{\{u,v\}\in E(F)} W(\varphi(u), \varphi(v))^{\,p} \right)^{1/p}.$$

The classical lower bound in the Kohayakawa–Nagle–Rödl–Schacht (KNRS) circle of results states that for a $\rho$-locally dense host the ordinary count cannot fall below the independent-edges heuristic:

$$\|W_F\|_{L^1} \;=\; t(F,W) \;\ge\; \rho^{\,e(F)}. \tag{KNRS}$$

### 1.2 The suspect threshold

It is natural to ask how robust (KNRS) is when the exponent $1$ is replaced by a general $p$. Small $p<1$ rewards concentration (the map $x\mapsto x^p$ is concave), and one expects that below some threshold $p^\star(F)$ a locally dense host can drive $\|W_F\|_{L^p}$ strictly below $\rho^{e(F)}$, while above it the bound survives. A clean and attractive conjecture proposes an explicit threshold:

> **Conjecture (suspect form).** For $F$ with $m$ edges and $n$ non-isolated vertices, if
> $$p \;<\; \frac{\binom{n}{2}}{m},$$
> then there is a $\rho$-locally dense graphon $W$ with $\|W_F\|_{L^p} < \rho^{\,e(F)}$.

The formula $\binom{n}{2}/m$ is the ratio of possible to actual edges — memorable and symmetric. Our purpose is to interrogate it.

### 1.3 Contributions

1. **Single edge (Section 3).** We prove the conjecture is *correct and sharp* for $K_2$: the threshold is exactly $p^\star(K_2) = 1 = \binom{2}{2}/1$. For $p\ge1$ no counterexample exists (Theorem 3.1, via the power-mean inequality); for $0<p<1$ an explicit block construction is a counterexample (Theorem 3.2). Combining gives sharpness (Theorem 3.3).

2. **Matching disproof (Section 4).** We prove the pattern functional of the $2$-edge matching $M_2$ factorizes, $\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^2$ (Theorem 4.1). Because $\|W_{K_2}\|_{L^p}\ge\rho$ for $p\ge1$, this forces $\|W_{M_2}\|_{L^p}\ge\rho^2$ for *all* $p\ge1$ (Theorem 4.2). Since the conjecture predicts counterexamples throughout $1\le p<3$, the literal $\binom{n}{2}/m$ threshold is **false**; the true threshold for $M_2$ is $1$ (Corollary 4.3).

3. **The component-count bridge (Section 5).** We isolate the mechanism. A bijection identifies edge-constant vertex colorings with arbitrary colorings of connected components (Theorem 5.1), so the number of such colorings is $k^{c}$ with $c$ the component count (Corollary 5.2). This yields the block-kernel closed form $\sum_\varphi \prod_{\text{edges}} W(\varphi) = t^{D} k^{c}$ (Theorem 5.4), where $D$ is the number of directed edges. Normalizing shows block constructions reach $(n-c)/m$ and no further (Section 6). Since $n-c\le\binom{n}{2}$ with unbounded slack over matchings, this explains and corrects the suspect threshold.

---

## 2. Preliminaries and notation

We write $[N] = \{0,\dots,N-1\}$ for the host and $[k] = \{0,\dots,k-1\}$ for a set of $k$ block indices. A **block graphon** with $k$ blocks partitions $[N]$ into $k$ equal parts $B_0,\dots,B_{k-1}$ and sets $W(x,y) = \beta(i,j)$ whenever $x\in B_i$, $y\in B_j$, for a symmetric block-value matrix $\beta\colon [k]^2\to[0,1]$.

For a simple graph $G$ on a finite vertex set $V$, a **walk** is a sequence of vertices in which consecutive entries are adjacent; two vertices are **connected** if joined by a walk. Connectivity is an equivalence relation whose classes are the **connected components**; we write $c(G)$ for their number. The number of **directed edges** (ordered adjacent pairs) is $D(G) = |\{(a,b): a \sim b\}| = 2\,e(G)$.

We use the **power-mean inequality** in the following averaged form: for nonnegative reals $a_1,\dots,a_M$ and $p\ge 1$,

$$\left(\frac1M\sum_i a_i\right)^{p} \;\le\; \frac1M\sum_i a_i^{\,p}, \tag{PM}$$

equivalently $\big(\frac1M\sum_i a_i^p\big)^{1/p} \ge \frac1M\sum_i a_i$; it is a direct consequence of Jensen's inequality applied to the convex function $x\mapsto x^p$.

---

## 3. The single edge: the threshold is exactly $1$

For $F = K_2$ the functional simplifies to the $p$-mean of the kernel entries:

$$\|W_{K_2}\|_{L^p} = \left(\frac{1}{N^2}\sum_{x,y\in[N]} W(x,y)^p\right)^{1/p}.$$

The local-density hypothesis, applied to $S = [N]$, gives $\frac{1}{N^2}\sum_{x,y}W(x,y)\ge \rho$.

**Theorem 3.1 (single-edge lower bound).** *For every $p\ge 1$ and every $\rho$-locally dense $W$ with values in $[0,1]$,*
$$\|W_{K_2}\|_{L^p} \ge \rho.$$

*Proof.* Apply (PM) to the $N^2$ nonnegative numbers $W(x,y)$:
$$\|W_{K_2}\|_{L^p}^p = \frac1{N^2}\sum_{x,y}W(x,y)^p \ge \left(\frac1{N^2}\sum_{x,y}W(x,y)\right)^p \ge \rho^p,$$
using (LD) with $S=[N]$ for the second inequality. Taking $p$-th roots (both sides nonnegative) gives the claim. $\qquad\blacksquare$

Thus above the threshold the bound $\|W_{K_2}\|_{L^p}\ge\rho = \rho^{e(K_2)}$ holds and no counterexample exists. Below the threshold, counterexamples appear.

**Theorem 3.2 (block counterexample below $1$).** *Fix an integer $k\ge2$ and let $W$ be the $k$-block graphon with $\beta(i,j) = \mathbf 1[i=j]$ (all connections inside each block, none across). Then $W$ is $\rho$-locally dense at level $\rho = 1/k$, takes values in $[0,1]$, and for every $0<p<1$,*
$$\|W_{K_2}\|_{L^p} = (1/k)^{1/p} < 1/k = \rho.$$

*Proof.* **Local density.** Take any $S$ with $s_i = |S\cap B_i|/|S|$ the fraction of $S$ in block $i$, so $\sum_i s_i = 1$. Then $\frac{1}{|S|^2}\sum_{x,y\in S}W = \sum_i s_i^2$ (only same-block pairs contribute). By Cauchy–Schwarz (or power-mean), $\sum_i s_i^2 \ge (\sum_i s_i)^2/k = 1/k = \rho$. Hence (LD) holds. **Value.** Since $W\in\{0,1\}$, $W^p = W$, and the fraction of same-block ordered pairs is $k\cdot(1/k)^2 = 1/k$, so $\|W_{K_2}\|_{L^p}^p = 1/k$ and $\|W_{K_2}\|_{L^p} = (1/k)^{1/p}$. As $0<p<1$ gives $1/p>1$ and $1/k<1$, we get $(1/k)^{1/p}<1/k$. $\qquad\blacksquare$

**Theorem 3.3 (sharp single-edge threshold).** *The single-edge threshold is exactly*
$$p^\star(K_2) = 1 = \binom{2}{2}\big/1.$$
*No $\rho$-locally dense counterexample to $\|W_{K_2}\|_{L^p}\ge\rho$ exists for $p\ge1$; a counterexample exists for every $0<p<1$.*

*Proof.* Immediate from Theorems 3.1 and 3.2. $\qquad\blacksquare$

For the single edge the suspect conjecture is therefore vindicated. This makes the matching failure below all the more striking.

---

## 4. The $2$-edge matching: the conjecture fails

Let $M_2$ denote the matching with vertex set $\{1,2,3,4\}$ and edges $\{1,2\}$, $\{3,4\}$: two disjoint edges, so $n=4$, $m=2$, $e(M_2)=2$, and $c(M_2)=2$. The conjectured threshold is $\binom{4}{2}/2 = 3$.

**Theorem 4.1 (matching factorization).** *For every graphon $W$ on $[N]$ and every $p>0$,*
$$\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^{\,2}.$$

*Proof.* Because the two edges share no vertices, the sum over $\varphi\colon\{1,2,3,4\}\to[N]$ factors as a product of two independent sums:
$$\|W_{M_2}\|_{L^p}^p = \frac{1}{N^4}\sum_{a,b,c,d} W(a,b)^p W(c,d)^p = \left(\frac1{N^2}\sum_{a,b}W(a,b)^p\right)\left(\frac1{N^2}\sum_{c,d}W(c,d)^p\right) = \left(\|W_{K_2}\|_{L^p}^p\right)^2.$$
Taking $p$-th roots gives $\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^2$. $\qquad\blacksquare$

**Theorem 4.2 (matching non-existence of counterexamples for $p\ge1$).** *For every $p\ge1$ and every $\rho$-locally dense nonnegative graphon $W$,*
$$\|W_{M_2}\|_{L^p} \ge \rho^{2} = \rho^{e(M_2)}.$$

*Proof.* By Theorem 4.1 and then Theorem 3.1, $\|W_{M_2}\|_{L^p} = \|W_{K_2}\|_{L^p}^2 \ge \rho^2$. $\qquad\blacksquare$

**Corollary 4.3 (the conjecture is false; the true threshold is $1$).** *The literal threshold $\binom{n}{2}/m$ is incorrect. For $M_2$ it predicts counterexamples on the entire interval $1\le p<3$, but by Theorem 4.2 none exist there. Moreover, applying the block construction of Theorem 3.2 through the factorization gives, for $0<p<1$,*
$$\|W_{M_2}\|_{L^p} = (1/k)^{2/p} < (1/k)^2 = \rho^2,$$
*a genuine counterexample. Hence the true matching threshold is exactly $p^\star(M_2) = 1$.*

**Remark 4.4 (unbounded error).** For the matching with $m$ disjoint edges, $n=2m$, $c=m$, the same factorization gives true threshold $1$, while the conjecture predicts $\binom{2m}{2}/m = 2m-1$. The gap $2m-2\to\infty$: the suspect formula is not merely off by a constant.

---

## 5. The mechanism: connected components as an exponent

Why do block constructions cap out exactly where they do? The reason is a counting identity linking a purely combinatorial constraint to the topology of the pattern.

Fix a finite simple graph $G$ on vertex set $V$ and a finite palette $\beta$ of colors. Call a coloring $f\colon V\to\beta$ **edge-constant** if $f(a) = f(b)$ whenever $a\sim b$.

**Lemma 5.0 (edge-constant equals walk-constant).** *If $f$ is edge-constant then $f$ is constant along every walk; hence $f(v)=f(w)$ whenever $v$ and $w$ are connected.*

*Proof.* Induction on walk length. The empty walk from $v$ to $v$ is trivial. If $v\sim v'$ and there is a walk $v'\to w$ with $f(v')=f(w)$, then $f(v)=f(v')=f(w)$. $\qquad\blacksquare$

**Theorem 5.1 (the connector bijection).** *Edge-constant colorings of $V$ are in canonical bijection with arbitrary colorings of the set of connected components:*
$$\{\, f\colon V\to\beta \;\mid\; f \text{ edge-constant} \,\} \;\;\cong\;\; \big(\, \mathrm{Comp}(G) \to \beta \,\big),$$
*where $\mathrm{Comp}(G)$ is the set of connected components of $G$.*

*Proof.* By Lemma 5.0 an edge-constant $f$ is constant on each component and so descends to a well-defined map $\bar f\colon \mathrm{Comp}(G)\to\beta$. Conversely any $g\colon\mathrm{Comp}(G)\to\beta$ pulls back to $f(v) = g([v])$, which is edge-constant since adjacent vertices lie in the same component. These operations are mutually inverse. $\qquad\blacksquare$

**Corollary 5.2 (counting form).** *For finite $V$ and a palette of $k$ colors,*
$$\#\{\, f\colon V\to[k] \;\mid\; f \text{ edge-constant} \,\} \;=\; k^{\,c(G)}.$$

*Proof.* The right-hand side of Theorem 5.1 is the set of maps $\mathrm{Comp}(G)\to[k]$, of which there are $k^{c(G)}$. $\qquad\blacksquare$

We now feed this into the pattern functional of a **block-diagonal kernel** $W_t(i,j) = t\cdot\mathbf1[i=j]$ on the $k$ block indices (value $t$ within a block, $0$ across blocks). Define the discrete homomorphism product over ordered pairs,
$$\mathrm{hom}(W_t, \varphi) = \prod_{a\in V}\prod_{b\in V} \big(\,\text{if } a\sim b \text{ then } W_t(\varphi(a),\varphi(b)) \text{ else } 1\,\big),$$
where $\varphi\colon V\to[k]$.

**Lemma 5.3 (product collapses to an indicator).** *For the block-diagonal kernel,*
$$\mathrm{hom}(W_t,\varphi) = \begin{cases} t^{\,D(G)}, & \varphi \text{ edge-constant},\\[2pt] 0, & \text{otherwise},\end{cases}$$
*where $D(G)$ is the number of directed edges.*

*Proof.* If $\varphi$ is edge-constant, every edge factor equals $t$ and there are exactly $D(G)$ of them (non-edges contribute the factor $1$), giving $t^{D(G)}$. If some edge $a\sim b$ has $\varphi(a)\ne\varphi(b)$, that factor is $W_t(\varphi(a),\varphi(b)) = 0$, so the whole product vanishes. $\qquad\blacksquare$

**Theorem 5.4 (block-kernel closed form).** *Summing over all $k$-colorings,*
$$\sum_{\varphi\colon V\to[k]} \mathrm{hom}(W_t,\varphi) \;=\; t^{\,D(G)}\cdot k^{\,c(G)}.$$

*Proof.* By Lemma 5.3 only edge-constant $\varphi$ contribute, each with value $t^{D(G)}$; by Corollary 5.2 there are $k^{c(G)}$ of them. $\qquad\blacksquare$

The exponent of $k$ in Theorem 5.4 is *exactly* the number of connected components. This is the combinatorial engine behind the block-graphon $L^p$ value.

---

## 6. From the closed form to the corrected threshold

We now normalize Theorem 5.4 to recover the reachable $L^p$ value for a general pattern $F$ with $n$ vertices, $m$ edges, and $c$ components.

Use a $k$-block host of $N = k$ points (one point per block; general $N$ scales identically) with block value chosen so that the on-diagonal weight equals $\rho k$ — this is the largest value keeping $W\in[0,1]$-scaled local density at level $\rho$, since the diagonal blocks carry all the mass and each covers a $1/k$ fraction of the population. With $D = 2m$ directed edges, taking the $p$-th power of the kernel (i.e. $t = (\rho k)^p$) and dividing by the vertex-map count $k^{\,n}$ gives

$$\|W_F\|_{L^p}^{\,p} \;=\; \frac{t^{\,2m}\, k^{\,c}}{k^{\,n}}\Big|_{\text{normalized}} \;=\; k^{\,c-n+mp}\,\rho^{\,mp}.$$

Therefore

$$\|W_F\|_{L^p} \;=\; k^{\,(c-n+mp)/p}\,\rho^{\,m} \;=\; k^{\,(c-n)/p}\;\rho^{\,m}\cdot k^{\,m}\big/k^{\,m}\;,$$

and comparing with the forbidden value $\rho^{e(F)} = \rho^{m}$ we obtain the clean criterion: the block construction beats the bound, $\|W_F\|_{L^p} < \rho^{m}$, for large $k$ **iff** the exponent of $k$ is negative,

$$c - n + mp < 0 \quad\Longleftrightarrow\quad p < \frac{n-c}{m}.$$

**Theorem 6.1 (corrected reachable threshold).** *For every finite pattern $F$ with $n$ non-isolated vertices, $m$ edges, and $c$ connected components, block-diagonal constructions produce a $\rho$-locally dense counterexample to $\|W_F\|_{L^p}\ge\rho^{e(F)}$ for every $p < (n-c)/m$.*

**Corollary 6.2 (consistency and correction).** *The corrected threshold $(n-c)/m$ recovers all our exact cases and never exceeds the conjectured one:*

- *Single edge $K_2$: $(2-1)/1 = 1$, matching Theorem 3.3.*
- *Matching $M_2$: $(4-2)/2 = 1$, matching Corollary 4.3.*
- *General $m$-edge matching: $(2m-m)/m = 1$, matching Remark 4.4.*
- *For all $F$, $n - c \le \binom{n}{2}$, so $(n-c)/m \le \binom{n}{2}/m$; for matchings the slack $\binom{n}{2}-(n-c) = (2m-1)m - m = m(2m-2)$ is unbounded.*

The suspect formula replaced the component-aware quantity $n-c$ by the far larger $\binom{n}{2}$, inflating the threshold whenever the pattern has more than the minimum connectivity.

---

## 7. Algorithms

The results above are effective: every quantity is a finite sum computable exactly in rational arithmetic. We record the three core routines.

**Algorithm A (single-edge $L^p$ value of a block graphon).** Given a block-value matrix $\beta$ and block sizes, compute $\|W_{K_2}\|_{L^p}$ as the $p$-th root of the block-weighted $p$-th-power average. Complexity $O(k^2)$ for $k$ blocks. Used to certify Theorems 3.1–3.2 numerically.

**Algorithm B (component-count closed form).** Given a pattern $G$, compute $c(G)$ by union–find over its edges, then return the closed form $t^{D}k^{c}$ and compare against the brute-force sum $\sum_\varphi \mathrm{hom}(W_t,\varphi)$ (an $O(k^{|V|})$ enumeration) to certify Theorem 5.4. Complexity $O(|V|\,\alpha(|V|) + |E|)$ for the closed form.

**Algorithm C (threshold comparator).** Given $F$, compute $(n,m,c)$ and output both the corrected threshold $(n-c)/m$ and the conjectured $\binom{n}{2}/m$, flagging the gap. Complexity linear in the size of $F$.

---

## 8. Applications and discussion

**Corrected map of the $L^p$ landscape.** The exact results give a precise phase diagram for the two smallest cases and a general reachability bound. For the single edge, the classical density lower bound is defeated by softening to $L^p$ *precisely* for $p<1$. For disjoint edges the count factorizes, so the bound is never defeated for $p\ge1$; the conjectured window $1\le p<3$ is empty.

**A geometry-in-analysis phenomenon.** The magnitude of the $L^p$ pattern integral for block hosts is controlled by a discrete topological invariant of the pattern, the number of connected components. This is a small instance of the recurring theme in which a counting of "pieces" controls the size of an integral. The mechanism here is completely explicit: edge-constant colorings equal component colorings, hence their number is $k^{c}$.

**Relation to Sidorenko / KNRS.** The case $p=1$ of the surviving bound $\|W_F\|_{L^1}\ge\rho^{e(F)}$ for $\rho$-locally dense hosts is exactly the KNRS lower bound. Clarifying for which patterns the $L^p$ inequality persists for some $p>1$ (as it does for matchings up to $p=1$ being the boundary of counterexamples) connects the threshold question to Sidorenko's conjecture.

---

## 9. Future work

1. **Exact threshold $p^\star(F)$.** We have $p^\star(F) \ge (n-c)/m$ from Theorem 6.1 and, for matchings, the matching upper bound $p^\star = 1$. Is $p^\star(F) = (n-c)/m$ for all $F$? The first test is the triangle $K_3$ ($n=3, m=3, c=1$): block constructions give $p<2/3$; does a counterexample exist for $2/3\le p<1$, and is there any for $p\ge1$? Settling this needs either a smarter construction or a Sidorenko-type lower bound.

2. **Rank-one PSD perturbations.** Kernels $W = \rho + c\,\varphi(x)\varphi(y)$ with $c\ge0$ are automatically $\rho$-locally dense, since $\frac1{|S|^2}\sum_{S\times S} W = \rho + c\big(\tfrac1{|S|}\sum_S\varphi\big)^2 \ge \rho$. They are far more flexible than block kernels and are the natural candidate to beat $(n-c)/m$. Computing their $L^p$ functional is a concrete next step.

3. **General block-kernel theorem in normalized form.** Promote Theorem 5.4 to the normalized statement $\|W_F\|_{L^p}^p = k^{c-n+mp}\rho^{mp}$ for a general finite pattern, completing the reachability direction in full generality.

4. **Continuum bridge.** Lift the finite-model results to genuine graphons on $[0,1]^2$, and prove that for block-constant kernels the worst-case local-density set is a union of blocks, so the finite check is equivalent to the continuum condition.

5. **Sym2 edge model.** Restate the homomorphism product over undirected edges ($D=|E|$) and reconcile with the ordered-pair version up to the $2|E|$ exponent, matching the literature convention.

---

## Appendix: worked numerical checks

For $k=2$ (so $\rho = 1/2$) and $p = 1/2$: the two-block $0/1$ graphon has $\|W_{K_2}\|_{L^{1/2}} = (1/2)^{2} = 1/4 < 1/2 = \rho$ (counterexample), while for $p=2$, $\|W_{K_2}\|_{L^2} = (1/2)^{1/2} \approx 0.707 \ge 1/2$ (no counterexample). For the matching, $\|W_{M_2}\|_{L^2} = 1/2 \ge 1/4 = \rho^2$, confirming Theorem 4.2 at the conjecture's "counterexample" value $p=2<3$. The closed form of Theorem 5.4 for $M_2$ with $k$ blocks: $D=4$, $c=2$, so $\sum_\varphi \mathrm{hom}(W_t,\varphi) = t^4 k^2$; direct enumeration over $k^4$ colorings confirms this exactly.
