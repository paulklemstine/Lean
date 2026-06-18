# Future Directions: Provability Logic as a Fixed-Point Theory

## Synthesis of this cycle

The previous cycle built the **order-theoretic core of Gödel–Löb provability logic `GL`**
in `Catalog/Logic/LobFixedPoint.lean`: from the three `GLOperator` axioms alone
(`□⊤ = ⊤`, `□(a ⊓ b) = □a ⊓ □b`, Löb `□(□a ⇨ a) ≤ □a`) it derived axiom 4, Gödel II, and
the **one-parameter** de Jongh–Sambin fixed point `glFix c = □c ⇨ c` (existence, the
provability value `□(glFix c) = □c`, and uniqueness). It also left three congruence lemmas
(`box_biimp_le`, `biimp_himp_const`, `biimp_inf_const`) standing idle — clearly staged for
a sequel.

This cycle wrote that sequel, `Catalog/Logic/CloseProofs.lean`, closing the **two-parameter**
de Jongh–Sambin theorem for the genuinely general modalised context

> `Φ_{c,d}(p) = d ⊓ (□p ⇨ c)`.

The deliverables (all `sorry`-free, axiom profile `[propext]` only):

- `gl2 c d := d ⊓ (□(d ⊓ c) ⇨ c)` — the **explicit** fixed point;
- `gl2_box : □(gl2 c d) = □(d ⊓ c)` — the Löb-iteration crux;
- `gl2_fixed_point` — existence; `gl2_unique` / `gl2_iff` — uniqueness & characterisation
  (the idle congruence lemmas finally compose into `boxCongruent_inf_himp`, then
  `modalised_fixedPoint_unique` discharges uniqueness "for free");
- `gl2_eq_glFix : gl2 c ⊤ = glFix c` — strict generalisation of the prior cycle;
- `gl2_bot_not_provable` — a consistency corollary at `c = ⊥`.

**Results summary.** The fixed-point theory of `GL` is now closed in *two* parameters from
pure order theory, and the value `□(gl2 c d) = □(d ⊓ c)` (not the naive `□c`) pinpoints
exactly how a side conjunct contributes provability strength.

---

## Direction 1 — Closed-form fixed points for *all* one-variable modal contexts

**Conjecture.** For every modal context built from `□`, `⊓`, `⊔`, `⇨` with the variable `p`
occurring only under `□`, the de Jongh–Sambin fixed point admits a closed form obtained by
the substitution scheme `A(□A(⊤))` — the same scheme that produced `glFix c = (□c ⇨ c)` from
`A(x) = x ⇨ c` and `gl2 c d = d ⊓ (□(d⊓c) ⇨ c)` from `A(x) = d ⊓ (x ⇨ c)`.

The key insight is that both solved cases are the *single* identity `fixedpoint = A(□A(⊤))`
specialised, and that `□A(⊤)` is computable by one Löb collapse per `□` in `A`; the side
condition "variable only under `□`" is precisely box-congruence, which already powers
uniqueness. This is falsifiable: exhibit a box-congruent `A` whose genuine fixed point
differs from `A(□A(⊤))`, or prove the identity by structural induction on contexts in Lean.

Why now? The two worked instances in `CloseProofs.lean` are exactly the two atomic context
shapes (`· ⇨ c` antitone, `d ⊓ ·` monotone); the induction only needs the `⊔` step and the
nesting step, both within reach of `box_biimp_le` plus the existing `biimp_*_const` toolkit.

## Direction 2 — Simultaneous fixed points (vectorial de Jongh–Sambin)

**Conjecture.** A system `pᵢ = Aᵢ(□p₁, …, □pₙ)` of box-congruent equations has a unique
joint solution, given componentwise by an explicit term, generalising `gl2`.

