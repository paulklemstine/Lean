import Mathlib

/-!
# Tropical Functorial Surgery Calculus

This file formalizes the **tropical functorial surgery calculus**: the theorem that
sequential composition of surgeries corresponds exactly to min-plus (tropical)
matrix multiplication.

## Main Definitions

* `Surgery α β` — a surgery from boundary states `α` to boundary states `β`,
  consisting of a cost kernel `α → β → ℝ`.
* `Surgery.comp` — composition of two surgeries via Bellman-style minimization
  over intermediate states.
* `updateMatrix` — extracts the cost matrix from a surgery on finite index types.
* `minPlusMul` — tropical (min-plus) matrix multiplication.

## Main Results

* `updateMatrix_comp_minPlus` — the central functoriality theorem: the update matrix
  of a composed surgery equals the min-plus product of the individual update matrices.
* `minPlusMul_assoc` — min-plus matrix multiplication is associative.
* `Surgery.comp_assoc` — surgery composition is associative.
* `minPlusMul_mono` — min-plus multiplication is monotone in both arguments.
* `updateMatrix_triple_comp` — three-stage surgery equals nested Bellman update.

## Cross-Domain Significance

This formalization establishes a **functor** from a category of surgeries (finite-state
cost kernels composed by Bellman minimization) to the category of tropical linear operators
(matrices composed by min-plus multiplication). This is the tropicalization of functorial
field theory: where ordinary TQFTs assign linear maps to cobordisms, tropical surgery
theory assigns min-plus linear operators.

The key identity `(A ⊛ B)(i,k) = min_j (A(i,j) + B(j,k))` is the Bellman equation,
connecting surgery calculus to dynamic programming, shortest-path algorithms, weighted
automata, and variational principles.
-/

noncomputable section

open Finset

/-! ## Surgery Definition -/

/-- A surgery from boundary states `α` to boundary states `β` is a cost kernel:
for each input state `a : α` and output state `b : β`, the value `cost a b` represents
the cost of transitioning from `a` to `b` through the surgery. -/
structure Surgery (α β : Type*) where
  /-- The cost kernel of the surgery -/
  cost : α → β → ℝ

/-! ## Min-Plus Matrix Multiplication -/

/-- Min-plus (tropical) matrix multiplication. The entry `(i, k)` of the product is
the minimum over all intermediate indices `j` of `A i j + B j k`. This is the
Bellman composition / tropical convolution of two cost matrices.

Requires `NeZero n` to ensure the intermediate index set `Fin n` is nonempty. -/
def minPlusMul {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    Matrix (Fin m) (Fin p) ℝ :=
  fun i k => Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + B j k)

/-- Entrywise characterization of min-plus matrix multiplication. -/
theorem minPlusMul_apply {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (i : Fin m) (k : Fin p) :
    minPlusMul A B i k =
      Finset.inf' Finset.univ Finset.univ_nonempty (fun j => A i j + B j k) := by
  rfl

/-! ## Surgery Composition -/

/-- Composition of two surgeries via Bellman minimization over intermediate states.
Given surgeries `S₁ : Surgery α β` and `S₂ : Surgery β γ`, the composed surgery
has cost `(S₂ ∘ S₁)(a, c) = min_b (S₁(a, b) + S₂(b, c))`.

This is the dynamic-programming composition: the cheapest way to go from `a` to `c`
through the two-stage pipeline is to minimize over all intermediate states `b`. -/
def Surgery.comp {α β γ : Type*} [Fintype β] [Nonempty β]
    (S₁ : Surgery α β) (S₂ : Surgery β γ) : Surgery α γ where
  cost a c := Finset.inf' Finset.univ Finset.univ_nonempty
    (fun b => S₁.cost a b + S₂.cost b c)

/-! ## Update Matrix -/

/-- Extract the update matrix from a surgery on finite index types.
This is simply the cost kernel viewed as a matrix. -/
def updateMatrix {m n : ℕ} (S : Surgery (Fin m) (Fin n)) :
    Matrix (Fin m) (Fin n) ℝ :=
  fun i j => S.cost i j

/-- Entrywise characterization of the update matrix of a composed surgery. -/
theorem updateMatrix_comp_apply {m n p : ℕ} [NeZero n]
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p))
    (i : Fin m) (k : Fin p) :
    updateMatrix (Surgery.comp S₁ S₂) i k =
      Finset.inf' Finset.univ Finset.univ_nonempty
        (fun j => updateMatrix S₁ i j + updateMatrix S₂ j k) := by
  rfl

