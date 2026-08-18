# The Last Moment

## How much do you have to know about a data set before you know it completely?

Suppose someone has a bag of numbers. Not a bag of arbitrary numbers — the entries are whole numbers, and they all lie between $0$ and $N$. You are not allowed to look inside. You are allowed to ask for *averages of powers*: the number of items, the sum of the items, the sum of their squares, the sum of their cubes, and so on. Each question buys you one number:

$$S_k = \sum_{x \in \text{bag}} x^k, \qquad k = 0, 1, 2, \dots$$

$S_0$ is the size of the bag. $S_1$ is the total. $S_2$ is the sum of squares, which together with $S_1$ and $S_0$ gives you the variance. These are the *moments*, the oldest and most universal summary statistics in existence. Every histogram, every error bar, every kurtosis in a physics paper is built from them.

How many do you need before the bag is pinned down exactly?

The answer turns out to be beautifully crisp, and the story of *why* it is crisp — and of what happens one question short of the answer — runs from Vandermonde matrices through the alternating binomial coefficients, past a two-hundred-year-old problem of Prouhet, Tarry and Escott, and into a small, stubborn arithmetic question that is still open.

---

## The answer: $N$ questions, and not one fewer

**Theorem (Rigidity).** *A weight system on the points $\{0, 1, \dots, N\}$ is completely determined by its power sums of orders $k = 0, 1, \dots, N$.*

Here a "weight system" is any assignment of real numbers $w_0, w_1, \dots, w_N$ to the points $0, 1, \dots, N$; the power sums are $S_k(w) = \sum_{i=0}^N w_i \, i^k$. A bag of numbers is the special case where the $w_i$ are non-negative integers (multiplicities), and a probability distribution is the case $w_i \ge 0$, $\sum_i w_i = 1$.

The proof is one of those arguments that feels like a magic trick until you see it, and then feels inevitable. There are $N+1$ unknowns $w_0, \dots, w_N$ and $N+1$ equations, one per moment. The coefficient matrix has entries $i^k$ — the *Vandermonde matrix* of the nodes $0, 1, \dots, N$ — and Vandermonde matrices with distinct nodes are invertible. Concretely: for each node $j$ there is a polynomial $L_j$ of degree $N$ that equals $1$ at $j$ and vanishes at every other node (its Lagrange basis polynomial). Expanding $L_j$ in powers of $X$ and feeding the expansion the known moments reconstructs $w_j$ on the nose:

$$w_j = \sum_{k=0}^{N} \big([X^k] L_j\big) \, S_k(w).$$

So $N+1$ moments — orders $0$ through $N$ — suffice. Can you get away with fewer?

**Theorem (Sharpness).** *No. For every $K < N$ there are two genuinely different probability distributions supported in $\{0, 1, \dots, N\}$ whose power sums agree in every order $k \le K$.*

The witnesses are startlingly clean. Take the binomial coefficients $\binom{N}{0}, \binom{N}{1}, \dots, \binom{N}{N}$ — Pascal's triangle, row $N$ — and split them by parity. Put mass $\binom{N}{i}/2^{N-1}$ on each *even* $i$; that is one probability distribution, because the even binomial coefficients sum to $2^{N-1}$. Put mass $\binom{N}{i}/2^{N-1}$ on each *odd* $i$; that is another. These two distributions look nothing alike — one lives entirely on the even numbers, the other entirely on the odd ones — yet they have exactly the same mean, the same variance, the same skewness, the same everything, all the way up to order $N - 1$. Only at order $N$, the very last question, do they part company.

For $N = 2$ this is the classic: the bag $\{0, 2\}$ and the bag $\{1, 1\}$ both have two elements and both sum to $2$. Only the sum of squares, $4$ versus $2$, tells them apart. For $N = 5$, the even half puts mass $\tfrac{1}{16}, \tfrac{10}{16}, \tfrac{5}{16}$ on $0, 2, 4$ and the odd half puts $\tfrac{5}{16}, \tfrac{10}{16}, \tfrac{1}{16}$ on $1, 3, 5$; their first five moments $1, \tfrac52, \tfrac{15}{2}, 25, 90$ coincide perfectly, and the fifth-order moments finally differ by $\tfrac{15}{2}$.

