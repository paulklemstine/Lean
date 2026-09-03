# Uniqueness and Classification of Two-Point Transreal Compactifications

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

The transreal line is the four-part carrier $\mathbb{T} = \mathbb{R} \sqcup \{+\infty\} \sqcup \{-\infty\} \sqcup \{\Phi\}$, on which division is total: $1/0 = +\infty$, $(-1)/0 = -\infty$ and $0/0 = \Phi$ (*nullity*). Analytic statements about $\mathbb{T}$ — in particular sharpness statements asserting that certain guarded operations cannot be made continuous — are usually proved for a topology introduced by decree, namely the extended real line $\overline{\mathbb{R}}$ together with $\Phi$ as an isolated point. We ask whether that choice is forced.

We formulate the four natural axioms — compactness, Hausdorffness, openness of the finite fragment as a copy of $\mathbb{R}$, and isolation of nullity — and call a topology satisfying them a *transreal compactification*. We prove:

1. **(Non-uniqueness.)** The four axioms do not determine the topology: the *circle model*, in which the line is compactified by the single point named $-\infty$ while $+\infty$ and $\Phi$ are isolated, satisfies all four and differs from the natural topology.
2. **(Density does not help.)** Adding the requirement that no exceptional point other than $\Phi$ be isolated still does not determine the topology: the *flip model*, obtained by exchanging the names of the two infinities, is a further counterexample.
3. **(Uniqueness under orientation.)** A topology on $\mathbb{T}$ equals the natural topology **if and only if** it is a transreal compactification and its infinities are *oriented ends*: $+\infty \in \overline{\mathbb{R}_{>0}}$ and $-\infty \in \overline{\mathbb{R}_{<0}}$.
4. **(Classification.)** Every transreal compactification in which neither infinity is isolated is either the natural topology or its flip; there are exactly two.

The engine is a genuine ends argument for $\mathbb{R}$: a compact core produced by Hausdorff separation, connectedness of the two complementary rays, and a forced tail-ray neighbourhood basis at each infinity, followed by the compact-to-Hausdorff comparison of topologies.

As a consequence, sharpness statements about the division boundary split into two grades. *Topology-canonical* statements, such as the discontinuity of $x \mapsto x/x$, hold in every $T_1$ model. *Ends-canonical* statements, such as the non-existence of a continuous repair of $y \mapsto 1/y$ at the origin, hold in the natural topology and its flip — hence in every model whose infinities are ends — but **fail** in the circle model, where the reciprocal admits a unique continuous repair. The necessity of the transreal guard on division is thus an invariant of the remainder, not of the carrier.

**Keywords:** transreal arithmetic, end compactification, extended real line, two-ended space, division by zero, uniqueness of compactifications, nullity.

---

## 1. Introduction

### 1.1 Total arithmetic and its topological cost

Ordinary arithmetic on $\mathbb{R}$ is partial: division by zero has no value. *Transreal arithmetic* removes the partiality by enlarging the carrier with three symbols and legislating values for the missing cases. The carrier has four constructors,

$$\mathbb{T} \;::=\; \mathrm{fin}(x)\ (x \in \mathbb{R}) \;\mid\; +\infty \;\mid\; -\infty \;\mid\; \Phi,$$

with $\Phi$ (*nullity*) absorbing the genuinely indeterminate results. Division becomes a total function: $\mathrm{fin}(1)/\mathrm{fin}(0) = +\infty$, $\mathrm{fin}(-1)/\mathrm{fin}(0) = -\infty$, $\mathrm{fin}(0)/\mathrm{fin}(0) = \Phi$.

Totality is cheap; *continuity* is not. A total arithmetic is only analytically useful if its operations respect limits, and to speak of limits one needs a topology on $\mathbb{T}$. The customary choice is

$$\mathbb{T} \;\cong\; \overline{\mathbb{R}} \;\sqcup\; \{\Phi\}, \tag{1}$$

where $\overline{\mathbb{R}} = [-\infty, +\infty]$ carries its order topology (so that $\mathrm{fin}(x_n) \to +\infty$ exactly when $x_n \to +\infty$ in the usual sense) and $\Phi$ is a separate isolated point. We call (1) the **natural topology** and denote it $\tau_{\mathrm{nat}}$.

### 1.2 The problem

Every theorem of the form "operation $F$ cannot be made continuous on $\mathbb{T}$" is, strictly, a theorem about $\tau_{\mathrm{nat}}$. If some other reasonable topology existed, such theorems would be artefacts of a modelling decision. The question is whether the decision is forced by structural requirements.

We isolate the requirements one would actually insist on and ask whether they characterise (1). They do not, as stated; they do after one further hypothesis, which we identify exactly; and dropping that hypothesis in favour of a weaker non-isolation condition yields a complete classification with exactly two members.

### 1.3 Results and organisation

Section 2 fixes notation and defines a transreal compactification. Section 3 records the properties of $\tau_{\mathrm{nat}}$ that we need, in particular its tail-ray neighbourhood bases. Section 4 develops the ends argument. Section 5 proves the uniqueness theorem. Section 6 constructs the two counterexample models and shows that the hypotheses of the uniqueness theorem are sharp. Section 7 proves the classification theorem. Section 8 applies the classification to the division boundary, splitting sharpness into topology-canonical and ends-canonical grades. Section 9 discusses algorithms and computational content, Section 10 applications, and Section 11 future directions.

---

## 2. The carrier and the axioms

