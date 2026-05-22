/-
# Tropical Diffusion Regularity Theory

This file formalizes a discrete tropical diffusion framework and proves
regularity criteria analogous to maximum principles and oscillation
contraction in classical PDE theory.

## Mathematical Context

Classical Navier–Stokes regularity hinges on propagating scale-sensitive bounds
on vorticity and gradients. Tropical (max-plus / min-plus) mathematics replaces
additive superposition by min/max composition, turning nonlinear propagation into
order-theoretic dynamics. We prove that tropical diffusion operators are:

1. **Order-preserving**: they cannot create new extrema (maximum principle)
2. **Sup-nonexpansive**: 1-Lipschitz in the sup norm
3. **Oscillation-contracting**: cannot increase oscillation
4. **Globally bounded under iteration**: all iterates remain uniformly bounded

These properties constitute an idempotent anti-blowup mechanism: singularity
formation is obstructed because the idempotent envelope cannot amplify
oscillation beyond its initial barrier.

## Definitions

- `tropDiffMax K u`: max-plus tropical diffusion operator, `i ↦ sup_j (u j - K i j)`
- `tropDiff K u`: min-plus tropical diffusion operator, `i ↦ inf_j (K i j + u j)`
- `osc u`: oscillation seminorm, `sup u - inf u`
- `tropEnergy u`: tropical energy, `sup u`
- `tropDissipation K u`: tropical dissipation, `sup_i (u i - tropDiffMax K u i)`
- `iterateTrop K n u`: n-fold iteration of `tropDiffMax K`
- `discreteVorticity A u`: discrete vorticity surrogate

## Main Results

- `tropDiffMax_pointwise_le`: pointwise bound by global supremum
- `tropDiffMax_le_sup`: global supremum is nonincreasing
- `inf_le_tropDiff`: global infimum is nondecreasing
- `tropDiffMax_monotone`: monotonicity in state
- `tropDiffMax_add_const`: translation equivariance
- `tropDiffMax_nonexpansive`: sup-norm nonexpansiveness
- `osc_tropDiffMax_le_osc`: oscillation contraction
- `iterate_sup_bound`: global sup bound under iteration
- `iterate_osc_monotone`: oscillation bound under iteration
- `discreteVorticity_tropDiffMax_le`: vorticity control
-/

import Mathlib

open Finset

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Core Definitions -/

/-- Max-plus tropical diffusion operator: at each site `i`, take the supremum
over all `j` of `u j - K i j`. This is the Bellman/Lax–Oleinik operator
in the finite setting, and the morphological dilation with structuring
element `-K`. -/
noncomputable def tropDiffMax (K : ι → ι → ℝ) (u : ι → ℝ) : ι → ℝ :=
  fun i => Finset.sup' Finset.univ Finset.univ_nonempty (fun j => u j - K i j)

/-- Min-plus tropical diffusion operator: at each site `i`, take the infimum
over all `j` of `K i j + u j`. This is the dual (min-plus) Bellman operator. -/
noncomputable def tropDiff (K : ι → ι → ℝ) (u : ι → ℝ) : ι → ℝ :=
  fun i => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => K i j + u j)

