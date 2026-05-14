/-
# Geometric Cryptanalysis: Bounded-Box Collisions and Short Kernel Vectors

This file formalizes the bridge between collision-style attack complexity
and lattice reduction geometry. The core insight is:

  If a finite family of integer vectors in a bounded box maps into too small
  a residue space modulo q, then two distinct vectors collide modulo q,
  and their difference yields a nonzero short lattice vector in the kernel lattice.

This creates a formal dictionary between:
- Birthday paradox style cryptanalysis (birthday_attack_query_bound)
- Lattice-based attack witnesses (factor_produces_lattice_vector')
- Geometry-of-numbers short vector existence
- Tropical determinant bounds as a complexity-to-volume transfer principle

## Application Keywords

lattice cryptanalysis, birthday bound, modular collisions, short integer solution,
SIS, geometry of numbers, finite pigeonhole, additive combinatorics, syndrome decoding,
kernel lattice, attack complexity, tropical determinant, cryptanalytic witness extraction
-/

import Mathlib

open Finset BigOperators

/-! ## The Bounded Integer Box -/

/-- The bounded integer box: all vectors `x : Fin n → ℤ` with `|x i| ≤ B` for all `i`. -/
noncomputable def boxVec (n B : ℕ) : Finset (Fin n → ℤ) :=
  Fintype.piFinset (fun _ => Finset.Icc (-(B : ℤ)) (B : ℤ))

/-- The cardinality of the bounded integer box is `(2B+1)^n`. -/
theorem boxVec_card (n B : ℕ) : (boxVec n B).card = (2 * B + 1) ^ n := by
  unfold boxVec
  rw [Fintype.card_piFinset]
  conv_lhs =>
    arg 2; ext i
    rw [Int.card_Icc]
    rw [show ((↑B : ℤ) + 1 - -(↑B : ℤ)).toNat = 2 * B + 1 from by omega]
  simp [Finset.prod_const]

/-- Membership in the bounded box is equivalent to having all coordinates bounded. -/
theorem mem_boxVec_iff {n B : ℕ} {x : Fin n → ℤ} :
    x ∈ boxVec n B ↔ ∀ i, |x i| ≤ B := by
  unfold boxVec
  simp only [Fintype.mem_piFinset, Finset.mem_Icc]
  constructor
  · intro h i
    have hi := h i
    exact abs_le.mpr ⟨by linarith [hi.1], hi.2⟩
  · intro h i
    have hi := abs_le.mp (h i)
    exact ⟨by linarith [hi.1], hi.2⟩

/-! ## The Modular Linear Hash -/

/-- The modular linear form: maps a vector to `∑ i, a i * x i` modulo `q`. -/
def modLinearForm {n : ℕ} (q : ℕ) (a : Fin n → ℤ) (x : Fin n → ℤ) : ZMod q :=
  ∑ i, (a i : ZMod q) * (x i : ZMod q)

/-- Predicate for membership in the kernel lattice of a linear form modulo `q`. -/
def isKernelVec {n : ℕ} (q : ℕ) (a : Fin n → ℤ) (z : Fin n → ℤ) : Prop :=
  (∑ i, a i * z i : ℤ) ≡ 0 [ZMOD q]

/-! ## The Core Collision Theorem -/

/-
**Bounded-box modular collision theorem.**

If `(2B+1)^n > q`, then there exist distinct vectors `x, y` in the bounded box
`{x : ℤ^n | ∀ i, |x i| ≤ B}` that collide under the modular linear form
`x ↦ ∑ i, a i * x i (mod q)`.

This is the cryptanalytic core: if an attack enumerates more bounded candidates
than the modulus can distinguish, a collision is inevitable.

Connects to:
- `birthday_attack_query_bound`: structured linear-algebraic upgrade of arbitrary collisions
- `factor_produces_lattice_vector'`: generalizes arithmetic collision → lattice vector
-/
theorem bounded_box_mod_collision
    {n q B : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)
    (hsize : q < (2 * B + 1) ^ n) :
    ∃ x y : Fin n → ℤ,
      x ≠ y ∧
      (∀ i, |x i| ≤ (B : ℤ)) ∧
      (∀ i, |y i| ≤ (B : ℤ)) ∧
      modLinearForm q a x = modLinearForm q a y := by
  -- The image of the linear map under modulo q lies in `ZMod q` which has `q` elements.
  have h_image_card : (Finset.image (fun x : Fin n → ℤ => modLinearForm q a x) (boxVec n B)).card ≤ q := by
    convert Finset.card_le_univ ( Finset.image ( fun x : Fin n → ℤ => modLinearForm q a x ) ( boxVec n B ) ) using 1;
    convert rfl;
    convert ZMod.card q;
    cases q <;> [ tauto; infer_instance ];
  -- Since the cardinality of the image is less than the cardinality of the domain, by the pigeonhole principle, there must be at least two distinct elements in the domain that map to the same element in the image.
  obtain ⟨x, y, hxy, h_eq⟩ : ∃ x y : Fin n → ℤ, x ∈ boxVec n B ∧ y ∈ boxVec n B ∧ x ≠ y ∧ modLinearForm q a x = modLinearForm q a y := by
    contrapose! h_image_card;
    rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_image_card x y hx hy hxy ] ; linarith [ boxVec_card n B ];
  exact ⟨ x, y, h_eq.2.1, fun i => mem_boxVec_iff.mp hxy i, fun i => mem_boxVec_iff.mp h_eq.1 i, h_eq.2.2 ⟩

/-
**Bounded-box collision yields short kernel vector.**

