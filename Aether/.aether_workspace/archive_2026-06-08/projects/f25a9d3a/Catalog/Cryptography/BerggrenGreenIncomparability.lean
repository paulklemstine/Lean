import Mathlib

/-!
# Berggren Semigroup: Green-Order Incomparability and LCM-Free Pair Extraction

We prove that the three Berggren generators, realized as 2×2 integer matrices,
generate a **free semigroup** of rank 3 inside `GL₂(ℤ)`, and use this to
establish two-sided divisibility geometry theorems: the Green-order incomparability
of non-overlapping words in finite balls, and the extraction of lcm-free pairs.

## Overview

The Berggren tree generators A, B, C act on pairs (m,n) with m > n > 0 and
produce a free semigroup. The matrix evaluation map `evalBergWord` is injective,
which means divisibility in the semigroup corresponds exactly to prefix/suffix
relationships at the word level. From this we derive:

1. **Left/Right overlap rigidity**: Equal products force one factor to extend another.
2. **Green-order incomparability**: Non-overlapping words have no common left or right
   multiples, ruling out "merge attacks" in cryptographic applications.
3. **LCM-free pair extraction**: Every ball of radius ≥ 1 contains an explicit pair
   with neither a common left nor right multiple.

## Main Results

* `list_eq_append_overlap` — pure list overlap decomposition lemma
* `berggren_word_left_overlap` — left overlap rigidity for Berggren words
* `berggren_word_right_overlap` — right overlap rigidity for Berggren words
* `no_common_left_multiple_of_no_suffix_overlap` — Green L-incomparability
* `no_common_right_multiple_of_no_prefix_overlap` — Green R-incomparability
* `berggren_green_incomparable_of_no_overlap` — full two-sided incomparability
* `exists_lcm_free_pair_in_ball` — explicit lcm-free pair extraction

## References

* Berggren, B. (1934). Pytagoreiska trianglar.
* Hall, A. (1970). Genealogy of Pythagorean triads.
-/

set_option linter.unusedVariables false

/-! ## Generator Type -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A | B | C
  deriving DecidableEq, Repr

instance : Fintype BergGen where
  elems := {.A, .B, .C}
  complete := by intro x; cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-! ## Pair-Based Evaluation (for proving injectivity) -/

/-- Action of a generator on a pair (m, n). -/
def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair (2, 1). -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Evaluate a word by acting on the root pair. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A valid pair has 0 < n < m. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BergGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h; linarith [m_ge_three_after_gen g hp, show (actGen g p).1 = 2 from congr_arg Prod.fst h]

theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

/-- **Freeness via pairs**: the pair evaluation map is injective. -/
theorem evalPair_injective : Function.Injective evalPair := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalPair_valid rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalPair_valid rest₁))
    | g₂ :: rest₂ =>
      have hp₁ := evalPair_valid rest₁
      have hp₂ := evalPair_valid rest₂
      have hg := actGen_generator_determined hp₁ hp₂ h
      subst hg
      have hp := actGen_injective g₁ h
      exact congrArg (g₁ :: ·) (ih hp)

/-! ## Matrix Formulation -/

/-- Matrix representation of each Berggren generator. -/
def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

/-- Evaluate a Berggren word as a matrix product. -/
def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

/-- Evaluation respects concatenation: `evalBergWord (u ++ v) = evalBergWord u * evalBergWord v`. -/
theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

/-- Bridge between pair evaluation and matrix evaluation. -/
def pairOfMat (M : Matrix (Fin 2) (Fin 2) ℤ) : ℤ × ℤ :=
  (2 * M 0 0 + M 0 1, 2 * M 1 0 + M 1 1)

theorem pairOfMat_evalBergWord (w : BergWord) :
    pairOfMat (evalBergWord w) = evalPair w := by
  induction w with
  | nil => simp [pairOfMat, evalBergWord, evalPair, rootPair]
  | cons g rest ih =>
    simp only [evalBergWord, evalPair]; rw [← ih]
    cases g <;>
      simp only [actGen, bergMat, pairOfMat, Matrix.mul_apply, Fin.sum_univ_two] <;>
      ext <;> simp <;> ring

/-- **Injectivity of the matrix evaluation**: the free semigroup theorem. -/
theorem evalBergWord_injective : Function.Injective evalBergWord := by
  intro u v h; apply evalPair_injective
  rw [← pairOfMat_evalBergWord, ← pairOfMat_evalBergWord, h]

/-- Equal matrix products iff equal words. -/
theorem evalBergWord_eq_iff {u v : BergWord} :
    evalBergWord u = evalBergWord v ↔ u = v :=
  ⟨fun h => evalBergWord_injective h, fun h => by rw [h]⟩

/-! ## Basic Properties -/

theorem evalBergWord_eq_one_iff {w : BergWord} : evalBergWord w = 1 ↔ w = [] :=
  ⟨fun h => evalBergWord_injective (h.trans evalBergWord_nil.symm), fun h => by subst h; rfl⟩

/-! ## Cancellation -/

