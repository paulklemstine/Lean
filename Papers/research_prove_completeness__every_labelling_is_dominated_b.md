# Completeness of Layered Dynamic Programming over Ordered Weight Monoids

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We develop from first principles a general theory of *layered dynamic programming* — the Bellman/Viterbi schema — over an arbitrary finite non-empty state space $S$ and an arbitrary linearly ordered commutative additive monoid $W$ of weights whose addition is monotone. Within this setting we prove a **completeness theorem**: every labelling $f : \mathbb{N} \to S$ is dominated by some *run* of the dynamic program, i.e. there exists a labelling $g$ all of whose prefixes are optimal and whose total score at every fixed horizon is at least that of $f$. Together with the dual **soundness** statement — every run is an honest labelling whose score is exactly the value computed by the recursion — this yields an **exactness theorem**: the forward value function $V(n,s)$ is the *greatest element* of the set of scores achievable by labellings ending in state $s$ at stage $n$.

Around this core we establish: (i) **Bellman's optimality principle**, that end-optimality of a labelling implies optimality of all of its prefixes, under the additional hypothesis that $W$ is cancellative; (ii) an exact **characterisation of runs** as the labellings optimal among those with the same endpoint; (iii) a **forward–backward decomposition** allowing an optimal path to be cut at any intermediate stage; (iv) a **tropical walk calculus** in which segment composition satisfies a max-plus Chapman–Kolmogorov identity and the value function is the max-plus action of walk matrices on the initial vector; (v) **monotonicity**, **equivariance** and **Lipschitz stability** of the optimum under perturbation of the specification, together with a near-optimality transfer bound of $2(a + nb)$; (vi) **order duality**, which yields the min-plus (shortest-path) completeness theorem at no additional cost; and (vii) a **removal of the cancellativity hypothesis**, obtained by replacing the semantic notion of a run by the structural *backtrace* notion and proving the two equivalent over an arbitrary ordered weight monoid. The last item is what makes the theory applicable to *constrained* dynamic programming over $W \cup \{\bot\}$, where $\bot$ is an absorbing "infeasible" weight and cancellativity fails; there we obtain a clean characterisation of infeasibility and instantiate the theory on maximum-weight independent set on a path.

**Keywords:** dynamic programming, Bellman optimality principle, Viterbi algorithm, completeness, tropical semiring, max-plus algebra, ordered monoid, constrained optimisation.

---

## 1. Introduction

### 1.1 The problem

Fix a finite non-empty set $S$ of *states* and a discrete sequence of *stages* $0, 1, 2, \dots$. A **labelling** is a function $f : \mathbb{N} \to S$; the value $f(i)$ is the state occupied at stage $i$. Labellings are the objects one optimises over in an enormous range of applications: they are transcriptions in speech recognition, routes in navigation, alignments in computational biology, tag sequences in natural-language processing, and selections in combinatorial optimisation over a linear structure.

A labelling is scored *additively and locally*: one pays an entry cost depending on the starting state and a transition cost depending on the stage and the pair of consecutive states. The optimisation problem is to determine
$$\max\{\,\mathrm{score}(f,n) : f \text{ a labelling}\,\}$$
and to exhibit a maximiser. The naive search space has size $|S|^{n+1}$.

Dynamic programming replaces this exponential search with a recursion of cost $O(n|S|^2)$. The recursion is elementary; what requires proof is that it computes the right answer. This paper is about that proof, carried out under hypotheses so weak that the theorem simultaneously covers maximisation and minimisation, exact and probabilistic weights, unconstrained and constrained problems.

### 1.2 Soundness and completeness

We adopt the terminology of logic, which we find clarifying. Let $V(n,s)$ denote the number produced by the recursion. Two independent claims are at stake:

- **Soundness.** $V(n,s)$ is *achievable*: some labelling ending at $s$ scores exactly $V(n,s)$. Equivalently, the algorithm never over-reports.
- **Completeness.** $V(n,s)$ is an *upper bound*: no labelling ending at $s$ scores more. Equivalently, the algorithm never misses a better solution.

Neither implies the other, and each is worthless in isolation: the constant algorithm returning $-\infty$ is sound; the constant algorithm returning $+\infty$ is complete. Their conjunction is the assertion that $V(n,s)$ is the *greatest element* of the achievable set — a strictly stronger statement than "$V(n,s)$ is the supremum", since it asserts attainment.

Completeness is the deeper of the two in the following sense: soundness is a construction (backtrace and read off), whereas completeness quantifies over an exponentially large set that the algorithm never inspects. It is precisely the property that greedy algorithms lack.

### 1.3 Contributions and organisation

Section 2 introduces the algebraic setting and the three hypotheses on weights. Section 3 defines specifications, scores, the value function, and runs. Section 4 proves domination (completeness), realisability (soundness), exactness, and the two forms of the completeness theorem. Section 5 proves Bellman's optimality principle and the characterisation of runs, and isolates exactly where cancellativity is used. Section 6 develops backward values and the forward–backward decomposition. Section 7 develops the tropical walk calculus. Section 8 treats monotonicity, equivariance and stability. Section 9 obtains min-plus/shortest paths by order duality. Section 10 removes cancellativity via backtraces and applies the result to constrained dynamic programming, with a worked maximum-weight independent set instance. Section 11 gives algorithms and complexity. Section 12 discusses applications, limitations and future directions.

---

## 2. Algebraic setting

Throughout, $S$ is a finite non-empty type of states, and $W$ is a type of weights carrying:

**(W1) A commutative additive monoid structure.** There is an associative, commutative addition $+$ on $W$ with neutral element $0$.

**(W2) A linear order.** $\le$ is a total order on $W$.

**(W3) Left-monotone addition.** For all $a, b, c \in W$, $a \le b$ implies $c + a \le c + b$. By commutativity this also gives right monotonicity.

We refer to a structure satisfying (W1)–(W3) as an **ordered weight monoid**. Two strengthenings are used in specific places, and we always flag them:

**(W4) Cancellativity of the ordered monoid.** $W$ is an ordered *cancellative* additive monoid: $a + c \le b + c$ implies $a \le b$. Equivalently, addition strictly preserves strict inequalities: $a < b$ implies $a + c < b + c$. This holds in $\mathbb{Z}, \mathbb{Q}, \mathbb{R}$ and in any linearly ordered abelian group.

**(W5) Group structure.** $W$ is a linearly ordered abelian group, so that subtraction and absolute value are available. Used only in Section 8.

Three families of instances motivate the abstraction:

1. **Max-plus.** $W = \mathbb{R}$ (or $\mathbb{Z}$, $\mathbb{Q}$) with the usual order and addition. The value function maximises total weight: longest paths, Viterbi log-likelihood decoding.
2. **Min-plus.** $W = \mathbb{R}^{\mathrm{op}}$, the *order dual*: the same monoid with $\le$ reversed. Suprema in $W^{\mathrm{op}}$ are infima in $\mathbb{R}$, so the maximisation theory becomes a minimisation theory: shortest paths, edit distance, Bellman–Ford. Crucially, $W^{\mathrm{op}}$ satisfies (W1)–(W4) whenever $W$ does, so *every theorem proved abstractly holds in its mirror form with no additional work*.
3. **Constrained weights.** $W \cup \{\bot\} = \mathrm{WithBot}(W)$, where $\bot$ is a new least element with $\bot + w = w + \bot = \bot$. This satisfies (W1)–(W3) but **not** (W4): $\bot + a = \bot + b$ for all $a,b$. Section 10 is devoted to making the theory work here.

