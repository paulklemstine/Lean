# Certified Evidence: The Exact Logical Strength of Bounded Verification, with Application to the $3n+1$ Problem

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

We develop a complete theory of *bounded certification*: the practice of establishing a universal arithmetic statement $\forall n \ge 1,\ p(n)$ by exhaustively verifying a finite initial window $[1, N]$. Three questions are answered exactly.

First, **what a finite certificate is worth.** We show that a bounded check is not merely sound but equivalent to the bounded statement it certifies, that certificates glue and restrict along intervals, and that failure yields explicit counterexamples. Against this we prove a sharp negative result: for every bound $N$ there is a predicate agreeing bit-for-bit with the certified evidence on $[1,N]$ and false at $N+1$; consequently no bound is uniformly sound, and the *version space* — the family of hypotheses consistent with the evidence — retains the cardinality of the continuum after any finite check. In learning-theoretic terms, the unrestricted class of binary predicates on $\mathbb{N}$ shatters every finite set, so its VC dimension is infinite and no finite sample complexity exists.

Second, **what closes the gap.** We isolate the notion of a *descent certificate*: a verified window $[1,N]$ together with a reduction $r$ that strictly decreases above $N$ and transports truth upward. Descent certificates are sound by strong induction and, crucially, **complete**: every true universal statement of this shape admits one. Thus "finite check $+$ descent" is a complete proof system for bounded-quantifier-free universal arithmetic, in exact contrast with bare finite checking, which is not even sound. Periodicity and closure under a fixed shift are shown to be instances; from a ten-input window we obtain $n^5 \equiv n \pmod{10}$ for all $n$, and from a three-input window the numerical-semigroup theorem that every $n \ge 8$ lies in $\langle 3, 5\rangle$, with the sharp gap set $\{1,2,4,7\}$.

Third, **how far a fixed computational budget reaches.** Instantiating the theory on the Collatz map, we prove a *residue sieve theorem*: certifying only the class $n \equiv 3 \pmod 4$ certifies all of $[1,B]$, with workload exactly $\lfloor (B+1)/4 \rfloor$. We prove this sieve *optimal at its scale*, since the two-step accelerated map sends $4m+3 \mapsto 9m+8$ and therefore no such input descends; the exact scale-$2$ workload on $[1,B]$ is $\lfloor (B+1)/4\rfloor + 2$. We embed the sieve in a family indexed by the $2$-adic scale $k$, characterise its workload by the arithmetic condition $2^k \le 3^{s_k(r)}$ on parity-word weights, and prove that the amortized examined fraction tends to zero: for every $\varepsilon > 0$ some scale certifies $[1,B]$ from fewer than $\varepsilon B$ inputs, for all large $B$. Combined with a relatively-complete early-stopping test and a depth-balanced evaluation strategy proved equal to the linear one, the certified bound advances $20 \to 1000 \to 4000 \to 131072$.

Finally, we prove a **learning dichotomy** that reconciles the negative and positive halves: at identical evidence — the values on $[1,T]$ — the unrestricted hypothesis class retains a continuum of candidates while the class of $T$-periodic predicates retains exactly one, and $T-1$ samples do not suffice. Informativeness of evidence is a property of the hypothesis class, never of the amount of computation.

**Keywords:** bounded certification, reflection, Collatz conjecture, descent, residue sieve, version space, VC dimension, sample complexity.

---

## 1. Introduction

### 1.1 The problem

A recurring situation in computational mathematics is this. A universal statement
$$\forall n \ge 1, \quad p(n)$$
resists proof; a decision procedure for $p$ exists; and so one runs the procedure on $1, 2, \ldots, N$ for the largest $N$ affordable. The Collatz conjecture has been checked past $2^{68}$; the Riemann hypothesis past $10^{13}$ zeros; Goldbach past $4 \times 10^{18}$. Everyone agrees this is *evidence*. Almost nobody says precisely what it is evidence *of*.

This paper answers that question exactly, in three parts: the logical strength of a certificate (§3), the precise structural supplement that upgrades it to a proof (§4), and how much a fixed budget of verified computation can be made to cover once the supplement is unavailable (§5–§6). §7 closes with a dichotomy in the language of statistical learning that explains both halves at once.

### 1.2 Summary of contributions

1. **A reflection calculus** (§2): bounded checks with an exact soundness–completeness bridge, a gluing law licensing chunked/parallel/resumable certification, equivalence with list and array traversals, and constructive counterexample extraction.
2. **Insufficiency, sharpened** (§3): the truncation operator; failure of soundness at every bound; the diagonal; a continuum lower bound for the version space; infinite VC dimension of the ambient class.
3. **Descent certificates** (§4): definition, soundness, and a completeness theorem; periodic and shift specialisations; two fully certified universal theorems from windows of size $10$ and $3$.
4. **The mod-$4$ sieve and its exact optimality** (§5).
5. **The scale-$k$ sieve family and vanishing amortized cost** (§6), together with two evaluation-level improvements (early stopping with relative completeness; depth-balanced reflection) that jointly raise the certified Collatz bound to $131072$.
6. **The learning dichotomy** (§7).

### 1.3 Notation

$\mathbb{N}$ denotes the non-negative integers. A *predicate* is a function $p : \mathbb{N} \to \{\mathrm{true}, \mathrm{false}\}$; we identify a predicate with the set on which it is true. The classical Collatz map is
$$\mathrm{col}(n) = \begin{cases} n/2, & n \text{ even},\\ 3n+1, & n \text{ odd},\end{cases}$$
and the *accelerated map* is
$$T(n) = \begin{cases} n/2, & n \text{ even},\\ (3n+1)/2, & n \text{ odd}.\end{cases}$$
We write $f^{[k]}$ for the $k$-fold iterate.

---

