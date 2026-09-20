# The Wall That Wasn't: How a Symmetry Made a Number Vanish

## A measurement that looked like a discovery

Suppose you are handed a large number $N$ and told, correctly, that it is the product of two unknown primes, $N = pq$. You cannot factor it — nobody can, for the sizes used in modern cryptography. But you are allowed to run cheap, coarse measurements on the pair: you may compute residues, sums, products, small modular fingerprints. The question is not "can you factor $N$?" It is subtler and, in some ways, more interesting:

> Can these cheap measurements tell you *anything at all* about which of the two hidden primes is the bigger one?

A single bit. That is all we are asking for. If a measurement device could reliably whisper "the larger factor is the one that plays the role of $q$", it would be a crack in the wall — a foothold, a place to push.

So a measurement device was built. Call it a **battery**: a chain of small modular "fields", each one a modulus $m$ from a fixed list such as $3, 5, 7, 11$. For a pair $(p, q)$, each field records the two residues
$$(p+q) \bmod m \quad\text{and}\quad (pq) \bmod m,$$
and the fields are chained together in a positional, base-$m$ way into a single integer code. Four fields give a code in the range $0 \le \text{code} < (3\cdot 5\cdot 7\cdot 11)^2 = 1{,}334{,}025$ — a readout with about twenty bits of room.

Then came the statistic. Take thousands of ordered pairs, label each one by which coordinate carries the larger prime, and measure the *mutual information* between that label and the code: the standard number of bits that knowing one thing tells you about the other. The measurement came back at **$0.0469$ bits**. Small — but not zero. Something, apparently, was leaking.

Then came the control. Shuffle the labels randomly, destroying any real relationship, and re-measure. Two hundred times. The shuffled data returned a mean of **$0.0469$ bits**, with a standard deviation of $0.0014$. The observed value sat $0.05$ standard deviations above its own null distribution.

The signal was exactly equal to its own noise floor. The entire reading was an artifact of the measuring instrument.

This article is about what happened next: the empirical verdict was replaced by a theorem, and the theorem turned out to be sharper, cleaner, and more general than the experiment could ever have been. The leakage is not "small". It is not "below the sensitivity floor of $\pm 0.003$ bits". It is **exactly zero**, and it is zero for a reason that has nothing to do with statistics at all.

## Why an average can be biased upward

First, the instrument. Mutual information between a label $\ell$ and a code $k$, estimated from data, is usually computed by the *plug-in* recipe: build the contingency table of observed frequencies $\hat p(\ell, k)$, and evaluate
$$\hat I \;=\; \sum_{\ell}\sum_{k} \hat p(\ell,k)\,\log_2\frac{\hat p(\ell,k)}{\hat p(\ell)\,\hat p(k)}.$$

This functional has a property that is both its greatest virtue and its most dangerous trap: **it is never negative**. That is the finite form of Gibbs' inequality, which in turn is nothing more than the elementary estimate $\log x \le x - 1$ applied one cell at a time. If $p$ is a probability vector and $q$ a nonnegative vector of total mass at most $1$ which vanishes only where $p$ does, then
$$\sum_i p_i \log \frac{p_i}{q_i} \;\ge\; 0 .$$
Apply this with $p$ the joint table and $q$ the product of its own margins, and you get $\hat I \ge 0$ always.

One-sidedness means noise cannot cancel. A truly independent pair of variables has mutual information $0$, the minimum possible value; any random wobble in a finite sample can only push the estimate *up*. The estimator is therefore biased upward, systematically, and the bias grows as the table gets sparser — as the number of distinct code values approaches the number of samples.

How bad can it get? In the extreme, arbitrarily bad. Here is the cleanest possible instance. Take a population in which label and code are *exactly* independent — the uniform $2 \times 2$ table with all four cells equal to $1/4$, whose true mutual information is exactly $0$ bits. Draw two samples from it. Whatever you draw, the empirical table is a permutation matrix: two cells of mass $1/2$, two cells empty. Its plug-in reading is exactly $1$ bit — the largest value a binary label can carry. And now shuffle: the only relabelling available is the swap, which turns one permutation matrix into the other, and reads $1$ bit again. Observed value $1$ bit; permutation null mean $1$ bit; null standard deviation $0$; truth $0$ bits; $z$-score numerator identically zero.

