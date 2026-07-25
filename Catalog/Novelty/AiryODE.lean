/-
# The Airy ODE: Wronskian Theory for Edge Universality

At the spectral *edge* of a random matrix ensemble the local eigenvalue statistics
are governed by the **Airy kernel**, built from solutions of Airy's differential
equation `y'' = x · y`.  The structural backbone of that kernel — the reason it is
an *integrable* (Christoffel–Darboux) kernel at all — is that the **Wronskian** of
two solutions of a second-order linear ODE with no first-order term is *constant*.

This file develops that analytic Wronskian theory directly for abstract solutions
`f, g : ℝ → ℝ` of the Airy equation (given via their first and second pointwise
derivatives), and proves:

* `airyWronskian_hasDerivAt_zero` — the Wronskian has derivative `0` everywhere
  (the one genuine computation: `W' = f·g'' - f''·g = f·(x·g) - (x·f)·g = 0`).
* `airyWronskian_const` — the Wronskian is constant.
* `airy_solutions_linearIndep` — two solutions whose Wronskian is nonzero at one
  point are linearly independent as functions.

These are the analytic inputs reused in `AiryKernel.lean` to compute the diagonal
of the Airy correlation kernel.
-/
import Mathlib

namespace RandomMatrices

/-- The (classical, analytic) Wronskian of two functions `f, g` with first
derivatives `f'`, `g'`:  `W(x) = f(x)·g'(x) - f'(x)·g(x)`. -/
noncomputable def airyWronskian (f f' g g' : ℝ → ℝ) (x : ℝ) : ℝ :=
  f x * g' x - f' x * g x

/-- **Wronskian derivative vanishes.**  For two solutions of the Airy equation
`y'' = x·y`, the Wronskian `W = f·g' - f'·g` has derivative `0` at every point.

