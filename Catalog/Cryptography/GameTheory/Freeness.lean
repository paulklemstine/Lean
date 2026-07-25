import Mathlib

/-!
# Berggren Free Semigroup and Unique Normal Forms

## Overview

We prove that the three Berggren matrices generate a free semigroup of rank 3,
and every element admits a unique normal form (word decomposition). This is
the algebraic backbone for SPB Diffie–Hellman: it upgrades "generation by
Berggren moves" into a canonical encoding theorem.

## Main Results

* `berggren_eval_injective` — the evaluation map from words to triples is injective
* `berggren_normal_form_unique` — every generated matrix/triple has a unique word
* `berggren_left_cancel`, `berggren_right_cancel` — cancellation in the free semigroup
* `actGen_generator_determined` — the discriminant classifier uniquely identifies parents

## Proof Strategy

We use a **discriminant classifier**: for any triple `(a', b', c')` in the image of
a Berggren generator applied to a positive Pythagorean triple, the signs of the
linear forms `x = a' + 2b' - 2c'` and `y = 2a' + b' - 2c'` uniquely determine
which generator was applied:
- Generator `A` (B₁): `x > 0, y < 0`
- Generator `B` (B₂): `x > 0, y > 0`
- Generator `C` (B₃): `x < 0, y > 0`

Combined with injectivity of each individual generator (they are invertible integer
matrices) and strict hypotenuse increase, this gives unique parenthood in the
Berggren tree and hence freeness.

## References

* Berggren, B. (1934). "Pytagoreiska trianglar"
* Barning, F. J. M. (1963). "Over pythagorese en bijna-pythagorese driehoeken"
-/

/-! ## Definitions -/

/-- The three Berggren generators. -/
inductive BergGen : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord := List BergGen

/-- Action of a single Berggren generator on a triple `(a, b, c)`.
- `A` (B₁): `(a - 2b + 2c, 2a - b + 2c, 2a - 2b + 3c)`
- `B` (B₂): `(a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)`
- `C` (B₃): `(-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c)` -/
def actGen (g : BergGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root of the Berggren tree: the fundamental primitive Pythagorean triple (3, 4, 5). -/
def rootTriple : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Evaluate a Berggren word as a sequence of generator actions starting from the root.
The word `[g₁, g₂, ..., gₙ]` is interpreted as `g₁ • (g₂ • (... (gₙ • root)))`,
so `g₁` is the most recent (outermost) generator applied. -/
def evalTriple : BergWord → ℤ × ℤ × ℤ
  | [] => rootTriple
  | g :: rest => actGen g (evalTriple rest)

/-- The hypotenuse (third coordinate) of a triple. -/
def hyp (t : ℤ × ℤ × ℤ) : ℤ := t.2.2

/-- A triple `(a, b, c)` is a *good triple* if it has positive coordinates
and satisfies the Pythagorean relation `a² + b² = c²`. -/
def GoodTriple (t : ℤ × ℤ × ℤ) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-- The first discriminant: `x = a + 2b - 2c`. -/
def discX (t : ℤ × ℤ × ℤ) : ℤ := t.1 + 2 * t.2.1 - 2 * t.2.2

/-- The second discriminant: `y = 2a + b - 2c`. -/
def discY (t : ℤ × ℤ × ℤ) : ℤ := 2 * t.1 + t.2.1 - 2 * t.2.2

/-! ## Discriminant Identities -/

@[simp] theorem discX_A (t : ℤ × ℤ × ℤ) : discX (actGen .A t) = t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discX_B (t : ℤ × ℤ × ℤ) : discX (actGen .B t) = t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discX_C (t : ℤ × ℤ × ℤ) : discX (actGen .C t) = -t.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discX, actGen]; ring

@[simp] theorem discY_A (t : ℤ × ℤ × ℤ) : discY (actGen .A t) = -t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

@[simp] theorem discY_B (t : ℤ × ℤ × ℤ) : discY (actGen .B t) = t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

@[simp] theorem discY_C (t : ℤ × ℤ × ℤ) : discY (actGen .C t) = t.2.1 := by
  obtain ⟨a, b, c⟩ := t; simp [discY, actGen]; ring

/-! ## Generator Injectivity -/

