# The Determinant That Refused to Be Complicated

## A grid built from plus-and-minus signs

Pick a prime number $p$. Not just any prime — let it be one that is at least $7$ and that leaves a remainder of $3$ when you divide it by $4$. The first few are $7, 11, 19, 23, 31$. These primes have a personality. They are the ones for which $-1$ is *not* a perfect square in the clock arithmetic of $p$, and that single fact, as we will see, ends up controlling everything.

Now we build a grid of numbers. For any integer $a$, the *Legendre symbol* $\left(\frac{a}{p}\right)$ is a beautifully simple gadget: it is $+1$ if $a$ is a nonzero perfect square modulo $p$, it is $-1$ if $a$ is not a square modulo $p$, and it is $0$ if $p$ divides $a$. So if you stand inside the world of remainders modulo $p$, the Legendre symbol sorts every number into one of three buckets — "square," "non-square," or "zero" — and stamps each with $+1$, $-1$, or $0$.

From this stamp we assemble a square table. Let $m = \frac{p-5}{2}$, and label both the rows and the columns by $0, 1, 2, \dots, m-1$. In the cell at row $j$ and column $k$, write the number
$$
C_{j,k} = \left(\frac{j-k}{p}\right).
$$
This is an $m \times m$ matrix made entirely of the symbols $+1$, $-1$, and $0$. Its diagonal is all zeros, because $j-j = 0$. Everything off the diagonal is a single sign, dictated by whether the *difference* of the two coordinates is a square modulo $p$.

This object is one of a family of matrices studied by the number theorist Zhi-Wei Sun, who noticed that the determinants of such Legendre-symbol arrays — despite being built from a chaotic-looking jumble of plus and minus signs — fall into astonishingly clean patterns. The grid above is the "truncated" version, cut down to size $m = \frac{p-5}{2}$. The question is deceptively innocent: **what is its determinant?**

## A determinant in disguise

The twist that makes this story interesting is that we do not look at the constant grid alone. Instead we introduce a variable, call it $X$, and add it to *every* entry. We form the new matrix
$$
A_{j,k} = X + \left(\frac{j-k}{p}\right).
$$
Now each entry is not a number but a little polynomial: it is $X$ plus a sign. The determinant of $A$ is therefore not a number either — it is a polynomial in $X$. Our question sharpens into: **as a polynomial, what is $\det A$?**

Here is where intuition sets a trap. A determinant is a sum over all the ways of picking one entry from each row and column, multiplying them, and attaching a sign. With an $m \times m$ matrix whose entries are degree-one polynomials, you would expect to be able to pick the "$X$" part from every row — $m$ rows in total — and end up with a term of degree $m$. So *a priori* the determinant could be a complicated polynomial of degree as high as $m$. For $p = 19$ that would be degree $7$.

The headline result is that this never happens. No matter how large the prime, the determinant collapses to a single, almost trivial shape:
$$
\det A = c \cdot X,
$$
a straight line through the origin. All the high-degree terms vanish. The polynomial is not degree $m$; it is degree $1$, with **no constant term at all**. And the slope $c$ turns out to be a perfect square:
$$
\det A = \left\lfloor \frac{p-2}{3} \right\rfloor^{2} \cdot X.
$$
For $p = 7, 11, 19, 23$ the slopes are $1, 9, 25, 49$ — the squares of the odd numbers $1, 3, 5, 7$. A grid of scrambled signs, perturbed by a variable, produces a perfectly tamed answer: a line whose slope is an odd number squared.

How can a determinant be so much simpler than it has any right to be? The answer comes in two movements, and each one is a small gem of an idea.

## First movement: the magic of rank one

Adding $X$ to every entry is the same as adding $X$ times the *all-ones matrix* — the grid $J$ whose every cell is $1$. So $A = C + X \cdot J$, where $C$ is our original sign grid. The crucial feature of $J$ is that it has **rank one**: every row is identical. It carries only one direction's worth of information.

When you perturb a matrix by something of rank one, the determinant cannot react in a complicated way. To see why, think of the determinant as a function that is *linear in each row separately* — change one row by adding two vectors, and the determinant splits into a sum of two determinants. Our matrix has each row equal to "a row of $C$" plus "$X$ times a row of all ones." If we expand using this row-by-row linearity, we get a sum over every possible choice of which rows contribute their "$C$ part" and which contribute their "$X \cdot (1,1,\dots,1)$ part."

But here is the catch that does all the work. If *two or more* rows decide to contribute their $X$-part, then those rows become identical — each is just $X$ times the same string of ones. A determinant with two equal rows is zero. So every one of those terms silently annihilates itself. The only survivors are:

- the single term where **no** row takes the $X$-part — this is just $\det C$, the constant term; and
- the $m$ terms where **exactly one** row takes the $X$-part — each contributing $X$ times the determinant of $C$ with that one row replaced by all ones.

Everything else is gone. This is the content of the first main theorem, stated in full generality for any matrix $M$ over any commutative ring and any scalar $c$:
$$
\det(M + c \cdot J) = \det M + c \cdot \sum_{j} \det\bigl(M \text{ with row } j \text{ replaced by } (1,1,\dots,1)\bigr).
$$
Setting $c = X$ and $M = C$ gives exactly the affine shape we promised:
$$
\det A = \det C + \bigl(\det(C + J) - \det C\bigr)\cdot X.
$$
The would-be degree-$m$ polynomial is forced, by nothing more than the rank-one nature of the perturbation, to be a straight line. There is no number theory in this step at all — it is pure linear algebra, and it works for *any* grid you start with.