From the collision theorem, we extract a nonzero integer vector `z` with:
1. `z ≠ 0`
2. `|z i| ≤ 2B` for all coordinates
3. `∑ i, a i * z i ≡ 0 (mod q)`

This is the attack-complexity → lattice-witness pipeline:
any cryptanalytic attack producing "too many" structured candidates relative
to modulus size forces an explicit short-vector witness in the kernel lattice.

Connects to:
- `tropical_lattice_det_bound`: volume controls when bounded search regions must
  intersect lattice cosets
- `bounded_berggren_orbit_in_lattice`: bounded combinatorial generation + ambient
  discrete structure ⇒ short nonzero vector
- `berggren_lattice_svp_trivial`: short vector existence from structured families
-/
theorem bounded_box_collision_yields_short_kernel_vector
    {n q B : ℕ}
    (hq : 0 < q)
    (a : Fin n → ℤ)
    (hsize : q < (2 * B + 1) ^ n) :
    ∃ z : Fin n → ℤ,
      z ≠ 0 ∧
      (∀ i, |z i| ≤ 2 * (B : ℤ)) ∧
      isKernelVec q a z := by
  -- Use `bounded_box_mod_collision` to get x, y with x ≠ y, |x i| ≤ B, |y i| ≤ B, and modLinearForm q a x = modLinearForm q a y.
  obtain ⟨x, y, hxy, hxB, hyB, hmod⟩ := bounded_box_mod_collision hq a hsize;
  refine' ⟨ x - y, sub_ne_zero.mpr hxy, fun i => _, _ ⟩ <;> simp_all +decide [ modLinearForm, isKernelVec ];
  · exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( hxB i ), abs_le.mp ( hyB i ) ], by linarith [ abs_le.mp ( hxB i ), abs_le.mp ( hyB i ) ] ⟩;
  · simp_all +decide [ mul_sub, ← ZMod.intCast_eq_intCast_iff ]

/-! ## Matrix Generalization: SIS Existence -/

/-
**Bounded-box SIS witness (matrix version).**

For a matrix `A ∈ ℤ^{m×n}`, if the bounded box has more vectors than the
number of possible syndromes `q^m`, then there exists a nonzero bounded
vector in the modular kernel `{z : Az ≡ 0 (mod q)}`.

This is the exact conceptual skeleton behind lattice cryptanalysis of
hash families and SIS-type constructions:
  `(2B+1)^n > q^m ⟹ ∃ z ≠ 0, ‖z‖_∞ ≤ 2B, Az ≡ 0 (mod q)`

Connects to:
- Short Integer Solution (SIS) problem in lattice cryptography
- Syndrome decoding in coding theory
- Security thresholds for lattice-based hash functions
-/
theorem bounded_box_sis_witness
    {m n q B : ℕ}
    (hq : 0 < q)
    (A : Matrix (Fin m) (Fin n) ℤ)
    (hsize : q ^ m < (2 * B + 1) ^ n) :
    ∃ z : Fin n → ℤ,
      z ≠ 0 ∧
      (∀ i, |z i| ≤ 2 * (B : ℤ)) ∧
      (∀ j : Fin m, ((∑ i, A j i * z i : ℤ) ≡ 0 [ZMOD q])) := by
  have h_pigeonhole : ∃ x y : Fin n → ℤ, x ≠ y ∧ (∀ i, |x i| ≤ B) ∧ (∀ i, |y i| ≤ B) ∧ (∀ j, (∑ i, A j i * x i) ≡ (∑ i, A j i * y i) [ZMOD q]) := by
    have h_pigeonhole : Finset.card (Finset.image (fun x : Fin n → ℤ => fun j : Fin m => (∑ i, (A j i : ℤ) * (x i : ℤ)) % q) (boxVec n B)) ≤ q^m := by
      have h_pigeonhole : Finset.card (Finset.image (fun x : Fin n → ℤ => fun j : Fin m => (∑ i, (A j i : ℤ) * (x i : ℤ)) % q) (boxVec n B)) ≤ Finset.card (Finset.Icc (0 : Fin m → ℤ) (fun _ => q - 1)) := by
        refine Finset.card_le_card ?_;
        exact Finset.image_subset_iff.mpr fun x hx => Finset.mem_Icc.mpr ⟨ fun _ => Int.emod_nonneg _ ( by positivity ), fun _ => Int.le_sub_one_of_lt ( Int.emod_lt_of_pos _ ( by positivity ) ) ⟩;
      erw [ Finset.card_map, Finset.card_pi ] at h_pigeonhole ; aesop;
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn ];
    · rw [ boxVec_card ] ; linarith;
    · exact fun x hx y hy hxy => Classical.not_not.1 fun h => by obtain ⟨ j, hj ⟩ := h_pigeonhole x y h ( fun i => by simpa using Finset.mem_Icc.mp ( Fintype.mem_piFinset.mp hx i ) |> fun h => abs_le.mpr ⟨ by linarith, by linarith ⟩ ) ( fun i => by simpa using Finset.mem_Icc.mp ( Fintype.mem_piFinset.mp hy i ) |> fun h => abs_le.mpr ⟨ by linarith, by linarith ⟩ ) ; exact hj <| by simpa using congr_fun hxy j;
  obtain ⟨ x, y, hxy, hx, hy, h ⟩ := h_pigeonhole; use x - y; simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ] ;
  exact ⟨ sub_ne_zero_of_ne hxy, fun i => abs_le.mpr ⟨ by linarith [ abs_le.mp ( hx i ), abs_le.mp ( hy i ) ], by linarith [ abs_le.mp ( hx i ), abs_le.mp ( hy i ) ] ⟩, fun j => by simpa [ mul_sub ] using sub_eq_zero.mpr ( h j ) ⟩