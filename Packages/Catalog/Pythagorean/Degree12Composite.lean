/-
# Degree-12 composite rung: the arithmetic of `Q(ζ₅₆)⁺`

This file formalises the *group-theoretic core* of the "degree 12, conductor 56"
rung of the abelian ladder.  The real cyclotomic field `Q(ζ₅₆)⁺` has degree
`φ(56)/2 = 12` over `ℚ` and Galois group

  `G⁺ = (ZMod 56)ˣ / {±1}`,

which is the *first non-cyclic, composite-order* group in the ladder:
`G⁺ ≅ C₆ × C₂`.

Everything here is proved about explicit, finite, decidable objects:

* `Units56`   — the 24 reduced residues mod 56, characterised as `{a | a ^ 6 = 1}`
                (equivalently: the units, equivalently: the classes coprime to 56);
* `resDeg a`  — the *type* (residue degree) of a residue: the least `k ≥ 1`
                with `a ^ k = ±1`, i.e. the order of the class of `a` in `G⁺`;
* `cls`       — an explicit splitting `C₆ × C₂ → (ZMod 56)ˣ`, `(i,j) ↦ 3^i·13^j`,
                which together with `-1` gives a basis of `(ZMod 56)ˣ`.

The main results are

* `basisMap_bijective`, `image_basisMap` : `(ZMod 56)ˣ ≅ C₆ × C₂ × C₂` with the
  last factor being exactly `{±1}` — hence `G⁺ ≅ C₆ × C₂`;
* `addOrderOf_eq_resDeg_cls` : the type `resDeg` computes the order of the
  corresponding element of `C₆ × C₂` (Frobenius order = residue degree);
* `not_isAddCyclic` : `G⁺` is **not** cyclic (exponent 6 < 12);
* `card_type_*` : the four type counts `2, 6, 4, 12` out of 24, i.e. densities
  `1/12, 1/4, 1/6, 1/2`, and `chebotarev_match`, which identifies these densities
  with the element-order statistics of `C₆ × C₂`;
* `resDeg_natCast_congr` : the type of a prime depends **only** on `p mod 56`
  (this is the "full pinning" hypothesis exploited information-theoretically in
  `Pythagorean.Degree12CompositeEntropy`).
-/
import Mathlib

set_option maxRecDepth 40000

namespace Catalog.Pythagorean.Degree12Composite

open Finset

/-! ## The reduced residues mod 56 -/

/-- The reduced residue classes mod `56`, presented by the equation `a ^ 6 = 1`.
(`(ZMod 56)ˣ ≅ C₂ × C₂ × C₆` has exponent 6, so this really is the unit group.) -/
def Units56 : Finset (ZMod 56) := Finset.univ.filter (fun a => a ^ 6 = 1)

@[simp] lemma mem_Units56 {a : ZMod 56} : a ∈ Units56 ↔ a ^ 6 = 1 := by
  simp [Units56]

/-- There are `φ(56) = 24` reduced residues. -/
theorem card_Units56 : Units56.card = 24 := by decide

theorem totient_56 : Nat.totient 56 = 24 := by decide

/-- Membership in `Units56` is exactly invertibility mod 56. -/
theorem mem_Units56_iff_isUnit {a : ZMod 56} : a ∈ Units56 ↔ IsUnit a := by
  constructor
  · intro ha
    rw [mem_Units56] at ha
    have h6 : a * a ^ 5 = 1 := by
      have : a * a ^ 5 = a ^ 6 := by ring
      rw [this]; exact ha
    exact IsUnit.of_mul_eq_one (a ^ 5) h6
  · intro ha
    obtain ⟨b, hb⟩ := ha.exists_right_inv
    have key : ∀ a : ZMod 56, (∃ b, a * b = 1) → a ^ 6 = 1 := by decide
    exact mem_Units56.2 (key a ⟨b, hb⟩)

/-- Membership in `Units56` is exactly coprimality to 56. -/
theorem mem_Units56_iff_coprime {a : ZMod 56} : a ∈ Units56 ↔ Nat.Coprime a.val 56 := by
  have key : ∀ a : ZMod 56, a ^ 6 = 1 ↔ Nat.Coprime a.val 56 := by decide
  simpa [mem_Units56] using key a

/-- A prime different from the ramified primes `2, 7` gives a reduced residue mod 56. -/
theorem mem_Units56_of_prime {p : ℕ} (hp : p.Prime) (h2 : p ≠ 2) (h7 : p ≠ 7) :
    (p : ZMod 56) ∈ Units56 := by
  rw [mem_Units56_iff_isUnit, ZMod.isUnit_iff_coprime]
  rw [Nat.coprime_comm, Nat.Coprime]
  rcases Nat.coprime_or_dvd_of_prime hp 56 with h | h
  · rwa [Nat.coprime_comm] at h
  · exfalso
    have hle : p ≤ 56 := Nat.le_of_dvd (by norm_num) h
    have hp2 := hp.two_le
    interval_cases p <;> simp_all (config := { decide := true })

