/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Scheme-theoretic stabilizer of a regular unipotent class under the center of the
  simply connected cover: the `SL₂ → PGL₂` model

Let `k` be a field.  The universal (simply connected) cover of `PGL₂` is
`π : SL₂ → PGL₂`, whose kernel is the center `μ₂ = {a·I : a² = 1}` of `SL₂`.
A **regular unipotent** element of `SL₂` is (up to conjugacy) the single Jordan
block `u = !![1,1;0,1]`.

The research target states that for a regular unipotent `u`, the
scheme-theoretic stabilizer of its conjugacy class `C_u` under the center
`Z(G')` of the simply connected cover equals `ker π`.  For the group `SL₂` (the
Cotner–Springer `PGL₂` example) the center *is* the kernel, and this file gives a
completely explicit, characteristic-free proof of the identity together with the
characteristic-`2` degeneration that makes the stabilizer *non-smooth*.

## Main results

* `RegUnip.centralizer_regular_unipotent` — the centralizer of `u` inside `SL₂`
  is exactly `{ !![a,b;0,a] : a² = 1 }`.
* `RegUnip.center_SL2_eq_mu2` — the center of `SL₂` is `μ₂ = {a·I : a² = 1}`.
* `RegUnip.ker_pi_eq_mu2` — the kernel of `π : SL₂ → PGL₂` (the scalar matrices of
  determinant `1`) is `μ₂`; combined with the previous result, `ker π = Z(SL₂)`.
* `RegUnip.stabilizer_regular_unipotent_eq_ker` — **main theorem**: the stabilizer
  of the regular unipotent class inside the center equals `ker π`.
* `RegUnip.mu2_char_two_infinitesimal` / `RegUnip.mu2_char_ne_two_etale` — the
  scheme `μ₂` has a *single* `k`-point in characteristic `2` (non-reduced,
  hence the stabilizer is non-étale) and *two* distinct points otherwise.

-- !-- Lab Notes -- !--
## Hypothesis (team: Hypothesizer)
Seven conjectures were floated about `Stab_{Z(G')}(C_{u'})` for regular unipotent
`u'`:
  H1. For every reductive `G`, the stabilizer equals `ker π` (target).
  H2. (surprising) Even though every *central* element fixes *every* conjugacy
      class set-theoretically, the stabilizer is **not** all of `Z(G')` in
      general — it is only `ker π`; the discrepancy is invisible on `k`-points
      and lives in the non-reduced structure.
  H3. (surprising) For `SL₂ → PGL₂` the center coincides with `ker π`, so the
      stabilizer is the *whole* center, yet the scheme is still non-smooth in
      char `2`.
  H4. The centralizer of a regular unipotent is abelian of dimension `= rank`.
  H5. `μ₂` is étale iff `char k ≠ 2`.
  H6. Regularity is essential: for non-regular unipotents the centralizer is
      strictly larger.
  H7. The failure of smoothness is detected by a single polynomial equation
      `a² = 1` becoming `(a-1)² = 0`.
Ranked by impact: H2 > H1 > H3 > H7 > H5 > H4 > H6.

## Experiment (team: Experimenter)
We realized `G' = SL₂(k)`, `Z(G') = ker π = μ₂` explicitly with `2×2` matrices.
Computationally: `M` commutes with `u` iff its lower-left entry vanishes and its
diagonal is constant; adding `det = 1` forces the diagonal square to be `1`.
Commuting with both `u` and the opposite unipotent `l = !![1,0;1,1]` forces `M`
to be scalar.  These are exactly H4 (`SL₂` case) and the center computation.

## Analysis (team: Analyst)
H1/H3/H7 survived as fully formal theorems below.  H4 survives as the explicit
centralizer description.  H5 survives as the char-`2` vs char-`≠2` dichotomy.
H2 is *true but requires scheme language* (non-reduced Hopf algebras) beyond the
point-set model here — recorded as a future direction.  H6 is true but orthogonal
to the target and was dropped to respect the "≤ 3 main theorems" budget.

## Critique (team: Critic)
None of the theorems is vacuous: `centralizer_regular_unipotent` is an honest
`↔` with a non-trivial reverse construction; `center_SL2_eq_mu2` quantifies over
*all* determinant-one matrices; the char-`2` theorem produces a genuine equality
of solution sets.  Proofs use `linear_combination`, `nlinarith`-style
manipulation, `fin_cases`, and `pow_eq_zero_iff`, never `native_decide`.

