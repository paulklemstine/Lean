# The Silver Ratio Hidden in the Tree of Right Triangles

## A famous tree, and a question nobody had answered

Every schoolchild meets $3^2 + 4^2 = 5^2$. Fewer meet the astonishing fact that *every*
primitive Pythagorean triple — every triple $(a,b,c)$ of positive integers with
$a^2+b^2=c^2$ and no common factor — sits at a unique spot in a single infinite ternary
tree, rooted at $(3,4,5)$.

The tree was described by Berggren in 1934. From a triple you produce three children by
multiplying the column vector $(a,b,c)$ by three fixed integer matrices. In the coordinates
mathematicians actually prefer, the picture is even cleaner. Euclid's two-thousand-year-old
parametrisation says that every primitive triple comes from a pair of integers $(m,n)$ with
$m > n > 0$, $\gcd(m,n)=1$, and $m \not\equiv n \pmod 2$ — call such a pair a *seed* — via
$$a = m^2 - n^2, \qquad b = 2mn, \qquad c = m^2 + n^2 .$$
In seed coordinates Berggren's three matrices become three strikingly simple maps:
$$B_1(m,n) = (2m-n,\; m), \qquad B_2(m,n) = (2m+n,\; m), \qquad B_3(m,n) = (m+2n,\; n).$$
Start from the root seed $(2,1)$, which is the triple $(3,4,5)$, apply these three maps in
all possible ways, and you generate every primitive triple exactly once. The tree is
*complete* (nothing is missed) and *irredundant* (nothing appears twice).

So the tree has two natural notions of "how far out" a triple is.

The **combinatorial** one is the *depth*: the number of moves needed to reach the triple
from $(3,4,5)$. This is the length of the recipe, the number of letters in the word over the
alphabet $\{B_1,B_2,B_3\}$ that produces it.

The **geometric** one is subtler and, it turns out, far more informative. Send each seed
$(m,n)$ to the point
$$z(m,n) \;=\; \frac{n+i}{m}$$
in the hyperbolic upper half-plane — the classical model of non-Euclidean geometry whose
points are complex numbers with positive imaginary part and whose "straight lines" are
vertical rays and semicircles meeting the real axis at right angles. Take the base point to
be $i$, the centre of everything. Then each Pythagorean triple has a **hyperbolic
distance** $d(i, z(m,n))$ from the origin of the hyperbolic world.

Here is the question. *How do these two measures of size compare?* If a triple takes $k$
moves to build, how far out in hyperbolic space can it be?

The answer, it turns out, is governed by the **silver ratio**
$$\lambda \;=\; 1+\sqrt2 \;=\; 2.41421\ldots,$$
the less famous cousin of the golden ratio, and the answer is exact.

---

## Warm-up: the distance is just $\log m$

The first surprise is how simple the hyperbolic distance is. In the upper half-plane the
distance from $i$ to a point $z = x+iy$ satisfies
$$\cosh d(i,z) \;=\; \frac{x^2+y^2+1}{2y}.$$
Plugging in $z(m,n) = (n+i)/m$, so $x = n/m$ and $y=1/m$, everything collapses:
$$\boxed{\;\cosh d\bigl(i, z(m,n)\bigr) \;=\; \frac{m^2+n^2+1}{2m} \;=\; \frac{c+1}{2m}.\;}$$
The hyperbolic position of a Pythagorean triple is an exact, elementary function of its
seed. No approximation, no error term.

From this identity one reads off a strikingly clean statement, which is the first main
result of this work.

> **The logarithmic window theorem.** For every seed $(m,n)$ with $0 < n < m$,
> $$\log m \;\le\; d\bigl(i, z(m,n)\bigr) \;\le\; \log m + \log 2 .$$

In words: *the hyperbolic distance of a Pythagorean triple is the logarithm of the first
Euclid parameter, to within $\log 2 = 0.693\ldots$*. Both ends are sharp: the lower bound is
approached when $n/m \to 0$ (long thin triangles) and the upper bound when $n/m \to 1$
(nearly isoceles ones). The proof is a two-line squeeze on the $\cosh$ identity: since
$m^2 \le c$ we get $d \ge \tfrac12\log c \ge \log m$, and since $2(c+1) \le 4m^2$ for a seed
we get $d \le \tfrac12\log\bigl(2(c+1)\bigr) \le \log m + \log 2$.

