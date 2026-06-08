import Mathlib

/-!
# Berggren Hidden-Subsemigroup Rigidity via Abelianized Length Spectra

## Overview

We formalize the **abelianized word spectrum** framework for the Berggren semigroup and
prove that bounded spectral data certify reconstruction and collision-freeness.

The Berggren semigroup is the free semigroup on three generators `A, B, C` acting on
primitive Pythagorean triples. Each generator corresponds to a 2×2 integer matrix,
and the semigroup action is realized via matrix–vector multiplication on pairs `(m, n)`
with `0 < n < m`.

## Main Results

### Definitions
* `BerggrenGen` — the three Berggren generators
* `BergWord` — words (lists) over the generators
* `ParikhTriple` — the abelianized word invariant `(#A, #B, #C)`
* `parikhTriple` — computes the Parikh vector of a word
* `wordLength` — the length of a Berggren word
* `allWordsOfLength` — all words of a given length (as `Finset`)
* `boundedWords` — all words of length ≤ R (the "radius ball")
* `collidesOnRadius` — existence of a collision in the radius ball

### Theorems
* `evalPair_injective` — the Berggren action is injective (freeness)
* `parikhTriple_mul` — Parikh vectors are additive under concatenation
* `short_word_reconstruction` — words are recoverable from their orbit profile
* `certified_no_collision` — no collisions exist on any radius ball
* `bounded_profile_determines_membership` — equal orbit-profile spectra on bounded
  balls imply equal membership
* `hidden_subsemigroup_recovery` — spectral agreement on bounded balls recovers
  the hidden subsemigroup

## Significance

This establishes the principle that **abelianized statistics + geometric action =
bounded noncommutative identifiability**. In cryptographic terms, it provides formal
collision-resistance certificates and hidden-subsemigroup recovery guarantees for
hash constructions built from the Berggren dynamics.
-/

set_option linter.unusedVariables false

/-! ## 1. Generator Type and Word Model -/

/-- The three Berggren generators. -/
inductive BerggrenGen : Type
  | A | B | C
  deriving DecidableEq, Repr

instance : Fintype BerggrenGen where
  elems := {.A, .B, .C}
  complete := by intro x; cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BerggrenGen

/-! ## 2. Pair-Based Action (the Berggren dynamics)

Each generator acts on pairs `(m, n) ∈ ℤ × ℤ` with `0 < n < m` (the "valid" cone).
The root pair `(2, 1)` corresponds to the fundamental Pythagorean triple `(3, 4, 5)`.
-/

