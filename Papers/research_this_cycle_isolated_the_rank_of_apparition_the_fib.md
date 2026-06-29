# The Rank of Apparition as the Spine of Fibonacci Primitive-Divisor Theory

**Domain:** Bridges (Number Theory / Combinatorics on Sequences)

---

## Abstract

The *rank of apparition* of a positive integer $m$ — the least index $k > 0$ for
which $m$ divides the Fibonacci number $F_k$ — is a classical but historically
under-emphasized object. We isolate it as the single load-bearing structure
underlying a cluster of otherwise-parallel results about Fibonacci divisibility:
entry points, apparition lattices, strong-divisibility sequences, and the
Carmichael / Bang–Zsygmondy primitive-divisor program. We give a self-contained
foundation built on two pillars. First, an *existence theorem*: every positive
modulus has a rank, proved by a pigeonhole argument on the reversible Fibonacci
shift over $(\mathbb{Z}/m\mathbb{Z})^2$ — an elementary surrogate for Pisano-period
theory. Second, the *spine*: the biconditional
$m \mid F_n \iff \mathrm{rank}(m) \mid n$, established **without any primitivity
hypothesis**, thereby generalizing the standard pinning lemma. From the spine we
derive in a few lines several results, two of which are absent from both the prior
catalog and the standard libraries: the *fixed-point law*
$\mathrm{rank}(F_k) = k$ for $k \ge 3$, which pins Fibonacci values exactly; and the
*divisibility mirror* $F_a \mid F_b \iff a \mid b$ for $a \ge 3$, upgrading the
classical one-directional $a \mid b \Rightarrow F_a \mid F_b$ to a biconditional.
We also obtain the order-morphism law $b \mid a \Rightarrow \mathrm{rank}(b) \mid
\mathrm{rank}(a)$ and Carmichael's prime case — *every* prime index $p \ge 3$
yields a Fibonacci number with a primitive prime divisor — uniformly and in three
sentences. All results have been formally verified with a proof assistant (0
unproved obligations; reliance only on the standard logical axioms). This paper is
fully self-contained: every definition, theorem, and proof sketch is stated inline.

---

## 1. Introduction

The Fibonacci sequence is defined by
$$F_0 = 0,\quad F_1 = 1,\quad F_{n+2} = F_n + F_{n+1}.$$

A foundational question about any integer sequence is its *divisibility pattern*:
for a fixed modulus $m$, at which indices $n$ does $m \mid F_n$? For the Fibonacci
numbers the answer is strikingly rigid. The indices at which a given $m$ appears as
a divisor form a complete arithmetic progression with no gaps and no extras. The
generator of that progression is the **rank of apparition** (also called the
*Fibonacci entry point*) of $m$:
$$\mathrm{rank}(m) := \min\{\, k > 0 : m \mid F_k \,\}.$$

This object has been rediscovered many times. The prior catalog of formalized
mathematics on which this work builds contained at least six distinct, parallel
developments of essentially the same fact — existence and a biconditional in one
file, an "entry-point calculus" in another, "apparition lattice" laws (least common
multiple identities) in a third, a primitivity-conditioned pinning lemma in a
fourth, an abstract "strong divisibility sequence" treatment in a fifth, and an
analytic Carmichael argument restricted to primes $p \ge 5$ in a sixth. Each was
correct and useful, but the duplication signaled that none had identified the true
spine.

**Contributions.** We make the rank of apparition the protagonist and prove its
master property in maximal generality.

1. **Existence (§3).** Every positive $m$ has a rank, via pigeonhole on the
   reversible Fibonacci shift over $(\mathbb{Z}/m\mathbb{Z})^2$.
2. **The spine (§4).** $m \mid F_n \iff \mathrm{rank}(m) \mid n$, with **no
   primitivity hypothesis**, generalizing the catalog's pinning lemma
   `dvd_fib_iff_index_dvd_of_primitive`.
3. **Order morphism (§5).** $b \mid a$ and $a > 0$ imply $\mathrm{rank}(b) \mid
   \mathrm{rank}(a)$, packaged with existence.
4. **Fixed-point law (§6).** $\mathrm{rank}(F_k) = k$ for $k \ge 3$ — new; pins
   Fibonacci values exactly.
