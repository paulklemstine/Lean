# Tight Length Bounds for Distinguishing Experiments on Deterministic Moore Machines

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

We study the length of the shortest experiment that separates two behaviourally
inequivalent initial states of deterministic Moore machines over a common input alphabet
$A$ and a common observation type $O$. We give a complete, self-contained development of
three linked results. First, a product-automaton fixpoint argument on the increasing
chain of "distinguishable within $k$ steps" relations shows that inequivalent initial
states of machines with state sets $S$ and $T$ are separated by a word of length
$< |S| \cdot |T|$. Second, an abstract chain-stabilisation theorem for decreasing chains
of equivalence relations on a finite set — any such chain whose bottom level is already
non-trivial stabilises by index $|U| - 2$ — applied to the disjoint union $S \sqcup T$,
sharpens the bound to the linear estimate $|S| + |T| - 2$, which subsumes the quadratic
one. Third, we prove the linear bound extremal for *every* pair of state-set sizes by an
explicit two-parameter family over the unary alphabet: a saturating tail of $n$ states
raced against a cycle of $m$ states, whose first disagreement occurs at time exactly
$n + m - 2$. As consequences we obtain an explicit complete finite test suite — all words
of length at most $|S| + |T| - 2$, of cardinality at most $(|A| + 1)^{|S| + |T| - 2}$ —
and decidability of behavioural equivalence via a computable bounded-agreement recursion.
We complement these with a matching negative result: once the state set may be infinite,
every behaviour $A^* \to \mathbb{B}$ is realised by a machine, and consequently no fixed
finite test suite is complete. The resulting dichotomy identifies finiteness of the state
space as exactly the property that converts decidability into a bounded test plan.

**Keywords:** Moore machine, behavioural equivalence, distinguishing sequence, Moore
bound, partition refinement, finite test suite, conformance testing, Fine–Wilf
periodicity.

---

## 1. Introduction

### 1.1 The problem

A deterministic Moore machine is the simplest useful model of a reactive system: an
internal state, a deterministic reaction to each input symbol, and an observable output
attached to each state. Two initial states are *behaviourally equivalent* if no
experiment — no finite input word — produces different observations. Behavioural
equivalence is the semantic notion of "same system" for such models: it is exactly the
relation that must hold between a specification and a correct implementation.

The definition quantifies over infinitely many words. This raises the fundamental
question of black-box testing:

> If two initial states are *not* behaviourally equivalent, how long must a
> distinguishing experiment be?

Any bound $B(|S|, |T|)$ answers three questions at once. It makes equivalence decidable
(check all words of length $\le B$). It yields an explicit finite test suite for
conformance testing. And it quantifies the cost of black-box verification in terms of
structural size alone, with no reference to the machines' internal wiring.

### 1.2 Contributions

We develop the theory from first principles and establish:

1. **Product bound** (Theorem 3.6): inequivalent initial states admit a distinguishing
   word of length $< |S| \cdot |T|$, via a saturating fixpoint chain in $S \times T$.

2. **Abstract refinement stabilisation** (Theorem 4.1): a decreasing chain of equivalence
   relations on a finite set $U$, non-trivial at level $0$, stabilises at some index
   $\le |U| - 2$. The proof is a block-counting argument through a surjection between
   consecutive quotients.

3. **Moore bound** (Theorem 4.5): the previous result applied to the disjoint union
   $S \sqcup T$ gives the linear bound $|S| + |T| - 2$, and (Proposition 4.6) this
   subsumes the product bound since $n + m - 2 < nm$ for $n, m \ge 1$.

4. **Extremality for all sizes** (Theorem 5.4): an explicit unary two-parameter family
   attaining $|S| + |T| - 2$ for every pair of sizes; and the absence of any bound
   independent of the state counts (Corollary 5.6).

5. **Explicit complete test suite** (Theorem 6.3) of size at most
   $(|A| + 1)^{|S| + |T| - 2}$, together with decidability of equivalence (Theorem 3.9)
   from a computable bounded-agreement recursion.

6. **The infinite-state barrier and dichotomy** (Theorems 7.2, 7.3, 7.5): every
   behaviour is realised by an infinite-state machine, so no finite test suite is
   complete in general; a fixed suite $W_k$ is simultaneously complete over the whole
   class of machine pairs with $|S| + |T| - 2 \le k$ and incomplete for arbitrary
   behaviours.

### 1.3 Relation to classical automata theory

The linear bound is the Moore-machine analogue of the classical fact that inequivalent
states of a deterministic automaton are separated by a word of length below the number of
states, obtained by partition refinement. What we add here is (i) a fully abstract
formulation of the refinement engine, decoupled from machines, so that the same lemma
applies verbatim to any monotone refinement process; (ii) a *two-machine* statement with
the sharp constant $|S| + |T| - 2$, obtained by transporting the single-machine result
across the disjoint union; (iii) a general extremal family showing the constant is exact
for every pair of sizes, over a unary alphabet, where the phenomenon becomes a statement
about the interaction of a preperiod and a period; and (iv) the exact complementary
negative result delimiting the theory.

---

## 2. Preliminaries

Throughout, $A$ is a set of *input symbols* (the alphabet), $O$ is a set of
*observations*, and $A^*$ denotes the set of finite words over $A$, with $\varepsilon$
the empty word, $|w|$ the length of $w$, and $a \cdot w$ the word $w$ prefixed by $a$.

**Definition 2.1 (Moore machine).** A *deterministic Moore machine* over $(A, O)$ with
state set $S$ is a pair $M = (\delta, \lambda)$ with a total transition function
$\delta \colon S \times A \to S$ and an output function $\lambda \colon S \to O$.