/-! ## Main Functoriality Theorem -/

/-
**Tropical Functoriality Theorem**: The update matrix of a composed surgery
equals the min-plus product of the individual update matrices.

This is the central result: surgery composition is sent to tropical matrix
multiplication. Symbolically:
  `updateMatrix(S₂ ∘ S₁) = updateMatrix(S₁) ⊛ updateMatrix(S₂)`

This establishes that `updateMatrix` is a functor from the category of surgeries
(with Bellman composition) to the category of tropical matrices (with min-plus
multiplication).
-/
theorem updateMatrix_comp_minPlus {m n p : ℕ} [NeZero n]
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p)) :
    updateMatrix (Surgery.comp S₁ S₂) = minPlusMul (updateMatrix S₁) (updateMatrix S₂) := by
  exact funext fun i => funext fun k => updateMatrix_comp_apply S₁ S₂ i k

/-! ## Algebraic Properties of Min-Plus Multiplication -/

/-
Addition distributes over finite infimum: `c + inf S = inf (c + S)`.
This is the key algebraic identity underlying tropical linearity.
-/
theorem add_finset_inf' {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (f : ι → ℝ) (c : ℝ) :
    c + s.inf' hs f = s.inf' hs (fun i => c + f i) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · exact Finset.exists_min_image _ _ hs

/-
Right-addition distributes over finite infimum.
-/
theorem finset_inf'_add {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (f : ι → ℝ) (c : ℝ) :
    s.inf' hs f + c = s.inf' hs (fun i => f i + c) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩;
  · exact Finset.exists_min_image _ _ hs

/-
**Associativity of min-plus matrix multiplication**.
This is the tropical analogue of ordinary matrix multiplication associativity,
and is essential for the categorical structure of tropical linear algebra.

The proof expands both sides entrywise and uses the fact that addition distributes
over finite infima, allowing reassociation of the nested minimizations.
-/
theorem minPlusMul_assoc {m n p q : ℕ} [NeZero n] [NeZero p]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ)
    (C : Matrix (Fin p) (Fin q) ℝ) :
    minPlusMul (minPlusMul A B) C = minPlusMul A (minPlusMul B C) := by
  ext i k;
  simp +decide only [minPlusMul_apply, add_finset_inf', finset_inf'_add];
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · exact fun j l => ⟨ l, j, by linarith ⟩;
  · exact fun b c => ⟨ c, b, by ring_nf; norm_num ⟩

/-! ## Surgery Composition is Associative -/