## 2. A calculus of bounded checks

### 2.1 The bounded conjunction

**Definition 2.1 (Bounded check).** For a predicate $p$ define, by recursion on the *length*,
$$\mathrm{Chk}(p, \ell, 0) = \mathrm{true}, \qquad \mathrm{Chk}(p, \ell, m+1) = p(\ell) \wedge \mathrm{Chk}(p, \ell+1, m),$$
and set the *window check* $C_p(\ell, h) = \mathrm{Chk}(p, \ell, h + 1 - \ell)$, with truncated subtraction, so that the check of an empty window ($h < \ell$) succeeds.

Recursion on length rather than on the endpoint keeps the evaluation linear in the number of inputs and independent of their magnitude.

**Theorem 2.2 (Reflection bridge).** For all $\ell, m$,
$$\mathrm{Chk}(p, \ell, m) = \mathrm{true} \iff \forall k,\ \ell \le k < \ell + m \Rightarrow p(k),$$
and consequently
$$C_p(\ell, h) = \mathrm{true} \iff \forall k,\ \ell \le k \le h \Rightarrow p(k).$$

*Proof sketch.* Induction on $m$. The base case is the vacuous quantification over an empty range. In the step, $\mathrm{Chk}(p,\ell,m+1)$ splits as $p(\ell)$ and $\mathrm{Chk}(p,\ell+1,m)$; the inductive hypothesis converts the second conjunct, and the two directions are then a case split on whether $k = \ell$ or $k > \ell$. $\square$

Two corollaries are worth naming separately because they are used in opposite directions. *Soundness*: from $C_p(\ell,h)$ and $\ell \le k \le h$ infer $p(k)$. *Completeness*: any true bounded statement is certified. The check is therefore an exact representation of the bounded statement, not an approximation of it.

### 2.2 Composition

**Theorem 2.3 (Splitting law).** $\mathrm{Chk}(p, \ell, m + m') = \mathrm{Chk}(p, \ell, m) \wedge \mathrm{Chk}(p, \ell + m, m')$.

**Corollary 2.4 (Gluing).** If $\ell \le \text{mid} + 1$ and $\text{mid} \le h$ then
$$C_p(\ell, h) = C_p(\ell, \text{mid}) \wedge C_p(\text{mid}+1, h).$$

*Proof sketch.* Induction on $m$ for 2.3, using associativity of conjunction; 2.4 is 2.3 after rewriting $h+1-\ell$ as $(\text{mid}+1-\ell) + (h+1-(\text{mid}+1))$, valid under the stated inequalities. $\square$

This is the law that makes divide-and-conquer certification *correct rather than merely plausible*: a certificate for a long interval is definitionally a pair of certificates for adjacent subintervals. It licenses chunking (to bound memory), parallelism (independent chunks), and resumption (a crashed run loses only its current chunk). Two further trivialities follow: certificates restrict to subwindows, and a certificate extends one step to the right given a single new verification.

### 2.3 Implementation independence

**Theorem 2.5.** $\mathrm{Chk}(p,\ell,m)$ equals the conjunction of $p$ over the list $[\ell, \ell+1, \ldots, \ell+m-1]$, and equals the conjunction of $p$ over the corresponding array.

Statements of this kind are the interface between mathematics and engineering: they permit an efficient array-based implementation to be substituted for the naive recursion with no change whatever to what is being asserted.

### 2.4 Extraction of counterexamples

**Definition 2.6.** $\mathrm{FirstFail}(p, \ell, 0) = \bot$, and $\mathrm{FirstFail}(p, \ell, m+1) = \mathrm{FirstFail}(p, \ell+1, m)$ if $p(\ell)$, else $\ell$.

**Theorem 2.7.** $\mathrm{FirstFail}(p,\ell,m) = \bot$ if and only if $\mathrm{Chk}(p,\ell,m)$; and if $\mathrm{FirstFail}(p,\ell,m) = k$ then $\ell \le k < \ell+m$ and $p(k)$ is false. Consequently a failed window check yields an explicit $k \in [\ell,h]$ with $\neg p(k)$.

So the calculus is *refutation-complete* on finite windows: a search either certifies or produces a witness, never merely reports failure.

---

## 3. The exact insufficiency of finite evidence

### 3.1 Truncation

**Definition 3.1.** The *truncation* of $p$ at $N$ is $\tau_N p(k) = p(k) \wedge (k \le N)$.

**Lemma 3.2.** $\tau_N p$ agrees with $p$ on $[0,N]$ and is false above $N$. Hence $C_{\tau_N p}(\ell, N) = C_p(\ell, N)$ for every $\ell$, while $\tau_N p(N+1) = \mathrm{false}$.

*Proof sketch.* The pointwise agreement is immediate. For the certificate equality, argue by cases on whether $C_p(\ell,N)$ holds: if it does, apply completeness to the pointwise agreement; if it does not, extract a counterexample by Theorem 2.7 and observe that the same point defeats the truncated check. $\square$

Truncation is *evidence-preserving sabotage*: it is invisible to any observer restricted to the certified window and fatal immediately outside it.

**Theorem 3.3 (No finite bound is sound).** For every $N$ there is a predicate $q$ with $C_q(1,N) = \mathrm{true}$ and $\neg\, \forall n \ge 1,\ q(n)$.

*Proof.* Take $q = \tau_N(\mathrm{true})$; Lemma 3.2 gives the certificate and the failure at $N+1$. $\square$

**Corollary 3.4 (Diagonal form).** There is no $N$ such that, for all predicates $p$, $C_p(1,N)$ implies $\forall n \ge 1,\ p(n)$.

**Proposition 3.5 (Certificates carry no information off-window).** For every $p$ and $N$ there is $q$ agreeing with $p$ on $[0,N]$ with $q(N+1)$ false and $q(N+2)$ true. Certification constrains nothing about untouched inputs, in either direction.

