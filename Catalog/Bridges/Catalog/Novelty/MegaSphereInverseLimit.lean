import Mathlib

/-!
# The Mega-Sphere I: Inverse limits of towers

The guiding fantasy of this project is a *single algebraic object* whose
projections recover every finite stage of an infinite tower at once — the
"all dimensions at once" object.  The rigorous heart of that fantasy is the
**inverse limit** of a tower

  `⋯ → X (n+1) --π n--> X n → ⋯ → X 1 → X 0`,

the universal object equipped with compatible projections to every stage.

This file builds the inverse limit of a tower of (additive) groups and of rings
completely by hand, as a sub-object of the product, and proves:

* `MegaSphere.invLimit` / `MegaSphere.invLimitRing` — the inverse limit exists
  as a concrete subgroup / subring of `∀ n, X n`.
* `MegaSphere.proj`, `MegaSphere.proj_comp` — the projections to every stage,
  and their compatibility with the connecting maps `π`.
* `MegaSphere.univMap`, `MegaSphere.proj_univMap`, `MegaSphere.univMap_unique`
  — the **universal property**: any cone over the tower factors uniquely through
  the inverse limit.  This is the precise sense in which the mega-object "is" the
  inverse limit.

Two concrete towers illustrate the two extremes:

* `MegaSphere.constTower_invLimit_eq` — the constant tower `X n = G` (identity
  connecting maps) has inverse limit the diagonal copy of `G`.
* `MegaSphere.doublingTower_invLimit_eq_bot` — the doubling tower
  `ℤ ←×2— ℤ ←×2— ⋯` **collapses**: its inverse limit is trivial, because an
  integer divisible by every power of `2` must vanish.
* `MegaSphere.padicTower_nontrivial` — by contrast the `2`-adic tower
  `ZMod (2^(n+1))` with reduction maps has a genuinely nontrivial inverse limit
  (the `2`-adic integers), a *bona fide* mega-object.
-/

namespace MegaSphere

universe u v

variable {X : ℕ → Type u} {Y : Type v}

/-! ## Inverse limit of a tower of additive groups -/

/-- The inverse limit of a tower of additive groups `X` with connecting
homomorphisms `π n : X (n+1) →+ X n`, realised as the subgroup of coherent
sequences inside the product `∀ n, X n`. -/
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

/-- The projections are compatible with the connecting maps: applying the
connecting map `π n` to the `(n+1)`-st projection recovers the `n`-th
projection.  This is the coherence that makes the mega-object a genuine cone. -/
theorem proj_comp [∀ n, AddGroup (X n)] (π : ∀ n, X (n + 1) →+ X n) (n : ℕ)
    (x : invLimit π) : π n (proj π (n + 1) x) = proj π n x := x.2 n

/-- **Universal property (existence).**  Given any additive group `Y` with a
compatible cone `g n : Y →+ X n` (`π n ∘ g (n+1) = g n`), there is an induced
homomorphism into the inverse limit. -/
def univMap [∀ n, AddGroup (X n)] [AddGroup Y] (π : ∀ n, X (n + 1) →+ X n)
    (g : ∀ n, Y →+ X n) (hg : ∀ n, (π n).comp (g (n + 1)) = g n) :
    Y →+ invLimit π where
  toFun y := ⟨fun n => g n y, by
    intro n
    have := hg n
    rw [AddMonoidHom.ext_iff] at this
    simpa using this y⟩
  map_zero' := by ext n; simp
  map_add' := by intro a b; ext n; simp

/-- The induced map really is a factorisation of the cone through the
projections. -/
@[simp] theorem proj_univMap [∀ n, AddGroup (X n)] [AddGroup Y]
    (π : ∀ n, X (n + 1) →+ X n) (g : ∀ n, Y →+ X n)
    (hg : ∀ n, (π n).comp (g (n + 1)) = g n) (n : ℕ) (y : Y) :
    proj π n (univMap π g hg y) = g n y := rfl

/-- **Universal property (uniqueness).**  Any two homomorphisms into the inverse
limit that agree after every projection are equal. -/
theorem univMap_unique [∀ n, AddGroup (X n)] [AddGroup Y]
    (π : ∀ n, X (n + 1) →+ X n) (u v : Y →+ invLimit π)
    (h : ∀ n, (proj π n).comp u = (proj π n).comp v) : u = v := by
  ext y n
  have := h n
  rw [AddMonoidHom.ext_iff] at this
  exact this y

/-! ## Example: the constant tower recovers its base -/

/-- The constant tower `X n = G` with identity connecting maps. -/
def constTower (G : Type u) [AddGroup G] : ∀ _n : ℕ, G →+ G := fun _ => AddMonoidHom.id G

/-- The inverse limit of the constant tower is exactly the diagonal: coherent
sequences are the constant sequences. -/
theorem constTower_invLimit_eq (G : Type u) [AddGroup G] :
    (invLimit (X := fun _ => G) (constTower G)).carrier
      = {x : ℕ → G | ∀ n, x n = x 0} := by
  ext x
  constructor
  · intro hx
    -- `hx n : x (n+1) = x n`; induct to reach `x 0`.
    have step : ∀ n, x (n + 1) = x n := fun n => hx n
    intro n
    induction n with
    | zero => rfl
    | succ k ih => rw [step k, ih]
  · intro hx n
    show x (n + 1) = x n
    rw [hx (n + 1), hx n]

