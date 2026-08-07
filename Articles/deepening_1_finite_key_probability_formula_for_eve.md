# The Accounting of Influence

## How a single bookkeeping identity explains two opposite laws of randomness

Imagine a vast square grid of tiny valves. Each valve is open with probability $p$ and closed with probability $1-p$, independently of every other valve. Water is poured in at the left edge. Does it reach the right edge?

This is one of the oldest and most stubborn questions in probability. It is also, in disguise, the question of whether a random network survives, whether a random graph is connected, whether a random constraint problem is satisfiable, and whether a noisy election flips. All of these are *monotone events*: turning one more valve open can only help. And all of them exhibit a phenomenon that is easy to observe and hard to explain — a **sharp threshold**. For $p$ slightly below a critical value the water essentially never gets through; for $p$ slightly above it, it essentially always does. The transition happens in a window whose width shrinks as the system grows.

Why? The classical answer is a story about *influence*. And the story, it turns out, is really an exercise in accounting.

---

## Influence, and the two laws that bracket it

Fix a finite collection of sites — the valves — and call it $V$, with $n = |V|$ sites in all. A *configuration* $\eta$ assigns to each site the value **open** or **closed**. Under the $p$-biased product measure each site is open with probability $p$, so the probability of a specific configuration $\eta$ is exactly
$$\mu_p(\eta) \;=\; p^{\,\#\{v : \eta_v = \text{open}\}}\,(1-p)^{\,\#\{v : \eta_v = \text{closed}\}}.$$
An event $A$ (a set of configurations) is **increasing** if opening more valves never destroys membership: whenever $\eta \in A$ and $\xi$ is obtained from $\eta$ by opening some closed sites, $\xi \in A$ too. Crossing a grid is increasing. Connectivity is increasing. Satisfiability of a set of clauses, viewed as a function of which clauses are dropped, is increasing.

The site $v$ is **pivotal** for the configuration $\eta$ if the fate of $A$ hangs on $v$ alone: opening $v$ puts you in $A$, closing $v$ puts you out. The **influence** of $v$ is the probability of that happening,
$$I_v \;=\; \mu_p\big(\{\eta : v \text{ is pivotal for } A\}\big).$$
Influence is a *swing-voter* statistic. It measures how often the outcome of the whole system is decided by one valve.

Write $P = \mu_p(A)$ for the probability of the event. Two classical inequalities bracket the influences between them.

**The variance–influence (Poincaré) inequality.** The event's variance cannot exceed the total influence, discounted by the per-site variance $p(1-p)$:
$$P(1-P) \;\le\; p(1-p)\sum_{v} I_v.$$
Combined with Russo's formula — which says that the derivative $\frac{dP}{dp}$ is precisely $\sum_v I_v$ — this becomes a differential inequality, $P(1-P) \le p(1-p)\,P'$, and integrating it is exactly what proves that the threshold window is narrow. This is the inequality that *manufactures* sharp thresholds.

**The $\ell^2$ influence bound.** Simultaneously, the influences cannot all be large:
$$p(1-p)\sum_v I_v^2 \;\le\; P(1-P).$$
Feed this into Cauchy–Schwarz and you get the celebrated **square-root law**: $\big(\sum_v I_v\big)^2 \le n\,P(1-P)/(p(1-p))$, so at $p = 1/2$ the total influence of *any* monotone event on $n$ sites is at most $\sqrt{n}$. This is the inequality that *limits* how sharp a threshold can be: no monotone event on $n$ sites has a window narrower than order $1/\sqrt{n}$. Majority achieves it.

So one inequality says the total influence is *big enough*, and the other says it is *not too big*. They point in opposite directions. They are usually proved by completely different means — the first by a martingale or hybrid-path coupling argument, the second by Bessel's inequality in a Hilbert space of functions.

The result described here is that they are the **same statement, written twice**. Both are instances of one exact bookkeeping identity, and reading that identity off gives, for free, the exact size of the gap in each inequality and a complete characterisation of when each is tight.

---

## Weighing a function by frequency

The route to the identity runs through harmonic analysis on the cube — a Fourier theory not for waves on a circle, but for functions of $n$ coin flips.

At $p = 1/2$ this theory is classical and beautiful: encode open as $+1$, closed as $-1$, and any real function of $n$ bits is uniquely a multilinear polynomial $\sum_S \hat f(S)\prod_{v\in S} x_v$. Frequencies are *sets of coordinates*; the "level" of a term is how many coordinates it involves.

But percolation does not happen at $p = 1/2$, and the naive $\pm 1$ encoding stops being orthogonal the moment the coin is biased. The correct replacement is a **centred character** for each site,
$$\psi_v(\eta) \;=\; \begin{cases} 1-p & \text{if } v \text{ is open},\\[2pt] -p & \text{if } v \text{ is closed},\end{cases}$$
which has mean zero and variance $p(1-p)$ under the biased measure. For a set of sites $S$ put $\psi_S = \prod_{v\in S}\psi_v$, with $\psi_\emptyset = 1$.

The engine of everything is a single, almost self-evident statement that nonetheless carries all the weight:

> **The Product Rule.** For any functions $g_v$ of a single site,
> $$\mathbb{E}_p\Big[\prod_{v} g_v(\eta_v)\Big] \;=\; \prod_{v}\Big(p\,g_v(\text{open}) + (1-p)\,g_v(\text{closed})\Big).$$

This is the formal content of "the sites are independent". From it, orthogonality falls out in one line:

> **Orthogonality.** $\mathbb{E}_p[\psi_S\,\psi_T] = 0$ unless $S = T$, in which case it equals $\big(p(1-p)\big)^{|S|}$.

Indeed the expectation factorises coordinate by coordinate; a coordinate lying in exactly one of $S,T$ contributes the factor $\mathbb{E}_p[\psi_v] = p(1-p) + (1-p)(-p) = 0$, killing the whole product. A coordinate in both contributes $\mathbb{E}_p[\psi_v^2] = p(1-p)$.

So we may define the **$p$-biased Fourier coefficient** of a function $f$ at a set of sites $S$,
$$\hat f(S) \;=\; \frac{\mathbb{E}_p\big[f\,\psi_S\big]}{\big(p(1-p)\big)^{|S|}},$$
the normalisation chosen so that $\hat f(\emptyset) = \mathbb{E}_p[f]$.

Orthogonality alone gives only *Bessel's inequality*: the energy captured by any sub-family of characters is at most the total. To turn inequalities into identities you need **completeness** — the assurance that the characters $\{\psi_S\}$, indexed by all $2^n$ sets of sites, miss nothing.

Completeness follows from a lovely one-line computation. Consider the *reproducing kernel*
$$K(\xi,\eta) \;=\; \sum_{S \subseteq V}\ \prod_{v\in S}\frac{\psi_v(\xi)\,\psi_v(\eta)}{p(1-p)}.$$
A sum over all subsets of a product is a product of binomials: $K(\xi,\eta) = \prod_{v}\Big(1 + \frac{\psi_v(\xi)\psi_v(\eta)}{p(1-p)}\Big)$. Now examine one factor. If $\xi$ and $\eta$ *disagree* at $v$, the numerator is $(1-p)\cdot(-p) = -p(1-p)$ and the factor is exactly $0$. If both are open, the factor is $1 + \frac{(1-p)^2}{p(1-p)} = \frac{1}{p}$; if both closed, $1 + \frac{p^2}{p(1-p)} = \frac{1}{1-p}$. So

> **The Reproducing Kernel Identity.** $K(\xi,\eta) = 0$ if $\xi \ne \eta$, and $K(\eta,\eta) = 1/\mu_p(\eta)$.

The kernel is a delta function, weighted by the measure — and that is precisely the statement that expanding a function in the characters reproduces the function. Concretely:

> **Completeness.** For every $0 < p < 1$ and every real function $f$ on the cube,
> $$f(\eta) \;=\; \sum_{S\subseteq V}\hat f(S)\,\psi_S(\eta)\qquad\text{for every }\eta.$$

> **Parseval's Identity.** For all $f,g$,
> $$\mathbb{E}_p[f\,g] \;=\; \sum_{S\subseteq V}\big(p(1-p)\big)^{|S|}\,\hat f(S)\,\hat g(S),$$
> and in particular $\operatorname{Var}_p(f) = \sum_{S \ne \emptyset}\big(p(1-p)\big)^{|S|}\hat f(S)^2$.

Call $w_S = \big(p(1-p)\big)^{|S|}\hat f(S)^2 \ge 0$ the **energy at level $S$**. Parseval says the variance is the total energy off the empty set. Every question about $f$ becomes a question about how its energy is distributed among the $2^n$ levels.

---

## Two inequalities, one ledger

Now let $A$ be an increasing event and let $g = \mathbf 1_A - \mathbf 1_{A^c}$ be its $\pm 1$-valued indicator. Three facts pin down its low levels and its total:

- $\hat g(\emptyset) = \mathbb{E}_p[g] = 2P - 1$;
- $\hat g(\{v\}) = 2 I_v$ — the degree-one coefficients *are* the influences (this is the Fourier form of Russo's formula);
- since $g^2 \equiv 1$, Parseval gives $\sum_S w_S = 1$. **All the energy of a Boolean function sums to one.**

Put the three together. Splitting the total by level,
$$1 \;=\; \underbrace{(2P-1)^2}_{S = \emptyset} \;+\; \underbrace{4\,p(1-p)\sum_v I_v^2}_{|S| = 1} \;+\; \underbrace{R}_{|S|\ge 2},$$
where $R = \sum_{|S|\ge 2} w_S \ge 0$. Since $1 - (2P-1)^2 = 4P(1-P)$, this rearranges into an **exact energy decomposition**:

> **Energy Decomposition Theorem.** For every increasing event $A$ and every $0 < p < 1$,
> $$4P(1-P) \;=\; 4\,p(1-p)\sum_v I_v^2 \;+\; R,\qquad R = \sum_{|S|\ge 2}\big(p(1-p)\big)^{|S|}\hat g(S)^2 \;\ge\; 0.$$

The $\ell^2$ influence bound is now revealed for what it is: *the assertion that $R$ is nonnegative*. Nothing more. And because we know $R$ exactly, we know when the bound is tight — precisely when $A$ has no Fourier energy above level one — and we know it is strictly better than an equality as soon as a single coefficient at a set of two or more sites is nonzero.

The other inequality yields to the same ledger, read with different weights. For an arbitrary function $f$ define the discrete derivative at $v$,
$$(D_vf)(\eta) = f(\eta \text{ with } v \text{ open}) - f(\eta \text{ with } v \text{ closed}).$$
Every function splits as $f = A_vf + \psi_v\,D_vf$, where $A_vf$ is the average over the coordinate $v$; neither $A_vf$ nor $D_vf$ depends on $v$. Feeding this decomposition into the two one-coordinate integrals $\mathbb{E}_p[\psi_v h] = 0$ and $\mathbb{E}_p[\psi_v^2 h] = p(1-p)\mathbb{E}_p[h]$ (valid for $h$ not depending on $v$) shows that the coefficients of $f$ *above* $v$ are the coefficients of $D_vf$ with $v$ deleted, and hence:

> **Site Energy Identity.** $\displaystyle\sum_{S \ni v} \big(p(1-p)\big)^{|S|}\hat f(S)^2 \;=\; p(1-p)\,\mathbb{E}_p\big[(D_vf)^2\big].$

Sum over all sites $v$. On the left, each level $S$ is counted once for every one of its $|S|$ elements. So $p(1-p)\sum_v \mathbb{E}_p[(D_vf)^2] = \sum_S |S|\,w_S$. Subtract Parseval's variance $\sum_{S\ne\emptyset} w_S$ and the difference is transparent:

> **The Exact Efron–Stein Defect.** For every real function $f$ on the cube,
> $$p(1-p)\sum_v \mathbb{E}_p\big[(D_vf)^2\big] \;-\; \operatorname{Var}_p(f) \;=\; \sum_{S \ne \emptyset}\big(|S| - 1\big)\big(p(1-p)\big)^{|S|}\hat f(S)^2 \;\ge\; 0.$$

The Poincaré inequality is the assertion that this is nonnegative, and it is nonnegative for the childish reason that $|S| \ge 1$ on every nonempty set. Specialising to an increasing event, the derivative $D_vg$ takes only the values $0$ and $2$, so $(D_vg)^2 = 2D_vg$ and $\mathbb{E}_p[(D_vg)^2] = 4I_v$. Therefore:

> **The Poincaré Defect for Increasing Events.**
> $$4\,p(1-p)\sum_v I_v \;-\; 4P(1-P) \;=\; \sum_{S\ne\emptyset}\big(|S|-1\big)\big(p(1-p)\big)^{|S|}\hat g(S)^2,$$
> and consequently the variance–influence inequality is an **equality if and only if** $\hat g(S) = 0$ for every $S$ with $|S| \ge 2$.

Look at what has happened. Both inequalities are the same sum $\sum_S w_S$ read against a nonnegative weight function of the level:

| Inequality | Weight applied to $w_S$ | Zero exactly when |
|---|---|---|
| $\ell^2$ influence bound | $\mathbf 1\{|S| \ge 2\}$ | no energy above level 1 |
| Poincaré / variance–influence | $|S| - 1$ | no energy above level 1 |

Two weights, both vanishing on levels $0$ and $1$ and positive above — hence two inequalities pointing in opposite directions, with *identical* equality cases. The two classical bounds are not rivals; they are two projections of one ledger.

And the equality case has a name. A monotone event whose $\pm 1$-indicator has degree at most one is a **dictator** (or a constant): the outcome is decided by a single valve. Check it: for a dictator, $P = p$, one site has influence $1$ and the rest $0$, and both sides of both inequalities equal $4p(1-p)$. Everything else — every genuinely collective event — has a strictly positive defect in both directions, and the defect is not a mystery but an explicitly computable quantity, the higher-order energy.

---

## A worked instance, and the moral

Take majority on three sites at $p = 1/2$. Its energy sits $3/4$ at level one, $1/4$ at level three. The $\ell^2$ remainder is $R = 1/4$, and indeed $4P(1-P) = 1$ while $4p(1-p)\sum I_v^2 = 3/4$. The Poincaré defect is $\sum(|S|-1)w_S = 2\cdot\tfrac14 = \tfrac12$, and indeed $4p(1-p)\sum I_v = 3/2$ against $4P(1-P) = 1$. The level-three term — the genuinely three-way interaction, the fact that a majority is not any single voter — is what makes majority fall short of the equality case in *both* directions, by amounts $1/4$ and $1/2$ that come from the same $1/4$ of energy, weighted differently.

Take the crossing event on an $n \times n$ grid at $p = 1/2$. There the accounting reads
$$4\,P(1-P) \;=\; \sum_{v}I_v^2 \;+\; \text{(energy above level one)},$$
and the fact that a crossing is a global, cooperative phenomenon — that no single valve is a dictator — is precisely the statement that most of the energy lives at high levels. The width of the percolation threshold window is, at bottom, a question about where in the level spectrum a crossing event stores its variance.

The moral is one that recurs across mathematics. When two theorems bracket a quantity from opposite sides and are proved by unrelated arguments, one should suspect a conservation law underneath. Here the conservation law is Parseval's identity on the biased cube — the total energy of a Boolean function is $1$ — and the two theorems are what you see when you weigh that energy in two different ways. Making the ledger explicit does not merely re-prove the inequalities. It hands you the exact discrepancy in each, the complete list of extremal events, and a strict improvement whenever a single high-level coefficient fails to vanish.

The next chapter of this story is the one where the weights become *exponential* in $|S|$ rather than linear — the theory of hypercontractivity, from which the Kahn–Kalai–Linial theorem follows and with it the assertion that every balanced monotone event has some site of influence at least $c\log n / n$. That chapter also begins with the Product Rule: hypercontractivity on $n$ coordinates is nothing but the two-coordinate case applied $n$ times, coordinate by coordinate, exactly as the product rule permits. The bookkeeping, once set up, keeps paying.
