# Conservativity for Tangled Hierarchies

### Self-referential truth predicates that cost the base theory nothing

**Author:** Aristotle
**Date:** 2026-08-17

---

## Abstract

We study propositional languages extended by a family of *internal truth atoms* $T c$, one for each *name* $c$, together with a *denotation* function $\mathrm{den}$ assigning to each name a formula of the extended language. Such a structure — a **tangled hierarchy** — permits arbitrary self-reference and reference cycles among names. The associated theory is the set of Tarski biconditionals $T c \leftrightarrow \mathrm{den}(c)$.

We prove that conservativity of a tangled extension over an arbitrary truth-free base theory is *exactly equivalent* to the solvability of the associated system of fixed-point equations: a tangle adds no new truth-free consequence to any truth-free base theory if and only if every valuation of the base atoms expands to a solution of the loop equations. From this criterion we derive three sufficient conditions of increasing generality. (i) **Positivity**: if no truth atom occurs under a negation, the Knaster–Tarski theorem supplies a model and the tangle is conservative, with no restriction whatsoever on the reference graph. (ii) **Groundedness**: if the dependency relation is graded by a natural-number rank with strictly descending edges, the model is not merely existent but *unique*, for arbitrary polarity. (iii) **Local stratification**, the common generalization: negative occurrences descend strictly in rank, positive occurrences merely do not ascend. Locally stratified tangles are conservative, and the condition strictly generalizes both (i) and (ii) while remaining strictly sufficient rather than necessary.

We also prove a **height collapse** theorem: since formulas are finite, a tangle has a well-founded dependency relation if and only if it admits an $\mathbb{N}$-valued rank; a finitary tangled hierarchy can be infinitely tall but never transfinitely tall. Finally we quantify the *cost* of tangling. For positive tangles the model set is the fixed-point set of a monotone operator, hence a complete lattice bracketed by a least and a greatest extension, and determinacy holds exactly when the two coincide. A single grounded name has exactly one model, a positive self-loop (the truth-teller) exactly two, and a negative self-loop (the liar) exactly none; $k$ independent truth-tellers have exactly $2^k$ models and add no truth-free consequence at all. The cost of tangling is therefore *exponential in semantics and zero in syntax*, and the liar marks the sharp boundary at which even the semantic cost becomes infinite: conservativity fails outright, by inconsistency.

**Keywords:** tangled hierarchy, strange loop, self-reference, Tarski biconditional, conservative extension, Knaster–Tarski fixed point, local stratification, well-founded dependency, liar paradox, truth-teller.

---

## 1. Introduction

### 1.1 The problem

Tarski's theorem on the undefinability of truth is often summarized as an interdiction: a language may not contain its own truth predicate. The interdiction is real, but it is also coarse. It is a statement about *one particular* self-referential construction — the diagonal one producing the liar — and it says nothing about the enormous space of self-referential constructions that are not diagonal.

The engineering counterpart of this coarseness is familiar. Recursive definitions in programming languages, inductive predicates in proof systems, recursive rules in deductive databases, and reflection principles in verified reasoning systems all involve a language talking about, and defining, objects of its own kind. All of them work. What distinguishes them from the liar is not the absence of self-reference but the presence of *structure* — monotonicity, or stratification, or well-foundedness — that makes a system of self-referential equations solvable.

This paper isolates that structure in the simplest setting where the phenomenon lives: propositional logic with a family of internal truth atoms. The setting is deliberately minimal — no quantifiers, no arithmetization, no Gödel numbering — precisely so that the mechanism is visible without the machinery of self-reference obscuring it. Every self-referential configuration is available by fiat: we simply *stipulate* that the name $c$ denotes a formula mentioning $T c$.

### 1.2 The Hofstadter thesis, formalized

Hofstadter's *tangled hierarchy* is a system of levels in which the top level reaches back down to the bottom, and his claim about such systems is that the strange loop does not corrupt the levels it sits above. Read as mathematics, "does not corrupt the levels above" is exactly the technical notion of a **conservative extension**: the theory of the tangled system entails no sentence of the old vocabulary that the old theory did not already entail.

The main results of this paper give that claim a precise form, precise sufficient conditions, and a precise boundary. The conditions are generous. The boundary is the liar.

### 1.3 Contributions

1. **Exact criterion (Theorem 4.2).** Conservativity over *all* truth-free base theories is equivalent to expandability of every base valuation to a model of the loop equations.
2. **Positivity suffices (Theorem 5.3).** No constraint on the reference graph is needed: positivity alone yields conservativity, via Knaster–Tarski.
3. **Groundedness yields determinacy (Theorem 6.3, 6.4).** Rank-graded tangles have unique models regardless of polarity, hence are conservative.
4. **Local stratification (Theorem 7.4).** Negative edges descend, positive edges stay put: this unifies and strictly generalizes 2 and 3, with a level-by-level least-fixed-point construction. Strictness is witnessed (Prop. 7.6) and non-necessity is witnessed (Prop. 7.7).
5. **Height collapse (Theorem 8.3).** Well-foundedness of the dependency relation is *equivalent* to the existence of an $\mathbb{N}$-rank.
6. **Exact cost accounting (Theorems 9.2, 9.4, 9.5).** Model sets of positive tangles are bracketed by extremal fixed points; the single-name trichotomy $1/2/0$; $k$ loops give $2^k$ models and $0$ new theorems.
7. **Sharpness (Theorem 10.1).** The liar destroys conservativity by inconsistency.

---

## 2. The language

### 2.1 Syntax

