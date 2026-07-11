# Cellular Automata at the Ordinals: Transfinite Computation via Monotone Least Fixed Points

## Abstract

We establish a rigorous bridge between two *a priori* unrelated subjects: the dynamics of cellular automata and the theory of ordinal (transfinite) computation. The connecting device is the classical theory of monotone operators on complete lattices and their least fixed points computed by transfinite iteration. We exhibit a concrete one-dimensional cellular automaton—the *spreading automaton* on the cells $\mathbb{N}$, with a permanent source at the origin and unit-speed rightward propagation—and prove three facts that, taken together, exhibit genuinely transfinite behaviour. First, the automaton is a bona fide radius-$1$, monotone cellular automaton, and its finite-time evolution from the empty configuration lights exactly the initial segment $\{0,1,\dots,k-1\}$ after $k$ steps. Second, *no finite stage completes the computation*: for every natural number $k$, the configuration is a proper subset of the fully-on configuration. Third, under the transfinite iteration governed by the standard limit rule of Infinite Time Turing Machines (take the limit inferior, which for a monotone run is the union of all earlier configurations), the automaton completes *exactly* at the first limit ordinal $\omega$, at which stage every cell is on—and this fully-on configuration is precisely the least fixed point of the rule. Thus the automaton's **closure ordinal is exactly $\omega$**. We conclude with the general connector: for *any* monotone cellular-automaton rule on *any* complete-lattice configuration space, the global fixed point is a value of the transfinite ordinal evolution. This mirrors, at the level of cellular automata, the way Infinite Time Turing Machines strictly exceed ordinary Turing machines.

**Keywords.** Cellular automata; ordinal computation; transfinite iteration; monotone operators; least fixed points; complete lattices; Infinite Time Turing Machines; closure ordinals.

---

## 1. Introduction

A *cellular automaton* is a discrete dynamical system in which a fixed local rule is applied uniformly and simultaneously to every cell of a lattice. Despite the extreme simplicity of the local rule, cellular automata can display arbitrarily complex global behaviour; Rule 110 is famously Turing-complete. Traditionally the dynamics unfold in discrete *finite* time: one applies the global update map $t = 0, 1, 2, \dots$ and studies the resulting orbit.

*Ordinal computation* asks what happens when a computational process is allowed to proceed past the finite stages into the transfinite: through $\omega, \omega+1, \dots, \omega \cdot 2, \dots, \omega^2, \dots$. The paradigm is the theory of **Infinite Time Turing Machines** (ITTMs), which run for ordinal time and, at *limit* stages—ordinals with no immediate predecessor—resolve the tape by a *limit rule*, typically the *limit inferior* of the earlier tape contents. ITTMs decide problems far beyond the reach of ordinary Turing machines, giving a robust notion of super-Turing computation.

The purpose of this paper is to make precise, and prove, the sense in which *cellular automata run at the ordinals strictly exceed their finite-time counterparts*. Our central tool is the theory of monotone operators on complete lattices. A monotone cellular-automaton rule is a monotone operator on the configuration lattice; its transfinite iteration from the bottom element—applying the rule at successor stages and taking suprema at limit stages—is exactly the constructive, ordinal-indexed computation of the *least fixed point* guaranteed by the Knaster–Tarski theorem. This identifies:

- one CA step with a successor stage of the iteration;
- the ITTM limit rule (limit inferior / union) with a limit stage of the iteration;
- the completed computation with the least fixed point of the rule.

We instantiate this dictionary on a minimal but genuine example, the spreading automaton, and prove that its closure ordinal is exactly $\omega$.

### 1.1 The dictionary

| Cellular automaton | Ordinal computation |
| :--- | :--- |
| configuration space | a complete lattice $\alpha$ |
| local monotone update rule | a monotone operator $f : \alpha \to \alpha$ |
| one CA step | successor stage of the transfinite iteration |
| limit-of-time (ITTM $\liminf$) rule | limit stage of the transfinite iteration (supremum) |
| the completed computation | the least fixed point $\mathrm{lfp}(f)$ |

---

## 2. Preliminaries

### 2.1 Complete lattices and monotone operators

A **complete lattice** is a partially ordered set $(\alpha, \le)$ in which every subset $S \subseteq \alpha$ has a least upper bound (supremum) $\bigvee S$ and a greatest lower bound (infimum) $\bigwedge S$. In particular it has a bottom element $\bot = \bigvee \varnothing$ and a top element $\top$. The motivating example for cellular automata is the power set $\mathcal{P}(X)$ of any set $X$, ordered by inclusion, with supremum given by union and infimum by intersection; here $\bot = \varnothing$ and $\top = X$.

