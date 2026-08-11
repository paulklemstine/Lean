# The Forbidden Zone: Why Some Equations Have No Solutions At All

## A question about near misses

Ask a number theorist whether the equation
$$x_1^2 + x_2^2 + x_3^2 = 7$$
has a solution in whole numbers, and you will get a crisp "no" — with a classical reason attached (numbers of the form $8k+7$ are never sums of three squares). Ask instead whether
$$\left(x_1 - \tfrac12\right)^2 + \left(x_2 - \tfrac12\right)^2 + \left(x_3 - \tfrac12\right)^2 = 0.7$$
has a solution in whole numbers, and something different happens. There is no congruence obstruction to invoke, no clever modular arithmetic. And yet the answer is still no — and the reason is *geometric*. Every point of the integer grid $\mathbb{Z}^3$ sits at squared distance at least $3/4$ from the centre point $(\tfrac12,\tfrac12,\tfrac12)$, because each coordinate must miss $\tfrac12$ by at least $\tfrac12$. The target value $0.7$ falls into a **forbidden zone**: a whole interval of values that the left-hand side simply cannot reach.

This article is about that forbidden zone in full generality — how large it is, what happens just above it, and how it leaves a fingerprint on an infinite analytic sum built out of all the solutions at once.

## The set-up: shifted quadratic forms

A **quadratic form** in $n$ variables is a function
$$Q(x) \;=\; \sum_{i=1}^{n}\sum_{j=1}^{n} A_{ij}\, x_i x_j ,$$
determined by an $n \times n$ real matrix $A$. When $A$ is the identity matrix, $Q(x)=\|x\|^2$ is the ordinary squared length. Other choices of $A$ stretch, squeeze, and skew space: level sets of $Q$ are ellipsoids rather than spheres.

The **non-homogeneous** — or *shifted*, or *inhomogeneous* — problem replaces $x$ by $x - t$ for a fixed real shift vector $t \in \mathbb{R}^n$, and asks for integer solutions:
$$Q(x - t) = c, \qquad x \in \mathbb{Z}^n .$$

Geometrically: pick a point $t$ anywhere in space, draw the family of ellipsoids centred at $t$, and ask which of them meet the integer grid. The homogeneous case $t = 0$ always has the trivial solution $x=0$ with $c=0$; the shifted case has no such freebie, and that is exactly what makes it interesting. It is the setting of the classical *inhomogeneous minimum* of a form, of the covering radius of a lattice, and — in disguise — of the "closest vector problem" that underpins lattice-based cryptography.

## Spectral sandwiching: taming an arbitrary form

Working with a general matrix $A$ is unpleasant. The trick is to record only what matters: how much the form can stretch or shrink a vector. Say $A$ is **spectrally sandwiched between $m$ and $M$** if
$$m\,\|x\|^2 \;\le\; Q(x) \;\le\; M\,\|x\|^2 \qquad \text{for every } x \in \mathbb{R}^n .$$
For a symmetric matrix this is exactly the statement that all eigenvalues of $A$ lie in the interval $[m, M]$ — hence the word *spectral*. The ellipsoid $\{Q = 1\}$ is then trapped between two spheres, of radii $1/\sqrt{M}$ and $1/\sqrt{m}$.

Two constants, $m$ and $M$, are all the input we need. Every theorem below is stated in terms of them, so it applies verbatim to any positive definite form once its extreme eigenvalues are known. A diagonal form $Q(x) = \sum_i d_i x_i^2$ with all $d_i \in [m, M]$ is sandwiched, and the sum of squares is the case $m = M = 1$.

## The gap: how far the grid must stay away

The other ingredient is a measure of how badly the shift $t$ misses the grid. For a single real number $u$, let $d_{\mathbb{Z}}(u)$ denote the distance from $u$ to the nearest integer — concretely, $\min(\{u\}, 1 - \{u\})$ where $\{u\}$ is the fractional part. This is always between $0$ and $\tfrac12$, hits $0$ exactly at integers, and hits its maximum $\tfrac12$ at half-integers. Summing squares coordinatewise gives
$$d(t, \mathbb{Z}^n)^2 \;=\; \sum_{i=1}^{n} d_{\mathbb{Z}}(t_i)^2 ,$$
the squared Euclidean distance from $t$ to the nearest grid point.

The elementary but decisive observation — the humble engine of everything that follows — is that for any integer $k$ and real $u$,
$$d_{\mathbb{Z}}(u)^2 \;\le\; (u - k)^2 ,$$
because $d_{\mathbb{Z}}(u)$ is the distance to the *nearest* integer, and $k$ is merely one of them. Summing over coordinates: for every integer vector $x$,
$$d(t, \mathbb{Z}^n)^2 \;\le\; \|x - t\|^2 .$$
Feeding this into the spectral sandwich yields the first main theorem.

