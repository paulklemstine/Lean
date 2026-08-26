# The Logic That Knows It Cannot Prove Itself — And Now Knows How Small Its Excuses Are

## A modality for "provable"

In 1931 Kurt Gödel showed that a sufficiently strong formal theory of arithmetic — Peano arithmetic, say — can talk about itself. It can encode its own syntax as numbers, and it can write down an arithmetical formula $\mathrm{Prov}(x)$ that says, in effect, *"the sentence with code number $x$ has a proof."* Once a theory can say that, strange loops become possible: the theory can assert things about what it can and cannot establish.

Logicians eventually noticed that the *reasoning patterns* about $\mathrm{Prov}$ are far simpler than the arithmetic underneath them. So they stripped the arithmetic away and kept only the pattern. Write $\Box A$ for "$A$ is provable." Three laws govern this operator:

- **Distribution.** $\Box(A \to B) \to (\Box A \to \Box B)$. If you can prove an implication and you can prove its hypothesis, you can prove its conclusion — just concatenate the two proofs.
- **Necessitation.** If $A$ is a theorem, then so is $\Box A$. If you have actually proved $A$, then "$A$ is provable" is itself something you can prove: exhibit the proof.
- **Löb's axiom.** $\Box(\Box A \to A) \to \Box A$.

The third one is the strange one. Read it slowly. It says: *if the theory can prove "whenever $A$ is provable, $A$ is true", then the theory can already prove $A$ outright.* Martin Hugo Löb discovered this in 1955, and it is genuinely disorienting the first time you see it. A theory is not allowed to trust itself for free. The moment it certifies its own reliability about $A$, it must have $A$ in hand.

Take $A$ to be $\bot$ — outright falsity. Then $\Box\bot \to \bot$ says "falsity is not provable", which is exactly the theory asserting its own consistency. Löb's axiom instantly yields Gödel's second incompleteness theorem: if the theory could prove its own consistency, it would prove $\bot$, and so be inconsistent. Consistency statements are exactly the sentences a consistent theory can never reach.

The system built from these three laws is called **Gödel–Löb logic**, or **GL**. Its semantics is beautifully geometric. Picture a set of possible worlds with an arrow relation $R$: $w \mathrel{R} v$ means "$v$ is visible from $w$". Then $\Box A$ holds at $w$ exactly when $A$ holds at every world visible from $w$. Löb's axiom is valid precisely on the frames whose arrow relation is **transitive** and **converse well-founded** — that is, there is no infinite ascending chain $w_0 \mathrel{R} w_1 \mathrel{R} w_2 \mathrel{R} \cdots$. On a finite set of worlds this simply means: the arrows form a strict order, with no cycles at all, not even a loop from a world to itself. Every path eventually stops. Provability, in this picture, is a strictly descending staircase — and Löb's axiom is the geometry of a staircase that cannot go on forever.

## Adding time

Now add a second dimension. Suppose the theory is not fixed but grows: axioms get added, a mathematician learns new things, an automated system accumulates lemmas overnight. Then "provable" is a moving target, and the natural companion operator is a temporal one. Write $\blacksquare A$ for "$A$ holds now and at every future moment."

The structures that carry both operators are what we shall call **temporal Gödel–Löb frames**. Such a frame consists of a set $W$ of worlds together with *two* relations:

- $R$, the provability relation, which is transitive and converse well-founded, exactly as in GL;
- $T$, the flow of time, which is reflexive and transitive — you are in your own future, and the future of your future is your future.

And the two must interact. The condition we impose is
$$w \mathrel{T} w' \ \text{and}\ w' \mathrel{R} v \implies w \mathrel{R} v,$$
which says: *anything visible from a future moment was already visible now.* Time does not open new provability horizons; it can only bring old ones into focus.

This single geometric condition has a striking syntactic shadow. It validates the axiom
$$\Box A \to \blacksquare \Box A,$$
which reads: **once something is provable, it stays provable forever.** Proofs do not decay. Nothing you add to a theory later can un-prove what it has already established. That is the axiom that stitches the two modalities together, and it is the axiom that gives the resulting logic — call it **TGL**, temporal Gödel–Löb logic — its character.

The full calculus TGL consists of: all classical propositional tautologies; modus ponens; distribution and Löb for $\Box$; distribution, reflexivity $\blacksquare A \to A$ and transitivity $\blacksquare A \to \blacksquare\blacksquare A$ for $\blacksquare$; the interaction axiom $\Box A \to \blacksquare \Box A$; and necessitation for both boxes.

Notice what is *not* in the list: transitivity for $\Box$. The formula $\Box A \to \Box\Box A$ — "if it's provable, then it's provable that it's provable" — is not assumed. It does not need to be. It is a *theorem*, derivable from Löb's axiom alone by a short and lovely argument that uses the auxiliary formula $C = A \wedge \Box A$. Because $C \to \Box A$ and $C \to A$ are tautologies, boxing them gives $\Box C \to \Box\Box A$ and $\Box C \to \Box A$; the latter turns propositionally into $A \to (\Box C \to C)$; boxing *that* and applying Löb gives $\Box A \to \Box C$; chaining with the first yields $\Box A \to \Box\Box A$. Löb's axiom knows about transitivity without being told.

