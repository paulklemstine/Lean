/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Tropical Hodge Theory via Supermodularity Hierarchies

This file develops a **graded tropical positivity hierarchy** on functions
`g : Finset α → ℝ` over a finite ground set, inspired by the weight/Hodge
filtration in toric and matroidal geometry. The key idea is that *iterated
supermodularity* defines a depth invariant — the **tropical Hodge depth** —
that behaves like a tropical shadow of Lefschetz-type structure.

## Mathematical Overview

A set function `g : Finset α → ℝ` is **supermodular** if
`g(s ∪ t) + g(s ∩ t) ≥ g(s) + g(t)` for all `s, t`. A positive function `f`
is **log-supermodular** if `f(s∪t) · f(s∩t) ≥ f(s) · f(t)`, equivalently
`log(f)` is supermodular.

We define **iterated supermodularity of order k** recursively: order 0 is
ordinary supermodularity, and order `k+1` additionally requires that all
discrete difference functions `s ↦ g(s ∪ {a}) - g(s)` have order `k`.

The **tropical bridge** transports this hierarchy: log-supermodularity of
order `k` for `f` is equivalent to supermodularity of order `k` for `log(f)`.

## Main Definitions

* `supermodDefect g s t` — The supermodularity defect.
* `elemDiff g a s` — Discrete difference `g(s ∪ {a}) - g(s)`.
* `SupermodularOrder k g` — Iterated supermodularity of depth `k`.
* `LogSupermodOrder k f` — Multiplicative hierarchy: log-supermodularity of order `k`.
* `TropicalBridgeOrder k f` — Alias: supermod order `k` on `log ∘ f`.

## Main Results

* `SupermodularOrder.mono` — Order `k+1` implies order `k` (filtration).
* `SupermodularOrder.of_le` — Monotonicity generalized.
* `SupermodularOrder.nonneg_linear_comb` — Cone closure.
* `log_supermodOrder_of_logSupermod` — Forward bridge transport.
* `exp_logSupermod_of_supermodOrder` — Reverse bridge transport.
* `depth_unique` — Depth is well-defined.
* `supermodularOrder_card` — Cardinality has all orders.
* `supermodularOrder_affine` — Affine rank-defect functions have all orders.

## Keywords

tropical Hodge theory, supermodularity hierarchy, discrete convexity, Lorentzian polynomials,
matroid Hodge theory, weight filtration, polyhedral cones, certified computation
-/

noncomputable section

open Finset Real

variable {α : Type*} [DecidableEq α]

/-! ## Core Definitions -/

/-- The **supermodularity defect** of `g` at sets `s, t`:
    `g(s ∪ t) + g(s ∩ t) - g(s) - g(t)`. -/
def supermodDefect (g : Finset α → ℝ) (s t : Finset α) : ℝ :=
  g (s ∪ t) + g (s ∩ t) - g s - g t

/-- Discrete difference: `g(s ∪ {a}) - g(s)`. -/
def elemDiff (g : Finset α → ℝ) (a : α) (s : Finset α) : ℝ :=
  g (s ∪ {a}) - g s

/-- **Iterated supermodularity of order k**.
  - Order 0: `∀ s t, 0 ≤ g(s∪t) + g(s∩t) - g(s) - g(t)`.
  - Order `k+1`: order `k`, plus `∀ a, elemDiff g a` has order `k`. -/
def SupermodularOrder : ℕ → (Finset α → ℝ) → Prop
  | 0, g => ∀ s t : Finset α, 0 ≤ supermodDefect g s t
  | k + 1, g => SupermodularOrder k g ∧
                ∀ a : α, SupermodularOrder k (elemDiff g a)

/-- **Log-supermodularity of order k** for positive functions.
  - Order 0: `f(s) · f(t) ≤ f(s∪t) · f(s∩t)` for all `s, t`.
  - Order `k+1`: order `k`, plus `∀ a`, `elemDiff (log ∘ f) a` has supermod order `k`. -/
