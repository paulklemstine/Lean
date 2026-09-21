# The Battery Capacity Law: Saturation of the Label-Information Curve at the Label-Entropy Ceiling

**Author:** Aristotle
**Date:** 2026-09-20

---

## Abstract

We study the *label capacity curve* of a growing battery of finite-valued measurements
("dials") read against a label on a finite population. For a nested chain of sub-batteries
$S_1 \subseteq \cdots \subseteq S_n$ we consider $I(k) = I(K_{S_k}; L)$, the counting mutual
information between the joint reading of $S_k$ and the label $L$, its additive comparison
$\sum_{i \in S_k} I(k_i; L)$, and the *deficit* $D(k)$ between them. We establish four
structural laws. (i) **Ceiling:** $I(K;L) \le H(L)$ for every reading $K$, with the slack
equal to the conditional entropy $H(L \mid K)$. (ii) **Saturation:** equality holds if and only
if the reading determines the label, and strictly fails as soon as the reading confuses two
differently labelled individuals; quantitatively, if an $m$-valued auxiliary statistic
disambiguates the label, the gap is at most $\log m$. (iii) **Monotonicity:** the curve is
non-decreasing along the chain — a data-processing statement for mutual information, which we
derive from *strong subadditivity of the counting entropy*, $H(u,v,w) + H(u) \le H(u,v) +
H(u,w)$, proved from scratch by a single Gibbs inequality against the conditional product
reference $q(a,b,c) = n(a,b)\,n(a,c)/(n(a)N)$. (iv) **Synergy and its boundary:** if a new dial
is statistically independent of the existing joint reading — the situation produced by pairwise
coprime conductors through the Chinese Remainder Theorem — the deficit is non-decreasing, and
strictly increasing at a dial that completes the classifier; without independence the law is
false, and a two-element population with a duplicated one-bit dial has deficit $-1$ bit. We
further prove an exact vanishing theorem: if an involution of the population preserves every
dial but flips a binary label, that label's capacity is identically zero at every battery size.
Finally, we verify that a measured six-dial capacity curve, rising to $99.6\%$ of its ceiling
with a monotonically compounding deficit, is consistent with all of these laws, and we
reinterpret the residual $0.4\%$ as a bound on per-cell label ambiguity rather than as an
uninterpreted percentage.

**Keywords:** counting entropy, mutual information, strong subadditivity, Gibbs inequality,
capacity curve, information synergy, Chinese Remainder Theorem, factor blindness.

---

## 1. Introduction

### 1.1 The phenomenon

Consider a finite population of objects, each carrying a hidden *label*, and a collection of
cheap measurements, each of which reports a residue modulo some fixed integer. Call each
measurement a **dial** and a set of dials a **battery**. Individually a dial is nearly
useless: it partitions the population into a handful of large cells. Collectively, if the
moduli are pairwise coprime, the Chinese Remainder Theorem welds them into a single
measurement of very large modulus, and the battery becomes a fine-grained instrument.

An experiment along these lines, run with six dials of pairwise coprime conductors and combined
modulus $31 \cdot 23 \cdot 9 \cdot 8 \cdot 5 \cdot 11$ against a label on a population of
pairs, produced the following capacity curve (all values in bits):

| $k$ | $I(k)$ | $\sum$ marginals | $D(k)$ | ceiling | % of ceiling |
|---|---|---|---|---|---|
| 1 | 1.0011 | 1.0011 | $+0.0000$ | — | — |
| 2 | 2.1334 | 2.0020 | $+0.1314$ | 4.6063 | 46% |
| 3 | 4.0242 | 2.4777 | $+1.5465$ | 6.4947 | 62% |
| 4 | 8.2412 | 3.9120 | $+4.3292$ | 9.5434 | 86% |
| 5 | 11.5307 | 5.1591 | $+6.3716$ | 11.9557 | 96% |
| 6 | 12.7235 | 5.3650 | $+7.3585$ | 12.7726 | 99.6% |

Three empirical patterns are visible: the curve rises; the deficit — the gap between the joint
information and the sum of the single-dial informations — compounds monotonically, reaching a
factor of $3.7$ at six dials; and the curve presses against a ceiling given by the joint label
entropy, reaching $99.6\%$ of it. A fourth measurement, of a binary *which-factor* label, read
$0.3594$ bits against a permutation null of $0.3591$ ($z = +0.11$): no signal at all, unchanged
from four dials to six.

### 1.2 Contributions

This paper converts those patterns into theorems and, in one case, into a counterexample.

1. A finitary, purely combinatorial information calculus on finite populations (Section 2),
   with no probability space: entropy is a function of cell counts.
2. **The ceiling theorem** and its exact slack identity (Section 3).
3. **The saturation theorem**: the ceiling is attained *exactly* under determination, with a
   strict-deficit converse and a quantitative $\log m$ bound (Section 4).
4. **Strong subadditivity of the counting entropy**, proved from a single Gibbs inequality
   (Section 5), and the consequent **monotonicity of the capacity curve** (Section 6).
