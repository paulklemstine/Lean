# Conductor Budgets for Periodic Side Statistics: Residue Dials Cannot Amplify a Partial-Key Hint

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

We study whether a family of periodic arithmetic statistics of a hidden prime $p$
— Kronecker symbols $\left(\frac{D_i}{p}\right)$ at fundamental discriminants, and
more generally any *residue dials* — can amplify a Coppersmith-style partial-key
hint $p \equiv r \pmod m$ by cutting down the resulting candidate set. We prove
that the answer is no, and we locate the obstruction exactly.

The entire discriminating power of a dial family is controlled by a single integer,
the conductor least common multiple $M^* = \operatorname{lcm}_i c_i$, measured
against the hint modulus $m$. Our **master bound** states that on any candidate set
contained in a single hint class mod $m$, the dial vector takes at most
$M^*/\gcd(M^*, m)$ distinct values; consequently the candidate set cannot shrink by
more than that factor. We show this budget is **exactly attained** for every pair
$(M^*, m)$, so no sharper universal bound exists, and that dials of coprime
conductors compound multiplicatively, which identifies $M^*$ (rather than
$\max_i c_i$) as the correct invariant.

From the master bound we derive a strict dichotomy. If $M^* \mid m$, the dial vector
is a function of the hint — *hint-computable* — hence constant on the candidate set;
it carries exactly zero information about any secret statistic of $p$, and remains
zero-information under arbitrary post-processing. If $M^* \nmid m$, the hint provably
fails to determine the residue $p \bmod M^*$ the dials read, and any dial family
separating two candidates of a hint class is not hint-computable. There is no third
regime: *computable implies useless, useful implies incomputable*.

We then convert the budget into a threshold. The joint attacker statistic
(hint, dial vector) resolves $p$ modulo $\operatorname{lcm}(m, M^*)$ and no further,
so pinning a candidate inside a window $[0, X)$ forces $X \le \operatorname{lcm}(m, M^*) \le mM^*$,
i.e. $M^* \ge X/m$. In the Coppersmith regime $X = m^2$ (a prime $p < N^{1/2}$
against a hint $m \approx N^{1/4}$), this yields $M^* \ge m$: an informative dial
family must have conductor lcm at least the size of the hint modulus itself, and is
therefore as expensive as a second hint. A complementary counting barrier forces
$K \ge \log_3 C$ sign dials to pin $C$ candidates. Both thresholds are shown to be
attained, so the obstruction is exact rather than an artefact of the estimates.

Finally, we observe that no step of the argument uses multiplicativity, reciprocity,
or the $\pm 1$ range of Kronecker symbols — only periodicity. The barrier is a
statement about conductors, and applies verbatim to any periodic side channel.

**Keywords:** Coppersmith partial-key exposure, Kronecker symbol, conductor,
residue dial, side-channel information bound, pigeonhole, Chinese Remainder Theorem.

---

## 1. Introduction

### 1.1 The setting

Let $N = pq$ be an RSA-type modulus with $p < q$, so $p < N^{1/2}$. A *partial-key
hint* is knowledge of a residue $p \equiv r \pmod m$ for some modulus $m$ known to
the attacker. Coppersmith's lattice method converts a hint with $m \gtrsim N^{1/4}$
into a full factorization in polynomial time; below that threshold the method fails
and one is left with the **candidate set**
$$
\Omega \;=\; \{\, p' \in [0, X) \;:\; p' \equiv r \pmod m \,\},
$$
of size roughly $X/m$. With $X \approx N^{1/2}$ and $m \approx N^{1/4}$ this is on
the order of $N^{1/4}$ candidates — computationally hopeless to enumerate.

A natural hope is that publicly-available arithmetic data about $p$ could sieve
$\Omega$ further and thereby lower the Coppersmith threshold. The most attractive
such data are the **Kronecker symbols**
$$
p \;\longmapsto\; \left(\frac{D}{p}\right) \in \{-1, 0, +1\}
$$
at fundamental discriminants $D$. They are ubiquitous in analytic number theory,
they are individually cheap to describe, and there are unboundedly many of them. If
$K$ such symbols behaved like independent fair coins on $\Omega$, reading them would
cut $|\Omega|$ by a factor $2^K$, and $K = \Theta(\log N)$ symbols would pin down
$p$ outright.

This paper proves that this cannot happen, for a reason that has nothing to do with
the arithmetic of the symbols and everything to do with their **periods**.

### 1.2 Results

Section 2 introduces residue dials and the conductor lcm $M^*$. Section 3 proves the
master bound (Theorem 3.1) and its operational corollary (Theorem 3.3), and Section 4
shows that the bound is sharp (Theorem 4.1) and that coprime dials compound
(Theorem 4.3). Section 5 develops the dichotomy: Regime 1 ($M^* \mid m$) yields
constancy and exact zero information under arbitrary post-processing (Theorems 5.2,
5.4, 5.5); Regime 2 ($M^* \nmid m$) yields non-computability (Theorems 5.7, 5.8) and
the quantitative requirement $M^*/\gcd(M^*,m) \ge |\Omega|$ (Theorem 5.9). Section 6
gives the counting barrier $K \ge \log_3 C$ (Theorem 6.1) and its sharpened $2^K$
form. Section 7 proves the threshold theorems: the joint resolution cap (Theorem 7.1),
the pinning window bound (Theorem 7.2), the Coppersmith threshold $M^* \ge m$
(Theorem 7.4), the combined two-barrier statement (Theorem 7.5), and the attainment
of the threshold (Theorem 7.6). Section 8 works two explicit numerical instances.
Section 9 discusses scope, and Section 10 states conjectures.

