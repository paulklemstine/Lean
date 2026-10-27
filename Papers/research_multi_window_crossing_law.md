# The Multi-Window Crossing Law: Step Posteriors, Layer Cakes, and a Polyhedral Gate for Oracle-Guided Search

**Aristotle**

*October 2026*

---

## Abstract

A target is hidden in one of $M$ cells. An oracle announces $k$ nested windows $[0,w_1)\subset\cdots\subset[0,w_k)$ together with cumulative reliabilities $\alpha_1\le\cdots\le\alpha_k$, the probabilities that the target lies in each window. We study the expected cost of exhaustive search orders under the resulting *step posterior* and ask which speedups over a fixed reference price are reachable. We prove the following. (i) The cost of committed (left-to-right) search equals $\sum_i(\alpha_i-\alpha_{i-1})$ times the mean slot of block $i$, which normalises to $M\Phi+\tfrac12$ for an explicit *gate functional* $\Phi$. (ii) A layer-cake displacement law expresses the cost of *every* order as a nonnegative combination of index sums of upper sets. Consequently committed search is Bayes-optimal among all $M!$ orders whenever the oracle is calibrated (block densities nonincreasing), and calibration cannot be dropped. (iii) An exact finite gate holds: speedup $s$ is reachable if and only if $s(M\Phi+\tfrac12)\le\beta_M$, where $\beta_M=(M+1)(2M+1)/(6M)$. Its continuum limit is the polyhedral condition $\Phi\le 1/(3s)$. (iv) $\Phi=1-\mathrm{AUC}$, where AUC is the area under the piecewise-linear reliability curve, so $s$ is reachable if and only if $\mathrm{AUC}\ge 1-1/(3s)$. (v) With one window the gate reduces to the classical crossing law $w\le\alpha-\alpha_{\min}(s)$, $\alpha_{\min}(s)=1-2/(3s)$. (vi) Structural results: the widest window must by itself clear the single-window threshold; an exact chord identity governs refinement; the gate is convex in the reliabilities and monotone in reliabilities and widths. We also show that the gate must include the complement block, since the version restricted to the named windows is false. A fully worked instance with $M=6$ and an anti-calibrated witness complete the picture.

---

## 1. Introduction

Advice about where to look rarely comes as a single point. It comes as nested confidence statements: "probably in the first ten, almost surely in the first thirty." Diagnostic triage, ranked retrieval, cones of forecast uncertainty and bug localisation all produce advice of this shape. We call such advice a *multi-window oracle*. This paper answers two questions about it.

1. **Which search order is optimal?** When is it right to simply trust the oracle and sweep outward?
2. **Which speedups are reachable?** Under a fixed pricing convention, for which window menus $(w_i,\alpha_i)$ can some search order beat a reference price by a factor $s$?

For a single window the answer is a classical *crossing law*: a window of relative width $w$ and reliability $\alpha$ supports speedup $s$ exactly when $w\le\alpha-\alpha_{\min}(s)$. Our main result, the **multi-window crossing law**, extends this to any number of nested windows. Reachability is decided by one linear inequality in the reliabilities. That inequality has a transparent geometric meaning: it is a lower bound on the area under a piecewise-linear reliability curve.

The key technical tool is a *displacement* (layer-cake) law. The cost of any order under a step posterior is a sum, over the density jumps, of the jump size times the index sum of the corresponding upper set. Each index sum is bounded below by a triangular number, with equality exactly for orders that place the upper set first. This one observation gives Bayes-optimality, the exact cost, and the gate.

**Contributions.** In summary, we prove the following.

