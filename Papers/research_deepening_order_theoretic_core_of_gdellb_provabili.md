# Constructive de Jongh–Sambin Fixed Points by Descending Iteration: The Order-Theoretic Core of Gödel–Löb Provability Logic

## Abstract

We isolate the purely structural content of the de Jongh–Sambin fixed-point theorem of
Gödel–Löb provability logic **GL**, working entirely inside an abstract algebraic setting —
a Heyting algebra equipped with a unary "provability" operator `□` satisfying three axioms
(necessitation of truth, normality, and Löb's axiom). From these three axioms alone, with
no syntax, Gödel numbering, or arithmetic, we recover the structural skeleton of provability
logic: the transitivity axiom `4` (`□a ≤ □□a`) as a *derived* theorem, Gödel's second
incompleteness theorem in algebraic form, the explicit Sambin fixed point `□c ⇨ c` of the
canonical modalised map `p ↦ □p ⇨ c`, and — crucially — the *uniqueness* of fixed points
for arbitrary *box-congruent* operators.

The new contribution is a clean separation of the two halves of the de Jongh–Sambin
theorem and a constructive existence result. We prove that uniqueness of modalised fixed
points is exactly **Löb's rule applied to the biimplication** (a purely modal fact), while
*existence* is governed by the **descending chain condition** on the underlying order (a
purely order-theoretic fact). The headline theorem states: on any Gödel–Löb algebra whose
order satisfies the descending chain condition (`WellFoundedLT`), every box-congruent
operator `f` whose square `f ∘ f` is monotone has a unique fixed point, obtained
constructively as the stabilised value of the descending iteration `(f ∘ f)^[n] ⊤`. The
bridge between the two halves is the closure of box-congruence under composition, which is
precisely where the transitivity axiom `4` is consumed. The canonical (antitone)
Gödel/Sambin map is a special case, and its iterative fixed point coincides with the
closed form `□c ⇨ c`. Finite GL frames `(Fin n, <)` are exhibited as the natural home where
the iteration always terminates.

---

## 1. Introduction

Gödel–Löb provability logic **GL** is the modal logic of formal provability: the box `□p`
reads "`p` is provable" in a sufficiently strong, recursively axiomatised theory such as
Peano Arithmetic. By the arithmetical completeness theorem of Solovay (1976), GL captures
exactly the schematic provability principles valid across all such theories.

Two of the deepest facts about GL are:

1. **Gödel's second incompleteness theorem**: a consistent theory cannot prove its own
   consistency.
2. **The de Jongh–Sambin fixed-point theorem**: every formula `A(p)` in which the
   propositional variable `p` occurs only within the scope of `□` has, provably in GL, a
   *unique* fixed point `p ↔ A(p)`; moreover that fixed point is *explicitly definable*
   from `A` and does not mention `p`.

The de Jongh–Sambin theorem is the engine behind the canonical construction of unique
Gödel and Henkin sentences. Its standard proofs are syntactic and intricate. Our purpose
is to extract its algebraic and order-theoretic core, exhibit *which axiom does what*, and
turn the existence half into a terminating computation.

We work in the language of **Gödel–Löb algebras**: a Heyting algebra `H` with an operator
`□` satisfying necessitation, normality, and Löb's axiom. This is the Lindenbaum–Tarski
abstraction of GL. The advantage is conceptual clarity: every theorem becomes a statement
about order and meets, and one can see exactly where each modal axiom is invoked.

**Contributions.**

- A self-contained derivation of the GL skeleton (axiom 4, Löb's rule, Gödel II, the
  explicit Sambin fixed point) from three algebraic axioms (Section 3).
- A clean decomposition of the de Jongh–Sambin theorem: uniqueness = Löb's rule on the
  biimplication; existence = the descending chain condition (Sections 4–5).
- A constructive existence theorem under the descending chain condition, by descending
  iteration from `⊤`, with the canonical antitone map handled via its monotone square
  (Section 5).
- Identification of finite frames as the terminating home of the iteration, and of the
  infinite well-founded *frame* models `(ℕ, >)`, `(Ordinal, <)` as places where the
  *algebra* fails the descending chain condition (Section 6).

---

## 2. Preliminaries: Heyting algebras and the biimplication

A **Heyting algebra** `H` is a bounded lattice `(H, ⊓, ⊔, ⊤, ⊥)` with a binary operation
`⇨` (Heyting implication) characterised by the adjunction

> `c ⊓ a ≤ b  ⟺  c ≤ a ⇨ b`     (for all `a, b, c ∈ H`).

We use the standard consequences: `a ⊓ (a ⇨ b) ≤ b` (modus ponens, `himp_inf_le`),
`b ≤ a ⇨ b` (`le_himp`), and `a ⇨ b = ⊤ ⟺ a ≤ b` (`himp_eq_top_iff`).

**Definition 2.1 (Biimplication).** For `a, b ∈ H` set
> `a ⇔ b := (a ⇨ b) ⊓ (b ⇨ a)`.

**Lemma 2.2 (`biimp_eq_top_iff`).** `a ⇔ b = ⊤  ⟺  a = b`.

*Proof.* `(a ⇨ b) ⊓ (b ⇨ a) = ⊤` iff both conjuncts are `⊤`, iff `a ≤ b` and `b ≤ a`, iff
`a = b`. ∎

The biimplication is the algebraic "if and only if": it measures equality with a single
truth-value. Two lemmas record how it interacts with the basic operators (proofs are short
lattice calculations):

**Lemma 2.3 (`biimp_himp_const`).** For all `a, b, c`: `a ⇔ b ≤ (a ⇨ c) ⇔ (b ⇨ c)`. *(The
antitone map `· ⇨ c` preserves agreement.)*

**Lemma 2.4 (`biimp_inf_const`).** For all `a, b, d`: `a ⇔ b ≤ (d ⊓ a) ⇔ (d ⊓ b)`. *(The
monotone map `d ⊓ ·` preserves agreement.)*

---

## 3. Gödel–Löb algebras and their structural skeleton

**Definition 3.1 (Gödel–Löb algebra, `GLOperator`).** A Gödel–Löb algebra is a Heyting
algebra `H` together with an operator `□ : H → H` satisfying

- **(Nec)** `□⊤ = ⊤`;
- **(K)** `□(a ⊓ b) = □a ⊓ □b`;
- **(Löb)** `□(□a ⇨ a) ≤ □a`.

We write `□a` for `box a`. The three axioms are the conjunctive (algebraic) form of the
normal modal logic K extended with Löb's axiom; together they axiomatise GL.

From these we derive everything below. The proofs are short; we give the key idea for each.

**Lemma 3.2 (`box_mono`).** `□` is monotone: `a ≤ b ⟹ □a ≤ □b`.

*Proof.* `a ≤ b` gives `a ⊓ b = a`, so by (K), `□a = □a ⊓ □b ≤ □b`. ∎

**Theorem 3.3 (Transitivity / axiom 4 is derivable, `box_transitive`).** `□a ≤ □□a`.

*Proof (the classic Löb trick).* Put `c := a ⊓ □a`. By (K), `□c = □a ⊓ □□a`. One checks
`a ≤ □c ⇨ c` (since `□c ⊓ a ≤ a ⊓ □a = c` after unfolding). Applying `□` and (Löb):
`□a ≤ □(□c ⇨ c) ≤ □c = □a ⊓ □□a ≤ □□a`. ∎

This is the celebrated fact that GL needs no separate transitivity axiom.

**Theorem 3.4 (Equality form of Löb, `loeb_eq`).** `□(□a ⇨ a) = □a`.

*Proof.* `≤` is (Löb); `≥` is monotonicity applied to `a ⊓ □a ≤ a`, i.e. `a ≤ □a ⇨ a`. ∎

**Theorem 3.5 (Löb's rule, `loeb_rule`).** If `□a ≤ a` then `a = ⊤`.

*Proof.* `□a ≤ a` gives `□a ⇨ a = ⊤`, so `□(□a ⇨ a) = □⊤ = ⊤`. By (Löb), `⊤ ≤ □a`, hence
`□a = ⊤`, and then `⊤ = □a ≤ a`. ∎

**Corollary 3.6 (`box_fixedPoint_eq_top`).** The only self-provable element is `⊤`: if
`□a = a` then `a = ⊤`.

**Theorem 3.7 (Gödel II, algebraic form, `consistency_unprovable` / `godel_second`).** If
the algebra is consistent (`□⊥ ≠ ⊤`) then it cannot prove its own consistency:
`□(□⊥ ⇨ ⊥) ≠ ⊤`.

*Proof.* Suppose `□(□⊥ ⇨ ⊥) = ⊤`. Instantiating (Löb) at `a = ⊥` gives `⊤ ≤ □⊥`, i.e.
`□⊥ = ⊤`, contradicting consistency. ∎

**Lemma 3.8 (Normality of implication, `box_himp_le`).** `□(a ⇨ b) ≤ □a ⇨ □b`.

*Proof.* From `(a ⇨ b) ⊓ a ≤ b`, apply `□` and (K). ∎

---

## 4. The de Jongh–Sambin fixed point of `p ↦ □p ⇨ c`

Fix `c ∈ H`. The canonical modalised map is `f_c(p) := □p ⇨ c`. We exhibit its fixed point
explicitly and prove uniqueness.

**Definition 4.1 (Explicit Sambin fixed point, `glFix`).** `glFix c := □c ⇨ c`.

With `c = ⊥`, `glFix ⊥ = □⊥ ⇨ ⊥` is the Gödel consistency sentence.

**Theorem 4.2 (Provability of the fixed point, `glFix_box`).** `□(glFix c) = □c`.

*Proof.* Unfolding, `□(□c ⇨ c)`: the inequality `≤` is exactly (Löb), and `≥` is
monotonicity applied to `c ≤ □c ⇨ c`. ∎

**Theorem 4.3 (Existence, `loeb_fixed_point`).** `glFix c = □(glFix c) ⇨ c`. That is,
`glFix c` is a fixed point of `f_c`.

*Proof.* By Theorem 4.2, `□(glFix c) ⇨ c = □c ⇨ c = glFix c`. ∎

**Theorem 4.4 (Uniqueness, `glFix_unique`).** If `a = □a ⇨ c` then `a = glFix c`.

*Proof.* From the fixed-point equation, `c ≤ a` (so `□c ≤ □a`) and `a ⊓ □a ≤ c`. Apply `□`
to the latter and use (K) together with the derived `□a ≤ □□a` (Theorem 3.3) to get
`□a ≤ □c`. Hence `□a = □c`, and substituting, `a = □a ⇨ c = □c ⇨ c = glFix c`. ∎

**Corollary 4.5 (`glFix_iff`).** `a = □a ⇨ c ⟺ a = glFix c`.

---

## 5. The general theorem: uniqueness is modal, existence is order-theoretic

### 5.1 Box-congruent operators and general uniqueness

**Definition 5.1 (Box-congruence, `BoxCongruent`).** An operator `f : H → H` is
*box-congruent* if for all `a, b`:
> `□(a ⇔ b) ≤ f a ⇔ f b`.

Syntactically, this is the algebraic shadow of "the variable occurs only within the scope
of `□`."

**Lemma 5.2 (`box_biimp_le`).** `□` is a biimplication-congruence: `□(a ⇔ b) ≤ □a ⇔ □b`.
Equivalently, `box` itself is box-congruent (`boxCongruent_box`).

*Proof.* `a ⇔ b = (a ⇨ b) ⊓ (b ⇨ a)`; apply (K) and Lemma 3.8 componentwise. ∎

**Theorem 5.3 (General de Jongh–Sambin uniqueness, `modalised_fixedPoint_unique`).** A
box-congruent operator has *at most one* fixed point: if `a = f a` and `b = f b`, then
`a = b`.

*Proof (the conceptual heart).* By box-congruence at the two fixed points,
`□(a ⇔ b) ≤ f a ⇔ f b = a ⇔ b`. This is precisely the hypothesis of Löb's rule
(Theorem 3.5) applied to the element `a ⇔ b`, so `a ⇔ b = ⊤`, i.e. (Lemma 2.2) `a = b`. ∎

Thus uniqueness is *purely modal*: it is Löb's rule applied to the biimplication of the two
candidate fixed points, plus the single congruence Lemma 3.8. It needs no order condition
and holds on **every** Gödel–Löb algebra.

### 5.2 Existence as a descending chain condition

Existence is the genuinely missing half. On an arbitrary algebra a box-congruent operator
need not have any fixed point. The exact extra hypothesis is order-theoretic.

**Theorem 5.4 (Descending-iteration fixed point, `exists_fixedPoint_of_monotone_wf`).**
Let `H` be a partial order with a top element `⊤` and no infinite strictly descending chain
(`WellFoundedLT`). Then every monotone `g : H → H` has a fixed point, realised as the
stabilised value of the iteration `x_n := g^[n] ⊤`.

*Proof.* The iterates descend: `x_{n+1} = g(x_n)`, and by induction `x_{n+1} ≤ x_n` (base:
`x_1 = g ⊤ ≤ ⊤`; step: apply monotone `g` to `x_{k+1} ≤ x_k`). The range `{x_n : n ∈ ℕ}`
is nonempty, so by `WellFoundedLT` it has a minimal element `x_m`. Then `x_{m+1} ≤ x_m` but
`¬(x_{m+1} < x_m)` by minimality, so `x_{m+1} = x_m`, i.e. `g(x_m) = x_m`. ∎

This is *pure order theory* — no `□`. The fixed point is **computed**, not posited: iterate
`g` from `⊤` until two successive values agree.

### 5.3 Composition-closure: the bridge, and where axiom 4 is consumed

**Lemma 5.5 (Box-congruence is closed under composition, `boxCongruent_comp`).** If `f` and
`g` are box-congruent, so is `g ∘ f`.

*Proof.* For all `a, b`:
> `□(a ⇔ b) ≤ □□(a ⇔ b)`   [transitivity, Theorem 3.3 — **this is where axiom 4 enters**]
> `≤ □(f a ⇔ f b)`          [`box_mono` of `f`'s box-congruence]
> `≤ g(f a) ⇔ g(f b)`       [`g`'s box-congruence].
∎

The second box is unavoidable: to push the inner agreement `f a ⇔ f b` under another box, we
must move from `□(a⇔b)` to `□□(a⇔b)`. Composition-closure of box-congruence is *exactly*
the place transitivity / axiom 4 is needed.

**Lemma 5.6 (`boxCongruent_himp_const`).** If `f` is box-congruent then so is
`p ↦ f p ⇨ c`.

*Proof.* Compose `f`'s box-congruence with Lemma 2.3. ∎

**Corollary 5.7 (`boxCongruent_sambin`).** The canonical Gödel/Sambin map `p ↦ □p ⇨ c` is
box-congruent (take `f = □` in Lemma 5.6, using Lemma 5.2).

### 5.4 The constructive fixed-point theorem under DCC

We can now combine the halves. The subtlety is that the Sambin map `f_c(p) = □p ⇨ c` is
*antitone*, so Theorem 5.4 does not apply to it directly. But its square is monotone.

**Theorem 5.8 (Constructive fixed point under DCC, `boxCongruent_fixedPoint`).** Let `H` be
a Gödel–Löb algebra whose order satisfies `WellFoundedLT`. Let `f` be box-congruent with
`f ∘ f` monotone. Then `f` has a fixed point.

*Proof.* Put `g := f ∘ f`. By Lemma 5.5, `g` is box-congruent. Since `g` is monotone and
`H` is `WellFoundedLT` with top, Theorem 5.4 yields `a` with `g(a) = a`, i.e. `a` is a
fixed point of `g`. Now `f(a)` is also a fixed point of `g`, because
`g(f a) = f(f(f a)) = f(g a) = f a`. By the general uniqueness Theorem 5.3 applied to the
box-congruent `g` (whose fixed points are unique), `f a = a`. So `a` is a fixed point of
`f`. ∎

**Theorem 5.9 (Existence + uniqueness under DCC, `boxCongruent_existsUnique_fixedPoint`).**
Under the hypotheses of Theorem 5.8, `f` has a **unique** fixed point. *(Existence:
Theorem 5.8. Uniqueness: Theorem 5.3.)*

The hypothesis "`f ∘ f` monotone" holds whenever `f` is monotone (monotone∘monotone) **or**
antitone (antitone∘antitone). In particular the canonical antitone Sambin map qualifies.

**Theorem 5.10 (Sambin map under DCC, `sambin_existsUnique_fixedPoint`).** On a
`WellFoundedLT` Gödel–Löb algebra, the map `p ↦ □p ⇨ c` has a unique fixed point, found by
iterating its square from `⊤`.

**Theorem 5.11 (Agreement with the closed form, `sambin_fixedPoint_eq_glFix`).** That
iterative fixed point equals the explicit `glFix c = □c ⇨ c`.

*Proof.* The iterative fixed point is *a* fixed point of `p ↦ □p ⇨ c`; by Theorem 4.4 every
such fixed point equals `glFix c`. ∎

This closes the circle: the abstract iteration recovers the hand-written Sambin formula.

---

## 6. Models: where staircases stop, and where they don't

### 6.1 Frame boxes and well-founded frames

For a relation `r : α → α → Prop`, the **frame box** is
> `wfBox r S := { x | ∀ y, r y x → y ∈ S }`

— "`x` proves `S` iff every `r`-predecessor of `x` satisfies `S`."

**Theorem 6.1 (`wfBox_loeb`).** If `r` is transitive and well-founded, then `wfBox r`
satisfies Löb's axiom: `wfBox r (wfBox r S ⇨ S) ≤ wfBox r S`. Together with the easy
`wfBox_top` and `wfBox_inf`, this makes `(Set α, wfBox r)` a Gödel–Löb algebra.

*Proof.* By well-founded induction on the witness; the single use of transitivity is
`r p m → r m n → r p n`. Transitivity gives axiom 4; converse-well-foundedness gives Löb.
∎

**The `ℕ`-model `NatGL`.** Taking `α = ℕ`, `r = (· < ·)` gives `natBox S = {n | ∀ m < n,
m ∈ S}`. This is a consistent Gödel–Löb algebra (`□⊥ = {0} ≠ ⊤`). One computes the
**provability ladder** `natBox^[k] ∅ = Iio k = {0,…,k−1}` (`natBox_iterate_eq_Iio`), so the
consistency strengths `k ↦ □^k⊥` strictly increase and never reach `⊤`, and one obtains a
graded Gödel II: for every `k`, `□(□^{k+1}⊥ ⇨ ⊥) ≠ ⊤`.

**The ordinal model `OrdGL`.** Taking `α = Ordinal`, `r = (· < ·)` lifts everything
transfinitely: `□(Iio a) = Iio(a+1)` (`ordBox_Iio`), the consistency strengths
`a ↦ Iio a` form a proper-class strictly increasing chain, and transfinite graded Gödel II
holds: `□(Iio(a+1) ⇨ ⊥) ≠ ⊤` for every ordinal `a`.

### 6.2 The descending chain condition fails in these algebras

Crucially, although the *frames* `(ℕ, >)` and `(Ordinal, <)` are well-founded, the
**algebras** `Set ℕ` and `Set Ordinal` are *not* `WellFoundedLT`: the chain
`{0,1,2,…} ⊋ {1,2,…} ⊋ {2,3,…} ⊋ ⋯` descends forever. So in these models the descending
iteration `(f ∘ f)^[n] ⊤` need not stabilise, and the constructive Theorem 5.8 does **not**
apply. Existence in these models still holds, but only via the explicit `glFix`, not the
iteration. The descending chain condition is load-bearing.

### 6.3 Finite frames: the terminating home

**Finite GL frames `FinGL` on `(Fin n, <)`.** The frame `(Fin n, <)` is finite, hence its
algebra `Set (Fin n)` (equivalently a finite Boolean algebra) is automatically
`WellFoundedLT`. Therefore every finite GL frame is a *DCC* Gödel–Löb algebra, and
Theorem 5.8 applies: every box-congruent operator with monotone square has the
**constructive** fixed-point property, with the iteration `(f ∘ f)^[n] ⊤` guaranteed to
terminate. In particular the Sambin map's iterative fixed point equals `glFix c`
(`finGL_sambin_fixedPoint`). Finite frames are the clean setting where self-reference is a
finite computation.

---

## 7. Algorithms

The proofs are constructive enough to read off two algorithms on a finite (DCC) Gödel–Löb
algebra.

**Algorithm A (Descending-iteration fixed point).** Given a monotone `g` and the element
`⊤`, compute `x ← ⊤`; repeatedly set `x' ← g(x)`; if `x' = x` return `x`, else `x ← x'`.
Termination is guaranteed by `WellFoundedLT` (the sequence strictly descends until it
stabilises). On a finite frame with `N` elements the loop runs at most `N` times.

**Algorithm B (Sambin fixed point of `p ↦ □p ⇨ c`).** Set `f(p) := □p ⇨ c` and run
Algorithm A on `g := f ∘ f`. The returned `a` satisfies `g(a) = a`, and `f(a) = a` by
uniqueness; by Theorem 5.11, `a = □c ⇨ c`. (Equivalently, one may directly return the
closed form `□c ⇨ c`, which Theorem 5.11 certifies equal to the iterative result.)

---

## 8. Discussion

The development clarifies the logical architecture of the de Jongh–Sambin theorem by
decoupling its two halves:

- **Uniqueness** is the *modal* half: Löb's rule applied to the biimplication of two
  candidate fixed points (Theorem 5.3). It holds on every Gödel–Löb algebra, with no order
  hypothesis.
- **Existence** is the *order-theoretic* half: the descending chain condition forces the
  iteration `g^[n] ⊤` to stabilise at a fixed point (Theorem 5.4).
- **Transitivity (axiom 4)** is the bridge: it is needed exactly to close box-congruence
  under composition (Lemma 5.5), which is what lets an antitone modalised operator be
  handled through its monotone square.

A pleasant consequence is a unifying generalisation: the hypothesis "`f ∘ f` monotone"
covers both monotone and antitone box-congruent operators, so the single Theorem 5.8
recovers the canonical antitone Sambin map and any monotone modalised operator at once,
and the abstract iteration provably reproduces the closed-form `glFix c = □c ⇨ c`.

All results are established in a fully formal, machine-checked development that depends only
on the standard foundational axioms (propositional extensionality, the axiom of choice for
`Classical`, and quotient soundness); no nonstandard axioms are used.

---

## 9. Future work

(See the dedicated future-directions discussion accompanying this package.) The most
immediate question is **quantitative convergence**: for the Sambin map the iteration is
observed to reach `glFix c` after a single application of the square. We conjecture that for
`p ↦ □p ⇨ c`, the iterates `(f∘f)^[1] ⊤` and `(f∘f)^[2] ⊤` already equal `glFix c` in
*every* Gödel–Löb algebra, with no descending chain condition — the iteration is eventually
constant from step one, because `glFix_box` pins the provability of the fixed point
(`□(glFix c) = □c`). Further directions include extending the constructive iteration to
multi-variable modalised systems (simultaneous fixed points), to polymodal provability
logics (GLP), and to graded/parametrised hierarchies of fixed points indexed by ordinals.

---

## Appendix: Symbol glossary

| Symbol | Meaning |
| --- | --- |
| `⊓`, `⊔` | meet (and), join (or) |
| `⊤`, `⊥` | top (true), bottom (false) |
| `a ⇨ b` | Heyting implication |
| `a ⇔ b` | biimplication `(a ⇨ b) ⊓ (b ⇨ a)` |
| `□a` | provability / box of `a` |
| `glFix c` | the explicit Sambin fixed point `□c ⇨ c` |
| `g^[n]` | `n`-fold composition of `g` |
| `WellFoundedLT` | descending chain condition: no infinite `a₀ > a₁ > a₂ > ⋯` |
| `Iio a` | `{x | x < a}` |
