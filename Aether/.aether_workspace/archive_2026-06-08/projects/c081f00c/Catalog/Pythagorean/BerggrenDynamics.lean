import Mathlib

/-!
# Berggren Dynamics: Free Semigroup Action on Primitive Pythagorean Triples

This file develops the Berggren tree as a certified arithmetic dynamical system
on primitive Pythagorean triples, proving preservation, monotonicity,
determinant structure, and injectivity results.

## Main Results

* **Theorem A** (`bergA_preserves_prim` etc.): Each Berggren generator preserves
  the full BerggrenPrimitive predicate.
* **Theorem D** (`det_matA` etc.): Generator matrices have det ∈ {±1}.
* **Theorem E** (`hypotenuse_strict_growth_of_child`): Children have strictly
  larger hypotenuse than parents.
* Forward-inverse cancellation for all generators.
* Generator injectivity and distinctness of children.
* Lorentz form Q(a,b,c) = a²+b²-c² is preserved by all generators.
-/

set_option maxHeartbeats 1600000

/-! ## Core Definitions -/

/-- A triple (a,b,c) is Pythagorean if a² + b² = c². -/
def IsPythTriple (a b c : ℤ) : Prop := a ^ 2 + b ^ 2 = c ^ 2

/-- A Pythagorean triple is primitive if gcd(a, b) = 1. -/
def IsPrimPythTriple (a b c : ℤ) : Prop :=
  IsPythTriple a b c ∧ Int.gcd a b = 1

/-- Full primitivity with all positive coordinates. -/
def IsBerggrenPrim (a b c : ℤ) : Prop :=
  IsPrimPythTriple a b c ∧ 0 < a ∧ 0 < b ∧ 0 < c

/-- Berggren child A. -/
def bergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

/-- Berggren child B. -/
def bergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

/-- Berggren child C. -/
def bergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- Inverse of Berggren A. -/
def invBergA (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)