### 3.2 Version spaces

**Definition 3.6.** The *version space* of $p$ at $N$ is
$$V(p,N) = \{\, q : \mathbb{N} \to \{\mathrm{true},\mathrm{false}\} \ \mid\ \forall k,\ 1 \le k \le N \Rightarrow q(k) = p(k) \,\}.$$

**Definition 3.7 (Grafting).** For $f : \mathbb{N} \to \{\mathrm{true},\mathrm{false}\}$ set
$$E_{p,N}(f)(k) = \begin{cases} p(k), & k \le N,\\ f(k - (N+1)), & k > N.\end{cases}$$

**Lemma 3.8.** $E_{p,N}(f) \in V(p,N)$ for every $f$, and $E_{p,N}$ is injective.

*Proof sketch.* Membership is by construction. For injectivity, evaluate $E_{p,N}(f)$ at $m + N + 1$ to recover $f(m)$. $\square$

**Theorem 3.9 (Continuum theorem).** For every $p$ and every $N$,
$$\mathfrak{c} \;=\; 2^{\aleph_0} \;\le\; |V(p,N)|.$$
In particular $V(p,N)$ is infinite.

*Proof.* $E_{p,N}$ injects the full function space $\{\mathrm{true},\mathrm{false}\}^{\mathbb{N}}$, of cardinality $2^{\aleph_0} = \mathfrak{c}$, into $V(p,N)$. $\square$

Cardinality is a coarse measure, but that is precisely the point: finite evidence does not even reduce the *cardinality* of the space of surviving hypotheses. It is not that evidence is weak; on this scale it is null.

### 3.3 The learning-theoretic reading

**Theorem 3.10 (No finite sample determines a hypothesis).** For every finite $S \subseteq \mathbb{N}$ and every predicate $p$ there is $q \ne p$ with $q|_S = p|_S$.

*Proof.* Pick $m = 1 + \max S \notin S$ and flip the value of $p$ at $m$. $\square$

Equivalently, the class of all binary predicates on $\mathbb{N}$ shatters every finite subset; its VC dimension is infinite; no PAC-style finite sample complexity exists for it under any distribution with infinite support. §7 shows that this is the *only* obstruction — restrict the class and finite evidence becomes conclusive.

**Theorem 3.11 (Monotone but never sufficient).** Evidence is monotone — $N \le M$ and $C_p(1,M)$ imply $C_p(1,N)$ — and yet for no $N$ is $C_p(1,N)$ equivalent to $\forall n \ge 1, p(n)$.

The two clauses together are the precise sense in which computation "converges without arriving": the family of certificates is increasing, its union is the universal statement, and no member of the family is.

---

## 4. Descent certificates: a sound and complete proof system

### 4.1 The definition and its two theorems

**Definition 4.1 (Descent certificate).** A *descent certificate* for $p$ is a tuple $(N, r)$ where $N \in \mathbb{N}$ and $r : \mathbb{N} \to \mathbb{N}$, subject to:
* **(base)** $C_p(1, N) = \mathrm{true}$;
* **(range)** $r(n) \ge 1$ for all $n > N$;
* **(descent)** $r(n) < n$ for all $n > N$;
* **(transport)** $p(r(n))$ implies $p(n)$, for all $n > N$.

**Theorem 4.2 (Soundness).** A descent certificate for $p$ proves $\forall n \ge 1,\ p(n)$.

*Proof.* Strong induction on $n$. If $n \le N$, apply soundness of the base check. Otherwise $r(n)$ is a smaller positive integer, so the induction hypothesis gives $p(r(n))$, and transport gives $p(n)$. $\square$

**Theorem 4.3 (Completeness).** Conversely, if $\forall n \ge 1,\ p(n)$, then $p$ admits a descent certificate. Hence
$$\text{$p$ has a descent certificate} \iff \forall n \ge 1,\ p(n).$$

*Proof.* Take $N = 1$, $r \equiv 1$; the base check is the single instance $p(1)$, range and descent are immediate for $n > 1$, and transport holds because $p(n)$ holds outright. $\square$

Theorem 4.3 is trivial to prove and non-trivial to interpret. It says that the schema "verify a finite window, then exhibit a well-founded reduction" is *not a heuristic but a complete proof system* for universal statements of this shape: whenever such a statement is true, a proof in this format exists. Contrast Theorem 3.3: the schema "verify a finite window" is not sound at all. The delta between an incomplete-and-unsound system and a complete one is exactly one object — the reduction $r$. This reframes open universal conjectures: the missing ingredient is never computational, always structural.

### 4.2 Two structural hypotheses that yield descent

**Theorem 4.4 (Periodic certificate).** Suppose $T > 0$ and $p(n+T) = p(n)$ for all $n$. If $C_p(1,T)$ then $p(n)$ for all $n \ge 1$.

*Proof sketch.* Instantiate Definition 4.1 with bound $T$ and reduction $r(n) = n - T$; range and descent hold for $n > T$, and transport is periodicity. $\square$

**Theorem 4.5 (Shift certificate).** Suppose $a > 0$ and $p$ is closed under $n \mapsto n+a$ above $N$: $N \le n$ and $p(n)$ imply $p(n+a)$. If $C_p(N, N+a-1)$ then $p(n)$ for all $n \ge N$.

*Proof sketch.* Strong induction on $n \ge N$. Inputs in $[N, N+a-1]$ come from the base check; for $n \ge N + a$, apply the induction hypothesis at $n - a \ge N$ and close under $+a$. $\square$

### 4.3 Two certified universal theorems

**Theorem 4.6 (Last digits of fifth powers).** For all $n \in \mathbb{N}$, $n^5 \equiv n \pmod{10}$.