5. **The synergy law** under independence, the guarded monotone-deficit law, strictness at the
   completing dial, and a concrete counterexample showing the unguarded law is false
   (Section 7).
6. **The exact vanishing theorem for symmetric batteries** (Section 8), with a non-vacuous
   witness, explaining the which-factor wall as an identity rather than a small number.
7. Consistency of the measured table with all of the above, and reinterpretation of the
   $99.6\%$ figure (Section 9).

---

## 2. The counting calculus

Throughout, $\Omega$ is a finite non-empty set — the **population** — of size
$N = |\Omega|$. A **statistic** is a function $f : \Omega \to A$ into an arbitrary set of
readings. No probability measure is assumed anywhere: all quantities below are functions of
the cell counts of $f$.

**Definition 2.1 (fibre, image, count).** For a statistic $f$ and a value $a$, the *fibre* is
$f^{-1}(a) \subseteq \Omega$, the *count* is $n_f(a) = |f^{-1}(a)|$, and the *image*
$\operatorname{img} f$ is the finite set of values actually attained.

**Definition 2.2 (counting entropy).** With $\varphi(N, n) = -\frac{n}{N}\log\frac{n}{N}$ for
$n \ge 1$ and $\varphi(N,0) = 0$,

$$H(f) \;=\; \sum_{a \in \operatorname{img} f} \varphi\big(N, n_f(a)\big)
\;=\; -\sum_{a \in \operatorname{img} f} \frac{n_f(a)}{N} \log \frac{n_f(a)}{N}
\quad\text{(nats)},$$

and $H_2(f) = H(f)/\log 2$ in bits. Equivalently, $H(f)$ is the Shannon entropy of the
uniform distribution on $\Omega$ pushed forward by $f$; we work with counts directly because
every proof below is then a finite identity or inequality about integers and logarithms.

**Definition 2.3 (joint statistic, mutual information).** For statistics $f : \Omega \to A$,
$g : \Omega \to B$, the *joint* statistic is $(f,g) : x \mapsto (f(x), g(x))$, and

$$I(f;g) \;=\; H(f) + H(g) - H(f,g), \qquad I_2(f;g) = I(f;g)/\log 2.$$

We record the elementary facts on which everything rests.

**Lemma 2.4 (coarsening).** If $f = r \circ g$ for some map $r$ of value sets, then
$H(f) \le H(g)$; the inequality is an equality when $r$ is injective on $\operatorname{img} g$,
and is strict whenever $r$ identifies two values attained by $g$ on individuals that $g$
separates.

*Proof sketch.* Each cell of $f$ is a disjoint union of cells of $g$, and
$\varphi(N, m_1 + m_2) \le \varphi(N,m_1) + \varphi(N,m_2)$ with equality only when one of
$m_1, m_2$ vanishes, by concavity of $t \mapsto -t\log t$ / superadditivity of
$t \mapsto t \log(1/t)$. $\square$

**Lemma 2.5 (subadditivity).** $H(f,g) \le H(f) + H(g)$; consequently $I(f;g) \ge 0$.

*Proof sketch.* Gibbs' inequality against the product reference $q(a,b) = \frac{n_f(a)}{N}
\cdot \frac{n_g(b)}{N}$, which is a probability weight on pairs. $\square$

**Lemma 2.6 (projections).** $H(f) \le H(f,g)$ and $H(g) \le H(f,g)$, since each coordinate is
a coarsening of the pair. Also $H(g,f) = H(f,g)$, as the swap of coordinates is injective.

**Lemma 2.7 (constants and non-constants).** A constant statistic has $H = 0$. If $f(x) \ne
f(y)$ for some $x, y$, then $H(f) > 0$.

*Proof sketch.* The first is the single-cell computation $\varphi(N,N) = 0$. For the second,
the constant coarsening of $f$ collapses two separated individuals, so by the strict case of
Lemma 2.4, $0 = H(\text{const}) < H(f)$. $\square$

**Definition 2.8 (dial, battery, joint reading).** A **dial** on $\Omega$ is a statistic
$k : \Omega \to \{0, \dots, m-1\}$ for some modulus $m \ge 1$. A **battery** indexed by a
finite set $\iota$ is a family $d = (d_i)_{i \in \iota}$ of dials. For $S \subseteq \iota$, the
**joint reading** $K_S : \Omega \to \mathbb{Z}^S$ is $K_S(x) = (d_i(x))_{i \in S}$.

The defining structural fact about joint readings is that for $S \subseteq T$ the reading $K_S$
factors through $K_T$ by coordinate restriction: $K_S = \rho_{T \to S} \circ K_T$.

**Definition 2.9 (capacity curve, deficit).** For a battery $d$, a sub-battery $S$ and a label
$L : \Omega \to \Lambda$,

$$\mathrm{cap}(S) \;=\; I(K_S ; L), \qquad
D(S) \;=\; \mathrm{cap}(S) - \sum_{i \in S} I(d_i ; L).$$

Along a nested chain $S_1 \subseteq \cdots \subseteq S_n$ we write $I(k) = \mathrm{cap}(S_k)$
and $D(k) = D(S_k)$.

---

## 3. The ceiling

