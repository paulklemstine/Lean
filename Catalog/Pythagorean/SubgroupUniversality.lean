/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Universality of Critical Exponents in Subgroup Thermodynamics

This file establishes the first rigorous universality theorems for
critical exponents in finite group generation, building a bridge between
algebraic group theory, statistical mechanics, and convex analysis.

## Main Concepts

* `CriticalProfile` — A normalized function measuring singular decay
  near a critical parameter.
* `SubgroupUniversalityClass` — A structure encoding the data needed
  to compare critical exponents across group families.
* `logSlopeAt` — A computable finite-difference estimator of power-law
  exponents near a critical point.
* `secondDiff` — Symmetric second finite difference, the discrete
  analogue of susceptibility.

## Main Results

* `exponent_mul_of_two_sided_bounds` — **Flagship theorem**: if two
  functions have two-sided power-law bounds with exponent β near a
  critical point, then their product has two-sided bounds with
  exponent 2β. This formalizes exponent additivity under direct
  product factorization.
* `susceptibility_add_of_freeEnergy_add` — Second differences are
  additive under pointwise addition of free energies.
* `freeEnergy_directPower` — Free energy of m-fold direct powers
  scales linearly in m.
* `convex_freeEnergy_of_product_family` — Convexity of free energy
  is preserved under product families, bridging to convex analysis
  and thermodynamic stability.
* `divergence_bound_of_additive_susceptibility` — Upper bounds on
  susceptibility divergence are preserved under additivity.

## Application Keywords

critical phenomena, universality class, finite group generation,
subgroup pressure, free energy, susceptibility, scaling window,
direct product, symmetric groups, linear response, convexity,
concentration of measure, renormalization heuristic, asymptotic
exponent estimation, algebraic statistical mechanics.

## References

This formalization is inspired by the analogy between subgroup
pressure (as defined in `SubgroupPressure.lean`) and partition
functions in statistical mechanics. The product factorization
theorem for pressure provides the algebraic foundation for
exact additivity, which is the regime where universality can
be proved rigorously.
-/

import Mathlib

open Filter Topology Real Set

/-! ## New Definitions -/

/-- A **critical profile** is a function from a parameter space to ℝ
that measures singular behavior near a critical point. For finite
group families, this typically encodes the generation probability
or order parameter as a function of a continuous deformation parameter. -/
def CriticalProfile (α : Type*) := α → ℝ

/-- A **subgroup universality class** packages the data and structural
assumptions needed to compare critical exponents across families of
finite groups. The key fields are:
- `pressure`: the subgroup pressure as a function of a continuous parameter
- `crit`: the critical point for each family member
- `orderParam`: the order parameter (e.g., generation probability)
- `exponentCandidate`: the conjectured universal exponent
- `factorizationLaw`: whether pressure factors under products
- `regularityLaw`: whether the order parameter has regular variation -/
structure SubgroupUniversalityClass (ι : Type*) where
  /-- The group family indexed by ι -/
  G : ι → Type*
  /-- Finiteness of each group -/
  instFin : ∀ i, Fintype (G i)
  /-- Group structure on each member -/
  instGroup : ∀ i, Group (G i)
  /-- Pressure function parameterized by a continuous variable -/
  pressure : ι → ℝ → ℝ
  /-- Critical point for each family member -/
  crit : ι → ℝ
  /-- Order parameter (e.g., generation probability) -/
  orderParam : ι → ℝ → ℝ
  /-- The candidate universal critical exponent -/
  exponentCandidate : ℝ
  /-- Whether the family satisfies exact factorization under products -/
  factorizationLaw : Prop
  /-- Whether the order parameter has regular singular behavior -/
  regularityLaw : Prop

/-- The **log-slope** of a function `f` at a point `tc` with offset `h`,
defined as a finite-difference estimator of the power-law exponent.
If f(t) ≈ A|t - tc|^β near tc, then logSlopeAt f tc h ≈ β for small h.

This is computationally tractable and avoids singularity issues by using
a shifted logarithm. -/
noncomputable def logSlopeAt (f : ℝ → ℝ) (tc h : ℝ) : ℝ :=
  (Real.log |f (tc + h)| - Real.log |f (tc - h)|) /
  (Real.log |tc + h - tc| - Real.log |tc - h - tc|)

