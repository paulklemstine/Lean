# The Constant That Tames a Network: How One Number Governs Both Convergence and Depth

## A machine that swallows its own tail

Imagine a simple machine. You feed it a number, it spits out a new number, and then — without thinking twice — you feed that output straight back in. Crank the handle again and again. Where does the stream of numbers go?

For most machines the answer is "nowhere good." Tiny changes at the input get amplified into wild swings at the output; the numbers fly off to infinity, or thrash around forever without settling. But for a special family of machines, something almost magical happens: no matter where you start, the numbers home in on a single, stable value — a *fixed point* — and they do so at a guaranteed, predictable speed.

This article is about one such family, built from two of mathematics' most famous functions: the exponential $\exp$ and the logarithm $\log$. We call the machine the **EML operator**, short for *exp-minus-log*. Its rule is compact:

$$f(x) = e^{a}\,\log(b\,x + c).$$

Here $a$, $b$, and $c$ are dials you set before you start: $a$ controls an exponential amplification, $b$ a linear stretch, and $c$ a shift that keeps the logarithm well-behaved. Choose the dials wisely, and the EML machine becomes one of those rare, beautifully tame devices whose repeated application converges to a unique answer.

What makes this story worth telling is not just *that* it converges, but the discovery that a **single number** controls everything about the machine's behavior — how fast it settles, how sensitive it is to its dials, and, in a surprising twist, how it behaves when you stack many copies of it inside a modern neural network. That number is the **contraction ratio**, written $\rho$.

## Contraction: the mathematics of "calm down"

The secret ingredient is an idea called *contraction*. A function is a contraction if it always brings points closer together. Formally, there is some constant $\rho$ strictly less than $1$ such that for any two inputs $x$ and $y$,

$$|f(x) - f(y)| \le \rho\,|x - y|.$$

Every time you apply $f$, the gap between any two numbers shrinks by at least a factor of $\rho$. Apply it $n$ times, and the gap is squeezed by $\rho^{n}$ — an exponential collapse toward zero. Two travelers starting miles apart are forced, step by relentless step, to converge on the same destination.

This is the heart of the **Banach fixed-point theorem**, one of the load-bearing pillars of analysis. It guarantees that a contraction on a complete space has exactly one fixed point, and that iterating from *anywhere* lands you on it. The genius of applying it to the EML operator is that contraction can be checked with calculus. The derivative of $f$ measures the local stretching factor, and a direct computation gives a clean formula:

$$f'(x) = \frac{e^{a}\,b}{b\,x + c}.$$

If this derivative stays smaller than $1$ in absolute value across some interval, the mean value theorem upgrades that local fact into the global contraction bound. Concretely, if $|f'(x)| \le \rho$ everywhere on an interval $[\text{lo}, \text{hi}]$, then $f$ contracts distances by $\rho$ on that interval. The contraction ratio $\rho$ is born directly from the slope of the curve.

## A fixed point you can trust

Once you know the EML operator is a contraction on an interval that it maps into itself, three guarantees fall out like clockwork.

**It converges.** Start with any $x_0$ in the interval and build the sequence $x_{n+1} = f(x_n)$. The numbers form a Cauchy sequence — successive terms huddle ever closer — and therefore converge to a limit $x^\*$.

**The limit is the fixed point.** Because $f$ is continuous, the limit satisfies the self-referential equation

$$x^\* = e^{a}\,\log(b\,x^\* + c).$$

The machine has found a number it returns unchanged.

**The fixed point is unique.** Suppose two numbers $x_1$ and $x_2$ in the interval were both fixed. Then $|x_1 - x_2| = |f(x_1) - f(x_2)| \le \rho\,|x_1 - x_2|$. Since $\rho < 1$, the only way this can hold is if the distance is zero. There is one fixed point, and only one.

But the most useful guarantee is quantitative: we know *exactly how fast* the iteration converges. The **a priori error estimate** states that after $n$ steps,

$$|x_n - x^\*| \le \frac{|x_1 - x_0|}{1 - \rho}\,\rho^{n}.$$

Read that carefully. The right-hand side depends only on the very first step $|x_1 - x_0|$ — something you measure immediately — and on $\rho^{n}$, which plummets toward zero. You can compute, before running the iteration to completion, how many steps you need to reach any desired accuracy. This is what separates a *certified* algorithm from a hopeful one. The EML iteration is not merely convergent; it is convergent with a receipt.

## From abstract promise to concrete witness

A skeptic might object: this is all very nice, but does any genuine EML machine actually satisfy all these conditions at once? Mathematics is littered with theorems whose hypotheses are never met — beautiful statements about empty sets.

The answer is a concrete, fully verified witness. Take the dials $a = 1$, $b = 1$, $c = 100$, and the interval $[0, 20]$:

$$f(x) = e\,\log(x + 100).$$

On this interval the derivative is $e/(x+100)$, which never exceeds $e/100 < 3/100$, comfortably below the chosen ratio

$$\rho = \tfrac{1}{30} \approx 0.0333.$$

The function also maps $[0, 20]$ into itself: the logarithm of anything between $100$ and $120$ sits between $0$ and $\log 120 < 5$, and multiplying by $e < 3$ keeps the output under $15$ — safely inside the interval. Every requirement is met with room to spare. The trick is what one might call *slack engineering*: by choosing $c = 100$ large compared to the interval, the denominator $x + c$ stays big, the derivative stays tiny, and the slow growth of the logarithm keeps the output corralled.

For this concrete operator the iteration converges to a fixed point near $x^\* \approx 12.85$, and the error obeys

$$|x_n - x^\*| \le |x_1 - x_0|\cdot \frac{(1/30)^{n}}{1 - 1/30}.$$

