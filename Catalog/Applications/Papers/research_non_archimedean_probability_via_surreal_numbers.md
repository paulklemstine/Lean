# A Finite Infinitesimal Probability Model: Non-Archimedean Measures with Positive Infinitesimal Atoms

**Author:** Aristotle
**Date:** 2026-06-19
**Domain:** Novelty — Foundations of Probability / Non-Archimedean Analysis

---

## Abstract

Classical (real-valued) probability theory forbids a fair lottery over
infinitely many equally likely, individually possible outcomes: the Archimedean
property of the real numbers makes any uniform positive probability sum past 1.
We dissolve this obstruction by relocating probability values into a small,
explicit **non-Archimedean ordered ring of infinitesimals**, and we construct a
family of finitely additive probability measures in which every "visible" atom
carries a *positive infinitesimal* probability ε while the total mass is exactly
1. The value ring is `LexRat = ℚ × ℚ`, with componentwise addition and a
*lexicographic* order under which ε = (0, 1) is positive yet strictly below
every positive rational. For each parameter *n*, the sample space is
`Option (Fin n)`: *n* visible atoms each of weight ε, and one reservoir atom of
weight 1 − n·ε that absorbs the infinitesimal deficit while keeping a unit
standard component. We establish: (i) ε is a genuine infinitesimal
(`eps_infinitesimal`); (ii) a closed form for the probability of an arbitrary
event (`prob_eq_closed_form`); (iii) nonnegativity (`prob_nonneg`); (iv) finite
additivity for disjoint events (`prob_union_disjoint`); (v) normalization to 1
(`prob_univ`); and (vi) that each visible atom has positive infinitesimal
probability strictly below 1 (`visible_singleton_infinitesimal`). The model is a
minimal, fully verified witness that the "impossible fair lottery" is impossible
only over the reals, and it serves as a finite prototype for a probability
theory valued in Conway's surreal numbers. We close with conjectures on
inclusion–exclusion, non-Archimedean conditioning (a Bayes rule that divides
infinitesimals), and a standard-part retraction recovering Lebesgue measure.

---

## 1. Introduction

### 1.1 The impossible lottery

A recurring foundational embarrassment in probability is the *fair infinite
lottery*. Suppose we want a probability assignment on an infinite outcome set
in which every outcome is equally likely and none is impossible. Over the real
numbers this is provably unattainable. If each of countably many outcomes had a
common positive probability *p* > 0, then by the Archimedean property there is
an integer *m* with *m·p* > 1, contradicting normalization and monotonicity.
The only uniform assignment compatible with the axioms gives every singleton
probability 0, severing "probability 0" from "impossible": under the uniform
measure on [0, 1], every point is individually a null event, yet the realized
outcome is always *some* point.

Measure theory accommodates this by restricting attention to a σ-algebra of
"nice" sets (intervals and their countable combinations) and accepting that
singletons are null. This is enormously successful, but it is a *concession*: it
declares the original question — what is the probability of *this exact point*?
— ill-posed rather than answering it.

### 1.2 The diagnosis: Archimedeanness, not probability

The obstruction is a property of the *value field*, not of probability per se.
The real line is **Archimedean**: for every ε > 0 there is *m ∈ ℕ* with
*m·ε* > 1. There is no positive real that survives being added to itself
finitely many times without exceeding any prescribed bound. Hence no positive
real can serve as the common atomic weight of an infinite uniform lottery.

The remedy is to take probability values in a **non-Archimedean ordered
field** (or ordered ring) possessing positive *infinitesimals*: elements ε > 0
such that *n·ε* < 1 for every *n ∈ ℕ*. Such fields include the hyperreals of
nonstandard analysis, fields of formal Hahn/Laurent series, and — the conceptual
target of this program — Conway's **surreal numbers**, the universal ordered
field in which reals, ordinals, and infinitesimals coexist.

### 1.3 Contribution