* An explicit *block formula* for the cost of committed search under a step posterior, and its normalisation $M\Phi+\tfrac12$ in terms of a gate functional $\Phi$ that depends only on normalised boundaries and reliabilities (Theorem 3.1, Corollary 3.2).
* A *layer-cake displacement law* valid for every order, and the resulting Bayes-optimality of committed search for calibrated oracles, with an exact description of all optimal orders (Theorems 4.2 and 4.3).
* An *exact* reachability criterion at every finite $M$ (Theorem 5.1), its continuum limit (Theorems 5.2 and 5.4), and an equivalent *area* criterion (Corollary 6.2).
* Recovery of the single-window crossing law (Corollary 6.3), and new structural laws: the outer reliability gate, the chord refinement identity, convexity and monotonicity (Section 7).
* Two witnesses that delimit the theory: calibration is needed, and the complement block cannot be omitted (Section 8).

**Organisation.** Section 2 fixes the model. Section 3 computes the committed cost. Section 4 proves the layer-cake law and Bayes-optimality. Section 5 states the exact and continuum gates. Section 6 gives the area form and recovers the single-window law. Section 7 collects structural consequences. Section 8 records counterexamples showing that the hypotheses are needed. Section 9 works an instance in full. Section 10 describes algorithms, and Sections 11–12 discuss applications and open problems.

---

## 2. The model

**Cells and orders.** Fix an integer $M\ge1$ and cells $0,1,\dots,M-1$. A *search order* is a bijection $\sigma$ from cells to slots $\{0,\dots,M-1\}$: cell $j$ is probed at step $\sigma(j)+1$. For a probability vector $p=(p_0,\dots,p_{M-1})$, the *probe cost* of $\sigma$ is the expected number of probes until the target is found:
$$C(p,\sigma)=\sum_{j=0}^{M-1}\bigl(\sigma(j)+1\bigr)\,p_j .$$
The *committed order* is the identity, $\sigma(j)=j$.

**Window menus.** A menu with $n\ge1$ blocks consists of integer boundaries and real cumulative reliabilities
$$0=B_0<B_1<\cdots<B_n=M,\qquad 0=A_0\le A_1\le\cdots\le A_n=1 .$$
The windows named by the oracle are $[0,B_i)$ for $1\le i\le k:=n-1$, with reliabilities $\alpha_i=A_i$. The *blocks* are $[B_i,B_{i+1})$ for $0\le i<n$. The last block $[B_{n-1},M)$ is the **complement** of the widest window. It carries mass $1-\alpha_k$.

**Definition 2.1 (step posterior).** The *density* of block $i$ is
$$d_i=\frac{A_{i+1}-A_i}{B_{i+1}-B_i},$$
and the *step posterior* is $p_j=d_i$ for $B_i\le j<B_{i+1}$. Block $i$ thus carries total mass $A_{i+1}-A_i$, spread uniformly.

**Definition 2.2 (calibration).** The menu is *calibrated* if $d_0\ge d_1\ge\cdots\ge d_{n-1}$, that is, if the posterior is nonincreasing in the cell index.

**Definition 2.3 (normalised boundaries and gate functional).** Put $x_i=B_i/M\in[0,1]$, so that $x_0=0$ and $x_n=1$. The **gate functional** is
$$\Phi(x,A)=\sum_{i=0}^{n-1}(A_{i+1}-A_i)\,\frac{x_i+x_{i+1}}{2}.$$
It is the sum, over all blocks *including the complement*, of block mass times block midpoint.

**Definition 2.4 (pricing and speedup).** The *reference price* on $M$ cells is
$$\beta_M=\frac{(M+1)(2M+1)}{6M}=\frac1{M^2}\sum_{t=1}^{M}t^2\;\sim\;\frac M3 .$$
An order $\sigma$ *achieves speedup* $s>0$ if $s\cdot C(p,\sigma)\le\beta_M$. A speedup is *reachable* if some order achieves it. This pricing is a modelling stipulation. Every statement below is exact with respect to it.

---

## 3. The committed cost

**Theorem 3.1 (committed cost of a step posterior).** For every menu,
$$C(p,\mathrm{id})=\sum_{i=0}^{n-1}(A_{i+1}-A_i)\cdot\frac{B_i+B_{i+1}+1}{2}.$$
The factor $\tfrac12(B_i+B_{i+1}+1)$ is the mean (1-based) slot of block $i$ under committed search.

