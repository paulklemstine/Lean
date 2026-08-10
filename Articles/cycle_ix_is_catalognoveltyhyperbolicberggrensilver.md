# The Silver Speed Limit of the Pythagorean Tree

## Every right triangle has an address

Every primitive Pythagorean triple — every triple of whole numbers $(a,b,c)$ with
$a^2+b^2=c^2$ and no common factor, like $(3,4,5)$, $(5,12,13)$, $(20,21,29)$ — has
exactly one address in an infinite ternary tree.

The tree was discovered by B. Berggren in 1934 and rediscovered many times since. Its
root is $(3,4,5)$. Every triple has exactly three children, produced by three fixed
integer matrices, and every primitive triple appears exactly once. Nothing is missed,
nothing is repeated. It is one of the cleanest structural facts in elementary number
theory: the chaotic-looking set of Pythagorean triples is really a perfect ternary
tree.

It is much easier to see what the tree does if you stop looking at the triples and look
at their *seeds*. Euclid's parametrisation writes each primitive triple as
$$a = m^2 - n^2,\qquad b = 2mn,\qquad c = m^2+n^2$$
for a pair of coprime integers $m > n > 0$ of opposite parity. The root $(3,4,5)$ has
seed $(m,n)=(2,1)$. In seed coordinates the three children of a node are given by three
strikingly simple rules:
$$B_1:(m,n)\mapsto(2m-n,\;m),\qquad
B_2:(m,n)\mapsto(2m+n,\;m),\qquad
B_3:(m,n)\mapsto(m+2n,\;n).$$
So the whole tree of Pythagorean triples is the orbit of the single pair $(2,1)$ under
free composition of these three maps. A node is a *word* in the letters $B_1,B_2,B_3$,
and its *depth* is the length of that word.

That raises a question that sounds like geography rather than number theory: **how fast
does the tree grow?** If you walk $k$ steps down from the root, how far have you
travelled?

## Distance, measured in the hyperbolic plane

"How far" needs a ruler. The natural ruler here is not the size of the numbers but
hyperbolic distance, because the three matrices $B_1,B_2,B_3$ are isometries of the
hyperbolic plane: they belong to the modular group, and the tree is literally a walk in
a negatively curved world.

Put each seed on the hyperbolic upper half-plane $\mathbb{H}=\{x+iy: y>0\}$ at the point
$$z(m,n) \;=\; \frac{n+i}{m},$$
and measure hyperbolic distance $d$ from the base point $i$. A two-line computation with
the formula $\cosh d(i,x+iy) = \frac{x^2+y^2+1}{2y}$ gives
$$\cosh d\bigl(i,z(m,n)\bigr) = \frac{m^2+n^2+1}{2m},$$
and since $0<n<m$ this is squeezed between $\frac{m^2+1}{2m}=\cosh(\log m)$ and
$\frac{4m^2+1}{4m}=\cosh(\log 2m)$. In other words:

> **The Window Lemma.** For every Euclid seed $(m,n)$ with $0<n<m$,
> $$\log m \;\le\; d\bigl(i,z(m,n)\bigr)\;\le\;\log m + \log 2 .$$

This is the hinge of the entire story. Hyperbolic distance is nothing but the logarithm
of the *larger seed coordinate*, to within an absolute error of $\log 2 = 0.693\ldots$.
Geometry has become arithmetic: to understand distances in the tree, understand how fast
$m$ grows.

## The three moves are not created equal

Now look at the three maps through the lens of the slope $x=m/n$. Dividing out,
$$B_1: x\mapsto 2-\tfrac1x,\qquad B_2: x\mapsto 2+\tfrac1x,\qquad B_3: x\mapsto x+2 .$$

* $B_1$ has the single fixed point $x=1$, which it touches tangentially — it is a
  *parabolic* map. Slopes near $1$ crawl.
* $B_3$ has no finite fixed point; it slides slopes off to infinity, and once $m\gg n$
  the multiplicative gain per step is $1+2n/m \to 1$. Parabolic at infinity.
* $B_2$ has the fixed point $x = 2+1/x$, i.e. $x = 1+\sqrt2$: the **silver ratio**. This
  fixed point is *hyperbolic*, attracting with expansion factor exactly $1+\sqrt2$.

So only one of the three moves is a genuine expander, and its expansion constant is the
silver ratio $\lambda = 1+\sqrt2 = 2.41421\ldots$, the number satisfying
$\lambda^2 = 2\lambda+1$ (the "$\sqrt2$-analogue" of the golden ratio, and the growth
rate of the Pell numbers $0,1,2,5,12,29,70,\ldots$).

This single observation dictates everything below. It explains why the fastest route
down the Pythagorean tree is not "any route", why the natural guess about depth and
distance is wrong, and why a certain irrational number, $\log(1+\sqrt2)=0.881373\ldots$,
is the tree's absolute speed limit.

## The silver potential and the speed limit

Here is the trick that turns the observation into a theorem. Define the **silver
potential** of a seed:
$$\Phi(m,n) \;=\; m + (\sqrt2-1)\,n .$$
The weight $\sqrt2-1$ is chosen so that $\Phi$ behaves as well as possible under all
three moves at once. A short computation shows:

* $\Phi(B_2(m,n)) = (1+\sqrt2)\,\Phi(m,n)$ — **exactly**, for every seed;
* $\Phi(B_1(m,n)) \le (1+\sqrt2)\,\Phi(m,n) - 2$;
* $\Phi(B_3(m,n)) \le (1+\sqrt2)\,\Phi(m,n) - \sqrt2$.

The middle move multiplies the potential by the silver ratio on the nose; the other two
fall strictly short, and by a definite amount. Starting from $\Phi(2,1)=1+\sqrt2$, an
induction gives the clean bound
$$\Phi \;\le\; (1+\sqrt2)^{\,k+1}\quad\text{at depth }k,$$
with equality precisely along the pure-$B_2$ path — the *Pell spine*, whose seeds are
$(2,1),(5,2),(12,5),(29,12),(70,29),\ldots$, consecutive Pell numbers. Combining this
with the Window Lemma:

> **The Silver Speed Limit.** Every node at depth $k$ satisfies
> $$d(i,z)\;\le\;(k+1)\log(1+\sqrt2)+\log 2 .$$
> Along the Pell spine, $d \ge (k+1)\log(1+\sqrt2)-\tfrac12\log 2$.

So the maximal hyperbolic displacement per step is exactly $\log(1+\sqrt2)=0.88137\ldots$
— strictly between $\log 2 = 0.693$ and $\log 3 = 1.099$. The tree is ternary, so a naive
count says it "should" spread at rate $\log 3$; it does not, and it never can. Its true
metric growth exponent is the logarithm of the silver ratio.

The extremal structure is rigid, not just optimal on average. At every depth the Pell
node dominates every other node in *both* coordinates simultaneously, so it maximises the
seed, the hypotenuse, and the potential all at once — and it is the **unique** maximiser:
any other node at depth $k$ has potential at most $(1+\sqrt2)^{k+1}-\sqrt2$. There is a
gap, and the gap does not shrink.

There is a pleasant surprise in the fine print. The Pell numbers obey the Binet formula
$$m_k = \frac{\lambda^{k+2}-\bar\lambda^{\,k+2}}{2\sqrt2},\qquad \bar\lambda = 1-\sqrt2,$$
so the maximal seed coordinate at depth $k$, divided by $\lambda^{k+1}$, converges not to
the "obvious" constant $1/\sqrt2 = 0.7071$ but to
$$\frac{2+\sqrt2}{4} = 0.853553\ldots,$$
which is strictly larger. Sharp constants are easy to guess wrong.

## The obvious conjecture, and why it fails

Only $B_2$ expands. So the natural conjecture — one we can now test rather than admire —
is that the long-run speed of an infinite path is governed by *how often you use $B_2$*:
that the growth rate should be a function, indeed an increasing function, of the
asymptotic frequency of the middle move.

It is not. Consider two periodic paths that never use $B_1$ and use $B_2$ exactly half the
time:
$$P_A = (B_2B_3)^\infty,\qquad P_B = (B_2B_2B_3B_3)^\infty .$$
Both have middle-move frequency exactly $\tfrac12$. Multiply out one period of each in
matrix form. For $P_A$ the period matrix is $\begin{pmatrix}4&1\\1&0\end{pmatrix}$, with
characteristic root $2+\sqrt5$; for $P_B$ it is
$\begin{pmatrix}13&6\\2&1\end{pmatrix}$, with characteristic root
$7+4\sqrt3=(2+\sqrt3)^2$. Feeding the resulting Binet expansions through the Window Lemma
yields the *exact* speeds
$$\text{rate}(P_A) = \tfrac12\log(2+\sqrt5) = 0.721817\ldots,\qquad
\text{rate}(P_B) = \tfrac12\log(2+\sqrt3) = 0.658479\ldots .$$

Same frequency of the only expanding move, different speeds, and by a wide margin. The
*arrangement* of the letters matters, not merely their density. The reason is dynamical:
$B_3$ is not neutral — it pushes the slope $x=m/n$ far away from the attracting fixed
point $1+\sqrt2$, and $B_2$'s next application then earns less than its nominal factor.
Two consecutive $B_3$'s do more damage than two separated ones. Clustering the damage
costs you.

## The whole interval is available

Once you know that the top speed is $\log(1+\sqrt2)$ and that some paths crawl at nearly
zero speed, you want the full list: which speeds actually occur?

There is a two-parameter family that answers this. For odd $a\ge1$ and any $b\ge0$,
consider the periodic path $(B_2^{\,a}B_3^{\,b})^\infty$. Its period matrix is
$M^aR^b$, where $M=\begin{pmatrix}2&1\\1&0\end{pmatrix}$ and
$R=\begin{pmatrix}1&2\\0&1\end{pmatrix}$. The entries of $M^a$ are Pell numbers,
$$M^a=\begin{pmatrix}P_{a+1}&P_a\\P_a&P_{a-1}\end{pmatrix},$$
and Cassini's identity for Pell numbers, $P_{a+1}P_{a-1}-P_a^2=(-1)^a$, says the
determinant is $-1$ when $a$ is odd. A $2\times2$ integer matrix of determinant $-1$ and
trace $T$ has characteristic polynomial $x^2-Tx-1$, so the seed coordinate along the path
satisfies the two-term integer recurrence $x_{j+2}=Tx_{j+1}+x_j$ and grows like
$$\sigma(a,b)=\frac{T+\sqrt{T^2+4}}{2},\qquad T(a,b)=P_{a+1}+2bP_a+P_{a-1}.$$
Because the period has length $a+b$, the exact speed of this path is
$$r(a,b)=\frac{\log \sigma(a,b)}{a+b}.$$

