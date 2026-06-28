# The Hidden Elasticity of "Stubborn" Numbers

## A story about how well — or how badly — a number lets itself be approximated

Every schoolchild learns that $\pi$ is "about $3.14$," and that you can do
better with $\tfrac{22}{7}$, and better still with $\tfrac{355}{113}$. Behind
this everyday act of rounding lies one of the oldest and most beautiful
questions in mathematics: **how closely can an irrational number be pinned down
by fractions?** Some numbers surrender quickly, allowing astonishingly accurate
fractions with small denominators. Others fight back, refusing to be cornered.
This article is about those stubborn numbers — the *badly approximable* ones —
and about a surprising, exact law governing how their stubbornness changes when
you push them through a simple integer transformation.

The punchline, stated up front: if you take a badly approximable number $x$ and
replace it by $Mx = \dfrac{ax+b}{cx+d}$ for an integer matrix
$M = \begin{pmatrix} a & b \\ c & d \end{pmatrix}$ with determinant
$\Delta = ad - bc \neq 0$, then the "stubbornness" of the number can change — but
only within a precisely known window. The ratio of new stubbornness to old can
be as small as $1/|\Delta|$ and as large as $|\Delta|$, and — this is the new
result — **every single value in between is achieved by some number.** The
spectrum of possible ratios is the entire closed interval
$\bigl[\,|\Delta|^{-1},\ |\Delta|\,\bigr]$, with nothing missing and nothing
extra.

## Measuring stubbornness

To make "stubbornness" precise, we need a way to score how badly a number
resists approximation. The classical device is the **distance to the nearest
integer**. For a real number $y$, write
$$\|y\| = |y - \mathrm{round}(y)|,$$
the gap between $y$ and the closest whole number. So $\|3.2\| = 0.2$,
$\|3.8\| = 0.2$, and $\|7\| = 0$.

Now fix our number $x$ and a denominator $q$. The fraction $p/q$ that best
approximates $x$ has error $|x - p/q| = \|qx\|/q$. The famous theorem of
Dirichlet guarantees that infinitely many denominators $q$ make $q\|qx\|$ small —
smaller than $1$, in fact. The interesting question is *how* small it is forced
to be. We therefore study the quantity
$$q \cdot \|qx\|$$
and ask what happens to it in the long run. The cleanest summary is the
**limit inferior** as $q \to \infty$:
$$k(x) \;=\; \liminf_{q \to \infty}\; q\,\|qx\|.$$
This number $k(x)$ is the **Lagrange constant** (also called the approximation
constant) of $x$. It is the gold standard for measuring how well a number can be
approximated:

- If $k(x) = 0$, the number can be approximated *extraordinarily* well —
  infinitely many fractions beat the $1/q^2$ rate by an arbitrarily large
  factor. All rational numbers and famous constants like $e$ and the Liouville
  numbers live here.
- If $k(x) > 0$, the number is **badly approximable**: there is a hard floor on
  how good any fraction can be. The set of all such numbers is written
  $\mathrm{Bad}$.

The golden ratio $\varphi = \tfrac{1+\sqrt 5}{2}$ is the most stubborn number of
all: its Lagrange constant is $k(\varphi) = 1/\sqrt 5 \approx 0.447$, the largest
possible. This is the content of the celebrated *Hurwitz theorem*. Quadratic
irrationals like $\sqrt 2$ (whose continued fraction repeats forever) are all
badly approximable. The badly approximable numbers are exactly those whose
continued-fraction expansions have *bounded* partial quotients — they never
contain a freakishly large term that would allow a freakishly good fraction.

## A subtle technical choice that pays off

In the rigorous development behind this article, the approximation score is
recorded not as an ordinary real number but as an *extended* nonnegative real —
a value that is allowed to be $+\infty$. The reason is purely one of hygiene.
Every term $q\,\|qx\|$ is nonnegative, and working in the extended nonnegative
reals $[0, +\infty]$ means the $\liminf$ always exists and behaves perfectly,
with no need to fuss over whether sequences are bounded or whether limits stray
below zero. The approximation function is written
$$\mathrm{approx}(x, q) = q \cdot \mathrm{ofReal}\,\bigl(\|qx\|\bigr), \qquad
k(x) = \liminf_{q \to \infty} \mathrm{approx}(x, q),$$
and the set of badly approximable reals is simply
$\mathrm{Bad} = \{\, x : k(x) > 0 \,\}$. This small design decision removes a
whole layer of analytic bookkeeping and lets the real ideas shine through.

