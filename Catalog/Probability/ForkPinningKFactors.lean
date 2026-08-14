/-
# The which-factor wall for a product of `k` primes

`ForkPinningSemiprimeGeneral` proves that for a semiprime `N = p q` the class of `N` in a finite
group `G` is *exactly* independent of every statistic of the first factor.  This file closes the
"wall" half of conjecture **C7** of `FUTURE_DIRECTIONS.md`: the same is true for a product of
arbitrarily many primes, and in the strongest possible form.

The key structural fact is that the class map is a group homomorphism with *uniform fibres in the
last coordinate*: whatever the classes of the first `k` primes are, the class of the last one is
free, so the class of the product is uniform **conditionally on everything else**.  We isolate
this as `ForkPinning.last_factor_wall`, which is stated for an arbitrary aggregate
`h : Ω → G` of the other factors, and then instantiate it at `Ω = Fin k → G`.

Main results:

* `ForkPinning.mutualInfo_congr_equiv` : mutual information is invariant under a relabelling of
  the sample space (a reusable transport lemma).
* `ForkPinning.prb_lastMul_uniform` : the class of the product is exactly uniform.
* `ForkPinning.last_factor_wall` : `I( h(u)·v ; F(u) ) = 0` for every aggregate `h` and every
  statistic `F` of the remaining data — the wall in its general form.
* `ForkPinning.kfactor_wall` : for `N = p₁ ⋯ p_{k+1}` with independent uniform classes, the class
  of `N` carries **exactly zero** information about any statistic of `p₁, …, p_k`.
* `ForkPinning.kfactor_wall_which_splits` : in particular it says nothing about *which* of the
  first `k` primes split, and `kfactor_class_uniform` : the class of `N` is uniform, so it says
  nothing at all in isolation either.
-/

import Probability.ForkPinningSemiprimeGeneral

namespace ForkPinning

open Finset Real

/-! ## Transport of the information functionals along a relabelling of the sample space -/

section Transport

