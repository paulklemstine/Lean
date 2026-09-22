# The Four-Decimal Illusion: When a Number Really Does Reproduce

Every computational science has the same small ritual. You run a program, you
write a number into a table, and months later — because a referee asks, or
because you no longer trust your past self — you run the program again and
compare. The digits match. You write **reproduced** in the margin and move on.

But what exactly have you learned? Suppose the recorded value is $1.3125$ and
the fresh run also prints $1.3125$. You have learned that two numbers agree to
four decimal places. You have *not*, on the face of it, learned that they are
the same number. Between $1.31250$ and $1.31254$ there is an entire continuum
of impostors.

And yet — and this is the surprise at the heart of this article — sometimes you
*have* learned exactly that. Under a condition you can check in your head,
agreement to four decimals is not evidence of equality. It is a **proof** of
equality, down to the last bit. The condition has nothing to do with the
software, the random seeds, the hardware, or the care of the experimenter. It
is a statement about *denominators*.

This article is about the mathematics hiding inside a routine reproducibility
audit, and about what happens to that mathematics when the number you recorded
is irrational.

---

## A gap you cannot fall into

Start with the simplest possible question. Take two fractions, $a/q$ and $b/r$,
with whole-number numerators and positive whole-number denominators. How close
can they be *without being equal*?

Put them over a common denominator:

$$\frac{a}{q} - \frac{b}{r} = \frac{ar - bq}{qr}.$$

The numerator $ar - bq$ is an integer. If the two fractions are different, that
integer is not zero — so its absolute value is at least $1$. Therefore

$$\left|\frac{a}{q} - \frac{b}{r}\right| \ \ge\ \frac{1}{qr} \qquad\text{whenever } \frac{a}{q} \ne \frac{b}{r}.$$

That one line is the whole engine. Distinct fractions with small denominators
cannot huddle arbitrarily close together; they are pushed apart by a gap of size
$1/qr$. Rational numbers, for all their density on the line, are *granular* once
you cap the denominator. Mathematicians know this granularity as the **Farey
dissection**: the fractions with denominator at most $Q$ form a discrete
scaffold on $[0,1]$ in which neighbours are never closer than $1/Q^2$.

Now turn it around, and you have a certificate rather than a bound.

> **Separation Theorem.** If $a/q$ and $b/r$ satisfy
> $\left|a/q - b/r\right| < 1/(qr)$, then $a/q = b/r$ exactly.
>
> **Four-Decimal Certificate.** If both denominators are at most $70$ and the
> two values agree to within $10^{-4}$, then they are the same number.

Why $70$? Because $70 \times 70 = 4900 < 10\,000$, so the guaranteed gap
$1/(qr) \ge 1/4900$ is comfortably wider than the tolerance $10^{-4}$ — two
distinct such fractions simply cannot both fit in a window that narrow.

And the theorem is sharp in a way you can hold in your hand. The fractions
$1/100$ and $1/101$ are different, yet

$$\left|\frac{1}{100} - \frac{1}{101}\right| = \frac{1}{10\,100} \approx 9.9 \times 10^{-5} < 10^{-4}.$$

Four decimals cannot tell them apart. Push the denominators past $100$ and the
certificate evaporates. So the audit ritual has a precise domain of validity:
**four-decimal agreement is a theorem about bounded denominators, not about
pipelines.** Whether your number reproduces *provably* is decided before you
ever press Enter, by the arithmetic shape of the quantity you chose to record.

---

## The numbers being audited

To see this in action we need real recorded quantities, and the ones in play
here come from a small and rather beautiful arithmetic channel.

Fix an integer $n \ge 1$ and work in $\mathbb{Z}/n$, the integers modulo $n$.
Think of it as the Galois group of a cyclic field extension: each residue $a$ is
a Frobenius element, and the datum an arithmetician reads off it is its
**splitting type**

$$T(a) \;=\; \frac{n}{\gcd(n,a)},$$

