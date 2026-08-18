# Tropical Order Statistics of Seed Distributions: The Median as a Max-of-Mins Polynomial, and the Commutation of Aggregation with Threshold Reading

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

We develop the median of an odd sample as an object of tropical algebra and derive from that normal form a group of structural theorems about how noisy threshold experiments should be summarised. Our starting point is the identity
$$\operatorname{med}(x_0,\dots,x_{2k}) \;=\; \bigvee_{\substack{S \subseteq \{0,\dots,2k\} \\ |S| = k+1}}\ \bigwedge_{i \in S} x_i ,$$
valid in any linear order, which exhibits the median as a homogeneous tropical polynomial of degree $k+1$ in $2k+1$ variables over the bounded tropical semiring $(\vee,\wedge) = (\max,\min)$. From it we obtain *threshold duality*: for every $v$, the relation $v \le \operatorname{med}(x)$ holds iff at least $k+1$ coordinates satisfy $v \le x_i$, and dually. Threshold duality is the engine of every result that follows.

Our principal theorem is a **commutation law between aggregation and threshold reading**. Given a finite grid $G$, a bar $\beta$, and $2k+1$ non-decreasing *retention curves* $c_i : \mathbb{N} \to \beta\text{-ordered set}$ with *knees* $K_i = \min\{t \in G : c_i(t) \ge \beta\}$, the pointwise median curve $t \mapsto \operatorname{med}(c_0(t),\dots,c_{2k}(t))$ has knee exactly $\operatorname{med}(K_0,\dots,K_{2k})$. Aggregating first and reading the knee second gives the same answer as reading knees first and aggregating second. We prove the corresponding statement is *false* for the arithmetic mean (an explicit triple of monotone step curves with knees $1,2,3$ has mean-curve knee $3 \ne 2$), and that monotonicity of the curves cannot be dropped.

We complement the commutation law with an axiomatic characterisation: a ternary aggregator on $\mathbb{R}$ that is monotone, symmetric, conservative, translation-equivariant and self-dual under order reversal is necessarily the median; and the tropical axiom (translation equivariance) is indispensable, witnessed by an explicit *sum-sign aggregator* satisfying the other four. We prove nonexpansiveness ($1$-Lipschitz for the sup-norm) and a breakdown theorem: a median of $2k+1$ values cannot leave the range spanned by any $k+1$ of them, whence a *pipeline* breakdown theorem — corrupting up to $k$ of $2k+1$ seeds, curves and all, cannot move the knee of the median curve outside the interval spanned by the surviving seeds. The mean pipeline has breakdown point $0$.

Finally we apply the theory to a measured two-context, six-seed dataset from a long-context attention-budget experiment. We derive, rather than assume, that the seed-3 knee at $(d, \mathrm{ctx}) = (4, 2048)$ is $k^\* = 160$ with margin $0.001$; that all four pre-registered point predictions $\{192,224,240,256\}$ clear the bar yet none is the knee; that the three-seed knee multiset $\{160,224,256\}$ has median $224 = \tfrac78 \cdot \tfrac{d\cdot \mathrm{ctx}}{32}$, replicating $112 = \tfrac78\cdot 128$ at half the context; that $7/8$ is the *unique* constant reproducing both rows, while the mean admits *no* such constant; and that the exact stability region of the reported centre is the ray $x \le 224$, which refutes the informal claim that only a third seed of $256$ or more could move it.

**Keywords:** tropical semiring, median, order statistics, max-of-mins normal form, threshold duality, knee detection, breakdown point, robust aggregation, attention budget.

---

## 1. Introduction

### 1.1 The empirical problem

A great many experiments have the following shape. A system has a tunable budget $k$ drawn from a finite grid $G$; a quality measure $c(k)$ increases (statistically) with $k$; and the number one actually wants to report is not a value of $c$ but the smallest budget at which $c$ clears a pre-agreed bar $\beta$. Call that budget the **knee**. Sparse attention budgets, quantisation bit-widths, sample-complexity thresholds, sensor counts, and dosage ladders all fit this template.

Two features of this template create trouble. First, the knee is an *extreme* functional of the curve: it is determined by where a single crossing happens, and if the curve crosses shallowly, one part in a thousand of measurement noise can move it by a whole grid step. Second, experiments of this kind are usually repeated across random seeds, and one must then decide how to summarise the several knees obtained — or, alternatively, whether to aggregate the *curves* and read a single knee from the aggregate.

The dataset that motivates this paper makes both problems vivid. In a long-context sequence-modelling experiment at model width $d=4$ and context length $\mathrm{ctx}=2048$, with a retention bar of $0.98$ (accuracy at budget $k$, relative to full-context accuracy), three random seeds produced three different knees: $256$, $224$ and $160$. The third of these cleared the bar by $0.001$. Four pre-registered point predictions all failed. Yet the *median* of the three knees was exactly $224$, matching a structural prediction $\tfrac78 P$ where $P = d\cdot\mathrm{ctx}/32 = 256$ — and matching the same prediction at half the context, where the three knees $\{96,112,128\}$ have median $112 = \tfrac78 \cdot 128$.

This paper is an attempt to explain, structurally, why the median is the object such laws attach to, and to determine precisely how far its good behaviour extends.

### 1.2 The tropical viewpoint

On any linearly ordered set $\alpha$, the pair of operations $(\vee, \wedge) = (\max, \min)$ forms a commutative, idempotent semiring: each operation is associative and commutative, each distributes over the other, and $a \vee a = a \wedge a = a$. This is the *bounded tropical semiring*; polynomials over it are precisely the lattice polynomials, and over $\mathbb{R}$ they are the continuous piecewise-linear functions built from coordinates by $\max$ and $\min$.

Our organising observation is that the median of an odd sample is a tropical polynomial in a strong sense — homogeneous of degree $k+1$ — and that essentially every desirable property of the median is a shadow of that algebraic fact. Monotonicity is nonnegativity of the "coefficients"; translation equivariance is tropical homogeneity of degree one; self-duality under $x \mapsto -x$ is the exchange of the max-of-mins and min-of-maxes normal forms; $1$-Lipschitzness for the sup-norm follows from the previous two; and the majority-vote behaviour under thresholding is what makes aggregation commute with knee reading.

