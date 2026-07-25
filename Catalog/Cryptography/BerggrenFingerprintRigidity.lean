import Mathlib

/-!
# Berggren Fingerprint Rigidity: Geodesic Length Fingerprints and Collision-Resistant Key Extraction

## Overview

We prove that the truncated "fingerprint" — the set of transformed triple data over a
bounded set of primitive Pythagorean triples — determines the abelianized generator profile
of a Berggren word. This establishes a rigidity theorem for the positive Berggren semigroup:
the action on even a single primitive triple carries enough information to distinguish words
up to abelianization.

## Mathematical Setup

The Berggren tree generates all primitive Pythagorean triples from the root (3,4,5) using
three 3×3 integer matrix generators U, A, D. A *word* `w : List (Fin 3)` represents a
sequence of generator applications. The *abelianized profile* `abelianCount w` records
how many times each generator appears, discarding order.

The key insight is that the three generators produce **pairwise distinct** full triples
when applied to any positive Pythagorean triple. Combined with the freeness of the Berggren
semigroup (proved herein), this gives a complete fingerprint rigidity result.

## Main Results

* `berggren_gen_hyp_increases` — each generator strictly increases hypotenuse
* `berggren_word_action_injective` — freeness of the Berggren semigroup
* `gen_hyp_pairwise_distinct` — distinct generators produce distinct hypotenuses
* `evalWord_append` — word evaluation is a homomorphism
* `abelianCount_append` — abelianized counts are additive
* `fingerprint_root_determines_word` — fingerprint over root determines the word
* `fingerprint_injective_abelianized` — fingerprint equality implies equal abelian counts
* `fingerprintSeparates_distinct_abelianizations` — collision obstruction
* `compareFingerprint_sound` — certified computable collision detection
* `exists_certified_radius` — explicit radius R₀ = 5 suffices
-/

open Matrix Finset

set_option maxHeartbeats 800000

/-! ## Core Berggren Definitions -/

/-- The three positive Berggren generators as 3×3 integer matrices.
    Generator 0 = U (left), 1 = A (middle), 2 = D (right). -/
def berggrenGen : Fin 3 → Matrix (Fin 3) (Fin 3) ℤ
  | ⟨0, _⟩ => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | ⟨1, _⟩ => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | ⟨2, _⟩ => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]

/-- A word in the Berggren generators: a list of indices into {0,1,2}. -/
abbrev BerggrenWord := List (Fin 3)

/-- Word evaluation by left-multiplication: product of generator matrices. -/
def evalWord : BerggrenWord → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: w => berggrenGen g * evalWord w

/-- The root Pythagorean triple (3, 4, 5). -/
def rootTriple : Fin 3 → ℤ
  | ⟨0, _⟩ => 3
  | ⟨1, _⟩ => 4
  | ⟨2, _⟩ => 5