The key insight is that uniqueness needs no new idea: the product Heyting algebra `Hⁿ` with
the diagonal box `□(x₁,…,xₙ) = (□x₁,…,□xₙ)` is again a `GLOperator`, so the *scalar*
`modalised_fixedPoint_unique` applied in `Hⁿ` already yields vectorial uniqueness — the
whole system is one box-congruent endomap of `H⁛`. This is falsifiable by either constructing
the product `GLOperator` instance and deriving uniqueness, or finding a two-equation system
with two distinct solutions (which would refute box-congruence of the diagonal box).

Why now? `Catalog/Logic/GLProductBox.lean` already studies product box operators; bridging it
to `CloseProofs.lean`'s `BoxCongruent` machinery is a concrete cross-file synthesis.

## Direction 3 — The explicit value `□(d ⊓ c)` as a strength-grading invariant

**Conjecture.** The map `(c, d) ↦ □(gl2 c d) = □(d ⊓ c)` is a lattice homomorphism in each
argument and its fibres stratify fixed points by "provability strength", refining the rank
stratification of `Catalog/Logic/GLRankStratification.lean`.

The key insight is that `gl2_box` turns a self-referential object into the *non*-modal datum
`□(d ⊓ c)`, so questions about fixed points (e.g. when two parametrised Gödel sentences are
equiprovable) reduce to equalities `□(d ⊓ c) = □(d' ⊓ c')` in the base algebra — decidable in
the concrete `(Set ℕ, natBox)` model where `□` is the `Iio`-closure. Falsifiable: compute the
fibres in `LobNatModel` and check whether they match the rank strata.

Why now? `gl2_box` is the first cycle to expose the provability value of a *parametrised*
fixed point in closed form, making the grading map concrete for the first time.

## Direction 4 — Henkin vs. Gödel sentences via the side conjunct

**Conjecture.** Within `Φ_{c,d}`, the "Gödel pole" `d = ⊤` (sentence ⇔ "if I'm provable then
`c`") and the "Henkin pole" obtained by tuning `c` toward `⊤` interpolate continuously, and
`gl2 c d` is provable (`□(gl2 c d) = ⊤`) iff `□(d ⊓ c) = ⊤`, i.e. iff `d ⊓ c` is a theorem.

The key insight is that `gl2_box` *reduces provability of the self-referential sentence to
provability of the plain conjunction `d ⊓ c`*, dissolving the apparent paradox of Henkin
sentences ("I am provable") into an ordinary derivability question with no fixed-point magic.
Falsifiable: in `LobNatModel`, find `c, d` with `□(d ⊓ c) = ⊤` but `gl2 c d` not the top
theory — which would refute `gl2_box`.

Why now? `gl2_bot_not_provable` already handles the `c = ⊥` (consistency) extreme; the general
provability criterion is the immediate corollary `□(gl2 c d) = ⊤ ↔ □(d ⊓ c) = ⊤`.

## Direction 5 — Transfer to Kripke semantics and arithmetic completeness

**Conjecture.** Every theorem of `CloseProofs.lean` transfers, via Solovay-style arithmetical
realisation, to a statement about parametrised provability predicates in `PA`; concretely,
`gl2 c d` realises the unique `PA`-sentence `σ ⇔ (D ∧ (Prov⌜σ⌝ → C))`, and `gl2_box` predicts
its exact provability behaviour.

The key insight is that the order-theoretic proofs are *frame-agnostic*: they use only the
`GLOperator` axioms, which `Catalog/Logic/GLKripke.lean` validates on finite transitive
irreflexive frames and which the standard arithmetical box satisfies; so the bridge is a
single instance, not a re-proof. Falsifiable by constructing the `GLOperator` instance on the
Lindenbaum algebra of `GL` (or a finite frame's powerset) and checking `gl2` against a
hand-computed Kripke fixed point.

Why now? With both the one- and two-parameter fixed points closed purely algebraically, the
only remaining gap to "real" provability logic is the single semantic-bridge instance, which
the existing `GLKripke` / `LobNatModel` models put within reach.
