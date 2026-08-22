# The Golden Cost of Not Looking at the Whole Picture

## A story about products, rectangles, and a constant that refuses to go away

Imagine you are given a grid of light bulbs. Some are on, some are off. Your
job is to shine a beam of light onto the grid so that as much energy as
possible lands on the bulbs that are on — and you must do it with a beam of
fixed total power. If you are free to design the beam pixel by pixel, the
answer is obvious: pour all your power exactly onto the lit bulbs, in equal
shares, and none anywhere else. That is the best possible strategy, and it is
the *only* best possible strategy.

Now add one constraint, the kind of constraint that appears everywhere in
physics, computer science, and machine learning: your beam must be a
**product**. You may choose an intensity profile $f$ across the rows and,
independently, a profile $g$ across the columns, and the light that arrives at
the cell in row $a$ and column $b$ is the product $f(a)g(b)$. You cannot say
"bright here, dark just to the right"; you can only say "bright in this row"
and "dark in that column", and the grid multiplies your two decisions
together.

Suddenly the problem has teeth. A product beam has no way of seeing the
*shape* of the pattern of lit bulbs — only its row profile and its column
profile. If the lit pattern happens to be a perfect rectangle, a product beam
reproduces it exactly and nothing is lost. If the pattern is anything else,
something must be lost.

The question this article is about is: **how much?**

The answer turns out to be a single, beautiful, universal number:

$$\frac{3-\sqrt 5}{2} = 0.381966\ldots$$

This is $2-\varphi$, where $\varphi = (1+\sqrt5)/2$ is the golden ratio; it is
also exactly $1/\varphi^2$. No matter how large the grid, no matter how many
bulbs are lit, no matter how subtly the pattern deviates from a rectangle, a
product beam always leaves at least this much energy on the table — and there
is a tiny three-bulb pattern for which it leaves exactly this much and no more.

---

## Setting the stage precisely

Let $X$ be a finite set of *states*. A **resonance set** is a subset
$R \subseteq X$: the states we care about, the lit bulbs. A **coin** is a
real-valued weight function $\psi : X \to \mathbb{R}$ normalised so that

$$\sum_{x \in X} \psi(x)^2 = 1 .$$

(The name comes from quantum walks, where such a normalised weighting is the
"coin" that decides how amplitude is spread across states.) The quantity we
want to maximise is the **resonance amplitude**

$$A_R(\psi) \;=\; \sum_{x \in R} \psi(x),$$

or rather its square $A_R(\psi)^2$, which is the quantity with physical
meaning: it is the probability weight, up to normalisation, that a measurement
finds the system inside $R$.

Cauchy–Schwarz answers the unconstrained problem immediately:
$A_R(\psi)^2 \le |R|$, with equality precisely when $\psi$ is a constant
multiple of the indicator function of $R$. In fact there is an exact bookkeeping
identity behind the inequality, and it is worth stating because everything
later grows out of it. For any unit coin $\psi$ and nonempty $R$,

$$|R| - A_R(\psi)^2 \;=\; |R| \sum_{x \in X} \Bigl( \psi(x) - \tfrac{A_R(\psi)}{|R|}\,\mathbf 1_R(x) \Bigr)^{\!2}.$$

The **defect** — how far you fall short of the ideal $|R|$ — is exactly $|R|$
times the squared distance from your coin to the best available scalar copy of
the indicator. The inequality is not a black box; it is a Pythagorean theorem
in disguise. Fall short, and the shortfall *measures* your distance from the
indicator.

So the entire question becomes geometric: **how close can a product get to an
indicator function?**

---

## Rectangles, and only rectangles

Take $X = A \times B$, a grid. A product coin is $\psi(a,b) = f(a)g(b)$, with
$\sum_a f(a)^2 = \sum_b g(b)^2 = 1$ (which automatically makes $\psi$ a unit
coin). Call $R \subseteq A \times B$ a **combinatorial box** if it is closed
under the rectangle rule:

> whenever $(a,b) \in R$ and $(a',b') \in R$, also $(a,b') \in R$.

An easy argument shows a set is a box exactly when it is the product
$S \times T$ of its two projections — a solid rectangle of cells, possibly with
its rows and columns scattered around the grid.

The first half of the picture is the easy half.

> **Theorem (boxes are optimal).** If $R \subseteq A \times B$ is a nonempty
> box, $R = S \times T$, then the product coin built from the normalised
> indicators, $f = \mathbf 1_S/\sqrt{|S|}$ and $g = \mathbf 1_T/\sqrt{|T|}$,
> satisfies $A_R(f \otimes g)^2 = |S|\,|T| = |R|$ exactly.

The reason is that a product coin *is* an indicator of a box when its two
factors are indicators: the product of two normalised indicators is precisely
the normalised indicator of the rectangle. Boxes are exactly the patterns a
product beam can draw.

The interesting half is the converse, and it is where the golden ratio enters.

---

## Frobenius geometry and a $2\times 2$ minor

Encode the resonance set as its $0/1$ **indicator matrix** $M$, with
$M_{ab} = 1$ if $(a,b) \in R$ and $0$ otherwise. A product coin $f\otimes g$,
scaled by its own amplitude $t = A_R(f\otimes g)$, becomes the rank-one matrix
$X = t\, f g^{\mathsf T}$. A short computation — the product version of the
defect identity above — gives the clean statement

$$\bigl\| M - t\, f g^{\mathsf T} \bigr\|_F^2 \;=\; |R| - t^2 ,$$

where $\|\cdot\|_F$ is the entrywise Euclidean (Frobenius) norm. The amplitude
defect of a product coin is *exactly* the squared distance from the indicator
matrix to a rank-one matrix. We have converted a question about beams into the
oldest question in low-rank approximation: **how badly can a rank-one matrix
approximate a $0/1$ matrix that is not a rectangle?**

Now, what does "not a box" give us? Exactly one thing: four cells forming a
$2 \times 2$ pattern

$$\begin{pmatrix} M_{ab} & M_{ab'} \\ M_{a'b} & M_{a'b'} \end{pmatrix}
= \begin{pmatrix} 1 & 0 \\ m & 1 \end{pmatrix}, \qquad m \in \{0,1\},$$

because the failure of the rectangle rule hands us $(a,b), (a',b') \in R$ with
$(a,b') \notin R$. This little block has determinant $1$; it is *not* rank one,
and no amount of context around it can hide that fact. Meanwhile the same four
cells of $X$ form a $2\times2$ block of a rank-one matrix, so that block is
singular.

And the total energy $|R| - t^2$ is at least the energy contributed by these
four cells. So everything reduces to a two-dimensional question:

> How far, in squared Frobenius norm, must a **singular** $2\times2$ matrix be
> from $\begin{pmatrix} 1 & 0\\ m & 1\end{pmatrix}$?

Here is the elegant answer. A singular $2\times2$ matrix $X$ kills some unit
vector $n$: $Xn = 0$. Then

$$\|M_{\mathrm{blk}} - X\|_F^2 \;\ge\; \|(M_{\mathrm{blk}} - X)n\|^2 \;=\; \|M_{\mathrm{blk}} n\|^2
\;\ge\; \sigma_{\min}(M_{\mathrm{blk}})^2 .$$

(The first step is just the fact that the operator norm is at most the
Frobenius norm.) This is the two-by-two case of the Eckart–Young theorem, done
by hand. So the loss is at least the squared smallest singular value of the
block, minimised over the two possibilities $m = 0$ and $m = 1$. For $m=0$ the
block is the identity and its smallest singular value is $1$. For $m=1$ the
block is $\begin{pmatrix}1&0\\1&1\end{pmatrix}$, whose singular values squared
are the roots of $\lambda^2 - 3\lambda + 1 = 0$, namely

$$\frac{3+\sqrt5}{2} = \varphi^2 \qquad\text{and}\qquad \frac{3-\sqrt5}{2} = \varphi^{-2}.$$

The golden ratio was hiding in the smallest non-rectangular $0/1$ pattern all
along. We have proved:

> **Theorem (sharp rigidity gap).** If $R \subseteq A \times B$ is not a
> combinatorial box, then every unit product coin satisfies
> $$A_R(f \otimes g)^2 \;\le\; |R| - \frac{3-\sqrt5}{2}.$$

The loss is an *absolute constant*: it does not shrink as the grid grows, as
$|R|$ grows, or as the deviation from a rectangle becomes a vanishingly small
fraction of the pattern. A single misplaced bulb costs you $0.381966\ldots$
units of amplitude-squared, forever.

---

## The smallest counterexample, and why it is sharp

The constant cannot be improved, and the witness is the smallest non-rectangle
there is: the **L-shape**

$$R \;=\; \{(0,0),\,(0,1),\,(1,0)\} \subseteq \{0,1\}\times\{0,1\},
\qquad M = \begin{pmatrix} 1 & 1 \\ 1 & 0\end{pmatrix}.$$

Three cells, arranged in an L. Here $|R| = 3$, and a direct computation gives
the exact best product amplitude. Cauchy–Schwarz in the column variable turns
$\bigl(f_0g_0 + f_0g_1 + f_1g_0\bigr)^2$ into at most the quadratic form
$(f_0+f_1)^2 + f_0^2$ on the unit circle, whose maximum is the largest
eigenvalue of $\begin{pmatrix}2&1\\1&1\end{pmatrix}$ — again
$(3+\sqrt5)/2$. And explicit unit vectors achieve it. Hence the exact optimum
for the L-shape is

$$\max_{f,g} A_R(f\otimes g)^2 \;=\; \frac{3+\sqrt 5}{2} \;=\; \varphi^2 \;=\; 2.618\ldots
\;=\; 3 - \frac{3-\sqrt5}{2},$$

meeting the general bound with equality. Three lit bulbs in an L, and the best
any product beam can do is $\varphi^2$ out of a possible $3$.

The very first bound one can prove by cruder means — expanding the $2\times2$
determinant and applying a four-term Cauchy–Schwarz inequality — gives a loss
of $1/(9|R|)$, which for the L-shape is a mere $1/27 \approx 0.037$. Valid, but
ten times too pessimistic, and worse, it decays as the resonance set grows.
Part of the story here is precisely that a natural-looking $|R|$-dependent
constant is an artefact of the method: the truth is uniform.

---

## Depth: many factors, same constant

Real systems are not two-dimensional. Take $X = D^{\,n+1}$, states described by
$n+1$ coordinates, and let a **depth-$(n+1)$ product coin** be
$\psi(x) = \prod_{i} f_i(x_i)$ — the mean-field ansatz, the separable state,
the fully factorised model. Call $R \subseteq D^{\,n+1}$ a **full box** if it
is the product $\prod_i S_i$ of its $n+1$ coordinate projections.

Two facts complete the picture. The first is purely combinatorial and, once
seen, unsurprising but not quite obvious:

> **Structure theorem.** If, for every coordinate $i$, the set $R$ viewed as a
> subset of $D \times D^{\,n}$ (splitting off coordinate $i$) is a box, then
> $R$ is a full box $\prod_i S_i$.

Its proof is a crossover induction: given any candidate point whose $i$-th
coordinate lies in the $i$-th projection for every $i$, repair the coordinates
of an actual member of $R$ one at a time, staying inside $R$ at every step
because each single-coordinate split is closed under crossover.

The second is a reduction: any depth-$(n+1)$ product coin, read through the
splitting of coordinate $i$ off the rest, is a *two-factor* product coin — one
factor is $f_i$, the other is the depth-$n$ product of the remaining factors,
which is itself a unit coin. So the two-dimensional theorem applies verbatim.
Combining:

> **Theorem (depth-$n$ rigidity gap).** If $R \subseteq D^{\,n+1}$ is not a
> full box, then every depth-$(n+1)$ product coin satisfies
> $$A_R(\psi)^2 \;\le\; |R| - \frac{3-\sqrt5}{2},$$
> a constant independent of the depth $n$, of $|D|$, and of $|R|$.

And the converse holds too: a nonempty full box $\prod_i S_i$ is exactly
matched by the product of the normalised indicators of its factors. So we
obtain a clean **dichotomy**: for a nonempty resonance set in $D^{\,n+1}$,
some depth-$(n+1)$ product coin attains the Cauchy–Schwarz optimum $|R|$
**if and only if** $R$ is a full combinatorial box. Anything else pays the
golden toll.

---

## Why one should care

The pattern "factorised ansatz versus globally correlated target" is one of the
recurring shapes of modern mathematics.

* **Quantum information.** A product coin is a *separable* (unentangled) state;
  a general coin may be entangled. The dichotomy says that unentangled states
  can be perfectly matched to a target subspace exactly when that subspace is a
  product of local subspaces, and the cost of entanglement-free approximation
  is bounded below by a universal constant.

* **Communication complexity.** Combinatorial rectangles are the atoms of
  two-party communication: everything a protocol can certify is a union of
  boxes. The result is a quantitative statement that a single rank-one
  certificate cannot see any non-rectangular structure, and that the blind spot
  has a fixed size.

* **Low-rank and tensor methods.** In matrix and tensor factorisation, rank-one
  fits of binary data are ubiquitous — topic models, biclustering, mean-field
  approximations. The theorem is a hard floor: the moment the binary pattern is
  not a bicluster, the best rank-one fit is off by at least $0.381966\ldots$ in
  squared Frobenius norm, no matter how big the data.

* **The golden ratio, again.** $\varphi$ is famous for showing up in Fibonacci
  numbers and continued fractions. Here it appears for an entirely spectral
  reason: the smallest non-rectangular $0/1$ pattern is the lower-triangular
  all-ones $2\times2$ matrix, and its singular values are governed by
  $\lambda^2 - 3\lambda + 1 = 0$, the "square" of the golden equation
  $x^2 = x+1$. The extremal combinatorics of rectangles and the arithmetic of
  the golden ratio meet in a single $2\times2$ minor.

---

## What is still open

Three questions push directly out of this work.

First, the proof lower-bounds the *total* tail of the singular spectrum. The
numerics suggest something stronger and purely spectral: for every $0/1$ matrix
of rank at least two, the **second** singular value alone satisfies
$\sigma_2^2 \ge (3-\sqrt5)/2$, with equality exactly for matrices whose
non-trivial part is a copy of $\begin{pmatrix}1&0\\1&1\end{pmatrix}$.

Second, what about coins of tensor rank at most $r$ — sums of $r$ products
instead of one? The natural conjecture is that the same golden constant is a
*rank-independent* modulus of rigidity, with the extremal object becoming the
$(r+1)\times(r+1)$ lower-triangular all-ones matrix, whose smallest singular
value is the explicit trigonometric quantity $2\sin\bigl(\pi/(2(2r+3))\bigr)$
— degenerating exactly to the golden constant when $r = 1$.

Third, is there a genuine hierarchy in depth? One expects, for each $n$, a
resonance set in $\{0,1\}^{n+1}$ of size $n+2$ that costs at least the golden
constant to any coin factorising over *two* blocks of coordinates, but which is
matched exactly by a coin factorising over *three*.

For now, the picture at depth $n$ is complete and remarkably crisp: products
see rectangles, rectangles only, and the price of the blind spot is the inverse
square of the golden ratio.
