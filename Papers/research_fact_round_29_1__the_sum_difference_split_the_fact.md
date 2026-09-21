# The Factor-Residue Hint Value: Sum/Difference Coordinates, Data Processing, and the Hyperbola Ceiling

**Author:** Aristotle
**Date:** 2026-09-21

---

## Abstract

Let a finite population of labelled examples carry a hidden pair of residues $(p, q)$ in a commutative ring $R$ in which $2$ is invertible — the motivating case being $R = \mathbb{Z}/m$ with $m$ odd. Four *views* of such a population are natural: the **product view** $N = pq$ (the hint-free channel, all that the visible modulus reveals), the **sum view** $s = p + q$, the **gap view** $d = q - p$, and the **joint residue view** $(s,d)$. We define the **factor-residue hint value**
$$\Delta(T; p, q) \;=\; I(T; s, d) \;-\; I(T; N)$$
in bits, where $T$ is the label statistic, and we determine its structure completely.

Our results are: (i) $\Delta \ge 0$ always, because the polynomial identity $4pq = (p+q)^2 - (q-p)^2$ makes the product view a post-processing of the joint view, so a pre-registered hypothesis $I(T;s,d) = I(T;N)$ can only fail upward; (ii) the joint residue view is *exactly* the factor-pair view, since $(p,q) \mapsto (p+q, q-p)$ is a bijection when $2$ is invertible, so $\Delta$ measures the capacity of a hint of $2\log_2 m$ bits; (iii) $\Delta = H(T \mid N) - H(T \mid s,d)$, so $\Delta = 0$ iff the label is conditionally independent of the fibre coordinate given the product — product-measurability of the labels is sufficient but demonstrably not necessary; (iv) three ceilings, $\Delta \le H(T)$, $\Delta \le I(T;s) + H(d)$, and the sharp modulus-aware bound $\Delta \le H(s,d) - H(N)$, the last of which we evaluate in closed form for the uniform battery over a finite field with $q$ elements by counting points on the hyperbolas $xy = n$ ($q-1$ points for $n \ne 0$; $2q-1$ for the degenerate conic $n = 0$); (v) exact small witnesses establishing that $\Delta$ can be exactly $1$ bit while the product view reads exactly $0$ (refuting the hypothesis with no numerical estimation), that the ceiling $\Delta = H(T)$ is attained, and that the sum and gap views can each read exactly $0$ bits while the joint view reads exactly $1$ — maximal synergy with zero hint value, showing that release and synergy are independent coordinates of a routing table.

A numerical experiment at modulus $31$ that motivated this work measured $I(T;N) = 1.0012$, $I(T;s) = 0.0391$, $I(T;d) = 0.0387$, $I(T;s,d) = 1.5201$ bits, hence $\Delta = +0.5189$ bits (replication: $+0.5099$). Our analysis shows that the *ordering* of these rows is forced, that their *boundary case* is a conditional-independence condition, and that the correct yardstick for the measured magnitude is the hyperbola ceiling $H(s,d) - H(N) = 4.9719$ bits at $q = 31$, against which the release is $10.4\%$.

**Keywords:** factor residues, sum/difference coordinates, mutual information, data-processing inequality, conditional entropy, hyperbola point counts, informational synergy.

---

## 1. Introduction

### 1.1 The motivating measurement

Consider a population of examples, each of which hides a pair of factors and exposes a label. In a concrete instance the hidden data is a pair of prime residues $(p \bmod 31, q \bmod 31)$, the visible datum is the product residue $N = pq \bmod 31$, and the label is a binary or small-alphabet outcome attached to each example. One asks: how many bits about the label does each way of looking at the hidden pair carry?

A measurement produced this routing table:

| view | bits about the label | share of the product row |
|---|---|---|
| product view (hint-free) $N$ | $1.0012$ | $100\%$ |
| sum view alone $s = p+q$ | $0.0391$ | $3.9\%$ |
| gap view alone $d = q-p$ | $0.0387$ | $3.9\%$ |
| joint residue view $(s,d)$ | $1.5201$ | $152\%$ |
| **hint value** $\Delta = I(s,d) - I(N)$ | $+0.5189$ | |

The pre-registered *reconstruction hypothesis* had been $I(T; s, d) = I(T; N)$: that reading the factors through their sum and difference is informationally the same as reading their product. The measurement refuted it, upward, by about half a bit; a replicate battery gave $+0.5099$ bits, and $p \leftrightarrow q$ symmetry was verified numerically.

Two things about this table demand explanation. First, the two single-coordinate rows carry almost nothing individually yet their combination carries more than the product row — a textbook signature of synergy, but also possibly a signature of estimator bias. Second, the direction of the refutation: was it luck that the hypothesis failed upward rather than downward?

### 1.2 What we prove

It was not luck. This paper shows that every structural feature of the table is a theorem, and isolates precisely which feature of it remains empirical (namely: the magnitude $+0.5189$, and only that).

The whole analysis rests on one identity and one inequality. The identity is
$$4pq = (p+q)^2 - (q-p)^2,$$
valid in every commutative ring; the inequality is the data-processing inequality for mutual information. Together they say that the product view is a deterministic function of the joint residue view, hence carries no more label information than it. The hint value is nonnegative *by algebra*.

