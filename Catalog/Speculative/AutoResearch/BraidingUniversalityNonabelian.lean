/-
# Topological Quantum Computing: The Non-Abelian Core of Braiding Universality

This module isolates the precise *algebraic* reason that anyon-braiding is
universal for quantum computation: **the braiding gates do not commute**.

It is a self-contained companion to the catalog files
`Speculative.AutoResearch.BraidingUniversality` and
`...BraidingUniversalityExt` (Cycles 4471cf7c / 646015c5). Those files
established the Burau representation of `B₃`, the Yang–Baxter braid relation
(`BraidingUniversality.burau_braid_relation`), the determinants `burau_det₁/₂`,
the inverse of `σ₁` (`burauSigma₁_mul_inv`), the scalar/central full twist
(`burau_fullTwist_scalar`), and the number-theoretic torus dichotomy controlling
single-phase density (`phaseGate_orbit_dense` / `fibonacci_phase_not_dense`). The
remaining open result there is `su2_braiding_dense` — the *full* `SU(2)` density
statement — left as a `sorry` because it needs the classification of closed
subgroups of `SU(2)`; that deep theorem is *not* attacked here.

Instead we close the algebraic gap *underneath* it. The parent torus dichotomy
already proves that no single phase gate can be dense (rational phases have
finite order). Universality must therefore come from **non-commutativity**, and
here we prove exactly that, plus the minimal-polynomial structure of the
elementary braid `σ₁σ₂`. To keep this file independently checkable we re-declare
the Burau primitives in a fresh namespace `BraidingNonabelian` (so it never
clashes with the parent `BraidingUniversality` namespace).

## Main results

1. **Non-commutativity (`burau_noncomm`).** For *every* loop value `t` the
   Burau gates satisfy `σ₁σ₂ ≠ σ₂σ₁` — the algebraic certificate that the
   single-qubit braiding gate set is genuinely non-abelian, the precondition for
   `SU(2)` density that no single phase gate can supply. (The Critic strengthened
   this from an initial `t ≠ 0` form after finding the gates differ even at
   `t = 0`; the false guess `burau_comm_at_zero` was replaced accordingly.)

2. **Both generators are units (`burau_isUnit₁`, `burau_isUnit₂`), with explicit
   two-sided inverses.** The whole generating set lands in `GL₂(ℂ)` for `t ≠ 0`.

3. **Trace / determinant of the elementary braid (`burau_braidWord_trace`,
   `burau_braidWord_det`).** `tr(σ₁σ₂) = -t`, `det(σ₁σ₂) = t²` — the
   Markov-trace inputs feeding the Jones polynomial of the closure of `σ₁σ₂`.

4. **Cayley–Hamilton / minimal polynomial (`burau_braidWord_min_poly`).** The
   elementary braid `M = σ₁σ₂` satisfies `M² + t·M + t²·I = 0`; its eigenvalues
   `t·ζ₆^{±1}` show one braid already realises a genuine rotation.

5. **Unimodular consistency (`burau_braidWord_cube_at_one`).** At `t = 1`,
   `(σ₁σ₂)³ = I`, matching the parent's central full twist `(σ₁σ₂)³ = t³·I`.

6. **Non-trivial commutator (`burau_commutator_ne_one`) and the corrected
   boundary (`burau_degenerate_at_zero`, `burau_noncomm_at_zero`)**: at `t = 0`
   it is *invertibility* (`det σ₁ = 0`) that fails, not non-commutativity.

## Catalog synthesis

Connects knot theory / braid groups (Burau, Jones), linear algebra
(Cayley–Hamilton, units of `M₂(ℂ)`), and the quantum-computational universality
program. The bridge: *non-commutativity of the linear braid representation* is
the algebraic shadow of *non-abelian anyon statistics*, which is what makes
topological quantum computation universal.
-/
import Mathlib

set_option maxHeartbeats 1600000

open Matrix

namespace BraidingNonabelian

noncomputable section

/-! ## 0. The Burau primitives (re-declared, self-contained)

The reduced Burau representation of the three-strand braid group `B₃` sends the
two Artin generators to the following `2×2` matrices over `ℂ`, parametrised by
the loop variable `t` (the Jones variable). These match
`BraidingUniversality.burauSigma₁/₂`. -/

