# Attention on a Sphere: A New Way for Machines to Decide What Matters

## The quiet engine behind modern AI

Every time a language model finishes your sentence, translates a paragraph, or
summarizes a document, a single mechanism is doing most of the heavy lifting:
**attention**. Attention is the part of a neural network that decides, for each
word it is about to produce, which of the thousands of earlier words deserve a
glance and which can be safely ignored. It is the network's spotlight operator,
sweeping over a sea of context and brightening the few places that matter.

For nearly a decade this spotlight has been built the same way. Each candidate
word — call it a *key* — is compared to the word currently being processed —
the *query* — by taking a dot product, exponentiating it, and normalizing.
This recipe is called **softmax attention**, and it works astonishingly well.
But it has a stubborn flaw: the softmax spotlight is never truly dark anywhere.
Exponentials are always positive, so *every* key gets at least a sliver of
attention. With a million words of context, a model must in principle keep a
flicker of focus on all million of them at once. That is expensive, and it is
also unlike how we think — when you read this sentence, the previous chapter is
not glowing faintly in your mind; it is simply gone from your immediate focus.

This article is about a different way to build the spotlight, one borrowed not
from statistics but from geometry: from the centuries-old art of drawing a sphere
on a flat map. We call it **stereographic attention**, and its central promise is
that *darkness comes for free*. Most keys naturally receive a score so close to
zero that they can be discarded, and they do so not because we forced them to but
because the geometry of a sphere insists on it.

## A score that is secretly a distance

Let us start with the new rule for scoring a key against a query. Instead of the
exponential dot product, stereographic attention uses what mathematicians call
the **Cauchy kernel**:

> **The Cauchy attention score.** Given a query vector `q` and a key vector `k`,
> their score is
>
> &nbsp;&nbsp;&nbsp;&nbsp; `K(q, k) = 1 / (1 + ‖q − k‖²)`,
>
> where `‖q − k‖` is the ordinary Euclidean distance between them.

Read it slowly. When `q` and `k` are identical, the distance is zero and the
score is `1 / (1 + 0) = 1` — the maximum. As the key drifts away from the query,
the squared distance in the denominator grows, and the score slides smoothly
toward zero. There is no exponential anywhere; the whole thing is a simple
fraction. And yet, as we will see, this innocent fraction carries inside it the
entire geometry of a sphere.

The first thing to notice is how well-behaved this score is. We can prove three
clean facts about it, and they are worth stating exactly because they pin down
the character of the whole mechanism.

> **Fact 1 (Always positive).** For every query `q` and key `k`,
> `K(q, k) > 0`.

The denominator `1 + ‖q − k‖²` is at least `1`, because a squared distance is
never negative. A positive number divided by something at least `1` is positive.
So no key is ever assigned a *hard* zero — every key keeps a toehold of relevance,
which matters because it means the mechanism is smooth and differentiable, the
property neural networks need in order to learn.

> **Fact 2 (Never more than one).** For every query `q` and key `k`,
> `K(q, k) ≤ 1`.

Again the reason is elementary: since `‖q − k‖² ≥ 0`, the denominator is at least
`1`, so the fraction is at most `1`. This gives us a *budget*. If every one of `N`
keys scores at most `1`, then the total attention across all keys can never exceed
`N`. That single bound, trivial as it looks, turns out to be the lever that pries
open the sparsity guarantee later.

> **Fact 3 (Maximal only on the diagonal).** `K(q, k) = 1` if and only if
> `q = k`.

The score hits its ceiling of `1` *exactly* when the key equals the query, and
never otherwise. This is the geometric meaning of "self-attention": a query
attends most strongly to itself, and to anything else strictly less. Notice this
is a stronger statement than softmax can make. Softmax scores are only meaningful
*relative* to each other — scale everything and the picture is unchanged. The
Cauchy score, by contrast, has an *absolute* meaning: `1` is `1`, the perfect
match, full stop.

