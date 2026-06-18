# Provability Logic as a Fixed-Point Theory: The Order-Theoretic Core of Gödel–Löb and a Graded Second Incompleteness Theorem

## Abstract

We develop the Gödel–Löb provability logic **GL** entirely as a theory of
ordered algebraic structures, isolating its order-theoretic core in a single
typeclass — the **Gödel–Löb algebra** (also known as a Magari or diagonalizable
algebra). A Gödel–Löb algebra is a Heyting algebra `H` equipped with a unary
*provability operator* `□` satisfying three axioms: normality of the top
(`□⊤ = ⊤`), normality over meets (`□(a ⊓ b) = □a ⊓ □b`), and **Löb's axiom**
`□(□a ⇨ a) ≤ □a`. From these three axioms alone we derive the full structural
skeleton of GL: the normal modal distribution law `□(a ⇨ b) ≤ □a ⇨ □b`, the
transitivity (axiom 4) `□a ≤ □□a`, the equality form of Löb's axiom
`□(□a ⇨ a) = □a`, **Löb's rule** (`□a ≤ a ⟹ a = ⊤`), an algebraic Gödel Second
Incompleteness Theorem (`□⊥ ≠ ⊤ ⟹ □(□⊥ ⇨ ⊥) ≠ ⊤`), and a general
**uniqueness theorem for modalised fixed points** which subsumes the classical
de Jongh–Sambin theorem and a two-parameter generalisation. We then exhibit a
concrete, consistent model — the well-founded frame `(ℕ, >)` realised on the
Boolean algebra `Set ℕ` — in which everything is computed explicitly: the
iterated falsity satisfies `□ⁿ⊥ = {0, 1, ..., n−1}`, these consistency
strengths form a strictly increasing chain, and a **graded Second Incompleteness
Theorem** holds: for every `n`, the `n`-fold consistency statement is unprovable.
The result is a self-contained, computational refinement of Gödel's single
incompleteness phenomenon into a strictly ordered, infinite spectrum.

**Keywords:** provability logic, Gödel–Löb logic, Löb's theorem, Magari algebra,
diagonalizable algebra, fixed-point theorem, Gödel incompleteness,
well-founded frame, Heyting algebra, modal logic.

---

## 1. Introduction

Provability logic studies the modal operator `□`, read "it is provable that,"
as it behaves inside sufficiently strong arithmetical theories such as Peano
Arithmetic. Solovay's celebrated arithmetical completeness theorem (1976)
identifies the modal logic of provability with the system **GL** (for
Gödel–Löb), axiomatised by the normal modal logic **K** together with **Löb's
axiom** `□(□A → A) → □A`. The single most surprising feature of GL is that it
is *not* about possibility and necessity in the usual sense: its frames are the
*converse-well-founded transitive* relations, and its defining law encodes the
diagonal argument behind Gödel's incompleteness theorems.

The purpose of this work is to strip GL down to its algebraic, order-theoretic
essentials. We isolate a typeclass `GLOperator` — a Heyting algebra with a box
satisfying three axioms — and show that an entire hierarchy of structural
theorems, culminating in a *graded* version of Gödel's Second Incompleteness
Theorem, follows from this minimal data. The development has two halves:

1. **The abstract core** (Section 3): every algebraic consequence of the three
   axioms, proved generically. The central organising insight is that
   *uniqueness of modalised fixed points is not a fixed-point phenomenon at all;
   it is Löb's rule applied to a biconditional.*

2. **A concrete consistent model** (Section 4): the frame `(ℕ, >)`, which
   witnesses that the axioms are non-vacuous and in which every quantity admits
   an explicit closed form, yielding the graded incompleteness hierarchy.

All results have been formalised and machine-checked. We present the
mathematical content with full statements and proof sketches; the prose here is
self-contained and may be read without reference to the formalisation.

---

## 2. Preliminaries: Heyting algebras and the box

We work in a **Heyting algebra** `H`: a bounded lattice `(H, ⊓, ⊔, ⊥, ⊤, ≤)`
equipped with a relative pseudocomplement (Heyting implication) `⇨` characterised
by the adjunction

