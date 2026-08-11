# Doppelgänger Phase-Lock: A Complete Theory of Synchronization for Identical Reactive Agents

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Two spatially separated but structurally identical deterministic agents observe the same environmental stimulus stream. Under what conditions do they arrive, after finitely many observations, at exactly the same internal state — regardless of how differently they were initialized? We develop a complete theory of this phenomenon, which we call **doppelgänger phase-lock**.

We prove a **Synchronization Theorem**: for a finite internal state space, the existence of a universal locking stimulus word is equivalent to the mergeability of every individual pair of states, with an explicit bound of $(|S|-1)L$ on the locking time when pairs merge within $L$ stimuli, and an unconditional bound of $(|S|-1)|S|^2$. As a corollary, phase-lockability is a decidable property of an agent design. We complement this with three sharp boundary results: a **reversibility obstruction** showing that phase-lock is impossible whenever every stimulus acts injectively (synchronization requires dissipation); a counterexample on an infinite state space (the *countdown agent*) showing that pairwise mergeability does not imply global phase-lock without finiteness; and a **no-signalling theorem** proving that, in the product system, each agent's state depends only on its own initial state and its own stimuli, so phase-lock is a shared-cause correlation rather than a communication channel.

We then determine how typical phase-lock is. Locking words form a two-sided ideal of the free stimulus monoid, from which a block-counting argument yields a failure fraction of at most $(1-q^{-1})^m$ over $m$ blocks with $q=|I|^L$ block values, tending to zero. Topologically, in the Cantor space of infinite stimulus streams, the lock set is always open and — for a phase-locking design — dense, giving a **zero–one law**: the lock set is either empty or open and dense with nowhere-dense complement. We show this is sharp: for Černý's three-state agent the lock set is neither closed nor everything.

We supply an analytic mechanism (uniform contraction with factor $k<1$ forces exponential collapse of the doppelgänger gap, and quantization upgrades this to exact locking uniformly in the stream) and prove it strictly stronger than the phenomenon: an agent with one bijective stimulus admits no contractive metric, yet may phase-lock. A structural calculus establishes that phase-lock is preserved by parallel composition (locking times add), by surjective simulation, and functorially by stimulus relabelling; for monotone agents on a linear order we prove **order rigidity** — locking the two extreme states locks everything — improving the bound to $|S|^2$. Finally, certified exhaustive search establishes exact minimal phase-lock times $4=(3-1)^2$ and $9=(4-1)^2$ for the three- and four-state Černý agents, situating the theory against the Černý conjecture, which in this language asks for the exact worst-case phase-lock time of a synchronizable agent.

**Keywords:** synchronizing word, reset sequence, deterministic automaton, Černý conjecture, transition monoid, contraction mapping, zero–one law, no-signalling.

---

## 1. Introduction

### 1.1 The phenomenon

Consider two copies of one machine, built to the same blueprint and separated in space, with no communication link of any kind. Their initial internal configurations are unknown and may differ arbitrarily. The environment then emits a stream of stimuli, and — crucially — *both copies observe the same stream*. Each reacts privately and deterministically.

It can happen that after finitely many observations the two copies occupy *exactly* the same internal state, and that this holds regardless of their initial states. To an outside observer, the two machines have spontaneously agreed. The suggestive framing is "telepathic synchronization"; the mathematics dissolves the suggestion entirely, and does so in a way that is much more interesting than the framing.

The formal content of the phenomenon is classical in one guise: a word that maps all states of a deterministic automaton to a single state is a *synchronizing word*, or *reset sequence*. What is developed here is a systematic theory of the phenomenon as a statement about *pairs of separated agents*, with attention paid equally to what the phenomenon permits and to what it forbids. The negative half — the reversibility obstruction, the necessity of finiteness, the necessity of identical stimuli, and no-signalling — is as much the subject as the positive half.

### 1.2 Contributions

1. **Core algebra** (§3): the stimulus monoid acts on the state space; the locking words form a two-sided ideal; phase-lock is equivalent to the transition monoid containing a constant (rank-one) element.
2. **Synchronization Theorem** (§4): finiteness converts pairwise mergeability into global locking, with quantitative bounds $(|S|-1)L$ and unconditionally $(|S|-1)|S|^2$; rank is antitone and locking words are exactly the rank-one words.
3. **Boundaries** (§5): reversibility obstruction; failure of the theorem on infinite state spaces; no-signalling and the indispensability of identical stimuli.
4. **Genericity** (§6): geometric decay of the failure fraction under blind driving; a topological zero–one law for the lock set, together with a sharpness witness.
5. **Analytic mechanism** (§7): contraction implies exponential and then exact phase-lock; the mechanism is strictly stronger than the phenomenon.
6. **Structural calculus** (§8): behaviour under parallel composition, coarse-graining, relabelling; order rigidity and a quadratic bound for monotone agents.
7. **Effectivity and extremal data** (§9): decidability of phase-lockability; exact minimal locking times $4$ and $9$ for the three- and four-state Černý agents.

---

## 2. The model

**Definition 2.1 (Agent).** An *agent* consists of a set $S$ of internal states, a set $I$ of environmental stimuli, and a transition rule
$$\delta : S \times I \longrightarrow S.$$
We write $\delta(s,i)$ for the state entered from $s$ upon observing $i$. The agent is deterministic and memoryless beyond its state.

**Definition 2.2 (Drive).** For a finite stimulus word $w = i_1 i_2 \cdots i_n \in I^{*}$ define $\mathrm{drive}(w, \cdot) : S \to S$ by left fold:
$$\mathrm{drive}(\varepsilon, s) = s, \qquad \mathrm{drive}(i \cdot w, s) = \mathrm{drive}(w, \delta(s,i)).$$
Thus $\mathrm{drive}(w,s)$ is the state reached from $s$ after observing $w$ left to right.

**Lemma 2.3 (Composition).** For all $w, v \in I^{*}$ and $s \in S$,
$$\mathrm{drive}(wv, s) = \mathrm{drive}(v, \mathrm{drive}(w, s)).$$

*Proof.* Immediate from the fold characterization: folding over a concatenation is folding over the first list and then over the second. $\square$

