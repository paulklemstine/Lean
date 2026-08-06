# Half-Canonical Divisors of Large Rank on Regular Graphs

**Author:** Aristotle
**Date:** 2026-08-06

---

## Abstract

Let $G$ be a finite simple connected graph of genus $g = |E| - |V| + 1$, equipped with the Baker–Norine theory of divisors and linear systems. The *half-canonical degree* $g-1$ is the unique degree at which the graph-theoretic Riemann–Roch identity $r(D) - r(K-D) = \deg D - g + 1$ degenerates, yielding only the symmetry $r(D) = r(K-D)$ and no information about the common value. We study the resulting existence problem for $k$-regular graphs: does every simple $k$-regular graph carry a divisor of degree $g-1$ and Baker–Norine rank at least $k-1$?

Our principal result is a **one-shot set-firing estimate**: on a graph of minimum degree $k$, a divisor carrying at least $m$ chips on every vertex, with $2 \le m \le k$, has Baker–Norine rank at least $\min(3m-1,\,k+m)$. The proof isolates the set $S$ of vertices at which an adversarial effective divisor meets the local reserve $m$, shows by a global degree count that $|S| \le 2$, and then fires the complement of $S$ exactly once.

Applied at the half-canonical degree of a $k$-regular graph, where the constant reserve is $m = \lfloor (k-2)/2 \rfloor$, this yields an unconditional existence theorem: **for every $k \ge 6$ with $k \ne 7$, every simple $k$-regular graph — with no lower bound whatsoever on the number of vertices — carries a divisor of degree $g-1$ and rank at least $k-1$.** The conjectural threshold $N_0(k)$ may therefore be taken to equal $1$ for all such $k$.

We complement this with four further results. First, a *pointwise obstruction*: on a $k$-regular graph no divisor of degree $g-1$ can carry $r$ chips at every vertex once $2r > k-2$, so the target rank $k-1$ can never be certified by domination alone and every proof must genuinely move chips. Second, the exact *Brill–Noether arithmetic*: at $d = g-1$ the Brill–Noether number collapses to $\rho = g - (r+1)^2$, and for a $k$-regular graph with $r = k-1$ positivity is equivalent to $2k^2 \le (k-2)n$ — yet the linear bound $n \ge 2k+7$ already implies it for $k \ge 5$, so the quadratic scale $2k^2$ is not forced by the numerics. Third, a *residual duality*: the involution $D \mapsto K-D$ preserves the half-canonical degree and, under Riemann–Roch, the set of witnesses of any given rank; its fixed classes are exactly the theta characteristics, for which the rank identity holds unconditionally. Fourth, an explicit *self-dual witness*: on a $2j$-regular graph with $j \ge 3$ the constant divisor $j-1$ is a theta characteristic of degree $g-1$ and rank at least $3j-4 \ge k-1$.

Exhaustive rank computations show that the set-firing bound is attained — not merely approached — on $K_6$, $K_7$, $K_8$, $C_8(1,2,3)$ and $C_9(1,2,3)$, and that the maximal rank at the half-canonical degree on $K_6$ is $2$, so that at $k=5$ a genuine threshold $N_0(5) > 6$ is required.

**Keywords.** chip-firing, Baker–Norine rank, divisors on graphs, half-canonical divisor, theta characteristic, Brill–Noether number, regular graph, set firing.

---

## 1. Introduction

### 1.1 Divisor theory on graphs

The theory of divisors on finite graphs, initiated by Baker and Norine, is a combinatorial shadow of the divisor theory of algebraic curves. A *divisor* on a graph $G$ is an integer-valued function on its vertices — a configuration of chips, possibly negative. The role of "principal divisors" is played by the image of the graph Laplacian, that is, by the chip-firing moves; the quotient of degree-zero divisors by principal divisors is the finite *Jacobian*, or sandpile group. Most strikingly, there is an exact analogue of the Riemann–Roch theorem, with a canonical divisor $K(v) = \deg(v) - 2$ and a genus $g = |E| - |V| + 1$.

The transfer of information across this bridge is not formal: degenerating a family of algebraic curves to a graph and computing on the graph has become a standard method for proving statements about curves, and the graph-theoretic Brill–Noether theory has been used to give combinatorial proofs of sharp results about the existence and non-existence of linear systems on general curves.

### 1.2 The half-canonical degree

Riemann–Roch determines the rank function completely for divisors of degree $> 2g-2$, and constrains it strongly at all other degrees except one. At
$$\deg D = g - 1$$
the right-hand side of
$$r(D) - r(K - D) = \deg D - g + 1$$
vanishes, and the identity degenerates into a bare symmetry:
$$r(D) = r(K-D).$$
Nothing at all is said about the common value. This *half-canonical degree* — half the canonical degree $2g-2$ — is therefore the unique locus in the theory that Riemann–Roch leaves open, and it is exactly where the classical theory of theta characteristics and of Brill–Noether loci is most interesting.

### 1.3 The regular case and the existence problem

For a $k$-regular graph the canonical divisor is the constant function $k-2$, so $2g - 2 = (k-2)n$ where $n = |V|$, and the half-canonical degree is
$$g - 1 = \tfrac12 (k-2) n .$$
The genus ceases to be an independent parameter; the problem is governed by the pair $(k,n)$ alone. The existence question, in the strongest form one might hope for, is:

> **Uniform half-canonical existence.** For every $k \ge 5$ there is a threshold $N_0(k)$ such that every simple connected $k$-regular graph on at least $N_0(k)$ vertices carries a divisor of degree $g-1$ and Baker–Norine rank at least $k-1$.

The scale of $N_0(k)$ was expected to be quadratic, of order $2k^2$, this being the number of vertices at which the relevant Brill–Noether count first becomes non-negative. One of the messages of this paper is that this expectation conflated a dimension count with a construction: for almost all $k$ the correct threshold is $N_0(k) = 1$.

### 1.4 Results

Throughout, "rank" means the Baker–Norine rank $r(D)$, defined in §2.

**Theorem A (Receiving-move bound, §4).** Let $G$ have minimum degree at least $k$ and let $D$ satisfy $D(v) \ge m$ for all $v$, with $m \ge 1$. Then $r(D) \ge m + t$ for every integer $t$ with $0 \le t \le \min(m,k)$. In particular $r(D) \ge 2m$ whenever $m \le k$.

**Theorem B (Set-firing bound, §5).** Let $G$ have minimum degree at least $k$ and let $D$ satisfy $D(v) \ge m$ for all $v$, with $2 \le m \le k$. Then
$$r(D) \ \ge\ \min\bigl(3m - 1,\ k + m\bigr).$$

**Theorem C (Unconditional half-canonical existence, §6).** Let $G$ be a simple $k$-regular graph on $n \ge 1$ vertices with $k \ge 6$. Then $G$ carries a divisor $D$ with $\deg D = g-1$ and
$$r(D) \ \ge\ 3\left\lfloor \tfrac{k-2}{2}\right\rfloor - 1 .$$
Consequently, for every $k \ge 6$ with $k \ne 7$, every simple $k$-regular graph carries a divisor of degree $g-1$ and rank at least $k-1$; the threshold $N_0(k)$ may be taken to be $1$.

**Theorem D (Pointwise obstruction, §3).** Let $G$ be a $k$-regular graph and let $r$ satisfy $2r > k-2$. Then there is *no* divisor $D$ with $\deg D = g-1$ and $D(v) \ge r$ for all $v$. In particular this holds for $r = k-1$ and every $k$.

**Theorem E (Residual duality, §7).** The residual map $D \mapsto K - D$ is an involution preserving the half-canonical degree. If $G$ satisfies the Baker–Norine Riemann–Roch identity, then $r(K-D) = r(D)$ for every $D$ of degree $g-1$, so the involution maps the set of degree-$(g-1)$ divisors of rank at least $r$ onto itself. A divisor class is fixed by the involution if and only if it is a theta characteristic ($2D \sim K$), and for a theta characteristic the identity $r(K-D) = r(D)$ holds with no Riemann–Roch hypothesis.

**Theorem F (Self-dual witness, §7).** On a simple $2j$-regular graph with $j \ge 3$, the constant divisor $D \equiv j-1$ is a theta characteristic of degree $g-1$, fixed by the residual involution, with $r(D) \ge 3j - 4 \ge k-1$.

**Theorem G (Brill–Noether arithmetic, §8).** At $d = g-1$ the Brill–Noether number satisfies $\rho(g, g-1, r) = g - (r+1)^2$. For a $k$-regular graph and $r = k-1$,
$$\rho \ \ge\ 1 \iff 2k^2 \le (k-2)\,n .$$
For $k \ge 5$ the linear bound $n \ge 2k + 7$ already implies this; and $2k+7 \le 2k^2$ for all $k \ge 3$.

Section 9 records exhaustive rank computations establishing sharpness and the necessity of a threshold at $k=5$; §10 discusses the remaining cases and directions.

---

## 2. Divisors, chip-firing, and the Baker–Norine rank

Throughout, $G = (V,E)$ is a finite simple graph with $n = |V| \ge 1$; connectivity is assumed only where stated. We write $\deg_G(v)$ for the vertex degree and $N(v)$ for the neighbourhood.

**Definition 2.1 (Divisor, degree).** A *divisor* on $G$ is a function $D : V \to \mathbb{Z}$. Its *degree* is $\deg D = \sum_{v \in V} D(v)$. A divisor is *effective*, written $D \ge 0$, if $D(v) \ge 0$ for all $v$.

**Definition 2.2 (Laplacian and firing).** For $f : V \to \mathbb{Z}$ define
$$(\Delta f)(v) \;=\; \deg_G(v)\, f(v) \;-\!\!\sum_{u \in N(v)}\! f(u).$$
For a subset $A \subseteq V$ write $\mathbf 1_A$ for its indicator. Then
$$(\Delta \mathbf 1_A)(v) = \begin{cases} \operatorname{out}(v, A) := |N(v)\setminus A|, & v \in A,\\[2pt] -\,|N(v)\cap A|, & v \notin A,\end{cases}$$
so that *firing the set $A$* — every vertex of $A$ sends one chip along each of its edges leaving $A$ — transforms $D$ into $D - \Delta\mathbf 1_A$. Since $\Delta \mathbf 1_V = 0$, firing $A$ and firing $V \setminus A$ differ only in sign; equivalently, $D + \Delta \mathbf 1_S$ is the result of *firing the complement of $S$*: each vertex of $S$ gains one chip per edge leaving $S$, and each vertex outside $S$ pays one chip per neighbour inside $S$.

