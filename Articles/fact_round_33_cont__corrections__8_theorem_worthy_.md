# When a Fallen Hypothesis Moves Nothing

*How a one-line test from convex optimisation closed an apparent opening in deterministic factoring, and why the corrections that came with it matter more than the opening did.*

---

## A record and a rumour

Breaking a large number into its prime factors is the problem behind RSA cryptography. It is also one of the oldest open problems in computation. The fastest practical methods, such as the number field sieve, run in sub-exponential time, but their analyses rest on heuristics or on randomness. If we demand a **deterministic** algorithm, one that never flips a coin and always succeeds, progress has been much slower.

For decades the deterministic benchmark was Strassen's method, with running time about $N^{1/4}$ for a number $N$. Lehman's elementary method, which tries small rational approximations of the ratio of the two factors, also runs in about $N^{1/3}$. In 2021 David Harvey published an algorithm with running time about $N^{1/5}$, up to logarithmic factors. That is the current record. It is an **upper bound**: nobody has proved that factoring needs time $N^{1/5}$, or even that it needs more than polynomial time in the number of digits. No unconditional super-polynomial lower bound for factoring is known in any reasonable model of computation.

Records invite rumours. One goes like this. Harvey's analysis uses several ingredients, one of them a step that finds the multiplicative order of an element. Order-finding came with a hypothesis, a ceiling on how large one of the algorithm's tables could be made. Suppose that hypothesis were removed. Could the exponent $1/5$ drop?

This article explains why the answer is no, and why the reason is general rather than special to this case. The same investigation also turned up a series of corrections to the record. Some made targets harder, some made them easier, and one removed a supposed impossibility. In research a caught error beats a retraction, and a clean "no" beats a vague "maybe".

## The shape of the record: three costs and one balance point

Logarithmic factors aside, Harvey's algorithm has two dials. Call them $a$ and $b$. The algorithm handles about $r = N^{a}$ candidate pairs of small integers, and it builds a "baby-step" table with about $m = N^{b}$ entries. Three kinds of work then compete:

- **the pair sweep**, costing about $N^{a}$, which goes through the candidate pairs;
- **the baby-step table**, costing about $N^{b}$, which is built once;
- **the giant sweep**, costing about $N^{1/2 - a/2 - b}$, which crosses the remaining search gap. Turning up either dial shrinks it.

The total cost is governed by the largest of the three exponents:

$$E(a,b) = \max\Big(a,\; b,\; \tfrac12 - \tfrac a2 - b\Big).$$

This is a tug of war. Raising $a$ or $b$ makes the giant sweep cheaper and the pair sweep or the table more expensive. The best setting is where all three are equal: $a = b = \tfrac12 - \tfrac a2 - b$, which gives $a = b = 1/5$, and the cost is $N^{1/5}$.

A detail that is easy to miss is that **all three costs are tied at the optimum**. No single term "dominates". Earlier accounts said that one particular term made up the whole leading cost. That is wrong. The table term and the pair term are co-leaders with the sweep. Measurements of the two summands in Harvey's own parameter formula give a ratio of exactly $1.000000$ across seven bit sizes, which matches this exact three-way tie.

## The slack-constraint lemma

Now back to the rumour. The ceiling in question limits the baby-step table to at most $N^{2/5}$ entries, so it imposes $b \le 2/5$. The optimum needs only $b = 1/5$.

Picture the cost $E(a,b)$ as a landscape. It is a bowl with flat faces, and its lowest point sits at $(1/5, 1/5)$. The ceiling is a fence at $b = 2/5$, well away from the bottom. Remove the fence and the lowest point stays where it was, because the fence was never touching it.

That picture is a theorem, and it is worth stating carefully because it applies far beyond factoring.

> **The Slack-Constraint Lemma.** Let $f$ be a convex function on a convex set $A$. Suppose a point $x$ minimises $f$ over the constrained region $A \cap C$, and suppose the constraint is *slack* at $x$: the set $C$ contains a whole neighbourhood of $x$. Then $x$ minimises $f$ over all of $A$. Removing the constraint cannot lower the optimum, and the constrained and unconstrained optimal values are equal.

