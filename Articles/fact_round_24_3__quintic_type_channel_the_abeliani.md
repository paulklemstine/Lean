# The Two-Bit Dial Behind a Quintic

## How much does the way a polynomial factors tell you about a prime?

Take the polynomial $x^5 - 2$. Its roots are the five complex fifth roots of $2$, and over the
rational numbers it is irreducible: no amount of algebra will break it into smaller pieces. But
reduce it modulo a prime $p$ — that is, do the arithmetic in the world of remainders mod $p$ —
and it *can* break apart. Sometimes it splits into five linear factors. Sometimes it stays in one
irreducible lump of degree five. Sometimes you get a linear factor times a quartic, and sometimes
a linear factor times two quadratics.

Four possibilities. Four "shapes", which number theorists call the **splitting type** and write as
a partition of $5$:
$$[1,1,1,1,1], \qquad [5], \qquad [1,4], \qquad [1,2,2].$$

Now here is the question that this article is about. Suppose someone hands you a large prime $p$
but refuses to tell you what it is. They will only tell you the shape — which of the four patterns
$x^5-2$ falls into modulo $p$. **How much have they told you about $p$?**

The honest answer is: a precise number of bits, and the number is exactly $3/2$.

That "exactly" is the whole story. Not $1.4989$, which is what you get if you actually run the
experiment over the first twenty-odd thousand primes. Not "about one and a half". Exactly
three halves of a bit, with a proof, and — more importantly — with a *reason*, a structural law
that says where the missing half-bit went and predicts the answer for the next polynomial before
you compute anything.

---

## The dial and the pointer

Every question of this kind has the same anatomy. There is a hidden quantity you would like to
know, and there is an observation that leaks information about it.

The hidden quantity here is the residue $p \bmod 5$. A prime other than $5$ leaves remainder
$1, 2, 3$ or $4$; by Dirichlet's theorem on primes in arithmetic progressions, each of the four
happens equally often in the long run. So the hidden quantity is a perfectly balanced four-way
choice, worth
$$H(p \bmod 5) = \log_2 4 = 2 \text{ bits}.$$
Call it **the dial**: a two-bit dial with four settings.

The observation is the splitting type $T$ of $x^5 - 2$. Its four outcomes are *not* equally likely.
The Chebotarev density theorem — the great generalisation of Dirichlet's theorem — hands us the
frequencies on a plate:
$$\Pr[\,[1,1,1,1,1]\,] = \tfrac{1}{20}, \quad \Pr[\,[5]\,] = \tfrac{4}{20}, \quad
\Pr[\,[1,4]\,] = \tfrac{10}{20}, \quad \Pr[\,[1,2,2]\,] = \tfrac{5}{20}.$$
A little arithmetic with logarithms turns those frequencies into an entropy:
$$H(T) = \frac{11}{10} + \frac{1}{4}\log_2 5 = 1.68048\ldots \text{ bits}.$$

So the type is worth about $1.68$ bits of surprise, and the dial holds $2$ bits of secret. The
question is how much of the second the first can see. In information-theoretic language we want
the **mutual information** $I(T\,;\,p \bmod 5)$.

And the answer, for $x^5 - 2$, is $3/2$ bits — three quarters of the dial, and not a hair more.

---

## Where the frequencies come from: a group of twenty symmetries

Why $1 : 4 : 10 : 5$? Because behind $x^5 - 2$ stands a group.

The five roots of $x^5 - 2$ are $\sqrt[5]{2}\,\zeta^j$ for $j = 0,1,2,3,4$, where $\zeta$ is a
primitive fifth root of unity. Every symmetry of this root system — every way of permuting the
roots that respects all algebraic relations among them — is a map that sends the label $j$ to
$aj + b$ for some multiplier $a \in \{1,2,3,4\}$ and some shift $b \in \{0,1,2,3,4\}$, with the
arithmetic done modulo $5$. These are the **affine transformations of the line over the field with
five elements**, and there are $4 \times 5 = 20$ of them. The resulting group is called
$\mathrm{AGL}(1,5)$, or $F_{20}$: the Frobenius group of order twenty. It is *not* commutative —
shifting and then stretching is not the same as stretching and then shifting.

Chebotarev's theorem says: pick a large prime at random, and the symmetry it induces (its
*Frobenius element*) is uniformly distributed over these twenty transformations. Everything else
follows by counting.