**Definition 2.3 (Linear equivalence).** Divisors $D, D'$ are *linearly equivalent*, $D \sim D'$, if $D' = D + \Delta f$ for some $f : V \to \mathbb{Z}$. Linear equivalence preserves degree, since $\deg \Delta f = 0$ for all $f$.

**Definition 2.4 (Baker–Norine rank).** For an integer $r \ge 0$ we say $r(D) \ge r$ if for *every* effective divisor $E$ with $\deg E = r$ there exists $f$ with
$$D - E + \Delta f \ \ge\ 0 .$$
The *Baker–Norine rank* $r(D)$ is the largest such $r$, with the convention $r(D) = -1$ if $D$ is not linearly equivalent to any effective divisor. The condition "$r(D)\ge r$" is monotone decreasing in $r$ and is invariant under linear equivalence of $D$; moreover $r(D) \ge r$ implies $\deg D \ge r$, since $D - E + \Delta f \ge 0$ forces $\deg D \ge \deg E = r$.

**Definition 2.5 (Genus, canonical divisor).** The *genus* of $G$ is $g = |E| - |V| + 1$. The *canonical divisor* is $K(v) = \deg_G(v) - 2$; by the handshake lemma
$$\deg K = 2|E| - 2|V| = 2g - 2 .$$

**Theorem 2.6 (Baker–Norine Riemann–Roch; hypothesis $\mathrm{RR}$).** For a connected graph $G$ and every divisor $D$,
$$r(D) - r(K-D) = \deg D - g + 1 .$$
We treat this identity as a named hypothesis, $\mathrm{RR}(G)$, and mark the (few) statements below that use it. It is satisfiable — for instance the one-vertex graph, where $g = 0$, all firings are trivial and $r(D) = \max(-1, \deg D)$, satisfies it directly.

**Remark 2.7 (Where the identity is silent).** Setting $\deg D = g-1$ in Theorem 2.6 gives $r(D) = r(K-D)$ and nothing more. This is the half-canonical degree studied here.

---

## 3. The half-canonical degree of a regular graph, and the pointwise obstruction

**Lemma 3.1.** If $G$ is $k$-regular then $K \equiv k-2$ is constant, and
$$2(g-1) = (k-2)\,n .$$

*Proof.* $K(v) = \deg_G(v) - 2 = k-2$. Summing, $\deg K = (k-2)n$, and $\deg K = 2g-2$. $\square$

Thus the half-canonical degree is $g - 1 = (k-2)n/2$, and the *average* number of chips per vertex at that degree is exactly $(k-2)/2 \approx k/2$. The target rank is $k-1$, roughly twice the average. This already suggests that no argument based purely on local abundance can succeed, and indeed:

**Theorem 3.2 (Theorem D; pointwise obstruction).** Let $G$ be $k$-regular with $n \ge 1$ and let $r \ge 0$ satisfy $(k-2) < 2r$. Then there is no divisor $D$ with $\deg D = g-1$ and $D(v) \ge r$ for all $v$.

*Proof.* Such a $D$ would satisfy $rn \le \deg D = g-1 = (k-2)n/2$, whence $2r \le k-2$, contradicting the hypothesis. $\square$

**Corollary 3.3.** Taking $r = k-1$: since $2(k-1) = 2k-2 > k-2$ for every $k \ge 0$, the conjectural rank-$(k-1)$ witnesses are *never* pointwise-dominant. Any proof of half-canonical existence must move chips.

**Corollary 3.4 (Optimality of the uniform reserve).** No divisor of degree $g-1$ on a $k$-regular graph has more than $m := \lfloor (k-2)/2 \rfloor$ chips at every vertex.

**Lemma 3.5 (Construction of the reserve).** Let $V \ne \emptyset$, let $m \ge 0$ and let $d \ge mn$. Then there is a divisor $D$ with $\deg D = d$ and $D(v) \ge m$ for all $v$.

*Proof.* Fix $v_0$ and set $D(v_0) = m + (d - mn)$, $D(v) = m$ otherwise. The degree is $mn + (d-mn) = d$ and the lower bound is clear since $d - mn \ge 0$. $\square$

For a $k$-regular graph and $d = g-1$, the hypothesis $mn \le d$ reads $2mn \le (k-2)n$, i.e. $2m \le k-2$, which holds precisely for $m \le \lfloor (k-2)/2\rfloor$. Combining Corollary 3.4 and Lemma 3.5: **the constant reserve $m = \lfloor(k-2)/2\rfloor$ is available, and it is the best possible.** The entire remaining problem is to convert a reserve of $m$ into a rank substantially larger than $m$.

---

## 4. The receiving move: rank at least $2m$

The simplest nontrivial firing is "all vertices except one fire". We record its Laplacian description.

**Lemma 4.1.** For $v, u \in V$,
$$\bigl(\Delta \mathbf 1_{\{v\}}\bigr)(u) = \begin{cases} \deg_G(v), & u = v,\\ -1, & u \sim v,\\ 0, & \text{otherwise.}\end{cases}$$
Thus adding $\Delta \mathbf 1_{\{v\}}$ to a divisor gives $v$ one chip along each of its edges, at the cost of one chip from each neighbour.

*Proof.* Immediate from Definition 2.2 with $A = \{v\}$: $\operatorname{out}(v,\{v\}) = \deg_G(v)$, and $|N(u) \cap \{v\}| = 1$ exactly when $u \sim v$. $\square$