/-
Surgery composition is associative, which follows directly from
the associativity of min-plus multiplication via the functoriality theorem.
-/
theorem Surgery.comp_assoc {α β γ δ : Type*}
    [Fintype β] [Nonempty β] [Fintype γ] [Nonempty γ]
    (S₁ : Surgery α β) (S₂ : Surgery β γ) (S₃ : Surgery γ δ) :
    Surgery.comp (Surgery.comp S₁ S₂) S₃ = Surgery.comp S₁ (Surgery.comp S₂ S₃) := by
  cases' S₁ with f₁;
  cases' S₂ with f₂;
  cases' S₃ with f₃;
  unfold Surgery.comp;
  congr with a c;
  refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
  · intro b;
    obtain ⟨ i, hi ⟩ := Finset.exists_mem_eq_inf' ( Finset.univ_nonempty ) ( fun x => f₂ b x + f₃ x c );
    exact ⟨ i, by linarith [ Finset.inf'_le ( fun x => f₁ a x + f₂ x i ) ( Finset.mem_univ b ) ] ⟩;
  · intro b;
    obtain ⟨ i, hi ⟩ := Finset.exists_min_image Finset.univ ( fun x => f₁ a x + f₂ x b ) ⟨ Classical.arbitrary β, Finset.mem_univ _ ⟩;
    grind +suggestions

/-! ## Monotonicity -/

/-
**Monotonicity of min-plus multiplication**: if every entry of `A` is at most the
corresponding entry of `A'`, and similarly for `B` vs `B'`, then every entry of
`A ⊛ B` is at most the corresponding entry of `A' ⊛ B'`.

This means surgery cost propagation is stable under perturbations: making individual
surgery costs cheaper cannot make the overall pipeline more expensive.
-/
theorem minPlusMul_mono {m n p : ℕ} [NeZero n]
    {A A' : Matrix (Fin m) (Fin n) ℝ}
    {B B' : Matrix (Fin n) (Fin p) ℝ}
    (hA : ∀ i j, A i j ≤ A' i j)
    (hB : ∀ j k, B j k ≤ B' j k) :
    ∀ i k, minPlusMul A B i k ≤ minPlusMul A' B' i k := by
  unfold minPlusMul;
  norm_num [ ← add_assoc, hA, hB ];
  exact fun i k b => ⟨ b, add_le_add ( hA i b ) ( hB b k ) ⟩

/-! ## Three-Stage Composition Corollary -/

/-
**Three-stage surgery composition theorem**: composing three surgeries and taking
the update matrix gives the same result as computing three nested min-plus products.
This is a direct corollary of the functoriality theorem applied twice.
-/
theorem updateMatrix_triple_comp {m n p q : ℕ} [NeZero n] [NeZero p]
    (S₁ : Surgery (Fin m) (Fin n))
    (S₂ : Surgery (Fin n) (Fin p))
    (S₃ : Surgery (Fin p) (Fin q)) :
    updateMatrix (Surgery.comp (Surgery.comp S₁ S₂) S₃) =
      minPlusMul (minPlusMul (updateMatrix S₁) (updateMatrix S₂)) (updateMatrix S₃) := by
  -- Apply the functoriality theorem twice to conclude the proof.
  apply updateMatrix_comp_minPlus

/-! ## Min-Plus Duality -/

/-
Negation transforms min-plus into max-plus: the minimum of negated values
is the negation of the maximum. This connects tropical surgery semantics
(cost minimization) with max-plus semantics (energy maximization).
-/
theorem neg_inf'_eq_sup'_neg {ι : Type*} {s : Finset ι} (hs : s.Nonempty)
    (f : ι → ℝ) :
    -(s.inf' hs f) = s.sup' hs (fun i => -(f i)) := by
  refine' le_antisymm _ _ <;> simp_all +decide [ Finset.inf'_le, Finset.le_sup' ];
  · exact Finset.exists_min_image _ _ hs;
  · exact fun b hb => ⟨ b, hb, le_rfl ⟩

/-
**Min-plus to max-plus duality for matrix multiplication**: negating all entries
transforms min-plus multiplication into max-plus multiplication with negated matrices.
This is the formal bridge between cost-minimization and energy-maximization
interpretations of surgery propagation.
-/
theorem minPlusMul_neg_duality {m n p : ℕ} [NeZero n]
    (A : Matrix (Fin m) (Fin n) ℝ)
    (B : Matrix (Fin n) (Fin p) ℝ) :
    ∀ i k, -(minPlusMul A B i k) =
      Finset.sup' Finset.univ Finset.univ_nonempty
        (fun j => -(A i j) + -(B j k)) := by
  intro i k;
  convert neg_inf'_eq_sup'_neg _ _ using 2;
  ring

end