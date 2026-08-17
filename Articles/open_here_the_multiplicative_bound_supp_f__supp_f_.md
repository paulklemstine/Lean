# The Sharpest Uncertainty: Why Prime Numbers Make Signals Impossible to Hide

## A signal cannot be small in two places at once

Here is a fact you can feel in your bones. Strike a single, perfectly short click on a
loudspeaker — an impulse lasting one sample and nothing more — and its frequency content is
spread across the entire audible spectrum: a click is white, it has no pitch. Play instead a
pure sine tone, perfectly concentrated at one frequency, and it must last forever; the moment
you cut it off, its spectrum smears.

This trade-off is the *uncertainty principle*. In quantum mechanics it becomes Heisenberg's
inequality between position and momentum. In signal processing it becomes a statement about a
vector and its Fourier transform: they cannot both be concentrated.

The version this article is about lives in the most computational corner of the subject.
Take a cyclic group of $p$ points — the integers modulo $p$, written $\mathbb{Z}_p$, which is
what a length-$p$ FFT actually operates on. A signal is a function $f : \mathbb{Z}_p \to
\mathbb{C}$, and its discrete Fourier transform is

$$\hat f(k) \;=\; \sum_{x \in \mathbb{Z}_p} \omega^{-kx} f(x), \qquad
\omega = e^{2\pi i / p}.$$

Write $\operatorname{supp} f$ for the set of points where $f$ is nonzero, and $|\operatorname{supp} f|$ for
how many there are. "Concentrated" now means "small support". The uncertainty principle should
say: $f$ and $\hat f$ cannot both have small support.

There are two ways to say it, and the gap between them is the story.

## Two inequalities, and the chasm between them

The classical statement, due to Donoho and Stark, holds for *any* length $n$:

> **Product bound.** If $f \neq 0$ on $\mathbb{Z}_n$, then
> $|\operatorname{supp} f| \cdot |\operatorname{supp} \hat f| \;\geq\; n$.

It is elegant, it is easy to state, and it is the workhorse of a great deal of signal
processing. But it has a soft spot: it is happy with *balanced* signals. If $n = 10{,}000$, the
product bound is perfectly content with a signal occupying $100$ time samples and $100$
frequencies. Ten thousand equals one hundred times one hundred; no contradiction.

Now restrict the length to a **prime** $p$. Something remarkable happens: the inequality
upgrades from multiplicative to additive.

> **Additive bound.** If $p$ is prime and $f \neq 0$ on $\mathbb{Z}_p$, then
> $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \;\geq\; p + 1$.

This is an entirely different animal. For $p \approx 10{,}000$, a signal with $100$ nonzero
samples must now have at least $9{,}901$ nonzero Fourier coefficients. The balanced
$100 \times 100$ profile is not merely suboptimal — it is *impossible*. On a prime-length
group, sparsity in time and sparsity in frequency are not just in tension; they are in a
zero-sum war, and the total budget is $p+1$.

How much stronger is the additive statement really? Exactly this much:

* **Additive implies multiplicative.** If $a, b \geq 1$ and $a + b \geq p+1$, then
  $ab \geq p$. (Because $(a-1)(b-1) \geq 0$ gives $ab \geq a + b - 1 \geq p$.) So nothing is
  lost by passing to the additive form.
* **Multiplicative does not imply additive — ever.** For every $p \geq 5$ one can take
  $a = 2$ and $b = \lfloor (p+1)/2 \rfloor$: then $ab \geq p$, so the product bound is
  satisfied, while $a + b < p + 1$, so the additive bound is violated. The pair of
  cardinalities is perfectly legal for Donoho–Stark and completely illegal additively. No
  rearrangement of the product inequality, however clever, can ever produce the additive one.
* **What the product bound alone buys you.** By the inequality of arithmetic and geometric
  means, $4ab \le (a+b)^2$, so from $ab \geq p$ one gets only
  $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \geq 2\sqrt{p}$. That is roughly $200$ where the
  truth is roughly $10{,}000$. The multiplicative bound sees a square root of the real
  phenomenon.

So the additive bound is not a cosmetic improvement. It is a different order of magnitude.

## Primality is not decoration

