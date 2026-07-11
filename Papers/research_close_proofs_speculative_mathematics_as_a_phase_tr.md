# Sharp Arithmetic Transitions in the Fibonacci Sequence: A Lifting-the-Exponent Law and Its Threshold Interpretation

## Abstract

We establish an exact lifting-the-exponent law for the Fibonacci sequence: for an
odd prime $p$ that already divides $F_m$ (with $m \ge 1$), the $p$-adic valuation
of $F_{mp}$ exceeds that of $F_m$ by exactly one,
$$v_p\big(F_{mp}\big) = v_p\big(F_m\big) + 1.$$
The proof rests on a new closed-form *multiple-index binomial expansion*,
$$F_{(m+1)n} = \sum_{j=0}^{n} \binom{n}{j}\, F_m^{\,n-j}\, F_{m+1}^{\,j}\, F_j,$$
derived from the golden-ratio recurrence $\varphi^{m+1} = F_{m+1}\varphi + F_m$
and the irrationality of $\varphi$. Specialising to $n = p$ and performing a term-by-term
valuation analysis, we show that a single term attains the critical valuation
$v_p(F_m)+1$ while every other term is strictly deeper, pinning the valuation of
the sum. We explain why the oddness hypothesis is essential (the $p=2$ doubling
identity destroys uniqueness of the minimiser), and how the law supplies the
multiplicity-one input needed for the primitive-divisor (Zsigmondy/Carmichael)
theory of Fibonacci numbers. We then place the result in a broader conceptual
frame: that of *sharp thresholds* in monotone growth processes. Using mixed-radix
positional number systems — with the factorial number system as the distinguished
example — we formalise the notion of a critical length at which a monotone
value-predicate switches on, and we outline a program of threshold conjectures
(computability, product/compositional laws, and extremality of the factorial
system) that recast mathematical growth as a phase-transition phenomenon.

**Keywords:** Fibonacci numbers, $p$-adic valuation, lifting-the-exponent,
golden ratio, binomial expansion, primitive divisors, Zsigmondy's theorem,
mixed-radix, factorial number system, sharp threshold, phase transition.

---

## 1. Introduction

Many phenomena that appear to develop smoothly in fact reorganise abruptly at a
single critical point. Water freezes at a sharp temperature; a random graph
acquires a giant component at a sharp density; a monotone Boolean event flips on
at a sharp threshold. This paper studies an exact, discrete instance of such a
transition living inside the Fibonacci sequence, and then situates it within a
general theory of sharp thresholds for monotone growth processes.

The **Fibonacci sequence** is defined by
$$F_0 = 0, \quad F_1 = 1, \quad F_{k+2} = F_{k+1} + F_k.$$
Its divisibility structure is famously rigid: it is a *strong divisibility
sequence*, meaning $\gcd(F_a, F_b) = F_{\gcd(a,b)}$. Consequently each prime $p$
has a *rank of apparition* $\alpha(p)$, the least index with $p \mid F_{\alpha(p)}$,
and $p \mid F_n$ if and only if $\alpha(p) \mid n$.

Beyond the question of *whether* a prime divides a term lies the finer question
of *multiplicity*: how the $p$-adic valuation $v_p(F_n)$ evolves along the
arithmetic progression of indices divisible by $\alpha(p)$. Our main theorem
answers this in the sharpest possible form for odd primes: multiplying the index
by $p$ increments the valuation by exactly one.

### Contributions

1. **A multiple-index binomial expansion** (Theorem 3.1) expressing $F_{(m+1)n}$
   as a binomial-type sum in two consecutive Fibonacci numbers.
2. **A Fibonacci lifting-the-exponent law** (Theorem 4.1) for odd primes, proved
   by isolating a unique minimal-valuation term.
3. A discussion of why oddness is necessary and how the law feeds primitive-divisor
   theory (Section 5).
4. A **threshold/phase-transition framework** for monotone growth processes via
   mixed-radix systems, with the factorial number system as the key example, and
   a family of conjectures (Section 6).

---

## 2. Preliminaries and notation

