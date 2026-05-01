/-! # CatalogBuild.Algebra.SciFi.SETIOrthogonality

Auto-generated from theorem catalog database.
Domain: Algebra/SciFi
Declarations: 1
-/

import Mathlib

/-- [Section: # CatalogBuild.Speculative.SciFi.SETIOrthogonality
Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 1
Research Arc: Cryptographic Gravity
Novelty: 0.95] -/
theorem seti_orthogonality_decomposition
    {q : ℕ} [NeZero q] [Fintype (ZMod q)ˣ]
    (χ ψ : DirichletCharacter ℂ q) (h : χ ≠ ψ) :
    ∑ a : (ZMod q)ˣ, χ a * ψ (a⁻¹) = 0 := by
  -- Recognize that the sum can be rewritten using the properties of characters.
  have h_rewrite : ∑ a : (ZMod q)ˣ, χ a * ψ (a⁻¹) = ∑ a : (ZMod q)ˣ, (χ * ψ⁻¹) a := by
    simp +decide [MulChar.mul_apply, MulChar.inv_apply];
  -- Since $\chi \neq \psi$, we have $\chi * \psi⁻¹ \neq 1$.
  have h_ne_one : χ * ψ⁻¹ ≠ 1 := by
    exact fun h' => h <| by simpa using eq_inv_of_mul_eq_one_left h';
  convert MulChar.sum_eq_zero_of_ne_one h_ne_one;
  rw [ ← Finset.sum_subset ( Finset.subset_univ ( Finset.image ( fun x : ( ZMod q ) ˣ => ( x : ZMod q ) ) Finset.univ ) ) ];
  · rw [ Finset.sum_image ] ; aesop;
    exact fun x _ y _ hxy => Units.ext hxy;
  · simp +contextual [ DirichletCharacter ];
    intro x hx; haveI := Fact.mk ( NeZero.pos q ) ; exact Or.inl ( χ.map_nonunit <| by contrapose! hx; aesop ) ;