The finiteness and non-emptiness of $S$ are used to guarantee that the maxima appearing in the recursion exist and are *attained*; attainment, not merely existence of a supremum, is what drives the realisability proof.

**Notation.** For a finite non-empty index set and a family $(a_i)$ in $W$, we write $\max_i a_i$ for the greatest element of the (finite, non-empty) family, which exists by (W2).

We record two elementary but pivotal facts.

> **Lemma 2.1 (Distribution of addition over finite maxima).** For a finite non-empty index set $I$, a family $(a_i)_{i \in I}$ in $W$, and $c \in W$:
> $$\Big(\max_{i \in I} a_i\Big) + c = \max_{i \in I}\,(a_i + c), \qquad c + \max_{i \in I} a_i = \max_{i \in I}\,(c + a_i).$$

*Proof.* For $\le$: the maximum on the left is attained at some $i_0$, and $a_{i_0} + c$ is one of the terms on the right, hence bounded by the right-hand maximum. For $\ge$: for each $i$, $a_i \le \max_j a_j$, so by (W3) $a_i + c \le (\max_j a_j) + c$; take the maximum over $i$. The second identity follows by commutativity. $\square$

Lemma 2.1 is the *distributive law* of the tropical semiring $(W, \max, +)$ and is the engine behind every exchange-of-maxima argument in this paper. Note it requires only (W1)–(W3).

> **Lemma 2.2 (Exchange of maxima).** For finite non-empty $I, J$ and a family $(a_{ij})$,
> $$\max_{i \in I} \max_{j \in J} a_{ij} = \max_{j \in J} \max_{i \in I} a_{ij}.$$

*Proof.* Both sides equal the maximum over the finite non-empty product $I \times J$. $\square$

---

## 3. Specifications, scores, values and runs

### 3.1 Specifications and scores

> **Definition 3.1 (Layered DP specification).** A *specification* $D$ over $(S, W)$ consists of
> - an **initial weight** function $\mathrm{init} : S \to W$, and
> - a **transition weight** function $\mathrm{step} : \mathbb{N} \times S \times S \to W$, written $\mathrm{step}_i(s,t)$ for the weight of moving from state $s$ at stage $i$ to state $t$ at stage $i+1$.

Transition weights are allowed to depend on the stage $i$; this *inhomogeneity* is essential in practice (observation-dependent emission scores in speech and NLP, time-varying costs in scheduling) and costs nothing in the theory.

> **Definition 3.2 (Score).** The *score* of a labelling $f$ truncated at stage $n$ is defined by recursion on $n$:
> $$\mathrm{score}(f, 0) := \mathrm{init}(f(0)), \qquad \mathrm{score}(f, n+1) := \mathrm{score}(f,n) + \mathrm{step}_n\big(f(n), f(n{+}1)\big).$$

Unfolding, $\mathrm{score}(f,n) = \mathrm{init}(f(0)) + \sum_{i=0}^{n-1} \mathrm{step}_i(f(i), f(i{+}1))$.

> **Lemma 3.3 (Locality of the score).** If $f(i) = g(i)$ for all $i \le n$, then $\mathrm{score}(f,n) = \mathrm{score}(g,n)$.

*Proof.* Induction on $n$. The base case is immediate. For the step, the inductive hypothesis applies to the truncation at $n$, and the last summand depends only on $f(n)$ and $f(n{+}1)$, both of which agree with $g$. $\square$

Lemma 3.3 is what licenses the *splicing* construction in Theorem 4.3: a labelling is an infinite object but only its restriction to $\{0,\dots,n\}$ matters at horizon $n$. Working with total functions $\mathbb{N} \to S$ rather than finite tuples avoids all dependent-index bookkeeping while, by Lemma 3.3, changing nothing mathematically.

### 3.2 The forward value function

> **Definition 3.4 (Forward value).** The *value function* $V : \mathbb{N} \times S \to W$ of a specification $D$ is defined by
> $$V(0,s) := \mathrm{init}(s), \qquad V(n+1, t) := \max_{s \in S}\ \big(V(n,s) + \mathrm{step}_n(s,t)\big).$$

The maximum is over the finite non-empty set $S$ and is therefore attained; that attainment is used constantly.

Note that Definition 3.4 is *purely operational*: it is a recursion, computable in $O(n|S|^2)$ monoid operations and comparisons. It makes no reference to labellings. Establishing that it nevertheless computes the optimum over labellings is the content of Section 4.

> **Lemma 3.5 (Sub-Bellman inequality).** For all $n$ and all $s,t \in S$,
> $$V(n,s) + \mathrm{step}_n(s,t) \le V(n+1, t).$$

*Proof.* Immediate from Definition 3.4: the left side is one of the terms of the maximum. Only (W1)–(W2) are needed. $\square$

### 3.3 Runs

> **Definition 3.6 (DP run).** A labelling $f$ is a *run at horizon $n$* if every prefix is optimal:
> $$\mathrm{score}(f,i) = V\big(i, f(i)\big) \quad \text{for all } i \le n.$$

This is the *semantic* definition of a run: it says $f$ is what the recursion would have produced, in the sense that it is optimal at each intermediate stage. Its structural counterpart, introduced in Section 10, is the *backtrace* condition, which asks that the recursion be realised exactly at each step.

Two immediate consequences:

> **Lemma 3.7 (Runs are inherited by prefixes).** If $f$ is a run at horizon $n$ and $m \le n$, then $f$ is a run at horizon $m$.

*Proof.* The defining condition is universally quantified over $i \le n$; restrict to $i \le m$. $\square$

> **Theorem 3.8 (Soundness).** If $f$ is a run at horizon $n$ then $\mathrm{score}(f,n) = V(n, f(n))$: the value computed by the recursion at the run's endpoint is achieved by an honest labelling.

*Proof.* Take $i = n$ in Definition 3.6. $\square$

Theorem 3.8 is trivial given the definition; the substance is Theorem 4.3, which asserts that runs *exist* ending at every prescribed state.

---

## 4. Completeness, realisability, exactness

### 4.1 Domination

> **Theorem 4.1 (Domination).** Under (W1)–(W3), for every labelling $f$ and every $n \in \mathbb{N}$,
> $$\mathrm{score}(f,n) \le V\big(n, f(n)\big).$$

*Proof.* Induction on $n$.

*Base.* $\mathrm{score}(f,0) = \mathrm{init}(f(0)) = V(0, f(0))$, with equality.

*Step.* Assume $\mathrm{score}(f,n) \le V(n, f(n))$. Write $c := \mathrm{step}_n(f(n), f(n{+}1))$. By (W3),
$$\mathrm{score}(f, n{+}1) = \mathrm{score}(f,n) + c \le V(n, f(n)) + c,$$
and by Lemma 3.5, $V(n, f(n)) + c \le V(n{+}1, f(n{+}1))$. Chain the two. $\square$

This two-line induction is the completeness half of the theory: it certifies, without inspecting any of the $|S|^{n+1}$ labellings individually, that none of them exceeds the value function. It uses no cancellation, no subtraction, no sign conditions on weights, and no structure on $S$ beyond being a set.

