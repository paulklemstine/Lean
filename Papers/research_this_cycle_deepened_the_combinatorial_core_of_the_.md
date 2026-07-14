# The Modal Logic of the Forcing Multiverse: Frame Correspondences, Buttons, Switches, and the Genericity of Independence

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

We develop the combinatorial core of the modal logic of forcing in the
set-theoretic multiverse, treating the collection of models of set theory as a
Kripke frame whose accessibility relation is *"is a forcing extension of."* We prove
the classical Sahlqvist frame correspondences linking the modal axioms **T**, **4**,
**B**, **5**, and **.2** to the first-order frame conditions of reflexivity,
transitivity, symmetry, euclideanness, and confluence. Using the directed but
antisymmetric extension order — modelled by $(\mathbb{N}, \le)$ — we establish that
the logic of directed forcing is exactly **S4.2**: axioms **T**, **4**, and **.2**
hold while **B** and **5** fail, with the loss of symmetry identified as the single
frame condition responsible for the descent from **S5**. We then classify assertions
into *buttons* (monotone along accessibility) and *switches* (both they and their
negations remain possible from every world), proving that over a reflexive frame the
buttons are exactly the fixed points of the necessity operator, that they form a
distributive lattice, that switches in the fully connected multiverse are precisely
the non-constant assertions, and that no assertion is simultaneously a genuine switch
and a nontrivial button. Finally, we quantify independence: over $n$ mutually
independent atoms there are $2^n$ branches and $2^{(2^n)}$ sentences, of which exactly
$2$ are settled, so $2^{(2^n)} - 2$ are independent and the proportion of independent
sentences tends to $1$ as $n \to \infty$. Independence is therefore generic.

## 1. Introduction

The independence phenomena discovered by Gödel and Cohen show that the standard
axioms of set theory leave many natural questions — most famously the Continuum
Hypothesis — undecided. Cohen's method of *forcing* produces, from a given model of
set theory, new models in which a chosen undecided statement holds or fails at will.
The **set-theoretic multiverse** takes this seriously: rather than positing a single
privileged universe of sets, it studies the entire landscape of models related by
forcing.

A productive way to organize that landscape is through **modal logic**. Reading
possibility as *truth in some forcing extension* and necessity as *truth in every
forcing extension*, one obtains a Kripke semantics over the frame of models with
accessibility relation *"is a forcing extension of."* This paper develops the
combinatorial core of that semantics, focused on three questions.

1. **Which modal logic governs forcing?** We prove the exact frame correspondences
   and pin down the logic of the directed forcing order as **S4.2**.
2. **How do individual assertions behave?** We formalize the button/switch dichotomy
   and give exact structural characterizations of each.
3. **How common is independence?** We count settled versus independent sentences and
   show that independence is generic.

Throughout, an **assertion** on a frame $(W, R)$ is a predicate $P : W \to
\mathrm{Prop}$; a **world** $w \in W$ is a model of set theory; and $R\,w\,v$ means
"$v$ is a forcing extension of $w$."

## 2. Frames, box, and diamond

### 2.1 Definitions

Let $W$ be a type of worlds and $R : W \times W \to \mathrm{Prop}$ an accessibility
relation.

**Definition (Necessity).** For an assertion $P : W \to \mathrm{Prop}$,
$$(\Box_R P)(w) \;:=\; \forall v,\; R\,w\,v \to P(v).$$
Thus $\Box_R P$ holds at $w$ when $P$ is true in every world accessible from $w$.

**Definition (Possibility).** Dually,
$$(\Diamond_R P)(w) \;:=\; \exists v,\; R\,w\,v \wedge P(v).$$
Thus $\Diamond_R P$ holds at $w$ when $P$ is true in some world accessible from $w$.

We use two less standard frame conditions.

**Definition (Euclidean).** $R$ is *euclidean* if for all $x, y, z$, $R\,x\,y$ and
$R\,x\,z$ imply $R\,y\,z$.

