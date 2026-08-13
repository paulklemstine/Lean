# The Residue-Leakage Curve and the Dirichlet No-Pruning Theorem

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

For a finite list $A = (a_1,\dots,a_K)$ of probe primes, the *quadratic-residue
fingerprint* of an integer $N$ is the vector of Jacobi symbols
$F_A(N) = \bigl(\left(\tfrac{a_1}{N}\right),\dots,\left(\tfrac{a_K}{N}\right)\bigr)$.
Each entry is computable in $\mathrm{poly}(\log N)$ time without any factorization
of $N$, so $F_A$ is the maximal *cheap* residue handle attached to $N$. We
determine exactly what this handle knows about a factorization $N_0 = pq$.

Our principal result is the **Dirichlet No-Pruning Theorem**: for every odd target
$N_0$ coprime to the probes and every odd prime $p$ outside the probe set, there
are infinitely many primes $q$ with $F_A(pq) = F_A(N_0)$. Every candidate prime
factor is consistent with the observation; the fingerprint prunes nothing. We
isolate the arithmetic core of this statement — the compensating primes are
*precisely* the primes of the unit class $N_0 p$ modulo the conductor $4\prod A$ —
so that any effective bound for the least prime in a coprime class (Linnik-type)
is inherited verbatim, giving a constructive form of the theorem.

We complement no-pruning with three sharpenings. (i) *Pattern surjectivity*: every
one of the $2^K$ sign vectors is the fingerprint of infinitely many primes, so the
range of $F_A$ on primes is exactly $\{\pm1\}^K$ and has cardinality $2^K$.
(ii) *Exact structure*: a pair of primes $(p,q)$ is consistent with the observation
if and only if the single symmetric relation
$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)$
holds at every probe; consequently the factorization fibre
$\Phi(N_0) = \{(F_A(p),F_A(q)) : F_A(pq) = F_A(N_0)\}$ is a coset of the
anti-diagonal of $\{\pm1\}^K\times\{\pm1\}^K$, is a *trivial torsor* under that
anti-diagonal (the action is simply transitive), projects onto all of $\{\pm1\}^K$
in the first coordinate, and has exactly $2^K$ elements. (iii) *Sharp boundary*:
the coprimality hypothesis is necessary and its failure is the only pruning the
channel ever achieves — if a probe prime divides $N_0$ the fingerprint has a zero
entry and the second factor is forced.

Finally we determine the scope of the obstruction. It holds for **every** finite
family of Dirichlet characters of a fixed modulus, in any coefficient ring
(*abelian channels*); it holds at the level of conjugacy classes in **every** group
(*non-abelian Artin channels*), while the rigid torsor structure holds if and only
if the group is abelian; and it is *sieve-independent*: any sound candidate filter
computed from the fingerprint accepts every admissible candidate, so a filter that
prunes anything must discard a true factorization.

**Keywords:** Jacobi symbol, quadratic residue, Dirichlet's theorem on arithmetic
progressions, Dirichlet characters, integer factorization, information leakage,
torsor, Artin symbol.

---

## 1. Introduction

### 1.1 The question

Let $N_0 = pq$ be a semiprime whose factorization is unknown. There is a small,
classical set of questions one may ask about $N_0$ *without* factoring it. Chief
among them are questions of quadratic character: for a small prime $a$, the Jacobi
symbol $\left(\tfrac{a}{N_0}\right)$ is computable by a reciprocity-driven
Euclidean algorithm in time $\mathrm{poly}(\log N_0)$, and its value lies in
$\{+1,-1\}$ whenever $\gcd(a,N_0)=1$.

Collecting these answers over the first $K$ primes produces a $K$-bit
*fingerprint*. Empirically this fingerprint is strikingly discriminative: on a
sample of three hundred cryptographic-shape semiprimes, $K = 20$ probes separate
all three hundred targets, with no collisions. The natural conjecture is that so
much cheap, structured information must constrain the factors — that some
candidate primes $p'$ can be ruled out because no partner $q'$ could reproduce the
observed symbols.

This paper proves that the conjecture is false in the strongest possible sense, and
determines the exact information-theoretic content of the channel.

### 1.2 Summary of results

Throughout, $A$ denotes a finite list of distinct probe primes, $K = |A|$, and

$$F_A(N) = \Bigl(\left(\tfrac{a}{N}\right)\Bigr)_{a\in A} \in \mathbb{Z}^K$$

the fingerprint, with $\left(\tfrac{\cdot}{\cdot}\right)$ the Jacobi symbol.

* **Theorem A (No pruning).** For odd $N_0$ coprime to $A$ and any odd prime
  $p \notin A$, the set $\{q \text{ prime} : F_A(pq) = F_A(N_0)\}$ is infinite.
* **Theorem B (Compensating class; effective form).** Every prime
  $q \equiv N_0 p \pmod{4\prod A}$ compensates, and $N_0 p$ is a unit modulo
  $4\prod A$. Hence any bound $B$ for the least prime in a coprime class modulo
  $4\prod A$ yields a compensator $q \le B$.
* **Theorem C (Pattern surjectivity).** Every sign vector in $\{\pm1\}^K$ is the
  fingerprint of infinitely many primes; the range of $F_A$ on primes outside $A$
  is exactly the set of $\pm1$-vectors of length $K$, of cardinality $2^K$.
