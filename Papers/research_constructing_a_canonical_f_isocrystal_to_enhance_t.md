# A Non-Circular Proof of the Fibonacci Law of Apparition

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (Number Theory / Bridges)

---

## Abstract

For a prime $p$, the *rank of apparition* (or Fibonacci entry point)
$\alpha(p)$ is the least positive index $k$ with $p \mid F_k$, where $F$ denotes
the Fibonacci sequence $F_0 = 0,\ F_1 = 1,\ F_{n+2} = F_{n+1} + F_n$. The
*spine* of apparition theory, $p \mid F_n \iff \alpha(p) \mid n$, is classical
and reduces every divisibility question about Fibonacci numbers to a question
about the single number $\alpha(p)$. This paper establishes the classical
**localisation law**: for every prime $p \ge 7$,
$$\alpha(p) \mid p - 1 \quad \text{or} \quad \alpha(p) \mid p + 1.$$
The significance is computational as much as theoretical: the law converts the
*a priori* unbounded search for $\alpha(p)$ into a bounded loop over the divisors
of $p-1$ and $p+1$. We give a proof that is deliberately **non-circular**: it
never invokes the multiplicative order of the golden ratio modulo $p$ (which is
itself defined through $\alpha(p)$). Instead the proof pins down the single
residue $F_p \bmod p$ using the Frobenius endomorphism of the quadratic ring
$S = (\mathbb{Z}/p)[x]/(x^2 - x - 1)$, obtains $F_p^2 \equiv 1 \pmod p$, and then
applies Cassini's identity at $n = p-1$ together with primality to split
$p \mid F_{p+1} F_{p-1}$ into the desired dichotomy. The entire development has
been formalised and machine-checked in Lean 4 / Mathlib; the main theorems are
`dvd_fib_iff_rank_dvd` (the spine), `fib_sq_mod` ($F_p^2 \equiv 1$),
`cassini` (Cassini's identity), `p_dvd_fib_pred_or_succ` (the Fibonacci–Fermat
law), and `rank_dvd_pred_or_succ` (the law of apparition).

---

## 1. Introduction

The Fibonacci sequence $(F_n)_{n \ge 0}$ defined by

$$F_0 = 0, \qquad F_1 = 1, \qquad F_{n+2} = F_{n+1} + F_n$$

is a *strong divisibility sequence*: $\gcd(F_m, F_n) = F_{\gcd(m,n)}$. A direct
consequence is that the set of indices at which a fixed modulus $m$ divides
$F_n$ forms an ideal of $(\mathbb{N}, +)$ under the divisibility order, generated
by a single least element.

**Definition 1.1 (Rank of apparition).** For $m \in \mathbb{N}$, say $m$ *has a
rank* if there exists $k > 0$ with $m \mid F_k$. The **rank of apparition** of
$m$ is
$$\alpha(m) = \min\{\,k > 0 : m \mid F_k\,\},$$
and $\alpha(m) = 0$ by convention when no such $k$ exists. (In the Lean
development these are `HasRank m`, `rank m`, with existence for $m>0$ proved as
`exists_pos_dvd_fib`.)

The basic theory rests on two pillars. The first is *existence*: every positive
modulus has a rank, because the pair of residues $(F_k \bmod m,\ F_{k+1} \bmod
m)$ ranges over a finite set and must eventually repeat, and the recurrence is
reversible, forcing a return to $(0,1)$ and hence a zero of $F$. The second is
the *spine*, which we record now and prove in §2.

**Theorem 1.2 (Spine).** If $m$ has a rank, then for all $k \in \mathbb{N}$,
$$m \mid F_k \iff \alpha(m) \mid k.$$

The spine reduces *all* Fibonacci divisibility to knowledge of $\alpha(m)$. The
outstanding question it leaves open is how to *find* $\alpha(p)$ for a prime $p$
without an unbounded search. That is answered by the central result of this
paper.

**Theorem 1.3 (Law of apparition).** For every prime $p \ge 7$,
$$\alpha(p) \mid p - 1 \quad \text{or} \quad \alpha(p) \mid p + 1.$$
(Lean: `rank_dvd_pred_or_succ`.)

The restriction $p \ge 7$ excludes only the special primes $2, 3$ (small
exceptions) and $5$ (the ramified prime where $x^2 - x - 1$ has a double root and
$5 \mid F_5$ degenerately). For $p = 5$ one has $\alpha(5) = 5$, which divides
neither $4$ nor $6$.

