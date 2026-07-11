# Proving Things About Proving Things

## A sentence that knows it can be proved

Imagine a mathematical statement that does not merely assert some fact about numbers or shapes, but instead comments on its own status inside mathematics. Not "there are infinitely many primes," but something stranger: "this fact *can be proved* — but the very fact that it can be proved *cannot itself be proved*."

At first this sounds like a paradox dressed up in a tuxedo. Yet it turns out to be a perfectly respectable, perfectly consistent thing to say — provided we are careful about what "provable" means. This article is about a small, self-contained theory in which such self-referential statements are ordinary citizens: they can be written down, they can be true, and they can be false, all without the roof caving in. We call it a **reflective** theory, because its statements are allowed to reflect on their own provability.

The punchline, which we will earn honestly below, is a sharp dividing line. The sentence "provable but not provably provable" can genuinely be true — but *only* if provability is allowed to be, in a precise sense, **short-sighted**. The moment provability becomes far-sighted enough to see its own consequences all the way down, the sentence collapses into a contradiction and quietly disappears. That single geometric condition is the whole story.

## Provability as a journey between stages

The trick to taming self-reference is to stop thinking of "provable" as a fixed, absolute property and start thinking of it as something that unfolds over **stages of knowledge**.

Picture your mathematical understanding as a collection of stages, or *worlds*. Each world represents a state of what has been established so far. From any given stage, you can take a single **step of reasoning** to certain neighboring stages — the stages that become accessible after one more move of thought. We record this with an accessibility relation: writing $w \to v$ to mean "from stage $w$, stage $v$ is one reasoning step ahead."

In this picture a proposition is not a bare true-or-false verdict. It is the *set of stages at which it holds*. The proposition "there are infinitely many primes" is the collection of all stages where that has been secured; a more exotic proposition is just a more exotic collection of stages.

Now we can say precisely what "provable" means. A proposition $P$ is **provable at stage $w$** — written $\Box P$, read "box $P$" — exactly when $P$ holds at *every* stage reachable from $w$ in one reasoning step:

$$\Box P = \{\, w : \text{for every } v \text{ with } w \to v,\ P \text{ holds at } v \,\}.$$

The intuition: to have proved $P$ at your current stage is to have guaranteed $P$ no matter which single next step your reasoning takes. Provability is a promise about where one step of thought can lead.

Its mirror image is **possibility**, written $\Diamond P$: the proposition is *consistent with provability* at $w$ when *some* reachable stage satisfies it,

$$\Diamond P = \{\, w : \text{there is a } v \text{ with } w \to v \text{ and } P \text{ holds at } v \,\}.$$

These two are dual, exactly as "for all" and "there exists" are dual. Indeed a short calculation shows

$$\Diamond P = \overline{\ \Box\, \overline{P}\ },$$

where the bar denotes complement (the stages where a proposition *fails*): something is possible precisely when its negation is not provable. This little equation is the seed from which the whole logic grows.

## Building the impossible sentence

Now to the star of the show. We want a stage where $P$ is provable but its provability is *not* provable — a stage $w$ living in $\Box P$ but *not* in $\Box \Box P$.

Here is the smallest arrangement that does it. Take just three stages, arranged in a chain that does **not** loop back and does **not** take shortcuts:

$$2 \longrightarrow 1 \longrightarrow 0.$$

From stage $2$ you can step only to stage $1$; from stage $1$ you can step only to stage $0$; stage $0$ is a dead end. Let $P$ be the proposition true at *exactly one* stage, the middle one — so $P$ holds at stage $1$ and nowhere else.

Watch what happens at stage $2$.

