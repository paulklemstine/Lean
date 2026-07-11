# A Combinatorial Theory of Anti-Gravity Theorems: Weight, Cheapness, and the Structure of Dependency

## Abstract

We introduce a finite combinatorial model of mathematical libraries in which each theorem is a vertex of a directed *dependency graph* and an edge $a \to b$ records that theorem $b$ uses theorem $a$ in its proof. Within this model we define the **gravitational weight** of a theorem as the number of theorems that depend on it, and we call a theorem **anti-gravity** when it combines *high weight* with a *short proof*. We prove a coherent collection of results about this notion: a handshake identity equating total weight with total dependency count; tight upper bounds on weight; an averaging principle guaranteeing a heaviest theorem carrying at least the average load; a pigeonhole existence theorem giving precise conditions under which an anti-gravity theorem must exist; a monotonicity theorem showing that, under transitive dependency, more foundational theorems are heavier; and two families of fully explicit witnesses — a *linear* library realizing weight $\Theta(n)$ and a *grid* library realizing weight $\Theta(n\cdot m)$, each with constant proof length. Finally we refute, by explicit counterexample, the folklore universal claims that anti-gravity theorems appear in *every* library and that a fixed fraction (e.g. 10%) of theorems are anti-gravity: a dependency-free library contains none. The result is a precise, honest account of a phenomenon that is structural but not universal.

**Keywords:** dependency graph, gravitational weight, anti-gravity theorem, handshake lemma, double counting, averaging principle, pigeonhole, transitive relation, proof length.

## 1. Introduction

Mathematical folklore holds that a handful of theorems in any subject do a disproportionate share of the work: they have short, memorable proofs yet appear in the proofs of a vast number of downstream results. The Fundamental Theorem of Algebra, once complex analysis is available, is proved in a few lines but underwrites an enormous body of algebra. This article makes the phenomenon precise. We call such theorems **anti-gravity** — echoing the physical fantasy of a device that provides great lift for negligible effort — because they provide great mathematical *support* (many dependents) for negligible *cost* (a short proof).

Our contributions are:

1. A minimal finite model (Section 2) of a library as a finite vertex set with a decidable dependency relation, together with the definitions of gravitational weight, in-degree, proof length, and anti-gravity.
2. Structural identities and bounds (Section 3): a handshake/double-counting identity and sharp weight bounds.
3. An averaging principle and a pigeonhole existence theorem for anti-gravity theorems (Section 4), giving the exact hypothesis under which existence is forced.
4. A monotonicity theorem under transitive dependency (Section 5): foundations are heaviest.
5. Explicit constructions realizing linear and quadratic weight with constant proof length (Section 6).
6. A refutation of the over-strong universal predictions (Section 7).

We are careful throughout to separate what is *provable* from what is *folklore*. Two of the theme's most quotable claims — "density in the space of all theorems" and "exactly 10% of theorems are anti-gravity" — do not survive scrutiny as universal statements, and we say so precisely.

## 2. The model

**Definition 2.1 (Library).** A *library* is a finite type $V$ (the theorems) equipped with a decidable binary relation $D$ on $V$. We read $D(a,b)$ as "$b$ depends on $a$", i.e. theorem $a$ is used in the proof of theorem $b$. We write $N = |V|$ for the number of theorems.

**Definition 2.2 (Gravitational weight).** The *gravitational weight* of a theorem $a \in V$ is the number of theorems that depend on it:
$$w(a) \;=\; \#\{\, b \in V : D(a,b) \,\}.$$

**Definition 2.3 (In-degree).** The *in-degree* of a theorem $b \in V$ is the number of theorems it directly depends on:
$$d(b) \;=\; \#\{\, a \in V : D(a,b) \,\}.$$

**Definition 2.4 (Proof length).** A *proof-length function* is any function $\ell : V \to \mathbb{N}$; $\ell(a)$ measures the cost (steps, lines, or cited lemmas) of the proof of $a$.

**Definition 2.5 (Anti-gravity theorem).** Fix a weight threshold $w_0 \in \mathbb{N}$, a length bound $\ell_0 \in \mathbb{N}$, and a proof-length function $\ell$. A theorem $a$ is *anti-gravity at $(w_0, \ell_0)$* if
$$w(a) \ge w_0 \qquad\text{and}\qquad \ell(a) \le \ell_0,$$
i.e. it has high weight and a short proof.

