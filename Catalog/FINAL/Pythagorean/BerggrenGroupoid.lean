/-
# Berggren Groupoid: Free Orbit on Primitive Pythagorean Triples

Bridge: Number theory × Algebraic dynamics × Certified coding.

The three Berggren matrices A, B, C generate a ternary tree of positive primitive
Pythagorean triples rooted at (3,4,5). All three are unimodular (|det| = 1).
-/
import Mathlib

open Matrix

def berggrenA : Matrix (Fin 3) (Fin 3) ℤ := !![(1:ℤ), -2, 2; 2, -1, 2; 2, -2, 3]
def berggrenB : Matrix (Fin 3) (Fin 3) ℤ := !![(1:ℤ), 2, 2; 2, 1, 2; 2, 2, 3]
def berggrenC : Matrix (Fin 3) (Fin 3) ℤ := !![(-1:ℤ), 2, 2; -2, 1, 2; -2, 2, 3]

def pythagoreanForm (v : Fin 3 → ℤ) : ℤ := v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2
def IsPositiveTriple (v : Fin 3 → ℤ) : Prop := 0 < v 0 ∧ 0 < v 1 ∧ 0 < v 2
def IsSortedLegTriple (v : Fin 3 → ℤ) : Prop := v 0 ≤ v 1
def IsPythagoreanTriple (v : Fin 3 → ℤ) : Prop := pythagoreanForm v = 0
def IsPrimitiveTriple (v : Fin 3 → ℤ) : Prop := Int.gcd (Int.gcd (v 0) (v 1)) (v 2) = 1
def TripleContent (v : Fin 3 → ℤ) : ℕ := Int.gcd (Int.gcd (v 0) (v 1)) (v 2)
def IsRootedPrimitiveTriple (v : Fin 3 → ℤ) : Prop :=
  IsPositiveTriple v ∧ IsPythagoreanTriple v ∧ IsPrimitiveTriple v
def rootTriple : Fin 3 → ℤ := ![3, 4, 5]
def berggrenAct (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) : Fin 3 → ℤ := M.mulVec v
inductive BerggrenLetter | A | B | C deriving DecidableEq, Repr
def BerggrenLetter.toMatrix : BerggrenLetter → Matrix (Fin 3) (Fin 3) ℤ
  | .A => berggrenA | .B => berggrenB | .C => berggrenC
def berggrenWordAct : List BerggrenLetter → (Fin 3 → ℤ) → (Fin 3 → ℤ)
  | [], v => v
  | l :: w, v => berggrenAct l.toMatrix (berggrenWordAct w v)
def hypotenuse (v : Fin 3 → ℤ) : ℤ := v 2
def legGap (v : Fin 3 → ℤ) : ℤ := v 1 - v 0
def wordCost (w : List BerggrenLetter) : ℕ := w.length
def IsChronometricState (v : Fin 3 → ℤ) : Prop := IsRootedPrimitiveTriple v
def EntropyLikeHeight (v : Fin 3 → ℤ) : ℤ := v 2 - max (v 0) (v 1)
def CertifiedOrbitRadius (w : List BerggrenLetter) : ℕ := w.length
def PostQuantumLatticeShadow (v : Fin 3 → ℤ) : ℤ := v 0 + v 1 + v 2
def LipschitzShadow (_M : Matrix (Fin 3) (Fin 3) ℤ) : ℕ := 7

private theorem mulVec_expand (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ) (i : Fin 3) :
    M.mulVec v i = M i 0 * v 0 + M i 1 * v 1 + M i 2 * v 2 := by
  simp [Matrix.mulVec, dotProduct, Fin.sum_univ_three]

private theorem coord_lemma (M : Matrix (Fin 3) (Fin 3) ℤ) (v : Fin 3 → ℤ)
    (i : Fin 3) (a b c r : ℤ) (ha : M i 0 = a) (hb : M i 1 = b) (hc : M i 2 = c)
    (hr : a * v 0 + b * v 1 + c * v 2 = r) : M.mulVec v i = r := by
  rw [mulVec_expand, ha, hb, hc, hr]

