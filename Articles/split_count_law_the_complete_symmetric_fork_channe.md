# The Fork in the Road: How Much Does a Number Tell You About Its Own Factors?

## A question you can ask about any product

Take two prime numbers, multiply them together, and hand the product to a
stranger. You know a great deal: you know both primes, their sizes, their
residues, their arithmetic personalities. The stranger knows only the product
$N$. The whole edifice of modern public-key cryptography rests on the belief
that this asymmetry is enormous — that the product hides its factors almost
perfectly.

But "almost" is doing a lot of work in that sentence. The product does leak
*something*. If $N$ is odd, both factors are odd. If $N \equiv 3 \pmod 4$, then
exactly one of the two primes is $\equiv 3 \pmod 4$. These are not deep facts;
they are the kind of thing every student notices. The interesting question is
quantitative: **exactly how many bits of information about the factors are
carried by the residue of $N$?** Not "is there a leak?" — of course there is —
but "what is the *complete* leak, measured in bits, and can it ever be turned
into an attack?"

This article answers that question exactly, for a natural and very large family
of leaks. The answer turns out to be a single, clean function of one integer
parameter, and it comes with a surprise: the leak is substantially *larger* than
previous accounts had suggested, reaching a full bit in the most classical case
— and yet it is still, provably and structurally, useless for factoring.

## Splitting: the arithmetic of a prime's residue

The mechanism behind every leak of this kind is a *character*. Fix a modulus
$f$, and consider the group of residues modulo $f$ that are coprime to $f$. Now
fix a way of collapsing that group onto a smaller abelian group $G$ of size $n$
— a surjective homomorphism $\chi$. Every prime $p$ not dividing $f$ acquires a
label $\chi(p) \in G$.

Call the prime **split** when it gets the identity label, $\chi(p) = 1$. The
name is not arbitrary. In the classical language of algebraic number theory,
$\chi$ cuts out an abelian field extension, and $\chi(p) = 1$ is precisely the
condition that $p$ splits completely in that field. The simplest case, $n = 2$,
is the quadratic character: a prime is split when it is a square modulo $f$.
For $n = 3$ and $f = 7$ or $f = 9$, it is the cubic residue condition — the same
condition that decides whether $2$ is a cube modulo $p$, or whether $p$ is
representable by a particular quadratic form.

Two facts about labels are all we need. First, the label of a random prime is
uniform on $G$: each of the $n$ labels occurs with density $1/n$. Second, labels
multiply: $\chi(pq) = \chi(p)\chi(q)$. The first is the classical
equidistribution theorem for primes in arithmetic progressions; the second is
just the homomorphism property. Together they say: a semiprime $N = pq$ is a
**fork**. Two independent uniform labels flow in; only their product flows out.
The residue of $N$ modulo $f$ reveals $\chi(N) = \chi(p)\chi(q)$ — and nothing
else about the labels.

## The right question: what does a fork carry?

Here is where earlier attempts to measure the leak went astray. It is natural to
ask a *yes/no* question: "does at least one of the two factors split?" — that
is, to look at the logical OR of the two split events. This is a legitimate
question, and one can compute exactly how much the residue of $N$ tells you
about its answer. In the quadratic case $n = 2$ the answer comes out to
$$
\tfrac{3}{2} - \tfrac{3}{4}\log_2 3 = 0.31128\ldots \text{ bits},
$$
and one can show this $0.3113$ is a hard ceiling for the OR question across
*every* choice of character and modulus.

But this is the wrong question, and the ceiling is an artifact of asking it.
The OR discards information. So does the AND ("do both split?"), and so does the
XOR ("does exactly one split?"). What is the *complete* content of a fork?

The answer is beautifully simple. Because the two factors are interchangeable —
the product $pq$ cannot distinguish $p$ from $q$ — the entire symmetric content
of the pair of split events is the **split-count**
$$
s = [\chi(p) = 1] + [\chi(q) = 1] \in \{0, 1, 2\},
$$
the number of factors that split. Marginally, $s$ is a binomial variable,
$s \sim \mathrm{Bin}(2, 1/n)$. And every Boolean question you might ask — OR,
AND, XOR, any of them — is a *function of $s$*. By the data processing
principle of information theory (you cannot manufacture information by
post-processing), each such question can only carry less than $s$ itself.

So the complete leak is the mutual information between the residue class of $N$
and the split-count.

## The split-count law