* **Theorem D (Exact consistency; coset and torsor structure).** Consistency is
  equivalent to the symmetric relation
  $\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)$;
  the factorization fibre is a coset of the anti-diagonal, a trivial torsor under
  it, surjects onto $\{\pm1\}^K$, and has exactly $2^K$ elements.
* **Theorem E (Sharp boundary).** If a probe $a$ divides $N_0$ then the fingerprint
  has a zero entry and forces $q = a$; this is the only pruning the channel ever
  achieves. Moreover $F_A$ is a square-class invariant, $F_A(ms^2) = F_A(m)$, so it
  is not a collision-free hash: every realized class contains infinitely many
  primes.
* **Theorem F (Abelian channels).** For any finite family of Dirichlet characters
  of a fixed modulus $M$ in any commutative coefficient ring, and any $N_0, p$
  coprime to $M$, there are infinitely many primes $q$ with the character
  fingerprint of $pq$ equal to that of $N_0$.
* **Theorem G (Non-abelian channels).** In every group, every candidate class
  admits a compensating class; but the compensator is unique up to conjugacy for
  all targets if and only if the group is abelian. At element level the fibre is
  always a torsor of size $|C_p|$.
* **Theorem H (Sieve independence).** Any sound residue filter accepts every
  admissible candidate for every admissible observation.

### 1.3 Interpretation

The channel emits exactly $K$ bits about $N$ (Theorem C: $2^K$ distinct
fingerprints, all attained) and exactly $0$ bits about the factorization
(Theorem D: the $K$ bits of $F_A(p)$ remain uniformly free). Discriminative power
and pruning power are entirely decoupled. The residue channel identifies the
haystack and says nothing about the needle.

---

## 2. Definitions and basic structure

### 2.1 The fingerprint

**Definition 2.1 (Probe list, fingerprint).** A *probe list* is a finite list
$A = (a_1,\dots,a_K)$ of distinct primes. The *quadratic-residue fingerprint* of
$N \in \mathbb{N}$ relative to $A$ is
$$F_A(N) = \Bigl(\left(\tfrac{a_1}{N}\right),\dots,\left(\tfrac{a_K}{N}\right)\Bigr),$$
where $\left(\tfrac{a}{N}\right)$ is the Jacobi symbol. Its entries lie in
$\{+1,-1\}$ when $\gcd(a,N) = 1$ and equal $0$ otherwise.

**Definition 2.2 (Conductor).** The *conductor* of the probe list is
$M_A = 4\prod_{a\in A} a$. If $2 \in A$ this equals the classical $8\prod_{a \text{ odd}} a$.

**Definition 2.3 (Prime basis).** For $K \in \mathbb{N}$, the *prime basis* is the
list of the first $K$ primes $(2,3,5,7,11,\dots)$; it is duplicate-free and all its
members are prime.

**Definition 2.4 (Admissible candidate).** For a probe list $A$, a natural number
$p$ is an *admissible candidate* if $p$ is an odd prime with $p \notin A$. (Probe-
sized factors are found by trial division; see Theorem E for why they must be
excluded.)

### 2.2 Multiplicativity and periodicity

**Proposition 2.5 (Multiplicativity).** For nonzero $m,n$,
$$F_A(mn) = F_A(m) \odot F_A(n),$$
where $\odot$ is the entrywise product.

*Proof.* Entrywise this is the multiplicativity of the Jacobi symbol in its lower
argument, $\left(\tfrac{a}{mn}\right) = \left(\tfrac{a}{m}\right)\left(\tfrac{a}{n}\right)$,
applied along the list. $\square$

This is the *symmetric residue structure* leaked by a semiprime: the observation
determines the products $\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$ and
nothing more. Everything that follows is a precise elaboration of "nothing more".

**Proposition 2.6 (Periodicity / conductor bound).** If $m,n$ are odd and
$m \equiv n \pmod{M_A}$, then $F_A(m) = F_A(n)$.

*Proof.* For each probe $a$, $4a \mid M_A$, hence $m \equiv n \pmod{4a}$. The
Jacobi symbol $\left(\tfrac{a}{\cdot}\right)$ on odd arguments depends only on the
class modulo $4a$ (this is the content of quadratic reciprocity together with the
supplementary law at $2$), so the two symbols agree. Applying this at every probe
gives the claim. $\square$

**Proposition 2.7 (Square-class invariance).** If $m,s \neq 0$ and no probe divides
$s$, then $F_A(m s^2) = F_A(m)$.

*Proof.* Entrywise, $\left(\tfrac{a}{ms^2}\right) = \left(\tfrac{a}{m}\right)\left(\tfrac{a}{s}\right)^2$
and $\left(\tfrac{a}{s}\right) = \pm 1$ since $a \nmid s$ and $a$ is prime. $\square$

Propositions 2.6 and 2.7 already refute the "collision-free hash" reading of the
experimental data: $F_A$ factors through the quotient
$(\mathbb{Z}/M_A)^\times / \bigl((\mathbb{Z}/M_A)^\times\bigr)^2$, a group of order
at most $2^{K+1}$, so $F_A$ is massively non-injective on any range of integers
substantially larger than the conductor. Three hundred distinct values among $2^{20}$
possible fingerprints is a birthday-paradox non-event, not evidence of injectivity.

### 2.3 Coprimality bookkeeping

**Lemma 2.8.** If $m$ is odd and coprime to every probe, then $m$ is coprime to the
conductor $M_A$.

*Proof.* $m$ odd gives $\gcd(m,4)=1$; coprimality to each prime factor of
$\prod A$ gives $\gcd(m, \prod A) = 1$ by induction along the list; multiply. $\square$

