# When Counting Meets Shape: Two Faces of Quantum Error Mitigation

## A machine that whispers, and a chorus that shouts

Imagine you ask a friend a simple yes-or-no question across a crackling
phone line. The static is so bad that any single word might be flipped:
your "yes" could arrive as "no." What do you do? The instinct is ancient
and obvious — you ask them to *repeat themselves*. Say "yes" ten times,
and even if three copies get garbled, the seven survivors still carry the
truth. You take a vote.

This humble trick — repeat, then take the majority — is the oldest idea in
the theory of reliable communication, and it turns out to be one of the
most important ideas in the youngest branch of computing: **quantum
computation**. Today's quantum machines are exquisitely powerful and
maddeningly fragile. They live in what engineers call the *NISQ era* —
Noisy Intermediate-Scale Quantum — where every measurement is a coin
half-corrupted by noise. The machines are real, they are here, but they
forget what they were doing almost as fast as they do it.

To get useful answers out of these noisy machines, researchers run the
same quantum circuit again and again, collecting a cloud of slightly-wrong
readouts, and then try to distill the truth from the crowd. This is the
art of **quantum error mitigation**. And underneath all the quantum
hardware lies a question that is, at heart, completely classical and
completely combinatorial: *given a pile of noisy votes, how many can be
wrong before the majority lies to you?*

This article tells the story of two precise, fully verified answers to two
faces of that question. The first face is the **logic of counting**: a
clean threshold theorem for majority voting. The second face is the
**logic of shape**: a theorem from algebraic topology — the mathematics of
connectedness and holes — that says, in effect, *clusters of agreement can
only grow, never shatter.* The surprise is that these two faces, one from
elementary combinatorics and one from the abstract theory of "connected
components," are describing the very same phenomenon from two different
angles. Counting and shape turn out to be old friends.

## The chorus: how many wrong votes can you survive?

Let us make the voting story exact. A single logical bit — a true answer,
either $0$ or $1$, which we will write as `false` or `true` — is measured
$n$ times. Each measurement returns a bit, but noise may have flipped it.
The whole batch of readouts is a vector
$$s : \{0, 1, \dots, n-1\} \to \{\text{false}, \text{true}\}.$$
Two simple counts describe this vector completely, for our purposes.

The first is **`ones`**: the number of measurements that came back `true`,
$$\text{ones}(s) = \#\{\, i : s(i) = \text{true} \,\}.$$

The second is **`errors`**: the number of measurements that *disagree* with
the true bit $b$ — the corrupted readouts,
$$\text{errors}(s, b) = \#\{\, i : s(i) \neq b \,\}.$$
This count is the famous **Hamming weight** of the error pattern: simply
*how many things went wrong.*

The decoder itself is the chorus taking its vote. We define the
**majority** decoder to output `true` exactly when strictly more than half
of the readouts came back `true`:
$$\text{majority}(s) = \big[\, 2 \cdot \text{ones}(s) > n \,\big].$$
The strict "greater than" matters: on an exact tie, the decoder falls back
to `false`. (Ties are a real subtlety — we will return to them.)

Now the central question: **when is the vote trustworthy?** The answer is
as clean as one could hope.

> **The Repetition-Code Correctness Theorem.** If strictly fewer than half
> of the readouts are corrupted — that is, if $2 \cdot \text{errors}(s,b) < n$
> — then majority voting recovers the true bit exactly: $\text{majority}(s) = b$.

In plain words: *as long as the liars are outnumbered, the truth wins.* If
you measure $n = 7$ times and at most $3$ readouts are wrong (since
$2 \cdot 3 = 6 < 7$), the majority is guaranteed correct, no matter *which*
three were flipped. This is not a statement about averages or
probabilities — it is an ironclad, worst-case guarantee. Even an
adversary who chooses exactly which measurements to corrupt cannot fool the
decoder, as long as they are kept to a minority.

