# The Ruler That Never Repeats Itself

## A story about differences, greed, and a tower that turns out to be two towers in disguise

Imagine you are building a ruler. Not an ordinary ruler — a *sparse* one. You are allowed to
engrave only a handful of marks on it, and you want those marks placed so cleverly that no two
pairs of marks are ever the same distance apart. Measure from the first mark to the third, and
you get some length; measure from the second to the fifth, and you must get a *different* length.
Every distance your ruler can measure, it measures in exactly one way.

Rulers like this are called **perfect difference sets**, or **Sidon sets**, and they are among the
most stubbornly beautiful objects in combinatorics. They show up when radio engineers design
antenna arrays that avoid interference, when crystallographers place sensors, when cryptographers
look for sequences with flat correlation, and when number theorists ask how dense a set of
integers can be before it starts repeating itself.

This article is about what happens when you build such a ruler the laziest possible way: greedily,
one mark at a time, always taking the smallest legal position. And about a surprise that appears
when you try to generalise the idea from pairs of marks to $h$-tuples of marks: a hierarchy that
looks like it has two interleaved families of floors turns out to have only one, because the
"difference" floors land *exactly* on the even "sum" floors.

---

## Sums or differences? The same question wearing two hats

Start with a finite set of non-negative integers $A = \{a_1 < a_2 < \dots < a_k\}$. There are two
natural ways to ask that $A$ be non-repetitive.

**The difference version.** All the differences $a_i - a_j$ with $i \neq j$ are distinct. This is
the ruler picture: no distance is measurable twice.

**The sum version.** All the sums $a_i + a_j$ with $i \le j$ are distinct, apart from the trivial
reordering $a_i + a_j = a_j + a_i$. A set with this property is called a **Sidon set**, after
Simon Sidon, who introduced them in the 1930s while studying Fourier series.

These look like different demands, and over the natural numbers they even live in different
worlds: differences can be negative, so they escape from $\mathbb{N}$ into $\mathbb{Z}$, while sums
stay put. But they are the same demand. Rearranging is all it takes: the coincidence
$a - b = c - d$ is the coincidence $a + d = c + b$, read from a different angle. Formally:

> **Theorem (Sums versus differences).** A finite set $A \subseteq \mathbb{N}$ is a Sidon set if and
> only if the map $(a,b) \mapsto a - b$, taken with values in $\mathbb{Z}$, is injective on the
> pairs of *distinct* elements of $A$.

The proof is three lines of arithmetic, but the consequence is not cosmetic: it says that the two
greedy algorithms you might write — "add the smallest number that does not repeat a difference"
and "add the smallest number that does not repeat a sum" — are the *same algorithm*. They produce
the same ruler, mark for mark.

That ruler begins

$$0,\ 1,\ 3,\ 7,\ 12,\ 20,\ 30,\ 44,\ 65,\ 80,\ 96,\ 122,\ 147,\ 181,\ \dots$$

Add one to every term and you get the **Mian–Chowla sequence** $1, 2, 4, 8, 13, 21, 31, 45, \dots$,
first written down in 1944 and still, eighty years later, holding on to its secrets.

---

## The obstruction: a cubic cloud of forbidden numbers

Why is the greedy process even well defined? You need to know that a legal next mark always
exists. Here is the clean way to see it.

Suppose $A$ is already a Sidon set and $m$ is a candidate larger than everything in $A$. Adjoining
$m$ ruins the difference property exactly when $m$ repeats some distance: $m - c = d - b$ for some
$b, c, d \in A$. Rearranged, that says

$$m = c + d - b, \qquad b, c, d \in A.$$

So the entire failure mode is a single finite set of integers,

$$\mathrm{Bad}(A) = \{\,c + d - b \ :\ b, c, d \in A\,\},$$

a *cubic cloud*: at most $|A|^3$ numbers, one for each triple. And the criterion is exact, not
merely sufficient — for $m$ above $A$, the enlarged set $A \cup \{m\}$ is Sidon precisely when $A$
is Sidon and $m$ avoids the cloud.

Now the greedy step can never get stuck: among any $|A|^3 + 1$ consecutive integers above
$\max A$, at least one dodges the cloud. Summing these window widths stage by stage gives a first
growth bound for the greedy sequence $a(n)$ (the $n$-th mark, counting from $a(0) = 0$):

