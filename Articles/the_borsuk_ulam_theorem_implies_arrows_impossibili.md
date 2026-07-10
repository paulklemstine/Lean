# When Voting Meets the Doughnut: The Hidden Topology of Fair Elections

## A tale of two theorems

Two of the twentieth century's most celebrated impossibility results come from
worlds that seem to have nothing in common.

The first belongs to economics. In 1951 Kenneth Arrow proved that no ranked
voting system can be simultaneously fair in three very reasonable senses: it
should respect unanimity (if *everyone* prefers apple pie to cherry pie, so
should society), it should never let a single voter dictate the outcome, and the
relative ranking of two candidates should not flip merely because some third,
irrelevant candidate entered or left the race. Arrow showed that these three
mild-sounding demands are mutually contradictory whenever there are at least
three alternatives. Fairness, in this precise sense, is impossible.

The second belongs to topology. The Borsuk–Ulam theorem says that any continuous
function from the surface of a sphere $S^n$ into $n$-dimensional space $\mathbb{R}^n$
must send some pair of *antipodal* points — two points diametrically opposite,
like the North and South Poles — to exactly the same value. The most quoted
consequence is meteorological folklore: at every instant there are two
antipodal points on Earth with identical temperature *and* barometric pressure.

A tantalizing modern slogan claims these two theorems are secretly the same
theorem: *social choice is topology*, and *Arrow's impossibility is Borsuk–Ulam
in disguise*. Antipodal points, the story goes, are opposite preference
profiles — one voter block ranking $A > B > C$, the mirror block ranking
$C > B > A$ — and Borsuk–Ulam forces a "coincidence" that no fair, continuous
voting rule can survive.

It is a beautiful idea. This article tells the honest version of the story: what
part of the slogan is a genuine theorem, and what part is a seductive myth. The
truth turns out to be more interesting than the myth, because it reveals *exactly
which ingredient* makes fairness impossible — and it is not voting at all. It is
the **shape of the space of opinions**.

## The one-dimensional heart of the matter

Strip Borsuk–Ulam down to its simplest incarnation and you get a statement about
a circle. Imagine walking once around a circular track while carrying a
thermometer. Let $f(x)$ be the temperature at the point you reach after turning
through angle $x$. Because the track closes up on itself, $f$ is *periodic*:
returning to the start after a full turn of $2\pi$ gives the same reading,
$f(x + 2\pi) = f(x)$.

**The One-Dimensional Borsuk–Ulam Theorem.** *If $f:\mathbb{R}\to\mathbb{R}$ is
continuous and $2\pi$-periodic, then there is some angle $x$ with*
$$f(x) = f(x + \pi).$$
*In words: some pair of diametrically opposite points on the circle record
exactly the same temperature.*

The proof is a small gem. Define the *difference function*
$$g(x) = f(x) - f(x + \pi),$$
which measures how much hotter a point is than the point directly across from it.
Step half a turn further and something magical happens:
$$g(x + \pi) = f(x + \pi) - f(x + 2\pi) = f(x + \pi) - f(x) = -g(x),$$
using periodicity in the last step. So $g$ is *odd under the half-turn*: crossing
to the antipode flips its sign. In particular $g(0) = -g(\pi)$. If $g(0)$ is
positive, then $g(\pi)$ is negative, and vice versa. A continuous function that
is positive somewhere and negative somewhere must, by the Intermediate Value
Theorem, pass through zero somewhere in between. That zero is a point where
$g(x) = 0$, i.e. $f(x) = f(x+\pi)$. $\blacksquare$

This is not a party trick; it is the entire topological engine, laid bare. Every
higher-dimensional Borsuk–Ulam theorem is a more elaborate version of the same
"odd function must hit zero" phenomenon.

## Reading it as a voting theorem

Now let the circle be a *space of political opinions*. A point on the circle is a
stance; its antipode is the diametrically opposite stance. Suppose society runs a
continuous "scoring" rule that reads a stance $x$ and outputs a single number
$f(x)$ — how strongly society leans one way. Continuity is the reasonable demand
that infinitesimally similar opinions receive nearly identical scores; periodicity
encodes that opinions live on a closed loop.

Here is the fantasy of the slogan: society should *strictly* prefer every stance
to its opposite, so that $f(x) > f(x + \pi)$ for all $x$ — always favoring $x$
over its mirror image. The one-dimensional Borsuk–Ulam theorem says this is
**impossible**:

**No Strictly Antipodal Preference.** *There is no continuous, periodic scoring
rule $f$ with $f(x+\pi) < f(x)$ for every $x$* (and, symmetrically, none with
$f(x) < f(x+\pi)$ for every $x$).

The proof is a one-liner given the theorem above: Borsuk–Ulam hands us an $x$
with $f(x) = f(x+\pi)$, which flatly contradicts a strict inequality holding
everywhere. This is the *genuine kernel* of the "clash with unanimity" that the
slogan gestures at. On a circular opinion space, no continuous rule can strictly
break every antipodal tie. The topology forbids it.

