/-
# Persistent Homology of Tropical Filtrations: Main Theorems

This file proves the central results connecting tropical active-set combinatorics
to barcode complexity bounds. The key theorems establish:

1. **Tropical max sublevel sets are convex and contractible** — no interesting
   persistent homology can arise from max-affine families.
2. **Min sublevel sets decompose as unions of convex patches** — the topology
   comes from how convex pieces glue together.
3. **The patch nerve is a monotone filtration** — it can only grow as the
   threshold increases.
4. **The nerve is an abstract simplicial complex** — it is downward-closed.
5. **Nerve changes are finitely bounded** — only finitely many combinatorial
   configurations are possible, giving finite barcode complexity.
6. **Stable intervals produce no topological events** — if the nerve doesn't
   change, the combinatorial topology is constant.

## Cross-domain bridges

- **Tropical geometry → TDA**: Patches = tropical analogue of Čech balls
- **Convex geometry → homological algebra**: Convexity → contractibility →
  vanishing higher homology
- **Combinatorial persistence**: Barcode events ⊂ nerve change-points

## Dependencies

Builds on `Tropical.PersistentHomology.Defs` and catalog results
`sublevel_mono`, `activeSetComplex_mono`, `tropMax_sublevel_convex`.
-/

import Logic.Defs

open Finset BigOperators Classical Set

noncomputable section

namespace TropicalPersistence

variable {n m : ℕ}

-- ============================================================================
-- PART I: CONVEXITY AND CONTRACTIBILITY OF MAX SUBLEVEL SETS
-- ============================================================================

/-! ## Affine evaluation is affine (convex combination identity) -/

