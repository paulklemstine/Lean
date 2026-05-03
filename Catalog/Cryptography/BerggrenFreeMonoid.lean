import Mathlib

/-!
# Berggren Free Monoid: Unique Factorization and Word-Metric Rigidity

We prove that the three Berggren generators, realized as 2×2 integer matrices,
generate a **free semigroup** of rank 3 inside `GL₂(ℤ)`.

## Main Results

* `evalBergWord_injective` — the matrix evaluation map is injective (freeness)
* `evalBergWord_eq_iff` — equal matrix products ↔ equal words
* `bergWordOf_unique` — unique coding of semigroup elements
* `leftDivides_iff_prefix` / `rightDivides_iff_suffix` — divisibility = prefix/suffix
* `bergLength_mul` — word length is additive
* `eval_prefix_rigidity` — equal-length prefixes of equal products agree
* `berg_overlap_free_monoid` — free-monoid overlap theorem
* `equal_products_prefix_comparable` — prefix comparability of left factors
-/

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false

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

/-! ## Pair-Based Evaluation -/

def actGen (g : BergGen) (p : ℤ × ℤ) : ℤ × ℤ :=
  match g with
  | .A => (2 * p.1 - p.2, p.1)
  | .B => (2 * p.1 + p.2, p.1)
  | .C => (p.1 + 2 * p.2, p.2)

def rootPair : ℤ × ℤ := (2, 1)

def evalPair : BergWord → ℤ × ℤ
  | [] => rootPair
  | g :: rest => actGen g (evalPair rest)

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

