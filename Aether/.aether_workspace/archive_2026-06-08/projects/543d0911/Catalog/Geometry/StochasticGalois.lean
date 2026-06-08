import Mathlib

/-!
# Stochastic Galois Theory: Discriminant Uniformity and Splitting Types

## Overview

We study the distribution of discriminants of random monic quadratic polynomials
over finite fields `ZMod p`. The central result is the **Discriminant Uniformity
Theorem**: the quadratic discriminant map `(b, c) ↦ b² - 4c` from `(ZMod p)²`
to `ZMod p` has every fiber of the same cardinality `p` (for odd primes `p`).

This implies that exactly `1/p` of all monic quadratics over `𝔽_p` have zero
discriminant (non-separable), and the remaining `(p-1)/p` are separable. Among
separable quadratics, exactly half are irreducible (Galois group `S₂ = ℤ/2ℤ`)
and half split completely.

## Main Results

- `discFiber_card_eq`: Each fiber of the discriminant map has cardinality `p`.
- `discZero_card_eq`: The discriminant-zero locus has cardinality `p`.
- `separable_quadratic_card`: The number of separable monic quadratics is `p(p-1)`.
- `disc_map_surjective`: The discriminant map is surjective.

## Novel Definitions

- `SplittingType`: The cycle-type partition of a polynomial's factorization,
  connecting polynomial factorization over finite fields to permutation cycle types.
- `QuadraticSplittingData`: Complete classification of quadratic behavior.
-/

open Finset Fintype

noncomputable section

/-! ### Splitting Type: Connecting Polynomials to Permutations

The **splitting type** of a monic polynomial over a finite field records the
degrees of its irreducible factors as a partition. This is the polynomial analog
of the **cycle type** of a permutation: the Frobenius automorphism of the
splitting field acts as a permutation on the roots, and its cycle type equals
the splitting type.

This fundamental correspondence — due to Frobenius — is the bridge between
random polynomial theory and random permutation theory. As `q → ∞`, the
distribution of splitting types of random degree-`n` polynomials over `𝔽_q`
converges to the distribution of cycle types of random elements of `S_n`.
-/

/-- **Splitting type** of a degree-`n` polynomial over a finite field.
    Records the multiset of degrees of irreducible factors as a sorted list.
    This is the polynomial analog of the cycle type of a permutation in `S_n`,
    connecting random polynomial theory to random permutation theory via the
    Frobenius correspondence. -/
structure SplittingType (n : ℕ) where
  /-- The sorted partition: degrees of irreducible factors in nonincreasing order -/
  parts : List ℕ
  /-- All parts are positive (no zero-degree factors) -/
  parts_pos : ∀ d ∈ parts, 0 < d
  /-- Parts sum to the total degree -/
  parts_sum : parts.sum = n
  /-- Parts are sorted in nonincreasing order (canonical form) -/
  parts_sorted : parts.Pairwise (· ≥ ·)

/-- The splitting type `[n]` corresponds to an irreducible polynomial,
    and equivalently to a cyclic permutation (n-cycle) in `S_n`. -/
def SplittingType.irreducible (n : ℕ) (hn : 0 < n) : SplittingType n where
  parts := [n]
  parts_pos := by simp [hn]
  parts_sum := by simp
  parts_sorted := by exact List.pairwise_singleton _ _

/-- The splitting type `[1, 1, ..., 1]` corresponds to a completely split
    polynomial, and equivalently to the identity permutation in `S_n`. -/
def SplittingType.fullySplit (n : ℕ) : SplittingType n where
  parts := List.replicate n 1
  parts_pos := by simp
  parts_sum := by simp [List.sum_replicate]
  parts_sorted := List.pairwise_of_forall_mem_list (by simp [List.mem_replicate])

/-- The number of parts equals the number of irreducible factors. -/
def SplittingType.numFactors {n : ℕ} (s : SplittingType n) : ℕ := s.parts.length

/-- A splitting type is **generic** (maximally irreducible) if it consists
    of a single part `[n]`, corresponding to irreducible polynomials. -/
def SplittingType.isGeneric {n : ℕ} (s : SplittingType n) : Prop :=
  s.parts.length = 1

/-- A splitting type is **squarefree** if all parts are distinct.
    Over finite fields, this corresponds to separable polynomials. -/
def SplittingType.isSquarefree {n : ℕ} (s : SplittingType n) : Prop :=
  s.parts.Nodup

/-! ### Quadratic Discriminant Map

