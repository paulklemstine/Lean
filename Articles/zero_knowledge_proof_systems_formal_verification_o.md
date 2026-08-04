# The Colour of Secrets

## How to prove you know something without revealing a single thing about it

Imagine you have solved a fiendish puzzle — a map coloured so that no two neighbouring
countries share a colour, using only three crayons. You want to convince a sceptic that
you really did it. But you do not want to hand over the solution. Maybe you will sell it
later. Maybe it is a password. Maybe the whole point is that only you should know it.

Can you prove you know the answer, while revealing *nothing whatsoever* about the answer?

Astonishingly, yes. And the mechanism is so simple that you can carry it out with hats,
crayons and a coin. What follows is an account of that mechanism, with the exact
guarantees it provides — completeness, soundness, and privacy — stated and justified
precisely. Each guarantee turns out to be a small, sharp piece of mathematics.

---

## The puzzle: three colours, no clashes

Let $G$ be a graph: a set $V$ of *vertices* and a finite set $E$ of *edges*, each edge a
pair $(u,v)$ of vertices. A **3-colouring** is a function $c : V \to \{0,1,2\}$ assigning
one of three colours to each vertex. It is **proper** if it never gives the two endpoints
of an edge the same colour:

$$c(u) \neq c(v) \qquad \text{for every edge } (u,v) \in E .$$

Deciding whether a given graph admits a proper 3-colouring is one of the classical hard
problems of computer science — it is NP-complete, and famously so. This hardness is not
an obstacle here; it is the *point*. Because 3-colourability is NP-complete, every
statement in NP — "this number factors", "this program halts within a thousand steps",
"this transaction is valid" — can be translated into a graph 3-colouring question. A
privacy-preserving proof for 3-colouring is therefore a privacy-preserving proof for
*everything* efficiently checkable.

## The protocol: hats over the vertices

Here is the whole idea, in physical form.

1. **Shuffle the palette.** You, the *prover*, take your secret proper colouring $c$ and
   apply a random permutation to the three colours — perhaps every red becomes blue,
   every blue becomes green, every green becomes red. There are $3! = 6$ such
   relabellings, and you pick one uniformly at random. The result is still a proper
   colouring; renaming colours cannot create a clash where there was none.

2. **Commit.** You write the recoloured colour of each vertex on a slip of paper, put
   each slip in a locked box, and place the boxes on the table — one per vertex. You
   cannot change what is inside; the *verifier* cannot see inside.

3. **Challenge.** The verifier picks one edge $(u,v)$, uniformly at random from $E$, and
   says: "open those two."

4. **Respond.** You hand over the keys to boxes $u$ and $v$.

5. **Verify.** The verifier looks at the two revealed colours. She accepts if and only if
   they differ.

That is one round. It is short, it is cheap, and its analysis splits into exactly three
questions. *Does an honest prover always succeed? Does a cheating prover get caught? Does
the verifier learn anything?*

---

## Guarantee 1: honesty always wins

Fix a graph with at least one edge and a colouring $c$. Let