$$4\,a(n) \le (n+1)^4 .$$

Quartic. Correct, but wasteful — and the waste has a precise location.

---

## Greed is rigid, and rigidity buys you a whole degree

The waste is the phrase *"above $\max A$"*. The greedy rule always picks the smallest legal value,
so once you have chosen $n$ marks, could there be a legal value hiding *below* the largest one — a
gap the algorithm jumped over?

No. And that "no" is a theorem.

> **Theorem (Chain rigidity).** If $m$ is not already among the first $n$ greedy marks, and adding
> $m$ to them still yields a Sidon set, then $m$ is larger than every one of those marks.

The reason is a small piece of logical judo. Suppose such an $m$ sat below the last mark. Sidon-ness
is inherited by subsets, so $m$ would have been legal at some *earlier* stage too — and it is
smaller than what the algorithm actually chose there, contradicting the fact that the algorithm
chose the minimum. The greedy chain never skips a usable value; it is as tight as a chain can be.

Rigidity has a price and a payoff. The price: once you allow candidates *anywhere*, a second
obstruction wakes up. For a candidate below the current maximum, $m$ can collide with itself,

$$m + m = c + d, \qquad c, d \in A,$$

an equation that was automatically impossible when $m$ exceeded everything. This **halving
obstruction** is a much smaller cloud — at most $|A|^2$ numbers, the "midpoints" of $A$ — but it is
genuinely needed. The two-element set $A = \{0, 2\}$ with candidate $m = 1$ makes the point: $1$
avoids the cubic cloud entirely, yet $\{0,1,2\}$ is not Sidon, because $0 + 2 = 1 + 1$. And this is
not a small-set accident: doubling any greedy Sidon set of size $k$ and offering the candidate
$m = 1$ produces a counterexample of every size $k \ge 2$.

The payoff is a genuinely better bound. With rigidity in hand, you no longer add up one window per
stage; you do a *single* pigeonhole over the interval $\{0, 1, \dots, n^3 + n^2 + n\}$, whose length
comfortably exceeds the total size of both obstruction clouds plus the $n$ marks already used:

$$a(n) \le n^3 + n^2 + n .$$

Cubic, down from quartic — an entire degree, bought with a structural observation rather than a
sharper count.

From the other side, a classical counting bound for Sidon sets (a set with $k$ marks inside
$\{0, \dots, N-1\}$ needs $k(k-1) \le N-1$, because its $k(k-1)$ differences are distinct and all
fit in an interval of that length) pushes the greedy sequence *up*:

$$n(n+1) \le 2\,a(n).$$

So the greedy ruler is pinned between a quadratic floor and a cubic ceiling:

$$\frac{n(n+1)}{2} \ \le\ a(n) \ \le\ n^3 + n^2 + n .$$

The data suggest the truth is near the ceiling: $a(13) = 181$, against a floor of $91$ and a ceiling
of $2379$. Closing the gap is not a matter of counting the cloud better — the cloud really does have
about $n^3$ points. It is a matter of showing that those points are *spread out* rather than
clustered. That is a dispersion question, and it is open.

There is one more charming data point. At $n = 3$ the greedy marks $\{0, 1, 3\}$ form a *perfect*
difference set modulo $7$: every non-zero residue mod $7$ is hit exactly once by a difference. This
is the smallest of the celebrated Singer difference sets, the algebraic gold standard for Sidon
sets. At the very next step the magic evaporates: $\{0, 1, 3, 7\}$ is not a perfect difference set
modulo $13$ — the residue $5$ is never realised. Greed matches algebra for exactly one step.

---

## Climbing the tower: from pairs to $h$-tuples

Everything so far concerned *pairs*. The natural generalisation replaces $2$ by $h$.

> **Definition.** A finite set $A$ is a **$B_h$ set** if a multiset of $h$ elements of $A$ is
> determined by its sum: whenever $s$ and $t$ are multisets of $h$ elements of $A$ with the same
> total, $s$ and $t$ are the same multiset.

$B_1$ is no condition at all. $B_2$ is exactly the Sidon condition. Higher $h$ is progressively
harsher: you must forbid coincidences among all $h$-fold sums, so $B_h$ sets are automatically
$B_k$ sets for every $1 \le k \le h$ (pad the shorter multisets with copies of a fixed element and
cancel). This gives a descending tower

