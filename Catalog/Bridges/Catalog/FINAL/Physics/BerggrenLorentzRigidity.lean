import Mathlib

/-!
# Lorentzian Berggren Geodesic Rigidity

This file establishes the Berggren semigroup as a positive cone inside an arithmetic
Lorentz group `O(2,1;ℤ)` and proves orbit injectivity — a rigidity theorem that enables
unique decoding of Berggren words from the displacement profile of the root triple `(3,4,5)`.

## Main results

* `A_preservesMinkowski`, `B_preservesMinkowski`, `C_preservesMinkowski`:
  The three classical Berggren generators preserve the Minkowski form `diag(1,1,−1)`.
* `preservesMinkowski_mul`: Closure of Minkowski preservation under multiplication.
* `preserves_nullcone`: Minkowski-preserving maps preserve the Lorentzian null cone.
* `tripleOfWord_null`, `tripleOfWord_positive`: Every Berggren orbit point is a
  positive null triple.
* `berggren_orbit_injective`: The map from Berggren words to Pythagorean triples
  (via the orbit of `(3,4,5)`) is injective — **the main rigidity theorem**.
* `berggren_decode_unique`: Unique decoding of reduced words from displacement profiles.

## Strategy

The proof of orbit injectivity uses two key ingredients:

1. **Sector separation**: Two linear functionals `σ₁(v) = v₀ + 2v₁ − 2v₂` and
   `σ₂(v) = 2v₀ + v₁ − 2v₂` satisfy, after applying generator `G` to a positive
   null triple `v`:
   - After `A`: `σ₁ = v₀ > 0`, `σ₂ = −v₁ < 0`
   - After `B`: `σ₁ = v₀ > 0`, `σ₂ = v₁ > 0`
   - After `C`: `σ₁ = −v₀ < 0`, `σ₂ = v₁ > 0`

   The three sign patterns `(+,−)`, `(+,+)`, `(−,+)` are pairwise distinct, so the
   first generator in any word is uniquely determined by the resulting triple.

2. **Left cancellation**: Each generator matrix has determinant `±1`, hence is
   invertible over `ℤ`, enabling cancellation of the leading generator to reduce
   to a shorter word and apply induction.

## References

* Berggren, B. (1934). "Pytagoreiska trianglar".
* Barning, F.J.M. (1963). "Over pythagorese en bijna-pythagorese driehoeken en een
  generatieproces met behulp van unimodulaire matrices".
-/

namespace BerggrenLorentz

/-! ## Core Definitions -/

/-- The Minkowski metric tensor `diag(1, 1, −1)`. -/
def J : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 0, 0; 0, 1, 0; 0, 0, -1]

/-- A matrix preserves the Minkowski form if `Mᵀ J M = J`. -/
def preservesMinkowski (M : Matrix (Fin 3) (Fin 3) ℤ) : Prop :=
  M.transpose * J * M = J

/-- Berggren generator A (left branch). -/
def A : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, -2, 2; 2, -1, 2; 2, -2, 3]

/-- Berggren generator B (middle branch). -/
def B : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, 2; 2, 1, 2; 2, 2, 3]

/-- Berggren generator C (right branch). -/
def C : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- The Lorentz quadratic form: `v₀² + v₁² − v₂²`. -/
def minkowskiQ (v : Fin 3 → ℤ) : ℤ :=
  v 0 * v 0 + v 1 * v 1 - v 2 * v 2

/-- A triple is positive if all components are strictly positive. -/
def positiveTriple (v : Fin 3 → ℤ) : Prop :=
  0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2

/-- A vector is primitive if the gcd of absolute values of all components is 1. -/
def primitiveVec (v : Fin 3 → ℤ) : Prop :=
  Nat.gcd (Nat.gcd (v 0).natAbs (v 1).natAbs) (v 2).natAbs = 1

/-- A primitive null triple: on the null cone, primitive, and positive. -/
def primitiveNullTriple (v : Fin 3 → ℤ) : Prop :=
  minkowskiQ v = 0 ∧ primitiveVec v ∧ positiveTriple v

/-- The root Pythagorean triple `(3, 4, 5)`. -/
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]