---

## 3. The Dirichlet realization lemma

The single analytic input to the whole development is the following lemma.

**Lemma 3.1 (Dirichlet realization).** Let $A$ be a probe list, and let $m$ be odd
and coprime to every probe. Then the set
$$\{\,q \text{ prime} : q \text{ odd and } \left(\tfrac{a}{q}\right) = \left(\tfrac{a}{m}\right) \text{ for all } a \in A\,\}$$
is infinite.

*Proof.* Let $M = M_A$. By Lemma 2.8, $m$ is a unit modulo $M$. Dirichlet's theorem
on primes in arithmetic progressions supplies infinitely many primes $q$ with
$q \equiv m \pmod M$. For any such $q$: since $2 \mid M$ and $m$ is odd, $q$ is odd;
and since $4a \mid M$ for each probe $a$, Proposition 2.6's entrywise argument gives
$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{m}\right)$. $\square$

**Corollary 3.2 (The fingerprint is not a hash).** For $m$ odd and coprime to the
probes, the set $\{q \text{ prime} : F_A(q) = F_A(m)\}$ is infinite. In particular
every realized fingerprint class already contains infinitely many primes.

Structurally, Lemma 3.1 says: each fingerprint entry is a Dirichlet character of
the group $(\mathbb{Z}/M_A)^\times$, and Dirichlet's theorem populates every unit
class with infinitely many primes. All of the "impossibility" results below are
this one fact seen from different angles.

---

## 4. The No-Pruning Theorem

**Theorem 4.1 (Dirichlet No-Pruning).** Let $A$ be a probe list, $N_0$ odd and
coprime to every probe, and $p$ an odd prime with $p \notin A$. Then
$$\{\, q \text{ prime} : F_A(p q) = F_A(N_0) \,\}$$
is infinite. Consequently, the observation $F_A(N_0)$ removes **no** candidate
prime $p$ from the divisor search.

*Proof.* Put $m = N_0 p$. It is odd (product of odd numbers) and coprime to every
probe ($N_0$ is by hypothesis; $p$ is because $p$ is a prime distinct from each
probe). Lemma 3.1 supplies infinitely many odd primes $q$ with
$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{m}\right)$ for all $a \in A$. For any
such $q$ and any probe $a$,
$$\left(\tfrac{a}{pq}\right)
= \left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)
= \left(\tfrac{a}{p}\right)\left(\tfrac{a}{N_0 p}\right)
= \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)^2
= \left(\tfrac{a}{N_0}\right),$$
using multiplicativity twice and $\left(\tfrac{a}{p}\right)^2 = 1$ (valid since
$a \neq p$ are distinct primes, so the symbol is $\pm1$). Hence $F_A(pq) = F_A(N_0)$. $\square$

**Corollary 4.2 (Existence form).** For every $N_0$ and every candidate prime $p$
as above, a *compensating prime* $q$ with $F_A(pq) = F_A(N_0)$ exists.

The theorem is sharper than "the fingerprint is weak". It says the consistent
candidate set is the *entire* admissible candidate set: as a filter, the residue
channel is the identity map.

### 4.1 The arithmetic core, and effectivity

Theorem 4.1 is existential and gives no control on the size of $q$. The next two
results split the argument into a purely congruence-theoretic part (no analysis)
and a single analytic input, so that any effective version of the latter transfers.

**Lemma 4.3 (The compensating residue is a unit).** Under the hypotheses of
Theorem 4.1, $\gcd(N_0 p, M_A) = 1$.

*Proof.* $N_0 p$ is odd and coprime to each probe, so Lemma 2.8 applies. $\square$

**Theorem 4.4 (The compensating set is a full unit class).** Under the hypotheses
of Theorem 4.1, **every** prime $q$ with
$$q \equiv N_0 \, p \pmod{M_A}$$
satisfies $F_A(pq) = F_A(N_0)$.

*Proof.* Since $2 \mid M_A$ and $N_0 p$ is odd, $q$ is odd. Since $4a \mid M_A$ for
each probe $a$, the congruence gives
$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0 p}\right)$ for every $a$. Then the
computation in the proof of Theorem 4.1 applies verbatim. No appeal to Dirichlet is
made. $\square$

Thus the entire non-analytic content of no-pruning is the congruence condition
$q \equiv N_0 p \pmod{M_A}$, and conversely feeding infinitude of primes in that
class back into Theorem 4.4 recovers Theorem 4.1. This clean split has a
quantitative payoff.

**Theorem 4.5 (Effective no-pruning).** Suppose $B$ bounds the least prime in every
coprime residue class modulo $M_A$; that is, for every $r$ with $\gcd(r,M_A)=1$
there is a prime $q \le B$ with $q \equiv r \pmod{M_A}$. Then for every candidate
prime $p$ there is a compensating prime $q \le B$ with $F_A(pq) = F_A(N_0)$.

*Proof.* Apply the hypothesis to $r = N_0 p$, which is a unit class by Lemma 4.3,
and then Theorem 4.4. $\square$

Linnik's theorem provides exactly such a $B$, of the shape $B = C \cdot M_A^{L}$ for
absolute constants $C, L$. Since $M_A = 4\prod_{i\le K} a_i = e^{(1+o(1))a_K}$ is a
fixed, small modulus for any practical $K$, the compensating witness is not merely
guaranteed but *constructible in polynomial time*. The defeat of the residue sieve
is effective, not merely in principle.

