# The Seventh Rung: How Much Does a Number Tell You About Its Own Factors?

## A question a spy would ask

Suppose someone hands you an enormous integer $N$ and tells you only that it is
the product of two primes, $N = p_1 p_2$. You are not allowed to factor it —
that is the whole point. But you *are* allowed to look at $N$ modulo some small
fixed number, say $29$. That is one cheap glance. The question is brutally
simple:

**How many bits about the hidden factors does that one glance buy you?**

"Bits" here is not a metaphor. Information theory gives an exact currency for
this: the mutual information $I(X;Y)$ between a hidden quantity $X$ and an
observation $Y$, measured in bits. If $I = 0$, the glance is worthless. If
$I$ equals the full entropy $H(X)$ of the hidden quantity, the glance tells you
*everything*.

This article is about a family of such questions in which both extremes occur
simultaneously — and where the exact number of bits, for every one of the
questions, can be written down in closed form. The extremes are startling. Look
at one prime at a time, and a single residue is a *perfect* oracle: it pins the
answer down completely, zero uncertainty left. Multiply two primes together
first, and the same glance collapses to about *one ninth of a bit*. Arithmetic
is loud about primes and almost silent about their products, and we can now say
by exactly how much.

## The hidden variable: a prime's "splitting type"

The hidden quantity is a classical invariant. Fix a number field — a finite
extension of the rational numbers — and a prime $p$. Inside that field, $p$
either shatters into many pieces, or resists, or something in between. The
coarsest measure of what happens is the *residue degree* $T(p)$: the size of the
smallest chunk $p$ breaks into. If $T(p) = 1$, the prime *splits completely*: it
breaks into as many factors as the field has dimensions. This is the most
democratic possible behaviour, and the rarest.

For the fields we care about here — the *cyclic fields of prime degree $q$* —
there are only two possibilities, and this dichotomy is the engine of everything
that follows. Take a prime conductor $f$ with $f \equiv 1 \pmod q$, and inside the
$f$-th cyclotomic field $\mathbb{Q}(\zeta_f)$ take the unique subfield $K_q$ of
degree $q$. The Galois group of $\mathbb{Q}(\zeta_f)$ is the multiplicative group
$(\mathbb{Z}/f)^\times$, cyclic of order $f-1$; the subfield $K_q$ is the fixed field of
the subgroup of $q$-th powers. Class field theory then says something completely
concrete:

> **The splitting law.** A prime $p \neq f$ splits completely in $K_q$ if and
> only if $p$ is a $q$-th power modulo $f$. Otherwise its residue degree is
> exactly $q$. There is nothing in between.

The seventh rung of our ladder is the case $q = 7$, $f = 29$. The units mod $29$
form a cyclic group of order $28$, and the seventh powers form the subgroup of
order $4$ — which is, concretely, the group of fourth roots of unity:

$$\{u : u^7 \text{ is a seventh power}\} = \{u : u^4 = 1\} = \{1, 12, 17, 28\} \pmod{29}.$$

So the whole arithmetic of a degree-seven field of $29$ elements' worth of
symmetry reduces to a four-element checklist:

> **Degree-seven splitting criterion.** A prime $p \neq 29$ splits completely in
> the septic subfield of $\mathbb{Q}(\zeta_{29})$ — equivalently, its discrete
> logarithm mod $29$ is divisible by $7$ — precisely when
> $p \bmod 29 \in \{1, 12, 17, 28\}$. Otherwise $T(p) = 7$.

Thus $41 \equiv 12$ splits; $2$ does not. Exactly $4$ of the $28$ classes split:
density $1/7$, against $6/7$ for the inert ones. That $1{:}6$ imbalance is the
source of every number in this story.

## One glance, all the bits

How uncertain is the type of a random prime, before you look? The distribution
is $(1/7, 6/7)$, so the entropy is

$$H(T) \;=\; \log_2 7 \;-\; \tfrac{6}{7}\log_2 6 \;=\; 0.5916727\ldots \text{ bits}.$$

A pleasant reformulation: $7\,H(T) = \log_2\!\big(7^7/6^6\big)$, which is how the
value can be pinned rigorously between $0.5916$ and $0.5918$ by the integer
inequalities $2^{8283}\cdot 6^{12000} < 7^{14000} < 2^{8284}\cdot 6^{12000}$ — a
transcendental constant certified by two comparisons of whole numbers.

Now look at $p \bmod 29$ — or rather at something strictly weaker: its *coset*
modulo the fourth roots of unity, a datum with only $7$ possible values.

