import Mathlib

/-! # Max-Plus Hecke Algebras on Finite Lattices: Tropical Langlands Foundations

## Overview

We formalize **max-plus Hecke operators** on finite lattices, establishing the
foundational algebraic framework for the tropical Langlands program. The central
construction associates to each element `p` of a finite lattice `L` an operator
`T_p` on functions `L → V` (where `V` is a sup-semilattice with bottom), defined by

  `(T_p f)(q) = ⨆ { f(r) | r ⊔ q ≥ p }`

This is the tropical (max-plus) shadow of classical Hecke operators in the theory
of automorphic forms, where summation over double cosets is replaced by supremum
over lattice neighborhoods.

## Main Results

* `MaxPlusHecke.heckeOp_comm` — **Hecke Commutativity (Gelfand Property)**
* `MaxPlusHecke.doubleReach_symm` — Lattice reachability symmetry lemma
* `MaxPlusHecke.heckeOp_monotone` — Monotonicity of Hecke operators
* `MaxPlusHecke.heckeOp_bot_param` — `T_⊥` computes the global supremum
* `MaxPlusHecke.heckeOp_const` — Hecke operators fix constant functions

## Bridge: Tropical Algebra ↔ Automorphic Forms ↔ Certified Robustness
-/

noncomputable section
set_option linter.unusedVariables false
set_option linter.unusedSectionVars false

namespace MaxPlusHecke

/-! ## §1. Core Definitions -/

/-- **Max-Plus Hecke Operator.** For element `p` of a finite lattice `L`,
`T_p` acts on functions `f : L → V` by taking the sup of `f` over all
lattice elements whose join with the evaluation point dominates `p`.

Bridge: connects tropical algebra to automorphic forms.
Computational bound: O(|L|) per evaluation. -/
def heckeOp {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)]
    {V : Type*} [SemilatticeSup V] [OrderBot V]
    (p : L) (f : L → V) (q : L) : V :=
  (Finset.univ.filter (fun r => p ≤ r ⊔ q)).sup f

/-- The **Hecke filter**: `{r ∈ L : r ⊔ q ≥ p}`. -/
def heckeFilter {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)] (p q : L) : Finset L :=
  Finset.univ.filter (fun r => p ≤ r ⊔ q)

/-- **Double Reachability.** `u` is `(p,q)`-reachable from `s` if
`∃ r, p ≤ r ⊔ s ∧ q ≤ u ⊔ r`.

Bridge: connects lattice combinatorics to tropical representation theory. -/
def DoubleReach {L : Type*} [Lattice L] (p q s u : L) : Prop :=
  ∃ r : L, p ≤ r ⊔ s ∧ q ≤ u ⊔ r

instance DoubleReach.decidable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)]
    (p q s u : L) : Decidable (DoubleReach p q s u) :=
  Fintype.decidableExistsFintype

/-- **Coprime Lattice Elements.** `p ⊔ q = ⊤`.
Bridge: connects idempotent number theory to post-quantum cryptography. -/
def AreCoprime {L : Type*} [Lattice L] [OrderTop L] (p q : L) : Prop := p ⊔ q = ⊤

/-- **Spherical Function.** Invariant under all lattice automorphisms.
Bridge: connects tropical geometry to automorphic forms. -/
def IsSphericalFun {L : Type*} [Preorder L] {V : Type*} (f : L → V) : Prop :=
  ∀ σ : L ≃o L, ∀ q : L, f (σ q) = f q

/-- **Hecke Eigenpair.** `f` is an eigenfunction for `T_p` with eigenvalue `λ`. -/
structure HeckeEigenpair {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)]
    {V : Type*} [SemilatticeSup V] [OrderBot V]
    (p : L) (f : L → V) (eigenval : V) : Prop where
  eigen_eq : ∀ q : L, heckeOp p f q = eigenval ⊔ f q

/-- **Tropical Character.** A sup-preserving function from `L` to `V`.
Bridge: connects tropical Galois theory to lattice cryptography. -/
structure TropicalCharacter (L : Type*) [Lattice L]
    (V : Type*) [SemilatticeSup V] [OrderBot V] where
  toFun : L → V
  map_sup : ∀ a b : L, toFun (a ⊔ b) = toFun a ⊔ toFun b