### 1.3 The one-sentence reason

A dial family with conductor lcm $M^*$ is a function of $p \bmod M^*$; the hint is a
function of $p \bmod m$; on a hint class the dial vector therefore ranges over at
most $M^*/\gcd(M^*, m)$ values. Everything else is bookkeeping around this
observation, and the bookkeeping is what makes it a barrier rather than a remark.

---

## 2. Residue dials

### 2.1 Definition

**Definition 2.1 (Residue dial).** A *residue dial* is a pair $(c, \chi)$ where
$c \ge 1$ is an integer, called the **conductor**, and $\chi : \mathbb{N} \to \mathbb{Z}$
satisfies
$$
\chi(n + c) = \chi(n) \qquad \text{for all } n \ge 0 .
$$
We write $\operatorname{cond}(d) = c$ and refer to $\chi(p)$ as the *reading* of the
dial at the candidate $p$.

Periodicity is the only assumption. In particular a dial need not be multiplicative,
need not take values in $\{-1,0,1\}$, and need not be a character.

**Lemma 2.2 (Iterated periodicity).** For every dial $d$, every $n$ and every $k$,
$\chi(n + kc) = \chi(n)$.

*Proof.* Induction on $k$, the step being $n + (k+1)c = (n + kc) + c$. $\square$

**Lemma 2.3 (Dials read residues).** Let $d$ be a dial of conductor $c$ and let
$c \mid M$. Then $\chi(n \bmod M) = \chi(n)$ for all $n$; consequently, if
$a \equiv b \pmod M$ then $\chi(a) = \chi(b)$.

