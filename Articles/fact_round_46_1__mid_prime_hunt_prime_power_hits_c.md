# The Hidden Ledger: How Repeated Small Primes Explain Which Numbers Factor Easily

## A number's secret budget

Pick a whole number at random — say $1{,}048{,}575$ — and ask a deceptively simple question: is it built only out of small prime bricks? For $1{,}048{,}575 = 3 \cdot 5^2 \cdot 11 \cdot 31 \cdot 41$, the largest brick is $41$. If your idea of "small" means "at most $50$", this number passes. If it means "at most $13$", it fails.

Numbers that pass such a test have a name: they are called **smooth**. Formally, a positive integer $v$ is **$B$-smooth** if every prime dividing $v$ is at most $B$. The threshold $B$ is called the *factor base bound*, and the primes $p \le B$ are the *factor base*.

Smooth numbers are the hidden engine of modern integer factorization. Every serious factoring algorithm of the last forty years — the quadratic sieve, the number field sieve, and their descendants — works the same way: it generates a torrent of candidate values, throws away all the ones that are not $B$-smooth, and assembles the survivors into a giant linear-algebra problem over the two-element field $\mathbb{F}_2$. The whole cost of the computation is governed by one number: **what fraction of your candidates survive the smoothness test?**

That yield is notoriously hard to predict in practice. Asymptotically, the answer is elegant: if $\Psi_B(x)$ denotes the count of $B$-smooth integers in $[1, x]$, and you set
$$u = \frac{\log x}{\log B},$$
then $\Psi_B(x) \approx x \cdot \rho(u)$, where $\rho$ is the Dickman function. The parameter $u$ measures how many "layers" of factor-base primes it takes to build a typical candidate, and $\rho$ decays super-exponentially in $u$. But in the *tight-$u$ regime* — where real sieves live, with $u$ between roughly $2$ and $5$ — the asymptotic formula is a blunt instrument. Practitioners want a per-instance dial: given this batch of candidates, at this bound $B$, how many will survive?

This article is about a structural discovery that answers a piece of that question, and about the surprisingly clean mathematics underneath it.

## The empirical clue

A sequence of experiments tried to build exactly such a per-instance predictor. The baseline model used the obvious features: the size of the candidates, the bound $B$, the implied parameter $u$, and — crucially — the *squarefree hit indicators*: for each factor-base prime $p$, does $p$ divide the candidate value?

That baseline works well, but it leaves a residual: a stubborn, structured chunk of variance in the yield that no combination of those features can explain. Several natural candidates for the missing ingredient were tested and failed. The fraction of mid-sized primes in the factor base added an estimated $+0.019$ to out-of-sample $R^2$, with a confidence interval straddling zero — statistically indistinguishable from noise. The density of quadratic residues fared even worse, at $+0.004$.

Then one feature landed. Add, for each small prime $p \le 13$, the indicator "$p^2$ divides the candidate", and out-of-sample $R^2$ jumps by $\mathbf{+0.0892}$, with confidence interval $[0.041, 0.125]$ — comfortably clear of zero, over and above the full baseline.

*Repeated small primes.* Not which small primes divide your number, but which ones divide it **twice**.

Why should that matter? The mathematics that follows explains it completely — and the explanation turns out to be exact, not statistical.

## A divisibility test is a change of budget

Here is the first and most important structural fact.

> **Exact Rescaling Theorem.** Let $B \ge 1$ and let $m$ be a positive $B$-smooth integer. Then the number of $B$-smooth $v \in [1, x]$ divisible by $m$ is exactly
> $$\#\{v \le x : v \text{ is } B\text{-smooth},\ m \mid v\} = \Psi_B\!\left(\left\lfloor x/m \right\rfloor\right).$$

The proof is a bijection, and it is the kind of proof that makes you sit up: the map $v \mapsto v/m$ sends the hit set to the full smooth pool below $x/m$, with inverse $w \mapsto m \cdot w$. It is well defined in both directions because smoothness passes to divisors and is multiplicative — dividing a smooth number by a divisor keeps it smooth, and multiplying two smooth numbers keeps them smooth. The identity is exact, with no error term whatsoever.

The smoothness of $m$ is genuinely required, not a technical convenience. Take $B = 5$, $m = 7$, $x = 100$: no $5$-smooth number below $100$ is divisible by $7$, so the left-hand side is $0$, while $\Psi_5(14) = 10$. The failure is total.