which is just the order of $a$ in the group — the number of "pieces" a prime
with that Frobenius splits into. Draw a residue uniformly at random and $T$
becomes a random variable. The number of residues of order $d$ is Euler's
totient $\varphi(d)$, so

$$\Pr[T = d] = \frac{\varphi(d)}{n} \quad \text{for each divisor } d \mid n,$$

and the information content of the readout, in bits, is its Shannon entropy

$$H_T(n) \;=\; -\sum_{d \mid n} \frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n} \;=\; \log_2 n - \frac{1}{n}\sum_{d\mid n}\varphi(d)\log_2 \varphi(d).$$

There is a second, richer observable. Multiply two primes together: take
$(x,y)$ uniform in $\mathbb{Z}/n \times \mathbb{Z}/n$, record the *unordered
pair of types* $K = \{T(x), T(y)\}$, and record the **norm class**
$N = x + y \bmod n$ — the Frobenius of the product. How much does the
composite's Frobenius tell you about the splitting behaviour of its two hidden
factors? That is a mutual information,

$$I_{\text{pair}}(n) = I(K;N) = H(K) + H(N) - H(K,N),$$

measured in bits. It is the *capacity* of the "semiprime channel": the number
of bits about the factor types that leak out through the product.

These are the headline numbers a computational record stores. For $n = 4$, $8$,
$16$ the capacities are $1.2500$, $1.3125$, $1.3281$. For $n = 6$ it is
$1.4738$. The entropies at $n = 2, 4, 8, 16$ are $1.0000$, $1.5000$, $1.7500$,
$1.8750$.

Which of those records can be *certified* by a re-run?

---

## The certifiable stratum: a table that was secretly a law

Look at the entropies of the two-power orders and the pattern almost shouts:

$$1,\quad \tfrac{3}{2},\quad \tfrac{7}{4},\quad \tfrac{15}{8},\ \dots$$

It is a law, and the divisor formula proves it. For $n = 2^k$, the divisors are
$1, 2, 4, \dots, 2^k$, and $\varphi(2^{i+1}) = 2^i$, so the weighted log-sum
collapses to the arithmetic–geometric series $\sum_{i<k} i\,2^i = (k-2)2^k + 2$,
giving

> **Two-Adic Entropy Law.** For every $k \ge 1$,
> $$H_T(2^k) \;=\; 2 - 2^{\,1-k} \;=\; \frac{2^k - 1}{2^{\,k-1}}.$$

Four stored rows have become a single theorem with infinitely many instances.
And the theorem says more than the rows did: the tower is strictly increasing,
it never reaches $2$, and it converges to exactly $2$. The two-power splitting
channel has a hard **two-bit ceiling** — no matter how large you make the
cyclic group, the type of a random residue carries less than two bits of
information, and asymptotically exactly two.

The companion capacities obey their own law. The recorded $5/4$, $21/16$,
$85/64$ continue as $341/256$, $1365/1024$, $5461/4096$ — the numerators
$1, 5, 21, 85, 341, 1365, 5461$ are the **Jacobsthal numbers**
$J_k = (4^k-1)/3$, and

$$I_{\text{pair}}(2^k) = \frac{4}{3}\left(1 - 4^{-k}\right) \nearrow \frac{4}{3}.$$

Now apply the certificate. Every one of these values is a fraction with a small
power-of-two denominator: $4$, $16$, $64$, $2$, $8$. All well under $70$. So for
each of them, a fresh run that produces a rational value with denominator at
most $70$ and lands within $10^{-4}$ of the record has not merely *agreed* with
the record — it has **reproduced it exactly**, and this is a theorem, not an
inference from digits.

There is an even better certificate available for the two-power tower, and it
comes from structure rather than from denominator size. Consecutive rows are
separated by a definite gap: if $j < k$ then

$$H_T(2^k) - H_T(2^j) \;\ge\; \frac{1}{2^{\,j}}.$$