**Theorem 3.1 (Ceiling).** For every statistic $K$ and every label $L$ on a finite population,
$$I(K;L) \;\le\; H(L).$$
In particular $\mathrm{cap}(S) \le H(L)$ for every sub-battery $S$, of any size.

*Proof.* By Lemma 2.6, $H(K) \le H(K,L)$. Substituting into $I(K;L) = H(K) + H(L) - H(K,L)$
gives $I(K;L) \le H(L)$. $\square$

**Proposition 3.2 (Exact slack).** $H(L) - I(K;L) = H(K,L) - H(K)$.

*Proof.* Immediate from the definition of $I$. $\square$

The right-hand side is the conditional entropy $H(L \mid K)$ in the counting calculus: it is a
weighted average over the cells $c$ of $K$ of the entropy of the labels inside cell $c$,

$$H(L\mid K) \;=\; \sum_{c} \frac{n_K(c)}{N}\, H\big(L \restriction K^{-1}(c)\big).$$

Thus the ceiling gap is exactly the residual within-cell label ambiguity. This identity is the
interpretive engine of the whole paper: a percentage of ceiling is a statement about how many
distinct labels survive inside a typical cell of the joint reading.

---

## 4. Saturation

**Theorem 4.1 (Saturation).** For any statistic $K$ and label $L$,
$$I(K;L) = H(L) \iff \big(\forall x, y \in \Omega\big)\ \big(K(x) = K(y) \Rightarrow L(x) = L(y)\big),$$
i.e. the ceiling is attained precisely when the reading determines the label.

*Proof.* ($\Leftarrow$) If $K$ determines $L$ then $L$ factors as $L = r \circ K$ for some map
$r$ (defined on $\operatorname{img} K$ by choosing any preimage; well defined by hypothesis).
Hence $(K,L) = (\mathrm{id}, r)\circ K$ has the same cells as $K$: $H(K,L) = H(K)$, and
$I(K;L) = H(K) + H(L) - H(K) = H(L)$.

($\Rightarrow$) Suppose $K(x) = K(y)$ but $L(x) \ne L(y)$. Then the pair statistic $(K,L)$
separates $x$ and $y$ while its coarsening $K$ does not, so by the strict case of Lemma 2.4,
$H(K) < H(K,L)$, whence $I(K;L) = H(K) + H(L) - H(K,L) < H(L)$. $\square$

**Corollary 4.2 (Strict sub-saturation).** If a battery confuses two individuals with distinct
labels, then $\mathrm{cap}(S) < H(L)$ strictly.

Theorem 4.1 is the precise content of the phrase *the curve saturates at the label-entropy
ceiling*: saturation is an all-or-nothing event triggered by perfect classification, never by
accumulation alone. It also shows that no finite sequence of additional dials can push the
curve to the ceiling unless it eliminates every surviving confusion.

The next result converts "how close to the ceiling" into "how ambiguous".

**Theorem 4.3 (Quantitative saturation).** Let $K$ be a reading, $L$ a label, and suppose there
is a statistic $g : \Omega \to \{1, \dots, m\}$ such that $L$ is a function of $(K, g)$: some
$r$ satisfies $L(x) = r(K(x), g(x))$ for all $x$. Then

$$H(L) - I(K;L) \;\le\; \log m.$$

*Proof.* Since $(K,L)$ is a coarsening of $(K,g)$ — apply $(c, u) \mapsto (c, r(c,u))$ — Lemma
2.4 gives $H(K,L) \le H(K,g)$. Subadditivity (Lemma 2.5) gives $H(K,g) \le H(K) + H(g)$, and
$H(g) \le \log|\operatorname{img} g| \le \log m$ by the maximum-entropy bound. Combining with
Proposition 3.2, $H(L) - I(K;L) = H(K,L) - H(K) \le H(g) \le \log m$. $\square$

With $m = 1$, Theorem 4.3 recovers the "$\Leftarrow$" half of Theorem 4.1. In the other
direction, it is the right tool for reading the measured $99.6\%$: a gap of $0.049$ bits means
that any disambiguating auxiliary statistic must have at least $2^{0.049} \approx 1.035$
effective values — i.e. the surviving ambiguity is confined to a small fraction of the
population, since a fully ambiguous binary distinction anywhere in bulk would cost close to a
whole bit.

---

## 5. Strong subadditivity of the counting entropy

The monotonicity of the capacity curve is a statement about a *difference* of entropies and is
not accessible from Lemmas 2.4–2.6. We prove the required inequality directly in the counting
calculus.

**Theorem 5.1 (Strong subadditivity).** For any statistics $u, v, w$ on a finite population,
$$H(u,v,w) + H(u) \;\le\; H(u,v) + H(u,w).$$

*Proof.* Write $N = |\Omega|$ and abbreviate cell counts by $n(a) = n_u(a)$,
$n(a,b) = n_{(u,v)}(a,b)$, $n(a,c) = n_{(u,w)}(a,c)$ and $n(a,b,c) = n_{(u,v,w)}(a,b,c)$. Put

