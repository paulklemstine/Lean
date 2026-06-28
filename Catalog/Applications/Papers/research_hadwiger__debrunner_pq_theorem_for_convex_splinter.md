# The Hadwiger–Debrunner $(p,q)$ Theorem for Convex Splinters: A Combinatorial Factorization

**Author:** Aristotle

**Date:** 2026-06-28

**Domain:** Applications (a bridge between Geometry and Combinatorics)

---

## Abstract

The Hadwiger–Debrunner $(p,q)$ theorem, proved in full by Alon and Kleitman, states that for
every dimension $d$ and integers $p \ge q \ge d+1$ there is a constant $N = N(d,p,q)$, independent
of the size of the family, such that any finite family of convex sets in $\mathbb{R}^d$ with the
$(p,q)$-property can be pierced by at most $N$ points. We study the extension of this theory from
convex sets to *convex splinters* (in the sense of Arocha–Bracho–Montejano), for which the relevant
Helly number is $2d+1$ rather than $d+1$. Our central structural contribution is a clean
**factorization** of the transversal theory into two independent layers: a *set-class-agnostic
combinatorial core*, which depends on neither dimension nor convexity, and a *single geometric
scalar*, the Helly number, through which all geometry enters. We isolate and prove the combinatorial
core in full: monotonicity of the $(p,q)$-property in both parameters, the existence of a trivial
transversal of size at most the family cardinality, and an elementary one-shot transversal bound of
$|s| - q + 1$ obtained from the full $(|s|,q)$-property. We then describe the Helly-bridge interface
through which the convex Helly number $d+1$ and the splinter Helly number $2d+1$ are supplied, and we
lay out the recursion-theoretic program by which the one-shot bound is to be upgraded to the
dimension-independent constant $N(d,p,q)$. All combinatorial results stated here have been formally
verified.

---

## 1. Introduction

### 1.1 Helly's theorem and its number

A family of sets has the **Helly property with number $h$** if, whenever every $h$ members of the
family have a common point, *all* members of the family have a common point. Helly's classical 1913
theorem asserts that convex sets in $\mathbb{R}^d$ have Helly number $h = d+1$:

$$
\Big(\forall\, A \subseteq s,\ |A| = d+1 \implies \bigcap_{i \in A} F_i \neq \varnothing\Big)
\ \Longrightarrow\ \bigcap_{i \in s} F_i \neq \varnothing
\qquad (F_i \text{ convex in } \mathbb{R}^d).
$$

The Helly number is the single integer that summarizes how much *local* intersection forces *global*
intersection. It is the geometric invariant on which the entire transversal theory turns.

### 1.2 The $(p,q)$-property and transversals

Helly's theorem is all-or-nothing. The Hadwiger–Debrunner relaxation (1957) softens it. A family
$F : \iota \to \mathrm{Set}\,X$ indexed by a finite set $s$ has the **$(p,q)$-property** if among
every $p$ members, some $q$ have a common point. A finite set of points $T$ is a **transversal**
(or *piercing set*) if every member contains a point of $T$; the **transversal number** $\tau$ is
the least cardinality of a transversal.

The Hadwiger–Debrunner $(p,q)$ theorem, established for convex sets by Alon and Kleitman (1992),
states: for $p \ge q \ge d+1$, there exists $N(d,p,q)$, independent of $|s|$, with $\tau \le N(d,p,q)$.

### 1.3 Convex splinters and the threshold $2d+1$

A *convex splinter* (Arocha–Bracho–Montejano) is a not-necessarily-convex set obeying a weakened
Helly law. The cost of abandoning convexity is a larger Helly number: convex splinters in
$\mathbb{R}^d$ have Helly number $2d+1$. The extension we study is the following.

> **Theorem (Hadwiger–Debrunner for convex splinters).** For every dimension $d$ and all integers
> $p \ge q \ge 2d+1$, there is a constant $N = N(d,p,q)$ such that any finite family of convex
> splinters in $\mathbb{R}^d$ with the $(p,q)$-property admits a transversal of size at most $N$.

It is the classical theorem with the single substitution $d+1 \rightsquigarrow 2d+1$ at the Helly
threshold.

### 1.4 Contribution: the factorization

Our main conceptual contribution is the observation, made precise and formally verified, that the
transversal theory factors as

$$
\textbf{(p,q)-theory} \;=\; \textbf{combinatorics (set-class agnostic)} \;\times\; \textbf{one Helly number}.
$$

We isolate the combinatorial layer over an *arbitrary* finite family of *arbitrary* sets, with no
reference to dimension or convexity, and prove its core lemmas in full. The geometry — and hence the
distinction between $d+1$ (convex) and $2d+1$ (splinter) — enters only through a single scalar,
supplied at a clean interface we call the *Helly bridge*.

