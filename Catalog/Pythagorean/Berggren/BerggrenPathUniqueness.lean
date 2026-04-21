/-! # CatalogBuild.Pythagorean.Berggren.BerggrenPathUniqueness

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 23
-/

import Mathlib

/-- [Section: ## Definitions] -/
inductive BStepU where
  | A | B | C
  deriving Repr, DecidableEq


def applyStepU (s : BStepU) (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match s with
  | .A => (t.1 - 2*t.2.1 + 2*t.2.2, 2*t.1 - t.2.1 + 2*t.2.2, 2*t.1 - 2*t.2.1 + 3*t.2.2)
  | .B => (t.1 + 2*t.2.1 + 2*t.2.2, 2*t.1 + t.2.1 + 2*t.2.2, 2*t.1 + 2*t.2.1 + 3*t.2.2)
  | .C => (-t.1 + 2*t.2.1 + 2*t.2.2, -2*t.1 + t.2.1 + 2*t.2.2, -2*t.1 + 2*t.2.1 + 3*t.2.2)


def applyPathU (path : List BStepU) : ℤ × ℤ × ℤ :=
  path.foldl (fun t s => applyStepU s t) (3, 4, 5)


/-- [Section: ## Section 1: Sigma Identities] -/
theorem sigma1_stepA (a' b' c' : ℤ) :
    let ch := applyStepU .A (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = a' := by simp [applyStepU]; ring


theorem sigma2_stepA (a' b' c' : ℤ) :
    let ch := applyStepU .A (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = -b' := by simp [applyStepU]; ring


theorem sigma1_stepB (a' b' c' : ℤ) :
    let ch := applyStepU .B (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = a' := by simp [applyStepU]; ring


theorem sigma2_stepB (a' b' c' : ℤ) :
    let ch := applyStepU .B (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = b' := by simp [applyStepU]; ring


theorem sigma1_stepC (a' b' c' : ℤ) :
    let ch := applyStepU .C (a', b', c')
    ch.1 + 2 * ch.2.1 - 2 * ch.2.2 = -a' := by simp [applyStepU]; ring


theorem sigma2_stepC (a' b' c' : ℤ) :
    let ch := applyStepU .C (a', b', c')
    2 * ch.1 + ch.2.1 - 2 * ch.2.2 = b' := by simp [applyStepU]; ring


/-- [Section: ## Section 2: Step Uniqueness
The signs of σ₁, σ₂ are disjoint: A → (+,−), B → (+,+), C → (−,+).
So if two steps from positive-legged parents produce the same child, the steps agree.] -/
theorem step_determined (s₁ s₂ : BStepU) (t₁ t₂ : ℤ × ℤ × ℤ)
    (ht₁a : 0 < t₁.1) (ht₁b : 0 < t₁.2.1)
    (ht₂a : 0 < t₂.1) (ht₂b : 0 < t₂.2.1)
    (heq : applyStepU s₁ t₁ = applyStepU s₂ t₂) : s₁ = s₂ := by
  cases s₁ <;> cases s₂ <;> simp_all +decide;
  all_goals unfold applyStepU at heq; norm_num at heq; linarith;


/-- [Section: ## Section 3: Each Step is Injective] -/
theorem applyStepU_injective (s : BStepU) (t₁ t₂ : ℤ × ℤ × ℤ)
    (h : applyStepU s t₁ = applyStepU s t₂) : t₁ = t₂ := by
  cases s <;> simp only [applyStepU, Prod.mk.injEq] at h <;>
    obtain ⟨h1, h2, h3⟩ := h <;> ext <;> linarith


/-- [Section: ## Section 4: Forward Maps Preserve Pythagorean + Positivity] -/
theorem step_pyth (s : BStepU) (a b c : ℤ) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepU s (a, b, c)
    ch.1 ^ 2 + ch.2.1 ^ 2 = ch.2.2 ^ 2 := by
  cases s <;> simp [applyStepU] <;> nlinarith


theorem step_pos (s : BStepU) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    let ch := applyStepU s (a, b, c)
    0 < ch.1 ∧ 0 < ch.2.1 ∧ 0 < ch.2.2 := by
  rcases s with ( _ | _ | _ ) <;> norm_num [ applyStepU ] <;> constructor <;> try nlinarith;
  · constructor <;> nlinarith only [ ha, hb, hc, hpyth ];
  · constructor <;> linarith;
  · constructor <;> nlinarith only [ ha, hb, hc, hpyth ]


/-- [Section: ## Section 5: Hypotenuse Strictly Increases] -/
theorem step_hyp_increase (s : BStepU) (a b c : ℤ)
    (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) (hpyth : a ^ 2 + b ^ 2 = c ^ 2) :
    c < (applyStepU s (a, b, c)).2.2 := by
  cases s <;> simp [applyStepU] <;> nlinarith [sq_nonneg (a - b)]


/-- [Section: ## Section 6: Path Preservation] -/
theorem path_valid_aux :
    ∀ (path : List BStepU) (t : ℤ × ℤ × ℤ),
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    0 < t.1 → 0 < t.2.1 → 0 < t.2.2 →
    let res := path.foldl (fun t s => applyStepU s t) t
    res.1 ^ 2 + res.2.1 ^ 2 = res.2.2 ^ 2 ∧ 0 < res.1 ∧ 0 < res.2.1 ∧ 0 < res.2.2 := by
  intro path
  induction path with
  | nil => intro t hp ha hb hc; exact ⟨hp, ha, hb, hc⟩
  | cons s rest ih =>
    intro t hp ha hb hc
    simp only [List.foldl_cons]
    exact ih _ (step_pyth s _ _ _ hp) (step_pos s _ _ _ ha hb hc hp).1
      (step_pos s _ _ _ ha hb hc hp).2.1 (step_pos s _ _ _ ha hb hc hp).2.2


theorem applyPathU_valid (path : List BStepU) :
    let t := applyPathU path
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 ∧ 0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 :=
  path_valid_aux path (3, 4, 5) (by norm_num) (by norm_num) (by norm_num) (by norm_num)


/-- [Section: ## Section 7: Hypotenuse Bounds] -/
theorem hyp_increases_aux :
    ∀ (path : List BStepU) (t : ℤ × ℤ × ℤ),
    t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2 →
    0 < t.1 → 0 < t.2.1 → 0 < t.2.2 →
    path ≠ [] →
    t.2.2 < (path.foldl (fun t s => applyStepU s t) t).2.2 := by
  intro path
  induction path with
  | nil => intro _ _ _ _ _ h; exact absurd rfl h
  | cons s rest ih =>
    intro t hp ha hb hc _
    simp only [List.foldl_cons]
    by_cases hrest : rest = []
    · subst hrest; simp; exact step_hyp_increase s _ _ _ ha hb hc hp
    · calc t.2.2 < (applyStepU s t).2.2 := step_hyp_increase s _ _ _ ha hb hc hp
        _ < _ := ih _ (step_pyth s _ _ _ hp) (step_pos s _ _ _ ha hb hc hp).1
            (step_pos s _ _ _ ha hb hc hp).2.1 (step_pos s _ _ _ ha hb hc hp).2.2 hrest


theorem nonempty_path_hyp_gt_5 (path : List BStepU) (hne : path ≠ []) :
    5 < (applyPathU path).2.2 := by
  have := hyp_increases_aux path (3, 4, 5) (by norm_num) (by norm_num) (by norm_num) (by norm_num) hne
  simp [applyPathU] at this ⊢; linarith


/-- [Section: ## Section 8: Append / Concat Lemmas] -/
theorem applyPathU_concat (path : List BStepU) (s : BStepU) :
    applyPathU (path.concat s) = applyStepU s (applyPathU path) := by
  simp [applyPathU, List.concat_eq_append, List.foldl_append]


/-- **Berggren Path Uniqueness**: Two paths from root (3,4,5) producing the
same triple must be identical. -/
theorem berggren_path_unique (w₁ w₂ : List BStepU)
    (h : applyPathU w₁ = applyPathU w₂) : w₁ = w₂ :=
  path_unique_aux _ w₁ w₂ rfl h


/-- Different words produce different triples -/
theorem berggren_free_semigroup (w₁ w₂ : List BStepU) (hw : w₁ ≠ w₂) :
    applyPathU w₁ ≠ applyPathU w₂ :=
  fun h => hw (berggren_path_unique w₁ w₂ h)


/-- The map applyPathU is injective -/
theorem applyPathU_injective : Function.Injective applyPathU :=
  fun _ _ h => berggren_path_unique _ _ h


/-- Every PPT in the tree has a unique path representation -/
theorem unique_representation (t : ℤ × ℤ × ℤ)
    (w₁ w₂ : List BStepU) (h₁ : applyPathU w₁ = t) (h₂ : applyPathU w₂ = t) :
    w₁ = w₂ :=
  berggren_path_unique w₁ w₂ (h₁ ▸ h₂ ▸ rfl)
