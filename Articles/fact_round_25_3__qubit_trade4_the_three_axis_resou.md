# The Cheapest Way to Break a Number Is the Obvious One

## A three-knob machine

Imagine you are handed a quantum computer and asked to factor a large number $N$. The recipe — order finding, the engine inside Shor's algorithm — has three knobs on its front panel, and every one of them costs money.

The **first knob** is the width of the counting register, $t$ qubits. Textbook practice sets $t$ to roughly twice the bit-length of $N$: the *full register*, or, as engineers building the thing tend to call it, *the wall*. Qubits are the single scarcest commodity in quantum hardware, so the temptation to shave a few bits off the wall is enormous, and an entire literature exists on doing exactly that.

The **second knob** is the number of samples $s$: how many times you run the circuit on a given base $a$ and read out a measurement. Each shot gives you a rational approximation which may or may not reveal the order of $a$.

The **third knob** is the number of base re-draws $k$: how many fresh $a$'s you try. This one matters more than it looks. For any particular base, the order of $a$ modulo $N$ may simply be unusable — odd, or leading to a trivial factor — and no amount of re-sampling *that same base* will rescue you. There is a hard per-$N$ ceiling on what one base can deliver. Re-drawing is the only escape hatch, and it is the escape hatch that Shor's algorithm actually specifies.

Together these three knobs define a **resource surface**: a three-dimensional grid of configurations $(t, s, k)$, each with its own success probability and its own price tag. The question this article is about is deceptively simple:

> **Where on that surface is the cheapest point that still works?**

The answer, it turns out, is: *exactly where the textbook told you to stand*. Not approximately, not usually — provably, and by an exponential margin. This article explains why.

## Modelling the surface

To reason about the surface at all, we need a model of how each knob feeds into success. Three ingredients suffice, and each corresponds to something concrete in the machine.

**Shots are independent Bernoulli trials.** A configuration performs $n$ runs of the circuit, each succeeding with probability $q$, independently. The chance that at least one of them works is
$$P(q, n) \;=\; 1 - (1-q)^n .$$

**The sample and re-draw axes enter only as their product.** A run is a run: $s$ samples on each of $k$ bases is $n = ks$ shots. The surface never sees $s$ and $k$ separately, only $ks$.

**Each shaved bit halves the per-shot chance.** Write $T$ for the full register width and let $d = T - t$ be the number of bits you have shaved. The continued-fraction step at the heart of order finding needs the measured phase to land inside a window whose width scales with the resolution of the register, so
$$q(d) \;=\; \frac{q_0}{2^{d}} ,$$
where $q_0$ is the per-shot success probability at the full register. Each bit you give up costs you a factor of two in *every single shot*.

**Cost is shots times circuit size.** A width-$t$ modular-exponentiation circuit is priced at $t^2$ gates (we will check later that nothing changes if you prefer $t^3$), so the total gate budget of a configuration is
$$G(n, t) \;=\; n\,t^{2} \;=\; k\,s\,t^{2}.$$

That is the whole model. Now watch what it forces.

## Law one: failure multiplies

The first structural fact is about the re-draw axis, and it is exact.

> **Cap-Lift Law.** Running $n$ independent blocks of $m$ shots each leaves a failure probability equal to the $n$-th power of the failure probability of a single block:
> $$1 - P(q, mn) \;=\; \bigl(1 - P(q,m)\bigr)^{n}.$$

The proof is one line: both sides equal $(1-q)^{mn}$. But the content is real. It says that the "per-$N$ unlucky cap" — the ceiling you hit when one base refuses to cooperate — is escaped *exactly* multiplicatively. Two consequences:

- **Doubling the re-draws squares the failure probability**: $1 - P(q,2n) = (1-P(q,n))^2$.
- **After $j$ doublings the failure probability is raised to the power $2^j$** — a doubly exponential collapse in the number of doublings.

This is not a fitted curve; it is an identity. And it is testable. In the experimental round behind this work, measurements at the full register with $s = 5$ samples gave success probabilities of $0.504$ at $k=1$, $0.735$ at $k=2$, and $0.940$ at $k=4$. Feeding only the $k=1$ number into the law predicts
$$1 - (1-0.504)^2 = 0.753984, \qquad 1 - (1-0.504)^4 = 0.939476\ldots$$
The $k=4$ prediction is off by less than $6 \times 10^{-4}$. The $k=2$ cell sits about $1.9 \times 10^{-2}$ low — the only visible deviation, and well inside the sampling error of twenty trials on each of twenty-four moduli.