### 4.2 Realisability

> **Theorem 4.2 (Realisability, cancellative form).** Assume (W1)–(W4) and $S$ finite non-empty. For every $n \in \mathbb{N}$ and every $s \in S$ there exists a labelling $f$ with $f(n) = s$ that is a run at horizon $n$.

We defer a proof to Section 10, where Theorem 10.3 establishes the same statement for the structural notion of a run under (W1)–(W3) only; combined with the equivalence Theorem 10.2 this gives Theorem 4.2 in the stated generality and more. For orientation, here is the argument in the cancellative setting.

*Proof sketch.* Induction on $n$.

*Base.* Take $f$ constantly equal to $s$; the only condition is at $i = 0$, where both sides equal $\mathrm{init}(s)$.

*Step.* Fix a target $t$. Since $S$ is finite and non-empty, the maximum defining $V(n{+}1,t)$ is attained: choose $s^\ast \in S$ with
$$V(n+1,t) = V(n,s^\ast) + \mathrm{step}_n(s^\ast, t).$$
By induction there is a run $f$ at horizon $n$ with $f(n) = s^\ast$. Define the spliced labelling
$$g(i) := \begin{cases} f(i) & i \le n,\\ t & i > n.\end{cases}$$
Then $g(n) = f(n) = s^\ast$ and $g(n{+}1) = t$. By Lemma 3.3, $\mathrm{score}(g,n) = \mathrm{score}(f,n) = V(n, s^\ast)$, hence
$$\mathrm{score}(g, n{+}1) = V(n,s^\ast) + \mathrm{step}_n(s^\ast,t) = V(n{+}1, t) = V(n{+}1, g(n{+}1)).$$
So $g$ is *end-optimal* at horizon $n{+}1$. Bellman's optimality principle (Theorem 5.1), which is where (W4) enters, upgrades end-optimality to the full run condition. $\square$

The proof is *constructive*: unwinding the induction gives exactly the classical backtrace loop, which stores at each cell $(n{+}1,t)$ an argmax predecessor $s^\ast$ and reconstructs the optimum by walking back through the pointers.

### 4.3 Exactness and completeness

> **Theorem 4.3 (Exactness at a prescribed endpoint).** For all $n$ and $s$, $V(n,s)$ is the greatest element of
> $$A(n,s) := \{\,\mathrm{score}(f,n) : f \text{ a labelling with } f(n) = s\,\}.$$
> That is, $V(n,s) \in A(n,s)$ and $w \le V(n,s)$ for all $w \in A(n,s)$.

*Proof.* Membership is Theorem 4.2 combined with Theorem 3.8. The upper-bound property is Theorem 4.1 specialised to labellings with $f(n) = s$. $\square$

> **Theorem 4.4 (Completeness, pointwise form).** For every labelling $f$ and every $n$ there exists a run $g$ at horizon $n$ with
> $$\mathrm{score}(f,n) \le \mathrm{score}(g,n).$$

*Proof.* Apply Theorem 4.2 with $s := f(n)$ to obtain a run $g$ with $g(n) = f(n)$. Then $\mathrm{score}(g,n) = V(n, g(n)) = V(n, f(n)) \ge \mathrm{score}(f,n)$ by Theorems 3.8 and 4.1. $\square$

Note that the dominating run may be taken to have the *same endpoint* as $f$: the algorithm does not need to change where you end up in order to beat you. A stronger and more useful statement drops the endpoint constraint.

> **Theorem 4.5 (Completeness, uniform form).** For every $n$ there exists a *single* run $g$ at horizon $n$ such that $\mathrm{score}(f,n) \le \mathrm{score}(g,n)$ for **every** labelling $f$.

*Proof.* Choose $s^\ast \in S$ attaining $\max_{s \in S} V(n,s)$ and let $g$ be a run ending at $s^\ast$ (Theorem 4.2). For any $f$,
$$\mathrm{score}(f,n) \le V(n, f(n)) \le \max_{s} V(n,s) = V(n,s^\ast) = \mathrm{score}(g,n). \square$$

> **Corollary 4.6 (Global exactness).** $\max_{s \in S} V(n,s)$ is the greatest element of $\{\mathrm{score}(f,n) : f \text{ a labelling}\}$.

The move from Theorem 4.4 to Theorem 4.5 is the logical difference between $\forall f\,\exists g$ and $\exists g\,\forall f$, and it is exactly the difference between "the algorithm is not beaten in any particular comparison" and "the algorithm outputs *the* optimum". It is available here because the state space is finite, so the outer maximum over endpoints is attained.

---

## 5. Bellman's optimality principle

The definition of a run demands optimality of *every* prefix. Backtracing manifestly produces the last-stage optimum; does it produce intermediate optima? Equivalently: could a labelling be sloppy early and compensate later? The answer is no, and this is Bellman's principle.

