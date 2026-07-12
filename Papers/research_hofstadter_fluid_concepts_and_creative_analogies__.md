# Analogy as a Mathematical Operation: Metric Fidelity, Adjoint Structure, and Tropical Optimization

## Abstract

We develop a mathematical theory of *analogy-making* inspired by Hofstadter's account of analogy as the core of cognition. An analogy between two structures $A$ and $B$ is formalized as a pair of maps $F : A \to B$ (forward) and $G : B \to A$ (backward), and the *quality* of the analogy is measured by its **distortion** — the largest displacement of a point under the round trip $G \circ F$. We prove that the identity ("copycat") analogy achieves the minimum possible distortion of zero, that zero distortion exactly characterizes a perfect left inverse, and that distortion is monotone and non-negative. We establish a **triangle inequality for analogies**: under a Lipschitz condition, distortions accumulate subadditively along a chain, $\varepsilon_f + L\varepsilon_g$, giving a controlled error budget for compositions of analogies. We disprove a natural but false conjecture — a perfect one-directional analogy need not be an equivalence — by an explicit collapse example. Turning to *structured* concepts, we model the canonical structure-preserving analogy between concept lattices as a Galois connection (an **adjoint analogy**) and show its round trips are monotone idempotent closure/kernel operators, that the backward map is uniquely determined by the forward map, and that the copycat analogy is a rigid, self-dual adjoint. Finally, we cast "making the best analogy" as an optimization over a finite pool of candidate costs and prove that it is solved by a single operation in the **tropical (min-plus) semiring**: the tropical sum of candidate costs equals the optimal cost, is attained by a candidate, and lower-bounds all candidates.

**Keywords:** analogy, distortion, fidelity, Galois connection, closure operator, tropical semiring, min-plus algebra, concept lattice, optimization.

## 1. Introduction

Hofstadter, in *Fluid Concepts and Creative Analogies*, argues that analogy-making is not a peripheral capacity of the mind but its central mechanism: perception, categorization, and creative insight are, at bottom, acts of analogy. His *Copycat* architecture models analogy as fluid mapping between concepts drawn from a lattice-like network. The present paper asks a mathematical question suggested by that program: *can analogy be treated as a mathematical operation with a measurable quality and a well-posed optimization?*

We give an affirmative and constructive answer across three registers.

1. **A metric theory (Section 3).** Modeling an analogy as a pair of maps and grading it by round-trip distortion yields a clean quantitative calculus: a perfect baseline (the copycat), an exact characterization of perfection, monotonicity, and — crucially — a composition law that bounds the distortion of a chain of analogies.

2. **An order-theoretic theory (Section 4).** When the structures carry order (concept lattices), the natural structure-preserving analogy is a Galois connection. Its round trips are closure/kernel operators, and the backward map is unique — the "best" inverse of an analogy is forced.

3. **A tropical optimization (Section 5).** Selecting the least-distortion analogy from a finite candidate pool is exactly addition in the min-plus semiring; a single tropical sum returns the optimum.

We also record a cautionary negative result (Section 3.5): perfect fidelity in one direction does not imply an equivalence.

## 2. Preliminaries and notation

We work with (pseudo)metric spaces and preorders. For a pseudometric space $A$, $\text{dist}(\cdot,\cdot)$ denotes its distance, satisfying $\text{dist}(x,x)=0$, symmetry, and the triangle inequality; a *metric* space additionally satisfies $\text{dist}(x,y)=0 \Rightarrow x=y$. A map $h$ between pseudometric spaces is **$L$-Lipschitz** if $\text{dist}(h(x),h(y)) \le L\cdot \text{dist}(x,y)$ for all $x,y$.

For preorders $(L,\le)$ and $(M,\le)$, a map is **monotone** if it preserves $\le$. The **tropical (min-plus) semiring** over an ordered value set is the set equipped with $x \oplus y := \min(x,y)$ as "addition" and ordinary $+$ as "multiplication"; its additive identity is $+\infty$. We use the value set $\mathbb{R} \cup \{+\infty\}$ (written $\overline{\mathbb{R}}_{+\infty}$), so that $+\infty$ models an infeasible candidate.

## 3. The metric theory of analogies

### 3.1 Definition

**Definition 3.1 (Analogy).** An **analogy** between structures $A$ and $B$ is a pair
$$f = (F, G), \qquad F : A \to B \ \text{(forward)}, \quad G : B \to A \ \text{(backward)}.$$
No compatibility between $F$ and $G$ is assumed a priori; the quality of $f$ is measured separately.

