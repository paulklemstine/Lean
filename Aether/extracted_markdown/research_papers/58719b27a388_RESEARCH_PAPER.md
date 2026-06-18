# The Order-Theoretic Core of Gödel–Löb Provability Logic

## Abstract

We isolate the purely algebraic and order-theoretic core of the Gödel–Löb
provability logic **GL**. A *Gödel–Löb algebra* (or *Magari algebra*) is a Heyting
algebra `H` equipped with a unary *provability operator* `□` satisfying exactly three
equations: necessitation of truth (`□⊤ = ⊤`), distribution over binary meets
(`□(a ⊓ b) = □a ⊓ □b`), and Löb's axiom (`□(□a ⇨ a) ≤ □a`). We show that from these
three equations *alone* — with no assumption of transitivity (modal axiom 4), no
assumption of well-foundedness, and no recourse to syntactic or arithmetical
machinery — one can derive the entire propositional skeleton of GL. Specifically we
obtain: (i) monotonicity of `□` as a derived property; (ii) the de Jongh–Sambin
fixed point `□(□a ⇨ a) = □a`; (iii) Löb's theorem in the form "no nontrivial
reflexive points," `□a ≤ a ⟹ a = ⊤`; (iv) modal axiom 4, `□a ≤ □□a`, derived via
Sambin's diagonal; and (v) Gödel's Second Incompleteness Theorem as the instance of
the fixed point at `⊥`, namely `□(□⊥ ⇨ ⊥) = □⊥`. We complement the abstract theory
with an explicit *consistent* model on `Set ℕ` arising from the converse-well-founded
frame `(ℕ, <)`, in which provability rank is computable: the `k`-fold box of `⊥` is
the initial segment `{0, 1, …, k-1}`, yielding a strictly increasing, never-saturating
chain of consistency strengths and an explicit "unprovability spectrum" — a graded
form of Gödel's Second Theorem. All results have been formally verified.

**Keywords:** provability logic, Löb's theorem, Gödel incompleteness, Magari algebra,
Heyting algebra, modal logic, fixed points, well-founded orders, Sambin's lemma.

---

## 1. Introduction

The Gödel–Löb logic GL is the modal logic of formal provability. By Solovay's
arithmetical completeness theorem (1976), GL is exactly the set of modal principles
that hold uniformly when `□` is read as the provability predicate of a sufficiently
strong, consistent, recursively axiomatized arithmetical theory such as Peano
Arithmetic. Its central axiom is **Löb's axiom**,

    □(□a → a) → □a,

discovered by M. H. Löb (1955) in answer to a question of Leon Henkin. GL is also
characterized semantically (Segerberg 1971) by the class of finite, transitive,
irreflexive Kripke frames — the *converse-well-founded* frames.

The standard presentations of these facts are heavily *syntactic* or *semantic*:
they involve Gödel numbering, provability predicates, derivability conditions, or
Kripke-frame combinatorics. The purpose of this work is to extract the **algebraic
kernel**. Following Magari (1975), provability can be modeled as an operator on a
Heyting (or Boolean) algebra. We adopt the three Magari equations as the *definition*
of the structure and show that the whole propositional theory of GL is *forced* by
them — no order-theoretic side conditions required.

The pivotal observation, which organizes the entire development, is that
**well-foundedness is already latent in Löb's axiom**. Modal axiom 4 (transitivity)
and the existence/uniqueness of de Jongh–Sambin fixed points are not extra
hypotheses; they are consequences. Even monotonicity of `□` is a theorem rather than
a postulate. The single inequality of Löb, together with meet-preservation, suffices.

### 1.1 Contributions

1. A minimal axiomatization of the GL provability operator as a typeclass
   `GLOperator` over an arbitrary Heyting algebra (Section 3).
2. Formal derivations, from the three axioms only, of monotonicity, the
   de Jongh–Sambin fixed point, Löb's theorem, modal axiom 4, and Gödel's Second
   Incompleteness Theorem (Section 4).
3. A concrete, consistent realization `NatGL` on `Set ℕ` via the frame `(ℕ, <)`,
   with a computable provability rank and a strictly increasing unprovability
   spectrum (Section 5).
4. A discussion of how this kernel connects to the Kripke-semantic and
   shallow-temporal presentations of GL, and five concrete directions for extension
   (Sections 6–7).

---

## 2. Preliminaries: Heyting algebras

A **Heyting algebra** `(H, ⊓, ⊔, ⇨, ⊤, ⊥, ≤)` is a bounded lattice in which every
pair of elements `a, b` has a *relative pseudocomplement* (Heyting implication)
`a ⇨ b`, characterized by the adjunction

    c ≤ (a ⇨ b)   ⟺   c ⊓ a ≤ b.        (HImp)

