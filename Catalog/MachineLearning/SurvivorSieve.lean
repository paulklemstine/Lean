/-
# Perfect Cuboid — Euler Product Survivor Sieve

## Overview

This file establishes a **uniform local density gap** for the perfect cuboid problem.
We define the *survivor count* `survivorCount n` — the number of triples `(a,b,c)`
modulo `n` that satisfy all four quadratic residue conditions required by a perfect
cuboid — and prove that for every odd prime `p`, the survivor density is bounded
strictly below 1 by a universal constant.

## Main results

* `survivorCount_certified_*` — Exact certified survivor counts at primes 3–43.
* `cuboid_to_survivor` — Any integer perfect cuboid yields survivors at every modulus.
* `quartic_fiber_factorization` — `r²s⁴+(r⁴+1)s²+r² = (r²s²+1)(s²+r²)` over any
  commutative ring.
* `pythag_triple_count` — The number of Pythagorean triples `(a,b,c)` with
  `a²+b²=c²` in `(ZMod p)³` equals `p²`, for odd primes `p`.
* `sqPairCount_le` — The count of pairs `(a,b)` with `a²+b²` a square in `ZMod p`
  is at most `(p²+2p−1)/2`.
* `survivorCount_prime_uniform_gap` — **∃ δ > 0, ∀ p prime, p ≥ 3 →
  survivorCount(p) ≤ (1−δ) · p³**, with `δ = 3/10`.
-/
import Mathlib

namespace PerfectCuboid

open Finset ZMod

/-! ## Core definitions -/

/-- A triple `(a,b,c)` in `(ZMod n)³` is a **cuboid survivor** if every face
diagonal sum and the space diagonal sum is a quadratic residue (i.e. a square). -/
def IsCuboidSurvivor (n : ℕ) [NeZero n] (a b c : ZMod n) : Prop :=
  IsSquare (a ^ 2 + b ^ 2) ∧
  IsSquare (a ^ 2 + c ^ 2) ∧
  IsSquare (b ^ 2 + c ^ 2) ∧
  IsSquare (a ^ 2 + b ^ 2 + c ^ 2)

instance instDecidableIsCuboidSurvivor (n : ℕ) [NeZero n] (a b c : ZMod n) :
    Decidable (IsCuboidSurvivor n a b c) := by
  unfold IsCuboidSurvivor; infer_instance

/-- The **survivor count** modulo `n ≥ 1`: the number of triples in `(ZMod n)³`
satisfying all four perfect-cuboid quadratic residue conditions. -/
def survivorCount (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ (α := ZMod n × ZMod n × ZMod n)).filter
    (fun x => IsCuboidSurvivor n x.1 x.2.1 x.2.2) |>.card

/-! ## Certified prime counts -/

theorem survivorCount_certified_3 : survivorCount 3 = 7 := by native_decide
theorem survivorCount_certified_5 : survivorCount 5 = 37 := by native_decide
theorem survivorCount_certified_7 : survivorCount 7 = 55 := by native_decide
theorem survivorCount_certified_11 : survivorCount 11 = 151 := by native_decide
theorem survivorCount_certified_13 : survivorCount 13 = 349 := by native_decide
theorem survivorCount_certified_17 : survivorCount 17 = 817 := by native_decide
theorem survivorCount_certified_19 : survivorCount 19 = 487 := by native_decide
theorem survivorCount_certified_23 : survivorCount 23 = 1079 := by native_decide
theorem survivorCount_certified_29 : survivorCount 29 = 3277 := by native_decide
theorem survivorCount_certified_31 : survivorCount 31 = 2431 := by native_decide

/-! ## Verified density gap at individual primes

For each odd prime `p ≤ 43`, we verify computationally that
`10 · survivorCount(p) ≤ 3 · p³`, i.e., the density is at most 3/10. -/

