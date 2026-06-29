# The Multiplicative Independence Barrier behind Cobham's Theorem

## Abstract

Cobham's theorem (1972) asserts that any sequence that is simultaneously
*j*-automatic and *k*-automatic for **multiplicatively independent** bases *j*
and *k* is eventually periodic. The entire content of the theorem rests on the
multiplicative-independence hypothesis: without it (for instance, for the bases 2
and 4) the conclusion is false. This paper isolates and develops the arithmetic
backbone of that hypothesis as a self-contained, fully verified theory. We study
the relation of **multiplicative dependence** of natural-number bases,
`MultDep j k := ∃ a b > 0, jᵃ = kᵇ`, which for bases ≥ 2 is equivalent to the
rationality of `log j / log k`. We prove that `MultDep` is an equivalence
relation on bases (reflexivity, symmetry, and — the only substantive axiom —
transitivity, established by elementary exponent bookkeeping), that powers of a
fixed base are always dependent, and, as the central result, the **barrier
theorem**: a base *j* ≥ 2 coprime to *k* is never multiplicatively dependent on
*k*. The concrete witness `¬ MultDep 2 3` certifies that the barrier is
non-empty and hence that Cobham's theorem is non-vacuous. We close with a
conjectural normal-form classification — dependent bases are exactly common
powers of a single primitive integer — and discuss its role as a bridge toward a
full formalization of Cobham's theorem. Every positive result reported here is
formally verified; the conjecture is the sole open statement.

**Keywords.** Cobham's theorem, automatic sequences, multiplicative
independence, finite automata, eventual periodicity, prime factorization,
equivalence relation.

---

## 1. Introduction

### 1.1 Automatic sequences and Cobham's theorem

Fix an integer base *k* ≥ 2. A sequence `(uₙ)ₙ≥0` over a finite alphabet is
**k-automatic** if there is a deterministic finite automaton with output (a
*DFAO*) that, when fed the base-*k* representation of *n*, halts in a state whose
output label is `uₙ`. Equivalently, by a theorem of Eilenberg, the **k-kernel**
of *u* — the set of subsequences `(u_{kⁱ n + r})ₙ` for *i* ≥ 0 and 0 ≤ r < kⁱ —
is finite.

The prototypical example is the **Thue–Morse sequence** `t`, where `tₙ` is the
parity of the number of 1s in the binary expansion of *n*:

```
t = 0 1 1 0 1 0 0 1 1 0 0 1 0 1 1 0 ...
```

It is 2-automatic (a two-state automaton suffices) yet not eventually periodic.

Cobham's theorem describes precisely when automaticity in two bases can coexist
nontrivially.

> **Theorem (Cobham, 1972).** Let *j*, *k* ≥ 2 be **multiplicatively
> independent** bases. If a sequence is both *j*-automatic and *k*-automatic, then
> it is eventually periodic.

The hypothesis of multiplicative independence is essential. If *j* and *k* are
multiplicatively *dependent* — say *j* = 2, *k* = 4, so that 2² = 4¹ — then the
two automaton models are inter-translatable (two base-2 digits = one base-4
digit), and the Thue–Morse sequence is both 2- and 4-automatic while remaining
aperiodic. Thus the qualitative dividing line that makes Cobham's theorem true is
exactly the dependence/independence dichotomy on the pair of bases.

### 1.2 Contribution

This paper formalizes the *arithmetic* core that governs that dividing line. We
make the dependence relation a first-class object, establish its algebraic
structure, and prove the obstruction that renders Cobham's theorem non-vacuous.
Concretely:

1. We define multiplicative dependence purely arithmetically and explain its
   equivalence to the analytic condition `log j / log k ∈ ℚ`, while arguing that
   the arithmetic form is the correct foundation.
2. We prove `MultDep` is an equivalence relation (Section 3).
3. We prove powers of a fixed base are always dependent (Section 4).
4. We prove the **barrier theorem** for coprime bases and exhibit the concrete
   witness `¬ MultDep 2 3` (Section 5).
5. We state and analyze the **common-root normal-form conjecture** (Section 6).

All positive results have complete, machine-checked proofs free of unproven
assumptions; the normal-form statement is left as an explicit conjecture.

---

## 2. Definitions

Throughout, *bases* are natural numbers, and the interesting regime is *j*, *k* ≥
2.