**Theorem 4.2 (Theorem A).** Suppose $\deg_G(v) \ge k$ for all $v$, and let $D$ satisfy $D(v) \ge m$ for all $v$ with $m \ge 1$. Then for every $t$ with $0 \le t \le m$ and $t \le k$ we have $r(D) \ge m+t$.

*Proof.* Let $E \ge 0$ with $\deg E = m+t$. If $E(v) \le D(v)$ for all $v$, then $D - E \ge 0$ and we take $f = 0$.

Otherwise fix $v$ with $E(v) > D(v)$; since $D(v) \ge m$ this gives
$$E(v) \ \ge\ m+1 .$$
Because $E$ is effective, for any $u \ne v$ we have $E(u) + E(v) \le \deg E = m+t$, hence
$$E(u) \ \le\ (m+t) - (m+1) \ =\ t-1 \qquad (u \ne v),$$
and also $E(v) \le \deg E = m+t$.

Take $f = \mathbf 1_{\{v\}}$ and evaluate $D - E + \Delta f$ using Lemma 4.1.

- At $u = v$: $\;D(v) - E(v) + \deg_G(v) \ \ge\ m - (m+t) + k \ =\ k - t \ \ge\ 0$.
- At $u \sim v$: $\;D(u) - E(u) - 1 \ \ge\ m - (t-1) - 1 \ =\ m - t \ \ge\ 0$.
- At $u \not\sim v$, $u\ne v$: $\;D(u) - E(u) \ \ge\ m - (t-1) \ >\ 0$.

Hence $D - E + \Delta f \ge 0$. As $E$ was arbitrary, $r(D) \ge m+t$. $\square$

**Corollary 4.3.** Under the hypotheses of Theorem 4.2 with $m \le k$, $r(D) \ge 2m$.

**Corollary 4.4 (Half-canonical existence at rank $2\lfloor (k-2)/2\rfloor$).** Every simple $k$-regular graph with $k \ge 4$, on any number of vertices, carries a divisor $D$ with $\deg D = g-1$ and $r(D) \ge 2\lfloor (k-2)/2 \rfloor$. For even $k \ge 4$ this reads $r(D) \ge k-2$.

*Proof.* Set $m = \lfloor(k-2)/2\rfloor \ge 1$ and apply Lemma 3.5 to obtain $D$ with $\deg D = g-1$ and reserve $m$ (legitimate since $2m \le k-2$ gives $mn \le g-1$), then Corollary 4.3 with $m \le k$. $\square$

For even $k$ this is exactly one unit short of the conjectural rank $k-1$. Closing that unit is the content of the next section.

---

## 5. One-shot set firing: rank at least $\min(3m-1, k+m)$

The limitation of Theorem 4.2 is that it handles only a single vertex in debt. The remedy is to fire the complement of the whole *set* of heavily loaded vertices — and to observe that a global degree count forces that set to be tiny.

**Definition 5.1.** For $S \subseteq V$ and $v \in S$ write $\operatorname{out}(v,S) = |N(v) \setminus S|$ for the number of edges from $v$ leaving $S$.

**Lemma 5.2 (Set-firing criterion).** Let $S \subseteq V$ and let $D, E$ be divisors satisfying
1. $E(v) - D(v) \le \operatorname{out}(v, S)$ for every $v \in S$;
2. $|N(u) \cap S| \le D(u) - E(u)$ for every $u \notin S$.

Then $D - E + \Delta\mathbf 1_S \ge 0$; in particular $D-E$ is linearly equivalent to an effective divisor.

*Proof.* By Definition 2.2, for $v \in S$ the value of $D - E + \Delta\mathbf 1_S$ at $v$ is $D(v) - E(v) + \operatorname{out}(v,S) \ge 0$ by (1); for $u \notin S$ it is $D(u) - E(u) - |N(u)\cap S| \ge 0$ by (2). $\square$

**Lemma 5.3 (Edges leaving a small set).** If $v \in S$ then $\operatorname{out}(v,S) \ge \deg_G(v) - (|S| - 1)$.

*Proof.* $N(v) \cap S \subseteq S \setminus \{v\}$, since $G$ is simple and so $v \notin N(v)$. Hence $|N(v)\cap S| \le |S|-1$, and $\operatorname{out}(v,S) = \deg_G(v) - |N(v)\cap S|$. $\square$

**Theorem 5.4 (Theorem B).** Suppose $\deg_G(v) \ge k$ for all $v$. Let $D$ satisfy $D(v) \ge m$ for all $v$, with $2 \le m \le k$, and let $d$ be an integer with
$$d + 1 \le 3m \qquad\text{and}\qquad d \le k+m .$$
Then $r(D) \ge d$. Equivalently, $r(D) \ge \min(3m-1,\ k+m)$.

*Proof.* Let $E \ge 0$ with $\deg E = d$. If $E \le D$ pointwise we take $f = 0$ and are done, so assume some $v_0$ has $E(v_0) > D(v_0) \ge m$, i.e. $E(v_0) \ge m+1$.

Define the **trouble set**
$$S \;=\; \{\, u \in V : E(u) \ge m \,\}, \qquad v_0 \in S .$$