Throughout, $p$ denotes a prime and $v_p(N)$ the $p$-adic valuation of a positive
integer $N$ (the exponent of $p$ in the prime factorisation of $N$), with the
convention $v_p(0) = +\infty$. We write $F_k$ for the $k$-th Fibonacci number and
$L_k$ for the $k$-th Lucas number ($L_0 = 2, L_1 = 1, L_{k+2}=L_{k+1}+L_k$).

We record three standard facts used below.

- **(P1) Coprimality of neighbours.** $\gcd(F_k, F_{k+1}) = 1$ for all $k$.
- **(P2) Binet / golden-ratio recurrence.** With $\varphi = \tfrac{1+\sqrt5}{2}$
  and $\psi = 1-\varphi = \tfrac{1-\sqrt5}{2}$, we have
  $F_k = (\varphi^k - \psi^k)/\sqrt5$, and $\varphi^{k+1} = F_{k+1}\varphi + F_k$
  (with the analogous identity for $\psi$).
- **(P3) Prime interior binomials.** For a prime $p$ and $0 < j < p$,
  $p \mid \binom{p}{j}$.

---

## 3. The multiple-index binomial expansion

Our engine is a closed-form expansion of a Fibonacci number at a product index.

> **Theorem 3.1 (Multiple-index binomial expansion).** For all $m, n \in \mathbb{N}$,
> $$F_{(m+1)n} \;=\; \sum_{j=0}^{n} \binom{n}{j}\, F_m^{\,n-j}\, F_{m+1}^{\,j}\, F_j.$$

**Proof sketch.** Write $a = F_m$, $b = F_{m+1}$. By (P2),
$\varphi^{m+1} = b\varphi + a$. Raising to the $n$-th power and applying the
binomial theorem,
$$\varphi^{(m+1)n} = (b\varphi + a)^n = \sum_{j=0}^{n}\binom{n}{j} a^{\,n-j} b^{\,j}\,\varphi^{j}.$$
The identical computation with $\psi$ in place of $\varphi$ gives
$$\psi^{(m+1)n} = \sum_{j=0}^{n}\binom{n}{j} a^{\,n-j} b^{\,j}\,\psi^{j}.$$
Subtracting and dividing by $\sqrt5$, then using Binet's formula
$F_k = (\varphi^k - \psi^k)/\sqrt5$ on each power $\varphi^{j}, \psi^{j}$, yields
$$F_{(m+1)n} = \frac{\varphi^{(m+1)n} - \psi^{(m+1)n}}{\sqrt5}
= \sum_{j=0}^{n}\binom{n}{j} a^{\,n-j} b^{\,j}\,\frac{\varphi^{j}-\psi^{j}}{\sqrt5}
= \sum_{j=0}^{n}\binom{n}{j} F_m^{\,n-j} F_{m+1}^{\,j} F_j.$$
Since both sides are integers, the identity holds over $\mathbb{Z}$. $\qquad\blacksquare$

Equivalently — matching the coefficients of $\{1,\varphi\}$ in
$\varphi^{(m+1)n} = (b\varphi+a)^n$, which are independent because $\varphi$ is
irrational — the coefficient of $\varphi$ is exactly $F_{(m+1)n}$, giving the same
formula. This "read off the $\varphi$-coefficient" viewpoint is the conceptual
heart of the identity.

**Sanity check.** For $n = 2$: the right side is
$F_m^2 F_0 + 2F_m F_{m+1} F_1 + F_{m+1}^2 F_2 = 2 F_m F_{m+1} + F_{m+1}^2$, while
$F_{2(m+1)} = F_{m+1}(2F_m + F_{m+1}) = F_{m+1} L_{m+1}$, and indeed
$2F_m F_{m+1} + F_{m+1}^2 = F_{m+1}(2F_m + F_{m+1})$. ✓

---

## 4. The Fibonacci lifting-the-exponent law

> **Theorem 4.1 (Fibonacci lifting-the-exponent).** Let $p$ be an odd prime and
> $m \ge 1$ with $p \mid F_m$. Then
> $$v_p\big(F_{mp}\big) = v_p\big(F_m\big) + 1.$$

