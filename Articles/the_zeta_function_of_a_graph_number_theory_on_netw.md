# The Zeta Function of a Graph: Number Theory on Networks

## Where primes become loops

Prime numbers are the indivisible atoms of arithmetic. Every positive integer factors into primes, and the Riemann zeta function gathers those atoms into a single analytic object. Networks have atoms too—not vertices or edges, but irreducible closed journeys. A traveler can leave a vertex, move through a graph, and eventually return. If the journey is not merely several repetitions of a shorter loop, it is a **prime cycle**.

This analogy is more than poetic. For a finite graph $G$, one may form the Ihara zeta function

$$
\zeta_G(u)=\prod_{[C]}(1-u^{|C|})^{-1},
$$

where the product runs over equivalence classes $[C]$ of prime cycles and $|C|$ is the cycle length. As in number theory, an Euler product records primitive objects and all their repetitions at once. Expanding $(1-u^{|C|})^{-1}$ allows a prime cycle to be traversed once, twice, three times, and so on.

The remarkable feature of graph zeta functions is that geometry, combinatorics, and spectral theory meet in a quadratic polynomial. Suppose a graph is regular and a nontrivial adjacency eigenvalue is $\lambda$. The corresponding local spectral factor has the form

$$
L_{\lambda,q}(u)=1-\lambda u+qu^2,
$$

where $q>0$ is the branching parameter. In the common convention for a $(q+1)$-regular graph, this is the parameter that controls the exponential growth of non-backtracking walks. The results developed here explain exactly what one such factor says: its zeros lie on a critical circle under the Ramanujan bound, its hidden roots generate a Lucas recurrence, and a finite explicit formula turns that recurrence into coefficient data with a completely visible truncation error.

## Two hidden frequencies

Choose complex numbers $\alpha$ and $\beta$ satisfying

$$
\alpha+\beta=\lambda,
\qquad
\alpha\beta=q.
$$

Then a direct multiplication gives the **reciprocal-root factorization theorem**:

$$
1-\lambda u+qu^2=(1-\alpha u)(1-\beta u).
$$

The terminology “reciprocal root” reflects that the zeros in the $u$-plane are $u=\alpha^{-1}$ and $u=\beta^{-1}$ when the roots are nonzero. The pair $\alpha,\beta$ acts like two hidden frequencies behind the quadratic factor.

Now define the spectral power sums

$$
S_n=\alpha^n+\beta^n
$$

for integers $n\ge 0$. Their first values are

$$
S_0=2,
\qquad
S_1=\lambda.
$$

The entire infinite sequence follows from the **Lucas recurrence theorem**:

$$
S_{n+2}=\lambda S_{n+1}-qS_n.
$$

Why? Both $\alpha$ and $\beta$ solve $x^2-\lambda x+q=0$, so multiplying that equation by $x^n$ and adding the two resulting identities produces the recurrence. This is a bridge from spectral graph theory to elementary number theory: a quadratic eigenvalue factor naturally generates a Lucas sequence.

For the concrete parameters $\lambda=2$ and $q=2$, the recurrence begins

$$
2,\ 2,\ 0,\ -4,\ -8,\ -8,\ 0,\ 16.
$$

Nothing numerical has been approximated here. The values are forced by $S_0=2$, $S_1=2$, and $S_{n+2}=2S_{n+1}-2S_n$. They oscillate because the hidden roots are complex, while their size grows because each root has modulus $\sqrt{2}$.

## A critical circle for good expanders

Ramanujan graphs are regular networks with nearly optimal spectral expansion. Their nontrivial adjacency eigenvalues obey a sharp inequality. At the level of one local factor, assume $\lambda$ is real, $q>0$, and

$$
\lambda^2\le 4q.
$$

This is the Ramanujan bound in squared form. The **local critical-circle theorem** states that every complex zero $z$ of

$$
1-\lambda z+qz^2
$$

satisfies

$$
|z|=\frac{1}{\sqrt q}.
$$

This is the graph-theoretic analogue of putting zeta zeros on a critical locus. The proof is transparent. The reciprocal roots $\alpha$ and $\beta$ solve $x^2-\lambda x+q=0$. Since $\lambda^2-4q\le 0$, they are either a complex-conjugate pair or coincide at the boundary. Their product is $q$, so each has modulus $\sqrt q$. Taking reciprocals places the zeros of the local factor on the circle of radius $1/\sqrt q$.

There is also a useful trigonometric picture. Write

$$
\lambda=2\sqrt q\cos\theta
$$

for some real angle $\theta$. Then

$$
\alpha=\sqrt q\,e^{i\theta},
\qquad
\beta=\sqrt q\,e^{-i\theta},
$$

and therefore

$$
S_n=2q^{n/2}\cos(n\theta).
$$

The recurrence is now a sampled wave. The Ramanujan inequality does not merely bound an eigenvalue; it forces the associated spectral dynamics to be oscillatory rather than exponentially dominated by one real root.

## An exact finite explicit formula

In classical analytic number theory, an explicit formula connects primes to zeros. Here the local analogue connects the power sums $S_n$ to the quadratic factor. For any integer $N\ge 0$, define the truncated series

$$
T_N(u)=\sum_{k=0}^{N}S_{k+1}u^k.
$$

The **finite local explicit formula** is

$$
(1-\lambda u+qu^2)T_N(u)
=
\lambda-2qu-S_{N+2}u^{N+1}+qS_{N+1}u^{N+2}.
$$