The rows are isolated points. So if a re-run lands within $10^{-4}$ of the
recorded row for $2^k$, and $k \le 13$, the re-run *is* that row — there is no
neighbouring row it could be confused with, whatever its denominator. Structure
beats size: knowing that your value lives on a sparse ladder certifies it far
beyond what the generic bound allows.

---

## The stratum where no record can ever be right

Then there is $n = 6$, and the mood changes. The recorded capacity $1.4738$
turns out to have the closed form

$$I_{\text{pair}}(6) = \log_2 3 - \tfrac{1}{9}.$$

And $\log_2 3$ is irrational. The proof is three lines and needs no
transcendence theory at all — only unique factorisation. If $\log_2 3 = m/q$
with $q > 0$, then $2^m = 3^q$; but $3$ divides the right-hand side and cannot
divide a power of $2$. Contradiction.

Follow the consequence honestly. $I_{\text{pair}}(6)$ is irrational, so **no
decimal record, at any precision, is equal to it.** Not $1.4738$; not
$1.473851389610$; not a stored value with a thousand digits. Whatever your
re-run prints, if it prints a finite decimal it prints a number that is
provably *not* the quantity in the table. Digit agreement in this stratum can
never be a proof of the value. What it certifies is something weaker and more
honest: that the pipeline is deterministic.

This does not make the record meaningless — it makes it a different kind of
object. What is reproducible here is the **closed form**, together with an
explicit enclosure. Rational approximations to $\log_2 3$ good enough to pin the
fourth decimal come from its continued fraction, and the sharp ones can be
checked as plain integer inequalities:

$$2^{1054} < 3^{665} \quad\Longrightarrow\quad \log_2 3 > \frac{1054}{665} = 1.58496240\ldots$$
$$3^{306} < 2^{485} \quad\Longrightarrow\quad \log_2 3 < \frac{485}{306} = 1.58496732\ldots$$

so $1.58496 < \log_2 3 < 1.58497$, and therefore

$$\left| I_{\text{pair}}(6) - 1.4738 \right| < 10^{-4}.$$

The record is *validated* — it is a correct four-decimal enclosure of a number
we can name exactly — but it is not, and can never be, *identical* to it. The
audit verdict has to be restated: not "the numbers match", but "the derivation
reproduces, and the record encloses".

---

## Which side of the line are you on?

So a recorded entropy belongs to one of two strata, and it would be nice to know
which without running anything. For a large and classical family of orders, we
can say exactly.

Call $n$ **constructible** if every divisor $d$ of $n$ has $\varphi(d)$ a power
of two. By the Gauss–Wantzel theorem these are precisely the $n$ for which the
regular $n$-gon is constructible with straightedge and compass: a power of two
times a product of distinct Fermat primes ($3, 5, 17, 257, 65537$). For such an
$n$, every term $\varphi(d)\log_2\varphi(d)$ in the divisor formula is an
integer, so

$$H_T(n) = \log_2 n - (\text{a rational number}).$$

Its rationality therefore rests entirely on that of $\log_2 n$ — and by the same
unique-factorisation argument as before, $\log_2 n$ is rational exactly when $n$
is a power of two. (If $\log_2 n = a/b$ then $n^b = 2^a$, so every prime factor
of $n$ is $2$.) Hence:

> **Rationality Dichotomy.** On the constructible orders, the recorded type
> entropy $H_T(n)$ is rational — and so certifiable by a rounded record —
> precisely when $n$ is a power of two. On every other constructible order it is
> irrational, and no record of any precision can equal it.

The boundary between "the audit proves it" and "the audit merely enclosed it"
is drawn, remarkably, by a two-thousand-year-old question about ruler and
compass. $H_T(3)$, $H_T(5)$, $H_T(15)$, $H_T(17)$ are all irrational — beautiful
numbers, but not certifiable ones.

---

## Reproducible by construction

There is a second thing "reproducible" ought to mean, and it is stronger than
re-running your own script. A recorded number should not depend on the
*arbitrary choices* made when the pipeline was set up. Re-running with the same
convention reproduces your conventions along with your results.

