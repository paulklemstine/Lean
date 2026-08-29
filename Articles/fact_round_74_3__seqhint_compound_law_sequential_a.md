# The Price of a Hint

## Why twelve well-chosen questions can be worth three hundred badly-chosen ones — and why no question is ever worth more than one bit

Imagine you are trying to break a number apart. You are handed
$N = 1099511627791$, a number you know to be the product of exactly two
primes, $N = pq$, and you are asked to find them. This is the oldest hard
problem in computational number theory, and the one on which a good deal of
modern cryptography quietly rests.

Now imagine someone offers to help. Not by telling you the answer — that would
be no fun — but by answering questions of a very restricted kind. You may name
a number $t$ and ask: *"Is the smaller prime at most $t$?"* You get back a
truthful yes or no. Each question costs you something, so you would like to
know: **what is a hint worth?**

This sounds like a puzzle, and it is. But it is also a question with a
surprisingly sharp and surprisingly two-faced answer, and the two faces have
been in apparent conflict in the folklore for some time. One line of reasoning
says hints *add up*: $k$ hints buy you a speedup of about $k+1$, no more,
because they carve your search space into $k+1$ pieces. Another line of
reasoning says hints *multiply*: everyone who has ever played Twenty Questions
knows that $20$ well-chosen yes/no questions pin down one item out of a
million, a speedup of $2^{20}$, not $21$.

Both are true. They are statements about different things, and the difference
is a single word: **adaptivity**.

---

## Two ways to ask twelve questions

Suppose the unknown prime $p$ lives somewhere in a window of $w$ consecutive
integers — say $[\mathrm{lo}, \mathrm{hi})$, with $w = \mathrm{hi} -
\mathrm{lo}$ candidates. You are allowed $k$ questions of the form "$p \le t$?".

**Strategy A — the fixed battery.** Write down all $k$ thresholds
$t_1, \dots, t_k$ in advance, hand them over as a list, and receive all $k$
answers at once.

**Strategy B — the adaptive interrogation.** Ask one question, look at the
answer, and only then decide what to ask next.

The difference in value between these two is enormous, and it is *exactly*
computable.

### Fixed batteries price linearly

Here is the whole argument for Strategy A in one picture. The answers to
comparison questions are *nested*: if $p \le t_1$ and $t_1 \le t_2$, then
automatically $p \le t_2$. So the full answer vector to a fixed battery is
determined by a single number — the count of thresholds you fall below. Define
the **signature** of a candidate $x$ under the battery $T$ to be
$$\sigma_T(x) = \#\{t \in T : x \le t\}.$$
Two candidates with the same signature give *identical answers to every
question in the battery*: they are indistinguishable, forever, no matter what
you do with the answers.

The signature takes at most $k+1$ values, namely $0, 1, \dots, k$. So the
battery cuts the window into at most $k+1$ indistinguishability classes, and by
the pigeonhole principle one of those classes contains at least $w/(k+1)$
candidates.

> **Linear Pricing Theorem.** For *every* fixed battery $T$ of $k$ comparison
> thresholds and every window $W$ of $w$ candidates, there is a set $C
> \subseteq W$ with $|C| \ge w/(k+1)$ such that all members of $C$ produce
> exactly the same answers to every threshold in $T$. Consequently the speedup
> a fixed battery can buy is at most $k+1$.

Twelve fixed hints buy you a factor of at most $13$. That is the "no-synergy"
law: hints add, they do not compound.

And the bound is tight — the equally spaced battery attains it. On the tiny
window $\{0,1,\dots,7\}$ with three thresholds, the battery $\{1,3,5\}$ leaves
every class of size exactly $2 = 8/4$, and an exhaustive check over all
$\binom{8}{3}$ three-threshold batteries confirms that no other choice does
better. On $\{0,\dots,15\}$ with four thresholds, *every one* of the
$\binom{16}{4} = 1820$ possible batteries leaves at least four candidates
mutually tied.

### Adaptive questions price geometrically

Now Strategy B. You ask about the median, and whichever answer comes back, half
the window dies.