### 1.3 Contributions

1. **Normal form** (§3): the counting median of an odd sample equals the max-of-mins tropical polynomial of degree $k+1$, in any linear order; and for three arguments it equals both $(a\wedge b)\vee(b\wedge c)\vee(a\wedge c)$ and the dual $(a\vee b)\wedge(b\vee c)\wedge(a\vee c)$.
2. **Threshold duality** (§3.3): thresholding the median is a majority vote, in both directions.
3. **Equivariance** (§4): the median is preserved by every order-preserving *and* every order-reversing reparametrisation of the sample; extremes are not (order reversal exchanges them).
4. **Axiomatic characterisation** (§5): five axioms force the median, and the tropical axiom among them is independent and indispensable.
5. **Commutation of aggregation with knee reading** (§6), for three and for $2k+1$ seeds; failure for the mean; necessity of monotonicity.
6. **Robustness** (§7): nonexpansiveness, a breakdown theorem, the composed *pipeline* breakdown theorem, and the corresponding failure ("breakdown point zero") of the mean pipeline.
7. **Application** (§8): a derivation of the measured knee, the horn analysis, the two-context $7/8$ median law with its uniqueness, the impossibility of the same law for the mean, the pinned-upper-edge / sinking-lower-tail geometry, and the exact stability ray of the reported centre, together with a correction of an informal claim about that ray.

---

## 2. Definitions

Throughout, $\alpha$ and $\beta$ denote linearly ordered sets; $\vee$ and $\wedge$ denote $\max$ and $\min$. All multisets are finite.

**Definition 2.1 (Median, counting form).** Let $s$ be a multiset over $\alpha$ with $|s| = 2k+1$. An element $m \in \alpha$ is a *median* of $s$, written $\mathrm{IsMedian}_k(s,m)$, if
$$m \in s, \qquad \#\{x \in s : x \le m\} \ge k+1, \qquad \#\{x \in s : m \le x\} \ge k+1 .$$

The counting form is the right definition to work with in an arbitrary linear order: it makes no reference to sorting, arithmetic or a metric.

**Definition 2.2 (Indexed median).** For $x : \{0,\dots,2k\} \to \alpha$, say $\mathrm{IsMedianIdx}_k(x,m)$ if $m$ is in the range of $x$ and both $\#\{i : x_i \le m\} \ge k+1$ and $\#\{i : m \le x_i\} \ge k+1$.

**Definition 2.3 (Tropical median polynomial).** For $x : \{0,\dots,2k\} \to \alpha$ set
$$\operatorname{tmed}(x) \;:=\; \bigvee_{|S| = k+1}\ \bigwedge_{i \in S} x_i ,$$
the join, over all $(k+1)$-element index sets $S$, of the meet of $x$ over $S$. For $k=1$ we write
$$\operatorname{med}_3(a,b,c) \;:=\; (a \wedge b) \vee (b \wedge c) \vee (a \wedge c).$$

**Definition 2.4 (Retention curve, bar, knee).** Let $G \subseteq \mathbb{N}$ be a finite grid, let $V$ be a linearly ordered set of quality values, and let $\beta \in V$ be a *bar*. A *retention curve* is a function $c : \mathbb{N} \to V$. We say $k$ is a *knee of $c$ on $G$ at bar* $\beta$, written $\mathrm{IsKnee}_{G,\beta}(c,k)$, if
$$k \in G, \qquad \beta \le c(k), \qquad \text{and} \qquad \forall j \in G,\ \beta \le c(j) \Rightarrow k \le j .$$
That is: $k$ is the least grid point at which $c$ clears the bar.

**Definition 2.5 (Product point, ratio, speed-up).** For an experiment at width $d$ and context $\mathrm{ctx}$, the *product point* is $P = d\cdot\mathrm{ctx}/32$; the *ratio* of a knee is $k^\*/P$; the *deployment speed-up* is $\mathrm{ctx}/k^\*$.

---

## 3. The median is a tropical polynomial

### 3.1 The normal form

**Theorem 3.1 (Tropical normal form of the median).** Let $x : \{0,\dots,2k\} \to \alpha$ and suppose $\mathrm{IsMedianIdx}_k(x,m)$. Then $\operatorname{tmed}(x) = m$.

*Proof sketch.* Two inequalities.

$(\le)$ Fix any $S$ with $|S| = k+1$. We claim $S$ contains an index $i$ with $x_i \le m$. Indeed, the counting condition $\#\{i : x_i \le m\} \ge k+1$ over a universe of size $2k+1$ gives $\#\{i : m < x_i\} \le k$; if every $i \in S$ had $x_i > m$ then $S$ would be a $(k+1)$-subset of a set of size $\le k$, absurd. Hence $\bigwedge_{i \in S} x_i \le x_i \le m$ for that index, and taking the join over $S$ yields $\operatorname{tmed}(x) \le m$.

$(\ge)$ By $\#\{i : m \le x_i\} \ge k+1$ choose a subset $S_0$ of that index set with $|S_0| = k+1$. Then $m \le \bigwedge_{i \in S_0} x_i \le \operatorname{tmed}(x)$. $\square$

**Corollary 3.2 (Three-seed normal form).** $\operatorname{med}_3(a,b,c)$ is the median of the multiset $\{a,b,c\}$, and
$$\operatorname{med}_3(a,b,c) = (a\vee b)\wedge(b\vee c)\wedge(a\vee c).$$
The equality of the max-of-mins and min-of-maxes normal forms is the *self-duality* of the median under order reversal; verifying it is a finite case analysis on the six orderings of $a,b,c$.

**Proposition 3.3 (Conservativity).** $\operatorname{tmed}(x) \in \{x_0,\dots,x_{2k}\}$; in particular $\operatorname{med}_3(a,b,c) \in \{a,b,c\}$. (A join of meets over a finite family attains its value at some index.)

### 3.2 Existence and uniqueness of the counting median

**Theorem 3.4 (Uniqueness).** If $|s| = 2k+1$ and $m, m'$ are both medians of $s$, then $m = m'$.

