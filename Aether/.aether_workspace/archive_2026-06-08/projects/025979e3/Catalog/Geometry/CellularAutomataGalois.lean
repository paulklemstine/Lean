import Mathlib

/-!
# Galois Theory of Cellular Automata: Reversibility Groups

We formalize cellular automata on periodic configurations and prove that
reversible (bijective) CAs that commute with the shift form a group —
the **reversibility group** of the configuration space.

## Main Definitions

* `CellularAutomata.shiftConfig` — The shift operator on periodic configurations
* `CellularAutomata.IsShiftEquivariant` — A map commutes with all shifts
* `CellularAutomata.LocalRule` — A local rule of radius r on alphabet α
* `CellularAutomata.applyLocal` — Global map induced by a local rule
* `CellularAutomata.ReversibilitySubgroup` — The subgroup of Equiv.Perm consisting
  of shift-equivariant permutations

## Main Results

* `CellularAutomata.inv_shift_equivariant` — The inverse of a shift-equivariant
  bijection is shift-equivariant (key structural theorem)
* `CellularAutomata.applyLocal_shift_equivariant` — Every local rule induces a
  shift-equivariant global map
* `CellularAutomata.shift_perm_mem_reversibility` — The shift permutation lies in
  the reversibility subgroup
* `CellularAutomata.reversibility_proper_subgroup` — The reversibility group is a
  proper subgroup of the full symmetric group
-/

namespace CellularAutomata

open Function

/-! ### The Shift Operator -/

variable {α : Type*} {n : ℕ}

/-- The shift operator: translates a periodic configuration by k positions. -/
def shiftConfig [Add (ZMod n)] (k : ZMod n) (c : ZMod n → α) : ZMod n → α :=
  fun i => c (i + k)

/-- Shifting by zero is the identity. -/
@[simp]
theorem shiftConfig_zero [NeZero n] (c : ZMod n → α) :
    shiftConfig (0 : ZMod n) c = c := by
  ext i; simp [shiftConfig]

/-- Shifting is functorial: shift by k then by l equals shift by (l + k). -/
theorem shiftConfig_add [NeZero n] (k l : ZMod n) (c : ZMod n → α) :
    shiftConfig k (shiftConfig l c) = shiftConfig (l + k) c := by
  ext i; simp only [shiftConfig]; ring_nf

/-! ### Shift-Equivariance -/

/-- A map on configurations is shift-equivariant if it commutes with all shifts.
This is the algebraic characterization of cellular automata on finite periodic
configurations (the Curtis-Hedlund-Lyndon theorem for finite groups). -/
def IsShiftEquivariant [NeZero n] (F : (ZMod n → α) → (ZMod n → α)) : Prop :=
  ∀ k : ZMod n, ∀ c : ZMod n → α, F (shiftConfig k c) = shiftConfig k (F c)

/-- The identity map is shift-equivariant. -/
theorem id_isShiftEquivariant [NeZero n] :
    IsShiftEquivariant (id : (ZMod n → α) → (ZMod n → α)) := by
  intro k c; rfl

/-- Composition of shift-equivariant maps is shift-equivariant. -/
theorem comp_isShiftEquivariant [NeZero n]
    {F G : (ZMod n → α) → (ZMod n → α)}
    (hF : IsShiftEquivariant F) (hG : IsShiftEquivariant G) :
    IsShiftEquivariant (F ∘ G) := by
  intro k c
  simp only [comp_apply]
  rw [hG k c, hF k (G c)]

/-
**Key theorem**: The inverse of a shift-equivariant bijection is shift-equivariant.

This is the non-trivial direction for the group structure: if F commutes with all
shifts and F is a bijection, then F⁻¹ also commutes with all shifts.
The proof uses: F(σ_k(c)) = σ_k(F(c)) implies F⁻¹(σ_k(d)) = σ_k(F⁻¹(d))
by substituting d = F(c) and applying F⁻¹ to both sides.
-/
theorem inv_shift_equivariant [NeZero n] [DecidableEq α] [Fintype α]
    (e : Equiv.Perm (ZMod n → α))
    (he : IsShiftEquivariant (e : (ZMod n → α) → (ZMod n → α))) :
    IsShiftEquivariant (e.symm : (ZMod n → α) → (ZMod n → α)) := by
  intro k c;
  apply_fun e using Equiv.injective e;
  simp +decide [ he k ( e.symm c ) ]

/-! ### The Reversibility Subgroup -/

