# The Price of a Guess, and the Discount for Structure

## A game of twenty questions with the universe

Imagine a locked door. Behind it is a secret string of bits — a password, a
cryptographic key, the exact pattern of static that corrupted a transmitted
message. You cannot see the secret, but you *can* make guesses, one at a time,
and each time an oracle tells you only "yes" or "no." How many guesses will it
take?

This deceptively simple question sits at the crossroads of cryptography, coding
theory, and information theory. It has a name: **guesswork**. And the number of
guesses you need — averaged, raised to a power, and tracked as the secret grows
longer — turns out to obey a beautifully precise law.

The central discovery we describe here is a *discount*. When the secret is not
an arbitrary string but is constrained to lie in a structured set — the kind of
structure that error-correcting codes impose on their messages — the difficulty
of guessing drops. Not by a fuzzy, approximate amount, but by an **exact,
closed-form exponent**. If the structure pins the secret down to a fraction $R$
of its possible freedom, the exponential cost of guessing falls by precisely
$\rho(1-R)$, where $\rho$ is the "risk sensitivity" of the guesser. This article
tells the story of that exponent and proves it from the ground up in the sharpest
case — the case of pure, maximal randomness.

## Why we count guesses raised to a power

Suppose an adversary must try candidates one by one until they hit the true
secret $x$. The number of trials is the **guessing rank** $G(x)$: if the
adversary's ordered list places $x$ in position $k$, then $G(x) = k$. A wise
adversary sorts candidates from most likely to least likely, so the rank is
small exactly when the secret is predictable.

Why not simply average $G(x)$? Because averages hide tail risk. A single
catastrophic secret — one that takes exponentially many guesses — can matter far
more than a thousand easy ones. To capture this, information theorists study the
$\rho$-th **moment** of guesswork,
$$
\mathbb{E}\left[ G(X)^{\rho} \right] = \sum_{x} P(x)\, G(x)^{\rho},
$$
where $\rho > 0$ is a knob. Small $\rho$ weights typical cases; large $\rho$
amplifies the worst cases, modeling a security-conscious analyst who fears the
rare disaster. Massey, Arıkan, and later Arıkan and Merhav showed that for a
secret of length $n$ drawn from an independent, identically distributed source,
this moment grows *exponentially* in $n$, and the growth rate is a single clean
number.

## The Arıkan–Merhav exponent

Let the secret be $n$ bits of noise, each bit independently $1$ with probability
$p$ and $0$ with probability $1-p$. The classical result says that the $\rho$-th
guesswork moment grows like $2^{n E(\rho, p)}$ where the exponent is
$$
E(\rho, p) = (1+\rho)\,\log_2\!\left( p^{\frac{1}{1+\rho}} + (1-p)^{\frac{1}{1+\rho}} \right).
$$
This is the **Arıkan–Merhav exponent**. The quantity inside the logarithm is,
up to normalization, a *Rényi entropy* of order $\frac{1}{1+\rho}$: guessing
difficulty is entropy, viewed through the lens of the risk parameter $\rho$.

The exponent is largest when the source is hardest to predict. That happens at
$p = \tfrac{1}{2}$, the fair coin, where every bit is a genuine surprise. Plugging
in $p = \tfrac12$:
$$
E\!\left(\rho, \tfrac12\right)
= (1+\rho)\log_2\!\left( 2 \cdot 2^{-\frac{1}{1+\rho}} \right)
= (1+\rho)\left( 1 - \tfrac{1}{1+\rho} \right)
= \rho .
$$
So at maximal entropy the guessing exponent is simply $\rho$. This is the
cleanest possible benchmark: a fair-coin secret of length $n$ costs, in the
$\rho$-th moment, essentially $2^{\rho n}$ guesses. We will *prove* this identity
along the way, not merely assert it.

## Enter structure: cosets and codes

Now change the game. Instead of an arbitrary secret, suppose the secret is
required to be *consistent with an error-correcting code*. A binary linear code
of **rate** $R$ carves the space of all $2^n$ strings into equal-sized bins
called **cosets**. Each coset is the set of all noise patterns that would produce
the same received, corrupted codeword. There are $2^{(1-R)n}$ cosets, and each
contains $2^{Rn}$ strings.

In many real problems — decoding a noisy channel, breaking a structured
cryptosystem — the adversary does not have to search the whole space. They know
which coset the secret lives in, and they only have to guess *within* that coset.
That is **constrained coset guesswork**: the candidate set shrinks from all
$2^n$ possibilities to the $2^{Rn}$ members of a single coset.

Intuitively, less to search means fewer guesses. But how much fewer, exactly, in
the exponent? The answer is the heart of this work:

> **The exact exponent shift.** Constraining the guess to a rate-$R$ coset lowers
> the guesswork exponent by *precisely* $\rho(1-R)$. At maximal entropy the
> constrained exponent is exactly
> $$ E_{\text{coset}}\!\left(\rho, R, \tfrac12\right) = \rho R = \rho - \rho(1-R). $$

The fraction $1-R$ is the *redundancy* of the code — the portion of freedom the
structure removes — and each unit of redundancy buys the adversary a discount of
$\rho$ in the exponent. Structure is a gift to whoever must guess.

## Proving it from first principles

The elegance of the fair-coin case is that we can prove the whole statement with
nothing more than a clever bracketing of a sum. Here is the argument in full.

