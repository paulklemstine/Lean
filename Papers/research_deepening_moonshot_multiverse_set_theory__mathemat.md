# The Combinatorial Core of the Set-Theoretic Multiverse

## Abstract

We develop a self-contained, elementary model of the combinatorial heart of the set-theoretic *multiverse* — the view, associated with Joel David Hamkins, that there is no single universe of sets but a plurality of models of set theory, connected by forcing and disagreeing on independent statements such as the Continuum Hypothesis. We abstract a model of set theory to a **world**: a truth assignment to a fixed collection of atomic set-theoretic assertions. **Sentences** are propositional combinations of atoms; a **multiverse** is a collection of worlds; and a sentence is **independent** in a multiverse when it holds in one world and fails in another. Forcing is modeled by the **flip** operation, which toggles the truth value of a single atom, and a multiverse is **forcing-closed** when stable under all flips. Our central theorem states that *in any nonempty forcing-closed multiverse, every atomic sentence is independent* — forcing settles nothing. We complement this with an absoluteness theorem (the laws of classical logic are valid across every multiverse), a full analysis of a concrete three-atom instance modeling $\mathrm{CH}$, $V=L$, and the existence of a measurable cardinal, and the result that the Continuum Hypothesis remains independent even after adopting the true implication $(V=L)\Rightarrow\mathrm{CH}$ as a law of the multiverse. We conclude with the counting fact that the full multiverse over $n$ atoms has exactly $2^n$ worlds, and with a program of extensions toward first-order signatures, Boolean-valued models, genuine forcing posets, and the modal logic of forcing.

**Keywords:** set-theoretic multiverse, Continuum Hypothesis, forcing, independence, absoluteness, propositional semantics, Boolean-valued models.

## 1. Introduction

### 1.1 Background and motivation

Two of the twentieth century's landmark theorems concern the *limits* of what the standard axioms of set theory (ZFC) can decide. Gödel (1940) proved that the Continuum Hypothesis $\mathrm{CH}$ — the assertion that there is no cardinality strictly between that of the integers and that of the reals — is *consistent* with ZFC, by constructing the constructible universe $L$ in which $\mathrm{CH}$ holds. Cohen (1963) proved the complementary result that $\lnot\mathrm{CH}$ is also consistent, by inventing **forcing**, a method for extending a model of ZFC by a generic object that decides $\mathrm{CH}$ negatively. Together these results show $\mathrm{CH}$ is *independent* of ZFC: neither it nor its negation is provable.

The classical reading treats independence as an incompleteness — a defect to be resolved, ideally, by discovering the "right" new axioms. The **multiverse** perspective, articulated by Hamkins, offers a different interpretation: there is no privileged universe of sets, but rather a vast plurality of set-theoretic universes, each a legitimate context for mathematics, connected to one another by constructions such as forcing. On this view, $\mathrm{CH}$ does not have a hidden true value awaiting discovery; it simply holds in some universes and fails in others, and the network of universes — the multiverse — is itself the proper object of study.

### 1.2 Contribution

Hamkins' multiverse is a rich philosophical and mathematical program. Our aim is narrow and rigorous: to isolate the *combinatorial core* of the phenomenon of independence-under-forcing and prove sharp theorems about it from first principles. We deliberately abstract away the internal structure of models of ZFC, retaining only the data relevant to independence — the *answers* a universe gives to a fixed list of yes/no questions. This abstraction is spare enough to make every claim provable by elementary means, yet expressive enough to capture:

1. **Absoluteness of logic** (Section 4): the classical propositional validities hold across *every* multiverse.
2. **The headline theorem** (Section 6): in any nonempty forcing-closed multiverse, every atomic sentence is independent.
3. **A concrete instance** (Section 7): the independence of $\mathrm{CH}$ and $V=L$ in the two-world multiverse $\{\text{Gödel}, \text{Cohen}\}$; the validity of $(V=L)\Rightarrow\mathrm{CH}$; and the robustness of $\mathrm{CH}$'s independence even after adopting that implication as a law.
4. **Counting** (Section 8): the full multiverse over $n$ atoms has $2^n$ worlds.

Everything is developed from a single elementary semantics, and the results are stated so as to be directly checkable.

## 2. The language of the multiverse

