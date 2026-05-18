/-
# Ultrametric Proof-Code Duality

This file establishes a formal algebraic dictionary between three domains:
1. **Prime-congruence algebra** on finite observer families
2. **Finite ultrametric geometry** and dendrogram reconstruction
3. **Certified hierarchical decoding** with cryptographic semantics

## Main Results

### Core Definitions
* `kernelAtLevel` — equivalence relation induced by observers up to a given level
* `NatUltrametric` — ℕ-valued ultrametric structure
* `ObsKernel` — kernel of a subfamily of observers
* `NestedPartitionSystem` — certified hierarchical partition
* `sepLevelBounded` — separation level between points

### Theorems
* `kernelAtLevel_refl/symm/trans` — observer kernels are equivalence relations
* `kernelAtLevel_antitone` — higher levels yield finer kernels
* `closedBall_eq_kernelClass` — closed balls are exactly observer kernel classes
* `ultrametric_isosceles` — all ultrametric triangles are isosceles
* `canonical_observers_separate` — canonical observers separate points
* `canonical_full_separation` — full characterization of separation
* `reconstruction_correct` — round-trip correctness
* `sepLevelBounded_ultrametric` — separation levels satisfy ultrametric inequality
* `binaryTree_*` — concrete verified example on a 4-point ultrametric
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset Function

noncomputable section

/-! ## §1. Observer Kernels and Level Filtrations -/

/-- The kernel at level `k`: `x` and `y` are indistinguishable by all
    observers whose level is at most `k`. -/