### 4.2 A worked instance

Take $A = (2,3,5,7,11)$, so $K = 5$ and $M_A = 4\cdot 2310 = 9240$. Let
$N_0 = 1591 = 37\cdot 43$. Then $F_A(1591) = (1,-1,1,-1,1)$, and periodicity is
visible: $F_A(1591 + 9240) = F_A(1591)$.

For each candidate prime one exhibits a compensator:

| candidate $p$ | compensator $q$ | $p\cdot q$ |
|---|---|---|
| $13$ | $197$ | $2561$ |
| $17$ | $47$ | $799$ |
| $19$ | $181$ | $3439$ |
| $23$ | $103$ | $2369$ |
| $29$ | $61$ | $1769$ |
| $31$ | $71$ | $2201$ |
| $37$ | $43$ | $1591$ |
| $41$ | $311$ | $12751$ |
| $47$ | $17$ | $799$ |
| $53$ | $107$ | $5671$ |
| $59$ | $101$ | $5959$ |
| $3607$ | $167$ | $602369$ |

Every listed product has fingerprint $(1,-1,1,-1,1)$, identical to $F_A(1591)$. The
true factorization $37\cdot43$ is one row among many, indistinguishable from the
others by the channel. Note also the collision $F_A(79) = F_A(1591)$ with $79$
prime and $79 \not\equiv 1591 \pmod{9240}$: the fingerprint sees only the square
class, illustrating Proposition 2.7 (indeed $F_A(1591\cdot 13^2) = F_A(1591)$).

---

## 5. Pattern surjectivity: every fingerprint occurs

No-pruning says the channel cannot exclude. The complementary statement is
constructive: the channel's output space is fully populated by primes.

**Theorem 5.1 (Surjectivity onto sign patterns).** Let $A$ be a duplicate-free
probe list and $\varepsilon : A \to \{\pm1\}$ any prescribed sign assignment. Then
infinitely many primes $q$ satisfy $\left(\tfrac{a}{q}\right) = \varepsilon(a)$ for
all $a \in A$; equivalently $F_A(q) = \varepsilon$.

*Proof sketch.* The argument has two stages: realize the pattern by *some* modulus,
then upgrade to primes.

*Stage 1 (a modulus with the prescribed pattern).* Split $A$ into the odd probes and
possibly the prime $2$. Consider the pairwise-coprime moduli $8$ and the odd probes
$a$. Prescribe residues by the Chinese remainder theorem as follows:

* modulo $8$: prescribe $1$ if the target value of $\left(\tfrac{2}{\cdot}\right)$
  is $+1$, and $5$ if it is $-1$ (the supplementary law at $2$ reads the symbol off
  the class mod $8$);
* modulo an odd probe $a$: prescribe $1$ if $\varepsilon(a) = +1$, and a quadratic
  nonresidue mod $a$ if $\varepsilon(a) = -1$. Such a nonresidue exists because a
  finite field of odd order always contains a non-square.

Let $m$ be a simultaneous solution. Then $m \equiv 1 \pmod 4$ (as $m \bmod 8 \in \{1,5\}$),
so the *friendly* case of quadratic reciprocity applies and gives
$\left(\tfrac{a}{m}\right) = \left(\tfrac{m}{a}\right)$ for each odd probe $a$. The
right side is a Legendre symbol depending only on $m \bmod a$, which the
prescription controls; hence $\left(\tfrac{a}{m}\right) = \varepsilon(a)$. The value
at $2$ is read off from $m \bmod 8$ by the supplementary law. Nonvanishing of all
symbols forces $m$ to be coprime to all probes, and $m$ is odd.

*Stage 2 (from modulus to primes).* Apply Lemma 3.1 to $m$: infinitely many primes
$q$ share all probe symbols with $m$, hence realize $\varepsilon$. $\square$

The proof is a genuine confluence of four classical theorems: the Chinese remainder
theorem, quadratic reciprocity with its supplementary law, existence of nonresidues
in finite fields, and Dirichlet's theorem.

**Corollary 5.2 (Exact range).** For a duplicate-free probe list $A$ of length $K$,
$$\{\, F_A(q) : q \text{ prime},\, q \notin A \,\} \;=\; \{\pm1\}^K .$$

*Proof.* "$\subseteq$": for $q$ prime outside $A$ and $a \in A$ the two distinct
primes are coprime, so each symbol is $\pm 1$. "$\supseteq$": Theorem 5.1, noting
that a prime realizing a $\pm1$-pattern cannot itself be a probe (a probe's own
symbol would vanish). $\square$

**Theorem 5.3 (Exact leakage count).** The set of $\pm1$-vectors of length $K$ has
exactly $2^K$ elements; hence
$$\bigl|\{\, F_A(q) : q \text{ prime},\, q\notin A \,\}\bigr| = 2^K .$$

*Proof.* Induct on $K$: the sign vectors of length $K+1$ are the disjoint union of
those of length $K$ prefixed by $+1$ and by $-1$, and both prefix maps are
injective. Combine with Corollary 5.2. $\square$

So the channel emits exactly $K$ bits about $N$ — an exact "residue-leakage curve"
$K \mapsto K$ bits — and Theorem 4.1 says none of them is about the factors.

**Corollary 5.4 (No individual pinning).** Fix the observation $F_A(N_0)$ and any
probe $a_0 \in A$. There exist consistent factorizations $p_1q_1$ and $p_2q_2$,
both with fingerprint $F_A(N_0)$, such that $\left(\tfrac{a_0}{p_1}\right) = +1$ and
$\left(\tfrac{a_0}{p_2}\right) = -1$.