We then characterise the boundary $\Delta = 0$, prove three ceilings on $\Delta$ (one of which is modulus-aware and evaluated in closed form by a hyperbola point count), and construct small exact witnesses which fix the logical status of each claim beyond the reach of estimation error.

### 1.3 Organisation

Section 2 fixes the finitary information calculus. Section 3 develops the sum/difference algebra. Section 4 proves the ordering theorems and nonnegativity. Section 5 identifies the joint view with the factor-pair hint and establishes $p \leftrightarrow q$ symmetry. Section 6 gives the conditional-entropy bridge and the exact boundary. Section 7 proves the three ceilings. Section 8 evaluates the sharp ceiling over a finite field via hyperbola counts. Section 9 presents the exact witnesses. Section 10 separates release from synergy. Section 11 gives algorithms; Section 12 applications and discussion; Section 13 future directions.

---

## 2. The finitary information calculus

All populations are finite; all statistics take values in arbitrary types, with equality of values being the only structure used. This "counting" formulation avoids measure-theoretic overhead and makes every quantity below an explicit finite sum of logarithms of rationals.

**Definition 2.1 (population, statistic, fibre).** A *population* is a nonempty finite set $\Omega$ with the uniform distribution. A *statistic* is a function $f : \Omega \to A$ into any type. For $a \in A$ the *fibre* is $f^{-1}(a) = \{x \in \Omega : f(x) = a\}$, and $c_f(a) = |f^{-1}(a)|$ is the *fibre count*. The *image* $\mathrm{img}(f)$ is the finite set of values actually attained.

**Definition 2.2 (entropy).** With $n = |\Omega|$ and $\varphi(n, c) = \frac{c}{n}\log\frac{n}{c}$, the *entropy in nats* of a statistic is
$$H(f) \;=\; \sum_{a \in \mathrm{img}(f)} \varphi\big(n, c_f(a)\big) \;=\; -\sum_{a \in \mathrm{img}(f)} \frac{c_f(a)}{n}\log\frac{c_f(a)}{n}.$$
The entropy in bits is $H_b(f) = H(f)/\log 2$.

**Lemma 2.3 (uniform fibres).** If every nonempty fibre of $f$ has the same size $k > 0$, then $H(f) = \log n - \log k$. *Proof.* There are $n/k$ fibres, each contributing $\frac{k}{n}\log\frac{n}{k}$. $\square$

This lemma is what makes all the exact witnesses below exactly computable: each is a small population on which every relevant statistic has uniform fibres.

**Definition 2.4 (pairing, joint and conditional entropy, mutual information).** For statistics $f : \Omega \to A$, $g : \Omega \to B$ write $(f,g) : \Omega \to A \times B$ for the joint statistic. The *conditional entropy* is $H(f \mid g) = H(f,g) - H(g)$, and the *mutual information* is
$$I(f; g) \;=\; H(f) + H(g) - H(f,g) \;=\; H(f) - H(f \mid g),$$
with $I_b$ denoting the same quantity divided by $\log 2$, i.e. measured in bits. Throughout, $T : \Omega \to \Lambda$ denotes the label statistic and $I(T; V)$ is abbreviated to the view's name.

We use three standard facts, each elementary in this finitary setting.

**Lemma 2.5 (data processing).** For any statistic $g$ and any function $h$ on its codomain, $I(T; h \circ g) \le I(T; g)$. *Proof sketch.* $h \circ g$ has coarser fibres than $g$; the joint statistic $(T, h\circ g)$ is a function of $(T, g)$, so $H(T, h\circ g) \le H(T, g)$, while $H(h \circ g) \le H(g)$ in a matched way. Expanding $I = H(T) - H(T,\cdot) + H(\cdot)$ and comparing the coarsening term by term gives the claim. $\square$

**Lemma 2.6 (equal fibres give equal information).** If two statistics $g_1, g_2$ induce the same partition of $\Omega$ — that is, $g_1(x) = g_1(y) \iff g_2(x) = g_2(y)$ for all $x,y$ — then $I(T; g_1) = I(T; g_2)$. *Proof sketch.* Information depends on a statistic only through its fibre partition; relabelling values is an information-preserving bijection of images. $\square$

**Lemma 2.7 (basic bounds).** $0 \le I(T;g) \le \min\{H(T), H(g)\}$; if $g$ determines $T$ (i.e. $g(x) = g(y) \Rightarrow T(x) = T(y)$) then $I(T;g) = H(T)$; if $g$ is constant then $I(T;g) = 0$; and $H(g) \le \log|\mathrm{img}(g)|$.

---

## 3. The algebra of the sum/difference split

Throughout this section $R$ is a commutative ring.

**Definition 3.1 (sum/difference coordinates).** For $p, q \in R$ set
$$\mathrm{sd}(p,q) \;=\; (p + q,\; q - p) \;=\; (s, d).$$