**Proof sketch.** Put $v = v_p(F_m) \ge 1$. Apply Theorem 3.1 with the substitution
$m \mapsto m-1$, $n \mapsto p$ (valid since $m \ge 1$), so $(m-1)+1 = m$ and
$$F_{mp} = \sum_{j=0}^{p} \binom{p}{j}\, F_{m-1}^{\,p-j}\, F_m^{\,j}\, F_j
\;=:\; \sum_{j=0}^{p} T_j.$$
We estimate $v_p(T_j)$.

- **$j = 0$:** $T_0 = \binom{p}{0} F_{m-1}^p F_0 = 0$ since $F_0 = 0$. It drops out.
- **$2 \le j \le p-1$:** by (P3), $p \mid \binom{p}{j}$, contributing valuation
  $\ge 1$; and since $p \mid F_m$, the factor $F_m^{\,j}$ contributes valuation
  $jv \ge 2v \ge 2$. Hence $v_p(T_j) \ge 1 + 2v \ge v + 2$.
- **$j = p$:** here $\binom{p}{p} = 1$ and $F_m^{\,p}$ contributes valuation
  $pv \ge p \ge 3 \ge v+2$ (using $p \ge 3$ and, more carefully, $(p-1)v \ge 2$).
  So $v_p(T_p) \ge v + 2$.
- **$j = 1$:** $T_1 = p \cdot F_{m-1}^{\,p-1} \cdot F_m$. By (P1),
  $\gcd(F_{m-1}, F_m) = 1$, so $p \nmid F_{m-1}$ and $v_p(F_{m-1}^{\,p-1}) = 0$.
  Therefore $v_p(T_1) = 1 + 0 + v = v + 1$.

Thus modulo $p^{\,v+2}$ the entire sum reduces to its single $j = 1$ term:
$$F_{mp} \equiv p\, F_{m-1}^{\,p-1} F_m \pmod{p^{\,v+2}}.$$
The right-hand side has $p$-adic valuation exactly $v+1$: it is divisible by
$p^{\,v+1}$ (one factor of $p$ times $p^{v} \mid F_m$) but not by $p^{\,v+2}$
(because $p \nmid F_{m-1}$ and $v_p(F_m) = v$ exactly). Since the congruence is
modulo $p^{\,v+2}$, this forces $p^{\,v+1} \mid F_{mp}$ and $p^{\,v+2} \nmid F_{mp}$,
i.e. $v_p(F_{mp}) = v + 1$. $\qquad\blacksquare$

**The transition is sharp.** The proof is a competition among $p+1$ contributions
in which *exactly one*, the $j=1$ term, attains the critical valuation $v+1$; all
others are pushed to valuation $\ge v+2$. This uniqueness of the minimiser is the
arithmetic signature of a sharp transition — the surviving term plays the role of
an order parameter.

### 4.1 Iterating: the exact valuation staircase

Because the increment is exactly one, Theorem 4.1 iterates cleanly. If
$p \mid F_m$ with $v_p(F_m) = v_0$, then for every $r \ge 0$,
$$v_p\big(F_{m p^{r}}\big) = v_0 + r.$$
In particular, if $\alpha = \alpha(p)$ is the rank of apparition of an odd prime
$p$ with $e := v_p(F_\alpha)$, then $v_p(F_{\alpha p^r}) = e + r$. Combined with
the general rule "$p \mid F_n \iff \alpha \mid n$", this yields the standard
closed form for odd $p$:
$$v_p(F_n) = \begin{cases} v_p(F_\alpha) + v_p(n/\alpha), & \alpha \mid n,\\[2pt] 0, & \alpha \nmid n.\end{cases}$$
The single-step law is precisely the inductive core of this formula.

### 4.2 Why oddness is essential

For $p = 2$ the law fails. The doubling identity $F_{2k} = F_k L_k$ shows that
$v_2$ can jump by more than one: for instance $v_2(F_3) = v_2(2) = 1$ but
$v_2(F_6) = v_2(8) = 3$, a jump of $2$. Structurally, when $p = 2$ the $j=1$ term
is no longer the unique valuation-minimiser in the expansion, so the sharp
one-step transition dissolves. Oddness is exactly the hypothesis that restores
uniqueness of the minimiser.

---

## 5. Application: primitive divisors and multiplicity one

