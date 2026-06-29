# The Order-Theoretic Core of Gödel–Löb Provability Logic: Fixed Points, a Computable Well-Founded Model, and the Consistency Diamond

## Abstract

We present a fully algebraic, syntax-free development of the structural heart of the
Gödel–Löb provability logic **GL**. A *Gödel–Löb algebra* is defined to be a Heyting
algebra `H` equipped with a single unary operator `□ : H → H` (read "is provable")
satisfying exactly three equations: necessitation of truth `□⊤ = ⊤`, normality
`□(a ⊓ b) = □a ⊓ □b`, and **Löb's axiom** `□(□a ⇨ a) ≤ □a`. From these three axioms
*alone* — with no Gödel numbering, no arithmetization, and no proof-theoretic
syntax — we derive the entire structural skeleton of provability logic: monotonicity of
`□`; the transitivity axiom `4` (`□a ≤ □□a`); Löb's rule (`□a ≤ a ⟹ a = ⊤`); the
algebraic form of Gödel's Second Incompleteness Theorem (a consistent algebra cannot prove
its own consistency); the de Jongh–Sambin fixed-point theorem for the modalised map
`p ↦ □p ⇨ c`, including an *explicit* solution, its exact provability, and uniqueness; and
a general uniqueness theorem for arbitrary box-congruent operators. We then construct a
concrete, *consistent* model on the powerset `Set ℕ` using the provability box of the
converse well-founded frame `(ℕ, >)`, and we go beyond existence to *computation*: the
iterated falsity satisfies `□^k⊥ = {0, 1, …, k−1}`, exhibiting provability rank as the
identity on `ℕ`, a strictly increasing chain of consistency strengths that never reaches
the top, and a graded refinement of Gödel II into an explicit unprovability spectrum.
Finally we record two structural extensions: the **consistency diamond** `◇a = (□aᶜ)ᶜ`
over a Boolean Gödel–Löb algebra, shown to be a *well-founded nucleus* obeying a dual Löb
law with no topological analogue; and the lift of the entire theory from `(ℕ, >)` to every
transitive converse-well-founded frame, including the proper-class ordinal model where the
rank ladder becomes `□(Iio a) = Iio (a+1)` for every ordinal `a`. All results are
formalized and machine-checked, depending only on the standard foundational axioms.

**Keywords.** provability logic, Gödel–Löb logic, Löb's theorem, Gödel's second
incompleteness theorem, de Jongh–Sambin fixed points, Heyting algebra, well-founded
nucleus, ordinal hierarchy.

---

## 1. Introduction

Gödel's Second Incompleteness Theorem and Löb's theorem are traditionally proved by an
intricate arithmetization of metamathematics: Gödel numbering, the provability predicate
`Prov(⌜φ⌝)`, the diagonal (fixed-point) lemma, and the Hilbert–Bernays–Löb derivability
conditions. Solovay's completeness theorem then identifies the propositional logic of these
conditions as the modal logic **GL** — `K` plus the Löb axiom `□(□φ → φ) → □φ`. In this
modal presentation, the derivability conditions become axioms and the heavy syntactic
machinery recedes; what remains is a remarkably austere algebra.

This paper carries that austerity to its conclusion. We work entirely inside a Heyting
algebra with a single operator `□` constrained by three equations, and we show that the
whole structural content of GL — including Gödel II, axiom 4, and the de Jongh–Sambin
fixed-point theorem with uniqueness — is *order-theoretic*. The pivot is the recognition
that Löb's axiom is the algebraic fingerprint of **converse well-foundedness**: it both
forbids nontrivial reflexive points and forces self-transparency of provability.

Our contributions are:

1. A minimal axiomatization (`GLOperator`) and a complete derivation of the GL skeleton
   from it (§3), notably the *derivation* of axiom 4 and the *two-line* algebraic proof of
   Gödel II.
2. The de Jongh–Sambin fixed-point theorem in algebraic form — existence with an explicit
   term, exact provability, uniqueness, and a general uniqueness theorem for box-congruent
   operators (§4).
