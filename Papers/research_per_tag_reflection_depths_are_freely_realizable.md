# Heights and Reflection Depths of Provability Tags: Rigidity, a Height-Gap Inequality, and Decoupling by Window Frames

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study multi-tag provability logic: a consistent theory equipped with a family of provability operators $\Box_i$, one for each *tag* $i$, each satisfying the axioms and rules of Gödel–Löb logic **GL**. Two numerical invariants attach to every tag. The *inconsistency height* $H_i$ is determined by the iterated boxed falsum, $\vdash \Box_i^k \bot \iff H_i < k$; the *reflection depth* $\rho_i$ is the largest $r$ such that the depth-restricted reflection rule "$\vdash \Box_i a \Rightarrow\; \vdash a$ for all $a$ of box depth $< r$" holds. We ask which pairs of vectors $(H, \rho)$ are realizable.

Our answers are as follows. We introduce a general semantic framework — *tag-indexed frames with a valuation*, i.e. finite chains of worlds $0,\dots,N$ in which each tag carries its own downward-looking accessibility relation — and prove that transitivity alone makes every such frame a consistent GL theory for all tags. We then prove an **image theorem**: $\Box_i a$ is a theorem exactly when $a$ holds throughout the image $\mathrm{Im}_i$ of the tag's accessibility relation, from which we deduce that reflection depth is monotone with respect to inclusion of images, and that tags with equal images obey literally identical reflection rules.

Applied to the natural class of *truncated* frames — the class in which each tag's power simply switches off above a level $c_i$ — the image theorem forces a **rigidity theorem**: since these images are nested initial segments, equal heights force equal reflection depths for *every* valuation. In particular the natural conjecture that heights and depths are freely realizable subject to $\rho_i \le H_i$ is **false**. Two further constraints are proved, both witnessed by the explicit *gap probe* $\Box_i^{s}(\Box_j\bot \to \Box_i\bot)$: the **height-gap inequality** $\rho_i \le H_i - H_j$ whenever $H_j < H_i$, and the **low-tag collapse** $\rho_j \le 1$ whenever some tag is strictly higher than $j$. Both bounds are sharp: for a two-valued height vector with values $N > L \ge 1$ we compute the entire reflection spectrum exactly, obtaining $\rho = N - L$ at the high tags and $\rho = 1$ at the low tags, the positive half resting on a bounded-bisimulation lemma. On constant height vectors, by contrast, the conjecture is true, with the reflection depth equal to the distance from the top of the chain to the cut point of a block valuation.

Finally we show the obstruction is an artefact of nesting, not of GL: replacing truncated frames by *window* frames, in which a tag has both a top and a bottom cut and hence an interval image, we construct for every $h \ge 2$ a consistent GL theory with two tags of equal height $h$ and reflection depths $1$ and $0$. The abstract principle behind both halves is one statement: two tags can be given different reflection depths only if their accessibility images are incomparable.

**Keywords:** provability logic, Gödel–Löb logic, reflection principles, Löb's theorem, Kripke semantics, bounded bisimulation, modal depth, realizability of invariants.

---

## 1. Introduction

### 1.1 Provability as a modality

The provability predicate of a sufficiently strong arithmetical theory obeys the Hilbert–Bernays–Löb derivability conditions, and Solovay's theorem identifies the propositional modal principles it validates: they are exactly the theorems of the Gödel–Löb logic **GL**, axiomatized over classical propositional logic by

* **K.** $\Box(a \to b) \to (\Box a \to \Box b)$;
* **4.** $\Box a \to \Box\Box a$;
* **Löb.** $\Box(\Box a \to a) \to \Box a$;

together with modus ponens and necessitation ($\vdash a \Rightarrow \vdash \Box a$). The second incompleteness theorem is the instance $a := \bot$ of Löb's axiom.

A single box captures one notion of provability. Practice is full of *several*: proofs in a base theory, proofs in an extension, proofs of bounded length, proofs using a restricted induction scheme, proofs relative to an oracle. Each is a **tag** $i$ carrying its own operator $\Box_i$, each individually a GL modality, and the interesting phenomena arise from what the ambient theory can prove about the *interaction* of tags.

### 1.2 Two invariants

Throughout, $S$ is a consistent theory with a distinguished set of theorems, written $\vdash a$, whose every tag is a GL tag (Definition 2.3).

**Inconsistency height.** The iterated boxed falsum $\Box_i^k\bot$ is monotone: once provable, it stays provable as $k$ grows. When the transition happens at a finite point we write
$$\vdash \Box_i^k \bot \iff H_i < k,$$
and call $H_i \in \mathbb{N}$ the *inconsistency height* of tag $i$. A tag of height $0$ is *dead*: the theory outright proves $\Box_i \bot$. A tag of height $H$ supports a tower of $H$ nested consistency assertions.

**Reflection depth.** Full reflection, "$\vdash \Box_i a \Rightarrow \vdash a$ for every $a$", is unavailable: taking $a := \bot$ in a theory that proves $\Box_i\bot$ would break consistency, and even for live tags full reflection contradicts Löb's rule. What is available is reflection restricted by *modal complexity*. Writing $\mathrm{bd}(a)$ for the box depth of $a$ (Definition 2.2), say that tag $i$ *reflects to depth $r$* if
$$\text{for all } a \text{ with } \mathrm{bd}(a) < r:\quad \vdash \Box_i a \ \Longrightarrow\ \vdash a .$$
This condition is monotone downward in $r$ (a smaller $r$ constrains fewer formulas), so there is a well-defined *reflection depth*
$$\rho_i \;=\; \sup\{\, r : \text{tag } i \text{ reflects to depth } r \,\},$$
and $\rho_i = 0$ holds trivially for every tag (depth $0$ is vacuous). Reflection depth is a resolution parameter: it says how modally complex a statement must be before the theory's trust in $\Box_i$ becomes unwarranted.

### 1.3 The realizability question and our results