### 2.1 Atoms, sentences, and worlds

Fix a type $\alpha$ of **atomic assertions**. Intuitively these are the primitive set-theoretic yes/no statements we wish to track — e.g. $\mathrm{CH}$, $V=L$, "there is a measurable cardinal."

**Definition 2.1 (Sentence).** The set $\mathrm{Sentence}(\alpha)$ of **sentences over $\alpha$** is generated inductively:

- for each atom $a \in \alpha$, $\mathrm{atom}(a)$ is a sentence;
- $\top$ (true) and $\bot$ (false) are sentences;
- if $p$ is a sentence, so is $\lnot p$ (negation);
- if $p, q$ are sentences, so are $p \land q$ (conjunction), $p \lor q$ (disjunction), and $p \Rightarrow q$ (implication).

**Definition 2.2 (World).** A **world** over $\alpha$ is a function $w : \alpha \to \{\texttt{true}, \texttt{false}\}$, i.e. a truth assignment to the atoms. A world is our abstraction of a model of set theory: it records precisely the truth values that model assigns to the atomic assertions.

**Definition 2.3 (Evaluation).** Each world $w$ extends to an evaluation map $\mathrm{eval}_w : \mathrm{Sentence}(\alpha) \to \{\texttt{true},\texttt{false}\}$ by structural recursion:

$$
\begin{aligned}
\mathrm{eval}_w(\mathrm{atom}(a)) &= w(a), &
\mathrm{eval}_w(\top) &= \texttt{true}, &
\mathrm{eval}_w(\bot) &= \texttt{false},\\
\mathrm{eval}_w(\lnot p) &= \lnot\,\mathrm{eval}_w(p), &
\mathrm{eval}_w(p \land q) &= \mathrm{eval}_w(p) \wedge \mathrm{eval}_w(q),\\
\mathrm{eval}_w(p \lor q) &= \mathrm{eval}_w(p) \vee \mathrm{eval}_w(q), &
\mathrm{eval}_w(p \Rightarrow q) &= \lnot\,\mathrm{eval}_w(p) \vee \mathrm{eval}_w(q).
\end{aligned}
$$

Here the operations on the right are the Boolean connectives on $\{\texttt{true},\texttt{false}\}$.

**Definition 2.4 (Satisfaction).** A world $w$ **satisfies** a sentence $p$, written $w \models p$, when $\mathrm{eval}_w(p) = \texttt{true}$.

The following equivalences are immediate from the definition of $\mathrm{eval}$ and constitute the basic calculus of satisfaction; we use them freely.

**Lemma 2.5 (Satisfaction clauses).** For any world $w$ and sentences $p, q$:

- $w \models \mathrm{atom}(a) \iff w(a) = \texttt{true}$;
- $w \models \top$ always, and $w \not\models \bot$;
- $w \models \lnot p \iff w \not\models p$;
- $w \models p \land q \iff (w \models p \text{ and } w \models q)$;
- $w \models p \lor q \iff (w \models p \text{ or } w \models q)$;
- $w \models p \Rightarrow q \iff (w \models p \text{ implies } w \models q)$.

*Proof.* Each clause is a direct unfolding of $\mathrm{eval}$, with the implication clause verified by exhausting the four truth-value combinations of $p$ and $q$. $\square$

### 2.2 Multiverses and the three fates of a sentence

**Definition 2.6 (Multiverse).** A **multiverse** over $\alpha$ is a collection $M$ of worlds, i.e. a subset $M \subseteq (\alpha \to \{\texttt{true},\texttt{false}\})$.

**Definition 2.7 (Valid, refutable, independent, settled).** Fix a multiverse $M$ and a sentence $p$.

- $p$ is **valid** in $M$ if $w \models p$ for every $w \in M$.
- $p$ is **refutable** in $M$ if $w \not\models p$ for every $w \in M$.
- $p$ is **independent** in $M$ if there exist $w_1, w_2 \in M$ with $w_1 \models p$ and $w_2 \not\models p$.
- $p$ is **settled** in $M$ if it is valid or refutable in $M$.