Everything can be computed in closed form, and the computation is short enough
to do here.

Condition on the observable, $\chi(N)$. There are two cases, and only two matter.

If $\chi(N) = 1$ — which happens with probability $1/n$ — then
$\chi(q) = \chi(p)^{-1}$, so the two factors split *together or not at all*.
The split-count is $2$ with probability $1/n$ and $0$ with probability
$(n-1)/n$; the value $s = 1$ is impossible.

If $\chi(N) = c \neq 1$, then the two factors can never split together (their
labels would multiply to $1$). But exactly one can: $\chi(p) = 1$, or
$\chi(p) = c$ so that $\chi(q) = 1$. Each has probability $1/n$, and they are
mutually exclusive. So $s = 1$ with probability $2/n$ and $s = 0$ with
probability $(n-2)/n$; the value $s = 2$ is impossible.

Two conditional distributions, sitting on complementary supports:
$$
P(s \mid \chi(N) = 1) = \left(\tfrac{n-1}{n},\ 0,\ \tfrac{1}{n}\right),
\qquad
P(s \mid \chi(N) \neq 1) = \left(\tfrac{n-2}{n},\ \tfrac{2}{n},\ 0\right).
$$
The mutual information between the two is the **split-count law**:
$$
I_s(n) = H\!\left(\mathrm{Bin}(2,\tfrac1n)\right)
 - \tfrac{1}{n} H\!\left(\tfrac{n-1}{n}, 0, \tfrac1n\right)
 - \tfrac{n-1}{n} H\!\left(\tfrac{n-2}{n}, \tfrac2n, 0\right),
$$
where $H$ is Shannon entropy in bits. Note what does *not* appear: the modulus
$f$, the structure of the group $G$, whether $G$ is cyclic, anything about the
particular character. Only the order $n$ survives. The law is
**order-universal**.

Two values deserve to be written out. At the quadratic characters,
$$
\boxed{I_s(2) = 1 \text{ bit, exactly.}}
$$
At the cubic characters,
$$
I_s(3) = \log_2 3 - \tfrac{10}{9} = 0.47385\ldots \text{ bits.}
$$

The first is the headline. The complete symmetric content of a quadratic fork is
one full bit — more than three times the celebrated $0.3113$ that the OR
projection reports. The $0.3113$ ceiling was never a property of forks; it was a
property of the *question* being asked of them.

## Where does the full bit hide?

At $n = 2$ the mechanism is transparent, and it is worth savouring. If
$\chi(N) = 1$, the two primes are both squares or both non-squares: the
split-count is $0$ or $2$, each with probability $1/2$. If $\chi(N) \neq 1$,
exactly one is a square: the split-count is $1$, with certainty. So the residue
of $N$ determines whether the split-count is *even or odd*, exactly and without
error — and the even/odd distinction is a fair coin. One perfect bit.

That is why the XOR question — "does exactly one factor split?" — is complete at
$n = 2$: XOR is precisely the parity of $s$, and parity is all there is. The OR
question, by contrast, cannot see the difference between $s = 1$ and $s = 2$,
and pays $0.69$ of a bit for the confusion.

## AND beats OR, always

Once one starts comparing the Boolean faces of a fork, an unexpected regularity
appears. At $n = 3$ the four numbers are

| question | bits |
|---|---|
| OR (at least one splits) | $0.0728$ |
| AND (both split) | $0.1972$ |
| XOR (exactly one splits) | $0.3789$ |
| split-count (complete) | $0.4739$ |

The AND question beats the OR question by a factor of almost three, even though
the two look like mirror images of each other. And this is not an accident of
$n = 3$:

> **The AND–OR Theorem.** For every order $n \geq 2$, the AND face of a
> character-pinned fork carries at least as much information as the OR face, and
> strictly more whenever $n > 2$. The quadratic characters are the unique place
> where the two coincide.

The reason is genuinely pretty, and it is a statement about binary channels in
general rather than about arithmetic. Write $x = 1/n$. Both faces are channels
with the same input prior $(x, 1-x)$ and the same first row $\mathrm{Bern}(x)$;
they differ only in the second row, which is $\mathrm{Bern}(0)$ for AND and
$\mathrm{Bern}(2x)$ for OR. Those two second rows are *mirror images about the
useless value $q = x$*: at $q = x$ the two rows would be identical and the
channel would carry nothing. AND undershoots the useless value by $x$; OR
overshoots it by $x$.

