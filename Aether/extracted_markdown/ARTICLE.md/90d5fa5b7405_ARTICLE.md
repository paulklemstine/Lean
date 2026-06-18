# When Computers Play Games to Prove Programs Identical

## A surprising link between abstract games, observation, and the hidden structure of computation

Imagine two black boxes sitting on a table. Each has a button on the front and a small display. When you press the button, the display changes, and new buttons might appear. You can press buttons, watch what happens, and press more buttons. The question is deceptively simple: **Are these two boxes doing the same thing?**

This question — whether two systems behave identically — sits at the heart of computer science, mathematics, and even philosophy. It's the question a chip designer asks when verifying that a new processor design matches its specification. It's the question a security analyst asks when checking whether a patched program leaks the same information as the original. It's even the question a cognitive scientist might ask when comparing two neural circuits that seem to produce the same behavior.

For decades, mathematicians have known three completely different ways to answer this question. What a recent breakthrough in mathematical formalization has now shown is that these three methods are, in a deep and precise sense, the same — and the proof is certified by machine, leaving no room for human error.

---

## Three Ways to See the Same Thing

The first approach is what you might call the **engineering method**. Take both systems, run them forward a few steps, and record what you see. If at every step, the pattern of possible futures looks identical, then the systems are the same — at least as far as you've looked. This is like testing two algorithms by running them on the same inputs and checking that the outputs match. Engineers do this every day. Mathematicians call it *behavioral observation*.

The second approach is the **game method**, and it's far more dramatic. Imagine two players: the Challenger and the Defender. The Challenger tries to prove the systems are different by picking a move in one system and daring the Defender to find a matching move in the other. If the Defender can always respond — no matter what the Challenger tries, no matter how many rounds they play — then the systems are equivalent. This isn't just a metaphor; it's a precise mathematical game with exact rules. It descends from a tradition in logic called Ehrenfeucht–Fraïssé games, invented in the 1950s to study the expressive power of logical languages.

The third approach is the **logical method**. Write down every property you can express in a certain formal language — a language with words like "it's possible that..." and "it's necessary that..." — and check whether both systems satisfy exactly the same properties. If no formula in your language can tell them apart, they're equivalent.

Here's the remarkable fact: **all three methods give the same answer.** Not approximately the same. Not usually the same. *Exactly* the same, in every case, with a rigorous mathematical proof.

---

## The Triangle That Took Sixty Years

The intellectual roots of this equivalence stretch back to the 1960s and 1970s, when the foundations of theoretical computer science were being laid. Robin Milner, one of the founding figures of the field, introduced the notion of *bisimulation* — a way of saying that two processes are indistinguishable to any observer. Matthew Hennessy and Milner then proved a landmark result: for systems with finitely many behaviors at each step, bisimulation coincides exactly with logical indistinguishability. This became known as the Hennessy-Milner theorem.

Meanwhile, coalgebra — a branch of abstract mathematics that studies systems from the outside in, by their observable behavior rather than their internal construction — was developing its own perspective. Coalgebraists showed that behavior could be captured by a single mathematical map: send each state to its "behavior portrait," and two states are equivalent exactly when their portraits match.

And game theorists had their own version: the back-and-forth game, where bounded rounds of challenge and response capture exactly the distinctions expressible in bounded logical languages.

Each community knew its own version of the story. But formalizing the complete triangle — showing that behavioral portraits, game strategies, and logical formulas all carve out exactly the same equivalence — and doing so with *machine-checked mathematical certainty*, had never been done.

Until now.

---

## What the Proof Actually Shows

The new result establishes three theorems, each connecting two vertices of the triangle.

**First**, it shows that if two states produce the same behavior when you observe them to depth *d* — collecting the set of observable futures up to *d* steps ahead — then a Defender can always win the *d*-round game against any Challenger. Conversely, if the Defender wins, the observations match. This links the *coalgebraic* (observation-based) and *game-theoretic* perspectives.

**Second**, it shows that winning the *d*-round game is equivalent to satisfying the same formulas of modal depth at most *d*. The key insight is constructive: when the game fails, the proof *builds* a specific formula that distinguishes the two states. This formula is a kind of smoking gun — a concrete, finite description of the difference. This links the *game-theoretic* and *logical* perspectives.

**Third**, combining these, it establishes the full triangle: observation, game, and logic all define exactly the same notion of equivalence at every depth. And as a consequence, any system that is fully bisimilar (where a Defender wins at *every* depth) must be equivalent in all three senses simultaneously.

---

## Why Machine Verification Matters

Mathematical proofs, even when published in top journals, sometimes contain errors. Famously, Voevodsky — a Fields Medalist — discovered that a published proof he relied on was wrong, which shook his confidence in informal mathematics and led him to advocate for computer-checked proofs.

