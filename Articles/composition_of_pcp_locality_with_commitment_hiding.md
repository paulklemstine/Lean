# Two Locked Boxes and a Shuffled Deck: How to Prove You Know a Secret Without Revealing a Single Bit

## A puzzle from the world of maps

Suppose you have coloured a huge map — thousands of countries — so that no two neighbouring countries share a colour, and you have managed to do it with only three colours. That is a genuinely hard thing to achieve; finding such a colouring for an arbitrary map is one of the classic computationally intractable problems.

Now a sceptic appears. She does not believe you. You would like to convince her that your colouring exists and works. But you would also very much like *not* to hand her the colouring, because it is valuable, or secret, or simply because you would rather she solve her own problems.

Is there a way to convince someone that a solution exists without leaking anything at all about it?

There is, and the classic protocol reads like a magic trick:

1. Before the sceptic looks, you **shuffle the colours**: you pick one of the six ways to permute the palette $\{\text{red}, \text{green}, \text{blue}\}$ uniformly at random and apply it to your entire colouring. A valid colouring stays valid under any permutation of the palette.
2. You write the (permuted) colour of each country on a card, put each card in its own **locked box**, and hand all the boxes to the sceptic.
3. She picks **one border** — a single pair of neighbouring countries — at random and asks you to unlock just those **two** boxes.
4. You unlock them. She checks that the two colours differ. If they do, she is a little more convinced; if not, she has caught you cheating.

Repeat this many times (with a fresh shuffle each round) and a cheating prover is caught with overwhelming probability. That is the *soundness* half of the story, and it is well understood.

This article is about the other half. **Why does the sceptic learn nothing?** She *does* see something: two colours on a border, every round. In what sense is data she genuinely receives "nothing"?

The answer has an exact mathematical shape. The whole thing factors into two completely independent ingredients — one about the locked boxes, one about the shuffle — and their composition is *exact*: no approximation, no error term, no "negligible difference" hand-waving. This article explains that factorization.

## What "learns nothing" actually means

The standard definition is a beautiful piece of conceptual engineering. It says:

> The verifier learns nothing if everything she sees could have been manufactured, with exactly the right frequencies, by someone who does not know the secret at all.

Concretely, one writes down the *transcript* — the complete record of everything the verifier sees:

$$\tau = (\text{commitment}, \ \text{verifier's coins}, \ \text{opened symbols}, \ \text{opening data}).$$

The real interaction, run with a genuine secret and honest randomness, produces a probability distribution over transcripts. Now imagine a **simulator**: a machine with no secret, no colouring, no witness of any kind, that nevertheless prints out fake transcripts. If the simulator's distribution over transcripts is *identical* to the real one, then whatever the verifier can extract from a real conversation she could equally have extracted from a conversation she fabricated alone in a room. Real information cannot be conjured from nothing, so the conversation carried none.

When the two distributions are exactly equal — not merely close — the protocol is said to have **perfect honest-verifier zero knowledge**. That is the property we will establish, in a form that applies far beyond map-colouring.

## The abstract machine: committed local oracles

Strip the colouring story down to its skeleton and you get the following object, which we shall call a **committed local-oracle protocol**.

There is a set $I$ of coordinates — think "countries" — and an alphabet $A$ of symbols. The prover holds a randomized **proof string**: for each value $p$ of its private randomness, a function $\mathrm{proof}(p) : I \to A$. In the colouring example, $I$ is the set of countries, $A$ is the three-colour palette, and $\mathrm{proof}(\pi)$ is the colouring composed with the palette permutation $\pi$.

There is a **commitment scheme**: two functions

$$\mathrm{com}(u, \rho) \in C, \qquad \mathrm{open}(u, \rho, T) \in O,$$

where $u : I \to A$ is the string being committed, $\rho$ is fresh commitment randomness, $T \subseteq I$ is the set of coordinates being revealed, and $C, O$ are the sets of possible commitment messages and opening data. The first is what you hand over up front (the sealed boxes); the second is what you hand over when asked to reveal the coordinates in $T$ (the keys).

There is a **verifier** who tosses coins $r$ and, as a function of those coins alone, queries a set $Q(r) \subseteq I$ of coordinates. The defining feature of the whole framework is **locality**: there is a constant $q$ with

$$|Q(r)| \le q \quad \text{for every } r.$$

In the colouring protocol, $q = 2$: the proof string may be astronomically long, but the verifier looks at only two symbols of it.

The transcript of one execution is then
$$\tau = \bigl(\mathrm{com}(\mathrm{proof}(p), \rho), \ r, \ \mathrm{proof}(p)\big|_{Q(r)}, \ \mathrm{open}(\mathrm{proof}(p), \rho, Q(r))\bigr),$$
where $\mathrm{proof}(p)\big|_{Q(r)}$ denotes the *partial* assignment that equals $\mathrm{proof}(p)(i)$ for $i \in Q(r)$ and is undefined elsewhere. That "undefined elsewhere" is not decoration: it is a formal guarantee that the transcript, as a mathematical object, contains no trace of the unopened coordinates other than whatever the commitment and openings happen to carry. One can prove the corresponding bookkeeping fact directly: **the number of coordinates on which the transcript's partial assignment is defined never exceeds $q$**, regardless of how large $I$ is.

## Ingredient one: the boxes must be opaque

The first requirement concerns the commitment. Intuitively it should be that "an unopened box reveals nothing about its contents". The exact form we need is slightly stronger and much more usable:

> **Perfect hiding of unopened coordinates.** For any two strings $u, v : I \to A$ that *agree on a set $T$*, there is a bijection $e$ of the commitment-randomness space such that for every $\rho$,
> $$\mathrm{com}(u, \rho) = \mathrm{com}(v, e(\rho)) \quad\text{and}\quad \mathrm{open}(u, \rho, T) = \mathrm{open}(v, e(\rho), T).$$

Read it as a re-labelling principle. Two strings that look the same *on the revealed part* are interchangeable from the verifier's point of view: any run with $u$ can be re-labelled, by changing only the prover's internal coin flips, into a run with $v$ producing an identical commitment *and* identical keys.

This is not an assumption pulled from the air; it is what real schemes provide. The simplest example is the **one-time pad**. Let the alphabet $A$ be any finite abelian group. Commit to $u : I \to A$ by choosing a uniformly random pad $\rho : I \to A$ and publishing

$$\mathrm{com}(u, \rho) = u + \rho \quad (\text{coordinate-wise}),$$

and open a set $T$ by revealing the pad on $T$, that is $\rho|_T$. The verifier can then recover $u|_T$ from the commitment and the pad; the commitment is genuinely binding-in-use and the openings genuinely informative.

Does it hide? Take $u$ and $v$ agreeing on $T$, and use the translation
$$e(\rho) = \rho + (u - v).$$
This is a bijection of the pad space (translation in a group always is). It sends the commitment $u + \rho$ to $v + e(\rho) = v + \rho + u - v = u + \rho$ — the same commitment. And on the opened set $T$ we have $u = v$, so $u - v$ vanishes there, so $e(\rho)$ and $\rho$ agree on $T$ and the openings are literally identical. Hiding, proved, in three lines.

## Ingredient two: the visible part must be fake-able

The second requirement is about what the verifier *does* see. She sees $q$ symbols. Those symbols are real data. The requirement is that their distribution be reproducible without the secret:

> **Perfect simulation of the opened coordinates.** There is a simulator which, on verifier coins $r$ and its own randomness $s$, produces a string $\mathrm{sim}(r, s)$ such that for every $r$, the distribution of $\mathrm{proof}(p)|_{Q(r)}$ over uniform prover randomness $p$ equals the distribution of $\mathrm{sim}(r,s)|_{Q(r)}$ over uniform simulator randomness $s$.

Counting rather than dividing (which keeps everything in the integers and avoids any question of rounding), this says: for every $r$ and every candidate partial view $t$,

$$\#\{p : \mathrm{proof}(p)|_{Q(r)} = t\} \cdot |S| \;=\; \#\{s : \mathrm{sim}(r,s)|_{Q(r)} = t\} \cdot |P|,$$

with $P$ and $S$ the prover's and simulator's randomness spaces.

There is a very convenient way to certify this: exhibit a bijection. If for each $r$ there is a bijection $\Phi_r : P \to S$ from prover randomness to simulator randomness that preserves the opened view, i.e. $\mathrm{proof}(p)|_{Q(r)} = \mathrm{sim}(r, \Phi_r(p))|_{Q(r)}$, then the simulation is perfect. A bijection does two jobs at once — it equates the sizes of the two randomness spaces and it matches the fibres of the "opened view" map.

For the 3-colouring protocol, that bijection is where the palette shuffle earns its keep, and the underlying fact is a small gem of group theory.

## Why exactly six shuffles: sharp 2-transitivity

Fix a border, i.e. a pair of adjacent countries $x \ne y$ with colours $c(x) \ne c(y)$. The verifier will see the pair $(\pi(c(x)), \pi(c(y)))$ for a uniformly random permutation $\pi$ of the three colours.

What is the distribution of that pair? There are six ordered pairs of *distinct* colours from a palette of three. And there are exactly six permutations of three colours. The key fact is:

> **For any distinct $x \ne y$ and any distinct targets $a \ne b$ in a three-element alphabet, there is exactly one permutation $\pi$ with $\pi(x) = a$ and $\pi(y) = b$.**

Existence is a two-swap construction: first swap $x$ with $a$, then swap the image of $y$ with $b$ (checking the second swap does not disturb $a$). Uniqueness is the observation that a permutation of a three-element set is pinned down by its values at two points — the third point has nowhere else to go, because it must map to the unique remaining element.

Group theorists call this *sharp $2$-transitivity*: the symmetric group on three letters acts on ordered pairs of distinct letters simply transitively. Six permutations, six target pairs, a perfect matching between them.

The consequence is immediate and decisive. **The pair of colours revealed on the challenged border is exactly uniform on the six ordered pairs of distinct colours, no matter what the underlying colouring is.** The verifier is watching a fair six-sided die. So the simulator's job is trivial: on being told which border was challenged, it rolls that die itself — picks a uniformly random ordered pair of distinct colours — and writes those two colours down. It has never seen the colouring, and its output has exactly the right distribution. Here $\Phi_r$ is the map sending the palette permutation $\pi$ to the pair $(\pi(c(x)), \pi(c(y)))$, and sharp $2$-transitivity is precisely the statement that this map is a bijection.

## The composition theorem

Now the two ingredients meet, and the main result is the statement that they compose *exactly*.

> **Composition Theorem (Perfect honest-verifier zero knowledge).** Let a committed local-oracle protocol perfectly hide unopened coordinates, and let a simulator perfectly simulate the opened coordinates. Then for *every* transcript $\tau$,
> $$\Pr[\text{real interaction produces } \tau] = \Pr[\text{simulation produces } \tau].$$

Not close. Equal.

The proof is a two-dimensional counting argument whose shape explains *why* the two hypotheses are the right ones.

Fix a target transcript $\tau = (c, r_0, t, o)$. Ask: how many triples (prover randomness, commitment randomness, verifier coins) produce exactly $\tau$?

The verifier coins are forced to be $r_0$. That leaves a sum over prover randomness $p$: each $p$ contributes, provided its opened view matches $t$, the number of commitment randomnesses $\rho$ giving commitment $c$ and opening data $o$. Call that number the **fibre count** of $\mathrm{proof}(p)$. So:

$$\#\{\text{runs producing } \tau\} \;=\; \sum_{p \,:\, \mathrm{proof}(p)|_{Q(r_0)} = t} \mathrm{fib}\bigl(\mathrm{proof}(p)\bigr).$$

The count has split into a **horizontal** factor — which prover randomnesses produce the visible view $t$ — and a **vertical** factor — how many commitment coins are compatible with $(c, o)$.

Now hiding does its work. Every $p$ in the sum has the same opened view, namely $t$; so any two of the corresponding proof strings agree on $Q(r_0)$; so by the re-labelling bijection, their fibre counts are equal. (Formally: hiding implies the fibre count depends on the message only through its restriction to the opened set.) The sum is therefore a *constant* $N$ times the number of terms:

$$\#\{\text{runs producing } \tau\} \;=\; \#\{p : \mathrm{proof}(p)|_{Q(r_0)} = t\} \cdot N.$$

The identical computation on the simulator's side gives $\#\{s : \mathrm{sim}(r_0,s)|_{Q(r_0)} = t\} \cdot N$ — the *same* $N$, because the simulator's string also has opened view $t$, and hiding does not care where the string came from.

Now simulation does its work: it says precisely that the two remaining counts agree after cross-multiplying by the randomness-space sizes. Multiply through and the two transcript counts are proportional with the right constant; divide by the total number of coin sequences and the two probabilities are equal. $\square$

Two remarks on the fine print, both of which matter. First, when the fibre in question is *empty* — when no prover randomness yields the view $t$ — one must argue that the simulator's fibre is empty too, which uses the (harmless) fact that the prover has at least one possible coin sequence. Second, the commitment- and verifier-randomness spaces are *not* assumed non-empty; if either is empty, both distributions are identically zero and the theorem holds vacuously but correctly.

Two corollaries fall out for free. Since the two distributions agree transcript by transcript, they agree on every **event** — every set of transcripts the verifier might care about. And every **distinguisher** — any function assigning a score to transcripts, however cleverly designed, with no bound on its computational power — has *exactly the same expected score* in the real interaction and in the simulation. The distinguishing advantage is zero, not negligible.

## Both hypotheses are load-bearing

A composition theorem is only interesting if both inputs are genuinely required. They are, and the counterexamples are tiny.

**Drop hiding.** Take a one-query protocol over two coordinates and the alphabet $\{0,1\}$, whose proof string is $0$ on coordinate $0$ and $1$ on coordinate $1$, and whose "commitment" is the identity map — it publishes the entire string. The verifier only ever queries coordinate $0$, so the opened view is perfectly simulatable: a simulator writing $0$ everywhere reproduces it exactly. But the unopened coordinate is broadcast in the clear, and the honest transcript occurs with probability $1$ in the real interaction and $0$ in the simulation. The instructive point is that the leak is *invisible in the opened view*.

**Drop simulation.** Take a one-coordinate one-time-padded protocol whose proof string is constantly $0$ — perfectly hiding, as proved above — and equip it with a simulator that opens $1$ instead of $0$. A transcript that really occurs with probability $1/2$ is produced by the simulator with probability $0$. Failure again, at query complexity one.

Hiding controls the unopened part; simulation controls the opened part; each governs a direction the other cannot see.

**And transitivity is not enough.** Return to 3-colouring and replace the shuffle by something weaker but still natural: instead of a uniformly random permutation of the palette, let the prover apply a uniformly random *cyclic shift* $c \mapsto c + d$ with $d \in \{0,1,2\}$. The cyclic group of order three is transitive on colours — every colour can be sent to every colour — so one might hope that suffices. It does not. A shift preserves the *difference* of the two colours along a border, so the opened pair leaks that difference, which is a genuine function of the witness.

This is provable as a hard impossibility, not merely a failure of one particular simulator. Take the two-vertex, one-edge instance and the two proper colourings $(0,1)$ and $(0,2)$. Under shift randomization, the opened view "colour $0$ here, colour $1$ there" occurs with probability $1/3$ for the first colouring and probability $0$ for the second. A simulator does not see the colouring, so it produces a single distribution; that distribution cannot be both $1/3$ and $0$ on the same view. **No simulator whatsoever, over any randomness space, works for both.** Sharp $2$-transitivity is not a convenience of the proof; it is the thing being used.

## Why locality is the hero

Step back and the architecture is clear. Hiding is a statement about the commitment: the vertical direction, the space of commitment coins, is symmetric enough that the verifier cannot see through the boxes. Simulation is a statement about the alphabet's symmetry group acting on the visible window: the horizontal direction is *uniform* enough to be forged.

Locality is what makes the horizontal direction small enough to be forgeable at all. If the verifier looked at every coordinate, the opened view would be the whole proof string and a witness-independent simulator would be tantamount to solving the problem. With $q$ queries, the simulator only has to get $q$ symbols right — and for a suitably symmetric alphabet, those $q$ symbols are uniform on the admissible configurations, hence free.

Read the counting identity once more with this in mind:

$$\#\{\text{runs producing } \tau\} = \#\{p : \mathrm{proof}(p)|_{Q} = t\} \cdot \mathrm{fib}(t).$$

The right-hand side never mentions a single coordinate outside $Q$. **Whatever a $q$-query protocol leaks, it leaks only through the $q$-dimensional marginal of the prover's proof distribution.** That is a graded statement, interpolating between perfect zero knowledge (the $q$-marginal is witness-independent) and total disclosure (when $q$ is the whole index set). It suggests that "how much does a local protocol leak?" has a clean answer in terms of how far the $q$-marginals depend on the witness — a question we have made precise but not yet quantified.

## Coda

There is something faintly paradoxical about zero-knowledge proofs, and close inspection does not dissolve the paradox so much as change its shape. The verifier really does receive data. She really does become convinced. And yet the data is, in a mathematically exact sense, data she could have generated herself — a fair die roll, and a sealed box that could equally have held anything.

What makes the trick work is that these two facts live in different dimensions of the same picture and never interfere. The boxes handle everything you do not see. The shuffle handles everything you do. Locality guarantees that what you do see is small. And when you multiply the two guarantees together, the arithmetic is exact: the real conversation and the imaginary one are not approximately the same distribution. They are the same distribution.