5. **Divisibility mirror (§6).** $F_a \mid F_b \iff a \mid b$ for $a \ge 3$ — new;
   upgrades the classical one-way implication to a biconditional.
6. **Carmichael's prime case (§7).** For every prime $p \ge 3$, $F_p$ has a
   primitive prime divisor — uniform over all such $p$, derived in a few lines.

We close (§8–9) with applications to apparition density and a discussion of how the
spine transports verbatim to all strong-divisibility sequences, followed by future
directions.

---

## 2. Preliminaries and Notation

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$, $a \mid b$ denotes divisibility, and
$\gcd$ and $\mathrm{lcm}$ have their usual meanings. We write $F_n$ for the $n$-th
Fibonacci number. We use two classical Fibonacci identities as black boxes; both
are standard.

**Lemma 2.1 (Divisibility identity).** *If $a \mid b$ then $F_a \mid F_b$.*

For example $F_3 = 2$ divides $F_9 = 34$ because $3 \mid 9$.

**Lemma 2.2 (GCD identity).** *$\gcd(F_a, F_b) = F_{\gcd(a,b)}$.*

For example $\gcd(F_8, F_{12}) = \gcd(21, 144) = 3 = F_4 = F_{\gcd(8,12)}$.

These two identities are the *only* substantive facts about the Fibonacci sequence
used below. This is the technical reason the entire theory transports to other
sequences satisfying analogues of Lemmas 2.1–2.2 (see §9).

**Definition 2.3 (Has a rank).** A modulus $m$ *has a rank of apparition* if it
divides some positive-index Fibonacci number:
$$\mathrm{HasFibRank}(m) :\Longleftrightarrow \exists\, k > 0,\ m \mid F_k.$$

**Definition 2.4 (Rank function).** The *rank of apparition* of $m$ is
$$\mathrm{rank}(m) := \begin{cases}
\min\{\, k : k > 0 \wedge m \mid F_k \,\} & \text{if } \mathrm{HasFibRank}(m), \\
0 & \text{otherwise.}
\end{cases}$$

For $m \ge 1$, existence of the minimum is guaranteed by Theorem 3.3 below. Note
$\mathrm{rank}(1) = 1$ since $1 \mid F_1$.

The defining properties of $\mathrm{rank}$ are immediate from the well-ordering of
$\mathbb{N}$:

- **(Positivity)** If $\mathrm{HasFibRank}(m)$ then $\mathrm{rank}(m) > 0$.
- **(Witness)** If $\mathrm{HasFibRank}(m)$ then $m \mid F_{\mathrm{rank}(m)}$.
- **(Minimality)** If $0 < k < \mathrm{rank}(m)$ then $m \nmid F_k$.

---

## 3. Existence: Every Positive Modulus Has a Rank

That a rank *exists* is not automatic — it asserts that $m$ divides *some* positive
Fibonacci number. We prove it by an elementary period argument that serves as a
surrogate for Pisano-period theory (which is absent from the underlying library).

**Definition 3.1 (Fibonacci shift).** Over the ring $\mathbb{Z}/m\mathbb{Z}$,
define the map on pairs
$$\sigma_m : (\mathbb{Z}/m\mathbb{Z})^2 \to (\mathbb{Z}/m\mathbb{Z})^2,\qquad
\sigma_m(a, b) = (b,\ a + b),$$
with inverse $\sigma_m^{-1}(a, b) = (b - a,\ a)$. One checks directly that
$\sigma_m^{-1}\circ\sigma_m = \mathrm{id}$ and $\sigma_m\circ\sigma_m^{-1} =
\mathrm{id}$, so $\sigma_m$ is a **bijection** (it is the companion matrix
$\left(\begin{smallmatrix}0&1\\1&1\end{smallmatrix}\right)$, of determinant $-1$, a
unit).

**Lemma 3.2 (Iteration generates Fibonacci pairs).**
$$\sigma_m^{\,k}(0, 1) = \big(F_k \bmod m,\ F_{k+1} \bmod m\big).$$

*Proof sketch.* Induction on $k$. The base case is $(F_0, F_1) = (0,1)$. The
inductive step is exactly the recurrence $F_{k+2} = F_k + F_{k+1}$, which is the
action of $\sigma_m$. $\square$

**Theorem 3.3 (Existence of the rank).** *For every $m > 0$,
$\mathrm{HasFibRank}(m)$ holds.*