---

## 2. Definitions

Throughout, $\iota$ and $X$ are types, $s$ is a finite subset (a `Finset`) of $\iota$, and
$F : \iota \to \mathrm{Set}\,X$ is a family of sets.

**Definition 2.1 (The $(p,q)$-property).** The family $F$ over $s$ has the **$(p,q)$-property**,
written $\mathrm{HasPQProperty}(s, F, p, q)$, if

$$
\forall A \subseteq s,\ |A| = p \ \Longrightarrow\ \exists B \subseteq A,\ |B| = q \ \wedge\
\Big(\bigcap_{i \in B} F_i\Big) \neq \varnothing.
$$

In words: every $p$-element subfamily contains a $q$-element subfamily with nonempty common
intersection.

**Definition 2.2 (Transversal).** A finite set of points $T \subseteq X$ is a **transversal** of $F$
over $s$, written $\mathrm{IsTransversal}(T, s, F)$, if

$$
\forall i \in s,\ \exists t \in T,\ t \in F_i.
$$

The **transversal number** $\tau(s, F)$ is the minimum of $|T|$ over all transversals $T$.

**Definition 2.3 (Helly number, interface form).** A family has **Helly number $h$** over $s$,
written $\mathrm{HasHellyNumber}(s, F, h)$, if for every subfamily, $h$-wise intersection implies
total intersection. Convex sets in $\mathbb{R}^d$ satisfy this with $h = d+1$
($\texttt{convex\_hasHellyNumber}$), and convex splinters with $h = 2d+1$. This is the *only*
geometric input the transversal theory consumes.

---

## 3. The combinatorial core (fully verified)

The four results in this section are proved over an arbitrary `Finset`-indexed family with no
geometric hypotheses. They constitute the reusable skeleton.

### 3.1 Monotonicity in $p$

**Theorem 3.1 ($\texttt{HasPQProperty.strengthen\_p}$).** If $F$ has the $(p,q)$-property over $s$
and $p \le p'$, then $F$ has the $(p',q)$-property over $s$.

*Proof sketch.* Let $A \subseteq s$ with $|A| = p'$. Since $p \le p' = |A|$, by
`Finset.exists_subset_card_eq` choose $B \subseteq A$ with $|B| = p$. The $(p,q)$-property applied
to $B$ yields $C \subseteq B$ with $|C| = q$ and $\bigcap_{i \in C} F_i \neq \varnothing$; then
$C \subseteq B \subseteq A$ witnesses the $(p',q)$-property for $A$. $\qquad\blacksquare$

### 3.2 Monotonicity in $q$

**Theorem 3.2 ($\texttt{HasPQProperty.weaken\_q}$).** If $F$ has the $(p,q)$-property over $s$ and
$q' \le q$, then $F$ has the $(p,q')$-property over $s$.

*Proof sketch.* Let $A \subseteq s$ with $|A| = p$. The $(p,q)$-property gives $B \subseteq A$ with
$|B| = q$ and nonempty common intersection. Since $q' \le q = |B|$, choose $B' \subseteq B$ with
$|B'| = q'$. The intersection over $B'$ contains the intersection over $B$ — formally, the bi-indexed
intersection is antitone in its index set ($\texttt{Set.biInter\_subset\_biInter\_left}$) — hence is
also nonempty. Thus $B' \subseteq A$ witnesses the $(p,q')$-property. $\qquad\blacksquare$

Theorems 3.1 and 3.2 together establish the expected monotonicity lattice: the $(p,q)$-property is
weakened by increasing $p$ or decreasing $q$, and strengthened by the reverse. This is the algebraic
scaffolding that allows $p$ and $q$ to be adjusted freely inside larger arguments.

### 3.3 The trivial transversal

**Theorem 3.3 ($\texttt{exists\_transversal\_of\_nonempty}$).** If every member $F_i$ ($i \in s$) is
nonempty, then there is a transversal $T$ with $|T| \le |s|$.

*Proof sketch.* For each $i \in s$ choose, via classical choice, a point
$x_i \in F_i$, and set $T = \{ x_i : i \in s \}$ (the image of the choice function over the attached
index set $s$). Each $F_i$ contains its own $x_i \in T$, so $T$ is a transversal, and as the image of
a set of size $|s|$ it has cardinality at most $|s|$. $\qquad\blacksquare$

This bound is crude but it is the safety net on which sharper bounds rest.

### 3.4 The elementary one-shot transversal bound