These are the three exhaustive-but-not-mutually-exhaustive fates a sentence can have relative to a given multiverse. (Over a *nonempty* $M$, "valid," "refutable," and "independent" are mutually exclusive and jointly exhaustive; over the empty multiverse a sentence is vacuously both valid and refutable.)

## 3. The grammar of independence

The interaction of the four notions above is governed by a handful of structural lemmas, proved directly from Definitions 2.6–2.7.

**Proposition 3.1.** Let $p$ be independent in $M$. Then:

1. $p$ is not valid in $M$;
2. $p$ is not refutable in $M$;
3. $p$ is not settled in $M$.

*Proof.* (1) Independence supplies $w_2 \in M$ with $w_2 \not\models p$, contradicting validity. (2) Independence supplies $w_1 \in M$ with $w_1 \models p$, contradicting refutability. (3) Settledness is validity or refutability, both excluded by (1),(2). $\square$

**Proposition 3.2.** If $p$ is valid in $M$, then $p$ is not independent in $M$.

*Proof.* Immediate from Proposition 3.1(1) by contraposition. $\square$

**Proposition 3.3 (Independence is negation-symmetric).** A sentence $p$ is independent in $M$ if and only if $\lnot p$ is.

*Proof.* By Lemma 2.5, $w \models \lnot p \iff w \not\models p$. Thus a pair of worlds witnessing the independence of $p$ (one satisfying, one refuting) is, with the roles exchanged, exactly a pair witnessing the independence of $\lnot p$, and vice versa. $\square$

These facts show that independence is a robust, well-behaved notion: it is incompatible with any form of settledness and is preserved under negation.

## 4. Absoluteness: the laws of logic hold everywhere

Before studying disagreement, we identify what *cannot* be disagreed upon. The propositional tautologies are valid in *every* multiverse — they are the absolute skeleton beneath all branches.

**Theorem 4.1 (Absoluteness of classical logic).** For every multiverse $M$ and every sentence $p$:

1. **Excluded middle:** $p \lor \lnot p$ is valid in $M$.
2. **Non-contradiction:** $\lnot(p \land \lnot p)$ is valid in $M$.
3. **Self-implication:** $p \Rightarrow p$ is valid in $M$.

*Proof.* Fix any $w \in M$; we show $w$ satisfies each sentence. In every world $\mathrm{eval}_w(p)$ is either $\texttt{true}$ or $\texttt{false}$. (1) In both cases $\mathrm{eval}_w(p) \vee \lnot\mathrm{eval}_w(p) = \texttt{true}$, so $w \models p \lor \lnot p$ by Lemma 2.5. (2) Similarly $\lnot(\mathrm{eval}_w(p) \wedge \lnot\mathrm{eval}_w(p)) = \texttt{true}$ in both cases. (3) $\lnot\mathrm{eval}_w(p)\vee\mathrm{eval}_w(p)=\texttt{true}$ in both cases. Since $w \in M$ was arbitrary, each sentence is valid. $\square$

**Interpretation.** Theorem 4.1 draws the fundamental line of the multiverse view. The plurality of universes is a plurality of *mathematical content*, not of *logic*. No matter how the branches disagree about $\mathrm{CH}$ or large cardinals, they agree without exception on the propositional validities. The multiverse is lawful, not anarchic.

## 5. Forcing as a flip

We now model the operation that *generates* independence. Cohen forcing extends a model of ZFC by a generic filter, producing a new model that decides a target statement the opposite way while preserving much of the old model's structure. Its combinatorial shadow — the only feature relevant to the truth values of atoms — is that it *toggles* the targeted atom.

Throughout this section we assume equality of atoms is decidable (automatic for the finite atom-types of interest).

**Definition 5.1 (Flip / generic extension).** For a world $w$ and an atom $a$, the **flip of $w$ at $a$** is the world

$$
\mathrm{flip}(w, a)(x) = \begin{cases} \lnot\, w(a), & x = a, \\ w(x), & x \neq a. \end{cases}
$$

It agrees with $w$ on every atom except $a$, whose value it negates. This is the abstraction of a generic extension targeting $a$.

**Lemma 5.2 (Flip toggles its target).** For every world $w$ and atom $a$,

$$\mathrm{flip}(w,a) \models \mathrm{atom}(a) \iff w \not\models \mathrm{atom}(a).$$

