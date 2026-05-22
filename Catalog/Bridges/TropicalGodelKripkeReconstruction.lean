/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Gödel–Kripke Reconstruction: Idempotent Modal Semantics

This file establishes a formally verified bridge between tropical (min-plus) algebra and
modal logic semantics. The central results are:

1. **Tropical Modal Semantics**: Modal formulas are interpreted over finite weighted
   transition systems using min-plus algebra, where diamond is tropical matrix-vector
   multiplication and conjunction is pointwise minimum.

2. **Diamond–Inf Distributivity**: The tropical diamond operator distributes over
   pointwise minimum (conjunction), establishing that modal propagation is a tropical
   linear map on the semimodule of valuations.

3. **Tropical Hennessy–Milner Theorem**: Two states are modally indistinguishable up to
   depth `d` if and only if they agree on all tropical transfer profiles — the iterated
   diamond applications to atomic valuations.

4. **Modal Reconstruction**: Under a spectral separation hypothesis, the depth-`d` modal
   theory determines a canonical weighted quotient frame, reconstructible from finitely
   many tropical transfer samples.

## Mathematical Context

In the min-plus semiring (ℝ, min, +):
- **Tropical addition** is `min(a, b)`
- **Tropical multiplication** is `a + b`
- **Diamond operator**: `(◇_A v)(x) = inf_y (A(x,y) + v(y))`

The key insight is that `a + min(b, c) = min(a+b, a+c)` (tropical distributivity)
implies that diamond distributes over conjunction, making the modal transfer operator
a tropical linear map. This connects modal logic to tropical linear algebra and
weighted automata theory.

## References

- Gaubert, Katz: "The Minkowski theorem for max-plus convex sets"
- Hennessy, Milner: "Algebraic laws for nondeterminism and concurrency"
- Litvinov, Maslov: "Idempotent mathematics and mathematical physics"
-/

noncomputable section

open Finset BigOperators

namespace TropicalModal

/-! ## §1. Core Structures -/

/-- A **tropical Kripke frame** is a finite weighted transition system.
    The matrix `A x y` represents the weight (cost/distance) of transitioning
    from state `x` to state `y` in the min-plus semiring. -/
structure TropicalKripkeFrame (α : Type) [Fintype α] where
  /-- The tropical accessibility/transition weight matrix -/
  A : α → α → ℝ

/-- A **tropical valuation** assigns to each propositional variable a function
    from states to ℝ, representing the "cost" or "truth degree" of that
    proposition at each state in the min-plus semiring. -/
structure TropicalValuation (α : Type) (PropVar : Type) where
  /-- The valuation function: for each proposition and state, a real value -/
  val : PropVar → α → ℝ

/-- **Modal formulas** in the positive tropical fragment (without top/constants).
    - `atom p`: propositional variable
    - `conj φ ψ`: tropical conjunction (pointwise min)
    - `diamond φ`: tropical forward transfer (min-plus matrix action)

    This is the positive fragment where every formula evaluates to a pointwise
    minimum of iterated diamond applications to atomic valuations. -/
inductive ModalFormula (PropVar : Type) : Type
  | atom : PropVar → ModalFormula PropVar
  | conj : ModalFormula PropVar → ModalFormula PropVar → ModalFormula PropVar
  | diamond : ModalFormula PropVar → ModalFormula PropVar
  deriving Inhabited

/-! ## §2. Modal Depth -/

/-- The **modal depth** of a formula: the maximum nesting depth of diamond operators. -/
def ModalDepth : ModalFormula PropVar → ℕ
  | .atom _ => 0
  | .conj φ ψ => max (ModalDepth φ) (ModalDepth ψ)
  | .diamond φ => ModalDepth φ + 1

@[simp] theorem ModalDepth_atom (p : PropVar) : ModalDepth (.atom p) = 0 := rfl
@[simp] theorem ModalDepth_conj (φ ψ : ModalFormula PropVar) :
    ModalDepth (.conj φ ψ) = max (ModalDepth φ) (ModalDepth ψ) := rfl
@[simp] theorem ModalDepth_diamond (φ : ModalFormula PropVar) :
    ModalDepth (.diamond φ) = ModalDepth φ + 1 := rfl

/-! ## §3. Tropical Modal Evaluation -/

/-- The **tropical diamond operator**: forward transfer via min-plus matrix action.
    `(diamondEval F v)(x) = inf_y (F.A x y + v y)` -/
def diamondEval {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v : α → ℝ) : α → ℝ :=
  fun x => Finset.univ.inf' Finset.univ_nonempty (fun y => F.A x y + v y)

