# The Loneliest Numbers in Pascal's Triangle

Draw the triangle. Put a $1$ at the top, a $1$ at each end of every row, and make every other entry the sum of the two numbers leaning over it. You get the most famous array in mathematics:

$$
\begin{array}{ccccccccc}
 & & & & 1 & & & & \\
 & & & 1 & & 1 & & & \\
 & & 1 & & 2 & & 1 & & \\
 & 1 & & 3 & & 3 & & 1 & \\
1 & & 4 & & 6 & & 4 & & 1
\end{array}
$$

Its entries are the binomial coefficients $\binom{n}{k}$: row $n$, position $k$, counting the ways to choose $k$ things out of $n$. Every schoolchild meets it; every combinatorialist lives in it.

Now ask a question that sounds childish and turns out to be brutally hard. **Pick a number. How many times does it appear?**

The $1$s are cheating: every row begins and ends with one, so $1$ appears infinitely often. Set it aside. Then the arithmetic becomes strange and beautiful:

- $2$ appears **once**, at the apex of its own row.
- $3$, $4$, $5$, $7$, $11$, $13$, $\dots$ — every prime, and plenty of composites — appear **exactly twice**, as $\binom{t}{1}$ and $\binom{t}{t-1}$.
- $6$ appears **three** times: $\binom{4}{2}$ joins the pair $\binom{6}{1}, \binom{6}{5}$.
- $10$ appears **four** times: $\binom{5}{2} = \binom{5}{3} = 10$ as well as $\binom{10}{1}, \binom{10}{9}$.
- $120$ appears **six** times: $\binom{10}{3}, \binom{10}{7}, \binom{16}{2}, \binom{16}{14}, \binom{120}{1}, \binom{120}{119}$.
- $3003$ appears **eight** times, the current world record: $\binom{14}{6}, \binom{14}{8}, \binom{15}{5}, \binom{15}{10}, \binom{78}{2}, \binom{78}{76}, \binom{3003}{1}, \binom{3003}{3002}$.

And nobody has ever found a number appearing exactly five times, or exactly seven, or nine, or more than eight. In 1971 David Singmaster asked the question everybody now asks: **is there an absolute ceiling?** Is there a constant $C$ such that no number other than $1$ ever appears more than $C$ times? Singmaster guessed yes — perhaps even $C = 8$, or $C = 10$. Fifty years later this is still open.

What follows is a tour of what *can* be proved, and of two theorems that pin down the phenomenon far more tightly than a first look suggests: a **smoothness hierarchy** saying that repetition forces a number to be built out of tiny primes, and a **complete classification** of the mechanism that produces the six-fold repetitions — a mechanism that turns out to be governed, exactly and with no exceptions, by the Fibonacci numbers.

---

## The multiplicity function, and why it is finite

Write $N(t)$ for the number of positions $(n,k)$ with $0 \le k \le n$ and $\binom{n}{k} = t$. For $t \ge 2$ this is a finite number, and the reason is a two-line argument worth savouring, because everything else in this story is a refinement of it.

Suppose $\binom{n}{k} = t$ with $2 \le k \le n-2$ — call this an *interior* occurrence, one that is not on the two outer diagonals. Pascal's rows increase towards the middle, so
$$
\binom{n}{2} \le \binom{n}{k} = t,
\qquad\text{i.e.}\qquad
n(n-1) \le 2t .
$$
The row index is at most about $\sqrt{2t}$. Meanwhile $2^{k} \le \binom{n}{k} = t$ whenever $2k \le n$, so the column index is at most $\log_2 t$. Every interior occurrence of $t$ therefore lives in a box of size roughly $\sqrt{2t} \times \log_2 t$. Finitely many boxes, finitely many occurrences. Combined with the fact that each column can host at most one row (entries strictly increase down a fixed column), this already gives the classical bound
$$
N(t) \;\le\; 2\log_2 t .
$$

