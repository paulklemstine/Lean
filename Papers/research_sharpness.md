# Sharpness of the Finite Moment Problem on a Bounded Alphabet

**Rigidity, the one-dimensional kernel, and the minimal collision size $m(N,K)$**

*Aristotle*

---

## Abstract

Let $N \ge 1$ and consider weight systems $w = (w_0,\dots,w_N) \in \mathbb{R}^{N+1}$ on the node set $\{0,1,\dots,N\}$, with power sums (moments) $S_k(w)=\sum_{i=0}^N w_i i^k$. We give a complete rigidity/sharpness analysis of the reconstruction problem $w \mapsto (S_0(w),\dots,S_K(w))$.

We prove: (i) **rigidity** — the moments of orders $k \le N$ determine $w$; (ii) **sharpness** — for every $K < N$ there are two distinct probability distributions on $\{0,\dots,N\}$ whose moments agree in all orders $k \le K$, namely the even and odd halves of the normalised binomial weights; (iii) a **structure theorem** — two weight systems agreeing in all orders $k < N$ differ by a scalar multiple of the alternating binomial vector $i \mapsto (-1)^i \binom{N}{i}$, so the space of moment-invisible signals is exactly one-dimensional; (iv) the resulting **exact gap and total-variation identities** $S_N(w)-S_N(v)=(w_0-v_0)(-1)^N N!$ and $\|w-v\|_1 = |w_0-v_0| 2^N$, and the **extremal separation** $|S_N(w)-S_N(v)| \le N!/2^{N-1}$ for probability distributions, attained by the binomial halves; and (v) a **stability estimate** with the $\ell^1$ norms of Lagrange coefficient vectors as constants.

Turning to integer data (multisets), a second, independent rigidity mechanism — Newton's identities — gives determination from the moments of orders $k \le n$ for a multiset of size $n$, whence the exact threshold $\min(N,n)$. We package the sharpness data into a single invariant, the **minimal collision size** $m(N,K)$: the least cardinality of a multiset $s$ with entries $\le N$ such that some $t \ne s$ has the same power sums in all orders $k \le K$. We prove: $m(N,K)=0$ (no collision) exactly when $N \le K$; the Prouhet–Tarry–Escott floor $K < m(N,K)$; antitonicity in $N$ and monotonicity in $K$; the exact critical value $m(N,N-1)=2^{N-1}$; the uniform Prouhet ceiling $m(N,K) \le 2^K$ on the whole non-rigid range, via a doubling lemma yielding the Thue–Morse pairs; and the reduction to disjoint collisions. Finally we compute the invariant exactly in small degree: $m(N,1)=2$ ($N \ge 2$), the complete table $m(N,2) \in \{0,4,3\}$, $m(N,3)=4$ ($N \ge 7$), $m(N,4)=5$ ($N \ge 18$), $m(N,5)=6$ ($N \ge 16$). Hence the PTE floor is attained in every degree $K \le 5$. The narrow multiset witnesses used exhibit minimal ideal alphabets $d(3)=7$, $d(4)=18$, $d(5)=16$ — in particular $d$ is **not monotone** in the degree.

**Keywords:** moment problem, power sums, Vandermonde, Newton's identities, Prouhet–Tarry–Escott, Thue–Morse, alternating binomial identity, minimal collision size.

---

## 1. Introduction

### 1.1 The problem

The moment problem asks to what extent a measure is determined by its moments. On the real line the classical answers (Hamburger, Stieltjes, Hausdorff) concern infinite moment sequences and analytic growth conditions. On a *finite* node set the question becomes finite-dimensional and combinatorial: how many moments does one need, exactly, and what goes wrong one moment short?

Fix $N \ge 1$ and let the nodes be $0, 1, \dots, N$. A **weight system** is a vector $w = (w_0,\dots,w_N) \in \mathbb{R}^{N+1}$; we write

$$S_k(w) \;=\; \sum_{i=0}^{N} w_i \, i^k, \qquad k \ge 0,$$

for its **power sums**, with the convention $0^0 = 1$, so $S_0(w) = \sum_i w_i$ is total mass. Special cases of interest:

* $w_i \ge 0$ and $S_0(w)=1$: a probability distribution on $\{0,\dots,N\}$;
* $w_i \in \mathbb{Z}_{\ge 0}$: the multiplicity vector of a finite multiset ("data set") of naturals bounded by $N$, whose power sums are $\sum_{x \in s} x^k$.

Two questions organise the paper.

**Q1 (Rigidity/sharpness).** For which $K$ does $(S_0,\dots,S_K)$ determine $w$? What is the exact structure of the failure when $K$ is too small?

**Q2 (Cost of a collision).** In the integer setting, if the moments up to order $K$ fail to determine the data set, how *large* must an ambiguous data set be?

Question Q1 has a clean and complete answer (Sections 2–4). Question Q2 leads to a numerical invariant $m(N,K)$ (Section 6) which interpolates between two classical circles of ideas: the exponential $2^{N-1}$ threshold coming from the alternating binomial kernel, and the Prouhet–Tarry–Escott problem of ideal power-sum equalities.

### 1.2 Summary of results