> **Spectral Gap Theorem.** Let $Q$ be spectrally sandwiched between $m \ge 0$ and $M$, and let $t \in \mathbb{R}^n$. Then for every integer point $x \in \mathbb{Z}^n$,
> $$Q(x - t) \;\ge\; m \, d(t, \mathbb{Z}^n)^2 .$$

The proof is two lines, and yet it is a genuine Diophantine obstruction. If $m > 0$ and the shift has even one non-integral coordinate, then $d(t,\mathbb{Z}^n) > 0$, so $Q(x - t) > 0$ for *every* integer $x$: the equation $Q(x-t) = c$ has **no** integer solution whenever
$$c < m\, d(t,\mathbb{Z}^n)^2 .$$
That interval $[0, \,m\,d(t,\mathbb{Z}^n)^2)$ is the forbidden zone. It is not modular, not congruence-theoretic; it is pure geometry — the grid simply cannot come closer.

For half-integral shifts, where every coordinate of $t$ has fractional part $\tfrac12$, the distance is maximal, $d(t,\mathbb{Z}^n)^2 = n/4$, and the gap becomes $mn/4$: the forbidden zone grows *linearly in the dimension*. This is the general theorem behind the concrete inequality
$$\sum_{i=1}^{n}\left(x_i - \tfrac12\right)^2 \;\ge\; \frac{n}{4} \qquad \text{for all } x \in \mathbb{Z}^n,$$
which settles our opening puzzle with $n=3$: the smallest attainable value is $3/4$, so $0.7$ is unreachable.

For **rational shifts** the gap can be made completely effective. If every coordinate of $t$ is of the form $a_i / q$ with $a_i, q$ integers, $q > 0$, and at least one $a_i$ is not divisible by $q$, then that coordinate is at distance at least $1/q$ from $\mathbb{Z}$, and hence
$$Q(x - t) \;\ge\; \frac{m}{q^{2}} \qquad \text{for all } x \in \mathbb{Z}^n .$$
No solutions below $m/q^2$: a clean, computable, denominator-driven obstruction, exactly parallel to the classical Liouville-style bounds in Diophantine approximation.

## The other side: you cannot hide forever

A lower bound alone would be a half-truth; a form could conceivably stay enormous on the whole grid. It cannot. Round each coordinate of $t$ to the nearest integer, obtaining $x_0 = \mathrm{round}(t)$. Each coordinate then errs by at most $\tfrac12$, so $\|x_0 - t\|^2 \le n/4$, and the upper half of the spectral sandwich gives:

> **Covering Bound.** There exists an integer point $x_0 \in \mathbb{Z}^n$ with
> $$Q(x_0 - t) \;\le\; \frac{Mn}{4}.$$

Combining the two, define the **inhomogeneous minimum**
$$\mu(Q, t) \;=\; \inf_{x \in \mathbb{Z}^n} Q(x - t),$$
the value of the smallest ellipsoid centred at $t$ that touches the grid. Then:

> **Spectral Sandwich Theorem.** For $Q$ spectrally sandwiched between $m \ge 0$ and $M \ge 0$,
> $$m\, d(t, \mathbb{Z}^n)^2 \;\le\; \mu(Q,t) \;\le\; \frac{Mn}{4}.$$

Both ends are attained simultaneously in the model case: for the sum of squares with a half-integral shift, $m = M = 1$ and $d^2 = n/4$, and the sandwich collapses to the exact value $\mu = n/4$.

There is a pleasing corollary, a **solvability window**: the inequality $Q(x-t) \le R$ is *always* solvable once $R \ge Mn/4$, and *never* solvable when $R < m\,d(t,\mathbb{Z}^n)^2$. Between those two thresholds lies the genuinely arithmetic regime, where the answer depends on the fine structure of $A$ and $t$.

## Counting near-solutions

Once we know solutions exist above the covering threshold, the natural next question is *how many*. Let $N(R)$ count the integer points with $Q(x - t) \le R$. A solution has every coordinate constrained: from $m\|x - t\|^2 \le Q(x-t) \le R$ we get $|x_i - t_i| \le \sqrt{R/m}$ for each $i$, so $x$ lives in a box of side $2\sqrt{R/m}$, giving

> **Counting Upper Bound.** Any set of integer solutions of $Q(x-t) \le R$ has at most $\left(2\sqrt{R/m} + 1\right)^n$ elements.

In the other direction, if $R \ge Mn/4$, then every integer point in the box of half-width $p = \sqrt{R/(Mn)}$ around $t$ satisfies $Q(x-t) \le M \|x-t\|^2 \le M n p^2 = R$, and such a box contains at least $(2p - 1)^n$ lattice points:

> **Counting Lower Bound.** For $R \ge Mn/4$ there are at least $\left(2\sqrt{R/(Mn)} - 1\right)^n$ integer solutions of $Q(x-t) \le R$.

Together these pin the growth rate: $N(R) \asymp R^{n/2}$, with explicit constants determined solely by $m$, $M$ and $n$. The representation numbers of a shifted form — the counts of integer vectors hitting a given value — therefore grow at most polynomially, never exponentially.

