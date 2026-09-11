# The Loneliest Number in Pascal's Triangle

## A puzzle you can see

Write down Pascal's triangle — each number the sum of the two above it — and stare at it for a while.

$$
\begin{array}{c}
1\\
1\quad 1\\
1\quad 2\quad 1\\
1\quad 3\quad 3\quad 1\\
1\quad 4\quad 6\quad 4\quad 1\\
1\quad 5\quad 10\quad 10\quad 5\quad 1\\
\end{array}
$$

Ignore the border of $1$'s, which repeats forever and is therefore boring. Every other number you see, say $10$, appears somewhere. How many times? Ten shows up twice in row five, as $\binom{5}{2}$ and $\binom{5}{3}$, and it also shows up as $\binom{10}{1}$ and $\binom{10}{9}$ far down the left and right edges — because *every* integer $n$ appears at least twice, at positions $\binom{n}{1}$ and $\binom{n}{n-1}$. So $10$ appears exactly four times.

Now try $3003$. It appears at $\binom{3003}{1}$ and $\binom{3003}{3002}$, of course. But also at $\binom{78}{2}$ and $\binom{78}{76}$. And at $\binom{15}{5}$ and $\binom{15}{10}$. And at $\binom{14}{6}$ and $\binom{14}{8}$. Eight times. Nobody has ever found a number that appears more often.

In 1971 David Singmaster asked the obvious question: **is there a limit?** Is there a constant $C$ such that no integer appears more than $C$ times in Pascal's triangle? He conjectured yes. Half a century later the conjecture is wide open. The best known unconditional bound says the number of appearances of $n$ is at most about $\log n / \log\log n$ — infinitely far from a constant.

This article is about what one *can* prove, completely and unconditionally, about the function

$$m(n) = \#\{(N,k) : 0 \le k \le N,\ \tbinom{N}{k} = n\},$$

which we will call the **multiplicity** of $n$. (For $n=1$ the count is infinite — the border — so $1$ is excluded from the discussion; for every $n \ge 2$ the count is finite, as we are about to see.) The story that emerges is unexpectedly rigid: there are arithmetic reasons why most numbers appear exactly twice, a parity law that says the multiplicity is almost always even, an infinite family of numbers appearing at least six times that is governed by the Fibonacci sequence — and, as the newest result here shows, that Fibonacci family is the *only* one its mechanism can produce.

## Why the search is finite: two squeezes

The first thing to notice is that hunting for occurrences of $n$ is a finite task. Inside a row, binomial coefficients increase as you move toward the middle: if $j \le k$ and $j + k \le N$ then $\binom{N}{j} \le \binom{N}{k}$. So the smallest interesting entry of row $N$ is $\binom{N}{1} = N$ itself, which means an occurrence of $n$ can only live in a row with $N \le n$.

That is crude. The good bound comes from throwing away the two boundary occurrences. Call an occurrence $(N,k)$ **interior** if $2 \le k \le N-2$ — that is, if it is not one of the two edge appearances $\binom{n}{1} = \binom{n}{n-1} = n$. For an interior occurrence, the same monotonicity gives

$$n = \binom{N}{k} \ \ge\ \binom{N}{2} = \frac{N(N-1)}{2},$$

so $N(N-1) \le 2n$: **every interesting occurrence of $n$ lies in a row of index about $\sqrt{2n}$ or less.** For $n = 3003$ this says $N \le 78$, and sure enough the largest interesting row for $3003$ is row $78$. Searching for occurrences of a huge number requires scanning only $O(\sqrt n)$ rows.

There is a second, independent squeeze, this time on the column. If $2k \le N$ then $\binom{N}{k} \ge \binom{2k}{k} \ge 2^k$, so an interior occurrence in the left half of the triangle has $k \le \log_2 n$. The two squeezes together confine all the interesting action to a rectangle of size roughly $\sqrt{2n} \times \log_2 n$.

That rectangle immediately buys a theorem about how *rare* interesting numbers are. Assign to each $n \le x$ with $m(n) \ge 3$ one interior occurrence in the left half; different $n$'s get different positions, since a position determines its value. The positions all live in a rectangle, so

