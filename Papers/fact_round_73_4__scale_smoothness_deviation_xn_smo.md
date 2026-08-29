# The Dial That Averages to One

### A guided tour of the quadratic-residue structure of $x^2 - N$

---

## Where we are going

There is a piece of folklore at the heart of integer factoring. To split a
large number $N$, the quadratic sieve looks at the values of

$$f(x) = x^2 - N$$

for $x$ just above $\sqrt{N}$, hunting for values that factor entirely into
small primes — *smooth* values. Collect enough of them, combine the right
subset so that every prime exponent becomes even, and you have manufactured a
congruence $X^2 \equiv Y^2 \pmod N$; a greatest common divisor then splits $N$.

The folklore says this polynomial is **better than random**. Here is the reason
it feels true. Reduce modulo a prime $p$. A random integer is divisible by $p$
one time in $p$. But $x^2 - N \equiv 0 \pmod p$ has *two* solutions
$x \equiv \pm r$ whenever $N \equiv r^2$ is a quadratic residue. Double the hit
rate!

By the end of this page you will know exactly why that folklore is **false in
the first moment, true in the second moment, and bounded forever by the number
2** — and you will have turned the dials yourself.

---

## 1 · Meet the dial

Everything starts with one small integer. For an odd prime $p$ and a residue
$N$ modulo $p$, define the **dial**

$$D_p(N) \;=\; \#\{\, x \bmod p \;:\; x^2 \equiv N \,\}.$$

It counts the residue classes of $x$ on which $p$ divides $f(x)$. A random
integer has "dial 1".

Turn the prime slider below. Watch the bars. Every bar is either at height 2
(a quadratic residue: two roots), at height 0 (a nonresidue: no roots), or —
at exactly one place, $N = 0$ — at height 1.

{{interactive_demo:0}}

Notice the two numbers the console reports and never gets wrong, whichever
prime you choose:

$$\sum_{N} D_p(N) = p, \qquad \sum_{N} D_p(N)^2 = 2p - 1.$$

The first says the **mean dial is exactly 1** — precisely the random rate. The
double hit rate on residues is paid for, exactly and completely, by the total
miss on nonresidues.

<details>
<summary><b>Click to reveal the one-line proof of the first identity</b></summary>

The sum $\sum_N D_p(N)$ counts pairs $(x, N)$ with $x^2 \equiv N \pmod p$. Fix
$x$: exactly one $N$ works, namely $x^2$. So the count equals the number of
choices of $x$, which is $p$. There is no error term and no asymptotic — the
identity is exact for every prime.