Why insist on prime length? Because the theorem is simply false otherwise, and the
counterexample is as small and as clean as one could wish.

Work in $\mathbb{Z}_4$ and let $f$ be the indicator of the subgroup $\{0,2\}$: that is
$f(0) = f(2) = 1$ and $f(1) = f(3) = 0$. A two-line computation with the fourth root of unity
$i$ gives $\hat f(k) = 1 + (-1)^{k}$, so $\hat f(0) = \hat f(2) = 2$ and
$\hat f(1) = \hat f(3) = 0$. The transform of the subgroup is (twice) the indicator of the
subgroup again.

Count: $|\operatorname{supp} f| = |\operatorname{supp} \hat f| = 2$. The product is $4$, so the
Donoho–Stark bound is satisfied *with equality*. The sum is $4$, but the additive bound would
demand $4 + 1 = 5$. **It fails.**

The reason is structural, and it is the reason primes matter everywhere in this subject:
$\mathbb{Z}_4$ has a proper nontrivial subgroup, and a subgroup indicator is its own transform,
up to scale. Such a function is maximally concentrated in both domains at once. A group of
prime order has no proper nontrivial subgroups — nothing for a signal to hide inside — and this
absence is precisely what the additive bound converts into arithmetic.

## The bound is sharp — at both ends, and only there

An inequality is interesting when it is achieved. This one is achieved twice over, at the two
extremes of the scale.

At one end, take the **Dirac delta** $\delta_a$, equal to $1$ at a single point $a$ and $0$
elsewhere. Its transform is $\hat{\delta_a}(k) = \omega^{-ka}$: a unimodular number, never
zero. So $|\operatorname{supp} \delta_a| = 1$ and $|\operatorname{supp} \hat{\delta_a}| = p$, and the sum is
exactly $p + 1$. The click is white — and it is *exactly* as white as the theorem allows.

At the other end, take a **character** $\chi_b(x) = \omega^{bx}$, a pure discrete frequency.
Its transform is $p$ at the frequency $b$ and $0$ everywhere else, because the sum of all
$p$-th roots of unity vanishes:
$\sum_{y \in \mathbb{Z}_p} \omega^{y} = \frac{\omega^p - 1}{\omega - 1} = 0.$
So $|\operatorname{supp} \chi_b| = p$, $|\operatorname{supp} \hat{\chi_b}| = 1$, and again the sum is $p+1$.
The pure tone lasts forever — exactly as long as the theorem allows.

Between these two poles the inequality is a genuine constraint, and understanding what happens
in the middle is where the mathematics gets hard.

## The hidden identity: uncertainty is a determinant

Here is the conceptual heart of the story. The additive uncertainty principle looks like an
analytic statement about sparse vectors. It is secretly a statement of pure linear algebra —
in fact, one that predates it by eighty years.

Form the $p \times p$ Fourier matrix $F$ with entries $F_{s,t} = \omega^{st}$. Pick any $n$
rows and any $n$ columns and take the determinant of the resulting $n \times n$ block. Such a
block is called a *minor*.

> **Chebotarev's property.** Every square minor of the Fourier matrix of $\mathbb{Z}_p$ is
> nonsingular.

Chebotarev proved this in the 1920s for prime $p$; several beautiful proofs are known. What is
worth spelling out is the exact relationship to uncertainty:

> **Equivalence.** For every modulus $p$, the additive bound
> $|\operatorname{supp} f| + |\operatorname{supp} \hat f| \geq p+1$ (for all $f \neq 0$) holds **if and only
> if** every square minor of the Fourier matrix of $\mathbb{Z}_p$ is nonsingular.

Both directions are short once you see the dictionary. A function $f$ violating the additive
bound has support $A$ and a zero set of its transform that is at least as large as $A$; picking
$|A|$ frequencies where $\hat f$ vanishes produces a square block of the Fourier matrix that
kills the nonzero vector of values of $f$ — a singular minor. Conversely, a singular minor
gives a nonzero kernel vector; place its entries on the chosen columns to build a function
whose transform vanishes on the chosen rows, and count: you have manufactured a violator of the
additive bound.