def LogSupermodOrder : ℕ → (Finset α → ℝ) → Prop
  | 0, f => ∀ s t : Finset α, f s * f t ≤ f (s ∪ t) * f (s ∩ t)
  | k + 1, f => LogSupermodOrder k f ∧
                ∀ a : α, SupermodularOrder k (elemDiff (fun s => Real.log (f s)) a)

/-- **Tropical bridge order**: `f` has order `k` iff `log ∘ f` has SupermodularOrder `k`. -/
def TropicalBridgeOrder (k : ℕ) (f : Finset α → ℝ) : Prop :=
  SupermodularOrder k (fun s => Real.log (f s))

/-! ## Basic Algebraic Properties -/

theorem supermodDefect_comm (g : Finset α → ℝ) (s t : Finset α) :
    supermodDefect g s t = supermodDefect g t s := by
  simp only [supermodDefect, Finset.union_comm, Finset.inter_comm]; ring

theorem supermodDefect_linear (g₁ g₂ : Finset α → ℝ) (a b : ℝ) (s t : Finset α) :
    supermodDefect (fun x => a * g₁ x + b * g₂ x) s t =
    a * supermodDefect g₁ s t + b * supermodDefect g₂ s t := by
  simp only [supermodDefect]; ring

theorem elemDiff_linear (g₁ g₂ : Finset α → ℝ) (a b : ℝ) (e : α) :
    elemDiff (fun x => a * g₁ x + b * g₂ x) e =
    fun s => a * elemDiff g₁ e s + b * elemDiff g₂ e s := by
  ext s; simp only [elemDiff]; ring

/-! ## Theorem 1: Monotonicity of the Hierarchy

This is the fundamental filtration property. Without monotonicity, the "depth"
invariant would be ill-posed. Monotonicity ensures the hierarchy is genuinely
a filtration, and the tropical Hodge depth is well-defined as the supremum
of satisfied orders.

**Proof**: Immediate from the recursive definition — order `k+1` includes
order `k` as a conjunct. The generalization to arbitrary gaps follows by
induction on `m`. -/

/-- **Monotonicity**: order `k+1` implies order `k`. -/
theorem SupermodularOrder.mono
    (g : Finset α → ℝ) {k : ℕ}
    (h : SupermodularOrder (k + 1) g) : SupermodularOrder k g :=
  h.1

/-- **Monotonicity generalized**: order `m` implies order `k` for `k ≤ m`. -/
theorem SupermodularOrder.of_le
    (g : Finset α → ℝ) {k m : ℕ} (hkm : k ≤ m)
    (hm : SupermodularOrder m g) : SupermodularOrder k g := by
  induction m with
  | zero => rwa [Nat.le_zero.mp hkm]
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le hkm with rfl | hlt
    · exact hm
    · exact ih (Nat.lt_succ_iff.mp hlt) hm.1

/-! ## Theorem 3: Closure under Nonnegative Linear Combination

A Hodge-theoretic cone should be a cone. This theorem shows the set of functions
satisfying `SupermodularOrder k` forms a convex cone, closed under nonnegative
linear combinations. The proof is by induction on `k`, using the linearity of
the defect functional and the linearity of the elemDiff operator. -/

/-- **Cone property**: closed under nonneg linear combinations. -/
theorem SupermodularOrder.nonneg_linear_comb
    (k : ℕ) :
    ∀ {g₁ g₂ : Finset α → ℝ} {a b : ℝ},
    0 ≤ a → 0 ≤ b →
    SupermodularOrder k g₁ →
    SupermodularOrder k g₂ →
    SupermodularOrder k (fun s => a * g₁ s + b * g₂ s) := by
  induction k with
  | zero =>
    intro g₁ g₂ a b ha hb h₁ h₂ s t
    rw [supermodDefect_linear]
    exact add_nonneg (mul_nonneg ha (h₁ s t)) (mul_nonneg hb (h₂ s t))
  | succ n ih =>
    intro g₁ g₂ a b ha hb h₁ h₂
    refine ⟨ih ha hb h₁.1 h₂.1, fun e => ?_⟩
    rw [elemDiff_linear]
    exact ih ha hb (h₁.2 e) (h₂.2 e)