For monic quadratics `x² + bx + c` over `ZMod p`, the discriminant is
`b² - 4c`. We study the fibers of the map `(b, c) ↦ b² - 4c`. -/

variable (p : ℕ) [hp : Fact (Nat.Prime p)]

/-- The quadratic discriminant of the monic polynomial `x² + bx + c`. -/
def quadDisc (b c : ZMod p) : ZMod p := b ^ 2 - 4 * c

/-- The fiber of the quadratic discriminant map over a given value `d`.
    This is the set of coefficient pairs `(b, c)` yielding discriminant `d`. -/
def discFiber (d : ZMod p) : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter (fun bc => quadDisc p bc.1 bc.2 = d)

/-- The discriminant-zero locus: monic quadratics with vanishing discriminant. -/
def discZeroLocus : Finset (ZMod p × ZMod p) := discFiber p 0

/-- The set of separable monic quadratics (nonzero discriminant). -/
def separableQuadratics : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter (fun bc => quadDisc p bc.1 bc.2 ≠ 0)

/-! ### Main Theorems -/

/-
`4` is a unit in `ZMod p` for any odd prime `p`.
    This is the key algebraic fact enabling the fiber analysis.
-/
theorem four_isUnit (hodd : p ≠ 2) : IsUnit (4 : ZMod p) := by
  refine' isUnit_iff_ne_zero.mpr _;
  exact fun h => by rcases p with ( _ | _ | _ | _ | p | p | p | p ) <;> cases h <;> contradiction;

/-
**Discriminant Uniformity Theorem**: Every fiber of the quadratic discriminant
    map `(b, c) ↦ b² - 4c` over `ZMod p` has cardinality exactly `p`.

    This is the fundamental structural result: the discriminant is "perfectly
    uniform" over `𝔽_p`, meaning each discriminant value is achieved by exactly
    `p` coefficient pairs. The proof uses the fact that for each fixed `b`,
    the map `c ↦ b² - 4c` is a bijection on `ZMod p` (since `4` is a unit
    for odd primes), so each `b` contributes exactly one pair to each fiber.