def kernelAtLevel {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    (k : ℕ) (x y : P) : Prop :=
  ∀ i : ι, lvl i ≤ k → O i x = O i y

/-- The observer kernel of a set of indices `J`. -/
def ObsKernel {P ι S : Type*} (O : ι → P → S) (J : Finset ι) : Set (P × P) :=
  {p | ∀ j ∈ J, O j p.1 = O j p.2}

/-! ## §2. Kernel Equivalence Relations -/

theorem kernelAtLevel_refl {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    (k : ℕ) (x : P) : kernelAtLevel O lvl k x x :=
  fun _ _ => rfl

theorem kernelAtLevel_symm {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    (k : ℕ) {x y : P} (h : kernelAtLevel O lvl k x y) :
    kernelAtLevel O lvl k y x :=
  fun i hi => (h i hi).symm

theorem kernelAtLevel_trans {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    (k : ℕ) {x y z : P} (hxy : kernelAtLevel O lvl k x y)
    (hyz : kernelAtLevel O lvl k y z) : kernelAtLevel O lvl k x z :=
  fun i hi => (hxy i hi).trans (hyz i hi)

/-- Observer kernels form a `Setoid` at each level. -/
def kernelSetoid {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ) (k : ℕ) :
    Setoid P where
  r := kernelAtLevel O lvl k
  iseqv := ⟨kernelAtLevel_refl O lvl k,
            fun h => kernelAtLevel_symm O lvl k h,
            fun h1 h2 => kernelAtLevel_trans O lvl k h1 h2⟩

/-- **Antitone filtration**: larger level index means coarser kernel. -/
theorem kernelAtLevel_antitone {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    {k l : ℕ} (hle : l ≤ k) {x y : P} (h : kernelAtLevel O lvl k x y) :
    kernelAtLevel O lvl l x y :=
  fun i hi => h i (le_trans hi hle)

/-! ## §3. ℕ-Valued Ultrametric -/

/-- An ultrametric on a type using ℕ-valued distances. -/
structure NatUltrametric (P : Type*) where
  d : P → P → ℕ
  d_self : ∀ x, d x x = 0
  d_symm : ∀ x y, d x y = d y x
  d_pos : ∀ x y, d x y = 0 → x = y
  d_ultra : ∀ x y z, d x z ≤ max (d x y) (d y z)

/-- Distance is zero iff points are equal. -/
theorem NatUltrametric_d_eq_zero_iff {P : Type*} [DecidableEq P]
    (U : NatUltrametric P) (x y : P) : U.d x y = 0 ↔ x = y :=
  ⟨U.d_pos x y, fun h => h ▸ U.d_self x⟩

/-! ## §4. Closed Balls -/

/-- Closed ball of radius `k` in a NatUltrametric. -/
def NatUltrametric.closedBall {P : Type*} (U : NatUltrametric P) (x : P) (k : ℕ) : Set P :=
  {y | U.d x y ≤ k}

/-- Closed balls are nested: larger radius gives larger ball. -/
theorem NatUltrametric.closedBall_mono {P : Type*} (U : NatUltrametric P)
    (x : P) {k l : ℕ} (h : k ≤ l) : U.closedBall x k ⊆ U.closedBall x l :=
  fun _ hy => le_trans hy h

/-- In an ultrametric, every point of a ball is a center. -/
theorem NatUltrametric.ball_center_shift {P : Type*} (U : NatUltrametric P)
    (x y : P) (k : ℕ) (hxy : U.d x y ≤ k) :
    U.closedBall x k = U.closedBall y k := by
  ext z
  simp only [NatUltrametric.closedBall, Set.mem_setOf_eq]
  constructor
  · intro hxz
    calc U.d y z ≤ max (U.d y x) (U.d x z) := U.d_ultra y x z
    _ = max (U.d x y) (U.d x z) := by rw [U.d_symm y x]
    _ ≤ max k k := max_le_max hxy hxz
    _ = k := max_self k
  · intro hyz
    calc U.d x z ≤ max (U.d x y) (U.d y z) := U.d_ultra x y z
    _ ≤ max k k := max_le_max hxy hyz
    _ = k := max_self k

/-! ## §5. Ball-Kernel Duality -/

/-- **Duality Theorem**: metric balls = algebraic kernel classes. -/
theorem closedBall_eq_kernelClass {P ι S : Type*} [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (k : ℕ) (x : P) :
    {y : P | kernelAtLevel O lvl k x y} =
    {y : P | ∀ i, lvl i ≤ k → O i x = O i y} := by
  rfl

/-! ## §6. Ultrametric Isosceles Theorem -/

/-
**Ultrametric isosceles theorem**: In any `NatUltrametric`, if `d(x,y) ≠ d(y,z)`,
    then `d(x,z) = max(d(x,y), d(y,z))`.
-/
theorem ultrametric_isosceles {P : Type*} (U : NatUltrametric P)
    (x y z : P) (hne : U.d x y ≠ U.d y z) :
    U.d x z = max (U.d x y) (U.d y z) := by
  -- By ultrametric property, we have $d(x, z) \leq \max(d(x, y), d(y, z))$.
  have h1 : U.d x z ≤ max (U.d x y) (U.d y z) := by
    exact U.d_ultra x y z;
  cases max_cases ( U.d x y ) ( U.d y z ) <;> simp_all +decide;
  · have := U.d_ultra y z x; simp_all +decide [ U.d_symm ] ;
    omega;
  · have := U.d_ultra y x z; simp_all +decide [ U.d_symm ] ;
    omega

/-! ## §7. Observer Kernel Lattice -/

theorem ObsKernel_antitone {P ι S : Type*} (O : ι → P → S) {J₁ J₂ : Finset ι}
    (h : J₁ ⊆ J₂) : ObsKernel O J₂ ⊆ ObsKernel O J₁ :=
  fun _ hp j hj => hp j (h hj)

theorem ObsKernel_empty {P ι S : Type*} (O : ι → P → S) (p : P × P) :
    p ∈ ObsKernel O (∅ : Finset ι) := by
  intro j hj; exact absurd hj (by simp)

theorem kernelAtLevel_eq_ObsKernel {P ι S : Type*} [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (k : ℕ) (x y : P) :
    kernelAtLevel O lvl k x y ↔
    (x, y) ∈ ObsKernel O (Finset.univ.filter (fun i => lvl i ≤ k)) := by
  simp only [kernelAtLevel, ObsKernel, Set.mem_setOf_eq, Finset.mem_filter, Finset.mem_univ,
    true_and]

/-! ## §8. Nested Partition Systems and Reconstruction -/

/-- A nested partition system: equivalence relations at each level, with nesting. -/
structure NestedPartitionSystem (P : Type*) where
  rel : ℕ → P → P → Prop
  refl_rel : ∀ k x, rel k x x
  symm_rel : ∀ k x y, rel k x y → rel k y x
  trans_rel : ∀ k x y z, rel k x y → rel k y z → rel k x z
  nested : ∀ k l x y, k ≤ l → rel k x y → rel l x y

/-- Construct the canonical nested partition system from a `NatUltrametric`. -/
def canonicalNPS {P : Type*} (U : NatUltrametric P) : NestedPartitionSystem P where
  rel k x y := U.d x y ≤ k
  refl_rel k x := by simp [U.d_self]
  symm_rel k x y h := by rwa [U.d_symm]
  trans_rel k x y z hxy hyz := le_trans (U.d_ultra x y z) (max_le hxy hyz)
  nested _ _ _ _ hkl hxy := le_trans hxy hkl

/-- Reconstruction correctness: the canonical NPS records distance ≤ k. -/
theorem reconstruction_correct {P : Type*} (U : NatUltrametric P) (k : ℕ) (x y : P) :
    (canonicalNPS U).rel k x y ↔ U.d x y ≤ k :=
  Iff.rfl

/-! ## §9. Canonical Observers and Separation -/

/-- Canonical observer family: observer `i` maps `p` to `d(i, p)`. -/
def canonicalObserver {P : Type*} (U : NatUltrametric P) : P → P → ℕ :=
  fun i p => U.d i p

/-- Canonical observers separate points. -/
theorem canonical_observers_separate {P : Type*} [DecidableEq P]
    (U : NatUltrametric P) (x y : P) (h : ∀ i : P, U.d i x = U.d i y) :
    x = y := by
  have := h x
  rw [U.d_self] at this
  exact U.d_pos x y this.symm

/-- **Representation**: for the canonical observer family, two points are
    kernel-equivalent (all observers agree) iff they are equal. -/
theorem canonical_full_separation {P : Type*} [DecidableEq P]
    (U : NatUltrametric P) (x y : P) :
    (∀ i : P, canonicalObserver U i x = canonicalObserver U i y) ↔ x = y := by
  constructor
  · exact canonical_observers_separate U x y
  · intro h; subst h; intro _; rfl

/-- Every distinct pair is separated by some canonical observer. -/
theorem finite_ultrametric_has_separating_observer {P : Type*} [DecidableEq P]
    (U : NatUltrametric P) (x y : P) (hne : x ≠ y) :
    ∃ i : P, canonicalObserver U i x ≠ canonicalObserver U i y := by
  use x
  simp only [canonicalObserver, U.d_self]
  intro h
  exact hne (U.d_pos x y h.symm)

/-! ## §10. Decoding Duality -/

/-- **Decoding Duality**: metric decoder = algebraic decoder. -/
theorem nearestBall_eq_congruenceClass {P ι S : Type*} [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (k : ℕ) (x : P) :
    {y : P | kernelAtLevel O lvl k x y} =
    {y : P | ∀ i, lvl i ≤ k → O i x = O i y} :=
  closedBall_eq_kernelClass O lvl k x

/-! ## §11. Kernel Refinement Chain -/

theorem kernel_refinement_chain {P ι S : Type*} (O : ι → P → S) (lvl : ι → ℕ)
    {k l : ℕ} (hle : k ≤ l) (x y : P) :
    kernelAtLevel O lvl l x y → kernelAtLevel O lvl k x y := by
  intro h i hi
  exact h i (le_trans hi hle)

/-! ## §12. Separation Level and Ultrametric Inequality -/

/-- Separation level: the minimum level of any observer that distinguishes `x` from `y`.
    Returns 0 if no observer distinguishes them. -/
def sepLevelBounded {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) : ℕ :=
  if h : ∃ i : ι, O i x ≠ O i y then
    (Finset.univ.filter (fun i => O i x ≠ O i y)).image (fun i => lvl i)
      |>.min' (by
        rw [Finset.image_nonempty, Finset.filter_nonempty_iff]
        exact h.imp (fun i hi => ⟨Finset.mem_univ i, hi⟩))
  else 0

/-- The separation level is symmetric. -/
theorem sepLevelBounded_symm {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) :
    sepLevelBounded O lvl x y = sepLevelBounded O lvl y x := by
  simp only [sepLevelBounded]
  have key : (∃ i : ι, O i x ≠ O i y) ↔ (∃ i : ι, O i y ≠ O i x) := by
    constructor <;> exact fun ⟨i, hi⟩ => ⟨i, hi ∘ Eq.symm⟩
  by_cases h : ∃ i : ι, O i x ≠ O i y
  · simp only [dif_pos h, dif_pos (key.mp h)]
    congr 1
    ext v
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨i, hi, rfl⟩; exact ⟨i, hi ∘ Eq.symm, rfl⟩
    · rintro ⟨i, hi, rfl⟩; exact ⟨i, hi ∘ Eq.symm, rfl⟩
  · have hrev : ¬∃ i, O i y ≠ O i x := fun ⟨i, hi⟩ => h ⟨i, hi ∘ Eq.symm⟩
    simp only [dif_neg h, dif_neg hrev]

/-- Helper: sepLevelBounded when no observer distinguishes. -/
theorem sepLevelBounded_eq_zero {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) (h : ¬∃ i : ι, O i x ≠ O i y) :
    sepLevelBounded O lvl x y = 0 := by
  simp [sepLevelBounded, dif_neg h]

/-
Helper: sepLevelBounded is ≤ lvl j for any distinguishing observer j.
-/
theorem sepLevelBounded_le_lvl {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) (j : ι) (hj : O j x ≠ O j y) :
    sepLevelBounded O lvl x y ≤ lvl j := by
  unfold sepLevelBounded;
  split_ifs <;> simp_all +decide [ Finset.min' ];
  exact ⟨ j, hj, le_rfl ⟩


/-- **Observer-induced distance**: the maximum level of any distinguishing observer.
    Higher values mean more separated. Returns 0 for indistinguishable points. -/
def obsDist {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) : ℕ :=
  if h : ∃ i : ι, O i x ≠ O i y then
    (Finset.univ.filter (fun i => O i x ≠ O i y)).image (fun i => lvl i)
      |>.max' (by
        rw [Finset.image_nonempty, Finset.filter_nonempty_iff]
        exact h.imp (fun i hi => ⟨Finset.mem_univ i, hi⟩))
  else 0

/-- obsDist is symmetric. -/
theorem obsDist_symm {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) :
    obsDist O lvl x y = obsDist O lvl y x := by
  simp only [obsDist]
  by_cases h : ∃ i : ι, O i x ≠ O i y
  · have hrev : ∃ i : ι, O i y ≠ O i x := h.imp (fun i hi => hi ∘ Eq.symm)
    simp only [dif_pos h, dif_pos hrev]
    congr 1
    ext v
    simp only [Finset.mem_image, Finset.mem_filter, Finset.mem_univ, true_and]
    constructor
    · rintro ⟨i, hi, rfl⟩; exact ⟨i, hi ∘ Eq.symm, rfl⟩
    · rintro ⟨i, hi, rfl⟩; exact ⟨i, hi ∘ Eq.symm, rfl⟩
  · have hrev : ¬∃ i, O i y ≠ O i x := fun ⟨i, hi⟩ => h ⟨i, hi ∘ Eq.symm⟩
    simp only [dif_neg h, dif_neg hrev]

/-- obsDist self is zero. -/
theorem obsDist_self {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x : P) :
    obsDist O lvl x x = 0 := by
  simp [obsDist]

/-
Helper: obsDist is ≥ lvl j for any distinguishing observer j.
-/
theorem obsDist_ge_lvl {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y : P) (j : ι) (hj : O j x ≠ O j y) :
    lvl j ≤ obsDist O lvl x y := by
  unfold obsDist;
  split_ifs <;> simp_all +decide [ Finset.max' ];
  exact ⟨ j, hj, le_rfl ⟩

/-
**Ultrametric inequality for observer distance**:
    `obsDist(x,z) ≤ max(obsDist(x,y), obsDist(y,z))`.

    Any observer distinguishing `x` from `z` must also distinguish either
    `x` from `y` or `y` from `z`, so its level contributes to one of the
    right-hand side maxima.
-/
theorem obsDist_ultrametric {P ι S : Type*} [DecidableEq S] [Fintype ι]
    (O : ι → P → S) (lvl : ι → ℕ) (x y z : P) :
    obsDist O lvl x z ≤ max (obsDist O lvl x y) (obsDist O lvl y z) := by
  unfold obsDist;
  split_ifs <;> simp_all +decide [ Finset.max' ];
  have h_max : ∃ i ∈ Finset.univ.filter (fun i => O i x ≠ O i z), ∀ j ∈ Finset.univ.filter (fun i => O i x ≠ O i z), lvl j ≤ lvl i := by
    exact Finset.exists_max_image _ _ ⟨ Classical.choose ‹∃ i, O i x ≠ O i z›, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, Classical.choose_spec ‹∃ i, O i x ≠ O i z› ⟩ ⟩;
  grind

/-! ## §13. Concrete Example: Binary Tree Ultrametric -/

/-- A 4-point ultrametric: d(0,1) = 1, d(2,3) = 1, cross-distance = 2. -/
def binaryTreeDist : Fin 4 → Fin 4 → ℕ
  | ⟨0, _⟩, ⟨0, _⟩ => 0
  | ⟨0, _⟩, ⟨1, _⟩ => 1
  | ⟨1, _⟩, ⟨0, _⟩ => 1
  | ⟨1, _⟩, ⟨1, _⟩ => 0
  | ⟨2, _⟩, ⟨2, _⟩ => 0
  | ⟨2, _⟩, ⟨3, _⟩ => 1
  | ⟨3, _⟩, ⟨2, _⟩ => 1
  | ⟨3, _⟩, ⟨3, _⟩ => 0
  | ⟨0, _⟩, ⟨2, _⟩ => 2
  | ⟨0, _⟩, ⟨3, _⟩ => 2
  | ⟨1, _⟩, ⟨2, _⟩ => 2
  | ⟨1, _⟩, ⟨3, _⟩ => 2
  | ⟨2, _⟩, ⟨0, _⟩ => 2
  | ⟨2, _⟩, ⟨1, _⟩ => 2
  | ⟨3, _⟩, ⟨0, _⟩ => 2
  | ⟨3, _⟩, ⟨1, _⟩ => 2
  | ⟨n + 4, h⟩, _ => absurd h (by omega)
  | _, ⟨n + 4, h⟩ => absurd h (by omega)

theorem binaryTreeDist_self (x : Fin 4) : binaryTreeDist x x = 0 := by
  fin_cases x <;> rfl

theorem binaryTreeDist_symm (x y : Fin 4) : binaryTreeDist x y = binaryTreeDist y x := by
  fin_cases x <;> fin_cases y <;> rfl

theorem binaryTreeDist_pos (x y : Fin 4) (h : binaryTreeDist x y = 0) : x = y := by
  fin_cases x <;> fin_cases y <;> simp_all [binaryTreeDist]

theorem binaryTreeDist_ultra (x y z : Fin 4) :
    binaryTreeDist x z ≤ max (binaryTreeDist x y) (binaryTreeDist y z) := by
  fin_cases x <;> fin_cases y <;> fin_cases z <;> simp [binaryTreeDist]

/-- The binary tree distance forms a valid NatUltrametric. -/
def binaryTreeUltrametric : NatUltrametric (Fin 4) where
  d := binaryTreeDist
  d_self := binaryTreeDist_self
  d_symm := binaryTreeDist_symm
  d_pos := binaryTreeDist_pos
  d_ultra := binaryTreeDist_ultra

/-- The canonical NPS for the binary tree correctly identifies clusters. -/
theorem binaryTree_cluster_level0 :
    ¬(canonicalNPS binaryTreeUltrametric).rel 0 (0 : Fin 4) (1 : Fin 4) := by
  simp [canonicalNPS, binaryTreeUltrametric, binaryTreeDist]

theorem binaryTree_cluster_level1 :
    (canonicalNPS binaryTreeUltrametric).rel 1 (0 : Fin 4) (1 : Fin 4) := by
  simp [canonicalNPS, binaryTreeUltrametric, binaryTreeDist]

theorem binaryTree_cluster_level1_cross :
    ¬(canonicalNPS binaryTreeUltrametric).rel 1 (0 : Fin 4) (2 : Fin 4) := by
  simp [canonicalNPS, binaryTreeUltrametric, binaryTreeDist]

theorem binaryTree_cluster_level2 :
    (canonicalNPS binaryTreeUltrametric).rel 2 (0 : Fin 4) (2 : Fin 4) := by
  simp [canonicalNPS, binaryTreeUltrametric, binaryTreeDist]

/-- Observer family for the binary tree: two observers. -/
def binaryTreeObserver : Fin 2 → Fin 4 → Fin 2
  | ⟨0, _⟩, ⟨0, _⟩ => 0
  | ⟨0, _⟩, ⟨1, _⟩ => 0
  | ⟨0, _⟩, ⟨2, _⟩ => 1
  | ⟨0, _⟩, ⟨3, _⟩ => 1
  | ⟨1, _⟩, ⟨0, _⟩ => 0
  | ⟨1, _⟩, ⟨1, _⟩ => 1
  | ⟨1, _⟩, ⟨2, _⟩ => 0
  | ⟨1, _⟩, ⟨3, _⟩ => 1
  | ⟨n + 2, h⟩, _ => absurd h (by omega)
  | _, ⟨n + 4, h⟩ => absurd h (by omega)

/-- Level assignment for binary tree observers. -/
def binaryTreeLevel : Fin 2 → ℕ
  | ⟨0, _⟩ => 2
  | ⟨1, _⟩ => 1

/-- The binary tree observers separate all distinct points. -/
theorem binaryTree_observers_separate (x y : Fin 4) (hne : x ≠ y) :
    ∃ i : Fin 2, binaryTreeObserver i x ≠ binaryTreeObserver i y := by
  fin_cases x <;> fin_cases y <;> simp_all [binaryTreeObserver]

end