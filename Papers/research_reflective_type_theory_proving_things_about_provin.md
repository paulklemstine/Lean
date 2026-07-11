# Reflective Type Theory: A Semantic Core for Propositions About Their Own Provability

## Abstract

We develop a semantic core for a *reflective* type theory — a system in which propositions may speak about their own provability. Adopting the propositions-as-types discipline in its possible-worlds form, we interpret a proposition as the set of *proof stages* (worlds) at which it holds, and we attach a provability modality $\Box$ ("is provable") to an accessibility relation $R$ encoding a single step of reasoning. Within this setting we establish three headline results. First, the self-referential proposition $\Box P \wedge \neg\,\Box\Box P$ — "provable but not provably provable" — is inhabited: we exhibit an explicit finite model realizing it, and we prove the matching boundary theorem that on any *transitive* frame the axiom $\Box P \to \Box\Box P$ holds, so the phenomenon is a genuine feature of non-transitive (reflective) provability rather than of classical Gödel–Löb provability. Second, the modality is *normal* — monotone, distributive over conjunction, validating the distribution axiom $K$ and the necessitation rule — yet provably distinct from the identity operator, so the reflective theory conservatively but *properly* extends its non-modal base. Third, viewing propositions as a complete lattice, $\Box$ is one monotone operator among all monotone operators; the Knaster–Tarski theorem supplies least and greatest fixed points uniformly, the modal duality $\Diamond P = \overline{\Box\overline{P}}$ holds, and on well-founded frames Löb's law $\Box(\Box P \to P) \to \Box P$ is validated. These facts identify the reflective proof-term language, structurally, as a modal $\mu$-calculus. We give explicit numerical demonstrations of every result over finite frames.

**Keywords.** reflective type theory, provability modality, Kripke semantics, normal modal logic, axiom 4, Löb's theorem, modal $\mu$-calculus, least and greatest fixed points, Knaster–Tarski.

---

## 1. Introduction

Self-reference is simultaneously the source of logic's most famous limitations — the incompleteness phenomena of Gödel and the fixed-point theorem of Löb — and of some of its most powerful tools, the fixed-point logics that drive formal verification. A *reflective* type theory is one whose propositions are permitted to comment on their own provability: alongside statements like "$P$ holds" we admit statements like "$P$ is provable," "$P$ is provable but its provability is not provable," and so on.

The immediate difficulty is that "provable" cannot be an absolute, self-applied predicate without inviting paradox. Our resolution is to relativize provability to *stages of knowledge*. A proposition is not a bare truth value but the set of stages at which it holds; provability at a stage is a promise about the stages reachable by one step of reasoning. This is precisely the possible-worlds (Kripke) reading of a necessity modality, and it lets us make the reflective vocabulary rigorous while keeping the whole development elementary and finite-model-checkable.

Three questions organize the paper.

1. **Expressibility and inhabitation.** Can "provable but not provably provable" be written as a well-formed proposition, and is it ever true? (Section 3.)
2. **Extension.** How does the reflective layer relate to the non-modal base — is it a genuine enrichment or a redundant re-description? (Section 4.)
3. **Proof-term structure.** What is the algebraic character of the reflective connectives, and how do fixed points enter? (Section 5.)

Our answers are, respectively: yes and exactly on non-transitive frames; a proper (normal, non-trivial) extension; and a modal $\mu$-calculus, with Löb's law as its well-founded fixed-point principle.

---

## 2. The reflective semantics

### 2.1 Frames and propositions

**Definition 2.1 (Reflective frame).** A *reflective frame* on a type of worlds $W$ is a binary accessibility relation $R : W \to W \to \mathrm{Prop}$. We read $R\,w\,v$ as "from stage $w$, stage $v$ is one provability step ahead." A *proposition* is a subset $P \subseteq W$, understood as the set of stages at which it holds. Propositions ordered by inclusion form a complete Boolean lattice, with conjunction $P \cap Q$, disjunction $P \cup Q$, negation $\overline P = W \setminus P$, top $W$, and bottom $\varnothing$.

**Definition 2.2 (Reflective modalities).** For a frame $(W, R)$ and a proposition $P \subseteq W$ define