*Step 1: $S$ has at most two elements.* Since $E \ge 0$, for any $T \subseteq V$ we have $\sum_{u\in T} E(u) \le \deg E = d$. Applying this to $T = S$ and bounding each term from below — every $u \in S$ contributes at least $m$, and $v_0$ contributes at least $m+1$ — gives
$$|S|\,m + 1 \ \le\ \sum_{u \in S} E(u) \ \le\ d \ \le\ 3m - 1 . \tag{5.1}$$
If $|S| \ge 3$ then $3m + 1 \le 3m - 1$, absurd. Also $|S| \ge 1$. Hence $|S| \in \{1,2\}$.

*Step 2: the load outside $S$.* By definition of $S$, every $u \notin S$ has
$$E(u) \le m - 1. \tag{5.2}$$
Moreover, applying $\sum_{T} E \le d$ to $T = S \cup \{u\}$ and using the lower bound $\sum_{u\in S} E \ge |S|m+1$ from (5.1),
$$E(u) \;\le\; d - |S|\,m - 1 \qquad (u \notin S). \tag{5.3}$$

*Step 3: the load inside $S$.* For $v \in S$, the other $|S|-1$ elements of $S$ each carry at least $m$ chips of $E$, so
$$E(v) \ \le\ d - (|S|-1)\,m . \tag{5.4}$$

*Step 4: verify the criterion of Lemma 5.2.* We check the two conditions in each of the two cases.

**Case $|S| = 1$, $S = \{v_0\}$.**
Condition (1): by (5.4), $E(v_0) \le d \le k+m$, while $D(v_0) \ge m$ and $\operatorname{out}(v_0, S) = \deg_G(v_0) \ge k$ by Lemma 5.3. Hence
$$E(v_0) - D(v_0) \le (k+m) - m = k \le \operatorname{out}(v_0,S).$$
Condition (2): for $u \notin S$, $|N(u)\cap S| \le 1$, while by (5.2) $D(u) - E(u) \ge m - (m-1) = 1$.

**Case $|S| = 2$.**
Condition (1): for $v \in S$, (5.4) gives $E(v) \le d - m \le (3m-1) - m = 2m-1$, while Lemma 5.3 gives $\operatorname{out}(v,S) \ge \deg_G(v) - 1 \ge k-1$. Hence
$$E(v) - D(v) \ \le\ (2m-1) - m \ =\ m - 1 \ \le\ k-1 \ \le\ \operatorname{out}(v,S),$$
using $m \le k$.
Condition (2): for $u \notin S$, $|N(u)\cap S| \le 2$, while (5.3) gives $E(u) \le d - 2m - 1 \le (3m-1) - 2m - 1 = m-2$, so
$$D(u) - E(u) \ \ge\ m - (m-2) \ =\ 2 \ \ge\ |N(u)\cap S| .$$

In both cases Lemma 5.2 supplies $f = \mathbf 1_S$ with $D - E + \Delta f \ge 0$. As $E$ was arbitrary, $r(D) \ge d$. $\square$

**Remark 5.5 (What each hypothesis does).** The bound $d \le 3m-1$ is used twice and is the crux: once in Step 1 to force $|S| \le 2$, and once in Step 4 (Case $|S|=2$) to make an outside vertex able to afford *two* chips rather than one. The bound $d \le k+m$ is used only in Case $|S|=1$, where the single trouble vertex may absorb the entire demand but is compensated by its full degree. The hypothesis $m \ge 2$ is needed for (5.1) to bite ($m=1$ gives no bound on $|S|$), and $m \le k$ is needed in Case $|S|=2$.

**Remark 5.6 (Comparison).** For $m \le k$ this improves Corollary 4.3's bound $2m$ by roughly fifty percent. The two expressions in the minimum are genuinely both present: §9 exhibits a graph ($K_7$, $k=6$, $m=2$) where the true rank is $5 = 3m-1$ while $k+m = 8$, so the term $3m-1$ cannot be dropped.

---

## 6. Unconditional half-canonical existence

**Theorem 6.1 (Theorem C, first part).** Let $G$ be a simple $k$-regular graph on $n \ge 1$ vertices with $k \ge 6$. Then there is a divisor $D$ with
$$\deg D = g-1, \qquad r(D) \ \ge\ 3\left\lfloor \tfrac{k-2}{2}\right\rfloor - 1 .$$

*Proof.* Put $m = \lfloor (k-2)/2 \rfloor$; since $k \ge 6$ we have $m \ge 2$, and clearly $m \le k$. As $2m \le k-2$, Lemma 3.1 gives $mn \le (k-2)n/2 = g-1$, so Lemma 3.5 yields $D$ with $\deg D = g-1$ and $D(v)\ge m$ for all $v$.

Apply Theorem 5.4 with $d = 3m-1$. The hypothesis $d+1 \le 3m$ is an equality; and $d \le k+m$ holds since $3m - 1 \le k+m$ is equivalent to $2m \le k+1$, which follows from $2m \le k-2$. Hence $r(D) \ge 3m-1$. $\square$

**Theorem 6.2 (Theorem C, second part).** For every $k \ge 6$ with $k \ne 7$, every simple $k$-regular graph on any number of vertices carries a divisor of degree $g-1$ with rank at least $k-1$. Equivalently, the uniform half-canonical existence statement holds for such $k$ with threshold $N_0(k) = 1$.

*Proof.* By Theorem 6.1 it suffices to check $3\lfloor(k-2)/2\rfloor - 1 \ge k-1$.

If $k = 2j$ is even then $\lfloor(k-2)/2\rfloor = j-1$ and the inequality reads $3j - 4 \ge 2j-1$, i.e. $j \ge 3$, i.e. $k \ge 6$.

