# The Dials That Cannot Turn: Why a Partial Secret Cannot Amplify Itself

## A tempting free lunch

Imagine you are trying to break an RSA modulus $N = pq$, and someone hands you a
gift: a *partial key hint*. You do not learn the secret prime $p$, but you learn
its remainder upon division by some modulus $m$ — say $p \equiv r \pmod m$. This
is exactly the setting of Coppersmith's celebrated lattice attack, and the famous
threshold is that a hint of size $m \approx N^{1/4}$ suffices: knowing a quarter
of the bits of $p$ lets you recover all of it in polynomial time.

Just below that threshold, though, the attack dies. If your hint is a little too
small — $m$ a bit under $N^{1/4}$ — the lattice fails and you are left staring at
a candidate set: all the integers in your search window that are congruent to $r$
modulo $m$. Typically that is on the order of $N^{1/4}$ candidates, far too many
to test.

So here is the tempting idea. The number $N$ is public. Quadratic residues are
free. For any discriminant $D$ you like, the Kronecker symbol $\left(\frac{D}{p}\right)$
is a $\pm 1$-valued "dial" attached to the secret prime — and dials of this kind
are cheap, plentiful, and classically loaded with arithmetic meaning. Why not
read off a whole vector of them,
$$
p \;\longmapsto\; \left(\left(\tfrac{D_1}{p}\right), \left(\tfrac{D_2}{p}\right), \ldots, \left(\tfrac{D_K}{p}\right)\right),
$$
and use the readings to *sieve* the candidate set? Each dial is a $\pm 1$ coin
flip; $K$ dials should cut the candidates by $2^K$; take $K \approx \log_2 N^{1/4}$
dials and the candidate set collapses to a single prime. Coppersmith's threshold
would drop, and RSA with a slightly-too-short hint would fall.

This article is about why that plan cannot work — not "does not seem to work in
practice", but *cannot*, as a theorem, for every choice of discriminants, every
number of dials, and every post-processing scheme you might layer on top. The
obstruction turns out to be embarrassingly simple once you see it, and it is
governed by a single integer.

## Dials are periodic, and periodicity is a budget

Strip the Kronecker symbol of its number-theoretic glamour and one property
remains: **periodicity**. The symbol $\left(\frac{D}{\cdot}\right)$ is a function
of $p$ that repeats with period dividing $4|D|$. Call any integer-valued function
$\chi$ of the candidate that satisfies $\chi(n + c) = \chi(n)$ for all $n$ a
**dial of conductor $c$**. Kronecker symbols are dials; so is "the third bit of
$p \bmod 1000$"; so is any table lookup indexed by a residue.

Given a family of $K$ dials with conductors $c_1, \dots, c_K$, the single number
that matters is their **conductor least common multiple**
$$
M^* \;=\; \operatorname{lcm}(c_1, c_2, \ldots, c_K).
$$
The whole dial vector is a function of $p \bmod M^*$ and of nothing else. That is
the entire content of the theory, and everything below is squeezed out of it.

Now put the dials next to the hint. The hint tells you $p \bmod m$. The dials tell
you a function of $p \bmod M^*$. The candidate set lives inside a single class
modulo $m$. How many distinct dial readings can occur on that class?

**Master Bound.** *Let a family of dials have conductor lcm $M^*$, and let $\Omega$
be any set of candidates all congruent to each other modulo $m$. Then the dial
vector takes at most*
$$
\frac{M^*}{\gcd(M^*, m)}
$$
*distinct values on $\Omega$.*

The proof is three lines. Write $g = \gcd(M^*, m)$. Every candidate in $\Omega$
has the same residue mod $m$, hence the same residue mod $g$. The dial vector
depends only on the residue mod $M^*$, and among the $M^*$ residue classes mod
$M^*$ exactly $M^*/g$ are compatible with a prescribed class mod $g$. So the dial
vector can only reach $M^*/g$ values. Done.

That fraction $M^*/\gcd(M^*,m)$ is the **amplification budget**: it is the index
by which the dials' resolution overshoots the resolution the hint already gives
you. Immediately, by pigeonholing the candidates into their readings, one gets
the operational form:

**No amplification beyond budget.** *Some dial reading is shared by at least a
$\gcd(M^*, m)/M^*$ fraction of the candidates. Reading the dials therefore cannot
shrink a candidate set inside a hint class by more than the factor
$M^*/\gcd(M^*, m)$.*