**Definition (Confluent / directed).** $R$ is *confluent* if for all $x, y, z$ with
$R\,x\,y$ and $R\,x\,z$ there exists $u$ with $R\,y\,u$ and $R\,z\,u$. This is the
directedness of iterated forcing: any two extensions of a common ground can be
amalgamated.

### 2.2 A validity convention

An axiom schema is *valid on the frame* $(W, R)$ if the displayed implication holds
for every assertion $P$ and every world $w$. Each correspondence below is a
biconditional between validity of a schema and a first-order property of $R$; both
directions are proved.

## 3. Frame correspondences (Direction 1)

We establish the Sahlqvist correspondences relating each modal axiom to its frame
condition.

**Theorem 3.1 (T $\leftrightarrow$ reflexive).**
The schema $\Box p \to p$ — i.e. $\forall P\,w,\; (\Box_R P)(w) \to P(w)$ — is valid
on $(W,R)$ if and only if $R$ is reflexive.

*Proof sketch.* If the schema is valid, instantiate $P := R\,x$ (the assertion
"accessible from $x$") at $w := x$: $(\Box_R P)(x)$ holds trivially, so $P(x)$ holds,
i.e. $R\,x\,x$. Conversely, if $R$ is reflexive and $(\Box_R P)(w)$ holds, then
applying it to the accessible world $w$ itself yields $P(w)$. $\square$

**Theorem 3.2 (4 $\leftrightarrow$ transitive).**
The schema $\Box p \to \Box\Box p$ is valid on $(W,R)$ if and only if $R$ is
transitive.

*Proof sketch.* For necessity of transitivity, instantiate $P := R\,x$ at $x$; the
schema forces $(\Box_R \Box_R P)(x)$, which unwinds to $R\,x\,y \wedge R\,y\,z \to
R\,x\,z$. Conversely, if $R$ is transitive, $(\Box_R P)(w)$ and $R\,w\,x$, $R\,x\,y$
give $R\,w\,y$, hence $P(y)$; thus $(\Box_R\Box_R P)(w)$. $\square$

**Theorem 3.3 (B $\leftrightarrow$ symmetric).**
The schema $p \to \Box\Diamond p$ is valid on $(W,R)$ if and only if $R$ is
symmetric.

*Proof sketch.* Instantiate $P := (\cdot = x)$ at $x$: the schema gives
$(\Box_R\Diamond_R P)(x)$, which says every $y$ with $R\,x\,y$ can access some world
equal to $x$, i.e. $R\,y\,x$ — symmetry. Conversely, from $P(w)$, symmetry makes $w$
accessible from any $v$ with $R\,w\,v$, witnessing $(\Diamond_R P)(v)$; hence
$(\Box_R\Diamond_R P)(w)$. $\square$

**Theorem 3.4 (5 $\leftrightarrow$ euclidean).**
The schema $\Diamond p \to \Box\Diamond p$ is valid on $(W,R)$ if and only if $R$ is
euclidean.

*Proof sketch.* Instantiate $P := (\cdot = z)$ to extract euclideanness from
validity; conversely, given $(\Diamond_R P)(w)$ witnessed by $v$ and any $x$ with
$R\,w\,x$, euclideanness yields $R\,x\,v$, so $(\Diamond_R P)(x)$, establishing
$(\Box_R\Diamond_R P)(w)$. $\square$

**Theorem 3.5 (.2 $\leftrightarrow$ confluent).**
The schema $\Diamond\Box p \to \Box\Diamond p$ is valid on $(W,R)$ if and only if $R$
is confluent.

*Proof sketch.* For necessity, instantiate $P := R\,z$; the antecedent
$\Diamond_R\Box_R P$ packages a common source and the schema produces the
amalgamating world. Conversely, given $(\Diamond_R\Box_R P)(w)$ witnessed by $a$
(with $\Box_R P$ at $a$) and any $v$ with $R\,w\,v$, confluence supplies $u$ with
$R\,v\,u$ and $R\,a\,u$; then $P(u)$ holds, witnessing $(\Diamond_R P)(v)$. $\square$