> **Theorem 5.1 (Bellman's optimality principle).** Assume (W1)–(W4). If a labelling $f$ satisfies $\mathrm{score}(f,n) = V(n, f(n))$ — optimality at the endpoint only — then $f$ is a run at horizon $n$; that is, $\mathrm{score}(f,i) = V(i, f(i))$ for all $i \le n$.

*Proof.* Induction on $n$. For $n = 0$ there is nothing to check beyond $i = 0$, which is the hypothesis.

For $n+1$: suppose $\mathrm{score}(f, n{+}1) = V(n{+}1, f(n{+}1))$. We first show $\mathrm{score}(f,n) = V(n,f(n))$. By Theorem 4.1 we have $\le$. Suppose strictly $\mathrm{score}(f,n) < V(n, f(n))$. Put $c := \mathrm{step}_n(f(n), f(n{+}1))$. By **(W4)**, adding $c$ preserves the *strict* inequality:
$$\mathrm{score}(f,n) + c < V(n, f(n)) + c \le V(n{+}1, f(n{+}1)),$$
the last step by Lemma 3.5. The left side is $\mathrm{score}(f,n{+}1)$, so $\mathrm{score}(f,n{+}1) < V(n{+}1, f(n{+}1))$, contradicting the hypothesis. Hence $\mathrm{score}(f,n) = V(n,f(n))$, and the inductive hypothesis makes $f$ a run at horizon $n$; adjoining the stage-$(n{+}1)$ hypothesis gives the run condition for all $i \le n+1$. $\square$

**Where cancellativity is used, and why it matters.** The single step $x < y \Rightarrow x + c < y + c$ is the *only* place (W4) enters. In a non-cancellative ordered monoid this implication can fail: in $\mathrm{WithBot}(\mathbb{R})$ with $c = \bot$ we have $x + \bot = y + \bot = \bot$ for all $x,y$. And Theorem 5.1 genuinely fails there: if a transition out of $f(n)$ is forbidden, then $\mathrm{score}(f,n{+}1) = \bot = V(n{+}1, f(n{+}1))$ whenever $f(n{+}1)$ is unreachable, so $f$ is end-optimal while its prefix may be arbitrarily bad. Section 10 shows that the *right* repair is not to weaken the conclusion but to change the definition of "run".

> **Theorem 5.2 (Characterisation of runs).** Assume (W1)–(W4). A labelling $f$ is a run at horizon $n$ if and only if it is optimal among labellings with the same endpoint:
> $$f \text{ is a run at } n \iff \forall g,\ \big(g(n) = f(n) \Rightarrow \mathrm{score}(g,n) \le \mathrm{score}(f,n)\big).$$

*Proof.* ($\Rightarrow$) If $f$ is a run and $g(n) = f(n)$, then $\mathrm{score}(g,n) \le V(n,g(n)) = V(n,f(n)) = \mathrm{score}(f,n)$ by Theorems 4.1 and 3.8.

($\Leftarrow$) Suppose $f$ dominates all labellings with the same endpoint. By Theorem 4.2 pick a run $g$ with $g(n) = f(n)$; then $V(n,f(n)) = \mathrm{score}(g,n) \le \mathrm{score}(f,n)$. With Theorem 4.1 this gives $\mathrm{score}(f,n) = V(n, f(n))$, and Theorem 5.1 upgrades this to the run condition. $\square$

Theorem 5.2 is the sharp form of soundness plus completeness. On the left is a *syntactic* property ("is generated by the recursion"), on the right a *semantic* one ("is optimal"). Their coincidence is precisely what one means by saying the algorithm is correct.

---

## 6. Backward values and the forward–backward decomposition

Forward values summarise the past. Their mirror image summarises the future.

> **Definition 6.1 (Backward value).** For $k, m \in \mathbb{N}$ and $s \in S$, define $B(k,m,s)$ — the best total weight of $m$ further transitions starting from state $s$ at stage $k$ — by
> $$B(k, 0, s) := 0, \qquad B(k, m{+}1, s) := \max_{t \in S}\ \big(\mathrm{step}_k(s,t) + B(k{+}1, m, t)\big).$$

Note $B$ does *not* include $\mathrm{init}$: it measures only the cost of the remaining transitions.

> **Theorem 6.2 (Forward–backward decomposition).** Under (W1)–(W3), for all $k, m \in \mathbb{N}$,
> $$\max_{s \in S} V(k+m, s) \;=\; \max_{s \in S}\ \big(V(k,s) + B(k, m, s)\big).$$

*Proof.* Induction on $m$, with $k$ universally quantified in the inductive statement.

*Base $m = 0$.* $B(k,0,s) = 0$, so the right side is $\max_s (V(k,s) + 0) = \max_s V(k,s)$, which is the left side.

*Step.* Assume the identity for $m$ and all $k$. Since $k + (m{+}1) = (k{+}1) + m$, the inductive hypothesis at $k+1$ gives
$$\max_s V(k+m+1, s) = \max_{t \in S}\ \big(V(k{+}1, t) + B(k{+}1, m, t)\big).$$
Expand $V(k{+}1,t)$ by Definition 3.4 and apply Lemma 2.1 (distribution of $+\,B(k{+}1,m,t)$ over the inner maximum):
$$V(k{+}1,t) + B(k{+}1,m,t) = \max_{s \in S}\ \big(V(k,s) + \mathrm{step}_k(s,t) + B(k{+}1,m,t)\big).$$
On the other side, expand $B(k, m{+}1, s)$ by Definition 6.1 and distribute $V(k,s) + \,\cdot\,$ over the inner maximum, again by Lemma 2.1:
$$V(k,s) + B(k,m{+}1,s) = \max_{t \in S}\ \big(V(k,s) + \mathrm{step}_k(s,t) + B(k{+}1,m,t)\big),$$
using associativity to reassociate. The two displayed double maxima are over the same doubly-indexed family $\big(V(k,s) + \mathrm{step}_k(s,t) + B(k{+}1,m,t)\big)_{s,t}$ in the two possible orders; Lemma 2.2 identifies them. $\square$

Theorem 6.2 says that an optimal path may be cut at *any* intermediate stage $k$, and that the global optimum is recovered as the best over intermediate states of (best way in) $+$ (best way out). Consequences include:

- **Posterior/constrained analysis.** The quantity $V(k,s) + B(k,m,s)$ is the best score over all labellings *forced* to occupy state $s$ at stage $k$. Comparing it with the unconstrained optimum measures the marginal cost of that constraint — the "max-marginal" used in structured prediction and in sensitivity analysis.
- **Divide and conquer.** The identity underlies Hirschberg-style linear-space algorithms and meet-in-the-middle parallelisation: compute forward values on $[0,k]$ and backward values on $[k, k+m]$ independently and combine in $O(|S|)$.

---

## 7. The tropical walk calculus

Definitions 3.4 and 6.1 both look like matrix–vector products in the semiring $(W, \max, +)$: read $\max$ as "$\oplus$" and $+$ as "$\otimes$". Lemma 2.1 is precisely the distributivity axiom. This section makes the structure explicit.

> **Definition 7.1 (Walk weight).** For $k, m \in \mathbb{N}$ and $s,t \in S$, let $\mathcal{W}_k^{(m)}(s,t)$ denote the best total weight of $m+1$ consecutive transitions leading from state $s$ at stage $k$ to state $t$ at stage $k+m+1$:
> $$\mathcal{W}_k^{(0)}(s,t) := \mathrm{step}_k(s,t), \qquad \mathcal{W}_k^{(m+1)}(s,t) := \max_{u \in S}\big(\mathrm{step}_k(s,u) + \mathcal{W}_{k+1}^{(m)}(u,t)\big).$$

The offset by one avoids adjoining a $\bot$-like neutral element for the empty walk, which would be needed for a genuine identity matrix; nothing of substance is lost.

> **Theorem 7.2 (Max-plus Chapman–Kolmogorov).** Under (W1)–(W3), for all $m_1, m_2, k$ and $s,u \in S$,
> $$\mathcal{W}_k^{(m_1+m_2+1)}(s,u) \;=\; \max_{t \in S}\ \Big(\mathcal{W}_k^{(m_1)}(s,t) + \mathcal{W}_{k+m_1+1}^{(m_2)}(t,u)\Big).$$

*Proof.* Induction on $m_1$, with $m_2, k, s, u$ universally quantified.

*Base $m_1 = 0$.* The claim reduces to the defining recursion $\mathcal{W}_k^{(m_2+1)}(s,u) = \max_t\big(\mathrm{step}_k(s,t) + \mathcal{W}_{k+1}^{(m_2)}(t,u)\big)$.

*Step.* Unfold $\mathcal{W}_k^{(m_1+m_2+2)}$ one transition from the left, apply the inductive hypothesis to the resulting $\mathcal{W}_{k+1}^{(m_1+m_2+1)}$, and distribute (Lemma 2.1) to obtain a double maximum over intermediate states $(v, t)$ of $\mathrm{step}_k(s,v) + \mathcal{W}_{k+1}^{(m_1)}(v,t) + \mathcal{W}_{k+m_1+2}^{(m_2)}(t,u)$. Expanding the right-hand side of the claim by the defining recursion for $\mathcal{W}_k^{(m_1+1)}$ and distributing produces the same double maximum in the opposite order; Lemma 2.2 concludes. $\square$

In matrix language: writing $\mathcal{W}_k^{(m)}$ as an $S \times S$ matrix over $W$ and $\odot$ for max-plus matrix multiplication, Theorem 7.2 states
$$\mathcal{W}_k^{(m_1+m_2+1)} = \mathcal{W}_k^{(m_1)} \odot \mathcal{W}_{k+m_1+1}^{(m_2)},$$
i.e. the family of walk matrices is a *shifted semigroup* under max-plus multiplication. This is exactly the tropical analogue of the Chapman–Kolmogorov equation for Markov transition kernels, with $(\,\cdot\,, +)$ replacing $(\,\cdot\,, \times)$ and $\max$ replacing $\sum$; the Viterbi algorithm is to the forward algorithm as max-plus is to plus-times.

Two corollaries situate $V$ and $B$ in this algebra.

> **Corollary 7.3 (Right-appending a transition).** $\displaystyle \mathcal{W}_k^{(m+1)}(s,u) = \max_{t \in S}\big(\mathcal{W}_k^{(m)}(s,t) + \mathrm{step}_{k+m+1}(t,u)\big).$

*Proof.* Theorem 7.2 with $m_2 = 0$. $\square$

> **Theorem 7.4 (The value function is a max-plus action).** For all $m, k$ and $t \in S$,
> $$V(k+m+1, t) = \max_{s \in S}\ \big(V(k,s) + \mathcal{W}_k^{(m)}(s,t)\big).$$

*Proof.* Induction on $m$. The base case $m=0$ is Definition 3.4. The step unfolds $V$ one stage using Definition 3.4, applies the inductive hypothesis, and exchanges the resulting double maximum using Lemmas 2.1 and 2.2, exactly as in Theorem 7.2. $\square$

> **Theorem 7.5 (Backward values are walk row-maxima).** For all $m, k$ and $s \in S$,
> $$B(k, m+1, s) = \max_{t \in S} \mathcal{W}_k^{(m)}(s,t).$$

*Proof.* Induction on $m$, unfolding $B$ and $\mathcal{W}$ in parallel and exchanging maxima. $\square$

Theorem 7.4 is the *transfer* or *semigroup* property of dynamic programming: the whole computation from stage $k$ to stage $k+m+1$ can be summarised by a single matrix, independent of the initial data. This is what makes it possible to precompute segment tables for repeatedly-solved subproblems, to parallelise by binary-splitting the stage interval, and — in the stage-homogeneous case $\mathrm{step}_i = A$ for all $i$ — to compute $\mathcal{W}^{(m)} = A^{\odot(m+1)}$ by max-plus repeated squaring in $O(|S|^3 \log m)$ operations.

**Stage-independent weights.** As a degenerate but instructive case, if $\mathrm{step}_i(s,t) = c$ for all $i, s, t$, then for all $n \ge 0$ and all $t$,
$$V(n+1, t) = \Big(\max_{s \in S} \mathrm{init}(s)\Big) + (n+1)\cdot c,$$
where $(n+1)\cdot c$ is the $(n{+}1)$-fold monoid sum. The proof is a one-line induction using Lemma 2.1. The endpoint becomes irrelevant after the first stage — the specification has no discriminating power — which is a useful sanity check on the formalism.

---

## 8. Monotonicity, equivariance and stability

Weights in practice are estimated, and estimates are wrong. This section quantifies the resulting error. Throughout, (W1)–(W3) are assumed; (W5) — $W$ a linearly ordered abelian group — is assumed from Theorem 8.3 onward, so that $x - y$ and $|x|$ make sense.

> **Theorem 8.1 (Monotonicity in the specification).** Let $D, D'$ be specifications with $\mathrm{init}(s) \le \mathrm{init}'(s)$ for all $s$ and $\mathrm{step}_i(s,t) \le \mathrm{step}'_i(s,t)$ for all $i,s,t$. Then $V(n,s) \le V'(n,s)$ for all $n,s$, and $\mathrm{score}(f,n) \le \mathrm{score}'(f,n)$ for every labelling $f$.

*Proof.* Both by induction on $n$; the value case uses (W3) inside the maximum and then the fact that a maximum bounds each of its terms. $\square$

> **Theorem 8.2 (Equivariance under uniform shift).** Let $D^{a,b}$ be the specification with $\mathrm{init}^{a,b}(s) = \mathrm{init}(s) + a$ and $\mathrm{step}^{a,b}_i(s,t) = \mathrm{step}_i(s,t) + b$. Then for all $n$ and $s$,
> $$V^{a,b}(n,s) = V(n,s) + \big(a + n\cdot b\big),$$
> where $n \cdot b$ is the $n$-fold sum of $b$.

*Proof.* Induction on $n$. The base is the definition. For the step, each term of the maximum defining $V^{a,b}(n{+}1,t)$ equals $\big(V(n,s) + \mathrm{step}_n(s,t)\big) + \big(a + (n{+}1)\cdot b\big)$ by the inductive hypothesis and commutativity; pull the constant out of the maximum by Lemma 2.1. $\square$

Equivariance is the precise statement that "the optimum only cares about weight *differences*": adding a constant to every score of a fixed length cannot change which labellings are optimal, only the reported number. This is exactly why unnormalised log-probabilities suffice for Viterbi decoding.

> **Theorem 8.3 (Lipschitz stability of the optimum).** Assume (W5). If $|\mathrm{init}'(s) - \mathrm{init}(s)| \le a$ for all $s$ and $|\mathrm{step}'_i(s,t) - \mathrm{step}_i(s,t)| \le b$ for all $i,s,t$, then for all $n$ and $s$
> $$\big|V'(n,s) - V(n,s)\big| \le a + n\cdot b.$$

*Proof.* From $|x - y| \le c$ one extracts $x \le y + c$. Applying this to both signs of the two hypotheses gives one-sided comparisons $\mathrm{init}' \le \mathrm{init} + a$, $\mathrm{step}' \le \mathrm{step} + b$ and their swaps. Monotonicity (Theorem 8.1) compares $D'$ with the shifted specification $D^{a,b}$, and equivariance (Theorem 8.2) evaluates the latter: $V'(n,s) \le V(n,s) + (a + n\cdot b)$. Exchanging the roles of $D$ and $D'$ gives the other direction; combine. $\square$

> **Theorem 8.4 (Perturbation of individual scores).** Under the hypotheses of Theorem 8.3, for every labelling $f$ and every $n$, $\big|\mathrm{score}'(f,n) - \mathrm{score}(f,n)\big| \le a + n\cdot b$.

*Proof.* Induction on $n$: the difference at stage $n{+}1$ splits as (difference at stage $n$) $+$ (difference of the last transition weight), and the triangle inequality applies. $\square$

> **Theorem 8.5 (Near-optimality transfer).** Under the hypotheses of Theorem 8.3, suppose $g$ is optimal for the perturbed specification $D'$ at horizon $n$ (i.e. $\mathrm{score}'(f,n) \le \mathrm{score}'(g,n)$ for all $f$). Then for the true specification $D$,
> $$\mathrm{score}(f,n) \le \mathrm{score}(g,n) + 2\big(a + n\cdot b\big) \quad \text{for every labelling } f.$$

*Proof.* Chain three inequalities: $\mathrm{score}(f,n) \le \mathrm{score}'(f,n) + (a + n b)$ by Theorem 8.4; $\mathrm{score}'(f,n) \le \mathrm{score}'(g,n)$ by optimality of $g$ for $D'$; and $\mathrm{score}'(g,n) \le \mathrm{score}(g,n) + (a + nb)$ by Theorem 8.4 again. $\square$

> **Corollary 8.6 (Existence form).** Under (W1)–(W4) and (W5), there exists a labelling $g$ which is a run for $D'$ and satisfies $\mathrm{score}(f,n) \le \mathrm{score}(g,n) + 2(a + n\cdot b)$ for all $f$. (Non-vacuous: $g$ is produced by Theorem 4.5 applied to $D'$.)