The triangle of equivalences involves subtle arguments: structural induction on formulas, back-and-forth constructions with finite sets, and careful tracking of quantifier depth. These are exactly the kinds of arguments where off-by-one errors, forgotten edge cases, and subtle logical slips can hide for years.

By formalizing the entire development in a proof assistant — a computer program that checks every logical step — the result achieves a level of certainty that traditional publication cannot match. The computer verified not just the main theorems but every lemma, every intermediate step, every implicit assumption. If the proof compiles, it is correct. Period.

---

## A New Tool for Program Security

One of the most immediate applications is in computer security. When a software developer patches a security vulnerability, they need to know: does the patched program behave the same as the original from the user's perspective, while fixing the bug from the attacker's perspective?

The game-theoretic characterization provides a precise answer. Model the program as a transition system. The patch is secure if no bounded observer (modeled as a Challenger playing finitely many rounds) can distinguish the patched version from the original. The separating formula, when it exists, tells you exactly *what* observation reveals the difference — and therefore what an attacker could exploit.

In tests, this approach successfully identified that a "leaky" program variant — one that occasionally exposes internal state — is indistinguishable from its secure counterpart to shallow observers but detectable by observers who look four steps ahead. The distinguishing formula ◇¬◇¬¬◇¬◇⊤ (translated: "there exists a future where you can observe a state from which certain deeper futures are blocked") precisely characterizes the information leak.

---

## Compression and Minimization

Another application is system minimization. Many real-world systems have redundant states — different internal configurations that produce identical external behavior. The behavioral observation map automatically identifies these redundancies.

In experiments with a six-state system, the behavior map at depth 2 reduced it to just three equivalence classes, identifying pairs of states that no depth-2 observation could distinguish. This is the computational backbone of *state-space reduction*, a technique critical in model checking — the automated verification of hardware and software systems against formal specifications.

The formally verified triangle guarantees that this reduction is correct: states identified by the behavior map are exactly those that satisfy the same logical properties and survive the same game challenges.

---

## The Bigger Picture

What makes this result more than a technical achievement is what it connects. The game perspective links to finite model theory and descriptive complexity — deep areas of mathematical logic concerned with what can and cannot be expressed in bounded languages. The coalgebraic perspective links to category theory and the abstract study of dynamical systems. The modal logic perspective links to knowledge representation, artificial intelligence, and the philosophical study of possibility and necessity.

The triangle of equivalences says that these aren't separate subjects studying different things. They are three views of *one mathematical reality*. A certified algorithm for checking game equivalence is simultaneously a certified algorithm for checking logical equivalence and coalgebraic equivalence. A theoretical advance in one domain automatically transfers to the other two.

This kind of unification — proving that different mathematical frameworks are secretly the same — is one of the most powerful moves in all of mathematics. When it happens, it doesn't just solve one problem. It creates a bridge that lets ideas, techniques, and algorithms flow freely between fields that previously couldn't communicate.

---

## What Comes Next

The current results apply to finite-depth observations of finitely branching systems. Several natural extensions beckon:

**Infinite depth.** The bounded results approximate full bisimulation but don't capture it exactly. Under what conditions does the finite approximation stabilize? A natural conjecture — that for finite-state systems with *n* states, checking *n²* rounds suffices — remains open and computationally testable.

**Labeled transitions.** Real-world systems don't just move between states; they perform *actions* — reading inputs, producing outputs, sending messages. Extending the triangle to labeled transition systems would directly connect the results to process algebras like CCS and CSP, the workhorses of concurrent system verification.

**Higher-order processes.** When the "states" of a system are themselves programs — as in the lambda calculus, the mathematical foundation of functional programming — the transition systems become infinitely branching and the analysis becomes dramatically more subtle. Connecting the bounded game theory to lambda calculus semantics would open a new chapter in the theory of programming languages.

Each of these directions is not merely speculative. The current formalization provides the infrastructure — definitions, lemma libraries, proof techniques — that makes the next steps achievable rather than aspirational.

---

## The Art of Seeing Structure

At its core, this work is about one of the oldest questions in human inquiry: when are two things the same?

The answer, it turns out, depends on how carefully you look. Two states may appear identical when you look one step ahead but reveal differences when you look two steps ahead. They may survive three rounds of a game but fail on the fourth. They may satisfy a thousand formulas but be separated by the thousand-and-first.

The triangle of equivalences tells us something profound: the answer doesn't depend on *which* method of looking you choose. Observation, challenge, and description are three facets of one diamond. And now, for the first time, a computer has verified that the diamond has no flaws.
