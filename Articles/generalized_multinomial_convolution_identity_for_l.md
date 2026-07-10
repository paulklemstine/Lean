# Counting with Dots and Dividers: A Convolution Identity Hidden Inside Latin Squares

## A puzzle about arranging symbols in a grid

Imagine a spreadsheet with three rows and several columns. You want to fill each cell with a symbol so that no symbol repeats within a row and no symbol repeats within a column. This is the classic recipe behind Sudoku, behind experimental designs used in agriculture and clinical trials, and behind the error-correcting schemes that keep data intact as it travels across noisy channels. Mathematicians call such a filled grid a **Latin rectangle**, and one of the oldest questions in combinatorics is simply: *how many are there?*

Counting them exactly is notoriously hard. Even for three rows, the classical answer — worked out decades ago by Kenneth Bogart and John Longyear — arrives as a bristling sum of products of binomial coefficients. Buried inside that formula, however, is a smaller and far more elegant creature: a single **convolution identity** that collapses a whole tangle of terms into one clean binomial coefficient. The original authors dismissed it in passing as "easily proved with dots and dividers," and then moved on.

This article is about taking that throwaway remark seriously — and discovering that the identity is not a one-off trick for three rows, but the tip of a completely general phenomenon that works for any number of rows at once.

## The identity, stated plainly

Here is the small identity that appears inside the three-row count. Fix a whole number $a \ge 0$. Then, summing over every way of writing a target number $d$ as an ordered sum $i + j + k = d$ of three non-negative integers,

$$\sum_{i+j+k=d} \binom{a+i}{a}\binom{a+j}{a}\binom{a+k}{a} \;=\; \binom{3a+d+2}{d}.$$

The left side is a sprawling sum: for each of the many triples $(i,j,k)$ that add up to $d$, you multiply three binomial coefficients together, and then you add all those products up. The right side is a *single* binomial coefficient. That such a mess should compress to one term is the kind of small miracle that makes combinatorics addictive.

Our central result is that the "$3$" is not special at all. For **any** number of factors $m \ge 1$:

$$\boxed{\;\sum_{i_1+i_2+\cdots+i_m=d} \;\prod_{j=1}^{m} \binom{a+i_j}{a} \;=\; \binom{ma+d+m-1}{d}.\;}$$

The sum runs over every ordered $m$-tuple of non-negative integers $(i_1,\dots,i_m)$ that adds up to $d$. No matter how many factors you stack, no matter how big $a$ and $d$ are, the enormous sum on the left always folds into the compact expression on the right. We call this the **Generalized Multinomial Convolution Identity**.

## Why "dots and dividers"?

The nickname refers to one of the most beloved pictures in all of counting, usually called **stars and bars**. Suppose you want to count the ways to distribute $d$ identical dots into $m$ labeled boxes. Lay the $d$ dots in a row and drop $m-1$ dividers among them; each arrangement of dots and dividers corresponds to exactly one distribution. There are $d + (m-1)$ objects in total and you choose which $m-1$ of them are dividers, so the count is

$$\binom{d+m-1}{d}.$$

This is precisely our identity in the special case $a = 0$, because $\binom{0+i}{0} = 1$ for every $i$: the product of binomial coefficients becomes $1$, and the left side simply counts the tuples themselves. So the humble dots-and-dividers count is the ground floor of a much taller building. The general identity asks what happens when each dot-configuration is *weighted*, not just counted — when the box holding $i_j$ dots contributes a factor of $\binom{a+i_j}{a}$ instead of $1$.

## The one honest idea behind the proof

There is a single conceptual engine that drives everything, and it comes from generating functions — the practice of encoding an entire infinite sequence of numbers as the coefficients of a power series, so that multiplying series performs bookkeeping automatically.

The key fact is that the binomial coefficients $\binom{a+i}{a}$, read off as $i = 0, 1, 2, \dots$, are exactly the coefficients of the series
$$\frac{1}{(1-x)^{a+1}} \;=\; \sum_{i=0}^{\infty} \binom{a+i}{a}\, x^{i}.$$
This is the *negative binomial series*, and it is the beating heart of the argument. When you **multiply** two power series, the coefficient of $x^{d}$ in the product is a convolution — a sum over all ways of splitting $d$ into two pieces. So multiplying two of these series and reading off the coefficient of $x^d$ gives exactly a two-factor convolution:

$$\sum_{i+j=d}\binom{p+i}{p}\binom{q+j}{q} \;=\; [\,x^d\,]\;\frac{1}{(1-x)^{p+1}}\cdot\frac{1}{(1-x)^{q+1}} \;=\; [\,x^d\,]\;\frac{1}{(1-x)^{p+q+2}} \;=\; \binom{p+q+1+d}{d}.$$

The middle step is just the schoolbook law of exponents: multiplying $(1-x)^{-(p+1)}$ by $(1-x)^{-(q+1)}$ adds the exponents to give $(1-x)^{-(p+q+2)}$. This two-factor statement — the **negative binomial convolution** — is the whole game in miniature.

From there, the general identity follows by a clean induction on the number of factors. Peel off the first coordinate $i_1$ from the $m$-tuple. Summing over everything else, the inner sum is (by the inductive hypothesis) a *single* binomial coefficient with parameter $(m-1)a + m - 2$ or so. That leaves exactly a two-factor convolution between $\binom{a+i_1}{a}$ and the collapsed inner term — precisely the shape the negative binomial convolution knows how to close. The exponents add, the factors merge, and out pops $\binom{ma+d+m-1}{d}$. Every step is elementary; the elegance is in the organization.

## Small numbers you can check by hand

Take $m = 2$, $a = 1$, $d = 2$. The tuples $(i,j)$ summing to $2$ are $(0,2), (1,1), (2,0)$, and $\binom{1+i}{1} = i+1$. The left side is
$$1\cdot 3 + 2\cdot 2 + 3\cdot 1 = 3 + 4 + 3 = 10,$$
while the right side is $\binom{2\cdot 1 + 2 + 1}{2} = \binom{5}{2} = 10$. They agree.

Take the three-factor case $m = 3$, $a = 1$, $d = 2$. Now you are summing $\prod (i_j+1)$ over the six ordered triples that sum to $2$: the triples with a single $2$ contribute $3$ each (three of them), and the triples with two $1$'s contribute $4$ each (three of them). That is $3\cdot 3 + 3\cdot 4 = 9 + 12 = 21$, and the right side is $\binom{3+2+2}{2} = \binom{7}{2} = 21$. Again exact.

These little confirmations are more than reassurance. They show the identity is *robust*: the weights $\binom{a+i_j}{a}$ grow, the number of tuples grows, and yet the sum lands squarely on a single binomial coefficient every time.

## Back to the Latin rectangles

Why did this identity surface inside the count of three-row Latin rectangles in the first place? Because building a valid third row on top of two fixed rows is an inclusion–exclusion problem, and the resulting bookkeeping naturally produces sums of products of binomial coefficients indexed by how columns of various "types" are distributed. The three factors correspond to the three rows; the parameter $a$ tracks a shared offset; and $d$ is a running total. Whenever such a sum appears, the convolution identity replaces it with a single term, dramatically simplifying the closed form. What Bogart and Longyear needed for three rows, the generalized identity supplies for any number of rows — opening the door to analogous simplifications for taller rectangles and related rook-placement counts.

## A wider view

The reason this identity feels inevitable, once seen, is that it is really a statement about **exponents adding**. Each factor $\dfrac{1}{(1-x)^{a+1}}$ is a "brick" carrying exponent $a+1$; stacking $m$ of them builds exponent $m(a+1) = ma + m$, and the coefficient of $x^d$ in $(1-x)^{-(ma+m)}$ is $\binom{ma+m-1+d}{d}$ — exactly the right-hand side. The convolution on the left and the multiplication of series on the right are two descriptions of the same act of combining.

This viewpoint immediately suggests generalizations. If the bricks have *different* thicknesses — parameters $a_1, \dots, a_m$ that need not be equal — the exponents still add, and the same reasoning predicts $\binom{(a_1+\cdots+a_m) + m - 1 + d}{d}$. One can recast the ordered-tuple sum as a sum over unordered multisets with multiplicity weights, connecting it to the theory of multisymmetric functions. And one can ask for a "quantum" version, replacing ordinary binomial coefficients with their $q$-analogues; there the naive identity fails, but a carefully weighted variant survives, hinting at deeper structure.

For now, the take-home message is simple and satisfying. A remark tossed off in an old counting paper — "easily proved with dots and dividers" — turns out to conceal a fully general law. Sums that look hopelessly complicated, involving arbitrarily many interacting binomial weights, always collapse to a single, clean count. It is a reminder that in combinatorics, the right picture — a row of dots, a handful of dividers, a product of tidy power series — can turn an intimidating computation into something you can prove on the back of an envelope.