> **The Mirror Principle.** For a binary channel with prior $(x, 1-x)$ where
> $x < 1/2$ and first row $\mathrm{Bern}(x)$, a second row that *undershoots*
> the useless value $q = x$ by $t$ is strictly more informative than one that
> *overshoots* it by the same $t$.

Symmetry is broken by the prior. When $x < 1/2$ the two input classes are not
equally weighted, and the entropy landscape is tilted; moving the second row
towards the deterministic end $q = 0$ buys more than moving it the same distance
towards $q = 2x$. Making this precise comes down to a single convexity fact: for
$\varphi(u) = H_b(x + u) - H_b(x - u)$ (a difference of binary entropies), the
derivative is
$$
\varphi'(u) = \log\frac{(1-x)^2 - u^2}{x^2 - u^2},
$$
which is strictly increasing in $u$ exactly when $x < 1/2$. Two applications of
the mean value theorem convert that monotonicity into the sub-homogeneity
$\varphi(\lambda t) < \lambda\,\varphi(t)$, which is the theorem. And at
$x = 1/2$ — the quadratic characters — the derivative is constant in $u$: the
tilt vanishes, and AND and OR coincide at $0.3113$ exactly as observed.

There is a cautionary tale here too. It is tempting to guess a universal
hierarchy: split-count $\geq$ XOR $\geq$ AND $\geq$ OR, valid for all $n$. The
first and last inequalities are theorems. The middle one is *false*. It holds
for $n \leq 7$ and fails from $n = 8$ onward, where the exact values are
$$
\mathrm{OR}(8) = 0.00775 < \mathrm{XOR}(8) = 0.04801 < \mathrm{AND}(8) = 0.04817
< I_s(8) = 0.09056.
$$
The XOR–AND crossover at $n = 8$ is a genuine feature of the entropy landscape,
and a reminder that plausible-looking chains of inequalities in information
theory deserve to be checked rather than assumed.

## How fast does the leak die?

For large $n$ the leak becomes tiny, and it is worth knowing exactly how tiny.
The fork table has only four nonzero cells, and their contributions can be
tracked to any desired order. The result is a complete asymptotic law:
$$
I_s(n) = \frac{\log n + 2 - \frac{1}{2n} + O(n^{-2})}{n^2 \log 2}.
$$
Every constant here is exact. The leading behaviour is $\log_2 n / n^2$ — the
information falls off like the *square* of the group order, not linearly. The
additive constant is exactly $2$: it decomposes as $+3$ from the three cells in
which exactly one factor splits, minus $1$ from the majority-class cell. The
constant is approached from below, at rate exactly $-1/(2n)$.

Two earlier guesses about this decay are refuted by the law. There is no
constant $c > 0$ with $I_s(n) \geq c/n$ for all $n$; and the scaled quantity
$n \cdot I_s(n)/\log_2 n$ tends to $0$, not to $1$. The channel is a $1/n^2$
channel, and the honest statement is $n^2 I_s(n)/\log_2 n \to 1$.

## More factors do not help

A natural hope for an attacker: if two factors leak $I_s(n)$ bits, perhaps many
factors leak more. Consider $N = p_1 p_2 \cdots p_r$ with $r$ independent
uniform labels, and let the split-count $k$ count how many factors carry the
identity label. Again the marginal is binomial, $k \sim \mathrm{Bin}(r, 1/n)$ at
every arity, and again the whole joint law is order-universal. The coefficients
of the table are the counts
$$
a_m = \frac{(n-1)^m + (n-1)(-1)^m}{n},
$$
the number of $m$-tuples of non-identity classes whose product is the identity —
an exact count, satisfied by a two-term recursion, valid whether or not the
group is cyclic. (Remarkably, the number of $m$-tuples of non-identity classes
with any *fixed non-identity* product is $\bigl((n-1)^m - (-1)^m\bigr)/n$, the
same for every target, even when $n$ is composite and no unit acts transitively
on the non-identity classes.)

The answer to the hope is a flat no:

> **The No-Amplification Law.** The information carried by an arity-$r$ fork
> obeys $I^{(r)}(n) \leq (n-1)^{1-r}/\log 2$. For every $n \geq 3$ it therefore
> decays geometrically in the number of factors, and tends to $0$.

The proof is a $\chi^2$ argument: mutual information is dominated by the
$\chi^2$ divergence between the joint table and the product of its marginals,
and for the fork table that divergence is *exactly* $(n-1)^{1-r}$. More factors
mean more mixing, and mixing destroys the signal.