There is a small trap here, and it is worth spelling out because it is exactly
the kind of thing that turns a beautiful theorem into a program that never
halts. Suppose you use the *upper* median, $\mathrm{lo} + \lfloor w/2 \rfloor$,
as your threshold. On the two-element window $\{0, 1\}$ this threshold is $1$;
the answer "$p \le 1$?" is *yes* for both candidates; the window after the
query is $\{0, 1\}$ again. The scheme **stalls forever**: it will ask the same
useless question for eternity and never isolate anything.

The fix is one character wide. Use the **lower median**,
$$m = \mathrm{lo} + \left\lfloor \frac{w-1}{2} \right\rfloor,$$
and everything works:

> **Width-Halving Law.** One adaptive query at the lower median takes a
> nonempty window of width $w$ to a window of width at most $\lceil w/2
> \rceil$, on either answer, and the true candidate is never discarded.
> Iterating, after $k$ adaptive queries the residual window has width exactly
> $$\left\lceil \frac{w}{2^k} \right\rceil.$$

That last equality is not an estimate. The composite of $k$ ceiling-halvings is
*exactly* the ceiling of division by $2^k$ — the roundings do not accumulate.

An immediate consequence: the residual window is a single candidate precisely
when $w \le 2^k$, so

> **Exact Isolation Budget.** The least number of adaptive comparison queries
> that pins the unknown value in a window of $w$ candidates is exactly
> $\lceil \log_2 w \rceil$.

For a $40$-bit semiprime, the smaller factor lives below $2^{20}$, and the
budget is exactly $20$. After $20$ questions you know $p$ completely. After
$19$ you do not.

---

## The ceiling nobody can break

Bisection reaches $2^k$. Could something cleverer reach more?

No — and the reason is beautifully cheap. An adaptive strategy is a rule that
turns the answers-so-far into the next threshold. Run it against a hidden value
$x$ and you get a **transcript**: a string of $k$ bits. There are only $2^k$
bit strings of length $k$. So if your window has more than $2^k$ candidates,
two distinct candidates must produce the *same* transcript — and a strategy
that produces the same transcript for two different values has not
distinguished them.

> **Isolation Ceiling.** No adaptive strategy whatsoever, using $k$ truthful
> yes/no comparison queries, can separate more than $2^k$ candidates. If
> $2^k < |W|$, some pair in $W$ is provably indistinguishable.

Together with the halving law this pins the answer from both sides: bisection
isolates $2^k$ candidates, nothing isolates more. Each query is worth exactly
one bit — no more, and (with the right threshold) no less. The argument
generalises without effort: if the oracle answers in an alphabet of $r$
symbols, $k$ queries generate at most $r^k$ transcripts, so a query is worth
exactly $\log_2 r$ bits. External positional information is *priced*, and the
price is one bit per query.

This is why the compounding stops. Speedup grows like $2^k$ until $k$ reaches
$\lceil \log_2 w \rceil$, and then it is flat forever: the window is a
singleton and there is nothing left to buy. Compounding is real, and it
saturates *exactly* at the isolation ceiling, never a hair beyond it.

---

## The adaptivity premium

Put the two laws side by side. Fixed: $k+1$. Adaptive: $2^k$. Their ratio is
the **adaptivity premium**
$$r(k) = \frac{2^k}{k+1}.$$

It has a lovely shape. At $k = 0$ it is $1$ — trivially. At $k = 1$ it is
$2/2 = 1$ — **exactly** $1$, and this is not a coincidence but a theorem: with
a single query there is nothing to adapt to, and a single fixed threshold
placed at the lower median achieves precisely what one bisection step achieves.
Adaptivity is worth *nothing at all* on the first question. From $k = 2$
onward the premium strictly increases, and it outgrows every linear function:
$r(k) \ge k$ for all $k \ge 5$. At $k = 12$ it is $4096/13 \approx 315$.

So both slogans are right. "Hints price linearly" describes fixed batteries.
"Sequential hints compound" describes adaptive ones. One pricing structure,
two faces, separated by exactly the factor $r(k)$, which starts at $1$ and runs
away.

---

## The surprise: a battery that carries literally zero bits

Now the punchline, and it is the kind of thing that only shows up when you look
at real numbers rather than asymptotics.

