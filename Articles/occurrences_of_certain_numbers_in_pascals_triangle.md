# The Loneliest Numbers in Pascal's Triangle

## A pyramid of numbers, and a strange scarcity

Draw a triangle of numbers. Put a $1$ at the top. Put $1$s down both slanted edges. Fill every other slot with the sum of the two numbers directly above it. You get the most famous array in mathematics:

$$
\begin{array}{ccccccccc}
 & & & & 1 & & & &\\
 & & & 1 & & 1 & & &\\
 & & 1 & & 2 & & 1 & &\\
 & 1 & & 3 & & 3 & & 1 &\\
1 & & 4 & & 6 & & 4 & & 1
\end{array}
$$

The entry in row $n$, position $k$ (counting rows and positions from zero) is the binomial coefficient
$$\binom{n}{k} = \frac{n!}{k!\,(n-k)!},$$
the number of ways to choose $k$ objects out of $n$. Pascal's triangle is the multiplication table of combinatorics: every counting problem you ever solved in a probability class lives in here somewhere.

Now ask a question that sounds childish and turns out to be brutally hard. **Pick a number. How many times does it appear in the triangle?**

The number $1$ appears infinitely often — it runs down both edges forever. Set it aside. Everything else is startlingly rare.

- $2$ appears **once**, at $\binom{2}{1}$. It is the only number besides $1$ that appears just once.
- $3$, $4$, $5$, and every odd prime appear **exactly twice**, at $\binom{t}{1}$ and $\binom{t}{t-1}$ and nowhere else.
- $6$ appears **three times**: $\binom{6}{1}$, $\binom{6}{5}$, and $\binom{4}{2}$.
- $10$ appears **four times**: $\binom{10}{1}$, $\binom{10}{9}$, $\binom{5}{2}$, $\binom{5}{3}$.
- $120$, $210$, $1540$, $7140$, $11628$, $24310$ each appear **exactly six times**.
- $3003$ appears **eight times** — and no smaller number, and no number below a million, appears more often.

And then the gap that has kept the problem alive for half a century: **nobody has ever found a number that appears exactly five times, or exactly seven times.** Not one, in fifty years of searching.

In 1971 the Berkeley mathematician David Singmaster asked the obvious follow-up: is there some absolute ceiling? Is there a constant $C$ such that no number other than $1$ ever appears more than $C$ times in the whole infinite triangle? Empirically the answer looks like $C = 8$. Nobody can prove any constant at all.

This article is about how much of that story can be pinned down rigorously — and it turns out to be a surprising amount.

## Why almost everything appears exactly twice

Write $N(t)$ for the number of positions $(n,k)$ with $k \le n$ and $\binom{n}{k} = t$. The first thing to notice is that $N(t)$ is finite for every $t \ge 2$, and for a very simple reason.

**Every occurrence lives in a bounded region.** If $\binom{n}{k} = t \ge 2$, then $k$ is neither $0$ nor $n$ (those entries equal $1$), so the entry is *interior*, and every interior entry of row $n$ is at least $n$ itself. Hence $n \le t$. All occurrences of $t$ are trapped in the top $t$ rows — a finite triangle. So $N(t)$ is a genuine, computable number.

Two occurrences are always free: $\binom{t}{1} = t$ and $\binom{t}{t-1} = t$. So $N(t) \ge 2$ for every $t \ge 3$, and the interesting question is always about the *extra* occurrences.

For a prime $p$ there are none. If $\binom{n}{k} = p$, then $p$ divides $n!$ (because $\binom{n}{k} \cdot k! \, (n-k)! = n!$), and a prime dividing $n!$ must be at most $n$; combined with $n \le p$ this forces $n = p$ exactly. Then within row $p$, any entry with $2 \le k \le p-2$ is at least $\binom{p}{2} = p(p-1)/2$, which exceeds $p$ once $p \ge 5$. So the only entries equal to $p$ are the two obvious ones: **every odd prime appears exactly twice**. (And $2$ appears once, because row $2$ has no interior slot other than the single $2$.)

This is the shape of the whole subject: occurrences are pinned down by *size* arguments. Two monotonicity facts do almost all the work.