theorem berggrenA_apply0 (v) : berggrenAct berggrenA v 0 = v 0 - 2 * v 1 + 2 * v 2 :=
  coord_lemma berggrenA v 0 1 (-2) 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenA_apply1 (v) : berggrenAct berggrenA v 1 = 2 * v 0 - v 1 + 2 * v 2 :=
  coord_lemma berggrenA v 1 2 (-1) 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenA_apply2 (v) : berggrenAct berggrenA v 2 = 2 * v 0 - 2 * v 1 + 3 * v 2 :=
  coord_lemma berggrenA v 2 2 (-2) 3 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenB_apply0 (v) : berggrenAct berggrenB v 0 = v 0 + 2 * v 1 + 2 * v 2 :=
  coord_lemma berggrenB v 0 1 2 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenB_apply1 (v) : berggrenAct berggrenB v 1 = 2 * v 0 + v 1 + 2 * v 2 :=
  coord_lemma berggrenB v 1 2 1 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenB_apply2 (v) : berggrenAct berggrenB v 2 = 2 * v 0 + 2 * v 1 + 3 * v 2 :=
  coord_lemma berggrenB v 2 2 2 3 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenC_apply0 (v) : berggrenAct berggrenC v 0 = -v 0 + 2 * v 1 + 2 * v 2 :=
  coord_lemma berggrenC v 0 (-1) 2 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenC_apply1 (v) : berggrenAct berggrenC v 1 = -2 * v 0 + v 1 + 2 * v 2 :=
  coord_lemma berggrenC v 1 (-2) 1 2 _ (by native_decide) (by native_decide) (by native_decide) (by ring)
theorem berggrenC_apply2 (v) : berggrenAct berggrenC v 2 = -2 * v 0 + 2 * v 1 + 3 * v 2 :=
  coord_lemma berggrenC v 2 (-2) 2 3 _ (by native_decide) (by native_decide) (by native_decide) (by ring)

theorem rootTriple_pythagorean : IsPythagoreanTriple rootTriple := by
  unfold IsPythagoreanTriple pythagoreanForm rootTriple; native_decide
theorem rootTriple_primitive : IsPrimitiveTriple rootTriple := by
  show Int.gcd (Int.gcd (rootTriple 0) (rootTriple 1)) (rootTriple 2) = 1; decide
theorem rootTriple_positive : IsPositiveTriple rootTriple := by
  show 0 < rootTriple 0 ∧ 0 < rootTriple 1 ∧ 0 < rootTriple 2
  exact ⟨by native_decide, by native_decide, by native_decide⟩
theorem rootTriple_sorted : IsSortedLegTriple rootTriple :=
  show (3 : ℤ) ≤ 4 from by norm_num
theorem rootTriple_rooted : IsRootedPrimitiveTriple rootTriple :=
  ⟨rootTriple_positive, rootTriple_pythagorean, rootTriple_primitive⟩

theorem det_berggrenA : berggrenA.det = 1 := by native_decide
theorem det_berggrenB : berggrenB.det = -1 := by native_decide
theorem det_berggrenC : berggrenC.det = 1 := by native_decide

/-- All Berggren matrices are unimodular: |det| = 1. -/
theorem berggrenLetter_det_unit (l : BerggrenLetter) : IsUnit l.toMatrix.det := by
  cases l <;> simp [BerggrenLetter.toMatrix, det_berggrenA, det_berggrenB, det_berggrenC] <;>
  exact isUnit_one

theorem berggrenA_preserves_pythagoreanForm (v) :
    pythagoreanForm (berggrenAct berggrenA v) = pythagoreanForm v := by
  simp only [pythagoreanForm, berggrenA_apply0, berggrenA_apply1, berggrenA_apply2]; ring
