# The Eckmann–Hilton Equational Theory *is* Commutative Monoids

### A formal two-way bridge between interchanging unital operations and commutative monoids, with a rigidity theorem

---

## Abstract

The Eckmann–Hilton argument shows that two unital binary operations on a
set, sharing a common unit and satisfying the interchange law, are forced
to coincide and to be commutative and associative. This is the algebraic
core of the classical theorem that the second homotopy group `π₂` of a
space is abelian. The usual presentation stops at the *collapse*: it proves
that the two operations agree and that the resulting single operation is
commutative. This paper records the sharper statement that closes the loop.
We package the equational consequences of the interchange law into a bona
fide commutative-monoid structure, prove the converse that every
commutative monoid furnishes Eckmann–Hilton data, and conclude that the two
equational theories **coincide exactly**: an operation-with-unit is the
vertical product of some Eckmann–Hilton structure if and only if it is the
multiplication of a commutative monoid. We further prove a *rigidity*
theorem: the vertical operation alone determines the unit and the
horizontal operation, so the apparent two-dimensional data carries no
information beyond its one-dimensional shadow. As corollaries we obtain a
clean algebraic form of "`π₂` is abelian" and a one-line criterion: a
monoid admitting a second compatible unital operation is automatically
commutative. All results have been formalized and machine-checked with no
unproven assumptions.

**Keywords.** Eckmann–Hilton argument, interchange law, commutative monoid,
medial law, higher homotopy, double loop space, rigidity, equational theory.

---

## 1. Introduction

### 1.1 The classical argument

Let `X` be a set carrying two binary operations `·` and `∗`, each with the
same two-sided unit `1`, and suppose they satisfy the **interchange law**

```
(a ∗ b) · (c ∗ d) = (a · c) ∗ (b · d)      for all a, b, c, d ∈ X.      (★)
```

Eckmann and Hilton (1962) observed that (★), together with the four unit
laws, forces:

- **(EH1)** `a · b = a ∗ b` (the operations coincide);
- **(EH2)** `a · b = b · a` (commutativity);
- **(EH3)** `(a · b) · c = a · (b · c)` (associativity).

The classical application is topological. On a double loop space, vertical
and horizontal composition of 2-cells share the constant 2-cell as unit
and satisfy (★); the argument then yields the commutativity of the second
homotopy group `π₂`.

### 1.2 The gap this paper closes

The conclusions (EH1)–(EH3) describe the *consequences* of (★) but stop
short of identifying the algebraic theory they generate. Three natural
questions remain:

1. **What is the precise theory?** (EH1)–(EH3) certainly give *a*
   commutative monoid, but is the interchange theory *exactly* the
   commutative-monoid theory, or could it be strictly stronger (forcing,
   say, idempotence or cancellation) or, read the other way, strictly
   weaker?
2. **Is the correspondence two-way?** Does every commutative monoid arise
   from interchange data?
3. **How much data is in the structure?** Eckmann–Hilton data names two
   operations and a unit. Are these independent, or determined by one
   another?

This paper answers all three. The interchange theory is *precisely* the
commutative-monoid theory (Theorem 4.1); the correspondence is a genuine
round trip (Definitions 3.1, 3.2); and the structure is rigid — the
vertical operation determines the rest (Theorem 5.1).

### 1.3 Foundations reused

Throughout we build on an abstract engine that isolates the purely
equational core of the argument. That engine provides a data structure
`EckmannHiltonData X` and three lemmas — `same_op` (EH1), `comm` (EH2),
`assoc` (EH3) — proved once and for all from (★). The present development
imports those lemmas verbatim and never reproves them; our contribution is
the bridge to commutative monoids, the equivalence of theories, the
rigidity theorem, and the corollaries. All statements are formalized and
carry complete, machine-checked proofs; the proof *sketches* below describe
the mathematical content rather than the formal scripts.

---

## 2. Definitions

### Definition 2.1 (Eckmann–Hilton data)

