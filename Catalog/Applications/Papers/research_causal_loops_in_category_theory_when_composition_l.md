# Periodicity of Tensor Powers in Monoidal Categories: A Witness-Based Theory of Loop-Tolerant Composition

## Abstract

We develop a self-contained theory of *periodicity* for objects of an arbitrary
monoidal category, built entirely on a concrete, witness-based notion of
isomorphism between iterated tensor powers. For an object `X` of a monoidal
category `C`, we define the right-associated `n`-fold tensor power `Xⁿ` and study
when the sequence `(Xⁿ)ₙ` repeats up to isomorphism. Our central structural
result is **shift invariance**: a periodicity witness `Xᵐ ≅ Xᵐ⁺ᵈ` located at one
height `m` transports along the tower to every greater height `m + k`, by left
whiskering with `X`. From this we derive a clean detection principle — any
isomorphism `Xᵐ ≅ Xⁿ` with `m < n` certifies periodicity with period `n − m` — and
we establish the existence, positivity, and minimality of the least period of any
periodic object. A foundational tool, the **additive comparison isomorphism**
`Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ`, lifts the schoolbook exponent law to the categorical setting
and is proved by induction using the associator and unitors. We frame the whole
development through the lens of *loop-tolerant composition*: a monoidal category is
precisely a setting in which re-association of products fails on the nose but holds
up to coherent isomorphism, and periodicity is the phenomenon of the
self-composition tower folding back on itself. The theory models, in a fully
rigorous algebraic form, the self-consistency of finite-state causal loops and the
finite-order "charges" of categorical symmetry. Every result is established
constructively and without gaps.

**Keywords.** Monoidal category, tensor power, periodicity, associator, unitor,
whiskering, minimal period, coherence, fusion rules, causal loop.

**MSC 2020.** 18M05 (Monoidal categories), 18A05 (Categories: foundations),
18M15 (Tannakian and fusion categories), 18D99.

---

## 1. Introduction

### 1.1 Motivation: controlled failure of strictness

A recurring theme across modern mathematics and theoretical physics is that the
correct notion of "sameness" is not equality but *isomorphism*, and that
fundamental algebraic laws — associativity, unitality — hold not literally but up
to canonical, coherent isomorphism. A **monoidal category** is the universal
arena for this phenomenon. It is equipped with a tensor product `⊗`, a unit object
`𝟙`, and structure isomorphisms — the associator `α` and the left/right unitors
`λ`, `ρ` — encoding the controlled failure of `(A ⊗ B) ⊗ C` to be *equal* to
`A ⊗ (B ⊗ C)`, replaced by a coherent isomorphism between them.

This paper takes that controlled failure seriously and studies its dynamical
consequence. Fix an object `X` and consider the tower of its iterated tensor
powers
```
𝟙 = X⁰,  X¹,  X²,  X³,  ...
```
In a setting where sameness is isomorphism, this tower can do something a sequence
of distinct numbers never could: it can **loop back on itself**, with a later
power becoming isomorphic to an earlier one. We call this *periodicity*, and we
give it a complete elementary theory.

### 1.2 Why periodicity matters

Periodicity of tensor powers is not an abstract curiosity; it organizes several
concrete situations.

- **Finite-order objects and categorified groups.** An object satisfying
  `Xᵈ ≅ 𝟙` is an element of finite order in the categorified group of
  invertible objects (the Picard groupoid). The smallest such `d` is its order.
- **Fusion rules in quantum field theory.** In a fusion category modelling
  anyonic excitations, tensor powers of a simple object decompose according to
  fusion rules; periodic recurrence of (the isomorphism class of) `Xⁿ` encodes
  selection rules and conserved topological charge.
- **Finite monoidal categories and the pigeonhole principle.** When only finitely
  many isomorphism classes exist, the infinite tower must repeat — periodicity is
  forced. This is the categorical pigeonhole phenomenon.
- **Self-consistent causal loops.** A finite-state process that evolves by
  repeating a single operation cannot diverge; it must return to a previously
  visited state and cycle with a definite period. Tensor-power periodicity is a
  faithful algebraic model of this closed-timelike-curve self-consistency.

