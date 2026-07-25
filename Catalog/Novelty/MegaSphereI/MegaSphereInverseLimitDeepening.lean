import Mathlib

/-!
# The Mega-Sphere I (Deepening): collapse, surjectivity, and a contrarian disproof

This file deepens `MegaSphereInverseLimit.lean`.  We reuse the by-hand inverse
limit of a tower of additive groups (redeveloped here so the file is
self-contained) and prove three genuinely new results, in the "contrarian"
spirit of formulating bold statements and either proving or disproving them.

* **General multiplication tower collapses.**
  `MegaSphereDeep.mulTower_invLimit_eq_bot` — for *any* integer `d` with
  `2 ≤ |d|`, the tower `ℤ ←×d— ℤ ←×d— ⋯` has trivial inverse limit.  This
  strictly generalises the doubling collapse (`d = 2`).

* **Contrarian disproof.**  A tempting bold conjecture is: *the inverse limit of
  a tower of nontrivial groups is nontrivial.*  This is **false**:
  `MegaSphereDeep.exists_nontrivial_stages_trivial_invLimit` exhibits a tower
  with every stage `ZMod 2` (nontrivial) but whose connecting maps are all zero,
  giving a trivial inverse limit.  The "mega-object" can be trivial even when
  every finite stage is not.

* **Surjective towers do not collapse.**  Positively,
  `MegaSphereDeep.proj_zero_surjective_of_surjective` proves the Mittag-Leffler
  phenomenon for `ℕ`-indexed towers: if every connecting map is surjective, the
  projection from the inverse limit onto the bottom stage is surjective (so the
  mega-object surjects onto stage `0`).
-/

namespace MegaSphereDeep

universe u

variable {X : ℕ → Type u}

/-! ## Inverse limit of a tower of additive groups (self-contained) -/

/-- The inverse limit of a tower of additive groups. -/
def invLimit [∀ n, AddGroup (X n)] (π : ∀ n, X (n + 1) →+ X n) :
    AddSubgroup (∀ n, X n) where
  carrier := {x | ∀ n, π n (x (n + 1)) = x n}
  zero_mem' := by intro n; simp
  add_mem' := by intro a b ha hb n; simp [map_add, ha n, hb n]
  neg_mem' := by intro a ha n; simp [map_neg, ha n]

@[simp] lemma mem_invLimit [∀ n, AddGroup (X n)] (π : ∀ n, X (n + 1) →+ X n)
    (x : ∀ n, X n) : x ∈ invLimit π ↔ ∀ n, π n (x (n + 1)) = x n := Iff.rfl

/-- The projection of the inverse limit onto stage `n`. -/
def proj [∀ n, AddGroup (X n)] (π : ∀ n, X (n + 1) →+ X n) (n : ℕ) :
    invLimit π →+ X n :=
  (Pi.evalAddMonoidHom X n).comp (invLimit π).subtype

@[simp] lemma proj_apply [∀ n, AddGroup (X n)] (π : ∀ n, X (n + 1) →+ X n)
    (n : ℕ) (x : invLimit π) : proj π n x = (x : ∀ n, X n) n := rfl

/-! ## General multiplication tower collapses -/

/--
An integer divisible by every power of an integer `d` with `2 ≤ |d|` is
zero.
-/
theorem int_eq_zero_of_forall_pow_dvd {d a : ℤ} (hd : 2 ≤ d.natAbs)
    (h : ∀ n : ℕ, d ^ n ∣ a) : a = 0 := by
  contrapose! h;
  -- Choose $n$ such that $|d|^n > |a|$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, d.natAbs ^ n > a.natAbs := by
    exact pow_unbounded_of_one_lt _ hd;
  exact ⟨ n, fun hnn => hn.not_ge <| by simpa [ Int.natAbs_pow ] using Nat.le_of_dvd ( Int.natAbs_pos.mpr h ) <| Int.natAbs_dvd_natAbs.mpr hnn ⟩

/-- The multiplication connecting map `×d : ℤ →+ ℤ`. -/
def mulTower (d : ℤ) : ∀ _n : ℕ, ℤ →+ ℤ := fun _ => AddMonoidHom.mulLeft d

@[simp] lemma mulTower_apply (d : ℤ) (n : ℕ) (a : ℤ) : mulTower d n a = d * a := rfl

/--
**Collapse of the general multiplication tower.**  For every integer `d`
with `2 ≤ |d|`, the tower `ℤ ←×d— ℤ ←×d— ⋯` has trivial inverse limit.
-/
theorem mulTower_invLimit_eq_bot {d : ℤ} (hd : 2 ≤ d.natAbs) :
    invLimit (X := fun _ => ℤ) (mulTower d) = ⊥ := by
  refine' eq_bot_iff.mpr _;
  intro x hx
  have h_eq : ∀ m k : ℕ, x m = d^k * x (m + k) := by
    intro m k; induction' k with k ih <;> simp_all +decide [ pow_succ', mul_assoc ] ;
    grind
  exact (by
  exact funext fun m => int_eq_zero_of_forall_pow_dvd hd fun k => h_eq m k ▸ dvd_mul_right _ _)

/-! ## Contrarian disproof: nontrivial stages, trivial limit -/

/-- The all-zero connecting maps on the constant tower `ZMod 2`. -/
def zeroTower : ∀ _n : ℕ, ZMod 2 →+ ZMod 2 := fun _ => 0

/--
With all connecting maps zero, the inverse limit is trivial.
-/
theorem zeroTower_invLimit_eq_bot :
    invLimit (X := fun _ => ZMod 2) zeroTower = ⊥ := by
  refine' eq_bot_iff.mpr _;
  intro x hx; ext n; have := hx n; simp_all +decide ;
  exact hx n ▸ rfl

/-- **Contrarian disproof.**  The bold conjecture "*the inverse limit of a tower
of nontrivial groups is nontrivial*" is **false**: there is a tower of additive
groups in which every stage is nontrivial yet the inverse limit is trivial. -/
theorem exists_nontrivial_stages_trivial_invLimit :
    ∃ (Y : ℕ → Type) (_ : ∀ n, AddGroup (Y n)) (π : ∀ n, Y (n + 1) →+ Y n),
      (∀ n, Nontrivial (Y n)) ∧ invLimit π = ⊥ := by
  refine ⟨fun _ => ZMod 2, inferInstance, zeroTower, ?_, zeroTower_invLimit_eq_bot⟩
  intro n; infer_instance

/-! ## Surjective towers do not collapse -/

/-
**Mittag-Leffler for `ℕ`-towers.**  If every connecting map is surjective,
then the projection of the inverse limit onto the bottom stage is surjective:
the mega-object surjects onto stage `0`.
-/
theorem proj_zero_surjective_of_surjective [∀ n, AddGroup (X n)]
    (π : ∀ n, X (n + 1) →+ X n) (hπ : ∀ n, Function.Surjective (π n)) :
    Function.Surjective (proj π 0) := by
  intro a
  obtain ⟨x, hx⟩ : ∃ x : ∀ n, X n, (x 0 = a) ∧ (∀ n, (π n) (x (n + 1)) = x n) := by
    exact ⟨ fun n => Nat.recOn n a fun n ih => Function.surjInv ( hπ n ) ih, rfl, fun n => Function.surjInv_eq ( hπ n ) _ ⟩;
  exact ⟨ ⟨ x, hx.2 ⟩, hx.1 ⟩

end MegaSphereDeep