For an infinite stimulus stream $x : \mathbb{N} \to I$ we write $x{\restriction}n$ for its length-$n$ prefix $x_0 x_1 \cdots x_{n-1}$.

**Definition 2.4 (Locking, mergeability, phase-lock).**
- $w \in I^{*}$ **locks** $\delta$ if $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ for all $s,t \in S$.
- A pair $(s,t)$ is **mergeable** if $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ for some $w \in I^{*}$.
- $\delta$ is **phase-locking** if some word locks it.

The interpretation is exactly the doppelgänger picture. Two separated copies of $\delta$, in unknown states $s$ and $t$, both fed $w$, end in states $\mathrm{drive}(w,s)$ and $\mathrm{drive}(w,t)$. A locking word forces these to agree for every $(s,t)$.

**Proposition 2.5 (Constant characterization).** For $S$ nonempty, $w$ locks $\delta$ if and only if there is $c \in S$ with $\mathrm{drive}(w,s) = c$ for all $s$.

*Proof.* If $w$ locks, fix any $s_0$ and take $c = \mathrm{drive}(w,s_0)$. Conversely, constancy gives equality of all pairs. $\square$

---

## 3. The core algebra of locking

### 3.1 Locking is absorbing, and forms an ideal

**Lemma 3.1 (Suffix stability).** If $w$ locks $\delta$ then so does $wv$ for every $v$.

*Proof.* $\mathrm{drive}(wv,s) = \mathrm{drive}(v,\mathrm{drive}(w,s)) = \mathrm{drive}(v,\mathrm{drive}(w,t)) = \mathrm{drive}(wv,t)$. $\square$

**Lemma 3.2 (Prefix stability).** If $w$ locks $\delta$ then so does $uw$ for every $u$.

*Proof.* $\mathrm{drive}(uw,s) = \mathrm{drive}(w,\mathrm{drive}(u,s))$, and $w$ locks all pairs, in particular the pair $(\mathrm{drive}(u,s),\mathrm{drive}(u,t))$. $\square$

**Theorem 3.3 (Ideal Theorem).** The set of locking words is a two-sided ideal of the free monoid $I^{*}$: if $w$ locks, then $uwv$ locks for all $u,v \in I^{*}$.

*Proof.* Combine Lemmas 3.1 and 3.2. $\square$

The operational reading is strong: *once telepathy is possible, no amount of extra environmental noise, before or after, can destroy it.* Locking is robust to arbitrary contamination of the experimental protocol at both ends.

**Corollary 3.4 (Absorption).** If $\mathrm{drive}(w,s)=\mathrm{drive}(w,t)$ then $\mathrm{drive}(wv,s)=\mathrm{drive}(wv,t)$ for all $v$: once in phase, always in phase. The diagonal of $S\times S$ is invariant under the common dynamics.

**Lemma 3.5 (Block locking).** If a stimulus stream is cut into blocks $b_1, b_2, \dots, b_m$ and *some* block $b_j$ locks, then the concatenation $b_1 b_2 \cdots b_m$ locks.

*Proof.* Induction on the block list, applying Lemma 3.2 to the prefix and Lemma 3.1 to the suffix of the locking block. $\square$

Lemma 3.5 is the engine of the quantitative rarity estimates of §6.

### 3.2 The transition monoid

Let $\mathrm{End}(S)$ denote the monoid of self-maps of $S$ under composition. Because $\mathrm{drive}$ composes contravariantly (Lemma 2.3), the assignment $w \mapsto \mathrm{drive}(w,\cdot)$ is a monoid homomorphism
$$T_\delta : I^{*} \longrightarrow \mathrm{End}(S)^{\mathrm{op}},$$
into the *opposite* endomorphism monoid. Its image is the **transition monoid** of the agent.

**Theorem 3.6 (Rank-one characterization).** For $S$ nonempty, $\delta$ is phase-locking if and only if the transition monoid contains a constant map, i.e. an element of rank one.

*Proof.* A locking word $w$ has $\mathrm{drive}(w,\cdot) = \mathrm{const}_c$ by Proposition 2.5, and this map lies in the image of $T_\delta$. Conversely, if $\mathrm{drive}(w,\cdot)$ is constant then $w$ locks. $\square$

This places the subject inside semigroup theory: phase-lock asks whether a finitely generated transformation monoid contains a rank-one element. The ideal structure of Theorem 3.3 is then the statement that rank-one elements form a two-sided ideal of the transition monoid — which is exactly the semigroup-theoretic fact that the minimal ideal, when it consists of constants, absorbs multiplication.

---

## 4. The Synchronization Theorem

Throughout this section $S$ is finite with decidable equality.

### 4.1 Rank

**Definition 4.1 (Rank).** The *rank* of a word $w$ is
$$\mathrm{rank}(w) := \bigl|\{\mathrm{drive}(w,s) : s \in S\}\bigr|,$$
the number of internal states still distinguishable after $w$ has been observed. Note $\mathrm{rank}(\varepsilon) = |S|$.

**Theorem 4.2 (Rank is antitone).** $\mathrm{rank}(wv) \le \mathrm{rank}(w)$ for all $w, v$.

*Proof.* The image of $\mathrm{drive}(wv,\cdot)$ is the image under $\mathrm{drive}(v,\cdot)$ of the image of $\mathrm{drive}(w,\cdot)$, by Lemma 2.3; images do not grow under further maps. $\square$

Rank is thus a monotone potential: observing stimuli only ever destroys information about the initial state, never creates it. This is the precise sense in which phase-lock is a *dissipative* phenomenon.

**Proposition 4.3.** For $S$ nonempty finite, $w$ locks $\delta$ if and only if $\mathrm{rank}(w) = 1$.

*Proof.* If $w$ locks, the image is the singleton $\{\mathrm{drive}(w,s_0)\}$. Conversely, if the image is a singleton $\{c\}$ then every $\mathrm{drive}(w,s)$ equals $c$. $\square$

### 4.2 Greedy collapse

**Lemma 4.4 (A collision strictly drops cardinality).** Let $f : S \to S$, let $A \subseteq S$ be finite, and suppose $s \ne t$ both lie in $A$ with $f(s)=f(t)$. Then $|f(A)| < |A|$.

