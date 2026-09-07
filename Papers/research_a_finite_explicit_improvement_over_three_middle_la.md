# Weakly $D_6$-Free Families in the Boolean Lattice: an Abelian No-Go Theorem, a Turán Ceiling, and the Interval Hierarchy

**Author:** Aristotle

**Date:** 2026-09-07

---

## Abstract

Let $2^{[n]}$ denote the Boolean lattice of all subsets of $[n] = \{0,1,\dots,n-1\}$, ordered by inclusion. A family $\mathcal{F} \subseteq 2^{[n]}$ *weakly contains* the $j$-diamond $D_j$ if there are $A, C \in \mathcal{F}$ and $j$ distinct sets $B_1,\dots,B_j \in \mathcal{F}$ with $A \subsetneq B_i \subsetneq C$ for all $i$; otherwise $\mathcal{F}$ is *weakly $D_j$-free*. The union of three consecutive layers is weakly $D_6$-free and has $\binom{n}{k}+\binom{n}{k+1}+\binom{n}{k+2} \approx 3\binom{n}{\lfloor n/2\rfloor}$ members. We investigate whether a fixed rational constant $c > 3$ can be attained, i.e. whether there is a weakly $D_6$-free family of size at least $c\binom{n}{\lfloor n/2 \rfloor}$ for all large $n$, by the most natural candidate mechanism: thinning a fourth layer by an algebraic labelling.

We prove four groups of results.

1. **Rigidity of the baseline.** Three consecutive layers are weakly $D_3$-free, hence weakly $D_6$-free, and the family is *saturated*: adding any set of the adjacent layer above or below creates a weak $D_6$. In particular, four consecutive full layers are never weakly $D_6$-free.

2. **The interval-exclusion criterion.** For families confined to four consecutive layers, weak $D_6$-freeness is *equivalent* to a deterministic, local condition: every height-$3$ interval whose endpoints lie in the family misses at least one of its six interior sets. The proof rests on the exact interval count $|(A,C)| = 2^{|C|-|A|}-2$.

3. **An abelian no-go theorem.** Suppose the interior layer $k+2$ is thinned by a sum-labelling $v : [n] \to V$ into a finite abelian group with keep-set $U \subseteq V$, so that $S$ survives iff $\sum_{i\in S} v(i) \in U$. Then weak $D_6$-freeness forces an algebraic *safety* condition on $(v,U)$; safety forces every label class $v^{-1}(a)$ to have at most two elements; and if the labels occupy more than two thirds of $V$ (automatic whenever $4|V| < 3n$), safety forces $|U| \le 2$. Consequently the resulting family has at most $3\binom{n}{\lfloor n/2\rfloor} + 2b$ members, where $b$ bounds one colour class inside the thinned layer, giving $c \le 3 + 2/K$ whenever $Kb \le \binom{n}{\lfloor n/2 \rfloor}$. Under equidistribution ($b \approx \binom{n}{k+2}/|V|$, $|V| \ge n/2$) this is $c \le 3 + O(1/n)$: **no fixed constant $c > 3$ is attainable by an abelian sum-labelling.**

4. **A Turán ceiling.** Link graphs of weakly $D_6$-free families containing layers $k+1$ and $k+3$ in full are triangle-free; Mantel's theorem and double counting give $4\binom{k+2}{2}\,|\mathcal{F} \cap \text{layer}(k{+}2)| \le \binom{n}{k}(n-k)^2$, which for balanced $k$ caps four-layer constructions near $3.5\binom{n}{\lfloor n/2\rfloor}$.

All results are the case $m = 3$ of a uniform hierarchy: in a window of $m+1$ layers, weak $D_{2^m-1}$-freeness is automatic, weak $D_{2^m-2}$-freeness is equivalent to height-$m$ interval exclusion, and the $m$-layer window is saturated. Together, items 3 and 4 place any hypothetical constant in the corridor $3 < c \le 3.5$ and rule out the entire class of abelian sum-labelling constructions.

**Keywords.** Boolean lattice, diamond-free families, extremal set theory, interval exclusion, sum labelling, additive combinatorics, Mantel's theorem, link graph.

---

## 1. Introduction

### 1.1 The problem

Extremal set theory studies the maximum size of a family $\mathcal{F} \subseteq 2^{[n]}$ avoiding a prescribed subposet. Write $\binom{n}{\le}$ for the central binomial coefficient $\binom{n}{\lfloor n/2\rfloor}$. For a poset $P$, the *Turán number* $\mathrm{La}(n, P)$ is the largest size of a family containing no (weak) copy of $P$, and the standard normalisation is $\pi(P) = \lim_{n\to\infty} \mathrm{La}(n,P)/\binom{n}{\le}$.

The *diamond* $D_j$ is the poset with a minimum, a maximum, and $j$ pairwise incomparable middle elements. We use the *weak* notion of containment throughout: a family weakly contains $D_j$ if it contains two sets $A \subsetneq C$ together with $j$ distinct sets strictly between them; the middle sets need not be pairwise incomparable, and no induced-ness is required. Weak containment is the harder condition to avoid, so weak freeness is the stronger property.