Moreover $\mathrm{flip}(w,a)(x) = w(x)$ for all $x \neq a$.

*Proof.* By Definition 5.1, $\mathrm{flip}(w,a)(a) = \lnot w(a)$, so $\mathrm{flip}(w,a) \models \mathrm{atom}(a) \iff \lnot w(a) = \texttt{true} \iff w(a) = \texttt{false} \iff w \not\models \mathrm{atom}(a)$. The agreement off $a$ is the second case of the definition. $\square$

**Definition 5.3 (Forcing-closed multiverse).** A multiverse $M$ is **forcing-closed** if it is stable under all flips:

$$\forall w \in M,\ \forall a \in \alpha,\quad \mathrm{flip}(w,a) \in M.$$

This is the combinatorial abstraction of the multiverse axiom that every universe admits forcing extensions realizing the opposite of any forceable statement. A forcing-closed multiverse never contains a universe without also containing all of its one-step forcing neighbors.

## 6. The headline theorem: forcing settles nothing

**Theorem 6.1 (Forcing settles nothing).** Let $M$ be a nonempty forcing-closed multiverse. Then every atomic sentence $\mathrm{atom}(a)$ is independent in $M$.

*Proof.* Fix an atom $a$. Since $M$ is nonempty, choose $w \in M$. Since $M$ is forcing-closed, $\mathrm{flip}(w,a) \in M$ (Definition 5.3). By Lemma 5.2, exactly one of $w$ and $\mathrm{flip}(w,a)$ satisfies $\mathrm{atom}(a)$ and the other does not. Concretely: if $w(a)=\texttt{true}$ then $w \models \mathrm{atom}(a)$ and $\mathrm{flip}(w,a) \not\models \mathrm{atom}(a)$; if $w(a)=\texttt{false}$ then $\mathrm{flip}(w,a) \models \mathrm{atom}(a)$ and $w \not\models \mathrm{atom}(a)$. In either case $M$ contains a world satisfying $\mathrm{atom}(a)$ and a world refuting it, so $\mathrm{atom}(a)$ is independent. $\square$

**Corollary 6.2 (Nothing atomic is settled).** In a nonempty forcing-closed multiverse, no atomic sentence is settled.

*Proof.* Immediate from Theorem 6.1 and Proposition 3.1(3). $\square$

This is the central phenomenon of the multiverse, made precise: once a collection of universes is closed under the very operation (forcing) that generates independence, *forcing decides nothing*. Every primitive question splits into a "yes" branch and a "no" branch. Independence is not exceptional; it is generic.

### 6.1 The full multiverse

The maximal forcing-closed multiverse is the one containing every conceivable world.

**Definition 6.3 (Full multiverse).** The **full multiverse** over $\alpha$ is $\mathrm{full}(\alpha) = \{\, w : w \text{ a world over } \alpha \,\}$, the set of all worlds.

**Proposition 6.4.** The full multiverse is forcing-closed, and (whenever a world exists) nonempty. Consequently every atomic sentence is independent in $\mathrm{full}(\alpha)$.

*Proof.* Forcing-closure is trivial: $\mathrm{flip}(w,a)$ is a world, hence already in $\mathrm{full}(\alpha)$. Nonemptiness holds as soon as the type of worlds is inhabited. The last claim is Theorem 6.1. $\square$

**Proposition 6.5 (Joint realizability).** For distinct atoms $a \neq b$, the compound sentence $\mathrm{atom}(a) \land \lnot\,\mathrm{atom}(b)$ is independent in $\mathrm{full}(\alpha)$.

*Proof.* The world assigning $\texttt{true}$ exactly to $a$ satisfies $a$ and (since $a \neq b$) refutes $b$, hence satisfies $a \land \lnot b$. The world assigning $\texttt{false}$ everywhere refutes $a$, hence refutes $a \land \lnot b$. Both worlds lie in $\mathrm{full}(\alpha)$, witnessing independence. $\square$

Proposition 6.5 shows the full multiverse realizes *all four* joint truth-patterns of any two distinct atoms; the branches are as rich as the language allows.

## 7. A concrete multiverse: $\mathrm{CH}$, $V=L$, and a measurable cardinal

We instantiate the framework with three atoms and reproduce the classical independence facts.