Throughout, $\mathrm{fin} : \mathbb{R} \to \mathbb{T}$ is the injection of the finite fragment; we write $\mathrm{fin}(S) = \{\mathrm{fin}(x) : x \in S\}$ for $S \subseteq \mathbb{R}$, and $I_{>b} = (b, \infty)$, $I_{<b} = (-\infty, b)$. The three *exceptional points* are $+\infty$, $-\infty$, $\Phi$; the first two are the **infinities** and together form the **remainder** of the line inside $\mathbb{T} \setminus \{\Phi\}$. Closures are taken in whichever topology is under discussion and decorated when ambiguity threatens.

We use repeatedly that the four constructors are distinct and that no exceptional point lies in the range of $\mathrm{fin}$.

> **Definition 2.1 (Transreal compactification).** A topology $\tau$ on $\mathbb{T}$ is a **transreal compactification** if
>
> * **(C)** $(\mathbb{T}, \tau)$ is compact;
> * **(H)** $(\mathbb{T}, \tau)$ is Hausdorff;
> * **(L)** $\mathrm{fin} : \mathbb{R} \to (\mathbb{T}, \tau)$ is an open embedding, i.e. a homeomorphism onto an open subspace;
> * **(N)** $\{\Phi\}$ is $\tau$-open.

Axiom (L) says the finite arithmetic is topologically untouched; (C) says runaway behaviour lands somewhere; (H) makes limits unique; (N) says nullity is an error value, not a limit.

> **Definition 2.2 (Orientation).** A transreal compactification $\tau$ is **oriented** if
> $$+\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0}) \quad\text{and}\quad -\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{<0}).$$

Orientation asserts that $+\infty$ is attached to the positive end of the line and $-\infty$ to the negative end. It is a statement of *which* end each infinity names, and it is exactly what topology alone cannot supply.

> **Definition 2.3 (End property).** A point $a \in \mathbb{T} \setminus \mathrm{fin}(\mathbb{R})$ is an **end** for $\tau$ if for every $\tau$-open $W \ni a$ and every $c \in \mathbb{R}$ there is $x \in \mathbb{R}$ with $|x| > c$ and $\mathrm{fin}(x) \in W$; it is a **positive end** if one can additionally require $x > c$, and a **negative end** if one can require $x < -c$.

---

## 3. The natural topology

We record the facts about $\tau_{\mathrm{nat}}$ used later. Let $\iota : \mathbb{T} \to \overline{\mathbb{R}} \oplus \{\ast\}$ be the bijection of (1), sending $\mathrm{fin}(x) \mapsto \mathrm{inl}(x)$, $\pm\infty \mapsto \mathrm{inl}(\pm\infty)$, $\Phi \mapsto \mathrm{inr}(\ast)$, and let $\tau_{\mathrm{nat}}$ be the topology it induces. Then $\iota$ is a homeomorphism onto a compact Hausdorff space, so:

> **Proposition 3.1.** $\tau_{\mathrm{nat}}$ is a transreal compactification, and it is oriented.

*Proof sketch.* Compactness and Hausdorffness transfer along $\iota$ from $\overline{\mathbb{R}} \oplus \{\ast\}$, which is a disjoint union of a compact interval and a point. Axiom (L) holds because $\mathbb{R} \hookrightarrow \overline{\mathbb{R}}$ is an open embedding and $\mathrm{inl}$ is one; (N) holds because $\mathrm{inr}(\ast)$ is a clopen point of the disjoint union. For orientation: $\mathrm{fin}(x) \to +\infty$ as $x \to +\infty$ (this is the statement that $x \mapsto x$ tends to $\top$ in $\overline{\mathbb{R}}$ along the filter $\mathrm{atTop}$, composed with the continuous $\mathrm{inl}$), and eventually $x > 0$; hence $+\infty$ lies in the closure of $\mathrm{fin}(I_{>0})$. Symmetrically for $-\infty$. $\square$

> **Proposition 3.2 (Tail-ray bases).** If $s$ is $\tau_{\mathrm{nat}}$-open and $+\infty \in s$, there is $b \in \mathbb{R}$ with $\{+\infty\} \cup \mathrm{fin}(I_{>b}) \subseteq s$. Symmetrically, if $-\infty \in s$ there is $b$ with $\{-\infty\} \cup \mathrm{fin}(I_{<b}) \subseteq s$.

*Proof sketch.* Transport $s$ through $\iota$ and restrict to the $\overline{\mathbb{R}}$ summand: the preimage is an open neighbourhood of $\top$ in $\overline{\mathbb{R}}$, and the neighbourhood filter of $\top$ there is generated by the rays $(b, \top]$. Pull the ray back through the injectivity of $\iota$. $\square$

> **Corollary 3.3.** Neither $\{+\infty\}$ nor $\{-\infty\}$ is $\tau_{\mathrm{nat}}$-open.

*Proof.* A tail ray inside $\{+\infty\}$ would force $\mathrm{fin}(b+1) = +\infty$. $\square$

Proposition 3.2 is the target of the whole argument: we shall show that *any* oriented transreal compactification has the same tail-ray bases, and that this alone determines the topology.

---

## 4. The ends argument

Fix a transreal compactification $\tau$; all topological notions in this section refer to $\tau$ unless stated otherwise. Write $\mathrm{fin}$ for the (continuous, by (L)) injection.

### 4.1 From limit point to end

> **Lemma 4.1 (The positive end absorbs the ray).** Assume $+\infty \in \operatorname{cl}\,\mathrm{fin}(I_{>0})$. Then for every open $W \ni +\infty$ and every $c \in \mathbb{R}$ there exists $x > c$ with $\mathrm{fin}(x) \in W$.

