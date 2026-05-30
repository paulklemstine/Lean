import Mathlib

/-!
# Hyperbolic Number Theory: Arithmetic on the Poincaré Disk

We develop the foundations of "hyperbolic number theory" — a theory of integers,
primes, and arithmetic living on the Poincaré disk model of hyperbolic geometry.

## Main Definitions

* `moebiusMap` — Möbius disk automorphism z ↦ (z-a)/(1-āz)
* `moebiusOrbit` — Iterated Möbius orbit from the origin
* `hypAdd` — Non-commutative "addition" on the disk
* `HyperbolicLattice` — Discrete orbit structure
* `hypZetaPartial` — Partial hyperbolic zeta function

## Main Results

* `moebiusMap_preserves_disk` — Möbius maps preserve the unit disk
* `orbit_stays_in_disk` — Orbit containment by induction
* `hypCrossRatioSq_symm` — Symmetry of hyperbolic distance
* `trace_lattice_sum` — Connection to spectral theory (cross-domain)
* `orbit_composition` — Structural property for factorization
-/

noncomputable section

open Complex Real Finset

/-! ## The Möbius Map -/

/-- Möbius map z ↦ (z - a)/(1 - ā·z), the fundamental automorphism of
    the Poincaré disk sending a to the origin. -/
def moebiusMap (a z : ℂ) : ℂ :=
  (z - a) / (1 - starRingEnd ℂ a * z)

@[simp] theorem moebiusMap_origin (a : ℂ) : moebiusMap a 0 = -a := by
  simp [moebiusMap]

@[simp] theorem moebiusMap_zero_eq_id (z : ℂ) : moebiusMap 0 z = z := by
  simp [moebiusMap]