Why does this matter? Because the previous natural coordinate, $\tfrac12 \log c$, is
*quadratic* in the seed, whereas $\log m$ is *linear* — and the Berggren moves act on
$(m,n)$ linearly. The whole growth problem becomes a question about linear maps.

---

## The silver potential

How fast can $m$ grow under one Berggren move? The naive answer is "at most a factor $3$":
$B_2$ sends $m \mapsto 2m+n < 3m$, and $B_3$ sends $m \mapsto m+2n < 3m$. Iterating gives
$m \le 2\cdot 3^k$ at depth $k$, and hence $d \lesssim k\log 3$. That was the state of the
art, and it is not sharp — the constant $\log 3 = 1.0986\ldots$ is never attained.

The trick that gets the true constant is to stop measuring the node by $m$ and start
measuring it by a cleverly weighted combination. Define the **silver potential**
$$\Phi(m,n) \;=\; m + (\sqrt2-1)\,n .$$
This is not pulled out of a hat: the linear map $B_2$ has matrix $\begin{pmatrix}2&1\\1&0\end{pmatrix}$,
whose eigenvalues are $1\pm\sqrt2$, and $\Phi$ is precisely the positive left eigenvector
belonging to the dominant eigenvalue $\lambda = 1+\sqrt 2$. Now compute:

- $\Phi(B_2(m,n)) = (2m+n) + (\sqrt2-1)m = (1+\sqrt2)m + n = \lambda\,\Phi(m,n)$ — **exactly**.
- $\Phi(B_1(m,n)) = (2m-n) + (\sqrt2-1)m = \lambda m - n \le \lambda\,\Phi(m,n)$, losing $2n$.
- $\Phi(B_3(m,n)) = m + (1+\sqrt2)n \le \lambda m + n = \lambda\,\Phi(m,n)$, and this last
  inequality is $\sqrt2\,n \le \sqrt2\,m$, i.e. exactly the defining seed condition $n<m$.

So the potential is multiplied by *at most* $\lambda$ by every move, and by *exactly*
$\lambda$ by the middle move. Since $\Phi$ at the root $(2,1)$ equals $2 + (\sqrt2-1) =
1+\sqrt2 = \lambda$, induction gives the **potential bound**: at depth $k$,
$$\Phi \;\le\; \lambda^{k+1}.$$
And because $m \le \Phi$ always, and $\Phi \le \sqrt2\,m$ for a seed, the potential pins
down $m$ from both sides.

Combining with the logarithmic window theorem yields the sharp envelope.

> **The silver envelope theorem.** Every Pythagorean triple at depth $k$ in the Berggren
> tree lies at hyperbolic distance
> $$d \;\le\; (k+1)\log(1+\sqrt2) + \log 2$$
> from the base point.

The constant $\log(1+\sqrt2) = 0.88137\ldots$ replaces the old $\log 3 = 1.09861\ldots$. And
unlike the old one, it cannot be improved.

---

## The Pell spine: where the bound is attained

Which triples grow fastest? The ones that use the middle move every time — since $B_2$ is
the only move that turns the potential inequality into an equality. Starting from $(2,1)$
and applying $B_2$ forever gives the seeds
$$(2,1),\;(5,2),\;(12,5),\;(29,12),\;(70,29),\;(169,70),\;(408,169),\;(985,408),\ldots$$
These are the **Pell numbers**, the solutions of $m^2 - 2n^2 = \pm1$, the $\sqrt2$-analogue
of the Fibonacci sequence. Their triples are $(3,4,5)$, $(21,20,29)$, $(119,120,169)$,
$(697,696,985)$ — the near-isoceles Pythagorean triples, the ones whose legs differ by one.

Along this spine the potential is *exactly* $\lambda^{k+1}$, hence $m \ge \lambda^{k+1}/\sqrt2$,
hence
$$d \;\ge\; (k+1)\log(1+\sqrt2) - \tfrac12\log 2 .$$
Upper and lower bounds now differ by an additive constant of at most $\tfrac32\log 2$, so
dividing by $k$ and letting $k\to\infty$:

> **The silver growth rate.** Along the Pell spine of pure middle moves,
> $$\frac{d(i,z_k)}{k} \;\longrightarrow\; \log(1+\sqrt2) = 0.88137\ldots$$
> and no branch of the tree does better: for every $\varepsilon>0$ there is a depth beyond
> which *every* node of the tree satisfies $d/k \le \log(1+\sqrt2)+\varepsilon$.

The metric growth exponent of the tree of Pythagorean triples is the logarithm of the
silver ratio. It sits strictly between $\log 2 = 0.693\ldots$ and $\log 3 = 1.0986\ldots$,
and in particular the value $\log 3$ — the natural guess, since the tree is ternary — is
attained by **no path at all**. Beyond an explicit depth threshold, every single node of the
tree satisfies $d/k < \log 3$ with a uniform gap.

The numbers bear this out immediately. At depth $8$ the maximum distance over all $6561$
nodes is $7.9324$, attained (as the theory predicts) at the Pell node $(2378,985)$, against
the new bound $8.6255$ and the previously known bound $10.5217$.

---

## The great surprise: two of the three moves are useless

Here is where the story turns. There are three moves; one of them, $B_2$, expands at the
silver rate. What do the other two do?

Take the path that uses $B_3$ every time. From $(2,1)$ it produces $(4,1), (6,1), (8,1),
\ldots$ — at depth $k$ the seed is $(2k+2,1)$, the triple $\bigl((2k+2)^2-1,\,2(2k+2),\,
(2k+2)^2+1\bigr)$. This is the family of triples with a leg one less than the hypotenuse:
$(3,4,5), (15,8,17), (35,12,37), (63,16,65),\ldots$. Its hyperbolic distance is
$\log(2k+2) + O(1)$ — **logarithmic in the depth**. So
$$\frac{d}{k} \;\longrightarrow\; 0 .$$
The same happens along the pure-$B_1$ path, which produces $(3,2),(4,3),(5,4),\ldots$, i.e.
the seeds $(k+2,k+1)$, the triples $(5,12,13),(7,24,25),(9,40,41),\ldots$ whose hypotenuse
exceeds a leg by one. Again $d = \log(k+2)+O(1)$ and $d/k \to 0$.

> **The trichotomy of pure branches.** Of the three one-generator paths in the Berggren
> tree, the middle one has metric rate $\log(1+\sqrt2)$ and the other two have rate $0$.

This is a genuine structural asymmetry, and it had been conjectured otherwise. The natural
guess was that $B_1$, which is *parabolic* — it fixes the boundary slope $n/m = 1$ and
merely creeps towards it — is the unique culprit for the mismatch between combinatorial
depth and geometric distance, and that any path avoiding $B_1$ most of the time must grow at
a definite positive rate. That guess is false in the strongest possible way: the pure-$B_3$
path uses $B_1$ **never**, and still stagnates. For any $\delta>0$ there are arbitrarily deep
$B_1$-free paths whose distance-to-depth ratio is below $\delta$.

What is really going on is that both $B_1$ and $B_3$ *slide along a boundary*. In the slope
coordinate $t=n/m$ the three moves are the Möbius maps $t \mapsto 1/(2-t)$, $t\mapsto 1/(2+t)$
and $t \mapsto t/(1+2t)$. The first has a fixed point at $t=1$ and the third at $t=0$; both
are parabolic, both trap a path in a corner where the seed entries grow only linearly. Only
$B_2$ has a genuinely *hyperbolic* fixed point, at the silver slope $t = \sqrt2-1$, and only
there does the seed grow geometrically.

---

## The clean positive statement

If the frequency of *non-parabolic* moves is the wrong statistic, what is the right one?
The answer is as simple as one could wish: **count the middle moves**.