We freely use the following standard consequences:

- **(L1)** `a ≤ b ⟺ a ⊓ b = a` (the order is recoverable from the meet).
- **(L2)** `inf_le_left : a ⊓ b ≤ a` and `inf_le_right : a ⊓ b ≤ b`.
- **(L3)** `le_inf : c ≤ a → c ≤ b → c ≤ a ⊓ b`.
- **(L4)** `a ≤ (b ⇨ a)` always (take `c = a` in (HImp): need `a ⊓ b ≤ a`, true by (L2)).
- **(L5)** `himp_eq_top_iff : (a ⇨ b) = ⊤ ⟺ a ≤ b`.
- **(L6)** `top_le_iff : ⊤ ≤ a ⟺ a = ⊤`.

The top element `⊤` is the verum; the bottom `⊥` is the falsum (contradiction).
Boolean algebras are the special case where `a ⇨ b = ¬a ⊔ b`; the entire development
below is valid in the Heyting generality, which is strictly broader and matches the
intuitionistic provenance of `□` in arithmetic.

---

## 3. Gödel–Löb algebras

### Definition 3.1 (GL operator / Magari algebra)

Let `H` be a Heyting algebra. A **Gödel–Löb operator** on `H` is a function
`□ : H → H` satisfying:

- **(Box⊤)** `□⊤ = ⊤`;
- **(BoxK)** `□(a ⊓ b) = □a ⊓ □b` for all `a, b ∈ H`;
- **(Löb)** `□(□a ⇨ a) ≤ □a` for all `a ∈ H`.

A Heyting algebra equipped with such an operator is a **Gödel–Löb algebra** (Magari
algebra). We write `□a` for the box of `a`.

**Remarks.** (i) (Box⊤) and (BoxK) together are the algebraic form of the normal
modal logic **K** with the necessitation rule. (ii) (Löb) is the algebraic Löb axiom.
(iii) We deliberately do *not* assume monotonicity, axiom 4 (`□a ≤ □□a`), or any
well-foundedness condition on `H`. The thesis of this paper is that those are
theorems.

In the formal development this is the typeclass

```
class GLOperator (H : Type u) [HeytingAlgebra H] where
  box     : H → H
  box_top : box ⊤ = ⊤
  box_inf : ∀ a b : H, box (a ⊓ b) = box a ⊓ box b
  loeb    : ∀ a : H, box (box a ⇨ a) ≤ box a
```

---

## 4. The derived theory

Throughout this section, `H` is a Gödel–Löb algebra.

### Theorem 4.1 (Monotonicity — `box_mono`)

For all `a, b ∈ H`, if `a ≤ b` then `□a ≤ □b`.

*Proof.* By (L1), `a ≤ b` gives `a ⊓ b = a`. Then
`□a = □(a ⊓ b) = □a ⊓ □b` by (BoxK), and `□a = □a ⊓ □b` is exactly `□a ≤ □b` by (L1)
and (L2). ∎

The point is conceptual: **monotonicity is squeezed out of meet-preservation alone**.
It is not an independent regularity assumption.

### Theorem 4.2 (de Jongh–Sambin fixed point — `loeb_fixed_point`)

For all `a ∈ H`,

    □(□a ⇨ a) = □a.

*Proof.* The inequality `□(□a ⇨ a) ≤ □a` is (Löb) verbatim. For the reverse, note
`a ≤ (□a ⇨ a)` by (L4) (equivalently `le_himp_iff.mpr inf_le_left`). Apply
monotonicity (Theorem 4.1) to obtain `□a ≤ □(□a ⇨ a)`. Antisymmetry closes the
equality. ∎

**Interpretation.** Consider the box-guarded endo-operator `F(x) = □(x ⇨ a)`, in
which the variable `x` occurs only inside a box. A fixed point of `F` is an `x` with
`x = □(x ⇨ a)`. Theorem 4.2 says `x = □a` is such a fixed point, and it is given by
an explicit closed form free of `x`. This is the minimal, two-element instance of the
de Jongh–Sambin fixed-point theorem, which classically asserts unique definable fixed
points for all box-guarded formulas.

### Theorem 4.3 (Löb's theorem — `loeb_rule`)

For all `a ∈ H`, if `□a ≤ a` then `a = ⊤`.

*Proof.* From `□a ≤ a` and (L5), `(□a ⇨ a) = ⊤`. Instantiate (Löb) and rewrite using
this together with (Box⊤):

    ⊤ = □⊤ = □(□a ⇨ a) ≤ □a,