*Proof.* Put $d = |c| \ge 0$. The set $\mathrm{fin}([-d,d])$ is the continuous image of a compact set, hence compact, hence closed by (H). Therefore $W' = W \setminus \mathrm{fin}([-d,d])$ is open, and it contains $+\infty$ because $+\infty \notin \mathrm{fin}(\mathbb{R})$. Since $+\infty$ lies in the closure of $\mathrm{fin}(I_{>0})$, the open set $W'$ meets $\mathrm{fin}(I_{>0})$: there is $x > 0$ with $\mathrm{fin}(x) \in W'$. Then $x \notin [-d,d]$, and $x > 0$ forces $x > d \ge c$. $\square$

> **Lemma 4.2 (The negative end).** Assume $-\infty \in \operatorname{cl}\,\mathrm{fin}(I_{<0})$. Then for every open $W \ni -\infty$ and every $c \in \mathbb{R}$ there exists $x < c$ with $\mathrm{fin}(x) \in W$.

*Proof.* Mirror image of Lemma 4.1: the same compact interval $\mathrm{fin}([-d,d])$, $d = |c|$, is deleted, and the witness $x < 0$ obtained from the closure hypothesis must satisfy $x < -d \le c$. $\square$

The upgrade in Lemmas 4.1–4.2 — from "is a limit point of the positive reals" to "meets *arbitrarily far* positive reals" — is where compactness of intervals and Hausdorffness cooperate, and it is the entire content of the phrase "the infinities are ends and not merely limit points".

### 4.2 The compact core and the ray partition

> **Lemma 4.3 (Unoriented ray separation).** Suppose both $+\infty$ and $-\infty$ satisfy the end property of Definition 2.3 (in the unsigned form: every neighbourhood contains finite points of arbitrarily large modulus). Then there exist $M \in \mathbb{R}$ and disjoint open sets $U \ni +\infty$, $V \ni -\infty$ with $\Phi \notin U \cup V$, such that **either**
> $$\mathrm{fin}(I_{>M}) \subseteq U \ \text{ and } \ \mathrm{fin}(I_{<-M}) \subseteq V,$$
> **or**
> $$\mathrm{fin}(I_{>M}) \subseteq V \ \text{ and } \ \mathrm{fin}(I_{<-M}) \subseteq U.$$

*Proof sketch.* By (H) choose disjoint open $U_0 \ni +\infty$, $V_0 \ni -\infty$. Using (N), replace them by $U_1 = U_0 \cup \{\Phi\}$ (open) and $V_1 = V_0 \setminus \{\Phi\}$ (open, since $\{\Phi\}$ is also closed by (H)); these remain disjoint and now cover $\Phi$ exactly once. The uncovered set $K = \mathbb{T} \setminus (U_1 \cup V_1)$ is closed in a compact space, hence compact, and by construction $K \subseteq \mathrm{fin}(\mathbb{R})$ and $K$ omits all three exceptional points. Since $\mathrm{fin}$ is an embedding, $\mathrm{fin}^{-1}(K)$ is a compact, hence bounded, subset of $\mathbb{R}$: choose $M$ with $\mathrm{fin}^{-1}(K) \subseteq [-M, M]$, $M \ge 0$. Then $\mathrm{fin}(I_{>M})$ and $\mathrm{fin}(I_{<-M})$ are covered by the disjoint open sets $U_1, V_1$. Each ray is connected and $\mathrm{fin}$ is continuous, so each image is connected and therefore lies wholly in $U_1$ or wholly in $V_1$.

It remains to exclude both rays landing in the same set — say both in $U_1$. Then $V_1$, an open neighbourhood of $-\infty$, would contain no $\mathrm{fin}(x)$ with $|x| > M$, contradicting the end property of $-\infty$. Setting $U = U_1 \setminus \{\Phi\}$, $V = V_1$ (both open, since $\{\Phi\}$ is clopen) gives the statement. $\square$

> **Corollary 4.4 (Oriented ray separation).** If $\tau$ is *oriented*, then the first alternative of Lemma 4.3 holds: there are $M$ and disjoint open $U \ni +\infty$, $V \ni -\infty$ with $\mathrm{fin}(I_{>M}) \subseteq U$ and $\mathrm{fin}(I_{<-M}) \subseteq V$.

*Proof.* Orientation plus Lemmas 4.1–4.2 give the unsigned end property, so Lemma 4.3 applies. In the second alternative, $U$ contains the far negative ray and is disjoint from $V \supseteq \mathrm{fin}(I_{>M})$; but Lemma 4.1 supplies $x > M$ with $\mathrm{fin}(x) \in U$, a contradiction. $\square$

### 4.3 Forced neighbourhood bases

> **Proposition 4.5 (Tail rays are neighbourhoods).** Let $\tau$ be an oriented transreal compactification. For every $b \in \mathbb{R}$ there is a $\tau$-open $W \ni +\infty$ with $W \subseteq \{+\infty\} \cup \mathrm{fin}(I_{>b})$. Symmetrically, for every $b$ there is a $\tau$-open $W' \ni -\infty$ with $W' \subseteq \{-\infty\} \cup \mathrm{fin}(I_{<b})$.

