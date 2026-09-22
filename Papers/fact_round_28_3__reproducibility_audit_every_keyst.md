# Does your number actually reproduce?

> *A guided tour of the arithmetic hidden inside a routine reproducibility audit.*

You run a program. You write $1.3125$ into a table. Months later you run it
again, the fresh run prints $1.3125$, and you write **reproduced** in the margin.

Pause on that for a second. What did you just learn? That two decimal strings
agree to four places. Not, on the face of it, that the two *numbers* are the
same — between $1.31250$ and $1.31254$ there is a whole continuum of impostors.

And yet, under a condition you can check in your head, four-decimal agreement is
a **proof** of exact equality. The condition has nothing to do with your code,
your seeds, or your hardware. It is a statement about **denominators**. This
page builds that statement from scratch, then follows it into a corner of number
theory where it spectacularly fails — and shows what honest reproducibility
looks like there instead.

---

## 1. The gap you cannot fall into

Take two fractions $a/q$ and $b/r$. How close can they be without being equal?
Put them over a common denominator:

$$\frac{a}{q}-\frac{b}{r}=\frac{ar-bq}{qr}.$$

The numerator is an **integer**. If the fractions are distinct it is not zero, so
its absolute value is at least $1$, and therefore

$$\left|\frac{a}{q}-\frac{b}{r}\right|\ \ge\ \frac{1}{qr}.$$

Distinct fractions with small denominators cannot huddle. They are pushed apart
by a gap of size $1/qr$. That granularity is the whole engine, and it is what
the first widget lets you feel directly: drag the denominator bound, watch the
scaffold of admissible values thicken, and watch the certificate live or die.

{{interactive_demo:0}}

<details>
<summary>Click to reveal the formal statement and its proof</summary>

**Separation Theorem.** *For integers $a,b$ and positive integers $q,r$, if*
$\left|a/q-b/r\right|<1/(qr)$ *then* $a/q=b/r$.

*Proof.* Multiply the hypothesis by $qr>0$. The left-hand side becomes
$|ar-bq|$, an absolute value of an integer, and the right-hand side becomes $1$.
An integer of absolute value strictly below $1$ is zero, so $ar=bq$, i.e.
$a/q=b/r$. $\blacksquare$

**Four-Decimal Certificate.** *If both denominators are at most $70$ and the
values agree to within $10^{-4}$, they are equal* — because $70^2=4900<10^4$, so
the guaranteed gap $1/(qr)\ge 1/4900$ is wider than the tolerance.

**Sharpness.** $|1/100-1/101| = 1/10100 \approx 9.9\times10^{-5} < 10^{-4}$ while
$1/100\ne 1/101$. Past denominator $100$ the certificate is simply false. (The
exact break-even is $Q=99$; $70$ is a comfortable working bound.)