*Proof sketch.* Suppose $m < m'$. Then the predicates $x \le m$ and $m' \le x$ are mutually exclusive, so their filtered cardinalities add to at most $|s| = 2k+1$; but each is at least $k+1$, giving $2k+2 \le 2k+1$. $\square$

**Theorem 3.5 (Existence).** Every multiset of odd size $2k+1$ over a linear order has a (unique) median, namely the entry at index $k$ of a sorted representative.

*Proof sketch.* Sort $s$ into a list $\ell$ with $\ell$ pairwise $\le$. For a sorted list, at least $i+1$ entries are $\le \ell_i$ (the prefix of length $i+1$ is a sublist all of whose entries are $\le \ell_i$) and at least $|\ell| - i$ entries are $\ge \ell_i$ (the suffix). Taking $i = k$ gives both counting bounds. $\square$

### 3.3 Threshold duality

**Theorem 3.6 (Threshold duality).** For every $x : \{0,\dots,2k\}\to\alpha$ and every $v \in \alpha$,
$$v \le \operatorname{tmed}(x) \iff \#\{i : v \le x_i\} \ge k+1, \qquad\qquad \operatorname{tmed}(x) \le v \iff \#\{i : x_i \le v\} \ge k+1 .$$

*Proof sketch.* ($\Rightarrow$, first form) If $v \le \bigvee_S \bigwedge_{i\in S} x_i$ then, the join being over a finite family, $v \le \bigwedge_{i \in S_0} x_i$ for some $S_0$ of size $k+1$; every $i \in S_0$ then satisfies $v \le x_i$. ($\Leftarrow$) Choose $S_0$ of size $k+1$ inside $\{i : v \le x_i\}$; then $v \le \bigwedge_{S_0} x_i \le \operatorname{tmed}(x)$.

For the second form, ($\Leftarrow$) given $\#\{i : x_i \le v\} \ge k+1$, any $(k+1)$-set $S$ must meet $\{i : x_i \le v\}$ by inclusion–exclusion inside a universe of size $2k+1$, so $\bigwedge_S x \le v$; take the join. ($\Rightarrow$) contrapositive: if fewer than $k+1$ indices satisfy $x_i \le v$, then at least $k+1$ satisfy $x_i > v$, and the meet over such a $(k+1)$-set strictly exceeds $v$ while being $\le \operatorname{tmed}(x)$. $\square$

**Corollary 3.7 (Three-seed duality).**
$$v \le \operatorname{med}_3(a,b,c) \iff (v\le a \wedge v \le b) \ \text{or}\ (v \le b \wedge v \le c)\ \text{or}\ (v\le a \wedge v\le c),$$
and dually with all inequalities reversed. In words: **thresholding a median is a majority vote.**

### 3.4 Tropical algebra of the polynomial

**Proposition 3.8.** Over a linearly ordered abelian group $(G, +, \le)$:

* *(Monotonicity)* $x_i \le y_i$ for all $i$ implies $\operatorname{tmed}(x) \le \operatorname{tmed}(y)$.
* *(Tropical homogeneity of degree one)* $\operatorname{tmed}(x + t) = \operatorname{tmed}(x) + t$ for a constant $t$.
* *(Self-duality)* $\operatorname{tmed}(-x) = -\operatorname{tmed}(x)$.
* *(Bounds)* $\bigwedge_i x_i \le \operatorname{tmed}(x) \le \bigvee_i x_i$.

*Proof sketch.* All four are immediate from the normal form: joins and meets are monotone; $\min$ and $\max$ commute with translation; negation exchanges $\min$ and $\max$, converting the max-of-mins form into the min-of-maxes form, which by Corollary 3.2 is the same polynomial. $\square$

**Theorem 3.9 (Nonexpansiveness).** For real samples, $\operatorname{tmed}$ is $1$-Lipschitz for the sup-norm; for three arguments,
$$\bigl|\operatorname{med}_3(a,b,c) - \operatorname{med}_3(a',b',c')\bigr| \;\le\; \max\bigl(|a-a'|,\,|b-b'|,\,|c-c'|\bigr).$$

*Proof sketch.* Let $\delta$ be the right-hand side. Then $a \le a'+\delta$, $b \le b'+\delta$, $c\le c'+\delta$, so by monotonicity and homogeneity $\operatorname{med}_3(a,b,c) \le \operatorname{med}_3(a',b',c') + \delta$; symmetrically for the reverse. $\square$

This is the quantitative form of "the centre is the stable quantity": measurement noise of size $\delta$ in each seed perturbs the reported centre by at most $\delta$, with no amplification.

---

## 4. Equivariance: the median under changes of coordinates

Experimental readings are re-expressed constantly: knees are divided by a reference scale to make ratios, and inverted to make speed-ups. The first is order-preserving, the second order-reversing. The median survives both.

**Theorem 4.1 (Monotone equivariance).** Let $s$ be a multiset of odd size $2k+1$, $m$ its median, and $f$ a map such that $f(x) \le f(y) \iff x \le y$ for all $x,y \in s$. Then $f(m)$ is the median of $f(s)$.

**Theorem 4.2 (Antitone equivariance).** Under the same hypotheses but with $f(x) \le f(y) \iff y \le x$ on $s$, $f(m)$ is again the median of $f(s)$.

*Proof sketch (both).* Filtering commutes with mapping: $\#\{z \in f(s) : z \le f(m)\} = \#\{x \in s : f(x) \le f(m)\}$, which the hypothesis identifies with $\#\{x \in s : x \le m\}$ in the monotone case and with $\#\{x \in s : m \le x\}$ in the antitone case. In either case both counting bounds of Definition 2.1 are met, with the two roles exchanged in the antitone case. Membership is clear. $\square$

**Proposition 4.3 (Extremes are not equivariant, they are exchanged).** If $M$ is the greatest element of $s$ and $f$ is antitone on $s$, then $f(M)$ is the *least* element of $f(s)$.

Theorems 4.1–4.2 and Proposition 4.3 have a sharp practical consequence, spelled out in §8.4: the *median* speed-up is the speed-up of the median knee, but the *guaranteed* (worst-case) speed-up is the speed-up of the **largest** knee. Median and guarantee are governed by different order statistics, and only the former is coordinate-free.