### 1.1 The computational payoff

The naive algorithm for $\alpha(p)$ tests $k = 1, 2, 3, \dots$ until $p \mid
F_k$; its running time is $\Theta(\alpha(p))$, which can be as large as $p+1$ and
is not known *a priori*. Theorem 1.3 replaces this by a bounded search.

> **Algorithm $\mathrm{RANK}(p)$, for prime $p \ge 7$:**
> 1. Enumerate $D = \mathrm{Div}(p-1) \cup \mathrm{Div}(p+1)$, sorted ascending.
> 2. For each $d \in D$: if $p \mid F_d$, return $d$.

Theorem 1.3 certifies that the loop *terminates with a return* (the true rank is
some divisor of $p-1$ or of $p+1$, since the rank divides whichever of those it
appears in, by the spine). Theorem 1.2 certifies *correctness of the first hit*:
any $d$ with $p \mid F_d$ is a multiple of $\alpha(p)$, so the least such $d$ in
$D$ is $\alpha(p)$ itself. The number of candidates is
$|D| \le d(p-1) + d(p+1)$, where $d(\cdot)$ is the divisor-count function — on
average $O(\log p)$, and worst case $p^{o(1)}$. Evaluating $F_d \bmod p$ costs
$O(\log d)$ multiplications by fast doubling. The total is therefore
quasi-polynomial in $\log p$, a dramatic improvement over $\Theta(\alpha(p))$.

### 1.2 The circularity, and how we avoid it

Binet's formula $F_n = (\varphi^n - \psi^n)/\sqrt5$ with $\varphi,\psi$ the roots
of $x^2 - x - 1$ tempts one to argue via the multiplicative order of $\varphi$
modulo $p$. But that order is *defined through* $\alpha(p)$ (it equals
$\alpha(p)$ or $2\alpha(p)$ depending on the Legendre symbol), so bounding
$\alpha(p)$ by reasoning about the order is circular.

Our proof breaks the circle by computing one residue that is independent of the
rank, namely $F_p \bmod p$, using only the Frobenius endomorphism (Fermat's
little theorem in characteristic $p$). We then feed it into Cassini's identity.
No statement in the chain mentions $\alpha(p)$ until the very last step, where
the spine is applied.

---

## 2. The spine

We work with `HasRank` and `rank` as in Definition 1.1.

**Lemma 2.1 (Existence).** For $m > 0$, $m$ has a rank. *(Lean:
`exists_pos_dvd_fib`.)*

*Proof sketch.* Consider the sequence of pairs
$P_k = (F_k \bmod m,\ F_{k+1} \bmod m) \in (\mathbb{Z}/m)^2$. The codomain is
finite, so by pigeonhole there exist $i < j$ with $P_i = P_j$. The Fibonacci
recurrence is invertible ($F_{k} = F_{k+2} - F_{k+1}$), so $P$ is "eventually
periodic with no pre-period," i.e. $P_i = P_j \Rightarrow P_0 = P_{j-i}$. Since
$P_0 = (0,1)$, the first coordinate of $P_{j-i}$ is $0$, giving $m \mid F_{j-i}$
with $j - i > 0$. $\;\square$

**Lemma 2.2.** If $m$ has a rank then $\alpha(m) > 0$ and $m \mid F_{\alpha(m)}$.
*(Lean: `rank_pos`, `dvd_fib_rank`.)* Immediate from the well-ordering used to
define $\alpha$ via `Nat.find`.

**Theorem 1.2 (Spine), restated.** If $m$ has a rank then
$m \mid F_k \iff \alpha(m) \mid k$. *(Lean: `dvd_fib_iff_rank_dvd`.)*

*Proof sketch.*
($\Leftarrow$) If $\alpha(m) \mid k$, write $k = \alpha(m)\,c$. The strong
divisibility property $F_{a} \mid F_{ac}$ (`Nat.fib_dvd`) gives
$F_{\alpha(m)} \mid F_k$, and $m \mid F_{\alpha(m)}$ by Lemma 2.2, so
$m \mid F_k$.
($\Rightarrow$) Suppose $m \mid F_k$. Using $F_{\gcd(a,b)} = \gcd(F_a, F_b)$
(`Nat.fib_gcd`), we get
$$m \mid \gcd(F_{\alpha(m)},\, F_k) = F_{\gcd(\alpha(m),\,k)}.$$
Thus $g := \gcd(\alpha(m), k)$ is a positive index with $m \mid F_g$, and
$g \le \alpha(m)$ since $g \mid \alpha(m)$. Minimality of $\alpha(m)$ forces
$g = \alpha(m)$, i.e. $\alpha(m) \mid k$. $\;\square$