## Unrolling the map of the world

Where does the sphere come in? Here is the beautiful part. There is a classical
construction, known to every cartographer, called **stereographic projection**.
Picture a globe sitting on a flat sheet of paper, touching it at the South Pole.
Now stand at the North Pole and shine a light through each point of the globe down
onto the paper. Every point of the sphere casts a shadow somewhere on the infinite
plane, and every point of the plane is the shadow of exactly one point of the
sphere. The sphere and the plane become two views of the same world. This is how
you flatten a globe into a map — and, run in reverse, how you wrap a flat map back
onto a globe.

Stereographic attention runs the map *backwards*. It takes each flat query or key
vector `x` and lifts it up onto the surface of a sphere. Written out, the lift
sends `x` to a point with two pieces — a "horizontal" part that still lives in the
original space, and a single new "height" coordinate:

> **The stereographic lift.** A vector `x` is sent to the sphere point with
> horizontal part
>
> &nbsp;&nbsp;&nbsp;&nbsp; `P(x) = (2 / (1 + ‖x‖²)) · x`
>
> and height
>
> &nbsp;&nbsp;&nbsp;&nbsp; `H(x) = (‖x‖² − 1) / (‖x‖² + 1)`.

This formula looks arbitrary until you check what it does, and what it does is
land precisely on the unit sphere — the set of points exactly one unit from the
origin. That is not an accident or an approximation; it is an exact identity.

> **Fact 4 (The lift lands on the sphere).** For every vector `x`,
>
> &nbsp;&nbsp;&nbsp;&nbsp; `‖P(x)‖² + H(x)² = 1`.

In words: the squared length of the horizontal part plus the square of the height
always equals exactly `1`, which is the defining equation of a unit sphere. So
when we say stereographic attention "projects to the sphere," this is a literal,
verified statement, not a metaphor. Every vector in your data, however large or
small, gets a unique home on the surface of one fixed sphere. Vectors near the
origin land near the South Pole; vectors that race off to infinity crowd toward
the North Pole; everything in between drapes smoothly over the curve.

## The punchline: the score *is* the sphere distance

Now we can connect the two ideas — the fraction and the sphere — and this is the
conceptual heart of the whole story. Take a vector `x`, lift it to its point
`(P(x), H(x))` on the sphere, and measure the straight-line distance from that
point to the North Pole `(0, 1)` (the top of the sphere). Square that distance.
What do you get? Not something vaguely related to the Cauchy score — you get the
Cauchy score itself, multiplied by four:

> **Fact 5 (The score is a chordal distance).** For every vector `x`,
>
> &nbsp;&nbsp;&nbsp;&nbsp; `‖P(x)‖² + (H(x) − 1)² = 4 · K(x, 0)`.

The left side is the squared "chord" — the straight-line distance through space
— from `x`'s home on the sphere to the North Pole. The right side is four times
the Cauchy score of `x` against the origin. They are equal, exactly, for every
`x`.

This is the sentence to carry away from the article: **a Cauchy attention score
is a distance on a sphere.** When the network asks "how relevant is this key to
this query?", stereographic attention answers by lifting both onto the Riemann
sphere and measuring how far apart they sit on its curved surface. Softmax
attention is a clever statistical heuristic; stereographic attention is a
genuine geometric measurement. The two are siblings — both decide what matters —
but one speaks the language of probabilities and the other the language of space.

## Why a sphere makes the spotlight go dark

Here is where the geometry pays a practical dividend. On a sphere, there is only
so much room. Picture the curved surface around the North Pole. Points very near
the pole are crowded together, but as you slide down toward the equator the
surface fans out, and the chordal distance to the pole grows quickly. Translated
back through Fact 5, this means: as a key moves away from a query, its score does
not trail off lazily — it plummets, because squared distance sits in the
denominator. Faraway keys are not faintly lit; they are *dark*.

We can make this precise. Fix a threshold `τ` — say, "I only care about keys that
score at least `τ`." Which keys clear the bar?

