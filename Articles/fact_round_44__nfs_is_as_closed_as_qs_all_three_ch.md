# Three Ways to Fool Yourself About Factoring — and Why the Number Field Sieve Stays Shut

*How a constant, a counter that stops at sixty, and two slopes closed every proposed shortcut through the fastest classical factoring algorithm.*

---

## The fortress

Every time you open a secure web page, your browser is betting on one belief: multiplying two large primes is easy, and undoing the multiplication is hard. Take $p = 1{,}000{,}000{,}007$ and $q = 1{,}000{,}000{,}009$. A pocket calculator gives $N = pq = 1{,}000{,}000{,}016{,}000{,}000{,}063$ in a moment. Going the other way, from $N$ back to $p$ and $q$, is much harder. For the 2048-bit numbers used in RSA, no known classical method can do it before the Sun burns out.

The best general method we have is the **number field sieve** (NFS). Its running time is written in a notation that looks strange at first:

$$L_N\!\left[\tfrac13,\, c\right] \;=\; \exp\!\Big(c\,(\ln N)^{1/3}\,(\ln\ln N)^{2/3}\Big), \qquad c = \left(\tfrac{64}{9}\right)^{1/3} \approx 1.923.$$

This sits between polynomial time (which would make factoring easy) and exponential time (which would make it hopeless). The exponent $\tfrac13$ is the first number that matters. The constant $c$ is the second. Since the early 1990s, cryptographers have treated "improving the NFS" as meaning one thing: lowering $\tfrac13$, or lowering $c$.

This article is about a research round that went looking for such an improvement. It tested three separate "channels" through which some property of the particular number $N$ might be used to speed up the sieve. All three were closed. The interesting part is *how*. In each case the evidence for a breakthrough failed for a reason simple enough to state as a short theorem. Those three theorems, plus a fourth about the structure of the algorithm, are worth knowing for anyone who measures algorithms.

## The setting: hunting for a lever

The earlier rounds of this program had studied the **quadratic sieve** (QS), an older cousin of the NFS, and found it "closed": nothing about a specific $N$ gives a speedup in the terms that dominate its cost. The NFS was the one family those rounds had said should *not* be lumped in with the quadratic sieve. In the quadratic sieve, the set of primes the algorithm works with (the "factor base") is fixed by $N$ itself, through a quadratic-residue condition. In the NFS, the algebraic half of the factor base is governed by an auxiliary polynomial of degree $d$, which describes an auxiliary number field. So the NFS's columns really are *decoupled* from $N$. Perhaps that freedom left room for a lever.

The round attacked along three lines. Its own built-in critics, the "refuters," were tasked with killing any claim that did not hold up. Here is what each channel claimed and why it failed.

## Channel one: a constant is not an $L$

The round's measurement of NFS behaviour produced exactly one positive result: a measured cost ratio for a modified procedure. The first problem was practical. Nobody could reproduce it. The data file did not record which $N$ or which smoothness bound $B$ were used, and no script on disk generated it. Rebuilt from scratch, the experiment gave a ratio of $0.9932 \pm 0.0122$ over four runs. In other words, no effect at all.

The second objection is deeper, and it would apply even if the number had been reproducible. Suppose a modification really did make the sieve run in $0.99$ times the time, or $0.5$ times, or $0.001$ times. Does that change the NFS's complexity?

It does not, and this can be stated precisely. Write $x = \ln N$ for the size of the number in natural-log units. Define the **$L$-scale**

$$\Lambda_\alpha(x) = x^{\alpha}(\ln x)^{1-\alpha}.$$

Say that a cost function $f$ has **$L$-exponent $(\alpha, c)$** if

$$\frac{\ln f(x)}{\Lambda_\alpha(x)} \longrightarrow c \quad\text{as } x\to\infty.$$

This limit is the invariant the literature reports when it says "the NFS has constant $1.923$." It behaves as you would hope:

> **Theorem (the ladder is well defined).** For $0<\alpha\le 1$, the function $L[\alpha,c]$ has $L$-exponent exactly $(\alpha,c)$, and the constant of any cost function, when it exists, is unique.

Now multiply by a constant $K>0$:

$$\frac{\ln(K f(x))}{\Lambda_\alpha(x)} = \frac{\ln K}{\Lambda_\alpha(x)} + \frac{\ln f(x)}{\Lambda_\alpha(x)}.$$

