import Mathlib
import Novelty.NeuralCoding

/-!
# Stone Duality for Neural Networks: Activation Patterns as a Boolean Algebra

A neural network with `k` threshold neurons assigns to every input `x` an
**activation pattern** — the tuple of on/off states of its neurons.  This file
develops the *Stone-dual* picture of such a network:

* The **pattern space** `P = Fin k → Bool` is the finite space of all activation
  patterns.  Given the discrete topology it is a **Stone space** (compact,
  Hausdorff, totally disconnected) and its Boolean algebra of clopen sets is the
  full powerset `Set P`.
* A network is an **activation map** `act : X → P` from the input space.  Its
  **Stone dual** is the *region map* `region act : Set P → Set X`,
  `S ↦ act ⁻¹' S`, sending a set of patterns to the region of inputs realizing
  one of them.
* The region map is a **homomorphism of Boolean algebras**: it commutes with
  `⊥, ⊤, ∪, ∩, ᶜ, \\` and is monotone.  It is **injective exactly when every
  pattern is realized** (`act` surjective) — the algebraic shadow of Stone
  duality's reconstruction theorem.
* The **atoms** of `Set P` are the singletons `{p}`, whose images are the
  **activation cells** `act ⁻¹' {p}`.  These cells are pairwise disjoint, cover
  the input space, and a cell is nonempty exactly when its pattern is realized.
* For a **linear-threshold (perceptron) network** each cell is an intersection of
  affine half-spaces, hence **convex**, tying the algebra and topology back to the
  geometry of the input space.

The pattern space reuses `NeuralCoding.NeuralCode` from the catalog, so the
capacity count `Fintype.card (NeuralCode k) = 2 ^ k` feeds directly into the
count of distinct network regions, `2 ^ (2 ^ k)`.

-- !-- Lab Notes -- !--

* **Hypothesis.**  Every neural network `f : ℝ^n → ℝ^m` (more precisely, every
  network whose neurons induce an activation map `act : X → P`) has a "Stone
  dual": a Boolean algebra together with a duality map into the algebra of input
  regions, mirroring the correspondence between a Boolean algebra and the clopen
  algebra of its Stone space of ultrafilters.

* **Experiment.**  We modelled the dual concretely as the preimage map
  `region act = act ⁻¹' (·)` on the powerset of the finite pattern space.  On a
  finite discrete space every ultrafilter is principal, so the Stone space *is*
  the pattern space and its clopen algebra *is* `Set P`.  We proved the
  homomorphism laws, the injective ⇔ surjective duality, the atom/cell
  correspondence, the region count `2 ^ (2 ^ k)`, and — for perceptron networks
  — convexity of cells.

* **Analysis.**  The duality is exact (an isomorphism onto its image) precisely
  when the network realizes all `2 ^ k` patterns; otherwise the dual detects the
  *missing* patterns as the kernel of the homomorphism.  Convexity of cells is a
  purely geometric fact that the Boolean/topological layer is blind to, showing
  the perceptron layer carries strictly more structure than its Stone dual.

* **Critique.**  The finite-dimensional discreteness is essential: on an infinite
  Boolean algebra the Stone space carries non-principal ultrafilters, so the
  naive powerset model would fail.  We therefore state the topological results for
  a genuine (finite, discrete) Stone space rather than asserting them in general.

* **Synthesis.**  A neural network's decision structure is completely captured by
  a Boolean-algebra homomorphism from the clopen algebra of its (finite Stone)
  pattern space; the geometry of the input space enters only through the shape
  (here: convexity) of the atoms' images.
-/

open Function Set
open NeuralCoding

namespace StoneDualNN

/-! ## The pattern space as a Stone space -/

/-- The **pattern space** of a `k`-neuron network: the space of all activation
patterns.  It reuses `NeuralCoding.NeuralCode k = Fin k → Bool`. -/
def PatternSpace (k : ℕ) : Type := NeuralCode k

instance (k : ℕ) : Fintype (PatternSpace k) := inferInstanceAs (Fintype (NeuralCode k))
instance (k : ℕ) : DecidableEq (PatternSpace k) := inferInstanceAs (DecidableEq (NeuralCode k))
instance (k : ℕ) : TopologicalSpace (PatternSpace k) := ⊥
instance (k : ℕ) : DiscreteTopology (PatternSpace k) := ⟨rfl⟩

