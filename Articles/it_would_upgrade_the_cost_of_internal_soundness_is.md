# Strange Loops Are Free

## What a self-referential sentence really costs the theory that hosts it

There is a picture of thought that Douglas Hofstadter made famous: the mind as a *tangled hierarchy*, a system of levels in which the top level somehow reaches back down and touches the bottom. A symbol stands for a pattern of neurons; the pattern of neurons computes the symbol. The strange loop is not a bug in the architecture — it is, on this view, the very thing that makes a self out of a machine.

The mathematician's reflex, on hearing this, is to worry. Self-reference has a bad reputation, honestly earned. "This sentence is false" is a demolition charge: assume it true and it is false, assume it false and it is true. Tarski proved that no reasonably rich language can contain its own truth predicate, and the standard lesson is that levels must be kept apart — a language may talk about a *lower* language, never about itself.

So here is the question this article is about. Suppose you have a perfectly good theory — say, a theory of arithmetic, or a database of facts, or the working knowledge of a reasoning agent — and you bolt onto it a tangled hierarchy: a collection of *names*, each of which denotes a sentence, together with an internal truth predicate saying, of each name, exactly when the sentence it denotes holds. The names are permitted to refer to each other, in loops, and to themselves. Does the old theory survive?

The answer turns out to be sharp, and sharper than the folklore suggests. **Under precise and rather generous conditions, the tangle costs the old theory nothing at all: not one new consequence in the old vocabulary.** Strange loops can be arbitrarily wild, arbitrarily deep, arbitrarily self-involved, and still leave the levels above them completely untouched. What they cost is something else entirely — not *soundness* but *definiteness*. And exactly where the guarantee fails, the liar is waiting.

---

## The setup: names, sentences, and one biconditional per name

Strip the problem to its bones. Fix a stock of ordinary atomic statements — call them $a_1, a_2, \dots$ — the vocabulary of the old theory. Formulas are built from these atoms, from falsehood $\bot$, and from implication $\to$; negation is the usual abbreviation $\neg\varphi := \varphi \to \bot$, and the biconditional $\varphi \leftrightarrow \psi$ abbreviates its usual definition in terms of these. Call a formula built only from atoms, $\bot$, and $\to$ **truth-free**: this is the *old language*, the language your theory was already speaking.

Now add something new. Fix a set of **names** $c, d, \dots$, and for each name a new atomic formula $T c$, read "the sentence named $c$ is true". A **tangled hierarchy** is a function $\mathrm{den}$ that assigns to each name $c$ a formula $\mathrm{den}(c)$ — the sentence that $c$ names. Crucially, $\mathrm{den}(c)$ is allowed to contain truth atoms, including $T c$ itself. The name may name a sentence about itself. It may name a sentence about a name that names a sentence about it. Loops of any length are permitted.

The theory attached to a tangled hierarchy is exactly what Tarski's schema demands: for each name $c$, the biconditional
$$T c \;\leftrightarrow\; \mathrm{den}(c).$$
Call this collection of biconditionals the **tangled theory**. It says nothing more than "the truth predicate is correct about every name". That is internal soundness, and internal completeness, in a single package.

The question of the article is now completely precise. Let $\mathcal{T}$ be any base theory of truth-free sentences and $\psi$ any truth-free sentence. Does $\mathcal{T}$ together with all the Tarski biconditionals prove $\psi$ only when $\mathcal{T}$ alone already does? If yes, we call the tangle **conservative** over $\mathcal{T}$: the new machinery answers no old question that was previously open, and — as a special case, taking $\psi$ to be $\bot$ — it cannot make a consistent theory inconsistent.

---

## The master key: conservativity is solvability

The first result is the one everything else hangs from, and it is disarmingly simple once seen.

> **Conservativity Criterion.** A tangled hierarchy is conservative over *every* truth-free base theory if and only if every assignment of truth values to the old atoms can be extended to an assignment of truth values to the names satisfying all the loop equations $T c \leftrightarrow \mathrm{den}(c)$.

The right-to-left direction is the useful one and its proof is three lines of honest bookkeeping. Suppose the tangled theory proves the old sentence $\psi$, and suppose some old model — some valuation $v$ of the atoms — satisfies the base theory $\mathcal{T}$. By hypothesis, $v$ extends to a solution $w$ of the loop equations. The pair $(v, w)$ satisfies $\mathcal{T}$ (because truth-free sentences cannot see the internal truth predicate — their value depends only on $v$) and satisfies every biconditional (because $w$ solves the loop equations). So $(v,w)$ satisfies $\psi$; and since $\psi$ is truth-free, $v$ alone satisfies $\psi$. Hence $\mathcal{T}$ entails $\psi$ outright.

