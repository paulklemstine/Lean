/-
  # The Mega-Sphere: Inverse Limits of Sphere Towers

  This module constructs the "Mega-Sphere" — a single algebraic object whose
  projections recover data associated to spheres S⁰, S¹, S², ... of all dimensions.

  ## Mathematical Overview

  We define:
  1. `NatInverseSystem` / `NatInverseLimit`: Inverse systems and their limits
  2. `SphereSpectrum`: A novel structure encoding graded Euler-characteristic data
  3. `bernoulliSphereWeight`: Invariant connecting Bernoulli numbers to spheres
  4. `sphereCharPoly`: Characteristic polynomials encoding CW-structure

  The key insight is that χ(Sⁿ) = 1 + (-1)ⁿ and Bernoulli numbers both vanish
  on odd indices, creating an algebraic resonance captured by the Mega-Sphere.
-/

import Mathlib

open Polynomial

/-! ## Part 1: Inverse Systems and Limits -/

/-- An inverse system indexed by ℕ: a tower ⋯ → F(n+1) → F(n) → ⋯ → F(0). -/
structure NatInverseSystem (F : ℕ → Type*) where
  bond : ∀ n, F (n + 1) → F n

/-- The inverse limit: sequences compatible with all bonding maps. -/
def NatInverseLimit (F : ℕ → Type*) (S : NatInverseSystem F) : Type _ :=
  { f : ∀ n, F n // ∀ n, S.bond n (f (n + 1)) = f n }

namespace NatInverseLimit

variable {F : ℕ → Type*} {S : NatInverseSystem F}

/-- Projection to the n-th component. -/
def proj (x : NatInverseLimit F S) (n : ℕ) : F n := x.val n

/-- Projections commute with bonding maps. -/
theorem proj_bond_compat (x : NatInverseLimit F S) (n : ℕ) :
    S.bond n (x.proj (n + 1)) = x.proj n :=
  x.property n

/-- Universal lift: a compatible family factors through the limit. -/
def lift {X : Type*} (f : ∀ n, X → F n)
    (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x) :
    X → NatInverseLimit F S :=
  fun x => ⟨fun n => f n x, fun n => hf n x⟩

/-- The lift commutes with projections. -/
theorem lift_proj {X : Type*} (f : ∀ n, X → F n)
    (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x)
    (x : X) (n : ℕ) :
    (lift f hf x).proj n = f n x := rfl

/-- **Uniqueness**: any map commuting with all projections equals the lift. -/
theorem lift_unique {X : Type*} (g : X → NatInverseLimit F S)
    (f : ∀ n, X → F n) (hf : ∀ n x, S.bond n (f (n + 1) x) = f n x)
    (hg : ∀ n x, (g x).proj n = f n x) :
    ∀ x, g x = lift f hf x := by
  intro x; apply Subtype.ext; funext n; exact hg n x

/-- Extensionality for inverse limit elements. -/
@[ext]
theorem ext (x y : NatInverseLimit F S)
    (h : ∀ n, x.proj n = y.proj n) : x = y := by
  apply Subtype.ext; funext n; exact h n

end NatInverseLimit

/-! ## Part 2: Morphisms and Functoriality -/

/-- A morphism of inverse systems: level-wise maps commuting with bonds. -/
structure NatInverseSystemMorphism (F G : ℕ → Type*) (S : NatInverseSystem F)
    (T : NatInverseSystem G) where
  component : ∀ n, F n → G n
  compatible : ∀ n (x : F (n + 1)),
    T.bond n (component (n + 1) x) = component n (S.bond n x)

/-- Functoriality: a morphism induces a map on limits. -/
def NatInverseSystemMorphism.limitMap {F G : ℕ → Type*} {S : NatInverseSystem F}
    {T : NatInverseSystem G} (φ : NatInverseSystemMorphism F G S T) :
    NatInverseLimit F S → NatInverseLimit G T :=
  fun ⟨f, hf⟩ => ⟨fun n => φ.component n (f n), fun n => by
    rw [φ.compatible n (f (n + 1)), hf n]⟩

/-- The induced map commutes with projections. -/
theorem NatInverseSystemMorphism.limitMap_proj {F G : ℕ → Type*}
    {S : NatInverseSystem F} {T : NatInverseSystem G}
    (φ : NatInverseSystemMorphism F G S T) (x : NatInverseLimit F S) (n : ℕ) :
    (φ.limitMap x).proj n = φ.component n (x.proj n) := rfl

/-- The identity morphism. -/
def NatInverseSystemMorphism.id (F : ℕ → Type*) (S : NatInverseSystem F) :
    NatInverseSystemMorphism F F S S where
  component _ := _root_.id
  compatible _ _ := rfl

/-- The identity morphism induces the identity on limits. -/
theorem NatInverseSystemMorphism.limitMap_id {F : ℕ → Type*}
    {S : NatInverseSystem F} (x : NatInverseLimit F S) :
    (NatInverseSystemMorphism.id F S).limitMap x = x := by
  apply NatInverseLimit.ext; intro; rfl

/-- Composition of morphisms. -/
def NatInverseSystemMorphism.comp {F G H : ℕ → Type*}
    {S : NatInverseSystem F} {T : NatInverseSystem G} {U : NatInverseSystem H}
    (ψ : NatInverseSystemMorphism G H T U)
    (φ : NatInverseSystemMorphism F G S T) :
    NatInverseSystemMorphism F H S U where
  component n := ψ.component n ∘ φ.component n
  compatible n x := by
    simp [Function.comp]; rw [ψ.compatible, φ.compatible]

/-- Composition corresponds to composition of limit maps. -/
theorem NatInverseSystemMorphism.limitMap_comp {F G H : ℕ → Type*}
    {S : NatInverseSystem F} {T : NatInverseSystem G} {U : NatInverseSystem H}
    (ψ : NatInverseSystemMorphism G H T U)
    (φ : NatInverseSystemMorphism F G S T)
    (x : NatInverseLimit F S) :
    (ψ.comp φ).limitMap x = ψ.limitMap (φ.limitMap x) := by
  apply NatInverseLimit.ext; intro; rfl

/-! ## Part 3: Sphere Euler Characteristic -/

/-- χ(Sⁿ) = 1 + (-1)ⁿ. -/
def sphereEulerChar (n : ℕ) : ℤ := 1 + (-1) ^ n

@[simp] theorem sphereEulerChar_zero : sphereEulerChar 0 = 2 := by
  simp [sphereEulerChar]

@[simp] theorem sphereEulerChar_one : sphereEulerChar 1 = 0 := by
  decide

/-- Even-dimensional spheres have χ = 2. -/
theorem sphereEulerChar_even (k : ℕ) : sphereEulerChar (2 * k) = 2 := by
  unfold sphereEulerChar
  have : (-1 : ℤ) ^ (2 * k) = 1 := by rw [pow_mul]; simp
  linarith

/-- Odd-dimensional spheres have χ = 0. -/
theorem sphereEulerChar_odd (k : ℕ) : sphereEulerChar (2 * k + 1) = 0 := by
  unfold sphereEulerChar
  have : (-1 : ℤ) ^ (2 * k + 1) = -1 := by rw [pow_add, pow_mul]; simp
  linarith

/-- Recurrence: χ(Sⁿ⁺¹) = 2 - χ(Sⁿ). -/
theorem sphereEulerChar_recurrence (n : ℕ) :
    sphereEulerChar (n + 1) = 2 - sphereEulerChar n := by
  simp [sphereEulerChar, pow_succ]; ring

/-
The sum Σ_{i<2k+1} χ(Sⁱ) = 2k+2.
-/
theorem sphereEulerChar_partial_sum (k : ℕ) :
    ∑ i ∈ Finset.range (2 * k + 1), sphereEulerChar i = 2 * (↑k : ℤ) + 2 := by
  induction k <;> simp_all +decide [ Finset.sum_range_succ, Nat.mul_succ ];
  simp_all +decide [ sphereEulerChar ] ; ring

/-! ## Part 4: Sphere Spectrum — Novel Definition -/

/-- The **Sphere Spectrum** packages all sphere Euler data into a single
    graded algebraic object with Bernoulli modulation. -/
structure SphereSpectrum where
  eulerWeight : ℕ → ℚ
  bernoulliMod : ℕ → ℚ
  euler_spec : ∀ n, eulerWeight n = (1 : ℚ) + (-1) ^ n
  bernoulli_spec : ∀ n, bernoulliMod n = bernoulli' n * eulerWeight n
  odd_vanishing : ∀ k, eulerWeight (2 * k + 1) = 0

/-- The canonical sphere spectrum instance. -/
noncomputable def SphereSpectrum.canonical : SphereSpectrum where
  eulerWeight n := (1 : ℚ) + (-1) ^ n
  bernoulliMod n := bernoulli' n * ((1 : ℚ) + (-1) ^ n)
  euler_spec _ := rfl
  bernoulli_spec _ := rfl
  odd_vanishing k := by
    show (1 : ℚ) + (-1) ^ (2 * k + 1) = 0
    have : ((-1 : ℚ) ^ (2 * k + 1)) = -1 := by rw [pow_add, pow_mul]; simp
    rw [this]; ring

/-! ## Part 5: Bernoulli-Sphere Weight -/

/-- B_n · (1 + (-1)^n): vanishes at all odd dimensions. -/
noncomputable def bernoulliSphereWeight (n : ℕ) : ℚ :=
  bernoulli' n * ((1 : ℚ) + (-1) ^ n)

/-- Odd weights vanish. -/
theorem bernoulliSphereWeight_odd (k : ℕ) :
    bernoulliSphereWeight (2 * k + 1) = 0 := by
  unfold bernoulliSphereWeight
  have : ((-1 : ℚ) ^ (2 * k + 1)) = -1 := by
    rw [pow_add, pow_mul]; simp
  rw [this]; ring

/-- Even weights equal 2·B_{2k}. -/
theorem bernoulliSphereWeight_even (k : ℕ) :
    bernoulliSphereWeight (2 * k) = 2 * bernoulli' (2 * k) := by
  unfold bernoulliSphereWeight
  have : ((-1 : ℚ) ^ (2 * k)) = 1 := by rw [pow_mul]; simp
  rw [this]; ring

/-- The cumulative invariant. -/
noncomputable def bernoulliSphereInvariant (N : ℕ) : ℚ :=
  ∑ k ∈ Finset.range (N + 1), bernoulliSphereWeight k

/-- Step recurrence. -/
theorem bernoulliSphereInvariant_succ (N : ℕ) :
    bernoulliSphereInvariant (N + 1) =
    bernoulliSphereInvariant N + bernoulliSphereWeight (N + 1) := by
  simp [bernoulliSphereInvariant, Finset.sum_range_succ]

/-- Odd steps don't change the invariant. -/
theorem bernoulliSphereInvariant_odd_step (N : ℕ) :
    bernoulliSphereInvariant (2 * N + 1) = bernoulliSphereInvariant (2 * N) := by
  rw [bernoulliSphereInvariant_succ, bernoulliSphereWeight_odd, add_zero]

/-
Base value: BSI(0) = 2 since B_0 = 1 and χ(S⁰) = 2.
-/
theorem bernoulliSphereInvariant_zero :
    bernoulliSphereInvariant 0 = 2 := by
  unfold bernoulliSphereInvariant bernoulliSphereWeight;
  norm_num +zetaDelta at *

/-! ## Part 6: Characteristic Polynomials -/

/-- p_n(X) = X^n + (-1)^n. Eval at 1 gives χ(Sⁿ). -/
noncomputable def sphereCharPoly (n : ℕ) : ℤ[X] :=
  X ^ n + C ((-1) ^ n)

/-- Evaluation at 1 yields the Euler characteristic. -/
theorem sphereCharPoly_eval_one (n : ℕ) :
    (sphereCharPoly n).eval 1 = sphereEulerChar n := by
  simp [sphereCharPoly, sphereEulerChar]

/-
**Degree theorem**: natDegree = n for n ≥ 1.
-/
theorem sphereCharPoly_natDegree (n : ℕ) (hn : 1 ≤ n) :
    (sphereCharPoly n).natDegree = n := by
  unfold sphereCharPoly; erw [ Polynomial.natDegree_X_pow_add_C ] ;

/-
The characteristic polynomial is monic for n ≥ 1.
-/
theorem sphereCharPoly_monic (n : ℕ) (hn : 1 ≤ n) :
    (sphereCharPoly n).Monic := by
  convert Polynomial.monic_X_pow_add_C _ _;
  lia

/-! ## Part 7: The Mega-Sphere -/

/-- The Mega-Sphere inverse system: truncated coefficient sequences. -/
def megaSphereSystem : NatInverseSystem (fun n => Fin (n + 1) → ℤ) where
  bond _n f := fun i => f (Fin.castSucc i)

/-- The **Mega-Sphere**: inverse limit of the truncated polynomial tower. -/
def MegaSphere : Type := NatInverseLimit (fun n => Fin (n + 1) → ℤ) megaSphereSystem

/-- Extract the underlying infinite sequence. -/
def MegaSphere.toSeq (x : MegaSphere) : ℕ → ℤ :=
  fun n => x.proj (n + 1) ⟨n, by omega⟩

/-- Construct from an infinite sequence. -/
def MegaSphere.ofSeq (a : ℕ → ℤ) : MegaSphere :=
  ⟨fun n i => a i.val, fun n => by ext i; simp [megaSphereSystem]⟩

/-- Round-trip: toSeq ∘ ofSeq = id. -/
theorem MegaSphere.ofSeq_toSeq (a : ℕ → ℤ) :
    (MegaSphere.ofSeq a).toSeq = a := by
  ext n; simp [MegaSphere.toSeq, MegaSphere.ofSeq, NatInverseLimit.proj]

/-- Projection recovers values. -/
theorem MegaSphere.proj_ofSeq (a : ℕ → ℤ) (n : ℕ) (i : Fin (n + 1)) :
    (MegaSphere.ofSeq a).proj n i = a i.val := by
  simp [MegaSphere.ofSeq, NatInverseLimit.proj]

/-
toSeq is injective.
-/
theorem MegaSphere.toSeq_injective : Function.Injective MegaSphere.toSeq := by
  -- To prove injectivity, assume $toSeq x = toSeq y$. We need to show $x = y$.
  intro x y hxy
  have h_proj : ∀ n, x.proj n = y.proj n := by
    intro n;
    induction' n with n ih;
    · convert congr_arg ( fun f : ℕ → ℤ => fun i : Fin 1 => f i ) hxy;
      · convert x.proj_bond_compat 0 |> Eq.symm;
        simp +decide [ funext_iff, Fin.forall_fin_succ ];
        rename_i i; fin_cases i; rfl;
      · convert y.proj_bond_compat 0 |> Eq.symm;
        simp +decide [ funext_iff, Fin.forall_fin_succ ];
        rename_i i; fin_cases i; rfl;
    · simp_all +decide [ funext_iff, NatInverseLimit.proj ];
      intro i; induction i using Fin.lastCases <;> simp_all +decide [ MegaSphere.toSeq ] ;
      · have := x.2 ( n + 1 ) ; have := y.2 ( n + 1 ) ; simp_all +decide [ NatInverseLimit.proj, megaSphereSystem ] ;
        simp_all +decide [ funext_iff, Fin.last ];
        have := ‹∀ ( x_1 : Fin ( n + 1 + 1 ) ), ( x.val ( n + 1 + 1 ) ) ( Fin.castSucc x_1 ) = ( x.val ( n + 1 ) ) x_1› ⟨ n + 1, by linarith ⟩ ; have := ‹∀ ( x_1 : Fin ( n + 1 + 1 ) ), ( y.val ( n + 1 + 1 ) ) ( Fin.castSucc x_1 ) = ( y.val ( n + 1 ) ) x_1› ⟨ n + 1, by linarith ⟩ ; simp_all +decide [ Fin.add_def, Fin.last ] ;
      · have := x.2 n; have := y.2 n; simp_all +decide [ NatInverseLimit.proj ] ;
        simp_all +decide [ funext_iff, megaSphereSystem ];
  -- By definition of equality of functions, it suffices to show that $x.proj n = y.proj n$ for all $n$.
  apply NatInverseLimit.ext; intro n; exact h_proj n

/-! ## Part 8: Filtration -/

/-- Elements with support bounded by n. -/
def MegaSphere.filtration (n : ℕ) : Set MegaSphere :=
  { x | ∀ k, n < k → x.toSeq k = 0 }

/-- Filtration is monotone. -/
theorem MegaSphere.filtration_mono {m n : ℕ} (hmn : m ≤ n) :
    MegaSphere.filtration m ⊆ MegaSphere.filtration n :=
  fun _ hx k hk => hx k (by omega)

/-- Zero is in every level. -/
theorem MegaSphere.zero_mem_filtration (n : ℕ) :
    MegaSphere.ofSeq (fun _ => 0) ∈ MegaSphere.filtration n := by
  intro k _; simp [MegaSphere.toSeq, MegaSphere.ofSeq, NatInverseLimit.proj]

/-! ## Part 9: Euler Encoding -/

/-- The Mega-Sphere element encoding all sphere Euler characteristics. -/
def eulerEncoding : MegaSphere :=
  MegaSphere.ofSeq (fun n => sphereEulerChar n)

/-- Values alternate between 2 and 0. -/
theorem eulerEncoding_values (n : ℕ) :
    eulerEncoding.toSeq n = 1 + (-1) ^ n := by
  simp [eulerEncoding, MegaSphere.ofSeq_toSeq, sphereEulerChar]

/-
The Euler encoding has infinite support.
-/
theorem eulerEncoding_not_filtered (n : ℕ) :
    eulerEncoding ∉ MegaSphere.filtration n := by
  intro h
  have := h (2 * (n + 1)) (by linarith)
  simp [eulerEncoding_values] at this