# Sound Proof Automation for the Catalog: Three Domain Tactics and Their Correctness Certificates

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Proof Automation)

---

## Abstract

We present three custom proof tactics, each targeting a recurring proof pattern
in a large formal mathematics catalog, and we prove each one *sound* — that is,
incapable of certifying a false statement. The tactics are: `tropical_simp`, a
simplifier for the min-plus (tropical) semiring built exclusively from proven
rewrite equalities; `number_theory_decide`, a finite-case closer assembled as a
disjunction of sound primitive decision procedures; and `spectral_bound`, an
eigenvalue-magnitude estimator backed by a from-scratch proof of a weak
Gershgorin (absolute-row-sum) bound. For each tactic we establish a *correctness
certificate*: a theorem whose truth guarantees the tactic's soundness. We then
demonstrate that each tactic attains its real utility only in concert with
genuine structural mathematics that decision procedures cannot supply. The
flagship illustrations are (i) an inductive *scalar fold law* certifying tropical
scalar distribution over sums of arbitrary length; (ii) **Pisano periodicity** of
the Fibonacci sequence modulo $m$, proved by a paired two-track induction, with
the seed residues discharged by `number_theory_decide`, plus Fermat-style
congruences via reduction to $\mathrm{ZMod}\,p$; and (iii) the absolute-row-sum
eigenvalue bound with a symmetric-interval corollary for real eigenvalues. The
recurring thesis is a clean division of labor: sound automation handles the
finite/routine layer, while human-style reasoning supplies the structural core.

---

## 1. Introduction

Formalized mathematics accumulates not only theorems but *proof patterns*:
stereotyped sequences of steps that recur across many developments. Three such
patterns motivate this work.

1. **Min-plus algebra.** Tropical (min-plus) computations — shortest paths,
   scheduling, dynamic programming, tropical geometry — repeatedly require
   normalizing expressions built from $\min$ and $+$ under a distributive law.
2. **Finite reduction in number theory.** A great many number-theoretic claims
   over infinitely many integers reduce, after the right structural move
   (an induction base, a quotient to $\mathrm{ZMod}\,m$, a residue seed), to a
   *finite* mechanical check.
3. **Eigenvalue localization.** Stability, convergence, and conditioning
   arguments frequently need only a *bound* on eigenvalue magnitudes, not exact
   values.

For each pattern we build a tactic that automates its routine kernel, and we
prove the tactic sound. Soundness here means: *the tactic closes a goal only if
the goal is true.* We obtain soundness in two complementary styles. For
`tropical_simp` and `number_theory_decide`, soundness is *structural* — the
tactic is assembled solely from sound components (proven rewrite lemmas;
individually sound decision procedures), so no false goal is reachable. For
`spectral_bound`, soundness is *certified by a theorem* (`eigenvalue_rowsum_bound`)
that the tactic merely applies.

The remainder of the paper treats each tactic in turn (Sections 3–5), states its
correctness certificate, and develops the structural mathematics that makes it
useful. Section 6 distills the design principle; Section 7 lists future
directions.

---

## 2. Preliminaries and notation

We work over the reals $\mathbb{R}$, the naturals $\mathbb{N}$, and the integers
$\mathbb{Z}$, and use $\mathrm{ZMod}\,m$ for the integers modulo $m$ (a finite
commutative ring, and a field when $m$ is prime). The Fibonacci sequence is
$F_0 = 0$, $F_1 = 1$, $F_{n+2} = F_{n+1} + F_n$. For a square matrix
$M \in \mathbb{R}^{n\times n}$ and vector $v \in \mathbb{R}^n$, $Mv$ denotes the
usual matrix–vector product $(Mv)_i = \sum_j M_{ij}v_j$, and $\lambda$ is an
*eigenvalue* with *eigenvector* $v \neq 0$ when $Mv = \lambda v$.

A **tactic** is a metaprogram transforming proof goals. A tactic is **sound** if
every goal it closes is true. We freely use the following sound primitives as
black boxes: `decide` (kernel evaluation of a `Decidable` proposition); `norm_num`
(numeric normalization with arithmetic/primality extensions); `omega` (linear
integer/natural arithmetic); `nlinarith` (nonlinear arithmetic over ordered
fields); and `fin_cases` (finite case exhaustion). Each is independently sound;
our soundness arguments reduce to this fact.

---

## 3. `tropical_simp`: a sound min-plus simplifier

### 3.1 The min-plus semiring

