/-
# The character-table reduction of the non-split case (abelian covers)

Conjecture C5 of `FUTURE_DIRECTIONS.md`.  The informal sentence "the non-split case reduces to
the split (character-twisted) case, with no loss in the exponent" becomes a theorem as soon as
one knows that the character table is an *invertible* transfer matrix.  Over `ℝ` this was
already available in the abstract (`exponent_of_inverse_transform`,
`transfer_iff_det_ne_zero`); the missing ingredient was the invertibility itself, which lives
over `ℂ` and comes from the orthogonality relations.

This file supplies the complex-valued half of the theory:

* `HasErrorExponentC` : the `ℂ`-valued analogue of `HasErrorExponent`, with the same calculus
  (`add`, `const_mul`, `sum`, `linear_comb`);
* `hasErrorExponentC_ofReal_iff` : it restricts to the real-valued notion;
* `exponentC_of_inverse_transform` : the transfer principle for a (possibly rectangular)
  complex transform admitting a left inverse;
* `charMatrix_left_inverse` : **the character table of a finite abelian group is invertible**,
  with explicit left inverse `(a, ψ) ↦ ψ(-a)/|α|`, proved from the orthogonality relation
  `∑_ψ ψ(a) = |α|·[a = 0]`;
* `hasErrorExponentC_character_iff` : consequently the twisted counting functions
  `π_ψ = ∑_a ψ(a) π_a` satisfy the estimate with exponent `θ` **iff** every individual
  `π_a` does;
* `chebotarev_abelian_character_reduction` : the real-valued statement for an abelian cover —
  since in an abelian group each conjugacy class is a single element, this is exactly the
  equivalence "non-split Chebotarev estimate ⟺ finitely many split (character-twisted)
  estimates", with no loss in the exponent.
-/

import Mathlib
import Catalog.Shared.ChebotarevGeodesic

open Finset Filter
open scoped Topology

namespace ChebotarevGeodesic

/-! ## The complex-valued exponent calculus -/

/-- The `ℂ`-valued analogue of `HasErrorExponent`. -/
def HasErrorExponentC (pi M : ℝ → ℂ) (θ : ℝ) : Prop :=
  ∀ ε > 0, ∃ C > 0, ∃ X ≥ (1 : ℝ), ∀ x ≥ X, ‖pi x - M x‖ ≤ C * x ^ (θ + ε)

variable {pi pi₁ pi₂ M M₁ M₂ : ℝ → ℂ} {θ : ℝ}

/-- The complex estimate is additive. -/
theorem HasErrorExponentC.add (h₁ : HasErrorExponentC pi₁ M₁ θ)
    (h₂ : HasErrorExponentC pi₂ M₂ θ) :
    HasErrorExponentC (fun x => pi₁ x + pi₂ x) (fun x => M₁ x + M₂ x) θ := by
  intro ε hε
  obtain ⟨C₁, hC₁, X₁, hX₁, hb₁⟩ := h₁ ε hε
  obtain ⟨C₂, hC₂, X₂, hX₂, hb₂⟩ := h₂ ε hε
  refine ⟨C₁ + C₂, by linarith, max X₁ X₂, le_trans hX₁ (le_max_left _ _), fun x hx => ?_⟩
  have hx1 : X₁ ≤ x := le_trans (le_max_left _ _) hx
  have hx2 : X₂ ≤ x := le_trans (le_max_right _ _) hx
  calc ‖pi₁ x + pi₂ x - (M₁ x + M₂ x)‖ = ‖(pi₁ x - M₁ x) + (pi₂ x - M₂ x)‖ := by ring_nf
    _ ≤ ‖pi₁ x - M₁ x‖ + ‖pi₂ x - M₂ x‖ := norm_add_le _ _
    _ ≤ C₁ * x ^ (θ + ε) + C₂ * x ^ (θ + ε) := add_le_add (hb₁ x hx1) (hb₂ x hx2)
    _ = (C₁ + C₂) * x ^ (θ + ε) := by ring

/-- The complex estimate is stable under multiplication by a constant. -/
theorem HasErrorExponentC.const_mul (c : ℂ) (h : HasErrorExponentC pi M θ) :
    HasErrorExponentC (fun x => c * pi x) (fun x => c * M x) θ := by
  intro ε hε
  obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
  refine ⟨(‖c‖ + 1) * C, by positivity, X, hX, fun x hx => ?_⟩
  have hx1 : (1 : ℝ) ≤ x := le_trans hX hx
  have hxpos : (0 : ℝ) ≤ x ^ (θ + ε) := Real.rpow_nonneg (by linarith) _
  calc ‖c * pi x - c * M x‖ = ‖c‖ * ‖pi x - M x‖ := by
        rw [← norm_mul]; ring_nf
    _ ≤ ‖c‖ * (C * x ^ (θ + ε)) := mul_le_mul_of_nonneg_left (hb x hx) (norm_nonneg c)
    _ ≤ (‖c‖ + 1) * C * x ^ (θ + ε) := by nlinarith [norm_nonneg c, hC.le]

