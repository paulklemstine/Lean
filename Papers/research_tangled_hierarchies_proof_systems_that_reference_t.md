# Tangled Hierarchies: A Kripke-Semantic Account of Self-Referential Soundness

## Abstract

We give a self-contained semantic treatment of *self-referential soundness* in Gödel–Löb provability logic and prove, at the level of Kripke frames, that the soundness (equivalently, consistency) predicate of a sufficiently expressive proof system cannot reside inside the system it validates without trivializing it. Modelling a proof system as a Kripke frame whose worlds are theories and whose accessibility relation encodes "provable reachability," we identify the two structural conditions — **transitivity** and **converse well-foundedness** — under which the provability modality validates Löb's axiom. Within this setting we prove a **semantic Löb theorem**, $\Box(\Box A \to A) \subseteq \Box A$, by converse-well-founded induction; we derive the **semantic second incompleteness theorem**, $\Box\,\mathrm{Con} \subseteq \Box\bot$, from the observation that the reflection instance at the false proposition *is* the consistency statement; and we prove the **tangled hierarchy theorem**: no consistent world validates $\Box\,\mathrm{Con}$, so the soundness predicate is unavoidably external. We complement these with a converse — local self-soundness forces consistency — and ground the whole family of results in a single **Lawvere fixed-point** argument, from which Cantor's theorem and Tarski's undefinability of truth follow as the fixed-point-free instance given by Boolean negation. An explicit infinite frame (the natural numbers under $>$) witnesses non-vacuity of every result. We include algorithms that compute the modality on finite frames, verify the collapse concretely, and search for fixed points, together with numerical demonstrations.

**Keywords:** provability logic, Gödel–Löb logic, Löb's theorem, second incompleteness theorem, Kripke semantics, converse well-foundedness, Lawvere fixed-point theorem, Tarski undefinability, self-reference.

---

## 1. Introduction

A recurring temptation in the design of reasoning systems — formal theories, program verifiers, self-modelling agents — is to let a system certify its own reliability. The certificate typically takes the shape of a *soundness* or *consistency* statement: "everything I prove is true," or "I never prove a contradiction." The central fact of this paper is that such a certificate cannot live inside the system it certifies. If it does, the system is either inconsistent (its certificate is vacuous) or it cannot produce the certificate at all. We call the resulting stratification a **tangled hierarchy**: the level that would validate a system must sit strictly above it.

Our contribution is to present this phenomenon *semantically*, purely in terms of Kripke frames, in a way that is elementary, fully self-contained, and non-vacuous. The classical route to these facts runs through the arithmetization of syntax, Gödel numbering, and the Hilbert–Bernays–Löb derivability conditions. We bypass all of that. We work directly with the modal semantics of the provability operator, isolate the two frame conditions that make provability logic tick, and obtain Löb's theorem, the second incompleteness theorem, and the impossibility of internal consistency proofs as short, transparent semantic lemmas. Beneath them all sits Lawvere's fixed-point theorem, which we prove and use to recover Cantor and Tarski.

### 1.1 Contributions

1. A definition of **Gödel–Löb frames** (Section 3) as transitive, converse-well-founded Kripke frames, with box, diamond, and consistency modalities defined as operators on subsets of worlds.
2. A **semantic Löb theorem** (Section 4) proved by converse-well-founded induction, with an explicit maximal-counterexample argument.
3. The identity **reflection-at-$\bot$ equals consistency** (Section 5) and, as an immediate corollary, the **semantic second incompleteness theorem** and the **tangled hierarchy theorem**.
4. A **converse**: local self-soundness at $\bot$ forces consistency (Section 5).
5. The **Lawvere fixed-point theorem** and its corollaries **Cantor/Tarski** (Section 6).
6. A concrete **infinite witness frame** and a proof that non-dead worlds cannot prove their own consistency (Section 7).
7. **Algorithms and numerical demonstrations** on finite frames (Section 8).

---

## 2. Preliminaries and notation

Throughout, a *property* of worlds is identified with the subset of worlds satisfying it. Logical connectives on properties are the corresponding Boolean set operations; the false proposition $\bot$ is the empty set $\varnothing$, and the true proposition $\top$ is the full set of worlds. We write $w \in A$ for "world $w$ satisfies property $A$," and $A \subseteq B$ for "$A$ entails $B$ at every world."

