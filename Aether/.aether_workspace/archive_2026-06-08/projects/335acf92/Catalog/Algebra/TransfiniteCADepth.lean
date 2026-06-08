/-
Copyright (c) 2026 Harmonic. All rights reserved.

# Transfinite Cellular Automata Depth Theory

We formalize one-dimensional cellular automata on infinite configurations `ℤ → Bool`,
define iterated evolution, omega-limits, convergence depth, and the **Convergence Spectrum** —
a novel classification of CA rules by the ordinal depth of their convergence behavior.

## Main Results

1. **OR Spreading Theorem** (`orRule_expansion`): After n steps of the OR rule,
   any initially true cell spreads to fill all positions within distance n.
2. **NOT Oscillation Theorem** (`notRule_no_fixedPoint`): The NOT rule admits no
   fixed points — it has infinite convergence depth.
3. **Monotone Dominance Theorem** (`monotone_step_preserves_order`): Monotone CA rules
   preserve the pointwise Boolean ordering through single and iterated evolution.
4. **Depth Spectrum Theorem** (`depth_spectrum_nontrivial`): The convergence spectrum
   is non-degenerate — rules of depth 0, 1, and ∞ all exist.

## Novel Definition

* `ConvergenceClass` — Classification of CA rules by convergence depth
-/
import Mathlib

namespace TransfiniteCA

/-! ## Core Definitions -/

/-- A cellular automaton configuration: assignment of Bool to each integer position. -/
abbrev Config := ℤ → Bool

/-- A local CA rule: maps (left, center, right) neighborhood to new center value. -/
abbrev CARule := Bool → Bool → Bool → Bool

/-- Global synchronous update: apply the local rule at every position simultaneously. -/
def caStep (rule : CARule) (cfg : Config) : Config := fun z =>
  rule (cfg (z - 1)) (cfg z) (cfg (z + 1))

/-- n-fold iteration of the global update. -/
def caIter (rule : CARule) : ℕ → Config → Config
  | 0 => id
  | n + 1 => caStep rule ∘ caIter rule n

@[simp] theorem caIter_zero (rule : CARule) (cfg : Config) :
    caIter rule 0 cfg = cfg := rfl

@[simp] theorem caIter_succ (rule : CARule) (n : ℕ) (cfg : Config) :
    caIter rule (n + 1) cfg = caStep rule (caIter rule n cfg) := rfl

/-- A configuration is a fixed point of the CA rule. -/
def IsFixedPoint (rule : CARule) (cfg : Config) : Prop :=
  caStep rule cfg = cfg

/-- Cell z eventually stabilizes under iteration from cfg. -/
def EventuallyConstantAt (rule : CARule) (cfg : Config) (z : ℤ) : Prop :=
  ∃ N : ℕ, ∀ n ≥ N, caIter rule n cfg z = caIter rule N cfg z

/-- All cells eventually stabilize (omega-convergence). -/
def OmegaConverges (rule : CARule) (cfg : Config) : Prop :=
  ∀ z : ℤ, EventuallyConstantAt rule cfg z

/-- A CA rule is monotone: preserving the pointwise ≤ order on Bool (false ≤ true).
    We encode this as: if each input implies the corresponding input, then
    the output implies the output. -/
def IsMonotoneRule (rule : CARule) : Prop :=
  ∀ l₁ c₁ r₁ l₂ c₂ r₂ : Bool,
    (l₁ → l₂) → (c₁ → c₂) → (r₁ → r₂) →
    (rule l₁ c₁ r₁ → rule l₂ c₂ r₂)

/-- Pointwise ordering on configurations. -/
def ConfigLE (cfg₁ cfg₂ : Config) : Prop :=
  ∀ z : ℤ, cfg₁ z → cfg₂ z

notation:50 cfg₁ " ≤c " cfg₂ => ConfigLE cfg₁ cfg₂

/-! ## Specific Rules -/

/-- The OR rule: output is true if any neighbor is true. -/
def orRule : CARule := fun l c r => l || c || r

/-- The NOT rule: each cell flips its center value. -/
def notRule : CARule := fun _l c _r => !c

/-- The AND rule: output is true only if all neighbors are true. -/
def andRule : CARule := fun l c r => l && c && r

/-- The identity rule: each cell keeps its value. -/
def idRule : CARule := fun _l c _r => c

/-- The all-false configuration. -/
def allFalse : Config := fun _ => false

/-- The all-true configuration. -/
def allTrue : Config := fun _ => true

/-! ## Convergence Spectrum -/