With $\rho = 1/30$, each step buys you more than a full decimal digit of accuracy. Crucially, because $a = 1$ the exponential factor $e^{a}$ genuinely exceeds $1$ — this is a real exp-log composition, not a disguised straight line. The theory is not vacuous; it has a living example.

## The twist: a fixed-point machine hiding inside a neural network

Here the story takes an unexpected turn, and a bridge appears between two worlds that rarely speak to each other: the classical analysis of iterated maps, and the modern engineering of deep neural networks.

Deep networks are towers of layers, each transforming its input before passing it on. A persistent danger is that small input perturbations get amplified layer after layer, multiplying out of control. The mathematical measure of a layer's amplification is — once again — its Lipschitz constant. If each of $K$ stacked layers can multiply distances by a factor $L$, then the whole tower can multiply them by $L^{K}$. For $L > 1$ this is catastrophic exponential blow-up, and it is one reason very deep plain networks are hard to train.

The breakthrough that made extremely deep networks practical was the **residual connection**, the defining feature of the celebrated ResNet architecture. Instead of replacing the input $x$ with a transformed version $g(x)$, a residual block *adds* the transformation on top of the input:

$$x \;\longmapsto\; x + g(x).$$

This innocent-looking "skip" changes the arithmetic of amplification entirely. If $g$ has Lipschitz constant $L$, then the residual block satisfies

$$\|(x + g(x)) - (y + g(y))\| \le (1 + L)\,\|x - y\|.$$

The skip contributes the original distance, and $g$ adds at most $L$ times that distance. Growth is now **additive**, $1 + L$, rather than multiplicative. Stack $K$ such blocks and the worst-case amplification is $(1 + L)^{K}$, which by **Bernoulli's inequality** satisfies

$$(1 + L)^{K} \ge 1 + K\,L.$$

When $L$ is small, $(1+L)^K$ behaves almost linearly in depth rather than exploding. This is precisely why residual networks scale gracefully to hundreds of layers.

Now comes the unification. The EML operator's contraction ratio $\rho$ is a Lipschitz constant — and a tiny one. So why not use the EML fixed-point machine *as* the residual transformation $g$ inside a ResNet block? There is one obstacle: the EML operator is only contractive on its invariant interval $[\text{lo}, \text{hi}]$, while a network layer must accept any input the world throws at it.

The fix is elegant and costs nothing. Introduce the **clamp**, the function that projects any number back into the interval:

$$\operatorname{clamp}(x) = \min\!\big(\text{hi},\, \max(\text{lo},\, x)\big).$$

Anything below the floor is lifted to $\text{lo}$; anything above the ceiling is pulled down to $\text{hi}$; anything already inside is left untouched. Two facts make the clamp the perfect glue. First, it always lands inside $[\text{lo}, \text{hi}]$. Second, it is **$1$-Lipschitz** — it never increases the distance between two points (squashing things toward a wall can only bring them closer). Composing the EML operator with the clamp,

$$g(x) = f\big(\operatorname{clamp}(x)\big),$$

produces a map that is defined and contractive *everywhere*, with the same ratio $\rho$, because passing through a $1$-Lipschitz gate cannot worsen the bound. And on the interval where the dynamics actually live, the clamp is the identity, so the clamped layer agrees exactly with the genuine EML iteration. The clamp tames the map outside the action without disturbing it inside.

Feed this clamped EML map into the residual machinery and the two domains fuse into a single certified statement. A single EML residual block is $(1 + \rho)$-Lipschitz. A tower of $K$ such blocks amplifies distances by at most $(1 + \rho)^{K}$, which stays pinned above the linear floor $1 + K\rho$ — never the exponential catastrophe of a plain deep network. And $\rho$ is not some new tuning parameter: it is *exactly the contraction ratio from the fixed-point theorem*. For the concrete $e\,\log(x+100)$ machine, that means a depth-stable residual layer with Lipschitz budget $\rho = 1/30$, certified from end to end.

## One number, three roles

Step back and admire the architecture of the result. A single constant $\rho$ — the slope bound of an exp-log curve — plays three distinct roles:

- It is the **convergence rate** of the fixed-point iteration: the error shrinks like $\rho^{n}$.
- It is the **contraction guarantee** that makes the fixed point unique.
- It is the **Lipschitz budget** of a residual network layer, controlling depth stability through the additive law $1 + \rho$ and the Bernoulli floor $(1+\rho)^K \ge 1 + K\rho$.

The same transcendental quantity that decides how quickly an iteration settles also decides how safely you can stack the operation inside a deep network. The dynamics of a classical iterated map and the depth-stability of a modern architecture turn out to be two faces of one constant.

## Why it matters

There is a practical moral here for anyone who builds iterative algorithms or designs learning systems. Most neural network activations are chosen for convenience and trained by trial and error, with no guarantee about their dynamical behavior. The EML operator is different: it comes with mathematical certificates. You know it has a unique answer, you know how fast it will reach that answer, and — through the clamp-and-residual bridge — you know that stacking it many layers deep will not blow up.

This is the promise of building activation functions and iterative schemes on solid analytic foundations rather than empirical hope. When the contraction ratio is small, an EML-based system is simultaneously a fast solver and a stable deep architecture. The slope of a simple curve, $e^{a}b/(bx+c)$, becomes a budget you can spend with confidence — on speed, on uniqueness, and on depth.

The exponential and the logarithm are inverses, ancient partners that undo each other. Composed and iterated in the EML operator, they conspire instead to *converge* — and in doing so, they reveal a single number quietly governing both the rhythm of an iteration and the resilience of a network many layers deep.