### 1.3 Contributions

We make the following contributions, all developed from first principles within an
arbitrary monoidal category `C`:

1. A precise, *witness-based* formalization of periodicity: `HasPeriodAt`,
   `HasPeriod`, `IsPeriodic`, the `PeriodSet`, and the least period `minPeriod`
   (Section 3).
2. The **additive comparison isomorphism** `Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ`, lifting the exponent
   law to objects (Theorem 4.1).
3. The **shift invariance theorem**: periodicity witnesses transport upward along
   the tower (Theorem 5.1), with the corollary that loops occur arbitrarily high
   (Corollary 5.2).
4. A **detection principle**: any isomorphism `Xᵐ ≅ Xⁿ` with `m < n` implies
   periodicity with period `n − m` (Theorem 5.3).
5. The **least-period theory**: existence, characterization as a genuine period,
   positivity, and minimality (Theorem 6.1).

We deliberately restrict attention to results provable cleanly from the concrete
witness-based definition; braided/symmetric refinements, finite-skeleton
consequences, full divisibility theory of the least period, and delooping
equivalences are identified as future work (Section 8).

---

## 2. Preliminaries: monoidal categories

We recall the structures we use, fixing notation. The reader familiar with
monoidal categories may skip to Section 3.

A **category** `C` consists of objects and, between any two objects `A, B`, a set
of morphisms `A ⟶ B`, with associative composition and identity morphisms. An
**isomorphism** `A ≅ B` is a morphism with a two-sided inverse; we write `A ≅ B`
both for the data of such an isomorphism and (loosely) for the proposition that
one exists. Isomorphism is reflexive, symmetric, and transitive; we write `≪≫` for
composition of isomorphisms and `(·).symm` for inversion.

A **monoidal category** is a category `C` equipped with:

- a **tensor product** bifunctor `⊗ : C × C → C`;
- a **unit object** `𝟙`;
- a natural **associator** isomorphism
  `α_{A,B,C} : (A ⊗ B) ⊗ C ≅ A ⊗ (B ⊗ C)`;
- natural **left and right unitors**
  `λ_A : 𝟙 ⊗ A ≅ A` and `ρ_A : A ⊗ 𝟙 ≅ A`;

subject to Mac Lane's pentagon and triangle coherence axioms, which guarantee that
*all* formal diagrams built from `α`, `λ`, `ρ` commute. The only consequence of
coherence we invoke explicitly is the existence and naturality of the structure
isomorphisms themselves; we never need to manipulate the coherence diagrams
directly.

We use one further standard operation. Given a morphism or isomorphism
`f : B ≅ B'` and a fixed object `A`, **left whiskering** produces an isomorphism
`A ◁ f : A ⊗ B ≅ A ⊗ B'`. Whiskering preserves isomorphisms and is functorial; in
particular `A ◁ (g ≪≫ f)` agrees with `(A ◁ g) ≪≫ (A ◁ f)`. We write the
whiskered isomorphism abstractly as `whiskerLeftIso X e` for an isomorphism `e`.

Throughout, `C` is an arbitrary monoidal category; no braiding, symmetry,
finiteness, or skeletality is assumed unless stated.

---

## 3. Iterated tensor powers and the definition of periodicity

### 3.1 The tower of tensor powers

**Definition 3.1 (tensor power).** For an object `X` of `C`, the right-associated
`n`-fold tensor power `Xⁿ` (written `mpow X n`) is defined by recursion on `n`:
```
X⁰ = 𝟙,        Xⁿ⁺¹ = X ⊗ Xⁿ.
```

The base and step equations hold definitionally:
- `mpow_zero`: `X⁰ = 𝟙`;
- `mpow_succ`: `Xⁿ⁺¹ = X ⊗ Xⁿ`.

**Lemma 3.2 (first power).** `X¹ ≅ X`, witnessed by the right unitor
`ρ_X : X ⊗ 𝟙 ≅ X` (recall `X¹ = X ⊗ X⁰ = X ⊗ 𝟙`). We call this isomorphism
`mpowOneIso`.