*Proof sketch.* Take $M, U, V$ from Corollary 4.4 and set $R = \max(M, b)$. The set $\mathrm{fin}([-R, R])$ is compact, hence closed, so
$$W \;=\; U \setminus \mathrm{fin}\big([-R,R]\big)$$
is open and contains $+\infty$. We check $W \subseteq \{+\infty\} \cup \mathrm{fin}(I_{>b})$ by inspecting the four kinds of point. A finite point $\mathrm{fin}(x) \in W$ has $|x| > R \ge M$; if $x < -R$ then $\mathrm{fin}(x) \in V$, contradicting disjointness with $U$; hence $x > R \ge b$. The point $-\infty$ is excluded because $-\infty \in V$ and $U \cap V = \emptyset$; the point $\Phi$ is excluded because $\Phi \notin U$. What remains is $+\infty$ itself. The statement at $-\infty$ is symmetric, with $W' = V \setminus \mathrm{fin}([-R,R])$ and $R = \max(M, |b|)$. $\square$

Proposition 4.5 says: the neighbourhood filter of $+\infty$ in *any* oriented transreal compactification refines the tail-ray filter, which is precisely the neighbourhood filter of $\top$ in $\overline{\mathbb{R}}$.

---

## 5. The uniqueness theorem

> **Proposition 5.1 (Comparison).** If $\tau$ is an oriented transreal compactification then $\tau \le \tau_{\mathrm{nat}}$; that is, every $\tau_{\mathrm{nat}}$-open set is $\tau$-open.

*Proof.* Let $s$ be $\tau_{\mathrm{nat}}$-open and $a \in s$. We produce a $\tau$-open $W$ with $a \in W \subseteq s$; since $a$ was arbitrary, $s$ is a $\tau$-neighbourhood of each of its points and hence $\tau$-open. Four cases, by the constructor of $a$.

*Finite, $a = \mathrm{fin}(x)$.* The set $\mathrm{fin}^{-1}(s)$ is open in $\mathbb{R}$ (continuity of $\mathrm{fin}$ for $\tau_{\mathrm{nat}}$), so by (L) its image $\mathrm{fin}(\mathrm{fin}^{-1}(s))$ is $\tau$-open; it contains $a$ and is contained in $s$.

*Nullity, $a = \Phi$.* Take $W = \{\Phi\}$, $\tau$-open by (N).

*$a = +\infty$.* By Proposition 3.2 there is $b$ with $\{+\infty\} \cup \mathrm{fin}(I_{>b}) \subseteq s$; by Proposition 4.5 there is a $\tau$-open $W \ni +\infty$ inside that tail set.

*$a = -\infty$.* Symmetric, using the second halves of Propositions 3.2 and 4.5. $\square$

> **Theorem 5.2 (Uniqueness of the oriented two-point transreal compactification).** Let $\tau$ be a topology on $\mathbb{T}$ which is compact and Hausdorff, for which $\mathrm{fin}$ is an open embedding and $\{\Phi\}$ is open, and which is oriented:
> $$+\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0}), \qquad -\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{<0}).$$
> Then $\tau = \tau_{\mathrm{nat}}$.

*Proof.* Proposition 5.1 gives $\tau \le \tau_{\mathrm{nat}}$, i.e. the identity $(\mathbb{T}, \tau) \to (\mathbb{T}, \tau_{\mathrm{nat}})$ is continuous. For the converse inequality, let $s$ be $\tau$-open. Its complement is $\tau$-closed, hence $\tau$-compact by (C), hence its image under the continuous identity is $\tau_{\mathrm{nat}}$-compact, hence $\tau_{\mathrm{nat}}$-closed because $\tau_{\mathrm{nat}}$ is Hausdorff. So $s$ is $\tau_{\mathrm{nat}}$-open. Both inequalities give $\tau = \tau_{\mathrm{nat}}$. $\square$

> **Theorem 5.3 (Characterisation).** For a topology $\tau$ on $\mathbb{T}$,
> $$\tau = \tau_{\mathrm{nat}} \iff \tau \text{ is a transreal compactification and } +\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0}) \text{ and } -\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{<0}).$$

*Proof.* Forward: Proposition 3.1. Backward: Theorem 5.2. $\square$

The final step of Theorem 5.2 deserves emphasis: it is the standard fact that **a compact topology finer than a Hausdorff topology equals it**. This is what converts the merely one-sided information produced by the ends argument (every natural-open set is $\tau$-open) into an equality without any further analysis of $\tau$.

---

## 6. Sharpness: two exotic models

We now show that neither the orientation hypothesis nor any weakening of it to a density condition can be dropped.

### 6.1 The circle model

Let $\mathbb{R}^+ = \mathbb{R} \cup \{\infty_{\mathrm{c}}\}$ denote the one-point compactification of the line — topologically a circle, with neighbourhoods of $\infty_{\mathrm{c}}$ the complements of compact sets. Define a bijection
$$\gamma : \mathbb{T} \longrightarrow \mathbb{R}^+ \oplus \{0,1\}, \qquad
\gamma(\mathrm{fin}\,x) = \mathrm{inl}(x), \quad
\gamma(-\infty) = \mathrm{inl}(\infty_{\mathrm{c}}), \quad
\gamma(+\infty) = \mathrm{inr}(1), \quad
\gamma(\Phi) = \mathrm{inr}(0),$$
and let $\tau_{\mathrm{circ}}$ be the topology it induces.

> **Theorem 6.1 (The circle model).** $\tau_{\mathrm{circ}}$ is a transreal compactification, and $\tau_{\mathrm{circ}} \ne \tau_{\mathrm{nat}}$. Moreover $\{+\infty\}$ is $\tau_{\mathrm{circ}}$-open, and $+\infty \notin \operatorname{cl}_{\tau_{\mathrm{circ}}} \mathrm{fin}(\mathbb{R})$.

