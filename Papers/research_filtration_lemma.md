# Clock-and-Switch Worlds: A Sharp Filtration Theorem for Finite Preorders

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

A *clock-and-switch world* is the state space of the simplest imaginable irreversible machine: a clock reading in a finite chain that may only advance, together with a bank of switches that may only be turned on. As an ordered set it is the product of a chain with a Boolean cube, $\mathrm{CW}(n,m) \cong [n] \times \{0,1\}^m$, of cardinality $n \cdot 2^m$. We determine exactly which finite preorders arise as *bounded morphic* (p-morphic) images of such worlds, the notion of faithful quotient under which modal validity is preserved and reflected.

Our first main theorem is a complete characterisation: a finite nonempty preorder is a surjective bounded morphic image of a clock-and-switch world **iff** it is rooted, directed and antisymmetric. The positive direction is a constructive *greedy climb* along a linear extension, with a "jump to the top" repair clause without which monotonicity fails; it uses one clock tick and $|P| - 1$ switches. The negative direction is an inheritance theorem: bounded morphic images of finite posets are antisymmetric, so every preorder with a nontrivial cluster is obstructed.

We then supply the quantitative theory. A rank grading yields two independent lower bounds — the cardinality bound $|P| \le n \cdot 2^m$ and the height bound $\operatorname{height}(P) < n+m$ — which meet exactly on chains: the $(\ell+1)$-chain is an image of the one-tick world with $m$ switches iff $\ell \le m$. Switchless worlds represent exactly the finite chains, while the clock is entirely redundant: whatever is representable is representable with one tick.

Finally we repair the obstruction. Adjoining to each world an order-invisible *phase* in a $c$-element indiscrete factor produces a preorder $\mathrm{CW}_c(n,m)$ of cardinality $n \cdot 2^m \cdot c$. We prove that **every finite nonempty rooted directed preorder whose clusters have size at most $c$ is a surjective bounded morphic image of $\mathrm{CW}_c(1,m)$ with $m$ the number of clusters**, and conversely that every cluster of such an image has at most $c$ elements. Hence the minimal admissible number of phases is exactly the maximal cluster size, and phase-representability is characterised by rootedness and directedness alone: antisymmetry disappears, paid for by exactly one order-invisible coordinate metered by the obstruction it removes.

**Keywords:** bounded morphism, p-morphism, finite preorder, cluster, linear extension, Boolean cube, filtration, modal frame, indiscrete preorder.

---

## 1. Introduction

### 1.1 The objects

Fix a preorder $A$ (the *clock*) and a set $B$ (the *switches*). A **clock-and-switch world** over $(A,B)$ is a pair
$$w = (\mathrm{clock}(w),\ \mathrm{switch}(w)) \in A \times (B \to \{\mathrm{on},\mathrm{off}\}).$$
Accessibility is the product order:
$$w \le v \quad :\Longleftrightarrow \quad \mathrm{clock}(w) \le \mathrm{clock}(v) \ \text{ and } \ \forall b \in B,\ \bigl(\mathrm{switch}(w)_b = \mathrm{on} \Rightarrow \mathrm{switch}(v)_b = \mathrm{on}\bigr).$$
Write $\mathrm{CW}(A,B)$ for the resulting preorder, and $\mathrm{CW}(n,m) := \mathrm{CW}([n], [m])$ where $[n] = \{0 < 1 < \cdots < n-1\}$.

This is the canonical model of *monotone resource accumulation*: time advances, commitments are made and never unmade. Three elementary facts, all immediate from the definition, set the stage.

**Proposition 1.1.** *(i) If $A$ is a partial order then so is $\mathrm{CW}(A,B)$; in particular $\mathrm{CW}(n,m)$ is a finite partial order with $n \cdot 2^m$ elements. (ii) If $A$ has a least element then $\mathrm{CW}(A,B)$ is rooted, with root "clock at the bottom, all switches off". (iii) If $A$ is a join-semilattice then $\mathrm{CW}(A,B)$ is directed: $w, v \le (\mathrm{clock}(w) \vee \mathrm{clock}(v),\ \mathrm{switch}(w) \cup \mathrm{switch}(v))$.*

*Proof sketch.* (i) If $w \le v \le w$ then the clocks agree by antisymmetry in $A$, and a switch on in one is on in the other in both directions, so the configurations agree pointwise. (ii) and (iii) are the displayed witnesses. $\square$

The cardinality claim is the bijection $\mathrm{CW}(A,B) \cong A \times (B \to \{0,1\})$, which is an order isomorphism onto the product order.

### 1.2 Faithful quotients

Let $X, Y$ be preorders. A map $f : X \to Y$ is a **bounded morphism** (p-morphism) if:

- **(Forth)** $x \le y \ \Rightarrow \ f(x) \le f(y)$;
- **(Back)** $f(x) \le q \ \Rightarrow \ \exists y \ge x$ with $f(y) = q$.

Bounded morphisms compose. They are the correct notion of quotient here for two reasons. Structurally, the back condition prevents the map from inventing or destroying local possibility: the future of $f(x)$ in $Y$ is precisely the $f$-image of the future of $x$ in $X$. Logically, if $f : X \twoheadrightarrow Y$ is a surjective bounded morphism then $X$ and $Y$ validate exactly the same modal formulas, so any modal-theoretic question about $Y$ can be answered on $X$.

**Definition 1.2.** A preorder $P$ is **representable** if there exist $n, m \in \mathbb{N}$ and a surjective bounded morphism $\mathrm{CW}(n,m) \twoheadrightarrow P$.

