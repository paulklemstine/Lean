# Mathematics Across Branches: The Set-Theoretic Multiverse

## One question, many answers

Here is a question that sounds like it should have an answer: *is there a set of numbers that is bigger than the whole numbers but smaller than the real numbers?*

Between the endless list $0, 1, 2, 3, \dots$ and the unbroken continuum of the real number line lies one of the oldest puzzles in mathematics. Georg Cantor, who discovered that infinities come in different sizes, believed the answer was *no* — that there is nothing strictly between the countable and the continuum. This guess is called the **Continuum Hypothesis**, or $\mathrm{CH}$ for short. Cantor spent years trying to prove it and never succeeded.

We now know why he failed. It was not for lack of cleverness. It was because, working from the standard axioms of mathematics, the Continuum Hypothesis can be *neither proved nor disproved*. Kurt Gödel showed in 1940 that you cannot refute it; Paul Cohen showed in 1963, using a revolutionary technique called **forcing**, that you cannot prove it either. The question is *independent* of the rules of the game.

For a long time this was treated as an embarrassment — a gap to be apologized for. But there is another way to look at it, and it is the subject of this article. What if the independence of $\mathrm{CH}$ is not a bug, but a feature? What if there is no single mathematical universe at all, but a vast landscape of them — a **multiverse** — in which $\mathrm{CH}$ is simply true in some worlds and false in others, the way "it is raining" is true in some cities and false in others?

This is the *multiverse* view of set theory, championed by the logician Joel David Hamkins. This article develops a clean, self-contained mathematical model of its combinatorial heart. We will build the multiverse out of the simplest possible ingredients, model forcing as a single elementary operation, and prove — rigorously — that in a world-collection rich enough to be closed under forcing, *forcing settles nothing*: every basic question stays open. Along the way we will see exactly which statements are absolute (true everywhere, no matter what) and which are contingent (true here, false there).

## Worlds as answer sheets

To reason about a multiverse we first need a workable notion of a "universe." A full model of set theory is an enormously complicated object. But almost everything we want to say about independence concerns only the *answers* a universe gives to a fixed list of yes/no questions: Is $\mathrm{CH}$ true? Does every set arise in Gödel's constructible hierarchy (the axiom written $V = L$)? Is there a measurable cardinal?

So we strip a universe down to its answer sheet. Fix a collection of **atomic assertions** — the basic yes/no questions we care about. A **world** is nothing more than an assignment of `true` or `false` to each atom. If our questions are $\mathrm{CH}$, $V=L$, and "there is a measurable cardinal," then a world is a filled-in form like

$$\mathrm{CH} \mapsto \texttt{true}, \quad V=L \mapsto \texttt{true}, \quad \text{Meas} \mapsto \texttt{false}.$$

That particular answer sheet describes Gödel's constructible universe $L$: everything is constructible, so $V=L$ holds; from $V=L$ it follows that $\mathrm{CH}$ holds; and $L$ contains no measurable cardinal. We call this world **Gödel**. A different answer sheet, in which $\mathrm{CH}$ is false, describes a Cohen forcing extension; we call it **Cohen**.

From atoms we build **sentences** by the usual logical glue: negation ("not"), conjunction ("and"), disjunction ("or"), and implication ("if … then …"), together with the constants *true* and *false*. A sentence like $(V=L) \Rightarrow \mathrm{CH}$ — "if every set is constructible then the Continuum Hypothesis holds" — is a perfectly good compound statement. Given a world (an answer sheet), we can *evaluate* any sentence to `true` or `false` by the obvious rules: "and" is true when both parts are, "not" flips the value, and so on. We say a world **satisfies** a sentence when the sentence evaluates to `true` there.

Finally, a **multiverse** is simply a *collection of worlds* — a set of answer sheets we regard as legitimate. This is the whole setup. It is deliberately spare, and that spareness is what makes the theorems below crisp and unarguable.

## Three fates for a sentence

Fix a multiverse $M$. Relative to it, every sentence $p$ has one of three fates.

- $p$ is **valid** if it is true in *every* world of $M$. These are the settled truths of the multiverse.
- $p$ is **refutable** if it is false in *every* world. These are the settled falsehoods.
- $p$ is **independent** if it is true in *some* world and false in *another*. These are the genuinely contingent statements — the ones on which the branches disagree.

