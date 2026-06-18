# Divisibility Bridges: Fibonacci Lattices, a Sharp Divisibility Pigeonhole, and a Finite Garden-of-Eden Principle

**Author:** Aristotle
**Date:** 2026-06-18
**Domain:** Bridges (Number Theory ↔ Combinatorics ↔ Finite Dynamics)

---

## Abstract

We present a self-contained development of three structurally linked results,
each formally verified. First, we record the classical *Fibonacci divisibility
law* $m \mid n \Rightarrow F_m \mid F_n$ and upgrade it, for indices $m \ge 3$,
to a full equivalence $F_m \mid F_n \iff m \mid n$, exhibiting the Fibonacci
sequence as a faithful embedding of the divisibility order of $\mathbb{N}$ into
itself. Second, using the $2$-adic *odd-part* decomposition of integers as a
pigeonhole coloring, we prove the sharp combinatorial theorem that any
$n+1$-element subset of $\{1, \dots, 2n\}$ contains a divisibility pair. Third,
we develop a finite *Garden-of-Eden* theory: a state of a self-map $F$ is a
Garden of Eden when it has no preimage, and we prove (i) Gardens of Eden exist
iff $F$ is not surjective, (ii) iterates of an order-descending map form a
descending chain, (iii) every orbit of a monotone descending map on a finite
poset of cardinality $N$ stabilizes within $N$ steps, and (iv) the resulting
finite Moore–Myhill shadow whereby surjectivity forces injectivity on finite
state spaces. The unifying theme is that *structure-preserving maps are governed
by the structure they preserve*: divisibility, multiplicative valuation, and
order respectively dictate the behaviour of the three maps.

---

## 1. Introduction

A recurring motif across number theory, combinatorics, and dynamics is that a
map which *respects* an algebraic or order structure has its global behaviour
forced by that structure, often without any explicit computation. This paper
collects three concrete incarnations of the motif and makes the bridges between
them explicit.

The thread connecting the three parts is the interaction between a map and an
invariant:

1. The Fibonacci map $n \mapsto F_n$ respects divisibility; its arithmetic is
   therefore an exact copy of the arithmetic of indices.
2. The odd-part map $x \mapsto \operatorname{oddPart}(x)$ records the
   multiplicative valuation $v_2$; using it as a pigeonhole color extracts a
   sharp extremal bound.
3. An order-descending self-map on a finite poset respects $\le$; finiteness
   then forces stabilization, and the failure of surjectivity forces the
   existence of permanently unreachable states.

All statements below are quoted in their formalized form and accompanied by
proof sketches faithful to the verified proofs.

### Notation

$\mathbb{N}$ denotes the non-negative integers. $F_n$ denotes the $n$-th
Fibonacci number with $F_1 = F_2 = 1$ (so $F_0 = 0$, $F_3 = 2$, $F_4 = 3$,
$F_5 = 5$). For a function $F : \alpha \to \alpha$, $F^{[n]}$ denotes its $n$-fold
iterate, with $F^{[0]} = \mathrm{id}$. For $x \in \mathbb{N}$, $v_2(x)$ is the
exponent of $2$ in the prime factorization of $x$. We write $[a,b]$ for the
integer interval $\{a, a+1, \dots, b\}$ (the formal `Finset.Icc a b`).

---

## 2. Fibonacci divisibility lattice

### Theorem 1 (`fib_dvd_of_dvd`)

*If $m \mid n$ then $F_m \mid F_n$.*

**Sketch.** This is the divisibility direction of the classical theory and is a
direct consequence of the Mathlib fact `Nat.fib_dvd`. Conceptually it follows
from the matrix/addition formula
$F_{a+b} = F_{a+1}F_b + F_a F_{b-1}$,
which shows $F_a \mid F_{ka}$ by induction on $k$: each increment by $a$ adds a
multiple of $F_a$. $\square$

### Theorem 2 (`fib_dvd_iff`)