The **tropical (min-plus) semiring** equips $\mathbb{R}$ with
$a \oplus b := \min(a,b)$ as addition and $a \odot b := a + b$ as multiplication.
The distributive law $a \odot (b \oplus c) = (a \odot b) \oplus (a \odot c)$ is
the concrete real-number identity

$$a + \min(b,c) = \min(a+b,\ a+c). \tag{3.1}$$

**Lemma 3.1 (`trop_scalar_min`).** *For all $a,b,c \in \mathbb{R}$,*
$a + \min(b,c) = \min(a+b,\ a+c)$.

*Proof.* Case split on $b \le c$ vs. $c \le b$. If $b \le c$ then
$a+b \le a+c$, so both sides equal $a+b$; symmetrically in the other case. $\square$

**Lemma 3.2 (`trop_scalar_min_right`).** *For all $a,b,c \in \mathbb{R}$,*
$\min(a,b) + c = \min(a+c,\ b+c)$.

*Proof.* Commute the additions and apply Lemma 3.1. $\square$

### 3.2 The tactic and its soundness

`tropical_simp` is defined as `simp only` over a fixed rewrite set: the two
distributivity lemmas above together with the associative/commutative laws of
$\min$ (`min_comm`, `min_assoc`, `min_left_comm`), idempotence (`min_self`), and
the additive monoid laws (`add_assoc`, `add_zero`, `zero_add`).

**Theorem 3.3 (Soundness of `tropical_simp`).** *Every goal closed by
`tropical_simp` is a true identity of real numbers.*

*Proof.* `simp only [S]` rewrites the goal using only the equations in $S$ and
closes it when both sides become syntactically equal. Each member of $S$ is a
proven equality (Lemmas 3.1–3.2 and standard library identities), so each rewrite
preserves the truth value; a goal reduced to reflexivity was therefore already
true. $\square$

The tactic is *normalizing*, not complete: it cannot evaluate $\min(a,b)$ when
the order of $a,b$ is unknown (that is a case split, not a rewrite). This is the
honest scope. Worked goals it discharges include

$$a + \min(\min(b,c),d) = \min(a+b,\ \min(a+c,\ a+d)),$$
$$\min(a,b)+c = \min(b+c,\ a+c), \qquad a + \min(b,b) = a+b,$$

the second requiring AC-normalization (which is why `min_left_comm` is essential —
without it `simp` fails to canonicalize re-bracketed $\min$ trees).

### 3.3 The structural core: scalars distribute over whole sums

Finite rewrite rules handle expressions of fixed shape; universally quantified
statements about sums of arbitrary length need induction. Model a tropical sum as
a right fold of $\min$ over a list with base value $d$.

**Theorem 3.4 (`scalar_foldr_min`).** *For all $c,d \in \mathbb{R}$ and every
finite list $\ell = [a_1,\dots,a_k]$ of reals,*

$$c + \mathrm{foldr}\,\min\,d\,\ell = \mathrm{foldr}\,\min\,(c+d)\,\big(\mathrm{map}\,(c + \cdot)\,\ell\big),$$

*i.e.*

$$c + \min(a_1,\dots,a_k,d) = \min(c+a_1,\dots,c+a_k,\ c+d).$$

*Proof.* Induction on $\ell$. For $\ell = []$ both sides are $c+d$. For
$\ell = a :: t$, unfold the folds and maps to expose
$c + \min(a,\ \mathrm{foldr}\,\min\,d\,t)$; apply Lemma 3.1
(`trop_scalar_min`) to split off $c+a$, then the induction hypothesis on $t$. $\square$

Theorem 3.4 is the closed-form correctness guarantee that `tropical_simp`
realizes one step at a time: the tactic performs each distribution; the induction
certifies the unbounded composite.

### 3.4 Bridge: min-plus from max-plus by duality

Min-plus and max-plus are exchanged by negation, $\min(a,b) = -\max(-a,-b)$.
Using a catalog max-plus distributivity lemma
`tropical_scalar_distrib`: $a + \max(b,c) = \max(a+b,a+c)$, one derives (3.1):

**Proposition 3.5 (`minplus_via_maxplus`).** *Identity (3.1) follows from the
max-plus distributive law via the negation duality.*

*Proof.* Write $\min(b,c) = -\max(-b,-c)$ and
$\min(a+b,a+c) = -\max(-(a+b),-(a+c))$, expand $-(a+x) = -a + -x$, and apply the
max-plus law at $(-a,-b,-c)$. $\square$

---

## 4. `number_theory_decide`: a sound finite-case closer

### 4.1 The tactic and its soundness