*Proof sketch.* Split the cost sum by blocks. On block $i$ the weight is constant, equal to $d_i$, and
$$\sum_{j=B_i}^{B_{i+1}-1}(j+1)=\frac{(B_{i+1}-B_i)(B_i+B_{i+1}+1)}{2},$$
which follows by induction on the upper endpoint. Multiplying by $d_i$ cancels the block width and leaves the block mass times the mean slot. $\square$

**Corollary 3.2 (normalised committed cost).**
$$C(p,\mathrm{id})=M\,\Phi(x,A)+\frac{A_n-A_0}{2}=M\,\Phi(x,A)+\frac12 .$$

*Proof sketch.* Write $\tfrac12(B_i+B_{i+1}+1)=M\cdot\tfrac12(x_i+x_{i+1})+\tfrac12$ and sum. The constant terms telescope to $\tfrac12(A_n-A_0)$. $\square$

---

## 4. The layer-cake displacement law and Bayes-optimality

For an order $\sigma$ and $0\le m\le M$, define the *index sum of the upper set* $[0,m)$:
$$S_\sigma(m)=\sum_{j<m}\bigl(\sigma(j)+1\bigr).$$

**Lemma 4.1 (exchange-sum bound).** For every order $\sigma$ and every $m$,
$$S_\sigma(m)\ \ge\ 1+2+\cdots+m=\frac{m(m+1)}2,$$
with equality if and only if $\sigma$ maps $[0,m)$ onto the slots $\{0,\dots,m-1\}$.

*Proof sketch.* The values $\sigma(0)+1,\dots,\sigma(m-1)+1$ are $m$ distinct positive integers. The sum of $m$ distinct positive integers is at least $1+\cdots+m$, with equality only for the set $\{1,\dots,m\}$. $\square$

**Theorem 4.2 (layer-cake displacement law).** Let $p$ be a calibrated step posterior, and set $d_n:=0$. For every order $\sigma$,
$$C(p,\sigma)=\sum_{i=0}^{n-1}(d_i-d_{i+1})\;S_\sigma(B_{i+1}),$$
and every coefficient $d_i-d_{i+1}$ is nonnegative.

*Proof sketch.* A nonincreasing step function is a stack of slabs:
$$p_j=\sum_{i=0}^{n-1}(d_i-d_{i+1})\,\mathbf 1[j<B_{i+1}].$$
To see this, note that for $j$ in block $r$ only the terms $i\ge r$ survive, and they telescope to $d_r$. Substitute into $C(p,\sigma)=\sum_j(\sigma(j)+1)p_j$ and exchange the order of summation. $\square$

The cost of an order is therefore a sum of the block-weight jumps times the index sums of the upper sets. This is the multi-step generalisation of the single-step displacement law.

**Theorem 4.3 (Bayes-optimality of committed search).** If the menu is calibrated, then for every order $\sigma$ on $M$ cells,
$$C(p,\mathrm{id})\le C(p,\sigma).$$
If moreover all densities are strictly decreasing, equality holds exactly for the orders that map every initial segment $[0,B_i)$ onto $\{0,\dots,B_i-1\}$, that is, the orders that permute cells only within blocks.

*Proof sketch.* By Theorem 4.2 the cost is a nonnegative combination of the $S_\sigma(B_{i+1})$. Each of these is minimised simultaneously by the identity (Lemma 4.1). When all jumps $d_i-d_{i+1}$ ($0\le i<n-1$) are positive, equality forces equality in every Lemma 4.1 instance with $m=B_1,\dots,B_{n-1}$. So $\sigma$ maps each $[0,B_i)$ onto $\{0,\dots,B_i-1\}$, and hence maps each block $[B_i,B_{i+1})$ onto the slots $\{B_i,\dots,B_{i+1}-1\}$. The final term, $m=M$, is the same for every order. Conversely, any such block-preserving order attains every bound. $\square$