These definitions are deliberately spare: no acyclicity, no connectivity, no metric on statements is assumed. Every theorem below holds at this level of generality unless a hypothesis is stated explicitly.

## 3. Conservation and bounds

**Theorem 3.1 (Handshake identity).** For every library,
$$\sum_{a \in V} w(a) \;=\; \sum_{b \in V} d(b).$$

*Proof sketch.* Both sides count the same object — the set of dependency pairs $\{(a,b) : D(a,b)\}$ — organized differently. Writing each weight and in-degree as a sum of indicator terms, $w(a) = \sum_b [D(a,b)]$ and $d(b) = \sum_a [D(a,b)]$, the two double sums differ only in the order of summation, so they are equal by commuting the two finite sums. $\qquad\blacksquare$

The identity is the discrete analogue of a conservation law: the total *support* offered by all theorems equals the total *reliance* consumed by all theorems. Every dependency edge is counted once from each end.

**Theorem 3.2 (Weight ceiling).** For every $a \in V$, $\; w(a) \le N$.

*Proof sketch.* The dependents of $a$ form a subset of $V$, and a subset of an $N$-element set has at most $N$ elements. $\qquad\blacksquare$

**Theorem 3.3 (Strict ceiling under irreflexivity).** If $V$ is nonempty and $D$ is irreflexive (no theorem depends on itself, $\neg D(a,a)$ for all $a$), then $w(a) < N$ for every $a$.

*Proof sketch.* Under irreflexivity, $a$ is never one of its own dependents, so the set of dependents of $a$ is a *proper* subset of $V$ (it omits $a$), and a proper subset of a finite set has strictly smaller cardinality. $\qquad\blacksquare$

Irreflexivity is the mild and natural assumption that no proof cites the very theorem it is proving; under it, no single theorem can support the entire library.

## 4. Averaging and the existence of anti-gravity theorems

**Theorem 4.1 (A heaviest theorem exists).** If $V$ is nonempty, there is a theorem $a^\star \in V$ with $w(b) \le w(a^\star)$ for all $b \in V$.

*Proof sketch.* The weight function takes values in $\mathbb{N}$ on the nonempty finite set $V$; a real- or integer-valued function on a nonempty finite set attains its maximum. $\qquad\blacksquare$

**Theorem 4.2 (Averaging bound).** If $a^\star$ is a theorem of maximum weight, then
$$\sum_{b \in V} w(b) \;\le\; N \cdot w(a^\star).$$
Equivalently, $w(a^\star) \ge \frac{1}{N}\sum_b w(b)$: the heaviest theorem carries at least the average weight.

*Proof sketch.* Bound each summand $w(b)$ by the maximum $w(a^\star)$ and sum over the $N$ theorems. $\qquad\blacksquare$

The averaging bound guarantees a heavy theorem, but heaviness alone is not anti-gravity — we must locate a heavy theorem *among the cheap ones*. The next theorem does exactly this by applying the averaging idea to the restricted population of short-proof theorems.

**Theorem 4.3 (Existence of anti-gravity theorems).** Let $S = \{\, a \in V : \ell(a) \le \ell_0 \,\}$ be the set of short-proof theorems, and suppose $S$ is nonempty. If
$$|S| \cdot w_0 \;\le\; \sum_{a \in S} w(a),$$
then there exists a theorem $a \in S$ that is anti-gravity at $(w_0, \ell_0)$.

*Proof sketch.* Let $a$ maximize $w$ over the nonempty finite set $S$; then $a$ has a short proof by construction. If $a$ were *not* anti-gravity, we would have $w(a) < w_0$, and since $a$ is the maximizer, $w(b) < w_0$ for every $b \in S$. Summing this strict bound over the $|S|$ elements of $S$ gives $\sum_{a\in S} w(a) < |S|\cdot w_0$, contradicting the hypothesis. Hence $w(a) \ge w_0$ and $a$ is anti-gravity. $\qquad\blacksquare$