The spine alone yields the standard corollary $\alpha(m) \mid n$ whenever
$m \mid F_n$; the work of the paper is to exhibit such an $n \in \{p-1, p+1\}$.

---

## 3. A ring-theoretic Binet identity

The recurrence is best handled abstractly.

**Lemma 3.1 (Binet recurrence).** Let $R$ be a commutative ring and $a \in R$
with $a^2 = a + 1$. Then for all $n \ge 0$,
$$a^{\,n+1} = F_{n+1}\, a + F_n \qquad (\text{coefficients reduced into } R).$$
*(Lean: `pow_succ_of_golden`.)*

*Proof sketch.* Induction on $n$. Base $n=0$: $a^1 = F_1 a + F_0 = a$. Step:
assuming $a^{n+1} = F_{n+1}a + F_n$, multiply by $a$ and use $a^2 = a+1$:
$$a^{n+2} = F_{n+1}a^2 + F_n a = F_{n+1}(a+1) + F_n a
          = (F_{n+1}+F_n)a + F_{n+1} = F_{n+2}a + F_{n+1}. \;\square$$

This is Binet's formula purged of $\sqrt5$ and division, so it specialises
*verbatim* to any characteristic, in particular to a quadratic extension of
$\mathbb{Z}/p$.

**The golden-ratio ring.** Fix a prime $p \ge 7$. Let
$$S = \mathrm{AdjoinRoot}(x^2 - x - 1) = (\mathbb{Z}/p)[x]/(x^2 - x - 1),$$
a free $(\mathbb{Z}/p)$-algebra of rank $2$. Write $\varphi \in S$ for the image
of $x$ and set $\psi = 1 - \varphi$. Then $\varphi^2 = \varphi + 1$ and a short
computation gives $\psi^2 = \psi + 1$ as well (both are roots of $x^2 - x - 1$),
together with
$$\varphi + \psi = 1, \qquad \varphi\,\psi = -1, \qquad \varphi - \psi = 2\varphi - 1.$$
Note $(\varphi - \psi)^2 = (\varphi+\psi)^2 - 4\varphi\psi = 1 + 4 = 5$, the
image of the discriminant. The structure map
$\iota = \mathrm{algebraMap}\,(\mathbb{Z}/p)\,S$ is injective because
$x^2 - x - 1$ has degree $2 > 0$ and $\mathbb{Z}/p$ is a field (`compute_degree!`
and nontriviality discharge the side conditions in Lean).

Applying Lemma 3.1 to $a = \varphi$ and $a = \psi$ at exponent $n = p - 1$:
$$\varphi^p = F_p\,\varphi + F_{p-1}, \qquad \psi^p = F_p\,\psi + F_{p-1},$$
where $F_p, F_{p-1}$ are read modulo $p$ via $\iota$. Subtracting,
$$\varphi^p - \psi^p = F_p\,(\varphi - \psi). \tag{3.1}$$

---

## 4. Pinning down $F_p \bmod p$ via Frobenius