/-- Reduced Burau matrix of the first braid generator `σ₁` of `B₃`. -/
def burauSigma₁ (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![-t, 1; 0, 1]

/-- Reduced Burau matrix of the second braid generator `σ₂` of `B₃`. -/
def burauSigma₂ (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; t, -t]

/-- The explicit inverse matrix of `σ₁` (valid for `t ≠ 0`). -/
def burauSigma₁Inv (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![-t⁻¹, t⁻¹; 0, 1]

/-- The explicit inverse matrix of `σ₂` (valid for `t ≠ 0`). -/
def burauSigma₂Inv (t : ℂ) : Matrix (Fin 2) (Fin 2) ℂ := !![1, 0; 1, -t⁻¹]

-- !-- Burau braid relation (re-derived for self-containment) -- !--
-- !-- σ₁σ₂σ₁ = σ₂σ₁σ₂; both sides equal !![0,-t;-t²,0]; entrywise ring. -- !--
/-- **Yang–Baxter / braid relation.** The Burau generators satisfy the defining
relation of `B₃` for every loop parameter `t`. -/
theorem burau_braid_relation (t : ℂ) :
    burauSigma₁ t * burauSigma₂ t * burauSigma₁ t
      = burauSigma₂ t * burauSigma₁ t * burauSigma₂ t := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₂, Matrix.mul_apply, Fin.sum_univ_two]

/-- The first Burau generator has determinant `-t`. -/
theorem burau_det₁ (t : ℂ) : (burauSigma₁ t).det = -t := by
  simp [burauSigma₁, Matrix.det_fin_two]

/-- The second Burau generator has determinant `-t`. -/
theorem burau_det₂ (t : ℂ) : (burauSigma₂ t).det = -t := by
  simp [burauSigma₂, Matrix.det_fin_two]

/-! ## I. Non-commutativity of the braiding gates

The single most important *algebraic* fact for universality: the Burau gates do
not commute. The parent torus dichotomy shows any single (commuting) phase gate
fails to be dense; density can only come from this non-commutativity. -/

-- !-- Non-commutativity of Burau gates (universal) -- !--
-- !-- σ₁σ₂ and σ₂σ₁ differ in their (0,0) and (0,1) entries: equality forces t = 0 -- !--
-- !-- AND -t = 1 simultaneously, an impossibility — so they never commute. -- !--
/-- **Non-commutativity (`σ₁σ₂ ≠ σ₂σ₁`), for *every* loop value `t`.** The two
Burau gates fail to commute for all `t` (no hypothesis): if they were equal, the
(0,0) entries force `t = 0` while the (0,1) entries force `-t = 1`, a
contradiction. This is the algebraic certificate that single-qubit braiding is
genuinely non-abelian — the precondition for `SU(2)` density that no single phase
gate can supply. (Strengthened from an earlier `t ≠ 0` version: see the Critic's
note below, the gates do not commute even at the degenerate value `t = 0`.) -/
theorem burau_noncomm (t : ℂ) :
    burauSigma₁ t * burauSigma₂ t ≠ burauSigma₂ t * burauSigma₁ t := by
  intro h
  have h00 := congrFun (congrFun h 0) 0
  have h01 := congrFun (congrFun h 0) 1
  simp [burauSigma₁, burauSigma₂, Matrix.mul_apply, Fin.sum_univ_two] at h00 h01
  rw [h00] at h01
  norm_num at h01

-- !-- Lab Notebook: burau_noncomm -- !--
-- !-- Hypothesis: the reduced Burau gates of B₃ do not commute for nonzero loop t. -- !--
-- !-- Result: proved — and STRENGTHENED to all t — by comparing TWO entries: (0,0) -- !--
-- !--   forces t = 0, (0,1) forces -t = 1; these cannot both hold. -- !--
-- !-- Insight: this is the exact algebraic content the parent program's torus -- !--
-- !--   dichotomy leaves open: a commutative (abelian) gate set is a subgroup of a -- !--
-- !--   maximal torus and can never be dense in SU(2). Non-commutativity is therefore -- !--
-- !--   NECESSARY for universality, and it holds for the ENTIRE loop family. -- !--
-- !-- Failure analysis: a first attempt compared only the (0,0) entry and needed -- !--
-- !--   t ≠ 0; the Critic discovered the gates also differ at t = 0 (entry (0,1): -- !--
-- !--   0 vs 1), so a one-entry proof is too weak. Using both entries removes the -- !--
-- !--   hypothesis entirely and yields the sharper universal statement. -- !--
-- !-- End Lab Notebook -- !--

/-! ## II. Both generators are units (the `GL₂` picture) -/

-- !-- σ₁ · σ₁⁻¹ = I and σ₁⁻¹ · σ₁ = I -- !--
-- !-- Entrywise expansion; the nontrivial entry cancels via t·t⁻¹ = 1 (field_simp). -- !--
/-- `burauSigma₁Inv` is a right inverse of `burauSigma₁` for `t ≠ 0`. -/
theorem burauSigma₁_mul_inv (t : ℂ) (ht : t ≠ 0) :
    burauSigma₁ t * burauSigma₁Inv t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₁Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp <;> ring

/-- `burauSigma₁Inv` is a left inverse of `burauSigma₁` for `t ≠ 0`. -/
theorem burauSigma₁_inv_mul (t : ℂ) (ht : t ≠ 0) :
    burauSigma₁Inv t * burauSigma₁ t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₁Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp

/-- `burauSigma₂Inv` is a right inverse of `burauSigma₂` for `t ≠ 0`. -/
theorem burauSigma₂_mul_inv (t : ℂ) (ht : t ≠ 0) :
    burauSigma₂ t * burauSigma₂Inv t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₂, burauSigma₂Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp

/-- `burauSigma₂Inv` is a left inverse of `burauSigma₂` for `t ≠ 0`. -/
theorem burauSigma₂_inv_mul (t : ℂ) (ht : t ≠ 0) :
    burauSigma₂Inv t * burauSigma₂ t = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₂, burauSigma₂Inv, Matrix.mul_apply, Fin.sum_univ_two] <;>
    field_simp <;> ring