$$\Box P = \{\, w \in W : \forall v,\ R\,w\,v \Rightarrow v \in P \,\}, \qquad \Diamond P = \{\, w \in W : \exists v,\ R\,w\,v \wedge v \in P \,\}.$$

We read $w \in \Box P$ as "$P$ is provable at stage $w$": every stage one reasoning step ahead of $w$ satisfies $P$. Dually, $w \in \Diamond P$ reads "$P$ is consistent with provability at $w$."

The membership rules are immediate from the definitions:

$$w \in \Box P \iff (\forall v,\ R\,w\,v \Rightarrow v \in P), \qquad w \in \Diamond P \iff (\exists v,\ R\,w\,v \wedge v \in P).$$

### 2.2 Duality

**Proposition 2.3 (Modal duality).** For every frame and every proposition $P$,
$$\Diamond P = \overline{\ \Box\,\overline{P}\ }.$$

*Proof sketch.* Unfolding, $w \notin \Box\overline P$ means it is not the case that every $R$-successor of $w$ lies in $\overline P$, i.e. some successor lies in $P$, i.e. $w \in \Diamond P$. Taking complements gives the claim. $\square$

This is the defining relationship between the two dual modalities of the $\mu$-calculus and confirms that $\Diamond$ carries no information beyond $\Box$ and Boolean negation.

---

## 3. Provable but not provably provable

### 3.1 The flagship model

We now show that the reflective vocabulary can express, and *inhabit*, the self-referential proposition $\Box P \wedge \neg\,\Box\Box P$.

**Definition 3.1 (The chain frame).** Let $W = \{0, 1, 2\}$ and let $R$ be the non-transitive, non-reflexive chain
$$2 \longrightarrow 1 \longrightarrow 0,$$
that is, $R\,a\,b$ holds iff $(a=2 \wedge b=1)$ or $(a=1 \wedge b=0)$. Let $P = \{1\}$, the proposition true exactly at the middle stage.

**Theorem 3.2 (Inhabitation of "provable but not provably provable").** On the chain frame, at stage $2$,
$$2 \in \Box P \qquad \text{and} \qquad 2 \notin \Box\Box P.$$
Equivalently, the type $\Box P \wedge \neg\,\Box\Box P$ is inhabited in the reflective theory.

*Proof.* For the first claim, the unique $R$-successor of $2$ is $1$, and $1 \in P$; hence every successor of $2$ lies in $P$, so $2 \in \Box P$. For the second claim, suppose toward a contradiction that $2 \in \Box\Box P$. Then $\Box P$ must hold at every successor of $2$, in particular at $1$, so $1 \in \Box P$. But the unique successor of $1$ is $0$, and $0 \notin P = \{1\}$, so $1 \notin \Box P$ — a contradiction. Hence $2 \notin \Box\Box P$. $\square$

A direct computation over the finite frame corroborates the theorem: $\Box P = \{0, 2\}$ (stage $0$ vacuously, being a dead end; stage $2$ because its only successor is $1$) and $\Box\Box P = \{0, 1\}$, so stage $2$ lies in the first set but not the second.

**Corollary 3.3 (Existential form).** There exist a frame $F$, a proposition $P$, and a world $w$ with $w \in \Box P$ and $w \notin \Box\Box P$.

The essential structural feature is *near-sightedness*: stage $2$ sees one step (to $1$) but not two steps (to $0$) in a single glance. Provability has a horizon, and the self-referential sentence lives exactly at that horizon.

### 3.2 The boundary theorem

The natural objection is that Theorem 3.2 might be an artifact of an impoverished notion of proof. The following result draws the exact line.

**Theorem 3.4 (Transitivity validates axiom 4).** If the frame is *transitive* — for all $a, b, c$, $R\,a\,b$ and $R\,b\,c$ imply $R\,a\,c$ — then for every proposition $P$,
$$\Box P \subseteq \Box\Box P.$$

*Proof.* Let $w \in \Box P$; we show $w \in \Box\Box P$. Take any $v$ with $R\,w\,v$ and any $u$ with $R\,v\,u$; we must show $u \in P$. By transitivity $R\,w\,u$, and since $w \in \Box P$ every $R$-successor of $w$ lies in $P$, so $u \in P$. Hence $v \in \Box P$ for every successor $v$ of $w$, i.e. $w \in \Box\Box P$. $\square$

