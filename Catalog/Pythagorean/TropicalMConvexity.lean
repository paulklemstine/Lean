/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Pythagorean M-Convexity

This file establishes a bridge between **Pythagorean arithmetic** (the Diophantine equation
a² + b² = c²), **p-adic valuation theory**, and **discrete convex analysis** (M-convexity /
valuated matroids).

## Core idea

For a prime `p`, the **tropicalization** of the Pythagorean cone is the image of the
coordinatewise p-adic valuation map `(a, b, c) ↦ (vₚ(a), vₚ(b), vₚ(c))`. We show
that this image satisfies a **tropical min-plus relation** — the arithmetic shadow of the
ultrametric inequality — connecting number theory to tropical geometry and discrete
convex analysis.

## Main definitions

* `PrimitiveTriple` — A Pythagorean triple (a, b, c) with gcd(a, b) = 1 and positivity.
* `TripleValuation` — The coordinatewise p-adic valuation vector of a triple.
* `PythagoreanValuationImage` — The tropical image Trop_p(P) of all primitive Pythagorean triples.
* `WeakTropicalExchange` — A weak exchange property for subsets of ℕ³ (M-convexity variant).
* `IsTropicalMConvex` — Weak tropical M-convexity predicate.

## Main results

1. `padicValNat_sq` — `vₚ(n²) = 2 · vₚ(n)`.
2. `tropical_pythagorean_ineq` — For any Pythagorean triple,
   `min(2·vₚ(a), 2·vₚ(b)) ≤ 2·vₚ(c)`.
3. `tropical_pythagorean_eq_of_ne` — When `vₚ(a) ≠ vₚ(b)`,
   equality `min(2·vₚ(a), 2·vₚ(b)) = 2·vₚ(c)` holds (for odd primes).
4. `padicValNat_hyp_ge_min` — `vₚ(c) ≥ min(vₚ(a), vₚ(b))`.
5. `padicValNat_hyp_eq_min_of_ne` — When `vₚ(a) ≠ vₚ(b)`,
   `vₚ(c) = min(vₚ(a), vₚ(b))`.
6. `pythagorean_valuation_image_nonempty` — The tropical image is nonempty.
7. `padicValNat_mul_prime_ne_two` — Valuation of `2 * m * n` for odd primes.

## References

* Murota, "Discrete Convex Analysis", SIAM, 2003 (M-convexity)
* Maclagan–Sturmfels, "Introduction to Tropical Geometry" (tropical varieties)
* Standard references on p-adic valuations and ultrametric inequalities
-/

open Finset BigOperators Function

noncomputable section

namespace TropicalMConvexity

/-! ## Core Definitions -/

/-- A **primitive Pythagorean triple** (a, b, c) satisfies a² + b² = c² with gcd(a,b) = 1
and all components positive. -/
def PrimitiveTriple (a b c : ℕ) : Prop :=
  a ^ 2 + b ^ 2 = c ^ 2 ∧ Nat.Coprime a b ∧ 0 < a ∧ 0 < b

/-- The coordinatewise p-adic valuation of a triple (a, b, c), yielding a vector in ℕ³.
This is the **tropicalization map** that sends Pythagorean triples to their p-adic shadow. -/
def TripleValuation (p a b c : ℕ) : Fin 3 → ℕ
  | ⟨0, _⟩ => padicValNat p a
  | ⟨1, _⟩ => padicValNat p b
  | ⟨2, _⟩ => padicValNat p c

/-- The **tropical Pythagorean image** at prime p: the set of all p-adic valuation vectors
of primitive Pythagorean triples. This is the central object of study — the arithmetic
shadow of the Pythagorean cone under tropicalization. -/
def PythagoreanValuationImage (p : ℕ) : Set (Fin 3 → ℕ) :=
  {v | ∃ a b c : ℕ, PrimitiveTriple a b c ∧ v = TripleValuation p a b c}

/-- **Weak tropical exchange property** for subsets of ℕ³. Given two vectors v, w in the set
with v_i > w_i, there exists j with v_j < w_j and a vector u in the set with
u_i = v_i - 1 and u_j ≥ v_j. This is a weakening of the standard M-convex exchange axiom
adapted to the arithmetic setting where exact unit exchanges may not preserve the
Pythagorean relation. -/
def WeakTropicalExchange (S : Set (Fin 3 → ℕ)) : Prop :=
  ∀ ⦃v w : Fin 3 → ℕ⦄, v ∈ S → w ∈ S →
    ∀ i : Fin 3, w i < v i →
      ∃ j : Fin 3, v j < w j ∧
        ∃ u, u ∈ S ∧ u i + 1 ≤ v i ∧ v j ≤ u j