```
c ⊓ a ≤ b   ⟺   c ≤ (a ⇨ b).        (Heyting adjunction)
```

We freely use the standard consequences: `a ≤ (b ⇨ a)` (weakening),
`(a ⇨ b) ⊓ a ≤ b` (modus ponens), `a ≤ b ⟺ (a ⇨ b) = ⊤`, and monotonicity of
`⊓` and `⇨` in the appropriate arguments. Boolean algebras (for example,
`Set X` with `⊓ = ∩`, `⊔ = ∪`, `a ⇨ b = aᶜ ∪ b`) are Heyting algebras, and our
concrete model lives in one.

We write the **biconditional** `a ⇔ b := (a ⇨ b) ⊓ (b ⇨ a)` and record the
fundamental fact

```
a ⇔ b = ⊤   ⟺   a = b.            (biconditional/equality)
```

### Definition 2.1 (Gödel–Löb algebra / `GLOperator`)

A **Gödel–Löb algebra** is a Heyting algebra `H` together with a unary operator
`□ : H → H` satisfying:

- **(B⊤)** `□⊤ = ⊤`;
- **(B⊓)** `□(a ⊓ b) = □a ⊓ □b` for all `a, b`;
- **(Löb)** `□(□a ⇨ a) ≤ □a` for all `a`.

We call `□a` the *provability* of `a`. The pair `(H, □)` is also known in the
literature as a *Magari algebra* or *diagonalizable algebra*.

The algebra is **consistent** if `□⊥ ≠ ⊤`.

Note that axioms (B⊤) and (B⊓) are exactly the algebraic content of the normal
modal logic **K**; (Löb) is the single additional axiom defining GL.

---

## 3. The abstract core

Throughout this section `(H, □)` is an arbitrary Gödel–Löb algebra.

### 3.1 Monotonicity and normal distribution

#### Lemma 3.1 (Monotonicity of the box)

*If `a ≤ b` then `□a ≤ □b`.*

**Proof.** `a ≤ b` gives `a ⊓ b = a`, hence
`□a = □(a ⊓ b) = □a ⊓ □b ≤ □b` by (B⊓). ∎

#### Lemma 3.2 (Normal distribution, axiom K)

*`□(a ⇨ b) ≤ □a ⇨ □b`.*

**Proof.** By modus ponens `(a ⇨ b) ⊓ a ≤ b`, so by Lemma 3.1 and (B⊓),
`□(a ⇨ b) ⊓ □a = □((a ⇨ b) ⊓ a) ≤ □b`. The Heyting adjunction then yields
`□(a ⇨ b) ≤ □a ⇨ □b`. ∎

#### Lemma 3.3 (Box congruence)

*`□(a ⇔ b) ≤ (□a ⇔ □b)`, and more generally for any constants the operation
`p ↦ □p` is a congruence: provable equivalence of inputs yields provable
equivalence of outputs.*

**Proof.** Apply Lemma 3.2 to each direction of `⇔` and combine with (B⊓):
`□(a ⇔ b) = □(a ⇨ b) ⊓ □(b ⇨ a) ≤ (□a ⇨ □b) ⊓ (□b ⇨ □a) = (□a ⇔ □b)`. ∎

### 3.2 The equality form of Löb and Löb's rule

#### Theorem 3.4 (Löb equality, `loeb_eq`)

*`□(□a ⇨ a) = □a`.*

**Proof.** The inequality `≤` is (Löb). For `≥`: weakening gives
`a ≤ (□a ⇨ a)`, so Lemma 3.1 gives `□a ≤ □(□a ⇨ a)`. ∎

#### Theorem 3.5 (Löb's rule, `loeb_rule`)

*If `□a ≤ a` then `a = ⊤`.*

**Proof.** `□a ≤ a` is equivalent to `(□a ⇨ a) = ⊤`. Applying `□` and (B⊤),
`□(□a ⇨ a) = □⊤ = ⊤`. By (Löb), `⊤ = □(□a ⇨ a) ≤ □a`, so `□a = ⊤`. Then
`⊤ = □a ≤ a` gives `a = ⊤`. ∎