> **Full pinning at degree seven.** Conditioned on that coset, the residue
> degree has zero remaining uncertainty, so the information gained equals the
> entire entropy:
> $$I(\text{coset of } p \bmod 29 \; ; \; T) = H(T) = 0.5917\ldots \text{ bits}.$$

The channel is *saturated*. Nothing is lost, nothing is left over. In the
language a physicist might prefer: the observable commutes exactly with the
hidden variable.

Just as striking is the orthogonal statement. The group $C_{28}$ splits as
$C_4 \times C_7$, and the $C_4$-part of the Frobenius — the *quartic character*,
which contains among other things the familiar quadratic residue symbol mod $29$
— knows nothing:

> **Orthogonality.** The quartic character mod $29$ carries exactly zero
> information about the degree-seven splitting type.

Each of the four fibres of the quartic character contains exactly one splitting
class and six inert ones: the same $1{:}6$ ratio, every time. This is the
Chinese Remainder Theorem doing information theory: because $\gcd(4,7) = 1$, the
two coordinates of $C_4 \times C_7$ are independent, and only one of them is
arithmetically relevant to $K_7$.

## The rung is an invariant of the degree alone

The pair $(q, f) = (7, 29)$ looks like a special choice. It is not.

> **Universality of the prime rungs.** For every prime degree $q$ and every
> prime conductor $f \equiv 1 \pmod q$, the degree-$q$ subfield of
> $\mathbb{Q}(\zeta_f)$ has splitting density exactly $1/q$, type entropy exactly
> $$H(T) = \log_2 q - \tfrac{q-1}{q}\log_2(q-1),$$
> independent of $f$, and full pinning by the Frobenius class.

The proof is a one-line count once phrased correctly: in a finite cyclic group
generated by $g$, the $q$-th powers are precisely the powers of $g^q$, a subgroup
of order $|G| / \gcd(|G|, q)$. Everything else follows. So the septic rung built
over conductor $29$ and the septic rung built over conductor $43$ — a field
nobody computed by hand — carry *literally the same* $0.5917$ bits. The rung is
a property of the number $7$, not of the field.

## Now multiply two primes together

Here is where the arithmetic turns quiet. Model a semiprime $N = p_1 p_2$ by the
discrete logarithms $a, b$ of its two prime factors, each uniform in
$\mathbb{Z}/n$ where $n$ is the degree. The hidden variable is now the *type
pair*: the unordered pair of residue degrees of the two factors. The observation
is the residue of the product, which in logarithmic coordinates is simply
$a + b \bmod n$.

At degree $7$, the two factors split independently with probability $1/7$ each,
so the number $S$ of split factors follows the binomial law $\mathrm{Bin}(2,1/7)$
— exactly, not approximately:

> **The semiprime split-count law at degree seven.** Of the $49$ exponent pairs,
> exactly $36$ have no split factor, $12$ have exactly one, and $1$ has two.

And the channel? Write $I_{\mathrm{split}}(q)$ for the information the product
residue gives about $S$. At degree $7$ it is

$$I_{\mathrm{split}}(7) \;=\; \log_2 7 + \frac{30\log_2 5 - 78\log_2 3 - 78}{49} \;=\; 0.1141053\ldots \text{ bits},$$

certified to lie strictly between $0.1140$ and $0.1142$. From $0.5917$ bits down
to $0.1141$: multiplying two primes together destroys about $80\%$ of the signal.
And the ladder keeps falling — at degree $11$ the same channel is worth only
$0.0519$ bits. The decay looks like $q^{-2}$, and the numerics suggest a sharp
second-order law,
$$q^2\, I_{\mathrm{split}}(q) - \log_2 q \;\longrightarrow\; 2\log_2 e = 2.885390\ldots,$$
with the leading constant pure entropy curvature, carrying no arithmetic
information about the field at all.

## Throw away one more bit and lose everything

What if the eavesdropper only asks the yes/no question, "does *at least one*
factor split?" Call the resulting channel $G(q)$. It has its own closed form,

$$G(7) \;=\; \log_2 7 + \frac{30\log_2 5 - 66\log_2 3 - 13\log_2 13 - 54}{49} \;=\; 0.0103060\ldots \text{ bits},$$

and there is a clean structural reason it can never beat the split count: inside
any single fibre of the product residue, the split count takes at most one
non-zero value, so the two read-outs leave *identical* conditional uncertainty.
The channels therefore differ exactly by their unconditional entropies, which
forces $G(q) \le I_{\mathrm{split}}(q)$ at every prime degree — a data-processing
inequality proved by an exact identity rather than an estimate.

