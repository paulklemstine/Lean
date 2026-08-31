# The Shape of the Primes

### A guided tour of the persistent homology of the prime point cloud

---

## 0. The question

Take the primes $2, 3, 5, 7, 11, 13, \dots$ and forget, for a moment, that they are numbers. Put a
dot on the real line at each of them. What you now have is a **point cloud** — exactly the kind of
object a topologist knows how to interrogate.

The tool of choice is [persistent homology](https://en.wikipedia.org/wiki/Persistent_homology).
Inflate every point into a ball, let the balls grow, and watch the shape that emerges: clusters
merge, loops form and get filled. Every feature is *born* at some scale and *dies* at another, and
its lifetime is drawn as a bar. The collection of bars — the **barcode** — is a portrait of the
data across all scales at once.

So: **what is the barcode of the primes?** By the end of this page you will have computed it
yourself, discovered why the obvious statistical guess about it is impossible, and seen the twin
prime conjecture appear as an unbounded Betti number.

<details>
<summary>Prerequisites — the Vietoris–Rips complex in one minute</summary>

Fix a scale $\varepsilon > 0$. The **Vietoris–Rips complex** $\mathrm{R}_\varepsilon(X)$ of a finite
metric space $X$ has:

* the points of $X$ as vertices,
* an edge between any two points at distance $\le \varepsilon$,
* a filled triangle whenever all three of its sides are edges,
* and so on: a $k$-simplex for every $(k+1)$-subset of diameter $\le \varepsilon$.

Growing $\varepsilon$ only adds cells, so $\{\mathrm{R}_\varepsilon(X)\}_\varepsilon$ is a nested
family — a *filtration*. Its degree-zero homology counts **connected components**; its degree-one
homology counts **holes** (loops that are not filled in). Persistent homology tracks how those
counts change with $\varepsilon$, and records each feature as an interval.

Two numbers will occupy us throughout: $b_0(\varepsilon, n)$, the number of components of the
complex on the first $n+1$ primes at scale $\varepsilon$; and the dimension of the first homology,
which — spoiler — is always zero here. See also
[Vietoris–Rips complex](https://en.wikipedia.org/wiki/Vietoris%E2%80%93Rips_complex).
</details>

---

## 1. First: the primes have no holes. Discover it yourself.

Before computing anything about the primes, let us settle what *cannot* happen. Drag the points in
the sandbox below. Edges appear between points closer than $\varepsilon$; triangles fill in when all
three sides are present; and the live counter reports the number of independent holes.

Start from the square. You will find a hole: four edges, no triangles, $\dim H_1 = 1$. Now press
**Snap to a line** and try to make a hole again. You cannot — and no amount of dragging along the
line or tuning $\varepsilon$ will help.

{{interactive_demo:1}}

That experiment is a theorem.

> **Theorem (Vanishing of first homology on a line).** For *any* point cloud on the real line and
> *any* scale $\varepsilon$, the first homology of its Vietoris–Rips complex vanishes. The prime
> point cloud has no degree-one bars at all.

<details>
<summary>Click to reveal the proof — the umbrella argument</summary>

Work modulo $2$, so a $1$-chain is just a set of edges and addition is symmetric difference. Let
$E$ be a nonempty cycle: every vertex meets an even number of its edges. Let $M$ be its
**rightmost** vertex. Since $\deg_E(M)$ is even and positive, there are two distinct edges
$(u, M)$ and $(w, M)$ in $E$, with $u, w$ both to the left of $M$.

Both $u$ and $w$ lie in the interval $[M - \varepsilon, M]$, which has length $\varepsilon$.
Therefore $|u - w| \le \varepsilon$ too: the triple $\{u, w, M\}$ has diameter $\le \varepsilon$ and
spans a genuine filled triangle $T$. This is the **umbrella property** of a cloud on a line — two
neighbours of a point, both on the same side of it, are neighbours of each other.

Now replace $E$ by $E \mathbin{\triangle} \partial T$. The two edges at $M$ cancel and the single
lower edge $uw$ is toggled. Measuring a chain by $\Phi(E) = \sum_{(a,b) \in E} b$, the sum of upper
endpoints, this step changes $\Phi$ by $\pm w - 2M < 0$. The cycle condition survives, because every
degree of $\partial T$ is even.

$\Phi$ is a nonnegative integer that strictly decreases, so the process terminates at the empty
chain. Unwinding, $E$ was the sum of the triangle boundaries we used: it bounds. Hence there are no
essential cycles, at any $\varepsilon$. $\blacksquare$

**Sharpness.** The square is exactly where the umbrella fails: the two neighbours $1$ and $3$ of the
corner $0$ are at distance $2$ from each other, further than either is from $0$. No triangle appears
and the loop is essential. One dimension is precisely the boundary between a trivial and a
nontrivial first homology.
</details>

**Consequence.** The entire topological content of the primes lives in degree zero. In particular,
the romantic guess that the twin prime conjecture is encoded by some long one-dimensional bar is
impossible. As we will see, it is encoded — but by a Betti *number*, not a bar.

Here is the machinery behind the counter you just used:

{{algorithm:3}}

---

## 2. Degree zero: the barcode is the gap sequence

On a line, degree-zero persistence is completely transparent. Two consecutive primes $p_i$ and
$p_{i+1}$ join at scale $\varepsilon$ exactly when the **gap** $g_i = p_{i+1} - p_i$ is at most
$\varepsilon$; a component is a maximal run of consecutive primes whose internal gaps have all
closed; and the component ending at index $i$ dies precisely at $\varepsilon = g_i$.

So the degree-zero barcode of the primes **is** the sequence of prime gaps:

$$
b_0(\varepsilon, n) \;=\; 1 + \#\{\, i < n : g_i > \varepsilon \,\},
\qquad
\sum_{i<n} g_i \;=\; p_n - 2 .
$$

That last identity — the **total persistence** — is a telescoping sum, and it is one of the rare
places where a topological invariant of the primes has a closed form.

This makes the computation trivial where general persistent homology would be hopeless: a Rips
complex on the $78\,497$ primes below $10^6$ has about $3 \times 10^9$ edges, but its barcode is one
linear scan of differences.

{{algorithm:0}}

And every invariant we will want is an upper-tail count of the same multiset, answerable in
logarithmic time after a single sort:

{{algorithm:1}}

---

## 3. Play with the barcode

Now the main laboratory. The scale slider grows $\varepsilon$; the window slider chooses how many
primes to include. Watch three things simultaneously: the cloud breaking into components, the
Betti staircase $\varepsilon \mapsto b_0(\varepsilon, n)$, and the histogram of bar lengths.

Three experiments worth running:

1. **Slide $\varepsilon$ slowly from $0$ to $6$.** The staircase drops in a jump at $\varepsilon = 1$
   (the single bar from $2$ to $3$), then at $2$, then at $4$, then at $6$ — and *never* in between.
2. **Watch the box "bars shorter than 2".** Push the window all the way to $200\,000$. The number
   stays at $1$. Now compare it with the box next to it, the exponential prediction for the same
   quantity, which climbs into the thousands.
3. **Set $\varepsilon = 2$** and read the twin-bar box: at that scale, the shortfall between the
   number of points and the number of components is exactly the number of twin-prime pairs.

{{interactive_demo:0}}

---

## 4. The primes are not random — and the barcode says so in one line

The standard heuristic — [Cramér's model](https://en.wikipedia.org/wiki/Cram%C3%A9r%27s_random_model)
— treats the primes as a Poisson process of intensity $1/\log x$. Spacings of a Poisson process are
exponentially distributed, so the bar lengths ought to be exponential with mean $\approx \log x$.
Below $10^6$ the empirical mean bar length is $12.74$ against $\log 10^6 = 13.82$: a fit good enough
to be seductive.

It is nevertheless impossible, and the reason takes one line.

> **Theorem (Atomicity).** Every bar of the prime barcode has length $1$ — which happens exactly
> once, for the bar from $2$ to $3$ — or an even length $\ge 2$. The bar-length spectrum is supported
> on the lattice $\{1\} \cup 2\mathbb{N}$.

*Because $2$ is the only even prime.* Every later prime is odd, and the difference of two odd
numbers is even. A lattice has measure zero for any continuous distribution, so no exponential law
can live there.

The failure can be made completely quantitative, in a way no re-tuning of parameters can repair:

> **Theorem (Refutation).** Among the first $n$ bars, the number shorter than $2$ is **exactly one**,
> for every $n \ge 1$. An exponential law of mean $\mu$ predicts $n(1 - e^{-2/\mu})$ such bars, which
> tends to infinity. Hence for every $\mu > 0$ there is an $N$ beyond which the prediction strictly
> exceeds the truth: no exponential law with any mean describes the prime barcode.

<details>
<summary>Click for the two-line proof</summary>

By atomicity, $g_i < 2$ forces $i = 0$; and $g_0 = 1 < 2$. So the count is exactly $1$ for every
$n \ge 1$.

Set $c = 1 - e^{-2/\mu}$. Since $\mu > 0$ we have $-2/\mu < 0$, hence $e^{-2/\mu} < 1$ and $c > 0$.
Choose any $N > 1/c$. Then for $n \ge N$ we have $nc > 1$, i.e. the prediction $nc$ strictly exceeds
the true count $1$. $\blacksquare$

With the empirical mean $\mu = 12.74$, the prediction already exceeds the truth at $n = 7$. At
$n = 78\,497$ it predicts $11\,405$ short bars where there is one.
</details>

Run the audit yourself:

{{algorithm:2}}

**What survives.** The refutation is about the *support* of the barcode measure, not its shape.
Divide each bar by the local mean gap, $g_i / \log p_i$, and the lattice disappears while the shape
is preserved. Whether the rescaled bars are exponential — whether
$\#\{i < n : g_i \le t \log p_i\}/n \to 1 - e^{-t}$ — is the honest form of the conjecture, and it is
**open**. The audit algorithm above computes that statistic too; try it and see how close it already
is.

Here is the whole story in one figure:

{{visualization:0}}

---

## 5. The twin prime conjecture is a Betti number

Now set the scale to exactly $\varepsilon = 2$. At that scale two primes are joined precisely when
they are **twins**. Each twin gap fuses two clusters, so the number of components falls below the
number of points by exactly the number of twin pairs.

> **Theorem (Twin primes as a Betti defect).** For every $n \ge 1$,
> $$b_0(2, n) \;+\; T(n) \;=\; n, \qquad T(n) = \#\{\, i < n : g_i = 2 \,\}.$$
> Equivalently $T(n) = b_0(1, n) - b_0(2, n)$: the twin-prime counting function is a **single Betti
> difference**.

At $10^6$: $70\,328 + 8\,169 = 78\,497$. Exactly.

> **Theorem (Equivalence).** There are infinitely many twin primes **if and only if** the Betti
> defect $n - b_0(2, n)$ of the prime point cloud at scale $2$ is unbounded.

<details>
<summary>Click for the proof of the identity and the equivalence</summary>

*Identity.* Split the indices $i < n$ into those with $g_i > 2$ and the rest. By atomicity, an index
with $g_i \le 2$ is either $i = 0$ (where $g_0 = 1$) or has $g_i$ even, positive and $\le 2$, i.e.
$g_i = 2$. So the complement has $T(n) + 1$ elements and
$\#\{g_i > 2\} + T(n) + 1 = n$. Since $b_0(2,n) = 1 + \#\{g_i > 2\}$, adding $T(n)$ gives $n$.

*Equivalence.* A twin pair $(p, p+2)$ has no prime strictly between its members, so it is a pair of
*consecutive* primes: twin pairs correspond exactly to gaps equal to $2$. If there are infinitely
many such indices then for any $K$ one finds $K$ of them below some $n$, so $T(n) \ge K$ and the
defect $n - b_0(2,n) = T(n)$ exceeds $K$. Conversely, if there are only $C$ such indices then
$T(n) \le C$ for all $n$ and the defect is bounded by $C$. $\blacksquare$
</details>

The same translation captures the deepest theorem we actually possess about small gaps. Writing the
defect at a general scale $B$,

$$(n+1) - b_0(B, n) \;=\; \#\{\, i < n : g_i \le B \,\},$$

the **bounded-gaps theorem** of Zhang, refined by Maynard and Tao, says exactly that the scale-$246$
defect is unbounded; the twin prime conjecture is the case $B = 2$; and conversely an unbounded
scale-$B$ defect forces $\liminf_n (p_{n+1} - p_n) \le B$. The entire small-gaps programme is the
question of how far down the scale axis the "unbounded defect" property extends.

{{visualization:1}}

---

## 6. Two things you would not have guessed

**The cloud never connects.** Surely at a huge scale — say $\varepsilon = 10^{100}$ — the primes all
glue into one blob? No. For every $m$, the numbers $m!+2, \dots, m!+m$ are all composite (each
$m!+k$ is divisible by $k$), so prime-free stretches of any length occur arbitrarily far out. Bars
longer than any fixed $\varepsilon$ therefore occur infinitely often, and

> **Theorem.** For every fixed $\varepsilon$ and every $K$ there is an $n$ with
> $b_0(\varepsilon, n) \ge K$: at every scale, the prime cloud shatters into arbitrarily many
> components.

At every fixed scale the barcode has infinitely many bars below it *and* infinitely many above it.
It never simplifies.

**Nothing is lost, and nothing is fragile.** Two final structural facts:

> **Theorem (Completeness).** For point clouds on a line, two clouds have the same degree-zero
> barcode if and only if they have the same Betti curve. The staircase remembers the whole multiset
> of bars.

> **Theorem (Stability).** If two clouds are within $\delta$ of each other pointwise, their Betti
> curves are $2\delta$-interleaved: $b_0^{\,q}(\varepsilon + 2\delta, n) \le b_0^{\,p}(\varepsilon, n)$.

<details>
<summary>Why completeness matters more than it looks</summary>

The Betti curve is $1$ plus the upper-tail counting function of the bar-length multiset. Suppose two
finite multisets of reals have the same tail counts at every threshold. Evaluating below all
elements shows they have the same size. If their maxima differed, evaluating just below the larger
one would give $0$ on one side and $\ge 1$ on the other. So the maxima agree; strip them off and
induct.

The consequence: any statistical law you propose for the Betti curve is a law for the gaps
themselves, with nothing lost in translation. That is why the atomicity obstruction of Section 4
cannot be dodged by working with the staircase instead of the bars — and why the rescaled Cramér
conjecture can be stated equivalently as a claim about the single explicit staircase
$b_0(t \log x, n)$.

Stability, meanwhile, is the guarantee that everything on this page is about the *spacing* of the
primes, not about accidental features of their exact positions: jiggle every prime by up to $0.4$
and the barcode moves by at most $0.8$ in scale.
</details>

---

## 7. See it all verified

Everything above — atomicity, the constancy at $1$ of the short-bar count, the divergence of the
exponential prediction, the twin identity, the merge identity at scales up to $246$, the telescoping
total persistence and the bound $p_n \ge 2n+1$, even-window rigidity, the interleaving bound, the
factorial composite window, and the vanishing of first homology for prime windows against
$\dim H_1 = 1$ for the square — is checked numerically here:

{{demo:0}}

---

## 8. Where this points

The prime cloud is **topologically rigid but statistically non-Poisson**. Its degree-one homology is
empty and always will be. Its degree-zero barcode is the gap sequence, pinned to the even lattice,
losslessly encoded by a staircase that jumps only at even scales, stable under perturbation, and
never simplifying at any resolution. Its defects at fixed finite scales are exactly the open and the
solved problems of prime gap theory: $\varepsilon = 2$ is the twin prime conjecture, $\varepsilon =
246$ is Maynard–Tao.

The natural next moves are three. Test the **rescaled** Cramér law, $g_i / \log p_i$, where the
lattice obstruction disappears. Push the cloud into higher dimensions via the delay embedding
$n \mapsto (p_n, p_{n+1}, \dots)$, where — unlike on the line — genuine holes should exist, and where
the $\log^2 x$ scale originally guessed for the one-dimensional cloud may finally be the right
answer. And ask whether the topological formulation of small gaps offers any leverage on lowering
the least scale $B$ at which the defect is unbounded, from $246$ towards $2$.

The primes have a shape. Reading it is the same as understanding their gaps — which is to say, we
can now see, in geometric terms, exactly what it is that we do not yet know.