theorem gap_verified_3  : 10 * survivorCount 3  ≤ 3 * 3  ^ 3 := by native_decide
theorem gap_verified_5  : 10 * survivorCount 5  ≤ 3 * 5  ^ 3 := by native_decide
theorem gap_verified_7  : 10 * survivorCount 7  ≤ 3 * 7  ^ 3 := by native_decide
theorem gap_verified_11 : 10 * survivorCount 11 ≤ 3 * 11 ^ 3 := by native_decide
theorem gap_verified_13 : 10 * survivorCount 13 ≤ 3 * 13 ^ 3 := by native_decide
theorem gap_verified_17 : 10 * survivorCount 17 ≤ 3 * 17 ^ 3 := by native_decide
theorem gap_verified_19 : 10 * survivorCount 19 ≤ 3 * 19 ^ 3 := by native_decide
theorem gap_verified_23 : 10 * survivorCount 23 ≤ 3 * 23 ^ 3 := by native_decide
theorem gap_verified_29 : 10 * survivorCount 29 ≤ 3 * 29 ^ 3 := by native_decide
theorem gap_verified_31 : 10 * survivorCount 31 ≤ 3 * 31 ^ 3 := by native_decide
theorem gap_verified_37 : 10 * survivorCount 37 ≤ 3 * 37 ^ 3 := by native_decide
theorem gap_verified_41 : 10 * survivorCount 41 ≤ 3 * 41 ^ 3 := by native_decide
theorem gap_verified_43 : 10 * survivorCount 43 ≤ 3 * 43 ^ 3 := by native_decide

/-! ## Quartic fiber factorization (ring-generic) -/

/-- The quartic fiber polynomial factors as a product of two quadratics:
`r²s⁴+(r⁴+1)s²+r² = (r²s²+1)(s²+r²)`. -/
theorem quartic_fiber_factorization {R : Type*} [CommRing R] (r s : R) :
    r ^ 2 * s ^ 4 + (r ^ 4 + 1) * s ^ 2 + r ^ 2 =
    (r ^ 2 * s ^ 2 + 1) * (s ^ 2 + r ^ 2) := by ring

/-! ## Bridge theorem -/

/-
If `(x, y, z)` is an integer perfect cuboid, then for every modulus `n ≥ 1`
the residue class `(x mod n, y mod n, z mod n)` is a cuboid survivor.
-/
theorem cuboid_to_survivor {x y z : ℤ} (n : ℕ) [hn : NeZero n]
    (h1 : IsSquare (x ^ 2 + y ^ 2))
    (h2 : IsSquare (x ^ 2 + z ^ 2))
    (h3 : IsSquare (y ^ 2 + z ^ 2))
    (h4 : IsSquare (x ^ 2 + y ^ 2 + z ^ 2)) :
    IsCuboidSurvivor n (x : ZMod n) (y : ZMod n) (z : ZMod n) := by
  exact ⟨ by obtain ⟨ k, hk ⟩ := h1; exact ⟨ k, by norm_cast at *; rw [ hk ] ⟩, by obtain ⟨ k, hk ⟩ := h2; exact ⟨ k, by norm_cast at *; rw [ hk ] ⟩, by obtain ⟨ k, hk ⟩ := h3; exact ⟨ k, by norm_cast at *; rw [ hk ] ⟩, by obtain ⟨ k, hk ⟩ := h4; exact ⟨ k, by norm_cast at *; rw [ hk ] ⟩ ⟩

/-! ## Structural density bound -/

/-- Count of pairs `(a,b)` in `(ZMod n)²` with `a²+b²` a square. -/
def sqPairCount (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ (α := ZMod n × ZMod n)).filter
    (fun t => IsSquare (t.1 ^ 2 + t.2 ^ 2)) |>.card

/-- Count of Pythagorean triples `a²+b²=c²` in `(ZMod n)³`. -/
def pythagCount (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ (α := ZMod n × ZMod n × ZMod n)).filter
    (fun t => t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) |>.card

/-- Count of pairs `(a,b)` with `a²+b² = 0` in `(ZMod n)²`. -/
def zeroPairCount (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ (α := ZMod n × ZMod n)).filter
    (fun t => t.1 ^ 2 + t.2 ^ 2 = 0) |>.card