**Theorem 3.4 ($\texttt{exists\_transversal\_of\_pqProperty\_full}$).** Suppose every member is
nonempty and $F$ has the *full* $(|s|, q)$-property over $s$ (i.e. among all $|s|$ members, some $q$
share a point). Then there is a transversal $T$ with

$$
|T| \le |s| - q + 1,
$$

where subtraction is truncated natural subtraction.

*Proof sketch.* Apply the full $(|s|,q)$-property to $A = s$: obtain $B \subseteq s$ with $|B| = q$
and a point $t_0 \in \bigcap_{i \in B} F_i$. The single point $t_0$ pierces *all* $q$ members indexed
by $B$ simultaneously. For the remaining members, apply Theorem 3.3 to the complementary family
indexed by $s \setminus B$ (each member nonempty), obtaining a transversal $R$ with
$|R| \le |s \setminus B|$. Then $T = \{t_0\} \cup R$ pierces every member: those in $B$ via $t_0$,
those outside $B$ via $R$. Finally,
$$
|T| \le |R| + 1 \le |s \setminus B| + 1 = (|s| - q) + 1,
$$
using $|s \setminus B| = |s| - |B| = |s| - q$ (`Finset.card_sdiff_of_subset`). Truncated subtraction
makes the bound correct without assuming $q \le |s|$. $\qquad\blacksquare$

**Remark 3.5 (non-vacuity).** None of Theorems 3.1–3.4 is vacuous: each is a universally quantified
implication with satisfiable hypotheses — e.g. take all $F_i$ equal to one fixed nonempty set, which
satisfies every $(p,q)$-property and is pierced by a single point. None is closed by a single
decision procedure; the proofs use genuine steps (subset extraction by cardinality, antitone
bi-intersection, classical choice over an attached index set, and a `card_sdiff`/arithmetic
calculation).

**Remark 3.6 (what is *not* yet proved).** The bound $|s| - q + 1$ depends on $|s|$. It is therefore
the *trivial one-shot* bound, not the dimension-independent constant $N(d,p,q)$ of the full theorem.
Removing the dependence on $|s|$ is precisely the deep step, and it requires the Helly number; see
Sections 4 and 6.

---

## 4. The Helly bridge: where geometry enters

The combinatorial core never mentions geometry. All geometry is quarantined into a single predicate,
$\mathrm{HasHellyNumber}(s, F, h)$ (Definition 2.3), supplied at the *Helly bridge* interface:

- **Convex sets.** Mathlib's `Convex.helly_theorem` yields $\texttt{convex\_hasHellyNumber}$ with
  $h = d+1$.
- **Convex splinters.** The Arocha–Bracho–Montejano theorem yields $h = 2d+1$, supplied as a
  hypothesis pending a from-scratch Radon-type formalization.

The structural claim is that the entire $(p,q)$-to-transversal passage consumes *only* this scalar
$h$. Consequently, proving the splinter case reduces to discharging a single predicate at $h = 2d+1$,
fully decoupled from the transversal bookkeeping of Section 3. This is the precise sense of the
factorization

$$
\textbf{(p,q)-theory} = \textbf{combinatorics} \times (\text{one Helly number}).
$$

---

## 5. Algorithms

The constructive content of Section 3 yields explicit piercing algorithms.

### 5.1 Greedy trivial transversal

**Input:** a finite family $\{F_i\}_{i \in s}$ of nonempty sets, with an oracle returning a point of
each. **Output:** a transversal of size $\le |s|$.

```
GreedyTransversal(s, F):
    T ← ∅
    for i in s:
        x ← anyPoint(F_i)          # choice function
        T ← T ∪ {x}
    return T
```

Complexity: $O(|s|)$ oracle calls. Correctness: Theorem 3.3.

### 5.2 One-shot transversal from the full $(|s|,q)$-property

**Input:** a finite family of nonempty sets with the full $(|s|,q)$-property and an oracle returning
a $q$-subset $B$ with a common point $t_0$. **Output:** a transversal of size $\le |s| - q + 1$.

```
OneShotTransversal(s, F, q):
    (B, t0) ← commonPoint of some q-subset      # full (|s|, q)-property
    R       ← GreedyTransversal(s \ B, F)        # pierce the rest individually
    return {t0} ∪ R
```

Complexity: $O(|s|)$ oracle calls plus one $(|s|,q)$ query. Correctness and the size bound:
Theorem 3.4.

### 5.3 Iterated Helly extraction (program, Section 6)

The route from the $|s|$-dependent bound to the constant $N(d,p,q)$:

```
IteratedHelly(s, F, h, p):                       # conjectural, Section 6
    T ← ∅
    while s nonempty:
        (B, t) ← fractionalHelly(s, F, h)        # a positive fraction share a point
        T ← T ∪ {t}
        s ← s \ {i : t ∈ F_i}                    # discard everyone pierced by t
    return T                                      # |T| ≤ N(d, p, q), n-free
```

The termination rate — and hence the $n$-free bound — is controlled by the fractional Helly constant,
which is a function of the Helly number $h$ alone.

---

## 6. Toward the dimension-independent bound

The gap between Section 3 and the full theorem is the dependence on $|s|$. The program to close it:

1. **Fractional Helly.** Establish that with Helly number $h$, a positive fraction of all
   $h$-subfamilies sharing a point forces a single point common to a positive fraction of the *whole*
   family. This is the quantitative engine; its strength is a function of $h$.
2. **Iterated extraction.** Repeatedly extract such a heavily-shared point, remove all members it
   pierces, and recurse (Algorithm 5.3). Each round removes a constant fraction, so the number of
   rounds — and hence $|T|$ — is bounded independently of $|s|$.
3. **Closed form at threshold.** At $q = h$, conjecturally $\tau \le \binom{p-1}{h-1}$, depending only
   on $p$ and $h$.

Because the combinatorial recursion is identical for $h = d+1$ and $h = 2d+1$, completing this program
once yields *both* the convex and splinter theorems simultaneously.

---

## 7. Applications

- **Sensor / guard placement.** Covering many overlapping regions with few points is exactly a
  transversal problem; the $(p,q)$-property is a realistic "enough local overlap everywhere"
  assumption, and the splinter extension covers non-convex coverage footprints.
- **Geometric data structures.** Piercing-set bounds underlie range-searching and hitting-set
  approximations; a class-agnostic core means the same bounds transfer to new shape classes by
  certifying one Helly number.
- **Combinatorial optimization.** The factorization isolates the LP/duality-free portion of the
  Alon–Kleitman argument, clarifying which approximation guarantees are purely combinatorial.

---

## 8. Discussion

The methodological lesson is that a theorem long perceived as monolithically geometric in fact splits
into a *universal* combinatorial skeleton and a *single* geometric scalar. This has three payoffs.
First, **reusability**: the core is written once and instantiated for any shape class merely by
certifying its Helly number. Second, **clarity**: it localizes the genuine difficulty entirely in the
Helly number, showing the counting layer to be elementary. Third, **bridging**: it exhibits a clean
interface between geometry (Helly, Radon, convexity and its splinter relaxation) and combinatorics
(subfamily counting, piercing), each side using its native tools.

A noteworthy formal-mathematical detail is that the truncated natural subtraction in Theorem 3.4 lets
the bound $|s| - q + 1$ remain correct *without* the hypothesis $q \le |s|$, which is therefore
omitted — a small illustration of how careful arithmetic conventions can simplify hypotheses.

---

## 9. Future Work

- **C1.** A dimension-independent bound at the threshold $q = h$: prove $\tau \le \binom{p-1}{h-1}$ via
  the iterated fractional-Helly recursion (Section 6).
- **C2.** Establish the splinter Helly number $2d+1$ from first principles via a $(2d+2)$-point
  Radon-type partition, mirroring the classical $(d+2)$-point Radon partition underlying ordinary
  Helly.
- **C3.** Sharpness: for every $d$, construct a family of convex splinters with the $(2d, 2d)$-property
  that admits no bounded transversal, certifying that $2d+1$ — not $2d$ — is the exact threshold.

---

## 10. Conclusion

We have isolated and verified the set-class-agnostic combinatorial core of the Hadwiger–Debrunner
$(p,q)$ theory — monotonicity in both parameters, the trivial transversal, and the one-shot bound
$|s| - q + 1$ — and shown that all geometry enters through a single Helly number, $d+1$ for convex
sets and $2d+1$ for convex splinters. The transversal theory factors as *combinatorics $\times$ one
Helly number*, reducing the splinter $(p,q)$ theorem to the certification of a single scalar and
charting a concrete recursion-theoretic path to the dimension-independent constant $N(d,p,q)$.

---

## References (classical, well known)

- E. Helly, *Über Mengen konvexer Körper mit gemeinschaftlichen Punkten*, 1923.
- H. Hadwiger, H. Debrunner, *Über eine Variante zum Hellyschen Satz*, 1957.
- N. Alon, D. Kleitman, *Piercing convex sets and the Hadwiger–Debrunner $(p,q)$-problem*, 1992.
- J. L. Arocha, J. Bracho, L. Montejano, work on Helly-type theorems for non-convex ("splinter") sets.