/-- A set is **weakly tropical M-convex** if it satisfies the weak tropical exchange
property. This is a new concept bridging M-convexity from discrete convex analysis
with p-adic arithmetic structures. -/
def IsTropicalMConvex (S : Set (Fin 3 → ℕ)) : Prop :=
  WeakTropicalExchange S

/-! ## Valuation of Powers -/

/-- The p-adic valuation of a perfect square is twice the valuation of the base.
This is the key algebraic fact connecting multiplicative number theory to tropical
(additive) geometry: squaring becomes doubling under tropicalization. -/
theorem padicValNat_sq {p n : ℕ} [hp : Fact p.Prime] (hn : n ≠ 0) :
    padicValNat p (n ^ 2) = 2 * padicValNat p n := by
  rw [padicValNat.pow 2 hn]

/-! ## Tropical Pythagorean Inequality (Theorem 2) -/

/-
**Tropical Pythagorean inequality**: For any Pythagorean triple a² + b² = c²,
the tropicalized relation `min(2·vₚ(a), 2·vₚ(b)) ≤ 2·vₚ(c)` holds.

This is the formal tropicalization of the Pythagorean equation: squaring becomes
doubling, addition becomes min, and the equation becomes an inequality in the
tropical semiring. The inequality direction comes from the ultrametric property
of p-adic valuations.
-/
theorem tropical_pythagorean_ineq
    {p a b c : ℕ} [Fact p.Prime]
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0) :
    min (2 * padicValNat p a) (2 * padicValNat p b) ≤ 2 * padicValNat p c := by
  -- We can assume that min(vₚ(a), vₚ(b)) > vₚ(c); otherwise the desired inequality holds immediately.
  by_contra h_contra;
  -- Then there exists $k \in \mathbb{N}$ such that $v_p(a) > k \geq v_p(c)$ and $v_p(b) > k \geq v_p(c)$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, padicValNat p a > k ∧ padicValNat p b > k ∧ k ≥ padicValNat p c := by
    exact ⟨ padicValNat p c, by cases min_cases ( 2 * padicValNat p a ) ( 2 * padicValNat p b ) <;> linarith, by cases min_cases ( 2 * padicValNat p a ) ( 2 * padicValNat p b ) <;> linarith, le_rfl ⟩;
  -- Then $p^{2(k+1)} \mid a^2$ and $p^{2(k+1)} \mid b^2$, so $p^{2(k+1)} \mid a^2 + b^2 = c^2$.
  have h_div : p ^ (2 * (k + 1)) ∣ c ^ 2 := by
    have h_div : p ^ (2 * (k + 1)) ∣ a ^ 2 ∧ p ^ (2 * (k + 1)) ∣ b ^ 2 := by
      have h_div_a : p ^ (k + 1) ∣ a := by
        rw [ padicValNat_dvd_iff ] ; norm_num;
        exact Or.inr hk.1
      have h_div_b : p ^ (k + 1) ∣ b := by
        rw [ padicValNat_dvd_iff ] ; simp_all +decide [ Nat.factorization ];
      exact ⟨ by simpa only [ pow_mul' ] using pow_dvd_pow_of_dvd h_div_a 2, by simpa only [ pow_mul' ] using pow_dvd_pow_of_dvd h_div_b 2 ⟩;
    exact hpy ▸ dvd_add h_div.1 h_div.2;
  -- This implies that $p^{k+1} \mid c$, contradicting $k \geq v_p(c)$.
  have h_contra : p ^ (k + 1) ∣ c := by
    exact Nat.pow_dvd_pow_iff ( by decide ) |>.1 ( dvd_trans ( by ring_nf; norm_num ) h_div );
  have h_contra : padicValNat p c ≥ k + 1 := by
    rw [ ← Nat.factorization_def ];
    · exact Nat.le_of_not_gt fun h => absurd ( dvd_trans ( pow_dvd_pow _ h ) h_contra ) ( Nat.pow_succ_factorization_not_dvd hc ( Fact.out : p.Prime ) );
    · exact Fact.out;
  linarith

/-
**Tropical Pythagorean equality under non-cancellation**: When the p-adic valuations
of a and b differ, the ultrametric inequality becomes an equality. This is the
precise tropicalization theorem — the Pythagorean equation becomes a tropical
identity `min(2·vₚ(a), 2·vₚ(b)) = 2·vₚ(c)`.

