# Knots That Think

## A thought is a braid

Close your eyes and follow a single idea as it forms. It does not arrive all at
once. Regions of your brain light up in sequence, hand a signal to their
neighbors, loop back, cross over one another, and settle. If you could draw the
timelines of the regions involved and watch how they weave past each other, you
would not see a tidy stack of parallel lines. You would see strands crossing —
a braid.

This is more than a metaphor. Mathematicians have a precise language for
strands that cross: the *braid group*. Picture $n$ vertical strands hanging side
by side. The only thing you are ever allowed to do is swap two *neighboring*
strands, passing one in front of the other. Call the move that crosses strand
$i$ over strand $i+1$ by the name $\sigma_i$, and call the reverse crossing
$\sigma_i^{-1}$. Any braid, however tangled, is just a *word* in these moves:
$\sigma_2\,\sigma_1^{-1}\,\sigma_2\,\sigma_3\,\dots$ Read left to right, the word
is a recipe for weaving.

The claim explored here is simple to state and strange to contemplate: **a
cognitive process is an element of the braid group** $B_n$, where $n$ is the
number of participating brain regions. Linear, step-by-step reasoning is a braid
with almost no crossings. A flash of creative insight is a genuinely knotted
braid that cannot be combed straight. And the *topology* of your thought — how
irreducibly tangled it is — is a measure of its quality.

## When are two thoughts the same thought?

Here is the first subtlety. Two different words can describe the *same* braid.
If strand $1$ and strand $4$ are far apart, then crossing $1$-over-$2$ and then
$3$-over-$4$ gives exactly the same weave as doing them in the other order:
distant crossings commute,
$$\sigma_i\,\sigma_j = \sigma_j\,\sigma_i \qquad \text{whenever } |i-j|>1.$$
And there is one more, subtler identity — the one that gives braids their
character — relating three crossings of two adjacent pairs:
$$\sigma_i\,\sigma_{i+1}\,\sigma_i \;=\; \sigma_{i+1}\,\sigma_i\,\sigma_{i+1}.$$
This is the famous *braid relation*. Wiggle the physical strands and you will
see that both sides describe the identical tangle.

Together these two rules define what it means for two braid words to be *equal
as braids*. Translated back into the language of the mind, they say when two
sequences of neural events are **cognitively equivalent** — the same thought,
merely told in a different order. Any honest measure of "thought quality" must
respect this equivalence: if you reorder the telling without changing the tangle,
the measurement must not budge. A quantity that survives every legal
rearrangement is called an *invariant*, and invariants are the crown jewels of
topology.

## The simplest invariant: writhe

The deepest invariant in this circle of ideas is the *Jones polynomial*, a
subtle algebraic fingerprint that assigns to each braid a polynomial $V(t)$. The
trivial braid — no thinking at all — has $V(t)=1$. The **trefoil**, the simplest
truly knotted braid and our model of a creative insight, has
$$V(t) = -t^{2} + t + 1$$
(up to normalization and orientation conventions). The figure-eight knot, our
model of *confused* thinking, has its own signature polynomial. From these one
extracts an *information content* by evaluating at a special root of unity and
taking a logarithm — a number that measures the "quantum dimension" of the
thought. Remarkably, among our three archetypes only the trefoil carries
positive information; the confused figure-eight, by this measure, is
indistinguishable from thinking nothing at all.

The Jones polynomial is powerful but delicate. So it is worth pausing on a
humbler invariant that can be pinned down completely and rigorously — one that
already tells a clean story. It is called the **writhe**.

The writhe is nothing more than a signed crossing count. Every positive crossing
$\sigma_i$ contributes $+1$; every negative crossing $\sigma_i^{-1}$ contributes
$-1$. Add them up over the whole word. That sum is the writhe:
$$\mathrm{writhe}(w) \;=\; \sum_{\text{letters } \ell \text{ in } w}
\begin{cases} +1 & \ell = \sigma_i,\\ -1 & \ell = \sigma_i^{-1}.\end{cases}$$
Cognitively, the writhe is the *net directed charge* of a thought: how much more
often signals flowed "forward" than "backward" as regions handed off to one
another.

The writhe is obviously additive: run one thought and then another, and the net
charges simply add,
$$\mathrm{writhe}(u \cdot v) = \mathrm{writhe}(u) + \mathrm{writhe}(v).$$
But additivity is cheap. The real question is the one every invariant must
answer: **does it survive cognitive equivalence?**

## The theorem: writhe is a genuine invariant

It does. And this can be proved rigorously.

