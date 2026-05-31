import Mathlib

/-!
# Hyperbolic Arithmetic: Definitions and Core Theory

This module develops arithmetic on the Poincaré disk model of hyperbolic geometry.
We define:

* `DiskPoint` — points in the open unit disk {z ∈ ℂ : ‖z‖ < 1}
* `SL2Z_elem` — elements of SL₂(ℤ) with Möbius action
* `hypDist` — the hyperbolic distance function
* `HyperbolicLattice` — the orbit of a base point under the modular group

## References

* Beardon, A.F. "The Geometry of Discrete Groups" (1983)
* Katok, S. "Fuchsian Groups" (1992)
-/

noncomputable section

open Real Complex

/-! ## Part 1: The Poincaré Disk -/

/-- A point in the open unit disk of ℂ. -/
structure DiskPoint where
  val : ℂ
  mem : ‖val‖ < 1

namespace DiskPoint

/-- The origin of the disk. -/
def origin : DiskPoint where
  val := 0
  mem := by simp

/-- The norm squared of a disk point is less than 1. -/
theorem normSq_lt_one (p : DiskPoint) : Complex.normSq p.val < 1 := by
  rw [Complex.normSq_eq_norm_sq]
  have h := p.mem
  have h1 : ‖p.val‖ ≥ 0 := norm_nonneg _
  nlinarith [sq_nonneg (1 - ‖p.val‖)]

/-- 1 - normSq z > 0 for a disk point. -/
theorem one_sub_normSq_pos (p : DiskPoint) : 0 < 1 - Complex.normSq p.val := by
  linarith [normSq_lt_one p]

/-- 1 - ‖z‖ > 0 for a disk point. -/
theorem one_sub_norm_pos (p : DiskPoint) : 0 < 1 - ‖p.val‖ := by
  linarith [p.mem]

end DiskPoint

/-! ## Part 2: Hyperbolic Distance -/

/-- The Möbius cross-ratio distance parameter: ‖(z - w) / (1 - z̄w)‖. -/
def möbiusParam (z w : ℂ) : ℝ :=
  ‖(z - w) / (1 - starRingEnd ℂ z * w)‖

/-- The hyperbolic distance in the Poincaré disk model.
    d(z,w) = log((1 + |τ|)/(1 - |τ|))
    where τ = (z - w)/(1 - z̄w). -/
def hypDist (z w : ℂ) : ℝ :=
  Real.log ((1 + möbiusParam z w) / (1 - möbiusParam z w))

/-- Hyperbolic distance from a point to itself is zero. -/
theorem hypDist_self (z : ℂ) : hypDist z z = 0 := by
  simp [hypDist, möbiusParam, sub_self, norm_zero, zero_div]

/-- The Möbius parameter is symmetric. -/
theorem möbiusParam_comm (z w : ℂ) : möbiusParam z w = möbiusParam w z := by
  unfold möbiusParam
  rw [norm_div, norm_div, norm_sub_rev]
  congr 1
  have : (1 : ℂ) - starRingEnd ℂ z * w = starRingEnd ℂ ((1 : ℂ) - starRingEnd ℂ w * z) := by
    simp only [starRingEnd_apply, map_sub, map_mul, map_one, star_star]
    ring
  rw [this, norm_conj]

/-- Hyperbolic distance is symmetric. -/
theorem hypDist_comm (z w : ℂ) : hypDist z w = hypDist w z := by
  simp only [hypDist, möbiusParam_comm]

/-! ## Part 3: SL₂(ℤ) and Möbius Transformations -/

/-- An element of SL₂(ℤ): a 2×2 integer matrix with determinant 1. -/
@[ext]
structure SL2Z_elem where
  a : ℤ
  b : ℤ
  c : ℤ
  d : ℤ
  det_one : a * d - b * c = 1

namespace SL2Z_elem

instance : DecidableEq SL2Z_elem := fun g h =>
  if ha : g.a = h.a then
    if hb : g.b = h.b then
      if hc : g.c = h.c then
        if hd : g.d = h.d then isTrue (by ext <;> assumption)
        else isFalse (fun e => hd (congr_arg SL2Z_elem.d e))
      else isFalse (fun e => hc (congr_arg SL2Z_elem.c e))
    else isFalse (fun e => hb (congr_arg SL2Z_elem.b e))
  else isFalse (fun e => ha (congr_arg SL2Z_elem.a e))

/-- The identity matrix. -/
def id : SL2Z_elem := ⟨1, 0, 0, 1, by ring⟩

/-- Matrix multiplication. -/
def mul (g h : SL2Z_elem) : SL2Z_elem where
  a := g.a * h.a + g.b * h.c
  b := g.a * h.b + g.b * h.d
  c := g.c * h.a + g.d * h.c
  d := g.c * h.b + g.d * h.d
  det_one := by nlinarith [g.det_one, h.det_one]

