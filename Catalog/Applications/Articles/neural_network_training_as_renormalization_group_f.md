# The Forgetting Machine: Why Training a Neural Network Looks Like Zooming Out on the Universe

## A tale of two zoom levels

Imagine you are looking at a coastline from space. You see a smooth curve, a
clean boundary between land and sea. Now drop down to an airplane: the curve
sprouts bays and peninsulas. Drop again, to a beach: there are boulders,
pebbles, grains of sand, each one a jagged little coastline of its own. Physics
has a beautiful name for the act of changing your zoom level and asking what
*survives*: the **renormalization group**, or RG.

The renormalization group is one of the deepest ideas in modern science. It won
Kenneth Wilson the 1982 Nobel Prize in Physics, and it answers a question that
sounds almost philosophical: when you blur out the fine details of a system —
the individual atoms, the microscopic jitters — what large-scale behavior is
left? The astonishing discovery was that wildly different physical systems —
a magnet near its critical temperature, water at its boiling point, a fluid
separating into two phases — can blur down to the *exact same* large-scale
description. They belong to the same **universality class**. The microscopic
details wash out; only a few "relevant" features matter.

Now switch fields entirely. A modern neural network has hundreds of billions of
numbers in it, called *parameters*. Training the network means nudging those
numbers, over and over, to make the network's predictions better. Each nudge is
tiny. The process — *stochastic gradient descent*, or SGD — is the workhorse
behind every chatbot, image generator, and recommendation system you have ever
touched.

Here is the provocative claim at the heart of this article: **training a neural
network is itself an act of zooming out.** Each training step quietly throws away
fine-grained, fast-changing detail and keeps only the coarse, slow, important
structure. Training is renormalization. And if that is true, then neural
networks should have *universality classes* too — different networks, trained on
different data, should converge to the same destination as long as their data
"blurs down" to the same thing.

This article tells the story of how that intuition can be made into honest,
airtight mathematics. We will build a small, exact model of "training as
zooming out," and we will prove — with the certainty of a theorem, not the hope
of an analogy — that the fixed points of training and the fixed points of
renormalization are *literally the same set*, that training is an exponential
glide onto that set, and that where you land depends only on your universality
class.

## The one idea you need: a coarse-graining operator

To make the analogy precise, we need a mathematical gadget that *does* the
zooming-out. Physicists call it coarse-graining. Mathematically, the cleanest
version is something called an **idempotent linear operator**.

Let us unpack that. Picture the full list of a network's parameters as a single
arrow (a *vector*) in a very high-dimensional space `V`. Call this arrow `θ`
("theta"). Coarse-graining is an operation `P` that takes an arrow and returns a
blurred version of it: `P θ`. Two properties make `P` a genuine zoom-out:

- **Linearity:** blurring the sum of two configurations is the sum of their
  blurs. (Zooming out doesn't play favorites.)
- **Idempotency:** blurring something that is *already blurred* changes nothing.
  In symbols, `P(P θ) = P θ`. Once you have thrown away the fine detail, throwing
  it away again does nothing — there is nothing left to remove.

That second property is the soul of the whole construction. A coarse-graining
step is a *retraction*: it lands you on the manifold of "fully blurred"
configurations and, once you're there, holds you fixed.

From `P` we build its shadow, the **residual operator**:

> **Definition (residual).** `R = I − P`, where `I` is the identity. Concretely,
> `R θ = θ − P θ`.

If `P θ` is "the part of `θ` that survives zooming out," then `R θ = θ − P θ` is
exactly the part that *gets thrown away* — the fine detail, the high-frequency
noise, the irrelevant content. In physics language, `P θ` holds the **relevant
couplings** and `R θ` holds the **irrelevant** ones.

## Training has a loss; the loss has a gradient; the gradient is the residual

Neural networks learn by minimizing a *loss function* — a single number that
measures how unhappy we are with the current parameters. Training rolls `θ`
downhill on the loss landscape.

What loss corresponds to "wanting to be coarse-grained"? The most natural choice
is the **relevance loss**:

> **Definition (relevance loss).** `L(θ) = ½ ‖θ − P θ‖²`.

In words: the loss is half the squared length of the part that would be thrown
away. It is zero exactly when `θ` is already fully coarse-grained, and it grows
as `θ` carries more irrelevant detail. Minimizing `L` means *making your
parameters look like something that has already survived RG*.

Here is the first small miracle. If you compute the gradient of this loss — the
direction of steepest ascent, which gradient descent walks *against* — you get,
exactly, the residual operator:

> The gradient of `L(θ) = ½‖θ − Pθ‖²` is `R θ = θ − P θ` (when `P` is an
> orthogonal projection).

So "rolling downhill on the relevance loss" *is* "subtracting the irrelevant
content." Training and coarse-graining are not just cousins; they are driven by
the same vector field.

## Theorem 1: the two notions of "fixed point" are the same set

Every dynamical story has its resting places. For training, a resting place is a
**critical point**: a `θ` where the gradient vanishes, so SGD stops nudging. For
renormalization, a resting place is an **RG fixed point**: a `θ` that
coarse-graining leaves unchanged, `P θ = θ`. A magnet exactly at its critical
temperature sits at such a fixed point; zoom in or out, and it looks the same.

Our first theorem says these two sets of resting places coincide *exactly*.

> **Theorem 1 (SGD ↔ RG fixed points).** For any parameter vector `θ`,
> `R θ = 0` (an SGD critical point) **if and only if** `P θ = θ` (an RG fixed
> point).

The proof is a single line of algebra — `R θ = 0` means `θ − P θ = 0` means
`P θ = θ` — but its meaning is large. It says the destinations of training and
the destinations of renormalization are not merely *similar*; they are the *same
points in the same space*. The analogy has become an identity.

And those points have a clean geometric description:

> **Theorem 2 (fixed points = the relevant manifold).** When `P` is idempotent,
> `P θ = θ` if and only if `θ` lies in the *range* of `P` — the set of all
> possible blurred configurations.

So the fixed-point set is precisely the "screen" onto which coarse-graining
projects. Physicists would call it the **critical surface**; we have just shown
it is the image of the coarse-graining map.

## Theorem 3: training is an exponential glide

Knowing where a flow *rests* is one thing; knowing how it *gets there* is
another. We now write down the continuous-time version of gradient descent — the
limit of infinitely many infinitesimally small steps — and solve it in closed
form.

> **Definition (RG training flow).** Starting from initialization `x₀`, define
> `θ(t) = P x₀ + e^(−t) · (x₀ − P x₀)`.

Read that formula slowly, because it tells the whole story in one line. The
parameters split into two pieces. The first piece, `P x₀`, is the relevant,
coarse-grained part — and it carries no `t`, so it **never moves**. The second
piece, `x₀ − P x₀`, is the irrelevant part, multiplied by `e^(−t)`, which shrinks
toward zero as time goes on. Training freezes what matters and dissolves what
doesn't.

We prove four facts that pin this down rigorously:

> **Theorem 3a (correct start).** `θ(0) = x₀`. The flow begins where we
> initialized it.
>
> **Theorem 3b (relevant couplings are conserved).** `P(θ(t)) = P x₀` for all
> time `t`. The coarse-grained part is an exact conserved quantity along the
> entire trajectory — the slow modes are frozen, just as RG predicts.
>
> **Theorem 3c (it really solves the training equation).** The flow `θ(t)`
> satisfies the gradient ODE `θ'(t) = −R(θ(t))`. So this closed form is not a
> caricature of gradient descent; it *is* gradient descent on the relevance
> loss, written exactly.
>
> **Theorem 3d (exact exponential relaxation).** The distance from the running
> parameters to their destination is `‖θ(t) − P x₀‖ = e^(−t) · ‖x₀ − P x₀‖`.

That last equation is the punchline of the dynamics. The error decays as a clean
exponential `e^(−t)`, with rate exactly `1`. In RG language, the *rate* at which
an irrelevant mode dies off is a **critical exponent**, and we have computed it:
it is `1`, the slope of the so-called beta-function in the irrelevant direction.
There is no overshoot, no oscillation, no chaos — just a smooth, geometric glide
onto the critical surface.

## Theorem 4: convergence, and the punchline of universality

The exponential decay immediately gives convergence:

> **Theorem 4 (convergence).** As `t → ∞`, `θ(t) → P x₀`. Every training
> trajectory converges to the coarse-grained projection of its own starting
> point. And that limit is a genuine fixed point — `P(P x₀) = P x₀` — so training
> truly comes to rest on the critical surface.

Now we arrive at the summit. Recall that in physics, *universality* is the
miracle that microscopically different systems flow to the same place because
they share a few coarse features. Here is the exact analogue, as a theorem:

> **Theorem 5 (universality).** If two initializations `x₀` and `y₀` satisfy
> `P x₀ = P y₀` — that is, they belong to the same coarse-grained class — then
> their training flows converge to the **same** fixed point.

The destination of training is determined *entirely* by the universality class
`P x₀`, and not at all by the microscopic details `x₀ − P x₀` that get thrown
away. Two networks that look identical after blurring will train to the same
solution, no matter how different their raw initializations were. This is the
mathematical heart of the conjecture that opened this article: **neural networks
have universality classes.**

## Why this matters beyond the metaphor

It is tempting to enjoy analogies between deep learning and physics as poetry and
leave it there. The point of turning the analogy into theorems is that theorems
make *predictions* and *demands*.

- **A design principle.** If the destination depends only on `P x₀`, then to
  control where your network ends up, you should control its coarse-grained
  features — not fuss over microscopic initialization. The fine detail is
  literally irrelevant; the theory says so.

- **An explanation for robustness.** Practitioners have long noticed that
  retraining a network from a different random seed often lands somewhere
  functionally equivalent. Universality is exactly the statement that should be
  true if training is an RG flow: different seeds in the same class, same
  destination.

- **A spectrum of speeds.** The single rate `1` we computed is the simplest case,
  where coarse-graining is a clean projection. In a richer model where the
  coarse-graining operator has many eigenmodes, each irrelevant direction decays
  at its *own* rate — its own critical exponent. The slowest of these governs how
  long training really takes, a phenomenon physicists call *critical slowing
  down*. The framework here is the seed from which that fuller spectral story
  grows.

- **A bridge that carries traffic both ways.** Sixty years of renormalization
  theory — fixed points, relevant and irrelevant operators, universality classes,
  critical exponents — becomes a vocabulary for understanding learning. And the
  precise, finite-dimensional setting of machine learning becomes a clean
  laboratory for the abstract machinery of RG.

## The view from above

We began with a coastline seen from orbit and from a grain of sand. The deep
lesson of the renormalization group is that *the right description of a system
depends on the questions you can ask at your zoom level*, and that as you zoom
out, almost everything you thought was important quietly stops mattering. Only a
few relevant features survive, and they decide everything.

What we have seen is that this is not just a way of thinking about boiling water
and magnets. It can be made into exact, proven mathematics about how machines
learn. Training a neural network is a forgetting machine: step by step, it
integrates out the fast, fine, irrelevant detail and glides — exponentially,
inexorably — onto the surface of what truly matters. Where it lands is fixed not
by the noise it started with, but by the universality class it belongs to.

The same network, trained on different data, converges to the same fixed point —
*if the data lives in the same universality class.* That sentence began as a
conjecture borrowed from physics. Here, in a clean and rigorous setting, it has
become a theorem.
