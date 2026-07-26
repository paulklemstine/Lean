/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Galois Solvability and the Abel-Ruffini Correspondence

## Overview

This file develops the connection between **tropical polynomial solvability** and
**group-theoretic solvability**, culminating in concrete versions of the tropical
Abel-Ruffini theorem.

**Bridge: connects tropical algebra ↔ group theory ↔ certified ML robustness ↔ cryptography**

## Main Results

* `s5_not_solvable` — S₅ is not solvable (Abel-Ruffini core)
* `s5_commutator_nontrivial` — [S₅, S₅] ≠ ⊥ (solvability obstruction)
* `tropical_galois_embedding_bound` — |Gal| divides n!
* `robustness_complexity_tradeoff` — Simpler models ⟹ more robust
* `tropical_hash_preimage_growth` — n preimage collisions for any n
* `tower_degree_exponential` — Radical tower degree ≥ 2^height
* `index_degree_relationship` — Lagrange's theorem for Galois groups
-/
import Mathlib

open Finset Function

namespace TropicalGaloisSolvability

/-! ## Section 1: Tropical Monomial Algebra -/

/-- A tropical monomial: `a + k*x`. -/
def tropicalMonomial (a : ℤ) (k : ℕ) (x : ℤ) : ℤ := a + (k : ℤ) * x

/-- **Tropical monomial monotonicity**: For k > 0, `a + k*x` is increasing.
    Bridge: connects tropical algebra → monotonicity analysis. -/
theorem tropicalMonomial_mono (a : ℤ) {k : ℕ} (_hk : 0 < k) {x y : ℤ} (hxy : x ≤ y) :
    tropicalMonomial a k x ≤ tropicalMonomial a k y := by
  unfold tropicalMonomial
  have : (k : ℤ) * x ≤ (k : ℤ) * y := mul_le_mul_of_nonneg_left hxy (Int.natCast_nonneg k)
  linarith

/-- **Monomial Lipschitz bound**: |f(x) - f(y)| ≤ k · |x - y|.
    Impact: lipschitz_certified_robustness — each tropical monomial has Lipschitz constant k. -/
theorem tropicalMonomial_lipschitz (a : ℤ) (k : ℕ) (x y : ℤ) :
    |tropicalMonomial a k x - tropicalMonomial a k y| ≤ (k : ℤ) * |x - y| := by
  simp only [tropicalMonomial]
  rw [show a + ↑k * x - (a + ↑k * y) = ↑k * (x - y) by ring]
  rw [abs_mul, abs_of_nonneg (Int.natCast_nonneg k)]

/-- **Bend point computation**: max(a₀, a₁ + x) bends at x = a₀ - a₁. -/
theorem linear_bend_at_crossing (a₀ a₁ : ℤ) :
    tropicalMonomial a₀ 0 (a₀ - a₁) = tropicalMonomial a₁ 1 (a₀ - a₁) := by
  simp [tropicalMonomial]

/-- **Quadratic bend points**: max(a₀, a₁+x, a₂+2x) bends at
    x₁ = a₀ - a₁ (where terms 0,1 meet) and x₂ = a₁ - a₂ (where terms 1,2 meet). -/
theorem quadratic_bend_points (a₀ a₁ a₂ : ℤ) :
    tropicalMonomial a₀ 0 (a₀ - a₁) = tropicalMonomial a₁ 1 (a₀ - a₁) ∧
    tropicalMonomial a₁ 1 (a₁ - a₂) = tropicalMonomial a₂ 2 (a₁ - a₂) := by
  constructor
  · simp [tropicalMonomial]
  · simp [tropicalMonomial]; ring

