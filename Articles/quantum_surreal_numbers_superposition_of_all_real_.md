# The Number That Hides: When Quantum Chance Meets the Infinitely Small

## A coin that is almost, but not quite, fair

Imagine a coin so strange that one of its faces is *infinitely thin*. Not thin
like a razor's edge — thin in the way a mathematician means it: smaller than
one-tenth, smaller than one-hundredth, smaller than one-billionth, smaller than
*every* fraction you could ever name, yet still not zero. Flip this coin a
trillion times and the impossibly thin face never comes up. Flip it a googol
times and still nothing. And yet, in the exact bookkeeping of mathematics, that
face has a genuine, positive chance of landing.

How should we speak about a possibility like that? Is it real? Is it nothing?
This article is about a framework that answers the question crisply: such a
possibility is *real in the ledger and invisible in the world*. The tool that
makes the two statements compatible is a single, humble operation called the
**standard part**, and the setting where it becomes powerful is a number system
larger than the familiar real line — one that contains numbers infinitely large
and infinitely small.

## Two ingredients: superposition and the infinitely small

The story braids together two threads that are rarely spun together.

The first thread is **superposition**, the signature move of quantum theory. A
quantum system need not be in one definite state; it can be in a blend of
several at once. We write such a blend as
$$
|\psi\rangle = \alpha_1\,|s_1\rangle + \alpha_2\,|s_2\rangle + \cdots + \alpha_n\,|s_n\rangle,
$$
where the $s_i$ are the possible outcomes and the $\alpha_i$ are *amplitudes*
that measure how strongly each outcome participates. The rule connecting this
blend to actual chance is more than a century old and astonishingly reliable:
the probability of seeing outcome $s_i$ is proportional to the square of its
amplitude, $\alpha_i^2$. This is the **Born rule**, and it says that amplitudes
are not probabilities themselves — their *squares*, once normalized to add up to
one, are.

The second thread is the **infinitely small**. The real numbers, for all their
richness, obey a law called the Archimedean property: no matter how tiny a
positive real number you pick, adding enough copies of it eventually exceeds
$1$. There is no real number that is positive yet smaller than every fraction.
But mathematicians have long known how to build larger ordered number systems
that break this law — number systems in which a genuine *infinitesimal*
$\varepsilon > 0$ lives, satisfying $\varepsilon < \tfrac{1}{n}$ for every whole
number $n$, alongside its reciprocal $1/\varepsilon$, a number larger than any
integer. Conway's surreal numbers are the grandest such system, containing every
real number together with an entire cosmos of infinities and infinitesimals. The
essential feature we need is simpler than the full surreal construction: an
ordered field that extends the reals and contains at least one infinitesimal.

Braiding the threads together gives the object at the heart of this work: a
superposition whose amplitudes are drawn not from the ordinary reals but from
such a non-Archimedean field. Some branches of the superposition can then be
*infinitesimally* weighted. What does it mean to measure one?

## The standard part: a lens that ignores the infinitely small

Every number that is *limited* — bounded in size by some ordinary integer —
sits infinitesimally close to exactly one real number. Its **standard part**,
written $\mathrm{st}(x)$, is that nearest real number: the unique real $r$ such
that $x - r$ is infinitesimal. Think of it as a lens ground to the resolution of
the real line. Point it at $3 + \varepsilon$ and you see $3$; point it at
$7 - 2\varepsilon$ and you see $7$; point it at a pure infinitesimal like
$5\varepsilon$ and you see $0$, because $5\varepsilon$ is closer to zero than any
real number could distinguish.

The standard part has three properties that make it the perfect measurement
lens. It respects addition and multiplication — $\mathrm{st}(x+y) =
\mathrm{st}(x) + \mathrm{st}(y)$ and $\mathrm{st}(xy) = \mathrm{st}(x)\,
\mathrm{st}(y)$ — so it never distorts arithmetic. It respects order, so it can
never turn a positive quantity negative. And it collapses *precisely* the
infinitesimals to zero, and nothing else: $\mathrm{st}(x) = 0$ for a limited $x$
exactly when $x$ is infinitesimal. That last property is the whole trick. It is a
principled way to declare "infinitely small means observationally nothing"
without ever pretending that infinitely small equals exactly nothing.

## The measurement rule, and what it guarantees

Here is the framework in full. Take a superposition with amplitudes
$\alpha_1, \dots, \alpha_n$ living in a non-Archimedean field. Form the **total
weight**
$$
Z = \alpha_1^2 + \alpha_2^2 + \cdots + \alpha_n^2,
$$
and give each branch its **Born weight** $w_i = \alpha_i^2 / Z$. In the exact
arithmetic of the field, these weights are perfectly normalized: they add up to
$1$ on the nose, with no approximation. But some of them may be infinitesimal. So
the rule for what an observer actually *sees* applies the lens: the **observed
probability** of branch $i$ is
$$
p_i = \mathrm{st}(w_i).
$$

Three theorems say this rule behaves exactly as a theory of chance must, provided
the amplitudes are all limited and the total weight $Z$ is *appreciable* —
neither infinitely large nor infinitesimally small.

**Exact normalization.** Before any lens is applied, the Born weights sum to one
identically: $w_1 + \cdots + w_n = 1$ in the field. Chance is conserved perfectly
at the microscopic level.

**Standard normalization.** After the lens, the observed probabilities still sum
to one: $p_1 + \cdots + p_n = 1$. Because the standard part respects addition and
sends $1$ to $1$, the exact identity is transported term by term into an ordinary
real identity. No probability leaks away in translation.

