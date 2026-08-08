import Mathlib

/-!
# Tropical cells and the freezing of a neural tangent kernel

`MachineLearning/NTKConvergence/Convergence.lean` uses a *tropical cell criterion* as its
geometric source of frozen kernels, but the module it imported for that criterion was
missing from this repository, so the whole `NTKConvergence` chapter failed to build.  This
file supplies it.

The idea is the one behind lazy training of piecewise-linear networks.  A max-plus
("tropical") function

  `T(x) = maxᵢ (⟨aᵢ, x⟩ + bᵢ)`

is affine on each *cell*, the region on which the set of maximizing indices is constant.
Its gradient — and hence any kernel built from the gradient — is therefore literally
constant along a trajectory that stays inside one cell.  `IsCellwiseConstant` abstracts
"constant on cells", `SameTropicalCell` abstracts "in the same cell", and
`tropical_lazy_training_of_cell_invariance` is the resulting freezing statement used
downstream.

## Main results

* `tropical_lazy_training_of_cell_invariance` — a cellwise-constant kernel is constant
  along a cell-confined trajectory.
* `tropicalValue_eq_of_mem_activeSet` — inside a cell the max-plus function *is* one of its
  affine pieces.
* `tropicalValue_sub_of_sameCell` — two points of the same cell differ by the linear form of
  that piece: the function is affine on the cell.
* `activeSetGrad_cellwiseConstant` — consequently the gradient, and any kernel assembled
  from it, is cellwise constant, which is exactly the hypothesis the NTK chapter needs.
-/

namespace TropicalKernelDynamics

/-! ### The abstract cell framework -/

/-- Two points lie in the same cell of the labelling `cellOf`. -/
def SameTropicalCell {α C : Type*} (cellOf : α → C) (x y : α) : Prop := cellOf x = cellOf y

theorem sameTropicalCell_refl {α C : Type*} (cellOf : α → C) (x : α) :
    SameTropicalCell cellOf x x := rfl

theorem SameTropicalCell.symm {α C : Type*} {cellOf : α → C} {x y : α}
    (h : SameTropicalCell cellOf x y) : SameTropicalCell cellOf y x := Eq.symm h

theorem SameTropicalCell.trans {α C : Type*} {cellOf : α → C} {x y z : α}
    (h₁ : SameTropicalCell cellOf x y) (h₂ : SameTropicalCell cellOf y z) :
    SameTropicalCell cellOf x z := Eq.trans h₁ h₂

/-- A quantity that depends only on the cell a point lies in. -/
def IsCellwiseConstant {α C β : Type*} (cellOf : α → C) (K : α → β) : Prop :=
  ∀ x y, SameTropicalCell cellOf x y → K x = K y

/-- **Lazy training from cell confinement.**  If the kernel `K` is constant on cells and the
trajectory stays in the cell of its starting point up to time `T`, then the kernel is
literally frozen on `[0, T)`.  (The hypothesis `0 < T` is not needed for the conclusion; it
is kept because it records the intended regime and is supplied by the caller.) -/
theorem tropical_lazy_training_of_cell_invariance {α C β : Type*}
    (cellOf : α → C) (traj : ℝ → α) (K : α → β) (T : ℝ) (_hT : 0 < T)
    (hcell : ∀ t, 0 ≤ t → t < T → SameTropicalCell cellOf (traj t) (traj 0))
    (hK : IsCellwiseConstant cellOf K) :
    ∀ t, 0 ≤ t → t < T → K (traj t) = K (traj 0) :=
  fun t ht htT => hK _ _ (hcell t ht htT)

/-! ### The tropical (max-plus) model that produces such cells -/

variable {M P : ℕ}