The dictionary works for *any* modulus, so it also explains the $\mathbb{Z}_4$ failure from the
other side: the Fourier matrix of $\mathbb{Z}_4$ does have a singular minor, namely
$\begin{pmatrix} 1 & 1 \\ 1 & 1\end{pmatrix}$ obtained from rows $\{0,2\}$ and columns
$\{0,2\}$ — the same subgroup, appearing again.

## Turning analysis into counting

Once uncertainty has been translated into "all minors are nonsingular", one can attack the
determinant directly. Expand it by the Leibniz formula. Rows indexed by $s_1, \dots, s_n$ and
columns by $t_1, \dots, t_n$ give

$$\det\left(\omega^{\,s_j t_k}\right)_{j,k} \;=\; \sum_{\sigma \in S_n}
\operatorname{sgn}(\sigma)\, \omega^{\,E_\sigma}, \qquad
E_\sigma = \sum_{j} s_{\sigma(j)}\, t_j \bmod p .$$

Every term is a $p$-th root of unity with an integer sign. Collect equal exponents: for each
residue $r \in \mathbb{Z}_p$, let $c_r$ be the number of even permutations with $E_\sigma = r$
minus the number of odd ones. Then the determinant is $\sum_r c_r \omega^r$, and — because
$n \geq 2$ means half the permutations are even and half are odd — the coefficients satisfy
$\sum_r c_r = 0$.

Now bring in the one algebraic input that makes primality bite: over the rationals, the only
linear relation among the $p$ roots of unity $1, \omega, \dots, \omega^{p-1}$ is that they sum
to zero. (Equivalently: the minimal polynomial of $\omega$ is $1 + X + \dots + X^{p-1}$.) So a
rational combination $\sum_r c_r \omega^r$ vanishes exactly when all the $c_r$ are *equal* —
and if they also sum to zero, exactly when all of them are zero. Conclusion:

> **Parity criterion.** For $n \geq 2$, the minor is nonsingular **if and only if** some
> residue $r$ is hit by unequally many even and odd permutations under the exponent map
> $\sigma \mapsto \sum_j s_{\sigma(j)} t_j$.

An analytic non-vanishing question has become a finite counting question about the symmetric
group acting on $\mathbb{Z}_p$. Two immediate consequences: if any residue is hit by an *odd*
number of permutations, the signed count is odd, hence nonzero, hence the minor is nonsingular;
and in particular if any permutation realises its exponent *uniquely*, we are done.

That last observation is enough to settle small minors completely. For $n \le 3$ one can check
that a uniquely-realised exponent always exists — and a direct six-term argument confirms it:
a determinant of a $3\times 3$ Fourier minor is $\omega^{e_1} + \omega^{e_2} + \omega^{e_3} -
\omega^{f_1} - \omega^{f_2} - \omega^{f_3}$, and distinctness of the rows and columns forces
one of the negative exponents to differ from all three positive ones, which makes the signed
coefficient at that residue nonzero.

## What is proved, and where the frontier lies

Assembling the pieces, the additive uncertainty principle on $\mathbb{Z}_p$ is now established
outright in the following regimes. In every case $p$ is prime and $f \neq 0$:

1. $|\operatorname{supp} f| \leq 3$ — at most three nonzero samples, with *no* structural assumption;
2. $|\operatorname{supp} \hat f| \leq 3$ — the dual statement, at most three nonzero frequencies;
3. $|\operatorname{supp} f| \geq p - 3$ — very spread-out signals;
4. $\operatorname{supp} f$ is an arithmetic progression $a, a+d, \dots$ of any length;
5. $\operatorname{supp} \hat f$ is an arithmetic progression of any length.

Cases 4 and 5 come from the polynomial method: if the support sits inside a progression, then
$\hat f(k) = \omega^{-ka} P(\omega^{-kd})$ for a nonzero polynomial $P$ of degree less than the
length of the progression, and a polynomial of degree $m-1$ has at most $m-1$ roots. Since
$k \mapsto \omega^{-kd}$ is injective for $d \neq 0$, the transform has at most $m-1$ zeros, so
at least $p - m + 1$ nonzero values. Equivalently, and strikingly: **the Fourier transform of a
nonzero signal can never vanish on an entire arithmetic progression of length
$|\operatorname{supp} f|$.**