**Theorem (Writhe is a braid invariant).** *If two braid words $u$ and $v$ are
related by any sequence of the braid moves — distant-crossing commutation
$\sigma_i\sigma_j = \sigma_j\sigma_i$ for $|i-j|>1$, and the braid relation
$\sigma_i\sigma_{i+1}\sigma_i = \sigma_{i+1}\sigma_i\sigma_{i+1}$, applied inside
any surrounding context — then* $\mathrm{writhe}(u) = \mathrm{writhe}(v)$.

The proof is a small marvel of bookkeeping. The key observation is that the
writhe is defined *directly* as a sum over letters, with no reference whatsoever
to the equivalence relation it is supposed to respect. So to check invariance we
only have to inspect the two moves in isolation:

- **Distant commutation** replaces the two-letter subword
  $\sigma_i\sigma_j$ (net charge $+2$) by $\sigma_j\sigma_i$ (also net charge
  $+2$). And crucially, this holds *for any signs* on the two crossings, because
  far-apart strands commute regardless of orientation. The net charge of the
  swapped pair is unchanged.
- **The braid relation** replaces the three-letter subword
  $\sigma_i\sigma_{i+1}\sigma_i$ (net charge $+3$) by
  $\sigma_{i+1}\sigma_i\sigma_{i+1}$ (also net charge $+3$). Again, unchanged.

Since each move preserves the writhe of the little piece it touches, and since
the writhe of a whole word is just the sum of the writhes of its pieces,
swapping a subword for another of equal writhe leaves the grand total alone. The
invariance follows for *any* chain of moves, in *any* context, by a clean
induction over how the equivalence was built up. There is no circularity: the
quantity is manifestly well defined *before* we ever mention when two thoughts
are the same.

## From words to the group itself

There is a more structural way to say the same thing, and it is worth stating
because it upgrades "invariant" to something sharper.

The braid group $B_n$ can be *presented* by generators and relations: take the
free group on symbols $\sigma_1,\dots,\sigma_{n-1}$ and impose exactly the
distant-commutation and braid relations above. An honest invariant should not
merely be constant on equivalence classes of words — it should be a genuine
*homomorphism out of the group*, a map that turns the group's multiplication
into ordinary addition.

**Theorem (Descent to the braid group).** *The assignment sending every
generator $\sigma_i \mapsto +1$ extends to a well-defined group homomorphism*
$$\mathrm{writhe}\colon B_n \longrightarrow \mathbb{Z}.$$

The proof strategy is exactly the modern one. Start on the free group, where the
map "send each generator to $+1$" exists for free and by construction sends the
inverse $\sigma_i^{-1}$ to $-1$. Then check that it *kills every defining
relation*: the commutator $\sigma_i\sigma_j\sigma_i^{-1}\sigma_j^{-1}$ maps to
$1+1-1-1 = 0$, and the braid relator
$\sigma_i\sigma_{i+1}\sigma_i(\sigma_{i+1}\sigma_i\sigma_{i+1})^{-1}$ maps to
$3 - 3 = 0$. A map that sends every relation to zero descends automatically to
the quotient — that is the universal property of a presented group. So the
writhe is not just numerically stable under rearrangement; it is a bona fide
algebraic feature of the braid *itself*, independent of any recipe you choose to
build it.

## Why this matters

Step back from the neurons for a moment. What has been established is a small,
airtight instance of a very large idea: that **the informational content of a
process can be read off from the topology of how its parts interleave**, and
that this reading is stable under all the ways the same process might be
described.

The writhe is the abelian shadow of this idea — a single integer, the net
directed charge. It already does real work: it places a floor under how many
firing events a thought must involve, because you cannot achieve a net charge of
$+5$ with fewer than five crossings. But the writhe is deliberately blind to the
richer structure. It cannot tell a creative trefoil from a merely lopsided pile
of crossings, because it only sees the sum, never the weave. That is precisely
where the Jones polynomial and its quantum dimension take over, distinguishing
the trefoil's genuine knottedness from the figure-eight's confusion and from the
flatness of trivial thought.

The vision that ties it together is bracing in its simplicity. Thinking *is*
braiding. Linear reasoning is a braid you can comb straight. A creative insight
is literally knotted — a trefoil in the fabric of your firing patterns that no
reordering can undo. Confusion is a different knot, tangled but strangely empty
of information. And the quality of a thought, on this view, is not a vague
psychological attribute but a *topological invariant*: a number that every
retelling of the thought must agree on, carved into the shape of the crossings
themselves.

We do not yet know whether real connectomes braid the way this picture demands.
But the mathematics is now on firm ground at its foundation. The net charge of a
thought is a genuine invariant of the braid group, provable to the last symbol.
The strands cross; the count is honest; and somewhere in that honest count is
the first rigorous hint that our thoughts have a shape — and that the knottiest
ones are the ones worth having.
