# The Shortest Road Between Two Beliefs

## How far apart are two probability distributions?

Suppose you have two coins. One is fair; the other lands heads with probability $0.51$. How different are they?

There is an obvious answer and a subtle answer, and the tension between them is one of the quiet engines of modern statistics.

The obvious answer measures the disagreement directly. Line the two distributions up side by side and add up the absolute differences:
$$\|p - q\|_1 \;=\; \sum_i |p_i - q_i|.$$
For our coins this is $|0.51-0.5| + |0.49-0.5| = 0.02$. Half of this number, $0.01$, is the *total variation distance*: it is exactly the largest amount by which the two coins can disagree about the probability of any event whatsoever. If you must bet on a single yes-or-no question, $0.01$ is your maximum edge.

The subtle answer takes seriously the fact that the space of probability distributions is *curved*. Moving from $p_1 = 0.5$ to $p_1 = 0.51$ is a small, cheap step, because near $1/2$ a coin's behaviour changes slowly and it takes many flips to notice. But moving from $p_1 = 0.999$ to $p_1 = 0.9999$ — the same numerical gap of $0.0009$ in probability, no more — is a *huge* step statistically: the second coin produces tails ten times less often, and you will notice after a few thousand flips. The $L^1$ distance is blind to this. It treats every unit of probability mass as equally valuable no matter where in the simplex it sits.

The measure that is *not* blind is the **Fisher–Rao metric**. It is the intrinsic geometry of statistics, discovered by asking a purely operational question: how many samples do you need to tell $p$ from a nearby $p + v$? The answer is governed by the quadratic form
$$\|v\|_p^2 \;=\; \sum_i \frac{v_i^2}{p_i},$$
which weights a displacement $v_i$ by the inverse of the probability $p_i$ where it happens. Motion in a low-probability coordinate is *expensive*; motion in a high-probability coordinate is cheap. Take the square root and you have the **Fisher–Rao speed** of a moving distribution. Integrate the speed along a path and you have its **Fisher–Rao length**.

This article is about the exact relationship between these two answers. The headline is a clean inequality with a one-line proof and a remarkably long list of consequences:

> **Theorem (the $L^1$–Fisher–Rao length bound).** Let $t \mapsto p(t)$ be a smooth curve of strictly positive probability vectors on a finite set, with velocity $v(t)$, defined for $t$ in an interval $[a,b]$. Then
> $$\sum_i |p_i(b) - p_i(a)| \;\le\; \int_a^b \sqrt{\sum_i \frac{v_i(t)^2}{p_i(t)}}\, dt.$$
> In words: *the $L^1$ displacement between the ends of a path never exceeds the Fisher–Rao length of the path.*

Equivalently: the total variation distance between the endpoints is at most **half** the Fisher–Rao length. Information geometry dominates the crude, flat picture — always, everywhere, with the sharpest possible constant.

## Why is it true? A single application of Cauchy–Schwarz

The whole theorem is an integrated version of a statement about a single instant of time. Ask: at a given moment, how fast can the distribution move in $L^1$?

The $L^1$ speed is $\sum_i |v_i|$. The Fisher–Rao speed is $\sqrt{\sum_i v_i^2/p_i}$. The claim is that the first is at most the second. Here is the entire argument. Write each term with a factor of $\sqrt{p_i}$ inserted and removed:
$$\sum_i |v_i| \;=\; \sum_i \frac{|v_i|}{\sqrt{p_i}} \cdot \sqrt{p_i}.$$
Now apply the Cauchy–Schwarz inequality to the two vectors $\left(|v_i|/\sqrt{p_i}\right)_i$ and $\left(\sqrt{p_i}\right)_i$:
$$\sum_i \frac{|v_i|}{\sqrt{p_i}} \cdot \sqrt{p_i} \;\le\; \sqrt{\sum_i \frac{v_i^2}{p_i}} \cdot \sqrt{\sum_i p_i}.$$
And here the simplex does its work: $\sum_i p_i = 1$, so the second factor is exactly $1$ and disappears. What is left is
$$\sum_i |v_i| \;\le\; \sqrt{\sum_i \frac{v_i^2}{p_i}},$$
the infinitesimal $L^1 \le$ Fisher–Rao bound. That is the whole idea.

To get from the instant to the interval, use the fundamental theorem of calculus coordinate by coordinate: $p_i(b) - p_i(a) = \int_a^b v_i(t)\,dt$, hence $|p_i(b) - p_i(a)| \le \int_a^b |v_i(t)|\,dt$. Summing over $i$ and exchanging the (finite) sum with the integral gives
$$\|p(b) - p(a)\|_1 \;\le\; \int_a^b \sum_i |v_i(t)|\, dt,$$
and then the pointwise inequality above, integrated, converts the right-hand side into the Fisher–Rao length. Done.

