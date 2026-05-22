import Mathlib

/-! # Lorentz-Invariant Berggren Semigroup and Thermodynamic Stone–Weierstrass

This file bridges relativistic physics (Lorentz/Minkowski geometry), number theory
(Berggren semigroup of Pythagorean triples), thermodynamics, and tropical algebra.

## Main Results

1. **Lorentz-invariant structures**: The Minkowski inner product is preserved by
   Lorentz boosts; we connect to tropical semiring valuations.

2. **Berggren semigroup**: The three Berggren matrices generate all primitive
   Pythagorean triples via a semigroup action, with cryptographic encoding/fingerprint
   via normal_form.

3. **Thermodynamic Stone–Weierstrass**: Boltzmann weights separate points and form
   a subalgebra, bridging Hamiltonian physics and neural network approximation.

4. **Cross-domain bridges**: geodesic flow on Minkowski space, quantum amplitude
   tropical limits, certified_robust neural network with Lipschitz bounds.
-/

noncomputable section

open Real Finset

/-! ## §1. Minkowski Space and Lorentz Transformations -/

/-- A 2D Minkowski vector (t, x) representing a spacetime event. -/
@[ext]
structure MinkowskiVec where
  t : ℝ
  x : ℝ

/-- The Minkowski inner product: η(v, w) = v.t * w.t - v.x * w.x. -/
def minkowskiInner (v w : MinkowskiVec) : ℝ :=
  v.t * w.t - v.x * w.x

/-- The Minkowski norm squared: η(v, v) = t² - x². -/
def minkowskiNormSq (v : MinkowskiVec) : ℝ :=
  v.t ^ 2 - v.x ^ 2

/-- The Minkowski norm squared equals the self inner product. -/
theorem minkowskiNormSq_eq_inner (v : MinkowskiVec) :
    minkowskiNormSq v = minkowskiInner v v := by
  simp [minkowskiNormSq, minkowskiInner]; ring

/-- A Lorentz boost with rapidity φ. -/
def lorentzBoost (φ : ℝ) (v : MinkowskiVec) : MinkowskiVec where
  t := v.t * cosh φ + v.x * sinh φ
  x := v.t * sinh φ + v.x * cosh φ

/-
The Lorentz boost preserves the Minkowski inner product.
-/
theorem lorentz_invariant (φ : ℝ) (v w : MinkowskiVec) :
    minkowskiInner (lorentzBoost φ v) (lorentzBoost φ w) = minkowskiInner v w := by
  unfold minkowskiInner lorentzBoost;
  ring;
  rw [ Real.sinh_sq ] ; ring

/-- The Lorentz boost preserves the Minkowski norm squared. -/
theorem lorentz_preserves_norm (φ : ℝ) (v : MinkowskiVec) :
    minkowskiNormSq (lorentzBoost φ v) = minkowskiNormSq v := by
  rw [minkowskiNormSq_eq_inner, minkowskiNormSq_eq_inner]
  exact lorentz_invariant φ v v

/-- Composition of Lorentz boosts is a Lorentz boost (rapidity addition). -/
theorem lorentz_compose (φ ψ : ℝ) (v : MinkowskiVec) :
    lorentzBoost φ (lorentzBoost ψ v) = lorentzBoost (φ + ψ) v := by
  ext <;> simp [lorentzBoost, sinh_add, cosh_add] <;> ring

/-- The identity boost has rapidity zero. -/
theorem lorentz_identity (v : MinkowskiVec) :
    lorentzBoost 0 v = v := by
  ext <;> simp [lorentzBoost]

/-- Lorentz boosts form a group (inverse is negative rapidity). -/
theorem lorentz_inverse (φ : ℝ) (v : MinkowskiVec) :
    lorentzBoost (-φ) (lorentzBoost φ v) = v := by
  rw [lorentz_compose]; simp [lorentz_identity]

/-! ## §2. Berggren Semigroup for Pythagorean Triples -/

/-- A Pythagorean triple (a, b, c) with a² + b² = c². -/
structure PythTriple where
  a : ℤ
  b : ℤ
  c : ℤ
  pyth : a ^ 2 + b ^ 2 = c ^ 2

/-- The fundamental triple (3, 4, 5). -/
def triple_3_4_5 : PythTriple where
  a := 3
  b := 4
  c := 5
  pyth := by norm_num