**Theorem 3.2 (characteristic-free recovery identity).** For all $p, q \in R$,
$$4\,pq \;=\; (p+q)^2 - (q-p)^2 .$$
*Proof.* Expand: $(p+q)^2 - (q-p)^2 = (p^2 + 2pq + q^2) - (q^2 - 2pq + p^2) = 4pq$. $\square$

No invertibility is used to *state* the identity; invertibility of $2$ is needed only to solve for $pq$.

**Definition 3.3 (recovered product).** Suppose $2 \in R^\times$. For $(s,d) \in R \times R$ define
$$\pi(s,d) \;=\; \tfrac14\big(s^2 - d^2\big) \;=\; \tfrac12 \cdot \tfrac12 \cdot (s^2 - d^2).$$

**Theorem 3.4 (the product factors through the split).** If $2 \in R^\times$ then $\pi(\mathrm{sd}(p,q)) = pq$ for all $p,q$. Consequently $\mathrm{sd}(p,q) = \mathrm{sd}(p',q') \Rightarrow pq = p'q'$. *Proof.* Immediate from Theorem 3.2 after multiplying by $\tfrac14$. $\square$

This single statement is the structural reason the joint row of the routing table can never fall below the product row.

**Theorem 3.5 (the split is a bijection).** If $2 \in R^\times$, the map $\mathrm{sd} : R\times R \to R \times R$ is a bijection, with inverse
$$(s,d) \;\longmapsto\; \Big(\tfrac{s - d}{2},\ \tfrac{s + d}{2}\Big).$$
*Proof.* Compute $\tfrac12\big((p+q)-(q-p)\big) = p$ and $\tfrac12\big((p+q)+(q-p)\big) = q$ for the left inverse, and $\tfrac{s-d}{2} + \tfrac{s+d}{2} = s$, $\tfrac{s+d}{2} - \tfrac{s-d}{2} = d$ for the right inverse. $\square$

**Theorem 3.6 ($p \leftrightarrow q$ symmetry).** $\mathrm{sd}(q,p) = (s, -d)$ where $(s,d) = \mathrm{sd}(p,q)$, and $\pi(s,-d) = \pi(s,d)$. Hence swapping the two factors fixes the recovered product and acts on the joint view by the involution $d \mapsto -d$, which is a bijection and therefore preserves the fibre partition.

**Proposition 3.7 (strictness at $m = 31$).** In $\mathbb{Z}/31$:

1. *The sum view does not determine the product*: $1 + 2 = 0 + 3$ but $1\cdot 2 = 2 \ne 0 = 0 \cdot 3$.
2. *The gap view does not determine the product*: $2 - 1 = 1 - 0$ but $1 \cdot 2 = 2 \ne 0 = 0 \cdot 1$.
3. *The joint view is strictly finer than the product view*: $1 \cdot 6 = 6 = 2 \cdot 3$ while $\mathrm{sd}(1,6) = (7,5) \ne (5,1) = \mathrm{sd}(2,3)$.
4. *The collapse is not merely the swap*: the pairs $(1,6)$ and $(2,3)$ lie in the same product fibre and are neither equal nor swaps of each other.

So one direction of the correspondence is a bijection and the other is a genuinely $2$-to-$1$-or-worse quadratic collapse.

**Proposition 3.8 (hint size at $m = 31$).** $|\mathbb{Z}/31 \times \mathbb{Z}/31| = 961 < 2^{10}$, hence $\log_2 961 < 10$: revealing the factor-residue pair modulo $31$ is a hint of strictly fewer than ten bits.

---

## 4. Four views, and the ordering of the routing table

Fix a finite population $\Omega$, a label statistic $T : \Omega \to \Lambda$, and hidden residue statistics $P, Q : \Omega \to R$.

**Definition 4.1 (the views).**
$$\mathsf{S} = P + Q, \qquad \mathsf{D} = Q - P, \qquad \mathsf{N} = P \cdot Q, \qquad \mathsf{R} = \mathrm{sd}(P, Q) = (\mathsf{S}, \mathsf{D}), \qquad \mathsf{P\!P} = (P, Q).$$
We call $\mathsf S$ the sum view, $\mathsf D$ the gap view, $\mathsf N$ the product (hint-free) view, $\mathsf R$ the joint residue view, and $\mathsf{PP}$ the factor-pair view.

**Definition 4.2 (hint value).**
$$\Delta(T; P, Q) \;=\; I_b(T; \mathsf R) \;-\; I_b(T; \mathsf N) \quad\text{bits}.$$

**Theorem 4.3 (single coordinates are dominated).** $I(T;\mathsf S) \le I(T;\mathsf R)$ and $I(T;\mathsf D) \le I(T;\mathsf R)$. *Proof.* $\mathsf S = \mathrm{pr}_1 \circ \mathsf R$ and $\mathsf D = \mathrm{pr}_2 \circ \mathsf R$ literally, by definition of $\mathsf R$; apply data processing (Lemma 2.5). $\square$

**Theorem 4.4 (the product view is dominated).** If $2 \in R^\times$ then $\mathsf N = \pi \circ \mathsf R$, hence $I(T;\mathsf N) \le I(T;\mathsf R)$. *Proof.* Pointwise, $\pi(\mathsf R(x)) = \pi(\mathrm{sd}(P x, Q x)) = P x \cdot Q x = \mathsf N(x)$ by Theorem 3.4; apply data processing. $\square$