So the window $k \le N$ is exactly right: it cannot be shortened by even one question.

---

## The invisible signal

The really pleasing part is not that near-collisions exist, but that there is *only one* of them, up to scale.

**Theorem (Structure of the failure).** *If two weight systems on $\{0, 1, \dots, N\}$ have identical power sums in every order $k < N$, then their difference is a scalar multiple of the alternating binomial vector*
$$i \longmapsto (-1)^i \binom{N}{i}.$$
*The scalar is exactly the discrepancy at the node $0$.*

In signal-processing language: the space of "moment-invisible" signals on $N+1$ points — signed measures that all your questions below order $N$ cannot see — is exactly one-dimensional, and its single basis vector is the alternating row of Pascal's triangle. Every failure of reconstruction is that one signal in disguise.

This has an immediate and very sharp consequence. Since the alternating vector has $\ell^1$ norm $\sum_i \binom{N}{i} = 2^N$, any two weight systems agreeing below order $N$ satisfy

$$\sum_{i=0}^{N} |w_i - v_i| = |w_0 - v_0| \cdot 2^N.$$

The total discrepancy is entirely determined by the discrepancy at a single point. And the gap that finally appears at order $N$ is likewise pinned:

$$S_N(w) - S_N(v) = (w_0 - v_0) \cdot (-1)^N \, N! .$$

This last identity rests on a small gem, the *alternating-sum identity*: for any polynomial $p$ of degree at most $N$,

$$\sum_{i=0}^{N} (-1)^i \binom{N}{i} p(i) = (-1)^N N! \cdot [X^N]p,$$

where $[X^N]p$ is the leading coefficient. The functional $p \mapsto \sum_i (-1)^i \binom{N}{i} p(i)$ is the $N$-fold finite difference in disguise; each application of $p(X) \mapsto p(X+1) - p(X)$ knocks the degree down by one and multiplies the leading coefficient by its degree, and after $N$ steps only $N!$ times the leading coefficient survives. Pascal's rule performs the telescoping.

Put the two facts together and you get the extremal constant of the whole subject. Two *probability* distributions have total discrepancy at most $2$, so $|w_0 - v_0| \le 2^{1-N}$, so:

**Theorem (Extremal separation).** *Among probability distributions on $\{0, \dots, N\}$ that agree in all moments of order below $N$, the $N$-th moments differ by at most $N!/2^{N-1}$ — and the even and odd binomial halves achieve exactly this.*

There is a companion statement for noisy data. If you only know the moments approximately — every moment of order $k \le N$ correct to within $\varepsilon$ — then each weight is recovered to within $\Lambda_{N,j}\,\varepsilon$, where $\Lambda_{N,j}$ is the sum of the absolute values of the coefficients of the $j$-th Lagrange polynomial. Rigidity is the case $\varepsilon = 0$. These constants grow fast: at $N = 6$ the worst one is already $35$, and the growth is exponential. Reconstructing a distribution from its moments is possible in principle and delicate in practice — exactly the phenomenon that makes the classical moment problem in statistics such a minefield.

---

## Two different reasons a bag can be pinned down

So far, everything has hinged on the *alphabet*: the fact that the data live in $\{0, \dots, N\}$. But there is a second, entirely independent mechanism, and it hinges on the *size* of the bag.

**Theorem (Size threshold).** *A bag of $n$ numbers is determined by its power sums of orders $k \le n$, no matter how large the numbers are.*

This is the fundamental theorem of symmetric functions, made effective by Newton's identities. The power sums $S_1, \dots, S_n$ determine the elementary symmetric functions $e_1, \dots, e_n$ recursively — $S_1 = e_1$, $S_2 = e_1 S_1 - 2e_2$, and so on — and the elementary symmetric functions are the coefficients of the polynomial $\prod_{x \in \text{bag}} (X - x)$, whose roots are the bag.

Two mechanisms, two thresholds, and the truth is the better of the two:

**Theorem (Exact threshold).** *A bag of $n$ numbers, all at most $N$, is determined by its power sums of orders $k \le \min(N, n)$.*

Which mechanism bites depends on the shape of the data. A million samples from a six-sided die: the alphabet is small, so six moments suffice. Three enormous integers: the bag is small, so three moments suffice.