/-- The Convergence Spectrum classifies CA rules by their convergence behavior. -/
inductive ConvergenceClass where
  | Depth0 : ConvergenceClass
  | Depth1 : ConvergenceClass
  | DepthInfinite : ConvergenceClass
  | DepthFinite (k : ℕ) : ConvergenceClass

/-- A rule has depth 0 if every configuration is already a fixed point. -/
def HasDepth0 (rule : CARule) : Prop :=
  ∀ cfg : Config, IsFixedPoint rule cfg

/-- A rule has convergence depth 1 if every configuration omega-converges
    and not every configuration is already a fixed point. -/
def HasDepth1 (rule : CARule) : Prop :=
  (∀ cfg : Config, OmegaConverges rule cfg) ∧ ¬ HasDepth0 rule

/-- A rule has infinite convergence depth if it admits no fixed points. -/
def HasInfiniteDepth (rule : CARule) : Prop :=
  ∀ cfg : Config, ¬ IsFixedPoint rule cfg

/-! ## Section 1: NOT Rule — Infinite Depth -/

/-
The NOT rule is an involution: applying it twice returns the original config.
-/
theorem notRule_involution (cfg : Config) :
    caStep notRule (caStep notRule cfg) = cfg := by
  exact funext fun x => by unfold caStep notRule; simp +decide ;

/-
The NOT rule has no fixed points: ¬b ≠ b for any Boolean b.
-/
theorem notRule_no_fixedPoint (cfg : Config) : ¬ IsFixedPoint notRule cfg := by
  unfold IsFixedPoint caStep notRule; intro h; have := congr_fun h 0; aesop;

/-- The NOT rule has infinite convergence depth. -/
theorem notRule_infinite_depth : HasInfiniteDepth notRule :=
  notRule_no_fixedPoint

/-
The NOT rule has exact period 2: iterating twice is the identity.
-/
theorem notRule_period_two (cfg : Config) (n : ℕ) :
    caIter notRule (2 * n) cfg = cfg := by
  induction n <;> simp_all +arith +decide [ Nat.mul_succ, caIter_succ, notRule_involution ]

/-
The NOT rule after odd steps negates the entire configuration.
-/
theorem notRule_odd_negates (cfg : Config) (n : ℕ) :
    caIter notRule (2 * n + 1) cfg = caStep notRule cfg := by
  convert congr_arg ( fun x => caStep notRule x ) ( notRule_period_two cfg n ) using 1

/-
The NOT rule never stabilizes at any cell.
-/
theorem notRule_never_stabilizes (cfg : Config) (z : ℤ) :
    ¬ EventuallyConstantAt notRule cfg z := by
  unfold EventuallyConstantAt;
  simp;
  intro n;
  refine' ⟨ n + 1, _, _ ⟩ <;> simp +decide [ caIter ];
  unfold caStep;
  unfold notRule; aesop;

/-! ## Section 2: Identity Rule — Depth 0 -/

/-
The identity rule is depth 0: every configuration is a fixed point.
-/
theorem idRule_depth0 : HasDepth0 idRule := by
  exact fun cfg => funext fun z => by unfold idRule; rfl;

/-! ## Section 3: OR Rule — Spreading and Depth 1 -/

/-
The OR rule is monotone.
-/
theorem orRule_monotone : IsMonotoneRule orRule := by
  intro l₁ c₁ r₁ l₂ c₂ r₂ h₁ h₂ h₃; unfold orRule; aesop;

/-
The all-false configuration is a fixed point of the OR rule.
-/
theorem orRule_allFalse_fixed : IsFixedPoint orRule allFalse := by
  exact funext fun x => by unfold caStep orRule allFalse; simp +decide ;

/-
The all-true configuration is a fixed point of the OR rule.
-/
theorem orRule_allTrue_fixed : IsFixedPoint orRule allTrue := by
  exact funext fun x => by unfold orRule allTrue; aesop;

/-
**OR Expansion Lemma**: If cfg z₀ = true, then after n steps of the OR rule,
    every position within distance n of z₀ is true.
    This is the core spreading result.
-/
theorem orRule_expansion (cfg : Config) (z₀ : ℤ) (h : cfg z₀ = true)
    (n : ℕ) (z : ℤ) (hz : |z - z₀| ≤ n) :
    caIter orRule n cfg z = true := by
  induction' n with n ih generalizing z <;> simp_all +decide [ caIter ];
  · rwa [ sub_eq_zero.mp hz ];
  · unfold caStep; simp_all +decide [ orRule ] ;
    grind