*Proof.* $f(A) = f(A \setminus \{s\})$, since the value $f(s)$ is already attained at $t \in A\setminus\{s\}$. Hence $|f(A)| \le |A\setminus\{s\}| = |A| - 1 < |A|$. $\square$

**Lemma 4.5 (Greedy collapse).** Suppose every pair $(s,t)$ of states is mergeable by a word of length at most $L$. Then for every nonempty finite $A \subseteq S$ there is a word $w$ with
$$|w| \le (|A|-1)L \quad\text{and}\quad |\{\mathrm{drive}(w,a) : a \in A\}| = 1.$$

*Proof.* Strong induction on $|A|$. If $|A| = 1$ take $w = \varepsilon$. Otherwise pick distinct $s,t \in A$ and a merging word $v$ with $|v| \le L$ and $\mathrm{drive}(v,s)=\mathrm{drive}(v,t)$. Set $B := \mathrm{drive}(v, A)$; by Lemma 4.4, $|B| < |A|$, and $B$ is nonempty. By induction there is $u$ with $|u| \le (|B|-1)L$ collapsing $B$ to a point. Then $vu$ collapses $A$ to a point, and
$$|vu| \le L + (|B|-1)L = |B| \cdot L \le (|A|-1)L. \qquad \square$$

**Theorem 4.6 (Synchronization Theorem, quantitative form).** Let $S$ be finite and nonempty and suppose every pair of internal states is mergeable by a word of length at most $L$. Then there is a single word $w$ with
$$|w| \le (|S|-1)\,L$$
that locks $\delta$: the two separated doppelgängers phase-lock from *any* pair of initial states.

*Proof.* Apply Lemma 4.5 with $A = S$: the image of $S$ under $\mathrm{drive}(w,\cdot)$ is a singleton, which by Proposition 4.3 is exactly locking. $\square$

**Theorem 4.7 (Pairwise telepathy is global telepathy).** For a finite nonempty state space,
$$\delta \text{ is phase-locking} \iff \text{every pair } (s,t) \text{ of states is mergeable.}$$

*Proof.* ($\Rightarrow$) A locking word merges every pair. ($\Leftarrow$) Choose for each pair a merging word and let $L$ be the maximum of their lengths — finite, because $S \times S$ is finite. Apply Theorem 4.6. $\square$

This is the structural heart of the theory. A local, pairwise ability — *these two states can be reconciled, by a word that may depend on them* — bootstraps into a global, uniform one: *a single word reconciles everything simultaneously*. Finiteness is what makes the bootstrap legitimate, and §5.2 shows it cannot be dropped.

### 4.3 Removing the parameter $L$

**Lemma 4.8 (Pigeonhole in the pair automaton).** Let $S$ be finite. If $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ and $|w| > |S|^2$, then there is a strictly shorter $v$ with $\mathrm{drive}(v,s) = \mathrm{drive}(v,t)$.

*Proof.* Consider the trajectory in the pair space $S \times S$:
$$k \mapsto \bigl(\mathrm{drive}(w{\restriction}k, s),\ \mathrm{drive}(w{\restriction}k, t)\bigr), \qquad 0 \le k \le |w|.$$
This is a function from a set of size $|w|+1 > |S|^2 + 1 - 1$ into $S\times S$, of size $|S|^2$; since $|w|+1 > |S|^2$, two indices $a < b$ give the same pair. Excise the loop: put $v := (w{\restriction}a)\,(w_{\ge b})$. Then $|v| = |w| - (b-a) < |w|$, and driving $s$ or $t$ by $v$ produces the same result as driving by $w$, because the state pair after the prefix $w{\restriction}a$ agrees coordinatewise with the pair after $w{\restriction}b$. Hence $\mathrm{drive}(v,s) = \mathrm{drive}(v,t)$. $\square$

**Corollary 4.9 (Short merges).** Every mergeable pair merges within $|S|^2$ stimuli.

*Proof.* Iterate Lemma 4.8, descending on length; the process terminates at length $\le |S|^2$. $\square$

**Theorem 4.10 (Unconditional phase-lock time).** If a finite nonempty agent phase-locks at all, it does so within
$$(|S|-1)\,|S|^{2}$$
shared stimuli.

*Proof.* By Theorem 4.7 every pair is mergeable; by Corollary 4.9 within $L = |S|^2$; apply Theorem 4.6. $\square$

The bound is cubic in $|S|$. §9 discusses the conjecturally correct quadratic answer.

---

## 5. Boundaries: what phase-lock cannot do

Positive theorems alone would misrepresent the subject. Three boundary results delimit it sharply.

### 5.1 Reversibility obstruction: synchronization requires dissipation

**Lemma 5.1.** If every stimulus occurring in $w$ acts injectively on $S$, then $\mathrm{drive}(w,\cdot)$ is injective.

*Proof.* Induction on $w$; a composition of injections is an injection. $\square$

**Theorem 5.2 (Reversibility obstruction).** Suppose every stimulus $i \in I$ acts injectively, i.e. $s \mapsto \delta(s,i)$ is injective. If $S$ has at least two distinct elements, then $\delta$ is **not** phase-locking.

*Proof.* Suppose $w$ locks and $s \ne t$. By Lemma 5.1, $\mathrm{drive}(w,\cdot)$ is injective, and $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ forces $s=t$, a contradiction. $\square$

Injectivity per stimulus is the discrete analogue of reversible — unitary, information-preserving — dynamics. The theorem therefore says: **telepathic synchronization requires dissipative internal dynamics**. A system that never forgets can never come into agreement with a differently-initialized copy of itself. The mechanism of phase-lock is precisely the destruction of information about the initial condition, quantified by the decreasing rank of §4.1.

**Example 5.3 (Parity agent).** $S = \{0,1\}$, one stimulus, $\delta(s,\ast) = \lnot s$. Every stimulus is a bijection, so by Theorem 5.2 two parity doppelgängers started out of phase remain out of phase forever, however long they observe.

**Example 5.4 (Copy agent).** $S = \{0,1\}$, $I = \{0,1\}$, $\delta(s,i) = i$: the agent overwrites its memory with what it observes. Any single stimulus is a locking word; phase-lock occurs after one shared observation.

The contrast is instructive: the two agents have the same state space and differ only in whether the transition depends on the current state or on the stimulus. Total recall versus total amnesia; eternal separation versus instantaneous communion.