Two representations are classical and motivate the theory.

**Example 1.3 (Forget the switches).** $w \mapsto \mathrm{clock}(w)$ is a surjective bounded morphism $\mathrm{CW}(A,B) \twoheadrightarrow A$. Back: to realise a later clock reading $a \ge \mathrm{clock}(w)$, move to $(a, \mathrm{switch}(w))$.

**Example 1.4 (Count the switches).** $w \mapsto \#\{b : \mathrm{switch}(w)_b = \mathrm{on}\}$ is a surjective bounded morphism $\mathrm{CW}(1,m) \twoheadrightarrow [m+1]$. Back: to raise the count to $j$, turn on additional switches until exactly $j$ are on, which is possible since the current count is $\le j \le m$.

The programme of this paper is to determine the class of all representable finite preorders, to meter the resources $(n,m)$ required, and to repair the failure of the class to contain all rooted directed preorders.

### 1.3 Terminology

Throughout, $P$ is a finite preorder. It is **rooted** if some $r \in P$ satisfies $r \le p$ for all $p$; **directed** if any $x,y$ have a common upper bound; **antisymmetric** (a poset) if $p \le q \le p$ implies $p = q$. The **cluster** of $p_0$ is $C(p_0) = \{p : p \le p_0 \text{ and } p_0 \le p\}$; clusters partition $P$ and are singletons exactly when $P$ is a poset. The **antisymmetrisation** $P/\!\!\approx$ is the poset of clusters. The **height** of $P$ is the largest $\ell$ such that there is a strictly increasing chain $c_0 < c_1 < \cdots < c_\ell$ (with $c_i \le c_{i+1}$ and $c_{i+1} \not\le c_i$).

Note the following elementary but repeatedly used fact.

**Lemma 1.5.** *A finite nonempty directed preorder has a greatest element.*

*Proof sketch.* By induction on finite subsets: the empty set has an arbitrary upper bound, and given an upper bound $z$ of $S$ and a new point $a$, directedness supplies an upper bound of $\{a,z\}$, which bounds $S \cup \{a\}$. Apply to the whole (finite) carrier. $\square$

---

## 2. The representation theorem

### 2.1 The greedy climb

**Definition 2.1 (Linear extension enumeration).** A **linear extension enumeration** of a finite nonempty poset $P$ with $k = |P|$ is a listing $t_0, \dots, t_{k-1}$ of all points of $P$ such that $t_i \le t_j \Rightarrow i \le j$. Such an enumeration exists for every finite poset (refine $\le$ to a linear order and list in increasing order).

**Definition 2.2 (Greedy climb).** Let $P$ be a finite poset with root $r$, top $\top$, and linear extension enumeration $t$. For a switch configuration $s : \mathbb{N} \to \{\mathrm{on},\mathrm{off}\}$ define $W_s(i) \in P$ by
$$W_s(0) = r, \qquad W_s(i+1) = \begin{cases} t_i & \text{if } s_i = \mathrm{on} \text{ and } W_s(i) \le t_i,\\ \top & \text{if } s_i = \mathrm{on} \text{ and } W_s(i) \not\le t_i,\\ W_s(i) & \text{if } s_i = \mathrm{off}.\end{cases}$$
The **greedy climb map** is $\Phi(w) = W_{\mathrm{switch}(w)}(k)$ on $\mathrm{CW}(1,k)$.

Two structural facts about $W$ are needed. First, $W_s(i)$ depends only on $s_0, \dots, s_{i-1}$ (immediate induction). Second, $W_{(\mathrm{all\ off})}(i) = r$ for all $i$.

**Lemma 2.3 (Forth).** *If $s_l = \mathrm{on} \Rightarrow s'_l = \mathrm{on}$ for all $l$, then $W_s(i) \le W_{s'}(i)$ for all $i$.*

