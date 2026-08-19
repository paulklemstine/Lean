# The Geometry of a Knee Distribution: Fermat–Weber Centres, Projections, and Scaling Rays

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

We develop the one-dimensional Fermat–Weber (geometric median) theory needed to analyse a family of empirical *knee distributions*, and we use it to convert a set of informal empirical claims into sharp, falsifiable geometric statements.

The empirical setting is a threshold-search experiment: at each context length $\mathrm{ctx}$ one measures the smallest budget $k^\*$ at which a quality metric still clears a fixed bar. The measurement is seed-dependent. Three repetitions at $\mathrm{ctx}=1024$ gave $\{96,112,128\}$; three at $\mathrm{ctx}=2048$ gave $\{160,224,256\}$. Writing $P = d\cdot\mathrm{ctx}/32$ for the natural *product point* of the experiment ($P=128$ and $P=256$ respectively), the two medians are $112 = \tfrac78 P$ and $224 = \tfrac78 P$, while individual seeds scatter over $\{0.75,0.875,1.0\}\cdot P$ and $\{0.625,0.875,1.0\}\cdot P$.

Our contributions are as follows.

1. **A complete characterisation of Fermat–Weber points on a line.** For a multiset $S$ in a linearly ordered abelian group, a point $m$ minimises $F_S(t)=\sum_{x\in S}|t-x|$ if and only if $m$ is *balanced*: $\#\{x>m\} \le \#\{x\le m\}$ and $\#\{x<m\}\le\#\{x\ge m\}$. Sufficiency holds in any linearly ordered abelian group; necessity is proved over $\mathbb{R}$ by a finitary witness argument (the step is to the nearest datum on the heavy side). Together with convexity of $F_S$ this shows the minimiser set is a closed interval: a point for odd samples, a segment for even ones.

2. **A sharp slope bound for odd samples.** If $m$ is the counting median of a sample of odd size $2k+1$, then $F_S(m) + |t-m| \le F_S(t)$ for every $t$. Minimality and uniqueness follow at once, and the bound is metric-space-general: in any metric space, a metrically between point of a triple is its unique geometric median, with optimal cost equal to the diameter.

3. **The median of three as a metric projection.** With two arguments fixed, $x \mapsto \operatorname{med}(a,b,x)$ is the nearest-point projection of $\mathbb{R}$ onto the segment $[a\wedge b,\, a\vee b]$. It is monotone, $1$-Lipschitz, and firmly nonexpansive; its fibres over the endpoints are the normal half-lines and over interior points are singletons; its range is the compact segment, whereas the mean of three is a surjection onto $\mathbb{R}$.

4. **Scaling geometry.** Plotting measurements as points $(\mathrm{ctx},k^\*)$, the top edge and the median lie on rays through the origin of slopes $1/8$ and $7/64 = \tfrac78\cdot\tfrac18$; the median slope is uniquely determined by one context and confirmed by the other. The low tail lies on no such ray: the associated determinant is $-32768$ and the origin triangle has area $16384$. Doubling the context is a dilation that is equivariant on the top edge and the median but has low-tail defect exactly $32 = P/8$; no dilation matches the entire configuration. Normalising, the optimal Fermat–Weber costs are $1/4$ and $3/8$, in exact ratio $3/2$, and the entire increase is carried by the low coordinate.

5. **A level-set statement.** Both normalised triples lie on the maximal half-line $\{(t,7/8,1): t\le 7/8\}$ contained in the level set $\{\operatorname{med} = 7/8\}$, hence so does the segment joining them; the level set itself is not convex, so this is a genuine structural fact about the data.

6. **A pre-registered prediction for a pending fourth measurement.** For every possible fourth value $x$, the point $224$ remains an optimal centre of $\{160,224,256,x\}$, the optimal cost is exactly $96 + |224-x|$, the optimal set is $[x,224]$ when $x\in[160,224]$ and $[224,x]$ when $x\in[224,256]$, and the optimum is unique only in the knife-edge case $x=224$. Consequently a fourth measurement cannot refute the $7/8$ centre variationally; it can only destroy uniqueness. What it tests is the low tail.

**Keywords:** Fermat–Weber point, geometric median, metric projection, firm nonexpansiveness, order statistics, dilation equivariance, level sets, knee distribution.

---

## 1. Introduction

### 1.1 The empirical setting

Consider an experiment parameterised by a depth $d$ and a context length $\mathrm{ctx}$. For a budget $k$ one measures a quality ratio $q(k) \in [0,1]$ — the performance retained at budget $k$ relative to full budget — and defines the **knee**

$$k^\* \;=\; \min\{k \text{ in the sweep grid}\ :\ q(k) \ge \beta\}$$

for a fixed bar $\beta$ (here $\beta = 0.98$). The quantity $k^\*$ is the deployable budget: the smallest cost at which quality is still acceptable.

Two structural constants organise the data. The first is the **product point**

$$P \;=\; \frac{d\cdot\mathrm{ctx}}{32},$$

which at $(d,\mathrm{ctx}) = (4,1024)$ equals $128$ and at $(4,2048)$ equals $256$. Empirically $k^\* \le P$ at every seed measured, at both contexts — six for six — which makes $P$ a usable upper bound rather than a trend. The second constant is the ratio $7/8$, which appears not in any single measurement but in the *centre* of the measured distribution.

The dataset, complete at three seeds per context, is:

| context | knees $k^\*$ | product point $P$ | ratios $k^\*/P$ | median |
|---|---|---|---|---|
| $1024$ | $\{96,\,112,\,128\}$ | $128$ | $\{3/4,\ 7/8,\ 1\}$ | $112 = \tfrac78\cdot 128$ |
| $2048$ | $\{160,\,224,\,256\}$ | $256$ | $\{5/8,\ 7/8,\ 1\}$ | $224 = \tfrac78\cdot 256$ |

The most recent measurement (the third seed at $\mathrm{ctx}=2048$) returned $k^\*=160$, crossing the bar with margin $+0.0012$ — the tightest of the series, indicating a true threshold near $150$–$160$ that falls between grid points. Four point predictions had been recorded in advance ($224$, $240$, $256$, $192$); all four were refuted. The distributional claim — that the median sits at $\tfrac78 P$ — was not.