*Proof.* By Theorem 5.1 choose a prime $p_1$ with all probe symbols $+1$ and a
prime $p_2$ with symbol $-1$ at $a_0$ and $+1$ elsewhere. Both are outside $A$
(their symbols are nonzero). Apply Corollary 4.2 to each. $\square$

Thus not a single bit of the factor's own fingerprint is determined by the
observation — only the symmetric products, which are already read off from $N_0$.

---

## 6. Exact structure of the channel: coset and torsor

We now characterize consistency exactly and give the fibre its geometry.

**Theorem 6.1 (Exact consistency criterion).** Let $A$ be a probe list, $p,q$ primes
with $p \notin A$. Then
$$F_A(pq) = F_A(N_0) \iff \left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right) \quad \text{for all } a \in A .$$

*Proof.* Entrywise, $F_A(pq) = F_A(N_0)$ means
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)$ for
each $a$. Since $p \notin A$ and both are prime, $\left(\tfrac{a}{p}\right) = \pm1$,
so it squares to $1$ and may be moved across the equation in either direction. $\square$

The criterion is an *if and only if*: the symmetric relation is not merely implied
by consistency, it *is* consistency. There is no residual constraint.

**Definition 6.2 (Sign group, anti-diagonal).** Equip $\{\pm1\}^K$ with the entrywise
product $\odot$; it is an elementary abelian $2$-group of order $2^K$. The
*anti-diagonal* is $\Delta^- = \{(w,w) : w \in \{\pm1\}^K\}$, acting on
$\{\pm1\}^K\times\{\pm1\}^K$ by simultaneous entrywise multiplication.

**Definition 6.3 (Factorization fibre).** For an observation $F_A(N_0)$,
$$\Phi(N_0) = \bigl\{ (F_A(p), F_A(q)) : p,q \text{ prime},\; p,q \notin A,\; F_A(pq) = F_A(N_0) \bigr\}
\subseteq \{\pm1\}^K \times \{\pm1\}^K .$$

**Theorem 6.4 (The fibre is a coset).** For a duplicate-free probe list $A$ and odd
$N_0$ coprime to the probes,
$$\Phi(N_0) = \bigl\{ (u,\; F_A(N_0)\odot u) \;:\; u \in \{\pm1\}^K \bigr\},$$
the graph of the translation $u \mapsto F_A(N_0)\odot u$, i.e. a coset of $\Delta^-$.

*Proof.* ($\subseteq$) Given consistent primes $p,q \notin A$, Corollary 5.2 puts
$F_A(p) \in \{\pm1\}^K$, and Theorem 6.1 gives entrywise
$\left(\tfrac{a}{q}\right) = \left(\tfrac{a}{N_0}\right)\left(\tfrac{a}{p}\right)$,
i.e. $F_A(q) = F_A(N_0)\odot F_A(p)$.
($\supseteq$) Given $u \in \{\pm1\}^K$, Theorem 5.1 produces a prime $p \notin A$
with $F_A(p) = u$, and Corollary 4.2 a compensating prime $q$; the compensator has
nonvanishing symbols (each is a product of $\pm1$s by Theorem 6.1), so $q \notin A$,
and its fingerprint is $F_A(N_0)\odot u$. $\square$

**Theorem 6.5 (Trivial torsor: simple transitivity).** Under the hypotheses of
Theorem 6.4, for any two elements $x,y \in \Phi(N_0)$ there is a **unique**
$w \in \{\pm1\}^K$ with $y = (w \odot x_1,\, w \odot x_2)$. Hence $\Delta^-$ acts
simply transitively on $\Phi(N_0)$: the fibre is a trivial $\Delta^-$-torsor.

*Proof.* Existence: take $w = y_1 \odot x_1$ (entrywise; note $x_1$ is its own
inverse). Then $w \odot x_1 = y_1$, and by Theorem 6.4 both second coordinates are
$F_A(N_0)$ times the respective first, so
$w \odot x_2 = w \odot F_A(N_0)\odot x_1 = F_A(N_0) \odot y_1 = y_2$.
Uniqueness: if $y_1 = w\odot x_1$ then multiplying by
$x_1$ recovers $w = y_1\odot x_1$. $\square$

"Trivial torsor" is the precise structural form of the verdict: the fibre has no
monodromy, no distinguished point, no internal structure that an algorithm could
exploit to prefer one candidate over another.

**Theorem 6.6 (No pruning, geometric form).** Under the same hypotheses,
$$\mathrm{pr}_1\bigl(\Phi(N_0)\bigr) = \{\pm1\}^K .$$

*Proof.* Immediate from Theorem 6.4. $\square$

**Theorem 6.7 (Exact fibre size).** $|\Phi(N_0)| = 2^K$.

*Proof.* By Theorem 6.4, $\Phi(N_0)$ is the image of $\{\pm1\}^K$ under the injective
map $u \mapsto (u, F_A(N_0)\odot u)$; apply Theorem 5.3. $\square$

**The leakage ledger.** Theorem 5.3: the channel distinguishes exactly $2^K$ values
of $N$, i.e. it emits $K$ bits about $N$. Theorem 6.7 together with Theorem 6.6:
conditioned on the observation, the fingerprint of the factor $p$ ranges over all
$2^K$ possibilities, i.e. the channel emits $0$ bits about the factorization. These
two numbers are the residue-leakage curve in full.