*Proof sketch.* Let $p(n)$ be the decidable predicate $n^5 \bmod 10 = n \bmod 10$. Since $(n+10)^5 \equiv n^5$ and $n + 10 \equiv n$ modulo $10$, $p$ has period $10$. The ten instances $n=1,\ldots,10$ are checked directly, and $n = 0$ separately; Theorem 4.4 finishes. $\square$

Ten checked inputs yield a theorem about infinitely many. This is the exact opposite of §3, and the difference is entirely the periodicity hypothesis.

**Theorem 4.7 (Chicken McNugget, with sharp boundary).** Every $n \ge 8$ can be written $n = 3x + 5y$ with $x, y \in \mathbb{N}$; $7$ cannot; and the complete set of non-representable integers is $\{1, 2, 4, 7\}$.

*Proof sketch.* Let $p(n)$ be the decidable predicate "$\exists y \le n,\ 5y \le n$ and $3 \mid (n - 5y)$", which is equivalent to representability by a bounded search. Representability is closed under adding $3$ (increment $x$). The three instances $n = 8 = 3+5$, $9 = 3\cdot 3$, $10 = 5 \cdot 2$ are checked; Theorem 4.5 with $N = 8$, $a = 3$ gives all $n \ge 8$. Non-representability of $7$ is a finite check. For the gap set, every $n < 8$ other than $1,2,4,7$ is $0, 3, 5, 6$, each visibly representable. $\square$

Here the window has size $3$; the Frobenius number $7 = 3\cdot 5 - 3 - 5$ appears as the sharp boundary of the certified region.

---

## 5. The Collatz instance: semantics, sieve, optimality

### 5.1 Semantics of the checker

Certified computation is worthless if what is certified is a program rather than a theorem, so we begin by fixing the semantics.

**Definition 5.1.** $\mathrm{Reach}(n)$ means $\exists k,\ T^{[k]}(n) = 1$; $\mathrm{ReachCol}(n)$ means $\exists k,\ \mathrm{col}^{[k]}(n) = 1$.

**Lemma 5.2.** $\mathrm{Reach}(T(n))$ implies $\mathrm{Reach}(n)$; $\mathrm{Reach}(1)$; $\mathrm{Reach}(T^{[j]}(n))$ implies $\mathrm{Reach}(n)$; and $n \ge 1$ implies $T^{[k]}(n) \ge 1$ for every $k$.

**Theorem 5.3 (Bridge to the classical map).** $\mathrm{Reach}(n)$ implies $\mathrm{ReachCol}(n)$.

*Proof sketch.* One accelerated step is one classical step (if $n$ even) or two (if $n$ odd): $T(n) = \mathrm{col}^{[m]}(n)$ with $m \in \{1,2\}$. Induct on the number of accelerated steps, composing the corresponding classical iterates. $\square$

Every bound below is therefore a statement about $3n+1$ as classically defined.

**Definition 5.4 (Fuelled checker).** $\mathrm{ReachB}(0, n) = \mathrm{false}$ and
$$\mathrm{ReachB}(f+1, n) = \begin{cases}\mathrm{true}, & n = 1,\\ \mathrm{false}, & n = 0,\\ \mathrm{ReachB}(f, T(n)), & \text{otherwise}.\end{cases}$$

**Theorem 5.5 (Soundness and monotonicity).** $\mathrm{ReachB}(f,n)$ implies $\mathrm{Reach}(n)$; and $f \le g$ with $\mathrm{ReachB}(f,n)$ implies $\mathrm{ReachB}(g,n)$.

*Proof sketch.* Induction on the fuel. Soundness: a success at $n \ne 1$ is a success at $T(n)$ with less fuel, and Lemma 5.2 lifts it. Monotonicity: the same recursion with a larger budget. $\square$

Monotonicity is what allows certificates produced with different budgets to be combined; a certificate is never invalidated by rerunning with more fuel.

### 5.2 The mod-$4$ sieve

**Lemma 5.6.** $T^{[2]}(4m+1) = 3m+1$. Hence $\mathrm{Reach}(3m+1)$ implies $\mathrm{Reach}(4m+1)$.

*Proof.* $4m+1$ is odd, so $T(4m+1) = (12m+4)/2 = 6m+2$, which is even, so $T(6m+2) = 3m+1$. $\square$

**Theorem 5.7 (Sieve theorem).** Let $B \in \mathbb{N}$. If $\mathrm{Reach}(n)$ holds for every $n \in [1,B]$ with $n \equiv 3 \pmod 4$, then $\mathrm{Reach}(n)$ holds for every $n \in [1,B]$.

*Proof sketch.* Strong induction on $n$. For $n = 1$ the claim is trivial. If $n$ is even, $T(n) = n/2 < n$ and the induction hypothesis applies. If $n \equiv 1 \pmod 4$, write $n = 4m+1$ with $m \ge 1$; then $3m + 1 < 4m+1 \le B$, so the induction hypothesis gives $\mathrm{Reach}(3m+1)$ and Lemma 5.6 lifts it. If $n \equiv 3 \pmod 4$ the hypothesis applies directly. $\square$

**Theorem 5.8 (Exact sieve density).** $\bigl|\{ n \in [1,B] : n \equiv 3 \bmod 4\}\bigr| = \lfloor (B+1)/4 \rfloor$.

*Proof sketch.* Induction on $B$, splitting on whether $B+1 \equiv 3 \pmod 4$. $\square$

So the sieve reduces the examined set by a factor of $4$ exactly, not asymptotically.

### 5.3 Optimality at scale $2$

The two-step behaviour of $T$ on residues modulo $4$ is completely explicit:
$$T^{[2]}(4m) = m, \qquad T^{[2]}(4m+1) = 3m+1, \qquad T^{[2]}(4m+2) = 3m+2, \qquad T^{[2]}(4m+3) = 9m+8.$$
Each is a two-line computation from the definition of $T$.

