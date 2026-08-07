# The Hidden Bookkeeping of Chance: How a Coin-Flip Cube Reveals Its Own Secrets

## A puzzle about wet floors

Imagine a square tile of porous rock, $n$ millimetres on a side, drawn as an $n \times n$ grid of tiny cells. Each cell is independently either *open* (water can pass) with probability $p$, or *blocked* with probability $1-p$. Pour water on the left edge. Does it reach the right edge?

This is percolation, and the question — "does the water cross?" — has a probability, call it $P(p)$. It is a polynomial in $p$, so it is as concrete as anything in mathematics. And yet almost everything interesting about it is hard. As $p$ climbs from $0$ to $1$, $P(p)$ climbs from $0$ to $1$, but *how* it climbs is the whole story. For large $n$ the climb happens almost entirely inside a razor-thin window of densities. Outside that window the answer is essentially deterministic; inside it, the system is poised between two worlds.

To understand a threshold you must understand *sensitivity*: how much does the answer depend on any single cell? The natural measure is the **influence** of a cell $v$, written $I_v$: the probability that cell $v$ is *pivotal*, meaning that opening it makes the water cross and blocking it stops the crossing. Cells deep inside a lake of open cells are irrelevant; cells sitting on a knife-edge between two nearly-connected clusters are everything.

Two inequalities have governed this subject for decades. The first says that a system with a sharp threshold must have large total influence:
$$P(1-P) \le p(1-p)\sum_v I_v .$$
The second, subtler one bounds the influences in a different norm:
$$p(1-p)\sum_v I_v^2 \le P(1-P).$$
The first is a Poincaré inequality; the second gives, through Cauchy–Schwarz, the celebrated *square-root law* $\sum_v I_v \le \sqrt{N}$ at $p = 1/2$ for a system with $N$ cells — no event on $N$ cells can have a threshold window narrower than about $1/\sqrt{N}$.

Both are inequalities. Both feel like they are hiding something. What, exactly, is the gap?

This article is about the answer: **both gaps are the same object, seen twice.** They are two different ways of reading a single accounting identity — a decomposition of "randomness" into levels, in which each inequality above is nothing but the observation that a certain list of nonnegative numbers has a nonnegative sum. Once you see the identity, you also see *precisely* when each inequality is tight.

## Turning coin flips into harmonics

The tool is Fourier analysis, but not the Fourier analysis of waves on a circle. Here the underlying space is the *discrete cube*: the set of all $2^N$ configurations $\eta$ assigning open/blocked to each of $N$ sites. A "function on the cube" is just a number attached to each configuration — for instance the indicator of "water crosses".

To do Fourier analysis you need an inner product and an orthonormal basis. The inner product is supplied by the coin flips themselves: for two functions $f, g$, set
$$\langle f, g\rangle = \mathbb{E}_p[f g] = \sum_{\eta} w_p(\eta)\, f(\eta)\, g(\eta),$$
where $w_p(\eta) = \prod_v \big(p \text{ if } v \text{ open}, \ 1-p \text{ if } v \text{ blocked}\big)$ is the probability of the configuration.

For the basis, start with the simplest nonconstant function attached to a single site $v$: the *centred character*
$$\psi_v(\eta) = \begin{cases} 1-p & \text{if } v \text{ is open in } \eta,\\ -p & \text{if } v \text{ is blocked in } \eta.\end{cases}$$
This is the site's own state, recentred to have mean zero. It has mean $0$ and variance $p(1-p)$. It is the discrete analogue of $\sin$ and $\cos$ — the fundamental tone of a single coin.

Now the crucial move. For an arbitrary **set** $S$ of sites, form the *overtone*
$$\psi_S(\eta) = \prod_{v \in S} \psi_v(\eta),$$
with the convention $\psi_\emptyset = 1$. The set $S$ plays the role of the frequency, and $|S|$ is the *degree*: $\psi_\emptyset$ is the constant, $\psi_{\{v\}}$ is the pure tone of a single site, and a large $S$ is a high-frequency mode that only notices intricate joint patterns across many sites.

Why do these overtones work? Because of a single, almost embarrassingly simple fact, which turns out to be the engine of everything.

> **The Product Rule.** Let $g_v$ be, for each site $v$, a function of that site's state alone. Then
> $$\mathbb{E}_p\Big[\prod_v g_v(\eta_v)\Big] = \prod_v \Big(p\, g_v(\text{open}) + (1-p)\, g_v(\text{blocked})\Big).$$

This is precisely the statement that the coins are *independent* — that the probability measure on the cube is a product measure — written in a form ready for algebra. Its proof is the expansion of a product of $N$ two-term sums into a sum of $2^N$ products, matched term by term against the $2^N$ configurations of the cube.

Apply the product rule to $\psi_S \psi_T$, which is a product of one-site functions, and everything falls out at once:

> **Orthogonality.** For any two sets of sites $S$ and $T$,
> $$\mathbb{E}_p[\psi_S \psi_T] = \begin{cases}\big(p(1-p)\big)^{|S|} & \text{if } S = T,\\[2pt] 0 & \text{otherwise.}\end{cases}$$

Indeed, at a site in both $S$ and $T$ the local factor is $\mathbb{E}[\psi_v^2] = p(1-p)$; at a site in exactly one of them it is $\mathbb{E}[\psi_v] = 0$, which kills the whole product; and at a site in neither it is $1$. So a *single* mismatched site annihilates the inner product.

## Completeness: nothing is left over

Orthogonality alone gives only *Bessel's inequality* — the energy captured by any partial family of characters is at most the total. That is exactly the form in which the two classical influence bounds have traditionally appeared, and exactly why they are inequalities: the family of low-degree characters $\{1\} \cup \{\psi_v\}$ is *incomplete*. To turn the inequalities into identities, one has to prove that when *all* $2^N$ characters $\psi_S$ are included, nothing at all is left over.

The proof is a beautiful piece of finite algebra. Define, for a function $f$ and a set $S$, the **Fourier coefficient**
$$\hat f(S) = \frac{\mathbb{E}_p[f\, \psi_S]}{\big(p(1-p)\big)^{|S|}}.$$
Consider the *reproducing kernel*
$$K(\xi, \eta) = \sum_{S} \prod_{v \in S} \frac{\psi_v(\xi)\,\psi_v(\eta)}{p(1-p)},$$
the sum running over all $2^N$ subsets. A sum over all subsets of a product is a product of binomials: the whole thing factors as
$$K(\xi,\eta) = \prod_v \left(\frac{\psi_v(\xi)\psi_v(\eta)}{p(1-p)} + 1\right).$$
Now inspect one factor. If $\xi$ and $\eta$ disagree at $v$, the numerator is $(1-p)(-p) = -p(1-p)$, the bracket is $-1 + 1 = 0$, and the whole product vanishes. If they agree, the bracket is $1/p$ or $1/(1-p)$ — the reciprocal of the probability of that site's state. So

> **The Reproducing Kernel Identity.** For $0 < p < 1$,
> $$\sum_{S} \prod_{v \in S} \frac{\psi_v(\xi)\psi_v(\eta)}{p(1-p)} \;=\; \begin{cases} 1/w_p(\eta) & \text{if } \xi = \eta,\\ 0 & \text{otherwise.}\end{cases}$$

The kernel is a delta function in disguise, and the $1/w_p(\eta)$ is exactly the weight needed to cancel the measure. Feeding it into $\sum_S \hat f(S)\psi_S(\eta)$ and exchanging the order of summation collapses the double sum to the single term $f(\eta)$:

> **Completeness.** For $0 < p < 1$, every real function on the cube is the sum of its Fourier series:
> $$f = \sum_{S} \hat f(S)\, \psi_S .$$

And then, immediately:

> **Parseval's Identity.** $\displaystyle \mathbb{E}_p[fg] = \sum_S \big(p(1-p)\big)^{|S|}\, \hat f(S)\, \hat g(S)$, and in particular
> $$\operatorname{Var}_p(f) = \sum_{S \neq \emptyset} \big(p(1-p)\big)^{|S|}\, \hat f(S)^2 .$$

Call $E_S(f) = (p(1-p))^{|S|}\hat f(S)^2$ the **energy at level $S$**. Variance is total nonconstant energy. A function's randomness has been sorted into bins indexed by frequency.

## Reading the two inequalities off the ledger

Now return to percolation — or to any *increasing* event $A$ (opening more cells cannot destroy the event). Encode it by the $\pm 1$ indicator $g$, equal to $+1$ on $A$ and $-1$ off it. Two facts calibrate the ledger:

- Since $g^2 \equiv 1$, Parseval gives the **Plancherel identity for Boolean functions**: $\sum_S E_S(g) = 1$. Total energy is always exactly $1$ — the levels form a probability distribution over frequencies.
- The empty level carries $E_\emptyset = (2P-1)^2$, and the *degree-one* coefficients are exactly the influences: $\hat g(\{v\}) = 2I_v$, so $E_{\{v\}} = 4p(1-p) I_v^2$. (This is the Fourier reading of the Margulis–Russo formula, which says the derivative $P'(p)$ equals $\sum_v I_v$.)

Substituting into $\sum_S E_S = 1$ and rearranging with $\operatorname{Var}(g) = 4P(1-P)$ gives an *identity* where before there was an inequality:

> **Exact Energy Decomposition.** For every increasing event,
> $$4P(1-P) \;=\; 4p(1-p)\sum_v I_v^2 \;+\; R, \qquad R = \sum_{|S| \ge 2} E_S(g) \ \ge\ 0.$$

There it is. The $\ell^2$ influence bound $p(1-p)\sum_v I_v^2 \le P(1-P)$ — the engine of the square-root law — *is* the statement $R \ge 0$. Nothing more. And the equality case is now transparent: the bound is tight exactly for events whose indicator has **no Fourier weight above degree one**, and it is strictly better than tight as soon as a single coefficient $\hat g(S)$ with $|S| \ge 2$ is nonzero.

What about the other inequality, the Poincaré bound? For that one needs a second identity, obtained by taking a function apart one coordinate at a time. Write $D_v f(\eta) = f(\eta \text{ with } v \text{ open}) - f(\eta \text{ with } v \text{ blocked})$ for the *discrete derivative* at $v$, and $A_v f$ for the average over $v$'s state. Then
$$f = A_v f + \psi_v \cdot D_v f,$$
an exact splitting in which both $A_v f$ and $D_v f$ ignore the coordinate $v$ entirely. Combined with the two one-site integrals $\mathbb{E}[\psi_v h] = 0$ and $\mathbb{E}[\psi_v^2 h] = p(1-p)\,\mathbb{E}[h]$ (valid for any $h$ not depending on $v$), it yields $\hat f(S) = \widehat{D_v f}(S \setminus v)$ for every $S$ containing $v$, hence

> **Site Energy Identity.** $\displaystyle \sum_{S \ni v} E_S(f) = p(1-p)\, \mathbb{E}_p\big[(D_v f)^2\big].$

Summing over $v$ counts each level $S$ exactly $|S|$ times, and subtracting the variance (which counts each nonempty level once) leaves:

> **The Exact Efron–Stein Defect.** For *every* real function on the cube,
> $$p(1-p)\sum_v \mathbb{E}_p\big[(D_v f)^2\big] \;-\; \operatorname{Var}_p(f) \;=\; \sum_{S \neq \emptyset} \big(|S| - 1\big)\, E_S(f) \ \ge\ 0.$$

Each term is nonnegative because $|S| \ge 1$ on nonempty sets — that is the entire proof of the Poincaré inequality. And for an increasing event, where $D_v g$ takes only the values $0$ and $2$ (so $\mathbb{E}[(D_vg)^2] = 2\,\mathbb{E}[D_vg] = 4I_v$), it specialises to
$$4p(1-p)\sum_v I_v - 4P(1-P) = \sum_{S \neq \emptyset}\big(|S|-1\big)E_S(g),$$
with the sharp conclusion: **the variance–influence inequality is an equality precisely when the event has no Fourier weight above degree one.**

## The same ledger, read two ways

Step back and look at the two defects side by side. Both are sums over levels of the *same* nonnegative energies $E_S(g)$, weighted differently:

| Inequality | Defect |
|---|---|
| $\ell^2$ bound, $p(1-p)\sum I_v^2 \le P(1-P)$ | $\displaystyle \tfrac14\sum_{|S| \ge 2} E_S$ |
| Poincaré, $P(1-P) \le p(1-p)\sum I_v$ | $\displaystyle \tfrac14\sum_{S \ne \emptyset}(|S|-1)E_S$ |

Two classical inequalities pointing in opposite directions, long proved by unrelated arguments — a residual-vector computation on one side, a hybrid-path union bound on the other — turn out to be two readings of a single ledger. They are tight under *the same* condition: no energy above degree one.

That condition is severe. A dictatorship, "cell $v$ is open", has all its energy at one level $\{v\}$ and makes both inequalities exact equalities simultaneously. Majority on three cells at $p = 1/2$ carries $3/4$ of its energy at degree $1$ and $1/4$ at degree $3$; the $\ell^2$ defect is $1/4$ and the Poincaré defect is $2 \cdot \tfrac14 = 1/2$. Percolation crossing on a large grid pushes nearly all its energy to high degrees, which is exactly why its threshold is so much sharper than the square-root law demands — and why "noise sensitivity" is the right name for what it does.

## Why the humble product rule matters

Everything above rests on one theorem: the product rule for the biased expectation. It is the formal encoding of independence, and it is the only place where independence is used. Orthogonality is the product rule applied to $\psi_S\psi_T$. The reproducing kernel is a product of binomials. The one-coordinate decomposition is the product rule at a single site.

That is not an accident of exposition; it is a road map. The great missing piece in this circle of ideas is *hypercontractivity* — the estimate that powers the Kahn–Kalai–Linial theorem, Talagrand's influence bounds, and the modern theory of noise sensitivity. And hypercontractivity is, structurally, a two-point inequality that gets **tensorized** to $N$ coordinates. Tensorization is exactly repeated application of the product rule, coordinate by coordinate. With the complete biased Fourier expansion in hand, the door to that theory is a single two-variable polynomial inequality away.

There is something satisfying about this. We started with water seeping through rock, asked when the answer is delicately balanced, and ended up with a ledger of frequencies in which two famous inequalities are revealed as the same nonnegativity statement. The randomness was never mysterious. It was just filed under headings we had not yet learned to read.