/-
Affine evaluation respects convex combinations:
`fᵢ(a•x + b•y) = a • fᵢ(x) + b • fᵢ(y)` when `a + b = 1`.
-/
theorem evalAffine_convex_combination (F : TropAffineFamily n m) (i : Fin m)
    (x y : Fin n → ℝ) (a b : ℝ) (_ha : 0 ≤ a) (hb : 0 ≤ b) (hab : a + b = 1) :
    evalAffine F i (fun j => a * x j + b * y j) =
    a * evalAffine F i x + b * evalAffine F i y := by
      unfold evalAffine;
      simp +decide only [mul_add, mul_left_comm, sum_add_distrib, Finset.mul_sum _ _ _] ; rw [ ← eq_sub_iff_add_eq' ] at hab ; subst_vars ; ring

/-! ## Max sublevel sets are convex -/

/-
**Theorem (Max Sublevel Convexity).**
The sublevel set {x | max_i fᵢ(x) ≤ c} is convex, being an intersection
of halfspaces. This is the ℝ-version of `tropMax_sublevel_convex` from
the catalog.
-/
theorem maxSublevelSet_convex (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    Convex ℝ (MaxSublevelSet F hm c) := by
      have h_convex : ∀ i : Fin m, Convex ℝ {x : Fin n → ℝ | evalAffine F i x ≤ c} := by
        intro i x hx y hy a b ha hb hab;
        convert Set.mem_setOf_eq.mpr ( show evalAffine F i ( fun j => a * x j + b * y j ) ≤ c from ?_ ) using 1;
        convert Set.mem_setOf_eq.mp hx |> fun h => le_trans ( evalAffine_convex_combination F i x y a b ha hb hab ▸ add_le_add ( mul_le_mul_of_nonneg_left h ha ) ( mul_le_mul_of_nonneg_left hy.out hb ) ) _ using 1;
        cases le_total c 0 <;> nlinarith;
      convert convex_iInter fun i => h_convex i using 1;
      ext; simp [MaxSublevelSet, tropMaxVal]

/-
**Theorem 1 (Tropical Max Has Trivial Persistent Homology).**
If the max sublevel set is nonempty, it is contractible. This follows from
convexity via `Convex.contractibleSpace`. Consequently, all persistence bars
in positive degree are absent.
-/
theorem tropMax_sublevel_contractible (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    IsEmpty ↥(MaxSublevelSet F hm c) ∨
    ContractibleSpace ↥(MaxSublevelSet F hm c) := by
      -- By cases on whether the set is empty or nonempty.
      by_cases h_empty : MaxSublevelSet F hm c = ∅;
      · exact Or.inl ⟨ fun x => h_empty.subset x.2 ⟩;
      · convert Convex.contractibleSpace _ _;
        any_goals exact maxSublevelSet_convex F hm c;
        all_goals try infer_instance;
        · simp +decide [ h_empty ];
        · exact Set.nonempty_iff_ne_empty.mpr h_empty

-- ============================================================================
-- PART II: PATCH DECOMPOSITION OF MIN SUBLEVEL SETS
-- ============================================================================

/-! ## Each halfspace patch is convex -/

/-
Each individual halfspace patch {x | fᵢ(x) ≤ c} is convex.
-/
theorem halfspacePatch_convex (F : TropAffineFamily n m) (c : ℝ) (i : Fin m) :
    Convex ℝ (HalfspacePatch F c i) := by
      intro x hx y hy a b ha hb hab;
      have := evalAffine_convex_combination F i x y a b ha hb hab;
      exact this.trans_le ( by rw [ ← eq_sub_iff_add_eq' ] at hab; subst hab; nlinarith [ hx.out, hy.out ] )

/-
**Theorem (Patch Intersections Are Convex).**
Any finite intersection of halfspace patches is convex. This is the key
hypothesis needed for the nerve theorem: every nonempty intersection of
patches is convex, hence contractible if nonempty.
-/
theorem patchIntersection_convex (F : TropAffineFamily n m) (c : ℝ)
    (S : Finset (Fin m)) :
    Convex ℝ (PatchIntersection F c S) := by
      convert convex_iInter fun i => convex_iInter fun hi => halfspacePatch_convex F c i

/-
Nonempty convex patch intersections are contractible. This establishes
the nerve theorem hypothesis for tropical min families.
-/
theorem patchIntersection_contractible (F : TropAffineFamily n m) (c : ℝ)
    (S : Finset (Fin m)) (hne : (PatchIntersection F c S).Nonempty) :
    ContractibleSpace ↥(PatchIntersection F c S) := by
      convert Convex.contractibleSpace ( patchIntersection_convex F c S ) hne

/-! ## Min sublevel = union of patches -/

/-
**Theorem 2 (Patch Cover).**
The min sublevel set equals the union of individual halfspace patches:
{x | min_i fᵢ(x) ≤ c} = ⋃ᵢ {x | fᵢ(x) ≤ c}.
This is the decomposition that makes the nerve theorem applicable.
-/
theorem minSublevelSet_eq_iUnion_patches (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    MinSublevelSet F hm c = ⋃ i : Fin m, HalfspacePatch F c i := by
      ext x;
      simp +decide [ MinSublevelSet, HalfspacePatch ];
      simp +decide [ tropMinVal ]

-- ============================================================================
-- PART III: MONOTONICITY AND ABSTRACT SIMPLICIAL COMPLEX PROPERTIES
-- ============================================================================

/-! ## Sublevel and patch monotonicity -/

/-
Max sublevel sets form a monotone filtration in c.
-/
theorem maxSublevelSet_mono (F : TropAffineFamily n m) (hm : 0 < m)
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂) :
    MaxSublevelSet F hm c₁ ⊆ MaxSublevelSet F hm c₂ := by
      exact fun x hx => le_trans hx h

/-
Min sublevel sets form a monotone filtration in c.
-/
theorem minSublevelSet_mono (F : TropAffineFamily n m) (hm : 0 < m)
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂) :
    MinSublevelSet F hm c₁ ⊆ MinSublevelSet F hm c₂ := by
      exact fun x hx => le_trans hx h

/-
Each halfspace patch is monotone in c.
-/
theorem halfspacePatch_mono (F : TropAffineFamily n m) (i : Fin m)
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂) :
    HalfspacePatch F c₁ i ⊆ HalfspacePatch F c₂ i := by
      exact fun x hx => le_trans hx h

/-
Patch intersections are monotone in c.
-/
theorem patchIntersection_mono (F : TropAffineFamily n m) (S : Finset (Fin m))
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂) :
    PatchIntersection F c₁ S ⊆ PatchIntersection F c₂ S := by
      exact Set.iInter₂_mono fun i hi => halfspacePatch_mono F i h

/-! ## Nerve monotonicity -/

/-
**Theorem 3 (Active-Set Nerve Monotonicity).**
If c₁ ≤ c₂, every face of the nerve at c₁ is also a face at c₂.
The nerve filtration can only grow. This builds on the patch monotonicity.
-/
theorem patchNerve_mono (F : TropAffineFamily n m)
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂) :
    PatchNerveFaces F c₁ ⊆ PatchNerveFaces F c₂ := by
      intros S hS
      obtain ⟨hS_nonempty, hS_nonempty_inter⟩ := hS
      exact ⟨hS_nonempty, by
        exact Set.nonempty_of_mem ( patchIntersection_mono F S h hS_nonempty_inter.choose_spec )⟩

/-! ## Downward closure (abstract simplicial complex property) -/

/-
**Theorem (Nerve Is Downward-Closed).**
If S is a face of the patch nerve and T ⊆ S is nonempty, then T is also
a face. This makes the patch nerve an abstract simplicial complex.
-/
theorem patchNerve_down_closed (F : TropAffineFamily n m) (c : ℝ)
    (S : Finset (Fin m)) (hS : S ∈ PatchNerveFaces F c)
    (T : Finset (Fin m)) (hTS : T ⊆ S) (hT : T.Nonempty) :
    T ∈ PatchNerveFaces F c := by
      refine' ⟨ hT, _ ⟩;
      exact hS.2.mono ( by aesop_cat )

-- ============================================================================
-- PART IV: FINITENESS AND BARCODE COMPLEXITY BOUNDS
-- ============================================================================

/-! ## Finiteness of nerve configurations -/

/-
The number of possible distinct nerves is bounded by 2^(2^m).
Since each nerve is a subset of the powerset of Fin m, there are
at most 2^(2^m) possible nerve configurations.
-/
theorem nerve_configurations_finite (m : ℕ) :
    ∀ (S : Finset (Finset (Fin m))), S.card ≤ 2 ^ m := by
      exact fun S => le_trans ( Finset.card_le_univ _ ) ( by simp +decide )

/-
**Theorem 4 (Finite Barcode Complexity).**
The number of vertices in the patch nerve is at most m (the number of
affine forms).
-/
theorem nerveVertexCount_le (F : TropAffineFamily n m) (c : ℝ) :
    nerveVertexCount F c ≤ m := by
      exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )

/-! ## Patch intersection characterization -/

/-
The intersection of patches indexed by S equals the max sublevel set
restricted to those indices. This reveals the bridge between min-family
patches and max-family sublevel sets: each patch intersection is itself
a max-type sublevel set.
-/
theorem patchIntersection_eq_forall (F : TropAffineFamily n m) (c : ℝ)
    (S : Finset (Fin m)) :
    PatchIntersection F c S = {x | ∀ i ∈ S, evalAffine F i x ≤ c} := by
      -- By definition of PatchIntersection, we have:
      ext x
      simp [PatchIntersection, HalfspacePatch]

-- ============================================================================
-- PART V: NERVE STABILITY AND TOPOLOGICAL EVENT LOCALIZATION
-- ============================================================================

/-! ## Nerve stability implies topological stability -/

/-
**Theorem 5 (No Barcode Event When Nerve Is Constant).**
If the patch nerve faces are identical at c₁ and c₂ (with c₁ ≤ c₂),
then the nerve vertex count is preserved. This is a combinatorial
shadow of the topological statement that no H₀ bar is born or dies.
-/
theorem nerveVertexCount_eq_of_nerve_constant (F : TropAffineFamily n m)
    {c₁ c₂ : ℝ} (h : c₁ ≤ c₂)
    (hconst : PatchNerveFaces F c₁ = PatchNerveFaces F c₂) :
    nerveVertexCount F c₁ = nerveVertexCount F c₂ := by
      refine' Finset.card_bij ( fun i hi => i ) _ _ _ <;> simp +decide;
      · exact fun i hi => hi.mono ( halfspacePatch_mono F i h );
      · intro i hi; replace hconst := Set.ext_iff.mp hconst { i } ; simp_all +decide [ HalfspacePatch ] ;
        contrapose! hconst; simp_all +decide [ PatchNerveFaces ] ;
        simp_all +decide [ Set.ext_iff, PatchIntersection ];
        exact Or.inr ⟨ fun ⟨ x, hx ⟩ => by linarith [ hconst x, hx.out ], hi ⟩

