# A Reflection Principle for Two-Summand Representation Counts, with Applications to the Goldbach Framework

## Abstract

We study the *representation count* of a natural number $n$ as an unordered sum
of two elements drawn from a prescribed set $A \subseteq \mathbb{N}$. Writing
$r_A(n)$ for the number of pairs $(p, n-p)$ with $p, n-p \in A$ and $p \le n-p$,
we prove a structural reflection theorem: when $A$ is symmetric about $n/2$ — that
is, closed under the involution $k \mapsto n-k$ on its elements not exceeding $n$ —
the count $r_A(n)$ equals simply the number of elements of $A$ in the lower half
$\{0,1,\dots,\lfloor n/2\rfloor\}$. From this single principle we derive: (i) the
exact count $r_{\mathbb{N}}(n) = \lfloor n/2\rfloor + 1$ for the unrestricted set;
(ii) a universal upper bound $r_A(n) \le \lfloor n/2\rfloor + 1$ valid for every
set $A$; and (iii) a complete parity-sensitive evaluation for the set of even
numbers, equal to $0$ when $n$ is odd and to $\lfloor (n/2)/2\rfloor + 1$ when
$n$ is even. We situate these results within the broader Goldbach circle of ideas,
explain why the primes evade the reflection principle, and discuss the sharp
parity barrier at $7$ governing the three-prime (ternary) problem. The
representation count is thereby isolated as a clean, finite, and computable object
equivalent to the representability question, and a natural target for
circle-method refinements.

**Keywords:** Goldbach's conjecture, additive number theory, representation
function, Goldbach partitions, parity obstruction, ternary Goldbach problem,
involution symmetry.

---

## 1. Introduction

Goldbach's binary conjecture asserts that every even integer $n \ge 4$ is the
sum of two primes. Despite its elementary statement and exhaustive numerical
confirmation, it remains open. A productive reframing replaces the binary
"is $n$ representable?" with the quantitative "in how many ways is $n$
representable?", because the resulting *representation function* carries
analytic, combinatorial, and probabilistic structure absent from a single
truth value. This paper develops the combinatorial backbone of that reframing in
full rigor for arbitrary summand sets, and applies it to the canonical cases.

Our central observation is that representation counting is, at heart, a problem
about a reflection. To split $n$ as $p + q$ is to choose the smaller part $p$;
the larger part $q = n - p$ is then forced. Counting unordered representations is
therefore counting admissible small parts in the lower half $[0, n/2]$, and a
representation $p$ is valid exactly when both $p$ and its mirror image $n - p$
lie in $A$. When $A$ is invariant under this mirror, the upper-half condition
becomes automatic and the count collapses to a half-count. We make this precise
and extract its consequences.

### 1.1 Contributions

1. **The Reflection Theorem** (Section 3): a structural identity computing
   $r_A(n)$ for any $A$ symmetric about $n/2$.
2. **Exact unrestricted count and universal bound** (Section 4): the value
   $\lfloor n/2\rfloor + 1$ for $A = \mathbb{N}$, and the same quantity as a
   ceiling for every $A$.
3. **Complete evaluation for even summands** (Section 5): a parity dichotomy
   giving $0$ or $\lfloor (n/2)/2\rfloor + 1$.
4. **Framework discussion** (Sections 6–7): why the primes break the reflection
   symmetry, the role of the count in circle-method approaches, and the sharp
   ternary threshold at $7$.

---

## 2. Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $\lfloor\,\cdot\,\rfloor$
denotes the floor. For $A \subseteq \mathbb{N}$ we write $k \in A$ for membership.

**Definition 2.1 (Representation count).**
For $A \subseteq \mathbb{N}$ and $n \in \mathbb{N}$, define
$$
r_A(n) \;=\; \#\bigl\{\, p \in \{0,1,\dots,n\} \;:\; p \in A,\ (n-p) \in A,\ p \le n-p \,\bigr\}.
$$
The condition $p \le n - p$ selects one representative from each unordered pair
$\{p, n-p\}$, so $r_A(n)$ counts *unordered* two-summand representations of $n$
with both summands in $A$. Restricting $p$ to $\{0,\dots,n\}$ loses nothing, since
$p \le n - p \le n$ forces $0 \le p \le n$.

**Definition 2.2 (Goldbach representation count).**
The Goldbach partition count is the special case $g(n) = r_{\mathbb{P}}(n)$, where
$\mathbb{P} = \{p \in \mathbb{N} : p \text{ prime}\}$. Goldbach's binary
conjecture is the assertion $g(n) \ge 1$ for all even $n \ge 4$.