theorem evalBergWord_left_cancel {u v w : BergWord}
    (h : evalBergWord (u ++ v) = evalBergWord (u ++ w)) : v = w :=
  List.append_cancel_left (evalBergWord_injective h)

theorem evalBergWord_right_cancel {u v w : BergWord}
    (h : evalBergWord (v ++ u) = evalBergWord (w ++ u)) : v = w :=
  List.append_cancel_right (evalBergWord_injective h)

/-! ## List Overlap Lemma (Pure Combinatorics) -/

/-- **List overlap decomposition**: if `x ++ u = y ++ v`, then either
`x` is a prefix of `y` or `y` is a prefix of `x`, with the corresponding
suffix/remainder relationship. This is the free-semigroup heart of the argument. -/
theorem list_eq_append_overlap {α : Type*}
    (x y u v : List α)
    (h : x ++ u = y ++ v) :
    ∃ w : List α,
      ((x = y ++ w ∧ v = w ++ u) ∨
       (y = x ++ w ∧ u = w ++ v)) := by
  rcases List.append_eq_append_iff.mp h with ⟨w, hw1, hw2⟩ | ⟨w, hw1, hw2⟩
  · exact ⟨w, Or.inr ⟨hw1, hw2⟩⟩
  · exact ⟨w, Or.inl ⟨hw1, hw2⟩⟩

/-! ## Left Overlap Rigidity -/

/-- **Left overlap rigidity for Berggren words**: if `evalBergWord (x ++ u) = evalBergWord (y ++ v)`,
then one word pair extends the other via a connecting word `w`. -/
theorem berggren_word_left_overlap
    {u v x y : BergWord}
    (hxy : evalBergWord (x ++ u) = evalBergWord (y ++ v)) :
    ∃ w : BergWord,
      ((u = w ++ v ∧ y = x ++ w) ∨
       (v = w ++ u ∧ x = y ++ w)) := by
  have heq := evalBergWord_injective hxy
  obtain ⟨w, hw⟩ := list_eq_append_overlap x y u v heq
  exact ⟨w, by tauto⟩

/-! ## Right Overlap Rigidity -/

/-- **Right overlap rigidity for Berggren words**: if `evalBergWord (u ++ x) = evalBergWord (v ++ y)`,
then one word pair extends the other via a connecting word `w`. -/
theorem berggren_word_right_overlap
    {u v x y : BergWord}
    (hxy : evalBergWord (u ++ x) = evalBergWord (v ++ y)) :
    ∃ w : BergWord,
      ((u = v ++ w ∧ y = w ++ x) ∨
       (v = u ++ w ∧ x = w ++ y)) := by
  have heq := evalBergWord_injective hxy
  obtain ⟨w, hw⟩ := list_eq_append_overlap u v x y heq
  exact ⟨w, by tauto⟩

/-! ## Matrix-Level Overlap Rigidity -/

/-- **Left multiple rigidity (matrix form)**: if `evalBergWord x * evalBergWord u =
evalBergWord y * evalBergWord v`, then one of `u,v` is a suffix-extension of the other. -/
theorem berggren_left_multiple_rigidity
    {u v x y : BergWord}
    (hxy : evalBergWord x * evalBergWord u = evalBergWord y * evalBergWord v) :
    ∃ w : BergWord,
      ((u = w ++ v ∧ evalBergWord y = evalBergWord x * evalBergWord w) ∨
       (v = w ++ u ∧ evalBergWord x = evalBergWord y * evalBergWord w)) := by
  rw [← evalBergWord_append, ← evalBergWord_append] at hxy
  obtain ⟨w, hw⟩ := berggren_word_left_overlap hxy
  exact ⟨w, by rcases hw with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
    [left; right] <;> exact ⟨h1, by subst h2; rw [evalBergWord_append]⟩⟩

/-- **Right multiple rigidity (matrix form)**: if `evalBergWord u * evalBergWord x =
evalBergWord v * evalBergWord y`, then one of `u,v` is a prefix-extension of the other. -/
theorem berggren_right_multiple_rigidity
    {u v x y : BergWord}
    (hxy : evalBergWord u * evalBergWord x = evalBergWord v * evalBergWord y) :
    ∃ w : BergWord,
      ((u = v ++ w ∧ evalBergWord y = evalBergWord w * evalBergWord x) ∨
       (v = u ++ w ∧ evalBergWord x = evalBergWord w * evalBergWord y)) := by
  rw [← evalBergWord_append, ← evalBergWord_append] at hxy
  obtain ⟨w, hw⟩ := berggren_word_right_overlap hxy
  exact ⟨w, by rcases hw with ⟨h1, h2⟩ | ⟨h1, h2⟩ <;>
    [left; right] <;> exact ⟨h1, by subst h2; rw [evalBergWord_append]⟩⟩

/-! ## Green-Order Incomparability: No Common Left/Right Multiples -/