Fix two sets: a set $A$ of **atoms** (the vocabulary of the base, or "old", theory) and a set $I$ of **names**.

> **Definition 2.1 (Formulas).** The set $\mathrm{Frm}(A, I)$ of formulas is generated inductively by:
> - $a$, for each atom $a \in A$;
> - $\bot$;
> - $\varphi \to \psi$, for formulas $\varphi, \psi$;
> - $T c$, for each name $c \in I$ (the **truth atom** of $c$).

We abbreviate $\neg \varphi := \varphi \to \bot$ and
$$\varphi \leftrightarrow \psi \;:=\; \neg\big( (\varphi \to \psi) \to \neg(\psi \to \varphi) \big),$$
which under the semantics below has exactly the truth table of the biconditional. Only $\bot$ and $\to$ are primitive; the choice is immaterial and merely keeps the inductions short.

> **Definition 2.2 (Truth-free formulas).** A formula is **truth-free** if it contains no truth atom: atoms and $\bot$ are truth-free, $\varphi \to \psi$ is truth-free iff both conjuncts are, and $T c$ is never truth-free. The truth-free formulas constitute the **old language**.

> **Definition 2.3 (Occurrence).** The name $c$ **occurs** in $\varphi$, written $\mathrm{Occ}(c, \varphi)$, if: $\varphi = T c$; or $\varphi = \varphi_1 \to \varphi_2$ and $c$ occurs in $\varphi_1$ or in $\varphi_2$. No name occurs in an atom or in $\bot$.

### 2.2 Polarity

Polarity is the crucial syntactic invariant. We define it twice: once as a global property of a formula, once as a property of a particular name's occurrences.

> **Definition 2.4 (Global polarity).** Define $\mathrm{Pol}(b, \varphi)$ for $b \in \{+,-\}$ by recursion:
> - $\mathrm{Pol}(b, a)$ and $\mathrm{Pol}(b, \bot)$ hold for both $b$;
> - $\mathrm{Pol}(b, \varphi \to \psi)$ iff $\mathrm{Pol}(\bar b, \varphi)$ and $\mathrm{Pol}(b, \psi)$, where $\bar b$ is the opposite sign;
> - $\mathrm{Pol}(b, T c)$ iff $b = +$.
>
> A formula $\varphi$ is **positive** if $\mathrm{Pol}(+, \varphi)$, i.e. every truth atom of $\varphi$ occurs positively; it is **negative** if $\mathrm{Pol}(-, \varphi)$, i.e. every truth atom of $\varphi$ occurs negatively — equivalently, $\neg\varphi$ is positive. Every truth-free formula is both positive and negative, and no truth atom is negative.

Note $\neg \varphi = \varphi \to \bot$ is positive iff $\varphi$ is negative: negation flips polarity, as expected.

> **Definition 2.5 (Polarized occurrence).** $\mathrm{Occ}^{+}(c, \varphi)$ and $\mathrm{Occ}^{-}(c, \varphi)$ are defined by:
> - neither holds for atoms or $\bot$;
> - $\mathrm{Occ}^{b}(c, \varphi \to \psi)$ iff $\mathrm{Occ}^{\bar b}(c, \varphi)$ or $\mathrm{Occ}^{b}(c, \psi)$;
> - $\mathrm{Occ}^{b}(c, T c')$ iff $b = +$ and $c' = c$.
>
> Thus $c$ occurs positively (resp. negatively) if some occurrence of $T c$ lies under an even (resp. odd) number of antecedent positions. A name may occur both positively and negatively in the same formula: in $T c \to T c$, the name $c$ does both.

Two easy inductions relate the notions:

> **Lemma 2.6.** (i) If $\mathrm{Occ}^{b}(c, \varphi)$ for some $b$, then $\mathrm{Occ}(c, \varphi)$. (ii) Conversely, if $\mathrm{Occ}(c, \varphi)$ then $\mathrm{Occ}^{+}(c, \varphi)$ or $\mathrm{Occ}^{-}(c, \varphi)$. (iii) If $\varphi$ is positive then no name occurs negatively in $\varphi$.

### 2.3 Semantics

> **Definition 2.7 (Evaluation).** Given a **base valuation** $v : A \to \{ \text{true}, \text{false} \}$ and a **name assignment** $w : I \to \{\text{true},\text{false}\}$, the value $[\![\varphi]\!]_{v,w}$ is defined by the obvious recursion: $[\![a]\!] = v(a)$, $[\![\bot]\!] = \text{false}$, $[\![\varphi \to \psi]\!] = ([\![\varphi]\!] \Rightarrow [\![\psi]\!])$, $[\![T c]\!] = w(c)$.

For a set $S$ of formulas, $(v,w) \models S$ means $[\![\varphi]\!]_{v,w}$ is true for all $\varphi \in S$; and $S \models \psi$ ("$S$ entails $\psi$") means every $(v,w)$ satisfying $S$ satisfies $\psi$.

Three elementary but load-bearing lemmas:

> **Lemma 2.8 (Truth-free invariance).** If $\varphi$ is truth-free then $[\![\varphi]\!]_{v,w} = [\![\varphi]\!]_{v,w'}$ for all $w, w'$.

> **Lemma 2.9 (Occurrence locality).** If $w(c) = w'(c)$ for every $c$ occurring in $\varphi$, then $[\![\varphi]\!]_{v,w} = [\![\varphi]\!]_{v,w'}$.

> **Lemma 2.10 (Polarity monotonicity).** Suppose $w \le w'$ pointwise (i.e. $w(c)$ true implies $w'(c)$ true). Then: if $\varphi$ is positive, $[\![\varphi]\!]_{v,w}$ true implies $[\![\varphi]\!]_{v,w'}$ true; if $\varphi$ is negative, $[\![\varphi]\!]_{v,w'}$ true implies $[\![\varphi]\!]_{v,w}$ true.