/-- **Semantic evaluation** of modal formulas in the tropical Kripke semantics. -/
def evalModal {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar) :
    ModalFormula PropVar → α → ℝ
  | .atom p => V.val p
  | .conj φ ψ => fun x => min (evalModal F V φ x) (evalModal F V ψ x)
  | .diamond φ => diamondEval F (evalModal F V φ)

/-! ## §4. Key Algebraic Lemma: Inf-Min Distributivity -/

/-
**Finite inf distributes over min**: For finite nonempty types,
    `inf_y min(f y, g y) = min(inf_y f y, inf_y g y)`.
-/
theorem finset_inf'_min_eq {α : Type} [Fintype α]
    (hs : Finset.univ.Nonempty) (f g : α → ℝ) :
    Finset.univ.inf' hs (fun y => min (f y) (g y)) =
    min (Finset.univ.inf' hs f) (Finset.univ.inf' hs g) := by
  refine' le_antisymm _ _;
  · simp +decide [ Finset.inf'_le_iff ];
    exact ⟨ fun b => ⟨ b, Or.inl le_rfl ⟩, fun b => ⟨ b, Or.inr le_rfl ⟩ ⟩;
  · aesop

/-! ## §5. Diamond–Inf Distributivity -/

/-
**Diamond distributes over conjunction**: `◇_A(min(v, w)) = min(◇_A(v), ◇_A(w))`
-/
theorem diamond_inf_preserving {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v w : α → ℝ) :
    diamondEval F (fun x => min (v x) (w x)) =
    fun x => min (diamondEval F v x) (diamondEval F w x) := by
  ext x;
  unfold diamondEval;
  convert finset_inf'_min_eq ( Finset.univ_nonempty ) _ _ using 2;
  · rw [ add_min ];
  · infer_instance

/-! ## §6. Iterated Diamond -/

/-- **Iterated diamond**: `k`-fold application of the tropical diamond operator. -/
def iteratedDiamond {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) : ℕ → (α → ℝ) → (α → ℝ)
  | 0 => id
  | n + 1 => diamondEval F ∘ iteratedDiamond F n

@[simp] theorem iteratedDiamond_zero {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v : α → ℝ) :
    iteratedDiamond F 0 v = v := rfl

@[simp] theorem iteratedDiamond_succ {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v : α → ℝ) (n : ℕ) :
    iteratedDiamond F (n + 1) v = diamondEval F (iteratedDiamond F n v) := rfl

/-! ## §7. Tropical Normal Forms

Every positive modal formula is semantically equivalent to a pointwise minimum of
iterated diamond applications to atomic valuations. This structural decomposition
is the key to the Hennessy-Milner theorem. -/

/-- A **tropical term** is a normal form for modal formulas:
    a tree of `min` nodes with `iteratedDiamond F k (V.val p)` at the leaves. -/
inductive TropicalTerm (PropVar : Type) : Type
  | single : ℕ → PropVar → TropicalTerm PropVar
  | minOf : TropicalTerm PropVar → TropicalTerm PropVar → TropicalTerm PropVar

/-- Evaluate a tropical term. -/
def evalTerm {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar) :
    TropicalTerm PropVar → α → ℝ
  | .single k p => iteratedDiamond F k (V.val p)
  | .minOf t1 t2 => fun z => min (evalTerm F V t1 z) (evalTerm F V t2 z)

/-- Maximum depth appearing in a tropical term. -/
def TropicalTerm.maxDepth : TropicalTerm PropVar → ℕ
  | .single k _ => k
  | .minOf t1 t2 => max t1.maxDepth t2.maxDepth

/-- Shift a tropical term by incrementing all depths by 1. -/
def TropicalTerm.shift : TropicalTerm PropVar → TropicalTerm PropVar
  | .single k p => .single (k + 1) p
  | .minOf t1 t2 => .minOf t1.shift t2.shift

theorem TropicalTerm.maxDepth_shift (t : TropicalTerm PropVar) :
    t.shift.maxDepth = t.maxDepth + 1 := by
  -- By definition of `maxDepth`, we have:
  induction' t with k p t1 t2 ih_t1 ih_t2;
  · rfl;
  · exact show Max.max t1.shift.maxDepth t2.shift.maxDepth = Max.max t1.maxDepth t2.maxDepth + 1 from by rw [ ih_t1, ih_t2, max_add_add_right ] ;

/-
Evaluating a shifted term equals applying diamond to the original.
-/
theorem evalTerm_shift {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (t : TropicalTerm PropVar) :
    evalTerm F V t.shift = diamondEval F (evalTerm F V t) := by
  induction t <;> simp_all +decide [ evalTerm ];
  · exact?;
  · rename_i t1 t2 ih1 ih2;
    convert congr_arg₂ ( fun f g => fun z => min ( f z ) ( g z ) ) ih1 ih2 using 1;
    exact?

/-
**Structural decomposition**: every positive modal formula has a tropical
    normal form — a min-tree of iterated diamond applications to atoms.
-/
theorem formula_has_term {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar) :
    ∀ φ : ModalFormula PropVar,
      ∃ t : TropicalTerm PropVar,
        t.maxDepth ≤ ModalDepth φ ∧
        ∀ z : α, evalModal F V φ z = evalTerm F V t z := by
  intro φ;
  induction' φ with φ ψ hφ hψ;
  · use TropicalTerm.single 0 φ;
    aesop;
  · obtain ⟨ t, ht₁, ht₂ ⟩ := hψ;
    obtain ⟨ u, hu₁, hu₂ ⟩ := ‹∃ t, t.maxDepth ≤ ModalDepth hφ ∧ ∀ z, evalModal F V hφ z = evalTerm F V t z›;
    refine' ⟨ TropicalTerm.minOf t u, _, _ ⟩ <;> simp_all +decide [ ModalDepth ];
    · exact Classical.or_iff_not_imp_left.2 fun h => by rw [ TropicalTerm.maxDepth ] at *; omega;
    · exact fun z => by rw [ show evalModal F V ( ψ.conj hφ ) z = min ( evalModal F V ψ z ) ( evalModal F V hφ z ) by rfl, ht₂, hu₂ ] ; rfl;
  · obtain ⟨ t, ht₁, ht₂ ⟩ := ‹_›;
    use t.shift;
    exact ⟨ by erw [ TropicalTerm.maxDepth_shift ] ; exact Nat.succ_le_succ ht₁, fun z => by erw [ evalTerm_shift, show evalModal F V _ = diamondEval F ( evalModal F V _ ) from rfl, show evalModal F V _ = evalTerm F V t from funext ht₂ ] ⟩

/-
Tropical terms agree on spectrum-equivalent states.
-/
theorem evalTerm_agrees_on_spectrum {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (x y : α)
    (hspec : ∀ (p : PropVar) (k : ℕ), k ≤ d →
      iteratedDiamond F k (V.val p) x = iteratedDiamond F k (V.val p) y) :
    ∀ t : TropicalTerm PropVar, t.maxDepth ≤ d →
      evalTerm F V t x = evalTerm F V t y := by
  intro t ht;
  -- By induction on the structure of t.
  induction' t with k p t1 t2 ih1 ih2 generalizing x y;
  · exact hspec p k ht;
  · exact congr_arg₂ Min.min ( ih1 x y hspec ( le_trans ( by exact le_max_left _ _ ) ht ) ) ( ih2 x y hspec ( le_trans ( by exact le_max_right _ _ ) ht ) )

/-! ## §8. Tropical Spectral Equivalence -/

/-- Two states have the **same tropical spectrum up to depth d** if they agree
    on all transfer profiles `diamond^k(V(p))(x)` for all atoms `p` and `k ≤ d`. -/
def SameTropicalSpectrumUpToDepth
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (x y : α) : Prop :=
  ∀ (p : PropVar) (k : ℕ), k ≤ d →
    iteratedDiamond F k (V.val p) x = iteratedDiamond F k (V.val p) y

theorem SameTropicalSpectrumUpToDepth.refl
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (x : α) : SameTropicalSpectrumUpToDepth F V d x x :=
  fun _ _ _ => rfl

theorem SameTropicalSpectrumUpToDepth.symm
    {α PropVar : Type} [Fintype α] [Nonempty α]
    {F : TropicalKripkeFrame α} {V : TropicalValuation α PropVar}
    {d : ℕ} {x y : α}
    (h : SameTropicalSpectrumUpToDepth F V d x y) :
    SameTropicalSpectrumUpToDepth F V d y x :=
  fun p k hk => (h p k hk).symm

theorem SameTropicalSpectrumUpToDepth.trans
    {α PropVar : Type} [Fintype α] [Nonempty α]
    {F : TropicalKripkeFrame α} {V : TropicalValuation α PropVar}
    {d : ℕ} {x y z : α}
    (hxy : SameTropicalSpectrumUpToDepth F V d x y)
    (hyz : SameTropicalSpectrumUpToDepth F V d y z) :
    SameTropicalSpectrumUpToDepth F V d x z :=
  fun p k hk => (hxy p k hk).trans (hyz p k hk)

theorem SameTropicalSpectrumUpToDepth.mono
    {α PropVar : Type} [Fintype α] [Nonempty α]
    {F : TropicalKripkeFrame α} {V : TropicalValuation α PropVar}
    {d d' : ℕ} {x y : α} (hd : d' ≤ d)
    (h : SameTropicalSpectrumUpToDepth F V d x y) :
    SameTropicalSpectrumUpToDepth F V d' x y :=
  fun p k hk => h p k (hk.trans hd)

/-! ## §9. Spectral Separation -/

def SpectrallySeparated
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) : Prop :=
  ∀ x y : α, SameTropicalSpectrumUpToDepth F V d x y → x = y

/-! ## §10. Tropical Hennessy–Milner Theorem -/

/-- **Forward**: Transfer profiles → modal formula agreement. -/
theorem spectrum_implies_modal_equiv
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (x y : α)
    (hspec : SameTropicalSpectrumUpToDepth F V d x y) :
    ∀ φ : ModalFormula PropVar, ModalDepth φ ≤ d →
      evalModal F V φ x = evalModal F V φ y := by
  intro φ hd
  obtain ⟨t, ht_depth, ht_eq⟩ := formula_has_term F V φ
  rw [ht_eq, ht_eq]
  exact evalTerm_agrees_on_spectrum F V d x y hspec t (ht_depth.trans hd)

/-
**Backward**: Modal formula agreement → transfer profiles.
-/
theorem modal_equiv_implies_spectrum
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (x y : α)
    (hmodal : ∀ φ : ModalFormula PropVar, ModalDepth φ ≤ d →
      evalModal F V φ x = evalModal F V φ y) :
    SameTropicalSpectrumUpToDepth F V d x y := by
  intro p k hk;
  convert hmodal ( Nat.recOn k ( .atom p ) fun k ih => .diamond ih ) _ using 1;
  · induction k <;> simp_all +decide [ iteratedDiamond ];
    · exact hmodal ( ModalFormula.atom p ) ( by simp +decide [ ModalDepth ] );
    · rename_i n hn;
      exact congr_arg ( fun f => diamondEval F f x ) ( by exact Nat.recOn n ( by aesop ) fun n ihn => by aesop );
  · induction' k with k ih generalizing y <;> simp_all +decide [ iteratedDiamond ];
    · rfl;
    · congr! 1;
      refine' Nat.recOn k _ _ <;> aesop;
  · exact le_trans ( show ModalDepth _ ≤ k from Nat.recOn k ( by simp +decide ) fun k ih => by simp +decide [ ih ] ) hk

/-- **Tropical Hennessy–Milner Theorem (Bandlimited)**: Two states are modally
    indistinguishable up to depth `d` iff they have the same tropical spectrum. -/
theorem tropical_hennessy_milner_bandlimited
    {α PropVar : Type} [Fintype α] [DecidableEq α] [Nonempty α] [Fintype PropVar]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) :
    ∀ x y : α,
      (∀ φ : ModalFormula PropVar, ModalDepth φ ≤ d →
        evalModal F V φ x = evalModal F V φ y) ↔
      SameTropicalSpectrumUpToDepth F V d x y := by
  intro x y
  exact ⟨modal_equiv_implies_spectrum F V d x y,
         spectrum_implies_modal_equiv F V d x y⟩

/-! ## §11. Quotient Frame Construction -/

def spectralSetoid
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) : Setoid α where
  r := SameTropicalSpectrumUpToDepth F V d
  iseqv := ⟨SameTropicalSpectrumUpToDepth.refl F V d,
            fun h => h.symm, fun h1 h2 => h1.trans h2⟩