*For $m \ge 3$,*
$$F_m \mid F_n \iff m \mid n.$$

**Sketch.** The reverse implication is Theorem 1. For the forward implication the
engine is the gcd identity
$$\gcd(F_m, F_n) = F_{\gcd(m,n)},$$
formalized via `Nat.fib_gcd`. Suppose $F_m \mid F_n$. Then
$\gcd(F_m, F_n) = F_m$, so $F_{\gcd(m,n)} = F_m$.

We argue by contradiction that $m \mid n$. If $m \nmid n$, then
$g := \gcd(m,n)$ is a proper divisor of $m$, hence $g < m$ (it divides $m$ and is
not equal to $m$). Since $m \ge 3$, strict monotonicity of the Fibonacci sequence
on indices $\ge 2$ — together with a small finite check for the cases
$g \in \{0,1\}$, where $F_g \le 1 < 2 \le F_m$ — gives $F_g < F_m$. But we also
derived $F_g = F_{\gcd(m,n)} = F_m$, a contradiction. Therefore $m \mid n$.

The hypothesis $m \ge 3$ is necessary and sharp: $F_1 = F_2 = 1$ divide every
$F_n$, so the equivalence fails for $m \in \{1,2\}$. $\square$

**Remark.** Theorem 2 says the position-indexed map $n \mapsto F_n$ is an order
embedding of $(\mathbb{N}_{\ge 3}, \mid)$ into $(\mathbb{N}, \mid)$: it not only
preserves divisibility but reflects it. The divisibility lattice of indices is
recovered exactly inside the Fibonacci values.

---

## 3. A sharp divisibility pigeonhole

### Definition 3 (`oddPart`)

For $x \in \mathbb{N}$,
$$\operatorname{oddPart}(x) := \frac{x}{2^{v_2(x)}},$$
the odd part obtained by dividing out every factor of $2$. Equivalently, $x$
factors uniquely as $\operatorname{oddPart}(x)\cdot 2^{v_2(x)}$ with
$\operatorname{oddPart}(x)$ odd (for $x \ge 1$).

### Theorem 4 (`divisibility_pigeonhole`)

*Let $n \ge 1$ and let $S \subseteq [1, 2n]$ be a set of integers with
$|S| = n+1$. Then there exist $a, b \in S$ with $a \ne b$ and $a \mid b$.*

**Sketch.** Color each element $x \in S$ by its odd part
$\operatorname{oddPart}(x)$. Two facts pin down the color set:

1. For $1 \le x \le 2n$, $\operatorname{oddPart}(x)$ is odd and lies in
   $[1, 2n]$ (dividing by a positive power of $2$ only decreases $x$). Hence the
   colors land among the odd numbers $\{1, 3, 5, \dots, 2n-1\}$.
2. There are exactly $n$ such odd numbers, realized as
   $\{2k+1 : 0 \le k < n\}$.

Therefore the image $\operatorname{oddPart}(S)$ has at most $n$ elements, while
$|S| = n+1$. By the pigeonhole principle (`Finset.card_image_of_injOn`,
contrapositive), the map $x \mapsto \operatorname{oddPart}(x)$ is **not**
injective on $S$: there are $a \ne b$ in $S$ with
$\operatorname{oddPart}(a) = \operatorname{oddPart}(b) =: q$.

Write $a = q\cdot 2^{i}$ and $b = q\cdot 2^{j}$ (using
$x = \operatorname{oddPart}(x)\cdot 2^{v_2(x)}$, valid because
$2^{v_2(x)} \mid x$). Without loss of generality $i \le j$ (otherwise swap $a$
and $b$, which only swaps the roles in the conclusion). Then
$$b = q\cdot 2^{j} = (q\cdot 2^{i})\cdot 2^{\,j-i} = a\cdot 2^{\,j-i},$$
so $a \mid b$. $\square$

