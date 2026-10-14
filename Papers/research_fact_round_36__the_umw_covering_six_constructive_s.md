# The Divisibility-Covering Frontier: A Sandwich Theorem Around the Umans–Wang Target $(1/3,1/3)$

**Aristotle** (Harmonic)

*October 2026*

---

## Abstract

A pair of finite sets $S,T\subset\mathbb{Z}_{\ge 0}$ is a *divisibility covering* of $[n]=\{1,\dots,n\}$ if every $i\in[n]$ divides some positive difference $s-t$ with $s\in S$, $t\in T$, $t<s$. Umans and Wang have shown that coverings with $|S|,|T|\le n^{\beta}$ and elements at most $\exp(n^{\alpha})$, at the symmetric point $(\alpha,\beta)=(1/3,1/3)$, would improve the exponent of deterministic integer factoring from $1/5$ to $1/6$; they leave open whether the natural constraint $\alpha\ge 1-2\beta$ is achievable. We give a complete, elementary account of what is provable around this target. We prove (i) an explicit *counting wall* $4^k\le 2k\,M^{|S||T|}$ for every covering of $[2k]$ with elements at most $M$; (ii) the resulting *exponent constraint* $\alpha+\beta_S+\beta_T\ge 1$ for every asymptotically feasible triple; (iii) feasibility of the block-product covering for every $\alpha>1-\beta$ with $|T|=1$; hence (iv) the *one-sided frontier is exactly* $\alpha=1-\beta$; and (v) the *sandwich* at $\beta=1/3$: feasibility forces $\alpha\ge 1/3$, and every $\alpha>2/3$ is feasible. We also prove a large-prime budget $y^{\pi(n)-\pi(y)}\le M^{|S||T|}$, a resultant reformulation of the covering condition for disjoint integer sets, the necessity of the disjointness guard, and the correctness of the double-logarithmic unit $\ln\ln M/\ln n$ (the single-logarithmic reading diverges). Finally we report a negative experimental campaign — six construction families, fifteen independent adversarial reviews, zero genuine coverings at the target — and explain, via the sandwich, why the one empirical success at $(1/2,2/3)$ carries no information about the open interval $\alpha\in[1/3,2/3]$.

---

## 1. Introduction

### 1.1 Background

Deterministic integer factoring is far slower than its randomised counterpart. Algorithms in the Pollard–Strassen and Lehman lineage factor $N$ deterministically in time $N^{c+o(1)}$, and every improvement in $c$ is hard won. Umans and Wang (arXiv:2511.10851) isolated a purely combinatorial ingredient whose existence, in their framework, controls the exponent: a *divisibility covering* of an initial segment of the integers by the differences of two small sets of moderately sized numbers. In their parametrisation, coverings at $(\alpha,\beta)=(1/3,1/3)$ would yield exponent $1/6$, improving the exponent $1/5$. They record that a counting argument forces $\alpha\ge 1-2\beta$ and state that they do not know whether $\alpha=1-2\beta$ is achievable.

This paper is about the combinatorial problem alone. We do not construct a covering at $(1/3,1/3)$, and we do not refute one. What we do is establish, with complete proofs, the exact region surrounding the target, and separate three statements that are easily conflated:

1. a *trivial boundary* $\alpha+\beta\le 1+o(1)$ describing where elementary constructions live;
2. the *counting constraint* $\alpha\ge 1-2\beta$, which is the binding lower bound;
3. the *trivial covering point* $\alpha=1-\beta+o(1)$, which block products attain.

At $\beta=1/3$ the constraint gives $\alpha=1/3$ (with zero slack) and the trivial covering gives $\alpha=2/3$. The gap between them is precisely the open content.

### 1.2 Summary of results