*Proof sketch of 2.10.* Simultaneous induction on $\varphi$, the two statements swapping roles at the antecedent of an implication; the base cases are trivial and the case $T c$ is the hypothesis $w \le w'$ in one direction and vacuous in the other, since $T c$ is never negative. $\square$

A refinement of 2.10, needed for local stratification, tracks polarity per name rather than globally:

> **Lemma 2.11 (Polarized shift).** Let $w, w'$ be assignments such that for every name $c$: if $c$ occurs positively in $\varphi$ then $w(c)$ true implies $w'(c)$ true; and if $c$ occurs negatively in $\varphi$ then $w'(c)$ true implies $w(c)$ true. Then $[\![\varphi]\!]_{v,w}$ true implies $[\![\varphi]\!]_{v,w'}$ true.

---

## 3. Tangled hierarchies

> **Definition 3.1 (Tangled hierarchy).** A **tangled hierarchy** on $(A, I)$ is a function $\mathrm{den} : I \to \mathrm{Frm}(A,I)$. The formula $\mathrm{den}(c)$ is the **sentence named by** $c$. No constraint is imposed: $\mathrm{den}(c)$ may contain $T c$, and the *dependency relation*
> $$c' \prec c \quad :\Longleftrightarrow \quad \mathrm{Occ}(c', \mathrm{den}(c))$$
> may contain cycles of any length, including self-loops.

> **Definition 3.2 (Tarski theory).** The **tangled theory** of $\mathrm{den}$ is
> $$\mathrm{Tar}(\mathrm{den}) \;=\; \{\, T c \leftrightarrow \mathrm{den}(c) \;:\; c \in I \,\}.$$

> **Definition 3.3 (Model of the tangle).** Given a base valuation $v$, an assignment $w$ is a **model** of $\mathrm{den}$ over $v$ if
> $$w(c) \;\Longleftrightarrow\; [\![\mathrm{den}(c)]\!]_{v,w} \qquad \text{for every } c \in I .$$
> We write $\mathrm{Mod}_v(\mathrm{den})$ for the set of such $w$.

> **Lemma 3.4.** $(v,w) \models \mathrm{Tar}(\mathrm{den})$ if and only if $w \in \mathrm{Mod}_v(\mathrm{den})$.

*Proof.* Unfold the encoded biconditional; its truth table is the intended one. $\square$

Thus $\mathrm{Mod}_v(\mathrm{den})$ is the solution set of a system of simultaneous fixed-point equations in the unknowns $w(c)$, with the base valuation $v$ as a parameter. This is the object the whole paper studies.

> **Definition 3.5 (Conservativity).** Let $\mathcal{T}$ be a set of truth-free formulas. The tangle $\mathrm{den}$ is **conservative over $\mathcal{T}$** if for every truth-free $\psi$,
> $$\mathcal{T} \cup \mathrm{Tar}(\mathrm{den}) \models \psi \quad \Longleftrightarrow \quad \mathcal{T} \models \psi .$$
> It is **conservative** (simpliciter) if it is conservative over every truth-free $\mathcal{T}$.

Taking $\psi = \bot$ shows that conservativity implies relative consistency: tangling a consistent truth-free theory keeps it consistent.

---

## 4. The exact criterion

The right-to-left direction of Definition 3.5 is trivial (monotonicity of entailment), so conservativity is really the statement that adding the biconditionals proves nothing new.

> **Theorem 4.1 (Conservativity from expandability).** Suppose every base valuation $v$ admits some $w \in \mathrm{Mod}_v(\mathrm{den})$. Then $\mathrm{den}$ is conservative over every truth-free base theory.

*Proof.* Let $\mathcal{T}$, $\psi$ be truth-free and suppose $\mathcal{T} \cup \mathrm{Tar}(\mathrm{den}) \models \psi$. Take any $(v,w)$ with $(v,w) \models \mathcal{T}$. By hypothesis choose $w' \in \mathrm{Mod}_v(\mathrm{den})$. Then $(v, w') \models \mathcal{T}$ by Lemma 2.8, and $(v,w') \models \mathrm{Tar}(\mathrm{den})$ by Lemma 3.4. Hence $[\![\psi]\!]_{v,w'}$ is true, and by Lemma 2.8 again $[\![\psi]\!]_{v,w}$ is true. So $\mathcal{T} \models \psi$. $\square$

The converse requires a base theory rich enough to pin down a valuation. The **diagram** of $v$ is
$$\mathrm{Diag}(v) \;=\; \{\, \varphi \;:\; \varphi \text{ truth-free and } [\![\varphi]\!]_{v,\cdot} \text{ true} \,\}$$
(well defined by Lemma 2.8). It is a set of truth-free formulas, it is satisfied by $(v,w)$ for every $w$, and — because it contains each atom $a$ with $v(a)$ true and each $\neg a$ with $v(a)$ false — any $(v', w')$ satisfying it has $v'$ agreeing with $v$ on every atom.

> **Theorem 4.2 (Characterization of conservativity).** For any tangled hierarchy $\mathrm{den}$, the following are equivalent:
> 1. every base valuation $v$ admits a model $w \in \mathrm{Mod}_v(\mathrm{den})$;
> 2. $\mathrm{den}$ is conservative over every truth-free base theory.

