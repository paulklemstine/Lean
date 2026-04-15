/-! # CatalogBuild.Physics.ArchitectureOfReality.KauffmanBracket

Auto-generated from theorem catalog database.
Domain: Physics/ArchitectureOfReality
Declarations: 14
-/

import Mathlib

noncomputable section

/-- A crossing in a knot diagram can be resolved in two ways -/
inductive Smoothing
  | A_smooth
  | B_smooth
deriving DecidableEq, Fintype


/-- A state of a knot diagram with n crossings -/
def KnotState (n : ℕ) := Fin n → Smoothing


instance (n : ℕ) : Fintype (KnotState n) := inferInstanceAs (Fintype (Fin n → Smoothing))


/-- The sigma of a state: (# A-smoothings) - (# B-smoothings) -/
def stateSigma {n : ℕ} (s : KnotState n) : ℤ :=
  let a_count := (Finset.univ.filter (fun i => s i = Smoothing.A_smooth)).card
  let b_count := (Finset.univ.filter (fun i => s i = Smoothing.B_smooth)).card
  (a_count : ℤ) - (b_count : ℤ)


theorem smoothing_count_sum {n : ℕ} (s : KnotState n) :
    (Finset.univ.filter (fun i : Fin n => s i = Smoothing.A_smooth)).card +
    (Finset.univ.filter (fun i : Fin n => s i = Smoothing.B_smooth)).card = n := by
  rw [ Finset.card_filter, Finset.card_filter ];
  rw [ ← Finset.sum_add_distrib, Finset.sum_congr rfl fun _ _ => by rcases s _ with ( _ | _ ) <;> rfl, Finset.sum_const, Finset.card_fin ] ; norm_num;
  aesop


/-- The writhe of a knot diagram (sum of crossing signs) -/
def writhe (crossingSigns : List ℤ) : ℤ := crossingSigns.sum


theorem trefoil_writhe : writhe [-1, -1, -1] = -3 := by decide

theorem unknot_writhe : writhe [] = 0 := by decide


/-- The Temperley-Lieb relation: idempotent up to scalar -/
def IsTLIdempotent {R : Type*} [Ring R] (e : R) (delta : R) : Prop :=
  e * e = delta • e


/-- When delta = 1, TL generators are genuine idempotents -/
theorem TL_at_delta_one {R : Type*} [Ring R] (e : R)
    (h : IsTLIdempotent e (1 : R)) : e * e = e := by
  unfold IsTLIdempotent at h; rwa [one_smul] at h


theorem smoothing_card : Fintype.card Smoothing = 2 := by decide


theorem state_count (n : ℕ) : Fintype.card (KnotState n) = 2 ^ n := by
  show Fintype.card (Fin n → Smoothing) = 2 ^ n
  rw [Fintype.card_fun, Fintype.card_fin, smoothing_card]


/-- Primitive root of unity for level k -/
def rootOfUnity (k : ℕ) : ℂ := Complex.exp (2 * Real.pi * Complex.I / k)


/-- The braiding eigenvalues for Jones at level k -/
def braidingEigenvalues (k : ℕ) : ℂ × ℂ :=
  let q := rootOfUnity (2 * k)
  (q, -q⁻¹)


end