- **Is $P$ provable at stage $2$?** From stage $2$ the only single step lands on stage $1$, and $P$ holds there. Every one-step destination satisfies $P$, so yes: stage $2$ lies in $\Box P$. *$P$ is provable.*
- **Is the provability of $P$ provable at stage $2$?** For that we would need $\Box P$ to hold at every one-step destination of stage $2$ — that is, at stage $1$. But is $P$ provable at stage $1$? From stage $1$ the only step lands on stage $0$, and $P$ *fails* at stage $0$. So $P$ is *not* provable at stage $1$. Hence $\Box P$ fails one step ahead of stage $2$, which means stage $2$ does **not** lie in $\Box\Box P$. *The provability of $P$ is not provable.*

There it is, no smoke and no mirrors: at stage $2$, the proposition $\Box P \wedge \neg\,\Box\Box P$ — "provable but not provably provable" — is genuinely, verifiably true. A running numerical model confirms the verdict exactly: $\Box P = \{0, 2\}$ while $\Box\Box P = \{0, 1\}$, and stage $2$ belongs to the first but not the second.

The reason it works is the *near-sightedness* of this chain. Stage $2$ can see one step (to stage $1$) but cannot, in a single glance, see two steps (to stage $0$). Its knowledge of $P$ is secured for the next step but not for the step after that. Provability here has a horizon, and self-reference lives right at that horizon.

## Why far-sightedness destroys the trick

This raises the natural worry: did we cheat? Is "provable but not provably provable" just an artifact of a deliberately impoverished, blinkered notion of proof? The honest and beautiful answer is that there is an exact condition separating the two regimes, and it has a name.

Call a provability step **transitive** if shortcuts always exist: whenever $a \to b$ and $b \to c$, we also have $a \to c$. Transitivity is far-sightedness — if you can reason to $b$ and from $b$ to $c$, then you can reason straight to $c$. It is the assumption that provability sees all the way down its own consequences.

On any transitive frame, the following always holds, for every proposition $P$:

$$\Box P \subseteq \Box\Box P.$$

In words: **if something is provable, then its provability is provable.** This is the celebrated *axiom 4* of modal logic, and here it is not an assumption we bolt on — it *follows for free* from far-sightedness. The proof is a single line: if $P$ holds at every stage one step from $w$, and every stage two steps from $w$ is (by transitivity) already one step from $w$, then $P$ holds two steps out too, which is exactly what $\Box\Box P$ demands.

So the impossible sentence is impossible *precisely* on transitive frames. Our three-stage chain worked only because it was **not** transitive: stage $2$ reaches stage $1$, and stage $1$ reaches stage $0$, but stage $2$ does *not* reach stage $0$ directly. Add that one missing shortcut and the counterexample evaporates — the numerical model confirms that with the shortcut in place, $\Box P \subseteq \Box\Box P$ holds for *every* proposition, and stage $2$ is no longer a witness.

This is why the phenomenon is genuinely non-classical. Classical accounts of provability — the ones behind Gödel's incompleteness theorems and Löb's theorem — take place on transitive frames, where "provable" is automatically "provably provable." Reflective type theory deliberately relaxes that, and the reward is a new expressive layer: sentences that live exactly at the reasoning horizon.

## A well-behaved kind of self-reference

One might fear that admitting such self-referential statements makes the whole edifice flimsy. It does not. The provability operator is what logicians call a **normal modality**, and it obeys every good structural law you could ask of an honest notion of proof.

- **It respects implication (monotonicity).** If $P$ always implies $Q$, then whenever $P$ is provable, so is $Q$. Proving a stronger thing proves the weaker.
- **It splits over "and" (distribution).** The provability of "$P$ and $Q$" is exactly the provability of $P$ together with the provability of $Q$. Nothing is lost or gained by proving a conjunction in one go versus piece by piece.
- **It validates the fundamental law $K$.** If an implication $P \to Q$ is provable, and $P$ is provable, then $Q$ is provable. Provability is closed under proved implications — the engine of every deduction.
- **It admits necessitation.** Anything true at *all* stages whatsoever is provable at *every* stage. Universal truths are always available.