We write $M.\mathrm{step}(s, a) = \delta(s,a)$ and $M.\mathrm{out}(s) = \lambda(s)$ when
we need to name the components of a particular machine.

**Definition 2.2 (Run and observation).** The *run* function
$\mathrm{run}_M \colon S \times A^* \to S$ is defined by recursion on the word:
$$\mathrm{run}_M(s, \varepsilon) = s, \qquad
\mathrm{run}_M(s, a \cdot w) = \mathrm{run}_M(\delta(s,a), w).$$
The *observation* of $s$ on $w$ is $\mathrm{obs}_M(s, w) = \lambda(\mathrm{run}_M(s,w))$.

Two immediate consequences, used constantly, are
$$\mathrm{obs}_M(s, \varepsilon) = \lambda(s), \qquad
\mathrm{obs}_M(s, a \cdot w) = \mathrm{obs}_M(\delta(s,a), w). \tag{2.1}$$
Equation (2.1) is the *coinductive unfolding*: the observation on a nonempty word is the
observation of the successor state on the tail. Every proof in this paper is, at bottom,
an exploitation of (2.1).

**Definition 2.3 (Behavioural equivalence).** Let $M$ be a machine with state set $S$ and
$N$ a machine with state set $T$, over the *same* $A$ and $O$. States $s \in S$ and
$t \in T$ are *behaviourally equivalent*, written $s \approx t$, if
$$\mathrm{obs}_M(s, w) = \mathrm{obs}_N(t, w) \quad \text{for all } w \in A^*.$$
A word $w$ with $\mathrm{obs}_M(s,w) \neq \mathrm{obs}_N(t,w)$ is a *distinguishing
experiment* (or *separating word*) for $s$ and $t$.

Note the deliberate generality: $M$ and $N$ may be different machines with different
state sets. The single-machine case is recovered by taking $M = N$.

**Definition 2.4 (Bounded distinguishability and agreement).** For $k \in \mathbb{N}$:
$$D_k(s,t) \;:\Longleftrightarrow\; \exists w \in A^*,\ |w| \le k \ \wedge\
\mathrm{obs}_M(s,w) \neq \mathrm{obs}_N(t,w),$$
$$E_k(s,t) \;:\Longleftrightarrow\; \forall w \in A^*,\ |w| \le k \Rightarrow
\mathrm{obs}_M(s,w) = \mathrm{obs}_N(t,w).$$
We call $D_k$ the *distinguishability level $k$* and $E_k$ the *agreement level $k$*.

**Lemma 2.5 (Duality).** $\neg D_k(s,t) \iff E_k(s,t)$.

*Proof.* Immediate: negating an existential over a conjunction yields a universal over an
implication. $\square$

---

## 3. The product bound

### 3.1 The recursion

**Lemma 3.1 (Base level).** $D_0(s,t) \iff \lambda_M(s) \neq \lambda_N(t)$.

*Proof.* A word of length $\le 0$ is $\varepsilon$, and
$\mathrm{obs}(s,\varepsilon) = \lambda(s)$. $\square$

**Lemma 3.2 (One-step unfolding).** For all $k$,
$$D_{k+1}(s,t) \iff \lambda_M(s) \neq \lambda_N(t) \ \ \vee\ \
\exists a \in A,\ D_k\big(\delta_M(s,a), \delta_N(t,a)\big).$$

*Proof.* ($\Rightarrow$) Let $w$ with $|w| \le k+1$ separate $s$ and $t$. If
$w = \varepsilon$ the outputs already differ. If $w = a \cdot v$ then $|v| \le k$ and, by
(2.1), $v$ separates $\delta_M(s,a)$ from $\delta_N(t,a)$.
($\Leftarrow$) If the outputs differ, $\varepsilon$ works. If $v$ with $|v| \le k$
separates the $a$-successors, then $a \cdot v$ has length $\le k+1$ and separates $s$ and
$t$ by (2.1). $\square$

Dualising through Lemma 2.5 gives the form used for computation:
$$E_0(s,t) \iff \lambda_M(s) = \lambda_N(t), \tag{3.1}$$
$$E_{k+1}(s,t) \iff \lambda_M(s) = \lambda_N(t) \ \wedge\
\forall a \in A,\ E_k\big(\delta_M(s,a), \delta_N(t,a)\big). \tag{3.2}$$

**Lemma 3.3 (Monotonicity).** If $k \le l$ and $D_k(s,t)$ then $D_l(s,t)$. Dually, if
$k \le l$ and $E_l(s,t)$ then $E_k(s,t)$.

*Proof.* A witness of length $\le k$ has length $\le l$. $\square$

**Lemma 3.4 (Constant observation).** If $\lambda_M(s') = \lambda_N(t')$ for all
$s' \in S$, $t' \in T$, then $\mathrm{obs}_M(s',w) = \mathrm{obs}_N(t',w)$ for all $w$
and all $s', t'$; in particular no pair is distinguishable.

*Proof.* Induction on $w$ using (2.1), generalising over the states. $\square$

### 3.2 Saturation

The crucial structural property is that the chain $(D_k)_k$, once it stalls, is frozen
forever. This is what allows an arbitrarily long distinguishing word to be replaced by a
short one.

**Theorem 3.5 (Saturation).** Suppose that for all $s' \in S$, $t' \in T$,
$$D_{k+1}(s',t') \Rightarrow D_k(s',t').$$
Then for every $j \in \mathbb{N}$ and all $s', t'$:
$$D_{k+j}(s',t') \Rightarrow D_k(s',t').$$