The proof is two lines. Because $C$ surrounds $x$, every point of $A$ near $x$ is a feasible competitor, so $x$ is a *local* minimum of $f$ on $A$. For convex functions every local minimum is a global one: if some far-away point $y$ did better, then the points on the segment from $x$ to $y$, arbitrarily close to $x$, would also do better, by convexity.

Applied to Harvey's model, the cost $E$ is a maximum of three linear functions and so is convex. The fence $b < 2/5$ is an open region containing the optimum $(1/5,1/5)$. The lemma then says that removing the fence leaves the exponent at exactly $1/5$.

We can say more and draw the whole **phase diagram**. Put the ceiling at a general height $b \le c$:

- if $c \ge 1/5$, the ceiling is **slack** and the optimum is exactly $1/5$, whatever $c$ is;
- if $c < 1/5$, the ceiling is **active**. The optimum becomes exactly $(1-2c)/3$, attained at $a = (1-2c)/3$, $b = c$, and this is strictly larger than $1/5$.

So a ceiling affects the exponent **if and only if** it is active. Harvey's real ceiling, $c = 2/5$, is twice the critical value. In the exponent model the table could be a factor $N^{1/5}$ larger than the optimum needs. (An earlier account put this headroom at only a polylogarithmic factor, about $\lg^{0.8} N$. That understated it. At the level of exponents the headroom is a full power of $N$, so the conclusion is stronger, not weaker.) Harvey himself calls the order-finding step "negligible" in his analysis, and the lemma explains why that matters.

The practical lesson is a screening rule that any research programme can adopt:

> *Before claiming that the fall of a hypothesis moves an optimum, check whether that hypothesis's constraint is tight at the optimum.*

This one check rules out a whole family of "something fell, so something improves" arguments.

## Which cost does your filter actually cut?

Suppose that instead of removing a constraint you add a trick: a **filter** that discards most candidate pairs before they are examined. If the filter keeps only one pair in $N^{\sigma}$, the pair term drops from $a$ to $a - \sigma$. A filter might also cut the giant sweep, by $N^{\sigma_1}$ say. The balancing problem becomes

$$E_{\sigma_1,\sigma_2}(a,b) = \max\Big(a - \sigma_2,\; b,\; \tfrac12 - \tfrac a2 - b - \sigma_1\Big),$$

and solving it exactly gives a clean formula:

$$\text{optimum} = \frac15 - \frac{\sigma_2}{5} - \frac{2\sigma_1}{5}.$$

The optimiser is unique, and at it the three terms are again exactly equal.

The coefficients $1/5$ and $2/5$ have a meaning. They are the "shadow prices" of the three costs: the weights $(1/5, 2/5, 2/5)$ on (pairs, table, sweep) that make the weighted sum of the three exponents independent of the dials. A saving on a term buys exponent in proportion to that term's weight. Pair savings are the cheapest kind, at one fifth of the face value.

This settles a target that had been misquoted. The earlier record said that a pair filter of strength $N^{1/18}$ would bring the exponent down to $1/6$. The formula shows what that figure assumes:

- a filter that cuts **both** the pairs and the sweep by $N^{\sigma}$ reaches $1/5 - 3\sigma/5$, which equals $1/6$ exactly when $\sigma = 1/18$;
- a filter that cuts **only the pairs** reaches $1/5 - \sigma/5$, which equals $1/6$ exactly when $\sigma = 1/6$.

A pair filter has no effect on the sweep, whose dominant logarithmic cost comes from a smoothness sieve in Harvey's analysis. So the honest target is $\sigma = 1/6$, **three times harder** in the exponent than advertised. The most concrete goal in the record had been quietly understated by a factor of three.

## A free filter that nobody thought existed

In the same record, alongside that understated target, was a pessimistic claim: *no filter on Harvey's candidate pairs is known that keeps the right pair while discarding a matched quantity of others.*