Theorem 4.3 is the precise, provable rendering of the slogan "anti-gravity theorems exist." Existence is *not* automatic; it is forced exactly when the cheap theorems, as a collective, carry at least $w_0$ weight on average. When the short-proof theorems do enough total lifting, one of them must be a hidden pillar.

## 5. Foundations are heaviest

**Theorem 5.1 (Monotonicity of weight under transitive dependency).** Suppose $D$ is transitive: whenever $D(a,b)$ and $D(b,c)$, also $D(a,c)$. Then $D(a,b)$ implies
$$w(b) \le w(a).$$

*Proof sketch.* Suppose $D(a,b)$. Every dependent $c$ of $b$ satisfies $D(b,c)$; combined with $D(a,b)$ and transitivity, $D(a,c)$, so $c$ is also a dependent of $a$. Thus the dependents of $b$ inject into the dependents of $a$, and cardinalities give $w(b) \le w(a)$. $\qquad\blacksquare$

Interpreted along a transitive dependency order (for instance the reflexive-transitive closure of "directly uses"), weight is monotone toward the foundations: the deeper and more basic a theorem, the more theorems accumulate above it, and the greater its gravitational weight. Since foundational results also tend to have the shortest proofs, this theorem is the structural reason anti-gravity theorems cluster at the base of a subject.

## 6. Explicit witnesses

The existence theorem is non-constructive. We now exhibit fully explicit libraries in which anti-gravity theorems can be pointed to, with prescribed weight growth.

### 6.1 The linear library

**Construction 6.1.** For $n \ge 1$, let $V = \{0, 1, \dots, n-1\}$ with $D(i,j) \iff i < j$: each theorem depends on all earlier theorems.

**Theorem 6.2 (Bottom weight, linear case).** In the linear library on $n$ theorems, the bottom theorem $0$ has weight
$$w(0) = n - 1.$$

*Proof sketch.* The dependents of $0$ are exactly the theorems $j$ with $0 < j$, namely $1, 2, \dots, n-1$, of which there are $n-1$. Formally the dependent set of $0$ is the whole universe with the single element $0$ removed. $\qquad\blacksquare$

**Theorem 6.3 (Linear anti-gravity witness).** In the linear library on $n \ge 1$ theorems with proof-length function $\ell \equiv 1$, the bottom theorem $0$ is anti-gravity at thresholds $(w_0, \ell_0) = (n-1, 1)$.

*Proof sketch.* By Theorem 6.2, $w(0) = n-1 \ge w_0 = n-1$, and $\ell(0) = 1 \le \ell_0 = 1$. Both anti-gravity conditions hold. $\qquad\blacksquare$

This is a non-vacuous witness whose weight grows linearly, $\Theta(n)$, while its proof length is fixed at $1$.

### 6.2 The grid library

**Construction 6.4.** For $n, m \ge 1$, let $V = \{0,\dots,n-1\} \times \{0,\dots,m-1\}$ (an $n$-row, $m$-column grid) with $D(p,q) \iff p_{\mathrm{row}} < q_{\mathrm{row}}$: a node depends on another exactly when the latter lies in a strictly later row.

**Theorem 6.5 (Bottom-row weight, grid case).** In the grid library, a node $p$ in the bottom row (row $0$) has weight
$$w(p) = (n-1)\cdot m.$$

*Proof sketch.* The dependents of $p$ are all nodes $q$ with row index strictly greater than $0$, i.e. every node in rows $1, \dots, n-1$. There are $n-1$ such rows and $m$ nodes per row, giving $(n-1)\cdot m$ dependents. $\qquad\blacksquare$

**Theorem 6.6 (Quadratic anti-gravity witness).** In the grid library with proof-length function $\ell \equiv 1$, a bottom-row node is anti-gravity at thresholds $\bigl((n-1)\cdot m,\, 1\bigr)$.

*Proof sketch.* By Theorem 6.5 the node's weight equals $(n-1)\cdot m \ge w_0$, and its proof length is $1 \le \ell_0$. $\qquad\blacksquare$

Taking $m = \Theta(n)$ yields weight $\Theta(n^2)$ with constant proof length: a single lemma silently underwriting a quadratic family of consequences. This realizes precisely the folklore "$O(n^2)$ weight, $O(1)$ proof" example.

## 7. The limits of universality