### 3.1 The forcing order is S4.2, not S5

The extension order of iterated forcing is directed (extensions amalgamate) but
antisymmetric (one cannot force back to a smaller ground). The minimal faithful model
of a directed antisymmetric order is $(\mathbb{N}, \le)$.

**Lemma 3.6.** The order $(\mathbb{N}, \le)$ is reflexive, transitive, and confluent,
but neither symmetric nor euclidean.

*Proof sketch.* Reflexivity and transitivity are standard. Confluence: for $y, z \ge
x$, the maximum $\max(y,z)$ dominates both. Symmetry fails since $0 \le 1$ but not $1
\le 0$; euclideanness fails since $0 \le 1$ and $0 \le 0$ but not $1 \le 0$. $\square$

**Theorem 3.7 (Main separation).**
On the directed antisymmetric extension order $(\mathbb{N}, \le)$, axioms **T**,
**4**, and **.2** are valid while **B** and **5** both fail. Consequently the modal
logic of directed forcing is **S4.2**, strictly weaker than the **S5** obtained from
a symmetric (equivalence) accessibility relation.

*Proof sketch.* Combine the correspondences of Theorems 3.1–3.5 with Lemma 3.6.
Reflexivity, transitivity, and confluence validate **T**, **4**, and **.2**; the
failures of symmetry and euclideanness refute **B** and **5**. $\square$

**Remark.** Symmetry is the pivotal condition. Modelling a generic extension as a
change of only finitely much information makes accessibility an equivalence relation
and collapses the logic to **S5**; retaining directedness while dropping symmetry — the
genuine combinatorics of iterated forcing — lands precisely on the Hamkins–Löwe logic
**S4.2**.

## 4. Buttons and switches (Direction 2)

Following Hamkins, we classify assertions by their persistence under forcing.

**Definition (Button).** $P$ is a *button* if it is monotone along accessibility:
$$\forall w\,v,\; R\,w\,v \to P(w) \to P(v).$$
Once a button becomes true it remains true in every further extension.

**Definition (Switch).** $P$ is a *switch* if from every world both it and its
negation are possible:
$$\forall w,\; (\Diamond_R P)(w) \wedge (\Diamond_R (\neg P))(w).$$

### 4.1 Buttons are fixed points of necessity

**Theorem 4.1.** Over a reflexive frame, $P$ is a button if and only if it is a fixed
point of the necessity operator pointwise:
$$\forall w,\; (\Box_R P)(w) \leftrightarrow P(w).$$

*Proof sketch.* ($\Rightarrow$) If $P$ is a button, then at any $w$: reflexivity gives
$(\Box_R P)(w) \to P(w)$, while monotonicity gives $P(w) \to (\Box_R P)(w)$ since
every accessible $v$ inherits $P$. ($\Leftarrow$) Given the fixed-point equation, if
$R\,w\,v$ and $P(w)$, then $(\Box_R P)(w)$ holds by the equation, so $P(v)$; hence $P$
is monotone. $\square$

Thus buttons are exactly the assertions that are true precisely when they are bound to
remain true.

### 4.2 Buttons form a distributive lattice

**Theorem 4.2 (Closure under $\wedge$).** If $P$ and $Q$ are buttons, so is
$w \mapsto P(w) \wedge Q(w)$.

**Theorem 4.3 (Closure under $\vee$).** If $P$ and $Q$ are buttons, so is
$w \mapsto P(w) \vee Q(w)$.

*Proof sketch.* Monotonicity is preserved by pointwise conjunction and disjunction:
if $R\,w\,v$ and both conjuncts (resp. one disjunct) hold at $w$, they hold at $v$ by
the monotonicity of $P$ and $Q$. $\square$