We freely use the material-implication property: for properties $A, B$, the property "$A \to B$" is $\{w \mid w \in A \Rightarrow w \in B\}$, i.e. the complement of $A$ united with $B$.

---

## 3. Gödel–Löb frames and the modalities

**Definition 3.1 (Gödel–Löb frame).** A *Gödel–Löb frame* $F$ consists of a set $W$ of *worlds* (theories) together with a binary *accessibility relation* $R \subseteq W \times W$ satisfying:

- **(Transitivity)** for all $a,b,c$, if $R\,a\,b$ and $R\,b\,c$ then $R\,a\,c$;
- **(Converse well-foundedness)** the relation $a \prec b :\Leftrightarrow R\,b\,a$ is well-founded; equivalently, there is no infinite ascending chain $w_0, w_1, w_2, \dots$ with $R\,w_i\,w_{i+1}$ for all $i$, and every nonempty set of worlds has an $R$-maximal element.

We read $R\,w\,v$ as "from $w$, the theory $v$ is a provably reachable continuation." Transitivity is the modal axiom **4** (positive introspection): provability of provability. Converse well-foundedness is exactly the frame condition validating Löb's axiom.

**Definition 3.2 (Box).** For a property $A \subseteq W$, the *box* (provability) modality is
$$\Box A \;=\; \{\, w \mid \forall v,\ R\,w\,v \Rightarrow v \in A \,\}.$$
A world validates $\Box A$ (read "$A$ is provable at $w$") iff $A$ holds at every accessible world.

**Definition 3.3 (Diamond).** The *diamond* (consistency-with) modality is
$$\Diamond A \;=\; \{\, w \mid \exists v,\ R\,w\,v \wedge v \in A \,\}.$$

**Definition 3.4 (Consistency).** The *consistency* property is $\mathrm{Con} = \Diamond\top$, i.e.
$$\mathrm{Con} \;=\; \{\, w \mid \exists v,\ R\,w\,v \,\}.$$
A world is consistent iff it has an accessible successor. A world with no successor is a *dead end*: it vacuously validates $\Box A$ for every $A$ (including $\Box\bot$), the semantic image of an inconsistent theory that proves everything.

**Lemma 3.5 (Monotonicity of box).** If $A \subseteq B$ then $\Box A \subseteq \Box B$.

*Proof.* If $w \in \Box A$ and $R\,w\,v$, then $v \in A \subseteq B$, so $v \in B$; hence $w \in \Box B$. $\qquad\blacksquare$

---

## 4. The semantic Löb theorem

The following is the semantic core of the paper. Recall the reflection property "$\Box A \to A$" $= \{w \mid w \in \Box A \Rightarrow w \in A\}$.

**Theorem 4.1 (Semantic Löb).** In every Gödel–Löb frame,
$$\Box(\Box A \to A) \;\subseteq\; \Box A.$$
Equivalently: if a world proves "provability of $A$ entails $A$," it already proves $A$.

*Proof.* Fix $w \in \Box(\Box A \to A)$ and any successor $v$ with $R\,w\,v$; we must show $v \in A$. Suppose not, so $v \notin A$. Consider the nonempty set
$$S \;=\; \{\, u \mid R\,w\,u \ \wedge\ u \notin A \,\}, \qquad v \in S.$$
By converse well-foundedness, $S$ has an $R$-maximal element $u$: that is, $R\,w\,u$, $u \notin A$, and for every $t$ with $R\,u\,t$ and $t \notin A$ we would have a contradiction, because such $t$ satisfies $R\,w\,t$ (by transitivity from $R\,w\,u$ and $R\,u\,t$) and $t \notin A$, so $t \in S$, contradicting maximality of $u$. Hence every $t$ with $R\,u\,t$ satisfies $t \in A$; that is, $u \in \Box A$.

Now $R\,w\,u$ and $w \in \Box(\Box A \to A)$ give $u \in (\Box A \to A)$, i.e. $u \in \Box A \Rightarrow u \in A$. Since $u \in \Box A$, we conclude $u \in A$ — contradicting $u \notin A$. Therefore no such $v$ exists, and $w \in \Box A$. $\qquad\blacksquare$

The proof is a single maximal-counterexample induction; converse well-foundedness is used *exactly once*, to extract the maximal offender $u$, and transitivity is used *exactly once*, to certify that $u$'s successors are also $w$'s successors. These are the only two frame conditions the theorem needs, and both are necessary: on a reflexive point (which is trivially not converse well-founded) Löb's principle fails.