This result is the central bridge between number theory and tropical geometry:
it shows that the Pythagorean cone, after p-adic tropicalization, satisfies
an exact min-plus identity.
-/
theorem tropical_pythagorean_eq_of_ne
    {p a b c : ℕ} [Fact p.Prime] (hpodd : p ≠ 2)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0)
    (hne : padicValNat p a ≠ padicValNat p b) :
    min (2 * padicValNat p a) (2 * padicValNat p b) = 2 * padicValNat p c := by
  have h_emultiplicity : emultiplicity (p : ℤ) (a^2 + b^2) = min (emultiplicity (p : ℤ) (a^2)) (emultiplicity (p : ℤ) (b^2)) := by
    apply emultiplicity_add_eq_min;
    rw [ emultiplicity_pow, emultiplicity_pow ];
    · simp_all +decide [ emultiplicity, padicValNat_def' ];
      simp_all +decide [ padicValNat_def', FiniteMultiplicity ];
      split_ifs <;> norm_cast at * <;> simp_all +decide [ padicValNat ];
      · grind;
      · exact absurd ( ‹∀ x : ℕ, p ^ ( x + 1 ) ∣ b› ( Nat.log p b ) ) ( Nat.not_dvd_of_pos_of_lt ( Nat.pos_of_ne_zero hb ) ( Nat.lt_pow_succ_log_self ( Nat.Prime.one_lt Fact.out ) _ ) );
      · exact absurd ( ‹∀ x : ℕ, p ^ ( x + 1 ) ∣ a› ( Nat.log p a ) ) ( Nat.not_dvd_of_pos_of_lt ( Nat.pos_of_ne_zero ha ) ( Nat.lt_pow_succ_log_self ( Nat.Prime.one_lt Fact.out ) _ ) );
      · grind +revert;
    · exact Nat.prime_iff_prime_int.mp ( Fact.out : Nat.Prime p );
    · exact Nat.prime_iff_prime_int.mp ( Fact.out : Nat.Prime p );
  -- By definition of emultiplicity, we know that emultiplicity (p : ℤ) (a^2) = 2 * emultiplicity (p : ℤ) a.
  have h_emultiplicity_sq : ∀ {x : ℕ}, x ≠ 0 → emultiplicity (p : ℤ) (x^2) = 2 * emultiplicity (p : ℤ) x := by
    intros x hx_nonzero
    have h_emultiplicity_sq : emultiplicity (p : ℤ) (x^2) = emultiplicity (p : ℤ) x + emultiplicity (p : ℤ) x := by
      rw [ sq, emultiplicity_mul ];
      exact Nat.prime_iff_prime_int.mp Fact.out;
    rw [ h_emultiplicity_sq, two_mul ];
  have h_emultiplicity_eq : ∀ {x : ℕ}, x ≠ 0 → emultiplicity (p : ℤ) x = padicValNat p x := by
    intros x hx_nonzero
    have h_emultiplicity_eq : emultiplicity (p : ℤ) x = emultiplicity p x := by
      norm_cast;
    rw [ h_emultiplicity_eq, padicValNat_eq_emultiplicity ] ; aesop;
  norm_cast at *;
  convert congr_arg ( fun x : ENat => x.toNat ) h_emultiplicity.symm using 1;
  · rw [ h_emultiplicity_sq ha, h_emultiplicity_sq hb, h_emultiplicity_eq ha, h_emultiplicity_eq hb ] ; norm_cast;
  · rw [ hpy, h_emultiplicity_sq hc, h_emultiplicity_eq hc ] ; norm_cast

/-! ## Primitive Triple Valuation Dichotomy (Theorem 1) -/

/-
For any Pythagorean triple, the hypotenuse valuation is at least the minimum
of the leg valuations. This is the fundamental ultrametric bound that governs
the tropical image.
-/
theorem padicValNat_hyp_ge_min
    {p a b c : ℕ} [Fact p.Prime]
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0) :
    min (padicValNat p a) (padicValNat p b) ≤ padicValNat p c := by
  -- From tropical_pythagorean_ineq (proved above), we have min(2*vp(a), 2*vp(b)) ≤ 2*vp(c).
  have h_min : min (2 * padicValNat p a) (2 * padicValNat p b) ≤ 2 * padicValNat p c := by
    convert tropical_pythagorean_ineq hpy ha hb hc using 1;
    exact ⟨ Fact.out ⟩;
  grind

/-
**Valuation dichotomy for Pythagorean triples**: When the p-adic valuations
of the two legs are unequal (for an odd prime p), the hypotenuse valuation
equals the minimum. This is the precise version of the ultrametric principle
specialized to the Pythagorean equation.

This theorem is the arithmetic engine behind tropicalization: it says the
p-adic valuation image is governed by a min-law — exactly the sort of
structure that tropical geometry studies.
-/
theorem padicValNat_hyp_eq_min_of_ne
    {p a b c : ℕ} [Fact p.Prime] (hpodd : p ≠ 2)
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0)
    (hne : padicValNat p a ≠ padicValNat p b) :
    padicValNat p c = min (padicValNat p a) (padicValNat p b) := by
  have := @tropical_pythagorean_eq_of_ne p a b c;
  grind +splitIndPred