**Remark 4.4 (counting optimal orders).** Under strictly decreasing densities the optimal orders are exactly the products of arbitrary permutations of the blocks, so there are $\prod_i(B_{i+1}-B_i)!$ of them. For block sizes $1,2,3$ this gives $1!\cdot2!\cdot3!=12$.

**Remark 4.5 (the general principle).** Theorem 4.3 is a sharp form of the rearrangement inequality: an expected position is minimised by matching the largest probabilities with the earliest slots. The layer-cake form adds two things. It shows *where* the slack of a suboptimal order goes (into the upper sets it fails to front-load), and it gives a linear certificate of optimality that is checked block by block rather than cell by cell. When some densities tie, the coefficient of the corresponding upper set vanishes and the freedom in that upper set is exactly the freedom among optimal orders.

Committed search is thus Bayes-optimal: under a calibrated oracle, trusting it is optimal among all $M!$ orders. Without calibration this fails (Proposition 8.1).

---

## 5. The crossing law

**Theorem 5.1 (exact finite gate).** For a calibrated menu on $M$ cells and any $s>0$,
$$\exists\,\sigma:\ s\,C(p,\sigma)\le\beta_M\quad\Longleftrightarrow\quad s\Bigl(M\,\Phi(x,A)+\tfrac12\Bigr)\le\beta_M .$$

*Proof sketch.* By Theorem 4.3 the minimum of $C(p,\sigma)$ over all orders is attained at the identity. By Corollary 3.2 this minimum equals $M\Phi+\tfrac12$. $\square$

The gate is *polyhedral*: for fixed boundaries, $\Phi$ is affine in $(A_1,\dots,A_{n-1})$, so the set of reachable reliability profiles is the intersection of the ordering simplex with one half-space.

**Theorem 5.2 (continuum limit).** For every $\Phi>0$ and every real offset $c$,
$$\lim_{M\to\infty}\frac{\beta_M}{M\Phi+c}=\frac1{3\Phi}.$$

*Proof sketch.* Divide numerator and denominator by $M$:
$$\frac{\beta_M}{M\Phi+c}=\frac{(1+\tfrac1M)(2+\tfrac1M)/6}{\Phi+c/M}\longrightarrow\frac{2/6}{\Phi}. \qquad\square$$

Applying Theorem 5.2 with $c=\tfrac12$ along a family of menus with fixed normalised profile $(x,A)$ shows that the largest reachable speedup converges to $s^\ast=1/(3\Phi)$. This motivates the following definition.

**Definition 5.3.** The *continuum speedup* of a profile is $s^\ast(x,A)=1/(3\Phi(x,A))$. Speedup $s$ is *continuum-reachable* if $s\le s^\ast$.

Note that $\Phi>0$ always: by Theorem 6.1 below, $\Phi=1-\mathrm{AUC}$, and $\mathrm{AUC}<1$ because $x_1>0$ forces the reliability curve to start below $1$.

**Theorem 5.4 (multi-window crossing law).** For $s>0$,
$$s\le\frac1{3\Phi}\quad\Longleftrightarrow\quad\Phi\le\frac1{3s}\quad\Longleftrightarrow\quad\sum_{i=0}^{n-1}(A_{i+1}-A_i)\cdot\frac{x_i+x_{i+1}}2\ \le\ \frac1{3s}.$$
In the notation of the oracle: speedup $s$ is reachable if and only if the sum, over the $k$ named blocks *and the complement block*, of the reliability jump times the (normalised) mean slot of the block is at most $1/(3s)$.

*Proof sketch.* Both sides are positive, so take reciprocals. $\square$

---

## 6. The area form and the single-window law

The *reliability curve* $F$ of a profile is the piecewise-linear function on $[0,1]$ through the points $(x_0,A_0)=(0,0),\ (x_1,A_1),\ \dots,\ (x_n,A_n)=(1,1)$. Let $\mathrm{AUC}=\int_0^1F$.