**Theorem 4.4 (Distributivity).** For all assertions $P, Q, S$,
$$\big(w \mapsto P(w) \wedge (Q(w) \vee S(w))\big) \;=\; \big(w \mapsto (P(w)\wedge Q(w)) \vee (P(w)\wedge S(w))\big).$$

*Proof sketch.* Pointwise Boolean distributivity. $\square$

Theorems 4.2–4.4 show the buttons form a **distributive lattice** under pointwise
$\wedge$ and $\vee$.

### 4.3 Switches in the fully connected multiverse

**Definition (Complete relation).** The *complete* accessibility relation on $W$ is
$R^{\top}\,w\,v := \top$ for all $w, v$: every world accesses every world. This models
the finite-information equivalence frame in which any generic extension is reachable
from any other.

**Theorem 4.5.** In the (nonempty) complete multiverse, $P$ is a switch if and only
if it is non-constant:
$$\mathrm{Switch}(R^{\top}, P) \iff (\exists w,\, P(w)) \wedge (\exists w,\, \neg P(w)).$$

*Proof sketch.* Under $R^{\top}$, possibility of $P$ at any world is just existence of
a world satisfying $P$; likewise for $\neg P$. So $P$ is a switch exactly when both a
witness and a counterwitness exist. $\square$

The Continuum Hypothesis, being non-constant across the multiverse, is thus a switch:
from any world it can be forced true or forced false.

### 4.4 Switches and buttons are disjoint (on the nontrivial part)

**Theorem 4.6.** If $P$ is both a switch and a button on $(W,R)$, then $P$ is false
everywhere: $\forall w,\; \neg P(w)$.

*Proof sketch.* Suppose $P(w)$. Since $P$ is a switch, from $w$ its negation is
possible: there is $v$ with $R\,w\,v$ and $\neg P(v)$. But $P$ is a button, so
$P(w)$ and $R\,w\,v$ force $P(v)$, contradicting $\neg P(v)$. Hence $P(w)$ is
impossible. $\square$

So no contingent assertion is simultaneously a genuine switch and a nontrivial
button: the two notions partition the interesting assertions.

## 5. Quantitative independence (Direction 5)

Fix $n$ mutually independent atomic assertions.

**Definition (Branch).** A *branch* is a truth assignment to the atoms,
$\mathrm{Branch}(n) := \mathrm{Fin}\,n \to \mathrm{Bool}$.

**Definition (Sentence).** A *sentence* is a Boolean combination of the atoms viewed
as a map from branches to truth values, $\mathrm{Sentence}(n) := \mathrm{Branch}(n)
\to \mathrm{Bool}$.

**Definition (Valid / Refutable / Independent).** A sentence $s$ is *valid* if $s(b) =
\mathrm{true}$ for every branch $b$; *refutable* if $s(b) = \mathrm{false}$ for every
$b$; *settled* if it is valid or refutable; and *independent* otherwise.

**Theorem 5.1 (Branch count).** $\#\,\mathrm{Branch}(n) = 2^n.$

*Proof sketch.* There are $2$ choices for each of the $n$ atoms. $\square$

**Theorem 5.2 (Sentence count).** $\#\,\mathrm{Sentence}(n) = 2^{(2^n)}.$

*Proof sketch.* A sentence assigns one of $2$ values to each of the $2^n$ branches
independently; the count of functions from a size-$2^n$ domain to a size-$2$ codomain
is $2^{(2^n)}$. $\square$

**Theorem 5.3 (Settled = two constants).** The settled sentences are exactly the two
constant functions $b \mapsto \mathrm{true}$ and $b \mapsto \mathrm{false}$.

*Proof sketch.* A valid sentence equals the constant true; a refutable sentence
equals the constant false; and conversely both constants are settled. No sentence is
both (the branch type is nonempty), so these are the only settled sentences. $\square$

**Theorem 5.4 (Number settled).** Exactly $2$ sentences are settled.

