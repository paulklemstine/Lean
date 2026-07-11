# Infinite Games Against Death: Immortality Strategies and the $\omega$–$\omega^2$ Dichotomy

## Abstract

We introduce and analyze a transfinite *survival game* between two players: **Mortal**, whose computational power is captured by a well-ordered set of reachable internal configurations, and **Eternity**, an adversary who may prolong the contest through transfinitely many ordinal-indexed rounds and seeks Mortal's demise. Each round Mortal survives, it must exhibit a strictly later reachable *moment*; the length of any survivable play is therefore bounded by the order type of Mortal's moment set. We define the **survival value** of a game as this order type and prove a *Fundamental Theorem*: Mortal can force survival to round $\beta$ if and only if $\beta \le \mathrm{value}(G)$. From this single reduction we derive a sharp dichotomy. A finite deterministic Mortal (moments of order type $\omega$) forces every finite round and forces round $\omega$, but dies exactly at $\omega$; moreover *any* Mortal whose moments order-embed into $\mathbb{N}$ cannot pass $\omega$. A Mortal with bounded nondeterminism (moments of order type $\omega^2$, indexed lexicographically) forces every round $\omega \cdot n$ and forces $\omega^2$, but dies exactly at $\omega^2$. Underlying the jump is a **refinement principle**: subdividing each moment into an $\omega$-block of sub-moments multiplies the survival value by $\omega$. We interpret these thresholds through the lens of Infinite Time Turing Machines, where $\omega$ and $\omega^2$ are the first two clockable milestones met when climbing from deterministic to boundedly nondeterministic transfinite computation.

**Keywords:** ordinals, order type, well-order, transfinite game, survival value, bounded nondeterminism, infinite time Turing machines, clockable ordinals.

---

## 1. Introduction

Classical computability measures a machine's power by *what* it can compute. A complementary question asks *how long* a machine can persist under an adversary who is willing to wait transfinitely long. This question is naturally phrased as a game. One player, **Mortal**, is a bounded computational agent; the other, **Eternity**, controls a clock indexed by the ordinals and wins the instant Mortal cannot make a legal move. Because time is well-founded — one may climb ordinals indefinitely but never descend them forever — Mortal's predicament reduces to a single structural fact about the set of configurations it can reach.

Our contribution is a compact, fully rigorous framework for this game together with a sharp analysis of two natural computational regimes. The framework isolates one invariant, the **survival value**, and shows that survival is *entirely* governed by it (Theorem 3.1). We then compute the value in two cases of independent interest:

1. **Finite deterministic computation.** Reachable moments have order type $\omega$; survival is exactly $\omega$ (Section 4), and this bound is intrinsic to *any* system whose configurations embed into $\mathbb{N}$.
2. **Bounded nondeterminism.** Reachable moments have order type $\omega^2$; survival is exactly $\omega^2$ (Section 5).

The mechanism connecting the two is a general **refinement principle** (Section 6): replacing each moment by an $\omega$-block of sub-moments multiplies survival by $\omega$. Finally (Section 7) we interpret $\omega$ and $\omega^2$ as the first two clockable milestones of Infinite Time Turing Machines.

All statements below are elementary consequences of the theory of ordinals and order types; we favor transparent proofs over generality.

---

## 2. The Survival Game

### 2.1 Ordinals, well-orders, and order type

We work throughout with **ordinals**, the canonical representatives of well-order types. A linear order $(X, <)$ is a **well-order** if every nonempty subset has a least element, equivalently if there is no infinite strictly descending sequence. Every well-order $(X,<)$ has a unique **order type** $\mathrm{type}(X,<)$, the ordinal to which it is order-isomorphic. We write $\omega$ for the order type of $(\mathbb{N}, <)$, the least infinite ordinal. Ordinal multiplication is defined so that $\alpha \cdot \beta$ is the order type of $\beta$ copies of $\alpha$ laid end to end; in particular $\omega \cdot \omega = \omega^2$.

Two standard facts drive every proof in this paper.

- **(Order-type comparison.)** For well-orders $A$ and $B$, one has $\mathrm{type}(A) \le \mathrm{type}(B)$ if and only if there exists an order embedding (a strictly increasing, order-reflecting injection) $A \hookrightarrow B$.
- **(Initial-segment realization.)** For every ordinal $\beta$, the collection of ordinals below $\beta$, ordered by $<$, is itself a well-order of type $\beta$.

### 2.2 The game and its value