And yet, for all its good behavior, provability is emphatically **not** the same as plain truth. There are frames, propositions, and stages where $\Box P$ and $P$ part ways — the simplest being a dead-end stage with no next step at all, where *everything* is vacuously provable (there are no one-step destinations to check) even when nothing is actually true. Because $\Box$ can differ from the identity, the reflective layer adds real content: it is a genuine, proper enrichment of ordinary logic, not a redundant restatement of it.

## The deep structure: an algebra of fixed points

Step back far enough and a larger pattern comes into focus. Propositions, remember, are sets of stages — and sets of stages form a lattice, ordered by inclusion, with "and" as intersection and "or" as union. The provability operator $\Box$ is just *one* well-behaved (monotone) transformation on this lattice.

Once you see it that way, a classical theorem takes over. The Knaster–Tarski fixed-point theorem guarantees that *every* monotone operator on such a lattice has both a **least fixed point** and a **greatest fixed point** — a smallest and a largest proposition left unchanged by the operator. These fixed points are the raw material for defining recursive, self-referential concepts.

- The **least fixed point** captures notions like "eventually reachable": the smallest collection of stages that already contains a target and is closed under taking one step back toward it. Iterating from the empty set, it builds up exactly the stages from which the target can be reached along the reasoning steps. In our running four-stage line $0\to1\to2\to3$ with target stage $3$, the least fixed point of "target, or one step from the fixed point" is the *whole* line — every stage eventually reaches the target.
- The **greatest fixed point** captures notions like "can be sustained forever": the largest collection closed under the operator, describing behavior that never gets stuck. On the same finite acyclic line it is *empty*, correctly reporting that no stage begins an infinite forward journey.

This is precisely the vocabulary of the **modal $\mu$-calculus**, the expressive fixed-point logic that underpins much of modern verification of software and hardware. In it, $\mu$ denotes least fixed points and $\nu$ denotes greatest fixed points, layered on top of $\Box$ and $\Diamond$. The reflective theory, read through this lens, *is* a modal $\mu$-calculus: provability is one monotone operator among many, and the fixed-point machinery supplies the recursion.

The crowning law of this fixed-point world is **Löb's theorem**. On frames that are transitive and, crucially, **well-founded** — meaning there is no infinite ascending chain of reasoning steps, so every backward journey must terminate — provability satisfies

$$\Box(\Box P \to P) \to \Box P.$$

Read it slowly: *if it is provable that "the provability of $P$ implies $P$," then $P$ is already provable.* This astonishing statement, the modal heart of Gödel's second incompleteness theorem, is exactly the fixed-point law of self-reference made safe by well-foundedness. Its proof is an induction that works precisely because the reasoning steps cannot go up forever; every self-referential loop must eventually hit bottom. A numerical check over a strict-order frame confirms Löb's law holds for every proposition there.

## Why any of this matters

Self-reference is where logic gets both its deepest paradoxes and its deepest theorems. The liar's sentence, Gödel's undecidable statements, the halting problem — all are variations on the theme of a system describing itself. A reflective theory domesticates this power. It gives self-reference a home where it can be studied rather than feared, and it pins down, with a single frame condition, the exact border between the safe and the explosive.

The practical resonance is real. Modal fixed-point logics like the one lurking here are the mathematical backbone of *model checking*, the technology that verifies whether a chip design or a network protocol will ever reach a bad state or can keep running forever. "Eventually reaches the target" and "can be sustained indefinitely" are precisely least and greatest fixed points of monotone operators — the very things Knaster–Tarski hands us. And the provability modality, with its careful distinction between "provable" and "provably provable," is a small laboratory for the epistemics of *staged* knowledge: what a reasoner, a program, or an agent can guarantee now versus what it can guarantee about its own future guarantees.

The moral is compact and, once seen, hard to unsee. A statement can know it is provable without being able to prove that it knows — but only for as long as its provability remains near-sighted. Grant provability the far-sightedness to see all its own consequences, and the humble word "provably" folds in on itself: provable becomes provably provable, and the horizon, along with the strange sentences that lived there, disappears.