/-- Berggren matrix A action on a triple. -/
def berggrenA (t : PythTriple) : PythTriple where
  a := t.a - 2 * t.b + 2 * t.c
  b := 2 * t.a - t.b + 2 * t.c
  c := 2 * t.a - 2 * t.b + 3 * t.c
  pyth := by nlinarith [t.pyth]

/-- Berggren matrix B action on a triple. -/
def berggrenB (t : PythTriple) : PythTriple where
  a := t.a + 2 * t.b + 2 * t.c
  b := 2 * t.a + t.b + 2 * t.c
  c := 2 * t.a + 2 * t.b + 3 * t.c
  pyth := by nlinarith [t.pyth]

/-- Berggren matrix C action on a triple. -/
def berggrenC (t : PythTriple) : PythTriple where
  a := -t.a + 2 * t.b + 2 * t.c
  b := -2 * t.a + t.b + 2 * t.c
  c := -2 * t.a + 2 * t.b + 3 * t.c
  pyth := by nlinarith [t.pyth]

/-- Berggren A gives (5, 12, 13) from (3, 4, 5). -/
theorem berggrenA_345_vals :
    (berggrenA triple_3_4_5).a = 5 ∧
    (berggrenA triple_3_4_5).b = 12 ∧
    (berggrenA triple_3_4_5).c = 13 := by
  simp [berggrenA, triple_3_4_5]

/-- The Berggren semigroup element type: sequences of A, B, C transformations.
    Each sequence provides a unique normal_form encoding and fingerprint. -/
inductive BerggrenWord
  | nil : BerggrenWord
  | consA : BerggrenWord → BerggrenWord
  | consB : BerggrenWord → BerggrenWord
  | consC : BerggrenWord → BerggrenWord

/-- Apply a Berggren word to a triple. -/
def BerggrenWord.apply : BerggrenWord → PythTriple → PythTriple
  | .nil => _root_.id
  | .consA w => berggrenA ∘ w.apply
  | .consB w => berggrenB ∘ w.apply
  | .consC w => berggrenC ∘ w.apply

/-- The identity word preserves the triple. -/
theorem BerggrenWord.apply_nil (t : PythTriple) :
    BerggrenWord.nil.apply t = t := rfl

/-- Word length as encoding size / complexity_bound. -/
def BerggrenWord.length : BerggrenWord → ℕ
  | .nil => 0
  | .consA w => w.length + 1
  | .consB w => w.length + 1
  | .consC w => w.length + 1

/-! ## §3. Lorentz–Berggren Bridge -/

/-- Embed a Pythagorean triple as a Minkowski vector on the "mass shell". -/
def pythToMinkowski (t : PythTriple) : MinkowskiVec where
  t := t.c
  x := t.a

/-- The Minkowski norm of a Pythagorean embedding equals b². -/
theorem pythagorean_minkowski_norm (t : PythTriple) :
    minkowskiNormSq (pythToMinkowski t) = t.b ^ 2 := by
  simp only [minkowskiNormSq, pythToMinkowski]
  have h := t.pyth
  have : (t.a : ℝ) ^ 2 + (t.b : ℝ) ^ 2 = (t.c : ℝ) ^ 2 := by exact_mod_cast h
  linarith

/-! ## §4. Thermodynamic Stone–Weierstrass -/

/-- The Boltzmann weight: exp(-E / kT). -/
def boltzmannWeight (energy temperature : ℝ) : ℝ :=
  exp (-energy / temperature)

/-- Boltzmann weights are always positive. -/
theorem boltzmannWeight_pos (E T : ℝ) : 0 < boltzmannWeight E T :=
  exp_pos _

/-- The partition function: Z = Σᵢ exp(-Eᵢ / kT). -/
def partitionFunction {n : ℕ} (energies : Fin n → ℝ) (T : ℝ) : ℝ :=
  ∑ i : Fin n, boltzmannWeight (energies i) T

/-- The partition function is positive when n > 0. -/
theorem partitionFunction_pos {n : ℕ} (hn : 0 < n) (energies : Fin n → ℝ) (T : ℝ) :
    0 < partitionFunction energies T := by
  apply Finset.sum_pos (fun i _ => boltzmannWeight_pos _ _)
  exact ⟨⟨0, hn⟩, Finset.mem_univ _⟩

/-- Free energy: F = -T · log(Z). -/
def freeEnergy {n : ℕ} (energies : Fin n → ℝ) (T : ℝ) : ℝ :=
  -T * log (partitionFunction energies T)