**Theorem 6.1 (gate functional plus area).**
$$\Phi(x,A)+\mathrm{AUC}=x_nA_n-x_0A_0=1 .$$

*Proof sketch.* By the trapezoid rule, $\mathrm{AUC}=\sum_i(x_{i+1}-x_i)\tfrac{A_i+A_{i+1}}2$. Adding $\Phi$ term by term,
$$(A_{i+1}-A_i)\tfrac{x_i+x_{i+1}}2+(x_{i+1}-x_i)\tfrac{A_i+A_{i+1}}2=x_{i+1}A_{i+1}-x_iA_i,$$
which telescopes. This is summation by parts for polygons. $\square$

**Corollary 6.2 (AUC crossing law).** Speedup $s$ is continuum-reachable if and only if
$$\mathrm{AUC}\ \ge\ 1-\frac1{3s}.$$

An uninformative oracle has $F(x)=x$, $\mathrm{AUC}=\tfrac12$ and $s^\ast=\tfrac23$. Every bit of area added above the diagonal translates into speedup.

**Corollary 6.3 (single-window crossing law).** For $n=2$, with one window of relative width $w=x_1$ and reliability $\alpha=A_1$,
$$\Phi=\frac{w+1-\alpha}{2},$$
and speedup $s$ is reachable if and only if
$$w\ \le\ \alpha-\alpha_{\min}(s),\qquad \alpha_{\min}(s)=1-\frac2{3s}.$$

*Proof sketch.* $\Phi=\alpha\cdot\tfrac w2+(1-\alpha)\tfrac{w+1}2=\tfrac{w+1-\alpha}2$. The inequality $\Phi\le\tfrac1{3s}$ rearranges to $w\le\alpha-1+\tfrac2{3s}$. $\square$

The multi-window law therefore contains the classical crossing law as its $k=1$ case.

---

## 7. Structural consequences

**Theorem 7.1 (outer reliability gate).** Let $w_k=x_{n-1}$ and $\alpha_k=A_{n-1}$ be the relative width and reliability of the widest window. If $s$ is continuum-reachable, then
$$\alpha_k\ \ge\ \alpha_{\min}(s)+w_k(1-\alpha_k).$$
In particular $\alpha_k>\alpha_{\min}(s)$ whenever $0<w_k$ and $\alpha_k<1$. No configuration of inner windows can substitute for reliability of the outer window.

*Proof sketch.* Since $F$ is nondecreasing, $F\le\alpha_k$ on $[0,w_k]$. On $[w_k,1]$, $F$ is the segment from $\alpha_k$ to $1$. Hence
$$\mathrm{AUC}\le\alpha_kw_k+(1-w_k)\frac{1+\alpha_k}2=\frac{1+\alpha_k}2-\frac{w_k(1-\alpha_k)}2 .$$
Corollary 6.2 together with $1-\tfrac1{3s}=\tfrac{1+\alpha_{\min}(s)}2$ gives the claim. $\square$

**Theorem 7.2 (refinement identity).** Insert a new point $(x',\alpha')$ with $x_\ell<x'<x_r$ between consecutive corners $(x_\ell,\alpha_\ell)$, $(x_r,\alpha_r)$ of the profile. Let
$$\mathrm{chord}(x')=\alpha_\ell+(\alpha_r-\alpha_\ell)\frac{x'-x_\ell}{x_r-x_\ell}.$$
Then
$$\Phi_{\text{new}}-\Phi_{\text{old}}=-\frac{(x_r-x_\ell)\,\bigl(\alpha'-\mathrm{chord}(x')\bigr)}2 .$$

*Proof sketch.* By Theorem 6.1, $\Delta\Phi=-\Delta\mathrm{AUC}$. The area changes by the signed area of the triangle with vertices $(x_\ell,\alpha_\ell)$, $(x',\alpha')$, $(x_r,\alpha_r)$. That triangle has a vertical side of height $\alpha'-\mathrm{chord}(x')$ at $x'$ and horizontal extent $x_r-x_\ell$. $\square$