Löb's rule is the engine of the entire theory; nearly every theorem below is an
application of it. Conceptually it asserts that *the only elements which are true
whenever provable are the trivially true ones.*

#### Corollary 3.6 (Self-provable elements, `box_fixedPoint_eq_top`)

*If `□a = a` then `a = ⊤`. In particular `⊤` is the unique fixed point of `□`.*

**Proof.** `□a = a` implies `□a ≤ a`; apply Theorem 3.5. ∎

### 3.3 Transitivity is derivable

A distinctive feature of GL is that the transitivity axiom 4, `□a ≤ □□a`, need
not be assumed: it follows from Löb (Magari 1975; de Jongh).

#### Theorem 3.7 (Transitivity, `box_transitive`)

*`□a ≤ □□a`.*

**Proof sketch.** Apply (Löb) to the auxiliary element `b := a ⊓ □a`. Using
(B⊓), `□b = □a ⊓ □□a`, and one checks via the normal distribution Lemma 3.2 and
the Heyting calculus that `□a ≤ □(□b ⇨ b)`; Löb's axiom `□(□b ⇨ b) ≤ □b`
together with `□b ≤ □□a` then yields `□a ≤ □□a`. The mechanism is the standard
GL derivation of axiom 4 from Löb's axiom, carried out in the Heyting calculus
rather than the Hilbert calculus. ∎

### 3.4 Gödel's Second Incompleteness Theorem

The statement `□⊥` reads "falsehood is provable," i.e. "the system is
inconsistent"; its negation `Con := □⊥ ⇨ ⊥` is the **consistency statement**.

#### Theorem 3.8 (Algebraic Gödel II, `consistency_unprovable`)

*If `(H, □)` is consistent (`□⊥ ≠ ⊤`), then consistency is unprovable:*
*`□(□⊥ ⇨ ⊥) ≠ ⊤`.*

**Proof.** Apply (Löb) with `a = ⊥`: `□(□⊥ ⇨ ⊥) ≤ □⊥`. If
`□(□⊥ ⇨ ⊥) = ⊤`, then `□⊥ = ⊤`, contradicting consistency. ∎

This is the abstract form of Gödel's Second Incompleteness Theorem: the entire
syntactic apparatus (Gödel numbering, the diagonal lemma, the derivability
conditions) has been compressed into Löb's axiom, which is taken as primitive.

### 3.5 The fixed-point theory

We now turn to the cycle's central contribution: a uniform treatment of
self-referential definitions.

A function `F : H → H` is **modalised** if its variable occurs only under the
box, formalised by the requirement that it respects boxed equivalence:

```
□(a ⇔ b) ≤ (F a ⇔ F b)   for all a, b.     (modalised)
```

By Lemma 3.3, any composition built from constants, `⊓`, `⊔`, `⇨`, and `□`, in
which the variable always appears under a `□`, is modalised.

#### Theorem 3.9 (Uniqueness of modalised fixed points, `modalised_fixedPoint_unique`)

*Let `F` be modalised. If `a = F a` and `b = F b`, then `a = b`.*

**Proof.** Substituting the fixed-point equations into (modalised),

```
□(a ⇔ b) ≤ (F a ⇔ F b) = (a ⇔ b).
```

This has the form `□x ≤ x` with `x = a ⇔ b`. By Löb's rule (Theorem 3.5),
`x = ⊤`, i.e. `a ⇔ b = ⊤`, i.e. `a = b`. ∎

This is the conceptual heart of the development: **fixed-point uniqueness in GL
is Löb's rule applied to a biconditional.** No explicit computation of `□a` is
needed, which is exactly why the argument generalises without friction.

#### The canonical fixed point

Consider the prototypical equation `p = (□p ⇨ c)`.

#### Theorem 3.10 (Existence and explicit solution, `glFix`)