The converse is a diagram argument: if some valuation $v$ admits no solution, take as base theory the set of all truth-free sentences that $v$ makes true. Every model of that theory has exactly $v$'s atomic values, so the tangled theory built on it has no model at all — it entails $\bot$ — while the base theory obviously does not.

The content of this equivalence is worth pausing on. **Conservativity is not a delicate syntactic property to be established formula by formula. It is the solvability of a system of equations.** The Tarski biconditionals are fixed-point equations in the unknowns $w(c)$; a tangled hierarchy is harmless exactly when its equations have solutions, for every state of the world below. Everything that follows is a hunt for structural conditions guaranteeing solvability.

---

## Positive loops: the truth-teller and the Knaster–Tarski theorem

Here is the first, and prettiest, sufficient condition. Say that a formula is **positive** if every occurrence of a truth atom in it lies under an even number of "left-of-arrow" positions — formally, define positivity and negativity by mutual recursion: atoms and $\bot$ are both positive and negative; $\varphi \to \psi$ is positive when $\varphi$ is negative and $\psi$ is positive, and negative when $\varphi$ is positive and $\psi$ is negative; a truth atom $T c$ is positive but never negative. Since $\neg\varphi$ is $\varphi \to \bot$, this is exactly the intuitive notion: positive means *no truth atom sits under a negation*.

The key fact about positivity is a monotonicity law: if $w$ makes at least as many names true as $w'$ does, then $w$ makes every positive formula at least as true. So the **revision operator**
$$R(w)(c) \;=\; \text{the truth value of } \mathrm{den}(c) \text{ when the names are valued by } w$$
is monotone on the lattice of truth assignments, ordered pointwise. And a monotone map on a complete lattice always has a fixed point — indeed a least and a greatest one. That is the Knaster–Tarski theorem, the same theorem that underlies the semantics of recursive programs and inductive definitions.

> **Positive Conservativity Theorem.** If every sentence $\mathrm{den}(c)$ of a tangled hierarchy is positive, then for every truth-free base theory $\mathcal{T}$ and every truth-free sentence $\psi$, the tangled theory entails $\psi$ if and only if $\mathcal{T}$ alone entails $\psi$. In particular a consistent base theory stays consistent.

Read that carefully, because it is stronger than it looks. There is *no* restriction on how the names refer to one another. A name may name a sentence about itself; a hundred names may form a single enormous cycle; the dependency graph may be an arbitrary directed graph with loops everywhere. As long as no truth atom appears negated, the equations are solvable and the strange loops are, from the old theory's point of view, invisible.

The simplest instance is the **truth-teller**, the sentence "this sentence is true", i.e. the single name $c$ with $\mathrm{den}(c) = T c$. It is the liar's harmless twin, and it is positive.

---

## Grounded hierarchies: no loops, no freedom

The other classical sufficient condition throws away positivity and restricts the *shape* of the reference graph instead. Call a hierarchy **grounded** (or stratified) if there is a rank function $\mathrm{rk}$ assigning a natural number to each name such that whenever $c'$ occurs in $\mathrm{den}(c)$, we have $\mathrm{rk}(c') < \mathrm{rk}(c)$. Every reference points strictly downward; there are no loops at all. This is Tarski's own prescription: a hierarchy of metalanguages.

> **Grounded Determinacy and Conservativity Theorem.** If a tangled hierarchy is graded by a rank function with strictly descending dependencies, then for every valuation of the old atoms there is *exactly one* assignment of truth values to the names satisfying all the loop equations; consequently the hierarchy is conservative over every truth-free base theory, whatever the polarities of its dependencies.

The construction is the obvious one: iterate the revision operator from the everywhere-false assignment, and observe that the value at a name of rank $n$ has stopped changing after $n+1$ steps, because it depends only on names of smaller rank. Uniqueness is induction on rank.

The special case worth naming is a hierarchy in which every name denotes an *old*, truth-free sentence. Then the Tarski biconditionals say precisely: the internal truth predicate is sound and complete for the old language. That is the strongest internal-soundness statement one could want, and it costs nothing — no new theorem, and not even a new degree of freedom, since the truth predicate is uniquely pinned down.

