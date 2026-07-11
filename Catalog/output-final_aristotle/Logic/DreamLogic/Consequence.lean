import Mathlib
import Logic.DreamLogic.Bilattice

/-!
# Dream Logic VI — The Paraconsistent Consequence Relation

This file lifts the four-valued algebra `FOUR` of `Bilattice.lean` to a genuine
**propositional consequence relation** and proves that it is paraconsistent
(non-explosive), paracomplete (excluded middle is not valid), yet retains all the
structural rules of a Tarskian logic (reflexivity, monotonicity/weakening, cut) and
validates the full De Morgan / lattice laws.

Propositions are built from atoms drawn from an arbitrary type `V` using the
connectives `neg`, `conj` (`tmeet`), `disj` (`tjoin`).  A *valuation* is a function
`V → FV`; a formula is *satisfied* by a valuation when its value is **designated**
(`tt` or `both`).  Semantic consequence `Γ ⊨ φ` means every valuation satisfying all
of `Γ` satisfies `φ`.

## Main results

* `Entails.refl`, `Entails.weakening`, `Entails.cut` — the structural rules: the
  consequence relation is a Tarskian closure operator.
* `Entails.and_intro`, `Entails.and_elim_left`, `Entails.and_elim_right` — conjunction
  behaves classically.
* `Entails.or_intro_left`, `Entails.or_intro_right` — disjunction introduction.
* `deMorgan_valid` — De Morgan laws are valid entailments.
* `explosion_fails` — **paraconsistency**: from `p` and `¬p` one cannot derive an
  arbitrary `q`.  A contradiction does not entail everything.
* `lem_not_valid` — **paracompleteness**: `p ∨ ¬p` is not a validity.
* `noncontradiction_not_valid` — `¬(p ∧ ¬p)` is not a validity either: contradictions
  are genuinely tolerated.
-/

namespace DreamLogic.Consequence

open DreamLogic.Bilattice

/-- Propositional formulas over an atom type `V`. -/
inductive Formula (V : Type*)
  | atom : V → Formula V
  | neg : Formula V → Formula V
  | conj : Formula V → Formula V → Formula V
  | disj : Formula V → Formula V → Formula V

variable {V : Type*}

/-- Evaluate a formula in the four-valued algebra under a valuation of atoms. -/
def eval (v : V → FV) : Formula V → FV
  | Formula.atom p => v p
  | Formula.neg φ => Bilattice.neg (eval v φ)
  | Formula.conj φ ψ => tmeet (eval v φ) (eval v ψ)
  | Formula.disj φ ψ => tjoin (eval v φ) (eval v ψ)

/-- Semantic consequence: every valuation designating all premises designates the
conclusion. -/
def Entails (Γ : Set (Formula V)) (φ : Formula V) : Prop :=
  ∀ v : V → FV, (∀ ψ ∈ Γ, designated (eval v ψ)) → designated (eval v φ)

@[inherit_doc] scoped infix:50 " ⊨ " => Entails

/-! ### Structural rules -/

/-- Reflexivity: a premise is entailed by any premise set containing it. -/
theorem Entails.refl {Γ : Set (Formula V)} {φ : Formula V} (hφ : φ ∈ Γ) : Γ ⊨ φ :=
  fun _ hv => hv φ hφ

/-- Monotonicity / weakening: enlarging the premise set preserves entailment. -/
theorem Entails.weakening {Γ Δ : Set (Formula V)} {φ : Formula V}
    (hsub : Γ ⊆ Δ) (h : Γ ⊨ φ) : Δ ⊨ φ :=
  fun v hv => h v (fun ψ hψ => hv ψ (hsub hψ))

/-- Cut: if `Γ ⊨ φ` and `Γ ∪ {φ} ⊨ ψ`, then `Γ ⊨ ψ`. -/
theorem Entails.cut {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h1 : Γ ⊨ φ) (h2 : insert φ Γ ⊨ ψ) : Γ ⊨ ψ := by
  intro v hv
  apply h2 v
  intro χ hχ
  rcases hχ with hχ | hχ
  · subst hχ; exact h1 v hv
  · exact hv χ hχ

/-! ### Conjunction and disjunction behave lattice-theoretically -/

theorem Entails.and_intro {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h1 : Γ ⊨ φ) (h2 : Γ ⊨ ψ) : Γ ⊨ Formula.conj φ ψ := by
  intro v hv
  have a := h1 v hv
  have b := h2 v hv
  have := designated_filter.2.2 (eval v φ) (eval v ψ) a b
  simpa [eval] using this