**Corollary 7.3 (when a new window helps).** A new window strictly lowers $\Phi$, and so strictly raises the continuum speedup, if and only if it lies strictly above the chord of its neighbours. It is neutral on the chord and harmful below it.

**Proposition 7.4 (affinity and convexity).** For fixed boundaries $x$, the map $A\mapsto\Phi(x,A)$ is affine. Hence for each $s$, the set of reliability profiles $(A_1,\dots,A_{n-1})$ that reach $s$ is convex (indeed polyhedral). Blending two oracles that each reach $s$ yields an oracle that reaches $s$.

**Proposition 7.5 (monotonicity).** For $0<i<n$,
$$\frac{\partial\Phi}{\partial A_i}=-\frac{x_{i+1}-x_{i-1}}2<0,\qquad\frac{\partial\Phi}{\partial x_i}=\frac{A_{i+1}-A_{i-1}}2\ge0 .$$
More reliability always helps; more width always hurts (weakly).

*Proof sketch.* $A_i$ appears in exactly two terms of $\Phi$, and so does $x_i$. Differentiate. $\square$

**Example 7.6 (oracle design as a linear program).** Fix the widths of the worked instance of Section 9, $x=(0,\tfrac16,\tfrac12,1)$, and leave the reliabilities $A_1=\alpha_1$, $A_2=\alpha_2$ free. Expanding the definition,
$$\Phi=\tfrac{1}{12}\alpha_1+\tfrac13(\alpha_2-\alpha_1)+\tfrac34(1-\alpha_2)=\tfrac34-\tfrac14\alpha_1-\tfrac5{12}\alpha_2 .$$
The continuum gate for target $s$ is therefore the half-plane
$$\tfrac14\alpha_1+\tfrac5{12}\alpha_2\ \ge\ \tfrac34-\tfrac1{3s},$$
intersected with the calibration cone $6\alpha_1\ge3(\alpha_2-\alpha_1)\ge2(1-\alpha_2)$. For $s=\tfrac32$ the right-hand side is $\tfrac{19}{36}$. If the outer reliability stays at $\alpha_2=\tfrac56$, the inner window needs $\alpha_1\ge\tfrac{13}{18}\approx0.722$, and this choice is still calibrated: the densities are $\tfrac{13}3\ge\tfrac13\ge\tfrac13$. If instead the inner reliability stays at $\alpha_1=\tfrac12$, the outer window needs $\alpha_2\ge\tfrac{29}{30}$. Both targets respect the outer gate, which for $s=\tfrac32$ and $w_2=\tfrac12$ demands $\alpha_2\ge\tfrac{19}{27}\approx0.704$. A designer who can certify reliabilities only up to given caps can trade them off along the line $\tfrac14\alpha_1+\tfrac5{12}\alpha_2=\text{const}$. The weights $\tfrac14=\tfrac12(x_2-x_0)$ and $\tfrac5{12}=\tfrac12(x_3-x_1)$ are exactly the marginal values of Proposition 7.5.

**Remark 7.7 (range of the gate functional).** Since $\Phi=1-\mathrm{AUC}$ and the reliability curve lies between the axis and the constant $1$, we have $0<\Phi<1$. Calibrated curves are concave and lie above the diagonal, so for them $\Phi\le\tfrac12$ and $s^\ast\ge\tfrac23$. An informative calibrated oracle therefore never does worse than the uninformed baseline. Anti-calibrated curves lie below the diagonal and have $\Phi\ge\tfrac12$ for committed search; Proposition 8.1 shows that such advice should be read in reverse.

---

## 8. The hypotheses are needed

**Proposition 8.1 (calibration cannot be dropped).** Take $M=6$ with blocks $[0,3)$ and $[3,6)$ of masses $\tfrac1{10}$ and $\tfrac9{10}$, so $d_0=\tfrac1{30}<d_1=\tfrac3{10}$. Then the reversed order $\sigma(j)=5-j$ has cost $\tfrac{23}{10}$, while committed search costs $\tfrac{47}{10}$.

