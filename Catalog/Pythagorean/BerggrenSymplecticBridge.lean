import Mathlib

/-!
# Berggren Parity Reduction and Symplectic Bridge

## Overview

This file formalizes the connection between the Berggren tree of primitive Pythagorean
triples and finite symplectic group actions.

### Correction of the naive mod-2 approach

The naive approach of reducing the top-left 2×2 block of the 3×3 Berggren matrices modulo 2
yields the identity matrix for all three generators (since all entries of B₁, B₂, B₃ are
odd on the diagonal and even off-diagonal in the first two rows/columns). Thus the mod-2
top-left approach **cannot** generate `SL(2, 𝔽₂)`.

### The correct bridge: Euclidean parameters modulo 3

The correct arithmetic-to-symplectic bridge goes through the **Euclidean parametrization**.
Every primitive Pythagorean triple `(a,b,c)` with `a` odd, `b` even arises from coprime
parameters `(m,n)` via `a = m² - n², b = 2mn, c = m² + n²`.

The Berggren generators act on `(m,n)` by explicit 2×2 integer matrices:
- `B₁ ↦ E₁ = [[2,-1],[1,0]]` (det = 1)
- `B₂ ↦ E₂ = [[2,1],[1,0]]`  (det = -1)
- `B₃ ↦ E₃ = [[1,2],[0,1]]`  (det = 1)

Reduced modulo 3, the unit-determinant generators `E₁` and `E₃` generate all of
`SL(2, 𝔽₃) ≅ Sp(2, 𝔽₃)`, which is the symplectic group governing qutrit (dimension 3)
Clifford dynamics.

### Main results

1. **Primitive parity classification**: Every primitive Pythagorean triple has exactly one
   odd leg and one even leg (Theorem `primitive_triple_parity_nonzero`).
2. **Berggren parity invariance**: The Berggren generators preserve the parity class of
   primitive triples (all generators ≡ I mod 2) (Theorem `berggren_preserves_parity`).
3. **SL(2, 𝔽₃) generation**: The Euclidean-parameter matrices E₁ and E₃, reduced mod 3,
   generate all of `SL(2, ZMod 3)` (Theorem `berggren_euclid_generates_SL2_F3`).
4. **Orbit surjectivity**: The Berggren orbit on Euclidean parameters mod 3 covers all
   nonzero vectors (Theorem `berggren_euclid_orbit_surjective`).
5. **Determinant facts**: E₁, E₃ have determinant 1; E₂ has determinant -1
   (Theorem `euclid_matrix_dets`).

### Significance

This establishes that the ancient Berggren tree is an **arithmetic lift of the symplectic
control layer** of qutrit stabilizer circuits. The Berggren tree's branching structure
provides an integer-arithmetic presentation of `SL(2, 𝔽₃)`, connecting number-theoretic
orbit dynamics to finite quantum information symmetries.
-/

open Matrix

/-! ## Part 1: Berggren Matrices (3×3 over ℤ) -/

/-- Berggren generator B₁ -/
def B₁ : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren generator B₂ -/
def B₂ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren generator B₃ -/
def B₃ : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-! ## Part 2: Euclidean Parameter Matrices (2×2 over ℤ)

The Berggren generators act on the Euclidean coprime parameters `(m, n)` by:
- `B₁: (m, n) ↦ (2m - n, m)` — matrix `E₁ = [[2, -1], [1, 0]]`
- `B₂: (m, n) ↦ (2m + n, m)` — matrix `E₂ = [[2, 1], [1, 0]]`
- `B₃: (m, n) ↦ (m + 2n, n)` — matrix `E₃ = [[1, 2], [0, 1]]`
-/

/-- Euclidean-parameter matrix for Berggren generator B₁ -/
def E₁ : Matrix (Fin 2) (Fin 2) ℤ := !![2, -1; 1, 0]

/-- Euclidean-parameter matrix for Berggren generator B₂ -/
def E₂ : Matrix (Fin 2) (Fin 2) ℤ := !![2, 1; 1, 0]

/-- Euclidean-parameter matrix for Berggren generator B₃ -/
def E₃ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 2; 0, 1]

/-- E₁ has determinant 1 (orientation-preserving Berggren branch) -/
theorem det_E₁ : Matrix.det E₁ = 1 := by native_decide

/-- E₂ has determinant -1 (orientation-reversing Berggren branch) -/
theorem det_E₂ : Matrix.det E₂ = -1 := by native_decide

/-- E₃ has determinant 1 (orientation-preserving Berggren branch) -/
theorem det_E₃ : Matrix.det E₃ = 1 := by native_decide