$$\#\{\,3 \le n \le x : m(n) \ge 3\,\} \ \le\ \bigl(\lfloor \sqrt{2x}\rfloor + 2\bigr)\bigl(\lfloor \log_2 x\rfloor + 2\bigr) = O(\sqrt x \log x).$$

In words: **almost every integer appears exactly twice in Pascal's triangle**, with at most $O(\sqrt{x}\log x)$ exceptions up to $x$. Numerically, up to $x = 3000$ there are $110$ exceptions against a proved ceiling of $1027$ — comfortably true, and of the right shape.

## The parity law: why odd multiplicities are almost impossible

Pascal's triangle has a mirror symmetry: $\binom{N}{k} = \binom{N}{N-k}$. Reflecting $k \mapsto N-k$ pairs each occurrence strictly left of centre with one strictly right of centre. Only a *central* occurrence, one with $N = 2k$, is left unpaired. Therefore

$$m(n) = 2 \cdot \#\{\text{occurrences left of centre}\} + \#\{\text{central occurrences}\}.$$

How many central occurrences can there be? The central binomial coefficients $\binom{2m}{m} = 1, 2, 6, 20, 70, 252, 924, 3432,\dots$ are strictly increasing, so no value can be central twice. Hence:

> **Parity Law.** For $n \ge 2$, the multiplicity $m(n)$ is odd **if and only if** $n$ is a central binomial coefficient $\binom{2m}{m}$.

This is a complete explanation of a pattern anybody who tabulates multiplicities notices immediately: odd values are freakishly rare. Below $3003$ the only numbers with odd multiplicity are $2, 6, 20, 70, 252, 924$ — precisely the central binomial coefficients in that range — and each of them has multiplicity exactly $3$ (except $2$, with multiplicity $1$). The parity law also tells you why the record $8$ is even, and why chasing an example with multiplicity $9$ means chasing a central binomial coefficient with four extra pairs of occurrences.

## An arithmetic reason to be boring

Everything so far has been combinatorial. Here is an arithmetic obstruction, and it is startlingly effective.

Suppose $p$ is a prime dividing $n$. If $n = \binom{N}{k}$ then $\binom{N}{k}$ divides $N!$, so $p$ divides $N!$, so $p \le N$. Combine that with the row squeeze $N(N-1)\le 2n$ for an interior occurrence: we get $p(p-1) \le N(N-1) \le 2n$. Contrapositive:

> **Large-Prime-Factor Theorem.** If $n \ge 3$ has a prime factor $p$ with $p(p-1) > 2n$, then $n$ has no interior occurrence at all, and $m(n) = 2$ exactly.

A number with a big prime factor relative to its size is condemned to appear only on the two edges. Two immediate consequences: every prime $p \ge 5$ has $m(p) = 2$ (take $p$ itself: $p(p-1) > 2p$ once $p \ge 4$), and every $n = 2p$ with $p \ge 7$ prime has $m(2p) = 2$. In particular **infinitely many integers appear exactly twice** — a statement that sounds obvious but needs precisely this kind of argument.

## Exactly four times, infinitely often

Push the same idea one step further and something sharper appears. Take a prime $p \ge 5$ and let $n = \binom{p}{2} = p(p-1)/2$. Since $p$ is odd, $p$ divides $n$. The row squeeze gives $N(N-1) \le 2n = p(p-1)$, so $N \le p$; the prime argument gives $p \le N$. Both together force $N = p$: **every interior occurrence of $\binom{p}{2}$ lies in row $p$.** Within that row, monotonicity plus the strict inequality $\binom{p}{2} < \binom{p}{3}$ (valid for $p \ge 7$) pins the column to $k = 2$ or $k = p-2$. So there are exactly two interior occurrences, and

> **Exact-Four Theorem.** For every prime $p \ge 5$, the number $\binom{p}{2}$ appears exactly four times in Pascal's triangle: at $\binom{p}{2}, \binom{p}{p-2}$, and on the two edges.

So $10, 21, 55, 78, 136, 171, 253, 406, \dots$ all have multiplicity exactly $4$, and there are infinitely many of them. Note the character of this result: not a bound, not "at least", but an exact count for an infinite family — the sort of statement Singmaster's conjecture would need in bulk.

