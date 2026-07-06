# When Squaring a Triangle Keeps the Roots Real

## A number-theory story about counting, matrices, and the quiet order hiding inside chaos

Take a deck of cards numbered $1$ through $n$ and shuffle it. As you read the shuffled deck from left to right, count how many times a card is followed by a *larger* card. Each such spot is called an **ascent**. A perfectly sorted deck has $n-1$ ascents; a perfectly reversed deck has none; most shuffles land somewhere in between.

If you ask, "How many of the $n!$ possible orderings have exactly $k$ ascents?", you have stumbled onto one of the oldest and most beautiful sequences in combinatorics: the **Eulerian numbers**, written $A(n,k)$. They were studied by Leonhard Euler in the eighteenth century, and they have been turning up ever since — in probability, in the geometry of high-dimensional cubes, in the theory of splines used by every animation studio, and in the statistics of random permutations.

This article is about a surprising and delicate fact concerning what happens when you take the entire *table* of Eulerian numbers and **multiply it by itself**. The headline is short and strange:

> Squaring the Eulerian triangle produces a new family of polynomials whose roots are *all real* — and, moreover, all negative, and neatly interlacing from one row to the next.

Real roots may sound like a technicality. It is not. Real-rootedness is a kind of hidden discipline: it forces a sequence of numbers to rise and fall smoothly, with no erratic spikes, and it is exactly the property that guarantees the numbers behave like a well-shaped bell curve. That such discipline should *survive* an operation as violent as squaring a whole table of numbers is the small miracle we want to explain.

## The triangle everyone should know

Let us build the Eulerian numbers from scratch. Arrange them in a triangle, one row for each $n$:

$$
\begin{array}{c}
1 \\
1 \quad 1 \\
1 \quad 4 \quad 1 \\
1 \quad 11 \quad 11 \quad 1 \\
1 \quad 26 \quad 66 \quad 26 \quad 1 \\
1 \quad 57 \quad 302 \quad 302 \quad 57 \quad 1
\end{array}
$$

Row $n$ has $n$ entries, $A(n,0), A(n,1), \dots, A(n,n-1)$. Each row is a palindrome — reversing a deck turns ascents into descents, so orderings with $k$ ascents pair up perfectly with those having $n-1-k$ ascents. The outermost entries are always $1$: exactly one ordering (the reversed deck) has no ascent, and exactly one (the sorted deck) has the maximum.

Everything in the triangle grows from a single rule. To get an entry in a new row, blend the two entries above it with carefully chosen weights:

$$
A(n,k) = (k+1)\, A(n-1,k) + (n-k)\, A(n-1,k-1).
$$

Starting from $A(0,0)=1$ and the left column $A(n,0)=1$, this recurrence generates the whole triangle. It has a clean combinatorial meaning: when you insert the new largest card into a shorter ordering, it either lands in an existing gap (sometimes creating a new ascent, sometimes not), and the two coefficients $k+1$ and $n-k$ count precisely how many insertions keep the ascent count the same versus raise it by one.

The very first fact about these numbers is the most satisfying, and it is completely rigorous:

> **Row-Sum Identity.** For every $n \ge 1$, the entries of row $n$ add up to $n!$:
> $$ \sum_{k=0}^{n-1} A(n,k) = n!. $$

This is not a coincidence — it is a *conservation law*. Every one of the $n!$ possible orderings has *some* number of ascents, so if you sort the orderings into bins by ascent count and total the bins, you must recover all $n!$ orderings. Check the triangle: $1+4+1 = 6 = 3!$, and $1+11+11+1 = 24 = 4!$. The pattern never fails.

## From numbers to polynomials

Combinatorialists have a favorite trick: whenever you have a row of numbers, hang them on the powers of a variable $x$ to make a polynomial. For the Eulerian numbers, this produces the **Eulerian polynomials**:

$$
A_n(x) = \sum_{k=0}^{n-1} A(n,k)\, x^k.
$$

So $A_3(x) = 1 + 4x + x^2$ and $A_4(x) = 1 + 11x + 11x^2 + x^3$. These polynomials are famous, and they possess a jewel of a property that has been known for over a century:

> **Every Eulerian polynomial has only real roots** — in fact only negative real roots.

Why should anyone care where a polynomial vanishes? Because a polynomial with nonnegative coefficients has *all real roots* if and only if its coefficients are *log-concave with no internal gaps* — meaning each coefficient is at least the geometric mean of its neighbors. Log-concavity is the mathematical signature of "smooth, single-peaked, bell-like" data. Real roots are the certificate that a counting sequence is as well-behaved as a Gaussian. The Eulerian numbers famously satisfy a central limit theorem: the number of ascents in a random permutation is approximately normally distributed, and real-rootedness is the engine behind that fact.

## The bold move: square the triangle

Now for the twist that gives this story its name. Think of the Eulerian triangle not as a picture but as an infinite lower-triangular **matrix** $M$, whose entry in row $n$, column $k$ is $A(n,k)$. Matrices can be multiplied, and in particular a matrix can be multiplied by itself. What is $M^2$?

The rule for matrix multiplication says that the entry of $M^2$ in row $n$, column $k$ is a sum of products along a row and down a column:

$$
T(n,k) = \sum_{j} A(n,j)\, A(j,k).
$$

You march across row $n$ of the triangle, and for each entry you march down column $k$, multiply the matching pairs, and add everything up. It is a genuinely tangled double sum — every entry of the answer mixes together contributions from the entire triangle.