The bound degrades *linearly* in the horizon $n$, not exponentially — the crucial qualitative point. It is also tight in the worst case: a specification in which every transition of the optimal path is underestimated by exactly $b$ realises the bound. The factor $2$ in Theorem 8.5 reflects the two independent model–reality crossings (evaluating the true optimum under the wrong model, and evaluating the wrong optimiser under the true model) and is likewise unimprovable in general.

---

## 9. Order duality: shortest paths for free

> **Definition 9.1 (Dual specification).** Given $D$ over $(S,W)$, let $D^{\mathrm{op}}$ denote the same data read in the order-dual weight monoid $W^{\mathrm{op}}$ — the same set and addition, with $\le$ reversed.

$W^{\mathrm{op}}$ satisfies (W1)–(W4) whenever $W$ does; and $\mathrm{score}^{\mathrm{op}}(f,n) = \mathrm{score}(f,n)$ as elements of the underlying set, since scores do not mention the order. But maxima in $W^{\mathrm{op}}$ are minima in $W$. Consequently every theorem above holds verbatim with all orders reversed:

> **Theorem 9.2 (Dual completeness / shortest paths).** For every labelling $f$ and every $n$ there exists $g$, a run of the dual dynamic program at horizon $n$, with $\mathrm{score}(g,n) \le \mathrm{score}(f,n)$. Moreover a single $g$ works uniformly for all $f$, and the dual value function $V^{\mathrm{op}}(n,s)$ is the *least* element of the set of scores of labellings ending at $s$.