And the bound is not a lazy over-estimate. For every conductor $M$ and every hint
modulus $m$ there is a dial — the "resolution dial" $p \mapsto p \bmod M$, which
simply reads the whole residue and is the most discriminating dial of conductor
$M$ — and a candidate set inside one hint class on which exactly $M/\gcd(M,m)$
readings occur. The budget is achieved, so no sharper universal bound exists.

## The trap closes: two regimes, both useless

Now watch the trap close. Split into two cases according to whether the dials'
conductor lcm divides the hint modulus.

**Regime 1: $M^* \mid m$ — the dials are computable, and worthless.** If $M^*$
divides $m$, the budget $M^*/\gcd(M^*,m)$ equals $1$. The dial vector is
*constant* on the entire candidate set. Filtering the candidates by "keep those
whose dials match the true reading" removes not a single candidate — the sieve is
the identity map. Indeed the dial vector is a function of $p \bmod m$, which is
precisely to say the attacker can compute it *from the hint alone*, without
knowing $p$. Data you computed from what you already knew cannot tell you
anything new.

This is worth stating in the strongest available form. Say a statistic $T$ of the
candidate is **hint-computable** if $T(p) = g(p \bmod m)$ for some function $g$ —
equivalently, if $T$ agrees on any two candidates with the same hint. Then:

**Zero-information dichotomy, useless half.** *Let $T$ be any hint-computable
statistic and $\Omega$ any candidate set inside a hint class. Then for every
secret quantity $S(p)$ the attacker would like to learn, the reading $T$ and the
secret $S$ are exactly independent on $\Omega$: for all values $t, s$,*
$$
\#\{p \in \Omega: T(p) = t,\, S(p) = s\}\cdot \#\Omega \;=\; \#\{p \in \Omega : T(p) = t\}\cdot\#\{p \in \Omega : S(p) = s\}.
$$
*The same holds for $h \circ T$ for every function $h$ whatsoever — no lattice
reduction, no statistical post-processing, no machine-learned decoder extracts
anything.*

That last clause is what makes it a genuine barrier rather than a remark. It
covers not just Kronecker dials with small conductors but *every* statistic the
attacker can compute from public data: any function $g(N, p \bmod m)$ of the
public modulus and the hint is hint-computable, hence exactly independent of every
secret. Self-generated data can never amplify a hint. Whatever your side channel,
if you can evaluate it, it is empty.

**Regime 2: $M^* \nmid m$ — the dials are informative, and unavailable.** Suppose
instead the dials really do separate two candidates of the same hint class. Then,
by definition, the dial vector is *not* a function of $p \bmod m$: the attacker
cannot evaluate it, because doing so requires knowing $p$ modulo something the
hint does not determine. Concretely, if $M^* \nmid m$ then the two integers $0$
and $m$ share a hint but differ mod $M^*$ — the hint genuinely underdetermines
what the dials want to read.

So there is a clean dichotomy: *computable implies useless; useful implies
incomputable*. There is no third regime.

## How far beyond the hint must a useful dial reach?

The dichotomy is qualitative. The quantitative version is where the story gets
sharp, because it puts a number on how expensive an informative dial would have
to be.

Combine the two pieces of the attacker's knowledge into one joint statistic: the
pair (hint, dial vector). The hint resolves $p$ modulo $m$; the dials resolve $p$
modulo $M^*$. Together they resolve $p$ modulo $\operatorname{lcm}(m, M^*)$ — and
not one bit further. Any two candidates congruent modulo $\operatorname{lcm}(m,M^*)$
produce *identical* hints and *identical* dial readings, whatever the dials are.

**Joint resolution cap.** *If the pair (hint, dial vector) determines the candidate
uniquely inside a search window $[0, X)$, then*
$$
X \;\le\; \operatorname{lcm}(m, M^*) \;\le\; m\,M^*, \qquad\text{hence}\qquad M^* \;\ge\; X/m .
$$

The proof is the cheapest kind: if $X$ exceeded $L = \operatorname{lcm}(m, M^*)$,
then $0$ and $L$ would both lie in the window, be congruent mod $L$, and hence be
indistinguishable — contradicting uniqueness.

Now instantiate in the actual attack regime. The secret prime satisfies
$p < N^{1/2}$, so the window is $X \approx N^{1/2}$, and the hint has size
$m \approx N^{1/4}$; that is, $X = m^2$. The cap becomes:

**Coppersmith threshold.** *If the hint $p \bmod m$ together with the dial readings
pins down the prime in a window of size $m^2$, then $M^* \ge m$.*