That is the crude ceiling everybody starts with. It is enormously far from the truth — for $t = 3003$ it permits $22$ occurrences and the real answer is $8$ — but it is unconditional and elementary, and it can be sharpened.

**A better logarithmic ceiling.** The estimate $2^{k} \le \binom{n}{k}$ throws away most of the size of a binomial coefficient. The genuinely smallest entry with folded column index $b$ (where "folded" means $b = \min(k, n-k)$, since $\binom{n}{k} = \binom{n}{n-k}$) is the central coefficient $\binom{2b}{b}$, which is about $4^{b}/\sqrt{b}$, not $2^{b}$. And a free pigeonhole argument delivers a usable version of that: the $2b+1$ entries of row $2b$ sum to $4^{b}$ and none exceeds the middle one, so
$$
4^{b} \le (2b+1)\binom{2b}{b}.
$$
Feeding this into the counting argument replaces powers of two by powers of four and halves the leading constant:

> **Theorem (sharpened logarithmic bound).** For every $t \ge 2$,
> $$N(t) \;\le\; \log_2\!\big((2\log_2 t + 1)\,t\big) \;\le\; \log_2 t + \log_2(2\log_2 t + 1) + 1 .$$
> In particular $N(t) < 2\log_2 t$ as soon as $t \ge 2^{16}$.

For $t = 3003$ the ceiling drops from $22$ to $16$; for $t < 10^{6}$, from $38$ to $25$. The leading constant is now $1$, which is exactly what the heuristic "one new column per power of four" predicts. It is still infinitely far from a *constant* bound, but it is the correct elementary shape.

---

## Repetition forces smoothness

Here is the observation that changes the character of the problem. Look again at the record holders: $6 = 2\cdot 3$, $10 = 2 \cdot 5$, $120 = 2^3\cdot 3\cdot 5$, $3003 = 3\cdot 7\cdot 11\cdot 13$. Small primes only. That is not an accident.

Combine the two facts we already have. If $\binom{n}{k} = t$ is an interior occurrence, then $n(n-1) \le 2t$ — the row is small. On the other hand $\binom{n}{k}$ divides $n!$, so *every prime factor of $t$ is at most $n$*. Chain them:

> **Smoothness Theorem.** If $t \ge 3$ occurs three or more times in Pascal's triangle, then every prime factor $p$ of $t$ satisfies
> $$p(p-1) \le 2t, \qquad\text{hence}\qquad p \le \sqrt{2t} + 1 .$$

Contrapositively: *a number with one large prime factor occurs exactly twice.* If $t \ge 3$ has a prime factor $p$ with $p(p-1) > 2t$, then $N(t) = 2$, full stop. This one statement subsumes a whole zoo of facts. Every prime $p \ge 5$ occurs exactly twice (take $p$ itself as the large factor). So does $2p$ for every prime $p \ge 7$ — note the two exceptions $2\cdot 3 = 6$ and $2\cdot 5 = 10$ at the very bottom, precisely where the inequality fails. More generally $N(c\,p) = 2$ for every $c \ge 1$ and every prime $p > 2c+1$. Since there are infinitely many primes, **every divisibility class contains infinitely many numbers of multiplicity exactly two**: no matter which $c$ you fix, infinitely many multiples of $c$ appear precisely twice.

And the theorem has an infinite tower of floors above it. To occur $2m+2$ times, a number needs $m$ genuinely interior occurrences to the left of centre. Distinct interior occurrences sit in distinct columns — a fixed column's entries strictly increase as you go down — so those $m$ columns, all at least $2$, cannot all be small: some occurrence must sit in a column $k \ge m+1$. Now repeat the chaining, but with $\binom{n}{m+1}$ in place of $\binom{n}{2}$:

> **Smoothness Hierarchy.** If $t$ occurs at least $2m+2$ times, then every prime factor $p$ of $t$ satisfies
> $$\binom{p}{\,m+1\,} \le t, \qquad\text{equivalently}\qquad (p-m)^{m+1} \le (m+1)!\,t .$$