> **Fact 6 (Active keys form a ball).** A key `k` scores `K(q, k) ≥ τ` if and
> only if `k` lies within Euclidean distance `√(1/τ − 1)` of the query `q`.

This is an exact characterization, not an estimate. The "active" keys — the ones
the spotlight actually illuminates — are precisely those inside a ball of a known
radius centered on the query. Want a stricter spotlight? Raise `τ`; the radius
`√(1/τ − 1)` shrinks, and the ball of survivors contracts around the query. The
geometry literally draws the boundary of attention for you.

And the score behaves the way intuition demands: closer is always better. If one
key is nearer to the query than another, it scores strictly higher — the score is
a strictly decreasing function of distance. No ties, no inversions, no surprises.

## Counting the survivors

The final ingredient turns this geometry into a hard guarantee about cost. We
have a budget (Fact 2: every score is at most `1`, so the total over `N` keys is
at most `N`) and we have a threshold (`τ`). A classical and beautifully simple
argument — the same logic behind *Markov's inequality* in probability — now
bounds how many keys can possibly be active at once.

> **Fact 7 (Sparsity bound).** The number of keys scoring at least `τ`, call it
> `#active`, satisfies
>
> &nbsp;&nbsp;&nbsp;&nbsp; `τ · #active ≤ (sum of all scores) ≤ N`.

The reasoning is almost too simple to need words: each of the `#active` keys
contributes at least `τ` to the total score, so the active keys alone account for
at least `τ · #active` of the sum. But the whole sum is at most `N`. Therefore
`τ · #active ≤ N`, i.e. `#active ≤ N / τ`. The higher you set your relevance bar,
the fewer keys can clear it — and the bound is exact arithmetic, true for *any*
arrangement of keys whatsoever.

This is the rigorous backbone of the program's headline conjecture, which dreams
of something even stronger: that for keys that are genuinely *spread out* — as
they tend to be in real data — the total score grows only like `√N` rather than
`N`, so that the number of active keys collapses to roughly `√N`. That sharper
claim is not yet a theorem; it is the honest frontier. The unconditional truth we
can stand behind today is `τ · #active ≤ N`, and it is tight: if you cruelly
place every key exactly on top of the query, every score is `1`, the total really
is `N`, and no spotlight can save you. Sparsity is a gift of *spread*, and the
geometry tells us exactly where the remaining work lies — in counting how points
can pack onto shells of a sphere.

## Two portraits of the same idea

There is a pleasing symmetry hiding in all this. Attention can be studied
*algebraically*, as an abstract operation that must respect the symmetries of the
data — a viewpoint that, through a classical result called Schur's lemma, forces
the most symmetric attention maps to be simple scalar multiples of the identity.
And attention can be studied *geometrically*, as we have done here, as a
conformal kernel on a sphere. The two portraits meet on the diagonal: the
algebraic story's "scalar identity" fixed point is exactly the geometric story's
self-attention maximum, the place where Fact 3 tells us the score saturates at
`1` precisely when query equals key. The same truth, seen from two sides.

## What we have, and what we want

Stereographic attention is, at its core, a wager that geometry can do the work we
currently ask statistics to do — and do it with sparsity built in rather than
bolted on. We have shown that the Cauchy score is positive, bounded, and maximal
exactly on the diagonal; that the stereographic lift genuinely lands on the unit
sphere; that the score *is* a chordal distance on that sphere; that the active
keys form an exact ball whose radius you dial with a threshold; and that the
number of active keys obeys a clean Markov bound `τ · #active ≤ N`.

What remains is the most tantalizing part: proving that "spread-out" keys push
that bound all the way down to `√N`, turning a comfortable guarantee into a
spectacular one. That is a packing problem on the sphere, and it is exactly the
kind of question the geometry was built to ask. The map of the world has been
unrolled and wrapped back onto its globe; now we get to count how many cities can
share a horizon.