**Sharpness.** The bound $n+1$ is optimal: the $n$-element set
$\{n+1, n+2, \dots, 2n\}$ contains no divisibility pair, since for distinct
$a < b$ in this range $b < 2a$, ruling out $a \mid b$.

**Remark on hypotheses.** The hypothesis $n \ge 1$ is retained because it was
part of the requested statement, but the formal proof does not use it (the case
$n = 0$ is vacuous since $|S| = 1$ cannot be a subset of $[1,0] = \varnothing$
with $|S| = 1$). The decisive structural input is Definition 3, shared with the
Fibonacci development through the common arithmetic of valuations.

---

## 4. A finite Garden-of-Eden theory

We now move to dynamics. Throughout, $F : \alpha \to \alpha$ is a self-map and
$F^{[n]}$ its $n$-fold iterate.

### Definition 5 (`IsGardenOfEden`)

A state $y \in \alpha$ is a **Garden of Eden** for $F$ if it has no preimage:
$$\operatorname{IsGardenOfEden}(F, y) :\iff \forall x,\ F(x) \ne y.$$
Such a state can be an initial configuration but is never produced by one tick
of the dynamics.

### Theorem 6 (`exists_garden_of_eden_iff_not_surjective`)

$$(\exists\,y,\ \operatorname{IsGardenOfEden}(F, y)) \iff \neg\,\operatorname{Surjective}(F).$$

**Sketch.** Unfolding both sides, "$\exists y\, \forall x,\ F(x) \ne y$" is the
literal negation of surjectivity "$\forall y\, \exists x,\ F(x) = y$." The
equivalence is therefore a propositional simplification (`simp` on the
definitions). Despite its triviality it is the conceptual hinge: it identifies
the existence of unreachable states precisely with loss of surjectivity. $\square$

### Lemma 7 (`iterate_descends`)

*Let $(P, \le)$ be a partial order and $F : P \to P$ satisfy $F(x) \le x$ for all
$x$ ("descending"). Then for all $n$ and $x$,*
$$F^{[n+1]}(x) \le F^{[n]}(x).$$

**Sketch.** Rewrite $F^{[n+1]}(x) = F(F^{[n]}(x))$ via
`Function.iterate_succ_apply'` and apply the descent hypothesis at the point
$F^{[n]}(x)$. $\square$

### Theorem 8 (`finite_garden_of_eden_descent`) — Finite Descent Principle

*Let $(P, \le)$ be a finite partial order with $N := |P|$, and let
$F : P \to P$ be monotone with $F(x) \le x$ for all $x$. Then for every
$x \in P$ there exists $n \le N$ with*
$$F^{[n]}(x) = F^{[n+1]}(x).$$
*That is, every orbit reaches a fixed point of $F$ within $N$ steps.*

**Sketch.** Fix $x$ and suppose, for contradiction, that
$F^{[n]}(x) \ne F^{[n+1]}(x)$ for all $n \le N$. By Lemma 7 the orbit is weakly
descending; combined with the assumption that no consecutive pair is equal, it is
**strictly** descending on $\{0, 1, \dots, N\}$:
$$F^{[N]}(x) < F^{[N-1]}(x) < \dots < F^{[1]}(x) < F^{[0]}(x) = x.$$
Concretely, monotonicity propagates a strict drop forward — once
$F^{[m]}(x) < F^{[m+1]}(x)$ fails to be equality and the chain is descending, all
later iterates stay strictly below earlier ones, so the map
$k \mapsto F^{[k]}(x)$ is injective on $\{0, \dots, N\}$ (formally via
`Finset.card_image_of_injOn`). This produces $N+1$ distinct elements of $P$,
contradicting $|P| = N$. Hence some consecutive pair coincides with index
$n \le N$, and at that point $F^{[n]}(x)$ is a fixed point. $\square$

**Quantitative content.** The cardinality $N$ is a hard, structure-derived
deadline: change in a finite descending system cannot persist longer than the
number of states. This is the order-theoretic analogue of "a strictly decreasing
sequence of naturals terminates," localized to a finite poset with an explicit
bound.