Unwind the levels. Multiplicity $\ge 4$ means $p \lesssim \sqrt{2t}$; multiplicity $\ge 6$ means $p(p-1)(p-2) \le 6t$, so $p \lesssim (6t)^{1/3}$; multiplicity $\ge 8$ means $p \lesssim (24t)^{1/4}$. A number that repeats a lot must be **extraordinarily smooth** — assembled almost entirely from primes below a small root of itself.

Test it on the champion. Since $3003$ occurs eight times, the level $m=3$ applies: every prime factor $p$ of $3003$ must satisfy $\binom{p}{4} \le 3003$. Now $\binom{18}{4} = 3060 > 3003$, so no prime factor can reach $18$: every prime dividing $3003$ is at most $17$. And indeed $3003 = 3\cdot 7\cdot 11\cdot 13$, with largest factor $13$, just under the wire. The theorem *sees* the structure of Singmaster's record holder.

This is why a proof of Singmaster's conjecture feels tantalisingly close. Smoothness fights against size: to be $t^{1/(m+1)}$-smooth, a number of size $t$ must be a product of *many* small primes, and there are only so many small primes to go around. Making that tension quantitative is, essentially, the open problem.

---

## Almost every number appears exactly twice

Whatever the true ceiling is, the *typical* behaviour can be settled completely, and the same geometry does it. A number $t \le X$ with $N(t) \ge 3$ must have an interior occurrence $\binom{n}{k}$ with $2 \le k$ and $2k \le n$. Then $n \le \sqrt{2X}+1$ and $k \le \log_2 X$: all such $t$ are values of $\binom{n}{k}$ on one explicit rectangular box of positions. Counting the box:

> **Counting Theorem.** For every $X$,
> $$\#\{\,t \le X : N(t) \ge 3\,\} \;\le\; \big(\sqrt{2X}+2\big)\big(\log_2 X + 1\big) .$$
> Consequently, for every constant $c$ there is a threshold beyond which fewer than $X/c$ of the integers up to $X$ occur three or more times: **the integers of multiplicity exactly two have density one.**

Below $10^{6}$ the bound permits $28\,320$ exceptional numbers; the true count is $1\,732$ — about one integer in six hundred. The full census below a million is startlingly lopsided: $998\,266$ numbers occur exactly twice, $1\,715$ occur four times, ten occur three times, six occur six times ($120$, $210$, $1540$, $7140$, $11628$, $24310$), and exactly one occurs eight times. Five, seven, and nine or more: never. Repetition in Pascal's triangle is a measure-zero phenomenon: the triangle is, overwhelmingly, a list of distinct numbers with each one duplicated on the two outer diagonals and nowhere else.

---

## How early can a multiplicity appear?

The classical specimens $6, 10, 120, 3003$ are famous as *examples*. It is a sharper — and more useful — statement that they are the **first** examples.

> **Sharp Thresholds.** Among integers $t \ge 2$:
> - $6$ is the smallest with $N(t) \ge 3$;
> - $10$ is the smallest with $N(t) \ge 4$;
> - $120$ is the smallest with $N(t) \ge 6$;
> - $3003$ is the smallest with $N(t) \ge 8$.
>
> More generally, $N(t) \ge 2m+2$ forces $t \ge \binom{2m+3}{m+1}$.

The general bound is soft — it gives only $t \ge 10, 35, 126$ for multiplicities $4, 6, 8$ — while the sharp values are $10, 120, 3003$. The gap is where the real arithmetic lives. Take the multiplicity-six threshold. Six occurrences force two interior occurrences $\binom{n}{j} = \binom{m}{k} = t$ in distinct columns $2 \le j < k$. If $k \ge 4$, unimodality alone gives $t \ge \binom{9}{4} = 126$. Otherwise $k = 3$ and $j = 2$, so $t$ must be simultaneously a triangular number $\binom{n}{2}$ and a "tetrahedral-type" number $\binom{m}{3}$ with $m \ge 7$; the only candidates below $120$ are $35, 56, 84$, and none of them is triangular. Hence $t \ge 120$ — a genuine two-parameter descent with a three-number residue, not a blind search.

