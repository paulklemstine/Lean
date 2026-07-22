# Turning Reciprocal Moments into Geometric Echoes

## A finite window onto the Báez–Duarte criterion

Number theory often advances by learning to look at the same quantity in two incompatible-seeming ways. A sum built from powers may secretly be a mixture of exponential decays. A complicated alternating combination may simplify into a family of elementary modes. An operation that appears analytic may, before any limit is taken, be nothing more mysterious than the binomial theorem.

That is the central story here. We begin with an arbitrary real sequence of weights $\mu(1),\mu(2),\ldots$ and a finite cutoff $N$. Although the letter $\mu$ recalls the number-theoretic Möbius function, the identities below do not require that special choice. For each nonnegative integer $j$, define the reciprocal-power moment

$$
M_j(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^{2j+2}}.
$$

These moments inspect the same weights at different resolutions. As $j$ grows, large values of $n$ are suppressed more strongly. Now combine the first $k+1$ moments with alternating binomial coefficients:

$$
C_k(N)=\sum_{j=0}^{k}(-1)^j\binom{k}{j}M_j(N).
$$

At first sight, this is numerically awkward. Large binomial terms can cancel, and every $M_j(N)$ is itself a sum. Yet the whole expression has a remarkably transparent second form.

## The hidden geometric mixture

The Finite Báez–Duarte Identity states that for every real weight sequence, every cutoff $N$, and every nonnegative integer $k$,

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}
\left(1-\frac{1}{n^2}\right)^k.
$$

Each integer $n$ contributes a geometric mode with initial amplitude $\mu(n)/n^2$ and decay factor $1-1/n^2$. The original alternating transform is therefore a finite superposition of simple echoes.

Why does this happen? Substitute the definition of $M_j(N)$ into $C_k(N)$ and exchange the two finite sums. The contribution from a fixed $n$ becomes

$$
\frac{\mu(n)}{n^2}
\sum_{j=0}^{k}(-1)^j\binom{k}{j}\left(\frac{1}{n^2}\right)^j.
$$

The binomial theorem collapses the inner sum:

$$
\sum_{j=0}^{k}(-1)^j\binom{k}{j}x^j=(1-x)^k.
$$

Setting $x=1/n^2$ gives the claimed mixture. There is no infinite rearrangement and no hidden convergence condition: every sum is finite.

This formula changes the geometry of the problem. In moment form, the index $k$ controls a delicate cancellation among many reciprocal powers. In mixture form, $k$ is simply time. Every mode evolves independently by repeated multiplication by a number in the interval $[0,1)$. The exceptional mode $n=1$ has decay factor $0$, so it contributes only at $k=0$. Modes with large $n$ decay slowly because $1-1/n^2$ lies close to $1$.

The picture resembles many familiar systems. A plucked string is decomposed into harmonics; a relaxation experiment is decomposed into exponential responses; a Markov process is analyzed through modes with different persistence rates. Here the modes are discrete and arithmetic, indexed by positive integers, with precisely prescribed rates $1-1/n^2$.

## Differences reveal deeper moments

A decay law should become clearer when consecutive times are compared. Subtracting the coefficient at time $k+1$ from the coefficient at time $k$ yields the First-Difference Law:

$$
C_k(N)-C_{k+1}(N)
=
\sum_{n=1}^{N}\frac{\mu(n)}{n^4}
\left(1-\frac{1}{n^2}\right)^k.
$$

The proof is local to each mode. For $r_n=1-1/n^2$,

$$
\frac{\mu(n)}{n^2}r_n^k-
\frac{\mu(n)}{n^2}r_n^{k+1}
=
\frac{\mu(n)}{n^2}r_n^k(1-r_n)
=
\frac{\mu(n)}{n^4}r_n^k.
$$

Taking one negative forward difference raises the reciprocal weight from $n^{-2}$ to $n^{-4}$. This is the first rung of a broader staircase: repeated differences should continue to insert powers of $n^{-2}$. Even at the first rung, the identity explains exactly what finite-difference calculus is measuring. It emphasizes smaller $n$, because multiplying by another $n^{-2}$ suppresses the distant modes.

There is also a computational lesson. Alternating binomial sums can suffer severe cancellation in floating-point arithmetic. The geometric formula evaluates the same finite quantity using direct mode contributions. When the weights have mixed signs, some cancellation remains unavoidable, but the representation removes the additional cancellation manufactured by the binomial transform itself.

## What positivity buys

Suppose now that every weight is nonnegative:

$$
\mu(n)\ge 0 \qquad \text{for all }n.
$$

Since $0\le 1-1/n^2\le 1$, every term in the geometric mixture is nonnegative. Consequently the Positivity Theorem gives

$$
C_k(N)\ge 0.
$$

Moreover, each mode decreases or stays fixed as $k$ increases. Summing mode by mode proves the Monotonicity Theorem:

$$
C_{k+1}(N)\le C_k(N).
$$

The first-difference law tells the same story: under nonnegative weights, its right-hand side is nonnegative, hence $C_k(N)-C_{k+1}(N)\ge 0$.

This is more than a pleasant inequality. It identifies finite Báez–Duarte coefficients with moments of a positive discrete measure. Place mass $\mu(n)/n^2$ at the point

$$
r_n=1-\frac{1}{n^2}.
$$

Then

$$
C_k(N)=\sum_{n=1}^{N}\frac{\mu(n)}{n^2}r_n^k
$$

is the $k$th ordinary moment of that measure on $[0,1)$. Positive measures generate structured sequences: they are nonnegative, decreasing at the first-difference level, and suggest a hierarchy of alternating signs for higher differences.

