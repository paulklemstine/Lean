# The Refinement Hierarchy of Survival Games: Bounded-Depth Clocks, the $\omega^\omega$ Limit, and an Exact Closure Ordinal

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop the order-theoretic theory of *survival games*: two-player games in which one player (Mortal) fixes a well-ordered schedule of moments and survives exactly as long as that schedule lasts, so that the strategic content of the game is the order type of the schedule. We study the operator that **refines** a schedule by replacing each of its moments with an entire copy of the natural-number clock, and prove that refinement multiplies the survival value on the left by $\omega$. Iterating, the $k$-fold refinement of a game of value $v$ has value $\omega^k \cdot v$; in particular the $k$-fold refinement of the natural-number schedule has value exactly $\omega^{k+1}$, and the resulting hierarchy is strict in the strong sense that a $j$-fold refined Mortal cannot force survival to the death round of a $k$-fold refined one whenever $j < k$. We characterise the reach of bounded-depth clocks: a game is timed by the $k$-fold lexicographic natural-number clock if and only if its survival value is at most $\omega^k$, with the general statement that a game embeds into the canonical well-order of an ordinal $o$ exactly when its value is at most $o$. We then construct the limit of all finite refinement depths as a dependent lexicographic sum and prove its value is exactly $\omega^\omega$; the upper bound comes from an explicit key function $\mathrm{key}\langle k, a\rangle = \omega^k + \mathrm{rank}(a)$ which simultaneously certifies well-foundedness of the dependent lexicographic order. This is generalised to a limit theorem: a lexicographic chain of lives whose values lie below and are cofinal in an additively principal ordinal $o$ has value exactly $o$. We prove three structural theorems — completeness of the survival value as an invariant, non-commutativity of concatenation of lives, and a criterion for refinement stability ($\omega^a$ is stable iff $\omega \le a$) — and we deduce a negative result refuting the natural conjecture that refinement always strictly increases survival: the limit clock is a fixed point, $\omega \cdot \omega^\omega = \omega^\omega$. Finally we exhibit a monotone transfinite transition system, the abstract skeleton of an infinite-time machine, whose stages admit a closed form, whose reachable-time well-order is order-isomorphic to the moments of the bounded-nondeterministic game, and whose closure ordinal is *exactly* $\omega^2$, coinciding with that game's survival value.

**Keywords:** ordinal arithmetic, well-orders, survival games, lexicographic orders, Cantor normal form, additively principal ordinals, closure ordinals, infinite-time computation.

---

## 1. Introduction

Comparing infinite processes by size fails immediately: all the processes we care about here have countably many stages, so cardinality cannot distinguish them. Comparing them by *shape* succeeds. The invariant that does the work is the order type of the process's stages — an ordinal.

The device we use to make this concrete is a game. **Mortal** must present, in advance, a well-ordered list of the moments of a life; the **Reaper** advances one moment per round; Mortal survives while moments remain. The value of the game is the order type of the schedule, and everything strategic reduces to comparison of ordinals. This is a deliberately minimal model: it is chosen so that no strategic subtlety hides in the game tree, and so that every theorem is a theorem about ordinals wearing a suggestive costume.

Two natural questions organise the paper.

1. **How much time does structural refinement buy?** If Mortal subdivides every moment of a schedule into an infinite sequence of finer moments, how much longer does he live? The answer, exactly a factor of $\omega$, generates a strict hierarchy $\omega, \omega^2, \omega^3, \dots$ Where does it stop, and does it stop for a reason?

2. **What is the exact reach of a bounded clock?** If a life must be timed on an odometer with $k$ base-$\omega$ digits, what is the precise ceiling on its length, and is the ceiling attained?

We answer both, and then take the answers seriously enough to test the naive conjectures they invite. One of these — "refinement always strictly increases the survival value" — is *false*, and its failure is not an artefact but a diagnosis: it fails exactly when the multiplication $\omega \cdot o = o$ has already stabilised, which happens exactly at the additively principal ordinals whose exponents are infinite.

The last part of the paper connects the order-theoretic picture to computation. We build a monotone transfinite transition system whose closure ordinal we compute exactly, and show it realises the survival game of value $\omega^2$ faithfully, so that "how long can Mortal survive?" and "how long does this machine run before it stalls?" have literally the same answer.

**Notation.** Ordinals are von Neumann ordinals with the usual (non-commutative) arithmetic; $\omega$ denotes the first infinite ordinal. For a well-ordered set $(X, <)$, $\mathrm{type}(X,<)$ is its order type, and for $x \in X$, $\mathrm{rank}(x)$ denotes the order type of the set of predecessors of $x$ (equivalently the position of $x$). For an ordinal $o$, $\mathsf{Ord}(o)$ denotes the canonical well-ordered set of ordinals below $o$; $\mathrm{type}(\mathsf{Ord}(o)) = o$. We write $\mathrm{Lex}(A \times B)$ for the product ordered lexicographically with the $A$-coordinate most significant, and $\sum^{\mathrm{lex}}_{k \in \mathbb{N}} X_k$ for the dependent sum $\{\langle k, a\rangle : a \in X_k\}$ ordered by depth first and then within the fibre. Recall $\mathrm{type}(\mathrm{Lex}(A\times B)) = \mathrm{type}(B) \cdot \mathrm{type}(A)$: the *less* significant factor becomes the left factor of the ordinal product.