**Definition 2.3 (Symmetry about $n/2$).**
A set $A \subseteq \mathbb{N}$ is *symmetric about $n/2$* if
$$
\forall k,\quad k \in A \ \text{and}\ k \le n \;\Longrightarrow\; (n - k) \in A.
$$
Equivalently, the involution $k \mapsto n - k$ maps $A \cap [0,n]$ into $A$.

Note $p \le n - p$ is equivalent to $p \le n/2$, hence to $p \le \lfloor n/2\rfloor$
for integers; we use these interchangeably.

---

## 3. The Reflection Theorem

**Theorem 3.1 (Reflection Theorem).**
Let $A \subseteq \mathbb{N}$ be symmetric about $n/2$. Then
$$
r_A(n) \;=\; \#\bigl\{\, p \in \{0,1,\dots,n\} : p \in A,\ p \le \lfloor n/2\rfloor \,\bigr\}.
$$
That is, $r_A(n)$ counts exactly the elements of $A$ in the lower half
$\{0, 1, \dots, \lfloor n/2 \rfloor\}$.

*Proof.* It suffices to show that the defining predicate of $r_A(n)$,
$$
P(p):\quad p \in A \ \wedge\ (n-p)\in A \ \wedge\ p \le n - p,
$$
agrees, over $p \in \{0,\dots,n\}$, with the predicate
$Q(p): p \in A \ \wedge\ p \le \lfloor n/2\rfloor$.

($P \Rightarrow Q$.) If $P(p)$ holds, then $p \in A$ and $p \le n - p$, the latter
giving $p \le \lfloor n/2\rfloor$. Hence $Q(p)$.

($Q \Rightarrow P$.) If $Q(p)$ holds, then $p \in A$ and $p \le \lfloor n/2\rfloor
\le n$. The bound $p \le n$ together with $p \in A$ and symmetry gives
$(n - p) \in A$. Moreover $p \le \lfloor n/2\rfloor$ implies $p \le n - p$. Hence
$P(p)$.

Since the predicates coincide on $\{0,\dots,n\}$, the two filtered sets are equal,
and so are their cardinalities. $\qquad\blacksquare$

The content of Theorem 3.1 is that for a mirror-invariant summand set the only
genuine constraint on a representation is membership of the *small* summand;
membership of the large summand is supplied by symmetry, and the ordering
condition is supplied by the half-range restriction.

---

## 4. The unrestricted count and a universal bound

We first record two elementary counting lemmas that the reflection principle
feeds into.

**Lemma 4.1 (Lower-half cardinality).**
For $m \le n$,
$$
\#\bigl\{ p \in \{0,\dots,n\} : p \le m \bigr\} = m + 1.
$$
*Proof.* The set in question is exactly $\{0, 1, \dots, m\}$, since $p \le m \le n$,
which has $m + 1$ elements. $\qquad\blacksquare$

**Lemma 4.2 (Even count in an initial segment).**
For $M \in \mathbb{N}$,
$$
\#\bigl\{ p \in \{0,\dots,M\} : p \text{ even} \bigr\} = \lfloor M/2\rfloor + 1.
$$
*Proof.* The map $i \mapsto 2i$ is a bijection from $\{0, 1, \dots, \lfloor M/2\rfloor\}$
onto $\{p \le M : p \text{ even}\}$, with inverse $p \mapsto p/2$. Indeed $2i \le M$
iff $i \le \lfloor M/2\rfloor$, and $2(p/2) = p$ for even $p$ while $(2i)/2 = i$
always. A bijection preserves cardinality, and the domain has
$\lfloor M/2\rfloor + 1$ elements. $\qquad\blacksquare$

**Theorem 4.3 (Unrestricted count).**
For the full set $A = \mathbb{N}$,
$$
r_{\mathbb{N}}(n) = \left\lfloor \tfrac{n}{2}\right\rfloor + 1.
$$
*Proof.* $\mathbb{N}$ is trivially symmetric about $n/2$ (every $n-k \in \mathbb{N}$),
so Theorem 3.1 reduces $r_{\mathbb{N}}(n)$ to the count of all
$p \le \lfloor n/2\rfloor$ in $\{0,\dots,n\}$. Since $\lfloor n/2\rfloor \le n$,
Lemma 4.1 with $m = \lfloor n/2\rfloor$ gives $\lfloor n/2\rfloor + 1$.
$\qquad\blacksquare$

The same statement holds for the finite "range" set $\{x : x < n + 1\} =
\{0,1,\dots,n\}$, which is likewise symmetric about $n/2$ because
$n - k \le n < n + 1$; the reflection principle yields $r(n) = \lfloor n/2\rfloor + 1$
identically.

