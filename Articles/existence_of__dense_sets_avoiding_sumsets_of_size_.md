# The Sumsets You Cannot Escape

## A dense set of numbers always hides a perfect grid — and we now know exactly how big

Pick a million whole numbers between $1$ and two million. You are free to choose them
however you like: primes, squares, random numbers, numbers whose binary expansion spells
your name. Your set $S$ is *half dense* — it contains half of everything available.

Here is a question that sounds like it should have an easy answer, and doesn't.

Must your set contain a **sumset**? That is, must there exist two sets of numbers
$A = \{a_1,\dots,a_k\}$ and $B = \{b_1,\dots,b_k\}$ such that *every one of the $k^2$ sums*
$a_i + b_j$ lands inside $S$?

A sumset $A + B = \{a + b : a \in A,\ b \in B\}$ is an extremely rigid object. It is a
$k \times k$ grid of numbers, an additive multiplication table. Any two of its rows differ
by a constant shift; the whole thing is determined by $2k$ numbers but constrains $k^2$ of
them. Asking a set to contain a big sumset is asking it to contain a large, perfectly
regular additive pattern. Sets that look random, one feels, should be able to dodge such a
pattern.

They cannot. And the point at which dodging becomes possible is now pinned down with an
exact constant.

---

## The two forces

Write $[n] = \{0, 1, \dots, n-1\}$ and call a set $S \subseteq [n]$ **$\delta$-dense** if
$|S| \ge \delta n$. The whole story is a tug of war between two effects.

**Force one: pigeonholing.** A dense set has a lot of internal structure it cannot help
having. If $|S| = \delta n$, then among the $2n$ possible shifts $a$ with $-n < a < n$, the
*average* number of elements $u \in S$ with $u + a \in S$ is $\delta |S|$. Some shift must
do at least as well as the average. So there is a shift $a$ keeping a $\delta$-fraction of
$S$ inside $S$. Do it again with a different shift, and a $\delta$-fraction of *that*
survives. After $k$ shifts the surviving set has size roughly $\delta^{k} |S| = \delta^{k+1} n$,
which is still positive as long as
$$\delta^{k} n \ge 1, \qquad \text{i.e.} \qquad k \le \frac{\log n}{\log (1/\delta)}.$$
And the surviving set $B$, together with the collected shifts $A = \{a_1,\dots,a_k\}$, gives
exactly the grid we wanted: $A + B \subseteq S$.

**Force two: counting.** Grids are rare. A pair of arithmetic progressions of length $k$
inside $[n]$ is specified by a handful of parameters — a starting point and two common
differences, so at most $n^3$ possibilities. Each such pair produces a sumset with at
least $2k$ distinct points. If we choose $S$ by picking $\delta n$ elements of $[n]$ at
random, the chance that a *particular* set of $2k$ points is entirely swallowed by $S$ is
about $\delta^{2k}$. So the expected number of grids inside $S$ is at most
$n^3 \delta^{2k}$, which is less than $1$ once
$$k \ \ge \ \frac{3}{2}\cdot\frac{\log n}{\log(1/\delta)} .$$
Then *some* $\delta$-dense set contains no such grid at all.

Both forces produce the same shape, $\log n / \log(1/\delta)$. Only the constant in front
differs: $1$ from below, $3/2$ from above. The gap between them is the whole game.

---

## Closing the gap

The upper side, $3/2$, is wasteful in a way that takes a moment to see. When we counted
the "cost" of a grid, we credited it with only $2k$ points — the L-shaped skeleton
$\{a_1 + b_j\} \cup \{a_i + b_1\}$. That is honest only when the two progressions have the
*same* common difference. If $A$ marches in steps of $d_1$ and $B$ in steps of $d_2$, write
$d_1 = g e_1$ and $d_2 = g e_2$ with $e_1, e_2$ coprime. Then the sumset
$$A + B = \{a + b + g(i e_1 + j e_2) : 0 \le i, j < k\}$$
is much fatter than an L: because $e_1$ and $e_2$ are coprime, the numbers
$i e_1 + j e_2$ take many distinct values, and the sumset contains a full
$k \times \min(\max(e_1,e_2),\,k)$ rectangular block. It has roughly $k \cdot Q$ points,
where $Q = \max(e_1, e_2)$.

Meanwhile, the number of parameter choices producing a given ratio $Q$ does not grow with
$Q$: it stays $O(n^2)$. So instead of paying $n^3$ once, we pay $n^2$ for each $Q$ and are
rewarded with a witness of $\max(2k-1,\ k\min(Q,k))$ points. The union bound becomes a
*geometric series*,
$$\sum_{Q \ge 1} 2n^2\,\delta^{\max(2k-1,\ k\min(Q,k))},$$
dominated by its first term $2n^2\delta^{2k-1}$, and this drops below $1$ precisely when
$$k \ >\ (1+o(1))\,\frac{\log n}{\log(1/\delta)} .$$
One factor of $n$ has simply vanished from the count: the ratio of the two common
differences is no longer a free parameter, because whenever it is nontrivial the grid it
produces is a fat block rather than a thin L. That is the whole improvement, and it is
exactly enough.