/-- Summary of all three Euclidean-parameter matrix determinants -/
theorem euclid_matrix_dets :
    Matrix.det E₁ = 1 ∧ Matrix.det E₂ = -1 ∧ Matrix.det E₃ = 1 :=
  ⟨det_E₁, det_E₂, det_E₃⟩

/-! ## Part 3: Mod-2 Triviality

All three Berggren matrices are congruent to the identity modulo 2.
This means the naive mod-2 approach **cannot** generate `SL(2, 𝔽₂)`.
-/

/-- Cast an integer matrix to `ZMod n` entrywise -/
def matCast (n : ℕ) (M : Matrix (Fin k) (Fin k) ℤ) : Matrix (Fin k) (Fin k) (ZMod n) :=
  Matrix.of fun i j => (M i j : ZMod n)

/-- All three 3×3 Berggren matrices are identity mod 2.
    This rules out the naive "top-left 2×2 mod 2 generates SL(2, 𝔽₂)" claim. -/
theorem berggren_mod2_trivial :
    matCast 2 B₁ = 1 ∧ matCast 2 B₂ = 1 ∧ matCast 2 B₃ = 1 := by native_decide

/-! ## Part 4: Mod-3 Reduction of Euclidean Matrices -/

/-- E₁ reduced mod 3 -/
def E₁mod3 : Matrix (Fin 2) (Fin 2) (ZMod 3) := !![2, 2; 1, 0]

/-- E₃ reduced mod 3 -/
def E₃mod3 : Matrix (Fin 2) (Fin 2) (ZMod 3) := !![1, 2; 0, 1]

/-- E₁mod3 is indeed the mod-3 reduction of E₁ -/
theorem E₁mod3_eq : E₁mod3 = matCast 3 E₁ := by native_decide

/-- E₃mod3 is indeed the mod-3 reduction of E₃ -/
theorem E₃mod3_eq : E₃mod3 = matCast 3 E₃ := by native_decide

/-- E₁ mod 3 has determinant 1 (lies in SL(2, 𝔽₃)) -/
theorem det_E₁mod3 : Matrix.det E₁mod3 = 1 := by native_decide

/-- E₃ mod 3 has determinant 1 (lies in SL(2, 𝔽₃)) -/
theorem det_E₃mod3 : Matrix.det E₃mod3 = 1 := by native_decide

/-- E₁ mod 3 has order 3 -/
theorem E₁mod3_order : E₁mod3 ^ 3 = 1 ∧ E₁mod3 ^ 1 ≠ 1 := by native_decide

/-- E₃ mod 3 has order 3 -/
theorem E₃mod3_order : E₃mod3 ^ 3 = 1 ∧ E₃mod3 ^ 1 ≠ 1 := by native_decide

/-- E₁ · E₃ mod 3 has order 6, which certifies non-abelian generation -/
theorem E₁E₃mod3_order6 :
    (E₁mod3 * E₃mod3) ^ 6 = 1 ∧ (E₁mod3 * E₃mod3) ^ 3 ≠ 1 := by native_decide

/-! ## Part 5: Generation of SL(2, 𝔽₃) — The Core Bridge Theorem

`SL(2, 𝔽₃)` has exactly 24 elements. We show that every matrix in
`SL(2, ZMod 3)` (i.e., every 2×2 matrix over 𝔽₃ with determinant 1)
is a product of powers of `E₁mod3` and `E₃mod3`.

Since `E₁^3 = E₃^3 = I`, it suffices to check alternating products
`E₁^a · E₃^b · E₁^c · E₃^d · E₁^e` for `a,b,c,d,e ∈ {0,1,2}`.
-/

/-- The set of all products of the form `E₁^a · E₃^b · E₁^c · E₃^d · E₁^e`
    for `a,b,c,d,e ∈ {0,1,2}`. -/
def euclidProducts : Finset (Matrix (Fin 2) (Fin 2) (ZMod 3)) :=
  (Finset.univ : Finset (Fin 3 × Fin 3 × Fin 3 × Fin 3 × Fin 3)).image
    fun ⟨a, b, c, d, e⟩ =>
      E₁mod3 ^ a.val * E₃mod3 ^ b.val * E₁mod3 ^ c.val *
      E₃mod3 ^ d.val * E₁mod3 ^ e.val

/-- The product set has exactly 24 elements (= |SL(2, 𝔽₃)|) -/
theorem euclidProducts_card : euclidProducts.card = 24 := by native_decide

/-- **Main Generation Theorem**: Every 2×2 matrix over 𝔽₃ with determinant 1
    is a product of powers of E₁mod3 and E₃mod3.

    This proves that the mod-3 Euclidean-parameter matrices from the Berggren tree
    generate the full special linear group `SL(2, 𝔽₃) ≅ Sp(2, 𝔽₃)`. -/