*Define `glFix c := □c ⇨ c`. Then:*

1. *`glFix c` solves the equation: `glFix c = □(glFix c) ⇨ c`;*
2. *its provability is `□(glFix c) = □c`.*

**Proof.** By Theorem 3.4, `□(glFix c) = □(□c ⇨ c) = □c`, which is (2). Then
`□(glFix c) ⇨ c = □c ⇨ c = glFix c`, which is (1). ∎

#### Theorem 3.11 (de Jongh–Sambin uniqueness, `glFix_unique`)

*If `p = □p ⇨ c`, then `p = glFix c = □c ⇨ c`.*

**Proof.** The map `F(p) = □p ⇨ c` is modalised (its variable occurs only under
`□`), so by Theorem 3.9 any two solutions coincide; `glFix c` is one solution by
Theorem 3.10. ∎

#### Theorem 3.12 (Two-parameter uniqueness, `glFix_two_param_unique`)

*Fix `c, d ∈ H`. If `p = d ⊓ (□p ⇨ c)`, then `p` is uniquely determined.*

**Proof.** The map `F(p) = d ⊓ (□p ⇨ c)` is modalised: the parameters `c, d` are
constants and `p` appears only inside `□p`. Apply Theorem 3.9. ∎

**Remark (a failed approach, and why the right one generalises).** A first
attempt at Theorem 3.12 tried to imitate the explicit one-step calculation that
proves Theorem 3.11 by computing `□p` for a fixed point `p` and matching it to
`□c`. This breaks down: the extra meet with `d` perturbs the lower bound `c ≤ p`
used implicitly in that computation, and the explicit calculation no longer
closes. The biconditional/Löb's-rule engine of Theorem 3.9 *never computes `□p`*
— it only uses that `p` occurs boxed — which is precisely why it generalises to
arbitrarily complicated modalised contexts at no extra cost.

### 3.6 What Löb forbids: the box is never the identity

#### Theorem 3.13 (`box_ne_id`)

*In any nontrivial Gödel–Löb algebra (`⊥ ≠ ⊤`), the box is not the identity:*
*there exists `a` with `□a ≠ a`.*

**Proof.** If `□a = a` for all `a`, then by Corollary 3.6 every `a` equals `⊤`,
contradicting `⊥ ≠ ⊤`. ∎

#### Proposition 3.14 (The identity operator violates Löb, `identity_violates_loeb`)

*On `H = Set ℕ`, the identity operator `□a := a` fails Löb's axiom. Explicitly,
at `S = ∅`,*

```
id(id ∅ ⇨ ∅) = (∅ ⇨ ∅) = univ ⊄ ∅ = id ∅,
```

*so `□(□S ⇨ S) ≤ □S` fails.*

This pinpoints Löb's axiom as exactly the constraint forbidding the naive
"provable = true" operator. The irreducible gap between provability and truth is
a logical necessity, not an arithmetical accident.

---

## 4. A concrete consistent model: the frame `(ℕ, >)`

The abstract theory is vacuous unless the axioms have a consistent model. We now
exhibit one in which, moreover, *every quantity is explicitly computable*.

### Definition 4.1 (`natBox`, `NatGL`)

On the Boolean algebra `H = Set ℕ` (with `⊓ = ∩`, `⊔ = ∪`, `S ⇨ T = Sᶜ ∪ T`,
`⊥ = ∅`, `⊤ = ℕ`), define

```
natBox S := { n : ℕ | ∀ m, m < n → m ∈ S }.
```

Read: *world `n` proves `S` iff every strictly smaller world satisfies `S`.*
This is the box of the (converse) well-founded frame `(ℕ, >)`: the accessible
worlds from `n` are the finitely many `m < n`.

### Theorem 4.2 (`NatGL` is a Gödel–Löb algebra)

*`(Set ℕ, natBox)` satisfies (B⊤), (B⊓), and (Löb).*

**Proof.**
- **(B⊤)** `natBox univ = univ`: every smaller world lies in `univ`.
- **(B⊓)** `natBox (A ∩ B) = natBox A ∩ natBox B`: "all smaller worlds in
  `A ∩ B`" iff "all smaller in `A`" and "all smaller in `B`".
