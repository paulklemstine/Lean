# Position Pays: Why Counting Down From the Square Root Breaks a Speed Limit

*An old trick of Fermat's, turned on its head, finds the hidden factor of a balanced number five times faster on average — and a short formula, $1/(\sqrt r - 1)$, says exactly when and why.*

---

## The oldest algorithm in the book

Give someone a number like $N = 10403$ and ask for its factors. Almost everyone does the same thing: try $2$, then $3$, then $5$, and keep going until something divides. This is **trial division**, probably the oldest factoring method there is. It has one useful guarantee. If $N$ is composite, it has a factor no bigger than $\sqrt N$, so you never need to test past $\lfloor \sqrt N \rfloor$.

Now take the case cryptographers care about most: a **semiprime** $N = pq$, the product of two primes $p \le q$. Below the square root there is exactly one divisor waiting, namely the smaller prime $p$. Every other test is wasted. If you count upward from $2$, the number of tests you spend is

$$\text{ascending cost} = p - 1,$$

because you visit $2, 3, \dots, p$ and stop at $p$.

For $N = 10403 = 101 \times 103$, that means 100 tests. Here is the surprise. Start at $\lfloor\sqrt{10403}\rfloor = 101$ and count **down**, and the very first test succeeds.

## Fermat's instinct, applied to division

Pierre de Fermat noticed long ago that a number whose two factors are close together sits very close to a perfect square. His method starts at $\sqrt N$ and walks *upward*, looking for a square $a^2$ with $a^2 - N$ also a square. That gives $N = a^2 - b^2 = (a-b)(a+b)$. For near-squares it finishes almost at once.

The idea studied here takes the same instinct and applies it to plain trial division. Keep the list of candidate divisors $\{2, 3, \dots, \lfloor\sqrt N\rfloor\}$ exactly as it is, and change only the **order** of the tests: begin at the square root and count downward. Call this the *sqrt-descending* order. It needs no new arithmetic, no sieve and no cleverness about residues. It only reshuffles the queue.

Count the cost the same way as before. Going down from $\lfloor\sqrt N\rfloor$ to $p$ visits

$$\text{descending cost} = \lfloor \sqrt N \rfloor + 1 - p$$

candidates. Put the two formulas side by side and a small piece of bookkeeping falls out:

> **Complementarity.** For every semiprime, the ascending cost plus the descending cost equals $\lfloor\sqrt N\rfloor$ exactly.

The two scans share the pool between them, and $p$ is the point where they meet. When $p$ sits near the top of the pool, the descending scan wins. When $p$ sits near the bottom, the ascending scan wins.

## Where the crossover lives: the wall at four

So which one wins? Because $\lfloor\sqrt{pq}\rfloor$ is roughly $p\sqrt{q/p}$, the answer depends only on the **balance ratio** $r = q/p$. A short computation puts the crossover at $\sqrt N \approx 2p$, which is $q \approx 4p$, and the exact integer statement is clean:

> **The balance wall.** If $q < 4p$, the descending scan costs at most one test more than the ascending scan (so it ties or wins). If $q \ge 4p$, the ascending scan wins by at least two tests.

Near-squares come out especially well. The descending cost never exceeds about half the gap between the factors:

$$2\,(\text{descending cost} - 1) \;\le\; q - p.$$

So a "twin-type" semiprime, one whose factors differ by at most $3$, is cracked by the descending scan in **at most two tests**, however many digits it has.

## The law of the speedup

Now drop the floor function and treat the costs as smooth quantities: $p$ for the ascending scan and $\sqrt{pq} - p = p(\sqrt r - 1)$ for the descending one. The factor $p$ cancels and a strikingly simple law is left:

$$\boxed{\;S(r) \;=\; \frac{1}{\sqrt r - 1}\;}$$

This is the **positional speedup** at balance $r$, the factor by which the descending order beats the ascending one. Several facts follow from it, each a short exercise in algebra:

- **It decays with imbalance.** $S$ is strictly decreasing for $r > 1$. Balanced numbers gain the most and lopsided ones the least.
- **It is unbounded.** As $r \to 1^+$, $S(r) \to \infty$. Pick any target speedup you like, a thousand or a million, and there is a band of balance ratios just above $1$ where the descending order beats it.
- **Every threshold has an explicit window.** Position pays more than a factor $k$ *exactly* when
$$1 < r < \left(1 + \tfrac1k\right)^2.$$
Speedups above $10$ need $r < 1.21$. Speedups above $2$ need $r < 2.25$. At $r = 4$ the speedup is exactly $1$, which is the wall again.

## A speed limit, and how position slips past it

The law becomes more than a curiosity when you set it against an earlier result.

The usual way to speed up trial division is to skip candidates by their **residues**. You never test even numbers beyond $2$, or you test only numbers that are $\pm 1 \pmod 6$, and so on. Call any rule of the form "fix a modulus $M$, and test only those candidates whose remainder mod $M$ lies in a chosen set of allowed classes" a **residue dial**. A previously established theorem puts a hard ceiling on all of them:

> **The residue cap.** No residue dial, for any modulus and any choice of allowed classes, improves the expected number of divisibility tests by more than a factor of $4/3$.

The reason is that, from the point of view of residues, the hidden prime looks *uniformly spread out*. Sieving by residues throws away work in proportion to the candidates it discards, but it cannot make the true factor turn up earlier than average.

Position can. Line the law up against the cap and you find the exact place where they cross:

> **The barrier map.** For every balance ratio $1 < r < 49/16$, the positional speedup strictly exceeds the speedup of *every* residue dial, whatever its modulus and filter. At $r = 49/16$ the two are exactly equal, since $\sqrt{49/16} = 7/4$ gives $S = 1/(3/4) = 4/3$. Beyond $49/16$, position never beats $4/3$.

So the residue cap is real, but it is a cap on *one kind of information*. On the whole stratum of semiprimes whose factors are within a ratio of about $3.06$ of each other, information about position is worth more than any amount of information about residues.

## Why the two results don't contradict each other

That raises a question. If no residue trick can beat $4/3$, how can a simple reordering beat it by a factor of five? Both statements are true, and a clean theorem explains why.

Model the search abstractly. There are $n$ candidates, and the hidden factor is candidate $i$ with some probability weight $\mu_i$. A visitation order is just a permutation, and its expected cost is the weighted average position at which you hit the target. To keep the comparison honest, measure every order against a **sham**: the same order started at a uniformly random point and wrapped around cyclically. The sham costs $(n+1)/2$ tests on average, the same as guessing blindly.

> **The separation theorem.** Some visitation order strictly beats the sham *if and only if* the weights $\mu_i$ are not all equal.

There are two directions:

- If the target's distribution over candidates is uniform, **every order costs exactly the sham**. Order cannot help.
- If it is not uniform, then some cyclic shift of *any* order strictly beats the sham. A further fact pins down the sham itself: averaged over all $n$ cyclic shifts, any order costs exactly the sham. The sham is therefore a genuine average of real orders, which is what makes it a fair control.

This theorem is the dividing line. Residue classes see a uniform marginal, so they hit the cap. Position sees a marginal skewed by balance, so it gets through.

The theorem also says which order is best. By the classical **rearrangement inequality**, the optimal order visits candidates in decreasing order of probability. This is the *Bayes order*. If the hidden factor is more likely to sit near $\sqrt N$ than far below it, which is exactly the situation for a balance-concentrated population of semiprimes, the Bayes order *is* the sqrt-descending order:

> **Fermat's order is Bayes-optimal** for every prior that increases towards $\sqrt N$, and it strictly beats the sham whenever that increase is strict.

## What the experiment saw

The theory was built to explain a measurement. In a controlled experiment of $30{,}000$ semiprimes in each of five batches, all with factors drawn from primes below $2^{17}$, the sqrt-descending order gave an **expected trial-division speedup of $5.19\times$**. A sham control gave only $1.65\times$ under identical conditions, so the real-to-sham ratio was $3.16$. A guess made beforehand, that positional effects would stay below $2\times$, was refuted.

Split by balance stratum, the speedup broke into **two separate mechanisms whose gradients run in opposite directions**:

| balance stratum $q/p$ | $1$–$1.25$ | $1.25$–$2$ | $2$–$4$ |
|---|---|---|---|
| (a) balance bet (Fermat-type) | $20.67\times$ | $4.74\times$ | $1.97\times$ |
| (b) range truncation | $4.35\times$ | $4.73\times$ | $6.91\times$ |

**Mechanism (a)** is the balance bet described above. The law $S(r)$ predicts its shape exactly, and the algebra gives sharp bands for each stratum:

- On $1 < r \le 5/4$, every single instance has speedup at least $S(5/4) = 4 + 2\sqrt5 \approx 8.47$.
- On $5/4 \le r \le 2$, the speedup lies between $1 + \sqrt2 \approx 2.41$ and $4 + 2\sqrt5 \approx 8.47$.
- On $2 \le r \le 4$, it lies between $1$ and $1 + \sqrt2 \approx 2.41$.

The experiment measures a ratio of *expected* costs, not an average of ratios. The bands still apply because of a small fact sometimes called the **mediant principle**: if every ratio $a_i/b_i$ in a finite sample lies in $[L, U]$, then so does $(\sum a_i)/(\sum b_i)$. Each measured number, $20.67$, $4.74$ and $1.97$, falls inside its proved band.

**Mechanism (b)** is something else. Because every prime in the pool is below $2^{17}$, the size of $N$ alone tells you that $p \ge N/2^{17}$. You can then simply skip every candidate below that bound. The exact accounting is clean, and it shows the two mechanisms are **orthogonal**:

> **Truncation saves exactly $L - 2$ ascending tests and zero descending tests.** If you learn that $p \ge L$, the ascending scan drops from $p - 1$ to $p + 1 - L$ tests, while the descending scan, which never went below $p$ anyway, costs exactly what it did before.

Mechanism (a) works at the top of the pool. Mechanism (b) works at the bottom, and it depends on how close the larger factor sits to the pool's ceiling, not on balance. That is why it grows in the lopsided strata exactly where the balance bet fades. The opposite gradients are not a fitted effect. They follow from the algebra.

## Honesty in the ledger

The experiment kept a ledger of what did *not* work, and two entries are worth repeating.

First, a learned "Bayes ordering" built by a classifier scored $3.37\times$ on held-out data, which is less than plain sqrt-descending. Its apparent edge on training data was inflation. The honest computable frontier is the simple rule: count down from the square root. Second, an earlier claim that a smooth posterior would collapse to a fixed order was refuted at the edge of the finite pool, where truncation distorts the distribution. A designed sanity check, that a particular degenerate ordering reproduces the ascending scan, still passed in $30{,}000$ out of $30{,}000$ cases.

All of these figures count *divisibility tests*, which is a measure of information, not wall-clock time.

## A last duet: Fermat and trial division share the work

One identity ties the whole story back to Fermat. For odd primes $p \le q$, write $a = (p+q)/2$, the point where Fermat's upward walk from $\sqrt N$ succeeds. The descending trial scan walks from $\lfloor\sqrt N\rfloor$ down to $p$, and Fermat walks from $\lfloor\sqrt N\rfloor$ up to $a$. Together they cover the interval $[p, a]$ exactly once:

$$\text{descending cost} + \bigl(a - \lfloor\sqrt N\rfloor\bigr) \;=\; \frac{q-p}{2} + 1.$$

The two classical methods are two halves of a single walk outward from the square root. That suggests a natural next experiment: walk both ways at once and stop at whichever succeeds first.

## The takeaway

There is a speed limit on what residues can tell you about a hidden prime, and it is $4/3$. It is a genuine theorem. But it is a limit on one kind of knowledge, the kind that sees the target as uniformly spread out. Knowing *where* a factor is likely to sit is a different kind of knowledge, and it obeys a different law, $1/(\sqrt r - 1)$. That law crosses the residue cap at exactly $r = 49/16$ and has no ceiling as the factors approach each other. For balanced semiprimes, the cheapest improvement to the oldest algorithm in number theory is not to skip work but to do the same work in Fermat's order.