---

## 5. Consistency, incompleteness, and tangling

The reduction of incompleteness to Löb is a single algebraic identity.

**Theorem 5.1 (Reflection at $\bot$ is consistency).**
$$\{\, w \mid w \in \Box\bot \Rightarrow w \in \bot \,\} \;=\; \mathrm{Con}.$$

*Proof.* Unfolding, $w \in \Box\bot$ means every successor of $w$ lies in $\varnothing$, which holds iff $w$ has *no* successor. And $w \in \bot$ is impossible. So "$w \in \Box\bot \Rightarrow w \in \bot$" holds iff "$w$ has no successor" is false, i.e. iff $w$ has a successor, i.e. iff $w \in \mathrm{Con}$. $\qquad\blacksquare$

**Theorem 5.2 (Semantic second incompleteness).** In every Gödel–Löb frame,
$$\Box\,\mathrm{Con} \;\subseteq\; \Box\bot.$$
A world that proves its own consistency proves falsehood, hence proves everything.

*Proof.* Instantiate Theorem 4.1 at $A = \bot$: $\Box(\Box\bot \to \bot) \subseteq \Box\bot$. By Theorem 5.1 the antecedent $\Box\bot \to \bot$ equals $\mathrm{Con}$, so $\Box(\Box\bot \to \bot) = \Box\,\mathrm{Con}$. Substituting gives $\Box\,\mathrm{Con} \subseteq \Box\bot$. $\qquad\blacksquare$

**Theorem 5.3 (Tangled hierarchy theorem).** Let $w$ be a world with at least one successor (i.e. $w \in \mathrm{Con}$). Then
$$w \notin \Box\,\mathrm{Con}.$$
No consistent world proves its own consistency; the soundness/consistency predicate is unavoidably external.

*Proof.* Suppose $w \in \Box\,\mathrm{Con}$. By Theorem 5.2, $w \in \Box\bot$, so every successor of $w$ lies in $\varnothing$. But $w$ has a successor $v$ by hypothesis, whence $v \in \varnothing$, a contradiction. $\qquad\blacksquare$

The dichotomy is now exact. If a world proves its own consistency then, by Theorem 5.2, it proves $\bot$, and (Theorem 5.1) it has no successor: it is a dead, inconsistent theory whose "consistency proof" is vacuous. If instead the world is genuinely consistent, Theorem 5.3 forbids the proof outright. There is no consistent, self-certifying world.

A gratifying converse holds as well.

**Theorem 5.4 (Soundness forces consistency).** If a world $w$ is locally self-sound at $\bot$ — that is, $w \in \Box\bot \Rightarrow w \in \bot$ — then $w \in \mathrm{Con}$.

*Proof.* This is precisely membership of $w$ in the left-hand side of Theorem 5.1, which equals $\mathrm{Con}$. Concretely: local self-soundness at $\bot$ says $w \notin \Box\bot$ (since $w \in \bot$ is impossible), i.e. $w$ has a successor. $\qquad\blacksquare$

Thus reflection and consistency are two faces of one coin: a world that cannot be duped by a proof of falsehood is automatically a live theory — but, by Theorem 5.3, it cannot internalize this fact as a theorem about itself.

---

## 6. The diagonal core: Lawvere, Cantor, Tarski

All of the above are shadows of a single fixed-point phenomenon.

**Theorem 6.1 (Lawvere fixed-point).** Let $A, B$ be sets and let $f : A \to (A \to B)$ be *point-surjective*: every function $A \to B$ equals $f(a)$ for some $a \in A$. Then every endomap $g : B \to B$ has a fixed point: there exists $b \in B$ with $g(b) = b$.

*Proof.* Consider the diagonal map $d : A \to B$, $d(a) = g(f(a)(a))$. By point-surjectivity, $d = f(c)$ for some $c \in A$. Evaluating at $c$: $f(c)(c) = d(c) = g(f(c)(c))$. Hence $b := f(c)(c)$ satisfies $g(b) = b$. $\qquad\blacksquare$

**Theorem 6.2 (Cantor / Tarski undefinability).** For no set $A$ is there a point-surjective map $f : A \to (A \to \mathrm{Bool})$. Equivalently, a system cannot carry a surjective self-encoding onto its own two-valued predicates; its truth predicate is not internally definable.