## Law two: every doubling buys exactly the variance

How much does a doubling actually *gain* you? The answer is startlingly clean.

> **Fungibility Increment.** For any $q$ and any $n$, writing $P = P(q,n)$,
> $$P(q, 2n) - P(q, n) \;=\; P\,(1 - P).$$

Doubling either resource axis raises the success probability by exactly the **Bernoulli variance** of the current configuration. Three corollaries fall straight out:

- **Positivity below saturation.** If $0 < q < 1$ and $n \geq 1$, then $0 < P < 1$ and the gain $P(1-P)$ is strictly positive. Doubling *always* helps, everywhere below saturation — which is the precise version of the experimental observation that the mean probability gain per single-resource doubling was positive at every mixed-axis step measured.
- **A hard ceiling of one quarter.** Since $P(1-P) \leq \tfrac14$ for all $P$, no single doubling can ever buy more than $0.25$ of probability. (The measured $k{=}1 \to k{=}2$ increment, $0.735 - 0.504 = 0.231$, sits just under the ceiling, as it must.)
- **The ceiling is attained exactly at half-saturation**: the gain equals $\tfrac14$ if and only if $P = \tfrac12$. Doubling is most valuable precisely when you are on the knife edge, and nearly worthless once you are already reliable.

So the sample and re-draw axes are **perfectly fungible with each other** — the surface depends on them only through $ks$ — and each behaves in an entirely predictable, saturating way. Two of the three knobs are, mathematically, one knob.

## The third knob is different

Now the width axis. Here the arithmetic is unforgiving, and the reason is a collision between an exponential and a polynomial.

Start with an elementary but decisive bound: a union bound over $n$ shots gives $P(q,n) \le nq$. Substituting $q = q_0/2^d$ and rearranging yields

> **Exponential Shot Floor.** Any configuration at a register shaved by $d$ bits that reaches target probability $P^\ast$ must use at least
> $$n \;\geq\; \frac{P^\ast}{q_0}\,2^{d}$$
> shots.

Notice what this is: a *lower* bound holding for **every** configuration, however cleverly scheduled. Shaving $d$ bits multiplies your unavoidable shot count by $2^d$. Meanwhile, the saving is only that each shot got cheaper, from $T^2$ to $(T-d)^2$ gates — and $(T-d)^2 / T^2$ can never fall below zero, let alone below $2^{-d}$. The total gate bill at a shave of $d$ is therefore at least
$$\frac{P^\ast}{q_0}\,2^{d}\,(T-d)^{2},$$
an **exponentially growing** floor.

The comparison with the corner comes down to a pure inequality about real numbers, and it is where the whole verdict lives:

> **Trade-Off Inequality.** For every full width $T \geq 8$ and every shave $1 \leq d \leq T/2$,
> $$\tfrac54\,T^{2} \;<\; 2^{d}\,(T-d)^{2}.$$

The proof splits into the two small cases $d = 1$ and $d = 2$, handled by direct polynomial arithmetic in $T$, and the tail $d \geq 3$, where $2^d \geq 8$ while $(T-d)^2 \geq (T/2)^2 = T^2/4$, so the right-hand side is at least $2T^2$ — comfortably past $\tfrac54 T^2$. The exact same argument with cubes replacing squares gives $\tfrac54 T^3 < 2^d (T-d)^3$, so nothing below depends on whether you price a width-$t$ register at $t^2$ or $t^3$ gates.

## The verdict: the standard corner is optimal

Assemble the pieces. Suppose the full-register configuration is *efficient* — meaning its expected number of successes $n_0 q_0$ overshoots the union-bound floor $P^\ast$ by at most $25\%$, so $n_0 q_0 \leq \tfrac54 P^\ast$. Then:

> **Standard-Corner Optimality.** Fix a target $P^\ast > 0$, a full width $T \geq 8$, and an efficient full-register configuration of $n_0$ shots. For every shave $1 \leq d \leq T/2$, **every** configuration of $n$ shots at reduced width $t = T-d$ which still reaches $P^\ast$ satisfies
> $$n_0 T^{2} \;<\; n\,t^{2}.$$
> The same holds with cubes in place of squares.

In words: the quadratic saving from a narrower register is always overwhelmed by the exponential growth of the samples and re-draws needed to compensate. And since the sample and re-draw axes are fungible only with each other, there is nowhere else on the surface to hide — writing $n = ks$ leaves the conclusion untouched. **The minimum of the three-axis resource surface sits at the full-register corner $d = 0$.**