An operator $f : \alpha \to \alpha$ is **monotone** if $a \le b$ implies $f(a) \le f(b)$. Monotonicity captures the intuition that "turning on more input can only turn on more output"—for a cellular automaton, that adding live cells never kills a cell that would otherwise be alive.

### 2.2 The Knaster–Tarski theorem and its constructive form

**Theorem (Knaster–Tarski).** Every monotone operator $f$ on a complete lattice $\alpha$ has a least fixed point $\mathrm{lfp}(f)$, characterized as the least element $x$ with $f(x) = x$, equivalently the least *prefixed point* (least $x$ with $f(x) \le x$).

The least fixed point admits an explicit *constructive* description by transfinite iteration. Define an ordinal-indexed family $g : \mathrm{Ord} \to \alpha$ by

$$
g(\beta) \;=\; \bigvee \Bigl(\{\, f(g(\gamma)) : \gamma < \beta \,\} \cup \{\bot\}\Bigr).
$$

Read concretely, this says:
- $g(0) = \bot$ (the empty configuration);
- at a **successor** $\beta = \gamma + 1$, one has $g(\gamma+1) = f(g(\gamma))$—apply the rule once more;
- at a **limit** $\lambda$, one has $g(\lambda) = \bigvee_{\gamma < \lambda} g(\gamma)$—take the supremum (union) of all earlier stages.

Because $\alpha$ is a set, the ordinal-indexed sequence $g$ cannot be strictly increasing forever; it stabilizes at some ordinal, and its stable value is exactly $\mathrm{lfp}(f)$. We write $g(\beta)$ for the stage-$\beta$ approximant. The least ordinal at which $g$ reaches $\mathrm{lfp}(f)$ is the **closure ordinal** of $f$.

When $f$ is monotone, the map $\beta \mapsto g(\beta)$ is itself monotone in $\beta$, and the successor rule specializes to ordinary finite iteration at natural-number stages: $g(n) = f^{[n]}(\bot)$, the $n$-fold composite of $f$ applied to $\bot$.

### 2.3 The limit rule and Infinite Time Turing Machines

An Infinite Time Turing Machine runs the ordinary transition function at successor stages of ordinal time and, at each limit stage, sets each cell of the tape to the *limit inferior* of its earlier values: a cell reads $1$ at the limit iff it is *eventually always* $1$ (equivalently, for a value that only ever increases, iff it is $1$ at some earlier stage). For a **monotone** run—one in which cells never switch from on to off—the limit inferior of the cell traces coincides with the *union* of all earlier configurations. This is precisely the supremum rule $g(\lambda) = \bigvee_{\gamma<\lambda} g(\gamma)$ of the constructive least-fixed-point iteration. This coincidence is the technical heart of the bridge: **the ITTM limit rule and the least-fixed-point limit rule agree on monotone runs.**

---

## 3. The spreading cellular automaton

### 3.1 Definition

We work on the one-dimensional lattice of cells $\mathbb{N} = \{0, 1, 2, \dots\}$. A **configuration** is a subset $S \subseteq \mathbb{N}$, interpreted as the set of "on" cells; the configuration space is the complete lattice $(\mathcal{P}(\mathbb{N}), \subseteq)$.

**Definition (spreading rule).** The *spreading automaton* is the operator
$$
\mathrm{spread}(S) \;=\; \{0\} \cup \{\, n+1 : n \in S \,\}.
$$
In words: after one step, cell $0$ is on (a permanent source at the origin), and cell $m$ is on for $m \ge 1$ iff its left neighbour $m-1$ was on.

**Proposition 3.1 (Monotonicity).** $\mathrm{spread}$ is a monotone operator on $\mathcal{P}(\mathbb{N})$.

*Proof.* If $S \subseteq T$ then $\{n+1 : n \in S\} \subseteq \{n+1 : n \in T\}$, and inserting the source $0$ into both preserves the inclusion. $\qquad\blacksquare$

**Proposition 3.2 (Locality).** For every configuration $S$ and every cell $n$,
$$
n \in \mathrm{spread}(S) \iff n = 0 \ \text{ or } \ \bigl(n > 0 \ \text{and}\ n-1 \in S\bigr).
$$
Hence $\mathrm{spread}$ is a genuine cellular automaton of radius $1$: the state of cell $n$ after one step depends only on the source and on the single left neighbour $n-1$.