/-! ## Generator Alphabet and Word Evaluation -/

/-- The three Berggren generators as an alphabet. -/
inductive Gen where
  | a | b | c
  deriving DecidableEq, Repr

/-- Map each generator letter to its matrix. -/
def genMatrix : Gen → Matrix (Fin 3) (Fin 3) ℤ
  | .a => A
  | .b => B
  | .c => C

/-- Evaluate a word (list of generators) as a matrix product (left-to-right). -/
def evalWord : List Gen → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => genMatrix g * evalWord w

/-- The Pythagorean triple obtained by applying a word to the root triple. -/
def tripleOfWord (w : List Gen) : Fin 3 → ℤ :=
  (evalWord w).mulVec rootTriple

/-- Reduced word — in a free semigroup, every word is reduced. -/
def reducedWord (_ : List Gen) : Prop := True

/-- Displacement profile: the triple of coordinates of the orbit point. -/
def displacementProfile (M : Matrix (Fin 3) (Fin 3) ℤ) : ℤ × ℤ × ℤ :=
  let v := M.mulVec rootTriple
  (v 0, v 1, v 2)

/-! ## Sector Separation Invariants -/

/-- First separation functional: `v₀ + 2v₁ − 2v₂`.
After applying `A` or `B` to a positive null triple `(x,y,z)`, this equals `x > 0`.
After applying `C`, this equals `−x < 0`. -/
def sigma1 (v : Fin 3 → ℤ) : ℤ := v 0 + 2 * v 1 - 2 * v 2

/-- Second separation functional: `2v₀ + v₁ − 2v₂`.
After applying `A` to `(x,y,z)`, this equals `−y < 0`.
After applying `B` or `C`, this equals `y > 0`. -/
def sigma2 (v : Fin 3 → ℤ) : ℤ := 2 * v 0 + v 1 - 2 * v 2

/-! ## Inverse Matrices -/

/-- Inverse of generator A, computed as `J Aᵀ J`. -/
def A_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; -2, -1, 2; -2, -2, 3]

/-- Inverse of generator B, computed as `J Bᵀ J`. -/
def B_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![1, 2, -2; 2, 1, -2; -2, -2, 3]

/-- Inverse of generator C, computed as `J Cᵀ J`. -/
def C_inv : Matrix (Fin 3) (Fin 3) ℤ :=
  !![-1, -2, 2; 2, 1, -2; -2, -2, 3]

/-- Map each generator to its inverse matrix. -/
def genMatrixInv : Gen → Matrix (Fin 3) (Fin 3) ℤ
  | .a => A_inv
  | .b => B_inv
  | .c => C_inv

/-! ## Lorentz Preservation -/

/-- Generator A preserves the Minkowski form. -/
theorem A_preservesMinkowski : preservesMinkowski A := by
  simp only [preservesMinkowski, A, J]; native_decide

/-- Generator B preserves the Minkowski form. -/
theorem B_preservesMinkowski : preservesMinkowski B := by
  simp only [preservesMinkowski, B, J]; native_decide

/-- Generator C preserves the Minkowski form. -/
theorem C_preservesMinkowski : preservesMinkowski C := by
  simp only [preservesMinkowski, C, J]; native_decide

/-
Minkowski preservation is closed under matrix multiplication:
the Berggren semigroup lies inside the integral Lorentz group.
-/
theorem preservesMinkowski_mul {M N : Matrix (Fin 3) (Fin 3) ℤ}
    (hM : preservesMinkowski M) (hN : preservesMinkowski N) :
    preservesMinkowski (M * N) := by
  unfold preservesMinkowski at *;
  simp_all +decide [ Matrix.mul_assoc ];
  simp_all +decide [ ← Matrix.mul_assoc ]

/-- Each generator preserves the Minkowski form. -/
theorem gen_preservesMinkowski (g : Gen) : preservesMinkowski (genMatrix g) := by
  cases g <;> simp only [genMatrix]
  · exact A_preservesMinkowski
  · exact B_preservesMinkowski
  · exact C_preservesMinkowski

/-! ## Inverse Matrix Verification -/