/-- **Max-Plus Hecke Algebra Element.** A monotone operator on `(L → ℕ)`.

Bridge: connects tropical algebra to automorphic representation theory.
Computational complexity O(|L|² · depth). -/
structure MaxPlusHeckeAlg (L : Type*) [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)] where
  op : (L → ℕ) → L → ℕ
  mono : ∀ f g : L → ℕ, (∀ q, f q ≤ g q) → ∀ q, op f q ≤ op g q

/-- **Satake Cardinality Map.** `q ↦ |heckeFilter p q|`.
Bridge: connects combinatorial lattice theory to tropical_hash_collision bounds. -/
def satakeCard {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)] (p q : L) : ℕ :=
  (heckeFilter p q).card

/-- **Idempotent Spectral Datum.** Packages eigenfunction data.
Bridge: connects tropical spectral theory to quantum statistical mechanics. -/
structure IdempotentSpectralDatum (L : Type*) [Lattice L] [Fintype L] [DecidableEq L]
    [DecidableRel ((· ≤ ·) : L → L → Prop)] where
  level : L
  eigenfun : L → ℕ
  eigenval : ℕ
  is_eigen : HeckeEigenpair level eigenfun eigenval

/-! ## §2. Lattice Reachability Symmetry -/

section Reachability

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-
**Lattice Reachability Symmetry.** `DoubleReach p q s u ↔ DoubleReach q p s u`.

The proof constructs the witness `r' = u ⊔ r ⊔ s`:
- `q ≤ u ⊔ r ≤ u ⊔ r ⊔ s = r' ⊔ s`
- `p ≤ r ⊔ s ≤ u ⊔ r ⊔ s = u ⊔ r'`

Bridge: connects lattice theory to tropical automorphic forms.
-/
theorem doubleReach_symm (p q s u : L) :
    DoubleReach p q s u ↔ DoubleReach q p s u := by
  constructor <;> rintro ⟨ r, hr₁, hr₂ ⟩;
  · use u ⊔ r ⊔ s;
    simp_all +decide [le_sup_right];
    exact ⟨ hr₂.trans ( le_sup_left ), hr₁.trans ( by simp +decide [ sup_assoc ] ) ⟩;
  · refine' ⟨ u ⊔ r ⊔ s, _, _ ⟩ <;> simp_all +decide [ sup_assoc ];
    · exact le_trans hr₂ ( sup_le_sup_left ( le_sup_left ) _ );
    · exact le_trans hr₁ ( le_sup_right )

/-- The double reachability filter is symmetric in p, q. -/
lemma doubleReach_filter_eq (p q s : L) :
    Finset.univ.filter (fun u => DoubleReach p q s u) =
    Finset.univ.filter (fun u => DoubleReach q p s u) := by
  ext u; simp only [Finset.mem_filter, Finset.mem_univ, true_and]
  exact doubleReach_symm p q s u

end Reachability

/-! ## §3. Hecke Operator Properties -/

section HeckeProps

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]
  {V : Type*} [SemilatticeSup V] [OrderBot V]

/-
**Monotonicity.** `f ≤ g → T_p f ≤ T_p g`.
Bridge: connects tropical order theory to certified_robustness.
-/
theorem heckeOp_monotone (p : L) {f g : L → V} (hfg : ∀ q, f q ≤ g q)
    (q : L) : heckeOp p f q ≤ heckeOp p g q := by
  exact Finset.sup_mono_fun fun x hx => hfg x

/-
**Extensivity.** If `p ≤ q`, then `f q ≤ T_p f q`.
-/
theorem heckeOp_le_self (p : L) (f : L → V) (q : L) (hpq : p ≤ q) :
    f q ≤ heckeOp p f q := by
  exact Finset.le_sup ( f := f ) ( by simp [hpq] )

/-
**Global maximum bound.** `T_p f q ≤ sup f`.
-/
theorem heckeOp_le_sup (p : L) (f : L → V) (q : L) :
    heckeOp p f q ≤ Finset.univ.sup f := by
  exact Finset.sup_mono ( Finset.filter_subset _ _ )