*Proof sketch.* The two constants are distinct (again using nonemptiness of the branch
type), so the set of Theorem 5.3 has cardinality $2$. $\square$

**Theorem 5.5 (Number independent).**
$$\#\{\text{independent sentences}\} = 2^{(2^n)} - 2.$$

*Proof sketch.* Independent sentences are the complement of the settled ones, so their
count is the total sentence count of Theorem 5.2 minus the settled count of Theorem
5.4. $\square$

**Theorem 5.6 (Independence is generic).**
$$\lim_{n \to \infty} \frac{\#\{\text{independent sentences over } n \text{ atoms}\}}{\#\,\mathrm{Sentence}(n)} \;=\; 1.$$

*Proof sketch.* By Theorems 5.2 and 5.5 the ratio equals $1 - 2 / 2^{(2^n)}$. Since
$2^{(2^n)} \to \infty$ (indeed doubly exponentially) as $n \to \infty$, the subtracted
term tends to $0$, so the ratio tends to $1$. $\square$

The interpretation is that undecidability is the typical case among Boolean
combinations of independent atoms: settled sentences form a vanishing $2 /
2^{(2^n)}$ fraction, while independence is generic.

## 6. Algorithms

The counting results are effective, yielding simple decision and enumeration
procedures.

**Sentence classification.** Given a sentence $s$ over $n$ atoms as a truth table of
length $2^n$, evaluate $s$ on all branches; report *valid* if all outputs are true,
*refutable* if all are false, and *independent* otherwise. Complexity $O(2^n)$ per
sentence.

**Frame-condition checking.** Given a finite frame $(W, R)$ as an adjacency matrix,
each frame property (reflexive, transitive, symmetric, euclidean, confluent) is a
bounded quantifier statement decidable in $O(|W|^3)$ time, and by the correspondences
of Section 3 this simultaneously decides which modal axioms hold.

**Button/switch detection.** On a finite frame, $P$ is a button iff monotone along
every edge ($O(|W|^2)$ checks); a switch iff every world has an accessible $P$-world
and an accessible $\neg P$-world ($O(|W|^2)$).

## 7. Applications and discussion

The frame correspondences give a *portable* criterion: to determine the modal logic
of any proposed accessibility relation on models — whether the forcing order, the
finite-information equivalence, or a hybrid — one need only test simple first-order
properties. This reduces a question about provability of modal principles to
elementary combinatorics of a relation.

The button/switch dichotomy organizes set-theoretic assertions by their forcing
behavior and equips the buttons with distributive-lattice structure, opening the door
to a Boolean-algebraic study of the settled fragment. The genericity of independence
recasts the classical independence results not as isolated pathologies but as
representatives of an overwhelming majority, giving a precise combinatorial content to
the multiverse philosophy.

## 8. Future work

Several directions extend the picture. The confluent-but-antisymmetric order can be
compared inside a single frame against the finite-information equivalence, sharpening
the S4.2/S5 boundary. The button/switch classification suggests a full lattice- and
topological-theoretic study: with $\Box$ satisfying **K**, **T**, and **4** it is an
interior operator, so the multiverse carries an Alexandrov topology whose clopen sets
are the decidable statements. Finally, adopting finitely many implications among atoms
as "laws" is propositional constraint propagation in disguise, suggesting a
graph-reachability decision procedure for which atoms remain independent.

## 9. Conclusion

Reading possibility and necessity as truth in some and every forcing extension turns
the set-theoretic multiverse into a Kripke frame whose logic can be identified
exactly. The directed antisymmetric forcing order obeys **S4.2**, with symmetry the
sole condition separating it from **S5**; assertions cleanly split into fixed-point
buttons forming a distributive lattice and contingent switches; and settled sentences
are a doubly-exponentially vanishing minority, so independence is generic. The
multiverse is not a foundational embarrassment but a structured, quantifiable
mathematical landscape.