The one exception is, again, the quadratic characters: $I^{(r)}(2) = 1$ for
every arity $r$. Parity never degrades, no matter how many terms you add.

## The one-bit ceiling

Could some cleverer character, some exotic modulus, some cunningly chosen
"splitting profile" push the leak past one bit? No — and the reason is
structural rather than arithmetic.

> **The One-Bit Cap.** Any channel whose input alphabet has two symbols carries
> at most one bit, whatever its output alphabet and whatever its conditional
> laws. Moreover it attains one full bit *only* if its input prior is balanced.

The observable in a fork is binary — either $\chi(N)$ is the identity or it is
not — so a fork can never carry more than one bit. And the input prior is
$(1/n, (n-1)/n)$, which is balanced precisely when $n = 2$. Hence:
$$
I_s(n) = 1 \iff n = 2 .
$$
The quadratic characters are not merely the best case; they are the unique
maximiser, and the maximum is exactly one bit.

One can test this by brute force in a much wider setting: declare a prime
"split" when its residue lies in an arbitrary subset $S$ of the residues coprime
to $f$ — no character, no group structure assumed — and let the observer see the
*full* residue class of $N$ rather than a single yes/no flag. Enumerating every
such subset on nine moduli, including the non-cyclic groups $C_2 \times C_2$,
$C_2 \times C_4$, $C_2\times C_2\times C_2$ and $C_2 \times C_6$, the maximum is
exactly $1.000000$ bits in every case — and the only subsets achieving it are
the index-two subgroups, that is the quadratic characters, together with their
complements.

## So can you factor with it?

No, and it is important to be honest about why not.

The information is **symmetric**. The split-count says how many factors split;
it never says *which*. In fact the split event of a single designated factor is
*exactly independent* of the residue of $N$: knowing $N \bmod f$ tells you
literally zero bits — not "few", zero — about whether $p$ specifically splits.
This is the which-factor wall, and it is not a limitation of the analysis; it is
a theorem about the fork.

The information is a **residue dial**. Everything the channel delivers is a
function of $N \bmod f$, which anyone can compute from $N$ without factoring.
At $n = 2$ the full bit is the Jacobi symbol of $N$: it tells you the parity of
the number of non-residue factors, which is exactly the classical statement of
quadratic reciprocity, computable in polynomial time and known to be
factoring-useless for two centuries. The split-count law does not add a new
attack; it *quantifies precisely* what the classical reciprocity laws already
told us, and shows that there is nothing else in the fork.

Numerical experiments bear the theory out. Sampling tens of thousands of
semiprimes below $2^{22}$ across eight moduli, the measured channel matches the
closed form throughout: $0.4731$, $0.4718$ and $0.4755$ against the predicted
$0.4739$ at order $3$ for the moduli $7$, $9$ and $21$; $0.2894$ against
$0.2947$ at order $4$; $0.1482$ against $0.1487$ at order $6$. The empirical
split-count distribution matches $\mathrm{Bin}(2,1/n)$ everywhere, and the
which-factor channel measures between $0.0000$ and $0.0003$ bits — statistical
zero, as predicted.

## What the exercise is worth

There is a familiar rhythm in the study of hard computational problems: someone
notices a leak, the leak is measured badly, the measurement suggests false hope
or false comfort, and eventually someone identifies the *complete* statistic and
computes it exactly. Then the leak stops being a rumour and becomes a number.

Here the complete statistic is the split-count, the number is
$$
I_s(n) = H(\mathrm{Bin}(2,\tfrac1n))
 - \tfrac1n H\!\left(\tfrac{n-1}{n},0,\tfrac1n\right)
 - \tfrac{n-1}{n} H\!\left(\tfrac{n-2}{n},\tfrac2n,0\right),
$$
and the story it tells has three chapters. The leak is *bigger than advertised*:
a full bit at the quadratic characters, three times what the standard Boolean
projection reports. The leak is *sharply bounded*: never more than one bit, at
any order, any modulus, any group, any profile — with the maximum attained only
by the quadratic characters. And the leak is *structurally inert*: symmetric in
the factors, computable from the residue alone, geometrically destroyed by extra
factors, and saying nothing that classical reciprocity had not already said.

Knowing exactly how much a number tells you about its factors, and knowing
exactly why that is not enough, is the kind of negative result that makes the
positive ones trustworthy.