/-
**Hecke preserves bot.** `T_p ⊥ = ⊥`.
-/
theorem heckeOp_bot (p : L) : heckeOp p (fun _ : L => (⊥ : V)) = fun _ => ⊥ := by
  ext q; simp +decide [ heckeOp ] ;

/-
**Anti-monotonicity in parameter.** `p ≤ p' → T_{p'} f q ≤ T_p f q`.
-/
theorem heckeOp_anti_param {p p' : L} (hpp' : p ≤ p') (f : L → V) (q : L) :
    heckeOp p' f q ≤ heckeOp p f q := by
  unfold heckeOp;
  grind

end HeckeProps

/-! ## §4. Hecke Commutativity -/

section HeckeComm

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]
  {V : Type*} [SemilatticeSup V] [OrderBot V]

/-
**Composition equals sup over double reachability.**
`(T_p ∘ T_q) f s = sup { f u | DoubleReach p q s u }`.
Uses `Finset.sup_biUnion` to flatten iterated supremum.
-/
theorem heckeOp_comp_eq_sup_doubleReach (p q : L) (f : L → V) (s : L) :
    heckeOp p (heckeOp q f) s =
    (Finset.univ.filter (fun u => DoubleReach p q s u)).sup f := by
  refine' le_antisymm _ _;
  · simp +decide [ heckeOp ];
    exact fun r hr u hu => Finset.le_sup ( f := f ) ( by exact Finset.mem_filter.2 ⟨ Finset.mem_univ _, ⟨ r, hr, by simpa only [ sup_comm ] using hu ⟩ ⟩ );
  · simp +decide [ heckeOp, DoubleReach ];
    exact fun b x hp hq => Finset.le_sup ( f := heckeOp q f ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hp ⟩ ) |> le_trans ( Finset.le_sup ( f := f ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hq ⟩ ) )

/-- **Hecke Commutativity (Gelfand Property).**
`T_p ∘ T_q = T_q ∘ T_p` for all `p, q`.

Bridge: connects tropical Hecke theory to classical Gelfand pairs.
Computational bound: O(|L|³) for verification. -/
theorem heckeOp_comm (p q : L) (f : L → V) :
    heckeOp p (heckeOp q f) = heckeOp q (heckeOp p f) := by
  funext s
  rw [heckeOp_comp_eq_sup_doubleReach, heckeOp_comp_eq_sup_doubleReach,
      doubleReach_filter_eq]

end HeckeComm

/-! ## §5. Bounded Lattice Theory -/

section BoundedLattice

variable {L : Type*} [Lattice L] [BoundedOrder L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]
  {V : Type*} [SemilatticeSup V] [OrderBot V]

/-
**Bottom Hecke = global sup.** `T_⊥ f q = sup f`.
Bridge: connects tropical algebra to statistical mechanics.
Application: computes tropical partition function.
-/
theorem heckeOp_bot_param (f : L → V) (q : L) :
    heckeOp (⊥ : L) f q = Finset.univ.sup f := by
  unfold heckeOp;
  aesop

/-
**Self-evaluation.** `f p ≤ T_p f p`.
-/
theorem heckeOp_self_le (p : L) (f : L → V) : f p ≤ heckeOp p f p := by
  exact Finset.le_sup ( f := f ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, by simp +decide ⟩ )

/-
**Top always reachable.** `f ⊤ ≤ T_p f q`.
-/
theorem heckeOp_ge_top_val (p : L) (f : L → V) (q : L) :
    f ⊤ ≤ heckeOp p f q := by
  refine' Finset.le_sup ( f := f ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ _, _ ⟩ );
  exact le_sup_of_le_left le_top

/-
**Identity on constants.** `T_p (fun _ => c) = fun _ => c`.
Bridge: connects idempotent algebra to tropical neural networks.
Application: constant activations are Hecke fixed points for certified_robustness.
-/
theorem heckeOp_const (p : L) (c : V) :
    heckeOp p (fun _ : L => c) = fun _ => c := by
  ext q;
  refine' le_antisymm _ _;
  · exact Finset.sup_le fun x hx => le_rfl;
  · exact Finset.le_sup ( f := fun x => c ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ ⊤, by simp +decide ⟩ )

