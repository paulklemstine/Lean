# Lines That Refuse to Crowd: The Curious Geometry of the Angle $\arccos(1/3)$

## A puzzle you can pose to a child

Take a fistful of drinking straws and try to arrange them through a single point so that **every pair meets at exactly the same angle**. In two dimensions the answer is quickly disappointing: three lines through a point, spaced $60^\circ$ apart, and you are done — a fourth line is forced to spoil the symmetry. But push into three dimensions, then four, then a hundred, and the question suddenly becomes deep, beautiful, and stubbornly hard.

These are the **equiangular lines**: families of lines through the origin, every pair separated by one common angle. They look like a toy, but they sit at the crossroads of geometry, combinatorics, coding theory, and the spectral theory of matrices. Physicists meet them in quantum measurement; engineers meet them in signal design; pure mathematicians have chased them for more than half a century. The central question is embarrassingly simple to state and famously difficult to answer:

> **How many equiangular lines can fit in $d$-dimensional space?**

This article is about a sharp, clean answer for one very special angle — the angle whose cosine is $1/3$ — and about the single elegant idea that tames it.

## Why one angle deserves its own story

Fix the common angle to be $\theta = \arccos(1/3)$, roughly $70.5^\circ$. Write $N_{1/3}(d)$ for the largest number of lines you can pack into $\mathbb{R}^d$ so that every pair meets at this angle. The result we celebrate here is a crisp ceiling:

$$
N_{1/3}(d) \;\le\; \max\{\,28,\; 2(d-1)\,\}.
$$

Read that formula slowly, because it tells a two-act story.

For small dimensions the winner is the flat constant **28**. In fact there is a legendary configuration of $28$ equiangular lines living in $\mathbb{R}^7$ — a jewel connected to the exceptional geometry of the root system $E_7$ and to the $28$ bitangents of a plane quartic curve. No matter how you embed $\mathbb{R}^7$ inside a bigger space, you cannot beat $28$ lines until the *dimension itself* becomes large enough to help you.

For large dimensions the winner is the growing term $2(d-1)$. Here the lines organize into a small number of "pillars," and the count grows *linearly* with the dimension — not quadratically, as a naive guess might suggest. The two mechanisms — a rigid, dimension-blind ceiling and a flexible, dimension-driven growth — never cooperate; they simply hand off to one another exactly where $2(d-1) = 28$, that is, at $d = 15$.

This is a special, fully resolved instance of a sweeping prediction known as **Balla's conjecture**, which foresees a bound of this same shape for *every* fixed angle. The angle $\arccos(1/3)$ is where the prediction becomes an integer-perfect statement, and where the underlying mechanism is easiest to see with complete clarity.

## Turning geometry into a matrix

The decisive move — the one that has powered essentially all progress on equiangular lines since the 1970s — is to stop thinking about lines and start thinking about a matrix.

Pick a unit vector $v_i$ along each line. Because a line has two directions, each $v_i$ is chosen up to sign, but that ambiguity will not hurt us. Now record all the pairwise inner products in a single **Gram matrix** $G$, whose $(i,j)$ entry is $\langle v_i, v_j\rangle$. The diagonal entries are all $1$ (each vector is a unit vector), and every off-diagonal entry is $\pm 1/3$, because that is exactly what "common angle $\arccos(1/3)$" means.

Split $G$ into its predictable part and its interesting part:

$$
G \;=\; I \;+\; \tfrac{1}{3}\,S.
$$

Here $I$ is the identity, and $S$ is the **Seidel matrix**: it has a $0$ on every diagonal entry and a $\pm 1$ on every off-diagonal entry. All the combinatorics of "which pairs of lines are 'acute' and which are 'obtuse'" is packed into the sign pattern of $S$. The Seidel matrix is the combinatorial fingerprint of the configuration.

Two facts about this matrix, both provable in a few lines, do all the heavy lifting.

## Fact one: the Gram matrix cannot have high rank

The vectors $v_1, \dots, v_m$ live in $\mathbb{R}^d$. Stack their coordinates as the rows of an $m \times d$ matrix $B$. Then a single line of algebra shows

$$
G \;=\; B\,B^{\mathsf T}.
$$

The **rank** of a matrix — the number of genuinely independent directions it contains — cannot exceed the number of columns of any factor. Since $B$ has only $d$ columns, we get the **rank cap**:

$$
\operatorname{rank}(G) \;\le\; d.
$$

Geometry ($m$ vectors squeezed into $d$ dimensions) has become linear algebra (a matrix of low rank). This is the whole reason dimension enters the story at all.

## Fact two: rank plus nullity equals the number of lines

Now translate the rank cap into a statement about eigenvalues. Because $G = I + \tfrac13 S$, we have $3G = S + 3I$, and the two matrices $3G$ and $S+3I$ are the same object. So the rank cap says

$$
\operatorname{rank}(S + 3I) \;\le\; d.
$$

