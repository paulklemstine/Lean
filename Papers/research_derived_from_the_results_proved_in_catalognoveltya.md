# Truncation Orders and Reflection Depths in Tagged Provability Logic

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We study two finite quantitative invariants of theories in a multi-tagged language of
provability: the *inconsistency height*, measured by the least $k$ with
$\vdash \Box_i^k \bot$, and the *reflection depth*, the largest $d$ for which the rule
"$\vdash \Box_i a$ implies $\vdash a$" is valid for all formulas $a$ of box depth
$< d$. Two families of consistent theories of the logic of provability GL are analysed
completely.

The first is the family $\mathcal{L}(c,N)$ of *tag-sensitive finite-height ladder
theories*, indexed by a height function $c : \mathbb{N} \to \mathbb{N}$ and a truncation
level $N$. It is known that $\mathcal{L}(c,N)$ depends on $c$ only through its *depth
vector* $d_c(i) = \min(N, c(i))$, and that the depth vector is a complete invariant. We
determine the *inclusion order* on this family exactly. We refute the standing
conjecture that inclusion is governed by pointwise growth of the depth vector together
with preservation of the relative order of the depths, exhibiting a counterexample at
truncation level $N = 2$ with a single explicit separating formula; we prove that the
conjectured criterion is nonetheless necessary, and that it is sufficient precisely for
$N \le 1$, so that $N = 2$ is the least failing level. The exact criterion,
*depth domination*, requires pointwise growth together with the condition that a depth
may strictly increase only at a tag of maximal depth. Equivalently — and this is the
structural content — the weakenings of a theory in this family are exactly its uniform
*truncations*: $\mathcal{L}(c,N)$ is weaker than $\mathcal{L}(c',N)$ iff
$d_c = \min(D, d_{c'})$ pointwise for a single cut level $D \le N$. Consequently the
weakenings of a fixed theory form a *chain* of length at most $N+1$. We also prove that
the tag-indexed criterion coincides, as a matter of pure arithmetic, with a
level-indexed *level-agreement* criterion, giving a second and independent derivation of
the inclusion theorem.

The second family consists of *valuated* finite-height theories $\mathcal{V}(V,N)$ and
in particular the *block theories* $\mathcal{B}(n,w)$, in which every atom is true
exactly at the worlds below a shift point $w$. All six GL closure conditions, Löb
included, are verified for these theories. We compute the reflection depth of
$\mathcal{B}(n,w)$ to be exactly $n - w$ while its provable iterated boxed falsa are
independent of $w$. Combined with the elementary syntactic bound "reflection depth $\le$
inconsistency height", valid for arbitrary proof systems, this yields the exact
realizability theorem: a consistent GL theory of inconsistency height $n$ and reflection
depth exactly $d$ exists **iff** $d \le n$. In particular the reflection depth is not a
function of the inconsistency spectrum, and depth-$1$ reflection is strictly stronger
than minimal soundness — an optimal separation, since the depth-$0$ rule is vacuous.
Finally we prove that the block family is *rigid*: both parameters are recoverable from
the theory, in sharp contrast to the massive redundancy of the ladder family.

**Keywords:** provability logic, GL, Löb's axiom, consistency statements, reflection
principles, Kripke semantics, truncation order, depth vector.

---

## 1. Introduction

### 1.1 Motivation

A formal theory that can arithmetize its own syntax can express statements about what it
proves. The canonical such statement is $\mathrm{Con} = \neg \Box \bot$: "I do not prove
a contradiction". Gödel's second incompleteness theorem, in its modal distillation
(Löb's axiom), says that self-trust cannot be had for free. But it says nothing about
*how much* self-trust a given theory has, nor about how the self-trust of one system
relates to that of another.

Once one adds several provability operators $\Box_0, \Box_1, \dots$ — one per *tag*,
i.e. per system under discussion — the natural objects are the *transfer* statements
$\mathrm{Con}_i \to \mathrm{Con}_j$ and their iterated relatives. Earlier work in this
line established that for the tag-sensitive finite-height theories introduced below,
provable transfer is governed exactly by the truncated heights, that the resulting
transfer relation is always a total preorder, and that every total preorder without long
strict chains arises this way. What remained open was the *inclusion* order: given two
such theories, when is one a subtheory of the other? A natural conjecture was recorded,
and this paper settles it — negatively — and replaces it with an exact criterion.

A second, independent question concerns the relationship between two ways of measuring
how "sound" a theory is about its own provability. One may look at the least depth at
which the theory concedes its own inconsistency, or at the complexity threshold up to
which its provability claims are actually correct. In the simplest models these two
numbers coincide, and one might suspect a theorem. We show the coincidence is an
artefact and compute the whole spectrum of realizable pairs.

### 1.2 Summary of contributions

1. **Refutation of the order-preservation conjecture** for the inclusion order on
   tag-sensitive ladder theories, with an explicit counterexample at truncation level
   $N = 2$ and an explicit separating formula (Section 5).
2. **The exact inclusion criterion** (*depth domination*), and its reformulation as the
   statement that weakenings are exactly truncations (Sections 3–4, 6).
3. **Structural consequences**: the weakenings of a fixed theory form a chain; there are
   at most $N + 1$ of them; mutual inclusion is equality (Section 6).
4. **The exact threshold** of the refuted conjecture: it is correct precisely for
   $N \le 1$ (Section 7).
5. **A purely arithmetic bridge** identifying the tag-indexed criterion with a
   level-indexed criterion, hence an independent second proof of the inclusion theorem
   (Section 8).
6. **The reflection-depth spectrum**: valuated GL theories, block valuations, locality,
   depth probes, and the exact reflection depth $n - w$ (Sections 9–11).
7. **Exact realizability of the pair (height, reflection depth)**, the independence of
   the two invariants, and the optimal separation of depth-$1$ reflection from minimal
   soundness (Section 11).
8. **Rigidity of the block family**, a structural contrast with the redundancy of the
   ladder family (Section 12).

---

## 2. The setting

### 2.1 Language

Fix a countable supply of *tags* $i \in \mathbb{N}$ and of *atoms* $p \in \mathbb{N}$.
The set of **formulas** is generated by

$$a \; ::= \; \bot \;\mid\; p \;\mid\; a \to a \;\mid\; \Box_i a .$$

Abbreviations: $\neg a := a \to \bot$, and $\mathrm{Con}_i := \neg \Box_i \bot$. The
**iterated box** is defined by $\Box_i^0 a = a$ and $\Box_i^{k+1} a = \Box_i (\Box_i^k a)$.
The **box depth** $\mathrm{bd}(a)$ is $0$ for $\bot$ and for atoms,
$\max(\mathrm{bd}(a),\mathrm{bd}(b))$ for $a \to b$, and $1 + \mathrm{bd}(a)$ for
$\Box_i a$. Thus $\mathrm{bd}(\Box_i^k a) = k + \mathrm{bd}(a)$.

### 2.2 Theories

A **theory** here is a proof system $S$ over the formulas, with a provability predicate
$\vdash_S$; we write $\mathrm{Prov}_S(a)$ or $\vdash_S a$. $S$ is **consistent** if
$\nvdash_S \bot$. $S$ is a **GL theory at tag $i$** if it is closed under

* modus ponens: $\vdash_S a \to b$ and $\vdash_S a$ imply $\vdash_S b$;
* necessitation: $\vdash_S a$ implies $\vdash_S \Box_i a$;
* all propositional tautologies;
* distribution: $\vdash_S \Box_i(a \to b) \to (\Box_i a \to \Box_i b)$;
* transitivity: $\vdash_S \Box_i a \to \Box_i \Box_i a$;
* Löb: $\vdash_S \Box_i(\Box_i a \to a) \to \Box_i a$.

Two soundness notions are relevant.

**Definition 2.1 (Minimal soundness).** $S$ is *minimally sound at $i$* if
$\nvdash_S \Box_i \bot$.

**Definition 2.2 (Depth-restricted reflection).** For $d \in \mathbb{N}$, $S$ satisfies
*depth-$d$ reflection at $i$*, written $\mathrm{DR}_d^i(S)$, if for every formula $a$
with $\mathrm{bd}(a) < d$,
$$\vdash_S \Box_i a \;\Longrightarrow\; \vdash_S a .$$
The **reflection depth** of $S$ at $i$ is the largest $d$ with $\mathrm{DR}_d^i(S)$ (or
$\infty$). The rule is monotone in $d$: $\mathrm{DR}_d^i(S)$ and $d' \le d$ imply
$\mathrm{DR}_{d'}^i(S)$. $\mathrm{DR}_0^i(S)$ holds vacuously.

**Definition 2.3 (Inconsistency height).** $S$ has *inconsistency height $n$ at $i$* if
$\vdash_S \Box_i^k \bot$ exactly for $k > n$.

### 2.3 Two Kripke-style semantics on the ladder $(\mathbb{N},<)$

Both families of theories live on the frame whose worlds are natural numbers, world $m$
accessing exactly the worlds $n < m$. This frame is transitive and conversely
well-founded, which is what makes Löb's axiom valid.

**Tag-sensitive satisfaction.** Given a *height function* $c : \mathbb{N} \to \mathbb{N}$,
define $\models^c_m a$ by recursion:

* $\not\models^c_m \bot$; atoms are true everywhere;
* $\models^c_m a \to b$ iff ($\models^c_m a$ implies $\models^c_m b$);
* $\models^c_m \Box_i a$ iff ($m \le c(i)$ implies $\models^c_n a$ for all $n < m$).

Thus the accessibility relation of tag $i$ is *switched off* at all worlds $m > c(i)$: at
such a world tag $i$ is **dead** and $\Box_i$ is vacuously true. In particular
$$\models^c_m \Box_i \bot \iff m = 0 \ \text{ or } \ c(i) < m, \tag{2.1}$$
and more generally
$$\models^c_m \Box_i^k \bot \iff k \ge 1 \ \text{ and } \ (m < k \ \text{ or } \ c(i) < m). \tag{2.2}$$

**Definition 2.4 (Ladder theory).** For $N \in \mathbb{N}$, let $\mathcal{L}(c,N)$ be the
theory whose theorems are the formulas true at every world $m \le N$:
$$\vdash_{\mathcal{L}(c,N)} a \iff \forall m \le N,\ \models^c_m a .$$

$\mathcal{L}(c,N)$ is consistent (at world $0$, $\bot$ fails) and is a GL theory at every
tag. From (2.2):

**Proposition 2.5 (Inconsistency spectrum of a ladder theory).**
$$\vdash_{\mathcal{L}(c,N)} \Box_i^k \bot \iff k \ge 1 \ \text{ and } \ \min(N, c(i)) < k .$$

**Definition 2.6 (Depth vector).** $d_c(i) := \min\bigl(N, c(i)\bigr)$ (the truncation
level $N$ is suppressed from the notation when clear). By Proposition 2.5 this is exactly
the *depth of provable inconsistency* of tag $i$ in $\mathcal{L}(c,N)$. Note
$0 \le d_c(i) \le N$.

Two facts are inherited from earlier work and used freely.

**Proposition 2.7 (Completeness of the depth vector).** If $\min(N, c(i)) = \min(N, c'(i))$
for all $i$, then $\mathcal{L}(c,N)$ and $\mathcal{L}(c',N)$ have exactly the same
theorems. Conversely, if the depth vectors differ, so do the theories.

**Valuated satisfaction.** Given a valuation $V : \mathbb{N} \times \mathbb{N} \to \{0,1\}$
(world, atom), define $\models^V_m a$ by: $\bot$ false everywhere;
$\models^V_m p$ iff $V(m,p) = 1$; the usual clause for $\to$; and
$$\models^V_m \Box_i a \iff \models^V_n a \text{ for all } n < m,$$
with no tag sensitivity. For $N \in \mathbb{N}$ let $\mathcal{V}(V,N)$ be the theory of
formulas true at all worlds $m \le N$. Taking $V \equiv 1$ recovers the tag-blind ladder.

---

## 3. Depth domination

Throughout Sections 3–8 we fix a truncation level $N$ and write $d_c(i) = \min(N,c(i))$.

**Definition 3.1 (Inclusion).** $\mathcal{L}(c',N) \subseteq \mathcal{L}(c,N)$, written
$\mathrm{Incl}(c,c',N)$, means: every theorem of $\mathcal{L}(c',N)$ is a theorem of
$\mathcal{L}(c,N)$. (The *weaker* theory is written first.)

**Definition 3.2 (Depth domination).** $\mathrm{DD}(c,c',N)$ holds iff

* **(D1)** $d_c(i) \le d_{c'}(i)$ for all tags $i$, and
* **(D2)** for all tags $i,j$: if $d_c(i) < d_{c'}(i)$ then $d_c(j) \le d_c(i)$.

In words: *depths may only increase, and a depth may increase strictly only at a tag
whose depth is already maximal.*

**Definition 3.3 (The conjectured criterion).** $\mathrm{CC}(c,c',N)$ holds iff

* **(C1)** $d_c(i) \le d_{c'}(i)$ for all $i$ (= D1), and
* **(C2)** for all $i,j$: $d_{c'}(i) \le d_{c'}(j)$ implies $d_c(i) \le d_c(j)$.

The **Main Theorem** of the first half of the paper is:

> **Theorem 3.4 (Exact inclusion criterion).** For all $c, c' : \mathbb{N} \to \mathbb{N}$
> and all $N$,
> $$\mathrm{Incl}(c,c',N) \iff \mathrm{DD}(c,c',N).$$

Sections 4 and 5 give the two directions.

---

## 4. Sufficiency

Two semantic lemmas do the work. The first says that satisfaction depends on the height
function only through the *aliveness flags* $\;n \le c(i)$ at the relevant levels.

**Lemma 4.1 (Congruence below a level).** Let $M \in \mathbb{N}$ and suppose that for all
tags $i$ and all $n \le M$,
$$n \le c(i) \iff n \le c'(i).$$
Then for every formula $a$ and every $m \le M$: $\models^c_m a \iff \models^{c'}_m a$.

*Proof sketch.* Induction on $a$. The atomic and implicational cases are immediate. For
$\Box_i a$ at a world $m \le M$: the flag hypothesis at level $m$ gives
$m \le c(i) \iff m \le c'(i)$, so the two clauses trigger together, and the induction
hypothesis at the worlds $n < m \le M$ transports the inner satisfaction. $\square$

The second lemma isolates the worlds where nothing at all is accessible.

**Definition 4.2 (Dead world).** A world $m$ is *dead* for $c$ if $m = 0$ or $c(i) < m$
for every tag $i$.

**Lemma 4.3 (Dead worlds are modally indistinguishable).** At a dead world every box is
vacuously true; consequently, if $m$ is dead for $c$ and $m'$ is dead for $c'$, then for
every formula $a$: $\models^c_m a \iff \models^{c'}_{m'} a$.

*Proof sketch.* At a dead world, either $m = 0$ (no accessible worlds) or every tag is
dead, so in both cases $\models_m \Box_i a$ holds for every $i, a$. Induction on $a$ then
never needs to descend: atoms are true at every world, $\bot$ false at every world, and
boxes true at both worlds. $\square$

**Theorem 4.4 (Depth domination implies inclusion).** $\mathrm{DD}(c,c',N)$ implies
$\mathrm{Incl}(c,c',N)$.

*Proof sketch.* Let $a$ be a theorem of $\mathcal{L}(c',N)$ and let $m \le N$; we must
show $\models^c_m a$. Two cases.

*Case 1: $m$ is dead for $c$.* World $0$ is dead for $c'$, and $a$ holds there since $a$
is a theorem of $\mathcal{L}(c',N)$. By Lemma 4.3, $\models^c_m a$.

*Case 2: $m$ is alive*, i.e. $m \ne 0$ and $m \le c(i_0)$ for some tag $i_0$. We claim
the flag hypothesis of Lemma 4.1 holds at level $M = m$. The implication
"$n \le c(i) \Rightarrow n \le c'(i)$" for $n \le m \le N$ follows from (D1), since
$n \le c(i)$ and $n \le N$ give $n \le d_c(i) \le d_{c'}(i) \le c'(i)$. Conversely suppose
$n \le c'(i)$ but $n > c(i)$ for some $n \le m$. Then $d_c(i) < n \le d_{c'}(i)$, so the
depth of $i$ strictly increases, and (D2) applied to the pair $(i, i_0)$ gives
$d_c(i_0) \le d_c(i) < n \le m$. But $i_0$ is alive at $m \le N$, so
$d_c(i_0) = \min(N, c(i_0)) \ge m$ — a contradiction. Lemma 4.1 now yields
$\models^c_m a \iff \models^{c'}_m a$, and the right-hand side holds because $a$ is a
theorem of $\mathcal{L}(c',N)$ and $m \le N$. $\square$

The proof explains the shape of (D2): the only way an inclusion can fail is that some
*live* world of the $c$-model is not reproduced by the $c'$-model, and (D2) says exactly
that no live world sees a difference between the two aliveness patterns.

---

## 5. Necessity, and the refutation of the conjecture

### 5.1 Depths can only increase

**Lemma 5.1.** $\mathrm{Incl}(c,c',N)$ implies (D1).

*Proof sketch.* Suppose $d_{c'}(i) < d_c(i)$. By Proposition 2.5,
$\Box_i^{\,d_{c'}(i)+1}\bot$ is a theorem of $\mathcal{L}(c',N)$, hence of
$\mathcal{L}(c,N)$, hence $d_c(i) < d_{c'}(i)+1$, i.e. $d_c(i) \le d_{c'}(i)$ —
contradiction. $\square$

### 5.2 The order witness

The whole subtlety of the problem is concentrated in one formula.

**Definition 5.2 (Order witness).** For tags $i,j$ and $m \ge 1$,
$$W(i,j,m) \;:=\; \Box_i \bot \;\to\; \bigl(\neg \Box_j^m \bot \;\to\; \neg \Box_j^{m+1}\bot\bigr).$$

Its intended reading, via (2.2), is: *if tag $i$ is dead here, then tag $j$ does not have
depth exactly $m$ here.*

**Lemma 5.3 (When the witness is a theorem).** If $1 \le m \le c(i)$ then
$W(i,j,m)$ is a theorem of $\mathcal{L}(c,N)$ for every $N$ and every $j$.

*Proof sketch.* Let $w$ be any world with $\models^c_w \Box_i \bot$,
$\not\models^c_w \Box_j^m \bot$ and $\models^c_w \Box_j^{m+1}\bot$; we derive a
contradiction. By (2.2) the middle condition gives $\neg(w < m \vee c(j) < w)$, i.e.
$w \ge m$ and $w \le c(j)$; the last gives $w < m+1$ or $c(j) < w$, so $w = m$. And by
(2.1) the first gives $w = 0$ or $c(i) < w$, i.e. $m = 0$ or $c(i) < m$, both excluded by
$1 \le m \le c(i)$. $\square$

**Lemma 5.4 (When the witness fails).** If $1 \le m \le N$, $c(i) < m$ and $m \le c(j)$,
then $W(i,j,m)$ is *not* a theorem of $\mathcal{L}(c,N)$: it is refuted at the world $m$.

*Proof sketch.* At $w = m$: $\models \Box_i \bot$ by (2.1) since $c(i) < m$;
$\not\models \Box_j^m \bot$ by (2.2) since $m \not< m$ and $c(j) \ge m$; and
$\models \Box_j^{m+1}\bot$ by (2.2) since $m < m+1$. So the antecedents hold and the
conclusion fails, and $m \le N$ is a world of the model. $\square$

The world $m$ of Lemma 5.4 is the *witness world*: a world at which tag $i$ is already
dead while tag $j$ is alive with depth exactly $m$.

### 5.3 Strict increases occur only at the top

**Lemma 5.5.** $\mathrm{Incl}(c,c',N)$ implies (D2).

*Proof sketch.* Suppose $d_c(i) < d_{c'}(i)$ but $d_c(i) < d_c(j)$ for some $j$. Put
$m := d_c(i) + 1$. Then $m \le N$ (as $d_c(i) < d_{c'}(i) \le N$), $c(i) < m$,
$m \le c(j)$ (since $d_c(j) \ge m$) and $m \le c'(i)$ (since $d_{c'}(i) \ge m$). By Lemma
5.3, $W(i,j,m)$ is a theorem of $\mathcal{L}(c',N)$; by inclusion it is a theorem of
$\mathcal{L}(c,N)$; by Lemma 5.4 it is not. $\square$

Theorem 3.4 follows from Theorem 4.4 and Lemmas 5.1 and 5.5.

**Corollary 5.6 (The conjectured criterion is necessary).** $\mathrm{Incl}(c,c',N)$
implies $\mathrm{CC}(c,c',N)$.

*Proof sketch.* (C1) is (D1). For (C2), assume $d_{c'}(i) \le d_{c'}(j)$. If
$d_c(j) = d_{c'}(j)$ then $d_c(i) \le d_{c'}(i) \le d_{c'}(j) = d_c(j)$. Otherwise
$d_c(j) < d_{c'}(j)$, and (D2) applied to the pair $(j,i)$ gives $d_c(i) \le d_c(j)$.
$\square$

### 5.4 The counterexample

**Definition 5.7.** Let $N = 2$ and
$$c := (0,1,1,1,\dots), \qquad c' := (1,2,2,2,\dots),$$
i.e. $c(0) = 0$, $c(k) = 1$ for $k \ge 1$; $c'(0) = 1$, $c'(k) = 2$ for $k \ge 1$. Then
$d_c = (0,1,1,\dots)$ and $d_{c'} = (1,2,2,\dots)$.

**Proposition 5.8.** $\mathrm{CC}(c,c',2)$ holds.

*Proof sketch.* (C1): $0 \le 1$ and $1 \le 2$. (C2): $d_{c'}$ and $d_c$ induce the same
ordering of the tags — tag $0$ strictly below all others in both — so the implication is
immediate by case analysis. $\square$

**Proposition 5.9 (Separation).** The formula
$$W(0,1,1) \;=\; \Box_0 \bot \to \bigl(\neg \Box_1 \bot \to \neg \Box_1 \Box_1 \bot\bigr)$$
is a theorem of $\mathcal{L}(c',2)$ and is not a theorem of $\mathcal{L}(c,2)$.

*Proof sketch.* Lemma 5.3 with $m = 1 \le 1 = c'(0)$ gives the first half. Lemma 5.4 with
$m = 1 \le 2 = N$, $c(0) = 0 < 1$ and $1 \le c(1) = 1$ gives the second: $W(0,1,1)$ is
refuted at world $1$ of the $c$-model. $\square$

**Theorem 5.10 (The order-preservation conjecture is false).** There exist $c, c', N$
with $\mathrm{CC}(c,c',N)$ and $\neg\,\mathrm{Incl}(c,c',N)$; hence the conjectured
criterion is strictly weaker than inclusion.

The mechanism is worth stating separately. Raising the depth of tag $0$ from $0$ to $1$
*deletes* the witness world $1$ of the old model — the unique world at which tag $0$ is
dead while tag $1$ is alive at depth $1$ — and no world of the new model reproduces that
configuration. Conditions (C1) and (C2) are blind to this, because they only compare
*numbers*; (D2) sees it, because it compares each raised tag against the *maximum* depth,
which is precisely the height of the tallest live world.

---

## 6. Weakenings are truncations

The criterion admits a formulation with no quantifier alternation at all, which reveals
the global shape of the inclusion order.

**Definition 6.1 (Top depth).** $T(c,N) := \max_i d_c(i)$, the largest depth attained.
(The maximum exists: the depths are bounded by $N$, so $T(c,N)$ may be defined as the
greatest $k \le N$ such that some tag has $d_c(i) \ge k$; this is well defined
unconditionally, without assuming the maximum is attained by a *named* tag, and it *is*
attained.)

**Theorem 6.2 (Truncation theorem).**
$$\mathrm{Incl}(c,c',N) \iff \exists D \le N \ \forall i,\ d_c(i) = \min\bigl(D, d_{c'}(i)\bigr).$$

*Proof sketch.* ($\Rightarrow$) Take $D := T(c,N)$ and let $i_0$ attain it. For a tag
$i$: if $d_c(i) = d_{c'}(i)$ then, since $d_c(i) \le D$, we get
$\min(D, d_{c'}(i)) = d_c(i)$. If $d_c(i) < d_{c'}(i)$, then (D2) applied to $(i, i_0)$
gives $D = d_c(i_0) \le d_c(i)$, so $d_c(i) = D \le d_{c'}(i)$ and again
$\min(D, d_{c'}(i)) = d_c(i)$.
($\Leftarrow$) Given such a $D$: (D1) is clear from $\min(D,x) \le x$. For (D2), a strict
increase at $i$ forces $\min(D, d_{c'}(i)) < d_{c'}(i)$, hence $d_c(i) = D$, which is an
upper bound for every $d_c(j) = \min(D, d_{c'}(j))$. $\square$

Thus the *only* way to weaken a theory in this family is to choose one cut level $D$ and
truncate the entire depth vector at it. The two structural corollaries are immediate.

**Corollary 6.3 (Chain).** If $\mathrm{Incl}(c_1,c',N)$ and $\mathrm{Incl}(c_2,c',N)$
then $\mathrm{Incl}(c_1,c_2,N)$ or $\mathrm{Incl}(c_2,c_1,N)$: the weakenings of a fixed
theory are linearly ordered by inclusion.

*Proof sketch.* Write $d_{c_1} = \min(D_1, d_{c'})$ and $d_{c_2} = \min(D_2, d_{c'})$. If
$D_1 \le D_2$ then $d_{c_1} = \min(D_1, d_{c_2})$ pointwise, which is the truncation
condition for $\mathrm{Incl}(c_1,c_2,N)$; symmetrically otherwise. $\square$

**Corollary 6.4 (Pigeonhole).** Let $f_0, \dots, f_{N+1}$ be $N+2$ height functions with
$\mathrm{Incl}(f_a, c', N)$ for every $a$. Then two of them generate the same theory:
there are $a \ne b$ with $\vdash_{\mathcal{L}(f_a,N)} x \iff \vdash_{\mathcal{L}(f_b,N)} x$
for every formula $x$.

*Proof sketch.* Each $f_a$ has a cut level $D_a \in \{0,\dots,N\}$; there are $N+2$
indices and $N+1$ possible cut levels, so $D_a = D_b$ for some $a \ne b$, whence the
depth vectors coincide and Proposition 2.7 applies. $\square$

Further order-theoretic corollaries of Theorem 3.4:

* **Reflexivity and transitivity.** $\mathrm{DD}(c,c,N)$ always holds, and
  $\mathrm{DD}$ is transitive. Transitivity is entirely opaque on the arithmetic side —
  the naive composition of two (D2) conditions does not obviously give a (D2)
  condition — but is immediate once (D2) is identified with inclusion of theories, which
  is transitive for trivial reasons.
* **Antisymmetry.** If $\mathrm{Incl}(c,c',N)$ and $\mathrm{Incl}(c',c,N)$ then
  $d_c = d_{c'}$, hence by Proposition 2.7 the two theories are literally equal.
* **Constant depth is minimal.** If $d_c$ is constant equal to $\delta$ and
  $\delta \le d_{c'}(i)$ for all $i$, then $\mathrm{Incl}(c,c',N)$. This is the extreme
  case of the criterion, and it shows that the failure of the pointwise order is a
  genuinely *relational* phenomenon: constant profiles cause no trouble at all; only
  non-constant ones do.

---

## 7. The exact threshold of the refuted conjecture

The conjecture was not wrong everywhere. It is exactly right in low heights.

**Lemma 7.1.** If $N \le 1$ then $\mathrm{CC}(c,c',N)$ implies $\mathrm{DD}(c,c',N)$.

*Proof sketch.* All depths lie in $\{0,\dots,N\} \subseteq \{0,1\}$. Suppose
$d_c(i) < d_{c'}(i)$ and, for contradiction, $d_c(i) < d_c(j)$ for some $j$. Then
$d_c(i) = 0$, $d_c(j) = 1$, $N = 1$, and $d_{c'}(i) = 1$, which is the maximum, so
$d_{c'}(j) \le d_{c'}(i)$. Applying (C2) to the pair $(j,i)$ gives
$d_c(j) \le d_c(i) = 0$, contradicting $d_c(j) = 1$. $\square$

**Lemma 7.2.** For every $N \ge 2$ the pair $(c,c')$ of Definition 5.7 satisfies
$\mathrm{CC}(c,c',N)$; and for every $N \ge 1$ the formula $W(0,1,1)$ is a theorem of
$\mathcal{L}(c',N)$ but not of $\mathcal{L}(c,N)$.

*Proof sketch.* For $N \ge 2$ the depth vectors are still $(0,1,1,\dots)$ and
$(1,2,2,\dots)$, so Proposition 5.8 applies verbatim. The separation is Lemmas 5.3 and
5.4 with $m = 1$. $\square$

**Theorem 7.3 (Exact threshold).** For every $N$,
$$\bigl(\forall c,c':\ \mathrm{CC}(c,c',N) \Rightarrow \mathrm{Incl}(c,c',N)\bigr) \iff N \le 1 .$$

So $N = 2$ is the least truncation level at which the conjecture fails; below it, the
conjectured criterion *is* a correct description of inclusion. (Note the second clause of
Lemma 7.2: the separating formula itself works from $N = 1$ on; what fails at $N = 1$ is
the *conjectured criterion* for that pair, since at $N = 1$ the depth vectors truncate to
$(0,1,1,\dots)$ and $(1,1,1,\dots)$, which violate (C2).)

---

## 8. A second route: level agreement

There is a different, *level-indexed* way to phrase the criterion, and comparing the two
is instructive.

**Definition 8.1 (Level agreement).** $\mathrm{LA}(c,c',N)$ holds iff for every level
$m \le N$ that is *alive* for $c$ (i.e. $m \le c(i)$ for some $i$), and every tag $j$,
$$\min\bigl(m, c(j)\bigr) = \min\bigl(m, c'(j)\bigr).$$

**Theorem 8.2 (Bridge).** $\mathrm{LA}(c,c',N) \iff \mathrm{DD}(c,c',N)$, and the
equivalence is a purely arithmetic fact about truncations — no modal semantics is
involved.

*Proof sketch.* ($\Rightarrow$) The level $d_c(i)$ is itself alive for $c$ whenever it is
positive, and evaluating level agreement there forces $d_c(i) \le d_{c'}(i)$, giving
(D1). For (D2): if $d_c(i) < d_{c'}(i)$ and some $j$ has $d_c(j) > d_c(i)$, then the level
$m := d_c(i)+1 \le N$ is alive for $c$ (witnessed by $j$), and at that level
$\min(m,c(i)) = c(i) = d_c(i) < m = \min(m, c'(i))$, contradicting agreement.
($\Leftarrow$) Let $m \le N$ be alive for $c$, witnessed by $i_0$, and let $j$ be a tag.
If $d_c(j) = d_{c'}(j)$ the two truncations agree. If $d_c(j) < d_{c'}(j)$ then by (D2)
$d_c(i_0) \le d_c(j)$; since $i_0$ is alive at $m$ we get $m \le d_c(i_0) \le d_c(j)$, so
both $c(j)$ and $c'(j)$ are $\ge m$ and both truncations equal $m$. $\square$

Combining Theorem 8.2 with the level-agreement form of the inclusion theorem gives a
second, independent derivation of Theorem 3.4 — a useful consistency check, since the two
proofs go through different intermediate objects (levels vs. tags).

---

## 9. Valuated finite-height theories

We now turn to the second invariant. The tag-blind ladder makes every atom true at every
world; consequently a box-free formula has the same truth value at all worlds, and the
only sentences that can distinguish worlds are those built from $\bot$. This is precisely
why, in that family, the inconsistency height and the reflection depth coincide. Adding a
genuine valuation removes the artefact.

Recall $\mathcal{V}(V,N)$: the theory of the formulas true at every world $m \le N$ under
the valuated satisfaction $\models^V$.

**Theorem 9.1.** For every valuation $V$, every $N$ and every tag $i$: $\mathcal{V}(V,N)$
is consistent and is a GL theory at $i$.

*Proof sketch.* Consistency: $\bot$ fails at world $0 \le N$. Closure under modus ponens
and necessitation, and validity of the tautologies and of the distribution axiom, are
routine pointwise verifications. Transitivity holds because $(\mathbb{N},<)$ is
transitive. Löb's axiom holds because $(\mathbb{N},<)$ is conversely well-founded: if
$\models^V_n \Box_i a \to a$ for all $n < m$, then by strong induction on $n < m$ one gets
$\models^V_n a$ for all $n < m$, i.e. $\models^V_m \Box_i a$. $\square$

**Theorem 9.2 (Valuation-independence of the inconsistency spectrum).**
$$\vdash_{\mathcal{V}(V,N)} \Box_i^k \bot \iff N < k .$$

*Proof sketch.* $\bot$ contains no atoms, so $\models^V_m \Box_i^k \bot \iff m < k$ for
any $V$, by induction on $k$. Requiring this at all $m \le N$ is exactly $N < k$.
$\square$

So the inconsistency height of $\mathcal{V}(V,N)$ is $N$, whatever $V$ is. The valuation
is invisible to that ruler. It is *not* invisible to the reflection ruler.

---

## 10. Block valuations, locality, and depth probes

**Definition 10.1 (Block valuation).** For a *shift point* $w \in \mathbb{N}$, let
$$V_w(m,p) = 1 \iff m < w,$$
i.e. every atom is true exactly at the worlds $0,\dots,w-1$. Note $V_0$ makes every atom
false everywhere, so under $V_0$ the atoms behave like $\bot$; this is the degenerate
case.

**Definition 10.2 (Block theory).** $\mathcal{B}(n,w) := \mathcal{V}(V_w, n)$.

By Theorem 9.1, $\mathcal{B}(n,w)$ is a consistent GL theory; by Theorem 9.2 its provable
iterated boxed falsa are exactly the $\Box_i^k \bot$ with $k > n$, for every $w$.

**Lemma 10.3 (Locality above the block).** For every formula $a$ with
$\mathrm{bd}(a) \le k$ and all worlds $m, m'$ with $w + k \le m$ and $w + k \le m'$,
$$\models^{V_w}_m a \iff \models^{V_w}_{m'} a .$$

*Proof sketch.* Induction on $a$. Atoms: both $m$ and $m'$ are $\ge w$, so all atoms are
false at both. Implication: componentwise, using $\mathrm{bd}$ of the parts. Box
$\Box_i b$ with $\mathrm{bd}(b) \le k-1$: suppose $b$ holds at all worlds $< m$; to see
it holds at all $j < m'$, split on whether $j \ge w + (k-1)$. If yes, then $b$ (of box
depth $\le k-1$) cannot distinguish $j$ from $m-1 \ge w+(k-1)$, and $b$ holds at $m-1$;
if no, then $j < w + k - 1 \le m$, so $b$ holds at $j$ directly. $\square$

The lemma expresses the intuition that a formula of box depth $k$ can look down at most
$k$ rungs of the ladder, and above the block the valuation is constant.

**Definition 10.4 (Depth probe).** $P(i,k) := \Box_i^k\, p_0$, of box depth exactly $k$.

**Lemma 10.5 (Truth table of the probes).** Under $V_w$,
$$\models^{V_w}_m P(i,k) \iff m < w + k .$$
Consequently $\vdash_{\mathcal{B}(n,w)} P(i,k) \iff n < w + k$.

*Proof sketch.* Induction on $k$. For $k = 0$ this is the definition of $V_w$. For
$k+1$: $\models_m \Box_i P(i,k)$ iff $P(i,k)$ holds at all $j < m$ iff (by IH) $j < w+k$
for all $j < m$ iff $m \le w+k$ iff $m < w + (k+1)$. The provability statement follows
because the worlds of $\mathcal{B}(n,w)$ are $0,\dots,n$ and truth of the probe is
downward closed. $\square$

The probe is a *shifted falsum*: for $w = 0$ it behaves exactly like $\Box_i^k \bot$, and
increasing $w$ moves the point at which truth stops from the root up to world $w$.

---

## 11. The reflection-depth spectrum

**Theorem 11.1 (Reflection holds below the gap).** For all $n, w, i$:
$\mathrm{DR}^i_{\,n-w}\bigl(\mathcal{B}(n,w)\bigr)$.

*Proof sketch.* Let $\mathrm{bd}(a) < n - w$ and suppose $\Box_i a$ is a theorem, i.e.
holds at every world $\le n$; in particular at $n$, so $a$ holds at all worlds $< n$. It
remains to check $a$ at $n$ itself. Both $n$ and $n-1$ are $\ge w + \mathrm{bd}(a)$ (as
$\mathrm{bd}(a) \le n - w - 1$), so by Lemma 10.3 $a$ has the same value at $n$ and at
$n-1$, where it holds. $\square$

**Theorem 11.2 (Reflection fails one step higher).** For $w \le n$ and any $i$,
$\mathrm{DR}^i_{\,n-w+1}\bigl(\mathcal{B}(n,w)\bigr)$ fails, witnessed by the probe
$P(i, n-w)$ of box depth exactly $n-w$.

*Proof sketch.* $\Box_i P(i,n-w) = P(i, n-w+1)$ is provable iff $n < w + (n-w) + 1$,
which is true; while $P(i,n-w)$ is provable iff $n < w + (n - w) = n$, which is false.
$\square$

**Theorem 11.3 (Exact reflection depth).** For $w \le n$ and any $d, i$,
$$\mathrm{DR}^i_d\bigl(\mathcal{B}(n,w)\bigr) \iff d \le n - w .$$

The next result requires no semantics at all and holds for arbitrary proof systems.

**Theorem 11.4 (Height bounds depth).** If $\vdash_S \Box_i^{n+1}\bot$ and
$\nvdash_S \Box_i^{n}\bot$, then $\mathrm{DR}^i_{n+1}(S)$ fails.

*Proof sketch.* $\mathrm{bd}(\Box_i^n\bot) = n < n+1$, and $\Box_i(\Box_i^n \bot)$ is
literally $\Box_i^{n+1}\bot$, which is provable; so the depth-$(n+1)$ rule would yield
$\vdash_S \Box_i^n \bot$. $\square$

**Theorem 11.5 (Exact realizability of the pair).** For all $n, d, i$: there exists a
consistent GL theory $S$ at tag $i$ with

* $\vdash_S \Box_i^k\bot$ exactly for $k > n$ (inconsistency height $n$), and
* $\mathrm{DR}^i_{d'}(S)$ exactly for $d' \le d$ (reflection depth exactly $d$)

**if and only if** $d \le n$.

*Proof sketch.* Necessity is Theorem 11.4: if $d > n$ then $S$ satisfies
$\mathrm{DR}^i_{n+1}$ while proving $\Box_i^{n+1}\bot$ and refuting $\Box_i^n\bot$.
Sufficiency is $S := \mathcal{B}(n, n-d)$, using Theorems 9.1, 9.2 and 11.3. $\square$

So the two invariants are constrained by the single inequality $d \le n$ and by nothing
else; the whole triangle $\{(n,d) : d \le n\}$ is realized. The tag-blind ladders occupy
only its diagonal.

**Theorem 11.6 (Reflection depth is not determined by the inconsistency spectrum).** For
every $n \ge 1$ and every tag $i$, the theories $\mathcal{B}(n,0)$ and $\mathcal{B}(n,n)$
prove exactly the same formulas $\Box_i^k\bot$ (namely those with $k > n$), yet
$\mathrm{DR}^i_n(\mathcal{B}(n,0))$ holds while $\mathrm{DR}^i_1(\mathcal{B}(n,n))$ fails.

Hence no function of the provable iterated boxed falsa can compute the reflection depth.

**Theorem 11.7 (Optimal separation from minimal soundness).** For every tag $i$, the
theory $\mathcal{B}(1,1)$ — two worlds $0,1$; atoms true at the root only — is
consistent, is a GL theory at $i$, and is minimally sound at $i$ (it does not prove
$\Box_i \bot$), yet it proves $\Box_i p_0$ and refutes $p_0$, so
$\mathrm{DR}^i_1(\mathcal{B}(1,1))$ fails.

*Proof sketch.* Minimal soundness: $\Box_i \bot = \Box_i^1\bot$ is provable iff $1 > 1$,
false. $\Box_i p_0 = P(i,1)$ is provable iff $1 < 1 + 1$, true; $p_0 = P(i,0)$ is provable
iff $1 < 1 + 0$, false. $\square$

**Corollary 11.8 (The chain of reflection rules starts strictly above minimal
soundness).** For consistent theories, depth-$1$ reflection implies minimal soundness,
and the converse fails. This is optimal, since the depth-$0$ rule is vacuous.

We stress that Theorem 11.7 cannot be witnessed inside the atom-trivial ladders: there, a
box-free formula is world-independent, so the depth-$1$ rule is automatic for consistent
theories. The valuation is not a convenience; it is what makes the bottom of the chain
visible.

---

## 12. Rigidity of the block family

The ladder family is massively redundant: infinitely many height functions give the same
theory, and Sections 3–7 classify that redundancy. The block family behaves in exactly
the opposite way.

**Definition 12.1 (World guard).** $G(i,j,a) := \Box_i^{j+1}\bot \to (\neg \Box_i^{j}\bot \to a)$.

**Lemma 12.2.** $\models^V_m G(i,j,a)$ iff ($m = j$ implies $\models^V_m a$). Hence
$$\vdash_{\mathcal{V}(V,N)} G(i,j,a) \iff \bigl(j \le N \Rightarrow \models^V_j a\bigr).$$

*Proof sketch.* Using $\models^V_m \Box_i^k\bot \iff m<k$, the two antecedents say
$m < j+1$ and $\neg(m<j)$, i.e. $m = j$. $\square$

World guards are formulas that pin the current world down to a prescribed distance from
the root and then assert something about it; they are the tag-free analogue of the order
witnesses of Section 5.

**Lemma 12.3.** If $j < w \iff j < w'$ for all $j \le m$, then $\models^{V_w}_m a$ iff
$\models^{V_{w'}}_m a$, for every formula $a$.

*Proof sketch.* Induction on $a$, the atomic case being the hypothesis at $j = m$ and the
box case using the hypothesis at the worlds below $m$. $\square$

**Theorem 12.4 (Inclusion criterion for the block family).** Every theorem of
$\mathcal{B}(n',w')$ is a theorem of $\mathcal{B}(n,w)$ if and only if
$$n \le n' \quad\text{and}\quad \forall j \le n,\ (j < w \iff j < w').$$

*Proof sketch.* ($\Leftarrow$) Lemma 12.3 world by world, together with $n \le n'$.
($\Rightarrow$) If $n' < n$ then $\Box_0^{n'+1}\bot$ is a theorem of the right-hand
theory but not the left-hand one, by Theorem 9.2. Given $n \le n'$ and a $j \le n$ with,
say, $j < w$ but $j \ge w'$, the guarded formula $G(0,j,\neg p_0)$ is a theorem of
$\mathcal{B}(n',w')$ (at world $j$ the atom is false there) but fails in
$\mathcal{B}(n,w)$ (at world $j$ the atom is true there); the symmetric case uses
$G(0,j,p_0)$. $\square$

**Theorem 12.5 (Rigidity).** $\mathcal{B}(n,w)$ and $\mathcal{B}(n',w')$ have the same
theorems iff $n = n'$ and $j < w \iff j < w'$ for all $j \le n$. In particular, if
$w, w' \le n$ and the theories coincide, then $w = w'$.

*Proof sketch.* Apply Theorem 12.4 in both directions for the first claim. For the
second: if $w < w'$, instantiating the valuation-agreement condition at $j = w \le n$
gives $w < w \iff w < w'$, i.e. false $\iff$ true. $\square$

**Corollary 12.6.** For each height $n$, the $n+1$ block theories $\mathcal{B}(n,w)$ with
$0 \le w \le n$ are pairwise distinct consistent GL theories, all with the same
inconsistency spectrum, and they are classified by their reflection depth $n - w$, which
takes each value in $\{0,1,\dots,n\}$ exactly once.

So a fixed inconsistency height supports a *scale* of $n+1$ pairwise distinct theories,
linearly ordered by their reflection depth, and this scale is invisible to the boxed-falsa
ruler.

---

## 13. Algorithms

All the invariants above are computable for finitely presented data, and the proofs are
constructive enough to read algorithms off them.

**Algorithm A (Depth-domination test).** Given $N$ and the depth vectors of $c, c'$
restricted to a finite tag set $I$ (all other tags being handled by a default value):

1. If $d_c(i) > d_{c'}(i)$ for some $i \in I$, reject.
2. Let $T := \max_{i \in I} d_c(i)$.
3. If there is $i \in I$ with $d_c(i) < d_{c'}(i)$ and $d_c(i) < T$, reject.
4. Otherwise accept.

This runs in $O(|I|)$ time and mirrors the criterion literally; by Theorem 6.2 an
equivalent test is: accept iff $d_c = \min(T, d_{c'})$ pointwise, which also *produces the
cut level* $T$.

**Algorithm B (Separating formula).** When Algorithm A rejects at step 3 with witnesses
$i$ (raised, non-maximal) and $j$ (deeper), output the order witness
$W(i,j,d_c(i)+1)$; by Lemmas 5.3 and 5.4 it is a theorem of the stronger theory and is
refuted at world $d_c(i)+1$ of the weaker model. When Algorithm A rejects at step 1 with
witness $i$, output $\Box_i^{\,d_{c'}(i)+1}\bot$. Thus every failure of inclusion comes
with an explicit certificate of bounded size.

**Algorithm C (Reflection depth by probing).** Given $n, w$ with $w \le n$, the reflection
depth of $\mathcal{B}(n,w)$ is $n - w$; the certificate of failure at depth $n-w+1$ is the
probe $\Box_i^{\,n-w} p_0$. Verifying a claimed reflection depth by brute force over all
formulas of box depth $< d$ is infeasible, but over any finite formula set it is a direct
check: evaluate at the worlds $0,\dots,n$, and test the rule.

---

## 14. Discussion

### 14.1 Why the conjecture failed

The conjectured criterion was phrased in the currency of *numbers*: the sizes of the
depths and their relative order. The truth is phrased in the currency of *worlds*: which
combinations "tag $i$ dead, tag $j$ alive at depth exactly $m$" are realized by an actual
world of the model. Conditions (C1) and (C2) are invariant under order-preserving
relabelings of the depth values; inclusion is not, because deleting a world is not an
order-theoretic operation on the depth vector. Once the order witnesses $W(i,j,m)$ are in
hand — formulas asserting the *non-existence* of such a configuration — the correct
condition writes itself.

It is also instructive that the conjecture is correct for $N \le 1$. With at most two
depth values there is essentially no room for a non-maximal tag to be raised without
disturbing the order, so (C2) accidentally implies (D2). The first genuine
counterexample needs three depth values, i.e. $N = 2$.

### 14.2 Redundancy versus rigidity

The two families exhibit opposite behaviour, and the contrast is not accidental. The
ladder family varies its *accessibility* structure while keeping the valuation trivial;
accessibility is only visible through the boxed falsa, and those see only truncated
heights, hence the collapse of an infinite-dimensional parameter space onto finitely many
theories with a one-parameter inclusion order. The block family keeps accessibility fixed
and varies the *valuation*; a valuation is visible at each individual world through the
world guards, hence full rigidity. A common refinement — tag-sensitive accessibility
together with a nontrivial valuation — would presumably interpolate, and its
classification is the natural next problem.

### 14.3 Interpretation

Consistency statements are the currency in which one formal system certifies another.
Theorem 6.2 says that within this family, strength profiles cannot be locally rearranged:
the only weakenings are uniform truncations. If a designer of a hierarchy of systems
wants a weaker configuration, no amount of selective adjustment of individual components
will do; the whole profile must be cut at one level.

Theorem 11.5 says that "how deep does the theory concede its own inconsistency" and "how
complex a provability claim can the theory be trusted on" are genuinely different
measurements, coupled by a single inequality. The temptation to read one off the other is
strong precisely because the most familiar examples sit on the diagonal.

---

## 15. Future work

1. **The common refinement.** Combine the tag-sensitive accessibility of the ladders with
   a nontrivial valuation, and classify the resulting theories. The natural conjecture is
   that per-tag inconsistency heights $d$ and per-tag reflection depths $r$ are freely
   realizable subject only to $r(i) \le \min(N, d(i))$; the two cut points of the finite
   chain — where a tag's accessibility stops, and where the valuation stops being
   constant — should be independent, exactly as the one-tag case shows.
2. **Restricted transfer.** For each pair of tags, determine the set of *transfer*
   formulas $\Box_i^k\bot \to \Box_j^l\bot$ provable in a valuated tag-sensitive theory,
   generalizing the truncated-height criterion of the atom-trivial case.
3. **Inclusion orders in higher families.** Is the "weakenings form a chain" phenomenon
   special to truncation-type families, or does it persist under the common refinement?
   The rigidity of the block family suggests the two effects can be dialed independently.
4. **Beyond boxed falsa as probes.** The order witnesses and world guards are both
   instances of a general pattern: a formula that pins down a configuration of a world and
   then asserts something at it. Characterizing which world-configurations are definable
   in this way would give a uniform explanation of both classification theorems.
5. **Boundary rigidity for the reflection chain.** Is there a natural condition strictly
   between minimal soundness and depth-$1$ reflection? Theorem 11.7 says the gap is
   nonempty; the question is whether it contains anything canonical.

---

## 16. Conclusion

We have settled the inclusion order on the tag-sensitive finite-height theories of tagged
provability logic: the standing order-preservation conjecture is false from truncation
level $2$ upward and correct below it, and the exact criterion is depth domination —
equivalently, *weakenings are truncations*, so the weakenings of a theory form a chain of
length at most $N+1$. And we have separated the two natural finite invariants of
self-trust: the inconsistency height and the reflection depth are constrained by the
single inequality $d \le n$ and by nothing else, every legal pair being realized by an
explicit consistent theory of the logic of provability; within a fixed height, the
realizing theories form a rigid scale of $n+1$ pairwise distinct theories indexed by their
reflection depth.
