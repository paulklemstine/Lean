# The Fingerprint That Identifies Everything and Reveals Nothing

## A perfect informant with nothing to say

Imagine you are handed a number — a very large one, hundreds of digits — and told
that it is the product of exactly two primes, $N_0 = p \cdot q$. Your task is the
oldest hard problem in computational number theory: find $p$.

You cannot factor $N_0$ directly; that is the whole point. But you *can* interrogate
it cheaply. There is a classical family of questions you may ask of any integer,
each answered in a fraction of a millisecond even when the integer has a thousand
digits. The questions are about **quadratic residues**: for a small prime $a$, is
$a$ a square modulo $N_0$, in the generalized sense measured by the *Jacobi symbol*
$\left(\tfrac{a}{N_0}\right) \in \{+1,-1\}$?

Ask this for the first $K$ primes $a_1 = 2, a_2 = 3, a_3 = 5, \dots$ and you obtain
a vector of signs,

$$F(N_0) \;=\; \left[\left(\tfrac{a_1}{N_0}\right), \left(\tfrac{a_2}{N_0}\right), \dots, \left(\tfrac{a_K}{N_0}\right)\right] \in \{\pm 1\}^K .$$

Call it the **residue fingerprint** of $N_0$. It is the maximal *cheap* handle
that residue theory offers on a number you cannot factor: every entry costs only
$\mathrm{poly}(\log N_0)$ arithmetic — a Euclidean-algorithm-style computation
that never needs a factorization of $N_0$.

Here is the experimental observation that started this story. Take three hundred
random semiprimes of cryptographic shape and compute their fingerprints with
$K=20$ probes. All three hundred fingerprints are **distinct**. The fingerprint
looks like a perfect identifier — twenty cheap bits that separate every number in
the sample. Surely twenty bits of free information about $N_0$ must say *something*
about its factors?

The answer, proved below, is a flat and total **no**. Not "very little". Not
"only a constant factor's worth". Exactly zero. Every prime $p$ in the universe
remains a possible factor of a number with the observed fingerprint, and the
$K$ bits describing the fingerprint of $p$ itself remain completely free.
The residue fingerprint is a perfect informant who, when asked the only question
you care about, says nothing at all.

## Multiplicativity: the leak, and the trap

The reason one expects a leak is **multiplicativity**. The Jacobi symbol satisfies

$$\left(\tfrac{a}{mn}\right) = \left(\tfrac{a}{m}\right)\left(\tfrac{a}{n}\right),$$

so the fingerprint of a product is the entrywise product of the fingerprints:
$F(pq) = F(p) \cdot F(q)$. Observing $F(N_0)$ therefore *does* tell you something
about the pair $(p,q)$: for each probe $a$, you learn the **product**
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$.

And there the leak stops. What you learn is a *symmetric* function of the two
factors — it is invariant under swapping them, and it constrains only the joint
sign, never either sign separately. Knowing that $x \cdot y = +1$ for two unknown
signs $x,y \in \{\pm1\}$ tells you nothing whatsoever about $x$.

That is the intuition. The mathematics that turns it into a theorem is Dirichlet's
great result of 1837.

## The Dirichlet No-Pruning Theorem

**Theorem (No pruning).** *Let $A = \{a_1,\dots,a_K\}$ be any finite set of probe
primes, let $N_0$ be any odd number coprime to all of them, and let $p$ be **any**
odd prime not among the probes. Then there exist infinitely many primes $q$ with*

$$F(p \cdot q) = F(N_0).$$

Read that carefully, because it is stronger than it looks. It does not say that
some candidates survive. It says that *every* candidate survives, and each one
survives infinitely often. The set of prime factors compatible with the observed
fingerprint is the set of all primes. The fingerprint prunes nothing.

The proof is short and worth seeing in full, because it exhibits precisely why the
channel is empty.

Fix $p$. For every probe $a$ we want a prime $q$ with
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)$.
Since signs square to one, this is the same as demanding

$$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)
= \left(\tfrac{a}{N_0 \cdot p}\right) \quad \text{for all } a \in A.$$

So the required $q$ must merely have the same fingerprint as the *known* number
$N_0 p$. Now the second classical ingredient: the fingerprint is **periodic**.
Each symbol $\left(\tfrac{a}{\cdot}\right)$ depends only on the residue class of
its argument modulo $4a$, so the whole fingerprint depends only on the residue
class modulo the **conductor**

$$M \;=\; 4 \prod_{a \in A} a .$$

Consequently *any* prime $q \equiv N_0 p \pmod M$ does the job. And $N_0 p$ is
invertible modulo $M$, because $N_0$ and $p$ are odd and coprime to the probes.
Dirichlet's theorem on primes in arithmetic progressions now hands us infinitely
many primes in that class. $\blacksquare$