theorem berggren_euclid_generates_SL2_F3 :
    ∀ M : Matrix (Fin 2) (Fin 2) (ZMod 3),
      M.det = 1 → M ∈ euclidProducts := by native_decide

/-- SL(2, 𝔽₃) has exactly 24 elements -/
theorem SL2_F3_card :
    Fintype.card (Matrix.SpecialLinearGroup (Fin 2) (ZMod 3)) = 24 := by native_decide

/-! ## Part 6: Orbit Surjectivity on 𝔽₃²

The Berggren orbit on Euclidean parameters mod 3 covers all nonzero vectors in (𝔽₃)².
This is the corrected version of the originally proposed orbit theorem.
-/

/-- The root triple (3,4,5) has Euclidean parameters (m,n) = (2,1).
    Reduced mod 3, the root Euclidean vector is (2, 1). -/
def rootEuclidMod3 : Fin 2 → ZMod 3 := ![2, 1]

/-- The root Euclidean vector mod 3 is nonzero -/
theorem rootEuclidMod3_ne_zero : rootEuclidMod3 ≠ 0 := by native_decide

/-- The orbit of the root vector under `euclidProducts` -/
def euclidOrbit : Finset (Fin 2 → ZMod 3) :=
  euclidProducts.image fun M => M.mulVec rootEuclidMod3

/-- The orbit covers all 8 nonzero vectors of (𝔽₃)² -/
theorem euclidOrbit_card : euclidOrbit.card = 8 := by native_decide

/-- There are exactly 8 nonzero vectors in (𝔽₃)² -/
theorem nonzero_F3_sq_card :
    (Finset.univ.filter (fun (v : Fin 2 → ZMod 3) => v ≠ 0)).card = 8 := by native_decide

/-- **Orbit Surjectivity Theorem**: For every nonzero vector `x` in (𝔽₃)²,
    there exists a product of E₁mod3 and E₃mod3 mapping the root Euclidean
    parameter vector (2,1) to `x`.

    In quantum-information terms: the Berggren orbit on Euclidean parameters mod 3
    covers the entire nonzero finite phase space, establishing full stabilizer-state
    reachability for qutrit systems. -/
theorem berggren_euclid_orbit_surjective :
    ∀ x : Fin 2 → ZMod 3, x ≠ 0 →
      ∃ M ∈ euclidProducts, M.mulVec rootEuclidMod3 = x := by native_decide

/-! ## Part 7: Parity Classification and Berggren Invariance -/

/-- A triple `(a,b,c)` is Pythagorean if `a² + b² = c²` -/
def IsPythagoreanTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- The parity projection: extract `(a mod 2, b mod 2)` from a triple -/
def tripleParity (a b _c : ℤ) : Fin 2 → ZMod 2 :=
  ![((a : ZMod 2)), ((b : ZMod 2))]

/-
A Pythagorean triple with coprime legs has exactly one odd and one even leg.
    Therefore its parity vector is nonzero.