---

## 2. The model

**Definition 2.1 (Survival game).** A *survival game* $G$ consists of a set $\mathrm{Mom}(G)$ of **moments** equipped with a well-order $<$. Its **survival value** is
$$\mathrm{val}(G) := \mathrm{type}(\mathrm{Mom}(G), <).$$

The intended reading: the moments, in their order, are the rounds Mortal will live through; the Reaper walks the order from the bottom; Mortal is alive at a round while the order still supplies a moment. Well-foundedness is the requirement that the walk is well defined — there is always a next moment to consume and no infinite regress.

**Definition 2.2 (Forcing).** Mortal *forces survival to $\alpha$* in $G$, written $G \Vdash \alpha$, when the schedule supplies at least $\alpha$ rounds. In the model this is the statement
$$G \Vdash \alpha \iff \alpha \le \mathrm{val}(G).$$

**Lemma 2.3 (Non-forcing from strict inequality).** If $\mathrm{val}(G) < \mathrm{val}(H)$ then $\neg\, (G \Vdash \mathrm{val}(H))$.

*Proof.* Immediate from Definition 2.2: $\mathrm{val}(H) \le \mathrm{val}(G)$ would contradict $\mathrm{val}(G) < \mathrm{val}(H)$. $\square$

Three basic games recur.

**Definition 2.4.**
- The **point game** has a single moment; $\mathrm{val} = 1$.
- The **finite game** $F$ has moments $\mathbb{N}$ in their usual order; $\mathrm{val}(F) = \omega$. This is the Mortal who survives every finite round but has no last moment.
- The **bounded-nondeterministic game** $N$ has moments $\mathrm{Lex}(\mathbb{N}\times\mathbb{N})$; $\mathrm{val}(N) = \omega^2$. This is the Mortal who, at each of infinitely many stages, is granted a fresh unbounded but finite reprieve.

**Definition 2.5 (Refinement).** For survival games $G, H$, the game $G \ast H$ (*$G$ refined by $H$*) has moments $\mathrm{Lex}(\mathrm{Mom}(G) \times \mathrm{Mom}(H))$: each moment of $G$ is replaced by an entire copy of the schedule of $H$. The **$\omega$-refinement** is $R(G) := G \ast F$.

**Theorem 2.6 (Refinement law).** $\mathrm{val}(G \ast H) = \mathrm{val}(H)\cdot \mathrm{val}(G)$; in particular $\mathrm{val}(R(G)) = \omega \cdot \mathrm{val}(G)$.

*Proof.* The lexicographic order type of a product is the product of the order types with the significant factor on the right: $\mathrm{type}(\mathrm{Lex}(A\times B)) = \mathrm{type}(B)\cdot\mathrm{type}(A)$. Take $A = \mathrm{Mom}(G)$, $B = \mathrm{Mom}(H)$, and specialise $H = F$, $\mathrm{val}(F)=\omega$. $\square$

**Proposition 2.7 (Refinement never shortens a life).** If $1 \le \mathrm{val}(H)$ then $\mathrm{val}(G) \le \mathrm{val}(G\ast H)$.

*Proof.* $\mathrm{val}(G) = 1\cdot \mathrm{val}(G) \le \mathrm{val}(H)\cdot\mathrm{val}(G)$, using weak monotonicity of ordinal multiplication in the left factor. $\square$

Proposition 2.7 is stated with a weak inequality on purpose. Theorem 7.2 below shows the strict version is false.

---

## 3. The finite refinement hierarchy

**Definition 3.1.** Set $R^0(G) := G$ and $R^{k+1}(G) := R(R^k(G))$.

**Theorem 3.2 (Iterated refinement law).** For every $k \in \mathbb{N}$ and every game $G$,
$$\mathrm{val}(R^k(G)) = \omega^k\cdot \mathrm{val}(G).$$

*Proof.* Induction on $k$. The base case is trivial. For the step, Theorem 2.6 and the induction hypothesis give $\mathrm{val}(R^{k+1}(G)) = \omega\cdot(\omega^k\cdot\mathrm{val}(G)) = (\omega\cdot\omega^k)\cdot\mathrm{val}(G)$ by associativity, and $\omega \cdot \omega^k = \omega^{1+k} = \omega^{k+1}$ since $1 + k = k+1$ for finite $k$. $\square$

The last step is the only place where finiteness of $k$ is used, and it is exactly the place where the transfinite version of this hierarchy would need care: for infinite $\delta$, $1 + \delta = \delta$, and the multiplier collapses. This is the germ of Theorem 7.2.

**Corollary 3.3 (Value of the $k$-fold refined finite game).** $\mathrm{val}(R^k(F)) = \omega^{k+1}$.

*Proof.* Theorem 3.2 with $\mathrm{val}(F) = \omega$: $\omega^k\cdot\omega = \omega^{k+1}$. $\square$

**Theorem 3.4 (Strictness of the hierarchy).** If $j < k$ then $\mathrm{val}(R^j(F)) < \mathrm{val}(R^k(F))$, and consequently
$$\neg\,\bigl(R^j(F) \Vdash \mathrm{val}(R^k(F))\bigr):$$
a $j$-fold refined Mortal cannot force survival to the round at which a $k$-fold refined Mortal dies.