Two things deserve to be noticed. First, the hypothesis $p_i(t) > 0$ is not cosmetic. If the curve touches the boundary of the simplex — if some coordinate hits zero — the integrand $v_i^2/p_i$ blows up, and the Fisher–Rao length can genuinely be infinite while the $L^1$ displacement stays small. Second, only the behaviour on $[a,b]$ matters. Straight-line segments in the simplex, extended forever, eventually leave it; the theorem holds in a localized form assuming positivity and normalization only on the interval you care about, which is what one applies in practice.

## Is the constant $1$ the right one?

An inequality with a constant invites suspicion. Perhaps $\|p(b)-p(a)\|_1 \le \tfrac{1}{2} L$? Or $\le 0.9\,L$? The question is settled completely by one exactly solvable family of curves.

Fix a parameter $r \in [0,1)$ and let a coin's bias sweep sinusoidally:
$$p(t) \;=\; \left(\frac{1 + r\sin t}{2},\; \frac{1 - r\sin t}{2}\right), \qquad t \in [0, \pi/2].$$
At $t=0$ the coin is fair; at $t = \pi/2$ it has bias $(1+r)/2$. The $L^1$ displacement is exactly $r$, by direct computation.

The Fisher–Rao length can also be computed in closed form. The velocity is $v(t) = \left(\tfrac{r\cos t}{2}, -\tfrac{r\cos t}{2}\right)$, so the Fisher–Rao speed is
$$\sqrt{\frac{(r\cos t/2)^2}{(1+r\sin t)/2} + \frac{(r\cos t/2)^2}{(1-r\sin t)/2}} \;=\; \frac{r\cos t}{\sqrt{1 - r^2\sin^2 t}},$$
which is precisely the derivative of $\arcsin(r \sin t)$. Integrating from $0$ to $\pi/2$:
$$L \;=\; \arcsin r.$$

So for this family the theorem says exactly $r \le \arcsin r$ — a classical fact about the sine function, here reappearing as a statement of information geometry. Three consequences follow:

* **The inequality is strict** for every $r \in (0,1)$, since $\sin x < x$ for $x > 0$. No non-degenerate curve in this family achieves equality.
* **The constant $1$ is nonetheless optimal.** As $r \to 0$, $\arcsin r / r \to 1$. For any $\varepsilon > 0$ one can exhibit a curve in the family with $L \le (1+\varepsilon)\|p(b)-p(a)\|_1$. No constant smaller than $1$ works.
* **Long curves are much worse than short ones.** As $r \to 1$ the ratio $\arcsin r / r$ climbs to $\pi/2 \approx 1.571$. Fisher–Rao length substantially overestimates $L^1$ displacement when the distribution travels far.

## The sphere hiding inside the simplex

The proof above is elementary, but it conceals a beautiful geometric fact that explains everything. Consider the map
$$p \;\longmapsto\; \left(\sqrt{p_1}, \sqrt{p_2}, \dots, \sqrt{p_n}\right).$$
Since $\sum_i (\sqrt{p_i})^2 = \sum_i p_i = 1$, this sends the probability simplex onto the positive orthant of the unit sphere in $\mathbb{R}^n$. It is an old observation of Bhattacharyya's, and it turns the Fisher–Rao metric into something entirely familiar: if $p_i$ moves with velocity $v_i$, then $\sqrt{p_i}$ moves with velocity $v_i/(2\sqrt{p_i})$, and
$$\sum_i \left(\frac{d}{dt}\sqrt{p_i}\right)^2 \;=\; \frac{1}{4}\sum_i \frac{v_i^2}{p_i}.$$
So the Fisher–Rao speed is exactly **twice the ordinary Euclidean speed of the square-root curve on the sphere**. The exotic-looking information metric is, up to a factor of two, just round spherical geometry in disguise.

This immediately suggests a sharper theorem, and it is true: the *chord* of the square-root curve is at most half the Fisher–Rao length,
$$\left\|\sqrt{p(b)} - \sqrt{p(a)}\right\|_2 \;\le\; \tfrac{1}{2} L.$$
This is the statement "a curve is at least as long as the straight line between its endpoints", transported through the square-root map. Its proof is a small trick worth savouring: instead of integrating a vector-valued object, one tests the curve against the *single scalar functional* $t \mapsto \langle \Delta, \sqrt{p(t)}\rangle / \|\Delta\|$, where $\Delta = \sqrt{p(b)} - \sqrt{p(a)}$. Its derivative is bounded by half the Fisher–Rao speed (Cauchy–Schwarz again), its total change is exactly $\|\Delta\|$, and one-dimensional calculus finishes the job. Notably, this chord bound needs *no* simplex constraint at all — it is a purely metric statement.

