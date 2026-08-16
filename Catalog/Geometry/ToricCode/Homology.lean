import Geometry.ToricCode.Basic
/-!
# First homology of the square torus: rank exactly two

We compute `dim_{𝔽₂} H₁ = dim ker d₁ - dim im d₂ = 2` for the `M × N` square
torus, for *every* `M, N ≥ 1`.

The computation avoids any explicit basis of the cycle space.  Instead:

* the kernel of the coboundary `d₁ᵀ` is the line of constant `0`-cochains
  (`ker_d1T`), because the vertex graph of the torus is connected;
* the kernel of `d₂` is the line of constant `2`-chains (`ker_d2`), because the
  dual graph is connected;
* hence `rank d₁ᵀ = MN - 1`, and `rank d₁ = rank d₁ᵀ` by the row-rank/column-rank
  theorem, so `dim ker d₁ = 2MN - (MN - 1) = MN + 1`;
* and `dim im d₂ = MN - 1`;
* subtracting gives `2`.
-/

open Matrix

namespace ToricCode

variable (M N : ℕ) [NeZero M] [NeZero N]

/-- The `𝔽₂`-space of cellular one-cycles. -/
noncomputable def cycles : Submodule F2 (Edge M N → F2) := LinearMap.ker (d1 M N).mulVecLin

/-- The `𝔽₂`-space of cellular one-boundaries. -/
noncomputable def boundaries : Submodule F2 (Edge M N → F2) := LinearMap.range (d2 M N).mulVecLin

/-- Boundaries are cycles. -/
theorem boundaries_le_cycles : boundaries M N ≤ cycles M N := by
  rintro z ⟨g, rfl⟩
  simpa [cycles, LinearMap.mem_ker] using d1_d2_mulVec M N g

/-- First Betti number over `𝔽₂`. -/
noncomputable def homologyRank : ℕ :=
  Module.finrank F2 (cycles M N) - Module.finrank F2 (boundaries M N)

/-! ### The two connectivity lemmas -/

/-- A `0`-cochain is a cocycle iff it is constant: the vertex graph of the torus
is connected. -/
theorem ker_d1T :
    LinearMap.ker ((d1 M N)ᵀ).mulVecLin = F2 ∙ (fun _ => 1 : Vert M N → F2) := by
  apply le_antisymm
  · intro h hh
    rw [LinearMap.mem_ker, Matrix.mulVecLin_apply] at hh
    have key : ∀ (b : Bool) (u : ZMod M × ZMod N), h u + h (u + step M N b) = 0 := by
      intro b u
      rw [← d1T_mulVec M N h b u, hh]
      rfl
    have hx : ∀ u : ZMod M × ZMod N, h (u + (1, 0)) = h u := by
      intro u
      have := key false u
      simp only [step_false] at this
      have h2 : ∀ x y : F2, x + y = 0 → y = x := by decide
      exact h2 _ _ this
    have hy : ∀ u : ZMod M × ZMod N, h (u + (0, 1)) = h u := by
      intro u
      have := key true u
      simp only [step_true] at this
      have h2 : ∀ x y : F2, x + y = 0 → y = x := by decide
      exact h2 _ _ this
    rw [Submodule.mem_span_singleton]
    refine ⟨h 0, ?_⟩
    funext u
    simp only [Pi.smul_apply, smul_eq_mul, mul_one]
    exact (const_of_shift M N h hx hy u).symm
  · rw [Submodule.span_le, Set.singleton_subset_iff]
    rw [SetLike.mem_coe, LinearMap.mem_ker, Matrix.mulVecLin_apply]
    funext e
    obtain ⟨b, u⟩ := e
    rw [d1T_mulVec]
    show (1 : F2) + 1 = 0
    decide

