# How Much Does a Code Really Cost the Guesser? An Exact Answer, for Every Alphabet

Imagine a game of pure patience. Somewhere behind a locked door is a secret
string of symbols — a password, a genetic sequence, the noise that corrupted a
transmitted message. You cannot see it, but you *can* propose guesses, one at a
time, and each time a bell rings "wrong" until, finally, it rings "right." The
only cost in this game is your patience: how many guesses did it take?

This deceptively simple game, called **guesswork**, sits at the crossroads of
cryptography, information theory, and the physics of information. It measures the
resilience of a secret not by whether it *can* be broken, but by how much toil
its breaking demands. And it hides a beautiful, exact law about what happens when
the secret is protected by a *code*.

## The patience of an optimal adversary

Let's make the game precise. Suppose the secret is a block of $m$ symbols drawn
from an alphabet of $q$ letters — think $q = 2$ for bits, $q = 4$ for DNA bases,
$q = 26$ for letters. If every possible string is equally likely (the hardest
possible case for the guesser, the *maximal-entropy* source), there are $q^m$
candidates, all indistinguishable in advance.

A clever adversary who knows the probability distribution guesses in the smartest
possible order: most likely first, least likely last. When everything is equally
likely, any order is as good as any other, so the adversary simply works through
the list, and the number of guesses $G$ needed is equally likely to be
$1, 2, 3, \ldots, q^m$.

How do we summarize the "typical" toil? Averaging $G$ itself is too crude; the
interesting cryptographic quantities live in the **moments** of $G$. For a
parameter $\rho > 0$ — a knob that tunes how much we care about rare, expensive
outcomes — we study the $\rho$-th moment

$$ \mathbb{E}[G^\rho] = \frac{1}{q^m} \sum_{j=1}^{q^m} j^\rho. $$

The exponential growth rate of this quantity, measured per symbol, is the
*guessing exponent*. It is the true currency of the game.

## A code changes the game

Now add protection. A **coset code** of rate $R$ is a structured constraint that
tells the adversary something: instead of $q^m$ candidates, only $q^{k_m}$ remain
possible, where the code dimension grows so that $k_m / m \to R$. A rate $R$ close
to $1$ barely helps; a small $R$ shrinks the search space dramatically. The
narrowed moment becomes

$$ M_q(k_m) = q^{-k_m} \sum_{j=1}^{q^{k_m}} j^\rho. $$

The central question is disarmingly concrete: **by exactly how much does the code
reduce the guessing exponent?** Not "roughly," not "up to constants" — exactly.

## The answer: a clean, universal shift

Here is the result at the heart of this work.

> **Exact Coset-Guesswork Exponent (uniform source).**
> For any alphabet size $q \ge 2$ and any $\rho > 0$, the unconstrained guessing
> exponent (per symbol, in units where $q$ symbols cost one) is exactly $\rho$.
> A rate-$R$ coset code lowers it to exactly $\rho R$. The reduction is therefore
> $$ \rho - \rho R = \rho(1-R), $$
> the guessing exponent lost to the code's redundancy $1-R$ — and this holds
> **identically for every alphabet size $q$.**

Two things make this striking. First, it is *exact*: the constrained exponent is
not bounded by $\rho R$, it equals $\rho R$ in the limit. Second, it is
*universal*: whether you are guessing bits, DNA, or dictionary words, the code
costs the guesser precisely $\rho(1-R)$ in exponent — the alphabet size cancels
out completely once you measure information in the natural units of $q$.

## Why it's true: the anatomy of a power sum

The whole argument rests on estimating the innocent-looking sum
$S_N = \sum_{k=1}^{N} k^\rho$. Every term is at most the largest, $N^\rho$, so
$S_N \le N \cdot N^\rho = N^{\rho+1}$. Conversely, the *top half* of the terms —
the ones from $N/q$ up to $N$ — are each at least $(N/q)^\rho$, and there are
enough of them to guarantee $S_N \ge (N/q)^{\rho+1}$ (up to a harmless constant).
Setting $N = q^j$, this becomes a clean two-sided sandwich:

$$ q^{(j-1)(\rho+1)} \;\le\; \sum_{k=1}^{q^j} k^\rho \;\le\; q^{j(\rho+1)}. $$

The two ends differ only by a fixed factor $q^{\rho+1}$ — a constant that is
utterly negligible once we take logarithms and divide by the block length $m$.
Taking base-$q$ logarithms, the sum's growth rate is pinned to $\rho + 1$ per unit
of $j$.

Now assemble the moment. Its logarithm splits into two pieces:

$$ \log_q M_q(k_m) = \underbrace{-k_m}_{\text{density}} \;+\; \underbrace{\log_q \sum_{j=1}^{q^{k_m}} j^\rho}_{\approx\, k_m(\rho+1)}. $$

The second piece grows like $k_m(\rho+1)$; the first, the **density factor**
$-k_m$, is where the code's cost lives. Adding them gives $k_m \rho$, and dividing
by $m$ (using $k_m/m \to R$) yields exactly $\rho R$. The unconstrained case is
just $R = 1$, giving $\rho$.

This decomposition is the conceptual payoff. The redundancy penalty $\rho(1-R)$
comes *entirely* from the density factor $q^{-k_m}$, whose base-$q$ logarithm is
simply $-k_m$ — a number that knows nothing about $\rho$'s fine structure or the
alphabet's size. That is precisely *why* the shift is universal: it is a pure
counting effect, not an artifact of the alphabet.

## Where the leading $\rho$ comes from

One loose end: why is the *unconstrained* exponent exactly $\rho$? This is a
statement about entropy. The **Rényi entropy** of order $\alpha$ of a distribution
$P$ over $q$ letters is

$$ H_\alpha(P) = \frac{1}{1-\alpha} \log_q \sum_i P(i)^\alpha. $$

For the uniform law $P(i) = 1/q$, a short computation shows $H_\alpha = \log_q q = 1$
for *every* order $\alpha \ne 1$ — the maximal-entropy source carries exactly one
unit of information per symbol, no matter how you weight it. The classical
Arıkan–Merhav theory says the guessing exponent is $\rho$ times a Rényi entropy of
a specific order $1/(1+\rho)$; at the uniform source that entropy is $1$, so the
exponent saturates at $\rho$. The moment calculation above rederives this from
scratch and then shows how a code chips it down to $\rho R$.

## Why this matters

Guesswork is the honest measure of a secret's strength against a patient
brute-force adversary. Knowing the guessing exponent *exactly* — and knowing
exactly how much a code changes it — turns a qualitative intuition ("codes make
things harder to guess") into a quantitative design rule ("a rate-$R$ code costs
the guesser precisely $\rho(1-R)$ in exponent, whatever your alphabet").

The universality across alphabets is the practical prize. A cryptographer working
over bytes, a biologist reasoning about DNA-based storage, and a communications
engineer analyzing a $q$-ary channel are, it turns out, all playing the same game
with the same scorecard. The clean separation of the exponent into a *source term*
(here, the flat $\rho$ from maximal entropy) and a *code term* ($-\rho(1-R)$) is a
template: change the source and only the first term moves; change the code and only
the second does.

## The road ahead

The maximal-entropy case is the cleanest possible laboratory, and settling it
exactly clears the way for richer sources. The natural next step is a genuinely
biased $q$-ary source, where the flat $\rho$ is replaced by $\rho$ times the Rényi
entropy of the true distribution — but the code term $-\rho(1-R)$ should survive
untouched, because it lives in the density factor, not the source. Beyond that lie
random codes (where the dimension itself is drawn at random), matching lower bounds
that would turn the estimate into an exact limit for every sequence of code
dimensions, and sharper, second-order corrections that capture the finite-block
behavior a real engineer actually sees.

For now, one crisp fact stands complete: protect a maximal-entropy secret with a
rate-$R$ code over any alphabet, and you will cost the guesser exactly $\rho(1-R)$
in exponent — no more, no less, no matter the letters you write in.
