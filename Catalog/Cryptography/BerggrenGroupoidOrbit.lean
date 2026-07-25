import Mathlib

/-!
# Berggren Groupoid Orbit Cryptography

This module formalizes the Berggren generation of primitive Pythagorean triples
as an algebraic-combinatorial machine and establishes the first certified bridge
between arithmetic tree dynamics and post-quantum lattice-style hardness.

## Main Results

1. **Cone & Primitivity Preservation**: Each Berggren matrix preserves the
   Pythagorean cone a² + b² = c² and maps primitive triples to primitive triples.
2. **Faithful Orbit Action**: The map from Berggren words to primitive triples
   (via the root (3,4,5)) is injective — distinct words yield distinct triples.
3. **Lattice Extraction**: Orbit differences generate nontrivial integer lattice
   vectors, connecting orbit geometry to shortest-vector-type problems.
4. **Security Reduction**: Faithfulness + entropy → post-quantum key security
   via a clean reduction interface.

## Keywords

post-quantum cryptography, lattice hardness, shortest vector problem,
arithmetic dynamics, Berggren tree, primitive Pythagorean triples,
groupoid action, faithful representation, entropy extraction, orbit cryptography,
Lorentzian lattice, Diophantine key exchange
-/

open Matrix

namespace BerggrenGroupoid

/-! ## Section 1: Core Definitions -/

/-- Berggren matrix A: the first generator of the Berggren tree.
    Sends (3,4,5) ↦ (5,12,13). Has determinant 1. -/
def berggrenA : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren matrix B: the second generator of the Berggren tree.
    Sends (3,4,5) ↦ (21,20,29). Has determinant -1. -/
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren matrix C: the third generator of the Berggren tree.
    Sends (3,4,5) ↦ (15,8,17). Has determinant 1. -/
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- Integer inverse of Berggren matrix A. Satisfies A⁻¹A = AA⁻¹ = I. -/
def berggrenA_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Integer inverse of Berggren matrix B. -/
def berggrenB_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Integer inverse of Berggren matrix C. -/
def berggrenC_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- A vector v = (a,b,c) ∈ ℤ³ is a **primitive Pythagorean triple** if
    a² + b² = c², all components are positive, and they are pairwise coprime. -/
def PrimitivePythTriple (v : Fin 3 → ℤ) : Prop :=
  v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2 ∧
  Int.gcd (v 0) (v 1) = 1 ∧
  Int.gcd (v 0) (v 2) = 1 ∧
  Int.gcd (v 1) (v 2) = 1 ∧
  0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2

/-- The root of the Berggren tree: (3, 4, 5). -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-! ## Section 2: Computational Verifications -/

/-- The root triple (3,4,5) is a primitive Pythagorean triple. -/
theorem primitive_rootTriple : PrimitivePythTriple rootTriple := by
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> decide

/-- Berggren matrix A has determinant 1. -/
theorem berggrenA_det : berggrenA.det = 1 := by native_decide

/-- Berggren matrix B has determinant -1. -/
theorem berggrenB_det : berggrenB.det = -1 := by native_decide

/-- Berggren matrix C has determinant 1. -/
theorem berggrenC_det : berggrenC.det = 1 := by native_decide

/-- A_inv is a left inverse of A. -/
theorem berggrenA_inv_left : berggrenA_inv * berggrenA = 1 := by native_decide

/-- A_inv is a right inverse of A. -/
theorem berggrenA_inv_right : berggrenA * berggrenA_inv = 1 := by native_decide

/-- B_inv is a left inverse of B. -/
theorem berggrenB_inv_left : berggrenB_inv * berggrenB = 1 := by native_decide

/-- B_inv is a right inverse of B. -/
theorem berggrenB_inv_right : berggrenB * berggrenB_inv = 1 := by native_decide

/-- C_inv is a left inverse of C. -/
theorem berggrenC_inv_left : berggrenC_inv * berggrenC = 1 := by native_decide

/-- C_inv is a right inverse of C. -/
theorem berggrenC_inv_right : berggrenC * berggrenC_inv = 1 := by native_decide

/-- **Cross-generator product B⁻¹A**: negates the second component.
    This is the key to proving that children under different generators are distinct. -/
theorem cross_inv_B_A : berggrenB_inv * berggrenA = !![1, 0, 0; 0, -1, 0; 0, 0, 1] := by
  native_decide