*Proof.* By Corollary 3.3 the two values are $\omega^{j+1}$ and $\omega^{k+1}$. Exponentiation with base $\omega > 1$ is strictly increasing in the exponent, and $j+1 < k+1$. The forcing statement follows from Lemma 2.3. $\square$

It bears emphasis that all games in this hierarchy have countably many moments; the strictness is purely a statement about order structure, invisible to cardinality.

---

## 4. Bounded-depth clocks

**Definition 4.1 ($k$-fold clock).** Let $P$ denote the point game. The **$k$-fold lexicographic natural-number clock** is $C_k := R^k(P)$. Concretely $\mathrm{Mom}(C_k) \cong \mathbb{N}^k$ in dictionary order with the leftmost coordinate most significant (and $C_0$ is the point game).

**Proposition 4.2.** $\mathrm{val}(C_k) = \omega^k$.

*Proof.* Theorem 3.2 with $\mathrm{val}(P)=1$. $\square$

**Proposition 4.3 (The clock reads Cantor normal form).** The rank function of $C_k$ is
$$\mathrm{rank}(n_1,\dots,n_k) = \omega^{k-1}n_1 + \omega^{k-2}n_2 + \cdots + \omega\, n_{k-1} + n_k,$$
and it is an order isomorphism from $\mathbb{N}^k$ (dictionary order) onto $\mathsf{Ord}(\omega^k)$.

*Proof.* Both sides are strictly monotone and surjective onto the ordinals below $\omega^k$: uniqueness of the Cantor normal form of an ordinal below $\omega^k$ with exponents $< k$ gives injectivity and surjectivity, and monotonicity is the standard comparison of normal forms coefficient by coefficient from the top. $\square$

So $C_k$ is a base-$\omega$ odometer with $k$ digits, and the following theorem determines exactly what such an odometer can time.

**Theorem 4.4 (Clock characterisation, general form).** For any survival game $G$ and ordinal $o$,
$$\mathrm{val}(G)\le o \iff \text{there is a strictly increasing map } \mathrm{Mom}(G)\hookrightarrow \mathsf{Ord}(o).$$

*Proof.* ($\Leftarrow$) An order embedding of well-orders never increases order type: $\mathrm{type}(\mathrm{Mom}(G)) \le \mathrm{type}(\mathsf{Ord}(o)) = o$. ($\Rightarrow$) If $\mathrm{val}(G) \le o$ then, comparing order types, the schedule of $G$ is order-isomorphic to a proper initial segment of, or all of, $\mathsf{Ord}(o)$; the isomorphism onto that initial segment is the required embedding. $\square$

**Theorem 4.5 (Bounded-depth clocks).** For every survival game $G$ and every $k \in \mathbb{N}$:
$$\mathrm{val}(G) \le \omega^k \iff \mathrm{Mom}(G) \text{ order-embeds into } \mathrm{Mom}(C_k).$$

*Proof.* Combine Theorem 4.4 with Propositions 4.2 and 4.3, which identify $\mathrm{Mom}(C_k)$ with $\mathsf{Ord}(\omega^k)$. $\square$

**Corollary 4.6 ($k = 1$).** If $\mathrm{Mom}(G)$ order-embeds into $\mathbb{N}$ then $\mathrm{val}(G)\le\omega$.

*Proof.* The map $n \mapsto (\ast, n)$ embeds $\mathbb{N}$ order-faithfully into $\mathrm{Mom}(C_1) = \mathrm{Lex}(\{\ast\}\times\mathbb{N})$; compose and apply Theorem 4.5 with $k=1$. $\square$

Corollary 4.6 is the familiar statement that a life whose moments can be enumerated in increasing order by natural numbers cannot exceed $\omega$; Theorem 4.5 is the exact $k$-digit generalisation, and Theorem 4.4 the exact general one. The content of the converse direction is that the ceilings are *attained*: there is no gap between what a bounded-depth clock permits and what a Mortal can realise on it.

---

## 5. The limit of the finite depths

**Definition 5.1 (Limit clock).** The **limit clock** $L$ has moments
$$\mathrm{Mom}(L) := \sum\nolimits^{\mathrm{lex}}_{k\in\mathbb{N}} \mathrm{Mom}(C_k) = \{\langle k, a\rangle : k \in \mathbb{N},\ a \in \mathrm{Mom}(C_k)\},$$
ordered by: $\langle i,a\rangle < \langle j,b\rangle$ iff $i<j$, or $i=j$ and $a<b$ in $C_i$.

Two things must be established: that this order is a well-order at all (dependent lexicographic sums of well-orders are well-ordered, but the fact needs a witness we can compute with), and that its type is $\omega^\omega$. A single device does both.

**Definition 5.2 (Key).** $\displaystyle \mathrm{key}\langle k, a\rangle := \omega^k + \mathrm{rank}_{C_k}(a).$

**Lemma 5.3 (Key bound).** $\mathrm{key}\langle k,a\rangle < \omega^{k+1}$; consequently every key is $< \omega^\omega$.