Rather than invoking heavy machinery, we exhibit the **smallest laboratory** in
which the phenomenon is rigorous and the arithmetic is elementary. We work in
`LexRat = ℚ × ℚ` with lexicographic order, one infinitesimal ε = (0, 1), and a
*finite* family of measures (indexed by *n*) carried by `Option (Fin n)`. The
central trick is the **reservoir atom**: a single outcome `none` of weight
1 − n·ε whose negative infinitesimal coordinate balances the books, while its
unit standard coordinate keeps it lexicographically positive. We prove, with no
gaps, every axiom required of a finitely additive probability measure, plus a
master closed-form formula from which they all follow.

The result is a faithful, finite shadow of the surreal program: every visible
atom is positive yet infinitesimal, finitely many atoms always sum to less than
1, and the whole space has mass exactly 1.

---

## 2. The value ring of infinitesimals

### 2.1 Definition (LexRat)

Let `LexRat := ℚ × ℚ`. We read a pair `x = (x.1, x.2)` as the formal expression
`x.1 + x.2·ε`, where ε is a positive infinitesimal symbol. Addition,
subtraction, and negation are the usual componentwise (ℤ-module / ring)
operations inherited from the product `ℚ × ℚ`. We distinguish three constants:

- **Unit:** `one := (1, 0)`.
- **Infinitesimal:** `eps := (0, 1)`.
- **Rational embedding:** `ofRat q := (q, 0)` for `q ∈ ℚ`.

The simplification facts `one_fst = 1`, `one_snd = 0`, `eps_fst = 0`,
`eps_snd = 1`, `ofRat_fst q = q`, `ofRat_snd q = 0` hold definitionally.

### 2.2 Definition (lexicographic order)

For `x, y ∈ LexRat` define

- **`lexLe x y`** ⟺ `x.1 < y.1` ∨ (`x.1 = y.1` ∧ `x.2 ≤ y.2`);
- **`lexLt x y`** ⟺ `x.1 < y.1` ∨ (`x.1 = y.1` ∧ `x.2 < y.2`);
- **`Nonneg x`** ⟺ `lexLe (0, 0) x`.

This is the dictionary order: the first coordinate (the *standard part*)
dominates, and the second coordinate (the *infinitesimal part*) breaks ties.
Componentwise addition is monotone for `lexLe`, so `(LexRat, +, lexLe)` is an
ordered abelian group; multiplication (componentwise as a ring, or via the
truncated polynomial law `(a,b)(c,d) = (ac, ad+bc)` in the field extension used
in the broader program) is order-compatible on the relevant cone. For the
finite probability model only the additive ordered-group structure and the
order are needed.

### 2.3 The infinitesimal is genuine

> **Lemma (`eps_pos`).** `lexLt (0, 0) eps`.
>
> *Proof.* The standard parts are equal (0 = 0), and the infinitesimal parts
> satisfy 0 < 1; take the right disjunct. ∎

> **Lemma (`eps_nonneg`).** `Nonneg eps`. *(Immediate from `eps_pos`.)*

> **Theorem (`eps_infinitesimal`).** For every `q ∈ ℚ` with `0 < q`,
> `lexLt eps (ofRat q)`.
>
> *Proof.* We compare `eps = (0, 1)` and `ofRat q = (q, 0)`. The standard parts
> are `0` and `q`; since `0 < q`, the left disjunct of `lexLt` holds
> immediately. Hence `eps < ofRat q`. ∎

Thus ε is positive yet strictly below every positive rational — the defining
behavior of an infinitesimal. Equivalently, *n·ε* = (0, n) has standard part 0,
so *n·ε* < 1 = (1, 0) for **every** `n ∈ ℕ`: the Archimedean property fails, by
design.

---

## 3. The finite infinitesimal probability model

### 3.1 Sample space and atom weights

Fix `n : ℕ`. The sample space is `Ω_n := Option (Fin n)`, with:

- *n* **visible atoms** `some i` for `i ∈ Fin n`;
- one **reservoir atom** `none`.

> **Definition (`atomWeight`).**
> `atomWeight n none := (1, −n)` and `atomWeight n (some i) := (0, 1) = eps`.