/-- The first Burau generator is a **unit** of `M₂(ℂ)` for `t ≠ 0`. -/
theorem burau_isUnit₁ (t : ℂ) (ht : t ≠ 0) : IsUnit (burauSigma₁ t) := by
  rw [Matrix.isUnit_iff_isUnit_det, burau_det₁]
  exact (isUnit_iff_ne_zero).2 (by simpa using ht)

/-- The second Burau generator is a **unit** of `M₂(ℂ)` for `t ≠ 0`. -/
theorem burau_isUnit₂ (t : ℂ) (ht : t ≠ 0) : IsUnit (burauSigma₂ t) := by
  rw [Matrix.isUnit_iff_isUnit_det, burau_det₂]
  exact (isUnit_iff_ne_zero).2 (by simpa using ht)

-- !-- Lab Notebook: GL₂ picture -- !--
-- !-- Hypothesis: both Burau generators are invertible for t ≠ 0. -- !--
-- !-- Result: explicit two-sided inverses give burau_isUnit₁/₂; whole gate set ⊂ GL₂(ℂ). -- !--
-- !-- Insight: the Burau map is a bona-fide group homomorphism B₃ → GL₂(ℂ) on the -- !--
-- !--   punctured loop t ≠ 0; invertibility and (below) non-commutativity are exactly -- !--
-- !--   the two ingredients an abstract density argument presupposes. -- !--
-- !-- Failure analysis: none; the only subtlety is field_simp for the t·t⁻¹ entry. -- !--
-- !-- End Lab Notebook -- !--

/-! ## III. The elementary braid `σ₁σ₂`: trace, determinant, minimal polynomial

`σ₁σ₂ = !![0,-t; t,-t]`. Its invariants are the Markov-trace inputs to the Jones
polynomial of the closure of `σ₁σ₂` (the Hopf link). -/