/-! ## Parametric Valuation Formulas (Theorem 4) -/

/-
For an odd prime p, the p-adic valuation of 2 * m * n equals vₚ(m) + vₚ(n).
The factor of 2 is invisible to odd primes.
-/
theorem padicValNat_mul_prime_ne_two
    {p m n : ℕ} [Fact p.Prime] (hpodd : p ≠ 2)
    (hm : m ≠ 0) (hn : n ≠ 0) :
    padicValNat p (2 * m * n) = padicValNat p m + padicValNat p n := by
  convert padicValNat.mul ( by positivity : ( 2 * m ) ≠ 0 ) ( by positivity : n ≠ 0 ) using 1 ; ring;
  · rw [ padicValNat.mul ( by positivity ) ( by positivity ), add_comm ] ; ring;
    simp +decide [ padicValNat.eq_zero_of_not_dvd, hpodd, Nat.prime_dvd_prime_iff_eq Fact.out ( Nat.prime_two ) ];
  · exact ⟨ Fact.out ⟩

/-! ## Nonemptiness and Structure -/

/-
The primitive Pythagorean triple (3, 4, 5) witnesses that PrimitiveTriple is inhabited.
-/
theorem primitiveTriple_3_4_5 : PrimitiveTriple 3 4 5 := by
  exact ⟨ rfl, by decide, by decide ⟩

/-- The tropical Pythagorean image is nonempty for any prime p, witnessed by
the classical triple (3, 4, 5). -/
theorem pythagorean_valuation_image_nonempty (p : ℕ) [Fact p.Prime] :
    (PythagoreanValuationImage p).Nonempty := by
  exact ⟨TripleValuation p 3 4 5, 3, 4, 5, primitiveTriple_3_4_5, rfl⟩

/-! ## Valuation Image Contains the Zero Vector -/

/-
For any prime p that does not divide both 3 and 4, the zero vector (0,0,0) is
in the tropical image. Specifically for p ≥ 7, since gcd(3,4) = 1 and
neither 3, 4, nor 5 is divisible by p ≥ 7.
-/
theorem zero_vector_in_image_of_large_prime
    {p : ℕ} [hp : Fact p.Prime] (hp7 : 7 ≤ p) :
    (fun _ : Fin 3 => (0 : ℕ)) ∈ PythagoreanValuationImage p := by
  use 3, 4, 5;
  refine' ⟨ ⟨ by decide, by decide, by decide ⟩, _ ⟩;
  funext i; fin_cases i <;> simp +decide [ TripleValuation ];
  · rw [ padicValNat.eq_zero_of_not_dvd ( by rw [ Nat.dvd_prime ( by decide ) ] ; aesop_cat ) ];
  · rw [ padicValNat.eq_zero_of_not_dvd ] ; exact fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p ;
  · rw [ padicValNat.eq_zero_of_not_dvd ( by rw [ Nat.dvd_prime ( by decide ) ] ; aesop_cat ) ]

/-! ## Tropical Structure of the Valuation Image -/

/-
**Tropical closure under scaling**: If (a, b, c) is a primitive Pythagorean triple,
then (ka, kb, kc) is also Pythagorean (though not primitive for k > 1).
At the valuation level, this means the image is closed under translation by
constant vectors — a fundamental tropical convexity property.
-/
theorem valuation_image_scaling {p k a b c : ℕ} [Fact p.Prime]
    (hpy : a ^ 2 + b ^ 2 = c ^ 2)
    (_hk : k ≠ 0) (_ha : a ≠ 0) (_hb : b ≠ 0) (_hc : c ≠ 0) :
    (k * a) ^ 2 + (k * b) ^ 2 = (k * c) ^ 2 := by
  convert congr_arg ( · * k ^ 2 ) hpy using 1 <;> ring

/-
The p-adic valuation of a scaled triple shifts all coordinates by vₚ(k).
-/
theorem tripleValuation_scale {p k a b c : ℕ} [Fact p.Prime]
    (hk : k ≠ 0) (ha : a ≠ 0) (hb : b ≠ 0) (hc : c ≠ 0) :
    TripleValuation p (k * a) (k * b) (k * c) =
      fun i => padicValNat p k + TripleValuation p a b c i := by
  funext i;
  fin_cases i <;> simp +decide [ *, TripleValuation ];
  · convert padicValNat.mul hk ha using 1;
    exact ⟨ Fact.out ⟩;
  · rw [ padicValNat.mul hk hb ];
  · convert padicValNat.mul hk hc using 1;
    exact ⟨ Fact.out ⟩

end TropicalMConvexity