Since a formula of box depth $\ge H_i$ can already exhibit the collapse of the tag, one expects $\rho_i \le H_i$, and it is natural to conjecture that this is the *only* constraint. The conjecture has a compelling picture behind it: in a finite chain of worlds, the height is the distance from the top to the point where a tag's accessibility switches off, and the depth is the distance from the top to the point where the valuation stops being constant — two independent cut points.

We prove that this is not so. Our contributions:

1. **A general semantic framework** (Section 3): tag-indexed frames with a valuation. Transitivity of every tag's relation suffices for all of GL; converse well-foundedness is automatic; the theory is always consistent.
2. **The image theorem** (Theorem 3.6) and its corollaries: reflection depth is monotone in the accessibility image (Theorem 3.8), equal images force identical reflection rules (Corollary 3.9), and different reflection depths force incomparable images (Corollary 3.10).
3. **Rigidity and the refutation** (Section 4): in truncated frames, equal truncated heights force equal reflection depths for every valuation (Theorem 4.4), hence the free-realizability conjecture is false (Theorem 4.11).
4. **The height-gap inequality and the low-tag collapse** (Section 5), both witnessed by the gap probe, together with the corollary that all tags of reflection depth $\ge 2$ share a single height.
5. **Exact spectra** (Section 6): the constant profile is realizable with $\rho$ equal to the distance from the top to a block valuation's cut point; on two-valued height vectors the reflection depths are computed in closed form, $\rho_{\text{high}} = N-L$ and $\rho_{\text{low}} = 1$, showing both inequalities of Section 5 to be sharp. The positive half uses a bounded-bisimulation transfer lemma (Theorem 3.11).
6. **Decoupling** (Section 7): window frames, whose images are intervals rather than initial segments, realize the forbidden profile: for every $h \ge 2$ there is a consistent GL theory with two tags of equal height $h$ and reflection depths $1$ and $0$.
7. **Algorithms and numerical census** (Sections 8–9): reflection depth is computable by depth-$k$ modal type refinement; an exhaustive census at truncation level $N=2$ with two live tags finds $22$ of the $36$ conjecturally admissible profiles realized by truncated models and $32$ by window models on up to five worlds.

---

## 2. The language and the invariants

**Definition 2.1 (Formulas).** Fix countably many atoms $p_0, p_1, \dots$ and countably many tags $i \in \mathbb{N}$. Formulas are generated by
$$a ::= \bot \mid p_n \mid (a \to a) \mid \Box_i a .$$
We abbreviate $\neg a := a \to \bot$ and write $\Box_i^k a$ for the $k$-fold iterate ($\Box_i^0 a = a$).

**Definition 2.2 (Box depth).** $\mathrm{bd}(\bot) = \mathrm{bd}(p_n) = 0$, $\mathrm{bd}(a \to b) = \max(\mathrm{bd}(a), \mathrm{bd}(b))$, $\mathrm{bd}(\Box_i a) = \mathrm{bd}(a) + 1$. In particular $\mathrm{bd}(\Box_i^k a) = k + \mathrm{bd}(a)$.

**Definition 2.3 (GL tag, consistency).** A *theory* is a set $S$ of formulas, whose members we call theorems and write $\vdash a$. The tag $i$ is a **GL tag** of $S$ if $S$ is closed under modus ponens and under necessitation for $\Box_i$, contains all propositional tautologies, and contains all instances of **K**, **4** and **Löb** for $\Box_i$. $S$ is **consistent** if $\nvdash \bot$.

**Definition 2.4 (Height and depth).** Given a consistent theory $S$ all of whose tags are GL tags:

* the *inconsistency height* of tag $i$ is the number $H_i$ (if it exists) with $\vdash \Box_i^k\bot \iff H_i < k$;
* tag $i$ *reflects to depth $r$*, written $\mathrm{Refl}(r, i)$, if $\vdash \Box_i a$ implies $\vdash a$ for every $a$ with $\mathrm{bd}(a) < r$; the *reflection depth* is $\rho_i = \sup\{r : \mathrm{Refl}(r,i)\}$.

**Lemma 2.5 (Monotonicity of the rule).** If $r' \le r$ and $\mathrm{Refl}(r,i)$, then $\mathrm{Refl}(r',i)$. *Proof.* The hypothesis of the rule at $r'$ is a subset of that at $r$. $\square$

**Definition 2.6 (Realizability).** Fix a *truncation level* $N$. A pair of vectors $d, \rho : \mathbb{N} \to \mathbb{N}$ is *realized* by a theory $S$ if for all tags $i$ and all $k, r$,
$$\vdash \Box_i^k \bot \iff \min(N, d_i) < k, \qquad \mathrm{Refl}(r, i) \iff r \le \rho_i .$$
The truncation level lets one compare finite models of different sizes on a common scale; it is exactly the point beyond which heights are not distinguished.

The **naive conjecture** is: for every $N$ and all $d, \rho$ with $\rho_i \le \min(N, d_i)$, some consistent GL theory of the *truncated class* (Definition 4.1) realizes $(d,\rho)$.

---

## 3. Tag-indexed frames with a valuation

### 3.1 Semantics

**Definition 3.1 (Frame, valuation, model).** A *tag-indexed frame* is a family of relations $R_i \subseteq \mathbb{N} \times \mathbb{N}$, written $R_i(m,n)$ and used only for $n < m$. A *valuation* assigns to every world $m$ and atom $p$ a truth value $V(m,p)$. Satisfaction at a world $m$ is defined by

* $m \nvDash \bot$;
* $m \vDash p \iff V(m,p)$;
* $m \vDash a \to b \iff (m \vDash a \Rightarrow m \vDash b)$;
* $m \vDash \Box_i a \iff$ for all $n < m$ with $R_i(m,n)$, $n \vDash a$.

Note the *strictly descending* clause: a box only inspects worlds with a smaller index. The **theory of the model truncated at $N$**, written $\mathrm{Th}_N(R,V)$, consists of the formulas true at every world $m \le N$.

