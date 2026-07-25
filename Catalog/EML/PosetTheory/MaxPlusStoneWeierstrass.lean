/-
# Max-Plus / Max-Times Stone–Weierstrass Bridge

This file proves that a family `A ⊆ C(X, ℝ)` on a compact Hausdorff space `X`
that is closed under pointwise maximum, addition, negation, contains all constants,
and separates points is uniformly dense in `C(X, ℝ)`.

The proof strategy is:
1. Derive closure under `inf` from `sup` and negation via `f ⊓ g = -((-f) ⊔ (-g))`.
2. Derive the strong two-point interpolation property (`SeparatesPointsStrongly`)
   from the additive and max structure.
3. Apply Mathlib's lattice Stone–Weierstrass theorem
   (`ContinuousMap.sublattice_closure_eq_top`).

The result is then transported via `Real.log` / `Real.exp` to a max-times statement
for positive-valued function classes, providing the formal bridge between
idempotent/tropical algebra and classical universal approximation.

## Main results

- `closedUnder_inf_of_sup_neg`: inf-closure from sup + negation
- `dense_of_maxPlus`: density of a max-plus family
- `approx_of_maxPlus`: ε-approximation in sup norm
- `dense_of_maxTimes_log`: log-domain density for positive max-times families

## References

This is an EML (Expressive Machine Learning) bridge theorem connecting
tropical/idempotent algebra to the Stone–Weierstrass approximation program.
-/

import Mathlib

noncomputable section

open ContinuousMap Set Topology

variable {X : Type*} [TopologicalSpace X]

/-! ## Section 1: Lattice closure from max-plus structure -/

/-- The identity `f ⊓ g = -((-f) ⊔ (-g))` in `C(X, ℝ)`. This is the key bridge
from idempotent/max-plus structure to lattice structure. -/
theorem inf_eq_neg_sup_neg (f g : C(X, ℝ)) :
    f ⊓ g = -((-f) ⊔ (-g)) := by
  ext x
  simp only [ContinuousMap.inf_apply, ContinuousMap.sup_apply, ContinuousMap.neg_apply]
  rcases le_total (f x) (g x) with h | h
  · simp [min_eq_left h, max_eq_left (neg_le_neg h)]
  · simp [min_eq_right h, max_eq_right (neg_le_neg h)]

/-- A family closed under `sup` and negation is automatically closed under `inf`. -/
theorem closedUnder_inf_of_sup_neg
    (A : Set C(X, ℝ))
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A) :
    ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊓ g ∈ A := by
  intro f g hf hg
  rw [inf_eq_neg_sup_neg]
  exact hneg (hsup (hneg hf) (hneg hg))

/-! ## Section 2: Additive closure helpers -/

/-- A family containing constants and closed under addition contains `0`. -/
lemma zero_mem_of_const (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A) :
    (0 : C(X, ℝ)) ∈ A := by
  have := hconst 0; simpa using this