*Proof sketch.* $\gamma$ is injective and surjective (a case check on the four constructors and on the two summands), so it is a homeomorphism onto a compact Hausdorff space — the one-point compactification of a locally compact Hausdorff space is compact Hausdorff, and adding two discrete points preserves both. Hence (C) and (H). Axiom (L): $\mathbb{R} \hookrightarrow \mathbb{R}^+$ is an open embedding and $\mathrm{inl}$ is one, so $\mathrm{fin} = \gamma^{-1} \circ \mathrm{inl}$ is one. Axiom (N): $\{\mathrm{inr}(0)\}$ is open. Openness of $\{+\infty\}$: $\{\mathrm{inr}(1)\}$ is open. Finally $\tau_{\mathrm{circ}} \ne \tau_{\mathrm{nat}}$, because $\{+\infty\}$ is $\tau_{\mathrm{circ}}$-open but not $\tau_{\mathrm{nat}}$-open (Corollary 3.3). $\square$

In the circle model, $\mathrm{fin}(x) \to -\infty$ both as $x \to +\infty$ and as $x \to -\infty$: the single glue point is the limit of the two rays. Thus
$$-\infty \in \operatorname{cl}_{\tau_{\mathrm{circ}}} \mathrm{fin}(I_{>0}) \quad\text{and}\quad -\infty \in \operatorname{cl}_{\tau_{\mathrm{circ}}} \mathrm{fin}(I_{<0}),$$
so the *negative* orientation hypothesis holds while the positive one fails badly.

### 6.2 The flip model

Let $\sigma : \mathbb{T} \to \mathbb{T}$ be the involution exchanging $+\infty$ and $-\infty$ and fixing all finite points and $\Phi$; it is an involution, hence bijective. Define $\tau_{\mathrm{flip}}$ as the topology induced by $\sigma$ from $\tau_{\mathrm{nat}}$: a set $s$ is $\tau_{\mathrm{flip}}$-open iff $\sigma(s)$ is $\tau_{\mathrm{nat}}$-open.

> **Theorem 6.2 (The flip model).** $\tau_{\mathrm{flip}}$ is a transreal compactification, neither $\{+\infty\}$ nor $\{-\infty\}$ is $\tau_{\mathrm{flip}}$-open, and $\tau_{\mathrm{flip}} \ne \tau_{\mathrm{nat}}$.

*Proof sketch.* By construction $\sigma : (\mathbb{T}, \tau_{\mathrm{flip}}) \to (\mathbb{T}, \tau_{\mathrm{nat}})$ is a homeomorphism (it is an inducing bijection), so compactness, Hausdorffness and non-isolation of the two infinities transfer. Axiom (L) holds because $\sigma \circ \mathrm{fin} = \mathrm{fin}$, so the $\tau_{\mathrm{flip}}$-open embedding property of $\mathrm{fin}$ is the $\tau_{\mathrm{nat}}$-one. Axiom (N) holds because $\sigma(\{\Phi\}) = \{\Phi\}$. Finally, in $\tau_{\mathrm{flip}}$ we have $+\infty \in \operatorname{cl}\,\mathrm{fin}(I_{<0})$ (transport the natural-topology fact $-\infty \in \operatorname{cl}\,\mathrm{fin}(I_{<0})$ through $\sigma$, using $\sigma(\mathrm{fin}(S)) = \mathrm{fin}(S)$), whereas $+\infty \notin \operatorname{cl}_{\tau_{\mathrm{nat}}} \mathrm{fin}(I_{<0})$; hence the two topologies differ. $\square$

> **Corollary 6.3 (Sharpness).** There is a transreal compactification different from $\tau_{\mathrm{nat}}$ (the circle model), and there is one different from $\tau_{\mathrm{nat}}$ in which no exceptional point other than $\Phi$ is isolated (the flip model). Hence neither the four axioms nor the four axioms plus density determine the topology, and the orientation hypothesis of Theorem 5.2 is indispensable.

---

## 7. Classification

The flip model is the *only* obstruction once isolated infinities are banned.

> **Lemma 7.1 (Non-isolated implies limit of finite points).** Let $\tau$ be a transreal compactification. If $\{+\infty\}$ is not $\tau$-open then $+\infty \in \operatorname{cl}_\tau \mathrm{fin}(\mathbb{R})$. Symmetrically for $-\infty$.

*Proof sketch.* Suppose not. Then some open $W \ni +\infty$ misses $\mathrm{fin}(\mathbb{R})$, so $W \subseteq \{+\infty, -\infty, \Phi\}$. Removing $\Phi$ (which is clopen) and separating $+\infty$ from $-\infty$ by (H) shrinks $W$ to $\{+\infty\}$, which would then be open — a contradiction. $\square$

> **Lemma 7.2 (Limit of finite points implies end).** Let $\tau$ be a transreal compactification and $a$ an exceptional point with $a \in \operatorname{cl}_\tau \mathrm{fin}(\mathbb{R})$. Then for every open $W \ni a$ and every $c$ there is $x$ with $|x| > c$ and $\mathrm{fin}(x) \in W$.

*Proof.* Exactly as Lemma 4.1, deleting the compact-hence-closed set $\mathrm{fin}([-|c|, |c|])$ from $W$ and using that $a \notin \mathrm{fin}(\mathbb{R})$. $\square$

> **Proposition 7.3 (Orientation dichotomy).** Let $\tau$ be a transreal compactification in which neither $\{+\infty\}$ nor $\{-\infty\}$ is open. Then either
> $$+\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0}) \ \text{ and } \ -\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{<0}),$$
> or
> $$+\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{<0}) \ \text{ and } \ -\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0}).$$