/-- The inverse matrix. -/
def inv (g : SL2Z_elem) : SL2Z_elem where
  a := g.d; b := -g.b; c := -g.c; d := g.a
  det_one := by nlinarith [g.det_one]

/-- The trace. -/
def tr (g : SL2Z_elem) : ℤ := g.a + g.d

/-- The generator S. -/
def S : SL2Z_elem := ⟨0, -1, 1, 0, by ring⟩

/-- The generator T. -/
def T : SL2Z_elem := ⟨1, 1, 0, 1, by ring⟩

/-- An element is hyperbolic if |tr(g)| > 2. -/
def IsHyperbolic (g : SL2Z_elem) : Prop := 2 < |g.tr|

/-- An element is parabolic if |tr(g)| = 2. -/
def IsParabolic (g : SL2Z_elem) : Prop := |g.tr| = 2

/-- An element is elliptic if |tr(g)| < 2. -/
def IsElliptic (g : SL2Z_elem) : Prop := |g.tr| < 2

/-- The Möbius action of an SL₂(ℤ) element on ℂ.
    g · z = (az + b) / (cz + d) -/
def möbiusAct (g : SL2Z_elem) (z : ℂ) : ℂ :=
  ((g.a : ℂ) * z + (g.b : ℂ)) / ((g.c : ℂ) * z + (g.d : ℂ))

theorem mul_assoc (f g h : SL2Z_elem) :
    mul (mul f g) h = mul f (mul g h) := by
  ext <;> simp [mul] <;> ring

theorem id_mul (g : SL2Z_elem) : mul id g = g := by
  ext <;> simp [mul, id]

theorem mul_id (g : SL2Z_elem) : mul g id = g := by
  ext <;> simp [mul, id]

theorem inv_mul_cancel (g : SL2Z_elem) : mul (inv g) g = id := by
  ext <;> simp [mul, inv, id] <;> nlinarith [g.det_one]

theorem mul_inv_cancel (g : SL2Z_elem) : mul g (inv g) = id := by
  ext <;> simp [mul, inv, id] <;> nlinarith [g.det_one]

/-- The trace is invariant under inversion. -/
theorem tr_inv (g : SL2Z_elem) : (inv g).tr = g.tr := by
  simp [tr, inv]; ring

/-- **Cayley-Hamilton for SL₂**: tr(g²) = tr(g)² - 2. -/
theorem tr_sq (g : SL2Z_elem) : (mul g g).tr = g.tr ^ 2 - 2 := by
  unfold tr mul; nlinarith [g.det_one]

/-- T is parabolic. -/
theorem T_parabolic : IsParabolic T := by
  simp [IsParabolic, tr, T]

/-- S is elliptic. -/
theorem S_elliptic : IsElliptic S := by
  simp [IsElliptic, tr, S]

/-- **Trace classification trichotomy**: every non-identity element of SL₂(ℤ)
    is either elliptic, parabolic, or hyperbolic. -/
theorem trace_trichotomy (g : SL2Z_elem) :
    IsElliptic g ∨ IsParabolic g ∨ IsHyperbolic g := by
  unfold IsElliptic IsParabolic IsHyperbolic
  by_cases h1 : |g.tr| < 2
  · left; exact h1
  · push_neg at h1
    by_cases h2 : |g.tr| = 2
    · right; left; exact h2
    · right; right; omega

end SL2Z_elem

/-! ## Part 4: The Hyperbolic Lattice -/

/-- A **hyperbolic lattice** is the orbit of a base point in the Poincaré disk
    under a discrete subgroup of PSL(2,ℝ), together with a generating set.
    This is our novel "hyperbolic integer" structure Z_H. -/
structure HyperbolicLattice where
  /-- The base point. -/
  basePoint : DiskPoint
  /-- The generators. -/
  generators : List SL2Z_elem
  /-- Generators are nontrivial. -/
  gen_nontrivial : ∀ g ∈ generators, g ≠ SL2Z_elem.id

/-- The **displacement length** of g at z₀: ℓ(g) = d_H(z₀, g·z₀). -/
def displacementLength (g : SL2Z_elem) (z₀ : DiskPoint) : ℝ :=
  hypDist z₀.val (SL2Z_elem.möbiusAct g z₀.val)

/-- A hyperbolic integer is **prime** if it is a generator or inverse of a generator. -/
def IsHypPrime (L : HyperbolicLattice) (g : SL2Z_elem) : Prop :=
  g ∈ L.generators ∨ SL2Z_elem.inv g ∈ L.generators

/-- The **Fricke character** of a pair (g,h). -/
def frickeChar (g h : SL2Z_elem) : ℤ × ℤ × ℤ :=
  (g.tr, h.tr, (SL2Z_elem.mul g h).tr)

/-- Predicate: (x,y,z) lies on the Markov surface x²+y²+z² - xyz = κ. -/
def onMarkovSurface (x y z κ : ℤ) : Prop :=
  x ^ 2 + y ^ 2 + z ^ 2 - x * y * z = κ

end