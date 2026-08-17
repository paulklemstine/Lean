import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.HolographicCyclicInequality

/-!
# Independence of the five-party cyclic inequality, and a non-geometric entropy vector

`Novelty.HolographicCyclicInequality` proves that every min-cut ("holographic")
entropy assignment obeys the five-party cyclic inequality

`∑_j S(A_j A_{j+1}) + S(A₀A₁A₂A₃A₄) ≤ ∑_j S(A_j A_{j+1} A_{j+2})`.

This file establishes that this inequality is *not* a formal consequence of the
standard entropy inequalities available before it, namely

* **subadditivity** `S(XY) ≤ S(X) + S(Y)`,
* **strong subadditivity** `S(XYZ) + S(Y) ≤ S(XY) + S(YZ)`,
* **weak monotonicity** `S(X) + S(Z) ≤ S(XY) + S(YZ)`, and
* **monogamy of mutual information (MMI)**
  `S(XY) + S(YZ) + S(XZ) ≥ S(XYZ) + S(X) + S(Y) + S(Z)`,

by exhibiting an explicit integer-valued five-party entropy vector `Sw` that
satisfies all four families on all pairwise disjoint arguments, yet violates the
cyclic inequality by exactly `1`.

Subsets of the five parties are encoded as bitmasks `0 ≤ m < 32`; unions become
`|||` and disjointness becomes `&&& = 0`.  All four validity families are
verified by kernel evaluation over the full `32³ = 32768` case space of triples
of masks — this is a genuine exhaustive computation, not a definitional
unfolding.

The consequence for emergent geometry: **no** bulk graph whatsoever can produce
this entropy vector (`no_bulk_geometry_realises_Sw`).  So the geometric states
form a strictly smaller cone than the quantum-mechanically consistent ones, and
"reconstruct the geometry from the entanglement" has a genuine obstruction that
is invisible to subadditivity, SSA, weak monotonicity and monogamy alone.
-/

noncomputable section

namespace EmergentGeometry

open Finset

/-! ## The witness vector -/

/-- An explicit five-party entropy vector, indexed by bitmasks `0 ≤ m < 32`
(bit `i` = party `i`).  Found by local search over integer vectors subject to
subadditivity, strong subadditivity, weak monotonicity and monogamy. -/
def Sw : ℕ → ℕ
  | 0 => 0  | 1 => 3  | 2 => 2  | 3 => 5  | 4 => 4  | 5 => 5  | 6 => 6  | 7 => 5
  | 8 => 2  | 9 => 5  | 10 => 4 | 11 => 7 | 12 => 6 | 13 => 6 | 14 => 7 | 15 => 5
  | 16 => 3 | 17 => 6 | 18 => 5 | 19 => 7 | 20 => 5 | 21 => 4 | 22 => 6 | 23 => 4
  | 24 => 4 | 25 => 5 | 26 => 6 | 27 => 6 | 28 => 4 | 29 => 3 | 30 => 5 | 31 => 2
  | _ => 0

/-- The empty region carries no entropy. -/
theorem Sw_empty : Sw 0 = 0 := rfl

/-! ## The four validity families

Each is checked exhaustively over all masks below `32`. -/

set_option maxRecDepth 100000 in
/-- **Subadditivity** holds for `Sw`. -/
theorem Sw_subadditive :
    ∀ X < 32, ∀ Y < 32, X &&& Y = 0 → Sw (X ||| Y) ≤ Sw X + Sw Y := by decide

set_option synthInstance.maxSize 1000 in
set_option synthInstance.maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
set_option maxHeartbeats 2000000 in
/-- **Strong subadditivity** holds for `Sw`. -/
theorem Sw_strong_subadditive :
    ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
      Sw (X ||| Y ||| Z) + Sw Y ≤ Sw (X ||| Y) + Sw (Y ||| Z) := by decide