**Corollary 4.5 (the hint value is never negative).** $\Delta(T;P,Q) \ge 0$ for every population, every labelling, every $R$ with $2$ invertible.

This is the paper's first headline. The pre-registered hypothesis $I(T;\mathsf R) = I(T;\mathsf N)$ is an equality constrained by a one-sided inequality: it could only ever fail in the direction the experiment observed. The observed sign carries no evidential weight; only the observed magnitude does.

Theorem 4.3 likewise forces the qualitative shape $3.9\% , 3.9\% \le 152\%$ of the measured table.

---

## 5. The joint residue view is exactly the factor-pair hint

**Theorem 5.1 (same fibres).** If $2 \in R^\times$ then for all $x, y \in \Omega$,
$$\mathsf R(x) = \mathsf R(y) \iff \mathsf{PP}(x) = \mathsf{PP}(y).$$
*Proof.* ($\Rightarrow$) $\mathrm{sd}$ is injective by Theorem 3.5. ($\Leftarrow$) $\mathrm{sd}$ is a function. $\square$

**Corollary 5.2.** $I(T;\mathsf R) = I(T;\mathsf{PP})$, by Lemma 2.6.

Hence the "$152\%$" row is literally the label information carried by the factor-residue pair itself, and the hint value is exactly the amount of label information released by disclosing $(p \bmod m, q \bmod m)$ to an observer who already sees $N \bmod m$. Nothing is gained or lost by presenting the hint in sum/difference coordinates rather than in factor coordinates — a remark that also disposes of encoding-level discrepancies between implementations: any two faithful encodings of the same residue pair must yield identical readings.

**Theorem 5.3 (symmetry of the hint value).** $\Delta(T; Q, P) = \Delta(T; P, Q)$.
*Proof.* The product view is symmetric since $PQ = QP$. For the joint view, $\mathrm{sd}(Q,P) = (\mathsf S, -\mathsf D)$, and $(s,d)\mapsto(s,-d)$ is a bijection, so $\mathsf{sd}(Q,P)$ and $\mathsf{sd}(P,Q)$ induce the same partition; apply Lemma 2.6. $\square$

This is the invariance the motivating experiment checked numerically; it is an identity, so its numerical verification was a sanity check on the pipeline rather than a test of the mathematics.

---

## 6. The conditional-entropy bridge and the exact boundary

**Theorem 6.1 (hint value as released conditional entropy).**
$$\Delta(T;P,Q) \;=\; \frac{H(T \mid \mathsf N) - H(T \mid \mathsf R)}{\log 2}.$$
*Proof.* $I(T;V) = H(T) - H(T\mid V)$; subtract the two instances, the $H(T)$ terms cancel, and divide by $\log 2$. $\square$

So the hint value is, exactly, the drop in residual label uncertainty caused by the hint — the same quantity a conditioning-capacity measurement reports.

**Corollary 6.2 (the exact boundary).** $\Delta(T;P,Q) = 0$ if and only if $H(T \mid \mathsf N) = H(T \mid \mathsf R)$; equivalently, iff the label is conditionally independent of the position within the product fibre, given the product residue.

Note that no measurability hypothesis appears. The boundary is an identity between conditional entropies. Two further results locate the failed hypothesis within it.

**Theorem 6.3 (product-measurable labels are a sufficient boundary case).** If $\mathsf N(x) = \mathsf N(y) \Rightarrow T(x) = T(y)$ for all $x,y$ — that is, if the label is a function of the product residue — then $\Delta(T;P,Q) = 0$.
*Proof.* Since $\mathsf N$ determines $T$, $I(T;\mathsf N) = H(T)$ by Lemma 2.7. Since $\mathsf R$ refines $\mathsf N$ (Theorem 3.4), $\mathsf R$ also determines $T$, so $I(T;\mathsf R) = H(T)$. Subtract. $\square$

This pins down the provenance of the refuted hypothesis: it is the assumption of product-measurable labels, illegitimately extended to arbitrary labellings. Round-number verdict: the experiment did not refute a theorem, it refuted an extrapolation.

**Theorem 6.4 (product-measurability is not necessary).** There exists a population with $\Delta = 0$ whose labels are not a function of the product residue.
*Witness.* $\Omega = \{x_1,x_2\}$, $P = Q = (0,0)$ in $\mathbb{Z}/5$, labels $T = (0,1)$. Every view is constant, so all mutual informations vanish and $\Delta = 0$; but $\mathsf N(x_1) = \mathsf N(x_2) = 0$ while $T(x_1) \ne T(x_2)$. $\square$

Thus the correct characterisation of the boundary is Corollary 6.2 and not Theorem 6.3.

---

## 7. Three ceilings

**Theorem 7.1 (label-entropy ceiling).** $\Delta(T;P,Q) \le H_b(T)$.
*Proof.* $I_b(T;\mathsf R) \le H_b(T)$ and $I_b(T;\mathsf N) \ge 0$. $\square$

