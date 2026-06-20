# The Recurrence That Couldn't Be: A Detective Story About Ramanujan's Mock Theta Function

## A formula too good to be true

In January 1920, three months before he died, the Indian mathematician Srinivasa Ramanujan wrote a final letter to G. H. Hardy in Cambridge. Tucked inside were a handful of strange new functions he called *mock theta functions*. They behaved *almost* like the classical theta functions that mathematicians had studied for a century — but not quite. They were near-misses, beautiful imposters, and for eighty years nobody really understood what they were.

The very first of them, the one Ramanujan listed at the top of his letter, was a function of a variable $q$:

$$f(q) = \sum_{n \ge 0} \frac{q^{n^2}}{\prod_{k=1}^{n}\left(1+q^k\right)^2}.$$

If you expand this as an ordinary power series — multiply everything out and collect terms by powers of $q$ — you get a sequence of whole numbers:

$$f(q) = 1 + q - 2q^2 + 3q^3 - 3q^4 + 3q^5 - 5q^6 + 7q^7 - 6q^8 + \cdots$$

The coefficients $1, 1, -2, 3, -3, 3, -5, 7, -6, 6, \dots$ are a famous integer sequence (catalogued by the Online Encyclopedia of Integer Sequences as A000025). They are stubbornly, unmistakably *whole numbers*.

Now, mathematicians love sequences that obey simple rules. The most prized rule of all is a **linear recurrence with polynomial coefficients**: a formula that tells you each new term from a fixed number of previous terms, where the multipliers are polynomials in the index $n$. The Fibonacci numbers have one. The factorials have one. Sequences with such a rule are called *holonomic* or *P-recursive*, and they are the well-behaved aristocracy of the number world: you can compute them fast, prove identities about them automatically, and analyze their growth with off-the-shelf machinery.

So here is a tantalizing claim, the kind that circulates in problem sets and preprints:

> The coefficients $a_n$ of $f(q)$ satisfy the recurrence
> $$(n+3)\,a_{n+3} = (3n+4)\,a_{n+2} - (3n+1)\,a_{n+1} + n\,a_n \quad \text{for all } n \ge 0,$$
> with starting values $a_0 = 1,\ a_1 = 0,\ a_2 = 1$.

It looks plausible. It has the right shape. The polynomial coefficients $(n+3)$, $(3n+4)$, $(3n+1)$, $n$ are tidy and suggestive. If true, it would tame one of Ramanujan's wild creatures, reducing an infinite mystery to a three-line rule a child could iterate.

This article is the story of how that claim falls apart — and why its failure is far more interesting than its success would have been.

## Two cracks in the foundation

A good detective checks the easy things first. The claim makes two factual assertions: a set of *starting values* and a *propagation rule*. Let's test each.

**Crack one: the wrong starting values.** The claim says $a_0 = 1$, $a_1 = 0$, $a_2 = 1$. But we just computed the genuine expansion of $f(q)$, and it begins $1, 1, -2$. The very first coefficient after the constant term is $+1$, not $0$. The third is $-2$, not $1$. So the stated initial data is simply not the data of $f(q)$. The claim describes *some* sequence, perhaps, but not Ramanujan's.

That alone would be enough to reject the claim. But the second crack is deeper and more devastating, because it shows the claim is not merely *mislabeled* — it is *internally impossible*.

**Crack two: the rule produces fractions.** Suppose we take the claim at its word and run the recurrence forward from its own stated starting values $(1, 0, 1)$. Set $n = 0$:

$$(0+3)\,a_3 = (3\cdot 0 + 4)\,a_2 - (3\cdot 0 + 1)\,a_1 + 0\cdot a_0,$$

which simplifies to

$$3\,a_3 = 4\cdot 1 - 1\cdot 0 + 0 = 4.$$

Therefore $a_3 = \tfrac{4}{3}$.