theorem actGen_unique_parent {g₁ g₂ : BergGen} {p₁ p₂ : ℤ × ℤ}
    (hp₁ : ValidPair p₁) (hp₂ : ValidPair p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ :=
  ⟨actGen_generator_determined hp₁ hp₂ h,
   actGen_injective g₁ (actGen_generator_determined hp₁ hp₂ h ▸ h)⟩

/-- **Freeness via pairs**. -/
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

/-! ## Matrix Formulation -/

def bergMat : BergGen → Matrix (Fin 2) (Fin 2) ℤ
  | .A => !![2, -1; 1, 0]
  | .B => !![2, 1; 1, 0]
  | .C => !![1, 2; 0, 1]

def evalBergWord : BergWord → Matrix (Fin 2) (Fin 2) ℤ
  | [] => 1
  | g :: rest => bergMat g * evalBergWord rest

@[simp] theorem evalBergWord_nil : evalBergWord [] = 1 := rfl
@[simp] theorem evalBergWord_cons (g : BergGen) (w : BergWord) :
    evalBergWord (g :: w) = bergMat g * evalBergWord w := rfl

theorem evalBergWord_append (u v : BergWord) :
    evalBergWord (u ++ v) = evalBergWord u * evalBergWord v := by
  induction u with
  | nil => simp
  | cons g rest ih => simp [ih, Matrix.mul_assoc]

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

/-- **Injectivity of the matrix evaluation**: the free-monoid theorem. -/
theorem evalBergWord_injective : Function.Injective evalBergWord := by
  intro u v h; apply evalPair_injective
  rw [← pairOfMat_evalBergWord, ← pairOfMat_evalBergWord, h]

theorem evalBergWord_eq_iff {u v : BergWord} :
    evalBergWord u = evalBergWord v ↔ u = v :=
  ⟨fun h => evalBergWord_injective h, fun h => by rw [h]⟩

/-! ## Unique Coding -/

def InBergSemigroup (M : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  ∃ w : BergWord, evalBergWord w = M

noncomputable def bergWordOf (M : Matrix (Fin 2) (Fin 2) ℤ) (hM : InBergSemigroup M) :
    BergWord := hM.choose

theorem eval_bergWordOf {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : InBergSemigroup M) :
    evalBergWord (bergWordOf M hM) = M := hM.choose_spec

theorem bergWordOf_unique {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : InBergSemigroup M)
    {w : BergWord} (hw : evalBergWord w = M) : w = bergWordOf M hM :=
  evalBergWord_injective (hw.trans (eval_bergWordOf hM).symm)

theorem bergWordOf_eval (w : BergWord) :
    bergWordOf (evalBergWord w) ⟨w, rfl⟩ = w :=
  (bergWordOf_unique ⟨w, rfl⟩ rfl).symm

/-! ## Non-triviality -/

theorem evalBergWord_eq_one_iff {w : BergWord} : evalBergWord w = 1 ↔ w = [] :=
  ⟨fun h => evalBergWord_injective (h.trans evalBergWord_nil.symm), fun h => by subst h; rfl⟩

theorem evalBergWord_ne_one_of_ne_nil {w : BergWord} (hw : w ≠ []) :
    evalBergWord w ≠ 1 := by rwa [ne_eq, evalBergWord_eq_one_iff]

/-! ## Divisibility -/

def LeftDivides (X Y : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  ∃ Z, InBergSemigroup Z ∧ Y = X * Z

def RightDivides (X Y : Matrix (Fin 2) (Fin 2) ℤ) : Prop :=
  ∃ Z, InBergSemigroup Z ∧ Y = Z * X

theorem leftDivides_iff_prefix {u v : BergWord} :
    LeftDivides (evalBergWord u) (evalBergWord v) ↔ u <+: v := by
  constructor;
  · rintro ⟨ Z, ⟨ t, rfl ⟩, hZ ⟩;
    rw [ ← evalBergWord_append ] at hZ;
    exact ⟨ t, by rw [ ← evalBergWord_injective hZ ] ⟩;
  · rintro ⟨ t, rfl ⟩;
    exact ⟨ evalBergWord t, ⟨ t, rfl ⟩, by rw [ evalBergWord_append ] ⟩

theorem rightDivides_iff_suffix {u v : BergWord} :
    RightDivides (evalBergWord u) (evalBergWord v) ↔ u <:+ v := by
  constructor <;> rintro ⟨ Z, hZ, h ⟩;
  · obtain ⟨ w, rfl ⟩ := hZ;
    rw [ ← evalBergWord_append ] at h;
    have := evalBergWord_injective h; aesop;
  · exact ⟨ evalBergWord Z, ⟨ Z, rfl ⟩, by simp +decide [ evalBergWord_append ] ⟩

theorem left_factor_unique {u v s t : BergWord}
    (hs : evalBergWord v = evalBergWord u * evalBergWord s)
    (ht : evalBergWord v = evalBergWord u * evalBergWord t) : s = t :=
  List.append_cancel_left (evalBergWord_injective
    (show evalBergWord (u ++ s) = evalBergWord (u ++ t) by
      rw [evalBergWord_append, evalBergWord_append]; exact hs.symm.trans ht))

theorem right_factor_unique {u v s t : BergWord}
    (hs : evalBergWord v = evalBergWord s * evalBergWord u)
    (ht : evalBergWord v = evalBergWord t * evalBergWord u) : s = t :=
  List.append_cancel_right (evalBergWord_injective
    (show evalBergWord (s ++ u) = evalBergWord (t ++ u) by
      rw [evalBergWord_append, evalBergWord_append]; exact hs.symm.trans ht))

theorem berg_prefix_of_left_factor {u v : BergWord}
    (h : ∃ t, evalBergWord v = evalBergWord u * evalBergWord t) : u <+: v := by
  -- By the injectivity of evalBergWord, if evalBergWord v = evalBergWord (u ++ t), then v must equal u ++ t.
  have h_eq : evalBergWord v = evalBergWord (u ++ h.choose) := by
    exact h.choose_spec.trans ( by rw [ evalBergWord_append ] );
  exact evalBergWord_injective h_eq ▸ List.prefix_append _ _

theorem berg_suffix_of_right_factor {u v : BergWord}
    (h : ∃ t, evalBergWord v = evalBergWord t * evalBergWord u) : u <:+ v := by
  -- Let's obtain such a $t$ from $h$.
  obtain ⟨t, ht⟩ := h;
  rw [ ← evalBergWord_append, evalBergWord_injective.eq_iff ] at ht ; aesop

/-! ## Additive Word Length -/

noncomputable def bergLength (M : Matrix (Fin 2) (Fin 2) ℤ) (hM : InBergSemigroup M) : ℕ :=
  (bergWordOf M hM).length

theorem bergLength_eval (w : BergWord) :
    bergLength (evalBergWord w) ⟨w, rfl⟩ = w.length := by
  simp [bergLength, bergWordOf_eval]

theorem InBergSemigroup_mul {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : InBergSemigroup X) (hY : InBergSemigroup Y) : InBergSemigroup (X * Y) := by
  obtain ⟨u, rfl⟩ := hX; obtain ⟨v, rfl⟩ := hY
  exact ⟨u ++ v, evalBergWord_append u v⟩

theorem bergLength_mul {X Y : Matrix (Fin 2) (Fin 2) ℤ}
    (hX : InBergSemigroup X) (hY : InBergSemigroup Y) :
    bergLength (X * Y) (InBergSemigroup_mul hX hY) = bergLength X hX + bergLength Y hY := by
  obtain ⟨u, rfl⟩ := hX; obtain ⟨v, rfl⟩ := hY
  unfold bergLength; rw [bergWordOf_eval, bergWordOf_eval]
  rw [show bergWordOf (evalBergWord u * evalBergWord v) _ = u ++ v from
    (bergWordOf_unique _ (evalBergWord_append u v)).symm]
  simp [List.length_append]

theorem bergLength_pos_iff_ne_one {M : Matrix (Fin 2) (Fin 2) ℤ} (hM : InBergSemigroup M) :
    0 < bergLength M hM ↔ M ≠ 1 := by
  obtain ⟨w, rfl⟩ := hM; rw [bergLength_eval]
  simp only [Nat.pos_iff_ne_zero, ne_eq, List.length_eq_zero_iff, evalBergWord_eq_one_iff]

/-! ## Cancellation -/

theorem evalBergWord_left_cancel {u v w : BergWord}
    (h : evalBergWord (u ++ v) = evalBergWord (u ++ w)) : v = w :=
  List.append_cancel_left (evalBergWord_injective h)

theorem evalBergWord_right_cancel {u v w : BergWord}
    (h : evalBergWord (v ++ u) = evalBergWord (w ++ u)) : v = w :=
  List.append_cancel_right (evalBergWord_injective h)

theorem evalBergWord_append_eq_iff {u v s t : BergWord} :
    evalBergWord (u ++ s) = evalBergWord (v ++ t) ↔ u ++ s = v ++ t :=
  ⟨fun h => evalBergWord_injective h, fun h => by rw [h]⟩

/-! ## Prefix Rigidity -/

theorem eval_prefix_rigidity {u v s t : BergWord}
    (h : evalBergWord (u ++ s) = evalBergWord (v ++ t))
    (huv : u.length = v.length) : u = v :=
  (List.append_inj (evalBergWord_injective h) huv).1

/-! ## Overlap Decomposition -/

theorem berg_overlap_free_monoid {u v s t : BergWord}
    (h : evalBergWord (u ++ s) = evalBergWord (v ++ t)) :
    ∃ p a b, u = p ++ a ∧ v = p ++ b ∧ (a = [] ∨ b = []) ∧ a ++ s = b ++ t := by
  have := evalBergWord_injective h;
  rcases List.append_eq_append_iff.mp this with ( ⟨ p, hp ⟩ | ⟨ p, hp ⟩ ) <;> simp_all +decide;
  · exact ⟨ u, [ ], by simp +decide, p, by simp +decide ⟩;
  · grind

theorem equal_products_prefix_comparable {u v s t : BergWord}
    (h : evalBergWord u * evalBergWord s = evalBergWord v * evalBergWord t) :
    u <+: v ∨ v <+: u := by
  rw [← evalBergWord_append, ← evalBergWord_append] at h
  exact List.prefix_or_prefix_of_prefix (List.prefix_append u s)
    (evalBergWord_injective h ▸ List.prefix_append v t)

theorem berg_overlap_decomposition {u v s t : BergWord}
    (h : evalBergWord u * evalBergWord s = evalBergWord v * evalBergWord t) :
    ∃ p u' v', u = p ++ u' ∧ v = p ++ v' ∧ (u' = [] ∨ v' = []) ∧
      evalBergWord u' * evalBergWord s = evalBergWord v' * evalBergWord t := by
  have := @berg_overlap_free_monoid;
  obtain ⟨ p, a, b, rfl, rfl, hab, h ⟩ := @this u v s t ( by simpa [ evalBergWord_append ] using h ) ; use p, a, b; simp_all +decide [ ← mul_assoc, ← evalBergWord_append ] ;