theorem A_inv_mul_A : A_inv * A = 1 := by
  simp only [A_inv, A]; native_decide

theorem B_inv_mul_B : B_inv * B = 1 := by
  simp only [B_inv, B]; native_decide

theorem C_inv_mul_C : C_inv * C = 1 := by
  simp only [C_inv, C]; native_decide

/-- Each generator's inverse is a left inverse. -/
theorem genMatrixInv_mul (g : Gen) : genMatrixInv g * genMatrix g = 1 := by
  cases g <;> simp only [genMatrixInv, genMatrix]
  · exact A_inv_mul_A
  · exact B_inv_mul_B
  · exact C_inv_mul_C

/-! ## Null Cone Preservation -/

/-
Any Minkowski-preserving matrix preserves the Lorentz quadratic form.
This identifies null vectors (Pythagorean triples) as geometric invariants
of the Berggren semigroup.
-/
theorem preserves_nullcone {M : Matrix (Fin 3) (Fin 3) ℤ}
    (hM : preservesMinkowski M) {v : Fin 3 → ℤ} :
    minkowskiQ (M.mulVec v) = minkowskiQ v := by
  -- By definition of minkowskiQ, we can expand both sides of the equation.
  have h_expand : minkowskiQ (M.mulVec v) = dotProduct (M.mulVec v) (J.mulVec (M.mulVec v)) ∧ minkowskiQ v = dotProduct v (J.mulVec v) := by
    simp +decide [ minkowskiQ, dotProduct, Matrix.mulVec ];
    simp +decide [ Fin.sum_univ_three, J ];
    constructor <;> ring;
  rw [ h_expand.1, h_expand.2 ];
  have h_expand : dotProduct (M.mulVec v) (J.mulVec (M.mulVec v)) = dotProduct v ((M.transpose * J * M).mulVec v) := by
    simp +decide [ Matrix.mul_assoc, Matrix.dotProduct_mulVec, Matrix.vecMul_mulVec ];
  rw [ h_expand, hM ]

/-! ## Root Triple Properties -/

/-- The root triple `(3,4,5)` is a primitive null triple. -/
theorem rootTriple_primitiveNull : primitiveNullTriple rootTriple := by
  simp only [primitiveNullTriple, minkowskiQ, primitiveVec, positiveTriple, rootTriple]
  native_decide

theorem rootTriple_null : minkowskiQ rootTriple = 0 :=
  rootTriple_primitiveNull.1

theorem rootTriple_positive : positiveTriple rootTriple :=
  rootTriple_primitiveNull.2.2

/-! ## Key Inequality: Null Cone Components -/