/-- A family closed under addition contains `n • f` for `f ∈ A`. -/
lemma nsmul_mem_of_add (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (n : ℕ) ⦃f : C(X, ℝ)⦄ (hf : f ∈ A) : n • f ∈ A := by
  induction n with
  | zero => simpa using zero_mem_of_const A hconst
  | succ n ih => rw [succ_nsmul]; exact hadd ih hf

/-- Addition with a constant. -/
lemma addConst_mem (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    ⦃f : C(X, ℝ)⦄ (c : ℝ) (hf : f ∈ A) : f + ContinuousMap.const X c ∈ A :=
  hadd hf (hconst c)

/-- Subtraction. -/
lemma sub_mem_of_add_neg (A : Set C(X, ℝ))
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    ⦃f g : C(X, ℝ)⦄ (hf : f ∈ A) (hg : g ∈ A) : f - g ∈ A := by
  rw [sub_eq_add_neg]; exact hadd hf (hneg hg)

/-! ## Section 3: Strong point separation from max-plus structure

The key mathematical insight: from a family closed under max, addition, negation,
and containing constants, with ordinary point separation, we can derive the
**strong** two-point interpolation property required by the lattice
Stone–Weierstrass theorem.

Given `x ≠ y` with separating function `f`, we:
1. Translate to get `h` with `h(x) = 0`, `h(y) = d > 0`.
2. Use `max(h, 0)` to ensure nonnegativity.
3. Scale up via `n • h` and truncate via `max(n•h, const(n*d - s)) - const(n*d - s)`
   to achieve any target value `s ≥ 0` at `y` while maintaining `0` at `x`.
4. Use negation for negative targets.
5. Combine x-direction and y-direction interpolators via addition.
-/

/-
From point separation, construct a nonneg function that is 0 at one point
    and positive at another.
-/
lemma exists_mem_zero_pos (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    {x y : X} (hxy : x ≠ y) :
    ∃ h ∈ A, h x = 0 ∧ 0 < h y ∧ ∀ z, 0 ≤ h z := by
  -- Set h = f - const(f(x)) ∈ A.
  obtain ⟨f, hf⟩ := hsep x y hxy
  have h1 : (f - ContinuousMap.const X (f x)) ∈ A := by
    simpa using hadd hf.1 ( hneg ( hconst ( f x ) ) );
  cases' lt_or_gt_of_ne hf.2 with h h;
  · refine' ⟨ ( f - ContinuousMap.const X ( f x ) ) ⊔ ContinuousMap.const X 0, _, _, _, _ ⟩ <;> simp_all +decide [ ContinuousMap.ext_iff ];
    exact hsup h1 ( hconst 0 );
  · refine' ⟨ - ( f - ContinuousMap.const X ( f x ) ) ⊔ ContinuousMap.const X 0, hsup ( hneg h1 ) ( hconst 0 ), _, _, _ ⟩ <;> simp +decide [ h.le ];
    exact h

/-
Given `h ∈ A` with `h x = 0`, `h y = d > 0`, and `h` nonneg,
    for any `0 ≤ s`, construct `g ∈ A` with `g x = 0` and `g y = s`.
-/
lemma exists_mem_zero_nonneg_target (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    {x y : X} {h : C(X, ℝ)} (hh : h ∈ A) (hx : h x = 0) (hy_nn : ∀ z, 0 ≤ h z)
    {d : ℝ} (hd : 0 < d) (hyd : h y = d)
    (s : ℝ) (hs : 0 ≤ s) :
    ∃ g ∈ A, g x = 0 ∧ g y = s := by
  -- Choose $n := \lceil s / d \rceil$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, (n : ℝ) * d ≥ s ∧ s ≥ (n - 1) * d := by
    exact ⟨ ⌈s / d⌉₊, by nlinarith [ Nat.le_ceil ( s / d ), mul_div_cancel₀ s hd.ne' ], by nlinarith [ Nat.ceil_lt_add_one ( show 0 ≤ s / d by positivity ), mul_div_cancel₀ s hd.ne' ] ⟩;
  -- Form $p = n • h \in A$.
  have hp : (n • h) ∈ A := nsmul_mem_of_add A hconst hadd n hh
  -- Form $q = p ⊔ const(n*d - s) - const(n*d - s) \in A$.
  have hq : (n • h ⊔ const X (n * d - s)) - const X (n * d - s) ∈ A := by
    simpa using hadd ( hsup hp ( hconst _ ) ) ( hneg ( hconst _ ) );
  refine' ⟨ _, hq, _, _ ⟩ <;> simp_all +decide [ ContinuousMap.ext_iff ]

/-
Two-point interpolation: given `x ≠ y`, for any target values `a, b : ℝ`,
    there exists `g ∈ A` with `g x = a` and `g y = b`.
-/
theorem separatesPointsStrongly_of_maxPlus (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f ⊔ g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    A.SeparatesPointsStrongly := by
  -- For any $v : X → ℝ$ and $x y : X$, we need to find $f \in A$ such that $f x = v x$ and $f y = v y$.
  intro v x y
  by_cases hxy : x = y
  · use const X (v x)
    simp [hxy, hconst]
  ·
    -- By exists_mem_zero_pos, get h₁ ∈ A with h₁ x = 0, h₁ y = d₁ > 0, h₁ nonneg.
    obtain ⟨h₁, hh₁A, hh₁x, hh₁y, hh₁nn⟩ : ∃ h₁ ∈ A, h₁ x = 0 ∧ 0 < h₁ y ∧ ∀ z, 0 ≤ h₁ z :=
      exists_mem_zero_pos A hconst hadd hsup hneg hsep hxy
    -- By exists_mem_zero_pos, get h₂ ∈ A with h₂ y = 0, h₂ x = d₂ > 0, h₂ nonneg.
    obtain ⟨h₂, hh₂A, hh₂y, hh₂x, hh₂nn⟩ : ∃ h₂ ∈ A, h₂ y = 0 ∧ 0 < h₂ x ∧ ∀ z, 0 ≤ h₂ z :=
      exists_mem_zero_pos A hconst hadd hsup hneg hsep (Ne.symm hxy)
    -- By exists_mem_zero_nonneg_target with h₁ and h₂, we can get functions with any nonneg value at y (with 0 at x) and any nonneg value at x (with 0 at y).
    obtain ⟨g₁, hg₁A, hg₁x, hg₁y⟩ : ∃ g₁ ∈ A, g₁ x = 0 ∧ g₁ y = max (v y - v x) 0 := by
      apply exists_mem_zero_nonneg_target A hconst hadd hsup hneg hh₁A hh₁x hh₁nn;
      exacts [ hh₁y, rfl, le_max_right _ _ ]
    obtain ⟨g₂, hg₂A, hg₂x, hg₂y⟩ : ∃ g₂ ∈ A, g₂ y = 0 ∧ g₂ x = max (v x - v y) 0 := by
      convert exists_mem_zero_nonneg_target A hconst hadd hsup hneg hh₂A hh₂y hh₂nn hh₂x rfl ( Max.max ( v x - v y ) 0 ) ( le_max_right _ _ ) using 1;
    refine' ⟨ g₁ + g₂ + ContinuousMap.const X ( Min.min ( v x ) ( v y ) ), hadd ( hadd hg₁A hg₂A ) ( hconst _ ), _, _ ⟩ <;> simp +decide [ * ];
    · cases max_cases ( v x - v y ) 0 <;> cases min_cases ( v x ) ( v y ) <;> linarith;
    · cases max_cases ( v y - v x ) 0 <;> cases min_cases ( v x ) ( v y ) <;> linarith

/-! ## Section 4: Main density theorems -/

variable [CompactSpace X] [T2Space X]

/-
**Max-Plus Stone–Weierstrass (density version)**: A family of continuous functions
    on a compact Hausdorff space that is closed under `max`, addition, negation,
    contains all constants, and separates points is dense in `C(X, ℝ)`.
-/
theorem dense_of_maxPlus
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊔ g) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y) :
    Dense (A : Set C(X, ℝ)) := by
  have h_dense : closure A = ⊤ := by
    apply ContinuousMap.sublattice_closure_eq_top;
    · exact ⟨_, hconst 0⟩
    · exact fun f hf g hg => closedUnder_inf_of_sup_neg A hsup hneg hf hg
    · exact fun f hf g hg => hsup hf hg
    · exact separatesPointsStrongly_of_maxPlus A hconst hadd hsup hneg hsep
  rwa [dense_iff_closure_eq]

/-
**Max-Plus Stone–Weierstrass (ε-approximation version)**: every continuous function
    can be uniformly approximated to within `ε` by a member of a max-plus family.
-/
theorem approx_of_maxPlus
    (A : Set C(X, ℝ))
    (hconst : ∀ c : ℝ, ContinuousMap.const X c ∈ A)
    (hsup : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → (f ⊔ g) ∈ A)
    (hadd : ∀ ⦃f g : C(X, ℝ)⦄, f ∈ A → g ∈ A → f + g ∈ A)
    (hneg : ∀ ⦃f : C(X, ℝ)⦄, f ∈ A → -f ∈ A)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ A, f x ≠ f y)
    (f : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ g ∈ A, ‖f - g‖ < ε := by
  have := dense_of_maxPlus A hconst hsup hadd hneg hsep;
  simpa [ dist_eq_norm ] using Metric.mem_closure_iff.1 ( this f ) ε hε

/-! ## Section 5: Positive-valued max-times transport

We define a subtype of strictly positive continuous functions and show that the
log-image of a max-times family is a max-plus family, allowing us to apply the
above theorem.
-/

/-- Strictly positive continuous functions. -/
def PosC (X : Type*) [TopologicalSpace X] := {f : C(X, ℝ) // ∀ x, 0 < f x}

namespace PosC

instance : CoeOut (PosC X) C(X, ℝ) := ⟨Subtype.val⟩

/-- Coerce a PosC to a function. -/
instance : CoeFun (PosC X) (fun _ => X → ℝ) := ⟨fun f => f.1⟩

/-- Positive constant function. -/
def const (c : ℝ) (hc : 0 < c) : PosC X :=
  ⟨ContinuousMap.const X c, fun _ => hc⟩

/-- Pointwise maximum of positive functions. -/
def sup (f g : PosC X) : PosC X :=
  ⟨f.1 ⊔ g.1, fun x => lt_sup_of_lt_left (f.2 x)⟩

/-- Pointwise multiplication of positive functions. -/
def mul (f g : PosC X) : PosC X :=
  ⟨f.1 * g.1, fun x => mul_pos (f.2 x) (g.2 x)⟩

/-- Pointwise reciprocal (1/f) of a positive function. -/
def inv (f : PosC X) : PosC X :=
  ⟨⟨fun x => (f x)⁻¹, f.1.continuous.inv₀ (fun x => ne_of_gt (f.2 x))⟩,
    fun x => inv_pos.mpr (f.2 x)⟩

end PosC

/-- The log map applied to a positive continuous function yields a continuous function. -/
def logPosC (f : PosC X) : C(X, ℝ) :=
  ⟨fun x => Real.log (f x),
    Real.continuousOn_log.comp_continuous f.1.continuous (fun x => ne_of_gt (f.2 x))⟩

/-
Log converts multiplication to addition.
-/
theorem logPosC_mul (f g : PosC X) :
    logPosC (PosC.mul f g) = logPosC f + logPosC g := by
  exact ContinuousMap.ext fun x => by simp +decide [ logPosC, PosC.mul, Real.log_mul ( ne_of_gt ( f.2 x ) ) ( ne_of_gt ( g.2 x ) ) ] ;

/-
Log converts max to max (since log is monotone).
-/
theorem logPosC_sup (f g : PosC X) :
    logPosC (PosC.sup f g) = logPosC f ⊔ logPosC g := by
  ext x;
  simp +decide [ logPosC, PosC.sup ];
  cases max_cases ( f x ) ( g x ) <;> simp +decide [ * ];
  · exact Real.log_le_log ( g.2 x ) ( by linarith );
  · exact Real.log_le_log ( f.2 x ) ( by linarith )

/-
Log converts positive constants to real constants.
-/
theorem logPosC_const (c : ℝ) (hc : 0 < c) :
    logPosC (PosC.const (X := X) c hc) = ContinuousMap.const X (Real.log c) := by
  exact ContinuousMap.ext fun _ => rfl

/-
Log converts reciprocal to negation.
-/
theorem logPosC_inv (f : PosC X) :
    logPosC (PosC.inv f) = -logPosC f := by
  ext x;
  exact Real.log_inv _

/-
Log preserves point separation.
-/
theorem logPosC_separates (f : PosC X) {x y : X} (h : f x ≠ f y) :
    (logPosC f) x ≠ (logPosC f) y := by
  contrapose! h;
  exact Real.log_injOn_pos ( f.2 x ) ( f.2 y ) h

/-
The log-image of a max-times family separates points if the family does.
-/
theorem logImage_separatesPoints
    (B : Set (PosC X))
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ B, f x ≠ f y) :
    ∀ x y : X, x ≠ y → ∃ g ∈ logPosC '' B, g x ≠ g y := by
  exact fun x y hxy => by rcases hsep x y hxy with ⟨ f, hfB, hxy ⟩ ; exact ⟨ logPosC f, Set.mem_image_of_mem _ hfB, logPosC_separates f hxy ⟩ ;

/-
The log-image of a max-times family contains all real constants.
-/
theorem logImage_const
    (B : Set (PosC X))
    (hconst : ∀ (c : ℝ) (hc : 0 < c), PosC.const c hc ∈ B) :
    ∀ c : ℝ, ContinuousMap.const X c ∈ logPosC '' B := by
  intro c;
  refine' ⟨ _, hconst ( Real.exp c ) ( Real.exp_pos c ), _ ⟩;
  convert logPosC_const ( Real.exp c ) ( Real.exp_pos c ) using 1;
  · rw [ Real.log_exp ];
  · infer_instance;
  · infer_instance

/-
The log-image of a max-times family is closed under sup.
-/
theorem logImage_sup
    (B : Set (PosC X))
    (hsup : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.sup f g ∈ B) :
    ∀ ⦃f g : C(X, ℝ)⦄, f ∈ logPosC '' B → g ∈ logPosC '' B → f ⊔ g ∈ logPosC '' B := by
  rintro _ _ ⟨ f, hf, rfl ⟩ ⟨ g, hg, rfl ⟩;
  exact ⟨ f.sup g, hsup hf hg, by simp +decide [ logPosC_sup ] ⟩

/-
The log-image of a max-times family is closed under addition.
-/
theorem logImage_add
    (B : Set (PosC X))
    (hmul : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.mul f g ∈ B) :
    ∀ ⦃f g : C(X, ℝ)⦄, f ∈ logPosC '' B → g ∈ logPosC '' B → f + g ∈ logPosC '' B := by
  rintro f g ⟨ f', hf', rfl ⟩ ⟨ g', hg', rfl ⟩;
  exact ⟨ _, hmul hf' hg', logPosC_mul f' g' ▸ rfl ⟩

/-
The log-image of a max-times family is closed under negation.
-/
theorem logImage_neg
    (B : Set (PosC X))
    (hinv : ∀ ⦃f : PosC X⦄, f ∈ B → PosC.inv f ∈ B) :
    ∀ ⦃f : C(X, ℝ)⦄, f ∈ logPosC '' B → -f ∈ logPosC '' B := by
  rintro f ⟨ g, hg, rfl ⟩;
  exact ⟨_, hinv hg, logPosC_inv g⟩

variable [CompactSpace X] [T2Space X]

/-
**Max-Times Stone–Weierstrass (log-domain density)**: the log-image of a positive
    max-times family (closed under max, multiplication, reciprocal, and positive
    constants) that separates points is dense in `C(X, ℝ)`.
-/
theorem dense_of_maxTimes_log
    (B : Set (PosC X))
    (hconst : ∀ (c : ℝ) (hc : 0 < c), PosC.const c hc ∈ B)
    (hsup : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.sup f g ∈ B)
    (hmul : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.mul f g ∈ B)
    (hinv : ∀ ⦃f : PosC X⦄, f ∈ B → PosC.inv f ∈ B)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ B, f x ≠ f y) :
    Dense (logPosC '' B : Set C(X, ℝ)) := by
  exact dense_of_maxPlus _ (logImage_const B hconst) (logImage_sup B hsup)
    (logImage_add B hmul) (logImage_neg B hinv) (logImage_separatesPoints B hsep)

/-
**Max-Times Stone–Weierstrass (log-domain ε-approximation)**: every continuous function
    can be uniformly approximated in log-domain by the log of a member of a positive
    max-times family.
-/
theorem approx_of_maxTimes_log
    (B : Set (PosC X))
    (hconst : ∀ (c : ℝ) (hc : 0 < c), PosC.const c hc ∈ B)
    (hsup : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.sup f g ∈ B)
    (hmul : ∀ ⦃f g : PosC X⦄, f ∈ B → g ∈ B → PosC.mul f g ∈ B)
    (hinv : ∀ ⦃f : PosC X⦄, f ∈ B → PosC.inv f ∈ B)
    (hsep : ∀ x y : X, x ≠ y → ∃ f ∈ B, f x ≠ f y)
    (h : C(X, ℝ)) {ε : ℝ} (hε : 0 < ε) :
    ∃ b ∈ B, ‖h - logPosC b‖ < ε := by
  have := dense_of_maxTimes_log B hconst hsup hmul hinv hsep;
  simpa [ dist_eq_norm, norm_sub_rev ] using Metric.mem_closure_iff.1 ( this h ) ε hε

end