3. A concrete consistent model `(Set ℕ, natBox)` with a *computed* provability rank
   `□^k⊥ = Iio k`, a strictly increasing consistency hierarchy, and graded Gödel II (§5).
4. Two structural extensions: the consistency diamond as a well-founded nucleus (§6.1), and
   the lift to arbitrary transitive converse-well-founded frames and the ordinals (§6.2).

All statements below are formalized and machine-verified; we give mathematical proof
sketches rather than formal scripts, and the paper is self-contained.

---

## 2. Preliminaries: Heyting and Boolean algebras

A **Heyting algebra** `(H, ⊓, ⊔, ⊥, ⊤, ⇨, ≤)` is a bounded distributive lattice with a
binary *implication* `⇨` adjoint to meet: for all `a, b, c`,

> `c ≤ (a ⇨ b)  ⟺  c ⊓ a ≤ b`.    (adjunction)

We freely use the standard consequences: `a ⇨ b = ⊤ ⟺ a ≤ b`; `himp_inf_le : (a ⇨ b) ⊓ a
≤ b`; `le_himp : a ≤ b ⇨ a`; and `le_himp_iff : c ≤ a ⇨ b ⟺ c ⊓ a ≤ b`. The order `≤` is
recovered from the lattice operations, and `a ⊓ b = a ⟺ a ≤ b`.

A **Boolean algebra** is a Heyting algebra in which complementation `(·)ᶜ` is involutive
(`aᶜᶜ = a`) and `a ⇨ b = aᶜ ⊔ b`. We use de Morgan's laws `(a ⊔ b)ᶜ = aᶜ ⊓ bᶜ`,
`(a ⊓ b)ᶜ = aᶜ ⊔ bᶜ`, and order reversal `a ≤ b ⟺ bᶜ ≤ aᶜ`. The motivating example is
the powerset `Set X` with `⊓ = ∩`, `⊔ = ∪`, `⊥ = ∅`, `⊤ = X`, and `Sᶜ` the set
complement.

---

## 3. Gödel–Löb algebras and the GL skeleton

### 3.1 Definition