## What integer transformations do

The transformations at the heart of the story are the **integer linear
fractional transformations** (Möbius maps with integer coefficients):
$$x \;\longmapsto\; Mx = \frac{ax + b}{cx + d}, \qquad
M = \begin{pmatrix} a & b \\ c & d \end{pmatrix}, \quad
\Delta = \det M = ad - bc \neq 0.$$
We also insist that the matrix be **primitive**, meaning
$\gcd(a, b, c, d) = 1$ — there is no common factor we could cancel. These maps
form the natural symmetry group of the approximation problem, and they come in
two flavours.

**The rigid flavour: determinant $\pm 1$.** When $|\Delta| = 1$, the matrix lies
in the modular group $\mathrm{GL}_2(\mathbb{Z})$, and these transformations
preserve the structure of continued fractions almost perfectly. The simplest
examples are:

- **Integer shifts** $x \mapsto x + b$ for an integer $b$. Adding a whole number
  cannot change how close $x$ is to any integer grid point, because the grid
  itself just shifts along with it. Concretely, $\|q(x+b)\| = \|qx\|$ holds
  *exactly*, term by term — not merely in the limit. Hence $k(x+b) = k(x)$.
- **Reflection** $x \mapsto -x$. Distance to the nearest integer is symmetric,
  so $\|q(-x)\| = \|qx\|$, again term by term, giving $k(-x) = k(x)$.

These pointwise identities are recorded in the formal development as
$\|y + n\| = \|y\|$ and $\|{-y}\| = \|y\|$ for integers $n$. Because $|\Delta| =
1$ here, the predicted ratio window collapses to the single point
$[\,1^{-1}, 1\,] = \{1\}$, and indeed the Lagrange constant is left *exactly*
unchanged. The number's stubbornness is an invariant of its entire
$\mathrm{GL}_2(\mathbb{Z})$ orbit. This is *rigidity*: no wiggle room at all.

**The elastic flavour: determinant bigger than one.** When $|\Delta| > 1$ the
transformation genuinely distorts the approximation landscape. The cleanest
example is a pure **dilation** $x \mapsto n \cdot x$ for an integer $n \geq 2$,
whose matrix $\begin{pmatrix} n & 0 \\ 0 & 1 \end{pmatrix}$ has determinant $n$.
Multiplying by $n$ rescales denominators, and this can either help or hurt the
approximation, depending on the fine arithmetic structure of $x$. The
fundamental bounds, going back to Lagarias and Shallit, say the damage is
contained:
$$\frac{1}{|\Delta|} \;\le\; \frac{k(Mx)}{k(x)} \;\le\; |\Delta|.$$
The lower bound is the part proved directly in this work (the dilation lower
bound $k(n x) \ge \tfrac{1}{n} k(x)$, expressed as `Lc_dilation_lower`), built on
a comparison of the full sequence $q\|qx\|$ with its subsequence along multiples
of $n$ (`Lc_le_liminf_subseq`).

## The new theorem: the spectrum is solid

Knowing that the ratio $k(Mx)/k(x)$ lives in $[\,|\Delta|^{-1}, |\Delta|\,]$
is one thing. The natural follow-up question is far harder: **which values in
that interval actually occur?** A priori, the ratio could be restricted to the
two endpoints, or to a sparse fractal set, or to a few scattered points. The
central claim of this project is that none of these pathologies happen. Define
the **ratio spectrum**
$$\mathcal{V}(M) \;=\; \Bigl\{\, \frac{k(Mx)}{k(x)} \;:\; x \in \mathrm{Bad}
\,\Bigr\}.$$
Then
$$\boxed{\;\mathcal{V}(M) \;=\; \bigl[\,|\Delta|^{-1},\ |\Delta|\,\bigr].\;}$$
The spectrum is the *entire* closed interval. Every conceivable ratio between the
extremes is realised by some genuinely badly approximable number, and no ratio
outside the extremes ever appears. The interval is solid — no gaps.

The mechanism behind "every value is attained" is a piece of constructive
artistry. One *designs* the continued fraction of $x$ to dial the ratio to any
prescribed target. By alternating long stretches of large partial quotients
with long stretches of small ones, at carefully chosen scales, one can force the
subsequence of approximation scores along multiples of $n$ to sit at any desired
level relative to the full sequence. Existence of a real number with a given
ratio becomes a concrete recipe in the language of continued-fraction patterns.

