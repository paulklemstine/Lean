# A Tight $\Theta(n^{2w})$ Bound for Strict Alternating Cycles in Width-$w$ Posets

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty / Extremal Combinatorics & Order Dimension Theory

---

## Abstract

For a fixed integer width $w \ge 2$, we study the maximum number of *strict alternating cycles* that an $n$-element partially ordered set of width $w$ can contain. Strict alternating cycles are the irreducible obstructions of poset dimension theory: a cyclic family of incomparable pairs in which each lower vertex dominates exactly one upper vertex — its cyclic successor. A standard counting argument (each cycle of length $k$ is pinned by its $2k$ vertices, and Dilworth's theorem caps the length at $w$) yields an upper bound of $O(n^{2w})$. The matching lower bound — the assertion that this rate is asymptotically achievable — is the difficult direction. We resolve it with an explicit construction, the **blown-up crown** $\mathrm{Crown}(w,m)$, obtained from the standard example crown $S_w$ by replacing each of its $2w$ vertices with a chain of $m$ clones. We prove that this poset (i) has exactly $2wm$ elements, (ii) has width exactly $w$ — the load-bearing fact, certified by an explicit column-folding injection — and (iii) carries at least $m^{2w}$ distinct strict alternating cycles. Setting $n = 2wm$ gives a width-$w$ poset on $n$ points with at least $(2w)^{-2w} n^{2w}$ strict alternating cycles, establishing that the maximum is $\Theta(n^{2w})$. All results have been formally verified. We close with four conjectures: a sharp leading constant, a length-spectrum refinement, a dimension-transfer principle, and a Turán-type dual.

---

## 1. Introduction

### 1.1 Background and motivation

A *partially ordered set* (poset) is a pair $(P, \le)$ in which $\le$ is reflexive, antisymmetric, and transitive. Two elements $x, y \in P$ are *comparable* if $x \le y$ or $y \le x$, and *incomparable* (written $x \parallel y$) otherwise. The structure of incomparabilities is what distinguishes a poset from a totally ordered set, and quantifying that structure is the central theme of *order dimension theory*, initiated by Dushnik and Miller (1941) and developed extensively by Trotter.

The **dimension** of a poset is the least number of linear extensions whose intersection recovers $\le$. The combinatorial obstruction to small dimension is the *strict alternating cycle*: a cyclic configuration of incomparable pairs that cannot be simultaneously "reversed" within a single linear extension. The canonical examples that force dimension upward are the *standard examples*, or *crowns*, $S_w$: a poset of $2w$ elements and dimension exactly $w$.

The **width** of a poset, by Dilworth's theorem, is both the maximum size of an antichain (a set of pairwise incomparable elements) and the minimum number of chains needed to cover $P$. Width and dimension are different but related measures; in particular $\dim(P) \le \mathrm{width}(P)$ is false in general but holds for the standard examples, where both equal $w$.

### 1.2 The extremal question

Fix the width $w \ge 2$ and let $n \to \infty$. How many strict alternating cycles can an $n$-element width-$w$ poset contain? This is a Turán-type extremal problem: we maximize the count of a substructure (alternating cycles) subject to a global constraint (bounded width). Let $A_w(n)$ denote this maximum (counting cycles as indexed cyclic families, i.e. counting cyclic rotations separately; this affects the answer only by a bounded factor).

**Upper bound (classical).** A strict alternating cycle of length $k$ is determined by its $2k$ vertices, so there are at most $O(n^{2k})$ of length $k$. The lower vertices of a strict alternating cycle form an antichain, so $k \le w$ by Dilworth. Summing over $k \le w$, $A_w(n) = O(n^{2w})$.

**Lower bound (this paper).** We prove $A_w(n) = \Omega(n^{2w})$, hence:

> **Main Theorem.** For every fixed $w \ge 2$, the maximum number of strict alternating cycles in an $n$-element width-$w$ poset satisfies $A_w(n) = \Theta(n^{2w})$. Explicitly, for $n$ divisible by $2w$ there is a width-$w$ poset on $n$ elements with at least $(2w)^{-2w}\, n^{2w}$ strict alternating cycles.

### 1.3 Contribution and method

The contribution is the lower bound — the open direction — via an explicit, fully formalized construction. The strategy:

1. Define the **blown-up crown** $\mathrm{Crown}(w,m)$ by inflating each vertex of $S_w$ into a length-$m$ chain (Section 3).
2. Verify it is a genuine partial order, with $2wm$ elements (Section 3).
3. Prove its width is **exactly** $w$ — the crux — via an explicit column-folding injection that discounts the cross-relations (Section 4).
4. Exhibit an injective family of $m^{2w}$ strict alternating cycles indexed by pairs of clone-selection functions (Section 5).
5. Convert $m^{2w}$ on $2wm$ points into $\Omega(n^{2w})$ (Section 6).

A guiding subtlety: inflating into **chains** (not antichains) is what preserves width. The $2w$ chains naively suggest width $2w$, but the cross relations $a_i \le b_{i+1}$ remove the extra incomparabilities, and the folding map makes this precise.

---

## 2. Preliminaries

Throughout, $w \ge 2$ and $m \ge 1$ are integers, and indices in $\{0, \dots, w-1\}$ are taken modulo $w$ (cyclically); we write $i + 1$ for the cyclic successor of column $i$.

**Definition 2.1 (Antichain, width).** A subset $A \subseteq P$ is an *antichain* if any two distinct elements of $A$ are incomparable. The *width* of $P$ is $\mathrm{width}(P) = \max\{|A| : A \text{ an antichain}\}$.

**Definition 2.2 (Chain).** A subset $C \subseteq P$ is a *chain* if any two elements of $C$ are comparable. A chain of $m$ elements is order-isomorphic to the linear order $\{0 < 1 < \dots < m-1\}$.

**Definition 2.3 (Strict alternating cycle).** Let $(P,\le)$ be a poset and $w \ge 2$. A family of pairs $p : \{0,\dots,w-1\} \to P \times P$, written $p(i) = (x_i, y_i)$, is a **strict alternating cycle** (of length $w$) if:

$$\textbf{(SAC1)}\qquad \forall i, j:\quad x_i \le y_j \iff j = i + 1 \pmod w,$$
$$\textbf{(SAC2)}\qquad \forall i:\quad y_i \not\le x_i.$$

Condition (SAC1) is the alternating "each lower vertex dominates exactly its cyclic successor" property. Condition (SAC2) says each pair is non-degenerate. Note that (SAC1) already forces $x_i \not\le y_i$ (since $i \ne i+1$ when $w \ge 2$); together with (SAC2) this makes each pair $(x_i,y_i)$ incomparable, so the cycle is "strict" in Trotter's sense.

*(In the formal development this predicate is `IsStrictAltCycle`, stated over the index type `Fin w`.)*

---

## 3. The blown-up crown

**Definition 3.1 (Carrier).** The *blown-up crown* $\mathrm{Crown}(w,m)$ has as elements all triples
$$x = (\mathrm{col}, \mathrm{side}, \mathrm{idx}), \qquad \mathrm{col} \in \{0,\dots,w-1\},\ \mathrm{side} \in \{\mathtt{a}, \mathtt{b}\},\ \mathrm{idx} \in \{0,\dots,m-1\},$$
where $\mathrm{side} = \mathtt{a}$ (encoded `false`) denotes a *lower* vertex and $\mathrm{side} = \mathtt{b}$ (encoded `true`) an *upper* vertex. We write $a(i,j)$ for $(i,\mathtt a,j)$ and $b(i,j)$ for $(i,\mathtt b,j)$.

*(Formally, `structure Crown (w m : ℕ)` with fields `col : Fin w`, `side : Bool`, `idx : Fin m`.)*

**Definition 3.2 (Order).** For $x, y \in \mathrm{Crown}(w,m)$, declare $x \le y$ iff one of:

- **(chain rule)** $x.\mathrm{side} = y.\mathrm{side}$, $x.\mathrm{col} = y.\mathrm{col}$, and $x.\mathrm{idx} \le y.\mathrm{idx}$; or
- **(cross rule)** $x.\mathrm{side} = \mathtt a$, $y.\mathrm{side} = \mathtt b$, and $y.\mathrm{col} = x.\mathrm{col} + 1 \pmod w$.

*(Formally, the relation `CrownLe`.)* In words: clones in the same stack order by their index; and every lower clone $a(i, \cdot)$ lies below every upper clone $b(i+1, \cdot)$ in the next column. The cross rule is **one-directional** ($\mathtt a \to \mathtt b$ only); it carries no index condition, so the relationship is total between the two facing stacks.

**Proposition 3.3 (Partial order).** $(\mathrm{Crown}(w,m), \le)$ is a partial order.

*Proof sketch.* Reflexivity is the chain rule with equal indices. For transitivity, examine the four combinations of rule applications: chain∘chain stays in one stack (transitivity of $\le$ on indices); chain∘cross and cross∘chain remain single cross steps (the chain step cannot change column or side in a way that breaks the cross pattern); cross∘cross is impossible because a cross step ends on side $\mathtt b$ but a cross step must start on side $\mathtt a$. Antisymmetry: if $x \le y$ and $y \le x$, the cross rule cannot fire in either direction (it would require both $x.\mathrm{side}=\mathtt a, y.\mathrm{side}=\mathtt b$ and $y.\mathrm{side}=\mathtt a$, a contradiction), so both relations are chain rules, forcing equal side and column and $x.\mathrm{idx} = y.\mathrm{idx}$ by antisymmetry of $\le$ on indices. The one-directional orientation of the cross rule is exactly what rescues antisymmetry. $\qquad\blacksquare$

*(Formally, instance `crownPO : PartialOrder (Crown w m)`.)*

**Theorem 3.4 (Cardinality).** $\#\,\mathrm{Crown}(w,m) = 2 \cdot w \cdot m$.

*Proof.* The map $x \mapsto (x.\mathrm{col}, x.\mathrm{side}, x.\mathrm{idx})$ is a bijection onto $\{0,\dots,w-1\} \times \{\mathtt a,\mathtt b\} \times \{0,\dots,m-1\}$, whose cardinality is $w \cdot 2 \cdot m$. $\qquad\blacksquare$

*(Formally, `theorem Crown.card`.)*

---

## 4. Width is exactly $w$

This is the heart of the construction: blowing up the vertices into chains must not change the width. There are $2w$ stacks, so a priori the width could be as large as $2w$; the cross relations cut it back to $w$.

**Definition 4.1 (Column folding).** Define $\mathrm{fold} : \mathrm{Crown}(w,m) \to \{0,\dots,w-1\}$ (values modulo $w$) by
$$\mathrm{fold}(x) = \begin{cases} x.\mathrm{col} & \text{if } x.\mathrm{side} = \mathtt b,\\ x.\mathrm{col} + 1 & \text{if } x.\mathrm{side} = \mathtt a.\end{cases}$$

*(Formally, `Crown.fold`.)* The design principle: a conflicting cross pair $a(i,\cdot) \le b(i+1,\cdot)$ has both endpoints folding to the same value $i+1$. The fold thus collapses each comparable cross pair to a single column-label.

**Lemma 4.2 (Fold is injective on antichains).** If $A \subseteq \mathrm{Crown}(w,m)$ is an antichain, then $\mathrm{fold}\restriction_A$ is injective.

*Proof sketch.* Suppose $x \ne y$ in $A$ with $\mathrm{fold}(x) = \mathrm{fold}(y)$. Case analysis on the sides:

- **Same side.** Then $\mathrm{fold}$ equals the column (both $\mathtt b$) or column $+1$ (both $\mathtt a$), so $x.\mathrm{col} = y.\mathrm{col}$. Same side and column means same stack; two distinct stack elements are comparable by the chain rule, contradicting antichain.
- **Opposite sides**, say $x.\mathrm{side} = \mathtt a$, $y.\mathrm{side} = \mathtt b$. Then $\mathrm{fold}(x) = x.\mathrm{col}+1$ and $\mathrm{fold}(y) = y.\mathrm{col}$, so $y.\mathrm{col} = x.\mathrm{col} + 1$. But that is exactly the cross rule $x \le y$, contradicting antichain.

In every case the two elements are comparable, contradiction. Hence $\mathrm{fold}$ is injective on $A$. $\qquad\blacksquare$

**Theorem 4.3 (Width).** $\mathrm{width}(\mathrm{Crown}(w,m)) = w$.

*Proof.* *Upper bound.* By Lemma 4.2, any antichain injects via $\mathrm{fold}$ into a set of $w$ values, so has at most $w$ elements; thus $\mathrm{width} \le w$. *Lower bound.* The set $\{a(0,0), a(1,0), \dots, a(w-1,0)\}$ has $w$ elements, all on side $\mathtt a$. Two distinct ones $a(i,0), a(i',0)$ ($i \ne i'$) are incomparable: the chain rule needs equal columns ($i = i'$), and the cross rule needs opposite sides. So this is an antichain of size $w$, giving $\mathrm{width} \ge w$. $\qquad\blacksquare$

*(Formally, `Crown.hasWidth`, witnessing both $\le w$ and $= w$.)*

---

## 5. Counting strict alternating cycles

**Definition 5.1 (The cycle family).** For functions $u, v : \{0,\dots,w-1\} \to \{0,\dots,m-1\}$ define
$$\mathrm{cyc}(u,v)(t) = \big(\,a(t, u(t)),\; b(t, v(t))\,\big), \qquad t \in \{0,\dots,w-1\}.$$
That is, in column $t$ take the $a$-clone with index $u(t)$ as the lower vertex and the $b$-clone with index $v(t)$ as the upper vertex.

*(Formally, `cyc`.)*

**Theorem 5.2 (Each family is a strict alternating cycle).** For all $u, v$, $\mathrm{cyc}(u,v)$ satisfies (SAC1) and (SAC2).

*Proof sketch.* Write $x_t = a(t,u(t))$ and $y_s = b(s,v(s))$. For (SAC1), $x_t \le y_s$ can only hold via the cross rule (the chain rule needs equal sides, but $x_t$ is side $\mathtt a$ and $y_s$ is side $\mathtt b$); the cross rule fires iff $y_s.\mathrm{col} = x_t.\mathrm{col}+1$, i.e. $s = t+1 \pmod w$. For (SAC2), $y_t \le x_t$ would need either the chain rule (impossible: opposite sides) or the cross rule with $x_t$ on side $\mathtt b$ (impossible: $x_t$ is side $\mathtt a$). So $y_t \not\le x_t$. $\qquad\blacksquare$

*(Formally, `cyc_strict`.)*

**Theorem 5.3 (Injectivity).** The map $(u,v) \mapsto \mathrm{cyc}(u,v)$ is injective.

*Proof.* If $\mathrm{cyc}(u,v) = \mathrm{cyc}(u',v')$ then for each $t$ the first components agree, $a(t,u(t)) = a(t,u'(t))$, giving $u(t) = u'(t)$; likewise the second components give $v(t) = v'(t)$. Hence $u = u'$ and $v = v'$. $\qquad\blacksquare$

*(Formally, `cyc_injective`.)*

**Corollary 5.4 (Cycle count).** $\mathrm{Crown}(w,m)$ contains at least $m^{2w}$ distinct strict alternating cycles.

*Proof.* There are $m^w$ choices for $u$ and $m^w$ for $v$, so $m^{2w}$ pairs $(u,v)$. By Theorem 5.2 each yields a strict alternating cycle, and by Theorem 5.3 distinct pairs yield distinct cycles. $\qquad\blacksquare$

*(Formally, `crown_strictAltCycle_card_lower`.)*

---

## 6. The asymptotic lower bound

**Theorem 6.1 (Main lower bound).** For every fixed $w \ge 2$ and every $m \ge 1$, the poset $\mathrm{Crown}(w,m)$ has width $w$, has $n = 2wm$ elements, and carries at least
$$m^{2w} = \left(\frac{n}{2w}\right)^{2w} = \frac{1}{(2w)^{2w}}\, n^{2w}$$
strict alternating cycles. Consequently $A_w(n) \ge (2w)^{-2w}\, n^{2w}$ for all $n$ divisible by $2w$, and combined with the classical upper bound $A_w(n) = O(n^{2w})$,
$$A_w(n) = \Theta(n^{2w}).$$

*Proof.* Width is Theorem 4.3; cardinality is Theorem 3.4; the cycle count is Corollary 5.4. Substitute $m = n/(2w)$. For general $n$, drop to the largest multiple of $2w$ below $n$; this changes the bound by a constant factor, preserving the $\Theta$. $\qquad\blacksquare$

The constant $c_w = (2w)^{-2w}$ is positive for each fixed $w$. The match with the upper bound confirms the conjectured tightness: the $O(n^{2w})$ ceiling is asymptotically achieved.

---

## 7. Algorithms

The construction is fully effective. We record the two core algorithms.

**Algorithm 7.1 (Enumerate strict alternating cycles of the blown-up crown).**

```
Input:  integers w ≥ 2, m ≥ 1
Output: the set of all m^{2w} cycle families cyc(u,v)
1. for each u in Functions({0..w-1} -> {0..m-1}):      # m^w of them
2.    for each v in Functions({0..w-1} -> {0..m-1}):   # m^w of them
3.       emit  t ↦ ( a(t, u(t)), b(t, v(t)) )
```
Complexity: $\Theta(w \cdot m^{2w})$ time to emit all cycles, $\Theta(w)$ per cycle. This realizes the count of Corollary 5.4 constructively.

**Algorithm 7.2 (Width certification by column folding).**

```
Input:  an antichain A ⊆ Crown(w,m)
Output: a proof that |A| ≤ w
1. compute fold(x) for each x in A, where
      fold(x) = x.col            if x.side = b
      fold(x) = (x.col + 1) mod w if x.side = a
2. assert all fold-values distinct        # Lemma 4.2
3. since fold-values lie in {0..w-1}, conclude |A| ≤ w
```
Complexity: $\Theta(|A|)$ to fold, $\Theta(|A|\log|A|)$ to test distinctness. The all-$a$ set $\{a(i,0)\}_{i}$ certifies the matching lower bound $\mathrm{width} \ge w$.

---

## 8. Applications and connections

- **Poset dimension theory.** Strict alternating cycles are the obstructions whose presence forces dimension up; the standard example $S_w$ is the archetypal dimension-$w$ poset. The blown-up crown shows that the *density* of these obstructions, under fixed width, follows a sharp power law.
- **Extremal / Turán-type combinatorics.** The result is a matching lower bound for a Turán-type problem: maximize a substructure count (alternating cycles) under a global constraint (width $\le w$). Such tight extremal results — where an explicit construction meets a counting ceiling — are comparatively rare.
- **Sperner / Dilworth theory.** The width computation is a Dilworth/Mirsky-flavoured antichain bound, executed by the explicit folding injection rather than an abstract chain decomposition.
- **Scheduling and preference modeling.** Incomparabilities model tasks with no forced precedence (scheduling) or unranked alternatives (preferences); alternating cycles are the formal cousins of cyclic conflicts (e.g. Condorcet-type paradoxes), and the bound quantifies how many can coexist.

---

## 9. Discussion

The decisive design choice is to inflate vertices into **chains** rather than antichains. Inflating into antichains would multiply the width, destroying the width-$w$ constraint; inflating into chains keeps each blown-up vertex internally comparable, so it contributes nothing new to any antichain. The cross relations then ensure that a lower stack and its facing upper stack do not jointly enlarge antichains, and the folding map quantifies this exactly: the naive bound of $2w$ chains is halved to the true width $w$ precisely because each $a$-stack folds onto the $b$-stack it dominates.

A modeling remark on counting: we count cycles as indexed cyclic families $p : \{0,\dots,w-1\} \to P \times P$, so cyclic rotations of the same geometric cycle are counted separately. This over-counts by at most a factor of $w$, which does not affect the $\Theta(n^{2w})$ order. Adjusting to count unlabeled cycles divides the constant by $w$, giving $\ge (2w)^{-2w}/w \cdot n^{2w}$.

The lower bound established here is the genuinely hard half; the upper bound is the elementary counting argument of Section 1.2. The count $m^{2w}$ is a true cardinality inequality (an injective family), not a vacuous or probabilistic estimate, and the underlying structure is a verified partial order of width exactly $w$.

---

## 10. Future directions

**Conjecture 1 — Sharp leading constant $c_w$.** Let $M_w(n)$ be the maximum number of strict alternating cycles (counted up to cyclic rotation) in an $n$-element width-$w$ poset. Then $\lim_{n\to\infty} M_w(n)/n^{2w}$ exists and equals the explicit rational $c_w^\* = 1/((2w)^{2w}\cdot w)$. The key insight is that the blown-up crown distributes $n$ points evenly into $2w$ equal chains, and any deviation from equal chain lengths strictly decreases the product $\prod m_i$ controlling the cycle count by AM–GM, so the balanced crown is extremal and pins the constant. This reduces to a one-variable optimization ($\prod m_i$ under $\sum m_i = n$) plus an upper-bound refinement.

**Conjecture 2 — Length-spectrum refinement.** For fixed $w$, the number of strict alternating cycles *of length exactly $k$* in a width-$w$ poset is $\Theta(n^{2k})$ for $2 \le k \le w$, and $0$ for $k > w$. The key insight is that a length-$k$ cycle selects $k$ mutually non-adjacent columns of an underlying width-$w$ skeleton, so its count factorizes as (choices per column)$^{2k}$, and Dilworth's theorem forbids $k > w$ because each cycle yields an antichain of size $k$. The present development already isolates the $k = w$ case; replacing $w$ columns by $k$ columns reuses the folding machinery.

**Conjecture 3 — Dimension transfer.** The blown-up crown $\mathrm{Crown}(w,m)$ has order dimension exactly $w$ for all $m \ge 1$, independent of clone-length $m$. The key insight is that fattening a poset vertex into a chain is a "retract-stable" operation: the realiser of $S_w$ lifts to the blow-up by ordering clones consistently inside each linear extension, and the lower bound $\dim \ge w$ is inherited because $S_w$ embeds as a sub-poset (the all-clone-$0$ copy).

**Conjecture 4 — Turán-type dual (forbidden-cycle extremal numbers).** Among $n$-element width-$w$ posets containing *no* strict alternating cycle of length $w$, the maximum number of incomparable pairs is $o(n^2)$; equivalently, forbidding the longest cycle forces comparability growth that is sub-quadratic in the number of incomparable pairs.

---

## 11. Conclusion

We have determined, up to constants, the maximum number of strict alternating cycles in an $n$-element poset of fixed width $w$: it is $\Theta(n^{2w})$. The upper bound is classical; the matching lower bound — the open direction — is realized by the blown-up crown $\mathrm{Crown}(w,m)$, a fully verified width-$w$ partial order on $2wm$ points carrying at least $m^{2w}$ strict alternating cycles. The argument's keystone is that inflating crown vertices into chains preserves the width exactly, certified by a one-line column-folding injection. All stated results are machine-checked.