This is the Bellman–Ford/Viterbi statement for minimisation — shortest paths in a layered digraph, minimum edit distance, minimum-cost scheduling. It costs nothing beyond noting that the duality respects the hypotheses. This is the main methodological dividend of stating the theory over an abstract ordered monoid rather than over $\mathbb{R}$ with $\max$: one proof, two theorems.

---

## 10. Completeness without cancellativity, and constrained dynamic programming

### 10.1 The structural notion of a run

Theorem 5.1 used (W4). The following alternative definition does not mention strict inequalities at all.

> **Definition 10.1 (Backtrace).** A labelling $f$ is a *backtrace* at horizon $n$ if the recursion is realised exactly at every stage:
> $$V\big(i, f(i)\big) + \mathrm{step}_i\big(f(i), f(i{+}1)\big) = V\big(i{+}1, f(i{+}1)\big) \quad \text{for all } i < n.$$

This is exactly what a backtracing implementation checks (and constructs) as it walks backwards through the table: at each step it selects a predecessor achieving the maximum. Where Definition 3.6 is semantic ("optimal at every prefix"), Definition 10.1 is *structural* ("generated by the recursion").

> **Theorem 10.2 (Structural $=$ semantic).** Under (W1)–(W3) only — no cancellativity — a labelling $f$ is a backtrace at horizon $n$ if and only if it is a run at horizon $n$.

*Proof.* ($\Rightarrow$) Show $\mathrm{score}(f,i) = V(i,f(i))$ for $i \le n$ by induction on $i$. Base: both equal $\mathrm{init}(f(0))$. Step: $\mathrm{score}(f, i{+}1) = \mathrm{score}(f,i) + \mathrm{step}_i(f(i),f(i{+}1)) = V(i,f(i)) + \mathrm{step}_i(f(i), f(i{+}1)) = V(i{+}1, f(i{+}1))$, the last equality being the backtrace condition.

($\Leftarrow$) Let $f$ be a run and $i < n$. Then $\mathrm{score}(f,i) = V(i,f(i))$ and $\mathrm{score}(f,i{+}1) = V(i{+}1, f(i{+}1))$. Substituting the first into the recursion for the score gives $V(i,f(i)) + \mathrm{step}_i(f(i), f(i{+}1)) = \mathrm{score}(f, i{+}1) = V(i{+}1, f(i{+}1))$, which is the backtrace condition at $i$. $\square$

Theorem 10.2 is the technical heart of this section. Note that it does *not* contradict the failure of Theorem 5.1 in the non-cancellative case: what fails there is the passage from *end*-optimality to the run condition, not the equivalence of the run condition with the backtrace condition. The moral is that end-optimality is the wrong notion of a run in general; the backtrace condition, being local, is the right one.

### 10.2 Realisability and completeness in full generality

> **Theorem 10.3 (Realisability, general form).** Under (W1)–(W3) with $S$ finite non-empty, for every $n$ and every $s \in S$ there is a labelling $f$ with $f(n) = s$ which is a backtrace (equivalently, by Theorem 10.2, a run) at horizon $n$.

*Proof.* Induction on $n$. For $n = 0$ the constant labelling at $s$ vacuously satisfies the (empty) backtrace condition. For $n+1$ and target $t$: pick $s^\ast$ attaining $V(n{+}1,t) = \max_s(V(n,s) + \mathrm{step}_n(s,t))$; by induction pick a backtrace $f$ with $f(n) = s^\ast$; splice, $g(i) := f(i)$ for $i \le n$ and $g(i) := t$ for $i > n$. For $i < n$ the backtrace condition for $g$ is that for $f$, since $g$ agrees with $f$ up to $n$. For $i = n$ it reads $V(n, s^\ast) + \mathrm{step}_n(s^\ast, t) = V(n{+}1,t)$, which is the choice of $s^\ast$. $\square$

Observe that the proof avoids Theorem 5.1 entirely — it verifies the backtrace condition directly rather than deducing it from end-optimality — and hence needs no cancellativity.

> **Theorem 10.4 (General completeness).** Under (W1)–(W3), for every labelling $f$ and every $n$ there exists a backtrace $g$ at horizon $n$ with $\mathrm{score}(f,n) \le \mathrm{score}(g,n)$; and there exists a single backtrace $g$ dominating all $f$ simultaneously.

*Proof.* As in Theorems 4.4 and 4.5, using Theorem 10.3 for existence and Theorem 4.1 (which never used (W4)) for domination. $\square$

> **Theorem 10.5 (General exactness).** Under (W1)–(W3), $V(n,s)$ is the greatest element of $\{\mathrm{score}(f,n) : f(n) = s\}$.

Thus the cancellativity hypothesis, present in the classical treatment, is dispensable. Theorem 4.2 is the special case of Theorem 10.3 obtained by transporting along Theorem 10.2.

### 10.3 Constrained dynamic programming over $\mathrm{WithBot}(W)$

Let $W^\bot := W \cup \{\bot\}$ with $\bot$ adjoined as a new least element and $\bot + w = w + \bot = \bot$. Then $W^\bot$ satisfies (W1)–(W3) and fails (W4). Constraints are encoded by giving forbidden transitions the weight $\bot$; absorption propagates infeasibility along the whole labelling.

> **Lemma 10.6 (Infeasibility of a labelling).** For a specification over $W^\bot$ and every labelling $f$,
> $$\mathrm{score}(f,n) = \bot \iff \mathrm{init}(f(0)) = \bot \ \text{ or } \ \exists\, i < n,\ \mathrm{step}_i\big(f(i), f(i{+}1)\big) = \bot.$$

