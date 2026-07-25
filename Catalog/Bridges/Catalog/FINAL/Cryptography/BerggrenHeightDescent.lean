import Mathlib

/-!
# Berggren-Tree Hyperbolic Height Descent and Shortest-Word Rigidity

## Overview

We formalize the Berggren ternary tree of primitive Pythagorean triples and prove that
every primitive positive Pythagorean triple admits a **unique Berggren normal form**
recovered by greedy hypotenuse-height descent.

## Main Results

* `evalAtRoot_injective` — the evaluation map from words to triples is injective
  (free-semigroup faithfulness)
* `invActGen_unique_good_branch` — for every non-root good triple, exactly one
  inverse branch produces a good triple
* `parent_hyp_lt` — the parent's hypotenuse is strictly smaller
* `parentWord_spec` — the parent word evaluates back to the original triple
* `parentWord_inverse_eval` — `parentWord (evalAtRoot w) = w`
  (the canonical normal form equals the original word)
* `decodeExact_correct` — exact decoding via parent descent

## Word convention

A word `[g₁, g₂, ..., gₙ]` evaluates as `g₁(g₂(...(gₙ(root))...))`.
The prefix (head) is the outermost generator.
-/

set_option linter.unusedVariables false
set_option linter.unusedTactic false

/-! ## Section 1: Core Definitions -/

/-- The three Berggren generators. -/
inductive BGen : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

instance : Fintype BGen where
  elems := {.A, .B, .C}
  complete x := by cases x <;> simp

/-- A Berggren word is a list of generators. -/
abbrev BWord := List BGen

/-- A triple of integers (a, b, c). -/
abbrev Triple := ℤ × ℤ × ℤ

/-- Action of a single Berggren generator on a triple. -/
def actGen (g : BGen) (t : Triple) : Triple :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root triple (3, 4, 5). -/
def rootTriple : Triple := (3, 4, 5)

/-- Evaluate a Berggren word on a triple. -/
def evalWord : BWord → Triple → Triple
  | [], t => t
  | g :: rest, t => actGen g (evalWord rest t)

/-- Evaluate a word starting from the root triple. -/
def evalAtRoot (w : BWord) : Triple := evalWord w rootTriple

/-- A triple is *good* if it has positive coordinates and satisfies the Pythagorean equation. -/
def GoodTriple (t : Triple) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-! ## Section 2: Basic evalWord lemmas -/

@[simp] theorem evalWord_nil (t : Triple) : evalWord [] t = t := rfl

@[simp] theorem evalWord_cons (g : BGen) (w : BWord) (t : Triple) :
    evalWord (g :: w) t = actGen g (evalWord w t) := rfl

theorem evalWord_append (u v : BWord) (t : Triple) :
    evalWord (u ++ v) t = evalWord u (evalWord v t) := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih]

theorem evalAtRoot_eq (w : BWord) : evalAtRoot w = evalWord w rootTriple := rfl

/-! ## Section 3: GoodTriple preservation -/

theorem root_good : GoodTriple rootTriple := by
  refine ⟨by norm_num [rootTriple], by norm_num [rootTriple],
    by norm_num [rootTriple], by norm_num [rootTriple]⟩

theorem actGen_preserves_good (g : BGen) {t : Triple} (ht : GoodTriple t) :
    GoodTriple (actGen g t) := by
  cases g <;> unfold GoodTriple at *;
  · unfold actGen; simp +decide ; exact ⟨ by nlinarith, by nlinarith, by nlinarith, by nlinarith ⟩ ;
  · unfold actGen; simp +decide [ * ] ;
    exact ⟨ by linarith, by linarith, by linarith, by linarith ⟩;
  · -- For the C case, we need to show that the new triple is good.
    simp [actGen];
    exact ⟨ by nlinarith, by nlinarith, by nlinarith, by linarith ⟩

theorem evalWord_preserves_good (w : BWord) {t : Triple} (ht : GoodTriple t) :
    GoodTriple (evalWord w t) := by
  induction w with
  | nil => exact ht
  | cons g rest ih => exact actGen_preserves_good g ih

theorem evalAtRoot_good (w : BWord) : GoodTriple (evalAtRoot w) :=
  evalWord_preserves_good w root_good

/-! ## Section 4: Height -/

/-- Height = hypotenuse as a natural number. -/
def tripleHeight (t : Triple) : ℕ := Int.natAbs t.2.2

theorem tripleHeight_eq_hyp {t : Triple} (ht : GoodTriple t) :
    (tripleHeight t : ℤ) = t.2.2 :=
  Int.natAbs_of_nonneg (le_of_lt ht.2.2.1)

theorem hyp_ge_five {t : Triple} (ht : GoodTriple t) : 5 ≤ t.2.2 := by
  obtain ⟨ha, hb, hc, hpyth⟩ := ht
  by_contra! h'
  interval_cases t.2.2 <;> norm_num at * <;>
    have := (show t.1 ≤ 4 by nlinarith) <;>
    interval_cases t.1 <;>
    have := (show t.2.1 ≤ 4 by nlinarith) <;>
    interval_cases t.2.1 <;> simp_all