---

## Local stratification: loops inside a level

The two theorems above look like rival ideologies — "loops are fine if nothing is negated" versus "negation is fine if nothing loops" — and it is natural to want a common generalization. Here it is, and it is the sharpest positive result in the story.

Refine the analysis of occurrences: say $c'$ occurs **positively** in $\varphi$ if it occurs under an even number of antecedent positions, and **negatively** if under an odd number. (A name can occur both ways in the same formula.) Now call a hierarchy **locally stratified** if there is a rank $\mathrm{rk}$ on names such that

- every **negative** occurrence strictly descends: if $c'$ occurs negatively in $\mathrm{den}(c)$ then $\mathrm{rk}(c') < \mathrm{rk}(c)$;
- every **positive** occurrence merely does not ascend: if $c'$ occurs positively in $\mathrm{den}(c)$ then $\mathrm{rk}(c') \le \mathrm{rk}(c)$.

So strange loops are permitted *inside* a level; only refutation-like, negative dependencies must point down.

> **Local Stratification Theorem.** Every locally stratified tangled hierarchy has, over every valuation of the old atoms, at least one model; hence it is conservative over every truth-free base theory.

The construction is a hybrid of the two earlier ones and is, to my eye, the most satisfying object in the subject: build the assignment *level by level*, and within each level take the least fixed point of the revision operator relative to the levels already built. The lower levels are frozen — which is legitimate precisely because negative dependencies descend, so the frozen part appears with a fixed value — and the within-level dependencies are positive, so Knaster–Tarski applies. A stability argument glues the levels together: once level $n$ has been built, no later stage disturbs it.

Both earlier theorems fall out: a positive hierarchy is locally stratified with the constant rank $0$ (one level, all loops inside it), and a grounded hierarchy is locally stratified by its own rank. And the generalization is strict. Consider two names $p$ and $q$ with
$$\mathrm{den}(q) = \bot, \qquad \mathrm{den}(p) = T q \to T p.$$
Here $p$ has a genuine positive self-loop, and $q$ occurs negatively in $\mathrm{den}(p)$ — so the hierarchy is not positive, and no rank can strictly descend along the self-loop $p \to p$. Yet putting $\mathrm{rk}(q) = 0$ and $\mathrm{rk}(p) = 1$ locally stratifies it, and it is conservative.

Is local stratification *necessary*? No — and the counterexample is a one-liner. The single-name hierarchy with $\mathrm{den}(c) = T c \to T c$ has $c$ occurring both positively and negatively in its own definition, so no rank can stratify it; but the sentence is a tautology, every assignment solves it, and the hierarchy is conservative. The exact criterion remains what the master key said it was: solvability.

---

## Height collapse: infinitely tall, never transfinitely tall

What if we allow hierarchies with no numerical grading at all, requiring only that the dependency relation "$c'$ occurs in $\mathrm{den}(c)$" be **well-founded** — no infinite descending chain of references? Then truth can be defined by recursion along the dependency order, again uniquely, and conservativity follows as before.

But there is a surprise here. One expects well-foundedness to be strictly more general than an $\mathbb{N}$-valued rank, because well-founded relations can have transfinite height. Not here.

> **Height Collapse Theorem.** A tangled hierarchy has a well-founded dependency relation if and only if it admits a rank function into the natural numbers with strictly descending dependencies.

The reason is finiteness of syntax: each sentence mentions only finitely many names, so the canonical rank "one more than the maximum of the ranks of the names I mention" is well defined by recursion and takes values in $\mathbb{N}$. A finitary tangled hierarchy can be *infinitely tall* — the levels may be unbounded — but no name ever lives at level $\omega$ or above. The transfinite is unreachable from below when every step is a finite formula.

An example makes the picture concrete. Take names $0, 1, 2, \dots$ together with one extra name $\star$, and set
$$\mathrm{den}(0) = \bot, \qquad \mathrm{den}(n+1) = \neg T n, \qquad \mathrm{den}(\star) = T 0 .$$
Every link is a negation, so the hierarchy is nowhere positive; the levels are unbounded, so no finite bound covers it. It is nevertheless well-founded, hence conservative, and its truth predicate is completely determined: $T0$ false, $T1$ true, $T2$ false, and so on forever, with $T\star$ false. Infinite regress is not the same as vicious circularity.