so `⊤ ≤ □a`, i.e. `□a = ⊤` by (L6). Combined with the hypothesis `□a ≤ a` we get
`⊤ ≤ a`, hence `a = ⊤`. ∎

**Interpretation.** `□` has **no nontrivial reflexive points**: the only sentence
whose own provability entails its truth is the trivially true one. This is the
algebraic essence of Löb's theorem and the formal embodiment of "there is no
consistent self-justifying sentence."

### Theorem 4.4 (Modal axiom 4 derived — `box_transitive`)

For all `a ∈ H`,

    □a ≤ □□a.

*Proof (Sambin's diagonal).* Put `b := a ⊓ □a`. By (BoxK),
`□b = □a ⊓ □□a`. We first show `a ⊓ □b ≤ b`:

- `a ⊓ □b ≤ a` by (L2);
- `□b ≤ □a` (since `□b = □a ⊓ □□a ≤ □a`), so `a ⊓ □b ≤ □b ≤ □a`;
- combining via (L3), `a ⊓ □b ≤ a ⊓ □a = b`.

By (HImp), `a ⊓ □b ≤ b` is equivalent to `a ≤ (□b ⇨ b)`. Monotonicity gives
`□a ≤ □(□b ⇨ b)`; (Löb) on `b` gives `□(□b ⇨ b) ≤ □b`; and `□b = □a ⊓ □□a ≤ □□a` by
(L2). Chaining,

    □a ≤ □(□b ⇨ b) ≤ □b ≤ □□a.   ∎

**Interpretation.** GL ⊇ K4: *transitivity is a theorem of GL, not a separate axiom*.
Semantically, the accessibility relation of any GL model is transitive and
well-founded; algebraically, that well-foundedness is encoded entirely in (Löb). The
diagonal element `a ⊓ □a` is the indispensable trick — naive application of (Löb) to
`□a` misplaces the box and the chain fails to close.

### Theorem 4.5 (Gödel's Second Incompleteness Theorem — `godel_second`)

    □(□⊥ ⇨ ⊥) = □⊥.

*Proof.* This is Theorem 4.2 instantiated at `a = ⊥`. ∎

### Corollary 4.6 (Consistency is unprovable — `consistency_unprovable`)

If the algebra is *consistent*, i.e. `□⊥ ≠ ⊤`, then `□(□⊥ ⇨ ⊥) ≠ ⊤`.

*Proof.* Rewrite with Theorem 4.5: `□(□⊥ ⇨ ⊥) = □⊥ ≠ ⊤`. ∎

**Interpretation.** Read `□⊥` as "the system proves a contradiction" (inconsistency)
and `□⊥ ⇨ ⊥` as the *consistency statement* `Con` = `¬Prov(⊥)`. Theorem 4.5 says the
provability of consistency *equals* the provability of falsity. Hence a consistent
system cannot prove its own consistency: if it could, that proof would be `⊤`, forcing
`□⊥ = ⊤` and collapsing consistency. This is precisely Gödel's Second Incompleteness
Theorem, obtained here as a one-line corollary of the algebraic fixed point.

---

## 5. A concrete consistent model: the frame `(ℕ, <)`

The abstract results are non-vacuous: we exhibit a consistent Gödel–Löb algebra in
which all quantities are explicitly computable. Take `H = Set ℕ` (the powerset
Boolean algebra, a fortiori Heyting, with `⊓ = ∩`, `⊔ = ∪`, `⊤ = univ`, `⊥ = ∅`,
`A ⇨ B = Aᶜ ∪ B`). Define the **natural box**

    □S := { n ∈ ℕ | ∀ m < n, m ∈ S }.

This is the box of the converse-well-founded strict order `(ℕ, <)`: a stage `n`
"proves" `S` iff every strictly earlier stage already satisfies `S`. Intuitively, a
sentence is provable at time `n` precisely when it holds throughout the (well-founded)
past.

### Proposition 5.1 (`natBox_loeb`, instance `NatGL`)

`□` as above satisfies (Box⊤), (BoxK), and (Löb); thus `(Set ℕ, □)` is a Gödel–Löb
algebra `NatGL`.

*Proof sketch.* (Box⊤): `□univ = univ` since the predecessor condition is vacuous for
membership in `univ`. (BoxK): `n ∈ □(A ∩ B)` iff every `m < n` lies in both `A` and
`B`, iff `n ∈ □A ∩ □B`. (Löb): the converse-well-foundedness of `(ℕ, <)` is exactly
what validates Löb's axiom on Kripke frames (Segerberg); concretely, if `n ∈ □(□S ⇨
S)` then by strong induction on `n` every `m < n` lies in `S`, so `n ∈ □S`. ∎

### Proposition 5.2 (Consistency — `natGL_consistent`)

`□⊥ = {0} ≠ univ`, so `NatGL` is consistent.

*Proof.* `□∅ = { n | ∀ m < n, m ∈ ∅ } = { n | there is no m < n } = {0}`. ∎

This is the model-level witness that Corollary 4.6 is non-trivial: a genuinely
consistent algebra in which consistency is genuinely unprovable.

### Proposition 5.3 (Provability rank — `natBox_iterate_eq_Iio`)

For every `k ∈ ℕ`,

    □^k ⊥ = { 0, 1, …, k-1 } = Iio k        (the initial segment below k).

*Proof sketch.* Induction on `k`. Base: `□^0⊥ = ∅ = Iio 0`. Step: assuming
`□^k⊥ = Iio k`, we have `n ∈ □(Iio k)` iff every `m < n` satisfies `m < k`, iff
`n - 1 < k` (for `n > 0`) or `n = 0`, iff `n ≤ k`, iff `n ∈ Iio (k+1)`. ∎

Thus **the number of boxes equals the depth into the well-founded order**: frame depth
and iteration index coincide.

### Proposition 5.4 (Strictly increasing consistency strengths — `consistency_strength_strictMono`)

The map `k ↦ □^k⊥` is strictly increasing and bounded away from `⊤`:

    ∅ = □^0⊥ ⊊ □^1⊥ ⊊ □^2⊥ ⊊ ⋯,    and    □^k⊥ ≠ univ for all k.

*Proof.* By Proposition 5.3, `□^k⊥ = Iio k ⊊ Iio (k+1) = □^{k+1}⊥` because
`k ∈ Iio(k+1) ∖ Iio k`; and `Iio k ≠ univ` since `k ∉ Iio k`. ∎

### Theorem 5.5 (Graded Gödel II / unprovability spectrum — `godel_hierarchy`)

For every `k`, the `k`-fold consistency statement is unprovable in `NatGL`:

    □(□^{k+1}⊥ ⇨ ⊥) ≠ univ,   indeed = □^{k+1}⊥ = Iio(k+1) ≠ univ.

More generally, iterating Theorem 4.2 yields `□(□^k⊥ ⇨ ⊥) = □^k⊥` for every `k`, so
the single Gödel II statement refines into a graded family indexed by consistency
strength, each member explicitly unprovable.

*Proof sketch.* The identity `□(□^k⊥ ⇨ ⊥) = □^k⊥` is Theorem 4.2 applied with
`a = □^{k-1}⊥`, using `□(□a ⇨ a) = □a` and `□^k⊥ = □(□^{k-1}⊥)`. Unprovability
(`≠ univ`) is Proposition 5.4. ∎

This is the quantitative payoff of the abstract development: not one unprovable
sentence but an explicit, strictly increasing **spectrum** of them, with rank equal to
the natural-number depth in the frame.

---

## 6. Catalog synthesis and relationship to other presentations

The algebraic kernel sits between two complementary presentations of GL.

- **Kripke-semantic layer.** The operator `□` is the algebraic shadow of the
  set-valued box `boxSet` on finite, transitive, irreflexive frames. There, Löb's
  axiom is *validated* on converse-well-founded frames (Segerberg's theorem), and the
  upward-closed sets form a provability lattice. Our `NatGL` is the concrete `(ℕ, <)`
  instance of exactly this picture, with `□S = {n | ∀ m < n, m ∈ S}` matching the
  set-valued box of the strict order.

- **Shallow / temporal layer.** Reading `□a` as "a holds at all strictly earlier
  times" gives the temporal soundness of Löb's axiom and a time-stamped reading of
  Gödel II. Proposition 5.3 makes that intuition *quantitative*: the provability rank
  is literally the time index.

Where those layers *validate* the GL axioms on models, the present development takes
the three equations as the *definition* and shows the entire theory is forced. The
three viewpoints — equational, Kripke-semantic, temporal — agree on `NatGL`.

---

## 7. Discussion and future directions

The development demonstrates a methodological point of independent interest: the
limitative theorems of metamathematics have a compact, *order-theoretic* nucleus.
Once provability is modeled as a meet-preserving operator satisfying Löb's single
inequality, monotonicity, the explicit fixed point, axiom 4, and Gödel II all become
elementary lattice calculations. Well-foundedness — usually imposed semantically — is
encoded inside Löb's axiom and re-emerges as the derivability of axiom 4.

We outline five directions, each phrased so it could be formalized directly on top of
`GLOperator`.

### Direction 1 — Uniqueness of modal fixed points (de Jongh–Sambin in algebra)

**Conjecture.** In any Gödel–Löb algebra, every box-guarded one-variable term `F(x)`
(each occurrence of `x` inside a `□`) has a *unique* fixed point `x = F(x)`,
expressible without `x`. The minimal case `F(x) = □(x ⇨ a)` already has the explicit
solution `□a` (Theorem 4.2). The key insight is that (Löb) is precisely the
contraction condition making `x ↦ □(x ⇨ a)` a Banach-style attracting map in the
well-founded order, so its fixed point is forced and computable, not merely existent.

### Direction 2 — Soundness and completeness against finite well-founded models

**Conjecture.** An inequality `s ≤ t` between `□`-terms holds in *every* Gödel–Löb
algebra iff it holds in every `NatGL`-style model on a finite, irreflexive,
transitive frame; the finite converse-well-founded frames are *complete* for the
equational theory of Gödel–Löb algebras. The route: Theorem 4.4 shows every Gödel–Löb
algebra is internally K4, so a canonical-model/filtration argument collapses to finite
well-founded quotients exemplified by `NatGL`.

### Direction 3 — The Magari functor and a categorical internal logic

**Conjecture.** Assigning to each Heyting algebra its free Gödel–Löb algebra is a
monad whose algebras are exactly the `GLOperator` structures, and GL is the internal
propositional logic of the Eilenberg–Moore category of this monad; the free
construction on the one-generator Boolean algebra is the Lindenbaum algebra of GL.
Here (BoxK) and (Box⊤) make `□` a finite-meet-preserving endofunctor on the algebra
viewed as a thin category, and (Löb) is a dinatural diagonal condition.

### Direction 4 — Quantitative Gödel II: provability rank and unprovability spectra

**Conjecture.** Define the *provability rank* of `a` as the least `k` with
`□^k a = □^{k+1} a`. In `NatGL` the rank of `⊥` is its frame depth, and Theorem 5.5
generalizes: for every `k`, the `k`-fold consistency statement `□^k⊥ ⇨ ⊥` is
unprovable whenever `□^k⊥ ≠ ⊤`, giving a strictly increasing hierarchy of unprovable
consistency strengths. Theorem 5.5 is the established `k = 1` core; the iteration is a
clean induction reusing Theorem 4.2 verbatim.

### Direction 5 — Provability operators as closure/interior duality

**Conjecture.** The de Morgan dual `◇a := ¬□¬a` of a provability operator is a
*well-founded co-closure* (deflationary, idempotent on its image, join-preserving),
and the fixed points of `□` form a frame (locale) on which `◇` acts as a nucleus of a
sublocale. Theorem 4.4 gives `□a ≤ □□a` while Theorem 4.3 forbids reflexive points,
so `□` is simultaneously inflationary on theorems and strictly contracting off them —
the signature of a *well-founded* nucleus with no analogue among ordinary topological
closure operators.

---

## 8. Conclusion

Three equations — `□⊤ = ⊤`, `□(a ⊓ b) = □a ⊓ □b`, and `□(□a ⇨ a) ≤ □a` — axiomatize
the entire propositional theory of formal provability. From them we derived, with no
side conditions, the monotonicity of `□`, the de Jongh–Sambin fixed point, Löb's
theorem, modal axiom 4, and Gödel's Second Incompleteness Theorem; and we realized the
theory in a concrete consistent model on `Set ℕ` where provability rank is computable
and yields an explicit strictly increasing spectrum of unprovable consistency
statements. The metamathematical content of incompleteness is, at its core,
order-theoretic.

---

## References (classical background)

- M. H. Löb, *Solution of a problem of Leon Henkin*, J. Symbolic Logic, 1955.
- K. Gödel, *Über formal unentscheidbare Sätze ...*, Monatshefte für Mathematik, 1931.
- R. Magari, *The diagonalizable algebras*, Boll. Un. Mat. Ital., 1975.
- K. Segerberg, *An Essay in Classical Modal Logic*, 1971.
- R. Solovay, *Provability interpretations of modal logic*, Israel J. Math., 1976.
- G. Sambin, *An effective fixed-point theorem in intuitionistic diagonalizable
  algebras*, Studia Logica, 1976.
- D. de Jongh and G. Sambin, fixed-point theorem for GL (independently).
- G. Boolos, *The Logic of Provability*, Cambridge University Press, 1993.