> **Theorem (Avoidance at constant $1$).** *Fix $0 < \delta < 1$ and $\varepsilon > 0$.
> For all sufficiently large $n$ there is a set $S \subseteq [n]$ with $|S| \ge \delta n$
> containing no sumset $A + B$ in which both $A$ and $B$ contain an arithmetic progression
> of length at least $(1 + \varepsilon)\log n / \log(1/\delta)$.*

On the other side, the pigeonhole argument as sketched above actually loses a factor of
two, because the shift window $(-n, n)$ has $2n$ elements while $S$ lives in a window of
only $n$. That loss can be removed by a trick: run the greedy process not from all of $S$,
but from the part of $S$ inside a short sub-interval of length $w \ll n$. Then only shifts
in a window of length $n$ are ever needed, and a pigeonhole choice of the sub-interval
keeps a proportional share of $S$ — costing a constant factor, which is invisible in the
exponent. The result is a matching lower bound with no loss at all.

> **Theorem (Existence at constant $1$).** *Fix $0 < \delta < 1$ and any $c > 0$ with
> $c \log(1/\delta) < 1$. For all sufficiently large $n$, **every** set $S \subseteq [n]$
> with $|S| \ge \delta n$ contains a sumset $A + B$ with
> $|A| = |B| = \lfloor c \log n \rfloor$.*

Put together: for pairs of sets that are rich in arithmetic progressions, the threshold
is
$$\boxed{\ (1 + o(1))\,\frac{\log n}{\log(1/\delta)}\ }$$
— an exact constant, where the previously recorded constant was $3$.

In a finite abelian group the geometry is even cleaner. There is no boundary, so no window
loss to fight: every $\delta$-dense subset of a finite abelian group $G$ contains a sumset
$A + B$ with $|A| = |B| = \lfloor c \log |G| \rfloor$ for any $c < 1/\log(1/\delta)$, once
$|G|$ is large. The constant $1$ is intrinsic to the problem, not an artefact of intervals.

---

## The engine: one identity, iterated

Everything above rests on a single, almost embarrassingly simple identity. Let $S$ be our
set and let $D$ be any collection of shifts large enough to contain every difference
$s - u$ of elements of $S$. For any $U \subseteq S$,
$$\sum_{a \in D} \#\{u \in U : u + a \in S\} \ = \ |U| \cdot |S|.$$
The proof is a change of perspective: fix $u \in U$ and let $a$ range over $D$; the shifted
point $u + a$ runs over every element of $S$ exactly once, contributing $|S|$. Summing over
$u \in U$ gives $|U||S|$.

From the identity to the theorem is three lines of bookkeeping. If we have already used
some set $F$ of shifts, the used ones contribute at most $|F| \cdot |U|$ to the sum, so the
best *unused* shift $a$ satisfies
$$\#\{u \in U : u + a \in S\} \ \ge\ \frac{|U|\,(|S| - |F|)}{|D|}.$$
Iterating $k$ times from $U_0 = S$ yields shifts $a_1, \dots, a_k$ and a survivor set $U_k$
with
$$|U_k| \ \ge\ |S| \left(\frac{|S| - k}{|D|}\right)^{k}.$$
Every element of $U_k$ can be shifted by every $a_i$ and stay inside $S$; so if $|U_k| \ge k$
we may pick $B \subseteq U_k$ of size $k$, set $A = \{a_1,\dots,a_k\}$, and we have our grid.
The single clean criterion is:
$$k\,|D|^{k} \ \le\ |S|\,(|S| - k)^{k} \quad\Longrightarrow\quad S \supseteq A + B,\ |A| = |B| = k.$$
No probability, no asymptotics, no hidden constants — just counting. Feed in $|D| = 2n$
and $|S| = \delta n$ and out comes the bound $k \approx \log n / \log(2/\delta)$; feed in
the short-window refinement and the $2$ disappears.

Because the criterion is exact, it can be checked on concrete numbers. For instance:

* **every** set of $524{,}288$ integers below $1{,}048{,}576$ (density $1/2$) contains a
  sumset $A + B$ with $|A| = |B| = 7$ — a $7 \times 7$ additive grid, all $49$ sums inside;
* **every** set of $524{,}288$ integers below $4{,}194{,}304$ (density $1/8$) contains a
  sumset with $|A| = |B| = 4$.

No matter how cunningly you choose your million numbers, the grid is there.

---

## Cubes: the same engine, iterated on itself

