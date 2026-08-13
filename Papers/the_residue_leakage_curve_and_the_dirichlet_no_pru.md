# The Fingerprint That Identifies Everything and Reveals Nothing

### A guided tour of the residue-leakage curve and the no-pruning theorem

---

## 0. The setting, in one paragraph

You are handed a large number $N_0$, known to be the product of two primes,
$N_0 = p\cdot q$, and asked to find $p$. You cannot factor $N_0$ — that is the whole
problem — but you *can* interrogate it cheaply. For a small prime $a$, the **Jacobi
symbol** $\left(\tfrac{a}{N_0}\right) \in \{+1,-1\}$ is computable in
$\mathrm{poly}(\log N_0)$ time by a reciprocity-driven Euclidean algorithm, with no
factorization needed. Ask this question for the first $K$ primes and you get a
$K$-bit **fingerprint**

$$F(N_0) \;=\; \left[\left(\tfrac{2}{N_0}\right), \left(\tfrac{3}{N_0}\right), \left(\tfrac{5}{N_0}\right), \dots\right] \in \{\pm1\}^K.$$

Here is the puzzle this page resolves. With $K = 20$ probes, the fingerprint separates
$300$ random cryptographic-shape semiprimes without a single collision. It looks like a
perfect identifier. **Does it help you factor?**

Spoiler: *no*. Not "barely". Exactly, provably, zero.

<details>
<summary>New to Jacobi symbols? Click for a two-minute primer</summary>

For an odd prime $a$ and an integer $x$ not divisible by $a$, the **Legendre symbol**
$\left(\tfrac{x}{a}\right)$ is $+1$ if $x$ is a square modulo $a$ and $-1$ otherwise. The
**Jacobi symbol** $\left(\tfrac{x}{n}\right)$ for odd $n = a_1 a_2 \cdots a_r$ (with
repetition) is defined as the product $\prod_i \left(\tfrac{x}{a_i}\right)$.

The magic is that although the definition mentions the factorization of $n$, the *value*
can be computed without it, by the law of
[quadratic reciprocity](https://en.wikipedia.org/wiki/Quadratic_reciprocity):
$\left(\tfrac{x}{n}\right)\left(\tfrac{n}{x}\right) = (-1)^{\frac{x-1}{2}\frac{n-1}{2}}$,
which lets you swap the two arguments and reduce, exactly like the Euclidean algorithm
for gcd. The supplementary law $\left(\tfrac{2}{n}\right) = (-1)^{(n^2-1)/8}$ handles the
factors of two. That is the whole algorithm, and it is why the fingerprint is *cheap*.

One warning that matters later: for composite $n$, $\left(\tfrac{x}{n}\right) = +1$ does
**not** mean $x$ is a square mod $n$. The symbol is a character, not a squareness test.
</details>

---

## 1. Play first: can you exclude a candidate?

Before any theory, try to break the claim yourself. Below is a live laboratory. Pick the
target $N_0 = 1591$, pick any candidate prime $p$ you like — $13$, $101$, $104729$ — and
ask for a compensator. The widget will find a prime $q$ such that $p\cdot q$ has *exactly*
the fingerprint of $N_0$.

Try to find a candidate that has no compensator. You will not succeed, and by the end of
this page you will know why with certainty.

{{interactive_demo:0}}

Three things to notice while you play.

1. **Every candidate works.** No matter how large or strange your $p$, a compensator turns
   up almost immediately.
2. **The compensator always lands in one residue class.** The widget reports
   $q \equiv N_0 \cdot p \pmod{4\prod A}$ every time. That is not a coincidence — it is the
   theorem.
3. **The grid at the bottom is a permutation matrix.** One gold cell per row, always.

---

## 2. Why it happens: multiplicativity is a trap

The reason one *expects* a leak is that the Jacobi symbol is multiplicative in its lower
argument:

$$\left(\tfrac{a}{mn}\right) = \left(\tfrac{a}{m}\right)\left(\tfrac{a}{n}\right),
\qquad\text{so}\qquad F(pq) = F(p)\odot F(q)$$

entrywise. So observing $F(N_0)$ *does* tell you something about the pair $(p,q)$: for
each probe you learn the **product** $\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$.

And there the leak stops. What you learn is *symmetric* in the two factors. Knowing that
$x\cdot y = +1$ for two unknown signs tells you nothing about $x$ alone.

Turning that intuition into a theorem needs one more classical fact and one classical
theorem.

> **Periodicity.** Each symbol $\left(\tfrac{a}{\cdot}\right)$ depends only on the residue
> class of its argument modulo $4a$. Hence the whole fingerprint depends only on the class
> modulo the **conductor** $M = 4\prod_{a\in A} a$.

> **Dirichlet's theorem (1837).** Every residue class $r$ modulo $M$ with $\gcd(r,M)=1$
> contains infinitely many primes.

Now the argument writes itself.

**Theorem (Dirichlet No-Pruning).** *Let $N_0$ be odd and coprime to the probes and let
$p$ be any odd prime outside the probe set. Then there are infinitely many primes $q$ with
$F(pq) = F(N_0)$.*

<details>
<summary>Click to reveal the complete proof — it is four lines</summary>

We want $\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)$
for every probe $a$. Since $\left(\tfrac{a}{p}\right) = \pm1$ squares to $1$, this is
equivalent to
$$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)
= \left(\tfrac{a}{N_0\, p}\right).$$
So $q$ must merely share the fingerprint of the **known** number $N_0 p$. By periodicity,
any prime $q \equiv N_0 p \pmod M$ does that. And $N_0 p$ is a unit modulo $M$, because it
is odd and coprime to every probe. Dirichlet supplies infinitely many primes in that
class. $\blacksquare$