## The theta series: hearing the gap

Number theorists have a favourite way to package all these counts at once: the **theta series**
$$\Theta(s) \;=\; \sum_{x \in \mathbb{Z}^n} e^{-s\,Q(x - t)}, \qquad s > 0 .$$
Each integer point contributes a weight that decays with its energy $Q(x-t)$. The counting bound guarantees the sum converges for every $s > 0$: the terms are dominated by a product of one-dimensional Gaussian sums $\sum_{k \in \mathbb{Z}} e^{-sm(k - t_i)^2}$, each of which converges by comparison with a geometric series.

Now watch what the spectral gap does to it. Every single term satisfies $e^{-sQ(x-t)} \le e^{-(s-s_0)\,m\,d(t,\mathbb{Z}^n)^2}\, e^{-s_0 Q(x-t)}$ for $s \ge s_0 > 0$, because the exponent loses at least $(s-s_0)$ times the gap. Summing:

> **Theta Decay Theorem.** For $0 < s_0 \le s$,
> $$\Theta(s) \;\le\; e^{-(s - s_0)\, m\, d(t, \mathbb{Z}^n)^2}\;\Theta(s_0).$$

So the gap is not merely an obstruction to one equation — it is an exponential decay rate for the entire generating function. If the shift is off the lattice, $\Theta(s) \to 0$ as $s \to \infty$: the analytic shadow of the fact that $Q(x - t) = 0$ has no solution. Conversely the covering bound gives a floor,
$$\Theta(s) \;\ge\; e^{-s\,Mn/4},$$
since the rounded point alone contributes that much. The theta series is squeezed between two exponentials whose rates are the two ends of the spectral sandwich.

For diagonal forms the theta series factors completely: if $Q(x) = \sum_i d_i x_i^2$ with all $d_i > 0$, then
$$\Theta(s) \;=\; \prod_{i=1}^{n} \; \sum_{k \in \mathbb{Z}} e^{-s d_i (k - t_i)^2},$$
an $n$-fold product of classical shifted Jacobi theta values. The multidimensional problem dissolves into $n$ one-dimensional ones — a reminder that all the difficulty of the general case lives in the off-diagonal entries of $A$.

## Extremal configurations: who achieves the minimum?

For the flagship example — sum of squares, half-integral shift — we can say precisely which integer points achieve the record. Since $(k - \tfrac12)^2 \ge \tfrac14$ for every integer $k$, with equality exactly when $k \in \{0, 1\}$, an integer vector satisfies
$$\sum_{i=1}^{n}\left(x_i - \tfrac12\right)^2 \;\le\; \frac n4$$
**if and only if** every coordinate $x_i$ is $0$ or $1$. The minimisers are exactly the $2^n$ vertices of the unit cube. The inhomogeneous minimum $n/4$ is attained with multiplicity $2^n$ — exponentially degenerate, even though the *value* is dictated by a two-line inequality.

This is the picture the whole theory paints in miniature: a sharp forbidden zone, a threshold value determined by spectral data, and an extremal set with rich combinatorial structure sitting exactly at the boundary.

## Why this matters beyond number theory

The quantity $\mu(Q,t)$ has a very modern alter ego. In lattice-based cryptography, one hides a secret by perturbing a lattice point: a ciphertext is a target vector $t$ near, but not on, a lattice, and breaking the scheme means finding the closest lattice point. The inhomogeneous minimum is precisely the squared distance from $t$ to the lattice in the geometry defined by $Q$, and the covering radius bound $Mn/4$ is the worst-case guarantee that some lattice point is never too far away. The spectral gap, in the same language, is a *lower* bound on the noise-free decoding radius: no lattice point can be closer than $\sqrt{m}\, d(t, \mathbb{Z}^n)$, which is exactly what makes a small-noise ciphertext uniquely decodable.

The same inequalities animate other fields. In coding theory over the integers, the gap is a minimum-distance guarantee. In physics, $\Theta(s)$ is a partition function of a lattice of oscillators with $s$ playing the role of inverse temperature; the gap theorem says the free energy per unit $\beta$ tends to the ground-state energy $\mu(Q,t)$, and the exponential-degeneracy count $2^n$ in the model case is a residual entropy. And in optimization, the solvability window is a certified feasibility test for integer quadratic programs: a rejection certificate below the gap, a constructive solution above the covering bound.

## The moral

The story here is that two numbers — the smallest and largest eigenvalues of a quadratic form — plus one elementary observation about fractional parts, control an entire ecosystem of arithmetic phenomena: which values are unattainable, which are guaranteed attainable, how many representations a value has, how fast a generating function decays, and which configurations are extremal. There is no heavy machinery. The proof of the central inequality fits on a napkin.

What makes it satisfying is the *shape* of the result: a forbidden zone below, a guarantee above, and a narrow band in between where the real arithmetic happens. That is, in the end, what one always wants from a Diophantine theory — a clear statement of where solutions cannot be, so that the search can concentrate on where they might.