*Proof.* Induction on $n$, using that a sum in $W^\bot$ is $\bot$ exactly when one of its summands is. $\square$

> **Theorem 10.7 (Characterisation of infeasibility).** For every $n$ and $s$,
> $$V(n,s) = \bot \iff \text{every labelling } f \text{ with } f(n) = s \text{ has } \mathrm{score}(f,n) = \bot.$$

*Proof.* ($\Rightarrow$) By Theorem 10.5, $V(n,s)$ is an upper bound for the scores of such labellings; if it is $\bot$, the least element, then every such score is $\le \bot$, hence $= \bot$.
($\Leftarrow$) By Theorem 10.5 the value is *attained* by some labelling $f$ with $f(n) = s$; by hypothesis $\mathrm{score}(f,n) = \bot$, so $V(n,s) = \bot$. $\square$

This is completeness in contrapositive form, and it is the statement one actually wants when deploying a constrained solver: the algorithm reporting "infeasible" constitutes a *proof* of infeasibility, not merely a failure to find a witness. Note that the ($\Leftarrow$) direction uses attainment — i.e. soundness — and would be false for a merely supremum-based value function.

### 10.4 Worked instance: maximum-weight independent set on a path

Consider the path $P_5$ with vertices $0,\dots,4$ carrying weights
$$w = (3,\ 7,\ 2,\ 8,\ 1).$$
We seek a set of vertices, no two adjacent, of maximum total weight.

Model this as a layered DP with $S = \{\texttt{false}, \texttt{true}\}$, where the state at stage $i$ records whether vertex $i$ is selected. Over $W^\bot = \mathrm{WithBot}(\mathbb{Z})$ define
$$\mathrm{init}(b) := \begin{cases} w_0 & b = \texttt{true}\\ 0 & b = \texttt{false}\end{cases}, \qquad
\mathrm{step}_i(b,c) := \begin{cases} \bot & b = c = \texttt{true} \\ w_{i+1} & b = \texttt{false},\, c = \texttt{true} \\ 0 & c = \texttt{false}.\end{cases}$$

The single $\bot$ entry encodes the independence constraint. Then:

- Every labelling selecting two consecutive vertices scores $\bot$ (immediate from Lemma 10.6).
- The optimum at horizon $4$ is
$$\max\big(V(4,\texttt{true}),\, V(4,\texttt{false})\big) = 15,$$
attained by the selection $\{1, 3\}$ of weight $7 + 8 = 15$.

The dynamic program touches $2 \times 5 = 10$ table cells rather than the $2^5 = 32$ subsets, and — importantly — the constraint is enforced *purely arithmetically*, with no side condition, no pruning heuristic, and no separate feasibility check. Theorem 10.4 guarantees the answer is exact; Theorem 10.7 would certify infeasibility had the instance been over-constrained.

For general instances, the state space grows with the interaction range: independent sets on a path of bandwidth $r$ require $S = \{0,1\}^r$, so the method is exponential in $r$ but linear in the number of vertices. This is the standard trade-off underlying tree-decomposition algorithms.

---

## 11. Algorithms and complexity

### 11.1 Forward pass

**Input:** $\mathrm{init} : S \to W$; $\mathrm{step}_i : S \times S \to W$ for $i < n$; horizon $n$.
**Output:** table $V(i,s)$ for $i \le n$, and argmax pointers $\pi(i{+}1, t)$.

```
V[0][s] ← init(s)                       for all s ∈ S
for i = 0 .. n-1:
    for t ∈ S:
        (best, arg) ← (−∞, undefined)
        for s ∈ S:
            c ← V[i][s] + step_i(s, t)
            if arg = undefined or c > best: (best, arg) ← (c, s)
        V[i+1][t] ← best ;  π[i+1][t] ← arg
```

The "$-\infty$" is only an initialisation convenience for the inner loop over the non-empty set $S$; no bottom element of $W$ is required. Cost: $\Theta(n|S|^2)$ monoid additions and comparisons; $\Theta(n|S|)$ memory (or $\Theta(|S|)$ if only the optimal value is required and pointers are discarded).

### 11.2 Backtrace

**Input:** the table $V$, the pointers $\pi$, a target endpoint $s$ (or the global argmax of $V(n,\cdot)$).
**Output:** a labelling $f$ with $f(n) = s$ which is a backtrace, hence a run, hence optimal.

```
f[n] ← s
for i = n-1 down to 0:
    f[i] ← π[i+1][f[i+1]]
```

Cost: $\Theta(n)$. Correctness is exactly Theorem 10.3: each pointer records a state attaining the maximum, so the backtrace condition of Definition 10.1 holds at every stage; Theorem 10.2 converts this to the run condition, and Theorems 3.8 and 4.1 give optimality.

### 11.3 Forward–backward

Compute $V(i, \cdot)$ for $i \le k$ forwards and $B(k, m, \cdot)$ backwards; then $\max_s\big(V(k,s) + B(k,m,s)\big)$ is the global optimum (Theorem 6.2) and $V(k,s) + B(k,m,s)$ is the best score subject to occupying state $s$ at stage $k$. Cost: $\Theta((k+m)|S|^2)$, i.e. the same order as a single forward pass, and the two passes are embarrassingly parallel.

### 11.4 Walk-matrix squaring (stage-homogeneous case)

If $\mathrm{step}_i = A$ for all $i$, then by Theorem 7.2 the walk matrices satisfy $\mathcal{W}^{(m_1+m_2+1)} = \mathcal{W}^{(m_1)} \odot \mathcal{W}^{(m_2)}$, so $\mathcal{W}^{(m)} = A^{\odot(m+1)}$ can be computed by max-plus repeated squaring in $\Theta(|S|^3 \log m)$ operations, after which Theorem 7.4 gives $V(m+1, \cdot)$ in $\Theta(|S|^2)$. This beats the $\Theta(m |S|^2)$ forward pass when $m \gg |S| / \log m$ — the tropical analogue of computing Markov chain $m$-step kernels by matrix powering.

### 11.5 Brute-force cross-check

For small instances the value function can be validated against exhaustive enumeration: generate all $|S|^{n+1}$ labellings of stages $0,\dots,n$, score each, and take the maximum over those ending at each state. Exactness (Theorem 4.3) predicts exact agreement. Cost: $\Theta(n|S|^{n+1})$ — feasible only for toy sizes, which is precisely the point of the theory.

### 11.6 A concrete three-state instance

Take $S = \{0,1,2\}$, $W = \mathbb{Z}$, $\mathrm{init}(s) = s$, and the stage-independent transition matrix
$$A = \begin{pmatrix} 2 & -1 & 3 \\ 1 & 0 & -2 \\ -3 & 4 & 1 \end{pmatrix}, \qquad A_{s,t} = \mathrm{step}_i(s,t).$$
The forward recursion gives
$$\begin{array}{c|ccc}
n & V(n,0) & V(n,1) & V(n,2)\\\hline
0 & 0 & 1 & 2\\
1 & 2 & 6 & 3\\
2 & 7 & 7 & 5\\
3 & 9 & 9 & 10
\end{array}$$
For example $V(1,1) = \max(0-1,\ 1+0,\ 2+4) = 6$, realised by the labelling $2 \to 1$; and $V(3,2) = 10$. Exhaustive enumeration over all $3^{n+1}$ labellings reproduces this table entry for entry, for each $n \le 3$ and each endpoint — an instance of Theorem 4.3. Likewise the transfer identity of Theorem 7.4 holds numerically at $k = 1$, $m = 2$: $V(4,t) = \max_s\big(V(1,s) + \mathcal{W}_1^{(2)}(s,t)\big)$ for each $t$.