*Proof.* Boolean negation $\lnot : \mathrm{Bool} \to \mathrm{Bool}$ has no fixed point ($\lnot\,\text{true} = \text{false} \neq \text{true}$ and $\lnot\,\text{false} = \text{true} \neq \text{false}$). If a point-surjective $f : A \to (A \to \mathrm{Bool})$ existed, Theorem 6.1 with $g = \lnot$ would produce a fixed point of $\lnot$, a contradiction. $\qquad\blacksquare$

The conceptual link is that provability, truth, and membership are all instances of a predicate a system tries to apply to its own codes; the diagonal produces the self-referential sentence (the Gödel sentence, the liar, the anti-diagonal set) that the fixed-point-free operator (negation, "unprovable," "not in the set") cannot accommodate. Löb's theorem is the constructive, converse-well-founded refinement of this picture: rather than merely forbidding a fixed point of negation, it computes what the fixed point of the *modalized* transformer $X \mapsto \Box X \to A$ must be, and converse well-foundedness makes that computation terminate rank by rank.

---

## 7. A concrete infinite frame

Non-vacuity is essential: the theorems above would be empty if Gödel–Löb frames were degenerate. They are not.

**Definition 7.1 (Natural-number frame).** Let $\mathbb{N}$ be the worlds with $R\,a\,b :\Leftrightarrow b < a$.

**Proposition 7.2.** The natural-number frame is a Gödel–Löb frame.

*Proof.* Transitivity: if $b < a$ and $c < b$ then $c < a$. Converse well-foundedness: the relation $a \prec b \Leftrightarrow b < a$ (i.e. the usual $<$) is well-founded on $\mathbb{N}$; there is no infinite strictly descending chain of naturals. $\qquad\blacksquare$

**Proposition 7.3 (The dead world).** $0 \notin \mathrm{Con}$: world $0$ has no successor (no natural is $< 0$), so it vacuously proves everything and is inconsistent.

**Proposition 7.4 (Live worlds cannot self-certify).** For every $n > 0$: $n \in \mathrm{Con}$ and $n \notin \Box\,\mathrm{Con}$.

*Proof.* Since $0 < n$, we have $R\,n\,0$, so $n$ has a successor and $n \in \mathrm{Con}$. By Theorem 5.3, $n \notin \Box\,\mathrm{Con}$. $\qquad\blacksquare$

In this frame $\Box^k\bot$ is exactly the set $\{0, 1, \dots, k-1\}$ of worlds of rank below $k$: $\Box\bot = \{0\}$ (only $0$ has all-successors-in-$\varnothing$), $\Box\Box\bot = \{0,1\}$, and so on. Consistency $\mathrm{Con} = \{n \mid n \geq 1\}$ is the complement of the rank-$0$ shell, and $\Box\,\mathrm{Con}$ collapses into $\Box\bot = \{0\}$, visibly excluding every live world — a completely explicit instance of the collapse.

---

## 8. Algorithms and computation

On a **finite** frame the modalities are computable by direct set manipulation, and every theorem above becomes a decidable check. We record the core routines; full type-hinted implementations accompany this paper.

**Algorithm A (Box operator).** Given the successor lists of a finite frame and a subset $A$ of worlds (as a bitset), compute $\Box A = \{w : \text{succ}(w) \subseteq A\}$ in $O(|W| + |{\to}|)$ time by scanning each world's successors.

**Algorithm B (Consistency and collapse check).** Compute $\mathrm{Con} = \{w : \text{succ}(w) \neq \varnothing\}$, then $\Box\,\mathrm{Con}$ and $\Box\varnothing$, and verify $\Box\,\mathrm{Con} \subseteq \Box\varnothing$ (Theorem 5.2) and, for each $w \in \mathrm{Con}$, that $w \notin \Box\,\mathrm{Con}$ (Theorem 5.3).

**Algorithm C (Löb least fixed point).** For the transformer $\Phi(X) = \Box X \to A = (W \setminus \Box X) \cup A$ on a finite frame, iterate from $\varnothing$ (or from $\Box(\Phi\text{-antecedent})$) to a fixed point; converse well-foundedness guarantees termination, and the fixed point equals $\Box A$, exhibiting the Löb identity numerically.