| Statement | Content |
|---|---|
| Rigidity | moments of orders $k \le N$ determine $w$ on $\{0,\dots,N\}$ |
| Sharpness | for each $K<N$: two distinct probability distributions agreeing up to $K$ |
| Structure | kernel of the "moments below order $N$" map is $\mathbb{R} \cdot \big((-1)^i \binom{N}{i}\big)_i$ |
| Gap identity | $S_N(w)-S_N(v)=(w_0-v_0)(-1)^N N!$ under agreement below $N$ |
| Total variation | $\|w-v\|_1=|w_0-v_0| \, 2^N$ under agreement below $N$ |
| Extremal separation | $|S_N(w)-S_N(v)| \le N!/2^{N-1}$ for probability distributions; attained |
| Stability | $|w_j-v_j| \le \Lambda_{N,j}\varepsilon$ if all moments agree within $\varepsilon$ |
| Newton threshold | a multiset of size $n$ is determined by orders $k \le n$ |
| Exact threshold | a multiset of size $n$ with entries $\le N$ is determined by orders $k \le \min(N,n)$ |
| Sandwich | $K < m(N,K) \le 2^K$ for $K<N$ |
| Critical value | $m(N,N-1) = 2^{N-1}$ |
| Small degrees | $m(N,1)=2$, $m(N,2)$ table, $m(N,3)=4$, $m(N,4)=5$, $m(N,5)=6$ |

---

## 2. Rigidity: the Vandermonde mechanism

The first mechanism is linear algebra on the *alphabet*.

**Lemma 2.1 (Moment expansion).** *Let $s$ be a finite index set, $v : s \to \mathbb{R}$ any family of nodes, $d : s \to \mathbb{R}$ any weights, and $p$ a polynomial with $\deg p < |s|$. Then*
$$\sum_{i \in s} d_i \, p(v_i) \;=\; \sum_{k=0}^{|s|-1} \big([X^k]p\big) \sum_{i \in s} d_i \, v_i^{\,k}.$$

*Proof.* Write $p=\sum_k ([X^k]p) X^k$, evaluate at $v_i$, multiply by $d_i$ and exchange the two finite sums. $\square$

**Theorem 2.2 (Vandermonde vanishing).** *Let $v : s \to \mathbb{R}$ be injective on a finite set $s$ and $d : s \to \mathbb{R}$ satisfy $\sum_{i \in s} d_i v_i^{\,k} = 0$ for all $k < |s|$. Then $d \equiv 0$ on $s$.*

*Proof.* Fix $j \in s$ and let $L_j$ be the Lagrange basis polynomial for the nodes $(v_i)_{i \in s}$: $\deg L_j = |s|-1 < |s|$, $L_j(v_j)=1$, $L_j(v_i)=0$ for $i \ne j$. Lemma 2.1 applied to $p = L_j$ turns the left-hand side into a combination of the vanishing moments, so $\sum_{i} d_i L_j(v_i) = 0$; but that sum collapses to $d_j$. $\square$

**Theorem 2.3 (Rigidity of the finite moment problem).** *If $w, v \in \mathbb{R}^{N+1}$ satisfy $S_k(w)=S_k(v)$ for all $k \le N$, then $w = v$.*

*Proof.* Apply Theorem 2.2 to $s=\{0,\dots,N\}$, nodes $v_i = i$ (injective as reals) and weights $d_i = w_i - v_i$; the hypotheses give $\sum_i d_i i^k = S_k(w)-S_k(v) = 0$ for all $k < |s| = N+1$. $\square$

The proof is constructive: expanding the $j$-th Lagrange polynomial gives the explicit inversion formula

$$w_j \;=\; \sum_{k=0}^{N} \big([X^k]L_j\big)\, S_k(w), \qquad L_j(X)=\prod_{i \ne j}\frac{X-i}{j-i}. \tag{2.1}$$

---

## 3. The alternating binomial functional and the structure of the failure

The second half of the story is the exact description of what agreement *below* order $N$ permits. Everything follows from one identity.

For $N \ge 0$ define the functional
$$\Delta_N(f) \;=\; \sum_{i=0}^{N} (-1)^i \binom{N}{i} f(i), \qquad f : \mathbb{N} \to \mathbb{R}.$$

**Lemma 3.1 (Pascal telescoping).** *For every $N$ and every $f$,*
$$\Delta_{N+1}(f) \;=\; -\,\Delta_N\big(f(\cdot+1)-f(\cdot)\big).$$

*Proof.* Split $\binom{N+1}{i}=\binom{N}{i}+\binom{N}{i-1}$ in the sum defining $\Delta_{N+1}$ and re-index the second part by $i \mapsto i+1$; the alternating signs convert the two halves into $\Delta_N(f)$ and $-\Delta_N(f(\cdot+1))$. $\square$

**Theorem 3.2 (Alternating-sum identity).** *For every polynomial $p$ with $\deg p \le N$,*
$$\sum_{i=0}^{N} (-1)^i \binom{N}{i} p(i) \;=\; (-1)^N \, N!\ [X^N]p .$$

*Proof.* Induction on $N$. For $N=0$ both sides are $p(0)=[X^0]p$. For the step, apply Lemma 3.1: the finite difference $q(X)=p(X+1)-p(X)$ has $\deg q \le N-1$ when $\deg p \le N$, and its top coefficient satisfies $[X^{N-1}]q = N\,[X^N]p$ (expand $(X+1)^N-X^N$). Then $\Delta_{N}(p) = -\Delta_{N-1}(q) = -(-1)^{N-1}(N-1)!\,[X^{N-1}]q = (-1)^N N!\,[X^N]p$. $\square$

Two specialisations are used repeatedly:

$$\Delta_N(i \mapsto i^k) = 0 \quad (k<N), \qquad \Delta_N(i \mapsto i^N) = (-1)^N N!. \tag{3.1}$$

**Theorem 3.3 (Structure theorem for near-collisions).** *Let $w,v \in \mathbb{R}^{N+1}$ satisfy $S_k(w)=S_k(v)$ for all $k<N$. Then*
$$w_i - v_i \;=\; (w_0-v_0)\,(-1)^i\binom{N}{i} \qquad (0 \le i \le N).$$

*Proof.* Put $c = w_0-v_0$ and $e_i = (w_i-v_i) - c(-1)^i\binom{N}{i}$; then $e_0 = 0$. By hypothesis and by (3.1) both parts of $e$ have vanishing $k$-th moments for every $k<N$, so $\sum_{i=0}^{N} e_i i^k = 0$ for $k<N$. Because $e_0=0$, these are $N$ moment conditions on the $N$ nodes $1,2,\dots,N$; Theorem 2.2 forces $e_i=0$ for $1 \le i \le N$, and $e_0=0$ by construction. $\square$

Thus the kernel of the map $w \mapsto (S_0(w),\dots,S_{N-1}(w))$ is exactly the line spanned by the alternating binomial vector — a one-parameter family of moment-invisible signed measures, and none at all one order later.

**Corollary 3.4 (Exact gap).** *Under the hypotheses of Theorem 3.3,*
$$S_N(w)-S_N(v) \;=\; (w_0-v_0)\,(-1)^N N! .$$

*Proof.* Substitute the structure theorem into $S_N(w)-S_N(v)=\sum_i (w_i-v_i) i^N$ and apply (3.1). $\square$

Corollary 3.4 reproves Theorem 2.3 independently of Lagrange interpolation: agreement at order $N$ as well forces $w_0=v_0$, hence $w=v$ by Theorem 3.3.

**Corollary 3.5 (Total variation).** *Under the hypotheses of Theorem 3.3, $\sum_{i=0}^{N}|w_i-v_i| = |w_0-v_0|\,2^N$.*

*Proof.* Take absolute values in Theorem 3.3 and use $\sum_i \binom{N}{i}=2^N$. $\square$

---

## 4. Sharpness, extremal separation, stability

### 4.1 The binomial halves

For $N \ge 1$ define two weight systems on $\{0,\dots,N\}$:

$$E_N(i) = \begin{cases}\binom{N}{i}/2^{N-1}, & i \text{ even},\\ 0, & i \text{ odd},\end{cases} \qquad O_N(i) = \begin{cases}0, & i \text{ even},\\ \binom{N}{i}/2^{N-1}, & i \text{ odd}.\end{cases}$$

Both are non-negative; since the even-index and odd-index binomial coefficients of row $N$ each sum to $2^{N-1}$, both have total mass $1$. Their difference is
$$E_N(i)-O_N(i) = \frac{(-1)^i \binom{N}{i}}{2^{N-1}},$$
so by (3.1) they agree in all moments of order $k<N$, while $E_N(0)=2^{1-N} \ne 0 = O_N(0)$ shows they are distinct.

**Theorem 4.1 (Sharpness of the range $k \le N$).** *For every $N \ge 1$ and every $K<N$ there exist two distinct probability distributions on $\{0,1,\dots,N\}$ whose power sums agree in all orders $k \le K$ and differ at order $N$: namely $E_N$ and $O_N$, with*
$$S_N(E_N)-S_N(O_N) \;=\; \frac{(-1)^N N!}{2^{N-1}} \ne 0 .$$

*Proof.* Agreement below order $N$ was just shown; the gap value is Corollary 3.4 with $w_0-v_0 = 2^{1-N}$. $\square$

Consequently the window $k \le N$ of Theorem 2.3 cannot be shortened by a single order. The case $N=2$ is the classical minimal example: the multisets $\{0,2\}$ and $\{1,1\}$ have equal cardinality and equal sums but different sums of squares.

### 4.2 The extremal constant

**Theorem 4.2 (Extremal separation).** *Let $w,v$ be probability distributions on $\{0,\dots,N\}$ ($N \ge 1$) with $S_k(w)=S_k(v)$ for all $k<N$. Then*
$$\big|S_N(w)-S_N(v)\big| \;\le\; \frac{N!}{2^{N-1}},$$
*with equality for $w=E_N$, $v=O_N$.*

*Proof.* By Corollary 3.5, $|w_0-v_0|2^N = \|w-v\|_1 \le \|w\|_1+\|v\|_1 = 2$, so $|w_0-v_0| \le 2^{1-N}$. Corollary 3.4 gives $|S_N(w)-S_N(v)| = |w_0-v_0|\,N! \le N!/2^{N-1}$. Equality is Theorem 4.1. $\square$

The constant decays superexponentially in the sense that it is $N!/2^{N-1}$ *relative to unit total mass*; interpreted the other way round, it says that distinguishing two moment-matched distributions at the final order requires resolving a quantity of size only $N!/2^{N-1}$ — tiny for small $N$, and only large for $N \gtrsim 5$.

### 4.3 Stability

Rigidity is a statement about exact data. The inversion formula (2.1) upgrades it to a quantitative one. Define the **stability constant** at node $j$ as the $\ell^1$ norm of the coefficient vector of the $j$-th Lagrange polynomial,
$$\Lambda_{N,j} \;=\; \sum_{k=0}^{N}\big|[X^k]L_j\big|.$$

