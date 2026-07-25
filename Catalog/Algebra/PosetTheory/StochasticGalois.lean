/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Stochastic Galois Theory: Random Polynomials Have Generic Galois Groups

We formalize foundational counting results about polynomials over finite fields
that underlie the probabilistic study of Galois groups.

## Main definitions

* `SplittingProfile` — A partition-based classification of polynomials by the
  degree pattern of their irreducible factors.
* `evalMonic` — Evaluation of monic polynomial given by coefficient tuple.

## Main results

* `schwartz_zippel_univariate` — A nonzero polynomial of degree d over F_p has ≤ d roots.
* `root_fiber_card` — The fiber of the evaluation map at any point has size q^(n-1).
* `root_pairs_eq_sum_fibers` — A double-counting identity relating roots and polynomials.
* `quadratic_has_root_iff_disc_square` — Quadratic root criterion via discriminant.
* `irreducible_quadratic_density_limit` — Irreducible quadratic density → 1/2 as p → ∞.
-/

import Mathlib

open Polynomial Finset BigOperators

namespace StochasticGalois

/-! ## Part 1: The SplittingProfile -/

/-- A `SplittingProfile` of degree `n` represents the factorization pattern of a
polynomial of degree `n` as a sorted list of degrees of its irreducible factors.
Over F_p, the splitting profile equals the cycle type of the Frobenius. -/
structure SplittingProfile (n : ℕ) where
  /-- The sorted list of degrees of irreducible factors -/
  parts : List ℕ
  /-- Each part is positive -/
  parts_pos : ∀ k ∈ parts, 0 < k
  /-- The parts sum to n -/
  parts_sum : parts.sum = n
  /-- The parts are sorted in non-decreasing order -/
  parts_sorted : parts.Pairwise (· ≤ ·)

/-- The completely split profile [1, 1, ..., 1] -/
def SplittingProfile.completelySplit (n : ℕ) : SplittingProfile n where
  parts := List.replicate n 1
  parts_pos := by intro k hk; simp [List.mem_replicate] at hk; omega
  parts_sum := by simp [List.sum_replicate]
  parts_sorted := by
    rw [List.pairwise_replicate]
    exact Or.inr (le_refl 1)

/-- The irreducible profile [n] for n ≥ 1 -/
def SplittingProfile.irreducible : (n : ℕ) → (hn : 0 < n) → SplittingProfile n
  | n, hn => {
    parts := [n]
    parts_pos := by simp; omega
    parts_sum := by simp
    parts_sorted := by exact List.pairwise_singleton _ _
  }

/-- The number of parts (number of irreducible factors) -/
def SplittingProfile.numFactors {n : ℕ} (sp : SplittingProfile n) : ℕ :=
  sp.parts.length

/-- A profile is generic if it consists of a single part (irreducible polynomial) -/
def SplittingProfile.isGeneric {n : ℕ} (sp : SplittingProfile n) : Prop :=
  sp.parts.length = 1

theorem SplittingProfile.irreducible_isGeneric (n : ℕ) (hn : 0 < n) :
    (SplittingProfile.irreducible n hn).isGeneric := by
  simp [isGeneric, SplittingProfile.irreducible]

theorem SplittingProfile.completelySplit_numFactors (n : ℕ) :
    (SplittingProfile.completelySplit n).numFactors = n := by
  simp [numFactors, completelySplit, List.length_replicate]

/-- The completely split profile is generic only for degree 1 -/
theorem SplittingProfile.completelySplit_generic_iff (n : ℕ) :
    (SplittingProfile.completelySplit n).isGeneric ↔ n = 1 := by
  simp [isGeneric, completelySplit, List.length_replicate]

/-! ## Part 2: Counting Monic Polynomials -/

/-- The number of monic polynomials of degree n over a finite field F
equals |F|^n. -/
theorem card_monic_poly_space (F : Type*) [Fintype F] [DecidableEq F] (n : ℕ) :
    Fintype.card (Fin n → F) = (Fintype.card F) ^ n := by
  rw [Fintype.card_fun, Fintype.card_fin]

/-- Specialization to ZMod p -/
theorem card_monic_poly_zmod (p : ℕ) [Fact (Nat.Prime p)] (n : ℕ) :
    Fintype.card (Fin n → ZMod p) = p ^ n := by
  rw [Fintype.card_fun, ZMod.card, Fintype.card_fin]

/-! ## Part 3: Schwartz-Zippel Bound (Univariate) -/