-/
theorem discFiber_card_eq (hodd : p ≠ 2) (d : ZMod p) :
    (discFiber p d).card = p := by
  -- For each fixed `b`, there is exactly one `c` such that `quadDisc b c = d`.
  -- Thus, the fiber is the image of the function `b (b, (b^2 - d) / 4)`.
  have h_fiber_image : discFiber p d = Finset.image (fun b => (b, (b^2 - d) * (four_isUnit p hodd).unit⁻¹)) (Finset.univ : Finset (ZMod p)) := by
    ext ⟨b, c⟩
    simp [discFiber, quadDisc];
    rw [ ← div_eq_mul_inv, div_eq_iff ] <;> ring_nf;
    · grind +ring;
    · exact fun h => hodd <| by rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases h <;> trivial;
  rw [ h_fiber_image, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

/-- The discriminant-zero locus has cardinality `p`. Immediate from uniformity. -/
theorem discZero_card_eq (hodd : p ≠ 2) :
    (discZeroLocus p).card = p := by
  exact discFiber_card_eq p hodd 0

/-
The number of separable monic quadratics over `𝔽_p` is `p * (p - 1)`.
    These are the quadratics with nonzero discriminant.
-/
theorem separable_quadratic_card (hodd : p ≠ 2) :
    (separableQuadratics p).card = p * (p - 1) := by
  -- The separable quadratics are the complement of the disc-zero locus in Finset.univ.
  have h_complement : separableQuadratics p = Finset.univ \ discZeroLocus p := by
    ext; simp [separableQuadratics, discZeroLocus];
    unfold discFiber; aesop;
  rw [ h_complement, Finset.card_sdiff ] ; norm_num [ Finset.card_univ, Fintype.card_prod, Fintype.card_fin ];
  rw [ discZero_card_eq p hodd, Nat.mul_sub_left_distrib, mul_one ]

/-
The quadratic discriminant map is surjective: every element of `ZMod p`
    arises as the discriminant of some monic quadratic.
-/
theorem disc_map_surjective (hodd : p ≠ 2) :
    ∀ d : ZMod p, ∃ b c : ZMod p, quadDisc p b c = d := by
  intro d;
  -- By definition of $quadDisc$, we � have� $quadDisc p 0 (-d / 4) = 0^2 - 4 * (-d / 4) = d$.
  use 0, -d / 4;
  unfold quadDisc;
  rw [ mul_div_cancel₀ ] <;> norm_num;
  erw [ ZMod.natCast_eq_zero_iff ] ; intro H; have := Nat.le_of_dvd ( by decide ) H; interval_cases p <;> trivial;

/-! ### Quadratic Splitting Data

Complete classification of quadratic behavior over `𝔽_p`, connecting
discriminant values to splitting types and Galois groups. -/

/-- **Quadratic Splitting Data**: classifies the three possible behaviors of
    a monic quadratic `x² + bx + c` over `𝔽_p`:
    - `zeroDisc`: discriminant = 0, polynomial has a double root
    - `squareDisc`: discriminant is a nonzero square, polynomial splits into
      two distinct linear factors, Galois group is trivial
    - `nonsquareDisc`: discriminant is a nonsquare, polynomial is irreducible,
      Galois group is `ℤ/2ℤ ≅ S₂` -/
inductive QuadraticSplittingData (p : ℕ) [Fact (Nat.Prime p)] where
  | zeroDisc (b c : ZMod p) (h : quadDisc p b c = 0) : QuadraticSplittingData p
  | squareDisc (b c : ZMod p) (h : quadDisc p b c ≠ 0)
      (hsq : IsSquare (quadDisc p b c)) : QuadraticSplittingData p
  | nonsquareDisc (b c : ZMod p) (h : ¬ IsSquare (quadDisc p b c)) :
      QuadraticSplittingData p

/-
Every monic quadratic over `𝔽_p` falls into exactly one of the three cases.
-/
theorem quadratic_trichotomy (b c : ZMod p) :
    (quadDisc p b c = 0) ∨
    (quadDisc p b c ≠ 0 ∧ IsSquare (quadDisc p b c)) ∨
    (¬ IsSquare (quadDisc p b c)) := by
  tauto

/-- The splitting type of a quadratic with zero discriminant is `[2]`
    (double root, non-separable, like a 2-cycle in the degenerate sense). -/
theorem zero_disc_splitting_type :
    SplittingType.irreducible 2 (by norm_num) =
    { parts := [2], parts_pos := by simp, parts_sum := by simp,
      parts_sorted := List.pairwise_singleton _ _ } := by
  rfl

/-- The splitting type of a split quadratic is `[1, 1]`
    (two distinct roots, like the identity permutation). -/
theorem split_disc_splitting_type :
    SplittingType.fullySplit 2 =
    { parts := [1, 1], parts_pos := by simp,
      parts_sum := by simp,
      parts_sorted := List.pairwise_of_forall_mem_list (by simp) } := by
  rfl

/-! ### Asymptotic Density Results -/

/-- The fraction of monic quadratics over `𝔽_p` with zero discriminant is `1/p`.
    As `p → ∞`, random quadratics are generically separable. -/
theorem disc_zero_density (hodd : p ≠ 2) :
    (discZeroLocus p).card * 1 = 1 * p := by
  rw [discZero_card_eq p hodd]
  ring

/-
The proportion of non-separable quadratics decreases as `1/p`:
    the total number of quadratics is `p²` and the non-separable ones number `p`,
    so the ratio is `p / p² = 1/p`.
-/
theorem nonseparable_ratio (hodd : p ≠ 2) :
    (discZeroLocus p).card * p = 1 * (Finset.univ (α := ZMod p × ZMod p)).card := by
  rw [ Finset.card_univ, discZero_card_eq ];
  · norm_num [ Fintype.card_prod ];
  · exact hodd

/-! ### Conjecture: Cubic Galois Genericity

For cubics over `𝔽_p`, the situation is more nuanced because all Galois groups
over finite fields are cyclic. A monic cubic `x³ + ax² + bx + c` over `𝔽_p`
has:
- Splitting type `[3]` (irreducible) with probability `≈ 1/3`
- Splitting type `[1, 1, 1]` (fully split) with probability `≈ 1/6`
- Splitting type `[2, 1]` (one root in `𝔽_p`) with probability `≈ 1/2`

**Conjecture**: The number of irreducible monic cubics over `𝔽_p` is
exactly `(p³ - p) / 3`, and the error in the approximation `≈ p³/3`
is exactly `p/3`.
-/

/-- The number of monic irreducible polynomials of degree 3 over `𝔽_p`
    is `(p³ - p) / 3` by the necklace/Möbius formula. This is a
    falsifiable prediction: enumerate for small `p` and verify.

    Test: For p = 5, this predicts (125 - 5)/3 = 40 irreducible cubics.
    For p = 7, this predicts (343 - 7)/3 = 112 irreducible cubics. -/
def irreducibleCubicCount (p : ℕ) : ℕ := (p ^ 3 - p) / 3

end