$$p(a,b,c) = \frac{n(a,b,c)}{N}, \qquad
q(a,b,c) = \frac{n(a,b)}{N}\cdot\frac{n(a,c)}{N}\Big/\frac{n(a)}{N}
= \frac{n(a,b)\, n(a,c)}{n(a)\,N}.$$

Two marginalisation identities hold by fibre-wise partition of the population:
$\sum_c n(a,b,c) = n(a,b)$, $\sum_b n(a,b,c) = n(a,c)$, and hence
$\sum_{b,c} n(a,b,c) = n(a)$.

*Step 1: $q$ is a probability weight.* Summing $q$ over $b$ and $c$ for fixed $a$ with
$n(a) > 0$ gives $\frac{1}{n(a)N}\big(\sum_b n(a,b)\big)\big(\sum_c n(a,c)\big)
= \frac{n(a)^2}{n(a)N} = \frac{n(a)}{N}$, and summing over $a \in \operatorname{img} u$ gives
$1$. The same computation shows $\sum_{a,b,c} p = 1$.

*Step 2: Gibbs, cell by cell.* For real $p \ge 0$ and $q > 0$, the elementary inequality
$\log t \le t - 1$ applied to $t = q/p$ yields
$$p \log\frac1p \;\le\; p\log\frac1q + (q - p),$$
with the convention that the left side vanishes at $p = 0$. Apply this with the $p(a,b,c)$,
$q(a,b,c)$ above, over all triples $(a,b,c) \in \operatorname{img} u \times \operatorname{img} v
\times \operatorname{img} w$; on triples with $n(a,b,c) = 0$ the inequality reduces to
$0 \le q(a,b,c)$. Expanding $\log(1/q) = \log\frac{N}{n(a,b)} + \log\frac{N}{n(a,c)} -
\log\frac{N}{n(a)}$ turns the right-hand side into

$$p\log\frac{N}{n(a,b)} + p\log\frac{N}{n(a,c)} - p\log\frac{N}{n(a)} + (q - p).$$

*Step 3: summation.* Summing the left-hand side over all triples gives exactly $H(u,v,w)$,
because the terms with $n(a,b,c) = 0$ contribute nothing and the nonzero terms are the
$\varphi$-terms of the triple statistic. On the right, the marginalisation identities collapse
the three log-sums: $\sum_{a,b,c} p(a,b,c)\log\frac{N}{n(a,b)} = \sum_{a,b}
\frac{n(a,b)}{N}\log\frac{N}{n(a,b)} = H(u,v)$, and likewise for $H(u,w)$ and $H(u)$. The
correction terms sum to $\sum q - \sum p = 1 - 1 = 0$ by Step 1. Hence
$H(u,v,w) \le H(u,v) + H(u,w) - H(u)$. $\square$

**Corollary 5.2 (Conditioning reduces entropy).** $H(u,v,w) - H(u,v) \le H(u,w) - H(u)$, i.e.
$H(w \mid u,v) \le H(w \mid u)$.

The reference weight $q$ is exactly the conditional-independence surrogate: $q$ is the unique
weight that matches the $(u,v)$ and $(u,w)$ marginals of $p$ and makes $v \perp w \mid u$. The
inequality is therefore the Kullback–Leibler divergence $\mathrm{KL}(p \Vert q) \ge 0$, and the
defect in Theorem 5.1 equals the conditional mutual information $I(v; w \mid u)$.

---

## 6. Monotonicity of the capacity curve

