# The Geometry of Consensus: Why "Moderate" Voters Save Democracy

## A paradox at the heart of voting

Imagine three friends — Ada, Boris, and Chen — trying to pick a restaurant.
The choices are Italian, Japanese, and Korean. Each person writes down a strict
ranking of the three. Then they vote pairwise: in each head-to-head matchup, the
option preferred by two out of three wins.

Here is a seating chart that should make you uneasy:

- Ada ranks **Italian > Japanese > Korean**
- Boris ranks **Japanese > Korean > Italian**
- Chen ranks **Korean > Italian > Japanese**

Now run the pairwise majority votes:

- Italian vs. Japanese: Ada and Chen prefer Italian → **Italian beats Japanese.**
- Japanese vs. Korean: Ada and Boris prefer Japanese → **Japanese beats Korean.**
- Korean vs. Italian: Boris and Chen prefer Korean → **Korean beats Italian.**

So the majority prefers Italian to Japanese, Japanese to Korean, and Korean to
Italian. The "will of the people" runs in a circle: Italian → Japanese → Korean →
Italian. There is no winner. This is the **Condorcet paradox**, and it is the
seed from which Kenneth Arrow grew his famous 1951 impossibility theorem: no
reasonable voting rule can convert individual rankings into a coherent social
ranking without, in effect, crowning a dictator.

This is a genuinely disturbing result. It says that the cyclical chaos above is
not a freak accident but a permanent structural hazard of group decision-making.

And yet democracies function. Committees pick chairs, legislatures pass budgets,
and parties choose nominees — usually without dissolving into infinite loops. Why?

The answer, discovered by Duncan Black in 1948, is one of the most reassuring
theorems in social science. And in this article we will tell its story from a
surprising new angle: **the angle of curvature.** We will see that the cyclical
chaos of the Condorcet paradox is, quite literally, a kind of *bending* of the
space of opinions — and that the cure is to *flatten* that space.

## Preferences as a landscape

To see the geometry, we need one more idea: the **political axis**.

Picture the three restaurants not as an unordered set, but laid out along a line
— say, by spiciness: Italian (mild), Japanese (medium), Korean (hot). Most real
disagreements have an axis like this. Politics has left-to-right. Budgets have
small-to-large. Thermostats have cold-to-hot.

Now ask: what does it mean for a person to have a *sensible* opinion along this
axis? Black's answer is the notion of a **single-peaked preference**. A voter is
single-peaked if there is one option they love most — their **peak** — and their
enthusiasm falls off steadily as you move away from that peak in *either*
direction along the axis. A person whose favorite is Japanese (medium spice) and
who likes Italian more than Korean is single-peaked: their happiness has a single
summit and slopes down on both sides. They never have a weird "I love the
extremes but hate the middle" valley.

This is an extraordinarily natural assumption. It simply says: people have a most
preferred point, and things get worse the farther you stray from it. A voter
whose ideal tax rate is 20% will, all else equal, prefer 22% to 25%, and 18% to
15%. That is single-peakedness.

Here is the punchline, **Black's Theorem**:

> If every voter is single-peaked along a common axis, then majority rule never
> cycles. The paradox vanishes. A coherent social ranking always exists, and (with
> an odd number of voters) the favorite of the **median voter** wins.

The chaos of the Condorcet paradox required someone like Chen above —
**Korean > Italian > Japanese** — a voter who loves a hot extreme, tolerates a
mild extreme, and *despises the moderate middle option most of all*. Chen is not
single-peaked. Chen's preference has a valley where the peak should be. Remove
voters like Chen, and democracy heals.

## The hidden geometry: curvature

So far this is classical political science. The new idea is to ask: *what kind of
object is the cyclical paradox, geometrically?*

In differential geometry, **curvature** is what measures the failure of a space
to be flat. On a flat plane, if you walk in a closed loop carrying an arrow that
always points "the same way," you return with the arrow pointing exactly as it
started. On a curved surface — the surface of the Earth, say — you can walk a loop
and come back to find your arrow rotated. This rotation is called **holonomy**,
and it is the fingerprint of curvature. Flat means: every loop closes up cleanly.
Curved means: some loops twist you around.

Now look again at the Condorcet paradox. We walked a loop through the
alternatives — Italian, Japanese, Korean — and instead of the preferences closing
up consistently, they *twisted*: each step said "this beats the next," and yet we
came back to the start. **A majority cycle is holonomy.** It is the signature of a
curved opinion-space.

This is not a loose metaphor. We can make it a precise, countable quantity. Define
the **Condorcet curvature** of a profile of votes to be simply *the number of
three-way majority cycles* it contains. Concretely, count every triple of
alternatives (a, b, c) such that the majority prefers a to b, b to c, and c to a.

- **Zero curvature** means *no cycles*: the space of opinions is flat, and majority
  rule produces a clean, consistent ranking. Consensus is achievable.
- **Positive curvature** means *some cycle exists*: the space is bent, the paradox
  has appeared, and Arrow's storm clouds gather.

With this definition, the classical results snap into geometric focus. Earlier
work in this project established two anchoring facts:

- **A single point is flat.** If all voters share *exactly* the same ranking
  (perfect unanimity), the Condorcet curvature is zero. Of course — there is
  nothing to twist.
- **Flatness equals consistency.** A profile has zero Condorcet curvature if and
  only if its majority relation has no cycle, which (for an odd electorate) is
  exactly the condition for majority rule to be a transitive, coherent ordering.