/-- There are exactly `2 ^ k` activation patterns (reusing the catalog capacity
count `card_neuralCode`). -/
theorem card_patternSpace (k : ℕ) : Fintype.card (PatternSpace k) = 2 ^ k :=
  card_neuralCode k

/-- The pattern space is compact: the topological half of "Stone space". -/
theorem patternSpace_compact (k : ℕ) : CompactSpace (PatternSpace k) := by
  infer_instance

/-- The pattern space is Hausdorff. -/
theorem patternSpace_t2 (k : ℕ) : T2Space (PatternSpace k) := by
  infer_instance

/-- The pattern space is totally disconnected: together with compactness and
Hausdorffness this makes it a **Stone space**. -/
theorem patternSpace_totallyDisconnected (k : ℕ) :
    TotallyDisconnectedSpace (PatternSpace k) := by
  infer_instance

/-- Every set of patterns is **clopen**: the Boolean algebra of clopen subsets of
the Stone pattern space is the full powerset `Set (PatternSpace k)`. -/
theorem isClopen_patternSet (k : ℕ) (S : Set (PatternSpace k)) : IsClopen S :=
  isClopen_discrete S

/-! ## The Stone dual: the region homomorphism -/

variable {X : Type*} {k : ℕ}

/-- The **region map** (Stone dual) of an activation map `act`: it sends a set of
patterns `S` to the region of inputs whose pattern lies in `S`. -/
def region (act : X → PatternSpace k) (S : Set (PatternSpace k)) : Set X := act ⁻¹' S

@[simp] theorem region_apply (act : X → PatternSpace k) (S : Set (PatternSpace k)) :
    region act S = {x | act x ∈ S} := rfl

@[simp] theorem region_empty (act : X → PatternSpace k) : region act ∅ = ∅ :=
  Set.preimage_empty

@[simp] theorem region_univ (act : X → PatternSpace k) : region act Set.univ = Set.univ :=
  Set.preimage_univ

theorem region_union (act : X → PatternSpace k) (S T : Set (PatternSpace k)) :
    region act (S ∪ T) = region act S ∪ region act T :=
  Set.preimage_union

theorem region_inter (act : X → PatternSpace k) (S T : Set (PatternSpace k)) :
    region act (S ∩ T) = region act S ∩ region act T :=
  Set.preimage_inter

theorem region_compl (act : X → PatternSpace k) (S : Set (PatternSpace k)) :
    region act Sᶜ = (region act S)ᶜ :=
  Set.preimage_compl

theorem region_diff (act : X → PatternSpace k) (S T : Set (PatternSpace k)) :
    region act (S \ T) = region act S \ region act T :=
  Set.preimage_diff act S T

theorem region_mono (act : X → PatternSpace k) : Monotone (region act) :=
  fun _ _ h => Set.preimage_mono h

/-- **Duality / reconstruction.**  The Stone dual is injective — i.e. it faithfully
distinguishes all sets of patterns — exactly when the network realizes every
pattern.  This is the finite avatar of Stone duality's reconstruction theorem. -/
theorem region_injective_iff_surjective (act : X → PatternSpace k) :
    Function.Injective (region act) ↔ Function.Surjective act :=
  Set.preimage_injective

/-! ## Atoms and activation cells -/

/-- The **activation cell** of a pattern `p`: the inputs whose pattern is exactly
`p`.  It is the Stone-dual image of the atom `{p}`. -/
def cell (act : X → PatternSpace k) (p : PatternSpace k) : Set X := act ⁻¹' {p}

theorem region_singleton (act : X → PatternSpace k) (p : PatternSpace k) :
    region act {p} = cell act p := rfl

theorem mem_cell (act : X → PatternSpace k) (p : PatternSpace k) (x : X) :
    x ∈ cell act p ↔ act x = p := Iff.rfl

/-- Distinct patterns have **disjoint** cells. -/
theorem cells_disjoint (act : X → PatternSpace k) {p q : PatternSpace k} (h : p ≠ q) :
    Disjoint (cell act p) (cell act q) := by
  rw [Set.disjoint_left]
  intro x hp hq
  rw [mem_cell] at hp hq
  exact h (hp ▸ hq)

/-- The cells **cover** the whole input space. -/
theorem cells_cover (act : X → PatternSpace k) : (⋃ p, cell act p) = Set.univ := by
  ext x
  simp only [Set.mem_iUnion, Set.mem_univ, iff_true]
  exact ⟨act x, by rw [mem_cell]⟩