**Theorem 7.2 (split ceiling).** $I_b(T;\mathsf R) \le I_b(T;\mathsf S) + H_b(\mathsf D)$, hence $\Delta \le I_b(T;\mathsf S) + H_b(\mathsf D)$.
*Proof sketch.* The joint statistic $(\mathsf S, \mathsf D)$ satisfies $I(T; (\mathsf S,\mathsf D)) \le I(T;\mathsf S) + H(\mathsf D)$: expanding both sides, the inequality reduces to subadditivity of entropy applied to the pair, i.e. the chain rule $I(T;\mathsf S,\mathsf D) = I(T;\mathsf S) + I(T;\mathsf D \mid \mathsf S)$ together with $I(T;\mathsf D\mid \mathsf S) \le H(\mathsf D \mid \mathsf S) \le H(\mathsf D)$. Divide by $\log 2$ and use $I_b(T;\mathsf N)\ge0$. $\square$

Interpretation: on top of whatever the sum dial reads, the gap dial can contribute at most its own entropy.

**Theorem 7.3 (hint-budget ceiling at $m = 31$).** For $P, Q : \Omega \to \mathbb{Z}/31$,
$$\Delta(T;P,Q) \;\le\; \log_2 961 \;<\; 10 .$$
*Proof.* $I_b(T;\mathsf R) \le H_b(\mathsf R) \le \log_2 |\mathrm{img}(\mathsf R)| \le \log_2 961$ since $\mathsf R$ takes values in a set of size $31^2$; and $I_b(T;\mathsf N) \ge 0$. Finally $961 < 1024 = 2^{10}$. $\square$

Against this budget the measured $+0.5189$ bits is about $5\%$. But Theorem 7.3 is crude: it ignores the fact that the product view already codes much of the pair. The sharp ceiling is next.

**Theorem 7.4 (the sharp entropy-gap ceiling).** For any labelling whatsoever,
$$\Delta(T;P,Q) \;\le\; H_b(\mathsf R) - H_b(\mathsf N).$$
*Proof.* By Theorem 6.1 it suffices to show $H(T\mid \mathsf N) - H(T \mid \mathsf R) \le H(\mathsf R) - H(\mathsf N)$, i.e. $H(T, \mathsf N) \le H(T, \mathsf R)$ after expanding $H(T\mid V) = H(T,V) - H(V)$. And indeed $(T, \mathsf N) = (\mathrm{id} \times \pi) \circ (T, \mathsf R)$ is a post-processing of the joint statistic $(T, \mathsf R)$, so its entropy is no larger. $\square$

The right-hand side is exactly the residual uncertainty of the factor pair once the product is known — *the* natural meaning of "what knowing $p$ and $q$ separately adds over reading $N$". Unlike the label-entropy ceiling, it shrinks as the product view approaches a faithful code, and unlike the $10$-bit budget it accounts for the information $N$ already carries.

---

## 8. Evaluating the sharp ceiling: hyperbola point counts

We now compute $H(\mathsf R) - H(\mathsf N)$ in closed form for the **uniform factor battery**: the population is $\Omega = F \times F$ for a finite field $F$ with $|F| = q$ elements (of odd characteristic, so $2 \in F^\times$), each residue pair occurring exactly once, with $P = \mathrm{pr}_1$ and $Q = \mathrm{pr}_2$. The labels are arbitrary.

**Theorem 8.1 (nondegenerate hyperbola).** For $n \in F$, $n \ne 0$,
$$\#\{(x,y) \in F^2 : xy = n\} \;=\; q - 1.$$
*Proof.* The map $x \mapsto (x, n x^{-1})$ is a bijection from $F^\times$ onto the fibre, with inverse $(x,y) \mapsto x$: any point of the fibre has $x \ne 0$ (else $xy = 0 \ne n$) and then $y$ is determined as $n x^{-1}$. $\square$

**Theorem 8.2 (degenerate conic).**
$$\#\{(x,y) \in F^2 : xy = 0\} \;=\; 2q - 1.$$
*Proof.* The fibre is the union of the lines $\{x = 0\}$ and $\{y = 0\}$, each of $q$ points, meeting exactly in the origin; inclusion–exclusion gives $q + q - 1$. $\square$

So the product map $F^2 \to F$ has one fat fibre of size $2q-1$ over $0$ and $q-1$ thin fibres of size $q-1$; total $2q - 1 + (q-1)^2 = q^2$, as it must be.

**Theorem 8.3 (the joint view is a faithful code).** For the uniform battery, every fibre of $\mathsf R$ is a singleton and
$$H(\mathsf R) \;=\; \log q^2 .$$
*Proof.* $\mathrm{sd}$ is a bijection of $F^2$ (Theorem 3.5), so $\mathsf R = \mathrm{sd}$ is injective on $\Omega = F^2$; apply Lemma 2.3 with $k = 1$ and $n = q^2$. $\square$

**Theorem 8.4 (product-view entropy in closed form).** For the uniform battery, with $\varphi(n,c) = \frac{c}{n}\log\frac{n}{c}$,
$$H(\mathsf N) \;=\; \varphi\big(q^2,\, 2q-1\big) \;+\; (q-1)\,\varphi\big(q^2,\, q-1\big).$$
*Proof.* The product map is surjective onto $F$ (take $(1,n)$), so the entropy sum runs over all $n \in F$. Split off $n = 0$ and apply Theorems 8.1 and 8.2 to the fibre counts. $\square$

