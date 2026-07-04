# Escher Staircases and the Escher Height: A Graded Refinement of Noetherianity

## Abstract

We study *Escher staircases*: infinite strictly ascending chains of ideals
$I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq \cdots$ in a commutative ring
whose infimum $\bigwedge_n I_n$ equals the bottom rung $I_0$. Every ascending
chain automatically has this "loop-back" property — the meet of a rising tower
is its floor — so the existence of an Escher staircase is a purely
order-theoretic gadget capturing the failure of the ascending chain condition.
Our central structural result is a clean equivalence: **a commutative ring
admits an Escher staircase if and only if it is not Noetherian.** We then
exhibit two explicit families of staircases that loop back to the zero ideal —
the *tail-vanishing ideals* of the infinite product ring
$\mathbb{Z}^{\mathbb{N}}$, and the *variable ideals* of the polynomial ring
$k[x_0, x_1, x_2, \dots]$ in countably many variables — and one clean negative
instance, the $p$-adic integers $\mathbb{Z}_p$, a discrete valuation ring that
admits no staircase at all. For polynomial rings over a field we prove a sharp
finite/infinite dichotomy: finitely many variables admit no staircase (by the
Hilbert Basis Theorem), while countably many variables always do. This motivates
a new invariant, the **Escher height**, that refines the binary
Noetherian/non-Noetherian distinction into a graded scale measuring how far a
ring is from satisfying the ascending chain condition. We correct a natural but
erroneous first guess — the "$2^n$-divisibility" chain in the ring of
integer-valued polynomials is descending, not ascending — and close with
conjectures and a computational toolkit.

**Keywords:** ascending chain condition, Noetherian rings, ideal lattice,
Hilbert Basis Theorem, discrete valuation ring, integer-valued polynomials,
infinite-variable polynomial rings, ring invariants.

---

## 1. Introduction

The ascending chain condition (ACC) on ideals is one of the load-bearing
finiteness hypotheses of modern commutative algebra. A commutative ring $R$ is
**Noetherian** when every ascending chain of ideals
$I_0 \subseteq I_1 \subseteq \cdots$ eventually stabilizes; equivalently, every
ideal is finitely generated. Noetherianity underwrites primary decomposition,
dimension theory, and the good behavior of the Zariski topology, and by Hilbert's
Basis Theorem it is stable under adjoining finitely many polynomial variables.

Failure of ACC is usually treated as a binary defect: a ring is Noetherian or it
is not. This paper takes the failure itself as the object of study and gives it a
name evocative of its shape. An **Escher staircase** is an infinite strictly
ascending chain of ideals. The name comes from a paradox visible in every
concrete example we construct: the chain ascends forever, and yet the *infimum*
of the whole chain — the largest ideal contained in every rung — equals the
bottom rung $I_0$. Climbing forever, one returns to the start. This "impossible
architecture" is, of course, automatic: the meet of an ascending family is its
minimum. But rendered in explicit examples it becomes a genuinely climbable
structure, and (more importantly) counting the available staircases turns the
binary Noetherian question into a graded numerical invariant.

Our contributions are:

1. **The Staircase Criterion** (Theorem 3.1): $R$ admits an Escher staircase
   $\iff$ $R$ is not Noetherian.
2. **A concrete product staircase** (Section 4): the tail-vanishing ideals of
   $\mathbb{Z}^{\mathbb{N}}$ form a strictly ascending chain with infimum $\{0\}$,
   proving $\mathbb{Z}^{\mathbb{N}}$ non-Noetherian.
3. **A clean negative instance** (Section 5): the $p$-adic integers
   $\mathbb{Z}_p$, being a discrete valuation ring, admit no staircase.
4. **The polynomial dichotomy** (Section 6): $k[x_1,\dots,x_n]$ over a field has
   no staircase (Hilbert Basis Theorem), while $k[x_0, x_1, \dots]$ in countably
   many variables carries the explicit variable-ideal staircase, which also loops
   back to $\{0\}$.