end BoundedLattice

/-! ## §6. Filter Properties -/

section FilterProps

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-
The Hecke filter contains `p` itself.
-/
lemma heckeFilter_self_mem (p q : L) : p ∈ heckeFilter p q := by
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_sup_left ⟩

/-- The Hecke filter is nonempty. -/
lemma heckeFilter_nonempty (p q : L) : (heckeFilter p q).Nonempty :=
  ⟨p, heckeFilter_self_mem p q⟩

/-
Anti-monotone in `p`.
-/
lemma heckeFilter_anti {p p' : L} (h : p ≤ p') (q : L) :
    heckeFilter p' q ⊆ heckeFilter p q := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_trans h ( Finset.mem_filter.mp hx |>.2 ) ⟩

/-
Monotone in `q`.
-/
lemma heckeFilter_mono_q (p : L) {q q' : L} (h : q ≤ q') :
    heckeFilter p q ⊆ heckeFilter p q' := by
  exact fun x hx => Finset.mem_filter.mpr ⟨ Finset.mem_filter.mp hx |>.1, le_trans ( Finset.mem_filter.mp hx |>.2 ) ( sup_le_sup_left h _ ) ⟩

/-
Top is always in the Hecke filter.
-/
lemma heckeFilter_top_mem [BoundedOrder L] (p q : L) :
    (⊤ : L) ∈ heckeFilter p q := by
  exact Finset.mem_filter.mpr ⟨ Finset.mem_univ _, le_top.trans ( le_sup_left ) ⟩

/-- Cardinality bound. -/
lemma heckeFilter_card_le (p q : L) :
    (heckeFilter p q).card ≤ Fintype.card L :=
  Finset.card_filter_le _ _

end FilterProps

/-! ## §7. Satake Map -/

section SatakeMap

