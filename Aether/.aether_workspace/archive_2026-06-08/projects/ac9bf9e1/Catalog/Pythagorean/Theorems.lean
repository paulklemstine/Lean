/-
# Coalgebraic Final Semantics: Main Theorems

This file proves the core theorems of coalgebraic final semantics for simple types:

1. **Quotient Coalgebra Structure**: The behavioral equivalence quotient inherits coalgebra structure.
2. **Morphism Kernel Bisimulation**: Kernel of any coalgebra morphism is a bisimulation.
3. **Uniqueness of Final Coalgebra**: Any two final coalgebras are isomorphic.
4. **Arity Bound**: Branching degree bounded by type arity.
5. **Modal Depth Theory**: n-step equivalence forms a descending chain.
6. **Morphisms Preserve Behavioral Equivalence**.
7. **Cross-domain: Simulation and automata-theoretic connection**.

**Application keywords:** coalgebraic semantics, final coalgebra, bisimulation minimization,
Myhill–Nerode for λ-calculus, polynomial functors, canonical models, observational equivalence
-/

import CoalgebraicSemantics.Defs

open STLCType

universe u

/-! ## Theorem 1: Quotient Coalgebra Structure -/

/-
The structure map respects behavioral equivalence.
-/
theorem str_respects_behavioral_equiv (A : STLCType) (C : FiniteCoalgebra A)
    (x y : C.Carrier)
    (h : BehavioralEquiv A C x y) :
    (match C.str x with
     | Sum.inl () => (Sum.inl () : TypePolynomialFunctor A (SemanticQuotient A C))
     | Sum.inr fx => Sum.inr (fun i => @Quotient.mk _ (behavioralSetoid A C) (fx i))) =
    (match C.str y with
     | Sum.inl () => (Sum.inl () : TypePolynomialFunctor A (SemanticQuotient A C))
     | Sum.inr fy => Sum.inr (fun i => @Quotient.mk _ (behavioralSetoid A C) (fy i))) := by
  rcases h with ⟨ R, hR, hxy ⟩;
  cases h : C.str x <;> cases h' : C.str y <;> simp_all +decide;
  · exact absurd ( hR.terminal_left x y hxy h ) ( by simp +decide [ h' ] );
  · have := hR.terminal_right x y hxy; aesop;
  · have := hR.branching x y _ _ hxy h h';
    exact funext fun i => Quotient.sound ⟨ R, hR, this i ⟩

/-- The descended structure map on the quotient. -/
noncomputable def quotientStr (A : STLCType) (C : FiniteCoalgebra A) :
    SemanticQuotient A C → TypePolynomialFunctor A (SemanticQuotient A C) :=
  Quotient.lift
    (fun x => match C.str x with
              | Sum.inl () => (Sum.inl () : TypePolynomialFunctor A (SemanticQuotient A C))
              | Sum.inr fx => Sum.inr (fun i => @Quotient.mk _ (behavioralSetoid A C) (fx i)))
    (fun x y (h : BehavioralEquiv A C x y) =>
      str_respects_behavioral_equiv A C x y h)

/-
**Theorem 1 (Quotient Has Coalgebra Structure)**
-/
theorem quotient_has_coalgebra_structure
    (A : STLCType) (C : FiniteCoalgebra A) :
    ∃ qstr : SemanticQuotient A C → TypePolynomialFunctor A (SemanticQuotient A C),
      ∀ x : C.Carrier,
        qstr (Quotient.mk (behavioralSetoid A C) x) =
        TypePolynomialFunctor.map (Quotient.mk (behavioralSetoid A C)) (C.str x) := by
  convert @str_respects_behavioral_equiv A C;
  constructor <;> intro h;
  · exact fun x y h => str_respects_behavioral_equiv A C x y h;
  · use fun x => Quotient.liftOn' x (fun x => match C.str x with
      | Sum.inl () => (Sum.inl () : TypePolynomialFunctor A (SemanticQuotient A C))
      | Sum.inr fx => Sum.inr (fun i => @Quotient.mk _ (behavioralSetoid A C) (fx i))) (fun x y (h : BehavioralEquiv A C x y) =>
      str_respects_behavioral_equiv A C x y h);
    intro x; exact (by
    cases h : C.str x <;> simp +decide [ h ];
    · rfl;
    · rfl)

/-! ## Theorem 2: Morphism Kernel is a Bisimulation -/

/-- The kernel relation of a function. -/
def kernelRel {α β : Type*} (f : α → β) (x y : α) : Prop := f x = f y

/-
**Theorem 2 (Morphism Kernel Bisimulation)**
-/
theorem morphism_kernel_is_bisimulation
    (A : STLCType) (C D : FiniteCoalgebra A)
    (f : CoalgebraHom A C D) :
    IsBisimulation A C (kernelRel f.toFun) := by
  constructor <;> intro x y hxy hx <;> simp_all +decide [ kernelRel ];
  · have h_comm : D.str (f.toFun x) = TypePolynomialFunctor.map f.toFun (C.str x) := by
      exact f.comm x
    have h_comm_y : D.str (f.toFun y) = TypePolynomialFunctor.map f.toFun (C.str y) := by
      exact f.comm y
    have := f.comm y; simp_all +decide [ TypePolynomialFunctor.map ] ;
    cases h : C.str y <;> aesop;
  · have := f.comm x; have := f.comm y; simp_all +decide [ IsBisimulation ] ;
    cases h : C.str x <;> simp_all +decide [ TypePolynomialFunctor.map ];
  · intro hxy' hx' hy' i
    have h_eq : TypePolynomialFunctor.map (f.toFun) (C.str x) = TypePolynomialFunctor.map (f.toFun) (C.str y) := by
      have := f.comm x; have := f.comm y; aesop;
    cases h : C.str x <;> cases h' : C.str y <;> simp_all +decide [ TypePolynomialFunctor.map ];
    injection h_eq with h_eq ; replace h_eq := congr_fun h_eq i ; aesop

/-- Morphism-identified states are behaviorally equivalent. -/
theorem morphism_identifies_implies_behavioral_equiv
    (A : STLCType) (C D : FiniteCoalgebra A)
    (f : CoalgebraHom A C D)
    {x y : C.Carrier} (h : f.toFun x = f.toFun y) :
    BehavioralEquiv A C x y :=
  ⟨kernelRel f.toFun, morphism_kernel_is_bisimulation A C D f, h⟩

/-! ## Theorem 3: Uniqueness of Final Coalgebra -/

/-- A coalgebra isomorphism. -/
structure CoalgebraIso (A : STLCType) (C D : FiniteCoalgebra A) where
  fwd : CoalgebraHom A C D
  bwd : CoalgebraHom A D C
  left_inv : ∀ x, bwd.toFun (fwd.toFun x) = x
  right_inv : ∀ y, fwd.toFun (bwd.toFun y) = y

/-- Finality in a class of coalgebras. -/
structure IsFinalIn (A : STLCType) (F : FiniteCoalgebra A)
    (inClass : FiniteCoalgebra A → Prop) : Prop where
  self_in_class : inClass F
  univ : ∀ C : FiniteCoalgebra A, inClass C →
    ∃ f : CoalgebraHom A C F,
      ∀ g : CoalgebraHom A C F, ∀ x, g.toFun x = f.toFun x

/-
**Theorem 3 (Uniqueness of Final Coalgebra)**
-/
theorem final_coalgebra_unique
    (A : STLCType) {inClass : FiniteCoalgebra A → Prop}
    {F G : FiniteCoalgebra A}
    (hF : IsFinalIn A F inClass)
    (hG : IsFinalIn A G inClass) :
    Nonempty (CoalgebraIso A F G) := by
  obtain ⟨f, hf⟩ : ∃ f : CoalgebraHom A G F, ∀ g : CoalgebraHom A G F, ∀ x, g.toFun x = f.toFun x := by
    exact hF.univ G hG.self_in_class
  obtain ⟨g, hg⟩ : ∃ g : CoalgebraHom A F G, ∀ h : CoalgebraHom A F G, ∀ y, h.toFun y = g.toFun y := by
    exact hG.univ F hF.self_in_class;
  refine' ⟨ g, f, _, _ ⟩;
  · have := hF.univ F hF.self_in_class;
    obtain ⟨ f, hf ⟩ := this;
    convert hf ( CoalgebraHom.comp ‹CoalgebraHom A G F› g ) using 1;
    simp +decide [ ← hf ( CoalgebraHom.id A F ) ];
    rfl;
  · have := hG.univ;
    obtain ⟨ h, hh ⟩ := this G hG.self_in_class;
    convert hh ( CoalgebraHom.comp g f ) using 1;
    simp +decide [ ← hh ( CoalgebraHom.id A G ) ];
    rfl

/-! ## Theorem 4: Type Shape Controls Arity -/

/-- The branching degree of a state. -/
def branchingDegree (A : STLCType) (C : FiniteCoalgebra A) (x : C.Carrier) : ℕ :=
  match C.str x with
  | Sum.inl _ => 0
  | Sum.inr _ => arityOf A

/-- **Theorem 4 (Arity Bound)** -/
theorem transition_arity_bounded_by_type
    (A : STLCType) (C : FiniteCoalgebra A) (x : C.Carrier) :
    branchingDegree A C x ≤ arityOf A := by
  unfold branchingDegree
  cases C.str x with
  | inl _ => exact Nat.zero_le _
  | inr _ => exact le_refl _

theorem arr_arity_pos (A B : STLCType) : 0 < arityOf (.arr A B) := by
  unfold arityOf; omega

/-! ## Theorem 5: Modal Depth Approximation -/

/-- n-step behavioral equivalence: agreement up to depth n. -/
def BehavEquivN (A : STLCType) (C : FiniteCoalgebra A) :
    ℕ → C.Carrier → C.Carrier → Prop
  | 0 => fun _ _ => True
  | n + 1 => fun x y =>
    (C.str x = Sum.inl () ↔ C.str y = Sum.inl ()) ∧
    ∀ (fx : Fin (arityOf A) → C.Carrier) (fy : Fin (arityOf A) → C.Carrier),
      C.str x = Sum.inr fx → C.str y = Sum.inr fy →
      ∀ i, BehavEquivN A C n (fx i) (fy i)

/-- n-step equivalence is reflexive. -/
theorem behavEquivN_refl (A : STLCType) (C : FiniteCoalgebra A) :
    ∀ (n : ℕ) (x : C.Carrier), BehavEquivN A C n x x := by
  intro n; induction n with
  | zero => intro _; trivial
  | succ n ih =>
    intro x
    refine ⟨Iff.rfl, fun fx fy hfx hfy i => ?_⟩
    rw [hfx] at hfy; cases hfy; exact ih (fx i)

/-- n-step equivalence is symmetric. -/
theorem behavEquivN_symm (A : STLCType) (C : FiniteCoalgebra A) :
    ∀ (n : ℕ) (x y : C.Carrier), BehavEquivN A C n x y → BehavEquivN A C n y x := by
  intro n; induction n with
  | zero => intros; trivial
  | succ n ih =>
    intro x y ⟨h_iff, h_branch⟩
    exact ⟨h_iff.symm, fun fy fx hfy hfx i => ih _ _ (h_branch fx fy hfx hfy i)⟩

/-- n-step equivalence is transitive. -/
theorem behavEquivN_trans (A : STLCType) (C : FiniteCoalgebra A) :
    ∀ (n : ℕ) (x y z : C.Carrier),
      BehavEquivN A C n x y → BehavEquivN A C n y z → BehavEquivN A C n x z := by
  intro n; induction n with
  | zero => intros; trivial
  | succ n ih =>
    intro x y z ⟨hxy_iff, hxy_br⟩ ⟨hyz_iff, hyz_br⟩
    refine ⟨Iff.trans hxy_iff hyz_iff, fun fx fz hfx hfz i => ?_⟩
    have hy_not_term : ¬(C.str y = Sum.inl ()) := by
      intro hy; have := hxy_iff.mpr hy; rw [this] at hfx; simp at hfx
    obtain ⟨fy, hfy⟩ : ∃ fy, C.str y = Sum.inr fy := by
      cases h : C.str y with
      | inl u => exact absurd h hy_not_term
      | inr g => exact ⟨g, rfl⟩
    exact ih _ _ _ (hxy_br fx fy hfx hfy i) (hyz_br fy fz hfy hfz i)

/-- **Theorem 5 (Descending Chain)**: (n+1)-step equivalence refines n-step. -/
theorem behavEquivN_descending (A : STLCType) (C : FiniteCoalgebra A) :
    ∀ (n : ℕ) (x y : C.Carrier),
      BehavEquivN A C (n + 1) x y → BehavEquivN A C n x y := by
  intro n; induction n with
  | zero => intros; trivial
  | succ n ih =>
    intro x y ⟨h_iff, h_branch⟩
    exact ⟨h_iff, fun fx fy hfx hfy i => ih _ _ (h_branch fx fy hfx hfy i)⟩

/-- **Theorem (Bisimulation implies n-equivalence for all n)** -/
theorem behavioral_implies_nstep
    (A : STLCType) (C : FiniteCoalgebra A)
    {x y : C.Carrier}
    (h : BehavioralEquiv A C x y) :
    ∀ n, BehavEquivN A C n x y := by
  obtain ⟨R, hR, hxy⟩ := h
  intro n
  induction n generalizing x y with
  | zero => trivial
  | succ n ih =>
    refine ⟨⟨fun hsx => hR.terminal_left x y hxy hsx,
            fun hsy => hR.terminal_right x y hxy hsy⟩,
           fun fx fy hfx hfy i => ?_⟩
    exact ih (hR.branching x y fx fy hxy hfx hfy i)

/-! ## Canonical Behavior Construction -/

/-- The canonical (minimized) coalgebra: quotient by behavioral equivalence. -/
noncomputable def canonicalCoalgebra (A : STLCType) (C : FiniteCoalgebra A) :
    FiniteCoalgebra A where
  Carrier := SemanticQuotient A C
  str := quotientStr A C
  fin := @Quotient.finite _ C.fin (behavioralSetoid A C)

/-- The canonical projection is a coalgebra morphism. -/
noncomputable def canonicalProjection (A : STLCType) (C : FiniteCoalgebra A) :
    CoalgebraHom A C (canonicalCoalgebra A C) where
  toFun := Quotient.mk (behavioralSetoid A C)
  comm := fun x => by
    simp only [canonicalCoalgebra, quotientStr, Quotient.lift_mk]
    cases hsx : C.str x with
    | inl u => simp [TypePolynomialFunctor.map]
    | inr fx => simp only [TypePolynomialFunctor.map]; rfl

/-- The canonical projection is surjective. -/
theorem canonical_projection_surjective (A : STLCType) (C : FiniteCoalgebra A) :
    Function.Surjective (canonicalProjection A C).toFun :=
  Quotient.exists_rep

/-- Behavioral equivalence on the quotient collapses to equality. -/
theorem quotient_behavioral_equiv_eq
    (A : STLCType) (C : FiniteCoalgebra A)
    {x y : C.Carrier}
    (h : BehavioralEquiv A C x y) :
    (Quotient.mk (behavioralSetoid A C) x : SemanticQuotient A C) =
    Quotient.mk (behavioralSetoid A C) y :=
  Quotient.sound h

/-! ## Cross-Domain: Simulation Relations -/

/-- A simulation relation between coalgebras (automata-theoretic bridge). -/
structure IsSimulation (A : STLCType) (C D : FiniteCoalgebra A)
    (R : C.Carrier → D.Carrier → Prop) : Prop where
  terminal_sim : ∀ x y, R x y → C.str x = Sum.inl () → D.str y = Sum.inl ()
  branching_sim : ∀ x y (fx : Fin (arityOf A) → C.Carrier) (fy : Fin (arityOf A) → D.Carrier),
    R x y → C.str x = Sum.inr fx → D.str y = Sum.inr fy →
    ∀ i, R (fx i) (fy i)

/-
The graph of a coalgebra morphism is a simulation.
-/
theorem morphism_graph_is_simulation
    (A : STLCType) (C D : FiniteCoalgebra A)
    (f : CoalgebraHom A C D) :
    IsSimulation A C D (fun x y => f.toFun x = y) := by
  constructor;
  · intro x y hxy hx; have := f.comm x; aesop;
  · intro x y fx fy hxy hx hy i; have := f.comm x; simp_all +decide [ TypePolynomialFunctor.map ] ;
    injection this.symm with h; aesop;

/-! ## Base Type Analysis -/

/-- For base types, `TypePolynomialFunctor` is isomorphic to `Unit ⊕ Unit`. -/
noncomputable def base_type_equiv (X : Type u) :
    TypePolynomialFunctor STLCType.base X ≃ (Unit ⊕ Unit) where
  toFun x := match x with
    | Sum.inl u => Sum.inl u
    | Sum.inr _ => Sum.inr ()
  invFun x := match x with
    | Sum.inl u => Sum.inl u
    | Sum.inr () => Sum.inr Fin.elim0
  left_inv x := by
    cases x with
    | inl u => rfl
    | inr f =>
      show Sum.inr Fin.elim0 = Sum.inr f
      congr; ext i; exact Fin.elim0 i
  right_inv x := by cases x with | inl u => rfl | inr u => rfl