---

## 7. The sharp boundary: where pruning *does* occur

Every hypothesis of Theorem 4.1 is load-bearing, and identifying the failure mode
identifies the only pruning the channel is ever capable of.

**Lemma 7.1 (Visible degeneracy).** If a probe prime $a$ divides $N_0 \neq 0$ then
$\left(\tfrac{a}{N_0}\right) = 0$; the degenerate case is visible directly in the
observed data.

**Theorem 7.2 (Probe divisor forces the factor).** Let $a \in A$ divide $N_0 \neq 0$,
let $p$ be a prime with $p \neq a$, and let $q$ be a prime with
$F_A(pq) = F_A(N_0)$. Then $q = a$.

*Proof.* At the probe $a$ the observation is $0$ by Lemma 7.1, hence
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right) = 0$. Since $a \neq p$ are distinct
primes, $\left(\tfrac{a}{p}\right) = \pm 1 \neq 0$, so $\left(\tfrac{a}{q}\right) = 0$,
which forces $\gcd(a,q) \neq 1$; as $a,q$ are prime, $q = a$. $\square$

So when a probe divides the target the channel prunes *completely* — but this is
precisely the case in which trial division by the probe has already produced the
factor. The coprimality hypothesis cannot be dropped, and dropping it buys nothing:
the only pruning the residue channel ever achieves is the detection of a
probe-sized prime factor.

---

## 8. Scope: how far does the obstruction extend?

### 8.1 Arbitrary abelian channels

One might hope that quadratic symbols are simply too coarse and that higher-order
characters — cubic residues, quartic residues, arbitrary Dirichlet characters —
would fare better. They do not.

**Definition 8.1 (Character fingerprint).** Let $R$ be a commutative monoid with
zero, $M \ge 1$, and $\chi_1,\dots,\chi_K$ Dirichlet characters modulo $M$ with
values in $R$. The *character fingerprint* of $N$ is
$\Phi_\chi(N) = (\chi_1(N),\dots,\chi_K(N))$.

**Theorem 8.2 (Abelian no-pruning).** For any such family, any $N_0$ coprime to $M$,
and any $p$ coprime to $M$ (primality of $p$ is not required), there are infinitely
many primes $q$ with $\Phi_\chi(pq) = \Phi_\chi(N_0)$.

*Proof.* Let $u, v \in (\mathbb{Z}/M)^\times$ be the classes of $p$ and $N_0$. By
Dirichlet's theorem there are infinitely many primes $q$ in the unit class
$v u^{-1}$. For each such $q$ and each $i$,
$$\chi_i(pq) = \chi_i(p)\,\chi_i(vu^{-1}) = \chi_i\bigl(u \cdot v u^{-1}\bigr) = \chi_i(v) = \chi_i(N_0),$$
using complete multiplicativity of characters on units. $\square$

*No abelian residue channel of bounded conductor can eliminate a single candidate
prime factor.* The quadratic case of Section 4 is the specialization in which each
$\chi_i$ is the Jacobi symbol $\left(\tfrac{a_i}{\cdot}\right)$ of conductor $4a_i$;
there $p^{-1} \equiv p$ up to squares, which is why the compensating class appeared
as $N_0 p$ rather than $N_0 p^{-1}$. As a sanity check, applying Theorem 8.2 to the
single mod-$8$ quadratic character recovers the no-pruning statement for the symbol
$\left(\tfrac{2}{\cdot}\right)$ with no use of reciprocity at all.

### 8.2 Non-abelian (Artin-symbol) channels

Replace the abelian character channel by the Artin symbol of a (possibly
non-abelian) Galois extension with group $G$: the datum attached to a prime $p$ is a
conjugacy class $C_p \subseteq G$, the datum attached to $N = pq$ is the class of
$\sigma_N = \sigma_p\sigma_q$, and the fibre is
$\{(C_p, C_q) : \sigma_N \in C_p\cdot C_q\}$. It is natural to conjecture that
non-commutativity destroys the free-compensation phenomenon. It does not — but it
does destroy the torsor.

**Definition 8.3.** For $\sigma, p, q$ in a group $G$, say $(p,q)$ is
*class-compatible* with $\sigma$ if there exist $x,y \in G$ with $x$ conjugate to
$p$, $y$ conjugate to $q$, and $xy = \sigma$. (This relation depends on $p$ and $q$
only through their conjugacy classes, so it is a statement about
$\mathrm{Cl}(G)\times\mathrm{Cl}(G)$.)

**Theorem 8.4 (No pruning in every group).** For every group $G$, every target
$\sigma \in G$, and every candidate $p \in G$, the element $q = p^{-1}\sigma$ is
class-compatible with $\sigma$. Hence the fibre surjects onto all of
$\mathrm{Cl}(G)$: not a single candidate class is excluded, abelian or not.

*Proof.* Take $x = p$, $y = p^{-1}\sigma$; then $xy = \sigma$. $\square$

**Theorem 8.5 (Torsor $\iff$ abelian).** For a group $G$, the following are
equivalent:
1. for all $\sigma,p,q,q'$, if $(p,q)$ and $(p,q')$ are both class-compatible with
   $\sigma$ then $q$ and $q'$ are conjugate (the compensator is unique up to
   conjugacy);
2. $G$ is abelian.