**Lemma 3.3 (congruence).** Any equality of exponents `m = n` induces an
isomorphism `Xᵐ ≅ Xⁿ`, namely the transport-of-identity isomorphism
`eqToIso` along `m = n`. We call it `mpowCongr X h`. Although it is "merely" an
identity transported across an index equality, it is the essential glue that lets
us rewrite exponents inside isomorphism chains; it satisfies the expected
functoriality (composing congruences along composed equalities).

### 3.2 Periodicity, witness-based

The crux of the theory is to define periodicity *constructively*: not as an
abstract property, but as the existence of an explicit isomorphism between two
rungs of the tower.

**Definition 3.4 (periodicity witness at a height).** For natural numbers `m, d`,
the object `X` **has period `d` starting at `m`**, written `HasPeriodAt X m d`, if
there exists an isomorphism
```
Xᵐ ≅ Xᵐ⁺ᵈ.
```
Formally `HasPeriodAt X m d := Nonempty (Xᵐ ≅ Xᵐ⁺ᵈ)`.

**Definition 3.5 (period).** `X` **has period `d`**, written `HasPeriod X d`, if
`d > 0` and `HasPeriodAt X m d` holds for some `m`:
```
HasPeriod X d  :=  0 < d  ∧  ∃ m, HasPeriodAt X m d.
```

**Definition 3.6 (periodic object).** `X` **is periodic**, written `IsPeriodic X`,
if it has some positive period: `IsPeriodic X := ∃ d, HasPeriod X d`.

**Definition 3.7 (period set).** The **period set** of `X` is
`PeriodSet X := { d | HasPeriod X d } ⊆ ℕ`.

We chose the witness-based definition (an actual isomorphism, recorded as a
`Nonempty` of an iso type) rather than a bare existential over isomorphism
classes, because it makes the structural operations — whiskering, transitivity,
re-indexing — directly available in proofs while remaining equivalent to the
class-level statement.

---

## 4. The additive comparison isomorphism

Before studying loops we record the algebraic backbone of the theory: tensor
powers obey the exponent addition law, up to canonical isomorphism.

**Theorem 4.1 (additive comparison).** For every object `X` and all `m, n ∈ ℕ`,
```
Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ.
```
We denote this isomorphism `mpow_add_iso X m n`.

*Proof sketch.* Induct on `m` with `n` fixed.

- **Base `m = 0`.** We need `X⁰⁺ⁿ ≅ X⁰ ⊗ Xⁿ`, i.e. `Xⁿ ≅ 𝟙 ⊗ Xⁿ`. Rewrite the
  exponent `0 + n = n` via `mpowCongr` (Lemma 3.3), then apply the inverse left
  unitor `(λ_{Xⁿ})⁻¹ : Xⁿ ≅ 𝟙 ⊗ Xⁿ`. Composing gives the claim.
- **Step `m ↦ m+1`.** Assume the isomorphism `iso : Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ`. We must
  produce `X⁽ᵐ⁺¹⁾⁺ⁿ ≅ Xᵐ⁺¹ ⊗ Xⁿ`. First rewrite `(m+1) + n = (m + n) + 1` via
  `mpowCongr`, so that `X⁽ᵐ⁺¹⁾⁺ⁿ ≅ X ⊗ Xᵐ⁺ⁿ` (by `mpow_succ`). Left-whisker the
  inductive isomorphism by `X` to get `X ⊗ Xᵐ⁺ⁿ ≅ X ⊗ (Xᵐ ⊗ Xⁿ)`. Finally apply
  the inverse associator `(α_{X, Xᵐ, Xⁿ})⁻¹ : X ⊗ (Xᵐ ⊗ Xⁿ) ≅ (X ⊗ Xᵐ) ⊗ Xⁿ`,
  and note `(X ⊗ Xᵐ) ⊗ Xⁿ = Xᵐ⁺¹ ⊗ Xⁿ` by `mpow_succ`. Composing the three
  isomorphisms yields the result. ∎

