# A Matsuno-Type Formula for Supersingular $2$-adic Iwasawa $\lambda$-Invariants

## Abstract

Let $E$ be an elliptic curve over $\mathbb{Q}$ with good supersingular reduction
at $2$ and square-free conductor $N_E$, and let $D > 0$ be a square-free integer
with $D \equiv 1 \pmod 4$. A Matsuno-type theorem predicts that, under the
assumption of a vanishing $\mu$-invariant, the difference of the sharp/flat
$2$-adic Iwasawa $\lambda$-invariants of the quadratic twist $E^D$ and of $E$ is
a purely local sum over the prime divisors of $D$. Each prime $\ell \mid D$
contributes a local term $\delta(\ell)$ determined by whether $\ell$ divides
$N_E$, by the parity of the order of the reduction of $E$ modulo $\ell$, and by a
$2$-adic depth $n_\ell = v_2\!\big((\ell^2 - 1)/8\big)$. In this paper we isolate
and rigorously analyze the arithmetic content of the right-hand side of this
formula. We prove a closed form for the depth, $n_\ell + 3 = v_2(\ell - 1) +
v_2(\ell + 1)$ for all odd $\ell \ge 3$; we establish that the total invariant is
additive over coprime twisting parameters and monotone under divisibility of the
square-free level; and we show that on a single prime the invariant reduces to
its local term. These structural results are the algebraic skeleton of the
Matsuno-type formula: additivity is the shadow of the multiplicativity of
quadratic twisting, and monotonicity reflects the non-negativity of local
ramification contributions.

**Keywords:** Iwasawa theory, supersingular reduction, $\lambda$-invariant,
quadratic twist, $2$-adic valuation, elliptic curves, additive arithmetic
functions.

**Mathematics Subject Classification:** 11R23 (Iwasawa theory), 11G05 (elliptic
curves over global fields), 11S15 (ramification and extension theory).

---

## 1. Introduction

Iwasawa theory studies arithmetic invariants of an object — a number field, a
Galois representation, an elliptic curve — not in isolation, but along an
infinite tower of extensions, typically the cyclotomic $\mathbb{Z}_p$-extension
of $\mathbb{Q}$. To an elliptic curve $E/\mathbb{Q}$ and a prime $p$ one attaches
a $p$-adic $L$-function and, via the Iwasawa Main Conjecture, a characteristic
ideal of a Selmer module. The two most fundamental numerical invariants extracted
from this data are the $\mu$-invariant and the $\lambda$-invariant, which
respectively govern the $p$-power and polynomial growth of Selmer groups up the
tower.

When $E$ has good *ordinary* reduction at $p$, the classical Mazur theory applies
directly, and the $\lambda$-invariant is the degree of the distinguished
polynomial factor of a bounded $p$-adic $L$-function. When $E$ has good
*supersingular* reduction, the $p$-adic $L$-function is unbounded and the naive
theory fails. To repair it, one introduces a pair of invariants — commonly
called the **sharp** ($\sharp$) and **flat** ($\flat$) $\lambda$-invariants — via
the $\pm$/sharp-flat theory of Kobayashi, Pollack, Sprung, and others. These
invariants are integers that faithfully record the polynomial growth of the
supersingular Selmer groups.

A recurrent theme in the subject is the behavior of these invariants under
**quadratic twisting**. Given a square-free integer $D$, the quadratic twist
$E^D$ is a new elliptic curve, isomorphic to $E$ over $\mathbb{Q}(\sqrt{D})$ but
generally inequivalent over $\mathbb{Q}$. Matsuno-type formulas express the
change in $\lambda$-invariant under twisting as a sum of local contributions,
one for each prime dividing the twisting parameter. The purpose of this paper is
to isolate, state precisely, and rigorously prove the structural properties of
the arithmetic function that appears on the right-hand side of the supersingular
$2$-adic Matsuno formula.

### 1.1 The setting

Throughout, $E$ is an elliptic curve over $\mathbb{Q}$ with:

- good supersingular reduction at the prime $2$;
- square-free conductor $N_E$;

and $D > 0$ is a square-free integer with $D \equiv 1 \pmod 4$. We assume the
relevant $\mu$-invariants vanish, which holds in the vast majority of cases and
is a standard hypothesis in this circle of ideas.