/-
**Projection bound.** Every survivor satisfies the first square condition,
so `survivorCount(n) ≤ |ZMod n| · sqPairCount(n)`.
-/
theorem survivorCount_le_mul_sqPairCount (n : ℕ) [NeZero n] :
    survivorCount n ≤ Fintype.card (ZMod n) * sqPairCount n := by
  -- The set of survivors is a subset of the set of triples (a,b,c) where a²+b² is a square (the first of four conditions).
  have h_survivors_subset : (Finset.univ (α := ZMod n × ZMod n × ZMod n)).filter (fun x => IsCuboidSurvivor n x.1 x.2.1 x.2.2) ⊆ Finset.image (fun (t : ZMod n × ZMod n × ZMod n) => (t.1, t.2.1, t.2.2)) ((Finset.univ (α := ZMod n × ZMod n × ZMod n)).filter (fun t => IsSquare (t.1 ^ 2 + t.2.1 ^ 2))) := by
    intro x hx; unfold IsCuboidSurvivor at hx; aesop;
  refine le_trans ( Finset.card_le_card h_survivors_subset ) ?_;
  simp +zetaDelta at *;
  rw [ show ( Finset.filter ( fun t : ZMod n × ZMod n × ZMod n => IsSquare ( t.1 ^ 2 + t.2.1 ^ 2 ) ) Finset.univ ) = Finset.biUnion ( Finset.univ.filter ( fun t : ZMod n × ZMod n => IsSquare ( t.1 ^ 2 + t.2 ^ 2 ) ) ) fun t => Finset.image ( fun c : ZMod n => ( t.1, t.2, c ) ) Finset.univ from ?_ ];
  · refine' le_trans ( Finset.card_biUnion_le ) _;
    refine' le_trans ( Finset.sum_le_sum fun x hx => Finset.card_image_le ) _ ; simp +decide [ mul_comm, sqPairCount ];
  · ext ⟨a, b, c⟩; simp [Finset.mem_biUnion, Finset.mem_image]

