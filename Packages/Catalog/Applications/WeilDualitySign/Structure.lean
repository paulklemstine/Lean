/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Cycle 3: the root sign as a `μ₂`-valued invariant

Cycles 1–2 computed the functional-equation sign of a duality eigensystem,
`ε = (−1)^{d + #neg-fixed} = (−1)^{m₊}`.  This file establishes the *structural*
properties that turn `ε` into a genuine arithmetic invariant rather than a formula:

* `rootSign_sq_eq_one` — `ε` takes values in the group `μ₂ = {±1}`;
* `rootSign_directSum` — **`ε` is multiplicative under direct sums** of eigensystems,
  as are the characteristic polynomials (`charPoly_directSum`), while the degree and the
  central multiplicity are additive.  So `E ↦ ε(E)` is a monoid homomorphism from the
  additive monoid of duality eigensystems (over a fixed `Q`) to `μ₂` — the shadow of the
  fact that root numbers are multiplicative in the Grothendieck group of Galois
  representations;
* `rootSign_twist` — `ε` is invariant under the **Tate twist / rescaling**
  `(Q, α) ↦ (cQ, cα)`, so it depends only on the *normalised* eigenvalues `α_i / Q`;
* `exists_fixed_point_of_odd_deg` — in **odd degree** a duality involution always has a
  self-dual eigenvalue `α = ±Q`, so the mission hypothesis has real content exactly in
  odd degree, and
* `rootSign_eq_neg_one_pow_deg_of_odd_deg_no_neg_fixed` — under the mission hypothesis an
  odd-degree system always has `ε = −1`, i.e. **odd degree forces central vanishing**
  (`charPoly_central_vanishing_of_odd_deg`), the eigenvalue-model analogue of "root
  number `−1` ⟹ the central value vanishes".

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): if `ε` deserves the name "root number" it must be a
  homomorphism on direct sums and be insensitive to Tate twists; if either failed, the
  cycle-1 formula would be an artefact of the model rather than an invariant.
Experiment (Experimenter): direct sums are `Sum.elim` on eigenvalues and
  `Equiv.sumCongr` on the duality permutations; every claim then follows from
  `Fintype.prod_sum_type` plus the cycle-1 closed formula.  For the twist, `∏ (c α_i)`
  and `(cQ)^d` both pick up exactly `c^d`, which cancels.
Analysis (Analyst): the odd-degree corollary is the sharpest consequence: `#non-fixed`
  is even (cycle-2 lemma), so odd `d` forces `Fix(σ) ≠ ∅`; combined with the mission
  hypothesis every fixed point carries `+Q`, so the central multiplicity is odd and `P`
  vanishes at `T = Q⁻¹`.  This is precisely the "sign `−1` ⟹ vanishing" phenomenon of
  the parity conjecture, now proved in the finite-field model.
Critique (Critic): the direct-sum construction needs the *same* `Q` on both summands
  (different weights cannot be added: that would be a graded, not a direct, sum), and
  the twist needs `c ≠ 0`.  Both hypotheses are recorded explicitly.
-/
import Mathlib
import Catalog.Applications.WeilDualitySign.EigenvalueModel
import Catalog.Applications.WeilDualitySign.CentralParity

open Finset
open scoped Classical

namespace WeilDualitySign

namespace DualEigensystem

variable {K : Type*} [Field K] {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ### `ε` is a square root of unity -/

/-- **The root sign lies in `μ₂`.**  Whatever the eigensystem, `ε² = 1`. -/
theorem rootSign_sq_eq_one (E : DualEigensystem K ι) : E.rootSign ^ 2 = 1 := by
  rw [E.rootSign_eq, ← pow_mul, mul_comm, pow_mul]
  simp

/-! ### Direct sums -/

variable {ι₂ : Type*} [Fintype ι₂] [DecidableEq ι₂]

/-- The **direct sum** of two duality eigensystems of the same weight `Q`: eigenvalues
are concatenated and the duality permutations act blockwise. -/
def directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂) (hQ : F.Q = E.Q) :
    DualEigensystem K (ι ⊕ ι₂) where
  Q := E.Q
  Q_ne_zero := E.Q_ne_zero
  α := Sum.elim E.α F.α
  σ := Equiv.sumCongr E.σ F.σ
  σ_involutive := by
    rintro (i | i)
    · simp [E.σ_involutive i]
    · simp [F.σ_involutive i]
  duality := by
    rintro (i | i)
    · simpa using E.duality i
    · simpa [hQ] using F.duality i

@[simp] theorem directSum_deg (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) : (E.directSum F hQ).deg = E.deg + F.deg := by
  simp [deg]

/-- Characteristic polynomials multiply under direct sums. -/
theorem charPoly_directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) (T : K) :
    (E.directSum F hQ).charPoly T = E.charPoly T * F.charPoly T := by
  simp [charPoly, directSum, Fintype.prod_sum_type]

/-- Eigenvalue products multiply under direct sums. -/
theorem prod_alpha_directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) :
    (∏ x, (E.directSum F hQ).α x) = (∏ i, E.α i) * ∏ i, F.α i := by
  simp [directSum, Fintype.prod_sum_type]

/-- **Multiplicativity of the root sign.**  `ε(E ⊕ F) = ε(E) · ε(F)`: the sign is a
homomorphism from direct sums of duality eigensystems to `μ₂`. -/
theorem rootSign_directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) :
    (E.directSum F hQ).rootSign = E.rootSign * F.rootSign := by
  have hEQ : E.Q ^ E.deg ≠ 0 := pow_ne_zero _ E.Q_ne_zero
  have hFQ : F.Q ^ F.deg ≠ 0 := pow_ne_zero _ F.Q_ne_zero
  rw [rootSign, rootSign, rootSign, prod_alpha_directSum, directSum_deg, pow_add,
    show (E.directSum F hQ).Q = E.Q from rfl, pow_add, hQ]
  field_simp