This is the structural core: `W' = (f·g')' - (f'·g)' = f·g'' - f''·g`, and the ODE
turns this into `f·(x·g) - (x·f)·g = 0`. -/
theorem airyWronskian_hasDerivAt_zero
    (f f' f'' g g' g'' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (hg : ∀ x, HasDerivAt g (g' x) x)
    (hg' : ∀ x, HasDerivAt g' (g'' x) x)
    (eqf : ∀ x, f'' x = x * f x)
    (eqg : ∀ x, g'' x = x * g x)
    (x : ℝ) :
    HasDerivAt (airyWronskian f f' g g') 0 x := by
  have h1 : HasDerivAt (fun y => f y * g' y) (f' x * g' x + f x * g'' x) x :=
    (hf x).mul (hg' x)
  have h2 : HasDerivAt (fun y => f' y * g y) (f'' x * g x + f' x * g' x) x :=
    (hf' x).mul (hg x)
  have h3 := h1.sub h2
  have hzero :
      (f' x * g' x + f x * g'' x) - (f'' x * g x + f' x * g' x) = 0 := by
    rw [eqf, eqg]; ring
  rw [hzero] at h3
  exact h3

/-- **Wronskian is constant.**  Abel's identity for the Airy equation: the
Wronskian of two solutions takes the same value at every pair of points. -/
theorem airyWronskian_const
    (f f' f'' g g' g'' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hf' : ∀ x, HasDerivAt f' (f'' x) x)
    (hg : ∀ x, HasDerivAt g (g' x) x)
    (hg' : ∀ x, HasDerivAt g' (g'' x) x)
    (eqf : ∀ x, f'' x = x * f x)
    (eqg : ∀ x, g'' x = x * g x)
    (a b : ℝ) :
    airyWronskian f f' g g' a = airyWronskian f f' g g' b := by
  have hW := airyWronskian_hasDerivAt_zero f f' f'' g g' g'' hf hf' hg hg' eqf eqg
  have hdiff : Differentiable ℝ (airyWronskian f f' g g') :=
    fun x => (hW x).differentiableAt
  have hderiv : ∀ x, deriv (airyWronskian f f' g g') x = 0 :=
    fun x => (hW x).deriv
  exact is_const_of_deriv_eq_zero hdiff hderiv a b

/-- **Linear independence of solutions.**  If the Wronskian of two solutions is
nonzero at some point `x₀`, then no nontrivial linear combination
`a·f + b·g` vanishes identically; hence `f` and `g` are linearly independent.

Note: only the first-derivative data is needed here (we differentiate the
identity `a·f + b·g ≡ 0` once and evaluate the `2×2` linear system at `x₀`). -/
theorem airy_solutions_linearIndep
    (f f' g g' : ℝ → ℝ)
    (hf : ∀ x, HasDerivAt f (f' x) x)
    (hg : ∀ x, HasDerivAt g (g' x) x)
    (a b x0 : ℝ)
    (hW : airyWronskian f f' g g' x0 ≠ 0)
    (hcomb : ∀ x, a * f x + b * g x = 0) :
    a = 0 ∧ b = 0 := by
  -- Differentiate the vanishing combination.
  have hderiv : ∀ x, a * f' x + b * g' x = 0 := by
    intro x
    have hc : HasDerivAt (fun y => a * f y + b * g y) (a * f' x + b * g' x) x :=
      ((hf x).const_mul a).add ((hg x).const_mul b)
    have hzero : HasDerivAt (fun y => a * f y + b * g y) 0 x := by
      have hrw : (fun y => a * f y + b * g y) = (fun _ => (0 : ℝ)) := funext hcomb
      rw [hrw]; exact hasDerivAt_const x 0
    exact hc.unique hzero
  have e1 : a * f x0 + b * g x0 = 0 := hcomb x0
  have e2 : a * f' x0 + b * g' x0 = 0 := hderiv x0
  have ha : a * airyWronskian f f' g g' x0 = 0 := by
    have hexp : a * airyWronskian f f' g g' x0
        = g' x0 * (a * f x0 + b * g x0) - g x0 * (a * f' x0 + b * g' x0) := by
      simp only [airyWronskian]; ring
    rw [hexp, e1, e2]; ring
  have hb : b * airyWronskian f f' g g' x0 = 0 := by
    have hexp : b * airyWronskian f f' g g' x0
        = f x0 * (a * f' x0 + b * g' x0) - f' x0 * (a * f x0 + b * g x0) := by
      simp only [airyWronskian]; ring
    rw [hexp, e1, e2]; ring
  refine ⟨?_, ?_⟩
  · rcases mul_eq_zero.mp ha with h | h
    · exact h
    · exact absurd h hW
  · rcases mul_eq_zero.mp hb with h | h
    · exact h
    · exact absurd h hW

end RandomMatrices

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer):
  H1. For two solutions of the Airy equation `y'' = x y` (no first-order term),
      the Wronskian `W = f g' - f' g` is constant. [Abel's identity, edge-kernel
      backbone.]
  H2 (counter-intuitive). Constancy needs NO decay/integrability of the Airy
      function — it is purely local (a derivative computation) — even though the
      Airy *kernel* it powers is global (a Fredholm determinant).
  H3. Wronskian nonzero at one point ⇒ global linear independence of solutions.

Experiment (Experimenter):
  * H1: proved via the product rule and the ODE substitution; the cross terms
    `f' g'` cancel and `f g'' - f'' g = f(xg) - (xf)g = 0`. `is_const_of_deriv_eq_zero`
    upgrades pointwise `deriv = 0` to global constancy.
  * H3: differentiate the identity `a f + b g ≡ 0` once (derivative uniqueness),
    then solve the 2×2 system; `a W = 0` and `b W = 0`, and `W ≠ 0` forces `a=b=0`.

Analysis (Analyst):
  * H1, H3 SURVIVED (0 sorries). H2 confirmed: the proof uses only `HasDerivAt`
    data, never any growth/decay of `f` — the local nature is real, not an artifact.
  * Failure mode avoided: a naive `simp`/`ring` attempt on the Wronskian derivative
    fails because the ODE substitution must happen *before* the cancellation; the
    `rw [eqf, eqg]; ring` ordering is load-bearing.

Critique (Critic):
  * Not trivial: the proof uses the product rule, derivative uniqueness, and
    `is_const_of_deriv_eq_zero` (an MVT consequence). Not `rfl`/`decide`.
  * Hidden assumption checked: linear independence really needs `W ≠ 0` somewhere;
    if `W ≡ 0` the solutions are dependent — the hypothesis is exactly load-bearing.

Synthesis (PI):
  These two facts are reused in `AiryKernel.lean`: constancy of `W` is what makes
  the diagonal of the Christoffel–Darboux Airy kernel independent of position.
-/