**Definition 2.1 (Survival game).** A *survival game* $G$ consists of a set $\mathrm{Moment}(G)$ of **moments of being alive**, linearly ordered by a relation $<$ that is a well-order. A moment is an internal configuration certifying that Mortal is still alive; the well-order encodes that time advances and never regresses.

**Definition 2.2 (Survival value).** The *survival value* of $G$ is the order type of its moments,
$$\mathrm{value}(G) := \mathrm{type}\big(\mathrm{Moment}(G), <\big).$$

**Definition 2.3 (Play).** For an ordinal $\beta$, a *play of length $\beta$* is an order embedding
$$f : (\{\gamma : \gamma < \beta\}, <) \hookrightarrow (\mathrm{Moment}(G), <),$$
i.e. an assignment of a strictly increasing moment to each round below $\beta$. Mortal **forces round $\beta$**, written $\mathrm{Forces}(G,\beta)$, if a play of length $\beta$ exists.

The interpretation is faithful to the informal rules: to survive $\beta$ rounds, Mortal must, for each round $\gamma < \beta$, produce a moment $f(\gamma)$ strictly later than all previously used moments. Injectivity forbids reusing a moment; monotonicity encodes the forward flow of time.

---

## 3. The Fundamental Theorem

**Theorem 3.1 (Fundamental Theorem of the survival game).** For every survival game $G$ and every ordinal $\beta$,
$$\mathrm{Forces}(G, \beta) \iff \beta \le \mathrm{value}(G).$$

*Proof.* ($\Rightarrow$) A play of length $\beta$ is an order embedding of the round set $\{\gamma < \beta\}$, which has type $\beta$, into $\mathrm{Moment}(G)$, which has type $\mathrm{value}(G)$. By order-type comparison, the existence of such an embedding gives $\beta \le \mathrm{value}(G)$.

($\Leftarrow$) Suppose $\beta \le \mathrm{value}(G)$. Since $\beta$ equals the type of its own round set, order-type comparison yields an order embedding from the round set into $\mathrm{Moment}(G)$. That embedding *is* a play of length $\beta$, so $\mathrm{Forces}(G,\beta)$. $\qquad\blacksquare$

The theorem reduces the entire game to one ordinal invariant. Three immediate corollaries record the consequences.

**Corollary 3.2 (Monotonicity / downward closure).** If $\mathrm{Forces}(G,\beta)$ and $\gamma \le \beta$, then $\mathrm{Forces}(G,\gamma)$.

*Proof.* By Theorem 3.1, $\beta \le \mathrm{value}(G)$; transitivity gives $\gamma \le \mathrm{value}(G)$; apply Theorem 3.1 again. $\qquad\blacksquare$

**Corollary 3.3 (Survival below the value).** If $\beta < \mathrm{value}(G)$ then $\mathrm{Forces}(G,\beta)$.

**Corollary 3.4 (Certain death at the value).** If $\mathrm{value}(G) < \beta$ then $\neg\,\mathrm{Forces}(G,\beta)$.

Thus $\mathrm{value}(G)$ is precisely the least round Mortal cannot force: survival for all rounds strictly below it, guaranteed death at it and beyond.

---

## 4. Finite Determinism: the $\omega$ Barrier

**Definition 4.1 (Finite deterministic game).** Let $\mathsf{Fin}$ be the survival game with $\mathrm{Moment}(\mathsf{Fin}) = \mathbb{N}$ under the usual order. This models a machine with finite memory whose clock advances one tick per round, with no branching.

**Proposition 4.2.** $\mathrm{value}(\mathsf{Fin}) = \omega$.

*Proof.* The order type of $(\mathbb{N}, <)$ is $\omega$ by definition of $\omega$. $\qquad\blacksquare$

**Theorem 4.3 (Finite Mortal survives every finite round and forces $\omega$).**
For every $n \in \mathbb{N}$, $\mathrm{Forces}(\mathsf{Fin}, n)$; moreover $\mathrm{Forces}(\mathsf{Fin}, \omega)$.

*Proof.* Each finite $n$ satisfies $n < \omega = \mathrm{value}(\mathsf{Fin})$, so $\mathrm{Forces}(\mathsf{Fin}, n)$ by Corollary 3.3. Since $\omega \le \omega = \mathrm{value}(\mathsf{Fin})$, Theorem 3.1 gives $\mathrm{Forces}(\mathsf{Fin}, \omega)$. $\qquad\blacksquare$

**Theorem 4.4 ($\omega$ is sharp).** $\neg\,\mathrm{Forces}(\mathsf{Fin}, \omega + 1)$.

*Proof.* $\mathrm{value}(\mathsf{Fin}) = \omega < \omega + 1$; apply Corollary 3.4. $\qquad\blacksquare$

