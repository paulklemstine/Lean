# The Memory of a Moving System: How Composed Maps Remember Less and Less

Imagine a stage magician working an audience. Each minute they perform a new
trick — a shuffle, a fold, a fan of cards — and each trick transforms the deck
in some lawful way. After ten minutes the deck has passed through ten distinct
transformations, stacked one on top of another. A natural question lurks
underneath the spectacle: how much of the *original* arrangement of the deck can
still be recovered from what you see now? Intuitively, the answer can only get
worse with time. Information, once collapsed, does not spontaneously
re-expand. Every additional trick can destroy distinctions, but it can never
manufacture new ones out of nothing.

This little intuition — *systems that evolve by composition forget, and never
un-forget* — turns out to be a precise, provable theorem in linear algebra. And
it sits at the heart of a surprisingly broad class of mathematics: the theory of
**discrete linear cocycles**, the time-varying cousins of the matrix powers you
met in a first course on dynamics. This article tells the story of a small,
self-contained piece of that theory: the **transition endomorphism**, its
governing **cocycle identity**, and the clean monotonicity law for how its
"memory" — measured by rank — decays.

## The setup: a parade of linear maps

Fix a vector space $V$ over a field $K$. Think of $V$ as the space of all
possible "states" of some system — positions, velocities, populations, signal
amplitudes, whatever you like. A single linear transformation $g : V \to V$ is a
rule that takes one state and returns another, respecting addition and scaling.
In the language of algebra, such a self-map is called an **endomorphism** of $V$.

Now suppose the rule *changes over time*. At step $0$ we apply some map $f(0)$,
at step $1$ a possibly different map $f(1)$, at step $2$ the map $f(2)$, and so
on. We package this as a sequence of endomorphisms

$$f : \mathbb{N} \to (V \to_{\ell} V),$$

where the subscript $\ell$ is shorthand for "linear." This is the discrete,
time-varying analogue of a linear differential equation $\dot{x} = A(t)\,x$ whose
coefficient matrix $A(t)$ drifts as time passes. Engineers call such a thing a
**non-autonomous** or **time-varying linear system**; mathematicians call the
family of resulting evolution operators a **linear cocycle**.

The central object is what happens when you run the system for a *window* of
steps. Starting at time $i$ and evolving for $n$ steps, the cumulative effect is
the composite

$$\Phi(i, n) \;=\; f(i+n-1) \circ \cdots \circ f(i+1) \circ f(i).$$

Read it right to left, like function composition always demands: first apply
$f(i)$, then $f(i+1)$, all the way up to $f(i+n-1)$. We give this composite a
name — the **transition endomorphism** — and write it $\mathrm{transEndo}\,f\,i\,n$.
Two conventions pin it down at the edges. With zero steps, nothing happens, so

$$\mathrm{transEndo}\,f\,i\,0 = \mathrm{id},$$

the identity map; and with one step it is just the single map $f(i)$ itself. In
between, it is built up one factor at a time by the recursion

$$\mathrm{transEndo}\,f\,i\,(n+1) \;=\; f(i+n) \circ \mathrm{transEndo}\,f\,i\,n.$$

That recursion is the whole definition. Everything else in the theory is squeezed
out of it.

## The cocycle identity: the law of windows

Here is the first real theorem, and it is the engine of everything that follows.
Suppose you want the transition operator for a long window — say $m+n$ steps
starting at time $i$. You can always split that window in two: run the first $n$
steps, landing you at time $i+n$, then run the remaining $m$ steps from there.
Composition is associative, so chopping and reassembling the chain of maps must
give back exactly the same operator. In symbols:

$$\boxed{\;\mathrm{transEndo}\,f\,i\,(m+n) \;=\; \mathrm{transEndo}\,f\,(i+n)\,m \;\circ\; \mathrm{transEndo}\,f\,i\,n\;}$$