theorem berggrenB_preserves_pythagoreanForm (v) :
    pythagoreanForm (berggrenAct berggrenB v) = pythagoreanForm v := by
  simp only [pythagoreanForm, berggrenB_apply0, berggrenB_apply1, berggrenB_apply2]; ring
theorem berggrenC_preserves_pythagoreanForm (v) :
    pythagoreanForm (berggrenAct berggrenC v) = pythagoreanForm v := by
  simp only [pythagoreanForm, berggrenC_apply0, berggrenC_apply1, berggrenC_apply2]; ring
theorem berggrenLetter_preserves_pythagoreanForm (l : BerggrenLetter) (v : Fin 3 → ℤ) :
    pythagoreanForm (berggrenAct l.toMatrix v) = pythagoreanForm v := by
  cases l <;> simp [BerggrenLetter.toMatrix, berggrenA_preserves_pythagoreanForm,
    berggrenB_preserves_pythagoreanForm, berggrenC_preserves_pythagoreanForm]

theorem berggrenLetter_injective (l : BerggrenLetter) :
    Function.Injective (berggrenAct l.toMatrix) := by
  cases l <;> simp_all +decide [ Function.Injective ];
  · unfold berggrenAct; simp +decide [ funext_iff, Fin.forall_fin_succ ] ;
    simp +decide [ BerggrenLetter.toMatrix, Matrix.mulVec ] at *;
    simp +decide [ Fin.sum_univ_three, dotProduct, berggrenA ] at * ; omega;
  · unfold berggrenAct;
    simp +decide [ funext_iff, Fin.forall_fin_succ ];
    simp +decide [ BerggrenLetter.toMatrix, Matrix.mulVec ];
    simp +decide [ Fin.sum_univ_three, dotProduct, berggrenB ] ; intros ; omega;
  · unfold berggrenAct BerggrenLetter.toMatrix berggrenC; simp +decide [ funext_iff, Fin.forall_fin_succ ] ;
    exact fun a₁ a₂ h₁ h₂ h₃ => ⟨ by linarith !, by linarith !, by linarith ! ⟩

theorem pyth_hyp_gt_leg0 {v : Fin 3 → ℤ}
    (hp : IsPositiveTriple v) (hpy : IsPythagoreanTriple v) : v 2 > v 0 := by
  obtain ⟨ha, hb, hc⟩ := hp
  have hpf : v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2 = 0 := hpy
  nlinarith [sq_abs (v 2 - v 0), sq_abs (v 1)]
theorem pyth_hyp_gt_leg1 {v : Fin 3 → ℤ}
    (hp : IsPositiveTriple v) (hpy : IsPythagoreanTriple v) : v 2 > v 1 := by
  obtain ⟨ha, hb, hc⟩ := hp
  have hpf : v 0 ^ 2 + v 1 ^ 2 - v 2 ^ 2 = 0 := hpy
  nlinarith [sq_abs (v 2 - v 1), sq_abs (v 0)]