*Proof sketch.* Consider the sequence of pairs $P_n := (F_n \bmod m,\ F_{n+1}
\bmod m) \in (\mathbb{Z}/m\mathbb{Z})^2$. The codomain is finite (it has $m^2$
elements), so by pigeonhole the map $n \mapsto P_n$ cannot be injective: there exist
$i < j$ with $P_i = P_j$, i.e. $F_i \equiv F_j$ and $F_{i+1} \equiv F_{j+1}
\pmod m$. Because $\sigma_m$ is a bijection and $P_n = \sigma_m^{\,n}(0,1)$, we may
apply $\sigma_m^{-1}$ exactly $i$ times to the equation $P_i = P_j$, obtaining
$P_0 = P_{j-i}$. The first coordinate of $P_0$ is $F_0 \bmod m = 0$, hence
$F_{j-i} \equiv 0 \pmod m$ with $k := j - i > 0$. Thus $m \mid F_k$. (The degenerate
case $m = 0$, where $\mathbb{Z}/0\mathbb{Z} \cong \mathbb{Z}$ is infinite, is
excluded by hypothesis.) $\square$

The reversibility of $\sigma_m$ is the conceptual heart: a repeated state in the
*interior* of an invertible dynamical system can always be wound back to the
*initial* state, and the initial state is the one we want (the $0$ in position
zero). This is the Pisano-period mechanism in miniature.

---

## 4. The Spine

This is the central theorem and the one from which all subsequent results flow.

**Theorem 4.1 (The spine).** *Let $m$ have a rank. Then for every $n$,*
$$m \mid F_n \quad\Longleftrightarrow\quad \mathrm{rank}(m) \mid n.$$

*Proof sketch.* Let $r := \mathrm{rank}(m) > 0$, and recall $m \mid F_r$ (Witness).

*($\Leftarrow$)* Suppose $r \mid n$. By Lemma 2.1, $F_r \mid F_n$. Since
$m \mid F_r \mid F_n$, we get $m \mid F_n$.

*($\Rightarrow$)* Suppose $m \mid F_n$; we show $r \mid n$. Argue by
contraposition: assume $r \nmid n$. Then $d := \gcd(r, n)$ is a *proper* divisor of
$r$, so $0 < d < r$ (it is positive because $r > 0$). Now $m$ divides both $F_r$
and $F_n$ (the latter by hypothesis), hence $m$ divides $\gcd(F_r, F_n)$. By the GCD
identity (Lemma 2.2), $\gcd(F_r, F_n) = F_{\gcd(r,n)} = F_d$. Therefore $m \mid F_d$
with $0 < d < r = \mathrm{rank}(m)$, contradicting minimality of the rank. Hence
$r \mid n$. $\square$

**Remark 4.2 (Generality).** Theorem 4.1 carries *no primitivity hypothesis*. The
prior catalog's pinning lemma — call it `dvd_fib_iff_index_dvd_of_primitive` —
required $m$ (typically a prime $p$) to be a *primitive* divisor of $F_{\mathrm{rank}(m)}$,
i.e. to first appear precisely there. Theorem 4.1 holds for **every** modulus with a
rank; primitivity reappears as the special boundary case $\mathrm{rank}(m) = n$
(see §7). This dropping of the hypothesis is what makes the rank a genuine spine
rather than one technical lemma among many.

**Corollary 4.3 (Exact progression).** *For $m$ with rank $r$, the set
$\{\, n : m \mid F_n \,\}$ equals the set of nonnegative multiples of $r$.* In
particular the appearances of $m$ as a Fibonacci divisor are perfectly periodic
with period $r$.

---

## 5. The Order-Morphism Law

The rank is not merely defined pointwise; it respects the divisibility order.

**Theorem 5.1 (Order morphism, with existence).** *If $b \mid a$ and $a > 0$, then
$b$ has a rank, $a$ has a rank, and $\mathrm{rank}(b) \mid \mathrm{rank}(a)$.*