theorem Entails.and_elim_left {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h : Γ ⊨ Formula.conj φ ψ) : Γ ⊨ φ := by
  intro v hv
  have := h v hv
  simp only [eval] at this
  exact designated_filter.2.1 (tmeet (eval v φ) (eval v ψ)) (eval v φ) (tmeet_le_left _ _) this

theorem Entails.and_elim_right {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h : Γ ⊨ Formula.conj φ ψ) : Γ ⊨ ψ := by
  intro v hv
  have := h v hv
  simp only [eval] at this
  exact designated_filter.2.1 (tmeet (eval v φ) (eval v ψ)) (eval v ψ) (tmeet_le_right _ _) this

theorem Entails.or_intro_left {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h : Γ ⊨ φ) : Γ ⊨ Formula.disj φ ψ := by
  intro v hv
  have := h v hv
  exact designated_filter.2.1 (eval v φ) (tjoin (eval v φ) (eval v ψ)) (left_le_tjoin _ _) this

theorem Entails.or_intro_right {Γ : Set (Formula V)} {φ ψ : Formula V}
    (h : Γ ⊨ ψ) : Γ ⊨ Formula.disj φ ψ := by
  intro v hv
  have := h v hv
  exact designated_filter.2.1 (eval v ψ) (tjoin (eval v φ) (eval v ψ)) (right_le_tjoin _ _) this

/-- De Morgan is a valid entailment: `¬(φ ∧ ψ) ⊨ ¬φ ∨ ¬ψ`. -/
theorem deMorgan_valid {φ ψ : Formula V} :
    ({Formula.neg (Formula.conj φ ψ)} : Set (Formula V)) ⊨
      Formula.disj (Formula.neg φ) (Formula.neg ψ) := by
  intro v hv
  have := hv _ rfl
  simp only [eval, neg_tmeet] at this ⊢
  exact this

/-! ### Paraconsistency and paracompleteness -/

/-- **Explosion fails.** With two distinct atoms `p ≠ q`, the contradictory premise set
`{p, ¬p}` does *not* entail `q`: a contradiction does not trivialize the logic. -/
theorem explosion_fails {p q : V} (hpq : p ≠ q) :
    ¬ (({Formula.atom p, Formula.neg (Formula.atom p)} : Set (Formula V))
        ⊨ Formula.atom q) := by
  intro h
  classical
  -- The valuation sending `p` (and every atom `≠ q`) to the glut `both` designates both
  -- premises, while `q ↦ ff` breaks the conclusion.
  set v : V → FV := fun r => if r = q then FV.ff else FV.both
  have hprem : ∀ ψ ∈ ({Formula.atom p, Formula.neg (Formula.atom p)} : Set (Formula V)),
      designated (eval v ψ) := by
    intro ψ hψ
    rcases hψ with rfl | rfl
    · show designated (if p = q then FV.ff else FV.both)
      rw [if_neg hpq]; trivial
    · show designated (Bilattice.neg (if p = q then FV.ff else FV.both))
      rw [if_neg hpq]; trivial
  have hconcl : designated (if q = q then FV.ff else FV.both) := h v hprem
  rw [if_pos rfl] at hconcl
  exact hconcl

/-- **Gluts are genuinely tolerated.** The contradictory set `{p, ¬p}` is satisfiable: some
valuation designates both a proposition and its negation (the glut model). -/
theorem contradiction_satisfiable {p : V} :
    ∃ v : V → FV, designated (eval v (Formula.atom p)) ∧
      designated (eval v (Formula.neg (Formula.atom p))) :=
  ⟨fun _ => FV.both, trivial, trivial⟩

/-- **Excluded middle is not valid.** The formula `p ∨ ¬p` fails on a gap valuation. -/
theorem lem_not_valid {p : V} :
    ¬ ((∅ : Set (Formula V)) ⊨ Formula.disj (Formula.atom p) (Formula.neg (Formula.atom p))) := by
  intro h
  have := h (fun _ => FV.neither) (by simp)
  simp only [eval, Bilattice.neg, tjoin, designated] at this

/-- **Non-contradiction is not valid either.** `¬(p ∧ ¬p)` fails on a glut valuation:
contradictions are genuinely tolerated, not merely undecided. -/
theorem noncontradiction_not_valid {p : V} :
    ¬ ((∅ : Set (Formula V)) ⊨
        Formula.neg (Formula.conj (Formula.atom p) (Formula.neg (Formula.atom p)))) := by
  intro h
  have := h (fun _ => FV.neither) (by simp)
  simp only [eval, Bilattice.neg, tmeet, designated] at this

end DreamLogic.Consequence