*Proof.* $(2)\Rightarrow(1)$: in an abelian group conjugacy is equality, so
class-compatibility with $\sigma$ says exactly $q = p^{-1}\sigma$. $(1)\Rightarrow(2)$:
suppose $ab \neq ba$. Take $\sigma = p = a$. Then $q = 1$ is compatible (via
$x = a, y = 1$), and so is $q' = (bab^{-1})^{-1}a$ (via $x = bab^{-1}$, which is
conjugate to $a$). If $1$ and $q'$ were conjugate then $q' = 1$, i.e.
$bab^{-1} = a$, contradicting $ab \neq ba$. $\square$

In $S_3$ this is concrete: with $\sigma = p = (0\,1)$, both the identity and a
$3$-cycle arise as compensators, and they are not conjugate. Hence $S_3$ is a
genuine counterexample to the class-level torsor property.

**Theorem 8.6 (Element-level fibre).** For any group $G$ and any $\sigma, p$,
$$\bigl|\{(x,y) \in G\times G : x \sim p,\; xy = \sigma\}\bigr| = |C_p| ,$$
where $C_p$ is the conjugacy class of $p$.

*Proof.* The map $x \mapsto (x, x^{-1}\sigma)$ is a bijection from $C_p$ onto the
fibre. $\square$

So at element level the fibre is always a torsor; the abelian/non-abelian dichotomy
of Theorem 8.5 is created purely by the passage to conjugacy classes. The moral:
*no-pruning is not an artifact of commutativity — it survives every group-theoretic
residue channel — while the rigid $2^K$-torsor picture is exactly as general as the
abelian hypothesis.*

### 8.3 Sieve independence: no filter of this shape can exist

All previous results concern specific sieves. The final theorem quantifies over
*all* of them.

**Definition 8.7 (Residue filter, soundness).** A *residue filter* is a predicate
$P(v,p)$, read "on observing fingerprint $v$, keep $p$ as a possible prime factor".
It is *sound* if it never discards a genuine factor: for all distinct admissible
candidates $x,y$, $P\bigl(F_A(xy),\, x\bigr)$ holds.

**Theorem 8.8 (No sound residue filter prunes).** Let $P$ be sound. Then for every
odd $N_0$ coprime to the probes and every admissible candidate $p$,
$P\bigl(F_A(N_0), p\bigr)$ holds. Equivalently,
$$\{\, p : p \text{ admissible and } P(F_A(N_0),p) \,\} = \{\, p : p \text{ admissible} \,\}.$$

*Proof.* Theorem 4.1 provides infinitely many compensating primes $q$; removing the
finitely many degenerate ones ($q = 2$, $q = p$, and the probes) leaves an
*admissible* $q \neq p$ with $F_A(pq) = F_A(N_0)$. Soundness applied to the genuine
semiprime $pq$ gives $P(F_A(pq), p)$, and rewriting the fingerprint gives
$P(F_A(N_0), p)$. $\square$

**Corollary 8.9 (Cryptanalytic form).** A residue filter that rejects even one
admissible candidate for one admissible observation is necessarily unsound: it
discards a true factorization.

Nothing about the internal workings of $P$ is used — it need not be computable, let
alone efficient. This upgrades the thread from *"this sieve fails"* to *"no sieve of
this shape can exist"*.

---

## 9. Algorithms

Three procedures make the theory constructive.

**Algorithm 1 (Fingerprint evaluation).** Given $N$ and probes $a_1,\dots,a_K$,
compute $\left(\tfrac{a_i}{N}\right)$ by the reciprocity-driven Euclidean algorithm.
Cost: $O(K \cdot \log^2 \max(a_i, N))$ bit operations with schoolbook arithmetic;
crucially, no factorization of $N$ is required.

**Algorithm 2 (Compensator search).** Given $N_0$, probes $A$ and a candidate prime
$p$, compute $r = N_0 p \bmod M_A$ with $M_A = 4\prod A$, then scan the arithmetic
progression $r, r+M_A, r+2M_A,\dots$ for a prime. By Theorem 4.4 the first prime
found is a valid compensator. Correctness is unconditional; termination and the
running-time bound come from Dirichlet and Linnik respectively, giving a witness of
size $O(M_A^{L})$.

**Algorithm 3 (Pattern realization).** Given a target sign vector $\varepsilon$,
build a modulus by the Chinese remainder theorem — residue $1$ or $5$ modulo $8$ for
the symbol at $2$; residue $1$ or a least quadratic nonresidue modulo each odd probe
— and then scan its class modulo $M_A$ for a prime. By Theorem 5.1 this always
succeeds, and the resulting prime has $F_A(q) = \varepsilon$.

Combining Algorithms 2 and 3 constructs, for any observation and any prescribed
pattern $u \in \{\pm1\}^K$, an explicit consistent factorization $pq$ with
$F_A(p) = u$ — a concrete point of the fibre $\Phi(N_0)$ for every one of its $2^K$
positions.

---

## 10. Discussion

### 10.1 Discriminative power is not pruning power

The experiment that motivated this work found that a $20$-probe fingerprint
separates $300$ random semiprimes without collision, and inferred that the channel
must constrain the factors. Both halves of the inference are wrong in an instructive
way.

The *observation* is correct but weaker than it appears: the channel has $2^{20}$
output values, so $300$ distinct outputs is expected by the birthday bound. Indeed
the fingerprint is provably far from injective — it is a square-class invariant
(Proposition 2.7) and periodic modulo the conductor (Proposition 2.6), so as a hash
on integers it collides infinitely often; every realized class contains infinitely
many primes (Corollary 3.2).