/-! ## The type (residue degree) map -/

/-- The **type** of a residue class mod 56: the least `k ≥ 1` with `a ^ k = ±1`.
For a prime `p ∤ 56` this is the residue degree of `p` in `Q(ζ₅₆)⁺`, i.e. the order
of the Frobenius class of `p` in `G⁺ = (ZMod 56)ˣ/{±1}`. -/
def resDeg (a : ZMod 56) : ℕ :=
  if a = 1 ∨ a = -1 then 1
  else if a ^ 2 = 1 ∨ a ^ 2 = -1 then 2
  else if a ^ 3 = 1 ∨ a ^ 3 = -1 then 3
  else if a ^ 6 = 1 ∨ a ^ 6 = -1 then 6
  else 0

/-- `resDeg` really is the minimal `k ≥ 1` with `a ^ k = ±1`. -/
theorem resDeg_spec :
    ∀ a ∈ Units56, (a ^ resDeg a = 1 ∨ a ^ resDeg a = -1) ∧
      ∀ k < resDeg a, 0 < k → ¬ (a ^ k = 1 ∨ a ^ k = -1) := by decide

/-- Only the four divisors `1, 2, 3, 6` of `|G⁺| / 2 = 6` occur as types. -/
theorem resDeg_mem_types : ∀ a ∈ Units56, resDeg a ∈ ({1, 2, 3, 6} : Finset ℕ) := by decide

/-- The type is a class function for the `±` identification: `p` and `-p` have the
same type (this is what makes `resDeg` descend to `G⁺`). -/
theorem resDeg_neg : ∀ a ∈ Units56, resDeg (-a) = resDeg a := by decide

/-- Every reduced residue satisfies `a ^ 6 = 1`: the unit group has exponent 6. -/
theorem pow_six_eq_one {a : ZMod 56} (ha : a ∈ Units56) : a ^ 6 = 1 := mem_Units56.1 ha

/-- The type of a natural number depends only on its class mod 56 — the exact
"full pinning" statement `H(T | p mod 56) = 0`. -/
theorem resDeg_natCast_congr {p q : ℕ} (h : p ≡ q [MOD 56]) :
    resDeg (p : ZMod 56) = resDeg (q : ZMod 56) := by
  rw [(ZMod.natCast_eq_natCast_iff p q 56).2 h]

/-! ## Structure of the unit group: `C₆ × C₂ × C₂` -/

/-- The explicit basis map `(i, j, k) ↦ 3^i · 13^j · (-1)^k`. -/
def basisMap (t : ZMod 6 × ZMod 2 × ZMod 2) : ZMod 56 :=
  3 ^ t.1.val * 13 ^ t.2.1.val * (-1) ^ t.2.2.val

/-- The basis map is injective. -/
theorem basisMap_injective : Function.Injective basisMap := by decide

/-- The basis map hits exactly the 24 reduced residues:
`(ZMod 56)ˣ ≅ C₆ × C₂ × C₂` with the third factor `{±1}`. -/
theorem image_basisMap : Finset.image basisMap Finset.univ = Units56 := by decide

/-- The `C₆ × C₂` part of the basis: `cls (i, j) = 3^i · 13^j`. -/
def cls (g : ZMod 6 × ZMod 2) : ZMod 56 := 3 ^ g.1.val * 13 ^ g.2.val

/-- `cls` is a group homomorphism `(C₆ × C₂, +) → ((ZMod 56)ˣ, ·)`. -/
theorem cls_add : ∀ g h : ZMod 6 × ZMod 2, cls (g + h) = cls g * cls h := by decide

theorem cls_zero : cls 0 = 1 := by decide

theorem cls_mem : ∀ g : ZMod 6 × ZMod 2, cls g ∈ Units56 := by decide

/-- `cls` is injective *modulo signs*: the 12 classes `± cls g` are distinct, so
`G⁺ = (ZMod 56)ˣ / {±1}` has exactly 12 elements, indexed by `C₆ × C₂`. -/
theorem cls_inj_mod_sign :
    ∀ g h : ZMod 6 × ZMod 2, (cls g = cls h ∨ cls g = -cls h) → g = h := by decide

/-- Every reduced residue is `± cls g` for a unique `g` : the splitting is onto. -/
theorem exists_cls : ∀ a ∈ Units56, ∃ g : ZMod 6 × ZMod 2, a = cls g ∨ a = -cls g := by decide

/-! ## Types are Frobenius orders in `C₆ × C₂` -/

private theorem resDeg_cls_spec : ∀ g : ZMod 6 × ZMod 2,
    (resDeg (cls g)) • g = 0 ∧ ∀ k < resDeg (cls g), 0 < k → k • g ≠ 0 := by decide