*Proof.* By Proposition 4.2 and the definition of rank, $\mathrm{rank}_{C_k}(a) < \omega^k$, so
$$\mathrm{key}\langle k,a\rangle < \omega^k + \omega^k = \omega^k\cdot 2 \le \omega^k\cdot\omega = \omega^{k+1},$$
using $2 \le \omega$ and monotonicity of multiplication in the right factor. Since $\omega^{k+1} < \omega^\omega$ for all finite $k$, all keys lie below $\omega^\omega$. $\square$

**Lemma 5.4 (Key monotonicity).** $\mathrm{key}$ is strictly increasing on $\mathrm{Mom}(L)$.

*Proof.* Two cases. If $i < j$, then $\mathrm{key}\langle i,a\rangle < \omega^{i+1} \le \omega^{j} \le \omega^j + \mathrm{rank}(b) = \mathrm{key}\langle j,b\rangle$, where the middle inequality uses $i+1\le j$ and monotonicity of $\omega^{(-)}$, and the last uses $x \le x + y$. If $i = j$ and $a < b$, then $\mathrm{rank}(a) < \mathrm{rank}(b)$ and adding $\omega^i$ on the left preserves strict inequality on the right argument. $\square$

**Corollary 5.5 (Well-foundedness).** The order on $\mathrm{Mom}(L)$ is well-founded, hence a well-order.

*Proof.* Lemma 5.4 exhibits the order as a subrelation of the pullback along $\mathrm{key}$ of the well-founded order on ordinals; pullbacks of well-founded relations along any map are well-founded, and subrelations of well-founded relations are well-founded. Linearity and transitivity of the lexicographic order are immediate. $\square$

**Theorem 5.6 (The limit clock).** $\mathrm{val}(L) = \omega^\omega$.

*Proof.* ($\le$) By Lemma 5.3 the key is a map $\mathrm{Mom}(L) \to \mathsf{Ord}(\omega^\omega)$, and by Lemma 5.4 it is strictly increasing; Theorem 4.4 gives $\mathrm{val}(L)\le \omega^\omega$. ($\ge$) For each $k$, the fibre map $a\mapsto\langle k,a\rangle$ embeds $\mathrm{Mom}(C_k)$ order-faithfully into $\mathrm{Mom}(L)$, so $\omega^k = \mathrm{val}(C_k)\le\mathrm{val}(L)$ by Theorem 4.4. As $\lambda \mapsto \omega^{\lambda}$ is normal (continuous and strictly increasing) and $\omega$ is a limit, $\omega^\omega = \sup_k \omega^k \le \mathrm{val}(L)$. $\square$

**Corollary 5.7 (Strictly above every depth).** $\mathrm{val}(R^k(F)) = \omega^{k+1} < \omega^\omega = \mathrm{val}(L)$ for every $k\in\mathbb{N}$; moreover $L \Vdash \omega^k$ for every $k$, while $\neg\,(L\Vdash \omega^\omega+1)$: the limit Mortal outlives every finite depth and dies exactly at $\omega^\omega$.

*Proof.* $k+1<\omega$ and strict monotonicity of $\omega^{(-)}$ give the strict inequality; the forcing statements are Definition 2.2 and Lemma 2.3 applied to $\mathrm{val}(L)=\omega^\omega < \omega^\omega+1$. $\square$

### 5.1 The general mechanism

The computation above is an instance of a general limit theorem for concatenated lives. Recall that an ordinal $o$ is **additively principal** if $o>0$ and $\beta,\gamma<o \Rightarrow \beta+\gamma<o$; the additively principal ordinals are exactly the ordinals $\omega^a$.

**Definition 5.8 (Concatenated chain).** Given games $A_0, A_1, A_2, \dots$, let $\Sigma A$ be the game with moments $\sum^{\mathrm{lex}}_{k}\mathrm{Mom}(A_k)$, i.e. the lives played one after another. Define the **landmarks** $\Lambda_0 := 0$, $\Lambda_{k+1} := \Lambda_k + \mathrm{val}(A_k)$ — the absolute starting time of the $k$-th life — and the key
$$\mathrm{key}_\Sigma\langle k,a\rangle := \Lambda_k + \mathrm{rank}_{A_k}(a).$$

**Lemma 5.9.** $\mathrm{key}_\Sigma$ is strictly increasing, so $\Sigma A$ is a well-ordered game, and $\mathrm{key}_\Sigma\langle k,a\rangle < \Lambda_{k+1}$.

*Proof.* $\mathrm{rank}_{A_k}(a) < \mathrm{val}(A_k)$ gives the displayed bound. If $i<j$ then $\mathrm{key}_\Sigma\langle i,a\rangle < \Lambda_{i+1}\le\Lambda_j\le \mathrm{key}_\Sigma\langle j,b\rangle$ since the landmarks are monotone ($\Lambda_k \le \Lambda_k + \mathrm{val}(A_k)$) and $x\le x+y$. If $i=j$ the ranks compare strictly. Well-foundedness follows as in Corollary 5.5. $\square$

**Lemma 5.10 (Landmarks stay below).** If $o$ is additively principal, $0<o$, and $\mathrm{val}(A_k)<o$ for all $k$, then $\Lambda_k<o$ for all $k$.