If $k = 2j+1$ is odd then $k - 2 = 2j-1$ and $\lfloor(k-2)/2\rfloor = j-1$ again, so the inequality reads $3j - 4 \ge 2j$, i.e. $j \ge 4$, i.e. $k \ge 9$.

Thus the inequality holds for all $k \ge 6$ except $k = 7$ (where $j=3$ and $3j-4 = 5 < 6 = k-1$). $\square$

**Remark 6.3 (The excluded degrees).** The proof fails exactly when $m = \lfloor(k-2)/2\rfloor$ is too small for the set-firing engine to reach $k-1$: at $k=5$ we get $m = 1$ and Theorem 5.4 does not even apply (only Theorem 4.2, giving rank $\ge 2$); at $k=7$ we get $m=2$ and the bound $3m-1 = 5$ falls one short of $6$. Section 9 shows both shortfalls are real, not artefacts.

**Remark 6.4 (Shape of the witness).** The witness is completely explicit: place $\lfloor(k-2)/2\rfloor$ chips at every vertex and the leftover $g - 1 - mn$ chips at a single arbitrary vertex. When $k$ is even the leftover is zero and the witness is the constant divisor $(k-2)/2$.

---

## 7. Residual duality and theta characteristics

We now turn to the internal symmetry of the half-canonical degree.

**Definition 7.1.** The *residual* of a divisor is $\operatorname{res}(D) = K - D$.

**Proposition 7.2.** $\operatorname{res}$ is an involution: $\operatorname{res}(\operatorname{res}(D)) = D$. Moreover $\deg \operatorname{res}(D) = 2g-2-\deg D$; in particular if $\deg D = g-1$ then $\deg \operatorname{res}(D) = g-1$.

*Proof.* Both statements are immediate from $\deg K = 2g-2$ (Definition 2.5). $\square$

**Theorem 7.3 (Theorem E; residual rank identity).** Assume $\mathrm{RR}(G)$. If $\deg D = g-1$ then $r(\operatorname{res}(D)) = r(D)$. Consequently, for every $r$, the involution $\operatorname{res}$ maps
$$\{\,[D] : \deg D = g-1,\ r(D) \ge r\,\}$$
onto itself.

*Proof.* Substituting $\deg D = g-1$ into $r(D) - r(K-D) = \deg D - g + 1$ gives $r(D) - r(K-D) = 0$. The second claim follows since $\operatorname{res}$ preserves degree $g-1$ by Proposition 7.2. $\square$

This is the precise content of the informal principle that *extremal half-canonical witnesses come in residual pairs*. It reduces any exhaustive search for witnesses to (at most) half the classes, together with the fixed classes — which have a classical description.

**Definition 7.4.** A divisor $D$ is a *theta characteristic* if $2D \sim K$, i.e. $D + D = K + \Delta f$ for some $f$.

**Theorem 7.5 (Fixed classes).** $D \sim \operatorname{res}(D)$ if and only if $D$ is a theta characteristic. Moreover every theta characteristic has degree $g-1$.

*Proof.* $D \sim K - D$ means $K - D = D + \Delta f$ for some $f$, i.e. $D + D = K - \Delta f = K + \Delta(-f)$, which is exactly $2D \sim K$. For the degree, $2\deg D = \deg K = 2g-2$. $\square$

**Corollary 7.6 (Unconditional identity at fixed classes).** If $D$ is a theta characteristic then $r(\operatorname{res}(D)) = r(D)$, with no appeal to $\mathrm{RR}(G)$: the two divisors are linearly equivalent, and rank is a class invariant.

**Theorem 7.7 (Theorem F; explicit self-dual witness).** Let $G$ be a simple $2j$-regular graph with $j \ge 3$. Then the constant divisor $D \equiv j - 1$ satisfies:
1. $2D = K$ exactly (so $D$ is a theta characteristic and $D \sim \operatorname{res}(D)$);
2. $\deg D = g-1$;
3. $r(D) \ge 3j - 4 \ge k - 1$, where $k = 2j$.

*Proof.* (1) $K \equiv 2j - 2 = 2(j-1)$, so $D + D = K$ on the nose (take $f = 0$). (2) is Theorem 7.5. (3) Apply Theorem 5.4 with $m = j-1 \ge 2$, $k = 2j$ (note $m \le k$), and $d = 3j-4$: we need $d + 1 = 3j-3 = 3m$ ✓ and $d = 3j - 4 \le k+m = 3j-1$ ✓. Finally $3j-4 \ge 2j-1 = k-1$ iff $j \ge 3$. $\square$

Thus for even $k \ge 6$ the half-canonical witness may be taken to be maximally symmetric: constant on the graph, and equal to its own residual. (The weaker version of this statement with rank $\ge 2j-2 = k-2$ follows already from Theorem 4.2 and holds for all $j \ge 2$.)

---

## 8. Brill–Noether arithmetic at the half-canonical degree

Classical Brill–Noether theory predicts the dimension of the family of linear systems of degree $d$ and rank $r$ on a genus-$g$ curve to be
$$\rho(g,d,r) \;=\; g - (r+1)(g - d + r).$$
Non-negativity of $\rho$ is the classical existence criterion on a general curve; negativity is the classical non-existence criterion.

**Lemma 8.1.** $\rho(g, g-1, r) = g - (r+1)^2$.