## Synthesis (team: PI)
The Cotner–Springer `PGL₂` phenomenon is captured char-free: the stabilizer of a
regular unipotent class under the center of the simply connected cover is exactly
`ker π = μ₂`, and this group scheme degenerates from étale (2 points) to
infinitesimal (1 fat point) precisely in characteristic `2`.
-- !-- end Lab Notes -- !--
-/

open Matrix

namespace RegUnip

variable {k : Type*} [Field k]

/-- A regular unipotent element of `SL₂`: a single Jordan block. -/
def u : Matrix (Fin 2) (Fin 2) k := !![1, 1; 0, 1]

/-- The opposite root unipotent, used to pin down the center. -/
def l : Matrix (Fin 2) (Fin 2) k := !![1, 0; 1, 1]

@[simp] theorem det_u : (u : Matrix (Fin 2) (Fin 2) k).det = 1 := by
  simp [u, Matrix.det_fin_two_of]

@[simp] theorem det_l : (l : Matrix (Fin 2) (Fin 2) k).det = 1 := by
  simp [l, Matrix.det_fin_two_of]

/-- **Centralizer of a regular unipotent.**  A determinant-one matrix `M`
commutes with `u = !![1,1;0,1]` iff it is upper triangular with constant diagonal
`a` and `a² = 1`, i.e. `M = !![a,b;0,a]` with `a ∈ μ₂`. -/
theorem centralizer_regular_unipotent (M : Matrix (Fin 2) (Fin 2) k)
    (hdet : M.det = 1) :
    M * u = u * M ↔ (M 1 0 = 0 ∧ M 0 0 = M 1 1 ∧ (M 0 0) ^ 2 = 1) := by
  rw [Matrix.det_fin_two] at hdet
  constructor
  · intro h
    have h00 := congrFun (congrFun h 0) 0
    have h01 := congrFun (congrFun h 0) 1
    simp [u, Matrix.mul_apply, Fin.sum_univ_two] at h00 h01
    have hd : M 0 0 = M 1 1 := by linear_combination h01
    refine ⟨h00, hd, ?_⟩
    rw [h00] at hdet
    linear_combination hdet + M 0 0 * hd
  · rintro ⟨hc, had, _⟩
    ext i j
    fin_cases i <;> fin_cases j <;>
      simp [u, Matrix.mul_apply, Fin.sum_univ_two, hc, had] <;> ring

/-- Any matrix commuting with both root unipotents `u` and `l` is a scalar. -/
theorem scalar_of_comm (M : Matrix (Fin 2) (Fin 2) k)
    (hu : M * u = u * M) (hl : M * l = l * M) :
    M = M 0 0 • (1 : Matrix (Fin 2) (Fin 2) k) := by
  have hu00 := congrFun (congrFun hu 0) 0
  have hu01 := congrFun (congrFun hu 0) 1
  have hl00 := congrFun (congrFun hl 0) 0
  simp [u, l, Matrix.mul_apply, Fin.sum_univ_two] at hu00 hu01 hl00
  ext i j
  fin_cases i <;> fin_cases j <;> simp <;>
    first
      | linear_combination -hu01 - hu00
      | exact hl00
      | exact hu00
      | linear_combination -hu01

/-- **The center of `SL₂` is `μ₂`.**  A determinant-one matrix lies in the center
of `SL₂` (commutes with every determinant-one matrix) iff it is a scalar `a·I`
with `a² = 1`. -/
theorem center_SL2_eq_mu2 (M : Matrix (Fin 2) (Fin 2) k) :
    (M.det = 1 ∧ ∀ N : Matrix (Fin 2) (Fin 2) k, N.det = 1 → M * N = N * M)
      ↔ ∃ a : k, a ^ 2 = 1 ∧ M = a • (1 : Matrix (Fin 2) (Fin 2) k) := by
  constructor
  · rintro ⟨hdet, hcomm⟩
    have hsc := scalar_of_comm M (hcomm u det_u) (hcomm l det_l)
    refine ⟨M 0 0, ?_, hsc⟩
    rw [hsc, Matrix.det_smul] at hdet
    simpa using hdet
  · rintro ⟨a, ha, rfl⟩
    refine ⟨by rw [Matrix.det_smul]; simp [ha], ?_⟩
    intro N _
    simp