**Which transformation gives which shape?** Count the fixed points and cycles of $j \mapsto aj+b$
acting on the five labels:

| multiplier $a$ | shift $b$ | cycle structure | splitting type | how many |
|---|---|---|---|---|
| $1$ | $0$ | identity | $[1,1,1,1,1]$ | $1$ |
| $1$ | $\ne 0$ | one $5$-cycle | $[5]$ | $4$ |
| $2$ or $3$ (order $4$) | any | fixed point $+$ $4$-cycle | $[1,4]$ | $10$ |
| $4$ (order $2$) | any | fixed point $+$ two $2$-cycles | $[1,2,2]$ | $5$ |

There are the frequencies $1 : 4 : 10 : 5$.

**And where is the dial in this picture?** It is the multiplier $a$, and nothing else. The
multiplier is exactly the residue $p \bmod 5$, read through the "discrete logarithm": $2$ is a
generator of the multiplicative group $\{1,2,3,4\}$, and writing $a = 2^e$ turns the four residues
into a four-setting dial labelled $e = 0, 1, 2, 3$. In group-theoretic terms, discarding the shift
$b$ and keeping the multiplier $a$ is precisely the **abelianization** of $F_{20}$: the largest
commutative quotient, here the cyclic group $C_4$. That quotient is not an abstraction — it *is*
the Galois group of the fifth cyclotomic field $\mathbb{Q}(\zeta_5)$, whose arithmetic is governed
by $p \bmod 5$.

---

## The half-bit that gets lost

Now put the table and the dial side by side, and the answer becomes visible without a single
logarithm.

Read down the "splitting type" column and ask, for each shape, *which dial settings produce it?*

- $[1,1,1,1,1]$ occurs only for $e = 0$. One setting.
- $[5]$ occurs only for $e = 0$. One setting.
- $[1,2,2]$ occurs only for $e = 2$. One setting.
- $[1,4]$ occurs for $e = 1$ **and** $e = 3$. **Two settings.**

Three of the four shapes pin the dial completely. The fourth, $[1,4]$, is blind to the difference
between multiplier $2$ and multiplier $3$ — because both have order four, and only the order of
the multiplier shows up in the cycle structure. That shape occurs half the time, and when it
occurs it leaves you with a perfectly balanced two-way ambiguity: one bit of residual doubt,
suffered with probability $1/2$.

$$\text{loss} = \tfrac12 \times \log_2 2 = \tfrac12 \text{ bit}, \qquad
I = 2 - \tfrac12 = \tfrac{3}{2}.$$

That is the whole computation. Note what did *not* happen: no entropies were evaluated. The
quantity $\log_2 5$, an irrational number that infests both $H(T) = 1.68048\ldots$ and the
conditional entropy $H(T \mid p \bmod 5) = \tfrac14\log_2 5 - \tfrac25 = 0.1805\ldots$, cancels
identically between them. The transmitted information is a clean rational number, and it is clean
for a structural reason.

That reason deserves a name. Call it the **merged-coset law**:

> **The Merged-Coset Law.** Suppose a hidden dial $D$ and an observation $T$ are read off from the
> same uniformly random source, and suppose that inside each fibre of $T$ — each set of sources
> giving the same observation — the dial settings that occur all occur equally often. Let $k(t)$
> be the number of distinct dial settings compatible with the observation $t$. Then
> $$H(D) - I(T;D) \;=\; \sum_t \Pr[T = t]\,\log_2 k(t).$$

In words: *the information you fail to extract is exactly the entropy of the settings your
observation cannot tell apart.* Nothing about the group enters, only the pattern of merging.

And it has a converse, which turns the law from an accounting identity into a classification:

> **The Pinning Criterion.** Under the same hypotheses, the observation recovers the dial
> completely, $I(T;D) = H(D)$, **if and only if** no observed value is compatible with two
> different dial settings.

Every commutative (abelian) Galois situation is pinned in this sense — there the splitting type
*is* a function of the residue, and the channel is lossless. For $x^5-2$ the group is not
commutative, and exactly one shape does the merging. The half-bit is not an accident; it is the
group's non-commutativity, measured.

---

## The experiment, and the error the experiment caught

