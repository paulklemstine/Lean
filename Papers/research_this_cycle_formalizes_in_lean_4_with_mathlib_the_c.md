# The Modal Logic and Alexandrov Topology of the Forcing Multiverse

## Abstract

We study the combinatorial and topological core of the modal logic of forcing in the set-theoretic multiverse. Modeling the class of worlds as an abstract Kripke frame with an accessibility relation $R$ read as "*is a forcing extension of*," we equip assertions with the necessity operator $\Box$ ("true in every extension") and the possibility operator $\Diamond$ ("true in some extension"). We establish the full Sahlqvist correspondence between the modal axioms $\mathbf{T}, \mathbf{4}, \mathbf{B}, \mathbf{5}, \mathbf{.2}$ and the frame conditions of reflexivity, transitivity, symmetry, the Euclidean property, and directedness, each as an exact biconditional. Instantiating with the directed order $(\mathbb{N}, \le)$ yields a faithful model validating $\mathsf{S4.2}$ while refuting $\mathsf{S5}$, exhibiting the loss of symmetry as the precise mechanism separating the Hamkins–Löwe logic of forcing from $\mathsf{S5}$. We then develop the button/switch dichotomy: over reflexive frames the buttons are exactly the fixed points of $\Box$ and form a distributive lattice, while in the fully connected multiverse the switches are exactly the non-constant assertions and are disjoint from the non-trivial buttons. On the quantitative side we count, over $n$ atoms, the $2^n$ branches, $2^{2^n}$ sentences, and exactly two settled sentences, whence $2^{2^n} - 2$ independent sentences and a proportion of independent sentences tending to $1$. Finally we build the bridge to topology: the upward-closed assertions form the **Alexandrov topology** of $R$; over a preorder $\Box$ is the interior operator and $\Diamond$ the closure operator; buttons are exactly the open sets, settled assertions exactly the clopen sets; the space is Alexandrov-discrete; and in the fully connected multiverse the only clopen sets are the two constants — the topological face of the count of settled sentences.

## 1. Introduction

The technique of *forcing*, introduced by Cohen to establish the independence of the Continuum Hypothesis, constructs from any model of set theory a larger model — a *forcing extension* — in which some prescribed statement holds. Iterating and amalgamating these constructions gives rise to the picture of a branching **set-theoretic multiverse**: a class of worlds partially ordered by extension. Hamkins and Löwe asked which modal principles govern the operators "in every forcing extension" and "in some forcing extension," and proved that the valid such principles form exactly the modal logic $\mathsf{S4.2}$.

This paper isolates and develops the *combinatorial and topological core* of that theory in a self-contained way. We work with an abstract accessibility relation and prove three families of results:

1. **Frame correspondences (Section 3).** A complete Sahlqvist dictionary between modal axioms and frame conditions, culminating in an explicit $\mathsf{S4.2}$-but-not-$\mathsf{S5}$ model.
2. **Buttons and switches (Section 4).** The lattice structure of buttons and the characterization of switches.
3. **The counting law of independence (Section 5).** An exact count showing that independence is generic.

We then unify these strands through topology (Section 6), showing that necessity and possibility are the interior and closure operators of the Alexandrov topology of the extension order, that buttons are the open sets and settled assertions the clopen sets, and that the space is Alexandrov-discrete.

## 2. Definitions

Throughout, $W$ is a type of *worlds* and $R : W \to W \to \mathrm{Prop}$ is an *accessibility relation*; we read $R\,w\,v$ as "$v$ is a forcing extension of $w$." An **assertion** is a predicate $P : W \to \mathrm{Prop}$, identified when convenient with the set $\{w : P\,w\}$.

**Definition 2.1 (Modal operators).** For an assertion $P$ and a world $w$,
$$\Box P\,(w) \;:\equiv\; \forall v,\ R\,w\,v \to P\,v, \qquad \Diamond P\,(w) \;:\equiv\; \exists v,\ R\,w\,v \wedge P\,v.$$
Thus $\Box P$ holds at $w$ iff $P$ holds in every extension of $w$, and $\Diamond P$ holds at $w$ iff $P$ holds in some extension.

**Definition 2.2 (Frame conditions).** The relation $R$ is
- *reflexive* if $R\,w\,w$ for all $w$;
- *transitive* if $R\,w\,v$ and $R\,v\,u$ imply $R\,w\,u$;
- *symmetric* if $R\,w\,v$ implies $R\,v\,w$;
- *Euclidean* if $R\,w\,v$ and $R\,w\,u$ imply $R\,v\,u$;
- *directed (confluent)* if for all $w, v, u$ with $R\,w\,v$ and $R\,w\,u$ there exists $t$ with $R\,v\,t$ and $R\,u\,t$.

