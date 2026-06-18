# The Rank of Apparition as a Divisibility-Lattice Morphism: An Abstract Theory of Strong Divisibility Sequences

## Abstract

The *rank of apparition* (entry point) of a modulus m in an integer sequence u is
the least positive index k at which m divides u(k). For the Fibonacci numbers this
classical invariant satisfies a *law of apparition* (m | u(k) iff entry(m) | k) and
is *multiplicative on coprime moduli* (entry(a·b) = lcm(entry(a), entry(b)) for
coprime a, b). These facts are traditionally derived through Fibonacci-specific
machinery — Lucas sequences, the golden ratio, Pisano periods. We show that both,
together with rigidity and monotonicity results, follow from a single structural
hypothesis: the **strong divisibility identity**

> gcd( u(m), u(n) ) = u( gcd(m, n) ),

augmented, for one edge case only, by the boundary value u(0) = 0. We isolate
exactly which hypotheses each theorem requires, prove that the entry map is a
morphism of divisibility lattices from moduli to indices, and harvest two
cross-domain corollaries at no further cost: the classical multiplicativity of the
multiplicative order modulo coprime moduli (via u(n) = aⁿ − 1, where the entry
point *is* the multiplicative order), and the Fibonacci multiplicativity of the
rank of apparition (via u = Fibonacci). All results are formally verified.

**Keywords:** strong divisibility sequence, rank of apparition, entry point, law of
apparition, multiplicative order, Fibonacci numbers, Mersenne sequence, divisibility
lattice, lattice morphism.

---

## 1. Introduction

A *divisibility sequence* is an integer sequence u with the property that m | n
implies u(m) | u(n). A *strong* divisibility sequence (SDS) strengthens this to the
gcd identity

> (SDS)  gcd( u(m), u(n) ) = u( gcd(m, n) )  for all m, n.

The Fibonacci numbers are the prototypical example (the identity
gcd(F(m), F(n)) = F(gcd(m, n)) is classical), but so is the base-a repunit /
Mersenne sequence u(n) = aⁿ − 1, by virtue of the identity
gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1.

Attached to such a sequence is the **rank of apparition** (or *entry point*) of a
modulus m: the smallest positive index k for which m | u(k). For Fibonacci numbers
this object has been studied since Lucas, and two facts are central to its theory:

1. **The law of apparition**: m | u(k) iff entry(m) | k.
2. **Coprime multiplicativity**: entry(a·b) = lcm(entry(a), entry(b)) when
   gcd(a, b) = 1.

These are usually proved using the special structure of the Fibonacci/Lucas
recurrence. The contribution of this work is to demonstrate that *neither fact uses
that structure*. Both — and the rigidity and monotonicity results that accompany
them — are consequences of the SDS identity alone (plus u(0) = 0 for a single edge
case). We thereby exhibit the entry map as a structure-preserving morphism between
two divisibility lattices: the lattice of moduli and the lattice of indices.

The dual half of this morphism — that gcd maps to gcd at the index level — is the
content of the SDS identity itself; our results supply the complementary
product/lcm half and the order-preservation that together make "lattice morphism"
literal rather than metaphorical.

---

## 2. Definitions

Throughout, u : ℕ → ℕ is a fixed sequence and all divisibility is in ℕ.

**Definition 2.1 (Strong divisibility sequence).** u is a *strong divisibility
sequence*, written IsSDS(u), if

> gcd( u(m), u(n) ) = u( gcd(m, n) )   for all m, n ∈ ℕ.

**Definition 2.2 (Appearance).** A modulus m *appears* in u, written Appears(u, m),
if there exists k > 0 with m | u(k).

**Definition 2.3 (Entry point / rank of apparition).** The *entry point* of m is

> entry(m) = the least k > 0 with m | u(k),   if m appears;
> entry(m) = 0,                               otherwise.

(Formally, entry(m) = Nat.find of the appearance predicate when it holds, else 0.)

We record two trivial-but-essential facts from the definition.

**Lemma 2.4 (Entry specification).** If m appears, then entry(m) > 0 and
m | u(entry(m)). In particular entry(m) is itself a valid index of appearance.