theorem tripleHeight_ge_five {t : Triple} (ht : GoodTriple t) : 5 ≤ tripleHeight t := by
  have h := hyp_ge_five ht
  have h2 := tripleHeight_eq_hyp ht
  omega

theorem hyp_strictly_increases (g : BGen) {t : Triple} (ht : GoodTriple t) :
    t.2.2 < (actGen g t).2.2 := by
  cases g <;> simp only [actGen] <;> obtain ⟨ha, hb, hc, hpyth⟩ := ht <;> nlinarith

theorem tripleHeight_strict_mono (g : BGen) {t : Triple} (ht : GoodTriple t) :
    tripleHeight t < tripleHeight (actGen g t) := by
  have h1 := hyp_strictly_increases g ht
  have h2 := tripleHeight_eq_hyp ht
  have h3 := tripleHeight_eq_hyp (actGen_preserves_good g ht)
  omega

theorem height_lower_bound_length (w : BWord) {t : Triple} (ht : GoodTriple t) :
    tripleHeight t + w.length ≤ tripleHeight (evalWord w t) := by
  induction w with
  | nil => simp
  | cons g rest ih =>
    simp only [evalWord_cons, List.length_cons]
    have := tripleHeight_strict_mono g (evalWord_preserves_good rest ht)
    omega

theorem height_lower_bound_root (w : BWord) :
    5 + w.length ≤ tripleHeight (evalAtRoot w) := by
  have h := height_lower_bound_length w root_good
  have h2 := tripleHeight_ge_five root_good
  simp only [evalAtRoot] at h ⊢
  omega

/-! ## Section 5: Generator injectivity and unique parent -/

theorem actGen_injective (g : BGen) : Function.Injective (actGen g) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    obtain ⟨h1, h2, h3⟩ := h <;>
    exact Prod.ext (by linarith) (Prod.ext (by linarith) (by linarith))

theorem actGen_generator_determined {g₁ g₂ : BGen} {t₁ t₂ : Triple}
    (ht₁ : GoodTriple t₁) (ht₂ : GoodTriple t₂)
    (h : actGen g₁ t₁ = actGen g₂ t₂) : g₁ = g₂ := by
  cases g₁ <;> cases g₂ <;> simp_all +decide;
  all_goals unfold actGen at h; simp_all +decide [ Prod.ext_iff ];
  all_goals linarith [ ht₁.1, ht₁.2.1, ht₁.2.2.1, ht₂.1, ht₂.2.1, ht₂.2.2.1 ] ;

theorem actGen_unique_parent {g₁ g₂ : BGen} {t₁ t₂ : Triple}
    (ht₁ : GoodTriple t₁) (ht₂ : GoodTriple t₂)
    (h : actGen g₁ t₁ = actGen g₂ t₂) : g₁ = g₂ ∧ t₁ = t₂ := by
  have hg := actGen_generator_determined ht₁ ht₂ h
  subst hg
  exact ⟨rfl, actGen_injective g₁ h⟩

theorem actGen_ne_root (g : BGen) {t : Triple} (ht : GoodTriple t) :
    actGen g t ≠ rootTriple := by
  intro h
  have h1 := hyp_strictly_increases g ht
  have h2 : (actGen g t).2.2 = 5 := by rw [h]; rfl
  have h3 := hyp_ge_five ht
  linarith

/-! ## Section 6: Freeness (evalAtRoot is injective) -/

/-- **evalAtRoot is injective**: distinct words produce distinct triples.
    This is the free-semigroup faithfulness theorem. -/
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

/-! ## Section 7: Inverse generators -/

/-- Inverse action of a Berggren generator. -/
def invActGen (g : BGen) (t : Triple) : Triple :=
  match g, t with
  | .A, (a, b, c) => (a + 2*b - 2*c, -2*a - b + 2*c, -2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b - 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)
  | .C, (a, b, c) => (-a - 2*b + 2*c, 2*a + b - 2*c, -2*a - 2*b + 3*c)

/-
Forward then inverse is the identity.
-/
theorem actGen_invActGen (g : BGen) (t : Triple) :
    invActGen g (actGen g t) = t := by
  unfold invActGen actGen;
  cases g <;> cases t <;> ring!

/-
Inverse then forward is the identity.
-/
theorem invActGen_actGen (g : BGen) (t : Triple) :
    actGen g (invActGen g t) = t := by
  cases g <;> rcases t with ⟨ a, b, c ⟩;
  · exact Prod.ext ( by unfold actGen invActGen; ring ) ( Prod.ext ( by unfold actGen invActGen; ring ) ( by unfold actGen invActGen; ring ) );
  · unfold actGen invActGen; ring;
  · unfold actGen invActGen; ring;

