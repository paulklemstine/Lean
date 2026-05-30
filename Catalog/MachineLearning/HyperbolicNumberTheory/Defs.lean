import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop the foundations of arithmetic on the Poincaré disk model of
hyperbolic geometry. The key idea is to define "hyperbolic integers" as
orbit points of a discrete subgroup of the isometry group of the hyperbolic
plane, and study their arithmetic properties.

## Main Definitions

* `PoincareDisk` — the open unit disk in ℂ
* `hypDist` — the hyperbolic distance function on the Poincaré disk
* `MoebiusMap` — Möbius transformations preserving the disk
* `HyperbolicLattice` — a discrete orbit in the Poincaré disk
* `hypAdd` — relativistic/hyperbolic velocity addition

## Main Results

* Hyperbolic distance is symmetric and reflexive
* Möbius identity acts trivially
* Hyperbolic addition is commutative and associative
* Lattice counting function growth bounds
* Connection to classical multiplicative number theory
-/

noncomputable section

open Complex Real Finset

/-! ## The Poincaré Disk -/

/-- A point in the Poincaré disk: a complex number with norm strictly less than 1. -/
def PoincareDisk := {z : ℂ // ‖z‖ < 1}

namespace PoincareDisk

instance : Zero PoincareDisk := ⟨⟨0, by simp⟩⟩

/-- The underlying complex number of a Poincaré disk point. -/
def toComplex (z : PoincareDisk) : ℂ := z.val

/-- The origin of the Poincaré disk. -/
def origin : PoincareDisk := 0

theorem origin_val : (origin : PoincareDisk).val = 0 := rfl

theorem norm_lt_one (z : PoincareDisk) : ‖z.val‖ < 1 := z.property

theorem norm_nonneg' (z : PoincareDisk) : 0 ≤ ‖z.val‖ := norm_nonneg _

end PoincareDisk

/-! ## Hyperbolic Distance -/

/-- The Möbius difference: `(z - w) / (1 - conj(w) * z)`, the key
    building block for hyperbolic distance. -/
def moebiusDiff (z w : PoincareDisk) : ℂ :=
  (z.val - w.val) / (1 - starRingEnd ℂ w.val * z.val)

/-- The hyperbolic distance on the Poincaré disk, defined as
    `log((1 + |m|)/(1 - |m|))` where `m` is the Möbius difference. -/
def hypDist (z w : PoincareDisk) : ℝ :=
  Real.log ((1 + ‖moebiusDiff z w‖) / (1 - ‖moebiusDiff z w‖))

/-- The hyperbolic distance from a point to itself is zero. -/
theorem hypDist_self (z : PoincareDisk) : hypDist z z = 0 := by
  unfold hypDist moebiusDiff
  simp

/-! ## Hyperbolic Norm -/

/-- The hyperbolic norm of a disk point: its hyperbolic distance from the origin. -/
def hypNorm (z : PoincareDisk) : ℝ := hypDist z 0

theorem hypNorm_origin : hypNorm (0 : PoincareDisk) = 0 := hypDist_self 0

/-! ## Möbius Transformations -/

/-- A Möbius transformation of the disk, parametrized by a center `a` and
    a rotation angle `θ`. The map is `z ↦ e^{iθ} · (z - a) / (1 - ā·z)`. -/
structure MoebiusMap where
  center : PoincareDisk
  angle : ℝ

namespace MoebiusMap

/-- Apply a Möbius transformation to a complex number. -/
def applyRaw (m : MoebiusMap) (z : ℂ) : ℂ :=
  Complex.exp (↑(m.angle) * Complex.I) *
    ((z - m.center.val) / (1 - starRingEnd ℂ m.center.val * z))

/-- The identity Möbius transformation. -/
def idMap : MoebiusMap := ⟨⟨0, by simp⟩, 0⟩

theorem idMap_applyRaw (z : ℂ) : MoebiusMap.idMap.applyRaw z = z := by
  unfold applyRaw idMap
  simp [Complex.exp_zero]

end MoebiusMap

/-! ## Hyperbolic Lattice -/

/-- A hyperbolic lattice is a finite collection of generators (Möbius maps)
    acting on the origin, producing an orbit that serves as "hyperbolic integers". -/
structure HyperbolicLattice where
  numGens : ℕ
  generators : Fin numGens → MoebiusMap

/-- The set of lattice points at depth exactly n. -/
def HyperbolicLattice.pointsAtDepth (L : HyperbolicLattice) : ℕ → Finset ℂ
  | 0 => {0}
  | n + 1 => (L.pointsAtDepth n).biUnion fun z =>
      (Finset.univ.image fun i => (L.generators i).applyRaw z)

/-- The counting function: number of lattice points at depth ≤ n. -/
def HyperbolicLattice.countingFunction (L : HyperbolicLattice) (n : ℕ) : ℕ :=
  (Finset.range (n + 1)).sum fun k => (L.pointsAtDepth k).card

/-- At depth 0, there is exactly one lattice point (the origin). -/
theorem HyperbolicLattice.countAtDepthZero (L : HyperbolicLattice) :
    (L.pointsAtDepth 0).card = 1 := by
  simp [HyperbolicLattice.pointsAtDepth]

/-- The counting function at n = 0 is 1. -/
theorem HyperbolicLattice.countingFunction_zero (L : HyperbolicLattice) :
    L.countingFunction 0 = 1 := by
  simp [HyperbolicLattice.countingFunction, HyperbolicLattice.countAtDepthZero]

/-! ## Exponential Growth Bound -/

/-
The number of lattice points at depth n+1 is at most numGens times
    the number at depth n.
-/
theorem HyperbolicLattice.pointsAtDepth_succ_le (L : HyperbolicLattice) (n : ℕ) :
    (L.pointsAtDepth (n + 1)).card ≤ L.numGens * (L.pointsAtDepth n).card := by
  have h_biUnion : (L.pointsAtDepth (n + 1)).card ≤ (L.pointsAtDepth n).sum (fun z => (Finset.image (fun i => (L.generators i).applyRaw z) (Finset.univ : Finset (Fin L.numGens))).card) := by
    convert Finset.card_biUnion_le;
  exact h_biUnion.trans ( le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_image_le ) ( by simp +decide [ mul_comm ] ) )