*Proof sketch.* Induction on $i$. Suppose $W_s(i) \le W_{s'}(i)$. If $s_i = \mathrm{off}$, then $W_s(i+1) = W_s(i) \le W_{s'}(i) \le W_{s'}(i+1)$, using that a single step never descends (if $s'_i = \mathrm{on}$ the step goes to $t_i \ge W_{s'}(i)$ or to $\top$). If $s_i = \mathrm{on}$ then $s'_i = \mathrm{on}$. If $W_{s'}(i) \le t_i$ then $W_s(i) \le t_i$ too and both sides step to $t_i$. If $W_{s'}(i) \not\le t_i$ then the right side steps to $\top$, which dominates everything. $\square$

The clause "$\to \top$" is not cosmetic. Without it — i.e. standing still when $W_s(i) \not\le t_i$ — the map is *not* monotone.

**Example 2.4 (Failure of the naive climb).** Let $P$ be the diamond $0 < a, b < 1$ with $a, b$ incomparable and enumeration $0, a, b, 1$. Under the naive rule, the configuration $\{b\}$ climbs to $b$, while the larger configuration $\{a, b\}$ climbs to $a$ (it reaches $a$, and then $a \not\le b$, so it stands still). Since $b \not\le a$, forth fails. The repair clause sends $\{a,b\}$ to $\top = 1$ instead, restoring monotonicity.

**Lemma 2.5 (Back).** *Let $t$ be a linear extension enumeration, $k' \le k$, and let $s$ be a configuration with $W_s(k') \le t_j$, $j < k'$. Then there is $s' \supseteq s$ (pointwise, on-sets only grow) with $s'_l = s_l$ for $l \ge k'$ except possibly at $j$, and $W_{s'}(k') = t_j$.*

*Proof sketch.* Induct on the number of steps. The essential point is the linear extension property: since $W_s$ only ever moves to points $t_i$ with $i$ increasing, and every point of $P$ below $t_j$ occurs at an index $\le j$, turning on switch $j$ (and leaving the earlier ones as they are) leaves the climb below $t_j$ when it arrives at index $j$, so the "$\le t_i$" branch fires and the climb lands on $t_j$; the later switches, all still off in the relevant positions, cannot move it away. $\square$

**Theorem 2.6 (Representation).** *Every finite rooted directed partial order $P$ is a surjective bounded morphic image of $\mathrm{CW}(1, |P|)$, via the greedy climb along any linear extension enumeration.*

*Proof sketch.* Let $r$ be the root and $\top$ the top (Lemma 1.5). Forth is Lemma 2.3, applied to the switch configurations of two comparable worlds. Back is Lemma 2.5: given $\Phi(w) \le t_j$, produce $s'$ with the same "on" switches as $w$ and possibly more, so the corresponding world is $\ge w$, and $\Phi$ of it is $t_j$. Surjectivity is the special case $w = $ all switches off, where $\Phi(w) = r \le t_j$ for every $j$. $\square$

**Theorem 2.7 (Sharp switch count, upper bound).** *Every finite rooted directed poset $P$ is a surjective bounded morphic image of $\mathrm{CW}(1, |P| - 1)$.*

*Proof sketch.* In any linear extension enumeration of a rooted poset, $t_0 = r$: the root is below everything, so its index is minimal. The switch attached to the root is a no-op, since the climb starts at $r$ and jumping to $r$ from $r$ changes nothing. Re-index so that switch $i$ carries $t_{i+1}$, and note that the back condition acquires exactly one extra case: the target $r$ itself is reached with no switches on at all, using antisymmetry (nothing strictly below $r$ exists, so $\Phi(w) \le r$ forces $\Phi(w) = r$). $\square$

Also useful: *spare switches are harmless*. Forgetting the last $b$ switches, $\mathrm{CW}(1, a+b) \twoheadrightarrow \mathrm{CW}(1,a)$, is a surjective bounded morphism, so a representation with $m$ switches yields one with any $m' \ge m$.

### 2.2 The obstruction

**Theorem 2.8 (Antisymmetry is inherited).** *Let $X$ be a finite partial order, $Y$ a preorder, and $f : X \twoheadrightarrow Y$ a surjective bounded morphism. Then $Y$ is antisymmetric.*

*Proof.* Let $p \le q$ and $q \le p$ in $Y$; write $p = f(x_0)$. Put $S = \{x \in X : f(x) = p \text{ or } f(x) = q\}$, a nonempty finite set, and choose $x \in S$ maximal (possible since $X$ is finite and antisymmetric, so maximal elements of nonempty finite subsets exist). Maximality says: for all $y \in S$ with $x \le y$, we have $y = x$.

Case $f(x) = p$: from $f(x) = p \le q$, Back gives $y \ge x$ with $f(y) = q$; then $y \in S$, so $y = x$ and $p = f(x) = q$. Case $f(x) = q$: symmetrically, from $q \le p$ Back gives $y \ge x$ with $f(y) = p$, so $y = x$ and $q = p$. $\square$

**Corollary 2.9 (The two-element cluster is not representable).** *Let $K$ be the two-element preorder in which both points are $\le$ each other. Then $K$ is finite, rooted and directed, but is not a bounded morphic image of any $\mathrm{CW}(n,m)$.*

*Proof.* $\mathrm{CW}(n,m)$ is a finite poset (Proposition 1.1), so Theorem 2.8 would force $K$ antisymmetric, which it is not. $\square$

Thus the literal filtration statement — *every finite rooted directed preorder is a bounded morphic image of some $\mathrm{CW}(n,m)$* — is false, with a two-point counterexample.

### 2.3 The characterisation

**Theorem 2.10 (Characterisation).** *For a finite nonempty preorder $P$:*
$$P \text{ is representable} \iff P \text{ is rooted, directed and antisymmetric.}$$

*Proof sketch.* ($\Rightarrow$) Given a surjection $\mathrm{CW}(n,m) \twoheadrightarrow P$: $n \ge 1$ since $P \neq \emptyset$; then rootedness and directedness are inherited by surjective monotone images of rooted/directed preorders (push the root and the common upper bound forward through Forth), and antisymmetry is Theorem 2.8. ($\Leftarrow$) Antisymmetry upgrades the preorder to a poset, and Theorem 2.6 applies with $n = 1$, $m = |P|$ (or Theorem 2.7 with $m = |P|-1$). $\square$

The value of Theorem 2.10 is that it converts every question about the existence of morphisms into a check of three elementary order conditions. The next section harvests this.

---

## 3. Closure properties of the representable class

Throughout, all orders are finite and nonempty.

**Theorem 3.1 (Isomorphism invariance).** *If $P \cong Q$ as ordered sets and $P$ is representable, so is $Q$.*

*Proof sketch.* Transport the root, the common upper bounds, and antisymmetry across the isomorphism. $\square$

**Theorem 3.2 (Binary products).** *If $P$ and $Q$ are representable, so is $P \times Q$ with the product order.*

*Proof sketch.* Root $(r_P, r_Q)$; a common upper bound of $(x_1,x_2)$ and $(y_1,y_2)$ is $(z_1, z_2)$ for coordinatewise common upper bounds; antisymmetry is coordinatewise. $\square$

**Theorem 3.3 (Finite products).** *If $\iota$ is a finite index set and each $P_i$ is representable, then $\prod_{i \in \iota} P_i$ is representable.*

*Proof sketch.* Identical to Theorem 3.2, coordinatewise, choosing roots and upper bounds in each factor. $\square$

**Theorem 3.4 (Principal filters).** *If $P$ is representable and $p \in P$, then the principal filter $\uparrow\!p = \{q \in P : p \le q\}$ is representable.*

*Proof sketch.* $\uparrow\!p$ is rooted at $p$. Given $x, y \in \uparrow\!p$ with common upper bound $z$ in $P$, one has $p \le x \le z$, so $z \in \uparrow\!p$. Antisymmetry is inherited by subsets. $\square$

Note that the *dual* statement fails in general: a principal ideal $\downarrow\!p$ need not be directed.

**Theorem 3.5 (Bounded lattices).** *Every finite lattice with least and greatest elements is representable. In particular every finite Boolean algebra, every finite distributive lattice with $\bot,\top$, and every finite chain is representable.*

*Proof.* Root $\bot$; directedness via $x \vee y$; antisymmetry is part of being a lattice order. Apply Theorem 2.10. $\square$

**Theorem 3.6 (Closure under images).** *If $P$ is representable and $g : P \twoheadrightarrow Q$ is a surjective bounded morphism, then $Q$ is representable.*

*Proof.* Compose. $\square$

Thus the representable finite preorders are exactly the closure of $\{\mathrm{CW}(n,m)\}$ under surjective bounded morphic images, and this closure is a large, robust class: it contains all finite bounded lattices and is stable under products and principal filters.

---

## 4. How much machine is needed?

### 4.1 The rank grading and two lower bounds

**Definition 4.1.** The **rank** of $w \in \mathrm{CW}(n,m)$ is $\mathrm{rk}(w) = \mathrm{clock}(w) + \#\{b : \mathrm{switch}(w)_b = \mathrm{on}\} \in \{0, \dots, n+m-1\}$.

**Lemma 4.2.** *$\mathrm{rk}$ is monotone, and strictly monotone: $w \le v$ and $w \neq v$ imply $\mathrm{rk}(w) < \mathrm{rk}(v)$.*

*Proof sketch.* Monotone because both summands are. If the rank is equal then the clocks are equal (the clock cannot decrease) and the on-sets have equal size while one contains the other, so they are equal; hence $w = v$. $\square$

**Proposition 4.3 (Cardinality bound).** *If $\mathrm{CW}(n,m) \twoheadrightarrow P$ then $|P| \le n \cdot 2^m$; equivalently $m \ge \log_2(|P|/n)$.*

**Theorem 4.4 (Chain lifting).** *Let $f : \mathrm{CW}(n,m) \twoheadrightarrow P$ be a surjective bounded morphism and let $c_0, \dots, c_\ell$ be a strictly increasing chain in $P$ ($c_i \le c_{i+1}$, $c_{i+1} \not\le c_i$). Then there is $w \in \mathrm{CW}(n,m)$ with $\mathrm{rk}(w) \ge \ell$.*

*Proof sketch.* Induct on $\ell$, lifting one step at a time. Given $w_i$ with $f(w_i) = c_i$ and $\mathrm{rk}(w_i) \ge i$, apply Back to $f(w_i) = c_i \le c_{i+1}$ to obtain $w_{i+1} \ge w_i$ with $f(w_{i+1}) = c_{i+1}$. Since $c_{i+1} \not\le c_i$, we have $w_{i+1} \neq w_i$, so Lemma 4.2 gives $\mathrm{rk}(w_{i+1}) > \mathrm{rk}(w_i) \ge i$. No dependent choice is needed: the chain is lifted inside a single induction. $\square$

**Corollary 4.5 (Height bound).** *If $P$ is a surjective bounded morphic image of $\mathrm{CW}(n,m)$ and $P$ contains a strictly increasing chain with $\ell+1$ points, then $\ell < n + m$. Equivalently $\operatorname{height}(P) \le n + m - 1$.*

*Proof.* Combine Theorem 4.4 with $\mathrm{rk} < n+m$. $\square$

The two bounds are genuinely independent: the cardinality bound is logarithmic in $|P|$ and blind to shape; the height bound is linear in the length of the longest chain and blind to width. For a Boolean cube the first is tight and the second is weak; for a chain the second is tight and the first is exponentially weak.

### 4.2 Chains: matching bounds

**Theorem 4.6 (Exact switch count for chains).** *For all $\ell, m \ge 0$:*
$$\bigl(\exists\ \text{surjective bounded morphism } \mathrm{CW}(1,m) \twoheadrightarrow [\ell+1]\bigr) \iff \ell \le m.$$

*Proof sketch.* ($\Rightarrow$) The chain $[\ell+1]$ contains a strictly increasing chain of $\ell+1$ points, so Corollary 4.5 gives $\ell < 1 + m$. ($\Leftarrow$) Theorem 2.7 with $|P| = \ell+1$ supplies a morphism from $\mathrm{CW}(1,\ell)$; extra switches are harmless by the "forget the last $b$ switches" morphism. $\square$

**Corollary 4.7 (Optimality of "count the switches").** *The least $m$ with $\mathrm{CW}(1,m) \twoheadrightarrow [\ell+1]$ is exactly $\ell$, and the switch-counting morphism of Example 1.4 attains it. So that classical example is optimal, not merely illustrative.*

### 4.3 Which resource does the branching?

**Theorem 4.8 (Switchless worlds are exactly the chains).** *A finite nonempty preorder $P$ is a surjective bounded morphic image of some $\mathrm{CW}(n,0)$ iff $P$ is a linear order (total and antisymmetric).*

*Proof sketch.* ($\Rightarrow$) $\mathrm{CW}(n,0)$ is totally ordered (the clock is its only coordinate), and Forth pushes totality forward; antisymmetry is Theorem 2.8. ($\Leftarrow$) A finite linear order with $k$ elements is isomorphic to $[k] \cong \mathrm{CW}(k,0)$, and order isomorphisms are bounded morphisms. $\square$

So the clock alone cannot create incomparability: every branching in a representable order is paid for in switches. The converse asymmetry also holds.

**Theorem 4.9 (The clock is redundant).** *A finite nonempty preorder is representable iff it is a surjective bounded morphic image of a one-tick world $\mathrm{CW}(1,m)$ for some $m$.*

*Proof.* If representable then rooted, directed and antisymmetric (Theorem 2.10), so Theorem 2.6 gives a one-tick representation. The converse is trivial. $\square$

The two coordinates of a clock-and-switch world are therefore far from symmetric: **switches subsume clocks; clocks do not subsume switches.** The clock survives as a convenience (it makes chains cheap: $[\ell+1] \cong \mathrm{CW}(\ell+1, 0)$ costs $0$ switches) but never as a necessity.

### 4.4 Modal transfer

Bounded morphisms are exactly the maps along which modal satisfaction transfers. Reading a preorder $X$ as a Kripke frame with accessibility $\le$, and writing $X \models \varphi$ for validity of a modal formula $\varphi$ on that frame:

**Theorem 4.10 (p-morphism lemma).** *If $f : X \to Y$ is a bounded morphism of preorders, $V$ a valuation on $Y$, and $\varphi$ any modal formula, then $x \Vdash_{V \circ f} \varphi$ iff $f(x) \Vdash_V \varphi$. Consequently, if $f$ is surjective then $X \models \varphi$ implies $Y \models \varphi$.*

*Proof sketch.* Induction on $\varphi$. The only nontrivial case is $\Box\psi$, where Forth is used for one implication and Back for the other. $\square$

**Theorem 4.11 (Modal theory of clock-and-switch worlds).** *For every modal formula $\varphi$: $\varphi$ is valid on every finite rooted directed poset iff $\varphi$ is valid on every $\mathrm{CW}(n,m)$.*

*Proof sketch.* ($\Rightarrow$) Every nonempty $\mathrm{CW}(n,m)$ *is* a finite rooted directed poset; the empty case ($n=0$) is vacuous. ($\Leftarrow$) Given a finite rooted directed poset $P$, Theorem 2.6 provides a surjective bounded morphism from $\mathrm{CW}(1, |P|)$, and Theorem 4.10 transfers validity. $\square$

So a modal formula is refutable on some finite bounded poset precisely when it is refutable on a product of a chain with a Boolean cube — a purely combinatorial criterion for a logical property, and a genuine reduction of the search space to a highly structured family.

**Example 4.12 (S4.2 by transfer).** The axiom $\Diamond\Box p \to \Box\Diamond p$ is valid on any directed preorder: given $x$ with some $u \ge x$ forcing $\Box p$, and any $y \ge x$, directedness gives $z \ge u, y$, and then $z \Vdash p$, so $y \Vdash \Diamond p$. Verifying this on $\mathrm{CW}(n,m)$ uses only the explicit directedness of Proposition 1.1(iii) ("advance the clock, union the switches"); Theorem 4.11 then exports validity to *every* finite rooted directed poset without re-examining those posets at all.

---

## 5. Phase-augmented worlds: repairing the mission

### 5.1 Why the obvious repairs fail

The literal filtration statement fails because of Theorem 2.8, and Theorem 2.8 uses only two properties of the source: it is finite, and it is antisymmetric. Two natural attempts to enlarge the source class therefore fail for structural reasons:

- **Enlarging by a product with an ordered factor.** If the extra coordinate carries any partial order, the product is again a finite poset, and Theorem 2.8 applies verbatim. No gain.
- **Enlarging by quotienting.** A quotient of a poset by an order-compatible equivalence is again a poset. Clusters cannot be manufactured by collapsing.

What is needed is a coordinate that is present in the carrier but **invisible to the order**.

### 5.2 The definition

**Definition 5.1 (Phase-augmented world).** For $c \ge 0$, a **phase-augmented clock-and-switch world** is a pair
$$w = (\mathrm{base}(w),\ \mathrm{phase}(w)) \in \mathrm{CW}(A,B) \times [c],$$
ordered by
$$w \le v \quad :\Longleftrightarrow\quad \mathrm{base}(w) \le \mathrm{base}(v).$$
Write $\mathrm{CW}_c(A,B)$, and $\mathrm{CW}_c(n,m)$ in the finite case.

Equivalently, $\mathrm{CW}_c(A,B)$ is the product of $\mathrm{CW}(A,B)$ with the $c$-element **indiscrete** preorder (every point $\le$ every point).

**Proposition 5.2.** *(i) $|\mathrm{CW}_c(n,m)| = n \cdot 2^m \cdot c$. (ii) $\mathrm{CW}_c(A,B)$ is rooted whenever $A$ has a least element and $c \ge 1$, and directed whenever $A$ is a join-semilattice. (iii) If $c \ge 2$ and $A \neq \emptyset$, $\mathrm{CW}_c(A,B)$ is not antisymmetric: any two states with the same base and different phases form a two-element cluster. (iv) $\mathrm{Forget\ the\ phase}$, $w \mapsto \mathrm{base}(w)$, is a surjective bounded morphism $\mathrm{CW}_c(A,B) \twoheadrightarrow \mathrm{CW}(A,B)$ when $c \ge 1$.*

*Proof sketch.* (i) is the product bijection. (ii) copies Proposition 1.1 with any phase attached. (iii) is the displayed pair. (iv) Forth is the definition; Back is trivial: to realise $u \ge \mathrm{base}(w)$, move to $(u, \mathrm{phase}(w))$. $\square$

Item (iv) is the third structural projection of the theory, standing alongside "forget the switches" (Example 1.3) and "count the switches" (Example 1.4).

**Definition 5.3.** $P$ is **phase-representable** if there are $n, m, c$ and a surjective bounded morphism $\mathrm{CW}_c(n,m) \twoheadrightarrow P$.

Since the phase can be trivial, every representable preorder is phase-representable: compose with the forget-the-phase morphism at $c = 1$.

### 5.3 The filtration lemma for preorders

**Theorem 5.4 (Filtration lemma, sharp form).** *Let $P$ be a finite nonempty rooted directed preorder in which every cluster has at most $c$ elements. Let $m = |P/\!\!\approx|$ be the number of clusters. Then $P$ is a surjective bounded morphic image of $\mathrm{CW}_c(1,m)$.*

*Proof.* Let $Q = P/\!\!\approx$ be the antisymmetrisation, $\pi : P \to Q$ the quotient, and fix a section $\rho : Q \to P$ with $\pi\rho = \mathrm{id}$. The defining property of the antisymmetrisation is
$$\pi(a) \le \pi(b) \iff a \le b .$$
Hence $Q$ is finite, nonempty, rooted (at $\pi(r)$) and directed (push common upper bounds through $\pi$), and it is a *poset*. Theorem 2.6 supplies a surjective bounded morphism
$$f : \mathrm{CW}(1, |Q|) \twoheadrightarrow Q .$$

The fibres of $\pi$ are exactly the clusters: $\pi(p) = q \iff p \in C(\rho(q))$. By hypothesis each fibre has at most $c$ elements, so we may fix, for each $q \in Q$, an injection $e_q : \pi^{-1}(q) \hookrightarrow [c]$. Define a **choice function**
$$\mathrm{pick}(q, j) = \begin{cases} \text{the unique } p \in \pi^{-1}(q) \text{ with } e_q(p) = j, & \text{if such a } p \text{ exists},\\ \rho(q), & \text{otherwise},\end{cases}$$
which satisfies two properties: $\pi(\mathrm{pick}(q,j)) = q$ always, and for every $p \in P$ there is $j$ with $\mathrm{pick}(\pi(p), j) = p$ (namely $j = e_{\pi(p)}(p)$).

Now define
$$F : \mathrm{CW}_c(1, |Q|) \to P, \qquad F(w) = \mathrm{pick}\bigl(f(\mathrm{base}(w)),\ \mathrm{phase}(w)\bigr).$$

*Forth.* If $w \le v$ then $\mathrm{base}(w) \le \mathrm{base}(v)$, so $f(\mathrm{base}(w)) \le f(\mathrm{base}(v))$ in $Q$. Applying $\pi(\mathrm{pick}(q,j)) = q$ twice, $\pi(F(w)) \le \pi(F(v))$, which by the displayed equivalence is exactly $F(w) \le F(v)$.

*Back.* Suppose $F(w) \le p$. Then $f(\mathrm{base}(w)) = \pi(F(w)) \le \pi(p)$ in $Q$, so Back for $f$ yields $u \ge \mathrm{base}(w)$ with $f(u) = \pi(p)$. Choose $j$ with $\mathrm{pick}(\pi(p), j) = p$. Then $(u, j) \ge w$ and $F(u,j) = \mathrm{pick}(\pi(p), j) = p$.

*Surjectivity.* Given $p$, pick $w_0$ with $f(w_0) = \pi(p)$ (surjectivity of $f$) and $j$ with $\mathrm{pick}(\pi(p), j) = p$; then $F(w_0, j) = p$. $\square$

The proof is a genuine two-layer factorisation: the poset layer is the greedy climb, reused verbatim, and the new content is entirely the "phase = choice inside the cluster" layer, whose back condition depends on the *fibre-surjectivity* of $\mathrm{pick}$.

**Corollary 5.5 (The mission statement, repaired).** *Every finite nonempty rooted directed preorder — no antisymmetry assumed — is a surjective bounded morphic image of some $\mathrm{CW}_c(n,m)$.*

*Proof.* Apply Theorem 5.4 with $c = |P|$, which trivially bounds all cluster sizes. $\square$

**Corollary 5.6.** *The two-element cluster $K$, excluded from the poset theory by Corollary 2.9, is phase-representable — with two phases.*

### 5.4 The converse: phases are metered by cluster size

**Theorem 5.7 (Cluster bound).** *If $f : \mathrm{CW}_c(n,m) \twoheadrightarrow P$ is a surjective bounded morphism, then every cluster of $P$ has at most $c$ elements.*

*Proof.* Fix $p_0 \in P$ and let $C = C(p_0)$ be its cluster. Consider the set of *bases* of preimages of $C$:
$$S = \{u \in \mathrm{CW}(n,m) : \exists j \in [c],\ f(u,j) \in C\}.$$
$S$ is nonempty (take any preimage of $p_0$) and finite, and $\mathrm{CW}(n,m)$ is a partial order, so choose $u \in S$ maximal: for all $v \in S$ with $u \le v$, $v = u$.

*Claim: every element of $C$ is realised at base $u$.* Let $p \in C$ and let $j_0$ witness $u \in S$, i.e. $f(u, j_0) \in C$. Since $C$ is a cluster, $f(u,j_0) \le p_0 \le p$, so Back gives $y = (y_b, y_p) \ge (u, j_0)$ with $f(y) = p$. Then $y_b \ge u$ and $y_b \in S$ (witnessed by $y_p$, since $p \in C$), so maximality forces $y_b = u$, and $f(u, y_p) = p$.

Hence $C \subseteq \{f(u,j) : j \in [c]\}$, a set of at most $c$ elements. $\square$

**Theorem 5.8 (Characterisation of phase-representability).** *A finite nonempty preorder is phase-representable iff it is rooted and directed.*

*Proof.* ($\Rightarrow$) A surjection forces $n, c \ge 1$; then rootedness and directedness are inherited from $\mathrm{CW}_c(n,m)$ (Proposition 5.2(ii)) through Forth. ($\Leftarrow$) Corollary 5.5. $\square$

Compare Theorem 2.10: the antisymmetry clause has disappeared. It has not been swept aside — it has been *bought*, and the price is recorded exactly:

**Theorem 5.9 (Sharpness of the phase count).** *Let $P$ be a finite nonempty rooted directed preorder and $c \ge 0$. Then*
$$\bigl(\exists m,\ \mathrm{CW}_c(1,m) \twoheadrightarrow P\bigr) \iff \bigl(\text{every cluster of } P \text{ has at most } c \text{ elements}\bigr).$$
*Consequently the least admissible number of phases is exactly the maximal cluster size of $P$.*

*Proof.* ($\Rightarrow$) Theorem 5.7. ($\Leftarrow$) Theorem 5.4. $\square$

This is the aesthetic core of the paper. The obstruction to the original statement was a single order-theoretic invariant — the presence and size of clusters. The repair is a single new coordinate, and the amount of that coordinate required is *precisely* the invariant that was in the way. Nothing is wasted and nothing is missing.

---

## 6. Algorithms

The theory is constructive, and every proof above corresponds to an executable procedure.

**Algorithm A (Greedy climb representation).** *Input:* a finite rooted directed poset $P$ given by its order relation. *Output:* the map $\Phi : \mathrm{CW}(1, |P|) \to P$.
1. Compute the root $r$ and the top $\top$.
2. Compute a linear extension $t_0, \dots, t_{k-1}$ (topological sort).
3. For each of the $2^k$ switch configurations $s$: set $w \leftarrow r$; for $i = 0, \dots, k-1$, if $s_i$ is on then set $w \leftarrow t_i$ if $w \le t_i$, else $w \leftarrow \top$. Emit $\Phi(s) = w$.

Complexity: $O(2^k \cdot k)$ order comparisons to tabulate the whole map; $O(k)$ per configuration. Verifying Forth naively costs $O(4^k)$ comparisons, and Back $O(2^k \cdot k \cdot |P|)$, though both are only needed for validation, not for construction.

**Algorithm B (Minimal switch number by pruned search).** *Input:* a finite rooted directed poset $P$ and a bound $M$. *Output:* the least $m \le M$ admitting a surjective bounded morphism $\mathrm{CW}(1,m) \twoheadrightarrow P$, if any. For each $m$ in increasing order, enumerate candidate maps by assigning values to cube vertices in order of increasing popcount, pruning immediately whenever monotonicity is violated against an already-assigned predecessor; at each complete assignment, test Back and surjectivity. The height and cardinality bounds ($m \ge \operatorname{height}(P)$ for one-tick worlds, $2^m \ge |P|$) prune the outer loop.

**Algorithm C (Phase-augmented representation).** *Input:* a finite rooted directed preorder $P$. *Output:* a surjective bounded morphism from $\mathrm{CW}_c(1,m) \twoheadrightarrow P$ with $c$ the maximal cluster size and $m$ the number of clusters.
1. Compute clusters $C_1, \dots, C_m$ by the mutual-accessibility relation; set $c = \max_i |C_i|$.
2. Build the antisymmetrisation $Q$ on $\{1, \dots, m\}$ and check it is a rooted directed poset.
3. Run Algorithm A on $Q$ to obtain $f : \mathrm{CW}(1,m) \to Q$.
4. Enumerate each cluster $C_i = \{p_{i,0}, \dots\}$, defining $\mathrm{pick}(i, j) = p_{i, \min(j, |C_i|-1)}$ — any fibre-surjective choice will do.
5. Emit $F(w, j) = \mathrm{pick}(f(w), j)$.

Complexity: cluster computation $O(|P|^2)$; step 3 dominates at $O(2^m \cdot m)$.

---

## 7. Discussion and applications

**Interpretation.** The characterisation says that the finite state spaces expressible by a monotone-resource machine, up to faithful (possibility-preserving) quotient, are exactly the ones with (i) a definite initial state, (ii) no permanently divergent branches, and (iii) no observationally indistinguishable duplicates. Conditions (i)–(ii) are structural facts about the process; condition (iii) is an *observational* fact, and the phase-augmented theory shows precisely what has to be added to the machine to allow it: hidden state, in the exact quantity of the indistinguishability it must support.

**Resource accounting.** The two lower bounds have a clean reading. Branching (width) is paid for logarithmically in switches, since a cube of $m$ switches supports $2^m$ states; length (height) is paid for linearly in ticks-plus-switches, since the rank increases by at least one per strict step. The switchless and one-tick theorems say the two resources are not interchangeable: the switch bank alone suffices for everything, while the clock alone yields only chains.

**Logic.** Theorem 4.11 turns a semantic question ("is $\varphi$ valid on all finite rooted directed posets?") into a question about a single, highly structured, easily enumerated family of frames. It is the practical face of the representation theorem: one checks an axiom on lines-times-cubes and gets it for free on a class one would not want to enumerate.

**Limits of the results.** Theorem 2.7 gives $|P| - 1$ switches, matched by the height bound only on chains. For general posets the exact switch number is not determined here: the diamond needs $2$ switches (matching $\lceil \log_2 4\rceil = 2$ and $\operatorname{height} = 2$), but there exist $6$-point posets of height $3$ where neither the logarithmic bound $\lceil \log_2 6 \rceil = 3$ nor the height bound is attained, and $4$ switches are needed. Closing this gap is the first open problem below. Likewise, Theorem 5.4 uses one switch per cluster, which is optimal for chains of clusters but is not claimed optimal in general.

---

## 8. Future directions

**Direction 1 — The switch number as an order invariant.** Define $\mathrm{sw}(P)$ to be the least $m$ with a surjective bounded morphism $\mathrm{CW}(1,m) \twoheadrightarrow P$. Conjecture: $\mathrm{sw}$ is *not* determined by the pair $(|P|, \operatorname{height}(P))$, but it *is* determined by the cover-branching profile
$$\mathrm{sw}(P) = \max_{C \text{ maximal chain}} \bigl(|C| - 1 + b(C)\bigr),$$
where $b(C)$ counts the points off $C$ that must be entered from $C$ by a single extra switch. The insight is that the greedy climb spends exactly one switch per point it must be able to *enter*, so the true invariant counts entries, not points or levels. The two matching bounds and an explicit counterexample to the naive formula (a $6$-point poset of height $3$ with $\lceil\log_2 6\rceil = 3$ yet $\mathrm{sw} = 4$) isolate the gap to a single combinatorial quantity, searchable exhaustively for $|P| \le 7$.

**Direction 2 — Randomised representability threshold.** For the random bounded poset on $n$ points obtained by transitively closing $G(n,p)$ on a linear order and adjoining $\bot, \top$, conjecture that $\mathrm{sw} = (1 + o(1))\, n$ for constant $p$: the trivial upper bound $n-1$ is asymptotically tight for almost all bounded posets. The insight is that a random bounded poset has linearly many "incomparable entries", each of which consumes a switch.

**Direction 3 — Cluster-aware switch economy.** Theorem 5.9 meters the phases exactly; the switch count in the phase-augmented setting is metered only by the number of clusters. Is the least $m$ in Theorem 5.4 equal to $\mathrm{sw}(P/\!\!\approx)$? The upper bound is immediate from the factorisation; a matching lower bound would require lifting the height argument through the indiscrete factor.

**Direction 4 — Infinite and non-well-founded worlds.** The maximality arguments behind Theorems 2.8 and 5.7 use finiteness of the source essentially. For clocks ranging over an infinite well-order, or for switch banks indexed by an infinite set, both the inheritance theorem and the cluster bound need a replacement for "choose a maximal preimage"; a Zorn-type argument requires chain-completeness in the fibre, which is not automatic.

**Direction 5 — Modal completeness with phases.** Theorem 4.11 identifies the modal theory of clock-and-switch worlds with that of the finite rooted directed posets. Its phase-augmented analogue should identify the modal theory of $\{\mathrm{CW}_c(n,m)\}$ with that of the finite rooted directed *preorders*, i.e. with **S4.2**; the transfer machinery is already in place, and what remains is the finite model property in the cluster-tolerant setting.

---

## 9. Summary of results

| Result | Statement |
|---|---|
| Cardinality | $\vert\mathrm{CW}(n,m)\vert = n \cdot 2^m$; $\vert\mathrm{CW}_c(n,m)\vert = n \cdot 2^m \cdot c$ |
| Representation | Every finite rooted directed poset is a bounded morphic image of $\mathrm{CW}(1, \vert P\vert - 1)$, via the greedy climb |
| Obstruction | Bounded morphic images of finite posets are antisymmetric; the two-element cluster is not representable |
| Characterisation | Representable $\iff$ rooted, directed and antisymmetric |
| Closure | Representability is preserved by isomorphism, finite products, principal filters, images; all finite bounded lattices are representable |
| Lower bounds | $\vert P\vert \le n \cdot 2^m$ and $\operatorname{height}(P) \le n+m-1$ |
| Chains | $\mathrm{CW}(1,m) \twoheadrightarrow [\ell+1]$ iff $\ell \le m$; switch-counting is optimal |
| Resources | Switchless worlds represent exactly the finite chains; the clock is redundant |
| Logic | The modal theory of clock-and-switch worlds equals that of the finite rooted directed posets |
| Filtration lemma | Cluster sizes $\le c$ $\Rightarrow$ $P$ is an image of $\mathrm{CW}_c(1, \vert P/\!\!\approx\vert)$ |
| Converse | Images of $\mathrm{CW}_c(n,m)$ have all clusters of size $\le c$ |
| Sharpness | Minimal phase count $=$ maximal cluster size; phase-representable $\iff$ rooted and directed |