*Proof.* Induction: $\Lambda_0 = 0 < o$, and $\Lambda_{k+1} = \Lambda_k + \mathrm{val}(A_k) < o$ by additive principality. $\square$

**Theorem 5.11 (Limit theorem for concatenated lives).** Let $o$ be additively principal with $0<o$. If $\mathrm{val}(A_k)<o$ for every $k$ and the values are **cofinal** in $o$ (for every $p<o$ there is $k$ with $p<\mathrm{val}(A_k)$), then
$$\mathrm{val}(\Sigma A) = o.$$

*Proof.* ($\le$) By Lemmas 5.9 and 5.10 the key maps $\mathrm{Mom}(\Sigma A)$ strictly increasingly into $\mathsf{Ord}(o)$; apply Theorem 4.4. ($\ge$) If $\mathrm{val}(\Sigma A)<o$, cofinality supplies $k$ with $\mathrm{val}(\Sigma A)<\mathrm{val}(A_k)$, contradicting the fibre embedding $\mathrm{val}(A_k)\le\mathrm{val}(\Sigma A)$. $\square$

**Corollary 5.12.** Taking $A_k = C_k$ and $o=\omega^\omega$ (additively principal, values $\omega^k<\omega^\omega$ cofinal in $\omega^\omega$) recovers Theorem 5.6.

*Proof.* Cofinality: given $p<\omega^\omega$, normality of $\omega^{(-)}$ at the limit $\omega$ gives $c<\omega$ with $p<\omega^{c}$, and $c$ is some natural number $n$, so $p < \mathrm{val}(C_n)$. $\square$

Additive principality is not decoration. Without it the landmarks can reach or pass $o$ and the chain overshoots its own supremum; with it, the running total of all earlier lives is guaranteed to remain a legitimate time below $o$.

---

## 6. Structure theory

### 6.1 The value is a complete invariant

**Theorem 6.1 (Canonical clock).** Every survival game $G$ is order-isomorphic to $\mathsf{Ord}(\mathrm{val}(G))$, via $x\mapsto\mathrm{rank}(x)$.

*Proof.* The rank map is strictly increasing by definition of rank, and surjective onto the ordinals below the order type: every $\gamma < \mathrm{type}(\mathrm{Mom}(G))$ is the rank of a unique moment, namely the least moment whose set of predecessors has type $\gamma$. $\square$

**Theorem 6.2 (Completeness).** $\mathrm{val}(G) = \mathrm{val}(H)$ if and only if $\mathrm{Mom}(G)\cong\mathrm{Mom}(H)$ as ordered sets. Moreover every ordinal is the value of some game, so $\mathrm{val}$ is a surjection onto the ordinals.

*Proof.* ($\Rightarrow$) Compose the isomorphism of Theorem 6.1 for $G$ with the inverse of the one for $H$, using $\mathrm{val}(G)=\mathrm{val}(H)$. ($\Leftarrow$) Isomorphic well-orders have equal type. Surjectivity: take the game with moments $\mathsf{Ord}(o)$. $\square$

Theorem 6.2 licenses the whole approach: nothing about a survival game is lost in passing to its ordinal.

### 6.2 Concatenation and non-commutativity

**Definition 6.3.** $G \frown H$ is the game with moments $\mathrm{Mom}(G)\sqcup_{\mathrm{lex}}\mathrm{Mom}(H)$: all of $G$'s moments, in order, then all of $H$'s.

**Theorem 6.4.** $\mathrm{val}(G\frown H) = \mathrm{val}(G)+\mathrm{val}(H)$.

*Proof.* The order type of an ordered disjoint union is the sum of the types. $\square$

**Theorem 6.5 (Non-commutativity of lives).** With $P$ the point game and $F$ the finite game,
$$\mathrm{val}(F\frown P) = \omega+1 \neq \omega = 1+\omega = \mathrm{val}(P\frown F).$$
An extra moment appended *after* an $\omega$-life is a genuine gain; the same moment prefixed *before* it is invisible.

*Proof.* Theorem 6.4 and the ordinal identities $1+\omega=\omega$ (absorption on the left) and $\omega<\omega+1$. $\square$

### 6.3 Refinement stability

**Definition 6.6.** An ordinal $o$ is **refinement stable** when $\omega\cdot o=o$, i.e. when a further $\omega$-refinement of a game of value $o$ buys nothing: by Theorem 2.6, $\mathrm{val}(R(G)) = \mathrm{val}(G)$ iff $\mathrm{val}(G)$ is refinement stable.

**Theorem 6.7 (Stability criterion in the pure scale).** For every ordinal $a$,
$$\omega^a \text{ is refinement stable} \iff \omega\le a.$$

*Proof.* $\omega\cdot\omega^a=\omega^{1+a}$, so stability says $\omega^{1+a}=\omega^{a}$, which by injectivity of the strictly increasing map $\lambda\mapsto\omega^\lambda$ is equivalent to $1+a=a$. If $a<\omega$, write $a=n$ finite: $1+n=n+1\neq n$. If $\omega\le a$ then $1+a=a$ by left absorption. $\square$

**Corollary 6.8.** Every finite depth value $\omega^{k+1}$ is unstable — refinement genuinely helps there — while $\omega^\omega$ is stable.

