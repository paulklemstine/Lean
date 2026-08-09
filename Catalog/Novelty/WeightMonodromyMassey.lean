/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Novelty.WeightMonodromyFormality

/-!
# Massey products, purity and the obstruction to weight-monodromy

Companion to `Catalog/Novelty/WeightMonodromyFormality.lean`.

Two complementary results are proved.

* `massey_zero_of_formality` : in any strictly formal dg-algebra (i.e. one admitting a
  `StrictFormalityData`) every triple Massey product which is defined contains `0`.  The
  mechanism is that the primitives can be chosen inside the acyclic ideal, which is absorbing.

* `massey_zero_of_weightPure` : the same conclusion directly from purity of the weight grading,
  by a *weight* argument: a Massey representative of cohomological degree `p + q + r - 1`
  necessarily has weight `p + q + r`, and purity kills everything off the diagonal.
  The primitives are moreover produced explicitly as bihomogeneous components.

* `not_weightPure_of_massey` : contrapositive.  A space whose cohomology algebra carries a
  genuinely non-vanishing triple Massey product cannot have a pure weight grading; this is the
  algebraic shadow of the non-formal rigid-analytic surfaces, which are therefore obstructions
  to the naive weight-monodromy purity in the corresponding dg-algebra model.
-/

namespace WeightMonodromy

variable {k A : Type*} [Field k] [Ring A] [Algebra k A]
variable {𝒜 : ℤ × ℤ → Submodule k A} [GradedAlgebra 𝒜] {D : WeightedDGA 𝒜}

/-- **Formality kills triple Massey products.**  If `(A, d)` admits a strict formality zig-zag
`A ⊇ sub ↠ sub/idl`, then for cocycles `x, y, z` (with `x, z` in the model `sub`) such that
`x * y` and `y * z` bound, one can choose primitives `u, v` for which the Massey representative
`s • (u * z) - x * v` bounds as well: the Massey product `⟨x, y, z⟩` contains `0`.

The hypothesis `hcocycle` records that the Massey representative is a cocycle; in the graded
situation of `massey_zero_of_weightPure` this is a consequence of the Leibniz rule. -/
theorem massey_zero_of_formality (F : StrictFormalityData D) {x y z : A}
    (hx : x ∈ F.sub) (hz : z ∈ F.sub)
    (hxy_sub : x * y ∈ F.sub) (hyz_sub : y * z ∈ F.sub)
    (hxy_d : D.d (x * y) = 0) (hyz_d : D.d (y * z) = 0)
    (hxy_ex : ∃ c, x * y = D.d c) (hyz_ex : ∃ c, y * z = D.d c) (s : k)
    (hcocycle : ∀ u v : A, D.d u = x * y → D.d v = y * z →
      D.d (s • (u * z) - x * v) = 0) :
    ∃ u v w : A, D.d u = x * y ∧ D.d v = y * z ∧ s • (u * z) - x * v = D.d w := by
  -- the primitives can be chosen inside the acyclic ideal
  have hxy_idl : x * y ∈ F.idl := (F.exact_iff_mem_idl _ hxy_sub hxy_d).mp hxy_ex
  have hyz_idl : y * z ∈ F.idl := (F.exact_iff_mem_idl _ hyz_sub hyz_d).mp hyz_ex
  obtain ⟨u, hu, hdu⟩ := F.idl_acyclic _ hxy_idl hxy_d
  obtain ⟨v, hv, hdv⟩ := F.idl_acyclic _ hyz_idl hyz_d
  -- the Massey representative lies in the ideal, hence bounds
  have hm : s • (u * z) - x * v ∈ F.idl :=
    Submodule.sub_mem _ (Submodule.smul_mem _ _ (F.idl_mul u hu z hz))
      (F.mul_idl x hx v hv)
  have hmd : D.d (s • (u * z) - x * v) = 0 := hcocycle u v hdu.symm hdv.symm
  obtain ⟨w, -, hw⟩ := F.idl_acyclic _ hm hmd
  exact ⟨u, v, w, hdu.symm, hdv.symm, hw⟩

section Pure

variable (D)

/-- **Purity kills triple Massey products.**  Let `x, y, z` be bihomogeneous cocycles on the
diagonal (degree = weight, the shape imposed by weight-monodromy), with `x * y` and `y * z`
exact.  If the weight grading is pure then there are primitives `u` of `x * y` and `v` of
`y * z` for which the Massey representative `sgn p • (u * z) - x * v` is exact.