`number_theory_decide` is the ordered disjunction

```
first | omega | decide | norm_num | (intro x; fin_cases x <;> decide)
```

(in a variant tuned for residue goals, `decide` precedes `norm_num`, because
`norm_num` may partially rewrite a $\mathrm{ZMod}$ residue and stall, whereas
`decide` evaluates it directly). With `set_option maxRecDepth` raised, `decide`
handles primality of explicit numbers and $\mathrm{ZMod}$ residue identities; the
final branch exhausts a finite type and computes each case.

**Theorem 4.1 (Soundness of `number_theory_decide`).** *Every goal closed by
`number_theory_decide` is true.*

*Proof.* `first | t₁ | … | tₙ` closes a goal iff some $t_i$ does, so soundness of
the combination follows from soundness of each branch. `omega`, `decide`,
`norm_num`, and `fin_cases`+`decide` are each individually sound. $\square$

**Proposition 4.2 (Soundness sampler, `number_theory_decide_sound`).** *Each of
the following is true and is closed by the tactic:* $561$ is not prime; $17$ is
prime; $\gcd(561,560)=1$; $(3-1)\mid 560$, $(11-1)\mid 560$, $(17-1)\mid 560$;
and $F_3 \equiv 0$, $F_4 \equiv 1 \pmod 2$.

The divisibility triple is **Korselt's criterion** for $561 = 3\cdot 11\cdot 17$,
the smallest Carmichael number; the sampler thus records exactly the finite data
on which Carmichael/Fermat arguments bottom out.

The tactic's value, however, is realized only when paired with a *reduction*.
We exhibit three canonical reductions.

### 4.2 Reduction A — induction with a finite base

**Theorem 4.3 (`two_pow_gt_sq`).** *For all $n \ge 5$, $n^2 < 2^n$.*

*Proof.* Induction on $n$. The values below $5$ (and the genuine base $n=5$) are
closed by `number_theory_decide`. For the step, from $k^2 < 2^k$ and $k \ge 5$,
$$(k+1)^2 \le k^2 + k^2 < 2^k + 2^k = 2^{k+1},$$
where $(k+1)^2 \le 2k^2$ for $k\ge 5$ is a nonlinear estimate (`nlinarith`). $\square$

The inductive step is *not* decidable; the finite base is. The tactic owns only
the latter.

### 4.3 Reduction B — Fermat congruences via $\mathrm{ZMod}\,p$

**Theorem 4.4 (`fermat_little_five`, `fermat_little_seven`).** *For every integer
$n$ and $p \in \{5,7\}$, $p \mid n^p - n$.*

*Proof (uniform).* It suffices (by `ZMod.intCast_zmod_eq_zero_iff_dvd`) to show
$(n^p - n) \equiv 0$ in $\mathrm{ZMod}\,p$. By the ring-hom cast (`push_cast`),
this reduces to the finite identity $x^p = x$ for all $x \in \mathrm{ZMod}\,p$,
which `number_theory_decide` verifies by exhausting the $p$ residues. $\square$

**Theorem 4.5 (`cube_sub_self_six`).** *For every integer $n$, $6 \mid n^3 - n$.*

*Proof.* Same pattern with the composite modulus: check $x^3 = x$ for all
$x \in \mathrm{ZMod}\,6$. $\square$

The reduction (quotient to a finite ring) is the insight; the residue exhaustion
is the tactic.

### 4.4 Reduction C — Pisano periodicity by paired induction

The Fibonacci sequence is eventually periodic modulo every $m$ (the **Pisano
period**). The clean statement isolates the structural core from the decidable
seeds.

**Theorem 4.6 (Pisano step, paired form, `fib_pisano_step`).** *Fix $m,p$ with
$F_p \equiv 0$ and $F_{p+1} \equiv 1 \pmod m$. Then for every $n$,*

$$F_{n+p} \equiv F_n \quad\text{and}\quad F_{n+p+1} \equiv F_{n+1} \pmod m. \tag{4.1}$$

*Proof.* Induction on $n$, carrying *both* congruences simultaneously. For $n=0$
they are exactly the seed hypotheses ($F_0 = 0$, $F_1 = 1$). For the step,
assume (4.1) at $k$. The first congruence at $k+1$ is the second at $k$ after
reindexing $k+1+p = (k+p)+1$. The second at $k+1$ uses the recurrence: with
$k+1+p+1 = (k+p)+2$,
$$F_{(k+p)+2} = F_{(k+p)+1} + F_{k+p} \equiv F_{k+1} + F_k = F_{k+2} \pmod m,$$
applying both halves of the induction hypothesis. $\square$

