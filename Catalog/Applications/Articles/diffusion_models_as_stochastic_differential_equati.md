# How a Drop of Ink Learns to Paint: The Mathematics of Diffusion Models

## A picture that destroys itself, then comes back to life

Drop a bead of ink into a glass of water and watch what happens. The sharp dark
point blurs, spreads, and fades. Within a minute the water is a uniform, featureless
gray. The information that was once concentrated in a single spot — *here is the ink,
everywhere else is clear* — has dissolved into structureless noise. Physicists have a
name for this one-way slide from order into uniformity: **diffusion**. It is the same
process that cools your coffee, mixes cream into tea, and ultimately drives the whole
universe toward bland equilibrium.

Now imagine running the film backward. The gray water un-mixes. Ghostly structure
reappears. The ink gathers itself, against all intuition, back into a perfect bead.
This reversed movie looks like a violation of the laws of physics — and in a literal,
thermodynamic sense it is. But here is the astonishing twist that has reshaped
artificial intelligence over the past few years: *if you know the precise statistical
shape of the noise at every instant, you can run the film backward on purpose.* And
when you do, you do not just recover the original ink drop. You can conjure **entirely
new pictures** that were never there to begin with — a human face, a landscape, a
galaxy — all assembled out of pure static.

This is the secret engine inside the image generators that have captured the world's
imagination. They are, at heart, machines that have learned to reverse diffusion. And
the mathematics that makes this possible is older and more elegant than the AI that
uses it. It comes from the physics of a particle being jostled by random molecular
collisions while a spring gently pulls it home — a process named, almost a century ago,
after two physicists: **Ornstein and Uhlenbeck**.

This article tells the story of that mathematics, and of a small set of exact,
rock-solid facts at its core that have now been verified down to the last symbol.

## The forward journey: turning a picture into static

The first half of a diffusion model is the easy half: deliberately wrecking a picture.
You take your image — think of it, for simplicity, as a single number $X$, say the
brightness of one pixel — and you let it wander randomly while being slowly tugged toward
zero. In the language of physics, the rule of motion is a **stochastic differential
equation** (an equation that mixes a smooth, predictable push with a random kick):

$$ dX_t = -\tfrac{1}{2}\,X_t\,dt + dW_t. $$

Read it like a recipe for the next instant. The term $-\tfrac{1}{2}X_t\,dt$ is the
spring: it pulls the value gently back toward zero, with a strength proportional to how
far away it currently is. The term $dW_t$ is the random buffeting — *Brownian motion*,
the mathematical idealization of being knocked around by countless invisible molecular
impacts. Together they describe the **variance-preserving Ornstein–Uhlenbeck process**,
the workhorse of modern diffusion models.

The beautiful thing about this particular recipe is that it is *exactly solvable*. If you
start not with a single value but with a whole cloud of possibilities — a bell curve, or
**Gaussian**, with some average $m_0$ and some spread (variance) $v_0$ — then the cloud
stays a bell curve forever. You only need to track two numbers as time passes: where the
center of the bell sits, and how wide it is.

The center, which we call $m(t)$, follows a simple exponential decay:

$$ m(t) = m_0 \, e^{-t/2}. $$

The width, measured as variance $v(t)$, relaxes toward a fixed target:

$$ v(t) = 1 + (v_0 - 1)\, e^{-t}. $$

Stare at these two formulas and the entire forward process reveals itself. The mean
slides toward zero. The variance, no matter where it starts, glides toward the value
$1$. After enough time, *every* starting picture — bright pixel or dark, sharp edge or
smooth gradient — has been transformed into the very same thing: a standard bell curve
centered at zero with width one. The static. The blank gray water. All memory of the
original is gone.

## The laws the cloud obeys

These two formulas are not arbitrary; they are forced by the physics. If you take the
averaging operation (the expectation) of the SDE itself, you find that the mean must
obey its own miniature law of motion, a clean first-order differential equation:

$$ m'(t) = -\tfrac{1}{2}\, m(t). $$

In words: *the rate at which the center moves is proportional to how far it still is from
home.* That is the signature of exponential decay, and it is exactly satisfied by
$m(t) = m_0 e^{-t/2}$. This fact has been checked with complete rigor — the derivative of
the closed-form mean is, on the nose, minus one half times the mean itself.

