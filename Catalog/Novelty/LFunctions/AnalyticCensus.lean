/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The L-Function Universe, part IV: the *analytic* census is faithful

Earlier parts of this project (`NaiveUniverse`, `PeriodicUniverse`, `SelbergCensus`)
studied the L-function universe *combinatorially*: an L-function was modelled by a
finite/periodic packet of coefficient data, and the theme was that the space of such
data packets is countable.

This file goes **deeper**, to the genuine *analytic* object.  An L-function here is a
concrete Dirichlet series

  `LSeries f (s) = ∑' n, f n / n ^ s`

viewed as an actual function `ℂ → ℂ`, built from a coefficient sequence `f : ℕ → ℂ`.
The census philosophy — "each L-function is pinned down by its coefficient data" — is
no longer a modelling convention: it is a **theorem** about the analytic function,
namely the rigidity/uniqueness result that a Dirichlet series which converges
somewhere is uniquely determined by its coefficients
(Mathlib's `LSeries_injOn`).  We build a chain of consequences on top of this hub:

* `abscissa_lt_top_of_summable`, `abscissa_lt_top_of_bounded` — convergence input;
* `lseries_inj` — **rigidity**: normalized, convergent coefficient sequences inject
  into their analytic L-functions;
* `zeta_rigidity` — the Riemann zeta function is the *unique* Dirichlet series (with
  `f 0 = 0`, convergent) taking its values;
* `spikeLSeries_injective` / `analytic_universe_infinite` — the monomial Dirichlet
  series `n ↦ (k+1)^{-s}` are pairwise distinct as analytic functions, so the
  analytic L-function universe is **infinite**;
* `charLSeries_injOn_fixedMod` / `charCensusEquiv` — for each modulus the Dirichlet
  characters correspond **bijectively** to their analytic L-functions (the census is
  *exact*, no accidental coincidences);
* `analyticDirichletUniverse_countable` — the whole family of Dirichlet L-functions,
  as analytic functions over all moduli, is **countable**.

Together these upgrade the combinatorial census to an honest statement about the
analytic objects: the universe of Dirichlet L-functions is countably infinite and
faithfully indexed by its arithmetic data.

The file is self-contained and imports only Mathlib.
-/
import Mathlib

open LSeries Complex

namespace AnalyticLFunctionCensus

/-! ## Convergence inputs

An L-function only "exists" (is determined by its coefficients) once it converges
somewhere.  These two lemmas record the two ways we obtain convergence in this file:
from a single summable point, and from a bound on the coefficients. -/

/-- If a Dirichlet series converges (absolutely) at one point, its abscissa of
absolute convergence is finite: it converges on a right half-plane. -/
theorem abscissa_lt_top_of_summable {f : ℕ → ℂ} {s : ℂ} (h : LSeriesSummable f s) :
    abscissaOfAbsConv f < ⊤ :=
  lt_of_le_of_lt h.abscissaOfAbsConv_le (EReal.coe_lt_top _)

/-- A Dirichlet series with bounded coefficients converges somewhere (indeed for
`Re s > 1`), so has finite abscissa of absolute convergence. -/
theorem abscissa_lt_top_of_bounded {f : ℕ → ℂ} {m : ℝ} (h : ∀ n, n ≠ 0 → ‖f n‖ ≤ m) :
    abscissaOfAbsConv f < ⊤ :=
  abscissa_lt_top_of_summable (LSeriesSummable_of_bounded_of_one_lt_re h (s := 2) (by norm_num))

/-! ## The rigidity hub

The central fact powering the whole census: a Dirichlet series which converges
somewhere is completely determined by its coefficient sequence.  Equivalently, the
map `f ↦ LSeries f` is injective on normalized (`f 0 = 0`), convergent sequences. -/

/-- **Rigidity of L-functions.**  Two normalized coefficient sequences that both
converge somewhere and produce the *same* analytic L-function must be *equal*.  This
is the analytic incarnation of the census slogan "an L-function is its data". -/
theorem lseries_inj {f g : ℕ → ℂ} (hf0 : f 0 = 0) (hg0 : g 0 = 0)
    (hf : abscissaOfAbsConv f < ⊤) (hg : abscissaOfAbsConv g < ⊤)
    (h : LSeries f = LSeries g) : f = g :=
  LSeries_injOn ⟨hf0, hf⟩ ⟨hg0, hg⟩ h

/-! ## The Riemann zeta function is rigid

`ζ(s) = ∑ n⁻ˢ` is the L-function of the (normalized) constant coefficient sequence.
Rigidity says it is the *only* convergent Dirichlet series taking its values. -/

/-- The (normalized) coefficient sequence of the Riemann zeta function: `1` at every
positive integer, `0` at `0`. -/
def zetaCoeff : ℕ → ℂ := fun n => if n = 0 then 0 else 1

theorem zetaCoeff_zero : zetaCoeff 0 = 0 := rfl

theorem zetaCoeff_abscissa : abscissaOfAbsConv zetaCoeff < ⊤ :=
  abscissa_lt_top_of_bounded (m := 1) (by intro n hn; simp [zetaCoeff, hn])

/-- **Rigidity of the Riemann zeta function.**  Any normalized, somewhere-convergent
Dirichlet series whose analytic L-function equals `ζ` has *exactly* the zeta
coefficients — there is no other Dirichlet series representing `ζ`. -/
theorem zeta_rigidity {g : ℕ → ℂ} (hg0 : g 0 = 0) (hg : abscissaOfAbsConv g < ⊤)
    (h : LSeries g = LSeries zetaCoeff) : g = zetaCoeff :=
  lseries_inj hg0 zetaCoeff_zero hg zetaCoeff_abscissa h

/-! ## The monomial family: the analytic universe is infinite

The simplest infinite family of honest Dirichlet series: the "monomials"
`spike k`, whose L-function is `s ↦ (k+1)⁻ˢ`.  Distinct `k` give distinct
coefficient sequences, hence — by rigidity — distinct analytic L-functions. -/

/-- The monomial coefficient sequence: `1` at position `k+1`, `0` elsewhere.  Its
L-function is `s ↦ (k+1)⁻ˢ`. -/
def spike (k : ℕ) : ℕ → ℂ := fun n => if n = k + 1 then 1 else 0

theorem spike_zero (k : ℕ) : spike k 0 = 0 := by simp [spike]

theorem spike_bounded (k : ℕ) : ∀ n, n ≠ 0 → ‖spike k n‖ ≤ 1 := by
  intro n _; unfold spike; split <;> simp

theorem spike_abscissa (k : ℕ) : abscissaOfAbsConv (spike k) < ⊤ :=
  abscissa_lt_top_of_bounded (spike_bounded k)

theorem spike_injective : Function.Injective spike := by
  intro a b h
  by_contra hab
  have := congrFun h (a + 1)
  simp only [spike, if_neg (show a + 1 ≠ b + 1 by omega)] at this
  exact one_ne_zero this

/-- **The monomial L-functions are pairwise distinct.**  Distinct exponents give
distinct analytic Dirichlet series, by rigidity. -/
theorem spikeLSeries_injective : Function.Injective (fun k => LSeries (spike k)) := by
  intro a b h
  exact spike_injective (lseries_inj (spike_zero a) (spike_zero b)
    (spike_abscissa a) (spike_abscissa b) h)

/-- **The analytic L-function universe is infinite.**  Already the monomial Dirichlet
series `s ↦ (k+1)⁻ˢ` form an infinite family of pairwise distinct analytic
functions. -/
theorem analytic_universe_infinite :
    Infinite (Set.range (fun k => LSeries (spike k))) :=
  Set.infinite_coe_iff.mpr (Set.infinite_range_of_injective spikeLSeries_injective)

/-! ## The Dirichlet family: exactness and countability

The genuine arithmetic L-functions of degree one are the Dirichlet L-functions
`L(s, χ) = ∑ χ(n) n⁻ˢ`.  Their coefficient sequences are bounded (`|χ(n)| ≤ 1`), so
they converge and rigidity applies.  We obtain:

* per modulus, the characters correspond **bijectively** to their L-functions;
* over all moduli, the analytic Dirichlet family is **countable**. -/

/-- The (normalized) coefficient sequence `n ↦ χ(n)` of a Dirichlet character `χ`
modulo `N`, with the `n = 0` term set to `0`. -/
noncomputable def charCoeff {N : ℕ} (χ : DirichletCharacter ℂ N) : ℕ → ℂ :=
  fun n => if n = 0 then 0 else χ (n : ZMod N)

theorem charCoeff_zero {N : ℕ} (χ : DirichletCharacter ℂ N) : charCoeff χ 0 = 0 := by
  simp [charCoeff]

/-- Dirichlet character values have norm at most `1`, so the coefficient sequence is
bounded. -/
theorem charCoeff_bounded {N : ℕ} (χ : DirichletCharacter ℂ N) :
    ∀ n, n ≠ 0 → ‖charCoeff χ n‖ ≤ 1 := by
  intro n hn; simp only [charCoeff, if_neg hn]; exact χ.norm_le_one _

theorem charCoeff_abscissa {N : ℕ} (χ : DirichletCharacter ℂ N) :
    abscissaOfAbsConv (charCoeff χ) < ⊤ :=
  abscissa_lt_top_of_bounded (charCoeff_bounded χ)

/-- Distinct Dirichlet characters (of a fixed modulus) have distinct coefficient
sequences.  The trick: every residue `a : ZMod N` is `↑(a.val + N)` with
`a.val + N ≠ 0`, so the coefficient sequence sees `χ(a)` for *every* `a`. -/
theorem charCoeff_injOn_fixedMod {N : ℕ} [NeZero N] :
    Function.Injective (fun χ : DirichletCharacter ℂ N => charCoeff χ) := by
  intro χ ψ h
  have hall : ∀ a : ZMod N, χ a = ψ a := by
    intro a
    have hn : a.val + N ≠ 0 := by have := (NeZero.ne N); omega
    have hh := congrFun h (a.val + N)
    simp only [charCoeff, if_neg hn] at hh
    have hcast : ((a.val + N : ℕ) : ZMod N) = a := by
      push_cast; rw [ZMod.natCast_val, ZMod.cast_id, ZMod.natCast_self, add_zero]
    rwa [hcast] at hh
  exact MulChar.ext (fun u => hall (u : ZMod N))

/-- **Exactness of the Dirichlet census (injectivity form).**  For a fixed modulus,
distinct Dirichlet characters give distinct *analytic* L-functions: the census has no
accidental coincidences. -/
theorem charLSeries_injOn_fixedMod {N : ℕ} [NeZero N] :
    Function.Injective (fun χ : DirichletCharacter ℂ N => LSeries (charCoeff χ)) := by
  intro χ ψ h
  exact charCoeff_injOn_fixedMod (lseries_inj (charCoeff_zero χ) (charCoeff_zero ψ)
    (charCoeff_abscissa χ) (charCoeff_abscissa ψ) h)

/-- **Exactness of the Dirichlet census (bijection form).**  For a fixed modulus, the
Dirichlet characters are in explicit bijection with the analytic L-functions they
produce. -/
noncomputable def charCensusEquiv {N : ℕ} [NeZero N] :
    DirichletCharacter ℂ N ≃
      Set.range (fun χ : DirichletCharacter ℂ N => LSeries (charCoeff χ)) :=
  Equiv.ofInjective _ charLSeries_injOn_fixedMod

/-- Per modulus, there are only finitely many analytic Dirichlet L-functions. -/
theorem charLSeries_finite_fixedMod {N : ℕ} [NeZero N] :
    (Set.range (fun χ : DirichletCharacter ℂ N => LSeries (charCoeff χ))).Finite :=
  Set.finite_range _

/-- The analytic Dirichlet L-function attached to a character bundled with its
modulus. -/
noncomputable def analyticDirichletFamily (p : Σ N : ℕ, DirichletCharacter ℂ N) : ℂ → ℂ :=
  LSeries (charCoeff p.2)

/-- **The universe of Dirichlet L-functions is countable.**  As actual analytic
functions `ℂ → ℂ`, ranging over all characters of all moduli, they form a countable
set: they are the image of the countable index `Σ N, DirichletCharacter ℂ N`. -/
theorem analyticDirichletUniverse_countable :
    (Set.range analyticDirichletFamily).Countable :=
  Set.countable_range _

end AnalyticLFunctionCensus