### 1.2 Why the median, and why geometry

The naive reading of "the median is robust" is statistical folklore. This paper takes the geometric reading instead, which is sharper and gives quantitative bounds.

On a line, the median coincides with the **Fermat–Weber point**, i.e. the minimiser of total distance to the sample. Once the median is understood variationally, three things follow that a sorting definition does not deliver:

* a *quantitative* stability bound (how far can a datum move before the centre moves?), obtained from the projection structure;
* a *characterisation* valid at every sample size and parity, which tells us exactly what happens when the sample size flips from odd to even;
* a *scaling* analysis, since Fermat–Weber cost is a genuine transport cost that can be compared across contexts.

All three are needed to state the pending experiment's prediction correctly.

### 1.3 Notation

Sample data are finite multisets. For a multiset $S$ of reals (or, more generally, of a linearly ordered abelian group $\alpha$) and $t\in\alpha$, the **Fermat–Weber cost** is

$$F_S(t) \;=\; \sum_{x\in S} |t - x|,$$

with multiplicity. We write $a\wedge b = \min(a,b)$, $a\vee b = \max(a,b)$, and

$$\operatorname{med}(a,b,c) \;=\; (a\wedge b)\vee(b\wedge c)\vee(a\wedge c)$$

for the median of three, in the $(\max,\min)$ form that makes its lattice-polynomial nature explicit. For a sample of odd size $2k+1$, we say $m$ is a **counting median** if at least $k+1$ entries are $\le m$ and at least $k+1$ entries are $\ge m$.

---

## 2. Fermat–Weber points of a triple: the metric-space core

We begin with the smallest statement, because it is the one that generalises furthest.

**Definition 2.1 (metric betweenness).** In a metric space $(X,d)$, a point $q$ lies *metrically between* $p$ and $r$ if $d(p,q) + d(q,r) = d(p,r)$.

**Theorem 2.2 (triple lower bound).** For any points $p,q,r,x$ of a metric space,
$$d(p,r) + d(x,q) \;\le\; d(x,p) + d(x,q) + d(x,r).$$

*Proof.* The triangle inequality gives $d(p,r)\le d(p,x)+d(x,r) = d(x,p)+d(x,r)$; add $d(x,q)$. $\square$

**Theorem 2.3 (betweenness points are geometric medians).** If $q$ lies metrically between $p$ and $r$, then for every $x$,
$$d(x,p)+d(x,q)+d(x,r) \;\ge\; d(p,r),$$
with equality **if and only if** $x = q$. The optimal value is the diameter $d(p,r)$, attained at $q$.

*Proof.* The value at $q$ is $d(q,p)+0+d(q,r) = d(p,r)$ by betweenness, so the bound is attained. For the lower bound and rigidity, Theorem 2.2 gives
$$d(x,p)+d(x,q)+d(x,r) \;\ge\; d(p,r) + d(x,q),$$
so the total is $\ge d(p,r)$, with equality forcing $d(x,q) = 0$, i.e. $x=q$. Conversely $x=q$ attains it. $\square$

Theorem 2.3 is the whole of the odd three-point theory, and it is remarkably cheap: no convexity, no differentiability, no ordering. Everything below specialises it.

**Corollary 2.4 (the real line).** For $a\le b\le c$ and $x\in\mathbb{R}$,
$$|x-a| + |x-b| + |x-c| \;\ge\; c-a,$$
with equality iff $x = b$; and any $x$ attaining the bound satisfies $x = \operatorname{med}(a,b,c)$.

*Proof.* On $\mathbb{R}$ with $d(u,v)=|u-v|$, sortedness gives $|a-b| + |b-c| = (b-a)+(c-b) = c-a = |a-c|$, i.e. $b$ is metrically between $a$ and $c$; apply Theorem 2.3. The identification with $\operatorname{med}$ is the evaluation $(a\wedge b)\vee(b\wedge c)\vee(a\wedge c) = a\vee b\vee(a\wedge c)= b$ under $a\le b\le c$. $\square$

**Corollary 2.5 (collinear data in a normed space).** Let $E$ be a real normed space, $v\in E$, $u\in E$ with $\|u\|=1$, and $a\le b\le c$. Then for every $x\in E$,
$$d(x, v+au) + d(x, v+bu) + d(x, v+cu) \;\ge\; c-a,$$
with equality iff $x = v + bu$.

*Proof.* $d(v+su, v+tu) = \|(s-t)u\| = |s-t|$, so the three points reproduce the configuration of Corollary 2.4 and $v+bu$ is metrically between the others; apply Theorem 2.3. $\square$

Corollary 2.5 matters because it says the minimiser is unique *in the ambient space*, not merely along the line: no off-line point does better. Data that happen to be collinear have a geometric median that is stable against the dimension of the space they are embedded in.

**Application 2.6 (the measured triples).** Applying Corollary 2.4:

* $\{160,224,256\}$: for all $x$, $|x-160|+|x-224|+|x-256| \ge 96$, with equality iff $x=224$. The unique geometric median is $224 = \tfrac78\cdot 256$, with optimal cost $96$.
* $\{96,112,128\}$: for all $x$, $|x-96|+|x-112|+|x-128| \ge 32$, with equality iff $x=112$. The unique geometric median is $112 = \tfrac78\cdot 128$, with optimal cost $32$.

So the "$7/8$-median law" is a variational statement: the value $\tfrac78 P$ is the unique minimiser of total distance to the measured knees at both contexts.

---

## 3. The general characterisation: balanced points

The triple theory does not survive the change of parity, so we develop the general statement.

**Definition 3.1 (balance).** Let $S$ be a finite multiset in a linearly ordered abelian group $\alpha$ and $m\in\alpha$. Say $m$ is **balanced** for $S$ if
$$\#\{x\in S : x > m\} \;\le\; \#\{x\in S : x\le m\} \quad\text{and}\quad \#\{x\in S : x<m\}\;\le\;\#\{x\in S : x\ge m\}.$$