### Theorem 9 (`finite_garden_of_eden_of_not_surjective`)

*A non-surjective monotone descending map on a finite partial order has a Garden
of Eden lying outside its eventual image* — a state that is permanently
unreachable under iteration.

**Sketch.** By Theorem 6 non-surjectivity yields a Garden-of-Eden state $y$
(no preimage under one step). The eventual image $\bigcap_n F^{[n]}(P)$ is
reached after finitely many steps on a finite set (the images form a descending
chain of finite sets and stabilize). Combining stabilization (Theorem 8 at the
level of the whole space) with the absence of a one-step preimage places a
witnessing Garden-of-Eden state outside the eventual image, so it is not produced
by any positive number of iterations. $\square$

### Theorem 10 (`finite_configuration_garden_of_eden`)

*On a finite configuration space, every non-surjective map possesses a
configuration that is never reachable as an output.*

**Sketch.** A specialization of Theorem 6 / Theorem 9 to configuration spaces
(finite function spaces over a finite alphabet and finite index set), where the
existence of a Garden-of-Eden configuration is the direct witness of
non-surjectivity. $\square$

### Theorem 11 (`preinjective_of_surjective_on_finite_configurations`)

*Finite Moore–Myhill shadow:* *on a finite type, surjectivity of $F$ implies
injectivity of $F$.*

**Sketch.** For a self-map of a finite set, surjective $\Leftrightarrow$
injective $\Leftrightarrow$ bijective (`Finite.injective_iff_surjective`). Thus
surjectivity forces injectivity. This is the finite, elementary shadow of the
Moore–Myhill Garden-of-Eden theorem for cellular automata, where surjectivity
is equivalent to *pre-injectivity*; here the finiteness collapses pre-injectivity
to genuine injectivity. $\square$

---

## 5. Algorithms

The theorems are constructive enough to yield decision procedures.

### Algorithm A — Fibonacci divisibility oracle via index arithmetic

To decide $F_m \mid F_n$ for $m \ge 3$ **without** computing $F_n$: by Theorem 2
it suffices to test $m \mid n$. This replaces an exponential-size computation
($F_n$ has $\Theta(n)$ digits) by a single $O(\log n)$ modular reduction.

```
function fib_divides(m, n):
    require m >= 3
    return (n mod m == 0)        # equals (F_m | F_n) by Theorem 2
```

### Algorithm B — Constructive divisibility pair extraction

Given $S \subseteq [1,2n]$ with $|S| = n+1$, produce a witnessing pair
$a \mid b$ in $O(|S|)$ time using the odd-part coloring of Theorem 4.

```
function find_divisibility_pair(S):
    seen := empty map (odd part -> element)
    for x in S:
        q := oddPart(x)               # divide out all factors of 2
        if q in seen:
            a, b := sort(seen[q], x)  # smaller 2-adic exponent divides larger
            return (a, b)             # a | b
        seen[q] := x
    # unreachable when |S| = n+1 and S ⊆ [1,2n]
```

### Algorithm C — Bounded orbit stabilization detector

For a monotone descending $F$ on a finite poset of size $N$, iterate from $x$ and
detect the fixed point; Theorem 8 guarantees termination within $N$ steps.

```
function stabilize(F, x, N):
    cur := x
    for n in 0 .. N:
        nxt := F(cur)
        if nxt == cur: return (n, cur)   # fixed point reached
        cur := nxt
    # unreachable by Theorem 8
```

---

## 5b. Worked examples

The following concrete instances make the abstract statements tangible and serve
as regression checks for any implementation of the algorithms above.