set_option synthInstance.maxSize 1000 in
set_option synthInstance.maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
set_option maxHeartbeats 2000000 in
/-- **Weak monotonicity** holds for `Sw`. -/
theorem Sw_weak_monotone :
    ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
      Sw X + Sw Z ≤ Sw (X ||| Y) + Sw (Y ||| Z) := by decide

set_option synthInstance.maxSize 1000 in
set_option synthInstance.maxHeartbeats 1000000 in
set_option maxRecDepth 100000 in
set_option maxHeartbeats 2000000 in
/-- **Monogamy of mutual information** holds for `Sw`. -/
theorem Sw_monogamy :
    ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
      Sw (X ||| Y ||| Z) + Sw X + Sw Y + Sw Z
        ≤ Sw (X ||| Y) + Sw (Y ||| Z) + Sw (X ||| Z) := by decide

/-- **But the cyclic inequality fails**, by exactly one unit. -/
theorem Sw_violates_cyclic5 :
    Sw 7 + Sw 14 + Sw 28 + Sw 25 + Sw 19
      < Sw 3 + Sw 6 + Sw 12 + Sw 24 + Sw 17 + Sw 31 := by decide

/-! ## Packaging the independence statement -/

/-- Subadditivity as a predicate on entropy vectors indexed by five-party
bitmasks. -/
def SatisfiesSA (S : ℕ → ℕ) : Prop :=
  ∀ X < 32, ∀ Y < 32, X &&& Y = 0 → S (X ||| Y) ≤ S X + S Y

/-- Strong subadditivity as a predicate on entropy vectors. -/
def SatisfiesSSA (S : ℕ → ℕ) : Prop :=
  ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
    S (X ||| Y ||| Z) + S Y ≤ S (X ||| Y) + S (Y ||| Z)

/-- Weak monotonicity as a predicate on entropy vectors. -/
def SatisfiesWM (S : ℕ → ℕ) : Prop :=
  ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
    S X + S Z ≤ S (X ||| Y) + S (Y ||| Z)

/-- Monogamy of mutual information as a predicate on entropy vectors. -/
def SatisfiesMMI (S : ℕ → ℕ) : Prop :=
  ∀ X < 32, ∀ Y < 32, ∀ Z < 32, X &&& Y = 0 → Y &&& Z = 0 → X &&& Z = 0 →
    S (X ||| Y ||| Z) + S X + S Y + S Z ≤ S (X ||| Y) + S (Y ||| Z) + S (X ||| Z)

/-- The cyclic inequality for the five singleton parties. -/
def SatisfiesCyclic5 (S : ℕ → ℕ) : Prop :=
  S 3 + S 6 + S 12 + S 24 + S 17 + S 31 ≤ S 7 + S 14 + S 28 + S 25 + S 19

/-- **Main independence theorem.**  There is a five-party entropy vector
satisfying subadditivity, strong subadditivity, weak monotonicity and monogamy
of mutual information, but violating the cyclic inequality.  Hence the cyclic
inequality proved in `entropy_cyclic5` is a genuinely new constraint: it is not
derivable from the four earlier families. -/
theorem cyclic5_independent_of_SA_SSA_WM_MMI :
    ∃ S : ℕ → ℕ, SatisfiesSA S ∧ SatisfiesSSA S ∧ SatisfiesWM S ∧ SatisfiesMMI S ∧
      ¬ SatisfiesCyclic5 S :=
  ⟨Sw, Sw_subadditive, Sw_strong_subadditive, Sw_weak_monotone, Sw_monogamy,
    not_le.2 Sw_violates_cyclic5⟩

/-! ## No bulk geometry realises the witness -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- The union of the sub-family of `A₀ … A₄` selected by five Boolean flags. -/
def unionSel (b₀ b₁ b₂ b₃ b₄ : Bool) (A₀ A₁ A₂ A₃ A₄ : Region V) : Region V :=
  fun v => (b₀ && A₀ v) || (b₁ && A₁ v) || (b₂ && A₂ v) || (b₃ && A₃ v) || (b₄ && A₄ v)

