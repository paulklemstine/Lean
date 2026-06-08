/-
# Discriminant Uniformity Theorem for Quadratic Polynomials over Finite Fields

This file establishes the **Discriminant Uniformity Theorem**: for any prime p,
the discriminant map (b, c) ↦ b² - 4c from (ZMod p)² to ZMod p has every fiber
of cardinality exactly p. This uniformity result has deep consequences for the
distribution of quadratic polynomials over finite fields.

## Main Results

* `QuadDisc` — the discriminant of a monic quadratic x² + bx + c
* `disc_fiber_card` — every fiber of the discriminant map has cardinality p
* `separable_quad_count` — the number of separable quadratics is p² - p
* `nonsquare_count` — the number of non-squares in ZMod p for odd primes
* `SplittingType` — classification of quadratic splitting behavior
-/
import Mathlib

open Finset BigOperators

noncomputable section

/-! ## The Discriminant Map -/

/-- The discriminant of the monic quadratic x² + bx + c over a commutative ring. -/
def QuadDisc {R : Type*} [CommRing R] (b c : R) : R := b ^ 2 - 4 * c

/-- The discriminant map from pairs (b,c) to the discriminant b² - 4c. -/
def quadDiscMap (p : ℕ) [NeZero p] : ZMod p × ZMod p → ZMod p :=
  fun ⟨b, c⟩ => QuadDisc b c

/-! ## Fiber Counting -/

/-- The fiber of the discriminant map over a value d. -/
def discFiber (p : ℕ) [NeZero p] (d : ZMod p) : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter (fun ⟨b, c⟩ => QuadDisc b c = d)

/-
For an odd prime p, the element 4 is a unit in ZMod p.
-/
theorem four_isUnit_of_odd_prime (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    IsUnit (4 : ZMod p) := by
      exact IsUnit.mk0 _ ( show ( 4 : ZMod p ) ≠ 0 from by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; intro h; have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial )

/-
Key lemma: for each b and target discriminant d, when p is an odd prime,
    there is exactly one c such that b² - 4c = d.
-/
theorem unique_c_for_disc (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2)
    (b d : ZMod p) : ∃! c : ZMod p, QuadDisc b c = d := by
      refine' ⟨ ( b^2 - d ) / 4, _, _ ⟩ <;> simp_all +decide [ QuadDisc, mul_div_cancel₀ ];
      · rw [ mul_div_cancel₀ ] <;> norm_num;
        erw [ ZMod.natCast_eq_zero_iff ] ; intro H; have := Nat.le_of_dvd ( by decide ) H; interval_cases p <;> trivial;
      · intro y hy; rw [ ← hy, eq_div_iff ] <;> norm_num;
        · ring;
        · erw [ ZMod.natCast_eq_zero_iff ] ; intro H; have := Nat.le_of_dvd ( by decide ) H; interval_cases p <;> trivial;

/-
The fiber of the discriminant map has cardinality p for odd primes.
    Proof: for each b ∈ ZMod p, there is exactly one c with b² - 4c = d
    (since 4 is a unit for odd primes). This gives a bijection
    ZMod p ≃ discFiber p d via b ↦ (b, (b² - d)/4).
-/
theorem disc_fiber_card_odd (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2)
    (d : ZMod p) : (discFiber p d).card = p := by
      -- By definition of `discFiber`, we know that every element in `discFiber p d` can be written as `(b, (b^2 - d) / 4)` for some `b`.
      have h_fiber_eq : ∀ x : ZMod p × ZMod p, x ∈ discFiber p d ↔ ∃ b : ZMod p, x = (b, (b^2 - d) / 4) := by
        intro x
        simp [discFiber, QuadDisc];
        constructor <;> intro h <;> cases' h with b hb;
        · use x.1;
          simp +decide [ mul_div_cancel_left₀, show ( 4 : ZMod p ) ≠ 0 from by { intro h; rcases p with ( _ | _ | _ | _ | _ | p ) <;> cases h <;> trivial } ];
        · rw [ hb ] ; rw [ mul_div_cancel₀ ] ; norm_num ; exact four_isUnit_of_odd_prime p hp |> IsUnit.ne_zero;
      rw [ show discFiber p d = Finset.image ( fun b : ZMod p => ( b, ( b^2 - d ) / 4 ) ) Finset.univ by ext x; aesop ] ; rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ] ;

