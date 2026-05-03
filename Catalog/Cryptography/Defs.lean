import Mathlib

/-!
# Berggren Semigroup: Definitions and Freeness

## Main Results

* `evalWord_injective` — The evaluation map on words is injective (freeness)
* `φ_injective` — The matrix homomorphism is injective (faithful embedding)
* `fs_left_cancel`, `fs_right_cancel` — Cancellation in the free semigroup
-/

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false
set_option linter.unnecessarySeqFocus false
set_option linter.unusedTactic false

/-- The three Berggren generators for the Pythagorean triple tree. -/
inductive BGen : Type
  | A | B | C
  deriving DecidableEq, Repr, Fintype

instance : Inhabited BGen := ⟨.A⟩

def actGen (g : BGen) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def rootTriple : ℤ × ℤ × ℤ := (3, 4, 5)

def evalWord : List BGen → ℤ × ℤ × ℤ
  | [] => rootTriple
  | g :: rest => actGen g (evalWord rest)

def GoodTriple (t : ℤ × ℤ × ℤ) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

def discX (t : ℤ × ℤ × ℤ) : ℤ := t.1 + 2 * t.2.1 - 2 * t.2.2
def discY (t : ℤ × ℤ × ℤ) : ℤ := 2 * t.1 + t.2.1 - 2 * t.2.2

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

theorem actGen_injective (g : BGen) : Function.Injective (actGen g) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  cases g <;> simp only [actGen, Prod.mk.injEq] at h <;>
    obtain ⟨h1, h2, h3⟩ := h <;>
    exact Prod.ext (by linarith) (Prod.ext (by linarith) (by linarith))

theorem root_good : GoodTriple rootTriple :=
  ⟨by norm_num [rootTriple], by norm_num [rootTriple],
   by norm_num [rootTriple], by norm_num [rootTriple]⟩