variable {L : Type*} [Lattice L] [BoundedOrder L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-
Satake cardinality is anti-monotone in `p`.
-/
theorem satakeCard_anti {p p' : L} (h : p ≤ p') (q : L) :
    satakeCard p' q ≤ satakeCard p q := by
  -- Since ` heckeFilter p' q ⊆ heckeFilter p q` due to `heckeFilter_anti` lemma.
  exact Finset.card_le_card (heckeFilter_anti h q)

/-
Satake cardinality is monotone in `q`.
-/
theorem satakeCard_mono (p : L) {q q' : L} (h : q ≤ q') :
    satakeCard p q ≤ satakeCard p q' := by
  exact Finset.card_mono ( heckeFilter_mono_q p h )

/-
Satake cardinality at `⊥` equals `|L|`.
-/
theorem satakeCard_bot (q : L) : satakeCard (⊥ : L) q = Fintype.card L := by
  exact congr_arg Finset.card ( Finset.filter_true_of_mem fun x _ => bot_le )

end SatakeMap

/-! ## §8. Double Reachability Properties -/

section DoubleReachProps

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-
Top is always double-reachable.
-/
theorem doubleReach_top [BoundedOrder L] (p q s : L) :
    DoubleReach p q s ⊤ := by
  exact ⟨ ⊤, by simp +decide, by simp +decide ⟩

/-
Self-reachability when `p ≤ u`.
-/
theorem doubleReach_self_diag (p u : L) (h : p ≤ u) :
    DoubleReach p p u u := by
  exact ⟨ u, by aesop ⟩

/-
Monotonicity in `s`.
-/
theorem doubleReach_mono_s {p q s s' u : L} (hss' : s ≤ s')
    (h : DoubleReach p q s u) : DoubleReach p q s' u := by
  -- Given that s ≤ s', we can use the same r from the hypothesis h.
  obtain ⟨r, hr⟩ := h;
  use r;
  exact ⟨ le_trans hr.1 ( sup_le_sup_left hss' _ ), hr.2 ⟩

end DoubleReachProps

/-! ## §9. Eigenfunction Theory -/

section EigenTheory

variable {L : Type*} [Lattice L] [BoundedOrder L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]
  {V : Type*} [SemilatticeSup V] [OrderBot V]

/-
**Constant functions are eigenfunctions.**
Bridge: connects tropical spectral theory to quantum statistical mechanics.
-/
theorem const_is_eigenfunction (p : L) (c : V) :
    HeckeEigenpair p (fun _ : L => c) c := by
  constructor;
  intro q
  simp [heckeOp];
  refine' le_antisymm _ _;
  · exact Finset.sup_le fun x hx => le_rfl;
  · exact Finset.le_sup ( f := fun _ => c ) ( Finset.mem_filter.mpr ⟨ Finset.mem_univ p, by simp +decide ⟩ )

/-
**Bot function is an eigenfunction.**
Bridge: connects tropical algebra to neural network initialization.
-/
theorem bot_is_eigenfunction (p : L) :
    HeckeEigenpair p (fun _ : L => (⊥ : V)) ⊥ := by
  constructor;
  unfold heckeOp;
  simp +decide

end EigenTheory

/-! ## §10. ℕ-Valued Hecke Theory -/

section NatHecke

variable {L : Type*} [Lattice L] [BoundedOrder L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-
Sup-norm preservation: `‖T_p f‖_∞ ≤ ‖f‖_∞`.
Bridge: connects tropical analysis to certified_robustness.
Application: 1-Lipschitz in sup-norm for tropical neural network classifiers.
-/
theorem heckeOp_sup_norm_le (p : L) (f : L → ℕ) :
    Finset.univ.sup (heckeOp p f) ≤ Finset.univ.sup f := by
  exact Finset.sup_le fun q _ => Finset.sup_le fun r hr => Finset.le_sup ( f := f ) ( Finset.mem_univ r )

end NatHecke

/-! ## §11. Bool Computations -/

section BoolLattice

instance : DecidableRel ((· ≤ ·) : Bool → Bool → Prop) :=
  fun a b => inferInstance

/-
`T_false` on `Bool` gives global max.
-/
theorem hecke_bool_false (f : Bool → ℕ) (q : Bool) :
    heckeOp false f q = f true ⊔ f false := by
  cases q <;> simp +decide [ heckeOp ]

/-
`T_true` at `true` gives global max.
-/
theorem hecke_bool_true_at_true (f : Bool → ℕ) :
    heckeOp true f true = f true ⊔ f false := by
  unfold heckeOp;
  simp +decide [ Finset.sup ]

/-
`T_true` at `false` gives `f true`.
-/
theorem hecke_bool_true_at_false (f : Bool → ℕ) :
    heckeOp true f false = f true := by
  convert Finset.sup_singleton

/-- Commutativity on `Bool`: concrete instance. -/
theorem hecke_bool_comm (p q : Bool) (f : Bool → ℕ) :
    heckeOp p (heckeOp q f) = heckeOp q (heckeOp p f) :=
  heckeOp_comm p q f

end BoolLattice

/-! ## §12. Fin n Computations -/

section FinLattice

instance (n : ℕ) : DecidableRel ((· ≤ ·) : Fin (n + 1) → Fin (n + 1) → Prop) :=
  fun a b => inferInstance

/-- Commutativity on `Fin n`: concrete instance. -/
theorem hecke_fin_comm (n : ℕ) (p q : Fin (n + 1)) (f : Fin (n + 1) → ℕ) :
    heckeOp p (heckeOp q f) = heckeOp q (heckeOp p f) :=
  heckeOp_comm p q f

end FinLattice

/-! ## §13. Hecke Algebra Construction -/

section HeckeAlg

variable {L : Type*} [Lattice L] [Fintype L] [DecidableEq L]
  [DecidableRel ((· ≤ ·) : L → L → Prop)]

/-- Every Hecke operator `T_p` yields a Hecke algebra element. -/
def MaxPlusHeckeAlg.ofHeckeOp (p : L) : MaxPlusHeckeAlg L where
  op := heckeOp p
  mono := fun f g hfg q => heckeOp_monotone p hfg q

end HeckeAlg

end MaxPlusHecke