The variance obeys an equally tidy law, this one obtained by applying the calculus of
random processes (Itô's formula) to the *square* of the value:

$$ v'(t) = 1 - v(t). $$

Here the story is even more vivid. The rate of change of the spread is the *gap* between
the current spread and the target value $1$. If the cloud is too narrow ($v < 1$), the
right-hand side is positive and the variance grows. If it is too wide ($v > 1$), the
right-hand side is negative and it shrinks. Either way it homes in on $1$. This too has
been verified exactly: the derivative of $v(t) = 1 + (v_0-1)e^{-t}$ is precisely
$1 - v(t)$.

Two consequences follow, and both have been nailed down as theorems.

First, **stationarity**: if you happen to start already at the target width, $v_0 = 1$,
then the variance never budges — $v(t) = 1$ for all time. The value $1$ is the fixed
point of the law $v' = 1 - v$, the place where the process is perfectly content to rest.

Second, **convergence to equilibrium**: as time runs to infinity, the mean tends to $0$
and the variance tends to $1$, regardless of the starting cloud. Mathematically,
$m(t) \to 0$ and $v(t) \to 1$. This is the precise statement that *all pictures dissolve
into the same noise.* The proof rests on a humble but essential fact — that $e^{-t}$
shrinks to nothing as $t$ grows — and it confirms what the ink drop told us intuitively:
diffusion forgets.

There is even a subtlety the rigorous treatment is careful about. The variance formula
$v(t) = 1 + (v_0-1)e^{-t}$ only describes a *genuine* spread (a positive number) when we
run time forward, $t \ge 0$. Push time backward toward $-\infty$ and $e^{-t}$ explodes;
for a starting width between $0$ and $1$ the formula would dip below zero, which is
nonsense for a variance. So the honest statement is: *for any positive starting spread
and any forward time, the variance stays positive.* On the physically meaningful
diffusion-time line, the cloud is always a real cloud.

## The return trip: reversing the arrow

If the forward process erases information, how on earth can we run it backward to create?
The key realization — the one that launched a thousand image generators — is that the
reverse of a diffusion is itself a diffusion, but with an extra steering term. To run the
film backward you need to know, at every moment and every location, which way the
probability is "leaning." That direction is captured by a quantity called the **score**.

The score is the slope of the logarithm of the probability density: it points toward
where the picture is more likely. For a bell curve with center $m$ and width $\sigma^2$,
the density is

$$ p(x) \propto \exp\!\Big(-\frac{(x-m)^2}{2\sigma^2}\Big), $$

and its logarithm, ignoring an additive constant that does not depend on $x$, is simply
the quadratic

$$ \log p(x) = -\frac{(x-m)^2}{2\sigma^2} + \text{const}. $$

Differentiate with respect to $x$ and the constant vanishes, leaving a strikingly simple
expression for the score:

$$ \nabla_x \log p(x) = -\frac{x-m}{\sigma^2}. $$

This is the **Gaussian score formula**, and it too has been verified exactly: the score
is the genuine derivative of the log-density, with the normalization constant correctly
shown to be irrelevant. In plain terms, the score always points *back toward the center*
of the bell, with a strength that grows the farther out you are. It is a restoring
signal — a compass that, at every point in the gray static, whispers "the structure was
this way."

A diffusion model is, fundamentally, a machine trained to estimate this compass. During
training it watches countless real images dissolve into noise and learns the score at
every noise level. Then, to generate, it starts from pure static — a sample from that
universal bell curve the forward process always produces — and takes many small steps
*against* the diffusion, each step nudged by the learned score. Slowly, structure
condenses out of chaos. A face emerges. The ink drop reassembles, except the "ink drop"
is a brand-new image the model invented.

## Why exactness matters

It would be easy to treat all of this as engineering folklore — formulas that "work well
enough" inside a neural network. But the heart of the method is genuine mathematics, and
genuine mathematics deserves genuine certainty. The handful of facts we have met —

- the mean decays as $m(t) = m_0 e^{-t/2}$ and obeys $m'(t) = -\tfrac12 m(t)$;
- the variance relaxes as $v(t) = 1 + (v_0-1)e^{-t}$ and obeys $v'(t) = 1 - v(t)$;
- the value $1$ is a stationary point, and $m(t)\to 0$, $v(t)\to 1$;
- the variance stays positive throughout the forward process;
- the Gaussian score is exactly $-(x-m)/\sigma^2$, the derivative of the log-density —

are the bedrock on which the whole edifice stands. Each has now been established as an
exact theorem, with no hand-waving and no "approximately." When a generative model
produces a photorealistic portrait, it is, in the end, riding on the back of these
unglamorous but unbreakable truths about how a jostled particle relaxes toward
equilibrium.

## From a glass of water to the frontier of AI

The deeper lesson is one of unexpected unity. The equations Ornstein and Uhlenbeck wrote
down to describe the velocity of a pollen grain in water turn out to be the same
equations that let a computer dream up images of things that have never existed. The
Fokker–Planck picture — the idea that you can forget about individual random trajectories
and instead track how an entire *probability cloud* flows and spreads — is the conceptual
bridge. The cloud's center and width march to the beat of two simple ordinary
differential equations, and from those two heartbeats everything else follows: the
inevitability of equilibrium, the special role of the standard bell curve, and the score
compass that makes the journey reversible.

There is a satisfying circularity here. Physics gave us diffusion as a story of
*irreversible* loss — the arrow of time, the inevitable slide toward gray. Mathematics
then showed that, with the right extra knowledge, the slide can be *undone*, not by
violating thermodynamics but by paying for it with information: the learned score. And
artificial intelligence took that insight and turned it into a creative engine.

A drop of ink, dispersing in water, contains the whole drama. Watch it fade, and you are
watching entropy win. Learn its score, and you hold the power to run the movie backward —
to summon, from nothing but structured static, a picture no one has ever seen. The
boundary between destruction and creation, it turns out, is a single exponential and a
gentle restoring force. That is the quiet mathematics behind one of the loudest
revolutions in modern technology.
