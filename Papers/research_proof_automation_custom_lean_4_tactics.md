# Verified Proof Automation for Three Recurring Patterns: Min-Plus Simplification, Reflective Primality, and Row-Sum Spectral Bounds

## Abstract

We present three reusable, provably sound proof-automation procedures for
recurring patterns in algebra, number theory, and linear algebra, together
with the soundness theorems that justify them. The first, a *min-plus
simplifier*, reduces any identity in the tropical semiring
$(R, \oplus, \odot)$ with $a \oplus b = \min(a,b)$ and $a \odot b = a+b$ to an
equivalent statement over the base ordered group, exploiting the injective
homomorphism `untrop`; we use it to derive tropical idempotency,
distributivity, and the tropical *freshman's dream*
$(a \oplus b)^n = a^n \oplus b^n$. The second, a *reflective primality
decider*, implements trial division as an explicit Boolean predicate and
proves it extensionally equal to genuine primality, yielding self-certifying
primality (and compositeness) judgments verified by the kernel rather than by
an opaque oracle. The third, a *spectral bounder*, encapsulates the elementary
half of the Gershgorin circle theorem: every real eigenvalue of a matrix is
bounded in absolute value by the maximum absolute row sum. Each procedure is
accompanied by a soundness statement establishing that any goal it closes is
true and any goal it produces is logically equivalent to the original. We
further describe a fourth, cognate development — an automation toolkit for
Fibonacci identities based on a two-term basis principle — and discuss the
general design pattern of *sound reduction tactics*.

## 1. Introduction

Automated tactics are the connective tissue of large formal developments. A
single well-designed tactic can discharge a whole family of routine goals,
sparing the human from repeating the same argument in a hundred slightly
different guises. But automation carries a risk that ordinary lemmas do not: a
tactic is a *program*, and a buggy program can, in principle, "prove" a false
statement or, more insidiously, transform a goal into an inequivalent one and
declare victory on the wrong problem.

The remedy pursued here is uniform. For each tactic we isolate a **soundness
witness**: a theorem asserting that the reduction the tactic performs is
faithful. Once the soundness witness is proved, the tactic is safe to apply
anywhere, because every step it takes is backed by that theorem. We instantiate
this discipline three times, in three unrelated domains, to show its
generality.

Throughout, we distinguish two notions of soundness for a reduction tactic
that transforms a goal $G$ into a goal $G'$:

- **Truth-preservation**: if $G'$ is true, then $G$ is true (so closing $G'$
  closes $G$).
- **Equivalence**: $G \iff G'$ (so nothing is lost — a provable $G$ becomes a
  provable $G'$).

Our first tactic achieves full equivalence via an injective map; the second is
an *if-and-only-if* reflection; the third is a truth-preserving application of
a proved inequality.

## 2. Min-Plus Simplification

### 2.1 The tropical semiring

Let $R$ be a linearly ordered additive commutative monoid. The **tropical**
(min-plus) semiring on $R$ has carrier $R$ (with a formal $+\infty$ as the
additive identity when needed) and operations
$$a \oplus b = \min(a,b), \qquad a \odot b = a + b.$$
Tropical addition is idempotent, commutative, and associative; tropical
multiplication is commutative, associative, and distributes over $\oplus$.
Tropical exponentiation is repeated $\odot$, so $a^{\odot n} = n \cdot a$ in the
base group.

We work through the standard device of a wrapper type $\mathrm{Trop}(R)$ with a
bijection `untrop : Trop(R) → R` (and inverse `trop`) satisfying, for all
$x, y$:
$$\textsf{untrop}(x \oplus y) = \min(\textsf{untrop}\,x, \textsf{untrop}\,y), \qquad \textsf{untrop}(x \odot y) = \textsf{untrop}\,x + \textsf{untrop}\,y.$$

### 2.2 The soundness witness