Rewriting the chord bound in statistical language, using the **Bhattacharyya coefficient**
$$\mathrm{BC}(p,q) = \sum_i \sqrt{p_i q_i}$$
(the cosine of the spherical angle between the square-root points), one gets
$$1 - \mathrm{BC}\big(p(a), p(b)\big) \;\le\; \frac{L^2}{8}.$$
For short curves this is far stronger than the $L^1$ bound: the overlap deficit shrinks *quadratically* in the length. Two distributions joined by a short Fisher–Rao path are not merely close — they overlap almost completely.

## Dropping smoothness entirely

Everything so far assumed a differentiable curve. Remarkably, the length bound survives with no smoothness at all, if one replaces "length" by the natural discrete notion: the sum of spherical steps.

Given two distributions, the spherical distance between their square-root images is the **Bhattacharyya angle** $\arccos \mathrm{BC}(p,q)$. The single-step estimate is a classical inequality of Le Cam:
$$\|p - q\|_1 \;\le\; 2\sqrt{1 - \mathrm{BC}(p,q)^2},$$
proved by the same Cauchy–Schwarz mechanism, factoring $|p_i - q_i| = |\sqrt{p_i} - \sqrt{q_i}|\,(\sqrt{p_i} + \sqrt{q_i})$ and splitting the product. Since $\sin \theta \le \theta$, this upgrades to $\|p-q\|_1 \le 2\arccos \mathrm{BC}(p,q)$ — twice the spherical distance. Chaining along an arbitrary finite path $p^{(0)}, p^{(1)}, \dots, p^{(N)}$ of probability vectors and using the triangle inequality for $L^1$:
$$\big\|p^{(N)} - p^{(0)}\big\|_1 \;\le\; \sum_{k=0}^{N-1} 2\arccos \mathrm{BC}\big(p^{(k)}, p^{(k+1)}\big).$$
This is the smooth theorem with the calculus removed, and it applies to a Markov chain's trajectory, to the iterates of an optimization algorithm, to any sequence of distributions whatsoever. There is no derivative, no positivity requirement, no interval — only the sequence.

## Two systems, one Pythagorean theorem

One last structural fact rounds out the picture. Suppose two *independent* systems evolve simultaneously, so the joint distribution is the product $p \otimes q$ and the joint velocity is $v \otimes q + p \otimes w$. Then the squared Fisher–Rao speeds simply add:
$$\|v \otimes q + p \otimes w\|_{p\otimes q}^2 \;=\; \|v\|_p^2 + \|w\|_q^2.$$
Fisher–Rao geometry is Pythagorean under products. The reason the cross term vanishes is charming: expanding the square produces a term proportional to $\left(\sum_i v_i\right)\left(\sum_j w_j\right)$, and any velocity vector of a curve *inside the simplex* has total mass zero — probability is conserved, so what one coordinate gains another must lose. Independence and the normalization constraint conspire to give exact orthogonality.

## Why this matters

The chain of inequalities has real teeth.

**Sample complexity.** Fisher–Rao length is, up to constants, the number of samples' worth of distinguishability separating two distributions. The theorem says that if your model can move only a short Fisher–Rao distance, then no statistical test — no event $S$ at all — can distinguish the endpoints by much: the probability of any event changes by at most $L/2$. Concretely, if a training procedure moves a model a Fisher–Rao distance of $0.1$, then every single yes/no prediction it makes shifts in probability by at most $0.05$.

**Optimization on the simplex.** Natural gradient descent, mirror descent with the entropic mirror map, and replicator dynamics all move through the simplex along curves whose natural length is Fisher–Rao. The bound converts a bound on the *work done* by such an algorithm into a bound on how much its output distribution can actually change — a stability guarantee that does not depend on the algorithm's internals.

**Markov chains and mixing.** Total variation is the standard currency of mixing times. The discrete form gives a route to bounding total variation displacement by an accumulation of local overlap deficits, one step at a time, without any continuity assumption.

**Physics.** The square-root embedding is precisely the map from classical probability distributions to (real, positive) quantum state vectors, and Fisher–Rao length is the Fubini–Study length restricted to that slice. The chord bound $\|\sqrt{p(b)} - \sqrt{p(a)}\|_2 \le L/2$ is a classical shadow of the quantum speed limit: how fast a state can move is controlled by how much "energy" the evolution expends.

## The moral

Two ways of measuring the distance between beliefs — one flat and operational, one curved and intrinsic — are related by a single, sharp inequality, and the whole of it comes from Cauchy–Schwarz plus the fact that probabilities sum to one. The curved geometry always dominates the flat one; equality is never attained except trivially, yet the constant cannot be improved; and beneath the whole story sits a sphere, onto which the simplex maps by taking square roots, converting information geometry into the geometry every schoolchild learns.

That the road from $p$ to $q$ is never shorter than the straight line between them is a triviality. That the *right* notion of "straight line" in statistics is an arc on a sphere, and that the crude $L^1$ answer is always the smaller of the two — that is the content of the theorem, and the reason it keeps reappearing wherever probability distributions are set in motion.