/-- The reversibility subgroup: all shift-equivariant permutations of the
configuration space (ZMod n → α). By the Curtis-Hedlund-Lyndon theorem,
these correspond exactly to reversible cellular automata on ℤ/nℤ. -/
def ReversibilitySubgroup [NeZero n] [DecidableEq α] [Fintype α] :
    Subgroup (Equiv.Perm (ZMod n → α)) where
  carrier := { e | IsShiftEquivariant (e : (ZMod n → α) → (ZMod n → α)) }
  mul_mem' := by
    intro a b ha hb
    show IsShiftEquivariant ((a * b : Equiv.Perm (ZMod n → α)) : (ZMod n → α) → (ZMod n → α))
    intro k c
    simp only [Equiv.Perm.coe_mul, comp_apply]
    rw [hb k c, ha k (b c)]
  one_mem' := by
    show IsShiftEquivariant ((1 : Equiv.Perm (ZMod n → α)) : (ZMod n → α) → (ZMod n → α))
    intro k c; rfl
  inv_mem' := by
    intro a ha
    show IsShiftEquivariant ((a⁻¹ : Equiv.Perm (ZMod n → α)) : (ZMod n → α) → (ZMod n → α))
    have : (a⁻¹ : Equiv.Perm (ZMod n → α)) = a.symm := rfl
    rw [this]
    exact inv_shift_equivariant a ha

/-- The shift permutation: the permutation of configurations induced by shifting by 1. -/
noncomputable def shiftPerm [NeZero n] [DecidableEq α] [Fintype α] :
    Equiv.Perm (ZMod n → α) where
  toFun := shiftConfig (1 : ZMod n)
  invFun := shiftConfig (-1 : ZMod n)
  left_inv := by
    intro c; ext i; simp [shiftConfig]
  right_inv := by
    intro c; ext i; simp [shiftConfig]

/-- The shift permutation is shift-equivariant, hence lies in the reversibility subgroup.
The shift operator commutes with itself — a fundamental symmetry of translational systems. -/
theorem shiftPerm_isShiftEquivariant [NeZero n] [DecidableEq α] [Fintype α] :
    IsShiftEquivariant (shiftPerm (α := α) (n := n) : (ZMod n → α) → (ZMod n → α)) := by
  intro k c
  ext i
  simp [shiftPerm, shiftConfig]
  ring_nf

/-- The shift permutation lies in the reversibility subgroup. -/
theorem shift_perm_mem_reversibility [NeZero n] [DecidableEq α] [Fintype α] :
    (shiftPerm : Equiv.Perm (ZMod n → α)) ∈
      (ReversibilitySubgroup : Subgroup (Equiv.Perm (ZMod n → α))) :=
  shiftPerm_isShiftEquivariant

/-! ### Local Rules and Global Maps -/

/-- A local rule of radius r on alphabet α: maps each neighborhood of size 2r+1 to a value.
In the Wolfram numbering for binary CAs, a rule number N encodes f by its binary digits. -/
def LocalRule (α : Type*) (r : ℕ) := (Fin (2 * r + 1) → α) → α

/-- Extract the neighborhood of cell i in a periodic configuration of period n.
The neighborhood consists of cells at positions i-r, i-r+1, ..., i+r. -/
def neighborhood [NeZero n] (r : ℕ) (c : ZMod n → α) (i : ZMod n) :
    Fin (2 * r + 1) → α :=
  fun j => c (i + (j : ℕ) - (r : ZMod n))

/-- The global map induced by a local rule on periodic configurations.
Each cell's new value is determined by applying the local rule to its neighborhood. -/
def applyLocal [NeZero n] (r : ℕ) (f : LocalRule α r) (c : ZMod n → α) :
    ZMod n → α :=
  fun i => f (neighborhood r c i)

/-
**Theorem**: Every local rule induces a shift-equivariant global map.
This is one half of the Curtis-Hedlund-Lyndon theorem for finite periodic CAs:
locality implies shift-equivariance.
-/
theorem applyLocal_shift_equivariant [NeZero n] (r : ℕ) (f : LocalRule α r) :
    IsShiftEquivariant (applyLocal (n := n) r f) := by
  intro k c; ext i; simp +decide [ applyLocal, neighborhood ] ;
  convert congr_arg f ?_;
  ext j; simp +decide [ shiftConfig, neighborhood ] ; ring;

/-! ### The Complement Involution -/