A concrete example makes the threshold tangible. Take $n = 5$ and suppose
the true bit is `true`. Say two readouts get flipped to `false`, so the
batch reads $(\text{true}, \text{true}, \text{true}, \text{false},
\text{false})$. Then $\text{ones}(s) = 3$ and $2 \cdot 3 = 6 > 5$, so the
decoder returns `true` — correct. The error count was $2$, and indeed
$2 \cdot 2 = 4 < 5$. We were under threshold, and the truth survived.

## The knife-edge: why the threshold is exactly sharp

A guarantee is only as interesting as its boundary. Could a cleverer
decoder survive *more* than $n/2$ errors? No — and we can prove it can't,
because at exactly the halfway point the vote genuinely fails.

> **Tightness of the Threshold.** For every batch of even length $n = 2k$
> (with $k \geq 1$), there exists a readout vector with *exactly* $k$ errors
> — precisely half corrupted — on which the majority decoder returns the
> wrong answer.

The witness is beautifully simple. Let the true bit be `true`, and corrupt
exactly the first half of the measurements to `false`, leaving the second
half correct. Now there are exactly $k$ `true` readouts and $k$ `false`
readouts — a perfect tie. Since the decoder requires *strictly* more than
half to vote `true`, the tie breaks toward `false`, and the decoder
announces the wrong answer. Half-corruption is exactly where the guarantee
dies; one error fewer and the truth is safe, one error more (well, the tie
itself) and it is lost. The threshold $n/2$ is not approximate — it is a
knife-edge.

There is one delicate twist worth savoring, because it shows how careful
the mathematics has to be. You might hope for a perfect "if and only if":
*the decoder is correct precisely when fewer than half the votes are
wrong.* This clean biconditional **does** hold — but only for the `true`
codeword:

> **Exact Threshold for the `true` Codeword.** The majority decoder
> returns `true` if and only if $2 \cdot \text{errors}(s, \text{true}) < n$.

For the `false` codeword the biconditional *fails*, and it fails exactly at
the tie. Because the decoder breaks ties toward `false`, on a perfect tie
it correctly outputs `false` even though half the votes were wrong — so the
"only if" direction breaks. This asymmetry is not a bug in the theory; it
is the honest fingerprint of the strict-inequality tie-break, and naming it
precisely is part of what it means to *prove* something rather than merely
believe it.

## The other face: shape instead of counting

Now we change our eyes entirely. Forget counting wrong votes. Instead,
imagine *plotting* the readouts as points and watching how they cluster.

This is the perspective of **persistent homology**, a tool from algebraic
topology that has, over the last two decades, become the workhorse of
"topological data analysis." The idea is to take a cloud of data points and
ask not *where* they are but *what shape* they form: how many separate
clusters, how many loops, how many voids. The most basic of these
shape-numbers is the count of **connected components** — the number of
distinct clusters. Topologists call it the **zeroth Betti number**, written
$\beta_0$.

Here is the construction adapted to our noisy measurements. Picture each
readout as a vertex. Now introduce a *proximity threshold* $t$, a dial you
slowly turn up. At each setting, you draw a link between two vertices if
they are "close enough" at that threshold. As you turn the dial up, more
and more links appear. At first every point is its own island
($\beta_0$ large); as links accumulate, islands merge into continents
($\beta_0$ shrinks). The record of *when* each cluster is born and when it
dies as you sweep the dial is called a **barcode**, and it is the
fingerprint of the data's shape.

The single most fundamental fact about this process — the bedrock on which
all of $H_0$ persistence rests — is this: **adding links can only merge
clusters, never split them.** Turn the dial up, and the number of clusters
can only go down or stay the same. It can never go up. Components merge;
they do not spontaneously shatter.

To state this precisely, we model "linked at threshold $t$" as a relation
$r$ on a finite set of vertices $V$. Two vertices are in the same cluster
when they are connected by a chain of links — formally, when they are
related by the *equivalence closure* of $r$. The number of clusters is then

$$\beta_0(r) = \#\big(\text{clusters of } r\big) = \#\big(V / {\sim_r}\big),$$

the number of equivalence classes. A step of the filtration is a *refinement*:
a coarser relation $r_2$ that contains a finer one $r_1$ (every link present
at the lower threshold is still present at the higher one). And the theorem is:

> **Persistence of $H_0$.** If $r_1 \subseteq r_2$ — that is, if the second
> proximity graph contains all the links of the first and possibly more —
> then $\beta_0(r_2) \leq \beta_0(r_1)$. The number of connected components
> is monotone non-increasing along the filtration.

The proof has a satisfying conceptual core. Every cluster at the *finer*
threshold sits inside exactly one cluster at the *coarser* threshold —
adding links can only fuse clusters together, so there is a natural map
sending each fine cluster to the coarse cluster that swallows it. This
**component map** is *surjective*: every coarse cluster is the destination
of at least one fine cluster (indeed, it contains points, and each point's
fine cluster lands on it). And whenever you have a surjection from one
finite set onto another, the source must be at least as large as the
target. Hence there are at least as many fine clusters as coarse ones:
$\beta_0(r_2) \le \beta_0(r_1)$. Counting collapses out of pure shape.

To be sure this is not a vacuous statement — to be sure clusters *really do*
merge and the inequality is not secretly always an equality — there is an
explicit witness on a two-element vertex set, where two genuinely distinct
clusters at the finer threshold collapse into one at the coarser threshold.
The component map there sends two things to one: a real merge event,
caught in the act.

## Two faces of one coin

Why tell these two stories side by side? Because they are the same story.

When you run a NISQ experiment many times and collect the noisy readouts,
the *correct* answers naturally cluster together — they agree with one
another — while the scattered errors are exactly that: scattered. In the
language of the chorus, the correct answers form the **majority class**. In
the language of shape, those same correct answers form the **largest
connected component** of the proximity graph: one big continent of
agreement surrounded by an archipelago of noise.

The majority threshold theorem says the continent wins as long as it
outnumbers the islands. The persistence theorem says that as you sweep the
filtration, components only merge — so the continent of correct answers
*grows*, absorbing nearby agreement, and the only way to fail is for the
minority to prematurely fuse into it and tip the balance. A logical error,
seen topologically, is precisely a *premature merge*: the moment the
minority cluster dies into the majority too soon. The Hamming-weight
threshold and the barcode of $H_0$ are two readings of the same dial.

This is the bridge the work builds: a *logic* side, where error is measured
by counting (Hamming weight), and a *topology* side, where error is measured
by a shape invariant (the zeroth Betti number). The endpoints are now both
nailed down with complete rigor. The correctness threshold for voting is
exact and sharp. The monotonicity of connected components along a filtration
is proved in full generality, with an explicit non-degeneracy witness so we
know it has teeth.

## Why it matters, and where it goes

The promise of this dual viewpoint is practical. Topological data analysis
comes with a mature toolkit — barcodes, persistence diagrams, stability
theorems — that is robust to exactly the kind of noise that plagues quantum
hardware. If the combinatorial threshold of majority voting can be re-derived
purely from the topology of the readout cloud, then the entire arsenal of
TDA becomes available for designing smarter, noise-aware decoders for NISQ
machines — decoders that look at the *shape* of the agreement rather than
just tallying votes.

Several precise conjectures chart the road ahead. One asks whether the
topological decoder — "take the dominant $\beta_0$ component" — provably
equals majority voting below threshold, which would mean topology exactly
re-derives the combinatorial decision boundary. Another asks for the sharp
dichotomy: that the number of components strictly drops *if and only if* a
genuine merge occurs, turning the persistence inequality into an exact event
detector. A third reaches for the quantitative crown jewel: that for random
bit-flip noise below rate one-half, the logical error probability decays
exponentially in the number of repetitions, with the decay rate governed by
the length of the longest bar in the $H_0$ barcode — the survival time of the
correct cluster.

For now, two clean theorems stand as anchors: *the truth wins when liars are
a minority,* and *clusters of truth can only grow.* One is the logic of
counting; the other is the logic of shape. That they describe the same thing
is the quiet, beautiful surprise at the heart of this work — and a reminder
that in mathematics, the shortest path between two ideas often runs straight
through a third.