---

## 5. What pins down the median? An axiomatic classification

Let $F : \mathbb{R}^3 \to \mathbb{R}$ be an aggregator. Consider five axioms.

* **(M) Monotone:** $a \le a'$, $b\le b'$, $c\le c'$ imply $F(a,b,c) \le F(a',b',c')$.
* **(S) Symmetric:** $F$ is invariant under the transpositions of its arguments, hence under $S_3$.
* **(C) Conservative:** $F(a,b,c) \in \{a,b,c\}$.
* **(T) Translation-equivariant:** $F(a+t,b+t,c+t) = F(a,b,c)+t$ — *tropical homogeneity of degree one.*
* **(D) Self-dual:** $F(-a,-b,-c) = -F(a,b,c)$.

**Theorem 5.1 (Characterisation of the median).** If $F$ satisfies (M), (S), (C), (T), (D), then $F = \operatorname{med}_3$.

*Proof sketch.* Three steps.

*(i) Dual identity.* By (D), $F(0,0,-d) = -F(0,0,d)$; by (T) applied with shift $d$, $F(d,d,0) = F(0,0,-d)+d$; by (S), $F(d,d,0) = F(0,d,d)$. Combining, $F(0,0,d) = d - F(0,d,d)$.

*(ii) Majority.* For $d \ge 0$, (M) gives $F(0,0,d) \le F(0,d,d)$, which with (i) yields $2F(0,0,d) \le d$. By (C), $F(0,0,d) \in \{0,d\}$; if it were $d$ then $2d \le d$, forcing $d = 0$, in which case the value is still $0$. Hence $F(0,0,d) = 0$: **two equal votes win.** Translating by $a$: $F(a,a,c) = a$ for $a \le c$; and by (i) plus translation, $F(a,c,c) = c$ for $a \le c$.

*(iii) Squeeze.* For $a\le b\le c$, monotonicity gives $F(a,b,b) \le F(a,b,c) \le F(b,b,c)$, i.e. $b \le F(a,b,c) \le b$. Sorted triples are pinned; (S) extends the conclusion to all triples, and $\operatorname{med}_3$ is the sorted-middle map. $\square$

**Proposition 5.2 (Non-vacuity).** $\operatorname{med}_3$ satisfies (M), (S), (C), (T), (D).

**Theorem 5.3 (Independence of the tropical axiom).** There is an aggregator satisfying (M), (S), (C), (D) that is not the median. Define the **sum-sign aggregator**
$$\mathrm{SS}(a,b,c) = \begin{cases} \max(a,b,c), & a+b+c > 0,\\[2pt] \min(a,b,c), & a+b+c < 0,\\[2pt] \operatorname{med}_3(a,b,c), & a+b+c = 0. \end{cases}$$
Then $\mathrm{SS}$ is monotone, symmetric, conservative and self-dual, and $\mathrm{SS}(0,0,1) = 1 \ne 0 = \operatorname{med}_3(0,0,1)$.

*Proof sketch.* Conservativity and symmetry are immediate (the sum is symmetric; $\max$, $\min$, $\operatorname{med}_3$ are conservative and symmetric). Self-duality: negating all inputs negates the sum, exchanging the first two branches, and $\max(-x) = -\min(x)$, $\min(-x) = -\max(x)$, $\operatorname{med}_3(-x) = -\operatorname{med}_3(x)$. Monotonicity is a case analysis on which branch each side falls in, using $\min(x) \le \mathrm{SS}(x) \le \max(x)$ in every branch, plus monotonicity of the sum, which guarantees the branch index can only increase. Translation equivariance fails, e.g. $\mathrm{SS}(-1,-1,0) = -1$ while $\mathrm{SS}(0,0,1) - 1 = 0$. $\square$

**Interpretation.** Order-theoretic axioms alone (monotone, symmetric, conservative, self-dual) do *not* single out the median. The additional requirement that pins it down is exactly the tropical one: invariance under a shift of the origin of the measurement scale. The median's status as the canonical centre is therefore an algebraic fact about the min-plus structure, not a soft consequence of "being in the middle".

---

## 6. The commutation theorem: aggregate then read = read then aggregate

Two pipelines compute a "consensus knee" from $2k+1$ seeds:

* **Pipeline A (read then aggregate):** compute knees $K_i$ from each curve $c_i$; report $\operatorname{tmed}(K)$.
* **Pipeline B (aggregate then read):** form the pointwise aggregate curve $\bar c(t) = A(c_0(t),\dots,c_{2k}(t))$; report its knee.

Pipeline B is arguably the more principled: it produces a curve, and hence an *operating point of an actual aggregate model*, rather than a summary statistic of derived quantities. Pipeline A is what practitioners do. The question is whether they agree.

**Theorem 6.1 (Median–knee commutation, three seeds).** Let $c_0,c_1,c_2 : \mathbb{N}\to V$ be non-decreasing, let $G$ be a finite grid, $\beta_0 \in V$ a bar, and suppose $\mathrm{IsKnee}_{G,\beta_0}(c_i, K_i)$ for $i=0,1,2$. Then
$$\mathrm{IsKnee}_{G,\beta_0}\bigl(t \mapsto \operatorname{med}_3(c_0(t),c_1(t),c_2(t)),\ \operatorname{med}_3(K_0,K_1,K_2)\bigr).$$

*Proof.* Write $K = \operatorname{med}_3(K_0,K_1,K_2)$.

*Grid membership.* By conservativity (Prop. 3.3), $K \in \{K_0,K_1,K_2\} \subseteq G$.

*Clearing the bar at $K$.* By the dual threshold duality (Cor. 3.7) applied to $K \le K$, at least two of $K_0,K_1,K_2$ are $\le K$; say $K_i, K_j \le K$. Monotonicity of $c_i$ gives $\beta_0 \le c_i(K_i) \le c_i(K)$, and likewise for $j$. So at least two of the three curves clear the bar at $K$, and by the upper threshold duality the median curve does too.

*Minimality.* Let $j \in G$ with $\beta_0 \le \operatorname{med}_3(c_0(j),c_1(j),c_2(j))$. By threshold duality, at least two curves clear the bar at $j$, so by the defining minimality of their knees, at least two of $K_0,K_1,K_2$ are $\le j$; by the dual duality, $K \le j$. $\square$