**Theorem 8.5 (the hyperbola ceiling).** For the uniform factor battery over a finite field with $q$ elements of odd characteristic, and **any** labelling $T$,
$$\Delta(T; \mathrm{pr}_1, \mathrm{pr}_2) \;\le\; \frac{\log q^2 \;-\; \varphi(q^2, 2q-1) \;-\; (q-1)\varphi(q^2, q-1)}{\log 2}.$$
*Proof.* Combine Theorems 7.4, 8.3, 8.4. $\square$

**Numerical evaluation.** Writing everything in bits:

| $q$ | $H_b(\mathsf R) = \log_2 q^2$ | $H_b(\mathsf N)$ | ceiling $H_b(\mathsf R) - H_b(\mathsf N)$ |
|---|---|---|---|
| $5$ | $4.6439$ | $2.2227$ | $2.4212$ |
| $7$ | $5.6147$ | $2.7338$ | $2.8809$ |
| $11$ | $6.9189$ | $3.4112$ | $3.5077$ |
| $31$ | $9.9084$ | $4.9365$ | $4.9719$ |

At the modulus of the motivating experiment the true budget for a factor-residue hint is $4.9719$ bits, and the measured release of $+0.5189$ bits is $10.4\%$ of it — a different and more meaningful figure than the $5\%$ obtained from the crude $10$-bit budget. At $q = 5$ the ceiling is $2.4212$ bits and, as Section 9 shows, $2$ of those bits are actually attained by an explicit four-example battery; the two ceilings of Theorems 7.1 and 7.4 are therefore comparable in size, not artefacts of slack.

As $q \to \infty$ the ceiling behaves like $\log_2 q^2 - \log_2 \frac{q^2}{q-1} \to \log_2 (q-1)$ up to the correction caused by the single degenerate fibre — so the entire modulus-dependent hint budget is governed by the one degenerate conic $xy = 0$, everything else being a uniform family of $(q-1)$-point hyperbolas.

---

## 9. Exact witnesses

Mutual information estimated by plug-in fibre counts is biased upward, so a small positive measured $\Delta$ is not by itself evidence of structure. The following witnesses are exact: every reading is a rational number of bits obtained from Lemma 2.3, with no estimation.

### 9.1 A one-bit refutation of the reconstruction hypothesis

Work in $\mathbb{Z}/5$ with $\Omega = \{1,2,3,4\}$:

| $x$ | $P(x)$ | $Q(x)$ | $\mathsf N(x)$ | $\mathsf S(x)$ | $\mathsf D(x)$ | $T(x)$ |
|---|---|---|---|---|---|---|
| $1$ | $1$ | $1$ | $1$ | $2$ | $0$ | $0$ |
| $2$ | $1$ | $2$ | $2$ | $3$ | $1$ | $0$ |
| $3$ | $2$ | $3$ | $1$ | $0$ | $1$ | $1$ |
| $4$ | $2$ | $1$ | $2$ | $3$ | $4$ | $1$ |

**Theorem 9.1.** On this battery $I_b(T;\mathsf N) = 0$ exactly and $I_b(T;\mathsf R) = 1$ exactly, hence $\Delta = 1$ bit exactly.
*Proof.* Each label class has two members, each product value has two preimages, and each pair $(T,\mathsf N)$ value has exactly one preimage. By Lemma 2.3, $H(T) = \log 4 - \log 2$, $H(\mathsf N) = \log 4 - \log 2$, $H(T,\mathsf N) = \log 4$; so $I(T;\mathsf N) = H(T) + H(\mathsf N) - H(T,\mathsf N) = 0$. The four values of $\mathsf R$ are $(2,0),(3,1),(0,1),(3,4)$, pairwise distinct, so $\mathsf R$ determines $T$ and $I(T;\mathsf R) = H(T) = 1$ bit. $\square$

**Corollary 9.2 (the reconstruction hypothesis is false).** There is no universal identity $I(T;\mathsf R) = I(T;\mathsf N)$; the witness separates the two readings by a full bit. What survives is Theorem 4.4 together with the boundary characterisation of Corollary 6.2.

### 9.2 The label-entropy ceiling is attained

**Theorem 9.3 (abstract sharpness).** If $\mathsf R$ determines $T$ while $\mathsf N$ is constant, then $\Delta = H_b(T)$.
*Proof.* $I_b(T;\mathsf R) = H_b(T)$ and $I_b(T;\mathsf N) = 0$. $\square$

**Witness.** In $\mathbb{Z}/5$, take the four points of the product fibre $pq = 1$:
$$(P,Q) = (1,1),\ (2,3),\ (3,2),\ (4,4), \qquad T = 0,1,2,3 .$$
Every product equals $1$, so $\mathsf N$ is constant and the hint-free channel reads exactly $0$ bits. The four residue pairs are distinct, so $\mathsf R$ determines $T$, whose entropy is exactly $2$ bits. Hence $\Delta = 2 = H_b(T)$: the ceiling of Theorem 7.1 is attained, the hint value can exceed one bit, and — since the product row is $0$ — the "share of the product row" statistic is unbounded. The $152\%$ of the motivating table is nowhere near the structural maximum.