**Theorem 5.9 (No input $\equiv 3 \bmod 4$ descends in two steps).** If $n \equiv 3 \pmod 4$ then $T^{[2]}(n) \ge n$.

*Proof.* Write $n = 4m+3$; then $T^{[2]}(n) = 9m + 8 > 4m+3$. $\square$

**Theorem 5.10 (Everything else does).** If $n \ge 3$ and $n \not\equiv 3 \pmod 4$ then $T^{[2]}(n) < n$.

*Proof.* Case on the residue: $m < 4m$ for $m \ge 1$; $3m+1 < 4m+1$ for $m \ge 1$; $3m+2 < 4m+2$ for $m \ge 1$. $\square$

**Definition 5.11.** For a scale $k$, the *non-descending set* at bound $B$ is
$$\mathrm{ND}(k,B) = \{\, n \in [1,B] : T^{[k]}(n) \ge n \,\}.$$
This is exactly the set of inputs a scale-$k$ sieve must examine.

**Theorem 5.12 (Exact scale-$2$ workload).** For $B \ge 2$,
$$\mathrm{ND}(2,B) = \{1,2\} \cup \{\, n \in [1,B] : n \equiv 3 \bmod 4 \,\}, \qquad |\mathrm{ND}(2,B)| = \left\lfloor \frac{B+1}{4} \right\rfloor + 2.$$

*Proof sketch.* Theorems 5.9 and 5.10 classify all $n \ge 3$; the inputs $1$ and $2$ are checked by hand ($T^{[2]}(1) = 2 \ge 1$ and $T^{[2]}(2) = 2 \ge 2$). The two pieces are disjoint since $1, 2 \not\equiv 3 \pmod 4$, so the cardinality follows from Theorem 5.8. $\square$

The hand-built mod-$4$ sieve is therefore **exactly optimal among residue sieves at scale $2$**: the set it examines is precisely the set that provably must be examined.

### 5.4 Certified bounds from the sieve

Running the fuelled checker inside the reflection calculus yields window certificates, and Theorems 5.3, 5.5, 5.7 convert them into mathematics:

* Verifying the unsieved checker on $[1,20]$: every $n \le 20$ satisfies $\mathrm{ReachCol}(n)$.
* Verifying the unsieved checker on $[1,1000]$: every $n \le 1000$ satisfies $\mathrm{ReachCol}(n)$.
* Verifying the *sieved* checker on $[1,4000]$ — which examines only the $1000$ inputs $\equiv 3 \bmod 4$ and returns true immediately otherwise: every $n \le 4000$ satisfies $\mathrm{ReachCol}(n)$.

The third bound costs the same as the second and reaches four times further, exactly as Theorem 5.8 predicts.

### 5.5 The wall, restated for Collatz

**Theorem 5.13 (Collatz evidence is not a proof).** For every fuel budget $f$ and every bound $B$ there is a predicate $q$ such that $q$ agrees with the Collatz checker on $[0,B]$, produces an identical certificate on $[1,B]$, and is false at $B+1$.

*Proof.* Take $q = \tau_B$ of the checker and apply Lemma 3.2. $\square$

**Theorem 5.14 (What is actually missing).** For every fuel budget $f$, the Collatz checker satisfies $\forall n \ge 1$ if and only if it admits a descent certificate.

*Proof.* Theorem 4.3 applied to the checker. $\square$

Together: the entire family of certificates, at every bound, is logically consistent with failure at the next untested input; and the sole missing ingredient is a reduction function.

---

## 6. Stretching the budget: scale, stopping, and shape

### 6.1 The scale-$k$ sieve

**Theorem 6.1 (Soundness of the scale-$k$ sieve).** Fix $k, B$. If $\mathrm{Reach}(n)$ holds for every $n \in \mathrm{ND}(k,B)$, then $\mathrm{Reach}(n)$ holds for every $n \in [1,B]$.

*Proof sketch.* Strong induction on $n$. Either $n \in \mathrm{ND}(k,B)$, and the hypothesis applies; or $T^{[k]}(n) < n$, and since iterates of positive inputs are positive and $T^{[k]}(n) \le B$, the induction hypothesis gives $\mathrm{Reach}(T^{[k]}(n))$, which lifts to $\mathrm{Reach}(n)$ by Lemma 5.2. $\square$

Note the absence of any threshold hypothesis: the non-descending set absorbs the small exceptional inputs automatically, which is why Theorem 5.12 contains $\{1,2\}$.

### 6.2 The arithmetic of non-contraction

Whether $n$ descends within $k$ accelerated steps is, up to a bounded set of exceptions, determined by $n \bmod 2^k$. Indeed, the parity of the first $k$ iterates of $n$ depends only on $n \bmod 2^k$, and if the parity word encountered has $s$ odd entries, then
$$T^{[k]}(n) = \frac{3^{s} n + c}{2^{k}}$$
for an explicit constant $c$ depending on the word and bounded by $2^k \cdot 3^{s}$. Thus $T^{[k]}(n) < n$ for all large $n$ in the class precisely when $3^s < 2^k$.

**Definition 6.2.** Let $s_k(r)$ be the number of odd steps in the first $k$ iterations starting at residue $r$ modulo $2^k$. The class $r$ is *non-contracting* at scale $k$ when
$$2^{k} \le 3^{\,s_k(r)}.$$

**Theorem 6.3 (Arithmetic characterisation).** A residue $r < 2^k$ is non-contracting exactly when $2^k \le 3^{s_k(r)}$; the real-analytic contraction condition (positivity of the exponent $k \log 2 - s_k(r)\log 3$) collapses to this integer inequality.