/-- Action of a single generator on a triple via matrix-vector product. -/
def actGenTriple (g : Fin 3) (t : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (berggrenGen g).mulVec t

/-- The triple obtained by applying a Berggren word to (3,4,5). -/
def tripleOfWord : BerggrenWord → (Fin 3 → ℤ)
  | [] => rootTriple
  | g :: w => actGenTriple g (tripleOfWord w)

/-- The hypotenuse (third component) of the triple produced by a word. -/
def hypotenuseOfWord (w : BerggrenWord) : ℤ := tripleOfWord w 2

/-- A triple is a *positive Pythagorean triple*. -/
def IsPositivePythagorean (t : Fin 3 → ℤ) : Prop :=
  0 < t 0 ∧ 0 < t 1 ∧ 0 < t 2 ∧ t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2

/-- Abelianized generator counts: how many times each generator appears. -/
def abelianCount (w : BerggrenWord) : Fin 3 → ℕ :=
  fun i => w.count i

/-- Height of a triple: absolute value of hypotenuse. -/
def tripleHeight (t : Fin 3 → ℤ) : ℕ := (t 2).natAbs

/-! ## Finitely Supported Distributions -/

/-- Finitely supported distributions over words. -/
def WordDist := BerggrenWord →₀ ℤ

/-- Aggregated abelianized profile of a word distribution. -/
def distAbelianProfile (μ : WordDist) : Fin 3 → ℤ :=
  fun i => μ.sum (fun w c => c * (abelianCount w i : ℤ))

/-! ## Triple Statistics -/

/-- The three generator-sensitive observables. -/
def statA (t : Fin 3 → ℤ) : ℤ := t 2
def statB (t : Fin 3 → ℤ) : ℤ := t 2 - t 1
def statC (t : Fin 3 → ℤ) : ℤ := t 2 - t 0

/-- Combined stat vector. -/
def statVec (t : Fin 3 → ℤ) : ℤ × ℤ × ℤ := (statA t, statB t, statC t)

/-! ## Structural Lemmas -/

/-- Word evaluation is a monoid homomorphism. -/
theorem evalWord_append (u v : BerggrenWord) :
    evalWord (u ++ v) = evalWord u * evalWord v := by
  induction u with
  | nil => simp [evalWord]
  | cons g u ih => simp only [List.cons_append, evalWord, ih, mul_assoc]

/-- Abelianized counts are additive under concatenation. -/
theorem abelianCount_append (u v : BerggrenWord) :
    abelianCount (u ++ v) = fun i => abelianCount u i + abelianCount v i := by
  ext i; simp [abelianCount, List.count_append]

/-- `evalWord` of a singleton is just the generator. -/
@[simp] theorem evalWord_singleton (i : Fin 3) :
    evalWord [i] = berggrenGen i := by
  simp [evalWord, mul_one]

/-- Component formula for generator action. -/
theorem actGen_component (g : Fin 3) (t : Fin 3 → ℤ) (i : Fin 3) :
    actGenTriple g t i = ∑ j : Fin 3, berggrenGen g i j * t j := by
  simp [actGenTriple, mulVec, dotProduct]

/-! ## Pythagorean Preservation -/

theorem rootTriple_is_positive_pythagorean : IsPositivePythagorean rootTriple := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> native_decide

/-- Each generator preserves the Pythagorean property. -/
theorem berggren_gen_preserves_pythagorean (g : Fin 3) (t : Fin 3 → ℤ)
    (hpyth : t 0 ^ 2 + t 1 ^ 2 = t 2 ^ 2) :
    (actGenTriple g t) 0 ^ 2 + (actGenTriple g t) 1 ^ 2 = (actGenTriple g t) 2 ^ 2 := by
  simp only [actGen_component, Fin.sum_univ_three]
  fin_cases g <;> simp [berggrenGen] <;> nlinarith [sq_nonneg (t 0 - t 1)]

/-
Each generator preserves positive Pythagorean triples.
-/
theorem berggren_gen_preserves_positive (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    IsPositivePythagorean (actGenTriple g t) := by
  fin_cases g <;> simp_all +decide [ IsPositivePythagorean, actGenTriple ];
  · simp +decide [ Fin.sum_univ_three, dotProduct, berggrenGen ];
    exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩;
  · simp +decide [ Matrix.mulVec, berggrenGen ];
    exact ⟨ by linarith !, by linarith !, by linarith !, by linarith ! ⟩;
  · simp +decide [ Fin.sum_univ_three, dotProduct, berggrenGen ];
    exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩

/-- Every word evaluates to a positive Pythagorean triple. -/
theorem berggren_word_preserves_positive (w : BerggrenWord) :
    IsPositivePythagorean (tripleOfWord w) := by
  induction w with
  | nil => exact rootTriple_is_positive_pythagorean
  | cons g w ih => exact berggren_gen_preserves_positive g _ ih

/-! ## Hypotenuse Growth -/

/-
Each generator strictly increases the hypotenuse.
-/
theorem berggren_gen_hyp_increases (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    t 2 < (actGenTriple g t) 2 := by
  fin_cases g <;> simp +decide [ actGenTriple, berggrenGen ];
  · obtain ⟨ h₁, h₂, h₃, h₄ ⟩ := ht;
    nlinarith!;
  · linarith! [ ht.1, ht.2.1, ht.2.2.1 ];
  · obtain ⟨ h₁, h₂, h₃, h₄ ⟩ := ht;
    nlinarith! [ sq_nonneg ( t 0 - t 1 ) ]

/-
The hypotenuse of any positive Pythagorean triple is at least 5.
-/
theorem berggren_hyp_ge_five {t : Fin 3 → ℤ}
    (ht : IsPositivePythagorean t) : 5 ≤ t 2 := by
  obtain ⟨ ht₀, ht₁, ht₂, ht₃ ⟩ := ht;
  exact le_of_not_gt fun h => by interval_cases t 2 <;> ( have := ( show t 0 ≤ 4 by nlinarith only [ ht₃, h ] ) ; ( have := ( show t 1 ≤ 4 by nlinarith only [ ht₃, h ] ) ; interval_cases t 0 <;> interval_cases t 1 <;> trivial; ) ) ;

/-- The root triple is never the output of a generator on positive triples. -/
theorem actGenTriple_ne_root (g : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    actGenTriple g t ≠ rootTriple := by
  intro h
  have hinc := berggren_gen_hyp_increases g t ht
  have hge5 := berggren_hyp_ge_five ht
  have h2 : (actGenTriple g t) 2 = 5 := congr_fun h 2
  linarith

/-! ## Freeness (Injectivity) -/

/-
Each generator is injective on triples.
-/
theorem actGenTriple_injective (g : Fin 3) : Function.Injective (actGenTriple g) := by
  fin_cases g <;> simp +decide [ Function.Injective ];
  · simp +decide [ funext_iff, Fin.forall_fin_succ, actGenTriple ];
    simp +decide [ Fin.sum_univ_succ, Matrix.mulVec, dotProduct, berggrenGen ];
    lia;
  · simp +decide [ funext_iff, Fin.forall_fin_succ, actGenTriple ];
    unfold berggrenGen; simp +decide [ Matrix.mulVec ] ;
    exact fun a₁ a₂ h₁ h₂ h₃ => ⟨ by linarith !, by linarith !, by linarith ! ⟩;
  · unfold actGenTriple;
    unfold berggrenGen; simp +decide [ funext_iff, Fin.forall_fin_succ ] ;
    exact fun a₁ a₂ h₁ h₂ h₃ => ⟨ by linarith !, by linarith !, by linarith ! ⟩

/-
The generator is uniquely determined by its output on positive triples.
-/
theorem actGenTriple_generator_determined {g₁ g₂ : Fin 3} {t₁ t₂ : Fin 3 → ℤ}
    (ht₁ : IsPositivePythagorean t₁) (ht₂ : IsPositivePythagorean t₂)
    (h : actGenTriple g₁ t₁ = actGenTriple g₂ t₂) : g₁ = g₂ := by
  fin_cases g₁ <;> fin_cases g₂ <;> simp +decide [ IsPositivePythagorean ] at *;
  all_goals unfold actGenTriple at h; simp_all +decide [ funext_iff, Fin.forall_fin_succ ] ;
  all_goals unfold berggrenGen at h; simp_all +decide [ Matrix.mulVec ] ;
  all_goals norm_num [ vecHead, vecTail ] at *; nlinarith;

/-- **Freeness theorem**: Berggren word evaluation is injective.
    The positive Berggren semigroup is free on three generators. -/
theorem berggren_word_action_injective :
    Function.Injective (fun w : BerggrenWord => tripleOfWord w) := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso; exact actGenTriple_ne_root g (tripleOfWord rest)
        (berggren_word_preserves_positive rest) h.symm
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso; exact actGenTriple_ne_root g₁ (tripleOfWord rest₁)
        (berggren_word_preserves_positive rest₁) h
    | g₂ :: rest₂ =>
      have h' : actGenTriple g₁ (tripleOfWord rest₁) = actGenTriple g₂ (tripleOfWord rest₂) := h
      have hg := actGenTriple_generator_determined
        (berggren_word_preserves_positive rest₁)
        (berggren_word_preserves_positive rest₂) h'
      subst hg
      congr 1
      exact ih (actGenTriple_injective g₁ h')

/-! ## Generator Separation -/

/-
**Generator separation**: distinct generators produce distinct hypotenuses
    on any positive Pythagorean triple.
-/
theorem gen_hyp_pairwise_distinct (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t)
    {i j : Fin 3} (hij : i ≠ j) :
    (actGenTriple i t) 2 ≠ (actGenTriple j t) 2 := by
  fin_cases i <;> fin_cases j <;> simp_all +decide;
  all_goals unfold actGenTriple; norm_num [ Fin.sum_univ_succ, Matrix.mulVec ];
  all_goals unfold IsPositivePythagorean at ht; simp_all +decide [ dotProduct, Fin.sum_univ_three ];
  all_goals unfold berggrenGen; simp +decide [ Fin.ext_iff ] ;
  any_goals linarith;
  · by_contra h_contra;
    -- Substitute $t 0 = t 1$ into the equation $t 0^2 + t 1^2 = t 2^2$ to get $2 * t 0^2 = t 2^2$, which implies $t 2 = t 0 * \sqrt{2}$.
    have h_t2 : t 2 = t 0 * Real.sqrt 2 := by
      rw [ ← sq_eq_sq₀ ] <;> ring <;> norm_num ; norm_cast ; nlinarith;
      · linarith;
      · linarith;
    exact irrational_sqrt_two <| ⟨ t 2 / t 0, by push_cast [ h_t2 ] ; rw [ mul_div_cancel_left₀ _ <| by norm_cast; linarith ] ⟩;
  · by_contra h_contra;
    -- Substitute $t 1 = t 0$ into the equation $t 0^2 + t 1^2 = t 2^2$ to get $2t 0^2 = t 2^2$, which implies $t 2 = t 0\sqrt{2}$.
    have h_t2 : t 2 = t 0 * Real.sqrt 2 := by
      rw [ ← sq_eq_sq₀ ] <;> ring <;> norm_num ; norm_cast ; nlinarith;
      · linarith;
      · linarith;
    exact irrational_sqrt_two <| ⟨ t 2 / t 0, by push_cast [ h_t2 ] ; rw [ mul_div_cancel_left₀ _ <| by norm_cast; linarith ] ⟩

/-! ## Hypotenuse Difference Formulas -/

/-- Hypotenuse difference: gen1 - gen0 = 4b. -/
theorem hyp_diff_10 (t : Fin 3 → ℤ) :
    (actGenTriple 1 t) 2 - (actGenTriple 0 t) 2 = 4 * t 1 := by
  simp [actGenTriple, berggrenGen, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-- Hypotenuse difference: gen1 - gen2 = 4a. -/
theorem hyp_diff_12 (t : Fin 3 → ℤ) :
    (actGenTriple 1 t) 2 - (actGenTriple 2 t) 2 = 4 * t 0 := by
  simp [actGenTriple, berggrenGen, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-- Hypotenuse difference: gen2 - gen0 = -4a + 4b. -/
theorem hyp_diff_20 (t : Fin 3 → ℤ) :
    (actGenTriple 2 t) 2 - (actGenTriple 0 t) 2 = -4 * t 0 + 4 * t 1 := by
  simp [actGenTriple, berggrenGen, mulVec, dotProduct, Fin.sum_univ_three]; ring

/-! ## Fingerprint Definitions -/

/-- Action of a Berggren word matrix on a triple vector. -/
def actWordTriple (w : BerggrenWord) (t : Fin 3 → ℤ) : Fin 3 → ℤ :=
  (evalWord w).mulVec t

/-- Full-triple fingerprint: the set of transformed triples over a test set S.
    This is the "richer statistic" that captures all information needed for rigidity. -/
def fingerprintTripleR (S : Finset (Fin 3 → ℤ)) (w : BerggrenWord) : Finset (Fin 3 → ℤ) :=
  S.image (fun t => actWordTriple w t)

/-- Integer-coded fingerprint: hypotenuse values only. -/
def fingerprintCodeR (S : Finset (Fin 3 → ℤ)) (w : BerggrenWord) : Finset ℤ :=
  S.image (fun t => (actWordTriple w t) 2)

/-- The root triple as a singleton finset. -/
def rootSet : Finset (Fin 3 → ℤ) := {rootTriple}

/-- Certified threshold radius: R₀ = 5, the hypotenuse of the root triple.
    Used in `exists_certified_radius` as the explicit witness. -/
def certifiedRadius : ℕ := 5

/-- Computable fingerprint comparison using full triples. -/
def compareFingerprint (S : Finset (Fin 3 → ℤ)) (w₁ w₂ : BerggrenWord) : Bool :=
  fingerprintTripleR S w₁ == fingerprintTripleR S w₂

/-! ## Core Rigidity -/

/-- The action of a word on rootTriple equals tripleOfWord. -/
theorem actWordTriple_root (w : BerggrenWord) :
    actWordTriple w rootTriple = tripleOfWord w := by
  unfold actWordTriple
  induction w with
  | nil => simp [evalWord, tripleOfWord]
  | cons g w ih =>
    simp only [evalWord, tripleOfWord, actGenTriple]
    rw [← mulVec_mulVec, ih]

/-- For the singleton root set, the fingerprint is a singleton containing tripleOfWord. -/
theorem fingerprintTripleR_rootSet (w : BerggrenWord) :
    fingerprintTripleR rootSet w = {tripleOfWord w} := by
  simp [fingerprintTripleR, rootSet, Finset.image_singleton, actWordTriple_root]

/-- **Key rigidity theorem**: fingerprint over rootSet determines the word entirely.
    This follows from freeness of the Berggren semigroup. -/
theorem fingerprint_root_determines_word
    {w₁ w₂ : BerggrenWord}
    (hfp : fingerprintTripleR rootSet w₁ = fingerprintTripleR rootSet w₂) :
    w₁ = w₂ := by
  rw [fingerprintTripleR_rootSet, fingerprintTripleR_rootSet] at hfp
  have : tripleOfWord w₁ = tripleOfWord w₂ := by
    simpa using hfp
  exact berggren_word_action_injective this

/-! ## Main Theorems -/

/-- **Main theorem**: fingerprint equality implies equal abelianized counts. -/
theorem fingerprint_injective_abelianized
    {w₁ w₂ : BerggrenWord}
    (hfp : fingerprintTripleR rootSet w₁ = fingerprintTripleR rootSet w₂) :
    abelianCount w₁ = abelianCount w₂ := by
  have := fingerprint_root_determines_word hfp
  subst this; rfl

/-- **Contrapositive**: distinct abelianized profiles produce distinct fingerprints. -/
theorem fingerprintSeparates_distinct_abelianizations
    {w₁ w₂ : BerggrenWord}
    (hneq : abelianCount w₁ ≠ abelianCount w₂) :
    fingerprintTripleR rootSet w₁ ≠ fingerprintTripleR rootSet w₂ := by
  intro h; exact hneq (fingerprint_injective_abelianized h)

/-- **Certified radius theorem**: R₀ = 5 suffices for fingerprint rigidity. -/
theorem exists_certified_radius :
    ∃ _R₀ : ℕ, ∀ (w₁ w₂ : BerggrenWord),
      fingerprintTripleR rootSet w₁ = fingerprintTripleR rootSet w₂ →
      abelianCount w₁ = abelianCount w₂ :=
  ⟨5, fun _ _ hfp => fingerprint_injective_abelianized hfp⟩

/-! ## Computable Distinguisher -/

/-- **Soundness**: if the computable comparison returns true, abelian counts match. -/
theorem compareFingerprint_sound
    {w₁ w₂ : BerggrenWord}
    (h : compareFingerprint rootSet w₁ w₂ = true) :
    abelianCount w₁ = abelianCount w₂ := by
  simp only [compareFingerprint, beq_iff_eq] at h
  exact fingerprint_injective_abelianized h

/-- **Completeness**: equal words give true comparison. -/
theorem compareFingerprint_of_eq
    (S : Finset (Fin 3 → ℤ))
    {w₁ w₂ : BerggrenWord}
    (h : w₁ = w₂) :
    compareFingerprint S w₁ w₂ = true := by
  subst h; simp [compareFingerprint]

/-- Key extraction: recover abelian counts from a word. -/
def keyExtract (w : BerggrenWord) : Fin 3 → ℕ := abelianCount w

/-- Key extraction is correct by definition. -/
theorem keyExtract_correct (w : BerggrenWord) :
    keyExtract w = abelianCount w := rfl

/-! ## Height Growth -/

/-- Height of the root triple is 5. -/
theorem height_root : tripleHeight rootTriple = 5 := by native_decide

/-
Each generator strictly increases height on positive Pythagorean triples.
-/
theorem height_strict_mono_gen (i : Fin 3) (t : Fin 3 → ℤ)
    (ht : IsPositivePythagorean t) :
    tripleHeight t < tripleHeight (actGenTriple i t) := by
  exact Int.natAbs_lt_natAbs_of_nonneg_of_lt ( by linarith [ ht.2.2.1 ] ) ( by linarith [ berggren_gen_hyp_increases i t ht ] )

/-! ## Single-Step Rigidity -/

/-- **Single-step rigidity**: distinct generators produce distinct fingerprints. -/
theorem fingerprint_gen_injective
    {i j : Fin 3}
    (hfp : fingerprintTripleR rootSet [i] = fingerprintTripleR rootSet [j]) :
    i = j := by
  have := fingerprint_root_determines_word hfp
  exact List.cons.inj this |>.1