/-
The fiber of the discriminant map has cardinality 2 for p = 2.
    Over ZMod 2, we have 4 = 0, so b² - 4c = b² = b (since b² = b in char 2).
    For d ∈ ZMod 2, the fiber is {(d, 0), (d, 1)}, which has 2 elements.
-/
theorem disc_fiber_card_two (d : ZMod 2) : (discFiber 2 d).card = 2 := by
  fin_cases d <;> native_decide +revert

/-
**Discriminant Uniformity Theorem**: For any prime p and any element d ∈ ZMod p,
    the number of pairs (b, c) ∈ (ZMod p)² with b² - 4c = d is exactly p.

    This is a fundamental result in the arithmetic of quadratic forms over finite fields.
    It says the discriminant map distributes values perfectly uniformly.
-/
theorem disc_fiber_card (p : ℕ) [Fact (Nat.Prime p)]
    (d : ZMod p) : (discFiber p d).card = p := by
      by_cases h : p ≠ 2 <;> simp_all +decide [ discFiber ];
      · convert disc_fiber_card_odd p h d using 1;
      · subst h; fin_cases d <;> trivial;

/-! ## Separability -/

/-- A monic quadratic x² + bx + c is separable iff its discriminant is nonzero. -/
def quadSeparable {R : Type*} [CommRing R] (b c : R) : Prop :=
  QuadDisc b c ≠ 0

/-- The set of separable quadratic pairs over ZMod p. -/
def separableQuads (p : ℕ) [NeZero p] : Finset (ZMod p × ZMod p) :=
  Finset.univ.filter (fun ⟨b, c⟩ => QuadDisc b c ≠ 0)

/-
The number of separable monic quadratics over ZMod p is p² - p.
    Proof: the inseparable ones are exactly the fiber over 0, which has p elements.
    The total number of pairs is p², so separable count = p² - p.
-/
theorem separable_quad_count (p : ℕ) [Fact (Nat.Prime p)] :
    (separableQuads p).card = p ^ 2 - p := by
      erw [ show separableQuads p = Finset.univ \ discFiber p 0 from ?_, Finset.card_sdiff, Finset.card_univ ] ; simp +decide [ Finset.card_univ, ZMod.card, disc_fiber_card ];
      · ring;
      · unfold separableQuads discFiber; aesop;

/-! ## Quadratic Residues and Irreducibility -/