- **Theorem A (Counting Wall).** If $S,T$ cover $[2k]$ ($k\ge 1$) and $s\le M$ for all $s\in S$, then $4^k\le 2k\,M^{|S||T|}$.
- **Theorem B (Exponent Constraint).** Every feasible triple $(\alpha,\beta_S,\beta_T)$ satisfies $\alpha+\beta_S+\beta_T\ge 1$.
- **Theorem C (Trivial Covering).** For $0<\beta\le 1$ and $\alpha>1-\beta$ the triple $(\alpha,\beta,0)$ is feasible.
- **Corollary D (One-Sided Frontier).** For $0<\beta\le1$: $(\alpha,\beta,0)$ feasible $\Rightarrow \alpha\ge 1-\beta$, and $\alpha>1-\beta \Rightarrow (\alpha,\beta,0)$ feasible.
- **Corollary E (Sandwich).** $(\alpha,\tfrac13,\tfrac13)$ feasible $\Rightarrow\alpha\ge\tfrac13$; and $\alpha>\tfrac23\Rightarrow(\alpha,\tfrac13,\tfrac13)$ feasible.
- **Proposition F (Large-Prime Budget).** For any covering of $[n]$ with elements $\le M$ ($M\ge1$) and any $y$: $y^{\pi(n)-\pi(y)}\le M^{|S||T|}$.
- **Proposition G (Resultant Bridge).** For disjoint integer sets covering $[n]$, $\operatorname{lcm}(1,\dots,n)$ divides the nonzero integer $\prod_{s\in S}\prod_{t\in T}(s-t)$.
- **Proposition H (Units).** $\ln\ln M/\ln n$ recovers $\alpha$ from $M=\exp(n^\alpha)$ and never exceeds $\alpha$ when $M\le\exp(n^\alpha)$; $\ln M/\ln n$ diverges.

Section 7 reports the experimental campaign.

---

## 2. Definitions

Throughout, $[n]=\{1,2,\dots,n\}$ and $\ln$ is the natural logarithm.

**Definition 2.1 (Divisibility covering).** Let $n\ge 0$ and let $S,T$ be finite sets of non-negative integers. We say $(S,T)$ *covers* $[n]$ if for every $i\in[n]$ there exist $s\in S$ and $t\in T$ with $t<s$ and $i\mid s-t$.

The strict inequality $t<s$ is the *disjointness guard*: the zero difference $s-s$ never counts. (Section 6 shows the guard cannot be dropped.) Covering is monotone: if $(S,T)$ covers $[m]$ and $n\le m$, it covers $[n]$.

**Definition 2.2 (Difference product).** The set of *positive pairs* is $P(S,T)=\{(s,t)\in S\times T: t<s\}$, and the *difference product* is
$$D(S,T)=\prod_{(s,t)\in P(S,T)}(s-t).$$
It is a positive integer (an empty product equals $1$), and $|P(S,T)|\le|S|\,|T|$.

**Definition 2.3.** $L_n=\operatorname{lcm}(1,2,\dots,n)$, a positive integer.

**Definition 2.4 (Feasibility).** A triple of reals $(\alpha,\beta_S,\beta_T)$ is *feasible* if for all sufficiently large $n$ there exist finite $S,T\subset\mathbb{Z}_{\ge0}$ with
$$|S|\le n^{\beta_S},\qquad |T|\le n^{\beta_T},\qquad s\le \exp(n^{\alpha})\ \ (s\in S),\qquad (S,T)\text{ covers }[n].$$

Only elements of $S$ are bounded; since only pairs with $t<s$ matter, elements of $T$ exceeding $\max S$ are useless and may be discarded, so no generality is lost. Feasibility is upward-closed: if $(\alpha,\beta_S,\beta_T)$ is feasible and $\alpha\le\alpha'$, $\beta_S\le\beta_S'$, $\beta_T\le\beta_T'$, then $(\alpha',\beta_S',\beta_T')$ is feasible (since $n\ge1$ makes $x\mapsto n^x$ non-decreasing).

**Remark 2.5 (The double-exponential unit).** The magnitude bound is $\exp(n^{\alpha})$, so $\alpha$ is a *double-exponential* parameter. For a construction whose largest element is $M$, the exponent it witnesses is
$$\alpha_{\mathrm{meas}}(n,M)=\frac{\ln\ln M}{\ln n}.$$
Proposition H makes precise that this, and not $\ln M/\ln n$, is the correct reading.

---

## 3. The counting wall

### 3.1 From covering to divisibility

**Lemma 3.1.** If $(S,T)$ covers $[n]$, then $L_n\mid D(S,T)$.

*Proof.* It suffices that each $i\in[n]$ divides $D(S,T)$. Choose $(s,t)$ with $t<s$ and $i\mid s-t$; then $(s,t)\in P(S,T)$, so $s-t$ is one of the factors of $D(S,T)$. $\square$

### 3.2 The central binomial coefficient divides the lcm

**Lemma 3.2.** For every $k\ge0$, $\binom{2k}{k}\mid L_{2k}$.