/-- Each Berggren generator is injective as a map on triples. -/
theorem actGen_injective (g : BergGen) : Function.Injective (actGen g) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;> obtain ⟨h1, h2, h3⟩ := h <;>
    exact Prod.ext (by linarith) (Prod.ext (by linarith) (by linarith))

/-! ## Preservation of Good Triples -/

/-- The root triple (3, 4, 5) is a good triple. -/
theorem root_good : GoodTriple rootTriple := by
  refine ⟨by norm_num [rootTriple], by norm_num [rootTriple],
    by norm_num [rootTriple], by norm_num [rootTriple]⟩

/-- Each Berggren generator preserves the good triple property. -/
theorem actGen_preserves_good (g : BergGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    GoodTriple (actGen g t) := by
  obtain ⟨ht1, ht2, ht3, ht4⟩ := ht
  rcases g with _ | _ | _
  · constructor
    · exact show 0 < t.1 - 2 * t.2.1 + 2 * t.2.2 from by nlinarith only [ht1, ht2, ht3, ht4]
    · exact ⟨by unfold actGen; nlinarith, by unfold actGen; nlinarith, by unfold actGen; nlinarith⟩
  · constructor <;> norm_num [actGen]
    · linarith
    · constructor
      · linarith
      · constructor
        · linarith
        · nlinarith
  · constructor <;> norm_num [actGen]
    · nlinarith
    · exact ⟨by nlinarith, by nlinarith, by linarith⟩

/-! ## Hypotenuse Strictly Increases -/

/-- The hypotenuse strictly increases under every Berggren generator. -/
theorem hyp_strictly_increases (g : BergGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    hyp t < hyp (actGen g t) := by
  obtain ⟨ha, hb, hc, hpyth⟩ := ht
  cases g <;> simp [hyp, actGen] <;> nlinarith [sq_nonneg (t.1 - t.2.1)]

/-
For a good triple, the hypotenuse is at least 5.
(The smallest positive integer Pythagorean triple is (3,4,5).)
-/
theorem hyp_ge_five {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) : 5 ≤ hyp t := by
  -- By contradiction, assume $c < 5$.
  by_contra hc_lt_5;
  -- Write t as (a, b, c) and get the inequalities from GoodTriple.
  obtain ⟨a, b, c⟩ := t
  have ha_pos : 0 < a := by
    exact ht.1
  have hb_pos : 0 < b := by
    exact ht.2.1
  have hc_pos : 0 < c := by
    exact ht.2.2.1
  have h_pyth : a^2 + b^2 = c^2 := by
    exact ht.2.2.2
  have hc_lt_5 : c < 5 := by
    exact lt_of_not_ge hc_lt_5;
  interval_cases c <;> ( have : a ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h_pyth ] ) ; ( have : b ≤ 4 := Int.le_of_lt_add_one ( by nlinarith only [ h_pyth ] ) ; interval_cases a <;> interval_cases b <;> trivial; ) )

