/-! # CatalogBuild.Computation.Oracles.SpectralCollapse

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.SpectralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem spectral_collapse_sq {T : V →ₗ[K] V} (hT : T ∘ₗ T = T)
    {v : V} {mu : K} (hv : v ≠ 0) (heig : T v = mu • v) :
    mu ^ 2 = mu := by
      apply_fun ( fun x => x v ) at hT;
      simp_all +decide [ sq, smul_smul ]





/-- [Section: # CatalogBuild.Computation.Oracles.SpectralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem spectral_collapse_eigenvalue {T : V →ₗ[K] V} (hT : T ∘ₗ T = T)
    {v : V} {mu : K} (hv : v ≠ 0) (heig : T v = mu • v) :
    mu = 0 ∨ mu = 1 := by
      by_contra! h;
      have i := congr_arg ( fun f => f v ) hT; simp_all +decide [ funext_iff, LinearMap.ext_iff ] ;
      exact h.2 ( smul_left_injective _ hv <| by simpa [ h.1 ] using i )





/-- [Section: # CatalogBuild.Computation.Oracles.SpectralCollapse
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 12] -/
theorem idempotent_ker_eigenspace {T : V →ₗ[K] V} (hT : T ∘ₗ T = T) (v : V) :
    v ∈ LinearMap.ker T ↔ T v = (0 : K) • v := by
      simp +zetaDelta at *





theorem idempotent_range_eigenspace {T : V →ₗ[K] V} (hT : T ∘ₗ T = T) (v : V) :
    v ∈ LinearMap.range T ↔ T v = (1 : K) • v := by
      simp +zetaDelta at *;
      exact ⟨ fun ⟨ y, hy ⟩ => by simp [ ← hy, ← LinearMap.comp_apply, hT ], fun h => ⟨ v, h ⟩ ⟩





theorem complementary_idempotent {T : V →ₗ[K] V} (hT : T ∘ₗ T = T) :
    (LinearMap.id - T) ∘ₗ (LinearMap.id - T) = LinearMap.id - T := by
      simp_all +decide [ sub_mul, mul_sub, LinearMap.ext_iff ]





theorem idempotent_range_ker_complement {T : V →ₗ[K] V} (hT : T ∘ₗ T = T) :
    LinearMap.range T ⊓ LinearMap.ker T = ⊥ := by
      simp +decide [ Submodule.eq_bot_iff ];
      simp_all +decide [ LinearMap.ext_iff ]





theorem idempotent_complement_range_eq_ker {T : V →ₗ[K] V} (hT : T ∘ₗ T = T) :
    LinearMap.range (LinearMap.id - T) = LinearMap.ker T := by
      ext v;
      simp_all +decide [ Eq, LinearMap.ext_iff ];
      grind +locals





/-- An idempotent matrix satisfies M² = M. -/
def Matrix.IsIdempotent (M : Matrix n n K) : Prop := M * M = M





/-- Trace is preserved: tr(M) = tr(M²) for idempotent M. -/
theorem idempotent_trace_sq (M : Matrix n n K) (hM : M.IsIdempotent) :
    M.trace = (M * M).trace := by
  rw [hM]





theorem idempotent_det_sq (M : Matrix n n K) (hM : M.IsIdempotent) :
    M.det ^ 2 = M.det := by
      rw [ sq, ← Matrix.det_mul, hM ]





theorem idempotent_det_zero_or_one (M : Matrix n n K) (hM : M.IsIdempotent) :
    M.det = 0 ∨ M.det = 1 := by
      -- From the lemma `idempotent_det_sq`, we know that det(M)^2 = det(M).
      have h_det_sq : M.det ^ 2 = M.det := by
        exact?;
      grobner





theorem iterate_to_idempotent {T : V →ₗ[K] V} {m : ℕ} (hm : 1 ≤ m)
    (hT : T ^ (m + 1) = T) :
    (T ^ m) ∘ₗ (T ^ m) = T ^ m := by
      -- From $T^{m+1} = T$, we get $T^{m+k} = T^k$ for $k \geq 1$ by induction.
      have h_ind : ∀ k ≥ 1, T ^ (m + k) = T ^ k := by
        intro k hk; induction hk <;> simp_all +decide [ pow_succ, ← mul_assoc ] ;
        simp_all +decide [ ← add_assoc, pow_add ];
      simpa [ pow_add ] using h_ind m hm





end