### 1.2 Statement of the governing formula

For an odd prime $\ell$, define the **$2$-adic depth**
$$n_\ell = v_2\!\left(\frac{\ell^2 - 1}{8}\right),$$
where $v_2$ is the $2$-adic valuation. Let $\mathrm{ord}(\ell)$ denote the order
of the reduction of $E$ modulo $\ell$ (the number of points on the reduced
curve, or any quantity whose parity encodes the relevant local ramification;
what matters for the arithmetic skeleton is its parity). Define the **local
contribution**
$$
\delta(\ell) =
\begin{cases}
2^{n_\ell}, & \ell \mid N_E, \\[2pt]
2^{n_\ell + 1}, & \ell \nmid N_E \text{ and } \mathrm{ord}(\ell) \text{ even}, \\[2pt]
0, & \text{otherwise.}
\end{cases}
$$

The Matsuno-type formula asserts
$$\boxed{\;\lambda^{\sharp/\flat}(E^D) - \lambda^{\sharp/\flat}(E) = \sum_{\ell \mid D} \delta(\ell)\;}$$
where the sum ranges over the prime divisors $\ell$ of $D$.

### 1.3 What this paper proves

The $\lambda$-invariant difference itself relies on the full analytic apparatus
of supersingular Iwasawa theory. What we can — and do — establish rigorously is
the complete structural theory of the right-hand side, regarded as an explicit
arithmetic function. Our main results are:

1. **(Depth closed form.)** For every odd $\ell \ge 3$,
   $$n_\ell + 3 = v_2(\ell - 1) + v_2(\ell + 1).$$
2. **(Local bound.)** For all inputs, $0 \le \delta(\ell) \le 2^{n_\ell + 1}$.
3. **(Reduction to a prime.)** For a prime $p$, the total invariant of level $p$
   equals $\delta(p)$.
4. **(Additivity over coprime moduli.)** For coprime nonzero $a, b$,
   $$\Lambda(ab) = \Lambda(a) + \Lambda(b),$$
   where $\Lambda(D) = \sum_{\ell \mid D} \delta(\ell)$.
5. **(Monotonicity in the level.)** If $d \mid D$ with $D \ne 0$, then
   $\Lambda(d) \le \Lambda(D)$.

Together these say that $\Lambda$ is an additive, monotone, locally computable
model of the supersingular $\lambda$-difference, with a closed-form depth.

---

## 2. Definitions

We work with non-negative integer valued arithmetic functions; the twisting
parameter and conductor are natural numbers, and the "reduction order" is modeled
as an arbitrary function $\mathrm{ord} : \mathbb{N} \to \mathbb{N}$ whose parity
carries the local information.

**Definition 2.1 (Depth).** For $\ell \in \mathbb{N}$ set
$$n_\ell := v_2\!\left(\left\lfloor \frac{\ell^2 - 1}{8} \right\rfloor\right).$$
For odd $\ell \ge 3$ the argument $(\ell^2 - 1)/8$ is a positive integer, so the
floor is immaterial and $n_\ell = v_2\big((\ell^2-1)/8\big)$.

**Definition 2.2 (Local contribution).** Given a conductor $N_E$, a parity
oracle $\mathrm{ord}$, and a prime $\ell$, the local contribution is
$$
\delta_{N_E,\mathrm{ord}}(\ell) =
\begin{cases}
2^{n_\ell}, & \ell \mid N_E, \\
2^{n_\ell + 1}, & \ell \nmid N_E \text{ and } 2 \mid \mathrm{ord}(\ell), \\
0, & \text{otherwise.}
\end{cases}
$$

**Definition 2.3 (Global invariant).** For a square-free level $D$,
$$\Lambda(D) := \sum_{\ell \in \mathcal{P}(D)} \delta_{N_E,\mathrm{ord}}(\ell),$$
where $\mathcal{P}(D)$ is the set of prime divisors of $D$.

These three definitions are computable: given $D$, $N_E$, and the parity oracle,
$\Lambda(D)$ is obtained by factoring $D$, computing each depth by trial division
by $2$, and summing.

