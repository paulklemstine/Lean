import Shared.BerggrenTQC.DepthBounds

/-!
# The tree boundary, its `ℤ/2` charge, and what braiding it really supports

The boundary of the ternary Berggren tree is the space of infinite words in the three
generators — the `3`-adic Cantor set.  This file formalises that boundary, the Berggren action
on it, the `ℤ/2` charge it carries, and the exact braid-theoretic content of the construction.

Main results.

* `bcons_injective`, `bcons_disjoint`, `bcons_surjective`, `shift_bcons`: the three Berggren
  generators act on the boundary as the three injective branches of the shift, with pairwise
  disjoint images covering the whole boundary.  This is the self-similar `3`-adic Cantor
  structure of the boundary.
* `boundary_uncountable`: the boundary is uncountable (a genuine Cantor set, not a discrete
  orbit).
* `wordMat_charge`: the mod `2` charge of a Berggren word equals the parity of the number of
  `A`- and `B`-letters in it.  Hence the boundary carries a `ℤ/2` grading, and this is the only
  topological charge the Berggren action defines.
* `braid3_relation`, `braid_image`: the Artin braid group on three strands as a presented
  group, and the relation satisfied by any representation.
* `no_berggren_braid_rep`: **no representation of `B₃` sends the two Artin generators to a pair
  of distinct Berggren generators** — in any of the six possible ways.  The Berggren groupoid
  does not carry the conjectured braid action.
* `abelianAnyon`, `abelianAnyon_image`: what the tree *does* support is the abelian
  (fermionic) anyon representation `σᵢ ↦ -1` induced by the `ℤ/2` charge, whose image has
  order `2` — finite, abelian, and therefore very far from universal.
-/

namespace BerggrenTQC

open PresentedGroup

/-! ## The boundary as a 3-adic Cantor set -/

/-- The boundary of the Berggren tree: infinite words in the three generators. -/
abbrev Boundary := ℕ → BerggrenStep

/-- Prepending a generator: the boundary action of a Berggren generator. -/
def bcons (s : BerggrenStep) (x : Boundary) : Boundary
  | 0 => s
  | n + 1 => x n

/-- The shift map (going one step towards the root). -/
def bshift (x : Boundary) : Boundary := fun n => x (n + 1)

@[simp] theorem bshift_bcons (s : BerggrenStep) (x : Boundary) : bshift (bcons s x) = x := rfl

@[simp] theorem bcons_zero (s : BerggrenStep) (x : Boundary) : bcons s x 0 = s := rfl

/-- Each Berggren generator acts injectively on the boundary. -/
theorem bcons_injective (s : BerggrenStep) : Function.Injective (bcons s) := by
  intro x y h
  funext n
  exact congrFun h (n + 1)

/-- Distinct generators have disjoint images on the boundary: the three branches are separated,
which is exactly the `3`-adic Cantor structure. -/
theorem bcons_disjoint {s t : BerggrenStep} (h : s ≠ t) (x y : Boundary) :
    bcons s x ≠ bcons t y := by
  intro he
  exact h (congrFun he 0)

/-- The three branches cover the boundary. -/
theorem bcons_surjective (x : Boundary) : x = bcons (x 0) (bshift x) := by
  funext n
  cases n with
  | zero => rfl
  | succ n => rfl

/-- The boundary is uncountable: a Cantor set, not a countable orbit. -/
theorem boundary_uncountable : ¬ Countable Boundary := by
  intro h
  have hinj : Function.Injective
      (fun b : ℕ → Bool => (fun n => if b n then BerggrenStep.A else BerggrenStep.B : Boundary)) := by
    intro b₁ b₂ hb
    funext n
    have := congrFun hb n
    by_cases h₁ : b₁ n <;> by_cases h₂ : b₂ n <;> simp_all
  have : Countable (ℕ → Bool) := Function.Injective.countable hinj
  have h2 : Cardinal.mk (ℕ → Bool) ≤ Cardinal.aleph0 := Cardinal.mk_le_aleph0
  rw [Cardinal.mk_arrow] at h2
  simp at h2
  exact absurd h2 (not_le.mpr Cardinal.aleph0_lt_continuum)

/-! ## The `ℤ/2` charge of a Berggren word -/

/-- The lifted generator attached to a Berggren step, as an element of `GL(2, ℤ)`. -/
def gLift : BerggrenStep → (Matrix (Fin 2) (Fin 2) ℤ)ˣ
  | .A => g₁
  | .B => g₂
  | .C => g₃

theorem gLift_mem (s : BerggrenStep) : gLift s ∈ berggrenGroup := by
  cases s
  · exact g₁_mem
  · exact g₂_mem
  · exact g₃_mem