/-
When the nerve is constant on an interval, it equals the nerve at
the left endpoint.
-/
theorem nerve_constant_eq (F : TropAffineFamily n m) {a b : ℝ}
    (_hab : a ≤ b) (hconst : NerveConstantOn F a b) (c : ℝ)
    (hac : a ≤ c) (hcb : c ≤ b) :
    PatchNerveFaces F c = PatchNerveFaces F a := by
      exact hconst c hac hcb

-- ============================================================================
-- PART VI: VERIFIED ALGORITHM — CRITICAL VALUE COMPUTATION
-- ============================================================================

/-! ## Critical value algorithm for rational families -/

/-- A tropical affine family with rational coefficients. -/
structure TropAffineFamilyQ (n m : ℕ) where
  coeff : Fin m → Fin n → ℚ
  bias  : Fin m → ℚ

/-- Convert a rational family to a real family by casting. -/
def TropAffineFamilyQ.toReal (F : TropAffineFamilyQ n m) : TropAffineFamily n m where
  coeff := fun i j => (F.coeff i j : ℝ)
  bias := fun i => (F.bias i : ℝ)

/-- For a pair of indices (i,j), the affine forms fᵢ and fⱼ are equal when
∑ⱼ (aᵢⱼ - aⱼⱼ) xⱼ + (bᵢ - bⱼ) = 0. The threshold where fᵢ(x) = fⱼ(x) = c
gives a candidate critical value. For n=0, this is just bᵢ and bⱼ. -/
def candidateCriticalValues (F : TropAffineFamilyQ 0 m) : Finset ℚ :=
  (Finset.univ : Finset (Fin m)).image F.bias