That claim is false, and the counterexample is very simple. **Keep a pair $(a,b)$ only if $a \le b$.**

Why is this safe? In Lehman's method, the useful pair $(a,b)$ approximates the ratio $p/q$ of the two prime factors $p < q$, accurate enough that $|aq - bp| < b$. Suppose $a \ge b$. Since $q > 0$, this gives $aq \ge bq$, so $aq - bp \ge b(q-p) \ge b$, because $q - p \ge 1$. That contradicts the accuracy bound. So the good pair always has $a < b$, and the filter never throws it away. (Positivity of $p$ is genuinely needed. With negative "factors" the implication fails.)

How much does it save? The exact count follows from the symmetry $(a,b) \leftrightarrow (b,a)$, which matches pairs below the diagonal with pairs above it. Only the diagonal pairs $(a,a)$ with $a^2 \le r$ are left over, and there are $\lfloor\sqrt r\rfloor$ of them:

$$2\cdot\#\{(a,b): ab\le r,\ a\le b\} \;=\; \#\{(a,b): ab\le r\} \;+\; \lfloor \sqrt r\rfloor.$$

For $r = 100$, there are $482$ pairs and $246$ survive: $2 \cdot 246 = 482 + 10$. The filter halves the work up to a lower-order term. That is a constant factor, not an exponent. A constant-strength filter corresponds to $\sigma \approx 1/\log_2 N$, which tends to zero, so it gains a speed-up but never a smaller exponent. Even so, it refutes a stated impossibility: the space of sound filters is not empty, and the target of $\sigma = 1/6$ is hard but not known to be unreachable.

## The gap that cancels

A second family of ideas uses the $p-1$ method: if $p-1$ divides an exponent $e$, then $x^{e} \equiv 1 \pmod p$ for every base $x$, and $\gcd(x^{e}-1, N)$ can expose $p$. This works when **exactly one** of $p-1$ and $q-1$ divides $e$. If both do, the gcd is all of $N$. If neither does, it is typically $1$.

Write $p - 1 = g a$ and $q - 1 = g b$, where $g$ is the shared "gap" factor and the cofactors $a,b$ are coprime. A natural guess is that a large shared factor $g$ helps. Count the exponents that are multiples of $g$ in one full period $[0, gab)$ and reveal a factor:

- multiples of $ga$: there are $b$ of them;
- multiples of $gb$: there are $a$ of them;
- multiples of both, which means multiples of $gab$ because $a, b$ are coprime: only $0$.

Inclusion–exclusion gives exactly $a + b - 2$ revealing exponents, **whatever $g$ is**. The gap cancels. The reveal density is

$$\rho(a,b) = \frac{a+b-2}{ab},$$

and it depends only on the cofactors.

What is the best possible density? The record and a later correction disagreed: one said the supremum was $1/2$, the other said $1$. **Both were right, on different classes.**

- Along $a = 1$, meaning $p-1$ divides $q-1$, the density is $(b-1)/b$. This tends to $1$ but never reaches it, so the supremum over all classes is $1$.
- If neither of $p-1$, $q-1$ divides the other, so that $a, b \ge 2$, then $\rho \le 1/2$, with equality exactly when $a = 2$ or $b = 2$. This follows from the identity $ab - 2(a+b-2) = (a-2)(b-2) \ge 0$.

The "large Euler gap" framing gave credit to the wrong variable. What governs the reveal is how $p-1$ and $q-1$ split into cofactors, not their common part.

## Guards against fooling yourself

Another line of attack tries to cover the integers $1,\dots,n$ "by divisibility": find sets $S$ and $T$ so that every $k \le n$ divides some difference $s - t$. Two simple facts make any search for such coverings honest.

**Guard 1: keep the sets disjoint.** If $S$ and $T$ share an element $x$, the difference $x - x = 0$ is divisible by every $k$, and the "covering" succeeds for every $n$ without doing anything. For example, $S=\{0,5\}$ and $T=\{5,7\}$ "cover" $[1,1000]$, while the disjoint pair $S = \{0,5\}$, $T = \{7\}$ already fails at $k = 3$. Spurious 100% coverage was one of the retractions in this line of work.