This is the **cocycle identity**. The word "cocycle" comes from the way the
formula stitches local pieces (single-step maps) into global ones (long-window
maps) in a consistent, overlap-respecting way — the same bookkeeping that shows
up in differential geometry, ergodic theory, and the theory of group extensions.
For us its meaning is humble and concrete: *a long evolution is the composition of
its consecutive sub-evolutions.* The proof is an induction on $m$, repeatedly
peeling one factor off the front and using associativity of composition. No
cleverness, no deep machinery — just the recursion applied with care.

The reason the cocycle identity matters so much is that it converts a question
about *one* big operator into a question about *two* smaller ones glued together.
And gluing is exactly where rank — our measure of memory — behaves predictably.

## Rank: the size of what survives

To make "how much the system remembers" precise, we use the **rank** of a linear
map: the dimension of its image, the set of states that are actually reachable as
outputs. Write it $\mathrm{finrank}\,K\,(\mathrm{range}\,T)$ for an operator $T$,
where $V$ is finite-dimensional so this number is a genuine non-negative integer.
A full-rank operator loses no dimensions; a rank-deficient operator has collapsed
some directions of $V$ down to zero, and those directions are gone for good.

The basic fact about composition and rank is almost a tautology once you see it.
If you feed the output of one map into another, the second map can only operate on
what the first one already produced. Its image is the image of an already-shrunken
space, so it cannot be any larger. Formally, for any composite $g \circ h$,

$$\mathrm{rank}(g \circ h) \;\le\; \mathrm{rank}(h),$$

because $\mathrm{range}(g \circ h) = g(\mathrm{range}\,h)$ is the image of
$\mathrm{range}\,h$ under $g$, and a linear image of a space never has larger
dimension than the space itself. Apply this with $h = \mathrm{transEndo}\,f\,i\,n$
and $g = f(i+n)$ — exactly the recursion that defines one extra step — and you
get the **one-step rank drop**:

$$\mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,(n+1)\big) \;\le\; \mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,n\big).$$

Each additional step can only hold the rank steady or push it down. Never up.

## The decay law: memory is antitone

From a single step to many steps is a short hop, and the cocycle identity carries
us there. Take any two window lengths with $n \le m$. Write $m = n + k$. The
cocycle identity factors the long window as

$$\mathrm{transEndo}\,f\,i\,m \;=\; \mathrm{transEndo}\,f\,(i+n)\,k \;\circ\; \mathrm{transEndo}\,f\,i\,n,$$

so the longer operator is the shorter one followed by $k$ more steps. By the
rank-of-composite bound, its image is a linear image of the shorter operator's
image, hence no larger. This gives the headline result, the **rank antitonicity
theorem**:

$$\boxed{\;n \le m \;\Longrightarrow\; \mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,m\big) \;\le\; \mathrm{rank}\big(\mathrm{transEndo}\,f\,i\,n\big)\;}$$

In words: *the rank of the transition operator is a non-increasing function of the
window length.* The longer you run a time-varying linear system, the smaller (or
equal) the space of states it can still reach. This is the precise, provable form
of the magician intuition we started with. The system's memory of its initial
configuration is monotonically eroded, and the erosion is irreversible.

Because the rank is a non-negative integer that only ever decreases, it must
eventually settle at a fixed value — it cannot fall forever. That observation
(pursued further in the research directions below) is the seed of a theory of
*eventual rank stabilization*, where the limiting rank measures the truly
permanent structure of the system, the part no amount of further evolution can
destroy.

## The flip side: when nothing is forgotten

There is a complementary story for systems that *preserve* information. A linear
map is **injective** when it never collapses two distinct states into one — when
different inputs always give different outputs. If every single-step map in a
window is injective, then nothing is lost at any step, and so the whole composite
must be injective too. This is the **injectivity propagation theorem**:

$$\Big(\forall k < n,\ f(i+k)\ \text{injective}\Big) \;\Longrightarrow\; \mathrm{transEndo}\,f\,i\,n\ \text{injective}.$$