Theorem 3.4 is the sharp boundary: the phenomenon of Theorem 3.2 requires a *non-transitive* provability step. The chain frame witnesses this because it is precisely not transitive — $R\,2\,1$ and $R\,1\,0$ hold, but $R\,2\,0$ fails. Adjoining the missing shortcut $R\,2\,0$ (the transitive closure) restores axiom 4 and destroys the witness; a finite check confirms that on the transitive closure $\Box P \subseteq \Box\Box P$ for *all* propositions, and stage $2$ is no longer in $\Box\Box P$'s complement.

**Remark 3.5 (Non-classicality).** The classical provability logics behind Gödel's incompleteness theorems and Löb's theorem — the systems $K4$ and $GL$ — are built on transitive frames, where axiom 4 makes "provable" and "provably provable" coincide. Reflective type theory relaxes transitivity, and Theorem 3.2 is the reward: a strictly larger expressive range in which the distinction between provability and its own iteration becomes visible.

---

## 4. The reflective modality properly extends the base

We now show that $\Box$ is a *normal* modality obeying all the standard structural laws, yet is not definable from the non-modal connectives — so the reflective theory is a proper extension of its Boolean base.

**Theorem 4.1 (Monotonicity).** If $P \subseteq Q$ then $\Box P \subseteq \Box Q$.

*Proof.* If $w \in \Box P$ then every successor of $w$ lies in $P \subseteq Q$, so every successor lies in $Q$, i.e. $w \in \Box Q$. $\square$

**Theorem 4.2 (Distribution over conjunction).** For all $P, Q$,
$$\Box(P \cap Q) = \Box P \cap \Box Q.$$

*Proof.* For any $w$: every successor lies in $P \cap Q$ iff every successor lies in $P$ and every successor lies in $Q$. $\square$

**Theorem 4.3 (Axiom $K$).** For all $P, Q$ and every world $w$, if $w \in \Box\{v : v \in P \Rightarrow v \in Q\}$ and $w \in \Box P$, then $w \in \Box Q$.

*Proof.* Fix a successor $v$ of $w$. The first hypothesis gives $v \in P \Rightarrow v \in Q$, and the second gives $v \in P$; hence $v \in Q$. As $v$ was arbitrary, $w \in \Box Q$. $\square$

**Theorem 4.4 (Necessitation).** If $P = W$ (i.e. $P$ holds at every world), then $\Box P = W$.

*Proof.* Every successor of every world lies in $W = P$, so every world is in $\Box P$. $\square$

Theorems 4.1–4.4 say precisely that $\Box$ is a *normal* modality: it is monotone, commutes with conjunction, validates $K$, and is closed under necessitation. These are exactly the laws one demands of an honest notion of provability, so the reflective layer is well-behaved.

**Theorem 4.5 ($\Box$ is not the identity).** There is a frame $F$ on $\{0, 1\}$, a proposition $P$, and a world $w$ with $w \in \Box P \not\Leftrightarrow w \in P$; equivalently, $\Box P \neq P$ in general.

*Proof.* Take $R = \varnothing$ (no reasoning steps) and $P = \varnothing$. Then every world is vacuously in $\Box P$ (there are no successors to violate $P$), so $\Box P = W = \{0, 1\}$, while $P = \varnothing$. At $w = 0$ we have $0 \in \Box P$ but $0 \notin P$. $\square$

**Corollary 4.6 (Proper extension).** The reflective modality is a normal operator that is not definable as the identity on the non-modal base. Consequently the reflective theory *properly* extends its non-modal fragment: it validates every structural law of provability while adding genuinely new propositions (those of the form $\Box P$ that disagree with $P$).

The intuition behind Theorem 4.5 is that a dead-end stage proves *everything* vacuously, decoupling provability from truth. More generally, provability and truth agree everywhere only under strong frame conditions (reflexivity forces $\Box P \subseteq P$; density and other constraints control the converse), so the modal layer carries information the Boolean base cannot.

---

## 5. The proof-term language is a modal $\mu$-calculus

### 5.1 Monotone operators and fixed points

The decisive structural observation is that the semantics lives in a complete lattice.

**Proposition 5.1 (Lattice of propositions).** The propositions $\mathcal{P}(W)$ ordered by $\subseteq$ form a complete lattice: every family of propositions has a least upper bound (union) and a greatest lower bound (intersection).