The trivial lower bound for $D_j$ with $j \ge 3$ comes from consecutive layers. If all members of $\mathcal{F}$ have sizes in a window of $m+1$ consecutive values, then any interval between two members has height at most $m$ and hence at most $2^m - 2$ interior sets. Since $2^2 - 2 = 2 < 3$, three consecutive layers are weakly $D_3$-free (and a fortiori weakly $D_j$-free for every $j \ge 3$), giving
$$\mathrm{La}(n, D_j) \;\ge\; \binom{n}{k}+\binom{n}{k+1}+\binom{n}{k+2} \;\sim\; 3\binom{n}{\le}, \qquad j \ge 3 .$$
For $j = 6$ the window $m=3$ is on the verge of usability: an interval of height $3$ has exactly $2^3 - 2 = 6$ interior sets, so a four-layer family is weakly $D_6$-free precisely when it never contains *all six*. This near-miss is the source of the guiding conjecture:

> **Conjecture (the target).** There exist explicit integers $q$, $n_0$ and a rational $c > 3$ such that for all $n \ge n_0$ a labelling of $[n]$ into a finite vector space over $\mathbb{F}_q$ produces a weakly $D_6$-free family in $2^{[n]}$ of size at least $c\binom{n}{\le}$.

The strategic idea behind the conjecture is compelling: **exclusion is deterministic**, so only the *lower bound on the number of selected sets* requires estimates, and those estimates can be made explicit via Gaussian-binomial inequalities, yielding a finite threshold $n_0$.

### 1.2 Contribution

This paper carries out the deterministic half of that program in full and, in doing so, refutes the conjecture for the entire class of abelian sum-labelling constructions. Precisely, we show:

* the deterministic exclusion condition is not merely sufficient, but a characterisation (Theorem 3.4);
* for sum-labelling constructions it is equivalent to a purely algebraic *safety* condition on the pair $(v, U)$ (Theorem 4.3);
* safety is drastically restrictive: label classes have size $\le 2$ (Theorem 4.4), and the keep-set has size $\le 2$ (Theorem 4.5), so the selection retains at most **two colour classes out of $|V| \ge n/2$**;
* the resulting cardinality gain over three layers is therefore $O(1/n)$ relative to $\binom{n}{\le}$ (Theorems 4.7, 4.8);
* independently, extremal graph theory caps *all* four-layer constructions keeping three layers whole at $\approx 3.5\binom{n}{\le}$ (Theorems 5.4, 5.5).

The failure is not caused by a lossy estimate. It is a two-line pigeonhole in $V$: the pair-sum symmetry $\{x,y\} \mapsto v(x)+v(y)$ that makes sum-labelling analytically tractable is exactly what forces the keep-set to collapse.

### 1.3 Organisation

Section 2 fixes notation and proves the interval formula. Section 3 gives the baseline, its saturation, and the exclusion criterion. Section 4 contains the abelian no-go theorem. Section 5 develops the Turán ceiling. Section 6 presents the height hierarchy. Section 7 describes algorithms and numerical verification. Section 8 discusses consequences and future directions.

---

## 2. Preliminaries

Throughout, $[n] = \{0,1,\dots,n-1\}$ and all families are finite families of finite subsets of $[n]$.

**Definition 2.1 (Layer).** For $n, k \in \mathbb{N}$, the *$k$-th layer* is
$$\mathcal{L}(n,k) \;=\; \{\, S \subseteq [n] : |S| = k \,\}, \qquad |\mathcal{L}(n,k)| = \binom{n}{k}.$$
Distinct layers are disjoint.

**Definition 2.2 (Weak diamond containment).** A family $\mathcal{F}$ *weakly contains* $D_j$ if there exist $A, C \in \mathcal{F}$ and a set $\mathcal{S} \subseteq \mathcal{F}$ with $|\mathcal{S}| = j$ such that $A \subsetneq B \subsetneq C$ for every $B \in \mathcal{S}$. Otherwise $\mathcal{F}$ is *weakly $D_j$-free*.

**Lemma 2.3 (Monotonicity).** If $j \le l$ and $\mathcal{F}$ weakly contains $D_l$, then $\mathcal{F}$ weakly contains $D_j$. Equivalently, weak $D_j$-freeness implies weak $D_l$-freeness for $j \le l$.

*Proof.* Discard $l - j$ of the middle sets. $\square$

**Definition 2.4 (Open interval).** For $A, C \subseteq [n]$, put $(A,C) = \{\, B : A \subsetneq B \subsetneq C \,\}$.

**Theorem 2.5 (Interval size).** If $A \subseteq C$ and $A \ne C$, then
$$|(A,C)| \;=\; 2^{|C| - |A|} - 2 .$$

*Proof sketch.* The map $B \mapsto B \setminus A$, with inverse $D \mapsto A \cup D$, is a bijection between $(A,C)$ and the set of subsets $D \subseteq C \setminus A$ with $D \ne \varnothing$ and $D \ne C\setminus A$. Indeed, $A \subsetneq B \subsetneq C$ forces $A \subseteq B \subseteq C$, so $B$ is determined by $B\setminus A \subseteq C\setminus A$; strictness at the bottom says $B\setminus A \ne \varnothing$ and strictness at the top says $B \setminus A \ne C\setminus A$. The target has $2^{|C\setminus A|} - 2 = 2^{|C|-|A|}-2$ elements since $|C\setminus A| = |C|-|A|$. $\square$

Theorem 2.5 is the engine of everything that follows; the values $2^2 - 2 = 2$ and $2^3 - 2 = 6$ are the two numbers the whole theory turns on.

**Lemma 2.6 (Height of a diamond).** If $A \subsetneq B \subsetneq C$ then $A \subseteq C$ and $|C| \ge |A| + 2$.

---

## 3. The three-layer baseline and the exclusion criterion

### 3.1 The baseline

**Theorem 3.1 (Three layers are weakly $D_3$-free).** Let $\mathcal{F}$ be a family all of whose members $S$ satisfy $k \le |S| \le k+2$. Then $\mathcal{F}$ is weakly $D_3$-free, hence weakly $D_6$-free.