The meaning is this: **a divisibility feature is not a new arithmetic condition on the pool — it is a change of the smoothness budget.** Conditioning on $p^2 \mid v$ does not carve out some exotic subset. It simply reruns the identical smoothness question at the shrunken bound $x/p^2$.

Specializing to the feature the experiment found:
$$\#\{v \le x : v \text{ is } B\text{-smooth},\ p^2 \mid v\} = \Psi_B\!\left(\lfloor x/p^2 \rfloor\right) \qquad (p \le B \text{ prime}).$$
And two prime-power features fire together exactly as often as one feature with the combined modulus: for distinct primes $p, q \le B$,
$$\#\{v \le x : v \text{ is } B\text{-smooth},\ p^2 \mid v,\ q^2 \mid v\} = \Psi_B\!\left(\lfloor x/(p^2q^2) \rfloor\right).$$
The hit events are not independent; they compose multiplicatively, and the rescaling theorem tells you exactly how.

One can go further and grade the pool by the *exact* multiplicity of $p$. Writing $v_p(v)$ for the exponent of $p$ in $v$:
$$\#\{v \le x : v \text{ is } B\text{-smooth},\ v_p(v) = j\} = \Psi_B\!\left(\lfloor x/p^j \rfloor\right) - \Psi_B\!\left(\lfloor x/p^{j+1} \rfloor\right).$$
The entire valuation spectrum is a telescoping family of rescaled smooth counts.

## Why the effect lives at small $B$

Now translate the rescaling into the language of the $u$-parameter. If $p^2 \mid v$ and both are positive, then
$$u(v) = u(v/p^2) + \frac{2 \log p}{\log B},$$
exactly. A $p^2$-hit splits the smoothness budget cleanly into the cofactor's budget plus a fixed toll of $2\log p / \log B$. In inequality form, provided $p^2 \le x$,
$$u\!\left(\lfloor x/p^2 \rfloor\right) \;\le\; u(x) - \frac{2\log p}{\log B}.$$
(The hypothesis $p^2 \le x$ is necessary: when $x < p^2$ the floor collapses to zero and the logarithm degenerates.)

The toll $2\log p / \log B$ is where the whole empirical story lives, because of one trivial-looking but decisive observation:

> **Antitonicity of the toll.** For $1 < B \le B'$ and $p \ge 1$,
> $$\frac{2 \log p}{\log B'} \;\le\; \frac{2 \log p}{\log B}.$$

The *same* prime-power hit costs *more* budget at a *smaller* factor base bound. At $B = 10^6$, hitting $4$ costs $2\log 2 / \log 10^6 \approx 0.10$ of your $u$-budget — a rounding error. At $B = 13$, it costs $2 \log 2 / \log 13 \approx 0.54$ — over half a unit of $u$, and since $\rho$ decays super-exponentially, half a unit of $u$ is enormous.

This is precisely why the effect shows up as a *tight-$u$* phenomenon and why the experiment found it with primes $p \le 13$: at small $B$, a value with $p^2 \mid v$ has its smoothness budget disproportionately consumed by small-prime powers. That is structure the marginal squarefree-hit features simply cannot see.

## What the squarefree features are blind to

That last claim can be made into a theorem — in fact, into two.

> **Blindness Theorem.** Let $p$ be a prime dividing $v \ne 0$, and let $k \ge 0$. Then $v$ and $v \cdot p^k$ have *identical* squarefree-hit vectors, while their budgets differ by exactly $k$:
> $$\mathrm{sqf}_B(v \cdot p^k) = \mathrm{sqf}_B(v), \qquad \Omega(v \cdot p^k) = \Omega(v) + k.$$

Here $\mathrm{sqf}_B(v)$ is the set of factor-base primes dividing $v$, and $\Omega(v)$ counts prime factors *with multiplicity* — the discrete smoothness budget. Multiplying by a prime you already have changes nothing the squarefree features can detect, yet drives the budget up without bound. The fibres of the squarefree feature map therefore contain values of arbitrarily different budget: **no function of squarefree hits can recover the budget.** This is not a weak correlation; it is an exact impossibility.

The prime-power features, by contrast, split these cases apart. If $p$ divides $v$ exactly once, then $v$ and $p v$ have the same squarefree vector, but $p$ belongs to the prime-power vector of $pv$ and not to that of $v$. The refinement is strict.

There is also an unavoidable pigeonhole. There are only $2^{\pi(B)}$ possible squarefree-hit vectors, where $\pi(B)$ counts the factor-base primes. So:

> **Collision Theorem.** If $2^{\pi(B)} < \Psi_B(x)$, then two *distinct* $B$-smooth values in $[1,x]$ share the same squarefree-hit vector. No predictor built from squarefree hits alone can separate them.

At $B = 2$ this is unconditional and completely explicit: for $x \ge 4$ the pool $\{1, 2, 4, \dots\}$ of powers of two already outgrows the two available vectors.

## All of the budget, and nothing but the budget

The deepest result in this circle of ideas is that the prime-power hit features do not merely add *some* information about the budget. They carry *all* of it, and they carry it linearly.

> **Budget Decomposition Theorem.** For all $B, x$,
> $$\sum_{\substack{v \le x \\ v\ B\text{-smooth}}} \Omega(v) \;=\; \sum_{p \le B} \; \sum_{j=1}^{\lfloor \log_2 x\rfloor} \#\{v \le x : v \text{ is } B\text{-smooth},\ p^j \mid v\},$$
> and equivalently, after rescaling,
> $$\sum_{\substack{v \le x \\ v\ B\text{-smooth}}} \Omega(v) \;=\; \sum_{p \le B} \; \sum_{j=1}^{\lfloor \log_2 x\rfloor} \Psi_B\!\left(\lfloor x/p^j\rfloor\right).$$

The proof is a double counting argument of unusual cleanliness. For a smooth $v$, its budget is the sum of its factor-base valuations, $\Omega(v) = \sum_{p \le B} v_p(v)$, because primes outside the factor base contribute nothing. And each individual valuation is itself a *count of hits*: for a prime $p$ and $v \ne 0$,
$$v_p(v) = \#\{ j \in [1, J] : p^j \mid v \}$$
as soon as the window $J$ reaches the valuation — which it always does at $J = \lfloor \log_2 x \rfloor$, since every prime valuation of $v \le x$ is bounded by $\log_2 v \le \log_2 x$ (a $p$-power dividing $v$ is at least the corresponding power of $2$). Substituting and exchanging the order of summation gives the identity on the nose.

Read this out loud and the empirical result stops being surprising: **the prime-power hit features are a linear coordinate system for the smoothness budget.** They are not a heuristic proxy that happens to correlate; they reconstruct the budget exactly, by a linear identity. And the squarefree features are precisely the single layer $j = 1$ of this decomposition — one slice of a stack that has $\lfloor \log_2 x \rfloor$ layers.

The completeness goes even further:

> **Complete Invariant Theorem.** Two positive $B$-smooth integers that trigger exactly the same prime-power hit features are equal. That is, if $v, w > 0$ are $B$-smooth and $p^j \mid v \iff p^j \mid w$ for every prime $p \le B$ and every $j \ge 1$, then $v = w$.

The prime-power profile is a perfect fingerprint of a smooth number. The $j=1$ truncation, as we saw, provably is not.

## The cost side: hits spend budget without buying relations

There is a beautiful complementary fact that explains why the prime-power feature *predicts* the sieve's yield rather than merely mimicking it.

The linear-algebra stage of a sieve works over $\mathbb{F}_2$: it looks for sub-families of smooth values whose product is a perfect square, which is to say, sub-families whose exponent vectors sum to zero modulo $2$. Now observe:

> **The $\mathbb{F}_2$ Blind Spot.** For any finite index set $S$, any $p > 0$, and any weights $w_i$,
> $$\prod_{i \in S} (p^2 w_i) \text{ is a perfect square} \iff \prod_{i \in S} w_i \text{ is a perfect square}.$$

The proof factors out $(p^{|S|})^2$ and uses that multiplying by a nonzero square never changes squareness. Consequently, a family of $p^2$-hit values has a square sub-product exactly when the family of their *cofactors* does. The doubled prime contributes an even exponent to every member and therefore vanishes modulo $2$.

**A prime-power hit spends smoothness budget without buying a new relation direction.** It is pure cost, no benefit — which is exactly why it is such a good predictor of yield: it shifts the budget without perturbing the relation-collection combinatorics.

Concretely: given $\pi(B) + 1$ positive $B$-smooth values, all of them $p^2$-hits, some nonempty sub-family has a perfect-square product — and that very relation is already present, unchanged, among the rescaled cofactors.

## How big is the hit sub-pool?

One might worry that $p^2$-hits are too rare to matter. They are not, and the count is exact combinatorics rather than an estimate.

Let $P_B = \prod_{p \le B} p$ be the primorial of the factor base. If $P_B^m \le x$, then every exponent vector with entries in $\{0, 1, \dots, m\}$ yields a distinct $B$-smooth value below $x$ (unique factorization makes the assignment injective), so
$$\Psi_B(x) \;\ge\; (m+1)^{\pi(B)}.$$
Conversely, the valuation vector of a smooth $v \le x$ has all entries bounded by $\lfloor\log_2 x\rfloor$, and determines $v$, so
$$\Psi_B(x) \;\le\; \left(\lfloor \log_2 x \rfloor + 1\right)^{\pi(B)}.$$
The pool is bracketed between two $\pi(B)$-th powers: **polynomial in $\log x$ of degree exactly $\pi(B)$.** Applying the lower bound at the rescaled bound $x/p^2$ shows the $p^2$-hit sub-pool is *itself* exponentially large in $\pi(B)$. A feature firing on an exponentially large sub-pool is not a corner case.

For the one exactly solvable instance, everything can be computed in closed form. At $B = 2$ the smooth pool is precisely the powers of two, so $\Psi_2(x) = \lfloor \log_2 x\rfloor + 1$, and for $x \ge 4$,
$$\#\{v \le x : 4 \mid v,\ v \text{ a power of } 2\} + 2 = \Psi_2(x).$$
Hitting $4 = 2^2$ consumes exactly two units of the base-two budget — the sharp form of the general inequality, with equality and no slack.

## What it all means

Step back, and a single picture emerges. The prime-power hit features are the **graded coordinates of the multiplicative monoid of smooth numbers**. The stack of layers indexed by $j$ splits neatly in two:

- The $j = 1$ layer — squarefree hits — is the abelianization modulo squares. It sees the $\mathbb{F}_2$ relation data that the sieve consumes, and nothing else.
- The higher layers, $j \ge 2$, see the smoothness budget, and nothing else.

These two kinds of information are *disjoint by theorem*, not merely weakly correlated in a sample. That is why adding prime-power indicators to a squarefree-hit baseline produces genuine, out-of-sample predictive gain: the new features live in a direction the old ones provably cannot reach. And it is why the gain concentrates at small $B$: the budget toll $2 \log p / \log B$ that the new features measure is antitone in $B$, so it is exactly in the tight-$u$ regime — the regime real factoring runs inhabit — that this direction carries the most weight.

The story also has a moral about model-building in number theory. Two plausible features — mid-prime fractions and quadratic-residue density — failed, and one succeeded. In hindsight the difference is structural, not statistical: the successful feature has an exact identity behind it, an identity that says it reconstructs the very quantity the sieve's yield depends on. When a feature works, it is worth asking not just *how much* it explains, but *what theorem* it is a shadow of. Here, the theorem was waiting: a divisibility test is a change of budget, and the budget is exactly the sum of the hits.

## Open horizons

The exact identities turn every question about hit features into a question about $\Psi_B$ at two nearby arguments. That reduction suggests a sharp conjecture: for fixed $B$ and $x \to \infty$, the $p^2$-hit fraction $\Psi_B(x/p^2)/\Psi_B(x)$ should tend to $1$ at rate $1 - \pi(B) \cdot (2\log p)/\log x + O((\log x)^{-2})$, and in the tight-$u$ regime, with $B$ growing alongside $x$, it should approach the Dickman ratio
$$\frac{\rho\!\left(u - \tfrac{2\log p}{\log B}\right)}{\rho(u)}.$$
The exact identity is settled; what remains is an asymptotic for $\Psi_B$ itself. The entire predictive content of the prime-power feature, on this view, is nothing more and nothing less than the local logarithmic derivative of the smooth-counting function.

That is a satisfying place for a hunt to end: not with a fitted coefficient, but with an identity.