So far the slogan looks vindicated. And then it overreaches.

## The myth, and its collapse

The bold conjecture says much more: that *any* social choice rule on $n$
alternatives is **either discontinuous or dictatorial** — that continuity alone
forces one voter to secretly rule them all. If true, this would make Arrow's
theorem a mere corollary of Borsuk–Ulam.

It is false. And the reason it is false is the most illuminating part of the
whole story.

The Borsuk–Ulam obstruction lives on the *sphere* — a space with a hole, a space
you cannot continuously shrink to a point. The moment the space of opinions is
**contractible** — shrinkable to a point, like a line, an interval, or a solid
convex blob — the obstruction evaporates. There is nothing left to obstruct.

To see this concretely, model each voter's opinion as a real number: a position
on a one-dimensional political spectrum from far-left to far-right. With $n$
voters submitting positions $p_1,\dots,p_n$, consider the most familiar
aggregation rule in the world — the **average**:
$$F(p_1,\dots,p_n) = \frac{p_1 + p_2 + \cdots + p_n}{n}.$$

This humble mean is simultaneously everything the myth says is impossible:

- **Continuous.** Nudge any voter's position slightly and the average barely
  moves. There are no jumps.
- **Unanimous (Pareto).** If every voter submits the very same position $c$, the
  average is exactly $c$. Society agrees when everyone agrees.
- **Anonymous.** Relabeling the voters — swapping who is "voter 1" and who is
  "voter 2" — leaves the average unchanged. No voter is special; the rule is
  perfectly symmetric.
- **Monotone.** If every voter shifts weakly rightward, the social outcome shifts
  weakly rightward. The rule never rewards a preference with the opposite result.
- **Translation-invariant.** Shift the entire spectrum by a constant $c$ — a
  change of units, not of opinion — and the outcome shifts by exactly $c$.
- **Non-dictatorial.** For $n \geq 2$ there is no single voter whose position
  *always* equals the outcome. The proof is delightfully simple: to defeat any
  candidate-dictator $i$, let voter $i$ submit $0$ while everyone else submits
  $1$. The average is $(n-1)/n$, which is strictly between $0$ and $1$ and hence
  never equal to voter $i$'s stance of $0$. So $i$ is not a dictator — and since
  $i$ was arbitrary, no dictator exists.

**The Continuous Non-Dictatorial Aggregator.** *For every $n \geq 2$ there exists
an aggregation rule on $n$ voters that is at once continuous, unanimous,
anonymous, and non-dictatorial.*

The mean is that rule. It is a working, everyday counterexample to the myth.
Continuity does **not** imply dictatorship. The slogan, taken literally,
collapses.

## So what is actually true?

The lesson is precise and, once seen, unforgettable: **fairness is impossible on
spheres, and possible on blobs.** The obstruction that dooms fair aggregation is
not the act of voting; it is the *global shape* of the space of opinions. When
opinions genuinely live on a circle or a higher sphere — a space with a hole,
where "opposite" opinions are built into the geometry — Borsuk–Ulam-type
theorems bite, and continuous fair aggregation becomes impossible. When opinions
live on a contractible domain — a spectrum, an interval, a convex set of
compromises — you can average, and averaging is fair.

This is not a defeat for the topological viewpoint; it is its triumph. The real
theorem of *topological social choice*, due to Graciela Chichilnisky in the
1980s, says exactly this: there is no continuous, anonymous, unanimity-respecting
way to aggregate opinions that live on a circle $S^1$ (or, more generally, on a
sphere $S^n$) into a single collective opinion on the same circle. The
impossibility is real — but it is a theorem about spheres, not about ballots.

And Arrow's original discrete theorem? Yuri Baryshnikov showed in 1993 that it,
too, can be *recovered* topologically: one builds a geometric scaffold — a
combinatorial shape whose holes encode the logical structure of ranked
preferences — and then invokes an obstruction of exactly Borsuk–Ulam type. So
the honest, defensible version of the grand slogan is not "Arrow equals
Borsuk–Ulam," but something subtler and truer:

> *Topological obstructions of Borsuk–Ulam type govern the aggregation of
> opinions on spheres, and through a geometric encoding of ranked preferences,
> they reach back to explain why Arrow's discrete impossibility holds too.*

## The moral

Chase a beautiful slogan far enough and one of two things happens: it shatters,
or it deepens. Here it does both. The naive claim — continuity forces
dictatorship — shatters against a five-year-old's arithmetic: *just take the
average*. But the wreckage exposes the true mechanism. The enemy of fairness is
not the ballot box. It is the hole in the doughnut.

Whether a society can aggregate its opinions fairly is, at bottom, a question
about the *shape* of its disagreements. Line up your disagreements along a
spectrum and compromise is always available. Wrap them into a circle, so that
every opinion has a diametric foe and there is no neutral center to retreat to,
and the topology itself guarantees that someone, somewhere, will always be
betrayed by the vote. Social choice really is topology — just not the topology
the slogan promised.