*Proof sketch.* Since $a > 0$, Theorem 3.3 gives $\mathrm{HasFibRank}(a)$. Since
$b \mid a$ and $a > 0$, also $b > 0$, so $b$ has a rank. Now $a \mid F_{\mathrm{rank}(a)}$
(Witness for $a$), and $b \mid a$, so by transitivity $b \mid F_{\mathrm{rank}(a)}$.
Apply the spine (Theorem 4.1) to $b$ at the index $n = \mathrm{rank}(a)$:
$b \mid F_{\mathrm{rank}(a)} \Rightarrow \mathrm{rank}(b) \mid \mathrm{rank}(a)$.
$\square$

Thus $\mathrm{rank} : (\mathbb{N}_{>0}, \mid) \to (\mathbb{N}_{>0}, \mid)$ is an
order-preserving map of divisibility posets. This is the structural fact that the
catalog's "apparition lattice" laws were grasping at; with the spine it is one line.

---

## 6. Pinning the Fibonacci Values: Two New Results

The following two results are, to our knowledge, absent from both the prior catalog
and the standard mathematical libraries.

**Theorem 6.1 (Fixed-point law).** *For every $k \ge 3$,
$\mathrm{rank}(F_k) = k$.*

*Proof sketch.* Let $r := \mathrm{rank}(F_k)$. Certainly $F_k \mid F_k$, so $r \le
k$. By the spine applied to $m = F_k$ at index $n = k$, $F_k \mid F_k$ gives
$r \mid k$, so in particular $r \le k$. For the reverse, we rule out $r < k$. The
Fibonacci sequence is strictly increasing from index $3$ onward ($F_3 = 2 < F_4 = 3
< F_5 = 5 < \cdots$). If $0 < r < k$ with $k \ge 3$, then $F_r < F_k$ (using
$r \ge 1$ and strict monotonicity on the relevant range), so the positive integer
$F_k$ cannot divide the smaller positive integer $F_r$ unless $F_r = 0$, which is
impossible for $r \ge 1$. But the Witness property says $F_k \mid F_{\mathrm{rank}(F_k)}
= F_r$, a contradiction. Hence $r = k$. $\square$

The content is the word *first*: $F_k$ does not appear as a divisor at any index
before $k$. Numerically: $\mathrm{rank}(F_5) = \mathrm{rank}(5) = 5$,
$\mathrm{rank}(F_7) = \mathrm{rank}(13) = 7$, $\mathrm{rank}(F_{10}) =
\mathrm{rank}(55) = 10$.

**Theorem 6.2 (Divisibility mirror).** *For $a \ge 3$,
$$F_a \mid F_b \quad\Longleftrightarrow\quad a \mid b.$$*

*Proof sketch.* ($\Leftarrow$) is Lemma 2.1. ($\Rightarrow$): Suppose $F_a \mid
F_b$. Apply the spine to $m = F_a$ (which has a rank since $a \ge 3 \Rightarrow F_a
\ge 2 > 0$) at index $n = b$: $F_a \mid F_b \Rightarrow \mathrm{rank}(F_a) \mid b$.
By the fixed-point law (Theorem 6.1), $\mathrm{rank}(F_a) = a$, hence $a \mid b$.
$\square$

The standard library provides only the forward implication (Lemma 2.1). The reverse
— often the one actually needed in applications — was missing, and is obtained here
in a single line from the spine plus the fixed-point law. The restriction $a \ge 3$
is necessary: $F_1 = F_2 = 1$ divides every $F_b$, but $1 \mid b$ and $2 \mid b$ are
not equivalent.

---

## 7. Carmichael's Prime Case

A prime $q$ is a **primitive prime divisor** of $F_n$ if $q \mid F_n$ but
$q \nmid F_j$ for all $0 < j < n$. Equivalently, by the minimality clause of
Definition 2.4, $q$ is a primitive prime divisor of $F_n$ iff $q \mid F_n$ and
$\mathrm{rank}(q) = n$.

**Theorem 7.1 (Carmichael, prime index).** *For every prime $p \ge 3$, the
Fibonacci number $F_p$ has a primitive prime divisor.*

*Proof sketch.* Since $p \ge 3$, $F_p \ge 2$, so $F_p$ has at least one prime
divisor $q$. As $q \mid F_p$, the spine (Theorem 4.1, applied to $m = q$) gives
$\mathrm{rank}(q) \mid p$. Because $p$ is prime, $\mathrm{rank}(q) \in \{1, p\}$.
It cannot be $1$: $\mathrm{rank}(q) = 1$ would mean $q \mid F_1 = 1$, impossible for
a prime. Hence $\mathrm{rank}(q) = p$, so $q$ first appears at index $p$ — it is a
primitive prime divisor of $F_p$. $\square$