- **(Löb)** `natBox(natBox S ⇨ S) ⊆ natBox S`. Fix `n` in the left side; we show
  every `k < n` lies in `S` by strong induction on `k`. The induction hypothesis
  gives `k ∈ natBox S`; the membership hypothesis at `n` (instantiated at `k`)
  then forces `k ∈ S`. This strong induction is the algebraic image of the
  converse-well-foundedness of `(ℕ, >)`, the frame condition that validates Löb.
∎

Consequently **all** theorems of Section 3 — Löb's rule, transitivity, the
fixed-point uniqueness theorems, and algebraic Gödel II — hold in `NatGL`.

### Theorem 4.3 (Consistency, `natGL_consistent`)

*`NatGL` is consistent: `natBox ∅ = {0} ≠ univ`, hence `□⊥ ≠ ⊤`.*

**Proof.** `n ∈ natBox ∅` iff every `m < n` lies in `∅`, which holds iff there
is no such `m`, i.e. `n = 0`. So `natBox ∅ = {0}`, and `1 ∉ {0}`. ∎

By Theorem 3.8, `NatGL` cannot prove its own consistency:
`natBox(natBox ∅ ⇨ ∅) ≠ univ` — Gödel's Second Theorem, concretely.

### 4.1 The provability-rank computation

The model's signature feature is the following closed form.

#### Theorem 4.4 (Iterated falsity, `natBox_iterate_eq_Iio`)

*For every `k`, `natBoxᵏ(∅) = {0, 1, ..., k−1} = Iio k`.*

**Proof.** Induction on `k`. Base: `natBox⁰ ∅ = ∅ = Iio 0`. Step: assume
`natBoxᵏ ∅ = Iio k`. Then

```
natBoxᵏ⁺¹ ∅ = natBox (Iio k) = { n | ∀ m < n, m < k } = { n | n ≤ k } = Iio (k+1),
```

using the elementary equivalence `(∀ m < n, m < k) ⟺ n ≤ k`. ∎

Thus the *provability rank* of `□ᵏ⊥` — the depth of nesting of its provability
claims — is not extra structure: in the canonical model it is **the identity
function on `ℕ`**. The frame depth and the iteration index coincide exactly.

### 4.2 The strictly increasing consistency spectrum

#### Theorem 4.5 (Strict monotonicity, `consistency_strength_strictMono`)

*The map `k ↦ natBoxᵏ(∅)` is strictly monotone:*
*`m < n ⟹ natBoxᵐ(∅) ⊊ natBoxⁿ(∅)`, and none equals `univ`.*

**Proof.** By Theorem 4.4 the map is `k ↦ Iio k`, and `Iio` is strictly
monotone under `⊆` (`m < n ⟹ Iio m ⊊ Iio n`). No `Iio k` equals `ℕ` since
`k ∈ ℕ \ Iio k`. ∎

So `∅ ⊊ {0} ⊊ {0,1} ⊊ {0,1,2} ⊊ ⋯` is an infinite, strictly increasing chain of
consistency strengths, climbing without bound yet never reaching `⊤`.

### 4.3 A graded Second Incompleteness Theorem

#### Theorem 4.6 (Graded Gödel II, `godel_hierarchy`)

*For every `k`, the `(k+1)`-fold consistency statement is unprovable in `NatGL`:*

```
natBox( natBoxᵏ⁺¹(∅) ⇨ ∅ ) ≠ univ.
```

**Proof.** By Theorem 4.4, `natBoxᵏ⁺¹ ∅ = Iio (k+1)`, which contains `k`. Hence
its consistency `(Iio (k+1) ⇨ ∅) = (Iio (k+1))ᶜ` excludes `k`. Evaluate the box
at world `k+1`: since `k < k+1` and `k ∉ (Iio(k+1))ᶜ`, world `k+1` fails to be
in `natBox((Iio(k+1)) ⇨ ∅)`. Therefore the box is not all of `ℕ`. ∎