/-- Action of a single generator on a pair. -/
def actGen (g : BerggrenGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

/-- The root pair, corresponding to the triple `(3, 4, 5)`. -/
def rootPair : ℤ × ℤ := (2, 1)

/-- Evaluation of a word on the root pair. -/
def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

/-- A pair `(m, n)` is valid if `0 < n < m`. -/
def ValidPair (p : ℤ × ℤ) : Prop := 0 < p.2 ∧ p.2 < p.1

theorem rootPair_valid : ValidPair rootPair := ⟨by norm_num [rootPair], by norm_num [rootPair]⟩

theorem actGen_preserves_valid (g : BerggrenGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    ValidPair (actGen g p) := by
  obtain ⟨hn, hmn⟩ := hp
  cases g <;> constructor <;> simp only [actGen] <;> linarith

theorem evalPair_valid (w : BergWord) : ValidPair (evalPair w) := by
  induction w with
  | nil => exact rootPair_valid
  | cons g rest ih => exact actGen_preserves_valid g ih

theorem m_ge_three_after_gen (g : BerggrenGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    3 ≤ (actGen g p).1 := by
  obtain ⟨hn, hmn⟩ := hp; cases g <;> simp only [actGen] <;> linarith

theorem actGen_ne_root (g : BerggrenGen) {p : ℤ × ℤ} (hp : ValidPair p) :
    actGen g p ≠ rootPair := by
  intro h
  have : (actGen g p).1 = 2 := congr_arg Prod.fst h
  linarith [m_ge_three_after_gen g hp]

theorem actGen_injective (g : BerggrenGen) : Function.Injective (actGen g) := by
  intro ⟨m₁, n₁⟩ ⟨m₂, n₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    exact Prod.ext (by linarith [h.1, h.2]) (by linarith [h.1, h.2])

/-- Different generators on valid pairs produce different outputs. -/
theorem actGen_generator_determined {g₁ g₂ : BerggrenGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨hn₁, hmn₁⟩ := hp₁; obtain ⟨hn₂, hmn₂⟩ := hp₂
  have hf := congr_arg Prod.fst h; have hs := congr_arg Prod.snd h
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [actGen] at hf hs <;> (first | rfl | linarith)

theorem actGen_unique_parent {g₁ g₂ : BerggrenGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-! ## 3. Freeness: Injectivity of the Evaluation Map

**Theorem**: The map `evalPair : BergWord → ℤ × ℤ` is injective.
This is the foundational freeness result for the Berggren semigroup.
-/

/-- **The Berggren action is injective**: distinct words produce distinct orbit values. -/
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
      have ⟨hg, hp⟩ := actGen_unique_parent (evalPair_valid rest₁) (evalPair_valid rest₂) h
      subst hg; exact congrArg (g₁ :: ·) (ih hp)

/-! ## 4. Abelianized Word Spectrum: Parikh Vectors -/

/-- The Parikh triple records the count of each generator in a word. -/
abbrev ParikhTriple := ℕ × ℕ × ℕ

/-- Compute the Parikh triple of a Berggren word. -/
def parikhTriple (w : BergWord) : ParikhTriple :=
  (w.count .A, w.count .B, w.count .C)

/-- Word length. -/
def wordLength (w : BergWord) : ℕ := w.length

/-- The orbit profile of a word: its image under the Berggren action on the root pair. -/
def orbitProfile (w : BergWord) : ℤ × ℤ := evalPair w

/-- Componentwise addition of Parikh triples. -/
def addParikhTriple (p q : ParikhTriple) : ParikhTriple :=
  (p.1 + q.1, p.2.1 + q.2.1, p.2.2 + q.2.2)

instance : Add ParikhTriple := ⟨addParikhTriple⟩

/-- The Parikh triple of the empty word is `(0, 0, 0)`. -/
@[simp]
theorem parikhTriple_empty : parikhTriple [] = (0, 0, 0) := by
  simp [parikhTriple]

/-- The Parikh triple of the generator `A`. -/
@[simp]
theorem parikhTriple_generator_A : parikhTriple [.A] = (1, 0, 0) := by
  simp [parikhTriple]

/-- The Parikh triple of the generator `B`. -/
@[simp]
theorem parikhTriple_generator_B : parikhTriple [.B] = (0, 1, 0) := by
  simp [parikhTriple]

/-- The Parikh triple of the generator `C`. -/
@[simp]
theorem parikhTriple_generator_C : parikhTriple [.C] = (0, 0, 1) := by
  simp [parikhTriple]

/-- **Parikh additivity**: the Parikh triple is additive under concatenation. -/
theorem parikhTriple_mul (u v : BergWord) :
    parikhTriple (u ++ v) = addParikhTriple (parikhTriple u) (parikhTriple v) := by
  simp [parikhTriple, addParikhTriple, List.count_append]

/-- The word length is additive under concatenation. -/
theorem wordLength_mul (u v : BergWord) :
    wordLength (u ++ v) = wordLength u + wordLength v := by
  simp [wordLength, List.length_append]

/-
The sum of Parikh components equals the word length.
-/
theorem parikhTriple_sum_eq_length (w : BergWord) :
    (parikhTriple w).1 + (parikhTriple w).2.1 + (parikhTriple w).2.2 = wordLength w := by
  -- We'll use induction on the word `w`.
  induction' w with g w ih;
  · rfl;
  · cases g <;> simp_all +decide [ parikhTriple, wordLength ] <;> linarith

/-! ## 5. Bounded Words: Radius Ball Enumeration -/

/-- All Berggren words of exactly length `n`. -/
def allWordsOfLength : ℕ → Finset BergWord
  | 0 => {[]}
  | n + 1 => Finset.univ.biUnion fun g => (allWordsOfLength n).image (g :: ·)

/-- All Berggren words of length `≤ R` (the "radius ball"). -/
def boundedWords (R : ℕ) : Finset BergWord :=
  (Finset.range (R + 1)).biUnion allWordsOfLength

/-
Membership in `allWordsOfLength n` is characterized by having length `n`.
-/
theorem mem_allWordsOfLength_iff (n : ℕ) (w : BergWord) :
    w ∈ allWordsOfLength n ↔ wordLength w = n := by
  induction' n with n ih generalizing w;
  · cases w <;> simp +decide [ allWordsOfLength ];
    exact Nat.succ_ne_zero _;
  · cases w <;> simp_all +decide [ allWordsOfLength ];
    · exact ne_of_lt ( Nat.succ_pos _ );
    · unfold wordLength; aesop;

/-
Membership in `boundedWords R` is characterized by having length `≤ R`.
-/
theorem mem_boundedWords_iff (R : ℕ) (w : BergWord) :
    w ∈ boundedWords R ↔ wordLength w ≤ R := by
  simp +decide [ boundedWords, mem_allWordsOfLength_iff ]

/-- The radius ball is a `Finset`. -/
abbrev radiusBall (R : ℕ) : Finset BergWord := boundedWords R

/-! ## 6. Spectral Definitions for Subsemigroups -/

/-- The bounded Parikh spectrum of a decidable set of words. -/
def boundedParikhSpectrum (S : BergWord → Prop) [DecidablePred S] (R : ℕ) : Finset ParikhTriple :=
  ((boundedWords R).filter S).image parikhTriple

/-- The bounded orbit-profile spectrum of a decidable set of words. -/
def boundedProfileSpectrum (S : BergWord → Prop) [DecidablePred S] (R : ℕ) : Finset (ℤ × ℤ) :=
  ((boundedWords R).filter S).image orbitProfile

/-- The bounded length spectrum of a decidable set of words. -/
def boundedLengthSpectrum (S : BergWord → Prop) [DecidablePred S] (R : ℕ) : Finset ℕ :=
  ((boundedWords R).filter S).image wordLength

/-- The truncation of a decidable set to the radius ball. -/
def truncation (S : BergWord → Prop) [DecidablePred S] (R : ℕ) : Finset BergWord :=
  (boundedWords R).filter S

/-
Membership in bounded Parikh spectrum.
-/
theorem mem_boundedParikhSpectrum_iff (S : BergWord → Prop) [DecidablePred S]
    (R : ℕ) (p : ParikhTriple) :
    p ∈ boundedParikhSpectrum S R ↔
      ∃ w, S w ∧ wordLength w ≤ R ∧ parikhTriple w = p := by
  simp [boundedParikhSpectrum, mem_boundedWords_iff];
  grind

/-
Membership in bounded profile spectrum.
-/
theorem mem_boundedProfileSpectrum_iff (S : BergWord → Prop) [DecidablePred S]
    (R : ℕ) (q : ℤ × ℤ) :
    q ∈ boundedProfileSpectrum S R ↔
      ∃ w, S w ∧ wordLength w ≤ R ∧ orbitProfile w = q := by
  simp +decide [ boundedProfileSpectrum, mem_boundedWords_iff ];
  grind

/-! ## 7. Short Word Reconstruction

**Theorem**: Two Berggren words with the same orbit profile (action on the root pair)
must be equal. This follows immediately from the injectivity of `evalPair`.

Note that the Parikh data is not even needed — the orbit profile alone determines the
word uniquely. The Parikh hypothesis is included in the theorem statement for interface
compatibility with weaker settings.
-/

/-- **Short word reconstruction**: words with the same orbit profile are equal.
The Parikh hypothesis is redundant (included for downstream compatibility). -/
theorem short_word_reconstruction
    (R : ℕ)
    (w₁ w₂ : BergWord)
    (_h₁ : wordLength w₁ ≤ R)
    (_h₂ : wordLength w₂ ≤ R)
    (_hp : parikhTriple w₁ = parikhTriple w₂)
    (ha : orbitProfile w₁ = orbitProfile w₂) :
    w₁ = w₂ :=
  evalPair_injective ha

/-- **Unconditional reconstruction**: orbit profile alone determines the word,
without any bound on word length. This is the strongest form. -/
theorem word_reconstruction_from_profile
    (w₁ w₂ : BergWord) (h : orbitProfile w₁ = orbitProfile w₂) :
    w₁ = w₂ :=
  evalPair_injective h

/-! ## 8. Certified No-Collision Theorem

**Theorem**: There are no collisions in the Berggren action on any radius ball.
This is a direct consequence of the injectivity of `evalPair`.
-/

/-- Two words collide if they are distinct but have the same orbit value. -/
def collidesOnRadius (R : ℕ) : Prop :=
  ∃ w₁ w₂ : BergWord,
    wordLength w₁ ≤ R ∧
    wordLength w₂ ≤ R ∧
    w₁ ≠ w₂ ∧
    orbitProfile w₁ = orbitProfile w₂

/-
**Certified no-collision**: the Berggren action has no collisions on any ball.
-/
theorem certified_no_collision (R : ℕ) : ¬ collidesOnRadius R := by
  exact fun h => h.choose_spec.choose_spec.2.2.1 ( word_reconstruction_from_profile _ _ h.choose_spec.choose_spec.2.2.2 )

/-
No-collision is derived from any reconstruction hypothesis.
-/
theorem certified_no_collision_of_reconstruction
    (R : ℕ)
    (hrec : ∀ w₁ w₂ : BergWord,
        wordLength w₁ ≤ R →
        wordLength w₂ ≤ R →
        parikhTriple w₁ = parikhTriple w₂ →
        orbitProfile w₁ = orbitProfile w₂ →
        w₁ = w₂) :
    ¬ collidesOnRadius R :=
  certified_no_collision R

/-
Collision-freeness holds unconditionally (not just on bounded balls).
-/
theorem no_collision_global :
    ¬ ∃ w₁ w₂ : BergWord, w₁ ≠ w₂ ∧ orbitProfile w₁ = orbitProfile w₂ := by
  exact fun ⟨ w₁, w₂, hne, heq ⟩ => hne ( word_reconstruction_from_profile _ _ heq )

/-! ## 9. Bounded Profile Determines Membership

**Key Principle**: Since `evalPair` is injective, the orbit-profile spectrum of a set
on a bounded ball uniquely determines which words belong to the set on that ball.

This is the core of the hidden-subsemigroup recovery guarantee.
-/

/-
**Profile spectrum determines truncation**: if two decidable sets have the same
bounded profile spectrum, their truncations to the radius ball are equal.
-/
theorem bounded_profile_determines_truncation
    (S T : BergWord → Prop) [DecidablePred S] [DecidablePred T] (R : ℕ)
    (hprof : boundedProfileSpectrum S R = boundedProfileSpectrum T R) :
    truncation S R = truncation T R := by
  simp_all +decide [ Finset.ext_iff, boundedProfileSpectrum ];
  intro w; specialize hprof ( orbitProfile w |>.1 ) ( orbitProfile w |>.2 ) ; simp_all +decide [ truncation ] ;
  grind +suggestions

/-
**Profile spectrum determines membership**: if two sets have the same bounded
profile spectrum, they agree on all words in the radius ball.
-/
theorem bounded_profile_determines_membership
    (S T : BergWord → Prop) [DecidablePred S] [DecidablePred T] (R : ℕ)
    (hprof : boundedProfileSpectrum S R = boundedProfileSpectrum T R) :
    ∀ w, wordLength w ≤ R → (S w ↔ T w) := by
  -- By definition of boundedProfileSpectrum, if two sets have the same bounded profile spectrum, their truncations to the radius ball are equal.
  have h_truncation : truncation S R = truncation T R := bounded_profile_determines_truncation S T R hprof;
  simp_all +decide [ Finset.ext_iff, truncation ];
  exact fun w hw => h_truncation w ( mem_boundedWords_iff R w |>.2 hw )

/-! ## 10. Hidden-Subsemigroup Recovery

We now package the results into the full recovery guarantee. Given two sets of
Berggren words (representing "hidden subsemigroups"), if their bounded profile spectra
agree, then they are indistinguishable on the radius ball.
-/

/-- Closure of a finite set of words under concatenation.
The smallest set containing `G` and closed under `++`. -/
inductive subsemigroupClosure (G : Finset BergWord) : BergWord → Prop
  | gen (w : BergWord) (hw : w ∈ G) : subsemigroupClosure G w
  | mul (u v : BergWord) : subsemigroupClosure G u → subsemigroupClosure G v →
      subsemigroupClosure G (u ++ v)

/-- **Hidden-subsemigroup recovery**: spectral agreement implies membership agreement
on the entire radius ball.

This theorem says: if two "hidden subsemigroups" (decidable sets) have identical
bounded orbit-profile spectra, then they contain exactly the same words of bounded
length. In cryptographic terms, the orbit-profile spectrum is a complete fingerprint
for bounded subsemigroup identification. -/
theorem hidden_subsemigroup_recovery
    (S T : BergWord → Prop) [DecidablePred S] [DecidablePred T] (R : ℕ)
    (hprof : boundedProfileSpectrum S R = boundedProfileSpectrum T R) :
    ∀ w, wordLength w ≤ R → (S w ↔ T w) :=
  bounded_profile_determines_membership S T R hprof

/-- **Hidden-subsemigroup recovery (Finset form)**: spectral agreement implies equal
truncations as Finsets. -/
theorem hidden_subsemigroup_recovery_finset
    (S T : BergWord → Prop) [DecidablePred S] [DecidablePred T] (R : ℕ)
    (hprof : boundedProfileSpectrum S R = boundedProfileSpectrum T R) :
    truncation S R = truncation T R :=
  bounded_profile_determines_truncation S T R hprof

/-! ## 11. Orbit Profile Injectivity on Bounded Words

The following theorem establishes that `orbitProfile` restricted to bounded words
is injective as a map from the radius ball. This is a finitary consequence of the
global injectivity `evalPair_injective`.
-/

/-
`orbitProfile` is injective on `boundedWords R`.
-/
theorem orbitProfile_injective_on_boundedWords (R : ℕ) :
    Set.InjOn orbitProfile (boundedWords R : Set BergWord) := by
  exact fun x hx y hy hxy => evalPair_injective hxy

/-
The cardinality of the bounded profile spectrum equals the cardinality of the
truncated set. No information is lost by passing to orbit profiles.
-/
theorem card_boundedProfileSpectrum_eq
    (S : BergWord → Prop) [DecidablePred S] (R : ℕ) :
    (boundedProfileSpectrum S R).card = (truncation S R).card := by
  exact Finset.card_image_of_injOn ( fun x hx y hy hxy => evalPair_injective hxy )

/-! ## 12. Parikh Data as a Weaker Invariant

While the orbit profile alone determines the word (Theorem `word_reconstruction_from_profile`),
the Parikh vector provides a cheaper-to-compute abelianized invariant that captures partial
information. We show that Parikh data partitions words into equivalence classes, and
within each class, the orbit profile further separates all elements.
-/

/-
Words with the same Parikh triple have the same length.
-/
theorem wordLength_of_parikhTriple_eq {w₁ w₂ : BergWord}
    (h : parikhTriple w₁ = parikhTriple w₂) :
    wordLength w₁ = wordLength w₂ := by
  rw [ ← parikhTriple_sum_eq_length w₁, ← parikhTriple_sum_eq_length w₂, h ]

/-- The Parikh triple of a single-generator word. -/
theorem parikhTriple_singleton (g : BerggrenGen) :
    parikhTriple [g] = match g with
      | .A => (1, 0, 0)
      | .B => (0, 1, 0)
      | .C => (0, 0, 1) := by
  cases g <;> simp [parikhTriple]

/-
The number of words of length `n` is `3^n`.
-/
theorem card_allWordsOfLength (n : ℕ) :
    (allWordsOfLength n).card = 3 ^ n := by
  induction' n with n ih;
  · rfl;
  · rw [ show allWordsOfLength ( n + 1 ) = Finset.biUnion ( Finset.univ : Finset BerggrenGen ) fun g => Finset.image ( fun w => g :: w ) ( allWordsOfLength n ) from rfl ];
    rw [ Finset.card_biUnion ];
    · rw [ Finset.sum_congr rfl fun x hx => Finset.card_image_of_injective _ <| fun y z h => by simpa using h ] ; simp_all +decide [ pow_succ' ];
    · intro g hg g' hg' hgg'; simp_all +decide [ Finset.disjoint_left ] ;
      aesop