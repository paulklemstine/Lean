# The Prime-Generating Staircase Behind 163

There is a particular kind of mathematical coincidence that feels less like an accident than a glimpse through a hidden door. The number $163$ is famous for one such glimpse: the transcendental quantity $e^{\pi\sqrt{163}}$ lies astonishingly close to an integer. Yet one can approach the same number without exponentials, complex analysis, or numerical approximation. Start instead with a childlike quadratic formula, follow the primes it produces, and watch three themes lock together: a staircase of prime values, the discriminants $43$, $67$, and $163$, and three enormous integers that are exactly cubes plus $744$.

The story begins with the family

$$
f_p(n)=n^2+n+p,
$$

where $p$ and $n$ are nonnegative integers. We say that $p$ has a **sharp Euler prime run** when every value $f_p(n)$ is prime for $0\le n<p-1$, while the next value, $f_p(p-1)$, is not prime. “Sharp” matters: it says not merely that many primes appear, but that the run lasts all the way to a universal barrier and stops exactly there.

## The wall at the end of every run

Why is there a barrier? Substitute $n=p-1$:

$$
f_p(p-1)=(p-1)^2+(p-1)+p=p^2.
$$

For every $p\ge 2$, this is composite. Thus no polynomial in this family can remain prime through the index $p-1$. The square $p^2$ is a built-in wall. A run reaching every earlier index is therefore as long as this simple obstruction permits.

Three values of $p$ reach that wall:

* For $p=11$, the ten values $f_{11}(0),\ldots,f_{11}(9)$ are prime, and $f_{11}(10)=121$.
* For $p=17$, the sixteen values $f_{17}(0),\ldots,f_{17}(15)$ are prime, and $f_{17}(16)=289$.
* For $p=41$, the forty values $f_{41}(0),\ldots,f_{41}(39)$ are prime, and $f_{41}(40)=1681$.

The last is Euler’s celebrated polynomial $n^2+n+41$. Its forty consecutive prime values are not merely a long run; they form a maximal run relative to the unavoidable square boundary.

The values themselves climb in a rigid rhythm. Since

$$
f_p(n+1)-f_p(n)=2n+2,
$$

the gaps are $2,4,6,8,\ldots$. The sequence is strictly increasing, so no prime repeats. This turns the run from a curiosity into a packing theorem.

## A box densely packed with primes

Suppose $p\ge2$ has a sharp Euler prime run. There are exactly $p-1$ allowed indices, namely $0,1,\ldots,p-2$. Strict increase makes their values distinct. Every one is at least $p$, because

$$
f_p(n)=p+n(n+1)\ge p.
$$

Every one is also below $p^2$. Indeed, the sequence increases with $n$, and all allowed indices precede $p-1$, where the value is $p^2$. Consequently:

> **Prime Packing Theorem.** If $p\ge2$ has a sharp Euler prime run, then the values $f_p(0),\ldots,f_p(p-2)$ are exactly $p-1$ distinct primes lying in the half-open interval $[p,p^2)$.

For $p=41$, this says that the polynomial packs forty distinct primes into $[41,1681)$. The first is $41$, the second is $43$, and the last is $1601$.

Two immediate consequences are especially striking. The value at zero is $f_p(0)=p$, so any $p\ge2$ with such a run must itself be prime. If $p\ge3$, then index $1$ also belongs to the run, and

$$
f_p(1)=p+2.
$$

Hence both $p$ and $p+2$ are prime.

> **Twin-Prime Consequence.** Every $p\ge3$ with a sharp Euler prime run begins a twin-prime pair $(p,p+2)$.

Thus the three sharp runs begin with $(11,13)$, $(17,19)$, and $(41,43)$. A forty-term phenomenon already announces itself in its first two steps.

## How the discriminants enter

Rewrite the quadratic by completing the square:

$$
4f_p(n)=(2n+1)^2+(4p-1).
$$

The quantity

$$
D_p=4p-1
$$

is the positive magnitude of the negative discriminant $1-4p$ associated with the quadratic. For $p=11,17,41$, it gives

$$
D_{11}=43,\qquad D_{17}=67,\qquad D_{41}=163.
$$

So the same parameters that create sharp prime runs lead directly to the three largest members of the familiar nine-number list

$$
\{1,2,3,7,11,19,43,67,163\}.
$$

Within this explicitly given finite set, $163$ is the maximum: it belongs to the set, and every listed number is at most $163$. This finite observation should be read literally. Explaining why these nine numbers, and no others, arise from class-number-one imaginary quadratic fields is the much deeper Stark–Heegner theorem; the elementary maximum calculation does not prove that classification.