The matrix $S + 3I$ acts on the space of all $m$-dimensional vectors — a space of dimension exactly $m$, one coordinate per line. A cornerstone of linear algebra, the **rank–nullity theorem**, says that for any such matrix,

$$
(\text{number of lines } m) \;=\; \operatorname{rank}(S+3I) \;+\; \operatorname{nullity}(S+3I),
$$

where the **nullity** is the dimension of the kernel — the space of vectors that $S+3I$ sends to zero. Combining the two facts gives the clean inequality at the heart of everything:

$$
\boxed{\,m \;\le\; d \;+\; \operatorname{nullity}(S + 3I).\,}
$$

And here is the punchline. A vector $x$ with $(S+3I)x = 0$ is exactly a vector with $Sx = -3x$ — an **eigenvector of the Seidel matrix $S$ for the eigenvalue $-3$**. So the nullity of $S + 3I$ is precisely the **multiplicity of $-3$ as an eigenvalue of $S$**: how many independent directions the Seidel matrix stretches by the factor $-3$.

In one sentence:

> **The number of equiangular lines exceeds the ambient dimension by at most the multiplicity of the eigenvalue $-3$ of the Seidel matrix.**

The entire, sprawling combinatorial problem of counting lines has collapsed into a single, self-contained question about the spectrum of a $0/\pm1$ matrix.

## Why $-3$, and why it forces a small answer

Why does the eigenvalue $-3$ appear, and why is its multiplicity small? The value is no accident: for angle $\arccos(1/3)$ the smallest eigenvalue any such Seidel matrix can have is $-3$, precisely because $-1/(1/3) = -3$. It is an *integer*, and a small one. The smallest matrix that already achieves it is the tiniest nontrivial Seidel matrix of all — the one attached to a single edge between two points, $K_2$, whose Seidel matrix $\left(\begin{smallmatrix}0&1\\1&0\end{smallmatrix}\right)$ has eigenvalues $+1$ and $-1$... and whose *shifted* structure pins the "spectral order" of $-3$ to the value $2$.

That number $2$ is exactly the dial that sets the final answer. In Balla's general framework the ceiling for a given angle is built from this spectral order together with the arithmetic of the angle. For $\arccos(1/3)$ the constant piece evaluates to

$$
\frac{(1 - 1/9)(1 - 2/9)}{2/81} \;=\; 28,
$$

and the linear piece evaluates to $2(d-1)$. Their maximum is the bound we set out to explain. The reason the multiplicity of $-3$ cannot balloon — the reason it stays *linear* in $m$ rather than quadratic — is that an integer eigenvalue of such low spectral order cannot be realized by too many independent "gadgets" before the rigid $\pm1$ sign pattern is forced to repeat itself. Small spectral order is the brake that keeps the count from exploding.

## The two faces of the extremal configurations

The formula $\max\{28, 2(d-1)\}$ hides a genuine change of personality as the dimension grows, and it is worth savoring.

- **Below $d = 15$: rigidity.** The champion is the exceptional $28$-line system. It is essentially unique — a crystalline object with enormous symmetry, the same configuration however you situate it in space. You cannot deform it; you cannot improve it; you can only admire it.

- **Above $d = 15$: flexibility.** The champions are supple one-parameter families of $2(d-1)$ lines, built by stacking simple two-line "books" along shared spines. They bend and flex as the dimension grows, and their count marches upward in lockstep with $d$.

At the crossover $d = 15$, where $2(d-1) = 28$, the crown passes from the rigid jewel to the flexible family, and nothing lives strictly in between.

## Why any of this matters

Equiangular lines are not merely a geometer's curiosity. A large family of lines all meeting at the same angle is, in disguise, a collection of signals that are *maximally spread out* — as mutually distinguishable as geometry allows. That is exactly what one wants in the design of error-correcting codes, in compressed sensing, and in the "symmetric informationally complete" measurements that quantum physicists use to reconstruct the state of a system from as few observations as possible. Knowing the exact maximum number of such lines tells an engineer precisely how many near-orthogonal directions a given number of dimensions can support — no more wishful over-design, no more leaving capacity on the table.

And beyond the applications there is the sheer pleasure of the argument. A question about straws through a point becomes a question about a matrix; the matrix's shape caps its rank; rank-and-nullity converts that cap into a count; and the count is governed by a single small integer eigenvalue. It is mathematics at its most satisfying: a hard, tangible problem dissolved by one clear idea, leaving behind an answer as sharp as $\max\{28, 2(d-1)\}$.

## The idea in one breath

If you remember nothing else, remember the chain:

$$
\text{lines} \;\longrightarrow\; \text{Gram matrix } G = I + \tfrac13 S \;\longrightarrow\; \operatorname{rank}(G)\le d \;\longrightarrow\; m \le d + \operatorname{mult}_{-3}(S).
$$

Counting lines becomes counting how often a single number, $-3$, appears in the spectrum of a matrix of signs. That is the quiet, powerful reason the lines refuse to crowd.