- **Down a column, entries strictly grow.** For a fixed $k \ge 1$, the sequence $\binom{k}{k}, \binom{k+1}{k}, \binom{k+2}{k}, \dots$ is strictly increasing. So a given value can occur *at most once in each column*.
- **Along the left half of a row, entries strictly grow.** For $2j' \le n$ and $j < j'$ we have $\binom{n}{j} < \binom{n}{j'}$. Combined with the mirror symmetry $\binom{n}{k} = \binom{n}{n-k}$, this means a given value occurs *at most twice in each row* — once on the left, once at its mirror image.

Those two facts, alone, give a real theorem.

## A logarithmic ceiling

Here is the first genuinely nontrivial general bound. Fold each position $(n,k)$ to its distance from the edge, $j = \min(k, n-k)$; by symmetry $\binom{n}{j} = \binom{n}{k}$, so folding loses nothing. The growth estimate $\binom{n}{j} \ge 2^{j}$ whenever $2j \le n$ then says that if $\binom{n}{k} = t$, the folded index satisfies $2^{j} \le t$, i.e.
$$j \le \log_2 t.$$
Each folded index $j \ge 2$ is realised by at most two positions (column uniqueness fixes the row, and then the row has only the position and its mirror), and the folded indices $j \le 1$ account for the two boundary occurrences. Adding up:

> **Theorem (logarithmic bound).** For every $t \ge 2$, $\ N(t) \le 2\log_2 t$.

So no number appears wildly often: a number of size $10^{12}$ can occupy at most about $80$ slots. Singmaster's conjecture asks to replace $2\log_2 t$ by a constant. The best result in the literature is $O(\log t / \log\log t)$ — better, but still not a constant, and still infinitely far from the empirical truth of $8$.

There is a cleaner way to say the same thing. Since a row hosts a value at most twice,
$$N(t) \le 2 \cdot \#\{\text{rows containing } t\}.$$
Singmaster's conjecture is therefore *equivalent* to bounding how many different rows a single number can visit. That reformulation deletes all the column bookkeeping and leaves a single crisp question: how many $n$ can there be with $\binom{n}{k_n} = t$ for some $k_n$?

## Where the sixes come from

Why do so many numbers appear exactly six times? A number $t = \binom{n}{k}$ with $2 \le k \le n-2$ automatically occupies four positions: $(n,k)$, $(n,n-k)$, and the two boundary ones $(t,1)$, $(t,t-1)$. Two *extra* positions appear exactly when the same number also shows up one row higher, i.e. when
$$\binom{n}{k} = \binom{n-1}{k+1}.$$

Cancel factorials and this coincidence becomes a Diophantine equation:
$$n\,(k+1) = (n-k)(n-k-1).$$

And now something lovely happens. That equation is a disguised Pell equation, and it has an infinite family of solutions built from Fibonacci numbers. Using Cassini's identity in the form $F_{2i+3}^2 = F_{2i+2}F_{2i+4} + 1$, one checks that
$$n = F_{2i+4}\,F_{2i+5}, \qquad k = F_{2i+2}\,F_{2i+5}$$
solves it for every $i \ge 0$. For $i = 0$: $n = 3 \cdot 5 = 15$, $k = 1 \cdot 5 = 5$, giving
$$\binom{15}{5} = \binom{14}{6} = 3003.$$
For $i = 1$: $n = 8 \cdot 13 = 104$, $k = 3 \cdot 13 = 39$, giving $\binom{104}{39} = \binom{103}{40}$, a $30$-digit monster. And so on forever.

> **Theorem (infinitely many sixes).** Every member of the Fibonacci family occurs at least six times, and the values grow without bound. Hence there are infinitely many numbers occurring six or more times.

This is the mechanism behind $120, 210, 1540, 7140, 11628, 24310$ — the small numbers with exactly six occurrences — and it is also why $3003$ is special. $3003$ sits in the Fibonacci family (giving six positions) *and* happens to be a triangular number, $3003 = \binom{78}{2} = \binom{78}{76}$, contributing two more. Six plus two is eight.

> **Theorem.** $3003$ occurs exactly eight times, at
> $$\binom{3003}{1},\ \binom{3003}{3002},\ \binom{78}{2},\ \binom{78}{76},\ \binom{15}{5},\ \binom{15}{10},\ \binom{14}{6},\ \binom{14}{8}.$$
> Moreover no number below $10^6$ occurs more than eight times, and $3003$ is the *only* number below $10^6$ that occurs eight times; every other number below $10^6$ occurs at most six times.

## The parity miracle

Now for the sharpest structural insight in this story — the one that explains, at least partly, the missing fives and sevens.

The mirror symmetry $\binom{n}{k} = \binom{n}{n-k}$ is an *involution* of the set of occurrences of $t$. It swaps positions strictly left of their row's centre with positions strictly right of it. The only positions it can fix are the exact centres $(2m, m)$. Therefore
$$N(t) = 2\cdot\#\{\text{left occurrences}\} + \#\{\text{central occurrences}\}.$$
And there is at most one central occurrence, because $m \mapsto \binom{2m}{m}$ is strictly increasing, so a number is a central binomial coefficient in at most one way. Conclusion:

> **Parity Theorem.** For $t \ge 2$, the multiplicity $N(t)$ is **odd if and only if $t$ is a central binomial coefficient** $\binom{2m}{m}$.

Look at what this does. The central binomial coefficients are the thin sequence
$$2,\ 6,\ 20,\ 70,\ 252,\ 924,\ 3432,\ 12870,\ 48620,\ 184756,\ 705432,\ \dots$$
Every other number in the universe has *even* multiplicity. So the hunt for a number appearing exactly five times, or exactly seven times, is not a hunt through all integers — it is a hunt through this one sequence. Everything else is automatically ruled out.

That is a spectacular narrowing, and it converts an open-ended search into a checkable one.

## Making the search effective

The central binomial coefficient $\binom{2m}{m}$ always occurs at least three times: the two boundary positions and the central one. The question becomes: does it ever occur *more*?

**A sandwich theorem** does the first half of the job. For $m \ge 1$, the central entry $\binom{2m}{m}$ is the strict maximum of the entire triangle truncated at row $2m$: every other entry $\binom{n}{k}$ with $k \le n \le 2m$ is strictly smaller. So a repeat of $\binom{2m}{m}$ can only occur *below* row $2m$. And any such repeat is interior, so it satisfies $\binom{n}{2} \le t$, which caps $n$ at roughly $\sqrt{2t}$.

The result is a completely explicit finite test:

> **Effective criterion.** Let $t = \binom{2m}{m}$ with $m \ge 2$, and pick $N$ with $t < \binom{N}{2}$. If no entry $\binom{n}{k} = t$ with $2m < n < N$ and $2 \le k \le n/2$ exists, then $N(t) = 3$ exactly.

Running that test settles the first ten cases: $\binom{2m}{m}$ occurs exactly three times for $2 \le m \le 10$, i.e. for
$$6,\ 20,\ 70,\ 252,\ 924,\ 3432,\ 12870,\ 48620,\ 184756.$$
Combined with the Parity Theorem, this already gives an unconditional statement about *all* integers: **no number below $705432$ occurs exactly five or exactly seven times**, and below that bound an odd multiplicity is always $1$ or $3$. Ten finite searches, and an infinite class of numbers is cleared.

Pushing further requires shrinking the search box, and two more ideas do that.

**The column collapse.** In the escape window the column index has to be tiny. If $2k \le n$, $n > 2m$ and $\binom{n}{k} = \binom{2m}{m}$, then necessarily $k < m$. The reason: $\binom{2k}{k} \le \binom{n}{k}$ by growth down the column, and $m \mapsto \binom{2m}{m}$ is strictly increasing, so $k \ge m$ would force $\binom{2m}{m} \le \binom{2k}{k} \le \binom{n}{k} = \binom{2m}{m}$ with a strict inequality somewhere — a contradiction. So the columns to search form a strip of height $m$, not a triangle of height $\sqrt{t/2}$.

**The triangular obstruction.** The single column $k = 2$ is what forces the enormous row window $N \approx \sqrt{2t}$. But $\binom{n}{2} = t$ has a solution if and only if $t$ is a triangular number, which happens if and only if $8t + 1$ is a perfect square. One square-root test therefore eliminates that entire column, after which every surviving entry satisfies $\binom{n}{3} \le t$ and the row window shrinks from $\sqrt{2t}$ to $(6t)^{1/3}$.

For $m = 20$ the search box shrinks from roughly $524248 \times 262124$ down to $9347 \times 17$ — more than nine orders of magnitude. With that, the verification extends to $m \le 20$, and:

> **Theorem.** $\binom{2m}{m}$ occurs exactly three times for every $2 \le m \le 20$. Consequently **no number below $538{,}257{,}874{,}440$ occurs exactly five or exactly seven times**, and below that bound every odd multiplicity equals $1$ or $3$.

That is a half-trillion-wide certificate for the folklore observation, obtained not by scanning half a trillion integers but by running nineteen small searches on a thin, structurally distinguished sequence.

## What is still out of reach

None of this proves Singmaster's conjecture. The honest state of affairs:

- The best general ceiling anyone has is logarithmic (or, with more work, $\log t/\log\log t$); a constant remains out of reach.
- We know infinitely many numbers occur at least six times, but we do not know whether *any* number occurs more than eight times, nor whether infinitely many occur eight times.
- The multiplicities $5$ and $7$ have been ruled out for every number below half a trillion, but they have not been ruled out in general. Because of the Parity Theorem, ruling them out forever is exactly the statement that $\binom{2m}{m}$ occurs exactly three times for every $m \ge 2$ — a clean, self-contained conjecture about a single classical sequence.
- The Fibonacci family solves $\binom{n}{k} = \binom{n-1}{k+1}$; it is conjectured, but unproved, that it gives *all* solutions. Equivalently: $(5m-1)(m-1)$ is a perfect square only when $m$ is a product of two Fibonacci numbers of the right indices.

There is something wonderful about a problem this elementary staying this hard. A child can build Pascal's triangle. A student can verify that $3003$ appears eight times. And yet the question "does any number appear a hundred times?" — which one could pose in a single sentence to anyone who has drawn the triangle once — is, in 2025, wide open.

What the results above show is that the difficulty is not diffuse. It is concentrated: on the central binomial coefficients, for the parity question; and on counting *rows*, rather than positions, for the conjecture itself. Sometimes half the battle in a fifty-year-old problem is learning exactly where the battle is.
