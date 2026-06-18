# Future Directions — Dream Logic III: First-Principles Structural Core

## Synthesis

Dream Logic II (`NonMonotone.lean`) established, at the *meta level*, the sharp dichotomy
"structural rules survive paraconsistency; connective rules die," culminating in Priest's
validity characterization `lp_validity_eq_classical`. The present cycle
(`StructuralCore.lean`) rebuilds the Logic of Paradox from a three-line semantic kernel and
isolates the *structural* skeleton that is wholly orthogonal to the three-valued connective
table. Three findings crystallise the picture:

1. **Structurality without case analysis.** `eval_subst` (a one-line homomorphism induction)
   yields uniform-substitution closure `lpvalid_subst_closed`, the Tarski–Łoś defining
   property of "being a logic," touching *no* truth value.
2. **The absolute glut is a terminal model.** `eval_allbb` shows `bb` is a simultaneous
   fixpoint of `neg`/`conj`/`disj`, so the constant glut valuation models *every* formula
   (`absolute_glut_models_all`). This single fact discharges both
   `contradiction_satisfiable` and `explosion_fails`, and is precisely what the
   minimal-model semantics excises to recapture classical inference.
3. **The closure-operator view.** `Cn_idempotent` repackages reflexivity + monotonicity as
   Tarskian idempotence, and `entails_imp_entailsMin` shows recapture is conservative
   (`LP ⊆ LPm`).

Together with the validity laws `lem_valid` / `lnc_valid` — valid *despite* universal
contradiction-satisfiability — this exhibits LP as a logic that cleanly separates *validity*
from *triviality*.

## Results Summary

| Theorem | Statement | Role |
|---|---|---|
| `eval_subst` | `eval` commutes with substitution | structural engine |
| `lpvalid_subst_closed` | validity is substitution-closed | LP is a genuine logic |
| `eval_allbb` | constant-`bb` evaluates everything to `bb` | glut fixpoint |
| `absolute_glut_models_all` | one valuation models all formulas | non-triviality |
| `contradiction_satisfiable` | every `{A,¬A}` is satisfiable | paraconsistency |
| `explosion_fails` | `{p,¬p} ⊭ q` | ECNQ |
| `lem_valid` / `lnc_valid` | `⊨ A∨¬A`, `⊨ ¬(A∧¬A)` | validity ≠ triviality |
| `entails_imp_entailsMin` | `LP ⊆ LPm` | conservative recapture |
| `Cn_idempotent` | `Cn(Cn Γ)=Cn Γ` | Tarskian closure |

## Research Directions

### 1. A categorical universal property for the absolute glut

Conjecture: in the preorder of valuations ordered by the pointwise truth order with
satisfaction as morphisms, the constant-`bb` valuation is a **terminal object** for the
satisfaction relation — every formula's "designation cone" factors through it — and dually
the all-`ff` valuation is initial for refutation. The key insight is that `eval_allbb` is not
an isolated curiosity but the object-level shadow of a terminal object, so the entire
collapse/recapture machinery of Dream Logic II should be re-derivable as the unique mediating
map into that terminal object. Why now? `eval_allbb` and `collapse_preserve` (Dream Logic II)
are now both formalized, giving the two adjoint halves needed to state and test the
universal-property formulation directly in Lean. Falsifiable: exhibit a formula whose
satisfaction does *not* factor through the constant-`bb` valuation.

### 2. Structural completeness of LP

Conjecture: LP is **structurally complete** for its admissible single-conclusion rules — i.e.
every rule admissible over `entails` is already derivable — *except* on the eliminative
connective rules, which are the unique admissible-but-underivable family. The key insight is
that `lpvalid_subst_closed` upgrades from validity to the full consequence relation
(substitution-closure of `entails`), turning admissibility into a decidable property of the
3-valued matrix. Why now? With `entails` proven to be a substitution-closed Tarskian closure
operator (`Cn_idempotent`), the standard structural-completeness criterion (admissible =
derivable for unifiable premises) becomes directly checkable against the finite glut matrix.
Falsifiable: produce an admissible rule of LP that is not derivable and is not an eliminative
connective rule.

### 3. Compactness of LP-consequence

Conjecture: `entails` is **finitary/compact** — `Γ ⊢ A` iff `Γ₀ ⊢ A` for some finite
`Γ₀ ⊆ Γ` — and the proof transfers verbatim from classical compactness because LP's models
are just functions `ℕ → LPval` into a finite set. The key insight is that LP-satisfiability is
a closed condition in the product topology on `LPval^ℕ` (with `LPval` finite/discrete), so
Tychonoff gives compactness with no paraconsistency-specific work. Why now? The self-contained
`Valuation := ℕ → LPval` kernel in this file is exactly the product space Mathlib's
`Filter`/`IsCompact` API expects, so the argument can reuse existing finite-product
compactness lemmas. Falsifiable: exhibit `Γ` and `A` with `Γ ⊢ A` but no finite subset
entailing `A`.

### 4. Quantifying the recapture gap

Conjecture: the inclusion `entails ⊆ entailsMin` (`entails_imp_entailsMin`) is **strict
exactly on the consistent-but-classically-stronger fragment**, and the "gap"
`entailsMin \ entails` is in bijection with the set of classical tautological consequences
lost to gluts — i.e. `LPm` recovers *precisely* the classical/LP difference, no more. The key
insight is that minimal models are glut-free on consistent premise sets (already used in
Dream Logic II's `entailsMin_recovers_mp`), so on such sets `entailsMin` *equals* classical
consequence. Why now? Both `entails_imp_entailsMin` (this file) and `entailsMin_recovers_mp`
(Dream Logic II) are formalized, bracketing the gap from both sides; the remaining step is a
single equality theorem `entailsMin Γ = ClassicalCn Γ` for consistent `Γ`. Falsifiable:
exhibit a consistent `Γ` and `A` with `Γ ⊨_classical A` but `Γ ⊬_min A`, or vice versa.

### 5. From LP to the full Belnap–Dunn FOUR

Conjecture: adjoining a fourth value `nn` ("neither", the dual of the glut) and re-running
this exact structural development yields the bilattice FOUR with `eval_subst`,
`Cn_idempotent`, and a *pair* of terminal/initial objects (`bb` and `nn`), and the validity
laws `lem_valid`/`lnc_valid` **fail** in FOUR precisely because `nn` breaks the
designation-of-`A∨¬A`. The key insight is that LP is the designated-`{tt,bb}` sub-matrix of
FOUR, so every structural theorem here lifts unchanged while every *validity* theorem becomes
a probe distinguishing the two logics. Why now? The kernel here is parametric in the value
algebra except for `desig`; swapping in a four-element `LPval` isolates exactly which proofs
are structural (survive) versus designation-dependent (change). Falsifiable: find a structural
theorem of this file (`eval_subst`, `Cn_idempotent`, `entails_imp_entailsMin`) that *fails*
in FOUR, or a validity law that survives.