variable {Ω Ω' : Type*} [Fintype Ω] [Nonempty Ω] [DecidableEq Ω]
variable [Fintype Ω'] [Nonempty Ω'] [DecidableEq Ω']
variable {κ β : Type*} [Fintype κ] [DecidableEq κ] [Fintype β] [DecidableEq β]

omit [Nonempty Ω] [DecidableEq Ω] [Nonempty Ω'] [Fintype κ] in
lemma fiber_congr_equiv (e : Ω' ≃ Ω) (X : Ω → κ) (k : κ) :
    fiber (fun w => X (e w)) k = (fiber X k).image e.symm := by
  ext w
  simp only [fiber, mem_filter, mem_univ, true_and, mem_image]
  constructor
  · intro hw
    exact ⟨e w, by simpa [fiber] using hw, e.symm_apply_apply w⟩
  · rintro ⟨a, ha, rfl⟩
    simpa [fiber] using ha

omit [Nonempty Ω] [DecidableEq Ω] [Nonempty Ω'] [Fintype κ] in
lemma prb_congr_equiv (e : Ω' ≃ Ω) (X : Ω → κ) (k : κ) :
    prb (fun w => X (e w)) k = prb X k := by
  have hcard : Fintype.card Ω' = Fintype.card Ω := Fintype.card_congr e
  rw [prb, prb, fiber_congr_equiv e X k,
    Finset.card_image_of_injective _ e.symm.injective, hcard]

omit [Nonempty Ω] [DecidableEq Ω] [Nonempty Ω'] in
lemma H_congr_equiv (e : Ω' ≃ Ω) (X : Ω → κ) : H (fun w => X (e w)) = H X := by
  simp only [H, prb_congr_equiv e X]

omit [Nonempty Ω] [DecidableEq Ω] [Nonempty Ω'] in
/-- **Mutual information is a relabelling invariant.**  Renaming the sample space by a bijection
changes neither entropy nor mutual information. -/
theorem mutualInfo_congr_equiv (e : Ω' ≃ Ω) (X : Ω → κ) (Y : Ω → β) :
    mutualInfo (fun w => X (e w)) (fun w => Y (e w)) = mutualInfo X Y := by
  have hjoint : joint (fun w => X (e w)) (fun w => Y (e w)) = fun w => (joint X Y) (e w) := rfl
  rw [mutualInfo, mutualInfo, H_congr_equiv e X, H_congr_equiv e Y, hjoint,
    H_congr_equiv e (joint X Y)]

end Transport

/-! ## The wall in its general form -/

section Wall

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω] [DecidableEq Ω]
variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]
variable {β : Type*} [Fintype β] [DecidableEq β]

omit [Nonempty Ω] in
/-- The fibre of the "aggregate times a free last factor" map over `s` is a graph over `Ω`. -/
lemma fiber_lastMul (h : Ω → G) (s : G) :
    fiber (fun x : Ω × G => h x.1 * x.2) s = univ.image (fun a : Ω => (a, (h a)⁻¹ * s)) := by
  ext ⟨a, b⟩
  simp only [fiber, mem_filter, mem_univ, true_and, mem_image, Prod.mk.injEq]
  constructor
  · intro hab
    exact ⟨a, rfl, by rw [← hab]; group⟩
  · rintro ⟨c, rfl, rfl⟩
    group

omit [Nonempty Ω] [Fintype β] in
/-- The joint fibre is a graph over a fibre of the statistic. -/
lemma fiber_joint_lastMul (h : Ω → G) (F : Ω → β) (s : G) (v : β) :
    fiber (joint (fun x : Ω × G => h x.1 * x.2) (fun x : Ω × G => F x.1)) (s, v)
      = (fiber F v).image (fun a : Ω => (a, (h a)⁻¹ * s)) := by
  ext ⟨a, b⟩
  simp only [fiber, mem_filter, mem_univ, true_and, joint, mem_image, Prod.mk.injEq]
  constructor
  · rintro ⟨hab, hFa⟩
    exact ⟨a, by simpa [fiber] using hFa, rfl, by rw [← hab]; group⟩
  · rintro ⟨c, hc, rfl, rfl⟩
    refine ⟨by group, ?_⟩
    simpa [fiber] using hc

/-- **The class of the product is exactly uniform**, whatever the aggregate of the other
factors is. -/
lemma prb_lastMul_uniform (h : Ω → G) (s : G) :
    prb (fun x : Ω × G => h x.1 * x.2) s = 1 / Fintype.card G := by
  have hΩ : (0 : ℝ) < Fintype.card Ω := by
    exact_mod_cast Fintype.card_pos
  have hG : (0 : ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos
  have hinj : Function.Injective (fun a : Ω => (a, (h a)⁻¹ * s)) :=
    fun a a' haa => congrArg Prod.fst haa
  rw [prb, fiber_lastMul h s, Finset.card_image_of_injective _ hinj]
  simp only [Finset.card_univ, Fintype.card_prod, Nat.cast_mul]
  field_simp

/-- **The which-factor wall, general form.**  For a uniformly random pair `(u, v)` in `Ω × G`,
the "class of the product" `h(u)·v` is exactly independent of *every* statistic `F(u)` of the
remaining data: the free last factor destroys all information. -/
theorem last_factor_wall (h : Ω → G) (F : Ω → β) :
    mutualInfo (fun x : Ω × G => h x.1 * x.2) (fun x : Ω × G => F x.1) = 0 := by
  have hΩ : (0 : ℝ) < Fintype.card Ω := by
    exact_mod_cast Fintype.card_pos
  have hG : (0 : ℝ) < Fintype.card G := by
    exact_mod_cast Fintype.card_pos
  refine mutualInfo_eq_zero_of_indep _ _ (fun s v => ?_)
  have hcard : (fiber (joint (fun x : Ω × G => h x.1 * x.2) (fun x : Ω × G => F x.1)) (s, v)).card
      = (fiber F v).card := by
    rw [fiber_joint_lastMul h F s v,
      Finset.card_image_of_injective _ (fun a a' haa => congrArg Prod.fst haa)]
  rw [prb, hcard, prb_lastMul_uniform h s, prb_fst F v, prb]
  simp only [Fintype.card_prod, Nat.cast_mul]
  field_simp

end Wall

/-! ## `k`-fold products -/

section KFactors

variable {G : Type*} [Group G] [Fintype G] [Nonempty G] [DecidableEq G]
variable {β : Type*} [Fintype β] [DecidableEq β]

/-- The product of a vector of group elements, taken in index order. -/
def vecProd {H : Type*} [Group H] {k : ℕ} (v : Fin k → H) : H := (List.ofFn v).prod

omit [Fintype G] [Nonempty G] [DecidableEq G] in
/-- Appending a factor at the end multiplies the product on the right. -/
lemma vecProd_snoc {k : ℕ} (u : Fin k → G) (g : G) :
    vecProd (Fin.snoc u g) = vecProd u * g := by
  rw [vecProd, vecProd, List.ofFn_succ']
  simp [List.concat_eq_append, Fin.snoc_castSucc, Fin.snoc_last]

/-- Splitting off the last coordinate of a vector of classes. -/
def snocEquiv (k : ℕ) (G : Type*) : (Fin k → G) × G ≃ (Fin (k + 1) → G) where
  toFun p := Fin.snoc p.1 p.2
  invFun v := (fun i => v i.castSucc, v (Fin.last k))
  left_inv p := by
    refine Prod.ext ?_ ?_
    · funext i; simp
    · simp
  right_inv v := by
    funext i
    refine Fin.lastCases ?_ ?_ i
    · simp
    · intro j; simp

/-- **C7, the wall half.**  For `N = p₁ ⋯ p_{k+1}` with independent uniform Frobenius classes,
the class of `N` carries **exactly zero** information about any statistic of the first `k`
factors.  No amount of factor structure leaks which prime is which. -/
theorem kfactor_wall {k : ℕ} (F : (Fin k → G) → β) :
    mutualInfo (fun v : Fin (k + 1) → G => vecProd v)
      (fun v : Fin (k + 1) → G => F (fun i => v i.castSucc)) = 0 := by
  have hEq : mutualInfo (fun p : (Fin k → G) × G => vecProd ((snocEquiv k G) p))
      (fun p : (Fin k → G) × G => F (fun i => ((snocEquiv k G) p) i.castSucc))
      = mutualInfo (fun v : Fin (k + 1) → G => vecProd v)
        (fun v : Fin (k + 1) → G => F (fun i => v i.castSucc)) :=
    mutualInfo_congr_equiv (snocEquiv k G) (fun v : Fin (k + 1) → G => vecProd v)
      (fun v : Fin (k + 1) → G => F (fun i => v i.castSucc))
  rw [← hEq]
  have h1 : (fun p : (Fin k → G) × G => vecProd ((snocEquiv k G) p))
      = fun p : (Fin k → G) × G => vecProd p.1 * p.2 := by
    funext p
    show vecProd (Fin.snoc p.1 p.2) = vecProd p.1 * p.2
    exact vecProd_snoc p.1 p.2
  have h2 : (fun p : (Fin k → G) × G => F (fun i => ((snocEquiv k G) p) i.castSucc))
      = fun p : (Fin k → G) × G => F p.1 := by
    funext p
    show F (fun i => Fin.snoc (α := fun _ => G) p.1 p.2 i.castSucc) = F p.1
    congr 1
    funext i
    simp
  rw [h1, h2]
  exact last_factor_wall (fun u : Fin k → G => vecProd u) F

/-- In particular the class of the product says nothing about *which* of the first `k` primes
split. -/
theorem kfactor_wall_which_splits {k : ℕ} :
    mutualInfo (fun v : Fin (k + 1) → G => vecProd v)
      (fun v : Fin (k + 1) → G => decide (∃ i : Fin k, v i.castSucc = 1)) = 0 :=
  kfactor_wall (fun u : Fin k → G => decide (∃ i, u i = 1))

/-- And the class of the product is itself exactly uniform. -/
theorem kfactor_class_uniform {k : ℕ} (s : G) :
    prb (fun p : (Fin k → G) × G => vecProd p.1 * p.2) s = 1 / Fintype.card G :=
  prb_lastMul_uniform (fun u : Fin k → G => vecProd u) s

end KFactors

end ForkPinning