**Definition 7.1.** Let the atom-type be $\mathrm{Claim} = \{\mathrm{CH}, V{=}L, \mathrm{Meas}\}$, where $\mathrm{CH}$ is the Continuum Hypothesis, $V{=}L$ the axiom of constructibility, and $\mathrm{Meas}$ the assertion "there exists a measurable cardinal." Define two distinguished worlds:

$$
\text{Gödel}: \ \mathrm{CH}\mapsto\texttt{true},\ V{=}L\mapsto\texttt{true},\ \mathrm{Meas}\mapsto\texttt{false};
$$
$$
\text{Cohen}: \ \mathrm{CH}\mapsto\texttt{false},\ V{=}L\mapsto\texttt{false},\ \mathrm{Meas}\mapsto\texttt{false}.
$$

The Gödel world models the constructible universe $L$: constructibility holds, hence $\mathrm{CH}$ holds, and $L$ has no measurable cardinal. The Cohen world models a Cohen extension violating $\mathrm{CH}$ (and hence $V=L$). Let $GC = \{\text{Gödel}, \text{Cohen}\}$ be the two-world multiverse.

**Theorem 7.2 (Independence of $\mathrm{CH}$).** The Continuum Hypothesis $\mathrm{atom}(\mathrm{CH})$ is independent in $GC$.

*Proof.* Gödel satisfies $\mathrm{CH}$ (its value there is $\texttt{true}$); Cohen refutes it (its value there is $\texttt{false}$). Both worlds are in $GC$. $\square$

**Theorem 7.3 (Independence of $V=L$).** The axiom of constructibility $\mathrm{atom}(V{=}L)$ is independent in $GC$.

*Proof.* True in Gödel, false in Cohen. $\square$

**Theorem 7.4 (A law of the multiverse).** The implication $(V{=}L) \Rightarrow \mathrm{CH}$ is valid in $GC$.

*Proof.* We check both worlds. In Gödel, $V{=}L$ and $\mathrm{CH}$ are both true, so the implication holds. In Cohen, $V{=}L$ is false, so the implication holds vacuously. Hence it holds in every world of $GC$. $\square$

Theorem 7.4 exhibits a settled *dependence* coexisting with unsettled *facts*: the branches disagree on $\mathrm{CH}$ yet agree that constructibility would entail it. This is the formal counterpart of the classical theorem that $V=L$ implies $\mathrm{CH}$.

**The law does not settle $\mathrm{CH}$.** One might hope to decide $\mathrm{CH}$ by discarding worlds that violate the law $(V{=}L)\Rightarrow\mathrm{CH}$. Let

$$\mathrm{LawMV} = \{\, w : w \models (V{=}L) \Rightarrow \mathrm{CH} \,\}$$

be the sub-multiverse of law-abiding worlds. Both Gödel and Cohen lie in $\mathrm{LawMV}$: Gödel satisfies the implication with true hypothesis and true conclusion, Cohen satisfies it vacuously.

**Theorem 7.5 ($\mathrm{CH}$ stays independent under the law).** The Continuum Hypothesis is independent in $\mathrm{LawMV}$.

*Proof.* Gödel and Cohen both belong to $\mathrm{LawMV}$ (verified above), and they disagree on $\mathrm{CH}$: Gödel satisfies it, Cohen refutes it. Hence $\mathrm{CH}$ is independent in $\mathrm{LawMV}$. $\square$

Adopting a *true* implication as a standing law fails to collapse the branches, because the branches already respected it. The independence of $\mathrm{CH}$ is robust against this natural attempt to eliminate it.

**Theorem 7.6 (A compound with a model).** In the full multiverse over $\mathrm{Claim}$, the sentence $\mathrm{CH} \land \lnot(V{=}L)$ is independent; in particular it has a model.

*Proof.* By Proposition 6.5 applied to the distinct atoms $\mathrm{CH} \neq V{=}L$. The witnessing world (assigning $\texttt{true}$ only to $\mathrm{CH}$) models a Cohen-style situation in which $\mathrm{CH}$ is forced while non-constructible reals are added, so $V=L$ fails. $\square$

## 8. Counting worlds

Finally, a clean enumerative fact quantifies the size of the multiverse.