/-- The complement map on Bool configurations: flips every cell.
This corresponds to Wolfram's Rule 51 for elementary CAs. -/
def complementConfig (n : ℕ) [NeZero n] (c : ZMod n → Bool) : ZMod n → Bool :=
  fun i => !c i

/-- Complement is an involution: applying it twice yields the original. -/
theorem complement_involution (n : ℕ) [NeZero n] (c : ZMod n → Bool) :
    complementConfig n (complementConfig n c) = c := by
  ext i; simp [complementConfig, Bool.not_not]

/-- The complement permutation on Bool configurations. -/
noncomputable def complementPerm (n : ℕ) [NeZero n] :
    Equiv.Perm (ZMod n → Bool) where
  toFun := complementConfig n
  invFun := complementConfig n
  left_inv := complement_involution n
  right_inv := complement_involution n

/-- The complement is shift-equivariant: flipping all bits commutes with translation. -/
theorem complement_isShiftEquivariant (n : ℕ) [NeZero n] :
    IsShiftEquivariant (complementPerm n : (ZMod n → Bool) → (ZMod n → Bool)) := by
  intro k c
  ext i
  simp [complementPerm, complementConfig, shiftConfig]

/-- The complement lies in the reversibility subgroup. -/
theorem complement_mem_reversibility (n : ℕ) [NeZero n] :
    (complementPerm n : Equiv.Perm (ZMod n → Bool)) ∈
      (ReversibilitySubgroup : Subgroup (Equiv.Perm (ZMod n → Bool))) :=
  complement_isShiftEquivariant n

/-! ### Shift and Complement Generate a Dihedral-like Subgroup -/

/-- The complement has order 2 in the reversibility group. -/
theorem complementPerm_sq (n : ℕ) [NeZero n] :
    (complementPerm n) * (complementPerm n) = 1 := by
  ext c; simp [complementPerm, complementConfig, Bool.not_not]

/-
Shift and complement generate a subgroup where the complement commutes with shift.
In the language of group theory, the subgroup ⟨σ, κ⟩ where σ is the shift of order n
and κ is the complement of order 2, and κσ = σκ, is isomorphic to ℤ/nℤ × ℤ/2ℤ.
-/
theorem shift_complement_comm (n : ℕ) [NeZero n] :
    (shiftPerm (α := Bool) (n := n)) * (complementPerm n) =
    (complementPerm n) * (shiftPerm (α := Bool) (n := n)) := by
  ext c i; simp +decide [ shiftPerm, complementPerm ] ;
  unfold shiftConfig complementConfig; aesop;

/-! ### Proper Subgroup Theorem -/

/-
**Theorem**: For n ≥ 2, the reversibility group is a proper subgroup of the full
symmetric group on α^(ℤ/nℤ). Not every permutation of configurations commutes with
the shift — in fact, most do not. This is because a generic permutation breaks
translational symmetry.

We prove this for n = 3, α = Bool (8-element configuration space). The shift
on {0,1}³ is a permutation of the 8 configurations. Since the shift is not the
identity permutation, its centralizer in S₈ is strictly smaller than S₈.
-/
theorem reversibility_proper_subgroup :
    (ReversibilitySubgroup : Subgroup (Equiv.Perm (ZMod 3 → Bool))) ≠ ⊤ := by
  norm_num [ SetLike.ext_iff ];
  refine' ⟨ Equiv.swap 0 ( Pi.single 0 Bool.true ), _ ⟩;
  intro h; have := h 1 0; simp +decide at this;

/-! ### Falsifiable Conjecture

**Conjecture (Reversibility Growth)**:
For binary CAs on ℤ/nℤ, the ratio
  |ReversibilitySubgroup(n)| / |Sym(2^n)|
decreases super-exponentially in n. In other words, the proportion of all permutations
that are shift-equivariant vanishes rapidly.

**Testable prediction**: For n = 3, the reversibility group has order dividing
|Sym(8)| = 40320, and should equal the size of the centralizer of the cyclic shift
in S₈. The shift on {0,1}³ acts on 8 elements with specific cycle structure, and
the centralizer size can be computed from that cycle type.

**Cycle structure of σ on {0,1}³**:
- Fixed points: 000, 111 (2 fixed points)
- 3-cycle: {001, 010, 100} and {011, 110, 101} (2 orbits of size 3)
- Total: 2 fixed + 2 three-cycles
- Centralizer size = 1!·1^1 · 1!·1^1 · 2!·3^2 = 1 · 1 · 2 · 9 = 18

So we conjecture |ReversibilitySubgroup(3, {0,1})| = 18.
-/

end CellularAutomata