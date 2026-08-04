import Mathlib

/-!
# EML expressions, their depth, and the Hardy level hierarchy

This file provides the common vocabulary for the exponential–logarithmic (EML)
depth theory used elsewhere in the catalog.

## Contents

* `EmlExpr` — the full EML expression grammar: the variable, real constants,
  `+`, `*`, negation, and the *exponential shell* `eml a b = a · exp b`.
  Its semantics is `EmlExpr.eval` and its exponential nesting depth is
  `EmlExpr.emlDepth`.
* `EmlClass n f` — the inductively defined class of real functions built from
  constants and the identity by `+`, `*`, `-` and at most `n` nested
  exponentials.
* `HardyLevel n f` — `f` agrees with a member of `EmlClass n` near `+∞`.  This
  is the semantic ("Hardy level") counterpart of `emlDepth` and is stable under
  eventual equality (`HardyLevel.congr`) and monotone in the level
  (`hardyLevel_mono`).
* `emlDepth_le_hardyLevel` — the bridge: an expression of EML depth `d`
  evaluates to a function of Hardy level `d`.
* `hardyLevel_closed_under_eml` — the exponential shell raises the level by one.
* `hardyLevel_zero_eq_polynomial` and `hardyLevel_one_ne_zero` — the hierarchy
  starts strictly: level `0` consists exactly of the eventually-polynomial
  functions, and `Real.exp`, which sits at level `1`, is not of level `0`.
-/

noncomputable section

open Real

/-! ## The full EML expression grammar -/

/-- Syntax of full EML expressions in one real variable.  The constructor
`eml a b` denotes the *exponential shell* `a · exp b`; ordinary exponentials are
the special case `eml 1 b`. -/
inductive EmlExpr : Type where
  | var : EmlExpr
  | const : ℝ → EmlExpr
  | add : EmlExpr → EmlExpr → EmlExpr
  | mul : EmlExpr → EmlExpr → EmlExpr
  | neg : EmlExpr → EmlExpr
  | eml : EmlExpr → EmlExpr → EmlExpr
  deriving Inhabited

namespace EmlExpr

/-- Interpretation of an EML expression as a real function. -/
def eval : EmlExpr → ℝ → ℝ
  | var, x => x
  | const c, _ => c
  | add a b, x => a.eval x + b.eval x
  | mul a b, x => a.eval x * b.eval x
  | neg a, x => -(a.eval x)
  | eml a b, x => a.eval x * Real.exp (b.eval x)

/-- The exponential nesting depth of an EML expression: only the exponential
shells `eml` contribute. -/
def emlDepth : EmlExpr → ℕ
  | var => 0
  | const _ => 0
  | add a b => max a.emlDepth b.emlDepth
  | mul a b => max a.emlDepth b.emlDepth
  | neg a => a.emlDepth
  | eml a b => 1 + max a.emlDepth b.emlDepth

end EmlExpr

/-! ## The semantic hierarchy -/

/-- `EmlClass n f` : the function `f` is built from real constants and the
identity using `+`, `*`, `-` and at most `n` nested exponentials. -/
inductive EmlClass : ℕ → (ℝ → ℝ) → Prop where
  | const (n : ℕ) (c : ℝ) : EmlClass n (fun _ => c)
  | id (n : ℕ) : EmlClass n (fun x => x)
  | add {n : ℕ} {f g : ℝ → ℝ} : EmlClass n f → EmlClass n g → EmlClass n (fun x => f x + g x)
  | mul {n : ℕ} {f g : ℝ → ℝ} : EmlClass n f → EmlClass n g → EmlClass n (fun x => f x * g x)
  | neg {n : ℕ} {f : ℝ → ℝ} : EmlClass n f → EmlClass n (fun x => -(f x))
  | shell {m n : ℕ} {f g : ℝ → ℝ} :
      EmlClass m f → EmlClass n g →
      EmlClass (1 + max m n) (fun x => f x * Real.exp (g x))

/-- Two functions are **eventually equal** if they agree on some half-line
`[X, ∞)`.  Hardy levels only see this equivalence relation. -/
def EventuallyEq' (f g : ℝ → ℝ) : Prop := ∃ X : ℝ, ∀ x ≥ X, f x = g x

namespace EventuallyEq'

theorem refl (f : ℝ → ℝ) : EventuallyEq' f f := ⟨0, fun _ _ => rfl⟩