This refines Gödel's single Second Incompleteness Theorem
(`natGL_godel_second`, the `k = 0` case) into a strictly increasing family of
unprovable consistency strengths indexed by `ℕ`. The system cannot prove its own
consistency; nor the consistency of "itself plus that consistency"; nor of *that*
extension; and so on, forever, each statement strictly stronger and provably
beyond reach.

**Remark (the level 0 is genuinely excluded).** `natBox⁰ ∅ = ∅`, whose
consistency `∅ ⇨ ∅ = univ` *is* provable. Only the *nontrivial* strengths
`natBoxᵏ⁺¹ ∅` escape provability; the hierarchy begins exactly where the
content begins.

---

## 5. Algorithms

The model is fully computable on bounded universes, enabling exhaustive
verification of every theorem.

### Algorithm A: Iterated provability box on a bounded universe

To verify Theorems 4.4–4.6 numerically, represent a "statement" as a subset of
`{0, 1, ..., N−1}` and implement `natBox` directly. Iterating from `∅` produces
the predicted initial segments. Complexity: each `natBox` application is
`O(N²)` naively (or `O(N)` with a running prefix-conjunction); `k` iterations
cost `O(kN)` with the optimised form.

### Algorithm B: Exhaustive Löb-axiom verifier

On a finite Boolean algebra `Set({0,...,N−1})` (which has `2^N` elements),
enumerate all subsets and check `natBox(natBox S ⇨ S) ⊆ natBox S` for each.
Complexity `O(2^N · N)`. This certifies (Löb) on the finite truncation and, by
the same enumeration with `□ := id`, exhibits the failure of Proposition 3.14.

### Algorithm C: Fixed-point solver and uniqueness checker

For the canonical equation `p = □p ⇨ c`, compute the predicted solution
`glFix c = □c ⇨ c`, verify it is a fixed point, and confirm uniqueness by
brute-force search over all `2^N` candidate subsets. The two-parameter equation
`p = d ⊓ (□p ⇨ c)` is checked the same way, confirming Theorem 3.12.

---

## 6. Applications and discussion

**Foundations.** The development gives a clean, axiom-economical route to
Gödel's Second Incompleteness Theorem. By taking Löb's axiom as the primitive
(rather than deriving it from the Hilbert–Bernays–Löb derivability conditions),
the entire incompleteness phenomenon becomes a two-line consequence of an order
inequality. The graded hierarchy (Theorem 4.6) makes precise the intuition that
incompleteness is not a single barrier but an infinite ascending sequence of
them — a spectrum of consistency strengths, each strictly stronger and each
unprovable.

**Fixed-point logic.** Theorem 3.9 unifies the existence/uniqueness theory of
self-referential sentences. The de Jongh–Sambin theorem, normally proved by an
explicit syntactic fixed-point construction, becomes a corollary of Löb's rule
applied to a biconditional. The two-parameter generalisation (Theorem 3.12)
demonstrates the robustness of this viewpoint: arbitrarily complex modalised
contexts inherit uniqueness for free.

**Modal logic and frames.** The concrete model `(ℕ, >)` exhibits the algebraic
shadow of the Kripke-semantic fact that GL is the logic of converse-well-founded
transitive frames. The choice of order is essential: `(ℕ, <)` is *not* converse
well-founded and fails Löb's axiom, while `(ℕ, >)` works precisely because every
descending chain terminates. The strong induction proving (Löb) in Theorem 4.2
is exactly the well-foundedness of `>`.

**Temporal reading.** Interpreting the world index `k` as a time stamp or a
proof stage, `□ᵏ⊥ = Iio k` says that the `k`-fold inconsistency statement is
"true at" exactly the first `k` stages. The qualitative statement "consistency is
unprovable at every time" sharpens to the quantitative graded hierarchy.

---

## 7. Future directions

*(Reproduced from the Phase A research notes.)*