A *single*-track induction fails: the recurrence couples consecutive terms, so
advancing $F_{n+p}$ requires also knowing $F_{n+p+1}$. The paired invariant is
the genuine content.

**Corollary 4.7 (Pisano periodicity, `fib_mod_periodic`).** *Under the seeds of
Theorem 4.6, $F_{n+p} \equiv F_n \pmod m$ for all $n$* (first component of (4.1)).

**Corollary 4.8 (concrete periods).** *`fib_mod_two_period`: $F_{n+3} \equiv F_n
\pmod 2$ for all $n$; `fib_mod_three_period`: $F_{n+8} \equiv F_n \pmod 3$ for all
$n$.*

*Proof.* Apply Corollary 4.7 with the seeds discharged by
`number_theory_decide`: $F_3 \equiv 0,\ F_4 \equiv 1 \pmod 2$, and
$F_8 = 21 \equiv 0,\ F_9 = 34 \equiv 1 \pmod 3$. $\square$

### 4.5 Bridge: Cassini modulo $m$

**Theorem 4.9 (`cassini_mod`).** *For all $m,n$, in $\mathrm{ZMod}\,m$,*

$$F_{n+2}\,F_n - F_{n+1}^2 = (-1)^{n+1}.$$

*Proof.* Cast the integer Cassini identity $F_{n+2}F_n - F_{n+1}^2 = (-1)^{n+1}$
(catalog lemma `fib_cassini`) along the ring homomorphism $\mathbb{Z} \to
\mathrm{ZMod}\,m$ via `push_cast`. $\square$

A concrete instance, `cassini_mod_example`: modulo $5$ at $n=4$,
$F_6 F_4 - F_5^2 = 8\cdot 3 - 25 = -1 = (-1)^5$, is closed by the tactic directly.

---

## 5. `spectral_bound`: a sound eigenvalue-magnitude estimator

### 5.1 The correctness certificate

**Theorem 5.1 (Weak Gershgorin row-sum bound, `eigenvalue_rowsum_bound`).** *Let
$n \ge 1$, $M \in \mathbb{R}^{n\times n}$, $v \in \mathbb{R}^n$ with $v \neq 0$,
and $\lambda \in \mathbb{R}$ with $Mv = \lambda v$. If $B \in \mathbb{R}$ satisfies
$\sum_j |M_{ij}| \le B$ for every row $i$, then $|\lambda| \le B$.*

*Proof.* Since $\mathrm{Fin}\,n$ is finite and nonempty (as $n\ge 1$), choose $i$
maximizing $|v_i|$. Because $v \neq 0$, some coordinate $v_k \neq 0$, so
$0 < |v_k| \le |v_i|$; thus $|v_i| > 0$. The $i$-th row of $Mv = \lambda v$ reads
$\sum_j M_{ij}v_j = \lambda v_i$. Then
$$|\lambda|\,|v_i| = |\lambda v_i| = \Big|\sum_j M_{ij}v_j\Big| \le \sum_j |M_{ij}|\,|v_j| \le \Big(\sum_j |M_{ij}|\Big)|v_i| \le B\,|v_i|,$$
using the triangle inequality, $|v_j| \le |v_i|$, and the row bound. Cancel the
positive factor $|v_i|$ to get $|\lambda| \le B$. $\square$

The hypothesis $v \neq 0$ is load-bearing: a zero "eigenvector" would admit any
$\lambda$. Abstracting the bound to a hypothesis $B$ with $\sum_j |M_{ij}| \le B$
(rather than $\max_i \sum_j |M_{ij}|$ directly) avoids `Finset.sup'` bookkeeping
without weakening the result — $B := \max_i \sum_j|M_{ij}|$ recovers the sharp
form.

### 5.2 The tactic and its soundness

`spectral_bound` reduces an eigenvalue-magnitude goal $|\lambda| \le B$ to the
hypotheses of Theorem 5.1 (it `apply`s the certificate and discharges the
side-goals from context). Because it only applies a proved theorem:

**Theorem 5.2 (Soundness of `spectral_bound`).** *Every goal closed by
`spectral_bound` is true.* $\square$

### 5.3 Worked example and real-eigenvalue corollary

For $M = \begin{pmatrix}1 & 2\\ 0 & 3\end{pmatrix}$, both absolute row sums equal
$3$, so every eigenvalue satisfies $|\lambda| \le 3$ (the true eigenvalues are
$1$ and $3$). Feeding the row-sum bound to the certificate proves the bound
formally.