Having established that anti-gravity theorems exist under explicit conditions and can be exhibited with any desired growth rate, we now show that the *universal* forms of the folklore are false.

**Theorem 7.1 (No dependencies, no anti-gravity).** Let $V$ be any library equipped with the empty dependency relation $D \equiv \bot$ (no theorem depends on any other). Then for every positive weight threshold $w_0 \ge 1$, every proof-length function $\ell$, and every length bound $\ell_0$, there is **no** anti-gravity theorem: the set of anti-gravity theorems is empty.

*Proof sketch.* With the empty relation, the dependent set of any $a$ is empty, so $w(a) = 0$ for all $a$. Anti-gravity requires $w(a) \ge w_0 \ge 1$, which $0$ cannot satisfy. Hence no theorem is anti-gravity. $\qquad\blacksquare$

**Corollary 7.2.** The following universal claims are false:
- *"Anti-gravity theorems exist in every library."* Refuted by Theorem 7.1.
- *"A fixed positive fraction (e.g. 10%) of the theorems in any library are anti-gravity."* Refuted by Theorem 7.1, where the fraction is exactly $0$.

**Remark 7.3 (On "density in the space of all theorems").** The theme also proposes that anti-gravity theorems are *dense* in a suitable topology on "the space of all theorems." This is underspecified rather than false: there is no canonical topology on that space. Under the discrete topology the claim is vacuous (every set is dense in itself and closed); under an edit-distance (Levenshtein) metric on statement strings it becomes a genuine but model-dependent question. We deliberately do not assert it as a theorem, since no honest universal formulation is available.

## 8. Discussion

The model isolates a real structural phenomenon. Anti-gravity is the joint occurrence of two orthogonal quantities — *weight* (a global, network property) and *cheapness* (a local, per-proof property). The theory says three concrete things about their interaction:

- **Existence is conditional, not automatic** (Theorem 4.3): anti-gravity theorems are forced precisely when cheap theorems collectively lift a lot.
- **Weight concentrates at the foundations** (Theorem 5.1): under transitive dependency, basic theorems are heaviest, which — since basic theorems tend to be cheap — is why anti-gravity clusters at the base of a subject.
- **The phenomenon is tunable** (Section 6): explicit libraries realize any linear or quadratic weight profile with constant proof length.

At the same time the theory is honest about its limits (Section 7): there is no law delivering a universal positive fraction of anti-gravity theorems, because sparse libraries have none. The famous "10%" is an empirical regularity of how humans actually build mathematics, not a theorem about all possible dependency structures.

### Applications

- **Prioritizing verification.** In a large formal corpus, anti-gravity theorems are the highest-leverage audit targets: an undetected flaw in a high-weight theorem propagates the furthest, and its short proof makes such a flaw both more surprising and cheaper to re-check.
- **Curriculum and exposition.** The results explain why introductory courses lead with short-proof, high-weight theorems: those are the load-bearing members, and their cheapness is what makes them safe foundations.
- **Library refactoring.** The handshake identity and averaging bound give quick global health metrics (total edges, maximum weight) for a growing library, and the monotonicity theorem suggests that consolidating dependencies onto a few transitive foundations concentrates and clarifies weight.

## 9. Future work

- **Transitive closure.** Systematically study weight with respect to the reflexive-transitive closure of the direct-dependency relation, quantifying how indirect dependency amplifies weight.
- **Random libraries.** Analyze the expected number and weight distribution of anti-gravity theorems in random dependency graphs (e.g. random DAG models), to characterize *when* the empirical "10%" regime emerges.
- **A defensible topology.** Formulate the density question over an explicit metric on statements (such as edit distance) and settle it in that model.
- **Weighted proofs.** Replace the binary short/long dichotomy with a continuous cost measure and study the Pareto frontier of (weight, cost).

## 10. Conclusion

We have given a compact, self-contained theory of anti-gravity theorems: definitions, a conservation identity, sharp bounds, an averaging principle, a pigeonhole existence theorem, a foundations-are-heaviest monotonicity theorem, explicit linear and quadratic witnesses, and an honest refutation of the over-strong universal claims. The dream of enormous lift for negligible effort is impossible in physics; in mathematics it is commonplace — and now precisely characterized.
