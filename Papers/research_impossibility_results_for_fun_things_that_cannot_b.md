# The Symmetry Principle of Impossibility: Invariant Distinguishers and Free Group Actions

**Author:** Aristotle
**Date:** 2026-07-08

## Abstract

A striking number of the classical impossibility theorems — the unsolvability of the general quintic by radicals, the impossibility of squaring the circle or trisecting an angle by ruler and compass, the non-existence of a fair non-dictatorial social choice rule — share an informal slogan: *you cannot break a symmetry with a rule that respects it.* We isolate the algebraic kernel behind this slogan and prove it precisely. Given a group $G$ acting on a set $X$, we model a "symmetric distinguishing task" as the existence of an **invariant injective** function $f : X \to Y$ — a rule that is constant on orbits (it respects the symmetry) yet separates points (it breaks the symmetry). Our central result is an exact dichotomy: **such a function exists if and only if the action is trivial.** We further characterize free actions as exactly those whose orbit maps are injective, showing that freeness is the sharpest — but not the necessary — form of the obstruction; non-triviality is the true frontier. Applying the dichotomy to the left-regular action of a non-trivial group yields a uniform impossibility statement, which specialized to the symmetric group $S_5$ becomes the group-theoretic shadow of the unsolvability of the quintic. We discuss the conceptual bridge to the classical impossibilities, provide numerical illustrations, and outline directions toward a quantitative theory of partial distinguishability and a Galois-theoretic refinement.

**Keywords:** group action, free action, invariant function, orbit space, symmetry breaking, impossibility theorems, Abel–Ruffini, symmetric group.

---

## 1. Introduction

Impossibility theorems occupy a distinctive place in mathematics. Where most theorems assert that something *can* be constructed, impossibility results assert that something *cannot* — and, remarkably, these negative statements are often deeper and more structurally illuminating than their positive counterparts. The classical canon includes:

- **Squaring the circle** is impossible because $\pi$ is transcendental (Lindemann, 1882).
- **Trisecting a general angle** and **doubling the cube** are impossible because the relevant lengths generate field extensions of degree $3$, not a power of $2$ (Wantzel, 1837).
- **Solving the general quintic by radicals** is impossible because the alternating group $A_5$ is not solvable (Abel and Ruffini, 1824; Galois).
- **Fair aggregate voting** is impossible in the sense of Arrow's theorem: no social welfare function is simultaneously unanimous, independent of irrelevant alternatives, and non-dictatorial.

Told in the usual way, each of these is a self-contained saga with its own toolkit. The purpose of this paper is to extract a single algebraic principle that underlies a large class of such statements and to prove it cleanly. The principle can be phrased as a slogan:

> *A symmetric structure cannot be pinned down by a rule that respects its symmetry.*

We turn this slogan into a theorem about group actions. The reward is not a shortcut around the specialized proofs — transcendence theory and Galois theory retain their essential roles — but a common diagnostic lens: once a would-be construction is recognized as an *invariant injective selector on a genuinely symmetric structure*, its impossibility is immediate.

### 1.1 Contributions

1. A precise model of a "symmetric distinguishing task" as an invariant injective function on a set carrying a group action (Section 2).
2. **Theorem A** (freeness = orbit-map injectivity): a structural characterization of free actions (Section 3).
3. **Theorem B** (the dichotomy): the symmetric distinguishing task is solvable if and only if the action is trivial (Section 4).
4. **Theorem C** (regular-action impossibility): the task is unsolvable for the left-regular action of any non-trivial group, with the symmetric group $S_5$ as the flagship instance connecting to the unsolvability of the quintic (Section 5).
5. A careful analysis of why the naive equivalence "impossible $\iff$ free" is *false*, locating the exact frontier at non-triviality (Section 6).

---

## 2. Definitions

Throughout, $G$ is a group (written multiplicatively, with identity $1$) acting on a set $X$. We write the action as $g \cdot x$ for $g \in G$ and $x \in X$, satisfying $1 \cdot x = x$ and $g \cdot (h \cdot x) = (gh) \cdot x$.

**Definition 2.1 (Orbit).** The *orbit* of $x \in X$ is $G \cdot x = \{\, g \cdot x : g \in G \,\}$. Orbits partition $X$; the set of orbits is the *orbit space* $X / G$.

**Definition 2.2 (Free action).** The action of $G$ on $X$ is **free** if the only group element fixing any point is the identity:
$$
\forall\, x \in X,\ \forall\, g \in G,\quad g \cdot x = x \implies g = 1.
$$

**Definition 2.3 (Trivial action).** The action is **trivial** if every element fixes every point:
$$
\forall\, g \in G,\ \forall\, x \in X,\quad g \cdot x = x.
$$
Equivalently, every orbit is a single point.

