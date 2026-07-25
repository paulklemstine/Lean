theorem lfp_rolling [CompleteLattice α]
    (f g : α →o α) :
    (f.comp g).lfp = f ((g.comp f).lfp) := by
  refine' le_antisymm ( OrderHom.lfp_le_fixed _ _ ) _;
  · have := ( g.comp f ).map_lfp;
    convert congr_arg f this using 1;
  · convert OrderHom.lfp_le_fixed ( f.comp g ) _;
    · exact map_lfp_comp f g;
    · exact OrderHom.map_lfp _

/-! ## Section 4: Diagonal Fixed Points and Self-Reference -/

/-- The diagonal of a monotone function on a product is monotone. -/
def diagonalHom [Preorder α] [Preorder β]
    (F : (α × α) →o β) : α →o β where
  toFun x := F (x, x)
  monotone' _ _ h := F.mono (Prod.mk_le_mk.mpr ⟨h, h⟩)

-- !-- Self-referential fixed points exist by Knaster-Tarski applied to the
-- diagonal. The diagonal x ↦ F(x,x) is monotone, hence has a lfp. -- !--

/-- **Diagonal Fixed Point**: `x ↦ F(x,x)` has a least fixed point. -/

theorem diagonal_lfp_is_fixedPt [CompleteLattice α]
    (F : (α × α) →o α) :
    IsFixedPt (diagonalHom F) (diagonalHom F).lfp :=
  (diagonalHom F).isFixedPt_lfp

/-
When `F(x, y) = x ⊓ y`, the diagonal is the identity and lfp = ⊥.
-/

theorem self_referential_fixedPt_exists [CompleteLattice α]
    (Sim : (α × α) →o α) :
    ∃ L : α, (diagonalHom Sim) L = L :=
  ⟨(diagonalHom Sim).lfp, (diagonalHom Sim).isFixedPt_lfp⟩

/-- The least self-referential fixed point is below any other. -/

theorem self_referential_lfp_least [CompleteLattice α]
    (Sim : (α × α) →o α) (L : α) (hL : Sim (L, L) = L) :
    (diagonalHom Sim).lfp ≤ L :=
  (diagonalHom Sim).lfp_le_fixed hL

/-! ## Section 5: Fixed Point Transfer via Order Isomorphisms -/

/-
!-- For ≤, show φ(lfp f) is a fixed point of the conjugate (using φ.symm_apply_apply
and map_lfp), then lfp ≤ it by lfp_le_fixed. For ≥, show any pre-fixed point b
of the conjugate gives φ⁻¹(b) as pre-fixed point of f, then lfp f ≤ φ⁻¹(b),
so φ(lfp f) ≤ b. -- !--

**Fixed Point Transfer**: `φ(lfp f) = lfp (φ ∘ f ∘ φ⁻¹)`.
-/