> **Definition 3.1 (Gödel–Löb algebra).** A *Gödel–Löb algebra* is a Heyting algebra `H`
> together with an operator `□ : H → H` satisfying
>
> - (**N**) `□⊤ = ⊤`  (necessitation of truth);
> - (**K**) `□(a ⊓ b) = □a ⊓ □b`  (normality, conjunctive form);
> - (**L**) `□(□a ⇨ a) ≤ □a`  (Löb's axiom),  for all `a, b ∈ H`.

We write `□a` for `box a`. Note that monotonicity of `□` is *not* assumed.

### 3.2 Monotonicity is a theorem

> **Lemma 3.2 (`box_mono`).** If `a ≤ b` then `□a ≤ □b`.
>
> *Proof.* From `a ≤ b` we have `a ⊓ b = a`, so by (K), `□a = □(a ⊓ b) = □a ⊓ □b ≤ □b`. ∎

Thus normality already contains monotonicity; the three axioms are leaner than the usual
presentation.

### 3.3 A normality consequence for implication

> **Lemma 3.3 (`box_himp_le`).** `□(a ⇨ b) ≤ □a ⇨ □b`.
>
> *Proof.* By the adjunction it suffices to show `□(a ⇨ b) ⊓ □a ≤ □b`. By (K) the left side
> is `□((a ⇨ b) ⊓ a)`, and `(a ⇨ b) ⊓ a ≤ b` (`himp_inf_le`), so monotonicity gives the
> result. ∎

This single fact powers all congruence arguments below.

### 3.4 Transitivity (axiom 4) is derived

> **Theorem 3.4 (`box_transitive`).** `□a ≤ □□a`.
>
> *Proof (Sambin's diagonal).* Put `c = a ⊓ □a`. By (K), `□c = □a ⊓ □□a`. We claim
> `a ≤ □c ⇨ c`: by the adjunction this is `a ⊓ □c ≤ c = a ⊓ □a`, which holds since
> `□c = □a ⊓ □□a ≤ □a`. Applying `□` and monotonicity, `□a ≤ □(□c ⇨ c)`, and Löb (L) at `c`
> gives `□(□c ⇨ c) ≤ □c`. Hence `□a ≤ □c = □a ⊓ □□a ≤ □□a`. ∎

The transitivity of provability — that provable statements are provably provable — is not
an independent postulate but a consequence of Löb's axiom.

### 3.5 The equality form of Löb and Löb's rule

> **Lemma 3.5 (`loeb_eq`).** `□(□a ⇨ a) = □a`.
>
> *Proof.* `≤` is Löb (L). For `≥`: `a ⊓ □a ≤ a` gives `a ≤ □a ⇨ a` by the adjunction, so
> `□a ≤ □(□a ⇨ a)` by monotonicity. ∎

> **Theorem 3.6 (Löb's rule, `loeb_rule`).** If `□a ≤ a` then `a = ⊤`.
>
> *Proof.* From `□a ≤ a` we get `□a ⇨ a = ⊤`, so `□(□a ⇨ a) = □⊤ = ⊤` by (N). Löb (L) then
> forces `□a = ⊤`, and `⊤ = □a ≤ a` gives `a = ⊤`. ∎

> **Corollary 3.7 (`box_fixedPoint_eq_top`).** If `□a = a` then `a = ⊤`. *The only
> self-provable element is `⊤`.*

### 3.6 Gödel's Second Incompleteness Theorem

Call a Gödel–Löb algebra **consistent** if `□⊥ ≠ ⊤`. The element `□⊥ ⇨ ⊥` is its
*consistency statement* ("if `⊥` is provable then `⊥`", i.e. "`⊥` is not provable").

> **Theorem 3.8 (Gödel II, `consistency_unprovable` / `godel_second`).** In a consistent
> Gödel–Löb algebra, `□(□⊥ ⇨ ⊥) ≠ ⊤`: the algebra cannot prove its own consistency.
>
> *Proof.* Löb (L) at `a = ⊥` reads `□(□⊥ ⇨ ⊥) ≤ □⊥`. If `□(□⊥ ⇨ ⊥) = ⊤` then `□⊥ = ⊤`,
> contradicting consistency. ∎

This is the entire content of Gödel's Second Theorem, reduced to one substitution into
Löb's axiom.

---

## 4. The de Jongh–Sambin fixed-point theorem

Self-reference in arithmetic ("this sentence is unprovable") is captured algebraically by
fixed points of *modalised* maps — maps in which the variable occurs only under `□`. The
canonical example is `p ↦ □p ⇨ c`.

### 4.1 The explicit fixed point

> **Definition 4.1 (`glFix`).** For `c ∈ H`, set `glFix c := □c ⇨ c`. With `c = ⊥` this is
> the Gödel consistency sentence `¬□⊥`.

> **Theorem 4.2 (provability of the fixed point, `glFix_box`).** `□(glFix c) = □c`.
>
> *Proof.* `glFix c = □c ⇨ c`, so `≤` is Löb (L) at `c` and `≥` is monotonicity applied to
> `c ≤ □c ⇨ c`. ∎

> **Theorem 4.3 (existence, `loeb_fixed_point`).** `glFix c = □(glFix c) ⇨ c`; i.e.
> `glFix c` is a fixed point of `p ↦ □p ⇨ c`.
>
> *Proof.* Immediate from `glFix_box`: `□(glFix c) ⇨ c = □c ⇨ c = glFix c`. ∎

### 4.2 Uniqueness

> **Theorem 4.4 (uniqueness, `glFix_unique`).** If `a = □a ⇨ c` then `a = glFix c`.
>
> *Proof.* From `a = □a ⇨ c` we get `c ≤ a` (`le_himp`), hence `□c ≤ □a`. Also
> `a ⊓ □a ≤ c` (the adjunction applied to `a ≤ □a ⇨ c`), so `□(a ⊓ □a) ≤ □c`; by (K) and
> axiom 4 (`□a ≤ □□a`, so `□a ⊓ □□a = □a`) this gives `□a ≤ □c`. Therefore `□a = □c`, and
> `a = □a ⇨ c = □c ⇨ c = glFix c`. ∎

> **Corollary 4.5 (`glFix_iff`).** `a = □a ⇨ c ⟺ a = glFix c`.

### 4.3 General uniqueness via biimplication

Define the Heyting **biimplication** `biimp a b := (a ⇨ b) ⊓ (b ⇨ a)`. Then
`biimp a b = ⊤ ⟺ a = b` (`biimp_eq_top_iff`), and `□` is a congruence for it.

> **Lemma 4.6 (`box_biimp_le`).** `□(biimp a b) ≤ biimp (□a) (□b)`.
>
> *Proof.* `biimp` is a meet of two implications; apply (K) and `box_himp_le` componentwise.
> ∎

> **Definition 4.7 (`BoxCongruent`).** An operator `f : H → H` is *box-congruent* if
> `□(biimp a b) ≤ biimp (f a) (f b)` for all `a, b`. Syntactically this captures "the
> variable occurs only under `□`".

> **Theorem 4.8 (general de Jongh–Sambin uniqueness, `modalised_fixedPoint_unique`).** A
> box-congruent operator has at most one fixed point: if `a = f a`, `b = f b`, and `f` is
> box-congruent, then `a = b`.
>
> *Proof.* Box-congruence at the fixed points gives `□(biimp a b) ≤ biimp (f a) (f b) =
> biimp a b`. Löb's rule (Theorem 3.6) applied to `biimp a b` forces `biimp a b = ⊤`, i.e.
> `a = b`. ∎

This is the conceptual core: *uniqueness of modalised fixed points is Löb's rule applied to
the biconditional of two candidate solutions*, not a fixed-point-specific miracle. We also
record that `biimp` is preserved by the maps `· ⇨ c` (`biimp_himp_const`) and `d ⊓ ·`
(`biimp_inf_const`), so the operators arising in Gödel/Henkin self-reference are
box-congruent and hence have unique fixed points.

---

## 5. A computable consistent model on `Set ℕ`

### 5.1 The well-founded frame box

The axioms could in principle be vacuous. We exhibit a concrete consistent model and then
*compute* in it.

> **Definition 5.1 (`natBox`).** On the Boolean algebra `Set ℕ`, define
> `natBox S := { n | ∀ m, m < n → m ∈ S }`.

This is the provability box of the converse well-founded frame `(ℕ, >)`: world `n` "proves"
`S` iff every strictly smaller world satisfies `S`.

> **Lemma 5.2 (`natBox_top`, `natBox_inf`).** `natBox ⊤ = ⊤` and
> `natBox (A ∩ B) = natBox A ∩ natBox B`. *(Routine.)*

> **Theorem 5.3 (Löb for `natBox`, `natBox_loeb`).**
> `natBox (natBox S ⇨ S) ≤ natBox S`.
>
> *Proof (strong induction).* Fix `n ∈ natBox(natBox S ⇨ S)`; we show every `k < n` lies in
> `S` by strong induction on `k`. Assume `m ∈ S` for all `m < k`. Then `k ∈ natBox S`. Since
> `k < n`, the hypothesis gives `k ∈ natBox S ⇨ S` (in `Set ℕ`, `X ⇨ Y = Xᶜ ∪ Y`), and with
> `k ∈ natBox S` this yields `k ∈ S`. ∎

The single appeal to transitivity of `<` (`m < k < n ⟹ m < n`) is exactly where the
abstract proof needs converse well-foundedness; see §6.2.

> **Instance 5.4 (`NatGL`).** `(Set ℕ, natBox)` is a Gödel–Löb algebra. Consequently all of
> §3–§4 — Löb's rule, the Sambin fixed point, axiom 4, Gödel II — hold for `Set ℕ`.

### 5.2 Consistency

> **Theorem 5.5 (`natGL_consistent`).** `□⊥ ≠ ⊤`. Indeed `□⊥ = natBox ∅ = {0}`.
>
> *Proof.* `0 ∈ natBox ∅` vacuously (no `m < 0`), but `1 ∉ natBox ∅` since `0 < 1` and
> `0 ∉ ∅`. So `natBox ∅ = {0} ≠ ℕ`. ∎

By Theorem 3.8 the model therefore cannot prove its own consistency (`natGL_godel_second`).

### 5.3 The provability-rank computation

> **Theorem 5.6 (rank, `natBox_iterate_eq_Iio`).** For all `k`,
> `natBox^[k] ∅ = Iio k = {0, 1, …, k−1}`.
>
> *Proof (induction on `k`).* Base: `natBox^[0] ∅ = ∅ = Iio 0`. Step: assuming
> `natBox^[k] ∅ = Iio k`, compute `natBox (Iio k) = { n | ∀ m < n, m < k } = { n | n ≤ k }
> = Iio (k+1)`, using `(∀ m < n, m < k) ⟺ n ≤ k`. ∎

Thus **provability rank is the identity on `ℕ`**: iterating the box `k` times reaches
exactly the worlds of depth `< k`.

### 5.4 The consistency hierarchy and graded Gödel II

> **Theorem 5.7 (strict hierarchy, `consistency_strength_strictMono`).** The map
> `k ↦ natBox^[k] ⊥` is strictly monotone (`Iio k ⊊ Iio (k+1)`), and no term equals `⊤`.

> **Theorem 5.8 (graded Gödel II, `godel_hierarchy`).** For every `k`, the `(k+1)`-fold
> consistency statement `natBox^[k+1] ∅ ⇨ ⊥` is unprovable: `□(natBox^[k+1] ∅ ⇨ ⊥) ≠ ⊤`.
>
> *Proof sketch.* `natBox^[k+1] ∅ = Iio (k+1)` is nonempty (contains `0, …, k`), so its
> complement omits, e.g., `k`. The box of `Iio(k+1) ⇨ ⊥ = (Iio(k+1))ᶜ` fails at a suitable
> world (the world `k+1` has the earlier world `k ∈ Iio(k+1)` as a counterexample), so the
> box is not all of `ℕ`. ∎

The level `0` is genuinely excluded: `natBox^[0] ∅ = ⊥`, whose consistency `⊥ ⇨ ⊥ = ⊤` *is*
provable. Only the nontrivial strengths `□^{k+1}⊥` are unprovable. Theorem 5.8 refines the
single Gödel II (the `k = 0` case `□⊥ = {0} ≠ ⊤`) into a strictly increasing unprovability
spectrum.

---

## 6. Structural extensions

### 6.1 The consistency diamond as a well-founded nucleus

Over a *Boolean* Gödel–Löb algebra `H`, define the **consistency / diamond operator**
`dia a := (□ aᶜ)ᶜ` (the de Morgan dual `¬□¬a`). Each box law dualises:

> **Theorem 6.1.** For all `a, b ∈ H`:
> - (`dia_compl`) `(dia a)ᶜ = □ aᶜ`;
> - (`dia_bot`) `dia ⊥ = ⊥`  (dual of (N): `dia ⊥ = (□⊤)ᶜ = ⊤ᶜ = ⊥`);
> - (`dia_sup`) `dia (a ⊔ b) = dia a ⊔ dia b`  (dual of (K), via de Morgan and `box_inf`);
> - (`dia_mono`) `a ≤ b ⟹ dia a ≤ dia b`;
> - (`dia_dia_le`) `dia (dia a) ≤ dia a`  (**sub-idempotence**, dual of axiom 4
>   `□aᶜ ≤ □□aᶜ`);
> - (`dia_loeb`) `dia a ≤ dia (a ⊓ (dia a)ᶜ)`  (**dual Löb law**);
> - (`dia_fixedPoint_eq_bot`) `dia a = a ⟹ a = ⊥`.
>
> *Proof sketches.* Each is the complement of a box law. For `dia_dia_le`: `dia(dia a) =
> (□(□aᶜ))ᶜ`, and axiom 4 gives `□aᶜ ≤ □□aᶜ`, which reverses under complement to
> `dia(dia a) ≤ (□aᶜ)ᶜ = dia a`. For `dia_loeb`: taking complements turns the goal into
> `□(a ⊓ (dia a)ᶜ)ᶜ ≤ □aᶜ`, and since `(a ⊓ (dia a)ᶜ)ᶜ = aᶜ ⊔ □aᶜ = □aᶜ ⇨ aᶜ` in a
> Boolean algebra, this is exactly Löb (L) at `aᶜ`. For `dia_fixedPoint_eq_bot`: `dia a = a`
> gives `□aᶜ = aᶜ`, so `aᶜ = ⊤` by Corollary 3.7, i.e. `a = ⊥`. ∎

The combination *deflationary* (`dia_dia_le`), *strict at the bottom* (`dia_bot`,
`dia_fixedPoint_eq_bot`), *join-preserving* (`dia_sup`), and the dual Löb law constitutes a
**well-founded nucleus** — a closure-like operator that *contracts* rather than expands and
is strict off its only fixed point `⊥`. This has no analogue among ordinary topological
closure/interior operators; the extra ingredient `dia_loeb` is converse well-foundedness
made algebraic. The development requires Boolean (not merely Heyting) structure precisely so
that `(·)ᶜ` is involutive and the duality `(dia a)ᶜ = □aᶜ` round-trips.

### 6.2 From `(ℕ, >)` to arbitrary frames and the ordinals

The `natBox` Löb proof used nothing about `ℕ` beyond transitivity and well-foundedness of
`<`. For a relation `r : α → α → Prop` define the **frame box**
`wfBox r S := { x | ∀ y, r y x → y ∈ S }`.

> **Theorem 6.2 (`wfBox_loeb`).** If `r` is transitive and well-founded, then
> `wfBox r (wfBox r S ⇨ S) ≤ wfBox r S`, so `(Set α, wfBox r)` is a Gödel–Löb algebra.
>
> *Proof sketch.* Well-founded induction on the witness `x`, with the single appeal to
> transitivity (`r p m → r m n → r p n`) exactly where the `ℕ` proof used `lt_trans`. ∎

The original model is the literal instance `natBox = wfBox (· < ·)` (`natBox_eq_wfBox`,
definitionally). Both frame conditions are necessary: dropping transitivity yields a
well-founded frame that need not validate axiom 4, hence is not GL. Instantiating at
`(Ordinal, <)` gives a Gödel–Löb algebra `OrdGL` on `Set Ordinal`, lifting the entire API
transfinitely. The rank computation becomes a successor *ladder*:

> **Theorem 6.3 (ordinal ladder, `ordBox_Iio`).** For every ordinal `a`,
> `□(Iio a) = Iio (a+1)`.
>
> *Proof sketch.* `x ∈ □(Iio a) ⟺ (∀ y < x, y < a) ⟺ x ≤ a ⟺ x < a+1`
> (`Order.lt_succ_iff`). ∎

Consequently the consistency strengths `a ↦ Iio a` form a *proper-class* strictly increasing
chain that never reaches `⊤` (`ordinal_consistency_strictMono`), and graded Gödel II holds at
every ordinal (`ordinal_godel_hierarchy`). Nothing special occurs at limit ordinals: the box
simply keeps taking successors.

---

## 7. Algorithms

The `Set ℕ`-model is decidable on bounded universes, making every theorem of §5 directly
computable. We summarize the algorithmic content.

**Algorithm A (frame box on a bounded universe).** Represent `S ⊆ {0, …, N−1}` as a bit
vector. Then `natBox S = { n < N | ∀ m < n, m ∈ S }`. Because membership of `n` depends only
on `{0, …, n−1}`, a single left-to-right sweep maintaining a "prefix-all-in-S" flag computes
`natBox S` in `O(N)` time.

**Algorithm B (provability-rank verification).** Iterate `natBox` from `∅` and compare with
`Iio k`. By Theorem 5.6 the result is `{0, …, k−1}` at every step, giving an `O(kN)`
empirical confirmation of `□^k⊥ = Iio k`.

**Algorithm C (consistency-statement evaluation).** For a target set `T`, evaluate
`□(T ⇨ ⊥) = natBox (Tᶜ)` and test equality with the universe; by Theorem 5.8 this is never
the full universe when `T = Iio(k+1)`, demonstrating graded Gödel II numerically.

---

## 8. Applications and discussion

- **Demystifying incompleteness.** Gödel II and Löb's theorem become two-line corollaries of
  a single substitution into Löb's axiom, exposing well-foundedness as the load-bearing
  principle and removing the dependence on Gödel numbering.
- **Portability.** Because the axioms mention no arithmetic, every theorem applies verbatim
  to Kripke frame algebras, the ordinals, and any Gödel–Löb algebra, including ones not yet
  identified. Incompleteness becomes a law of well-founded order.
- **Unique self-reference.** Theorem 4.8 isolates the abstract engine behind the uniqueness
  of Gödel/Henkin sentences: any guarded self-referential equation has exactly one solution.
- **A new operator class.** The consistency diamond (§6.1) is a genuinely novel structure — a
  contracting, well-founded nucleus — connecting provability logic to locale theory and
  pointing toward a "consistency topology."

**Relation to the literature.** The fixed-point and uniqueness results are the algebraic form
of the de Jongh–Sambin theorem; axiom 4 from Löb is Sambin's diagonal; Theorem 3.8 is the
modal form of Gödel's Second Theorem. Solovay's arithmetical completeness places the modal
logic GL as the provability logic of Peano Arithmetic. Our contribution is the *minimal*,
machine-checked, syntax-free packaging and the *computational* `ℕ`/ordinal models with an
explicit unprovability spectrum.

---

## 9. Future work

1. **Uniqueness of modal fixed points, fully general.** Strengthen Theorem 4.8 toward a
   constructive normal-form for fixed points of arbitrary box-guarded operators, transporting
   the well-founded descent into a Banach-style "contraction ⟹ unique fixed point" statement.
2. **Completeness against finite well-founded models.** Conjecture: an inequality of
   `□`-terms holds in every Gödel–Löb algebra iff it holds in every finite
   converse-well-founded frame `Set (Fin n)`; soundness is immediate, the hard half is a
   filtration argument.
3. **The Magari functor as a monad.** Conjecture: the free-`GLOperator` construction is a
   monad on Heyting algebras whose Eilenberg–Moore algebras are exactly the Gödel–Löb
   algebras, with axiom 4 as the comultiplication law.
4. **Ordinal rank, completed.** Extend Theorem 6.3 to the full transfinite recursion
   `□^α⊥ = ⋃_{β<α} □(□^β⊥) = Iio α` in a complete Gödel–Löb algebra, realizing a
   proper-class unprovability spectrum.
5. **The diamond as a sublocale nucleus.** Develop §6.1 into a full locale-theoretic
   account: the fixed points of `□` form a frame on which `◇` acts as a well-founded
   nucleus, with `NatGL` supplying a concrete computable locale to test every law.

---

## 10. Conclusion

Three equations — `□⊤ = ⊤`, `□(a ⊓ b) = □a ⊓ □b`, and `□(□a ⇨ a) ≤ □a` — suffice to derive
the entire structural skeleton of Gödel–Löb provability logic: monotonicity, transitivity,
Löb's rule, Gödel's Second Incompleteness Theorem, and the de Jongh–Sambin fixed-point
theorem with uniqueness. A concrete consistent model on `Set ℕ` makes provability rank
literally the identity function, yields a strictly increasing hierarchy of consistency
strengths, and refines Gödel II into an explicit unprovability spectrum that lifts to the
ordinals. The dual consistency operator emerges as a well-founded nucleus with no topological
analogue. The common thread is a single order-theoretic fact — the impossibility of infinite
descent — which Löb's axiom encodes algebraically, turning incompleteness from a peculiarity
of arithmetic into a theorem of well-founded order.