The scaffold of fractions with denominator at most $Q$ is the
[Farey dissection](https://en.wikipedia.org/wiki/Farey_sequence) of level $Q$,
and $1/Q^2$ is its resolution. Certifiability is a question about where your
recorded number sits in that scaffold, and about nothing else.
</details>

The algorithm below is the certificate turned into code — note that every
comparison happens in exact integer arithmetic, so the *decision* about
floating-point agreement never itself uses floating point.

{{algorithm:0}}

---

## 2. What we are auditing: an arithmetic channel

To see the theory bite we need real recorded numbers. Ours come from a small,
rather beautiful channel.

Fix $n$ and work modulo $n$. Think of the residues as Frobenius elements of a
cyclic field extension. The datum you read off a residue $a$ is its **splitting
type**

$$T(a)=\frac{n}{\gcd(n,a)},$$

the order of $a$ in the group — equivalently, a prime with that Frobenius splits
into $n/T(a)$ primes of degree $T(a)$. Exactly $\varphi(d)$ residues have
$T=d$ for each divisor $d\mid n$, so drawing $a$ uniformly gives
$\Pr[T=d]=\varphi(d)/n$ and a recordable entropy

$$H_T(n)=-\sum_{d\mid n}\frac{\varphi(d)}{n}\log_2\frac{\varphi(d)}{n}
=\log_2 n-\frac1n\sum_{d\mid n}\varphi(d)\log_2\varphi(d).$$

There is a richer observable too. Multiply two primes: take $(x,y)$ uniform,
record the unordered pair of types $K=\{T(x),T(y)\}$ and the **norm class**
$N=x+y \bmod n$ — the Frobenius of the product. How many bits about the hidden
factors leak through the product? That mutual information,

$$I_{\mathrm{pair}}(n)=I(K;N)=H(K)+H(N)-H(K,N),$$

is the channel's **pair capacity**.

Play with both in the explorer below. Slide $n$; then slide the *second* control,
which multiplies every residue by a unit — a change of generator, the one
arbitrary choice the whole construction makes. Watch the tiles shuffle and the
numbers refuse to move.

{{interactive_demo:1}}

{{algorithm:1}}

---

## 3. Four recorded rows that were secretly a law

Look at the two-power entropies: $1,\ \tfrac32,\ \tfrac74,\ \tfrac{15}8$. That is
not a table, it is the beginning of a sequence — and the divisor formula proves
it.

> **Two-Adic Entropy Law.** For every $k\ge1$,
> $$H_T(2^k)=2-2^{\,1-k}=\frac{2^k-1}{2^{\,k-1}}.$$

<details>
<summary>Click to reveal the derivation</summary>

The divisors of $2^k$ are $2^0,\dots,2^k$ and $\varphi(2^{i+1})=2^i$, so the
correction term is

$$\sum_{d\mid 2^k}\varphi(d)\log_2\varphi(d)=\sum_{i<k} i\,2^i=(k-2)2^k+2,$$

using the arithmetic–geometric identity $\sum_{i<k}i2^i=(k-2)2^k+2$ (a one-line
induction). Dividing by $2^k$ and subtracting from $\log_2 2^k=k$ gives
$k-(k-2)-2^{1-k}=2-2^{1-k}$. $\blacksquare$

Three corollaries come free: the tower is **strictly increasing**, it stays
**below two bits**, and it **converges to exactly two**. Whatever the size of the
cyclic $2$-group, the splitting type of a random residue carries less than two
bits of information.
</details>

The capacities have their own law, and the numerators are an old friend:

$$I_{\mathrm{pair}}(2^k)=\frac43\left(1-4^{-k}\right)=\frac{J_k}{4^{\,k-1}},
\qquad J_k=\frac{4^k-1}{3}=1,5,21,85,341,1365,5461,\dots$$

the [Jacobsthal numbers](https://oeis.org/A002450), satisfying
$J_{k+1}=4J_k+1$. Here is the whole picture — enumeration against closed form,
with both ceilings:

{{visualization:1}}

And here is a verification worth more than any number of matching digits: because
every probability on a two-power order is dyadic, the enumerated entropies can be
computed as **exact fractions**, so the check is an equality of rationals rather
than an agreement of decimals.

{{demo:1}}

{{algorithm:2}}

> **Structure beats size.** Rows of this tower are far apart:
> $H_T(2^k)-H_T(2^j)\ge 2^{-j}$ for $j<k$. So a record within $10^{-4}$ of a row
> identifies that row for every $k\le13$ — even though the denominator
> $2^{k-1}=4096$ is far outside the range the generic bound of $70$ can handle.
> When your recorded family is a sparse ladder, publish the spacing: it is a much
> stronger certificate than extra digits.

---

## 4. Where no record can ever be right

Now take $n=6$. The recorded capacity $1.4738$ has the closed form

$$I_{\mathrm{pair}}(6)=\log_2 3-\tfrac19,$$

and $\log_2 3$ is irrational — for a reason that needs no transcendence theory at
all.

<details>
<summary>Click to reveal the three-line irrationality proof</summary>

Suppose $\log_2 3=m/q$ with $q>0$. Then $2^m=3^q$. But $3$ divides the
right-hand side and $3$ divides no power of $2$. Contradiction. $\blacksquare$

The obstruction is **unique factorisation**, nothing deeper. The same argument
shows $\log_2 n$ is rational exactly when $n$ is a power of two: from
$\log_2 n=a/b$ we get $n^b=2^a$, so every prime factor of $n$ is $2$.
</details>

Follow that honestly and it stings: **no decimal record, at any precision, equals
$I_{\mathrm{pair}}(6)$.** Not $1.4738$; not a thousand digits of it. Digit
agreement here can certify that your pipeline is deterministic. It can never
certify the value.

What *is* reproducible is the closed form plus a rigorous enclosure — and the
enclosure reduces to integer inequalities you can check exactly:

$$2^{1054}<3^{665}\ \Rightarrow\ \log_2 3>\tfrac{1054}{665},\qquad
3^{306}<2^{485}\ \Rightarrow\ \log_2 3<\tfrac{485}{306},$$

so $1.58496<\log_2 3<1.58497$ and hence
$|I_{\mathrm{pair}}(6)-1.4738|<10^{-4}$. The record is *validated*, never
*identical*.

{{algorithm:4}}

---

## 5. Which side of the line is your number on?

Astonishingly, for a large classical family we can answer that without computing
anything. Call $n$ **constructible** if every divisor $d$ of $n$ has $\varphi(d)$
a power of two. By the
[Gauss–Wantzel theorem](https://en.wikipedia.org/wiki/Constructible_polygon)
these are exactly the $n$ for which the regular $n$-gon can be drawn with
straightedge and compass: a power of two times distinct Fermat primes
$3,5,17,257,65537$.

> **Rationality Dichotomy.** On constructible orders, $H_T(n)$ is rational — and
> so certifiable by a rounded record — **precisely when $n$ is a power of two**.
> Everywhere else on that family it is irrational, and no record of any precision
> can equal it.

The reason is short: for constructible $n$ every term $\varphi(d)\log_2\varphi(d)$
is an integer, so $H_T(n)=\log_2 n-(\text{rational})$, and $\log_2 n$ is rational
only on the powers of two. A two-thousand-year-old question about ruler and
compass draws the boundary between "the audit proves it" and "the audit merely
encloses it".

{{visualization:2}}

{{algorithm:3}}

---

## 6. The strongest kind of reproducibility

There is a better notion than "the same code prints the same digits". A recorded
number should not depend on the *arbitrary choices* made when the pipeline was
set up — and this channel makes exactly one such choice: the generator used to
identify the Galois group with the integers modulo $n$. A different choice
relabels every residue $a\mapsto u\cdot a$ for a unit $u$.

Since $\gcd(n,ua)=\gcd(n,a)$, we get $T(u\cdot a)=T(a)$: the type is **blind** to
the choice. Histogram identical, entropy identical, semiprime type pair
identical, conditional table merely row-permuted. That is what the second slider
in the explorer above was showing you.

The sharper question is whether the type is the *only* such observable. It is.

> **Universality of the Splitting Type.** A readout $t$ modulo $n$ satisfies
> $t(u\cdot x)=t(x)$ for every unit $u$ **if and only if** $t=f\circ T$ for some
> function $f$.

<details>
<summary>Click to reveal the orbit computation behind the converse</summary>

We must show two residues with the same $\gcd$ with $n$ are unit multiples of one
another. Write $g$ for the common $\gcd$, $n=gm$, $a=ga_1$, $b=gb_1$. Cancelling
$g$ shows $a_1$ and $b_1$ are coprime to $m$, hence units modulo $m$. Then
$w=b_1a_1^{-1}$ is a unit modulo $m$, and since $m\mid n$ it lifts to a unit $u$
modulo $n$ along the surjection
$(\mathbb{Z}/n)^\times\twoheadrightarrow(\mathbb{Z}/m)^\times$. Multiplying
$ua_1\equiv b_1 \pmod m$ by $g$ gives $ua\equiv b \pmod n$. $\blacksquare$

So the orbits of relabelling are exactly the $\gcd$ classes, which are exactly the
fibres of $T$. Anything strictly finer than the type separates residues inside a
$\gcd$ class and is therefore an artefact of the coordinates — a number you can
reproduce only by reproducing your own conventions.
</details>

---

## 7. Run the whole thing yourself

Everything above — the certificate, the two laws, the enclosure, the dichotomy,
the invariance and its converse — in one script:

{{demo:0}}

And the picture that started it all, for one last look at *why* a rounded record
can be a theorem:

{{visualization:0}}

---

## 8. What to take away

Three verdicts hide behind the single word "reproduced", and only the mathematics
of your recorded quantity says which one you have earned:

1. **Certified equality** — the value is a rational with a small denominator.
   Digit agreement is a *proof*. You knew that before re-running anything.
2. **Validated enclosure** — the value is a closed-form irrational. No record
   equals it, ever. What reproduces is the derivation; what the digits do is
   bracket.
3. **Structural reproduction** — the value is invariant under every arbitrary
   choice in its own definition. It reproduces even under a complete rewrite,
   because no other answer was available.

The third is the one worth designing for. A table re-runs because your seeds were
fixed; a law reproduces because it is true. Four audited rows became
$H_T(2^k)=2-2^{1-k}$, and with that one line they are no longer merely
re-runnable — they are derivable, extended to every $k$, capped at two bits, and
certified by a gap that outruns the generic bound by nine orders of $k$.