/-- The bitmask named by five Boolean flags. -/
def bmask (b₀ b₁ b₂ b₃ b₄ : Bool) : ℕ :=
  b₀.toNat + 2 * b₁.toNat + 4 * b₂.toNat + 8 * b₃.toNat + 16 * b₄.toNat

/-- **The witness vector is not holographic.**  No bulk graph with five
pairwise disjoint boundary regions can have min-cut entropies given by `Sw`.
Since `Sw` satisfies subadditivity, SSA, weak monotonicity and monogamy, this
obstruction is invisible to those four families; it is detected precisely by the
cyclic inequality. -/
theorem no_bulk_geometry_realises_Sw (M : HoloModel V) (A₀ A₁ A₂ A₃ A₄ : Region V)
    (hd : ∀ v, AtMostOneTrue (A₀ v) (A₁ v) (A₂ v) (A₃ v) (A₄ v))
    (hreal : ∀ b₀ b₁ b₂ b₃ b₄ : Bool,
      entropy M (unionSel b₀ b₁ b₂ b₃ b₄ A₀ A₁ A₂ A₃ A₄) = (Sw (bmask b₀ b₁ b₂ b₃ b₄) : ℝ)) :
    False := by
  have hE : ∀ (b₀ b₁ b₂ b₃ b₄ : Bool) (R : Region V),
      (∀ v, unionSel b₀ b₁ b₂ b₃ b₄ A₀ A₁ A₂ A₃ A₄ v = R v) →
      entropy M R = (Sw (bmask b₀ b₁ b₂ b₃ b₄) : ℝ) := by
    intro b₀ b₁ b₂ b₃ b₄ R h
    have hR : R = unionSel b₀ b₁ b₂ b₃ b₄ A₀ A₁ A₂ A₃ A₄ := funext fun v => (h v).symm
    rw [hR]; exact hreal b₀ b₁ b₂ b₃ b₄
  have e01 := hE true true false false false (fun v => A₀ v || A₁ v)
    (by intro v; simp [unionSel])
  have e12 := hE false true true false false (fun v => A₁ v || A₂ v)
    (by intro v; simp [unionSel])
  have e23 := hE false false true true false (fun v => A₂ v || A₃ v)
    (by intro v; simp [unionSel])
  have e34 := hE false false false true true (fun v => A₃ v || A₄ v)
    (by intro v; simp [unionSel])
  have e40 := hE true false false false true (fun v => A₄ v || A₀ v)
    (by intro v; simp [unionSel]; cases A₀ v <;> cases A₄ v <;> rfl)
  have eall := hE true true true true true (fun v => A₀ v || A₁ v || A₂ v || A₃ v || A₄ v)
    (by intro v; simp [unionSel])
  have t012 := hE true true true false false (fun v => A₀ v || A₁ v || A₂ v)
    (by intro v; simp [unionSel])
  have t123 := hE false true true true false (fun v => A₁ v || A₂ v || A₃ v)
    (by intro v; simp [unionSel])
  have t234 := hE false false true true true (fun v => A₂ v || A₃ v || A₄ v)
    (by intro v; simp [unionSel])
  have t340 := hE true false false true true (fun v => A₃ v || A₄ v || A₀ v)
    (by intro v; simp [unionSel]; cases A₀ v <;> cases A₃ v <;> cases A₄ v <;> rfl)
  have t401 := hE true true false false true (fun v => A₄ v || A₀ v || A₁ v)
    (by intro v; simp [unionSel]; cases A₀ v <;> cases A₁ v <;> cases A₄ v <;> rfl)
  have hcyc := entropy_cyclic5 M A₀ A₁ A₂ A₃ A₄ hd
  rw [e01, e12, e23, e34, e40, eall, t012, t123, t234, t340, t401] at hcyc
  norm_num [bmask, Sw] at hcyc

end EmergentGeometry