*Proof sketch.* Lemmas 7.1–7.2 give both infinities the unsigned end property, so Lemma 4.3 applies and produces $M$, $U \ni +\infty$, $V \ni -\infty$ disjoint, with the two rays distributed between $U$ and $V$ in one of the two orders. Suppose $\mathrm{fin}(I_{>M}) \subseteq U$, $\mathrm{fin}(I_{<-M}) \subseteq V$. To see $+\infty \in \operatorname{cl}\,\mathrm{fin}(I_{>0})$, let $W \ni +\infty$ be open; apply the end property to $W \cap U$ with $c = \max(M, 0)$, obtaining $x$ with $|x| > c$ and $\mathrm{fin}(x) \in W \cap U$. If $x$ were negative then $x < -M$, so $\mathrm{fin}(x) \in V$, contradicting disjointness; so $x > 0$ and $W$ meets $\mathrm{fin}(I_{>0})$. The other three assertions are identical up to symmetry. $\square$

> **Lemma 7.4 (Transport along the flip).** For a topology $\tau$ on $\mathbb{T}$ let $\sigma^*\tau$ be the topology induced by $\sigma$ from $\tau$. Then $\sigma^*(\sigma^*\tau) = \tau$; $\sigma^*\tau_{\mathrm{nat}} = \tau_{\mathrm{flip}}$; $\sigma^*\tau$ is a transreal compactification whenever $\tau$ is; and for any $S \subseteq \mathbb{R}$ and any $a$,
> $$a \in \operatorname{cl}_{\sigma^*\tau} \mathrm{fin}(S) \iff \sigma(a) \in \operatorname{cl}_{\tau} \mathrm{fin}(S).$$

*Proof sketch.* $\sigma$ is an involutive bijection, so inducing twice returns the original topology, and $\sigma$ is a homeomorphism $(\mathbb{T}, \sigma^*\tau) \to (\mathbb{T}, \tau)$; compactness, Hausdorffness and openness of $\{\Phi\}$ transfer, as does (L) because $\sigma \circ \mathrm{fin} = \mathrm{fin}$. The closure statement is the homeomorphism-invariance of closures together with $\sigma(\mathrm{fin}(S)) = \mathrm{fin}(S)$. $\square$

> **Theorem 7.5 (Classification).** Let $\tau$ be a compact Hausdorff topology on $\mathbb{T}$ for which $\mathrm{fin}$ is an open embedding, $\{\Phi\}$ is open, and neither $\{+\infty\}$ nor $\{-\infty\}$ is open. Then
> $$\tau = \tau_{\mathrm{nat}} \quad\text{or}\quad \tau = \tau_{\mathrm{flip}},$$
> and these two are distinct.

*Proof.* By Proposition 7.3, either $\tau$ is oriented — in which case Theorem 5.2 gives $\tau = \tau_{\mathrm{nat}}$ — or it is *anti*-oriented. In the latter case, Lemma 7.4 makes $\sigma^*\tau$ a transreal compactification and converts anti-orientation of $\tau$ into orientation of $\sigma^*\tau$; Theorem 5.2 gives $\sigma^*\tau = \tau_{\mathrm{nat}}$, whence
$$\tau = \sigma^*(\sigma^*\tau) = \sigma^*\tau_{\mathrm{nat}} = \tau_{\mathrm{flip}}.$$
Distinctness is Theorem 6.2. $\square$

> **Corollary 7.6.** Under the hypotheses of Theorem 7.5, either orientation clause alone selects the natural topology: if additionally $+\infty \in \operatorname{cl}_\tau \mathrm{fin}(I_{>0})$, then $\tau = \tau_{\mathrm{nat}}$.

*Proof.* The alternative $\tau = \tau_{\mathrm{flip}}$ would give, by Lemma 7.4, $-\infty \in \operatorname{cl}_{\tau_{\mathrm{nat}}} \mathrm{fin}(I_{>0})$, which is false: the natural-topology open set $\{-\infty\} \cup \mathrm{fin}(I_{<0})$ is a neighbourhood of $-\infty$ missing $\mathrm{fin}(I_{>0})$. $\square$

Theorem 7.5 is the promised statement in classical language: **a two-point-remainder compactification of the (locally compact, two-ended) real line in which both remainder points are limit points is the end compactification**, the sole residual freedom being the labelling of the two ends.

---

## 8. Consequences for the division boundary

Transreal arithmetic guards division with a case split at zero. Two sharpness theorems justify the guard. The classification lets us say exactly how much each of them depends on the topology.

Write $\mathrm{rec}_v : \mathbb{R} \to \mathbb{T}$ for the reciprocal repaired at the origin by a value $v$:
$$\mathrm{rec}_v(y) = \begin{cases} v, & y = 0,\\ \mathrm{fin}(1/y), & y \ne 0,\end{cases}$$
and $\mathrm{sq}: \mathbb{R} \to \mathbb{T}$, $\mathrm{sq}(x) = \mathrm{fin}(x)/\mathrm{fin}(x)$, for self-division, which equals $\mathrm{fin}(1)$ for $x \ne 0$ and $\Phi$ at $x = 0$.

> **Theorem 8.1 (Self-division is topology-canonical).** In *every* $T_1$ topology on $\mathbb{T}$, the map $\mathrm{sq}$ is discontinuous.

*Proof sketch.* $\{\Phi\}$ is closed in a $T_1$ space, so $\mathbb{T} \setminus \{\mathrm{fin}(1)\}$ is an open set containing $\mathrm{sq}(0) = \Phi$; its preimage is $\{0\}$, which is not a neighbourhood of $0$ in $\mathbb{R}$. $\square$

Since every transreal compactification is Hausdorff, hence $T_1$, no model whatsoever removes this obstruction; in particular it survives in the circle model.