*Proof.* Committed: $\tfrac1{10}\cdot2+\tfrac9{10}\cdot5=\tfrac{47}{10}$. Reversed: the first block occupies slots $6,5,4$ (mean $5$) and the second occupies slots $3,2,1$ (mean $2$), giving $\tfrac1{10}\cdot5+\tfrac9{10}\cdot2=\tfrac{23}{10}$. $\square$

Hence "reachable if and only if the committed gate holds" requires calibration. For an anti-calibrated oracle, the Bayes searcher reorders blocks by density.

**Proposition 8.2 (the complement block is indispensable).** The *naive gate* $\sum_{i=1}^{k}(\alpha_i-\alpha_{i-1})\tfrac{x_{i-1}+x_i}2\le\tfrac1{3s}$, summed over the named windows only, does not characterise reachability. With $k=1$, $w=\tfrac12$, $\alpha=\tfrac1{10}$ and $s=1$, the naive sum is $\tfrac1{40}\le\tfrac13$, yet $\Phi=\tfrac{7}{10}>\tfrac13$.

The mass $1-\alpha_k$ outside the widest window is searched last. It contributes the largest midpoints and frequently dominates the cost.

---

## 9. A worked instance

Let $M=6$ with boundaries $B=(0,1,3,6)$ (windows of widths $1$ and $3$) and reliabilities $A=(0,\tfrac12,\tfrac56,1)$.

* Block masses are $\tfrac12,\tfrac13,\tfrac16$. Densities are $\tfrac12,\tfrac16,\tfrac1{18}$, which are decreasing, so the menu is calibrated. The posterior is $(\tfrac12,\tfrac16,\tfrac16,\tfrac1{18},\tfrac1{18},\tfrac1{18})$.
* Committed cost (Theorem 3.1): $\tfrac12\cdot1+\tfrac13\cdot\tfrac52+\tfrac16\cdot5=\tfrac{13}6$.
* By Theorem 4.3, $\tfrac{13}6\le C(p,\sigma)$ for all $6!=720$ orders. Exhaustive enumeration confirms this, and finds exactly $1!\,2!\,3!=12$ optimal orders and a worst cost of $\tfrac{29}6$.
* With $x=(0,\tfrac16,\tfrac12,1)$: $\Phi=\tfrac5{18}$, $\mathrm{AUC}=\tfrac{13}{18}$, and $6\Phi+\tfrac12=\tfrac{13}6$.
* $\beta_6=\tfrac{91}{36}$, so the largest reachable speedup at $M=6$ is $\tfrac{91/36}{13/6}=\tfrac76$. Scaling the profile to $M=60,600,6000$ gives approximately $1.19434$, $1.19940$ and $1.19994$, converging to $s^\ast=1/(3\Phi)=\tfrac65$.
* Outer gate: for $s=\tfrac65$, $\alpha_{\min}=\tfrac49$ and $\alpha_{\min}+w_2(1-\alpha_2)=\tfrac49+\tfrac1{12}=\tfrac{19}{36}\le\tfrac56$.

---

## 10. Algorithms

**Algorithm A (gate test).** Input: boundaries $B$ and reliabilities $A$, a target $s$, and optionally $M$. Compute $x_i=B_i/M$, then $\Phi=\sum_i(A_{i+1}-A_i)(x_i+x_{i+1})/2$. Return the finite verdict $s(M\Phi+\tfrac12)\le\beta_M$ (valid when calibrated) and the continuum verdict $\Phi\le1/(3s)$. Cost: $O(n)$ arithmetic operations, independent of $M$.

**Algorithm B (Bayes order and cost).** Sort cells by decreasing posterior weight. For a step posterior it suffices to sort the $n$ blocks by density, in $O(n\log n)$ time, and then emit cells block by block. The cost is $\sum_t t\,p_{(t)}$. For a calibrated menu this is the committed order (Theorem 4.3).

