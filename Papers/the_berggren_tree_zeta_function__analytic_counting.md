# Silver Growth, Classical Density

### A guided tour of the Berggren tree and its zeta function

---

## Prologue: three matrices and a right triangle

You know $3^2 + 4^2 = 5^2$. Here is the fact that ought to be as famous.

Take the column vector $(3,4,5)^{T}$ and hit it with any of these three integer matrices:

$$
A_1 = \begin{pmatrix} 1 & -2 & 2\\ 2 & -1 & 2 \\ 2 & -2 & 3\end{pmatrix},\qquad
A_2 = \begin{pmatrix} 1 & 2 & 2\\ 2 & 1 & 2 \\ 2 & 2 & 3\end{pmatrix},\qquad
A_3 = \begin{pmatrix} -1 & 2 & 2\\ -2 & 1 & 2 \\ -2 & 2 & 3\end{pmatrix}.
$$

Out comes another *primitive* Pythagorean triple — legs with no common factor. Repeat forever and
you get an infinite ternary tree with $3^k$ triples at depth $k$. The remarkable part, discovered
by Berggren in 1934 and rediscovered by Barning and Hall in the 1960s, is that this enumeration is
**perfect**: no triple appears twice, and none is ever missed.

<details>
<summary><b>Click to reveal: the coordinate change that makes everything easy</b></summary>

Euclid's parametrisation says every primitive triple with odd first leg is

$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2)$$

for a unique **Euclid seed** $(m,n)$: integers with $0 < n < m$, $\gcd(m,n)=1$, and $m+n$ odd.
Under this change of variables the three matrices become three one-line maps on the seed:

$$s_0(m,n) = (2m-n,\ m), \qquad s_1(m,n) = (2m+n,\ m), \qquad s_2(m,n) = (m+2n,\ n),$$

acting on the root seed $(2,1)$ — which is $(3,4,5)$. That is the whole tree.

Why is nothing repeated? Because the three moves land in **disjoint angular sectors** of the
$(m,n)$ quadrant: $s_0$ produces $m<2n$, $s_1$ produces $2n<m<3n$, and $s_2$ produces $m>3n$
(coprimality forbids the boundaries $m=2n$ and $m=3n$ except at the root). So the ratio $m/n$ of
any node tells you which move made it.

Why is nothing missed? Run the sectors backwards. Each inverse move
— $u_0(m,n)=(n,2n-m)$, $u_1(m,n)=(n,m-2n)$, $u_2(m,n)=(m-2n,n)$ —
gives a valid seed with strictly smaller $m$, so iterating must terminate at $(2,1)$.

That single observation is simultaneously the proof of injectivity and of completeness, and it is
the hinge on which everything below turns: **the tree is a bijective relabelling of a
two-dimensional arithmetic lattice.**

</details>

Play with it. Walk the tree, then type in any seed you like and watch the descent algorithm hand
you back its unique address.

{{interactive_demo:0}}

---

## Act I: the silver ratio, and why you would believe it

Did you notice, in the explorer, how unequal the branches are?