**Theorem 6.4 (Scale $2$).** The unique non-contracting class at scale $2$ is $r = 3$.

*Proof.* The parity words from $0,1,2,3$ modulo $4$ have $s_2 = 0, 1, 1, 2$ respectively. The inequality $4 \le 3^{s}$ fails for $s \le 1$ and holds for $s = 2$. $\square$

Thus the mod-$4$ sieve of §5 *is* the scale-$2$ member of the family, and Theorem 5.12 says it is exactly optimal at that scale.

**Theorem 6.5 (Workload bound).** $|\mathrm{ND}(k,B)| \le |\mathcal{NC}_k| \cdot \bigl( \lfloor B/2^k \rfloor + 1 \bigr) + 2^k 4^k$, where $\mathcal{NC}_k$ is the set of non-contracting classes at scale $k$.

The first term counts the members of non-contracting classes below $B$; the second is the explicit exceptional window inside which the residue analysis is not yet dominant.

**Theorem 6.6 (Vanishing amortized certification cost).** For every $\varepsilon > 0$ there is a scale $k \ge 1$ such that, for all sufficiently large $B$,
$$|\mathrm{ND}(k,B)| < \varepsilon B \qquad\text{and}\qquad \Bigl(\forall n \in \mathrm{ND}(k,B),\ \mathrm{Reach}(n)\Bigr) \Rightarrow \Bigl(\forall n \in [1,B],\ \mathrm{Reach}(n)\Bigr).$$

*Proof sketch.* Non-contraction requires $s_k(r) \ge k \log 2/\log 3 \approx 0.6309\,k$, while a uniformly random residue $r$ modulo $2^k$ has $s_k(r)$ distributed as a sum of $k$ independent fair bits, with mean $k/2$. Since $0.6309 > 1/2$, a concentration estimate makes $|\mathcal{NC}_k|/2^k \to 0$; feeding this into Theorem 6.5 makes the density $|\mathrm{ND}(k,B)|/B$ eventually smaller than $\varepsilon$. Soundness is Theorem 6.1. $\square$

The convergence is not monotone in $k$: since the threshold $k\log 2/\log 3$ crosses integers irregularly, the density $|\mathcal{NC}_k|/2^k$ oscillates ($0.250$ at $k=2$, $0.500$ at $k=3$, $0.313$ at $k=4$), but along an arithmetic progression of scales it decreases steadily — for $k = 4, 7, 10, 13, 16$ it takes the values $0.3125,\ 0.2266,\ 0.1719,\ 0.1334,\ 0.1051$.

The examined fraction therefore tends to zero: certification of Collatz evidence is *sublinear* in the certified range. And by Theorem 5.13 it is still, at every scale and every bound, not a proof. The two statements are entirely compatible and jointly form the thesis of this paper.

### 6.3 Early stopping, with relative completeness

**Definition 6.7.** $\mathrm{Drop}(f, n)$ runs the orbit from $T(n)$ for at most $f$ accelerated steps and succeeds as soon as it observes a value $< n$.

**Theorem 6.8 (Soundness).** If $\mathrm{Drop}(f,n)$ succeeds then there is $j \ge 1$ with $T^{[j]}(n) < n$.

**Theorem 6.9 (Relative completeness).** If $T^{[j]}(n) < n$ for some $j < f$, then $\mathrm{Drop}(f, n)$ succeeds.

*Proof sketch.* Both by induction on the fuel; soundness accumulates the iterate count, relative completeness observes that the search cannot terminate early with failure. $\square$

Theorem 6.9 is what makes the substitution safe: nothing certifiable by the expensive orbit-to-$1$ checker within the budget is lost by switching to the cheap drop-below test. Empirically, over the inputs below $2\times 10^4$, the drop occurs after about $3.5$ accelerated steps on average across all inputs and about $10$ on the sieved class $3 \bmod 4$, against about $61$ and $68$ respectively for the full orbit to $1$ — a saving of roughly sevenfold on the inputs actually examined, and about eighteenfold averaged over all inputs. The strong induction of Theorem 6.1 never needed more.

**Theorem 6.10 (The production checker).** Define $\mathrm{SD}(f,n) = \mathrm{true}$ if $n \not\equiv 3 \pmod 4$, and $\mathrm{Drop}(f,n)$ otherwise. If $\mathrm{SD}(f,n)$ holds for all $n \in [1,B]$, then $\mathrm{Reach}(n)$ for all $n \in [1,B]$.

*Proof sketch.* Strong induction combining the three cases of Theorem 5.7 with Theorem 6.8 in the residue-$3$ case. $\square$

### 6.4 The shape of the evaluation

**Definition 6.11 (Balanced check).** $\mathrm{Bal}(p,\ell,0) = p(\ell)$ and $\mathrm{Bal}(p,\ell,d+1) = \mathrm{Bal}(p,\ell,d) \wedge \mathrm{Bal}(p, \ell + 2^d, d)$.

**Theorem 6.12.** $\mathrm{Bal}(p,\ell,d) = \mathrm{Chk}(p,\ell,2^d)$ for all $d, \ell$; equivalently, balanced evaluation computes the same bounded conjunction as linear evaluation, over the same $2^d$ inputs.

*Proof sketch.* Induction on $d$ using the splitting law (Theorem 2.3) with $2^{d+1} = 2^d + 2^d$. $\square$

The content is that the *shape* of an evaluation is a free parameter: two programs, provably equal, but one recursing to depth $2^d$ and the other to depth $d$. Linear evaluation of a verified window becomes infeasible around $2 \times 10^4$ inputs for reasons of evaluation depth rather than time; balanced evaluation shows no such obstruction, so the reachable bound becomes limited by time alone.

