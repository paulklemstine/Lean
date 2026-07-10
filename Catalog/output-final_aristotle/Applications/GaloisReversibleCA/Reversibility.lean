import Mathlib

/-!
# A Galois-style structure theory of reversible binary cellular automata

This file develops, fully formally, a rigorous fragment of the informal research
programme *"Galois Theory of Cellular Automata: which rules have reversible
dynamics?"*.

We work with **binary cellular automata on a finite cyclic lattice** `ℤ/n`.
A *configuration* is a function `Config n := ZMod n → Bool`.  An elementary
(radius `1`) local rule is a function `r : Bool → Bool → Bool → Bool`; it induces
a **global map** `caMap r : Config n → Config n` by
`caMap r c i = r (c (i-1)) (c i) (c (i+1))`.

A cellular automaton is **reversible** when its global map is a bijection.

The informal mission contains several claims that turn out to be *false as
literally stated* (for instance the claimed order `8!/4 = 10080` of the radius‑1
reversibility group is impossible: the centraliser of the 3‑cycle acting on the
`8` neighbourhoods has order `36`, and reversible global maps are far more
constrained than arbitrary permutations of neighbourhoods).  Rather than chase a
false numerology we isolate and *prove* the genuine mathematical content:

* **Translation invariance (a Hedlund‑type fact).** Every global map commutes
  with the shift: `caMap_shiftFun_comm`.

* **The distinguished reversible rules.** The six "reversible elementary rules"
  singled out in the mission — Wolfram rules `204, 51, 170, 240, 15, 85` — are
  exactly the six local rules that depend on a *single* neighbour, possibly
  negated: identity, complement, left/right shift and their complements.  We
  identify each global map and prove each is a bijection.

* **An irreversible rule.** The constant rule `0` is *not* reversible whenever the
  lattice is non‑trivial (`ruleConst_not_bijective`).

* **The reversibility group.** Reversible global maps commuting with the shift live
  inside the **centraliser of the shift** in `Equiv.Perm (Config n)`, a genuine
  subgroup (`ReversibilityGroup`).

* **Group structure.** The complement is an involution (`complement_pow_two`), the
  shift has order dividing `n` (`shift_pow_card`), the two commute
  (`shift_complement_commute`), and the subgroup they generate is **abelian**
  (`closure_shift_complement_commutative`).

* **Counting.** There are exactly `256` elementary rules and `8` neighbourhoods.
-/

namespace GaloisReversibleCA

open Equiv Function

/-- Configurations of a binary cellular automaton on the cyclic lattice `ℤ/n`. -/
abbrev Config (n : ℕ) := ZMod n → Bool

variable {n : ℕ}

/-! ## Counting elementary rules and neighbourhoods -/

/-- There are exactly `256` elementary (radius‑1 binary) local rules. -/
theorem card_rules : Fintype.card (Bool → Bool → Bool → Bool) = 256 := by simp

/-- There are exactly `8 = 2³` local neighbourhoods of radius `1`. -/
theorem card_neighborhoods : Fintype.card (Fin 3 → Bool) = 8 := by decide

/-! ## Basic operators: shift and complement -/

/-- The (left) shift of a configuration: `shiftFun c i = c (i+1)`. -/
def shiftFun (c : Config n) : Config n := fun i => c (i + 1)

/-- The right shift, inverse to `shiftFun`: `unshiftFun c i = c (i-1)`. -/
def unshiftFun (c : Config n) : Config n := fun i => c (i - 1)

/-- The shift as an explicit permutation of the configuration space. -/
def shift : Config n ≃ Config n where
  toFun := shiftFun
  invFun := unshiftFun
  left_inv := by intro c; funext i; simp [shiftFun, unshiftFun]
  right_inv := by intro c; funext i; simp [shiftFun, unshiftFun]

@[simp] theorem shift_apply (c : Config n) : shift c = shiftFun c := rfl
@[simp] theorem shift_symm_apply (c : Config n) : shift.symm c = unshiftFun c := rfl

/-- Pointwise complement of a configuration. -/
def complementFun (c : Config n) : Config n := fun i => !(c i)

/-- Complementation is an involution. -/
theorem complement_involutive : Function.Involutive (complementFun (n := n)) := by
  intro c; funext i; simp [complementFun]

/-- The complement as a permutation of the configuration space. -/
def complement : Config n ≃ Config n := (complement_involutive (n := n)).toPerm

@[simp] theorem complement_apply (c : Config n) : complement c = complementFun c := rfl

/-! ## Global maps of elementary cellular automata -/