/-- The zero function has every exponent. -/
theorem hasErrorExponentC_zero (θ : ℝ) :
    HasErrorExponentC (fun _ => (0 : ℂ)) (fun _ => (0 : ℂ)) θ := by
  intro ε hε
  refine ⟨1, one_pos, 1, le_rfl, fun x hx => ?_⟩
  have : (0 : ℝ) ≤ x ^ (θ + ε) := Real.rpow_nonneg (by linarith) _
  simpa using this

/-- Finite sums inherit a common exponent. -/
theorem HasErrorExponentC.sum {ι : Type*} (s : Finset ι) (f g : ι → ℝ → ℂ) (θ : ℝ)
    (h : ∀ i ∈ s, HasErrorExponentC (f i) (g i) θ) :
    HasErrorExponentC (fun x => ∑ i ∈ s, f i x) (fun x => ∑ i ∈ s, g i x) θ := by
  classical
  induction s using Finset.induction with
  | empty => simpa using hasErrorExponentC_zero θ
  | insert a s ha ih =>
      have hmem : ∀ i ∈ s, HasErrorExponentC (f i) (g i) θ := fun i hi =>
        h i (Finset.mem_insert_of_mem hi)
      have := (h a (Finset.mem_insert_self a s)).add (ih hmem)
      simpa [Finset.sum_insert ha] using this

/-- Finite linear combinations inherit a common exponent. -/
theorem HasErrorExponentC.linear_comb {ι : Type*} (s : Finset ι) (c : ι → ℂ)
    (f g : ι → ℝ → ℂ) (θ : ℝ) (h : ∀ i ∈ s, HasErrorExponentC (f i) (g i) θ) :
    HasErrorExponentC (fun x => ∑ i ∈ s, c i * f i x) (fun x => ∑ i ∈ s, c i * g i x) θ :=
  HasErrorExponentC.sum s (fun i x => c i * f i x) (fun i x => c i * g i x) θ
    fun i hi => (h i hi).const_mul (c i)

/-- The complex notion restricts to the real one along the inclusion `ℝ → ℂ`. -/
theorem hasErrorExponentC_ofReal_iff (f N : ℝ → ℝ) (θ : ℝ) :
    HasErrorExponentC (fun x => (f x : ℂ)) (fun x => (N x : ℂ)) θ ↔ HasErrorExponent f N θ := by
  have hnorm : ∀ x : ℝ, ‖((f x : ℂ) - (N x : ℂ))‖ = |f x - N x| := by
    intro x
    rw [show ((f x : ℂ) - (N x : ℂ)) = ((f x - N x : ℝ) : ℂ) by push_cast; ring,
      Complex.norm_real, Real.norm_eq_abs]
  constructor
  · intro h ε hε
    obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
    exact ⟨C, hC, X, hX, fun x hx => by rw [← hnorm x]; exact hb x hx⟩
  · intro h ε hε
    obtain ⟨C, hC, X, hX, hb⟩ := h ε hε
    exact ⟨C, hC, X, hX, fun x hx => by rw [hnorm x]; exact hb x hx⟩

/-! ## The transfer principle over `ℂ` -/