## The Fibonacci ladder

Now for the other direction: numbers that appear *many* times. Where do coincidences like $3003 = \binom{14}{6} = \binom{15}{5} = \binom{78}{2}$ come from?

One mechanism explains most of them. Ask when a number in one row equals a number one row up and one column to the right:

$$\binom{N}{k} = \binom{N-1}{k+1}.$$

Unwinding the multiplicative recurrences of the binomial coefficients, this holds exactly when

$$N(k+1) = (N-k)(N-k-1). \tag{$\ast$}$$

Any solution is a jackpot. It hands you two occurrences at once, and the mirror symmetry doubles them to four interior occurrences — $\binom{N}{k}$, $\binom{N}{N-k}$, $\binom{N-1}{k+1}$, $\binom{N-1}{N-k-2}$ — which together with the two edge occurrences gives multiplicity at least $6$.

The smallest solution of $(\ast)$ with $2 \le k \le N/2$ is $N = 15$, $k = 5$: our friend $3003 = \binom{15}{5} = \binom{14}{6}$. The next is $N = 104, k = 39$; then $N = 714, k = 272$; then $N = 4895, k = 1869$.

Do those numbers look familiar? $15 = 3 \cdot 5$, $104 = 8 \cdot 13$, $714 = 21\cdot 34$, $4895 = 55 \cdot 89$ — products of consecutive Fibonacci numbers. And $5 = 1\cdot 5$, $39 = 3\cdot 13$, $272 = 8 \cdot 34$, $1869 = 21\cdot 89$. Indeed, setting $F_1 = F_2 = 1$ and $F_{j+2} = F_{j+1} + F_j$, the pairs

$$N_i = F_{2i+2}F_{2i+3}, \qquad k_i = F_{2i}F_{2i+3} \qquad (i \ge 1)$$

all satisfy $(\ast)$, so:

> **Fibonacci Ladder Theorem.** For every $i \ge 1$, the binomial coefficient $\binom{F_{2i+2}F_{2i+3}}{F_{2i}F_{2i+3}}$ appears at least six times in Pascal's triangle. Consequently **infinitely many integers appear at least six times.** The first member of the ladder is $\binom{15}{5} = 3003$.

The engine underneath is the classical Cassini identity in its even form,

$$F_{2i+1}^2 = F_{2i}F_{2i+1} + F_{2i}^2 + 1,$$

that is, $b^2 = ab + a^2 + 1$ for $(a,b) = (F_{2i}, F_{2i+1})$. In fact one can prove the theorem for an *arbitrary* pair $(a,b)$ satisfying that relation: whenever $1 \le a < b$ and $b^2 = ab+a^2+1$, the number $\binom{(a+b)(a+2b)}{a(a+2b)}$ appears at least six times. And then a descent argument shows that the Cassini relation has no solutions beyond the Fibonacci ones: if $a \le b$ and $b^2 = ab+a^2+1$, then $(a,b) = (F_{2i},F_{2i+1})$ for some $i$. (Given a solution, $(2a-b,\,b-a)$ is a smaller one; iterate down to the base $(0,1)$.)

## The new theorem: the ladder is everything

That leaves a nagging question, and it is the one settled here. The Cassini relation is only the *input* to the row-shift mechanism. Might equation $(\ast)$ itself have solutions of some entirely different shape — a second infinite family of six-fold coincidences that nobody has noticed?

No. That is the main new result.

> **Row-Shift Classification.** Let $N, k$ be integers with $2 \le k$ and $2k \le N$. Then $N(k+1) = (N-k)(N-k-1)$ holds **if and only if** $N = F_{2i+2}F_{2i+3}$ and $k = F_{2i}F_{2i+3}$ for some $i \ge 1$.

The proof is a beautiful piece of elementary machinery: a *two-step Vieta descent*. Clear the subtractions and $(\ast)$ becomes the symmetric-looking Diophantine equation

$$k^2 + k + N^2 = 3Nk + 2N.$$