*Proof.* For $k=0$ both sides equal $1$. For $k\ge1$ compare $p$-adic valuations. By Legendre's formula,
$$v_p\!\binom{2k}{k}=\sum_{j\ge1}\left(\left\lfloor\frac{2k}{p^j}\right\rfloor-2\left\lfloor\frac{k}{p^j}\right\rfloor\right),$$
and each summand lies in $\{0,1\}$ and vanishes once $p^j>2k$. Hence $v_p\binom{2k}{k}\le\max\{j:p^j\le 2k\}$, i.e. $p^{v_p\binom{2k}{k}}\le 2k$. (Equivalently, by Kummer's theorem, $v_p\binom{2k}{k}$ is the number of carries when adding $k+k$ in base $p$, which is at most the number of base-$p$ digits of $2k$ minus one.) A prime power $p^e$ with $1\le p^e\le 2k$ is one of the integers $1,\dots,2k$, hence divides $L_{2k}$. Since this holds for every prime, $\binom{2k}{k}\mid L_{2k}$. $\square$

**Lemma 3.3.** For $k\ge1$, $4^k\le 2k\binom{2k}{k}$.

*Proof.* $4^k=\sum_{j=0}^{2k}\binom{2k}{j}$. The middle coefficient $\binom{2k}{k}$ is the largest; group the two end terms $\binom{2k}{0}+\binom{2k}{2k}=2\le\binom{2k}{k}$ together, leaving $2k$ groups, each at most $\binom{2k}{k}$. $\square$

**Lemma 3.4.** If $M\ge1$ and $s\le M$ for all $s\in S$, then $D(S,T)\le M^{|S||T|}$.

*Proof.* Each factor satisfies $0<s-t\le s\le M$, and there are $|P(S,T)|\le|S||T|$ factors; since $M\ge1$, $M^{|P|}\le M^{|S||T|}$. $\square$

### 3.3 The wall

**Theorem A (Counting Wall).** Let $k\ge1$. If $(S,T)$ covers $[2k]$ and every $s\in S$ satisfies $s\le M$, then
$$4^k\;\le\;2k\cdot M^{|S|\,|T|}.$$

*Proof.* Covering $1$ requires some $s\in S$ with $s>t\ge0$, so $M\ge s\ge1$. By Lemmas 3.2 and 3.1, $\binom{2k}{k}\mid L_{2k}\mid D(S,T)$, and $D(S,T)>0$, so $\binom{2k}{k}\le D(S,T)\le M^{|S||T|}$ by Lemma 3.4. Multiply by $2k$ and apply Lemma 3.3. $\square$

**Theorem A′ (Real form).** Let $n\ge2$ and suppose $(S,T)$ covers $[n]$ with $|S|\le n^{\beta_S}$, $|T|\le n^{\beta_T}$ and $s\le\exp(n^\alpha)$ for all $s\in S$. Then
$$(n-1)\ln2\;\le\;\ln n+n^{\alpha+\beta_S+\beta_T}.$$

*Proof.* Put $k=\lfloor n/2\rfloor\ge1$, so $2k\le n\le 2k+1$; by monotonicity $(S,T)$ covers $[2k]$. Let $M=\lfloor\exp(n^\alpha)\rfloor$; integrality of $s$ gives $s\le M$. Theorem A gives $4^k\le 2k\,M^{m}\le n\,\exp(n^\alpha)^{m}$ with $m=|S||T|$. Taking logarithms, $2k\ln2\le\ln n+m\,n^{\alpha}$. Now $2k\ge n-1$ and $m\,n^\alpha\le n^{\beta_S}n^{\beta_T}n^{\alpha}=n^{\alpha+\beta_S+\beta_T}$. $\square$

---

## 4. The exponent constraint

**Lemma 4.1.** If $\gamma<1$ then $\ln x+x^{\gamma}<(x-1)\ln2$ for all sufficiently large real $x$.

*Proof.* Let $c=\tfrac14\ln2$. Since $\ln x=o(x)$ and $x^{\gamma-1}\to0$, for large $x$ we have $\ln x\le cx$ and $x^\gamma\le cx$, so the left side is at most $\tfrac12 x\ln 2<(x-1)\ln2$ once $x>2$. $\square$

**Theorem B (Exponent Constraint).** If $\alpha+\beta_S+\beta_T<1$, then for all sufficiently large $n$ no pair $(S,T)$ with $|S|\le n^{\beta_S}$, $|T|\le n^{\beta_T}$ and $\max S\le\exp(n^\alpha)$ covers $[n]$. Consequently every feasible triple satisfies
$$\alpha+\beta_S+\beta_T\;\ge\;1.$$

*Proof.* Combine Theorem A′ with Lemma 4.1 at $\gamma=\alpha+\beta_S+\beta_T$: for large $n$ a covering would give $(n-1)\ln2\le\ln n+n^\gamma<(n-1)\ln2$. If the triple were feasible, for large $n$ coverings would exist and also be forbidden. $\square$

At $\beta_S=\beta_T=\beta$ this is Umans–Wang's constraint $\alpha\ge1-2\beta$.

**Interpretation.** The argument uses only that $L_n$ is exponentially large. The true size is $\ln L_n=\psi(n)\sim n$ by the prime number theorem, while the elementary bound via $\binom{2k}{k}$ gives $\ln L_n\ge n\ln2-O(\ln n)$; the difference affects constants but not exponents. At $(1/3,1/3,1/3)$ the inequality $\ln L_n\lesssim |S||T|\ln M$ reads $n\lesssim n^{1/3}\cdot n^{1/3}\cdot n^{1/3}$: the target saturates the bound.

---

## 5. Constructions and the frontier

### 5.1 Block products

For $L\ge1$ and $j\ge0$ let
$$B_L(j)=(jL+1)(jL+2)\cdots(jL+L),$$
a product of $L$ consecutive integers, and set
$$S_{n,L}=\{B_L(j):0\le j<\lceil n/L\rceil\},\qquad T=\{0\}.$$

**Lemma 5.1.** For $L\ge1$, $(S_{n,L},\{0\})$ covers $[n]$; moreover $|S_{n,L}|\le\lceil n/L\rceil$ and every element is at most $(n+L)^L$.

*Proof.* Given $i\in[n]$ let $j=\lfloor(i-1)/L\rfloor$; then $jL+1\le i\le jL+L$ and $j<\lceil n/L\rceil$, so $i\mid B_L(j)=B_L(j)-0$, and $0<B_L(j)$. For the size bound, the largest index has $jL+L\le\lceil n/L\rceil L\le n+L-1$, and $B_L(j)$ is a product of $L$ factors each at most $jL+L$. $\square$

**Lemma 5.2.** Let $0<\beta$ and $\alpha>1-\beta$. For all sufficiently large $x$: $x\ge1$, $x^\beta\ge2$, and $3x^{1-\beta}\ln(4x)\le x^\alpha$.

*Proof.* With $\delta=\alpha-(1-\beta)>0$, $\ln(4x)=\ln4+\ln x\le x^\delta/3$ for large $x$, because $\ln x=o(x^\delta)$ and $x^\delta\to\infty$. Multiply by $3x^{1-\beta}$. $\square$

**Theorem C (Trivial Covering).** If $0<\beta\le1$ and $\alpha>1-\beta$, then $(\alpha,\beta,0)$ is feasible.

*Proof.* For large $n$ (Lemma 5.2 at $x=n$) take $L=\lceil 2n^{1-\beta}\rceil$, so $2n^{1-\beta}\le L<2n^{1-\beta}+1\le 3n^{1-\beta}$ (as $n^{1-\beta}\ge1$); in particular $L\le 3n$, hence $n+L\le 4n$. Use $(S_{n,L},\{0\})$.

*Size of $S$:* writing $B=\lceil n/L\rceil$ we have $BL<n+L$. Since $n=n^{1-\beta}n^\beta$ and $n^\beta\ge2$, $n+L\le n^\beta L$ (because $n\le \tfrac12 n^\beta L$ and $L\le\tfrac12 n^\beta L$), so $BL<n^\beta L$ and $|S|\le B<n^\beta$.

*Size of $T$:* $|T|=1=n^0$.

*Magnitude:* every element is at most $(n+L)^L$, and
$$\ln\big((n+L)^L\big)=L\ln(n+L)\le 3n^{1-\beta}\ln(4n)\le n^\alpha.$$
Hence every element is at most $\exp(n^\alpha)$. $\square$

### 5.2 The one-sided frontier and the sandwich

**Corollary D (One-Sided Frontier).** For $0<\beta\le1$:
$$(\alpha,\beta,0)\ \text{feasible}\ \Longrightarrow\ \alpha\ge1-\beta,\qquad \alpha>1-\beta\ \Longrightarrow\ (\alpha,\beta,0)\ \text{feasible}.$$

*Proof.* The first implication is Theorem B with $\beta_T=0$; the second is Theorem C. $\square$

Thus with $|T|\le1$ nothing beats block products, up to the boundary point itself. **Any covering at $(1/3,1/3)$ must be genuinely two-sided**: the set $T$ must contribute a positive exponent's worth of counting budget.

**Corollary E (Sandwich at $\beta=1/3$).**
1. If $(\alpha,\tfrac13,\tfrac13)$ is feasible then $\alpha\ge\tfrac13$.
2. If $\alpha>\tfrac23$ then $(\alpha,\tfrac13,\tfrac13)$ is feasible.

*Proof.* (1) Theorem B: $\alpha+\tfrac23\ge1$. (2) Theorem C gives $(\alpha,\tfrac13,0)$ feasible; enlarge $\beta_T$ from $0$ to $\tfrac13$ by monotonicity. $\square$

The open content of the Umans–Wang question at $\beta=1/3$ is therefore exactly the interval
$$\alpha\in\left[\tfrac13,\tfrac23\right].$$

**Corollary 5.3 (The traded point is dominated).** $(\tfrac25,\tfrac23,0)$ is feasible, hence so is $(\tfrac12,\tfrac23,\tfrac23)$.

*Proof.* $\tfrac25>1-\tfrac23=\tfrac13$, so Theorem C applies; then use monotonicity. $\square$

---

## 6. Further structure

### 6.1 The large-prime budget

**Proposition F (Large-Prime Budget).** If $(S,T)$ covers $[n]$, $M\ge1$ and $s\le M$ for all $s\in S$, then for every $y\ge0$
$$y^{\,\#\{p\ \text{prime}:\ y<p\le n\}}\;\le\;M^{|S|\,|T|}.$$

*Proof.* Every prime $p\in(y,n]$ divides $L_n$, hence $D(S,T)$ (Lemma 3.1). Distinct primes are pairwise coprime, so their product divides $D(S,T)$. That product is at least $y^{\#}$, and $D(S,T)\le M^{|S||T|}$ (Lemma 3.4). $\square$

**Interpretation.** Take $y=n^{2/3}$ at the target. The left side has logarithm $(\pi(n)-\pi(n^{2/3}))\cdot\tfrac23\ln n\sim\tfrac23 n$, the right side $|S||T|\ln M\le n$. The large primes alone consume a constant fraction of the entire budget, and since there are about $n/\ln n$ of them spread over at most $n^{2/3}$ differences, a typical difference must carry on the order of $n^{1/3}/\ln n$ distinct primes from $(n^{2/3},n]$, each with near-perfect efficiency.

### 6.2 The resultant bridge

Extend Definition 2.1 to integers, dropping the order condition: integer sets $S,T\subset\mathbb{Z}$ *cover* $[n]$ if each $i\in[n]$ divides some $s-t$ with $s\in S$, $t\in T$. Put $P_T(X)=\prod_{t\in T}(X-t)\in\mathbb{Z}[X]$.

**Proposition G (Resultant Bridge).** If $S,T\subset\mathbb{Z}$ are disjoint and cover $[n]$, then
$$R(S,T)=\prod_{s\in S}P_T(s)=\prod_{s\in S}\prod_{t\in T}(s-t)$$
is a **nonzero** integer divisible by $L_n$.

*Proof.* The two products agree by evaluating $P_T$. Each $i\in[n]$ divides some factor $s-t$, hence divides $R$; thus $L_n\mid R$. Disjointness gives $s\ne t$ for all pairs, so every factor, and hence $R$, is nonzero. $\square$

Up to sign, $R(S,T)$ is the resultant $\operatorname{Res}(P_S,P_T)$ of the monic polynomials with root sets $S$ and $T$. The covering problem thus becomes a single divisibility between two integers, $L_n\approx e^{n}$ and $R(S,T)$ with $\ln|R|\le|S||T|\ln(2\max|S\cup T|)$, which at the target is of size $\exp(O(n))$: zero slack in the exponent.

### 6.3 The disjointness guard is essential

**Proposition 6.1.** For every $n$ and every integer $a$, the sets $S=T=\{a\}$ cover $[n]$ in the integer sense without the guard.

*Proof.* $s-t=0$ is divisible by every $i$. $\square$

So any search or argument that omits either disjointness (Proposition G) or the order condition $t<s$ (Definition 2.1) proves nothing. In Definition 2.1 the guard is built in.

### 6.4 Units

**Proposition H.** Let $n>1$.
1. $\dfrac{\ln\ln\exp(n^\alpha)}{\ln n}=\alpha$ for every real $\alpha$.
2. If $1<M\le\exp(n^\alpha)$ then $\dfrac{\ln\ln M}{\ln n}\le\alpha$.
3. If $\alpha>0$ then $\dfrac{\ln\exp(x^\alpha)}{\ln x}=\dfrac{x^\alpha}{\ln x}\to\infty$ as $x\to\infty$.

*Proof.* (1) $\ln\ln e^{n^\alpha}=\ln n^\alpha=\alpha\ln n$. (2) $\ln M\le n^\alpha$, and $\ln M>0$, so $\ln\ln M\le\alpha\ln n$. (3) $\ln x=o(x^\alpha)$. $\square$

For instance, with $M=\exp(n^{1/3})$ the correct reading is $1/3$ for every $n$, while the single-log reading is about $7.2$ at $n=10^6$ and about $362$ at $n=10^{12}$. A covering harness that reports $\ln M/\ln n$ is measuring something unrelated to $\alpha$.

---

## 7. Experimental campaign

The theoretical results above frame a negative experimental finding. We record it as an empirical report; none of the statements in this section is a theorem.

### 7.1 Protocol

Six construction families were implemented, each with a known-answer harness that checks the covering property on **all** of $[n]$ (composites included), enforces the guard $t<s$, and reports $\alpha$ in the double-logarithmic unit:

1. **Multi-scale difference covers**: classical difference-set constructions stacked at several scales.
2. **Smooth-number differences**: differences drawn from a factor base of small primes.
3. **Prime-power / valuation structure**: pairs $(s,t)$ arranged so that $s-t$ attains prescribed $p$-adic valuations.
4. **Interval and Cantor-type structured sets**: $S$ and $T$ with self-similar gap structure.
5. **Primorial arithmetic-progression assembly**: many of the arithmetic-progression building blocks from the Umans–Wang framework glued into a full covering.
6. **Lower-bound attempt**: an attempt to prove infeasibility at $(1/3,1/3,1/3)$.

Each run was examined by two independent adversarial reviewers who re-executed the harness.

### 7.2 Outcome

All fifteen adversarial verdicts concluded that no genuine covering at the target had been produced. Several runs had initially claimed more than they achieved; the reviews required those claims to be withdrawn, typically because the harness had (a) checked only primes rather than all of $[n]$, (b) allowed overlap $s=t$, or (c) reported $\alpha$ as $\ln M/\ln n$. The lower-bound attempt also failed: the counting argument places the target exactly on, not beyond, the boundary of Theorem B.

A disjointness-guarded greedy search provides a quantitative picture. At the traded point $(\alpha,\beta)=(\tfrac12,\tfrac23)$ it reaches full coverage $1.00$; at the target $(\tfrac13,\tfrac13)$ it reaches only $0.40$–$0.54$ over the tested range. Corollary 5.3 explains why the first number is uninformative: $(\tfrac12,\tfrac23,\tfrac23)$ lies inside the region already achieved by block products with $|T|=1$. Unstructured search never entered the open interval.

---

## 8. Algorithms

**Algorithm 1 (Covering verification).** Input $n,S,T$. Form the multiset of positive differences $\Delta=\{s-t: s\in S,t\in T,t<s\}$. For each $i=1,\dots,n$ test whether some $d\in\Delta$ has $d\equiv0\pmod i$. Output true iff all tests succeed. Cost: $O(n\,|S||T|)$ big-integer reductions. A faster equivalent test computes $D(S,T)\bmod L_n$, but note that $L_n\mid D$ is *necessary, not sufficient*: an index $i$ may divide $D$ without dividing any single difference. Only the per-index test certifies a covering.

**Algorithm 2 (Block-product construction).** Input $n,\beta$. Set $L=\lceil2n^{1-\beta}\rceil$, output $S=\{B_L(j):0\le j<\lceil n/L\rceil\}$, $T=\{0\}$. Cost: $O(n)$ multiplications of numbers of $O(n^{1-\beta}\log n)$ bits.

**Algorithm 3 (Wall test).** Input $(\alpha,\beta_S,\beta_T)$ and $n$. Evaluate $(n-1)\ln2-\ln n-n^{\alpha+\beta_S+\beta_T}$; if positive, no covering with these budgets exists at this $n$ (Theorem A′). This prunes experimental parameter grids before any search.

**Algorithm 4 (Unit-correct exponent).** Report $\alpha_{\mathrm{meas}}=\ln\ln M/\ln n$, computing $\ln M$ from the bit-length of $M$ to avoid overflow.

---

## 9. Discussion

**What the sandwich says.** The region of feasible triples is upward-closed and contained in the half-space $\alpha+\beta_S+\beta_T\ge1$. On the face $\beta_T=0$ it is known exactly: $\alpha\ge1-\beta_S$, with every strictly larger $\alpha$ attained. Off that face, the only known upper construction is still the one-sided one, so at $\beta_S=\beta_T=\tfrac13$ we know only $\tfrac13\le\alpha_{\min}\le\tfrac23$.

**What a solution would need.** By Corollary D, a covering at the target must make $T$ carry real weight. By Theorem B, it must waste essentially none of the counting budget $|S||T|\ln M$. By Proposition F, a positive proportion of differences must each absorb $\gg n^{1/3}/\ln n$ distinct large primes. By Proposition G, it amounts to making a single resultant of size $\exp(O(n))$ divisible by $L_n$. These are strong structural constraints, and they explain why generic search fails.

**Why the CRT approach is suspect.** The most natural two-sided idea is to choose each $s$ by the Chinese remainder theorem to satisfy $s\equiv t_k\pmod{Q_k}$ for a fixed list of $t_k\in T$ and pairwise coprime moduli $Q_k$. But such an $s$ has $\ln s\approx\sum_k\ln Q_k$: it pays in magnitude for every modulus it serves, exactly as a block product does. This motivates the conjecture below that CRT-built coverings collapse to the one-sided frontier.

**Both directions are significant.** Achieving $(1/3,1/3,1/3)$ would, by Umans–Wang, yield deterministic factoring in time $N^{1/6+o(1)}$. Proving that it is impossible would show that the counting constraint in their framework is not tight, which is equally new information.

---

## 10. Future directions

1. **Two-sided collapse for CRT coverings.** *Conjecture:* if every $s\in S$ is the CRT solution of $s\equiv t_k\pmod{Q_k}$ for a fixed list $(t_k)\subset T$ and pairwise coprime $Q_k$, then every feasible triple realised by such coverings satisfies $\alpha+\beta_S\ge1$. The approach: bound $\ln s$ by $\sum\ln Q_k$ and apply the counting wall with $T$ replaced by a singleton. A proof would exclude the most natural two-sided family below the trivial line.
2. **Resultant divisibility gap.** For disjoint $S,T$ with $|S|=|T|=n^{1/3}$ and entries at most $\exp(n^{1/3})$, determine whether $L_n\mid\operatorname{Res}(P_S,P_T)$ forces the differences to be pairwise almost coprime. The slack $\ln|R|-\ln L_n$ is now an explicit quantity.
3. **Large-prime allocation.** Show that in any covering at $(1/3,1/3)$ a positive proportion of the $n^{2/3}$ differences carry $\gg n^{1/3}/\ln n$ distinct primes in $(n^{2/3},n]$; study the equality cases of Proposition F.
4. **Unit-correct harnesses.** Every experimental harness should report $\ln\ln M/\ln n$; reporting $\ln M/\ln n$ overstates $\alpha$ without bound (Proposition H).

---

## 11. Conclusion

The Umans–Wang divisibility covering at $(1/3,1/3)$ sits exactly on the counting wall $\alpha+\beta_S+\beta_T\ge1$, while the best construction, block products, sits on the one-sided frontier $\alpha=1-\beta$, which we have shown to be sharp for one-sided coverings. The open problem is precisely the interval $\alpha\in[1/3,2/3]$ at $\beta=1/3$. Six construction families and fifteen adversarial reviews produced no covering inside that interval, and the counting machinery produces no obstruction either. The door is open, and hard, in both directions.

---

### Reference

C. Umans and S. Wang, arXiv:2511.10851.