private theorem resDeg_cls_pos : ∀ g : ZMod 6 × ZMod 2, 0 < resDeg (cls g) := by decide

/-- **Type = Frobenius order.** For every `g ∈ C₆ × C₂`, the type of the residue
`cls g` equals the order of `g`.  Under the identification `G⁺ ≅ C₆ × C₂`, the
residue degree of a prime is exactly the order of its Frobenius class. -/
theorem addOrderOf_eq_resDeg_cls (g : ZMod 6 × ZMod 2) : addOrderOf g = resDeg (cls g) := by
  obtain ⟨h1, h2⟩ := resDeg_cls_spec g
  refine (addOrderOf_eq_iff (resDeg_cls_pos g)).2 ⟨h1, ?_⟩
  intro m hm hm0
  exact h2 m hm hm0

/-- The group `C₆ × C₂` has exponent 6. -/
theorem six_nsmul_eq_zero (g : ZMod 6 × ZMod 2) : (6 : ℕ) • g = 0 := by revert g; decide

/-- `|G⁺| = 12`: the degree of `Q(ζ₅₆)⁺`. -/
theorem card_Gplus : Nat.card (ZMod 6 × ZMod 2) = 12 := by
  simp [Nat.card_eq_fintype_card]

/-- **`G⁺` is not cyclic.**  This is the first rung of the ladder whose Galois
group is not cyclic: `C₆ × C₂` has order 12 but exponent 6. -/
theorem not_isAddCyclic : ¬ IsAddCyclic (ZMod 6 × ZMod 2) := by
  intro h
  obtain ⟨g, hg⟩ := h.exists_generator
  have hcard : Nat.card (ZMod 6 × ZMod 2) = 12 := card_Gplus
  have hord : addOrderOf g = 12 := by
    have := addOrderOf_eq_card_of_forall_mem_zmultiples hg
    rwa [hcard] at this
  have h6 : addOrderOf g ∣ 6 := addOrderOf_dvd_of_nsmul_eq_zero (six_nsmul_eq_zero g)
  rw [hord] at h6
  omega

/-! ## Type densities: the Chebotarev profile -/

/-- The number of reduced residues of a given type. -/
def typeCount (d : ℕ) : ℕ := (Units56.filter (fun a => resDeg a = d)).card

theorem typeCount_one : typeCount 1 = 2 := by decide
theorem typeCount_two : typeCount 2 = 6 := by decide
theorem typeCount_three : typeCount 3 = 4 := by decide
theorem typeCount_six : typeCount 6 = 12 := by decide

/-- The four types exhaust all 24 residues. -/
theorem typeCount_sum : typeCount 1 + typeCount 2 + typeCount 3 + typeCount 6 = 24 := by decide

/-- The set of types actually realised is `{1, 2, 3, 6}`. -/
theorem image_resDeg : Units56.image resDeg = ({1, 2, 3, 6} : Finset ℕ) := by decide

/-- The number of elements of `C₆ × C₂` of a given order. -/
def orderCount (d : ℕ) : ℕ :=
  (Finset.univ.filter (fun g : ZMod 6 × ZMod 2 => resDeg (cls g) = d)).card

/-- **Chebotarev match.**  For every `d`, the number of reduced residues of type `d`
is exactly twice the number of elements of `C₆ × C₂` of order `d`; i.e. the type
densities in `(ZMod 56)ˣ` coincide with the order densities of the Galois group
`G⁺ ≅ C₆ × C₂`.  Concretely the densities are `1/12, 1/4, 1/6, 1/2`. -/
theorem chebotarev_match (d : ℕ) : typeCount d = 2 * orderCount d := by
  have key : ∀ d < 13, typeCount d = 2 * orderCount d := by decide
  by_cases hd : d < 13
  · exact key d hd
  · have h1 : typeCount d = 0 := by
      have : ∀ a ∈ Units56, resDeg a ≤ 6 := by decide
      simp only [typeCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
      intro a ha h
      exact absurd (h ▸ this a ha) (by omega)
    have h2 : orderCount d = 0 := by
      have : ∀ g : ZMod 6 × ZMod 2, resDeg (cls g) ≤ 6 := by decide
      simp only [orderCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
      intro g _ h
      exact absurd (h ▸ this g) (by omega)
    omega

/-- Order statistics of `C₆ × C₂` written out: `1, 3, 2, 6` elements of order
`1, 2, 3, 6` — i.e. densities `1/12, 1/4, 1/6, 1/2`. -/
theorem orderCount_values :
    orderCount 1 = 1 ∧ orderCount 2 = 3 ∧ orderCount 3 = 2 ∧ orderCount 6 = 6 := by decide

end Catalog.Pythagorean.Degree12Composite