The proof is again a clean induction: the identity map (zero steps) is injective,
and the composition of two injective maps is injective. Over a finite-dimensional
space, injectivity is equivalent to full rank, so this theorem is the optimistic
twin of the decay law — it identifies exactly the circumstance under which the
rank *never* drops at all.

## The autonomous special case: ordinary powers

All of the above allows the rule to change at every step. But what if it does
not? Suppose the system is **autonomous** — the same map $g$ is applied over and
over. Then the sequence is constant, $f(k) = g$ for all $k$, and the transition
endomorphism collapses into something completely familiar: the ordinary operator
power. A short induction proves the bridge identity

$$\mathrm{transEndo}\,(\lambda\_.\,g)\,i\,n \;=\; g^{\,n}.$$

Every theorem above now descends, for free, to the classical world of iterating a
single transformation. Rank antitonicity becomes the statement that

$$n \le m \;\Longrightarrow\; \mathrm{rank}(g^{\,m}) \;\le\; \mathrm{rank}(g^{\,n}),$$

the powers of any single endomorphism have non-increasing rank — a fact you may
have met when studying the stabilizing kernel and image filtrations of a nilpotent
or a Fitting decomposition. And injectivity propagation becomes the statement that
if $g$ is injective then so is every power $g^n$. The general cocycle theory is
not a detour around these classical facts; it *contains* them as the constant-rule
special case, and re-derives them with no extra work.

## Why this is more than bookkeeping

It would be easy to dismiss all of this as obvious. Composition shrinks images;
of course rank goes down. But the value of formalizing the intuition is exactly
that it stops being a vague feeling and becomes a load-bearing tool. The cocycle
identity is the single fact that everything rests on, and once it is nailed down,
the monotonicity laws fall out in one line each. That economy is the mathematical
aesthetic at work: find the one true lemma, and let the rest cascade.

The reach of this little theory is genuinely wide:

- **Control theory and signals.** The transition endomorphism is precisely the
  discrete *state-transition operator* of a time-varying linear system. Its rank
  is the dimension of the reachable subspace; the decay law says reachability can
  only contract as a maneuver lengthens, which is the abstract backbone of
  controllability and observability analysis.
- **Dynamical systems and ergodic theory.** Linear cocycles over a base dynamics
  are the objects whose long-run growth rates are quantified by Lyapunov
  exponents and the celebrated Oseledets theorem. The cocycle identity proved here
  is the very first axiom such a theory demands.
- **Markov chains and population models.** Replace "linear map" with "transition
  matrix" and the windows become products of stochastic matrices; the rank
  filtration tracks how quickly the chain forgets its initial distribution.
- **Numerical linear algebra.** Repeated application of an operator — the inner
  loop of the power method and of Krylov subspace solvers — is exactly the
  autonomous special case, where the rank filtration governs how the iteration's
  effective dimension stabilizes.

What ties them together is the same humble picture we began with: a system marching
forward in time, each step a linear rule, the accessible world quietly contracting
as the steps accumulate. The transition endomorphism gives that picture a name,
the cocycle identity gives it a law, and the antitonicity theorem gives it a
direction — always downhill, never back.

## The shape of an idea

Good mathematics often looks, in retrospect, inevitable. You define the right
object, you prove the one identity it satisfies, and a whole landscape of
consequences arranges itself around that identity like iron filings around a
magnet. The transition endomorphism is a small example of this pattern, but a
faithful one. From a two-line recursion we extracted a cocycle law; from the
cocycle law, a monotonicity theorem; from the monotonicity theorem, a guarantee
that every such system eventually settles into a stable core of unforgettable
structure. And by setting the rule constant, the whole edifice reproduces the
classical algebra of operator powers as a corollary.

The magician's deck, run through trick after trick, can only lose distinctions —
until, at last, it reaches a configuration so thoroughly mixed that no further
trick changes how much of the original is recoverable. That stable residue is the
true subject of the theory. Everything before it is just the system remembering a
little less, one composition at a time.
