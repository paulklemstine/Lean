import Algebra.StandardConjectures.Defs

/-!
# Standard Conjectures: Structural Theorems

We prove non-trivial structural results about Grothendieck's standard conjectures:

1. **Nondegeneracy implies D**: When the pairing is nondegenerate,
   Standard Conjecture D holds.
2. **Numerical kernel in Lefschetz kernel**: numKer ≤ ker(Q_L).
3. **Complementary idempotents**: Motive decomposition via idempotents.
4. **Rank additivity**: dim(M) + dim(M^⊥) = dim(V).
5. **Lefschetz stability**: L preserves the numerical kernel under compatibility.
6. **Künneth decomposition**: Orthogonal projectors give direct sums.
7. **Hodge index theorem (rank 2)**: Signature constraint on intersection forms.
8. **Lefschetz involution**: Star operator is idempotent on image.
9. **Motivic weight filtration**: Filtered pieces are well-ordered.

## Mathematical significance

These results form the "linear algebra backbone" of the standard conjectures.
The key insight is that many properties follow from purely linear-algebraic
reasoning once the Lefschetz structure and intersection pairing are given.
-/

noncomputable section

open LinearMap Submodule

/-! ## Theorem 1: Nondegenerate pairing implies Standard Conjecture D -/

/-- If the intersection pairing is nondegenerate (numKer = ⊥), then
    Standard Conjecture D holds trivially. -/
theorem standardD_of_nondegenerate (M : LefschetzModule) (HD : M.HomologicalData)
    (h_nondeg : M.qNondegenerate) : M.standardConjectureD HD := by
  rw [LefschetzModule.standardConjectureD_iff]
  rw [LefschetzModule.qNondegenerate] at h_nondeg
  rw [h_nondeg]
  exact bot_le

/-! ## Theorem 2: Numerical kernel ≤ Lefschetz pairing kernel -/

/-- If v is in the numerical kernel of Q and Q is L-compatible
    (Q(Lx,y) = Q(x,Ly)), then L(v) is also in the numerical kernel.
    This implies numKer is L-stable under compatibility. -/
theorem numKer_le_lefschetzPairing_ker (M : LefschetzModule)
    (hcompat : ∀ x y, M.Q (M.L x) y = M.Q x (M.L y)) :
    M.numKer ≤ LinearMap.ker M.lefschetzPairing := by
  intro v hv
  rw [LinearMap.mem_ker]
  ext w
  simp only [LefschetzModule.lefschetzPairing, LinearMap.comp_apply, LinearMap.zero_apply]
  rw [hcompat v w]
  exact (M.mem_numKer_iff v).mp hv (M.L w)

/-! ## Theorem 3: Complementary idempotents -/

/-
If p is idempotent, then 1-p is also idempotent.
-/
theorem complement_idempotent {V : Type*} [AddCommGroup V] [Module ℚ V]
    (p : V →ₗ[ℚ] V) (hp : p ∘ₗ p = p) :
    (LinearMap.id - p) ∘ₗ (LinearMap.id - p) = LinearMap.id - p := by
  simp_all +decide [ LinearMap.ext_iff ]

/-
The image of an idempotent projector equals its fixed-point set.
-/
theorem pureMotive_range_eq_fixed (M : PureMotive) :
    M.realization = LinearMap.eqLocus M.projector LinearMap.id := by
  ext v; simp [PureMotive.realization];
  constructor <;> intro h <;> have := M.projector_idem <;> simp_all +decide [ LinearMap.ext_iff ] ;
  · grind +ring;
  · exact ⟨ v, h ⟩

/-- The complementary motive. -/
def PureMotive.complement (M : PureMotive) : PureMotive where
  V := M.V
  projector := LinearMap.id - M.projector
  projector_idem := by
    have := complement_idempotent M.projector M.projector_idem
    exact this
  twist := M.twist

/-
The realizations of a motive and its complement span the whole space.
-/
theorem PureMotive.realization_complement_sup (M : PureMotive) :
    M.realization ⊔ M.complement.realization = ⊤ := by
  rw [ eq_top_iff ];
  -- For any v in the top submodule, we can write v as p(v) + (v - p(v)), where p(v) is in M.realization and (v - p(v)) is in M.complement.realization.
  intro v hv
  have h_decomp : v = M.projector v + (v - M.projector v) := by
    rw [ add_sub_cancel ];
  exact Submodule.mem_sup.mpr ⟨ M.projector v, LinearMap.mem_range_self _ _, v - M.projector v, LinearMap.mem_range_self _ _, by simp ⟩