Cases 1 and 2 come from the parity criterion via the nonsingularity of all $3 \times 3$ minors,
and case 3 follows by playing off the dual bound against the trivial cap
$|\operatorname{supp}| \leq p$.

What remains is the middle: supports of size between $4$ and $p-4$, with no arithmetic
structure and no structure in the spectrum. Numerically, no minor has ever failed — exhaustive
checks over all $4 \times 4$ minors for $p = 7, 11, 13$ find every single one nonsingular, and
for $p = 11$ about $89\%$ of them are settled by the cheap "uniquely realised exponent" test.
(For $p = 7$ and $4 \times 4$ minors, remarkably, *none* is: the fibres are all large. On the
other hand, in every configuration examined some residue is hit by an *odd* number of
permutations, which would suffice — but nobody knows how to prove that this always happens.)
The remaining fraction requires a genuinely new combinatorial invariant, and identifying it is
the current frontier. Two concrete conjectures point the way: one predicts that the
minimal-length permutation in each exponent fibre breaks the parity balance; the other predicts
an exact valuation formula, saying that the polynomial $\det\big((1+u)^{s_j t_k}\big)$ vanishes
to order exactly $n(n-1)/2$ at $u=0$, with leading coefficient a ratio of Vandermonde products
that is an integer prime to $p$.

## Why anyone outside pure mathematics should care

Because the additive bound is the exact reason that *sparse recovery works at prime lengths*.

Suppose a signal on $\mathbb{Z}_p$ has at most $k$ nonzero samples — a sparse spike train, a
handful of active features, a few reflecting objects in a radar return — and you are allowed to
measure only some of its Fourier coefficients. How many do you need to pin it down?

The answer is $2k$, **and any $2k$ frequencies will do**. Here is the one-line proof. Suppose
two $k$-sparse signals $f$ and $g$ agree on a set $\Omega$ of $2k$ frequencies. Their
difference $h = f - g$ is at most $2k$-sparse and $\hat h$ vanishes on $\Omega$, so
$|\operatorname{supp} \hat h| \leq p - 2k$. The additive bound then forces
$|\operatorname{supp} h| \geq (p+1) - (p - 2k) = 2k + 1$, which is impossible unless $h = 0$. Hence
$f = g$.

The contrast with generic compressed sensing is the point. Standard results guarantee recovery
from *random* measurements, with high probability, up to logarithmic factors. Here the
guarantee is deterministic, exact and universal: no randomness, no failure probability, no
logarithms, no conditions on which frequencies you sample. Choose any $2k$ of them — the first
$2k$, a scattered set, whatever your hardware makes cheap — and the $k$-sparse signal is
uniquely determined. That is a property of prime lengths and of nothing else; on
$\mathbb{Z}_4$, sampling the frequencies $\{1,3\}$ tells you nothing at all about the subgroup
indicator, whose transform is supported precisely on $\{0,2\}$.

This is why the result matters well beyond harmonic analysis. Sparse recovery, feature hashing,
spectral sketching and dictionary design all rest on knowing which measurement patterns are
safe. On a prime-length group, the answer is: all of them.

## The shape of the idea

Step back and look at the chain of translations, because it is a small masterpiece of
mathematical redirection.

*A statement about how sparse a signal and its spectrum can simultaneously be* becomes
*a statement that all minors of the Fourier matrix are invertible*, which becomes
*a statement that a signed sum of roots of unity does not vanish*, which becomes — using the
single fact that a prime cyclotomic polynomial is $1 + X + \dots + X^{p-1}$ —
*a statement that the permutations of a finite set cannot distribute themselves in
parity-perfect balance across the residues modulo $p$.*

Analysis becomes linear algebra becomes algebraic number theory becomes combinatorics. At each
step the problem gets more elementary and, curiously, no easier. What survives every
translation is the primality: no subgroups to hide in, no rational relations among roots of
unity beyond the obvious one, no way for a signal to be concentrated twice.

The click is white. The tone is eternal. And on a prime-length group, everything in between
pays the full price of $p+1$.
