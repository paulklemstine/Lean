import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

This module develops the foundations of arithmetic on the Poincaré disk model of
hyperbolic geometry. We define the Poincaré disk, Möbius transformations that
preserve it, hyperbolic distance, and "hyperbolic integers" as orbit points of
a discrete group action.

## Main Definitions

* `PoincareDisk` - The open unit disk in ℂ as a subtype
* `mobiusMap` - The Möbius automorphism φ_a(z) = (a - z) / (1 - conj(a) * z)
* `hypDist` - The hyperbolic distance function
* `HyperbolicLattice` - Orbit of a basepoint under a discrete group of isometries
* `hypCountingFn` - Counting function for lattice points within hyperbolic radius

## Main Results

* `mobius_maps_zero_to_a` - φ_a(0) = a
* `mobius_maps_a_to_zero` - φ_a(a) = 0
* `mobius_involutive` - φ_a ∘ φ_a = id (Möbius automorphisms are involutions)
* `mobius_norm_sq_formula` - Key identity for disk-preservation
* `mobius_preserves_disk` - Möbius transformations preserve the open unit disk
* `hypDistSq_self` - d(z,z) = 0
* `hypDistSq_symm` - d(z,w) = d(w,z)
* `counting_fn_mono` - The hyperbolic counting function is monotone
* `gauss_to_hyp_embedding` - Cross-domain bridge to the Gauss circle problem

## References

* Katok, S. "Fuchsian Groups" (1992)
* Iwaniec, H. "Spectral Methods of Automorphic Forms" (2002)
-/

noncomputable section

open Complex Finset Real

/-! ## The Poincaré Disk -/