A *preorder* is a reflexive and transitive relation.

**Definition 2.3 (Buttons and switches).** An assertion $S$ is a **button** if it is stable along accessibility: $R\,w\,v$ and $w \in S$ imply $v \in S$. It is a **switch** (in a given multiverse) if from every world it can be forced true and forced false. An assertion is **settled** if its truth value is invariant along accessibility in both directions.

## 3. Frame correspondences and the $\mathsf{S4.2}$/$\mathsf{S5}$ separation

We prove that each standard modal axiom, quantified over all assertions, holds precisely when $R$ satisfies the matching frame condition. Each statement is a biconditional, capturing both directions of the Sahlqvist correspondence.

**Theorem 3.1 (T ↔ reflexive).** $(\forall P\, w,\ \Box P\,(w) \to P\,w)$ holds if and only if $R$ is reflexive.

*Proof sketch.* If $R$ is reflexive and $\Box P\,(w)$ holds, apply the definition to $v := w$ using $R\,w\,w$. Conversely, apply the axiom at the specific assertion $P := R\,w\,(\cdot)$: from reflexive-free hypotheses one extracts $R\,w\,w$ by feeding $\Box P\,(w)$, which holds because $R\,w\,v \to R\,w\,v$. $\square$

**Theorem 3.2 (4 ↔ transitive).** $(\forall P\,w,\ \Box P\,(w) \to \Box\Box P\,(w))$ holds iff $R$ is transitive.

*Proof sketch.* Transitivity gives, from $R\,w\,v$ and $R\,v\,u$, that $R\,w\,u$, so $\Box P\,(w)$ propagates two steps. Conversely instantiate at $P := R\,w\,(\cdot)$ to recover transitivity. $\square$

**Theorem 3.3 (B ↔ symmetric).** $(\forall P\,w,\ P\,w \to \Box\Diamond P\,(w))$ holds iff $R$ is symmetric.

*Proof sketch.* If $R$ is symmetric and $w \in P$, then for any $v$ with $R\,w\,v$ we have $R\,v\,w$, so $\Diamond P\,(v)$ is witnessed by $w$ itself. Conversely, at $P := \{w\}$ the axiom forces $R\,v\,w$ from $R\,w\,v$. $\square$

**Theorem 3.4 (5 ↔ Euclidean).** $(\forall P\,w,\ \Diamond P\,(w) \to \Box\Diamond P\,(w))$ holds iff $R$ is Euclidean.

**Theorem 3.5 (.2 ↔ directed).** $(\forall P\,w,\ \Diamond\Box P\,(w) \to \Box\Diamond P\,(w))$ holds iff $R$ is directed.

*Proof sketch.* Suppose $R$ directed and $\Diamond\Box P\,(w)$: there is $v$ with $R\,w\,v$ and $\Box P\,(v)$. To show $\Box\Diamond P\,(w)$, take any $u$ with $R\,w\,u$; directedness yields a common extension $t$ with $R\,v\,t$ and $R\,u\,t$; then $P\,t$ holds because $\Box P\,(v)$, so $\Diamond P\,(u)$ is witnessed by $t$. The converse instantiates the axiom at a suitable assertion to synthesize the amalgam. $\square$

**Theorem 3.6 (The $\mathsf{S4.2}$/$\mathsf{S5}$ separation).** The order $(\mathbb{N}, \le)$ is reflexive, transitive, and directed, but neither symmetric nor Euclidean. Hence axioms $\mathbf{T}, \mathbf{4}, \mathbf{.2}$ all hold while $\mathbf{B}$ and $\mathbf{5}$ both fail.

*Proof sketch.* Reflexivity, transitivity, and directedness (via the maximum of two numbers) are standard. Symmetry fails since $0 \le 1$ but $1 \not\le 0$; the Euclidean property fails likewise. By Theorems 3.1–3.5 the corresponding axioms hold or fail accordingly. $\square$

Since $\mathsf{S5} = \mathsf{S4} + \mathbf{B}$ and $\mathsf{S4.2} = \mathsf{S4} + \mathbf{.2}$, Theorem 3.6 shows that the **loss of symmetry** is exactly the frame-theoretic mechanism dropping $\mathsf{S5}$ to the Hamkins–Löwe logic $\mathsf{S4.2}$: forcing is irreversible, and irreversibility is the failure of $\mathbf{B}$.

## 4. Buttons and switches

**Theorem 4.1 (Buttons are the fixed points of necessity).** Over a reflexive frame, an assertion $S$ is a button if and only if $w \in S \iff \Box S\,(w)$ for every world $w$.

