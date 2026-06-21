/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The "chain" semiring on `Fin (n+1)`

For a finite chain `Fin (n+1)` (a totally ordered finite set) we equip the carrier
with the *semiring* structure obtained from the lattice operations:

* addition is `max` (the join `⊔`), with additive identity the bottom element `0 = ⊥`;
* multiplication is `min` (the meet `⊓`), with multiplicative identity the top
  element `1 = ⊤ = Fin.last n`.

This is the standard fact that a bounded distributive lattice is an (idempotent,
commutative) semiring.  Every algebraic axiom below is proved using **only order
properties** of the linear order on `Fin (n+1)` (`max_assoc`, `min_comm`,
`max_min_distrib_left`, `bot_le`, `le_top`, …).  No `Semiring`/`CommSemiring`
instance is used in proving the individual order facts, so there is no circular
reasoning: the lemmas in §1–§5 are independent order results, and the bundled
`finChainCommSemiring` instance in §7 is *assembled from* them.

## Main results

* `FinChain.max_assoc'`, `FinChain.max_comm'`, `FinChain.min_assoc'`,
  `FinChain.min_comm'` — associativity/commutativity (§1).
* `FinChain.max_min_distrib` — distributivity `max x (min y z) = min (max x y) (max x z)` (§2).
* `FinChain.zero_is_add_id`, `FinChain.one_is_mul_id` — identities (§3).
* `FinChain.max_idem`, `FinChain.min_idem` — idempotence (§4).
* `FinChain.max_absorb`, `FinChain.min_absorb` — absorption (§5).
* `FinChain.top_no_add_inverse` — the top element has no additive inverse when `n ≥ 1` (§6).
* `FinChain.finChainCommSemiring` — the assembled commutative semiring structure (§7).
-/

namespace FinChain

variable {n : ℕ}

/-! ## §1 Associativity and commutativity (pure order facts) -/

/-- Additive (`max`) associativity. -/
theorem max_assoc' (x y z : Fin (n + 1)) : max (max x y) z = max x (max y z) :=
  max_assoc x y z

/-- Additive (`max`) commutativity. -/
theorem max_comm' (x y : Fin (n + 1)) : max x y = max y x :=
  max_comm x y

/-- Multiplicative (`min`) associativity. -/
theorem min_assoc' (x y z : Fin (n + 1)) : min (min x y) z = min x (min y z) :=
  min_assoc x y z

/-- Multiplicative (`min`) commutativity. -/
theorem min_comm' (x y : Fin (n + 1)) : min x y = min y x :=
  min_comm x y

/-! ## §2 Distributivity -/

/-- `max` distributes over `min` (the distributive-lattice law); this is the law
that makes addition distribute over multiplication in the chain semiring. -/
theorem max_min_distrib (x y z : Fin (n + 1)) :
    max x (min y z) = min (max x y) (max x z) :=
  max_min_distrib_left x y z

/-- The companion law: `min` distributes over `max`.  This is the
left-distributivity `a * (b + c) = a * b + a * c` of the chain semiring. -/
theorem min_max_distrib (x y z : Fin (n + 1)) :
    min x (max y z) = max (min x y) (min x z) :=
  min_max_distrib_left x y z

/-! ## §3 Identities: `0 = ⊥` for `max`, `1 = ⊤` for `min` -/

/-- The bottom element `0 = ⊥` is the (left) identity for `max` (additive identity). -/
theorem zero_is_add_id (x : Fin (n + 1)) : max (0 : Fin (n + 1)) x = x :=
  max_eq_right (Fin.zero_le x)

/-- The bottom element `0 = ⊥` is also a right identity for `max`. -/
theorem add_id_zero (x : Fin (n + 1)) : max x (0 : Fin (n + 1)) = x :=
  max_eq_left (Fin.zero_le x)

/-- The top element `1 = ⊤ = Fin.last n` is the (left) identity for `min`
(multiplicative identity). -/
theorem one_is_mul_id (x : Fin (n + 1)) : min (⊤ : Fin (n + 1)) x = x :=
  min_eq_right le_top

/-- The top element `1 = ⊤` is also a right identity for `min`. -/
theorem mul_id_one (x : Fin (n + 1)) : min x (⊤ : Fin (n + 1)) = x :=
  min_eq_left le_top

/-! ## §4 Idempotence -/

/-- `max` is idempotent. -/
theorem max_idem (x : Fin (n + 1)) : max x x = x :=
  max_self x

/-- `min` is idempotent. -/
theorem min_idem (x : Fin (n + 1)) : min x x = x :=
  min_self x

/-! ## §5 Absorption -/

/-- Absorption law `max x (min x y) = x`. -/
theorem max_absorb (x y : Fin (n + 1)) : max x (min x y) = x :=
  sup_inf_self

/-- Absorption law `min x (max x y) = x`. -/
theorem min_absorb (x y : Fin (n + 1)) : min x (max x y) = x :=
  inf_sup_self

/-! ## §6 The top element has no additive inverse -/

/-- When `n ≥ 1` the chain has at least two elements, so the top element `⊤`
(the multiplicative `1`) has **no additive inverse**: there is no `z` with
`max ⊤ z = 0`.  Indeed `max ⊤ z = ⊤ ≠ 0`. -/
theorem top_no_add_inverse (hn : 1 ≤ n) :
    ¬ ∃ z : Fin (n + 1), max (⊤ : Fin (n + 1)) z = (0 : Fin (n + 1)) := by
  rintro ⟨z, hz⟩
  rw [max_eq_left le_top] at hz
  -- now `hz : (⊤ : Fin (n+1)) = 0`, impossible since `⊤ ≠ 0` for `n ≥ 1`
  have hval : ((⊤ : Fin (n + 1)) : ℕ) = ((0 : Fin (n + 1)) : ℕ) := congrArg Fin.val hz
  rw [Fin.val_zero, show ((⊤ : Fin (n + 1)) : ℕ) = n from rfl] at hval
  omega

/-! ## §7 The assembled commutative semiring structure -/

/-- The chain `Fin (n+1)` as a commutative semiring with `add = max`, `mul = min`,
`0 = ⊥` and `1 = ⊤`.  Each field is discharged by the order facts proved above. -/
noncomputable def finChainCommSemiring : CommSemiring (Fin (n + 1)) where
  add := max
  add_assoc := max_assoc'
  zero := ⊥
  zero_add := fun a => max_eq_right bot_le
  add_zero := fun a => max_eq_left bot_le
  add_comm := max_comm'
  nsmul := fun k a => if k = 0 then ⊥ else a
  nsmul_zero := fun _ => rfl
  nsmul_succ := fun k a => by
    show (if k + 1 = 0 then (⊥ : Fin (n + 1)) else a) = max (if k = 0 then ⊥ else a) a
    rcases Nat.eq_zero_or_pos k with hk | hk
    · subst hk; simp
    · rw [if_neg (by omega), if_neg (by omega), max_self]
  mul := min
  left_distrib := min_max_distrib
  right_distrib := fun a b c => by
    show min (max a b) c = max (min a c) (min b c)
    rw [min_comm (max a b) c, min_max_distrib, min_comm c a, min_comm c b]
  zero_mul := fun a => min_eq_left bot_le
  mul_zero := fun a => min_eq_right bot_le
  mul_assoc := min_assoc'
  one := ⊤
  one_mul := fun a => min_eq_right le_top
  mul_one := fun a => min_eq_left le_top
  mul_comm := min_comm'

end FinChain