/-- A max-plus function `T(x) = maxᵢ (⟨aᵢ, x⟩ + bᵢ)` with `M + 1` affine pieces. -/
noncomputable def tropicalValue (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty fun i => (∑ j, a i j * x j) + b i

open Classical in
/-- The cell label of `x`: the set of pieces attaining the maximum. -/
noncomputable def activeSet (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : Finset (Fin (M + 1)) :=
  Finset.univ.filter fun i => (∑ j, a i j * x j) + b i = tropicalValue a b x

theorem activeSet_nonempty (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : (activeSet a b x).Nonempty := by
  classical
  obtain ⟨i, -, hi⟩ :=
    Finset.exists_mem_eq_sup' (Finset.univ_nonempty (α := Fin (M + 1)))
      fun i => (∑ j, a i j * x j) + b i
  exact ⟨i, by simp [activeSet, tropicalValue, hi]⟩

/-- Inside its cell the max-plus function *is* one of its affine pieces. -/
theorem tropicalValue_eq_of_mem_activeSet {a : Fin (M + 1) → (Fin P → ℝ)}
    {b : Fin (M + 1) → ℝ} {x : Fin P → ℝ} {i : Fin (M + 1)} (hi : i ∈ activeSet a b x) :
    tropicalValue a b x = (∑ j, a i j * x j) + b i := by
  classical
  simpa [activeSet, eq_comm] using (Finset.mem_filter.mp hi).2

/-- The distinguished piece of a cell (the least active index). -/
noncomputable def activePiece (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : Fin (M + 1) :=
  (activeSet a b x).min' (activeSet_nonempty a b x)

theorem activePiece_mem (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : activePiece a b x ∈ activeSet a b x :=
  Finset.min'_mem _ _

/-- **The max-plus function is affine on a cell.**  Two points of the same cell differ by the
linear form of the cell's piece. -/
theorem tropicalValue_sub_of_sameCell {a : Fin (M + 1) → (Fin P → ℝ)} {b : Fin (M + 1) → ℝ}
    {x y : Fin P → ℝ} (h : SameTropicalCell (activeSet a b) x y) :
    tropicalValue a b x - tropicalValue a b y
      = ∑ j, a (activePiece a b x) j * (x j - y j) := by
  have hx : tropicalValue a b x = (∑ j, a (activePiece a b x) j * x j) + b (activePiece a b x) :=
    tropicalValue_eq_of_mem_activeSet (activePiece_mem a b x)
  have hmem : activePiece a b x ∈ activeSet a b y := by
    have := activePiece_mem a b x
    rwa [show activeSet a b x = activeSet a b y from h] at this
  have hy : tropicalValue a b y = (∑ j, a (activePiece a b x) j * y j) + b (activePiece a b x) :=
    tropicalValue_eq_of_mem_activeSet hmem
  have hsum : ∑ j, a (activePiece a b x) j * (x j - y j)
      = (∑ j, a (activePiece a b x) j * x j) - ∑ j, a (activePiece a b x) j * y j := by
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun j _ => by ring
  rw [hx, hy, hsum]
  ring

/-- The gradient of the max-plus function on a cell, i.e. the coefficient vector of the
cell's affine piece. -/
noncomputable def activeSetGrad (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    (x : Fin P → ℝ) : Fin P → ℝ := a (activePiece a b x)

theorem min'_eq_min'_of_eq {α : Type*} [LinearOrder α] {s t : Finset α} (h : s = t)
    (hs : s.Nonempty) (ht : t.Nonempty) : s.min' hs = t.min' ht := by
  subst h; rfl

/-- **The gradient is cellwise constant.**  This is the concrete instance of
`IsCellwiseConstant` that feeds `tropical_lazy_training_of_cell_invariance`: a trajectory
confined to one tropical cell sees a frozen gradient, hence a frozen kernel. -/
theorem activeSetGrad_cellwiseConstant (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ) :
    IsCellwiseConstant (activeSet a b) (activeSetGrad a b) := by
  intro x y h
  simp only [activeSetGrad, activePiece]
  rw [min'_eq_min'_of_eq h (activeSet_nonempty a b x) (activeSet_nonempty a b y)]

/-- Any kernel built functorially from the gradient is cellwise constant too; in particular
the Gram matrix of the gradient, which is the neural tangent kernel of a one-unit
piecewise-linear model. -/
theorem gradKernel_cellwiseConstant (a : Fin (M + 1) → (Fin P → ℝ)) (b : Fin (M + 1) → ℝ)
    {β : Type*} (F : (Fin P → ℝ) → β) :
    IsCellwiseConstant (activeSet a b) (fun x => F (activeSetGrad a b x)) := by
  intro x y h
  show F (activeSetGrad a b x) = F (activeSetGrad a b y)
  rw [activeSetGrad_cellwiseConstant a b x y h]

end TropicalKernelDynamics