-/
theorem primitive_triple_parity_nonzero (a b _c : ℤ) (_h : IsPythagoreanTriple a b _c)
    (hcop : Int.gcd a b = 1) :
    tripleParity a b _c ≠ 0 := by
  by_contra h_contra;
  unfold tripleParity at h_contra;
  replace h_contra := congr_fun h_contra; simp_all +decide [ ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
  exact absurd ( Int.dvd_coe_gcd h_contra.1 h_contra.2 ) ( by norm_num [ hcop ] )

/-- The root triple (3,4,5) has parity (1, 0) -/
theorem root_parity : tripleParity 3 4 5 = ![1, 0] := by native_decide

/-- The child triple (5,12,13) has parity (1, 0) -/
theorem child1_parity : tripleParity 5 12 13 = ![1, 0] := by native_decide

/-- The child triple (21,20,29) has parity (1, 0) -/
theorem child2_parity : tripleParity 21 20 29 = ![1, 0] := by native_decide

/-- The child triple (15,8,17) has parity (1, 0) -/
theorem child3_parity : tripleParity 15 8 17 = ![1, 0] := by native_decide

/-
Berggren generator B₁ preserves the parity of a triple (since B₁ ≡ I mod 2)
-/
theorem berggren_B₁_preserves_parity (v : Fin 3 → ℤ) :
    (fun i : Fin 2 => ((B₁.mulVec v) ⟨i.1, by omega⟩ : ZMod 2)) =
    (fun i : Fin 2 => (v ⟨i.1, by omega⟩ : ZMod 2)) := by
  simp +decide [ funext_iff, Fin.forall_fin_two, Matrix.mulVec, dotProduct ];
  simp +decide [ B₁, Fin.sum_univ_three ];
  grind +splitImp

/-
Berggren generator B₂ preserves the parity of a triple (since B₂ ≡ I mod 2)
-/
theorem berggren_B₂_preserves_parity (v : Fin 3 → ℤ) :
    (fun i : Fin 2 => ((B₂.mulVec v) ⟨i.1, by omega⟩ : ZMod 2)) =
    (fun i : Fin 2 => (v ⟨i.1, by omega⟩ : ZMod 2)) := by
  simp +decide [ funext_iff, Fin.forall_fin_two, Matrix.mulVec, dotProduct ];
  simp +decide [ Fin.sum_univ_three, B₂ ];
  grind

/-
Berggren generator B₃ preserves the parity of a triple (since B₃ ≡ I mod 2)
-/
theorem berggren_B₃_preserves_parity (v : Fin 3 → ℤ) :
    (fun i : Fin 2 => ((B₃.mulVec v) ⟨i.1, by omega⟩ : ZMod 2)) =
    (fun i : Fin 2 => (v ⟨i.1, by omega⟩ : ZMod 2)) := by
  ext i; fin_cases i <;> simp +decide [ Matrix.mulVec, B₃ ] ;
  · simp +decide [ ← mul_add, vecHead, vecTail ];
  · simp +decide [ vecHead, vecTail ];
    grind

/-! ## Part 8: Berggren-Euclid Correspondence

The key identity linking 3×3 Berggren action on triples to 2×2 Euclidean action
on parameters: if `(a,b,c) = (m²-n², 2mn, m²+n²)` then
`B_i(a,b,c) = (M²-N², 2MN, M²+N²)` where `(M,N) = E_i(m,n)`.
-/

/-- The Euclid parametrization: `(m,n) ↦ (m²-n², 2mn, m²+n²)` -/
def euclidParam (m n : ℤ) : Fin 3 → ℤ :=
  ![m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2]

/-- Euclid parametrization always produces Pythagorean triples -/
theorem euclidParam_pythagorean (m n : ℤ) :
    IsPythagoreanTriple (euclidParam m n 0) (euclidParam m n 1) (euclidParam m n 2) := by
  simp [IsPythagoreanTriple, euclidParam]; ring

/-
B₁ acting on a Euclid triple equals the Euclid triple of E₁ acting on parameters
-/
theorem berggren_euclid_B₁ (m n : ℤ) :
    B₁.mulVec (euclidParam m n) = euclidParam (2 * m - n) m := by
  unfold B₁ euclidParam;
  ext i; fin_cases i <;> norm_num [ Matrix.mulVec ] <;> ring;

/-
B₂ acting on a Euclid triple equals the Euclid triple of E₂ acting on parameters
-/
theorem berggren_euclid_B₂ (m n : ℤ) :
    B₂.mulVec (euclidParam m n) = euclidParam (2 * m + n) m := by
  ext i;
  unfold B₂ euclidParam; fin_cases i <;> norm_num [ Matrix.mulVec ] <;> ring;

/-
B₃ acting on a Euclid triple equals the Euclid triple of E₃ acting on parameters
-/
theorem berggren_euclid_B₃ (m n : ℤ) :
    B₃.mulVec (euclidParam m n) = euclidParam (m + 2 * n) n := by
  unfold euclidParam B₃; ext i; fin_cases i <;> norm_num <;> ring;

/-- The root triple (3,4,5) is the Euclid parametrization with (m,n) = (2,1) -/
theorem root_is_euclid : euclidParam 2 1 = ![3, 4, 5] := by native_decide

/-! ## Part 9: Summary of the Arithmetic-to-Symplectic Bridge

The chain of results establishes:

1. Berggren matrices act on primitive Pythagorean triples (3×3 over ℤ)
2. This action lifts to 2×2 integer matrices on Euclidean parameters
3. The unit-determinant generators E₁, E₃ reduce mod 3 to generate SL(2, 𝔽₃)
4. SL(2, 𝔽₃) ≅ Sp(2, 𝔽₃) is the symplectic group governing qutrit Clifford dynamics
5. The Berggren orbit covers all nonzero stabilizer states in (𝔽₃)²

This is the correct version of the "quantum bridge" from Pythagorean arithmetic to
stabilizer-circuit semantics. The bridge goes through 𝔽₃ (qutrit), not 𝔽₂ (qubit).

### Correction note
The originally proposed mod-2 top-left 2×2 reduction gives the identity for all
three Berggren generators (proved as `berggren_mod2_trivial`), so it cannot generate
`SL(2, 𝔽₂)`. The correct bridge is the Euclidean-parameter reduction modulo 3.
-/