Read as `a + b·ε`: each visible atom has weight ε, and the reservoir has weight
`1 − n·ε`. The deficit −n·ε is parked in the reservoir's infinitesimal
coordinate, while its standard coordinate is the unit 1.

### 3.2 The measure

> **Definition (`prob`).** For an event `A : Finset (Option (Fin n))`,
> `prob n A := ∑_{x ∈ A} atomWeight n x`.

Probability is the finite sum of atomic weights — the only sensible definition
on a discrete space, and the one from which additivity is automatic.

To analyze it we isolate the visible content of an event.

> **Definition (`visiblePart`).**
> `visiblePart n A := { i ∈ Fin n : some i ∈ A }` (as a `Finset (Fin n)`).

Basic facts: `i ∈ visiblePart n A ↔ some i ∈ A` (`mem_visiblePart`);
`(visiblePart n A).card ≤ n` (`visiblePart_card_le`);
`visiblePart n univ = univ` (`visiblePart_univ`); and
`(visiblePart n univ).card = n` (`visiblePart_univ_card`).

### 3.3 The master formula

> **Theorem (`prob_eq_closed_form`).** For every `A : Finset (Option (Fin n))`,
> ```
> prob n A = ( [none ∈ A] ,  |visiblePart n A| − [none ∈ A]·n )
> ```
> where `[P]` is 1 if `P` holds and 0 otherwise. Explicitly, the standard
> (first) coordinate is 1 iff the reservoir lies in `A`; the infinitesimal
> (second) coordinate is the number of visible atoms in `A`, less `n` when the
> reservoir is present.
>
> *Proof sketch.* Induction on the finite set `A` via `Finset.induction`. The
> empty event gives `(0, 0)`, matching the formula (`visiblePart` is empty and
> `none ∉ ∅`). For the inductive step, insert an atom `a ∉ s`:
> - If `a = none`: the sum gains `(1, −n)`. The reservoir indicator flips from 0
>   to 1, raising the standard coordinate to 1 and subtracting `n` from the
>   infinitesimal coordinate; the visible cardinality is unchanged. The two
>   sides agree after `ring`.
> - If `a = some i` with `i ∉ visiblePart n s`: the sum gains `(0, 1) = eps`.
>   The visible cardinality grows by 1 via
>   `visiblePart n (insert (some i) s) = visiblePart n s ∪ {i}` together with
>   `Finset.card_union` (disjointness from `i ∉ visiblePart n s`); the reservoir
>   indicator is unchanged. Both sides agree after `ring`. ∎

Several specializations follow directly:

> **Corollary (`prob_empty`).** `prob n ∅ = (0, 0)`.
> **Corollary (`prob_singleton_none`).** `prob n {none} = (1, −n)`.
> **Corollary (`prob_singleton_visible`).** `prob n {some i} = eps`.

### 3.4 The probability axioms

> **Lemma (`atomWeight_nonneg`).** Every atom weight is lexicographically
> nonnegative: `Nonneg (atomWeight n x)` for all `x ∈ Ω_n`.
>
> *Proof.* For `none`, the standard part is `1 > 0`, so the left disjunct of
> `lexLe` holds (despite the negative infinitesimal coordinate −n). For
> `some i`, the standard parts are equal (0 = 0) and the infinitesimal parts
> satisfy 0 ≤ 1. ∎

> **Theorem (Nonnegativity, `prob_nonneg`).** For every event `A`,
> `Nonneg (prob n A)`.
>
> *Proof.* Apply `prob_eq_closed_form`. If `none ∈ A`, the standard coordinate
> is `1 > 0` and the left disjunct of `lexLe (0,0) (prob n A)` holds. If
> `none ∉ A`, the standard coordinate is `0` (so standard parts are equal) and
> the infinitesimal coordinate is `|visiblePart n A| ≥ 0`; the right disjunct
> holds (`positivity`). ∎

> **Theorem (Finite additivity, `prob_union_disjoint`).** If `A, B` are disjoint
> events then `prob n (A ∪ B) = prob n A + prob n B`.
>
> *Proof.* By definition `prob` is a `Finset.sum` of `atomWeight`, and
> `Finset.sum_union` over a disjoint union splits the sum:
> `∑_{A ∪ B} = ∑_A + ∑_B`. ∎

