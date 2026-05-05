import Mathlib
import Bridges.MaxPlusDefs
import Bridges.MaxPlusLemmas
import Bridges.EigenvectorIteration
import Bridges.PerronTheorem

/-!
# EML Spectral Duality: Lifting Max-Plus Eigenvectors to EML Endomorphisms

This file establishes the bridge between finite max-plus spectral theory
and finitely generated EML (Exp-Minus-Log) semiring endomorphisms.

## Key insight: left vs right eigenvectors

The **right eigenvector** `v` satisfies `(M ⊗ v)ᵢ = μ + vᵢ`, i.e.,
`max_j(M_ij + v_j) = μ + v_i` for all `i`.

The **left eigenvector** `w` satisfies `(Mᵀ ⊗ w)_j = μ + w_j`, i.e.,
`max_i(M_ij + w_i) = μ + w_j` for all `j`.

The tropical character `χ(x) = max_j(x_j + w_j)` built from the LEFT
eigenvector satisfies the eigencharacter equation:

  `χ(M ⊗ x) = μ + χ(x)`

for ALL coordinate vectors `x`. This is the spectral duality.

## Main results

* `character_eigenequation` - the eigencharacter equation using left eigenvector
* `spectral_duality_on_generators` - spectral duality for EML generators
* `iterate_spectral_law` - k-fold iterate shifts character by `k·μ`
-/

noncomputable section

open Finset BigOperators

variable {n : ℕ}

/-! ### Finitely generated invariant presentation -/

/-- A finitely generated invariant presentation of an operator `T : A → A`. -/
structure FinGenPresentation (A : Type*) (T : A → A) where
  dim : ℕ
  hdim : 0 < dim
  gens : Fin dim → A
  coeff : Matrix (Fin dim) (Fin dim) ℝ

/-! ### Tropical character from left eigenvector -/

/-- Tropical character defined by a weight vector `w`:
    `χ(x) = max_j(x_j + w_j)`. -/
def tropicalChar (hn : 0 < n) (w : Fin n → ℝ) (x : Fin n → ℝ) : ℝ :=
  Finset.univ.sup' (univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩) (fun j => x j + w j)

/-
Tropical character commutes with adding a constant to the coordinate vector.
-/
theorem tropicalChar_shift (hn : 0 < n) (w : Fin n → ℝ) (x : Fin n → ℝ) (c : ℝ) :
    tropicalChar hn w (fun j => c + x j) = c + tropicalChar hn w x := by
  unfold tropicalChar; simp +decide [ add_assoc ] ;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.sup'_le_iff, Finset.le_sup' ];
  · exact fun i => ⟨ i, le_rfl ⟩;
  · simpa using Finset.exists_max_image Finset.univ ( fun i => x i + w i ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩

/-
**Eigencharacter equation**: If `w` is a LEFT eigenvector of `M`
    (i.e., an eigenvector of `Mᵀ`), then the tropical character
    `χ(x) = max_j(x_j + w_j)` satisfies `χ(M ⊗ x) = μ + χ(x)`.

    Proof: `χ(M ⊗ x) = max_j((M ⊗ x)_j + w_j) = max_j(max_i(M_ji + x_i) + w_j)`
    `= max_{i,j}(M_ji + x_i + w_j) = max_i(x_i + max_j(M_ji + w_j))`
    `= max_i(x_i + (Mᵀ ⊗ w)_i) = max_i(x_i + μ + w_i) = μ + max_i(x_i + w_i) = μ + χ(x)`.
-/
theorem character_eigenequation (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (mu : ℝ)
    (hw : ∀ j, maxPlusMul M.transpose w hn j = mu + w j)
    (x : Fin n → ℝ) :
    tropicalChar hn w (maxPlusMul M x hn) = mu + tropicalChar hn w x := by
  refine' le_antisymm _ _;
  · unfold tropicalChar maxPlusMul at *;
    simp_all +decide [ Finset.sup'_add ];
    intro i j; specialize hw j; simp_all +decide [ add_assoc, Finset.sup'_le_iff ] ;
    linarith [ Finset.le_sup' ( fun x => M x j + w x ) ( Finset.mem_univ i ), Finset.le_sup' ( fun j => x j + w j ) ( Finset.mem_univ j ) ];
  · unfold tropicalChar;
    obtain ⟨ i, hi ⟩ := Finset.exists_max_image Finset.univ ( fun j => x j + w j ) ⟨ ⟨ 0, hn ⟩, Finset.mem_univ _ ⟩;
    -- By definition of $maxPlusMul$, we know that $maxPlusMul M x hn j \geq M j i + x i$ for all $j$.
    have h_maxPlusMul_ge : ∀ j, maxPlusMul M x hn j ≥ M j i + x i := by
      exact fun j => Finset.le_sup' ( fun k => M j k + x k ) ( Finset.mem_univ i );
    have := Finset.exists_max_image Finset.univ ( fun j => M j i + w j ) ⟨ i, Finset.mem_univ _ ⟩ ; obtain ⟨ j, hj ⟩ := this; simp_all +decide [ Finset.le_sup'_iff ] ;
    have := hw i; unfold maxPlusMul at this; simp_all +decide [ Finset.le_sup'_iff ] ;
    exact ⟨ j, by linarith [ hi i, hj i, h_maxPlusMul_ge j, show ( univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ i ⟩ ) fun j => x j + w j ) = x i + w i from le_antisymm ( Finset.sup'_le _ _ fun j _ => hi j ) ( Finset.le_sup' ( fun j => x j + w j ) ( Finset.mem_univ i ) ), show ( univ.sup' ( Finset.univ_nonempty_iff.mpr ⟨ i ⟩ ) fun j => M j i + w j ) = M j i + w j from le_antisymm ( Finset.sup'_le _ _ fun j _ => hj j ) ( Finset.le_sup' ( fun j => M j i + w j ) ( Finset.mem_univ j ) ) ] ⟩

/-! ### Spectral duality for EML endomorphisms -/

/-- **Spectral duality on generators**: Given a presentation `P` and a
    left eigenvector `w` of `P.coeff`, the character `χ` satisfies
    `χ(T(gᵢ)-coords) = μ + χ(gᵢ-coords)` for each generator `gᵢ`. -/
theorem spectral_duality_on_generators {A : Type*} {T : A → A}
    (P : FinGenPresentation A T)
    (w : Fin P.dim → ℝ) (mu : ℝ)
    (hw : ∀ j, maxPlusMul P.coeff.transpose w P.hdim j = mu + w j) :
    ∀ (coords : Fin P.dim → ℝ),
      tropicalChar P.hdim w (maxPlusMul P.coeff coords P.hdim) =
      mu + tropicalChar P.hdim w coords :=
  fun coords => character_eigenequation P.hdim P.coeff w mu hw coords

/-! ### Iterate spectral law -/

/-
**Iterate spectral law**: The character of the k-th iterate shifts
    by `k·μ`. This establishes the asymptotic spectral growth law
    for EML endomorphisms.
-/
theorem iterate_spectral_law (hn : 0 < n)
    (M : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (mu : ℝ)
    (hw : ∀ j, maxPlusMul M.transpose w hn j = mu + w j)
    (x : Fin n → ℝ) (k : ℕ) :
    tropicalChar hn w (iterMaxPlusMul hn M k x) =
      k * mu + tropicalChar hn w x := by
  induction' k with k ih;
  · unfold iterMaxPlusMul; aesop;
  · convert character_eigenequation hn M w mu hw ( iterMaxPlusMul hn M k x ) using 1 ; push_cast [ ih ] ; ring

end