Theorem 4.1 is the categorical lift of `xᵐ⁺ⁿ = xᵐ · xⁿ`. Its essential role is
conceptual: it certifies that the tower of powers is a genuine *exponential*
object in `C`, and it is the natural source of periodicity witnesses (any
isomorphism `Xᵈ ≅ 𝟙` immediately yields `Xᵐ⁺ᵈ ≅ Xᵐ ⊗ Xᵈ ≅ Xᵐ ⊗ 𝟙 ≅ Xᵐ`, a
period-`d` witness at every `m`).

---

## 5. Shift invariance and detection

### 5.1 The central theorem

The defining structural feature of tensor-power periodicity is that a loop, once
present at any single height, propagates up the entire tower.

**Theorem 5.1 (shift invariance of witnesses).** If `HasPeriodAt X m d`, then for
every `k ∈ ℕ`,
```
HasPeriodAt X (m + k) d.
```

*Proof sketch.* Induct on `k`.

- **Base `k = 0`.** `HasPeriodAt X (m+0) d` is `HasPeriodAt X m d`, the
  hypothesis.
- **Step `k ↦ k+1`.** By the inductive hypothesis we have an isomorphism
  `e : Xᵐ⁺ᵏ ≅ X⁽ᵐ⁺ᵏ⁾⁺ᵈ`. Left-whisker by `X`:
  `X ◁ e : X ⊗ Xᵐ⁺ᵏ ≅ X ⊗ X⁽ᵐ⁺ᵏ⁾⁺ᵈ`, i.e. `Xᵐ⁺ᵏ⁺¹ ≅ X⁽ᵐ⁺ᵏ⁺ᵈ⁾⁺¹` by
  `mpow_succ`. Re-index the right-hand exponent using `mpowCongr` and the
  arithmetic identity `(m + k + d) + 1 = m + (k + 1) + d`, obtaining
  `Xᵐ⁺⁽ᵏ⁺¹⁾ ≅ Xᵐ⁺⁽ᵏ⁺¹⁾⁺ᵈ`. This is precisely `HasPeriodAt X (m + (k+1)) d`. ∎

The proof is the entire conceptual engine of the theory distilled to one move:
*tensoring an isomorphism on the left by `X` preserves it and advances the height
by one.* Iterating advances the height arbitrarily.

### 5.2 Corollaries

**Corollary 5.2 (loops occur arbitrarily high).** If `HasPeriod X d`, then for
every `k ∈ ℕ` there exists `m ≥ k` with `HasPeriodAt X m d`.

*Proof sketch.* By definition `HasPeriod X d` provides some `m₀` with
`HasPeriodAt X m₀ d`. Apply Theorem 5.1 with shift `k` to obtain
`HasPeriodAt X (m₀ + k) d`, and note `m₀ + k ≥ k`. ∎

**Theorem 5.3 (detection principle).** If `m < n` and there exists an isomorphism
`Xᵐ ≅ Xⁿ`, then `X` is periodic, with period `n − m`.

*Proof sketch.* Set `d = n − m`; since `m < n`, `d > 0`. Rewrite the target
exponent: `n = m + (n − m)` (valid because `m < n`), so the given isomorphism
`Xᵐ ≅ Xⁿ`, composed with the congruence `mpowCongr` along `n = m + d`, yields
`Xᵐ ≅ Xᵐ⁺ᵈ`, i.e. `HasPeriodAt X m d`. Together with `d > 0` this gives
`HasPeriod X d`, hence `IsPeriodic X`. ∎

Theorem 5.3 is the practical gateway to the theory: to prove an object periodic one
need only exhibit *any* coincidence between two distinct rungs, with no need to
identify a canonical starting height — Theorem 5.1 guarantees the loop is robust.

---

## 6. The least period

A periodic object generally admits many periods; among them there is a smallest,
which serves as the object's fundamental frequency.

**Theorem 6.1 (least period).** Let `X` be periodic, witnessed by
`h : IsPeriodic X`. Then there is a natural number `minPeriod h` with the
following properties:

1. **(Specification)** `minPeriod h` is a period of `X`: `HasPeriod X (minPeriod h)`.
2. **(Minimality)** For every `d ∈ PeriodSet X`, `minPeriod h ≤ d`.
3. **(Positivity)** `0 < minPeriod h`.