*Proof sketch.* Suppose $A, C \in \mathcal{F}$ have three distinct sets of $\mathcal{F}$ strictly between them. By Lemma 2.6, $|C| \ge |A|+2$; combined with the window constraint, $|C| - |A| = 2$ exactly. By Theorem 2.5 the interval $(A,C)$ has $2^2 - 2 = 2$ members, and the three middle sets embed into it — a contradiction. $\square$

**Definition 3.2 (Baseline family).** $\mathcal{T}(n,k) = \mathcal{L}(n,k)\cup\mathcal{L}(n,k{+}1)\cup\mathcal{L}(n,k{+}2)$.

**Theorem 3.3 (Baseline cardinality).** $|\mathcal{T}(n,k)| = \binom{n}{k}+\binom{n}{k+1}+\binom{n}{k+2}$, and $\mathcal{T}(n,k)$ is weakly $D_6$-free. For $k = \lfloor n/2\rfloor - 1$ this is $(3 - o(1))\binom{n}{\le}$.

### 3.2 The exclusion criterion

**Theorem 3.4 (Interval-exclusion criterion).** Let $\mathcal{F}$ be a family with $k \le |S| \le k+3$ for all $S \in \mathcal{F}$. Then $\mathcal{F}$ is weakly $D_6$-free **if and only if**
$$\forall A, C \in \mathcal{F} \ \text{with}\ A \subseteq C,\ |C| = |A|+3 : \quad \exists B \ \text{with}\ A \subsetneq B \subsetneq C \ \text{and}\ B \notin \mathcal{F}. \tag{E}$$

*Proof sketch.*
*(Necessity.)* If (E) fails for some pair $A \subseteq C$ of height $3$, the entire interval $(A,C)$ lies in $\mathcal{F}$. By Theorem 2.5 it has exactly six members, and they witness a weak $D_6$ with endpoints $A, C$.

*(Sufficiency.)* Assume (E) and suppose $A, C \in \mathcal{F}$ have six distinct members of $\mathcal{F}$ strictly between them. These six lie in $(A,C)$, so $6 \le 2^{|C|-|A|}-2$, whence $|C|-|A| \ge 3$; the window bound gives $|C| - |A| \le 3$, so equality holds and $|(A,C)| = 6$. The six middle sets, being six distinct elements of a six-element set, *are* $(A,C)$; thus $(A,C) \subseteq \mathcal{F}$, contradicting (E). $\square$

Theorem 3.4 is the pivotal reduction. It says that inside a four-layer window, avoiding $D_6$ is not a global or statistical property but an entirely local and deterministic one, checkable interval by interval. Any construction is therefore a *deletion problem*: choose which sets to remove so that no height-$3$ interval survives complete, while removing as few sets as possible.

### 3.3 Rigidity of the baseline

**Theorem 3.5 (A full interval is a weak $D_6$).** If $A, C \in \mathcal{F}$, $A \subseteq C$, $|C| = |A|+3$ and $(A,C) \subseteq \mathcal{F}$, then $\mathcal{F}$ is not weakly $D_6$-free.

**Theorem 3.6 (Four full layers are never free).** For $k + 3 \le n$, the family $\mathcal{L}(n,k)\cup\mathcal{L}(n,k{+}1)\cup\mathcal{L}(n,k{+}2)\cup\mathcal{L}(n,k{+}3)$ is not weakly $D_6$-free.

*Proof sketch.* Choose any $A$ of size $k$ and extend it to $C$ of size $k+3$ inside $[n]$. Every $B$ with $A \subsetneq B \subsetneq C$ has $|B| \in \{k+1,k+2\}$, so lies in the family; apply Theorem 3.5. $\square$

**Theorem 3.7 (Saturation of the baseline).** Let $X \subseteq [n]$.
(i) If $|X| = k+3$ then $\{X\} \cup \mathcal{T}(n,k)$ is not weakly $D_6$-free.
(ii) If $|X| = k$ and $k+3 \le n$ then $\{X\} \cup \mathcal{T}(n,k{+}1)$ is not weakly $D_6$-free.
Consequently $\mathcal{T}(n,k)$ is a maximal weakly $D_6$-free family inside its four-layer window: every $X$ of the window not already present destroys freeness.

*Proof sketch.* For (i) pick $A \subseteq X$ with $|A| = k$; the six sets strictly between $A$ and $X$ have sizes $k+1$ and $k+2$, hence all lie in $\mathcal{T}(n,k)$; apply Theorem 3.5. For (ii) extend $X$ upward to a $(k+3)$-set $C$ inside $[n]$ and argue symmetrically. $\square$

Thus the baseline cannot be improved by *addition*; any improvement must come from a genuinely different family, and by Theorem 3.6 any four-layer family must *delete*.

---

## 4. The abelian no-go theorem

### 4.1 The mechanism

**Definition 4.1 (Sum labelling and selected family).** Let $V$ be a finite abelian group, $v : [n] \to V$ a labelling, and $U \subseteq V$ a *keep-set*. The *sum label* of $S \subseteq [n]$ is $\sigma_v(S) = \sum_{i \in S} v(i)$. The *selected family* is
$$\mathcal{F}(n,k,v,U) \;=\; \mathcal{L}(n,k) \;\cup\; \mathcal{L}(n,k{+}1) \;\cup\; \{\, S \in \mathcal{L}(n,k{+}2) : \sigma_v(S) \in U \,\} \;\cup\; \mathcal{L}(n,k{+}3).$$