Equivalently: neither open side of $m$ contains more than half of the sample.

**Lemma 3.2 (two-valued sums).** For a finite multiset $S$, a decidable predicate $p$, and constants $c,d$ in an abelian group,
$$\sum_{x\in S}\bigl(\text{$c$ if $p(x)$, else $d$}\bigr) \;=\; \#\{x : p(x)\}\cdot c \;+\; \#\{x : \neg p(x)\}\cdot d .$$

*Proof.* Induction on $S$. $\square$

This bookkeeping lemma is the engine of everything in this section: it converts a pointwise comparison into a comparison of *counts*.

**Theorem 3.3 (sufficiency).** Let $S$ be a finite multiset in a linearly ordered abelian group and let $m$ be balanced for $S$. Then $F_S(m) \le F_S(t)$ for every $t$.

*Proof.* Suppose first $m \le t$. Set $A = \#\{x\le m\}$, $C = \#\{x>m\}$, so balance gives $C\le A$. The pointwise inequality
$$|m-x| \;+\; \begin{cases} t-m, & x\le m\\ -(t-m), & x>m\end{cases} \;\le\; |t-x|$$
holds for every $x$: if $x\le m$ both absolute values open positively and the left side equals $|t-x|$ exactly; if $x>m$ the left side is $-(m-x)-(t-m) = -(t-x) \le |t-x|$. Summing over $S$ and applying Lemma 3.2,
$$F_S(m) \;+\; A\cdot(t-m) \;+\; C\cdot\bigl(-(t-m)\bigr) \;\le\; F_S(t).$$
Writing $A = C + r$ with $r\ge 0$, the middle terms collapse to $r\cdot(t-m)\ge 0$, so $F_S(m) \le F_S(t)$. The case $t\le m$ is symmetric, using the other half of balance. $\square$

Note the proof uses only ordered-group arithmetic: no completeness, no archimedean property, no division. The *only* input is the counting condition.

**Theorem 3.4 (odd samples: the counting median is balanced).** If $|S| = 2k+1$ and $m$ is a counting median of $S$, then $m$ is balanced.

*Proof.* $\#\{x\le m\}\ge k+1$ and $\#\{x\le m\}+\#\{x>m\} = 2k+1$ give $\#\{x>m\}\le k \le \#\{x\le m\}$; symmetrically for the other side. $\square$

Combining Theorems 3.3 and 3.4 recovers the classical statement — but we can say more for odd samples, because the count gap is then at least one.

**Theorem 3.5 (sharp slope bound).** Let $|S| = 2k+1$ and let $m$ be a counting median. Then for every $t$,
$$F_S(m) + |t-m| \;\le\; F_S(t).$$

*Proof.* Take $m\le t$ (the other case is symmetric). With $A,C$ as above, $A\ge k+1$ and $A+C = 2k+1$ give $C+1\le A$. Repeating the computation of Theorem 3.3 but writing $A = C + r + 1$, the collapse now leaves $r\cdot(t-m) + (t-m) \ge t-m$, so $F_S(m) + (t-m) \le F_S(t)$. $\square$

**Corollary 3.6 (uniqueness for odd samples).** For $|S|$ odd with counting median $m$: $F_S(m) < F_S(t)$ for all $t\ne m$, and any minimiser of $F_S$ equals $m$. In particular the Fermat–Weber point of an odd sample is unique.

Theorem 3.5 is stronger than mere minimality: it says the cost landscape has slope at least $1$ in each direction away from the median, so a perturbation of the centre by $\delta$ costs at least $\delta$. This is the quantitative form of "the median is a sharp minimum".

### 3.1 Necessity

Sufficiency was purely combinatorial. Necessity requires that we can *step to a witness*, so we work over $\mathbb{R}$ and use the fact that a finite sample has a nearest point on each side.