**Algorithm D (Lawvere / anti-diagonal witness).** Given a candidate encoding $f$ of predicates and an endomap $g$ on values, form the diagonal $d(a) = g(f(a)(a))$; either return the fixed point $f(c)(c)$ when $d = f(c)$, or, for $g = \lnot$, return the anti-diagonal predicate $a \mapsto \lnot f(a)(a)$ that is provably outside the range of $f$, certifying non-surjectivity (Theorem 6.2).

The accompanying demonstration verifies on random finite Gödel–Löb frames that $\Box\,\mathrm{Con} \subseteq \Box\bot$ always holds, that no consistent world lies in $\Box\,\mathrm{Con}$, that the rank identity $\Box^k\bot = \{\text{rank} < k\}$ holds on the natural-number frame, and that the anti-diagonal predicate is never in the range of any candidate encoding into $\mathrm{Bool}$.

---

## 9. Applications and interpretation

**Formal theories.** The results are the semantic skeleton of Gödel's and Löb's theorems: a consistent, sufficiently expressive theory cannot prove its own consistency, and can prove "$A$ is provable $\to A$" only for the $A$ it already proves. The Kripke picture makes precise *why* the provability predicate must be studied from a metatheory.

**Program verification and trusted computing.** A verifier that could internally certify its own soundness would, by Theorem 5.2, be unsound (it would "prove" everything). Practical trust is therefore layered: a small trusted kernel is validated from outside, and each layer certifies only strictly weaker layers — a concrete tangled hierarchy.

**Self-modelling agents.** An agent whose internal model certifies "all my conclusions are correct" is, by the same collapse, an agent that endorses every conclusion. Calibrated reliability is necessarily represented externally, not as an internal theorem of self-soundness.

**Foundations of self-reference.** Section 6 unifies the liar paradox, Cantor's theorem, Russell's paradox, Tarski's undefinability, and Gödel–Löb incompleteness as instances of one fixed-point law, isolating the fixed-point-free operator (negation) as the single source of impossibility.

---

## 10. Discussion and future directions

The organizing insight is that **converse well-foundedness converts self-reference into terminating recursion stratified by ordinal rank**. This is what turns the reflective principle $\Box(\Box A \to A)$ into the flat $\Box A$, and it suggests several directions.

1. **Uniqueness of modal fixed points on tangled frames.** *Conjecture.* On every transitive, converse-well-founded frame, each modalized predicate transformer has a *unique* fixed point, definable from finite Boolean combinations of iterated consistency statements. The rank-stratification $\Box^k\varnothing = \{\text{rank} < k\}$ forces a fixed point to be constant on each rank shell, converting the de Jongh–Sambin uniqueness folklore into a checkable ordinal induction.

2. **Exact tangling threshold.** *Conjecture.* A proof system can internally express its own soundness for all propositions of quantifier-rank below $k$ but never for rank exactly $k$, and this threshold coincides with the converse-well-founded rank of the canonical frame. Internal soundness is a graded reflection principle, and Löb's collapse acts once the grade reaches the self-referential diagonal; "consistency = reflection at $\bot$" is the base rung.

3. **Polymodal tangling and provability strength.** *Conjecture.* In a polymodal system with modalities $[0], [1], [2], \dots$ of strictly increasing strength, each modality can prove the consistency of all strictly weaker modalities but never its own, and the provable cross-consistencies form a strict linear order isomorphic to the modality index. A stronger operator sees a sparser accessibility relation, spends strictly less ordinal capital, and the gap certifies weaker operators while barring self-certification; antitonicity of rank in the modality index supplies the strict inequalities.

4. **Diagonal-free consistency certificates.** *Conjecture.* A proof system admits a *diagonal-free* consistency certificate — a non-self-referential internal witness of its own consistency — if and only if its canonical frame has an accessible terminal (dead) world reachable in a bounded number of steps, decoupling the witness from the diagonal that Löb's theorem exploits.

---

## 11. Conclusion

Working entirely within Kripke semantics, we have shown that the soundness/consistency predicate of an expressive proof system cannot be internal to that system without collapse. The engine is the semantic Löb theorem, proved by one maximal-counterexample induction using transitivity and converse well-foundedness; its instance at the false proposition is the second incompleteness theorem, and the consistency of a live world then forbids any internal consistency proof. Beneath these lies a single Lawvere fixed-point argument that also yields Cantor and Tarski. An explicit infinite frame confirms that none of the statements is vacuous. Tangled hierarchies are not an accident of a particular formalism; they are a structural law of any system rich enough to reason about its own reasoning.