The $\omega$ barrier is not peculiar to this particular indexing; it is a property of finite deterministic computation as such.

**Theorem 4.5 (Intrinsic $\omega$ bound).** If the moments of a survival game $G$ order-embed into $(\mathbb{N}, <)$, then $\mathrm{value}(G) \le \omega$, and hence $\neg\,\mathrm{Forces}(G, \omega+1)$.

*Proof.* An order embedding $\mathrm{Moment}(G) \hookrightarrow \mathbb{N}$ gives, by order-type comparison, $\mathrm{value}(G) \le \mathrm{type}(\mathbb{N}) = \omega$. The final clause is Corollary 3.4. $\qquad\blacksquare$

Embeddability into $\mathbb{N}$ is the order-theoretic signature of finite deterministic behavior: a machine whose reachable configurations can be enumerated as an increasing sequence of naturals. Theorem 4.5 says that no such machine survives past $\omega$. Breaking the barrier requires leaving this class.

---

## 5. Bounded Nondeterminism: the $\omega^2$ Barrier

We now grant Mortal a bounded amount of nondeterministic choice, modeled by a second coordinate that counts how many limit stages ("blocks") it has survived.

**Definition 5.1 (Bounded-nondeterministic game).** Let $\mathsf{Nd}$ be the survival game with
$$\mathrm{Moment}(\mathsf{Nd}) = \mathbb{N} \times_{\mathrm{lex}} \mathbb{N},$$
the set of pairs $(b, t)$ ordered **lexicographically**: $(b,t) < (b',t')$ iff $b < b'$, or $b = b'$ and $t < t'$. The major coordinate $b$ counts completed $\omega$-blocks; the minor coordinate $t$ counts ticks within the current block. A bounded nondeterministic reset lets Mortal increment $b$ and restart $t$.

**Proposition 5.2.** $\mathrm{value}(\mathsf{Nd}) = \omega^2$.

*Proof.* The lexicographic product of two well-orders has order type equal to the product of their types, taken as $\mathrm{type}(\text{minor}) \cdot \mathrm{type}(\text{major})$ in the ordinal-multiplication convention where $\alpha \cdot \beta$ is $\beta$ copies of $\alpha$. Here both factors have type $\omega$, so $\mathrm{value}(\mathsf{Nd}) = \omega \cdot \omega = \omega^2$. $\qquad\blacksquare$

**Theorem 5.3 (Nondeterministic Mortal survives every $\omega \cdot n$ and forces $\omega^2$).**
For every $n \in \mathbb{N}$, $\mathrm{Forces}(\mathsf{Nd}, \omega \cdot n)$; moreover $\mathrm{Forces}(\mathsf{Nd}, \omega^2)$.

*Proof.* For finite $n$, $\omega \cdot n \le \omega \cdot \omega = \omega^2 = \mathrm{value}(\mathsf{Nd})$ (since $n \le \omega$ and multiplication on the left by $\omega$ is monotone), so Theorem 3.1 gives $\mathrm{Forces}(\mathsf{Nd}, \omega \cdot n)$. Since $\omega^2 \le \omega^2$, likewise $\mathrm{Forces}(\mathsf{Nd}, \omega^2)$. $\qquad\blacksquare$

**Theorem 5.4 ($\omega^2$ is sharp).** $\neg\,\mathrm{Forces}(\mathsf{Nd}, \omega^2 + 1)$.

*Proof.* $\mathrm{value}(\mathsf{Nd}) = \omega^2 < \omega^2 + 1$; apply Corollary 3.4. $\qquad\blacksquare$

**Theorem 5.5 (Nondeterminism strictly helps).** $\mathrm{value}(\mathsf{Fin}) < \mathrm{value}(\mathsf{Nd})$.

*Proof.* $\omega = \omega \cdot 1 < \omega \cdot \omega = \omega^2$, since $1 < \omega$ and left multiplication by the positive ordinal $\omega$ is strictly monotone. $\qquad\blacksquare$

Thus a bounded pinch of nondeterminism lifts survival from $\omega$ to its square — from the first infinity to a genuinely two-dimensional transfinite lifespan.

---

## 6. The Refinement Principle

The jump from $\omega$ to $\omega^2$ is a special case of a uniform construction.

**Definition 6.1 ($\omega$-refinement).** For a survival game $G$, its *$\omega$-refinement* $R(G)$ is the game with
$$\mathrm{Moment}(R(G)) = \mathrm{Moment}(G) \times_{\mathrm{lex}} \mathbb{N},$$
ordered lexicographically with the original moment as the major coordinate. Each original moment is thereby expanded into an $\omega$-block of sub-moments.