Three layers are kept in full; only the interior layer $k+2$ is thinned. This is the canonical form of the conjectured construction: taking $V = \mathbb{F}_q^d$ makes $\sigma_v$ a linear functional of the indicator vector of $S$, so counting the sets of each colour reduces to counting solutions of a linear equation of prescribed weight — the point at which Gaussian-binomial estimates would enter.

Two auxiliary notions are needed. The first is a spread hypothesis, the second the algebraic condition that will do all the work.

**Definition 4.2 (Sum-richness).** The labelling $v$ is *sum-rich at level $k$* if for every $g \in V$ and all $x,y,z \in [n]$ there is a $k$-set $A \subseteq [n]$ with $A \cap \{x,y,z\} = \varnothing$ and $\sigma_v(A) = g$.

Sum-richness is exactly the "probabilistic rank estimate" of the original program, isolated as a hypothesis. It is a very weak assumption: for $V = \mathbb{F}_q^d$ with $q^d = o(\binom{n-3}{k})$ and a labelling of full rank, a standard character-sum or rank argument shows every $g$ is realised, typically $\binom{n-3}{k}/|V|(1+o(1))$ times.

**Definition 4.3 (Safety).** The pair $(v,U)$ is *safe* if there is no $g \in V$ and no three distinct $x,y,z \in [n]$ with
$$g + v(x)+v(y) \in U, \qquad g+v(x)+v(z) \in U, \qquad g+v(y)+v(z) \in U .$$

### 4.2 Freeness forces safety

**Theorem 4.3 (Freeness $\Rightarrow$ safety).** If $v$ is sum-rich at level $k$ and $\mathcal{F}(n,k,v,U)$ is weakly $D_6$-free, then $(v,U)$ is safe.

*Proof sketch.* Suppose safety fails, witnessed by $g$ and distinct $x,y,z \in [n]$. By sum-richness choose a $k$-set $A$ disjoint from $\{x,y,z\}$ with $\sigma_v(A) = g$, and set $C = A \cup \{x,y,z\}$, a $(k+3)$-set. Both $A$ and $C$ belong to $\mathcal{F}$ (layers $k$ and $k+3$ are kept whole). By Theorem 3.4 there must be some $B$ with $A \subsetneq B \subsetneq C$ and $B \notin \mathcal{F}$. Every such $B$ equals $A \cup D$ for a nonempty proper $D \subsetneq \{x,y,z\}$, so $|B| \in \{k+1, k+2\}$.

If $|B| = k+1$ then $B \in \mathcal{L}(n,k{+}1) \subseteq \mathcal{F}$ — contradiction. If $|B| = k+2$ then $D$ is one of the three pairs $\{x,y\}, \{x,z\}, \{y,z\}$, and since $A$ and $D$ are disjoint,
$$\sigma_v(B) = \sigma_v(A) + \sigma_v(D) = g + v(a) + v(b)$$
for the corresponding pair $\{a,b\}$. By the failure of safety this lies in $U$, so $B \in \mathcal{F}$ — contradiction again. Hence no such $B$ exists, contradicting exclusion. $\square$

This is the exact translation promised by the strategic insight: for sum-labelling constructions, the deterministic interval condition *is* the algebraic condition of Definition 4.3. Nothing is lost in the translation — Theorem 4.3 is an equivalence in substance, since a safe pair also satisfies exclusion at every height-$3$ interval whose bottom lies in layer $k$.

### 4.3 Safety collapses the selection

**Theorem 4.4 (Label multiplicity).** If $(v,U)$ is safe and $U \ne \varnothing$, then every label class has at most two elements:
$$|\{\, i \in [n] : v(i) = a \,\}| \le 2 \qquad \text{for all } a \in V .$$

*Proof.* Suppose $x, y, z \in [n]$ are distinct with $v(x)=v(y)=v(z)=a$. Pick $u \in U$ and set $g = u - 2a$. Then all three pair-labels equal $g + a + a = u \in U$, contradicting safety. $\square$

**Corollary 4.4.1.** If $U \ne \varnothing$ then $|v([n])| \ge n/2$, hence $|V| \ge n/2$: the labelling group is forced to be large.

**Theorem 4.5 (The closure obstruction).** Suppose $(v,U)$ is safe and the label set $L = v([n])$ satisfies
$$2|V| \;<\; 3|L| .$$
Then $|U| \le 2$.

*Proof.* Suppose $|U| \ge 3$ and pick distinct $u_1,u_2,u_3 \in U$. Put $\alpha = u_1 - u_3$ and $\beta = u_1 - u_2$; these are nonzero and distinct from each other (if $\alpha = \beta$ then $u_2 = u_3$).

Consider the three subsets $L$, $L - \alpha$, $L - \beta$ of $V$; translation is a bijection, so all three have cardinality $|L| > \tfrac{2}{3}|V|$. Two applications of the inclusion–exclusion bound $|X| + |Y| \le |X\cap Y| + |V|$ give
$$|L \cap (L-\alpha) \cap (L-\beta)| \;\ge\; 3|L| - 2|V| \;>\; 0 .$$
Choose $c$ in the triple intersection. Then $c, c+\alpha, c+\beta \in L$, so there are $z, x, y \in [n]$ with
$$v(z) = c, \qquad v(x) = c+\alpha, \qquad v(y) = c+\beta .$$
Since $\alpha \ne 0$, $\beta \ne 0$ and $\alpha \ne \beta$, the three labels are pairwise distinct, hence so are $x, y, z$.