*Proof.* $\omega^{k+1}<\omega$ fails to satisfy $\omega \le k+1$; and $\omega\le\omega$. $\square$

---

## 7. A negative result: refinement is not always a gain

Proposition 2.7 says refinement never hurts. The natural strengthening is that it always strictly helps whenever the refining clock is nontrivial. It is false, and the limit clock is the counterexample.

**Theorem 7.1 (Fixed point).** $\mathrm{val}(R(L)) = \mathrm{val}(L)$, i.e. $\omega\cdot\omega^\omega = \omega^\omega$.

*Proof.* $\omega\cdot\omega^\omega = \omega^{1+\omega} = \omega^{\omega}$ since $1+\omega=\omega$. $\square$

**Theorem 7.2 (Refutation of strict refinement).** It is **not** the case that for all games $G,H$ with $0<\mathrm{val}(G)$ and $1<\mathrm{val}(H)$ one has $\mathrm{val}(G)<\mathrm{val}(G\ast H)$.

*Proof.* Take $G=L$ and $H=F$. Then $\mathrm{val}(L)=\omega^\omega>0$ and $\mathrm{val}(F)=\omega>1$, while $\mathrm{val}(L\ast F) = \omega\cdot\omega^\omega = \omega^\omega = \mathrm{val}(L)$ by Theorems 2.6 and 7.1. $\square$

The formal cause is that ordinal multiplication is only weakly monotone in its left factor. The structural cause is more illuminating: a schedule that already contains, cofinally, blocks of every finite base-$\omega$ depth is unchanged, up to isomorphism, by the insertion of one more layer of subdivision. Refinement's factor of $\omega$ is real at every finite depth and disappears exactly at the additively principal ordinals with infinite exponent, which is precisely the content of Theorem 6.7. Thus the hierarchy theorem, the limit theorem, and the refutation are three faces of the single identity $1+a=a \iff \omega \le a$.

---

## 8. A monotone transfinite machine with closure ordinal exactly $\omega^2$

We now realise a survival game as a running computation. Fix the bounded-nondeterministic game $N$ with $\mathrm{val}(N)=\omega^2$ (Definition 2.4).

**Definition 8.1 (Cells and step).** The **cells** are the moments of $N$. For a set $S$ of cells put
$$\mathrm{step}(S) := \{x : \forall y<x,\ y\in S\}$$
— a cell switches on once all strictly earlier cells are on. $\mathrm{step}$ is monotone with respect to inclusion.

**Definition 8.2 (Stages).** By recursion on ordinals,
$$\mathrm{stage}(\alpha) := \mathrm{step}\Bigl(\bigcup_{\beta<\alpha}\mathrm{stage}(\beta)\Bigr).$$
This is a legitimate definition by well-founded recursion; it packages the successor rule and the limit rule in a single clause. The **arrival time** of a cell is $\mathrm{arr}(x) := \mathrm{rank}_N(x) < \omega^2$.

**Theorem 8.3 (Closed form of the stages).** For every ordinal $\alpha$ and every cell $x$,
$$x\in\mathrm{stage}(\alpha) \iff \mathrm{arr}(x)\le\alpha.$$

*Proof.* Induction on $\alpha$. Note first the elementary equivalence $\mathrm{arr}(x)\le\alpha \iff \forall y<x,\ \mathrm{arr}(y)<\alpha$: left to right is monotonicity of rank; right to left, if $\mathrm{arr}(x)>\alpha$ then, since $\alpha<\omega^2$ and every ordinal below $\omega^2$ is the arrival time of a (unique) cell, there is $y$ with $\mathrm{arr}(y)=\alpha$, and $y<x$, contradicting $\mathrm{arr}(y)<\alpha$. Now if $x\in\mathrm{stage}(\alpha)$ then every $y<x$ lies in some $\mathrm{stage}(\beta)$ with $\beta<\alpha$, whence $\mathrm{arr}(y)\le\beta<\alpha$ by the induction hypothesis, so $\mathrm{arr}(x)\le\alpha$. Conversely if $\mathrm{arr}(x)\le\alpha$ and $y<x$, then $\mathrm{arr}(y)<\alpha$ and the induction hypothesis at $\mathrm{arr}(y)$ puts $y\in\mathrm{stage}(\mathrm{arr}(y))$, one of the stages unioned; so $x\in\mathrm{stage}(\alpha)$. $\square$

**Corollary 8.4 (Explicit successor and limit rules).** $\mathrm{stage}(\alpha+1)=\mathrm{step}(\mathrm{stage}(\alpha))$, and at every $\alpha$ (in particular at limits) $\mathrm{stage}(\alpha)=\mathrm{step}(\bigcup_{\beta<\alpha}\mathrm{stage}(\beta))$. The stages are monotone in $\alpha$.

*Proof.* The second is Definition 8.2. For the first, unwind both sides through Theorem 8.3: $x \in \mathrm{stage}(\alpha+1)$ iff $\mathrm{arr}(x)\le\alpha+1$ iff every $y<x$ has $\mathrm{arr}(y)<\alpha+1$, i.e. $\mathrm{arr}(y)\le\alpha$, i.e. $y\in\mathrm{stage}(\alpha)$. Monotonicity is immediate from the closed form. $\square$