*Proof.* Immediate from the defining minimization: the witness produced by the
least-element principle is positive and satisfies the divisibility. ∎

---

## 3. Transport of divisibility

The first structural consequence of (SDS) is that divisibility of indices
transports to divisibility of terms — the "weak" divisibility property, here
derived from the strong one.

**Lemma 3.1 (Index divisibility transports).** If IsSDS(u) and d | n, then
u(d) | u(n).

*Proof.* Since d | n we have gcd(d, n) = d, so by (SDS),
gcd(u(d), u(n)) = u(gcd(d, n)) = u(d). A number equals the gcd of itself and a
second number exactly when it divides that second number; hence u(d) | u(n). ∎

---

## 4. The rank of apparition divides every index of appearance

This is the technical core from which the law of apparition and everything
downstream flow. It uses only (SDS).

**Theorem 4.1 (Entry divides index).** Let IsSDS(u). If n > 0 and m | u(n), then
entry(m) | n.

*Proof.* Write e = entry(m); since m | u(n) with n > 0, m appears, so by Lemma 2.4
we have e > 0 and m | u(e). From m | u(n) and m | u(e),

> m | gcd(u(n), u(e)) = u(gcd(n, e))   (by SDS).

Thus gcd(n, e) is a positive index (it is positive because e > 0 divides it... more
precisely gcd(n,e) > 0 since e > 0) at which m divides the term. By minimality of e
as the *least* positive index of appearance, we cannot have gcd(n, e) < e; hence
e ≤ gcd(n, e). But gcd(n, e) | e gives gcd(n, e) ≤ e, so gcd(n, e) = e. Since
gcd(n, e) | n, we conclude e | n. ∎

The argument is the canonical "minimality meets self-similarity" pattern: any other
index of appearance, intersected (via gcd, i.e. via the SDS identity) with the
minimal one, cannot escape below the minimum, forcing divisibility.

---

## 5. The abstract law of apparition

**Theorem 5.1 (Law of apparition).** Let IsSDS(u) and u(0) = 0, and let m appear.
Then for every k ∈ ℕ,

> m | u(k)  ⟺  entry(m) | k.

*Proof.* (⇒) If k > 0, this is exactly Theorem 4.1. If k = 0, then entry(m) | 0
holds trivially, so the implication is vacuously satisfied. (Here u(0) = 0 ensures
the k = 0 case is consistent: m | u(0) = 0 always, and entry(m) | 0 always.)

(⇐) Suppose entry(m) | k. By Lemma 3.1 (transport), u(entry(m)) | u(k). By
Lemma 2.4, m | u(entry(m)). Composing, m | u(k). ∎

**Remark 5.2 (Role of u(0) = 0).** The boundary value is *only* needed to make the
k = 0 instance of the biconditional come out correctly; the substance of the
theorem (all positive k) rests on (SDS) alone. This pinpoints u(0) = 0 as
load-bearing for exactly one edge case.

---

## 6. Rigidity: the entry point is the unique generator

The appearance set { k : m | u(k) } is, by the law of apparition, precisely the set
of multiples of entry(m). The following converse rigidity statement shows that the
generator is uniquely determined — and, notably, it requires only (SDS), not even
u(0) = 0.

**Theorem 6.1 (Rigidity / unique generator).** Let IsSDS(u), let m appear, let
d > 0, and suppose that for all k, m | u(k) ⟺ d | k. Then entry(m) = d.

*Proof.* We prove mutual divisibility and apply antisymmetry.

- entry(m) | d: From the hypothesis with k = d we get m | u(d) (since d | d).
  As d > 0, Theorem 4.1 yields entry(m) | d.
- d | entry(m): By Lemma 2.4, m | u(entry(m)); by the hypothesis with
  k = entry(m), this gives d | entry(m).

Hence entry(m) = d. ∎

This says the appearance set determines, and is determined by, a single positive
integer — the structure is maximally rigid.

---

## 7. The entry map is a divisibility-lattice morphism

We now show the entry map respects both lattice operations on moduli. Together with
the gcd-half (which is the SDS identity itself, transported to indices), this
justifies calling entry a *morphism of divisibility lattices*.

### 7.1 Order side (monotonicity)