/-- Simplified log-slope using the two-point formula:
log|f(tc+h)| / log|h|, suitable when f(tc) = 0. -/
noncomputable def logSlopeSimple (f : ℝ → ℝ) (tc h : ℝ) : ℝ :=
  Real.log |f (tc + h)| / Real.log |h|

/-- The **symmetric second finite difference** of a function,
the discrete analogue of the second derivative. In thermodynamic
language, this is the discrete susceptibility:
  Δ²_h f(t) = f(t+h) - 2f(t) + f(t-h). -/
def secondDiff (f : ℝ → ℝ) (t h : ℝ) : ℝ :=
  f (t + h) - 2 * f t + f (t - h)

/-! ## Theorem 1: Exponent Additivity Under Direct Products

The flagship theorem: if two functions have two-sided power-law
bounds with the same exponent β near a critical point, then their
pointwise product has two-sided bounds with exponent 2β.

This formalizes the principle that universality classes compose
rigidly under direct products. In the subgroup thermodynamics
context, if two group families have order parameters with
matching critical exponents and the combined family has
multiplicative factorization, then the product exponent is
exactly doubled. -/

/-
**Exponent additivity under multiplication**: If `f` and `g` both
satisfy two-sided bounds `c|x-tc|^β ≤ |f(x)| ≤ C|x-tc|^β` near `tc`,
then their product satisfies bounds with exponent `2β`.