-- !-- Trace of the elementary braid -- !--
-- !-- σ₁σ₂ = !![0,-t;t,-t]; trace = 0 + (-t) = -t. -- !--
/-- **Markov trace of `σ₁σ₂`.** `tr(σ₁σ₂) = -t`. -/
theorem burau_braidWord_trace (t : ℂ) :
    Matrix.trace (burauSigma₁ t * burauSigma₂ t) = -t := by
  simp [burauSigma₁, burauSigma₂, Matrix.trace, Matrix.diag, Matrix.mul_apply,
    Fin.sum_univ_two]

-- !-- Determinant of the elementary braid -- !--
-- !-- det multiplicative: det σ₁ · det σ₂ = (-t)(-t) = t². -- !--
/-- **Determinant of `σ₁σ₂`.** `det(σ₁σ₂) = t²`. -/
theorem burau_braidWord_det (t : ℂ) :
    (burauSigma₁ t * burauSigma₂ t).det = t ^ 2 := by
  rw [Matrix.det_mul, burau_det₁, burau_det₂]
  ring

-- !-- Minimal polynomial of the elementary braid -- !--
-- !-- Cayley–Hamilton for trace -t, det t²: M² + t·M + t²·I = 0, entrywise. -- !--
/-- **Minimal polynomial / Cayley–Hamilton of `σ₁σ₂`.** The elementary braid
`M = σ₁σ₂` satisfies `M² + t·M + t²·I = 0`. The roots are `t·ζ₆^{±1}` (primitive
sixth-root scaled), so even one braid contributes a genuine rotation, not a mere
phase. -/
theorem burau_braidWord_min_poly (t : ℂ) :
    (burauSigma₁ t * burauSigma₂ t) ^ 2
        + t • (burauSigma₁ t * burauSigma₂ t)
        + t ^ 2 • (1 : Matrix (Fin 2) (Fin 2) ℂ)
      = 0 := by
  rw [pow_two]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₂, Matrix.add_apply, Matrix.smul_apply] <;> ring