*Proof.* $(1) \Rightarrow (2)$ is Theorem 4.1. For $(2) \Rightarrow (1)$, suppose some $v$ has $\mathrm{Mod}_v(\mathrm{den}) = \varnothing$. We claim $\mathrm{Diag}(v) \cup \mathrm{Tar}(\mathrm{den}) \models \bot$. Indeed, let $(v', w') $ satisfy it; then $v'$ agrees with $v$ atomwise, so by invariance of evaluation under atomwise-equivalent valuations, $w'$ is a model of $\mathrm{den}$ over $v$ as well — contradicting emptiness. So the theory $\mathrm{Diag}(v) \cup \mathrm{Tar}(\mathrm{den})$ has no model at all and entails $\bot$ vacuously. But $\mathrm{Diag}(v) \not\models \bot$, since $(v, \lambda c.\,\text{false})$ satisfies $\mathrm{Diag}(v)$. So conservativity fails for $\mathcal{T} = \mathrm{Diag}(v)$, $\psi = \bot$. $\square$

**Interpretation.** Conservativity of a tangled hierarchy is not a subtle proof-theoretic property; it *is* the solvability of the loop equations, uniformly in the state of the base. Every subsequent theorem is a structural sufficient condition for solvability.

---

## 5. Positive tangles: Knaster–Tarski

Order assignments pointwise: $w \le w'$ iff $w(c)$ true implies $w'(c)$ true for all $c$. The set of assignments is then a complete lattice (a powerset lattice on $I$).

> **Definition 5.1 (Revision operator).** For a tangle $\mathrm{den}$ all of whose sentences are positive, and a base valuation $v$, define
> $$R_{v}(w)(c) \;=\; [\![\mathrm{den}(c)]\!]_{v,w} .$$

> **Lemma 5.2.** If every $\mathrm{den}(c)$ is positive then $R_v$ is monotone.

*Proof.* Immediate from Lemma 2.10. $\square$

By Knaster–Tarski, a monotone endomap of a complete lattice has a least fixed point $\mathrm{lfp}(R_v)$ and a greatest fixed point $\mathrm{gfp}(R_v)$; and by Definition 3.3, $w \in \mathrm{Mod}_v(\mathrm{den})$ iff $R_v(w) = w$.

> **Theorem 5.3 (Conservativity of positive tangles).** If every sentence of a tangled hierarchy is positive, then the hierarchy has a model over every base valuation and is therefore conservative over every truth-free base theory. In particular, adding the Tarski biconditionals of an arbitrarily looped positive tangle to a consistent truth-free theory preserves consistency.

*Proof.* $\mathrm{lfp}(R_v)$ is a model by Lemma 5.2 and Knaster–Tarski; apply Theorem 4.1. $\square$

**What is *not* assumed.** Nothing about the reference graph. A name may denote a sentence about itself; the graph may be a single enormous strongly connected component. Positivity alone — no truth atom under a negation — is sufficient.

---

## 6. Grounded tangles: existence and uniqueness

> **Definition 6.1 (Grounded / rank-stratified).** A tangle $\mathrm{den}$ is **grounded** with rank $\mathrm{rk} : I \to \mathbb{N}$ if
> $$\mathrm{Occ}(c', \mathrm{den}(c)) \;\Longrightarrow\; \mathrm{rk}(c') < \mathrm{rk}(c).$$

Groundedness forbids cycles entirely but imposes no polarity restriction. Define the **revision sequence** from the empty extension:
$$R^0 = \lambda c.\,\text{false}, \qquad R^{n+1}(c) = [\![\mathrm{den}(c)]\!]_{v, R^n}.$$

> **Lemma 6.2 (Stabilization).** If $\mathrm{den}$ is grounded with rank $\mathrm{rk}$, then for every name $c$ and all $n, m > \mathrm{rk}(c)$ we have $R^n(c) = R^m(c)$.

