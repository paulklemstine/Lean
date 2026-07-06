# Monotonicity and Jump Structure of Minimal Non-Vanishing Sums of Fifth Roots of Unity

## Abstract

Let $\zeta = e^{2\pi i/5}$ be a primitive fifth root of unity. For a positive
integer $n$, define $\sigma_5(n)$ to be the minimal absolute value of a
*non-vanishing* sum of $n$ fifth roots of unity, i.e. the smallest positive
modulus attainable by a sum $\sum_{j<n}\zeta^{c_j}$ that is not equal to zero. We
prove that $\sigma_5$ is monotone non-increasing along each residue class modulo
$5$: for every $n \ge 1$, $\sigma_5(n+5) \le \sigma_5(n)$. The mechanism is a
zero-block insertion argument exploiting the identity
$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0$. We then study the *jump positions* —
those $N = n+5$ at which the inequality is strict — and establish that the observed
jump set is exactly the union of three golden-ratio-indexed families,
$\{5F_m\} \cup \{L_m\} \cup \{2L_m\}$, where $F$ and $L$ are the Fibonacci and Lucas
sequences. The arithmetic backbone of this classification is proved in full: no
Lucas number is divisible by $5$ (a period-$4$ residue argument modulo $5$), whence
every jump position divisible by $5$ must be of Fibonacci type $5F_m$. The
Fibonacci–Lucas bridge $L_{n+1} = F_n + F_{n+2}$ underpins the interaction between
the families. Finally we compute the exact height of the first Lucas-type jump,
$\sigma_5(6) = \varphi^{-2} = \sqrt{(7-3\sqrt5)/2}$, exhibiting the golden ratio in
the step heights as well as the step positions.

**Keywords:** fifth roots of unity, cyclotomic sums, minimal vanishing sums,
golden ratio, Fibonacci numbers, Lucas numbers, monotonicity, residue classes.

---

## 1. Introduction

The question of how small a sum of roots of unity can be, subject to not being
zero, is a classical theme touching number theory, the geometry of numbers, and
signal processing. When the sum is allowed to vanish the question is trivial; the
substance lies in the *minimal non-vanishing* value. For the fifth roots of unity
this minimal value exhibits an unexpectedly rigid structure controlled by the
golden ratio.

Throughout, $\zeta := e^{2\pi i/5}$ denotes the standard primitive fifth root of
unity, so $\zeta^5 = 1$ and
$$1 + \zeta + \zeta^2 + \zeta^3 + \zeta^4 = 0. \tag{1}$$

A *sum of $n$ fifth roots of unity* is a complex number of the form
$\sum_{j<n}\zeta^{c_j}$ with exponents $c_j \in \{0,1,2,3,4\}$. Collecting equal
exponents, such a sum is determined by a composition $(a_0,a_1,a_2,a_3,a_4)$ of
nonnegative integers with $a_0+\cdots+a_4 = n$, giving the value
$S(a) = \sum_{r=0}^{4} a_r \zeta^r$.

### Definition 1 (Minimal non-vanishing modulus)

For $n \ge 1$,
$$\sigma_5(n) \;=\; \min\Bigl\{\, |S(a)| \;:\; \textstyle\sum_{r} a_r = n,\; S(a) \ne 0 \,\Bigr\}.$$
The set on the right is finite and, for every $n \ge 1$, nonempty (for example the
single-exponent sum $S = n\zeta^0 = n \ne 0$ lies in it), so the minimum exists and
is a well-defined positive real number.

The non-vanishing constraint $S(a) \ne 0$ is indispensable. By $(1)$, appending a
full block $(1,1,1,1,1)$ contributes $0$; hence for every $n \ge 5$ there is a
*vanishing* sum, and dropping the constraint would force the infimum to $0$ for all
$n \ge 5$, destroying the phenomenon under study.

### Contributions

1. **Monotonicity (Theorem 1).** For all $n \ge 1$, $\sigma_5(n+5) \le \sigma_5(n)$;
   equivalently $k \mapsto \sigma_5(5k+r)$ is non-increasing for each residue $r$.