**Theorem 7.1 (Order preservation).** Let IsSDS(u). If m appears and d | m, then
entry(d) | entry(m).

*Proof.* Since d | m and m | u(entry(m)) (Lemma 2.4), transitivity gives
d | u(entry(m)). As entry(m) > 0 (Lemma 2.4), Theorem 4.1 applied to d yields
entry(d) | entry(m). ∎

Refining the modulus in the divisibility order refines the entry point in the same
order.

### 7.2 Join side (multiplicativity on coprime moduli)

We first record the elementary splitting lemma.

**Lemma 7.2 (Coprime product splits divisibility).** If gcd(a, b) = 1, then for all
k, (a·b) | k ⟺ (a | k and b | k).

*Proof.* (⇒) a | a·b | k and b | a·b | k. (⇐) For coprime a, b, joint divisibility
by a and b implies divisibility by their product. ∎

**Theorem 7.3 (Join law / multiplicativity).** Let IsSDS(u) and u(0) = 0. If
gcd(a, b) = 1 and both a and b appear, then

> entry(a·b) = lcm( entry(a), entry(b) ).

*Proof.* We show the appearance set of a·b is exactly the multiples of
L := lcm(entry(a), entry(b)), then invoke rigidity (Theorem 6.1).

First, a·b appears: by Lemma 3.1 each of a, b divides u at a common multiple of
their entry points, and Lemma 7.2 assembles a·b dividing that term; concretely a·b
divides u(L). For an arbitrary k, chain the equivalences:

> (a·b) | u(k)
>   ⟺ a | u(k)  and  b | u(k)              (Lemma 7.2, coprimality)
>   ⟺ entry(a) | k  and  entry(b) | k       (Theorem 5.1, law of apparition)
>   ⟺ lcm(entry(a), entry(b)) | k           (definition of lcm)
>   ⟺ L | k.

Thus (a·b) | u(k) ⟺ L | k for all k. Since L = lcm(entry(a), entry(b)) > 0 (both
entry points are positive by Lemma 2.4), Theorem 6.1 gives entry(a·b) = L. ∎

**Corollary 7.4 (Reduction to prime powers).** For any modulus n that appears, with
prime-power factorization n = ∏ pᵢ^{eᵢ}, the prime-power factors are pairwise
coprime, so by induction on Theorem 7.3,

> entry(n) = lcm_i ( entry(pᵢ^{eᵢ}) ).

Hence the computation of every entry point reduces to the prime-power case. ∎

---

## 8. Cross-domain instantiations

Because Sections 3–7 used only (SDS) and u(0) = 0, every concrete sequence with
those properties inherits the full theory. We highlight two.

### 8.1 The Mersenne / repunit family — and the multiplicative order

Fix a base a ≥ 2 and let u(n) = aⁿ − 1. Then u(0) = 0, and the classical identity

> gcd(aᵐ − 1, aⁿ − 1) = a^{gcd(m,n)} − 1

shows IsSDS(u). For this sequence, m | u(k) means m | aᵏ − 1, i.e. aᵏ ≡ 1 (mod m),
so the entry point of m is the **multiplicative order** ord_m(a). Theorem 7.3 then
reads:

**Corollary 8.1 (Multiplicativity of the multiplicative order).** For coprime
moduli a', b' coprime to the base (so that orders exist),

> ord_{a'·b'}(a) = lcm( ord_{a'}(a), ord_{b'}(a) ).

*Example.* Base a = 2. ord₅(2) = 4 (since 2⁴ − 1 = 15), ord₇(2) = 3 (since
2³ − 1 = 7). As 5 and 7 are coprime, ord₃₅(2) = lcm(4, 3) = 12, and indeed
2¹² − 1 = 4095 = 35 × 117.

This recovers a cornerstone of computational number theory (used pervasively in
RSA, Diffie–Hellman, and primality testing) as a special case of the abstract join
law.

### 8.2 The Fibonacci family

Let u = F, the Fibonacci sequence, with F(0) = 0 and gcd(F(m), F(n)) = F(gcd(m, n)).
Theorem 7.3 specializes to:

**Corollary 8.2 (Fibonacci rank multiplicativity).** For coprime a, b that appear,

