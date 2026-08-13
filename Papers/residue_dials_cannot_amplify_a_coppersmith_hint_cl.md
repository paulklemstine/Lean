# Can a Secret Amplify Itself?

### A guided tour of conductor budgets, residue dials, and a barrier that fits in three lines

---

## 1. The situation: a hint that is *almost* enough

You are handed a public number $N = pq$, the product of two secret primes, and one extra
gift: a **partial-key hint**, the residue of the smaller prime,
$$
p \equiv r \pmod m .
$$

There is a famous threshold here. [Coppersmith's method](https://en.wikipedia.org/wiki/Coppersmith_method)
turns a hint with $m \gtrsim N^{1/4}$ — roughly a quarter of the bits of $p$ — into a full
factorization in polynomial time. Just below that threshold the lattice fails, and all you
have is a **candidate set**: every integer in the search window congruent to $r$ modulo $m$.
With a window of size $N^{1/2}$ that is about $N^{1/4}$ candidates. Far too many.

So here is the temptation that this page is about. Quadratic residues are free. For any
discriminant $D$, the [Kronecker symbol](https://en.wikipedia.org/wiki/Kronecker_symbol)
$\left(\frac{D}{p}\right) \in \{-1, 0, +1\}$ is an arithmetic "dial" attached to the secret
prime. Read $K$ of them, treat each as a coin flip, and the candidate set should shrink by
$2^K$. Take $K \approx \log_2 N^{1/4}$ dials and the prime pops out. Coppersmith's threshold
would fall.

**It cannot work.** Not "does not seem to" — *cannot*, for every choice of discriminants,
every number of dials, and every post-processing scheme layered on top. Let us find out why,
by playing with it.

---

## 2. First, play

Before any definitions, get your hands on the object. Pick a hint modulus, toggle
discriminants on and off, and watch what the dials do to the candidate set.

Two things to try immediately:

- Load the preset **Regime 1 · m = 168** (dials at $D = -3, 21, 42$). Count the columns.
- Load the preset **Regime 2 · m = 135** (the single dial $(-4\mid\cdot)$). Count them again.

{{interactive_demo:0}}

Did you notice? In the first configuration the candidates fall into **one** group: the dials
read the same value on every candidate in the class. In the second they split — but hold that
thought, because the split is going to turn out to be unusable.

---

## 3. The only thing a dial really is

Strip the Kronecker symbol of its glamour and one property remains: **periodicity**.

> **Definition (residue dial).** A *residue dial* is an integer-valued function $\chi$ of the
> candidate together with an integer $c \ge 1$, the **conductor**, such that
> $\chi(n + c) = \chi(n)$ for all $n$.

The Kronecker symbol $\left(\frac{D}{\cdot}\right)$ is a dial of conductor $4|D|$. So is "the
third bit of $p \bmod 1000$". So is any table lookup indexed by a residue. No multiplicativity
is assumed, no reciprocity, not even that the values are $\pm 1$.

For a family of $K$ dials, one number rules everything:
$$
M^* \;=\; \operatorname{lcm}(c_1, \dots, c_K) \qquad \text{(the conductor lcm)} .
$$

<details>
<summary><b>Click to reveal: why the whole family only sees $p \bmod M^*$</b></summary>

Iterating periodicity gives $\chi(n + kc) = \chi(n)$ for every $k$. So if $c \mid M$, writing
$n = (n \bmod M) + (M/c)\lfloor n/M\rfloor \cdot c$ shows $\chi(n) = \chi(n \bmod M)$. Each
$c_i$ divides $M^*$, so every reading — and hence the whole vector
$V(p) = (\chi_1(p), \dots, \chi_K(p))$ — is a function of $p \bmod M^*$ and of nothing else.
</details>

---

## 4. The master bound, in one picture

Now put the dials next to the hint. The hint is a function of $p \bmod m$. The dials are a
function of $p \bmod M^*$. What can the two see *together*?

Slide the two moduli below and watch the reachable pairs $(p \bmod m,\; p \bmod M^*)$:

{{interactive_demo:1}}

A single row of that lattice is one hint class — everything the attacker cannot separate using
the hint alone. Count the reachable cells in the row. There are exactly
$M^*/\gcd(M^*, m)$ of them, and that count is the whole story.

> **Theorem (Master bound).** Let a dial family have conductor lcm $M^*$, and let $\Omega$ be
> any set of candidates all congruent modulo $m$. Then the dial vector takes at most
> $$ \frac{M^*}{\gcd(M^*, m)} $$
> distinct values on $\Omega$.

<details>
<summary><b>Click to reveal the proof (it really is three lines)</b></summary>

Put $g = \gcd(M^*, m)$. Every candidate in $\Omega$ shares a residue mod $m$, hence mod $g$.
The dial vector depends only on the residue mod $M^*$, and among the $M^*$ classes mod $M^*$
exactly $M^*/g$ are compatible with a prescribed class mod $g$ (count the arithmetic
progression). So the vector can reach at most $M^*/g$ values. $\blacksquare$
</details>

Call $B = M^*/\gcd(M^*, m)$ the **amplification budget**. Pigeonholing the candidates into
their readings converts it into the statement an attacker cares about:

> **Theorem (No amplification beyond the budget).** Some reading is shared by at least a
> $1/B$ fraction of the candidates. Reading the dials cannot shrink a candidate set inside a
> hint class by more than the factor $B$.

And the budget is not a lazy over-estimate: for *every* pair $(M, m)$ the "resolution dial"
$p \mapsto p \bmod M$ realizes exactly $M/\gcd(M,m)$ readings on a suitable candidate set. No
sharper universal bound exists.

---

## 5. The trap: two regimes, both useless

Here is where the argument closes on itself. Split on whether $M^*$ divides $m$.

**Regime 1 — $M^* \mid m$.** The budget is $1$. The dial vector is *constant* on the whole
candidate set. Filtering candidates by the true reading removes not one of them. Equivalently:
the dial vector is a function of $p \bmod m$, so the attacker can compute it *from the hint
alone* — and data you computed from what you already knew tells you nothing new.

**Regime 2 — $M^* \nmid m$.** Now the dials really can separate two candidates of the same hint
class. But by definition that means the dial vector is *not* a function of $p \bmod m$: the
attacker cannot evaluate it, because doing so requires $p$ modulo something the hint does not
determine.

> **Computable $\Rightarrow$ useless. Useful $\Rightarrow$ incomputable.** There is no third
> regime.

<details>
<summary><b>Click to reveal: the strongest form — zero information, even after post-processing</b></summary>

Say a reading $T$ carries **zero information** about a secret $S$ on $\Omega$ if for all
values $t, s$
$$
\#\{p \in \Omega: T(p)=t,\, S(p)=s\}\cdot\#\Omega \;=\; \#\{T = t\}\cdot\#\{S = s\},
$$
i.e. $T$ and $S$ are exactly independent under the uniform counting measure — a finitary
statement, no asymptotics, no distributional assumptions.

A constant reading trivially satisfies it, and zero information survives composition with any
function $h$ (fibres of $h \circ T$ are unions of fibres of $T$). Hence in Regime 1, for
*every* secret $S$ and *every* post-processing $h$ — lattice reduction, statistics, a learned
decoder, anything — both $V$ and $h \circ V$ carry zero information about $S$.

The same argument applies verbatim to any statistic of the form $g(N,\, p \bmod m)$: whatever
you can compute from the public modulus and the hint is exactly independent of every secret.
**A hint cannot amplify itself.**
</details>

---

## 6. How expensive would a *useful* dial be?

The dichotomy is qualitative. Now the number. Combine the attacker's two pieces of knowledge
into the pair (hint, dial vector). It resolves $p$ modulo $\operatorname{lcm}(m, M^*)$ — and
not one step further, since any two candidates congruent mod that number produce identical
hints *and* identical readings.

> **Theorem (Pinning window bound).** If the pair (hint, dials) determines the candidate
> uniquely inside a window $[0, X)$, then
> $$ X \;\le\; \operatorname{lcm}(m, M^*) \;\le\; m\,M^*, \qquad\text{so}\qquad M^* \ge X/m. $$

*Proof:* if $X$ exceeded $L = \operatorname{lcm}(m, M^*)$ then $0$ and $L$ would both lie in
the window and be indistinguishable. $\blacksquare$

Now instantiate: the prime satisfies $p < N^{1/2}$ and the hint has $m \approx N^{1/4}$, so
the window is the *square* of the hint, $X = m^2$.

> **Theorem (Coppersmith threshold).** Pinning the prime in a window of size $m^2$ forces
> $$ M^* \;\ge\; m . $$

Read that slowly. A dial family big enough to help must have conductor lcm of hint size,
$M^* \gtrsim N^{1/4}$. But the families the attacker can *evaluate* are exactly those with
$M^* \mid m$ — all of them information-free. A useful dial family would be, in information
content, **a second Coppersmith hint**. The free lunch costs exactly as much as the meal it
was supposed to replace.

And the threshold is exactly attained: when $\gcd(m, C) = 1$, the single resolution dial of
conductor $C$ *does* pin every candidate in $[0, mC)$, by the Chinese Remainder Theorem.
Pinning becomes possible precisely when the dials reach the missing scale, and not a step
sooner.

{{algorithm:2}}

---

## 7. Two taxes, not one

There is a second, independent obstruction. Kronecker readings live in $\{-1, 0, 1\}$, so $K$
dials produce at most $3^K$ distinct vectors — only $2^K$ when the readings never vanish, the
generic case for a prime. Pigeonhole again: separating $C$ candidates needs $K \ge \log_3 C$
dials. With $C \approx N^{1/4}$ that is $K = \Theta(\log N)$ dials, *each* of which must carry
a large conductor. Both taxes apply at once.

---

## 8. Run the numbers yourself

The theory was tested on two instances chosen to sit on either side of the divide.

**Regime 1.** $N \approx 8.08 \times 10^8$, hint modulus $m = 168$, dials at
$D = -3, 21, 42$ of conductors $12, 84, 168$; their lcm is $168$, which divides $m$. The
primes $28393$ and $28729$ are both $\equiv 1 \pmod{168}$ and receive **identical** readings.

**Regime 2.** $N \approx 3.4 \times 10^8$, $m = 135$, the single dial
$\left(\frac{-4}{\cdot}\right)$ of conductor $16$; here $16 \nmid 135$. The primes $541$ and
$811$ are both $\equiv 1 \pmod{135}$, yet $\left(\frac{-4}{541}\right) = +1$ and
$\left(\frac{-4}{811}\right) = -1$ — separated, and therefore not hint-computable.

The second is not a numerical accident: for *every* odd $m$, the candidates $1$ and $1 + 2m$
share the hint but differ mod $4$, so $\left(\frac{-4}{\cdot}\right)$ always separates them.

Here is the full verification suite — every claim on this page, checked by exhaustive
computation with hard assertions:

{{demo:0}}

And here is the attack itself, simulated end to end on a real semiprime with an honest
attacker and an oracle attacker side by side:

{{demo:1}}

---

## 9. Seeing the barrier at a glance

Two pictures summarize everything. The first plots the amplification budget over all pairs
$(M^*, m)$ and outlines the configurations an attacker can actually evaluate; brightness
(useful) and outline (available) never coincide. The second shows the candidate fibres in the
two experimental regimes.

{{visualization:0}}

{{algorithm:0}}

{{visualization:1}}

{{algorithm:1}}

---

## 10. What this really says

Notice what the argument never used: no quadratic reciprocity, no multiplicativity, no bound
on the number of dials, no assumption that readings are $\pm 1$, no asymptotics. **Only
periodicity.**

So the barrier is a statement about *conductors*, not about characters, and it transfers
verbatim to any periodic side channel: a lookup table, a Hamming weight of $p \bmod P$, a
timing artefact keyed to a residue. All obey the budget $P/\gcd(P, m)$, and all become exactly
information-free as soon as $P \mid m$.

The only escape would be an *aperiodic* statistic of the hidden prime, efficiently computable
from public data and genuinely dependent on $p$ beyond its hint — which is uncomfortably close
to a definition of a factoring oracle.

**The verdict:** a partial-key hint is genuinely, irreducibly external information. You can
post-process it, decorate it with characters, feed it to lattices — but you cannot make it
larger than it is. The dials, for all their arithmetic beauty, are locked to the very residue
you already knew.