/-- Sum preserves the hierarchy. -/
theorem SupermodularOrder.add
    {k : ℕ} {g₁ g₂ : Finset α → ℝ}
    (h₁ : SupermodularOrder k g₁)
    (h₂ : SupermodularOrder k g₂) :
    SupermodularOrder k (fun s => g₁ s + g₂ s) := by
  have : (fun s => g₁ s + g₂ s) = fun s => 1 * g₁ s + 1 * g₂ s := by ext s; ring
  rw [this]
  exact SupermodularOrder.nonneg_linear_comb k (by norm_num : (0:ℝ) ≤ 1)
    (by norm_num : (0:ℝ) ≤ 1) h₁ h₂

/-- Nonneg scalar multiples preserve the hierarchy. -/
theorem SupermodularOrder.nonneg_smul
    {k : ℕ} {g : Finset α → ℝ} {c : ℝ}
    (hc : 0 ≤ c) (h : SupermodularOrder k g) :
    SupermodularOrder k (fun s => c * g s) := by
  have : (fun s => c * g s) = fun s => c * g s + 0 * g s := by ext s; ring
  rw [this]
  exact SupermodularOrder.nonneg_linear_comb k hc le_rfl h h

/-! ## Zero and Constant Functions -/

/-- Zero function has all orders. -/
theorem supermodularOrder_zero_fun (k : ℕ) :
    SupermodularOrder k (fun _ : Finset α => (0 : ℝ)) := by
  induction k with
  | zero => intro s t; simp [supermodDefect]
  | succ n ih =>
    refine ⟨ih, fun a => ?_⟩
    have : elemDiff (fun _ : Finset α => (0 : ℝ)) a = fun _ => 0 := by
      ext s; simp [elemDiff]
    rw [this]; exact ih

/-- Constant functions have all orders. -/
theorem supermodularOrder_const {k : ℕ} (c : ℝ) :
    SupermodularOrder k (fun _ : Finset α => c) := by
  induction k with
  | zero => intro s t; simp [supermodDefect]
  | succ n ih =>
    refine ⟨ih, fun a => ?_⟩
    have : elemDiff (fun _ : Finset α => c) a = fun _ => (0 : ℝ) := by
      ext s; simp [elemDiff]
    rw [this]; exact supermodularOrder_zero_fun n

/-! ## Theorem 2: Tropical Bridge Transport

The bridge between the multiplicative world (log-supermodularity) and the
additive world (supermodularity) extends to the full iterated hierarchy.

**Forward**: If `f` is positive and log-supermodular of order `k`, then
`log(f)` has supermodular order `k`. At order 0, this uses `Real.log_le_log`
and `Real.log_mul`. The inductive step is immediate from the definitions.

**Reverse**: If `g` has supermodular order `k`, then `exp(g)` has
log-supermodular order `k`. At order 0, this uses `Real.exp_add` and
`Real.exp_le_exp`. The inductive step uses `log(exp(g)) = g`. -/