*Proof sketch.* Periodicity `h` asserts the predicate `HasPeriod X (·)` holds for
some natural number. Because the natural numbers are well-ordered, the least such
number exists; we take `minPeriod h` to be it (concretely, via the constructive
least-witness operator `Nat.find` applied to `h`).

1. The least-witness operator returns a value satisfying the predicate, so
   `HasPeriod X (minPeriod h)` holds (this is `Nat.find_spec`).
2. The least-witness operator returns a *lower bound*: any `d` satisfying the
   predicate — i.e. any `d ∈ PeriodSet X` — dominates it,
   `minPeriod h ≤ d` (this is `Nat.find_min'`).
3. By (1), `HasPeriod X (minPeriod h)` holds, and by Definition 3.5 every period
   is positive; extracting the first component gives `0 < minPeriod h`. ∎

The least period is the categorical analogue of the order of a group element or
the base frequency of a vibrating string. For the unit object `𝟙` it equals `1`;
for an object satisfying `Xᵈ ≅ 𝟙` with `d` minimal, it equals `d`.

**Remark 6.2 (on divisibility).** A complete theory of the least period would show
the period set is closed under taking positive differences and hence consists
exactly of the positive multiples of `minPeriod h`, mirroring the theory of the
order of a group element. Establishing this requires closure of periods under
modular reduction (subtracting the least period from any larger one while
preserving a valid witness), which in turn needs a *cancellation*-type input not
assumed here. We therefore record only the minimality inequality (Theorem 6.1(2))
in this development and flag the full divisibility theory as future work
(Section 8).

---

## 7. Worked interpretations and examples

We illustrate the theory in concrete monoidal categories. (These are
interpretations of the abstract theorems, not additional formal results.)

**Example 7.1 (the unit object).** Take `X = 𝟙`. Then `Xⁿ ≅ 𝟙` for all `n`
(by repeated unitor isomorphisms), so `X⁰ ≅ X¹`, and Theorem 5.3 gives periodicity
with period `1`. By Theorem 6.1 the least period is `1` — the tightest possible
rhythm.

**Example 7.2 (a cyclic charge).** In the category of finite-dimensional
representations of the cyclic group `ℤ/3`, let `X` be a nontrivial
one-dimensional character. Then `X³` is the trivial representation `𝟙`, so
`X³ ≅ X⁰`. Theorem 5.3 yields periodicity with period `3`; one checks `X¹, X²`
are nontrivial, so by Theorem 6.1 the least period is exactly `3`. This is the
algebraic skeleton of three-fold colour neutrality.

**Example 7.3 (forced periodicity in finite categories).** Suppose `C` has only
finitely many isomorphism classes of objects, say `N` of them. The infinite
sequence `X⁰, X¹, …, X^N` has `N + 1` terms drawn from `N` classes, so by the
pigeonhole principle two are isomorphic: `Xⁱ ≅ Xʲ` for some `i < j ≤ N`. By
Theorem 5.3, `X` is periodic with period `j − i ≤ N`. Thus *every* object of a
finite monoidal category is periodic, with least period at most `N`. This is the
categorical statement that a finite-state self-composition must loop.

**Example 7.4 (causal-loop reading).** Interpret `Xⁿ` as the state of a closed,
finite, deterministic process after `n` repetitions of a single fixed operation
"tensor with `X`." Example 7.3 says the process cannot escape to infinitely many
states; it must return to a previously visited state and thereafter cycle.
Theorem 5.1 says the cycle, once entered, is permanent (the loop reappears at every
later step), and Theorem 6.1 names the cycle length. This is a faithful algebraic
model of a self-consistent closed timelike curve: the system loops back, and the
least period is the length of the loop it is bound to.

---

## 8. Discussion and future work

### 8.1 Design choices

The witness-based definition (Definitions 3.4–3.6) is the load-bearing decision in
this development. By packaging periodicity as the existence of an explicit
isomorphism between rungs, we make the proofs of shift invariance and detection
short and structural — they manipulate isomorphisms directly via whiskering,
composition, and re-indexing congruences — while remaining logically equivalent to
the isomorphism-class statement. The right-associated convention for `Xⁿ` makes
the recursion `Xⁿ⁺¹ = X ⊗ Xⁿ` definitional, which is why left whiskering by `X` is
exactly the "advance the height by one" operation that drives Theorems 4.1 and 5.1.