**Definition 3.2 (Transitivity).** $R_i$ is *transitive* if $R_i(m,n)$ and $R_i(n,k)$ imply $R_i(m,k)$ for all $k < n < m$.

**Theorem 3.3 (Soundness).** If $R_i$ is transitive then $i$ is a GL tag of $\mathrm{Th}_N(R,V)$, for every $N$ and every $V$.

*Proof sketch.* Closure under modus ponens and necessitation, propositional tautologies, and **K** are immediate from the truth clauses (necessitation uses only that the theory is truncated *downward closed*: if $a$ holds at all $m \le N$ then in particular at all worlds below any $m \le N$). Axiom **4** is exactly transitivity. For **Löb**, fix $m \le N$ and suppose $m \vDash \Box_i(\Box_i a \to a)$. We show by strong induction on $n$ that every $n < m$ with $R_i(m,n)$ satisfies $a$: given such an $n$, the induction hypothesis together with transitivity gives $n \vDash \Box_i a$ (every $k < n$ with $R_i(n,k)$ also satisfies $R_i(m,k)$, hence $k \vDash a$ by induction), and then $n \vDash \Box_i a \to a$ yields $n \vDash a$. Thus $m \vDash \Box_i a$. Converse well-foundedness, the usual side condition for Löb, is free: the semantics only ever descends through the natural numbers. $\square$

**Theorem 3.4 (Consistency).** $\mathrm{Th}_N(R,V)$ is consistent for every $R, V, N$: $\bot$ fails at the world $0$. $\square$

### 3.2 The image theorem

**Definition 3.5 (Image).** The *image* of tag $i$ in the truncation at $N$ is
$$\mathrm{Im}_i \;=\; \{\, n : \exists\, m \le N,\ n < m \ \text{and}\ R_i(m,n) \,\}.$$

**Theorem 3.6 (Image theorem).** For every formula $a$,
$$\mathrm{Th}_N(R,V) \vdash \Box_i a \quad\Longleftrightarrow\quad n \vDash a \text{ for every } n \in \mathrm{Im}_i .$$

*Proof.* ($\Rightarrow$) If $n \in \mathrm{Im}_i$, pick $m \le N$ with $n < m$ and $R_i(m,n)$; since $\Box_i a$ holds at $m$, $a$ holds at $n$. ($\Leftarrow$) For any $m \le N$, every $R_i$-successor of $m$ lies in $\mathrm{Im}_i$, hence satisfies $a$; so $m \vDash \Box_i a$. $\square$

Since $\vdash a$ means "$a$ is true at every world $\le N$", Theorem 3.6 recasts the reflection rule as a *definability* statement.

**Corollary 3.7 (Reflection as indistinguishability).** Tag $i$ reflects to depth $r$ if and only if no formula of box depth $< r$ is true throughout $\mathrm{Im}_i$ yet false at some world $\le N$. $\square$

**Theorem 3.8 (Monotonicity in the image).** If $\mathrm{Im}_i \subseteq \mathrm{Im}_j$ then $\mathrm{Refl}(r,i)$ implies $\mathrm{Refl}(r,j)$, for every $r$.

*Proof.* Let $\mathrm{bd}(a) < r$ and $\vdash \Box_j a$. By Theorem 3.6, $a$ holds throughout $\mathrm{Im}_j \supseteq \mathrm{Im}_i$, hence throughout $\mathrm{Im}_i$, i.e. $\vdash \Box_i a$; now apply $\mathrm{Refl}(r,i)$. $\square$

**Corollary 3.9 (Equal images, equal rules).** If $\mathrm{Im}_i = \mathrm{Im}_j$ then $\mathrm{Refl}(r,i) \iff \mathrm{Refl}(r,j)$ for every $r$; in particular $\rho_i = \rho_j$. $\square$

**Corollary 3.10 (Decoupling requires incomparability).** If $\mathrm{Refl}(r,i)$ holds and $\mathrm{Refl}(r,j)$ fails, then $\mathrm{Im}_i \not\subseteq \mathrm{Im}_j$. Consequently, in any model in which the tag images form a chain under inclusion, the reflection depths are monotone in the images and any two tags with the same image have the same reflection depth. $\square$

Corollary 3.10 is the conceptual heart of the paper: *the only way to prescribe different reflection depths to two tags is to give them incomparable fields of view.*

### 3.3 Bounded bisimulation

The positive halves of all our exact computations come from one transfer principle, a finite-resolution Ehrenfeucht–Fraïssé argument.

**Theorem 3.11 (Bounded bisimulation transfer).** Let $E_0, E_1, E_2, \dots$ be relations between worlds such that

1. each $E_k$ is symmetric;
2. $E_k$-related worlds agree on all atoms;
3. (*back-and-forth*) if $E_{k+1}(m,n)$ and $m' < m$ with $R_j(m,m')$, then there is $n' < n$ with $R_j(n,n')$ and $E_k(m', n')$.

Then $E_k(m,n)$ implies that $m$ and $n$ satisfy the same formulas of box depth $\le k$.

*Proof sketch.* Induction on the formula. Atoms are handled by (2) and $\bot$ trivially; implication is componentwise. For $\Box_j b$ with $\mathrm{bd}(\Box_j b) \le k+1$, suppose $m \vDash \Box_j b$ and let $n' < n$ with $R_j(n,n')$. By symmetry and (3) applied at $n$ there is $m' < m$ with $R_j(m,m')$ and $E_k(n', m')$; then $m' \vDash b$, so $n' \vDash b$ by the induction hypothesis, since $\mathrm{bd}(b) \le k$. The other direction is symmetric. $\square$

**Lemma 3.12 (Depth zero).** If $V(m,\cdot) = V(n,\cdot)$ then $m$ and $n$ satisfy the same formulas of box depth $0$. $\square$

---

## 4. Truncated frames and the rigidity theorem