This cycle rebuilt and deepened the order-theoretic core of Gödel–Löb provability
logic, supplying the missing `GLOperator` foundation — a Heyting algebra with a
normal box satisfying Löb's axiom `□(□a ⇨ a) ≤ □a` — and deriving from those
three axioms the full structural skeleton of GL: transitivity (derivable from
Löb), the equality form `□(□a ⇨ a) = □a`, Löb's rule, the "only self-provable
element is `⊤`" corollary, and Gödel's Second Incompleteness Theorem.

The structural insight that drove the deepening is that **uniqueness of
modalised fixed points is not a fixed-point miracle — it is Löb's rule applied
to a biimplication.** After proving the single congruence lemma
`□(a ⇨ b) ≤ □a ⇨ □b`, the biimplication `a ⇔ b` becomes a box-congruence for any
operator in which the variable occurs only under `□`; at two fixed points this
yields `□(a ⇔ b) ≤ (a ⇔ b)`, and Löb's rule forces `a ⇔ b = ⊤`, i.e. `a = b`.
This was packaged as the general theorem `modalised_fixedPoint_unique`,
recovering the classical de Jongh–Sambin uniqueness for the canonical map
`p ↦ □p ⇨ c` (with the explicit solution `glFix c = □c ⇨ c` and provability
`□(glFix c) = □c`) and promoting the previously conjectured two-parameter
uniqueness for `p ↦ d ⊓ (□p ⇨ c)` from conjecture to theorem by composing three
congruence lemmas.

What failed is instructive. A first attempt at two-parameter uniqueness tried to
re-run the one-step `□a = □c` computation that works for the single-parameter
case; it broke because the extra meet `d` perturbs the lower bound `c ≤ a`. The
biconditional/Löb-rule engine sidesteps computing `□a` at all, which is exactly
why it generalises. A complementary sharpening: `box_ne_id` shows the provability
operator is never the identity in a nontrivial algebra, and
`identity_violates_loeb` exhibits the explicit failure of Löb for the naïve
"provable = true" operator on `Set ℕ` at `S = ∅`. Löb's axiom is precisely what
forbids the operator that would make every sentence its own fixed point.

Concrete next steps include: extending the abstract core to polymodal provability
algebras (GLP) with infinitely many boxes; relating the graded hierarchy to
proof-theoretic ordinal analysis (the consistency strengths `□ⁿ⊥` as an
order-type-`ω` reflection ladder); proving an algebraic analogue of the
de Jongh–Sambin–Bernardi *explicit* fixed-point theorem for arbitrary modalised
contexts; and connecting the `(ℕ, >)` model to the Kripke completeness of GL via
the box-as-frame-operator dictionary.

---

## 8. Conclusion

From three axioms for a provability operator on a Heyting algebra, we derived the
complete structural skeleton of Gödel–Löb logic and recovered Gödel's Second
Incompleteness Theorem as a two-line argument. The conceptual centerpiece is the
recognition that fixed-point uniqueness in GL is Löb's rule applied to a
biconditional — an observation that subsumes the de Jongh–Sambin theorem and its
two-parameter generalisation under one principle. In the concrete model `(ℕ, >)`
everything becomes computable: `□ⁿ⊥ = {0, ..., n−1}`, the consistency strengths
form a strictly increasing chain, and Gödel's single incompleteness phenomenon
unfolds into an infinite, strictly ordered spectrum of unprovable truths.

---

## References

- G. Boolos, *The Logic of Provability*, Cambridge University Press, 1993.
- R. Solovay, "Provability interpretations of modal logic," *Israel J. Math.*
  25 (1976), 287–304.
- M. H. Löb, "Solution of a problem of Leon Henkin," *J. Symbolic Logic* 20
  (1955), 115–118.
- R. Magari, "The diagonalizable algebras," *Boll. Un. Mat. Ital.* 12 (1975).
- D. de Jongh and G. Sambin, on the explicit fixed-point theorem for GL.
- K. Gödel, "Über formal unentscheidbare Sätze...," *Monatshefte für Mathematik
  und Physik* 38 (1931), 173–198.