---

## What a loop actually costs: indeterminacy, priced exactly

If strange loops add no theorems, do they add nothing? No. They add *freedom* — and one can price it exactly.

For a positive hierarchy, the models are precisely the fixed points of the monotone revision operator $R$, and Knaster–Tarski gives a least fixed point $\mathrm{lfp}(R)$ and a greatest fixed point $\mathrm{gfp}(R)$, each of which is a model, with every other model sandwiched between them. So all indeterminacy lives in the interval $[\mathrm{lfp}(R), \mathrm{gfp}(R)]$, and:

> **Determinacy Criterion.** A positive tangled hierarchy determines its internal truth predicate uniquely if and only if its minimal and maximal extensions coincide.

Now count. Take $k$ independent truth-tellers: names $c_1, \dots, c_k$ with $\mathrm{den}(c_i) = T c_i$. Every one of the $2^k$ possible assignments solves the equations, so:

> **Exponential Semantic Cost, Zero Syntactic Cost.** The hierarchy of $k$ independent truth-tellers has exactly $2^k$ models, each $T c_i$ is left undecided by the tangled theory (neither it nor its negation follows), and the tangled theory nevertheless adds no truth-free consequence whatsoever to any truth-free base theory.

The minimal extension calls every loop false; the maximal one calls them all true; the theory cannot tell them apart. The slogan: **the cost of tangling is exponential in semantics and zero in syntax.**

And the single-name case gives the whole spectrum in one line:

> **The Cost of One Loop.** For a hierarchy with a single name $c$: if $\mathrm{den}(c) = \bot$ (grounded), there is exactly one model; if $\mathrm{den}(c) = T c$ (the truth-teller, a positive self-loop), exactly two; if $\mathrm{den}(c) = \neg T c$ (the liar, a negative self-loop), exactly none.

$1$, $2$, $0$. Grounding costs nothing and buys determinacy. A positive loop costs one bit of indeterminacy and buys nothing. A negative loop costs everything.

---

## Sharpness: the liar is not a technicality

The last result is the boundary marker, and it is worth stating as a theorem rather than as a caveat.

> **Failure of Conservativity for the Liar.** The single-name hierarchy with $\mathrm{den}(c) = \neg T c$ entails $\bot$ even over the empty base theory, while the empty theory is consistent. So it is not conservative over anything.

The loop equation $w \leftrightarrow \neg w$ has no solution; by the master key, conservativity fails; and it fails in the worst possible way, by outright inconsistency. Every positive theorem above is therefore sharp in the same direction: drop positivity without imposing descent (or descent without positivity) and the liar walks straight through the gap.

---

## Why this matters beyond the paradoxes

The picture that emerges is not the standard cautionary tale about self-reference. It is a *trade-off with an exact price list*, and the price list is recognizable from several places in computing.

**Recursive definitions.** The revision operator and its least fixed point are exactly the semantics of recursive program definitions and inductive predicates, and positivity is exactly the condition making such a definition monotone, hence meaningful. When a system insists that recursion through negation be *stratified*, it is enforcing the local stratification condition above — and the theorem says what that discipline buys: the extended program computes nothing new about the negation-free part of the language.

**Reflection.** A system reasoning about its own correctness needs an internal truth predicate. The grounded case — every name denoting an old sentence — is the counterpart of a reflection principle for the old language, and the theorem says it is free, in the double sense of adding no theorem and no ambiguity.

**Knowledge bases and self-describing data.** A database storing statements about the truth of its own records is a tangled hierarchy. The criterion tells the designer what to check: not "is there a cycle?" but "do the equations have a solution for every state of the base data?"

**And the strange loop itself.** Hofstadter's claim was that the loop of self-representation does not corrupt the levels it sits above. Here that claim has a theorem-shaped counterpart, with the fine print made explicit. The loop is free *provided its negations are grounded*. A system may represent itself, reason about its own representations, and close the circle, all without changing a single fact about the world it models. What it gains from the loop is not new knowledge about the world. What it pays is that some of its statements about itself are simply not determined — the system contains genuine bits about which its own theory is silent.

There is something almost consoling in the arithmetic. The self can be tangled, unbounded, and utterly circular; that costs the world nothing. It costs the self only a certain irreducible indefiniteness about itself. And the one loop the mathematics refuses is the one that turns back on itself in denial.