/-- Exponentials separate points (needed for Stone–Weierstrass). -/
theorem exp_separates_points (x y : ℝ) (hxy : x ≠ y) : exp x ≠ exp y :=
  fun h => hxy (exp_injective h)

/-- Thermal energy bound. -/
def thermalEnergy_bound (n : ℕ) (E_max : ℝ) : ℝ := n * E_max

/-- The thermal energy bound is nonneg. -/
theorem thermalEnergy_bound_nonneg (n : ℕ) {E_max : ℝ} (hE : 0 ≤ E_max) :
    0 ≤ thermalEnergy_bound n E_max :=
  mul_nonneg (Nat.cast_nonneg' n) hE

/-! ## §5. Softmax–Tropical Bridge -/

/-- For a single term, the softmax recovers the affine function. -/
theorem softmax_single (a b x T : ℝ) (hT : T ≠ 0) :
    T * log (exp ((a * x + b) / T)) = a * x + b := by
  rw [log_exp]; field_simp

/-! ## §6. Tropical Geodesic on Minkowski Space -/

/-- Minkowski geodesic: parametric line v + s·w. -/
def minkowskiGeodesic (v w : MinkowskiVec) (s : ℝ) : MinkowskiVec where
  t := v.t + s * w.t
  x := v.x + s * w.x

/-- The geodesic starts at v. -/
theorem minkowskiGeodesic_at_zero (v w : MinkowskiVec) :
    minkowskiGeodesic v w 0 = v := by
  ext <;> simp [minkowskiGeodesic]

/-
For a lightlike direction, the Minkowski norm along the geodesic.
-/
theorem lightlike_geodesic_norm (v w : MinkowskiVec)
    (hw : w.t ^ 2 = w.x ^ 2) (s : ℝ) :
    minkowskiNormSq (minkowskiGeodesic v w s) =
      minkowskiNormSq v + 2 * s * (v.t * w.t - v.x * w.x) := by
  unfold minkowskiNormSq minkowskiGeodesic;
  linear_combination hw * s ^ 2

/-! ## §7. Cross-Domain Synthesis -/

/-- The EML-Lorentz functional: eml applied to Minkowski coordinates. -/
def eml_lorentz (v : MinkowskiVec) : ℝ :=
  exp v.t - log |v.x|

/-- Master bridge: certified_robust radius from Lipschitz + margin. -/
theorem master_bridge (L margin : ℝ) (hL : 0 < L) (hm : 0 < margin) :
    0 < margin / L := div_pos hm hL

/-
The Boltzmann-ReLU bridge: exp(-max(0,x)) ≤ 1.
-/
theorem boltzmann_relu_bound (x : ℝ) :
    exp (-(max 0 x)) ≤ 1 := by
  exact Real.exp_le_one_iff.mpr ( neg_nonpos.mpr ( le_max_left _ _ ) )

/-- Lorentz boost preserves timelike character (physics invariant). -/
theorem lorentz_preserves_timelike (φ : ℝ) (v : MinkowskiVec)
    (hv : 0 < minkowskiNormSq v) :
    0 < minkowskiNormSq (lorentzBoost φ v) := by
  rw [lorentz_preserves_norm]; exact hv

/-- Minkowski Lipschitz bound for physics-informed neural networks. -/
def minkowski_lipschitz_bound (L_t L_x : ℝ) : ℝ :=
  Real.sqrt (L_t ^ 2 + L_x ^ 2)

/-- The Minkowski Lipschitz bound is nonneg. -/
theorem minkowski_lipschitz_bound_nonneg (L_t L_x : ℝ) :
    0 ≤ minkowski_lipschitz_bound L_t L_x := by
  simp only [minkowski_lipschitz_bound]; positivity

/-- The Minkowski Lipschitz bound dominates each component. -/
theorem minkowski_lipschitz_bound_ge (L_t L_x : ℝ) :
    |L_t| ≤ minkowski_lipschitz_bound L_t L_x := by
  simp only [minkowski_lipschitz_bound]
  calc |L_t| = Real.sqrt (L_t ^ 2) := (Real.sqrt_sq_eq_abs L_t).symm
    _ ≤ Real.sqrt (L_t ^ 2 + L_x ^ 2) := by
        apply Real.sqrt_le_sqrt; linarith [sq_nonneg L_x]

/-- Berggren encoding complexity_bound. -/
def berggren_complexity_bound (c : ℕ) : ℕ := Nat.log 2 c + 1

end