**Definition 8.5.** $\alpha$ is **terminal** when $\mathrm{stage}(\alpha+1)=\mathrm{stage}(\alpha)$: one further step yields nothing new.

**Theorem 8.6 (Exact closure ordinal).** $\omega^2$ is the least terminal time. Explicitly: (i) no $\alpha<\omega^2$ is terminal; (ii) $\omega^2$ is terminal.

*Proof.* (i) Let $\alpha<\omega^2$. Since $\omega^2$ is additively principal and $1<\omega^2$, also $\alpha+1<\omega^2$, so there is a cell $x$ with $\mathrm{arr}(x)=\alpha+1$. By Theorem 8.3, $x\in\mathrm{stage}(\alpha+1)$ but $x\notin\mathrm{stage}(\alpha)$, so the stages differ. (ii) Every cell has arrival time $<\omega^2\le\omega^2$, so $\mathrm{stage}(\omega^2)$ and likewise $\mathrm{stage}(\omega^2+1)$ are the set of all cells. $\square$

**Theorem 8.7 (Faithfulness).** The map $\mathrm{arr}$ is a strictly increasing bijection from the cells onto the ordinals below $\omega^2$; hence the reachable-time well-order of the machine is order-isomorphic to the moments of $N$, and the least terminal time equals $\mathrm{val}(N)$.

*Proof.* Strict monotonicity and injectivity are properties of rank; surjectivity onto $\mathsf{Ord}(\omega^2)$ is Theorem 6.1 applied to $N$, whose value is $\omega^2$. A strictly monotone surjection of linear orders is an order isomorphism. Combining with Theorem 8.6 gives $\min\{\alpha : \alpha \text{ terminal}\} = \omega^2 = \mathrm{val}(N)$. $\square$

Theorem 8.7 is the sense in which the machine is not merely *some* system with closure ordinal $\omega^2$ but a faithful realisation of the game: its clock of reachable times is literally the game's schedule, and the point at which the computation stalls is the point at which Mortal dies.

---

## 9. Algorithms

Three computational procedures accompany the theory; all operate on ordinals below $\varepsilon_0$ in Cantor normal form, represented as strictly decreasing lists of (exponent, coefficient) pairs with exponents recursively of the same shape.

**(A) Cantor normal form arithmetic.** Comparison is lexicographic on the term list. Addition $\alpha+\beta$ deletes from $\alpha$ every term whose exponent is strictly below the leading exponent of $\beta$ (this is left absorption made concrete), merges an equal leading exponent by adding coefficients, and appends $\beta$. Multiplication distributes over the terms of the right factor: a finite term $c$ scales the leading coefficient of the left factor and re-appends its tail, while an infinite term $\omega^e c$ produces $\omega^{(\text{lead exponent of }\alpha)+e}c$. Each operation is linear in the number of terms up to recursive exponent comparisons; for the ordinals occurring in this paper all term lists have length $O(k)$.

**(B) Clock reading and its inverse.** The rank map of the $k$-fold clock, $(n_1,\dots,n_k)\mapsto\sum_i \omega^{k-i}n_i$, converts a moment into an ordinal in $O(k)$ operations, and Cantor normal form uniqueness converts back. This is exactly a base-$\omega$ positional notation, and it makes the embeddings of Theorems 4.4–4.5 executable on concrete data.

**(C) Key evaluation and monotonicity certification.** For the limit clock, $\mathrm{key}\langle k,a\rangle=\omega^k+\mathrm{rank}(a)$ is evaluated in $O(k)$ and, by Lemmas 5.3 and 5.4, certifies both the well-foundedness of the dependent lexicographic order and the bound $\mathrm{val}(L)\le\omega^\omega$. Comparing two keys is a comparison of normal forms; the certification therefore reduces an infinitary order-theoretic fact to finite symbolic arithmetic on any finite sample of moments.

**(D) Stage evaluation for the transfinite machine.** Naively, computing $\mathrm{stage}(\alpha)$ requires recursion through all $\beta<\alpha$. Theorem 8.3 replaces this with the $O(1)$ membership test $\mathrm{arr}(x)\le\alpha$, converting a transfinite recursion into an ordinal comparison; the non-terminality witness at $\alpha$ is obtained by decoding the ordinal $\alpha+1<\omega^2$ into the unique cell of that arrival time.

---

## 10. Discussion

**Order type, not cardinality.** Every game in this paper has countably many moments. Every strict inequality proved is therefore invisible to counting and visible only to order. The model is designed to make this unavoidable: forcing survival to $\alpha$ *is* the inequality $\alpha\le\mathrm{val}(G)$, so the strategic hierarchy and the ordinal hierarchy are the same object (Theorem 6.2).

**One identity behind three theorems.** The finite hierarchy is strict because $1+k=k+1$ for finite $k$; the limit is stable because $1+\omega=\omega$; and refinement stability of $\omega^a$ is exactly $1+a=a$. The interesting content of Theorems 3.2, 6.7 and 7.1 is a single fact about left absorption viewed at three different scales. This also explains why the naive strictness conjecture (Theorem 7.2) is not merely false but false *at a computable boundary*: the failure set is precisely $\{\omega^a : \omega \le a\}$ within the pure scale.