5. **The Escher height** (Section 7): a proposed invariant refining
   Noetherianity, with conjectures relating it to the number of variables and to
   Krull dimension.

We also flag a subtle sign error that a natural first attempt invites (Section
6.4).

---

## 2. Definitions

Throughout, $R$ is a commutative ring with $1$, and $\mathrm{Id}(R)$ denotes its
lattice of ideals, ordered by inclusion, with meet $\bigwedge$ (intersection)
and join $\bigvee$ (ideal sum).

**Definition 2.1 (Escher staircase).** An *Escher staircase* in $R$ is a
strictly monotone sequence of ideals, i.e. a map $I : \mathbb{N} \to
\mathrm{Id}(R)$ with $I_m \subsetneq I_n$ whenever $m < n$. Equivalently,
$I_n \subsetneq I_{n+1}$ for all $n$. We say $R$ *admits an Escher staircase*
when such a sequence exists.

**Definition 2.2 (Loop-back).** A staircase $I$ *loops back* to its bottom rung
if $\bigwedge_n I_n = I_0$. For an ascending chain this holds automatically,
since $I_0 \subseteq I_n$ for all $n$ forces $I_0 \subseteq \bigwedge_n I_n
\subseteq I_0$. The loop-back is called *to zero* when moreover $I_0 = \{0\}$;
this is the "impossible architecture" picture in which the whole ascending tower
meets in the single zero element.

**Definition 2.3 (Noetherian).** $R$ is *Noetherian* if every ascending chain of
ideals stabilizes, equivalently if the relation $\supsetneq$ on $\mathrm{Id}(R)$
is well-founded, equivalently if every ideal is finitely generated.

**Definition 2.4 (Escher height, informal).** The *Escher height* of $R$ is the
supremum, over all strictly ascending chains of ideals, of the chain's length
(as an ordinal). A ring with no staircase has Escher height $0$; a ring with an
infinite staircase has Escher height at least $\omega$. Section 7 discusses this
invariant and its conjectural values.

---

## 3. The Staircase Criterion

**Theorem 3.1 (Staircase Criterion).** A commutative ring $R$ admits an Escher
staircase if and only if $R$ is not Noetherian.

*Proof sketch.* Noetherianity of $R$ is, by definition, well-foundedness of the
strict-superset relation $\supsetneq$ on $\mathrm{Id}(R)$ — that is, of the order
$>$ on ideals. Unwinding:

($\Rightarrow$) Suppose $R$ is Noetherian yet a staircase $I : \mathbb{N} \to
\mathrm{Id}(R)$ exists. Then $I$ is strictly monotone increasing, so
$n \mapsto I_n$ is an infinite strictly *increasing* sequence, contradicting the
well-foundedness of $>$ (a well-founded order admits no strictly increasing
$\omega$-sequence viewed through the reversed relation). Concretely, no strictly
monotone function into a ring's ideal lattice can exist when that lattice has the
ascending chain condition.

($\Leftarrow$) Suppose $R$ is not Noetherian, so $>$ on $\mathrm{Id}(R)$ is not
well-founded. Non-well-foundedness yields an order embedding of
$(\mathbb{N}, <)$ into $(\mathrm{Id}(R), <)$; its underlying function is exactly
a strictly monotone sequence of ideals, i.e. an Escher staircase.

The equivalence therefore reduces to the standard order-theoretic fact that a
partial order satisfies the ascending chain condition if and only if it admits
no strictly increasing $\omega$-chain. $\qquad\blacksquare$

Theorem 3.1 is the hinge of the paper. It lets us prove *non-Noetherianity* by
*constructing a staircase* (Sections 4, 6) and prove *no staircase exists* by
*invoking Noetherianity* (Sections 5, 6).

---

## 4. The product staircase in $\mathbb{Z}^{\mathbb{N}}$

Let $R = \mathbb{Z}^{\mathbb{N}}$ be the ring of integer sequences
$f = (f_0, f_1, \dots)$ under coordinatewise addition and multiplication. This is
the prototypical non-Noetherian ring, and it carries a fully explicit loop-back
staircase.