/-- Inverse of Berggren B. -/
def invBergB (a b c : ℤ) : ℤ × ℤ × ℤ := (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Inverse of Berggren C. -/
def invBergC (a b c : ℤ) : ℤ × ℤ × ℤ := (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-- Lorentz form Q(a,b,c) = a² + b² - c². -/
def lorentzQ (a b c : ℤ) : ℤ := a ^ 2 + b ^ 2 - c ^ 2

/-- The Berggren matrix A. -/
def matA : Matrix (Fin 3) (Fin 3) ℤ := !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- The Berggren matrix B. -/
def matB : Matrix (Fin 3) (Fin 3) ℤ := !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- The Berggren matrix C. -/
def matC : Matrix (Fin 3) (Fin 3) ℤ := !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz metric. -/
def metricQ : Matrix (Fin 3) (Fin 3) ℤ := !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-! ## Section 1: Basic Properties -/

theorem root_is_pythag : IsPythTriple 3 4 5 := by unfold IsPythTriple; norm_num

theorem root_is_prim : IsPrimPythTriple 3 4 5 :=
  ⟨root_is_pythag, by native_decide⟩

theorem root_is_berggren : IsBerggrenPrim 3 4 5 :=
  ⟨root_is_prim, by omega, by omega, by omega⟩

/-- For a positive Pythagorean triple, each leg < hypotenuse. -/
theorem pythag_leg_lt_hyp {a b c : ℤ} (h : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) : a < c ∧ b < c := by
  unfold IsPythTriple at h
  constructor <;> nlinarith [sq_nonneg (c - a), sq_nonneg (c - b)]

/-! ## Section 2: Pythagorean Preservation -/

theorem bergA_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  unfold IsPythTriple bergA at *; nlinarith

theorem bergB_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  unfold IsPythTriple bergB at *; nlinarith

theorem bergC_pyth {a b c : ℤ} (h : IsPythTriple a b c) :
    IsPythTriple (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  unfold IsPythTriple bergC at *; nlinarith

/-! ## Section 3: Lorentz Form Preservation -/

theorem bergA_preserves_Q (a b c : ℤ) :
    lorentzQ (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergA; ring

theorem bergB_preserves_Q (a b c : ℤ) :
    lorentzQ (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergB; ring

theorem bergC_preserves_Q (a b c : ℤ) :
    lorentzQ (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = lorentzQ a b c := by
  unfold lorentzQ bergC; ring

/-! ## Section 4: Determinant Structure (Theorem D) -/

/-- Berggren A has determinant 1 — a proper Lorentz transformation. -/
theorem det_matA : matA.det = 1 := by native_decide

/-- Berggren B has determinant -1 — an improper Lorentz transformation. -/
theorem det_matB : matB.det = -1 := by native_decide

/-- Berggren C has determinant 1 — a proper Lorentz transformation. -/
theorem det_matC : matC.det = 1 := by native_decide

/-- All generators preserve the Lorentz metric: Mᵀ Q M = Q. -/
theorem matA_lorentz : matA.transpose * metricQ * matA = metricQ := by native_decide
theorem matB_lorentz : matB.transpose * metricQ * matB = metricQ := by native_decide
theorem matC_lorentz : matC.transpose * metricQ * matC = metricQ := by native_decide

/-! ## Section 5: Forward-Inverse Cancellation -/

theorem fwd_inv_A (a b c : ℤ) :
    invBergA (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 = (a, b, c) := by
  simp only [bergA, invBergA, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem fwd_inv_B (a b c : ℤ) :
    invBergB (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 = (a, b, c) := by
  simp only [bergB, invBergB, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem fwd_inv_C (a b c : ℤ) :
    invBergC (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 = (a, b, c) := by
  simp only [bergC, invBergC, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_A (a b c : ℤ) :
    bergA (invBergA a b c).1 (invBergA a b c).2.1 (invBergA a b c).2.2 = (a, b, c) := by
  simp only [bergA, invBergA, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_B (a b c : ℤ) :
    bergB (invBergB a b c).1 (invBergB a b c).2.1 (invBergB a b c).2.2 = (a, b, c) := by
  simp only [bergB, invBergB, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

theorem inv_fwd_C (a b c : ℤ) :
    bergC (invBergC a b c).1 (invBergC a b c).2.1 (invBergC a b c).2.2 = (a, b, c) := by
  simp only [bergC, invBergC, Prod.mk.injEq]; exact ⟨by ring, by ring, by ring⟩

/-! ## Section 6: Generator Injectivity -/

theorem bergA_injective : Function.Injective (fun t : ℤ × ℤ × ℤ => bergA t.1 t.2.1 t.2.2) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  have := congr_arg (fun t : ℤ × ℤ × ℤ => invBergA t.1 t.2.1 t.2.2) h
  simp only [fwd_inv_A] at this; exact this

theorem bergB_injective : Function.Injective (fun t : ℤ × ℤ × ℤ => bergB t.1 t.2.1 t.2.2) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  have := congr_arg (fun t : ℤ × ℤ × ℤ => invBergB t.1 t.2.1 t.2.2) h
  simp only [fwd_inv_B] at this; exact this

theorem bergC_injective : Function.Injective (fun t : ℤ × ℤ × ℤ => bergC t.1 t.2.1 t.2.2) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  have := congr_arg (fun t : ℤ × ℤ × ℤ => invBergC t.1 t.2.1 t.2.2) h
  simp only [fwd_inv_C] at this; exact this

/-! ## Section 7: Hypotenuse Strict Growth (Theorem E) -/

theorem bergA_hyp_growth {a b c : ℤ} (ha : 0 < a) (_hac : a < c) (hbc : b < c) :
    c < (bergA a b c).2.2 := by
  unfold bergA; nlinarith

theorem bergB_hyp_growth {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    c < (bergB a b c).2.2 := by
  unfold bergB; nlinarith

theorem bergC_hyp_growth {a b c : ℤ} (hb : 0 < b) (hac : a < c) (_hbc : b < c) :
    c < (bergC a b c).2.2 := by
  unfold bergC; nlinarith

/-- **Theorem E**: Every Berggren child has strictly larger hypotenuse. -/
theorem hypotenuse_strict_growth_of_child {a b c : ℤ}
    (hpyth : IsPythTriple a b c) (ha : 0 < a) (hb : 0 < b) (hc : 0 < c)
    (g : Fin 3) :
    c < (match g with
         | 0 => bergA a b c
         | 1 => bergB a b c
         | 2 => bergC a b c).2.2 := by
  obtain ⟨hac, hbc⟩ := pythag_leg_lt_hyp hpyth ha hb hc
  fin_cases g
  · exact bergA_hyp_growth ha hac hbc
  · exact bergB_hyp_growth ha hb hc
  · exact bergC_hyp_growth hb hac hbc

/-! ## Section 8: Positivity Preservation -/

theorem bergA_pos {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergA a b c).1 ∧ 0 < (bergA a b c).2.1 ∧ 0 < (bergA a b c).2.2 := by
  obtain ⟨hac, hbc⟩ := pythag_leg_lt_hyp hpyth ha hb hc
  unfold bergA; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem bergB_pos {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergB a b c).1 ∧ 0 < (bergB a b c).2.1 ∧ 0 < (bergB a b c).2.2 := by
  unfold bergB; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

theorem bergC_pos {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    0 < (bergC a b c).1 ∧ 0 < (bergC a b c).2.1 ∧ 0 < (bergC a b c).2.2 := by
  obtain ⟨hac, hbc⟩ := pythag_leg_lt_hyp hpyth ha hb hc
  unfold bergC; refine ⟨?_, ?_, ?_⟩ <;> nlinarith

/-! ## Section 9: Primitivity Preservation (Theorem A) -/

/-- If d divides both legs of a Pythagorean triple, d divides the hypotenuse. -/
theorem dvd_hyp_of_dvd_legs {a b c d : ℤ} (h : IsPythTriple a b c)
    (hda : d ∣ a) (hdb : d ∣ b) : d ∣ c := by
  have : d ^ 2 ∣ c ^ 2 := by
    unfold IsPythTriple at h
    exact h ▸ dvd_add (pow_dvd_pow_of_dvd hda 2) (pow_dvd_pow_of_dvd hdb 2)
  exact (Int.pow_dvd_pow_iff (by norm_num : (2 : ℕ) ≠ 0)).mp this

/-
Generator A preserves coprimality of legs.
-/
theorem bergA_prim {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (hgcd : Int.gcd a b = 1) :
    Int.gcd (bergA a b c).1 (bergA a b c).2.1 = 1 := by
  refine' Nat.coprime_of_dvd' _;
  intro k hk hk₁ hk₂; have := Int.natCast_dvd.2 hk₁; have := Int.natCast_dvd.2 hk₂; simp_all +decide [ IsPythTriple ] ;
  -- Since the child is Pythagorean (bergA_pyth), k also divides the child hypotenuse (2a-2b+3c) by dvd_hyp_of_dvd_legs.
  have hk₃ : (k : ℤ) ∣ (bergA a b c).2.2 := by
    have hk₃ : (k : ℤ) ∣ ((bergA a b c).1 ^ 2 + (bergA a b c).2.1 ^ 2) := by
      exact dvd_add ( dvd_pow ‹_› two_ne_zero ) ( dvd_pow ‹_› two_ne_zero );
    have hk₃ : (k : ℤ) ∣ ((bergA a b c).2.2 ^ 2) := by
      convert hk₃ using 1;
      unfold bergA; ring;
      linarith;
    exact Int.Prime.dvd_pow' hk hk₃;
  -- Use the inverse map: a = (a-2b+2c) + 2*(2a-b+2c) - 2*(2a-2b+3c) and b = -2*(a-2b+2c) - (2a-b+2c) + 2*(2a-2b+3c), so k | a and k | b.
  have hk₄ : (k : ℤ) ∣ a := by
    convert dvd_add ( dvd_add ‹ ( k : ℤ ) ∣ a - 2 * b + 2 * c › ( dvd_mul_of_dvd_right ‹ ( k : ℤ ) ∣ 2 * a - b + 2 * c › 2 ) ) ( dvd_neg.mpr ( dvd_mul_of_dvd_right hk₃ 2 ) ) using 1 ; ring!;
    unfold bergA; ring;
  have hk₅ : (k : ℤ) ∣ b := by
    have hk₅ : (k : ℤ) ∣ (-2 * (bergA a b c).1 - (bergA a b c).2.1 + 2 * (bergA a b c).2.2) := by
      exact dvd_add ( dvd_sub ( dvd_mul_of_dvd_right ‹_› _ ) ‹_› ) ( dvd_mul_of_dvd_right ‹_› _ );
    convert hk₅ using 1 ; unfold bergA ; ring;
  exact absurd ( Int.dvd_coe_gcd hk₄ hk₅ ) ( by norm_cast; aesop )

/-
Generator B preserves coprimality of legs.
-/
theorem bergB_prim {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (hgcd : Int.gcd a b = 1) :
    Int.gcd (bergB a b c).1 (bergB a b c).2.1 = 1 := by
  -- Assume there's a prime p dividing both legs of bergB(a,b,c).
  by_contra h
  obtain ⟨p, hp_prime, hp_div_a, hp_div_b⟩ : ∃ p, Nat.Prime p ∧ (p : ℤ) ∣ (bergB a b c).1 ∧ (p : ℤ) ∣ (bergB a b c).2.1 := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h |> fun ⟨ p, hp₁, hp₂, hp₃ ⟩ => ⟨ p, hp₁, Int.natCast_dvd.mpr hp₂, Int.natCast_dvd.mpr hp₃ ⟩;
  -- Since the child is Pythagorean, p | (2a+2b+3c) by dvd_hyp_of_dvd_legs.
  have hp_div_c : (p : ℤ) ∣ (bergB a b c).2.2 := by
    have hp_div_c : (p : ℤ) ∣ ((bergB a b c).1 ^ 2 + (bergB a b c).2.1 ^ 2) := by
      exact dvd_add ( hp_div_a.pow two_ne_zero ) ( hp_div_b.pow two_ne_zero );
    convert Int.Prime.dvd_pow' hp_prime ( show ( p : ℤ ) ∣ ( ( bergB a b c ).2.2 ) ^ 2 from ?_ ) using 1;
    grind +locals;
  -- Since p | a' and p | b' and p | c', p | a and p | b, contradicting gcd(a,b)=1.
  have hp_div_a_b : (p : ℤ) ∣ a ∧ (p : ℤ) ∣ b := by
    simp_all +decide [ bergB ];
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    grind;
  exact Nat.Prime.not_dvd_one hp_prime ( hgcd ▸ Int.natCast_dvd_natCast.mp ( Int.dvd_coe_gcd hp_div_a_b.1 hp_div_a_b.2 ) )

/-
Generator C preserves coprimality of legs.
-/
theorem bergC_prim {a b c : ℤ} (hpyth : IsPythTriple a b c)
    (hgcd : Int.gcd a b = 1) :
    Int.gcd (bergC a b c).1 (bergC a b c).2.1 = 1 := by
  -- Assume there's a prime p dividing both legs of bergC(a,b,c).
  by_contra h
  obtain ⟨p, hp_prime, hp_div⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ (Int.natAbs (-a + 2 * b + 2 * c)) ∧ p ∣ (Int.natAbs (-2 * a + b + 2 * c)) := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h;
  -- By dvd_hyp_of_dvd_legs and bergC_pyth, p | (-2a+2b+3c).
  have hp_div_hyp : p ∣ (Int.natAbs (-2 * a + 2 * b + 3 * c)) := by
    have hp_div_hyp : (-a + 2 * b + 2 * c)^2 + (-2 * a + b + 2 * c)^2 = (-2 * a + 2 * b + 3 * c)^2 := by
      unfold IsPythTriple at hpyth; linarith;
    exact Int.natAbs_dvd_natAbs.mpr ( Int.Prime.dvd_pow' hp_prime <| hp_div_hyp ▸ dvd_add ( dvd_pow ( Int.natCast_dvd.mpr hp_div.1 ) two_ne_zero ) ( dvd_pow ( Int.natCast_dvd.mpr hp_div.2 ) two_ne_zero ) );
  -- Using the inverse: a = -(-a+2b+2c) - 2*(-2a+b+2c) + 2*(-2a+2b+3c) and b = 2*(-a+2b+2c) + (-2a+b+2c) - 2*(-2a+2b+3c).
  have hp_div_a : p ∣ (Int.natAbs a) := by
    simp_all +decide [ ← Int.natCast_dvd_natCast ];
    convert dvd_sub ( dvd_neg.mpr hp_div.1 ) ( dvd_mul_of_dvd_right hp_div.2 2 ) |> dvd_add <| dvd_mul_of_dvd_right hp_div_hyp 2 using 1 ; ring
  have hp_div_b : p ∣ (Int.natAbs b) := by
    simp_all +decide [ ← Int.natCast_dvd_natCast ];
    haveI := Fact.mk hp_prime; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;
    grind;
  exact Nat.Prime.not_dvd_one hp_prime ( hgcd ▸ Nat.dvd_gcd hp_div_a hp_div_b )

/-- **Theorem A (generator A)**: bergA preserves IsBerggrenPrim. -/
theorem bergA_preserves_prim {a b c : ℤ} (h : IsBerggrenPrim a b c) :
    IsBerggrenPrim (bergA a b c).1 (bergA a b c).2.1 (bergA a b c).2.2 := by
  obtain ⟨⟨hpyth, hgcd⟩, ha, hb, hc⟩ := h
  exact ⟨⟨bergA_pyth hpyth, bergA_prim hpyth hgcd⟩, bergA_pos hpyth ha hb hc⟩

/-- **Theorem A (generator B)**: bergB preserves IsBerggrenPrim. -/
theorem bergB_preserves_prim {a b c : ℤ} (h : IsBerggrenPrim a b c) :
    IsBerggrenPrim (bergB a b c).1 (bergB a b c).2.1 (bergB a b c).2.2 := by
  obtain ⟨⟨hpyth, hgcd⟩, ha, hb, hc⟩ := h
  exact ⟨⟨bergB_pyth hpyth, bergB_prim hpyth hgcd⟩, bergB_pos ha hb hc⟩

/-- **Theorem A (generator C)**: bergC preserves IsBerggrenPrim. -/
theorem bergC_preserves_prim {a b c : ℤ} (h : IsBerggrenPrim a b c) :
    IsBerggrenPrim (bergC a b c).1 (bergC a b c).2.1 (bergC a b c).2.2 := by
  obtain ⟨⟨hpyth, hgcd⟩, ha, hb, hc⟩ := h
  exact ⟨⟨bergC_pyth hpyth, bergC_prim hpyth hgcd⟩, bergC_pos hpyth ha hb hc⟩

/-! ## Section 10: Seed Computations -/

theorem bergA_root : bergA 3 4 5 = (5, 12, 13) := by native_decide
theorem bergB_root : bergB 3 4 5 = (21, 20, 29) := by native_decide
theorem bergC_root : bergC 3 4 5 = (15, 8, 17) := by native_decide

theorem invA_root : invBergA 5 12 13 = (3, 4, 5) := by native_decide
theorem invB_root : invBergB 21 20 29 = (3, 4, 5) := by native_decide
theorem invC_root : invBergC 15 8 17 = (3, 4, 5) := by native_decide

/-! ## Section 11: Distinct Generators Give Distinct Children -/

/-- Distinct generators produce distinct children for positive triples. -/
theorem distinct_children {a b c : ℤ} (ha : 0 < a) (hb : 0 < b) (_hc : 0 < c) :
    bergA a b c ≠ bergB a b c ∧
    bergA a b c ≠ bergC a b c ∧
    bergB a b c ≠ bergC a b c := by
  unfold bergA bergB bergC
  refine ⟨?_, ?_, ?_⟩ <;> intro h <;> simp [Prod.ext_iff] at h <;> omega

/-! ## Section 12: Finiteness of Fixed-Hypotenuse Triples -/

/-
For any fixed c, the set of Pythagorean triples with hypotenuse c is finite.
-/
theorem pythag_triples_fixed_hyp_finite (c : ℤ) :
    Set.Finite {p : ℤ × ℤ | p.1 ^ 2 + p.2 ^ 2 = c ^ 2} := by
  exact Set.Finite.subset ( Set.Finite.prod ( Set.finite_Icc ( -|c| ) |c| ) ( Set.finite_Icc ( -|c| ) |c| ) ) fun p hp => ⟨ ⟨ by cases abs_cases c <;> nlinarith [ hp.symm ], by cases abs_cases c <;> nlinarith [ hp.symm ] ⟩, ⟨ by cases abs_cases c <;> nlinarith [ hp.symm ], by cases abs_cases c <;> nlinarith [ hp.symm ] ⟩ ⟩

/-! ## Section 13: Word Injectivity (Theorem C sketch) -/

/-- Berggren alphabet. -/
inductive BerggrenGen | A | B | C
  deriving DecidableEq, Repr

/-- Apply a generator to a triple. -/
def applyGen : BerggrenGen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => bergA a b c
  | .B, (a, b, c) => bergB a b c
  | .C, (a, b, c) => bergC a b c

/-- Apply the inverse of a generator. -/
def applyGenInv : BerggrenGen → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | .A, (a, b, c) => invBergA a b c
  | .B, (a, b, c) => invBergB a b c
  | .C, (a, b, c) => invBergC a b c

/-- Forward-inverse cancellation for any generator. -/
theorem applyGenInv_applyGen (g : BerggrenGen) (t : ℤ × ℤ × ℤ) :
    applyGenInv g (applyGen g t) = t := by
  rcases t with ⟨a, b, c⟩
  cases g <;> simp [applyGen, applyGenInv, fwd_inv_A, fwd_inv_B, fwd_inv_C]

/-- Inverse-forward cancellation for any generator. -/
theorem applyGen_applyGenInv (g : BerggrenGen) (t : ℤ × ℤ × ℤ) :
    applyGen g (applyGenInv g t) = t := by
  rcases t with ⟨a, b, c⟩
  cases g <;> simp [applyGen, applyGenInv, inv_fwd_A, inv_fwd_B, inv_fwd_C]

/-- Each generator acts as a bijection on ℤ³. -/
theorem applyGen_bijective (g : BerggrenGen) : Function.Bijective (applyGen g) := by
  constructor
  · intro x y h
    have := congr_arg (applyGenInv g) h
    rwa [applyGenInv_applyGen, applyGenInv_applyGen] at this
  · intro y
    exact ⟨applyGenInv g y, applyGen_applyGenInv g y⟩

/-- A Berggren word is a list of generators. -/
abbrev BerggrenWord := List BerggrenGen

/-- Apply a word to a triple (first letter acts first). -/
def applyWord : BerggrenWord → ℤ × ℤ × ℤ → ℤ × ℤ × ℤ
  | [], t => t
  | g :: w, t => applyWord w (applyGen g t)

/-- The root triple. -/
def root : ℤ × ℤ × ℤ := (3, 4, 5)

/-- applyWord distributes over append. -/
theorem applyWord_append (w₁ w₂ : BerggrenWord) (t : ℤ × ℤ × ℤ) :
    applyWord (w₁ ++ w₂) t = applyWord w₂ (applyWord w₁ t) := by
  induction w₁ generalizing t with
  | nil => simp [applyWord]
  | cons g w ih => simp [applyWord, ih]

/-- applyWord preserves IsBerggrenPrim. -/
theorem applyWord_preserves_prim (w : BerggrenWord) {t : ℤ × ℤ × ℤ}
    (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) :
    IsBerggrenPrim (applyWord w t).1 (applyWord w t).2.1 (applyWord w t).2.2 := by
  induction w generalizing t with
  | nil => exact ht
  | cons g w ih =>
    simp only [applyWord]
    apply ih
    cases g <;> simp [applyGen]
    · exact bergA_preserves_prim ht
    · exact bergB_preserves_prim ht
    · exact bergC_preserves_prim ht

/-- applyWord of any word applied to root gives a BerggrenPrim triple. -/
theorem applyWord_root_prim (w : BerggrenWord) :
    IsBerggrenPrim (applyWord w root).1 (applyWord w root).2.1 (applyWord w root).2.2 :=
  applyWord_preserves_prim w root_is_berggren

/-- applyWord is injective as a function on triples. -/
theorem applyWord_injective (w : BerggrenWord) : Function.Injective (applyWord w) := by
  induction w with
  | nil => exact Function.injective_id
  | cons g w ih =>
    simp only [applyWord]
    exact ih.comp (applyGen_bijective g).injective

/-
Distinct generators give distinct results on BerggrenPrim triples.
-/
theorem applyGen_distinct_on_prim {g₁ g₂ : BerggrenGen} (hne : g₁ ≠ g₂)
    {t : ℤ × ℤ × ℤ} (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) :
    applyGen g₁ t ≠ applyGen g₂ t := by
  rcases g₁ with ( _ | _ | _ ) <;> rcases g₂ with ( _ | _ | _ ) <;> simp +decide at hne ⊢;
  all_goals unfold applyGen; simp +decide [ bergA, bergB, bergC ];
  all_goals intro h₁ h₂; linarith [ ht.2.1, ht.2.2.1, ht.2.2.2 ] ;

/-
A single generator strictly increases the hypotenuse.
-/
theorem applyGen_hyp_growth {t : ℤ × ℤ × ℤ}
    (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) (g : BerggrenGen) :
    t.2.2 < (applyGen g t).2.2 := by
  rcases g with ( _ | _ | _ ) <;> simp_all +decide [ applyGen ];
  · exact bergA_hyp_growth ( ht.2.1 ) ( pythag_leg_lt_hyp ht.1.1 ht.2.1 ht.2.2.1 ht.2.2.2 |>.1 ) ( pythag_leg_lt_hyp ht.1.1 ht.2.1 ht.2.2.1 ht.2.2.2 |>.2 );
  · exact bergB_hyp_growth ht.2.1 ht.2.2.1 ht.2.2.2;
  · rcases ht with ⟨ ⟨ h₁, h₂ ⟩, h₃, h₄, h₅ ⟩;
    exact bergC_hyp_growth h₄ ( pythag_leg_lt_hyp h₁ h₃ h₄ h₅ |>.1 ) ( pythag_leg_lt_hyp h₁ h₃ h₄ h₅ |>.2 )

/-
The hypotenuse is weakly increasing under any word on BerggrenPrim triples.
-/
theorem applyWord_hyp_nondecreasing (w : BerggrenWord) {t : ℤ × ℤ × ℤ}
    (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) :
    t.2.2 ≤ (applyWord w t).2.2 := by
  induction' w using List.reverseRecOn with w g ih;
  · rfl;
  · rw [ applyWord_append ];
    exact le_trans ih ( le_of_lt ( applyGen_hyp_growth ( applyWord_preserves_prim w ht ) g ) )

/-
A non-empty word strictly increases the hypotenuse on BerggrenPrim triples.
-/
theorem applyWord_cons_hyp_growth (g : BerggrenGen) (w : BerggrenWord)
    {t : ℤ × ℤ × ℤ} (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) :
    t.2.2 < (applyWord (g :: w) t).2.2 := by
  -- By definition of applyWord, we have applyWord (g :: w) t = applyWord w (applyGen g t).
  have h_applyWord : applyWord (g :: w) t = applyWord w (applyGen g t) := by
    rfl;
  exact h_applyWord.symm ▸ lt_of_lt_of_le ( applyGen_hyp_growth ht g ) ( applyWord_hyp_nondecreasing _ ( by cases g <;> [ exact bergA_preserves_prim ht; exact bergB_preserves_prim ht; exact bergC_preserves_prim ht ] ) )

/-
Strong injectivity: for any BerggrenPrim triple, the word action is injective.
-/
theorem applyWord_injective_on_prim {t : ℤ × ℤ × ℤ}
    (ht : IsBerggrenPrim t.1 t.2.1 t.2.2) :
    Function.Injective (fun w : BerggrenWord => applyWord w t) := by
  intro w w' h_eq
  by_contra h_neq;
  induction' w using List.reverseRecOn with w₁ g₁ ih generalizing w' <;> induction' w' using List.reverseRecOn with w₂ g₂ ih' <;> simp_all +decide [ Function.Injective.eq_iff ];
  · -- Apply the growth property to the assumption.
    have h_growth : t.2.2 < (applyWord (w₂ ++ [g₂]) t).2.2 := by
      have h_growth : ∀ w : BerggrenWord, w ≠ [] → t.2.2 < (applyWord w t).2.2 := by
        intro w hw_nonempty
        induction' w with g w ih generalizing t <;> simp_all +decide [ Function.Injective.eq_iff ];
        exact applyWord_cons_hyp_growth g w ht;
      exact h_growth _ ( by simp +decide );
    exact h_growth.ne ( by rw [ ← h_eq ] ; rfl );
  · have h_hyp : ∀ w : BerggrenWord, ∀ t : ℤ × ℤ × ℤ, IsBerggrenPrim t.1 t.2.1 t.2.2 → t.2.2 ≤ (applyWord w t).2.2 := by
      -- Apply the hypothesis `h_hyp` directly to conclude the proof.
      apply applyWord_hyp_nondecreasing;
    have h_hyp : (applyWord (w₁ ++ [g₁]) t).2.2 > t.2.2 := by
      have h_hyp : ∀ w : BerggrenWord, ∀ t : ℤ × ℤ × ℤ, IsBerggrenPrim t.1 t.2.1 t.2.2 → w ≠ [] → t.2.2 < (applyWord w t).2.2 := by
        intros w t ht hw_nonempty
        induction' w with g w ih generalizing t <;> simp_all +decide [ Function.Injective.eq_iff ];
        exact applyWord_cons_hyp_growth g w ht;
      exact h_hyp _ _ ht ( by simp +decide );
    grind +locals;
  · -- By the properties of the generators and the induction hypothesis, we can simplify the equation to $g₁ (applyWord w₁ t) = g₂ (applyWord w₂ t)$.
    have h_simp : applyGen g₁ (applyWord w₁ t) = applyGen g₂ (applyWord w₂ t) := by
      convert h_eq using 1 <;> simp +decide [ applyWord_append ];
      · rfl;
      · rfl;
    -- By the properties of the generators and the induction hypothesis, we can simplify the equation to $g₁ (applyWord w₁ t) = g₂ (applyWord w₂ t)$, which implies $g₁ = g₂$.
    have h_gen_eq : g₁ = g₂ := by
      have h_gen_eq : ∀ (g₁ g₂ : BerggrenGen) (t₁ t₂ : ℤ × ℤ × ℤ), IsBerggrenPrim t₁.1 t₁.2.1 t₁.2.2 → IsBerggrenPrim t₂.1 t₂.2.1 t₂.2.2 → applyGen g₁ t₁ = applyGen g₂ t₂ → g₁ = g₂ := by
        intros g₁ g₂ t₁ t₂ ht₁ ht₂ h_eq
        have h_inv : applyGenInv g₁ (applyGen g₁ t₁) = t₁ ∧ applyGenInv g₂ (applyGen g₂ t₂) = t₂ := by
          exact ⟨ applyGenInv_applyGen g₁ t₁, applyGenInv_applyGen g₂ t₂ ⟩;
        rcases g₁ with ( _ | _ | _ ) <;> rcases g₂ with ( _ | _ | _ ) <;> simp +decide [ * ] at h_eq h_inv ⊢;
        all_goals unfold applyGen at h_eq; unfold applyGenInv at h_inv; simp +decide [ bergA, bergB, bergC, invBergA, invBergB, invBergC ] at h_eq h_inv ⊢;
        all_goals unfold applyGen at h_inv; simp +decide [ bergA, bergB, bergC ] at h_inv ⊢;
        all_goals unfold IsBerggrenPrim at *; simp +decide [ IsPrimPythTriple ] at *;
        all_goals unfold IsPythTriple at *; simp +decide [ Prod.ext_iff ] at *; omega;
      exact h_gen_eq g₁ g₂ _ _ ( applyWord_preserves_prim w₁ ht ) ( applyWord_preserves_prim w₂ ht ) h_simp;
    have h_apply_eq : applyWord w₁ t = applyWord w₂ t := by
      exact applyGen_bijective g₁ |>.injective ( by aesop );
    exact h_neq ( ih h_apply_eq ) h_gen_eq

/-- **Theorem C**: Distinct words yield distinct triples from root. -/
theorem berggren_word_injective_on_root :
    Function.Injective (fun w : BerggrenWord => applyWord w root) :=
  applyWord_injective_on_prim root_is_berggren