---

## 3. The $2$-adic depth

### 3.1 Divisibility by $8$

**Lemma 3.1.** For odd $\ell$, $\;8 \mid \ell^2 - 1$.

*Proof sketch.* Write $\ell^2 - 1 = (\ell - 1)(\ell + 1)$, a product of two
consecutive even integers. Of any two consecutive even integers one is divisible
by $4$ and the other by exactly $2$, so their product is divisible by
$4 \cdot 2 = 8$. $\qquad\blacksquare$

This is what makes Definition 2.1 sensible: the quantity $(\ell^2-1)/8$ is a
genuine non-negative integer for odd $\ell$.

### 3.2 Valuation of $\ell^2 - 1$

**Lemma 3.2.** For odd $\ell \ge 3$, $\;v_2(\ell^2 - 1) = n_\ell + 3.$

*Proof sketch.* By Lemma 3.1 we may write $\ell^2 - 1 = 8 \cdot m$ with
$m = (\ell^2-1)/8$ a positive integer. Since $v_2$ is additive on products and
$v_2(8) = 3$,
$$v_2(\ell^2 - 1) = v_2(8) + v_2(m) = 3 + n_\ell.$$
Positivity of $m$ (which holds because $\ell \ge 3$) is needed to apply
additivity of the valuation. $\qquad\blacksquare$

### 3.3 Closed form for the depth

**Theorem 3.3 (Depth closed form).** For every odd $\ell \ge 3$,
$$n_\ell + 3 = v_2(\ell - 1) + v_2(\ell + 1),$$
equivalently $n_\ell = v_2(\ell - 1) + v_2(\ell + 1) - 3$.

*Proof sketch.* Factor $\ell^2 - 1 = (\ell - 1)(\ell + 1)$. Both factors are
positive for $\ell \ge 3$, so additivity of the $2$-adic valuation gives
$$v_2(\ell^2 - 1) = v_2(\ell - 1) + v_2(\ell + 1).$$
Combining with Lemma 3.2, $\;n_\ell + 3 = v_2(\ell - 1) + v_2(\ell + 1)$.
$\qquad\blacksquare$

**Remark 3.4 (Residue stratification).** Theorem 3.3 makes the depth transparent
modulo powers of $2$. Since exactly one of $\ell - 1, \ell + 1$ is $\equiv 0
\pmod 4$:

- $n_\ell = 0 \iff \ell \equiv 3 \text{ or } 5 \pmod 8$ (the "$4$-divisible"
  factor has valuation exactly $2$ and the other exactly $1$);
- $n_\ell \ge 1 \iff \ell \equiv \pm 1 \pmod 8$;
- large values of $n_\ell$ occur precisely along $\ell \equiv 1 \pmod 8$
  (equivalently $\ell \equiv 7 \pmod 8$ contributes deep valuation through
  $\ell+1$), where one factor absorbs many powers of $2$.

The sample values $n_3 = n_5 = 0$, $n_7 = 1$, $n_{17} = 2$, $n_{31} = 3$,
$n_{97} = 3$ confirm the pattern.

---

## 4. The local contribution

**Proposition 4.1 (Local bound).** For all $N_E$, $\mathrm{ord}$, $\ell$,
$$0 \le \delta_{N_E,\mathrm{ord}}(\ell) \le 2^{n_\ell + 1}.$$

*Proof sketch.* By definition $\delta$ takes one of the three values $2^{n_\ell}$,
$2^{n_\ell + 1}$, or $0$. All three are non-negative, and the largest is
$2^{n_\ell + 1}$ (since $2^{n_\ell} \le 2^{n_\ell+1}$ and $0 \le 2^{n_\ell+1}$).
$\qquad\blacksquare$

**Proposition 4.2 (Ramified primes).** If $\ell \mid N_E$ then
$\delta_{N_E,\mathrm{ord}}(\ell) = 2^{n_\ell}$.

*Proof sketch.* Immediate from the first case of Definition 2.2. $\qquad\blacksquare$

These facts confirm that a prime of bad reduction (dividing the conductor) always
contributes the base power $2^{n_\ell}$, while a good prime with even reduction
order contributes twice as much, $2^{n_\ell+1}$; all other good primes contribute
nothing. The doubling in the good-even case reflects that such a prime becomes
newly ramified in the twist, whereas a conductor prime is already ramified.