$$\alpha(E, c) \;=\; \frac{\#\{\,e \in E \;:\; c(e_1) \neq c(e_2)\,\}}{\#E}$$

be the **acceptance probability**: the fraction of edges on which the committed colouring
survives inspection. Likewise let

$$\rho(E, c) \;=\; \frac{\#\{\,e \in E \;:\; c(e_1) = c(e_2)\,\}}{\#E}$$

be the **rejection probability**. Every edge is counted exactly once by one of the two
numerators, so we have the clean bookkeeping identity

$$\alpha(E,c) + \rho(E,c) = 1 .$$

**Perfect Completeness Theorem.** *If $c$ is a proper colouring of a graph with at least
one edge, then $\alpha(E,c) = 1$: the honest prover is accepted with certainty.*

The proof is a single observation. Properness says that *every* edge $e \in E$ satisfies
$c(e_1) \neq c(e_2)$, so the filtered set of "good" edges is all of $E$, and the fraction
is $\#E / \#E = 1$. There is no failure probability at all — not a small one, not a
negligible one. Zero. An honest prover who knows a colouring never gets unlucky.

## Guarantee 2: cheating leaves a trace

Now suppose the prover does not know a colouring and commits to some $c'$ that is *not*
proper. Then at least one edge is monochromatic under $c'$, so the rejecting set is
non-empty and contains at least one of the $\#E$ edges. Hence

$$\rho(E, c') \;\geq\; \frac{1}{\#E}.$$

Combining with the bookkeeping identity gives the sharp complement:

**One-Round Soundness Theorem.** *If a committed colouring $c'$ fails to be proper on a
graph with at least one edge, then*

$$\alpha(E, c') \;\leq\; 1 - \frac{1}{\#E}.$$

The bound is unglamorous — a cheat with exactly one bad edge in a graph of a thousand
edges slips through $99.9\%$ of the time. On its own, one round is nearly worthless as a
proof. Its value is that it is *not quite* worthless, and that "not quite" compounds.

## Guarantee 3: repetition crushes the cheat

Run the protocol $k$ times, with fresh commitments and independently sampled edge
challenges each time. A prover locked into a fixed improper colouring must survive every
round, and independence multiplies the per-round bounds:

**Amplification Theorem.** *For an improper committed colouring $c'$ and any number of
rounds $k$,*

$$\alpha(E,c')^{\,k} \;\leq\; \Bigl(1 - \frac{1}{\#E}\Bigr)^{k}.$$

The proof is the monotonicity of $x \mapsto x^k$ on the non-negative reals, applied to
the one-round bound — the acceptance probability is a ratio of cardinalities and so is
never negative, which is exactly the side condition that monotonicity needs.

The consequence is the practical heart of the design. Since $(1 - 1/m)^{m} < e^{-1}$, it
suffices to take $k$ proportional to $\#E$ — say $k = 100\,\#E$ — to drive the cheating
probability below $e^{-100}$, a number smaller than the chance of guessing a randomly
chosen atom in the observable universe. A protocol whose single round is $99.9\%$
unreliable becomes, after a merely *linear* number of repetitions, more reliable than any
physical process you could name. That is the alchemy of amplification: a tiny, stubborn,
irreducible chance of detection, compounded.

---

## Guarantee 4: the verifier learns nothing — and we can say precisely what that means

The completeness and soundness guarantees make the protocol a *proof*. The next
guarantee is what makes it a *zero-knowledge* proof, and it is the subtlest of the four,
because it is a statement not about what the verifier *does* learn but about what she
*could possibly* learn.

What does the verifier actually see in one round? Two boxes open, showing an ordered pair
of distinct colours. Call the set of such observations

$$\mathcal{P} \;=\; \{(a,b) \in \{0,1,2\}^2 \;:\; a \neq b\},$$

the **distinct pairs**. There are exactly six of them.

Now, the crucial computation. The prover's secret is a proper colouring $c$; on the
challenged edge $(u,v)$ the underlying secret colours are $c(u) \neq c(v)$. But before
committing, the prover applied a *uniformly random* one of the six colour permutations.
A permutation of three symbols is determined by, and can send an ordered pair of distinct
symbols to, any other ordered pair of distinct symbols — in exactly one way. So the
revealed pair is uniformly distributed over $\mathcal{P}$:

**Transcript Uniformity Theorem.** *For any graph, any proper colouring $c$, and any
challenged edge $e \in E$, the law of the revealed pair assigns probability exactly
$\tfrac{1}{6}$ to each of the six distinct pairs.*

The number $\tfrac16$ contains no information at all about $c$. Say it another way:

**Colour-and-Edge Independence Theorem.** *Let $(E_1, c_1, e_1)$ and $(E_2, c_2, e_2)$ be
any two valid protocol instances — any two graphs, any proper colourings of them, any
challenged edges. The two resulting transcript laws are equal.*

The verifier's view on a graph she has never seen, coloured by a solution she has never
imagined, is *literally the same random variable* as her view on any other. Nothing in
what she sees can tell one from the other, because there is nothing to tell.

### The simulation paradigm

There is a beautiful way to package this, due to the founders of the subject, and it is
the definitional backbone of zero knowledge. Consider a **simulator**: a machine that
knows *nothing* — not the colouring, not even whether one exists — and simply outputs a
uniformly random element of $\mathcal{P}$. Then:

**Perfect Zero-Knowledge Theorem.** *For every graph, every proper colouring, and every
challenged edge, the law of the real transcript equals the law of the simulator's output.*

This is the punchline of the whole design. Anything the verifier can compute from a real
conversation, she could have computed *by herself, at home, without the prover*, by
flipping her own coins. A transcript that a colouring-oblivious machine can manufacture
cannot contain knowledge of a colouring. The protocol conveys conviction and nothing
else.

To make "cannot tell them apart" fully operational, let a **distinguisher** be any
deterministic rule $D$ that reads a transcript and outputs *true* or *false* — any test
whatsoever, however clever, however computationally extravagant. Its acceptance
probability under a law $\mu$ is $\sum_{p} \mathbb{1}[D(p)] \, \mu(p)$, the total mass
$\mu$ puts on the transcripts $D$ likes.

**Zero-Advantage Theorem.** *For every deterministic distinguisher $D$, every graph, every
proper colouring, and every challenged edge, $D$'s acceptance probability on the real
transcript equals its acceptance probability on the simulated transcript. Consequently
both one-sided advantages — real minus simulated, and simulated minus real — are exactly
zero.*

Note the quantifier order: the equality holds for *all* $D$ simultaneously, and it is
equality, not approximate equality. There is no security parameter, no negligible
function, no computational assumption. The privacy here is information-theoretic and
absolute. No amount of computing power helps, because there is no signal to extract.

---

## Why this matters outside the puzzle

The three-colouring game is a toy, but it is a *universal* toy. Because 3-colouring is
NP-complete, any statement whose truth can be efficiently checked given a certificate can
be mechanically rewritten as "this graph is 3-colourable", with the certificate becoming
the colouring. Combine that with the protocol above, and you get the great theorem of the
1980s: **everything provable is provable in zero knowledge**.

The practical descendants of this idea are now everywhere:

- **Authentication without passwords.** You prove you hold a secret key without ever
  transmitting it, so a compromised server learns nothing worth stealing.
- **Private blockchains.** A transaction can be proved valid — inputs exist, balances
  suffice, no double spend — without revealing sender, recipient, or amount. The whole
  industry of "zk-rollups" and shielded currencies descends from the simulation paradigm.
- **Verifiable computation.** A cloud service proves it ran your computation correctly
  without you rerunning it, and without exposing proprietary code.
- **Compliance without disclosure.** A bank proves its reserves exceed a regulatory
  threshold, or a company proves its algorithm satisfies an audit rule, without opening
  its books.

Each of these is a descendant of the same three-part skeleton: *complete* (honest parties
succeed), *sound* (cheats are caught with amplifiable probability), *zero-knowledge* (the
view is simulable from nothing).

## The shape of the argument

What is striking, once the analysis is laid out, is how the difficulty is distributed.

The **completeness** guarantee is a definitional unfolding: properness means all edges are
good, so the good fraction is one.

The **soundness** guarantee is counting: at least one bad edge out of $\#E$, so at least
$1/\#E$ rejection, so at most $1 - 1/\#E$ acceptance. The amplification is monotonicity of
powers. Nothing here requires cleverness; it requires only that the bookkeeping be exact
— and the identity $\alpha + \rho = 1$, which looks like a triviality, is doing the real
work of converting a *lower* bound on catching a cheat into an *upper* bound on the
cheat's success.

The **zero-knowledge** guarantee is where the content lives, and it lives in one sentence:
*the symmetry group of the palette acts simply transitively on ordered pairs of distinct
colours*. Six permutations, six distinct pairs, and the random relabelling smears the
secret uniformly across all of them. The privacy of the protocol is, at bottom, a group
action.

That is the aesthetic pleasure of this corner of cryptography. The security does not come
from a hard problem, a big prime, or a hash function. It comes from a symmetry. The
prover's secret survives the protocol not because it is hidden behind computational
difficulty, but because the observation is *equivariant* — the verifier sees the orbit,
never the point.

---

## Coda: what the protocol does not yet promise

Honesty about scope is part of the mathematics. The guarantees above are stated for a
model in which the locked boxes are ideal: perfectly binding (the prover cannot change a
slip) and perfectly hiding (the verifier learns nothing from a closed box). Real
commitment schemes achieve these only up to a computational assumption, and the transcript
then contains the commitments themselves as well as the openings.

The privacy statement above is for an *honest* verifier: one who really does pick her edge
uniformly at random. A verifier who chooses her challenges adaptively, in a way that
depends on the commitments, requires the classical rewinding argument to simulate — the
simulator guesses the challenge, and retries if it guessed wrong.

And the amplification theorem, as stated, bounds a prover locked into one fixed colouring
across all rounds. Handling a prover who adapts between rounds means deriving that
fixedness from the binding property of the commitment rather than assuming it.

Each of these is a well-trodden extension, and each has the same flavour: a symmetry, a
counting argument, a simulator that knows nothing. The mathematics of proving without
revealing is, in the end, the mathematics of arranging that there be nothing to reveal.