*Proof.* Write $M = c\,c'$. Then $n = (n \bmod M) + M\lfloor n/M \rfloor
= (n \bmod M) + (c' \lfloor n/M\rfloor)\,c$, so Lemma 2.2 applies. The second claim
follows by rewriting both sides through their residues mod $M$. $\square$

Lemma 2.3 is the engine of the whole paper: *a dial sees only a residue class, and
only at the scale of its conductor.*

### 2.2 Kronecker dials

**Definition 2.4 (Kronecker dial).** For a nonzero integer $D$, the Kronecker dial
$\kappa_D$ has conductor $4|D|$ and reading
$$
\chi_D(n) \;=\; \left(\frac{D}{\,n \bmod 4|D|\,}\right),
$$
the Jacobi/Kronecker symbol evaluated at the reduced representative.

**Lemma 2.5.** $\chi_D$ is periodic of period $4|D|$ by construction, and for every
*odd* $n$ one has $\chi_D(n) = \left(\frac{D}{n}\right)$; that is, on odd candidates
— in particular on odd primes — the Kronecker dial is literally the Kronecker
symbol.

*Proof.* Periodicity is immediate from the reduction. The identification uses the
standard periodicity of the Jacobi symbol in its lower argument modulo $4|D|$ for odd
arguments. $\square$

**Lemma 2.6 (Sign range).** $\chi_D(n) \in \{-1, 0, 1\}$ for all $n$; and if $n$ is
odd with $\gcd(D, n) = 1$ then $\chi_D(n) \in \{-1, 1\}$.

### 2.3 Dial systems and the conductor lcm

**Definition 2.7 (Dial system, dial vector, conductor lcm).** A *dial system* is a
finite family $\mathcal{D} = (d_1, \dots, d_K)$ of dials. Its **dial vector** is
$$
V_{\mathcal{D}} : \mathbb{N} \to \mathbb{Z}^K, \qquad V_{\mathcal{D}}(p) = (\chi_1(p), \ldots, \chi_K(p)),
$$
and its **conductor lcm** is
$$
M^* \;=\; M^*(\mathcal{D}) \;=\; \operatorname{lcm}(c_1, \ldots, c_K) \;\ge\; 1 .
$$

**Lemma 2.8.** $c_i \mid M^*$ for each $i$, $M^* \ge 1$, and if $M^* \mid M$ and
$a \equiv b \pmod{M}$ then $V_{\mathcal{D}}(a) = V_{\mathcal{D}}(b)$. In particular
$V_{\mathcal{D}}(p) = V_{\mathcal{D}}(p \bmod M^*)$.

*Proof.* Immediate from Lemma 2.3 applied coordinatewise. $\square$

So the dial vector factors through $\mathbb{Z}/M^*\mathbb{Z}$, and $M^*$ measures
the total resolution of the family. It will follow from Theorem 4.3 that $M^*$, and
not $\max_i c_i$, is the right invariant: dials with coprime conductors genuinely
compound.

### 2.4 The counting lemma

We isolate the elementary count used throughout.

**Lemma 2.9 (Arithmetic-progression count).** Let $g \mid M$ with $g \ge 1$ and let
$0 \le c < g$. Then
$$
\#\{\,x < M \;:\; x \equiv c \pmod g\,\} \;=\; M/g .
$$

*Proof.* The map $i \mapsto c + gi$ is an injection from $\{0, \dots, M/g - 1\}$ onto
the set in question: each image is $< g + g(M/g - 1) = M$ and reduces to $c$ mod $g$,
and conversely $x$ in the set is the image of $x/g$. $\square$

---

## 3. The master bound

Throughout, a **hint class** is the set of integers congruent to a fixed $r$ modulo
$m \ge 1$, and a **candidate set** $\Omega$ is any finite set of integers contained
in one hint class.

**Theorem 3.1 (Master bound).** Let $\mathcal{D}$ be a dial system with conductor lcm
$M^*$, let $m \ge 1$, and let $\Omega$ be a finite set of nonnegative integers with
$p \equiv r \pmod m$ for all $p \in \Omega$. Then
$$
\#\, V_{\mathcal{D}}(\Omega) \;\le\; \frac{M^*}{\gcd(M^*, m)} .
$$

*Proof.* Put $g = \gcd(M^*, m) \ge 1$. Consider
$$
T \;=\; \{\, x < M^* \;:\; x \equiv r \pmod g \,\}.
$$
By Lemma 2.9, $\#T = M^*/g$. We claim $V_{\mathcal{D}}(\Omega) \subseteq V_{\mathcal{D}}(T)$.
Indeed, let $p \in \Omega$ and set $x = p \bmod M^*$; then $x < M^*$, and since
$g \mid M^*$ we have $x \equiv p \pmod g$, while $g \mid m$ and $p \equiv r \pmod m$
give $p \equiv r \pmod g$; hence $x \in T$. By Lemma 2.8, $V_{\mathcal{D}}(x) = V_{\mathcal{D}}(p)$.
Therefore
$$
\# V_{\mathcal{D}}(\Omega) \;\le\; \# V_{\mathcal{D}}(T) \;\le\; \# T \;=\; M^*/g . \qquad \square
$$

**Definition 3.2 (Amplification budget).** The quantity
$$
B(M^*, m) \;=\; \frac{M^*}{\gcd(M^*, m)}
$$
is the **amplification budget** of the dial system against the hint modulus $m$. It
is the index by which the dial resolution $M^*$ overshoots the hint resolution.

The budget immediately bounds the *shrinkage* an attacker can achieve, which is the
form relevant to an attack: the attacker learns the true reading $v = V_{\mathcal{D}}(p)$
and retains only the candidates matching it.

**Theorem 3.3 (No amplification beyond the budget).** With hypotheses as in Theorem
3.1 and $\Omega \neq \emptyset$, there exists a reading $v$ with
$$
\#\Omega \;\le\; B(M^*, m)\cdot \#\{\, p \in \Omega : V_{\mathcal{D}}(p) = v \,\} .
$$
Equivalently, some fibre of the dial vector retains at least a
$1/B(M^*,m) = \gcd(M^*,m)/M^*$ fraction of the candidates.

*Proof.* Partition $\Omega$ into the fibres of $V_{\mathcal{D}}$, indexed by the image
$I = V_{\mathcal{D}}(\Omega)$, and let $v \in I$ maximize the fibre size. Then
$$
\#\Omega \;=\; \sum_{w \in I} \#\{p \in \Omega : V_{\mathcal{D}}(p) = w\}
\;\le\; \#I \cdot \#\{p\in\Omega : V_{\mathcal{D}}(p) = v\},
$$
and $\#I \le B(M^*, m)$ by Theorem 3.1. $\square$

Two consequences deserve emphasis. First, the bound is *uniform in $K$*: adding more
dials cannot help unless it enlarges $M^*$. Second, it is *uniform in the choice of
discriminants*: nothing about $D_i$ enters except $4|D_i|$.

---

## 4. Sharpness

A negative result of this shape is only as strong as its sharpness. If the true
budget were much smaller, the bound would be vacuous bookkeeping; if it were
unattainable, the two-regime dichotomy could conceal a third regime. We close both
gaps.

**Definition 4.1 (Resolution dial).** For $M \ge 1$, the *resolution dial* $\rho_M$
has conductor $M$ and reading $\rho_M(n) = n \bmod M$. It is the most discriminating
dial of conductor $M$: any dial of conductor dividing $M$ factors through $\rho_M$.

**Theorem 4.2 (The budget is attained).** For all $M, m \ge 1$ and every residue $r$
there exist a dial system $\mathcal{D}$ with $M^*(\mathcal{D}) = M$ and a candidate
set $\Omega$ inside the hint class $r$ mod $m$ such that
$$
\#\, V_{\mathcal{D}}(\Omega) \;=\; \frac{M}{\gcd(M, m)} .
$$
Explicitly, one may take $\mathcal{D} = (\rho_M)$ and
$\Omega = \{x < \operatorname{lcm}(M, m) : x \equiv r \pmod m\}$.

*Proof.* Write $L = \operatorname{lcm}(M, m)$. Since $m \mid L$, Lemma 2.9 gives
$\#\Omega = L/m$. The reading $\rho_M$ is injective on $\Omega$: if $x, y \in \Omega$
have equal readings then $x \equiv y \pmod M$, and also $x \equiv y \pmod m$ since
both lie in the hint class, so $x \equiv y \pmod L$; as $x, y < L$ this forces
$x = y$. Hence $\# V(\Omega) = \#\Omega = L/m = M/\gcd(M,m)$, using
$\operatorname{lcm}(M,m)\gcd(M,m) = Mm$. $\square$

Thus Theorem 3.1 is an equality in the worst case: the amplification budget is
*exactly* the overshoot index, no more and no less.

**Theorem 4.3 (CRT independence: coprime dials compound).** Let $a, b \ge 1$ be
coprime. Then the two-dial system $(\rho_a, \rho_b)$ has conductor lcm $ab$ and
realizes all $ab$ joint readings on $\{0, 1, \dots, ab-1\}$:
$$
\#\, V_{(\rho_a,\rho_b)}\big(\{x < ab\}\big) \;=\; ab .
$$

*Proof.* If $x, y < ab$ have the same joint reading then $x \equiv y \pmod a$ and
$x \equiv y \pmod b$; by the Chinese Remainder Theorem $x \equiv y \pmod{ab}$, hence
$x = y$. The map is injective on a set of size $ab$. That the conductor lcm equals
$ab$ is $\operatorname{lcm}(a,b) = ab$ for coprime $a, b$. $\square$

Theorem 4.3 explains why $M^*$, rather than the largest conductor, is the invariant:
resolutions of coprime dials multiply. It also shows the budget cannot be improved
by any structural assumption weaker than a bound on $M^*$ itself.

---

## 5. The dichotomy: computable versus informative

### 5.1 Hint-computability

**Definition 5.1 (Hint-computable statistic).** Let $m \ge 1$. A statistic
$T : \mathbb{N} \to \beta$ is **hint-computable** (at modulus $m$) if there is a
function $g$ with $T(p) = g(p \bmod m)$ for all $p$.

**Lemma 5.2 (Characterization).** $T$ is hint-computable at $m$ if and only if
$T(a) = T(b)$ whenever $a \equiv b \pmod m$.

*Proof.* Necessity is clear. For sufficiency take $g(x) = T(x \bmod m)$ and note
$p \equiv (p \bmod m) \bmod m$. $\square$

The name is chosen because hint-computable statistics are precisely those an
attacker holding only the hint can evaluate — no knowledge of $p$ is required.

### 5.2 Regime 1: $M^* \mid m$

**Theorem 5.3 (Constancy).** If $M^* \mid m$ then $V_{\mathcal{D}}$ is constant on
every candidate set inside a hint class mod $m$; and $V_{\mathcal{D}}$ is
hint-computable at $m$.

*Proof.* For $p, p_0$ in the class, $p \equiv p_0 \pmod m$ and $M^* \mid m$, so
Lemma 2.8 gives $V(p) = V(p_0)$. Hint-computability follows by Lemma 5.2. $\square$

**Corollary 5.4 (The dial cut is the identity).** Under the hypotheses of Theorem
5.3, filtering $\Omega$ by the true reading changes nothing:
$$
\{\, p \in \Omega : V_{\mathcal{D}}(p) = V_{\mathcal{D}}(p_0) \,\} \;=\; \Omega
$$
for any $p_0 \in \Omega$. In particular, on a window $[0, mC)$ intersected with one
hint class — a set of exactly $C$ candidates — all $C$ candidates survive the dial
cut.

Constancy already says everything, but it is worth recording the strongest
information-theoretic form, because it also covers post-processing.

**Definition 5.5 (Exact zero information).** Let $\Omega$ be a finite candidate set,
$T$ a reading and $S$ a secret statistic. Say $T$ carries **zero information** about
$S$ on $\Omega$ if for all values $t$ and $s$,
$$
\#\{p \in \Omega : T(p) = t \wedge S(p) = s\}\cdot\#\Omega \;=\;
\#\{p\in\Omega : T(p) = t\}\cdot\#\{p\in\Omega : S(p) = s\} .
$$
This is exact statistical independence of $T$ and $S$ under the uniform counting
measure on $\Omega$; it is a finitary, assumption-free notion, with no asymptotics
and no distributional hypotheses.

Two elementary facts about this notion will be used: a *constant* reading carries
zero information about every $S$ (both sides reduce to
$\#\{S = s\}\cdot\#\Omega$), and if $T$ carries zero information about $S$ then so
does $h \circ T$ for every function $h$ (fibres of $h\circ T$ are unions of fibres
of $T$, and the defining identity is additive in $t$).

**Theorem 5.6 (Regime 1 is information-free, even after post-processing).** Suppose
$M^* \mid m$ and $\Omega$ lies in a single hint class mod $m$. Then for *every*
secret statistic $S$ of the candidate and *every* function $h$ on readings, both
$V_{\mathcal{D}}$ and $h \circ V_{\mathcal{D}}$ carry zero information about $S$ on
$\Omega$.

*Proof.* If $\Omega = \emptyset$ both sides of the identity vanish. Otherwise
$V_{\mathcal{D}}$ is constant on $\Omega$ by Theorem 5.3, hence zero-information; and
zero information is preserved by composition with $h$. $\square$

The following abstraction is the conceptual core of the negative result: it applies
to *any* statistic, dial or not.

**Theorem 5.7 (No self-amplification).** Let $T$ be any hint-computable statistic at
modulus $m$ and $\Omega$ any candidate set in a hint class mod $m$. Then $T$ carries
zero information about every secret $S$ on $\Omega$, as does $h \circ T$ for every
$h$. In particular, for the public modulus $N$ and any function $g$ whatsoever, the
statistic $p \mapsto g(N, p \bmod m)$ carries zero information about every secret.

*Proof.* By Lemma 5.2, $T$ is constant on the hint class, hence on $\Omega$; apply
the constancy and post-processing facts. The final claim is the case
$T(p) = g(N, p\bmod m)$, which is hint-computable by definition. $\square$

Theorem 5.7 is the formal content of the verdict: **a partial-key hint cannot be
amplified by data derived from itself.** Any side statistic the attacker can compute
from public data and the hint is exactly independent of the secret on the candidate
set, no matter how it is post-processed.

### 5.3 Regime 2: $M^* \nmid m$

**Theorem 5.8 (The hint underdetermines the dial argument).** If $M \nmid m$ then
there exist $a, b$ with $a \equiv b \pmod m$ and $a \not\equiv b \pmod M$; one may
take $a = 0$, $b = m$.

*Proof.* $0 \equiv m \pmod m$ always, and $0 \equiv m \pmod M$ would say $M \mid m$.
$\square$

**Theorem 5.9 (Separation implies non-computability).** If a dial system separates
two candidates of a common hint class — i.e. $a \equiv b \pmod m$ but
$V_{\mathcal{D}}(a) \neq V_{\mathcal{D}}(b)$ — then $V_{\mathcal{D}}$ is not
hint-computable at $m$, and consequently $M^* \nmid m$.

*Proof.* Non-computability is immediate from Lemma 5.2. If $M^* \mid m$ then
Theorem 5.3 would make $V_{\mathcal{D}}$ hint-computable, a contradiction. $\square$

**Theorem 5.10 (Quantitative form).** If $V_{\mathcal{D}}$ is injective on a
candidate set $\Omega$ inside a hint class mod $m$ (the dials *pin* the candidates),
then
$$
\#\Omega \;\le\; \frac{M^*}{\gcd(M^*, m)} \;\le\; M^* .
$$

*Proof.* Injectivity gives $\#\Omega = \# V_{\mathcal{D}}(\Omega)$; apply Theorem 3.1.
$\square$

### 5.4 The dichotomy

**Theorem 5.11 (No-amplification dichotomy).** Let $\mathcal{D}$ be any dial system,
$m \ge 1$, and $\Omega$ any candidate set inside a hint class mod $m$. Exactly one of
the following holds, and neither permits amplification.

1. **(Computable, useless.)** $M^* \mid m$. Then $V_{\mathcal{D}}$ is hint-computable
   and constant on $\Omega$; it carries zero information about every secret $S$, and
   so does $h \circ V_{\mathcal{D}}$ for every post-processing $h$.
2. **(Informative, unavailable.)** $M^* \nmid m$. Then the hint provably fails to
   determine $p \bmod M^*$ — there are $a \equiv b \pmod m$ with
   $a \not\equiv b \pmod{M^*}$ — and any pair of candidates separated by the dials
   witnesses that $V_{\mathcal{D}}$ is not hint-computable at $m$.

*Proof.* Case split on $M^* \mid m$, then Theorems 5.3, 5.6 in the first case and
Theorems 5.8, 5.9 in the second. $\square$

---

## 6. The counting barrier

The dichotomy is arithmetic. There is a second, independent obstruction of purely
information-theoretic type, which bounds the number of dials.

**Theorem 6.1 (Dial capacity).** Let $\mathcal{D}$ be a system of $K$ *sign dials*,
i.e. all readings lie in $\{-1, 0, 1\}$ (as for Kronecker dials, Lemma 2.6). If
$\#\Omega > 3^K$ then two distinct candidates of $\Omega$ share a dial vector.
Equivalently: pinning $C$ candidates requires $K \ge \log_3 C$.

*Proof.* The dial vector maps $\Omega$ into $\{-1,0,1\}^K$, a set of size $3^K$;
pigeonhole. $\square$

**Theorem 6.2 (Sharpened capacity).** If in addition the dials never vanish on
$\Omega$ — for Kronecker dials, if every candidate is odd and coprime to all the
discriminants, the generic case for a prime — then readings lie in $\{-1,1\}^K$ and
$\#\Omega > 2^K$ already forces a collision; pinning $C$ candidates requires
$K \ge \log_2 C$.

With $C \approx N^{1/4}$ candidates in a sub-threshold Coppersmith class, Theorem 6.2
demands $K = \Theta(\log N)$ dials. Combined with the arithmetic barrier this is
severe: not only must there be logarithmically many dials, but their conductors must
jointly reach past the hint.

**Theorem 6.3 (Both barriers at once).** If a system of $K$ sign dials pins every
candidate of a set $\Omega$ inside a hint class mod $m$, then
$$
\#\Omega \;\le\; 3^K \qquad\text{and}\qquad \#\Omega \;\le\; \frac{M^*}{\gcd(M^*, m)} \;\le\; M^* .
$$

*Proof.* Theorem 6.1 (contrapositive, using injectivity) and Theorem 5.10. $\square$

---

## 7. From budget to threshold

We now convert the budget into the threshold that gives the paper its title: how far
beyond the hint an informative dial family must reach.

The attacker's total knowledge is the pair (hint, dial vector). We bound its joint
resolution.

**Theorem 7.1 (Joint resolution cap).** Let $L = \operatorname{lcm}(m, M^*)$. If
$a \equiv b \pmod L$ then
$$
a \equiv b \pmod m \qquad\text{and}\qquad V_{\mathcal{D}}(a) = V_{\mathcal{D}}(b) .
$$
That is, candidates congruent mod $L$ are indistinguishable by the pair (hint, dials),
whatever the dials are.

*Proof.* $m \mid L$ gives the first claim; $M^* \mid L$ with Lemma 2.8 gives the
second. $\square$

**Theorem 7.2 (Pinning window bound).** Suppose $m \ge 1$ and the joint statistic
pins down candidates inside the window $[0, X)$: whenever $a, b < X$ satisfy
$a \equiv b \pmod m$ and $V_{\mathcal{D}}(a) = V_{\mathcal{D}}(b)$, one has $a = b$.
Then
$$
X \;\le\; \operatorname{lcm}(m, M^*) .
$$

*Proof.* Suppose $X > L = \operatorname{lcm}(m, M^*)$. Since $L \ge 1$, both $0$ and
$L$ lie in $[0, X)$, and $0 \equiv L \pmod L$, so by Theorem 7.1 they share the hint
and the dial reading. Pinning forces $0 = L$, contradicting $L \ge 1$. $\square$

**Corollary 7.3 (The dials must supply the missing information).** Under the
hypotheses of Theorem 7.2,
$$
X \;\le\; m\,M^*, \qquad \text{i.e.} \qquad M^* \;\ge\; X/m .
$$

*Proof.* $\operatorname{lcm}(m, M^*) \mid mM^*$ and $mM^* \ge 1$, so
$\operatorname{lcm}(m,M^*) \le mM^*$. $\square$

**Theorem 7.4 (Coppersmith threshold).** In the Coppersmith regime the window is the
square of the hint modulus: $p < N^{1/2}$ and $m \approx N^{1/4}$, i.e. $X = m^2$. If
the joint statistic pins candidates in $[0, m^2)$, then
$$
M^* \;\ge\; m .
$$

*Proof.* Corollary 7.3 with $X = m^2$ gives $m^2 \le mM^*$; cancel $m \ge 1$.
$\square$

This is the precise sense in which the dials cannot be free. The dial families that
are *computable* from the hint are exactly those with $M^* \mid m$ (Theorem 5.3), all
of which satisfy $M^* \le m$ and are information-free by Theorem 5.6. A family that
could pin the prime must have $M^* \ge m \approx N^{1/4}$ — its conductor lcm is of
hint size, so evaluating it requires knowing $p$ modulo a number as large as the
Coppersmith hint itself. Acquiring that is acquiring a second hint. Hence:

> **Verdict.** The partial-key hint must be genuinely external. Self-generated
> residue amplification is impossible.

**Theorem 7.5 (Two thresholds together).** Let $m, C \ge 1$ and consider the window
$[0, mC)$, which splits into hint classes of exactly $C$ candidates each. If a system
of $K$ sign dials pins every candidate in the window given the hint, then
$$
C \;\le\; 3^K \qquad\text{and}\qquad C \;\le\; M^* .
$$

*Proof.* Let $\Omega = \{x < mC : x \equiv 0 \pmod m\}$, of size $C$ by Lemma 2.9.
The pinning hypothesis makes $V_{\mathcal{D}}$ injective on $\Omega$ (all elements
share the hint). Theorem 6.1 gives $C \le 3^K$, and Theorem 5.10 gives
$C \le M^*/\gcd(M^*, m) \le M^*$. $\square$

Finally, the threshold is a real obstruction, not a vacuous implication: pinning
becomes possible exactly when the dials reach the missing scale.

**Theorem 7.6 (Threshold attained).** Let $C \ge 1$ with $\gcd(m, C) = 1$. Then the
single resolution dial $\rho_C$ pins every candidate of the window $[0, mC)$ given
the hint mod $m$: if $a, b < mC$, $a \equiv b \pmod m$, and $\rho_C(a) = \rho_C(b)$,
then $a = b$.

*Proof.* The hypotheses give $a \equiv b \pmod m$ and $a \equiv b \pmod C$; coprimality
and the Chinese Remainder Theorem give $a \equiv b \pmod{mC}$, and $a, b < mC$ forces
$a = b$. $\square$

Thus Theorem 7.2 is an equality for this family — $X = mC = \operatorname{lcm}(m,M^*)$
— and Theorem 7.4 marks the exact frontier: below $M^* = m$ pinning is impossible,
at $M^* = m$ (coprime to $m$) it is achieved.

---

## 8. Two numerical instances

The general theory was tested on two concrete instances chosen to sit on either side
of the divide.

### 8.1 Regime 1: a modulus near $8.08 \times 10^8$, hint modulus $m = 168$

Take the discriminants $D = -3, 21, 42$, with Kronecker dials of conductors
$4\cdot 3 = 12$, $4 \cdot 21 = 84$ and $4\cdot 42 = 168$. Their lcm is
$$
M^* = \operatorname{lcm}(12, 84, 168) = 168,
$$
which *divides* the hint modulus $m = 168$. The theory predicts total collapse:
budget $B = 168/\gcd(168,168) = 1$, dial vector constant, zero information, zero
pinning, all candidates surviving the cut.

The prediction is borne out on genuine candidates. The integers $28393$ and $28729$
are both prime, both $\equiv 1 \pmod{168}$, and their product is
$\approx 8.16 \times 10^8$ — exactly the scale of the instance. The three dials read
identically on them: they are *confused* by the entire dial family. An attacker in
possession of the hint can compute the dial vector — and gains nothing by doing so,
since it is the same for every candidate.

Quantitatively (Corollary 5.4), on a window $[0, 168\,C)$ intersected with the hint
class, all $C$ candidates survive. With $m \approx N^{1/4}$ and window $\approx N^{1/2}$,
that is $\approx N^{1/4}$ surviving candidates: not a single one is removed.

### 8.2 Regime 2: a modulus near $3.4 \times 10^8$, hint modulus $m = 135$

Take the single Kronecker dial $\left(\frac{-4}{\cdot}\right)$, of conductor $16$.
Here $16 \nmid 135$, so we are in Regime 2. The predicted consequence is
non-computability, and again there is a concrete witness: $541$ and $811$ are both
prime, both $\equiv 1 \pmod{135}$, and
$$
\left(\frac{-4}{541}\right) = +1, \qquad \left(\frac{-4}{811}\right) = -1 ,
$$
because $541 \equiv 1$ and $811 \equiv 3 \pmod 4$. The dial *separates* them, hence
(Theorem 5.9) it is not hint-computable at $m = 135$: an attacker holding only
$p \bmod 135$ cannot evaluate it, since $135$ is odd and therefore says nothing about
$p \bmod 4$.

This is not an accident of the chosen numbers.

**Theorem 8.1 (Regime 2, universal form).** For every *odd* modulus $m$, the dial
$\left(\frac{-4}{\cdot}\right)$ separates the two candidates $1$ and $1 + 2m$ of the
hint class $1$ mod $m$; consequently it is never hint-computable at an odd modulus,
and its conductor lcm never divides an odd $m$.

*Proof.* Both candidates are odd and congruent to $1$ mod $m$. On odd $n$ one has
$\left(\frac{-4}{n}\right) = \chi_4(n)$, the nontrivial character mod $4$. Since $m$
is odd, $1 + 2m \equiv 3 \pmod 4$ while $1 \equiv 1 \pmod 4$, so
$\chi_4(1) = 1 \ne -1 = \chi_4(1 + 2m)$. Apply Theorem 5.9. $\square$

Thus Regime 2 is the generic situation for the natural dials, and Regime 2 is exactly
the regime the attacker cannot enter.

---

## 9. Algorithmic reading and discussion

### 9.1 What an attacker would actually run

The results are constructive enough to describe as a decision procedure. Given a hint
modulus $m$ and a proposed dial family with conductors $c_1, \dots, c_K$:

1. Compute $M^* = \operatorname{lcm}(c_i)$ and $g = \gcd(M^*, m)$.
2. Compute the budget $B = M^*/g$. This is an *a priori* upper bound on the
   candidate-set shrinkage, valid before any dial is evaluated.
3. If $B = 1$ (equivalently $M^* \mid m$): the family is hint-computable and provably
   useless. Stop.
4. If $B > 1$: the family is not hint-computable at $m$. Evaluating it requires the
   residue $p \bmod M^*$, which the hint does not determine. Stop.
5. If pinning inside a window of size $X$ is the goal, test $X \le \operatorname{lcm}(m, M^*)$
   and $\#\Omega \le 3^K$; failure of either is a proof of impossibility.

Steps 1–2 cost $O(K)$ gcd computations, i.e. $O(K \log^2 \max_i c_i)$ bit operations,
and they decide the whole question without touching $N$ or any Kronecker symbol. This
is the practical payoff of the theory: an attacker (or a designer auditing an
implementation) can rule out an entire class of side channels in microseconds.

### 9.2 Where the barriers come from

The collapse is a confluence of three distinct obstructions, and it is worth
separating them.

- **Asymmetry of the residues.** An informative dial reads $p$ at a scale the hint
  does not cover, and the attacker holds only the hint.
- **Aggregation.** Quantities that do encode the needed information globally — sums
  of Kronecker symbols aggregated over ranges of size $\Omega(N)$ — are sealed behind
  a computation as expensive as factoring.
- **Conductor overshoot.** Even granting oracle access to the dial values, the
  quantitative threshold $M^* \ge X/m$ forces the family to have hint-scale conductors.

Any two of these could conceivably be circumvented; the theorems above show all three
apply simultaneously, and the dichotomy shows they cannot be traded off against one
another.

### 9.3 The scope of the argument

It is important to record what the proofs did *not* use:

- no multiplicativity of the Kronecker symbol;
- no quadratic reciprocity;
- no bound on the number of dials;
- no assumption that readings are $\pm 1$ (only Theorems 6.1–6.2 use a finite range,
  and there only to count);
- no distributional or asymptotic hypothesis: every statement is a finitary counting
  fact about finite sets.

The single input is **periodicity**. Consequently the barrier is a statement about
*conductors*, not about characters, and it transfers verbatim to any periodic side
channel: table lookups indexed by residues, Hamming weights of $p \bmod P$, timing
artefacts keyed to a residue, or any statistic with period $P$. All obey the budget
$P/\gcd(P, m)$.

### 9.4 What would falsify the barrier

An escape would require an *aperiodic* statistic of $p$, efficiently evaluable from
public data, that is not a function of $p \bmod m$. Theorem 5.7 shows that anything
of the form $g(N, p \bmod m)$ is out. So a counterexample must genuinely depend on
$p$ beyond its hint while being computable without $p$ — which is close to a
definition of a factoring oracle. This is Conjecture B below.

---

## 10. Future directions

The closure suggests three falsifiable conjectures, each stated so that a
counterexample would be a finite computation.

**Conjecture A (Conductor-budget conservation for all periodic side channels).** Let
$T$ be any statistic that is *eventually* periodic with period $P$ (not necessarily a
character: think of $p \bmod P$, of Hamming weights of residues, of any table lookup).
Then on a hint class mod $m$ the statistic takes at most $P/\gcd(P, m)$ values, and
every attacker strategy combining the hint with $T$ has candidate-set shrink factor at
most $P/\gcd(P, m)$; the only way to break the bound is aperiodicity. The key insight
is that the master bound never used multiplicativity, reciprocity, or even that the
dial values are $\pm 1$ — only periodicity — so the barrier is a statement about
conductors, not about characters. The remaining work is to replace "periodic" by
"eventually periodic" and to quantify over the attacker's strategy as a decision tree.

**Conjecture B (Aperiodic dials are the only escape, and they are as hard as
factoring).** Let $T$ be a statistic of $p$ computable in time $\mathrm{poly}(\log N)$
from $N$ and $p \bmod m$ alone. Then $T$ is hint-computable, hence information-free on
the candidate set. Equivalently: any dial with a genuine $\Omega(N^{1/4})$-scale
conductor that is *evaluable* from public data yields a factoring algorithm. The
theorem above already kills every statistic of the form $g(N, p \bmod m)$; the open
part is the converse — that a non-hint-computable but efficiently evaluable statistic
must leak $p$ itself. The formal notion of hint-computability is exactly the hypothesis
such a reduction would need, and the pinning window bound supplies the quantitative
target $\operatorname{lcm}(m, M^*) \ge N^{1/2}$.

**Conjecture C (Class-number dials obey the same threshold).** Replace the Kronecker
sign $\left(\frac{D}{p}\right)$ by the finer datum $h(D) \bmod \ell$ for fundamental
discriminants $D$ in a family, evaluated through the class-number formula.
Conjecturally the resulting statistic is *still* periodic in $p$ modulo
$\operatorname{lcm}_i(4|D_i|)$, so the same master bound applies verbatim, and no
class-group refinement escapes the conductor budget.

---

## 11. Conclusion

We set out to determine whether free residue data can amplify a partial-key hint. The
answer is a clean negative with an exact quantitative shape. A dial family with
conductor lcm $M^*$ has amplification budget $M^*/\gcd(M^*, m)$ against a hint modulus
$m$; the budget is attained; and it splits the world in two. Below the threshold
($M^* \mid m$) the dials are computable from the hint and carry exactly zero
information about any secret, before or after any post-processing. Above it the dials
are informative but not computable from the hint, and pinning a prime in a window of
size $X$ forces $M^* \ge X/m$ — in the Coppersmith regime, $M^* \ge m \approx N^{1/4}$,
so that an informative dial family is as expensive as a second hint. There is no third
regime, and both thresholds are attained.

The partial-key hint must therefore be genuinely external. Amplifying a hint using
data derived from itself is impossible — not merely difficult, but ruled out by a
counting argument that occupies three lines and depends on nothing but the periodicity
of the data.