A sentence that is valid or refutable we call **settled**. The drama of set theory is the discovery that $\mathrm{CH}$, far from being settled, is independent.

A few relationships are immediate but worth stating, because they organize everything that follows. An independent sentence cannot be valid (a world where it fails witnesses that), cannot be refutable (a world where it holds witnesses that), and therefore cannot be settled at all. Conversely a valid sentence is never independent. And independence is blind to negation: $p$ is independent exactly when its negation $\lnot p$ is, since swapping true and false merely swaps the two witnessing worlds. These little facts are the grammar of the multiverse.

## What is absolute?

Before celebrating disagreement, we should ask what *cannot* be disagreed about. The answer is: the laws of logic themselves. Consider the **law of excluded middle**, the sentence $p \lor \lnot p$ — "either $p$ or not $p$." In any world, $p$ evaluates to either `true` or `false`, and in both cases $p \lor \lnot p$ evaluates to `true`. So $p \lor \lnot p$ is valid in *every* multiverse whatsoever, no matter which worlds it contains.

**Theorem (Absoluteness of logic).** *For any multiverse and any sentence $p$, the law of excluded middle $p \lor \lnot p$ is valid; the law of non-contradiction $\lnot(p \land \lnot p)$ is valid; and self-implication $p \Rightarrow p$ is valid.*

The proof is a two-line case check on the truth value of $p$, but the moral is large. The multiverse is not chaos. There is a solid floor of logical truth beneath every branch. What varies from world to world is *mathematical content* — $\mathrm{CH}$, $V=L$, the existence of exotic cardinals — not *logic*. This is the sharp line the multiverse view draws: absolute where it must be, plural where it can be.

## Forcing, distilled to a single move

Now for the engine that generates the plurality. Cohen's forcing is a sophisticated technique for building a new universe from an old one by carefully adjoining a "generic" object that decides some question in a prescribed way. Its full machinery is intricate. But its *combinatorial shadow* is astonishingly simple: forcing takes a universe that answers a question one way and produces a neighboring universe that answers it the other way.

We model this with a single operation, the **flip**. Given a world $w$ and an atom $a$, the flipped world $\mathrm{flip}(w, a)$ is identical to $w$ on every other question but gives the opposite answer to $a$:

$$\mathrm{flip}(w,a)(x) = \begin{cases} \lnot\, w(a) & \text{if } x = a,\\ w(x) & \text{otherwise.}\end{cases}$$

This is the essential effect of a forcing extension that targets $a$: keep everything else fixed, decide $a$ the other way. The key property is exactly what you would expect — the flip genuinely toggles the targeted atom: $\mathrm{flip}(w,a)$ satisfies $a$ if and only if $w$ does *not*.

A multiverse deserves to be called **forcing-closed** when it is stable under this operation: whenever a world $w$ belongs to it, so does $\mathrm{flip}(w,a)$ for every atom $a$. This is the combinatorial abstraction of one of Hamkins' multiverse axioms — the principle that every universe has forcing extensions realizing the opposite of any forceable statement. A forcing-closed multiverse is one that never contains a universe without also containing its forcing neighbors.

## The headline: forcing settles nothing

Here is the central result, and it is beautifully clean.

**Theorem (Forcing settles nothing).** *In any nonempty forcing-closed multiverse, every atomic sentence is independent.*

The proof is a single paragraph. Take any atom $a$. Since the multiverse is nonempty, pick a world $w$ in it. Since it is forcing-closed, its flip $\mathrm{flip}(w,a)$ is also in it. Now $w$ and $\mathrm{flip}(w,a)$ give opposite answers to $a$ by the toggling property. So one of them satisfies $a$ and the other refutes it — which is precisely what it means for $a$ to be independent. Done.

The consequence is immediate and stark: **no atomic question is ever settled in a nonempty forcing-closed multiverse.** If your collection of universes is rich enough to be closed under forcing, then forcing cannot pin down the answer to a single basic question. Every such question splinters into a *yes* branch and a *no* branch. This is the multiverse view crystallized: in the space of all forcing-reachable universes, the independent statements are not exceptional — they are the rule.