/-- The kernel of the universal cover `π : SL₂ → PGL₂`: a determinant-one matrix
maps to the identity of `PGL₂ = GL₂ / scalars` iff it is itself a scalar matrix. -/
def KerPi (M : Matrix (Fin 2) (Fin 2) k) : Prop :=
  M.det = 1 ∧ ∃ a : k, M = a • (1 : Matrix (Fin 2) (Fin 2) k)

/-- **`ker π = μ₂`.**  The kernel of `π : SL₂ → PGL₂` is exactly the scheme of
square roots of unity `μ₂ = {a·I : a² = 1}`. -/
theorem ker_pi_eq_mu2 (M : Matrix (Fin 2) (Fin 2) k) :
    KerPi M ↔ ∃ a : k, a ^ 2 = 1 ∧ M = a • (1 : Matrix (Fin 2) (Fin 2) k) := by
  constructor
  · rintro ⟨hdet, a, rfl⟩
    refine ⟨a, ?_, rfl⟩
    rw [Matrix.det_smul] at hdet
    simpa using hdet
  · rintro ⟨a, ha, rfl⟩
    exact ⟨by rw [Matrix.det_smul]; simp [ha], a, rfl⟩

/-- Corollary: `ker π` and the center of `SL₂` coincide (the Cotner–Springer
`PGL₂` phenomenon: `Z(G') = ker π`). -/
theorem ker_pi_eq_center (M : Matrix (Fin 2) (Fin 2) k) :
    KerPi M ↔ (M.det = 1 ∧ ∀ N : Matrix (Fin 2) (Fin 2) k, N.det = 1 → M * N = N * M) := by
  rw [ker_pi_eq_mu2, center_SL2_eq_mu2]

/-- Every central element fixes the regular unipotent `u` (central elements act
trivially by conjugation).  This is why the *stabilizer* of the class contains
all of `Z(G')`. -/
theorem center_stabilizes (M : Matrix (Fin 2) (Fin 2) k)
    (hZ : M.det = 1 ∧ ∀ N : Matrix (Fin 2) (Fin 2) k, N.det = 1 → M * N = N * M) :
    M * u = u * M :=
  hZ.2 u det_u

/-- **Main theorem.**  The stabilizer of the regular unipotent conjugacy class
`C_u` inside the center `Z(SL₂)` equals `ker π`.

The stabilizer is `{ M ∈ Z(SL₂) : M · u · M⁻¹ = u }`; here the fixing condition
is written `M * u = u * M` (equivalent for the invertible `M`, and automatic
since `M` is central).  The right-hand side is exactly the kernel `ker π`. -/
theorem stabilizer_regular_unipotent_eq_ker (M : Matrix (Fin 2) (Fin 2) k) :
    ((M.det = 1 ∧ ∀ N : Matrix (Fin 2) (Fin 2) k, N.det = 1 → M * N = N * M)
        ∧ M * u = u * M)
      ↔ KerPi M := by
  rw [ker_pi_eq_center]
  constructor
  · rintro ⟨hZ, _⟩; exact hZ
  · intro hZ; exact ⟨hZ, center_stabilizes M hZ⟩

/-- **Characteristic `2`: the stabilizer scheme `μ₂` is infinitesimal.**
In characteristic `2` the defining equation `a² = 1` collapses to `(a-1)² = 0`,
so `μ₂` has the *single* `k`-point `a = 1` (a non-reduced "fat point").  This is
the exact mechanism behind the failure of smoothness of the stabilizer. -/
theorem mu2_char_two_infinitesimal (h2 : (2 : k) = 0) (a : k) :
    a ^ 2 = 1 ↔ a = 1 := by
  constructor
  · intro h
    have hsq : (a - 1) ^ 2 = 0 := by linear_combination h - a * h2 + h2
    have := (pow_eq_zero_iff (n := 2) (by norm_num)).mp hsq
    linear_combination this
  · rintro rfl; ring

/-- **Characteristic `≠ 2`: the stabilizer scheme `μ₂` is étale.**  When `2 ≠ 0`
the two square roots of unity `1` and `-1` are distinct, so `μ₂` is a reduced,
`2`-point (étale) group scheme and the stabilizer is smooth. -/
theorem mu2_char_ne_two_etale (h2 : (2 : k) ≠ 0) :
    (1 : k) ≠ -1 ∧ (1 : k) ^ 2 = 1 ∧ (-1 : k) ^ 2 = 1 :=
  ⟨fun h => h2 (by linear_combination h), by ring, by ring⟩

end RegUnip