/-- If neither `u` is a suffix-extension of `v` nor vice versa, then `u` and `v`
have no common left multiple in the Berggren semigroup. -/
theorem no_common_left_multiple_of_no_suffix_overlap
    {u v : BergWord}
    (hnot : ¬ ∃ w : BergWord, u = w ++ v ∨ v = w ++ u) :
    ¬ ∃ a b : BergWord,
        evalBergWord a * evalBergWord u = evalBergWord b * evalBergWord v := by
  intro ⟨a, b, hab⟩
  obtain ⟨w, hw⟩ := berggren_left_multiple_rigidity hab
  exact hnot ⟨w, by tauto⟩

/-- If neither `u` is a prefix-extension of `v` nor vice versa, then `u` and `v`
have no common right multiple in the Berggren semigroup. -/
theorem no_common_right_multiple_of_no_prefix_overlap
    {u v : BergWord}
    (hnot : ¬ ∃ w : BergWord, u = v ++ w ∨ v = u ++ w) :
    ¬ ∃ a b : BergWord,
        evalBergWord u * evalBergWord a = evalBergWord v * evalBergWord b := by
  intro ⟨a, b, hab⟩
  obtain ⟨w, hw⟩ := berggren_right_multiple_rigidity hab
  exact hnot ⟨w, by tauto⟩

/-! ## Finite-Ball Green-Order Incomparability -/

/-- **Full two-sided Green-order incomparability**: if `u` and `v` are distinct words
with no suffix overlap (ruling out common left multiples) and no prefix overlap
(ruling out common right multiples), then they are incomparable in both the
left and right Green preorders. -/
theorem berggren_green_incomparable_of_no_overlap
    {u v : BergWord}
    (hne : u ≠ v)
    (hnot_suffix : ¬ ∃ w : BergWord, u = w ++ v ∨ v = w ++ u)
    (hnot_prefix : ¬ ∃ w : BergWord, u = v ++ w ∨ v = u ++ w) :
    (¬ ∃ a b : BergWord,
        evalBergWord a * evalBergWord u = evalBergWord b * evalBergWord v) ∧
    (¬ ∃ a b : BergWord,
        evalBergWord u * evalBergWord a = evalBergWord v * evalBergWord b) :=
  ⟨no_common_left_multiple_of_no_suffix_overlap hnot_suffix,
   no_common_right_multiple_of_no_prefix_overlap hnot_prefix⟩

/-! ## Supporting Lemmas for Singleton Words -/

/-- A distinct singleton cannot be a suffix-extension of another singleton. -/
theorem singleton_no_suffix_overlap
    {g h : BergGen} (hgh : g ≠ h) :
    ¬ ∃ w : BergWord, [g] = w ++ [h] ∨ [h] = w ++ [g] := by
  rintro ⟨w, hw | hw⟩
  · have : w = [] ∧ g = h := by
      cases w with
      | nil => simp at hw; exact ⟨rfl, hw⟩
      | cons a t => simp [List.cons_append] at hw
    exact hgh this.2
  · have : w = [] ∧ h = g := by
      cases w with
      | nil => simp at hw; exact ⟨rfl, hw⟩
      | cons a t => simp [List.cons_append] at hw
    exact hgh this.2.symm

/-- A distinct singleton cannot be a prefix-extension of another singleton. -/
theorem singleton_no_prefix_overlap
    {g h : BergGen} (hgh : g ≠ h) :
    ¬ ∃ w : BergWord, [g] = [h] ++ w ∨ [h] = [g] ++ w := by
  rintro ⟨w, hw | hw⟩
  · simp at hw; exact hgh hw.1
  · simp at hw; exact hgh hw.1.symm

/-! ## LCM-Free Pair Extraction -/

/-- Two distinct Berggren generators form a Green-incomparable pair:
they have neither a common left multiple nor a common right multiple. -/
theorem distinct_generators_green_incomparable
    {g h : BergGen} (hgh : g ≠ h) :
    (¬ ∃ a b : BergWord,
        evalBergWord a * evalBergWord [g] = evalBergWord b * evalBergWord [h]) ∧
    (¬ ∃ a b : BergWord,
        evalBergWord [g] * evalBergWord a = evalBergWord [h] * evalBergWord b) :=
  berggren_green_incomparable_of_no_overlap
    (by simp [hgh])
    (singleton_no_suffix_overlap hgh)
    (singleton_no_prefix_overlap hgh)

/-- **LCM-free pair extraction**: every ball of radius ≥ 1 contains an explicit
pair of words with neither a common left multiple nor a common right multiple.
The witness is the pair `([A], [B])` of distinct singleton generator words. -/
theorem exists_lcm_free_pair_in_ball
    {R : ℕ} (hR : 1 ≤ R) :
    ∃ u v : BergWord,
      u.length ≤ R ∧ v.length ≤ R ∧
      u ≠ v ∧
      (¬ ∃ a b : BergWord,
          evalBergWord a * evalBergWord u = evalBergWord b * evalBergWord v) ∧
      (¬ ∃ a b : BergWord,
          evalBergWord u * evalBergWord a = evalBergWord v * evalBergWord b) := by
  refine ⟨[BergGen.A], [BergGen.B], ?_, ?_, ?_, ?_⟩
  · simp; omega
  · simp; omega
  · simp
  · exact distinct_generators_green_incomparable (by decide)