/-! ## Example: the doubling tower collapses -/

/-- The doubling connecting map `×2 : ℤ →+ ℤ`. -/
def dbl : ∀ _n : ℕ, ℤ →+ ℤ := fun _ => AddMonoidHom.mulLeft (2 : ℤ)

@[simp] lemma dbl_apply (n : ℕ) (a : ℤ) : dbl n a = 2 * a := rfl

/-- An integer divisible by every power of two is zero. -/
theorem int_eq_zero_of_forall_two_pow_dvd {a : ℤ} (h : ∀ n : ℕ, (2 : ℤ) ^ n ∣ a) :
    a = 0 := by
  by_contra ha
  have hpos : (0 : ℤ) < |a| := abs_pos.mpr ha
  have hdvd : (2 : ℤ) ^ a.natAbs ∣ a := h a.natAbs
  have hdvd' : (2 : ℤ) ^ a.natAbs ∣ |a| := (dvd_abs _ _).mpr hdvd
  have hle : (2 : ℤ) ^ a.natAbs ≤ |a| := Int.le_of_dvd hpos hdvd'
  have habs : |a| = (a.natAbs : ℤ) := Int.abs_eq_natAbs a
  have hlt : (a.natAbs : ℤ) < (2 : ℤ) ^ a.natAbs := by exact_mod_cast Nat.lt_two_pow_self
  rw [habs] at hle
  exact absurd (lt_of_le_of_lt hle hlt) (lt_irrefl _)

/-- **Collapse of the doubling tower.**  In a coherent sequence for the doubling
tower, every entry is `2^k` times a later entry, hence divisible by all powers of
`2`, hence zero. -/
theorem doublingTower_invLimit_eq_bot :
    invLimit (X := fun _ => ℤ) dbl = ⊥ := by
  rw [AddSubgroup.eq_bot_iff_forall]
  rintro x hx
  -- `hx m : 2 * x (m+1) = x m`.
  have hx' : ∀ m, 2 * x (m + 1) = x m := fun m => hx m
  -- For all m and k, `x m = 2^k * x (m+k)`.
  have key : ∀ m k, x m = 2 ^ k * x (m + k) := by
    intro m k
    induction k with
    | zero => simp
    | succ j ih =>
        rw [ih]
        have := hx' (m + j)
        rw [pow_succ]
        rw [mul_assoc, ← this]
        ring_nf
  -- Hence every `x m = 0`.
  funext m
  show x m = 0
  apply int_eq_zero_of_forall_two_pow_dvd
  intro k
  exact ⟨x (m + k), key m k⟩

/-! ## Inverse limit of a tower of rings, and a nontrivial mega-object -/

/-- The inverse limit of a tower of rings, as a subring of the product. -/
def invLimitRing [∀ n, Ring (X n)] (π : ∀ n, X (n + 1) →+* X n) :
    Subring (∀ n, X n) where
  carrier := {x | ∀ n, π n (x (n + 1)) = x n}
  one_mem' := by intro n; simp
  mul_mem' := by intro a b ha hb n; simp [map_mul, ha n, hb n]
  zero_mem' := by intro n; simp
  add_mem' := by intro a b ha hb n; simp [map_add, ha n, hb n]
  neg_mem' := by intro a ha n; simp [map_neg, ha n]

/-- Projection of the ring inverse limit onto stage `n`. -/
def projRing [∀ n, Ring (X n)] (π : ∀ n, X (n + 1) →+* X n) (n : ℕ) :
    invLimitRing π →+* X n :=
  (Pi.evalRingHom X n).comp (invLimitRing π).subtype

@[simp] lemma projRing_apply [∀ n, Ring (X n)] (π : ∀ n, X (n + 1) →+* X n)
    (n : ℕ) (x : invLimitRing π) : projRing π n x = (x : ∀ n, X n) n := rfl

theorem projRing_comp [∀ n, Ring (X n)] (π : ∀ n, X (n + 1) →+* X n) (n : ℕ)
    (x : invLimitRing π) : π n (projRing π (n + 1) x) = projRing π n x := x.2 n

/-- The `2`-adic tower `ZMod (2^(n+1))` with the reduction ring homomorphisms. -/
noncomputable def padicRed : ∀ n : ℕ, (ZMod (2 ^ (n + 2))) →+* (ZMod (2 ^ (n + 1))) :=
  fun n => ZMod.castHom (pow_dvd_pow 2 (Nat.le_succ _)) (ZMod (2 ^ (n + 1)))

set_option maxHeartbeats 1000000 in
/-- **A genuinely nontrivial mega-object.**  The inverse limit of the `2`-adic
tower is nontrivial: `0 ≠ 1`, as witnessed by the projection to stage `0`
(the field `ZMod 2`). -/
theorem padicTower_nontrivial :
    Nontrivial (invLimitRing (X := fun n => ZMod (2 ^ (n + 1))) padicRed) := by
  refine ⟨0, 1, ?_⟩
  intro h
  have h0 := congrArg (projRing (X := fun n => ZMod (2 ^ (n + 1))) padicRed 0) h
  rw [map_zero, map_one] at h0
  haveI : Fact (1 < 2 ^ (0 + 1)) := ⟨by norm_num⟩
  exact zero_ne_one h0

end MegaSphere