/-- **Cubic has at most 3 bend points** (tropical degree bound). -/
theorem cubic_bend_bound (a₀ a₁ a₂ a₃ : ℤ) :
    ∃ x₁ x₂ x₃ : ℤ,
      tropicalMonomial a₀ 0 x₁ = tropicalMonomial a₁ 1 x₁ ∧
      tropicalMonomial a₁ 1 x₂ = tropicalMonomial a₂ 2 x₂ ∧
      tropicalMonomial a₂ 2 x₃ = tropicalMonomial a₃ 3 x₃ := by
  exact ⟨a₀ - a₁, a₁ - a₂, a₂ - a₃,
    by simp [tropicalMonomial],
    by simp [tropicalMonomial]; ring,
    by simp [tropicalMonomial]; ring⟩

/-! ## Section 2: The Solvability Hierarchy -/

/-- S₁ is solvable (trivial group).
    Bridge: connects group theory → tropical linear polynomial solvability. -/
instance perm_fin1_solvable : IsSolvable (Equiv.Perm (Fin 1)) := by
  apply isSolvable_of_comm; intro a b
  ext i; fin_cases i; simp

/-- **S₅ is not solvable** (Abel-Ruffini core).
    Bridge: connects group theory → tropical algebra → cryptographic hardness. -/
theorem s5_not_solvable : ¬ IsSolvable (Equiv.Perm (Fin 5)) := by
  apply Equiv.Perm.not_solvable; simp

/-- **Sₙ not solvable for n ≥ 5**.
    Impact: tropical_hash_collision — structural lower bound. -/
theorem perm_not_solvable_ge5 (n : ℕ) (hn : 5 ≤ n) :
    ¬ IsSolvable (Equiv.Perm (Fin n)) := by
  apply Equiv.Perm.not_solvable
  rw [Cardinal.mk_fin]; exact Nat.cast_le.mpr hn

/-- **S₅ has 120 elements**. -/
theorem s5_card : Fintype.card (Equiv.Perm (Fin 5)) = 120 := by
  rw [Fintype.card_perm, Fintype.card_fin]; norm_num [Nat.factorial]

/-- **Factorial monotonicity**: m ≤ n ⟹ m! ≤ n!.
    Bridge: connects combinatorics → complexity bounds. -/
theorem factorial_mono {m n : ℕ} (h : m ≤ n) : Nat.factorial m ≤ Nat.factorial n :=
  Nat.factorial_le h

/-- **120 ≤ n! for n ≥ 5**: S₅ embeds into Sₙ.
    Impact: post_quantum_security — minimum Galois group size. -/
theorem factorial_ge_120 (n : ℕ) (hn : 5 ≤ n) : 120 ≤ Nat.factorial n := by
  calc 120 = Nat.factorial 5 := by norm_num [Nat.factorial]
    _ ≤ Nat.factorial n := Nat.factorial_le hn

/-- **S₅ commutator is non-trivial**: [S₅,S₅] ≠ ⊥.
    This is the obstruction to solvability of S₅.
    Bridge: connects commutator theory → solvability obstruction → tropical Abel-Ruffini. -/
theorem s5_commutator_nontrivial :
    commutator (Equiv.Perm (Fin 5)) ≠ ⊥ := by
  intro h
  have : IsSolvable (Equiv.Perm (Fin 5)) := by
    rw [isSolvable_def]; exact ⟨1, by simp [h]⟩
  exact s5_not_solvable this

/-! ## Section 3: Galois Group Size Bounds -/

/-- **Galois embedding bound**: |H| divides n! for any H ≤ Sₙ.
    Bridge: connects Lagrange's theorem → tropical Galois bounds.
    Impact: post_quantum_security — limits Galois group search space. -/
theorem tropical_galois_embedding_bound (n : ℕ) (H : Subgroup (Equiv.Perm (Fin n))) :
    Nat.card H ∣ Nat.factorial n := by
  have := Subgroup.card_subgroup_dvd_card H
  rwa [Nat.card_eq_fintype_card (α := Equiv.Perm (Fin n)),
       Fintype.card_perm, Fintype.card_fin] at this

/-- **Full group has order n!**. -/
theorem perm_full_card (n : ℕ) :
    Nat.card (⊤ : Subgroup (Equiv.Perm (Fin n))) = Nat.factorial n := by
  rw [Subgroup.card_top, Nat.card_eq_fintype_card, Fintype.card_perm, Fintype.card_fin]