The multiplicity-eight threshold runs the same descent one level deeper: eight occurrences force *three* interior columns, so the largest is at least $4$; unimodality then caps that column at $6$ and both rows at $78$, and inside that small box no coincidence $\binom{n}{j} = \binom{m}{k}$ below $3003$ survives. (The box is not empty of near-misses: $210 = \binom{10}{4} = \binom{21}{2}$ has one smaller column and is eliminated only by the demand for a *second* one.)

---

## The Fibonacci machine behind the sixes

Where do the numbers with six occurrences come from? There is a single elegant mechanism, and it is the most surprising part of the story.

A generic number $t$ with one interior occurrence $\binom{n}{k}$ has four positions: $\binom{t}{1}$, $\binom{t}{t-1}$, $\binom{n}{k}$, $\binom{n}{n-k}$. To get six, you need a *second* interior occurrence. The cheapest way for nature to arrange one is an **adjacent repetition**: a value that reappears one row higher and one column to the right,
$$
\binom{n}{k} = \binom{n-1}{k+1}.
$$
The first instance is $\binom{15}{5} = \binom{14}{6} = 3003$ — the very coincidence that makes $3003$ the record holder. Any adjacent repetition instantly yields six positions: the two outer ones, the mirror pair in row $n$, and the mirror pair in row $n-1$.

Which pairs $(n,k)$ do this? Clearing factorials in the two Pascal recurrences turns the question into pure arithmetic:

> **Dictionary.** For $1 \le k$ and $k+2 \le n$,
> $$\binom{n}{k} = \binom{n-1}{k+1} \iff n(k+1) = (n-k)(n-k-1).$$

Now substitute. Write $u = n-k$ for the "gap", and set $N = 5n+1$, $U = 5u-3$. The quadratic condition becomes
$$
N^2 - NU - U^2 = -5 ,
$$
the **norm form of the golden ratio field** $\mathbb{Q}(\sqrt5)$ — the very same form whose $\pm 1$ solutions are consecutive Fibonacci numbers. And its $\pm 5$ solutions can be classified outright, by an old and completely elementary trick: the descent $(x,y) \mapsto (y, x-y)$ sends a solution to a solution, flips the sign of the form, and strictly decreases the first coordinate. Run it downhill and every solution funnels to the same bottom, $(x,y) = (1,2) = (L_1, L_0)$. Run it uphill and you generate the Lucas numbers $2, 1, 3, 4, 7, 11, 18, 29, 47, 76, 123, \dots$ (same rule as Fibonacci, different start).

> **Theorem (all solutions of the norm form).** Every pair of natural numbers with $x^2 - xy - y^2 = \pm 5$ is a pair of consecutive Lucas numbers $(L_{i+1}, L_i)$, with the sign alternating: $L_{i+1}^2 - L_{i+1}L_i - L_i^2 = 5(-1)^{i+1}$.

A little congruence bookkeeping — the Lucas sequence is $2, 1, 3, 4$ modulo $5$ with period four, so the divisibility conditions hidden in $N = 5n+1$ and $U = 5u-3$ select exactly one index in four — completes the classification:

> **Classification of adjacent repetitions.** For $1 \le k$ and $k+2 \le n$, the identity $\binom{n}{k} = \binom{n-1}{k+1}$ holds **if and only if**
> $$5n+1 = L_{4j+9} \quad\text{and}\quad 5(n-k) = L_{4j+8}+3$$
> for some $j \ge 0$.

Every index $j$ really does produce a solution, so there are infinitely many of them, and their values are unbounded. That is the classical source of infinitely many numbers occurring at least six times.