**Definition 3.2 (Identity / copycat analogy).** For a structure $A$, the **copycat analogy** $\mathrm{id}_A$ is the analogy on $A$ with $A=B$ and $F=G=\mathrm{id}$ the identity map.

**Definition 3.3 (Composition).** Given analogies $f=(F_f,G_f):A\to B$ and $g=(F_g,G_g):B\to C$, their composite $g\circ f : A\to C$ is
$$g\circ f := (F_g\circ F_f,\ \ G_f\circ G_g),$$
i.e. forward maps compose forward and backward maps compose backward.

**Definition 3.4 (Distortion and fidelity).** Let $A$ be a pseudometric space and $f=(F,G)$ an analogy from $A$ to $B$. For $\varepsilon \in \mathbb{R}$ we say $f$ has **fidelity $\varepsilon$** (equivalently, distortion at most $\varepsilon$) if
$$\text{dist}\big(a,\ G(F(a))\big) \le \varepsilon \qquad \text{for all } a \in A.$$
The **distortion** of $f$ is the least such $\varepsilon$ (the supremum of round-trip displacements).

### 3.2 The copycat is perfect and optimal

**Theorem 3.5 (Copycat fidelity).** *The copycat analogy $\mathrm{id}_A$ has fidelity $0$.*

*Proof.* The round trip is $\mathrm{id}\circ\mathrm{id}=\mathrm{id}$, so $\text{dist}(a, a)=0\le 0$ for all $a$. $\qquad\blacksquare$

**Theorem 3.6 (Non-negativity / optimality of $0$).** *If $A$ is nonempty and $f$ has fidelity $\varepsilon$, then $\varepsilon \ge 0$.*

*Proof.* Pick any $a\in A$. Then $0\le \text{dist}(a,G(F(a)))\le \varepsilon$. $\qquad\blacksquare$

Together, Theorems 3.5 and 3.6 show that $0$ is the minimum achievable distortion, attained by the copycat.

**Theorem 3.7 (Monotonicity in the bound).** *If $\varepsilon \le \varepsilon'$ and $f$ has fidelity $\varepsilon$, then $f$ has fidelity $\varepsilon'$.*

*Proof.* For each $a$, $\text{dist}(a,G(F(a)))\le\varepsilon\le\varepsilon'$. $\qquad\blacksquare$

### 3.3 Zero distortion characterizes a perfect left inverse

**Theorem 3.8 (Fidelity-zero characterization).** *Let $A$ be a metric space (points at distance $0$ are equal) and $f=(F,G)$ an analogy from $A$ to $B$. Then $f$ has fidelity $0$ if and only if $G(F(a))=a$ for every $a\in A$.*

*Proof.* ($\Rightarrow$) Fidelity $0$ gives $\text{dist}(a,G(F(a)))\le 0$, hence $=0$; by the metric axiom, $G(F(a))=a$. ($\Leftarrow$) If $G(F(a))=a$ then $\text{dist}(a,G(F(a)))=\text{dist}(a,a)=0\le 0$. $\qquad\blacksquare$

Thus "distortion $0$" is not a soft quality label but an exact equation: $G$ is a left inverse of $F$.

### 3.4 The triangle inequality for analogies

The central quantitative result is that distortion behaves subadditively under composition, so chains of good analogies remain good.

**Theorem 3.9 (Composition bound).** *Let $A,B$ be pseudometric spaces and let $f:A\to B$, $g:B\to C$ be analogies. Suppose*
- *$f$ has fidelity $\varepsilon_f$,*
- *$g$ has fidelity $\varepsilon_g$,*
- *the backward map $G_f$ of $f$ is $L$-Lipschitz with $L\ge 0$.*

*Then the composite $g\circ f$ has fidelity $\varepsilon_f + L\,\varepsilon_g$.*

*Proof.* Fix $a\in A$ and set $b := F_f(a)$. The round trip of $g\circ f$ sends $a$ to $G_f\big(G_g(F_g(b))\big)$. By the triangle inequality,
$$\text{dist}\big(a,\ G_f(G_g(F_g(b)))\big) \le \text{dist}(a, G_f(b)) + \text{dist}\big(G_f(b),\ G_f(G_g(F_g(b)))\big).$$
The first term is $\text{dist}(a,G_f(F_f(a)))\le\varepsilon_f$ by fidelity of $f$. For the second, $L$-Lipschitzness of $G_f$ gives
$$\text{dist}\big(G_f(b), G_f(G_g(F_g(b)))\big) \le L\cdot \text{dist}\big(b, G_g(F_g(b))\big) \le L\cdot \varepsilon_g,$$
using fidelity of $g$ at the point $b$ and $L\ge 0$. Summing yields the bound $\varepsilon_f + L\varepsilon_g$. $\qquad\blacksquare$