/-- A cell is **nonempty** exactly when its pattern is realized by some input. -/
theorem cell_nonempty_iff (act : X → PatternSpace k) (p : PatternSpace k) :
    (cell act p).Nonempty ↔ p ∈ Set.range act := by
  constructor
  · rintro ⟨x, hx⟩
    rw [mem_cell] at hx
    exact ⟨x, hx⟩
  · rintro ⟨x, hx⟩
    exact ⟨x, by rw [mem_cell]; exact hx⟩

/-! ## Counting regions -/

/-- **Region capacity.**  A network that realizes all patterns has exactly
`2 ^ (2 ^ k)` distinct regions — the size of the powerset Boolean algebra of the
pattern space.  This chains the catalog capacity `2 ^ k` through the Stone dual. -/
theorem card_regions (act : X → PatternSpace k) (hsurj : Function.Surjective act) :
    Nat.card (Set.range (region act)) = 2 ^ (2 ^ k) := by
  have hinj : Function.Injective (region act) :=
    (region_injective_iff_surjective act).2 hsurj
  rw [Nat.card_range_of_injective hinj]
  rw [Nat.card_eq_fintype_card, Fintype.card_set, card_patternSpace]

/-! ## Perceptron networks: geometry of the cells -/

/-- The **linear-threshold (perceptron) activation map**: neuron `j` fires on
input `x` when its affine pre-activation `∑ i, w j i * x i + b j` is positive. -/
noncomputable def affineAct (n : ℕ) (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ) :
    (Fin n → ℝ) → PatternSpace k :=
  fun x j => decide (0 < (∑ i, w j i * x i) + b j)

/-- The linear pre-activation of neuron `j` is a linear map of the input. -/
theorem isLinearMap_preact (n : ℕ) (v : Fin n → ℝ) :
    IsLinearMap ℝ (fun x : Fin n → ℝ => ∑ i, v i * x i) := by
  constructor
  · intro x y
    simp only [Pi.add_apply, mul_add]
    rw [Finset.sum_add_distrib]
  · intro c x
    simp only [Pi.smul_apply, smul_eq_mul]
    rw [Finset.mul_sum]
    congr 1; ext i; ring

/-- Membership in a neuron's "on" set is exactly membership in an open affine
half-space, connecting the Boolean layer to input-space geometry. -/
theorem on_set_eq_halfspace (n : ℕ) (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (j : Fin k) :
    {x : Fin n → ℝ | affineAct n w b x j = true}
      = {x : Fin n → ℝ | (-(b j)) < ∑ i, w j i * x i} := by
  ext x
  simp only [affineAct, Set.mem_setOf_eq, decide_eq_true_eq]
  constructor <;> intro h <;> linarith

/-- **Convexity of activation cells.**  Every cell of a perceptron network is an
intersection of affine half-spaces, hence convex. -/
theorem cell_convex (n : ℕ) (w : Fin k → Fin n → ℝ) (b : Fin k → ℝ)
    (p : PatternSpace k) :
    Convex ℝ (cell (affineAct n w b) p) := by
  have hcell : cell (affineAct n w b) p
      = ⋂ j, {x : Fin n → ℝ | affineAct n w b x j = p j} := by
    ext x
    simp only [cell, mem_preimage, mem_singleton_iff, mem_iInter, mem_setOf_eq]
    constructor
    · intro h j; rw [h]
    · intro h; funext j; exact h j
  rw [hcell]
  apply convex_iInter
  intro j
  have hlin := isLinearMap_preact n (w j)
  cases hpj : p j
  · have heq : {x : Fin n → ℝ | affineAct n w b x j = false}
        = {x | (∑ i, w j i * x i) ≤ -(b j)} := by
      ext x
      simp only [affineAct, mem_setOf_eq, decide_eq_false_iff_not, not_lt]
      constructor <;> intro h <;> linarith
    rw [heq]; exact convex_halfSpace_le hlin (-(b j))
  · have heq : {x : Fin n → ℝ | affineAct n w b x j = true}
        = {x | -(b j) < ∑ i, w j i * x i} := by
      ext x
      simp only [affineAct, mem_setOf_eq, decide_eq_true_eq]
      constructor <;> intro h <;> linarith
    rw [heq]; exact convex_halfSpace_gt hlin (-(b j))

end StoneDualNN