The first term is a fixed number divided by something that grows without bound, so it disappears.

> **Theorem (constant factors are invisible).** If $f$ is eventually positive and has $L$-exponent $(\alpha,c)$, then $Kf$ has the same $L$-exponent for every $K>0$. More generally, if $a \le g(x) \le b$ for positive constants $a,b$, then $g\cdot f$ has the same exponent.

The second version covers the case at hand exactly. A "speedup" quoted as $0.9932 \pm 0.0122$ is a factor trapped between two positive constants. Whatever it is, it cannot show up on the $L$-ladder.

The converse is just as sharp. A real improvement from $c$ to a smaller $c'$ is very large:

> **Theorem (genuine gains are superpolynomial).** If $c'<c$ and $0<\alpha\le1$, then $L[\alpha,c]/L[\alpha,c']$ eventually exceeds $x^d$ for *every* power $d$. Consequently no constant $K$ satisfies $L[\alpha,c] \le K\cdot L[\alpha,c']$ for all large $x$.

The proof is a single line. The ratio is itself an $L$-function, $L[\alpha, c-c']$, and $\exp\big((c-c')x^\alpha(\ln x)^{1-\alpha}\big)$ grows faster than $\exp\big((c-c')x^\alpha\big)$, which outgrows every polynomial.

So "constant-factor effect" and "$L[1/3]$ effect" are two completely separate categories. A finite set of experiments that shows a constant ratio is evidence for the first category and *never* for the second. The refuters ruled the positive result worthless *by category*, and the theorem says that ruling was correct.

## Channel two: the counter that stopped at sixty

Every sieve, QS and NFS alike, ends the same way. You collect "relations": numbers that factor completely over a small set of primes. You write each one as a row of exponents mod 2. Then you look for a set of rows that adds up to zero mod 2. Such a set multiplies to a perfect square on both sides of a congruence, and a gcd computation then splits $N$ with probability about one half.

The round's second channel looked at this linear-algebra step. A routine called `left_dependencies` was supposed to measure, instance by instance, how much work sparse elimination needs and how many dependencies it finds. Reading the code turned up a plain bug: **the routine breaks out of its loop after 60 dependencies.** Every operation count and fill-in figure was therefore read off a truncated run.

How bad is that? Linear algebra answers in two lines. Let $M$ be the relation matrix, with $r$ rows (relations) and $c$ columns (primes), over any field. Let the **left nullity** be the dimension of the space of vectors $v$ with $vM=0$, which is the number of independent dependencies.

> **Theorem (rank–nullity for relations).** $\operatorname{rank} M + \text{(left nullity)} = r$. Since $\operatorname{rank} M \le c$, the left nullity is at least the **excess** $r-c$. Over $\mathbb F_2$ the space of dependencies has exactly $2^{\text{nullity}}$ elements, so there are at least $2^{r-c}-1$ nonzero dependencies.

This is the basic guarantee of every sieve: collect more relations than primes and squares are certain to exist. It also shows what a capped counter does. If the reading is $\min(60, \text{nullity})$:

> **Theorem (saturation).** On every matrix with excess $r - c \ge 60$, the truncated reading is exactly $60$. Any two such matrices, of any shapes and from any $N$, give identical readings.

A real NFS run collects excess relations deliberately, so in the regime that matters the instrument returns the constant 60. It cannot distinguish one instance from another. It is like a thermometer whose scale stops at body temperature, used to look for fevers. The situation is worse still if the routine counted *dependency vectors* rather than independent dependencies. Since $2^6-1 = 63 > 60$, the cap is reached once the excess is just $6$.

## Channel three: the inversion that wasn't

The last headline from the sparse-algebra channel was an "inversion." The idea: as you collect more relations, the surplus of dependencies grows faster than the cost of the wider matrix, so extra consumption eventually pays for itself.

The refuters used the miner's own numbers. Over the measured range, the surplus grew by a factor of $7.94$ while the width grew by a factor of $5.30$. On a log–log plot, the slope of the surplus is

$$s = \frac{\ln 7.94}{\ln 5.30} \approx 1.242.$$

The width cost, by the miner's own fit, scales like $W^{1.819}$.

The two-point slope is the right estimator: on an exact power law $aW^s$ it returns $s$ exactly. The bracket $\tfrac65 < s < \tfrac54$ can be checked with integer arithmetic alone, because

$$7.94^4 \approx 3974.5 < 5.3^5 \approx 4181.9, \qquad 5.3^6 \approx 22164 < 7.94^5 \approx 31557.$$

So $s < 1.25 < 1.819$. Both quantities grow, and the cost grows faster. For power laws that settles the question:

> **Theorem (no inversion).** Let the surplus be $S(W)=aW^s$ and the cost $C(W)=bW^t$ with $a,b>0$ and $0<s<t$. Then both are increasing; the ratio $S/C = (a/b)W^{-(t-s)}$ is strictly decreasing and tends to $0$; and once $C(W_0)\ge S(W_0)$ at some width $W_0$, it stays so at every larger width.

There is no consumption level at which the curves cross back. The "inversion" exists in neither the data nor the mathematics.

## The structural reason: decoupling without excess

Why did all three channels close? The answer comes from the one thing that *is* different about the NFS.

The NFS starts by choosing a polynomial. The classical method is **base-$m$ selection**: choose $m$ with $m^d \le N < m^{d+1}$ and write $N$ in base $m$. The digits become the coefficients of a polynomial $f$ of degree $d$ with $f(m)=N$.

> **Theorem (base-$m$ selection).** If $m \ge 2$ and $m^d \le N < m^{d+1}$, the digit polynomial has degree exactly $d$, satisfies $f(m) = N$, and has every coefficient smaller than $m \le N^{1/d}$.

For our $N = 1{,}000{,}000{,}016{,}000{,}000{,}063$ and $d=3$, $m = 10^6$ and $f(X) = X^3 + 16000X + 63$. The sieve then looks for coprime pairs $(a,b)$ that make both $a - bm$ and the homogeneous norm $F(a,b)=\sum_i c_i a^i b^{d-i}$ smooth. The size of that norm is controlled by an elementary bound:

> **Theorem (norm bound).** If every $|c_i| \le M$ and $|a|,|b| \le U$, then $|F(a,b)| \le (d+1)\,M\,U^d$.

For a fixed degree, the factor $d+1$ is a constant, and by channel one it is invisible on the $L$-ladder.

The final step balances the degree. With $u = \ln U$ and $x = \ln N$, the log-sizes of the two sides combine to roughly $d\,u + x/d$. The AM–GM inequality settles it:

> **Theorem (degree balance).** For positive $u, x, d$: $\;d\,u + x/d \ge 2\sqrt{ux}$, with equality exactly when $d=\sqrt{x/u}$.

This variational principle produces the exponent $\tfrac13$ once $u$ is balanced in turn. It also shows that choosing $d$ cleverly for a particular instance can at best *reach* the balanced value, never go below it.

That is the full picture. The NFS's columns are governed by $d$ and not directly by $N$, so the decoupling is real and the round genuinely studied the NFS rather than the quadratic sieve under another name. But the decoupled quantities reach the cost only through a balance whose optimum is fixed, and through factors such as $d+1$ that are constants. There is no surplus in the factor base and no validated structural quantity that controls the elimination cost. **Zero factoring methods came out of the round. The NFS, like the QS, has no exploitable per-instance lever in the terms that dominate its cost.**

## Why a closed door is worth writing about

This might look like a report of failure. It is better read as a set of rules for anyone who measures algorithms, whether the subject is factoring, protein folding or training a neural network:

1. **Know which scale your claim lives on.** A ratio measured with error bars is a bounded factor, and bounded factors are invisible on any scale like $L[\alpha,c]$. To claim an asymptotic gain you need evidence that the ratio grows faster than every polynomial.
2. **Make sure your instrument can move.** A counter capped at $k$ returns $k$ on everything past the cap. If theory (here, rank–nullity) puts every interesting instance past the cap, the instrument measures nothing.
3. **Compare slopes honestly.** Two increasing power laws with different exponents never trade places twice. If the cost exponent is larger, the cost wins from some point on and keeps winning.

Each rule corresponds to a short theorem, and each is the kind of thing that can be checked before an experiment is run. The cryptographic protection on your browser is unaffected by this round, and now we know in detail why each proposed crack fails.