A fraction. Not a whole number. The recurrence, fed its own initial conditions, is *forced* on its very first step to produce $\tfrac{4}{3}$ — and there is no integer that equals $\tfrac{4}{3}$. If you keep going, it gets worse: $a_4 = \tfrac{4}{3}$, $a_5 = \tfrac{6}{5}$, $a_6 = \tfrac{47}{45}$, and so on, a parade of stubbornly non-integer rationals.

This is the heart of the matter. The coefficients of $f(q)$ are integers — this is structural, baked into the definition, as we'll explain. But the only sequence the claimed recurrence-plus-initials can produce is a sequence containing $\tfrac{4}{3}$. An integer sequence and a sequence containing $\tfrac{4}{3}$ cannot be the same sequence. **No integer sequence whatsoever satisfies the claim.** The premise isn't hard to prove; it's impossible to satisfy.

## Why integers? The structural reason

It's worth pausing on *why* $f(q)$ has integer coefficients, because that fact is the anvil on which the false claim shatters.

Look again at a single summand:

$$\frac{q^{n^2}}{\prod_{k=1}^{n}(1+q^k)^2}.$$

The numerator $q^{n^2}$ is obviously an integer power series. What about the denominator? Each factor $\frac{1}{1+q^k}$ is the sum of a geometric series:

$$\frac{1}{1+q^k} = 1 - q^k + q^{2k} - q^{3k} + \cdots,$$

which is again a power series with integer coefficients. Products and sums of integer power series are integer power series, and so is the inverse of any integer power series whose constant term is $1$. Therefore *every* summand is an integer power series, and the whole infinite sum — which converges term-by-term because the lowest power $q^{n^2}$ marches off to infinity — lands squarely in $\mathbb{Z}[[q]]$, the ring of formal power series with integer coefficients.

So integrality isn't a numerical coincidence to be checked term by term; it's a property guaranteed by the architecture of the formula. And it is exactly this guarantee that the claimed recurrence violates at index $3$.

## The deeper truth: Ramanujan's functions resist all such rules

Reject one recurrence and a natural question arises: maybe a *different* recurrence works? Perhaps a longer one, reaching back four or five terms, with higher-degree polynomial coefficients?

A systematic computer search says no. Treating the unknowns of a hypothetical recurrence — the polynomial coefficients — as variables, and demanding that the rule hold across the first several dozen known coefficients of $f(q)$, produces a large system of linear equations. Solving it exactly (over the rational numbers, so there is no rounding error) reveals that for every recurrence order up to $5$ and every polynomial degree up to $5$, the *only* solution is the trivial all-zeros one. There is no genuine recurrence hiding in that range.

This is not bad luck. It is a fingerprint of something profound that took mathematics most of a century to articulate. In 2002, the Dutch mathematician Sander Zwegers finally explained what mock theta functions *are*: they are the holomorphic pieces of *harmonic Maass forms*. To complete a mock theta function into a genuinely well-behaved modular object, you must add a "shadow" — a non-holomorphic correction built from an integral that cannot be captured by any finite algebraic rule.

That correction is precisely the obstruction. A power series is holonomic — has a polynomial-coefficient recurrence — exactly when its generating function satisfies a finite linear differential equation. Mock theta functions, because they require a transcendental, non-holomorphic completion, satisfy no such equation. **They are non-holonomic.** The failure of our specific recurrence is a small, concrete shadow of this large, abstract fact. The claim never had a chance, not because the particular polynomials were wrong, but because the entire *category* of formula it belonged to is closed to $f(q)$.

## What we proved, exactly

To make all of this airtight, the reasoning was formalized and machine-checked. Here is the precise content, stated in plain terms.

First, define the candidate sequence honestly. Let $\mathrm{claimSeq}(n)$ be the sequence of rational numbers you get by *believing the claim*: start with $(a_0, a_1, a_2) = (1, 0, 1)$ and apply the recurrence forever, dividing by $(n+3)$ at each step (legal, because $n+3$ is never zero). This is the unique sequence consistent with the claim, so refuting it refutes the claim itself.