Notice the clean split: the compensating-class statement ("every prime in the class
$N_0p$ works") is a **pure congruence fact with no analysis in it**, and Dirichlet is
invoked exactly once. That split is what makes an *effective* version possible — see §6.
</details>

The algorithm implementing this is the engine behind the widget you just used.

{{algorithm:1}}

<details>
<summary>Click to see the underlying symbol computation</summary>

Everything rests on being able to evaluate $\left(\tfrac{a}{N}\right)$ without factoring
$N$. Here is that routine, with the reciprocity swap and the supplementary law made
explicit.

{{algorithm:0}}
</details>

---

## 3. The other half: every pattern occurs

No-pruning says the channel cannot *remove* a candidate. The complementary theorem says it
cannot *pin down* anything either.

**Theorem (Pattern surjectivity).** *For every sign vector $\varepsilon\in\{\pm1\}^K$
there are infinitely many primes $q$ with $F(q) = \varepsilon$. The range of the
fingerprint on primes is exactly $\{\pm1\}^K$, of cardinality $2^K$.*

This one is genuinely constructive, and the construction is a small cross-domain
symphony: the [Chinese remainder theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem),
[quadratic reciprocity](https://en.wikipedia.org/wiki/Quadratic_reciprocity), the
existence of non-squares in a finite field, and Dirichlet's theorem — four classical
results, one construction.

<details>
<summary>Click to reveal the construction</summary>

*Stage 1 — build a modulus with the prescribed pattern.* The moduli $8$ and the odd probes
are pairwise coprime, so we may prescribe residues simultaneously:

* modulo $8$: residue $1$ if we want $\left(\tfrac{2}{\cdot}\right) = +1$, residue $5$ if
  we want $-1$ (the supplementary law reads the symbol at $2$ straight off the class mod $8$);
* modulo an odd probe $a$: residue $1$ if $\varepsilon(a) = +1$, and a quadratic
  nonresidue mod $a$ if $\varepsilon(a) = -1$ (one always exists — exactly half the
  nonzero classes of a finite field of odd order are non-squares).

Any solution $m$ has $m \equiv 1 \pmod 4$, so quadratic reciprocity applies in its
friendly form: $\left(\tfrac{a}{m}\right) = \left(\tfrac{m}{a}\right)$, a Legendre symbol
determined by $m \bmod a$, which we prescribed. So $F(m) = \varepsilon$ exactly.

*Stage 2 — upgrade to a prime.* The fingerprint depends only on the class of $m$ modulo
$M$, and $m$ is a unit there, so Dirichlet gives infinitely many primes with the same
fingerprint. $\blacksquare$
</details>

{{algorithm:2}}

The immediate consequence is the failure of **individual pinning**: for any probe $a_0$
there are consistent factorizations $p_1q_1$ and $p_2q_2$ of the *same* observed
fingerprint with $\left(\tfrac{a_0}{p_1}\right)=+1$ and $\left(\tfrac{a_0}{p_2}\right)=-1$.
Not one bit of the factor's own fingerprint is determined.

---

## 4. The exact shape of the leak

We can now say precisely — not approximately — what the channel knows.

**Theorem (Exact consistency criterion).** *For primes $p,q$ outside the probe set,*
$$F(pq) = F(N_0) \iff \left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)\ \text{ for every probe } a.$$

It is an *if and only if*: the single symmetric relation **is** consistency. Nothing else
is constrained. Package this geometrically. Let

$$\Phi(N_0) = \bigl\{(F(p),F(q)) : p,q \text{ prime},\ F(pq) = F(N_0)\bigr\}
\subseteq \{\pm1\}^K\times\{\pm1\}^K$$

be the **factorization fibre**. The criterion says $\Phi(N_0)$ is the graph of the
translation $u \mapsto F(N_0)\odot u$ — a coset of the anti-diagonal
$\Delta^- = \{(w,w)\}$. Three consequences, and together they are the whole verdict:

| statement | meaning |
|---|---|
| $\Delta^-$ acts **simply transitively** on $\Phi(N_0)$ | the fibre is a *trivial torsor*: no monodromy, no distinguished point, nothing to exploit |
| $\mathrm{pr}_1(\Phi(N_0)) = \{\pm1\}^K$ | no pruning, in geometric form |
| $|\Phi(N_0)| = 2^K$ | the $K$ bits of $F(p)$ remain entirely free |

Here is what that looks like as a picture. Rows index the pattern of $F(p)$, columns that
of $F(q)$; a mark means the pair is consistent. It is always a permutation matrix — one
mark per row, no more, no fewer.

{{visualization:1}}

<details>
<summary>Click to reveal why simple transitivity is the right way to say "no structure"</summary>

A *torsor* under a group $G$ is a set on which $G$ acts simply transitively — a "group
that has forgotten its identity element". It looks exactly like $G$, but with no
distinguished point.

That is the sharpest possible way to say the channel is useless. If the fibre had a
distinguished point, or if the connecting element between two consistent pairs were ever
non-unique, there would be *some* structure an algorithm could try to exploit. There is
none: pick any consistent pair, and every other consistent pair is obtained by flipping a
sign vector $w$ simultaneously in both coordinates, with $w$ uniquely determined. The
fibre is a featureless copy of $\{\pm1\}^K$.
</details>

You can build the entire fibre yourself from explicit primes and verify all four
structural facts numerically:

{{demo:1}}

---

## 5. The leakage ledger

Two numbers summarise everything.

* **Bits about $N$:** exactly $K$. The fingerprint takes all $2^K$ values, and every one
  is attained by infinitely many primes.
* **Bits about the factorization:** exactly $0$. Conditioned on the observation, all
  $2^K$ patterns of $F(p)$ remain available.

Plotted against $K$, the two curves coincide — and that coincidence is the punchline.

{{visualization:0}}

<details>
<summary>Click to reveal: so why did 300 semiprimes give 300 distinct fingerprints?</summary>

Because $300 \ll 2^{20}$. That is the
[birthday bound](https://en.wikipedia.org/wiki/Birthday_problem) doing nothing surprising.

In fact the fingerprint is provably far from injective. It is a **square-class
invariant**: $F(m s^2) = F(m)$ for any $s$ coprime to the probes, and it is periodic
modulo the conductor. So it factors through a group of order at most $2^{K+1}$ and
collides infinitely often. Concretely, with $A = \{2,3,5,7,11\}$ the prime $79$ and the
semiprime $1591 = 37\cdot 43$ share the fingerprint $[+,-,+,-,+]$ although they are not
even congruent modulo the conductor $9240$.

The lesson: *discriminative power on a finite sample is not injectivity, and injectivity
would not be pruning power anyway.*
</details>

---

## 6. Where the theorem stops — and how effective it is

Every hypothesis earns its keep, and the exception is instructive.

**Sharp boundary.** If a probe prime $a$ actually **divides** $N_0$, the fingerprint prunes
*completely*: the entry at $a$ becomes $0$ rather than $\pm1$ — visible directly in the
data — and then for any candidate $p \neq a$ the only possible partner is $q = a$. Total
pruning. But this is exactly the case where trial division by $a$ has already found the
factor. *The only pruning the residue channel can ever achieve is the discovery of a
factor so small you did not need the channel to find it.* Try it in the laboratory above:
set $N_0 = 3027 = 3\cdot 1009$ and watch a zero appear.

**Effectivity.** Because the compensating-class statement is a pure congruence fact, any
effective bound $B$ for the least prime in a coprime class modulo $M = 4\prod A$ is
inherited verbatim by the compensator. [Linnik's theorem](https://en.wikipedia.org/wiki/Linnik%27s_theorem)
supplies such a bound of the shape $B = C\cdot M^{L}$. So the defeat of the residue sieve
is not merely a matter of principle: a compensating witness of polynomial size can be
exhibited, and the widget above finds one in milliseconds.

---

## 7. How far does the obstruction reach?

Maybe quadratic symbols are just too coarse? Try richer characters — cubic, quartic, any
[Dirichlet characters](https://en.wikipedia.org/wiki/Dirichlet_character) you like.

**Theorem (Abelian channels).** *Let $\chi_1,\dots,\chi_K$ be any finite family of
Dirichlet characters of a common modulus $M$, with values in any commutative ring. For any
target $N_0$ and candidate $p$ coprime to $M$, there are infinitely many primes $q$ with
$\chi_i(pq) = \chi_i(N_0)$ for all $i$.*

The proof is now pure group theory plus Dirichlet: put $q$ in the class $N_0 p^{-1}$, and
$\chi_i(pq) = \chi_i(p)\chi_i(N_0p^{-1}) = \chi_i(N_0)$. No reciprocity needed, and
primality of $p$ is not even used. **No abelian residue channel of bounded conductor can
eliminate a single candidate prime factor.**

What about *non-abelian* data — the [Artin symbol](https://en.wikipedia.org/wiki/Artin_reciprocity_law)
of a non-abelian Galois extension, where a prime carries a conjugacy class $C_p$ in a
group $G$ rather than a sign? The answer splits in a beautiful way, and you can explore it
here:

{{interactive_demo:1}}

* **The pruning half survives in complete generality.** In *any* group, $q = p^{-1}\sigma$
  compensates. No candidate class is ever excluded.
* **The torsor half is exactly commutativity.** The compensator is unique up to conjugacy
  for all targets **if and only if** $G$ is abelian. Switch the widget to $S_3$, $D_4$ or
  $A_4$ and watch a red multiplicity jump appear at exactly one class.
* **And yet at element level the fibre is always a torsor**, of size exactly $|C_p|$, in
  every group. The dichotomy is created purely by passing to conjugacy classes.

<details>
<summary>Click to reveal the two-line proof of the dichotomy</summary>

If $G$ is abelian, conjugacy is equality, so consistency says exactly $q = p^{-1}\sigma$:
one compensator.

If $ab \neq ba$, take $\sigma = p = a$. Then $q = 1$ is a compensator (via $x=a$, $y=1$),
and so is $q' = (bab^{-1})^{-1}a$, since $bab^{-1}$ is conjugate to $a$. If $1$ and $q'$
were conjugate then $q' = 1$, i.e. $bab^{-1} = a$, contradicting $ab \neq ba$. $\blacksquare$

For the element-level statement: $x \mapsto (x, x^{-1}\sigma)$ is a bijection from the
class $C_p$ onto $\{(x,y) : x\sim p,\ xy=\sigma\}$.
</details>

---

## 8. The final word: no filter of this shape can exist

Everything so far concerns particular sieves. The last theorem quantifies over *all* of
them. Model an arbitrary residue-based filter as a predicate $P(v,p)$ — "on observing
fingerprint $v$, keep $p$ as a possible factor". The only thing any usable filter must
satisfy is **soundness**: it never discards a genuine factor.

**Theorem.** *Every sound filter accepts every admissible candidate, for every admissible
observation. Equivalently: a residue filter that rejects even one admissible candidate
must be unsound — it discards a true factorization.*

<details>
<summary>Click to reveal the proof — one move</summary>

Given the observation $F(N_0)$ and a candidate $p$, no-pruning supplies an admissible
prime $q$ with $F(pq) = F(N_0)$. Soundness applied to the genuine semiprime $pq$ forces
$P(F(pq), p)$, i.e. $P(F(N_0), p)$. Nothing about the internal workings of $P$ was used —
it need not even be computable. $\blacksquare$

This upgrades the whole story from *"this sieve fails"* to *"no sieve of this shape can
exist"*.
</details>

---

## 9. Run the whole audit yourself

Every claim on this page is checked numerically here, from scratch, in pure Python:
structure, no-pruning across fourteen candidates, all $32$ patterns of the five-probe
basis, the fibre and its torsor structure, the leakage curve, the sharp boundary, an
abelian channel of order-twelve characters modulo $13$, the $S_3$ Artin channel, and the
no-sound-filter argument.

{{demo:0}}

---

## 10. What to take away

The experiment that started this asked whether cheap residue data leaks usable information
about factorization. It does leak information about $N$ — exactly $K$ bits. But the leaked
bits are of an irremediably symmetric kind: they constrain the pair $\{p,q\}$ only through
products $\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$, which are already visible in
$N$ itself. Learning an individual symbol would require knowing $p$ — the very thing you
are trying to find.

There is a broader moral for anyone hunting a shortcut. It is easy to mistake
**discriminative** power for **useful** power. A statistic that separates every element of
your test set may still be, provably, a constant-factor tool: it can label the haystack
beautifully and never tell you which straw is the needle.

*Cheap residues identify. They do not factor.*