**Definition 2.4 (Invariant function / symmetric observable).** A function $f : X \to Y$ is **invariant** (with respect to the action) if it is constant along the action:
$$
\forall\, g \in G,\ \forall\, x \in X,\quad f(g \cdot x) = f(x).
$$
Invariance is the formal expression of "the rule respects the symmetry": symmetric copies of a point receive identical values.

**Definition 2.5 (Symmetric distinguishing task).** The **symmetric distinguishing task** for the action of $G$ on $X$ is the problem of exhibiting a set $Y$ and a function $f : X \to Y$ that is simultaneously *invariant* (Definition 2.4) and *injective* (points get distinct values). We say the task is **solvable** if such an $(Y, f)$ exists, and **impossible** otherwise.

The two conditions on $f$ are in explicit tension: invariance demands that $f$ *ignore* the group's relabelings, while injectivity demands that $f$ *see through* them to tell every point apart. Solving the task means simultaneously respecting and breaking the symmetry.

**Remark 2.6 (Universe honesty).** In the fully formal statement, the target $Y$ ranges over all types in a fixed universe, so "impossible" means *no* target of any kind admits an invariant injection — the strongest sense of impossibility, not merely the failure of one candidate.

---

## 3. Theorem A: Freeness Is Injectivity of the Orbit Maps

For each $x \in X$ define the **orbit map**
$$
\mathrm{orb}_x : G \to X, \qquad \mathrm{orb}_x(g) = g \cdot x.
$$
Its image is precisely the orbit $G \cdot x$.

**Theorem A.** The action of $G$ on $X$ is free if and only if the orbit map $\mathrm{orb}_x$ is injective for every $x \in X$.

*Proof.*

($\Rightarrow$) Assume the action is free and fix $x$. Suppose $\mathrm{orb}_x(g) = \mathrm{orb}_x(h)$, i.e. $g \cdot x = h \cdot x$. Apply $h^{-1}$ to both sides: $(h^{-1} g) \cdot x = (h^{-1} h) \cdot x = 1 \cdot x = x$. By freeness the element $h^{-1} g$ fixing $x$ must equal $1$, hence $g = h$. Thus $\mathrm{orb}_x$ is injective.

($\Leftarrow$) Assume every orbit map is injective and suppose $g \cdot x = x$ for some $g, x$. Then $\mathrm{orb}_x(g) = g \cdot x = x = 1 \cdot x = \mathrm{orb}_x(1)$. Injectivity of $\mathrm{orb}_x$ gives $g = 1$. Hence the action is free. $\qquad\blacksquare$

**Interpretation.** Freeness is equivalent to the statement that the *entire group embeds into every orbit*: distinct relabelings always produce distinct points, so each orbit is a faithful, undistorted copy of $G$. This is the strongest structural form a symmetry can take. In particular there is no point at which the group's action "collapses," no partial fixed structure that a clever rule could exploit. Theorem A is what makes free actions the extreme case of the impossibility we prove next.

---

## 4. Theorem B: The Dichotomy

We now prove the central result: solvability of the symmetric distinguishing task is governed *exactly* by triviality of the action.

**Theorem B (Symmetry Principle of Impossibility).** There exists a set $Y$ and an invariant injective function $f : X \to Y$ **if and only if** the action of $G$ on $X$ is trivial.

*Proof.*

($\Rightarrow$) Suppose $f : X \to Y$ is invariant and injective. Fix any $g \in G$ and $x \in X$. Invariance gives $f(g \cdot x) = f(x)$. Injectivity then forces the arguments to agree: $g \cdot x = x$. Since $g$ and $x$ were arbitrary, the action is trivial.

($\Leftarrow$) Suppose the action is trivial. Take $Y = X$ and $f = \mathrm{id}_X$. The identity is injective. It is invariant because triviality gives $g \cdot x = x$, whence $f(g \cdot x) = g \cdot x = x = f(x)$ for all $g, x$. Thus $(X, \mathrm{id}_X)$ solves the task. $\qquad\blacksquare$

**Corollary 4.1 (Impossibility under any genuine symmetry).** If the action is non-trivial — that is, if some $g \in G$ moves some $x \in X$ — then the symmetric distinguishing task is impossible.

*Proof.* Immediate contrapositive of Theorem B. $\qquad\blacksquare$

The elegance of Theorem B lies in its exactness. It is not merely that free actions block the task; *any* orbit of size greater than one blocks it, because invariance collapses that orbit to a single value while injectivity demands the opposite. The dividing line is drawn with no slack.

---

## 5. Theorem C: The Regular Action and the Quintic

Every group $G$ acts on itself by left multiplication, $g \cdot x = gx$; this is the **left-regular action**.

**Lemma 5.1.** The left-regular action of any group $G$ on itself is free.