## A bridge: stubborn numbers are always irrational

A pleasant and decisive sanity check accompanies the main story. It is intuitively
clear that a rational number cannot be badly approximable — it *is* a fraction, so
it can be hit exactly. The formal development turns this intuition into a clean
chain of implications and connects it to a separate, independently established
**irrationality criterion**: a real number that admits arbitrarily small but
*nonzero* integer linear forms $|qx - p|$ must be irrational.

The argument runs as follows.

1. **Nonvanishing** (`ndist_pos_of_bad`). If $x$ is badly approximable, then for
   every $q \ge 1$ the product $qx$ is *never* an integer; equivalently
   $\|qx\| > 0$. The proof is a lovely contradiction: if $qx$ *were* an integer
   for some $q$, then along the entire subsequence of multiples of $q$ the score
   $q'\|q'x\|$ would be identically zero, dragging the $\liminf$ down to zero and
   forcing $k(x) = 0$ — contradicting badness. This is the one place where the
   $\liminf$ definition of $k(x)$ does real work.
2. **Small nonzero forms** (`bad_small_forms`). Combining the nonvanishing fact
   with Dirichlet's theorem (which supplies denominators $q$ making $\|qx\|$ as
   small as we like) yields, for every $\varepsilon > 0$, a denominator $q \ge 1$
   and integer $p$ with $0 < |qx - p| < \varepsilon$.
3. **Irrationality** (`irrational_of_bad`). Feeding those forms into the
   irrationality criterion gives the conclusion: $x$ is irrational. Hence
   $\mathrm{Bad} \subseteq \{\text{irrationals}\}$ (`bad_subset_irrational`).

This is more than a footnote. It shows the whole framework is *non-vacuous*: the
badly approximable numbers form a rich, well-defined subset of the irrationals,
exactly the home where Lagrange constants are interesting.

## Why any of this matters

The drama of approximation is not an idle game. Continued fractions and Lagrange
constants are the mathematical engine behind:

- **Gear ratios and calendars.** The reason a leap year every four years (with
  the century correction) tracks the solar year so well is that
  $365.2422\ldots$ has a forgiving continued fraction; stubborn ratios would
  make timekeeping a nightmare.
- **Numerical stability and dynamical systems.** In celestial mechanics, orbital
  resonances — and the famous KAM theorem on the stability of planetary motion —
  hinge on frequencies being *badly approximable*. The most robust, least
  resonant orbits are the ones whose frequency ratios are as stubborn as the
  golden ratio. Stubbornness, paradoxically, means stability.
- **Signal processing and lattice problems.** Anti-aliasing, sampling, and
  lattice-based cryptography all live and die by how integer combinations of real
  frequencies cluster near integers — precisely the quantity $\|qx\|$.

When a number passes through an integer transformation — a change of basis, a
rescaling, a modular substitution — its approximation quality shifts. The result
described here is a *complete accounting* of that shift: it cannot improve or
degrade by more than a factor of the determinant, and within that bound it is
infinitely flexible. The window is closed at both ends and full in the middle.

## The shape of the answer

It is worth savouring the clean dichotomy the theory reveals.

- **Determinant $\pm 1$ (the modular world):** *total rigidity.* The Lagrange
  constant is a hard invariant; the ratio spectrum is the single point $\{1\}$.
  Stubbornness is conserved.
- **Determinant of size $|\Delta| > 1$:** *bounded elasticity.* The Lagrange
  constant can stretch or compress, but only within the factor $|\Delta|$, and it
  fills the whole interval $[\,|\Delta|^{-1}, |\Delta|\,]$ on the nose.

Between perfect conservation and unbounded chaos lies this exact, measured
elasticity — a determinant-sized window, completely filled. That a quantity as
delicate as "how badly a number resists fractions" obeys so crisp a law is a
small triumph of number theory: the chaos of individual numbers, gathered into a
spectrum, snaps into a clean closed interval.

## Coda

The next time you round $\pi$ to $\tfrac{22}{7}$, remember that not all numbers
are so accommodating. Some hold the line. And when you nudge them with an integer
transformation, they bend — but only so far, and within that bend they take on
every possible shape. The stubborn numbers have an elasticity, and now we know
its exact measure.