/-
**Pythagorean triple count.** The number of `(x,y,z)` with `x²+y²=z²`
in `(ZMod p)³` equals `p²` for any odd prime `p`.
-/
theorem pythag_triple_count (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2)
    [NeZero p] :
    pythagCount p = p ^ 2 := by
  -- The change of variables φ : (x,y,z) ↦ (x+z, x−z, y) is a bijection on (ZMod p)³ since 2 is invertible (p is odd), with inverse (u,v,w) ↦ ((u+v)/2, w, (u−v)/2). This transforms x²+y²=z² into (x+z)(x-z) = -y², i.e. u·v = -w².
  have h_bij : Function.Bijective (fun (t : ZMod p × ZMod p × ZMod p) => (t.1 + t.2.2, t.1 - t.2.2, t.2.1)) := by
    -- To prove bijectivity, we show that the function is both injective and surjective.
    have h_inj : Function.Injective (fun (t : ZMod p × ZMod p × ZMod p) => (t.1 + t.2.2, t.1 - t.2.2, t.2.1)) := by
      intro t t' h; simp_all +decide [ sub_eq_iff_eq_add, add_eq_zero_iff_eq_neg ] ;
      -- By simplifying, we can see that $t.2.2 = t'.2.2$.
      have h2 : t.2.2 = t'.2.2 := by
        by_contra h_contra;
        exact h_contra ( mul_left_cancel₀ ( show ( 2 : ZMod p ) ≠ 0 from by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| lt_of_le_of_ne hp.1.two_le <| Ne.symm hodd ) <| by linear_combination' h.1 - h.2.1 );
      aesop;
    exact ⟨ h_inj, Finite.injective_iff_surjective.mp h_inj ⟩;
  nontriviality;
  -- So pythagCount p = #{(u,v,w) ∈ (ZMod p)³ : u·v = -w²}.
  have h_count : pythagCount p = Finset.card (Finset.filter (fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2) (Finset.univ : Finset (ZMod p × ZMod p × ZMod p))) := by
    have h_count : Finset.image (fun t : ZMod p × ZMod p × ZMod p => (t.1 + t.2.2, t.1 - t.2.2, t.2.1)) (Finset.filter (fun t : ZMod p × ZMod p × ZMod p => t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2) (Finset.univ : Finset (ZMod p × ZMod p × ZMod p))) = Finset.filter (fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2) (Finset.univ : Finset (ZMod p × ZMod p × ZMod p)) := by
      ext ⟨u, v, w⟩; simp [h_bij];
      constructor;
      · grind;
      · intro huv
        use (u + v) / 2, (u - v) / 2;
        cases' eq_or_ne ( 2 : ZMod p ) 0 with m m <;> simp_all +decide [ ← sq, ← mul_assoc, ← eq_sub_iff_add_eq' ];
        · rcases p with ( _ | _ | _ | p ) <;> cases m <;> contradiction;
        · grind;
    rw [ ← h_count, Finset.card_image_of_injective _ h_bij.injective ];
    rfl;
  -- Count by cases on w:
  -- - w = 0: u·v = 0, meaning u = 0 or v = 0. Count = p + p - 1 = 2p-1 (by inclusion-exclusion).
  have h_case0 : Finset.card (Finset.filter (fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2 ∧ t.2.2 = 0) (Finset.univ : Finset (ZMod p × ZMod p × ZMod p))) = 2 * p - 1 := by
    rw [ show ( Finset.filter ( fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2 ∧ t.2.2 = 0 ) Finset.univ : Finset _ ) = Finset.image ( fun t : ZMod p × ZMod p => ( t.1, t.2, 0 ) ) ( Finset.filter ( fun t : ZMod p × ZMod p => t.1 * t.2 = 0 ) Finset.univ ) from ?_ ];
    · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
      rw [ show ( Finset.filter ( fun t : ZMod p × ZMod p => t.1 = 0 ∨ t.2 = 0 ) Finset.univ : Finset _ ) = Finset.image ( fun t : ZMod p => ( 0, t ) ) Finset.univ ∪ Finset.image ( fun t : ZMod p => ( t, 0 ) ) Finset.univ from ?_, Finset.card_union ];
      · rw [ Finset.card_image_of_injective, Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
        rw [ show ( image ( fun t : ZMod p => ( 0, t ) ) Finset.univ ∩ image ( fun t : ZMod p => ( t, 0 ) ) Finset.univ : Finset ( ZMod p × ZMod p ) ) = { ( 0, 0 ) } by ext ⟨ x, y ⟩ ; aesop ] ; simp +decide [ two_mul ];
      · ext ⟨x, y⟩; simp [Finset.mem_union, Finset.mem_image];
        tauto;
    · ext ⟨x, y, z⟩; simp [Finset.mem_image];
      by_cases hz : z = 0 <;> simp +decide [ hz ];
      · rw [ eq_comm ];
      · exact ⟨ fun _ => Ne.symm hz, fun _ => Ne.symm hz ⟩;
  -- - w ≠ 0: u·v = -w² ≠ 0, so u ≠ 0, and v = -w²/u. For each w ≠ 0, there are p-1 choices for u ≠ 0. There are p-1 nonzero values of w.
  have h_case1 : Finset.card (Finset.filter (fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2 ∧ t.2.2 ≠ 0) (Finset.univ : Finset (ZMod p × ZMod p × ZMod p))) = (p - 1) * (p - 1) := by
    rw [ show ( Finset.filter ( fun t : ZMod p × ZMod p × ZMod p => t.1 * t.2.1 = -t.2.2 ^ 2 ∧ ¬t.2.2 = 0 ) Finset.univ ) = Finset.biUnion ( Finset.univ.filter ( fun w : ZMod p => w ≠ 0 ) ) ( fun w => Finset.image ( fun u : ZMod p => ( u, -w ^ 2 / u, w ) ) ( Finset.univ.filter ( fun u : ZMod p => u ≠ 0 ) ) ) from ?_, Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ fun a b h => by injection h ] ; simp +decide [ Finset.filter_ne', Finset.card_univ ];
    · grind +suggestions;
    · ext ⟨u, v, w⟩; simp [Finset.mem_biUnion, Finset.mem_image];
      grind;
  convert congr_arg₂ ( · + · ) h_case0 h_case1 using 1;
  · rw [ h_count, ← Finset.card_union_of_disjoint ];
    · exact congr_arg Finset.card ( by ext; by_cases h : ‹ZMod p × ZMod p × ZMod p›.2.2 = 0 <;> simp +decide [ h ] );
    · exact Finset.disjoint_filter.mpr ( by aesop );
  · zify;
    grind

/-
`zeroPairCount(p) ≤ 2p − 1` for odd primes.
-/
theorem zeroPairCount_le (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2)
    [NeZero p] :
    zeroPairCount p ≤ 2 * p - 1 := by
  -- For each $a \neq 0$, $b^2 = -a^2$ has exactly 2 solutions.
  have h_b_solutions : ∀ a : ZMod p, a ≠ 0 → Finset.card (Finset.filter (fun b : ZMod p => b^2 = -a^2) Finset.univ) ≤ 2 := by
    intro a ha;
    exact le_trans ( Finset.card_le_card ( show Finset.filter ( fun b : ZMod p => b ^ 2 = -a ^ 2 ) Finset.univ ⊆ ( Polynomial.roots ( Polynomial.X ^ 2 + Polynomial.C ( a ^ 2 ) ) |> Multiset.toFinset ) from fun x hx => Multiset.mem_toFinset.mpr <| Polynomial.mem_roots ( show Polynomial.X ^ 2 + Polynomial.C ( a ^ 2 ) ≠ 0 from by exact ne_of_apply_ne ( fun f => f.coeff 2 ) <| by simp +decide [ Polynomial.coeff_eq_zero_of_natDegree_lt ] ) |>.mpr <| by aesop ) ) <| le_trans ( Multiset.toFinset_card_le _ ) <| le_trans ( Polynomial.card_roots' _ ) <| by erw [ Polynomial.natDegree_X_pow_add_C ] ;
  -- For each $a \neq 0$, there are at most 2 solutions for $b$, and there are $p-1$ such $a$'s.
  have h_total_solutions : ∑ a : ZMod p, Finset.card (Finset.filter (fun b : ZMod p => b^2 = -a^2) Finset.univ) ≤ 2 * (p - 1) + 1 := by
    rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ 0 ) ];
    rw [ add_comm ];
    exact add_le_add ( le_trans ( Finset.sum_le_sum fun x hx => h_b_solutions x <| by simpa using hx ) <| by simp +decide [ Finset.card_sdiff, Finset.card_singleton, Finset.card_univ, mul_comm, hp.1.pos ] ) <| by simp +decide [ Finset.filter_eq', Finset.filter_ne' ] ;
  convert h_total_solutions using 1;
  · simp +decide only [zeroPairCount, card_filter];
    rw [ ← Finset.sum_product' ];
    simp +decide only [eq_neg_iff_add_eq_zero, add_comm];
    rfl;
  · exact Nat.sub_eq_of_eq_add <| by linarith [ Nat.sub_add_cancel hp.1.pos ] ;

/-
**Square-pair count bound.** `2 · sqPairCount(p) ≤ p² + 2p − 1`.
-/
theorem sqPairCount_le (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2)
    [NeZero p] :
    2 * sqPairCount p ≤ p ^ 2 + 2 * p - 1 := by
  -- Sum the identity over all (a,b) pairs.
  have h_sum : ∑ x : ZMod p, ∑ y : ZMod p, (Finset.card (Finset.filter (fun z : ZMod p => z^2 = x^2 + y^2) (Finset.univ : Finset (ZMod p)))) + zeroPairCount p = 2 * sqPairCount p := by
    -- For each pair (a,b), the number of solutions to c² = a² + b² is 0 if a² + b² is not a square, 1 if a² + b² = 0, and 2 if a² + b² is a nonzero square.
    have h_card : ∀ x y : ZMod p, (Finset.card (Finset.filter (fun z : ZMod p => z^2 = x^2 + y^2) (Finset.univ : Finset (ZMod p)))) = if x^2 + y^2 = 0 then 1 else if IsSquare (x^2 + y^2) then 2 else 0 := by
      intro x y; split_ifs <;> simp_all +decide [ isSquare_iff_exists_sq ] ;
      · exact Finset.card_eq_one.mpr ⟨ 0, by aesop ⟩;
      · obtain ⟨ r, hr ⟩ := ‹_›; rw [ show ( Finset.filter ( fun z => z ^ 2 = x ^ 2 + y ^ 2 ) Finset.univ : Finset ( ZMod p ) ) = { r, -r } from ?_ ] ; rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] ; simp +decide [ *, sq_eq_sq_iff_eq_or_eq_neg ] ;
        · rw [ eq_neg_iff_add_eq_zero ] ; contrapose! hodd ; simp_all +decide [ ← two_mul ];
          rcases p with ( _ | _ | _ | p ) <;> cases hodd <;> trivial;
        · grind;
      · grind;
    rw [ show sqPairCount p = ∑ x : ZMod p, ∑ y : ZMod p, if IsSquare ( x ^ 2 + y ^ 2 ) then 1 else 0 from ?_, show zeroPairCount p = ∑ x : ZMod p, ∑ y : ZMod p, if x ^ 2 + y ^ 2 = 0 then 1 else 0 from ?_ ];
    · simp +decide only [h_card, ← sum_add_distrib];
      rw [ Finset.mul_sum _ _ _ ] ; congr ; ext x ; rw [ Finset.mul_sum _ _ _ ] ; congr ; ext y ; split_ifs <;> simp_all +decide ;
    · unfold zeroPairCount;
      rw [ ← Finset.sum_product' ];
      simp +decide [ Finset.sum_ite ];
    · unfold sqPairCount;
      rw [ ← Finset.sum_product' ];
      simp +decide [ Finset.sum_ite ];
  -- From pythag_triple_count: pythagCount p = p².
  have h_pythagCount : (Finset.card (Finset.filter (fun (x, y, z) => z^2 = x^2 + y^2) (Finset.univ : Finset ((ZMod p) × (ZMod p) × (ZMod p))))) = p^2 := by
    convert pythag_triple_count p hodd using 1;
    exact congr_arg Finset.card ( Finset.filter_congr fun x hx => by simp +decide [ eq_comm, add_comm ] );
  -- From zeroPairCount_le: zeroPairCount p ≤ 2p-1.
  have h_zeroPairCount : zeroPairCount p ≤ 2 * p - 1 := by
    convert zeroPairCount_le p hodd;
  -- The sum of the cardinalities of the sets of solutions to $z^2 = x^2 + y^2$ over all $x, y \in \mathbb{Z}/p\mathbb{Z}$ is equal to the cardinality of the set of triples $(x, y, z)$ such that $z^2 = x^2 + y^2$.
  have h_sum_card : ∑ x : ZMod p, ∑ y : ZMod p, (Finset.card (Finset.filter (fun z : ZMod p => z^2 = x^2 + y^2) (Finset.univ : Finset (ZMod p)))) = (Finset.card (Finset.filter (fun (x, y, z) => z^2 = x^2 + y^2) (Finset.univ : Finset ((ZMod p) × (ZMod p) × (ZMod p))))) := by
    simp +decide only [card_filter];
    simp +decide only [← sum_product'];
    rfl;
  grind

/-! ## The uniform gap theorem -/

/-
**Uniform prime density gap (δ = 3/10).** For every odd prime `p`,
`10 · survivorCount(p) ≤ 7 · p³`.
-/
theorem survivorCount_prime_uniform_gap (p : ℕ) [NeZero p]
    (hp : Nat.Prime p) (hodd : p ≠ 2) :
    10 * survivorCount p ≤ 7 * p ^ 3 := by
  have h_p_prime : Fact (Nat.Prime p) := ⟨hp⟩;
  -- Use the structural bound chain:
  have h_bound_chain : 10 * survivorCount p ≤ 5 * p * (p ^ 2 + 2 * p - 1) := by
    have h_bound_chain : 10 * survivorCount p ≤ 10 * p * sqPairCount p := by
      convert Nat.mul_le_mul_left 10 ( survivorCount_le_mul_sqPairCount p ) using 1;
      norm_num [ mul_assoc ];
    exact h_bound_chain.trans ( by nlinarith [ sqPairCount_le p hodd, Nat.sub_add_cancel ( show 1 ≤ p ^ 2 + 2 * p from Nat.succ_le_of_lt ( by nlinarith only [ hp.two_le ] ) ) ] );
  by_cases h_p_le_43 : p ≤ 43;
  · interval_cases p <;> simp_all +decide only;
    grind +suggestions;
    all_goals exact le_trans h_bound_chain ( by decide ) ;
  · exact h_bound_chain.trans ( by nlinarith only [ h_p_le_43, Nat.sub_add_cancel ( by nlinarith : 1 ≤ p ^ 2 + 2 * p ) ] )

/-
**Uniform gap in rational form**: there exists `δ = 3/10 > 0` such that
for every prime `p ≥ 3`, `survivorCount(p)/p³ ≤ 1 − δ`.
-/
theorem survivorCount_prime_uniform_gap_rat :
    ∃ δ : ℚ, 0 < δ ∧
      ∀ p : ℕ, (hp : Nat.Prime p) → 3 ≤ p →
        (@survivorCount p ⟨hp.ne_zero⟩ : ℚ) ≤ (1 - δ) * (p : ℚ) ^ 3 := by
  refine' ⟨ 3 / 10, by norm_num, fun p hp hge => _ ⟩;
  convert survivorCount_prime_uniform_gap p hp ( by linarith ) using 1 ; ring_nf;
  rw [ ← @Nat.cast_le ℚ ] ; push_cast ; ring_nf;
  constructor <;> intro h <;> linarith

end PerfectCuboid