Press $s_1$ over and over and the hypotenuses go
$$5,\ 29,\ 169,\ 985,\ 5741,\ 33461,\ \ldots$$
These are the odd-indexed [Pell numbers](https://en.wikipedia.org/wiki/Pell_number), and they obey
$$c_{k+2} = 6c_{k+1} - c_k,$$
whose characteristic roots $3 \pm 2\sqrt2$ are exactly the eigenvalues of the Barning matrices. The
dominant one,
$$\lambda = 3 + 2\sqrt 2 = (1+\sqrt2)^2 \approx 5.8284,$$
is the square of the [silver ratio](https://en.wikipedia.org/wiki/Silver_ratio)
$\delta_S = 1+\sqrt2$ — the number satisfying $x = 2 + 1/x$, the humbler cousin of the golden ratio.

<details>
<summary><b>Click to reveal: the exact closed form and the speed limit</b></summary>

**Closed form.** With $\lambda' = 3-2\sqrt2 = \lambda^{-1}$,
$$c_k = \frac{(10+7\sqrt2)\lambda^k + (10-7\sqrt2)\lambda'^{\,k}}{4}.$$
Both sides satisfy $x_{k+2}=6x_{k+1}-x_k$ (since $\lambda^2 = 6\lambda - 1$ and likewise for
$\lambda'$) and agree at $k=0,1$, so they agree everywhere. Since $0 < \lambda'^{\,k} \le 1$, one
gets the clean sandwich $4\lambda^k \le c_k \le 6\lambda^k$, hence
$\frac{1}{k}\log c_k \to \log\lambda = 2\log(1+\sqrt2)$.

**Speed limit.** Nothing in the tree outruns this. Attach to each seed the *silver potential*
$$\Phi(m,n) = m + (\sqrt2-1)\,n.$$
Each move multiplies $\Phi$ by at most $1+\sqrt2$, with **equality exactly for $s_1$**: indeed
$$\Phi(2m+n,\,m) = (1+\sqrt2)m + n = (1+\sqrt2)\bigl(m + (\sqrt2-1)n\bigr),$$
using $(1+\sqrt2)(\sqrt2-1)=1$. Since $\Phi(2,1)=1+\sqrt2$ and $m \le \Phi \le$ everything, we get
$$c(w) \;\le\; 2\,\lambda^{\,k+1} \qquad\text{for every node at depth } k.$$

</details>

So we have two exact facts: **$3^k$ nodes per layer**, and **layer maximum $\asymp \lambda^k$**.
Every instinct says to combine them.

The natural analytic object attached to any family of arithmetic objects is a Dirichlet series.
Here it is the **tree zeta function**
$$Z(s) \;=\; \sum_{\text{nodes } w} c(w)^{-s},$$
and the number that summarises it is the **abscissa of convergence**: the threshold below which
the series blows up. Group by layer, bound each layer by its biggest member:
$$Z(s) \;\lesssim\; \sum_{k\ge0} 3^k \bigl(\lambda^k\bigr)^{-s} = \sum_{k\ge0}\bigl(3\lambda^{-s}\bigr)^k,$$
a geometric series convergent exactly when
$$s \;>\; \sigma_{\text{silver}} \;=\; \frac{\log 3}{\log(3+2\sqrt2)} \;=\; 0.62324\ldots$$

Branching over growth. It is the shape of a
[Hausdorff dimension](https://en.wikipedia.org/wiki/Hausdorff_dimension), the shape of the pole of a
[dynamical zeta function](https://en.wikipedia.org/wiki/Ruelle_zeta_function). It is a *beautiful*
prediction.

It is also wrong.

---

## Act II: the laboratory

Turn the dial yourself. Watch the layer majorant declare victory while the series it was supposed
to bound quietly diverges.

{{interactive_demo:1}}

The key to reading that panel is the **increment-ratio diagnostic**, and it is worth explaining
because naive truncation is hopeless here. At $s=1.02$ the tail of the series decays like
$M^{-0.04}$; no cut-off you can afford will make the partial sums look convergent. But the *second*
difference is decisive. Truncating at $m \le M$, the discarded tail behaves like $M^{2-2s}$, so
doubling the cut-off gives increments whose ratio tends to
$$\frac{D(2M)}{D(M)} \;\longrightarrow\; 2^{\,2-2s}.$$
That is $>1$ precisely for $s<1$, exactly $1$ at $s=1$, and $<1$ precisely for $s>1$. In the widget
the observed ratio tracks the theoretical curve to three or four decimals, and the crossing sits
squarely at $\mathbf{1}$.

---

## Act III: the two proofs

**Theorem.** *$Z(s)$ converges if and only if $s > 1$. Its abscissa of convergence is exactly $1$.*

<details>
<summary><b>Click to reveal: convergence above 1 (a two-dimensional majorant)</b></summary>

Because the tree bijects onto the Euclid seeds, the sum over words *is* a sum over the lattice:
$$Z(s) = \sum_{\substack{0<n<m,\ \gcd(m,n)=1 \\ m+n \text{ odd}}} \frac{1}{(m^2+n^2)^s}.$$
Now $m^2+n^2 \ge m^2$, and for each $m$ there are fewer than $m$ admissible values of $n$. Hence
$$Z(s) \;\le\; \sum_{m\ge1} m \cdot m^{-2s} \;=\; \sum_{m \ge 1} m^{1-2s} \;=\; \zeta(2s-1),$$
finite whenever $s>1$. **The three-fold branching never appears.** The convergence is a fact about
the seed lattice, and it was always going to be, because that is what the sum actually ranges over.

</details>

<details>
<summary><b>Click to reveal: divergence at and below 1 (plant primes in the tree)</b></summary>

Let $p$ be an odd prime and let $j$ satisfy $1 \le j$ and $2j < p$. Then the pair $(p, 2j)$ is a
Euclid seed: coprimality is free because $p$ is prime and $0 < 2j < p$; parity is right because $p$
is odd and $2j$ is even. By completeness, each of these sits *somewhere* in the tree. Its
hypotenuse is $p^2+4j^2 \le 2p^2$. There are $(p-1)/2$ admissible $j$, so these nodes alone
contribute
$$\sum_{j=1}^{(p-1)/2} \frac{1}{p^2+4j^2} \;\ge\; \frac{p-1}{2}\cdot\frac1{2p^2} \;\ge\; \frac1{8p}.$$
Summing over odd primes and invoking [Euler's theorem](https://en.wikipedia.org/wiki/Divergence_of_the_sum_of_the_reciprocals_of_the_primes)
that $\sum_p 1/p = \infty$ gives $Z(1) = \infty$. Since every term $c^{-s}$ increases as $s$
decreases, divergence propagates to all $s \le 1$.

</details>

And so the refutation is not merely qualitative but comes with an explicit window:

> **For every $s$ with $0.6233 < s \le 1$, the layer majorant $\sum_k 3^k(2\lambda^{k+1})^{-s}$
> converges while $Z(s)$ diverges.**

---

## Act IV: why the heuristic fails

Here is the picture. Layer by layer, on a logarithmic axis, with the two extremal spines drawn in.

{{visualization:0}}

The fast spine $s_1^k$ races off like $\lambda^k$. The **slow spine** $s_0^k$ has seed $(k+2,k+1)$
and hypotenuse
$$c = (k+2)^2 + (k+1)^2 = 2k^2 + 6k + 5,$$
merely **quadratic**. At depth $12$ the layer maximum exceeds the layer minimum by a factor of
twenty million, and the median sits at a vanishing fraction of the maximum.

Replacing every node in a layer by the largest one is therefore not a mild overestimate — it
discards essentially the entire sum.

<details>
<summary><b>Click to reveal: the entropy diagnosis, and the refined heuristic that would work</b></summary>

Write the layer sum as an expectation over uniform random words:
$$\sum_{|w|=k} c(w)^{-s} \;=\; 3^k\ \mathbb{E}_w\bigl[c(w)^{-s}\bigr].$$
The heuristic replaces $\mathbb E[c^{-s}]$ by $(\max c)^{-s}$. But $\log c(w)$ is essentially an
*additive functional* of the word — each letter contributes a step to $\log\Phi$ — and additive
functionals of i.i.d. letters concentrate around their **mean** per-letter contribution, not their
maximum. Since only $s_1$ achieves the full factor $1+\sqrt2$, the typical word grows strictly
slower than $\lambda^k$. Slower growth means *larger* terms $c^{-s}$, hence a larger sum, hence a
larger abscissa.

The correct refinement is a
[large-deviations](https://en.wikipedia.org/wiki/Large_deviations_theory) analysis. If
$\frac1k\log c(w)$ obeys a large-deviation principle with rate function $I$ on $[0,\log\lambda]$
(the lower endpoint is $0$ because the slow spine is only polynomial), then
$$\frac1k\log\sum_{|w|=k}c(w)^{-s} \;\longrightarrow\; \sup_\alpha\bigl[\log 3 - I(\alpha) - s\alpha\bigr].$$
Since $\alpha=0$ is attainable with $I(0)$ finite, the supremum is bounded below by $\log 3 - I(0)$
*independently of $s$* — which is precisely why the abscissa must be located by the arithmetic of
the seed lattice rather than by the top eigenvalue.

**The general moral.** Growth rates and densities are different animals. A top eigenvalue is a
statement about the fastest branch; a zeta function is a statement about all branches at once,
weighted by how many of them are small. When the branches diverge in speed, so do the two answers.

</details>

---

## Act V: what the abscissa is really saying

An abscissa at $1$ is a statement about counting. Let $N(H)$ be the number of tree nodes with
hypotenuse at most $H$ — equivalently, by completeness, the number of primitive Pythagorean
triples with odd first leg and hypotenuse $\le H$.

**Theorem.** *For all $H \ge 512$,* $\;H/50 \le N(H) \le 2H$, *so* $N(H) = \Theta(H)$.

{{visualization:1}}

<details>
<summary><b>Click to reveal: the elementary sieve behind the lower bound</b></summary>

The upper bound is immediate: $c \le H$ forces $m \le \sqrt H$ and $n < m$.

For the lower bound, work in the triangle $\{1 \le n < m \le M\}$, which has $M(M-1)/2$ pairs.

1. **Throw out pairs with a common factor.** Pairs divisible by $d \ge 2$ inject into the
   $(M/d)$-triangle, so they number at most $\frac{M^2}{2d^2}$. Summing and using the telescoping
   bound $\sum_{d \ge 2} d^{-2} \le \frac{25}{36}$ (from $\frac1{(d+1)^2} \le \frac1d - \frac1{d+1}$)
   costs at most $\frac{25}{72}M^2$. At least $\frac{11}{72}M^2$ coprime pairs survive.

2. **Halve for parity.** A coprime pair is never even–even, so it is odd–odd or opposite-parity.
   The map $(m,n)\mapsto \bigl(\frac{m+n}{2}, \frac{m-n}{2}\bigr)$ injects coprime odd–odd pairs into
   coprime opposite-parity pairs (any common divisor of the images divides their sum $m$ and their
   difference $n$; and their sum $m$ is odd). So at least half survive.

Every survivor with $m \le M$ has $c \le 2M^2$, giving $N(2M^2) \ge \frac{11}{144}M^2 - \frac M4$;
rescaling yields the stated form.

</details>

<details>
<summary><b>Click to reveal: the Tauberian bridge — counting alone forces the divergence</b></summary>

The counting law and the abscissa were proved by disjoint means (a sieve versus the primes). They
can be *joined*, with all constants explicit. Between $H$ and $128H$ the tree acquires at least
$$N(128H) - N(H) \;\ge\; \frac{128H}{50} - 2H \;=\; 0.56\,H$$
new nodes, each of hypotenuse at most $128H$, hence each contributing at least $1/(128H)$ to the
harmonic sum. So each block adds at least $0.56/128 > 1/300$, and iterating,
$$\sum_{c(w)\,\le\, 512 \cdot 128^{k}} \frac{1}{c(w)} \;\ge\; \frac{k}{300}.$$
That is a hard, explicit, logarithmic divergence deduced *purely from the counting statistics* — a
miniature [Tauberian theorem](https://en.wikipedia.org/wiki/Abelian_and_Tauberian_theorems). Its
moral: the abscissa is determined by the counting function alone, so any correct prediction of the
abscissa must correctly predict the growth of $N(H)$. The layer heuristic does not.

</details>

---

## Act VI: the conjectured constant

The proved bounds leave a factor of a hundred. The numerics leave essentially nothing:

| $H$ | $N(H)$ | $N(H)/H$ |
|---|---|---|
| $10^3$ | 158 | 0.1580000 |
| $10^4$ | 1,593 | 0.1593000 |
| $10^5$ | 15,919 | 0.1591900 |
| $10^6$ | 159,139 | 0.1591390 |
| $4\times10^6$ | 636,617 | 0.1591542 |

and $1/(2\pi) = 0.15915494\ldots$

**Conjecture.** $\displaystyle \lim_{H\to\infty}\frac{N(H)}{H} = \frac1{2\pi}$, so that $Z(s)$ has a
simple pole at $s=1$ with residue $1/(2\pi)$.

<details>
<summary><b>Click to reveal: four densities that multiply to 1/(2π)</b></summary>

$N(H)$ counts lattice points $(m,n)$ in the quarter disc $m^2+n^2 \le H$ with $n<m$,
$\gcd(m,n)=1$, $m+n$ odd. Multiply the densities:

| factor | value | source |
|---|---|---|
| quarter-disc area | $\pi H/4$ | the [Gauss circle problem](https://en.wikipedia.org/wiki/Gauss_circle_problem) |
| restriction $n<m$ | $\times \tfrac12$ | symmetry |
| coprimality | $\times \tfrac{6}{\pi^2}$ | $1/\zeta(2)$ |
| opposite parity, given coprime | $\times \tfrac23$ | coprime pairs are never even–even; the three surviving classes are equidistributed |

$$\frac{\pi H}{8}\cdot\frac{6}{\pi^2}\cdot\frac{2}{3} \;=\; \frac{H}{2\pi}.$$

The same answer arrives analytically. Since the tree bijects onto the seed lattice, $Z(s)$ is a
*sieved [Epstein zeta function](https://en.wikipedia.org/wiki/Epstein_zeta_function)* of the form
$m^2+n^2$. The unsieved version is $4\zeta(s)L(s,\chi_4)$, with a simple pole at $s=1$ of residue
$4L(1,\chi_4) = \pi$; the sieve factors $\frac18\cdot\frac{6}{\pi^2}\cdot\frac23 = \frac1{2\pi^2}$
turn $\pi$ into exactly $\frac{1}{2\pi}$.

</details>

---

## Coda: the legs tell the same story, for a different reason

Each node carries two legs as well as a hypotenuse: $a = m^2-n^2$ and $b = 2mn$.

**Theorem.** *Both leg zeta functions $\sum_w a(w)^{-s}$ and $\sum_w b(w)^{-s}$ also have abscissa
exactly $1$.*

<details>
<summary><b>Click to reveal: why this needs a new idea</b></summary>

Divergence below $1$ is free — the legs are smaller than the hypotenuse, so the leg series dominate
the hypotenuse series termwise. But convergence above $1$ **cannot** be inherited, because the legs
are not bounded below by a multiple of $c$: along $s_2^k$ the seed is $(2k+2,1)$, so $b$ is linear
while $c$ is quadratic; along the slow spine the seed is $(k+2,k+1)$, so $a = 2k+3$ is linear while
$c$ is quadratic.

The resolution is *multiplicative*: $b = 2mn \ge m \cdot n$ and $a = (m-n)(m+n) \ge (m-n)\cdot m$.
Each leg dominates a product of two nearly-independent parameters, so
$$a(w)^{-s} \le (m-n)^{-s}m^{-s}, \qquad b(w)^{-s} \le m^{-s}n^{-s},$$
and the double sum $\sum_{u,v\ge1} u^{-s}v^{-s} = \zeta(s)^2$ converges. Two different injective
reindexings of the seed lattice, $(m,n)\mapsto(m,n)$ and $(m,n)\mapsto(m-n,m)$, handle the two
cases.

Notice the subtlety: the even legs have a *different* counting function (roughly $B\log B$ values of
$2mn$ below $B$ across all seeds, reflecting divisor statistics) yet the same abscissa. The abscissa
sees only the polynomial order; the finer asymptotics live in the residue.

</details>

---

## The toolkit

Everything above is computable, and the computations are what make the phenomena visible.

### Enumerating a generation

{{algorithm:0}}

### Counting without the tree

Notice what this one does *not* do: it never touches the tree. Completeness turns the counting
problem into a plain lattice count, and that is the whole reason the branching structure fails to
determine the density.

{{algorithm:1}}

### Finding the break point

{{algorithm:2}}

### The full numerical companion

Every claim on this page, checked end to end.

{{demo:0}}

---

## What to take away

We set out to test whether the silver ratio, which so evidently governs the *geometry* of the
Berggren tree, also governs its *analysis*. It does not.

What survives is everything metric: the speed limit $c \le 2(3+2\sqrt2)^{k+1}$, the exact spine
recurrence $c_{k+2}=6c_{k+1}-c_k$ with its Pell closed form, the growth exponent
$\log\lambda = 2\log(1+\sqrt2)$. All exact, all as true as ever.

What replaces the failed prediction is sharper than what was lost: an exact abscissa of $1$; an
exact order $\Theta(H)$ for the counting function with explicit constants; a Tauberian bridge from
one to the other; matching results for both legs; and a conjectural constant $1/(2\pi)$ with a clean
four-factor derivation and six-digit numerical support.

And there is a portable lesson for anyone who works with self-similar structures — fractals,
branching processes, random walks, dynamical zeta functions, expanders. **A top eigenvalue is a
statement about the fastest branch. A zeta function is a statement about all of them.** When the
branches diverge in speed, so do the two answers.