A **primitive divisor** of $F_n$ is a prime $p$ dividing $F_n$ but no earlier
term $F_k$ ($1 \le k < n$); equivalently $\alpha(p) = n$. The Fibonacci case of
the Zsigmondy–Carmichael theorem asserts that $F_n$ has a primitive divisor for
every $n$ outside a short exceptional list ($n \in \{1,2,6,12\}$, up to the usual
conventions).

Proving such existence results requires controlling multiplicities, not just
appearances. The relevant object is the **primitive part** (cyclotomic factor)
$$\Phi_n \;=\; \prod_{d \mid n} F_d^{\,\mu(n/d)},$$
where $\mu$ is the Möbius function; $\Phi_n$ is an integer that collects precisely
the "new" prime contributions at level $n$. Theorem 4.1 controls how an *intrinsic*
prime — one whose rank equals $n$ — sits inside $\Phi_n$: because the valuation
climbs by exactly one when the index is multiplied by $p$, an intrinsic odd prime
enters the primitive part with multiplicity exactly one. This multiplicity-one
input, together with a growth estimate $\Phi_n \asymp \varphi^{\varphi(n)}$
obtained from Binet's formula, is what forces the primitive part to exceed the
"intrinsic" contribution and hence guarantees a genuinely new prime.

The lifting-the-exponent law is thus the arithmetic engine of the theory: it
converts the qualitative statement "primes reappear periodically" into the
quantitative statement "their depth increases in unit steps", which is exactly
what the primitive-divisor argument needs. (The remaining analytic ingredient —
the sharp lower bound $\Phi_n > n$ for large composite $n$ — is a growth estimate
independent of the valuation law and is not treated here.)

---

## 6. A general framework: sharp thresholds in monotone growth

The unit-step behaviour of Section 4 is a concrete avatar of a general principle:
*monotone growth processes concentrate their transitions at sharp thresholds.*
We make this precise using positional number systems.

### 6.1 Mixed-radix systems and the factorial system

A **mixed-radix system** is a sequence of bases $(b_0, b_1, b_2, \dots)$ with each
$b_i \ge 2$. A *word* of length $n$ is a digit string $(d_0,\dots,d_{n-1})$ with
$0 \le d_i < b_i$, representing the value
$$\mathrm{val}(d) = \sum_{i=0}^{n-1} d_i \prod_{k < i} b_k.$$
Words of length $n$ realise exactly the values $0, 1, \dots, C_n - 1$, where the
**capacity** is $C_n = \prod_{k<n} b_k$. The distinguished example is the
**factorial number system**, with $b_i = i+1$; then $C_n = n!$, and a word of
length $n$ represents every value up to $n! - 1$.

### 6.2 Critical lengths and sharp thresholds

Call a predicate $Q$ on values **monotone** if $Q(x)$ and $x \le y$ imply $Q(y)$
(for example, "$x \ge N$"). Lift $Q$ to words by asking whether the *maximal*
value representable in length $n$, namely $C_n - 1$, satisfies $Q$. Because the
capacities $C_n$ are non-decreasing (indeed strictly increasing once bases exceed
$1$), the set of lengths at which the lifted predicate holds is an **up-set**: it
switches from false to true exactly once, at a **critical length**
$$\tau(Q) = \min\{\, n : Q(C_n - 1) \,\}.$$
This single crossing is a *sharp threshold* — the discrete analogue of a
percolation transition. For the capacity predicate "can represent the target $N$",
$\tau$ is the least $n$ with $C_n > N$; in the factorial system this is the least
$n$ with $n! > N$.

> **Proposition 6.1 (Sharp threshold for monotone value-predicates).** For any
> mixed-radix system with bases eventually $\ge 2$ and any monotone value-predicate
> $Q$, the lifted word-predicate holds precisely for lengths $n \ge \tau(Q)$; the
> transition occurs at a single critical length.

**Proof sketch.** Monotonicity of $Q$ and $C_n \le C_{n+1}$ imply that once the
predicate holds at length $n$ it holds at all greater lengths; hence the truth-set
is an up-set of $\mathbb{N}$, which (being nonempty and bounded below) has a least
element $\tau(Q)$. $\qquad\blacksquare$

### 6.3 Conjectural program

The threshold picture suggests a compositional calculus of transitions.