*Proof.* ($\Rightarrow$) If $n \in \{0\} \cup \{m+1 : m \in S\}$ then either $n = 0$, or $n = m+1$ for some $m \in S$; in the latter case $n > 0$ and $n - 1 = m \in S$. ($\Leftarrow$) If $n = 0$ then $n$ is the inserted source. If $n > 0$ and $n-1 \in S$ then $n = (n-1)+1$ lies in the image, since $n - 1 \in S$. $\qquad\blacksquare$

### 3.2 Finite-time behaviour

Let $\mathrm{Iio}(k) = \{0, 1, \dots, k-1\}$ denote the initial segment of length $k$ (so $\mathrm{Iio}(0) = \varnothing$).

**Theorem 3.3 (Finite orbit).** For every $k \in \mathbb{N}$,
$$
\mathrm{spread}^{[k]}(\varnothing) \;=\; \{0, 1, \dots, k-1\} \;=\; \mathrm{Iio}(k).
$$

*Proof.* By induction on $k$. For $k = 0$, the zero-fold iterate is the identity, giving $\varnothing = \mathrm{Iio}(0)$. For the inductive step, assume $\mathrm{spread}^{[k]}(\varnothing) = \mathrm{Iio}(k)$. Then
$$
\mathrm{spread}^{[k+1]}(\varnothing) = \mathrm{spread}\bigl(\mathrm{Iio}(k)\bigr) = \{0\} \cup \{\, n+1 : 0 \le n < k \,\} = \{0\} \cup \{1, 2, \dots, k\} = \mathrm{Iio}(k+1).
$$
By Proposition 3.2, $x \in \mathrm{spread}(\mathrm{Iio}(k))$ iff $x = 0$ or ($x > 0$ and $x - 1 < k$), i.e. iff $x < k+1$. $\qquad\blacksquare$

The picture is a wave of "on" cells advancing rightward at unit speed:
$$
\varnothing \ \to\ \{0\} \ \to\ \{0,1\} \ \to\ \{0,1,2\} \ \to\ \cdots
$$

**Theorem 3.4 (No finite stage completes).** For every $k \in \mathbb{N}$,
$$
\mathrm{spread}^{[k]}(\varnothing) \ne \mathbb{N}.
$$
Consequently, at every finite time the configuration is a *proper* subset of the fully-on configuration.

*Proof.* By Theorem 3.3, $\mathrm{spread}^{[k]}(\varnothing) = \mathrm{Iio}(k)$, and the cell $k \notin \mathrm{Iio}(k)$ (since $k \not< k$), whereas $k \in \mathbb{N}$. Hence the two sets differ. $\qquad\blacksquare$

Theorem 3.4 is the negative half of the transfinite phenomenon: the computation whose intended output is "all cells on" *cannot be completed at any finite deadline*.

### 3.3 The intended output as a least fixed point

**Theorem 3.5 (Least fixed point).** The least fixed point of $\mathrm{spread}$ is the fully-on configuration:
$$
\mathrm{lfp}(\mathrm{spread}) \;=\; \mathbb{N}.
$$

*Proof.* Write $L = \mathrm{lfp}(\mathrm{spread})$, so $\mathrm{spread}(L) = L$ by the fixed-point property. We show every cell lies in $L$ by induction. Base case: $0 \in \mathrm{spread}(L) = L$ since $0$ is always inserted. Inductive step: if $m \in L$, then $m + 1 \in \mathrm{spread}(L) = L$ because $m+1 = m+1$ with $m \in L$ lies in the image. Hence $L = \mathbb{N}$. Since $\mathbb{N} = \top$ is the greatest element, and $L \le \top$ always, we conclude $L = \mathbb{N}$. (That $\mathbb{N}$ is itself a fixed point is immediate: $\mathrm{spread}(\mathbb{N}) = \{0\} \cup \{n+1 : n \in \mathbb{N}\} = \mathbb{N}$.) $\qquad\blacksquare$

Thus the "intended answer" is not an arbitrary target but the canonical least fixed point selected by the Knaster–Tarski theorem.

---

## 4. Transfinite behaviour: the main results

Let $g(\beta) = g_{\mathrm{spread}}(\beta)$ denote the stage-$\beta$ approximant of the constructive least-fixed-point iteration from $\bot = \varnothing$, as in §2.2.

**Lemma 4.1 (Finite stages match iteration).** For every natural number $n$,
$$
g(n) \;=\; \mathrm{spread}^{[n]}(\varnothing).
$$

