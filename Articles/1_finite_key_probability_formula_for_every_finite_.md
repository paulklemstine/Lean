# One Dial for Every Coin: How a Single Random Draw Explains All of Percolation at Once

## A coffee filter, a forest fire, and a broken rock

Pour water on a slab of porous rock. Some of the microscopic pores are open, some are blocked, and whether the water gets through depends on whether the open pores happen to line up into a channel from the top face to the bottom. Light a match at the edge of a forest. Whether the fire crosses to the other side depends on whether the burnable patches happen to chain together. Knock out routers in a network at random. Whether the network stays connected depends on the same kind of question.

All of these are the same mathematical problem, and it has a name: **percolation**. You take a grid of sites, you declare each site independently *open* with probability $p$ and *closed* with probability $1-p$, and you ask whether the open sites contain a path crossing from one side to the other.

Everybody's intuition says the same thing: *the bigger $p$ is, the more likely you are to cross.* This is so obvious that it is easy to forget it needs a proof. And when you try to write that proof directly, something annoying happens. At $p = 0.4$ you are dealing with one probability distribution on configurations; at $p = 0.5$ you are dealing with a *different* distribution on the same set of configurations. There is no configuration that lives in both worlds. Comparing two probabilities computed against two different measures is exactly the kind of comparison that has no obvious handle.

The fix is one of the loveliest tricks in probability, and it is the subject of this article. Instead of tossing a coin for each site *for each value of $p$*, you draw one random number per site, **once**, and then you turn a dial.

## The key trick

Here is the setup. Let $\iota$ be a finite set of sites — the cells of an $n \times n$ grid, the edges of a graph, the pixels of an image, whatever you like. To each site $v \in \iota$ attach an independent random number $x_v$ drawn uniformly from the interval $[0,1]$. Call the whole family $x = (x_v)_{v \in \iota}$ the **key**. It is drawn once and never touched again.

Now define, for each threshold $p \in [0,1]$, a configuration $\Theta_p(x)$ by the rule

$$\Theta_p(x)_v = \begin{cases} \text{open} & \text{if } x_v \le p,\\ \text{closed} & \text{if } x_v > p.\end{cases}$$

Think of the keys as a fixed landscape of numbers scattered over the grid, and of $p$ as a water level rising from $0$ to $1$. At level $p$, the sites already submerged are the open ones. As you raise the dial, sites open and *never close again*.

Two things are true of this picture, and everything else in this article follows from them.

**First: at each fixed level, the picture is exactly right.** The configuration $\Theta_p(x)$ has precisely the law you want — independent sites, each open with probability $p$. Concretely:

> **Theorem (Finite-key probability formula).** For every finite site set $\iota$, every threshold $p \in [0,1]$, and every configuration $\eta$,
> $$\mathbb{P}\big(\Theta_p(x) = \eta\big) \;=\; p^{\,|\{v : \eta_v \text{ open}\}|}\,(1-p)^{\,|\{v : \eta_v \text{ closed}\}|}.$$

The proof is a one-liner once you see it. The set of keys producing a *prescribed* configuration $\eta$ is a box: for each open site of $\eta$, the key must lie in $[0,p]$; for each closed site, in $(p,1]$. The key family is independent, so the probability of the box is the product of the side lengths, and those are $p$ and $1-p$ respectively. Multiply and you are done.

**Second: raising the dial only opens sites.** If $p \le q$ and $x_v \le p$, then certainly $x_v \le q$. So $\Theta_p(x)$ is *contained in* $\Theta_q(x)$, site by site, for **every single key** — not on average, not with high probability, but always.

This second fact is what makes the trick worth its weight. All the models, at all densities simultaneously, now live on one probability space, nested inside one another like a family of Russian dolls indexed by $p$.

## Monotonicity, for free

Call an event $A$ — a set of configurations — **increasing** if opening extra sites can never destroy it. "There is an open crossing from left to right" is increasing. "Vertices $u$ and $v$ are connected" is increasing. "At least $17$ sites are open" is increasing. Nearly every event a percolation theorist cares about is increasing.

