import Logic.LambdaCalculus.Confluence

/-!
# Uniqueness of β-normal forms

A direct consequence of the Church–Rosser theorem
(`LambdaCalculus.church_rosser_beta`): a λ-term has *at most one* β-normal form.
This is the classical corollary that makes "the" normal form of a term a
well-defined notion.

-- !-- Lab Notes -- !--
Hypothesis (H2): Confluence collapses the non-determinism of β-reduction at the
level of normal forms — two normal forms reachable from one term must be equal.
Experiment: prove the one-line lemma `betaStar_nf_eq` (a normal form only
reduces to itself) and feed two reductions into `church_rosser_beta`.
Analysis: the only subtlety is that a normal form *can* take zero steps; the
reflexive–transitive closure is inverted with `cases` to extract that a first
step is impossible. Critique: `NormalForm` is the genuinely-empty-redex
predicate (`∀ u, ¬ Beta t u`), so the result is not vacuous — e.g. `Lam.I` and
`Lam.var 0` are bona fide normal forms.
-- !-- End Lab Notes -- !--
-/

namespace LambdaCalculus

open Lam

/-- A normal form β-reduces only to itself. -/
theorem betaStar_nf_eq {u w : Lam} (hu : NormalForm u) (h : BetaStar u w) : u = w := by
  induction h with
  | refl => rfl
  | tail _ hstep _ =>
      -- a single β-step out of a normal form is impossible
      exact absurd hstep (by simp_all [NormalForm])

/-- **Uniqueness of β-normal forms.**  If a term reduces (in any number of steps)
to two normal forms, those normal forms are equal. -/
theorem betaStar_normalForm_unique {t u v : Lam}
    (hu : BetaStar t u) (hv : BetaStar t v)
    (hnu : NormalForm u) (hnv : NormalForm v) : u = v := by
  obtain ⟨w, huw, hvw⟩ := church_rosser_beta hu hv
  have e1 : u = w := betaStar_nf_eq hnu huw
  have e2 : v = w := betaStar_nf_eq hnv hvw
  exact e1.trans e2.symm

/-- `Lam.var n` is a β-normal form (a witness that `NormalForm` is non-vacuous). -/
theorem normalForm_var (n : ℕ) : NormalForm (var n) := by
  intro u h
  cases h

end LambdaCalculus