/-
**Forward bridge** (base case): log-supermodularity implies supermodularity of `log`.
-/
theorem log_supermodOrder_zero_of_logSupermod_zero
    {f : Finset α → ℝ}
    (hpos : ∀ s, 0 < f s)
    (hlog : LogSupermodOrder 0 f) :
    SupermodularOrder 0 (fun s => Real.log (f s)) := by
  intro s t;
  unfold supermodDefect;
  simp +zetaDelta at *;
  rw [ ← Real.log_mul ( ne_of_gt ( hpos _ ) ) ( ne_of_gt ( hpos _ ) ), le_sub_iff_add_le', ← Real.log_mul ( ne_of_gt ( hpos _ ) ) ( ne_of_gt ( hpos _ ) ) ];
  exact Real.log_le_log ( mul_pos ( hpos _ ) ( hpos _ ) ) ( hlog s t )

/-- **Forward bridge** for all orders. -/
theorem log_supermodOrder_of_logSupermod
    (k : ℕ) :
    ∀ {f : Finset α → ℝ},
    (∀ s, 0 < f s) →
    LogSupermodOrder k f →
    SupermodularOrder k (fun s => Real.log (f s)) := by
  induction k with
  | zero => intro f hpos hlog; exact log_supermodOrder_zero_of_logSupermod_zero hpos hlog
  | succ n ih => intro f hpos hlog; exact ⟨ih hpos hlog.1, hlog.2⟩

/-
**Reverse bridge** (base case): supermodularity of `g` implies log-supermodularity of `exp(g)`.
-/
theorem exp_logSupermod_zero_of_supermodOrder_zero
    {g : Finset α → ℝ}
    (hsuper : SupermodularOrder 0 g) :
    LogSupermodOrder 0 (fun s => Real.exp (g s)) := by
  intro s t;
  simpa [ ← Real.exp_add ] using Real.exp_le_exp.2 ( by linarith [ hsuper s t, show supermodDefect g s t = g ( s ∪ t ) + g ( s ∩ t ) - g s - g t from rfl ] )

/-- **Reverse bridge** for all orders. -/
theorem exp_logSupermod_of_supermodOrder
    (k : ℕ) :
    ∀ {g : Finset α → ℝ},
    SupermodularOrder k g →
    LogSupermodOrder k (fun s => Real.exp (g s)) := by
  induction k with
  | zero => intro g h; exact exp_logSupermod_zero_of_supermodOrder_zero h
  | succ n ih =>
    intro g hsuper
    refine ⟨ih hsuper.1, fun a => ?_⟩
    have simplify : elemDiff (fun s => Real.log (Real.exp (g s))) a =
                    elemDiff g a := by
      ext s; simp [elemDiff, Real.log_exp]
    rw [simplify]
    exact hsuper.2 a

/-! ## Theorem 4: Depth Characterization

The depth invariant is well-defined: if a function satisfies order `k` but not
order `k+1`, then `k` is its unique tropical Hodge depth. -/

/-- **Depth witness theorem**. -/
theorem depth_characterization
    {g : Finset α → ℝ} {k : ℕ}
    (hk : SupermodularOrder k g)
    (hfail : ¬SupermodularOrder (k + 1) g) :
    SupermodularOrder k g ∧ ¬SupermodularOrder (k + 1) g :=
  ⟨hk, hfail⟩

/-- If order `k+1` fails, then order `m` fails for all `m ≥ k+1`. -/
theorem not_supermodularOrder_of_not_succ
    (g : Finset α → ℝ) {k m : ℕ}
    (hfail : ¬SupermodularOrder (k + 1) g)
    (hm : k + 1 ≤ m) :
    ¬SupermodularOrder m g := by
  intro habs; exact hfail (SupermodularOrder.of_le g hm habs)

/-- **Depth uniqueness**: tropical Hodge depth is a genuine invariant. -/
theorem depth_unique
    {g : Finset α → ℝ} {k₁ k₂ : ℕ}
    (h₁ : SupermodularOrder k₁ g) (hf₁ : ¬SupermodularOrder (k₁ + 1) g)
    (h₂ : SupermodularOrder k₂ g) (hf₂ : ¬SupermodularOrder (k₂ + 1) g) :
    k₁ = k₂ := by
  by_contra hne
  rcases Nat.lt_or_gt_of_ne hne with hlt | hgt
  · exact hf₁ (SupermodularOrder.of_le g (Nat.succ_le_of_lt hlt) h₂)
  · exact hf₂ (SupermodularOrder.of_le g (Nat.succ_le_of_lt hgt) h₁)

/-! ## Theorem 5: Cross-Domain — Cardinality and Rank Functions

The cardinality function `|s|` is **modular** (defect identically zero), hence
supermodular of all orders. This serves as the base connecting to matroid rank
functions: for a matroid with rank function `r`, the defect `|s| - r(s)` is
supermodular by submodularity of `r`. -/

/-- **Cardinality is modular**: `|s∪t| + |s∩t| = |s| + |t|`. -/
theorem card_supermod_defect_eq_zero (s t : Finset α) :
    supermodDefect (fun s : Finset α => (s.card : ℝ)) s t = 0 := by
  unfold supermodDefect
  simp [sub_eq_iff_eq_add]
  exact_mod_cast by rw [Finset.card_union_add_card_inter]; ring

/-- **Cardinality** has supermodularity order 0. -/
theorem supermodularOrder_zero_card :
    SupermodularOrder 0 (fun s : Finset α => (s.card : ℝ)) := by
  intro s t; rw [card_supermod_defect_eq_zero]

/-- elemDiff of cardinality is the indicator of non-membership. -/
theorem elemDiff_card_eq (a : α) (s : Finset α) :
    elemDiff (fun s : Finset α => (s.card : ℝ)) a s =
    if a ∈ s then 0 else 1 := by
  split_ifs <;> simp_all [elemDiff]

/-- The supermodularity defect of elemDiff of cardinality is 0. -/
theorem supermodDefect_elemDiff_card_eq_zero (a : α) (s t : Finset α) :
    supermodDefect (elemDiff (fun s : Finset α => (s.card : ℝ)) a) s t = 0 := by
  unfold supermodDefect elemDiff
  by_cases ha : a ∈ s <;> by_cases hb : a ∈ t <;> simp_all [Finset.card_union]

/-
**Cardinality** has all supermodularity orders.
-/
theorem supermodularOrder_card (k : ℕ) :
    SupermodularOrder k (fun s : Finset α => (s.card : ℝ)) := by
  -- A function whose supermodularity defect is identically zero (modular) has all orders.
  have h_modular (g : Finset α → ℝ) (hg : ∀ s t, supermodDefect g s t = 0) : ∀ k, SupermodularOrder k g := by
    intro k
    induction' k with k ih generalizing g;
    · exact fun s t => hg s t ▸ le_rfl;
    · refine' ⟨ ih g hg, fun a => _ ⟩;
      convert ih ( elemDiff g a ) _ using 1;
      intro s t; have := hg ( s ∪ { a } ) ( t ∪ { a } ) ; have := hg ( s ∪ { a } ) ( t ∩ { a } ) ; have := hg ( s ∩ { a } ) ( t ∪ { a } ) ; have := hg ( s ∩ { a } ) ( t ∩ { a } ) ; simp_all +decide [ elemDiff, supermodDefect ] ; ring;
      grind;
  exact h_modular _ ( fun s t => card_supermod_defect_eq_zero s t ) k

/-- **Affine rank-defect function** `c * |s| + d` has all orders for `c ≥ 0`. -/
theorem supermodularOrder_affine (k : ℕ) (c d : ℝ) (hc : 0 ≤ c) :
    SupermodularOrder k (fun s : Finset α => c * (s.card : ℝ) + d) := by
  have h1 : SupermodularOrder k (fun s : Finset α => c * (s.card : ℝ)) :=
    SupermodularOrder.nonneg_smul hc (supermodularOrder_card k)
  have h2 : SupermodularOrder k (fun _ : Finset α => d) := supermodularOrder_const d
  have h3 := SupermodularOrder.add h1 h2
  convert h3 using 1

/-! ## Order 0/1 Characterizations -/

/-- Order 0 is equivalent to supermodularity. -/
theorem supermodularOrder_zero_iff (g : Finset α → ℝ) :
    SupermodularOrder 0 g ↔ ∀ s t : Finset α, 0 ≤ supermodDefect g s t :=
  Iff.rfl

/-- Order 1 unfolds explicitly. -/
theorem supermodularOrder_one_iff (g : Finset α → ℝ) :
    SupermodularOrder 1 g ↔
    (∀ s t : Finset α, 0 ≤ supermodDefect g s t) ∧
    (∀ a : α, ∀ s t : Finset α, 0 ≤ supermodDefect (elemDiff g a) s t) := by
  constructor
  · intro ⟨h0, h1⟩; exact ⟨h0, fun a => h1 a⟩
  · intro ⟨h0, h1⟩; exact ⟨h0, fun a => h1 a⟩

end