*Proof.* By induction on $n$. At $n = 0$, the approximant $g(0)$ is the supremum of the empty family together with $\bot$, which is $\bot = \varnothing = \mathrm{spread}^{[0]}(\varnothing)$. At a successor, the constructive iteration satisfies $g(n+1) = \mathrm{spread}(g(n))$; by the inductive hypothesis $g(n) = \mathrm{spread}^{[n]}(\varnothing)$, so $g(n+1) = \mathrm{spread}(\mathrm{spread}^{[n]}(\varnothing)) = \mathrm{spread}^{[n+1]}(\varnothing)$. $\qquad\blacksquare$

**Theorem 4.2 (The limit rule is the union of all finite stages).**
$$
g(\omega) \;=\; \bigcup_{n \in \mathbb{N}} \mathrm{spread}^{[n]}(\varnothing).
$$

*Proof.* ($\subseteq$) By definition $g(\omega) = \bigvee\bigl(\{\mathrm{spread}(g(\gamma)) : \gamma < \omega\} \cup \{\bot\}\bigr)$. Every $\gamma < \omega$ is a natural number $n$, and $\mathrm{spread}(g(n)) = g(n+1) = \mathrm{spread}^{[n+1]}(\varnothing)$ by Lemma 4.1 and the successor rule; and $\bot = \mathrm{spread}^{[0]}(\varnothing)$. Hence every element of the family taking the supremum is one of the finite iterates, so $g(\omega) \subseteq \bigcup_n \mathrm{spread}^{[n]}(\varnothing)$.

($\supseteq$) For each fixed $n$, Lemma 4.1 gives $\mathrm{spread}^{[n]}(\varnothing) = g(n)$, and monotonicity of $\beta \mapsto g(\beta)$ with $n < \omega$ gives $g(n) \le g(\omega)$. Taking the union over $n$ yields the reverse inclusion. $\qquad\blacksquare$

This is precisely the ITTM limit rule specialized to a monotone run: at the limit stage $\omega$, a cell is on iff it was on at some finite stage.

**Theorem 4.3 (Completion at $\omega$).**
$$
g(\omega) \;=\; \mathbb{N}.
$$
Every cell is on at the first limit ordinal.

*Proof.* By Theorem 4.2, $g(\omega) = \bigcup_n \mathrm{spread}^{[n]}(\varnothing) = \bigcup_n \mathrm{Iio}(n)$ using Theorem 3.3. Given any cell $n$, we have $n \in \mathrm{Iio}(n+1)$, hence $n$ lies in the union. Thus the union is all of $\mathbb{N}$. $\qquad\blacksquare$

**Corollary 4.4 (Closure ordinal exactly $\omega$).** Combining Theorems 3.4, 3.5, and 4.3:
$$
g(\omega) = \mathrm{lfp}(\mathrm{spread}) = \mathbb{N}, \qquad \text{yet} \qquad g(n) \ne \mathbb{N} \ \text{ for every } n \in \mathbb{N}.
$$
The spreading automaton reaches its least fixed point at the transfinite stage $\omega$ and at no finite stage. Its **closure ordinal is exactly $\omega$**.

This is the precise sense in which the transfinite run strictly exceeds every finite run: a concrete, unambiguous computation—light every cell—is provably impossible to complete in finite time yet completed at the first infinite ordinal.

---

## 5. The general bridge

The spreading automaton is an instance of a completely general phenomenon.

**Theorem 5.1 (Cellular fixed points are transfinitely computable).** Let $\alpha$ be any complete lattice and let $f : \alpha \to \alpha$ be any monotone operator (an arbitrary monotone cellular-automaton rule on an arbitrary configuration space). Then the least fixed point $\mathrm{lfp}(f)$ is a value of the transfinite ordinal iteration: there exists an ordinal $\beta$—the closure ordinal of $f$—such that $g_f(\beta) = \mathrm{lfp}(f)$, where $g_f$ is the constructive iteration of §2.2. Moreover $g_f$ is monotone in the stage, applies $f$ at successors, and takes suprema (the ITTM limit rule for monotone runs) at limits.

*Proof.* This is the constructive form of the Knaster–Tarski theorem (§2.2). The ordinal-indexed sequence $g_f$ is monotone; since $\alpha$ is a set it cannot strictly increase through a proper class of ordinals, so it stabilizes at some ordinal $\beta$, and the stable value is a fixed point of $f$. One checks it is the *least* prefixed point, hence $\mathrm{lfp}(f)$. The successor and limit rules hold by the defining recursion of $g_f$. $\qquad\blacksquare$

Theorem 5.1 is the abstract connector foreshadowed by the dictionary of §1.1: *the global fixed point of any monotone cellular-automaton rule is reached by transfinite ordinal iteration*, with one CA step per successor stage and the ITTM limit rule at limit stages. The spreading automaton realizes the simplest nontrivial case, with closure ordinal $\omega$.