The *inference* fails for a structural reason. The information the channel carries
about $(p,q)$ is exactly the collection of symmetric products
$\left(\tfrac{a}{p}\right)\left(\tfrac{a}{q}\right)$ — which is to say, exactly what
one already reads off from $N$ itself. Recovering an individual symbol
$\left(\tfrac{a}{p}\right)$ would require knowing $p$. There is no asymmetry
anywhere in the channel to break the tie between the two factors, and the
no-pruning theorem is the formal expression of that fact.

### 10.2 A general lesson for search-space reduction

The pattern generalizes beyond factoring. Suppose an invariant $I$ is (i) cheap,
(ii) multiplicative over the decomposition one is trying to invert, and (iii) has a
bounded output group. Then observing $I(N)$ determines the *product* of the
invariants of the parts and nothing else; if the invariant group is a group in which
every element is a product of any prescribed first factor and a suitable second one
— always true in a group — no part is excluded. The two ingredients that make the
collapse total in our setting are the group structure of the output and the
availability of a realization theorem (Dirichlet) guaranteeing that the compensating
class is actually inhabited by legitimate objects (primes). When both hold, the
channel is a bijective relabelling of information you already had.

### 10.3 Consequences for factoring heuristics

Concretely: residue fingerprints may be used as *cheap identifiers* — for
deduplication, for indexing, for consistency checks. They may not be used to prune a
divisor search. Any implementation claiming a speedup from such pruning is, by
Corollary 8.9, either unsound or reproducing trial division by the probes
(Theorem 7.2). The classical, uniform, hint-free residue surface of the factoring
problem is exhausted in this precise sense: for every abelian channel of bounded
conductor the candidate set is untouched, and even non-abelian Artin data excludes
no candidate class.

### 10.4 Limits of the results

Three honest caveats:

1. **Bounded conductor.** Theorem 8.2 is uniform in the number of characters but
   fixes the modulus $M$. A channel whose conductor grows with $N$ (for instance,
   symbols $\left(\tfrac{a}{N}\right)$ with $a$ of size comparable to $N$) is not
   covered — but such probes are no longer cheap in the relevant sense once the
   number of them is large.
2. **Hint-free.** All statements are about the fingerprint alone. Side information
   (a partial factor, an approximation to $p$, a related modulus) changes the
   problem entirely; the theorems say nothing about such settings.
3. **Non-uniformity.** The theorems rule out sound *filters*; they do not rule out
   an algorithm that uses residue data as one input among several in a randomized
   or amortized way. What they do show is that any such use cannot shrink the
   candidate set on its own.

---

## 11. Future work

Several concrete directions follow.

**Effective no-pruning.** The arithmetic half is settled: the compensators are
precisely the primes of the unit class $N_0 p$ modulo $4\prod A$ (Theorem 4.4), and
any effective bound for the least prime in a coprime class transfers verbatim
(Theorem 4.5). What remains is the analytic half — an explicit, small $B$ for the
specific moduli $4\prod_{i\le K} p_i$, ideally with constants good enough to make the
compensator search competitive in practice rather than merely polynomial.

**Growing conductor.** Determine the exact threshold at which a channel of growing
conductor begins to prune. The results here say a fixed modulus never does; a
modulus of size comparable to $N$ trivially does (it *is* $N$). Locating the
transition would sharpen the notion of "cheap residue handle".

**Beyond residues.** The multiplicative-invariant argument of §10.2 suggests
formulating a general no-pruning criterion: identify the exact hypotheses on an
invariant $I$ and a realization theorem under which observing $I(N)$ provably
excludes no factor. Candidate settings include ideal-class data, elliptic-curve
reduction data, and Frobenius traces.

**Non-abelian channels.** Theorem 8.5 shows that non-commutativity destroys the
torsor structure while Theorem 8.4 shows it does not create pruning. It remains to
quantify the *multiplicity* structure: in a non-abelian group the number of
compensating classes varies with the candidate class (it is one for the identity
class and at least two for a class with non-central members). Understanding this
multiplicity function as an invariant of $G$ — and whether it can ever be leveraged
statistically, even without hard exclusion — is open.

**Statistical versus exact leakage.** All results here are worst-case exclusion
statements. The distributional question is untouched: conditioned on
$F_A(N_0)$, how are the *sizes* of consistent factor pairs distributed? Exclusion is
impossible, but a nontrivial posterior over candidates is not obviously ruled out,
and quantifying it — or proving it uniform to within a constant — is the natural
next target.

---

## 12. Conclusion

The quadratic-residue fingerprint over $K$ probe primes is a cheap, perfectly
well-behaved arithmetic statistic that emits exactly $K$ bits about an integer $N$
and exactly zero bits about the factorization of $N$. Every candidate prime factor
survives the observation, infinitely often; every sign pattern of the factor's own
fingerprint remains available; the set of consistent factor-fingerprint pairs is a
coset of the anti-diagonal on which the anti-diagonal acts simply transitively, of
size exactly $2^K$; the sole exception is the degenerate case in which a probe
divides the target, which trial division already handles. The phenomenon is not a
peculiarity of quadratic symbols: it holds for every finite family of Dirichlet
characters of a fixed modulus, in any coefficient ring, and the pruning failure
persists even for non-abelian Artin-symbol data. Finally, it is sieve-independent:
any candidate filter that never discards a true factorization accepts every
admissible candidate.

Cheap residues identify. They do not factor.