*Proof sketch.* Strong induction on $n$. The value $R^{n+1}(c)$ depends by Lemma 2.9 only on the values $R^n(c')$ for $c'$ occurring in $\mathrm{den}(c)$, all of which have strictly smaller rank; apply the induction hypothesis to each. $\square$

Define the **canonical assignment** $w^{\mathrm{st}}(c) := R^{\mathrm{rk}(c)+1}(c)$.

> **Theorem 6.3 (Determinacy of grounded tangles).** If $\mathrm{den}$ is grounded, then for every base valuation $v$ there is *exactly one* model, namely $w^{\mathrm{st}}$.

*Proof sketch.* That $w^{\mathrm{st}}$ is a model follows by unfolding the definition and applying Lemma 6.2 to the finitely many names occurring in $\mathrm{den}(c)$, each of smaller rank. Uniqueness: given any model $w$, prove $w(c) = w^{\mathrm{st}}(c)$ by strong induction on $\mathrm{rk}(c)$; both sides equal $[\![\mathrm{den}(c)]\!]$ evaluated at assignments that agree on all names occurring in $\mathrm{den}(c)$, by induction hypothesis and Lemma 2.9. $\square$

> **Theorem 6.4 (Conservativity of grounded tangles).** A grounded tangled hierarchy, of arbitrary polarity, is conservative over every truth-free base theory.

*Proof.* Theorem 6.3 plus Theorem 4.1. $\square$

### 6.1 Internal soundness for the old theory is free

> **Corollary 6.5 (Naming the old language).** Suppose every $\mathrm{den}(c)$ is truth-free. Then the biconditionals $T c \leftrightarrow \mathrm{den}(c)$ — which state precisely that the internal truth predicate is sound *and* complete for the named old sentences — are conservative over every truth-free base theory, and the truth predicate they describe is uniquely determined by the base valuation.

*Proof.* A truth-free formula contains no name occurrence, so the constant rank $\mathrm{rk} \equiv 0$ grounds the tangle vacuously; apply Theorems 6.3 and 6.4. $\square$

This is the exact sense in which *internal soundness for the old theory costs nothing*: no new theorem, and not even a new degree of freedom.

---

## 7. Local stratification: loops inside a level

Theorems 5.3 and 6.4 are incomparable: the first allows arbitrary cycles but no negation of truth atoms, the second arbitrary negation but no cycles. Their common generalization relaxes each restriction exactly where the other is strong.

> **Definition 7.1 (Locally stratified).** A tangle $\mathrm{den}$ is **locally stratified** by $\mathrm{rk} : I \to \mathbb{N}$ if
> - (**neg**) $\mathrm{Occ}^{-}(c', \mathrm{den}(c)) \Longrightarrow \mathrm{rk}(c') < \mathrm{rk}(c)$, and
> - (**pos**) $\mathrm{Occ}^{+}(c', \mathrm{den}(c)) \Longrightarrow \mathrm{rk}(c') \le \mathrm{rk}(c)$.

So loops are permitted within a level; only negative (refutation-like) dependencies must strictly descend. By Lemma 2.6(ii), every occurrence satisfies $\mathrm{rk}(c') \le \mathrm{rk}(c)$.

The model is built level by level. Fix $v$ and write $A$ for an assignment already computed for the levels below.

> **Definition 7.2 (Level operator).** For $n \in \mathbb{N}$ and an assignment $A$, define
> $$L_{n,A}(w)(c) \;=\; \begin{cases} [\![\mathrm{den}(c)]\!]_{v,\; \lambda c'.\, (\text{if } \mathrm{rk}(c') < n \text{ then } A(c') \text{ else } w(c'))} & \text{if } \mathrm{rk}(c) \le n, \\[2pt] \text{false} & \text{otherwise.} \end{cases}$$
> That is: names strictly below level $n$ are frozen at their computed values; names at level $\le n$ are revised; names above are set false.

> **Lemma 7.3.** If $\mathrm{den}$ is locally stratified by $\mathrm{rk}$, then $L_{n,A}$ is monotone.

*Proof sketch.* Apply Lemma 2.11 to $\mathrm{den}(c)$ for a name $c$ with $\mathrm{rk}(c) \le n$. For a positively occurring $c'$: either $\mathrm{rk}(c') < n$, in which case both assignments give the frozen value $A(c')$, or the value is $w(c')$, which increases with $w$. For a negatively occurring $c'$: condition (**neg**) gives $\mathrm{rk}(c') < \mathrm{rk}(c) \le n$, so $c'$ is frozen and its value does not move at all. Hence the polarized shift hypothesis holds and monotonicity follows. $\square$

Define $F_0 = \lambda c.\,\text{false}$ and $F_{n+1} = \mathrm{lfp}(L_{n, F_n})$; finally set
$$w^{\mathrm{loc}}(c) \;=\; F_{\mathrm{rk}(c)+1}(c).$$

A stability lemma — proved by induction on levels, using that all dependencies of $c$ have rank $\le \mathrm{rk}(c)$ and negative ones strictly less — shows that $F_m(c) = F_{\mathrm{rk}(c)+1}(c)$ for all $m > \mathrm{rk}(c)$; consequently the levels glue, and $w^{\mathrm{loc}}$ satisfies every loop equation.

> **Theorem 7.4 (Local stratification implies conservativity).** Every locally stratified tangled hierarchy has a model over every base valuation, and is therefore conservative over every truth-free base theory: an arbitrarily tangled level may be bolted onto a theory without changing a single old consequence.

> **Proposition 7.5 (Both earlier theorems are special cases).** A positive tangle is locally stratified by the constant rank $0$ (there are no negative occurrences, by Lemma 2.6(iii)). A grounded tangle with rank $\mathrm{rk}$ is locally stratified by the same $\mathrm{rk}$.

> **Proposition 7.6 (Strictness).** Let $I = \{p, q\}$ and
> $$\mathrm{den}(q) = \bot, \qquad \mathrm{den}(p) = T q \to T p .$$
> Then $\mathrm{den}$ is locally stratified by $\mathrm{rk}(q) = 0$, $\mathrm{rk}(p) = 1$; it is not positive (since $q$ occurs negatively in $\mathrm{den}(p)$); and it is not grounded (since $p$ occurs in $\mathrm{den}(p)$, so no rank can strictly descend). Hence it is conservative by Theorem 7.4 though neither Theorem 5.3 nor Theorem 6.4 applies.

> **Proposition 7.7 (Non-necessity).** Let $I = \{c\}$ and $\mathrm{den}(c) = T c \to T c$. Then $c$ occurs both positively and negatively in its own sentence, so no rank locally stratifies it; nevertheless every assignment is a model (the sentence is a tautology), so the tangle is conservative.

Thus local stratification is a *sufficient, checkable, and strictly more general* condition, but Theorem 4.2 remains the exact criterion.

---

## 8. Well-founded tangles and the collapse of height

Dropping numerical grading altogether, require only that the dependency relation $c' \prec c \iff \mathrm{Occ}(c', \mathrm{den}(c))$ be well-founded.