**Corollary 3.10 (Chains stay good).** *A composition $f_n\circ\cdots\circ f_1$ of analogies with fidelities $\varepsilon_1,\dots,\varepsilon_n$ and backward Lipschitz constants $L_1,\dots,L_n$ has fidelity bounded by a telescoping sum $\varepsilon_1 + L_1\varepsilon_2 + L_1L_2\varepsilon_3 + \cdots$, obtained by iterating Theorem 3.9.*

This makes precise the conjecture that *creative insight decomposes into a sequence of analogy operations*: each step contributes a bounded, trackable amount of distortion, and the total never exceeds the accumulated budget.

### 3.5 Perfect one-sided analogies are not equivalences

It is tempting to believe that fidelity $0$ (perfect forward-then-back) forces the reverse composite $F\circ G$ to also be the identity, i.e. a genuine equivalence. This is false.

**Theorem 3.11 (Collapse counterexample).** *There is an analogy $f=(F,G)$ from $A=\{\ast\}$ (a single point) to $B=\mathbb{R}$ with fidelity $0$, yet $F(G(1))\ne 1$.*

*Proof.* Let $F(\ast)=0$ and $G(x)=\ast$ for all $x$. Since $A$ has one element, $G(F(\ast))=\ast$, so the round trip on $A$ is the identity and $f$ has fidelity $0$ (Theorem 3.8). But $F(G(1))=F(\ast)=0\ne 1$. $\qquad\blacksquare$

Interpretation: fidelity is a *directional* guarantee. A perfect analogy in one direction may collapse enormous information in the other — the mathematical shadow of over-trusted metaphors that run reliably one way but disastrously in reverse.

## 4. The adjoint (Galois) model on concept lattices

When the structures being compared carry order — concept lattices in the sense of formal concept analysis — the natural structure-preserving analogy is a Galois connection. This section shows the analogical round trips are exactly the stable (idempotent, monotone) operators, and that the backward analogy is uniquely determined.

### 4.1 Definition

**Definition 4.1 (Adjoint analogy).** Let $(L,\le)$ and $(M,\le)$ be preorders. An **adjoint analogy** is a pair of maps $l:L\to M$ and $u:M\to L$ forming a **Galois connection**:
$$l(a) \le b \iff a \le u(b) \qquad \text{for all } a\in L,\ b\in M.$$
Here $l$ is the forward analogy (lower adjoint) and $u$ the backward analogy (upper adjoint). Both are automatically monotone.

### 4.2 Round trips are stable operators

**Theorem 4.2 (Extensivity).** *For an adjoint analogy $l\dashv u$ and every $a\in L$, $\ a \le u(l(a))$.*

*Proof.* Apply the defining equivalence to $b=l(a)$: from $l(a)\le l(a)$ we get $a\le u(l(a))$. $\qquad\blacksquare$

**Theorem 4.3 (Round trip is a closure operator).** *For an adjoint analogy with $L$ a partial order, $u\circ l$ is idempotent: $u(l(u(l(a)))) = u(l(a))$ for all $a$.*

*Proof.* This is the standard $u\,l\,u = u$ identity of Galois connections, specialized: $u\circ l$ is extensive (Thm 4.2), monotone (Thm 4.5), and satisfies $u\,l\,u\,l = u\,l$, hence is a closure operator. $\qquad\blacksquare$

**Theorem 4.4 (Dual: kernel operator).** *For an adjoint analogy with $M$ a partial order, $l\circ u$ is idempotent: $l(u(l(u(b)))) = l(u(b))$ for all $b\in M$; i.e. $l\circ u$ is a kernel/interior operator.*

*Proof.* Dual to Theorem 4.3, using $l\,u\,l = l$. $\qquad\blacksquare$

**Theorem 4.5 (Monotone round trip).** *The round trip $u\circ l$ is monotone.*

*Proof.* Both $l$ and $u$ are monotone (each adjoint of a Galois connection is), and a composite of monotone maps is monotone. $\qquad\blacksquare$

The "best" analogies in this order-theoretic setting are exactly the stable ones: the round trip converges after a single application to a fixed refined concept and cannot be perturbed by further analogizing.