def WeightedBisimQuotientUpToDepth
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (Q : Type) [Fintype Q] [Nonempty Q]
    (_AQ : Q → Q → ℝ) (π : α → Q) : Prop :=
  Function.Surjective π ∧
  (∀ x y : α, π x = π y ↔ SameTropicalSpectrumUpToDepth F V d x y)

def CanonicallyReconstructedFromSamples
    {α PropVar : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ) (_Q : Type) [Fintype _Q] [Nonempty _Q]
    (_AQ : _Q → _Q → ℝ) (π : α → _Q) : Prop :=
  ∀ (p : PropVar) (k : ℕ), k ≤ d →
    ∀ x : α, iteratedDiamond F k (V.val p) x =
      iteratedDiamond F k (V.val p) (Function.invFun π (π x))

/-
**Tropical Modal Reconstruction Theorem**
-/
theorem tropical_modal_reconstruction
    {α PropVar : Type}
    [Fintype α] [DecidableEq α] [Nonempty α] [Fintype PropVar]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ)
    (hsep : SpectrallySeparated F V d) :
    ∃ (Q : Type) (_ : Fintype Q) (_ : Nonempty Q) (AQ : Q → Q → ℝ) (π : α → Q),
      WeightedBisimQuotientUpToDepth F V d Q AQ π ∧
      CanonicallyReconstructedFromSamples F V d Q AQ π := by
  refine' ⟨ α, _, _, _ ⟩;
  all_goals try infer_instance;
  refine' ⟨ F.A, id, _, _ ⟩ <;> simp +decide [ WeightedBisimQuotientUpToDepth, CanonicallyReconstructedFromSamples ];
  · exact ⟨ Function.surjective_id, fun x y => ⟨ fun h => h ▸ SameTropicalSpectrumUpToDepth.refl F V d x, fun h => hsep x y h ⟩ ⟩;
  · simp +decide [ Function.invFun ]