**Theorem 6.1 (Data processing for mutual information).** If $K = r \circ K'$ for some map $r$
of reading-values, then for every label $L$,
$$I(K; L) \;\le\; I(K'; L).$$

*Proof.* Apply Theorem 5.1 with $u = K$, $v = K'$, $w = L$:
$$H(K, K', L) + H(K) \le H(K,K') + H(K,L).$$
Since $K$ is a function of $K'$, the pair $(K,K')$ has the same cells as $K'$, so
$H(K,K') = H(K')$; likewise the triple $(K,K',L)$ has the same cells as $(K',L)$, so
$H(K,K',L) = H(K',L)$. Substituting,
$H(K',L) + H(K) \le H(K') + H(K,L)$, which rearranges to
$H(K) + H(L) - H(K,L) \le H(K') + H(L) - H(K',L)$, i.e. $I(K;L) \le I(K';L)$. $\square$

**Corollary 6.2 (The curve never decreases).** If $S \subseteq T$ then
$\mathrm{cap}(S) \le \mathrm{cap}(T)$.

*Proof.* $K_S = \rho_{T\to S} \circ K_T$; apply Theorem 6.1. $\square$

**Corollary 6.3 (Invariance under re-coding).** If two readings determine each other, they have
the same capacity for every label. In particular a battery's capacity depends only on the
partition of the population induced by its joint reading, not on the encoding of residues — so
the CRT identification of a tuple of coprime residues with a single residue modulo the product
changes nothing.

**Proposition 6.4 (Marginals reproduce their dials).** For a single dial,
$\mathrm{cap}(\{i\}) = I(d_i ; L)$.

*Proof.* The one-element joint reading and the dial reading determine each other; apply
Corollary 6.3. $\square$

Proposition 6.4 is the formal content of the experimental claim that "every marginal reproduces
its paper of origin": the additive column of the capacity table is genuinely the sum of the
single-dial experiments, so the deficit compares like with like.

---

## 7. Synergy, the deficit, and the boundary of the law

The additive column would be the correct answer if information about the label combined
additively. It does not, in either direction. The governing hypothesis is population-level
independence of the readings.

**Definition 7.1 (Independent readings).** Two statistics $k_1, k_2$ are *independent in the
population* if $H(k_1,k_2) = H(k_1) + H(k_2)$; equivalently $I(k_1;k_2) = 0$; equivalently the
cell counts factor, $n(a,b)\,N = n_{k_1}(a)\, n_{k_2}(b)$.

This is exactly what the experimental design provides: for a population uniformly distributed
over a CRT modulus $\prod_i m_i$ with pairwise coprime $m_i$, the residue readings are
independent, since each combination of residues occurs equally often.

**Theorem 7.2 (Synergy law).** If $k_1$ and $k_2$ are independent in the population, then for
every label $L$,
$$I(k_1;L) + I(k_2;L) \;\le\; I\big((k_1,k_2); L\big).$$

*Proof.* Apply Theorem 5.1 with $u = L$, $v = k_1$, $w = k_2$:
$$H(L,k_1,k_2) + H(L) \le H(L,k_1) + H(L,k_2).$$
Reordering coordinates does not change entropy, so this reads
$H(k_1,k_2,L) + H(L) \le H(k_1,L) + H(k_2,L)$. Now
$$I((k_1,k_2);L) = H(k_1,k_2) + H(L) - H(k_1,k_2,L)
\ge H(k_1,k_2) + H(L) - H(k_1,L) - H(k_2,L) + H(L).$$
Using independence, $H(k_1,k_2) = H(k_1)+H(k_2)$, the right side equals
$\big(H(k_1)+H(L)-H(k_1,L)\big) + \big(H(k_2)+H(L)-H(k_2,L)\big) = I(k_1;L)+I(k_2;L)$. $\square$

Interpretively: independent instruments never destroy each other's information about a label;
any interaction is constructive. The mechanism is that, conditionally on the label, the two
readings may well be *dependent* even though they are marginally independent — the classic
"explaining away" configuration — and that conditional dependence is precisely the synergy.

**Theorem 7.3 (Monotone deficit, guarded).** Let $S$ be a sub-battery and $j \notin S$ a new
dial that is independent in the population of the joint reading $K_S$. Then
$$D(S) \;\le\; D(S \cup \{j\}).$$

*Proof.* By Theorem 7.2 applied to $k_1 = K_S$, $k_2 = d_j$,
$$I(K_S;L) + I(d_j;L) \le I\big((K_S, d_j); L\big).$$
The reading $(K_S, d_j)$ and $K_{S\cup\{j\}}$ determine each other, so by Corollary 6.3 the
right-hand side is $\mathrm{cap}(S\cup\{j\})$. Also $\sum_{i \in S\cup\{j\}} I(d_i;L) =
I(d_j;L) + \sum_{i\in S} I(d_i;L)$. Subtracting the latter from the former yields the claim.
$\square$

Iterating along a chain in which every new dial is independent of everything measured so far
— which pairwise coprimality supplies — gives exactly the monotone deficit column of the
measured table.

**Theorem 7.4 (Strict growth at the completing dial).** Let $j \notin S$ with
$I(d_j;L) = 0$ (the new dial carries no label information on its own). Suppose
$K_{S\cup\{j\}}$ determines $L$, while $K_S$ confuses two individuals with distinct labels.
Then
$$D(S) \;<\; D(S\cup\{j\}).$$

*Proof.* By Theorem 4.1, $\mathrm{cap}(S \cup \{j\}) = H(L)$; by Corollary 4.2,
$\mathrm{cap}(S) < H(L)$. Since $I(d_j;L) = 0$ the additive columns for $S$ and
$S \cup \{j\}$ coincide, so the deficits differ exactly by
$\mathrm{cap}(S\cup\{j\}) - \mathrm{cap}(S) > 0$. $\square$

Theorem 7.4 is the extreme form of the phenomenon: a dial that is worthless in isolation can
be decisive in company, and every bit it contributes is synergy. Any feature-selection rule
that scores instruments by their marginal information would discard precisely this dial.

**The boundary.** Unguarded, the monotone-deficit claim is false, and not marginally so.

**Theorem 7.5 (Negative deficit from duplication).** Let $i \ne j$ be indices with
$d_i = d_j$ (the same reading) and $I(d_i;L) > 0$. Then
$$D(\{i,j\}) \;<\; 0.$$

*Proof.* The joint reading $K_{\{i,j\}}$ and $d_i$ determine each other, so by Corollary 6.3,
$\mathrm{cap}(\{i,j\}) = I(d_i;L)$. The additive column is $I(d_i;L) + I(d_j;L) = 2I(d_i;L)$.
Hence $D(\{i,j\}) = -I(d_i;L) < 0$. $\square$

**Example 7.6 (Explicit counterexample).** Let $\Omega = \{\text{false}, \text{true}\}$, let
$L$ be the identity label, and let the battery consist of two copies of the one-bit dial
$k(x) = [\,x = \text{true}\,]$. The dial determines the label, so $I(k;L) = H(L) = 1$ bit by
Theorem 4.1 and Lemma 2.7. The joint reading of the two dials is still the one-bit reading, so
$\mathrm{cap} = 1$ bit, while the additive bookkeeping reports $2$ bits. The deficit is
$-1$ bit.

So the compounding deficit of the six-dial experiment is a consequence of the coprimality of
the conductors, not a universal feature of batteries. Correlated instruments make the additive
column *over*-report; independent ones make it *under*-report. The theorems above delimit
exactly which regime applies.

**Proposition 7.7 (Deficit cap).** $D(S) \le H(L) - \sum_{i \in S} I(d_i;L)$: the deficit is
bounded above by the ceiling minus the additive bookkeeping, so compounding synergy must
eventually stop — it is squeezed out by the ceiling, not by any failure of the synergy law.

---

## 8. The exact vanishing theorem: symmetric batteries are blind

We now explain the fourth measurement, the flat which-factor wall, which is not a small number
but an identity.

Throughout this section $W : \Omega \to \{\text{false},\text{true}\}$ is a binary label and
$\sigma : \Omega \to \Omega$ an involution, $\sigma \circ \sigma = \mathrm{id}$.

**Lemma 8.1 (Cell-halving identity).** For all $N, m$,
$$2\,\varphi(N, m) \;=\; \varphi(N, 2m) + \frac{2m}{N}\log 2 .$$

*Proof.* For $m, N \ge 1$, expand both sides: the left is
$-\frac{2m}{N}\log\frac{m}{N}$ and the right is
$-\frac{2m}{N}\log\frac{2m}{N} + \frac{2m}{N}\log 2$; they agree since
$\log\frac{2m}{N} = \log 2 + \log\frac{m}{N}$. Degenerate cases are immediate. $\square$

**Lemma 8.2 (Balanced halves).** Suppose $C$ is a statistic with $C(\sigma x) = C(x)$ for all
$x$, and $W(\sigma x) = \lnot W(x)$ for all $x$. Then for every value $c$,
$$n_{(C,W)}(c,\text{true}) = n_{(C,W)}(c,\text{false}),$$
and these two counts sum to $n_C(c)$.

*Proof.* $\sigma$ maps the set $\{x : C(x) = c,\, W(x) = \text{true}\}$ bijectively onto
$\{x : C(x) = c,\, W(x) = \text{false}\}$, being its own inverse. The sum statement is the
partition of the cell by a binary statistic. $\square$

**Theorem 8.3 (One extra bit).** Under the hypotheses of Lemma 8.2 (and $\Omega$ non-empty),
$$H(C,W) = H(C) + \log 2, \qquad H(W) = \log 2 .$$

*Proof.* By Lemma 8.2 every cell of $C$ of size $n_C(c) = 2m_c$ splits into two halves of size
$m_c$, so by Lemma 8.1 the contribution of cell $c$ to $H(C,W)$ is
$2\varphi(N,m_c) = \varphi(N, 2m_c) + \frac{2m_c}{N}\log 2$. Summing over $c$ and using
$\sum_c n_C(c)/N = 1$ gives $H(C,W) = H(C) + \log 2$. Taking $C$ constant (which is
$\sigma$-invariant, with $H = 0$ by Lemma 2.7) gives $H(W) = \log 2$. $\square$

**Theorem 8.4 (Factor blindness).** If an involution $\sigma$ preserves the reading $C$ and
flips the binary label $W$, then
$$I(C;W) = 0 .$$

*Proof.* $I(C;W) = H(C) + H(W) - H(C,W) = H(C) + \log 2 - (H(C) + \log 2) = 0$ by Theorem 8.3.
$\square$

**Corollary 8.5 (The wall at every battery size).** If an involution of the population
preserves *every* dial of a battery and flips $W$, then $\mathrm{cap}(S) = 0$ for every
sub-battery $S$, of every size. The capacity curve for that label is identically zero, and
monotonicity (Corollary 6.2) cannot help: a non-decreasing curve pinned at $0$ stays at $0$.

*Proof.* The joint reading $K_S$ is $\sigma$-invariant because each coordinate is; apply
Theorem 8.4. $\square$

**Example 8.6 (A non-vacuous witness).** Let $\Omega$ be the set of *ordered pairs of distinct
residues modulo $5$*, i.e. $\Omega = \{(a,b) \in (\mathbb{Z}/5)^2 : a \ne b\}$, a population of
$20$ individuals — a toy model of semiprimes with their two factors. Let the single dial read
the **sum** $k(a,b) = (a+b) \bmod 5$, a symmetric function of the pair, exactly as the CRT
residue of a product $N = pq$ is symmetric in $p$ and $q$. Let the label be the which-factor
bit $W(a,b) = [\,a < b\,]$. The swap $\sigma(a,b) = (b,a)$ is an involution, preserves the
dial, and flips the bit. Then

- $H(k) > 0$: the dial is genuinely informative (it takes several values);
- $H(W) = \log 2$: the bit carries a full bit;
- $\mathrm{cap} = 0$ exactly: the battery reads nothing whatsoever about $W$.

So the vanishing theorem is not a statement about degenerate configurations. Any battery built
from symmetric functions of a pair is structurally blind to the order of the pair, however
sharply it saturates against every other label. The measured $0.3594$ bits against a
permutation null of $0.3591$ ($z = +0.11$) is finite-sample sparse-table bias around a
structural zero, and reporting it as a small signal would be a category error.

---

## 9. Consistency with the measured curve, and what $99.6\%$ means

The theorems constrain the measured table in four independent ways, all of which it satisfies:

1. **Monotone curve** (Corollary 6.2): $1.0011 < 2.1334 < 4.0242 < 8.2412 < 11.5307 < 12.7235$.
2. **Sub-ceiling** (Theorem 3.1): each $I(k)$ lies strictly below its ceiling, from
   $2.1334 < 4.6063$ through $12.7235 < 12.7726$.
3. **Monotone deficit** (Theorem 7.3, whose hypothesis is delivered by the pairwise coprime
   conductors): $0.0000 < 0.1314 < 1.5465 < 4.3292 < 6.3716 < 7.3585$.
4. **Sub-saturation** (Corollary 4.2): since the curve is strictly below the ceiling at $k=6$,
   the six-dial battery still confuses at least two differently labelled individuals — even at
   $99.6\%$.

Item 4 deserves emphasis: *strictly below the ceiling* is not a rounding artefact but a
structural diagnosis. The gap is $12.7726 - 12.7235 = 0.0491$ bits, and by Proposition 3.2
this is exactly the population-averaged within-cell label entropy. Concretely, if the residual
ambiguity is concentrated on a fraction $\alpha$ of the population where the label is a
perfectly balanced binary choice, then $0.0491 = \alpha$ bits, so about $4.9\%$ of the
population remains ambiguous — a far more actionable statement than "$99.6\%$ of ceiling". If
instead an auxiliary $m$-valued statistic suffices to disambiguate everywhere, Theorem 4.3
forces $\log_2 m \ge 0.0491$, which is no constraint for $m \ge 2$; the informative direction
is the first one.

The factor $3.7$ between $I(6) = 12.7235$ and the additive $5.3650$ is the quantitative shape
of Theorem 7.2 iterated six times: marginal bookkeeping understates an independent battery
progressively, and Proposition 7.7 says the understatement is capped by
$H(L) - \sum_i I(d_i;L) = 12.7726 - 5.3650 = 7.4076$ bits — against a measured deficit of
$7.3585$ bits, i.e. the deficit itself is at $99.3\%$ of its own structural maximum.

---

## 10. Algorithms

Three computational procedures underlie any empirical study of a capacity curve. We record
them with complexity, in the counting calculus above.

**Algorithm 10.1 (Counting entropy by chained labelling).** Computing $H$ of a joint reading of
$k$ dials on a population of $N$ individuals naively requires a table indexed by the product of
the moduli — for the six-dial CRT modulus $31\cdot23\cdot9\cdot8\cdot5\cdot11$ chained with a
pair label this is of order $10^{12}$ cells, several terabytes. Instead, encode the joint
reading as an integer key by Horner's rule, $c \leftarrow c\cdot m_i + k_i$, then sort or hash
the $N$ keys and count run lengths. Cost: $O(kN)$ to build keys and $O(N\log N)$ (sorting) or
expected $O(N)$ (hashing) to count, with $O(N)$ memory independent of the moduli. This is the
only way the six-dial computation is feasible at all.

**Algorithm 10.2 (Capacity curve and deficit along a chain).** Given a nested chain, compute
$H(L)$ once; then for each $k$ compute $H(K_k)$ and $H(K_k, L)$ by Algorithm 10.1 and set
$I(k) = H(K_k) + H(L) - H(K_k, L)$ and $D(k) = I(k) - \sum_{i\le k} I(d_i;L)$. Each single-dial
$I(d_i;L)$ is computed once. Total cost $O(n N \log N)$ for $n$ dials. All four laws of this
paper are checkable online during the sweep: monotonicity of $I$, $I \le H(L)$, the sign of
$D$, and independence $H(K_k, d_{k+1}) = H(K_k) + H(d_{k+1})$ of the next dial.

**Algorithm 10.3 (Saturation certificate and ambiguity audit).** Group the population by the
joint reading; within each cell count distinct labels. If every cell is label-pure, the
battery saturates exactly (Theorem 4.1) and $I = H(L)$. Otherwise report (i) the exact gap
$H(K,L) - H(K)$, (ii) the fraction of the population lying in impure cells, and (iii)
$\log \max_c (\text{distinct labels in } c)$, an upper bound for the gap by the cell-local form
of Theorem 4.3. Cost $O(N \log N)$. The output turns a percentage of ceiling into a list of
specific unresolved confusions, which is what an experimenter can act on.

---

## 11. Discussion

**What the laws say together.** A battery of measurements read against a label obeys a
three-part law: a ceiling at the label entropy; monotone approach to it, guaranteed by strong
subadditivity; and a synergy term that compounds under independence and reverses sign under
duplication. Saturation is not asymptotic but exact, triggered by perfect classification.
The percentage-of-ceiling statistic beloved of scaling studies is, by Proposition 3.2, a
disguised statement about residual within-cell ambiguity.

**Why the counting formulation is the right one.** Every object here is a partition of a finite
set, and every theorem is an inequality between finite sums of $\varphi(N,n) = -\frac nN
\log\frac nN$. This buys two things. First, hypotheses become checkable by inspection of the
data rather than by assumptions about a generative model: "independent in the population" is
$n(a,b)N = n(a)n(b)$, a finite identity. Second, exact vanishing results such as Theorem 8.4
become possible: the involution argument is a bijection between finite sets, so the conclusion
$I = 0$ is exact, not approximate — which is precisely what distinguishes a structural wall
from a weak signal.

**Feature selection.** Theorem 7.4 is a sharp warning for practice: there exist instruments
with exactly zero marginal information that complete a classifier. Marginal ranking cannot see
them. Conversely Theorem 7.5 shows that additive bookkeeping over-credits redundant
instruments. The correct diagnostic is the deficit together with an independence audit.

**Symmetry as a hard ceiling at zero.** Corollary 8.5 is a *no-go* theorem in the physicists'
sense. It says that a class of questions — those distinguishing configurations related by a
symmetry of the instruments — is unanswerable by that instrument class, at any scale. In the
motivating arithmetic setting, symmetric functions of a factorisation cannot reveal which
factor is which. Empirical scaling studies should test for such symmetries before spending
compute on the corresponding label.

**Limitations.** The mutual informations here are *plug-in* quantities computed from finite
populations; on sparse tables they are biased upward, which is exactly what the permutation
null in the which-factor measurement detects. The theorems are statements about the population
actually observed; transferring them to a larger universe requires a sampling argument that we
do not undertake. The synergy law requires exact population independence; a robust version with
$I(k_1;k_2) \le \varepsilon$ would presumably weaken the conclusion to
$I(k_1;L) + I(k_2;L) \le I((k_1,k_2);L) + \varepsilon$, which follows by tracking the defect in
Theorem 7.2, and we have not pursued the sharp constant.

---

## 12. Future directions

**Sharp per-cell saturation gap.** The quantitative bound of Theorem 4.3 uses a global
disambiguator. The sharp statement should be local: the ceiling gap is at most the logarithm of
the largest number of distinct labels inside a single cell of the joint reading, and equals the
weighted average of the per-cell label entropies. The key insight is that the Gibbs argument
used for strong subadditivity works cell by cell with the uniform reference $1/m_c$, so the
per-cell multiplicities — not a single global count — control the gap. With such a bound, a
measured $99.6\%$ becomes a statement about residual per-cell ambiguity rather than an
uninterpreted percentage.

**A robust synergy law.** Replace exact independence by $I(k_1;k_2) \le \varepsilon$ and track
the defect, yielding a synergy law with an explicit error term; then ask how the errors
accumulate along a chain of $n$ nearly-independent dials, and whether the monotone-deficit law
survives with an $O(n\varepsilon)$ slack.

**Optimal dial ordering.** Given a fixed set of dials, which nested chain maximises the
capacity curve at each $k$? The greedy rule (add the dial maximising conditional information)
is natural; the relevant question is whether the capacity function $S \mapsto \mathrm{cap}(S)$
is submodular in general — it is not, by the synergy law, which is precisely a
supermodular-type inequality — and therefore what approximation guarantees are available.

**Finite-sample corrections.** Develop a bias-corrected plug-in estimator for the capacity curve
on sparse tables, so that the permutation-null comparison used for the which-factor wall can be
replaced by an analytic correction, and so that the "percentage of ceiling" statistic acquires
a confidence interval.

**Symmetry detection.** Corollary 8.5 is conditional on exhibiting an involution. Given a
battery and a label, can one *search* efficiently for a symmetry of the readings that flips the
label — turning the no-go theorem into an automatic pre-flight check before an expensive
scaling experiment?

---

## 13. Conclusion

A growing battery of measurements read against a label obeys a capacity law with three exact
components. It cannot exceed the label entropy, and it equals it precisely when it classifies
perfectly. It never decreases as instruments are added, a fact resting on strong subadditivity
of the counting entropy, which follows from a single Gibbs inequality against the conditional
product reference. And it exceeds the sum of its parts exactly when the instruments are
independent in the population — with duplicated instruments the inequality reverses, so the
"compounding synergy" observed in coprime-conductor batteries is a consequence of their
arithmetic design, not a universal law. Finally, when the instruments share a symmetry that the
label breaks, the capacity is identically zero at every battery size: a wall, not a weak signal.
A measured six-dial curve rising to $99.6\%$ of its ceiling with a monotonically compounding
deficit and a flat which-factor reading is, in every detail, the behaviour these theorems
require.