**Definition 4.1 (Tail-vanishing ideals).** For $n \in \mathbb{N}$ let
$$
S_n = \{\, f \in \mathbb{Z}^{\mathbb{N}} : f_k = 0 \text{ for all } k \ge n \,\}.
$$

**Lemma 4.2.** Each $S_n$ is an ideal.

*Proof sketch.* $0 \in S_n$; if $f, g$ vanish past $n$ so does $f + g$; and for
any $c \in R$, $(cf)_k = c_k f_k = 0$ for $k \ge n$, so $cf \in S_n$. $\square$

**Lemma 4.3 (Monotone).** $S_m \subseteq S_n$ whenever $m \le n$: vanishing past
$m$ implies vanishing past $n \ge m$. $\square$

**Lemma 4.4 (Strictness).** $S_n \subsetneq S_{n+1}$ for every $n$.

*Proof sketch.* Let $e_n = \mathrm{Pi.single}\,n\,1$ be the "spike" sequence
equal to $1$ at index $n$ and $0$ elsewhere. For $k \ge n+1$ we have $k \ne n$,
so $(e_n)_k = 0$; hence $e_n \in S_{n+1}$. But $(e_n)_n = 1 \ne 0$, so
$e_n \notin S_n$. The spike separates the two rungs. $\square$

**Theorem 4.5.** $S : \mathbb{N} \to \mathrm{Id}(\mathbb{Z}^{\mathbb{N}})$ is an
Escher staircase. Consequently $\mathbb{Z}^{\mathbb{N}}$ is not Noetherian.

*Proof sketch.* By Lemma 4.4 and the "strictly monotone from
$I_n < I_{n+1}$" principle, $S$ is strictly monotone; this is a staircase, and
Theorem 3.1 delivers non-Noetherianity. $\square$

**Theorem 4.6 (Loop-back to zero).** $S_0 = \{0\}$ and
$\bigwedge_n S_n = \{0\} = S_0$.

*Proof sketch.* Membership $f \in S_0$ requires $f_k = 0$ for all $k \ge 0$, i.e.
$f = 0$; hence $S_0 = \{0\}$. Then $\bigwedge_n S_n \subseteq S_0 = \{0\}$, and
$\{0\} \subseteq \bigwedge_n S_n$ trivially, giving equality. $\square$

Theorem 4.6 realizes the impossible-architecture picture: the chain ascends
strictly and forever, yet the meet of every rung is precisely the bottom rung
$\{0\}$, the single zero sequence, which lies inside every $S_n$.

---

## 5. The negative instance: $p$-adic integers

**Theorem 5.1.** For a prime $p$, the ring $\mathbb{Z}_p$ of $p$-adic integers
admits no Escher staircase.

*Proof sketch.* $\mathbb{Z}_p$ is a discrete valuation ring: a local principal
ideal domain whose nonzero ideals are exactly the powers $(p^k)$ of its maximal
ideal, totally ordered as
$\mathbb{Z}_p \supsetneq (p) \supsetneq (p^2) \supsetneq \cdots$. Being a
principal ideal domain, $\mathbb{Z}_p$ is Noetherian. By Theorem 3.1, a
non-Noetherian ring is required for a staircase to exist; since $\mathbb{Z}_p$ is
Noetherian, it has none. $\square$

The contrast with Section 4 is the crux: $\mathbb{Z}^{\mathbb{N}}$ and
$\mathbb{Z}_p$ are both built from $\mathbb{Z}$, but the infinite *product*
manufactures unboundedly many independent directions of ideal growth, while the
$p$-adic *completion* collapses them onto a single well-ordered ladder.

---

## 6. The polynomial dichotomy

We now calibrate the invariant on polynomial rings over a field $k$, where the
number of variables governs everything.

### 6.1 Finitely many variables: no staircase

**Theorem 6.1.** For every $n \in \mathbb{N}$, the ring $k[x_0, \dots, x_{n-1}]$
of polynomials in finitely many variables over a field admits no Escher
staircase.