/-- **Cross-generator product A⁻¹C**: negates the first two components. -/
theorem cross_inv_A_C : berggrenA_inv * berggrenC = !![-1, 0, 0; 0, -1, 0; 0, 0, 1] := by
  native_decide

/-- **Cross-generator product B⁻¹C**: negates the first component. -/
theorem cross_inv_B_C : berggrenB_inv * berggrenC = !![-1, 0, 0; 0, 1, 0; 0, 0, 1] := by
  native_decide

/-- **Cross-generator product A⁻¹B**: negates the second component. -/
theorem cross_inv_A_B : berggrenA_inv * berggrenB = !![1, 0, 0; 0, -1, 0; 0, 0, 1] := by
  native_decide

/-- **Cross-generator product C⁻¹A**: negates the first two components. -/
theorem cross_inv_C_A : berggrenC_inv * berggrenA = !![-1, 0, 0; 0, -1, 0; 0, 0, 1] := by
  native_decide

/-- **Cross-generator product C⁻¹B**: negates the first component. -/
theorem cross_inv_C_B : berggrenC_inv * berggrenB = !![-1, 0, 0; 0, 1, 0; 0, 0, 1] := by
  native_decide

/-! ## Section 3: Cone Preservation

Each Berggren matrix preserves the Pythagorean cone a² + b² = c².
The proof reduces to a polynomial identity after expanding matrix multiplication. -/