**Definition 4.1 (Truncated frames).** Given a *truncation vector* $c : \mathbb{N} \to \mathbb{N}$, let
$$R^{c}_i(m,n) \iff m \le c_i .$$
Thus tag $i$ inspects *everything* below $m$ as long as $m \le c_i$, and nothing at all from higher worlds. Write $\mathrm{Trunc}_N(c,V) = \mathrm{Th}_N(R^c, V)$. These frames are transitive, hence (Theorems 3.3, 3.4) every $\mathrm{Trunc}_N(c,V)$ is a consistent theory all of whose tags are GL tags. The *truncated class at level $N$* is the family of all $\mathrm{Trunc}_N(c,V)$.

This class is exactly the common refinement of the two standard one-parameter families: tag-sensitive accessibility with all atoms true, and tag-independent accessibility with an arbitrary valuation. It is the class in which the naive conjecture was posed.

**Lemma 4.2 (Height spectrum).** In $\mathrm{Trunc}_N(c,V)$, for all $i,k$:
$$\vdash \Box_i^k \bot \iff \min(N, c_i) < k .$$
Thus $H_i = \min(N, c_i)$, *independently of the valuation*.

*Proof sketch.* One computes that $m \vDash \Box_i^k\bot$ iff $k \ge 1$ and ($c_i < m$ or $m < k$): above the tag's cut the boxes are vacuous, below it each box strips one world off the remaining chain. Evaluating at $m = 0$ and at $m = \min(N,c_i)$ gives both directions. $\square$

**Lemma 4.3 (Image of a truncated tag).** $\mathrm{Im}_i = [\,0,\ \min(N,c_i)\,)$, an initial segment. Hence for all $a$,
$$\vdash \Box_i a \iff n \vDash a \text{ for all } n < \min(N,c_i).$$

*Proof.* If $n \in \mathrm{Im}_i$ then $n < m \le \min(N, c_i)$ for some $m$; conversely $n < \min(N,c_i)$ is witnessed by $m = n+1 \le \min(N,c_i)$. Then apply Theorem 3.6. $\square$

Since initial segments are totally ordered by inclusion, Theorem 3.8 and Corollary 3.9 apply to *every* pair of tags:

**Theorem 4.4 (Rigidity).** In $\mathrm{Trunc}_N(c,V)$:

1. *(monotonicity)* if $\min(N,c_i) \le \min(N,c_j)$ then $\mathrm{Refl}(r,i)$ implies $\mathrm{Refl}(r,j)$ for all $r$; in particular $\rho_i \le \rho_j$;
2. *(rigidity)* if $\min(N,c_i) = \min(N,c_j)$ then $\mathrm{Refl}(r,i) \iff \mathrm{Refl}(r,j)$ for all $r$, whatever the valuation; in particular $\rho_i = \rho_j$. $\square$

The reflection-depth vector of a truncated model is therefore *not an independent parameter*: it is a monotone function of the height vector. Combined with Definition 2.6 this yields a constraint purely between the two prescribed vectors.

**Theorem 4.5 (Levelwise constancy).** If a truncated model realizes $(d,\rho)$ at level $N$ and $\min(N,d_i) = \min(N,d_j)$, then $\rho_i = \rho_j$.

*Proof.* Realizing the height vector forces $\min(N,c_i) = \min(N,d_i)$ for every $i$, by Lemma 4.2 evaluated at $k = \min(N,c_i)+1$ and $k = \min(N,d_i)+1$. The two tags then have equal truncated heights, so by Theorem 4.4(2) each satisfies the other's reflection rules; realizing the depth vector converts this into $\rho_i \le \rho_j$ and $\rho_j \le \rho_i$. $\square$

**Definition 4.6 (The refuting profile).** At level $N = 2$ set
$$d_i = \begin{cases} 2 & i \le 1 \\ 0 & i \ge 2\end{cases} \qquad \rho_i = \begin{cases} 1 & i = 0 \\ 0 & i \ge 1.\end{cases}$$

**Lemma 4.7.** $\rho_i \le \min(2, d_i)$ for every $i$. $\square$

**Theorem 4.8 (Refutation I).** No truncated model at level $2$ realizes $(d,\rho)$ of Definition 4.6: the tags $0$ and $1$ have equal truncated height $2$ but are prescribed reflection depths $1 \ne 0$, contradicting Theorem 4.5. $\square$

**Theorem 4.9 (The naive conjecture is false).** It is not the case that every pair $(d,\rho)$ with $\rho_i \le \min(N,d_i)$ is realized by a truncated model. $\square$

We record two further consequences of Theorem 4.4(1) that the census of Section 9 uses:

**Corollary 4.10.** In any truncated model, $H_i \le H_j$ implies $\rho_i \le \rho_j$; profiles violating this monotonicity are unrealizable in the class. $\square$

**Remark 4.11.** Rigidity holds for arbitrary valuations, so no amount of cleverness with the atoms can repair the conjecture inside the truncated class. The conjectured picture — height as the accessibility cut point, depth as the valuation cut point — fails not because the valuation is powerless (Section 6 shows it is very powerful) but because the valuation is *global*: it cannot distinguish two tags at all.

---

## 5. The height-gap inequality

Rigidity is a qualitative constraint. There is also a quantitative one, and it is witnessed by an explicit formula.

**Definition 5.1 (Gap probe).** For tags $i,j$ and $s \in \mathbb{N}$ put
$$G^{s}_{i,j} \;=\; \Box_i^{\,s}\bigl(\Box_j \bot \to \Box_i \bot\bigr).$$
Its box depth is exactly $s + 1$.

**Lemma 5.2 (Truth table of the gap probe).** In a truncated model with vector $c$, for all $s, m$:
$$m \vDash G^s_{i,j} \quad\Longleftrightarrow\quad c_i < m \ \ \text{or}\ \ m \le c_j + s .$$