---

## 5. The global invariant

### 5.1 Reduction on a single prime

**Proposition 5.1.** For a prime $p$, $\;\Lambda(p) = \delta_{N_E,\mathrm{ord}}(p)$.

*Proof sketch.* The set of prime divisors of a prime $p$ is the singleton
$\{p\}$, so the defining sum collapses to its single term $\delta(p)$.
$\qquad\blacksquare$

### 5.2 Additivity over coprime moduli

**Theorem 5.2 (Additivity).** Let $a, b$ be nonzero natural numbers with
$\gcd(a, b) = 1$. Then
$$\Lambda(ab) = \Lambda(a) + \Lambda(b).$$

*Proof sketch.* The set of prime divisors of a product satisfies
$\mathcal{P}(ab) = \mathcal{P}(a) \cup \mathcal{P}(b)$, and coprimality of $a$
and $b$ makes this union **disjoint**: no prime divides both $a$ and $b$.
Splitting a sum over a disjoint union,
$$
\Lambda(ab) = \sum_{\ell \in \mathcal{P}(a) \sqcup \mathcal{P}(b)} \delta(\ell)
= \sum_{\ell \in \mathcal{P}(a)} \delta(\ell) + \sum_{\ell \in \mathcal{P}(b)} \delta(\ell)
= \Lambda(a) + \Lambda(b). \qquad\blacksquare
$$

**Remark 5.3.** The coprimality hypothesis is essential and the theorem is not
vacuous: if $a$ and $b$ shared a prime $\ell$, that prime would appear once in
$\mathcal{P}(ab)$ but be counted in both $\Lambda(a)$ and $\Lambda(b)$, so the
identity would overshoot by $\delta(\ell)$. Additivity is the arithmetic shadow
of the multiplicativity of quadratic twisting: $E^{ab}$ is the twist of $E^a$ by
$b$, and when $a, b$ are coprime the local ramification data at the primes of $a$
and of $b$ do not interfere.

### 5.3 Monotonicity in the level

**Theorem 5.4 (Monotonicity).** Let $d, D$ be natural numbers with $d \mid D$ and
$D \ne 0$. Then
$$\Lambda(d) \le \Lambda(D).$$

*Proof sketch.* If $d \mid D$ and $D \ne 0$, then every prime dividing $d$ also
divides $D$, so $\mathcal{P}(d) \subseteq \mathcal{P}(D)$. Since each term
$\delta(\ell) \ge 0$ (Proposition 4.1), summing over the larger set can only
increase the total:
$$
\Lambda(d) = \sum_{\ell \in \mathcal{P}(d)} \delta(\ell)
\le \sum_{\ell \in \mathcal{P}(D)} \delta(\ell) = \Lambda(D). \qquad\blacksquare
$$

The non-negativity of every local term is genuine content here, since we work
over the non-negative integers: monotonicity would fail for a signed invariant.

### 5.4 Consequences

Theorems 5.2 and 5.4 together characterize $\Lambda$ as a **completely additive,
monotone** arithmetic function on square-free arguments, determined entirely by
its values $\delta(\ell)$ on primes. In particular, for square-free
$D = \ell_1 \cdots \ell_r$ with distinct primes $\ell_i$,
$$\Lambda(D) = \sum_{i=1}^r \delta(\ell_i),$$
a direct consequence of iterating additivity, and any tower
$d_1 \mid d_2 \mid \cdots \mid D$ of square-free levels produces a
non-decreasing sequence $\Lambda(d_1) \le \Lambda(d_2) \le \cdots \le \Lambda(D)$.

---

## 6. Algorithms

### 6.1 Computing the depth

The closed form of Theorem 3.3 gives two ways to compute $n_\ell$: directly, by
computing $v_2\big((\ell^2-1)/8\big)$, or via $v_2(\ell-1) + v_2(\ell+1) - 3$.
Both are logarithmic in $\ell$. The second avoids the intermediate quadratic
$\ell^2$ and is preferable for large $\ell$.