The proof is worth pausing over, because it explains why the theorem is about the median and nothing else. Both halves of the argument are the *same majority statement*, read through the two halves of threshold duality:

$$\underbrace{\text{“the median curve clears the bar at } t\text{”}}_{\text{majority of curves clear at } t} \;\Longleftrightarrow\; \underbrace{\text{“at least } k{+}1 \text{ knees are} \le t\text{”}}_{\text{“the median knee is} \le t\text{”}}$$

with monotonicity providing the middle equivalence "curve $i$ clears at $t$ $\iff K_i \le t$". Any aggregator whose thresholding is a majority vote would do; by Theorem 5.1, in the conservative tropical world that is the median.

**Theorem 6.2 (General odd case).** With $2k+1$ non-decreasing curves $c_i$ and knees $K_i$,
$$\mathrm{IsKnee}_{G,\beta_0}\bigl(t \mapsto \operatorname{tmed}(c_0(t),\dots,c_{2k}(t)),\ \operatorname{tmed}(K)\bigr).$$

*Proof sketch.* Identical, with counting in place of the three-fold case split: $\#\{i : \beta_0 \le c_i(t)\} \ge k+1 \iff \#\{i : K_i \le t\} \ge k+1$, because monotonicity makes the two filtered index sets coincide; apply Theorem 3.6 to each side. $\square$