**Theorem 8.1 (Cardinality of the full multiverse).** If there are $n$ atomic assertions (i.e. $\alpha$ is finite with $|\alpha| = n$), then the full multiverse has exactly $2^n$ worlds:

$$|\mathrm{full}(\alpha)| = 2^{|\alpha|}.$$

*Proof.* A world is a function $\alpha \to \{\texttt{true},\texttt{false}\}$, and the number of functions from an $n$-element set to a $2$-element set is $2^n$. $\square$

**Corollary 8.2.** Over the three atoms $\mathrm{Claim} = \{\mathrm{CH}, V{=}L, \mathrm{Meas}\}$, the full multiverse has exactly $8$ worlds.

*Proof.* $2^3 = 8$. $\square$

## 9. Discussion

The model isolates three provable messages of the multiverse view.

1. **A lawful floor.** Theorem 4.1 guarantees that classical logic is absolute: the multiverse is a plurality of *content*, never of *logic*. This distinguishes principled pluralism from relativism.

2. **Generic independence.** Theorem 6.1 shows that once a collection of universes is closed under forcing, independence is the rule rather than the exception — forcing settles no atomic question. This is the mathematical crux of why, on the multiverse view, questions like $\mathrm{CH}$ do not have hidden absolute answers.

3. **Structured (dis)agreement.** Section 7 shows that branches can share firm laws (Theorem 7.4) while remaining divided on the facts those laws constrain (Theorem 7.5). Independence is robust: it cannot be legislated away by adopting laws the branches already obey.

**Scope and honest limitations.** The model is deliberately propositional: worlds are truth assignments, not full structures, and forcing is abstracted to a single-atom flip. This captures the *combinatorics* of independence but not its *proof-theoretic* content — nothing here shows that $\mathrm{CH}$ is *actually* independent of ZFC (that is the deep Gödel–Cohen theorem, imported here as the design of the Gödel and Cohen worlds). What the model does is make the *structure* of the multiverse — validity, refutability, independence, forcing-closure, and their interactions — completely explicit and verifiable. It is a faithful skeleton, not a substitute for the full theory.

## 10. Future directions

Six natural extensions carry the abstraction toward the full theory.

1. **Quantified sentences over a signature.** Replace the atomic-assertion type by a genuine first-order language and interpret worlds as structures, recovering the propositional layer as the atomic-diagram fragment. This lets independence be stated for actual first-order sentences.

2. **A Boolean/Heyting algebra of multiverse truth values.** Map each sentence to the set of worlds satisfying it; validity, refutability, and independence become the top, bottom, and proper-nontrivial elements of a Boolean algebra of "multiverse propositions." Proving the assignment is a Boolean homomorphism is a first step toward Boolean-valued models.

3. **Forcing posets, not just single flips.** Generalize the flip to a partial order of finite conditions with a genericity notion, and prove a discrete Rasiowa–Sikorski-style existence lemma. This bridges the abstraction to real forcing.

4. **Consistency-strength ordering.** Introduce a preorder on worlds/theories by interpretability and study the multiverse as an ordered structure (the large-cardinal hierarchy). Prove that the settled sentences form a filter closed under modus ponens.

5. **Dependence relations.** Formalize when one sentence's truth constrains another's across a multiverse (as $(V=L)\Rightarrow\mathrm{CH}$ does), and characterize the settled fragment as the deductive closure of the multiverse's shared theory.

6. **Modal logic of forcing.** Interpret "forceable" as a modality on the forcing-closed multiverse and identify the resulting propositional modal logic (Hamkins–Löwe show it is $S4.2$ for actual forcing); test which modal schemes hold in the abstract flip model.

## References

- G. Cantor, *Contributions to the Founding of the Theory of Transfinite Numbers*, 1895/1897.
- K. Gödel, *The Consistency of the Continuum Hypothesis*, Princeton University Press, 1940.
- P. J. Cohen, *The Independence of the Continuum Hypothesis*, Proc. Natl. Acad. Sci. USA, 1963.
- J. D. Hamkins, *The set-theoretic multiverse*, The Review of Symbolic Logic, 2012.
- J. D. Hamkins and B. Löwe, *The modal logic of forcing*, Trans. Amer. Math. Soc., 2008.