That is the entire pathology in miniature. **A positive reading that matches its own permutation null is not weak evidence of a weak effect. It is the exact signature of estimator bias.**

## The sparse regime, in closed form

The two-sample example is a caricature, but the real experiment was living in the same country. Its four-field code was nearly injective on the sample: in a run of $3995$ ordered prime pairs, $3597$ distinct codes appeared — about ninety per cent of samples carried a code no other sample shared.

In the idealised limit of that regime — every sample carrying its own distinct code — everything can be computed exactly, and the result is startling:

> **Sparse Reading Theorem.** Let a sample of size $n$ carry labels $\ell_1,\dots,\ell_n \in \{\text{true},\text{false}\}$ and $n$ pairwise distinct code values. Then the plug-in mutual information between label and code equals the label entropy exactly:
> $$\hat I \;=\; H(\ell) \;=\; -\sum_{b} \frac{n_b}{n}\log_2\frac{n_b}{n},$$
> where $n_b$ is the number of samples carrying label $b$ — *whatever* the relationship between the labels and the codes.

The proof is a two-line count. When the code is injective on the sample, knowing the code determines the sample, hence determines the label: the conditional entropy $H(\ell \mid \text{code})$ is identically zero, and the identity $\hat I = H(\ell) - H(\ell \mid \text{code})$ collapses.

Three consequences follow immediately, and together they *are* the experimental signature.

* The reading depends only on the label counts. It knows nothing about any dependence, real or imagined.
* Therefore every relabelling of the sample gives exactly the same reading: **the permutation null is a point mass.** Observed minus null mean is identically $0$; the null spread is identically $0$.
* And the reading can never exceed $1$ bit, the entropy of a binary label — it sits *at the ceiling* whenever the labels are balanced, which by construction they are.

So in the sparse regime the plug-in statistic is not an estimator of mutual information at all. It is a relabelling-invariant function of the label margin, wearing an information-theoretic costume. A $z$-score built from it has a vanishing numerator over a vanishing denominator — precisely the reported $z = +0.05$ with $\text{sd} = 0.0014$.

## The real answer: a symmetry, not a small number

All of that explains why the measurement was uninformative. It does not yet say what the truth is. The truth comes from a completely different direction — from symmetry.

Look again at what the battery actually reads. Each field records $(p+q) \bmod m$ and $(pq) \bmod m$. These are the two *elementary symmetric functions* of the pair: they are the coefficients of the monic quadratic whose roots are $p$ and $q$,
$$X^2 - (p+q)X + pq .$$
Everything the battery can see is a function of that polynomial — of the unordered pair — and a polynomial does not remember the order in which you listed its roots. In the language of Galois theory: the battery reads only the invariant part of the pair under the symmetry that exchanges the two roots.

This is a theorem about the chain, not a slogan. Because the chaining rule at each field consumes only the two trace residues, the whole chained code factors through the map $(p,q) \mapsto (p+q,\, pq)$: two pairs with the same sum and the same product produce the same code, no matter how many fields you chain. In particular the code of $(q,p)$ equals the code of $(p,q)$ always.

Now the payoff:

> **Factor-Blindness Theorem.** Let $S$ be any finite population of ordered pairs of naturals that is *swap-closed* — if $(p,q) \in S$ then $(q,p) \in S$ — and *off-diagonal* — no member has $p = q$. Let $c$ be any readout that is *symmetric*, i.e. $c(q,p) = c(p,q)$. Then the joint law of (which-factor label, readout) over $S$ is an exact product law, and the mutual information between them is **exactly $0$ bits**.

No sampling. No null. No sensitivity floor. Zero, by a counting argument so short it fits in a sentence: exchanging the two coordinates is a fixed-point-free involution of the population; it preserves every fiber of the readout (because the readout is symmetric) and flips the which-factor label (because the pair is off-diagonal). So inside each fiber, the members labelled "first is bigger" are in perfect bijection with the members labelled "second is bigger". **Every fiber splits exactly in half.** A table in which each column splits in the same fixed ratio is, cell by cell, the product of its margins — and the mutual information of a product table is zero.