> **Theorem 8.2 (Reciprocal repair is ends-canonical).** In the natural topology, $\mathrm{rec}_v$ is discontinuous at $0$ for every $v \in \mathbb{T}$. The same holds in the flip model. Consequently, by Theorem 7.5, in **every** transreal compactification with no isolated infinity and for every $v$, $\mathrm{rec}_v$ is discontinuous at the origin.

*Proof sketch.* In the natural topology the one-sided limits of $\mathrm{fin}(1/y)$ as $y \to 0^{\pm}$ are $+\infty$ and $-\infty$; a Hausdorff space has unique limits, so no $v$ can serve. For the flip model one transports: $\sigma \circ \mathrm{rec}_v = \mathrm{rec}_{\sigma(v)}$, and $\sigma$ is an inducing map $(\mathbb{T}, \tau_{\mathrm{flip}}) \to (\mathbb{T}, \tau_{\mathrm{nat}})$, so continuity of $\mathrm{rec}_v$ at $0$ for $\tau_{\mathrm{flip}}$ is equivalent to continuity of $\mathrm{rec}_{\sigma(v)}$ at $0$ for $\tau_{\mathrm{nat}}$, which fails. The final clause is Theorem 7.5 applied case by case. $\square$

> **Theorem 8.3 (The circle model repairs the reciprocal, uniquely).** In $\tau_{\mathrm{circ}}$, the map $\mathrm{rec}_{-\infty}$ is continuous on all of $\mathbb{R}$ — in particular at the origin. Moreover if $\mathrm{rec}_v$ is continuous at $0$ for $\tau_{\mathrm{circ}}$ then $v = -\infty$.

*Proof sketch.* Consider $r : \mathbb{R} \to \mathbb{R}^+$ with $r(0) = \infty_{\mathrm{c}}$ and $r(y) = 1/y$ otherwise. Away from $0$, $r$ is the composition of $y \mapsto 1/y$ with the open embedding $\mathbb{R} \hookrightarrow \mathbb{R}^+$, hence continuous. At $0$: $y \mapsto 1/y$ tends to the cocompact filter along the punctured neighbourhood filter of $0$ — from the right it exceeds every bound, from the left it falls below every bound, and the supremum of the two one-sided filters is the punctured filter — and the defining property of the one-point compactification is that $\mathrm{inl}$ tends to $\infty_{\mathrm{c}}$ along the cocompact filter. Adding the pure filter at $0$, on which $r$ is constantly $\infty_{\mathrm{c}}$, gives continuity at $0$. Since $\gamma \circ \mathrm{rec}_{-\infty} = \mathrm{inl}\circ\, r$ and $\tau_{\mathrm{circ}}$ is induced by $\gamma$, the map $\mathrm{rec}_{-\infty}$ is continuous.
For uniqueness: $\mathrm{rec}_v$ and $\mathrm{rec}_{-\infty}$ agree off the origin, so if both are continuous at $0$ they have the same limit along the punctured filter; Hausdorffness of $\tau_{\mathrm{circ}}$ then forces $v = -\infty$. $\square$

The three theorems together give the promised dichotomy:

| statement | status |
|---|---|
| $x \mapsto x/x$ is discontinuous | **topology-canonical** — holds in every $T_1$ model |
| no value repairs $y \mapsto 1/y$ at $0$ | **ends-canonical** — holds exactly in the models with two honest ends (natural and flip); fails in the circle model, where $-\infty$ is the unique repair |

The interpretation is clean. The guard on self-division is forced by arithmetic, since $x/x$ genuinely takes an isolated exceptional value. The guard on the reciprocal is forced by *geometry of the remainder*: it is needed precisely because the two ends of the line are kept apart. A compactification which merges them removes the need for the guard — at the cost of destroying the order structure of the infinities, which transreal multiplication depends on.

---

## 9. Algorithmic and computational content

Although the theorems are about topologies on an uncountable carrier, all the decision content is finite once a model is presented by *neighbourhood bases at the exceptional points*. Each of the three models can be encoded as a rule assigning to each exceptional point a family of basic neighbourhoods parametrised by a real threshold:

* natural: $N_b(+\infty) = \{+\infty\} \cup \mathrm{fin}(I_{>b})$, $N_b(-\infty) = \{-\infty\} \cup \mathrm{fin}(I_{<-b})$, $N(\Phi) = \{\Phi\}$;
* flip: the same two families with the labels exchanged;
* circle: $N_b(-\infty) = \{-\infty\} \cup \mathrm{fin}(\{|x| > b\})$, $N(+\infty) = \{+\infty\}$, $N(\Phi) = \{\Phi\}$.

Three algorithms then decide the qualitative questions.

**(A) End classification.** Given such a basis oracle, decide for each exceptional point whether it is isolated, a positive end, a negative end, or both (a merged end). Test a point $a$ by probing whether $N_b(a)$ contains finite points $> b$ and finite points $< -b$ for growing $b$. The outcome is a *signature*, and by Theorems 5.2, 6.1 and 7.5 the signature determines the model: signature (positive, negative) $\Rightarrow$ natural; (negative, positive) $\Rightarrow$ flip; (isolated, merged) $\Rightarrow$ circle-like.

**(B) Compact core radius and ray assignment.** Given a Hausdorff separation of the two infinities presented as two threshold sets, compute the least $M$ such that the two rays $(M,\infty)$, $(-\infty,-M)$ are covered, and report which ray goes to which separator. This is the computational shadow of Lemma 4.3, and it makes the connectedness step visible: as $M$ grows, each ray remains inside a single separator and never oscillates.