### 5.2 Finiteness is indispensable

**Definition 5.5 (Countdown agent).** $S = \mathbb{N}$, one stimulus, $\delta(s,\ast) = s - 1$ (truncated at $0$).

**Lemma 5.6.** $\mathrm{drive}(w, s) = s - |w|$ (truncated subtraction).

**Proposition 5.7.** Every pair of countdown states is mergeable: for $s,t$, the word of length $\max(s,t)$ drives both to $0$.

**Theorem 5.8 (No global lock).** The countdown agent is not phase-locking. Consequently, pairwise mergeability does **not** imply phase-lock on an infinite state space, and Theorem 4.7 genuinely requires finiteness.

*Proof.* Let $w$ be any candidate with $n := |w|$. Then $\mathrm{drive}(w, n+1) = 1 \ne 0 = \mathrm{drive}(w, 0)$. $\square$

Unbounded memory permits states arbitrarily "far out of phase", and no fixed finite experiment can overtake all of them. The bootstrap of Theorem 4.7 is exactly a compactness phenomenon.

### 5.3 No signalling, and the necessity of identical stimuli

Model the two separated agents honestly as a single product system in which each copy receives its *own* local stimulus:
$$\Delta : (S\times S) \times (I \times I) \to S\times S, \qquad \Delta\bigl((p_1,p_2),(q_1,q_2)\bigr) = \bigl(\delta(p_1,q_1), \delta(p_2,q_2)\bigr).$$

**Theorem 5.9 (Locality/factorization).** For any word $W \in (I\times I)^{*}$ and any $(s,t)$,
$$\mathrm{drive}_\Delta(W, (s,t)) = \bigl(\mathrm{drive}_\delta(\pi_1 W, s),\ \mathrm{drive}_\delta(\pi_2 W, t)\bigr),$$
where $\pi_1 W, \pi_2 W$ are the componentwise projections of the joint stimulus word.

*Proof.* Induction on $W$; each joint step acts componentwise by construction. $\square$

**Theorem 5.10 (No-signalling).** Let $W, W'$ be joint stimulus words with $\pi_2 W = \pi_2 W'$, and let $s, s', t$ be states. Then
$$\bigl(\mathrm{drive}_\Delta(W, (s,t))\bigr)_2 = \bigl(\mathrm{drive}_\Delta(W', (s',t))\bigr)_2.$$
That is, agent 2's internal state depends only on agent 2's own initial state and agent 2's own stimulus stream. Neither agent 1's initial state nor agent 1's stimuli have any influence whatsoever.

*Proof.* Immediate from Theorem 5.9: the second component of the joint drive is a function of $\pi_2 W$ and $t$ alone. $\square$

Phase-lock is therefore **not a channel**. Nothing that occurs at one agent is detectable at the other, no matter how strongly correlated their states become. The correlation is a *shared-cause* correlation: one common signal, two identical mechanisms, one common outcome. The quantum-telepathic framing is thus dissolved in the strongest possible way — the model provably contains no signalling.

**Theorem 5.11 (Diagonal characterization).** A word $w$ locks $\delta$ if and only if the diagonal joint word $(w_1,w_1)(w_2,w_2)\cdots$ steers the product system onto the diagonal of $S\times S$ from every initial configuration.

*Proof.* By Theorem 5.9 applied to the diagonal word, the joint drive is $(\mathrm{drive}(w,s),\mathrm{drive}(w,t))$, and landing on the diagonal is exactly $\mathrm{drive}(w,s)=\mathrm{drive}(w,t)$. $\square$

**Theorem 5.12 (Identical stimuli are indispensable).** Consider two copy agents (Example 5.4) started at $(1,0)$ and driven by the constant *differing* joint stimulus $(1,0)$ repeated $n$ times. For every $n$ the two agents are in distinct states.

*Proof.* By Theorem 5.9 the agents' states are $\mathrm{drive}(1^n, 1) = 1$ and $\mathrm{drive}(0^n, 0) = 0$. $\square$

Two agents that lock instantly on a shared stimulus never lock at all on differing streams. The shared environment is the entire mechanism, not a modelling convenience.

---

## 6. How typical is phase-lock?

Existence of a locking word says nothing about whether an *uninformed* environment would ever produce one. Two answers — measure-theoretic and topological — say: almost always, and generically.

### 6.1 Geometric decay of the failure fraction

Let $u$ be a locking word of length $L$ and cut a stimulus stream into $m$ consecutive blocks of length $L$. By Lemma 3.5, the stream locks as soon as *one* block equals $u$. Hence a failing stream must avoid $u$ in every block.

**Theorem 6.1 (Counting the failures).** Let $I$ be finite. Among the $(|I|^L)^m$ block sequences of length $L\cdot m$, at most
$$\bigl(|I|^L - 1\bigr)^{m}$$
fail to lock.

*Proof.* The failing sequences inject into the product $\prod_{j=1}^m \bigl(I^L \setminus \{u\}\bigr)$, whose cardinality is $(|I|^L-1)^m$. $\square$

**Theorem 6.2 (Geometric decay).** Writing $q := |I|^L$ for the number of possible blocks, the fraction of length-$Lm$ stimulus streams that fail to lock is at most
$$\left(1 - \frac{1}{q}\right)^{m}.$$

*Proof.* Divide the bound of Theorem 6.1 by $q^m$. $\square$

**Corollary 6.3 (Blind driving locks almost surely).** If $q \ge 2$, the failure fraction tends to $0$ as $m \to \infty$. Under uniform blind environmental driving, doppelgänger phase-lock is an asymptotically probability-one event.

Phase-lock is therefore not a delicate coincidence requiring a designed protocol. Any environment rich enough to produce all blocks eventually produces a locking one, with exponentially small probability of continued failure.

### 6.2 A topological zero–one law

Real environments supply infinite streams. Equip $I^{\mathbb{N}}$ with the product topology of the discrete alphabet — Cantor topology. Define the **lock set**
$$\mathcal{L}(\delta) := \{ x \in I^{\mathbb{N}} : \text{some finite prefix } x{\restriction}n \text{ locks } \delta \}.$$