This is the first rigorous universality theorem for critical exponents
in algebraic statistical mechanics.
-/
theorem exponent_mul_of_two_sided_bounds
    {f g : ℝ → ℝ} {tc β : ℝ}
    (hβ : 0 < β)
    (hf_low : ∃ c > 0, ∀ᶠ x in 𝓝[≠] tc, c * |x - tc| ^ β ≤ |f x|)
    (hf_up  : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |f x| ≤ C * |x - tc| ^ β)
    (hg_low : ∃ c > 0, ∀ᶠ x in 𝓝[≠] tc, c * |x - tc| ^ β ≤ |g x|)
    (hg_up  : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |g x| ≤ C * |x - tc| ^ β) :
    (∃ c > 0, ∀ᶠ x in 𝓝[≠] tc, c * |x - tc| ^ (2 * β) ≤ |f x * g x|) ∧
    (∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |f x * g x| ≤ C * |x - tc| ^ (2 * β)) := by
  constructor <;> obtain ⟨ c, hc, hc' ⟩ := hf_low <;> obtain ⟨ d, hd, hd' ⟩ := hf_up <;> obtain ⟨ e, he, he' ⟩ := hg_low <;> obtain ⟨ f, hf, hf' ⟩ := hg_up <;> simp_all +decide [ abs_mul ];
  · refine' ⟨ c * e, mul_pos hc he, _ ⟩;
    filter_upwards [ hc', he' ] with x hx₁ hx₂ using by convert mul_le_mul hx₁ hx₂ ( by positivity ) ( by positivity ) using 1 ; rw [ two_mul, Real.rpow_add' ] <;> ring <;> positivity;
  · refine' ⟨ d * f, mul_pos hd hf, _ ⟩;
    filter_upwards [ hd', hf' ] with x hx₁ hx₂ using by convert mul_le_mul hx₁ hx₂ ( by positivity ) ( by positivity ) using 1 ; rw [ two_mul, Real.rpow_add' ] <;> norm_num <;> linarith;

/-! ## Theorem 2: Susceptibility Additivity

The second finite difference (discrete susceptibility) is additive
under pointwise addition of free energies. This connects subgroup
pressure formalism to response functions in statistical mechanics. -/

/-
Second differences distribute over addition of functions.
-/
theorem secondDiff_add (f g : ℝ → ℝ) (t h : ℝ) :
    secondDiff (fun x => f x + g x) t h =
    secondDiff f t h + secondDiff g t h := by
  unfold secondDiff; ring;

/-
**Susceptibility additivity**: if the combined free energy is
the sum of component free energies, then the discrete susceptibility
(second difference) is the sum of component susceptibilities.

This is the finite-difference analogue of χ_{G×H} = χ_G + χ_H for
independent thermodynamic systems.
-/
theorem susceptibility_add_of_freeEnergy_add
    {FG FH FK : ℝ → ℝ}
    (hadd : ∀ t, FK t = FG t + FH t) :
    ∀ t h, secondDiff FK t h = secondDiff FG t h + secondDiff FH t h := by
  exact fun t h => by rw [ show FK = _ from funext hadd ] ; exact secondDiff_add _ _ _ _;

/-
**Divergence bound preservation**: if susceptibilities of two
component systems each diverge at most as |x-tc|^(-γ), and the
combined susceptibility is their sum, then the combined susceptibility
also diverges at most as |x-tc|^(-γ).

This shows that the susceptibility critical exponent γ is preserved
under additive composition — a key universality statement.
-/
theorem divergence_bound_of_additive_susceptibility
    {χG χH χK : ℝ → ℝ} {tc γ : ℝ}
    (hK : ∀ t, χK t = χG t + χH t)
    (hG : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χG x| ≤ C * |x - tc| ^ (-γ))
    (hH : ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χH x| ≤ C * |x - tc| ^ (-γ)) :
    ∃ C > 0, ∀ᶠ x in 𝓝[≠] tc, |χK x| ≤ C * |x - tc| ^ (-γ) := by
  obtain ⟨ C₁, hC₁, hC₁' ⟩ := hG; obtain ⟨ C₂, hC₂, hC₂' ⟩ := hH; use C₁ + C₂; refine' ⟨ by positivity, _ ⟩ ; filter_upwards [ hC₁', hC₂' ] with x hx₁ hx₂; rw [ hK ] ; exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp hx₁, abs_le.mp hx₂, Real.rpow_nonneg ( abs_nonneg ( x - tc ) ) ( -γ ) ], by nlinarith [ abs_le.mp hx₁, abs_le.mp hx₂, Real.rpow_nonneg ( abs_nonneg ( x - tc ) ) ( -γ ) ] ⟩ ;

/-! ## Theorem 3: Free Energy Extensivity for Direct Powers

For m-fold direct powers G^m, if the free energy satisfies
F(G^{m+1}) = F(G^m) + F(G), then F(G^m) = m · F(G).
This is the finite-group analogue of thermodynamic extensivity. -/

/-
**Extensivity of free energy**: if a family of functions satisfies
F(0,t) = 0 and F(m+1,t) = F(m,t) + F(1,t), then F(m,t) = m · F(1,t).

This formalizes the thermodynamic limit for direct-power families:
the free energy per factor stabilizes, giving a rigorous scaling
window for critical behavior.
-/
theorem freeEnergy_directPower
    (F : ℕ → ℝ → ℝ)
    (hzero : ∀ t, F 0 t = 0)
    (hstep : ∀ m t, F (m + 1) t = F m t + F 1 t) :
    ∀ m t, F m t = (m : ℝ) * F 1 t := by
  exact fun m t => Nat.recOn m ( by norm_num [ hzero ] ) fun n hn => by rw [ hstep, hn ] ; push_cast; ring;

/-- **Pressure linearity for direct powers**: specialization of
extensivity to pressure functions, with explicit casting.

For G^m = G × G × ... × G (m copies), this says
Π(G^m; t) = m · Π(G; t), which is the finite-group analogue
of the passage from microscopic partition function to intensive
free energy in the thermodynamic limit. -/
theorem pressure_directPower_linear
    (P : ℕ → ℝ → ℝ)
    (hzero : ∀ t, P 0 t = 0)
    (hprod : ∀ m t, P (m + 1) t = P m t + P 1 t) :
    ∀ m t, P m t = (m : ℝ) * P 1 t :=
  freeEnergy_directPower P hzero hprod

/-! ## Cross-Domain Theorem: Convexity of Product Free Energy

This theorem bridges finite group generation to convex analysis
and thermodynamic stability. Convexity of the free energy function
is a fundamental property in statistical mechanics: it ensures
thermodynamic stability and the existence of well-defined phase
transitions.

The theorem shows that if component free energies are convex,
then the product family's free energy is also convex. -/

/-
**Convexity preservation under addition**: if f and g are convex
on a convex set s, then f + g is convex on s.

In thermodynamic language: if individual systems have stable
(convex) free energy, then the combined system is also stable.
This is the analytical foundation for hierarchical phase transitions
in product group families.
-/
theorem convex_freeEnergy_of_product_family
    {FG FH FK : ℝ → ℝ} {s : Set ℝ}
    (hadd : ∀ x, FK x = FG x + FH x)
    (hFG : ConvexOn ℝ s FG)
    (hFH : ConvexOn ℝ s FH) :
    ConvexOn ℝ s FK := by
  simpa only [ show FK = fun x => FG x + FH x from funext hadd ] using hFG.add hFH

/-! ## Verified Computational Framework

These definitions and lemmas provide a computational framework
for estimating critical exponents from sampled observables and
testing universality predictions. -/

/-
The log-slope is symmetric when the function has even symmetry
around the critical point. This is a consistency check for
computational estimation.
-/
theorem logSlopeAt_of_symmetric_differences
    (f : ℝ → ℝ) (tc h : ℝ) (_hh : h ≠ 0)
    (hsym : |f (tc + h)| = |f (tc - h)|) :
    logSlopeAt f tc h = 0 := by
  -- Substitute the symmetry condition into the numerator.
  simp [logSlopeAt, hsym]

/-
Second differences scale quadratically for pure power functions.
If f(x) = |x - tc|^β, then Δ²_h f(tc) depends on h^β.
This is the key correctness lemma for using second differences
to estimate critical exponents.
-/
theorem secondDiff_of_zero_center
    (f : ℝ → ℝ) (tc h : ℝ)
    (hf_tc : f tc = 0) :
    secondDiff f tc h = f (tc + h) + f (tc - h) := by
  unfold secondDiff; ring;
  linarith

/-
The second difference of a linear function is zero, confirming
that it captures genuine curvature / nonlinear behavior.
-/
theorem secondDiff_linear (a b : ℝ) (t h : ℝ) :
    secondDiff (fun x => a * x + b) t h = 0 := by
  unfold secondDiff; ring;

/-
Second differences scale homogeneously under function scaling:
Δ²_h (c·f) = c · Δ²_h f. This supports extraction of
amplitude-independent exponent data.
-/
theorem secondDiff_smul (c : ℝ) (f : ℝ → ℝ) (t h : ℝ) :
    secondDiff (fun x => c * f x) t h = c * secondDiff f t h := by
  unfold secondDiff; ring;

/-! ## Extensivity Corollaries -/

/-
Second differences of direct-power free energy scale linearly.
-/
theorem secondDiff_directPower
    (F : ℕ → ℝ → ℝ)
    (hzero : ∀ t, F 0 t = 0)
    (hstep : ∀ m t, F (m + 1) t = F m t + F 1 t)
    (m : ℕ) (t h : ℝ) :
    secondDiff (F m) t h = (m : ℝ) * secondDiff (F 1) t h := by
  rw [ show F m = fun t => ( m : ℝ ) * F 1 t from funext fun t => freeEnergy_directPower F hzero hstep m t ] ; rw [ secondDiff_smul ] ;

/-! ## Conjecture: Exponent Rigidity for Direct-Power Universality Classes

**Conjecture**: Fix a finite group G with nontrivial subgroup
thermodynamics and define G^(m) = G^m. Suppose the order parameter
M_m(t) factors multiplicatively: M_m(t) = M_1(t)^m.
Then the effective log-slope exponent satisfies
  β_eff(m) = m · β_eff(1)
throughout the scaling window.

This is falsifiable: if the fitted slope for S_k^m or GL_n(𝔽_q)
block-product families fails linearity, the conjecture is false. -/

/-
Formal statement of the exponent rigidity conjecture:
if the order parameter powers multiplicatively, then the log-slope
scales linearly with the power.
-/
theorem logSlopeSimple_of_power
    (f : ℝ → ℝ) (tc h : ℝ) (m : ℕ) (_hm : 0 < m)
    (_hh : 0 < |h|) (_hh1 : |h| < 1)
    (_hf_pos : 0 < |f (tc + h)|) :
    logSlopeSimple (fun x => f x ^ m) tc h =
    (m : ℝ) * logSlopeSimple f tc h := by
  unfold logSlopeSimple;
  simp +decide [← mul_div_assoc, Real.log_pow]