Read it as a quadratic in $N$ with $k$ fixed: $N^2 - (3k+2)N + (k^2+k) = 0$. It is monic with integer coefficients, so if $N$ is a root, so is the conjugate root $M = 3k+2-N$, and $NM = k(k+1)$. A little bookkeeping shows that when $1 \le k$ and $2k \le N$, this conjugate obeys $2 \le M < N$ and $2M \le k+1$: **a strictly smaller row, still admissible.**

Now hold the row $M$ fixed and read the same equation as a quadratic in $k$: $k^2 - (3M-1)k + (M^2 - 2M) = 0$. Again monic, again a conjugate root $j = 3M-1-k$, which satisfies $2j \le M$: the column has been dragged back into the admissible range.

So each solution has a strictly smaller solution beneath it, and the descent must terminate. The only place it can stop is the degenerate pair $(N,k) = (2,0)$, excluded by the requirement $k \ge 2$ but sitting at the bottom of the ladder as its $i=0$ member. Running the descent backwards — and this is where the Fibonacci numbers enter — the ascent step from $\bigl((a+b)(a+2b),\, a(a+2b)\bigr)$ produces exactly $\bigl((2a+3b)(3a+5b),\, (a+b)(3a+5b)\bigr)$, and verifying that it lands on a solution is *precisely* the even Cassini identity again. Since $(a,b) \mapsto (a+b, a+2b) \mapsto (2a+3b, 3a+5b)$ shifts Fibonacci indices by two, the ladder reproduces itself and nothing else.

An elegant fossil is left behind. Eliminating $k$ from the classification shows that a row-shift solution forces

$$(3N-1-2k)^2 = 5N^2 + 2N + 1,$$

so $5N^2+2N+1$ must be a perfect square — equivalently, $(5N+1)^2 - 5(3N-1-2k)^2 = -4$, the Pell equation whose solutions are the Lucas–Fibonacci pairs. At $N=15, k=5$ this reads $34^2 = 1156 = 5\cdot 225 + 30 + 1$, with $5N+1 = 76 = L_9$ and $3N-1-2k = 34 = F_9$. The Pell equation is genuinely there in the background — but the classification does not need it. The descent alone does the job.

The practical upshot is a piece of bad news for Singmaster hunters: **the one-row shift is exhausted.** Every six-fold coincidence obtainable that way is a Fibonacci one. Any new infinite family of highly repeated binomial coefficients has to come from a genuinely different coincidence — say a two-row shift $\binom{N}{k} = \binom{N-2}{k+r}$, or a coincidence between rows that are far apart, like the $\binom{78}{2} = \binom{15}{5}$ half of the $3003$ miracle, which no known mechanism explains.

## What the record actually looks like

Finally, the small-number end of the story. The row squeeze reduces the verification of a specific multiplicity to a finite search, and carrying it out gives the definitive local picture:

- $m(3003) = 8$, realised at $(14,6), (14,8), (15,5), (15,10), (78,2), (78,76), (3003,1), (3003,3002)$.
- $m(n) \le 8$ for every $n < 3003$ — so $3003$ is a genuine record holder, not merely the smallest example of $8$.
- No $n < 3003$ has $m(n) = 5$ or $m(n) = 7$. (Odd multiplicity forces $n$ to be one of $2, 6, 20, 70, 252, 924$, and each of those has multiplicity $3$ or $1$.)
- The multiplicities actually attained are $1, 2, 3, 4, 6, 8$ — witnessed by $2, 5, 6, 21, 120, 3003$ — plus the vacuous $m(0)=0$.

That last line is the shape of the mystery in miniature. Six values attained, two ($5$ and $7$) apparently forbidden, and a hard ceiling at $8$ that nobody can prove is a ceiling at all. What we do have is a network of reasons for the *floor*: a parity law that forbids odd values unless a central binomial coefficient is involved; an arithmetic obstruction that pins numbers with a large prime factor to exactly $2$; an infinite family pinned to exactly $4$; a Fibonacci ladder pushed to at least $6$; a density bound showing exceptions are $O(\sqrt x \log x)$; and now the knowledge that the ladder is the whole of what its mechanism can produce.

Singmaster's conjecture remains open. But the terrain around it is no longer trackless.