/-- A `2`-chain has vanishing boundary iff it is constant: the dual graph of the
torus is connected. -/
theorem ker_d2 :
    LinearMap.ker (d2 M N).mulVecLin = F2 ∙ (fun _ => 1 : Face M N → F2) := by
  apply le_antisymm
  · intro g hg
    rw [LinearMap.mem_ker, Matrix.mulVecLin_apply] at hg
    have key : ∀ (b : Bool) (u : ZMod M × ZMod N), g u + g (u - step M N (!b)) = 0 := by
      intro b u
      rw [← d2_mulVec M N g b u, hg]
      rfl
    have h2 : ∀ x y : F2, x + y = 0 → y = x := by decide
    have hx : ∀ u : ZMod M × ZMod N, g (u + (1, 0)) = g u := by
      intro u
      have := key true (u + (1, 0))
      simp only [Bool.not_true, step_false, add_sub_cancel_right] at this
      exact (h2 _ _ this).symm
    have hy : ∀ u : ZMod M × ZMod N, g (u + (0, 1)) = g u := by
      intro u
      have := key false (u + (0, 1))
      simp only [Bool.not_false, step_true, add_sub_cancel_right] at this
      exact (h2 _ _ this).symm
    rw [Submodule.mem_span_singleton]
    refine ⟨g 0, ?_⟩
    funext u
    simp only [Pi.smul_apply, smul_eq_mul, mul_one]
    exact (const_of_shift M N g hx hy u).symm
  · rw [Submodule.span_le, Set.singleton_subset_iff]
    rw [SetLike.mem_coe, LinearMap.mem_ker, Matrix.mulVecLin_apply]
    funext e
    obtain ⟨b, u⟩ := e
    rw [d2_mulVec]
    show (1 : F2) + 1 = 0
    decide

/-! ### Rank computations -/

private lemma finrank_const_line {α : Type*} [Fintype α] [Nonempty α] :
    Module.finrank F2 (F2 ∙ (fun _ => 1 : α → F2)) = 1 := by
  apply finrank_span_singleton
  intro h
  have := congrFun h (Classical.arbitrary α)
  simp at this

lemma finrank_ker_d1T : Module.finrank F2 (LinearMap.ker ((d1 M N)ᵀ).mulVecLin) = 1 := by
  rw [ker_d1T]
  exact finrank_const_line

lemma finrank_ker_d2 : Module.finrank F2 (LinearMap.ker (d2 M N).mulVecLin) = 1 := by
  rw [ker_d2]
  exact finrank_const_line

lemma one_le_mul : 1 ≤ M * N := Nat.one_le_iff_ne_zero.2 (by
  have h1 := NeZero.ne M
  have h2 := NeZero.ne N
  positivity)

/-- The rank of the boundary matrix `d₁` is `MN - 1`. -/
theorem rank_d1 : (d1 M N).rank = M * N - 1 := by
  have h := LinearMap.finrank_range_add_finrank_ker ((d1 M N)ᵀ).mulVecLin
  rw [finrank_ker_d1T, Module.finrank_fintype_fun_eq_card, card_vert M N] at h
  have : ((d1 M N)ᵀ).rank = M * N - 1 := by
    show Module.finrank F2 (LinearMap.range ((d1 M N)ᵀ).mulVecLin) = M * N - 1
    omega
  rwa [Matrix.rank_transpose] at this

/-- The rank of the boundary matrix `d₂` is `MN - 1`. -/
theorem rank_d2 : (d2 M N).rank = M * N - 1 := by
  have h := LinearMap.finrank_range_add_finrank_ker (d2 M N).mulVecLin
  rw [finrank_ker_d2, Module.finrank_fintype_fun_eq_card, card_face M N] at h
  show Module.finrank F2 (LinearMap.range (d2 M N).mulVecLin) = M * N - 1
  omega

/-- The cycle space has dimension `MN + 1`. -/
theorem finrank_cycles : Module.finrank F2 (cycles M N) = M * N + 1 := by
  have h := LinearMap.finrank_range_add_finrank_ker (d1 M N).mulVecLin
  rw [Module.finrank_fintype_fun_eq_card, card_edge M N] at h
  have hr : Module.finrank F2 (LinearMap.range (d1 M N).mulVecLin) = M * N - 1 := rank_d1 M N
  have := one_le_mul M N
  show Module.finrank F2 (LinearMap.ker (d1 M N).mulVecLin) = M * N + 1
  omega

/-- The boundary space has dimension `MN - 1`. -/
theorem finrank_boundaries : Module.finrank F2 (boundaries M N) = M * N - 1 := rank_d2 M N

/-- **The `M × N` toric code encodes exactly two logical qubits.**
The first `𝔽₂`-homology of the square torus has rank `2`, matching the genus-one
answer `2g = 2` — but here it is derived from a genuine cellulation, not from an
abstract minimal CW model. -/
theorem toric_homologyRank : homologyRank M N = 2 := by
  rw [homologyRank, finrank_cycles, finrank_boundaries]
  have := one_le_mul M N
  omega

end ToricCode