/-- **Transfer principle over `ℂ`.**  If the transformed family `x ↦ ∑ k A j k · f k x`
satisfies the estimate for every `j`, and `A` admits a left inverse `B`, then every member of
the original family satisfies it. -/
theorem exponentC_of_inverse_transform {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (A : Matrix ι κ ℂ) (B : Matrix κ ι ℂ) (hBA : B * A = 1) (f M : κ → ℝ → ℂ) (θ : ℝ)
    (h : ∀ j, HasErrorExponentC (fun x => ∑ k, A j k * f k x)
                                (fun x => ∑ k, A j k * M k x) θ) (i : κ) :
    HasErrorExponentC (f i) (M i) θ := by
  have hinv : ∀ k, (∑ j, B i j * A j k) = if i = k then 1 else 0 := by
    intro k
    have hik := congrFun (congrFun hBA i) k
    simpa [Matrix.mul_apply, Matrix.one_apply] using hik
  have key : ∀ (F : κ → ℝ → ℂ) (x : ℝ), ∑ j, B i j * (∑ k, A j k * F k x) = F i x := by
    intro F x
    have hswap : ∑ j, B i j * (∑ k, A j k * F k x)
        = ∑ k, (∑ j, B i j * A j k) * F k x := by
      calc ∑ j, B i j * (∑ k, A j k * F k x)
          = ∑ j, ∑ k, B i j * (A j k * F k x) :=
            Finset.sum_congr rfl fun j _ => by rw [Finset.mul_sum]
        _ = ∑ k, ∑ j, B i j * (A j k * F k x) := Finset.sum_comm
        _ = ∑ k, (∑ j, B i j * A j k) * F k x := by
            refine Finset.sum_congr rfl fun k _ => ?_
            rw [Finset.sum_mul]
            exact Finset.sum_congr rfl fun j _ => by ring
    rw [hswap]
    simp [hinv]
  have hlin := HasErrorExponentC.linear_comb Finset.univ (fun j => B i j)
      (fun j x => ∑ k, A j k * f k x) (fun j x => ∑ k, A j k * M k x) θ
      (fun j _ => h j)
  have e₁ : (fun x => ∑ j, B i j * (∑ k, A j k * f k x)) = f i := funext (key f)
  have e₂ : (fun x => ∑ j, B i j * (∑ k, A j k * M k x)) = M i := funext (key M)
  rw [e₁, e₂] at hlin
  exact hlin

/-! ## The character table of a finite abelian group is invertible -/

section Character

variable (α : Type*) [AddCommGroup α] [Fintype α] [DecidableEq α]

/-- The character table of a finite abelian group: rows indexed by characters, columns by
group elements. -/
def charMatrix : Matrix (AddChar α ℂ) α ℂ := fun psi a => psi a

/-- The explicit left inverse of the character table, given by the orthogonality relations. -/
noncomputable def charMatrixInv : Matrix α (AddChar α ℂ) ℂ :=
  fun a psi => (Fintype.card α : ℂ)⁻¹ * psi (-a)

/-- **Invertibility of the character table.**  `charMatrixInv * charMatrix = 1`; the proof is
the orthogonality relation `∑_ψ ψ(b - a) = |α| · [a = b]`. -/
theorem charMatrix_left_inverse : charMatrixInv α * charMatrix α = 1 := by
  have hcard : (Fintype.card α : ℂ) ≠ 0 := by
    have hpos : 0 < Fintype.card α := Fintype.card_pos
    exact_mod_cast Nat.cast_ne_zero.mpr hpos.ne'
  ext a b
  rw [Matrix.mul_apply, Matrix.one_apply]
  have hterm : ∀ psi : AddChar α ℂ,
      charMatrixInv α a psi * charMatrix α psi b
        = (Fintype.card α : ℂ)⁻¹ * psi (-a + b) := by
    intro psi
    rw [charMatrixInv, charMatrix, psi.map_add_eq_mul]
    ring
  rw [Finset.sum_congr rfl fun psi _ => hterm psi, ← Finset.mul_sum,
    AddChar.sum_apply_eq_ite (-a + b)]
  by_cases hab : a = b
  · subst hab
    simp [hcard]
  · have hne : -a + b ≠ 0 := by
      intro hzero
      exact hab (by linear_combination (norm := abel) -hzero)
    simp [hne, hab]

/-- **C5 for abelian covers, complex form.**  The character-twisted counting functions
`π_ψ = ∑_a ψ(a)·π_a` all satisfy the estimate with exponent `θ` if and only if every
individual `π_a` does. -/
theorem hasErrorExponentC_character_iff (piA MA : α → ℝ → ℂ) (θ : ℝ) :
    (∀ psi : AddChar α ℂ, HasErrorExponentC (fun x => ∑ a, psi a * piA a x)
        (fun x => ∑ a, psi a * MA a x) θ) ↔ ∀ a, HasErrorExponentC (piA a) (MA a) θ := by
  constructor
  · intro h a
    exact exponentC_of_inverse_transform (charMatrix α) (charMatrixInv α)
      (charMatrix_left_inverse α) piA MA θ (fun psi => h psi) a
  · intro h psi
    exact HasErrorExponentC.linear_comb Finset.univ (fun a => psi a) piA MA θ fun a _ => h a

/-- **C5 for abelian covers, real form.**  For an abelian Galois group `α` the conjugacy
classes are the group elements, so this says: the non-split Chebotarev estimate with exponent
`θ` for all classes is *equivalent* to the family of split (character-twisted) estimates with
the same exponent `θ`.  In particular the reduction to the split case loses nothing. -/
theorem chebotarev_abelian_character_reduction (piA MA : α → ℝ → ℝ) (θ : ℝ) :
    (∀ psi : AddChar α ℂ, HasErrorExponentC (fun x => ∑ a, psi a * (piA a x : ℂ))
        (fun x => ∑ a, psi a * (MA a x : ℂ)) θ) ↔ ∀ a, HasErrorExponent (piA a) (MA a) θ := by
  rw [hasErrorExponentC_character_iff α (fun a x => (piA a x : ℂ)) (fun a x => (MA a x : ℂ)) θ]
  exact forall_congr' fun a => hasErrorExponentC_ofReal_iff (piA a) (MA a) θ

end Character

end ChebotarevGeodesic