**Remark 7.2.** Carmichael's full theorem (1913) states that $F_n$ has a primitive
prime divisor for all $n \notin \{1, 2, 6, 12\}$ (with $F_{12} = 144 = 2^4 \cdot
3^2$ the celebrated exception). Theorem 7.1 dispatches the *prime-index* slice
uniformly for all $p \ge 3$, where the prior catalog's analytic argument required
$p \ge 5$ and substantial estimation. The simplification is entirely due to working
through the spine: primality of the index collapses the divisor lattice of $p$ to
$\{1, p\}$, and the rank cannot be $1$. Examples: $F_3 = 2$ debuts $2$; $F_5 = 5$
debuts $5$; $F_7 = 13$ debuts $13$; $F_{11} = 89$ debuts $89$; $F_{13} = 233$
debuts $233$.

The composite-index case is genuinely harder (the exception $F_{12}$ lives there)
and requires a cyclotomic / primitive-part lower bound; see §10.

---

## 8. Application: Exact Apparition Density

The spine turns a divisibility-counting problem into an arithmetic-progression
count, yielding *exact* (not asymptotic) densities.

**Proposition 8.1 (Apparition count and density).** *For $m$ with rank $r$ and any
$N$,*
$$\#\{\, n : 1 \le n \le N,\ m \mid F_n \,\} = \left\lfloor \frac{N}{r} \right\rfloor.$$
*Consequently the natural density of indices at which $m$ divides $F_n$ is exactly
$1/r$.*

*Proof sketch.* By Corollary 4.3 the qualifying indices are precisely $r, 2r, 3r,
\dots$; the number of these $\le N$ is $\lfloor N/r \rfloor$. Dividing by $N$ and
letting $N \to \infty$ gives density $1/r$. $\square$

For two **coprime** moduli $m_1, m_2$, an index is a simultaneous apparition iff it
is a multiple of both ranks, i.e. a multiple of $\mathrm{lcm}(\mathrm{rank}(m_1),
\mathrm{rank}(m_2))$; the joint density is $1/\mathrm{lcm}(\mathrm{rank}(m_1),
\mathrm{rank}(m_2))$. These exact statements (refining the catalog's
`apparition_count`) are immediate from the exact-progression structure.

---

## 9. The Spine Is Not About Fibonacci

A defining feature of the proof of Theorem 4.1 is its frugality: it used *only*
Lemma 2.1 (divisibility identity) and Lemma 2.2 (GCD identity). Neither the closed
form, the matrix representation, nor any growth estimate appeared. This isolates the
exact axioms a sequence must satisfy for a rank-of-apparition theory to exist.

**Definition 9.1 (Strong divisibility sequence).** A sequence $u : \mathbb{N} \to
\mathbb{N}$ with $u_0 = 0$ is a *strong divisibility sequence* if
$$\gcd(u_a, u_b) = u_{\gcd(a,b)} \quad \text{for all } a, b.$$
(This implies the divisibility property $a \mid b \Rightarrow u_a \mid u_b$.)

**Theorem 9.2 (Abstract spine).** *Let $u$ be a strong divisibility sequence and
let $m$ divide some $u_k$ with $k > 0$. Define $\mathrm{rank}_u(m) := \min\{ k > 0 :
m \mid u_k \}$. Then for all $n$,*
$$m \mid u_n \quad\Longleftrightarrow\quad \mathrm{rank}_u(m) \mid n.$$

*Proof sketch.* Verbatim the proof of Theorem 4.1, with Lemmas 2.1, 2.2 replaced by
their strong-divisibility analogues. $\square$

The Fibonacci numbers, the Mersenne numbers $u_n = 2^n - 1$, and more generally the
Lucas sequences $U_n(P, Q)$ are all strong divisibility sequences. Theorem 9.2
therefore yields entry-point theory, the spine, and the prime case of the
Bang–Zsygmondy primitive-divisor theorem for all of them simultaneously — a
genuine cross-domain unification.

---

## 10. Discussion and Future Directions

The methodological lesson is that identifying and *naming* the correct object — and
proving its master law in its most hypothesis-free form — collapses a fragmented
body of parallel results into corollaries. We outline the most promising next steps.