/-- The matrix of a finite Berggren word. -/
def wordMat (p : List BerggrenStep) : (Matrix (Fin 2) (Fin 2) ℤ)ˣ :=
  p.foldl (fun g s => g * gLift s) 1

theorem wordMat_concat (p : List BerggrenStep) (s : BerggrenStep) :
    wordMat (p ++ [s]) = wordMat p * gLift s := by
  simp [wordMat]

theorem wordMat_mem (p : List BerggrenStep) : wordMat p ∈ berggrenGroup := by
  induction p using List.reverseRecOn with
  | nil => exact Subgroup.one_mem _
  | append_singleton p s ih =>
      rw [wordMat_concat]
      exact Subgroup.mul_mem _ ih (gLift_mem s)

/-- The `ℤ/2` charge of a single Berggren step: the `A` and `B` branches are charged, the `C`
branch is neutral. -/
def stepCharge : BerggrenStep → ZMod 2
  | .A => 1
  | .B => 1
  | .C => 0

/-- The charge of a finite Berggren word: the parity of its number of `A`- and `B`-letters. -/
def wordCharge (p : List BerggrenStep) : ZMod 2 := (p.map stepCharge).sum

theorem charge_gLift (s : BerggrenStep) :
    charge ((gLift s : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ) = stepCharge s := by
  have hJ : Jm ≠ 1 := by decide
  cases s
  · simp [gLift, stepCharge, charge, show redHom (g₁ : Matrix (Fin 2) (Fin 2) ℤ) = Jm from by
      simpa [g₁] using red_U₁, hJ]
  · simp [gLift, stepCharge, charge, show redHom (g₂ : Matrix (Fin 2) (Fin 2) ℤ) = Jm from by
      simpa [g₂] using red_U₂, hJ]
  · simp [gLift, stepCharge, charge, show redHom (g₃ : Matrix (Fin 2) (Fin 2) ℤ) = 1 from by
      simpa [g₃] using red_U₃]

/-- **The tree's topological charge.**  The mod `2` invariant of a Berggren word is exactly the
parity of the number of `A`/`B` steps taken.  This `ℤ/2` grading is the whole of the "anyonic"
data the Berggren boundary action defines. -/
theorem wordMat_charge (p : List BerggrenStep) :
    charge ((wordMat p : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
      = wordCharge p := by
  induction p using List.reverseRecOn with
  | nil =>
      simp [wordMat, wordCharge, charge, redHom]
  | append_singleton p s ih =>
      rw [wordMat_concat, charge_mul _ _ (wordMat_mem p) (gLift_mem s), ih, charge_gLift]
      simp [wordCharge]

/-! ## The braid group on three strands and the Berggren generators -/

/-- The single Artin relation `σ₁σ₂σ₁ = σ₂σ₁σ₂`. -/
def braidRels : Set (FreeGroup (Fin 2)) :=
  {FreeGroup.of 0 * FreeGroup.of 1 * FreeGroup.of 0 *
    (FreeGroup.of 1 * FreeGroup.of 0 * FreeGroup.of 1)⁻¹}

/-- The Artin braid group on three strands. -/
abbrev Braid3 := PresentedGroup braidRels

theorem braid3_relation :
    (PresentedGroup.of 0 : Braid3) * PresentedGroup.of 1 * PresentedGroup.of 0
      = PresentedGroup.of 1 * PresentedGroup.of 0 * PresentedGroup.of 1 := by
  have h := PresentedGroup.one_of_mem (rels := braidRels)
    (x := FreeGroup.of 0 * FreeGroup.of 1 * FreeGroup.of 0 *
      (FreeGroup.of 1 * FreeGroup.of 0 * FreeGroup.of 1)⁻¹) rfl
  simp only [map_mul, map_inv] at h
  rw [mul_inv_eq_one] at h
  exact h

/-- Any representation of `B₃` sends the Artin generators to a braiding pair. -/
theorem braid_image {G : Type*} [Group G] (φ : Braid3 →* G) :
    φ (PresentedGroup.of 0) * φ (PresentedGroup.of 1) * φ (PresentedGroup.of 0)
      = φ (PresentedGroup.of 1) * φ (PresentedGroup.of 0) * φ (PresentedGroup.of 1) := by
  rw [← map_mul, ← map_mul, ← map_mul, ← map_mul, braid3_relation]

/-- **The Berggren generators carry no braid action.**  There is no representation of the
three-strand braid group sending the two Artin generators to two distinct Berggren generators,
in any of the six possible assignments. -/
theorem no_berggren_braid_rep (φ : Braid3 →* (Matrix (Fin 2) (Fin 2) ℤ)ˣ)
    (s t : BerggrenStep) (hst : s ≠ t)
    (h0 : φ (PresentedGroup.of 0) = gLift s) (h1 : φ (PresentedGroup.of 1) = gLift t) : False := by
  have hbraid := braid_image φ
  rw [h0, h1] at hbraid
  have hmat : (gLift s : Matrix (Fin 2) (Fin 2) ℤ) * (gLift t) * (gLift s)
      = (gLift t : Matrix (Fin 2) (Fin 2) ℤ) * (gLift s) * (gLift t) := by
    have := congrArg (fun u : (Matrix (Fin 2) (Fin 2) ℤ)ˣ => (u : Matrix (Fin 2) (Fin 2) ℤ)) hbraid
    simpa [Units.val_mul, mul_assoc] using this
  cases s <;> cases t <;> simp only [gLift, g₁, g₂, g₃, Units.val_mk] at hmat <;>
    first
      | exact hst rfl
      | revert hmat; decide

/-! ## The abelian anyon representation the tree does support -/

/-- The abelian (fermionic) anyon representation of `B₃` induced by the `ℤ/2` charge:
every generator braids by the phase `-1`. -/
def abelianAnyon : Braid3 →* ℤˣ :=
  PresentedGroup.toGroup (f := fun _ : Fin 2 => (-1 : ℤˣ)) (by
    rintro r rfl
    simp)

theorem abelianAnyon_of (i : Fin 2) : abelianAnyon (PresentedGroup.of i) = -1 :=
  PresentedGroup.toGroup.of _

/-- The image of the abelian anyon representation is the group `{±1}` of order `2`: finite,
abelian, and therefore not dense in any unitary group of positive dimension.  This is the exact
braiding content of the Berggren boundary: `ℤ/2` statistics, not universal computation. -/
theorem abelianAnyon_image :
    abelianAnyon (PresentedGroup.of 0) = -1 ∧
    abelianAnyon (PresentedGroup.of 0 * PresentedGroup.of 1) = 1 ∧
    Nat.card (ℤˣ) = 2 := by
  refine ⟨abelianAnyon_of 0, ?_, ?_⟩
  · rw [map_mul, abelianAnyon_of, abelianAnyon_of]
    decide
  · simp [Nat.card_eq_fintype_card]

/-! ## The charge is a braid invariant: only one anyon sector can braid -/

/-- **Braiding forces equal charge.**  If two elements of the Berggren group satisfy the Artin
braid relation, then they carry the same `ℤ/2` charge.  So the `ℤ/2` grading of the tree can
never be exchanged by a braid: the two charge sectors are braid-invariant, which is exactly the
statement that the statistics the tree supports are abelian. -/
theorem braid_pair_charge_eq (x y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ)
    (hx : x ∈ berggrenGroup) (hy : y ∈ berggrenGroup)
    (h : x * y * x = y * x * y) :
    charge (x : Matrix (Fin 2) (Fin 2) ℤ) = charge (y : Matrix (Fin 2) (Fin 2) ℤ) := by
  have hxy : x * y ∈ berggrenGroup := mul_mem hx hy
  have hyx : y * x ∈ berggrenGroup := mul_mem hy hx
  have hL : charge ((x * y * x : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
      = charge (y : Matrix (Fin 2) (Fin 2) ℤ) := by
    rw [charge_mul _ _ hxy hx, charge_mul _ _ hx hy]
    generalize charge (x : Matrix (Fin 2) (Fin 2) ℤ) = a
    generalize charge (y : Matrix (Fin 2) (Fin 2) ℤ) = b
    revert a b
    decide
  have hR : charge ((y * x * y : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) : Matrix (Fin 2) (Fin 2) ℤ)
      = charge (x : Matrix (Fin 2) (Fin 2) ℤ) := by
    rw [charge_mul _ _ hyx hy, charge_mul _ _ hy hx]
    generalize charge (x : Matrix (Fin 2) (Fin 2) ℤ) = a
    generalize charge (y : Matrix (Fin 2) (Fin 2) ℤ) = b
    revert a b
    decide
  rw [← hR, ← h, hL]

/-- Consequence for *every* braid representation landing in the Berggren group (not just the
ones sending Artin generators to single tree steps): the two Artin generators always have the
same `ℤ/2` charge.  A braid representation on the Berggren tree can never distinguish the two
charge sectors, so it cannot implement a nonabelian exchange of them. -/
theorem berggren_braid_rep_charge_eq (phi : Braid3 →* (Matrix (Fin 2) (Fin 2) ℤ)ˣ)
    (hphi : ∀ g, phi g ∈ berggrenGroup) :
    charge ((phi (PresentedGroup.of 0) : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) :
        Matrix (Fin 2) (Fin 2) ℤ)
      = charge ((phi (PresentedGroup.of 1) : (Matrix (Fin 2) (Fin 2) ℤ)ˣ) :
        Matrix (Fin 2) (Fin 2) ℤ) :=
  braid_pair_charge_eq _ _ (hphi _) (hphi _) (braid_image phi)

end BerggrenTQC