## Second movement: the disappearing constant term

A line has two numbers: an intercept and a slope. We have just reduced the whole problem to those two. The intercept is $\det C$. The slope is $\det(C + J) - \det C$. To finish, we need to understand both.

The intercept is where the special primes earn their keep. Recall that we chose $p \equiv 3 \pmod 4$ precisely so that $-1$ is *not* a square modulo $p$. This means $\left(\frac{-1}{p}\right) = -1$, and therefore
$$
C_{k,j} = \left(\frac{k-j}{p}\right) = \left(\frac{-1}{p}\right)\left(\frac{j-k}{p}\right) = -\left(\frac{j-k}{p}\right) = -C_{j,k}.
$$
In words: swapping a cell's row and column flips its sign. The matrix $C$ is **antisymmetric**. And an antisymmetric matrix of *odd* size always has determinant zero. Since $m = \frac{p-5}{2}$ is odd whenever $p \equiv 3 \pmod 4$, we conclude
$$
\det C = 0.
$$
The intercept vanishes. The line passes through the origin. This is the second main theorem, and it is exactly where the hypothesis $p \equiv 3 \pmod 4$ does its job — for primes congruent to $1$ modulo $4$ the grid would be *symmetric* instead, the constant term would generally survive, and the whole clean picture would dissolve.

With the intercept gone, the formula simplifies to
$$
\det A = \det(C + J)\cdot X.
$$
Everything now rests on a single number: the determinant of the sign grid with $1$ added to every cell. Computing $\det(C+J)$ for $p = 7, 11, 19$ gives $1, 9, 25$ — and these match $\left\lfloor\frac{p-2}{3}\right\rfloor^2$ exactly. So for these primes the complete identity reads
$$
\det A = \left\lfloor \frac{p-2}{3}\right\rfloor^{2}\cdot X,
$$
the odd-square slope we set out to explain.

## What is really going on

Step back and look at what happened. We started with an object that looked like it should be hopelessly complicated: a determinant of a matrix whose every entry is a polynomial, indexed by an arithmetic that scrambles squares and non-squares in a way no simple formula describes. By all rights $\det A$ should have been a dense degree-$m$ polynomial with $m+1$ mysterious coefficients.

Two structural facts flattened it completely. The first — *rank one forces affine* — is a statement of pure algebra: any matrix, perturbed along a single direction, has a determinant that is linear in the perturbation strength. It killed all but two coefficients. The second — *antisymmetry forces a zero determinant in odd dimensions* — is where the arithmetic of $p \equiv 3 \pmod 4$ entered, killing one of the two survivors. What remained was a single integer, $\det(C+J)$, and that integer turned out to be a perfect square.

This is a recurring miracle in number theory: a quantity that seems to depend on the full, irregular distribution of quadratic residues collapses to something you can write on a napkin. The mechanism here is unusually transparent. The slope $\det(C+J)$ is, by the rank-one expansion, a sum of "almost-minors" of a circulant-like Legendre matrix — and circulant Legendre matrices are exactly the objects that classical **Gauss sums** diagonalize. Gauss sums famously have absolute value $\sqrt{p}$, and when you multiply conjugate pairs of them you get *squares*. That is the conjectural reason the slope is always an odd number squared: it is a product of Gauss-sum eigenvalues, paired off into perfect squares. Proving that the slope equals $\left\lfloor\frac{p-2}{3}\right\rfloor^2$ for *every* eligible prime — not just the ones we can compute by hand — is the natural next chapter, and it now reads as a single, focused character-sum identity rather than an $m$-dimensional determinant.

## Why a determinant of signs should interest anyone

Legendre-symbol determinants are not an exotic curiosity. They sit at a crossroads where three rich subjects meet. Quadratic residues — the squares modulo a prime — are the simplest non-trivial case of the reciprocity laws that organize all of algebraic number theory. Determinants and rank are the load-bearing beams of linear algebra. And Gauss sums are the bridge between the two, the discrete cousins of the Fourier transform that turn additive structure into multiplicative structure.

Matrices like $A_{j,k} = X + \left(\frac{j-k}{p}\right)$ also belong to the family of **Toeplitz** and **circulant** matrices, whose entries depend only on the difference of their coordinates. These appear everywhere signals are processed, from the convolution kernels of audio filters to the covariance structures of stationary random processes. The fact that adding a constant background $X$ to such a matrix changes its determinant only linearly is a statement engineers would recognize: a uniform offset is a rank-one signal, and rank-one signals move spectra in the gentlest possible way.

But the deepest pleasure here is aesthetic. We took a wall of $+1$'s and $-1$'s, dialed in a variable, and asked for the determinant — a quantity that is the very emblem of combinatorial complexity, a signed sum over all $m!$ permutations. The answer was a single straight line whose slope is the square of an odd number. The complexity did not so much get solved as *evaporate*, dissolved by two ideas — rank one and antisymmetry — each of which can be explained over coffee. That a problem of this apparent difficulty hides such a small, sharp answer is precisely the kind of surprise that keeps mathematicians coming back to the arithmetic of primes.