Two things deserve emphasis. First, the *arithmetic* content of the theorem — the
statement that every prime in the class $N_0 p \bmod M$ compensates — is a pure
congruence fact with no analysis in it at all. Second, the *analytic* content is
exactly one application of Dirichlet. This clean split has a practical payoff:
any effective bound $B$ on the least prime in a coprime class modulo $M$ is
inherited verbatim by the compensating prime. Linnik's theorem supplies such a
bound of the shape $B = C \cdot M^L$, so the defeat of the residue sieve is not
merely a matter of principle; a compensating witness of polynomial size can be
exhibited.

Here it is concretely. Take the first five primes as probes, $A = \{2,3,5,7,11\}$,
conductor $M = 4 \cdot 2310 = 9240$, and the target $N_0 = 1591 = 37 \cdot 43$,
whose fingerprint is $[1,-1,1,-1,1]$. Now pick your favourite candidate prime and
watch a compensator appear:

$$F(13 \cdot 197) = F(17 \cdot 47) = F(19 \cdot 181) = F(23 \cdot 103)
= F(29 \cdot 61) = F(37 \cdot 43) = F(1591).$$

Twelve candidate primes, twelve compensators, all fingerprint-indistinguishable
from the truth. The genuine factorization $37 \cdot 43$ is hidden in a crowd it
cannot be picked out of.

## Every pattern occurs: the constructive half

No-pruning says the channel cannot *remove* a candidate. The complementary fact
says the channel cannot *pin down* anything either.

**Theorem (Pattern surjectivity).** *Let $A$ be a set of $K$ distinct probe primes.
For every sign vector $\varepsilon \in \{\pm1\}^K$ there are infinitely many primes
$q$ with $F(q) = \varepsilon$. In particular the fingerprint map on primes takes
exactly $2^K$ values, and every one of them occurs.*

This is a genuine cross-domain construction. To hit a prescribed pattern one first
builds a *modulus* with that pattern, using the Chinese remainder theorem: at each
odd probe $a$ prescribe the residue $1$ when the target sign is $+1$, and a
quadratic nonresidue mod $a$ when it is $-1$ (such a nonresidue exists in every
finite field of odd order); at the modulus $8$ prescribe $1$ or $5$ according to
the desired value of $\left(\tfrac{2}{\cdot}\right)$. Quadratic reciprocity — in
the friendly form available because the constructed number is $1 \bmod 4$ — flips
each symbol $\left(\tfrac{a}{m}\right)$ into $\left(\tfrac{m}{a}\right)$, which the
prescription controls directly. Then Dirichlet upgrades the modulus to infinitely
many primes in its class. Four classical theorems, one construction.

The consequence is the failure of **individual pinning**: given the observation
$F(N_0)$ and any probe $a_0$, there are consistent factorizations $p_1 q_1$ and
$p_2 q_2$ of the same fingerprint with $\left(\tfrac{a_0}{p_1}\right) = +1$ and
$\left(\tfrac{a_0}{p_2}\right) = -1$. Not one bit of the factor's own fingerprint
is determined.

## The exact shape of the leak: a coset with no monodromy

We can now say precisely — not approximately — what the residue channel knows.

**Theorem (Exact consistency criterion).** *For primes $p, q$ outside the probe set,*
$$F(pq) = F(N_0) \iff \left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right) \text{ for every } a \in A.$$

That single symmetric relation is the entire content of the channel; there is no
residual constraint hiding anywhere. Package it geometrically. Let

$$\Phi(N_0) = \bigl\{\,(F(p), F(q)) \;:\; p,q \text{ prime},\; F(pq) = F(N_0)\,\bigr\}
\subseteq \{\pm1\}^K \times \{\pm1\}^K$$

be the **factorization fibre** of the observation: all pairs of factor fingerprints
compatible with what you see. The criterion says $\Phi(N_0)$ is exactly the graph
of the translation $u \mapsto F(N_0) \cdot u$ — a *coset* of the anti-diagonal
$\Delta^- = \{(w,w) : w \in \{\pm1\}^K\}$. Three consequences follow, and together
they are the sharpest possible statement of the verdict:

1. **Simple transitivity.** Any two consistent pairs differ by a *unique* sign
   vector $w$ acting simultaneously on both coordinates. The fibre is a trivial
   $\Delta^-$-torsor: it has no monodromy, no internal structure, nothing to
   exploit.
2. **Full projection.** The fibre surjects onto the first coordinate: every one of
   the $2^K$ patterns occurs as $F(p)$ for some consistent $p$. This is the
   no-pruning theorem in geometric form.
3. **Exact size.** The fibre has exactly $2^K$ elements.

Contrast the two counts. The fingerprint of $N$ itself ranges over exactly $2^K$
values — the channel emits exactly $K$ bits about $N$. About the *factorization*
it emits exactly zero: the $K$ bits of $F(p)$ remain uniformly free.

## Where the theorem stops — and why that is the point

Every hypothesis in the no-pruning theorem earns its keep, and the exceptions are
illuminating.

*Coprimality is necessary.* If a probe prime $a$ actually **divides** $N_0$, the
fingerprint prunes completely: the entry at $a$ becomes $0$ instead of $\pm1$,
which is visible directly in the data, and then for any candidate $p \neq a$ the
only prime $q$ with $F(pq) = F(N_0)$ is $q = a$. Total pruning — but this is the
trivial case in which trial division has already found the factor. The one thing
the residue channel can ever detect is a factor so small that you did not need the
channel to find it.