### 4.3 Uniqueness of the backward analogy

**Theorem 4.6 (Uniqueness of the adjoint).** *Let $L,M$ be partial orders. If $l:L\to M$ admits two backward maps $u_1,u_2$ with $l\dashv u_1$ and $l\dashv u_2$, then $u_1=u_2$.*

*Proof.* Fix $b\in M$. From $l(u_1(b))\le b$ (counit of the first connection) and the second connection's equivalence, $u_1(b)\le u_2(b)$. Symmetrically $u_2(b)\le u_1(b)$. Antisymmetry gives $u_1(b)=u_2(b)$; as $b$ was arbitrary, $u_1=u_2$. $\qquad\blacksquare$

So once the forward analogy is fixed, the *best* backward analogy (its adjoint), when it exists, is forced — a uniqueness/rigidity phenomenon absent in the purely metric setting.

### 4.4 The copycat is a rigid, self-dual adjoint

**Theorem 4.7 (Copycat is adjoint).** *On any preorder $L$, the copycat analogy $(\mathrm{id}_L,\mathrm{id}_L)$ is an adjoint analogy.*

*Proof.* The equivalence $\mathrm{id}(a)\le b \iff a\le \mathrm{id}(b)$ is $a\le b\iff a\le b$. $\qquad\blacksquare$

**Theorem 4.8 (Copycat rigidity).** *On a partial order $L$, if $u:L\to L$ satisfies $\mathrm{id}_L\dashv u$, then $u=\mathrm{id}_L$.*

*Proof.* By Theorem 4.7, $\mathrm{id}_L$ is an adjoint of $\mathrm{id}_L$; by uniqueness (Theorem 4.6), any adjoint $u$ of $\mathrm{id}_L$ equals $\mathrm{id}_L$. $\qquad\blacksquare$

Hofstadter's copycat — a concept lattice compared to itself — is therefore a perfect, self-dual analogy with zero distortion, and it is the *unique* such analogy: seeing a structure as itself admits no alternative best translation back.

## 5. Making the best analogy: a tropical optimization

We now formalize "making a good analogy" as an optimization and show it is solved by a single tropical operation.

### 5.1 The optimization problem

**Definition 5.1 (Candidate pool and cost).** A **candidate pool** is a finite index set $s$ together with a **cost** function $\text{cost}:s\to \overline{\mathbb{R}}_{+\infty}$, where $\text{cost}(i)$ is the distortion of candidate analogy $i$ and $+\infty$ marks an infeasible candidate. The **best analogy** is a minimizer of $\text{cost}$ over $s$.

**Theorem 5.2 (The optimum exists).** *Over a nonempty finite pool with real costs, there exists $i\in s$ with $\text{cost}(i)\le \text{cost}(j)$ for all $j\in s$.*

*Proof.* A real-valued function on a nonempty finite set attains its minimum. $\qquad\blacksquare$

### 5.2 Tropical aggregation

**Definition 5.3 (Tropical score).** For a pool $(s,\text{cost})$ with $\text{cost}:s\to\overline{\mathbb{R}}_{+\infty}$, the **tropical score** is the tropical sum of the candidate costs,
$$\mathrm{Score}(s,\text{cost}) := \bigoplus_{i\in s}\text{cost}(i) \quad\text{where } x\oplus y = \min(x,y),$$
with the empty sum equal to the tropical zero $+\infty$.

**Theorem 5.4 (Tropical sum is the minimum).** *The tropical score equals the infimum (minimum) of the candidate costs:*
$$\mathrm{Score}(s,\text{cost}) = \inf_{i\in s}\text{cost}(i).$$

*Proof.* Tropical addition is $\min$, and a finite tropical sum unfolds to the iterated minimum, which is the finite infimum. $\qquad\blacksquare$

**Theorem 5.5 (Lower bound).** *For every $j\in s$, $\ \mathrm{Score}(s,\text{cost})\le \text{cost}(j)$.*

*Proof.* By Theorem 5.4 the score is the infimum over $s$, and an infimum lower-bounds each element. $\qquad\blacksquare$

**Theorem 5.6 (Attainment).** *Over a nonempty pool, some candidate achieves the score: there is $i\in s$ with $\mathrm{Score}(s,\text{cost})=\text{cost}(i)$.*

*Proof.* The finite infimum over a nonempty set is attained; by Theorem 5.4 the score equals that attained value. $\qquad\blacksquare$