> **Theorem 8.1 (Determinacy of well-founded tangles).** If $\prec$ is well-founded then for every base valuation $v$ there is exactly one model, whatever the polarities.

*Proof sketch.* Define the truth value at $c$ by recursion along $\prec$: evaluate $\mathrm{den}(c)$ against the values already defined at the names it mentions (all of which are $\prec$-below $c$). One checks that this partial-assignment evaluation agrees with ordinary evaluation once the assignment is total, so the resulting $w$ solves every loop equation. Uniqueness is $\prec$-induction combined with Lemma 2.9. $\square$

> **Theorem 8.2 (Conservativity).** A well-founded tangled hierarchy of arbitrary height and arbitrary polarity is conservative over every truth-free base theory.

The next result is the structural surprise.

> **Theorem 8.3 (Height collapse).** For any tangled hierarchy $\mathrm{den}$, the dependency relation $\prec$ is well-founded **if and only if** there exists $\mathrm{rk} : I \to \mathbb{N}$ with $\mathrm{Occ}(c', \mathrm{den}(c)) \Rightarrow \mathrm{rk}(c') < \mathrm{rk}(c)$.

*Proof sketch.* ($\Leftarrow$) A relation embedding into $<$ on $\mathbb{N}$ is well-founded. ($\Rightarrow$) Each formula mentions only finitely many names — the list of names of $\varphi$ is defined by an obvious recursion and its membership coincides with occurrence — so
$$\mathrm{rk}(c) \;=\; 1 + \max \{\, \mathrm{rk}(c') \;:\; c' \text{ occurs in } \mathrm{den}(c) \,\}$$
is a legitimate definition by $\prec$-recursion, the maximum being over a finite list (empty maximum $= 0$), and it strictly descends by construction. $\square$

**Interpretation.** A finitary tangled hierarchy may be *infinitely tall* — the ranks unbounded — but never *transfinitely tall*: no name sits at level $\omega$ or beyond. Finiteness of syntax is what forces the collapse, so the well-founded theory and the $\mathbb{N}$-graded theory coincide exactly.

> **Example 8.4 (An infinitely tall, nowhere positive, fully determined tangle).** Let $I = \mathbb{N} \sqcup \{\star\}$ and
> $$\mathrm{den}(0) = \bot, \qquad \mathrm{den}(n+1) = \neg T n, \qquad \mathrm{den}(\star) = T 0 .$$
> Every link between consecutive levels is a negation, so the tangle is nowhere positive; the ranks are unbounded, so no uniform finite bound applies. It is well-founded, hence conservative and determined: the unique model is $T0$ false, $T1$ true, $T2$ false, …, alternating forever, with $T\star$ false. Infinite regress is not vicious circularity.

---

## 9. The price of a strange loop: indeterminacy, measured

Conservativity says the tangle adds no *theorems*. It does not say it adds nothing. What it adds is *indeterminacy*, and for positive tangles the indeterminacy is exactly the gap between two canonical extensions.

> **Theorem 9.1 (Fixed-point description).** For a positive tangle, $\mathrm{Mod}_v(\mathrm{den})$ is exactly the fixed-point set of the monotone operator $R_v$. Consequently $\mathrm{lfp}(R_v)$ and $\mathrm{gfp}(R_v)$ are models, and every model $w$ satisfies
> $$\mathrm{lfp}(R_v) \;\le\; w \;\le\; \mathrm{gfp}(R_v) .$$

*Proof.* $w$ is a model iff $R_v(w) = w$ by Definition 3.3; the bracketing is the defining property of least and greatest fixed points. $\square$

> **Theorem 9.2 (Determinacy criterion).** A positive tangle has a unique model over $v$ if and only if $\mathrm{lfp}(R_v) = \mathrm{gfp}(R_v)$.

*Proof.* If unique, the two extremal models coincide. Conversely, if they coincide, every model is squeezed between equal bounds. $\square$

So all semantic indeterminacy is concentrated in the interval $[\mathrm{lfp}, \mathrm{gfp}]$: the minimal extension is the *sceptical* truth predicate (assert only what is forced), the maximal one the *credulous* predicate (assert everything not forbidden).

### 9.1 $k$ independent loops

> **Definition 9.3.** The **pure loop tangle** on $k$ names is $I = \{c_1,\dots,c_k\}$ with $\mathrm{den}(c_i) = T c_i$: $k$ independent truth-tellers.

> **Theorem 9.4 (Exponential semantics, zero syntax).** The pure loop tangle on $k$ names satisfies:
> 1. every assignment is a model, so $|\mathrm{Mod}_v| = 2^k$ for every base valuation $v$;
> 2. for each $i$, the tangled theory decides neither $T c_i$ nor $\neg T c_i$;
> 3. for every truth-free base theory $\mathcal{T}$ and truth-free $\psi$, $\mathcal{T} \cup \mathrm{Tar}(\mathrm{den}) \models \psi$ iff $\mathcal{T} \models \psi$;
> 4. for $k \ge 1$, $\mathrm{lfp}(R_v) \ne \mathrm{gfp}(R_v)$: the minimal extension declares every loop false and the maximal one declares them all true.

*Proof.* (1) The equation $w(c_i) \leftrightarrow w(c_i)$ is vacuous; the model set is the whole space, of cardinality $2^k$. (2) Exhibit the all-false and all-true models. (3) The tangle is positive, so Theorem 5.3 applies. (4) Direct computation of the extremal fixed points of the identity operator. $\square$

**Slogan.** The cost of tangling is exponential in semantics and zero in syntax.

### 9.2 The cost of one loop

> **Theorem 9.5 (Single-name trichotomy).** Consider a tangle on one name $c$ and any base valuation. Then
> $$\big|\mathrm{Mod}(\mathrm{den}(c) = \bot)\big| = 1, \qquad \big|\mathrm{Mod}(\mathrm{den}(c) = T c)\big| = 2, \qquad \big|\mathrm{Mod}(\mathrm{den}(c) = \neg T c)\big| = 0 .$$
> That is: a grounded denotation pins the truth predicate down; a positive self-loop (the truth-teller) leaves exactly one bit free; a negative self-loop (the liar) is unsatisfiable.

*Proof.* Solve $w \leftrightarrow \text{false}$, $w \leftrightarrow w$, $w \leftrightarrow \neg w$ respectively. $\square$

The numbers $1, 2, 0$ are the entire cost structure of self-reference in miniature: grounding buys determinacy for free, a positive loop costs one bit and buys nothing, a negative loop costs everything.

---

## 10. Sharpness: the liar

> **Theorem 10.1 (The liar is not conservative).** Let $I = \{c\}$ and $\mathrm{den}(c) = \neg T c$. Then $\mathrm{Tar}(\mathrm{den}) \models \bot$, while the empty theory is consistent. Hence the liar tangle is conservative over no truth-free base theory whatsoever.

*Proof.* A model would satisfy $w(c) \leftrightarrow \neg w(c)$, impossible; so $\mathrm{Tar}(\mathrm{den})$ has no models and entails everything, in particular $\bot$. The empty theory is satisfied by any valuation and does not entail $\bot$. $\square$

Combined with Theorem 4.2, this shows that each positive theorem above is sharp in its own direction: positivity cannot simply be dropped (Theorem 5.3), descent of negative dependencies cannot simply be dropped (Theorem 7.4), and well-foundedness cannot simply be dropped (Theorem 8.2) — the liar violates exactly the discarded clause in each case.

---

## 11. Algorithms

The theory is constructive enough to run. Throughout, let the tangle be finite: $n = |I|$ names, and let $s$ be the total size of the sentences $\mathrm{den}(c)$.

### 11.1 Model enumeration by fixed-point search

For arbitrary polarity and small $n$, the model set is computed by brute force: enumerate all $2^n$ assignments and test each of the $n$ loop equations. Cost $O(2^n \cdot s)$. This is the reference implementation against which the structural algorithms are validated, and it is what one uses to check trichotomies and model counts on tiny examples.

### 11.2 Least fixed point by Kleene iteration (positive tangles)

If every sentence is positive, $R_v$ is monotone on the $2^n$-element lattice, so the ascending chain $\varnothing \le R_v(\varnothing) \le R_v^2(\varnothing) \le \cdots$ stabilizes after at most $n$ steps at $\mathrm{lfp}(R_v)$; dually, iterating downward from the all-true assignment converges to $\mathrm{gfp}(R_v)$ in at most $n$ steps. Cost $O(n \cdot s)$ each. By Theorem 9.2 this yields a *linear-time determinacy test*: the tangle is determinate iff the two limits agree, without ever enumerating models.

### 11.3 Local stratification check and level-by-level model construction

Computing polarized occurrences of each name in each sentence takes $O(s)$. Local stratification then asks for a rank $\mathrm{rk}$ with strict inequalities on negative edges and non-strict on positive ones — a difference-constraint system, solvable by a shortest-path / Bellman–Ford computation on the dependency graph in $O(n \cdot |E|)$, where a negative cycle (in the appropriate weighting) is exactly an obstruction. Equivalently and more simply: contract the strongly connected components of the dependency graph; the tangle is locally stratified iff no strongly connected component contains a negative edge, and then the rank is the position of the component in a topological order.

Given a valid rank, the model is built by the level construction of Section 7: process levels in increasing order, freezing everything below and running Kleene iteration within the level. Total cost $O(n \cdot s)$, since each name is revised at most a bounded number of times per level and the levels partition the names.

### 11.4 Conservativity certification

Putting the pieces together: given a finite tangle, (i) compute polarized occurrence data; (ii) test the no-negative-edge-inside-a-strongly-connected-component condition; (iii) if it holds, output the rank and the level-by-level model as a *certificate of conservativity* — by Theorems 7.4 and 4.1, the existence of a model over each base valuation is precisely what conservativity requires. When the base atoms are finitely many, one certificate per valuation suffices for a complete proof; when they are infinitely many, the level construction is uniform in $v$ and the certificate is a single parametric construction.

---

## 12. Applications and interpretation

**Recursive and inductive definitions.** The revision operator is precisely the one-step operator of a system of mutually recursive definitions, and positivity is precisely the syntactic condition under which such a system is monotone and its least fixed point is the intended meaning. Theorem 5.3 says: the extended vocabulary defined by any monotone recursive system is a definitional extension in the strongest sense — it decides nothing new about the old vocabulary.

**Stratified negation in deductive databases and logic programming.** The requirement that recursion not pass through negation is the practitioner's version of Definition 7.1: negative edges must descend, positive edges may cycle. Theorem 7.4 identifies exactly what that engineering discipline buys — solvability, hence conservativity — and Proposition 7.7 shows the discipline is not necessary, only sufficient and cheap to check.

**Reflection principles.** A system reasoning about its own assertions requires an internal truth or provability predicate. Corollary 6.5 is the propositional shadow of a reflection principle for the old language: asserting internal soundness *and* completeness for named old sentences is free, adding neither theorem nor degree of freedom. The contrast with the arithmetized setting is instructive: there, reflection for a theory is famously *not* conservative, because the named sentences can express the naming apparatus itself, i.e. the tangle is no longer grounded.

**Self-describing data and metadata.** A knowledge base with records asserting the truth of other records is literally a tangled hierarchy. The design question is not "are there cycles?" but "do the loop equations have a solution in every state of the base data?", and the practical answer is the strongly-connected-component test of Section 11.3.

**The Hofstadter thesis.** Read against Section 9, the results give a nuanced verdict on the claim that strange loops leave the levels above intact. They do — *provided their negations are grounded*. What the loop costs is not soundness but definiteness: a system containing $k$ independent strange loops has $2^k$ equally admissible self-descriptions and no way to choose among them, while agreeing with itself, and with the loop-free system, on every statement about the world.

---

## 13. Discussion and limitations

The setting is propositional and the self-reference is stipulated rather than constructed. This is a genuine simplification: in an arithmetized setting, self-reference arises from a diagonal lemma and the "denotation function" is a definable object of the theory, which introduces interaction between the naming apparatus and the base theory that is invisible here. The compensating gain is that every self-referential configuration is available and the structural conditions are exactly visible.

Second, all results are *semantic*: conservativity is stated in terms of entailment over all valuations, not derivability in a calculus. For classical propositional logic completeness makes this immaterial for the finitary statements, but a genuinely proof-theoretic version — with a bound on the size of the transformed derivation — is a separate and interesting question (see Conjecture 1 below).

Third, the model-counting results are for very simple tangles (independent loops, single names). A general formula counting the models of an arbitrary finite positive tangle in terms of its loop structure is not established here; Conjecture 2 below states what we expect.

---

## 14. Future directions

### Conjecture 1 (Syntactic conservativity via cut elimination)

Every conservativity result above is semantic. We conjecture that for a locally stratified tangle there is a **proof-theoretic** conservativity theorem: a sequent calculus for the tangled language in which every derivation of a truth-free sequent from the Tarski biconditionals can be transformed, by a terminating rewriting on derivations, into a derivation using no biconditional — with at most an exponential blow-up in size, and only a polynomial blow-up when the tangle is grounded.

The key insight is that the level-by-level model construction is the semantic shadow of a *cut-elimination strategy eliminating truth atoms in order of decreasing rank*: each least-fixed-point stage corresponds to saturating the positive loops of one level, which is exactly where the exponential factor should appear. The semantic theorem fixes the right hypotheses (local stratification) and the right boundary (the tautological loop $T c \to T c$; the liar), so the proof-theoretic version now has a precise target and a known counterexample to respect.

### Conjecture 2 (Loop count = degrees of freedom)

For a finite positive tangle whose dependency digraph has $k$ strongly connected components containing a cycle ("strange loops"), we conjecture that the model set is a complete lattice whose height is bounded by a function of $k$ alone, and that the number of models is at most $2^{(\text{total size of the loops})}$, with equality exactly when every loop is a disjoint truth-teller. In particular conservativity is uniform in the loop count: the syntactic cost stays $0$ for all $k$.

The key insight is that the least and greatest fixed points bracket every model, so all indeterminacy is concentrated in the interval between them, and that interval should factor as a product over the cyclic strongly connected components of the dependency graph.

### Further questions

- **Quantified and first-order tangles.** Extending the language with quantifiers over an object domain, keeping the truth atoms propositional, should preserve every theorem here; extending to a genuinely first-order truth predicate applied to codes is where Tarskian undefinability re-enters, and the exact interface deserves a theorem.
- **Partial and paraconsistent valuations.** Kripke's least fixed point over a partial (three-valued) semantics tames the liar by allowing gaps. In the present framework the liar is unsatisfiable rather than gappy; the natural question is whether a three-valued version of Theorem 4.2 restores conservativity for *all* tangles, with the price of the liar becoming a gap rather than an inconsistency.
- **Complexity of the criterion.** Deciding whether a finite tangle of arbitrary polarity has a model over a given valuation is an NP-complete problem in general (it encodes propositional satisfiability). The structural conditions here are exactly the polynomial-time islands; a complete classification of tractable tangle shapes would be valuable.
- **Quantitative indeterminacy.** Defining the *entropy* of a tangle as $\log_2$ of its model count gives $k$ bits for $k$ independent loops and $0$ for grounded tangles. Is this entropy sub-additive under composition of tangles, and is it computable in polynomial time for positive tangles?

---

## 15. Summary of results

| Condition on the tangle | Models over each valuation | Conservative? |
|---|---|---|
| Arbitrary | — | iff every valuation expands to a model (exact criterion) |
| Positive (no truth atom negated) | $\ge 1$ (least and greatest fixed points) | yes |
| Grounded ($\mathbb{N}$-rank, all edges descend) | exactly $1$ | yes |
| Locally stratified (negative edges descend, positive edges stay) | $\ge 1$ | yes |
| Well-founded dependency | exactly $1$; equivalent to having an $\mathbb{N}$-rank | yes |
| $k$ independent truth-tellers | exactly $2^k$ | yes |
| Single name: $\bot$ / $T c$ / $\neg T c$ | $1$ / $2$ / $0$ | yes / yes / **no** |

The through-line: **conservativity is solvability**; solvability is guaranteed by monotonicity, by grounding, or by the hybrid of the two; and the entire cost of a strange loop is paid in indeterminacy, never in new theorems — until the loop turns negative on itself, at which point nothing can be paid at all.