**Theorem 4.4 (Universal upper bound).**
For every $A \subseteq \mathbb{N}$ and every $n$,
$$
r_A(n) \le \left\lfloor \tfrac{n}{2}\right\rfloor + 1.
$$
*Proof.* Every $p$ counted by $r_A(n)$ satisfies $p \le n - p$, hence
$p \le \lfloor n/2\rfloor$. Thus the set counted by $r_A(n)$ injects into
$\{p \le \lfloor n/2\rfloor\}$, whose cardinality is $\lfloor n/2\rfloor + 1$ by
Lemma 4.1. Monotonicity of cardinality under inclusion gives the bound.
$\qquad\blacksquare$

Theorem 4.4 needs no symmetry hypothesis: the ordering constraint alone caps the
count. In particular the Goldbach partition count satisfies
$g(n) \le \lfloor n/2\rfloor + 1$ for all $n$.

---

## 5. The even summand set: a parity dichotomy

We now evaluate $r_E(n)$ completely for $E = \{m \in \mathbb{N} : m \text{ even}\}$,
the canonical *asymmetric-by-parity* test case.

**Theorem 5.1 (Odd targets).**
If $n$ is odd, then $r_E(n) = 0$.
*Proof.* A counted $p$ would require $p$ even and $n - p$ even; but the sum of two
even numbers is even, contradicting $n$ odd. Hence no $p$ qualifies and the count
is $0$. (Formally, $p$ even and $n-p$ even force $n = p + (n-p)$ even.)
$\qquad\blacksquare$

**Theorem 5.2 (Even targets).**
If $n$ is even, then
$$
r_E(n) = \left\lfloor \tfrac{n/2}{2}\right\rfloor + 1.
$$
*Proof.* For even $n$, the set $E$ is symmetric about $n/2$: if $k$ is even and
$k \le n$, then $n - k$ is even (difference of evens), so $n - k \in E$. Theorem 3.1
applies and reduces $r_E(n)$ to the number of even $p \le \lfloor n/2\rfloor$ in
$\{0,\dots,n\}$, i.e. to $\#\{p \le n/2 : p \text{ even}\}$. By Lemma 4.2 with
$M = n/2$ this is $\lfloor (n/2)/2\rfloor + 1$. $\qquad\blacksquare$

Theorem 5.1 is a clean miniature of the *parity obstruction* pervasive in
additive number theory: representability can fail for a structural arithmetic
reason (a forbidden residue class) rather than mere scarcity of summands. Theorem
5.2 shows that once the obstruction is absent, the reflection principle delivers
an exact, closed-form count.

---

## 6. Why the primes resist

The reflection principle (Theorem 3.1) computes $r_A(n)$ outright whenever $A$ is
symmetric about $n/2$. The set of primes is conspicuously *not* symmetric: for
$p$ prime, $n - p$ is prime only sometimes — and *that this happens at least once*
is exactly Goldbach's conjecture. Thus the reflection theorem cannot be applied
to $\mathbb{P}$ directly; it instead furnishes:

- an **exact ceiling**, $g(n) \le \lfloor n/2\rfloor + 1$ (Theorem 4.4); and
- **solved shadow problems** — the unrestricted count (Theorem 4.3) and the even
  count (Theorems 5.1–5.2) — which any complete theory of $g(n)$ must reproduce
  as the contributions of larger symmetric or residue-defined superstructures.

The gap between the prime count and the symmetric ideal is precisely the
arithmetic content of Goldbach. The Hardy–Littlewood circle method attacks this
gap by writing the ordered representation count as a Fourier integral of the
prime-counting exponential sum $S(\alpha) = \sum_{p \le n} e^{2\pi i \alpha p}$:
$$
R(n) = \int_0^1 S(\alpha)^2 \, e^{-2\pi i \alpha n}\, d\alpha,
$$
and isolating a *main term* from neighborhoods of rationals with small
denominator (the major arcs). The conjectured asymptotic for the ordered count is
$$
R(n) \sim \mathfrak{S}(n)\,\frac{n}{(\log n)^2},
\qquad
\mathfrak{S}(n) = 2\!\prod_{p>2}\!\Bigl(1 - \tfrac{1}{(p-1)^2}\Bigr)\!\!\prod_{\substack{p\mid n\\ p>2}}\!\frac{p-1}{p-2},
$$
where $\mathfrak{S}(n)$ is the *singular series*. The unordered count studied here
is the symmetrized, exactly-controlled combinatorial skeleton on which such
analytic estimates are hung; its divergence $g(n) \to \infty$ is the quantitative
heart of every circle-method approach.

---

## 7. The ternary problem and the sharp threshold at 7

The ternary (odd) Goldbach problem asks whether every odd $n \ge 7$ is a sum of
three primes. In contrast to the binary case this is settled: every sufficiently
large odd number is a sum of three primes, and the bound has been lowered to cover
all odd $n \ge 7$.