- **(C1) Computable critical length.** For any mixed-radix system with bases
  eventually $\ge 2$ and any monotone value-predicate, the critical length is a
  computable, monotone function of the predicate's parameters. *Rationale:* a
  monotone yes/no event on a well-ordered timeline forces the successful times to
  form an up-set, collapsing the transition to one threshold.
- **(C2) Products preserve sharpness.** If two independent monotone processes each
  undergo a sharp threshold at $\tau_1, \tau_2$, then "both succeed" is sharp at
  $\max(\tau_1, \tau_2)$ and "either succeeds" is sharp at $\min(\tau_1, \tau_2)$.
  *Rationale:* intersections and unions of up-sets are up-sets, so sharpness is a
  lattice invariant closed under the natural combinators.
- **(C3) Factorial is slowest to percolate.** Among mixed-radix systems whose
  bases are bounded by a fixed increasing envelope, the factorial system (bases
  $i+1$) has the largest capacity threshold for every target: its capacity crosses
  each level later than any competitor with uniformly smaller bases. *Rationale:*
  the running product $C_n$ is monotone in each base, so capacity thresholds are
  anti-monotone in the base sequence; the smallest admissible bases percolate
  slowest.

These conjectures turn "mathematics as a phase transition" from metaphor into a
concrete research target: identify the monotone sub-events of a growth process,
locate each threshold, and compose them by max/min laws.

---

## 7. Algorithms

We summarise the computational content; full pseudocode and code appear in the
accompanying material.

1. **Valuation-staircase verifier.** Given an odd prime $p$ and a base index $m$
   with $p \mid F_m$, compute $v_p(F_{m p^r})$ for $r = 0,1,\dots,R$ and confirm
   the arithmetic progression $v_0, v_0+1, \dots, v_0+R$ predicted by Theorem 4.1.
2. **Binomial-expansion checker.** For inputs $m, n$, evaluate both sides of
   Theorem 3.1 exactly (big integers) and verify equality; also verify the
   $j$-term valuation profile from the proof of Theorem 4.1.
3. **Critical-length finder.** Given a mixed-radix base sequence and a target $N$,
   compute the capacity threshold $\tau = \min\{n : C_n > N\}$ by streaming the
   running product; specialise to the factorial system.

---

## 8. Discussion

The Fibonacci lifting-the-exponent law is small in statement but structural in
role: it is the exact local law underlying the global primitive-divisor theory,
and it exemplifies the broader thesis that monotone growth concentrates change at
sharp thresholds. The proof technique — expand at a product index, then locate the
unique minimal-valuation term — is robust and should transfer to other Lucas
sequences and strong divisibility sequences, where analogous golden-ratio-style
recurrences hold.

Two boundaries of the present work are worth naming. First, the law is genuinely
about *odd* primes; the $p=2$ case has a different, larger-jump behaviour governed
by the doubling identity and deserves separate treatment. Second, the
primitive-divisor application also needs an analytic growth estimate for $\Phi_n$
that is orthogonal to the valuation law; we treat only the arithmetic
(multiplicity) side here.

---

## 9. Future directions

- **Computable critical lengths (C1).** Make the threshold parametrically explicit
  and characterise exactly which value-predicates are monotone in length.
- **Compositional sharpness (C2).** Develop the max/min calculus for combining many
  monotone sub-events of a real growth process.
- **Extremality of the factorial system (C3).** Turn the structural embedding of the
  factorial system into a quantitative extremal statement across the mixed-radix
  family.
- **Width–height trade-offs.** For a fixed target capacity, study the interplay
  between critical word length and average base size in positional phase transitions.
- **Beyond Fibonacci.** Extend the lifting-the-exponent law and its threshold
  reading to general Lucas sequences and strong divisibility sequences.

---

## 10. Conclusion

We proved an exact lifting-the-exponent law for Fibonacci numbers at odd primes,
via a new multiple-index binomial expansion, and showed that its proof is the
arithmetic image of a sharp transition: one term reaches the critical altitude
while all others overshoot. We connected the law to primitive-divisor theory and
embedded it in a general threshold framework for monotone growth, complete with a
conjectural compositional calculus. The staircase inside the Fibonacci numbers is,
in miniature, a phase transition made rigorous.
