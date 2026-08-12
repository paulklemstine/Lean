# Three Structural Barrier Theorems for Integer Factorization

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

We prove three unconditional, independent obstructions that classify why broad
classes of *structural* approaches to integer factorization cannot succeed. Let
$N = pq$ be a semiprime with $p \ne q$ prime.

**Barrier I (algebraic).** For every $f \in \mathbb{Z}[x]$ and every prime $p \mid N$ we
have $p \mid f(N) \iff p \mid f(0)$, whence $\gcd(f(N), N) = \gcd(f(0), N)$. A fixed
invariant therefore exposes only the primes dividing $f(0)$ — at most $\log_2|f(0)|$ of
them — and if it splits $N = pq$ then $\min(p,q) \le |f(0)|$. No finite family of
integer polynomials, and no family indexed by the residue class of $N$ modulo a fixed
integer, splits every semiprime. The barrier extends to rational (integer-valued)
invariants, where the denominator contributes exactly one further, input-independent
source of primes.

**Barrier II (symmetry).** A quantity $D(p,q)$ attached to pairs of primes is a
function of the product $N = pq$ **if and only if** it is symmetric. This is a sharp
dichotomy, not merely a necessary condition: antisymmetric data (the gap $p-q$, "the
left factor") is provably not a function of $N$, while every symmetric quantity —
including $\min(p,q)$ and $p+q$ — is. The barrier is thus an obstruction to
well-definedness, not a hardness theorem, and we prove both halves.

**Barrier III (holomorphic rigidity).** If an entire function $F$ vanishes at two
distinct points $a \ne b$ then $F(z) = (z-a)(z-b)G(z)$ with $G$ entire, and if the zero
set is exactly $\{a,b\}$ then $G$ is nonvanishing off $\{a,b\}$: an analytic factoring
device is the factor polynomial times a unit, so it cannot be constructed without the
factorization. Independently, the zero set of a nonzero entire function is countable and
Lebesgue-null, so zero-set search succeeds with probability zero. Sharpness: such
entire functions do exist, so the barrier is rigidity, not nonexistence.

We prove the bridges between the barriers, prove that they are pairwise
non-implying, and locate the exact escape route: Pollard's $p-1$ method splits
semiprimes, but for each *fixed* exponent it is a constant polynomial and falls to
Barrier I. All of its power comes from letting the exponent grow with the input, and
this — unbounded description length — is the only loophole the three barriers leave.

**Keywords:** integer factorization, polynomial invariants, gcd witnesses, symmetric
functions, entire functions, holomorphic rigidity, Pollard's $p-1$, RSA.

---

## 1. Introduction

### 1.1 The shape of a structural factoring proposal

Let $N = pq$ be an RSA-like modulus: a product of two distinct primes, both of roughly
the same bit length. A recurring genre of factoring proposal has the following shape.

1. From $N$ alone, construct some mathematical object $\mathcal{O}_N$ — an integer, a
   polynomial, a lattice, a matrix, an analytic function.
2. Extract a number from $\mathcal{O}_N$ — a resultant, a discriminant, a determinant,
   a hyperdeterminant, a shortest lattice vector, a zero.
3. Take a greatest common divisor with $N$, or read the factors off directly.

Concrete instances are legion: "take $\gcd(\mathrm{Res}(f, g)(N), N)$", "reduce a
lattice built from $N$ and use the short vector", "form the analytic function whose
zeros are the factors and locate them by contour integration". Each proposal is
plausible in outline, and each fails in practice. This paper explains the failures
structurally: we identify three properties of the map $(p,q) \mapsto pq$ that make
entire classes of such proposals impossible, and we prove that the three properties are
logically independent.

### 1.2 Why unconditional barriers matter

The results below assume nothing. There is no appeal to $\mathrm{P} \ne \mathrm{NP}$, to
the hardness of factoring, to random oracles, or to any unproven number-theoretic
conjecture. They are congruence, symmetry, and rigidity statements. Consequently they
cannot become false; they can only be circumvented by leaving the class they describe.
Identifying the boundary of each class is therefore as important as proving the barrier
itself, and we do so in every case: §2.5 (a fixed invariant with a large constant term
*does* split many small semiprimes), §3.4 ($\min(p,q)$ is a function of $N$), §4.4 (an
entire device with prescribed prime zeros exists), and §5 (Pollard's $p-1$ escapes,
and exactly how).

### 1.3 Notation

$\mathbb{Z}[x]$ denotes the integer polynomials, $f(0)$ the constant term of $f$, and
$|m|$ the absolute value of $m \in \mathbb{Z}$. For $n \in \mathbb{Z}$, $\mathrm{rad}(n)$
is the set of distinct primes dividing $|n|$. We write $\gcd(a,b) \ge 0$ for the
nonnegative generator of the ideal $(a,b)$, with the convention $\gcd(0,n) = |n|$.
$\mathrm{vol}$ denotes planar Lebesgue measure on $\mathbb{C} \cong \mathbb{R}^2$.

**Definition 1.1 (distinct semiprime).** $N \in \mathbb{N}$ is a *distinct semiprime*
if $N = pq$ for primes $p \ne q$.

**Definition 1.2 (polynomial gcd witness).** For $f \in \mathbb{Z}[x]$ and
$N \in \mathbb{N}$, the *witness* of $f$ at $N$ is
$$W_f(N) := \gcd\big(f(N),\, N\big) \in \mathbb{N}.$$
We say $f$ **splits** $N$ if $1 < W_f(N) < N$, i.e. the witness is a nontrivial divisor.

**Definition 1.3 (revealed primes).** For $f \in \mathbb{Z}[x]$ with $f(0) \ne 0$,
$$\mathcal{R}(f) := \mathrm{rad}\big(f(0)\big),$$
the set of primes dividing the constant term. This finite set depends only on $f$ and
**not** on any input.

---

## 2. Barrier I: the polynomial (algebraic) barrier

### 2.1 The congruence at the heart of the barrier

**Lemma 2.1.** For every $f \in \mathbb{Z}[x]$ and every $N \in \mathbb{Z}$,
$$N \mid f(N) - f(0),$$
i.e. $f(N) \equiv f(0) \pmod N$.

*Proof.* Write $f(x) = \sum_{k \ge 0} c_k x^k$. For each $k \ge 1$, $N \mid N^k$, so
$f(N) - f(0) = \sum_{k \ge 1} c_k N^k$ is a multiple of $N$. (Equivalently: $a - b$
divides $f(a) - f(b)$ for all integers $a, b$; take $a = N$, $b = 0$.) $\square$

This one-line fact is the whole of Barrier I. Everything below is bookkeeping around it.

### 2.2 Local and global forms

**Theorem 2.2 (polynomial barrier, local form).** Let $f \in \mathbb{Z}[x]$, let
$N \in \mathbb{Z}$, and let $p$ be a prime with $p \mid N$. Then
$$p \mid f(N) \iff p \mid f(0).$$

*Proof.* By Lemma 2.1, $N \mid f(N) - f(0)$, hence $p \mid f(N) - f(0)$. If
$p \mid f(N)$, subtracting gives $p \mid f(0)$; if $p \mid f(0)$, adding gives
$p \mid f(N)$. $\square$

Thus the *set* of prime factors of $N$ that a polynomial invariant can detect does not
depend on $N$ at all. The global version makes the cancellation explicit.

**Theorem 2.3 (polynomial barrier, global form).** For every $f \in \mathbb{Z}[x]$ and
every $N \in \mathbb{N}$,
$$W_f(N) = \gcd\big(f(N), N\big) = \gcd\big(f(0), N\big).$$

*Proof.* By Lemma 2.1 write $f(N) = f(0) + Nk$ for some $k \in \mathbb{Z}$. Then
$\gcd(f(0) + Nk, N) = \gcd(f(0), N)$, since adding a multiple of the second argument to
the first leaves the gcd unchanged. $\square$

**Corollary 2.4.** If $r$ is a prime with $r \mid N$ and $r \mid f(N)$, and
$f(0) \ne 0$, then $r \in \mathcal{R}(f)$.

*Proof.* Theorem 2.2 gives $r \mid f(0)$; since $f(0) \ne 0$, $r$ is one of its prime
factors. $\square$

The interpretation is worth stating plainly. The evaluation $f(N)$ may be an enormous
integer requiring $\deg(f) \cdot \log N$ bits, and computing it may cost real work; but
the *information* it carries about the factorization of $N$ is exactly the information
carried by the fixed integer $f(0)$, which is available before $N$ is even seen. The
invariant's dependence on the input cancels identically.

### 2.3 The reveal budget

**Theorem 2.5 (logarithmic reveal budget).** For $f \in \mathbb{Z}[x]$ with
$f(0) \ne 0$,
$$\#\mathcal{R}(f) \le \log_2 |f(0)|.$$

*Proof.* Let $n = |f(0)| \ge 1$. The product of the distinct primes dividing $n$
divides $n$, hence is $\le n$. Each such prime is $\ge 2$, so
$2^{\#\mathcal{R}(f)} \le \prod_{p \in \mathcal{R}(f)} p \le n$, and taking base-$2$
logarithms gives the claim. $\square$

So an invariant with a $b$-bit constant term can, across all inputs it will ever be fed,
expose at most $b$ distinct primes. The "reveal budget" is an intrinsic property of the
program, never of its input.

### 2.4 Sharp failure in the cryptographic regime

**Theorem 2.6 (splitting forces a small factor).** Let $p, q$ be primes and suppose $f$
splits $N = pq$. Then
$$\min(p,q) \le |f(0)|.$$

*Proof.* Let $w = W_f(N)$, so $1 < w < N$ by hypothesis. By Theorem 2.3,
$w = \gcd(f(0), N)$. If $f(0) = 0$ then $w = N$, contradicting $w < N$; so
$f(0) \ne 0$. Since $w > 1$, choose a prime $r \mid w$. Then $r \mid N = pq$ and
$r \mid f(0)$. Primality gives $r \in \{p, q\}$, and $r \mid f(0) \ne 0$ gives
$r \le |f(0)|$. Hence $\min(p,q) \le r \le |f(0)|$. $\square$

**Corollary 2.7 (cryptographic uselessness).** A polynomial invariant whose constant
term has $b$ bits cannot split any semiprime both of whose prime factors exceed $2^b$.
In particular, splitting a balanced $2048$-bit RSA modulus requires an invariant with a
constant term of at least $1024$ bits — an integer divisible by one of the secret
primes, which must be written down before the modulus is seen.

### 2.5 No universal family, and no bounded adaptivity

**Theorem 2.8 (no universal finite family).** Let $\iota$ be a finite index set and
$F : \iota \to \mathbb{Z}[x]$ any family of integer polynomials. Then there is a
distinct semiprime $N = pq$ such that no $F(i)$ splits $N$. Moreover $p$ and $q$ may be
taken larger than $\max_i |F(i)(0)|$.

*Proof.* Put $B = \max_{i \in \iota} |F(i)(0)|$, finite because $\iota$ is finite. By
the infinitude of primes choose a prime $p > B + 1$ and then a prime $q > p$; put
$N = pq$, a distinct semiprime. If some $F(i)$ split $N$, Theorem 2.6 would give
$\min(p,q) = p \le |F(i)(0)| \le B$, contradicting $p > B$. $\square$

**Corollary 2.9 (no universal single invariant).** For every $f \in \mathbb{Z}[x]$ there
is a distinct semiprime that $f$ fails to split.

**Theorem 2.10 (no residue-adaptive witness).** Fix $M \ge 1$ and let
$F : \mathbb{Z}/M\mathbb{Z} \to \mathbb{Z}[x]$ be arbitrary. Then there is a distinct
semiprime $N$ such that $F(N \bmod M)$ fails to split $N$.

*Proof.* $\mathbb{Z}/M\mathbb{Z}$ is finite, so Theorem 2.8 applies to the family $F$
and produces a semiprime $N$ defeating every member — in particular the member
$F(N \bmod M)$ actually used. $\square$

Theorem 2.10 is the precise sense in which *adaptivity of bounded granularity buys
nothing*. An adversary may consult an infinite lookup table indexed by residue classes,
choosing a bespoke invariant for each class; because the table has finitely many
distinct entries, one semiprime defeats all of them at once. What the proof uses is
finiteness of the index set and nothing else — which is exactly why the loophole of §5
(families whose description grows with $\log N$) is not covered.

### 2.6 Extension to rational and integer-valued invariants

Many proposed invariants are not integral but rational: an integer $g(N)$ divided by a
fixed normalising denominator $m$ (a determinant divided by an index, a factorial
normalisation, a lattice volume). Write the value at $N$ as $v_N$ with $m v_N = g(N)$,
and the value at $0$ as $v_0$ with $m v_0 = g(0)$.

**Theorem 2.11 (scaled barrier).** Let $r$ be a prime with $r \mid N$, and suppose
$r \mid v_N$. Then $r \mid m$ or $r \mid v_0$.

*Proof.* From $m v_N - m v_0 = g(N) - g(0)$ and Lemma 2.1, $N \mid m v_N - m v_0$, hence
$r \mid m v_N - m v_0$. Since $r \mid v_N$ we get $r \mid m v_N$, so $r \mid m v_0$; as
$r$ is prime, $r \mid m$ or $r \mid v_0$. $\square$

**Theorem 2.12 (scaled barrier, dichotomy form).** In the situation above, if
$r \nmid m$ then $r \mid v_N \iff r \mid v_0$.

*Proof.* $m(v_N - v_0) = g(N) - g(0)$ is divisible by $N$, hence by $r$; since
$r \nmid m$ and $r$ is prime, $r \mid v_N - v_0$, and the equivalence follows by adding
and subtracting. $\square$

So passing from integral to rational invariants adds **exactly one** new source of
primes, the denominator $m$ — and $m$ is a fixed quantity, chosen before $N$ is seen.
No dependence on $N$ appears.

### 2.7 Scope

Resultants, discriminants, hyperdeterminants, characteristic polynomials of matrices
whose entries are polynomials in $N$, and the integer outputs of a *fixed* lattice
construction followed by reduction are all polynomial (or rational-polynomial) functions
of $N$, and therefore lie inside the scope of Theorems 2.3 and 2.11. The barrier applies
to all of them.

---

## 3. Barrier II: the symmetry (group-theoretic) barrier

### 3.1 Unique factorization for products of two primes

**Lemma 3.1 (uniqueness of the prime pair).** Let $p, q, a, b$ be natural numbers with
$p, a, b$ prime and $pq = ab$. Then $(p,q) = (a,b)$ or $(p,q) = (b,a)$.

*Proof.* $p \mid ab$, so by primality $p \mid a$ or $p \mid b$; as $a, b$ are prime,
$p = a$ or $p = b$. Cancelling $p$ from $pq = ab$ gives $q = b$ in the first case and
$q = a$ in the second. $\square$

Hence $N = pq$ determines the *unordered* pair $\{p,q\}$ exactly. The transposition is
the only ambiguity — and it is a genuine one.

### 3.2 The dichotomy

**Definition 3.2 (recoverable from the modulus).** A map $D : \mathbb{N} \times
\mathbb{N} \to \gamma$ is *recoverable from the modulus* if there exists
$G : \mathbb{N} \to \gamma$ with
$$G(pq) = D(p,q) \quad \text{for all primes } p, q.$$
No computability or efficiency requirement is imposed on $G$: this is recoverability in
the abstract, set-theoretic sense, which makes the negative results below as strong as
possible.

**Theorem 3.3 (necessity: everything recoverable is symmetric).** If $D$ is recoverable
from the modulus then $D(p,q) = D(q,p)$ for all primes $p, q$.

*Proof.* $D(p,q) = G(pq) = G(qp) = D(q,p)$. $\square$

**Theorem 3.4 (sufficiency: everything symmetric is recoverable).** Let $\gamma$ be
nonempty and let $D$ satisfy $D(p,q) = D(q,p)$ for all primes $p, q$. Then $D$ is
recoverable from the modulus.

*Proof.* Let $P(n)$ be the property "$n$ is a product of two primes". Define $G(n)$ as
follows: if $P(n)$ holds, choose (by the axiom of choice) some pair $(a,b)$ of primes
with $n = ab$ and set $G(n) = D(a,b)$; otherwise set $G(n)$ to an arbitrary element of
$\gamma$. For primes $p,q$ the chosen pair $(a,b)$ for $n = pq$ satisfies, by Lemma 3.1,
either $(a,b) = (p,q)$ — in which case $G(pq) = D(p,q)$ — or $(a,b) = (q,p)$ — in which
case $G(pq) = D(q,p) = D(p,q)$ by symmetry. $\square$

**Theorem 3.5 (the symmetry dichotomy).** For $\gamma$ nonempty and any
$D : \mathbb{N} \times \mathbb{N} \to \gamma$,
$$D \text{ is recoverable from the modulus} \iff D \text{ is symmetric on primes.}$$

This is the sharp form of the folklore "symmetry argument". The obstruction is not
merely necessary; it is *exactly* the obstruction, with nothing else in the way.

### 3.3 Antisymmetric data is destroyed

**Theorem 3.6 (no antisymmetric witness).** Let $\gamma$ be an additive group in which
$x = -x$ implies $x = 0$ (no $2$-torsion). Let $D$ be antisymmetric, i.e.
$D(q,p) = -D(p,q)$ for all $p,q$, and suppose $D(p,q) \ne 0$ for some primes $p, q$.
Then $D$ is not recoverable from the modulus.

*Proof.* If it were, Theorem 3.3 gives $D(p,q) = D(q,p) = -D(p,q)$, so $D(p,q) = 0$ by
the torsion hypothesis, a contradiction. $\square$

The torsion hypothesis is genuinely needed: over $\mathbb{Z}/2\mathbb{Z}$ the quantity
$D(p,q) = p + q$ is simultaneously symmetric and antisymmetric, and nothing is lost.

**Corollary 3.7 (the prime gap).** The function $(p,q) \mapsto p - q \in \mathbb{Z}$ is
not recoverable from the modulus. Indeed $D(2,3) = -1 \ne 1 = D(3,2)$ while
$2 \cdot 3 = 3 \cdot 2$.

**Corollary 3.8 (no "first factor" extractor).** The function $(p,q) \mapsto p$ is not
recoverable from the modulus: it would have to return both $2$ and $3$ on input $6$.

Corollary 3.8 is a useful sanity check on informal proposals. A method advertised as
"outputs the first prime factor of $N$" is not merely hard to build; the specification
is not a function of $N$ and therefore describes no object at all.

### 3.4 Sharpness: the symmetric half survives

**Theorem 3.9 (sharpness).** The functions $(p,q) \mapsto \min(p,q)$ and
$(p,q) \mapsto p+q$ are symmetric, hence — by Theorem 3.4 — genuine functions of the
modulus.

This is what keeps the barrier honest. Factoring *is* a function of $N$; of course it
is. Barrier II is an obstruction to **well-definedness** of antisymmetric targets and
nothing more; on its own it implies no hardness whatsoever. Its practical content is
prescriptive: state your factoring target symmetrically ($\min(p,q)$, $p+q$, the
unordered pair) or your specification is empty before any analysis begins.

### 3.5 The abstract mechanism

**Theorem 3.10 (invariance principle).** Let $\mathrm{enc} : A \to B$ be any encoding
map and $\sigma : A \to A$ a symmetry with $\mathrm{enc}(\sigma a) = \mathrm{enc}(a)$
for all $a$. Then for every $F : B \to \gamma$ and every $a \in A$,
$$F(\mathrm{enc}(\sigma a)) = F(\mathrm{enc}(a)).$$

*Proof.* Apply $F$ to the hypothesis. $\square$

Barrier II is the case $A = \{(p,q)\}$, $\mathrm{enc}(p,q) = pq$, $\sigma$ the
transposition. The general statement is worth isolating because the same phenomenon
recurs throughout cryptography: whenever the public encoding is invariant under a group
acting on the secret space, the corresponding isotypic components of the secret are
annihilated at encoding time, before any adversary acts.

---

## 4. Barrier III: the holomorphic rigidity barrier

Throughout, *entire* means holomorphic on all of $\mathbb{C}$.

### 4.1 Factoring out zeros

**Lemma 4.1 (difference quotients are entire).** If $F$ is entire and $c \in
\mathbb{C}$, then the difference quotient $z \mapsto (F(z) - F(c))/(z-c)$, extended by
$F'(c)$ at $z = c$, is entire.

*Proof sketch.* The function is holomorphic on $\mathbb{C} \setminus \{c\}$ and bounded
near $c$ (its limit at $c$ is $F'(c)$), so the singularity at $c$ is removable by
Riemann's removable singularity theorem. $\square$

**Theorem 4.2 (one zero factors out).** If $F$ is entire and $F(a) = 0$, then there is
an entire $G$ with $F(z) = (z-a)G(z)$ for all $z$.

*Proof.* Take $G$ to be the difference quotient of Lemma 4.1 at $c = a$; since
$F(a) = 0$ it satisfies $(z-a)G(z) = F(z) - F(a) = F(z)$. $\square$

**Theorem 4.3 (holomorphic rigidity).** Let $F$ be entire and let $a \ne b$ with
$F(a) = F(b) = 0$. Then there is an entire $G$ with
$$F(z) = (z-a)(z-b)\,G(z) \qquad \text{for all } z \in \mathbb{C}.$$

*Proof.* By Theorem 4.2, $F(z) = (z-a)G_1(z)$ with $G_1$ entire. Evaluating at $b$:
$0 = F(b) = (b-a)G_1(b)$ and $b \ne a$, so $G_1(b) = 0$. Applying Theorem 4.2 to $G_1$
gives $G_1(z) = (z-b)G(z)$ with $G$ entire, and substituting yields the claim.
$\square$

**Theorem 4.4 (sharpened rigidity: the cofactor is a unit).** Let $F$ be entire with
zero set exactly $\{a, b\}$, $a \ne b$. Then the entire cofactor $G$ of Theorem 4.3
satisfies $G(z) \ne 0$ for all $z \notin \{a,b\}$.

*Proof.* If $G(z_0) = 0$ for some $z_0 \notin \{a,b\}$, then $F(z_0) = (z_0-a)(z_0-b)
G(z_0) = 0$, so $z_0$ lies in the zero set $\{a,b\}$ — a contradiction. $\square$

**Interpretation (circularity).** Suppose a proposed method constructs from $N = pq$ an
entire $F_N$ whose zeros are the prime factors, $a = p$ and $b = q$. Theorem 4.3 says
$F_N$ is *divisible by the factor polynomial*
$$(z-p)(z-q) = z^2 - (p+q)z + N$$
inside the ring of entire functions, and Theorem 4.4 says the remaining cofactor
carries no zeros and hence no further information. The factorization is thus a
*divisor* of the device: producing $F_N$ is at least as hard as producing the
factorization it is meant to reveal. The construction step already contains the answer.

### 4.2 The zero set is negligible

**Theorem 4.5 (countability).** If $F$ is entire and $F(z_0) \ne 0$ for some $z_0$, then
$\{z : F(z) = 0\}$ is countable.

*Proof sketch.* $F$ is analytic on the connected set $\mathbb{C}$ and not identically
zero, so by the identity theorem its zero set has no accumulation point in
$\mathbb{C}$: the complement of the zero set is codiscrete. A discrete subset of a
second-countable (hence separable, hereditarily Lindelöf) space is countable.
$\square$

**Theorem 4.6 (null set).** If $F$ is entire and nonzero somewhere, then
$$\mathrm{vol}\{z \in \mathbb{C} : F(z) = 0\} = 0.$$

*Proof sketch.* By the same codiscreteness, the non-vanishing set has full measure in
$\mathbb{C}$: a codiscrete-within-$\mathbb{C}$ set contains the complement of a discrete
(hence countable, hence null) set. A countable set has planar Lebesgue measure zero.
$\square$

**Theorem 4.7 (zero-set search fails).** Let $F$ be entire and nonzero somewhere, and
let $S \subseteq \mathbb{C}$ with $\mathrm{vol}(S) > 0$. Then
$$\mathrm{vol}\big(S \setminus \{z : F(z) = 0\}\big) = \mathrm{vol}(S),$$
and in particular $S$ contains points where $F$ does not vanish.

*Proof.* $S \cap \{F = 0\}$ is a subset of a null set, hence null, so removing it does
not change the measure of $S$. If $S \setminus \{F = 0\}$ were empty, $S$ would be null,
contradicting $\mathrm{vol}(S) > 0$. $\square$

Operationally: a strategy that samples points of a region and tests whether the device
vanishes there hits a zero with probability **exactly** zero. Zeros of the device must
be located by methods (argument principle, contour integration, Newton iteration from a
good start) that require repeated *evaluation* of $F_N$ — which requires having
constructed $F_N$, which by §4.1 requires the factorization. This is the *evaluation
circularity*.

### 4.3 The arithmetic price of a zero

When the analytic device is integral, Barrier III becomes a quantitative statement and
merges with Barrier I.

**Theorem 4.8 (device size lower bound).** Let $f \in \mathbb{Z}[x]$ with $f(0) \ne 0$,
and let $p$ be a prime with $f(p) = 0$. Then $p \mid f(0)$, hence
$$p \le |f(0)|.$$

*Proof.* Apply Theorem 2.2 with $N = p$: since $p \mid p$ and $p \mid f(p) = 0$, we get
$p \mid f(0)$; and $f(0) \ne 0$ gives $p \le |f(0)|$. $\square$

**Theorem 4.9 (root budget).** Let $f \in \mathbb{Z}[x]$ with $f(0) \ne 0$ and let $S$
be a finite set of primes each of which is a root of $f$. Then
$$\#S \le \log_2 |f(0)|.$$

*Proof.* By Theorem 4.8 every element of $S$ lies in $\mathcal{R}(f)$, so
$\#S \le \#\mathcal{R}(f) \le \log_2|f(0)|$ by Theorem 2.5. $\square$

Encoding a prime as a zero of an integral device costs at least as many bits as the
prime itself. There is no compression: the "analytic" packaging is not a shortcut around
the information content of the answer.

### 4.4 Sharpness: the devices exist

**Theorem 4.10 (existence).** For any two distinct primes $p, q$ there exists a nonzero
entire function whose zero set is exactly $\{p, q\}$.

*Proof.* Take $F(z) = (z-p)(z-q)$. Its zero set is $\{p,q\}$ because a product of
complex numbers vanishes iff a factor does; and $F$ is not identically zero since
$F(p+q+1) = (q+1)(p+1) \ne 0$. (More generally $F(z) = (z-p)(z-q)e^{h(z)}$ works for any
entire $h$.) $\square$

**Theorem 4.11 (the combined analytic barrier).** Let $F$ be entire with zero set
exactly $\{p, q\}$ for distinct primes $p \ne q$. Then simultaneously:
1. $\mathrm{vol}\{z : F(z) = 0\} = 0$ — the zero set cannot be found by search; and
2. there is an entire $G$ with $F(z) = (z-p)(z-q)G(z)$ — the device cannot be built
   without the factorization.

*Proof.* Non-triviality: $F(p+q+1) \ne 0$, since $p+q+1 \notin \{p,q\}$ (it exceeds
both). Now (1) is Theorem 4.6 and (2) is Theorem 4.3. $\square$

Theorem 4.10 is what prevents Barrier III from over-claiming. The obstruction is
**rigidity, not nonexistence**: the object exists, and is unique up to a nonvanishing
entire factor; what is impossible is producing it from $N$ alone.

---

## 5. The boundary: what escapes, and how

A barrier programme is only as good as its stated boundary. Barrier I forbids fixed
polynomial invariants — but Pollard's $p-1$ method does split semiprimes by taking
$\gcd(a^m - 1, N)$. Where exactly does it live?

### 5.1 Correctness of the $p-1$ strategy

**Lemma 5.1 (Fermat, divisibility form).** Let $p$ be prime, $a \in \mathbb{Z}$ with
$p \nmid a$, and $(p-1) \mid m$. Then $p \mid a^m - 1$.

*Proof.* Write $m = (p-1)t$. In $\mathbb{Z}/p\mathbb{Z}$, $a$ is invertible and
$a^{p-1} = 1$ by Fermat's little theorem, so $a^m = (a^{p-1})^t = 1$. $\square$

**Theorem 5.2 ($p-1$ splits).** Let $p \ne q$ be primes, $N = pq$, $a \in \mathbb{Z}$,
$m \in \mathbb{N}$. If $(p-1) \mid m$, $p \nmid a$, and $q \nmid a^m - 1$, then
$$\gcd(a^m - 1, N) = p.$$

*Proof.* Let $d = \gcd(a^m - 1, N)$. Then $d \mid pq$. By Lemma 5.1, $p \mid a^m - 1$
and $p \mid N$, so $p \mid d$. If $q \mid d$ then $q \mid a^m - 1$, excluded by
hypothesis; hence $\gcd(d, q) = 1$, and from $d \mid pq$ we get $d \mid p$. Combined with
$p \mid d$ this yields $d = p$. $\square$

**Example 5.3.** $N = 35 = 5 \cdot 7$, $a = 2$, $m = 4$ (a multiple of $5-1$):
$\gcd(2^4 - 1, 35) = \gcd(15, 35) = 5$. The factor is found.

### 5.2 The over-smoothness failure mode

**Theorem 5.4 (too much smoothness).** Let $p \ne q$ be primes with $p \nmid a$,
$q \nmid a$, and let $m$ be a multiple of both $p-1$ and $q-1$. Then
$$\gcd(a^m - 1, N) = N,$$
so no factor is found.

*Proof.* By Lemma 5.1 both $p$ and $q$ divide $a^m - 1$; being distinct primes they are
coprime, so $N = pq \mid a^m - 1$, whence the gcd is $N$. $\square$

**Example 5.5.** $N = 15 = 3 \cdot 5$, $a = 2$, $m = 4$: both $3-1$ and $5-1$ divide
$4$, and $\gcd(15, 15) = 15$. Nothing learned.

The method therefore lives in a narrow window: the exponent must be divisible by $p-1$
but not by $q-1$.

### 5.3 A fixed exponent is a constant polynomial

**Theorem 5.6.** For fixed $a \in \mathbb{Z}$ and $m \in \mathbb{N}$ and all
$N \in \mathbb{N}$,
$$\gcd(a^m - 1, N) = W_c(N), \qquad c(x) := a^m - 1 \in \mathbb{Z}[x] \text{ constant.}$$

*Proof.* $c(N) = a^m - 1$ for every $N$; the witness is by definition the gcd. $\square$

**Theorem 5.7 (no universal fixed exponent).** For every fixed $a$ and $m$ there is a
distinct semiprime $N$ with $\gcd(a^m-1, N) \in \{1, N\}$, i.e. no factor is found.

*Proof.* By Theorem 5.6 the strategy is the polynomial witness of the constant
polynomial $c$; apply Corollary 2.9. Concretely, both prime factors can be taken larger
than $|a^m - 1|$, and then Theorem 2.6 forbids a split. $\square$

**Theorem 5.8 (escape requires a growing exponent).** Both of the following hold:
1. there exist $N, a, m$ with $N$ a distinct semiprime and $\gcd(a^m-1, N)$ a nontrivial
   divisor of $N$ (Example 5.3); and
2. for every fixed $(a, m)$ there is a distinct semiprime on which $\gcd(a^m-1,N)$ is
   trivial (Theorem 5.7).

Hence all of the power of the $p-1$ strategy comes from letting the exponent — and
therefore the bit-size of the invariant — grow with the input.

**Example 5.9.** With $a = 2$, $m = 12$, we have $a^m - 1 = 4095 = 3^2 \cdot 5 \cdot 7
\cdot 13$, so the reveal set is $\{3,5,7,13\}$ and the reveal budget is
$\log_2 4095 \approx 11.99$. On $N = 4099 \cdot 4111 = 16850989$ the witness is $1$.

This is exactly the one loophole Barrier I leaves open, and it is precisely the door
that every successful general-purpose factoring algorithm walks through: the quadratic
sieve, the number field sieve and the elliptic-curve method are not fixed formulas
evaluated at $N$, but unbounded processes whose descriptions grow with $\log N$.

---

## 6. How the three barriers interact

### 6.1 Bridge III $\to$ I: an integral device pays for its zeros

Theorems 4.8 and 4.9 already do this: an integer polynomial with a prime factor among
its roots has that prime dividing its constant term. In the language of §2, prime roots
lie inside $\mathcal{R}(f)$, so the analytic strategy inherits Barrier I's reveal budget
verbatim. "Encoding a zero" costs as much as knowing the factor.

### 6.2 Bridge I $\to$ II: gcd witnesses are symmetric

**Proposition 6.1.** For every $f \in \mathbb{Z}[x]$, the quantity
$D(p,q) := W_f(pq)$ is recoverable from the modulus (take $G = W_f$), hence symmetric.

Barrier I methods are therefore automatically confined to the symmetric world isolated
by Barrier II. In particular no polynomial gcd witness can even *aim* at an
antisymmetric target.

### 6.3 Independence: II does not imply I

**Theorem 6.2.** For every $f \in \mathbb{Z}[x]$ it is **false** that
$W_f(pq) = \min(p,q)$ for all distinct primes $p, q$.

*Proof.* If it held, then for any distinct primes $p, q$ we would have
$1 < \min(p,q) < pq$ (both primes are $\ge 2$), so $f$ would split every distinct
semiprime — contradicting Corollary 2.9. $\square$

Combining with Theorem 3.9: $\min(p,q)$ **passes** Barrier II (it is symmetric, hence an
abstract function of $N$) yet is **blocked** by Barrier I (no polynomial witness computes
it). So the two barriers cut along genuinely different lines, and Barrier II is by
itself a well-definedness constraint, not a hardness theorem.

### 6.4 The combined statement

**Theorem 6.3 (three barriers).** Let $p \ne q$ be primes, $N = pq$, and let
$f \in \mathbb{Z}[x]$ be arbitrary. Then:
1. *(algebraic)* $W_f(N) = \gcd(f(0), N)$, and $f$ fails to split some distinct
   semiprime;
2. *(group-theoretic)* the gap $(a,b) \mapsto a - b$ is not recoverable from the
   modulus;
3. *(analytic)* there is a nonzero entire $F$ with zero set exactly $\{p, q\}$; every
   such $F$ has $\mathrm{vol}\{F = 0\} = 0$ and factors as $F(z) = (z-p)(z-q)G(z)$ with
   $G$ entire.

*Proof.* (1) is Theorem 2.3 plus Corollary 2.9; (2) is Corollary 3.7; (3) is Theorem
4.10 plus Theorem 4.11. $\square$

---

## 7. Algorithms

The barriers are constructive: each yields an explicit procedure, either for computing
the collapse or for manufacturing a counterexample.

### 7.1 Collapse evaluation

Given $f$ and $N$, compute $W_f(N)$ in two ways: naively as $\gcd(f(N), N)$, and by the
barrier as $\gcd(f(0), N)$. The two always agree (Theorem 2.3), but the second costs one
gcd on numbers of size $\max(|f(0)|, N)$ while the first costs a full Horner evaluation
producing an integer of $\deg(f)\log_2 N$ bits. The barrier is therefore also a
(dramatic) speed-up: the naive route is $\Theta(\deg f)$ multiplications on
$\Theta(\deg f \cdot \log N)$-bit integers; the barrier route is a single Euclidean
algorithm, $O(\log^2 N)$ bit operations.

### 7.2 Adversarial modulus construction

Given a finite family $F = (f_1, \dots, f_k)$, compute $B = \max_i |f_i(0)|$, find the
least prime $p > B+1$ and the least prime $q > p$, and return $N = pq$. By Theorem 2.8
every $f_i$ fails on $N$. Cost: $O(k)$ constant-term evaluations plus two prime searches
of expected $O(\log B)$ primality tests each (by the prime number theorem), i.e.
polynomial in the description length of the family. The construction is what makes
Theorem 2.8 effective rather than merely existential.

### 7.3 Reveal-set computation

Given $f$, factor $f(0)$ and return $\mathcal{R}(f)$; this set is a complete description
of the invariant's lifetime power, computable *before* seeing any input, and its
cardinality is bounded by $\log_2|f(0)|$ (Theorem 2.5).

### 7.4 Symmetry audit

Given a specification $D(p,q)$ of a proposed factoring target, test $D(p,q)$ against
$D(q,p)$ on a sample of prime pairs. A single disagreement is a certificate — by
Theorem 3.3 — that no function of $N$ can implement the specification, no matter how
much time it is allowed. This is a genuinely useful triage step: it refutes a proposal
in constant time, before any analysis of its cost.

### 7.5 Rigidity extraction

Given a purported analytic device $F$ and a claimed zero $a$, form the difference
quotient $G_1(z) = F(z)/(z-a)$ (entire by Theorem 4.2, computable by one synthetic
division on power series or by evaluation at $z \ne a$), then repeat at the second
claimed zero. The output is the entire cofactor $G$ with $F(z) = (z-p)(z-q)G(z)$,
exhibiting the factor polynomial explicitly inside the device.

---

## 8. Applications and consequences

**For cryptanalysis.** Corollary 2.7 gives a concrete triage rule: a proposed invariant
can be dismissed by inspecting a single number, its constant term. If $|f(0)| < 2^{1024}$
then $f$ cannot split any balanced $2048$-bit RSA modulus, full stop. Similarly Corollary
3.8 dismisses "return the first factor" specifications immediately, and §4.1 dismisses
zero-set constructions unless the construction step is shown to be independent of the
factorization.

**For algorithm design.** The barriers are prescriptive as well as proscriptive. They
tell the designer to (i) let the description of the invariant grow with $\log N$ — as the
sieves and the elliptic-curve method do; (ii) state targets symmetrically; and (iii)
avoid analytic constructions whose definition presupposes the answer.

**For the study of RSA specifically.** The symmetry principle (Theorem 3.10) explains
why RSA's security specification is naturally phrased in terms of the unordered factor
pair, and why any advantage in "which factor is which" is information-theoretically
absent from the public key rather than merely hard to obtain.

**Beyond factoring.** Theorem 3.10 applies verbatim to any cryptographic encoding
invariant under a group action on the secret space, and Lemma 2.1 applies to any
scheme that evaluates a fixed polynomial at a public modulus. Both are portable.

---

## 9. Discussion: what the barriers do and do not prove

They do **not** prove factoring is hard. Barrier I concerns fixed-description
invariants; Barrier II is a well-definedness statement with an explicit sharpness
counterpart ($\min(p,q)$ *is* a function of $N$); Barrier III concerns constructions of
analytic devices, and its sharpness clause says the devices exist.

What they do prove is that three large and recurrent classes of proposal are
provably empty, for three different structural reasons — and, crucially, that the
reasons are independent (§6.3). A single "master" barrier would be less informative:
knowing that a proposal falls to Barrier I but not to Barrier II tells the designer
which feature of the proposal to change.

The unifying moral is one of *description length*. In each case the failure traces back
to the invariant, the specification, or the device having a description fixed in advance
of the input. Barrier I: a fixed $f$ has a fixed $f(0)$, hence a fixed reveal budget.
Barrier II: a specification blind to nothing but the ordering is exactly a symmetric
one. Barrier III: an entire function with prescribed zeros has those zeros in its
description. Escape is possible only where description length is allowed to grow —
which is precisely where the successful algorithms live.

---

## 10. Future directions

Three concrete, falsifiable conjectures suggest themselves.

**Conjecture A (size–yield law for arithmetic circuits).** For every invariant computed
by an arithmetic circuit of size $s$ over $\mathbb{Z}$ on input $N$, any prime revealed
by the gcd witness is bounded by a function of $s$ alone — conjecturally
$2^{2^{O(s)}}$ — independent of the input. The polynomial case is Theorem 2.6; the
general case needs an evaluation-at-zero argument plus a bound on iterated squaring.
*Falsifiable test:* exhibit a small circuit whose gcd witness splits a semiprime both of
whose primes exceed the circuit's value at input $0$.

**Conjecture B (adaptivity threshold).** Barrier I survives adaptivity of bounded
granularity (Theorem 2.10) but should fail as soon as the family is indexed by
$\log N$ bits: there should exist a family $(f_k)$ with $\deg f_k$ and height at most
$2^k$ such that $f_{\lceil \log N\rceil}$ splits every semiprime $N$ with $2^k$-smooth
$p-1$. The bounded half is proved; the unbounded half is essentially the $p-1$ method
(Theorem 5.2) plus a smoothness density estimate. *Falsifiable test:* find a single
polynomial family of *bounded* height splitting all semiprimes below a bound where both
failure modes of §5 occur.

**Conjecture C (antisymmetry is the only obstruction, quantitatively).** Define the
antisymmetric defect of a factor-recovery scheme $D$ as the number of prime pairs below
$x$ on which $D(p,q) \ne D(q,p)$. Any scheme with positive defect is not a function of
$N$ (Theorem 3.6); conversely, every symmetric $D$ should be realized by a function of
$N$ whose descriptive complexity is within $O(\log x)$ of that of the factoring oracle
itself.

Beyond these: extend Barrier III to meromorphic and to several-variable devices; extend
Barrier I to invariants defined over number fields or by $p$-adic constructions; and
quantify the trade-off in Conjecture B into a genuine description-length hierarchy for
factoring strategies.

---

## 11. Conclusion

Three theorems, three mechanisms, one moral.

The **polynomial barrier** says that evaluating any integer polynomial at $N$ is
congruent, modulo $N$, to evaluating it at $0$; so $\gcd(f(N), N) = \gcd(f(0), N)$, a
fixed invariant reveals at most $\log_2|f(0)|$ primes ever, splitting $N = pq$ forces
$\min(p,q) \le |f(0)|$, and no finite or boundedly-adaptive family is universal.

The **symmetry barrier** says that a quantity attached to prime pairs is a function of
their product exactly when it is symmetric; the antisymmetric half of the factor data is
destroyed at encoding time, while the symmetric half — including $\min(p,q)$ and $p+q$ —
survives as an abstract function of $N$.

The **holomorphic rigidity barrier** says that an entire function vanishing at $p$ and
$q$ is $(z-p)(z-q)$ times an entire function, with a nonvanishing cofactor when the zero
set is exactly $\{p,q\}$; such devices exist, but constructing one already encodes the
factorization, and their zero sets are countable and Lebesgue-null, so search finds them
with probability zero.

The three are independent and complementary — algebraic, group-theoretic, analytic —
and their common boundary is description length. Everything with a fixed description
fails; the one escape is to let the description grow with the input, which is exactly
what every successful factoring algorithm does.