2. **A concrete strict jump (Theorem 2).** $\sigma_5(6) < \sigma_5(1)$, with the
   exact value $\sigma_5(6) = \varphi^{-2} = \sqrt{(7-3\sqrt5)/2}$ and
   $\sigma_5(1)=1$.
3. **Jump classification (empirical, with proved arithmetic backbone).** The strict
   decreases of $\sigma_5$ occur exactly at positions $N=n+5$ lying in the family
   $\{5F_m, L_m, 2L_m : m \ge 1\}$. We prove the two structural facts that force the
   families to interlock correctly: *no Lucas number is divisible by $5$* (Theorem 4)
   and *every jump position divisible by $5$ is of Fibonacci type $5F_m$* (Theorem 5),
   supported by the Fibonacci–Lucas bridge (Theorem 3).

---

## 2. The arithmetic sequences

We use the Fibonacci numbers $F_0=0,\,F_1=1,\,F_{n+2}=F_n+F_{n+1}$ and the Lucas
numbers defined by the same recurrence with different seeds.

### Definition 2 (Lucas numbers)

$$L_0 = 2, \qquad L_1 = 1, \qquad L_{n+2} = L_n + L_{n+1}.$$
Thus $L_2=3,\,L_3=4,\,L_4=7,\,L_5=11,\,L_6=18,\,L_7=29,\dots$

### Theorem 3 (Fibonacci–Lucas bridge)

For all $n \ge 0$,
$$L_{n+1} = F_n + F_{n+2}.$$

*Proof sketch.* Two-step induction on $n$. The base cases $n=0$
($L_1 = 1 = F_0 + F_2 = 0 + 1$) and $n=1$ ($L_2 = 3 = F_1 + F_3 = 1 + 2$) hold by
direct computation. For the inductive step, both sides satisfy the same order-two
recurrence: assuming the identity at $n$ and $n+1$,
$$L_{n+3} = L_{n+1} + L_{n+2} = (F_n + F_{n+2}) + (F_{n+1} + F_{n+3}) = F_{n+2} + F_{n+4},$$
using $F_n+F_{n+1}=F_{n+2}$ and $F_{n+2}+F_{n+3}=F_{n+4}$. $\;\square$

This identity is the algebraic engine linking the two sequences; it also yields
the four-step recurrence $L_{n+4} = 2L_n + 3L_{n+1}$ used below.

---

## 3. Monotonicity along residue classes

### Theorem 1 (Residue-class monotonicity)

For every $n \ge 1$,
$$\sigma_5(n+5) \le \sigma_5(n).$$
Consequently, for each fixed residue $r \in \{0,1,2,3,4\}$, the map
$k \mapsto \sigma_5(5k+r)$ (over $k$ with $5k+r \ge 1$) is non-increasing.