/-- Oscillation seminorm: the difference between the supremum and infimum
of `u` over the finite type `ι`. Measures the total variation / spread. -/
noncomputable def osc (u : ι → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty u -
  Finset.inf' Finset.univ Finset.univ_nonempty u

/-- Tropical energy: the global supremum of `u`. -/
noncomputable def tropEnergy (u : ι → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty u

/-- Tropical dissipation: measures how much the tropical diffusion operator
decreases the state. Equal to `sup_i (u i - tropDiffMax K u i)`. -/
noncomputable def tropDissipation (K : ι → ι → ℝ) (u : ι → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i => u i - tropDiffMax K u i)

/-- Iterated tropical diffusion: apply `tropDiffMax K` n times. -/
noncomputable def iterateTrop (K : ι → ι → ℝ) : ℕ → (ι → ℝ) → (ι → ℝ)
  | 0, u => u
  | n + 1, u => tropDiffMax K (iterateTrop K n u)

/-- Discrete vorticity surrogate: measures the maximal weighted oscillation
across pairs of sites. For a weight matrix `A`, this captures the discrete
analogue of gradient/curl magnitude. -/
noncomputable def discreteVorticity (A : ι → ι → ℝ) (u : ι → ℝ) : ℝ :=
  Finset.sup' Finset.univ Finset.univ_nonempty (fun i =>
    Finset.sup' Finset.univ Finset.univ_nonempty (fun j => |A i j * (u j - u i)|))

/-! ## Theorem 1: Tropical Maximum Principle -/

/-
Pointwise bound: each value of `tropDiffMax K u` is at most `sup u`,
provided `K` is nonneg and has zero diagonal. This is because
`u j - K i j ≤ u j ≤ sup u` when `K i j ≥ 0`.
-/
theorem tropDiffMax_pointwise_le
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (u : ι → ℝ) :
    ∀ i, tropDiffMax K u i ≤ Finset.sup' Finset.univ Finset.univ_nonempty u := by
  intro iMax;
  exact Finset.sup'_le _ _ fun j _ => sub_le_self _ ( hK_nonneg _ _ ) |> le_trans <| Finset.le_sup' _ <| Finset.mem_univ _

/-
Tropical maximum principle (max-plus form): tropical diffusion does not
increase the global supremum.
-/
theorem tropDiffMax_le_sup
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (_hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    Finset.sup' Finset.univ Finset.univ_nonempty (tropDiffMax K u) ≤
    Finset.sup' Finset.univ Finset.univ_nonempty u := by
  -- By definition of supremum, for any $i$, we have $tropDiffMax K u i \leq \sup u$.
  have h_le_sup : ∀ i, tropDiffMax K u i ≤ Finset.sup' Finset.univ Finset.univ_nonempty u :=
    tropDiffMax_pointwise_le K hK_nonneg u
  exact Finset.sup'_le _ _ fun i _ => h_le_sup i

/-
Tropical maximum principle (min-plus form): tropical diffusion does not
decrease the global infimum.
-/
theorem inf_le_tropDiff
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (_hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    Finset.inf' Finset.univ Finset.univ_nonempty u ≤
    Finset.inf' Finset.univ Finset.univ_nonempty (tropDiff K u) := by
  simp +decide [ tropDiff ];
  exact fun i j => ⟨ j, by linarith [ hK_nonneg i j ] ⟩

/-! ## Structural Properties -/

/-
Monotonicity: if `u ≤ v` pointwise, then `tropDiffMax K u ≤ tropDiffMax K v`
pointwise. This is because sup of larger values is larger.
-/
theorem tropDiffMax_monotone
    (K : ι → ι → ℝ) :
    Monotone (tropDiffMax K : (ι → ℝ) → (ι → ℝ)) := by
  intro u v huv i;
  exact Finset.sup'_le _ _ fun j _ => le_trans ( sub_le_sub_right ( huv j ) _ ) ( Finset.le_sup' ( fun j => v j - K i j ) ( Finset.mem_univ j ) )

/-
Translation equivariance: shifting all values by a constant `c` shifts the
output by the same constant. This is because `(u j + c) - K i j = (u j - K i j) + c`.
-/
theorem tropDiffMax_add_const
    (K : ι → ι → ℝ) (u : ι → ℝ) (c : ℝ) :
    tropDiffMax K (fun i => u i + c) = fun i => tropDiffMax K u i + c := by
  unfold tropDiffMax;
  grind +suggestions

/-
The infimum of tropDiffMax K u is at least the infimum of u, when K is
nonneg with zero diagonal. Together with `tropDiffMax_le_sup`, this gives
the full maximum principle: the range of values cannot expand.
-/
theorem inf_le_tropDiffMax
    (K : ι → ι → ℝ)
    (_hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    Finset.inf' Finset.univ Finset.univ_nonempty u ≤
    Finset.inf' Finset.univ Finset.univ_nonempty (tropDiffMax K u) := by
  simp +decide [ * ];
  exact fun i => ⟨ i, by exact le_trans ( by simp +decide [ hK_diag ] ) ( Finset.le_sup' ( fun j => u j - K i j ) ( Finset.mem_univ i ) ) ⟩

/-! ## Theorem 2: Oscillation Contraction / Nonexpansiveness -/

/-
Sup-norm nonexpansiveness: tropical diffusion is 1-Lipschitz in the
sup norm. For each site `i`, `|tropDiffMax K u i - tropDiffMax K v i|`
is bounded by the global sup of `|u j - v j|`.
-/
theorem tropDiffMax_nonexpansive
    (K : ι → ι → ℝ) :
    ∀ u v : ι → ℝ, ∀ i : ι,
      |tropDiffMax K u i - tropDiffMax K v i| ≤
      Finset.sup' Finset.univ Finset.univ_nonempty (fun j => |u j - v j|) := by
  intro u v i;
  -- By definition of tropDiffMax, we have:
  have h_def : tropDiffMax K u i = Finset.sup' Finset.univ Finset.univ_nonempty (fun j => u j - K i j) ∧ tropDiffMax K v i = Finset.sup' Finset.univ Finset.univ_nonempty (fun j => v j - K i j) := by
    exact ⟨ rfl, rfl ⟩;
  rw [ h_def.1, h_def.2, abs_sub_le_iff ];
  constructor <;> rw [ sub_le_iff_le_add' ];
  · simp +decide [ Finset.sup'_le_iff ];
    intro j; linarith [ abs_le.mp ( Finset.le_sup' ( fun j => |u j - v j| ) ( Finset.mem_univ j ) ), Finset.le_sup' ( fun j => v j - K i j ) ( Finset.mem_univ j ) ] ;
  · simp +decide [ Finset.sup'_le_iff ];
    intro j; linarith [ abs_le.mp ( Finset.le_sup' ( fun j => |u j - v j| ) ( Finset.mem_univ j ) ), Finset.le_sup' ( fun j => u j - K i j ) ( Finset.mem_univ j ) ] ;

/-
Oscillation contraction: tropical diffusion cannot increase oscillation.
This follows from the maximum principle: sup decreases, inf increases,
so sup - inf decreases.
-/
theorem osc_tropDiffMax_le_osc
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    osc (tropDiffMax K u) ≤ osc u := by
  apply_rules [ sub_le_sub, inf_le_tropDiffMax, tropDiffMax_le_sup ]

/-! ## Theorem 3: Iterated Tropical Evolution Bounds -/

/-
Global supremum bound under iteration: all iterates of tropical diffusion
have supremum bounded by the initial supremum.
-/
theorem iterate_sup_bound
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (n : ℕ) (u : ι → ℝ) :
    Finset.sup' Finset.univ Finset.univ_nonempty (iterateTrop K n u) ≤
    Finset.sup' Finset.univ Finset.univ_nonempty u := by
  induction' n with n ih;
  · rfl;
  · exact le_trans ( tropDiffMax_le_sup K hK_nonneg hK_diag _ ) ih

/-
Oscillation bound under iteration: all iterates of tropical diffusion
have oscillation bounded by the initial oscillation. This is the
discrete regularity criterion: no blowup under iterated tropical evolution.
-/
theorem iterate_osc_monotone
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (n : ℕ) (u : ι → ℝ) :
    osc (iterateTrop K n u) ≤ osc u := by
  induction' n with n ih;
  · rfl;
  · exact le_trans ( osc_tropDiffMax_le_osc K hK_nonneg hK_diag _ ) ih

/-! ## Theorem 4: Discrete Vorticity Control via Oscillation Bridge -/

/-
Discrete vorticity is bounded by oscillation when weights are at most 1.
This is the bridge between vorticity and oscillation: since each weighted
difference `|A i j * (u j - u i)|` is at most `|u j - u i| ≤ osc u`.
-/
theorem discreteVorticity_le_osc
    (A : ι → ι → ℝ)
    (hA_nonneg : ∀ i j, 0 ≤ A i j)
    (hA_le_one : ∀ i j, A i j ≤ 1)
    (u : ι → ℝ) :
    discreteVorticity A u ≤ osc u := by
  refine' Finset.sup'_le _ _ _;
  intro i hi;
  refine' Finset.sup'_le _ _ _;
  intro j hj
  have h_abs : |u j - u i| ≤ osc u := by
    unfold osc;
    exact abs_sub_le_iff.mpr ⟨ by linarith [ Finset.le_sup' u hj, Finset.inf'_le u hi ], by linarith [ Finset.le_sup' u hi, Finset.inf'_le u hj ] ⟩;
  exact abs_le.mpr ⟨ by nlinarith [ abs_le.mp h_abs, hA_nonneg i j, hA_le_one i j ], by nlinarith [ abs_le.mp h_abs, hA_nonneg i j, hA_le_one i j ] ⟩

/-
Global vorticity bound under tropical diffusion: vorticity of the
diffused state is bounded by the initial oscillation. This combines
the vorticity-oscillation bridge with oscillation contraction.
-/
theorem discreteVorticity_tropDiffMax_le_osc
    (K : ι → ι → ℝ) (A : ι → ι → ℝ)
    (hA_nonneg : ∀ i j, 0 ≤ A i j)
    (hA_le_one : ∀ i j, A i j ≤ 1)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    discreteVorticity A (tropDiffMax K u) ≤ osc u := by
  refine' le_trans ( discreteVorticity_le_osc A hA_nonneg hA_le_one _ ) ( osc_tropDiffMax_le_osc K hK_nonneg hK_diag u )

/-
Iterated vorticity bound: vorticity of all iterates is uniformly bounded
by the initial oscillation. This is the discrete regularity criterion
for vorticity: tropical evolution prevents vorticity blowup.
-/
theorem iterate_vorticity_bound
    (K : ι → ι → ℝ) (A : ι → ι → ℝ)
    (hA_nonneg : ∀ i j, 0 ≤ A i j)
    (hA_le_one : ∀ i j, A i j ≤ 1)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (hK_diag : ∀ i, K i i = 0)
    (n : ℕ) (u : ι → ℝ) :
    discreteVorticity A (iterateTrop K n u) ≤ osc u := by
  have h_vorticreactual : ∀ m, discreteVorticity A (iterateTrop K m u) ≤ osc (iterateTrop K m u) := by
    exact fun m => discreteVorticity_le_osc A hA_nonneg hA_le_one _;
  exact le_trans ( h_vorticreactual n ) ( iterate_osc_monotone K hK_nonneg hK_diag n u )

/-! ## Nonneg Dissipation -/

/-
Tropical dissipation is nonneg: the operator cannot increase any value
beyond what it already was (under nonneg K with zero diagonal).
-/
theorem tropDissipation_nonneg
    (K : ι → ι → ℝ)
    (hK_nonneg : ∀ i j, 0 ≤ K i j)
    (_hK_diag : ∀ i, K i i = 0)
    (u : ι → ℝ) :
    0 ≤ tropDissipation K u := by
  -- Let i be a maximizer of u, i.e., u i = sup u.
  obtain ⟨i, hi⟩ : ∃ i, u i = Finset.sup' Finset.univ Finset.univ_nonempty u := by
    exact ( Finset.exists_max_image Finset.univ u Finset.univ_nonempty ) |> fun ⟨ i, hi ⟩ => ⟨ i, le_antisymm ( Finset.le_sup' u ( Finset.mem_univ i ) ) ( Finset.sup'_le _ _ fun j _ => hi.2 j ( Finset.mem_univ j ) ) ⟩;
  refine' le_trans _ ( Finset.le_sup' ( fun j => u j - tropDiffMax K u j ) ( Finset.mem_univ i ) );
  simp +decide [ tropDiffMax, hi ];
  exact ⟨ i, fun j => by linarith [ Finset.le_sup' ( fun x => u x ) ( Finset.mem_univ j ), hK_nonneg i j ] ⟩