> entry_F(a·b) = lcm( entry_F(a), entry_F(b) ).

*Example.* entry_F(2) = 3 (F(3) = 2), entry_F(3) = 4 (F(4) = 3). Since 2, 3 are
coprime, entry_F(6) = lcm(3, 4) = 12 — and indeed F(12) = 144 = 6 × 24, while no
earlier Fibonacci number is divisible by 6.

---

## 8b. Worked examples

We trace the machinery end-to-end on two moduli to make the abstractions concrete.

**Example 1: entry_F(60) in the Fibonacci sequence.** Factor 60 = 2^2 · 3 · 5, with
pairwise coprime prime-power factors 4, 3, 5. Compute each entry point by direct
search over small Fibonacci numbers:

- entry_F(4): the Fibonacci numbers are 1, 1, 2, 3, 5, 8, …; the first divisible by
  4 is F(6) = 8, so entry_F(4) = 6.
- entry_F(3): F(4) = 3, so entry_F(3) = 4.
- entry_F(5): F(5) = 5, so entry_F(5) = 5.

By Corollary 7.4, entry_F(60) = lcm(6, 4, 5) = 60. One verifies directly that F(60)
= 1 548 008 755 920 is divisible by 60 and that no earlier Fibonacci number is —
but the point is that we never had to compute that 13-digit term: three searches
over single-digit and two-digit Fibonacci numbers plus one least common multiple
sufficed.

**Example 2: order of 2 modulo 35.** Here u(n) = 2^n − 1, and entry(m) is the
multiplicative order of 2 modulo m. Factor 35 = 5 · 7 (coprime). The order of 2
modulo 5 is 4 (2^4 = 16 ≡ 1), and modulo 7 is 3 (2^3 = 8 ≡ 1). By Theorem 7.3 /
Corollary 8.1, ord_35(2) = lcm(4, 3) = 12, confirmed by 2^12 − 1 = 4095 = 35 · 117.
This is exactly the reasoning a cryptographer uses to understand the order of an
element in (Z/35Z)^× via the Chinese Remainder Theorem — but here it is an instance
of a theorem proved once, abstractly, for all strong divisibility sequences.

The two examples are *the same computation* in two disguises: factor the modulus,
look up prime-power entry points, take an lcm. That this works identically for
Fibonacci divisibility and for multiplicative orders is precisely the content of
the abstraction.

---

## 9. Algorithms

The theory yields a direct algorithm for computing entry points of composite moduli
from the prime-power case, and a verification routine for the law of apparition.

**Algorithm A (Entry point via prime-power reduction).**
Given an SDS oracle u and a modulus n:
1. Factor n = ∏ pᵢ^{eᵢ}.
2. For each prime power q = pᵢ^{eᵢ}, compute entry(q) by direct search (the only
   place a search is needed).
3. Return lcm of the entry(q) (Corollary 7.4).

This replaces a potentially enormous direct search over indices of n with a small
number of prime-power searches plus an lcm.

**Algorithm B (Law-of-apparition divisibility test).**
To decide whether m | u(k) for large k without computing u(k): compute entry(m)
once, then test entry(m) | k (Theorem 5.1). The exponential-size term u(k) is never
formed.

Both are detailed with pseudocode and reference Python in the accompanying package.

---

## 10. Discussion

The conceptual payoff is the clean separation of *what is true* from *why it is
true*. The Fibonacci rank of apparition is not special; it is one shadow of a
purely order-theoretic phenomenon attached to any sequence satisfying the
renormalization identity. The entry map sends the divisibility lattice of moduli
into the divisibility lattice of indices, carrying gcd to gcd (the SDS identity) and
coprime products to least common multiples (Theorem 7.3), and preserving the
divisibility order (Theorem 7.1). Rigidity (Theorem 6.1) guarantees the map is
well-defined as a genuine generator-assignment with no ambiguity.

A subtle but valuable by-product of the formal development is the precise accounting
of hypotheses: the substantive content rests on (SDS) alone; the boundary value
u(0) = 0 is load-bearing for *only* the k = 0 instance of the law of apparition; and
rigidity needs neither u(0) = 0 nor coprimality. Such fine-grained hypothesis
tracking is exactly what one wants when porting a result to a new domain, since one
knows immediately which facts must be re-established.