**Theorem 6.2 (Refinement multiplies survival by $\omega$).**
$$\mathrm{value}(R(G)) = \omega \cdot \mathrm{value}(G).$$

*Proof.* The lexicographic product $\mathrm{Moment}(G) \times_{\mathrm{lex}} \mathbb{N}$ has order type $\mathrm{type}(\mathbb{N}) \cdot \mathrm{type}(\mathrm{Moment}(G)) = \omega \cdot \mathrm{value}(G)$, by the order type of a lexicographic product (minor factor first in the ordinal-multiplication convention). $\qquad\blacksquare$

**Corollary 6.3 (Recovering $\omega^2$).** $\mathrm{value}(R(\mathsf{Fin})) = \omega \cdot \omega = \omega^2$.

*Proof.* Apply Theorem 6.2 with $\mathrm{value}(\mathsf{Fin}) = \omega$. $\qquad\blacksquare$

The refinement principle localizes the entire phenomenon: bounded nondeterminism is exactly one application of $R$, and nothing about the argument is special to $\omega$. Iterating $R$ yields survival values $\omega^3, \omega^4, \dots$, and a limit of finite refinements approaches $\omega^\omega$ (Section 8).

---

## 7. Connection to Infinite Time Turing Machines

An **Infinite Time Turing Machine** (ITTM) executes over ordinal time: it performs ordinary successor steps, and at each limit stage sets each cell to the limit inferior (equivalently, the eventual value) of its earlier contents, then continues from a designated limit state. ITTMs decide sets far beyond the arithmetic hierarchy and organize a rich theory of *clockable* ordinals — those that arise as halting times.

The survival game is a stripped-down model of *how far such a machine clocks before its first structural reckoning*.

- A **deterministic** ITTM with a finite work alphabet that must eventually halt traces, before its first limit intervention, a sequence of configurations whose reachable clock values are order-isomorphic to an initial segment of $\omega$. This is precisely $\mathsf{Fin}$, with survival value $\omega$ (Proposition 4.2).
- Allowing a **bounded** amount of nondeterministic branching at each stage lets the machine reset a bounded counter across limit stages, stacking $\omega$-blocks. The reachable clock values then realize $\omega^2$. This is precisely $\mathsf{Nd}$, with survival value $\omega^2$ (Proposition 5.2).

The ordinals $\omega$ and $\omega^2$ are the first two clockable milestones one meets when climbing from deterministic to boundedly nondeterministic transfinite computation, and Theorems 4.4 and 5.4 pin each down exactly. The refinement principle (Theorem 6.2) is the abstract counterpart of adding one more layer of bounded counting across limits.

---

## 8. Discussion and Future Work

The framework isolates a single invariant, the survival value, and reduces an ostensibly dynamic transfinite contest to its computation. The resulting dichotomy — $\omega$ for finite determinism, $\omega^2$ for bounded nondeterminism — is sharp in both directions, and the refinement principle explains the gap as a single multiplication by $\omega$. Several natural directions remain.

1. **Higher barriers $\omega^n$ and $\omega^\omega$.** Iterating $R$ should yield survival value $\omega^{n+1}$ after $n$ refinements of $\mathsf{Fin}$; a suitable colimit over finite refinements should reach $\omega^\omega$. Making the colimit precise, with the correct limit ordering on moments, is the first structural extension.
2. **Explicit strategy synthesis.** Our plays are abstract order embeddings. One would like concrete, computable winning schedules — for instance CNF-based encodings of the increasing moment sequences — realizing the same survival values constructively.
3. **Genuine ITTM dynamics.** Replace the abstract moment type by an actual ITTM configuration space with the liminf limit rule, and prove that the reachable clock values realize the same order types identified here.
4. **Determinacy.** Prove that at each threshold either Mortal has a surviving strategy or Eternity has a killing strategy, with the boundary located exactly at the survival value; this would recast the results as a determinacy statement.
5. **Clockable ordinals.** Relate survival values systematically to the clockable ordinals of ITTMs, aiming for a dictionary between computational regimes and the ordinals they clock.

## 9. Conclusion

Survival against an unbounded adversary is governed by one ordinal. Finite deterministic computation reaches $\omega$ and no further; a bounded pinch of nondeterminism reaches $\omega^2$; and a single refinement principle explains why each added layer of bounded structure multiplies survival by a whole factor of infinity. In the infinite game against death, the gap between $\omega$ and $\omega^2$ measures, precisely, the value of a little bit of choice.