Applied to the four-field chained battery: on every swap-closed, off-diagonal population, its which-factor leakage is exactly $0$ bits. The wall was never $0.0469$ bits high. It was infinitely high, and the $0.0469$ was the instrument breathing.

## Is the instrument blind too?

An honest sceptic now objects: maybe the functional simply cannot see anything. A ruler that reads zero for every object is not evidence that the object has no length.

Two results close that door.

The first is the **equality case**: a plug-in reading of zero holds *if and only if* the contingency table is exactly the product of its margins. Any deviation from independence — a single cell off by any amount — forces a strictly positive reading. This needs the strict form of Gibbs' inequality, $\log x < x - 1$ for $x \ne 1$, plus one genuinely subtle step: the discrepancy must be exhibited at a cell where the observed table is *positive*, since a mismatch hiding on the null set is invisible to the logarithm. A mass-balance argument supplies it — if two probability vectors agree wherever the first is positive, the total masses force them to agree everywhere.

The second is a **power check**. Take the tiniest swap-closed, off-diagonal population there is, $S = \{(3,5),(5,3)\}$, and equip it with the maximally indiscreet readout: the one that simply publishes the which-factor label. That readout is *not* symmetric, and its reading on this population is exactly $1$ bit — the maximum a binary label can carry. So on the very same population family where the battery reads $0$, an asymmetric readout is caught at full strength. Symmetry of the readout is load-bearing, not decorative, and the battery's zero is a genuine finding rather than an instrument that never moves.

## Capacity is not leakage

There is one more distinction the theory forces, and it matters for anyone designing such a device.

The four-field battery's chained code is bounded: each field contributes two residues below $m$, hence a factor $m^2$ of alphabet, so the code always lands below $(3\cdot5\cdot7\cdot11)^2 = 1{,}334{,}025$. By the maximum-entropy bound — itself another corollary of the same Gibbs inequality, comparing the readout distribution against the uniform one — the entropy of the readout can never exceed
$$\log_2 1{,}334{,}025 \;\approx\; 20.35 \text{ bits}.$$
In practice, on tens of thousands of prime pairs, the battery realises around $14$ bits of that room. Those bits are real. They are simply all *symmetric* bits: facts about the unordered pair, the trace and the norm, the coefficients of the quadratic.

**Capacity and leakage are logically independent.** A battery can be a fat pipe and still be perfectly blind in one specific direction. Chaining more fields raises the ceiling and buys more symmetric content; it buys exactly zero additional which-factor bits. Not "asymptotically zero", not "diminishingly few" — zero, for every width of chain.

## Where the zero comes from, and how far it goes

The proof above used a halving argument tailored to the swap involution. But nothing in it depends on the group having two elements, or on the objects being pairs of integers.

Let a finite group $G$ act on a finite population $S$, let the readout $c$ be $G$-invariant, and let the label be a **torsor coordinate**: for every member $x$ and every target label $\ell$ there is a *unique* group element $g$ with $\mathrm{lab}(g \cdot x) = \ell$. (For the swap action on off-diagonal pairs, the which-factor label is exactly such a coordinate: there is precisely one of the two group elements that makes the bigger factor land where you want it.)

> **Orbit-Blindness Theorem.** Under these hypotheses, the joint law of (label, readout) is a product law, so the leakage is exactly $0$ bits — for every group $G$, every invariant readout, and every torsor label.

The proof is a double count rather than a halving. Inside a readout fiber $F$, count the pairs $(x, g) \in F \times G$ with $\mathrm{lab}(g\cdot x) = \ell$ in two ways. Summing over $x$ first gives $|F|$, because the torsor property supplies exactly one valid $g$ per element. Summing over $g$ first gives $|G|$ times the size of the $\ell$-cell, because each group element permutes the fiber. Hence every label cell of every fiber has size exactly $|F|/|G|$ — which *is* the product condition.

Two instances are worth naming. The two-factor wall is the case $G = \mathbb{Z}/2$, recovered as a corollary. And for multi-prime moduli — three or more hidden factors — the relevant group is the full symmetric group $S_n$, acting on ordered $n$-tuples by permuting coordinates, with the label being the entire **ordering pattern**: the permutation that lists the coordinates in increasing order. That pattern is an $S_n$-torsor coordinate on tuples with distinct entries, and so:

> On any population of $n$-tuples of pairwise distinct factors closed under coordinate permutation, *any* permutation-invariant readout carries exactly $0$ bits about the ordering of the factors — for every $n$.

Concretely: the six orderings of $(3,5,7)$, read by the symmetric battery $v \mapsto \left(\sum_i v_i \bmod 13,\ \prod_i v_i \bmod 17\right)$, produce a single code shared by all six; the ordering leakage is $0$, while the non-invariant readout "report the first coordinate" gives away $\log_2 3 \approx 1.585$ bits about that ordering (out of the $\log_2 6 \approx 2.585$ bits it contains). The wall is not an arithmetic accident of two factors. It is representation theory: **no invariant function separates an orbit.**

## The arithmetic instance — and the one exception

Everything so far assumed an abstract swap-closed population. The population that factoring actually cares about is concrete: the ordered factorisations of a fixed $N$,
$$\{(d, N/d) : d \mid N\}.$$
Is it swap-closed? Yes — and the reason is a piece of elementary arithmetic that deserves its name: division by a divisor is an involution of the divisor lattice, $N/(N/d) = d$. Swapping $(d, N/d)$ gives $(N/d, d)$, which is the pair belonging to the divisor $N/d$.

Is it off-diagonal? Here the theory produces a sharp, purely arithmetic boundary. A fixed point of the involution means $d = N/d$, that is $N = d^2$. So:

> **The divisor population of $N$ is off-diagonal precisely when $N$ is not a perfect square.** For every non-square $N$, the four-field chained battery — and indeed any symmetric readout — carries exactly $0$ bits about which cofactor of $N$ is the larger one, over the whole population of ordered factorisations of $N$.

Every semiprime $N = pq$ with $p \ne q$ — the case cryptography cares about — is a non-square, so the flagship statement covers it.

And the exception is real, not technical. Take $N = 15$: the four ordered factorisations $(1,15), (3,5), (5,3), (15,1)$, two distinct battery codes, a genuinely non-constant readout, and leakage exactly $0$. Now take $N = 36$ or $N = 100$: nine ordered factorisations each, one of them diagonal ($(6,6)$, $(10,10)$), and the same readout leaks $0.1022$ bits. For $N = 49$, with only three factorisations, it leaks $0.2516$. The lone diagonal pair has no swap partner, the exact halving fails, and the zero fails with it. Off-diagonality is a boundary in the arithmetic, not a convenience in the proof.

## What to take away

Three lessons, each of which outlives the particular experiment that prompted them.

**A null distribution is not a control if the statistic cannot move.** Permutation tests presuppose that shuffling destroys something. In the sparse regime, shuffling destroys nothing the statistic can see, because the statistic is a function of the label counts and shuffling preserves them. A null with a tiny standard deviation is not reassurance about precision; it is a warning that the statistic is nearly deterministic, and a $z$-score computed from it is a ratio of two vanishing quantities.

**Where a symmetry exists, look for it before you measure.** Thousands of samples, hundreds of shuffles, and careful bookkeeping produced the number $0.0469 \pm 0.0014$. A single observation — the readout is a function of $p+q$ and $pq$, and those do not change when you swap $p$ and $q$ — produces the exact answer $0$, on every population, for every chain width, with no data at all.

**Verify the exact object, not a smaller cousin.** In the course of checking the original claim, a first pass tested a two-field chain instead of the four-field one that was actually flagged. It passed trivially — and it was the wrong object. Both the two-field and the four-field readings were eventually shown to be inside their own nulls, but the near miss is the more useful souvenir: an experiment that verifies the wrong thing can look exactly like an experiment that verifies the right thing.

The programme's original claim was that the battery is factor-blind, with a caveat about a small unexplained residual. The caveat is gone. What remains is a statement about symmetry, and it is exact: whatever a trace-routed battery learns about $N$ — and it can learn many bits — it learns nothing whatsoever about which of the two factors is the larger. The wall is not high. There is no wall; the direction simply does not exist.