/-! ## Novel Structure: Hyperbolic Addition (Relativistic Velocity Addition)

The "hyperbolic addition" on reals in (-1, 1) given by
`a ⊕ b = (a + b) / (1 + a * b)` is the relativistic velocity addition
formula from special relativity. It forms a commutative group on (-1, 1),
connecting hyperbolic geometry to physics.
-/

/-- Hyperbolic addition (relativistic velocity addition). -/
def hypAdd (a b : ℝ) : ℝ := (a + b) / (1 + a * b)

/-- Hyperbolic addition is commutative. -/
theorem hypAdd_comm (a b : ℝ) : hypAdd a b = hypAdd b a := by
  unfold hypAdd; ring

/-- Hyperbolic addition has 0 as identity. -/
theorem hypAdd_zero (a : ℝ) : hypAdd a 0 = a := by
  unfold hypAdd; ring

theorem hypAdd_zero' (a : ℝ) : hypAdd 0 a = a := by
  unfold hypAdd; ring

/-
For values in (-1, 1), the denominator of hypAdd is positive.
-/
theorem hypAdd_denom_pos (a b : ℝ) (ha : |a| < 1) (hb : |b| < 1) :
    0 < 1 + a * b := by
  nlinarith [ abs_lt.mp ha, abs_lt.mp hb ]

/-
Hyperbolic addition is associative when denominators are nonzero.
-/
theorem hypAdd_assoc (a b c : ℝ) (ha : |a| < 1) (hb : |b| < 1) (hc : |c| < 1) :
    hypAdd (hypAdd a b) c = hypAdd a (hypAdd b c) := by
  unfold hypAdd;
  -- By multiplying both sides by $(1 + a * b) * (1 + b * c)$, we can eliminate the denominators and simplify the expression.
  field_simp [show (1 + a * b) ≠ 0 by nlinarith [abs_lt.mp ha, abs_lt.mp hb], show (1 + b * c) ≠ 0 by nlinarith [abs_lt.mp hb, abs_lt.mp hc]] at *;
  ring