**(C) Repairability test.** Given a model and a candidate value $v$, decide whether $\mathrm{rec}_v$ is continuous at $0$ by computing the limits of $\mathrm{fin}(1/y)$ along $y \to 0^{+}$ and $y \to 0^{-}$ in the model's own neighbourhood structure and testing whether they coincide and equal $v$. This returns "unrepairable" for the natural and flip models and returns the unique value $-\infty$ for the circle model, reproducing Theorems 8.2 and 8.3.

All three run in time linear in the number of probe thresholds; none require any search, because the ends argument has already reduced the topology to tail data.

---

## 10. Applications

**Robust numerics and total arithmetic.** Systems that return $\pm\infty$ and a nullity-like value instead of raising exceptions inherit exactly this analysis. The classification says: if you want your infinite values to be honest limits of large magnitudes, you have essentially no design freedom left beyond the sign convention, and you *must* guard the reciprocal at zero. If you are willing to merge the two infinities into a single "unsigned infinity" — a design also found in projective and wheel-style arithmetics — the reciprocal becomes continuous, but you lose the ability to distinguish limits from the two sides, and with it the compatibility of the infinities with the order and with multiplication by signs.

**Semantics of exact real computation.** The tail-ray neighbourhood bases forced by Proposition 4.5 are exactly the observation predicates "$x$ exceeds $b$" available to a computation on a stream representation of a real number. The uniqueness theorem says that the observational topology of a two-ended total real arithmetic is determined by which observations are available at the infinities — an appealingly operational reading.

**Compactification design.** Beyond the transreal setting, the argument is a template: to decide whether a proposed finite-remainder compactification of a locally compact space is the end compactification, one need only check that no remainder point is isolated and that each remainder point absorbs a distinct complementary component of a compact exhaustion.

---

## 11. Discussion and future work

The starting conjecture — that "compact Hausdorff, open line, isolated nullity" forces the natural topology — is **false** as stated (circle model), **still false** after adding density (flip model), and **true** after adding an orientation of the two ends (Theorem 5.2). The classification (Theorem 7.5) closes the space of models under the density hypothesis: there are exactly two, the end compactification and its flip. Consequently the sharpness statements about the division boundary split into the two grades of Section 8.

Four directions follow.

**1. An ends functor for arbitrary locally compact carriers.** The argument used only three facts about $\mathbb{R}$: local compactness, that the complement of a compact core has exactly two components, and that those components are connected. Replacing "two rays" by "the components of the complements of a compact exhaustion" should give a functorial statement: finite-remainder compactifications of a locally compact Hausdorff space with finitely many ends are exactly the quotients of its end compactification. The skeleton — ray separation, forced neighbourhood bases, compact-to-Hausdorff comparison — is already stated in terms that survive the generalisation.

**2. Arithmetic rigidity: does the algebra see the topology?** The flip ambiguity is a purely *topological* symmetry, and transreal arithmetic breaks it: $\mathrm{fin}(1)\cdot(+\infty) = +\infty$ while $\mathrm{fin}(1)\cdot(-\infty) = -\infty$, and the flip involution does not commute with multiplication by a positive scalar. So the orientation that topology cannot supply may be derivable from the requirement that multiplication be separately continuous. With the classification in hand, the conjecture "a transreal compactification with separately continuous multiplication is the natural topology" reduces to a single computation on the flip model.

**3. Guard necessity as an invariant of the remainder.** The circle model repairs $1/y$ precisely because it identifies the two ends, i.e. because its remainder is a quotient of the end space. This suggests a general theorem: an unbounded continuous real function $f$ extends continuously to a compactification if and only if the compactification's remainder separates the limit behaviour of $f$ along the ends. Both instances of the dichotomy — the reciprocal across the interval and across the circle — are established here and serve as test cases.

**4. The lattice of transreal compactifications without the nullity axiom.** Isolation of nullity was used only to keep the uncovered compact core inside the line. Dropping it should enlarge the space of models to a lattice in which $\Phi$ may itself be attached to the line, and the natural next question is whether that lattice has a largest element and how the two grades of sharpness behave across it.

---

## 12. Summary of results

* **Definition.** A *transreal compactification* is a compact Hausdorff topology on $\mathbb{T} = \mathbb{R} \sqcup \{\pm\infty\} \sqcup \{\Phi\}$ in which $\mathrm{fin}$ is an open embedding and $\{\Phi\}$ is open.
* **Theorem 5.2 / 5.3.** A topology on $\mathbb{T}$ is the natural topology $\overline{\mathbb{R}} \sqcup \{\Phi\}$ if and only if it is a transreal compactification whose infinities are oriented ends.
* **Theorem 6.1.** The circle model — the line compactified by the single point named $-\infty$, with $+\infty$ and $\Phi$ isolated — is a transreal compactification different from the natural one; the four axioms alone are therefore insufficient.
* **Theorem 6.2.** The flip model is a transreal compactification with no isolated exceptional point other than $\Phi$, different from the natural one; density is therefore also insufficient.
* **Theorem 7.5.** Every transreal compactification with no isolated infinity is the natural topology or its flip: a two-point-remainder compactification of the line with both remainder points limit points is the end compactification, up to the labelling of the ends.
* **Theorem 8.1.** Discontinuity of $x \mapsto x/x$ holds in every $T_1$ model.
* **Theorem 8.2.** No value repairs $y \mapsto 1/y$ at the origin in any model with two honest ends.
* **Theorem 8.3.** In the circle model the reciprocal *is* repairable at the origin, uniquely, by the merged infinity.