Laws about primes deserve to be checked against primes. Running $x^5-2$ against the first
$\approx 23{,}000$ primes gives measured type frequencies within $2\%$ of the predicted
$1:4:10:5$, and a measured information of
$$I_{\text{measured}} = 1.4989 \quad \text{against the predicted } 1.5000.$$

More interesting is the **semiprime** layer. Suppose the observer sees not one prime but a product
$N = pq$ of two unknown primes, and is shown the pair of splitting types $\{T(p), T(q)\}$ together
with being asked about $N \bmod 5$. Since residues multiply, the dial of the product is the *sum*
of the two hidden dial settings modulo $4$. Two half-informative observations now have to
cooperate to pin one dial. The answer is again exactly rational:
$$I\big(\{T(p),T(q)\}\,;\,N \bmod 5\big) = \frac{5}{4},$$
measured at $1.2462$ over $400{,}000$ simulated semiprimes. And here is a genuinely striking
coincidence: $5/4$ is *verbatim* the value of the corresponding pair channel for the cyclotomic
field $\mathbb{Q}(\zeta_5)$ itself — the abelian world the dial lives in. The non-commutative
quintic reads its own abelianization's pair channel exactly.

Two more facts about that layer. First, telling the observer *which* of the two factors carried
which type is worth precisely nothing: the unordered pair transmits the same $5/4$. Second, if one
restricts attention to the shape $[1,2,2]$ — which occurs exactly when $p \equiv 4 \pmod 5$ — and
merely counts how many of the two factors exhibit it, that count still transmits
$\tfrac{19}{8} - \tfrac{21}{16}\log_2 3 = 0.294737\ldots$ bits, measured at $0.2915$; an
order-four fork living on a non-commutative field.

Now the cautionary tale. The first run of this computation assigned the two order-four multipliers
to the wrong dial settings — a bookkeeping slip, swapping which of $e=1,3$ carried which label
relative to the setting $e=2$ that hosts $[1,2,2]$. **At the single-prime level the slip is
completely invisible.** Both mislabelled classes still share the shape $[1,4]$, so the type
frequencies, the entropy $H(T)$, and the transmitted $3/2$ are all bit-for-bit unchanged. No
consistency check at the prime level can see it.

The pair channel sees it instantly. Under the swapped labelling the pair law becomes $9/8$, not
$5/4$ — a discrepancy of an eighth of a bit, which the simulation, sitting at $1.2462$, flatly
contradicted. The lesson generalises far beyond this polynomial: *a channel that merges its
symbols hides labelling errors, and the way to expose them is to look at the channel's product.*
Pairs see the group law; single draws see only the partition.

---

## Climbing the ladder: degree seven, and a prediction

Once the mechanism is this transparent, the next rung is irresistible. Replace $5$ by $7$: take a
generic radical septic $x^7 - a$, whose symmetry group is the affine group
$\mathrm{AGL}(1,7)$ of order $42$, with abelianization the cyclic group $C_6$ — the residue
$p \bmod 7$, a dial worth $\log_2 6 = 2.585$ bits.

The same fixed-point count gives five shapes instead of four. Writing $d$ for the multiplicative
order of the multiplier $a$:

| condition | splitting type | how many of the $42$ |
|---|---|---|
| $a=1, b=0$ | $[1,1,1,1,1,1,1]$ | $1$ |
| $a=1, b\ne 0$ | $[7]$ | $6$ |
| $d = 2$ | $[1,2,2,2]$ | $7$ |
| $d = 3$ | $[1,3,3]$ | $14$ |
| $d = 6$ | $[1,6]$ | $14$ |

The splitting entropy is $H(T) = \tfrac{4}{21} + \tfrac67\log_2 3 + \tfrac16 \log_2 7 = 2.0169\ldots$
bits, but again we never need it. Two shapes now merge cosets — $[1,3,3]$ fuses the two settings
whose multiplier has order $3$, and $[1,6]$ fuses the two of order $6$ — each with probability
$1/3$. The merged-coset law gives the loss immediately as $\tfrac13 + \tfrac13 = \tfrac23$, so
$$I(p \bmod 7\,;\,T) = \log_2 6 - \frac{2}{3} = \frac{1}{3} + \log_2 3 = 1.9183\ldots$$
Once more the transcendental $\log_2 7$ cancels; once more the answer is as clean as the dial
allows.