**Theorem 2.1 (Soundness of min-plus simplification).**
The map $\textsf{untrop} : \mathrm{Trop}(R) \to R$ is injective, and for all
tropical numbers $x, y$,
$$\textsf{untrop}(x \oplus y) = \min(\textsf{untrop}\,x,\ \textsf{untrop}\,y), \qquad \textsf{untrop}(x \odot y) = \textsf{untrop}\,x + \textsf{untrop}\,y.$$

*Proof sketch.* Injectivity holds because `trop` is a two-sided inverse. The
two homomorphism identities are the definitional behavior of `untrop` on the
tropical operations. $\qquad\blacksquare$

The tactic operates by (1) reducing a goal $s = t$ between tropical
expressions to $\textsf{untrop}\,s = \textsf{untrop}\,t$ via injectivity, then
(2) unfolding `untrop` across $\oplus$, $\odot$, powers, and units using the
identities of Theorem 2.1. Because injectivity gives the equivalence
$s = t \iff \textsf{untrop}\,s = \textsf{untrop}\,t$, and each unfolding is an
equation, the resulting base-level goal is *logically equivalent* to the
original. The reduction is therefore sound in the strong (equivalence) sense.

### 2.3 Consequences

Over $\mathrm{Trop}(\mathbb{Z})$, the reduced goals live in the fragment of
linear integer arithmetic over $\min$ and $+$, which is decidable.

**Proposition 2.2 (Idempotency).** $a \oplus a = a$; equivalently
$\min(a,a) = a$.

**Proposition 2.3 (Distributivity).**
$a \odot (b \oplus c) = (a \odot b) \oplus (a \odot c)$; equivalently
$a + \min(b,c) = \min(a+b, a+c)$.

**Proposition 2.4 (Unit law).** $a \odot 1 = a$, where the tropical unit is
$\textsf{trop}\,0$.

Each of Propositions 2.2–2.4 reduces, under Theorem 2.1, to a decidable linear
$\min/+$ statement.