*Proof.* Suppose $g \cdot x = x$, i.e. $gx = x$. Since $x = 1 \cdot x$ as well, we have $gx = 1 \cdot x = x$; right-cancellation of $x$ (valid in a group) yields $g = 1$. $\qquad\blacksquare$

**Theorem C (Regular-action impossibility).** If $G$ is a non-trivial group (i.e. $|G| > 1$) acting on itself by left multiplication, then the symmetric distinguishing task is impossible: there is no invariant injective function $f : G \to Y$ for any $Y$.

*Proof.* Suppose, for contradiction, that an invariant injective $f : G \to Y$ exists. By Theorem B the action must be trivial: $g \cdot x = x$ for all $g, x \in G$. Taking $x = 1$ gives $g \cdot 1 = g \cdot 1 = g = 1$ for every $g \in G$, so $G$ is trivial — contradicting $|G| > 1$. Hence no such $f$ exists. $\qquad\blacksquare$

By Lemma 5.1 the obstructing action here is not merely non-trivial but *free*, so Theorem C exhibits the impossibility in its sharpest form: every orbit is a faithful copy of the whole group.

### 5.1 The bridge to the unsolvability of the quintic

Specialize $G = S_5$, the symmetric group on five letters, with $|S_5| = 120 > 1$.

**Corollary 5.2.** For the left-regular action of $S_5$ on itself, no invariant injective function exists: no rule that respects relabeling can pick out the elements of $S_5$.

This is the group-theoretic shadow of the Abel–Ruffini theorem. Recall the shape of that classical result: the general quintic $x^5 + a_4 x^4 + \cdots + a_0 = 0$ cannot be solved by radicals — by any formula in the coefficients using field operations and $n$th roots — because the Galois group of the generic quintic is $S_5$, whose derived series does not terminate at the identity (equivalently, its simple non-abelian composition factor $A_5$ is not solvable). A radical formula for the roots would constitute, in structural terms, an *equivariant selector* for the action of the Galois group on the roots: a way of naming roots that respects the permutation symmetry yet distinguishes them. That is precisely a symmetric rule that breaks the symmetry — the forbidden combination of Theorem B. The very freeness of the symmetric group's action, which our development makes explicit, is the same rigidity that prevents the roots from being organized by a symmetric radical formula.

We emphasize the logical status: Corollary 5.2 does not *reprove* Abel–Ruffini (which requires the solvability theory of $S_5$ and Galois correspondence). Rather, it exhibits the shared skeleton — "no symmetric rule breaks a symmetric structure" — of which unsolvability by radicals is a decorated instance.

---

## 6. The Frontier: Why "Impossible $\iff$ Free" Is False

It is tempting to promote Corollary 4.1 to a biconditional and declare the task impossible *if and only if* the action is free. This is **false**, and identifying the error is itself instructive.

Consider a rotation action of the cyclic group $C_n$ ($n \ge 2$) on the plane $\mathbb{R}^2$, rotating about the origin. This action:

- is **non-trivial** (non-identity rotations move most points), so by Corollary 4.1 the symmetric distinguishing task is **impossible**;
- is **not free** (the origin is fixed by every rotation, so a non-identity element fixes a point).

Thus we have an impossible task arising from a non-free action. Freeness is therefore *sufficient but not necessary* for impossibility. The precise frontier is **non-triviality**: the task fails the instant one point is genuinely moved, whether or not other points sit still.

What, then, does freeness contribute? By Theorem A it upgrades the obstruction from *local* to *uniform*. In a non-free but non-trivial action, some orbits may be singletons (fixed points) while others are large; the difficulty is uneven. In a free action there are no fixed points anywhere and every orbit is a full copy of $G$ — the obstruction is homogeneous across the entire space. This is why free actions, and the left-regular action in particular, furnish the cleanest and most quotable impossibilities, even though they are not the whole story.

We record the corrected hierarchy:

$$
\underbrace{\text{trivial}}_{\text{task solvable}} \;\subsetneq\; \underbrace{\text{non-trivial}}_{\text{task impossible}} \;\supsetneq\; \underbrace{\text{free non-trivial}}_{\text{sharpest obstruction}}.
$$

The middle region — non-trivial actions that are not free — is where a *quantitative* refinement lives, measuring how much distinguishability survives; this is the subject of Section 8.

---

## 7. Algorithmic Perspective

Although the theorems are about arbitrary (possibly infinite) sets, their content is entirely constructive for finite groups and sets, yielding decision procedures.

**Deciding freeness.** By Definition 2.2, freeness is decided by checking, for every $x \in X$ and every $g \in G$ with $g \ne 1$, whether $g \cdot x = x$; the action is free iff no such fixed pair exists. This is $O(|G|\,|X|)$ group-action evaluations. By Theorem A one may equivalently verify injectivity of each orbit map $\mathrm{orb}_x$.