Finally set $g = u_2 + u_3 - u_1 - 2c$. Then
$$g + v(x)+v(y) = u_2+u_3-u_1+\alpha+\beta = u_1, \quad g+v(x)+v(z) = u_2+u_3-u_1+\alpha = u_2,$$
$$g+v(y)+v(z) = u_2+u_3-u_1+\beta = u_3,$$
all three in $U$ — contradicting safety. $\square$

The mechanism deserves a name because it explains *why* the conjecture fails: the three pair-sums attached to a triple $\{x,y,z\}$ can be steered, by the free shift $g$, onto **any** three group elements that are realised as $c, c+\alpha, c+\beta$ with the right differences. A keep-set of three or more elements always prescribes such a difference pattern, and a label set of density above $2/3$ always realises it. The keep-set is thus *closed* under nothing more than pigeonhole pressure.

**Theorem 4.6 (Small groups cannot help).** If $(v,U)$ is safe, $U \ne \varnothing$, and $4|V| < 3n$, then $|U| \le 2$.

*Proof.* By Theorem 4.4 every fibre of $v$ has at most two points, so $n \le 2|L|$, i.e. $|L| \ge n/2 > \tfrac{2}{3}|V|$ by the hypothesis $4|V| < 3n$. Apply Theorem 4.5. $\square$

Theorems 4.4–4.6 form a pincer. If $|V|$ is small (below $3n/4$), the keep-set collapses to at most two elements out of $|V|$. If $|V|$ is large, the keep-set may in principle be larger, but the *labels* now occupy a vanishing fraction of $V$ and — as Theorem 4.7 shows — what matters is not $|U|/|V|$ but the absolute number of surviving colour classes, which the same argument bounds by $2$ whenever the density hypothesis holds. Either way the surviving portion of the interior layer is at most two colour classes.

### 4.4 The cardinality bound

**Theorem 4.7 (Cardinality ceiling).** Suppose every colour class inside the interior layer is small: $|\{S \in \mathcal{L}(n,k{+}2) : \sigma_v(S) = u\}| \le b$ for every $u \in V$. If $|U| \le 2$, then
$$|\mathcal{F}(n,k,v,U)| \;\le\; 3\binom{n}{\lfloor n/2\rfloor} + 2b .$$

*Proof sketch.* The thinned layer is contained in the union of $|U|$ colour classes, hence has at most $|U| \cdot b \le 2b$ members. The three full layers each have at most $\binom{n}{\lfloor n/2\rfloor}$ members, since the central binomial coefficient dominates every layer. Add. $\square$

**Theorem 4.8 (No constant improvement).** Let $v$ be sum-rich at level $k$ with $2|V| < 3|v([n])|$, let every interior colour class have at most $b$ members, and suppose $K b \le \binom{n}{\lfloor n/2\rfloor}$ for a positive integer $K$. If $\mathcal{F}(n,k,v,U)$ is weakly $D_6$-free, then
$$K\,|\mathcal{F}(n,k,v,U)| \;\le\; (3K+2)\binom{n}{\lfloor n/2 \rfloor}, \qquad \text{i.e.} \qquad |\mathcal{F}| \le \Bigl(3 + \frac{2}{K}\Bigr)\binom{n}{\lfloor n/2\rfloor}.$$
The same conclusion holds with the density hypothesis $2|V| < 3|v([n])|$ replaced by the size condition $4|V| < 3n$.

*Proof sketch.* Combine Theorem 4.3 (freeness $\Rightarrow$ safety), Theorem 4.5 or 4.6 ($|U| \le 2$) and Theorem 4.7, then multiply by $K$ and use $Kb \le \binom{n}{\le}$. $\square$

**Corollary 4.9 (Refutation for the abelian mechanism).** Assume the equidistribution $b \approx \binom{n}{k+2}/|V|$, which holds to high numerical accuracy for full-rank labellings, and recall $|V| \ge n/2$ from Corollary 4.4.1. Taking $K \approx |V|$ gives
$$c \;\le\; 3 + \frac{2}{|V|} \;\le\; 3 + \frac{4}{n} \;=\; 3 + O(1/n).$$
Hence for every fixed rational $c > 3$ and every finite abelian group $V$, the labelling mechanism fails for all sufficiently large $n$. The gain is positive but vanishing.

It is worth emphasising what is *not* the reason for failure. The bound does not come from a lossy union bound or a suboptimal estimate on the number of sets of a given colour: even a perfectly equidistributed labelling, and even the optimal choice of $U$, saves nothing, because safety permits only two colours. The obstruction is structural.

---

## 5. A Turán ceiling for four-layer constructions

The no-go theorem closes one avenue. This section pushes a wall in from the other side, bounding *every* four-layer construction that keeps three layers whole — regardless of how its deletions are chosen.

**Definition 5.1 (Link graph).** For $A \in \mathcal{L}(n,k)$ and a family $\mathcal{F}$, the *link graph* $G_A$ has vertex set $[n]\setminus A$ and edge set
$$E(G_A) = \{\, \{x,y\} \subseteq [n]\setminus A : A \cup \{x,y\} \in \mathcal{F} \,\}.$$

**Theorem 5.2 (Link graphs are triangle-free).** Let $\mathcal{F}$ be weakly $D_6$-free with $\mathcal{L}(n,k{+}1) \subseteq \mathcal{F}$ and $\mathcal{L}(n,k{+}3)\subseteq\mathcal{F}$, and let $A \in \mathcal{F} \cap \mathcal{L}(n,k)$. Then $G_A$ contains no triangle.