**Proposition 5.2 ($\Box$ is monotone).** By Theorem 4.1, $\Box : \mathcal{P}(W) \to \mathcal{P}(W)$ is a monotone operator on this lattice. So is $\Diamond$, and so is every operator built from $\Box$, $\Diamond$, $\cap$, $\cup$, and monotone parameters.

**Theorem 5.3 (Knaster–Tarski fixed points).** Every monotone operator $f : \mathcal{P}(W) \to \mathcal{P}(W)$ has a least fixed point
$$\mu f = \bigcap \{\, X : f(X) \subseteq X \,\}$$
and a greatest fixed point
$$\nu f = \bigcup \{\, X : X \subseteq f(X) \,\},$$
each satisfying $f(\mu f) = \mu f$ and $f(\nu f) = \nu f$.

Because $\Box$ and $\Diamond$ are monotone, Theorem 5.3 applies to every operator in the reflective signature. This is exactly the ingredient that upgrades a modal logic to a modal *$\mu$-calculus*: the language of $\Box$, $\Diamond$, Boolean connectives, and the two fixed-point binders $\mu$ (least) and $\nu$ (greatest).

**Examples 5.4.** Over a frame:
- $\mu X.\ (A \cup \Diamond X)$ is the set of stages from which $A$ is *eventually reachable* along the reasoning steps.
- $\nu X.\ \Diamond X$ is the set of stages that begin an *infinite forward path* of reasoning steps.

On the finite acyclic line $0 \to 1 \to 2 \to 3$ with $A = \{3\}$, the least fixed point $\mu X.\ (A \cup \Diamond X)$ is the whole line $\{0,1,2,3\}$ (every stage eventually reaches $3$), while the greatest fixed point $\nu X.\ \Diamond X$ is empty (no stage begins an infinite path). Both values are computed exactly by iteration from $\varnothing$ and from $W$ respectively.

**Interpretation 5.5 (Proof terms as $\mu$-calculus formulas).** Under propositions-as-types, a proof term of a reflective proposition is a witness to membership in the corresponding set of stages. The connectives available for building such propositions are exactly the monotone lattice operators together with $\mu$ and $\nu$. Hence the reflective proof-term language *is*, structurally, a modal $\mu$-calculus: $\Box$ is one monotone operator among many, and Knaster–Tarski supplies the recursion uniformly.

### 5.2 Löb's law: the well-founded fixed-point principle

The characteristic fixed-point law of self-referential provability is Löb's theorem. It holds under a well-foundedness hypothesis on the reasoning steps.