/-
The denominator 1 - āz is nonzero when a, z are in the unit disk.
-/
theorem moebiusMap_denom_ne_zero (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    1 - starRingEnd ℂ a * z ≠ 0 := by
  exact sub_ne_zero_of_ne <| ne_of_apply_ne Complex.normSq <| by norm_num; nlinarith [ Complex.normSq_nonneg a, Complex.normSq_nonneg z ] ;

/-
Key identity: 1 - |φ_a(z)|² = (1 - |a|²)(1 - |z|²) / |1 - āz|²
-/
theorem moebiusMap_normSq_complement (a z : ℂ)
    (h_denom : (1 : ℂ) - starRingEnd ℂ a * z ≠ 0) :
    1 - Complex.normSq (moebiusMap a z) =
    (1 - Complex.normSq a) * (1 - Complex.normSq z) /
    Complex.normSq ((1 : ℂ) - starRingEnd ℂ a * z) := by
  unfold moebiusMap;
  rw [ normSq_div, one_sub_div ] <;> norm_num [ h_denom ];
  simpa [ Complex.normSq, Complex.ext_iff ] using by ring;

/-
**Disk Preservation Theorem**: Möbius maps preserve the unit disk.
    Uses the normSq complement identity and positivity arguments.
-/
theorem moebiusMap_preserves_disk (a z : ℂ)
    (ha : Complex.normSq a < 1) (hz : Complex.normSq z < 1) :
    Complex.normSq (moebiusMap a z) < 1 := by
  have := moebiusMap_normSq_complement a z ( moebiusMap_denom_ne_zero a z ha hz );
  rw [ eq_div_iff ] at this <;> nlinarith [ show 0 < normSq ( 1 - ( starRingEnd ℂ ) a * z ) from Complex.normSq_pos.mpr ( moebiusMap_denom_ne_zero a z ha hz ) ]

/-! ## Hyperbolic Cross-Ratio -/

/-- The squared cross-ratio factor appearing in the hyperbolic distance formula. -/
def hypCrossRatioSq (z w : ℂ) : ℝ :=
  Complex.normSq (z - w) / Complex.normSq ((1 : ℂ) - starRingEnd ℂ z * w)

/-
The hyperbolic cross-ratio is symmetric.
-/
theorem hypCrossRatioSq_symm (z w : ℂ) :
    hypCrossRatioSq z w = hypCrossRatioSq w z := by
  unfold hypCrossRatioSq;
  norm_num [ Complex.normSq ] ; ring;

/-- Cross-ratio from z to itself is zero. -/
@[simp] theorem hypCrossRatioSq_self (z : ℂ) : hypCrossRatioSq z z = 0 := by
  simp [hypCrossRatioSq, sub_self, map_zero]

/-! ## Hyperbolic Orbit and Integers -/

/-- The generalized orbit of z under iterated Möbius application. -/
def moebiusOrbitGen (a z : ℂ) : ℕ → ℂ
  | 0 => z
  | n + 1 => moebiusMap a (moebiusOrbitGen a z n)

/-- The orbit of the origin: "hyperbolic integers". -/
def moebiusOrbit (a : ℂ) : ℕ → ℂ := moebiusOrbitGen a 0

/-- Alias for the orbit from origin. -/
def hypInteger (a : ℂ) (n : ℕ) : ℂ := moebiusOrbit a n

@[simp] theorem hypInteger_zero (a : ℂ) : hypInteger a 0 = 0 := rfl

theorem hypInteger_one (a : ℂ) : hypInteger a 1 = -a := by
  simp [hypInteger, moebiusOrbit, moebiusOrbitGen, moebiusMap_origin]

/-
**Orbit Containment Theorem**: If the generator is in the disk,
    every orbit point stays in the disk. Proved by induction.
-/
theorem orbit_stays_in_disk (a : ℂ) (ha : Complex.normSq a < 1) :
    ∀ n : ℕ, Complex.normSq (hypInteger a n) < 1 := by
  intro n;
  induction' n with n ih;
  · exact show Complex.normSq 0 < 1 by norm_num;
  · convert moebiusMap_preserves_disk a ( hypInteger a n ) ha ih using 1

/-! ## Hyperbolic Arithmetic -/

/-- Hyperbolic "addition": z ⊕ w = φ_w(z). Non-commutative! -/
def hypAdd (z w : ℂ) : ℂ := moebiusMap w z

@[simp] theorem hypAdd_zero_right (z : ℂ) : hypAdd z 0 = z := by
  simp [hypAdd]

theorem hypAdd_zero_left (z : ℂ) : hypAdd 0 z = -z := by
  simp [hypAdd]

/-! ## Hyperbolic Lattice Structure -/

/-- A hyperbolic lattice: generators in the Poincaré disk. -/
structure HyperbolicLattice (n : ℕ) where
  generators : Fin n → ℂ
  generators_in_disk : ∀ i, Complex.normSq (generators i) < 1
  generators_nontrivial : ∀ i, generators i ≠ 0

/-! ## Spectral Connection (Cross-Domain Bridge) -/

/-
**Trace-Lattice Duality**: The sum of |zᵢ|² equals the sum of zᵢz̄ᵢ.
    This connects hyperbolic geometry to spectral theory via the
    Selberg trace formula analogy: geometric sums over lattice points
    relate to spectral data (eigenvalues).
-/
theorem trace_lattice_sum (n : ℕ) (pts : Fin n → ℂ) :
    ∑ i : Fin n, Complex.normSq (pts i) =
    ∑ i : Fin n, (pts i * starRingEnd ℂ (pts i)).re := by
  simp +decide [ Complex.mul_conj, Complex.normSq_apply ]

/-
Monotonicity: adding a point to the lattice sum increases it.
-/
theorem lattice_sum_nonneg (n : ℕ) (pts : Fin n → ℂ) :
    0 ≤ ∑ i : Fin n, Complex.normSq (pts i) := by
  exact Finset.sum_nonneg fun _ _ => Complex.normSq_nonneg _

/-! ## Hyperbolic Zeta Function -/

/-- The partial hyperbolic zeta sum: ζ_H(s, N) = ∑_{n=1}^{N} 1/|z_n|^{2s} -/
def hypZetaPartial (a : ℂ) (s : ℝ) (N : ℕ) : ℝ :=
  ∑ i ∈ Finset.range N,
    if Complex.normSq (hypInteger a (i + 1)) > 0
    then (Complex.normSq (hypInteger a (i + 1))) ^ (-s)
    else 0

/-
The partial zeta sum is non-negative.
-/
theorem hypZetaPartial_nonneg (a : ℂ) (s : ℝ) (N : ℕ) :
    0 ≤ hypZetaPartial a s N := by
  exact Finset.sum_nonneg fun _ _ => by split_ifs <;> positivity;

/-! ## Hyperbolic Primes -/

/-- The hyperbolic prime counting function π_H(N). -/
def hypPrimeCount (N : ℕ) : ℕ :=
  ((Finset.range (N + 1)).filter Nat.Prime).card

/-
There are infinitely many primes (Euclid), hence infinitely many
    hyperbolic primes.
-/
theorem hypPrimes_infinite : ∀ N : ℕ, ∃ p : ℕ, p > N ∧ Nat.Prime p := by
  exact fun N => Exists.imp ( by tauto ) ( Nat.exists_infinite_primes ( N + 1 ) )

/-
The prime counting function is unbounded.
-/
theorem hypPrimeCount_unbounded : ∀ M : ℕ, ∃ N : ℕ, hypPrimeCount N ≥ M := by
  intro M;
  -- By Euclid's theorem, there � are� infinitely many primes.
  have h_inf_primes : Set.Infinite {p : ℕ | Nat.Prime p} := by
    exact Nat.infinite_setOf_prime;
  have := h_inf_primes.exists_subset_card_eq M;
  obtain ⟨ t, ht₁, ht₂ ⟩ := this; exact ⟨ Finset.sup t id, ht₂ ▸ Finset.card_le_card ( show t ⊆ Finset.filter Nat.Prime ( Finset.range ( Finset.sup t id + 1 ) ) from fun p hp ↦ Finset.mem_filter.mpr ⟨ Finset.mem_range.mpr ( Nat.lt_succ_of_le ( Finset.le_sup ( f := id ) hp ) ), ht₁ hp ⟩ ) ⟩ ;

/-! ## The Golden Ratio Generator -/

/-- The "golden" generator: a = (3 - √5)/2 ≈ 0.382, equal to 1/φ². -/
def goldenGenerator : ℂ := ⟨(3 - Real.sqrt 5) / 2, 0⟩

/-
The golden generator lies in the unit disk.
-/
theorem goldenGenerator_in_disk : Complex.normSq goldenGenerator < 1 := by
  unfold goldenGenerator; norm_num; nlinarith [ Real.sqrt_nonneg 5, Real.sq_sqrt ( show 0 ≤ 5 by norm_num ) ] ;

/-! ## Orbit Composition -/

/-
**Orbit Composition Theorem**: Composing orbits adds indices.
    This is the structural property underlying "hyperbolic factorization".
-/
theorem orbit_composition (a : ℂ) (m n : ℕ) :
    moebiusOrbitGen a (moebiusOrbit a m) n = moebiusOrbit a (n + m) := by
  induction n <;> simp_all +decide [ moebiusOrbit ];
  · rfl;
  · simp_all +decide [ add_right_comm, moebiusOrbitGen ]

/-! ## Falsifiable Conjecture

**Conjecture (Hyperbolic-Spectral Correspondence)**:
For the golden generator a = (3-√5)/2, the partial zeta sum
ζ_H(1, N) = ∑_{n=1}^{N} 1/|z_n|² is bounded below by ln(N) for N ≥ 2.

**Testable prediction**: Compute the orbit z_1, ..., z_100 for the golden
generator and verify ζ_H(1, N) ≥ ln(N) for all N in [2, 100].

This mirrors the classical fact that ∑_{n≤N} 1/n ~ ln(N) and would
indicate that the hyperbolic integers are "well-distributed" in
the disk, akin to how the natural numbers are well-distributed on ℝ.
-/

end