/-
On the positive null cone, the hypotenuse exceeds each leg:
from `x² + y² = z²` and `x, y, z > 0` we get `x < z` and `y < z`.
-/
theorem null_cone_lt {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    v 0 < v 2 ∧ v 1 < v 2 := by
  constructor <;> cases abs_cases ( v 2 ) <;> nlinarith! [ hpos.1, hpos.2.1, hpos.2.2, show minkowskiQ v = v 0 * v 0 + v 1 * v 1 - v 2 * v 2 from rfl ]

/-! ## Positivity Preservation -/

/-
Generator A maps positive null triples to positive triples.
-/
theorem A_preserves_positive {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    positiveTriple (A.mulVec v) := by
  unfold minkowskiQ positiveTriple at *;
  unfold A; simp +decide [ Matrix.mulVec ] ;
  exact ⟨ by nlinarith! [ null_cone_lt hnull hpos ], by nlinarith! [ null_cone_lt hnull hpos ], by nlinarith! [ null_cone_lt hnull hpos ] ⟩

/-
Generator B maps positive null triples to positive triples.
-/
theorem B_preserves_positive {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    positiveTriple (B.mulVec v) := by
  unfold B;
  simp_all +decide [ Fin.sum_univ_three, positiveTriple ];
  exact ⟨ by linarith !, by linarith !, by linarith ! ⟩

/-
Generator C maps positive null triples to positive triples.
-/
theorem C_preserves_positive {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    positiveTriple (C.mulVec v) := by
  obtain ⟨ hv0, hv1, hv2 ⟩ := hpos;
  unfold positiveTriple C; simp +decide [ Matrix.vecHead, Matrix.vecTail ] ;
  unfold minkowskiQ at hnull; exact ⟨ by nlinarith, by nlinarith, by nlinarith ⟩ ;

/-- Each generator preserves positive null triples. -/
theorem gen_preserves_positive (g : Gen) {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    positiveTriple ((genMatrix g).mulVec v) := by
  cases g <;> simp only [genMatrix]
  · exact A_preserves_positive hnull hpos
  · exact B_preserves_positive hnull hpos
  · exact C_preserves_positive hnull hpos

/-! ## Sigma Separation Formulas -/

/-
After applying A, the first separation functional equals the first component.
-/
theorem sigma1_after_A (v : Fin 3 → ℤ) : sigma1 (A.mulVec v) = v 0 := by
  unfold sigma1; simp +decide [ A, Matrix.mulVec ] ; ring!;

/-
After applying A, the second separation functional equals minus the second component.
-/
theorem sigma2_after_A (v : Fin 3 → ℤ) : sigma2 (A.mulVec v) = -(v 1) := by
  unfold sigma2; simp +decide [ A, Matrix.mulVec ] ; ring!;

/-
After applying B, the first separation functional equals the first component.
-/
theorem sigma1_after_B (v : Fin 3 → ℤ) : sigma1 (B.mulVec v) = v 0 := by
  unfold sigma1; simp +decide [ Matrix.mulVec ] ; ring;
  simp +decide [ B, dotProduct ] ; ring!;
  simpa [ Fin.sum_univ_succ ] using by ring!;

/-
After applying B, the second separation functional equals the second component.
-/
theorem sigma2_after_B (v : Fin 3 → ℤ) : sigma2 (B.mulVec v) = v 1 := by
  unfold sigma2 B;
  simpa [ Matrix.mulVec ] using by ring!;

/-
After applying C, the first separation functional equals minus the first component.
-/
theorem sigma1_after_C (v : Fin 3 → ℤ) : sigma1 (C.mulVec v) = -(v 0) := by
  -- We unfold the definition of `sigma1` and `C.mulVec` for explicit calculation.
  dsimp [sigma1, C];
  simpa! using by ring!;

/-
After applying C, the second separation functional equals the second component.
-/
theorem sigma2_after_C (v : Fin 3 → ℤ) : sigma2 (C.mulVec v) = v 1 := by
  unfold sigma2 C;
  simpa [ Matrix.mulVec ] using by ring!;

/-! ## Orbit Properties -/

/-- Rewrite lemma: the triple of a cons word decomposes as generator applied to tail. -/
theorem tripleOfWord_cons (g : Gen) (w : List Gen) :
    tripleOfWord (g :: w) = (genMatrix g).mulVec (tripleOfWord w) := by
  simp [tripleOfWord, evalWord, Matrix.mulVec_mulVec]

/-
Every Berggren orbit point lies on the null cone.
-/
theorem tripleOfWord_null (w : List Gen) : minkowskiQ (tripleOfWord w) = 0 := by
  induction' w with g w ih;
  · exact rootTriple_null
  · rw [tripleOfWord_cons, preserves_nullcone (gen_preservesMinkowski g)]; exact ih

/-
Every Berggren orbit point is a positive triple.
-/
theorem tripleOfWord_positive (w : List Gen) : positiveTriple (tripleOfWord w) := by
  induction' w with g w ih;
  · exact ⟨ by decide, by decide, by decide ⟩;
  · rw [tripleOfWord_cons];
    exact gen_preserves_positive g ( tripleOfWord_null w ) ih

/-! ## Left Cancellation -/

/-
If `M_inv` is a left inverse of `M`, then `M.mulVec` is injective.
-/
theorem mulVec_left_cancel {M M_inv : Matrix (Fin 3) (Fin 3) ℤ}
    (h : M_inv * M = 1) {v w : Fin 3 → ℤ} (heq : M.mulVec v = M.mulVec w) :
    v = w := by
  apply_fun M_inv.mulVec at heq; simp_all +decide [ ← Matrix.mul_assoc ] ;

/-- Each generator's `mulVec` is injective. -/
theorem gen_mulVec_injective {g : Gen} {v w : Fin 3 → ℤ}
    (h : (genMatrix g).mulVec v = (genMatrix g).mulVec w) : v = w :=
  mulVec_left_cancel (genMatrixInv_mul g) h

/-! ## First Letter Determination -/

/-
The first letter of a Berggren word is uniquely determined by the resulting triple.
This is the sector separation theorem: the sign pattern of `(σ₁, σ₂)` uniquely
identifies which generator was applied.
-/
theorem first_letter_eq {g h : Gen} {u w : Fin 3 → ℤ}
    (hpu : positiveTriple u) (hpw : positiveTriple w)
    (heq : (genMatrix g).mulVec u = (genMatrix h).mulVec w) :
    g = h := by
  cases g <;> cases h;
  all_goals simp_all +decide only [positiveTriple, genMatrix];
  all_goals norm_num [ ← List.ofFn_inj, A, B, C ] at heq; linarith!;

/-! ## Hypotenuse Growth -/

/-
Each generator strictly increases the hypotenuse (third component).
This ensures non-empty words produce triples with hypotenuse > 5,
separating them from the root triple.
-/
theorem hypotenuse_increase (g : Gen) {v : Fin 3 → ℤ}
    (hnull : minkowskiQ v = 0) (hpos : positiveTriple v) :
    v 2 < ((genMatrix g).mulVec v) 2 := by
  rcases g with ( _ | _ | _ ) <;> norm_num [ *, Matrix.mulVec ];
  · unfold genMatrix;
    unfold A;
    simp +decide [ Fin.sum_univ_succ, dotProduct ];
    nlinarith [ hpos.1, hpos.2.1, hpos.2.2, null_cone_lt hnull hpos ];
  · simp_all +decide [ Fin.sum_univ_three, dotProduct ];
    simp_all +decide [ genMatrix ];
    simp_all +decide [ B ];
    linarith [ hpos.1, hpos.2.1, hpos.2.2 ];
  · unfold minkowskiQ at hnull; simp_all +decide [ Fin.sum_univ_three, dotProduct ];
    unfold genMatrix;
    unfold C; simp +decide ; nlinarith [ hpos.1, hpos.2.1, hpos.2.2 ] ;

/-! ## Main Rigidity Theorems -/

/-
**Berggren Orbit Injectivity**: The map from Berggren words to Pythagorean triples
is injective. This is the central rigidity theorem — no two distinct words in the
free semigroup on `{A, B, C}` produce the same Pythagorean triple.

Proof by induction on `w`:
- If `w = []`, then `tripleOfWord [] = rootTriple` has hypotenuse 5, while any
  non-empty word has hypotenuse > 5 by `hypotenuse_increase`.
- If `w = g :: t`, we case-split on `w'`:
  - `w' = []`: symmetric to the previous case.
  - `w' = h :: t'`: by `first_letter_eq`, `g = h`, then by `gen_mulVec_injective`,
    `tripleOfWord t = tripleOfWord t'`, and by induction `t = t'`.
-/
theorem berggren_orbit_injective
    {w w' : List Gen}
    (h : tripleOfWord w = tripleOfWord w') :
    w = w' := by
  -- If $w'$ is empty, then $tripleOfWord w' = rootTriple$. Since $tripleOfWord w = rootTriple$, $w$ must also be empty.
  induction' w with g t ih generalizing w';
  · induction' w' with g w ih <;> simp_all +decide [ tripleOfWord ];
    have h_hyp : ∀ w : List Gen, (tripleOfWord w) 2 ≥ 5 := by
      intro w; induction' w with g w ih <;> simp_all +decide [ tripleOfWord ] ;
      have := hypotenuse_increase g ( tripleOfWord_null w ) ( tripleOfWord_positive w ) ; simp_all +decide [ tripleOfWord ] ; linarith!;
    have := congr_fun h 2; norm_num [ evalWord ] at this;
    have := hypotenuse_increase g ( tripleOfWord_null w ) ( tripleOfWord_positive w ) ; simp_all +decide [ tripleOfWord ] ;
    linarith! [ h_hyp w, show rootTriple 2 = 5 from rfl ];
  · rcases w' with ( _ | ⟨ h, t' ⟩ ) <;> simp_all +decide;
    · -- By the properties of the generators, we know that applying any generator to a positive triple results in a triple with a larger hypotenuse.
      have h_hypotenuse : ∀ (g : Gen) (v : Fin 3 → ℤ), minkowskiQ v = 0 → positiveTriple v → v 2 < ((genMatrix g).mulVec v) 2 := by
        apply hypotenuse_increase;
      have h_hypotenuse : ∀ (w : List Gen), rootTriple 2 < (tripleOfWord w) 2 ∨ w = [] := by
        intro w; induction' w with g t ih <;> simp_all +decide [ tripleOfWord_cons ] ;
        cases ih <;> simp_all +decide [ rootTriple ];
        · exact lt_trans ‹_› ( h_hypotenuse g _ ( tripleOfWord_null t ) ( tripleOfWord_positive t ) );
        · exact h_hypotenuse g _ ( tripleOfWord_null _ ) ( tripleOfWord_positive _ );
      cases h_hypotenuse ( g :: t ) <;> simp_all +decide;
    · have h_eq : g = ‹Gen› := by
        exact first_letter_eq ( tripleOfWord_positive _ ) ( tripleOfWord_positive _ ) ( by simpa [ tripleOfWord_cons ] using h );
      simp_all +decide [ tripleOfWord_cons ];
      exact ih ( gen_mulVec_injective h )

/-
**Berggren Decode Uniqueness**: Reduced words are uniquely determined by their
displacement profile. Since every word is reduced (the semigroup is free) and the
displacement profile is determined by the orbit triple, this follows directly from
orbit injectivity.
-/
theorem berggren_decode_unique
    {w w' : List Gen}
    (_hw : reducedWord w) (_hw' : reducedWord w')
    (hprof : displacementProfile (evalWord w) = displacementProfile (evalWord w')) :
    w = w' := by
  -- By definition of `displacementProfile`, we know that `displacementProfile (evalWord w) = displacementProfile (evalWord w')` implies `tripleOfWord w = tripleOfWord w'`.
  have h_triple_eq : tripleOfWord w = tripleOfWord w' := by
    unfold displacementProfile at hprof; unfold tripleOfWord; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
  exact berggren_orbit_injective h_triple_eq

/-
First-letter uniqueness: distinct generators always produce distinct triples.
-/
theorem berggren_first_letter_unique
    {g h : Gen} {w w' : List Gen}
    (hne : g ≠ h) :
    tripleOfWord (g :: w) ≠ tripleOfWord (h :: w') := by
  exact fun h => hne <| by have := berggren_orbit_injective h; aesop;

/-! ## Berggren Maps Preserve Positive Null Triples -/

/-
Each generator maps positive null triples to positive null triples.
Combined with null cone preservation, this shows the Berggren semigroup
acts on the future light cone.
-/
theorem berggren_maps_positiveNull
    {G : Matrix (Fin 3) (Fin 3) ℤ}
    (hG : G = A ∨ G = B ∨ G = C)
    {v : Fin 3 → ℤ} :
    minkowskiQ v = 0 → positiveTriple v →
    minkowskiQ (G.mulVec v) = 0 ∧ positiveTriple (G.mulVec v) := by
  -- By definition of $G$, we know that $G$ is either $A$, $B$, or $C$.
  cases' hG with hA hB hC;
  · intro h1 h2; subst hA; exact ⟨ by
      rw [ preserves_nullcone A_preservesMinkowski ] ; aesop, by
      exact A_preserves_positive h1 h2 ⟩ ;
  · cases hB <;> simp_all +decide [ preserves_nullcone, B_preservesMinkowski, C_preservesMinkowski ];
    · exact fun a a_1 => B_preserves_positive a a_1
    · exact fun a a_1 => C_preserves_positive a a_1

end BerggrenLorentz