The proof is a pure weight count: choosing `u` and `v` bihomogeneous, the representative has
cohomological degree `p + q + r - 1` but weight `p + q + r`, and purity forces every cocycle
off the diagonal to be a coboundary. -/
theorem massey_zero_of_weightPure (hpure : IsWeightPure D) {p q r : ℤ} {x y z : A}
    (hx : x ∈ 𝒜 (p, p)) (hy : y ∈ 𝒜 (q, q)) (hz : z ∈ 𝒜 (r, r))
    (hdx : D.d x = 0) (hdz : D.d z = 0)
    {u₀ v₀ : A} (hu₀ : D.d u₀ = x * y) (hv₀ : D.d v₀ = y * z) :
    ∃ u v c : A, D.d u = x * y ∧ D.d v = y * z ∧
      D.sgn p • (u * z) - x * v = D.d c := by
  have hxy : x * y ∈ 𝒜 (p + q, p + q) := by
    have := SetLike.mul_mem_graded hx hy
    simpa [Prod.mk_add_mk] using this
  have hyz : y * z ∈ 𝒜 (q + r, q + r) := by
    have := SetLike.mul_mem_graded hy hz
    simpa [Prod.mk_add_mk] using this
  -- bihomogeneous primitives
  set u := cmpL 𝒜 (p + q - 1, p + q) u₀ with hu_def
  set v := cmpL 𝒜 (q + r - 1, q + r) v₀ with hv_def
  have hu_mem : u ∈ 𝒜 (p + q - 1, p + q) := cmpL_mem 𝒜 u₀ _
  have hv_mem : v ∈ 𝒜 (q + r - 1, q + r) := cmpL_mem 𝒜 v₀ _
  have hdu : D.d u = x * y := by
    have h := D.cmpL_d u₀ (p + q - 1) (p + q)
    rw [show p + q - 1 + 1 = p + q from by ring] at h
    rw [hu_def, ← h, hu₀, cmpL_of_mem_same 𝒜 hxy]
  have hdv : D.d v = y * z := by
    have h := D.cmpL_d v₀ (q + r - 1) (q + r)
    rw [show q + r - 1 + 1 = q + r from by ring] at h
    rw [hv_def, ← h, hv₀, cmpL_of_mem_same 𝒜 hyz]
  -- the Massey representative, bihomogeneous of degree `p+q+r-1` and weight `p+q+r`
  have huz : u * z ∈ 𝒜 (p + q + r - 1, p + q + r) := by
    have := SetLike.mul_mem_graded hu_mem hz
    simpa [Prod.mk_add_mk, show p + q - 1 + r = p + q + r - 1 from by ring] using this
  have hxv : x * v ∈ 𝒜 (p + q + r - 1, p + q + r) := by
    have := SetLike.mul_mem_graded hx hv_mem
    simpa [Prod.mk_add_mk, show p + (q + r - 1) = p + q + r - 1 from by ring,
      show p + (q + r) = p + q + r from by ring] using this
  have hm_mem : D.sgn p • (u * z) - x * v ∈ 𝒜 (p + q + r - 1, p + q + r) :=
    Submodule.sub_mem _ (Submodule.smul_mem _ _ huz) hxv
  -- it is a cocycle, by the Leibniz rule
  have hduz : D.d (u * z) = x * y * z := by
    rw [D.leibniz (p + q - 1) (p + q) u z hu_mem, hdu, hdz]
    simp
  have hdxv : D.d (x * v) = D.sgn p • (x * (y * z)) := by
    rw [D.leibniz p p x v hx, hdx, hdv]
    simp
  have hm_d : D.d (D.sgn p • (u * z) - x * v) = 0 := by
    rw [map_sub, map_smul, hduz, hdxv, mul_assoc, sub_self]
  -- purity: degree ≠ weight, so the class vanishes
  obtain ⟨c, -, hc⟩ := hpure (p + q + r - 1) (p + q + r) (by omega) _ hm_mem hm_d
  exact ⟨u, v, c, hdu, hdv, hc.symm⟩

/-- The bihomogeneous primitives produced above even lie in the acyclic ideal `idealDGA D`. -/
theorem massey_primitive_mem_idealDGA {p q : ℤ} {u₀ : A} :
    cmpL 𝒜 (p + q - 1, p + q) u₀ ∈ idealDGA D :=
  mem_idealDGA_of_lt D (by simp)
    (cmpL_mem 𝒜 u₀ (p + q - 1, p + q))

/-- **Obstruction to purity (hence to weight-monodromy) from non-formality.**  If some triple
Massey product of diagonal bihomogeneous cocycles is genuinely non-vanishing — no choice of
primitives makes the Massey representative exact — then the weight grading cannot be pure.

This is the algebraic form of the statement that the non-formal smooth proper rigid-analytic
surfaces of the paper do not admit a pure weight-graded model. -/
theorem not_weightPure_of_massey {p q r : ℤ} {x y z : A}
    (hx : x ∈ 𝒜 (p, p)) (hy : y ∈ 𝒜 (q, q)) (hz : z ∈ 𝒜 (r, r))
    (hdx : D.d x = 0) (hdz : D.d z = 0)
    {u₀ v₀ : A} (hu₀ : D.d u₀ = x * y) (hv₀ : D.d v₀ = y * z)
    (hnon : ∀ u v c : A, D.d u = x * y → D.d v = y * z →
      D.sgn p • (u * z) - x * v ≠ D.d c) :
    ¬ IsWeightPure D := by
  intro hpure
  obtain ⟨u, v, c, hdu, hdv, hc⟩ :=
    massey_zero_of_weightPure D hpure hx hy hz hdx hdz hu₀ hv₀
  exact hnon u v c hdu hdv hc

end Pure

end WeightMonodromy