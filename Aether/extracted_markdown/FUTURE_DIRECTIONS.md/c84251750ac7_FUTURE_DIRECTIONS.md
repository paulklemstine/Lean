# Future Directions: Propositional Logic Metatheory

The new module `Catalog/Logic/PropCompleteness.lean` closes the loop opened by the
catalog's semantics-only treatment of propositional logic (`Logic.HigherBootstrap`'s
`PropForm`, `PropForm.eval`, `PropForm.isTautology`, `PropForm.not_`,
`dne_is_tautology`, `identity_is_tautology`). It introduces a Hilbert calculus
`Proves` (axioms `ax1`, `ax2`, `ax3 = ¬¬φ→φ`, plus modus ponens), and proves the
full soundness/completeness pair:

* `soundness : Proves Γ φ → Γ ⊨ φ`;
* `deduction` / `deduction_rev` — the syntactic deduction theorem, both directions;
* `weakening`, `imp_self`, `ex_falso`, `imp_of_cons`, `imp_of_neg_ante`,
  `neg_imp_of`, `proof_by_cases` — the proof-theoretic toolkit;
* `kalmar` — Kalmár's lemma (signed literals derive the signed formula);
* `elim` — variable elimination by `Finset` induction over `proof_by_cases`;
* `completeness : IsTautology φ → Proves ∅ φ`;
* `consistency : ¬ Proves ∅ ⊥` and `completeness_iff` (adequacy).

The directions below build directly on these certified theorems.

## 1. Strong completeness for finite theories

The current `completeness` discharges the *empty* theory. The natural strengthening
is **strong completeness**: for `Γ : Finset PropForm`,
`(∀ v, (∀ ψ ∈ Γ, eval v ψ) → eval v φ) → Proves ↑Γ φ`. The key insight is that the
already-proven `deduction`/`deduction_rev` let us trade a finite context for an
iterated implication `Γ.foldr PropForm.imp φ`: semantic consequence from `Γ` is
exactly tautologyhood of that single formula, which `completeness` already settles,
and `deduction_rev` reinstalls the hypotheses one by one. Why now? Both halves of
the bridge — the deduction theorem and empty-theory completeness — are finished and
sorry-free in this file, so the remaining work is a clean induction on `Γ` rather
than new metatheory.

**Testable conjecture.** `theorem strong_completeness (Γ : Finset PropForm) (φ)
  (h : ∀ v, (∀ ψ ∈ Γ, PropForm.eval v ψ = true) → PropForm.eval v φ = true) :
  Proves (↑Γ) φ`.

## 2. Propositional compactness from finiteness of derivations

Once strong completeness is available, **compactness** becomes accessible: if every
finite subset of an arbitrary `Γ : Set PropForm` is satisfiable, then `Γ` is
satisfiable. The key insight is the dual finiteness already baked into our `Proves`
inductive — every derivation mentions only finitely many premises, so
`Proves Γ φ → ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Proves ↑Δ φ` is provable by induction
on the derivation, and compactness is its semantic shadow via soundness/completeness.
Why now? The `premise` constructor is the only place context is consumed, so the
finite-support lemma is a direct structural induction over the calculus we just built.

**Testable conjecture.** `theorem finite_support {Γ φ} (h : Proves Γ φ) :
  ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Proves (↑Δ) φ`, followed by
`Models Γ φ → ∃ Δ : Finset PropForm, ↑Δ ⊆ Γ ∧ Models (↑Δ) φ`.

## 3. Independence of the classical axiom `ax3`

The boundary note in the file claims that `ax3` (double-negation elimination) is
essential. This should be made into a theorem: the **intuitionistic** subsystem
`ProvesI` (axioms `ax1`, `ax2`, ex-falso, modus ponens, *without* `ax3`) is strictly
weaker. The key insight is to interpret formulas in a three-element Heyting algebra
(or a two-world Kripke frame) under which `ax1`, `ax2`, ex-falso are all valid but
`¬¬(var 0) → var 0` is not, giving a non-derivability witness by a soundness argument
against that algebraic semantics. Why now? Our `soundness` proof is a template:
swapping the Boolean target for a finite Heyting algebra reuses the same induction,
and the `examples` in the file already pinpoint DNE as the separating formula.

**Testable conjecture.** With `ProvesI` the ax3-free calculus,
`¬ ProvesI ∅ (.imp (PropForm.not_ (PropForm.not_ (.var 0))) (.var 0))`, proved by a
Heyting/Kripke soundness lemma for `ProvesI`.

## 4. Craig interpolation via the variable-aware Kalmár machinery

Craig's theorem — `Proves ∅ (imp φ ψ)` yields an interpolant `θ` with
`vars θ ⊆ vars φ ∩ vars ψ`, `Proves ∅ (imp φ θ)`, `Proves ∅ (imp θ ψ)` — fits our
infrastructure unusually well. The key insight is that our `vars` function and the
`signed`/`ctxF` apparatus already track *exactly which variables* a derivation can
depend on; the interpolant can be built semantically as a disjunction of the shared-
variable diagrams under which `φ` is true, and `completeness` certifies each required
implication. Why now? `vars`, `signed`, `ctxF`, and `completeness_iff` give a ready
language for stating and discharging the variable-containment side conditions that
make interpolation hard to even formalize from scratch.

**Testable conjecture.** `theorem interpolation {φ ψ} (h : Proves ∅ (.imp φ ψ)) :
  ∃ θ, vars θ ⊆ vars φ ∩ vars ψ ∧ Proves ∅ (.imp φ θ) ∧ Proves ∅ (.imp θ ψ)`.

## 5. A certified resolution/DPLL decision procedure

Finally, turn the metatheory into verified automation: implement a CNF-resolution
checker `resolve : List (List (ℕ × Bool)) → Bool` and prove it sound and complete
against `eval`, with refutations exported as `Proves` derivations. The key insight is
that a resolution step is a constrained `mp`/cut, so each step can be elaborated into
our Hilbert calculus, making `completeness_iff` the correctness specification "for
free": a `true` answer must correspond to an actual `Proves ∅` certificate, and a
`false` answer to a falsifying valuation. Why now? `completeness_iff` already equates
the operational target (provability) with the semantic spec (tautologyhood), so the
decision procedure only has to be shown to refine one side.

**Testable conjecture.** `theorem resolve_sound (clauses) (h : resolve clauses = true) :
  ∀ v : PropValuation, ∃ c ∈ clauses, ∀ l ∈ c, evalLit v l = false`, plus a
completeness companion producing a `Proves ∅` certificate of the corresponding CNF
tautology.