**Proposition 6.3 (Uniqueness of knees).** A curve has at most one knee on a given grid at a given bar; hence Theorem 6.1 *determines* the knee of the median curve. (If $k$ and $k'$ are both knees, each minimality clause applied to the other gives $k \le k'$ and $k' \le k$.)

### 6.1 The mean does not commute

**Theorem 6.4 (Failure for the arithmetic mean).** Let $\sigma_a(t) = \mathbb{1}[t \ge a]$ be the unit step curve switching on at $a$; each $\sigma_a$ is non-decreasing with knee $a$ at bar $1$. On the grid $G = \{1,2,3\}$ with bar $1$, the curves $\sigma_1,\sigma_2,\sigma_3$ have knees $1,2,3$ with median $2$, whereas
$$\bar c(t) = \tfrac13\bigl(\sigma_1(t)+\sigma_2(t)+\sigma_3(t)\bigr)$$
takes the values $\tfrac13, \tfrac23, 1$ at $t=1,2,3$, so its knee is $3 \ne 2$.

The mechanism is transparent: the mean curve can only clear a bar of $1$ when *every* component does, so the mean pipeline computes the *maximum* of the knees in this configuration — a worst-case, not a central, summary. In general the mean pipeline's knee is neither the mean nor the median of the individual knees, and it lies systematically to the right.

### 6.2 Monotonicity cannot be dropped

**Theorem 6.5.** There exist curves $c_0,c_1,c_2$ on $G = \{1,2,3\}$ with bar $1$ and knees $1,2,3$, with $c_1,c_2$ monotone and $c_0$ not, such that the median curve does **not** have knee $\operatorname{med}_3(1,2,3) = 2$.

*Proof.* Take $c_0(t) = 1$ for $t \ne 2$ and $c_0(2) = 0$ — it clears the bar at $t=1$, so its knee is $1$, but it dips below the bar afterwards — together with $c_1 = \sigma_2$, $c_2 = \sigma_3$. At $t = 2$ the values are $(0, 1, 0)$, whose median is $0 < 1$: only one curve clears the bar there, so the median curve does not clear it at $2$. $\square$

Monotonicity is exactly the hypothesis that converts "curve $i$ clears the bar at $t$" into the *upward-closed* condition "$K_i \le t$", which is what makes the two majority events coincide.

---

## 7. Robustness: breakdown of the median pipeline

**Theorem 7.1 (Breakdown theorem for the tropical median).** Let $x, y : \{0,\dots,2k\}\to\alpha$ agree on a set $T$ of indices with $|T| \ge k+1$ ("$T$ is clean"). Then
$$\min_{i \in T} x_i \;\le\; \operatorname{tmed}(y) \;\le\; \max_{i \in T} x_i .$$

*Proof sketch.* Let $v = \min_{i\in T} x_i$. For each $i \in T$, $v \le x_i = y_i$, so at least $|T| \ge k+1$ coordinates of $y$ are $\ge v$; threshold duality gives $v \le \operatorname{tmed}(y)$. The upper bound is dual. $\square$

In words: **a minority of arbitrarily corrupted seeds cannot move the median outside the range of the honest majority.** For three seeds this is $\min(a,b) \le \operatorname{med}_3(a,b,c') \le \max(a,b)$ for every $c'$.

**Theorem 7.2 (The mean has breakdown point zero).** For every bound $B$ there is a sample $y : \{0,1,2\} \to \mathbb{R}$ agreeing with the clean data $x \equiv 0$ on the majority set $\{0,1\}$, with $\operatorname{tmed}(y) = 0$ but $\tfrac13(y_0+y_1+y_2) > B$. (Take $y_2 = 3B+3$.)

**Theorem 7.3 (Pipeline breakdown).** Let $c'_0,\dots,c'_{2k}$ be non-decreasing curves with knees $K'_i$, and suppose that on an index set $T$ with $|T| \ge k+1$ these agree with a reference clean knee vector $K$. Then the pointwise median curve has a knee, namely $\operatorname{tmed}(K')$, and
$$\min_{i\in T} K_i \;\le\; \operatorname{tmed}(K') \;\le\; \max_{i \in T} K_i .$$

*Proof.* Theorem 6.2 supplies the knee; Theorem 7.1 supplies the interval. $\square$

Note the strength of the corruption model: the $k$ dishonest seeds may have *entirely different curves*, not merely perturbed knees; monotonicity is assumed of them only so that they have knees at all.

**Theorem 7.4 (The mean pipeline has breakdown point zero).** For any $N > 1$, the curves $\sigma_1, \sigma_1, \sigma_N$ on $G = \{1, N\}$ at bar $1$ have two clean knees equal to $1$, yet the knee of their mean curve is $N$. Thus one corrupted seed out of three drags the aggregate operating point arbitrarily far from the clean range $[1,1]$, whereas the median pipeline returns $1$.

**Theorem 7.5 (Exact stability ray).** Let $b < c$. Then, for all $x$,
$$\operatorname{med}_3(x, b, c) = b \iff x \le b .$$

*Proof sketch.* If $x \le b$ the sorted triple is $(x,b,c)$ with middle $b$. Conversely if $x > b$ then $b < \min(x,c) \le \operatorname{med}_3(x,b,c)$, so the median exceeds $b$. $\square$

Theorem 7.5 is the sharp complement to Theorem 7.1: robustness of the median value is *one-sided* around the current centre. A re-measured seed strictly between the current median and the top of the sample moves the centre, even though it lies inside the interval $[b,c]$ guaranteed by the breakdown theorem. Confusing the two — the interval in which the centre is guaranteed to *lie*, and the set on which it is guaranteed to *stay put* — is a genuine and easy error; §8.6 records an instance.

---

## 8. Application: a two-context, six-seed knee dataset

We now apply the theory to measured data. The experiment: a causal word-level language model, vocabulary $4097$, held-out final $10\%$ of the corpus, data-free top-$k$ attention selection, retention measured as accuracy at budget $k$ divided by full-attention accuracy, bar $= 0.98$.

### 8.1 The measured sweep and its knee

At $(d,\mathrm{ctx}) = (4, 2048)$, seed 3: full-attention accuracy $0.1546$, hence bar $0.1516$; full loss $5.2199$. The retention row over the grid $G = \{96,128,160,192,224,240,256,288,384,512,768,1024\}$ is

| $k$ | 96 | 128 | 160 | 192 | 224 | 240 | 256 | 288 | 384 | 512 | 768 | 1024 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $c(k)$ | 0.963 | 0.973 | 0.981 | 0.984 | 0.986 | 0.987 | 0.990 | 0.993 | 0.999 | 1.000 | 1.003 | 1.003 |

Writing the row as a base value plus nonnegative increments switched on at grid points, $c = 0.963 + \sum_j \Delta_j\,\mathbb{1}[\,\cdot \ge g_j]$ with all $\Delta_j \ge 0$, makes monotonicity structural rather than checked pointwise.

**Proposition 8.1.** The measured curve is non-decreasing, and $\mathrm{IsKnee}_{G, 0.98}(c, 160)$, with margin $c(160) - 0.98 = 0.001$.

The margin is razor-thin — comparable to the binomial standard error of the accuracy measurement — so the individual knee read is fragile, exactly as the theory predicts for an extreme-order functional. Note also the recovery tail: $c(512) = 1.000$, $c(768) = c(1024) = 1.003$ (a held-out loss difference of $0.0016$), so the curve is well behaved beyond the knee and the crossing is not an artefact of a collapsing model.

### 8.2 The horn analysis

Four point predictions $\{192,224,240,256\}$ were fixed before the run.

**Proposition 8.2.** Every $k \in \{192,224,240,256\}$ satisfies $c(k) \ge 0.98$, and no $k$ in that set is a knee of $c$ on $G$ at bar $0.98$.

*Proof sketch.* The first claim is the sweep row. For the second, any knee $k$ satisfies $k \le 160$ by minimality applied to the grid point $160$, which clears the bar; each of the four candidates exceeds $160$. $\square$

The two clauses say something worth separating in general: a prediction can be *sound* (the predicted budget really is sufficient) and yet *not the answer* (it is not the least sufficient budget). Sufficiency is an upper-bound claim, knee-hood a minimality claim; a sweep that only checks the former cannot adjudicate the latter.

### 8.3 The $7/8$ median law

Let $K_8 = \{128,112,96\}$ (three seeds at $\mathrm{ctx}=1024$, $P_8 = 128$) and $K_{16} = \{256,224,160\}$ (three seeds at $\mathrm{ctx}=2048$, $P_{16} = 256$).

**Proposition 8.3.** $\operatorname{med}(K_8) = 112$ and $\operatorname{med}(K_{16}) = 224$, and
$$112 = \tfrac78 P_8, \qquad 224 = \tfrac78 P_{16}.$$

**Proposition 8.4 (Normalised distributions).** Dividing by the product point is order-preserving, so by Theorem 4.1
$$\operatorname{med}\{1,\tfrac78,\tfrac34\} = \tfrac78 \quad (\mathrm{ctx}=1024), \qquad \operatorname{med}\{1,\tfrac78,\tfrac58\} = \tfrac78 \quad (\mathrm{ctx}=2048).$$

**Theorem 8.5 (Uniqueness of the constant).** For $a \in \mathbb{Q}$, $\bigl(a P_8 = 112 \text{ and } a P_{16} = 224\bigr) \iff a = \tfrac78$. The law has no free parameter.

**Theorem 8.6 (The mean admits no such law).** There is no constant $a$ with $a P_8 = \tfrac{128+112+96}{3}$ and $a P_{16} = \tfrac{256+224+160}{3}$. Indeed the first forces $a = 7/8$ (the mean coincides with the median at $\mathrm{ctx}=1024$), while the second requires $a = 5/6$.

Theorem 8.6 is the decisive discriminator between "the centre satisfies a law" and "the median satisfies a law". The two summaries agree at one context and disagree at the other, and only one of them extends.

### 8.4 Speed-ups: order reversal at work

Converting a knee to a deployment speed-up, $k^\* \mapsto \mathrm{ctx}/k^\*$, is order-reversing on positive values.

**Proposition 8.7.** At $\mathrm{ctx} = 2048$, the speed-up multiset is $\{8,\ 64/7,\ 64/5\} \approx \{8.0,\ 9.14,\ 12.8\}$; by Theorem 4.2 its median is $64/7 = 2048/224 = \mathrm{ctx}/\operatorname{med}(K_{16})$.

**Proposition 8.8 (Guaranteed speed-up).** $8$ is the least element of the speed-up multiset, and it is the image of the *largest* knee, $256$, under order reversal (Proposition 4.3). Moreover every seed satisfies the product-law bound $k^\* \le P_{16}$, so every seed deploys at at least $8\times$.

Thus the deployment reading at $(d,\mathrm{ctx}) = (4,2048)$ is: **$\ge 8.0\times$ guaranteed across all three seeds, $9.1\times$ median, $12.8\times$ best.** The three numbers are three different order statistics of one distribution, and the algebra says which is which: the guarantee reads the max knee, the headline reads the median knee, the best case reads the min knee. Only the middle one is invariant under the change of coordinates.

### 8.5 Geometry of the two distributions

**Proposition 8.9.** In normalised coordinates the profiles $(\min, \operatorname{med}, \max)$ are
$$\mathrm{ctx}=1024:\ (\tfrac34,\ \tfrac78,\ 1), \qquad \mathrm{ctx}=2048:\ (\tfrac58,\ \tfrac78,\ 1).$$
Hence: the **upper edge is pinned** at $1$ in both contexts; the **median is stationary** at $7/8$; the **lower tail strictly sinks**, $\tfrac58 < \tfrac34$; and the normalised spread grows by exactly the factor
$$\frac{(256-160)/P_{16}}{(128-96)/P_8} = \frac{3/8}{1/4} = \frac32 .$$

The pinned ceiling is not an accident of sampling: it is the product-law bound $k^\* \le P$, verified for all six seeds. The only free coordinate of the distribution, as context grows, is therefore the lower tail, and the median — the unique order statistic that is equivariant under *both* the normalisation $\div P$ and the inversion $\mathrm{ctx}/\cdot$ — is the only summary insensitive to which coordinate system one reads.

### 8.6 The exact stability region, and a corrected claim

With two of the three seeds pinned at $224$ and $256$, Theorem 7.5 gives immediately:

**Proposition 8.10.** $\operatorname{med}_3(x, 224, 256) = 224 \iff x \le 224$. In particular the family $\{160, 192, 224\}$ of third-seed values all preserve the reported centre.

**Proposition 8.11 (A false informal claim).** The statement "only a third seed of $256$ or more would shift the median" is false: $240 < 256$, yet $\operatorname{med}_3(240,224,256) = 240 \ne 224$.

The correct statement is Proposition 8.10: the stability region is the half-line $x \le 224$, whose endpoint is the current median, *not* the interval $x < 256$ delimited by the next data point. The breakdown theorem (Theorem 7.1) does guarantee that the centre stays inside $[224,256]$ for *any* third value — but staying inside an interval and staying at a point are different guarantees.

### 8.7 The centre as an operating point

Finally, Theorem 6.1 upgrades the reported centre from a summary statistic to an operating point.

**Proposition 8.12.** Let $c_0,c_1,c_2$ be any non-decreasing retention curves on any grid and bar with knees $256$, $224$, $160$. Then the pointwise median curve has knee exactly $224$.

**Proposition 8.13 (Non-vacuity).** Such curves exist: the unit step curves $\sigma_{256}, \sigma_{224}, \sigma_{160}$ on $G = \{160,224,256\}$ at bar $1$ realise the triple, and their median curve has knee $224$.

**Proposition 8.14 (Deployment reading under re-measurement).** With seeds 1 and 2 fixed at $256$ and $224$ and an arbitrary third measurement $t$, the median curve has knee $\operatorname{med}_3(256,224,t) \in [224,256]$.

So "the median knee is $224$" is equivalent to "the median of the three models, as a model, needs a budget of $224$" — and no fourth measurement of the third seed can push that below $224$ or above $256$.

---

## 9. Algorithms

Three algorithms are implicit in the development and worth stating explicitly.

**Algorithm A (Knee detection).** Given a sorted grid $G = (g_1 < \dots < g_n)$, a curve oracle $c$, and a bar $\beta$, return the least $g_i$ with $c(g_i) \ge \beta$, or $\bot$. Linear scan: $O(n)$ oracle calls. If $c$ is known monotone, binary search reduces this to $O(\log n)$ calls — relevant when each call is a four-hour training run's evaluation pass.

**Algorithm B (Median-curve knee, two routes).** Route A: run Algorithm A on each of the $2k+1$ curves, then take the median of the knees ($O((2k+1)n)$ oracle calls plus an $O(k\log k)$ selection). Route B: form the pointwise median curve and run Algorithm A on it ($O((2k+1)n)$ oracle calls plus $O(n k \log k)$ arithmetic). Theorem 6.2 guarantees the two return the same value when the curves are monotone; Route A is cheaper, Route B is what one would defend as an operating point. The theorem says one need not choose.

**Algorithm C (Stability certificate).** Given a measured knee multiset of odd size and a candidate re-measurement, decide whether the reported centre moves, and return the exact set of values that leave it fixed. For three seeds sorted as $a \le b \le c$ with the third slot free, Theorem 7.5 gives the stability set $(-\infty, b]$ when the two pinned values are $b < c$; more generally, for $2k+1$ seeds with one free coordinate, the reported centre as a function of the free value is the non-decreasing step function $t \mapsto \operatorname{med}(K_{\text{pinned}}, t)$, constant on $(-\infty, m]$ and on $[m', \infty)$, where $m, m'$ are the two central order statistics of the pinned values.

---

## 10. Discussion

### 10.1 Why point predictions failed and a structural prediction held

The empirical episode that motivated this work is instructive precisely because it separates two notions of correctness. Four point predictions of a single seed's knee failed, while the prediction that the *distribution's centre* sits at $\tfrac78 P$ held at two contexts.

The theory explains the asymmetry. A single knee is an extreme functional of a noisy curve: it depends on the location of one crossing, and the crossing in question was decided by a margin of $0.001$ against a measurement standard error of comparable magnitude. Nothing in the theory of the median predicts such a quantity, and nothing should: knees are not $1$-Lipschitz functionals of the curve.

The median, by contrast, is majority-determined (Theorem 3.6), invariant under any monotone or antitone change of measurement units (Theorems 4.1, 4.2), $1$-Lipschitz (Theorem 3.9), immune to any minority of corrupted seeds (Theorem 7.1), and — the point that makes the law more than statistical hygiene — an operating point of a genuine aggregate curve (Theorem 6.1). A prediction about it is a fundamentally different kind of claim from a prediction about a point, and the two should be scored separately.

### 10.2 Honest limitations

Several limits should be stated plainly.

* The individual knee read at seed 3 is razor-thin ($+0.001$), so the true crossing lies somewhere between grid points, plausibly near $150$–$160$; the grid resolution is a real source of uncertainty in the low tail.
* The sinking low tail is presently a single measurement at the longer context; one further seed would decide whether $5/8$ is a stable feature of the $\mathrm{ctx}=2048$ distribution or specific to that seed.
* The $7/8$ median law rests on two contexts and six seeds. Theorem 8.5 shows it has no free parameter — which makes it falsifiable, not confirmed.
* An unusual negative result in the dataset deserves emphasis: measures of attention concentration (effective support, top-$k$ mass) do **not** sort with the measured knees across the three seeds at the longer context. There is no evidence here for a bounded "working set" explanation of the knee.
* Nothing here explains *why* the centre should sit at $7/8$ of the product point. The theorems say the median is the right thing to state a law about, and that the specific law is unique and testable; they do not derive its value from a model of the underlying system.

### 10.3 Relation to classical robust statistics

That the median has breakdown point $1/2$ while the mean has breakdown point $0$ is classical. What is added here is (i) the *normal form* that makes these facts algebraic identities in a semiring rather than analytic estimates, (ii) the *characterisation* isolating translation equivariance — the tropical axiom — as the property that separates the median from other conservative order-theoretic aggregators, and (iii) the *commutation theorem*, which is not a statement about the median as a location estimator at all, but about the median as an aggregator that commutes with a nonlinear, non-Lipschitz read-out (knee detection). Point (iii) has no analogue for the mean, and it is what licenses reporting a median knee as an operating point rather than merely as a summary.

---

## 11. Future directions

The following conjectures are open; each is falsifiable by a single explicit counterexample or by one further experiment.

**C1. The $7/8$ centre is a fixed point of context doubling.** For contexts $\mathrm{ctx}_n = 2^n\,\mathrm{ctx}_0$ with product points $P_n = d\,\mathrm{ctx}_n/32$, conjecture that the normalised three-seed knee distributions $K_n/P_n$ have constant median $7/8$, strictly decreasing lower endpoints $\min(K_n)/P_n$, and upper endpoints pinned at $1$: the family is monotone in the *lower tropical coordinate only*. The pinned upper edge is not an accident but the product-law bound $k^\* \le P$; the median, being the unique order statistic equivariant under both $\div P$ and $\mathrm{ctx}/\cdot$, is the only summary insensitive to which coordinate one reads. Two contexts and six seeds already fix the median at $7/8$ and the max at $1$; a third context decides whether the low tail follows a law (a $2^{-n}$-type decay, say) or is noise.

**C2. Majority-threshold rigidity of the knee functional.** Conjecture that for monotone retention curves the map "curve $\mapsto$ knee" is an order-reversing homomorphism from the lattice of curves (pointwise $\wedge, \vee$) to the lattice of grid points: $\mathrm{knee}(c \wedge c') = \max(\mathrm{knee}\,c, \mathrm{knee}\,c')$ and $\mathrm{knee}(c\vee c') = \min(\mathrm{knee}\,c, \mathrm{knee}\,c')$, so that *every* lattice polynomial in the curves commutes with the knee. Theorem 6.1 is the $k=1$ median instance; the general mechanism is that threshold duality converts any lattice polynomial into a monotone Boolean function of the individual threshold events, which the knee reads off directly. This would give a calculus for aggregating retention curves before measuring knees.

**C3. The mean is the unique non-conservative self-dual aggregator that breaks the law.** Among monotone, symmetric, translation-equivariant, self-dual ternary aggregators on $\mathbb{R}$, conjecture that exactly two phases occur: the conservative ones (all equal to the median, by Theorem 5.1) and the strictly averaging ones, each of which fails some measured two-context ratio law. Equivalently: no strictly averaging aggregator satisfies $A(K_8) = \tfrac78 P_8$ and $A(K_{16}) = \tfrac78 P_{16}$ simultaneously. Conservativity is exactly the axiom separating the tropical (max/min-built) aggregators from the linear ones.

**C4. Grid refinement and the continuum knee.** All statements here are relative to a finite grid. Conjecture that for curves that are continuous and strictly increasing near their crossing, the grid knee converges to the continuum crossing as the grid refines, and that the commutation theorem passes to the limit. The razor-thin margin of the measured seed-3 read makes this practically relevant: the reported $160$ is an upper bound for a crossing plausibly near $150$.

**C5. Quantitative stability of the median law under seed resampling.** Combining Theorem 7.5 with a noise model for individual knees would yield a probability that the reported centre changes under one further seed. For the measured $16\times$ cell this is the probability that a fourth seed exceeds $224$ — a directly testable prediction rather than a qualitative robustness claim.

---

## 12. Conclusion

The median of an odd sample is a homogeneous tropical polynomial: the maximum, over all $(k+1)$-subsets of the sample, of the minimum there. That single normal form yields threshold duality, and threshold duality yields everything else — full equivariance under monotone and antitone changes of coordinates, an axiomatic characterisation in which the decisive axiom is the tropical one, nonexpansiveness, a majority breakdown theorem, and, most consequentially, the exact commutation of median aggregation with knee reading, a commutation that the arithmetic mean fails outright.

Applied to a measured attention-budget dataset, the theory both explains and disciplines the empirical story: it derives the measured knee $k^\* = 160$ and its razor-thin margin from the sweep row, shows that all four pre-registered point predictions are simultaneously sound and non-minimal, establishes that the two-context median law $\operatorname{med}(K) = \tfrac78 P$ has a unique constant and no mean-based analogue, identifies the pinned ceiling as the product-law bound and the sinking floor as the sole free coordinate, and pins the exact stability region of the reported centre to the ray $x \le 224$ — correcting, in passing, a plausible-sounding claim that it extends to $256$.

The general moral is a modest but useful one for experimental practice. When the quantity you can measure is fragile and the quantity you want to predict is structural, choose the summary whose algebra commutes with your read-out. In the threshold-crossing setting, that summary is the median, and the reason is tropical.
