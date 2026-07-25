/-
A family of `n+1` fixed-point-free involutions on a type `α` induces a simple graph
that is regular of degree `n+1`.

Note on imports: the task requested `Mathlib.Combinatorics.SimpleGraph.Degree`, but in this
Mathlib version (v4.28.0) the relevant declarations (`neighborFinset`, `degree`,
`IsRegularOfDegree`) live in `Mathlib.Combinatorics.SimpleGraph.Finite`, which is imported
here instead. `Mathlib.Algebra.Order.Group.Abs` is imported to provide the `|·|` notation
used in the `σ_commute` field.
-/
import Mathlib.Data.Fintype.Card
import Mathlib.Combinatorics.SimpleGraph.Finite
import Mathlib.Data.Finset.Basic
import Mathlib.Algebra.Order.Group.Abs

variable {α : Type*} {n : ℕ}

/-- A family of `n+1` fixed-point-free involutions on `α`, where non-adjacent involutions
commute and distinct involutions send a vertex to distinct images. -/
structure InvolutionFamily (α : Type*) (n : ℕ) where
  σ : Fin (n + 1) → α → α
  σ_involutive : ∀ i, Function.Involutive (σ i)
  σ_fixed_point_free : ∀ i x, σ i x ≠ x
  σ_commute : ∀ i j : Fin (n + 1), |(i : ℤ) - (j : ℤ)| ≥ 2 → ∀ x, σ i (σ j x) = σ j (σ i x)
  neighbors_distinct : ∀ i j v, i ≠ j → σ i v ≠ σ j v

namespace InvolutionFamily

/-- Each involution in the family is injective (a consequence of being involutive). -/
lemma σ_injective (F : InvolutionFamily α n) (i : Fin (n + 1)) :
    Function.Injective (F.σ i) := (F.σ_involutive i).injective

/-- The graph on `α` where `v` and `w` are adjacent iff some involution in the family maps one
to the other. -/
def involutionFamilyGraph (F : InvolutionFamily α n) : SimpleGraph α where
  Adj v w := ∃ i : Fin (n + 1), w = F.σ i v ∨ v = F.σ i w
  symm := by rintro v w ⟨i, h⟩; exact ⟨i, h.symm⟩
  loopless := ⟨fun v ⟨i, h⟩ => F.σ_fixed_point_free i v (h.elim (·.symm) (·.symm))⟩

noncomputable instance (F : InvolutionFamily α n) : DecidableRel F.involutionFamilyGraph.Adj :=
  fun _ _ => Classical.dec _

/-- The graph induced by an involution family is regular of degree `n+1`. -/
theorem involutionFamilyGraph_regular (F : InvolutionFamily α n) [Fintype α] [DecidableEq α] :
    F.involutionFamilyGraph.IsRegularOfDegree (n + 1) := by
  intro v
  have hinj : Function.Injective (fun i => F.σ i v) := by
    intro i j h
    by_contra hne
    exact F.neighbors_distinct i j v hne h
  have hset : F.involutionFamilyGraph.neighborFinset v
      = Finset.image (fun i => F.σ i v) Finset.univ := by
    ext w
    rw [SimpleGraph.mem_neighborFinset, Finset.mem_image]
    constructor
    · rintro ⟨i, hi | hi⟩
      · exact ⟨i, Finset.mem_univ i, hi.symm⟩
      · exact ⟨i, Finset.mem_univ i, by rw [hi, F.σ_involutive i]⟩
    · rintro ⟨i, _, hi⟩
      exact ⟨i, Or.inl hi.symm⟩
  rw [SimpleGraph.degree, hset, Finset.card_image_of_injective _ hinj,
    Finset.card_univ, Fintype.card_fin]

end InvolutionFamily