**Eckmann–Hilton data** on a type `X` is a tuple
`E = (m₁, m₂, e, ℓ₁, r₁, ℓ₂, r₂, χ)` consisting of:

- two binary operations `m₁, m₂ : X → X → X` (the *vertical* and
  *horizontal* operations);
- a distinguished element `e : X` (the *shared unit*);
- unit laws `ℓ₁ : ∀ x, m₁ e x = x`, `r₁ : ∀ x, m₁ x e = x`,
  `ℓ₂ : ∀ x, m₂ e x = x`, `r₂ : ∀ x, m₂ x e = x`;
- the interchange law
  `χ : ∀ a b c d, m₁ (m₂ a b) (m₂ c d) = m₂ (m₁ a c) (m₁ b d)`.

We write `EckmannHiltonData X` for the type of all such tuples.

### Definition 2.2 (the engine lemmas)

For `E : EckmannHiltonData X` the following are theorems (the abstract
Eckmann–Hilton engine):

- `same_op`: `∀ a b, m₁ a b = m₂ a b`;
- `comm`: `∀ a b, m₁ a b = m₁ b a`;
- `assoc`: `∀ a b c, m₁ (m₁ a b) c = m₁ a (m₁ b c)`.

*Proof sketch.* For `same_op`, instantiate `χ` at `(a, e, e, b)` and reduce
the four parentheses with the unit laws: the left side becomes `m₁ a b` and
the right `m₂ a b`. For `comm`, instantiate `χ` at `(e, a, b, e)` to obtain
`m₁ a b = m₂ b a`, then rewrite by `same_op`. For `assoc`, use `same_op` to
turn `χ` into the medial law `m₁(m₁ a b)(m₁ c d) = m₁(m₁ a c)(m₁ b d)` and
specialize `d := e`, reassembling both sides with the unit laws. ∎

### Definition 2.3 (commutative monoid)

A **commutative monoid** on `X` is a binary operation `* : X → X → X` with a
unit `1` satisfying `1 * x = x`, `x * 1 = x`, `(x * y) * z = x * (y * z)`,
and `x * y = y * x`. We write `CommMonoid X`.

---

## 3. The round trip

### Definition 3.1 (from interchange data to a commutative monoid)

Let `E : EckmannHiltonData X`. Define `toCommMonoid E : CommMonoid X` by:

- multiplication `:= m₁`;
- unit `:= e`;
- left/right unit laws `:= ℓ₁, r₁`;
- associativity `:= assoc E`;
- commutativity `:= comm E`.

This is well-typed precisely because the engine lemmas of Definition 2.2
supply exactly the missing monoid axioms; the unit laws are taken directly
from the data. We record the definitional fact
`toCommMonoid_mul : (toCommMonoid E).mul a b = m₁ a b`, true by reflexivity.

### Definition 3.2 (from a commutative monoid to interchange data)

Let `M` be a commutative monoid with multiplication `*` and unit `1`.
Define `ofCommMonoid M : EckmannHiltonData M` by:

- `m₁ := (*)`, `m₂ := (*)`, `e := 1`;
- all four unit laws `:= one_mul / mul_one`;
- interchange: the goal `a * b * (c * d) = a * c * (b * d)` is exactly the
  **medial law** `mul_mul_mul_comm`, which holds in every commutative
  monoid.

We record `ofCommMonoid_m₁ : (ofCommMonoid M).m₁ a b = a * b` and
`ofCommMonoid_m₂ : (ofCommMonoid M).m₂ a b = a * b`, both by reflexivity.

**Remark (a formal subtlety).** A naive attempt to discharge the
interchange field by `simp` makes no progress, because the stored operation
is an anonymous function (`(· * ·)`) and the goal does not present in the
medial-law shape until one explicitly *unfolds* it to
`a * b * (c * d) = a * c * (b * d)`. After that reshaping, the single lemma
`mul_mul_mul_comm` closes the goal. This is the one place where the formal
proof requires manual guidance rather than automation.

---

## 4. The equivalence of theories

### Theorem 4.1 (`eh_iff_commMonoid`)