Comparing the rungs is instructive, and slightly counterintuitive. Degree seven transmits strictly
more information than degree five — $1.918$ against $1.500$ — yet it wastes a strictly *larger
fraction* of its dial: a quarter is lost at degree five, and $\tfrac{2/3}{\log_2 6} = 25.8\%$ at
degree seven. Merging grows faster than the dial does.

Why? Because the merging is governed by a purely arithmetic object: the divisors of $q-1$. Two
multipliers give the same cycle type exactly when they have the same order, and the number of
elements of order $d$ in a cyclic group of size $q-1$ is Euler's totient $\varphi(d)$. That yields
a closed formula for the loss of the affine group $\mathrm{AGL}(1,q)$:
$$\boxed{\;\text{loss}(q) \;=\; \sum_{\substack{d \,\mid\, q-1 \\ d > 1}} \frac{\varphi(d)}{q-1}\,\log_2 \varphi(d)\;}$$
and hence $I = \log_2(q-1) - \text{loss}(q)$.

Check it. For $q = 5$ the divisors above $1$ are $2$ and $4$, with $\varphi(2)=1$ (contributing
nothing, since $\log_2 1 = 0$) and $\varphi(4) = 2$, contributing $\tfrac{2}{4}\cdot 1 = \tfrac12$.
That is the half-bit. For $q = 7$: divisors $2, 3, 6$ with totients $1, 2, 2$, giving
$0 + \tfrac{2}{6} + \tfrac{2}{6} = \tfrac23$. That is the two-thirds. And for $q = 11$, where the
divisors $2, 5, 10$ have totients $1, 4, 4$, the formula predicts
$$\text{loss}(11) = \tfrac{4}{10}\cdot 2 + \tfrac{4}{10}\cdot 2 = \tfrac{8}{5},$$
so $I(p \bmod 11\,;\,T) = \log_2 10 - \tfrac85 = \log_2 5 - \tfrac35$. That is a falsifiable
prediction about a degree-eleven polynomial, derived from nothing but a divisor lattice.

---

## What the law means

Strip away the number theory and the statement is about *quotients and their shadows*.

A non-commutative group has a largest commutative shadow, its abelianization. In arithmetic, that
shadow is the part of the field visible to a simple congruence condition on $p$ — the part
governed by cyclotomy, by Gauss and Kummer, rather than by anything deeper. A splitting type is a
crude but cheap observation: you factor a polynomial modulo $p$ and write down the degrees. The
question of how much a crude observation sees of the commutative shadow could have had an ugly
answer, some transcendental combination of logarithms depending delicately on the field.

It does not. The answer is always
$$I(p \bmod m\,;\,T) \;=\; H(\text{dial}) \;-\; \sum_{t} \Pr[T=t]\,\log_2 k(t),$$
a difference of a dial entropy and a small, explicitly combinatorial correction. Across degrees
two through five and abelianizations $C_2$, $C_3$, $C_4$, $C_2 \times C_2$ and $C_n$, the same
identity holds verbatim, and the gap between what the type sees and what the dial holds is
*always* exactly the entropy of the classes the type cannot distinguish. The affine ladder extends
it to degrees seven and beyond in closed form.

There is a control experiment that makes the point sharply. Take the degree-five *commutative*
field, the real subfield of $\mathbb{Q}(\zeta_{11})$, whose Galois group is the cyclic $C_5$. Its
dial is the full residue $p \bmod 11$, worth $\log_2 10 = 3.32$ bits, and its splitting entropy is
only $\log_2 5 - \tfrac85 = 0.7219\ldots$ bits, measured at $0.7198$ over the same prime range.
Here the channel is pinned — everything the type knows gets through — but the type knows so
little that $2.6$ bits of the dial are simply invisible. The non-commutative $F_{20}$, by
contrast, loses only a half-bit and transmits more than twice as much. Non-commutativity is not
the enemy of information; *merging* is.

The final image is worth keeping. A polynomial modulo a prime is a very coarse instrument: it
returns a partition of $5$, one of four words. Yet it turns a two-bit dial with three-quarters
efficiency, and the exact size of the slippage is written in the divisors of $q-1$ — the same
divisor lattice that has governed cyclotomy since Gauss. The quintic case is where the pattern
first becomes forced rather than observed, and it is the first place where the accountancy is
delicate enough that getting the bookkeeping wrong produces a number — $9/8$ — that looks just as
plausible as the truth until you ask it about a product of two primes.