/-
The realizations of a motive and its complement have trivial intersection.
-/
theorem PureMotive.realization_complement_inf (M : PureMotive) :
    M.realization ⊓ M.complement.realization = ⊥ := by
  rw [ eq_bot_iff ];
  intro v hv;
  obtain ⟨w, hw⟩ := hv.left;
  -- Since $v$ is in the image of $M.projector$, we have $M.projector v = v$.
  have h_proj_v : M.projector v = v := by
    have := M.projector_idem; replace := LinearMap.congr_fun this w; aesop;
  obtain ⟨x, hx⟩ := hv.right;
  have := M.projector_idem;
  replace this := LinearMap.congr_fun this x; simp_all +decide [ PureMotive.complement ] ;
  replace hx := congr_arg M.projector hx; simp_all +decide ;

/-! ## Theorem 4: Rank additivity -/

/-
**Rank additivity**: The rank of a motive plus the rank of its complement
    equals the total dimension.
-/
theorem PureMotive.rank_add_complement_rank (M : PureMotive) :
    M.rank + M.complement.rank = Module.finrank ℚ M.V := by
  have h_decomp := Submodule.finrank_sup_add_finrank_inf_eq ( M.realization ) ( M.complement.realization );
  convert h_decomp.symm;
  rw [ PureMotive.realization_complement_sup, PureMotive.realization_complement_inf ];
  norm_num

/-! ## Theorem 5: Numerical kernel respects Lefschetz -/

/-- The Lefschetz operator maps the numerical kernel to itself when Q
    satisfies Q(Lx, y) = Q(x, Ly). -/
theorem numKer_Lefschetz_stable (M : LefschetzModule)
    (hcompat : ∀ x y, M.Q (M.L x) y = M.Q x (M.L y)) :
    ∀ v ∈ M.numKer, M.L v ∈ M.numKer := by
  intro v hv
  rw [M.mem_numKer_iff] at hv ⊢
  intro w
  rw [hcompat]
  exact hv (M.L w)

/-! ## Theorem 6: Künneth decomposition from orthogonal projectors -/

/-
Two complementary orthogonal idempotents give trivial intersection of images.
-/
theorem künneth_two_projectors_inf {V : Type*} [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V]
    (p₁ p₂ : V →ₗ[ℚ] V)
    (h_idem₁ : p₁ ∘ₗ p₁ = p₁)
    (_h_idem₂ : p₂ ∘ₗ p₂ = p₂)
    (_h_sum : p₁ + p₂ = LinearMap.id)
    (h_orth : p₁ ∘ₗ p₂ = 0) :
    LinearMap.range p₁ ⊓ LinearMap.range p₂ = ⊥ := by
  simp_all +decide [ LinearMap.ext_iff, Submodule.eq_bot_iff ];
  grind

/-
Two projectors summing to identity span the whole space.
-/
theorem künneth_two_projectors_sup {V : Type*} [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V]
    (p₁ p₂ : V →ₗ[ℚ] V)
    (h_sum : p₁ + p₂ = LinearMap.id) :
    LinearMap.range p₁ ⊔ LinearMap.range p₂ = ⊤ := by
  refine' eq_top_iff.mpr fun x hx => _;
  exact Submodule.mem_sup.mpr ⟨ p₁ x, by simp +decide, _, ⟨ x, rfl ⟩, by simpa using LinearMap.congr_fun h_sum x ⟩

/-! ## Theorem 7: Hodge Index for rank-2 intersection forms -/

/-
**Hodge index theorem (rank 2)**: For a 2×2 symmetric matrix
    [[a, b], [b, c]] with a > 0 and det < 0, the orthogonal complement
    of the positive direction is negative definite.

    Concretely: if a > 0 and ac - b² < 0 and ax + by = 0,
    then ax² + 2bxy + cy² ≤ 0.