> **Definition 2.1 (Multiplicative dependence).** Two bases *j*, *k* ∈ ℕ are
> **multiplicatively dependent**, written `MultDep j k`, if there exist *a*, *b* ∈
> ℕ with *a* > 0, *b* > 0, and *jᵃ = kᵇ*.

The pair (*a*, *b*) is a **witness** of dependence. When no such witness exists,
*j* and *k* are **multiplicatively independent**.

> **Proposition 2.2 (Analytic reformulation).** For *j*, *k* ≥ 2,
> `MultDep j k ↔ log j / log k ∈ ℚ`.

*Proof sketch.* For positive reals, `jᵃ = kᵇ` is equivalent (apply log and use
log *j*, log *k* > 0) to `a · log j = b · log k`, i.e. `log j / log k = b / a ∈
ℚ` with *a*, *b* > 0. Conversely, a positive rational `b / a` yields the witness
(*a*, *b*). ∎

We emphasize that Definition 2.1, not Proposition 2.2, is the operative
definition. The arithmetic form `jᵃ = kᵇ` is an elementary statement about
integers; the analytic form, although equivalent, imports real-analytic
machinery (the logarithm, the order structure of ℝ) that is inessential to every
result below. This choice of abstraction level is what allows entirely
elementary proofs.

> **Definition 2.3 (Total persistence / energy — not used here).** *(Reserved for
> companion work; this paper concerns only `MultDep`.)*

---

## 3. Multiplicative dependence is an equivalence relation

We show `MultDep` is reflexive, symmetric, and transitive on bases.

> **Theorem 3.1 (Reflexivity).** For every base *j*, `MultDep j j`.

*Proof.* Take *a* = *b* = 1; then *j*¹ = *j*¹. ∎

> **Theorem 3.2 (Symmetry).** If `MultDep j k` then `MultDep k j`.

*Proof.* Given a witness (*a*, *b*) with *jᵃ = kᵇ*, the pair (*b*, *a*) witnesses
`MultDep k j` since *kᵇ = jᵃ*. ∎

> **Theorem 3.3 (Transitivity).** If `MultDep j k` and `MultDep k l` then
> `MultDep j l`.

*Proof.* Let (*a*, *b*) witness `MultDep j k`, so *jᵃ = kᵇ*, and (*c*, *d*)
witness `MultDep k l`, so *kᶜ = lᵈ*. We exhibit the witness (*a·c*, *d·b*) for
`MultDep j l`. Compute:

```
j^(a·c) = (jᵃ)ᶜ = (kᵇ)ᶜ = (kᶜ)ᵇ = (lᵈ)ᵇ = l^(d·b).
```

The key step `(kᵇ)ᶜ = (kᶜ)ᵇ` is commutativity of multiplication in the exponent
(`b·c = c·b`). Both new exponents *a·c* and *d·b* are positive because all of *a*,
*b*, *c*, *d* are. Hence `MultDep j l`. ∎

> **Corollary 3.4.** `MultDep` is an equivalence relation on bases. Its classes
> partition the bases into *dependence families*.

Transitivity is the only nontrivial axiom; reflexivity and symmetry are
immediate. The argument is pure exponent arithmetic and requires no
factorization theory.

---

## 4. Powers of a fixed base

The dependence families have a clean internal structure: any two positive powers
of a common base are dependent.

> **Theorem 4.1 (Powers are dependent).** For any base *j* and any *m*, *n* > 0,
> `MultDep (jᵐ) (jⁿ)`.

*Proof.* Use the witness (*n*, *m*): `(jᵐ)ⁿ = j^(m·n) = (jⁿ)ᵐ`. Both exponents
are positive. ∎

In particular {2, 4, 8, 16, …} is a single dependence family, as is {3, 9, 27,
…}. Theorem 4.1 shows every dependence family contains all positive powers of any
of its members. The converse direction — that *every* dependent pair arises this
way from a single primitive root — is the content of the conjecture in Section 6.

---

## 5. The multiplicative independence barrier

We now prove the central obstruction.

> **Theorem 5.1 (Coprime barrier).** If *j* ≥ 2 and `Coprime j k` (i.e.
> `gcd(j, k) = 1`), then `¬ MultDep j k`.

*Proof.* Suppose toward a contradiction that `MultDep j k` holds, with witness
(*a*, *b*), so *jᵃ = kᵇ* and *a*, *b* > 0. Since *j* ≥ 2, *j* ≠ 1, so by the
fundamental theorem of arithmetic there is a prime *p* with *p* ∣ *j*. Then:

* *p* ∣ *j* ⟹ *p* ∣ *jᵃ* (as *a* ≥ 1).
* *jᵃ = kᵇ* ⟹ *p* ∣ *kᵇ*.
* *p* prime and *p* ∣ *kᵇ* ⟹ *p* ∣ *k* (Euclid's lemma / `Prime.dvd_of_dvd_pow`).

Hence *p* divides both *j* and *k*, so *p* ∣ gcd(*j*, *k*) = 1, forcing *p* = 1.
This contradicts the primality of *p*. Therefore `¬ MultDep j k`. ∎

Two remarks. First, the hypothesis is *sharp and one-sided*: we never used *k* ≥
2, so the theorem also rules out the degenerate `k = 1` (where `Coprime j 1`
always holds). Second, the proof is a three-line divisibility argument resting on
the existence of a prime factor of *j* and Euclid's lemma — no logarithms, no
analysis.

A self-contained corollary is the keystone of the whole theory.

> **Theorem 5.2 (Concrete witness).** `¬ MultDep 2 3`.

*Proof (independent, elementary).* Suppose 2ᵃ = 3ᵇ with *a*, *b* > 0. Reduce both
sides modulo 2. Since *a* ≥ 1, `2ᵃ ≡ 0 (mod 2)`. Since 3 ≡ 1 (mod 2), `3ᵇ ≡ 1ᵇ =
1 (mod 2)`. Thus 0 ≡ 1 (mod 2), a contradiction. ∎

Theorem 5.2 also follows immediately from Theorem 5.1 with `Coprime 2 3`. We
record the modular proof because it is the most elementary possible certificate
that base 2 and base 3 are multiplicatively independent — the exact arithmetic
fact that makes Cobham's theorem non-vacuous.

> **Corollary 5.3 (Non-vacuity of Cobham's theorem).** There exists a pair of
> multiplicatively independent bases, namely (2, 3). Consequently Cobham's theorem
> has nontrivial instances.

---

## 6. A normal-form conjecture

The structural results above suggest that dependence families are exactly the
sets of positive powers of a single primitive integer.

> **Conjecture 6.1 (Common-root normal form).** For *j*, *k* ≥ 2,
> `MultDep j k ↔ ∃ g p q, g ≥ 2 ∧ p > 0 ∧ q > 0 ∧ j = g^p ∧ k = g^q`.

*Discussion.* The reverse implication is immediate: if *j* = *g^p* and *k* = *g^q*
then `(g^p)^q = g^(pq) = (g^q)^p`, witnessing `MultDep j k` with (*q*, *p*). The
forward implication is the substantive direction. A proof strategy:

1. From a witness *jᵃ = kᵇ*, compare prime factorizations. For each prime *p*,
   `a · vₚ(j) = b · vₚ(k)`, where `vₚ` is the *p*-adic valuation. Hence the
   exponent vectors `(vₚ(j))ₚ` and `(vₚ(k))ₚ` are proportional with rational ratio
   `b/a`.
2. Proportional integer exponent vectors share a common "primitive direction":
   let `e = (eₚ)ₚ` be the componentwise gcd-reduced vector, and set *g* = ∏ₚ
   *pᵉᵖ*. Then *g* ≥ 2 (since *j* ≥ 2 ensures some `eₚ > 0`), and *j*, *k* are
   integer powers of *g*.
3. The exponents *p*, *q* are the common multipliers from step 2; positivity
   follows from *j*, *k* ≥ 2.

The crux is the integrality argument in step 2 (extracting the primitive root from
proportional valuation vectors), which is why the statement is left as a
conjecture pending a fully verified treatment. Establishing it would convert the
qualitative barrier (Theorem 5.1) into a quantitative *normal form*, giving an
explicit decision procedure for dependence and providing the precise structural
input needed for a formal statement of Cobham's theorem itself.

---

## 7. Algorithms

Although the relation `MultDep` is defined by an existential over unbounded
exponents, it is decidable, and the structure theorems give efficient procedures.

### 7.1 Deciding dependence

The naive search over (*a*, *b*) does not terminate on independent pairs. Two
correct approaches:

* **Prime-signature test (exact).** Compute the prime factorizations of *j* and
  *k*. They are dependent iff they have the *same set* of prime factors *and* the
  exponent vectors are proportional (constant ratio across all shared primes).
  This is `O(√j + √k)` for trial-division factoring, then linear in the number of
  distinct primes. It is exact and never loops.

* **Bounded log-ratio test (numeric).** Test whether `log j / log k` is close to
  a rational with small denominator via continued fractions, then *verify* a
  candidate (*a*, *b*) by exact integer comparison `jᵃ == kᵇ`. The verification
  step keeps the procedure sound despite floating-point input.

The prime-signature test is the algorithmic embodiment of Conjecture 6.1: it
finds the common root *g* explicitly when one exists.

### 7.2 Computing the common root

Given a dependent pair, the primitive root *g* is recovered as ∏ *p*^(gcd of
valuations), and the exponents *p*, *q* are each base's valuation divided by the
primitive valuation. This is the normal form posited in Conjecture 6.1.

---

## 8. Applications

* **Non-vacuity certificates for Cobham's theorem.** Any application that invokes
  Cobham's theorem must first certify that the two bases are independent. The
  barrier theorem provides instant certificates for all coprime pairs (2 & 3, 3 &
  10, 6 & 35, …), and the prime-signature test handles the general case.

* **Base-conversion complexity.** Multiplicatively dependent bases admit
  finite-state inter-conversion of representations; independent bases do not. The
  dependence relation thus classifies *which digit re-encodings are realizable by
  finite automata* — the arithmetic counterpart of the geometric "bounded
  distortion simulation" picture.

* **Diophantine sanity checks.** The relation `jᵃ = kᵇ` is the simplest nontrivial
  exponential Diophantine equation; the barrier theorem is a clean, fully verified
  fragment of the surrounding theory (Catalan/Pillai-type questions concern *near*
  misses *jᵃ − kᵇ = c*).

---

## 8.5 Worked examples

We collect concrete instances that illustrate every theorem and the decision
procedure of Section 7.

**Example A (dependent, same family).** Take *j* = 8, *k* = 32. Their
factorizations are 8 = 2³, 32 = 2⁵. The prime sets agree ({2}), and the exponent
vectors (3) and (5) are trivially proportional with ratio 5/3. The minimal
witness is therefore (*a*, *b*) = (5, 3): indeed 8⁵ = 2¹⁵ = 32³ = 32768. The
common root is *g* = 2^gcd(3,5) = 2¹ = 2, giving the normal form 8 = 2³, 32 = 2⁵.
Cobham's theorem says *nothing* separating about base 8 and base 32: a sequence
can be both 8- and 32-automatic while remaining aperiodic.

**Example B (independent, coprime).** Take *j* = 2, *k* = 3. They are coprime
(gcd = 1), so the barrier theorem (5.1) applies immediately: `¬ MultDep 2 3`. The
modular certificate (5.2) is even more direct: any 2ᵃ is even, any 3ᵇ is odd. The
prime-signature test reaches the same verdict instantly because {2} ≠ {3}.
Cobham's theorem *does* apply: no aperiodic sequence is both 2- and 3-automatic.

**Example C (independent, not coprime).** Take *j* = 12, *k* = 18. These are not
coprime — gcd(12, 18) = 6 — so the barrier theorem does not apply. Yet they are
still independent: 12 = 2²·3, 18 = 2·3². The prime sets agree ({2, 3}), but the
exponent vectors (2, 1) and (1, 2) are *not* proportional (2/1 ≠ 1/2). Hence no
witness exists and `¬ MultDep 12 18`. This example shows the barrier theorem is
sufficient but not necessary for independence: the prime-signature test is the
complete criterion.

**Example D (dependent, shared factors).** Take *j* = 1000, *k* = 100. We have
1000 = 2³·5³, 100 = 2²·5². The prime sets agree and both exponent vectors are
proportional with ratio 2/3 (i.e. (2,2) = (2/3)(3,3)). The witness is (2, 3):
1000² = 10⁶ = 100³. The common root is *g* = 2^gcd(3,2)·5^gcd(3,2) = 2·5 = 10, so
1000 = 10³, 100 = 10². This is the normal form of Conjecture 6.1 made explicit.

These four cases — same-family dependent, coprime independent, shared-factor
independent, and shared-factor dependent — exhaust the qualitative possibilities
and show why the prime-signature criterion, not coprimality alone, is the exact
test.

## 9. Discussion

The results split naturally into a *trivial* layer (reflexivity, symmetry,
powers-are-dependent), a *one substantive algebraic step* (transitivity, via
`j^(ac) = k^(bc) = l^(db)`), and the *number-theoretic obstruction* (the coprime
barrier and its 2-vs-3 specialization). The conceptual lesson is the productive
*failure* of the analytic framing: phrasing dependence as `log j / log k ∈ ℚ` is
correct but pulls in real analysis for what is, on integer bases, an elementary
multiplicative phenomenon. Recognizing this collapse to pure exponent and
divisibility arithmetic is what let every theorem land with short, elementary
proofs.

There is a complementary *geometric* view of Cobham invariance — measuring how
cheaply one computational model simulates another via prefix ultrametrics and
bounded-distortion simulations. The arithmetic obstruction proved here and that
geometric machinery are two faces of one principle: a base change is an admissible
finite-distortion simulation precisely when the bases are multiplicatively
dependent. The geometric side measures *how cheaply* a simulation runs; the
arithmetic side decides *whether one can exist at all*. The barrier theorem
delivers the second answer — a flat *no* for coprime bases.

It is worth dwelling on *why* dependence is exactly the realizability condition
for finite-state base conversion. If *j* and *k* are dependent with *jᵃ = kᵇ*,
then *a* digits in base *j* and *b* digits in base *k* both encode exactly the
same range of values (0 through *jᵃ* − 1 = *kᵇ* − 1). A finite transducer can
therefore read blocks of *a* base-*j* digits and emit blocks of *b* base-*k*
digits with bounded memory, because the block boundaries stay synchronized
forever. When the bases are independent no such synchronization exists: the ratio
of block lengths needed to align values is irrational, so any aligning transducer
would need unboundedly growing memory — precisely the failure that lets Cobham's
theorem force eventual periodicity. The relation `MultDep` is thus not an
artificial hypothesis but the exact boundary of finite-state inter-translatability.

A further methodological remark: the entire development is *constructive* and
*decidable*. Every positive theorem exhibits an explicit witness (a pair of
exponents, or a prime), and the negative results are certified by a terminating
finite computation (a modular reduction, or a prime-signature comparison). There
is no appeal to nonconstructive choice or to the deep transcendence theory that
the analytic reformulation would invite. This is what makes the theory a clean,
reusable building block: any larger formalization can call the barrier theorem as
a black box and receive a concrete certificate of independence.

---

## 10. Future work

* **Prove Conjecture 6.1.** Turning the qualitative barrier into a normal form is
  the natural next milestone; it requires the proportional-valuation integrality
  argument of Section 6.

* **Formalize Cobham's theorem itself.** With the dependence relation and its
  classification in hand, the remaining ingredients are the kernel/automaton
  formalism and the eventual-periodicity conclusion.

* **Quantitative bounds.** Make explicit the smallest witness (*a*, *b*) for a
  dependent pair as a function of *j*, *k*, and bound the automaton-size blow-up
  of finite-state base conversion for dependent bases.

---

## 11. Conclusion

We have isolated the arithmetic heart of Cobham's theorem — the multiplicative
dependence relation on bases — and given it a complete, verified treatment.
`MultDep` is an equivalence relation; powers of a base are always dependent; and,
decisively, coprime bases are never dependent, with `¬ MultDep 2 3` certifying
non-vacuity by the even-versus-odd argument. The single remaining open statement,
the common-root normal form, would upgrade the qualitative barrier into an
explicit classification and form the bridge to a full formalization of Cobham's
theorem. The overarching moral is that the wall separating base 2 from base 3 —
the wall that gives Cobham's theorem its content — is, at bottom, the elementary
fact that no power of 2 is ever odd.

---

## Appendix A. Formal statements (reference)

For completeness we list the formally verified statements, in the arithmetic
language used above.

* `MultDep j k := ∃ a b, 0 < a ∧ 0 < b ∧ jᵃ = kᵇ`.
* `multDep_refl : MultDep j j`.
* `multDep_symm : MultDep j k → MultDep k j`.
* `multDep_trans : MultDep j k → MultDep k l → MultDep j l`.
* `multDep_pow_self : 0 < m → 0 < n → MultDep (jᵐ) (jⁿ)`.
* `coprime_not_multDep : 2 ≤ j → Coprime j k → ¬ MultDep j k`.
* `not_multDep_two_three : ¬ MultDep 2 3`.
* `multDep_iff_common_root (conjecture) : 2 ≤ j → 2 ≤ k → (MultDep j k ↔ ∃ g p q, 2 ≤ g ∧ 0 < p ∧ 0 < q ∧ j = g^p ∧ k = g^q)`.