**Unobservability of the infinitesimal.** If a branch's amplitude $\alpha_i$ is
infinitesimal while the total weight is appreciable, then $p_i = 0$. The reason
is a small piece of non-Archimedean arithmetic: the square of an infinitesimal is
again infinitesimal, and an infinitesimal divided by an appreciable quantity
stays infinitesimal — so $w_i$ is infinitesimal, and the lens sends it to zero.

Put together, these results resolve the paradox of the impossibly thin coin. The
thin branch has a *genuine positive weight* $w_i$ in the exact ledger — it is not
zero, and the ledger balances perfectly. Yet its *observed probability* is
exactly $0$, and meanwhile the visible branches carry a total observed
probability of exactly $1$. Both statements are true at once, with no
contradiction, because they are statements at two different resolutions.

## A worked example: the branch you can never see

Consider three outcomes, two ordinary and one infinitesimally weighted:
$$
|\psi\rangle = \tfrac{1}{\sqrt{2}}\,|0\rangle + \tfrac{1}{\sqrt{2}}\,|1\rangle
              + \tfrac{1}{\sqrt{2}}\,\varepsilon\,|\varepsilon\rangle .
$$
The total weight is
$$
Z = \tfrac12 + \tfrac12 + \tfrac12\varepsilon^2 = 1 + \tfrac12\varepsilon^2,
$$
which is appreciable — infinitesimally more than $1$. The Born weights are
$$
w_0 = w_1 = \frac{1/2}{1 + \tfrac12\varepsilon^2}, \qquad
w_\varepsilon = \frac{\tfrac12\varepsilon^2}{1 + \tfrac12\varepsilon^2}.
$$
Apply the lens. Since $\tfrac12\varepsilon^2$ is infinitesimal, the denominator
has standard part $1$, so $\mathrm{st}(w_0) = \mathrm{st}(w_1) = \tfrac12$, while
$w_\varepsilon$ is infinitesimal and $\mathrm{st}(w_\varepsilon) = 0$. The
observer sees outcome $0$ half the time, outcome $1$ half the time, and the third
outcome *never* — even though it was present in the state all along, carrying a
positive but infinitely thin weight. The probabilities the observer records,
$\tfrac12 + \tfrac12 + 0$, sum perfectly to one.

## The same collapse, told without quantum mechanics

The phenomenon is not a quirk of amplitudes or of squaring. It is a structural
fact about ranking possibilities by *orders of magnitude*, and it appears in a
completely classical setting too: **lexicographic probability**.

A lexicographic probability assigns to each outcome not a single number but a
short list — a primary probability, then a secondary "tie-breaker" probability,
then a tertiary one, and so on. Two outcomes are compared first on their primary
entries; only if those tie does the secondary entry matter, exactly like ordering
words in a dictionary. Such systems were invented to model beliefs about events
that a rational agent considers *infinitely* less likely than the main
possibilities but not outright impossible — the classical mirror of an
infinitesimal.

Encode the list as a number in a non-Archimedean field: primary probability at
order $1$, secondary at order $\varepsilon$, tertiary at order $\varepsilon^2$,
and so on. Then the standard-part lens does precisely what dictionary ordering
does: it reads off the primary layer and discards the rest. An event that lives
only at the secondary level — infinitely less likely than the main outcomes — is
invisible to leading order, just as the thin quantum branch was. The two
seemingly different stories, quantum superposition and lexicographic belief, are
the *same theorem* viewed through different windows.

## Why bother? Infinitesimal probabilities, made honest

For a century, physicists and philosophers have flirted with "vanishingly small
but nonzero" probabilities — the chance of a wildly improbable branch, the weight
of a measure-zero event, the tail of an idealized experiment. Usually these are
either rounded to zero by hand, losing information, or kept as tiny reals, which
misrepresents an event that ought to be *infinitely* rather than merely *very*
unlikely. The framework here offers a third path: keep the infinitesimal exactly,
compute with it exactly, and apply the standard-part lens only at the very end,
when you ask what an observer records. The exact ledger and the observed world
are reconciled by a single well-behaved map.

Three natural extensions point beyond what is settled here. First, the observed
probabilities should assemble into a bona-fide finitely additive probability
measure on the set of branches — not just isolated numbers but a coherent
assignment to every collection of outcomes, additive over disjoint families;
this follows from the fact that the lens respects addition. Second,
observability should be an *invariant*: rescaling all amplitudes by an
appreciable factor changes nothing about which branches are visible, because
visibility depends only on an amplitude's order of magnitude relative to the
whole, not on any overall scale. Third, and most tantalizing, one can iterate. A
single lens resolves only the leading real layer; a refined lens tuned to
second-order infinitesimals would expose a branch of weight $\varepsilon^2$ that
the first lens missed. This yields a whole *tower of visibility levels*, a
filtration of reality by how deeply a possibility is hidden — a branch of weight
$\varepsilon^k$ invisible to the first $k$ lenses and revealed only by the
$(k{+}1)$-th.

## The moral

The lesson is quietly radical. "Possible" and "observable" are not the same
thing, and the gap between them can be made mathematically exact. By enlarging our
numbers to admit the infinitely small, we gain room to record possibilities that
the real line is too coarse to hold; by applying a single principled lens at the
moment of observation, we recover the ordinary world in which those possibilities
never appear. Somewhere in the ledger of the universe there may be a coin with an
infinitely thin face. It will never land — and yet it counts.