---

## How expensive is a collision?

The two mechanisms give two lower bounds on how big a *collision* — a pair of different bags with identical moments up to order $K$ — has to be. Write $m(N,K)$ for the least number of elements in such a bag, with entries bounded by $N$ and agreement in every order $k \le K$. This single number encodes everything.

Three facts frame it.

**The floor.** Every collision of agreement order $K$ needs strictly more than $K$ elements: $K < m(N,K)$. This is the Newton mechanism, and it is precisely the classical *Prouhet–Tarry–Escott* lower bound. A pair achieving equality, $K+1$ elements on each side agreeing in all power sums up to order $K$, is what number theorists call an **ideal solution**.

**The ceiling.** $m(N,K) \le 2^K$ whenever a collision exists at all, i.e. whenever $K < N$. The construction is Prouhet's, from 1851, and it is a marvel of economy. Start with $\{0\}$ versus $\{1\}$. To go from agreement order $K$ to order $K+1$, take your pair $(s,t)$, pick any shift $M$, and form
$$s \cup (t+M) \quad\text{versus}\quad t \cup (s+M).$$
Expanding $(y+M)^k$ by the binomial theorem, all the cross terms cancel *because the two sides swap roles*, and one extra order of agreement falls out for free — for every shift $M$. Doubling with $M = 2, 4, 8, \dots$ yields, after $K$ steps, the split of $\{0, 1, \dots, 2^{K+1}-1\}$ by the parity of the binary digit sum: the **Thue–Morse** partition. For $K = 3$ this is $\{0,3,5,6,9,10,12,15\}$ versus $\{1,2,4,7,8,11,13,14\}$ — sixteen numbers whose two halves have identical counts, sums, sums of squares and sums of cubes. It is the same sequence that governs fair turn-taking and appears in aperiodic tilings; here it is the universal budget for moment forgery.

**The critical window.** At $K = N-1$ — one question short of rigidity — the ceiling is exactly attained:
$$m(N, N-1) = 2^{N-1}.$$
This is where the structure theorem earns its keep. At the critical window, the difference of the two bags must be an *integer* multiple of the alternating vector $(-1)^i\binom{N}{i}$; being nonzero, it has $\ell^1$ norm at least $2^N$, and so each side must carry at least $2^{N-1}$ elements. The binomial halves realise it. So at the very last window before rigidity kicks in, forging the moments is exponentially expensive — you need $2^{N-1}$ data points to hide a difference from $N-1$ questions on an alphabet of $N+1$ letters.

Together, on the whole non-rigid range $K < N$:
$$K \;<\; m(N,K) \;\le\; 2^K,$$
with the right-hand bound tight exactly at the critical window.

---

## Where the collapse happens

That leaves the real question. On the critical window the invariant is at the ceiling $2^{N-1}$. Widen the alphabet, keeping $K$ fixed, and it can only fall (any collision on a narrow alphabet is a collision on a wider one). How far, and how fast?

For $K = 2$ the whole profile is now known, and it is abrupt:
$$m(N,2) = \begin{cases} \text{no collision exists}, & N \le 2,\\ 4, & N = 3,\\ 3, & N \ge 4.\end{cases}$$
The invariant jumps straight from the ceiling $4$ to the floor $3$ with no intermediate value, and the drop happens the instant the alphabet reaches $\{0,1,2,3,4\}$. The witness is $\{0,3,3\}$ versus $\{1,1,4\}$: three elements each, with equal sums ($6$) and equal sums of squares ($18$), separated only at cubes ($54$ versus $66$).

Then it becomes a hunt for narrow ideal solutions — and here allowing *repeated* entries pays off spectacularly. The classical degree-$3$ ideal solution, known since the nineteenth century, is $\{0,4,7,11\}$ versus $\{1,2,9,10\}$, which needs an alphabet of twelve letters. But if the bags may repeat entries, one can do far better:

- **Degree $3$, alphabet $\{0,\dots,7\}$:** $\{1,1,6,6\}$ versus $\{0,3,4,7\}$. Counts $4$ and $4$; sums $14$ and $14$; sums of squares $74$ and $74$; sums of cubes $434$ and $434$. Fourth powers: $2594$ versus $2738$. Hence $m(N,3) = 4$ for every $N \ge 7$.
- **Degree $4$, alphabet $\{0,\dots,18\}$:** $\{0,4,8,16,17\}$ versus $\{1,2,10,14,18\}$, agreeing in all five power sums $5, 45, 625, 9585, 153409$ and diverging at fifth powers. Hence $m(N,4)=5$ for every $N \ge 18$.
- **Degree $5$, alphabet $\{0,\dots,16\}$:** $\{0,3,5,11,13,16\}$ versus $\{1,1,8,8,15,15\}$, agreeing through order $5$ ($6, 48, 580, 7776, 109444, 1584288$) and diverging at order $6$. Hence $m(N,5)=6$ for every $N \ge 16$.

**Theorem (The floor is reached in every small degree).** *For each $K$ with $1 \le K \le 5$ there is an alphabet on which the minimal collision has exactly $K+1$ elements — the least value the floor permits.*

Look again at that list of minimal alphabets: $d(3) = 7$, $d(4) = 18$, $d(5) = 16$. The degree-$5$ problem needs a *narrower* alphabet than the degree-$4$ one. Whatever governs the width required for an ideal solution, it is not monotone in the degree — a small, concrete piece of arithmetic irregularity sitting inside an otherwise smooth-looking picture.

And the invariant leaves the ceiling long before it reaches the floor. On $\{0,\dots,5\}$, the six-element pair $\{1,1,1,4,4,4\}$ versus $\{0,2,2,3,3,5\}$ agrees through cubes ($6, 15, 51, 195$) and so already brings $m(N,3)$ down to $6$, well under the Prouhet ceiling $8$, two letters short of the ideal threshold $7$. On $\{0,\dots,8\}$, the seven-element pair $\{1,1,1,5,6,6,8\}$ versus $\{0,2,2,3,7,7,7\}$ shows $m(N,4) \le 7$, ten letters below the ideal threshold $18$. The full profile of the degree-$3$ invariant, obtained by exhaustive search over all bags of the relevant sizes, reads
$$m(4,3)=8,\quad m(5,3)=6,\quad m(6,3)=6,\quad m(7,3)=4,$$
a staircase from ceiling to floor — not a cliff, as at $K=2$, but not a gentle slope either.

One more structural simplification makes such searches feasible: a smallest collision can always be taken **disjoint**. Any letter common to both bags contributes the same amount to every power sum on both sides, so deleting it preserves all the agreements and shrinks the bags. The minimum is therefore always attained by a pair with no letter in common — which cuts the search space dramatically.

---

## Why any of this matters

There is a practical reading. Moments are the cheapest possible summary of data: streaming algorithms, sketching, privacy-preserving statistics and method-of-moments estimators all replace a data set by a short vector of power sums. The results above say precisely when that vector is a faithful surrogate — $\min(N, n)$ moments, and no fewer — and precisely how an adversary could exploit a shorter summary. If you publish moments up to order $K$ over an alphabet of size $N+1$, then the smallest data set whose summary is forgeable is $m(N,K)$ items; below the critical window, at $K = N-1$, that number is $2^{N-1}$, so on small alphabets forgery is exponentially expensive; at wider alphabets it collapses to $K+1$, so publishing one moment fewer than everything can be very nearly free to fake.

There is also a purely mathematical reading. The Prouhet–Tarry–Escott problem — find two multisets of equal size with equal power sums up to a given order — has been studied since the 1750s, and ideal solutions are known only up to degree $11$, with degree $10$ still missing. The invariant $m(N,K)$ is a natural completion of that question: not just *does* an ideal solution exist, but *how much room* does it need, and what does the cost look like on the way down from the exponential ceiling to the linear floor?

For $K \le 5$ the floor is reached. For $K = 2$ the entire descent is charted. In between — for the value of the minimal ideal alphabet $d(K)$ in general, for the shape of the staircase between the critical alphabet and $d(K)$, for whether the non-monotonicity $d(5) < d(4)$ is an accident or the beginning of a pattern — the picture is still open. That is a good place for a subject to be: the framework settled, the extremes computed, and a concrete, checkable question left in the middle.

The last moment, it turns out, is always the one that matters.