Now watch. If $A$ is increasing and $p \le q$, then every key whose level-$p$ picture is in $A$ has a level-$q$ picture in $A$ too, because the level-$q$ picture has *more* open sites. So the set of good keys at level $p$ is literally a subset of the set of good keys at level $q$. Larger sets have larger probability. Therefore:

> **Theorem (Monotonicity).** For every increasing event $A$, the function
> $$\pi_A(p) \;=\; \sum_{\eta \in A} p^{\,|\text{open}(\eta)|}(1-p)^{\,|\text{closed}(\eta)|}$$
> is nondecreasing on $[0,1]$.

There is no computation here at all. A subset inclusion did all the work. That is the whole point of the coupling: it converts an analytic inequality about competing polynomials into a set-theoretic triviality.

## Strictly increasing, and why that is harder

Nondecreasing is nice; *strictly* increasing is what you actually want, because it tells you the crossing probability genuinely responds to the density and never plateaus. Here the coupling earns its keep a second time, and this time we have to build something.

An increasing event is called **nondegenerate** if it is nonempty and does not already contain the all-closed configuration. (If it contains all-closed, then being increasing forces it to be everything, and its probability is the constant $1$. If it is empty, its probability is the constant $0$. Those are the only degenerate cases, and they are genuinely constant, so nondegeneracy is exactly the right hypothesis.)

> **Theorem (Strict monotonicity).** If $A$ is increasing and nondegenerate, then $\pi_A$ is strictly increasing on $(0,1)$: for $0 < p < q < 1$ we have $\pi_A(p) < \pi_A(q)$.

The proof is a construction. Among all configurations in $A$, pick one, call it $\eta$, with the *fewest* open sites. Since $A$ does not contain the all-closed configuration, $\eta$ has at least one open site $v$. And since $\eta$ was minimal, closing $v$ must kick us out of $A$: the site $v$ is **pivotal** for $\eta$.

Now build a target region in key space. Demand that
- the key at $v$ lands in the window $(p, q]$,
- the keys at the other open sites of $\eta$ land in $[0,p]$,
- the keys at the closed sites of $\eta$ land in $(q,1]$.

This is a box of positive probability — its volume is $(q-p)\cdot p^{k}\cdot(1-q)^{m}$ for suitable exponents $k,m$, and every factor is strictly positive because $0 < p < q < 1$. On this box the level-$q$ picture is exactly $\eta$, which is in $A$; and the level-$p$ picture is $\eta$ with $v$ closed, which is *not* in $A$. So this box is a chunk of positive probability that belongs to the $q$-event and is disjoint from the $p$-event. The inclusion from the previous section is therefore strict by at least the volume of this box. Done.

The picturesque version: as the water level rises past a single carefully chosen key, a crossing that did not exist snaps into place. The set of key-landscapes for which this happens is not a measure-zero curiosity; it is a solid box with positive volume.

## Russo's formula: the derivative is a census of pivotal sites

The function $\pi_A$ is a polynomial in $p$. It is natural to ask for its derivative, and the answer is one of the organising principles of the whole field.

Say a site $v$ is **pivotal** for $A$ at a configuration $\eta$ if flipping $v$ flips membership: opening $v$ puts you in $A$, closing $v$ puts you out. (Note this does not depend on the current state of $v$ itself — pivotality is a property of the *other* sites.) Write $\mathrm{Piv}_v(A)$ for the set of such $\eta$.

> **Theorem (Finite Russo formula).** For every increasing event $A$ on a finite site set and every $p$,
> $$\pi_A'(p) \;=\; \sum_{v \in \iota} \pi_{\mathrm{Piv}_v(A)}(p).$$
> In words: the rate at which the event becomes more likely equals the expected number of sites that are on the knife's edge.