/-
The number of non-zero squares in ZMod p for an odd prime p is (p-1)/2.
-/
theorem nonzero_square_count (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    (Finset.univ.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x)).card = (p - 1) / 2 := by
      -- The squaring map is 2-to-1 on the unit group, so the image has size (p-1)/2.
      have h_sq_map : Finset.card (Finset.image (fun x : ZMod p => x^2) (Finset.filter (fun x => x ≠ 0) Finset.univ)) = (p - 1) / 2 := by
        have h_sq_map : ∀ x : ZMod p, x ≠ 0 → Finset.card (Finset.filter (fun y : ZMod p => y^2 = x^2) (Finset.filter (fun x => x ≠ 0) Finset.univ)) = 2 := by
          intro x hx_ne; rw [ show Finset.filter ( fun y => y ^ 2 = x ^ 2 ) ( Finset.filter ( fun x => ¬x = 0 ) Finset.univ ) = { x, -x } from ?_ ] ; rw [ Finset.card_insert_of_notMem, Finset.card_singleton ] ; simp +decide [ hx_ne ] ;
          · rw [ eq_neg_iff_add_eq_zero ] ; intro H; simp_all +decide [ ← two_mul ] ;
            rcases p with ( _ | _ | _ | p ) <;> cases H <;> contradiction;
          · grind;
        have h_sq_map : Finset.card (Finset.filter (fun x => x ≠ 0) (Finset.univ : Finset (ZMod p))) = Finset.sum (Finset.image (fun x : ZMod p => x^2) (Finset.filter (fun x => x ≠ 0) Finset.univ)) (fun y => Finset.card (Finset.filter (fun x : ZMod p => x^2 = y) (Finset.filter (fun x => x ≠ 0) Finset.univ))) := by
          rw [ Finset.card_eq_sum_ones, Finset.sum_image' ] ; aesop;
        simp_all +decide [ Finset.sum_const_nat ];
        simp_all +decide [ Finset.filter_ne' ];
      convert h_sq_map using 2;
      ext; simp +decide [ isSquare_iff_exists_sq ] ;
      grind +revert

/-
The number of non-squares in ZMod p for an odd prime p is (p-1)/2.
-/
theorem nonsquare_count (p : ℕ) [Fact (Nat.Prime p)] (hp : p ≠ 2) :
    (Finset.univ.filter (fun x : ZMod p => ¬ IsSquare x)).card = (p - 1) / 2 := by
      rw [ Finset.filter_not, Finset.card_sdiff ] ; norm_num;
      -- The set of squares in ZMod p is {0} {nonzero squares}. The cardinality of {0} is � �1, and the cardinality of {nonzero squares} is (p-1)/2.
      have h_squares : (Finset.univ.filter (fun x : ZMod p => IsSquare x)).card = 1 + (Finset.univ.filter (fun x : ZMod p => x ≠ 0 ∧ IsSquare x)).card := by
        rw [ show ( Finset.filter ( fun x => IsSquare x ) Finset.univ : Finset ( ZMod p ) ) = { 0 } ∪ Finset.filter ( fun x => x ≠ 0 ∧ IsSquare x ) Finset.univ from ?_, Finset.card_union_of_disjoint ] <;> norm_num;
        ext x; by_cases hx : x = 0 <;> simp +decide [ hx ] ;
      rw [ show ( Finset.filter IsSquare Finset.univ : Finset ( ZMod p ) ) = Finset.filter ( fun x => IsSquare x ) Finset.univ from rfl, h_squares, nonzero_square_count p hp ];
      cases Nat.Prime.odd_of_ne_two Fact.out hp ; omega

/-! ## Splitting Type for Quadratics -/

/-- The splitting type of a monic quadratic over a finite field.
    This records how the polynomial factors into irreducibles:
    - `split`: two distinct linear factors (x - a)(x - b)
    - `ramified`: one repeated linear factor (x - a)²
    - `inert`: irreducible quadratic (no roots) -/
inductive QuadSplitType where
  | split : QuadSplitType
  | ramified : QuadSplitType
  | inert : QuadSplitType
  deriving DecidableEq, Repr

/-- Classify a monic quadratic x² + bx + c over ZMod p by its splitting type.
    The classification is determined entirely by the discriminant:
    - zero discriminant → ramified
    - nonzero square discriminant → split
    - non-square discriminant → inert -/
noncomputable def classifyQuad (p : ℕ) [Fact (Nat.Prime p)]
    (b c : ZMod p) : QuadSplitType :=
  if QuadDisc b c = 0 then QuadSplitType.ramified
  else if IsSquare (QuadDisc b c) then QuadSplitType.split
  else QuadSplitType.inert

/-
The number of ramified quadratics over ZMod p is exactly p.
    These are exactly the pairs with zero discriminant, i.e., the fiber over 0.
-/
theorem ramified_count (p : ℕ) [Fact (Nat.Prime p)] :
    (Finset.univ.filter (fun x : ZMod p × ZMod p =>
      classifyQuad p x.1 x.2 = QuadSplitType.ramified)).card = p := by
        convert disc_fiber_card p 0 using 2;
        ext ⟨ b, c ⟩ ; unfold classifyQuad discFiber; aesop;

/-! ## The Frobenius Correspondence for Degree 2

The splitting type of a quadratic over 𝔽_p corresponds to the cycle type of the
Frobenius automorphism acting on its roots:
- split ↔ cycle type [1,1] (identity permutation on 2 elements)
- ramified ↔ degenerate case
- inert ↔ cycle type [2] (transposition)

This is the simplest instance of the Frobenius correspondence. -/

/-- The cycle type partition associated to a quadratic splitting type.
    Split quadratics have two fixed points [1,1], inert quadratics
    have one 2-cycle [2]. -/
def splitTypeToCyclePartition : QuadSplitType → List ℕ
  | QuadSplitType.split => [1, 1]
  | QuadSplitType.ramified => [1, 1]
  | QuadSplitType.inert => [2]

/-- The sum of the cycle type partition is always 2 (the polynomial degree). -/
theorem cycle_partition_sum (st : QuadSplitType) :
    (splitTypeToCyclePartition st).sum = 2 := by
  cases st <;> simp [splitTypeToCyclePartition]

/-! ## The Cubic Discriminant (for future work) -/

/-- The discriminant of a depressed cubic x³ + bx + c. -/
def cubicDisc {R : Type*} [CommRing R] (b c : R) : R :=
  -(4 * b ^ 3 + 27 * c ^ 2)

end