**Theorem 4.3 (Stability).** *If $|S_k(w)-S_k(v)| \le \varepsilon$ for all $k \le N$, then $|w_j - v_j| \le \Lambda_{N,j}\,\varepsilon$ for every $j \le N$.*

*Proof.* Apply Lemma 2.1 to $p = L_j$ and $d = w - v$: the left side collapses to $w_j-v_j$, the right side is $\sum_k ([X^k]L_j)(S_k(w)-S_k(v))$, and the triangle inequality bounds it by $\Lambda_{N,j}\varepsilon$. $\square$

Theorem 2.3 is the case $\varepsilon = 0$. The constants grow rapidly: $\max_j \Lambda_{N,j}$ equals $2, 3, 6, 10, 20, 35$ for $N = 1,\dots,6$ (these are central binomial coefficients $\binom{N}{\lfloor N/2\rfloor}$-type quantities), so moment inversion is exponentially ill-conditioned — the finite analogue of the notorious instability of the classical moment problem.

---

## 5. Integer data and the second rigidity mechanism

We now restrict to multisets ("data sets") $s$ of natural numbers, with power sums $P_k(s)=\sum_{x \in s} x^k$; the multiplicity vector of $s$ is a weight system, and $P_k(s) = S_k(\text{mult}(s))$ whenever $s$ has entries $\le N$.

**Theorem 5.1 (Rigidity, multiset form).** *If $s,t$ are multisets of naturals with entries $\le N$ and $P_k(s)=P_k(t)$ for all $k \le N$, then $s=t$.*

*Proof.* Multiplicity vectors are weight systems; apply Theorem 2.3 and compare multiplicities node by node (multiplicities of letters $>N$ vanish on both sides by hypothesis). $\square$

The alphabet is not the only source of rigidity. Newton's identities give a second mechanism, controlled by the *size* of the data set.

**Theorem 5.2 (Newton's identity, multiset form).** *For a multiset $s$ of reals and $k \ge 1$,*
$$P_k(s) \;=\; (-1)^{k+1}\,k\, e_k(s) \;-\; \sum_{\substack{a+b=k \\ 0<a<k}} (-1)^{a} e_a(s)\, P_b(s),$$
*where $e_a(s)$ denotes the $a$-th elementary symmetric function of the entries of $s$.*

*Proof.* Enumerate $s$ as $f : \{1,\dots,n\} \to \mathbb{R}$ and specialise the identity between power-sum and elementary symmetric polynomials in $n$ variables. $\square$

**Corollary 5.3.** *If $s,t$ are multisets of reals with $P_k(s)=P_k(t)$ for $1 \le k \le n$, then $e_k(s)=e_k(t)$ for all $k \le n$.*

*Proof.* Strong induction on $k$ using Theorem 5.2: the recursion expresses $k\,e_k$ in terms of $P_k$ and the lower $e_a, P_b$. $\square$

**Theorem 5.4 (Size threshold).** *If $s,t$ are multisets of reals of the same cardinality $n$ and $P_k(s)=P_k(t)$ for $1 \le k \le n$, then $s=t$.*

*Proof.* By Corollary 5.3 the two monic polynomials $\prod_{x \in s}(X-x)$ and $\prod_{x \in t}(X-x)$, whose coefficients are the $\pm e_k$, coincide; their root multisets are $s$ and $t$. $\square$

For multisets of naturals the cardinality is itself the $0$-th power sum, so:

**Theorem 5.5 (Determination by size).** *If $P_k(s)=P_k(t)$ for all $k \le |s|$, then $s=t$ (no bound on the entries needed).*

Combining the two mechanisms:

**Theorem 5.6 (Exact threshold $\min(N,|s|)$).** *If $s,t$ are multisets of naturals with entries $\le N$ and $P_k(s)=P_k(t)$ for all $k \le \min(N,|s|)$, then $s=t$.*

*Proof.* If $N \le |s|$ use Theorem 5.1, otherwise Theorem 5.5. $\square$

Restated contrapositively, Theorem 5.5 is the classical **Prouhet–Tarry–Escott lower bound**:

**Corollary 5.7 (PTE floor).** *If $s \ne t$ and $P_k(s)=P_k(t)$ for all $k \le K$, then $|s| > K$.*

---

## 6. The invariant $m(N,K)$

### 6.1 Definition and basic properties

**Definition 6.1.** For $N,K \in \mathbb{N}$, a **collision** with parameters $(N,K)$ is a pair of multisets $s \ne t$ of naturals with all entries $\le N$ and $P_k(s)=P_k(t)$ for every $k \le K$. Define
$$m(N,K) \;=\; \min\{\,|s| : (s,t)\text{ is a collision with parameters }(N,K)\,\},$$
with $m(N,K)=0$ by convention when no collision exists.

(Note that $P_0(s)=P_0(t)$ forces $|s|=|t|$, so the two sides of a collision always have the same cardinality.)

**Theorem 6.2 (Existence/non-existence).** *Collisions with parameters $(N,K)$ exist if and only if $K<N$; equivalently $m(N,K)=0 \iff N \le K$.*

*Proof.* If $N \le K$, Theorem 5.1 forbids collisions. If $K<N$, the even/odd binomial halves provide one (Theorem 6.6 below). $\square$

**Theorem 6.3 (Sandwich).** *For $K<N$,*
$$K \;<\; m(N,K) \;\le\; 2^{K}.$$

The lower bound is Corollary 5.7 applied to a minimising collision. The upper bound is Theorem 6.9 below.

**Theorem 6.4 (Monotonicity).** *(i) For $K<N \le N'$, $m(N',K) \le m(N,K)$: widening the alphabet can only cheapen collisions. (ii) For $K' \le K < N$, $m(N,K') \le m(N,K)$: demanding more orders of agreement can only make collisions more expensive.*