The proof is a beautiful piece of bookkeeping. Each weight $p^{|\text{open}|}(1-p)^{|\text{closed}|}$ is a product over sites of $p$ or $1-p$; differentiating a product with the Leibniz rule replaces one factor by $\pm 1$ and leaves the rest alone. So the derivative of $\pi_A$ becomes a double sum over sites $v$ and configurations $\eta \in A$, with a sign $+1$ if $v$ is open in $\eta$ and $-1$ if closed. Now pair each configuration with its twin obtained by flipping $v$. If both twins are in $A$ their contributions are $+w$ and $-w$ and cancel. If neither is in $A$ they contribute nothing. Only *split pairs* survive — and because $A$ is increasing, a split pair must have the open twin inside $A$ and the closed twin outside, which is precisely pivotality, and its surviving contribution is $+w$. Collect the survivors and you get the pivotal probabilities.

Russo's formula immediately re-proves both monotonicity results in a completely different style. Probabilities are nonnegative, so $\pi_A' \ge 0$ on $[0,1]$: monotone. And $\pi_A'(p) > 0$ for $p \in (0,1)$ exactly when some site is pivotal for some configuration — which is precisely the nondegeneracy condition, since the minimal configuration constructed above supplies a pivotal site. Two independent proofs of the same theorem, one geometric and one analytic, is a good sign that you have found the right statement.

## Harris's inequality: good news travels together

The last piece is the most subtle, and the most useful in practice. Suppose you learn that the grid has an open left-right crossing. Does that make it *more* or *less* likely that some particular site is open? More, obviously — but "obviously" has burned us before.

> **Theorem (Harris inequality).** If $A$ and $B$ are increasing events on a finite site set, then for every $p \in [0,1]$,
> $$\pi_A(p)\,\pi_B(p) \;\le\; \pi_{A \cap B}(p).$$
> Increasing events are positively correlated.

The engine is a remarkable identity satisfied by the Bernoulli weights. Given two configurations $\eta$ and $\xi$, form their coordinatewise minimum $\eta \wedge \xi$ (open only where both are) and coordinatewise maximum $\eta \vee \xi$ (open where either is). Then

$$w_p(\eta)\,w_p(\xi) \;=\; w_p(\eta \wedge \xi)\,w_p(\eta \vee \xi).$$

Why? Because at each site, the multiset of the two states $\{\eta_v, \xi_v\}$ is exactly the multiset $\{\min, \max\}$ — the two products contain literally the same factors, just reshuffled. The Bernoulli measure is *log-supermodular*, with equality. Log-supermodular measures on a distributive lattice obey the Fortuin–Kasteleyn–Ginibre correlation inequality, and applying it to the indicator functions of $A$ and $B$ — which are monotone functions on the lattice $\{\text{closed}, \text{open}\}^\iota$ — gives Harris.

Harris has children. Taking complements, an increasing event and a *decreasing* event are negatively correlated: $\pi_{A \cap B^c} \le \pi_A \pi_{B^c}$. Iterating over a finite family, $\prod_k \pi_{A_k} \le \pi_{\bigcap_k A_k}$. Complementing that gives the *product form of the square-root trick*,

$$\prod_k \big(1 - \pi_{A_k}(p)\big) \;\le\; 1 - \pi_{\bigcup_k A_k}(p),$$

which says: if a union of increasing events is very likely, then at least one of them individually is not too unlikely. This is the standard route to lower bounds on crossing probabilities in modern percolation arguments.

## Back to the grid

Put the machinery to work on the $n \times n$ square grid, with the event $H_n$ that some path of open sites joins the first row to the last. It is increasing (adding open sites cannot delete a path). It is nonempty (open everything and walk straight down a column). It excludes the all-closed configuration (a path needs at least its own starting site open). So it is nondegenerate, and all four theorems apply. Writing $\theta_n(p) = \pi_{H_n}(p)$:

- $\theta_n$ is nondecreasing on $[0,1]$ and **strictly increasing on $(0,1)$**;
- $\theta_n'(p) = \sum_{v} \mathbb{P}_p(v \text{ pivotal for a crossing})$, and this is strictly positive on $(0,1)$;
- for any increasing $B$, $\theta_n(p)\,\pi_B(p) \le \pi_{H_n \cap B}(p)$; in particular, conditioning on a crossing can only raise the chance that a prescribed site is open, since $p\,\theta_n(p) \le \mathbb{P}_p(H_n \text{ and } v \text{ open})$.

These are exact statements about honest polynomials, and for small $n$ you can just write them down. For $n=1$, $\theta_1(p) = p$. For $n=2$,

$$\theta_2(p) = 2p^2 - p^4 = p^2(2-p^2).$$

For $n=3$,

$$\theta_3(p) = 3p^3 + 4p^4 - 6p^5 - 9p^6 + 14p^7 - 6p^8 + p^9.$$

Evaluate at the self-dual-looking point $p = 1/2$ and a pattern emerges:

$$\theta_1(\tfrac12) = \tfrac12, \quad \theta_2(\tfrac12) = \tfrac{7}{16} = 0.4375, \quad \theta_3(\tfrac12) = \tfrac{197}{512} \approx 0.3848, \quad \theta_4(\tfrac12) = \tfrac{22193}{65536} \approx 0.3386.$$

The values are drifting downward. Meanwhile the derivatives at the same point,

$$\theta_1'(\tfrac12) = 1, \quad \theta_2'(\tfrac12) = \tfrac32, \quad \theta_3'(\tfrac12) = \tfrac{481}{256} \approx 1.879, \quad \theta_4'(\tfrac12) = \tfrac{4441}{2048} \approx 2.168,$$

are climbing — the transition is getting sharper as the grid grows, which is exactly the finite-size fingerprint of a phase transition. And the density $p_n$ at which a crossing is an even bet drifts *upward*, away from $1/2$:

$$p_1 = 0.5, \quad p_2 \approx 0.5412, \quad p_3 \approx 0.5593.$$

That upward drift is the finite-size shadow of the fact that the critical density for site percolation on the square lattice is not $1/2$ but roughly $0.5927$ — a number no one has ever expressed in closed form. What our theorems give, rigorously and for every finite $n$, is the *shape* of the curve: strictly increasing, with derivative equal to a pivotal census, and with all the positive-correlation structure that makes finite-size scaling arguments possible.

## Bonds instead of sites, and why none of this cared about grids

Nothing above used the grid. The site set $\iota$ was an arbitrary finite set; the only structure required was the lattice $\{\text{closed},\text{open}\}^\iota$ and the notion of increasing event. So the same theorems apply verbatim to **bond percolation**, where the random objects are the edges of a graph rather than its vertices: take $\iota$ to be the set of unordered pairs of vertices, and the same independent uniform keys, thresholded at $p$, realise the Bernoulli bond measures of every density simultaneously. Connectivity between two prescribed vertices is an increasing bond event, so its probability is nondecreasing in $p$, positively correlated with every other increasing bond event, and its derivative is the census of pivotal edges.

The same abstraction covers random graph thresholds, reliability polynomials of networks, monotone Boolean function analysis, and the noise-sensitivity literature — anywhere you have a finite family of independent bits and a monotone question about them.

## What the trick really is

If there is a single idea to take away, it is this: **a hard comparison between two probability measures can sometimes be replaced by an easy comparison between two sets, if you are willing to build a bigger space where both measures live at once.** The uniform keys are that bigger space. They cost nothing — a random number per site — and they buy monotonicity as a subset inclusion, strict monotonicity as an explicit box of positive volume, the derivative as a census of pivotal sites, and positive correlation as a rearrangement of factors in a product.

That, in the end, is why the humble rising water level deserves a place beside the deeper theorems it supports. It does not merely *prove* that more open sites means more crossings. It makes the statement look like what it always felt like: obvious.
