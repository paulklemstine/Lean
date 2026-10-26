# Knee Stability Is Equivalent to Tail-Exchangeability

### Order statistics, Galois connections, and count bands for finite demand multisets

**Author:** Aristotle

**Date:** 2026-10-26

---

## Abstract

A *demand multiset* is a finite multiset $D$ of non-negative integers. Its *upper-tail counting function* $\mathrm{tail}_D(t)$ counts the demands strictly larger than a threshold $t$. Its *knee* at gate $g$, $\mathrm{knee}_D(g)$, is the least threshold exceeded by at most $g$ demands. We prove that knees and tails form a Galois connection, $\mathrm{knee}_D(g) \le t \iff \mathrm{tail}_D(t) \le g$, and that the knee at gate $g$ is the $g$-th largest demand (indexed from $0$, and $0$ past the end).

From this we derive a complete answer to the question of when two demand multisets "look the same through their knees". Equal knees at every gate is equivalent to equal tail functions, and also to equality of the sub-multisets of *positive* demands. The unguarded statement with equality of full multisets is false. Equal knees on a gate window $a \le g < a + w$ is equivalent to equality of the tail functions after clamping to the count band $[a, a+w]$. We show that the naive closed-band formulation fails. A sweep over $\max(|D|, |D'|)$ gates decides all-gate equality.

We also prove the conjugate-partition duality between knees and tails, the area identity $\sum_{g<|D|} \mathrm{knee}_D(g) = \sum D$, and a sharp quantitative stability theorem. A $k$-gate shift between knee profiles is equivalent to a uniform additive bound $k$ between tails. This gives contamination and merge bounds. The practical consequence is that a single tail histogram per collection is a sufficient statistic for every question about knees, so multi-gate sweeps can be replaced by one counting pass.

---

## 1. Introduction

Many empirical procedures summarise a collection of non-negative integer "demands" by a threshold that tolerates a prescribed number of exceedances. The demands might be document lengths, request sizes, latencies or resource requirements. Given a *gate* $g$, meaning the number of exceedances one is willing to tolerate, the *knee* is the smallest threshold exceeded by at most $g$ items. Comparing two collections by their knees at a handful of gates is common. We call this *knee stability*. It is usually done by recomputing knees at each gate for each collection, a *sweep*.

This paper studies knee stability exactly. The central observation is elementary but has strong consequences:

> *The knee is an order statistic, so agreement of knees on an interval of gates is exactly agreement of the inverse distribution function on the corresponding interval of ranks.*

We make this precise through a Galois connection between the knee function and the upper-tail counting function. We then answer three questions completely.

1. **All gates.** When do two collections have the same knee at *every* gate? (Theorem 4.3.)
2. **Gate windows.** When do they have the same knee on a *window* of gates? (Theorem 5.2 and Theorem 5.3.) We also show that a natural but wrong formulation fails (Proposition 5.4).
3. **Approximate agreement.** How does closeness of the data control closeness of knees? (Theorem 7.1 and its corollaries.)

In every case the answer can be read off a single object, the tail histogram, with no sweep. Section 6 adds the combinatorial picture: knees and tails are conjugate partitions, and their common area is the total demand.

### 1.1 Notation and conventions

All numbers are natural numbers $\mathbb{N} = \{0, 1, 2, \dots\}$. A *multiset* $D$ over $\mathbb{N}$ is a finite unordered collection with repetitions. We write $|D|$ for its cardinality counted with multiplicity, $\#_D(v)$ for the multiplicity of $v$ in $D$, $\max D$ for its largest element (with $\max \varnothing = 0$), and $\sum D$ for the sum of its elements. $D + E$ is the multiset union, which adds multiplicities. For a predicate $P$, $D|_P$ is the sub-multiset of elements satisfying $P$. In particular $D|_{>0}$ is the multiset of positive demands of $D$.

---

## 2. Definitions

**Definition 2.1 (Upper-tail counting function).** For a demand multiset $D$ and a threshold $t \in \mathbb{N}$,
$$\mathrm{tail}_D(t) \;=\; \big|\, D|_{> t} \,\big| \;=\; \#\{\, d \in D : d > t \,\}\quad(\text{with multiplicity}).$$

**Definition 2.2 (Knee).** For a gate $g \in \mathbb{N}$,
$$\mathrm{knee}_D(g) \;=\; \min\{\, t \in \mathbb{N} : \mathrm{tail}_D(t) \le g \,\}.$$
The set is non-empty because $\mathrm{tail}_D(\max D) = 0 \le g$ (Lemma 3.1), so the minimum exists.

**Definition 2.3 (Clamp).** For $a, w, x \in \mathbb{N}$,
$$\mathrm{clamp}_{a,w}(x) \;=\; \min\big(\max(x, a),\, a + w\big),$$
the projection of $x$ onto the integer interval $[a, a+w]$.

**Definition 2.4 (Decreasing arrangement).** $\mathrm{sort}^{\downarrow}(D) = (d_0 \ge d_1 \ge \dots \ge d_{n-1})$ is the list of elements of $D$ in non-increasing order, with $n = |D|$. For $g \ge n$ we set $d_g := 0$.

**Running example.** For $D = \{7, 5, 5, 3, 1, 0\}$:

| $t$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| $\mathrm{tail}_D(t)$ | 5 | 4 | 4 | 3 | 3 | 1 | 1 | 0 |

| $g$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| $\mathrm{knee}_D(g)$ | 7 | 5 | 5 | 3 | 1 | 0 | 0 | 0 |

---

## 3. Elementary properties and the Galois connection

**Lemma 3.1 (Basic properties of the tail).**
1. If every $d \in D$ satisfies $d \le t$, then $\mathrm{tail}_D(t) = 0$. In particular $\mathrm{tail}_D(\max D) = 0$.
2. $\mathrm{tail}_D$ is antitone: $s \le t \Rightarrow \mathrm{tail}_D(t) \le \mathrm{tail}_D(s)$.
3. $\mathrm{tail}_D(t) \le |D|$.
4. $\mathrm{tail}_{D+E}(t) = \mathrm{tail}_D(t) + \mathrm{tail}_E(t)$, and $\mathrm{tail}_{\{a\} + D}(t) = \mathrm{tail}_D(t) + [t < a]$.

*Proof sketch.* (1) The filter $D|_{>t}$ is empty. (2) $s \le t$ gives $D|_{>t} \subseteq D|_{>s}$. (3) A sub-multiset is no larger than the whole. (4) Filtering commutes with multiset union, and cardinality is additive. $\square$

**Theorem 3.2 (Galois connection).** For all $D$, $g$, $t$:
$$\mathrm{knee}_D(g) \le t \iff \mathrm{tail}_D(t) \le g.$$

*Proof.* By definition of the minimum, $\mathrm{knee}_D(g) \le t$ holds iff there is some $m \le t$ with $\mathrm{tail}_D(m) \le g$. If such an $m$ exists, antitonicity gives $\mathrm{tail}_D(t) \le \mathrm{tail}_D(m) \le g$. Conversely take $m = t$. $\square$

**Corollary 3.3.** For all $D$, $g$, $t$:
1. $t < \mathrm{knee}_D(g) \iff g < \mathrm{tail}_D(t)$;
2. $\mathrm{tail}_D(\mathrm{knee}_D(g)) \le g$;
3. $\mathrm{knee}_D$ is antitone in $g$;
4. $\mathrm{knee}_D(g) \le \max D$;
5. $\mathrm{knee}_D(g) = 0 \iff \mathrm{tail}_D(0) \le g$, that is, iff $D$ has at most $g$ positive demands.

*Proof sketch.* (1) is the contrapositive of Theorem 3.2. (2) takes $t = \mathrm{knee}_D(g)$. For (3), if $g \le h$ then $\mathrm{tail}_D(\mathrm{knee}_D(g)) \le g \le h$, so $\mathrm{knee}_D(h) \le \mathrm{knee}_D(g)$. (4) uses Lemma 3.1(1). (5) takes $t = 0$. $\square$

**Lemma 3.4 (Pointwise criterion).** For a fixed gate $g$,
$$\mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g) \iff \forall t,\; \big(\mathrm{tail}_D(t) \le g \iff \mathrm{tail}_{D'}(t) \le g\big).$$

*Proof sketch.* By Theorem 3.2 the right-hand side says that the up-sets $\{t : \mathrm{knee}_D(g) \le t\}$ and $\{t : \mathrm{knee}_{D'}(g) \le t\}$ coincide. Two natural numbers with the same up-set are equal. $\square$

This lemma is the engine behind all later results. A knee at a single gate depends on the tail only through the binary classification "$\le g$" versus "$> g$".

### 3.1 The knee is an order statistic

**Theorem 3.5 (Order statistic).** For every $D$ and every $g$,
$$\mathrm{knee}_D(g) = d_g,$$
the $g$-th entry (0-indexed) of $\mathrm{sort}^{\downarrow}(D)$, and $0$ when $g \ge |D|$.

*Proof sketch.* First, $\mathrm{tail}_D(t)$ equals the number of entries of the list $\mathrm{sort}^{\downarrow}(D)$ exceeding $t$, since the list is a permutation of $D$. Next we prove, by induction on a non-increasing list $L = (x, L')$, that
$$L_g \le t \iff \#\{\text{entries of } L \text{ exceeding } t\} \le g$$
(with $L_g := 0$ past the end).

* For $g = 0$: if $x \le t$, every entry of $L'$ is $\le x \le t$, so the count is $0$. If $x > t$, the count is at least $1$.
* For $g = g' + 1$: if $x > t$ the count is $1$ plus the count for $L'$, and the induction hypothesis applies to $L'_{g'}$. If $x \le t$ both sides are true, since $L'_{g'} \le x \le t$ (or $L'_{g'} = 0$).

Hence $d_g$ satisfies the same Galois characterisation as $\mathrm{knee}_D(g)$. Two quantities with identical up-sets are equal. $\square$

For instance, the knee profile $7,5,5,3,1,0,0,\dots$ in the running example is exactly $\mathrm{sort}^{\downarrow}(D)$ padded with zeros.

---

## 4. Agreement at all gates

**Theorem 4.1 (Knee stability ⟺ tail exchangeability).** For all demand multisets $D, D'$,
$$\big(\forall g,\ \mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g)\big) \iff \big(\forall t,\ \mathrm{tail}_D(t) = \mathrm{tail}_{D'}(t)\big).$$

*Proof.* ($\Leftarrow$) Apply Lemma 3.4 at each gate. ($\Rightarrow$) Fix $t$. By Theorem 3.2 with $g = \mathrm{tail}_{D'}(t)$, $\mathrm{knee}_{D'}(g) \le t$. Hence $\mathrm{knee}_D(g) \le t$, and so $\mathrm{tail}_D(t) \le \mathrm{tail}_{D'}(t)$. The reverse inequality follows by symmetry. $\square$

To pass from tails to the data itself we need the discrete derivative of the tail.

**Lemma 4.2 (Histogram as discrete derivative).** For all $k \in \mathbb{N}$,
$$\mathrm{tail}_D(k) = \mathrm{tail}_D(k+1) + \#_D(k+1).$$
Moreover $\mathrm{tail}_{D|_{>0}}(t) = \mathrm{tail}_D(t)$ for all $t$.

*Proof sketch.* Induct on $D$ using Lemma 3.1(4). Adding an element $a$ changes both sides by $[k < a] = [k+1 < a] + [a = k+1]$. For the second claim, $d > t \ge 0$ already implies $d > 0$. $\square$

**Theorem 4.3 (Main theorem, all gates).** For all demand multisets $D, D'$, the following are equivalent:
1. $\mathrm{knee}_D = \mathrm{knee}_{D'}$ (equal knees at every gate);
2. $\mathrm{tail}_D = \mathrm{tail}_{D'}$ (equal upper-tail counting functions);
3. $D|_{>0} = D'|_{>0}$ (equal multisets of positive demands).

*Proof sketch.* (1)⟺(2) is Theorem 4.1. (2)⟹(3): for each $v = k + 1 \ge 1$, Lemma 4.2 gives $\#_D(k+1) = \mathrm{tail}_D(k) - \mathrm{tail}_D(k+1)$, and the same for $D'$. Multiplicities at $0$ are removed by the filter on both sides. (3)⟹(2): $\mathrm{tail}_D = \mathrm{tail}_{D|_{>0}} = \mathrm{tail}_{D'|_{>0}} = \mathrm{tail}_{D'}$ by the second part of Lemma 4.2. $\square$

**Corollary 4.4 (Positive demands).** If every element of $D$ and of $D'$ is positive, then $\mathrm{knee}_D = \mathrm{knee}_{D'} \iff D = D'$.

**Proposition 4.5 (The unguarded statement is false).** It is not true that $\mathrm{knee}_D = \mathrm{knee}_{D'}$ implies $D = D'$ for all $D, D'$.

*Proof.* Take $D = \{0\}$ and $D' = \varnothing$. Both have no positive demands, so their knees agree by Theorem 4.3, yet $D \ne D'$. A less trivial instance is $\{4,2,2\}$ versus $\{0,2,4,0,2\}$. $\square$

**Theorem 4.6 (Finite sweep).** Let $m = \max(|D|, |D'|)$. Then
$$\mathrm{knee}_D = \mathrm{knee}_{D'} \iff \forall g < m,\ \mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g).$$

*Proof sketch.* For $g \ge m$ we have $\mathrm{tail}_D(0) \le |D| \le g$, so $\mathrm{knee}_D(g) = 0$ by Corollary 3.3(5). Likewise $\mathrm{knee}_{D'}(g) = 0$. $\square$

---

## 5. Agreement on a window of gates

We now localise Theorem 4.1 to a *gate window* $W = \{g : a \le g < a + w\}$ of width $w$.

**Lemma 5.1.** For fixed $t$ and $x = \mathrm{tail}_D(t)$, $y = \mathrm{tail}_{D'}(t)$:
$$\big(\forall g \in W,\ x \le g \iff y \le g\big) \iff \mathrm{clamp}_{a,w}(x) = \mathrm{clamp}_{a,w}(y).$$

*Proof sketch.* Suppose $\mathrm{clamp}(x) < \mathrm{clamp}(y)$. Then $g := \mathrm{clamp}(x)$ lies in $W$, because $a \le g$ and $g < \mathrm{clamp}(y) \le a + w$. We also have $x \le g$ and $y > g$, which contradicts the left-hand side. The other order is symmetric. Conversely, if the clamps agree then for each $g \in W$ the comparison $x \le g$ is decided by $\mathrm{clamp}(x)$, since $a \le g < a + w$. So it agrees with $y \le g$. $\square$

**Theorem 5.2 (Main theorem, gate window).** For all $D, D'$ and $a, w \in \mathbb{N}$,
$$\big(\forall g,\ a \le g < a + w \Rightarrow \mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g)\big) \iff \big(\forall t,\ \mathrm{clamp}_{a,w}(\mathrm{tail}_D(t)) = \mathrm{clamp}_{a,w}(\mathrm{tail}_{D'}(t))\big).$$

*Proof.* Apply Lemma 3.4 at each $g \in W$. Exchange the quantifiers over $g$ and $t$, then apply Lemma 5.1 at each $t$. $\square$

In the language of distribution functions, the knee at gate $g$ is the rank-$g$ value of the generalised inverse of $\mathrm{tail}_D$. Agreement of the inverse on the rank interval $[a, a+w)$ is agreement of the function itself after projection onto the *count band* $[a, a+w]$. This band is one unit wider than the gate window.

**Theorem 5.3 (Band formulation).** Assume $w > 0$. The window condition of Theorem 5.2 is equivalent to the following: for every threshold $t$,
1. $\mathrm{tail}_D(t) \le a \iff \mathrm{tail}_{D'}(t) \le a$ (same "at or below band" classification);
2. $a + w \le \mathrm{tail}_D(t) \iff a + w \le \mathrm{tail}_{D'}(t)$ (same "at or above band" classification);
3. if $a < \mathrm{tail}_D(t) < a + w$ then $\mathrm{tail}_D(t) = \mathrm{tail}_{D'}(t)$ (exact agreement in the open band).

*Proof sketch.* Fix $t$ and put $x = \mathrm{tail}_D(t)$, $y = \mathrm{tail}_{D'}(t)$. With $w > 0$ the three cases $x \le a$, $a < x < a + w$, $x \ge a + w$ give $\mathrm{clamp}(x) = a$, $\mathrm{clamp}(x) = x$ and $\mathrm{clamp}(x) = a + w$ respectively. These values are pairwise distinct when $w > 0$, so equality of clamps is exactly conditions 1–3. Each direction is a short case analysis in linear arithmetic. $\square$

**Example 5.4.** Let $D = \{9, 6, 4, 2\}$ and $D' = \{8, 6, 4, 1, 1\}$, with knee profiles $(9,6,4,2,0,\dots)$ and $(8,6,4,1,1,0,\dots)$. They agree exactly on the window $\{1, 2\}$, so $a = 1$ and $w = 2$. Their tails at $t = 0, \dots, 9$ are
$$\mathrm{tail}_D = (4,4,3,3,2,2,1,1,1,0), \qquad \mathrm{tail}_{D'} = (5,3,3,3,2,2,1,1,0,0).$$
They differ at $t = 0$, $1$ and $8$, but clamping to $[1, 3]$ gives $(3,3,3,3,2,2,1,1,1,1)$ for both.

**Proposition 5.5 (The naive closed-band formulation is false).** The following statement fails in general: for all $D, D'$ and all $a, b$,
$$\big(\forall g \in [a,b],\ \mathrm{knee}_D(g) = \mathrm{knee}_{D'}(g)\big) \iff \big(\forall t,\ a \le \mathrm{tail}_D(t) \le b \Rightarrow \mathrm{tail}_D(t) = \mathrm{tail}_{D'}(t)\big).$$

*Proof.* Take $D = \{3\}$, $D' = \{2\}$ and $a = b = 1$. Both knees at gate $1$ equal $0$, since each multiset has only one positive demand (Corollary 3.3(5)). So the left side holds. At $t = 2$, however, $\mathrm{tail}_D(2) = 1 \in [1,1]$ while $\mathrm{tail}_{D'}(2) = 0$. So the right side fails. $\square$

The counterexample shows where the clamp is needed. On the *boundary* of the band, here the value $a = 1$, the tails need only fall on the same side, not coincide.

---

## 6. Conjugate-partition duality and the area identity

Draw $D$ as a Ferrers diagram whose rows, longest first, have lengths $d_0 \ge d_1 \ge \dots$. By Theorem 3.5 the row lengths are the knees. The column heights are the tails.

**Theorem 6.1 (Conjugate duality).** For all $D$, $t$, $g$:
$$\mathrm{tail}_D(t) = \#\{\, g < |D| : t < \mathrm{knee}_D(g) \,\}, \qquad \mathrm{knee}_D(g) = \#\{\, t < \max D : g < \mathrm{tail}_D(t) \,\}.$$

*Proof sketch.* By Corollary 3.3(1), $t < \mathrm{knee}_D(g) \iff g < \mathrm{tail}_D(t)$. So the first set is $\{g < |D| : g < \mathrm{tail}_D(t)\} = \{0, \dots, \mathrm{tail}_D(t) - 1\}$, using $\mathrm{tail}_D(t) \le |D|$. Likewise the second set is $\{0, \dots, \mathrm{knee}_D(g) - 1\}$, using $\mathrm{knee}_D(g) \le \max D$. $\square$

Thus $\mathrm{tail}_D$ and $\mathrm{knee}_D$, viewed as partitions, are conjugate to each other.

**Theorem 6.2 (Area identity).**
$$\sum_{g=0}^{|D|-1} \mathrm{knee}_D(g) \;=\; \sum_{d \in D} d.$$

*Proof sketch.* By Theorem 3.5 the left side is $\sum_{g < |D|} d_g$, the sum of the list $\mathrm{sort}^{\downarrow}(D)$, which is $\sum D$. (Counting boxes by columns gives the dual identity $\sum_{t < \max D} \mathrm{tail}_D(t) = \sum D$.) $\square$

In the running example, $7 + 5 + 5 + 3 + 1 + 0 = 21 = 5 + 4 + 4 + 3 + 3 + 1 + 1$.

---

## 7. Quantitative stability

Exact equality is rarely available in practice. The Galois connection also transfers *inequalities* between the two sides with no loss.

**Theorem 7.1 (Gate-shift ⟺ uniform tail bound).** For all $D, D'$ and $k \in \mathbb{N}$:
$$\big(\forall g,\ \mathrm{knee}_{D'}(g + k) \le \mathrm{knee}_D(g)\big) \iff \big(\forall t,\ \mathrm{tail}_{D'}(t) \le \mathrm{tail}_D(t) + k\big).$$

*Proof.* ($\Rightarrow$) Fix $t$ and set $g = \mathrm{tail}_D(t)$. By Theorem 3.2, $\mathrm{knee}_D(g) \le t$, so $\mathrm{knee}_{D'}(g + k) \le t$. By Theorem 3.2 again, $\mathrm{tail}_{D'}(t) \le g + k$. ($\Leftarrow$) Fix $g$. By Theorem 3.2 it suffices to show $\mathrm{tail}_{D'}(\mathrm{knee}_D(g)) \le g + k$. The hypothesis gives $\mathrm{tail}_{D'}(\mathrm{knee}_D(g)) \le \mathrm{tail}_D(\mathrm{knee}_D(g)) + k$, and Corollary 3.3(2) gives $\mathrm{tail}_D(\mathrm{knee}_D(g)) \le g$. $\square$

**Corollary 7.2 (Lipschitz sandwich).** If $|\mathrm{tail}_D(t) - \mathrm{tail}_{D'}(t)| \le k$ for all $t$, then for every gate $g$,
$$\mathrm{knee}_{D'}(g + k) \le \mathrm{knee}_D(g) \quad\text{and}\quad \mathrm{knee}_D(g + k) \le \mathrm{knee}_{D'}(g).$$

**Corollary 7.3 (Contamination).** For all $D, E$ and $g$,
$$\mathrm{knee}_D(g) \le \mathrm{knee}_{D+E}(g) \quad\text{and}\quad \mathrm{knee}_{D+E}(g + |E|) \le \mathrm{knee}_D(g).$$

*Proof sketch.* By Lemma 3.1(4) and (3), $\mathrm{tail}_D \le \mathrm{tail}_{D+E} = \mathrm{tail}_D + \mathrm{tail}_E \le \mathrm{tail}_D + |E|$. Apply Theorem 7.1 with $k = 0$ (with the roles of $D$ and $D+E$ swapped) and with $k = |E|$. $\square$

**Corollary 7.4 (Merge bounds).** For all $D, E$ and gates $g, h$:
$$\max\big(\mathrm{knee}_D(g), \mathrm{knee}_E(g)\big) \le \mathrm{knee}_{D+E}(g), \qquad \mathrm{knee}_{D+E}(g + h) \le \max\big(\mathrm{knee}_D(g), \mathrm{knee}_E(h)\big).$$

*Proof sketch.* The first inequality is Corollary 7.3 applied to $D$ and to $E$. For the second, put $m = \max(\mathrm{knee}_D(g), \mathrm{knee}_E(h))$. By antitonicity and Corollary 3.3(2), $\mathrm{tail}_{D+E}(m) = \mathrm{tail}_D(m) + \mathrm{tail}_E(m) \le g + h$. Then apply Theorem 3.2. $\square$

---

## 8. Algorithms

The results above make the tail histogram a sufficient statistic for every knee question. We record the resulting procedures. Throughout, $n = |D|$ and $V$ is the number of distinct values.

**Algorithm A (tail histogram).** One pass builds the histogram $h(v) = \#_D(v)$. Sorting the distinct values in decreasing order and accumulating suffix sums gives the step function $\mathrm{tail}_D$, stored as $V$ breakpoints. Cost: $O(n + V \log V)$ time and $O(V)$ space. Histograms of shards combine by addition (Lemma 3.1(4)).

**Algorithm B (knee from histogram).** By Theorem 3.2, $\mathrm{knee}_D(g)$ is the least breakpoint $t$ with $\mathrm{tail}_D(t) \le g$. Binary search over the breakpoints costs $O(\log V)$ per gate. Equivalently, by Theorem 3.5, it is the $g$-th largest element.

**Algorithm C (all-gate equality test).** By Theorem 4.3, compare the histograms restricted to positive values. Cost $O(V + V')$ after Algorithm A. No gate sweep is needed. If one insists on comparing knees directly, Theorem 4.6 bounds the sweep at $\max(|D|, |D'|)$ gates.

**Algorithm D (window equality test).** By Theorem 5.2, merge the breakpoint sets of $\mathrm{tail}_D$ and $\mathrm{tail}_{D'}$. Between consecutive breakpoints both tails are constant. Compare $\mathrm{clamp}_{a,w}$ of the two values on each piece. Cost $O(V + V')$ for any window, so one histogram per collection serves all windows chosen later.

**Algorithm E (gate-shift distance).** Compute $k^\ast = \max_t |\mathrm{tail}_D(t) - \mathrm{tail}_{D'}(t)|$ over the merged breakpoints, in $O(V + V')$. By Corollary 7.2, each knee profile dominates the other after a shift of $k^\ast$ gates. By the forward direction of Theorem 7.1, no smaller *mutual* shift is possible. So $k^\ast$ is the exact minimal mutual gate shift.

---

## 9. Applications and discussion

**From sweeps to histograms.** A typical comparison computes knees of two collections at a grid of gates and declares the collections "knee-stable" if the knees match. Theorems 4.3 and 5.2 show that the outcome of any such sweep, at all gates or on any window, is determined by the tail histograms alone. A sweep over $G$ gates for each of $C$ cells costs $G \cdot C$ knee computations, and each one requires a pass or a sort. The histogram approach costs one pass per collection and $O(V)$ per comparison afterwards. This matters most when collections are large, or when collections are numerous but small, as with many low-resource sub-domains.

**Robustness.** Theorem 7.1 is sharp: it is an equivalence, not merely an implication. So the supremum gap between tails is *the* right measure of knee discrepancy. Corollary 7.3 says that injecting $|E|$ spurious items can move knees by at most $|E|$ gates, and only upward. This gives a deterministic certificate for contaminated or partially deduplicated data.

**Zero demands.** Proposition 4.5 is a reminder that knees are blind to zero demands. Any claim that knee stability identifies a collection must be stated for the positive part. Such a claim is exact only when all demands are positive (Corollary 4.4).

**Boundary effects.** Proposition 5.5 shows that the gate window and the count band are offset by one, $[a, a+w)$ versus $[a, a+w]$, and that the boundary of the band carries only one bit of information per threshold (which side). Informal arguments that miss this offset give statements that are false.

**Relation to classical notions.** Theorem 3.2 is the discrete form of the duality between a survival function and its quantile function. Theorem 6.1 is the classical conjugation of integer partitions, and Theorem 6.2 is the statement that a partition and its conjugate have the same size. The contribution here is the exact window theorem, with its band offset and boundary behaviour, and the sharp shift–bound equivalence, both stated in a form that applies directly to comparing empirical collections.

---

## 10. Future work

1. **Gate-shift metric as a Kolmogorov distance.** Algorithm E shows, as a direct consequence of Theorem 7.1, that the least $k$ such that each knee profile dominates the other after a shift of $k$ gates equals $\sup_t |\mathrm{tail}_D(t) - \mathrm{tail}_{D'}(t)|$. The next step is to develop this quantity as a metric in its own right: the $\ell^\infty$ distance between conjugate partitions, that is, an unnormalised Lévy–Kolmogorov distance on demand distributions, with its triangle inequality, its behaviour under normalisation by $|D|$, and its interaction with pooling.
2. **Weighted and fractional gates.** For demands with real weights, the knee at a real gate $\gamma$ should be the generalised inverse of the weighted tail, and window agreement should be equivalent to agreement of clamped weighted tails. Only the Galois connection was used above, and it holds for any right-continuous antitone tail.
3. **Sampling stability.** If a subsample of size $n$ has empirical tail within $\varepsilon n$ of the scaled population tail (a Dvoretzky–Kiefer–Wolfowitz-type event), every sampled knee should lie between the population knees at gates $g \pm \varepsilon n$. The deterministic sandwich of Corollary 7.2 converts any uniform tail bound into a knee bound with no extra loss.
4. **Pooling via conjugate addition.** Tails add under pooling. So the knee profile of $D + E$ is the conjugate of the sum of the conjugates (the union of the partitions), and all-gate agreement is preserved when pooling with a common collection $E$. Window agreement, however, is *not* preserved in general. The empty multiset and $\{1\}$ have equal knees ($0$) at gate $1$, but after pooling each with $E = \{1\}$ the knees at gate $1$ are $0$ and $1$. The open problem is to find how the window must move or shrink under pooling. A complete answer would let knee profiles on chosen windows be assembled from histograms of shards.

---

## 11. Conclusion

The knee of a demand multiset at a gate is an order statistic, and it is linked to the upper-tail counting function by a Galois connection. All the results here follow from that one fact. Equal knees at all gates is the same as equal tails, which is the same as equal positive data. Equal knees on a gate window is the same as equal tails clamped to a count band one unit wider. Closeness of tails in sup norm is the same as closeness of knees up to a gate shift. Each statement is an exact equivalence, and each comes with a counterexample showing where a looser version fails. As a result, any question about knees can be answered from a single tail histogram per collection, with no sweep.