**Guard 2: the divisor-mass barrier.** If $S$ and $T$ are disjoint, every $k \le n$ is a divisor of some nonzero $|s-t|$, so

$$n \;\le\; \sum_{s\in S,\ t\in T} d(|s-t|),$$

where $d(m)$ counts the divisors of $m$. If every difference has at most $D$ divisors, then $n \le |S|\,|T|\,D$. This counting argument is why generic coverings fail, and it shows where the remaining freedom has to be: in carefully chosen, highly composite differences. In the covering framework that would yield an integer-factoring exponent of $1/6$, that exponent is the framework's floor with no slack. Its sets have sizes governed by two parameters $\alpha, \beta$, and at the critical choice $\alpha = \beta = 1/3$ the covering budget $n^{2\beta + \alpha}$ equals exactly $n$, against roughly $n$ worth of divisibility to supply. There is no room to spare. This is the slack-constraint lemma in reverse: here the constraint is tight.

## Three more corrections

**Preconditions with logarithms fail only for a while.** A published lemma about large-order elements requires $\delta \ge N^{1/4}\log^8 N$. With $\delta = N^{1/3}$ and $N = 2^k$, raising to the twelfth power turns this into $k^{96} \le 2^k$. A claim had circulated that this fails "for every $N \ge 2^{96}$". It does not. Exponentials always overtake polynomials. The precondition fails exactly on the window $k \in [96, 949]$ (indeed on all of $2 \le k \le 949$) and **holds for every $k \ge 950$**. RSA-2048 moduli, with $k = 2048$, satisfy it comfortably. The overclaim had been made against an overclaim, and it needed correcting too.

**Count primes, not draws.** Only $163$ of the $38{,}635$ primes between $2^{19}$ and $2^{20}$ have $p-1$ free of prime factors above $13$, which is about $0.42\%$. A statistical test that samples "smooth" primes with replacement is really testing $163$ objects, not thousands of independent draws. Any p-value computed otherwise is inflated.

**One identity, five probes.** Along the "B-spine" of Berggren's tree of Pythagorean triples, $(3,4,5) \to (21,20,29) \to (119,120,169) \to \cdots$, the two legs always differ by exactly one: $a_k - b_k = (-1)^{k+1}$. Every gcd test built on $a_k - b_k$ therefore returns $1$, for every $N$. Five proposed probes turned out to be a single event that could never succeed.

## The real diagnosis

The last finding of this round is not a theorem. It is about how the research was done. An audit of the campaign's accumulated body of results found that **145 of 185** relevant prior write-ups had never been reread in thirty-two rounds of work. Two of the strongest negative results, one against a non-abelian (braid-group) route and one against a route through complex-multiplication orders, had been on file all along without being consulted. Three of this round's twelve lines of attack turned out to re-derive results that were already there.

This fits the slack-constraint lemma itself. That lemma is simple, and it settles a question that had been open across several rounds. What was missing was attention, not new insight.

## What remains open

The factoring record is still $N^{1/5}$, and it is still an upper bound and not a floor. The honest frontier is now narrower and better marked:

- a **pair filter of strength $N^{1/6}$**, not $N^{1/18}$. It is not known to be impossible, but the only free filter known gives a factor of two;
- a **constructive covering** in the divisibility framework, built from carefully chosen factorisations of a smooth integer, searched at $n = 10^4$ to $10^6$ with both guards enforced. The divisor-mass barrier says where to look and what cannot work;
- a general **"shadow-price" law**: for any cost given by a maximum of linear terms with unique balancing weights, a saving $\sigma_i$ on term $i$ should lower the optimum by exactly $\sum_i w_i \sigma_i$. The three-term case is proved. The general law would let anyone read off the target for any proposed trick before building it.

In a field with no lower bounds, closing an opening for a clear and general reason counts as progress.