*Proof sketch.* Suppose $\{x,y\},\{x,z\},\{y,z\} \in E(G_A)$ with $x,y,z$ distinct and outside $A$. Put $C = A\cup\{x,y,z\}$, of size $k+3$, so $C \in \mathcal{F}$. The interval $(A,C)$ consists of the three $(k{+}1)$-sets $A\cup\{x\}, A\cup\{y\}, A\cup\{z\}$, all in $\mathcal{F}$ since layer $k+1$ is full, and the three $(k{+}2)$-sets $A\cup\{x,y\}, A\cup\{x,z\}, A\cup\{y,z\}$, all in $\mathcal{F}$ by the triangle. Thus $(A,C) \subseteq \mathcal{F}$ and Theorem 3.5 gives a weak $D_6$. $\square$

**Theorem 5.3 (Mantel bound for links).** Under the hypotheses of Theorem 5.2,
$$4\,|E(G_A)| \;\le\; (n-k)^2 .$$

*Proof.* $G_A$ is a triangle-free graph on $n - k$ vertices; Mantel's theorem (the $r=2$ case of Turán's theorem) bounds its edge count by $\lfloor (n-k)^2/4\rfloor$. $\square$

**Theorem 5.4 (Turán ceiling for the interior layer).** Let $\mathcal{F}$ be weakly $D_6$-free with $\mathcal{L}(n,k), \mathcal{L}(n,k{+}1), \mathcal{L}(n,k{+}3) \subseteq \mathcal{F}$. Then
$$4\binom{k+2}{2}\,\bigl|\mathcal{F}\cap\mathcal{L}(n,k{+}2)\bigr| \;\le\; \binom{n}{k}(n-k)^2 .$$

*Proof sketch.* Double count incidences $(A, S)$ with $A \in \mathcal{L}(n,k)$, $S \in \mathcal{F}\cap\mathcal{L}(n,k{+}2)$, $A \subseteq S$. For a fixed $A$, the sets $S$ above it correspond bijectively to the edges of $G_A$ via $S \mapsto S\setminus A$, so there are $|E(G_A)| \le (n-k)^2/4$ of them; summing over the $\binom{n}{k}$ choices of $A$ bounds the incidence count by $\binom{n}{k}(n-k)^2/4$. For a fixed $S$, the sets $A$ below it are the $k$-subsets of $S$, of which there are $\binom{k+2}{k} = \binom{k+2}{2}$. Equate and rearrange. $\square$

**Theorem 5.5 (Partial-layer refinement).** Without assuming layer $k$ is kept in full, the same double count gives
$$4\sum_{S \in \mathcal{F}\cap\mathcal{L}(n,k+2)} \bigl|\{A \in \mathcal{F}\cap\mathcal{L}(n,k) : A \subseteq S\}\bigr| \;\le\; \bigl|\mathcal{F}\cap\mathcal{L}(n,k)\bigr| \, (n-k)^2 ,$$
whenever $\mathcal{F}$ is weakly $D_6$-free and contains layers $k+1$ and $k+3$ in full. This exhibits an explicit trade-off: keeping more of the interior layer forces deletions in the bottom layer.

**Theorem 5.6 (Total ceiling).** If moreover every member of $\mathcal{F}$ has size in $[k, k+3]$, then
$$4\binom{k+2}{2}\,|\mathcal{F}| \;\le\; 4\binom{k+2}{2}\Bigl(\binom{n}{k}+\binom{n}{k+1}+\binom{n}{k+3}\Bigr) + \binom{n}{k}(n-k)^2 .$$

**Corollary 5.7 (The $3.5$ corridor).** Take $k \approx (n-3)/2$, so that $\binom{n}{k}, \binom{n}{k+1}, \binom{n}{k+3}$ are all $\approx \binom{n}{\le}$ up to lower-order factors. Then $(n-k)^2 \approx n^2/4$ and $4\binom{k+2}{2}\approx n^2/2$, so Theorem 5.4 gives
$$\bigl|\mathcal{F}\cap\mathcal{L}(n,k{+}2)\bigr| \;\lesssim\; \tfrac{1}{2}\binom{n}{\le},$$
and hence $|\mathcal{F}| \lesssim 3.5\binom{n}{\le}$. No four-layer construction keeping three layers whole can exceed $c = 3.5$.

Note the pleasing duality with Section 4. The Turán ceiling says *at most half* the interior layer survives; the no-go theorem says that if the deletion rule is an abelian sum-labelling, only *two colour classes* survive — a fraction $2/|V| = O(1/n)$ rather than $1/2$. The abelian mechanism therefore falls short of the graph-theoretic ceiling by a factor of order $n$.

---

## 6. The height hierarchy

Nothing above depends on the number $6$ except through the identity $6 = 2^3 - 2$. The general statements are as follows; each specialises at $m=3$ to a theorem of Sections 2–3 and at $m=2$ to a classical statement about the diamond $D_2$.

**Theorem 6.1 (Automatic freeness).** Let $m \ge 1$ and let $\mathcal{F}$ have all member sizes in $[k, k+m]$. Then $\mathcal{F}$ is weakly $D_{2^m-1}$-free.

*Proof sketch.* Any interval between two members has height at most $m$ and therefore at most $2^m-2 < 2^m - 1$ interior sets. $\square$

**Theorem 6.2 (Critical criterion).** Let $m \ge 2$ and let $\mathcal{F}$ have all member sizes in $[k,k+m]$. Then $\mathcal{F}$ is weakly $D_{2^m-2}$-free **iff** every $A, C \in \mathcal{F}$ with $A \subseteq C$ and $|C| = |A|+m$ satisfy: some $B$ with $A \subsetneq B\subsetneq C$ is missing from $\mathcal{F}$.