**Fibonacci dictionary at $n = 12$.** With $F_{12} = 144$, the Fibonacci numbers
among its divisors are $F_3 = 2$, $F_4 = 3$, $F_6 = 8$, $F_{12} = 144$ (together
with the degenerate $F_1 = F_2 = 1$ excluded by the $m \ge 3$ hypothesis). The
indices $\{3,4,6,12\}$ are exactly the divisors of $12$ that are $\ge 3$,
illustrating Theorem 2 in full: divisibility among values mirrors divisibility
among indices. A larger instance: $F_{15} = 610 = 2 \cdot 5 \cdot 61$ is divisible
by $F_3 = 2$ and $F_5 = 5$ (since $3 \mid 15$ and $5 \mid 15$) but not by
$F_4 = 3$, $F_6 = 8$, or $F_9 = 34$ (since $4,6,9 \nmid 15$), exactly as predicted.

**Pigeonhole at $n = 4$.** The range is $[1,8]$ and we select $5$ numbers. The
odd-part coloring assigns $\operatorname{oddPart}$ values from $\{1,3,5,7\}$
(four chains: $1\!-\!2\!-\!4\!-\!8$, $3\!-\!6$, $5$, $7$). Any $5$ choices repeat
a chain; e.g. $\{3,4,5,7,8\}$ repeats chain $1$ via $4$ and $8$, giving
$4 \mid 8$. The $4$-element extremal set $\{5,6,7,8\}$ hits each chain at most
once and has no divisibility pair, witnessing the sharpness of the $n+1$
threshold.

**Descent at $N = 8$.** Take $P = \{0,\dots,7\}$ with the usual order and
$F(x) = \max(x-1, 0)$. This $F$ is monotone and descending. From the top state
$7$ the orbit is $7 \to 6 \to \dots \to 0$, reaching the fixed point $0$ in $7$
steps $\le N$, matching Theorem 8. The image is $\{0,\dots,6\}$, so $F$ is not
surjective and (by Theorem 6) the state $7$ is a Garden of Eden: no $x$ has
$F(x) = 7$. Replacing $F$ by the identity makes it bijective, with no Garden of
Eden and injectivity guaranteed by Theorem 11.

## 6. Applications and connections

- **Number theory.** Theorem 2 turns divisibility queries among Fibonacci
  numbers (and, by the same gcd mechanism, among many Lucas sequences) into
  index arithmetic, the foundation of fast primality and factorization heuristics
  built on the rank of apparition.
- **Extremal combinatorics.** Theorem 4 is the prototypical "chain in a divisor
  poset" argument (Erdős): the odd-part coloring partitions $[1,2n]$ into $n$
  chains under divisibility, and Dilworth/pigeonhole forces a repeat. The result
  is sharp, with extremal family $\{n+1, \dots, 2n\}$.
- **Dynamics and computation.** Theorems 6–11 give a finite, fully explicit
  Garden-of-Eden theory: a clean criterion for unreachable states, a tight
  termination bound for monotone descending dynamics (relevant to greedy
  optimizers, relaxation labelings, and confluent rewriting), and a finite shadow
  of the Moore–Myhill theorem linking surjectivity and injectivity.

---

## 7. Discussion

The three developments share a single design principle: identify the invariant a
map preserves, then read the conclusion off the invariant. For Fibonacci numbers
the invariant is divisibility, captured by $\gcd(F_m, F_n) = F_{\gcd(m,n)}$; for
the pigeonhole the invariant is the $2$-adic valuation, capturing each integer's
multiplicative skeleton; for finite dynamics the invariant is the order, whose
finiteness caps the length of any strictly descending orbit. In every case the
proof avoids brute-force computation in favour of a structural squeeze.

A pleasant cross-link is that the *odd part* of Definition 3 is itself a
valuation-respecting map, mirroring the role of the Fibonacci embedding: both
factor an integer into a "shape" part (odd part / index) and a "scale" part
(power of two / Fibonacci growth), and both proofs exploit uniqueness of that
factorization.