For this channel there is exactly one such choice. Identifying an abstract
cyclic Galois group with $\mathbb{Z}/n$ requires choosing a generator, and a
different choice relabels every residue $a \mapsto u\cdot a$ for some unit $u$
modulo $n$. That is a genuine renaming of the entire sample space. Does the
record survive it?

It does — exactly, not approximately — and for a reason of one line:
$\gcd(n, ua) = \gcd(n, a)$ when $u$ is a unit, so

$$T(u \cdot a) = T(a).$$

The splitting type is *blind* to the change of generator. Its histogram is
identical, its entropy is identical, the unordered type pair of a semiprime is
identical, and the conditional table that computes $I_{\text{pair}}$ merely has
its rows permuted, which does not move an average. Every headline number in the
record is a property of the field, not of the coordinates someone picked for it.

And now the sharper question: is the splitting type the *only* such observable,
or did we just get lucky with it? Here the answer is a genuine
characterisation.

> **Universality of the Splitting Type.** A readout $t$ on $\mathbb{Z}/n$
> satisfies $t(u\cdot x) = t(x)$ for every unit $u$ **if and only if** $t$
> factors through the splitting type: $t = f \circ T$ for some function $f$.

One direction is the blindness above. The other is an orbit computation: two
residues with the same $\gcd$ with $n$ are always unit multiples of one another.
Write $n = gm$, $a = ga_1$, $b = gb_1$ where $g$ is the common $\gcd$; then
$a_1$ and $b_1$ are both units modulo $m$, so $b_1a_1^{-1}$ is a unit of
$\mathbb{Z}/m$, and it lifts to a unit of $\mathbb{Z}/n$ along the surjection
$(\mathbb{Z}/n)^\times \to (\mathbb{Z}/m)^\times$. That lift carries $a$ to $b$.

So the orbits of the relabelling action are *exactly* the $\gcd$ classes, which
are *exactly* the fibres of $T$. Any quantity that deserves to be recorded —
any quantity independent of the arbitrary generator — is a function of the
splitting type and nothing more. The type is not one invariant among many; it is
the universal one, the finest reproducible observable the channel admits.

---

## What the audit really certifies

Put the pieces together and the ritual reads differently.

When you record a number and later reproduce it, three quite different things
might be true, and only the mathematics of the recorded quantity can tell you
which.

1. **The value is a bounded-denominator rational.** Then four decimals are a
   *proof*: the recorded and re-run values are bit-for-bit identical, and you
   knew that before you re-ran anything. The certificate is granularity, not
   diligence.

2. **The value is a closed-form irrational.** Then no record equals it, ever.
   What reproduces is the derivation; what the digits do is enclose. Saying
   "reproduced to four decimals" here is saying something true but much weaker
   than it sounds.

3. **The value is invariant under the pipeline's arbitrary choices.** Then it
   reproduces *by construction* — not because you ran the same code, but because
   there is no other answer for a different implementation to get.

The third is the one worth designing for. A table of numbers re-runs because
your seeds were fixed; a *law* reproduces because it is true. The two-power
entropy tower is the case in point: four audited rows became
$H_T(2^k) = 2 - 2^{1-k}$, and with that single line the rows are not merely
re-runnable but *derivable*, extended to every $k$, bounded above by two bits,
and certified by the ladder gap $2^{-k}$ far past the point where the generic
denominator bound gives out.

That is the moral, and it applies well beyond this one arithmetic channel.
Reproducibility is usually treated as a property of infrastructure — containers,
seeds, version pins. The results above say that a good part of it is a property
of the *number itself*. Choose to record rationals with small denominators, and
your audits are theorems. Record irrationals, and be honest that you are storing
enclosures of quantities you should be naming in closed form. Record only what
is invariant under the choices you made arbitrarily, and the question of
reproduction does not arise at all: there was never anything else to reproduce.