*Proof sketch.* Identical in structure to Theorem 3.4. If an interval of height $m$ is complete, its $2^m-2$ interior sets form a weak $D_{2^m-2}$. Conversely, $2^m-2$ middle sets force $2^m - 2 \le 2^{|C|-|A|}-2$, hence height exactly $m$, hence the middle sets exhaust the interval. $\square$

**Theorem 6.3 (Window cardinality and saturation).** The window family $\mathcal{W}(n,k,m) = \bigcup_{j<m}\mathcal{L}(n,k{+}j)$ has $\sum_{j<m}\binom{n}{k+j}$ members, and for $m\ge 2$ it is saturated: for any $X \subseteq [n]$ with $|X| = k+m$, the family $\{X\}\cup\mathcal{W}(n,k,m)$ is not weakly $D_{2^m-2}$-free.

*Proof sketch.* Take $A \subseteq X$ with $|A| = k$. Every $B$ strictly between $A$ and $X$ has $k < |B| < k+m$, hence lies in the window. So the height-$m$ interval $(A,X)$ is complete and contains $2^m-2$ sets. $\square$

The hierarchy also clarifies the *design trade-off* for future constructions. Using a window of $m+1$ layers gains you a fourth, fifth, … layer of sets, but each height-$m$ interval you must break has $2^m-2$ interior sets, of which $\binom{m}{\lfloor m/2\rfloor}$ sit in the widest interior level. Deletion is cheap when a single removed set breaks many intervals; the ratio of intervals to sets grows with $m$, which is why larger windows are the most promising place to look for constant gains.

---

## 7. Algorithms and numerical verification

The theory above is finitary and directly checkable for small $n$. Four algorithmic components are natural.

### 7.1 Exhaustive weak-diamond detection

To certify whether a family $\mathcal{F} \subseteq 2^{[n]}$ is weakly $D_j$-free, it suffices — by the very definition — to test, for each comparable pair $A \subseteq C$ in $\mathcal{F}$ with $|C| \ge |A| + 2$, whether $|(A,C)\cap\mathcal{F}| \ge j$. The cost is $O(|\mathcal{F}|^2 \cdot 2^{h})$ where $h$ is the maximal height, but in a window of height $m$ the inner enumeration is a loop over $2^m - 2$ candidates, so the total is $O(|\mathcal{F}|^2 2^m)$. For $n \le 12$ and $m = 3$ this is entirely practical and confirms, in particular, Theorems 3.1, 3.6 and 3.7 on concrete instances.

### 7.2 Interval-exclusion certification

Theorem 3.4 replaces the quadratic search by a much cheaper certification for four-layer families: enumerate pairs $(A, T)$ where $A \in \mathcal{F}\cap\mathcal{L}(n,k)$ and $T$ is a $3$-subset of $[n]\setminus A$, and check that at least one of the six sets $A \cup D$, $\varnothing \ne D \subsetneq T$, is absent. The complexity is $O(\binom{n}{k}\binom{n-k}{3})$ with a constant of $6$, which is a factor $\approx \binom{n}{k}$ cheaper than naive detection.

### 7.3 Safety search over a labelling

Given $V$, $v$ and $U$, safety can be certified in $O(|V| \cdot n^3)$ by direct enumeration, or far faster by the following reformulation: $(v,U)$ is unsafe iff there exist distinct labels $a = v(x)$, $b = v(y)$, $c = v(z)$ and $g$ with $g+a+b, g+a+c, g+b+c \in U$. Eliminating $g$, this says the difference pattern $(u_1 - u_2, u_1 - u_3) = (c - b, b - a)$ — for some triple $u_1,u_2,u_3 \in U$ — is realised by three labels. So one loops over ordered triples in $U$ (cost $|U|^3$) and, for each, tests whether $L \cap (L-\alpha)\cap(L-\beta) \ne \varnothing$ (cost $|V|$). Total $O(|U|^3|V| + n)$. Running this over all $U \subseteq V$ for small cyclic $V$ confirms Theorems 4.4–4.6 exhaustively.

### 7.4 Gain evaluation

Finally, one evaluates the actual constant achieved. For a labelling $v$ and the *best* safe keep-set $U$, the selected family has size $\binom{n}{k}+\binom{n}{k+1}+\binom{n}{k+3} + \sum_{u\in U} N_u$, where $N_u = |\{S \in \mathcal{L}(n,k{+}2):\sigma_v(S) = u\}|$. Dividing by $\binom{n}{\lfloor n/2\rfloor}$ yields the empirical $c$. Numerically, for $V=\mathbb{Z}_q$ with $q$ modestly below $3n/4$ and any labelling, the maximal safe $U$ has two elements, and $c - 3$ tracks $2/q$ with high accuracy, confirming Corollary 4.9 in the finite regime.

---

## 8. Discussion

### 8.1 What the results mean for the conjecture

The original conjecture bet on a clean separation of concerns: interval exclusion is deterministic, so only the *size* of the selection needs quantitative work, and Gaussian-binomial inequalities would make that work explicit and finite. Theorem 4.3 vindicates the first half of the bet completely — the translation from combinatorics to algebra is exact and loses nothing. But it also reveals that the deterministic condition is far stronger than anticipated. Rather than merely forbidding a positive-density set of "bad" configurations, safety forbids *all but two* colours. There is no quantitative regime, no clever choice of $q$, $d$, or $U$, in which the abelian mechanism yields a constant gain: the bound $c \le 3+2/K$ with $K \approx |V| \ge n/2$ is unconditional given equidistribution, and even without equidistribution one has $|\mathcal{F}| \le 3\binom{n}{\le} + 2b$ with $b$ the largest colour class.