**Theorem 5.7 (The tropical sum is the best analogy's cost).** *Over a nonempty finite pool, the tropical score is achieved by some candidate and lower-bounds all candidates:*
$$\big(\exists\, i\in s:\ \mathrm{Score}(s,\text{cost})=\text{cost}(i)\big)\ \wedge\ \big(\forall\, j\in s:\ \mathrm{Score}(s,\text{cost})\le \text{cost}(j)\big).$$

*Proof.* Combine Theorems 5.6 and 5.5. $\qquad\blacksquare$

Thus "make the best analogy" — minimize distortion over the pool — is solved by a *single* tropical addition of the candidate scores. There is no iterative search beyond aggregating the costs in the min-plus semiring; the tropical sum *is* the optimum, and the infeasible candidates ($+\infty$) neutrally drop out.

## 6. Algorithms

**Algorithm A (Best-analogy selection via tropical aggregation).** Given a finite pool with a cost oracle, fold the costs under $\min$ (tropical addition), tracking the achieving index. Returns the optimal cost and a minimizer. Complexity $O(n)$ in the pool size $n$ (Theorem 5.7 guarantees correctness).

**Algorithm B (Chain distortion budget).** Given analogies $f_1,\dots,f_n$ with fidelities $\varepsilon_i$ and backward Lipschitz constants $L_i$, compute the accumulated distortion bound $\varepsilon_1 + L_1\varepsilon_2 + L_1L_2\varepsilon_3 + \cdots$ by a single left-to-right fold (Corollary 3.10). Complexity $O(n)$.

**Algorithm C (Adjoint construction and verification).** Given a forward monotone map $l$ on finite lattices, construct the candidate adjoint $u(b) := \max\{a : l(a)\le b\}$ and verify the Galois equivalence; by Theorem 4.6 the result, if it exists, is unique. Complexity $O(|L|\cdot|M|)$ for verification.

## 7. Applications

- **Model/representation transfer.** An analogy $F:A\to B$ with backward $G$ and small distortion is a lossy encoder/decoder; Theorem 3.9 bounds the end-to-end error of a pipeline of such encoders, and Theorem 3.11 warns that a good decoder for $A$ need not reconstruct $B$.
- **Concept alignment and ontology matching.** Aligning two concept hierarchies by a Galois connection guarantees stable, idempotent alignment (Theorems 4.3–4.5) and a unique backward alignment (Theorem 4.6).
- **Analogy search / metaphor selection.** Ranking candidate analogies by distortion and selecting the best is a min-plus aggregation (Section 5), directly implementable as a linear scan.

## 8. Discussion

The theory isolates three complementary facets of analogy: a *quantitative* facet (distortion, with a compositional error calculus), a *structural* facet (Galois adjunction, with rigidity and uniqueness), and a *computational* facet (tropical optimization). The copycat — seeing a structure as itself — appears in all three as the perfect, rigid baseline. The negative result of Theorem 3.11 is a reminder that faithfulness is directional and that the leap from "left inverse" to "equivalence" is unjustified.

## 9. Future directions

1. **Sharp composition constant.** Theorem 3.9 gives $\varepsilon_f + L\varepsilon_g$. Is this optimal over all metric spaces, and what is the tight constant for two-sided (bidirectional) Lipschitz control?
2. **Two-sided analogies and the isomorphism gap.** Quantify the failure in Theorem 3.11 via a bidirectional distortion $\max\big(\sup_a \text{dist}(a,G(F(a))),\ \sup_b \text{dist}(b,F(G(b)))\big)$ and characterize when it vanishes (genuine isometric analogy) versus one-sidedly (retraction).
3. **Existence of optimal analogies over infinite pools.** Extend Section 5 from finite pools to compact or complete families, seeking attainment via lower semicontinuity of distortion.
4. **Tropical structure of reasoning.** If *selecting* the best analogy is tropical addition and *chaining* accumulates distortion, is the full creative-reasoning process a computation in a richer tropical/idempotent algebra?

## 10. Conclusion

We have shown that analogy-making admits a rigorous mathematical treatment as an operation with a measurable quality. Distortion grades analogies; the copycat is the perfect, optimal, and (in the order-theoretic setting) rigid baseline; good analogies compose with a controlled error budget; perfect one-sided analogies need not be equivalences; the backward map of a structural analogy is unique; and choosing the best analogy from a finite pool is exactly a tropical sum. Hofstadter's vision of analogy as the core of thought thus acquires, at least in outline, an algebraic and metric skeleton.