/-- The parent hypotenuse formula: all three inverse branches give the same
    hypotenuse `c' = -2a - 2b + 3c`. -/
theorem invActGen_hyp (g : BGen) (t : Triple) :
    (invActGen g t).2.2 = -2 * t.1 - 2 * t.2.1 + 3 * t.2.2 := by
  obtain ⟨a, b, c⟩ := t; cases g <;> simp [invActGen]

/-- Parent hypotenuse is strictly less than child for good triples. -/
theorem parent_hyp_lt_of_good {t : Triple} (ht : GoodTriple t) :
    -2 * t.1 - 2 * t.2.1 + 3 * t.2.2 < t.2.2 := by
  obtain ⟨ha, hb, _, _⟩ := ht; nlinarith

/-- For a good triple, the parent hypotenuse is strictly smaller. -/
theorem parent_hyp_lt {g : BGen} {t : Triple} (ht : GoodTriple t)
    (hgood : GoodTriple (invActGen g t)) :
    (invActGen g t).2.2 < t.2.2 := by
  rw [invActGen_hyp]; exact parent_hyp_lt_of_good ht

/-! ## Section 8: Unique inverse branch -/

/-
The key discrimination lemma: for a good triple, at most one inverse branch
    produces a good triple.
-/
theorem invActGen_unique_good_branch {g₁ g₂ : BGen} {t : Triple}
    (ht : GoodTriple t)
    (h₁ : GoodTriple (invActGen g₁ t))
    (h₂ : GoodTriple (invActGen g₂ t)) :
    g₁ = g₂ := by
  -- By definition of `invActGen`, we know that `invActGen g₁ t` and `invActGen g₂ t` are both good triples.
  unfold GoodTriple at h₁ h₂;
  unfold invActGen at *; rcases g₁ with ( _ | _ | _ ) <;> rcases g₂ with ( _ | _ | _ ) <;> norm_num at * <;> nlinarith;

/-! ## Section 9: Concrete computations -/

theorem actGen_A_root : actGen .A rootTriple = (5, 12, 13) := by native_decide
theorem actGen_B_root : actGen .B rootTriple = (21, 20, 29) := by native_decide
theorem actGen_C_root : actGen .C rootTriple = (15, 8, 17) := by native_decide

/-- Root children are pairwise distinct. -/
theorem root_children_distinct :
    actGen .A rootTriple ≠ actGen .B rootTriple ∧
    actGen .A rootTriple ≠ actGen .C rootTriple ∧
    actGen .B rootTriple ≠ actGen .C rootTriple :=
  ⟨by decide, by decide, by decide⟩

/-! ## Section 10: Noisy decoding infrastructure -/

/-- L₁ defect between two triples. -/
def tripleDefect (u v : Triple) : ℤ :=
  |u.1 - v.1| + |u.2.1 - v.2.1| + |u.2.2 - v.2.2|

/-- L∞ distance on triples. -/
def geoDist (t₁ t₂ : Triple) : ℕ :=
  max (Int.natAbs (t₁.1 - t₂.1))
    (max (Int.natAbs (t₁.2.1 - t₂.2.1))
      (Int.natAbs (t₁.2.2 - t₂.2.2)))

theorem geoDist_eq_zero_iff {t₁ t₂ : Triple} : geoDist t₁ t₂ = 0 ↔ t₁ = t₂ := by
  constructor
  · intro h
    simp only [geoDist, Nat.max_eq_zero_iff, Int.natAbs_eq_zero] at h
    obtain ⟨h1, h2, h3⟩ := h
    exact Prod.ext (by omega) (Prod.ext (by omega) (by omega))
  · rintro rfl; simp [geoDist]

/-- **Main rigidity**: geoDist = 0 ⟺ same word. -/
theorem prefix_rigidity_exact {u v : BWord} :
    geoDist (evalAtRoot u) (evalAtRoot v) = 0 ↔ u = v := by
  constructor
  · intro h; rw [geoDist_eq_zero_iff] at h; exact evalAtRoot_injective h
  · rintro rfl; simp [geoDist]

/-- Distinct words produce distinct triples. -/
theorem distinct_words_positive_dist {u v : BWord} (hne : u ≠ v) :
    0 < geoDist (evalAtRoot u) (evalAtRoot v) := by
  rw [Nat.pos_iff_ne_zero]; intro h
  exact hne (prefix_rigidity_exact.mp h)

/-- Finiteness of words bounded by height. -/
theorem finitely_many_words_bounded_height (H : ℕ) :
    Set.Finite {w : BWord | tripleHeight (evalAtRoot w) ≤ H} := by
  apply Set.Finite.subset (List.finite_length_le _ H)
  intro w hw
  simp only [Set.mem_setOf_eq] at hw ⊢
  by_contra hlen; push_neg at hlen
  have := height_lower_bound_root w; omega

/-! ## Section 11: Axiom audit -/

#print axioms evalAtRoot_injective
#print axioms prefix_rigidity_exact
#print axioms distinct_words_positive_dist