/-
OR convergence: every cell eventually stabilizes under the OR rule.
-/
theorem orRule_eventuallyConstant (cfg : Config) (z : ℤ) :
    EventuallyConstantAt orRule cfg z := by
  by_contra h_not_converge;
  -- By definition of `EventuallyConstantAt`, there � exists� some $N$ such that for all $n \geq N$, `caIter orRule n cfg z` is constant.
  obtain ⟨N, hN⟩ : ∃ N, ∀ n ≥ N, caIter orRule n cfg z = true := by
    obtain ⟨z₀, hz₀⟩ : ∃ z₀, cfg z₀ = true := by
      contrapose! h_not_converge;
      use 0; simp_all +decide ;
      intro n; induction' n with n ih generalizing z <;> simp_all +decide [ caIter ] ;
      unfold caStep; aesop;
    exact ⟨ Int.natAbs ( z - z₀ ), fun n hn => orRule_expansion cfg z₀ hz₀ n z ( by cases abs_cases ( z - z₀ ) <;> linarith ) ⟩;
  exact h_not_converge ⟨ N, fun n hn => by rw [ hN n hn, hN N le_rfl ] ⟩

/-- The OR rule achieves omega-convergence for every initial configuration. -/
theorem orRule_omega_converges (cfg : Config) : OmegaConverges orRule cfg :=
  orRule_eventuallyConstant cfg

/-
The OR rule is not depth 0: the single-true config at 0 is not a fixed point.
-/
theorem orRule_not_depth0 : ¬ HasDepth0 orRule := by
  intro h;
  have := h ( fun z => z = 0 );
  exact absurd ( congr_fun this 1 ) ( by decide )

/-- The OR rule has convergence depth exactly 1. -/
theorem orRule_depth1 : HasDepth1 orRule :=
  ⟨orRule_omega_converges, orRule_not_depth0⟩

/-! ## Section 4: Monotone Dominance Theorem -/

/-
**Monotone Dominance Theorem**: Monotone rules preserve the pointwise order
    on configurations through a single step.
-/
theorem monotone_step_preserves_order (rule : CARule) (hm : IsMonotoneRule rule)
    (cfg₁ cfg₂ : Config) (hle : cfg₁ ≤c cfg₂) :
    caStep rule cfg₁ ≤c caStep rule cfg₂ := by
  exact fun z => by simpa using hm _ _ _ _ _ _ ( hle _ ) ( hle _ ) ( hle _ ) ;

/-
Monotone dominance extends to arbitrary iterations by induction.
-/
theorem monotone_iter_preserves_order (rule : CARule) (hm : IsMonotoneRule rule)
    (cfg₁ cfg₂ : Config) (hle : cfg₁ ≤c cfg₂) (n : ℕ) :
    caIter rule n cfg₁ ≤c caIter rule n cfg₂ := by
  induction' n with n ih;
  · exact hle;
  · convert monotone_step_preserves_order rule hm _ _ ih using 1

/-
The AND rule is monotone.
-/
theorem andRule_monotone : IsMonotoneRule andRule := by
  intro l₁ c₁ r₁ l₂ c₂ r₂ hl hc hr; by_cases h₁ : l₁ <;> by_cases h₂ : c₁ <;> by_cases h₃ : r₁ <;> simp_all +decide ;

/-
For monotone rules with rule(F,F,F)=F, the all-false config is a fixed point.
-/
theorem monotone_allFalse_fixed (rule : CARule) (_hm : IsMonotoneRule rule)
    (hf : rule false false false = false) :
    IsFixedPoint rule allFalse := by
  unfold IsFixedPoint allFalse; aesop;

/-
For monotone rules with rule(T,T,T)=T, the all-true config is a fixed point.
-/
theorem monotone_allTrue_fixed (rule : CARule) (_hm : IsMonotoneRule rule)
    (ht : rule true true true = true) :
    IsFixedPoint rule allTrue := by
  exact funext fun z => by unfold caStep allTrue; aesop;

/-! ## Section 5: Depth Spectrum Theorem -/

/-- **Depth Spectrum Theorem**: The convergence spectrum is non-degenerate —
    there exist rules at depth 0, depth 1, and infinite depth. -/
theorem depth_spectrum_nontrivial :
    (∃ r : CARule, HasDepth0 r) ∧
    (∃ r : CARule, HasDepth1 r) ∧
    (∃ r : CARule, HasInfiniteDepth r) :=
  ⟨⟨idRule, idRule_depth0⟩, ⟨orRule, orRule_depth1⟩, ⟨notRule, notRule_infinite_depth⟩⟩

end TransfiniteCA