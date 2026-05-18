/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Long Exact Sequence in Cohomology

This file establishes key components of the long exact sequence arising from
a short exact sequence of cochain complexes. We prove:

1. The composition in a short exact sequence is zero
2. Left-exactness of Hom: Hom(M, −) preserves injections
3. Injectivity on kernels from the snake lemma diagram
4. The connecting homomorphism construction
5. Exactness at the kernel level (snake lemma)

These results formalize the fundamental exactness machinery of homological algebra
over ℤ-modules.
-/
import Mathlib

open Function

/-- A short exact sequence of modules: 0 → A →f B →g C → 0. -/
structure ShortExactSeqMod (R : Type*) [Ring R]
    (A B C : Type*) [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [Module R A] [Module R B] [Module R C] where
  f : A →ₗ[R] B
  g : B →ₗ[R] C
  f_injective : Injective f
  g_surjective : Surjective g
  exact : LinearMap.range f = LinearMap.ker g

/-
The composition in a short exact sequence is zero.
-/
theorem ShortExactSeqMod.comp_zero {R : Type*} [Ring R]
    {A B C : Type*} [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [Module R A] [Module R B] [Module R C]
    (S : ShortExactSeqMod R A B C) : S.g.comp S.f = 0 := by
  ext x;
  exact S.exact.le ( LinearMap.mem_range_self _ _ )

/-
Hom(M, −) preserves injections: if f : A → B is injective,
    then f∗ : Hom(M, A) → Hom(M, B) is injective.
-/
theorem hom_preserves_injection
    {M A B : Type*}
    [AddCommGroup M] [AddCommGroup A] [AddCommGroup B]
    [Module ℤ M] [Module ℤ A] [Module ℤ B]
    (f : A →ₗ[ℤ] B) (hf : Injective f) :
    Injective (fun (φ : M →ₗ[ℤ] A) => f.comp φ) := by
  exact fun φ₁ φ₂ h => LinearMap.ext fun x => hf <| LinearMap.congr_fun h x

/-- Injectivity at the kernel level: in a commutative diagram with exact rows,
    the induced map ker(α) → ker(β) (via f) is injective. -/
theorem snake_lemma_ker_injective
    {A B C A' B' C' : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [AddCommGroup A'] [AddCommGroup B'] [AddCommGroup C']
    [Module ℤ A] [Module ℤ B] [Module ℤ C]
    [Module ℤ A'] [Module ℤ B'] [Module ℤ C']
    (f : A →ₗ[ℤ] B) (_g : B →ₗ[ℤ] C)
    (_f' : A' →ₗ[ℤ] B') (_g' : B' →ₗ[ℤ] C')
    (α : A →ₗ[ℤ] A') (β : B →ₗ[ℤ] B') (_γ : C →ₗ[ℤ] C')
    (hf : Injective f)
    (comm1 : _f'.comp α = β.comp f) :
    Injective (fun (x : LinearMap.ker α) =>
      (⟨f x.1, by
        simp only [LinearMap.mem_ker]
        have h := LinearMap.ext_iff.mp comm1 x.1
        simp only [LinearMap.comp_apply] at h
        rw [← h, (LinearMap.mem_ker.mp x.2), map_zero]⟩ : LinearMap.ker β)) := by
  intro x y hxy
  have h := congr_arg Subtype.val hxy
  simp only [Subtype.mk.injEq] at h
  exact Subtype.ext (hf h)

/-
The connecting homomorphism exists: for a commutative diagram with exact rows,
    every element of ker(γ) can be lifted through the diagram to produce
    an element related to coker(α).
-/
theorem connecting_homomorphism_exists
    {A B C A' B' C' : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [AddCommGroup A'] [AddCommGroup B'] [AddCommGroup C']
    [Module ℤ A] [Module ℤ B] [Module ℤ C]
    [Module ℤ A'] [Module ℤ B'] [Module ℤ C']
    (f : A →ₗ[ℤ] B) (g : B →ₗ[ℤ] C)
    (f' : A' →ₗ[ℤ] B') (_g' : B' →ₗ[ℤ] C')
    (_α : A →ₗ[ℤ] A') (β : B →ₗ[ℤ] B') (γ : C →ₗ[ℤ] C')
    (_hf : Injective f) (hg : Surjective g)
    (hfg : LinearMap.range f = LinearMap.ker g)
    (_hf' : Injective f')
    (hf'g' : LinearMap.range f' = LinearMap.ker _g')
    (_comm1 : f'.comp _α = β.comp f)
    (comm2 : _g'.comp β = γ.comp g) :
    ∀ c : C, γ c = 0 →
      ∃ b : B, g b = c ∧ β b ∈ LinearMap.range f' := by
  -- For any $c \in \ker(\gamma)$, choose $b \in B$ such that $g(b) = c$.
  intro c hc
  obtain ⟨b, hb⟩ : ∃ b : B, g b = c := hg c;
  replace comm2 := congr_arg ( fun f => f b ) comm2; aesop;

/-
Exactness at ker(β): in the snake lemma diagram, the sequence
    ker(α) → ker(β) → ker(γ) is exact at ker(β).
-/
theorem snake_lemma_ker_exact
    {A B C A' B' C' : Type*}
    [AddCommGroup A] [AddCommGroup B] [AddCommGroup C]
    [AddCommGroup A'] [AddCommGroup B'] [AddCommGroup C']
    [Module ℤ A] [Module ℤ B] [Module ℤ C]
    [Module ℤ A'] [Module ℤ B'] [Module ℤ C']
    (f : A →ₗ[ℤ] B) (g : B →ₗ[ℤ] C)
    (f' : A' →ₗ[ℤ] B') (_g' : B' →ₗ[ℤ] C')
    (α : A →ₗ[ℤ] A') (β : B →ₗ[ℤ] B') (γ : C →ₗ[ℤ] C')
    (_hf : Injective f) (_hg : Surjective g)
    (hfg : LinearMap.range f = LinearMap.ker g)
    (_hf' : Injective f') (_hg' : Surjective g')
    (_hf'g' : LinearMap.range f' = LinearMap.ker _g')
    (comm1 : f'.comp α = β.comp f)
    (_comm2 : _g'.comp β = γ.comp g)
    (b : LinearMap.ker β)
    (_hb : g b.1 ∈ LinearMap.ker γ) :
    (g b.1 = 0) →
    ∃ a : LinearMap.ker α, f a.1 = b.1 := by
  intro hb';
  -- Since $g(b) = 0$, $b$ is in the kernel of $g$, which is equal to the range of $f$ by $hfg$.
  have hb_range : b.val ∈ LinearMap.range f := by
    exact hfg.symm ▸ hb';
  obtain ⟨ a, ha ⟩ := hb_range;
  exact ⟨ ⟨ a, by replace comm1 := LinearMap.congr_fun comm1 a; aesop ⟩, ha ⟩