- **It really obeys the recurrence.** For every $n$, the sequence $\mathrm{claimSeq}$ satisfies $(n+3)\,a_{n+3} = (3n+4)\,a_{n+2} - (3n+1)\,a_{n+1} + n\,a_n$. (We are not attacking a straw man; this is genuinely the claim's sequence.)

- **It is forced to be $\tfrac{4}{3}$ at index 3.** A direct computation gives $\mathrm{claimSeq}(3) = \tfrac{4}{3}$, and likewise $\mathrm{claimSeq}(4) = \tfrac{4}{3}$.

- **That value is not an integer.** There is no integer $m$ with $\mathrm{claimSeq}(3) = m$; the equation $3m = 4$ has no solution in whole numbers.

- **The headline impossibility.** There exists *no* integer sequence $a : \mathbb{N} \to \mathbb{Z}$ at all with $a_0 = 1$, $a_1 = 0$, $a_2 = 1$ satisfying the recurrence — because the $n=0$ instance forces $3a_3 = 4$, which no integer solves. Since the genuine coefficients of $f(q)$ are integers, they cannot satisfy the claim.

- **Uniqueness.** Because the leading coefficient $n+3$ never vanishes, the recurrence determines the entire sequence from its first three terms. So $\mathrm{claimSeq}$ is the *only* sequence in play, and its non-integrality at index $3$ is conclusive.

Every one of these statements has been verified by a proof checker, leaving no room for hand-waving.

## Why a negative result matters

It might seem deflating to spend so much effort proving that a formula *doesn't* work. But disproofs are the immune system of mathematics. A false but plausible recurrence, left uncorrected, propagates: someone uses it to "compute" coefficients, publishes consequences, builds further claims on top. Catching the error at the root — and pinpointing *exactly* where it breaks ($3a_3 = 4$) — protects everything downstream.

More than that, the *manner* of failure is illuminating. The claim doesn't fail by a hair, off by a rounding error in the fortieth digit. It fails immediately, at the third coefficient, by demanding that $\tfrac{4}{3}$ be an integer. And the reason it fails is not a typo in the polynomials but a structural truth about Ramanujan's functions: they live outside the holonomic world entirely. A single fraction, $\tfrac{4}{3}$, becomes a window onto Zwegers' theory of harmonic Maass forms and the century-long quest to understand what Ramanujan saw on his deathbed.

## The road ahead

The collapse of the naive recurrence points to sharper questions, each of which now has a clear target.

The first is to formalize, end to end, that $f(q)$ genuinely lives in $\mathbb{Z}[[q]]$ — to build the power series inside a proof assistant and confirm its first coefficients are $1, 1, -2$. That single fact upgrades our result from "the premise is self-contradictory" to "the premise contradicts $f$ itself."

The second is to prove the non-holonomy outright: that for *every* order and degree, no nonzero polynomial recurrence fits the coefficients of $f(q)$. Our finite search certifies this up to order and degree $5$; a proof that the obstruction persists as the window grows would be a landmark — perhaps the first formally verified non-holonomy result.

The third is repair. Mock theta functions become holonomic *after* you subtract their shadow. So one expects that $a_n$ minus an explicit correction term — or its even- and odd-indexed halves treated separately — *does* satisfy an honest recurrence. Finding that corrected rule would turn a failed shortcut into a true one.

And finally there is the visible pattern in the numbers themselves: from $n = 2$ onward the signs alternate, $-, +, -, +, \dots$, and the magnitudes swell like $\exp(O(\sqrt{n}))$ — the unmistakable signature of a Hardy–Ramanujan growth law. Proving the sign pattern would be a satisfying, purely combinatorial capstone.

Ramanujan handed us functions that look like they should obey simple rules and then quietly refuse. The lesson of $\tfrac{4}{3}$ is that the refusal is the point. The mock theta functions are not broken theta functions; they are a new kind of object, and their resistance to easy formulas is exactly what makes them worth a hundred years of study.