$$\dots \subseteq B_4 \subseteq B_3 \subseteq B_2 = \text{Sidon} \subseteq B_1 = \text{everything}.$$

Since the Sidon story had a difference formulation, the higher floors should have one too. Here it
is, written additively so that it makes sense over $\mathbb{N}$, where subtraction is treacherous:

> **Definition.** $A$ has **$h$-fold difference rigidity** if, for all multisets $s, t, s', t'$ of
> $h$ elements of $A$,
> $$\textstyle\sum s - \sum t = \sum s' - \sum t' \quad\Longrightarrow\quad s + t' = s' + t$$
> as multisets. In words: the numerical value of an $h$-fold difference determines the difference
> itself, symbols and all.

At $h = 1$ this is precisely "all differences $a - b$ are distinct" — that is, precisely the Sidon
condition again. So the difference tower and the sum tower share their ground floor. The natural
guess is that difference rigidity gives *new* floors interleaved between the old ones. Two easy
implications point that way:

- If $A$ is $B_{2h}$, it has $h$-fold difference rigidity. (Given the hypothesis, $s + t'$ and
  $s' + t$ are two multisets of $2h$ elements with equal sums, so $B_{2h}$ forces them equal.)
- If $A$ has $h$-fold difference rigidity, it is $B_h$. (Feed in the degenerate difference
  $\sum s - \sum t = \sum t - \sum s$; rigidity yields $s + s = t + t$, and cancellation gives
  $s = t$.)

Together: $B_{2h} \Rightarrow \mathrm{Diff}_h \Rightarrow B_h$. A sandwich, with a new layer
apparently trapped strictly between two known floors.

Except that it isn't.

---

## The collapse

> **Theorem (Collapse).** For every $h$, $h$-fold difference rigidity is *equivalent* to being a
> $B_{2h}$ set.

The missing implication is almost embarrassing once seen. Suppose $A$ has $h$-fold difference
rigidity and you are handed two multisets $u, v$ of $2h$ elements of $A$ with the same sum. Cut each
in half: write $u = s + t'$ and $v = s' + t$ with all four pieces of size exactly $h$. The equality
$\sum u = \sum v$ is literally the hypothesis of rigidity, and rigidity returns
$s + t' = s' + t$, that is, $u = v$. So $A$ is $B_{2h}$.

The intermediate layer was an illusion. Every $2h$-element multiset splits into halves, and that
splitting converts a $B_{2h}$ coincidence into a repeated $h$-fold difference. The two conditions
are the same condition seen from two sides — signs moved across an equals sign.

This is worth pausing on, because it explains the phenomenon we started with. Greedy avoidance of
*differences* produces exactly Sidon sets, not because the case $h = 1$ is special, but because
$\mathrm{Diff}_1 = B_2$ exactly. And it predicts the correct generalisation: to build a $B_{2h}$
set greedily, you should test for repeated *$h$-fold differences* rather than repeated $2h$-fold
sums — the same condition, but with a strictly smaller family of coincidences to check.

---

## Is the tower real? Three points say yes

A hierarchy is only interesting if its floors are distinct. Here the separating example is as small
as it can possibly be — three points suffice, at every level.

> **Theorem (Strictness).** For every $h \ge 1$, the set $T_h = \{0,\ 1,\ h+1\}$ is a $B_h$ set and
> is not a $B_{h+1}$ set.

The failure at level $h+1$ is a single relation, the most economical one imaginable: $h+1$ copies of
the element $1$ sum to the same total as one copy of $h+1$ padded with $h$ zeros,

$$\underbrace{1 + 1 + \dots + 1}_{h+1} \;=\; (h+1) + \underbrace{0 + \dots + 0}_{h}.$$

And $T_h$ *is* $B_h$ for a reason that will be familiar to anyone who has thought about place-value
notation: a multiset from $\{0, 1, h+1\}$ has sum $c_1 + (h+1)\,c_{h+1}$, where $c_x$ counts copies
of $x$. If the multiset has only $h$ elements then $c_1 \le h < h+1$, so $c_1$ is a legitimate
"digit" in base $h+1$ — and digits are unique. Carrying is what destroys uniqueness, and carrying
begins exactly at multiplicity $h+1$.

Because $\mathrm{Diff}_h = B_{2h}$, the same three points separate the difference layers as well:
avoiding repeated $h$-fold differences is strictly weaker than avoiding repeated $(h+1)$-fold
differences. Take $h = 2$ and you recover a fact one can also see by hand: the greedy Sidon set
$\{0, 1, 3\}$ is Sidon but not $B_3$, since $0 + 0 + 3 = 1 + 1 + 1$.

---

## Greed at every floor, and where the difficulty hides

The whole greedy machine lifts up the tower. For $B_h$, the failure of a candidate $m$ is a
**weighted, signed** equation: the new element appears on both sides with different multiplicities,
and after cancellation what remains is

$$d\cdot m + \Sigma_0 = \Sigma_1, \qquad 1 \le d \le h,$$

where $\Sigma_0, \Sigma_1$ are sums of at most $h$ elements of $A$. Since $m$ is determined by the
triple $(d, \Sigma_1, \Sigma_0)$, the bad set is finite and explicitly bounded: writing $S$ for the
set of all sums of at most $h$ elements of $A$, one has $|S| \le (h+1)(|A|+1)^h$ and at most
$h\,|S|^2$ bad candidates. Chain rigidity transports verbatim — it needs only that $B_h$-ness passes
to subsets and that earlier choices were minimal — and a single pigeonhole then gives

$$a_h(n) \ \le\ n + h\big((h+1)(n+1)^h\big)^2,$$

a bound of degree $2h$ (the naive per-step accumulation would give degree $2h+1$). Underneath, a
counting bound in the opposite direction: a $B_h$ set $A \subseteq \{0, \dots, N-1\}$ satisfies

$$\binom{|A|}{h} \ \le\ h(N-1) + 1,$$

because distinct $h$-element subsets have distinct sums and all those sums fit into
$\{0, 1, \dots, h(N-1)\}$; in usable form, $(|A| - h + 1)^h \le h!\,\big(h(N-1)+1\big)$, so
$|A| \lesssim (h!\,h\,N)^{1/h}$. For $h = 2$ this is the familiar $\sqrt{N}$. Applied to the greedy
set it yields $\binom{n+1}{h} \le h\,a_h(n) + 1$, a lower bound of degree $h$.

The single weight $d$ is where all the extra difficulty of the higher floors is concentrated. For
Sidon sets $d \in \{1, 2\}$, and the case $d = 2$ is exactly the halving obstruction that
disappears when the candidate is above the set. For general $h$, $d$ ranges over $1, \dots, h$ — the
signed multiplicity of the newcomer — and everything else is unchanged.

Numerically, the greedy $B_3$ and $B_4$ rulers begin

$$0,\ 1,\ 4,\ 13,\ 32,\ 71,\ 124,\ 218,\ 375 \qquad\text{and}\qquad 0,\ 1,\ 5,\ 21,\ 55,\ 153,\ 368,\ 856,$$

(the classical listings, shifted by one) and they grow visibly faster than the Sidon ruler, as the
counting bound insists they must. Between the proved degree-$h$ floor and degree-$2h$ ceiling, the
data hint at degree $2h - 1$.

---

## Why any of this matters

The narrow moral is that a hierarchy nobody had reason to doubt turned out to be a duplicate of one
already known: the difference layers do not interleave with the sum layers, they *coincide* with the
even ones. Hierarchies collapse more often than we expect, and the way to find out is to try to
separate two adjacent floors and watch the attempt fail informatively.

The wider moral is about greed. Greedy algorithms are usually analysed as if each step were an
isolated local decision, which is why their bounds accumulate. But a greedy chain remembers its own
past: the fact that nothing was skipped earlier is a *global* constraint on what can happen later.
Cashing that memory in — a single pigeonhole instead of a sum of windows — removed a full degree
from the growth bound for Sidon sets, and a full degree at every floor of the tower. The technique
is not about Sidon sets at all; it applies whenever the property being maintained is inherited by
subsets, which is to say, almost always.

And the ruler? It is still out there, $0, 1, 3, 7, 12, 20, 30, 44, \dots$, growing at a rate nobody
can pin down, squeezed between $n^2/2$ and $n^3$, with every measurement it makes unrepeatable.
