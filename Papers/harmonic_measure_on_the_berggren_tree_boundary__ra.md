# Random Walks on the Pythagorean Tree

### A guided tour of the harmonic measure on a Cantor set made of right triangles

---

## 0 · The one picture to keep in your head

Every primitive Pythagorean triple — every $(a,b,c)$ with $a^2+b^2=c^2$ and $\gcd(a,b,c)=1$ —
hangs from a single tree, exactly once, with three branches at every node. Descend that tree
forever, choosing a branch at random each time, and you land somewhere on a Cantor set of
"directions in which right triangles can grow". This page is about the probability
distribution of where you land.

Start by just playing. Move the sliders, take some steps, and watch the numbers.

{{interactive_demo:0}}

Do not worry yet about what every readout means. Three things are worth noticing right away:

1. The **entropy** peaks when the three probabilities are equal, and so does the dimension.
2. The **escape rate** $d/n$ of a random descent settles inside a shaded band, never leaving it.
3. Applying the averaging operator a few times turns any observable into a **flat constant**.

Everything below explains why.

---

## 1 · The tree

<details>
<summary><strong>Background: Euclid's parametrisation (click if it's been a while)</strong></summary>

Every primitive Pythagorean triple is
$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2)$$
for a unique *seed* $(m,n)$ with $m>n>0$, $\gcd(m,n)=1$ and $m\not\equiv n \pmod 2$. The seed
$(2,1)$ gives $(3,4,5)$; the seed $(3,2)$ gives $(5,12,13)$; the seed $(5,2)$ gives
$(21,20,29)$. Working with seeds instead of triples turns a quadratic problem into a linear
one, which is why everything on this page is stated in terms of $(m,n)$.
See [Pythagorean triple](https://en.wikipedia.org/wiki/Pythagorean_triple) for the classical
background.
</details>

**Berggren's theorem.** The set of seeds is a free rooted ternary tree. The root is $(2,1)$,
and the three moves
$$L(m,n) = (2m-n,\ m),\qquad M(m,n)=(2m+n,\ m),\qquad R(m,n)=(m+2n,\ n)$$
generate every other seed exactly once. So a finite word in $\{L,M,R\}$ *is* a name for a
primitive triple, and the naming is a bijection.

This algorithm turns a word into a triple, and confirms the bijection numerically on the
depth-$7$ subtree:

{{algorithm:0}}

Try it: the word $MMMMM$ names the seed $(169,70)$ and hence the near-isosceles triple
$(23661,\,23660,\,33461)$. Pure-$M$ words give the
[Pell numbers](https://en.wikipedia.org/wiki/Pell_number) and the near-isosceles triples;
we will meet them again as the fastest-escaping path in the tree.

---

## 2 · The boundary is a Cantor set

Descend forever and you get an infinite word $x = x_1x_2x_3\cdots \in \{L,M,R\}^{\mathbb N}$.
Declare two ends close when they share a long prefix — concretely, at distance $3^{-n}$ if
they first differ at position $n$. The resulting space is the **boundary** of the tree.

> **Theorem.** The boundary is nonempty, compact, metrizable, totally disconnected, and has
> no isolated points. Its basic neighbourhoods — the *cylinders* $\mathrm{cyl}_n(x)$ of all
> ends passing through a fixed depth-$n$ node — are simultaneously open and closed, and each
> contains at least two distinct ends.

<details>
<summary><strong>Why no isolated points, and why that matters</strong></summary>

Given an end $x$, change only its $k$-th letter to get $x^{(k)} \ne x$. As $k\to\infty$ the
points $x^{(k)}$ agree with $x$ on longer and longer prefixes, so $x^{(k)}\to x$. Hence no end
is isolated: every subtree branches forever. Combined with compactness, metrizability and
total disconnectedness, [Brouwer's characterisation](https://en.wikipedia.org/wiki/Cantor_set)
says the boundary is homeomorphic to the middle-thirds Cantor set. Structured dust.
</details>

---

## 3 · The harmonic measure

Now randomise. At each node take $L$ with probability $p_L$, $M$ with $p_M$, $R$ with $p_R$,
independently forever. The walk converges to a boundary point; the law of that limit is the
**harmonic measure** $\nu$. It is characterised by being reproduced by one step of the walk:
$$\nu \;=\; p_L\, L_*\nu \;+\; p_M\, M_*\nu \;+\; p_R\, R_*\nu,$$
where $L_*,M_*,R_*$ push forward along "prepend this letter".

> **Main Theorem.** For every strictly positive $(p_L,p_M,p_R)$ this equation has exactly one
> probability solution, and it is the Bernoulli product measure:
> $$\nu\bigl(\mathrm{cyl}_n(w)\bigr) = p_{w_1}p_{w_2}\cdots p_{w_n}.$$
> When the three moves are equally likely, this is $3^{-n}$: the fair walk lands with the
> natural Cantor measure of the boundary.

<details>
<summary><strong>Click to reveal the proof — it is only two moves</strong></summary>

**Step 1 (cylinders determine a measure).** Two cylinders are nested or disjoint, because two
nodes of a tree are comparable or incomparable; so the cylinders form a $\pi$-system. They
also generate all measurable sets, since the event "the $i$-th letter is $a$" is a finite
union of cylinders. By Dynkin's $\pi$–$\lambda$ theorem, a probability measure on the boundary
is determined by its cylinder masses.

**Step 2 (a one-line recursion).** Pull back the depth-$(n{+}1)$ cylinder through $v$ along
"prepend $a$". If $a\ne v_1$ you get the empty set; if $a=v_1$ you get the depth-$n$ cylinder
through the shifted word. So harmonicity says
$$\nu(\mathrm{cyl}_{n+1}(v)) = p_{v_1}\,\nu(\mathrm{cyl}_n(\sigma v)),$$
and by induction the only solution is the product $\prod_{i\le n}p_{v_i}$. Checking that the
product measure does satisfy the equation is the same computation read backwards. $\blacksquare$
</details>

Here is the measure as a picture: the boundary drawn as an interval, subdivided at each depth
into the $3^n$ cylinders, each with **width equal to its harmonic mass**.

{{visualization:0}}

For the fair walk (left panel) all blocks at a level are equal. Bias the dice (right panel) and
the mass stampedes into an ever thinner sliver — this is a *dimension drop*, quantified next.

---

## 4 · Entropy, exactly

The natural way to measure how spread-out the harmonic measure is is Shannon entropy
$$H(p) = -p_L\log p_L - p_M\log p_M - p_R\log p_R,$$
the average information gained from one branch choice. Two theorems, one exact and one
almost-sure:

> **Exact identity.** Summing over all $3^n$ nodes at depth $n$, weighted by harmonic mass,
> the average information content of a depth-$n$ node is *exactly*
> $$\sum_{|w|=n}\nu[w]\,\bigl(-\log\nu[w]\bigr) = n\,H(p).$$
> No error term, at any finite depth.

> **Pointwise version.** For almost every single ray $x$,
> $-\frac1n\log \nu(\mathrm{cyl}_n(x)) \to H(p)$. Dividing by $\log 3$ gives the **dimension**
> $$\dim\nu = \frac{H(p)}{\log 3} \le 1,$$
> with equality exactly for the fair walk.

<details>
<summary><strong>Click for the proofs</strong></summary>

*Exact identity.* Since $\nu[w]=\prod_i p_{w_i}$, the surprisal $-\log\nu[w]$ is the sum
$\sum_i \iota(w_i)$ with $\iota(a)=-\log p_a$. Exchange the two summations. For a fixed
position $i$, factor the sum over $w_i$ against the sum over the remaining coordinates; the
latter is $1$, leaving $\sum_a p_a\iota(a) = H(p)$. There are $n$ positions.

*Pointwise version.* Under the product measure the letters are i.i.d., so this is Kolmogorov's
strong law applied to the observable $\iota$ — the
[Shannon–McMillan–Breiman theorem](https://en.wikipedia.org/wiki/Asymptotic_equipartition_property)
in its simplest incarnation.

*Bound and rigidity.* Apply $\log t\le t-1$, strict unless $t=1$, with $t=1/(3p_a)$; sum over
$a$. That is Gibbs' inequality, and strictness whenever some $p_a\ne1/3$.
</details>

This algorithm compares the brute-force sum over all $3^n$ nodes against the closed form
$nH(p)$ — they agree to machine precision at every depth — and then tracks the pointwise
convergence along one sampled ray:

{{algorithm:1}}

You can watch the whole simplex of possible dice at once: hover to read off the entropy and
both dimensions of the corresponding harmonic measure.

{{interactive_demo:1}}

Notice the second dimension column. It never gets past $0.6232$. That is the subject of §7.

---

## 5 · A single ray remembers the dice

All the harmonic measures have *full support*: every node of the tree, however deep, has
positive mass under every walk. And yet distinct walks are as different as measures can be.

> **Ray rigidity.** For two weight vectors the following are equivalent: the vectors are
> equal; some single boundary ray is typical for both; the harmonic measures are equal; the
> harmonic measures are *not* mutually singular.

There is no middle ground: two Berggren walks are either identical or mutually singular. The
separating statistic is embarrassingly simple — count letters:
$$\rho_a(x) = \limsup_{n\to\infty}\frac{\#\{i<n:\ x_i=a\}}{n} \;=\; p_a \quad\text{for a.e. } x.$$

Go back to the explorer above, hold down "take 10 steps", and watch the empirical frequency
row converge to the slider values. That convergence *is* the proof of mutual singularity: the
set of rays with frequencies $(p_L,p_M,p_R)$ carries all of one measure and none of the other.

<details>
<summary><strong>How fast? The Chernoff/Bhattacharyya window</strong></summary>

*Upper side.* The letter counts satisfy a Chernoff bound at the binary relative entropy rate:
$\Pr[\#\{i<n:x_i=a\}\ge nu] \le e^{-n\,\mathrm{KL}(u\|p_a)}$. Consequently, for two distinct
walks there is $c>0$ and a depth-$n$ test that is right with probability $1-e^{-cn}$ under one
and wrong with probability $\le e^{-cn}$ under the other. Total-variation separation at depth
$n$ tends to $1$.

*Lower side.* Let $\beta=\sum_a\sqrt{p_aq_a}$ be the Bhattacharyya coefficient, which is $<1$
exactly when the walks differ. Then for **every** event $A$ of the first $n$ letters,
$$\nu_P(A)+\nu_Q(A^c)\;\ge\;\tfrac12\beta^{2n}.$$
So no depth-$n$ test can beat the exponent $-2\log\beta$. The proof is Cauchy–Schwarz on the
overlap mass $\sum_w \min(m_P,m_Q)(w)$ together with the coordinatewise factorisation
$\sum_w\sqrt{m_Pm_Q} = \beta^n$.
</details>

The third panel of the explorer draws exactly this window: the Chernoff guarantee above, the
universal floor below, and the true cutoff rate somewhere between. The following algorithm
computes both endpoints, optimising the test threshold by golden-section search:

{{algorithm:2}}

---

## 6 · How fast does the walk run away?

The tree also has a *geometry*. Send the seed $(m,n)$ to the point $z(m,n)=(n+i)/m$ of the
hyperbolic upper half-plane, with base point $i$. Then the hyperbolic distance is
$$\cosh d\bigl(i, z(m,n)\bigr) = 1 + \frac{n^2+(m-1)^2}{2m},$$
and it equals $\log m$ to within $\log 2$: distance is the logarithm of the first Euclid
coordinate.

The growth of $m$ is governed not by the branching number $3$ but by the **silver ratio**
$1+\sqrt2$, through the potential $\Phi(m,n)=m+(\sqrt2-1)n$:
$$\Phi(L\cdot v),\ \Phi(R\cdot v)\ <\ (1+\sqrt2)\Phi(v), \qquad \Phi(M\cdot v) = (1+\sqrt2)\Phi(v).$$
The middle move, and only the middle move, saturates the growth. That yields the sharp
envelope, in terms of the labelling word $w$,
$$(\#M(w)+1)\log 2 \;\le\; d\bigl(i, z(w)\bigr) \;\le\; (|w|+1)\log(1+\sqrt2) + \log 2,$$
and, averaging (the expected number of middle moves in $n$ steps is exactly $np_M$),

> **Drift sandwich.**
> $$p_M\log 2 \;\le\; \frac{\mathbb E\,d(i,z_n)}{n} \;\le\; \log(1+\sqrt2) + \frac{\log(1+\sqrt2)+\log2}{n},$$
> and the same two-sided bound holds almost surely along a typical ray. In particular
> $d(i,z_n)\to\infty$ almost surely: the harmonic measure really does live at infinity.

{{visualization:1}}

The left panel embeds the tree in the upper half-plane with node area proportional to harmonic
mass; the highlighted red path is the pure-$M$ Pell spine. The right panel shows the measured
escape rate inside its proved band, with the spine approaching the silver exponent
$\log(1+\sqrt2)=0.8814$ from above — the upper bound is sharp.

This algorithm certifies the potential inequality exhaustively on a depth-$8$ subtree and then
measures the drift by Monte Carlo, checking the sandwich at each depth:

{{algorithm:3}}

---

## 7 · Two things that turned out to be false

The original expectation was that the silver ratio, being *the* growth constant of this tree,
would govern everything about the walk — including its **spectral gap**, the number
controlling how fast the walk forgets. It does not, and the reason is almost embarrassing.

The averaging operator is
$$(\mathcal Lf)(x) = p_L f(Lx) + p_M f(Mx) + p_R f(Rx).$$
If $f$ depends only on the first $n+1$ letters of a ray, then $\mathcal Lf$ depends only on
the first $n$: **the operator forgets exactly one letter per application**. Iterate $n$ times
and $\mathcal L^n f$ is *constant*.

> **Theorem.** On locally constant observables, $\mathcal L$ is nilpotent modulo constants.
> Its only eigenvalues are $0$ and $1$; the eigenvalue $1$ belongs to the constants alone; and
> the spectral gap is $1$, independently of the weights. In particular
> $\log(1+\sqrt2)=0.8814\ldots\in(0,1)$ is *not* an eigenvalue.

The fourth panel of the explorer animates this: press "apply the averaging operator once" and
watch a random observable flatten, one letter of memory at a time, until the spread is exactly
zero.

The second false expectation is subtler. The tree carries two exponents: the *combinatorial*
one, $\log 3 = 1.0986$, and the *metric* one of the hyperbolic embedding,
$2\log(1+\sqrt2) = \log(3+2\sqrt2) = 1.7627$. They are different, and the metric one is larger.

> **Uniform dimension gap.** $\log 3 < 2\log(1+\sqrt2)$, hence the hyperbolic dimension of the
> harmonic measure,
> $$\dim_{\mathrm{hyp}}\nu = \frac{H(p)}{2\log(1+\sqrt2)},$$
> satisfies $\dim_{\mathrm{hyp}}\nu \le \log 3/(2\log(1+\sqrt2)) = 0.6232\ldots \le 2/3$ for
> **every** weight vector. The harmonic measure is never the conformal measure of the
> hyperbolic embedding.

<details>
<summary><strong>The one-line reason, and the explicit constant $2/3$</strong></summary>

$(1+\sqrt2)^2 = 3+2\sqrt2 > 3$, so $2\log(1+\sqrt2) = \log(3+2\sqrt2) > \log 3$. Combining with
$H(p)\le\log3$ gives the bound. For the clean numeral: $\dim_{\mathrm{hyp}}\le 2/3$ is
equivalent to $3\log3\le4\log(1+\sqrt2)$, i.e. to $27 \le (1+\sqrt2)^4 = 17+12\sqrt2 = 33.97$.
</details>

The tree branches three ways but stretches by $1+\sqrt2$ per unit depth, and three is simply
not enough to catch up.

---

## 8 · Run everything yourself

The following self-contained program reproduces every claim on this page numerically: the
tree enumeration, the harmonicity check, the exact entropy identity, the pointwise dimension,
the frequency reconstruction, the separation bracket, the drift sandwich, the nilpotency of
the averaging operator, and the entropy–metric gap.

{{demo:0}}

---

## 9 · Where this leaves us

| Object | Value |
|---|---|
| Boundary | Cantor set $\{L,M,R\}^{\mathbb N}$, 3-adic topology |
| Harmonic measure | Unique; the Bernoulli product measure |
| Entropy | $H(p)$ exactly, at every finite depth and almost surely |
| Dimension (3-adic) | $H(p)/\log 3\in(0,1]$; $=1$ iff fair |
| Dimension (hyperbolic) | $H(p)/(2\log(1+\sqrt2)) \le 0.6232\ldots\le 2/3$ |
| Shift | Ergodic for every walk; measures pairwise singular |
| Drift | between $p_M\log2$ and $\log(1+\sqrt2)$, in mean and a.s. |
| Spectral gap | $1$, for every walk |
| Separation rate | bracketed by the Chernoff and Bhattacharyya exponents |

Three constants, three roles: $\log 3$ for information, $\log(1+\sqrt2)$ for distance, and $1$
for the spectral gap. The instinct that one growth constant should govern everything is, for
this tree, simply wrong — and knowing exactly *how* wrong is the point.

Further reading on the general theory this fits into:
[random walks on groups and their boundaries](https://en.wikipedia.org/wiki/Random_walk),
[harmonic measure](https://en.wikipedia.org/wiki/Harmonic_measure),
[Hausdorff dimension](https://en.wikipedia.org/wiki/Hausdorff_dimension), and the
[silver ratio](https://en.wikipedia.org/wiki/Silver_ratio).