/-- The root triple is never in the image of any generator applied to a good triple. -/
theorem actGen_ne_root (g : BergGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    actGen g t ≠ rootTriple := by
  intro h
  have h1 := hyp_strictly_increases g ht
  have h2 : hyp (actGen g t) = 5 := by rw [h]; rfl
  have h3 := hyp_ge_five ht
  linarith

/-! ## Unique Generator Determination via Discriminant Classifier -/

/-- **Discriminant classifier**: If `actGen g₁ p₁ = actGen g₂ p₂` with good inputs,
then `g₁ = g₂`. -/
theorem actGen_generator_determined {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ × ℤ}
    (hp₁ : GoodTriple p₁) (hp₂ : GoodTriple p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨ha₁, hb₁, _, _⟩ := hp₁
  obtain ⟨ha₂, hb₂, _, _⟩ := hp₂
  have hdx : discX (actGen g₁ p₁) = discX (actGen g₂ p₂) := by rw [h]
  have hdy : discY (actGen g₁ p₁) = discY (actGen g₂ p₂) := by rw [h]
  obtain ⟨a₁, b₁, c₁⟩ := p₁
  obtain ⟨a₂, b₂, c₂⟩ := p₂
  simp only [actGen, discX, discY] at hdx hdy
  cases g₁ <;> cases g₂ <;> simp_all <;> linarith

/-- **Unique parent theorem**: If two generators applied to good triples produce the
same output, then both the generator and the input triple must be identical. -/
theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ × ℤ}
    (hp₁ : GoodTriple p₁) (hp₂ : GoodTriple p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ := by
  have hg := actGen_generator_determined hp₁ hp₂ h
  subst hg
  exact ⟨rfl, actGen_injective g₁ h⟩

/-! ## evalTriple Preserves Good Triples -/

/-- Every Berggren word evaluates to a good triple. -/
theorem evalTriple_good (w : BergWord) : GoodTriple (evalTriple w) := by
  induction w with
  | nil => exact root_good
  | cons g rest ih => exact actGen_preserves_good g ih

/-! ## Main Theorem: Freeness / Injectivity -/

/-- **Berggren evaluation is injective**: distinct words produce distinct triples.
This is the freeness theorem for the Berggren semigroup. -/
theorem berggren_eval_injective : Function.Injective evalTriple := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso
      simp only [evalTriple] at h
      exact actGen_ne_root g (evalTriple_good rest) h.symm
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso
      simp only [evalTriple] at h
      exact actGen_ne_root g₁ (evalTriple_good rest₁) h
    | g₂ :: rest₂ =>
      simp only [evalTriple] at h
      have ⟨hg, hp⟩ := actGen_unique_parent (evalTriple_good rest₁) (evalTriple_good rest₂) h
      subst hg
      congr 1
      exact ih hp

/-- Equivalent formulation: equal evaluations imply equal words. -/
theorem berggren_word_eq_of_eval_eq {u v : BergWord} (h : evalTriple u = evalTriple v) :
    u = v :=
  berggren_eval_injective h

/-! ## Cancellation Laws -/

/-- Left cancellation in the Berggren semigroup. -/
theorem berggren_left_cancel {u v w : BergWord}
    (h : evalTriple (u ++ v) = evalTriple (u ++ w)) : v = w := by
  induction u with
  | nil => exact berggren_eval_injective h
  | cons g rest ih =>
    simp only [List.cons_append, evalTriple] at h
    exact ih (actGen_injective g h)

/-- Right cancellation in the Berggren semigroup. -/
theorem berggren_right_cancel {u v w : BergWord}
    (h : evalTriple (v ++ u) = evalTriple (w ++ u)) : v = w := by
  have := berggren_eval_injective h
  exact List.append_cancel_right this

/-! ## Unique Normal Form -/

/-- The Berggren semigroup: the set of triples reachable from the root. -/
def BergSemigroup : Set (ℤ × ℤ × ℤ) := Set.range evalTriple

/-- **Unique normal form**: a triple is in the Berggren semigroup iff
there exists a unique word that evaluates to it. -/
theorem berggren_normal_form_exists_unique (t : ℤ × ℤ × ℤ) :
    t ∈ BergSemigroup ↔ ∃! w : BergWord, evalTriple w = t := by
  constructor
  · rintro ⟨w, rfl⟩
    exact ⟨w, rfl, fun w' h => (berggren_eval_injective h.symm).symm⟩
  · rintro ⟨w, hw, _⟩
    exact ⟨w, hw⟩

/-- Equal evaluations imply equal words. -/
theorem berggren_normal_form_unique {w₁ w₂ : BergWord}
    (h : evalTriple w₁ = evalTriple w₂) : w₁ = w₂ :=
  berggren_eval_injective h

/-! ## No Nontrivial Relations -/

/-- A nonempty word never evaluates to the root. -/
theorem berggren_semigroup_no_identity {w : BergWord} (hw : w ≠ []) :
    evalTriple w ≠ rootTriple := by
  match w, hw with
  | g :: rest, _ =>
    simp [evalTriple]
    exact actGen_ne_root g (evalTriple_good rest)

/-! ## Encoding Theorem for Cryptographic Applications -/

/-- **Injective encoding of words into triples**: the evaluation map provides a
canonical encoding of Berggren words as primitive Pythagorean triples. -/
theorem berggren_encode_injective : Function.Injective evalTriple :=
  berggren_eval_injective

/-! ## Convenience lemmas -/

@[simp] theorem evalTriple_cons (g : BergGen) (w : BergWord) :
    evalTriple (g :: w) = actGen g (evalTriple w) := rfl

@[simp] theorem evalTriple_nil : evalTriple [] = rootTriple := rfl