/-- The mission hypothesis is stable under direct sums. -/
theorem no_neg_fixed_directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) (hE : ∀ i, E.σ i = i → E.α i ≠ -E.Q)
    (hF : ∀ i, F.σ i = i → F.α i ≠ -F.Q) :
    ∀ x, (E.directSum F hQ).σ x = x → (E.directSum F hQ).α x ≠ -(E.directSum F hQ).Q := by
  rintro (i | i) h
  · have h' : E.σ i = i := by simpa [directSum] using h
    simpa [directSum] using hE i h'
  · have h' : F.σ i = i := by simpa [directSum] using h
    simpa [directSum, hQ] using hF i h'

/-- Central multiplicities add under direct sums. -/
theorem centralOrder_directSum (E : DualEigensystem K ι) (F : DualEigensystem K ι₂)
    (hQ : F.Q = E.Q) :
    (E.directSum F hQ).centralOrder = E.centralOrder + F.centralOrder := by
  classical
  simp only [centralOrder, Finset.card_filter]
  rw [Fintype.sum_sum_type]
  have h2 : ∀ i : ι₂,
      ((if (E.directSum F hQ).α (Sum.inr i) = (E.directSum F hQ).Q then 1 else 0) : ℕ)
        = (if F.α i = F.Q then 1 else 0) :=
    fun i => if_congr (by simp only [directSum, Sum.elim_inr]; rw [hQ]) rfl rfl
  rw [Finset.sum_congr rfl (fun i (_ : i ∈ univ) => h2 i)]
  rfl

/-! ### Twist invariance -/

/-- The **twist** of an eigensystem by a scalar `c ≠ 0`: `(Q, α) ↦ (cQ, cα)`.  This is
the eigenvalue-model shadow of a Tate twist / normalisation change. -/
def twist (E : DualEigensystem K ι) (c : K) (hc : c ≠ 0) : DualEigensystem K ι where
  Q := c * E.Q
  Q_ne_zero := mul_ne_zero hc E.Q_ne_zero
  α := fun i => c * E.α i
  σ := E.σ
  σ_involutive := E.σ_involutive
  duality := fun i => by linear_combination c ^ 2 * E.duality i

/-- **The root sign is a twist invariant**: rescaling all eigenvalues and the weight by
the same `c ≠ 0` leaves `ε` unchanged, so `ε` depends only on the normalised eigenvalues
`α_i / Q`. -/
theorem rootSign_twist (E : DualEigensystem K ι) (c : K) (hc : c ≠ 0) :
    (E.twist c hc).rootSign = E.rootSign := by
  have hQ : E.Q ^ E.deg ≠ 0 := pow_ne_zero _ E.Q_ne_zero
  have hcd : c ^ E.deg ≠ 0 := pow_ne_zero _ hc
  have hprod : (∏ i, (E.twist c hc).α i) = c ^ E.deg * ∏ i, E.α i := by
    simp only [twist]
    rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ, deg_eq_card]
  rw [rootSign, rootSign, hprod, show (E.twist c hc).deg = E.deg from rfl,
    show (E.twist c hc).Q = c * E.Q from rfl, mul_pow]
  field_simp

/-! ### Odd degree -/

/-- **Odd degree forces a self-dual eigenvalue.**  A duality involution on an
odd-dimensional cohomology has a fixed point, since the non-fixed indices pair up. -/
theorem exists_fixed_point_of_odd_deg (E : DualEigensystem K ι) (hodd : Odd E.deg) :
    ∃ i, E.σ i = i := by
  classical
  by_contra hcon
  push_neg at hcon
  obtain ⟨k, hk⟩ := E.even_card_nonfixed
  have huniv : (univ.filter (fun i => ¬ E.σ i = i)) = (univ : Finset ι) := by
    ext i
    simp [hcon i]
  rw [huniv, Finset.card_univ] at hk
  obtain ⟨m, hm⟩ := hodd
  rw [deg] at hm
  omega

/-- **Odd degree ⟹ sign `−1`, under the mission hypothesis.**  If duality has no `−Q`
fixed point and the degree is odd, the root sign is `−1`. -/
theorem rootSign_eq_neg_one_of_odd_deg (E : DualEigensystem K ι)
    (hno : ∀ i, E.σ i = i → E.α i ≠ -E.Q) (hodd : Odd E.deg) :
    E.rootSign = -1 := by
  rw [E.rootSign_eq_neg_one_pow_deg hno]
  exact hodd.neg_one_pow

/-- **Odd degree ⟹ central vanishing.**  Under the mission hypothesis, an odd-degree
duality eigensystem has `P(Q⁻¹) = 0`: the zeta factor vanishes at the central point.
This is the eigenvalue-model counterpart of
`BSD.FunctionalEquation.central_vanishing_of_sign_neg_one`. -/
theorem charPoly_central_vanishing_of_odd_deg (E : DualEigensystem K ι)
    (hchar : (-1 : K) ≠ 1) (hno : ∀ i, E.σ i = i → E.α i ≠ -E.Q) (hodd : Odd E.deg) :
    E.charPoly E.Q⁻¹ = 0 :=
  E.charPoly_central_eq_zero_of_rootSign_neg hchar (E.rootSign_eq_neg_one_of_odd_deg hno hodd)

end DualEigensystem

end WeilDualitySign