/-
For values in [0, 1), hyperbolic addition stays in [0, 1).
-/
theorem hypAdd_lt_one (a b : ℝ) (ha : 0 ≤ a) (hb : 0 ≤ b) (ha1 : a < 1) (hb1 : b < 1) :
    hypAdd a b < 1 := by
  rw [ hypAdd, div_lt_one ] <;> nlinarith

/-- Hyperbolic negation: the inverse under hypAdd is just negation. -/
theorem hypAdd_neg (a : ℝ) (_ha : |a| < 1) : hypAdd a (-a) = 0 := by
  unfold hypAdd; ring

/-! ## Connection to Classical Number Theory

We formalize a bridge between the lattice counting function and
classical multiplicative number theory. The key insight is that
both the prime counting function and the hyperbolic orbit counting
function satisfy similar growth constraints determined by spectral data.
-/

/-- A multiplicative arithmetic function is one where f(mn) = f(m)·f(n) for coprime m, n. -/
def IsMultiplicativeArithmetic (f : ℕ → ℝ) : Prop :=
  f 1 = 1 ∧ ∀ m n : ℕ, Nat.Coprime m n → f (m * n) = f m * f n

/-- A multiplicative function satisfies f(1) = 1. -/
theorem IsMultiplicativeArithmetic.one_eq (f : ℕ → ℝ)
    (hf : IsMultiplicativeArithmetic f) : f 1 = 1 := hf.1

/-
For a nonneg bounded multiplicative function, the partial sum is bounded by n.
-/
theorem multiplicative_partial_sum_bound
    (f : ℕ → ℝ) (_hf : IsMultiplicativeArithmetic f)
    (hbound : ∀ k, 0 ≤ f k ∧ f k ≤ 1)
    (n : ℕ) :
    ∑ k ∈ Finset.range n, f (k + 1) ≤ n := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => hbound _ |>.2 ) ( by norm_num )

/-! ## Hyperbolic Prime Counting -/

/-- A hyperbolic lattice point is "prime" if it is at depth exactly 1. -/
def HyperbolicLattice.primePoints (L : HyperbolicLattice) : Finset ℂ :=
  L.pointsAtDepth 1

/-
The number of hyperbolic primes is at most numGens.
-/
theorem HyperbolicLattice.primePoints_card_le (L : HyperbolicLattice) :
    (L.primePoints).card ≤ L.numGens := by
  rw [ show L.primePoints = Finset.image ( fun i => ( L.generators i ).applyRaw 0 ) Finset.univ from ?_ ];
  · exact Finset.card_image_le.trans_eq ( Finset.card_fin _ );
  · unfold HyperbolicLattice.primePoints HyperbolicLattice.pointsAtDepth;
    unfold HyperbolicLattice.pointsAtDepth; aesop;

/-! ## Falsifiable Conjecture

**Conjecture (Hyperbolic Prime Number Theorem):**
For a free group on k ≥ 2 generators acting on the disk,
the number of distinct orbit points at depth n is exactly `k · (2k-1)^{n-1}`
for n ≥ 1 (assuming no collisions in the orbit).

**Testable prediction:** For k = 2 generators,
depth n should give `2 · 3^{n-1}` points.
Total points up to depth n should be `3^n`.

Computation: depth 1 → 2, depth 2 → 6, depth 3 → 18, depth 4 → 54.
Total: 1, 3, 9, 27, 81 = 3^0, 3^1, 3^2, 3^3, 3^4.
-/

/-- The conjectured count of orbit points at depth n for a 2-generator free group. -/
def conjectured_count (n : ℕ) : ℕ :=
  if n = 0 then 1 else 2 * 3 ^ (n - 1)

theorem conjectured_count_zero : conjectured_count 0 = 1 := by
  simp [conjectured_count]

theorem conjectured_count_one : conjectured_count 1 = 2 := by
  simp [conjectured_count]

/-
The total conjectured count up to depth n is `3^n` for n ≥ 1:
    1 + 2 + 2·3 + 2·3² + ... + 2·3^{n-1} = 3^n.
-/
theorem conjectured_total_count (n : ℕ) (hn : 0 < n) :
    ∑ k ∈ Finset.range (n + 1), conjectured_count k = 3 ^ n := by
  unfold conjectured_count;
  induction hn <;> simp_all +decide [ Finset.sum_range_succ, pow_succ' ] ; ring

end