### 9.3 Individually blind, jointly complete

**Definition 9.4 (synergy of the split).** $\mathrm{Syn}(T;P,Q) = I_b(T;\mathsf R) - I_b(T;\mathsf S) - I_b(T;\mathsf D)$.

**Theorem 9.5 (bounded redundancy).** $\mathrm{Syn}(T;P,Q) \ge -\min\{I_b(T;\mathsf S),\, I_b(T;\mathsf D)\}$, and $\mathrm{Syn}(T;P,Q) \le H_b(T)$.
*Proof.* The lower bound is Theorem 4.3 applied to whichever of the two single rows is larger; the upper bound follows from $I_b(T;\mathsf R) \le H_b(T)$ and nonnegativity of the two single rows. $\square$

**Witness (maximal synergy).** In $\mathbb{Z}/5$, take
$$(P,Q) = (0,0),\ (2,3),\ (3,3),\ (0,1), \qquad (\mathsf S,\mathsf D) = (0,0),\ (0,1),\ (1,0),\ (1,1), \qquad T = 0,1,1,0 .$$
The label is the exclusive-or of the two coordinates. Each value of $\mathsf S$ occurs twice, and within each such fibre both labels occur once — so $I_b(T;\mathsf S) = 0$ exactly; identically $I_b(T;\mathsf D) = 0$. The four joint values are distinct, so $I_b(T;\mathsf R) = H_b(T) = 1$. Hence $\mathrm{Syn} = 1 = H_b(T)$: the synergy ceiling of Theorem 9.5 is attained, and the qualitative pattern "$3.9\%$, $3.9\%$, $152\%$" is exactly realisable in its extreme form "$0$, $0$, everything".

---

## 10. Release and synergy are independent

The synergy witness of Section 9.3 has an instructive second property: its products are $0, 1, 4, 0$ and its labels $0, 1, 1, 0$, so the label *is* a function of the product residue. By Theorem 6.3 its hint value is exactly $0$ — while its synergy is maximal. The ceiling witness of Section 9.2, conversely, has maximal hint value.

**Theorem 10.1.** There exist batteries modulo $5$ with (i) $\mathrm{Syn} = H_b(T)$ and $\Delta = 0$, and (ii) $\Delta = H_b(T)$.

Consequently **release** (how much the hint adds over the hint-free channel) and **synergy** (how much the joint view adds over its two coordinates) are independent coordinates of a routing table. A single scalar summary — "$+0.5189$ bits", "$152\%$" — cannot be read as "the amount of structure" in a battery: two batteries with identical hint value can have opposite synergy, and vice versa. Any reporting protocol for such tables should quote both, together with the hyperbola ceiling against which the release is normalised.

This also explains, from the other side, sub-ceiling gaps in capacity measurements generally: the label entropy $H(T)$ counts what there is to know; the product row counts what the hint-free channel reaches; the hint value is exactly the bridge between them, and the entropy-gap ceiling is the largest that bridge can be.

---

## 11. Algorithms

Everything above is computable in time linear in the population size for a fixed view, given hashing of statistic values.

**Algorithm A — routing table of a factor-residue battery.** Given residues $P, Q \in (\mathbb Z/m)^n$ and labels $T \in \Lambda^n$, compute the four rows and the hint value.

1. Form the four value vectors $\mathsf N_i = P_iQ_i$, $\mathsf S_i = P_i + Q_i$, $\mathsf D_i = Q_i - P_i$, $\mathsf R_i = (\mathsf S_i, \mathsf D_i)$, all modulo $m$.
2. For each view $V$, accumulate fibre counts $c_V$ and joint counts $c_{(T,V)}$ in hash tables.
3. Compute $H(V) = -\sum_a \frac{c_V(a)}{n}\log_2\frac{c_V(a)}{n}$, similarly $H(T)$ and $H(T,V)$.
4. Report $I_b(T;V) = H_b(T) + H_b(V) - H_b(T,V)$ for each view, and $\Delta = I_b(T;\mathsf R) - I_b(T;\mathsf N)$.

Cost: $O(n)$ time and $O(\min(n, m^2))$ space. Correctness of the reported *ordering* is guaranteed a priori by Theorems 4.3 and 4.4, which makes the algorithm self-checking: a violation indicates an implementation defect, not a discovery.

**Algorithm B — exact hyperbola ceiling.** Given a prime power $q$ (odd), compute $H_b(\mathsf R) - H_b(\mathsf N)$ for the uniform battery in $O(1)$ arithmetic operations using the closed form of Theorem 8.5, or verify it in $O(q^2)$ by direct enumeration of $F\times F$. The two agree exactly.

**Algorithm C — boundary test.** Given a battery, decide whether $\Delta = 0$ *exactly*, without floating point: group examples by product residue; within each product fibre, group by residue pair; $\Delta = 0$ iff within every product fibre the conditional label distribution is the same across all residue-pair sub-fibres (i.e. every sub-fibre's label histogram is proportional to the fibre's). This is Corollary 6.2 made computational, and it is a rational-arithmetic test: $O(n)$ time.