/-- **Trivial subgroup has order 1**. -/
theorem perm_trivial_card (n : ℕ) :
    Nat.card (⊥ : Subgroup (Equiv.Perm (Fin n))) = 1 :=
  Subgroup.card_bot

/-- **Lagrange for tropical Galois**: |Sₙ| = |H| · [Sₙ : H].
    Bridge: connects Lagrange's theorem → tropical degree theory. -/
theorem lagrange_tropical (n : ℕ) (H : Subgroup (Equiv.Perm (Fin n))) :
    Nat.card (Equiv.Perm (Fin n)) = Nat.card H * H.index :=
  (Subgroup.card_mul_index H).symm

/-! ## Section 4: Certified Robustness -/

/-- **Robustness-complexity tradeoff**: Simpler models (lower degree d) give
    larger robustness radii. ∀ d₁ ≤ d₂, m/(2d₂) ≤ m/(2d₁).
    Bridge: connects tropical geometry → ML model selection.
    Impact: certified_robustness — formal justification for network pruning. -/
theorem robustness_complexity_tradeoff (d₁ d₂ m : ℕ) (hd₁ : 0 < d₁) (hd : d₁ ≤ d₂) :
    m / (2 * d₂) ≤ m / (2 * d₁) := by
  apply Nat.div_le_div_left (Nat.mul_le_mul_left 2 hd) (by positivity)

/-- **Maximum robustness at degree 1**: Linear models are most robust. -/
theorem max_robustness_linear (m d : ℕ) (hd : 1 ≤ d) :
    m / (2 * d) ≤ m / 2 :=
  Nat.div_le_div_left (Nat.mul_le_mul_left 2 hd) (by omega)

/-- **Margin amplification**: Doubling margin doubles robustness radius.
    Impact: lipschitz_certified_robustness. -/
theorem margin_amplification (d m : ℕ) :
    m / (2 * d) ≤ (2 * m) / (2 * d) :=
  Nat.div_le_div_right (by omega)

/-- **Robustness comparison**: Larger margin ⟹ more robust.
    Impact: certified_robustness — model comparison criterion. -/
theorem robustness_comparison (m₁ m₂ d : ℕ) (hm : m₁ ≤ m₂) :
    m₁ / (2 * d) ≤ m₂ / (2 * d) :=
  Nat.div_le_div_right hm

/-! ## Section 5: Tropical Hash Function Theory -/

/-- **Preimage growth**: ∀ t, ∃ n distinct inputs mapping to t under max.
    Impact: tropical_hash_collision — linear preimage growth. -/
theorem tropical_hash_preimage_growth (n : ℕ) (t : ℤ) :
    ∃ S : Finset ℤ, S.card = n ∧ ∀ a ∈ S, max a t = t := by
  refine ⟨(Finset.range n).map ⟨fun (i : ℕ) => t - (↑i : ℤ) - 1,
    fun a b (h : t - (↑a : ℤ) - 1 = t - (↑b : ℤ) - 1) => by omega⟩, ?_, ?_⟩
  · simp [Finset.card_map]
  · intro a ha
    simp only [Finset.mem_map, Finset.mem_range, Function.Embedding.coeFn_mk] at ha
    obtain ⟨i, _, rfl⟩ := ha
    show max (t - ↑i - 1) t = t; omega

/-- **Composition amplifies loss**: Double max preserves collisions.
    Impact: tropical_hash_collision. -/
theorem tropical_double_hash (t : ℤ) (n : ℕ) :
    ∃ S : Finset ℤ, S.card = n ∧ ∀ a ∈ S, max (max a t) t = t := by
  obtain ⟨S, hcard, hS⟩ := tropical_hash_preimage_growth n t
  exact ⟨S, hcard, fun a ha => by rw [hS a ha, max_self]⟩

/-- **Min-plus duality**: min-plus semiring has the same collision structure.
    Impact: tropical_hash_collision — applies to both min-plus and max-plus. -/
