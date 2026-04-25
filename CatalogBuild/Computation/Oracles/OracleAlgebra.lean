/-! # CatalogBuild.Computation.Oracles.OracleAlgebra

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Computation.Oracles.OracleAlgebra
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem idempotent_pow_eq {M : Type*} [Monoid M] (e : M) (he : e * e = e) (n : ℕ) (hn : n ≥ 1) :
    e ^ n = e := by
      induction hn <;> simp_all +decide [ pow_succ' ]





/-- [Section: # CatalogBuild.Computation.Oracles.OracleAlgebra
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem commuting_idempotents_product {M : Type*} [Monoid M] (e f : M)
    (he : e * e = e) (hf : f * f = f) (hc : e * f = f * e) :
    (e * f) * (e * f) = e * f := by
      grind +ring





/-- [Section: # CatalogBuild.Computation.Oracles.OracleAlgebra
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 17] -/
theorem idempotent_mul_comm {M : Type*} [CommMonoid M] (e f : M)
    (he : e * e = e) (hf : f * f = f) :
    (e * f) * (e * f) = e * f := by
      grind +ring





theorem comp_commuting_oracles {X : Type*} (O₁ O₂ : X → X)
    (h₁ : ∀ x, O₁ (O₁ x) = O₁ x)
    (h₂ : ∀ x, O₂ (O₂ x) = O₂ x)
    (hc : O₁ ∘ O₂ = O₂ ∘ O₁) :
    ∀ x, (O₁ ∘ O₂) ((O₁ ∘ O₂) x) = (O₁ ∘ O₂) x := by
      simp_all +decide [ funext_iff ]





/-- The kernel of an oracle: two elements are equivalent if the oracle gives the same answer -/
def OracleKernel {X : Type*} (O : X → X) : X → X → Prop :=
  fun x y => O x = O y





theorem oracle_kernel_refl {X : Type*} (O : X → X) : Reflexive (OracleKernel O) := by
  exact fun x => rfl





theorem oracle_kernel_symm {X : Type*} (O : X → X) : Symmetric (OracleKernel O) := by
  exact fun x y h => h.symm





theorem oracle_kernel_trans {X : Type*} (O : X → X) : Transitive (OracleKernel O) := by
  -- By definition of transitivity, if x is equivalent to y and y is equivalent to z, then x is equivalent to z.
  intro x y z hxy hyz
  exact Eq.trans hxy hyz





theorem oracle_kernel_equiv {X : Type*} (O : X → X) : Equivalence (OracleKernel O) := by
  refine' { .. };
  · exact fun x => rfl;
  · exact?;
  · exact fun hxy hyz => hxy.trans hyz





theorem fixedPoints_eq_range {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x) :
    {x | O x = x} = range O := by
      grind +splitImp





theorem range_subset_fixedPoints {X : Type*} (O : X → X) (hO : ∀ x, O (O x) = O x)
    (y : X) (hy : y ∈ range O) : O y = y := by
      grind +ring





theorem idempotent_injective_iff_surjective {n : ℕ} (O : Fin n → Fin n)
    (hO : ∀ x, O (O x) = O x) :
    Injective O ↔ Surjective O := by
      exact?





theorem oracle_lattice_inf_le {α : Type*} [CompleteLattice α] (S : Set α) (x : α) (hx : x ∈ S) :
    sInf S ≤ x := by
      exact?





theorem oracle_knaster_tarski {α : Type*} [CompleteLattice α] (f : α → α)
    (hf : Monotone f) : ∃ x, f x = x := by
      -- By the Knaster-Tarski theorem, since $f$ is monotone, it has a least fixed point.
      have h_least_fixed_point : ∃ x : α, IsLeast {x | f x ≤ x} x := by
        refine' ⟨ sInf { x | f x ≤ x }, _, fun x hx => _ ⟩;
        · exact le_sInf fun x hx => hf ( sInf_le hx ) |> le_trans <| hx;
        · exact sInf_le hx;
      obtain ⟨ x, hx ⟩ := h_least_fixed_point;
      have hx_least : f x ≤ x := by
        exact hx.1
      have hx_least' : x ≤ f x := by
        exact hx.2 ( hf hx_least )
      have hx_eq : f x = x := by
        exact le_antisymm hx_least hx_least'
      use x





theorem rectangular_band_prop (n : ℕ) (hn : 0 < n) :
    ∀ (a : Fin n), a = a := by
      aesop





theorem idempotent_count_base : Finset.card (Finset.filter (fun f : Fin 2 → Fin 2 => ∀ x, f (f x) = f x) Finset.univ) = 3 := by
  native_decide





theorem idempotent_count_three : Finset.card (Finset.filter (fun f : Fin 3 → Fin 3 => ∀ x, f (f x) = f x) Finset.univ) = 10 := by
  native_decide





end