*Proof sketch.* If $S$ is a button and $w \in S$, then every extension $v$ satisfies $v \in S$, so $\Box S\,(w)$; conversely $\Box S\,(w)$ gives $w \in S$ by reflexivity. For the reverse implication, the fixed-point property directly yields stability. $\square$

**Theorem 4.2 (Buttons form a distributive lattice).** If $S$ and $T$ are buttons then so are $S \cap T$ and $S \cup T$, and the distributive law $S \cap (T \cup U) = (S \cap T) \cup (S \cap U)$ holds.

*Proof sketch.* Stability is preserved by intersection and union directly from Definition 2.3; distributivity is the pointwise distributivity of $\wedge$ over $\vee$. $\square$

**Theorem 4.3 (Switches are the non-constant assertions).** In the fully connected multiverse (every world accessing every world), an assertion is a switch if and only if it is non-constant — true at some world and false at some world.

*Proof sketch.* Full connectivity means any world can reach any target; a non-constant assertion therefore has both a true witness and a false witness reachable from anywhere, so it can be forced either way. Conversely a constant assertion cannot be flipped. $\square$

**Theorem 4.4 (Switches are not non-trivial buttons).** A genuine switch is never a non-trivial button.

*Proof sketch.* A button that can be forced false from a world where it is true would violate stability; hence a switch fails the button condition unless trivial. $\square$

## 5. Independence is generic

We now count. Fix $n$ atoms.

**Definition 5.1.** A **branch** over $n$ atoms is a function $\mathrm{Fin}\,n \to \mathrm{Bool}$; a **sentence** is a function from branches to $\mathrm{Bool}$. A sentence is **settled** if it is constant.

**Theorem 5.2 (Counting).** The number of branches is $2^n$; the number of sentences is $2^{2^n}$; the number of settled sentences is exactly $2$; hence the number of independent (non-settled) sentences is $2^{2^n} - 2$.

*Proof sketch.* There are $2^n$ functions $\mathrm{Fin}\,n \to \mathrm{Bool}$, and $2^{(2^n)}$ functions from the $2^n$-element set of branches to $\mathrm{Bool}$. The settled sentences are precisely the two constant functions $\top$ and $\bot$; their complement in the sentence set has cardinality $2^{2^n} - 2$. $\square$

**Theorem 5.3 (Independence is generic).** The proportion of independent sentences tends to $1$:
$$\frac{2^{2^n} - 2}{2^{2^n}} = 1 - \frac{2}{2^{2^n}} \longrightarrow 1 \quad (n \to \infty).$$

*Proof sketch.* The correction term $2 / 2^{2^n} \to 0$ because $2^{2^n} \to \infty$. $\square$

Thus, in the space of all sentences over finitely many atoms, decidable statements are a vanishing minority: **undecidability is the typical case.**

## 6. The Alexandrov topology of the multiverse

We now unify the preceding results through topology.

**Definition 6.1 (Upper set).** An assertion $S$ is an **upper set** for $R$ if $R\,w\,v$ and $w \in S$ imply $v \in S$. (These are exactly the buttons of Definition 2.3.)

**Definition 6.2 (Alexandrov topology).** The **Alexandrov topology** of $R$ declares a set open iff it is an upper set. This is a topology for *any* relation $R$: the whole space and empty set are trivially upper sets, and upper sets are closed under arbitrary unions and (finite or arbitrary) intersections.

**Theorem 6.3 (Necessity is interior).** If $R$ is a preorder, then for every assertion $S$ the interior of $S$ in the Alexandrov topology equals $\{w : \Box S\,(w)\}$.

*Proof sketch.* The set $\{w : \Box S\,(w)\}$ is open (upper) by transitivity and is contained in $S$ by reflexivity, so it is contained in the interior. Conversely the interior, being open, is stable and lies inside $S$, hence at each of its points $\Box S$ holds. Antisymmetry of $\subseteq$ concludes. $\square$

**Theorem 6.4 (Possibility is closure).** If $R$ is a preorder, then for every assertion $S$ the closure of $S$ equals $\{w : \Diamond S\,(w)\}$.

*Proof sketch.* Dual to Theorem 6.3: $\{w : \Diamond S\,(w)\}$ is closed (its complement is upper by transitivity) and contains $S$ by reflexivity, so it contains the closure; conversely any closed set containing $S$ must contain every $\Diamond S$-point, via the characterization of closure by intersection with open neighborhoods. $\square$

**Corollary 6.5 (Idempotence of necessity).** Over a preorder, $\Box\Box S = \Box S$, reflecting the topological identity $\mathrm{int}(\mathrm{int}(S)) = \mathrm{int}(S)$.

**Theorem 6.6 (Buttons are the open sets).** Over a reflexive frame, an assertion $S$ is a button (fixed by $\Box$) if and only if it is open in the Alexandrov topology.

