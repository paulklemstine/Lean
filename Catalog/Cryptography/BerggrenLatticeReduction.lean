import Mathlib

/-!
# Berggren-Tree Lattice Reduction and Shortest-Word Rigidity

## Overview

We formalize prefix-rigidity theorems for the positive Berggren semigroup
acting on primitive Pythagorean triples. The Berggren tree is viewed as a
**noncommutative geometric code**: words whose images are close must share structure.

## Word convention

A word `[g₁, g₂, ..., gₙ]` evaluates as `g₁(g₂(...(gₙ(root))...))`.
The **suffix** of a word (tail end) represents generators applied first (near root).
The **prefix** (head) represents the outermost generators.
Extending a tree path deeper means **prepending** to the word.

## Main Results

* `evalWord_append` — prefix factorization of evaluation
* `height_lower_bound_length` — height grows linearly with word length
* `evalAtRoot_injective` — evaluation is injective (freeness)
* `first_letter_divergence` — distinct first letters ⟹ positive distance
* `prefix_rigidity_exact` — geoDist = 0 ⟺ same word
* `candidateWordSet_finite` — candidate sets are finite
* `prune_prepend_sound` — sound branch-and-bound pruning
* `finite_nearby_words` — finite ambiguity at bounded distance
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false

/-! ## Section 1: Core Definitions -/

/-- The three Berggren generators. -/
inductive BerggrenGen : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

instance : Fintype BerggrenGen where
  elems := {.A, .B, .C}
  complete x := by cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BerggrenWord := List BerggrenGen

/-- A triple of integers. -/
abbrev Triple := ℤ × ℤ × ℤ

/-- Action of a single Berggren generator on a triple. -/
def actGen (g : BerggrenGen) (t : Triple) : Triple :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
def rootTriple : Triple := (3, 4, 5)

/-- Evaluate a Berggren word on a triple. -/
def evalWord : BerggrenWord → Triple → Triple
  | [], t => t
  | g :: rest, t => actGen g (evalWord rest t)

/-- Evaluate a word starting from the root triple. -/
def evalAtRoot (w : BerggrenWord) : Triple := evalWord w rootTriple

/-- A triple is *good* if positive and Pythagorean. -/
def GoodTriple (t : Triple) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-! ## Section 2: Basic evalWord lemmas -/

@[simp] theorem evalWord_nil (t : Triple) : evalWord [] t = t := rfl

@[simp] theorem evalWord_cons (g : BerggrenGen) (w : BerggrenWord) (t : Triple) :
    evalWord (g :: w) t = actGen g (evalWord w t) := rfl

theorem evalWord_append (u v : BerggrenWord) (t : Triple) :
    evalWord (u ++ v) t = evalWord u (evalWord v t) := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih]

theorem evalAtRoot_eq (w : BerggrenWord) : evalAtRoot w = evalWord w rootTriple := rfl

/-! ## Section 3: GoodTriple preservation -/

theorem root_good : GoodTriple rootTriple := by
  exact ⟨by norm_num [rootTriple], by norm_num [rootTriple],
    by norm_num [rootTriple], by norm_num [rootTriple]⟩

theorem actGen_preserves_good (g : BerggrenGen) {t : Triple} (ht : GoodTriple t) :
    GoodTriple (actGen g t) := by
      cases g <;> unfold actGen <;> simp_all +decide [ GoodTriple ];
      · exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩;
      · grind;
      · exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩

theorem evalWord_preserves_good (w : BerggrenWord) {t : Triple} (ht : GoodTriple t) :
    GoodTriple (evalWord w t) := by
  induction w with
  | nil => exact ht
  | cons g rest ih => exact actGen_preserves_good g ih

theorem evalAtRoot_good (w : BerggrenWord) : GoodTriple (evalAtRoot w) :=
  evalWord_preserves_good w root_good

/-! ## Section 4: Height -/

/-- Height = absolute value of hypotenuse. -/
def tripleHeight (t : Triple) : ℕ := Int.natAbs t.2.2

theorem tripleHeight_eq_hyp {t : Triple} (ht : GoodTriple t) :
    (tripleHeight t : ℤ) = t.2.2 :=
  Int.natAbs_of_nonneg (le_of_lt ht.2.2.1)