**Step 1: What an optimal guesser actually does.** When every candidate in the
coset is equally likely — which is exactly what happens for a fair-coin source,
because all strings of length $n$ have identical probability $2^{-n}$ — the best
an adversary can do is guess them in an arbitrary order. Against $N$ equiprobable
candidates the guessing ranks realized are simply $1, 2, 3, \dots, N$. The $\rho$-th
moment is then the exact average
$$
M(N) = \frac{1}{N}\sum_{k=1}^{N} k^{\rho}.
$$
For unconstrained guessing $N = 2^m$ (all strings of length $m$); for coset
guessing over a rate-$R$ code, $N = 2^{k_m}$ where $k_m$ is the coset dimension,
with $k_m / m \to R$.

**Step 2: Bracket the power sum.** Everything now depends on the growth of
$S = \sum_{k=1}^{N} k^{\rho}$. We sandwich it with elementary estimates. Since
each of the $N$ terms is at most $N^{\rho}$,
$$
\sum_{k=1}^{N} k^{\rho} \le N \cdot N^{\rho} = N^{\rho+1}.
$$
For the lower bound, throw away the small terms and keep only the top half: the
$N/2$ largest terms are each at least $(N/2)^{\rho}$, so
$$
\sum_{k=1}^{N} k^{\rho} \ge \frac{N}{2}\left(\frac{N}{2}\right)^{\rho} = \left(\frac{N}{2}\right)^{\rho+1}.
$$
Together, with $N = 2^{j}$,
$$
2^{(j-1)(\rho+1)} \;\le\; \sum_{k=1}^{2^{j}} k^{\rho} \;\le\; 2^{\,j(\rho+1)} .
$$
Both walls of this cage grow at rate $\rho + 1$ per unit of $j$; the sum is
trapped between them.

**Step 3: Take logarithms and divide.** Applying $\log_2$ to the sandwich gives
$$
(j-1)(\rho+1) \;\le\; \log_2\!\sum_{k=1}^{2^{j}} k^{\rho} \;\le\; j(\rho+1).
$$
The two bounds differ by only $\rho+1$, a *constant*, independent of $j$. When we
form the moment $M(2^{k_m}) = 2^{-k_m}\sum_{k=1}^{2^{k_m}} k^{\rho}$, take its
logarithm, and normalize by the block length $m$, the constant gap washes out in
the limit:
$$
\frac{1}{m}\log_2 M\!\left(2^{k_m}\right)
= \frac{1}{m}\Big( -k_m + \log_2 \textstyle\sum_{k=1}^{2^{k_m}} k^{\rho} \Big)
\longrightarrow -R + R(\rho+1) = \rho R.
$$
The squeeze is complete. The constrained coset moment grows at rate exactly
$\rho R$.

**Step 4: Read off the shift.** Since the unconstrained exponent at the fair coin
is $\rho$ (the $R = 1$ special case of the same formula), the difference between
unconstrained and constrained is
$$
\rho - \rho R = \rho(1-R),
$$
exactly as promised. What began as an intuition — "less to search is easier" —
becomes an identity with no error term.

## Why this matters beyond the fair coin

The fair-coin case is the extreme point, the case of maximal uncertainty, and
proving it cleanly matters for three reasons.

First, it is a **benchmark**. Any claim about guessing structured secrets must
reduce to $\rho R$ when the source is a fair coin; a formula that fails this test
is wrong. Here that benchmark is established with a fully rigorous, elementary
argument — no unproven assumptions about the shape of the moment sequence, just a
sum bracketed between two powers of two.

Second, it **isolates the mechanism**. The discount $\rho(1-R)$ comes entirely
from the *shrinking of the candidate set* by the factor $2^{-(1-R)n}$ — the coset
density. By stripping away the source's bias (setting $p = \tfrac12$), we see the
coset compression acting alone, uncontaminated by the entropy of the noise. The
shift is a property of the *structure*, not of the *noise*.

Third, it points the way to the **general theorem**. For a biased source
$p \ne \tfrac12$, candidates are no longer equiprobable and the ranks are no
longer $1, \dots, N$; one must order noise vectors by decreasing probability and
group them by Hamming weight — Arıkan's classical tilting argument. But the
skeleton is the same: a compression by the coset density factor, producing the
same downward shift $\rho(1-R)$ on top of whatever the unconstrained exponent
happens to be. The fair-coin proof is the load-bearing special case that shows
the mechanism is real.

## The bigger picture

Guesswork is where information theory meets adversarial thinking. It quantifies
not "how many bits of information" a secret carries on average, but "how hard is
it to *break*" — a subtly different and often more security-relevant question.
The role of structure is where it gets surprising. We usually think of
error-correcting codes as protectors: they add redundancy so that messages
survive noise. But redundancy is double-edged. The very structure that lets a
receiver correct errors also tells an adversary *where to look*, collapsing the
search from the whole space to a single coset. This work measures that
double-edge precisely: every unit of code redundancy $1-R$ hands the guesser an
exponential discount of $\rho$.

The number $\rho(1-R)$ is small to write and easy to state, but it captures a
real tension at the heart of coded communication and cryptography: the same
structure that guards against random noise weakens the defense against a
determined adversary. Making that trade-off exact — provably, with no hidden
constants — is a small but sharp step toward understanding the true cost of a
guess.