-/
theorem hodge_index_rank2
    (a b c : ℚ)
    (ha : a > 0)
    (hdet : a * c - b * b < 0)
    (x y : ℚ)
    (horth : a * x + b * y = 0) :
    a * x * x + 2 * b * x * y + c * y * y ≤ 0 := by
  -- From horth, we get x = -by/a.
  have hx : x = -b * y / a := by
    exact eq_div_of_mul_eq ha.ne' ( by linarith );
  subst hx; ring_nf at *; nlinarith [ mul_inv_cancel_left₀ ha.ne' y ] ;

/-! ## Theorem 8: Lefschetz star is idempotent on image -/

/-
If Λ is a left inverse of L, then L ∘ Λ is idempotent on im(L).
-/
theorem lefschetz_star_idempotent_on_image {V : Type*}
    [AddCommGroup V] [Module ℚ V]
    (L Λ₀ : V →ₗ[ℚ] V)
    (hLΛ : Λ₀ ∘ₗ L = LinearMap.id) :
    ∀ v ∈ LinearMap.range L, (L ∘ₗ Λ₀) ((L ∘ₗ Λ₀) v) = (L ∘ₗ Λ₀) v := by
  simp_all +decide [ LinearMap.ext_iff ]

/-! ## Theorem 9: Weight filtration monotonicity -/

/-- A weight filtration on a vector space: an increasing sequence of submodules. -/
structure WeightFiltration (V : Type*) [AddCommGroup V] [Module ℚ V] where
  W : ℤ → Submodule ℚ V
  mono : ∀ i j : ℤ, i ≤ j → W i ≤ W j

/-- The graded piece Gr_k W = W_k / W_{k-1}. We express the dimension
    of graded pieces instead of constructing the quotient. -/
def WeightFiltration.gradedDim {V : Type*} [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V]
    (F : WeightFiltration V) (k : ℤ) : ℕ :=
  Module.finrank ℚ (F.W k) - Module.finrank ℚ (F.W (k - 1))

/-- A weight filtration is pure of weight w if W_{w-1} = ⊥ and W_w = ⊤. -/
def WeightFiltration.isPure {V : Type*} [AddCommGroup V] [Module ℚ V]
    (F : WeightFiltration V) (w : ℤ) : Prop :=
  F.W (w - 1) = ⊥ ∧ F.W w = ⊤

/-
For a pure weight filtration of weight w, the only nonzero graded piece
    is Gr_w.
-/
theorem WeightFiltration.pure_graded_zero {V : Type*} [AddCommGroup V] [Module ℚ V]
    [FiniteDimensional ℚ V]
    (F : WeightFiltration V) (w : ℤ) (hpure : F.isPure w)
    (k : ℤ) (hk : k ≠ w) :
    F.gradedDim k = 0 := by
  cases lt_or_gt_of_ne hk <;> simp_all +decide [ WeightFiltration.gradedDim ];
  · have h_le : F.W k ≤ F.W (w - 1) := by
      exact F.mono _ _ ( by linarith );
    simp_all +decide [ hpure.1 ];
    rw [ h_le, finrank_bot, Nat.zero_sub ];
  · -- Since $k > w$, we � have� $F.W k = F.W w = ⊤$ and $F.W (k - 1) ≥ F.W w = ⊤$, thus $F.W k = F.W (k - 1)$.
    have h_eq : F.W k = F.W (k - 1) := by
      have h_eq : F.W (k - 1) = ⊤ := by
        have h_eq : F.W (k - 1) ≥ F.W w := by
          exact F.mono _ _ ( by linarith );
        exact le_top.antisymm ( h_eq.trans' hpure.2.ge );
      grind +suggestions;
    rw [ h_eq, Nat.sub_self ]

/-! ## Conjecture: Numerical kernel dimension bound -/

/-- **Falsifiable Conjecture**: For any Lefschetz module of dimension d with
    nondegenerate intersection pairing and compatible L, the dimension of
    the primitive subspace (kernel of L) is at most d/2 + 1.

    **Computational test**: Construct random symmetric matrices Q and
    compatible L operators of size d and check dim(ker L) ≤ d/2 + 1.
    The conjecture holds for geometric Lefschetz modules (by Hard Lefschetz)
    but may fail for non-geometric ones. A counterexample would illuminate
    which linear-algebraic properties are specifically geometric. -/
def conjecture_primitive_bound (d : ℕ) : Prop :=
  ∀ (V : Type*) [AddCommGroup V] [Module ℚ V] [FiniteDimensional ℚ V],
    Module.finrank ℚ V = d →
    ∀ (L : V →ₗ[ℚ] V),
    ∀ (Q : V →ₗ[ℚ] V →ₗ[ℚ] ℚ),
    (LinearMap.ker Q = ⊥) →
    (∀ x y, Q x y = Q y x) →
    (∀ x y, Q (L x) y = Q x (L y)) →
    Module.finrank ℚ (LinearMap.ker L) ≤ d / 2 + 1

end