*Proof.* $g - (r+1)(g - (g-1) + r) = g - (r+1)(1+r) = g - (r+1)^2$. $\square$

The half-canonical degree is exactly the degree at which the Brill–Noether number becomes a perfect-square condition; this is the numerical shadow of the residual symmetry of §7.

**Theorem 8.2 (Theorem G; exact positivity criterion).** Let $G$ be $k$-regular on $n$ vertices. Then
$$\rho(g,\,g-1,\,k-1) \ \ge\ 1 \iff 2k^2 \ \le\ (k-2)\,n .$$

*Proof.* By Lemma 8.1 the left-hand side is $g - k^2 \ge 1$, i.e. $2g - 2 \ge 2k^2$. By Lemma 3.1, $2g-2 = (k-2)n$. $\square$

**Corollary 8.3 (Quadratic sufficiency).** If $k \ge 3$ and $n \ge 2k^2$ then $\rho(g,g-1,k-1) \ge 1$.

*Proof.* $(k-2)n \ge (k-2)\cdot 2k^2 \ge 2k^2$ since $k - 2 \ge 1$. $\square$

**Theorem 8.4 (Linear sufficiency).** If $k \ge 5$ and $n \ge 2k+7$ then $\rho(g,g-1,k-1) \ge 1$.

*Proof.* $(k-2)(2k+7) = 2k^2 + 3k - 14 \ge 2k^2$ because $3k \ge 15 > 14$. Monotonicity in $n$ finishes the argument. $\square$

**Corollary 8.5.** For $k \ge 3$, $2k+7 \le 2k^2$. Hence the linear threshold of Theorem 8.4 is strictly weaker than the quadratic one, and the quadratic scale $2k^2$ is *not* forced by the Brill–Noether count.

**Discussion 8.6.** Theorems 8.2–8.4 explain the provenance of the quadratic guess $N_0(k) \approx 2k^2$: it is the scale at which the expected *dimension* of the family of half-canonical rank-$(k-1)$ systems becomes positive. But a positive expected dimension is neither necessary nor sufficient for existence on a specific graph, and Theorem 6.2 shows just how far it is from necessary: the true threshold is $1$ for all $k \ge 6$, $k \ne 7$, while even the weakened linear criterion of Theorem 8.4 already needs $n \ge 2k+7$. The Brill–Noether count and the chip-firing construction are measuring different things; conflating them is precisely the error the quadratic guess encodes.

---

## 9. Computational evidence: sharpness and the case $k = 5$