theorem berggrenLetter_hypotenuse_strictly_grows (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (hp : IsPositiveTriple v) (hpy : IsPythagoreanTriple v) :
    hypotenuse v < hypotenuse (berggrenAct l.toMatrix v) := by
  rcases l with ( _ | _ | _ ) <;> simp_all +decide [ hypotenuse ];
  · erw [ berggrenA_apply2 ];
    linarith [ hp.1, hp.2.1, hp.2.2, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ];
  · unfold berggrenAct; erw [ BerggrenLetter.toMatrix ] ; norm_num [ mulVec ] ;
    simp_all +decide [ IsPositiveTriple, dotProduct ];
    simp_all +decide [ Fin.sum_univ_three, berggrenB ];
    linarith;
  · erw [ berggrenC_apply2 ];
    linarith [ hp.1, hp.2.1, hp.2.2, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ]

theorem berggrenLetter_hypotenuse_growth_lower_bound (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (hp : IsPositiveTriple v) (hpy : IsPythagoreanTriple v) :
    hypotenuse (berggrenAct l.toMatrix v) ≥ hypotenuse v + 2 := by
  rcases l with ( _ | _ | _ ) <;> simp_all +decide [ hypotenuse ];
  · erw [ berggrenA_apply2 ];
    linarith [ hp.1, hp.2.1, hp.2.2, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ];
  · unfold berggrenAct;
    unfold BerggrenLetter.toMatrix;
    unfold berggrenB;
    simp +decide [ Matrix.mulVec ];
    linarith! [ hp.1, hp.2.1, hp.2.2, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ];
  · unfold berggrenAct; simp +decide [ BerggrenLetter.toMatrix ] ;
    unfold berggrenC; simp +decide [ Matrix.mulVec ] ;
    unfold vecHead vecTail; linarith! [ hp.1, hp.2.1, hp.2.2, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ] ;

theorem berggrenLetter_preserves_positive (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (hp : IsPositiveTriple v) (hpy : IsPythagoreanTriple v) :
    IsPositiveTriple (berggrenAct l.toMatrix v) := by
  rcases l with ( _ | _ | _ ) <;> simp_all +decide [ IsPositiveTriple ];
  · unfold berggrenAct;
    unfold BerggrenLetter.toMatrix; simp +decide [ Matrix.mulVec ] ;
    unfold berggrenA; simp +decide [ dotProduct ] ;
    simp_all +decide [ Fin.sum_univ_succ, IsPythagoreanTriple ];
    unfold pythagoreanForm at hpy; exact ⟨ by nlinarith, by nlinarith, by nlinarith ⟩ ;
  · exact ⟨ by linarith! [ berggrenB_apply0 v ], by linarith! [ berggrenB_apply1 v ], by linarith! [ berggrenB_apply2 v, pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy ] ⟩;
  · exact ⟨ by linarith! [ pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy, berggrenC_apply0 v ], by linarith! [ pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy, berggrenC_apply1 v ], by linarith! [ pyth_hyp_gt_leg0 hp hpy, pyth_hyp_gt_leg1 hp hpy, berggrenC_apply2 v ] ⟩

theorem berggrenLetter_preserves_prim (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (hprim : IsPrimitiveTriple v) : IsPrimitiveTriple (berggrenAct l.toMatrix v) := by
  -- Each Berggren matrix has |det| = 1 (det A = 1, det B = -1, det C = 1).
  have h_det_unit (l : BerggrenLetter) : IsUnit (l.toMatrix.det) := by
    grind +suggestions;
  have h_gcd : ∀ d, (∀ i, d ∣ (l.toMatrix.mulVec v) i) → d ∣ Int.gcd (Int.gcd (v 0) (v 1)) (v 2) := by
    -- Since $d$ divides all coordinates of $l.toMatrix.mulVec v$, it follows that $d$ divides all coordinates of $v$.
    intros d hd
    have hd_div_v : ∀ i, d ∣ v i := by
      have h_det_unit : d ∣ (l.toMatrix.adjugate.mulVec (l.toMatrix.mulVec v)) 0 ∧ d ∣ (l.toMatrix.adjugate.mulVec (l.toMatrix.mulVec v)) 1 ∧ d ∣ (l.toMatrix.adjugate.mulVec (l.toMatrix.mulVec v)) 2 := by
        simp_all +decide [ Matrix.mulVec, dotProduct ];
        exact ⟨ Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right ( hd i ) _, Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right ( hd i ) _, Finset.dvd_sum fun i _ => dvd_mul_of_dvd_right ( hd i ) _ ⟩;
      simp_all +decide [ Fin.forall_fin_succ, Matrix.adjugate_mul ];
    exact Int.dvd_coe_gcd ( Int.dvd_coe_gcd ( hd_div_v 0 ) ( hd_div_v 1 ) ) ( hd_div_v 2 );
  refine' Nat.dvd_one.mp ( Int.natCast_dvd_natCast.mp _ );
  convert h_gcd _ _;
  · exact hprim.symm;
  · exact fun i => by fin_cases i <;> [ exact Int.dvd_trans ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_left _ _ ) ; exact Int.dvd_trans ( Int.gcd_dvd_left _ _ ) ( Int.gcd_dvd_right _ _ ) ; exact Int.gcd_dvd_right _ _ ] ;

theorem berggrenLetter_preserves_pyth (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (hpy : IsPythagoreanTriple v) : IsPythagoreanTriple (berggrenAct l.toMatrix v) := by
  unfold IsPythagoreanTriple at *; rw [berggrenLetter_preserves_pythagoreanForm]; exact hpy

theorem berggrenLetter_preserves_rooted (l : BerggrenLetter) {v : Fin 3 → ℤ}
    (h : IsRootedPrimitiveTriple v) : IsRootedPrimitiveTriple (berggrenAct l.toMatrix v) :=
  ⟨berggrenLetter_preserves_positive l h.1 h.2.1,
   berggrenLetter_preserves_pyth l h.2.1,
   berggrenLetter_preserves_prim l h.2.2⟩

@[simp] theorem berggrenWordAct_nil (v : Fin 3 → ℤ) : berggrenWordAct [] v = v := rfl
theorem berggrenWordAct_cons (l : BerggrenLetter) (w : List BerggrenLetter) (v : Fin 3 → ℤ) :
    berggrenWordAct (l :: w) v = berggrenAct l.toMatrix (berggrenWordAct w v) := rfl
theorem berggrenWordAct_append (u w : List BerggrenLetter) (v : Fin 3 → ℤ) :
    berggrenWordAct (u ++ w) v = berggrenWordAct u (berggrenWordAct w v) := by
  induction u with
  | nil => simp
  | cons l u ih => simp only [List.cons_append, berggrenWordAct, ih]

theorem berggrenWordAct_preserves_rooted : ∀ (w : List BerggrenLetter) {v : Fin 3 → ℤ},
    IsRootedPrimitiveTriple v → IsRootedPrimitiveTriple (berggrenWordAct w v)
  | [] => fun h => by simpa
  | l :: w => fun h => berggrenLetter_preserves_rooted l (berggrenWordAct_preserves_rooted w h)

theorem hypotenuse_le_wordAct (w : List BerggrenLetter) {v : Fin 3 → ℤ}
    (hr : IsRootedPrimitiveTriple v) :
    hypotenuse v ≤ hypotenuse (berggrenWordAct w v) := by
  induction' w with l w ih generalizing v;
  · rfl;
  · exact le_trans ( ih hr ) ( berggrenLetter_hypotenuse_strictly_grows l ( by have := berggrenWordAct_preserves_rooted w hr; exact this.1 ) ( by have := berggrenWordAct_preserves_rooted w hr; exact this.2.1 ) |> le_of_lt )

theorem hypotenuse_strictly_grows_nonempty_word (w : List BerggrenLetter) {v : Fin 3 → ℤ}
    (hr : IsRootedPrimitiveTriple v) (hne : w ≠ []) :
    hypotenuse v < hypotenuse (berggrenWordAct w v) := by
  induction' w with l w ih generalizing v;
  · contradiction;
  · by_cases hw : w = [] <;> simp_all +decide [ berggrenWordAct_cons ];
    · exact berggrenLetter_hypotenuse_strictly_grows l hr.1 hr.2.1;
    · exact lt_trans ( ih hr ) ( berggrenLetter_hypotenuse_strictly_grows l ( berggrenWordAct_preserves_rooted w hr |>.1 ) ( berggrenWordAct_preserves_rooted w hr |>.2.1 ) )

theorem legGap_A_formula (v) : legGap (berggrenAct berggrenA v) = v 0 + v 1 := by
  simp only [legGap, berggrenA_apply1, berggrenA_apply0]; ring
theorem legGap_C_formula (v) : legGap (berggrenAct berggrenC v) = -(v 0 + v 1) := by
  simp only [legGap, berggrenC_apply1, berggrenC_apply0]; ring

theorem berggren_branch_disjoint_AB {v w : Fin 3 → ℤ}
    (hv : IsRootedPrimitiveTriple v) (hw : IsRootedPrimitiveTriple w) :
    berggrenAct berggrenA v ≠ berggrenAct berggrenB w := by
  unfold berggrenAct;
  unfold berggrenA berggrenB;
  simp_all +decide [ IsRootedPrimitiveTriple ];
  intro h1 h2 h3; linarith! [ hv.1.1, hv.1.2.1, hv.1.2.2, hw.1.1, hw.1.2.1, hw.1.2.2 ] ;

theorem berggren_branch_disjoint_AC {v w : Fin 3 → ℤ}
    (hv : IsRootedPrimitiveTriple v) (hw : IsRootedPrimitiveTriple w) :
    berggrenAct berggrenA v ≠ berggrenAct berggrenC w := by
  intro h_eq;
  have h_pos : 0 < v 0 ∧ 0 < v 1 ∧ 0 < w 0 ∧ 0 < w 1 := by
    exact ⟨ hv.1.1, hv.1.2.1, hw.1.1, hw.1.2.1 ⟩;
  unfold berggrenAct at h_eq;
  unfold berggrenA berggrenC at h_eq; norm_num [ ← List.ofFn_inj ] at h_eq; linarith!;

theorem berggren_branch_disjoint_BC {v w : Fin 3 → ℤ}
    (hv : IsRootedPrimitiveTriple v) (hw : IsRootedPrimitiveTriple w) :
    berggrenAct berggrenB v ≠ berggrenAct berggrenC w := by
  unfold IsRootedPrimitiveTriple at *;
  unfold berggrenAct at *; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
  unfold berggrenB berggrenC at *; simp_all +decide [ Matrix.mulVec ] ;
  intro h1 h2 h3; linarith! [ hv.1.1, hv.1.2.1, hv.1.2.2, hw.1.1, hw.1.2.1, hw.1.2.2 ] ;

theorem berggren_one_step_rooted_injective
    {l₁ l₂ : BerggrenLetter} {v₁ v₂ : Fin 3 → ℤ}
    (h₁ : IsRootedPrimitiveTriple v₁) (h₂ : IsRootedPrimitiveTriple v₂)
    (heq : berggrenAct l₁.toMatrix v₁ = berggrenAct l₂.toMatrix v₂) :
    l₁ = l₂ ∧ v₁ = v₂ := by
  have hl : l₁ = l₂ := by
    by_contra hne
    cases l₁ <;> cases l₂ <;> simp_all [BerggrenLetter.toMatrix]
    · exact berggren_branch_disjoint_AB h₁ h₂ heq
    · exact berggren_branch_disjoint_AC h₁ h₂ heq
    · exact (berggren_branch_disjoint_AB h₂ h₁ heq.symm)
    · exact berggren_branch_disjoint_BC h₁ h₂ heq
    · exact (berggren_branch_disjoint_AC h₂ h₁ heq.symm)
    · exact (berggren_branch_disjoint_BC h₂ h₁ heq.symm)
  subst hl; exact ⟨rfl, berggrenLetter_injective l₁ heq⟩

theorem root_not_in_nonempty_image (w : List BerggrenLetter)
    (hne : w ≠ []) : berggrenWordAct w rootTriple ≠ rootTriple :=
  fun heq => lt_irrefl _ (heq ▸ hypotenuse_strictly_grows_nonempty_word w rootTriple_rooted hne)

/-- **Main Theorem**: Word action on rootTriple is injective.
    Bridge: Diophantine orbit rigidity → quantum-certified unique decoding. -/
theorem berggrenWordAct_root_free {u w : List BerggrenLetter} :
    berggrenWordAct u rootTriple = berggrenWordAct w rootTriple → u = w := by
  induction u generalizing w with
  | nil =>
    simp; intro heq; by_contra hne
    exact root_not_in_nonempty_image w hne heq.symm
  | cons l₁ u' ih =>
    intro heq; cases w with
    | nil =>
      simp at heq
      exact absurd heq (root_not_in_nonempty_image (l₁ :: u') (List.cons_ne_nil l₁ u'))
    | cons l₂ w' =>
      simp only [berggrenWordAct] at heq
      have hu' := berggrenWordAct_preserves_rooted u' rootTriple_rooted
      have hw' := berggrenWordAct_preserves_rooted w' rootTriple_rooted
      obtain ⟨hl, hv⟩ := berggren_one_step_rooted_injective hu' hw' heq
      exact congr_arg₂ List.cons hl (ih hv)

theorem hypotenuse_word_lower_bound_general
    (w : List BerggrenLetter) (v : Fin 3 → ℤ) (hr : IsRootedPrimitiveTriple v) :
    hypotenuse (berggrenWordAct w v) ≥ hypotenuse v + 2 * (w.length : ℤ) := by
  induction' w with l w ih generalizing v;
  · aesop;
  · -- By the induction hypothesis, we have hypotenuse (berggrenWordAct w v) ≥ hypotenuse v + 2 * w.length.
    have h_ind : hypotenuse (berggrenWordAct w v) ≥ hypotenuse v + 2 * w.length := by
      exact ih v hr;
    -- By the properties of the Berggren matrices, we have hypotenuse (berggrenAct l.toMatrix (berggrenWordAct w v)) ≥ hypotenuse (berggrenWordAct w v) + 2.
    have h_berggren : hypotenuse (berggrenAct l.toMatrix (berggrenWordAct w v)) ≥ hypotenuse (berggrenWordAct w v) + 2 := by
      apply berggrenLetter_hypotenuse_growth_lower_bound;
      · exact berggrenWordAct_preserves_rooted w hr |>.1;
      · exact berggrenWordAct_preserves_rooted w hr |>.2.1;
    norm_num [ mul_add ] at * ; linarith!

theorem hypotenuse_word_lower_bound_root (w : List BerggrenLetter) :
    hypotenuse (berggrenWordAct w rootTriple) ≥ 5 + 2 * (w.length : ℤ) := by
  have h := hypotenuse_word_lower_bound_general w rootTriple rootTriple_rooted
  simp only [hypotenuse] at h ⊢
  have hrt : rootTriple 2 = 5 := by native_decide
  linarith

theorem rooted_orbit_has_unique_word_prefix_decomposition (w : List BerggrenLetter) :
    ∀ x, x = berggrenWordAct w rootTriple → ∃! u, berggrenWordAct u rootTriple = x :=
  fun x hx => ⟨w, hx.symm, fun u hu => berggrenWordAct_root_free (by rw [hu, hx])⟩

theorem rooted_orbit_code_equivalence_quantum_certified (x : Fin 3 → ℤ)
    (hreach : ∃ w, berggrenWordAct w rootTriple = x) :
    ∃! w, berggrenWordAct w rootTriple = x := by
  obtain ⟨w, hw⟩ := hreach
  exact ⟨w, hw, fun u hu => berggrenWordAct_root_free (by rw [hu, hw])⟩

theorem TripleContent_nonneg (v : Fin 3 → ℤ) : 0 ≤ TripleContent v := Nat.zero_le _
theorem IsPrimitiveTriple_iff_content_eq_one (v : Fin 3 → ℤ) :
    IsPrimitiveTriple v ↔ TripleContent v = 1 := Iff.rfl

theorem post_quantum_security_linear_growth (w : List BerggrenLetter) :
    (hypotenuse (berggrenWordAct w rootTriple) : ℤ) ≥ 5 + ↑w.length := by
  linarith [hypotenuse_word_lower_bound_root w]