And the two boxes genuinely do not collapse into one another. $\blacksquare p \to \Box p$ fails: take two worlds, "now" and "later-in-the-provability-order", freeze time so that each world is its own only future, and let $p$ be true at the first but false at the second. Then $\blacksquare p$ holds and $\Box p$ does not. The converse $\Box p \to \blacksquare p$ fails just as easily on a single world with no provability arrows: $\Box p$ is then vacuously true while $p$ itself may be false, and the world is its own future. Provability and permanence are different things, even when provability persists.

## The question: how big does a counterexample have to be?

Here is the practical question that drives everything that follows. You have a formula $A$. You want to know whether TGL proves it. Suppose it doesn't. Then, by design, there must be a temporal Gödel–Löb model somewhere in which $A$ fails at some world. But "somewhere" is a terrible place to search. The class of frames is a proper class; there is no bound on how many worlds a model might have.

Unless there is.

Let $\mathrm{sub}(A)$ denote the number of *distinct subformulas* of $A$ — the size of the syntax tree after sharing repeated parts. For $\Box\bot \to \bot$, the subformulas are $\Box\bot \to \bot$, $\Box\bot$, and $\bot$, so $\mathrm{sub} = 3$. For $\blacksquare p \to \Box p$ we get $4$.

**Theorem (finite model property with an explicit bound).** *If $A$ is not derivable in TGL, then $A$ fails at some world of a temporal Gödel–Löb model with at most $2^{\mathrm{sub}(A)}$ worlds — a fortiori at most $2^{2\,\mathrm{sub}(A)}$ worlds.*

This is the result, and it changes the character of the problem completely. A question about an unbounded universe of models becomes a finite check. To decide whether TGL proves $A$, enumerate every temporal Gödel–Löb model with at most $2^{2\,\mathrm{sub}(A)}$ worlds and every valuation of the atoms on it, and test $A$ at every world. If it survives, $A$ is a theorem; if it fails, it isn't. Astronomically slow, but *correct* — and correctness is what a bound buys you.

## Two constructions, one obstruction

The proof has two halves, and each has a moment where the naive approach breaks.

**First half: shrinking a model.** The classical tool is *filtration*. Given a model refuting $A$, you glue together any two worlds that agree on every subformula of $A$; nothing about $A$ can tell them apart. Each world $u$ collapses to its *subformula theory* $\theta(u)$ — the set of subformulas of $A$ true at $u$. Since there are at most $2^{\mathrm{sub}(A)}$ such sets, the quotient is small. The delicate part is choosing the relations on the quotient so that the resulting structure is still a *legal* frame and still refutes $A$.

For $\Box$, the choice is a classical one due to Segerberg. Declare $S$ to see $S'$ when (i) every boxed subformula $\Box B$ realised at $S$ has both $B$ and $\Box B$ realised at $S'$, *and* (ii) at least one boxed subformula is realised at $S'$ but not at $S$. Clause (ii) looks like a technicality; it is the whole game. Define $\beta(S)$ to be the number of boxed subformulas of $A$ realised at $S$. Clause (i) says $\beta$ never decreases along an arrow, and clause (ii) says it strictly increases. But $\beta$ is bounded above by the number of boxed subformulas of $A$. So arrows cannot go on forever: **every chain in the quotient has length at most the number of boxed subformulas of $A$.** Converse well-foundedness, and hence Löb's axiom, is recovered by pure counting. That single observation is the combinatorial heart of the entire construction.

For $\blacksquare$, the obvious analogue of clause (i) — every $\blacksquare B$ realised at $S$ has $B$ and $\blacksquare B$ realised at $S'$ — is *not enough*, and this was the one genuine obstruction in the whole development. The interaction condition $w \mathrel{T} w'$ and $w' \mathrel{R} v \Rightarrow w \mathrel{R} v$ simply fails to survive the quotient. The fix is to strengthen the temporal relation with an extra clause: demand also that **every boxed subformula realised at $S$ is still realised at $S'$**. Boxes persist along time. This is legitimate precisely because it is true upstream: the interaction condition in the original model forces $\Box$-formulas to persist along $T$. So the clause costs nothing, and with it in place the interaction condition survives. The moral is a pleasant one — the axiom $\Box A \to \blacksquare\Box A$ is not decoration; it is load-bearing, and the filtration has to be built around it.

With the relations chosen, one proves the **filtration lemma**: at every realised world, the shrunken model agrees with the original on every subformula of $A$. The $\Box$ case is where converse well-foundedness of the *original* frame is spent: to show a box that fails in the quotient fails upstream, one picks an $R$-maximal counterexample world, which exists precisely because there are no infinite ascending chains. So the countermodel shrinks to at most $2^{\mathrm{sub}(A)}$ worlds, and the theorem is proved — *for formulas that already have a countermodel.*