The first fact is reassuring but weak: it only flattens a *single point* in
opinion-space, the lonely case of total agreement. Real societies never agree
perfectly. The question that drives this work is: **can we flatten an entire
region of disagreement?** Can people argue, hold genuinely different views, and
still live on flat ground?

Black's theorem says yes — and the geometric reformulation makes precisely this
claim:

> **Single-peaked preference domains are flat.**
> If every voter is single-peaked along a common axis, the Condorcet curvature is
> exactly zero — no matter how much the voters disagree about where the peak should
> be.

This upgrades "a single point is flat" to "an entire submanifold is flat." Voters
can disagree wildly — one wants the mildest option, another the hottest, a third
something in between — and as long as each opinion is single-peaked, the
collective opinion-space carries no curvature, no holonomy, no paradox.

## The engine of the proof: never bury the moderate

How does single-peakedness force the curvature to vanish? The proof rests on one
beautifully simple observation about moderates, and one transfer trick.

**Step 1 — The moderate is never anyone's last choice.** Take any three
alternatives and sort them by the axis: a (left), b (middle), c (right). Claim:
*a single-peaked voter never ranks the middle option b dead last.* Why? Their peak
sits somewhere on the axis. If the peak is at b or to its right, then going from c
back toward the peak improves things, so they prefer b to c — b isn't last. If the
peak is to the left of b, then going from a toward the peak improves things, so
they prefer b to a — again b isn't last. Either way, the middle survives. This is
the **value restriction** condition isolated by Amartya Sen: on a single-peaked
domain, one option (the axis-middle) is *forbidden from being worst*.

This is the geometric meaning of flatness in disguise. Curvature comes from voters
like Chen who throw the moderate to the bottom of their list. Single-peakedness
outlaws exactly that move.

**Step 2 — Decisiveness transfers across the protected middle.** Now suppose a
majority prefers the left option a to the middle b. Consider any voter in that
majority — they rank a above b. By value restriction, this same voter prefers b to
*something*: either to a or to c. They can't prefer b to a (they just told us a
beats b for them), so they must prefer b to c. Chaining it together: this voter
ranks a above b above c, hence **a above c.** So *every* voter who put a over b
also puts a over c. The majority that favored a over the middle automatically
favors a over the far extreme. We call this lemma **"cross beats"**: decisiveness
*crosses* the never-buried middle and lands on the far side.

In the language of geometry, this transfer is **parallel transport with trivial
holonomy** — you carry the "a wins" verdict around the triangle of alternatives
and it arrives unrotated, exactly as on a flat plane.

**Step 3 — No cycle can survive.** A majority cycle on the sorted triple a < b < c
would have to include an arrow from a flank into the middle and then close back
up. But "cross beats" forces the flank that wins at the middle to also win at the
far flank — which directly contradicts the closing arrow of the cycle. The loop
*cannot* close inconsistently. There is no holonomy. The curvature is zero. Black's
theorem is proved.

The whole argument collapses to a single counting step: the set of voters who
rank a above b sits *inside* the set who rank a above c. One is a subset of the
other, so the second majority is at least as large as the first. From this one
inclusion, the entire paradox dissolves.

## What is striking about the proof

Two features deserve emphasis.

First, **acyclicity needs no fine print.** You often hear that majority rule
"works for an odd number of voters." That oddness is only needed to break exact
ties so that *every* pair has a definite winner. The *absence of cycles* — the
flatness itself — holds regardless of whether the electorate is odd or even, large
or small. Curvature vanishes structurally, not numerically.

Second, the proof is **local.** The killer condition — "the middle is never worst"
— is a statement about each voter individually, looking at three alternatives at a
time. Yet it produces a *global* guarantee about the entire majority relation.
This is the hallmark of the curvature picture: a local geometric property (no
twisting in any small triangle) integrates up to a global one (no holonomy around
any loop). It is the discrete shadow of one of the deepest themes in geometry:
that local flatness controls global structure.

## Why this matters beyond restaurants

The dictionary we have built — **value restriction = flatness**, **majority cycle
= curvature**, **decisiveness transfer = parallel transport** — is more than a
pretty repackaging. It reframes the central tension of social choice as a question
about the *shape* of opinion.

Arrow's impossibility theorem tells us the generic opinion-space is curved, and
that curvature breeds paradox. Black's theorem tells us there is a flat
submanifold — the single-peaked profiles — where democracy behaves perfectly. The
geometry explains *why* these two famous theorems are not contradictory but
complementary: one describes the curved bulk, the other the flat slice through it.

It also points somewhere practical. Real institutions work hard, often
unconsciously, to keep debate on a single axis — framing a budget as one number,
a policy as a left-right choice, a thermostat as one dial. Each time we succeed in
collapsing a tangled, multi-dimensional argument onto a single line, we are
*flattening the opinion manifold*, and the geometry guarantees the reward: no
cycles, a clear median winner, a stable consensus. When debate fragments into
many incommensurable dimensions at once — when there is no shared axis — curvature
returns, and with it the specter of endless cycling.

The mathematics here has been verified down to the last logical step by a proof
assistant, so we can state it without hedging. But the moral is older than any
formalism and worth carrying out of the article: **a healthy democracy is a flat
one.** Protect the moderate from being everyone's last choice, keep the argument
on a common axis, and the will of the people will close its loops cleanly — every
time.