A second methodological observation concerns the role of finiteness. In the
pigeonhole result, finiteness of the color set ($n$ odd numbers) is what forces
a collision; in the descent principle, finiteness of the poset ($N$ states) is
what caps the orbit length. Both are instances of the same combinatorial
bottleneck: an injective map into a set strictly smaller than its domain cannot
exist. The Fibonacci result is the odd one out — it needs no finiteness, drawing
its strength instead from strict monotonicity of $F$ on indices $\ge 2$, which is
the order-theoretic substitute that makes equal values force equal indices. Thus
all three proofs ultimately rest on a single principle: a strictly
order-respecting (or strictly value-distinguishing) map cannot collapse, and any
forced collapse yields the desired conclusion.

Finally, the Garden-of-Eden dichotomy (Theorem 6) deserves emphasis precisely
because it is elementary. Its value is not difficulty but placement: it isolates
the exact algebraic condition (loss of surjectivity) responsible for permanently
unreachable states, and it is the lemma through which the order-theoretic descent
machinery (Theorems 7–8) connects to the dynamical phenomenon (Theorems 9–11).
In the formal development it is discharged by definitional simplification, which
is itself a useful signal: the conceptual work lives entirely in the finite
descent argument, while the surjectivity criterion is a clean restatement.

---

## 8. Future directions

(Reproduced from the Phase A program notes; these describe the broader
research engine into which interface-style results like the above are intended to
plug.)

The formalization in `KernelTailBounds.lean` proves a deterministic scaling-law
engine: given a two-sided polynomial tail bound on a loss sequence, every
standard downstream consequence (positivity, matching rates, data rescaling,
two-sided capacity thresholds) follows with no `sorry`. The directions below
describe how to feed that engine with genuinely new spectral inputs and how to
consume its outputs in applications.

1. **Prove the $p$-series integral comparison for $\lambda_k = (k+1)^{-p}$.**
   Derive, for $p > 1$, that the tail $\sum_{k \ge n}(k+1)^{-p}$ is pinched
   between constant multiples of $(n+1)^{-(p-1)}$, upgrading a pointwise spectral
   statement into a full tail-mass scaling law by elementary sum–integral
   comparison with explicit constants.
2. **Certified empirical spectra.** Formalize a pipeline turning a certified
   empirical spectrum (finite eigenvalue estimates plus a proven two-sided
   confidence envelope) into a verified tail-bound instance, so that an
   experimentally measured power-law slope becomes a machine-checked
   loss-exponent guarantee, discharging the inequalities via certified numerics.

---

## Appendix: Formal inventory

| Lean name | Statement |
|---|---|
| `fib_dvd_of_dvd` | $m \mid n \Rightarrow F_m \mid F_n$ |
| `fib_dvd_iff` | $m \ge 3 \Rightarrow (F_m \mid F_n \iff m \mid n)$ |
| `oddPart` | $\operatorname{oddPart}(x) = x / 2^{v_2(x)}$ |
| `divisibility_pigeonhole` | $S \subseteq [1,2n],\ |S|=n+1 \Rightarrow \exists a \ne b \in S,\ a \mid b$ |
| `IsGardenOfEden` | $\forall x,\ F(x) \ne y$ |
| `exists_garden_of_eden_iff_not_surjective` | $(\exists y,\ \text{GoE})\iff \neg \text{Surjective } F$ |
| `iterate_descends` | $(\forall x, F x \le x) \Rightarrow F^{[n+1]}x \le F^{[n]}x$ |
| `finite_garden_of_eden_descent` | monotone descending on finite $P$: $\exists n \le |P|,\ F^{[n]}x = F^{[n+1]}x$ |
| `finite_garden_of_eden_of_not_surjective` | non-surjective $\Rightarrow$ GoE outside eventual image |
| `finite_configuration_garden_of_eden` | finite config space, non-surjective $\Rightarrow$ unreachable config |
| `preinjective_of_surjective_on_finite_configurations` | finite type: surjective $\Rightarrow$ injective |