Equivalently: $D_p(N) = 1 + \chi_p(N)$ where $\chi_p$ is the
[Legendre symbol](https://en.wikipedia.org/wiki/Legendre_symbol), and the
statement is the classical vanishing of a nontrivial
[character sum](https://en.wikipedia.org/wiki/Character_sum),
$\sum_N \chi_p(N) = 0$.
</details>

<details>
<summary><b>Click to reveal the dial dichotomy, stated precisely</b></summary>

**Theorem (Dial Dichotomy).** Let $p$ be an odd prime. Then $D_p(0) = 1$;
$D_p(N) = 2$ for every nonzero quadratic residue $N$; and $D_p(N) = 0$ for every
nonresidue. In particular $D_p(N) \le 2$ always.

*Proof.* In the field $\mathbb{Z}/p$, $y^2 = c^2$ if and only if
$(y-c)(y+c) = 0$, so the root set of $x^2 = c^2$ is $\{c, -c\}$. Since $p$ is
odd, $2$ is invertible, so $c = -c$ forces $c = 0$: the root set is a singleton
exactly at the origin and a two-element set otherwise. If $N$ is not of the form
$r^2$ the root set is empty. $\blacksquare$

**Corollary (Balance).** Exactly $(p-1)/2$ residues have dial 2 and exactly
$(p-1)/2$ have dial 0. Indeed if $m_2 + m_0 = p - 1$ and $2m_2 + 1 = p$, then
$m_2 = (p-1)/2$.
</details>

---

## 2 · From dials to densities

The dial matters because it controls a **density**. The chance that $p$ fails to
divide a value of $f$ is $1 - D_p(N)/p$; for a random integer it is $1 - 1/p$.
Their ratio is the **local factor**

$$L_p(N) \;=\; \frac{p - D_p(N)}{p - 1},$$

which equals $\frac{p-2}{p-1}$ at a residue and $\frac{p}{p-1}$ at a nonresidue
— a small step below and a small step above 1, symmetrically placed. Because the
mean dial is 1, the mean local factor is 1. And because we know the second
moment of the dial exactly, we know the variance of the local factor exactly:

$$\operatorname{Var}(L_p) \;=\; \frac{1}{p(p-1)}.$$

An exact rational number, with no approximation anywhere. Try the $N$-lookup box
in the console above: enter any integer and see which side of the dial it lands
on, and what local factor it earns.

The figure below assembles the whole local picture — the dial spectrum, the
exact distribution of the global correction we are about to build, the
convergence of the master constant, and the $p^{-2}$ decay of the per-prime
variance that makes everything converge.

{{visualization:0}}

---

## 3 · The structure correction

Multiply the local factors over all primes in your factor base and you get the
single object that would carry a smoothness edge if one existed — the
**structure correction**

$$C(N) \;=\; \prod_{p \le B,\ p \text{ odd}} L_p(N \bmod p).$$

This is the complete multiplicative discrepancy between the heuristic smoothness
probability of $x^2 - N$ and that of a random integer of the same size. A random
integer has $C \equiv 1$ identically.

In the laboratory below, choose a factor base. The page then enumerates *every*
residue class of $N$ modulo the product of your primes — no sampling, no
estimation — and reports the exact statistics.

{{interactive_demo:1}}

Two things should have happened as you clicked.

**The mean stayed nailed to 1.** However wide the distribution of $C$ becomes,
its average is exactly 1. This is the exact form of the experimental verdict
that the quadratic sieve's polynomial is not smoother than random.

**The second moment refused to grow past 2.** Add primes; watch $\Delta$ climb
towards $\approx 1.2957$ and stop dead.

<details>
<summary><b>Click to reveal the proofs of the two ensemble theorems</b></summary>

**Theorem (Ensemble neutrality).** For every finite family of odd primes,
$\mathbb{E}[C] = 1$ exactly.

*Proof.* The residue coordinates are independent, so the expectation of the
product is the product of the expectations, and each is exactly 1. Note what
this does **not** depend on: the smoothness bound $B$, the size of $N$, the size
of the values $v$, and hence the smoothness depth $u$. $\blacksquare$

**Theorem (Uniform dispersion ceiling).** For every finite family of *distinct*
odd primes,
$$1 \;<\; \mathbb{E}[C^2] \;=\; \Delta \;=\; \prod_p \Bigl(1 + \tfrac{1}{p(p-1)}\Bigr) \;\le\; 2.$$

*Proof.* Independence again gives the product formula. For the bound, put
$x_p = \frac{1}{p(p-1)}$. The identity
$\frac{1}{n(n-1)} = \frac{1}{n-1} - \frac{1}{n}$ telescopes, so
$\sum_{n=3}^{M} \frac{1}{n(n-1)} = \frac12 - \frac1M \le \frac12$ over any set
of integers $\ge 3$; in particular $\sum_p x_p \le \frac12$. Combined with
$\prod (1 + x_i) \le 1/(1 - \sum x_i)$, this gives $\Delta \le 2$. The strict
lower bound is trivial: every factor exceeds 1. $\blacksquare$

Since $\operatorname{Var}(C) = \Delta - 1$, Chebyshev's inequality follows
immediately: the fraction of residue classes with $|C - 1| \ge t$ is at most
$(\Delta - 1)/t^2 \le 1/t^2$, uniformly in $B$.
</details>

<details>
<summary><b>Click to reveal why extreme corrections are exponentially rare</b></summary>

**Theorem (Exact joint uniformity).** For distinct odd primes
$p_1, \dots, p_k$ and every prescribed pattern $(d_1, \dots, d_k) \in \{0,2\}^k$
of dial settings, the number of residue tuples realising that exact pattern is

$$\frac{1}{2^k}\prod_{i=1}^{k}(p_i - 1),$$

independent of the pattern. The dial vector is exactly uniform on $\{0,2\}^k$.

*Proof.* The event factorises over coordinates and each factor is $(p_i - 1)/2$
by the balance corollary, regardless of whether $d_i$ is 0 or 2. $\blacksquare$

**Consequence.** The all-nonresidue and all-residue patterns — where $C$ attains
its maximum $\prod \frac{p}{p-1}$ and minimum $\prod \frac{p-2}{p-1}$ — each have
relative density $2^{-k}\prod\frac{p-1}{p}$. Extreme corrections are
exponentially rare in the size of the factor base. That is the combinatorial
reason the clustering they cause stays $O(1)$ rather than exploding.
</details>

Here is the algorithm the laboratory runs internally — an exhaustive,
zero-tolerance certification of all three ensemble identities.

{{algorithm:2}}

---

## 4 · The QR dial grips — but only in the second moment

There *is* a real signal. Flip a single coordinate of $N$ from a quadratic
residue to a nonresidue and the structure correction **strictly increases**:
$\frac{p-2}{p-1} < \frac{p}{p-1}$. So an $N$ with many quadratic residues among
the factor-base primes is genuinely harder to make smooth.

This is a second-moment phenomenon and cannot ever become a first-moment
phenomenon, because the residue and nonresidue cases occur exactly equally
often. Panel (c) of the figure below shows the exact monotone staircase.

{{visualization:1}}

---

## 5 · The experiment, and its two puzzles

None of this was armchair mathematics. It came out of a large computational
comparison designed to hunt for a smoothness edge where it would actually
matter.

Smoothness depth is measured by $u = \log v / \log B$, where $v$ is the size of
the value tested and $B$ the smoothness bound. Earlier attempts lived at
$u < 4.75$; this one pushed to $u \in \{5,6,7,8\}$ at $B = 1000$, with about
$1.5 \times 10^9$ candidates per arm, against controls histogram-matched on
bit-length and mantissa octant.

| $u$ | ratio $r(u)$ | 95% interval |
|---|---|---|
| $5.96$ | $1.011$ | $[0.947,\ 1.075]$ |
| $6.95$ | $0.949$ | $[0.783,\ 1.152]$ |
| $7.93$ | $0.900$ | $[0.455,\ 1.700]$ |
| $8.26$ | $1.200$ | $[0.500,\ 3.000]$ |

Every interval covers 1. The trend in $\log r$ against $u$ has slope $+0.036$
with $p = 0.831$: flat. The tightest bound is $|r - 1| \le 0.217$. Exactly as
the mean-one theorem demands.

But two secondary signals were real: the per-$N$ counts were **overdispersed**,
with index $1.61\,[1.50,1.73]$ at $u \approx 6$, and the fraction of
quadratic-residue primes predicted an $N$'s smoothness rate with Spearman
correlation $0.32$. And then — above $u \approx 7$ — **both vanished**, to
$\approx 1.00$ and $0.04$.

That is the puzzle, because nothing in the arithmetic depends on $u$.

You can reproduce the small-scale version of the null yourself:

{{demo:0}}

---

## 6 · Why the clustering dies

The resolution is that the signals are not arithmetic — they are *statistical*.

Model the number of smooth values found for a given $N$ as a count with
conditional mean $\lambda C(N)$ and conditional variance
$\lambda C(N)(1 - qC(N))$: exactly a binomial with $n$ trials of success
probability $q C(N)$ and rate $\lambda = nq$. The finite
[law of total variance](https://en.wikipedia.org/wiki/Law_of_total_variance)
gives an exact identity:

$$\text{Mean} = \lambda, \qquad
\text{Var} = \lambda\bigl(1 + \lambda(\Delta - 1) - q\,\Delta\bigr),$$

so the dispersion index is $1 + \lambda(\Delta-1) - q\Delta$ and

$$\bigl|\text{Var} - \text{Mean}\bigr| \;\le\; \text{Mean}\cdot(\lambda + 2q).$$

The arithmetic enters only through $\Delta$, which is capped at 2. The
*observable* excess dispersion is proportional to the **event rate**.

Go back to the laboratory (Section 3) and drag the $\lambda$ slider in panel 3.
Hold $\Delta$ fixed — it never changes — and watch the dispersion index slide
from clearly detectable clustering down to statistically invisible. At
$u \approx 8$ the experiment had roughly 18 events across 4000 clusters, i.e.
$\lambda \approx 0.005$: no experiment could have seen dispersion there.

**The clustering did not die. It became unobservable, at a rate the theory
predicts exactly.**

---

## 7 · The computational core

Two algorithms carry the whole development. The first certifies the local
statistics prime by prime; the second evaluates the master constant in exact
rational arithmetic and verifies the ceiling.

{{algorithm:0}}

{{algorithm:1}}

---

## 8 · Three lessons worth carrying elsewhere

**First moments are protected by symmetry.** The deviation of the dial from
randomness is exactly a nontrivial character, and characters sum to zero. Any
structure of that shape is ensemble-neutral, exactly and forever.

**Second moments are $O(1)$ because Euler products converge.** The variance of
$C$ is $\prod(1 + \frac{1}{p(p-1)}) - 1$, and $\sum \frac{1}{p(p-1)}$ converges
— the telescoping bound over all integers $\ge 3$ is $\frac12$. Arithmetic
structure can buy a constant. It cannot buy a growing factor.

**Observability of a second moment is proportional to the event rate.** Any
experiment reporting overdispersion at rate $\lambda$ is reporting
$\lambda \cdot \operatorname{Var}(C)$. Comparing a high-rate measurement to a
low-rate one and concluding the mechanism changed is a methodological error: the
mechanism is constant, the microscope is not.

---

## 9 · What is still open

The measurement tops out near $u \approx 8.5$, because with $N \le 2^{80}$ and
$x \le 4\sqrt{N}$ at $B = 1000$ you simply cannot make larger $u$;
production-scale $u \ge 9$ is untested, though the exact theorems apply there
verbatim.

The natural generalisation is already visible. Everything here was driven by the
*variance of the number of roots* of the sieve polynomial modulo $p$. For a
degree-$d$ polynomial with Galois group $G$, that quantity is the variance of the
number of fixed points of a uniform element of $G$, distributed by
[Chebotarev's theorem](https://en.wikipedia.org/wiki/Chebotarev%27s_density_theorem).
The *mean* number of roots is 1 for every irreducible polynomial — Burnside's
lemma applied to the transitive action on the roots — so the ensemble neutrality
survives at every degree. Only the ceiling changes, and it changes in a way you
can compute from the group.

Which is to say: the dial averages to one, always. It is only the wobble that
has a story.