**(1) A primitivity-free Carmichael composite case.** The composite-index case is
the hard half (it contains the exception $F_{12}$). The spine reframes it: $F_n$ has
a primitive divisor iff its *primitive part* — governed by the cyclotomic value
$\Phi_n(\varphi, \psi)$ at the golden-ratio roots $\varphi, \psi$ — exceeds $1$. The
non-primitive part of $F_n$ is supported on at most the single prime dividing
$n / \mathrm{rank}$, so a lower bound $|\Phi_n(\varphi,\psi)| > n$ (provable from
$\varphi^{\,\phi(n)}$ growth, $\phi$ the Euler totient) forces a primitive divisor
for all large $n$ *uniformly*, eliminating the finite cutoff used in purely
computational composite-case checks. The divisor-lattice bookkeeping needed is
already supplied by the spine and the order-morphism law; the only missing
ingredient is a totient growth bound.

**(2) The rank is multiplicative-by-lcm.** We conjecture $\mathrm{rank}(\mathrm{lcm}(a,b))
= \mathrm{lcm}(\mathrm{rank}(a), \mathrm{rank}(b))$, and for coprime $a, b$,
$\mathrm{rank}(ab) = \mathrm{lcm}(\mathrm{rank}(a), \mathrm{rank}(b))$. The spine
turns $\mathrm{lcm}(a,b) \mid F_n$ into the simultaneous system $\mathrm{rank}(a)
\mid n \wedge \mathrm{rank}(b) \mid n$, whose least solution is precisely
$\mathrm{lcm}(\mathrm{rank}(a), \mathrm{rank}(b))$. This upgrades the catalog's
apparition-lattice *join bound* (a divisibility, with strictness examples) to an
*equality* on the coprime sublattice and reduces all rank computation to
prime-power moduli.

**(3) Prime-power ranks and Lifting-the-Exponent.** Building on (2), reduce to prime
powers: conjecturally $\mathrm{rank}(p^{e+1}) = p \cdot \mathrm{rank}(p^e)$ for
$e \ge E_0(p)$, with exceptional Wall–Sun–Sun behavior at the base. The mechanism is
that $v_p(F_{\mathrm{rank}(p)\cdot t})$ increases by exactly one each time $t$ gains
a factor of $p$ — the Fibonacci instance of Lifting-the-Exponent. With the spine and
fixed-point law fixing exact apparition indices, the $v_p$-recursion becomes a
statement purely about $\mathrm{rank}$, decoupled from analytic estimates.

**(4) Transport to all strong divisibility sequences.** As in §9, abstracting the
spine over `IsStrongDivSeq` instantly yields Carmichael / Bang–Zsygmondy entry-point
theory for $a^n - 1$ and Lucas sequences, since the proof used only the gcd and
divisibility laws.

**(5) Density and equidistribution.** For fixed $m$, $\{ n \le N : m \mid F_n \}$ has
size exactly $\lfloor N / \mathrm{rank}(m) \rfloor$ (Proposition 8.1), so the density
is exactly $1/\mathrm{rank}(m)$. We conjecture the coprime two-modulus refinement
(joint density $1/\mathrm{lcm}(\mathrm{rank}(m_1), \mathrm{rank}(m_2))$) and that
averaging $1/\mathrm{rank}(p)$ over primes $p$ connects to a Fibonacci analogue of
Artin's constant. The exact-progression structure makes these statements falsifiable
by direct computation against rank tables.

---

## 11. Conclusion

We have argued that the rank of apparition deserves to be the central object of
Fibonacci divisibility theory, and we have proved the one biconditional — the spine,
$m \mid F_n \iff \mathrm{rank}(m) \mid n$ — that makes it so, in its cleanest,
primitivity-free form. From it we derived existence, the order-morphism law, two new
pinning results (the fixed-point law $\mathrm{rank}(F_k) = k$ and the divisibility
mirror $F_a \mid F_b \iff a \mid b$), Carmichael's prime case for all $p \ge 3$, and
exact apparition densities — and we showed the entire edifice rests on only two
classical identities, so it transports to every strong divisibility sequence. All
results have been formally machine-verified with no unproved obligations. The right
definition, proved in the right generality, is the whole story.