**Corollary 5.3 (Symmetric interval, `eigenvalue_interval`).** *Under the
hypotheses of Theorem 5.1, a real eigenvalue obeys $-B \le \lambda \le B$.*

*Proof.* $|\lambda| \le B \iff -B \le \lambda \le B$. $\square$

This two-sided form is the shape consumed by downstream stability and convergence
arguments.

---

## 6. Discussion: a design principle for sound automation

Across all three tactics the same architecture recurs.

- **Soundness is cheap and structural.** Build the tactic only from sound parts
  — proven rewrite equalities (`tropical_simp`), individually sound decision
  procedures (`number_theory_decide`), or a single proved certificate applied
  verbatim (`spectral_bound`). Then "the tactic never lies" is a one-line
  argument, not a verification burden.
- **Scope honesty.** Each tactic has a precise boundary: `tropical_simp`
  normalizes but cannot case-split on unknown orders; `number_theory_decide`
  decides finite goals but not the surrounding induction or quotient;
  `spectral_bound` gives the *weak* (single-disc) Gershgorin bound, not the
  per-disc union.
- **Power comes from pairing.** The decisive mathematics is always the
  *reduction*: the inductive scalar-fold law, the paired Pisano invariant, the
  reduce-mod-$p$ quotient, the extremal-coordinate argument. Automation supplies
  the finite/routine layer; structure supplies the rest.

The practical upshot is a maintainable library: small sound closers that compose
with hand-written structural lemmas, each tactic carrying a theorem that explains
exactly why it is trustworthy.

---

## 7. Future directions

**Conjecture 1 — `tropical_simp` is complete for the min/+ fragment.** Every
universally quantified identity $s=t$ between tropical polynomial expressions over
$\mathrm{Tropical}\,\mathbb{Z}$ whose only operations are $\oplus$ (min),
$\odot$ (+), and constants $0,1$ is closed by `tropical_simp; omega`. After
`untrop` injectivity and unfolding, such an identity becomes a quantifier-free
formula in $(\mathbb{Z},+,\min)$ — exactly the decidable fragment `omega`
handles; only $\mathbb{N}$-scaling (powers) escapes.

**Conjecture 2 — scaling is the unique obstruction (a sharp boundary theorem).**
`tropical_simp; omega` closes a tropical identity *iff* it contains no genuine
exponent-dependence; every failure is inter-reducible with an instance of
$n \bullet \min(p,q) = \min(n\bullet p,\ n\bullet q)$. The freshman's-dream
identity was the only demonstration needing a non-`omega` step (monotonicity of
$n\cdot$), isolating $\mathbb{N}$-scaling as a canonical hard core via
`mul_le_mul_of_nonneg_left`.

**Conjecture 3 — paired-invariant induction mechanizes all Pisano periods.**
There is a tactic `pisano_period m` that computes the period $p$ via
`number_theory_decide` on candidate seeds and returns a proof of
$\forall n,\ F_{n+p} \equiv F_n \pmod m$ for every $m \ge 1$, with runtime
polynomial in $p$. Theorem 4.6 reduces periodicity to verifying the two seed
residues; the only search needed is for the seed $p$.

**Conjecture 4 — Korselt's criterion is `number_theory_decide`-certifiable.**
For every squarefree $n < N$ (fixed bound), "$n$ is Carmichael $\iff$
$\forall$ prime $p \mid n,\ (p-1)\mid(n-1)$" reduces, via one structural lemma
plus `number_theory_decide` on the finite prime/divisibility data, to a proof
with no `native_decide`. The hard direction (Korselt $\Rightarrow$ Fermat
congruence) is a CRT + Fermat argument independent of $n$; the per-$n$ data
(squarefreeness, $(p-1)\mid(n-1)$) is decidable.

**A sharpening for `spectral_bound`.** Upgrade the single global disc to the
union of per-row Gershgorin discs, and extend the certificate to complex
matrices and operator-norm bounds.

---

## 8. Conclusion

We built three sound domain tactics — `tropical_simp`, `number_theory_decide`,
and `spectral_bound` — and proved each one cannot certify a falsehood, by
structural soundness or by an applied correctness certificate. In each case the
tactic's true leverage emerged from a partnership with genuine structural
mathematics: the inductive scalar-fold law, Pisano periodicity via a paired
invariant together with Fermat congruences, and the absolute-row-sum eigenvalue
bound. Sound automation for the routine, human-style reasoning for the
structural: a small, reusable, and trustworthy contribution to a growing formal
catalog.
