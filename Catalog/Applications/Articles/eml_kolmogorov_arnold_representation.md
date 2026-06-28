# How Many Ingredients Does a Surface Need? The Hidden Arithmetic of Separable Rank

## A theorem about building everything from almost nothing

In 1957, the nineteen‑year‑old Vladimir Arnold, working with his teacher Andrei Kolmogorov, demolished one of David Hilbert's famous problems. Hilbert had asked whether some functions of several variables are *irreducibly* multivariate — whether there exist surfaces so tangled that you can never build them out of simple one‑input curves. Kolmogorov and Arnold answered with a resounding *no*.

Their **superposition theorem** says something almost unbelievable. Take any continuous function $f$ of $n$ variables on the unit cube $[0,1]^n$ — a temperature field, a price surface, a sound texture, anything. Then $f$ can be written as

$$f(x_1,\dots,x_n) = \sum_{q=0}^{2n} \Phi_q\!\left(\sum_{p=1}^{n} \psi_{q,p}(x_p)\right),$$

where every $\Phi_q$ and every $\psi_{q,p}$ is a continuous function of a **single** variable. The whole infinite zoo of multivariate functions can be assembled from one‑dimensional building blocks, addition, and nothing else. For two variables ($n=2$), the magic number of outer functions is $2n+1 = 5$.

It is one of the most surprising facts in analysis, and in recent years it has become fashionable again: the "Kolmogorov–Arnold Networks" (KANs) that have swept through machine learning are direct descendants of this theorem, replacing the fixed weights of a neural network with learnable one‑dimensional curves.

But the theorem leaves a tantalizing question wide open. It promises that building blocks *exist*, but it says almost nothing about *which* building blocks, or *how many* you really need for a particular surface. This article is about a precise, hard‑edged answer to the "how many" question — an answer that turns out to be governed by the oldest tool in linear algebra: the rank of a matrix.

## EML functions: the universe's favorite building blocks

Among all the one‑dimensional curves you might reach for, a special family keeps showing up everywhere in science: the **EML functions**, built by composing just three operations — **E**xponentiation $\exp$, taking **L**ogarithms $\log$, and **M**ultiplying (together with adding and constants). These are the functions behind compound interest, radioactive decay, the Richter scale, entropy, the pH of your coffee, and the activation curves inside deep networks.

A natural and bold conjecture sharpens Kolmogorov–Arnold: *can the inner building blocks always be chosen from this clean EML family?* The simplest non‑trivial target to test is the humble product,

$$f(x,y) = x\cdot y.$$

On the positive quadrant, where $x>0$ and $y>0$, there is a breathtakingly compact answer. Using the schoolbook identity $\log(xy)=\log x+\log y$ and then undoing the logarithm with an exponential,

$$x\cdot y = \exp\big(\log x + \log y\big).$$

Read this as a Kolmogorov–Arnold formula: the inner function is $\psi=\log$ (applied to each coordinate), the sum $\log x + \log y$ is taken, and a single outer function $\Phi=\exp$ finishes the job. **One** outer term, drawn entirely from the EML family. The theorem guaranteed at most five outer functions for two variables; the product needs just one.

This elegance comes with fine print. The identity uses $\log x$, which only makes sense for $x>0$. Cross either axis and the formula collapses — $\exp$ is always positive, so it can never reproduce a product like $(-1)\cdot 1 = -1$. The clean "rank‑one" picture is a *local* miracle, not a global one. Over the whole plane you must fall back on a two‑piece construction, the polarization identity

$$x\cdot y = \tfrac14 (x+y)^2 - \tfrac14 (x-y)^2,$$

which uses **two** outer functions but works everywhere.

So already the product hints at a number attached to each surface — the smallest count of outer terms it truly requires. Making that number precise is the heart of the story.

## Separable rank: counting the irreducible ingredients

Here is the central definition. We say a two‑variable function $f$ has **separable rank at most $r$** if it can be written as a sum of $r$ products of one‑variable functions:

$$f(x,y) = \sum_{k=0}^{r-1} a_k(x)\, b_k(y).$$

Each term $a_k(x)\,b_k(y)$ is a "separable" piece — a curve in $x$ times a curve in $y$. The separable rank is the minimum number of such pieces you need. And crucially, when all the factors are positive, every single term is an EML expression: $a_k(x)\,b_k(y) = \exp\big(\log a_k(x) + \log b_k(y)\big)$. **The separable rank is exactly the number of EML outer `exp` terms in a sum‑of‑products Kolmogorov–Arnold representation.** Counting ingredients in the recipe is the same as counting EML exponentials.

With this lens, the earlier observations snap into focus.

- The product $x\cdot y$ is a *single* term $a(x)b(y)$ with $a=b=\mathrm{id}$. Its separable rank is $1$. (In the Lean development this is the lemma `mul_sepRankLE_one`.)
- Rank $\le 1$ turns out to be *exactly* the classical notion of being **multiplicatively separable** — that $f(x,y)=a(x)\,b(y)$ for some single pair of curves. The two notions are provably the same (`mulSeparable_iff_sepRankLE_one`).

So the product sits at the very bottom of the hierarchy. What about the sum?

## The sum is genuinely two‑dimensional

The most basic non‑separable surface is the sum, $f(x,y)=x+y$. We can certainly write it with two terms:

$$x + y = x\cdot 1 + 1\cdot y,$$