### 10.1 The lattice-morphism picture

It is worth making the title of this paper precise. Consider two partially ordered
sets, each ordered by divisibility: the moduli M = (ℕ_{>0}, |) and the indices
I = (ℕ_{>0}, |). Both are lattices, with meet = gcd and join = lcm. Restricting
attention to moduli that appear, the entry map

> entry : M → I,   m ↦ entry(m)

enjoys the following structural properties:

- **Monotone** (Theorem 7.1): d | m ⟹ entry(d) | entry(m). The map respects the
  order.
- **Join-preserving on coprime pairs** (Theorem 7.3): for coprime a, b — exactly
  the pairs whose join in M is the product a·b and whose meet is 1 — we have
  entry(a·b) = lcm(entry(a), entry(b)) = entry(a) ∨ entry(b). The map sends the
  join in M to the join in I.
- **Meet-compatible** via the SDS identity itself: the renormalization law
  gcd(u(m), u(n)) = u(gcd(m, n)), transported through the entry map, is the
  statement that meets of indices control meets of terms; it is the dual half that
  pairs with Theorem 7.3.

Thus the entry point is not a mere numerical invariant; it is a morphism of
divisibility lattices, and Theorems 7.1, 7.3 together with the SDS identity are the
three clauses that justify the word "morphism." Rigidity (Theorem 6.1) guarantees
the map is well-defined as the unique generator assignment.

### 10.2 Why coprimality, and not full multiplicativity

One might hope for entry(a·b) = lcm(entry(a), entry(b)) without coprimality, but
this fails: in the Fibonacci sequence entry_F(2) = 3, yet entry_F(4) = 6 ≠
lcm(3, 3) = 3. The interaction of repeated prime factors with the sequence's
p-adic valuation (the Wall–Sun–Sun phenomenon) is genuinely subtle and is exactly
what coprimality sidesteps. This is why Corollary 7.4 reduces computation to the
prime-power case rather than to the prime case: the prime-power entry points carry
irreducible information that the join law cannot manufacture.

---

## 11. Future work

- **Discharging the appearance hypotheses for Fibonacci.** Every positive m divides
  some positive Fibonacci number (a consequence of Pisano periodicity), with first
  index bounded (e.g. entry_F(m) ≤ 6m via the Pisano-period bound). Formalizing this
  would remove the Appears hypotheses from Corollary 8.2, upgrading it to the
  unconditional statement for all coprime a, b > 0.
- **Prime-power entry points.** Develop the entry point at prime powers
  (the "Wall–Sun–Sun" phenomenon for Fibonacci: whether entry(p²) = entry(p)), which
  together with Corollary 7.4 would give a complete computational theory.
- **Further SDS instances.** Elliptic divisibility sequences and Lehmer sequences
  also satisfy (variants of) the strong divisibility identity; the abstract theory
  should transfer with minor adjustments.
- **Lattice-theoretic completion.** Pair Theorem 7.3 with the gcd-half to state and
  formalize "entry is a morphism of bounded divisibility lattices" as a single
  categorical statement.

---

## 12. Summary of results

| Result | Statement | Hypotheses used |
|---|---|---|
| Lemma 3.1 | d \| n ⟹ u(d) \| u(n) | SDS |
| Theorem 4.1 | m \| u(n), n>0 ⟹ entry(m) \| n | SDS |
| Theorem 5.1 | m \| u(k) ⟺ entry(m) \| k | SDS, Appears (u(0)=0 only for k=0) |
| Theorem 6.1 | unique positive generator ⟹ = entry(m) | SDS only |
| Theorem 7.1 | d \| m ⟹ entry(d) \| entry(m) | SDS, Appears |
| Theorem 7.3 | entry(a·b) = lcm(entry a, entry b) | SDS, u(0)=0, coprime, Appears |
| Corollary 8.1 | ord_{a·b} = lcm(ord_a, ord_b) | instances of 7.3 |
| Corollary 8.2 | Fibonacci rank multiplicative | instances of 7.3 |

All results are formally verified and depend only on the standard foundational
axioms (propositional extensionality, the axiom of choice, and quotient soundness).