**Lemma 3.7 (exact cost of a gap-free step).** Let $S\subset\mathbb{R}$ be a finite multiset and $m\le t$ with the property that no sample point lies strictly between $m$ and $t$ (formally, $x\in S$ and $x>m$ imply $x\ge t$). Then
$$F_S(t) \;=\; F_S(m) \;+\; \bigl(\#\{x\le m\} - \#\{x>m\}\bigr)\cdot(t-m).$$
Symmetrically, for a leftward gap-free step to $t \le m$,
$$F_S(t) \;=\; F_S(m) \;+\; \bigl(\#\{x\ge m\} - \#\{x<m\}\bigr)\cdot(m-t).$$

*Proof.* Under the gap hypothesis every $x$ satisfies $|t-x| = |m-x| + (t-m)$ if $x\le m$ and $|t-x| = |m-x| - (t-m)$ if $x>m$ — the absolute values do not change sign. Sum and apply Lemma 3.2. $\square$

**Theorem 3.8 (necessity).** If $m\in\mathbb{R}$ minimises $F_S$, then $m$ is balanced for $S$.

*Proof.* Suppose the first balance condition fails: $A = \#\{x\le m\} < C = \#\{x>m\}$. Then $C>0$, so the set of sample points exceeding $m$ is nonempty and finite; let $t$ be its minimum. Then $m<t$ and no sample point lies strictly between, so Lemma 3.7 applies:
$$F_S(t) = F_S(m) + (A - C)(t-m) < F_S(m),$$
since $A-C<0$ and $t-m>0$ — contradicting minimality. The second condition is symmetric, stepping to the maximum of $\{x<m\}$. $\square$

**Theorem 3.9 (characterisation).** For a finite multiset $S\subset\mathbb{R}$ and $m\in\mathbb{R}$:
$$m \text{ minimises } F_S \iff m \text{ is balanced for } S.$$

*Proof.* Theorems 3.3 and 3.8. $\square$

The witness in Theorem 3.8 is a data point, so the argument is finitary — no limiting or derivative argument enters. This matters conceptually: the characterisation is a statement about counts, and its proof only ever compares counts.

### 3.2 Convexity and the shape of the optimal set

**Theorem 3.10 (convexity of the cost).** For $S\subset\mathbb{R}$ finite, $a,b\in\mathbb{R}$ and $\lambda\in[0,1]$,
$$F_S\bigl(\lambda a + (1-\lambda)b\bigr) \;\le\; \lambda F_S(a) + (1-\lambda)F_S(b).$$

*Proof.* Pointwise, $|\lambda a + (1-\lambda)b - x| = |\lambda(a-x) + (1-\lambda)(b-x)| \le \lambda|a-x| + (1-\lambda)|b-x|$ by the triangle inequality and homogeneity; sum over $S$. $\square$

**Theorem 3.11 (the optimal set is an interval).** If $a$ and $b$ both minimise $F_S$ and $a\le t\le b$, then $t$ minimises $F_S$. Hence the Fermat–Weber set is convex, and (being closed and bounded for a nonempty sample) a closed interval.

*Proof.* Write $t = \lambda a + (1-\lambda)b$ with $\lambda\in[0,1]$. Since $a$ and $b$ are both minimisers, $F_S(a) = F_S(b)$, so Theorem 3.10 gives $F_S(t) \le \lambda F_S(b) + (1-\lambda)F_S(b) = F_S(b) \le F_S(u)$ for every $u$. $\square$

Theorems 3.9 and 3.11 together give the complete picture: the optimum is an interval whose endpoints are determined by the counting condition. For odd samples the interval degenerates to the counting median (Corollary 3.6); for even samples it is the segment between the two middle order statistics, as we now make explicit.

---

## 4. Even samples: the optimum becomes a segment

**Theorem 4.1 (four-point Fermat–Weber).** Let $a\le b\le c\le d$ be real and set
$$C_4(t) \;=\; |t-a| + |t-b| + |t-c| + |t-d|.$$
Then for every $t$,
$$C_4(t) \;\ge\; (d-a) + (c-b),$$
with equality **if and only if** $b \le t \le c$.

*Proof.* The bound is the sum of $|t-a|+|t-d| \ge d-a$ and $|t-b|+|t-c|\ge c-b$, both instances of the triangle inequality. For the equality case: if $b\le t\le c$ then $t-a\ge 0$, $t-b\ge0$, $t-c\le0$, $t-d\le 0$, and expanding gives exactly $(d-a)+(c-b)$. Conversely, suppose $t<b$. Then $|t-b| = b-t$ and $|t-c| = c-t$, so
$$C_4(t) = \bigl(|t-a|+|t-d|\bigr) + (b+c-2t) \ge (d-a) + (b + c - 2t) > (d-a)+(c-b)$$
since $b+c-2t > c-b \iff 2b > 2t$. The case $t>c$ is symmetric. $\square$

**Corollary 4.2 (degeneracy criterion).** The Fermat–Weber set of $\{a,b,c,d\}$ (sorted) is the segment $[b,c]$; it is a single point if and only if $b=c$.

Thus for an even sample, "the median" is not a number but a *set*. Any prediction about the outcome of an even-sized experiment that is phrased as a point prediction about the median is already mis-typed. The correct object is the pair of endpoints.

---

## 5. The median of three as a metric projection

We now isolate the mechanism responsible for robustness: holding two measurements fixed and varying the third turns the median into a projection.

**Definition 5.1 (clamp).** For $a,b,x$ in a linear order, set
$$\operatorname{cl}_{a,b}(x) \;=\; \bigl(a\wedge b\bigr) \vee \bigl((a\vee b) \wedge x\bigr).$$

**Theorem 5.2 (median = clamp).** For all $a,b,x$ in a linear order, $\operatorname{med}(a,b,x) = \operatorname{cl}_{a,b}(x)$.

*Proof.* Both sides are lattice polynomials; case analysis on the relative order of $a,b,x$ (six cases) evaluates both to the middle element. $\square$

**Theorem 5.3 (the clamp is the nearest-point projection).** Let $a\le b$ in $\mathbb{R}$. Then $\operatorname{cl}_{a,b}(x) \in [a,b]$ for all $x$; it is the identity on $[a,b]$; and for every $y\in[a,b]$,
$$\bigl|\operatorname{cl}_{a,b}(x) - x\bigr| \;\le\; |y - x|,$$
with equality only for $y = \operatorname{cl}_{a,b}(x)$. That is, $\operatorname{cl}_{a,b}$ is the unique nearest-point projection of $\mathbb{R}$ onto $[a,b]$; it agrees with the standard projection onto a closed interval.

*Proof.* Three cases. If $x<a$, the clamp is $a$ and $|a-x| = a-x \le y-x = |y-x|$ for all $y\in[a,b]$, strictly unless $y=a$. If $x>b$, symmetric. If $x\in[a,b]$, the clamp is $x$ and the distance is $0$, strictly less than $|y-x|$ for $y\ne x$. $\square$

**Theorem 5.4 (regularity).** For fixed $a\le b$, the map $P = \operatorname{cl}_{a,b}$ on $\mathbb{R}$ satisfies:

1. *Monotonicity*: $x\le y \Rightarrow P(x)\le P(y)$.
2. *Nonexpansiveness*: $|P(x)-P(y)|\le |x-y|$.
3. *Firm nonexpansiveness*: $\bigl(P(x)-P(y)\bigr)^2 \le (x-y)\bigl(P(x)-P(y)\bigr)$.

*Proof.* (1) is case analysis. (2) follows from (1) plus the fact that $P$ never moves two points further apart than their preimages. (3) For $x\le y$, monotonicity gives $0\le P(y)-P(x)$ and nonexpansiveness gives $P(y)-P(x)\le y-x$; multiplying these two inequalities gives $(P(y)-P(x))^2 \le (y-x)(P(y)-P(x))$, which is the claim (the expression is symmetric under swapping $x,y$). $\square$

Firm nonexpansiveness (3) is strictly stronger than (2): it says the displacement of the image is not merely bounded by the displacement of the argument but is *aligned* with it and dominated by it in the inner-product sense. This is the standard regularity class of projections onto convex sets in Hilbert space, and it is exactly the quantitative content of "the median absorbs outliers".

**Theorem 5.5 (fibres).** Let $a<b$ in a linear order. Then

* $\operatorname{cl}_{a,b}(x) = a \iff x \le a$;
* $\operatorname{cl}_{a,b}(x) = b \iff b \le x$;
* for $a<m<b$: $\operatorname{cl}_{a,b}(x) = m \iff x = m$.

*Proof.* Immediate from Theorem 5.3 and monotonicity, splitting on the position of $x$ relative to $[a,b]$. $\square$

So the fibres over the endpoints are closed half-lines — the *normal cones* of the segment at its endpoints — while interior fibres are singletons. Stability of the centre is a boundary phenomenon.

**Theorem 5.6 (range).** For $a\le b$ real, $\{\operatorname{med}(a,b,x): x\in\mathbb{R}\} = [a,b]$: every value in the segment is attained and none outside it.

### 5.1 Consequences for the measured data

At $\mathrm{ctx}=2048$ the two earlier seeds are $256$ and $224$, so the segment is $[224,256]$.

**Proposition 5.7 (stability ray).** $\operatorname{med}(256,224,x) = 224 \iff x \le 224$.

*Proof.* Theorem 5.2 identifies the median with $\operatorname{cl}_{224,256}(x)$; apply Theorem 5.5 at the left endpoint. $\square$

The measured third seed $160$ lies in this ray, comfortably. Note also the sharpness:

**Proposition 5.8 (a plausible informal claim is false).** The assertion "only a third seed $\ge 256$ moves the centre off $224$" fails: $\operatorname{med}(256,224,240) = 240 \ne 224$, and $240 < 256$.

The correct threshold is the *near* endpoint $224$, not the far endpoint $256$.

**Proposition 5.9 (the excursion is absorbed).** The measured third seed sits at distance exactly $64$ from the segment: $|\operatorname{cl}_{224,256}(160) - 160| = 64$, and indeed $|y-160|\ge 64$ for every $y\in[224,256]$. The projection absorbs the entire excursion; the reported centre moves by $0$.

**Proposition 5.10 (contrast with the mean).** With two arguments fixed, the arithmetic mean $x\mapsto (a+b+x)/3$ is a surjection onto $\mathbb{R}$: a single free measurement can drive it anywhere. On the measured triple its value is $\operatorname{mean}(256,224,160) = 640/3 \approx 213.33 \ne 224$, whereas $\operatorname{med}(256,224,160) = 224 = \tfrac78\cdot 256$. The median's range is the compact segment $[224,256]$; the mean's is all of $\mathbb{R}$.

Propositions 5.7–5.10 are the precise sense in which "report the median, not the average" was the correct protocol, and they quantify how much abuse the protocol tolerates: any third measurement at or below $224$, without limit.

---

## 6. Scaling geometry: rays, dilations, and a single scalar defect

We now compare the two contexts. Plot each measurement as the point $(\mathrm{ctx}, k^\*)\in\mathbb{R}^2$:

$$\text{top: } (1024,128),\ (2048,256);\qquad \text{median: } (1024,112),\ (2048,224);\qquad \text{low: } (1024,96),\ (2048,160).$$

**Definition 6.1.** For $p,q\in\mathbb{R}^2$ write $p\times q = p_1q_2 - p_2q_1$. Two points lie on a common ray through the origin iff $p\times q = 0$; the triangle $O,p,q$ has area $|p\times q|/2$.

**Theorem 6.2 (the top edge is a ray).** $(1024,128)\times(2048,256) = 0$, and both points have slope $1/8$. Equivalently, the product-point law $k^\*_{\max} = d\cdot\mathrm{ctx}/32$ is exact proportionality.

**Theorem 6.3 (the median is a ray).** $(1024,112)\times(2048,224) = 0$, and both points have slope
$$\frac{7}{64} \;=\; \frac78\cdot\frac18 ,$$
the product-law slope scaled by the median constant.

**Theorem 6.4 (uniqueness and predictive content of the median slope).** If $s\in\mathbb{R}$ satisfies $112 = s\cdot 1024$, then $s = 7/64 = \tfrac78\cdot\tfrac18$, and moreover $224 = s\cdot 2048$.

*Proof.* The hypothesis is a linear equation with unique solution $s = 112/1024 = 7/64$; substituting into the second context, $\tfrac{7}{64}\cdot 2048 = 224$. $\square$

This is worth emphasising because it distinguishes a fitted constant from a tested one. One context *determines* the slope with zero remaining freedom; the second context then either confirms or refutes it. It confirms it exactly.

**Theorem 6.5 (the low tail is not a ray).** $(1024,96)\times(2048,160) = 1024\cdot 160 - 96\cdot 2048 = -32768 \ne 0$; the origin triangle has area $16384$. No proportional law fits the low tail.

**Theorem 6.6 (dilation equivariance, and its failure).** Let $\delta_2(p) = 2p$ be the doubling dilation of the plane, corresponding to doubling the context. Then
$$\delta_2(1024,128) = (2048,256),\qquad \delta_2(1024,112) = (2048,224),$$
so the top edge and the median are $\delta_2$-equivariant, while
$$\delta_2(1024,96) = (2048,192) \ne (2048,160),$$
with defect
$$2\cdot 96 - 160 \;=\; 32 \;=\; \frac{256}{8} \;=\; \frac{P}{8}.$$

**Theorem 6.7 (no dilation matches the configuration).** There is no $t\in\mathbb{R}$ with $t\cdot(1024,128) = (2048,256)$, $t\cdot(1024,112) = (2048,224)$ and $t\cdot(1024,96) = (2048,160)$ simultaneously.

*Proof.* The first forces $t\cdot 128 = 256$, i.e. $t=2$; the third then demands $2\cdot 96 = 160$, false. $\square$

**Interpretation.** The knee *distribution* is not self-similar under context doubling, even though its centre and its upper edge are. All of the non-self-similarity is concentrated in one scalar, the low-tail defect $P/8$. This localises the entire context-dependence of the distribution's shape into a single measurable number.

### 6.1 The spread, exactly

Normalise each triple by its product point:
$$r_8 = (3/4,\ 7/8,\ 1),\qquad r_{16} = (5/8,\ 7/8,\ 1).$$

**Theorem 6.8 (normalised optimal costs).** For all $x$,
$$|x-\tfrac34| + |x-\tfrac78| + |x-1| \ge \tfrac14, \quad\text{equality iff } x=\tfrac78;$$
$$|x-\tfrac58| + |x-\tfrac78| + |x-1| \ge \tfrac38, \quad\text{equality iff } x=\tfrac78.$$
Consequently the optimal Fermat–Weber costs are $1/4$ and $3/8$, and
$$\tfrac38 \;=\; \tfrac32\cdot\tfrac14 .$$

*Proof.* Corollary 2.4 applied to each sorted triple; the optimal cost is the spread, $1 - 3/4$ and $1 - 5/8$. $\square$

The informal report of a "$\sim 50\%$ wider" spread at the longer context is therefore *exact*: the optimal transport cost is larger by the precise factor $3/2$.

**Theorem 6.9 (the widening is carried entirely by the low tail).** The top two normalised coordinates coincide at the two contexts ($7/8$ and $1$ in both), and
$$\underbrace{\tfrac38 - \tfrac14}_{\text{cost increase}} \;=\; \tfrac18 \;=\; \underbrace{\tfrac34 - \tfrac58}_{\text{low-coordinate drop}} .$$

---

## 7. A flat face inside a non-convex level set

Regard normalised triples as points of $\mathbb{R}^3$ and consider the median map $\operatorname{med}:\mathbb{R}^3\to\mathbb{R}$ and its level set $\mathcal{L} = \operatorname{med}^{-1}(7/8)$.

**Theorem 7.1 (a maximal flat edge).** For every $t\le 7/8$, $\operatorname{med}(t,\ 7/8,\ 1) = 7/8$; and for $7/8 < t \le 1$, $\operatorname{med}(t,\ 7/8,\ 1) = t \neq 7/8$. So the half-line $H = \{(t,7/8,1) : t\le 7/8\}$ lies in $\mathcal{L}$ and is maximal in its direction.

*Proof.* If $t\le 7/8\le 1$, the sorted triple is $(t, 7/8, 1)$ with middle $7/8$; if $7/8<t\le 1$, the sorted triple is $(7/8, t, 1)$ with middle $t$. $\square$

**Theorem 7.2 (both contexts lie on the edge, hence so does the segment joining them).** $r_8, r_{16}\in H$, and for every $s\le 1$,
$$\operatorname{med}\bigl(s\,r_8 + (1-s)\,r_{16}\bigr) = \tfrac78 .$$

*Proof.* The second and third coordinates of $s\,r_8 + (1-s)\,r_{16}$ are $s\cdot\tfrac78+(1-s)\cdot\tfrac78 = \tfrac78$ and $s+(1-s)=1$; the first is $s\cdot\tfrac34 + (1-s)\cdot\tfrac58 = \tfrac58 + \tfrac{s}{8} \le \tfrac78$ whenever $s\le 2$, in particular for $s\le 1$. Apply Theorem 7.1. $\square$

The hypothesis needed is only $s\le 1$, not $0\le s\le 1$: the flat face extends *past* the $16\times$ endpoint in the $r_{16}$ direction. Physically, the low tail may keep decreasing over further contexts without moving the centre.

**Theorem 7.3 (the level set is not convex).** $\operatorname{med}(5/8,\,7/8,\,1) = 7/8$ and $\operatorname{med}(7/8,\,1,\,5/8) = 7/8$, but their midpoint $(3/4,\, 15/16,\, 13/16)$ satisfies $\operatorname{med}(3/4,\,15/16,\,13/16) = 13/16 \ne 7/8$.

*Proof.* Direct evaluation: the sorted midpoint triple is $(3/4, 13/16, 15/16)$ with middle $13/16$. $\square$

Theorem 7.3 shows that Theorem 7.2 has genuine content. Two points may each have median $7/8$ while the segment joining them leaves the level set entirely. That the two measured contexts lie in a *common convex face* of this non-convex polyhedral set is a structural statement about the data — specifically, it encodes that both contexts have the same pinned top coordinate and the same centre, with all variation confined to the invisible low coordinate.

---

## 8. The pending fourth measurement: a pre-registered prediction

The next planned experiment adds a fourth seed at $\mathrm{ctx}=2048$. By Section 4 the sample becomes even and the optimum becomes a segment. We state the full prediction.

Write, for a fourth value $x$ and a candidate centre $t$,
$$C(x,t) \;=\; |t-160| + |t-224| + |t-256| + |t-x|.$$

**Theorem 8.1 (value at the $7/8$ centre).** For every $x$, $\;C(x,224) = 96 + |224-x|$.

*Proof.* $|224-160| + |224-224| + |224-256| = 64 + 0 + 32 = 96$. $\square$

**Theorem 8.2 (the centre is optimal for every fourth value).** For all $x,t\in\mathbb{R}$, $\;C(x,224)\le C(x,t)$.

*Proof.* Two triangle inequalities: $|t-160| + |t-256|\ge 96$ and $|t-224| + |t-x|\ge |224-x|$. Add, and compare with Theorem 8.1. $\square$

**Theorem 8.3 (exact linear cost response).** The optimal four-value cost is exactly $96 + |224-x|$: it responds to the new datum linearly, with slope $1$ away from $224$. What a fourth measurement moves is the *spread*, never the centre.

**Theorem 8.4 (regimes).** For $160\le x\le 224$ and any $t$,
$$C(x,t) = (256-160) + (224 - x) \iff x\le t\le 224 ;$$
for $224\le x\le 256$ and any $t$,
$$C(x,t) = (256-160) + (x - 224) \iff 224 \le t \le x .$$
That is: a repeated low tail widens the optimal set *downwards* with upper endpoint pinned at $224$; a high fourth value widens it *upwards* with lower endpoint pinned at $224$.

*Proof.* Theorem 4.1 with sorted data $(160, x, 224, 256)$ in the first case and $(160,224,x,256)$ in the second. $\square$

**Theorem 8.5 (knife edge for uniqueness).** For $160\le x\le 224$, the $7/8$ centre is the *unique* optimum if and only if $x = 224$.

*Proof.* By Theorem 8.4 the optimal set is $[x,224]$, a singleton iff $x=224$. $\square$

**Theorem 8.6 (balance form).** For every $y\in\mathbb{R}$, the point $224$ is balanced for the four-element sample $\{160,224,256,y\}$: if $y\le 224$, three of the four entries are $\le 224$ and two are $\ge 224$; if $y>224$, two are on each side. By Theorem 3.3, $224$ minimises $F$ on that sample.

Theorem 8.6 re-derives Theorem 8.2 from the general characterisation, showing the phenomenon is not an accident of the specific numbers: it is the balance condition holding at the third order statistic of a four-point sample whose two middle entries straddle $224$.

**Methodological reading.** The prediction is *not* refutable by the pending measurement, and this is informative rather than embarrassing. It tells us that a fourth seed does not test the centre: the geometry guarantees the centre survives. What the fourth seed tests is the low tail — whether the ratio $5/8$ observed at the longest context is a stable structural feature or a single-seed artefact. Stated in the correct variational language, the outcome to watch is the *lower endpoint* of the optimal segment: a value $x\in[160,224]$ replicates the low tail and pushes the endpoint down to $x$; a value $x\in[224,256]$ contradicts it and pushes the *upper* endpoint to $x$ while leaving the lower one at $224$.

---

## 9. Algorithms

The theory is entirely constructive, and each theorem corresponds to a small exact algorithm.

**Algorithm A (Fermat–Weber set of a sample on a line).** Sort the sample $x_{(1)}\le\cdots\le x_{(n)}$ in $O(n\log n)$ (or $O(n)$ by selection). Return $[x_{(k+1)}, x_{(k+1)}]$ if $n = 2k+1$, and $[x_{(k)}, x_{(k+1)}]$ if $n = 2k$. Correctness: Corollary 3.6 and Theorem 4.1. The optimal cost is $\sum_{i}\bigl(x_{(n+1-i)} - x_{(i)}\bigr)$ over $i\le \lfloor n/2\rfloor$, i.e. the sum of nested spreads.

**Algorithm B (balance test).** Given $S$ and $m$, compute $\#\{x\le m\}$, $\#\{x<m\}$ in one pass, $O(n)$; report balanced iff $n - \#\{x\le m\} \le \#\{x\le m\}$ and $\#\{x<m\} \le n - \#\{x<m\}$. By Theorem 3.9 this is an exact optimality certificate — no cost evaluation required.

**Algorithm C (stability radius of the centre).** Given a sample with one designated free coordinate, the set of values of that coordinate leaving the reported centre unchanged is, by Theorem 5.5, a half-line when the centre is at an endpoint of the segment spanned by the fixed data, and a singleton otherwise. For the measured $16\times$ data (fixed $\{224,256\}$) it is $(-\infty, 224]$, so the stability radius *downwards* is infinite and *upwards* is $0^+$.

**Algorithm D (ray/dilation diagnostics).** For paired measurements $(c_1,y_1)$, $(c_2,y_2)$, compute the determinant $c_1y_2 - y_1c_2$; zero certifies a proportional law and its slope, nonzero quantifies the departure by the origin-triangle area $|{\det}|/2$. For a doubling pair, the defect $2y_1 - y_2$ is the scalar measuring failure of dilation equivariance.

---

## 10. Discussion

### 10.1 What the geometry bought

Three informal claims were in circulation, and the geometry adjudicated all three.

*"The median is the robust quantity."* Made precise: the median of three is a metric projection onto the segment spanned by the other two, hence firmly nonexpansive with an unbounded stability half-line at each endpoint (Theorems 5.3–5.5). The mean, by contrast, is surjective in the free coordinate (Proposition 5.10). The claim is true, and quantitatively so.

*"Only a third seed $\ge 256$ would move the centre."* **False** (Proposition 5.8): the threshold is $224$, the near endpoint, as $\operatorname{med}(256,224,240) = 240$ shows. Intuition placed the boundary at the wrong end of the segment.

*"The $16\times$ spread is $\sim 50\%$ wider."* Exactly right, and exactly $3/2$ (Theorem 6.8), with the widening carried wholly by the low coordinate (Theorem 6.9).

### 10.2 Point predictions versus structural predictions

The round separates two kinds of claim. Four *point* predictions about a single seed's knee were all refuted. One *structural* prediction — about the centre of the distribution — held. The geometry explains why this asymmetry is not luck. A single seed's knee is determined by where a noisy quality curve crosses a bar between grid points; the reported measurement crossed with a margin of $+0.0012$, so the true threshold lies near $150$–$160$ and the grid reports $160$. Nothing protects that number. The median, by contrast, is the image of a firmly nonexpansive projection, and the projection's fibre over the reported value is an entire half-line: it is insensitive to arbitrarily large excursions in the protected direction.

The practical lesson generalises well beyond this dataset. When a per-run measurement is grid-quantised and noisy, do not pre-register the run's value; pre-register a functional of the distribution whose stability you can bound in advance. The stability bound *is* the prediction's content.

### 10.3 Limits and honesty

Several caveats are structural rather than rhetorical.

* The $7/8$ law rests on two contexts and six measurements. Two points determine a ray, so the "confirmation" in Theorem 6.4 is one independent test, not many. A third context would be the first genuine multiplicity.
* The low-tail ratio $5/8$ rests on a single measurement. Theorem 6.6's defect $P/8$ is therefore an exactly proved statement about one measured pair, not a verified law.
* The most recent knee reading was razor thin ($+0.0012$ margin against a binomial standard error of about $0.11\%$ in accuracy), so $160$ should be read as "the grid point above a threshold near $150$–$160$", not as an exact value.
* Theorem 8.2 shows the pending fourth measurement cannot refute the centre. This is a limitation on what the next experiment can tell us, and the correct response is to read that experiment as a test of the low tail, per Section 8.

### 10.4 Beyond the line

Two directions in which the results are already stated more generally than the data requires are worth flagging. Theorem 2.3 lives in an arbitrary metric space, and Corollary 2.5 shows that collinear data in a normed space have their geometric median *in the ambient space* at the middle point — the minimiser does not move off the line. Theorem 3.3 lives in an arbitrary linearly ordered abelian group, so the sufficiency half of the characterisation applies verbatim to integer, rational, or lexicographic data. Only the necessity half (Theorem 3.8) uses the reals, and even then only through the existence of a nearest datum on each side — so it holds in any linear order with the finite-sample structure used, i.e. essentially unchanged for integer grids, which is the case relevant to grid-quantised measurements.

---

## 11. Future directions

### C1. The fourth-value dichotomy: a new measurement can widen the optimal set but never move it

**Conjecture.** For the pending $16\times$ fourth value $x$, the Fermat–Weber optimum of $\{160,224,256,x\}$ is the segment with endpoints $\min(x,224)\vee 160$ and $\max(x,224)\wedge 256$, whose *endpoint at $224$ is pinned for every $x$*, while the optimal cost is $96 + |224-x|$. Consequently no fourth value can refute the $7/8$ centre in the variational sense; it can only destroy uniqueness, and it does so unless $x = 224$ exactly.

**Status.** The pinning, the cost law, both regime descriptions, and the uniqueness knife edge are established above (Theorems 8.1–8.5). What remains conjectural is the *empirical* half: that the measured fourth value lands in $[160,256]$, so that the segment description applies with both endpoints interior.

**Key insight.** With an even sample the Fermat–Weber minimiser is not a point but the middle segment, so "the median" of a four-measurement experiment is a *set*, and the correct falsifiable statement concerns the position of that set's endpoints, not a number.

**Why now.** The next planned experiment is exactly a fourth seed at $\mathrm{ctx}=2048$; stating the prediction as a segment before the run makes the outcome decidable in advance.

### C2. The low-tail ray defect grows linearly in the context

**Conjecture.** Writing $L(\mathrm{ctx})$ for the smallest three-measurement knee at context $\mathrm{ctx}$, the plane points $(\mathrm{ctx}, L(\mathrm{ctx}))$ are *not* collinear with the origin, and the defect of the doubling dilation, $2L(\mathrm{ctx}) - L(2\,\mathrm{ctx})$, equals $P(2\,\mathrm{ctx})/8$ where $P = d\cdot\mathrm{ctx}/32$. The measured pair gives $2\cdot 96 - 160 = 32 = 256/8$.

**Status.** The single measured instance is exact (Theorem 6.6); the law itself is open. It needs a third context, $\mathrm{ctx}=4096$, with predicted low tail $2\cdot 160 - 512/8 = 256$, i.e. ratio $1/2$.

**Key insight.** The top edge and the median are dilation-equivariant while the low tail is not, so the entire context dependence of the knee *distribution* is concentrated in one scalar defect, measurable with a single extra run.

**Why now.** The $4096$ cell is one doubling away, and the prediction ratio $1/2$ is far from the alternative $5/8$ that would hold if the low tail were also equivariant; one run separates them.

### C3. Median stability as a firm-nonexpansiveness phenomenon, with a sharp constant

**Conjecture.** For any statistic $S:\mathbb{R}^n\to\mathbb{R}$ that is (i) symmetric, (ii) translation equivariant, (iii) monotone, and (iv) firmly nonexpansive in each coordinate with the others fixed, the stability set of a reported value — the set of values of a designated free coordinate leaving $S$ unchanged — is a closed interval, unbounded precisely when the reported value is an endpoint of the range of $S$ in that coordinate. The median satisfies all four hypotheses with sharp constant $1$; the mean fails (iv) in the required uniform sense and has singleton stability sets.

**Why it matters.** This would identify exactly which robust statistics inherit the half-line stability that made the $7/8$ law survivable, and would give a design criterion for choosing the reported functional in noisy threshold-search experiments.

### Further cells

Additional measurable directions: a fourth seed at $\mathrm{ctx}=1024$ to refine $\{96,112,128\}$ (low information value, since the median there is already pinned by the same projection argument); a depth-$8$ corner at short context to test whether the constant $7/8$ is depth-independent or specific to $d=4$; and a compression-floor check at depth $8$.

---

## 12. Conclusion

A distribution of noisy measurements was summarised by its median, and four point predictions about a single measurement failed while the structural claim about that median held. We have shown that this outcome is a theorem, not a coincidence.

The median on a line is the Fermat–Weber point: the minimiser of total distance. We characterised those minimisers completely — a point is optimal exactly when it is balanced — with sufficiency in any linearly ordered abelian group and a finitary necessity proof over the reals, and we showed the optimal set is always an interval, a point in odd size and a segment in even size. Holding two measurements fixed, the median of three is the nearest-point projection onto the segment they span: monotone, firmly nonexpansive, with half-line fibres at the endpoints. That is the mechanism of robustness, and it is quantitative: the measured excursion of $64$ units below the segment was absorbed exactly, and any excursion whatsoever in that direction would have been.

Across contexts, the picture is two rays and a defect. The upper edge and the median are exactly proportional to the context, with slopes $1/8$ and $7/64 = \tfrac78\cdot\tfrac18$; the low tail is not proportional at all, and the failure of dilation equivariance is the single scalar $P/8$. The spread grows by exactly $3/2$ per doubling, entirely through the low coordinate. Both normalised measurements lie on a maximal flat face of a non-convex level set of the median map, which is why they can agree at the centre while disagreeing everywhere else.

Finally, the geometry issues a prediction about the pending fourth measurement that cannot fail: the $7/8$ centre stays optimal whatever the new value is, the optimal cost is exactly $96 + |224 - x|$, and the optimum becomes a segment with one endpoint pinned at the centre. The right reading is that the next experiment is not a test of the centre but of the low tail — and stating that in advance, in the correct variational language, is the whole benefit of doing the geometry.