so its separable rank is at most $2$ (`add_sepRankLE_two`). The real question is whether one term could ever suffice. It cannot — and there is a beautiful, completely elementary way to *prove* it cannot, using nothing more than a $2\times 2$ table.

Sample the surface at $x,y\in\{0,1\}$ and lay the four values in a grid:

$$M = \begin{pmatrix} f(0,0) & f(0,1)\\ f(1,0) & f(1,1)\end{pmatrix} = \begin{pmatrix} 0 & 1\\ 1 & 2\end{pmatrix}.$$

The determinant of this matrix is $0\cdot 2 - 1\cdot 1 = -1$, which is *not* zero. And here is the punchline that connects everything: **if a function has separable rank at most $r$, then every grid of sampled values you can build from it has matrix rank at most $r$.**

The reason is pure linear algebra. If $f(x,y)=\sum_{k<r} a_k(x)b_k(y)$, then the sampled matrix factors as a tall matrix (rows indexed by your $x$‑points, columns by $k$) times a wide matrix (rows indexed by $k$, columns by your $y$‑points). A product of an $m\times r$ matrix and an $r\times m$ matrix can never have rank exceeding $r$. This is the **sampling lower bound** (`sample_rank_le`), and its immediate corollary (`sepRankLE_ge_of_det_ne_zero`) is a sharp detector: if even one $m\times m$ sample has nonzero determinant, the separable rank must be at least $m$.

Apply this to the sum. The $2\times 2$ sample has nonzero determinant, so the separable rank of $x+y$ is at least $2$. Combined with the easy upper bound, its rank is **exactly $2$** (`add_not_sepRankLE_one`). The sum is, in this precise and provable sense, irreducibly two‑dimensional: no single product of curves will ever capture it. A schoolchild's table of four numbers contains a rigorous impossibility proof.

## Climbing forever: the power‑sum staircase

Now for the climax. Is there a ceiling on separable rank? Kolmogorov–Arnold caps the number of *inner* functions at $2n+1$ — five for two variables. Does some similar magic number cap the number of *outer* EML terms?

The answer is a firm **no**, and a single family of surfaces proves it. Consider the **power‑sum**

$$p_N(x,y) = \sum_{k=0}^{N-1} x^k\, y^k = 1 + xy + x^2y^2 + \cdots + x^{N-1}y^{N-1}.$$

It is built as a sum of $N$ products, so its separable rank is at most $N$ (`powerSum_sepRankLE`). To prove that it needs *all* $N$ terms, we deploy the sampling detector with a classical and elegant choice of points: sample at $x,y \in \{0,1,2,\dots,N-1\}$. The resulting $N\times N$ matrix is precisely $V V^{\!\top}$, where $V$ is the **Vandermonde matrix** with entries $V_{ik} = i^{k}$. The Vandermonde determinant for distinct points is famously nonzero — it equals the product of all pairwise differences — and therefore

$$\det(V V^{\!\top}) = (\det V)^2 \neq 0.$$

A nonzero $N\times N$ sample forces the separable rank up to at least $N$. With the matching upper bound, the separable rank of $p_N$ is **exactly $N$** (`powerSum_rank_ge`).

Let that sink in. By dialing up $N$, we manufacture surfaces requiring as many EML outer terms as we please. The number of inner one‑dimensional functions stays pinned at the Kolmogorov–Arnold ceiling, but the number of outer EML exponentials marches off to infinity. The two notions of "complexity" decouple completely. There is no universal recipe with a fixed number of EML exponentials that bakes every two‑variable surface; the staircase of complexity has no top step.

## Why a Russian theorem and a Vandermonde matrix should be friends

What makes this story satisfying is that three classical ideas, born in different centuries and different fields, lock together perfectly:

- **Kolmogorov–Arnold (1957)** tells us one‑dimensional building blocks always suffice — a statement about *existence*.
- **EML functions** — exp, log, multiply — supply the most natural, science‑pervasive building blocks, and reveal that a separable term is literally an exponential of a sum of logs.
- **Matrix rank and the Vandermonde determinant (18th century)** supply the *accounting*, converting a slippery question about infinitely many functions into a finite, checkable computation on a grid of samples.

The bridge between them is the simple observation that *sampling a sum of products is a matrix factorization*. That one move turns analysis into arithmetic. To prove a surface is complicated, you no longer argue about continuous functions at all — you tabulate a handful of its values and compute a determinant. If the determinant is nonzero, the surface is provably irreducible below that size. It is a rare and beautiful instance where a deep representation theorem is fenced in by a fact a student can verify by hand.

## Where this points

Several threads now beg to be pulled. The sampling bound gives an upper limit on rank for every finite grid; one expects the *true* separable rank to equal the largest rank you ever see across all grids — turning it into a fully computable invariant of a surface. Tensor‑product surfaces, where two independent two‑variable functions are multiplied, should have ranks that *multiply*, mirroring the Kronecker‑product rank law. And the contrast between the local rank‑one $\exp(\log x+\log y)$ form of the product and its global rank‑two polarization form suggests that crossing an axis can force a measurable "rank jump" — a quantitative shadow of the boundary where logarithms cease to exist.

Underneath all of it lies a clean moral. The Kolmogorov–Arnold theorem tells you that everything can be built from simple parts. Separable rank tells you the *price*. And the price, it turns out, is written in the language of matrices and determinants — a currency mathematicians have been counting in for three hundred years.
