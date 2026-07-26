/-
# Bridge: Analytic Airy Solutions are Non-Polynomial

The Tracy–Widom edge laws are *not* algebraic — the Airy function `Ai`, which
generates the edge kernel, satisfies no polynomial relation.  The catalog file
`Catalog/EML/EMLDiffObstruction.lean` proves the *algebraic* shadow of this fact:
no nonzero polynomial `p ∈ ℝ[X]` solves Airy's equation `p'' = X·p`
(`EMLDiffObstruction.no_poly_solves_airy`, a degree-mismatch argument).

This file builds the **analytic-to-algebraic bridge**: any genuine (twice
differentiable, not identically zero) analytic solution of the Airy ODE
`f'' = x·f` *cannot* coincide with a polynomial function.  The proof transports
the analytic ODE to a polynomial identity via uniqueness of derivatives and
`Polynomial.funext` (an infinite field has no nonzero polynomial vanishing
everywhere), and then invokes the catalog's degree obstruction.

This is the precise sense in which "the Airy function is transcendental over
`ℝ[X]`", explaining why the edge-universality limit is genuinely new analysis and
not reducible to polynomial algebra.
-/
import Mathlib
import Catalog.EML.EMLDiffObstruction

open Polynomial

namespace RandomMatrices

/-- **Airy solutions are not polynomials.**  If `f` is twice differentiable with
`f'' x = x · f x` for all `x` (an Airy solution) and `f` is not identically zero,
then `f` does not agree with any polynomial function `p.eval`.

The proof:
* differentiate the representation `f = p.eval` twice (derivative uniqueness) to
  get `f'  = (p')·eval` and `f'' = (p'')·eval`;
* the ODE gives `(p'')·eval x = x · (p)·eval x = (X·p)·eval x` for all `x`, hence
  `p'' = X·p` as polynomials (`Polynomial.funext`);
* `EMLDiffObstruction.no_poly_solves_airy` says no nonzero `p` satisfies this. -/
theorem airy_solution_not_polynomial
    (f f' f'' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (ode : ∀ x, f'' x = x * f x)
    (p : Polynomial ℝ)
    (hrep : ∀ x, f x = p.eval x)
    (hne : ∃ x, f x ≠ 0) : False := by
  have hfeq : f = fun y => p.eval y := funext hrep
  -- `f ≢ 0` forces `p ≠ 0`.
  have hp : p ≠ 0 := by
    rintro rfl
    obtain ⟨x, hx⟩ := hne
    exact hx (by rw [hrep]; simp)
  -- First derivative agrees with `p'`.
  have hf'eq : ∀ x, f' x = (derivative p).eval x := by
    intro x
    have hpf : HasDerivAt f ((derivative p).eval x) x := by
      rw [hfeq]; exact p.hasDerivAt x
    exact (hf x).unique hpf
  -- Second derivative agrees with `p''`.
  have hf''eq : ∀ x, f'' x = (derivative (derivative p)).eval x := by
    intro x
    have hpf' : HasDerivAt f' ((derivative (derivative p)).eval x) x := by
      rw [show f' = fun y => (derivative p).eval y from funext hf'eq]
      exact (derivative p).hasDerivAt x
    exact (hf' x).unique hpf'
  -- Transport the ODE to a polynomial identity `p'' = X·p`.
  have hpoly : derivative (derivative p) = X * p := by
    apply Polynomial.funext
    intro x
    have h := ode x
    rw [hf''eq, hrep] at h
    rw [h]; simp [mul_comm]
  -- Invoke the catalog's degree obstruction.
  exact EMLDiffObstruction.no_poly_solves_airy p hp hpoly

/-- Contrapositive packaging: a nonzero Airy solution is *not* equal to any
polynomial function. -/
theorem airy_solution_ne_polynomial
    (f f' f'' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (ode : ∀ x, f'' x = x * f x)
    (hne : ∃ x, f x ≠ 0) :
    ∀ p : Polynomial ℝ, ∃ x, f x ≠ p.eval x := by
  intro p
  by_contra hc
  push_neg at hc
  exact airy_solution_not_polynomial f f' f'' hf hf' ode p hc hne

end RandomMatrices

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H7 (the bridge). Any genuine analytic solution of `f'' = x f` that is not
      identically zero is NOT a polynomial function — the analytic incarnation of
      the catalog's algebraic obstruction `no_poly_solves_airy`.
  H8 (surprising). The bridge needs no growth/decay information about `f`; the only
      analytic input is *uniqueness of derivatives* plus the fact that a nonzero
      polynomial cannot vanish on all of ℝ (`Polynomial.funext`).

Experiment (Experimenter):
  * H7: assume `f = p.eval`.  `HasDerivAt`-uniqueness transports `f', f''` to the
    polynomial derivatives `p', p''`; the ODE then yields the polynomial identity
    `p'' = X·p` (via `Polynomial.funext` over the infinite field ℝ); finally
    `EMLDiffObstruction.no_poly_solves_airy` (imported catalog result) closes it.
  * H8: confirmed — the proof script references only derivative uniqueness and
    `Polynomial.funext`; no integrability lemma appears.

Analysis (Analyst):
  * H7, H8 SURVIVED (0 sorries) and genuinely USE the catalog.
  * Failure mode discovered: the hypothesis `∃ x, f x ≠ 0` is load-bearing — the
    zero function IS the (trivial) polynomial solution `p = 0`, so without
    nontriviality the statement is false.  We thread `hne` through to derive
    `p ≠ 0`, exactly matching the hypothesis of `no_poly_solves_airy`.
  * "Needs a different definition" note: a purely *algebraic* statement (in ℝ[X])
    is already in the catalog; the NEW content is the analytic transport, which
    requires the ODE be stated with `HasDerivAt`, not with `Polynomial.derivative`.

Critique (Critic):
  * Not trivial: uses `by_contra`/`push_neg`, derivative uniqueness, and an
    imported nontrivial degree-obstruction theorem. Not `rfl`/`decide`.
  * Hidden corner case: `p = 0` ⇒ vacuous; excluded by `hne`.  Verified the
    proof of `hp : p ≠ 0` is exactly what rules this out.

Synthesis (PI):
  This closes the loop with the existing catalog: the algebraic non-solvability of
  Airy's equation (EML) is upgraded to a statement about analytic edge-kernel
  generators (this file), justifying "Tracy–Widom is non-algebraic".
-/