**Keys as certificates.** Both limit constructions are handled by an explicit key function rather than an abstract appeal to the theory of well-orders. This is a methodological point worth stating: a strictly monotone map into the ordinals is simultaneously (i) a proof of well-foundedness, (ii) an upper bound on order type, and (iii) an executable procedure for comparing elements. The dependent lexicographic sum is a case where the abstract fact is standard but the usable witness is not automatic, and the landmark key $\Lambda_k + \mathrm{rank}(a)$ supplies it in general (Lemma 5.9).

**Additive principality as the right hypothesis.** Theorem 5.11 isolates why $\omega^\omega$ appears: it is the least additively principal ordinal above all $\omega^k$. The theorem's two hypotheses are complementary and both necessary — cofinality forces the value up to $o$, additive principality prevents the accumulated landmarks from pushing it past $o$.

**Closure ordinals.** Theorem 8.6 computes a closure ordinal *exactly*, in both directions, which is the interesting half of such statements: an upper bound alone leaves open that the system stalls earlier. The proof of non-terminality below $\omega^2$ uses additive principality of $\omega^2$ once more, this time to guarantee that $\alpha+1$ is still a legitimate arrival time. The system's step operator is, however, permitted to consult the entire earlier configuration; restricting to more finitely presented step operators is the natural next question (see below).

**Limitations.** The refinement tower here is indexed by natural numbers, and the limit stage is taken once. A tower indexed by arbitrary ordinals, with the dependent lexicographic sum at limit levels, is the natural extension; the arithmetic already suggests the answer, but the construction requires a transfinite recursion at the level of types rather than of ordinals. Similarly, the stability criterion is proved inside the scale $\omega^a$; the general criterion should read off the Cantor normal form.

---

## 11. Future directions

1. **The transfinite refinement tower and $\varepsilon_0$.** Extend $R^k$ to a tower indexed by ordinals: refine by $\omega$ at successors and take the dependent lexicographic sum at limits. The conjecture is that level $\delta$ of the tower over the finite game has value $\omega^{\delta+1}$ for every $\delta$ below the first fixed point of $\delta\mapsto\omega^\delta$, and that the tower's own limit is exactly $\varepsilon_0$. The key insight is that the bound proved here at level $k$ comes entirely from the key $\omega^k + \mathrm{rank}(a)$, and that key is definable uniformly in the level; replacing the natural number $k$ by an ordinal $\delta$ turns the finite Cantor-normal-form argument into the general one, so no new combinatorics is needed — only a type-level transfinite recursion. The general limit step is already available in the form of Theorem 5.11.

2. **Refinement stability as a Cantor normal form tail condition.** Theorem 6.7 settles stability inside the pure scale $\omega^a$. The general statement should be: $\omega\cdot o = o$ if and only if $o=0$ or every Cantor exponent of $o$ is infinite. The key insight is that stability is a *local* condition on the exponents rather than a size condition: multiplication by $\omega$ shifts each Cantor exponent $e$ to $1+e$, and $1+e=e$ is equivalent to $\omega\le e$, so stability is a tail condition.

3. **A clockability gap for finitely presented steps.** The machine of Section 8 has closure ordinal exactly $\omega^2$, but its step operator was allowed to consult the whole earlier configuration. Restricting to step operators presented by a fixed finite amount of local data should make some ordinals unattainable as closure ordinals; the conjecture is that a genuine gap appears, and identifying the least such unattainable ordinal is the concrete target.

4. **Non-well-ordered schedules.** If Mortal is allowed a schedule that is merely linearly ordered, the Reaper's walk may fail to be defined; a natural relaxation replaces order type by the ordinal of the well-founded part, and asks how much of the theory survives.

5. **Quantitative forcing.** The forcing relation here is a plain inequality. Enriching it with resource bounds — for instance, requiring Mortal to name each moment within a fixed notation system — would connect the hierarchy to ordinal notation systems and proof-theoretic ordinals, where $\omega^\omega$ and $\varepsilon_0$ have independent significance.

---

## 12. Conclusion

The survival game reduces a question about outliving an adversary to a question about order types, faithfully and without loss: the survival value is a complete invariant and every ordinal occurs. Within that dictionary, structural refinement — subdividing every moment into an infinite sequence of finer moments — is worth exactly one factor of $\omega$, and iterating it produces a strict hierarchy $\omega, \omega^2, \omega^3,\dots$ whose members are exactly the ordinals timed by base-$\omega$ odometers of bounded digit length, with the ceilings attained. Stacking all finite depths gives exactly $\omega^\omega$, by way of a key function that doubles as a well-foundedness certificate for the dependent lexicographic order, and this computation is an instance of a general limit theorem for concatenated lives over additively principal ordinals. At $\omega^\omega$ the refinement operator becomes idempotent, refuting the natural conjecture that refinement always strictly helps, and the exact boundary of that collapse is the absorption identity $1+a=a$. Finally, the same ordinals govern computation: a monotone transfinite transition system built on the $\omega^2$-clock has closure ordinal exactly $\omega^2$, with its reachable-time well-order isomorphic to the game it realises. Length of life, order type, positional notation, and closure ordinal are, in this setting, four descriptions of one thing.