/-- The global map of the elementary CA with local rule `r`:
`caMap r c i = r (c (i-1)) (c i) (c (i+1))`. -/
def caMap (r : Bool → Bool → Bool → Bool) (c : Config n) : Config n :=
  fun i => r (c (i - 1)) (c i) (c (i + 1))

/-- **Translation invariance (Hedlund‑type).** Every elementary global map
commutes with the shift. -/
theorem caMap_shiftFun_comm (r : Bool → Bool → Bool → Bool) (c : Config n) :
    caMap r (shiftFun c) = shiftFun (caMap r c) := by
  funext i
  simp only [caMap, shiftFun, sub_add_cancel, add_sub_cancel_right]

/-! ## The six distinguished reversible rules -/

/-- Rule `204`: output equals the centre cell — the identity map. -/
theorem rule204_eq_id : caMap (fun _ c _ => c) = (id : Config n → Config n) := by
  funext c i; rfl

/-- Rule `51`: output is the negated centre cell — the complement. -/
theorem rule51_eq_complement :
    caMap (fun _ c _ => !c) = (complementFun : Config n → Config n) := by
  funext c i; rfl

/-- Rule `170`: output equals the right neighbour — the left shift. -/
theorem rule170_eq_shift :
    caMap (fun _ _ r => r) = (shiftFun : Config n → Config n) := by
  funext c i; rfl

/-- Rule `240`: output equals the left neighbour — the right shift. -/
theorem rule240_eq_unshift :
    caMap (fun l _ _ => l) = (unshiftFun : Config n → Config n) := by
  funext c i; rfl

/-- Rule `15`: output is the negated left neighbour — complement of the right shift. -/
theorem rule15_eq :
    caMap (fun l _ _ => !l) = (complementFun ∘ unshiftFun : Config n → Config n) := by
  funext c i; rfl

/-- Rule `85`: output is the negated right neighbour — complement of the left shift. -/
theorem rule85_eq :
    caMap (fun _ _ r => !r) = (complementFun ∘ shiftFun : Config n → Config n) := by
  funext c i; rfl

/-! ## Reversibility of the distinguished rules -/

theorem shiftFun_bijective : Bijective (shiftFun : Config n → Config n) :=
  shift.bijective

theorem unshiftFun_bijective : Bijective (unshiftFun : Config n → Config n) :=
  shift.symm.bijective

theorem complementFun_bijective : Bijective (complementFun : Config n → Config n) :=
  complement.bijective

theorem rule204_bijective : Bijective (caMap (fun _ c _ => c) : Config n → Config n) := by
  rw [rule204_eq_id]; exact bijective_id

theorem rule51_bijective : Bijective (caMap (fun _ c _ => !c) : Config n → Config n) := by
  rw [rule51_eq_complement]; exact complementFun_bijective

theorem rule170_bijective : Bijective (caMap (fun _ _ r => r) : Config n → Config n) := by
  rw [rule170_eq_shift]; exact shiftFun_bijective

theorem rule240_bijective : Bijective (caMap (fun l _ _ => l) : Config n → Config n) := by
  rw [rule240_eq_unshift]; exact unshiftFun_bijective

theorem rule15_bijective : Bijective (caMap (fun l _ _ => !l) : Config n → Config n) := by
  rw [rule15_eq]; exact complementFun_bijective.comp unshiftFun_bijective

theorem rule85_bijective : Bijective (caMap (fun _ _ r => !r) : Config n → Config n) := by
  rw [rule85_eq]; exact complementFun_bijective.comp shiftFun_bijective

/-! ## An irreversible rule: the constant rule `0` -/

/-- The constant rule `0` (output always `false`) is **not** reversible on any
non‑trivial lattice: its image is the single all‑`false` configuration. -/
theorem ruleConst_not_bijective [NeZero n] :
    ¬ Bijective (caMap (fun _ _ _ => false) : Config n → Config n) := by
  intro h
  obtain ⟨c, hc⟩ := h.surjective (fun _ => true)
  have : (fun _ => true : Config n) (0 : ZMod n) = (caMap (fun _ _ _ => false) c) 0 := by
    rw [hc]
  simp [caMap] at this

/-! ## The reversibility group -/

/-- The **reversibility group** of the lattice `ℤ/n`: the centraliser of the shift
inside the full symmetric group of the configuration space. -/
def ReversibilityGroup (n : ℕ) : Subgroup (Equiv.Perm (Config n)) :=
  Subgroup.centralizer {shift}

/-- The shift commutes with the complement (pointwise). -/
theorem shiftFun_complementFun_comm :
    (shiftFun ∘ complementFun : Config n → Config n) = complementFun ∘ shiftFun := by
  funext c i; simp [shiftFun, complementFun]