*Proof.* (i) A collision over $\{0,\dots,N\}$ is one over $\{0,\dots,N'\}$. (ii) A collision at order $K$ is one at order $K'$. $\square$

**Theorem 6.5 (Minimal collisions are disjoint).** *If $(s,t)$ is a collision with parameters $(N,K)$, then so is $(s-t,\,t-s)$, and $(s-t)\cap(t-s)=\varnothing$. Consequently $m(N,K)$ is also the least size of a collision whose two sides share no element.*

*Proof.* For any multisets $u,v$ and any $k$, $P_k(u-v)+P_k(u\cap v)=P_k(u)$. Subtracting the two instances $(u,v)=(s,t)$ and $(t,s)$, and using $s \cap t = t \cap s$, converts $P_k(s)=P_k(t)$ into $P_k(s-t)=P_k(t-s)$ for every $k \le K$. If $s-t=t-s$ then adding back the common part gives $s=t$, a contradiction; disjointness of the two differences is immediate from $\mathrm{mult}_x(u-v)=\max(\mathrm{mult}_x u - \mathrm{mult}_x v, 0)$. Finally $|s-t| \le |s|$, so minimality is preserved. $\square$

Theorem 6.5 is what makes exhaustive computation of $m(N,K)$ tractable: one may restrict the search to disjoint pairs.

### 6.2 The critical window: $m(N,N-1)=2^{N-1}$

**Theorem 6.6 (Lower bound at the critical window).** *Let $N \ge 1$, and let $s \ne t$ be multisets with entries $\le N$ and $P_k(s)=P_k(t)$ for all $k<N$. Then $|s| \ge 2^{N-1}$.*

*Proof.* Let $w,v$ be the multiplicity vectors. By Theorem 3.3, $w-v = c \cdot \big((-1)^i\binom{N}{i}\big)_i$ with $c = w_0-v_0$, and $c \ne 0$ (otherwise $w=v$). Since $w,v$ are integer vectors, $c$ is a nonzero integer, so $|c| \ge 1$. By Corollary 3.5, $\|w-v\|_1 = |c| 2^N \ge 2^N$. On the other hand $\|w-v\|_1 \le \|w\|_1 + \|v\|_1 = |s|+|t| = 2|s|$. Hence $|s| \ge 2^{N-1}$. $\square$

**Theorem 6.7 (The bound is attained).** *For every $N \ge 1$ the multisets*
$$\mathcal{E}_N = \{\, i \text{ repeated } \tbinom{N}{i} \text{ times} : i \le N \text{ even} \,\}, \qquad \mathcal{O}_N = \{\, i \text{ repeated } \tbinom{N}{i} \text{ times} : i \le N \text{ odd} \,\}$$
*are distinct, have entries $\le N$, satisfy $P_k(\mathcal{E}_N)=P_k(\mathcal{O}_N)$ for all $k<N$, and $|\mathcal{E}_N|=|\mathcal{O}_N|=2^{N-1}$.*

*Proof.* Their multiplicity vectors are $2^{N-1}E_N$ and $2^{N-1}O_N$; agreement below order $N$ is Section 4.1 rescaled, cardinality is the sum of the even (resp. odd) entries of row $N$ of Pascal's triangle, and $0 \in \mathcal{E}_N$, $0 \notin \mathcal{O}_N$ gives distinctness. $\square$

**Corollary 6.8 (Critical value).** *For every $N \ge 1$, $m(N,N-1)=2^{N-1}$.*

For example $m(2,1)=2$, $m(3,2)=4$, $m(4,3)=8$, $m(8,7)=128$.

### 6.3 The Prouhet ceiling

**Lemma 6.9 (Shifted power sums).** *For a multiset $t$ of naturals and $M,k \in \mathbb{N}$,*
$$P_k\big(t+M\big) \;=\; \sum_{j=0}^{k} P_j(t)\binom{k}{j}M^{k-j},$$
*where $t+M$ denotes the multiset of all $y+M$ with $y \in t$.*

*Proof.* Binomial expansion of $(y+M)^k$, summed over $y \in t$. $\square$

**Theorem 6.10 (Doubling lemma).** *Let $s,t$ be multisets of naturals with $P_k(s)=P_k(t)$ for all $k \le K$, and let $M$ be any natural number. Then*
$$P_k\big(s \cup (t+M)\big) \;=\; P_k\big(t \cup (s+M)\big) \qquad \text{for all } k \le K+1 .$$

*Proof.* By Lemma 6.9 the two sides are
$$P_k(s)+\sum_{j\le k}P_j(t)\binom{k}{j}M^{k-j} \quad\text{and}\quad P_k(t)+\sum_{j\le k}P_j(s)\binom{k}{j}M^{k-j}.$$
If $k \le K$ all the $P_j$ appearing agree termwise. If $k = K+1$, the terms with $j \le K$ agree, and the two remaining terms are $P_{K+1}(s) + P_{K+1}(t)\binom{K+1}{K+1}M^0 = P_{K+1}(s)+P_{K+1}(t)$ on the left and the same sum on the right. Equality holds in both cases. $\square$

The cancellation is structural: the construction *swaps* the two sides before shifting, so the unmatched top-order contributions appear symmetrically.

**Definition 6.11 (Prouhet pairs).** Set $(\mathcal{P}_0^+, \mathcal{P}_0^-) = (\{0\},\{1\})$ and
$$\big(\mathcal{P}_{K+1}^+, \mathcal{P}_{K+1}^-\big) = \big(\mathcal{P}_K^+ \cup (\mathcal{P}_K^- + 2^{K+1}),\; \mathcal{P}_K^- \cup (\mathcal{P}_K^+ + 2^{K+1})\big).$$

**Theorem 6.12 (Prouhet–Thue–Morse).** *For every $K$: $\mathcal{P}_K^\pm \subseteq \{0,1,\dots,2^{K+1}-1\}$, $|\mathcal{P}_K^+|=|\mathcal{P}_K^-|=2^K$, $\mathcal{P}_K^+ \ne \mathcal{P}_K^-$, and $P_k(\mathcal{P}_K^+)=P_k(\mathcal{P}_K^-)$ for all $k \le K$. Concretely $\mathcal{P}_K^+$ is the set of naturals below $2^{K+1}$ with an even number of $1$'s in binary — the Thue–Morse partition.*

*Proof.* Induction on $K$ using Theorem 6.10 with $M=2^{K+1}$; the shift by $2^{K+1}$ keeps entries below $2^{K+2}$ and preserves disjointness, and $0 \in \mathcal{P}_K^+$, $0 \notin \mathcal{P}_K^-$ throughout gives distinctness. $\square$

For example $\mathcal{P}_3^+=\{0,3,5,6,9,10,12,15\}$ and $\mathcal{P}_3^-=\{1,2,4,7,8,11,13,14\}$ have equal counts, sums, sums of squares and sums of cubes.

**Theorem 6.13 (Prouhet ceiling).** *If $2^{K+1}-1 \le N$ then $m(N,K) \le 2^K$. More strongly, $m(N,K) \le 2^K$ for every $K<N$.*

*Proof.* The first claim is Theorem 6.12. For the second, take $N=K+1$: by Corollary 6.8, $m(K+1,K)=2^{K}$; antitonicity in the alphabet (Theorem 6.4(i)) gives $m(N,K) \le m(K+1,K)=2^K$ for all $N \ge K+1$. $\square$

This completes the sandwich $K < m(N,K) \le 2^K$ of Theorem 6.3, with the right-hand bound attained exactly at the critical window $K=N-1$ and strictly loose elsewhere (e.g. $m(N,2)=3<4$ for $N \ge 4$).

---

## 7. Exact values in small degree

We call a collision **ideal** if it attains the PTE floor, i.e. $|s|=K+1$ at agreement order $K$. Write $d(K)$ for the least $D$ such that an ideal collision of degree $K$ fits in the alphabet $\{0,\dots,D\}$.

**Lemma 7.1 (Transfer from a witness).** *Let $s \ne t$ be multisets with entries $\le D$, $|s|=K+1$, and $P_k(s)=P_k(t)$ for all $k \le K$. Then $m(N,K)=K+1$ for every $N \ge D$ (assuming $K<D$).*

*Proof.* The witness gives $m(N,K) \le K+1$ by monotonicity of the alphabet; the PTE floor gives $m(N,K) \ge K+1$. $\square$

Similarly, a non-ideal witness of size $n$ inside $\{0,\dots,D\}$ yields $m(N,K) \le n$ for all $N \ge D$.

### 7.1 Degrees $1$ and $2$

**Theorem 7.2.** *$m(N,1)=2$ for all $N \ge 2$.* Witness: $\{0,2\}$ versus $\{1,1\}$ (counts $2$, sums $2$; squares $4 \ne 2$).

**Theorem 7.3.** *$m(N,2)=3$ for all $N \ge 4$.* Witness: $\{0,3,3\}$ versus $\{1,1,4\}$ (counts $3$, sums $6$, squares $18$; cubes $54 \ne 66$).

**Theorem 7.4 (Complete profile at $K=2$).**
$$m(N,2)=\begin{cases}0, & N \le 2,\\ 4, & N=3,\\ 3, & N \ge 4.\end{cases}$$

*Proof.* $N \le 2$ is Theorem 6.2; $N=3$ is the critical window (Corollary 6.8, $2^2=4$); $N \ge 4$ is Theorem 7.3. $\square$

So at $K=2$ the invariant falls from the ceiling $2^K=4$ straight to the floor $K+1=3$, with no intermediate value, as soon as one letter is added beyond the critical alphabet. Equivalently $d(2)=4$.

### 7.2 Degrees $3$, $4$, $5$: narrow multiset witnesses

The classical ideal PTE solution of degree $3$ is the *set* solution $\{0,4,7,11\}$ versus $\{1,2,9,10\}$, which requires $D=11$. Allowing repeated entries produces markedly narrower ideal solutions.

**Theorem 7.5 (Degree $3$, diameter $7$).** *The multisets $\{1,1,6,6\}$ and $\{0,3,4,7\}$ have four elements each, entries $\le 7$, and equal power sums of orders $0,1,2,3$:*
$$4,\quad 14,\quad 74,\quad 434,$$
*while at order $4$ they differ: $2594 \ne 2738$. Consequently $m(N,3)=4$ for every $N \ge 7$.*

**Theorem 7.6 (Degree $4$, diameter $18$).** *The multisets $\{0,4,8,16,17\}$ and $\{1,2,10,14,18\}$ have five elements each, entries $\le 18$, and equal power sums of orders $0,\dots,4$:*
$$5,\quad 45,\quad 625,\quad 9585,\quad 153409,$$
*differing at order $5$ ($2502225 \ne 2527425$). Consequently $m(N,4)=5$ for every $N \ge 18$.*

**Theorem 7.7 (Degree $5$, diameter $16$).** *The multisets $\{0,3,5,11,13,16\}$ and $\{1,1,8,8,15,15\}$ have six elements each, entries $\le 16$, and equal power sums of orders $0,\dots,5$:*
$$6,\quad 48,\quad 580,\quad 7776,\quad 109444,\quad 1584288,$$
*differing at order $6$ ($23391940 \ne 23305540$). Consequently $m(N,5)=6$ for every $N \ge 16$.*

Each of these is a finite verification of $K+2$ integer identities together with Lemma 7.1.

**Theorem 7.8 (The PTE floor is attained in every degree $K \le 5$).** *For each $K$ with $1 \le K \le 5$ there exists $N>K$ with $m(N,K)=K+1$; explicitly, $N=2,4,7,18,16$ works for $K=1,2,3,4,5$.*

An exhaustive search over disjoint pairs confirms that these alphabets are minimal, i.e.
$$d(1)=2,\qquad d(2)=4,\qquad d(3)=7,\qquad d(4)=18,\qquad d(5)=16 .$$

**Remark 7.9 (Non-monotonicity of $d$).** $d(5)=16 < 18 = d(4)$: the degree-$5$ ideal problem admits a *narrower* solution than the degree-$4$ one. The mechanism is visible in the witnesses: the degree-$5$ solution uses three doubled entries $\{1,1,8,8,15,15\}$ on one side, exploiting an arithmetic symmetry unavailable to the (essentially rigid) degree-$4$ configurations.

### 7.3 The descent between ceiling and floor

Between the critical alphabet $N=K+1$, where $m=2^K$, and the ideal alphabet $N=d(K)$, where $m=K+1$, the invariant descends through intermediate values. Two explicit witnesses:

**Proposition 7.10.** *$\{1,1,1,4,4,4\}$ and $\{0,2,2,3,3,5\}$ have six elements each, entries $\le 5$, and equal power sums $6,15,51,195$ of orders $0,1,2,3$, differing at order $4$ ($771 \ne 819$). Hence $m(N,3) \le 6 < 8 = 2^3$ already for $N \ge 5$ — two letters below the ideal threshold $d(3)=7$.*

**Proposition 7.11.** *$\{1,1,1,5,6,6,8\}$ and $\{0,2,2,3,7,7,7\}$ have seven elements each, entries $\le 8$, and equal power sums $7,28,164,1072,7316$ of orders $0,\dots,4$, differing at order $5$ ($51448 \ne 50728$). Hence $m(N,4) \le 7 < 16 = 2^4$ already for $N \ge 8$ — ten letters below $d(4)=18$.*

Exhaustive search over disjoint pairs gives the complete degree-$3$ descent:
$$m(4,3)=8,\qquad m(5,3)=6,\qquad m(6,3)=6,\qquad m(7,3)=4,$$
a genuine staircase rather than the single cliff observed at $K=2$.

**Proposition 7.12 (Profile at $N=8$).** $m(8,1)=2$, $m(8,2)=3$, $m(8,3)=4$, $m(8,4)\le 7$, $m(8,7)=128$.

The last entry is the critical window and shows that the exponential ceiling remains exactly attained arbitrarily far out, even as the invariant sits near the floor for all smaller $K$.

---

## 8. Algorithms

Three computational tasks arise; we record their structure and cost.

### 8.1 Moment inversion

**Input:** $S_0,\dots,S_N$. **Output:** $w_0,\dots,w_N$.
Solve the Vandermonde system $V w = S$, $V_{k,i}=i^k$, by exact rational Gaussian elimination, or by (2.1) with precomputed Lagrange coefficients. Cost $O(N^3)$ (or $O(N^2)$ using the standard Vandermonde solver). Conditioning is governed by $\Lambda_{N,j}$ of Theorem 4.3 and degrades exponentially, so exact arithmetic is strongly preferable.

### 8.2 Exhaustive computation of $m(N,K)$

**Input:** $N$, $K$, a size cap. **Output:** $m(N,K)$.
By Theorem 6.5 it suffices to search *disjoint* pairs. For $n = K+1, K+2, \dots$, enumerate all multisets of size $n$ with entries in $\{0,\dots,N\}$ (there are $\binom{N+n}{n}$ of them), compute the signature $(P_0,\dots,P_K)$ of each, bucket by signature, and report the first $n$ for which some bucket contains two distinct, element-disjoint multisets. Cost $O\big(\binom{N+n}{n} \cdot (K+1)\big)$ signature evaluations plus the within-bucket comparisons, which are negligible because collisions are rare. The floor $K<m$ justifies starting at $n=K+1$, and the ceiling $m \le 2^K$ bounds the loop.

### 8.3 Prouhet doubling

**Input:** $K$. **Output:** a collision of degree $K$ with $2^K$ elements per side.
Start from $(\{0\},\{1\})$ and iterate $(s,t) \mapsto (s \cup (t+2^{j+1}),\, t \cup (s+2^{j+1}))$ for $j=0,\dots,K-1$. Cost $O(2^K)$ arithmetic operations, output size $2^{K+1}$. Correctness is Theorem 6.10. The output is exactly the Thue–Morse split of $\{0,\dots,2^{K+1}-1\}$, so one may equally generate it by binary digit-sum parity in $O(2^K)$ time with no recursion.

---

## 9. Applications and interpretation

**Sketching and streaming.** Power sums are the canonical constant-space summary of a data stream over a bounded alphabet. Theorem 5.6 states the exact price of fidelity: $\min(N,n)$ moments, where $N$ bounds the alphabet and $n$ the sample size — never more, and (Theorem 4.1) never fewer.

**Adversarial forgery.** If a summary consisting of moments up to order $K$ is published, the invariant $m(N,K)$ is precisely the size of the smallest data set whose summary can be forged. Theorem 6.6 says that at the critical window $K=N-1$ forgery requires $2^{N-1}$ items — exponentially expensive; Theorems 7.5–7.7 say that one further letter of alphabet can collapse the cost to $K+1$. The security of a moment-based summary therefore depends sharply on the *relation* between the alphabet size and the number of published moments, not on either quantity alone.

**Ill-posedness of moment inversion.** Theorem 4.3 quantifies the classical folklore that moment reconstruction is unstable: the amplification factors $\Lambda_{N,j}$ grow exponentially in $N$. Theorem 4.2 gives the complementary extremal statement: two moment-matched probability distributions can be separated at the final order by no more than $N!/2^{N-1}$, and this is attained.

**Prouhet–Tarry–Escott.** The invariant refines the PTE problem. The classical question — does an ideal solution of degree $K$ exist? — is the question whether $m(N,K)=K+1$ for some $N$. Our results answer it affirmatively for $K \le 5$ with explicit narrow witnesses, and add the quantitative dimension $d(K)$: how much room does an ideal solution need? Allowing multisets rather than sets is essential to the narrowness: at degree $3$ the best set solution has diameter $11$ and the best multiset solution has diameter $7$.

**Combinatorics of Thue–Morse.** The doubling lemma explains, in the simplest possible terms, why the Thue–Morse sequence solves power-sum equalities: it is the unique fixed point of the swap-and-shift operation that adds one order of agreement for free. The classical fair-division interpretation ("you take, I take, I take, you take") is the same recursion.

---

## 10. Open problems and future work

1. **The minimal ideal alphabet $d(K)$.** Determine $d(K)$ for $K \ge 6$, or bound it. Is $d(K)$ eventually monotone? The data $d(3)=7$, $d(4)=18$, $d(5)=16$ rule out monotonicity outright. Is $d(K)$ even finite for all $K$? (Ideal PTE solutions are known only up to degree $11$, with degree $10$ open, so finiteness of $d$ is at least as hard as the PTE existence problem.)
2. **The descent profile.** For fixed $K$, describe the full function $N \mapsto m(N,K)$ on $K+1 \le N \le d(K)$. At $K=2$ the descent is a single step; at $K=3$ it is $8,6,6,4$. Is the descent always unimodal/monotone, and are all intermediate values of the form $2^{K}-j$ for small $j$?
3. **Sharp constants for stability.** Identify $\Lambda_{N,j}$ in closed form for the equispaced nodes $0,1,\dots,N$, and determine $\max_j \Lambda_{N,j}$ asymptotically. Numerically the maxima $2,3,6,10,20,35$ for $N=1,\dots,6$ suggest a central-binomial growth rate $\sim \binom{N}{\lfloor N/2 \rfloor}$.
4. **Weighted/real-node generalisations.** Everything in Sections 2–4 holds for arbitrary pairwise distinct real nodes; the alternating binomial kernel is special to equispaced nodes. What replaces the vector $(-1)^i\binom{N}{i}$, the constant $2^N$, and the gap $N!$ for general node sets? (For general nodes, the kernel at order $N-1$ is spanned by the reciprocals of the derivative of the node polynomial, which recovers the binomial vector in the equispaced case.)
5. **Higher-dimensional alphabets.** For data in $\{0,\dots,N\}^d$ with multivariate moments, is there an analogous exact threshold and a corresponding one-dimensional kernel at the critical multi-degree?

---

## 11. Conclusion

The finite moment problem on the alphabet $\{0,1,\dots,N\}$ admits a complete and unusually clean description. Reconstruction succeeds exactly with the moments of orders $0$ through $N$; one order short, the failure is a single one-parameter family generated by the alternating binomial vector, and everything about it — the gap $(-1)^N N!$ at the critical order, the total variation $2^N$, the extremal separation $N!/2^{N-1}$, the exponential collision cost $2^{N-1}$ — is computed exactly by one identity, $\sum_i (-1)^i \binom{N}{i}p(i)=(-1)^N N! [X^N]p$.

For integer data a second mechanism, Newton's identities, contributes the complementary threshold $\min(N,n)$ and the Prouhet–Tarry–Escott floor. Packaging the sharpness data into the invariant $m(N,K)$ organises the whole picture into a single sandwich $K < m(N,K) \le 2^K$, tight on the right at the critical window and tight on the left — as we show by explicit narrow ideal witnesses — in every degree up to $5$. What lies between remains the interesting part.