Balanced semiprimes — those with $p \approx q$, the ones cryptographers
actually use — have a property that ruins fixed batteries completely. If
$q/p \le 1.01$, then $p$ is pinned against $\sqrt N$ within half a percent. At
bit length $40$ that means $p$ lives in the window $[720000, 723600)$: $3600$
candidates out of the full search range $[2, 2^{20})$ of a million.

Now spread a "sensible" uniform battery of $24$ thresholds across that full
range: $t_i = \lfloor i \cdot 2^{20}/25 \rfloor$ for $i = 1, \dots, 24$, spaced
about $42000$ apart. Every one of those thresholds misses the $3600$-wide
support window. Every candidate in the support gives the *same* answer to
*every one* of the $24$ questions.

> **Zero-Bit Collapse.** If no threshold of a battery falls strictly inside the
> support of the unknown, the entire support is a single indistinguishability
> class. The battery carries literally zero bits, and the speedup is exactly
> $1.00$ — at $k = 24$ just as at $k = 0$.

Meanwhile, $12$ *adaptive* queries — half as many — isolate the factor
exactly: the residual window is the singleton $\{p\}$, a speedup of $3600$.

> **The Balanced Dichotomy.** On the balanced support window $[720000, 723600)$
> at bit length $40$: the $24$-threshold uniform fixed battery leaves all
> $3600$ candidates tied, while $12$ adaptive queries leave exactly one.

Half the questions, and the difference between removing none of the
uncertainty and removing all of it. In the balanced world the adaptivity
premium is not $315$; it is *infinite* relative to a fixed battery that carries
nothing at all. And it reconciles the two slogans in the sharpest possible way:
the linear no-synergy law is not merely an upper bound for non-adaptive hints
in this regime, it collapses to the trivial bound of $1$.

---

## What the premium is actually measuring

Here is the twist that makes the story deeper than "adaptivity is magic".
Adaptivity is *not* magic, and the premium $2^k/(k+1)$ is not a gain that
conditioning creates. It is a **deficit of the comparison channel** that
conditioning repairs.

Consider a fixed battery of $k$ *arbitrary* yes/no predicates — not
comparisons, anything at all. Take the $k$ bit-tests "is the $i$-th binary
digit of $p$ equal to $1$?". These are entirely non-adaptive, decided in
advance, and they separate every pair of candidates below $2^k$. So a
non-adaptive battery of general predicates already achieves $2^k$ — the
ceiling — with no conditioning whatsoever. And no fixed battery of general
predicates does better: $k$ Boolean predicates take at most $2^k$ values.

> **Adaptivity Repairs the Channel.** Non-adaptive comparison hints resolve at
> most $k+1$ candidates; non-adaptive *general* hints resolve exactly $2^k$;
> adaptive comparison hints also resolve exactly $2^k$. So the adaptivity
> premium measures how much information the comparison channel wastes when its
> questions are fixed in advance, not how much conditioning creates.

Comparison questions are individually weak in a way ordinary Boolean questions
are not: their answers are nested, so a fixed list of them is redundant.
Adaptivity un-nests them, restoring each query to its full one bit. That is all
it does, and the ceiling theorem guarantees that is all anything can do.

---

## Two currencies, not one

If adaptivity is not the source of compounding, what is? The answer is: the
*structure of the channel* — and a beautiful counterexample makes the point.

Ask $k$ **residue** questions instead: "what is $p \bmod m_i$?", for pairwise
coprime moduli $m_1, \dots, m_k$, all fixed in advance. By the Chinese
Remainder Theorem these answers pin $p$ uniquely in any window of $\prod_i m_i
\ge 2^k$ candidates. So here is a fully *non-adaptive* battery that compounds
geometrically. Compounding is a property of the channel, not of adaptivity.

And yet residue hints are useless for the actual factoring algorithm. The
downstream method here is Fermat's difference-of-squares scan, which sweeps an
*interval* of consecutive integers looking for a perfect square. A residue
class modulo $m$ is spread across the entire window — its members reach within
$m$ of both the top and the bottom — so:

> **Residue Hints Carry No Interval Information.** Knowing $p \bmod m$ still
> leaves two live candidates separated by all but $2m$ of the original window.