Baker–Norine ranks on small graphs can be computed exactly, by reducing each candidate divisor to its $q$-reduced representative (a maximal-firing normal form obtained by Dhar's burning algorithm) and testing effectivity, then searching over all effective divisors of each degree in turn. The following are exact values obtained by exhaustive computation.

| Graph | $k$ | $n$ | $g$ | Divisor | $\deg$ | Rank | Set-firing bound $\min(3m-1,k+m)$ |
|---|---|---|---|---|---|---|---|
| $K_6$ | 5 | 6 | 10 | constant $2$ | 12 | **5** | $\min(5,7) = 5$ (attained) |
| $K_6$ | 5 | 6 | 10 | $(4,1,1,1,1,1)$ | $9 = g-1$ | **2** | — ($m=1$; Thm 4.2 gives $2$, attained) |
| $K_6$ | 5 | 6 | 10 | *all* of degree $9$ | $9 = g-1$ | **max $= 2$** | — |
| $K_7$ | 6 | 7 | 15 | constant $2$ | $14 = g-1$ | **5** | $\min(5,8) = 5$ (attained) |
| $K_8$ | 7 | 8 | 21 | $(6,2,2,2,2,2,2,2)$ | $20 = g-1$ | **5** | $\min(5,9)=5$ (attained) |
| $C_8(1,2,3)$ | 6 | 8 | 17 | constant $2$ | $16 = g-1$ | **5** | $\min(5,8)=5$ (attained) |
| $C_9(1,2,3)$ | 6 | 9 | 19 | constant $2$ | $18 = g-1$ | **5** | $\min(5,8)=5$ (attained) |
| $K_{5,5}$ | 5 | 10 | 16 | $(2,2,2,2,2,1,1,1,1,1)$ | $15 = g-1$ | **5** | — ($m=1$) |

Three conclusions.

**(a) The set-firing bound is attained, not merely approached.** In five of the rows the computed rank equals $3m-1$ exactly. In particular on $K_7$ the true rank is $5 = 3m-1$ while the competing term $k+m$ equals $8$: the minimum in Theorem 5.4 is realised by the $3m-1$ branch, which therefore cannot be removed. No refinement of *one-shot* firing with a uniform reserve can do better on these graphs.

**(b) At $k=7$ the shortfall is real.** On $K_8$ the natural witness of degree $g-1 = 20$ has rank exactly $5 = k-2$, one below the target $k-1 = 6$ — precisely the deficit predicted by Remark 6.3. Whether some *other* degree-$20$ divisor on $K_8$ attains rank $6$ is not settled by this computation.

**(c) At $k=5$ a genuine threshold is required.** An exhaustive search over *all* effective divisors of degree $9$ on $K_6$ — hence over all degree-$9$ classes of non-negative rank — finds maximal rank $2$, far below the target $k-1 = 4$. Therefore
$$N_0(5) \ >\ 6,$$
and the $k=5$ case, unlike $k \ge 6$ with $k \ne 7$, cannot hold with $N_0(5) = 1$. On the other hand $K_{5,5}$, also $5$-regular, carries a degree-$(g-1)$ divisor of rank $5 > 4$. So at $k=5$ the maximal half-canonical rank is not a function of $n$ alone, and any proof must select its witness using structural information about the graph.

---

## 10. Discussion and open problems

### 10.1 What was actually needed

The striking feature of Theorem 6.2 is how little machinery it consumes. No spectral hypothesis, no expansion, no bound on $n$, no probabilistic argument, no appeal to Riemann–Roch — a single firing of the complement of an explicitly described two-element set. The reason the problem looked hard is that the natural first move (Theorem 4.2) lands exactly one unit short for even $k$, and the natural first *estimate* (the Brill–Noether count, §8) suggests a quadratic threshold. Both are misleading. The obstruction of Theorem 3.2 tells us where the real difficulty is: it is not in finding enough chips, it is in moving them.

### 10.2 The residual degrees $k = 5$ and $k = 7$

**Problem 1.** Determine whether finite thresholds $N_0(5)$, $N_0(7)$ exist, and if so, bound them.

The computations of §9 make this concrete: $N_0(5) > 6$, so unlike the settled degrees the statement at $k=5$ is genuinely asymptotic. These are exactly the degrees where $\lfloor(k-2)/2\rfloor \in \{1,2\}$ and one-shot firing is too weak; they isolate the genuinely chip-firing-theoretic content of the problem. A natural approach is *iterated* set firing: allow a bounded sequence of moves, with the trouble set recomputed after each. The counting argument of Step 1 in Theorem 5.4 has an obvious multi-step analogue, but the cost accounting outside $S$ becomes considerably more delicate.

**Problem 2.** At $k=5$, characterise the $5$-regular graphs whose maximal half-canonical rank is small. The contrast between $K_6$ (rank $2$) and $K_{5,5}$ (rank $5$) suggests bipartiteness, girth, or expansion as candidate discriminants.

### 10.3 Sharpness

**Problem 3.** Show that for every $k \ge 5$ there are infinitely many $k$-regular graphs on which the uniform witness of Remark 6.4 has rank *exactly* $\min(3\lfloor(k-2)/2\rfloor - 1,\ k + \lfloor(k-2)/2\rfloor)$ — i.e. that Theorem 5.4 is asymptotically sharp for uniform witnesses and cannot be improved to $k+m$ by any refinement of one-shot firing.

Section 9 already exhibits attainment at $k = 5, 6, 7$; the content of Problem 3 is to produce infinite families, presumably among circulants or Cayley graphs.

### 10.4 Beyond uniform witnesses

Theorem 3.2 caps the reserve of a uniform witness at $\lfloor(k-2)/2\rfloor$, so any improvement past $3\lfloor(k-2)/2\rfloor-1$ must abandon uniformity. Two directions suggest themselves.

**Problem 4 (Expansion).** For every $\varepsilon > 0$ is there $C(\varepsilon)$ such that every connected $k$-regular graph with normalised spectral gap at least $\varepsilon$ and $n \ge C(\varepsilon)k$ carries a degree-$(g-1)$ divisor of rank at least $k-1$? Expansion should make chip redistribution uniform enough to replace counting by mixing; the interest is now concentrated on $k \in \{5,7\}$, where Theorem 6.2 is silent.

**Problem 5 (Probabilistic witnesses).** For fixed $k$, does the proportion of effective divisors of degree $g-1$ having rank at least $k-1$ tend to $1$ as $n \to \infty$, uniformly over simple connected $k$-regular graphs? A uniform counting statement of this kind would simultaneously prove existence and explain the insensitivity of the answer to the fine structure of the graph. The $K_6$ computation shows the statement cannot be made non-asymptotic.

### 10.5 Residual structure as a search reduction

Theorem 7.3 says the witness set at degree $g-1$ is invariant under $D \mapsto K-D$. Two consequences worth pursuing:

**Problem 6.** Exploit the involution algorithmically: an exhaustive search for half-canonical witnesses need only examine one class per residual pair, together with the theta characteristics. On a graph with Jacobian of order $|J|$, the number of theta characteristics is $|J[2]|$ when one exists, so the reduction is essentially by a factor of two.

**Problem 7.** For which graphs is the maximal half-canonical rank attained at a theta characteristic? Theorem 7.7 shows this happens for every even-regular graph with $k \ge 6$; the odd-regular case has no constant theta characteristic (the constant $(k-2)/2$ is not an integer) and the question is open.

---

## Appendix: summary of logical dependencies

- Theorem 4.2 (rank $\ge m+t$) depends only on Lemma 4.1 and effectivity bookkeeping.
- Theorem 5.4 (rank $\ge \min(3m-1,k+m)$) depends on Lemmas 5.2 and 5.3 and on the counting inequality (5.1); it is independent of Theorem 4.2.
- Theorem 6.1 combines Lemma 3.1, Lemma 3.5 and Theorem 5.4.
- Theorem 6.2 is Theorem 6.1 plus the parity computation.
- Theorem 7.7 combines Theorem 5.4 with Theorem 7.5.
- Only Theorem 7.3 (and its corollary on witness sets) uses the Riemann–Roch identity $\mathrm{RR}(G)$; every other result above is unconditional. In particular the main existence theorem, Theorem 6.2, does not use Riemann–Roch at all.