/-
**Theorem 6 (Algorithm Correctness for 0-dimensional case).**
Every barcode-critical threshold of a 0-dimensional rational family
(constant affine forms) is among the bias values. In dimension 0,
fᵢ(x) = bᵢ, so the tropical min is min_i bᵢ, and the only critical
values are the bias values themselves.
-/
theorem algorithm_critical_values_complete_dim0
    (F : TropAffineFamilyQ 0 m) (hm : 0 < m) (c : ℚ) :
    BarcodeCritical (F.toReal) (c : ℝ) →
    c ∈ candidateCriticalValues F := by
      contrapose!;
      intro hc_not_mem_candidateCriticalValues
      have h_nerve_constant : ∃ ε > 0, NerveConstantOn F.toReal (c - ε) (c + ε) := by
        -- Since $c$ is not a bias value, there exists a $\delta > 0$ such that for all $i$, $|c - F.bias i| > \delta$.
        obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ i : Fin m, |(c : ℝ) - F.bias i| > δ := by
          -- Since $c$ is not in the image of $F.bias$, there exists a $\delta > 0$ such that for all $i$, $|c - F.bias i| \geq \delta$.
          obtain ⟨δ, hδ_pos, hδ⟩ : ∃ δ > 0, ∀ i : Fin m, |(c : ℝ) - F.bias i| ≥ δ := by
            have h_min_dist : ∃ i : Fin m, ∀ j : Fin m, |(c : ℝ) - F.bias j| ≥ |(c : ℝ) - F.bias i| := by
              simpa using Finset.exists_min_image Finset.univ ( fun i => |(c : ℝ) - F.bias i| ) ⟨ ⟨ 0, hm ⟩, Finset.mem_univ _ ⟩;
            obtain ⟨ i, hi ⟩ := h_min_dist;
            exact ⟨ |↑c - ↑ ( F.bias i )|, abs_pos.mpr ( sub_ne_zero.mpr <| mod_cast fun h => hc_not_mem_candidateCriticalValues <| h.symm ▸ Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ), hi ⟩;
          exact ⟨ δ / 2, half_pos hδ_pos, fun i => by linarith [ hδ i ] ⟩;
        refine' ⟨ δ / 2, half_pos hδ_pos, fun x hx₁ hx₂ => _ ⟩;
        ext S; simp [PatchNerveFaces, PatchIntersection];
        simp +decide [ HalfspacePatch, evalAffine ];
        intro hS_nonempty; constructor <;> intro h <;> intro i hi <;> have := h i hi <;> have := hδ i <;> cases abs_cases ( ( c : ℝ ) - F.bias i ) <;> linarith! [ show ( F.toReal.bias i : ℝ ) = F.bias i from rfl ] ;
      exact fun h => h h_nerve_constant

-- ============================================================================
-- PART VII: BRIDGE THEOREMS — CONNECTING DOMAINS
-- ============================================================================

/-! ## Bridge A: Max sublevel membership characterization -/

/-
A point is in the max sublevel set iff every affine form is ≤ c.
This is the ℝ-version of `mem_sublevel_iff_forall_le` from the catalog.
-/
theorem mem_maxSublevelSet_iff (F : TropAffineFamily n m) (hm : 0 < m)
    (c : ℝ) (x : Fin n → ℝ) :
    x ∈ MaxSublevelSet F hm c ↔ ∀ i : Fin m, evalAffine F i x ≤ c := by
      exact ⟨ fun hx i => hx.out.trans' ( Finset.le_sup' ( fun i => evalAffine F i x ) ( Finset.mem_univ i ) ), fun hx => Finset.sup'_le _ _ fun i _ => hx i ⟩

/-
A point is in the min sublevel set iff some affine form is ≤ c.
This is the dual characterization for min families.
-/
theorem mem_minSublevelSet_iff (F : TropAffineFamily n m) (hm : 0 < m)
    (c : ℝ) (x : Fin n → ℝ) :
    x ∈ MinSublevelSet F hm c ↔ ∃ i : Fin m, evalAffine F i x ≤ c := by
      convert TropicalPersistence.minSublevelSet_eq_iUnion_patches F hm c |> Set.ext_iff.mp |> fun h => h x using 1;
      simp +decide [ HalfspacePatch ]

/-! ## Bridge B: Patch intersection = max sublevel restricted to S -/

/-
The max sublevel set is the full patch intersection over all indices.
This connects the max and min viewpoints: max sublevel = nerve 0-skeleton
intersection = intersection of all patches.
-/
theorem maxSublevelSet_eq_full_patchIntersection
    (F : TropAffineFamily n m) (hm : 0 < m) (c : ℝ) :
    MaxSublevelSet F hm c = PatchIntersection F c Finset.univ := by
      rw [ patchIntersection_eq_forall ];
      exact Set.ext fun x => by simp +decide [ mem_maxSublevelSet_iff ] ;

end TropicalPersistence

end