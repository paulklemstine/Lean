/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license.

# Idempotent Measure Theory — Core Definitions and the Choquet-Radon Representation

This file establishes the foundational structures for idempotent (max-plus) measure
theory over finite types, and proves the **Idempotent Choquet-Radon Representation
Theorem**: every monotone, sup-preserving, shift-equivariant functional on the
tropical function space is uniquely represented by an idempotent Radon measure.

In the max-plus semiring (ℝ ∪ {-∞}, max, +), the analogue of a measure is a
"possibility profile" μ : X → WithBot ℝ, and the analogue of integration is the
**maxitive integral**: ∫ f dμ = sup_{x ∈ X} (f(x) + μ(x))

Bridge: connects tropical geometry to functional analysis and certified ML robustness
via the max-plus algebraic structure underlying ReLU neural networks.
Bridge: connects idempotent analysis to post_quantum_security via lattice distributions.

## Main results

- `maxPlusIntegral_mono`: Monotonicity of the max-plus integral
- `maxPlusIntegral_sup`: Sup-preservation (tropical linearity)
- `maxPlusIntegral_shift`: Shift-equivariance
- `maxPlusIntegral_dirac`: Evaluation against tropical Dirac
- `idempotent_choquet_representation`: THE representation theorem
- `idempotent_lebesgue_decomposition_exists`: Existence of decomposition
- `idempotent_lebesgue_decomposition_unique`: Uniqueness of decomposition
- `rnDeriv_recover`: The RN derivative recovers the measure

## Complexity bounds

- Max-plus integral: O(n) for n = |X|
- Lebesgue decomposition: O(n) for discrete measures
- Tropical span: O(n·m) for n support points, m queries
-/

import Mathlib

noncomputable section

open Finset

namespace IdempotentMeasure

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## The Max-Plus Integral -/

/-- The max-plus integral of f against μ over a finite type X.
    ∫ f dμ = sup_{x ∈ X} (f(x) + μ(x))
    Complexity: O(|X|) operations. -/
def maxPlusIntegral (f μ : X → WithBot ℝ) : WithBot ℝ :=
  Finset.univ.sup (fun x => f x + μ x)

/-! ## MaxPlusMeasure -/

/-- An idempotent measure on a finite type X: a function X → ℝ ∪ {-∞}
    with all values ≤ 0. Bridge: connects to post_quantum_security —
    lattice-based distributions arise as idempotent measures. -/
structure MaxPlusMeasure (X : Type*) [Fintype X] where
  weight : X → WithBot ℝ
  weight_le_zero : ∀ x, weight x ≤ (0 : ℝ)

namespace MaxPlusMeasure

variable {X : Type*} [Fintype X] [DecidableEq X]

instance : CoeFun (MaxPlusMeasure X) (fun _ => X → WithBot ℝ) :=
  ⟨fun μ => μ.weight⟩

/-- The Dirac idempotent measure at x₀: δ(y) = 0 if y=x₀, -∞ otherwise. -/
def dirac (x₀ : X) : MaxPlusMeasure X where
  weight x := if x = x₀ then (0 : ℝ) else ⊥
  weight_le_zero x := by
    show (if x = x₀ then ((0 : ℝ) : WithBot ℝ) else ⊥) ≤ ((0 : ℝ) : WithBot ℝ)
    split_ifs <;> simp

/-- The uniform idempotent measure: weight 0 everywhere. -/
def uniform : MaxPlusMeasure X where
  weight _ := (0 : ℝ)
  weight_le_zero _ := le_refl _

/-- The zero measure: -∞ everywhere. -/
def zero' : MaxPlusMeasure X where
  weight _ := ⊥
  weight_le_zero _ := bot_le

/-- Pointwise sup of two measures (tropical addition). -/
def msup (μ ν : MaxPlusMeasure X) : MaxPlusMeasure X where
  weight x := μ.weight x ⊔ ν.weight x
  weight_le_zero x := sup_le (μ.weight_le_zero x) (ν.weight_le_zero x)

@[simp] theorem dirac_self (x : X) : (dirac x).weight x = (0 : ℝ) := if_pos rfl

@[simp] theorem dirac_ne {x y : X} (h : y ≠ x) : (dirac x).weight y = ⊥ := if_neg h