There is a nice concreteness available. With the round's fitted per-shot probability $q_0 = 1/8$ and target $P^\ast = 3/10$, three shots at the full register suffice, since $1 - (7/8)^3 = 0.3300\ldots \ge 0.3$; and the efficiency hypothesis holds with equality, $3 \cdot \tfrac18 = \tfrac38 = \tfrac54 \cdot \tfrac{3}{10}$. Working with the round's actual register, $T = 40$:

| configuration | width $t$ | shots needed | gate cost |
|---|---|---|---|
| **corner** | $40$ | $3$ | $\mathbf{4800}$ |
| wall $-\,2$ | $38$ | $\geq 10$ | $\geq 14440$ |
| wall $-\,4$ | $36$ | $\geq 39$ | $\geq 50544$ |

Shaving two bits triples the bill; shaving four multiplies it by more than ten. And these are *floors*, not measurements — no scheduling trick lowers them.

## How steep is the wall, exactly?

One can say something sharper than "it gets worse." Comparing the exponential floor at a shave of $d$ against the union-bound floor $(P^\ast/q_0)T^2$ of the corner, and using $t = T-d \geq T/2$:

> **The Wall.** For $T \geq 8$, $d \geq 1$, and $2d \leq T$, every admissible configuration at width $t = T-d$ costs at least
> $$\frac{2^{d}}{4}\cdot\frac{P^\ast}{q_0}\,T^{2}$$
> gates.

The penalty factor **doubles with each further bit removed**. Qubit-shaving is not a trade; it is a cliff.

## And how low is the floor?

An optimality theorem is only worth something if the optimum is itself in a good place. It would be a hollow victory to prove that the cheapest corner of a quantum algorithm is cheaper than its own neighbourhood while the whole neighbourhood is more expensive than just trying every candidate by hand.

So we locate the corner on the absolute scale. The natural yardstick is a square-root-scale exhaustive search: for a modulus of $2M$ bits, trial division up to $\sqrt{N}$ costs on the order of $2^M$ operations. The corner's cost, under the more pessimistic cubic pricing, is $3T^3$ with $T = 2M$. Is the cubic really below the exponential at realistic sizes? Yes, and from quite modest sizes onward:

> **Cubic-Exponential Separation.** For every integer $M \geq 20$,
> $$24\,M^{3} \;<\; 2^{M}.$$
> Consequently, for a full register of width $T = 2M$ with $M \geq 20$, the corner cost satisfies $3T^{3} < 2^{M}$.

The proof is a clean induction. The base case is a computation: $24 \cdot 20^3 = 192000 < 1048576 = 2^{20}$. The inductive step needs only that the left side grows by a factor $(1 + 1/M)^3$, which is at most $2$ as soon as $M \geq 4$, while the right side grows by exactly $2$. The exponential wins the ratio race from the base case onward, and never gives the lead back.

So the geography of the surface is complete: a **polynomial floor at the textbook corner**, strictly below square-root-scale classical search, and an **exponential cliff in every direction** in which one tries to economise on register width.

## What this does and does not say

It is worth being careful about the shape of the claim, because stating it precisely changes its character.

The optimality verdict is **not** a statement about the fitted numbers of any particular experiment. Stripped of its narrative, it is the inequality $\tfrac54 T^2 < 2^d (T-d)^2$, and its hypotheses are load-bearing rather than decorative. It fails at $T = 4$, $d = 2$ — a tiny register shaved in half is a genuinely different regime — and it degenerates entirely at $d = T$, where the "register" has vanished. The theorem is a statement about **moderate shaves of a large enough register**, and that is exactly the regime anyone building hardware cares about.

Nor does the model claim to be the last word on order finding. It prices a *fixed* configuration; it treats the per-shot probability as exactly geometric in the shave; it charges $t^2$ (or $t^3$) gates per shot. What it captures, and captures exactly, is the structure of the trade: one axis whose cost is exponential and two axes whose payoff saturates at a variance.

And that structure is the point. There has been a persistent hope, running through a decade of "can we do Shor with fewer qubits" papers, that the three resources of order finding are fungible enough that some clever interior point of the surface — a slightly narrow register, generously re-sampled — would beat the textbook parameterisation. The surface *does* exist, and it *is* fungible: two of its three axes are literally interchangeable, and probability rises everywhere below saturation as you spend more of anything. But the fungibility is not symmetric. The cheap axes buy variance, capped at a quarter per doubling. The expensive axis charges an exponential. When you price the whole thing honestly, the minimum retreats to the corner it started at.

The textbook, in other words, was not a first draft waiting for optimisation. It was already the answer.