---

## 6. Algorithms

Two computational procedures underlie the results. Both operate on *finite representations* of configurations (initial segments and threshold indices), which suffices because all approximants of the spreading automaton are downward-closed initial segments.

### 6.1 Finite-stage simulation

To compute the configuration after $k$ finite steps, iterate the local rule $k$ times from the empty set. For the spreading automaton the result is always an initial segment, so we may represent a configuration by its length. The general (set-based) simulation runs in $O(k \cdot w)$ time where $w$ bounds the size of the live region, and is used to *witness* Theorems 3.3 and 3.4 for concrete $k$.

### 6.2 Closure-ordinal detection

To detect the closure ordinal, iterate the rule, taking a union (limit inferior) at the simulated limit stage $\omega$, and test for a fixed point. For a monotone rule on a decidable, finitely-presentable lattice this yields the *stabilization stage*: the first ordinal (represented symbolically) at which two consecutive approximants agree. For the spreading automaton the finite iterates never stabilize (each is a strict superset of the previous), while the union at $\omega$ is a fixed point—detecting closure ordinal exactly $\omega$.

---

## 7. Applications and discussion

**Super-Turing computation via automata.** The result gives a cellular-automaton mascot for the ITTM phenomenon: a fixed local rule that, run on the ordinals, completes a task provably beyond every finite deadline. The closure ordinal becomes a quantitative measure of a computation's transfinite content.

**Fixed-point semantics.** Least-fixed-point iteration is the backbone of denotational semantics, inductive definitions, and datalog-style query evaluation. The bridge here reframes those iterations as *cellular-automaton dynamics run at the ordinals*, and conversely gives cellular-automata a clean semantics as monotone least-fixed-point computations.

**A hierarchy of closure ordinals.** By enriching the lattice one can climb the transfinite staircase. On the grid $\mathcal{P}(\mathbb{N} \times \mathbb{N})$, the rule "fill row $i+1$ only once row $i$ is complete" completes each of infinitely many rows in $\omega$ steps and hence closes at $\omega^2$. Analogous constructions target $\omega + 1$, $\omega \cdot 2$, and beyond. The scaffolding used for the spreading automaton—the successor rule, monotonicity in the stage, and the characterization of limit stages as suprema—generalizes directly; the remaining work is computing the limit stages $\bigvee_{\gamma < \lambda} g(\gamma)$ at each limit $\lambda$.

**Limits of monotonicity.** The clean fixed-point story requires monotonicity. Rule 110 and other computationally universal automata are *not* monotone (cells oscillate), so the least-fixed-point machinery does not apply verbatim. There the appropriate device is the genuine ITTM limit inferior on the cell traces, and the goal becomes a *simulation* theorem rather than a fixed-point theorem.

---

## 8. Future work

1. **Closure ordinals beyond $\omega$.** Design monotone CA rules whose least fixed point is reached only at $\omega+1$, $\omega \cdot 2$, $\omega^2$, and prove the exact closure ordinal. The $\omega^2$ target is met by a grid rule that fills row $i+1$ only once row $i$ is complete; the work is computing the limit stages at each limit ordinal.

2. **A Rule-110 analog.** Rule 110 is not monotone, so the least-fixed-point machinery does not apply verbatim. Two routes: (a) study a monotone sub-shift / growth restriction of Rule-110-like dynamics where the fixed-point iteration applies; or (b) model the genuinely non-monotone limit dynamics with the ITTM limit-inferior rule directly (limit inferior of the Boolean cell traces) and prove a simulation result.

3. **ITTM connection, formalized.** Define an Infinite Time Turing Machine tape as a Boolean bi-infinite sequence evolving over the ordinals with the limit-inferior limit rule, and prove that the monotone CA studied here is *simulated* by such a machine, so that the CA's closure ordinal is an ITTM halting time.

---

## 9. Conclusion

We have exhibited a concrete, minimal cellular automaton whose computation is genuinely transfinite: provably impossible to complete in any finite number of steps, yet completed exactly at the first infinite ordinal $\omega$, where it reaches its canonical least-fixed-point output. Behind the example stands a general correspondence: every monotone cellular-automaton rule on every complete-lattice configuration space computes its global fixed point by transfinite ordinal iteration, with one automaton step per successor stage and the Infinite Time Turing Machine limit rule at limit stages. Cellular automata, run at the ordinals, strictly exceed their finite-time counterparts—precisely as Infinite Time Turing Machines exceed ordinary Turing machines.