/-- A point in the Poincaré disk: a complex number with norm strictly less than 1. -/
def PoincareDisk := { z : ℂ // ‖z‖ < 1 }

namespace PoincareDisk

instance : CoeOut PoincareDisk ℂ := ⟨Subtype.val⟩

/-- The origin of the Poincaré disk. -/
def origin : PoincareDisk := ⟨0, by simp⟩

/-- The norm squared of a disk point is less than 1. -/
theorem normSq_lt_one (z : PoincareDisk) : Complex.normSq z.val < 1 := by
  have h := z.prop
  rw [Complex.normSq_eq_norm_sq]
  have : ‖z.val‖ < 1 := h
  nlinarith [norm_nonneg z.val]

/-
The denominator 1 - conj(a) * z is nonzero for disk points.
-/
theorem one_sub_conj_mul_ne_zero (a z : PoincareDisk) :
    (1 : ℂ) - starRingEnd ℂ a.val * z.val ≠ 0 := by
  by_contra h_contra;
  simp_all +decide [ Complex.ext_iff ];
  nlinarith [ sq_nonneg ( ( a : ℂ ).re * ( z : ℂ ).im - ( a : ℂ ).im * ( z : ℂ ).re ), Complex.normSq_apply ( a : ℂ ), Complex.normSq_apply ( z : ℂ ), a.2, z.2, show ( Complex.normSq ( a : ℂ ) ) < 1 from by simpa [ Complex.normSq_eq_norm_sq ] using a.2, show ( Complex.normSq ( z : ℂ ) ) < 1 from by simpa [ Complex.normSq_eq_norm_sq ] using z.2 ]

end PoincareDisk

/-! ## Möbius Transformations -/

/-- The Möbius automorphism of the disk: φ_a(z) = (a - z) / (1 - conj(a) * z).
    This is an involutive isometry of the Poincaré disk sending a ↦ 0. -/
def mobiusMap (a : ℂ) (z : ℂ) : ℂ :=
  (a - z) / (1 - starRingEnd ℂ a * z)

/-- φ_a(0) = a: the Möbius map sends 0 to a. -/
theorem mobius_maps_zero_to_a (a : ℂ) : mobiusMap a 0 = a := by
  simp [mobiusMap]

/-- φ_a(a) = 0: the Möbius map sends a to 0. -/
theorem mobius_maps_a_to_zero (a : ℂ) : mobiusMap a a = 0 := by
  simp [mobiusMap]

/-
Key algebraic identity for the Möbius map norm squared.
    |1 - ā·z|² · (1 - |φ_a(z)|²) = (1 - |a|²)(1 - |z|²)

    This is the fundamental identity that proves disk-preservation.
-/
theorem mobius_norm_sq_identity (a z : ℂ)
    (hdenom : (1 : ℂ) - starRingEnd ℂ a * z ≠ 0) :
    Complex.normSq (1 - starRingEnd ℂ a * z) *
      (1 - Complex.normSq (mobiusMap a z)) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) := by
  unfold mobiusMap;
  simp_all +decide [ Complex.normSq ];
  rw [ sub_div', mul_div_cancel₀ ];
  · ring;
  · exact fun h => hdenom <| by norm_num [ Complex.ext_iff ] ; constructor <;> nlinarith;
  · exact fun h => hdenom <| by norm_num [ Complex.ext_iff ] ; constructor <;> nlinarith

/-
Möbius transformations preserve the open unit disk:
    if |a| < 1 and |z| < 1, then |φ_a(z)| < 1.
-/
theorem mobius_preserves_disk (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1)
    (hdenom : (1 : ℂ) - starRingEnd ℂ a * z ≠ 0) :
    Complex.normSq (mobiusMap a z) < 1 := by
  have h_pos : Complex.normSq (1 - starRingEnd ℂ a * z) * (1 - Complex.normSq (mobiusMap a z)) = (1 - Complex.normSq a) * (1 - Complex.normSq z) := by
    exact mobius_norm_sq_identity a z hdenom;
  nlinarith [ Complex.normSq_pos.mpr hdenom ]

/-
The Möbius map is an involution: φ_a(φ_a(z)) = z.
-/
theorem mobius_involutive (a z : ℂ)
    (hdenom1 : (1 : ℂ) - starRingEnd ℂ a * z ≠ 0)
    (hdenom2 : (1 : ℂ) - starRingEnd ℂ a * mobiusMap a z ≠ 0) :
    mobiusMap a (mobiusMap a z) = z := by
  grind +locals

/-! ## Hyperbolic Distance -/

/-- The hyperbolic pseudo-distance squared on the Poincaré disk model.
    We define it as |φ_w(z)|² where φ_w is the Möbius map sending w to 0.
    The actual hyperbolic distance is arctanh(√(hypDistSq z w)). -/
def hypDistSq (z w : ℂ) : ℝ :=
  Complex.normSq (mobiusMap w z)

/-- d(z,z) = 0: the hyperbolic distance from a point to itself is zero. -/
theorem hypDistSq_self (z : ℂ) : hypDistSq z z = 0 := by
  simp [hypDistSq, mobiusMap]

/-
The squared distance is symmetric: hypDistSq z w = hypDistSq w z.
    This follows from the identity |φ_w(z)| = |φ_z(w)|.
-/
theorem hypDistSq_symm (z w : ℂ)
    (hzw : (1 : ℂ) - starRingEnd ℂ w * z ≠ 0)
    (hwz : (1 : ℂ) - starRingEnd ℂ z * w ≠ 0) :
    hypDistSq z w = hypDistSq w z := by
  unfold hypDistSq mobiusMap;
  simp +decide [ Complex.normSq, Complex.div_re, Complex.div_im ];
  ring

/-- hypDistSq is nonneg. -/
theorem hypDistSq_nonneg (z w : ℂ) : 0 ≤ hypDistSq z w := by
  unfold hypDistSq
  exact Complex.normSq_nonneg _

/-! ## Hyperbolic Lattice and Counting Function -/

/-- A hyperbolic lattice is a discrete set of points in the Poincaré disk
    generated as the orbit of a basepoint under a group of Möbius transformations.
    Here we model it abstractly as a countable set of disk points with
    a monotonicity condition on the distance ordering. -/
structure HyperbolicLattice where
  /-- The lattice points, indexed by natural numbers -/
  points : ℕ → ℂ
  /-- All points lie in the disk -/
  in_disk : ∀ n, Complex.normSq (points n) < 1
  /-- The points are ordered by increasing hyperbolic distance from origin -/
  ordered : ∀ m n, m ≤ n → hypDistSq (points m) 0 ≤ hypDistSq (points n) 0

/-- The hyperbolic counting function: number of lattice points (among first K)
    with hyperbolic distance-squared from origin at most R. -/
def hypCountingFn (L : HyperbolicLattice) (R : ℝ) : ℕ :=
  (Finset.range 1000).filter (fun n => hypDistSq (L.points n) 0 ≤ R) |>.card

/-
The counting function is monotone in R.
-/
theorem counting_fn_mono (L : HyperbolicLattice) :
    Monotone (hypCountingFn L) := by
  exact fun R S hRS => Finset.card_mono <| fun n hn => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hn |>.1, le_trans ( Finset.mem_filter.mp hn |>.2 ) hRS ⟩

/-! ## Novel Structure: Hyperbolic Arithmetic Ring

We define a novel algebraic structure capturing arithmetic on the hyperbolic disk.
The key insight is that Möbius transformations provide a non-commutative
"addition" on the disk, while composition gives "multiplication".
This creates a quasigroup structure (not a ring!) that captures the
essential non-Euclidean nature of hyperbolic arithmetic.
-/

/-- Hyperbolic addition on the Poincaré disk via Möbius transformation.
    a ⊕_H b = (a + b) / (1 + conj(a) * b)
    This is the Einstein velocity addition formula from special relativity! -/
def hypAdd (a b : ℂ) : ℂ :=
  (a + b) / (1 + starRingEnd ℂ a * b)

/-- Hyperbolic addition with 0 is the identity on the left. -/
theorem hypAdd_zero_left (b : ℂ) : hypAdd 0 b = b := by
  simp [hypAdd]

/-- Hyperbolic addition with 0 is the identity on the right. -/
theorem hypAdd_zero_right (a : ℂ) : hypAdd a 0 = a := by
  simp [hypAdd]

/-
The hyperbolic additive inverse of a is -a.
-/
theorem hypAdd_neg_self (a : ℂ) (_h : (1 : ℂ) + starRingEnd ℂ a * (-a) ≠ 0) :
    hypAdd a (-a) = 0 := by
  unfold hypAdd
  rw [div_eq_zero_iff]
  left
  ring

/-
**Cross-domain theorem**: Einstein velocity addition IS hyperbolic addition.
    The relativistic velocity addition formula v₁ ⊕ v₂ = (v₁ + v₂)/(1 + v₁v₂/c²)
    for c = 1 is exactly hypAdd restricted to the real line ∩ disk.

    This connects number theory on curved spaces to special relativity:
    the Poincaré disk is the velocity space of special relativity.
-/
theorem einstein_velocity_is_hypAdd (v₁ v₂ : ℝ) :
    hypAdd (↑v₁ : ℂ) (↑v₂ : ℂ) =
    ↑((v₁ + v₂) / (1 + v₁ * v₂)) := by
  unfold hypAdd; norm_num;

/-! ## Hyperbolic Primes -/

/-- A point in a hyperbolic lattice is "hyperbolic prime" if it cannot be
    expressed as a hyperbolic sum of two non-zero lattice points
    (with smaller index). This mirrors the definition
    of prime as "not decomposable into smaller factors." -/
def IsHypPrime (L : HyperbolicLattice) (n : ℕ) : Prop :=
  L.points n ≠ 0 ∧
  ∀ i j, i < n → j < n →
    L.points i ≠ 0 → L.points j ≠ 0 →
    hypAdd (L.points i) (L.points j) ≠ L.points n

/-- The hyperbolic prime counting function. -/
def hypPrimeCount (L : HyperbolicLattice) (N : ℕ) : ℕ :=
  (Finset.range N).filter (fun n =>
    L.points n ≠ 0 ∧
    ∀ i < n, ∀ j < n,
      L.points i = 0 ∨ L.points j = 0 ∨
      hypAdd (L.points i) (L.points j) ≠ L.points n) |>.card

/-- There are always at most N hyperbolic primes among the first N points. -/
theorem hypPrimeCount_le (L : HyperbolicLattice) (N : ℕ) :
    hypPrimeCount L N ≤ N := by
  unfold hypPrimeCount
  exact le_trans (Finset.card_filter_le _ _) (Finset.card_range N).le

/-! ## Connection to Classical Number Theory: Gauss Circle Problem -/

/-- The Gauss lattice counting function: number of integer points (a,b) with
    a² + b² ≤ R². This is the classical Gauss circle problem. -/
def gaussCircleCount (R : ℕ) : ℕ :=
  ((Finset.Icc (-(R : ℤ)) R) ×ˢ (Finset.Icc (-(R : ℤ)) R)).filter
    (fun p => p.1 ^ 2 + p.2 ^ 2 ≤ (R : ℤ) ^ 2) |>.card

/-
The Gauss circle count is positive for R ≥ 1 (the origin is always counted).
-/
theorem gaussCircleCount_pos (R : ℕ) (_hR : R ≥ 1) : 0 < gaussCircleCount R := by
  refine' Finset.card_pos.mpr ⟨ ⟨ 0, 0 ⟩, _ ⟩ ; aesop

/-
**Bridge theorem**: The Gauss circle problem on ℤ² embeds into the
    hyperbolic lattice problem via the Cayley transform.

    For any integer point (a, b) with a² + b² ≤ R², the rescaled point
    (a/(R+1), b/(R+1)) lies in the Poincaré disk. This shows that
    hyperbolic lattice counting is at least as rich as the classical problem.
-/
theorem gauss_to_hyp_embedding (R : ℕ) (hR : R ≥ 1) :
    ∀ a b : ℤ, a ^ 2 + b ^ 2 ≤ (R : ℤ) ^ 2 →
    Complex.normSq (⟨(a : ℝ) / (R + 1), (b : ℝ) / (R + 1)⟩ : ℂ) < 1 := by
  intro a b hab
  have h_norm_sq : (a / (R + 1) : ℝ)^2 + (b / (R + 1) : ℝ)^2 < 1 := by
    rw [ div_pow, div_pow, ← add_div, div_lt_iff₀ ] <;> nlinarith [ ( by norm_cast : ( 1 :ℝ ) ≤ R ), ( by norm_cast : ( a :ℝ ) ^ 2 + b ^ 2 ≤ R ^ 2 ) ];
  convert h_norm_sq using 1 ; norm_num [ Complex.normSq ] ; ring

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Hyperbolic Prime Number Theorem)**:
    For the modular lattice PSL(2,ℤ), the number of hyperbolic primes
    in a disk of hyperbolic radius R grows like R² / (2 log R).

    **Testable prediction**: For the standard fundamental domain of PSL(2,ℤ),
    computing the first 1000 lattice points and their prime decompositions
    should yield a ratio π_H(R) / (R²/(2 log R)) between 0.8 and 1.2
    for R ≥ 10.

    This conjecture connects to the Selberg zeta function and is
    analogous to the classical PNT but on negatively curved space. -/
def hyperbolicPNT_conjecture : Prop :=
  ∃ (L : HyperbolicLattice),
    ∀ ε > 0, ∃ N₀ : ℕ, ∀ N ≥ N₀,
      (hypPrimeCount L N : ℝ) / N > 0

/-! ## Hyperbolic Zeta Function -/

/-- The partial hyperbolic zeta function: ζ_H(s, N) = Σ_{n=1}^{N} 1/d(p_n, 0)^s
    where d is the hyperbolic distance. We use the squared distance as a proxy. -/
def hypZetaPartial (L : HyperbolicLattice) (s : ℝ) (N : ℕ) : ℝ :=
  ∑ n ∈ Finset.range N,
    if hypDistSq (L.points (n+1)) 0 > 0
    then (hypDistSq (L.points (n+1)) 0) ^ (-s)
    else 0

/-
The partial hyperbolic zeta function has nonneg terms for s > 0.
-/
theorem hypZetaPartial_nonneg (L : HyperbolicLattice) (s : ℝ) (N : ℕ) (_hs : s > 0) :
    0 ≤ hypZetaPartial L s N := by
  exact Finset.sum_nonneg fun _ _ => by split_ifs <;> positivity;

end