The quantitative version is dramatic: at degree $7$, collapsing the count
$\{0,1,2\}$ to a single bit multiplies the information by less than $1/11$. More
than ninety percent of an already tiny channel evaporates. Coarse questions get
coarse answers, and in this regime the penalty is not gentle.

## An audit, and a correction

This rung came with two numerical anchors inherited from earlier
experimentation, and part of the work was to check them rather than trust them.
One survived and one did not.

The figure $0.0103$ had been floated as the value of the split-count channel.
It is not: it is the OR channel, matching $G(7) = 0.0103060$ to better than
$5 \times 10^{-5}$. That reattribution is confirmed. The figure $0.1161$,
advertised as $I_{\mathrm{split}}(7)$, is *wrong*: the true value is $0.1141053$,
short by more than $0.0018$ bits — far outside any rounding. Interestingly, a
nearby figure $0.116$ that had been attributed to the degree-*eleven* rung is more
than thirty times closer to the degree-seven value ($0.1141$) than to the
degree-eleven one ($0.0519$), which is exactly the signature of a rung
mislabelling. Closed forms are unforgiving in this way, and that is their virtue.

## Why seven is special, and four is not

The final piece of the story explains why we have been able to say "split count"
and "type pair" almost interchangeably. At degree $7$ — or any prime degree —
they are the same channel:

> **Sufficiency at prime degree.** If $q$ is prime, the number of split factors
> already determines the whole unordered type pair, and hence
> $I_{\mathrm{pair}}(q) = I_{\mathrm{split}}(q)$.

The reason is the dichotomy: at prime degree the only possible residue degrees
are $1$ and $q$, so knowing how many $1$s occur tells you the multiset entirely.
At composite degree that reasoning collapses, because intermediate degrees appear
— and the collapse is not a technicality. At $n = 4$ the two channels can be
computed exactly:

$$I_{\mathrm{pair}}(4) = \frac{5}{4}, \qquad
I_{\mathrm{split}}(4) = \frac{19}{8} - \frac{21}{16}\log_2 3 = 0.2947367\ldots$$

The type pair is worth a clean $5/4$ bits — a rational number, and notably
*above* the one-bit ceiling that any binary read-out obeys. The split count is
worth less than $0.3$ bits. The projection to a count destroys more than three
quarters of the channel and drags it back under the one-bit cap. The mechanism
is visible: at $n = 4$ the divisor $2$ creates a genuine intermediate type, and
the count $S$ forgets *which* non-trivial degrees occurred.

Better still, the underlying combinatorial statement is an exact criterion:

> **Primality is the sufficient-statistic condition.** For $n \ge 2$, the split
> count induces the same partition of the exponent box as the full type pair
> **if and only if** $n$ is prime.

One direction is the dichotomy above; the other exhibits, for any proper divisor
$d$ of $n$, two configurations with the same split count $0$ but different type
pairs. So primality of the degree is not a convenient hypothesis in these
theorems — it is exactly the condition under which counting splits loses nothing.
Exhaustive evaluation for $n \le 12$ shows a strictly positive gap at every
composite degree, and it is natural to conjecture that
$I_{\mathrm{pair}}(n) = I_{\mathrm{split}}(n)$ holds precisely for prime $n$.

## What the ladder is for

Step back and the picture is a ladder of channels indexed by degree, each rung a
different question asked of the same arithmetic:

| what you look at | what you learn |
|---|---|
| Frobenius class of a single prime | $H(T) = 0.5917$ bits — everything |
| the quartic character mod $29$ | $0$ bits — nothing |
| residue of a semiprime, full type pair | $0.1141$ bits |
| residue of a semiprime, split count | $0.1141$ bits (prime degree: identical) |
| residue of a semiprime, "at least one splits?" | $0.0103$ bits |

The first line is why splitting laws are powerful: reciprocity turns a
global question into a residue lookup, with no loss. The last line is why
factoring is hard in this sense: multiply two primes and the arithmetic of the
product tells you an order of magnitude less about the factors, and each further
coarsening of the question costs another order of magnitude.

Between them sits the structural discovery of this rung — that the sufficiency of
so natural a summary as "how many factors split" is *exactly* a primality
statement about the degree, with the first composite degree already exhibiting a
four-fold loss. Degree seven, the last gap below ten, closes with every quantity
in the table available in closed form and every prediction either confirmed or
precisely corrected.