**Theorem 6.4 (Openness).** $\mathcal{L}(\delta)$ is open.

*Proof.* If $x{\restriction}n$ locks, then every stream agreeing with $x$ on the first $n$ coordinates has the same locking prefix. That agreement set is a basic open cylinder containing $x$ and contained in $\mathcal{L}(\delta)$. $\square$

Openness is the statement that locking is a *finitely observable* event: it is decided by a finite prefix and therefore survives every sufficiently small perturbation of the stream.

**Theorem 6.5 (Density).** If $\delta$ is phase-locking, then $\mathcal{L}(\delta)$ is dense.

*Proof.* Let $U$ be nonempty open; it contains a basic cylinder constraining coordinates in a finite set $F$. Let $N$ exceed $\max F$, let $x$ realize the constraint, and let $w$ be a locking word. Splice: follow $x$ for $N$ steps and then emit $w$ (filling arbitrarily thereafter). The result lies in $U$ because coordinates in $F$ are untouched, and its prefix of length $N+|w|$ equals $(x{\restriction}N)w$, which locks by Lemma 3.2. $\square$

Density has an operational reading: **no experiment can be spoiled beyond repair**. However the environment has behaved on any finite record of observations, a continuation that phase-locks the doppelgängers is always available.

**Theorem 6.6 (Zero–one law).** For $I$ nonempty, exactly one of the following holds:
- $\mathcal{L}(\delta) = \varnothing$, which happens precisely when $\delta$ is not phase-locking; or
- $\mathcal{L}(\delta)$ is open and dense, with nowhere-dense complement.

*Proof.* If $\delta$ is not phase-locking, no prefix can lock, so $\mathcal{L}(\delta)=\varnothing$; conversely if $\delta$ locks via $w$ then any stream beginning with $w$ lies in $\mathcal{L}(\delta)$, so it is nonempty. In the locking case apply Theorems 6.4 and 6.5; density gives $\mathrm{int}\bigl(\mathcal{L}(\delta)^{c}\bigr) = \varnothing$. $\square$

There is no intermediate, "thin but nonempty", regime. Either telepathy is impossible, or it is topologically typical.

### 6.3 Sharpness

Could the law be strengthened to "empty or everything"? Or is $\mathcal{L}(\delta)$ perhaps clopen, making the dichotomy trivial? No, and there is an explicit witness.

**Definition 6.7 (Černý agent, $n=3$).** $S = \{0,1,2\}$, $I = \{a,b\}$, with $a$ the rotation $s \mapsto s+1 \bmod 3$ and $b$ the collapse $0 \mapsto 1$, $s \mapsto s$ otherwise.

**Theorem 6.8 (A non-locking stream for a locking agent).** The constant stream $aaa\cdots$ lies outside $\mathcal{L}$ for the three-state Černý agent, even though that agent is phase-locking.

*Proof.* Every prefix of the constant stream is a power of $a$, and $a$ acts bijectively; by Lemma 5.1 every such prefix acts injectively, hence cannot merge the distinct states $0$ and $1$. Meanwhile $baab$ locks (Theorem 9.3). $\square$

**Theorem 6.9 (Sharpness).** For the three-state Černý agent, $\mathcal{L}$ is open and dense, but neither closed nor equal to the whole stream space.

*Proof.* Openness and density are Theorems 6.4, 6.5. Theorem 6.8 gives properness. A dense proper subset cannot be closed, since a closed dense set equals its closure, which is everything. $\square$

Phase-lock is generic but not guaranteed: an environment can, by being perfectly regular, conspire to keep the doppelgängers apart forever — though only on a nowhere-dense set of streams.

---

## 7. An analytic mechanism: contraction

The combinatorics of §4 says *when* phase-lock happens. This section gives a *mechanism*, and then shows that the mechanism is strictly stronger than the phenomenon.

Suppose $S$ carries a (pseudo)metric $d$ and that every stimulus is a uniform $k$-contraction:
$$d(\delta(s,i), \delta(t,i)) \le k\, d(s,t) \qquad \text{for all } i \in I,\ s,t\in S,$$
with $0 \le k < 1$. Such an agent is *damped* or *dissipative* in the analytic sense.

**Theorem 7.1 (Exponential collapse of the doppelgänger gap).** For every word $w$,
$$d\bigl(\mathrm{drive}(w,s), \mathrm{drive}(w,t)\bigr) \le k^{|w|}\, d(s,t).$$

*Proof.* Induction on $w$, applying the contraction hypothesis at each step. $\square$

Note what the bound does *not* depend on: which stimuli occurred. The convergence rate is a property of the agent, uniform over all possible environments.

**Corollary 7.2 (Asymptotic phase-lock).** Along every infinite stimulus stream $x$ and for all $s,t$,
$$d\bigl(\mathrm{drive}(x{\restriction}n, s), \mathrm{drive}(x{\restriction}n, t)\bigr) \longrightarrow 0 \quad (n \to \infty).$$

*Proof.* Squeeze between $0$ and $k^n d(s,t) \to 0$. $\square$

Asymptotic agreement, however, is weaker than the exact agreement that "phase-lock" demands. The bridge is *quantization*.

**Theorem 7.3 (Quantization upgrades approximate to exact).** Suppose additionally that distinct states are separated, $d(s,t) \ge \varepsilon > 0$ for $s \ne t$, and the space is bounded, $d(s,t) \le D$. Then there is $N$, depending only on $k$, $\varepsilon$, $D$, such that **every** word of length $\ge N$ locks $\delta$.

*Proof.* Choose $N$ with $k^N < \varepsilon/(D+1)$, possible since $k<1$. If $|w| \ge N$ and $\mathrm{drive}(w,s) \ne \mathrm{drive}(w,t)$ then separation gives $\varepsilon \le d(\mathrm{drive}(w,s),\mathrm{drive}(w,t)) \le k^{|w|} d(s,t) \le k^N D < \varepsilon$, a contradiction. $\square$

The choice of $N$ is uniform in the stream: not merely "eventually the agents agree", but "after $N$ observations, whatever they were, the agents agree".

**Corollary 7.4 (Contractive finite agents always phase-lock).** On a finite metric state space, separation and boundedness are automatic (take $\varepsilon$ the minimum positive distance and $D$ the diameter). Hence any per-stimulus $k$-contraction with $k<1$ yields genuine phase-lock, with all sufficiently long words locking.