### 8.2 Where the argument is tight

Two features of the abelian setting drive the collapse, and both suggest escapes.

*Translation invariance.* The shift $g$ is free because $\sigma_v(A \cup D) = \sigma_v(A) + \sigma_v(D)$ and $\sigma_v(A)$ ranges over all of $V$ by sum-richness. If the rule depended on $S$ in a way not factoring through a group homomorphism, the adversary would lose this free parameter.

*Pair symmetry.* The three interior $(k{+}2)$-sets of an interval differ from $A$ by the three *pairs* inside a triple, and $v(x)+v(y)$ is symmetric. A rule sensitive to more than the multiset of labels — for example one depending on the *order* or on a nonabelian product — would not reduce to a three-term additive pattern.

### 8.3 Consequences for the search space

Collecting the constraints:

1. Improvements must delete only from *interior* layers, since the extreme layers of a window are rigid (Theorem 3.7).
2. The deletion rule is characterised by a local, deterministic condition, so no probabilistic construction can do better than the best deterministic one (Theorem 3.4).
3. The rule cannot be an abelian sum-labelling (Theorem 4.8, Corollary 4.9).
4. Within four layers keeping three whole, the constant is at most $3.5$ (Corollary 5.7).

The corridor is thus $3 < c \le 3.5$, and the admissible mechanisms are strongly constrained. Any candidate construction can now be tested against items 1–4 before any asymptotic analysis is attempted.

### 8.4 Related classical context

The interval formula $2^d - 2$ and the layer construction are folklore in extremal set theory; the novelty here is the *equivalence* in Theorem 3.4 and its exact algebraic shadow in Theorem 4.3, together with the pigeonhole collapse of Theorem 4.5. The use of Mantel's theorem on link graphs is a standard technique in hypergraph Turán problems, but its consequence here — a hard $3.5$ ceiling matching the $3$ from below to within a factor of $7/6$ — is unusually tight for a problem of this type.

### 8.5 Future directions

The next cycle should attack the corridor from both ends.

**Bipartite-link threshold constructions.** Fix a reference set $X \subseteq [n]$ with $|X| = \lfloor n/2\rfloor$ and keep a $(k{+}2)$-set $S$ according to a rule $R(S)$ depending only on $t = |S \cap X|$. The link graph at a $k$-set $A$ is then determined by how the two added points split between $X$ and its complement; a rule that keeps $S$ only when the added pair is *split* makes every link graph a complete bipartite graph, hence triangle-free *by construction* rather than by luck. Complete bipartite graphs are exactly the extremal examples for Mantel's theorem, so this is the unique shape that can hope to approach the $3.5$ ceiling. The question is whether the density of split pairs, integrated over $A$, exceeds a constant fraction — and, crucially, whether exclusion is genuinely satisfied at *all* height-$3$ intervals, including those whose bottom does not lie in the kept part of layer $k$.

**Nonabelian and nonlinear labellings.** Replace $\sigma_v(S) = \sum_{i\in S}v(i)$ by a rule that does not factor through an abelian group: an ordered product in a nonabelian group, a quadratic form on the indicator vector, or a threshold on a bounded-depth Boolean function. The precise target is to break the free shift parameter $g$, which is what allows the closure obstruction. A concrete first test: does there exist a rule on layer $k+2$ whose "unsafe patterns" fail to be translation-invariant, and for which the surviving fraction is bounded below by an absolute constant?

**Higher windows.** Use $m \ge 4$. In a window of $m+1$ layers, the relevant threshold is $D_{2^m-2}$, and the baseline is $m$ layers ($\approx m\binom{n}{\le}$). Since the number of intervals grows much faster than the number of sets, deletion becomes cheaper per interval broken; determining the growth rate of the optimal constant in $m$, even heuristically, would indicate whether the $D_6$ case is anomalously hard.

**Sharpening the ceiling.** Corollary 5.7 uses Mantel's theorem on each link graph independently. The link graphs at nested bottom sets are highly correlated, so a *stability* or *supersaturation* version of Mantel should improve the $3.5$ constant. Any improvement below $3 + \varepsilon$ for an explicit $\varepsilon$ would close the corridor from above and, combined with the baseline, determine the extremal constant exactly.

**Two-sided thinning.** All constructions considered here thin exactly one layer. Thinning two interior layers simultaneously, so that each height-$3$ interval is broken at whichever level is locally cheaper, changes the optimisation to a covering problem: cover all height-$3$ intervals by removed sets, minimising the number of removals. The LP relaxation of this covering problem gives a lower bound on the deletion cost, and its value — computable exactly for small $n$ — would immediately reveal whether any four-layer construction can beat $3$ by a constant.

---

## 9. Conclusion

The interval identity $|(A,C)| = 2^{|C|-|A|}-2$ organises the entire theory of weakly diamond-free families in a bounded window of the Boolean lattice. It yields the three-layer baseline and its saturation, the exact interval-exclusion criterion characterising freeness in a four-layer window, the general height hierarchy in which weak $D_{2^m-2}$-freeness corresponds to exclusion at height $m$, and — through the induced algebraic safety condition — a complete refutation of the abelian sum-labelling mechanism as a route to a constant improvement over three middle layers. Complementing this, link-graph triangle-freeness and Mantel's theorem cap all four-layer constructions near $3.5$. The question "is there a constant $c > 3$?" now has a precise shape: it lives in the corridor $3 < c \le 3.5$, and it demands a deletion rule outside the abelian world.