*Proof sketch.* A field is Noetherian, and by the Hilbert Basis Theorem the
polynomial ring over a Noetherian ring in one — hence, by induction, in finitely
many — variables is again Noetherian. By Theorem 3.1 there is no staircase. The
case $n = 0$ gives the field $k$ itself, still Noetherian, still without a
staircase, so the statement holds uniformly. $\square$

**Corollary 6.2.** The single-variable ring $k[x]$, a principal ideal domain and
hence Noetherian, admits no Escher staircase.

### 6.2 Countably many variables: an explicit staircase

Let $k[x_0, x_1, x_2, \dots]$ denote the polynomial ring in a countably infinite
family of variables indexed by $\mathbb{N}$. For a finite subset
$s \subseteq \mathbb{N}$ write $\langle x_i : i \in s \rangle$ for the ideal it
generates.

**Definition 6.3 (Variable ideals).** For $n \in \mathbb{N}$ let
$$
V_n = \langle x_0, x_1, \dots, x_{n-1} \rangle,
$$
so $V_0 = \langle \varnothing \rangle = \{0\}$, $V_1 = \langle x_0 \rangle$,
$V_2 = \langle x_0, x_1 \rangle$, and so on.

The strictness of this chain rests on a single, sharply stated non-membership
fact, which is the only genuinely ring-theoretic (as opposed to order-theoretic)
input of the construction.

**Lemma 6.4 (Missing variable).** Let $s \subseteq \mathbb{N}$ be a set of
indices and $j \notin s$. Then
$$
x_j \notin \langle x_i : i \in s \rangle.
$$

*Proof sketch.* Consider the algebra endomorphism
$\varphi_s : k[x_0, x_1, \dots] \to k[x_0, x_1, \dots]$ determined on generators
by
$$
\varphi_s(x_i) = \begin{cases} 0 & i \in s, \\ x_i & i \notin s. \end{cases}
$$
This is a well-defined ring homomorphism (it is evaluation/substitution). It
sends every generator $x_i$ ($i \in s$) of the ideal $\langle x_i : i \in s
\rangle$ to $0$, so the whole ideal lies in $\ker \varphi_s$. If $x_j$ belonged
to that ideal we would have $x_j = \varphi_s(x_j) = x_j$ mapping to $0$, i.e.
$x_j = 0$ in the target — contradicting that a variable is a nonzero element of a
polynomial ring over a nontrivial base. Hence $x_j \notin \langle x_i : i \in s
\rangle$. $\square$

This "evaluate to detect a missing generator" argument is the same mechanism
that powers standard non-Noetherian counterexamples for infinite variable
counts.

**Theorem 6.5.** The variable ideals $V_n$ form an Escher staircase in
$k[x_0, x_1, \dots]$; consequently the ring is not Noetherian.

*Proof sketch.* Monotonicity is clear since $V_n$ is generated by a subset of
the generators of $V_{n+1}$. For strictness, $x_n \in V_{n+1}$ by definition,
while $x_n \notin V_n = \langle x_0, \dots, x_{n-1}\rangle$ by Lemma 6.4 (taking
$s = \{0,\dots,n-1\}$, $j = n \notin s$). Thus $V_n \subsetneq V_{n+1}$ for all
$n$, giving a strictly monotone chain. Theorem 3.1 yields non-Noetherianity.
$\square$

**Theorem 6.6 (Loop-back to zero).** $V_0 = \{0\}$ and $\bigwedge_n V_n = \{0\}$.

*Proof sketch.* $V_0$ is generated by the empty set, hence is $\{0\}$. As with
any ascending chain, $\bigwedge_n V_n \subseteq V_0 = \{0\}$, and the reverse
inclusion is trivial. $\square$

### 6.3 The sharp dichotomy

**Theorem 6.7 (Escher dichotomy).** For polynomial rings over a field $k$:
finitely many variables admit **no** Escher staircase, while countably many
variables **do**. Precisely, for every $n$ the ring $k[x_0, \dots, x_{n-1}]$ has
no staircase, whereas $k[x_0, x_1, \dots]$ has the variable-ideal staircase.