Read that again. To be useful, the dials' conductor lcm must be at least as large
as the Coppersmith hint modulus itself, $M^* \gtrsim N^{1/4}$. But the dials with
$M^* \le m$ — indeed those with $M^* \mid m$ — are exactly the ones the attacker
can evaluate for free. A dial family big enough to help would have to read $p$
modulo something of size $N^{1/4}$ that the hint does not contain: it would be, in
information content, *a second Coppersmith hint*. The "free witnesses" are exactly
as expensive as the thing they were supposed to replace.

And the threshold is not a vacuous implication. When the dial conductor $C$ is
coprime to $m$, the single resolution dial of conductor $C$ *does* pin down every
candidate in the window $[0, mC)$, by the Chinese Remainder Theorem. Pinning becomes
possible precisely when the dials reach the missing scale, and not one step sooner.

There is a second, independent tax as well. Kronecker dials take values in
$\{-1, 0, +1\}$, so $K$ of them produce at most $3^K$ distinct vectors (only $2^K$
when the dials never vanish, the generic case for a prime). Pigeonhole: to
separate $C$ candidates you need $K \ge \log_3 C$ dials. With $C \approx N^{1/4}$
candidates that is $K = \Theta(\log N)$ dials — and every one of them must have a
big conductor. The two taxes, arithmetic and information-theoretic, apply
simultaneously.

## The experiment, on real numbers

The general theorems were tested against two concrete instances, chosen to sit on
each side of the divide.

*Regime 1.* Take a modulus of size $N \approx 8.08 \times 10^8$ with hint modulus
$m = 168$, and dials at discriminants $D = -3, 21, 42$, of conductors $12$, $84$,
and $168$. Their lcm is $M^* = 168$, which divides $m = 168$ exactly. The
prediction: zero pinning. And indeed the primes $28393$ and $28729$ are both
$\equiv 1 \pmod{168}$, both plausible secret factors at this scale, and the three
dials read *identically* on them. The dial vector is computable from the hint — and
constant on the candidates. It adds precisely nothing. Quantitatively, on a window
of size $mC$ split into hint classes of $C$ candidates each, all $C$ candidates
survive the dial cut.

*Regime 2.* Take $N \approx 3.4 \times 10^8$ with hint modulus $m = 135$, and the
single dial $\left(\frac{-4}{\cdot}\right)$ of conductor $16$. Here $16 \nmid 135$.
The primes $541$ and $811$ are both $\equiv 1 \pmod{135}$, yet
$\left(\frac{-4}{541}\right) = +1$ while $\left(\frac{-4}{811}\right) = -1$: the
dial separates them. It is informative — and therefore, by the dichotomy,
*not computable from the hint*. An attacker with only $p \bmod 135$ cannot evaluate
it, because that hint does not determine $p \bmod 4$.

The second example is not a numerical accident. For *every* odd hint modulus $m$,
the candidates $1$ and $1 + 2m$ share the hint but sit in different classes mod
$4$, so $\left(\frac{-4}{\cdot}\right)$ separates them. The simplest interesting
dial is never hint-computable against an odd hint. Regime 2 is the rule, not the
exception — and Regime 2 is precisely the regime the attacker cannot enter.

## What the collapse is really about

Notice what the argument never used. It never used quadratic reciprocity. It never
used multiplicativity of the Kronecker symbol, nor the fact that its values are
$\pm 1$, nor anything about class numbers or $L$-functions. It used *one* property:
periodicity. The barrier is a statement about **conductors**, not about characters.

That gives the result an unexpected reach. Any eventually periodic side channel —
a lookup table, a Hamming weight of a residue, a hardware timing artifact keyed to
$p \bmod P$ — obeys the same budget: at most $P/\gcd(P, m)$ values on a hint class,
at most a factor $P/\gcd(P,m)$ of candidate shrinkage, and zero information as soon
as $P \mid m$. The only way out is aperiodicity, and an efficiently computable
aperiodic statistic of a hidden prime is, at present, exactly the kind of object
whose existence would itself constitute a factoring breakthrough.

So the verdict is a clean negative, of the sort that saves other people's time. A
partial key hint is genuinely, irreducibly external information. You can post-process
it, decorate it with characters, feed it to lattices — but you cannot make it larger
than it is. The dials, for all their arithmetic beauty, are locked to the very
residue you already knew; turning them harder does not change what they show.