The discriminant identity also illuminates the polynomial. It says that testing whether $f_p(n)$ is prime is equivalent to looking at numbers of the form $((2n+1)^2+D_p)/4$. The odd squares march upward while a fixed discriminant supplies the offset. The quadratic’s prime-rich behavior is therefore arithmetically tied to $43$, $67$, and $163$, rather than merely labeled by them after the fact.

## Three cubes and the recurring $744$

A second pattern sits far from the scale of the prime runs. Consider the exact identities

$$
960^3+744=884736744,
$$

$$
5280^3+744=147197952744,
$$

and

$$
640320^3+744=262537412640768744.
$$

The bases $960$, $5280$, and $640320$ correspond respectively to the discriminants $43$, $67$, and $163$ in the classical theory of singular moduli. At the elementary level, what matters is already remarkable: three vast integers share precisely the same small displacement from a perfect cube.

Each equality immediately yields a modular signature:

$$
884736744\equiv744\pmod{960^3},
$$

$$
147197952744\equiv744\pmod{5280^3},
$$

$$
262537412640768744\equiv744\pmod{640320^3}.
$$

The number $744$ is not arbitrary in the broader story. It is the constant term in the Fourier expansion of the modular $j$-invariant, whose opening is $j(q)=q^{-1}+744+\cdots$. That analytic bridge explains why expressions involving $e^{\pi\sqrt{D}}$ hover near cube-plus-$744$ integers for special discriminants $D$. But the exact cube identities themselves require no approximation: they are integer arithmetic.

This distinction is important. The celebrated decimal observation about $e^{\pi\sqrt{163}}$ is not established merely by displaying $640320^3+744$. To prove a rigorous near-integer estimate, one must control the tail of the $j$-invariant expansion and obtain certified bounds for $\pi$, square roots, and exponentials. The arithmetic endpoint is exact; the transcendental bridge demands additional analysis.

## A small experiment anyone can reproduce

The arithmetic is unusually transparent. To test a proposed parameter $p$, compute $n^2+n+p$ for $n=0$ through $p-2$ and test each output for primality. Then evaluate the boundary index $p-1$; algebra predicts $p^2$ before any calculation begins. For $p=41$, the opening values are $41,43,47,53,61,71$, while the closing proper value is $1601$. Each gap increases by $2$, exactly as the difference formula predicts.

This experiment also shows why a prime run is stronger than a loose count of primes. It specifies their locations along a convex sequence. The $k$th value is $p+k(k+1)$, so the geometry of the parabola dictates every gap. There is no freedom to rearrange favorable values or discard failures. A single composite before the boundary destroys sharpness. In this sense, $p=11,17,41$ pass a demanding arithmetic obstacle course.

The procedure has a simple computational profile. Trial division up to the square root of each candidate is enough to certify primality. There are $p-1$ candidates, each smaller than $p^2$, so a straightforward implementation uses at most on the order of $p^2$ trial divisions. Faster primality tests improve performance, but no sophisticated machinery is needed for these three cases. The cube identities are even simpler: integer exponentiation, addition, and remainder reproduce them exactly.

## One structure, seen from several distances

At close range, the story is a quadratic staircase. Its $n$th step has height $p+n(n+1)$, and consecutive rises have sizes $2,4,6,\ldots$. At medium range, a sharp run is a dense package of $p-1$ distinct primes in $[p,p^2)$, beginning with twin primes. At a wider scale, completing the square exposes the discriminant $4p-1$. For $p=11,17,41$, that produces $43,67,163$. Farther still, modular function theory associates those discriminants with exact cube-plus-$744$ integers.

For $p=41$, all these elementary facts meet:

1. $n^2+n+41$ is prime for every $0\le n\le39$.
2. Its next value is $41^2=1681$, so the run is sharp.
3. Its forty prime values are distinct and lie in $[41,1681)$.
4. Its first two values are the twin primes $41$ and $43$.
5. The associated discriminant magnitude is $4\cdot41-1=163$.
6. The matching exact integer is $640320^3+744=262537412640768744$.
7. The number $163$ is the largest element of the explicit list $\{1,2,3,7,11,19,43,67,163\}$.

The power of this chain lies in its restraint. It does not pretend that elementary arithmetic alone proves the class-number-one classification or the famous transcendental approximation. Instead it isolates what can be seen exactly: the square that stops every run, the primes filling the interval below it, the twin pair at the entrance, the discriminant produced by completing the square, and the giant integers sitting exactly $744$ beyond cubes.

The number $163$ is often introduced as a magic trick performed by an exponential. The quadratic staircase offers another view. Here the magic is architectural. The wall at $p^2$, the even gaps between successive values, the discriminant $4p-1$, and the cube-plus-$744$ identity are separate beams. For $p=41$, they meet in one structure—and each connection can be followed with ordinary integer arithmetic before the deeper theory begins.
