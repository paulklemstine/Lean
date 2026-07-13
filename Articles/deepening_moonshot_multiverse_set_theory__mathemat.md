# Many Worlds of Mathematics: How Forcing Turns Set Theory into a Logic of Possibility

## A universe that refuses to make up its mind

At the foundation of modern mathematics sits a short list of axioms called $\mathrm{ZFC}$ — Zermelo–Fraenkel set theory with the Axiom of Choice. From this handful of rules, virtually all of mathematics can, in principle, be derived. Yet in 1963 the world of logic was upended by a discovery that still unsettles: some of the most natural questions we can ask about infinite sets simply **cannot be answered** by these axioms at all.

The most famous of these questions is the **Continuum Hypothesis** ($\mathrm{CH}$). It asks something disarmingly simple: is there any size of infinity strictly between the counting numbers $\{0,1,2,\dots\}$ and the real number line? Georg Cantor conjectured the answer was "no." Kurt Gödel showed in 1938 that you can never *disprove* $\mathrm{CH}$ from the standard axioms. Paul Cohen, wielding a revolutionary new technique called **forcing**, showed in 1963 that you can never *prove* it either. $\mathrm{CH}$ floats free — true in some mathematical universes, false in others, forbidden from ever being pinned down.

For decades, mathematicians treated this as an embarrassment to be managed. But the logician Joel David Hamkins proposed a radical reframing: what if this isn't a defect at all? What if there is not one true universe of sets, but a vast **multiverse** of them — each a legitimate mathematical world, each with its own answers to the undecidable questions? This article is about a precise, fully worked-out mathematical model of that vision, and about a surprising payoff: once you take the multiverse seriously, forcing stops being an exotic technical device and reveals itself as an ordinary **logic of possibility and necessity**.

## Worlds as answer sheets

To reason about a multiverse we first need a workable notion of a "world." A full model of $\mathrm{ZFC}$ is a monstrous object, far too intricate to manipulate directly. But for the purpose of studying which statements are settled and which float free, most of that structure is irrelevant. What distinguishes one universe from another, in the end, is *how it answers the undecidable questions*.

So we make a deliberate abstraction. Fix a collection of **atomic assertions** — think of them as the yes/no questions whose answers can vary, such as $\mathrm{CH}$, the axiom of constructibility $V=L$ ("every set is built in Gödel's canonical way"), or "there exists a measurable cardinal." A **world** is then nothing more than an answer sheet: a function that assigns to each atomic assertion a truth value, $\mathrm{true}$ or $\mathrm{false}$. If there are $n$ atomic questions on the table, there are exactly

$$2^{n}$$

possible answer sheets — and this count is a theorem in our framework, not a hand-wave.

From atoms we build **sentences** in the ordinary way, using *and*, *or*, *not*, and *implies*. Each world evaluates each sentence to a single truth value by the familiar rules of logic. A **multiverse** is simply a collection of worlds — a chosen family of answer sheets we regard as legitimate.

This is a caricature of set theory, and deliberately so. But it is a *faithful* caricature: it captures exactly the feature Hamkins cares about — that different universes disagree — while throwing away everything that would make the disagreement impossible to analyze.

## The three faces of a statement

Within a multiverse $M$, every sentence $p$ wears one of three faces:

- $p$ is **valid** if it is true in *every* world of $M$. These are the settled truths — the statements the multiverse agrees on.
- $p$ is **refutable** if it is false in every world. These are the settled falsehoods.
- $p$ is **independent** if it is true in some world *and* false in some other. These are the statements that float free.

A sentence that is valid or refutable is called **settled**; an independent sentence is precisely one that is *not* settled. Independence is what the whole subject is about.

Some statements are settled no matter which multiverse you pick. The law of the excluded middle, $p \lor \neg p$, is true in every conceivable world; so is non-contradiction, $\neg(p \land \neg p)$, and self-implication, $p \to p$. These logical validities are **absolute** — they hold across all branches of the multiverse simultaneously. This is the bedrock that no amount of forcing can shake, and it stands in sharp, deliberate contrast to $\mathrm{CH}$.

## Forcing, made combinatorial

Cohen's forcing is a delicate procedure for building a new universe of sets out of an old one, carefully arranged so that a target statement comes out the way you want. In our answer-sheet model it becomes something almost childishly simple: **forcing flips a switch.**

Given a world $w$ and an atom $a$, the *generic extension* of $w$ along $a$ is the world $\mathrm{flip}(w,a)$ that agrees with $w$ on every question except $a$, whose answer it reverses. That single operation captures the essential combinatorial content of forcing: it produces a new legitimate world deciding the chosen question the opposite way, while disturbing nothing else.

A multiverse is **forcing-closed** if it is stable under all such flips — whenever a world belongs to it, so does every generic extension of that world. This is our abstraction of Hamkins' *multiverse axioms*, which insist that every universe has the forcing extensions it ought to have. And now comes the first headline result:

> **Theorem (Forcing settles nothing).** In any nonempty forcing-closed multiverse, *every* atomic assertion is independent.

The proof is a two-line combinatorial argument, but its meaning is profound. Take any world $w$ and any question $a$. Whatever $w$ answers, the flipped world $\mathrm{flip}(w,a)$ — guaranteed to exist by forcing-closure — answers the opposite. So the question is true somewhere and false somewhere: independent. No atomic question can ever be pinned down once forcing is allowed to run free. The floating of $\mathrm{CH}$ is not special; it is the universal condition of everything forcing can touch.

## Gödel, Cohen, and the smallest interesting multiverse

Abstraction is only convincing if it reproduces the classical facts, so let us build the smallest multiverse that tells the real story. Take three atoms — $\mathrm{CH}$, $V=L$, and "there is a measurable cardinal" — and two worlds:

- **Gödel's world** $L$: here $V=L$ holds, and because constructibility forces the Continuum Hypothesis, $\mathrm{CH}$ holds too; there is no measurable cardinal.
- **Cohen's world**: a forcing extension in which $\mathrm{CH}$ fails, and with it $V=L$.

In the two-world multiverse $\{\text{Gödel}, \text{Cohen}\}$ we can now watch the classical theorems fall out mechanically. $\mathrm{CH}$ is **independent** — true in Gödel's world, false in Cohen's. So is $V=L$. This is Gödel's and Cohen's combined legacy, rendered as a finite check.

But the model also captures something subtler. The implication $V=L \to \mathrm{CH}$ is **valid** across this multiverse: it holds in both worlds. Constructibility really does entail the Continuum Hypothesis, and that entailment is a settled truth even though its two ingredients are each unsettled. We can even *adopt* this implication as a standing law — restrict attention to the worlds that obey $V=L \to \mathrm{CH}$ — and $\mathrm{CH}$ *still* refuses to be settled. Laws can constrain a multiverse without collapsing its genuine independence. Adopting true principles does not magically decide what forcing has set free.

## The twist: forcing is a logic of possibility

Here is where the story turns from clever bookkeeping into genuine discovery. Read the two forcing modalities as words from ordinary language:

- "**Possibly** $p$" means: $p$ holds in *some* forcing extension.
- "**Necessarily** $p$" means: $p$ holds in *every* forcing extension.

These are exactly the operators $\Diamond$ and $\Box$ of **modal logic**, the logic of possibility and necessity that philosophers have studied since Aristotle. And once we say which worlds are *accessible* from which — which universes count as "reachable by forcing" — the multiverse becomes a **Kripke frame**, the standard arena in which modal logic lives.

What is the right accessibility relation? A generic extension changes only *finitely much* information — forcing decides some questions but leaves all but finitely many untouched. So we declare two worlds **forcing-equivalent** when they disagree on only a finite set of atoms. Remarkably, this relation is an **equivalence relation**: every world reaches itself (reflexivity), reachability is symmetric, and it is transitive. We prove all three.

The moment accessibility is an equivalence relation, an entire cascade of modal principles becomes available. In the taxonomy of modal logics, an equivalence-relation frame validates the strongest standard system, called $\mathbf{S5}$. Concretely, our multiverse satisfies every one of the following, each proved from first principles:

- **Necessitation:** a statement valid throughout the multiverse is necessary at every world — logical laws survive all forcing.
- **Axiom $\mathbf K$:** necessity distributes over implication.
- **Axiom $\mathbf T$ (reflexivity):** whatever is necessary is actually true here — $\Box p \to p$.
- **Axiom $\mathbf 4$ (transitivity):** what is necessary stays necessary in every reachable world — $\Box p \to \Box\Box p$.
- **Axiom $\mathbf B$ (Brouwer):** what is true is necessarily possible — $p \to \Box\Diamond p$.
- **Axiom $\mathbf 5$ (Euclidean):** what is possible is necessarily possible — $\Diamond p \to \Box\Diamond p$.

Possibility and necessity turn out to be perfect mirror images, related by the duality $\Diamond p \leftrightarrow \neg\Box\neg p$: "possibly $p$" says exactly "not necessarily not-$p$."

## The Maximality Principle and the atoms that are switches

Two consequences deserve to be singled out.

The first is Hamkins' **Maximality Principle**, which in our setting reads
$$\Diamond\Box p \;\to\; \Box p.$$
In words: if it is *possible to force $p$ permanently* — possible to reach an extension after which $p$ can never again be undone — then $p$ is *already* settled throughout the whole equivalence class. Possibility of permanence collapses into actual permanence. This is the unmistakable modal signature of $\mathbf{S5}$, and it is a theorem in our framework.

The second is a vivid picture of what independence really is. In the full multiverse — the one containing every possible answer sheet — every atom behaves as a **switch**: from any world at all, forcing can flip the atom on, and forcing can flip it off. Both "possibly $a$" and "possibly not-$a$" hold everywhere. Consequently *no atom is ever necessary*: the necessity operator $\Box$ never manages to settle an atomic question, because there is always a reachable world that disagrees. The Continuum Hypothesis is the archetype: standing in Gödel's world, where $\mathrm{CH}$ is true, forcing can nonetheless carry us to Cohen's world where it fails. So $\mathrm{CH}$ is **not necessary** at Gödel's universe — $\neg\Box\mathrm{CH}$ — even though it happens to be true there. Both $\mathrm{CH}$ and its negation remain *possible* from every vantage point. Cantor's question is not a fact awaiting discovery; it is a switch, and forcing is the hand on it.

## Why this matters

There is something bracing about watching two of the deepest theorems of twentieth-century logic — the independence of the Continuum Hypothesis, and the modal logic of forcing — emerge from an object as humble as a table of $\mathrm{true}$s and $\mathrm{false}$s. The abstraction is honest: it keeps precisely the structure that makes forcing tick and discards everything else, so that the phenomena stand out in relief.

The philosophical payoff is a change of attitude. In the single-universe view, the undecidability of $\mathrm{CH}$ is a wall — the place where mathematics runs out of answers. In the multiverse view, that same undecidability becomes a *landscape*: a branching structure of possibilities threaded together by forcing, governed by a clean and complete logic of possibility and necessity. The questions we cannot settle are not gaps in our knowledge but genuine degrees of freedom in the mathematical world — switches we are free to set, and a logic that tells us exactly which settings are reachable from which.

Cantor asked whether there is an infinity between the integers and the reals. The honest, modern answer is the most interesting one imaginable: *it depends on which world you are standing in — and forcing is the road between them.*