For a binary operation `m : X → X → X` and an element `e : X`, the following
are equivalent:

1. there exists `E : EckmannHiltonData X` with `E.m₁ = m` and `E.unit = e`;
2. there exists a commutative-monoid structure on `X` whose multiplication
   satisfies `a * b = m a b` for all `a, b` and whose unit satisfies
   `1 = e`.

*Proof sketch.* (1 ⇒ 2): Given such `E`, take the commutative monoid
`toCommMonoid E` of Definition 3.1. Its multiplication is `m₁ = m` by
hypothesis, so `a * b = m a b` holds by reflexivity; its unit is `e`.
(2 ⇒ 1): Given the commutative-monoid witness, apply `ofCommMonoid X` of
Definition 3.2. Its `m₁` is the monoid multiplication, which equals `m`
pointwise by hypothesis; conclude `E.m₁ = m` by functional extensionality,
and `E.unit = e` from `1 = e`. ∎

**Interpretation.** Theorem 4.1 says the equational theory axiomatized by
"(two unital operations) + (interchange)", read off at the level of
(operation, unit) pairs, *coincides* with the equational theory of
commutative monoids. The interchange theory is neither stronger (it forces
nothing beyond the commutative-monoid axioms) nor weaker (it forces all of
them). This is the exact sense in which there is **no genuinely higher
algebra in dimension two**: a doubly-unital interchanging pair of
operations is a commutative monoid, viewed twice.

---

## 5. Rigidity

### Theorem 5.1 (`structure_rigidity`)

Let `E, F : EckmannHiltonData X` with `E.m₁ = F.m₁`. Then `E.unit = F.unit`
and `E.m₂ = F.m₂`.