**Theorem 5.6 (Löb's law).** Suppose the frame is transitive and *converse well-founded*: there is no infinite sequence $w_0 \to w_1 \to w_2 \to \cdots$ of reasoning steps (equivalently, the relation is well-founded read backward, so every forward chain terminates). Then for every proposition $P$,
$$\Box(\Box P \to P) \subseteq \Box P.$$

*Proof sketch.* By well-founded induction on the step relation. Assume $w \in \Box(\Box P \to P)$; we show $w \in \Box P$, i.e. $P$ holds at every successor $v$ of $w$. Fix such a $v$. By transitivity, $v$ inherits $\Box(\Box P \to P)$, so by the induction hypothesis applied at $v$ (legitimate because $v$ is strictly ahead of $w$ in a terminating relation) we obtain $v \in \Box P$. The hypothesis at $w$ gives, at $v$, that $\Box P \to P$ holds; combined with $v \in \Box P$ this yields $v \in P$. As $v$ was arbitrary, $w \in \Box P$. $\square$

Read in plain language, Löb's law says: *if it is provable that "the provability of $P$ entails $P$," then $P$ is already provable.* It is the modal core of Gödel's second incompleteness theorem and the archetypal fixed-point law of self-reference; well-foundedness is precisely what makes the self-referential induction terminate. A finite check over the strict-order frame on $\{0,1,2,3\}$ (transitive and converse well-founded) confirms $\Box(\Box P \to P) \subseteq \Box P$ for every proposition $P$.

**Remark 5.7.** Löb's law is exactly the statement that on well-founded transitive frames $\Box P$ is the *unique* fixed point of the operator $X \mapsto \Box(X \to P)$ — the $\mu$-calculus fixed-point law specialized to the provability modality. This closes the circle: fixed points are not an add-on to reflective provability but its native idiom.

---

## 6. Algorithms

The entire theory is finite-model-checkable, which makes the results directly executable. We record the two central algorithms.

**Algorithm A (Modal evaluation).** Given a finite frame $(W, R)$ and a proposition $P \subseteq W$, compute $\Box P$ and $\Diamond P$ by, for each world $w$, inspecting its successor set $R(w) = \{v : R\,w\,v\}$: place $w$ in $\Box P$ iff $R(w) \subseteq P$, and in $\Diamond P$ iff $R(w) \cap P \neq \varnothing$. Complexity $O(|W| + |R|)$ per proposition. Iterating gives $\Box\Box P$ and hence a decision procedure for $\Box P \wedge \neg\,\Box\Box P$ at any world.

**Algorithm B (Fixed-point iteration).** Given a monotone operator $f$ on the finite lattice $\mathcal{P}(W)$, compute $\mu f$ by iterating $X_0 = \varnothing$, $X_{n+1} = f(X_n)$ until $X_{n+1} = X_n$; compute $\nu f$ by iterating from $X_0 = W$. Monotonicity guarantees the chains are monotone and, in a finite lattice of height $|W|$, stabilize in at most $|W|$ steps. This evaluates any closed $\mu$-calculus formula (alternation handled by nesting the iterations).

---

## 7. Applications

**Staged epistemics.** The distinction between $\Box P$ and $\Box\Box P$ models the difference between what a reasoner (a program, an agent) can guarantee *now* and what it can guarantee about its own *future* guarantees. Non-transitive frames capture bounded-horizon reasoning, where an agent secures the next step but not the step after.

**Formal verification.** The modal $\mu$-calculus identified in Section 5 is the specification language of *model checking*. "Eventually reaches a good state" is a least fixed point $\mu X.\ (A \cup \Diamond X)$; "can run forever" or "avoids a bad state indefinitely" is a greatest fixed point. Algorithms A and B are precisely the core of a model checker.

**Foundations of self-reference.** The framework provides a controlled laboratory for the paradoxes and theorems of self-reference — the liar, Gödel incompleteness, Löb's theorem — locating the safe/explosive boundary at a single first-order frame condition (transitivity plus well-foundedness).

---

## 8. Discussion and future work

Three structural findings orient the next questions: (i) "provable but not provably provable" is inhabited exactly when the provability step is non-transitive; (ii) the modality is normal yet provably not the identity, so it strictly enriches the non-modal base; (iii) least and greatest fixed points exist for every monotone operator, and on well-founded frames provability satisfies Löb's law.

**Transitivity as the exact frontier.** We conjecture that $\Box P \wedge \neg\,\Box\Box P$ is satisfiable *iff* the step relation is non-transitive, and that $\Box$-definable predicates collapse onto the non-modal fragment precisely on transitive-and-dense frames — making axiom 4 equivalent to transitivity at the level of definable predicates.

**Completeness for the $\mu$-calculus.** We conjecture that every modal $\mu$-calculus formula is realized by a reflective proof term and conversely, via a compositional translation preserving alternation depth, since $\Box$ is one monotone operator among all and Knaster–Tarski supplies $\mu$/$\nu$ uniformly.

**Löb and normalization.** We conjecture that a reflective theory admits strong normalization of proof terms *iff* its provability step is transitive and converse well-founded — iff Löb's law holds globally — because converse well-foundedness both powers the induction behind Löb's theorem and forbids non-terminating self-referential proof terms.

**Graded reflection.** Indexing the step relation by a natural-number grade yields a hierarchy $\Box_0 \subseteq \Box_1 \subseteq \cdots$ of provability strengths whose union is a genuine fixed point, stratifying reflective power.

---

## 9. Conclusion

Reflective type theory is normal modal logic over propositions-as-sets, situated properly above its non-modal base, with the modal $\mu$-calculus as its fixed-point completion and Löb's theorem as its well-founded fixed-point law. The self-referential proposition "provable but not provably provable" is not a paradox but a theorem-bearing citizen of the theory, inhabited exactly at the horizon of non-transitive provability and vanishing the instant provability becomes far-sighted enough to see its own consequences.