Hang the resulting numbers on powers of $x$ again, and you get the **squared-triangle row polynomials**, the true heroes of this article:

$$
S_n(x) = \sum_{k} T(n,k)\, x^k = \sum_{k}\Bigl(\sum_j A(n,j)\,A(j,k)\Bigr) x^k.
$$

Written out, the first few are:

$$
\begin{aligned}
S_3(x) &= 6 + x, \\
S_4(x) &= 24 + 15x + x^2, \\
S_5(x) &= 120 + 181x + 37x^2 + x^3, \\
S_6(x) &= 720 + 2163x + 995x^2 + 83x^3 + x^4.
\end{aligned}
$$

Two features leap out, and both can be proved.

First, **the constant term is always $n!$**. Look: the constant term of $S_n$ is $\sum_j A(n,j)\,A(j,0)$, and since the left column of the triangle is all ones ($A(j,0)=1$), this collapses to $\sum_j A(n,j)$ — which is exactly the row sum $n!$ from before. The conservation law resurfaces, now sitting quietly at the bottom of each squared polynomial.

Second, **the degree is $n-2$**, two less than you might naively guess. The reason is structural: the Eulerian matrix is triangular, so multiplying it by itself pushes the nonzero entries inward, trimming two columns off each row.

## The miracle: the roots stay real

Here is where the surprise lands. There is no obvious reason a wild double sum like $S_n$ should be well-behaved. Squaring can and often does destroy real-rootedness; generic products of nice polynomials go complex. Yet when we compute the roots of $S_n$, we find:

$$
\begin{array}{c|l}
n & \text{roots of } S_n(x) \\ \hline
3 & -6 \\
4 & -13.18,\ -1.82 \\
5 & -31.35,\ -4.86,\ -0.79 \\
6 & -69.04,\ -11.28,\ -2.28,\ -0.41 \\
7 & -146.64,\ -23.98,\ -4.87,\ -1.28,\ -0.23
\end{array}
$$

Every root is **real**. Every root is **negative**. And if you place two consecutive rows side by side, their roots **interlace** like the teeth of a zipper — between any two neighboring roots of $S_{n+1}$ sits exactly one root of $S_n$. These are not floating-point coincidences; they can be certified exactly, with no rounding, using a classical tool called a **Sturm sequence** that counts real roots by tracking sign changes in a chain of polynomial remainders.

> **The Central Claim.** For every $n$, the squared-triangle polynomial $S_n(x)$ has only real, negative roots, and the roots of consecutive rows interlace.

## Why it should be true: the secret ingredient is interlacing

The double sum defining $S_n$ looks hopeless, but a change of perspective dissolves it. Group the terms not by the inner index but by the outer one:

$$
S_n(x) = \sum_{k}\Bigl(\sum_j A(n,j) A(j,k)\Bigr) x^k = \sum_{j} A(n,j) \Bigl(\sum_k A(j,k)\, x^k\Bigr) = \sum_{j} A(n,j)\, A_j(x).
$$

Read that again: **the squared-triangle polynomial is just a weighted sum of the ordinary Eulerian polynomials**, where the weights $A(n,j)$ are themselves Eulerian numbers — all of them nonnegative. The tangled double sum was, in disguise, a simple nonnegative recombination of objects we already understand.

This reframing is the key that unlocks the door, because of a powerful principle in the theory of polynomials:

> If a family of polynomials shares a *common interlacer* — a single polynomial whose roots separate the roots of every member — then **any nonnegative combination of the family is again real-rooted.**

This is the method of *interlacing families*, a circle of ideas that has, in recent years, resolved long-standing problems far afield (it lies behind the celebrated proof of the existence of infinite families of expander graphs). The Eulerian polynomials are the textbook example of such a compatible, interlacing family. Once we know $S_n$ is a nonnegative blend of them, real-rootedness is no longer a mystery about a double sum; it is a statement about whether the specific weights $A(n,\cdot)$ respect the interlacing structure. The chaos has been organized into a single, sharp question.

## Why this matters

Real-rootedness is one of the deepest recurring themes in modern combinatorics precisely because it is a bridge. On one side sits *counting* — concrete, discrete tallies of permutations, trees, lattice paths. On the other sits *analysis and geometry* — the smooth world of polynomials, roots, and inequalities. Real-rootedness is the passport that lets a result travel between them: it instantly delivers log-concavity, unimodality (the counts rise then fall, with a single peak), and central-limit behavior, all for free.

The same phenomenon has recently been established for the squares of several other classical triangles — Pascal's triangle, the Stirling triangle, the Narayana triangle. In each case, squaring the triangle preserved real-rootedness. The Eulerian triangle was the conspicuous, stubborn holdout: its rows are richer, its recurrence more intricate, and the question of whether *its* square keeps the roots real remained open. The results assembled here — the exact row-sum and constant-term identities, the degree formula, the reduction to a weighted sum of Eulerian polynomials, and the certified real, negative, interlacing spectra for every case computed — bring the Eulerian case into line with its cousins and pin down exactly where the remaining difficulty lives.

There is something almost philosophical in the picture. You start with the pure chaos of shuffled cards. You organize that chaos into a triangle. You then perform an operation — squaring — that scrambles the whole triangle into itself. And out the other side comes not more chaos but *more order*: a family of polynomials whose roots march down the negative axis in perfect, interlacing formation. It is a reminder that in mathematics the deepest structures are often the ones that refuse to break, no matter how hard you shake them.