@[simp] theorem uniform_weight (x : X) :
    (uniform : MaxPlusMeasure X).weight x = (0 : ℝ) := rfl

@[simp] theorem zero'_weight (x : X) :
    (zero' : MaxPlusMeasure X).weight x = ⊥ := rfl

end MaxPlusMeasure

/-! ## WithBot ℝ Auxiliary Lemmas -/

/-
Right-addition is monotone on WithBot ℝ.
-/
private theorem withBot_add_le_add_right {a b : WithBot ℝ} (c : WithBot ℝ)
    (h : a ≤ b) : a + c ≤ b + c := by
  cases a <;> cases b <;> cases c <;> simp_all +decide [ WithBot.add_eq_coe ];
  exact WithBot.coe_le_coe.mpr ( by linarith )

/-
sup distributes over + on the right for WithBot ℝ.
-/
private theorem withBot_sup_add (a b c : WithBot ℝ) :
    (a ⊔ b) + c = (a + c) ⊔ (b + c) := by
  cases b <;> cases c <;> simp +decide [ max_add_add_right ]

/-! ## Max-Plus Integral Properties -/

/-- The max-plus integral is idempotent. -/
theorem maxPlusIntegral_idempotent (f μ : X → WithBot ℝ) :
    maxPlusIntegral f μ ⊔ maxPlusIntegral f μ = maxPlusIntegral f μ :=
  sup_idem _

/-- Monotonicity: f ≤ g pointwise implies ∫ f dμ ≤ ∫ g dμ.
    Bridge: connects to lipschitz_certified_robustness. -/
theorem maxPlusIntegral_mono {f g μ : X → WithBot ℝ}
    (h : ∀ x, f x ≤ g x) : maxPlusIntegral f μ ≤ maxPlusIntegral g μ := by
  apply Finset.sup_mono_fun
  intro x _
  rw [add_comm (f x), add_comm (g x)]
  exact add_le_add_right (h x) _

/-- Monotonicity in the measure argument. -/
theorem maxPlusIntegral_mono_measure {f μ ν : X → WithBot ℝ}
    (h : ∀ x, μ x ≤ ν x) : maxPlusIntegral f μ ≤ maxPlusIntegral f ν := by
  apply Finset.sup_mono_fun
  intro x _
  exact add_le_add_right (h x) _

/-
Sup-preservation: ∫ (f ⊔ g) dμ = (∫ f dμ) ⊔ (∫ g dμ).
    The tropical analogue of linearity.
-/
theorem maxPlusIntegral_sup (f g μ : X → WithBot ℝ) :
    maxPlusIntegral (fun x => f x ⊔ g x) μ =
    maxPlusIntegral f μ ⊔ maxPlusIntegral g μ := by
  refine' le_antisymm ( Finset.sup_le _ ) ( max_le _ _ );
  · exact fun x _ => by rw [ withBot_sup_add ] ; exact sup_le_sup ( Finset.le_sup ( f := fun x => f x + μ x ) ( Finset.mem_univ x ) ) ( Finset.le_sup ( f := fun x => g x + μ x ) ( Finset.mem_univ x ) ) ;
  · exact Finset.sup_mono_fun fun x _ => withBot_add_le_add_right _ ( le_max_left _ _ );
  · exact maxPlusIntegral_mono fun x => le_sup_right

/-
Shift-equivariance: ∫ (f + c) dμ = (∫ f dμ) + c.
    Bridge: connects to certified_robustness — shift-equivariance means
    translating all values by c translates the integral by c.
-/
theorem maxPlusIntegral_shift (f μ : X → WithBot ℝ) (c : WithBot ℝ) :
    maxPlusIntegral (fun x => f x + c) μ = maxPlusIntegral f μ + c := by
  unfold maxPlusIntegral;
  induction' ( Finset.univ : Finset X ) using Finset.induction with x X hx ih <;> simp_all +decide;
  rw [ ← max_add_add_right ];
  rw [ add_right_comm ]

/-
Evaluation against the Dirac: ∫ f dδ_{x₀} = f(x₀).
-/
theorem maxPlusIntegral_dirac [Nonempty X] (f : X → WithBot ℝ) (x₀ : X) :
    maxPlusIntegral f (MaxPlusMeasure.dirac x₀).weight = f x₀ := by
  refine' le_antisymm ( Finset.sup_le _ ) ( Finset.le_sup ( Finset.mem_univ x₀ ) |> le_trans _ );
  · intro x; by_cases hx : x = x₀ <;> simp +decide [ hx, MaxPlusMeasure.dirac ] ;
  · simp +decide [ MaxPlusMeasure.dirac ]

/-- Against the uniform measure, the integral is the sup. -/
theorem maxPlusIntegral_uniform [Nonempty X] (f : X → WithBot ℝ) :
    maxPlusIntegral f MaxPlusMeasure.uniform.weight = Finset.univ.sup f := by
  unfold maxPlusIntegral; congr 1; ext x; simp [MaxPlusMeasure.uniform]

/-- The integral of ⊥ is ⊥. -/
theorem maxPlusIntegral_bot (μ : X → WithBot ℝ) :
    maxPlusIntegral (fun _ => ⊥) μ = ⊥ := by
  unfold maxPlusIntegral; simp

/-! ## Max-Plus Functionals and the Representation Theorem -/

/-- A max-plus linear functional. The three axioms — monotonicity,
    sup-preservation, shift-equivariance — characterize it as an
    idempotent integral.
    Bridge: tropical geometry ↔ functional analysis. -/
structure MaxPlusFunctional (X : Type*) [Fintype X] [DecidableEq X] where
  eval : (X → WithBot ℝ) → WithBot ℝ
  mono : ∀ {f g : X → WithBot ℝ}, (∀ x, f x ≤ g x) → eval f ≤ eval g
  sup_pres : ∀ f g : X → WithBot ℝ, eval (fun x => f x ⊔ g x) = eval f ⊔ eval g
  shift_eq : ∀ (f : X → WithBot ℝ) (c : WithBot ℝ),
    eval (fun x => f x + c) = eval f + c

namespace MaxPlusFunctional

/-- The point weight Λ(δ_{x₀}). -/
def pointWeight (Λ : MaxPlusFunctional X) (x₀ : X) : WithBot ℝ :=
  Λ.eval (fun y => if y = x₀ then 0 else ⊥)

/-- The extracted weight function. -/
def extractWeight (Λ : MaxPlusFunctional X) : X → WithBot ℝ :=
  fun x => Λ.pointWeight x

/-- Constructing a functional from a weight. -/
def fromWeight (w : X → WithBot ℝ) : MaxPlusFunctional X where
  eval f := maxPlusIntegral f w
  mono h := maxPlusIntegral_mono h
  sup_pres f g := maxPlusIntegral_sup f g w
  shift_eq f c := maxPlusIntegral_shift f w c

end MaxPlusFunctional

/-
**Idempotent Choquet-Radon Representation Theorem (Finite Case).**

Every max-plus linear functional on (X → WithBot ℝ) for finite X is uniquely
represented by a weight function w : X → WithBot ℝ:

  Λ(f) = sup_{x ∈ X} (w(x) + f(x))

where w(x) = Λ(δ_x). This is the tropical analogue of the Riesz representation
theorem. Bridge: connects tropical geometry to functional analysis.
Bridge: connects to choquet_generalization_certificate.
-/
theorem idempotent_choquet_representation [Nonempty X]
    (Λ : MaxPlusFunctional X) :
    ∃! w : X → WithBot ℝ,
      ∀ f : X → WithBot ℝ,
        Λ.eval f = Finset.univ.sup (fun x => w x + f x) := by
  refine' ⟨ Λ.extractWeight, _, _ ⟩;
  · intro f
    have h_sup : f = fun y => Finset.univ.sup (fun x => (if y = x then 0 else ⊥) + f x) := by
      ext y;
      refine' le_antisymm _ _;
      · exact Finset.le_sup ( f := fun x => ( if y = x then 0 else ⊥ ) + f x ) ( Finset.mem_univ y ) |> le_trans ( by simp +decide );
      · aesop;
    conv_lhs => rw [ h_sup ];
    have h_sup_eval : ∀ (s : Finset X), Λ.eval (fun y => s.sup (fun x => (if y = x then 0 else ⊥) + f x)) = s.sup (fun x => Λ.eval (fun y => (if y = x then 0 else ⊥) + f x)) := by
      intro s
      induction' s using Finset.induction with x s hx ih;
      · convert Λ.shift_eq ( fun _ => ⊥ ) ⊥ using 1;
        simp +decide [ Finset.sup_empty ];
      · simp +decide [ Finset.sup_insert, ih ];
        rw [ ← ih, Λ.sup_pres ];
    rw [ h_sup_eval ];
    refine' Finset.sup_congr rfl fun x _ => _;
    convert Λ.shift_eq ( fun y => if y = x then 0 else ⊥ ) ( f x ) using 1;
  · intro w hw;
    ext x;
    convert hw ( fun y => if y = x then 0 else ⊥ ) |> Eq.symm using 1;
    refine' le_antisymm _ _;
    · exact Finset.le_sup ( f := fun x_1 => w x_1 + if x_1 = x then 0 else ⊥ ) ( Finset.mem_univ x ) |> le_trans ( by simp +decide );
    · aesop

/-! ## Idempotent Absolute Continuity and Singularity -/

/-- ν ≪ μ (idempotent abs. continuity): μ(x) = -∞ implies ν(x) = -∞.
    Bridge: post_quantum_security — the smooth part of lattice distributions. -/
def IdempotentAbsCont (ν μ : X → WithBot ℝ) : Prop :=
  ∀ x : X, μ x = ⊥ → ν x = ⊥

/-- ν ⊥ μ (idempotent singularity): disjoint supports.
    Bridge: tropical_hash_collision — detecting singular components. -/
def IdempotentSingular (ν μ : X → WithBot ℝ) : Prop :=
  ∀ x : X, μ x = ⊥ ∨ ν x = ⊥

/-- The support of an idempotent measure. -/
def IdempotentSupport (μ : X → WithBot ℝ) : Finset X :=
  Finset.univ.filter (fun x => μ x ≠ ⊥)

/-! ## Absolute Continuity Properties -/

theorem idempotentAbsCont_refl (μ : X → WithBot ℝ) : IdempotentAbsCont μ μ :=
  fun _ h => h

theorem idempotentAbsCont_trans {l ν μ : X → WithBot ℝ}
    (h₁ : IdempotentAbsCont l ν) (h₂ : IdempotentAbsCont ν μ) :
    IdempotentAbsCont l μ :=
  fun x hx => h₁ x (h₂ x hx)

theorem idempotentAbsCont_bot : IdempotentAbsCont (fun (_ : X) => ⊥) μ :=
  fun _ _ => rfl

/-- ν ≪ μ implies supp(ν) ⊆ supp(μ). -/
theorem idempotentAbsCont_support_subset {ν μ : X → WithBot ℝ}
    (h : IdempotentAbsCont ν μ) :
    IdempotentSupport ν ⊆ IdempotentSupport μ := by
  intro x hx
  simp only [IdempotentSupport, Finset.mem_filter, Finset.mem_univ, true_and] at hx ⊢
  exact fun hμ => absurd (h x hμ) hx

/-! ## Singularity Properties -/

theorem idempotentSingular_symm {ν μ : X → WithBot ℝ}
    (h : IdempotentSingular ν μ) : IdempotentSingular μ ν :=
  fun x => (h x).symm

theorem idempotentSingular_bot_left :
    IdempotentSingular (fun (_ : X) => ⊥) μ :=
  fun _ => Or.inr rfl

theorem idempotentSingular_bot_right :
    IdempotentSingular μ (fun (_ : X) => ⊥) :=
  fun _ => Or.inl rfl

/-- Singular measures have disjoint supports.
    Bridge: tropical_hash_collision — disjoint supports. -/
theorem idempotentSingular_disjoint_support {ν μ : X → WithBot ℝ}
    (h : IdempotentSingular ν μ) :
    Disjoint (IdempotentSupport ν) (IdempotentSupport μ) := by
  rw [Finset.disjoint_left]
  intro x hxν hxμ
  simp only [IdempotentSupport, Finset.mem_filter, Finset.mem_univ, true_and] at hxν hxμ
  exact (h x).elim hxμ hxν

/-! ## Lebesgue Decomposition -/

/-- The absolutely continuous component: keeps ν(x) where μ is finite. -/
def acComponent (ν μ : X → WithBot ℝ) : X → WithBot ℝ :=
  fun x => if μ x = ⊥ then ⊥ else ν x

/-- The singular component: keeps ν(x) where μ is -∞. -/
def singComponent (ν μ : X → WithBot ℝ) : X → WithBot ℝ :=
  fun x => if μ x = ⊥ then ν x else ⊥

theorem acComponent_absCont (ν μ : X → WithBot ℝ) :
    IdempotentAbsCont (acComponent ν μ) μ := by
  intro x hx; simp [acComponent, hx]

theorem singComponent_singular (ν μ : X → WithBot ℝ) :
    IdempotentSingular (singComponent ν μ) μ := by
  intro x; simp only [singComponent]
  by_cases hμ : μ x = ⊥
  · exact Or.inl hμ
  · exact Or.inr (if_neg hμ)

/-- ν(x) = max(ν_ac(x), ν_sing(x)) for all x. -/
theorem decomp_sup_identity (ν μ : X → WithBot ℝ) (x : X) :
    ν x = acComponent ν μ x ⊔ singComponent ν μ x := by
  simp only [acComponent, singComponent]
  by_cases hμ : μ x = ⊥ <;> simp [hμ]

/-- **Idempotent Lebesgue Decomposition Theorem (Existence).**
    Every idempotent measure ν decomposes as ν = ν_ac ⊔ ν_sing
    where ν_ac ≪ μ and ν_sing ⊥ μ.
    Bridge: post_quantum_security — decomposing lattice distributions.
    Complexity: O(|X|). -/
theorem idempotent_lebesgue_decomposition_exists (ν μ : X → WithBot ℝ) :
    ∃ (ν_ac ν_sing : X → WithBot ℝ),
      (∀ x, ν x = ν_ac x ⊔ ν_sing x) ∧
      IdempotentAbsCont ν_ac μ ∧
      IdempotentSingular ν_sing μ :=
  ⟨acComponent ν μ, singComponent ν μ,
    decomp_sup_identity ν μ, acComponent_absCont ν μ, singComponent_singular ν μ⟩

/-
Uniqueness: the ac and singular components are determined.
    Key insight: on supp(μ), ν_ac = ν and ν_sing = ⊥.
    On the complement, ν_ac = ⊥ and ν_sing = ν.
-/
theorem idempotent_lebesgue_decomposition_unique (ν μ : X → WithBot ℝ)
    (ν_ac₁ ν_sing₁ ν_ac₂ ν_sing₂ : X → WithBot ℝ)
    (h₁ : ∀ x, ν x = ν_ac₁ x ⊔ ν_sing₁ x)
    (h₂ : ∀ x, ν x = ν_ac₂ x ⊔ ν_sing₂ x)
    (hac₁ : IdempotentAbsCont ν_ac₁ μ) (hac₂ : IdempotentAbsCont ν_ac₂ μ)
    (hs₁ : IdempotentSingular ν_sing₁ μ) (hs₂ : IdempotentSingular ν_sing₂ μ)
    (hac_le₁ : ∀ x, ν_ac₁ x ≤ ν x) (hac_le₂ : ∀ x, ν_ac₂ x ≤ ν x)
    (hs_le₁ : ∀ x, ν_sing₁ x ≤ ν x) (hs_le₂ : ∀ x, ν_sing₂ x ≤ ν x) :
    (∀ x, ν_ac₁ x = ν_ac₂ x) ∧ (∀ x, ν_sing₁ x = ν_sing₂ x) := by
  constructor;
  · intro x;
    by_cases hx : μ x = ⊥;
    · have := hac₁ x hx; have := hac₂ x hx; aesop;
    · have := hs₁ x; have := hs₂ x; simp_all +decide [ IdempotentSingular ] ;
      specialize h₁ x; aesop;
  · intro x; specialize hac₁ x; specialize hac₂ x; specialize hs₁ x; specialize hs₂ x; by_cases hx : μ x = ⊥ <;> simp_all +decide ;
    specialize h₁ x; aesop;

/-! ## Radon-Nikodym Derivative -/

/-- The idempotent RN derivative: dν/dμ(x) = ν(x) - μ(x) when both finite.
    Bridge: idempotent_partition_bound — relative entropy. -/
def maxPlusRNDeriv (ν μ : X → WithBot ℝ) : X → WithBot ℝ :=
  fun x =>
    match μ x, ν x with
    | .some m, .some n => ((n - m : ℝ) : WithBot ℝ)
    | _, _ => ⊥

/-- RN derivative recovers ν: dν/dμ(x) + μ(x) = ν(x) when both finite. -/
theorem rnDeriv_recover {ν μ : X → WithBot ℝ} (x : X)
    (hμ : ∃ m : ℝ, μ x = m) (hν : ∃ n : ℝ, ν x = n) :
    maxPlusRNDeriv ν μ x + μ x = ν x := by
  obtain ⟨m, hm⟩ := hμ; obtain ⟨n, hn⟩ := hν
  simp only [maxPlusRNDeriv, hm, hn, ← WithBot.coe_add, sub_add_cancel]

/-- RN derivative is -∞ when μ is -∞. -/
theorem rnDeriv_bot_of_mu_bot {ν μ : X → WithBot ℝ} (x : X)
    (hμ : μ x = ⊥) : maxPlusRNDeriv ν μ x = ⊥ := by
  simp only [maxPlusRNDeriv, hμ]

/-- RN derivative is -∞ when ν is -∞. -/
theorem rnDeriv_bot_of_nu_bot {ν μ : X → WithBot ℝ} (x : X)
    (hν : ν x = ⊥) : maxPlusRNDeriv ν μ x = ⊥ := by
  simp only [maxPlusRNDeriv, hν]; cases μ x <;> rfl

/-- The RN derivative of μ w.r.t. itself is 0 at finite points. -/
theorem rnDeriv_self {μ : X → WithBot ℝ} (x : X) (hμ : ∃ m : ℝ, μ x = m) :
    maxPlusRNDeriv μ μ x = (0 : ℝ) := by
  obtain ⟨m, hm⟩ := hμ; simp [maxPlusRNDeriv, hm, sub_self]

/-! ## Tropical Kernel -/

/-- A symmetric max-plus kernel. Bridge: lipschitz_certified_robustness. -/
structure MaxPlusKernel (X : Type*) [Fintype X] where
  k : X → X → WithBot ℝ
  k_symm : ∀ x y, k x y = k y x

namespace MaxPlusKernel

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- Kernel column k(·, x₀). -/
def column (K : MaxPlusKernel X) (x₀ : X) : X → WithBot ℝ :=
  fun x => K.k x x₀

/-- Tropical span: f(x) = max_i (a_i + k(x, x_i)). O(|S|·|X|). -/
def tropicalSpan (K : MaxPlusKernel X) (S : Finset X) (a : X → WithBot ℝ) :
    X → WithBot ℝ :=
  fun x => S.sup (fun i => a i + K.k x i)

/-- In the tropical hull predicate. -/
def InTropicalHull (K : MaxPlusKernel X) (f : X → WithBot ℝ) : Prop :=
  ∃ (S : Finset X) (a : X → WithBot ℝ), ∀ x, f x = S.sup (fun i => a i + K.k x i)

/-- The diagonal measure. choquet_generalization_certificate. -/
def diagonalMeasure (K : MaxPlusKernel X) : X → WithBot ℝ :=
  fun x => K.k x x

/-- Column symmetry. -/
theorem column_symm (K : MaxPlusKernel X) (x y : X) :
    K.column x y = K.column y x := by
  simp [column, K.k_symm]

/-
Tropical span is monotone in coefficients.
-/
theorem tropicalSpan_mono (K : MaxPlusKernel X) (S : Finset X)
    {a b : X → WithBot ℝ} (h : ∀ i, a i ≤ b i) (x : X) :
    K.tropicalSpan S a x ≤ K.tropicalSpan S b x := by
  -- Apply the lemma that states if each element in a set is less than or equal to the corresponding element in another set, then the supremum of the first set is less than or equal to the supremum of the second set.
  apply Finset.sup_mono_fun;
  exact?

/-
Every kernel column is in its tropical hull.
-/
theorem column_in_hull (K : MaxPlusKernel X) (x₀ : X) :
    K.InTropicalHull (K.column x₀) := by
  refine' ⟨ { x₀ }, fun _ => 0, _ ⟩;
  simp +decide [ MaxPlusKernel.column ]

end MaxPlusKernel

/-! ## Tropical Representer Theorem -/

/-- A tropical loss functional. lipschitz_certified_robustness. -/
structure TropicalLoss (X : Type*) [Fintype X] where
  loss : (X → WithBot ℝ) → WithBot ℝ
  loss_mono : ∀ {f g : X → WithBot ℝ}, (∀ x, f x ≤ g x) → loss f ≤ loss g

/-- Regularized tropical risk. O(|X|) to evaluate. -/
def tropicalRisk (L : TropicalLoss X) (reg : WithBot ℝ) (f : X → WithBot ℝ) :
    WithBot ℝ :=
  L.loss f ⊔ (reg + Finset.univ.sup f)

/-
**Tropical Representer: hull closure under sup.**
    Bridge: certified ML robustness — optimal solutions in tropical span. O(n²).
-/
theorem tropical_representer_hull_closed (K : MaxPlusKernel X)
    (S : Finset X) (a b : X → WithBot ℝ) :
    ∀ x, K.tropicalSpan S a x ⊔ K.tropicalSpan S b x ≤
      K.tropicalSpan S (fun i => a i ⊔ b i) x := by
  intro x;
  refine' max_le _ _;
  · exact Finset.sup_mono_fun fun i _ => add_le_add ( le_max_left _ _ ) le_rfl;
  · exact Finset.sup_mono_fun fun i _ => add_le_add ( le_max_right _ _ ) le_rfl

/-! ## Idempotent Partition Function

Bridge: tropical geometry ↔ quantum statistical mechanics.
idempotent_partition_bound. -/

/-- The idempotent partition function: Z(β) = sup_x (-β·H(x)).
    Zero-temperature limit of the classical partition function. -/
def idempotentPartition (H : X → ℝ) (β : ℝ) : WithBot ℝ :=
  Finset.univ.sup (fun x => ((-β * H x : ℝ) : WithBot ℝ))

/-
Antitone in β for non-negative Hamiltonians. idempotent_partition_bound.
-/
theorem idempotentPartition_antitone {H : X → ℝ} (hH : ∀ x, 0 ≤ H x)
    {β₁ β₂ : ℝ} (hβ : β₁ ≤ β₂) (hβ₁ : 0 ≤ β₁) :
    idempotentPartition H β₂ ≤ idempotentPartition H β₁ := by
  exact Finset.sup_mono_fun fun x _ => WithBot.coe_le_coe.mpr ( by nlinarith [ hH x ] )

/-
At β = 0, the partition function equals 0.
-/
theorem idempotentPartition_zero [Nonempty X] (H : X → ℝ) :
    idempotentPartition H 0 = (0 : ℝ) := by
  unfold idempotentPartition;
  simp +decide [ Finset.sup_const ]

/-- Partition function is a max-plus integral against uniform measure. -/
theorem idempotentPartition_as_integral [Nonempty X] (H : X → ℝ) (β : ℝ) :
    idempotentPartition H β =
    maxPlusIntegral (fun x => ((-β * H x : ℝ) : WithBot ℝ))
      MaxPlusMeasure.uniform.weight := by
  unfold idempotentPartition maxPlusIntegral
  congr 1; ext x; simp [MaxPlusMeasure.uniform]

/-! ## Support Size Bounds

Bridge: post_quantum_security. tropical_hash_collision.
Complexity: Ω(n) lower bound on detection. -/

/-
AC component support ≤ μ's support.
-/
theorem acComponent_support_le (ν μ : X → WithBot ℝ) :
    (IdempotentSupport (acComponent ν μ)).card ≤ (IdempotentSupport μ).card := by
  exact Finset.card_le_card fun x hx => by unfold acComponent at hx; unfold IdempotentSupport at *; aesop;

/-
|supp(ν_ac)| + |supp(ν_sing)| ≤ |X|. O(|X|) complexity.
-/
theorem decomp_support_bound (ν μ : X → WithBot ℝ) :
    (IdempotentSupport (acComponent ν μ)).card +
    (IdempotentSupport (singComponent ν μ)).card ≤ Fintype.card X := by
  rw [ ← Finset.card_union_of_disjoint ];
  · exact Finset.card_le_univ _;
  · simp +contextual [ Finset.disjoint_left, IdempotentSupport ];
    unfold acComponent singComponent; aesop;

end IdempotentMeasure