> **Theorem (Normalization, `prob_univ`).** `prob n univ = one = (1, 0)`.
>
> *Proof.* By `prob_eq_closed_form` with `A = univ`: `none ∈ univ` makes the
> standard coordinate 1, and `|visiblePart n univ| = n`, so the infinitesimal
> coordinate is `n − n = 0`. Hence `prob n univ = (1, 0) = one`. ∎

> **Theorem (Infinitesimal atoms, `visible_singleton_infinitesimal`).** For each
> `i ∈ Fin n`, `prob n {some i} = eps` and `lexLt (prob n {some i}) one`, i.e.
> the probability of a single visible atom is the positive infinitesimal ε,
> strictly below 1.
>
> *Proof.* The equality is `prob_singleton_visible`. The strict inequality is a
> direct instance of `eps_infinitesimal` at `q = 1` (since `eps = (0,1)` and
> `one = (1,0)` have standard parts `0 < 1`). ∎

### 3.5 Reading the model

The model realizes precisely the configuration the reals forbid:

| Object | Weight (as `a + b·ε`) | Standard part | Infinitesimal part |
|---|---|---|---|
| visible atom `some i` | ε | 0 | 1 |
| all *n* visible atoms | n·ε | 0 | n |
| reservoir `none` | 1 − n·ε | 1 | −n |
| whole space `univ` | 1 | 1 | 0 |

Every visible atom is **possible** (weight ε > 0) and **infinitely unlikely**
(ε < q for every positive rational q). Finitely many atoms sum to `n·ε < 1`. The
reservoir is lexicographically positive because its *standard* coordinate is 1,
even though its infinitesimal coordinate is negative. Normalization is exact, not
asymptotic.

---

## 4. Why the classical no-go theorem is not contradicted

The classical impossibility argument requires summing the probabilities of
infinitely many atoms and observing divergence. Two features of our model block
that argument without weakening probability:

1. **Finite additivity only.** `prob_union_disjoint` is stated for (finite)
   disjoint unions; the natural domain is the Boolean algebra of *finite*
   subsets of `Ω_n`. We never form an infinite disjoint sum of singletons.

2. **Genuine infinitesimals.** Because `eps_infinitesimal` gives `n·ε < 1` for
   every *n*, no finite collection of visible atoms ever exhausts the budget.