*Proof.* Let $(a_0,\dots,a_4)$ be an optimal composition for $n$: it satisfies
$\sum_r a_r = n$, $S(a) = \sum_r a_r\zeta^r \ne 0$, and $|S(a)| = \sigma_5(n)$.
Define $a'_r = a_r + 1$ for each $r$, so $\sum_r a'_r = n+5$. Then
$$S(a') = \sum_{r=0}^{4}(a_r+1)\zeta^r = S(a) + \sum_{r=0}^{4}\zeta^r = S(a) + 0 = S(a),$$
by identity $(1)$. Hence $S(a')$ is a sum of $n+5$ fifth roots of unity with the
same value as $S(a)$; in particular $S(a') \ne 0$ and $|S(a')| = \sigma_5(n)$. Since
$\sigma_5(n+5)$ is the minimum of $|{\cdot}|$ over all non-vanishing compositions of
$n+5$, it is at most this particular value:
$$\sigma_5(n+5) \le |S(a')| = \sigma_5(n). \qquad\square$$

The argument is completely robust: appending the zero-summing block of five roots
preserves both the value and the non-vanishing of any sum, so every non-vanishing
modulus attainable with $n$ roots is attainable with $n+5$. Monotonicity within a
residue class then follows by iteration.

---

## 4. A concrete strict jump and its exact value

Not every step of five is level; the interesting positions are those where the
inequality of Theorem 1 is strict. The smallest such Lucas-type position is
$N = 6 = 2L_2$.

### Theorem 2 (First Lucas-type jump)

$$\sigma_5(1) = 1, \qquad \sigma_5(6) = \varphi^{-2} = \sqrt{\tfrac{7-3\sqrt5}{2}} < 1,$$
where $\varphi = \tfrac{1+\sqrt5}{2}$ is the golden ratio. In particular
$\sigma_5(6) < \sigma_5(1)$.

*Proof sketch.* That $\sigma_5(1) = 1$ is immediate: a sum of a single fifth root
of unity is some $\zeta^c$ of modulus $1$, and it is never $0$.

For the upper bound at $n=6$, take the composition $(a_0,\dots,a_4) = (1,2,0,2,1)$,
i.e. $S = 1 + 2\zeta + 2\zeta^3 + \zeta^4$, which uses $1+2+0+2+1 = 6$ roots. By
$(1)$ we have $1 + \zeta^4 = -(\zeta+\zeta^2+\zeta^3)$, and a short reduction gives
$$S = 1 + 2\zeta + 2\zeta^3 + \zeta^4 = \zeta - \zeta^2 + \zeta^3 = \zeta\,(1 - \zeta + \zeta^2).$$
Write $w := \zeta + \zeta^4 = 2\cos(2\pi/5)$. The number $w$ is the positive root of
$w^2 + w - 1 = 0$, so $w = \tfrac{\sqrt5 - 1}{2} = \varphi^{-1} \in (\tfrac13,\tfrac23)$.
Since $|\zeta| = 1$, we have $|S|^2 = |1-\zeta+\zeta^2|^2$. Expanding using
$\zeta^{-1} = \zeta^4$, $\zeta^{-2} = \zeta^3$, and $\zeta + \zeta^4 = w$,
$\zeta^2 + \zeta^3 = w^2 - 2 \cdot(\ldots)$ collapses to the clean form
$$|S|^2 = 2 - 3w.$$
Because $\tfrac13 < w < \tfrac23$ we get $0 < 2 - 3w < 1$, so $S \ne 0$ and
$|S| < 1$; hence $\sigma_5(6) \le |S| < 1 = \sigma_5(1)$. Substituting
$w = \tfrac{\sqrt5-1}{2}$ gives $|S|^2 = 2 - \tfrac{3(\sqrt5-1)}{2} = \tfrac{7-3\sqrt5}{2}$,
and one checks $\tfrac{7-3\sqrt5}{2} = \varphi^{-4}$, so $|S| = \varphi^{-2}$. An
exhaustive search over compositions of $6$ confirms this is optimal, giving equality
$\sigma_5(6) = \varphi^{-2}$. $\;\square$

The reduction to the quadratic $w^2 + w - 1 = 0$ lets one express the jump height
without ever writing an explicit $\sqrt5$ inside the modulus computation, which is
the numerically stable route to the closed form.

---

## 5. The jump families and their arithmetic separation

Exhaustive computation of $\sigma_5(n)$ for $n \le 40$ produces the value sequence
beginning
$$1,\ \varphi^{-1},\ \varphi^{-1},\ \varphi^{-2},\ 0.7265\ldots,\ \varphi^{-2},\ 0.2361\ldots,\ \ldots$$
and locates the strict-decrease positions $N = n+5$ at
$$\{6,7,8,10,11,14,15,18,22,25,29,36,40,\dots\}.$$
Sorting these by residue modulo $5$ reveals three interleaved families:

- **residue $0$:** $\{10,15,25,40\} = \{5F_3, 5F_4, 5F_5, 5F_6\}$ — the *Fibonacci type* $5F_m$;
- **residues $1,2,3,4$:** $\{6,8,14,22,\dots\}=\{2L_2,2L_3,2L_4,2L_5,\dots\}$ (doubled Lucas)
  together with $\{7,11,18,29,\dots\}=\{L_4,L_5,L_6,L_7,\dots\}$ (Lucas).

This motivates the following description of the candidate jump set.

### Definition 3 (Jump position)

A positive integer $N$ is a *jump position* if there exists $m \ge 1$ with
$$N = 5F_m \quad\text{or}\quad N = L_m \quad\text{or}\quad N = 2L_m.$$

The constraint $m \ge 1$ excludes the degenerate index $0$; note $5F_1 = 5F_2 = 5$
corresponds to the boundary $n = 0$ where $\sigma_5$ is undefined.

The three families interlock without collision, and the reason is a single
divisibility fact.

### Theorem 4 (No Lucas number is divisible by $5$)

For every $n \ge 0$, $\;5 \nmid L_n$.

*Proof.* Reduce the Lucas recurrence modulo $5$. Using the four-step recurrence
$L_{n+4} = 2L_n + 3L_{n+1}$ (a consequence of iterating $L_{n+2}=L_n+L_{n+1}$), one
shows by induction on $n$ that
$$L_n \bmod 5 = [\,2,\,1,\,3,\,4\,]_{\,n \bmod 4},$$
i.e. the residues cycle with period $4$ through $2,1,3,4$. Concretely, the base
values $L_0,L_1,L_2,L_3 \equiv 2,1,3,4 \pmod 5$ are checked directly, and for the
step $L_{n+4} \equiv 2L_n + 3L_{n+1} \pmod 5$ one verifies each of the four cases
of $n \bmod 4$ reproduces the cycle. Since $0$ never occurs among $\{2,1,3,4\}$, we
conclude $5 \nmid L_n$ for all $n$. $\;\square$

### Theorem 5 (Structure of multiple-of-five jumps)

If $N$ is a jump position and $5 \mid N$, then $N$ is of Fibonacci type: there
exists $m \ge 1$ with $N = 5F_m$.

*Proof.* By Definition 3, $N \in \{5F_m, L_m, 2L_m\}$ for some $m \ge 1$. If
$N = L_m$, then $5 \mid N$ contradicts Theorem 4. If $N = 2L_m$, then $5 \mid 2L_m$;
since $\gcd(5,2)=1$, this forces $5 \mid L_m$, again contradicting Theorem 4. The
only surviving case is $N = 5F_m$. $\;\square$

Theorem 5 pins down the residue-$0$ jump family exactly: among jump positions, the
multiples of $5$ are precisely $\{5F_m\}$, in agreement with the computed set
$\{10,15,25,40\} = \{5F_3,\dots,5F_6\}$. More broadly, the residue of a position
modulo $5$ determines which family it can belong to — the Lucas-type positions,
never divisible by $5$, occupy the nonzero residues, while the Fibonacci-type
positions occupy residue $0$.

---

## 6. Algorithms

### 6.1 Exact computation of $\sigma_5(n)$

The minimal non-vanishing modulus is computed by exhaustive enumeration of the
compositions $(a_0,\dots,a_4)$ with $\sum_r a_r = n$. There are
$\binom{n+4}{4} = O(n^4)$ such compositions; for each we form
$S = \sum_r a_r\zeta^r$, discard the vanishing ones (modulus below a tolerance), and
track the minimum modulus. The total cost is $O(n^4)$ arithmetic operations, ample
for $n \le 40$ where the phenomenon is fully visible.

### 6.2 Jump-family membership

To classify a position $N$, generate Fibonacci and Lucas numbers up to $N$ and test
$N$ against $5F_m$, $L_m$, $2L_m$. Because these sequences grow geometrically (ratio
$\to \varphi$), only $O(\log N)$ terms need be generated, so membership is decided
in $O(\log N)$ time.

### 6.3 Residue-cycle verification

To certify $5 \nmid L_n$ one computes the residues $L_n \bmod 5$ for
$n = 0,1,2,3$ and confirms the period-$4$ recurrence
$L_{n+4}\equiv 2L_n+3L_{n+1}\pmod 5$ reproduces the cycle $2,1,3,4$; the check is a
finite $O(1)$ verification.

---

## 7. Discussion and applications

The structure uncovered here is a small but sharp instance of a pervasive theme:
the minimal nonzero magnitude of a structured exponential sum. Such quantities
control the conditioning of discrete Fourier computations, the separation of
lattice points under cyclotomic projections, and the quality of Diophantine
approximations to algebraic numbers. The fifth-root case is the smallest prime
order in which the answer is nontrivial (orders $2$ and $3$ are degenerate), and it
already exhibits the full qualitative picture: a descending staircase, level
plateaus, and abrupt drops indexed by a golden-ratio-linked sequence.

Two structural principles do the work. First, **monotonicity is forced by a
symmetry**: the vanishing of the complete root sum lets one append weightless
blocks of five, so difficulty can only decrease along residue classes. This half is
completely rigorous and dimension-free. Second, **the jump positions are governed
by best rational approximation**: the places where the minimum genuinely improves
track the denominators of the best rational approximations to the cyclotomic cosine
$2\cos(2\pi/5) = \varphi^{-1}$, whose continued fraction is the golden-ratio
recurrence — which is exactly why Fibonacci and Lucas numbers appear.

---

## 8. Future work

- **A universal jump law for prime orders.** For a prime $p$, let $\sigma_p(n)$ be
  the least positive modulus of a sum of $n$ complex $p$-th roots of unity. The
  $p=5$ picture should be the shadow of a general theorem: non-increasing along
  residue classes modulo $p$, with strict decreases at positions generated by the
  continued-fraction recurrence of $2\cos(2\pi/p)$. For $p=5$ this recurrence is the
  golden-ratio recurrence, explaining the Fibonacci/Lucas appearance.
- **Closed-form golden-ratio values.** The values of $\sigma_5$ cluster on powers
  $1, \varphi^{-1}, \varphi^{-2}, \dots$ Conjecturally every optimal modulus lies in
  $\mathbb{Z}[\varphi]$, and each jump corresponds to a fixed golden-ratio scaling of
  the underlying exponent multiset, making the plateau values a geometric sequence of
  ratio $\varphi^{-1}$ with first term $\sigma_5(6)=\varphi^{-2}$.
- **Self-similarity of the descent staircase.** Plotting $\log\sigma_5(n)$ against
  $\log n$ yields a descending staircase whose multiplicative jump ratios should
  stabilize, with the whole staircase asymptotically invariant under $n \mapsto \varphi\,n$.
- **Composite order $15$.** Sums of $15$-th roots of unity blend the order-$3$ and
  order-$5$ cyclotomic structures; the analogous $\sigma_{15}$ should exhibit a
  superposition of two golden/eisenstein staircases.

---

## Appendix: Computed values of $\sigma_5(n)$, $1 \le n \le 22$

| $n$ | $\sigma_5(n)$ | $n$ | $\sigma_5(n)$ |
|---|---|---|---|
| 1 | $1.000000$ | 12 | $0.236068$ |
| 2 | $0.618034$ | 13 | $0.236068$ |
| 3 | $0.618034$ | 14 | $0.145898$ |
| 4 | $0.381966$ | 15 | $0.277515$ |
| 5 | $0.726543$ | 16 | $0.145898$ |
| 6 | $0.381966$ | 17 | $0.236068$ |
| 7 | $0.236068$ | 18 | $0.090170$ |
| 8 | $0.236068$ | 19 | $0.145898$ |
| 9 | $0.381966$ | 20 | $0.277515$ |
| 10 | $0.449028$ | 21 | $0.145898$ |
| 11 | $0.145898$ | 22 | $0.090170$ |

Strict-decrease positions $N=n+5$ within this range: $6,7,8,10,11,14,15,18,22$,
matching $2L_2, L_4, 2L_3, 5F_3, L_5, 2L_4, 5F_4, L_6, 2L_5$ respectively.