The largest forcing-closed multiverse is the **full multiverse**, containing *every* possible answer sheet. It is trivially closed under flips (every world is already present), so every atom is independent there. In fact one can realize any combination of answers: for two distinct atoms $a$ and $b$, there is a world where $a$ holds and $b$ fails, and another where both fail — so even the compound statement $a \land \lnot b$ is independent. And a satisfying bookkeeping fact: if there are $n$ atomic questions, the full multiverse has exactly $2^n$ worlds, one for each way of filling in the form. Three questions give $8$ worlds.

## The Continuum Hypothesis, independent — and stubbornly so

Let us return to Cantor's question and make the abstract concrete. Take the three atoms $\mathrm{CH}$, $V=L$, and "there is a measurable cardinal," and the two-world multiverse $\{\text{Gödel}, \text{Cohen}\}$. In the Gödel world, $\mathrm{CH}$ is true; in the Cohen world, it is false.

**Theorem (Independence of $\mathrm{CH}$).** *In the multiverse $\{\text{Gödel}, \text{Cohen}\}$, the Continuum Hypothesis is independent — true in Gödel's constructible universe, false in the Cohen extension.*

This is the honest formal echo of the Gödel–Cohen theorems: two legitimate universes disagree, so no proof can force one answer. The same holds for $V=L$, which is true in Gödel and false in Cohen.

But now something subtler. The two worlds do *not* disagree about everything. Consider the implication $(V=L) \Rightarrow \mathrm{CH}$ — the classical fact that constructibility forces the Continuum Hypothesis. Check it: in the Gödel world both sides are true, so the implication holds; in the Cohen world the hypothesis $V=L$ is false, so the implication holds vacuously. It holds in *both* worlds.

**Theorem (A law of the multiverse).** *The implication $(V=L) \Rightarrow \mathrm{CH}$ is valid across $\{\text{Gödel}, \text{Cohen}\}$: unlike $\mathrm{CH}$ itself, it is a settled truth of this multiverse.*

So we have a settled *dependence* even amid unsettled *facts*: the branches may disagree on whether $\mathrm{CH}$ holds, but they all agree that constructibility would guarantee it.

One might hope to use such a law to tame $\mathrm{CH}$. Suppose we *adopt* $(V=L)\Rightarrow \mathrm{CH}$ as a standing law and restrict attention to the sub-multiverse of worlds that obey it. Does throwing out the lawless worlds settle the Continuum Hypothesis? It does not.

**Theorem (CH remains independent under the law).** *Even after restricting to worlds satisfying $(V=L)\Rightarrow\mathrm{CH}$, the Continuum Hypothesis stays independent.*

The reason is simple and telling: both Gödel and Cohen already obey the law, yet they still disagree about $\mathrm{CH}$. Gödel satisfies it with $V=L$ true; Cohen satisfies it vacuously with $V=L$ false; and their verdicts on $\mathrm{CH}$ remain opposite. Adopting a true implication does not collapse the branches. The plurality is robust — you cannot legislate it away with a law that the branches were already respecting.

## Why this picture matters

The multiverse view reframes a century of unease. The independence results were once read as a scandal: mathematics could not answer its own questions. The multiverse reads them instead as *discoveries about the shape of mathematical reality* — a reality with genuine branch points, where a question like $\mathrm{CH}$ is less like "is $7$ prime?" and more like "which way does the river fork?"

The model developed here makes three things precise and provable. First, there is an unshakable core — the laws of logic hold across every branch, so the multiverse is lawful, not anarchic. Second, forcing, reduced to its combinatorial essence as a flip, provably *cannot* settle any basic question once your world-collection is closed under it: independence is the generic condition, not a rare pathology. Third, agreement and disagreement coexist in structured ways — the branches can share a firm law like "$V=L$ implies $\mathrm{CH}$" while still splitting on $\mathrm{CH}$ itself, and no such shared law suffices to force consensus.

There is a pleasing echo here of ideas far beyond set theory: physicists speak of a multiverse of possible worlds with different physical constants; logicians of possible-world semantics for what *might* be true. The set-theoretic multiverse is the mathematician's own version — a landscape of consistent worlds, connected by forcing, absolute in their logic and plural in their truths. What we have shown is that this landscape, once you demand it be closed under the very operation that generates it, is *permanently* plural: the branches never fully merge, and the questions that divide them stay divided forever.

Cantor asked whether there is a size between the whole numbers and the continuum. The deepest answer we have is not *yes* and not *no*. It is: *in some worlds, yes; in others, no — and forcing will never make them agree.*