### 8.2 Future directions

The following are natural, falsifiable extensions of the present theory.

- **Full divisibility theory of the least period.** Show `PeriodSet X` is closed
  under positive differences, hence equals the set of positive multiples of
  `minPeriod h`. This requires closure of witnesses under modular reduction, e.g.
  a cancellation hypothesis on `⊗`.
- **Braided and symmetric refinements.** In a braided monoidal category, tensor
  powers carry a `ℤ/n` (or symmetric-group) action; relate periodicity to the
  representation theory of these actions and to the braid-group symmetry of `Xⁿ`.
- **Finite/fusion category consequences.** Make Example 7.3 a formal theorem
  (every object of a finite or fusion category is periodic with least period
  bounded by the number of simple objects), and connect the period to the order of
  `[X]` in the Grothendieck ring.
- **Delooping and Picard groupoids.** For invertible `X`, identify the least
  period with the order of `[X]` in the Picard group and study the delooping of
  the resulting `ℤ/d`-grading.
- **Quantitative bounds for causal loops.** Following the broader "causal loops"
  programme, prove that the minimal consistent period of a finite-state loop is
  bounded by its state count, and characterize the spectrum of attainable periods
  as the cycle lengths of the eventual permutation on the periodic core.

### 8.3 Conclusion

We have given a complete elementary theory of when the self-composition tower of
an object in a monoidal category loops back on itself. From the single principle
that left whiskering preserves isomorphisms and advances the height, we obtained
the additive comparison law, the shift invariance of periodicity witnesses, a
robust detection criterion, and a well-defined, positive, minimal period. The
theory is small, self-contained, and faithful to the "controlled failure of
strictness" that defines monoidal categories — and it offers a precise algebraic
model for the self-consistent loops that arise in symmetry, fusion, and the
physics of finite causal cycles.

---

## Appendix A. Glossary of constructions

- `mpow X n` (`Xⁿ`): right-associated `n`-fold tensor power, `X⁰ = 𝟙`,
  `Xⁿ⁺¹ = X ⊗ Xⁿ`.
- `mpowOneIso X`: isomorphism `X¹ ≅ X` via the right unitor `ρ_X`.
- `mpowCongr X h`: isomorphism `Xᵐ ≅ Xⁿ` induced by an exponent equality `m = n`.
- `mpow_add_iso X m n`: additive comparison isomorphism `Xᵐ⁺ⁿ ≅ Xᵐ ⊗ Xⁿ`.
- `HasPeriodAt X m d`: existence of `Xᵐ ≅ Xᵐ⁺ᵈ`.
- `HasPeriod X d`: `0 < d` and `HasPeriodAt X m d` for some `m`.
- `IsPeriodic X`: `HasPeriod X d` for some `d`.
- `PeriodSet X`: `{ d | HasPeriod X d }`.
- `minPeriod h`: least period of a periodic object (well-ordering of ℕ).

## Appendix B. Logical dependency map

```
mpow, mpow_zero, mpow_succ        (Definition 3.1)
   │
   ├── mpowOneIso  (ρ_X)          (Lemma 3.2)
   ├── mpowCongr   (eqToIso)      (Lemma 3.3)
   │       │
   │       └── mpow_add_iso       (Theorem 4.1)   [uses λ, α, whiskering]
   │
HasPeriodAt / HasPeriod / IsPeriodic / PeriodSet   (Definitions 3.4–3.7)
   │
   ├── HasPeriodAt.shift          (Theorem 5.1)   [uses whiskering, mpowCongr]
   │       └── HasPeriod.exists_witness_ge   (Corollary 5.2)
   │
   ├── isPeriodic_of_iso_lt       (Theorem 5.3)   [uses mpowCongr]
   │
   └── minPeriod, minPeriod_spec, minPeriod_le, minPeriod_pos
                                  (Theorem 6.1)   [uses well-ordering Nat.find]
```