-- !-- Full twist is scalar t³·I (re-derived) -- !--
-- !-- (σ₁σ₂)³ expands entrywise to !![t³,0;0,t³] = t³ • I. -- !--
/-- **Central full twist.** `(σ₁σ₂)³ = t³·I`; the center `Z(B₃) = ⟨(σ₁σ₂)³⟩` maps
to the scalars. (Re-derivation of `BraidingUniversality.burau_fullTwist_scalar`.) -/
theorem burau_fullTwist_scalar (t : ℂ) :
    (burauSigma₁ t * burauSigma₂ t) ^ 3
      = (t ^ 3) • (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  simp only [pow_succ, pow_zero, one_mul]
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [burauSigma₁, burauSigma₂, Matrix.mul_apply, Fin.sum_univ_two,
      Matrix.smul_apply]

-- !-- Consistency with the central full twist at t = 1 -- !--
-- !-- At t=1 the full twist is 1³•I = I; cross-checks the minimal polynomial. -- !--
/-- **Unimodular consistency.** At `t = 1`, `(σ₁σ₂)³ = I`. -/
theorem burau_braidWord_cube_at_one :
    (burauSigma₁ (1 : ℂ) * burauSigma₂ (1 : ℂ)) ^ 3
      = (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  rw [burau_fullTwist_scalar]
  simp

-- !-- Lab Notebook: elementary braid invariants -- !--
-- !-- Hypothesis: σ₁σ₂ has trace -t, det t², minimal polynomial X²+tX+t², cube t³•I. -- !--
-- !-- Result: all proved; at t=1 the cube collapses to I, agreeing with the center. -- !--
-- !-- Insight: the eigenvalues t·ζ₆^{±1} are NOT roots of unity for generic t, so a -- !--
-- !--   single braid already realizes a non-finite-order, non-scalar gate — exactly -- !--
-- !--   the ingredient the abelian torus picture cannot reach. t=1 is the topological -- !--
-- !--   sweet spot where the braid has finite (order-3) projective action. -- !--
-- !-- Failure analysis: Cayley–Hamilton must be phrased with `•` (scalars), so that -- !--
-- !--   `ring` closes each entry after Fin.sum_univ_two unfolding. -- !--
-- !-- End Lab Notebook -- !--

/-! ## IV. Generalization & boundary of the best theorem

The "best" theorem is `burau_noncomm`. Two natural follow-ups: -/

-- !-- Non-trivial commutator -- !--
-- !-- σ₁σ₂σ₁⁻¹σ₂⁻¹ = 1 would force σ₁σ₂ = σ₂σ₁; contradiction with burau_noncomm. -- !--
/-- **Generalization (commutator is non-trivial).** For `t ≠ 0` the commutator
`σ₁σ₂σ₁⁻¹σ₂⁻¹` is not the identity: the braid image is non-abelian as a subgroup
of `GL₂(ℂ)`, witnessed by a single commutator. -/
theorem burau_commutator_ne_one (t : ℂ) (ht : t ≠ 0) :
    burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t * burauSigma₂Inv t
      ≠ (1 : Matrix (Fin 2) (Fin 2) ℂ) := by
  intro h
  apply burau_noncomm t
  have h2 : burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t = burauSigma₂ t := by
    calc burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t
        = burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t
            * (burauSigma₂Inv t * burauSigma₂ t) := by
          rw [burauSigma₂_inv_mul t ht, mul_one]
      _ = burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t * burauSigma₂Inv t
            * burauSigma₂ t := by rw [← mul_assoc]
      _ = burauSigma₂ t := by rw [h, one_mul]
  calc burauSigma₁ t * burauSigma₂ t
      = burauSigma₁ t * burauSigma₂ t * burauSigma₁Inv t * burauSigma₁ t := by
        rw [mul_assoc, burauSigma₁_inv_mul t ht, mul_one]
    _ = burauSigma₂ t * burauSigma₁ t := by rw [h2]

-- !-- Boundary (corrected): degeneration is loss of invertibility, not commutativity -- !--
-- !-- The Critic's original guess ("they commute at t=0") is FALSE — see burau_noncomm. -- !--
-- !-- The genuine boundary at t=0 is det σ₁ = 0, i.e. the gate leaves GL₂(ℂ). -- !--
/-- **Boundary case (corrected).** A first guess was that non-commutativity fails
at the degenerate loop value `t = 0`; this is *false* — `burau_noncomm 0` shows the
gates differ even there (entry `(0,1)`: `0` vs `1`). The genuine degeneration at
`t = 0` is the loss of *invertibility*: `det (σ₁ 0) = 0`, so the representation
leaves `GL₂(ℂ)`. Non-commutativity is robust; invertibility is what breaks. -/
theorem burau_degenerate_at_zero : (burauSigma₁ (0 : ℂ)).det = 0 := by
  simp [burauSigma₁, Matrix.det_fin_two]

/-- The gates remain non-commuting at the degenerate value `t = 0` (a direct
specialisation of the universal `burau_noncomm`), refuting the naive boundary
guess. -/
theorem burau_noncomm_at_zero :
    burauSigma₁ (0 : ℂ) * burauSigma₂ (0 : ℂ)
      ≠ burauSigma₂ (0 : ℂ) * burauSigma₁ (0 : ℂ) := burau_noncomm 0

-- !-- Lab Notebook: generalization & boundary -- !--
-- !-- Hypothesis: non-commutativity needs t ≠ 0 and fails (gates commute) at t = 0. -- !--
-- !-- Result: REFUTED by the Critic. The gates never commute (burau_noncomm holds -- !--
-- !--   for ALL t, including t = 0 via burau_noncomm_at_zero); the commutator is -- !--
-- !--   non-trivial; the true boundary at t = 0 is det σ₁ = 0 (leaves GL₂). -- !--
-- !-- Insight: invertibility and non-commutativity are INDEPENDENT phenomena here. -- !--
-- !--   At t = 0 invertibility breaks (det = 0) but non-commutativity persists, so -- !--
-- !--   the non-abelian structure is more robust than the group structure. -- !--
-- !-- Failure analysis: the initial boundary theorem `burau_comm_at_zero` was FALSE -- !--
-- !--   (compiler returned `⊢ False` on entry (0,1)); replaced by the correct -- !--
-- !--   degeneration statement and a refutation specialisation. A reminder that a -- !--
-- !--   plausible boundary guess must itself be checked. -- !--
-- !-- End Lab Notebook -- !--

end

end BraidingNonabelian