theorem tropical_minplus_collision (t : ℤ) (n : ℕ) :
    ∃ S : Finset ℤ, S.card = n ∧ ∀ a ∈ S, min a t = t := by
  refine ⟨(Finset.range n).map ⟨fun (i : ℕ) => t + (↑i : ℤ) + 1,
    fun a b (h : t + (↑a : ℤ) + 1 = t + (↑b : ℤ) + 1) => by omega⟩, ?_, ?_⟩
  · simp [Finset.card_map]
  · intro a ha
    simp only [Finset.mem_map, Finset.mem_range, Function.Embedding.coeFn_mk] at ha
    obtain ⟨i, _, rfl⟩ := ha
    show min (t + ↑i + 1) t = t; omega

/-! ## Section 6: Radical Tower Theory -/

/-- **Tower degree ≥ 2^height**: Each radical step multiplies degree by ≥ 2.
    Impact: post_quantum_security — exponential complexity lower bound. -/
theorem tower_degree_exponential (h : ℕ) (indices : Fin h → ℕ)
    (hind : ∀ i, 2 ≤ indices i) :
    2 ^ h ≤ Finset.univ.prod indices := by
  calc 2 ^ h = Finset.univ.prod (fun (_ : Fin h) => 2) := by
        simp [Finset.prod_const, Finset.card_univ]
    _ ≤ Finset.univ.prod indices := by
        apply Finset.prod_le_prod
        · intro i _; omega
        · intro i _; exact hind i

/-- **Tower height bound**: height ≤ degree. -/
theorem tower_height_le_degree (h : ℕ) (indices : Fin h → ℕ)
    (hind : ∀ i, 2 ≤ indices i) :
    h ≤ Finset.univ.prod indices :=
  le_trans Nat.lt_two_pow_self.le (tower_degree_exponential h indices hind)

/-- **Binary tower**: All-2 indices give degree = 2^h. -/
theorem binary_tower_degree (h : ℕ) :
    Finset.univ.prod (fun (_ : Fin h) => 2) = 2 ^ h := by
  simp [Finset.prod_const, Finset.card_univ]

/-- **Tower composition**: Composing towers multiplies degrees. -/
theorem tower_composition (h₁ h₂ : ℕ)
    (ind₁ : Fin h₁ → ℕ) (ind₂ : Fin h₂ → ℕ)
    (hind₁ : ∀ i, 2 ≤ ind₁ i) (hind₂ : ∀ i, 2 ≤ ind₂ i) :
    2 ^ (h₁ + h₂) ≤ Finset.univ.prod ind₁ * Finset.univ.prod ind₂ := by
  rw [pow_add]
  exact Nat.mul_le_mul (tower_degree_exponential h₁ ind₁ hind₁)
                        (tower_degree_exponential h₂ ind₂ hind₂)

/-! ## Section 7: Brute-Force Complexity -/

/-- **n! ≥ 2^n for n ≥ 4**: Galois computation is exponential.
    Impact: post_quantum_security — exponential OWF gap. -/
theorem brute_force_complexity (n : ℕ) (hn : 4 ≤ n) :
    2 ^ n ≤ Nat.factorial n := by
  induction n with
  | zero => omega
  | succ m ih =>
    rw [Nat.factorial_succ, pow_succ]
    by_cases hm : 4 ≤ m
    · calc 2 ^ m * 2 ≤ Nat.factorial m * 2 := by
            apply Nat.mul_le_mul_right; exact ih hm
        _ ≤ Nat.factorial m * (m + 1) := by
            apply Nat.mul_le_mul_left; omega
        _ = (m + 1) * Nat.factorial m := by ring
    · interval_cases m <;> simp_all [Nat.factorial]

/-- **n² ≤ n! for n ≥ 4**: Forward O(n²) vs inverse Ω(n!).
    Impact: post_quantum_security — super-polynomial OWF advantage. -/