*Proof sketch.* Combine Theorem 6.1 (finite case, Hilbert Basis) with Theorem
6.5 (countable case, explicit staircase). $\square$

This is the precise sense in which the "Escher height" of a polynomial ring over
a field tracks the number of variables: it is $0$ in the finite case and
positive (indeed infinite) in the infinite case.

### 6.4 A cautionary sign error

The ring $\mathrm{Int}(\mathbb{Z}) = \{ f \in \mathbb{Q}[x] : f(\mathbb{Z})
\subseteq \mathbb{Z}\}$ of integer-valued polynomials is a classical
non-Noetherian ring, and it is tempting to propose the family
$$
I_n = \{\, f \in \mathrm{Int}(\mathbb{Z}) : f(\mathbb{Z}) \subseteq 2^n\mathbb{Z}
\,\}
$$
as an Escher staircase. **This is wrong.** Because $2^{n+1}\mathbb{Z} \subseteq
2^n\mathbb{Z}$, a polynomial whose values are all divisible by $2^{n+1}$ is a
fortiori divisible by $2^n$, so $I_{n+1} \subseteq I_n$: the chain *descends*.
A descending chain is not a staircase (Definition 2.1 requires strict *ascent*),
and its intersection is a legitimate but different phenomenon. This inclusion is
easy to reverse by inattention, and it underscores that the direction of the
arrows is the entire content of the definition. Genuine infinite-height witnesses
for $\mathrm{Int}(\mathbb{Z})$ do exist (it is non-Noetherian, so Theorem 3.1
guarantees one), but they must be constructed with strictly *growing* rungs.

---

## 7. The Escher height invariant

Theorem 6.7 suggests upgrading the binary Noetherian/non-Noetherian question to a
graded scale.

**Definition 7.1 (Escher height).** The *Escher height* $h(R)$ of a commutative
ring is the supremum, over all strictly ascending chains of ideals, of the order
type (length) of the chain. Equivalently it is the height of the ideal poset
under the ascending chain filtration. A Noetherian ring has $h(R) = 0$ in the
sense that no infinite strictly ascending chain exists; a non-Noetherian ring has
$h(R) \ge \omega$.

The invariant is meant to answer *how badly* ACC fails, not merely *whether* it
fails, and to do so along independent directions of ideal growth. The
calculations above provide anchoring data points:

- $h(k[x_1, \dots, x_n]) = 0$ (no staircase) for every finite $n$.
- $h(k[x_0, x_1, \dots]) \ge \omega$ (the variable staircase).
- $h(\mathbb{Z}^{\mathbb{N}}) \ge \omega$ (the tail-vanishing staircase).
- $h(\mathbb{Z}_p) = 0$.

**Conjecture 7.2 (Variable-count law).** For a polynomial ring over a field, the
Escher height equals the number of variables when that number is finite (namely
$0$, matching the absence of a staircase) and is infinite exactly when the
variable set is infinite. More refined gradings should recover the Krull
dimension in the finite case, positioning the Escher height as a non-Noetherian
extension of dimension theory.

**Conjecture 7.3 (Universality).** Every non-Noetherian ring contains an Escher
staircase (this direction is Theorem 3.1) and the *shape* of the invariant —
finite ordinal, $\omega$, or larger — is a genuine isomorphism invariant that
distinguishes non-Noetherian rings that the Noetherian/non-Noetherian dichotomy
cannot.

---

## 8. Algorithms and computation

While the invariant concerns infinite objects, several finite computations
illuminate and test it. We summarize three; full implementations accompany this
work.

**Algorithm A (Staircase strictness verifier).** Given a family of finitely
supported ideals (e.g. tail-vanishing ideals of $\mathbb{Z}^{\mathbb{N}}$
truncated to length $N$, or variable ideals truncated to $N$ variables), verify
$I_n \subsetneq I_{n+1}$ by exhibiting, at each level, a separating witness
(the spike $e_n$ or the variable $x_n$) and checking membership on both sides.
Complexity is linear in $N$ times the cost of a single membership test.