---

## 12. Discussion

### 12.1 What is theorem and what is measurement

The analysis assigns each feature of the motivating table a definite status.

- **Forced by algebra:** the ordering $\max\{I(T;\mathsf S), I(T;\mathsf D), I(T;\mathsf N)\} \le I(T;\mathsf R)$, hence $\Delta \ge 0$; and the $p\leftrightarrow q$ symmetry of $\Delta$. No experiment can refute these, and an experiment that appears to is reporting an implementation defect.
- **Forced by the boundary theorem:** $\Delta = 0$ exactly under conditional independence given the product residue; product-measurable labels are one instance.
- **Genuinely empirical:** the magnitude. Plug-in mutual information is biased upward, so a small positive $\Delta$ is not by itself evidence of structure. The honest report normalises by the entropy-gap ceiling: $0.5189 / 4.9719 = 10.4\%$ at $q = 31$.

### 12.2 Robustness to encoding

Corollary 5.2 has a practical consequence. Since the joint residue view and the factor-pair view induce the same partition, any two faithful encodings of the same residue pair must produce identical readings. A discrepancy between two implementations reading "the same" joint quantity — such as a joint reading of $0.1353$ against a nominally identical $2.1314$ elsewhere — is therefore necessarily a label-encoding or population-alignment difference, not an information-theoretic one. None of the results of this paper depend on such a reading.

### 12.3 Why the phenomenon is generic

The product view equals the joint view only on the conditional-independence locus of Corollary 6.2, which is a positive-codimension condition on label assignments; for a label assignment in general position the quadratic collapse $(s,d)\mapsto (s^2-d^2)/4$ destroys label information that the hint restores. So a positive hint value is the generic position, not the exception, and the interesting question about any particular battery is always *how much*, never *whether*.

### 12.4 Scope and limits

The hyperbola ceiling is proved for the uniform battery on all of $F \times F$. A battery supported on the unit group $F^\times \times F^\times$ — the case that actually arises for products of primes — has a different and strictly smaller budget, because the degenerate conic is removed and every product fibre then has exactly $q-1$ points. The general ceiling of Theorem 7.4 is assumption-free and is the statement to quote for non-uniform populations.

---

## 13. Future directions

**An intrinsic boundary condition.** $\Delta = 0$ is a conditional-independence statement. Conditional independence of a label from the fibre coordinate of a two-to-one-or-worse quadratic map ought to be expressible as a balance condition on fibre-wise label distributions, with no entropies at all. Both the sufficient condition (product-measurable labels) and a counterexample to its necessity are in hand; the gap to close is exactly one equivalence.

**The unit-battery budget.** Restricting the population to $F^\times \times F^\times$ removes the degenerate conic entirely, so every product fibre has exactly $q-1$ points and the whole hint budget collapses to $\log_2(q-1)$ — a strictly smaller and modulus-independent-in-shape ceiling. The point count is already established; only the entropy bookkeeping over the unit group remains, and the resulting bound is the one that applies to factor batteries built from primes.

**Hint value versus algebraic degree.** The sum/difference split is the degree-two case of a hierarchy: the elementary symmetric functions of $k$ factors recover the product from $k$ residues, and the hint value should grow with the number of hidden factors like the codimension of the discriminant locus. The $k = 2$ case here used only data processing plus one polynomial identity, both of which generalise verbatim.

**Estimator theory for the hint value.** Since $\Delta \ge 0$ is a theorem, the plug-in estimator's upward bias is a pure nuisance and a one-sided estimator is called for: a bias-corrected $\widehat\Delta$ with a valid upper confidence bound would turn the measured $+0.5189$ into a statement with a confidence interval rather than a point reading.

**Normalised reporting.** Because release and synergy are independent coordinates, routing tables should report the pair $(\Delta / (H_b(\mathsf R) - H_b(\mathsf N)),\ \mathrm{Syn}/H_b(T))$ rather than a percentage of the product row, which is unbounded and undefined when the product view reads zero.

---

## 14. Conclusion

The factor-residue hint value $\Delta = I(T;s,d) - I(T;N)$ is nonnegative for every battery, because $4pq = (p+q)^2 - (q-p)^2$ makes the product a function of the sum/difference pair. It equals the conditional entropy of the labels released by the hint, vanishes exactly under conditional independence given the product residue, is symmetric in the two factors, and is bounded by the label entropy, by the sum-row-plus-gap-entropy budget, and — sharply, and with modulus awareness — by $H(s,d) - H(N)$, which for the uniform battery over a field with $q$ elements is computed exactly by counting points on the hyperbolas $xy = n$. Explicit four-example batteries modulo $5$ show that the hint value can be exactly one bit where the hint-free channel reads exactly zero, that the label-entropy ceiling is attained, and that the two coordinates of the hint can be individually blind while jointly complete. A pre-registered hypothesis that the two views agree is therefore false as a universal statement — and could only ever have failed in the direction it did.