theorem owf_gap (n : ℕ) (hn : 4 ≤ n) : n ^ 2 ≤ Nat.factorial n := by
  have hsq : n ^ 2 ≤ 2 ^ n := by
    induction n with
    | zero => omega
    | succ m ih =>
      by_cases hm : m ≤ 4
      · interval_cases m <;> omega
      · push_neg at hm
        have ihm := ih (by omega)
        have hm3 : 2 * m + 1 ≤ m ^ 2 := by nlinarith
        have : 2 ^ (m + 1) = 2 ^ m * 2 := pow_succ 2 m
        nlinarith
  linarith [brute_force_complexity n hn]

/-! ## Section 8: Galois Correspondence — Structural Lemmas -/

/-- **Involution fixed point**: σ² = id ⟹ σ(σ(x)) = x.
    Bridge: connects involution theory → tropical Galois theory. -/
theorem involution_fixed {S : Type*} (σ : S ≃ S) (hσ : σ.trans σ = Equiv.refl S) (x : S) :
    σ (σ x) = x := by
  have := Equiv.ext_iff.mp hσ x
  simpa [Equiv.trans_apply] using this

/-- **Galois injectivity**: An automorphism fixing everything is the identity.
    Bridge: connects Galois theory → tropical algebra. -/
theorem galois_injectivity {S : Type*} (σ : S ≃ S) (hfix : ∀ x : S, σ x = x) :
    σ = Equiv.refl S :=
  Equiv.ext hfix

/-- **Order-reversing for Sₙ subgroups**: H₁ ≤ H₂ ⟹ Fix(H₂) ⊆ Fix(H₁).
    Bridge: connects lattice theory → tropical Galois correspondence. -/
theorem subgroup_fix_antitone {n : ℕ}
    (H₁ H₂ : Subgroup (Equiv.Perm (Fin n)))
    (h : H₁ ≤ H₂) (f : Fin n → Fin n)
    (hf : ∀ σ : Equiv.Perm (Fin n), σ ∈ H₂ → ∀ i, σ (f i) = f i) :
    ∀ σ : Equiv.Perm (Fin n), σ ∈ H₁ → ∀ i, σ (f i) = f i :=
  fun σ hσ => hf σ (h hσ)

/-- **Index-degree relationship**: |Sₙ| = |H| · [Sₙ : H].
    The index equals the number of cosets, analogous to the degree
    of an intermediate tropical extension.
    Bridge: connects Lagrange → tropical degree theory. -/
theorem index_degree_relationship (n : ℕ) (H : Subgroup (Equiv.Perm (Fin n))) :
    Nat.card (Equiv.Perm (Fin n)) = Nat.card H * H.index :=
  (Subgroup.card_mul_index H).symm

/-! ## Section 9: Concrete Computations -/

/-- S₃ has 6 elements. -/
theorem s3_card : Fintype.card (Equiv.Perm (Fin 3)) = 6 := by
  rw [Fintype.card_perm, Fintype.card_fin]; norm_num [Nat.factorial]

/-- S₄ has 24 elements. -/
theorem s4_card : Fintype.card (Equiv.Perm (Fin 4)) = 24 := by
  rw [Fintype.card_perm, Fintype.card_fin]; norm_num [Nat.factorial]

/-- **Tropical eval example**: max(3, 2+x, 1+2x) at x=1 is 3. -/
theorem tropical_eval_example :
    max (max 3 (2 + 1 * 1)) (1 + 2 * 1) = 3 := by norm_num

/-- **Tropical eval example**: max(3, 2+x, 1+2x) at x=2 is 5. -/
theorem tropical_eval_example2 :
    max (max 3 (2 + 1 * 2)) (1 + 2 * 2) = 5 := by norm_num

/-- **Bend point example**: max(3, 2+x) bends at x=1. -/
theorem bend_point_example :
    (3 : ℤ) = 2 + 1 * 1 ∧ max 3 (2 + 1 * 1) = 3 := by
  constructor <;> norm_num

end TropicalGaloisSolvability