### 7.1 Contraction is strictly stronger than phase-lock

**Theorem 7.5 (No contractive metric with a reversible stimulus).** Let $S$ be finite and metric, and suppose some stimulus $i_0$ acts *bijectively*. If every stimulus is a $k$-contraction with $0 \le k < 1$, then $S$ is a single point.

*Proof.* The bijection $s \mapsto \delta(s,i_0)$ is a permutation of the finite set $S$; let $m>0$ be its order, so its $m$-th iterate is the identity. Driving by $i_0^m$ therefore fixes every state, while Theorem 7.1 gives $d(s,t) \le k^m d(s,t)$ with $k^m<1$, forcing $d(s,t) = 0$, i.e. $s = t$. $\square$

**Corollary 7.6 (Separation of mechanism from phenomenon).** The three-state Černý agent phase-locks, yet its rotation stimulus is bijective, so by Theorem 7.5 no metric on its state space makes every stimulus a uniform contraction. The analytic mechanism is a strictly stronger hypothesis than the combinatorial phenomenon it explains.

This is a satisfying delimitation. Contraction gives a *reason* for phase-lock — a smooth, rate-controlled reason with a uniform time bound — but combinatorial synchronization is a broader phenomenon, achievable by agents that are locally reversible and only globally dissipative. Černý's agent is exactly such an agent: its rotation preserves all information, and only its collapse stimulus destroys any; the design's trick is to *use* the rotation to position states for the collapse.

---

## 8. A structural calculus of phase-locking designs

Phase-lock behaves well under the natural operations on agent designs.

### 8.1 Parallel composition

**Definition 8.1.** Given agents $\delta_1$ on $S_1$ and $\delta_2$ on $S_2$ over the *same* stimulus alphabet, their parallel composition is $(\delta_1 \parallel \delta_2)\bigl((p_1,p_2),i\bigr) = (\delta_1(p_1,i), \delta_2(p_2,i))$: two subsystems watching the same environment.

**Theorem 8.2 (Compositional telepathy; locking times add).** If $w_1$ locks $\delta_1$ and $w_2$ locks $\delta_2$, then $w_1 w_2$ locks $\delta_1 \parallel \delta_2$. In particular phase-lock is preserved by parallel composition, with locking time at most the sum.

*Proof.* Drive factors componentwise. In the first component, $w_1w_2$ locks by Lemma 3.1 applied to $w_1$; in the second, by Lemma 3.2 applied to $w_2$. $\square$

Nontrivially, the two subsystems do not interfere: the second word cannot unlock what the first locked (absorption, Corollary 3.4), and the first word cannot prevent the second from locking (prefix stability).

### 8.2 Coarse-graining

**Definition 8.3 (Simulation).** A map $f : S \to S'$ is a *simulation* from $\delta$ to $\delta'$ if $f(\delta(s,i)) = \delta'(f(s), i)$ for all $s,i$ — i.e. $f$ intertwines the dynamics.

**Theorem 8.4 (Coarse-graining preserves telepathy).** If $f$ is a *surjective* simulation and $w$ locks $\delta$, then $w$ locks $\delta'$. Hence phase-lock passes to homomorphic images.

*Proof.* Given $a,b \in S'$, lift to $s,t$ with $f(s)=a$, $f(t)=b$. Simulation gives $\mathrm{drive}_{\delta'}(w, f(s)) = f(\mathrm{drive}_\delta(w,s))$, and likewise for $t$; apply $f$ to the equality $\mathrm{drive}_\delta(w,s)=\mathrm{drive}_\delta(w,t)$. $\square$

You cannot lose synchronizability by adopting a coarser, lumped description of the agent. This matters practically: a validated locking sequence for a detailed model remains valid for any abstraction of it.

### 8.3 Functoriality in the stimulus alphabet

