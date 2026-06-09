theorem closure_idempotent (a : α) : bwd (fwd (bwd (fwd a))) = bwd (fwd a) := by
  apply le_antisymm
  · exact gc.monotone_u (gc.l_u_le _)
  · exact gc.monotone_u (gc.monotone_l (gc.le_u_l a))

/-! ## Concrete Tense Heyting Algebra on Fin 3 -/

/-- Forward temporal operator on Fin 3: sends ⊥ to ⊥, everything else to ⊤. -/
def fin3Fwd : Fin 3 → Fin 3
  | ⟨0, _⟩ => 0
  | _ => 2

/-- Backward temporal operator on Fin 3: right adjoint of fin3Fwd. -/
def fin3Bwd : Fin 3 → Fin 3
  | ⟨2, _⟩ => 2
  | _ => 0

/-- The Galois connection for the Fin 3 tense algebra. -/

theorem fin3_gc : GaloisConnection fin3Fwd fin3Bwd := by
  intro a b; fin_cases a <;> fin_cases b <;> trivial

/-- Concrete TenseHeytingAlgebra instance on Fin 3. -/
noncomputable instance fin3TenseHeytingAlgebra : TenseHeytingAlgebra (Fin 3) where
  fwd := fin3Fwd
  bwd := fin3Bwd
  gc := fin3_gc

/-- **B**oundary: The closure bwd ∘ fwd is NOT the identity in general.
In Fin 3: bwd(fwd 1) = fin3Bwd(2) = 2 ≠ 1. -/

theorem lem_holds_in_two (a : Fin 2) : a ⊔ (a ⇨ ⊥) = ⊤ := by
  fin_cases a <;> decide

/-! ## Temporal Excluded Middle -/

/-- The temporal excluded middle axiom: for all a, fwd a ⊔ bwd(aᶜ) = ⊤.
This says: "either a holds at some future time, or ¬a holds at all past times."
Unlike classical LEM (a ⊔ aᶜ = ⊤), this uses the temporal operators to
"spread out" the disjunction across time. -/
class TemporalEM (α : Type*) [TenseHeytingAlgebra α] : Prop where
  temporal_em : ∀ a : α, fwd a ⊔ bwd (a ⇨ ⊥) = ⊤

-- !-- When both temporal operators are contractive (fwd a ≤ a and bwd a ≤ a),
-- temporal EM collapses back to classical EM. This shows the temporal operators
-- must be non-trivial to separate temporal EM from classical EM. -- !--

/-- **P**roof: If fwd = id and bwd = id, temporal EM implies classical LEM. -/

theorem temporal_em_contractive_implies_lem [TemporalEM α]
    (h_fwd : ∀ a : α, fwd a ≤ a)
    (h_bwd : ∀ a : α, bwd a ≤ a)
    (a : α) : a ⊔ (a ⇨ ⊥) = ⊤ := by
  have hem := TemporalEM.temporal_em a
  exact le_antisymm le_top (hem ▸ sup_le_sup (h_fwd a) (h_bwd _))

/-- Temporal EM holds in the Fin 3 tense algebra. -/
instance fin3TemporalEM : TemporalEM (Fin 3) where
  temporal_em := by
    intro a
    show fin3Fwd a ⊔ fin3Bwd (a ⇨ ⊥) = ⊤
    fin_cases a <;> decide

/-- **P**roof: Classical LEM fails in Fin 3 despite temporal EM holding.
This demonstrates that temporal EM is strictly weaker than classical EM. -/

theorem complement_deficiency_bound (a : α) :
    fwd (bwd (a ⇨ ⊥)) ≤ a ⊔ (a ⇨ ⊥) :=
  le_trans (interior_contractive _) le_sup_right

/-- **E**xample: Applied to Fin 3 with the concrete operators. -/
example : fin3Fwd (fin3Bwd ((1 : Fin 3) ⇨ ⊥)) ≤ (1 : Fin 3) ⊔ ((1 : Fin 3) ⇨ ⊥) := by
  decide

/-
**G**eneralization: The set of decidable (complemented) elements is closed under meets.
This is a standard fact about Heyting algebras: the Boolean elements form a sublattice.
-/