**Algorithm B (Variable-ideal membership via evaluation).** To decide whether a
polynomial $f$ lies in $\langle x_i : i \in s\rangle$, apply the substitution
$\varphi_s$ setting $x_i = 0$ for $i \in s$ and check whether the result is $0$;
for the generated-by-variables ideals this is a complete test, and it is exactly
the mechanism of Lemma 6.4. Complexity is linear in the number of monomials of
$f$.

**Algorithm C (Escher-height estimator for polynomial rings).** Given a variable
count (finite $n$ or the symbol $\infty$), return $0$ when finite (Hilbert Basis
Theorem: no staircase) and a certificate staircase $V_0 \subsetneq \cdots
\subsetneq V_N$ up to any requested depth $N$ when infinite. This operationalizes
the dichotomy of Theorem 6.7.

---

## 9. Applications and context

Non-Noetherian rings are pervasive at the boundaries of commutative algebra:
rings of continuous or integer-valued functions, infinite-variable polynomial
and power-series rings arising in the study of symmetric functions and
representation stability, valuation rings of infinite rank, and the ring of all
algebraic integers $\overline{\mathbb{Z}}$ (which is non-Noetherian and hence, by
Theorem 3.1, must contain an Escher staircase). In each such setting the
Noetherian/non-Noetherian switch is too coarse to compare rings. The Escher
height offers a candidate ruler: it distinguishes a ring that fails ACC in one
"direction" from one that fails it in infinitely many, and — via Conjecture 7.2 —
promises to interpolate between Krull dimension in the tame regime and a genuinely
new invariant in the wild regime.

---

## 10. Future directions

**A quantitative Escher height from bounded chains.** Define the Escher height as
the supremum over strictly ascending chains of the chain length, and study when
it is finite, infinite, or a prescribed ordinal. Conjecture: for a polynomial
ring over a field the Escher height equals the number of variables when finite
and is infinite exactly when the variable set is infinite. An ascending chain is
the order-theoretic shadow of a ring's ACC failure, so the *longest* such chain
refines the binary distinction into a graded scale; the explicit variable-ideal
chain gives a computable lower bound to calibrate against Krull dimension.

**Escher staircases that meet at a prescribed ideal.** A staircase loops back
when the infimum of the chain equals its bottom rung. Ask which ideals $J$ can
arise as $\bigwedge_n I_n$ for a strictly ascending chain with $I_0 = J$, and
characterize the rings in which every ascending chain loops back versus those
admitting chains whose infimum strictly exceeds the bottom rung. Two independent
loop-back witnesses (tail-vanishing ideals of an infinite product and variable
ideals of an infinite-variable polynomial ring), both with infimum $\{0\}$,
invite a structural explanation.

**Transfer of Escher staircases along ring maps.** Study staircases under
quotients, localizations, polynomial and power-series extensions, and finite
products. Conjecture: a ring admits an Escher staircase iff some finitely
generated subalgebra does not, and the property is inherited by faithfully flat
extensions. Since non-Noetherianity is detected by a single countable chain,
transfer reduces to tracking one sequence of ideals through the functor.

**Escher height of integer-valued and related function rings.** Rings of
integer-valued polynomials and their relatives are classical sources of
non-Noetherian behavior; determine their Escher height and exhibit an explicit
strictly ascending chain realizing it, taking care (Section 6.4) that the chain
genuinely ascends.

---

## 11. Conclusion

An Escher staircase — an infinite strictly ascending chain of ideals looping back
to its own floor — is a faithful, evocative name for the failure of the ascending
chain condition. The Staircase Criterion pins the phenomenon exactly to
non-Noetherianity; the product and polynomial constructions render it as concrete,
loop-back architecture with infimum $\{0\}$; the $p$-adic integers show where it
is impossible; and the finite/infinite polynomial dichotomy calibrates the
proposed Escher height, a graded invariant measuring how far a ring stands from
Noetherian. What began as a visual paradox becomes a quantitative program for the
untamed frontier of commutative algebra.