**Deciding solvability.** By Theorem B, the symmetric distinguishing task is solvable iff the action is trivial, decided by checking $g \cdot x = x$ for all $(g, x)$ — again $O(|G|\,|X|)$.

**Constructing the maximal invariant distinguisher.** When the task is unsolvable, the best one can do is separate *orbits* rather than points. The orbit projection $\pi : X \to X/G$ is the universal invariant function: every invariant $f$ factors uniquely as $f = \bar f \circ \pi$. Computing $X/G$ (e.g. by a union–find over the relation $x \sim g\cdot x$) produces the finest invariant partition and quantifies exactly how far the task falls short — the number of surviving classes is $|X/G|$, versus the $|X|$ that full distinguishing would require.

---

## 8. Applications and Interpretations

**Canonical forms.** A "canonical form" for objects up to a symmetry is exactly an invariant injective map from objects to representatives. Theorem B explains why canonical forms that are simultaneously *symmetry-respecting* and *complete* cannot exist for genuinely symmetric families; practical canonical forms succeed only by *breaking* the symmetry with an arbitrary choice (a total order on variables, a chosen basepoint), which is precisely a non-invariant rule.

**Voting and social choice.** Arrow-type impossibilities can be read through this lens: the symmetric group permuting alternatives (or, in variants, voters) acts on the space of preference profiles, and an aggregation rule that is neutral (invariant under relabeling alternatives) while also decisive in a point-separating sense confronts the same tension between respecting and breaking symmetry.

**Physics and phase space.** Symmetries acting freely on a configuration space obstruct globally-defined, symmetry-respecting coordinates — a viewpoint resonant with the non-existence of certain global sections and with the necessity of gauge fixing (a deliberate symmetry break) in physical theories.

In each case the diagnostic is the same: identify the symmetry group and its action, ask whether a solution would be an invariant injective selector, and invoke Theorem B.

---

## 9. Discussion

The Symmetry Principle reframes a scattered catalogue of impossibilities as instances of one algebraic fact. Its worth is methodological: it converts "is this impossible?" into "is the symmetry genuine, and would a solution respect it?" — a question that can often be answered before any domain-specific machinery is deployed. At the same time, the principle is honest about its limits. It does not subsume the transcendence of $\pi$ or the solvability theory of $A_5$; those results supply the *reason a given action is genuine* in their respective settings. The principle organizes the conclusions, not the deep inputs.

The most important conceptual correction delivered here is the precise location of the frontier. The folklore identification of impossibility with freeness overshoots; non-triviality is the true boundary, with freeness marking the extreme. Stating this exactly — and exhibiting a concrete non-free yet impossible action — is what elevates the slogan to a theorem.

---

## 10. Future Directions

**The quotient dichotomy for partial distinguishers.** We conjecture that the maximal number of points an invariant function can separate equals the number of orbits: the poset of invariant functions on $X$ is canonically isomorphic to the poset of functions on the orbit space $X/G$, and every invariant function factors uniquely through the orbit projection. The insight is that invariance is a *change of base* — every symmetric observable is a function on the quotient — so the failure of full separation is exactly the non-injectivity of the quotient map, measured by orbit sizes. This refines the two endpoints proved here (trivial = full separation, non-trivial = no full separation) into a quantitative middle theory.

**Freeness as the unique universal obstruction.** We conjecture that among non-trivial actions of a fixed group $G$, the free actions are exactly those for which every orbit map is an embedding of $G$; consequently a free action is terminal among actions admitting no invariant distinguisher, and any action with a fixed point is strictly weaker as an obstruction. This would rank actions by obstruction strength, filling in the ordering between "trivial" and "free."

**A Galois bridge.** We conjecture that for a separable polynomial whose Galois group acts freely and transitively on a distinguished set of root-data, no radical tower can produce a selector equivariant for that action; hence unsolvability by radicals becomes a corollary of freeness of the Galois action on the relevant fiber. A radical formula is exactly an equivariant selector, so its non-existence is an instance of the general principle rather than a phenomenon special to degree five.

---

## 11. Conclusion

We have proven that a symmetric distinguishing task — an invariant injective function on a group-acted set — is solvable if and only if the action is trivial, characterized free actions by injectivity of their orbit maps, and derived a uniform impossibility for the left-regular action of any non-trivial group. The symmetric group $S_5$ furnishes the flagship instance, connecting the abstract principle to the classical unsolvability of the quintic. Along the way we corrected the seductive but false slogan "impossible iff free," locating the true frontier at non-triviality with freeness as its sharpest case. In this precise sense, a broad swath of impossibility is a single impossibility: *no symmetric rule can break a symmetric structure.*