theorem actGen_preserves_good (g : BGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    GoodTriple (actGen g t) := by
  obtain ⟨a, b, c⟩ := t; obtain ⟨ht1, ht2, ht3, ht4⟩ := ht
  cases g <;> simp only [GoodTriple, actGen] <;>
    refine ⟨?_, ?_, ?_, ?_⟩ <;> nlinarith [sq_nonneg (a - b), sq_nonneg (a + b - c)]

theorem hyp_strictly_increases (g : BGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    t.2.2 < (actGen g t).2.2 := by
  obtain ⟨a, b, c⟩ := t; obtain ⟨ha, hb, hc, hpyth⟩ := ht
  cases g <;> simp only [actGen] <;> nlinarith [sq_nonneg (a - b)]

theorem hyp_ge_five {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) : 5 ≤ t.2.2 := by
  obtain ⟨ha, hb, hc, hpyth⟩ := ht
  by_contra hlt; push_neg at hlt
  have hc4 : t.2.2 ≤ 4 := by omega
  have ha' : t.1 ≤ 4 := by nlinarith [sq_nonneg t.2.1]
  have hb' : t.2.1 ≤ 4 := by nlinarith [sq_nonneg t.1]
  obtain ⟨a, b, c⟩ := t; simp only at *
  interval_cases a <;> interval_cases b <;> (interval_cases c <;> simp_all)

theorem actGen_ne_root (g : BGen) {t : ℤ × ℤ × ℤ} (ht : GoodTriple t) :
    actGen g t ≠ rootTriple := by
  intro h
  have := hyp_strictly_increases g ht
  have := hyp_ge_five ht
  have : (actGen g t).2.2 = 5 := by rw [h]; rfl
  linarith

theorem actGen_generator_determined {g₁ g₂ : BGen} {p₁ p₂ : ℤ × ℤ × ℤ}
    (hp₁ : GoodTriple p₁) (hp₂ : GoodTriple p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ := by
  obtain ⟨ha₁, hb₁, _, _⟩ := hp₁; obtain ⟨ha₂, hb₂, _, _⟩ := hp₂
  have hdx : discX (actGen g₁ p₁) = discX (actGen g₂ p₂) := by rw [h]
  have hdy : discY (actGen g₁ p₁) = discY (actGen g₂ p₂) := by rw [h]
  rcases g₁ with _ | _ | _ <;> rcases g₂ with _ | _ | _ <;>
    simp only [discX_A, discX_B, discX_C, discY_A, discY_B, discY_C] at hdx hdy <;>
    first | rfl | linarith

theorem actGen_unique_parent {g₁ g₂ : BGen} {p₁ p₂ : ℤ × ℤ × ℤ}
    (hp₁ : GoodTriple p₁) (hp₂ : GoodTriple p₂)
    (h : actGen g₁ p₁ = actGen g₂ p₂) : g₁ = g₂ ∧ p₁ = p₂ := by
  have hg := actGen_generator_determined hp₁ hp₂ h
  subst hg; exact ⟨rfl, actGen_injective g₁ h⟩

theorem evalWord_good (w : List BGen) : GoodTriple (evalWord w) := by
  induction w with
  | nil => exact root_good
  | cons g rest ih => exact actGen_preserves_good g ih

/-- **Berggren evaluation is injective**: distinct words produce distinct triples. -/
theorem evalWord_injective : Function.Injective evalWord := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h; match w₂ with
    | [] => rfl
    | g :: rest => exact absurd h.symm (actGen_ne_root g (evalWord_good rest))
  | cons g₁ rest₁ ih =>
    intro w₂ h; match w₂ with
    | [] => exact absurd h (actGen_ne_root g₁ (evalWord_good rest₁))
    | g₂ :: rest₂ =>
      simp only [evalWord] at h
      have ⟨hg, hp⟩ := actGen_unique_parent (evalWord_good rest₁) (evalWord_good rest₂) h
      subst hg; exact congrArg _ (ih hp)

/-! ## Matrix embedding -/

def genMatrix : BGen → Matrix (Fin 3) (Fin 3) ℤ
  | .A => !![1, -2, 2; 2, -1, 2; 2, -2, 3]
  | .B => !![1, 2, 2; 2, 1, 2; 2, 2, 3]
  | .C => !![(-1), 2, 2; (-2), 1, 2; (-2), 2, 3]

def matProd : List BGen → Matrix (Fin 3) (Fin 3) ℤ
  | [] => 1
  | g :: rest => genMatrix g * matProd rest

noncomputable def φ : FreeSemigroup BGen →ₙ* Matrix (Fin 3) (Fin 3) ℤ :=
  FreeSemigroup.lift genMatrix

theorem φ_of (g : BGen) : φ (FreeSemigroup.of g) = genMatrix g :=
  FreeSemigroup.lift_of genMatrix g

theorem φ_mul (a b : FreeSemigroup BGen) : φ (a * b) = φ a * φ b :=
  map_mul φ a b

def fsToList (w : FreeSemigroup BGen) : List BGen := w.head :: w.tail

theorem fsToList_of (g : BGen) : fsToList (FreeSemigroup.of g) = [g] := rfl

theorem fsToList_mul (a b : FreeSemigroup BGen) :
    fsToList (a * b) = fsToList a ++ fsToList b := by
  cases a; cases b; simp [fsToList, FreeSemigroup.mk_mul_mk]

theorem fsToList_injective : Function.Injective fsToList := by
  intro ⟨h1, t1⟩ ⟨h2, t2⟩ h
  simp [fsToList] at h; exact FreeSemigroup.ext h.1 h.2

theorem matProd_append (w₁ w₂ : List BGen) :
    matProd (w₁ ++ w₂) = matProd w₁ * matProd w₂ := by
  induction w₁ with
  | nil => simp [matProd]
  | cons g rest ih => simp only [List.cons_append, matProd]; rw [ih, Matrix.mul_assoc]

theorem φ_eq_matProd (w : FreeSemigroup BGen) :
    φ w = matProd (fsToList w) := by
  induction w using FreeSemigroup.recOnMul with
  | ih1 x => simp [φ_of, fsToList, matProd]
  | ih2 x y _ ihy =>
    rw [φ_mul, φ_of, ihy]
    have : fsToList (FreeSemigroup.of x * y) = [x] ++ fsToList y := by
      rw [fsToList_mul, fsToList_of]
    rw [this, matProd_append]; simp [matProd]

def rootVec : Matrix (Fin 3) (Fin 1) ℤ := !![3; 4; 5]

private theorem gen_mat_action (g : BGen) (t : ℤ × ℤ × ℤ) :
    genMatrix g * (!![t.1; t.2.1; t.2.2] : Matrix (Fin 3) (Fin 1) ℤ) =
    !![(actGen g t).1; (actGen g t).2.1; (actGen g t).2.2] := by
  obtain ⟨a, b, c⟩ := t
  cases g <;> ext i j <;> fin_cases i <;> fin_cases j <;>
    simp [genMatrix, actGen, Matrix.mul_apply, Fin.sum_univ_three] <;> ring

theorem matProd_root_eq_evalWord (w : List BGen) :
    matProd w * rootVec =
    !![(evalWord w).1; (evalWord w).2.1; (evalWord w).2.2] := by
  induction w with
  | nil =>
    ext i j; fin_cases i <;> fin_cases j <;> simp [matProd, rootVec, evalWord, rootTriple]
  | cons g rest ih =>
    simp only [matProd, evalWord]
    rw [Matrix.mul_assoc, ih]
    exact gen_mat_action g (evalWord rest)

private theorem tripleToVec_injective :
    Function.Injective (fun t : ℤ × ℤ × ℤ =>
      (!![t.1; t.2.1; t.2.2] : Matrix (Fin 3) (Fin 1) ℤ)) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  have h0 := congr_fun (congr_fun h 0) 0
  have h1 := congr_fun (congr_fun h 1) 0
  have h2 := congr_fun (congr_fun h 2) 0
  simp at h0 h1 h2
  exact Prod.ext h0 (Prod.ext h1 h2)

theorem matProd_injective : Function.Injective matProd := by
  intro w₁ w₂ h
  have : matProd w₁ * rootVec = matProd w₂ * rootVec := by rw [h]
  rw [matProd_root_eq_evalWord, matProd_root_eq_evalWord] at this
  exact evalWord_injective (tripleToVec_injective this)

/-- **The matrix semigroup homomorphism is injective (faithful).** -/
theorem φ_injective : Function.Injective φ := by
  intro w₁ w₂ h
  have : matProd (fsToList w₁) = matProd (fsToList w₂) := by
    rw [← φ_eq_matProd, ← φ_eq_matProd, h]
  exact fsToList_injective (matProd_injective this)

/-! ## Free semigroup cancellation and length -/

theorem fs_left_cancel {a b c : FreeSemigroup BGen} (h : a * b = a * c) : b = c := by
  cases a with | mk ha ta =>
  cases b with | mk hb tb =>
  cases c with | mk hc tc =>
  simp only [FreeSemigroup.mk_mul_mk, FreeSemigroup.mk.injEq] at h
  have := List.append_cancel_left h.2
  simp at this
  exact FreeSemigroup.ext this.1 this.2

theorem fs_right_cancel {a b c : FreeSemigroup BGen} (h : b * a = c * a) : b = c := by
  cases a with | mk ha ta =>
  cases b with | mk hb tb =>
  cases c with | mk hc tc =>
  simp only [FreeSemigroup.mk_mul_mk, FreeSemigroup.mk.injEq] at h
  exact FreeSemigroup.ext h.1 (List.append_cancel_right h.2)

/-- Length of a FreeSemigroup element (always ≥ 1). -/
def fsLength (w : FreeSemigroup BGen) : ℕ := w.tail.length + 1

theorem fsLength_pos (w : FreeSemigroup BGen) : 0 < fsLength w :=
  Nat.succ_pos _

theorem fsLength_mul (a b : FreeSemigroup BGen) :
    fsLength (a * b) = fsLength a + fsLength b := by
  cases a with | mk ha ta =>
  cases b with | mk hb tb =>
  simp [fsLength, FreeSemigroup.mk_mul_mk, List.length_append]; omega

theorem fs_no_right_id (a b : FreeSemigroup BGen) : a * b ≠ a := by
  intro h
  have h1 := congrArg fsLength h
  rw [fsLength_mul] at h1
  have h2 := fsLength_pos b
  omega

theorem fs_no_left_id (a b : FreeSemigroup BGen) : b * a ≠ a := by
  intro h
  have h1 := congrArg fsLength h
  rw [fsLength_mul] at h1
  have h2 := fsLength_pos b
  omega