*Proof sketch.* Induction on $s$. For $s = 0$ one computes $m \vDash \Box_j\bot \iff (m = 0$ or $c_j < m)$ and similarly for $i$; the implication between them is true exactly when $c_i < m$ or $m \le c_j$. For the induction step, $m \vDash \Box_i G^{s}_{i,j}$ is vacuous when $c_i < m$, and otherwise requires $G^{s}_{i,j}$ at every $n < m$, which by the induction hypothesis holds iff $m - 1 \le c_j + s$, i.e. $m \le c_j + s + 1$. $\square$

Thus $G^s_{i,j}$ separates the worlds $\le c_j + s$ from the world $c_j + s + 1$ using box depth only $s+1$ — a very economical separator, and this is what caps reflection.

**Theorem 5.3 (Height-gap inequality).** In a truncated model at level $N$, if $\min(N,c_j) < \min(N,c_i)$ then tag $i$ does *not* reflect to depth $\min(N,c_i) - \min(N,c_j) + 1$. Hence
$$\rho_i \;\le\; H_i - H_j \qquad\text{whenever } H_j < H_i .$$

*Proof.* Write $h_i = \min(N,c_i)$, $h_j = \min(N,c_j)$ and $s = h_i - h_j - 1$. By Lemma 5.2, $G^{s}_{i,j}$ is true at every world $n < h_i$ — indeed $n \le h_j + s = h_i - 1$ — so $\vdash \Box_i G^s_{i,j}$ by Lemma 4.3. Its box depth is $s+1 = h_i - h_j$. But $G^{s}_{i,j}$ fails at the world $h_i$, since $h_i \le c_i$ and $h_i > h_j + s$; as $h_i \le N$, the probe is not a theorem. So reflection fails at depth $h_i - h_j + 1$. $\square$

**Theorem 5.4 (Low-tag collapse).** In a truncated model, if $\min(N,c_j) < \min(N,c_i)$ then tag $j$ does not reflect to depth $2$; hence $\rho_j \le 1$.

*Proof.* Take the probe at distance $0$: the depth-one formula $\Box_j\bot \to \Box_i\bot$. By Lemma 5.2 it is true at every world $n \le c_j$, in particular throughout $\mathrm{Im}_j = [0, h_j)$, so it is provably necessary at $j$. It fails at the world $h_j + 1 \le h_i \le N$, so it is not a theorem. $\square$

**Corollary 5.5 (Deep tags share a height).** If a truncated model realizes $(d,\rho)$ and $\rho_i \ge 2$, $\rho_j \ge 2$, then $\min(N,d_i) = \min(N,d_j)$. Non-trivial reflection can occur only on a single level set of the height vector. *Proof.* If the heights differed, Theorem 5.4 would bound the lower one's depth by $1$. $\square$

**Definition 5.6 (Second refuting profile).** At level $N = 2$ let $d_0 = 2$ and $d_i = 1$ for $i \ge 1$, and let $\rho_i = d_i$ (each tag asked for the maximum depth its own height permits).

**Theorem 5.7 (Refutation II).** No truncated model realizes Definition 5.6: the gap bound gives $\rho_0 \le 2 - 1 = 1 < 2$. Thus the conjecture fails for a second, independent reason — the *joint* height vector constrains each single reflection depth, not merely the tag's own height. $\square$

---

## 6. Exact spectra inside the truncated class

The obstructions of Sections 4–5 are matched exactly by constructions.

### 6.1 The constant profile

**Definition 6.1 (Block valuation).** For $t \in \mathbb{N}$ let $V^{t}(m,p)$ be true exactly when $m < t$: the atoms mark an initial block of the chain, and the *cut point* $t$ is the place where the valuation changes.

**Theorem 6.2 (Uniform realizability).** For all $\rho \le N$, the truncated model with $c_i = N$ for every tag and valuation $V^{\,N-\rho}$ realizes the constant profile $d \equiv N$, $\rho \equiv \rho$. In particular every tag has reflection depth exactly the distance from the top of the chain to the cut point of the valuation.

*Proof sketch.* Heights are immediate from Lemma 4.2. Since every tag sees all worlds below the current one, the model reduces to the single-tag chain with a block valuation, whose reflection spectrum is known to be exactly $\{r : r \le N - t\}$ for cut point $t$: the positive half because worlds $\ge t$ are pairwise indistinguishable up to the number of steps separating them from the block, so a formula of box depth $< N-t$ cannot separate the top world $N$ from $N-1 \in \mathrm{Im}$; the negative half because a formula of box depth exactly $N-t$ can count the distance from the top down to the block. $\square$

So the conjectural picture — *depth = distance from the top to the valuation's cut point* — is entirely correct when all tags are alike. It fails only when tags differ, and then the second cut point is supplied not by the valuation but by a *rival tag*.

### 6.2 Two-valued height vectors

**Definition 6.3.** Fix $1 \le L < N$ and a set of "high" tags. The *two-valued* truncation vector assigns $c_i = N$ to a high tag and $c_i = L$ to a low tag. Take the *flat* valuation $V^{0}$, in which no atom is ever true.

**Theorem 6.4 (Horizon lemma).** Suppose every tag has $c_j = L$ or $c_j \ge N$. Then under the flat valuation, for all $m, n \le N$ and all $k$,
$$\min(m, L+k) = \min(n, L+k) \ \Longrightarrow\ m \text{ and } n \text{ satisfy the same formulas of box depth} \le k .$$