theorem hyp_ge_five {t : Triple} (ht : GoodTriple t) : 5 ≤ t.2.2 := by
  obtain ⟨ ha, hb, hc, h ⟩ := ht;
  by_contra! h' ; interval_cases t.2.2 <;> norm_num at * <;> have := ( show t.1 ≤ 4 by nlinarith only [ h, h' ] ) <;> interval_cases t.1 <;> have := ( show t.2.1 ≤ 4 by nlinarith only [ h, h' ] ) <;> interval_cases t.2.1 <;> trivial;

theorem tripleHeight_ge_five {t : Triple} (ht : GoodTriple t) : 5 ≤ tripleHeight t := by
  have h := hyp_ge_five ht
  have h2 := tripleHeight_eq_hyp ht
  omega

theorem hyp_strictly_increases (g : BerggrenGen) {t : Triple} (ht : GoodTriple t) :
    t.2.2 < (actGen g t).2.2 := by
      cases g <;> rcases t with ⟨ a, b, c ⟩ <;> simp +decide [ actGen ] <;> rcases ht with ⟨ ha, hb, hc, h ⟩ <;> nlinarith

theorem tripleHeight_strict_mono (g : BerggrenGen) {t : Triple} (ht : GoodTriple t) :
    tripleHeight t < tripleHeight (actGen g t) := by
  have h1 := hyp_strictly_increases g ht
  have h2 := tripleHeight_eq_hyp ht
  have h3 := tripleHeight_eq_hyp (actGen_preserves_good g ht)
  omega

theorem height_lower_bound_length (w : BerggrenWord) {t : Triple} (ht : GoodTriple t) :
    tripleHeight t + w.length ≤ tripleHeight (evalWord w t) := by
  induction w with
  | nil => simp
  | cons g rest ih =>
    simp only [evalWord_cons, List.length_cons]
    have := tripleHeight_strict_mono g (evalWord_preserves_good rest ht)
    omega

theorem height_lower_bound_root (w : BerggrenWord) :
    5 + w.length ≤ tripleHeight (evalAtRoot w) := by
  have h := height_lower_bound_length w root_good
  have h2 := tripleHeight_ge_five root_good
  simp only [evalAtRoot] at h ⊢
  omega

/-- Prepending generators increases height. -/
theorem height_mono_prepend (gs w : BerggrenWord) :
    tripleHeight (evalAtRoot w) ≤ tripleHeight (evalAtRoot (gs ++ w)) := by
  simp only [evalAtRoot_eq, evalWord_append]
  have h := height_lower_bound_length gs (evalWord_preserves_good w root_good)
  omega

/-! ## Section 5: Generator injectivity and unique parent -/

theorem actGen_injective (g : BerggrenGen) : Function.Injective (actGen g) := by
  rcases g with ( _ | _ | _ ) <;> unfold actGen <;> simp_all +decide;
  · norm_num [ Function.Injective, Prod.ext_iff ];
    grind;
  · exact fun x y h => by norm_num at h; exact Prod.ext ( by linarith ) ( Prod.ext ( by linarith ) ( by linarith ) ) ;
  · norm_num [ Function.Injective ];
    grind

/-- First discriminant. -/
def discX (t : Triple) : ℤ := t.1 + 2 * t.2.1 - 2 * t.2.2

/-- Second discriminant. -/
def discY (t : Triple) : ℤ := 2 * t.1 + t.2.1 - 2 * t.2.2

@[simp] theorem discX_A (t : Triple) : discX (actGen .A t) = t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discX_B (t : Triple) : discX (actGen .B t) = t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discX_C (t : Triple) : discX (actGen .C t) = -t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discY_A (t : Triple) : discY (actGen .A t) = -t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

@[simp] theorem discY_B (t : Triple) : discY (actGen .B t) = t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

@[simp] theorem discY_C (t : Triple) : discY (actGen .C t) = t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

/-
Discriminant classifier.
-/
theorem actGen_generator_determined {g₁ g₂ : BerggrenGen} {t₁ t₂ : Triple}
    (ht₁ : GoodTriple t₁) (ht₂ : GoodTriple t₂)
    (h : actGen g₁ t₁ = actGen g₂ t₂) : g₁ = g₂ := by
      rcases g₁ with ( _ | _ | _ | g₁ ) <;> rcases g₂ with ( _ | _ | _ | g₂ ) <;> norm_cast at * <;> simp_all +decide [ GoodTriple ];
      all_goals unfold actGen at h; simp_all +decide [ Prod.ext_iff ] ;
      all_goals nlinarith only [ h, ht₁, ht₂ ] ;

/-- Unique parent. -/
theorem actGen_unique_parent {g₁ g₂ : BerggrenGen} {t₁ t₂ : Triple}
    (ht₁ : GoodTriple t₁) (ht₂ : GoodTriple t₂)
    (h : actGen g₁ t₁ = actGen g₂ t₂) : g₁ = g₂ ∧ t₁ = t₂ := by
  have hg := actGen_generator_determined ht₁ ht₂ h
  subst hg
  exact ⟨rfl, actGen_injective g₁ h⟩

/-- Root is not in the image of any generator. -/
theorem actGen_ne_root (g : BerggrenGen) {t : Triple} (ht : GoodTriple t) :
    actGen g t ≠ rootTriple := by
  intro h
  have h1 := hyp_strictly_increases g ht
  have h2 : (actGen g t).2.2 = 5 := by rw [h]; rfl
  have h3 := hyp_ge_five ht
  linarith

/-! ## Section 6: Freeness -/

/-- evalAtRoot is injective: distinct words produce distinct triples. -/
theorem evalAtRoot_injective : Function.Injective evalAtRoot := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso
      exact actGen_ne_root g (evalWord_preserves_good rest root_good) h.symm
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso
      exact actGen_ne_root g₁ (evalWord_preserves_good rest₁ root_good) h
    | g₂ :: rest₂ =>
      have ⟨hg, hp⟩ := actGen_unique_parent
        (evalWord_preserves_good rest₁ root_good)
        (evalWord_preserves_good rest₂ root_good) h
      subst hg; congr 1; exact ih hp

/-! ## Section 7: Longest Common Prefix -/

/-- Length of the longest common prefix. -/
def lcpLength : BerggrenWord → BerggrenWord → ℕ
  | [], _ => 0
  | _, [] => 0
  | a :: as, b :: bs => if a = b then 1 + lcpLength as bs else 0

/-- The longest common prefix word. -/
def lcpWord : BerggrenWord → BerggrenWord → BerggrenWord
  | [], _ => []
  | _, [] => []
  | a :: as, b :: bs => if a = b then a :: lcpWord as bs else []

theorem lcpLength_eq_lcpWord_length (u v : BerggrenWord) :
    lcpLength u v = (lcpWord u v).length := by
  induction u generalizing v with
  | nil => simp [lcpLength, lcpWord]
  | cons a as ih =>
    cases v with
    | nil => simp [lcpLength, lcpWord]
    | cons b bs =>
      simp only [lcpLength, lcpWord]
      split
      · simp [ih bs]; omega
      · simp

theorem lcpLength_le_left (u v : BerggrenWord) : lcpLength u v ≤ u.length := by
  induction u generalizing v with
  | nil => simp [lcpLength]
  | cons a as ih =>
    cases v with
    | nil => simp [lcpLength]
    | cons b bs =>
      simp only [lcpLength, List.length_cons]
      split <;> [have := ih bs; skip] <;> omega

theorem lcpLength_le_right (u v : BerggrenWord) : lcpLength u v ≤ v.length := by
  induction u generalizing v with
  | nil => simp [lcpLength]
  | cons a as ih =>
    cases v with
    | nil => simp [lcpLength]
    | cons b bs =>
      simp only [lcpLength, List.length_cons]
      split <;> [have := ih bs; skip] <;> omega

theorem lcpWord_prefix_left (u v : BerggrenWord) : lcpWord u v <+: u := by
  induction u generalizing v with
  | nil => exact List.nil_prefix
  | cons a as ih =>
    cases v with
    | nil => exact List.nil_prefix
    | cons b bs =>
      simp only [lcpWord]; split
      · next h => subst h; exact List.cons_prefix_cons.mpr ⟨rfl, ih bs⟩
      · exact List.nil_prefix

theorem lcpWord_prefix_right (u v : BerggrenWord) : lcpWord u v <+: v := by
  induction u generalizing v with
  | nil => exact List.nil_prefix
  | cons a as ih =>
    cases v with
    | nil => exact List.nil_prefix
    | cons b bs =>
      simp only [lcpWord]; split
      · next h => subst h; exact List.cons_prefix_cons.mpr ⟨rfl, ih bs⟩
      · exact List.nil_prefix

/-
After the LCP, the remaining suffixes start with different letters (or one is empty).
-/
theorem exists_prefix_split (u v : BerggrenWord) :
    ∃ p u' v',
      u = p ++ u' ∧
      v = p ++ v' ∧
      lcpLength u v = p.length ∧
      (u' = [] ∨ v' = [] ∨ u'.head? ≠ v'.head?) := by
        induction' u with a u ih generalizing v;
        · cases v <;> aesop;
        · induction' v with b v ih';
          · exact ⟨ [ ], a :: u, [ ], rfl, rfl, rfl, by tauto ⟩;
          · by_cases hab : a = b;
            · obtain ⟨ p, u', v', hu, hv, h₁, h₂ ⟩ := ih v;
              use a :: p, u', v';
              simp_all +decide [ lcpLength ];
              ring;
            · use [], a :: u, b :: v;
              simp [hab, lcpLength]

/-! ## Section 8: Geometric Distance -/

/-- L∞ distance on triples. -/
def geoDist (t₁ t₂ : Triple) : ℕ :=
  max (Int.natAbs (t₁.1 - t₂.1))
    (max (Int.natAbs (t₁.2.1 - t₂.2.1))
      (Int.natAbs (t₁.2.2 - t₂.2.2)))

theorem geoDist_self (t : Triple) : geoDist t t = 0 := by simp [geoDist]

theorem geoDist_comm (t₁ t₂ : Triple) : geoDist t₁ t₂ = geoDist t₂ t₁ := by
  simp only [geoDist]
  rw [show t₁.1 - t₂.1 = -(t₂.1 - t₁.1) by ring, Int.natAbs_neg,
      show t₁.2.1 - t₂.2.1 = -(t₂.2.1 - t₁.2.1) by ring, Int.natAbs_neg,
      show t₁.2.2 - t₂.2.2 = -(t₂.2.2 - t₁.2.2) by ring, Int.natAbs_neg]

theorem geoDist_eq_zero_iff {t₁ t₂ : Triple} : geoDist t₁ t₂ = 0 ↔ t₁ = t₂ := by
  unfold geoDist;
  grind

theorem geoDist_ge_hyp_diff (t₁ t₂ : Triple) :
    Int.natAbs (t₁.2.2 - t₂.2.2) ≤ geoDist t₁ t₂ := by
  simp [geoDist]

/-! ## Section 9: Key Rigidity Theorems -/

/-- Distinct first letters ⟹ positive distance. -/
theorem first_letter_divergence {g h : BerggrenGen} {u v : BerggrenWord}
    (hgh : g ≠ h) :
    0 < geoDist (evalAtRoot (g :: u)) (evalAtRoot (h :: v)) := by
  rw [Nat.pos_iff_ne_zero]; intro hzero
  rw [geoDist_eq_zero_iff] at hzero
  exact hgh (actGen_generator_determined
    (evalWord_preserves_good u root_good)
    (evalWord_preserves_good v root_good) hzero)

/-- Distinct words ⟹ positive distance. -/
theorem distinct_words_positive_dist {u v : BerggrenWord} (hne : u ≠ v) :
    0 < geoDist (evalAtRoot u) (evalAtRoot v) := by
  rw [Nat.pos_iff_ne_zero]; intro h
  rw [geoDist_eq_zero_iff] at h
  exact hne (evalAtRoot_injective h)

/-- **Main rigidity**: geoDist = 0 ⟺ same word. -/
theorem prefix_rigidity_exact {u v : BerggrenWord} :
    geoDist (evalAtRoot u) (evalAtRoot v) = 0 ↔ u = v := by
  constructor
  · intro h; rw [geoDist_eq_zero_iff] at h; exact evalAtRoot_injective h
  · rintro rfl; exact geoDist_self _

/-- Height lower bound from LCP length. -/
theorem height_ge_lcp_plus_five (u v : BerggrenWord) :
    5 + lcpLength u v ≤ min (tripleHeight (evalAtRoot u)) (tripleHeight (evalAtRoot v)) := by
  have hu := height_lower_bound_root u
  have hv := height_lower_bound_root v
  have hlcp_u := lcpLength_le_left u v
  have hlcp_v := lcpLength_le_right u v
  omega

/-! ## Section 10: Candidate sets -/

/-- Candidate word set: words of bounded length whose height is close to target. -/
def candidateWordSet (n : ℕ) (targetH : ℕ) (ε : ℕ) : Set BerggrenWord :=
  {w : BerggrenWord | w.length ≤ n ∧
    Int.natAbs ((evalAtRoot w).2.2 - ↑targetH) ≤ ε}

/-- Candidate sets are finite. -/
theorem candidateWordSet_finite (n targetH ε : ℕ) :
    Set.Finite (candidateWordSet n targetH ε) :=
  Set.Finite.subset (List.finite_length_le _ n) (fun _ hw => hw.1)

/-- Evaluation is injective on candidate sets. -/
theorem candidateWordSet_injOn (n targetH ε : ℕ) :
    Set.InjOn evalAtRoot (candidateWordSet n targetH ε) :=
  fun _ _ _ _ h => evalAtRoot_injective h

/-- Finiteness of words bounded by height. -/
theorem finitely_many_words_bounded_height (H : ℕ) :
    Set.Finite {w : BerggrenWord | tripleHeight (evalAtRoot w) ≤ H} := by
  apply Set.Finite.subset (List.finite_length_le _ H)
  intro w hw
  simp only [Set.mem_setOf_eq] at hw ⊢
  by_contra hlen; push_neg at hlen
  have := height_lower_bound_root w; omega

/-- **Finite ambiguity**: finitely many words land near any given triple. -/
theorem finite_nearby_words (w₀ : BerggrenWord) (R : ℕ) :
    Set.Finite {v : BerggrenWord |
      geoDist (evalAtRoot w₀) (evalAtRoot v) ≤ R} := by
  apply Set.Finite.subset (finitely_many_words_bounded_height (tripleHeight (evalAtRoot w₀) + R))
  intro v hv
  simp only [Set.mem_setOf_eq] at hv ⊢
  have hdiff := geoDist_ge_hyp_diff (evalAtRoot w₀) (evalAtRoot v)
  have hgw := evalAtRoot_good w₀
  have hgv := evalAtRoot_good v
  have hw_eq := tripleHeight_eq_hyp hgw
  have hv_eq := tripleHeight_eq_hyp hgv
  omega

/-! ## Section 11: Pruning -/

/-- Height of a prepended word is at least as large. -/
theorem height_prepend_mono (gs w : BerggrenWord) :
    tripleHeight (evalAtRoot w) ≤ tripleHeight (evalAtRoot (gs ++ w)) := by
  simp only [evalAtRoot_eq, evalWord_append]
  have := height_lower_bound_length gs (evalWord_preserves_good w root_good)
  omega

/-- **Sound pruning**: if a partial word's height already overshoots the target,
    prepending more generators only increases the height further. -/
theorem prune_prepend_sound
    (w : BerggrenWord) (targetH slack : ℕ)
    (hovershoot : targetH + slack < tripleHeight (evalAtRoot w))
    (gs : BerggrenWord) :
    targetH + slack < tripleHeight (evalAtRoot (gs ++ w)) := by
  have := height_prepend_mono gs w; omega

/-- Pruning excludes candidates: if a suffix already overshoots, no extension
    of it can be a candidate. -/
theorem prune_excludes_candidates
    (w : BerggrenWord) (n targetH ε : ℕ)
    (hovershoot : targetH + ε < tripleHeight (evalAtRoot w))
    (gs : BerggrenWord) :
    (gs ++ w) ∉ candidateWordSet n targetH ε := by
  intro ⟨_, hw_close⟩
  have h := prune_prepend_sound w targetH ε hovershoot gs
  have hgood := evalAtRoot_good (gs ++ w)
  have := tripleHeight_eq_hyp hgood
  omega

/-! ## Section 12: Concrete computations -/

theorem actGen_A_root : actGen .A rootTriple = (5, 12, 13) := by native_decide
theorem actGen_B_root : actGen .B rootTriple = (21, 20, 29) := by native_decide
theorem actGen_C_root : actGen .C rootTriple = (15, 8, 17) := by native_decide

/-- Root children are pairwise distinct. -/
theorem root_children_pairwise_distinct :
    actGen .A rootTriple ≠ actGen .B rootTriple ∧
    actGen .A rootTriple ≠ actGen .C rootTriple ∧
    actGen .B rootTriple ≠ actGen .C rootTriple :=
  ⟨by decide, by decide, by decide⟩

/-! ## Section 13: Certified search -/

/-- **Main certified search theorem**: candidate sets are finite with injective
    evaluation, and height-based pruning is sound. -/
theorem certified_search (n targetH ε : ℕ) :
    Set.Finite (candidateWordSet n targetH ε) ∧
    Set.InjOn evalAtRoot (candidateWordSet n targetH ε) :=
  ⟨candidateWordSet_finite n targetH ε, candidateWordSet_injOn n targetH ε⟩

/-- Search completeness: any word meeting the criteria is in the candidate set. -/
theorem search_completeness
    (n targetH ε : ℕ) (w : BerggrenWord)
    (hw_len : w.length ≤ n)
    (hw_close : Int.natAbs ((evalAtRoot w).2.2 - ↑targetH) ≤ ε) :
    w ∈ candidateWordSet n targetH ε :=
  ⟨hw_len, hw_close⟩

/-! ## Axiom verification -/

#print axioms evalWord_append
#print axioms height_lower_bound_length
#print axioms evalAtRoot_injective
#print axioms first_letter_divergence
#print axioms prefix_rigidity_exact
#print axioms candidateWordSet_finite
#print axioms prune_prepend_sound
#print axioms prune_excludes_candidates
#print axioms certified_search
#print axioms finite_nearby_words