**Second half: manufacturing a model.** But the theorem quantifies over formulas that are merely *not derivable*. To get from "not derivable" to "has a countermodel" one needs **completeness**: every formula valid on all temporal Gödel–Löb frames is provable in TGL. Without it, the bound would be a conditional promise.

And here Gödel–Löb logic plays its most famous trick. The standard way to prove completeness is to build a *canonical model* whose worlds are all maximal consistent sets of formulas. For GL this construction is fatally broken: the canonical frame is not converse well-founded, so it is not a legal frame at all, so it proves nothing. The escape is to go finite. Fix a formula $A$ and let $\mathrm{Cl}$ be its subformula closure. A **world** is now a subset $t \subseteq \mathrm{Cl}$ that is *consistent as a decision*: the list asserting every member of $t$ and the negation of every member of $\mathrm{Cl} \setminus t$ does not derive a contradiction. There are at most $2^{|\mathrm{Cl}|}$ such worlds — the model is finite by construction. And crucially, one uses the *very same* filtration relations to connect them.

The two existence lemmas are the mathematical core. Suppose $\Box B \notin t$; we need an accessible world where $B$ fails. Assemble the candidate hypothesis list: everything of the form $\Box D$ in $t$, together with each such $D$, together with $\Box B$ and $\lnot B$. If this list were inconsistent, then it would prove $\Box B \to B$; boxing that derivation (necessitation plus repeated distribution) and applying **Löb's axiom** would derive $\Box B$ from the boxed hypotheses — all of which sit inside $t$, using the derived transitivity $\Box D \to \Box\Box D$ to reproduce the boxed copies. So $\Box B \in t$, contradiction. Hence the list is consistent, extends to a world $s$, and $s$ is exactly the successor we wanted. Löb's axiom, having been the obstacle for the infinite canonical model, is the engine of the finite one.

The temporal existence lemma runs the same way, but with three different fuels: necessitation for $\blacksquare$, transitivity $\blacksquare A \to \blacksquare\blacksquare A$, and — for the extra $\Box$-persistence clause of the temporal relation — the interaction axiom $\Box A \to \blacksquare\Box A$. The axiom that made the filtration work is exactly the axiom that makes the canonical model work.

A truth lemma then shows that in this finite canonical model, a formula of the closure is true at a world if and only if it *belongs* to that world. Completeness follows immediately: if $A$ is not derivable, then $\{\lnot A\}$ is consistent, so some world omits $A$, so $A$ fails there. And the model has at most $2^{\mathrm{sub}(A)}$ worlds by construction. The conjecture is a theorem, in its sharp form.

## What the numbers look like

Bounds are one thing; reality is another. Consider the consistency statement $\Box\bot \to \bot$. It has three subformulas, so the theorem permits a countermodel with up to $2^{2 \cdot 3} = 64$ worlds. In fact it is refuted by the smallest model imaginable: **one** world, with no provability arrows at all. There, $\Box\bot$ is vacuously true and $\bot$ is false. Gödel's second incompleteness theorem, in its purest modal form, needs a single point to witness it.

Or take $\blacksquare p \to \Box p$, with four subformulas and a permitted bound of $2^{2 \cdot 4} = 256$. Its minimal countermodel has **two** worlds. Ratios of $64:1$ and $128:1$.

So the bound is correct and enormously generous. Why? Because the proof pays twice. It pays for *depth* — how long an arrow chain can be — and it pays for *width* — how many distinct worlds can sit at each level. The counting argument shows that depth is already tightly controlled: no chain is longer than the number of boxed subformulas, a linear quantity. The entire exponential lives in the width, and width is only ever spent realising distinct propositional theories, of which a *selective* canonical model — one that keeps only the worlds actually reached by iterating the two existence lemmas — never needs all $2^{\mathrm{sub}(A)}$. This is precisely the shape of a natural conjecture: that for every non-derivable $A$ there is a countermodel whose world count is bounded by a *polynomial* in $\mathrm{sub}(A)$, and in fact by $\mathrm{sub}(A) + 1$ for formulas with no nested implications beneath a $\Box$.

## Why it matters

Provability logic is the mathematics of self-reference tamed. Gödel's incompleteness theorems, Löb's theorem, the failure of self-certification — these are not isolated curiosities but consequences of a single, decidable, thoroughly understandable modal system. Adding a temporal dimension takes the picture one step closer to something you might actually build: a reasoning agent whose stock of theorems grows over time, that knows its own past proofs remain valid, and that still cannot vouch for its own consistency.

The finite model property with an explicit bound is what makes such a system *checkable*. It says the logic has no hidden depths: every failure it can exhibit, it can exhibit small. Whatever a temporal provability logic cannot prove, it cannot prove for a reason you can hold in your hand — a finite diagram, a handful of worlds, a strictly descending staircase that runs out.