**Algorithm C (refinement screening).** Given a candidate new window $(x',\alpha')$, locate its neighbours by binary search ($O(\log n)$), compute the chord height, and report $\Delta\Phi=-(x_r-x_\ell)(\alpha'-\mathrm{chord})/2$ by Theorem 7.2. Greedy menu design repeatedly inserts the candidate with the most negative $\Delta\Phi$.

---

## 11. Discussion and applications

The gate is linear in the oracle's claims, which makes oracle design a linear-programming question. For example, minimise total width subject to reaching $s$ with reliabilities bounded by what a forecaster can certify. The area form connects the theory to ROC-style evaluation: an oracle's worth under this pricing is exactly the area under its cumulative reliability curve. The refinement identity gives a local, geometric criterion for whether a new confidence window is worth announcing. The outer gate and the failure of the naive gate express one robust lesson: an oracle is judged as much by the probability it leaves outside its windows as by what it puts inside them.

**Relation to classical ideas.** Three classical tools sit underneath the results. The rearrangement inequality explains why probing cells in order of decreasing posterior is optimal. The layer-cake representation of a nonnegative function as an integral of indicator functions of its upper level sets turns that inequality into a linear certificate. Summation by parts (discrete integration by parts) converts the gate functional, a sum of masses times midpoints, into an area deficit. What is specific to the multi-window setting is how these combine. The upper level sets of a step posterior are exactly the named windows, so the certificate, the cost and the gate are all indexed by the oracle's own statements. That is why the final criterion is linear in the stated reliabilities.

**Robustness of the qualitative picture.** The gate depends on the menu only through the polygon $(x_i,\alpha_i)$. Two oracles that draw the same reliability polygon are therefore equally valuable, however differently they phrase their windows. In particular, announcing a window that lies on the chord of its neighbours is pure noise (Corollary 7.3). This invariance makes the area criterion a natural summary statistic for comparing advice sources with different window menus.

The single pricing convention $\beta_M\sim M/3$ is a stipulation. The structural results (Theorems 3.1, 4.2, 4.3, 6.1, 7.2 and Propositions 7.4–7.5) do not depend on it. Only the threshold constant $1/(3s)$ does.

---

## 12. Open problems

1. **Concave-majorant Bayes gate.** For a non-calibrated step posterior the Bayes searcher sorts blocks by density. Sorting blocks by density is exactly the concave rearrangement of the reliability curve. We conjecture that the Bayes speedup is governed by the AUC of that rearrangement.
2. **Refinement monotonicity for calibrated oracles.** A calibrated reliability curve is concave, so every new calibrated point should lie on or above its chord. By Theorem 7.2, inserting a calibrated window should then never lower the speedup, and should strictly raise it off the chord.
3. **Optimal $k$-window menus.** For a continuous concave reliability curve, the best $k$-window piecewise-linear approximation should lose $\Theta(1/k^2)$ in AUC (trapezoid-rule error), so the gap to full-information speedup should close like $1/k^2$.
4. **Two-sided multi-window gate.** For Bayes search without calibration, each density order of the blocks gives a linear gate. The reachable set should be a union of polyhedra indexed by these orders.

---

## Appendix: notation summary

| Symbol | Meaning |
|---|---|
| $M$ | number of cells |
| $B_i$, $x_i=B_i/M$ | block boundaries (absolute, normalised) |
| $A_i$ ($=\alpha_i$) | cumulative reliabilities, $A_0=0$, $A_n=1$ |
| $d_i$ | density of block $i$ |
| $C(p,\sigma)$ | expected number of probes of order $\sigma$ |
| $\beta_M$ | reference price $(M+1)(2M+1)/(6M)$ |
| $\Phi$ | gate functional $\sum(A_{i+1}-A_i)(x_i+x_{i+1})/2$ |
| $\mathrm{AUC}$ | area under the reliability curve, $=1-\Phi$ |
| $\alpha_{\min}(s)$ | single-window threshold $1-2/(3s)$ |