*Proof sketch.* Openness is upward-closure, which is exactly stability; combined with Theorem 4.1 this identifies buttons with open sets. $\square$

**Theorem 6.7 (Settled assertions are the clopen sets).** An assertion $S$ is settled — its truth value is invariant along accessibility, i.e. $R\,w\,v \to (w \in S \iff v \in S)$ — if and only if it is **clopen** (both open and closed) in the Alexandrov topology.

*Proof sketch.* Invariance in the forward direction is openness (upper set); invariance in the backward direction is closedness (the complement is an upper set). Their conjunction is exactly clopenness. $\square$

**Theorem 6.8 (Alexandrov-discreteness).** The Alexandrov topology of any $R$ is *Alexandrov-discrete*: arbitrary intersections of open sets are open.

*Proof sketch.* An arbitrary intersection of upper sets is an upper set: if $w$ lies in every member and $R\,w\,v$, then $v$ lies in every member. $\square$

This is the structural fingerprint distinguishing preorder-topologies from ordinary ones, and it is exactly what lets $\Box$ and $\Diamond$ be computed pointwise.

**Theorem 6.9 (The fully connected multiverse is topologically indiscrete).** If $W$ is nonempty and $R$ is total (every world accessing every world — the symmetric $\mathsf{S5}$ situation), then the only clopen sets are $\varnothing$ and $W$. Equivalently, the only settled assertions are the two truth-constants.

*Proof sketch.* By Theorem 6.7 a clopen set is invariant along $R$; totality makes any two worlds mutually accessible, so an invariant set has constant truth value, hence is empty or everything. $\square$

Theorem 6.9 is the **topological face of the count of settled sentences** (Theorem 5.2): "exactly two settled sentences" becomes "exactly two clopen sets," and the $2^{2^n} - 2$ independent sentences become the contingent — non-clopen — assertions.

## 7. Algorithms

The counting and correspondence results are effective. We highlight three procedures, given in full in the accompanying code:

1. **Sentence classifier.** Given a Boolean function on branches, decide whether it is settled (constant) or independent by scanning its truth table; the two settled sentences are the all-true and all-false tables.
2. **Independence census.** For each $n$, enumerate branches ($2^n$) and sentences ($2^{2^n}$), count settled sentences (always $2$), and report the exact independent count $2^{2^n} - 2$ and the ratio $1 - 2^{1-2^n}$.
3. **Frame-condition checker.** Given a finite relation $R$, test reflexivity, transitivity, symmetry, the Euclidean property, and directedness, and hence report which modal axioms $\mathbf{T}, \mathbf{4}, \mathbf{B}, \mathbf{5}, \mathbf{.2}$ it validates, and whether the frame is $\mathsf{S4.2}$-but-not-$\mathsf{S5}$.

## 8. Applications and discussion

The results give a clean, self-contained account of *why* the modal logic of forcing is $\mathsf{S4.2}$: the forcing order is a directed preorder that fails symmetry, and each of these properties corresponds exactly to a modal axiom. The button/switch dichotomy organizes assertions into those with an arrow of time (buttons, an open-set distributive lattice) and those freely reversible (switches, the non-constant assertions), while the counting law shows independence to be statistically overwhelming. The topological bridge reveals all of this as a single object: an Alexandrov-discrete space in which necessity and possibility are interior and closure, buttons are open sets, and settled assertions are clopen sets.

## 9. Future work

- **Specialization preorder.** Reconstruct $R$ from the Alexandrov topology alone via the specialization preorder, making the correspondence an equivalence between forcing frames and Alexandrov spaces.
- **Irreducibility and .2.** Show that directedness is equivalent to topological irreducibility, so that $\mathsf{S4.2}$ is the logic of irreducible Alexandrov spaces and $\mathsf{S5}$ that of the indiscrete ones.
- **Boolean subalgebra of settled assertions.** Prove that settled assertions form a Boolean subalgebra and that the independent assertions form a topologically dense complement, upgrading generic independence to Baire-style genericity.
- **Intermediate logics.** Realize every modal logic between $\mathsf{S4}$ and $\mathsf{S5}$ as the interior-operator logic of a suitable class of spaces.
- **Law adoption as unit propagation.** Model finitely many implications among atoms and prove that the number of newly settled atoms equals the unit-propagation closure of the implication graph.

## 10. Conclusion

Logic, combinatorics, and topology here describe one and the same object. The passage between mathematical universes obeys the logic $\mathsf{S4.2}$, pinned down by the exact geometry of the forcing order; the special assertions form clean algebraic and topological structures; undecidability is generic; and the whole picture is unified by the Alexandrov topology, in which necessity is interior, possibility is closure, buttons are open, and the settled assertions are the two clopen constants.
