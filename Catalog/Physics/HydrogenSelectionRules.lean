import Mathlib
import Physics.AngularMomentum

/-!
# Hydrogen Atom: Degeneracy and Dipole Selection Rules

We formalize two combinatorial/arithmetic facts about the hydrogen atom's
quantum numbers:

* **Degeneracy.** The shell with principal quantum number `n` contains exactly
  `n²` orbital states, because `∑_{l=0}^{n-1} (2l+1) = n²` and each `l` subshell
  has `2l+1` magnetic substates (the latter is `magnetic_count` from
  `Physics.AngularMomentum`).
* **Electric-dipole selection rules.** A transition is allowed iff `Δl = ±1` and
  `Δm ∈ {-1, 0, 1}`. We encode the rule as a predicate and prove its key
  consequences: `l = 0 → l = 0` is forbidden, allowed transitions flip orbital
  parity, and the rule is symmetric.

## Lab Notes

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The number of orbital states in shell `n` is `n²`,
the perfect-square partial sums of the odd numbers; and the dipole selection
rule `|Δl| = 1` forces a parity flip, forbidding `0 → 0` transitions.

Experiment (Experimenter): Proved the degeneracy identity `∑_{l<n}(2l+1) = n²`
by induction (`Finset.sum_range_succ`), reused `magnetic_count` for the subshell
size, and discharged the selection-rule consequences by `omega` on the integer
quantum numbers.

Analysis (Analyst): The degeneracy is a clean instance of the
sum-of-odd-numbers identity, structurally identical to the figurate-number
patterns elsewhere in the catalog. The parity consequence (`|Δl|=1 ⇒ Odd(l+l')`)
is the algebraic shadow of the photon carrying one unit of angular momentum.

Critique (Critic): Checked non-triviality — `allowed_parity_flip` genuinely needs
`|Δl| = 1`; the forbidden `0 → 0` case is a real corollary, not vacuous. The
degeneracy theorem is proven for all `n`, not a finite check.

Synthesis (PI): Together with `HydrogenSpectrum`, this completes the qualitative
description of hydrogen's spectral lines: which levels exist, how degenerate they
are, and which transitions between them are optically allowed.
-- !-- Lab Notes -- !--
-/

open scoped BigOperators

namespace HydrogenSelectionRules

/-- **Shell degeneracy.** The total number of orbital states in the shell with
principal quantum number `n` is `n²`:
`∑_{l=0}^{n-1} (2l+1) = n²`. -/
theorem shell_degeneracy (n : ℕ) :
    ∑ l ∈ Finset.range n, (2 * l + 1) = n ^ 2 := by
  induction n with
  | zero => simp
  | succ k ih => rw [Finset.sum_range_succ, ih]; ring

/-- The `l` subshell has `2l+1` magnetic substates, i.e. valid `m ∈ {-l, …, l}`.
This re-exports `magnetic_count` from `Physics.AngularMomentum`. -/
theorem subshell_size (l : ℕ) :
    (Finset.Icc (-(l : ℤ)) (l : ℤ)).card = 2 * l + 1 :=
  magnetic_count l

/-- **Electric-dipole selection rule.** A radiative transition between angular
states `(l, m)` and `(l', m')` is allowed iff the orbital quantum number changes
by exactly one and the magnetic quantum number changes by at most one. -/
def dipoleAllowed (l l' : ℕ) (m m' : ℤ) : Prop :=
  (l' = l + 1 ∨ l = l' + 1) ∧ |m - m'| ≤ 1

/-- An allowed transition must change the orbital quantum number: `l = l'` is
forbidden (in particular `0 → 0` is forbidden). -/
theorem dipole_forbids_same_l (l : ℕ) (m m' : ℤ) :
    ¬ dipoleAllowed l l m m' := by
  rintro ⟨h, _⟩; omega

/-- **Parity selection rule.** An allowed dipole transition flips orbital parity:
`l + l'` is odd. -/
theorem dipole_parity_flip (l l' : ℕ) (m m' : ℤ)
    (h : dipoleAllowed l l' m m') : Odd (l + l') := by
  obtain ⟨hl, _⟩ := h
  rcases hl with h | h
  · exact ⟨l, by omega⟩
  · exact ⟨l', by omega⟩

/-- The dipole selection rule is symmetric in initial/final states (detailed
balance at the level of allowedness). -/
theorem dipole_symm (l l' : ℕ) (m m' : ℤ) :
    dipoleAllowed l l' m m' ↔ dipoleAllowed l' l m' m := by
  unfold dipoleAllowed
  rw [abs_sub_comm]
  constructor <;> rintro ⟨h1, h2⟩ <;> exact ⟨by omega, h2⟩

/-- A concrete allowed transition: `2p → 1s` (`l : 1 → 0`, `m : 0 → 0`), the
Lyman-α line. -/
theorem lyman_alpha_allowed : dipoleAllowed 1 0 0 0 := by
  refine ⟨Or.inr rfl, by norm_num⟩

end HydrogenSelectionRules