A crucial warning accompanies this insight. The classical Möbius function takes values in $\{-1,0,1\}$, so it is not nonnegative. Positivity and monotonicity therefore do not automatically apply to the number-theoretic sequence at the heart of the Báez–Duarte criterion. They describe the positive-weight model and expose the structure that signs can disrupt; they do not prove the Riemann hypothesis.

## Two kinds of inversion

The same investigation touches a second Möbius phenomenon. Let the arithmetic Möbius function be written $\mu_{\mathrm{arith}}$, and let

$$
\sigma_s(m)=\sum_{d\mid m}d^s
$$

be the sum of the $s$th powers of the positive divisors of $m$. For every positive integer $n$ and every nonnegative integer $s$, the Divisor Möbius Identity states

$$
\sum_{ab=n}\mu_{\mathrm{arith}}(a)\sigma_s(b)=n^s.
$$

To see why, expand $\sigma_s(b)$ and regroup by a divisor. This is the usual cancellation law of divisor-lattice Möbius inversion: cumulative divisor data are stripped back to their primitive contribution.

The alternating binomial transform and divisor Möbius inversion live on different combinatorial worlds. Binomial coefficients belong to subsets and Pascal’s triangle; arithmetic Möbius inversion belongs to divisibility. Yet both are mechanisms for recovering primitive information from accumulated information. Their coexistence hints at a two-dimensional calculus in which one coordinate tracks reciprocal moments and another tracks divisor sums.

## A small numerical portrait

Take nonnegative weights $\mu(n)=1$ and cutoff $N=4$. The modes are located at $0$, $3/4$, $8/9$, and $15/16$, with amplitudes $1$, $1/4$, $1/9$, and $1/16$. At $k=0$,

$$
C_0(4)=1+\frac14+\frac19+\frac1{16}.
$$

At positive $k$, the $n=1$ mode disappears instantly, while the remaining modes decay at different speeds:

$$
C_k(4)=\frac14\left(\frac34\right)^k
+\frac19\left(\frac89\right)^k
+\frac1{16}\left(\frac{15}{16}\right)^k.
$$

The sequence is visibly positive and decreasing. Its drop from one step to the next is

$$
C_k(4)-C_{k+1}(4)=
\frac1{16}\left(\frac34\right)^k
+\frac1{81}\left(\frac89\right)^k
+\frac1{256}\left(\frac{15}{16}\right)^k.
$$

The same quantity can be reconstructed from alternating combinations of the reciprocal moments. The identity guarantees exact agreement; numerical experiments reveal how differently the two formulas behave under finite precision.

## Why finite cutoffs matter

It is tempting to regard a cutoff as an inconvenience—a temporary fence erected because an infinite sum is too difficult to handle. Here the cutoff is more constructive. It creates a laboratory in which every identity can be seen without analytic fog. The sums may be rearranged freely, each integer contributes one identifiable mode, and every discrepancy in a numerical experiment has a concrete source.

Cutoffs also reveal how information enters by scale. Passing from $N$ to $N+1$ adds exactly one new mode:

$$
C_k(N+1)-C_k(N)=\frac{\mu(N+1)}{(N+1)^2}
\left(1-\frac{1}{(N+1)^2}\right)^k.
$$

For small $k$, its amplitude is controlled mainly by $(N+1)^{-2}$. For large $k$, its slow decay becomes important. This competition explains why estimates uniform in both $N$ and $k$ are subtler than estimates with $k$ fixed.

The cutoff also turns visualization into explanation. One can draw each mode separately, stack the curves, and watch the total emerge. With positive weights, the stack can only descend. With signed weights, positive and negative layers compete. The latter picture is closer to arithmetic Möbius data: the central phenomenon is not decay of individual modes—all individual modes decay—but cancellation among a vast collection whose slowest components accumulate near ratio $1$.

## A transform as a change of language

The moment formula and the geometric formula encode identical numbers, yet they answer different questions. The moment formula explains provenance: $C_k(N)$ is built by applying Pascal’s alternating pattern to reciprocal powers. The geometric formula explains dynamics: $C_k(N)$ evolves as a sum of independent decays. The first-difference formula explains sensitivity: one step of differencing shifts attention toward small integers by adding a factor of $n^{-2}$.

This change of language is valuable far beyond this particular criterion. In data analysis, one often replaces a difficult basis by a basis adapted to the operation under study. Fourier modes simplify translation; eigenvectors simplify repeated linear maps; geometric sequences simplify finite differences. The Báez–Duarte rearrangement belongs to the same tradition. Its special feature is that the new basis is dictated by arithmetic points $1-1/n^2$.

The lesson is methodological. Before estimating a complicated expression, first ask whether its combinatorial transform has already diagonalized it. Here Pascal’s triangle performs precisely that diagonalization.

## Where the real difficulty begins

The finite theory cleanly separates algebra from analysis. For a fixed cutoff, the geometric-mixture identity is exact, the difference law is exact, and positivity follows term by term. The deeper Báez–Duarte program concerns what happens as $N$ tends to infinity with Möbius weights and as $k$ varies. Then tail estimates, cancellation, and uniformity become decisive.

Several natural questions emerge. Can the cutoff error be controlled uniformly when $k$ grows with $N$? Do all higher finite differences have the expected alternating signs for summable nonnegative weights? On which weighted sequence spaces does the infinite binomial transform become a bounded involution? Can divisor-lattice inversion and binomial inversion be combined into one two-parameter convolution? And are the geometric weights uniquely determined by a sufficiently fast-decaying coefficient sequence?

The finite identities do not answer those questions, but they put them into focus. They show that the complicated transform has a simple skeleton: reciprocal moments are converted into geometric echoes by Pascal’s triangle. Once that skeleton is visible, one can tell which difficulties are merely algebraic—and which belong to the subtle infinite behavior where number theory truly begins.