**Lemma 4.1 (Freshman's dream).** In any commutative ring $R$ of prime
characteristic $p$, $(u+v)^p = u^p + v^p$ for all $u,v$. *(Mathlib:
`add_pow_char`.)* Consequently $u \mapsto u^p$ is a ring endomorphism (the
**Frobenius**).

Since $S$ has characteristic $p$ (it is a $(\mathbb{Z}/p)$-algebra), Frobenius is
multiplicative and additive on $S$. Therefore
$$\varphi^p + \psi^p = (\varphi + \psi)^p = 1^p = 1, \tag{4.1}$$
$$\varphi^p \cdot \psi^p = (\varphi\,\psi)^p = (-1)^p = -1, \tag{4.2}$$
the last because $p$ is odd. From (4.1)–(4.2),
$$(\varphi^p - \psi^p)^2 = (\varphi^p + \psi^p)^2 - 4\,\varphi^p\psi^p
   = 1 + 4 = 5. \tag{4.3}$$

**Theorem 4.2 ($F_p^2 \equiv 1$).** For every prime $p \ge 7$,
$$F_p^{\,2} \equiv 1 \pmod p.$$
*(Lean: `fib_sq_mod`.)*

*Proof sketch.* Square (3.1) and use $(\varphi-\psi)^2 = 5$:
$$(\varphi^p - \psi^p)^2 = F_p^{\,2}\,(\varphi - \psi)^2 = 5\,F_p^{\,2}
  \quad\text{in } S.$$
Combining with (4.3), $5\,F_p^{\,2} = 5$ in $S$, i.e.
$\iota(5\,F_p^2) = \iota(5)$. Injectivity of $\iota$ gives $5 F_p^2 = 5$ in
$\mathbb{Z}/p$. Since $p \ge 7$ implies $p \nmid 5$, the element $5$ is a unit in
$\mathbb{Z}/p$, and cancelling yields $F_p^2 = 1$ in $\mathbb{Z}/p$. $\;\square$

*Remark (the Legendre symbol).* The same computation shows
$\varphi^p - \psi^p = \pm(\varphi - \psi)$, with sign $5^{(p-1)/2} \equiv
(5 \mid p) \pmod p$ by Euler's criterion. Hence in fact
$F_p \equiv (5 \mid p) \pmod p$. This sharper statement, governed by $p \bmod 5$
via quadratic reciprocity, is the seed of the branch-selection refinement
(Conjecture 7.1). For Theorem 1.3 we only need $F_p^2 \equiv 1$.

---

## 5. Cassini's identity and the dichotomy

**Lemma 5.1 (Cassini).** Over $\mathbb{Z}$, for all $n \ge 0$,
$$F_{n+2}\,F_n + (-1)^n = F_{n+1}^{\,2}.$$
*(Lean: `cassini`.)*

*Proof sketch.* Induction on $n$, or the determinant identity
$\det \begin{psmallmatrix} F_{n+1} & F_n \\ F_n & F_{n-1}\end{psmallmatrix} =
(-1)^n$ coming from
$\begin{psmallmatrix}1&1\\1&0\end{psmallmatrix}^{\,n}
 = \begin{psmallmatrix}F_{n+1}&F_n\\ F_n&F_{n-1}\end{psmallmatrix}$
and multiplicativity of the determinant. $\;\square$

**Theorem 5.2 (Fibonacci–Fermat law).** For every prime $p \ge 7$,
$$p \mid F_{p-1} \quad \text{or} \quad p \mid F_{p+1}.$$
*(Lean: `p_dvd_fib_pred_or_succ`.)*

*Proof sketch.* Apply Cassini at $n = p - 1$. As $p$ is odd, $p - 1$ is even, so
$(-1)^{p-1} = 1$ and
$$F_{p+1}\,F_{p-1} + 1 = F_p^{\,2}.$$
Reduce modulo $p$ and use Theorem 4.2, $F_p^2 \equiv 1$:
$$F_{p+1}\,F_{p-1} \equiv F_p^2 - 1 \equiv 0 \pmod p.$$
Since $p$ is prime, $p \mid F_{p+1}F_{p-1}$ implies $p \mid F_{p+1}$ or
$p \mid F_{p-1}$ (Euclid's lemma). $\;\square$

**Theorem 1.3 (Law of apparition), proof.** Let $p \ge 7$ be prime. By Lemma 2.1
$p$ has a rank, so the spine (Theorem 1.2) applies. By Theorem 5.2 either
$p \mid F_{p-1}$ or $p \mid F_{p+1}$. In the first case the spine gives
$\alpha(p) \mid p-1$; in the second, $\alpha(p) \mid p+1$. $\;\square$

Every hypothesis feeding into Theorem 1.3 — Lemma 3.1, Lemma 4.1, Theorem 4.2,
Lemma 5.1 — is established without any reference to $\alpha(p)$, which is what
makes the derivation non-circular.

---

## 6. Algorithms

### 6.1 Fibonacci modulo $m$ by fast doubling

The candidate test $p \mid F_d$ requires $F_d \bmod p$ for possibly huge $d$.
Fast doubling uses
$$F_{2k} = F_k\,(2F_{k+1} - F_k), \qquad F_{2k+1} = F_{k+1}^2 + F_k^2,$$
to compute the pair $(F_d, F_{d+1}) \bmod m$ in $O(\log d)$ ring operations.

### 6.2 Bounded rank computation

Algorithm $\mathrm{RANK}(p)$ of §1.1: enumerate the divisors of $p-1$ and $p+1$,
sort, and return the least $d$ with $F_d \equiv 0 \pmod p$. Correctness and
termination are Theorems 1.2 and 1.3. Complexity:
$O\!\big((d(p-1)+d(p+1))\cdot \log p\big)$ modular multiplications after factoring
$p \pm 1$.

### 6.3 Tabulation and pattern search

With $\mathrm{RANK}$ in hand one can tabulate $\alpha(p)$ for many primes and
test the conjectures of §7 empirically (e.g. comparing $\alpha(p)$ with
$p - (5 \mid p)$, or checking the Wall–Sun–Sun condition $p^2 \nmid
F_{\alpha(p)}$).

---

## 7. Discussion and open problems

**Conjecture 7.1 (Legendre branch selection).** For an odd prime $p \ne 5$:
if $p \equiv \pm 1 \pmod 5$ then $\alpha(p) \mid p - 1$; if $p \equiv \pm 2 \pmod
5$ then $\alpha(p) \mid p + 1$ (and $\alpha(p) \nmid p-1$). Equivalently
$\alpha(p) \mid p - (5 \mid p)$. The Remark after Theorem 4.2 already yields
$F_p \equiv (5\mid p) \pmod p$; upgrading the disjunction to the exact branch
needs only Euler's criterion and quadratic reciprocity, both available in
Mathlib.

**Conjecture 7.2 (Prime-power lifting).** For a prime $p \ne 5$ and $k \ge 1$,
$\alpha(p^k) = p^{k-1}\,\alpha(p)$ unless $p$ is a Wall–Sun–Sun prime (none
known); unconditionally $\alpha(p) \mid \alpha(p^k) \mid p^{k-1}\alpha(p)$. The
binomial normal form computes $F_n \bmod p^2$ just as it computes $F_n \bmod p$,
the second-order term controlling the jump from $\alpha(p)$ to $\alpha(p^2)$.

**Conjecture 7.3 (Uniform Lucas law).** For a nondegenerate Lucas sequence
$U_n(P,Q)$ with discriminant $D = P^2 - 4Q$, every prime $p \nmid 2QD$ satisfies
$\alpha_U(p) \mid p - (D \mid p)$. The Binet identity generalises verbatim:
$2^{\,n-1} U_n = \sum_j \binom{n}{2j+1} P^{\,n-1-2j} D^{\,j}$, and the Frobenius
collapse depends only on $(D \mid p)$.

**Conjecture 7.4 (Density of first-kind primes).** The set of primes $p$ with
$\alpha(p) \mid p-1$ (equivalently $p \equiv \pm 1 \bmod 5$, granting 7.1) has
natural density $1/2$, and likewise the $p+1$ branch, by Dirichlet's theorem on
primes in arithmetic progressions applied to the residue classes
$\{1,4\}$ and $\{2,3\} \bmod 5$.

---

## 8. Formalisation notes

The development is machine-checked in Lean 4 with Mathlib. Reusable Mathlib
components carry the weight of the algebra — `AdjoinRoot`, `CharP`/`add_pow_char`
(Frobenius), the field structure of `ZMod p`, `Nat.fib_gcd`, `Nat.fib_dvd` — so
that the number-theoretic core, `fib_sq_mod`, is a short auditable argument
rather than a hand manipulation of $(1\pm\sqrt5)^p$. Finite and structural side
conditions (degree of $x^2-x-1$, nontriviality of $S$) are discharged by
`decide`/`compute_degree!`, and ring identities by `ring`/`linear_combination`.
The named results are: `exists_pos_dvd_fib`, `rank_pos`, `dvd_fib_rank`,
`dvd_fib_iff_rank_dvd`, `pow_succ_of_golden`, `fib_sq_mod`, `cassini`,
`p_dvd_fib_pred_or_succ`, and `rank_dvd_pred_or_succ`.

---

## 9. Conclusion

We proved, non-circularly and with full machine verification, that the Fibonacci
rank of apparition of any prime $p \ge 7$ divides $p-1$ or $p+1$. The proof
isolates the rank-independent residue $F_p \bmod p$ through the Frobenius
endomorphism, derives $F_p^2 \equiv 1$, and closes with Cassini's identity and
Euclid's lemma. Beyond its intrinsic elegance, the law transforms the
computation of $\alpha(p)$ from an unbounded scan into a bounded divisor search,
and it points toward sharp refinements (branch selection by $p \bmod 5$,
prime-power lifting, uniform Lucas analogues, and density results) that are now
within reach.