*Proof.* First one proves, by induction on $j$, the "shifted" statement
$$D_{k+j+1}(s',t') \Rightarrow D_{k+j}(s',t') \quad \text{for all } s',t'.$$
The base case $j = 0$ is the hypothesis. For the inductive step, assume the statement at
level $j$ and let $D_{(k+j+1)+1}(s',t')$. By Lemma 3.2 either $\lambda_M(s') \neq
\lambda_N(t')$ — in which case $\varepsilon$ already witnesses $D_{k+j+1}(s',t')$ — or
there is $a$ with $D_{k+j+1}$ holding of the $a$-successors, which by the induction
hypothesis gives $D_{k+j}$ of the $a$-successors, and Lemma 3.2 again yields
$D_{k+j+1}(s',t')$.

The theorem now follows by a second induction on $j$: $D_{k+(j+1)} = D_{(k+j)+1}$ implies
$D_{k+j}$ by the shifted statement, and then $D_k$ by the induction hypothesis. $\square$

### 3.3 The bound

**Theorem 3.6 (Product bound).** Let $S$ and $T$ be finite. If $s \in S$ and $t \in T$
are *not* behaviourally equivalent, then there is $w \in A^*$ with
$$|w| < |S| \cdot |T| \quad\text{and}\quad \mathrm{obs}_M(s,w) \neq \mathrm{obs}_N(t,w).$$

*Proof.* Put $n = |S| \cdot |T|$ and let $\mathcal{D}_k = \{(x,y) \in S \times T :
D_k(x,y)\}$, a subset of the finite set $S \times T$. By Lemma 3.3 the chain is
increasing, and $|\mathcal{D}_k| \le |S \times T| = n$ for all $k$.

*The chain is nonempty at level $0$.* If $\lambda_M(x) = \lambda_N(y)$ for all $x,y$ then
Lemma 3.4 makes $s$ and $t$ equivalent, contrary to hypothesis. So some pair
$(x_0, y_0)$ has $\lambda_M(x_0) \neq \lambda_N(y_0)$, i.e. $\mathcal{D}_0 \neq
\emptyset$ by Lemma 3.1.

*Stabilisation occurs before index $n$.* Suppose not: for every $k < n$ there are
$x, y$ with $D_{k+1}(x,y)$ but $\neg D_k(x,y)$, so $\mathcal{D}_k \subsetneq
\mathcal{D}_{k+1}$ and hence $|\mathcal{D}_k| < |\mathcal{D}_{k+1}|$. Combined with
$|\mathcal{D}_0| \ge 1$, an induction gives $|\mathcal{D}_k| \ge k+1$ for all $k \le n$;
taking $k = n$ contradicts $|\mathcal{D}_n| \le n$. Therefore there is $k < n$ with
$$\forall x, y,\quad D_{k+1}(x,y) \Rightarrow D_k(x,y).$$

*Collapse the witness.* Since $s \not\approx t$, some word $w$ separates them, so
$D_{k+|w|}(s,t)$ by Lemma 3.3. Theorem 3.5 yields $D_k(s,t)$: there is $v$ with
$|v| \le k < n$ separating $s$ and $t$. $\square$

### 3.4 Finite test suite and decidability

**Theorem 3.7 (Finite test characterisation).** For finite $S$ and $T$,
$$s \approx t \iff \big(\forall w \in A^*,\ |w| < |S|\cdot|T| \Rightarrow
\mathrm{obs}_M(s,w) = \mathrm{obs}_N(t,w)\big).$$

*Proof.* ($\Rightarrow$) trivial. ($\Leftarrow$) If $s \not\approx t$, Theorem 3.6
produces a separating word of length $< |S| \cdot |T|$, contradicting the hypothesis.
$\square$

**Corollary 3.8.** If $|S| \cdot |T| > 0$ then $s \approx t \iff
E_{|S| \cdot |T| - 1}(s,t)$.

**Theorem 3.9 (Decidability).** Let $A$ be finite, $O$ have decidable equality, and $S$,
$T$ be finite and nonempty. Then behavioural equivalence of $s$ and $t$ is decidable.

*Proof.* The predicate $E_k(x,y)$ is decidable by recursion on $k$: the base case is the
decidable equality test $\lambda_M(x) = \lambda_N(y)$ by (3.1), and the successor case is
a conjunction of that test with a *finite* conjunction over $a \in A$ of the decidable
predicate $E_k$ at the successors by (3.2). Since $|S| \cdot |T| > 0$, Corollary 3.8
reduces $s \approx t$ to $E_{|S|\cdot|T| - 1}(s,t)$. $\square$

The recursion in Theorem 3.9 is not merely a decidability argument; it is a working
algorithm (Algorithm 1 in §8), and the dual recursion (3.2) evaluated in a table indexed
by $S \times T$ is the standard $O(|A| \cdot |S| \cdot |T|)$ partition-refinement
equivalence checker.

---

## 4. The Moore bound: from quadratic to linear

The product bound is not optimal. The improvement comes from replacing the *pair*
viewpoint by the *partition* viewpoint, and it is convenient to isolate the combinatorics
in a lemma that mentions no machines at all.

### 4.1 The abstract engine

**Theorem 4.1 (Refinement stabilisation).** Let $U$ be a finite set and let
$R_0, R_1, R_2, \dots$ be equivalence relations on $U$ with $R_{k+1} \subseteq R_k$ for
all $k$, and suppose $R_0$ is non-trivial: there exist $x, y \in U$ with
$\neg R_0(x,y)$. Then there exists $k \le |U| - 2$ with
$$\forall x, y \in U,\quad R_k(x,y) \Rightarrow R_{k+1}(x,y),$$
i.e. $R_k = R_{k+1}$.

*Proof.* For $x \in U$ write $[x]_k = \{y \in U : R_k(x,y)\}$ for its $R_k$-class, and
note the standard fact $[x]_k = [y]_k \iff R_k(x,y)$, which uses reflexivity, symmetry
and transitivity. Let $\Pi_k = \{[x]_k : x \in U\}$ be the level-$k$ partition and
$b_k = |\Pi_k|$ its block count.

Define the *saturation operator* $G_k$ sending a subset $C \subseteq U$ to
$G_k(C) = \{z \in U : \exists y \in C,\ R_k(z,y)\}$. The key identity is
$$G_k\big([x]_{k+1}\big) = [x]_k \qquad \text{for all } x \in U. \tag{4.1}$$
Indeed, if $z$ is $R_k$-related to some $y$ with $R_{k+1}(x,y)$, then $R_k(x,y)$ by
monotonicity and hence $R_k(x,z)$ by transitivity and symmetry; conversely $x$ itself
lies in $[x]_{k+1}$, so any $z$ with $R_k(x,z)$ is in the saturation.

Identity (4.1) says $\Pi_k = G_k(\Pi_{k+1})$, the image of the level-$(k+1)$ partition
under $G_k$; in particular $b_k \le b_{k+1}$.

*Proper refinement strictly increases the block count.* Suppose the chain is not stable
at $k$: there are $x, y$ with $R_k(x,y)$ but $\neg R_{k+1}(x,y)$. Then $[x]_{k+1} \neq
[y]_{k+1}$ are two distinct elements of $\Pi_{k+1}$, while by (4.1)
$G_k([x]_{k+1}) = [x]_k = [y]_k = G_k([y]_{k+1})$. So $G_k$ is not injective on
$\Pi_{k+1}$, whence $b_k = |G_k(\Pi_{k+1})| < |\Pi_{k+1}| = b_{k+1}$.

*Counting.* Non-triviality of $R_0$ gives two distinct classes at level $0$, so
$b_0 \ge 2$; and always $b_k \le |U|$ since the blocks are pairwise disjoint nonempty
subsets — equivalently $\Pi_k$ is the image of $U$ under $x \mapsto [x]_k$. Now suppose
for contradiction that the chain is unstable at every index $k \le |U| - 2$. Then an
induction gives $b_k \ge 2 + k$ for every $k \le |U| - 1$, and taking $k = |U| - 1$
yields $b_{|U|-1} \ge |U| + 1 > |U|$, a contradiction. $\square$

The bound $|U| - 2$ is exactly right: the block count must climb from $2$ to at most
$|U|$, allowing at most $|U| - 2$ strict increases, and the first stable index is reached
no later than immediately after the last one.

### 4.2 Agreement is an equivalence relation

For a *single* machine $M$ on state set $U$, the relations $E_k$ of Definition 2.4 (with
$N = M$) are equivalence relations: reflexivity, symmetry and transitivity are inherited
pointwise from equality of observations. Monotonicity (Lemma 3.3) says
$E_{k+1} \subseteq E_k$. So $(E_k)_k$ is exactly the kind of chain Theorem 4.1 governs.

**Theorem 4.2 (Single-machine Moore bound).** Let $M$ be a machine with finite state set
$U$ and let $x, y \in U$ be behaviourally inequivalent. Then some $w$ with
$$|w| \le |U| - 2$$
satisfies $\mathrm{obs}_M(x,w) \neq \mathrm{obs}_M(y,w)$.

*Proof.* Non-triviality of $E_0$: if $E_0(x', y')$ held for all $x', y' \in U$ then all
outputs would be equal, and Lemma 3.4 would force $x \approx y$. So Theorem 4.1 applies
and yields $k \le |U| - 2$ with $E_k = E_{k+1}$. Dualising through Lemma 2.5, this says
$$\forall x', y',\quad D_{k+1}(x',y') \Rightarrow D_k(x',y').$$
Since $x \not\approx y$, some word $w$ separates them, so $D_{k + |w|}(x,y)$; Theorem 3.5
collapses this to $D_k(x,y)$, producing a separating word of length $\le k \le |U| - 2$.
$\square$

### 4.3 Transport across the disjoint union

**Definition 4.3 (Sum machine).** For machines $M$ on $S$ and $N$ on $T$ over the same
$(A, O)$, the *sum machine* $M \oplus N$ has state set $S \sqcup T$, transition function
$$\delta_{M \oplus N}(\mathrm{inl}\,s, a) = \mathrm{inl}\,\delta_M(s,a), \qquad
\delta_{M \oplus N}(\mathrm{inr}\,t, a) = \mathrm{inr}\,\delta_N(t,a),$$
and output $\lambda_{M \oplus N}(\mathrm{inl}\,s) = \lambda_M(s)$,
$\lambda_{M\oplus N}(\mathrm{inr}\,t) = \lambda_N(t)$.

**Lemma 4.4 (Embedding).** For all $w$, $\mathrm{obs}_{M \oplus N}(\mathrm{inl}\,s, w)
= \mathrm{obs}_M(s,w)$ and $\mathrm{obs}_{M \oplus N}(\mathrm{inr}\,t, w) =
\mathrm{obs}_N(t,w)$.

*Proof.* Induction on $w$, generalising over the state; the transition of the sum machine
commutes with the injections by definition. $\square$

**Theorem 4.5 (Moore bound, two machines).** Let $S$ and $T$ be finite and let
$s \in S$, $t \in T$ be behaviourally inequivalent. Then there is $w$ with
$$|w| \le |S| + |T| - 2 \quad\text{and}\quad \mathrm{obs}_M(s,w) \neq
\mathrm{obs}_N(t,w).$$

*Proof.* By Lemma 4.4, $\mathrm{inl}\,s$ and $\mathrm{inr}\,t$ are inequivalent states of
the single machine $M \oplus N$, whose state set has cardinality $|S| + |T|$. Theorem 4.2
gives a separating word of length $\le |S| + |T| - 2$, and Lemma 4.4 transports the
separation back to $M$ and $N$. $\square$

**Proposition 4.6 (The linear bound subsumes the quadratic one).** For all integers
$n, m \ge 1$ one has $n + m - 2 < nm$. Consequently Theorem 4.5 implies Theorem 3.6.

*Proof.* If $n = 1$ the claim reads $m - 1 < m$; symmetrically for $m = 1$. If
$n, m \ge 2$ then $n + m \le nm$ (since $(n-1)(m-1) \ge 1$ expands to $nm \ge n + m - 1$,
and for $n,m\ge 2$ in fact $(n-1)(m-1) \ge 1$ gives $nm - n - m + 1 \ge 1$), hence
$n + m - 2 < n + m \le nm$. $\square$

Both bounds are therefore available; the linear one is always at least as strong, and the
quadratic proof remains of interest because its fixpoint chain is the object the standard
$O(|A| \cdot |S| \cdot |T|)$ algorithm actually computes.

---

## 5. Extremality

We now show the constant in Theorem 4.5 cannot be improved, for any pair of sizes, even
over a one-letter alphabet.

### 5.1 A first family: the saturating counter

**Definition 5.1.** For $n \in \mathbb{N}$, the *counter machine* $C_n$ has state set
$\{0, 1, \dots, n\}$ over the unary alphabet $\{\bullet\}$ and Boolean observations:
$$\delta(i, \bullet) = \min(i+1, n), \qquad \lambda(i) = [\,i = n\,].$$
The *sink machine* has one state and constant observation $\mathrm{false}$.

**Lemma 5.2.** Running $C_n$ from state $i$ along a word of length $\ell$ lands in state
$\min(i + \ell, n)$. Consequently
$$\mathrm{obs}_{C_n}(0, w) = [\,n \le |w|\,], \qquad
\mathrm{obs}_{\mathrm{sink}}(\ast, w) = \mathrm{false}.$$

*Proof.* Induction on $w$, generalising over $i$, splitting on whether $i < n$. $\square$

**Theorem 5.3 (Exact separation for the counter family).** A word $w$ separates the
initial state $0$ of $C_n$ from the sink state if and only if $|w| \ge n$. Hence the two
states are inequivalent, and the shortest separating word has length exactly
$$n = |S| \cdot |T| - 1 = |S| + |T| - 2,$$
where $|S| = n+1$ and $|T| = 1$. Both the product bound (Theorem 3.6) and the Moore
bound (Theorem 4.5) are therefore attained for every $n$.

*Proof.* Immediate from Lemma 5.2: the observations are $[\,n \le |w|\,]$ and
$\mathrm{false}$, which differ exactly when $n \le |w|$. The arithmetic identities are
$(n+1)\cdot 1 - 1 = n$ and $(n+1) + 1 - 2 = n$. $\square$

### 5.2 The general two-parameter family

The counter family only exercises the case $|T| = 1$. The following construction attains
$|S| + |T| - 2$ for *all* pairs of sizes. Write $n = n' + 1$ and $m = m' + 1$ for the two
state counts and set
$$r \;=\; (n' + m') \bmod m.$$

**Definition 5.4 (Tail and cycle machines).** Over the unary alphabet:

- The *tail machine* $\mathrm{Tail}_{n',m'}$ has state set $\{0, \dots, n'\}$, transition
  $\delta(i) = \min(i+1, n')$ (a saturating chain), and output
  $$\lambda(i) = \big[\,i < n' \ \wedge\ i \bmod m = r\,\big].$$
- The *cycle machine* $\mathrm{Cyc}_{n',m'}$ has state set $\{0, \dots, m'\}$, transition
  $\delta(j) = (j+1) \bmod m$ (a pure cycle), and output $\lambda(j) = [\, j = r \,]$.

Both start in state $0$.

**Lemma 5.5 (Behaviours).** For any word $w$ of length $\ell$,
$$\mathrm{obs}_{\mathrm{Tail}}(0,w) = \big[\,\min(\ell, n') < n' \ \wedge\
\min(\ell,n') \bmod m = r\,\big], \qquad
\mathrm{obs}_{\mathrm{Cyc}}(0,w) = \big[\,\ell \bmod m = r\,\big].$$

*Proof.* The runs are computed by induction on $w$: the chain reaches $\min(i + \ell,
n')$ and the cycle reaches $(j + \ell) \bmod m$. Apply the output functions. $\square$

**Lemma 5.6 (The blocking window).** If $n' \le \ell < n' + m'$ then
$\ell \bmod m \neq r$.

*Proof.* Suppose $\ell \equiv r \equiv n' + m' \pmod m$. Then $m \mid (n' + m' - \ell)$,
and $0 < n' + m' - \ell \le m'< m$, contradicting the divisibility (a positive multiple
of $m$ is at least $m$). $\square$

This lemma is the arithmetic core: the $m$ consecutive integers $n', n'+1, \dots, n'+m'$
form a complete residue system modulo $m$, and by the choice of $r$ the unique one
congruent to $r$ is the *last*, $n' + m'$.

**Theorem 5.7 (Extremality for every pair of sizes).** For all $n', m' \in \mathbb{N}$
the machines $\mathrm{Tail}_{n',m'}$ (with $n = n'+1$ states) and $\mathrm{Cyc}_{n',m'}$
(with $m = m'+1$ states) satisfy:

1. their initial states are behaviourally inequivalent;
2. every separating word has length $\ge n + m - 2 = n' + m'$;
3. some word of length exactly $n + m - 2$ separates them.

Hence the bound of Theorem 4.5 is attained for every pair of state-set sizes, over a
unary alphabet.

*Proof.* *(2)* Let $|w| = \ell < n' + m'$. If $\ell < n'$ then $\min(\ell,n') = \ell <
n'$, so by Lemma 5.5 the tail's output is $[\,\ell \bmod m = r\,]$, which is the cycle's
output. If $n' \le \ell$, then $\min(\ell, n') = n'$, the tail's first conjunct $n' < n'$
fails, so its output is $\mathrm{false}$; and by Lemma 5.6 the cycle's output
$[\,\ell \bmod m = r\,]$ is also $\mathrm{false}$. Either way they agree.

*(3)* Let $|w| = n' + m'$. Then $\min(|w|, n') = n'$, so the tail outputs
$\mathrm{false}$, while the cycle outputs $[\,(n'+m') \bmod m = r\,] = \mathrm{true}$ by
the definition of $r$. They differ.

*(1)* follows from (3). $\square$

**Corollary 5.8 (No uniform bound).** For every $k \in \mathbb{N}$ there is a pair of
finite Moore machines with inequivalent initial states such that *every* separating word
has length at least $k$. Consequently no length bound independent of the state counts can
exist.

*Proof.* Take $C_k$ against the sink and apply Theorem 5.3. $\square$

### 5.3 The periodicity reading

Over a unary alphabet a machine's entire behaviour is the infinite Boolean sequence
$\big(\mathrm{obs}(s_0, \bullet^\ell)\big)_{\ell \ge 0}$, and an $m$-state machine
produces a sequence that is eventually periodic with preperiod plus period at most $m$.
Theorem 5.7 therefore reads: *a purely periodic sequence of period $m$ and a sequence
that becomes constant after $n-1$ terms can agree on the first $n + m - 2$ positions and
must disagree somewhere by position $n + m - 2$.* This is the automata-theoretic shadow
of the classical Fine–Wilf periodicity phenomenon, in which the length of possible
agreement between differently-periodic words is controlled by the periods and their
greatest common divisor. The construction above realises the extremal configuration:
the preperiod contributes $n - 1$ positions of free imitation, and the periodic structure
contributes $m - 1$ further positions before the residue class $r$ is forced to recur.

---

## 6. An explicit finite test suite

Length bounds are existential. For engineering purposes one wants the actual list of
experiments. Assume $A$ is finite with decidable equality.

**Definition 6.1 (Bounded-length suite).** Define $W_k \subseteq A^*$ by recursion:
$$W_0 = \{\varepsilon\}, \qquad
W_{k+1} = W_k \ \cup\ \{\, a \cdot v : a \in A,\ v \in W_k \,\}.$$

**Lemma 6.2.** $w \in W_k \iff |w| \le k$, and $|W_k| \le (|A| + 1)^k$.

*Proof.* Membership: induction on $k$. For $k = 0$ the only word of length $\le 0$ is
$\varepsilon$. For $k+1$: a word in $W_{k+1}$ is either in $W_k$ (length $\le k \le k+1$)
or of the form $a\cdot v$ with $|v| \le k$, so of length $\le k+1$; conversely a word of
length $\le k+1$ is either $\varepsilon$ (in $W_k$) or $a \cdot v$ with $|v| \le k$.

Cardinality: induction on $k$, using $|W_{k+1}| \le |W_k| + |A| \cdot |W_k| = (|A|+1)
|W_k|$, since the second set in the union is the image of $A \times W_k$ under
$(a,v) \mapsto a\cdot v$. $\square$

**Definition/Theorem 6.3 (Complete finite test suite).** For finite state sets $S$, $T$
define the *canonical test suite* $\mathrm{TS}(A, S, T) = W_{|S| + |T| - 2}$. Then for
all machines $M$ on $S$, $N$ on $T$ and all $s \in S$, $t \in T$:
$$s \approx t \iff \forall w \in \mathrm{TS}(A,S,T),\
\mathrm{obs}_M(s,w) = \mathrm{obs}_N(t,w),$$
and $|\mathrm{TS}(A,S,T)| \le (|A| + 1)^{|S| + |T| - 2}$.

*Proof.* ($\Rightarrow$) trivial. ($\Leftarrow$) If $s \not\approx t$, Theorem 4.5 yields
a separating word of length $\le |S| + |T| - 2$, which by Lemma 6.2 lies in the suite —
contradiction. The cardinality bound is Lemma 6.2. $\square$

The suite is *structure-independent*: one and the same finite list of experiments
certifies equivalence for every pair of machines of the given sizes, whatever their
transition tables.

**Proposition 6.4 (Every omitted word matters).** Let $W$ be any set of words and
$w \notin W$. Then there exist two behaviours agreeing on all of $W$ but differing at
$w$; concretely, the behaviour $f \equiv \mathrm{false}$ and the behaviour
$g = [\,\cdot = w\,]$ (true exactly at $w$).

*Proof.* For $v \in W$ we have $v \neq w$, so $g(v) = \mathrm{false} = f(v)$; and
$g(w) = \mathrm{true} \neq f(w)$. $\square$

Proposition 6.4 shows that no word of length $\le |S| + |T| - 2$ can be deleted from the
suite if it is to remain complete for *arbitrary* behaviours of that length profile — the
suite is not merely sufficient but, at this level of generality, necessary.

---

## 7. The infinite-state barrier

All of the above depends on finiteness. We now show that finiteness is not a convenience
but the whole content of the theorem.

**Definition 7.1 (Free machine).** For $f \colon A^* \to \mathbb{B}$, the *free machine*
$F_f$ has state set $A^*$ (words read so far), transition $\delta(s, a) = s \cdot a$
(append), and output $\lambda(s) = f(s)$.

**Theorem 7.2 (Universality of the free construction).** For all $f$ and all $w \in A^*$,
$$\mathrm{obs}_{F_f}([\,], w) = f(w).$$
Consequently every function $A^* \to \mathbb{B}$ is the behaviour of some initial state of
some (infinite-state) Moore machine.

*Proof.* By induction, $\mathrm{run}_{F_f}(s, w) = s \cdot w$; with $s = \varepsilon$ this
is $w$, and applying $\lambda$ gives $f(w)$. $\square$

**Theorem 7.3 (No finite test suite).** Let $A$ be nonempty and $W$ a *finite* set of
words. Then there are $f \neq g \colon A^* \to \mathbb{B}$ with $f(w) = g(w)$ for all
$w \in W$.

*Proof.* Let $\mu = \max\{|w| : w \in W\}$ (with $\max \emptyset = 0$), pick a letter
$a \in A$, and let $u = a^{\mu + 1}$. Since $|u| = \mu + 1 > \mu$, we have $u \notin W$.
Take $f \equiv \mathrm{false}$ and $g = [\,\cdot = u\,]$. They agree on $W$ and differ at
$u$. $\square$

**Corollary 7.4 (Machine form).** For every finite $W$ there are two machines (on the
infinite state set $A^*$) whose initial states produce identical observations on every
word in $W$, yet are behaviourally inequivalent.

*Proof.* Combine Theorems 7.2 and 7.3. $\square$

**Theorem 7.5 (Finite-test dichotomy).** Fix a nonempty finite alphabet $A$, an
observation type $O$, and $k \in \mathbb{N}$. Then:

1. **(Universal completeness on a size class.)** For every pair of finite-state machines
   $M$ on $S$ and $N$ on $T$ with $|S| + |T| - 2 \le k$, and every $s, t$:
   $$\big(\forall w \in W_k,\ \mathrm{obs}_M(s,w) = \mathrm{obs}_N(t,w)\big)
   \iff s \approx t.$$
2. **(Universal incompleteness off it.)** There exist behaviours $f \neq g$ whose free
   machines agree on the whole of $W_k$ yet whose initial states are inequivalent.

*Proof.* (1) is Theorem 6.3 combined with Lemma 6.2 and monotonicity of $W_\bullet$;
(2) is Proposition 6.4 applied to the word $a^{k+1} \notin W_k$, realised as machines via
Theorem 7.2. $\square$

The dichotomy is exact and, in a sense, a definition of what "finite state" buys you.
Testing an infinite-state black box is not merely expensive: no finite amount of it is
evidence of anything. Testing a finite-state black box of known size is not merely
possible: a bounded, precomputable list of experiments settles the question completely.

---

## 8. Algorithms

Three algorithms follow from the development, each computing something different.

**Algorithm 1 (Bounded agreement, recursive).** Decide $E_k(s,t)$ by the recursion (3.1)
and (3.2): compare outputs, and for $k > 0$ recurse on all $a$-successors with budget
$k-1$. Naively this explores $O(|A|^k)$ paths — it is the direct evaluation of the test
suite — but it needs no auxiliary space beyond the recursion stack and is the honest
computational reading of Corollary 3.8.

**Algorithm 2 (Fixpoint refinement on the product).** Maintain the set
$\mathcal{D} \subseteq S \times T$, initialised to $\{(x,y) : \lambda_M(x) \neq
\lambda_N(y)\}$, and repeatedly add every pair $(x,y)$ having some $a$ with
$(\delta_M(x,a), \delta_N(y,a)) \in \mathcal{D}$, until no pair is added. By Theorem 3.5
the result is the full inequivalence relation, and by Theorem 3.6 at most $|S| \cdot |T|$
rounds are needed. Each round costs $O(|A| \cdot |S| \cdot |T|)$, and recording at each
pair the round at which it entered yields the exact shortest distinguishing length; a
standard backward-BFS implementation runs in $O(|A| \cdot |S| \cdot |T|)$ total.

**Algorithm 3 (Shortest separating word by product BFS).** Forward breadth-first search
in the product graph on $S \times T$ from $(s,t)$, following each letter $a$ from $(x,y)$
to $(\delta_M(x,a), \delta_N(y,a))$, stopping at the first reached pair with
$\lambda_M(x) \neq \lambda_N(y)$ and reconstructing the word from the BFS tree. Because
the first such pair is reached along a shortest path, the returned word is a shortest
separating word; complexity $O(|A| \cdot |S| \cdot |T|)$. Theorem 4.5 guarantees the
answer never exceeds $|S| + |T| - 2$ even though the search space has size
$|S| \cdot |T|$ — an inequality that is itself a useful runtime assertion.

---

## 9. Applications

**Conformance testing.** For a protocol implementation claimed to conform to a
specification with $|T|$ states, and an implementation known to have at most $|S|$
states, Theorem 6.3 supplies a finite, precomputed test plan whose completeness is
unconditional. The size bound $(|A|+1)^{|S|+|T|-2}$ is a worst case for *blind*
enumeration; Algorithm 3 shows that when the implementation is available as a white box
the shortest witness is found in linear time in the product size.

**Sequential equivalence checking.** Two synchronous circuits with $n$ and $m$ latch
configurations reachable are behaviourally distinguishable, if at all, by an input
stimulus of length at most $n + m - 2$. This turns unbounded model checking of a safety
property "outputs always agree" into bounded model checking with an explicit, and tight,
unrolling depth.

**Model learning.** Active automata learning algorithms build hypotheses and query an
equivalence oracle. When an upper bound on the target's state count is known, Theorem 6.3
converts the equivalence oracle into a finite membership-query loop, making the learning
procedure terminating and its query complexity explicit.

**Sanity limits.** Corollary 5.8 and Theorem 7.3 together are a warning: any claim that a
fixed, machine-size-independent test suite suffices is false; and any claim that testing
alone certifies an unbounded-state system is false. Both limits are witnessed by tiny,
concrete counterexamples.

---

## 10. Discussion and future work

The development has a pleasing three-part shape: a coarse but conceptually transparent
bound ($|S|\cdot|T|$, from the product fixpoint); a sharp bound ($|S|+|T|-2$, from
abstract refinement stabilisation); and matching extremal examples for every pair of
sizes over the smallest possible alphabet. The abstract engine, Theorem 4.1, is where the
mathematics actually lives — it mentions no machines, and any monotone refinement process
on a finite carrier inherits its conclusion.

Several directions suggest themselves.

**Fine–Wilf calibration of unary experiments.** For unary machines with $n$ and $m$
states whose reachable parts are a $(p_1, q_1)$- and a $(p_2, q_2)$-rho (preperiod $p_i$,
period $q_i$, $p_i + q_i \le$ size), we conjecture that the shortest distinguishing word
has length at most
$$\max(p_1, p_2) + q_1 + q_2 - \gcd(q_1, q_2) - 1,$$
and that this is attained. A unary machine's behaviour *is* an eventually periodic word,
so the distinguishing length is exactly the "first mismatch" quantity governed by the
Fine–Wilf periodicity theorem, with the preperiod contributing additively and the periods
through their greatest common divisor. The extremal family of §5.2 already realises the
coarse bound with a preperiod-$(n-1)$/period-$m$ pair; refining the statement requires
only a rho-decomposition lemma for unary machines and the Fine–Wilf inequality.

**Reachability-relativised bounds.** We expect the bound to hold with $|S|$ and $|T|$
replaced by the numbers $r_S$, $r_T$ of states *reachable* from the respective initial
states, giving $r_S + r_T - 2$; and that for minimal reachable machines this cannot be
lowered. The refinement chain never sees unreachable states, so the block count driving
Theorem 4.1 is already bounded by the reachable part; formally one instantiates the
abstract engine with the reachable subtype in place of $S \sqcup T$.

**Adaptive versus non-adaptive testing.** The suite $W_k$ is non-adaptive: all
experiments are fixed in advance. An adaptive strategy chooses the next input after
observing the last output. We conjecture that adaptivity cannot reduce the *number* of
tests needed to separate all inequivalent pairs of $n$-state machines by more than a
logarithmic factor, so that the exponential suite size is intrinsic rather than an
artifact of non-adaptivity.

**Beyond determinism.** The saturation argument uses determinism only through the fact
that the pair $(x,y)$ determines the successors. For nondeterministic or probabilistic
observation models the analogous chain lives on a lattice of *sets* of pairs or on a
convex space, and the block-counting argument must be replaced by a rank or dimension
count; the correct extremal constants there are, to our knowledge, not settled by an
argument as elementary as the one above.

**Weighted and quantitative settings.** Replacing $\{\mathrm{true},\mathrm{false}\}$
observations by values in a semiring turns behavioural equivalence into equality of
formal power series, where Hankel-matrix rank arguments give bounds of the form
$r_S + r_T$ with $r$ the rank rather than the state count. Reconciling the combinatorial
refinement bound with the linear-algebraic rank bound in a single statement — one that
degenerates to Theorem 4.5 over the Boolean semiring — would be a satisfying unification.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Product bound | Inequivalent initial states are separated by a word of length $< \lvert S\rvert \cdot \lvert T\rvert$. |
| Saturation | If distinguishability level $k+1$ equals level $k$, all higher levels equal level $k$. |
| Refinement stabilisation | A decreasing chain of equivalence relations on a finite $U$, non-trivial at level $0$, stabilises by index $\lvert U\rvert - 2$. |
| Moore bound (one machine) | Inequivalent states of a $\lvert U\rvert$-state machine are separated by a word of length $\le \lvert U\rvert - 2$. |
| Moore bound (two machines) | Separation by a word of length $\le \lvert S\rvert + \lvert T\rvert - 2$. |
| Subsumption | $n + m - 2 < nm$ for $n,m \ge 1$; the linear bound implies the quadratic one. |
| Extremality | For every $(n,m)$ a unary pair of machines agrees on all words shorter than $n+m-2$ and differs at length exactly $n+m-2$. |
| No uniform bound | For every $k$ a machine pair whose every separating word has length $\ge k$. |
| Complete test suite | Equivalence $\iff$ agreement on all words of length $\le \lvert S\rvert + \lvert T\rvert - 2$; suite size $\le (\lvert A\rvert+1)^{\lvert S\rvert+\lvert T\rvert-2}$. |
| Decidability | Behavioural equivalence is decidable for finite alphabets and finite nonempty state sets. |
| Universality of free machines | Every $f \colon A^* \to \mathbb{B}$ is the behaviour of an initial state of some machine. |
| No finite test suite | For every finite $W$ there are distinct behaviours agreeing on all of $W$. |
| Dichotomy | $W_k$ is complete for all machine pairs with $\lvert S\rvert+\lvert T\rvert-2 \le k$, and incomplete for arbitrary behaviours. |