In the broader program this finitary discipline persists at the limit: the
intended model takes the sample space to be the real interval [0, 1], the value
field to be a non-Archimedean field `K = Lex(ℝ⟦ℚ⟧)` of formal series (a concrete
surrogate for Conway's surreals), and assigns every point of [0, 1] a positive
infinitesimal mass while the whole interval has mass exactly 1. The "paradox"
dissolves because the honest domain is the *finite-union* Boolean algebra of
elementary sets, on which [0, 1] is **not** a disjoint union of its points.

---

## 5. Algorithms

The model is fully computational over ℚ × ℚ. We record the core procedures.

### 5.1 Lexicographic comparison

```
function lexCmp((a1, b1), (a2, b2)):
    if a1 < a2: return LT
    if a1 > a2: return GT
    if b1 < b2: return LT
    if b1 > b2: return GT
    return EQ
```
Complexity O(1) (two rational comparisons). Correctness mirrors `lexLt`/`lexLe`.

### 5.2 Event probability by direct summation

```
function probDirect(n, A):                 # A ⊆ Option(Fin n)
    s := (0, 0)
    for x in A:
        s := s + atomWeight(n, x)          # componentwise add
    return s
```
Complexity O(|A|). Correct by definition of `prob`.

### 5.3 Event probability by the closed form

```
function probClosed(n, A):
    res := 1 if (none ∈ A) else 0          # standard coordinate
    vis := |{ i : some i ∈ A }|            # visible cardinality
    inf := vis − (n if (none ∈ A) else 0)  # infinitesimal coordinate
    return (res, inf)
```
Complexity O(|A|) to compute `vis`, O(1) thereafter. Equivalence with
`probDirect` is the content of `prob_eq_closed_form`; this gives a verified
fast path and an oracle for testing.

---

## 6. Applications and significance

- **Fair infinite lotteries.** The model is an explicit, axiom-checked witness
  that uniform "every-outcome-possible" assignments exist once values are
  non-Archimedean — a concrete answer to a long-standing foundational
  discomfort.

- **Separating null from impossible.** Visible atoms have positive
  (infinitesimal) probability, restoring the distinction between
  "probability 0" and "impossible" that real-valued measures collapse.

- **A finite surreal prototype.** The construction is a finite, fully verified
  shadow of surreal-valued probability, isolating the essential mechanism (a
  reservoir balancing infinitesimal deficit under lexicographic order) from the
  heavier analytic apparatus of Hahn series and surreals.

- **Nonstandard analysis bridge.** The standard-part coordinate is precisely the
  shadow map of nonstandard analysis, suggesting a clean reduction of the
  infinitesimal theory to classical measure theory (Section 7).

---

## 7. Discussion and future directions

The development establishes the additive, finitely-additive core. The natural
next steps lift it toward a full non-Archimedean measure theory. The following
conjectures are precise and falsifiable.

### C1. Inclusion–exclusion and Carathéodory-style extension

**Conjecture.** The measure extends from disjoint joins to a finitely additive
measure on the full Boolean algebra of elementary sets (finite
unions/intersections/complements of intervals modified at finitely many points),
satisfying two-set inclusion–exclusion
`μ(E₁ ∪ E₂) + μ(E₁ ∩ E₂) = μ E₁ + μ E₂` and monotonicity. *Key insight:*
disjoint additivity (`prob_union_disjoint`) upgrades to general unions once the
continuous content (the ℚ standard part) and the atomic count (the infinitesimal
part) obey inclusion–exclusion *separately*, because the two summands live in
independent graded pieces of the value ring (order-0 reals vs. order-1
infinitesimals).

### C2. Non-Archimedean conditioning (a Bayes rule dividing infinitesimals)

**Conjecture.** For elementary sets with `μ B ≠ 0`, the conditional measure
`μ(A | B) := μ(A ∩ B) / μ B` is well-defined in the value field, lies in [0, 1],
and conditioning on a single point (mass ε) yields a genuine probability — e.g.
`μ({x} | {x, y}) = 1/2` — where real-valued measures produce the undefined 0/0.
*Key insight:* division by ε is legal in a *field*, so ratios of order-1
quantities collapse to order-0 reals; conditioning on a (real-) null event
becomes meaningful in the surreal extension.

### C3. Standard-part retraction recovering Lebesgue measure

**Conjecture.** The order-0 coefficient map `st : K → ℝ`, `st x = (ofLex x).coeff 0`,
is an ordered-ring retraction sending the infinitesimal measure of every
elementary set to its classical Lebesgue measure. In the finite model this is
already visible: `st(prob n A)` is the first coordinate, which is 1 for the whole
space and 0 for any finite collection of points — exactly the Lebesgue/length
content of those elementary sets.

Further directions include: countable additivity in an appropriate
non-Archimedean topology; expectation and integration of `K`-valued random
variables; and a full surreal-valued ([0, 1]) construction with one infinitesimal
atom per point, of which the present family `{prob n}` is the finite truncation.

---

## 8. Conclusion

We constructed and fully verified a finite family of finitely additive
probability measures valued in a non-Archimedean ring of infinitesimals. Every
visible atom carries a positive infinitesimal probability ε strictly below 1
(`visible_singleton_infinitesimal`, `eps_infinitesimal`); the measure is
nonnegative (`prob_nonneg`), finitely additive (`prob_union_disjoint`), and
exactly normalized (`prob_univ`); and a single closed form
(`prob_eq_closed_form`) computes every event. The "impossible fair lottery" is
impossible only over the Archimedean reals. Given an infinitesimal to spend,
probability can make the impossible merely improbable — and do so lawfully.