*The "collision-free hash" reading is false.* The fingerprint is a **square-class
invariant**: $F(m s^2) = F(m)$ for any $s$ coprime to the probes. It can therefore
never determine $N$; it sees only the class of $N$ in $(\mathbb{Z}/M)^\times$ modulo
squares, and every realized class contains infinitely many primes. The three
hundred distinct fingerprints in the experiment were an artifact of a small sample
against $2^{20}$ pigeonholes, not evidence of injectivity. Concretely, the prime
$79$ and the semiprime $1591$ share the fingerprint $[1,-1,1,-1,1]$ over
$A = \{2,3,5,7,11\}$, although they are not even congruent modulo the conductor.

## How far does the obstruction reach?

One might hope the collapse is an artifact of quadratic symbols — that a richer
residue channel would do better. It does not.

**Theorem (Abelian channels).** *Let $\chi_1,\dots,\chi_K$ be any finite family of
Dirichlet characters of a common modulus $M$, with values in any commutative ring,
and define $\Phi(N) = [\chi_1(N),\dots,\chi_K(N)]$. For any target $N_0$ coprime to
$M$ and any candidate $p$ coprime to $M$, there are infinitely many primes $q$ with
$\Phi(pq) = \Phi(N_0)$.*

The proof is now pure group theory plus Dirichlet: place $q$ in the class
$N_0 p^{-1} \bmod M$ and every character evaluates correctly, since
$\chi_i(pq) = \chi_i(p)\chi_i(N_0 p^{-1}) = \chi_i(N_0)$. No reciprocity is needed;
primality of $p$ is not even needed. *No abelian residue channel of bounded
conductor can eliminate a single candidate prime factor.*

What about a non-abelian channel — the Artin symbol of a non-abelian Galois
extension, where the datum attached to a prime is a conjugacy class $C_p$ in a
group $G$ rather than a sign? Here the answer splits in an instructive way. The
no-pruning half survives in complete generality: in **any** group, for any target
$\sigma$ and any candidate $p$, the element $q = p^{-1}\sigma$ compensates, so no
candidate class is ever excluded. But the rigid torsor structure does *not* survive:
the compensating class of a candidate is unique for all targets **if and only if
the group is abelian**. In the symmetric group $S_3$, the target $(0\,1)$ and the
candidate class of transpositions admit two non-conjugate compensators — the
identity and a $3$-cycle. Interestingly, the failure is created purely by the
passage to conjugacy classes: at the level of group *elements* the fibre is always
a torsor, of size exactly $|C_p|$, in every group.

So the picture is: commutativity is exactly what makes the fibre rigid, and
nothing at all is what makes it prune.

## The final word: no filter of this shape can exist

All of the above concerns particular sieves. The last theorem removes even that
qualification. Model an arbitrary residue-based filter as a predicate $P(v,p)$,
read as "on observing fingerprint $v$, keep $p$ as a possible factor". The only
requirement any usable filter must meet is **soundness**: it must never discard a
genuine factor, i.e. $P(F(xy), x)$ holds whenever $xy$ is an admissible semiprime.

**Theorem (No sound filter prunes).** *Every sound filter accepts every admissible
candidate, for every admissible observation. Equivalently: a residue filter that
rejects even one admissible candidate must be unsound — it discards a true
factorization.*

The proof is a single move: given the observation $F(N_0)$ and a candidate $p$,
no-pruning supplies an admissible $q$ with $F(pq) = F(N_0)$; soundness applied to
the genuine semiprime $pq$ forces $P(F(N_0), p)$. Nothing about the internal
workings of the filter is used. This upgrades the whole thread from *"this sieve
fails"* to *"no sieve of this shape can exist"*.

## What it means

The experiment that opened this story asked whether cheap residue data leaks usable
information about factorization. It does leak information about $N$ — exactly $K$
bits, and a fingerprint over twenty probes will indeed separate any modest list of
numbers. What the theorems show is that the leaked bits are of an irremediably
symmetric kind: they constrain the pair $\{p,q\}$ only through products
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$, which are already visible in
$N$ itself. Learning an individual symbol $\left(\tfrac{a}{p}\right)$ would require
knowing $p$ — the very thing you are trying to find.

There is a broader moral for anyone hunting for a shortcut. It is easy to
misidentify *discriminative* power as *useful* power. A statistic that separates
every element of your test set may still be, provably, a constant-factor tool: it
can label the haystack beautifully and never tell you which straw is the needle.
The residue channel is a clean, complete, and now fully understood example of that
phenomenon — and the fact that the collapse extends verbatim to every abelian
character channel of bounded conductor, and that the pruning failure persists even
in the non-abelian world, suggests that the classical, uniform, hint-free surface
of the factoring problem really has been exhausted here. If a shortcut exists, it
will not come from asking a number cheap questions about squares.