**Theorem 2.5 (Tropical freshman's dream).** For all $n \in \mathbb{N}$ and all
tropical $a, b$,
$$(a \oplus b)^{\odot n} = a^{\odot n} \oplus b^{\odot n}.$$

*Proof sketch.* Applying the soundness witness, the goal becomes
$n \cdot \min(p,q) = \min(np, nq)$ with $p = \textsf{untrop}\,a$,
$q = \textsf{untrop}\,b$, and $n \ge 0$. Case-split on $p \le q$ versus
$q \le p$. In the first case, $\min(p,q) = p$ and, since scaling by the
non-negative integer $n$ is monotone, $\min(np,nq) = np$; the second case is
symmetric. $\qquad\blacksquare$

Theorem 2.5 marks a precise boundary: the identity involves the product
$n \cdot (\cdot)$ and is therefore *not* in the linear $\min/+$ fragment, so it
requires the extra ingredient of monotonicity of scaling. Notably, the result
*fails* if $n$ is permitted to be negative, since scaling by a negative number
reverses order — a caveat that the hypothesis $n \ge 0$ makes explicit.

## 3. Reflective Small-Case Primality

### 3.1 An explicit trial-division predicate

We implement trial division as a concrete Boolean function. Say $n$ **has a
proper divisor** when there exists $d$ with $2 \le d < n$ and $d \mid n$;
computationally, this is a scan over $d \in \{0, 1, \dots, n-1\}$ testing
$2 \le d$ and $d \mid n$. Define the Boolean trial-division test
$$\textsf{trialPrime}(n) = (2 \le n) \ \wedge\ \neg\,\textsf{hasProperDivisor}(n).$$

**Lemma 3.1 (Divisor characterization).**
$\textsf{hasProperDivisor}(n) = \textsf{true} \iff \exists\, d,\ 2 \le d \wedge d < n \wedge d \mid n.$

*Proof sketch.* Unfold the scan (a bounded existential over a finite range)
and reconcile the ordering of conjuncts; the list-membership condition matches
the bounded existential term-for-term. $\qquad\blacksquare$

### 3.2 The soundness theorem

**Theorem 3.2 (Correctness of trial division).**
For every natural number $n$,
$$\textsf{trialPrime}(n) = \textsf{true} \iff n \text{ is prime}.$$

*Proof sketch.* Recall the elementary characterization: $n$ is prime iff
$2 \le n$ and every $m$ with $m < n$ dividing $n$ satisfies $m = 1$. Unfolding
$\textsf{trialPrime}$ and applying Lemma 3.1, the Boolean statement says
$2 \le n$ together with the *absence* of any $d$ satisfying
$2 \le d < n,\ d \mid n$. The forward direction shows that no such $d$ forces
every proper divisor to be $1$; the backward direction shows that primality
forbids any such $d$. Both directions are finite logical manipulations bridging
the bounded quantifier and the negated existential. $\qquad\blacksquare$

Theorem 3.2 is the soundness witness for the tactic. The tactic proves a goal
"$n$ is prime" by *reflection*: it rewrites the goal along Theorem 3.2 to
"$\textsf{trialPrime}(n) = \textsf{true}$" and then evaluates the closed Boolean
by kernel-checked computation. Crucially, no unverified oracle is trusted —
the equivalence itself is a proved theorem, so the reflective step is fully
justified. The same tactic certifies *compositeness*, since it also decides the
negation.

### 3.3 Examples

The tactic discharges, e.g., "$97$ is prime," "$101$ is prime," and
"$91$ is not prime" (as $91 = 7 \times 13$), each as a kernel-verified
computation. The design is deliberately conservative: it uses only trusted
reduction, never an unchecked fast path, so the primality certificate is
audited by the same core that checks the rest of the development.

### 3.4 Scope and cost

Trial division as stated scans candidate divisors up to $n$; a standard
optimization truncates the scan at $\lfloor\sqrt{n}\rfloor$, since a composite
number always has a nontrivial factor at or below its square root. For the
small-case regime the tactic targets, correctness and auditability dominate
raw speed, and the simple scan keeps the soundness proof maximally
transparent.

## 4. Row-Sum Spectral Bounds

### 4.1 Setup

Let $A$ be an $n \times n$ real matrix. A scalar $\lambda \in \mathbb{R}$ is a
**(real) eigenvalue** of $A$ if there is a nonzero vector $v$ with
$Av = \lambda v$. The **absolute row sum** of row $i$ is
$\sum_j |A_{ij}|$.

### 4.2 The existential form

**Theorem 4.1 (Row-sum dominates an eigenvalue).**
If $\lambda$ is a real eigenvalue of $A$ with eigenvector $v \ne 0$, then there
is a row index $i_0$ with
$$|\lambda| \le \sum_j |A_{i_0 j}|.$$

*Proof sketch.* Since $v \ne 0$, the finite index set is nonempty and some
coordinate is nonzero; choose $i_0$ maximizing $|v_{i_0}|$, so
$|v_i| \le |v_{i_0}|$ for all $i$ and $|v_{i_0}| > 0$. The $i_0$-th row of
$Av = \lambda v$ gives $\lambda\, v_{i_0} = \sum_j A_{i_0 j} v_j$. Taking
absolute values and using the triangle inequality,
$$|\lambda|\,|v_{i_0}| = \Big|\sum_j A_{i_0 j} v_j\Big| \le \sum_j |A_{i_0 j}|\,|v_j| \le \Big(\sum_j |A_{i_0 j}|\Big)\,|v_{i_0}|,$$
the last inequality by $|v_j| \le |v_{i_0}|$ and non-negativity of
$|A_{i_0 j}|$. Dividing by $|v_{i_0}| > 0$ yields the claim.
$\qquad\blacksquare$

### 4.3 The uniform bound (soundness witness)

**Theorem 4.2 (Uniform row-sum eigenvalue bound).**
If every absolute row sum of $A$ is at most $B$ — that is, $\sum_j |A_{ij}| \le
B$ for all $i$ — then every real eigenvalue $\lambda$ of $A$ (with a nonzero
eigenvector) satisfies
$$|\lambda| \le B.$$

*Proof sketch.* Apply Theorem 4.1 to obtain a row $i_0$ with
$|\lambda| \le \sum_j |A_{i_0 j}|$, then chain with the hypothesis
$\sum_j |A_{i_0 j}| \le B$. $\qquad\blacksquare$

Theorem 4.2 is the soundness witness for the spectral-bounding tactic. The
tactic reduces a goal "$|\lambda| \le B$" (given an eigenpair) to the
per-row obligations "$\sum_j |A_{ij}| \le B$." Because the tactic is a direct
application of a proved theorem, any bound it certifies is correct. The bound
is the accessible half of the Gershgorin circle theorem — the $\infty$-operator
norm estimate — and is vacuous only if no eigenvector exists, which the
nonzeroness hypothesis excludes.

### 4.4 A worked instance

If every absolute row sum of $A$ is at most $5$, then every real eigenvalue of
$A$ has magnitude at most $5$. This follows immediately from Theorem 4.2 with
$B = 5$.

## 5. A Cognate Development: Fibonacci Identities by a Two-Term Basis

The same "sound reduction" philosophy powers a fourth toolkit, for identities
among Fibonacci numbers $F_n$. Its engine is the **two-term basis principle**:
for a fixed base $n$, every shifted value $F_{n+k}$ is a fixed
$\mathbb{N}$-linear combination of the two coordinates $F_n$ and $F_{n+1}$.
Concretely,
$$F_{n+(k+1)} = F_k\, F_n + F_{k+1}\, F_{n+1}.$$

**Consequence (single-base reduction).** Any single-base polynomial identity in
shifted Fibonacci values becomes a formal polynomial identity in the two atoms
$F_n, F_{n+1}$ and is decided by ring normalization. Examples closed this way:
$$F_{n+5} = 3F_n + 5F_{n+1}, \qquad F_{n+7} = 8F_n + 13F_{n+1}, \qquad F_{n+2}^2 = F_{n+1}^2 + F_n F_{n+3}.$$

**Parity identities** depend on the sign $(-1)^n$, which is not a polynomial in
$(F_n, F_{n+1})$; these need exactly one induction step. The archetype is
**Cassini's identity**,
$$F_{n+2} F_n - F_{n+1}^2 = (-1)^{n+1}.$$

**Two-base identities** reduce to Cassini by substituting the closed form. For
example, **d'Ocagne's identity**
$$F_{n+k} F_{n+1} - F_{n+k+1} F_n = (-1)^n F_k$$
and **Catalan's identity**
$$F_{n+r}^2 - F_n F_{n+2r} = (-1)^n F_r^2$$
each become a Fibonacci multiple of the Cassini expression
$F_{n+1}^2 - F_n F_{n+2}$. The toolkit also yields the doubling formulas
$$F_{2n+1} = F_{n+1}^2 + F_n^2, \qquad F_{2n} = F_n\,(2F_{n+1} - F_n),$$
the partial sums
$$\sum_{i<n} F_i = F_{n+1} - 1, \qquad \sum_{i \le n} F_i^2 = F_n F_{n+1},$$
and the strong divisibility law
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$

This development illustrates the same three-tier structure seen above: a
*reduction* to a decidable fragment (here, polynomial identities in two atoms),
a clearly delimited *boundary* where an extra idea is needed (parity, requiring
induction), and *derived* results that reduce to a single hard core (Cassini).

## 6. Discussion

The three primary procedures share a template worth naming explicitly.

1. **Identify a faithful reduction.** For min-plus, an injective homomorphism
   to the base group; for primality, an if-and-only-if between a computable
   Boolean and the mathematical predicate; for eigenvalues, an application of a
   proved inequality.
2. **Prove the soundness witness once.** Theorems 2.1, 3.2, and 4.2 are the
   respective guarantees.
3. **Let the tactic be a thin wrapper.** The tactic performs only the reduction
   plus a routine finisher (linear arithmetic; kernel evaluation; a residual
   inequality check). Because it does nothing the soundness witness does not
   license, it cannot certify a falsehood.

This separation of concerns — heavy mathematics in a one-time theorem, light
mechanics in the tactic — is what makes verified automation both trustworthy
and reusable.

A recurring theme is the *boundary of easy automation*. The min-plus simplifier
handles everything in the linear $\min/+$ fragment for free; the freshman's
dream sits just outside it, requiring monotonicity. The Fibonacci toolkit
handles single-base identities by pure ring reasoning; parity identities sit
just outside, requiring one induction. Recognizing these boundaries precisely
is itself a mathematical result about *what can be automated cheaply*.

## 7. Future Directions

**A canonical Horner factorization for tropical polynomials.** We conjecture
that every univariate max-plus polynomial of degree $d$, written as
$\max_{k \le d}(a_k + kx)$, admits a unique nested factorization
$a_0 \oplus x \odot (a_1 \oplus x \odot (a_2 \oplus \cdots))$ evaluating in
exactly $d$ tropical additions and $d$ tropical multiplications — the min-plus
analogue of Horner's rule — with no shorter straight-line evaluation possible.
The two-sided distributivity of ordinary addition over $\max$ is enough to
collapse any max-of-affine expression into a single nested form, transporting
the classical arithmetic-circuit theory of polynomial evaluation to the
tropical world. Because tropical polynomials are the exact algebra of
piecewise-linear activation networks, an optimal canonical evaluation order
directly bounds the number of comparison-and-add operations such networks need.

**Optimality of trial division among divisor-scan certificates.** We conjecture
that among all primality tests certifying $n$ by exhibiting the absence of a
proper divisor in an explicitly scanned range, the scan can always be truncated
at $\lfloor\sqrt{n}\rfloor$ without loss, and no certificate of this shape can
inspect asymptotically fewer than $\sqrt{n}/\log n$ candidate divisors on
infinitely many $n$. A composite number always has a nontrivial factor at or
below its square root, so the witness to compositeness lives in a range of size
$\sqrt{n}$, while primes force the scan to rule out every prime below
$\sqrt{n}$, pinning the lower bound to the density of primes. Understanding the
minimal certificate size sharpens the cost model for self-certifying
number-theoretic procedures in verified cryptographic libraries.

**Exact tightness of row-sum bounds.** We conjecture that the bound
$|\lambda| \le \max_i \sum_j |A_{ij}|$ is attained by an eigenvalue of $A$ if
and only if, after a diagonal sign change, some maximal row is a non-negative
multiple of a common probability vector shared by all maximal rows;
equivalently, equality forces the extremal eigenvector to be constant in
modulus across the support of the maximal rows. Equality in the triangle
inequality used to prove the bound demands perfect phase alignment of the
eigenvector entries, rigidly constraining the maximal rows to a
scaled-stochastic shape. Since spectral radius controls the stability of
iterated linear dynamics, characterizing exact tightness sharpens stability
thresholds for such systems.

## 8. Conclusion

We have exhibited three provably sound automation procedures — a min-plus
simplifier, a reflective primality decider, and a row-sum spectral bounder —
each reducing a family of routine goals to a decidable or directly checkable
core, and each backed by an explicit soundness theorem. A fourth, cognate
toolkit for Fibonacci identities reinforces the pattern. The unifying lesson is
methodological: trustworthy automation is built by proving, once, that a
reduction is faithful, and then letting the tactic do nothing more than that
reduction. This keeps the mathematics honest and the shortcuts safe.