There is a second family of patterns that the same machine produces, and it is arguably
more striking. An **affine cube of dimension $d$** is a set of the form
$$u + \{0, a_1\} + \{0, a_2\} + \cdots + \{0, a_d\}
= \Big\{\, u + \sum_{i \in I} a_i \ :\ I \subseteq \{1,\dots,d\} \,\Big\},$$
a $d$-fold sumset of two-element sets. For $d = 2$ it is the quadruple
$u,\ u+a,\ u+b,\ u+a+b$: a "parallelogram" of integers. For general $d$ it is a shadow of
a $d$-dimensional hypercube laid down on the number line, with $2^d$ vertices.

Iterating the greedy shift step *on the surviving set itself* — rather than on $S$ — grows
a cube one dimension at a time. Each step squares the density loss: if the survivor set has
density $\rho$, the next one has density about $\rho^2$. So after $d$ steps the density is
$\delta^{2^d}$, and the process runs out of room when $\delta^{2^d} n \approx 1$. That gives
the following clean criterion.

> **Theorem (Cubes in dense sets).** *Let $S \subseteq [0,n)$ with $|S| \ge \delta n$.
> If $(4/\delta)^{2^d} \le 2n$ — equivalently
> $d \le \log_2\!\big(\log (2n) / \log(4/\delta)\big)$ — then $S$ contains an affine cube
> of dimension $d$ with all generators $a_i \ne 0$.*

A cube can be degenerate: taking $a_1 = a_2$ collapses it to a three-term progression. A
refinement of the argument, in which each newly chosen shift is forbidden from lying in the
difference set of the cube built so far, produces **proper** cubes, those whose $2^d$
subset sums are all distinct. The cost is only a factor $4^d$ in the criterion,
$(4/\delta)^{2^d}\cdot 4^d \le 2n$, which is nothing on the scale $2^d \approx \log n$.

Notice the doubly logarithmic dimension: $d \approx \log_2 \log n$. That looks weak until
you see the matching bound. A $d$-dimensional cube in $[n]$ is described by $d+1$
parameters — the base point and the $d$ generators — so there are at most $n^{d+1}$ of
them, while each proper one forces $2^d$ points to lie in $S$. The first moment
$n^{d+1}\delta^{2^d}$ drops below $1$ exactly when
$$2^d \ \gtrsim\ (d+1)\,\frac{\log n}{\log(1/\delta)},$$
and beyond that dimension there really are $\delta$-dense sets with no proper cube. So the
critical dimension is $\log_2\log n$ up to the additive $\log_2(d+1)$: the existence and
avoidance ranges of $d$ are provably disjoint, and both sit at $2^d \asymp \log n/\log(1/\delta)$.

One can even do the union bound over all dimensions at once. Since $n^{d+1}\delta^{2^d}$
shrinks geometrically as $d$ grows, a *single* $\delta$-dense set $S \subseteq [n]$ avoids
proper cubes of **every** dimension $d \ge d_0$ simultaneously, whenever
$(1+\varepsilon)(d_0+1)\log(4n) \le 2^{d_0}\log(1/\delta)$.

Again, concrete instances follow from the exact criterion: every set of $2048$ integers
below $4096$ contains a parallelogram $u, u+a, u+b, u+a+b$ with $a, b \ne 0$; every set of
$16{,}384$ integers below $32{,}768$ contains one with all four points distinct.

---

## Why this matters

The tension exposed here is a miniature version of one of the organising themes of modern
combinatorics: **density forces structure, but only so much of it.** Szemerédi's theorem
says a set of positive density contains arbitrarily long arithmetic progressions; Behrend's
construction says the density required grows quickly. Ramsey theory says order is
unavoidable; probabilistic constructions say it is unavoidable only at a specific scale.
Every such pair of results defines a threshold, and mathematics gets interesting exactly
at the threshold.

What is unusual here is that the threshold has been located with an *exact leading
constant*, from both sides, by two arguments that could hardly be more different in flavour
— a deterministic greedy pigeonhole on one side, a weighted first-moment count on the other
— and that the greedy side is entirely constructive: it does not merely assert that the
grid exists, it tells you how to find it, one shift at a time, each shift chosen by
maximising a count you can compute.

The cube results connect the same engine to Szemerédi's cube lemma, the combinatorial
statement (a cornerstone of the first proofs of density Hales–Jewett type results and of
Hilbert's cube lemma tradition) that dense sets contain affine cubes. Getting it from the
same three-line averaging identity, with a matching counting bound and with properness
thrown in, is a satisfying unification: two apparently different regularity phenomena —
a $k \times k$ grid and a $d$-dimensional cube — are the same greedy process, run either
$k$ times on the original set or $d$ times on its own output.

And in the end the answer to the opening question is short. Your million numbers below two
million contain a $7 \times 7$ additive grid, and they contain a parallelogram — both of
these are exact, fully checked consequences of the counting criterion. Asymptotically the
guarantee is far stronger: for a half-dense set in $[n]$ the theorems promise a grid of
size $|A| = |B| \approx \log n / \log 2$, which for $n = 2\times 10^6$ is about $21$. The
escape route opens only just beyond that — and now we know precisely where.