Every $B_2$ step at least doubles $m$ (since $2m+n > 2m$), while $B_1$ and $B_3$ never
decrease it. So if a word $w$ over $\{B_1,B_2,B_3\}$ contains $\#B_2(w)$ middle letters, the
node it produces has $m \ge 2^{\#B_2(w)+1}$. Together with the envelope theorem:

> **The word sandwich.** For every word $w$ in the three Berggren moves, the node $z_w$ it
> produces from the root satisfies
> $$\bigl(\#B_2(w)+1\bigr)\log 2 \;\le\; d(i,z_w) \;\le\; \bigl(|w|+1\bigr)\log(1+\sqrt2) + \log 2 .$$
> In particular, if a word of length $\ell$ uses the middle move at least an $\alpha$-fraction
> of the time, then $d/\ell \ge \alpha\log 2$.

Left-hand side: middle-move count. Right-hand side: total length. A path travels far in
hyperbolic space **if and only if** it plays the middle move often. The other two moves are
metrically almost free.

---

## What this says about the shortest recipe for a triple

Turn the microscope around. Given a large hypotenuse $N$, how deep in the tree must one dig
to find a triple that big?

From the potential bound, a node at depth $k$ has $m \le \lambda^{k+1}$ and hence hypotenuse
$c = m^2+n^2 \le 2\lambda^{2k+2}$. So a triple of hypotenuse at least $N$ requires
$$k \;\ge\; \frac{\log N - \log 2}{2\log(1+\sqrt2)} - 1 .$$
And the Pell spine attains this: for every $N \ge 1$ there is a Pell node of hypotenuse at
least $N$ at depth at most $(\log N + \log 2)/(2\log(1+\sqrt2))$.

> **The optimal depth law.** The minimal depth at which hypotenuse $N$ first appears in the
> Berggren tree is
> $$\frac{\log N}{2\log(1+\sqrt2)} + O(1) \;=\; 0.5673\ldots \times \log N + O(1),$$
> with both the constant and the error term proved, and the extremal family explicit.

That $0.5673\ldots = 1/(2\log(1+\sqrt2))$ is the sharp constant in the "logarithmic path
length" folklore about the Pythagorean tree. It is the reciprocal of twice the logarithm of
the silver ratio, and it is attained precisely by the near-isoceles triples.

---

## Why the silver ratio?

Because $1+\sqrt2$ is the fundamental unit of $\mathbb{Z}[\sqrt2]$, and the middle Berggren
move is multiplication by it.

Here is the cleanest way to see it. Consider the *slope* $t=n/m$ of a seed, and recall that
under the middle move it transforms as $t \mapsto 1/(2+t)$ — the
Gauss map of the continued fraction $[0;2,2,2,\ldots] = \sqrt2-1$. Its fixed point is the
silver slope, and the derivative there controls the expansion. The Pell numbers, the
near-isoceles triples, the equation $m^2-2n^2=\pm1$, the continued fraction of $\sqrt2$, and
the silver ratio are all the same object viewed from five angles; the theorem above says
that the *hyperbolic geometry* of the Pythagorean tree is a sixth.

There is also a satisfying moral about a much-advertised idea. The Pythagorean tree is
sometimes proposed as a lens on factorisation: if a number $N$ has two different
representations $N = m_1^2+n_1^2 = m_2^2+n_2^2$, then $\gcd(N, m_1m_2+n_1n_2)$ is a nontrivial
divisor of $N$, and both representations appear as nodes of the tree. Because
$d = \tfrac12\log c + O(1)$, both nodes lie at hyperbolic distance only $\tfrac12\log N + O(1)$
from the base point. A *short certificate* exists. The results here explain why this does
not become a fast algorithm: a hyperbolic ball of radius $R$ around $i$ contains on the
order of $e^{2R}$ nodes, so the ball of radius $\tfrac12\log N$ — precisely the radius at
which hypotenuse $N$ first appears — already contains on the order of $N$ candidates. The
certificate is short; the haystack is full-size.

But the *geometry* itself, freed from the algorithmic hope, turns out to be beautifully
rigid. Every primitive Pythagorean triple sits at hyperbolic distance $\log m$ from the
centre, to within $\log 2$; the tree expands at exactly the silver rate; and it does so
along exactly one of its three branches — the one that runs through $(3,4,5), (21,20,29),
(119,120,169), (697,696,985)$, the triangles that are almost, but never quite, isoceles.