**Algorithm (Depth via closed form).**
1. If $\ell$ is even or $\ell < 3$, handle separately (return the direct
   valuation).
2. Compute $a = v_2(\ell - 1)$ and $b = v_2(\ell + 1)$ by repeated division by
   $2$.
3. Return $a + b - 3$.

### 6.2 Computing the global invariant

**Algorithm (Global invariant).**
1. Factor $D$ into its distinct prime divisors $\ell_1, \dots, \ell_r$.
2. For each $\ell_i$: compute $n_{\ell_i}$; then determine $\delta(\ell_i)$ by
   the case analysis of Definition 2.2 using $N_E$ and the parity oracle.
3. Return $\sum_i \delta(\ell_i)$.

By Theorem 5.2 this procedure may be parallelized across coprime factors of $D$
without changing the result, and by Theorem 5.4 partial sums over divisors give
guaranteed lower bounds.

---

## 7. Applications

- **Fast tabulation of twist families.** Additivity means the invariant for a
  large square-free $D$ is assembled from a precomputed table of prime-level
  contributions $\delta(\ell)$, giving instant evaluation across an entire family
  of twists $\{E^D\}$.
- **Detecting invariant jumps.** Monotonicity identifies exactly which new prime
  factors cause the $\lambda$-difference to increase, isolating the arithmetically
  active primes in a twist tower.
- **Residue heuristics.** The stratification of Remark 3.4 predicts, from
  $\ell \bmod 8$ alone, the base depth of each prime's contribution, enabling
  average-order estimates over families ordered by size.

---

## 8. Discussion

The results here deliberately separate the *analytic* content of the
supersingular Matsuno formula (the identification of the left-hand
$\lambda$-difference) from its *arithmetic* content (the structure of the
right-hand local sum). The latter is complete and self-contained: a closed-form
depth, a bounded non-negative local term, additivity over coprime moduli, and
monotonicity in the level. These are precisely the properties one needs to treat
$\Lambda$ as a computable proxy for the $\lambda$-difference and to reason about
its behavior across families.

The conceptual payoff is the emergence of **locality**: a difference of global
Iwasawa invariants, defined through an infinite cyclotomic tower and the full
supersingular $L$-function machinery, decomposes into independent prime-by-prime
contributions with no global interaction term. Additivity encodes that the primes
do not talk to one another; monotonicity encodes that each prime can only add,
never subtract; and the depth closed form makes each contribution explicitly
computable from the residue of $\ell$ modulo powers of $2$.

---

## 9. Future Work

Several directions extend this arithmetic skeleton toward the full analytic
theory.

1. **Full additive realization.** Prove that the honest $\lambda$-difference
   $\lambda(E^D) - \lambda(E)$ is completely additive over coprime twisting
   parameters and matches $\Lambda(D)$ term-by-term, reducing the global identity
   to a single-prime local computation.
2. **Depth stratification by residue.** Establish that the distribution of
   $\delta(\ell)$ is governed by $\ell \bmod 8$ together with conductor
   divisibility and reduction-order parity, with $n_\ell = 0$ exactly for
   $\ell \equiv 3, 5 \pmod 8$ and unbounded growth only along $\ell \equiv 1
   \pmod 8$.
3. **Growth rate.** Show that the average of $\lambda(E^D) - \lambda(E)$ over
   square-free $D \le X$ grows like $c \log\log X$ for an explicit constant $c$,
   via Mertens-type estimates applied to the additive prime sum.
4. **Monotone towers.** Prove that along any tower of square-free levels the
   $\lambda$-difference is non-decreasing and stabilizes precisely when no new
   ramified prime with even reduction order is added.

---

## 10. Conclusion

We have isolated and rigorously established the arithmetic backbone of the
supersingular $2$-adic Matsuno formula. The local depth admits the closed form
$n_\ell = v_2(\ell - 1) + v_2(\ell + 1) - 3$ for odd $\ell \ge 3$; the local
contribution is non-negative and bounded by $2^{n_\ell + 1}$; and the assembled
global invariant is additive over coprime moduli and monotone under divisibility
of the square-free level. These results present the change in a deep global
invariant under quadratic twisting as a transparent, computable sum of
independent local $2$-adic depths.