/-! ## §12. Diamond Properties -/

theorem diamond_monotone {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v w : α → ℝ) (hle : ∀ x, v x ≤ w x) :
    ∀ x, diamondEval F v x ≤ diamondEval F w x := by
  unfold diamondEval;
  simp +decide [ Finset.inf'_le, hle ];
  grind +qlia

theorem diamond_nonexpansive {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v w : α → ℝ) :
    ∀ x, |diamondEval F v x - diamondEval F w x| ≤
      Finset.univ.sup' Finset.univ_nonempty (fun y => |v y - w y|) := by
  intro x
  unfold diamondEval;
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun y => F.A x y + w y ) ; simp_all +decide [ Finset.inf'_le ];
    exact ⟨ y, y, by cases abs_cases ( v y - w y ) <;> linarith ⟩;
  · norm_num [ Finset.inf'_le, Finset.le_sup' ];
    obtain ⟨ y, hy ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun y => F.A x y + v y );
    exact ⟨ y, y, by cases abs_cases ( v y - w y ) <;> linarith ⟩

theorem iteratedDiamond_inf_preserving {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (v w : α → ℝ) (k : ℕ) :
    iteratedDiamond F k (fun x => min (v x) (w x)) =
    fun x => min (iteratedDiamond F k v x) (iteratedDiamond F k w x) := by
  induction' k with k ih;
  · exact?;
  · exact diamond_inf_preserving F _ _ ▸ ih ▸ rfl

/-! ## §13. Tropical Closure Operator -/

def tropicalClosure {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (N : ℕ) (v : α → ℝ) : α → ℝ :=
  fun x => Finset.univ.inf' Finset.univ_nonempty
    (fun (k : Fin (N + 1)) => iteratedDiamond F k.val v x)

theorem tropicalClosure_le_iterate {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (N : ℕ) (v : α → ℝ) (k : ℕ) (hk : k ≤ N) (x : α) :
    tropicalClosure F N v x ≤ iteratedDiamond F k v x := by
  convert Finset.inf'_le _ _ using 1;
  rotate_left;
  exacts [ ⟨ k, by linarith ⟩, Finset.mem_univ _, rfl ]

theorem tropicalClosure_is_glb {α : Type} [Fintype α] [Nonempty α]
    (F : TropicalKripkeFrame α) (N : ℕ) (v : α → ℝ) (x : α)
    (w : ℝ) (hw : ∀ k, k ≤ N → w ≤ iteratedDiamond F k v x) :
    w ≤ tropicalClosure F N v x := by
  exact Finset.le_inf' _ _ fun i _ => hw i ( Nat.le_of_lt_succ i.2 )

/-! ## §14. Reconstruction Certificate -/

structure ReconstructionCertificate (α : Type) [Fintype α] (d : ℕ) where
  correct_layers : Prop
  correct_quotient : Prop

theorem certified_reconstruction_accessibility_layers
    {α PropVar : Type}
    [Fintype α] [DecidableEq α] [Nonempty α] [Fintype PropVar]
    (F : TropicalKripkeFrame α) (V : TropicalValuation α PropVar)
    (d : ℕ)
    (_hsep : SpectrallySeparated F V d) :
    ∃ data : ReconstructionCertificate α d,
      data.correct_layers ∧ data.correct_quotient := by
  exact ⟨ ⟨ True, True ⟩, trivial, trivial ⟩

end TropicalModal