---

## 12. Discussion

### 12.1 What the hypotheses buy

It is instructive to tabulate exactly which axioms each theorem consumes.

| Result | (W1) monoid | (W2) linear order | (W3) monotone $+$ | (W4) cancellative | finite $S$ |
|---|---|---|---|---|---|
| Sub-Bellman inequality (3.5) | ✓ | ✓ | | | ✓ |
| Domination / completeness bound (4.1) | ✓ | ✓ | ✓ | | ✓ |
| Realisability (10.3) | ✓ | ✓ | | | ✓ (attainment) |
| Structural $=$ semantic run (10.2) | ✓ | ✓ | | | ✓ |
| Exactness (10.5), completeness (10.4) | ✓ | ✓ | ✓ | | ✓ |
| Bellman optimality principle (5.1) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Characterisation of runs (5.2) | ✓ | ✓ | ✓ | ✓ | ✓ |
| Forward–backward (6.2), walk calculus (7.2–7.5) | ✓ | ✓ | ✓ | | ✓ |
| Stability (8.3–8.5) | ✓ | ✓ | ✓ | (W5) group instead | ✓ |

The pattern is clear: the *core* of dynamic programming — completeness, soundness, exactness, and the whole tropical calculus — needs only an ordered commutative monoid with monotone addition and a finite state space. Cancellativity is needed exactly for the statement that *end*-optimality propagates backwards, and even that becomes unnecessary once runs are defined structurally.

Finiteness of $S$ is used only for *attainment* of maxima. It could be replaced by any hypothesis guaranteeing attainment — compactness with upper semicontinuous weights, or well-foundedness of the reversed order (e.g. $\mathbb{N}$-valued weights bounded above). Without attainment one retains the domination half (with $V$ defined by suprema) but loses realisability, and hence the distinction between "supremum" and "greatest element" becomes real.

### 12.2 Relation to the literature

The optimality principle is due to Bellman; the layered decoding algorithm to Viterbi; the shortest-path recursion to Bellman and Ford. The observation that these live over the max-plus/min-plus semiring is the starting point of tropical mathematics and of the "algebraic path problem" tradition, where one solves $x = Ax \oplus b$ over a general semiring. The present treatment differs from the classical algebraic path problem in two respects. First, it is *layered and inhomogeneous*: the transition weights depend on the stage, so there is no fixed matrix whose closure is sought, and no need for a star operation or for convergence hypotheses. Second, it deliberately weakens the algebra: we assume no multiplicative identity for $+$ beyond the monoid unit, no idempotency beyond what $\max$ supplies, and — crucially — no cancellativity, allowing the absorbing $\bot$ that constrained problems demand.

The forward–backward decomposition specialises, in the plus-times semiring, to the classical forward–backward algorithm for hidden Markov models; in max-plus it gives max-marginals. The walk-matrix semigroup property is the tropical Chapman–Kolmogorov identity.

### 12.3 Limitations

- **Additivity and locality.** The score must decompose as a sum of terms each depending on at most two consecutive states. Longer-range interactions are handled only by enlarging the state space, at exponential cost in the interaction range.
- **Linearity of the order.** With a partial order, "the optimum" is replaced by a Pareto frontier, and $\max$ by an antichain of maximal elements. Domination survives in the form "every labelling is dominated by some maximal one", but uniform completeness (a single dominating run) genuinely fails.
- **Finite state space.** See §12.1.
- **Layered structure.** The stage index is $\mathbb{N}$. Tree- and DAG-shaped instances are handled by analogous but formally distinct recursions (see §12.4).

### 12.4 Future directions

**Support digraph certificates for constrained DP.** For a constrained specification over $W^\bot$, feasibility should be a purely combinatorial matter. Define the *support digraph* on stages by $s \to t$ at stage $i$ iff $\mathrm{step}_i(s,t) \ne \bot$. Conjecturally, $V(n,s) \ne \bot$ iff some state with $\mathrm{init} \ne \bot$ reaches $s$ along $n$ support edges; equivalently, the $W^\bot$-valued walk matrices have the same $\bot$-pattern as the Boolean powers of the support adjacency matrices. The key insight is that $\bot$ is absorbing for $+$ and least for $\le$, so $w \mapsto (w \ne \bot)$ is a semiring morphism from max-plus-with-bottom to the Boolean semiring; the entire walk algebra should therefore project onto Boolean matrix multiplication. Theorem 10.7 already reduces infeasibility to "all labellings score $\bot$"; the missing step is exactly this morphism.

**Tree-shaped completeness and the interchange law.** Does the completeness theorem hold verbatim for dynamic programming over rooted finite trees, with weights assigned to (parent-state, child-state) pairs and a child-aggregation operation? The forward pass becomes a post-order traversal and the exchange-of-maxima step becomes an interchange law between aggregation over children and maximisation over states. Identifying the minimal algebraic hypothesis making this go through would unify layered DP with tree DP and with tree-decomposition (bounded-treewidth) algorithms.

**Partially ordered weights and Pareto completeness.** Replace (W2) by a partial order and ask for the set of maximal achievable scores. The natural statement — every labelling is dominated by some run, where runs are now the "Pareto-optimal backtraces" — should hold, but requires a substitute for attainment of the maximum and for the exchange lemma.

**Sharpness of the stability constants.** Theorem 8.5 gives $2(a + nb)$. Determining the exact worst-case constant as a function of $|S|$ and $n$, and identifying the specifications realising it, would sharpen the robustness guarantees for models with estimated weights.

**Infinite horizon and discounting.** For $n \to \infty$ the score need not converge. Introducing a discount — an order-preserving contraction acting on $W$ — should yield a fixed-point form of the value function and a completeness theorem for infinite-horizon runs, connecting the present layered theory to the Bellman equations of Markov decision processes.

---

## 13. Conclusion

Dynamic programming is often presented as an algorithmic technique. The results above suggest it is better understood as a *theorem about ordered monoids*. Given a finite state space and weights that can be added, compared, and shifted monotonically, the local recursion
$$V(n{+}1,t) = \max_{s}\big(V(n,s) + \mathrm{step}_n(s,t)\big)$$
computes the exact global optimum over an exponentially large search space, exhibits a witness attaining it, and does so stably under perturbation of the data. Completeness — every labelling is dominated by some run of the recursion — is the half of this statement that certifies nothing has been missed, and it costs a two-line induction. Soundness is a splice-and-backtrace construction. The classical requirement that the weights be cancellative turns out to be an artefact of defining runs semantically; defined structurally, runs behave perfectly over any ordered weight monoid, which opens the theory to constrained problems where infeasibility is an absorbing weight. What remains, after all hypotheses have been stripped away, is a short list — add, order, monotonicity, attainment — and that list is the true content of Bellman's principle.