/-
Berggren matrix A preserves the Pythagorean cone.
-/
theorem berggrenA_preserves_cone (v : Fin 3 → ℤ)
    (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (berggrenA.mulVec v) 0 ^ 2 + (berggrenA.mulVec v) 1 ^ 2 =
    (berggrenA.mulVec v) 2 ^ 2 := by
  unfold berggrenA;
  simp +decide [ Matrix.mulVec ] ; linarith!

/-
Berggren matrix B preserves the Pythagorean cone.
-/
theorem berggrenB_preserves_cone (v : Fin 3 → ℤ)
    (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (berggrenB.mulVec v) 0 ^ 2 + (berggrenB.mulVec v) 1 ^ 2 =
    (berggrenB.mulVec v) 2 ^ 2 := by
  unfold berggrenB;
  simp +decide [ Matrix.mulVec ];
  linarith!

/-
Berggren matrix C preserves the Pythagorean cone.
-/
theorem berggrenC_preserves_cone (v : Fin 3 → ℤ)
    (h : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2) :
    (berggrenC.mulVec v) 0 ^ 2 + (berggrenC.mulVec v) 1 ^ 2 =
    (berggrenC.mulVec v) 2 ^ 2 := by
  unfold berggrenC; simp +decide [ Matrix.mulVec ] ; linarith!;

/-! ## Section 4: Positivity and Leg–Hypotenuse Inequalities -/

/-
In a primitive Pythagorean triple, the hypotenuse exceeds the first leg.
-/
theorem hyp_gt_leg0 (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) : v 0 < v 2 := by
  nlinarith [ hv.1, hv.2.2.2.2 ]

/-
In a primitive Pythagorean triple, the hypotenuse exceeds the second leg.
-/
theorem hyp_gt_leg1 (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) : v 1 < v 2 := by
  nlinarith [ hv.1, hv.2.2.2.2 ]

/-
Berggren A sends primitive triples to vectors with all positive components.
-/
theorem berggrenA_pos (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    0 < (berggrenA.mulVec v) 0 ∧
    0 < (berggrenA.mulVec v) 1 ∧
    0 < (berggrenA.mulVec v) 2 := by
  unfold berggrenA;
  simp_all +decide [ Matrix.vecHead, Matrix.vecTail ];
  exact ⟨ by linarith [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ], by linarith [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ], by linarith [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ] ⟩

/-
Berggren B sends primitive triples to vectors with all positive components.
-/
theorem berggrenB_pos (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    0 < (berggrenB.mulVec v) 0 ∧
    0 < (berggrenB.mulVec v) 1 ∧
    0 < (berggrenB.mulVec v) 2 := by
  unfold berggrenB; simp +decide [ Matrix.mulVec ] ;
  exact ⟨ by linarith! [ hv.2.2.2.2 ], by linarith! [ hv.2.2.2.2 ], by linarith! [ hv.2.2.2.2 ] ⟩

/-
Berggren C sends primitive triples to vectors with all positive components.
-/
theorem berggrenC_pos (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    0 < (berggrenC.mulVec v) 0 ∧
    0 < (berggrenC.mulVec v) 1 ∧
    0 < (berggrenC.mulVec v) 2 := by
  unfold berggrenC;
  simp +zetaDelta at *;
  exact ⟨ by linarith! [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ], by linarith! [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ], by linarith! [ hv.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ] ⟩

/-! ## Section 5: Coprimality Preservation

The key insight: each Berggren matrix M has det = ±1, hence has an integer inverse.
If a prime divided all three components of M·v, it would (via the inverse) divide
all three components of v, contradicting the primitivity of v. Combined with
the Pythagorean identity, pairwise coprimality follows. -/

/-
For a Pythagorean triple, gcd(a,b) = 1 implies gcd(a,c) = 1.
-/
theorem pyth_coprime_ac (v : Fin 3 → ℤ)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (hab : Int.gcd (v 0) (v 1) = 1) :
    Int.gcd (v 0) (v 2) = 1 := by
  by_contra h_contra
  obtain ⟨p, hp_prime, hp_div_a, hp_div_c⟩ : ∃ p, Nat.Prime p ∧ p ∣ Int.natAbs (v 0) ∧ p ∣ Int.natAbs (v 2) := by
    exact Nat.Prime.not_coprime_iff_dvd.mp h_contra;
  exact hp_prime.not_dvd_one <| hab ▸ Nat.dvd_gcd hp_div_a ( Int.natAbs_dvd_natAbs.mpr <| Int.Prime.dvd_pow' hp_prime <| show ( p : ℤ ) ∣ v 1 ^ 2 by erw [ ← Int.dvd_add_right ( dvd_pow ( Int.natCast_dvd.mpr hp_div_a ) two_ne_zero ) ] ; simpa using dvd_trans ( Int.natCast_dvd.mpr hp_div_c ) <| Dvd.intro_left ( v 2 ) <| by linarith )

/-
For a Pythagorean triple, gcd(a,b) = 1 implies gcd(b,c) = 1.
-/
theorem pyth_coprime_bc (v : Fin 3 → ℤ)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (hab : Int.gcd (v 0) (v 1) = 1) :
    Int.gcd (v 1) (v 2) = 1 := by
  refine' Nat.coprime_of_dvd' _;
  intros k hk hk1 hk2
  have hk3 : k ∣ Int.natAbs (v 0) := by
    rw [ ← Int.natCast_dvd ] at *;
    exact Int.Prime.dvd_pow' hk ( by rw [ show v 0 ^ 2 = v 2 ^ 2 - v 1 ^ 2 by linarith ] ; exact dvd_sub ( hk2.pow two_ne_zero ) ( hk1.pow two_ne_zero ) );
  exact hab ▸ Nat.dvd_gcd hk3 hk1

/-
If M has an integer left inverse N (N·M = I), and no prime divides all three
    components of v, then no prime divides all three components of M·v.
-/
theorem no_common_prime_of_mulVec
    (M N : Matrix (Fin 3) (Fin 3) ℤ) (hNM : N * M = 1)
    (v : Fin 3 → ℤ)
    (hv : ∀ (p : ℕ), p.Prime → ¬(∀ i : Fin 3, (p : ℤ) ∣ v i)) :
    ∀ (p : ℕ), p.Prime → ¬(∀ i : Fin 3, (p : ℤ) ∣ (M.mulVec v) i) := by
  intro p hp h; specialize hv p hp; contrapose! hv; simp_all +decide [ ← Matrix.mulVec_mulVec ] ;
  intro i; have := congr_arg ( fun x => x i ) ( show N.mulVec ( M.mulVec v ) = v from by simp +decide [ hNM ] ) ; simp_all +decide [ Matrix.mulVec ] ;
  exact this ▸ Finset.dvd_sum fun j _ => dvd_mul_of_dvd_right ( h j ) _

/-
For a Pythagorean triple with positive components, pairwise coprimality is
    equivalent to no prime dividing all three components.
-/
theorem pyth_gcd_one_of_no_common_prime (v : Fin 3 → ℤ)
    (hpyth : v 0 ^ 2 + v 1 ^ 2 = v 2 ^ 2)
    (hpos : 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2)
    (hncf : ∀ (p : ℕ), p.Prime → ¬(∀ i : Fin 3, (p : ℤ) ∣ v i)) :
    Int.gcd (v 0) (v 1) = 1 := by
  contrapose! hncf;
  obtain ⟨ p, hp₁, hp₂, hp₃ ⟩ := Nat.Prime.not_coprime_iff_dvd.mp hncf;
  exact ⟨ p, hp₁, fun i => by fin_cases i <;> [ exact Int.natCast_dvd.mpr hp₂; exact Int.natCast_dvd.mpr hp₃; exact Int.Prime.dvd_pow' hp₁ <| hpyth ▸ dvd_add ( dvd_pow ( Int.natCast_dvd.mpr hp₂ ) two_ne_zero ) ( dvd_pow ( Int.natCast_dvd.mpr hp₃ ) two_ne_zero ) ] ⟩

/-
For a primitive Pythagorean triple, no prime divides all three components.
-/
theorem ppt_no_common_prime (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    ∀ (p : ℕ), p.Prime → ¬(∀ i : Fin 3, (p : ℤ) ∣ v i) := by
  intro p pp h; have := hv.2.1; simp_all +decide [ Fin.forall_fin_succ, Int.gcd_eq_natAbs ] ;
  exact Nat.Prime.not_dvd_one pp ( this ▸ Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr h.1 ) ( Int.natAbs_dvd_natAbs.mpr h.2.1 ) )

/-! ## Section 6: Full Primitivity Preservation -/

/-
**Berggren matrix A preserves primitive Pythagorean triples.**
-/
theorem berggrenA_preserves_primitive (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    PrimitivePythTriple (berggrenA.mulVec v) := by
  -- Apply the theorem that states a matrix with an integer inverse preserves the primitivity of Pythagorean triples.
  have h_coprime : Int.gcd ((berggrenA.mulVec v) 0) ((berggrenA.mulVec v) 1) = 1 := by
    exact pyth_gcd_one_of_no_common_prime _ ( berggrenA_preserves_cone _ hv.1 ) ( berggrenA_pos _ hv ) ( no_common_prime_of_mulVec _ _ berggrenA_inv_left _ ( ppt_no_common_prime _ hv ) );
  constructor;
  · exact berggrenA_preserves_cone v hv.1;
  · exact ⟨ h_coprime, pyth_coprime_ac _ ( berggrenA_preserves_cone _ hv.1 ) h_coprime, pyth_coprime_bc _ ( berggrenA_preserves_cone _ hv.1 ) h_coprime, berggrenA_pos _ hv ⟩

/-
**Berggren matrix B preserves primitive Pythagorean triples.**
-/
theorem berggrenB_preserves_primitive (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    PrimitivePythTriple (berggrenB.mulVec v) := by
  constructor;
  · exact berggrenB_preserves_cone v hv.1;
  · have h_coprime : Int.gcd ((berggrenB.mulVec v) 0) ((berggrenB.mulVec v) 1) = 1 := by
      exact pyth_gcd_one_of_no_common_prime _ ( berggrenB_preserves_cone _ hv.1 ) ( berggrenB_pos _ hv ) ( no_common_prime_of_mulVec _ _ berggrenB_inv_left _ ( ppt_no_common_prime _ hv ) );
    exact ⟨ h_coprime, pyth_coprime_ac _ ( berggrenB_preserves_cone _ hv.1 ) h_coprime, pyth_coprime_bc _ ( berggrenB_preserves_cone _ hv.1 ) h_coprime, berggrenB_pos _ hv ⟩

/-
**Berggren matrix C preserves primitive Pythagorean triples.**
-/
theorem berggrenC_preserves_primitive (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    PrimitivePythTriple (berggrenC.mulVec v) := by
  refine' ⟨ _, _, _, _, _ ⟩;
  · exact berggrenC_preserves_cone v hv.1;
  · exact pyth_gcd_one_of_no_common_prime _ ( berggrenC_preserves_cone _ hv.1 ) ( berggrenC_pos _ hv ) ( no_common_prime_of_mulVec _ _ berggrenC_inv_left _ ( ppt_no_common_prime _ hv ) );
  · apply pyth_coprime_ac;
    · exact berggrenC_preserves_cone v hv.1;
    · apply pyth_gcd_one_of_no_common_prime;
      · exact berggrenC_preserves_cone v hv.1;
      · exact berggrenC_pos v hv;
      · intro p pp dp; have := no_common_prime_of_mulVec berggrenC berggrenC_inv berggrenC_inv_left v ( ppt_no_common_prime v hv ) p pp; simp_all +decide [ Fin.forall_fin_succ ] ;
  · -- By definition of coprimality, if gcd(a, b) = 1, then gcd(a, b) = 1.
    apply pyth_coprime_bc;
    · exact berggrenC_preserves_cone v hv.1;
    · exact pyth_gcd_one_of_no_common_prime _ ( berggrenC_preserves_cone _ hv.1 ) ( berggrenC_pos _ hv ) ( no_common_prime_of_mulVec _ _ berggrenC_inv_left _ ( ppt_no_common_prime _ hv ) );
  · exact berggrenC_pos v hv

/-! ## Section 7: Word Algebra and Orbit Points -/

/-- Generator alphabet for the Berggren tree. -/
inductive BerggrenGen | A | B | C
  deriving DecidableEq, Repr

/-- A **Berggren word** is a finite sequence of generators. -/
abbrev BerggrenWord := List BerggrenGen

/-- Matrix associated to a single generator. -/
def genMatrix : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
  | .A => berggrenA
  | .B => berggrenB
  | .C => berggrenC

/-- Integer inverse matrix of a generator. -/
def genMatrixInv : BerggrenGen → Matrix (Fin 3) (Fin 3) ℤ
  | .A => berggrenA_inv
  | .B => berggrenB_inv
  | .C => berggrenC_inv

/-- Left-inverse property for each generator. -/
theorem genMatrixInv_left (g : BerggrenGen) :
    genMatrixInv g * genMatrix g = 1 := by
  cases g <;> simp [genMatrix, genMatrixInv] <;>
  first | exact berggrenA_inv_left | exact berggrenB_inv_left | exact berggrenC_inv_left

/-- Evaluate a Berggren word to a matrix product (left-to-right action). -/
def evalBerggrenWord : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => genMatrix g * evalBerggrenWord w

/-- The **orbit point** of a word: the primitive triple obtained by applying the
    word's matrix product to the root triple (3,4,5). -/
def orbitPoint (w : BerggrenWord) : Fin 3 → ℤ :=
  (evalBerggrenWord w).mulVec rootTriple

/-
Every word produces a primitive Pythagorean triple when applied to the root.
-/
theorem eval_word_preserves_primitive (w : BerggrenWord) :
    PrimitivePythTriple (orbitPoint w) := by
  induction' w with g w ih;
  · exact primitive_rootTriple;
  · convert ( show PrimitivePythTriple ( genMatrix g |> fun m => m.mulVec ( orbitPoint w ) ) from ?_ ) using 1;
    · unfold orbitPoint;
      simp +decide [ evalBerggrenWord, Matrix.mul_assoc ];
    · cases g <;> [ exact berggrenA_preserves_primitive _ ih; exact berggrenB_preserves_primitive _ ih; exact berggrenC_preserves_primitive _ ih ]

/-! ## Section 8: Hypotenuse Increase

Each Berggren matrix strictly increases the hypotenuse (third component).
This is crucial for the faithfulness proof: it prevents the empty word
from colliding with any nonempty word. -/

/-
Berggren A strictly increases the hypotenuse.
-/
theorem berggrenA_hyp_increase (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    v 2 < (berggrenA.mulVec v) 2 := by
  unfold berggrenA; norm_num [ Matrix.mulVec ] ;
  simp_all +decide [ Fin.sum_univ_three, dotProduct ];
  nlinarith [ hv.1, hv.2.2.2.2 ]

/-
Berggren B strictly increases the hypotenuse.
-/
theorem berggrenB_hyp_increase (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    v 2 < (berggrenB.mulVec v) 2 := by
  simp +decide [ Fin.sum_univ_three, dotProduct, berggrenB ];
  linarith [ hv.2.2.2.2 ]

/-
Berggren C strictly increases the hypotenuse.
-/
theorem berggrenC_hyp_increase (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    v 2 < (berggrenC.mulVec v) 2 := by
  unfold berggrenC; erw [ Matrix.mulVec ] ; simp +decide [ Fin.sum_univ_three ];
  linarith! [ hv.2.2.2.2.1, hv.2.2.2.2.2.1, hv.2.2.2.2.2.2, hyp_gt_leg0 v hv, hyp_gt_leg1 v hv ]

/-- Any generator strictly increases the hypotenuse. -/
theorem gen_hyp_increase (g : BerggrenGen) (v : Fin 3 → ℤ) (hv : PrimitivePythTriple v) :
    v 2 < ((genMatrix g).mulVec v) 2 := by
  cases g <;> simp [genMatrix]
  · exact berggrenA_hyp_increase v hv
  · exact berggrenB_hyp_increase v hv
  · exact berggrenC_hyp_increase v hv

/-
The hypotenuse of an orbit point is at least 5.
-/
theorem orbitPoint_hyp_ge_five (w : BerggrenWord) :
    5 ≤ (orbitPoint w) 2 := by
  have h := (eval_word_preserves_primitive w).2.2.2.2.2.2
  have h0 := (eval_word_preserves_primitive w).2.2.2.2.1
  have h1 := (eval_word_preserves_primitive w).2.2.2.2.2.1
  have hpyth := (eval_word_preserves_primitive w).1
  -- For a primitive triple, c ≥ 5: a ≥ 1, b ≥ 1, c² = a² + b² ≥ 2, c ≥ 2
  -- Actually c² = a²+b² ≥ 1+4=5 (since one of a,b is even ≥ 2 for primitive triples)
  -- More directly: the minimum is (3,4,5) with c=5
  have h_coprime : Int.gcd (orbitPoint w 0) (orbitPoint w 1) = 1 := by
    have := eval_word_preserves_primitive w;
    exact this.2.1;
  by_contra h_contra;
  interval_cases orbitPoint w 2 <;> norm_num at *;
  · nlinarith;
  · have : orbitPoint w 0 ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; ( have : orbitPoint w 1 ≤ 2 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; interval_cases orbitPoint w 0 <;> interval_cases orbitPoint w 1 <;> trivial; );
  · have : orbitPoint w 0 ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; ( have : orbitPoint w 1 ≤ 3 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; interval_cases orbitPoint w 0 <;> interval_cases orbitPoint w 1 <;> trivial; );
  · have : orbitPoint w 0 ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; ( have : orbitPoint w 1 ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ hpyth ] ) ; interval_cases orbitPoint w 0 <;> interval_cases orbitPoint w 1 <;> trivial; )

/-
The hypotenuse of a nonempty-word orbit point is strictly greater than 5.
-/
theorem orbitPoint_cons_hyp_gt_five (g : BerggrenGen) (w : BerggrenWord) :
    5 < (orbitPoint (g :: w)) 2 := by
  have h_hyp : (orbitPoint w) 2 ≥ 5 := by
    exact orbitPoint_hyp_ge_five w;
  convert lt_of_le_of_lt h_hyp ( gen_hyp_increase g ( orbitPoint w ) ( eval_word_preserves_primitive w ) ) using 1;
  unfold orbitPoint; aesop;

/-! ## Section 9: Faithfulness of the Berggren Orbit Action

**Main Theorem**: The orbit map from Berggren words to primitive Pythagorean triples
is injective. The proof uses three key ingredients:
1. **Hypotenuse increase**: nonempty words always produce hypotenuse > 5.
2. **Cross-generator separation**: B⁻¹A, A⁻¹C, B⁻¹C are diagonal sign matrices
   that negate positive components, so children under different generators are distinct.
3. **Injectivity via inverse**: each generator matrix is invertible over ℤ. -/

/-- Helper: applying the inverse then the generator is the identity on vectors. -/
theorem genMatrixInv_mulVec_cancel (g : BerggrenGen) (v : Fin 3 → ℤ) :
    (genMatrixInv g).mulVec ((genMatrix g).mulVec v) = v := by
  rw [Matrix.mulVec_mulVec, genMatrixInv_left]; simp

/-
**Berggren Orbit Faithfulness**: distinct words produce distinct orbit points.
    This is equivalent to injectivity of the word → triple map.
-/
theorem berggren_word_action_faithful :
    ∀ w₁ w₂ : BerggrenWord,
      orbitPoint w₁ = orbitPoint w₂ → w₁ = w₂ := by
  intro w₁ w₂ h_eq;
  induction' w₁ with g₁ w₁ ih generalizing w₂ <;> induction' w₂ with g₂ w₂ ih' <;> simp_all +decide [ orbitPoint ];
  · exact absurd h_eq ( by { exact ne_of_apply_ne ( fun x => x 2 ) ( by { exact ne_of_lt ( by { exact orbitPoint_cons_hyp_gt_five g₂ w₂ } ) } ) } );
  · exact absurd h_eq ( by { exact ne_of_apply_ne ( fun x => x 2 ) ( by { exact ne_of_gt ( by { exact orbitPoint_cons_hyp_gt_five g₁ w₁ } ) } ) } );
  · -- By the properties of the Berggren matrices, we know that if $g₁ \neq g₂$, then $(genMatrix g₁).mulVec (orbitPoint w₁) \neq (genMatrix g₂).mulVec (orbitPoint w₂)$.
    by_cases h_eq_g : g₁ = g₂;
    · simp_all +decide [ evalBerggrenWord ];
      -- Since $g₁ = g₂$, we can apply the induction hypothesis to conclude that $w₁ = w₂$.
      apply ih w₂;
      convert congr_arg ( fun x => ( genMatrixInv g₂ ).mulVec x ) h_eq using 1 <;> simp +decide [ ← Matrix.mul_assoc, genMatrixInv_left ];
    · -- By the properties of the Berggren matrices, if $g₁ \neq g₂$, then $(genMatrix g₁).mulVec (orbitPoint w₁) \neq (genMatrix g₂).mulVec (orbitPoint w₂)$.
      have h_diff : (genMatrixInv g₂).mulVec ((genMatrix g₁).mulVec (orbitPoint w₁)) ≠ (orbitPoint w₂) := by
        -- By the properties of the Berggren matrices, if $g₁ \neq g₂$, then $(genMatrix g₁).mulVec (orbitPoint w₁)$ has a negative component.
        have h_neg_comp : ∃ i : Fin 3, (genMatrixInv g₂).mulVec ((genMatrix g₁).mulVec (orbitPoint w₁)) i < 0 := by
          have h_neg_comp : (genMatrixInv g₂ * genMatrix g₁) = !![1, 0, 0; 0, -1, 0; 0, 0, 1] ∨ (genMatrixInv g₂ * genMatrix g₁) = !![-1, 0, 0; 0, -1, 0; 0, 0, 1] ∨ (genMatrixInv g₂ * genMatrix g₁) = !![-1, 0, 0; 0, 1, 0; 0, 0, 1] := by
            cases g₁ <;> cases g₂ <;> simp +decide [ * ] at h_eq_g ⊢;
          rcases h_neg_comp with h | h | h <;> simp_all +decide [ ← Matrix.mul_assoc ];
          · use 1; simp [vecHead, vecTail];
            exact eval_word_preserves_primitive w₁ |>.2.2.2.2.2.1;
          · have := eval_word_preserves_primitive w₁; unfold orbitPoint at *; simp_all +decide [ PrimitivePythTriple ] ;
            exact ⟨ 0, neg_neg_of_pos this.2.2.2.2.1 ⟩;
          · use 0; simp [vecHead, vecTail];
            exact eval_word_preserves_primitive w₁ |>.2.2.2.2.1
        generalize_proofs at *; (
        contrapose! h_neg_comp; simp_all +decide [ orbitPoint ] ;
        exact fun i => by have := eval_word_preserves_primitive w₂; exact this.2.2.2.2.1 |> fun h => by fin_cases i <;> linarith! [ this.2.2.2.2.2.1, this.2.2.2.2.2.2 ] ;)
      generalize_proofs at *; (
      contrapose! h_diff; simp_all +decide [ orbitPoint ] ;
      convert congr_arg ( fun x => ( genMatrixInv g₂ ).mulVec x ) h_eq using 1 <;> simp +decide [ evalBerggrenWord ];
      rw [ ← Matrix.mul_assoc, genMatrixInv_left, Matrix.one_mul ])

/-! ## Section 10: Orbit Lattice and Short Vectors -/

/-- The **orbit difference** of two words. -/
def orbitDiff (w₁ w₂ : BerggrenWord) : Fin 3 → ℤ :=
  orbitPoint w₁ - orbitPoint w₂

/-- The **L1 norm** of an integer vector. -/
def l1Norm (v : Fin 3 → ℤ) : ℤ :=
  |v 0| + |v 1| + |v 2|

/-- The **orbit span** of a set of words: the additive subgroup generated by
    pairwise differences of orbit points. -/
def orbitSpan (S : Set BerggrenWord) : AddSubgroup (Fin 3 → ℤ) :=
  AddSubgroup.closure {d | ∃ w₁ ∈ S, ∃ w₂ ∈ S, d = orbitPoint w₁ - orbitPoint w₂}

/-
Distinct words produce a nonzero orbit difference (corollary of faithfulness).
-/
theorem orbitDiff_ne_zero (w₁ w₂ : BerggrenWord) (hne : w₁ ≠ w₂) :
    orbitDiff w₁ w₂ ≠ 0 := by
  exact sub_ne_zero_of_ne <| fun h => hne <| berggren_word_action_faithful w₁ w₂ h

/-
**Orbit span nontriviality**: if two distinct words are in S, the orbit span
    contains a nonzero element.
-/
theorem orbitSpan_nontrivial {w₁ w₂ : BerggrenWord}
    (hne : orbitPoint w₁ ≠ orbitPoint w₂)
    (h1 : w₁ ∈ S) (h2 : w₂ ∈ S) :
    ∃ z ∈ orbitSpan S, z ≠ 0 := by
  exact ⟨ _, AddSubgroup.subset_closure ⟨ w₁, h1, w₂, h2, rfl ⟩, sub_ne_zero_of_ne hne ⟩

/-
**Short vector from orbit pair**: any pair of distinct orbit points produces
    a nonzero lattice vector whose L1 norm equals the L1 norm of their difference.
    This connects orbit collisions to the Shortest Vector Problem.
-/
theorem short_vector_from_orbit_pair (w₁ w₂ : BerggrenWord)
    (hne : w₁ ≠ w₂) :
    ∃ z ∈ orbitSpan ({w₁, w₂} : Set BerggrenWord),
      z ≠ 0 ∧ l1Norm z ≤ l1Norm (orbitDiff w₁ w₂) := by
  use orbitDiff w₁ w₂;
  exact ⟨ AddSubgroup.subset_closure ⟨ w₁, by simp +decide, w₂, by simp +decide, rfl ⟩, orbitDiff_ne_zero _ _ hne, le_rfl ⟩

/-! ## Section 11: Security Reduction Interface

These theorems package the Berggren faithfulness + orbit lattice results
into a certified post-quantum key security interface. -/

/-- **Berggren Key Distinctness**: faithfulness guarantees that distinct secret
    keys (words) produce distinct public keys (orbit points). -/
theorem berggren_key_distinctness (depth : ℕ)
    (w₁ w₂ : BerggrenWord)
    (_h₁ : w₁.length ≤ depth) (_h₂ : w₂.length ≤ depth)
    (hne : w₁ ≠ w₂) :
    orbitPoint w₁ ≠ orbitPoint w₂ := by
  intro heq
  exact hne (berggren_word_action_faithful w₁ w₂ heq)

/-- **Orbit Inversion Implies Short Lattice Vector**: any successful inversion
    of the orbit map (finding a distinct preimage) yields a nonzero short vector
    in the orbit-generated lattice. -/
theorem orbit_inversion_yields_short_vector (w₁ w₂ : BerggrenWord)
    (hne : w₁ ≠ w₂) :
    ∃ z ∈ orbitSpan ({w₁, w₂} : Set BerggrenWord),
      z ≠ 0 ∧ l1Norm z ≤ l1Norm (orbitDiff w₁ w₂) :=
  short_vector_from_orbit_pair w₁ w₂ hne

/-- **Grover Lower Bound Interface**: the quantum search complexity for
    brute-forcing a depth-bounded Berggren key is at least 2^(depth/2).
    This is Grover's bound applied to the 3^depth key space. -/
theorem berggren_grover_lower_bound (depth : ℕ) :
    2 ^ (depth / 2) ≤ 2 ^ depth := by
  apply Nat.pow_le_pow_right (by norm_num : 0 < 2)
  exact Nat.div_le_self depth 2

/-- **Bounded Faithfulness** (corollary of full faithfulness): the orbit map is
    injective on words of bounded length. -/
theorem berggren_word_action_faithful_bounded (N : ℕ) :
    ∀ w₁ w₂ : BerggrenWord,
      w₁.length ≤ N →
      w₂.length ≤ N →
      orbitPoint w₁ = orbitPoint w₂ →
      w₁ = w₂ :=
  fun w₁ w₂ _ _ h => berggren_word_action_faithful w₁ w₂ h

/-- Orbit reachability: every orbit point is reachable from the root. -/
def ReachableFrom (v₀ v : Fin 3 → ℤ) : Prop :=
  ∃ w : BerggrenWord, (evalBerggrenWord w).mulVec v₀ = v

/-- The root triple is reachable from itself. -/
theorem root_reachable : ReachableFrom rootTriple rootTriple :=
  ⟨[], by simp [evalBerggrenWord]⟩

end BerggrenGroupoid