/-- The shift belongs to the reversibility group. -/
theorem shift_mem : (shift : Equiv.Perm (Config n)) ∈ ReversibilityGroup n := by
  rw [ReversibilityGroup, Subgroup.mem_centralizer_iff]
  intro h hh
  simp only [Set.mem_singleton_iff] at hh
  subst hh; rfl

/-- The complement belongs to the reversibility group. -/
theorem complement_mem : (complement : Equiv.Perm (Config n)) ∈ ReversibilityGroup n := by
  rw [ReversibilityGroup, Subgroup.mem_centralizer_iff]
  intro h hh
  simp only [Set.mem_singleton_iff] at hh
  subst hh
  apply Equiv.ext
  intro c
  simp only [Equiv.Perm.mul_apply, complement_apply, shift_apply]
  have := congrFun (shiftFun_complementFun_comm (n := n)) c
  simpa [Function.comp] using this.symm

/-! ## Group structure: order and commutativity -/

/-- The complement is an involution as a permutation. -/
theorem complement_pow_two : (complement : Equiv.Perm (Config n)) ^ 2 = 1 := by
  ext c i
  simp [pow_two, complement, complementFun]

/-- Iterating the shift `k` times translates the index by `k`. -/
theorem shift_pow_apply (k : ℕ) (c : Config n) :
    ((shift : Equiv.Perm (Config n)) ^ k) c = fun i => c (i + (k : ZMod n)) := by
  induction' k with k ih;
  · aesop;
  · simp_all +decide [ pow_succ, ← add_assoc ];
    rw [ show ( shift ^ k ) ( shiftFun c ) = shiftFun ( ( shift ^ k ) c ) from ?_, ih ];
    · exact funext fun i => by unfold shiftFun; ring_nf;
    · exact Nat.recOn k rfl fun n ih => by simp +decide [ *, pow_succ' ] ;

/-- The shift has order dividing `n`: `shift ^ n = 1`. -/
theorem shift_pow_card : (shift : Equiv.Perm (Config n)) ^ n = 1 := by
  ext c i; simp +decide [ shift_pow_apply ] ;

/-- The shift and the complement commute as permutations. -/
theorem shift_complement_commute :
    Commute (shift : Equiv.Perm (Config n)) complement := by
  apply Equiv.ext
  intro c
  simp only [Equiv.Perm.mul_apply, shift_apply, complement_apply]
  have := congrFun (shiftFun_complementFun_comm (n := n)) c
  simpa [Function.comp] using this

/-
For `0 < k < n`, iterating the shift `k` times is **not** the identity: it
moves the point-mass configuration at index `0`.
-/
theorem shift_pow_ne_one [NeZero n] {k : ℕ} (hk0 : 0 < k) (hkn : k < n) :
    (shift : Equiv.Perm (Config n)) ^ k ≠ 1 := by
  intro h;
  replace h := congr_arg ( fun f => f ( fun i => if i = 0 then Bool.true else Bool.false ) 0 ) h ; simp_all +decide [ shift_pow_apply ];
  rw [ ZMod.natCast_eq_zero_iff ] at h ; exact Nat.not_dvd_of_pos_of_lt hk0 hkn h

/-
**Exact order of the shift.** On a non-trivial cyclic lattice the shift has
order exactly `n` (not merely dividing `n`).
-/
theorem shift_orderOf [NeZero n] : orderOf (shift : Equiv.Perm (Config n)) = n := by
  apply orderOf_eq_iff (NeZero.pos n) |>.2;
  exact ⟨ shift_pow_card, fun m mn hm => shift_pow_ne_one hm mn ⟩

/-
The subgroup generated by the shift and the complement is **abelian**: any two
of its elements commute.
-/
theorem closure_shift_complement_commutative
    (x : Equiv.Perm (Config n))
    (hx : x ∈ Subgroup.closure ({shift, complement} : Set (Equiv.Perm (Config n))))
    (y : Equiv.Perm (Config n))
    (hy : y ∈ Subgroup.closure ({shift, complement} : Set (Equiv.Perm (Config n)))) :
    x * y = y * x := by
  rw [ Subgroup.mem_closure ] at hx hy;
  contrapose! hx;
  refine' ⟨ Subgroup.centralizer { shift, complement }, _, _ ⟩ <;> simp_all +decide [ Set.subset_def, Subgroup.mem_centralizer_iff ];
  · exact ⟨ shift_complement_commute.eq, shift_complement_commute.symm.eq ⟩;
  · intro h₁ h₂; have := hy ( Subgroup.centralizer { x } ) ; simp_all +decide [ Subgroup.mem_centralizer_iff ] ;
    specialize hy ( Subgroup.centralizer { x } ) ; simp_all +decide [ Subgroup.mem_centralizer_iff ] ;

end GaloisReversibleCA