**Definition 8.5 (Relabelling).** Given $g : I' \to I$, the relabelled agent is $\delta^{g}(s,i') := \delta(s, g(i'))$: the agent reacts to the new symbol $i'$ exactly as it would to $g(i')$.

**Theorem 8.6.** $w \in (I')^{*}$ locks $\delta^{g}$ if and only if $g(w) \in I^{*}$ locks $\delta$.

*Proof.* $\mathrm{drive}_{\delta^g}(w,s) = \mathrm{drive}_{\delta}(g(w), s)$ by induction on $w$. $\square$

The theory is thus functorial in the sensory interface: re-encoding the environment changes nothing beyond the translation of words.

### 8.4 Order rigidity

**Theorem 8.7 (Monotone drive).** If $S$ is a linear order and every stimulus acts monotonically, then $\mathrm{drive}(w,\cdot)$ is monotone for every $w$.

**Theorem 8.8 (Order rigidity).** Let $S$ be a linearly ordered state space with least element $\bot$ and greatest element $\top$, and suppose every stimulus acts monotonically. Then
$$w \text{ locks } \delta \iff \mathrm{drive}(w,\bot) = \mathrm{drive}(w,\top).$$

*Proof.* ($\Rightarrow$) trivially. ($\Leftarrow$) For any $x$, monotonicity gives $\mathrm{drive}(w,\bot) \le \mathrm{drive}(w,x) \le \mathrm{drive}(w,\top)$; equality of the outer terms squeezes $\mathrm{drive}(w,x)$ to their common value. $\square$

**Corollary 8.9.** A monotone agent is phase-locking if and only if the single pair $(\bot,\top)$ is mergeable.

**Theorem 8.10 (Quadratic phase-lock time for monotone agents).** A monotone agent on a finite linearly ordered state space that phase-locks at all does so within $|S|^2$ stimuli — improving the general cubic bound of Theorem 4.10.

*Proof.* By Corollary 8.9 it suffices to merge $(\bot,\top)$, which by Corollary 4.9 takes at most $|S|^2$ stimuli; Theorem 8.8 upgrades this to a lock. $\square$

The mechanism is transparent: order squeezes the entire state space between the images of the two extremes, so *one* merge does the work of $|S|-1$ merges and the greedy loop of Theorem 4.6 collapses to a single step. This is the sharpest structural improvement in the theory, and it suggests looking for other order- or geometry-theoretic hypotheses that similarly collapse the greedy iteration.

---

## 9. Effectivity and extremal experiments

### 9.1 Decidability

**Theorem 9.1 (Reduction to finite search).** For a finite state space $S$ and finite alphabet $I$,
$$\delta \text{ is phase-locking} \iff \exists\, w \in I^{*},\ |w| \le (|S|-1)|S|^2,\ w \text{ locks } \delta.$$

*Proof.* ($\Rightarrow$) by Theorem 4.10; ($\Leftarrow$) trivially. $\square$

**Corollary 9.2 (Phase-lockability is decidable).** Whether two identical copies of a given finite agent design can be phase-locked is an algorithmically decidable property of the design: check all words up to the cubic length bound.

Naive search over all words of length $\le (n-1)n^2$ is exponential; the standard practical algorithm instead exploits Theorem 4.7 directly, computing merging words pairwise by breadth-first search in the pair space $S\times S$ (which has $n^2$ nodes) and then greedily concatenating, as in the proof of Lemma 4.5. This runs in time polynomial in $n$ and $|I|$ and returns a locking word of length $O(n^3)$ when one exists. §10 records the algorithm explicitly.

### 9.2 Exact extremal values

**Definition (Černý agents).** For each $n \ge 2$, the agent $C_n$ has states $\{0,\dots,n-1\}$, alphabet $\{a,b\}$, with $a : s \mapsto s+1 \bmod n$ and $b : 0 \mapsto 1$, $s \mapsto s$ for $s \ne 0$.

**Theorem 9.3 (Three-state extremal value).** For $C_3$, the word $baab$ locks, and no word of length $< 4$ locks. The minimal phase-lock time is exactly $4 = (3-1)^2$.

**Theorem 9.4 (Four-state extremal value).** For $C_4$, the word $baaabaaab$ locks, and no word of length $< 9$ locks. The minimal phase-lock time is exactly $9 = (4-1)^2$.

Both are established by certified exhaustive search over all words shorter than the claimed optimum. They provide exact data points $(n, \text{minimal lock time}) = (3,4), (4,9)$, sitting precisely on the quadratic pattern $(n-1)^2$ and far below the cubic bound of Theorem 4.10 (which gives $18$ and $48$ respectively). Direct breadth-first search in the subset lattice extends the pattern: the minimal locking word of $C_n$ has length exactly $(n-1)^2$ for every $n$ from $2$ through $12$.

The strategy behind $C_n$'s optimal word is easy to describe: $b$ merges only the pair $\{0,1\}$ (both go to $1$), so to merge anything else one must first rotate the offending state into position $0$ using $a$. Each merge therefore costs roughly $n$ rotations plus one collapse, and $n-1$ merges are needed: $(n-1)\cdot n$ modulo boundary effects, which comes to exactly $(n-1)^2$.

### 9.3 The Černý conjecture in agent language

**Conjecture 9.5 (Černý, 1964; agent form).** Every finite phase-locking agent admits a locking word of length at most $(|S|-1)^2$.

This is one of the best-known open problems in combinatorics, unresolved for over six decades. In the present language it asks: *when two identical machines can be synchronized at all, how long must the environment talk to them?* The theory above proves the cubic bound $(n-1)n^2$; the conjecture asserts $(n-1)^2$; the Černý agents show that $(n-1)^2$ cannot be improved.

The structure of our proof suggests where the slack lies. The cubic bound factors as
$$\underbrace{(n-1)}_{\text{number of greedy merge steps}} \times \underbrace{n^2}_{\text{worst-case cost of one merge}},$$
and both factors are simultaneously extremal only if the pair system possesses a "longest shortest merge" structure that the image-collapsing process must repeatedly rebuild from scratch. In the Černý agents the two factors are emphatically not simultaneously extremal: each merge costs only about $n$, not $n^2$, because after each collapse the surviving image is already well positioned for the next. A potential function on the lattice of reachable image sets that captures this amortization is the natural line of attack, and Theorem 8.10 shows that when the state space carries enough order structure, such amortization can be made rigorous.

---

## 10. Algorithms

### 10.1 Deciding phase-lockability and constructing a locking word

**Input:** finite $S$, finite $I$, transition table $\delta$.
**Output:** a locking word, or a certificate that none exists.

1. **Pairwise merge table.** Build the pair system on $S \times S$ with transitions $(s,t) \xrightarrow{i} (\delta(s,i),\delta(t,i))$. Run a breadth-first search *backwards* from the diagonal $\{(s,s)\}$. For each pair, this yields either a shortest merging word or a proof that none exists.
2. **Certificate of failure.** If some pair is unreachable to the diagonal, that pair is not mergeable and by Theorem 4.7 the design is not phase-locking. Halt.
3. **Greedy collapse.** Set $A \leftarrow S$, $w \leftarrow \varepsilon$. While $|A| > 1$: pick distinct $s,t \in A$, look up their shortest merging word $v$, set $w \leftarrow wv$ and $A \leftarrow \mathrm{drive}(v, A)$. Each iteration strictly shrinks $|A|$ by Lemma 4.4.
4. **Return** $w$.

**Complexity.** Step 1 is $O(|I| \cdot |S|^2)$ time and $O(|S|^2)$ space. Step 3 performs at most $|S|-1$ iterations, each appending a word of length $\le |S|^2$ and recomputing the image in $O(|S|^3)$ time. Total time $O(|I||S|^2 + |S|^4)$, output length $O(|S|^3)$, matching Theorem 4.10.

**Correctness.** Termination and the length bound are Lemma 4.5; the failure certificate is Theorem 4.7.

### 10.2 Exact minimal phase-lock time

For small designs, breadth-first search over words in the *subset space* $2^S$, starting at $S$ and seeking a singleton, returns the exact minimum. The state space has $2^{|S|}$ nodes, so this is exponential in $|S|$ but entirely practical for $|S| \le 20$ and is how the exact values $4$ and $9$ of Theorems 9.3 and 9.4 are confirmed. (Determining the minimal locking word length is NP-hard in general, so exponential dependence is expected.)

---

## 11. Discussion and applications

### 11.1 Resetting without sensing

Strip the doppelgänger framing and the subject is the theory of **blind resetting**. A device has drifted into an unknown internal configuration; there is no sensor to read it. Is there a fixed command sequence returning it to a known configuration whatever its current state? That is precisely a locking word. Theorem 4.7 says: yes, provided every pair of states is individually reconcilable; Theorem 4.10 says the sequence is short; Corollary 9.2 says the question is decidable in advance, at design time.

Concrete manifestations include: part orienters that align components on a vibrating tray by an open-loop shake sequence with no sensing; self-synchronizing codes that let a receiver recover frame alignment after corruption without a handshake; robotic recovery routines; and testing sequences that drive a system under test into a known state before each test case.

### 11.2 The physics reading

Theorem 5.2 is the discrete shadow of a familiar physical principle. Reversible — information-preserving — dynamics cannot bring two differently-initialized copies of a system into agreement, because it never reduces the number of distinguishable configurations. Rank (Definition 4.1) is precisely a count of surviving distinguishability, and Theorem 4.2 says it decreases monotonically, an entropy-like statement. Synchronization is a dissipative process and consumes exactly the information about initial conditions that it destroys.

Theorem 7.1 supplies the quantitative version in the presence of a metric: the doppelgänger gap contracts at a rate $k$ per observation that is independent of the environment. Theorem 7.5 then closes the circle — a system with a reversible mode admits no such contraction at all.

### 11.3 The no-signalling reading

The most important negative result may be Theorem 5.10. Correlation between the two agents, however perfect, is never a channel: each agent's trajectory is a function of its own inputs and its own initial state. This is the precise sense in which the "telepathy" is a shared-cause correlation, exactly as in the classical explanation of correlated measurement outcomes with a common past. Theorem 5.12 sharpens it: remove the shared cause — feed the two agents different streams — and the correlation vanishes entirely.

### 11.4 The two regimes

The theory exhibits a clean dichotomy of *mechanisms*:

- **Analytic (contractive) regime.** Every stimulus shrinks distances. Locking is automatic, uniform in the stream, and quantitatively fast. All sufficiently long words lock (Theorem 7.3). This is the "thermostat" regime: independent devices reading the same signal converge.
- **Combinatorial (Černý) regime.** Some stimuli are reversible; locking requires a specific *strategy*, using reversible stimuli to position states for the rare dissipative ones. Only special words lock, and the lock set — though open and dense — is a proper subset of the stream space (Theorem 6.9). This is the "puzzle" regime, and it is where the hard extremal question lives.

Theorem 7.5 and Corollary 7.6 prove the second regime strictly larger. Almost all the difficulty of the Černý conjecture resides in it.

---

## 12. Future directions

**C1 — Quadratic phase-lock time (Černý conjecture, agent form).** For every finite agent that phase-locks, is there a locking word of length at most $(|S|-1)^2$? We proved the cubic bound $(|S|-1)|S|^2$ and verified the quadratic value exactly on the Černý agents with three and four states. This is the classical Černý conjecture, open since 1964. The key insight is that our cubic bound decomposes as *(number of greedy merge steps)* $\times$ *(cost of one pairwise merge)*, and both factors are simultaneously extremal only if the pair system has a Hamiltonian-like shortest-merge structure that the image-collapsing process must repeatedly rebuild — a tension that a potential function on the lattice of reachable image sets should be able to exploit. With rank, the ideal structure of locking words, and a certified exhaustive search procedure now available, one can systematically test candidate potential functions on all agents up to five or six states before attempting a general proof, and the greedy-collapse proof is written so that only the "cost of one merge step" lemma need be replaced.

**C2 — Order rigidity beyond linear orders.** Let $S$ be a finite lattice and let every stimulus act as a lattice homomorphism. Is phase-lock then equivalent to the mergeability of $\bot$ and $\top$, with lock time at most $\mathrm{height}(S)\cdot|S|$ rather than $|S|^3$? We proved this for linear orders and monotone (not necessarily homomorphic) transitions, with a quadratic bound. The lattice case is open: the monotone squeezing argument uses linearity only through antisymmetric trapping between $\bot$ and $\top$, but a genuine lattice needs a chain-decomposition argument. The key insight is that for order-preserving dynamics the whole state space is squeezed between the images of the two extreme states, so one merge does the work of $|S|-1$ merges. Since the order-rigidity proof is short once monotonicity of drive is available, the lattice generalization is a low-risk, high-reward extension that would also immediately sharpen the composition bound.

**Further avenues.** (i) *Probabilistic environments*: replace the uniform counting of §6 with general stationary or Markovian stimulus sources and determine the exact locking-time distribution. (ii) *Approximate phase-lock*: quantify partial synchronization by the rank profile of a random word, obtaining a rank-descent curve interpolating between $|S|$ and $1$. (iii) *Noisy channels*: allow the two agents to observe slightly different streams (rare discrepancies) and determine the maximal discrepancy rate consistent with recurrent phase-lock. (iv) *Continuous state spaces*: identify the correct generalization of rank for measurable dynamics and connect to random dynamical systems and synchronization by common noise. (v) *Compositional bounds*: Theorem 8.2 gives an additive bound for parallel composition; determine when it is tight, and whether coarse-graining can strictly reduce lock time.

---

## 13. Conclusion

Two identical machines, separated in space, unable to communicate, and started in unknown and differing configurations, can be driven into exactly the same internal state by a common environmental signal. We have characterized when this is possible (every pair of states must be individually reconcilable, and the state space must be finite), how long it takes (at most $(|S|-1)|S|^2$ stimuli, conjecturally $(|S|-1)^2$, exactly $(n-1)^2$ for the Černý designs with three and four states), how typical it is (failure probability decaying geometrically under blind driving; a topological zero–one law, sharp), what mechanism drives it (uniform contraction suffices but is strictly stronger than necessary), how it behaves under design operations (composition adds locking times; coarse-graining and relabelling preserve it; order structure collapses the bound to quadratic), and — most importantly — what it cannot do (it is impossible for reversible agents, it fails without finiteness, it fails without a shared stimulus stream, and it never constitutes a communication channel).

The phenomenon is real, it is generic, and it is entirely classical. What looks like telepathy is two identical mechanisms forgetting their differences at the same rate, in the same way, because the world told them the same story.