Two facts about this family close the circle:

* **It reaches the top.** For $b=0$, $\sigma(a,0)=(1+\sqrt2)^a$, so $r(a,0)=\log(1+\sqrt2)$
  exactly, for every odd $a$. The maximum is attained inside the family.
* **It reaches the bottom, in small steps.** For fixed $a$, $r(a,b)\to 0$ as $b\to\infty$
  (long parabolic blocks dilute the expansion), and consecutive members differ by at most
  $\frac{3\log 3}{a+b+1}$ — a step size we can make as small as we like by taking $a$
  large.

A discrete intermediate-value argument now does the rest: start at the top, walk down in
steps smaller than $\varepsilon$, and you cannot skip over any target.

> **Density Theorem.** For every $r\in[0,\log(1+\sqrt2)]$ and every $\varepsilon>0$ there
> exist an odd $a$ and a $b$ such that the path $(B_2^aB_3^b)^\infty$ — which never uses
> the move $B_1$ — has an exactly computable speed $r(a,b)$ with $|r(a,b)-r|<\varepsilon$.

Together with the Silver Speed Limit, which caps every convergent speed by
$\log(1+\sqrt2)$, this pins down the closure of the *metric growth spectrum* of the
Pythagorean tree:
$$\overline{\{\text{realised speeds}\}} \;=\; \bigl[0,\;\log(1+\sqrt2)\bigr].$$
Every conceivable speed up to the silver limit occurs, or is approached arbitrarily
closely, by an explicit periodic path; and none exceeds it. Remarkably, the single move
$B_1$ is never needed: the whole spectrum is realised by paths built from $B_2$ and $B_3$
alone.

## What this buys you: the cost of finding a triple

The geometry is not decoration. It converts into arithmetic statements about how hard it
is to *find* a Pythagorean triple with a prescribed hypotenuse.

Reading the Silver Speed Limit backwards gives a lower bound on depth. If a node has
hypotenuse at least $N$, then $m \gtrsim \sqrt N$ and hence its depth satisfies
$$k \;\ge\; \frac{\log N-\log 2}{2\log(1+\sqrt2)}-1 .$$
Conversely the Pell spine reaches hypotenuse $N$ at depth at most
$\frac{\log N+\log 2}{2\log(1+\sqrt2)}$. So the minimal depth at which hypotenuse $N$
becomes available is
$$\frac{\log N}{2\log(1+\sqrt2)}+O(1),$$
constant-sharp. Descending the tree is an exponentially efficient way to manufacture large
triples — the address of a triple with a hundred-digit hypotenuse is only a few hundred
letters long — and no strategy inside the tree can do better than the silver rate.

The same inequality applied twice gives a statement about *collisions*. Two different
primitive triples can share a hypotenuse: $65^2=16^2+63^2=33^2+56^2$, and generally any
$N$ with several prime factors congruent to $1 \bmod 4$. Such a coincidence is not free:
if two nodes both have hypotenuse $N$, then the **sum** of their depths is at least
$$\frac{\log N-\log 2}{\log(1+\sqrt2)}-2 .$$
Coincidences deep in the tree require genuine depth from both participants. This is the
tree-level shadow of a familiar dichotomy: exhibiting a representation
$N=m^2+n^2$ is cheap once you know it — the address is short — but *finding* one is not,
and the tree gives no shortcut. A lopsided representation with $n$ tiny is reachable only
through a long parabolic run of $B_3$'s, and the geometry certifies that the run must be
long.

## The shape of the answer

Step back and the picture is unexpectedly clean. A ternary tree, a naive growth rate of
$\log 3$; a hyperbolic ruler that turns distance into $\log m$; three moves of which only
one is hyperbolic, with expansion equal to the silver ratio; and consequently a true
growth exponent $\log(1+\sqrt2)$, attained uniquely by the Pell spine, with the entire
interval $[0,\log(1+\sqrt2)]$ realised as the closure of achievable speeds — and the
frequency of the expanding move alone failing, decisively, to predict the speed.

The silver ratio is the golden ratio's quieter sibling: continued fraction
$[2;2,2,2,\dots]$, the growth rate of the Pell numbers $1,2,5,12,29,70,169,\dots$, the
number governing the $\sqrt2$-rectangle behind the A4 sheet of paper. Here it turns up as
a speed limit — the exact exchange rate between "one step down the Pythagorean tree" and
"distance travelled in hyperbolic space". Right triangles, it turns out, have a maximum
speed, and it is silver.