Comparison hints halve the *interval* while removing only half the
*candidates*; residue hints slash the *candidate count* by a factor $m$ while
leaving the *interval* essentially intact. Two channels, two currencies. And
they refuse to mix: after $k$ adaptive comparison queries *and* a residue query
of modulus $m$, two consistent candidates still lie at least $w/2^k - 2m$
apart, while at least $w/(2^k m)$ candidates survive. The interval gain is
capped by the *order* budget alone — arithmetic side information is worthless
to an interval-sweeping algorithm.

---

## What one lie costs

There is one more appearance of the number $k+1$, and it is uncanny.

Suppose the oracle is allowed to lie — once, at a moment of its choosing.
Consider a strategy robust to that: it must identify the hidden value correctly
whichever single answer was corrupted. Run the strategy $k+1$ times against the
same hidden $x$, once for each choice of "lie at step $\ell$" (with
$\ell = k$ meaning "no lie"). Each run produces a length-$k$ transcript, and
these $k+1$ transcripts are pairwise distinct. So $(k+1) \cdot |C|$ distinct
transcripts must exist inside a space of only $2^k$ strings:

> **One Lie Costs the Factor $k+1$.** A $k$-query adaptive comparison strategy
> robust to a single lie can identify at most $2^k/(k+1)$ candidates.

The same $k+1$ that separates fixed batteries from adaptive ones in the
noiseless setting is exactly the tax that a single lie imposes on an adaptive
one. **Noise and non-adaptivity are the same tax.** Concretely: $20$ truthful
queries pin a $40$-bit factor exactly, but no $20$-query strategy survives a
single lie on that window, since $2^{20}/21 < 2^{20}$.

---

## Where to stop buying

Finally, economics. Each query costs $c$; the un-hinted downstream scan costs
$T$; after $k$ adaptive queries the residual cost is $T \cdot 2^{-k}$. Total:
$$\mathrm{cost}(k) = ck + T \cdot 2^{-k}.$$
This is strictly convex, and its minimum sits at
$$k_{\mathrm{opt}} = \log_2\!\left(\frac{T \ln 2}{c}\right),$$
where the residual downstream cost has fallen to exactly $c/\ln 2$ — the
marginal query has become as expensive as everything it saves. Since the budget
must be an integer, the best integer budget is $\lfloor k_{\mathrm{opt}}
\rfloor$ or $\lceil k_{\mathrm{opt}} \rceil$, never more than one query away
from the formula.

The scan length itself is where the two regimes come from. Fermat's method
starts at $\sqrt N$ and terminates at $(p+q)/2$, so its length is
$$\frac{p+q}{2} - \sqrt{pq} = \frac{(\sqrt q - \sqrt p)^2}{2}
= \sqrt N \cdot \frac{(\sqrt\rho - 1)^2}{2\sqrt\rho},
\qquad \rho = q/p.$$
That last function is $0$ at $\rho = 1$ and strictly increasing thereafter:
below $\sqrt N/60000$ for $\rho \le 1.01$, above $\sqrt N/2$ for
$\rho \ge 7.5$. A factor of at least $10^4$ between the two regimes, from a
single parameter. (There is a pretty aside here: for a perfect square
$N = n^2$, the Fermat witnesses $(a,b)$ with $(a-b)(a+b) = n^2$ are exactly the
Pythagorean triples $n^2 + b^2 = a^2$. Difference-of-squares factoring *is*
Pythagorean triple enumeration in disguise.)

---

## The shape of the law

Step back and the whole thing has a single silhouette.

Information from an external oracle is priced at one bit per query, absolutely
and with no exceptions. What varies is how much of that bit a given protocol
actually collects. A fixed comparison battery collects $\log_2(k+1)/k$ bits per
query — asymptotically nothing — and in the balanced regime, where the support
is narrow and the thresholds are spread wide, it collects *literally zero*.
Adaptive comparison queries collect the full bit, so speedups multiply, up to
the hard ceiling at $\lceil \log_2 w \rceil$ queries, where the curve goes flat
because there is nothing left to learn. A single lie costs a factor $k+1$ —
the same tax, in the same currency. And knowing where to stop is a one-line
calculation.

Hints compound. Hints price linearly. Both, exactly, and now we know precisely
which is which.