/-
**Schwartz-Zippel (univariate)**: A nonzero polynomial over ZMod p has at most
`natDegree` roots counted as distinct elements.
-/
theorem schwartz_zippel_univariate (p : ℕ) [Fact (Nat.Prime p)]
    (f : Polynomial (ZMod p)) (hf : f ≠ 0) :
    (Finset.univ.filter (fun x : ZMod p => f.eval x = 0)).card ≤ f.natDegree := by
  have h_roots : (Finset.univ : Finset (ZMod p)).filter (fun x => f.eval x = 0) ⊆ f.roots.toFinset := by
    intro x hx; aesop;
  exact le_trans ( Finset.card_le_card h_roots ) ( le_trans ( Multiset.toFinset_card_le _ ) ( Polynomial.card_roots' _ ) )

/-! ## Part 4: Evaluation Map and Fiber Counting -/

/-- Evaluate a monic polynomial (given by coefficient tuple) at a point.
For c : Fin n → F, this computes r^n + ∑_{i<n} c(i) * r^i. -/
noncomputable def evalMonic {F : Type*} [CommRing F] (n : ℕ) (c : Fin n → F) (r : F) : F :=
  r ^ n + ∑ i : Fin n, c i * r ^ (i : ℕ)

/-- The root fiber at r: coefficient tuples giving a monic polynomial with root r -/
noncomputable def rootFiber {F : Type*} [CommRing F] [DecidableEq F] [Fintype F]
    (n : ℕ) (r : F) : Finset (Fin n → F) :=
  Finset.univ.filter (fun c => evalMonic n c r = 0)

/-
The root fiber at any point has exactly |F|^(n-1) elements for degree-(n+1)
monic polynomials. The constraint eval = 0 determines c₀ from c₁,...,cₙ₋₁.
-/
theorem root_fiber_card {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (n : ℕ) (r : F) :
    (rootFiber (n + 1) r).card = (Fintype.card F) ^ n := by
  unfold rootFiber;
  -- Let's simplify the expression for the evaluation map.
  have h_eval_simplified : ∀ c : Fin (n + 1) → F, evalMonic (n + 1) c r = r ^ (n + 1) + ∑ i : Fin (n + 1), c i * r ^ (i : ℕ) := by
    aesop;
  simp_all +decide [ Fin.sum_univ_succ ];
  -- Let's simplify the expression for the root fiber.
  have h_root_fiber_simplified : Finset.filter (fun c : Fin (n + 1) → F => r ^ (n + 1) + (c 0 + ∑ x : Fin n, c x.succ * r ^ (x.val + 1)) = 0) Finset.univ = Finset.image (fun c : Fin n → F => Fin.cons (-r ^ (n + 1) - ∑ x : Fin n, c x * r ^ (x.val + 1)) c) Finset.univ := by
    ext c; simp [Fin.cons];
    constructor <;> intro h;
    · use fun i => c i.succ; ext i; induction i using Fin.inductionOn <;> simp_all +decide [ Fin.cons ] ; ring;
      grind;
    · aesop;
  rw [ h_root_fiber_simplified, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ]

/-! ## Part 5: Double Counting -/

/-- The set of all (coefficient tuple, root) pairs -/
noncomputable def rootPairs {F : Type*} [CommRing F] [DecidableEq F] [Fintype F] (n : ℕ) :
    Finset ((Fin n → F) × F) :=
  (Finset.univ ×ˢ Finset.univ).filter (fun ⟨c, r⟩ => evalMonic n c r = 0)

/-
Double counting: |rootPairs| = ∑_r |rootFiber r|
-/
theorem root_pairs_eq_sum_fibers {F : Type*} [Field F] [Fintype F] [DecidableEq F] (n : ℕ) :
    (rootPairs n : Finset ((Fin n → F) × F)).card =
    ∑ r : F, (rootFiber n r).card := by
  unfold rootPairs rootFiber;
  simp +decide only [card_filter];
  rw [ Finset.sum_product, Finset.sum_comm ]

/-! ## Part 6: Quadratic Discriminant -/

/-- The discriminant of the monic quadratic X² + bX + c -/
def quadDiscriminant {F : Type*} [CommRing F] (b c : F) : F :=
  b ^ 2 - 4 * c

/-
**Quadratic Formula**: A monic quadratic X² + bX + c over a field (char ≠ 2) has a root
iff the discriminant b²-4c is a perfect square.
-/
theorem quadratic_has_root_iff_disc_square {F : Type*} [Field F]
    (b c : F) (hchar : (2 : F) ≠ 0) :
    (∃ r : F, r ^ 2 + b * r + c = 0) ↔ IsSquare (quadDiscriminant b c) := by
  refine' ⟨ fun ⟨ r, hr ⟩ => ⟨ 2 * r + b, _ ⟩, fun ⟨ d, hd ⟩ => _ ⟩;
  · unfold quadDiscriminant; linear_combination -4 * hr;
  · -- By definition of IsSquare, there exists some $d$ such that $d^2 = b^2 - 4c$.
    use (-b + d) / 2;
    unfold quadDiscriminant at hd; simp_all +decide [ ← sq ] ;
    field_simp
    ring;
    linear_combination -hd

/-! ## Part 7: Irreducible Quadratic Density Limit -/

/-
The fraction (p-1)/(2p) converges to 1/2 as p → ∞, modeling the density of
irreducible monic quadratics over F_p for odd primes p.
-/
theorem irreducible_quadratic_density_limit :
    Filter.Tendsto
      (fun p : ℕ => ((p - 1 : ℚ) / (2 * p)))
      Filter.atTop
      (nhds (1 / 2 : ℚ)) := by
  ring_nf;
  exact le_trans ( Filter.Tendsto.add ( tendsto_const_nhds.congr' ( by filter_upwards [ Filter.eventually_ne_atTop 0 ] with p hp; aesop ) ) ( tendsto_inv_atTop_nhds_zero_nat.mul tendsto_const_nhds ) ) ( by norm_num )

/-! ## Part 8: The Symmetric Group -/

/-
The symmetric group on n elements has order n!
-/
theorem card_perm_fin (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  simp +decide [ Fintype.card_perm ]

/-
For n ≥ 2, the permutation group on Fin n is nontrivial.
-/
theorem perm_nontrivial (n : ℕ) (hn : 2 ≤ n) :
    Nontrivial (Equiv.Perm (Fin n)) := by
  exact ⟨ Equiv.swap ⟨ 0, by linarith ⟩ ⟨ 1, by linarith ⟩, Equiv.refl _, by aesop ⟩

/-! ## Part 9: Splitting Profile Rigidity -/

/-
A splitting profile of degree 0 must have empty parts list.
-/
theorem splitting_profile_zero (sp : SplittingProfile 0) :
    sp.parts = [] := by
  have := sp.parts_sum;
  cases h : sp.parts <;> simp_all +decide;
  exact absurd ( sp.parts_pos _ ( h.symm ▸ List.mem_cons_self ) ) ( by aesop )

/-
A splitting profile of degree 1 must be [1].
-/
theorem splitting_profile_one (sp : SplittingProfile 1) :
    sp.parts = [1] := by
  rcases sp with ⟨ _ | ⟨ k, _ | ⟨ l, _ | sp ⟩ ⟩, _, _, _ ⟩ <;> simp_all +arith +decide;
  · contradiction;
  · aesop;
  · norm_num at * ; linarith;
  · simp_all +arith +decide [ List.sum ];
    omega

/-
For degree n ≥ 2, the completely split profile is NOT generic.
-/
theorem completelySplit_not_generic (n : ℕ) (hn : 2 ≤ n) :
    ¬ (SplittingProfile.completelySplit n).isGeneric := by
  exact fun h => by have := SplittingProfile.completelySplit_generic_iff n; aesop;

/-- The generic profile has exactly 1 factor. -/
theorem generic_profile_one_factor (n : ℕ) (hn : 0 < n) :
    (SplittingProfile.irreducible n hn).numFactors = 1 := by
  simp [SplittingProfile.numFactors, SplittingProfile.irreducible]

/-! ## Part 10: Falsifiable Conjecture

**Conjecture (Irreducible Polynomial Asymptotics)**:
For fixed degree n ≥ 2, the fraction of monic degree-n polynomials over F_p
that are irreducible converges to 1/n as p → ∞.

The exact count is given by the necklace/Möbius formula:
  N(n, q) = (1/n) ∑_{d|n} μ(n/d) q^d

For prime n, this simplifies to (p^n - p)/n.

**Testable predictions** (n = 3):
- p = 5:  (125 - 5)/3 = 40 irreducible cubics out of 125 total (32.0%)
- p = 7:  (343 - 7)/3 = 112 out of 343 (32.65%)
- p = 11: (1331 - 11)/3 = 440 out of 1331 (33.06%)
- p = 13: (2197 - 13)/3 = 728 out of 2197 (33.14%)

These can be verified by direct enumeration over small fields. -/

end StochasticGalois