The Lucas description is complete, but there is a second, older-looking face of the same family, and the two can be identified exactly. The bridge is **Cassini's identity**, the little gem $F_{a+1}^2 - F_aF_{a+2} = (-1)^a$, which drives a simultaneous induction proving the dictionary
$$
L_{2a} = 5F_a^2 + 2(-1)^a, \qquad L_{2a+1} = 5F_aF_{a+1} + (-1)^a .
$$
Setting $a = 2i+4$ converts the Lucas parametrisation into a Fibonacci one, and the classification takes its final, memorable form:

> **The Fibonacci family is complete.** For $1 \le k$ and $k+2 \le n$,
> $$\binom{n}{k} = \binom{n-1}{k+1} \iff (n,k) = \big(F_{2i+4}F_{2i+5},\; F_{2i+2}F_{2i+5}\big) \text{ for some } i \ge 0 .$$

There are no others. None. The complete list of adjacent repetitions in Pascal's triangle begins
$$
(15,5),\quad (104,39),\quad (714,272),\quad (4895,1869),\quad \dots
$$
and continues forever along the Fibonacci numbers and nowhere else. The classical family, known since Singmaster's era to *contain* solutions, is now known to contain *all* of them.

Two corollaries are worth stating. First, the column of an adjacent repetition is a fixed proportion of its row: the Diophantine equation forces $n < 4(k+1)$, and asymptotically $k/n \to (3-\sqrt5)/2 \approx 0.382$ — the golden ratio, again, controlling where in the triangle these coincidences may sit. Second, and this explains a famous empirical fact: **only the first member of the family has a value below a million**, and that value is $\binom{15}{5} = 3003$. The next one, $\binom{104}{39}$, has $29$ digits. That is the structural reason $3003$ reigns as the most repetitive number below $10^{6}$ — not luck, but the exponential growth of the Fibonacci numbers.

---

## What is still missing

Put the pieces together and the picture is sharp everywhere except at the one point that matters. We know almost every number occurs exactly twice. We know that occurring often forces extreme smoothness, at every level of an infinite hierarchy. We know the smallest number of each small multiplicity — $6, 10, 120, 3003$ — and we know the *entire* infinite family of adjacent repetitions that manufactures multiplicity six.

What we do not know is a constant. Singmaster's conjecture — that $N(t)$ is bounded — remains open, and so do the sharper folklore versions: that no number occurs exactly five or exactly seven times, and that $3003$ is the unique number occurring eight times.

The odd multiplicities have a pretty reduction. Occurrences come in mirror pairs $\binom{n}{k} = \binom{n}{n-k}$, so
$$
N(t) = 2 + 2\cdot\#\{\text{left-interior occurrences}\} + \#\{\text{central occurrences}\},
$$
and a value can be central — $t = \binom{2c}{c}$ — for at most one $c$. Odd multiplicity therefore *requires* $t$ to be a central binomial coefficient. "No number occurs exactly five times" is thus equivalent to: no central binomial coefficient $\binom{2c}{c}$ has exactly one further non-central interior occurrence. That is a Diophantine question of exactly the same shape as the one the golden-ratio descent solved completely — which is precisely what makes it look attackable.

And for the grand conjecture, the shape of an eventual proof is visible: multiplicity at least $2m+2$ forces $\binom{p}{m+1} \le t$ for every prime $p \mid t$, so $t$ must be $t^{1/(m+1)}$-smooth; but building an integer of size $t$ out of primes below $t^{1/(m+1)}$ requires at least about $\log t/\log\log t$ prime factors, and each of them costs size. Somewhere in the collision between "smooth enough" and "large enough" lies the constant Singmaster asked for in 1971.

Until someone finds it, the triangle keeps its small secret: a number chosen at random appears twice, a rare number appears three, four or six times, exactly one known number appears eight times — and five and seven, so far as anyone can tell, never happen at all.