Every term is explicit. The low-degree expression $\lambda-2qu$ is the stable numerator, while the last two terms are the exact boundary left by truncation. There is no vague remainder estimate and no limit hidden in the statement.

The mechanism is cancellation. Multiply the sum by $1-\lambda u+qu^2$. At each interior power of $u$, the coefficient becomes

$$
S_{n+2}-\lambda S_{n+1}+qS_n,
$$

which vanishes by the Lucas recurrence. Only the first two coefficients and the two terms at the far edge survive. This kind of telescoping is the algebraic heartbeat of explicit formulas: a recurrence annihilates the bulk and exposes the boundary.

Formally letting $N$ tend to infinity, whenever $u$ lies in a region where the boundary tends to zero, gives

$$
\sum_{k\ge 0}S_{k+1}u^k
=
\frac{\lambda-2qu}{1-\lambda u+qu^2}.
$$

The right-hand side is the negative logarithmic derivative of the local factor:

$$
-\frac{d}{du}\log(1-\lambda u+qu^2)
=
\frac{\lambda-2qu}{1-\lambda u+qu^2}.
$$

Thus the spectral power sums are exactly the coefficients carried by the local logarithmic derivative. The finite theorem is stronger for computation because it says precisely what happens before an infinite limit is taken.

## Why this matters for networks

Adjacency eigenvalues govern mixing, expansion, diffusion, and synchronization. Closed non-backtracking walks govern feedback routes and cyclic redundancy. The local factor ties these two views together. From $\lambda$ and $q$, one can generate $S_n$ in linear time using only the recurrence. From the same parameters, one can locate the local zeros. Under the Ramanujan bound, those zeros all have the same radius, while their angles encode oscillation.

This offers a practical diagnostic. Given a proposed regular network, compute its nontrivial adjacency eigenvalues. For each $\lambda$, test whether $\lambda^2\le 4q$. If so, the associated quadratic zeros lie on the critical circle. The recurrence then predicts the local spectral coefficients without repeatedly taking complex powers. Such calculations can support experiments with expander networks, coding graphs, pseudorandom constructions, and transport systems in which rapid mixing and sparse connectivity must coexist.

The analogy with primes must nevertheless be handled carefully. The present results concern one adjacency-eigenvalue factor. They do not, by themselves, count primitive non-backtracking cycles of a whole graph. To reach that global statement one needs the non-backtracking edge matrix, a trace formula for rooted closed walks, Möbius inversion to extract primitive cycles, and the determinant identity assembling all local factors. Nor does a finite graph zeta function reproduce the statistics of the ordinary primes without a carefully specified normalization.

## A small laboratory of examples

The local theory is easy to explore by hand. Take $\lambda=2$ and $q=2$. The inequality $\lambda^2\le 4q$ reads $4\le 8$, so the critical-circle theorem applies. Solving $1-2u+2u^2=0$ gives

$$
u=\frac{1+i}{2}
\qquad\text{or}\qquad
u=\frac{1-i}{2}.
$$

Each zero has modulus $1/\sqrt2$. The first eight recurrence values are the oscillatory integer sequence already displayed. At truncation level $N=3$, the series is

$$
T_3(u)=2-4u^2-8u^3,
$$

and direct multiplication yields

$$
(1-2u+2u^2)T_3(u)=2-4u+8u^4-16u^5.
$$

The middle coefficients disappear; only the low-degree terms and the predicted boundary remain.

At the edge of the Ramanujan range, let $q=4$ and $\lambda=4$. Then $1-4u+4u^2=(1-2u)^2$. The repeated zero $u=1/2$ still lies on the circle of radius $1/2$, and $S_n=2^{n+1}$ reaches the largest size permitted by the bound.

Now step outside the range with $q=2$ and $\lambda=3$. The reciprocal roots are $2$ and $1$, so the local zeros are $1/2$ and $1$. They no longer share the radius $1/\sqrt2$, and $S_n=2^n+1$ is dominated by one exponential mode. The comparison makes the geometry visible: inside the bound there is balanced oscillation; outside it there can be unequal growth.

## The honest bridge

What has been established is both narrower and cleaner than a sweeping slogan. A quadratic graph-zeta factor splits into two reciprocal-root terms. Their power sums begin at $2$ and $\lambda$, obey a Lucas recurrence, and appear as coefficients of the local logarithmic derivative. The finite coefficient identity has an exact two-term boundary. When $\lambda^2\le 4q$, every zero of the factor lies on $|u|=1/\sqrt q$.

That package is a genuine dictionary:

- eigenvalue sum $\lambda$ becomes the first spectral power sum;
- branching product $q$ fixes the root modulus;
- the quadratic factor becomes a second-order recurrence;
- the Ramanujan bound becomes a critical-circle statement;
- multiplication by the local factor turns an infinite-looking coefficient problem into finite cancellation.

The broader dream—that prime cycles in networks might illuminate ordinary primes—remains a direction rather than a conclusion. A responsible next step is to build the global counting machinery, test exact graph families, and compare cycle counts first with their natural benchmark $q^n/n$. Only after choosing a precise normalization should one ask how those fluctuations resemble the fluctuations of integer primes.

Yet the local picture already shows why graph zeta functions are so compelling. A network can hide arithmetic in its loops, waves in its eigenvalues, and a critical circle in a quadratic polynomial. The bridge between those languages is not metaphor alone: it is an exact identity, coefficient by coefficient.