*Proof sketch.* Apply Theorem 3.11 with $E_k(m,n) :\iff m,n \le N$ and $\min(m,L+k) = \min(n,L+k)$. Symmetry is clear; the atom clause is trivial for the flat valuation. For the back-and-forth condition at $E_{k+1}$, let $m' < m$ with $R^c_j(m, m')$. If $j$ is a low tag, then $m \le L$, and $\min(m, L+k+1) = \min(n, L+k+1)$ forces $m = n$, so $m'$ matches itself. If $j$ is a high tag, match $m'$ with $\min(m', L+k)$: this world is $< n$ (because the horizon of $n$ at level $k+1$ agrees with that of $m$) and is $E_k$-related to $m'$ by construction. $\square$

The lemma says: *the low tags freeze the visible horizon at $L$, and every box moves it down by one*, so a formula of box depth $k$ can count no further than $L+k$.

**Theorem 6.5 (High tags reflect to the gap).** With the hypotheses of Theorem 6.4 and $L < N$, every high tag reflects to depth $N - L$.

*Proof.* Let $\mathrm{bd}(a) \le N - L - 1$ and suppose $a$ holds throughout $\mathrm{Im}_i = [0,N)$. For $m < N$ this gives $m \vDash a$ directly; for $m = N$, apply Theorem 6.4 with $k = N-L-1$ to $m = N$ and $n = N-1$, noting $\min(N, L+k) = \min(N-1, L+k) = N-1$. Hence $a$ holds at every world $\le N$. $\square$

**Theorem 6.6 (Every live tag reflects to depth 1).** Under the flat valuation, if $\min(N, c_j) \ge 1$ then tag $j$ reflects to depth $1$.

*Proof.* A formula of box depth $0$ has the same truth value at all worlds (Lemma 3.12, flat valuation). Its truth at the world $0 \in \mathrm{Im}_j$ propagates everywhere. $\square$

**Theorem 6.7 (Exact two-valued spectrum).** Let $1 \le L < N$, and split the tags into a nonempty set of high tags (height $N$) and a nonempty set of low tags (height $L$). Then the truncated model with the flat valuation realizes exactly
$$\rho_{\text{high}} = N - L, \qquad \rho_{\text{low}} = 1 .$$

*Proof.* Heights: Lemma 4.2. Upper bounds: Theorem 5.3 applied to a high tag against a low one gives $\rho_{\text{high}} \le N - L$, and Theorem 5.4 gives $\rho_{\text{low}} \le 1$. Lower bounds: Theorems 6.5 and 6.6. $\square$

**Corollary 6.8 (Sharpness).** The height-gap inequality and the low-tag collapse are attained simultaneously; on height vectors with at most two values the reflection-depth vector is a computable function of the height vector, namely $\rho_i = H_i - \min_j H_j$ for the high tags (with the convention that a single-valued vector falls under Theorem 6.2) and $\rho_i = 1$ for the low ones. $\square$

---

## 7. Decoupling by window frames

Corollary 3.10 tells us exactly what a repair must do: produce incomparable images. Truncated frames cannot, because their images are initial segments. So we cut from below as well as from above.

**Definition 7.1 (Window frames).** Given vectors $b$ (bottom cuts) and $H$ (top cuts), let
$$R^{b,H}_i(m,n) \iff m \le H_i \ \text{and}\ n \ge b_i .$$
Tag $i$ looks down only from the worlds $m \le H_i$, and only onto the worlds $n \ge b_i$.

**Lemma 7.2.** Window frames are transitive, hence (Theorems 3.3, 3.4) yield consistent GL theories. *Proof.* If $m \le H_i$, $n \ge b_i$, $n \le H_i$ and $k \ge b_i$ then $m \le H_i$ and $k \ge b_i$. $\square$

**Lemma 7.3 (Heights and images in a window frame).** In $\mathrm{Th}_N(R^{b,H}, V)$:
$$\vdash \Box_i^k\bot \iff \min(N,H_i) - b_i < k, \qquad \mathrm{Im}_i = [\,b_i,\ \min(N,H_i)\,).$$
So the height is the *length of the window*, and the image is an interval — and intervals can be incomparable. $\square$

**Definition 7.4 (The decoupling model).** Fix $h \ge 2$ and take the chain $0,1,\dots,h+1$ (that is, $N = h+1$). Put
$$b_0 = 0,\quad H_0 = h; \qquad b_1 = 1,\quad H_1 = h+1; \qquad H_i = 0 \ (i \ge 2),$$
and let the valuation be $V^{1}$: every atom is true exactly at the world $0$.

**Theorem 7.5 (Equal heights).** Both live tags have inconsistency height $h$: by Lemma 7.3, $\min(h+1,h) - 0 = h$ for tag $0$ and $\min(h+1,h+1) - 1 = h$ for tag $1$. Every tag $i \ge 2$ is dead. $\square$

**Theorem 7.6 (Tag 1 reflects to depth 0).** For $h \ge 1$, tag $1$ does not reflect to depth $1$.

*Proof.* Its image is $[1, h+1)$, all of whose worlds are above the block of the valuation, so the box-free formula $\neg p_0$ is true throughout it and hence $\vdash \Box_1 \neg p_0$ by Theorem 3.6. But $\neg p_0$ fails at the world $0$, which lies in the model but outside $\mathrm{Im}_1$. So $\neg p_0$, of box depth $0$, refutes reflection at depth $1$. $\square$

**Theorem 7.7 (Tag 0 reflects to depth exactly 1).** For $h \ge 2$: tag $0$ reflects to depth $1$ but not to depth $2$.

*Proof.* *Depth 1.* $\mathrm{Im}_0 = [0,h)$ contains the world $0$ (where $p_0$ holds) and the world $1$ (where it does not), i.e. a representative of each atom pattern occurring in the model. A box-free formula true throughout $\mathrm{Im}_0$ therefore holds at the world $0$ and at the world $1$, and by Lemma 3.12 its value at any world $m \ge 1$ equals its value at $1$. Hence it is a theorem. *Not depth 2.* Consider $\Box_0\bot \to \Box_1\bot$, of box depth $1$. Computing as in Lemma 7.3, $\Box_0\bot$ holds at $m$ iff $m = 0$ or $m > h$, and $\Box_1\bot$ holds at $m$ iff $m \le 1$ or $m > h+1$. The implication is thus true at every $n < h$ and so provably necessary at tag $0$; but at the top world $h+1$ we have $\Box_0\bot$ true (the world is above tag $0$'s ceiling) and $\Box_1\bot$ false (tag $1$ still sees the worlds $1,\dots,h$). So the implication is not a theorem. $\square$

**Theorem 7.8 (Decoupling).** For every $h \ge 2$ there is a consistent GL theory in which two tags have *equal* inconsistency heights $h$ and reflection depths $1$ and $0$ respectively, all other tags being dead with reflection depth $0$. In particular, the profile of Definition 4.6, which no truncated model realizes, is realized by a consistent GL theory (take $h=2$). $\square$

**Theorem 7.9 (Incomparable images, as predicted).** In the decoupling model $\mathrm{Im}_0 = [0,h)$ and $\mathrm{Im}_1 = [1,h+1)$: the world $0$ lies in the first only, the world $h$ in the second only. By Corollary 3.10 this incomparability is *forced* — no model with nested tag images could separate the two depths. $\square$

The two halves of the paper are thus a single statement seen from both sides. Reflection depth is monotone in the accessibility image; the truncated class has nested images and is therefore rigid; window frames have interval images and are therefore free. *The second cut point of the original picture must be a property of the tag, and a global valuation cannot make it so.*

---

## 8. Algorithms

Everything above is effective on finite models. We record the two algorithms used for the census of Section 9.

### 8.1 Inconsistency height

Evaluate $\Box_i^k\bot$ at all worlds $\le N$ for increasing $k$ and return the least $k$ with a theorem, minus one. Direct evaluation of $\Box_i^k\bot$ costs $O(k \cdot N^2)$ steps on a chain of $N+1$ worlds; since $H_i \le N$, computing the height costs $O(N^3)$. For the two structured families one can shortcut with the closed forms $H_i = \min(N,c_i)$ (truncated) and $H_i = \min(N,H_i) - b_i$ (window).

### 8.2 Reflection depth by modal type refinement

Enumerating formulas is unnecessary. Define the *depth-$k$ modal type* of a world by refinement:
$$\tau_0(m) = \bigl(V(m,p)\bigr)_{p},\qquad \tau_{k+1}(m) = \Bigl(\tau_0(m),\ \bigl(i, \{\tau_k(n) : n<m,\ R_i(m,n)\}\bigr)_{i}\Bigr).$$
Two worlds have the same depth-$k$ type iff they satisfy the same formulas of box depth $\le k$; this is Theorem 3.11 in algorithmic dress, its converse being the existence of characteristic formulas for types over a finite model with finitely many atoms and tags. By Corollary 3.7,
$$\mathrm{Refl}(r,i) \iff \text{every world } m \le N \text{ has } \tau_{r-1}(m) = \tau_{r-1}(n) \text{ for some } n \in \mathrm{Im}_i,$$
because a world whose type is unrealized in $\mathrm{Im}_i$ is separated from $\mathrm{Im}_i$ by (the negation of) its characteristic formula, of box depth $r-1$. Refinement of all types up to depth $k$ costs $O(k\,T\,N^2)$ for $T$ tags, and the depth is found by increasing $r$ until the condition fails.

### 8.3 Profile census

Enumerate frames from a parameterized family and valuations over a finite chain, compute $(\min(N,H_i))_i$ and $(\rho_i)_i$ for each, and collect the resulting profiles. Comparing the collected set with the set permitted by the naive constraint $\rho_i \le H_i$ produces the table of Section 9, and each missing profile can be attributed automatically to monotonicity, rigidity, the gap bound, or the low-tag collapse.

---

## 9. Numerical census

Fix the truncation level $N = 2$ and two live tags. The naive conjecture permits $36$ profiles $\bigl((H_0,H_1),(\rho_0,\rho_1)\bigr)$ with $\rho_i \le H_i \le 2$.

| model class | profiles realized (of 36) |
|---|---|
| truncated frames, arbitrary valuation | 22 |
| window frames on up to five worlds, arbitrary valuation | 32 |

Every one of the $14$ profiles missed by the truncated class is accounted for by the theory:

* eight by **rigidity** (equal heights, unequal depths): the two profiles with heights $(1,1)$ and unequal depths, and the six with heights $(2,2)$ and unequal depths;
* four by the **height-gap inequality**: $\bigl((1,2),(0,2)\bigr)$, $\bigl((1,2),(1,2)\bigr)$, $\bigl((2,1),(2,0)\bigr)$, $\bigl((2,1),(2,1)\bigr)$, in each of which the lower tag caps the higher tag's depth at the gap $1$;
* two by **monotonicity of depth in height**: $\bigl((1,2),(1,0)\bigr)$ and $\bigl((2,1),(0,1)\bigr)$.

Of the $14$, window frames on at most five worlds recover $10$: the six profiles with heights $(2,2)$ that rigidity had banned, and the four blocked by the height gap. The remaining four — the two rigidity failures at heights $(1,1)$ and the two monotonicity inversions — are not realized by any window model of that size; whether larger or more general transitive frames realize them is the content of Problem D1 below.

The census also confirms the exact spectra: for the two-valued vector at level $N$ with low value $L$, the measured depths are $N-L$ and $1$ for all $2 \le N \le 8$ and $1 \le L < N$; and for the constant vector with block valuation cut $t$, the measured depth is $N - t$ for all $1 \le N \le 7$ and $0 \le t \le N$.

---

## 10. Discussion

### 10.1 What the results mean informally

For a single self-referential system, Löb's theorem limits self-trust in a way that is *predictable*: the reflection depth is exactly the distance from the top of the model to the point where information stops varying (Theorem 6.2). Put several systems in one universe and their trustworthiness becomes *entangled*. If one tag is strictly weaker than another, the theory can compare their collapse points with a very cheap formula — the gap probe $\Box_i^{s}(\Box_j\bot\to\Box_i\bot)$, i.e. "if the weak one is inconsistent, so am I", boxed a few times — and that comparison caps the trust it can place in the strong tag (Theorem 5.3) while flattening its trust in the weak one (Theorem 5.4).

The escape route is equally informative. A theory can only be blocked by comparisons it can *make*. Tags whose fields of view are nested are always comparable in this sense; nested fields are what one gets when tags differ only in *how far up* they still operate. Tags that differ in what they can see at the *bottom* are genuinely incomparable, and then their reflection depths become independent (Theorem 7.8).

### 10.2 Methodological remarks

The technical economy of the development comes from two general lemmas: the image theorem, which converts every statement about provable boxes into a statement about a set of worlds, and the bounded-bisimulation transfer principle, which converts every "small formulas cannot see this" claim into a back-and-forth game. Together they replace a variety of ad hoc locality computations by a single principle, and they are what makes the exact spectra computable rather than merely bounded.

A second remark concerns hypotheses. In the frame semantics, transitivity of each tag's relation is the *only* assumption needed for GL: converse well-foundedness, usually required alongside, comes free because a box inspects only strictly smaller worlds of a chain. This is why the class of window frames — and any other family of transitive, strictly descending relations — automatically produces consistent GL theories, and it is what makes the search for decoupling constructions a purely combinatorial matter.

### 10.3 Limitations

The theories considered are semantically presented and finitely truncated: they are the theories of finite models, not arithmetical theories. The tags therefore capture the *modal shadow* of provability notions, in the same sense that **GL** captures the modal shadow of a single provability predicate; the arithmetical realizability of a prescribed profile (a multi-tag analogue of Solovay's completeness theorem) is not addressed here. Also, our positive results prescribe the reflection depth *exactly* — the harder demand — but only for the structured families considered; the general packing problem is open.

---

## 11. Future directions

### What this cycle settled

The conjecture, read literally — the theory ranges over the common refinement of tag-truncated frames and valuations — is **false**, and the reason is structural rather than accidental:

* in the refinement the *only* datum of a tag that a provable box sees is its truncated height, because the image of the tag's accessibility relation is the initial segment $[0, \min(N,c_i))$;
* **rigidity**: equal truncated heights force *literally identical* depth-restricted reflection rules, for every valuation;
* the "second inequality" that the original statement anticipated does exist: if $\min(N,d_j) < \min(N,d_i)$ then $\rho_i \le \min(N,d_i) - \min(N,d_j)$, witnessed by the gap probe $\Box_i^{\,\mathrm{gap}-1}(\Box_j\bot \to \Box_i\bot)$;
* a tag that is strictly lower than some other tag has reflection depth $\le 1$; hence two tags of depth $\ge 2$ have equal heights;
* the conjecture *is* true on the constant profiles $d \equiv N$, $\rho \equiv r \le N$;
* on two-valued height vectors the class realizes *exactly one* reflection-depth vector, namely $N - L$ on the high tags and $1$ on the low ones, so both inequalities above are attained and the depth vector is a computable function of the height vector there;
* but the refuting pair *is* realized by a consistent GL theory outside the class: the window-frame family has two tags of equal height $h$ and reflection depths $1$ and $0$;
* the abstract mechanism: reflection depth is monotone in the accessibility image, so decoupling two tags *requires* incomparable images, which truncated frames cannot produce and window frames can.

### D1. Full GL realizability of height–depth profiles

**Conjecture.** For every $N$ and all $d, \rho : \mathbb{N} \to \mathbb{N}$ with $\rho_i \le \min(N, d_i)$ there is a *consistent GL theory* — a finite transitive tag-indexed frame with a valuation, no longer required to be a common refinement of truncated frames and valuations — realizing both vectors: $\vdash \Box_i^k\bot \iff \min(N,d_i) < k$ and $\mathrm{Refl}(r,i) \iff r \le \rho_i$ for every tag $i$.

The key insight is that the reflection depth of a tag is the least $k$ at which its accessibility image fails to realize every depth-$k$ modal type of the model, so realizing a whole profile means engineering one finite "type ladder" in which the prescribed images sit at prescribed rungs — a purely combinatorial packing problem about intervals and a valuation.

### D2. Classification of realizable profiles by image posets

Corollary 3.10 suggests replacing the height vector by a richer invariant: the *poset of tag images* under inclusion, together with the modal type ladder of the model. Which posets arise, and which depth vectors are compatible with a given poset? The truncated class is the case of a chain; the window class realizes the interval orders.

### D3. Sharp thresholds for general height vectors

Corollary 6.8 computes the reflection spectrum in closed form for two-valued height vectors. For a height vector with $\ell$ distinct values, is the maximal depth of a tag always determined by the *nearest lower* value (the local gap), or do the further values interfere?

### D4. Arithmetical realization

Is there a multi-tag analogue of Solovay's theorem: given a prescribed profile realized by a finite frame, are there arithmetical provability predicates whose modal behaviour matches it? Bounded-length proof predicates and iterated consistency extensions are natural candidates for tags with prescribed heights.

### D5. Complexity of the realizability problem

Given a finite profile presented explicitly, decide whether some finite transitive tag-indexed frame realizes it. Section 8's algorithms make each candidate checkable in polynomial time, so the question is the complexity of the search — is it $\mathrm{NP}$-complete, and does the interval structure of Section 7 give a polynomial-time construction?

---

## 12. Conclusion

Heights and reflection depths of provability tags are not independent coordinates. In the class of models where each tag simply switches off above a level, the reflection depth is a monotone function of the height, equal heights force equal depths, and a strictly lower tag caps a higher tag's depth by the height gap and its own depth by $1$ — all three obstructions being witnessed by one small family of formulas, and all three being sharp, as the exact two-valued spectrum $\rho_{\text{high}} = N-L$, $\rho_{\text{low}} = 1$ shows. The obstruction is entirely explained by one abstract fact: a provable box sees only the image of its tag's accessibility relation, and reflection depth is monotone in that image. Rigidity is nesting; freedom is incomparability. Allowing a tag to be blind at the bottom as well as at the top restores the freedom, and yields, for every $h \ge 2$, consistent theories whose two tags have identical towers of consistency statements and yet radically different claims on the theory's trust.