*Proof sketch.* For the units: since `E.m₁ = F.m₁` and unit laws hold,
compute
`E.unit = E.m₁ E.unit F.unit` (by `E`'s right unit law)
`= F.m₁ E.unit F.unit` (by the hypothesis `E.m₁ = F.m₁`)
`= F.unit` (by `F`'s left unit law).
Concretely: `E.m₁ E.unit F.unit = F.unit` by the left unit law of `E`'s
operation applied via `F`'s data, and `= E.unit` by `E`'s right unit law;
hence `E.unit = F.unit`. For the horizontal operations: by `same_op`,
`E.m₂ = E.m₁` and `F.m₂ = F.m₁`, and these agree by hypothesis, so
`E.m₂ = F.m₂` by functional extensionality. ∎

**Interpretation.** The two-dimensional bookkeeping — the horizontal
operation and the chosen unit — is a *function of* the one-dimensional
vertical operation. The unit is determined because a monoid identity is
unique; the horizontal operation is determined because it equals the
vertical one. Combined with Theorem 4.1, this shows the round trip of
Section 3 is as tight as possible: each side has no hidden degrees of
freedom.

---

## 6. Corollaries

### Corollary 6.1 (abstract "`π₂` is abelian", `pi_two_commutative`)

For `E : EckmannHiltonData X` and all `a, b`,

```
m₁ a b = m₂ b a.
```

*Proof sketch.* `m₁ a b = m₁ b a` by `comm`, and `m₁ b a = m₂ b a` by
`same_op`. ∎

**Interpretation.** Reading `m₁` as vertical and `m₂` as horizontal
composition of 2-cells sharing the identity 2-cell, the two compositions
agree *and* commute. Specializing to a double loop space recovers the
classical statement that the second homotopy group is abelian.

### Corollary 6.2 (a second interchange forces commutativity, `monoid_comm_of_second_interchange`)

Let `X` be a monoid (not assumed commutative) with multiplication `*` and
identity `1`. Suppose there is a second operation `n : X → X → X` with
`n 1 x = x` and `n x 1 = x` for all `x`, interchanging with `*`:

```
n (a * b) (c * d) = (n a c) * (n b d)      for all a, b, c, d
```

(the unital interchange of `*` and `n`). Then `*` is commutative.

*Proof sketch.* Assemble Eckmann–Hilton data with `m₁ := *`, `m₂ := n`,
`unit := 1`: the unit laws for `*` come from the monoid, those for `n` from
the hypotheses, and the interchange field is the assumed law. Then `comm`
of the engine gives `a * b = b * a`. ∎

**Interpretation.** A second compatible unital multiplication on a monoid is
no extra structure — it is a *commutativity certificate*. This is the
algebraic incarnation of "a connected double loop space is
homotopy-commutative", reduced to a one-line application of the engine.

---

## 6.5 A fully worked finite example

To make the abstractions concrete, take `X = ℤ/5 = {0,1,2,3,4}` with addition
modulo 5 as the operation `m` and `e = 0`.

**The commutative-monoid side.** `(ℤ/5, +, 0)` is a commutative monoid: `0`
is a two-sided identity, addition is associative and commutative.

**Applying `ofCommMonoid` (Definition 3.2).** We set `m₁ = m₂ = (+ mod 5)` and
`unit = 0`. The four unit laws are immediate. The interchange field requires
`(a + b) + (c + d) = (a + c) + (b + d)` modulo 5, the medial law, which holds
because addition is associative and commutative; for instance with
`(a,b,c,d) = (1,2,3,4)` both sides equal `10 ≡ 0`. So we obtain valid
Eckmann–Hilton data.

**Reading off the engine lemmas.** `same_op` says `m₁ a b = m₂ a b`, trivially
true here since both are `(+ mod 5)`. `comm` says `a + b = b + a`. `assoc` says
`(a + b) + c = a + (b + c)`. `pi_two_commutative` says `m₁ a b = m₂ b a`, i.e.
`a + b = b + a`, again addition's commutativity.

**Applying `toCommMonoid` (Definition 3.1).** Forgetting `m₂` and keeping
`(m₁, unit) = (+ mod 5, 0)` returns exactly the commutative monoid we started
with — the round trip is the identity on this example, illustrating Theorem 4.1.

**Rigidity in action.** Suppose someone hands us only `m₁ = (+ mod 5)`. The unit
must be the unique `e` with `e + x = x` for all `x`, forcing `e = 0`; and `m₂`
must equal `m₁` by `same_op`. There is no freedom: the structure is recovered
from `m₁` alone (Theorem 5.1).

**The contrapositive of Corollary 6.2.** The symmetric group `S₃` is a
non-commutative monoid (in fact a group). By Corollary 6.2, it can admit *no*
second unital operation, sharing its identity, that interchanges with its
multiplication — for any such operation would force `S₃` to be abelian, which it
is not. The accompanying numerical demonstration confirms that a search over
candidate second operations on `S₃` finds none, exactly as the theorem predicts.

## 7. Algorithmic content

Although the results are equational, they have a constructive, executable
shape that the accompanying numerical demonstrations exploit. Three
procedures stand out.

### 7.1 Interchange verification

Given a finite carrier and two operation tables, one checks (★) by ranging
over all quadruples `(a, b, c, d)`. For a carrier of size `n` this is
`O(n⁴)` table lookups. This is the *decision procedure* behind "is this
Eckmann–Hilton data?".

### 7.2 The collapse witness

Given verified Eckmann–Hilton data, `same_op`, `comm`, `assoc` are
*witnessed* concretely: one can tabulate the single collapsed operation and
confirm, in `O(n²)` and `O(n³)` respectively, that it is commutative and
associative — i.e. exhibit the commutative monoid of Definition 3.1
directly.

### 7.3 The medial-law generator

Given any commutative monoid, `ofCommMonoid` *generates* Eckmann–Hilton
data by duplicating the operation. Verifying that the duplicate satisfies
interchange reduces to checking the medial law, which is automatic — a
constructive proof that the round trip's second leg never fails.

---

## 8. Applications and connections

- **Higher homotopy.** The package is the algebraic skeleton of the theorem
  that `π_n` is abelian for `n ≥ 2`, and of the broader principle that
  iterated loop spaces carry increasingly commutative (`E_∞` in the limit)
  multiplications.
- **Category theory.** The interchange law is exactly the compatibility of
  vertical and horizontal composition in a strict 2-category; Eckmann–Hilton
  explains why a 2-category with one object and one 1-morphism (a "doubly
  degenerate" 2-category) is a commutative monoid.
- **Universal algebra.** Theorem 4.1 is a clean example of two superficially
  different equational presentations defining the *same* variety; rigidity
  (Theorem 5.1) shows the presentations are not merely equivalent but that
  one set of operations is definable from a proper subset.
- **Verification practice.** Corollary 6.2 is a ready-made tactic: to prove
  a monoid commutative, exhibit any compatible second unital operation.

---

## 8.5 On the medial law and where commutativity comes from

It is worth isolating the precise mechanism by which commutativity is forced,
because it is more subtle than it first appears. The interchange law (★) by
itself does not obviously produce commutativity; what does the work is its
*combination* with the existence of a *shared* unit. If the two operations had
*different* units, the collapse would not proceed identically — the standard
"two units argument" first shows the units must coincide, and only then does the
cascade `same_op → comm → assoc` run. In our structure the unit is shared by
fiat, which is exactly the minimal hypothesis needed. Conversely, the medial law
`(a · b) · (c · d) = (a · c) · (b · d)` is *equivalent*, in the presence of a
unit, to commutativity-plus-associativity: a unital medial magma is a
commutative monoid. Theorem 4.1 can thus be read as the statement that the
interchange presentation, the medial presentation, and the commutative-monoid
presentation all axiomatize the same variety. This triangulation is what makes
the result feel inevitable once seen, yet it remains genuinely informative: no
amount of two-operation bookkeeping escapes the commutative-monoid variety.

## 9. Discussion

The value of this development is *exactness*. The classical argument shows a
collapse; the results here pin the landing point to a named, well-understood
variety and prove the correspondence is a tight, information-preserving
round trip. Rigidity is the conceptual punchline: what looked like
two-dimensional data (two operations, a unit) is determined by a single
one-dimensional operation. The supposed extra dimension is bookkeeping.

A subtle methodological point recurs in the formalization. The interchange
field of `ofCommMonoid` (Definition 3.2) cannot be discharged by blind
simplification because the stored operation is an anonymous lambda; one must
first *unfold* the goal into the medial-law shape. This is a reminder that
"obvious" equational steps can hinge on presentation, and that the right
intermediate form (`a * b * (c * d) = a * c * (b * d)`) is what unlocks the
one-lemma proof.

---

## 10. Future work

A natural next step upgrades Theorem 4.1 from an equivalence of
(operation, unit) pairs to an equivalence of *categories*: build the
category of Eckmann–Hilton structures with structure-preserving maps and
the category of commutative monoids with monoid homomorphisms, and exhibit
`toCommMonoid`/`ofCommMonoid` as an isomorphism of categories. Rigidity
already shows the functors are essentially injective on objects, so the only
remaining content is functoriality on morphisms — and a morphism of
Eckmann–Hilton data is forced to be a monoid homomorphism for `m₁` by
`same_op`. Beyond that lie the genuinely higher-dimensional analogues
(`E_n`-structures, the recognition principle for iterated loop spaces) where
the dimension-two collapse no longer holds and the interesting structure
finally survives. See the Future Directions for a fuller program.

---

## 11. Conclusion

We have established a tight, fully verified bridge between interchanging
unital operations and commutative monoids: a round trip
(`toCommMonoid`/`ofCommMonoid`), an exact equivalence of equational theories
(`eh_iff_commMonoid`), a rigidity theorem reducing the structure to its
one-dimensional shadow (`structure_rigidity`), and two corollaries — the
algebraic "`π₂` is abelian" (`pi_two_commutative`) and the
second-interchange commutativity criterion
(`monoid_comm_of_second_interchange`). Together they make precise, and
machine-check, the slogan that in dimension two there is no higher algebra:
there are only commutative monoids, viewed twice.