**Proposition 7.1 (Reduction and sharp threshold).**
If $n$ is odd and $n \ge 7$, then $n - 3$ is even and $n - 3 \ge 4$; hence any
binary Goldbach split $n - 3 = p + q$ yields a ternary representation
$n = 3 + p + q$. The threshold $7$ is sharp for this reduction: it is the least
odd number for which $n - 3$ lands in the even-Goldbach domain $\{4, 6, 8, \dots\}$.

*Proof.* For odd $n \ge 7$, $n - 3$ is even (odd minus odd) and $n - 3 \ge 4$. For
odd $n < 7$, i.e. $n \in \{1,3,5\}$, the value $n - 3 \in \{-2, 0, 2\}$ never lies
in $\{4,6,\dots\}$, so the peel-off reduction is unavailable. $\qquad\blacksquare$

Proposition 7.1 explains structurally why $7$ is the natural starting point of the
ternary statement: it is exactly where subtracting the smallest odd prime drops
the problem into the binary regime.

---

## 8. Algorithms

We give two algorithms underpinning the computational side of the framework.

**Algorithm A (Goldbach partition count).** Given even $n$, sieve the primes up to
$n$ and count $p \le n/2$ with both $p$ and $n - p$ prime. Sieving is
$O(n \log\log n)$; the scan is $O(n)$. The output equals $g(n)$, and by Theorem
4.4 it never exceeds $\lfloor n/2\rfloor + 1$.

**Algorithm B (Smallest-summand search).** Given even $n \ge 4$, iterate primes
$p = 2, 3, 5, \dots$ in increasing order and return the first with $n - p$ prime.
Empirically the smallest summand grows only poly-logarithmically, motivating the
bounded-summand conjecture below; each primality check is fast via a sieve or a
Miller–Rabin test.

Both are finite, decidable procedures; running Algorithm A over $4 \le n \le N$
verifies the binary conjecture up to $N$.

---

## 9. Applications

- **Exact benchmarking.** Theorems 4.3 and 5.2 supply closed forms against which
  any implementation of a representation counter can be validated bit-for-bit.
- **A priori bounds.** Theorem 4.4 gives an immediate, hypothesis-free ceiling on
  Goldbach partition counts, useful in pruning searches and in normalizing
  empirical densities.
- **Parity diagnostics.** Theorem 5.1 models, in the simplest possible setting,
  the parity obstruction that any sieve-theoretic attack must respect.
- **Reduction templates.** Proposition 7.1 is the prototype for peel-off
  reductions linking $k$-summand problems to $(k-1)$-summand problems.

---

## 10. Discussion and future work

The reflection principle cleanly separates the *easy* (symmetric, residue-defined)
structure of two-summand representation counts from the *hard* (prime, asymmetric)
arithmetic that constitutes Goldbach's conjecture. By isolating $r_A(n)$ as a
finite, exactly computable object, the framework converts representability into a
growth question about a count — the form in which analytic methods are most
powerful.

Several directions extend the present work.

1. **Bounded-summand strengthening.** Conjecturally there is an absolute constant
   $C$ such that every even $n \ge 6$ admits $n = p + q$ with the smaller prime
   $p \le C(\log n)^2$. Exhaustive scans show the smaller summand never exceeds a
   slowly growing envelope, and sieve bounds on prime gaps make the
   $(\log n)^2$ envelope concrete and testable far beyond current data.

2. **Residue-balanced partitions.** For each modulus $m$ and large compatible even
   $n$, the number of Goldbach partitions realizing each admissible residue pair
   $(a, b) \bmod m$ should be asymptotically proportional to a fixed local
   density, with no admissible pair omitted. The rigid $\bmod 4$ dichotomy — shared
   class when $n \equiv 2 \pmod 4$, split classes when $n \equiv 0 \pmod 4$ — is
   the first visible layer of this local-density law and connects directly to the
   singular series.

3. **Monotonicity of the count.** The ordered count $r(n)$ should be eventually
   non-collapsing: dips below previous values occur only on a density-zero set,
   and $r(n) \to \infty$. The count inherits smoothing from the self-convolution
   of the prime indicator, forcing isolated dips to be rare.

4. **Sharpness of the ternary threshold.** Every odd $n \ge 7$ is a sum of three
   primes, with $7$ sharp as the least odd number for which the reduction
   $n = 3 + (n - 3)$ to an even Goldbach instance is available.

---

## 11. Conclusion

We have established a reflection principle for two-summand representation counts
and used it to compute the unrestricted count, a universal upper bound, and a
complete parity-sensitive evaluation for even summands. These results form a
rigorous, self-contained combinatorial foundation for the quantitative study of
Goldbach's conjecture, sharply delineating the symmetric structure we fully
understand from the prime arithmetic that remains the central open problem.