theorem symm {f g : ℝ → ℝ} (h : EventuallyEq' f g) : EventuallyEq' g f := by
  obtain ⟨X, hX⟩ := h
  exact ⟨X, fun x hx => (hX x hx).symm⟩

theorem trans {f g h : ℝ → ℝ} (hfg : EventuallyEq' f g) (hgh : EventuallyEq' g h) :
    EventuallyEq' f h := by
  obtain ⟨X₁, hX₁⟩ := hfg
  obtain ⟨X₂, hX₂⟩ := hgh
  refine ⟨max X₁ X₂, fun x hx => ?_⟩
  rw [hX₁ x (le_trans (le_max_left _ _) hx), hX₂ x (le_trans (le_max_right _ _) hx)]

end EventuallyEq'

/-- `HardyLevel n f` : the function `f` coincides, near `+∞`, with a function of
`EmlClass n`.  This is the Hardy-hierarchy level of `f`. -/
def HardyLevel (n : ℕ) (f : ℝ → ℝ) : Prop :=
  ∃ g : ℝ → ℝ, EmlClass n g ∧ EventuallyEq' g f

/-- Members of `EmlClass n` have Hardy level `n`. -/
theorem HardyLevel.of_emlClass {n : ℕ} {f : ℝ → ℝ} (h : EmlClass n f) : HardyLevel n f :=
  ⟨f, h, 0, fun _ _ => rfl⟩

/-- `EmlClass` is monotone in the level. -/
theorem EmlClass.mono : ∀ {m n : ℕ} {f : ℝ → ℝ}, m ≤ n → EmlClass m f → EmlClass n f := by
  intro m n f hmn hf
  induction hf generalizing n with
  | const _ c => exact EmlClass.const _ c
  | id _ => exact EmlClass.id _
  | add _ _ iha ihb => exact (iha hmn).add (ihb hmn)
  | mul _ _ iha ihb => exact (iha hmn).mul (ihb hmn)
  | neg _ ih => exact (ih hmn).neg
  | @shell m₁ m₂ f g hf hg ihf ihg =>
      obtain ⟨k, rfl⟩ : ∃ k, n = 1 + max m₁ m₂ + k := ⟨n - (1 + max m₁ m₂), by omega⟩
      have h1 : m₁ ≤ max m₁ m₂ + k := le_trans (le_max_left _ _) (Nat.le_add_right _ _)
      have h2 : m₂ ≤ max m₁ m₂ + k := le_trans (le_max_right _ _) (Nat.le_add_right _ _)
      have := (ihf h1).shell (ihg h2)
      simpa [Nat.max_self, Nat.add_assoc] using this

/-- Hardy level is monotone in the level. -/
theorem hardyLevel_mono {m n : ℕ} {f : ℝ → ℝ} (hmn : m ≤ n) (hf : HardyLevel m f) :
    HardyLevel n f := by
  obtain ⟨g, hg, X, hX⟩ := hf
  exact ⟨g, hg.mono hmn, X, hX⟩

/-- Hardy level only depends on the behaviour of the function near `+∞`. -/
theorem HardyLevel.congr {n : ℕ} {f g : ℝ → ℝ} (hf : HardyLevel n f)
    (h : EventuallyEq' f g) : HardyLevel n g := by
  obtain ⟨u, hu, X₁, hX₁⟩ := hf
  obtain ⟨X₂, hX₂⟩ := h
  refine ⟨u, hu, max X₁ X₂, fun x hx => ?_⟩
  have h1 : x ≥ X₁ := le_trans (le_max_left _ _) hx
  have h2 : x ≥ X₂ := le_trans (le_max_right _ _) hx
  rw [hX₁ x h1, hX₂ x h2]

/-- Hardy levels are closed under sums. -/
theorem hardyLevel_add {n : ℕ} {f g : ℝ → ℝ} (hf : HardyLevel n f) (hg : HardyLevel n g) :
    HardyLevel n (fun x => f x + g x) := by
  obtain ⟨u, hu, X₁, hX₁⟩ := hf
  obtain ⟨v, hv, X₂, hX₂⟩ := hg
  refine ⟨fun x => u x + v x, hu.add hv, max X₁ X₂, fun x hx => ?_⟩
  show u x + v x = f x + g x
  rw [hX₁ x (le_trans (le_max_left _ _) hx), hX₂ x (le_trans (le_max_right _ _) hx)]

/-- Hardy levels are closed under products. -/
theorem hardyLevel_mul {n : ℕ} {f g : ℝ → ℝ} (hf : HardyLevel n f) (hg : HardyLevel n g) :
    HardyLevel n (fun x => f x * g x) := by
  obtain ⟨u, hu, X₁, hX₁⟩ := hf
  obtain ⟨v, hv, X₂, hX₂⟩ := hg
  refine ⟨fun x => u x * v x, hu.mul hv, max X₁ X₂, fun x hx => ?_⟩
  show u x * v x = f x * g x
  rw [hX₁ x (le_trans (le_max_left _ _) hx), hX₂ x (le_trans (le_max_right _ _) hx)]

/-- Hardy levels are closed under negation. -/
theorem hardyLevel_neg {n : ℕ} {f : ℝ → ℝ} (hf : HardyLevel n f) :
    HardyLevel n (fun x => -(f x)) := by
  obtain ⟨u, hu, X, hX⟩ := hf
  exact ⟨fun x => -(u x), hu.neg, X, fun x hx => by show -(u x) = -(f x); rw [hX x hx]⟩

/-- **The exponential shell raises the Hardy level by one.** -/
theorem hardyLevel_closed_under_eml {m n : ℕ} {f g : ℝ → ℝ}
    (hf : HardyLevel m f) (hg : HardyLevel n g) :
    HardyLevel (1 + max m n) (fun x => f x * Real.exp (g x)) := by
  obtain ⟨u, hu, X₁, hX₁⟩ := hf
  obtain ⟨v, hv, X₂, hX₂⟩ := hg
  refine ⟨fun x => u x * Real.exp (v x), hu.shell hv, max X₁ X₂, fun x hx => ?_⟩
  show u x * Real.exp (v x) = f x * Real.exp (g x)
  rw [hX₁ x (le_trans (le_max_left _ _) hx), hX₂ x (le_trans (le_max_right _ _) hx)]

/-- **Syntax to semantics.**  An EML expression of depth `d` evaluates to a
function of Hardy level `d`. -/
theorem emlDepth_le_hardyLevel (e : EmlExpr) : HardyLevel e.emlDepth (fun x => e.eval x) := by
  induction e with
  | var => exact HardyLevel.of_emlClass (EmlClass.id 0)
  | const c => exact HardyLevel.of_emlClass (EmlClass.const 0 c)
  | add a b iha ihb =>
      exact hardyLevel_add (hardyLevel_mono (le_max_left _ _) iha)
        (hardyLevel_mono (le_max_right _ _) ihb)
  | mul a b iha ihb =>
      exact hardyLevel_mul (hardyLevel_mono (le_max_left _ _) iha)
        (hardyLevel_mono (le_max_right _ _) ihb)
  | neg a ih => exact hardyLevel_neg ih
  | eml a b iha ihb => exact hardyLevel_closed_under_eml iha ihb

/-! ## The bottom of the hierarchy -/

/-- Every member of `EmlClass 0` is a polynomial function: without exponential
shells only ring operations on `x` and constants are available. -/
theorem EmlClass.eq_polynomial_of_level_zero {n : ℕ} {f : ℝ → ℝ} (h : EmlClass n f) (hn : n = 0) :
    ∃ p : Polynomial ℝ, ∀ x, f x = p.eval x := by
  induction h with
  | const _ c => exact ⟨Polynomial.C c, fun x => by simp⟩
  | id _ => exact ⟨Polynomial.X, fun x => by simp⟩
  | add _ _ iha ihb =>
      obtain ⟨p, hp⟩ := iha hn; obtain ⟨q, hq⟩ := ihb hn
      exact ⟨p + q, fun x => by simp [hp, hq]⟩
  | mul _ _ iha ihb =>
      obtain ⟨p, hp⟩ := iha hn; obtain ⟨q, hq⟩ := ihb hn
      exact ⟨p * q, fun x => by simp [hp, hq]⟩
  | neg _ ih =>
      obtain ⟨p, hp⟩ := ih hn
      exact ⟨-p, fun x => by simp [hp]⟩
  | @shell m k f g _ _ _ _ => omega

/-- Every member of `EmlClass 0` is a polynomial function. -/
theorem EmlClass.zero_eq_polynomial {f : ℝ → ℝ} (h : EmlClass 0 f) :
    ∃ p : Polynomial ℝ, ∀ x, f x = p.eval x :=
  h.eq_polynomial_of_level_zero rfl

/-- Powers of the variable belong to `EmlClass 0`. -/
theorem EmlClass.pow (k : ℕ) : EmlClass 0 (fun x : ℝ => x ^ k) := by
  induction k with
  | zero => simpa using EmlClass.const 0 1
  | succ k ih => simpa [pow_succ] using ih.mul (EmlClass.id 0)

/-- Every polynomial function belongs to `EmlClass 0`. -/
theorem EmlClass.of_polynomial (p : Polynomial ℝ) : EmlClass 0 (fun x => p.eval x) := by
  induction p using Polynomial.induction_on' with
  | add p q hp hq => simpa using hp.add hq
  | monomial n a =>
      simpa [Polynomial.eval_monomial] using (EmlClass.const 0 a).mul (EmlClass.pow n)

/-- **Level `0` is exactly the eventually-polynomial functions.** -/
theorem hardyLevel_zero_eq_polynomial {f : ℝ → ℝ} :
    HardyLevel 0 f ↔ ∃ (p : Polynomial ℝ) (X : ℝ), ∀ x ≥ X, p.eval x = f x := by
  constructor
  · rintro ⟨g, hg, X, hX⟩
    obtain ⟨p, hp⟩ := hg.zero_eq_polynomial
    exact ⟨p, X, fun x hx => by rw [← hp x]; exact hX x hx⟩
  · rintro ⟨p, X, hX⟩
    exact ⟨fun x => p.eval x, EmlClass.of_polynomial p, X, hX⟩

/-- `Real.exp` has Hardy level `1`. -/
theorem hardyLevel_one_exp : HardyLevel 1 Real.exp := by
  have h : EmlClass (1 + max 0 0) (fun x => (1 : ℝ) * Real.exp x) :=
    (EmlClass.const 0 1).shell (EmlClass.id 0)
  refine ⟨fun x => 1 * Real.exp x, by simpa using h, 0, fun x _ => one_mul _⟩

/-- **The hierarchy is strict at the bottom.**  The exponential function, which
has Hardy level `1`, does not have Hardy level `0`: it eventually dominates
every polynomial. -/
theorem hardyLevel_one_ne_zero : ¬ HardyLevel 0 Real.exp := by
  rw [hardyLevel_zero_eq_polynomial]
  rintro ⟨p, X, hX⟩
  -- `p.eval x / exp x → 0`, yet it is eventually equal to `1`
  have h0 : Filter.Tendsto (fun x : ℝ => p.eval x / Real.exp x) Filter.atTop (nhds 0) :=
    p.tendsto_div_exp_atTop
  have h1 : Filter.Tendsto (fun x : ℝ => p.eval x / Real.exp x) Filter.atTop (nhds 1) := by
    refine Filter.Tendsto.congr' ?_ tendsto_const_nhds
    filter_upwards [Filter.eventually_ge_atTop X] with x hx
    rw [hX x hx, div_self (Real.exp_ne_zero x)]
  have := tendsto_nhds_unique h0 h1
  norm_num at this

/-! ## Convenience aliases -/

/-- Constants have every Hardy level. -/
theorem hardyLevel_const (n : ℕ) (c : ℝ) : HardyLevel n (fun _ => c) :=
  HardyLevel.of_emlClass (EmlClass.const n c)

/-- Constants have Hardy level `0`. -/
theorem HardyLevel.base_const (c : ℝ) : HardyLevel 0 (fun _ => c) :=
  hardyLevel_const 0 c

/-- The identity has every Hardy level. -/
theorem hardyLevel_id (n : ℕ) : HardyLevel n (fun x => x) :=
  HardyLevel.of_emlClass (EmlClass.id n)

@[inherit_doc hardyLevel_add]
theorem HardyLevel.add {n : ℕ} {f g : ℝ → ℝ} (hf : HardyLevel n f) (hg : HardyLevel n g) :
    HardyLevel n (fun x => f x + g x) := hardyLevel_add hf hg

@[inherit_doc hardyLevel_mul]
theorem HardyLevel.mul {n : ℕ} {f g : ℝ → ℝ} (hf : HardyLevel n f) (hg : HardyLevel n g) :
    HardyLevel n (fun x => f x * g x) := hardyLevel_mul hf hg

@[inherit_doc hardyLevel_neg]
theorem HardyLevel.neg {n : ℕ} {f : ℝ → ℝ} (hf : HardyLevel n f) :
    HardyLevel n (fun x => -(f x)) := hardyLevel_neg hf

/-! ## Iterated exponentials -/

/-- The `n`-fold iterated exponential `exp (exp (⋯ (x)))`, the canonical
inhabitant of Hardy level `n`. -/
def iterExp : ℕ → (ℝ → ℝ)
  | 0 => id
  | n + 1 => fun x => Real.exp (iterExp n x)

@[simp] theorem iterExp_zero : iterExp 0 = id := rfl

@[simp] theorem iterExp_succ (n : ℕ) (x : ℝ) :
    iterExp (n + 1) x = Real.exp (iterExp n x) := rfl

/-- The `n`-fold iterated exponential lies in `EmlClass n`. -/
theorem emlClass_iterExp (n : ℕ) : EmlClass n (iterExp n) := by
  induction n with
  | zero => exact EmlClass.id 0
  | succ n ih =>
      have h := (EmlClass.const 0 (1 : ℝ)).shell ih
      have h1 : (1 + max 0 n) = n + 1 := by omega
      rw [h1] at h
      have h2 : (fun x => (1 : ℝ) * Real.exp (iterExp n x)) = iterExp (n + 1) := by
        funext x; simp
      rwa [h2] at h

/-- The `n`-fold iterated exponential has Hardy level `n`. -/
theorem iterExp_mem_hardyLevel (n : ℕ) : HardyLevel n (iterExp n) :=
  HardyLevel.of_emlClass (emlClass_iterExp n)


end