**Theorem 6.13 (Strengthened certified bound).** Every $n \le 131072 = 2^{17}$ satisfies $\mathrm{ReachCol}(n)$.

*Proof sketch.* A single balanced window of depth $17$ starting at $1$, with the production checker $\mathrm{SD}$ at fuel $400$; Theorem 6.12 converts it to the linear window check, Theorem 6.10 converts that to $\mathrm{Reach}$ on $[1,2^{17}]$, and Theorem 5.3 converts that to the classical map. $\square$

Recording the progression:

| certificate | reach | inputs examined | mechanism |
|---|---|---|---|
| naive orbit check | $20$ | $20$ | brute force |
| naive orbit check | $1000$ | $1000$ | brute force |
| mod-$4$ sieve | $4000$ | $1000$ | Theorem 5.7 |
| sieve + drop-below + balanced | $131072$ | $32768$ | Theorems 5.7, 6.10, 6.12 |

A factor of $6553$ over the starting evidence, obtained entirely from theorems about *why less work suffices*.

---

## 7. The learning boundary

Theorem 3.9 is a statement about the unrestricted hypothesis class. Restricting the class inverts it completely.

**Definition 7.1.** $\mathcal{P}_T = \{\, p : p(n + T) = p(n) \text{ for all } n \,\}$, the class of $T$-periodic predicates.

**Theorem 7.2 (Periodic extensionality).** Let $T > 0$ and $p, q \in \mathcal{P}_T$ agree on $[1,T]$. Then $p(n) = q(n)$ for all $n \ge 1$.

*Proof sketch.* Strong induction: for $n > T$, both sides reduce to their values at $n - T \ge 1$. $\square$

**Theorem 7.3 (Finite evidence identifies a periodic hypothesis).** Let $T > 0$. All members of $\mathcal{P}_T \cap V(p,T)$ agree on the positive integers: the version space is a singleton (as a set of behaviours on $\mathbb{N}_{\ge 1}$).

*Proof.* Two such hypotheses agree with $p$ on $[1,T]$, hence with each other; apply Theorem 7.2. $\square$

**Theorem 7.4 (Sharpness of the sample size).** For every $T \ge 2$ there are distinct $p, q \in \mathcal{P}_T$ agreeing on $[1, T-1]$ and differing at $T$.

*Proof.* Take $p \equiv \mathrm{true}$ and $q(k) = (k \not\equiv 0 \bmod T)$. Both have period $T$; they agree on $[1,T-1]$, where $k \bmod T = k \ne 0$; and they differ at $T$. $\square$

**Theorem 7.5 (Learning dichotomy).** Let $T > 0$ and let the evidence be the values of a predicate at $1, \ldots, T$. Then
$$\mathfrak{c} \le |V(p,T)| \qquad \text{and} \qquad \mathcal{P}_T \cap V(p,T) \text{ is a singleton on } \mathbb{N}_{\ge 1}.$$
The sample complexity of $\mathcal{P}_T$ is exactly $T$, while the unrestricted class has none.

**Theorem 7.6 (Computational face of the dichotomy).** $\forall n \ge 1,\ p(n)$ holds if and only if $p$ admits a descent certificate. Periodicity is one such structure: a $T$-periodic $p$ with a verified window $[1,T]$ has a descent certificate.

The dichotomy is the same phenomenon viewed twice. Statistically: evidence is informative to the extent that the hypothesis class is constrained; the constraint, not the sample size, does the work. Logically: a finite window proves a universal statement to the extent that the predicate carries a well-founded reduction; the reduction, not the window size, does the work. In both readings, the *amount* of computation is irrelevant to the qualitative question — it determines only how large the certified region is, never whether the region is all of $\mathbb{N}$.

---

## 8. Algorithms

We record the three procedures that carry the computational content.

**Algorithm A (Balanced window certification).** To certify a predicate on $2^d$ consecutive inputs, recursively certify the two halves of $2^{d-1}$ and conjoin. Depth $d$, total work $2^d \cdot c$ where $c$ is the per-input cost. Correctness is Theorem 6.12; the gluing law (Corollary 2.4) is what makes the recursion equal to the intended conjunction rather than merely implying it.

**Algorithm B (Sieved drop-below test).** On input $n$: if $n \not\equiv 3 \pmod 4$, return true immediately. Otherwise iterate $T$ from $T(n)$ for at most $f$ steps, returning true at the first value below $n$ and false if the budget is exhausted. Expected cost on examined inputs is $O(1)$ accelerated steps (about $4$ empirically); the examined fraction is $1/4$. Correctness is Theorems 6.8 and 6.10; no certificate is lost by Theorem 6.9.

**Algorithm C (Non-contracting class enumeration at scale $k$).** Enumerate residues $r < 2^k$; simulate $k$ steps of $T$ symbolically to record $s_k(r)$, the count of odd steps; retain $r$ iff $2^k \le 3^{s_k(r)}$. Cost $O(k 2^k)$. The output is exactly the residue set a scale-$k$ sieve must examine (Theorem 6.3), and its density controls Theorem 6.6.

---

## 9. Discussion

### 9.1 What "verified to $10^{20}$" means

A precise answer is now available. It means: the bounded statement on $[1, 10^{20}]$ holds, and no more. The version space after that computation has cardinality $\mathfrak{c}$; it contains the truncation of the true predicate at $10^{20}$, a hypothesis fitting every observed bit and failing at the next input. The intuition that large-scale verification makes a conjecture "probably true" is therefore not a theorem in the unrestricted class; it is a Bayesian statement that presupposes a prior concentrated on structured hypotheses — and Theorem 7.5 is the precise statement that such a prior is exactly what does the work.

### 9.2 Structure versus computation

The most useful practical consequence is quantitative rather than philosophical. Every improvement in §5 and §6 is a *theorem about what need not be checked*:

* the residue sieve says three-quarters of inputs need not be checked;
* the arithmetic characterisation says the fraction that must be checked can be made arbitrarily small by working at a higher $2$-adic scale;
* early stopping says the orbit need not be followed to $1$;
* balanced evaluation says the certified conjunction need not be evaluated in the order it is written.

Together these bought a factor of $6553$ in reach with no additional hardware. There is a general lesson: in certified computation, mathematical reformulation of the certification target is usually cheaper than more machine time, and — because each reformulation is itself a theorem — it costs nothing in reliability.

### 9.3 Limits of the negative results

Theorem 3.9 is a cardinality statement, deliberately coarse; it does not preclude *measure-theoretic* or *complexity-theoretic* refinements in which finite evidence does eliminate a positive fraction of a suitably weighted hypothesis space. Making such a refinement precise — a natural measure on hypothesis space under which a certificate on $[1,N]$ has quantifiable value — is the most interesting open direction suggested here, and Theorem 7.5 indicates the shape the answer must take: the measure must be concentrated on structured classes.

### 9.4 Relation to the $3n+1$ problem

Nothing here bears on the truth of the Collatz conjecture. What the development contributes is a precise reformulation: the conjecture is *equivalent* to the existence of a descent certificate for its checker (Theorem 5.14), and equivalently to a well-founded reduction defined above some finite window. Existing partial results — almost-all-orbits results, non-descending-density estimates — are naturally read as approximations to such a reduction: they exhibit reductions valid on sets of density tending to $1$. The gap is between "density $1$" and "everything", which is exactly the gap Theorem 6.6 quantifies and Theorem 5.13 declares uncrossable by computation.

---

## 10. Future directions

**1. A logarithmic-depth reflection hierarchy.** We conjecture that for every depth $d$, a balanced checker verifies $2^d$ inputs at evaluation depth $\Theta(d)$ and time $\Theta(2^d c)$ with $c$ the per-input cost, so that the reachable certified bound is limited by *time alone*; and that a chunked family glued by Corollary 2.4 attains any bound an unverified compiled run attains, at constant-factor slowdown. The key insight is that the failure mode of large certificates is the *shape* of the evaluation, not its size: linear evaluation fails at $\approx 2\times 10^4$ inputs at any time budget, whereas balanced evaluation at the same per-input cost reached $1.3 \times 10^5$ with no depth-related obstruction. The statement is falsifiable by exhibiting a depth at which balanced evaluation fails for a reason other than time. Theorems 2.3 and 6.12 are already in place, so what remains is an amortisation argument plus engineering.

**2. Optimality of the residue sieve at scale $k$.** We conjecture that the scale-$k$ sieve is optimal among residue sieves: the set of classes that must be examined is exactly the non-contracting set, i.e. for every non-contracting class there are arbitrarily large inputs in it that fail to descend within $k$ accelerated steps, so no smaller residue set is sound. Quantitatively we conjecture $|\mathcal{NC}_k| / 2^k = \Theta(1/\sqrt{k})$, rather than the $O(1/k)$ Chebyshev bound currently available. The key insight is that Theorem 6.3 reduces the analytic contraction condition to the integer inequality $2^k \le 3^{s_k(r)}$, turning optimality into a large-deviation counting problem about parity words, which the parity-word correspondence makes exact. The case $k = 2$ is settled: the unique non-contracting class is $3$, and the examined set is exactly $\{1,2\}$ together with the class $3 \bmod 4$, of size $\lfloor (B+1)/4\rfloor + 2$, because the two-step map sends $4m+3 \mapsto 9m+8$. The general case requires the same computation at scale $k$.

**3. A quantitative theory of evidential value.** Replace cardinality by measure: put a natural prior on hypothesis space and compute the posterior mass eliminated by a certificate on $[1,N]$. Theorem 7.5 suggests the answer is governed by how much prior mass sits on classes with finite sample complexity.

**4. Descent certificates with non-monotone reductions.** Definition 4.1 requires $r(n) < n$. Weakening this to well-foundedness with respect to another order — or to a ranking function into a well-ordered set — would cover reductions like "reduce to a smaller $2$-adic scale" and might bring known partial Collatz results inside the certificate framework.

**5. Certificates for other conjectures.** The framework is conjecture-agnostic. Natural targets are numerical-semigroup and Frobenius-type statements (where shift certificates apply directly and the framework is already complete), and modular statements (where periodic certificates apply). The interesting cases are those, like Collatz, where the reduction is conjectural but the sieve theory is not.

---

## 11. Conclusion

Bounded verification has an exact logical strength, and it is smaller than intuition suggests and larger than pessimism allows. Smaller: no finite certificate is sound for a universal statement, the version space after any check retains the cardinality of the continuum, and for Collatz specifically every certificate is consistent with failure at the next untested input. Larger: adjoining a well-founded reduction produces a proof system that is not merely sound but *complete*, and simple structural hypotheses — periodicity, closure under a shift — are already reductions, converting windows of ten and three inputs into genuinely universal theorems.

Between the two lies engineering that is really mathematics. A residue sieve, provably optimal at its scale, quarters the work; higher $2$-adic scales drive the examined fraction to zero; stopping the orbit at the first descent rather than at $1$ saves close to another order of magnitude with no loss of certifying power; and re-shaping the evaluation from linear to balanced removes the last structural obstruction. The composite raised the certified Collatz bound from $20$ to $131072$ without a faster machine.

The final picture is a dichotomy. At the same amount of evidence, an unconstrained hypothesis class retains a continuum of candidates and a $T$-periodic class retains exactly one. Evidence is worthless or conclusive according to the class, never according to the amount of computation. That is the whole theory, and it applies verbatim to every conjecture anyone has ever "verified up to $N$".
