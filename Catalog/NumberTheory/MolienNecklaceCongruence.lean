import Mathlib
import Catalog.NumberTheory.MolienBurnsideD10

/-!
# The Molien/Burnside machinery as an arithmetic engine: necklace congruences

This file is the number-theoretic pay-off of the Molien/Burnside framework of
`Catalog.NumberTheory.MolienBurnsideD10`.  The bridge is the *cycle-index* identity

`|X^g| = k ^ (number of ⟨g⟩-orbits on Y)`   for `X = Coloring Y k = (Y → Fin k)`,

proved here as `D10.Coloring.fixCount_coloring`.  Feeding it into the Burnside divisibility
`|G| ∣ ∑_{g ∈ G} |X^g|` for the rotation action of `ℤ/n` on itself yields the classical
**necklace congruence**

`n ∣ ∑_{a ∈ ℤ/n} k ^ gcd(n, a)`,

and, specialising to a prime, **Fermat's little theorem** `k^p ≡ k (mod p)`.  Thus the
Molien invariant, which the Klein four-group example of the companion file shows to be a
*strictly coarser* invariant than the Burnside mark vector, is nevertheless strong enough
to carry genuine arithmetic content.
-/

namespace D10

open Finset MulAction

/-- The set of `k`-colourings of `Y`.  This is a type synonym for `Y → Fin k`, introduced so
that we may equip it with the *permutation* action of a group acting on `Y` (rather than the
pointwise action on the values). -/
def Coloring (Y : Type*) (k : ℕ) : Type _ := Y → Fin k

namespace Coloring

variable {G Y : Type*} [Group G] [MulAction G Y] {k : ℕ}

instance [Fintype Y] [DecidableEq Y] : Fintype (Coloring Y k) :=
  inferInstanceAs (Fintype (Y → Fin k))

instance [Fintype Y] [DecidableEq Y] : DecidableEq (Coloring Y k) :=
  inferInstanceAs (DecidableEq (Y → Fin k))

instance : SMul G (Coloring Y k) := ⟨fun g f => (fun y => f (g⁻¹ • y) : Y → Fin k)⟩

theorem smul_apply (g : G) (f : Coloring Y k) (y : Y) :
    (g • f : Coloring Y k) y = f (g⁻¹ • y) := rfl

instance : MulAction G (Coloring Y k) where
  one_smul f := by funext y; rw [smul_apply, inv_one, one_smul]
  mul_smul g h f := by
    funext y
    rw [smul_apply, smul_apply, smul_apply, mul_inv_rev, mul_smul]

theorem smul_eq_self_iff (g : G) (f : Coloring Y k) :
    g • f = f ↔ ∀ y : Y, f (g • y) = f y := by
  constructor
  · intro h y
    have hy := congrFun (a := g • y) h
    rw [smul_apply, inv_smul_smul] at hy
    exact hy.symm
  · intro h
    funext y
    rw [smul_apply]
    have hy := h (g⁻¹ • y)
    rw [smul_inv_smul] at hy
    exact hy.symm

/-- The colourings fixed by `g` are exactly the functions on the set of `⟨g⟩`-orbits. -/
def fixedEquivOrbitFun (g : G) :
    {f : Coloring Y k // g • f = f} ≃
      (Quotient (MulAction.orbitRel (Subgroup.zpowers g) Y) → Fin k) where
  toFun f := Quotient.lift (fun y => (f.1 : Y → Fin k) y) (by
    rintro a b ⟨s, hs⟩
    have hg : g ∈ MulAction.stabilizer G f.1 := f.2
    have hsb : (s : G) ∈ MulAction.stabilizer G f.1 := (Subgroup.zpowers_le.mpr hg) s.2
    have hval := (smul_eq_self_iff (s : G) f.1).mp hsb b
    simp only at hs
    rw [← hs]
    exact hval)
  invFun h := ⟨(fun y => h (Quotient.mk _ y) : Y → Fin k), by
    rw [smul_eq_self_iff]
    intro y
    exact congrArg h (Quotient.sound ⟨⟨g, Subgroup.mem_zpowers g⟩, rfl⟩)⟩
  left_inv f := by ext; rfl
  right_inv h := by funext q; induction q using Quotient.inductionOn; rfl

/-- **Cycle-index identity.**  The permutation character of the colouring representation is
`k` to the power of the number of cycles (`⟨g⟩`-orbits) of `g`. -/
theorem fixCount_coloring [Fintype Y] [DecidableEq Y] (g : G) :
    fixCount (Coloring Y k) g
      = k ^ Nat.card (Quotient (MulAction.orbitRel (Subgroup.zpowers g) Y)) := by
  classical
  rw [fixCount, ← Fintype.card_subtype, Fintype.card_congr (fixedEquivOrbitFun (k := k) g)]
  simp [Nat.card_eq_fintype_card]

/-- **A Frobenius-type congruence for arbitrary finite group actions.**  For any action of a
finite group `G` on a finite set `Y` and any number of colours `k`,
`|G|` divides `∑_{g ∈ G} k ^ c(g)`, where `c(g)` is the number of cycles of `g` on `Y`.
The necklace congruence below is the case of `ℤ/n` acting on itself. -/
theorem card_dvd_sum_pow_cycles {G Y : Type*} [Group G] [Fintype G] [MulAction G Y]
    [Fintype Y] [DecidableEq Y] (k : ℕ) :
    Fintype.card G ∣
      ∑ g : G, k ^ Nat.card (Quotient (MulAction.orbitRel (Subgroup.zpowers g) Y)) := by
  classical
  have := card_group_dvd_sum_fixCount (G := G) (X := Coloring Y k)
  simpa only [Coloring.fixCount_coloring] using this

end Coloring

section Rotation

variable {n : ℕ} [NeZero n]

/-- The rotation group `ℤ/n`, written multiplicatively, acting on `ℤ/n` by translation. -/
abbrev Rot (n : ℕ) := Multiplicative (ZMod n)

theorem fixCount_translation (g : Rot n) :
    fixCount (ZMod n) g = if g = 1 then n else 0 := by
  by_cases hg : g = 1
  · subst hg
    simp [fixCount, ZMod.card]
  · have hne : Multiplicative.toAdd g ≠ 0 := fun h => hg (by simpa using h)
    rw [if_neg hg, fixCount, Finset.card_eq_zero, Finset.filter_eq_empty_iff]
    intro y _ hy
    apply hne
    have : Multiplicative.toAdd g + y = y := hy
    linear_combination (norm := abel) this

/-- The rotation action of a cyclic subgroup on `ℤ/n` is free, so the number of orbits times
the order of the subgroup is `n`. -/
theorem card_orbits_mul_card_zpowers (g : Rot n) :
    Nat.card (Quotient (MulAction.orbitRel (Subgroup.zpowers g) (ZMod n)))
        * Nat.card (Subgroup.zpowers g) = n := by
  classical
  have hsum := sum_fixCount_eq_card_orbits_mul (X := ZMod n) (Subgroup.zpowers g)
  have hterm : ∀ s : Subgroup.zpowers g,
      fixCount (ZMod n) (s : Rot n) = if s = (1 : Subgroup.zpowers g) then n else 0 := by
    intro s
    have hiff : ((s : Rot n) = 1) ↔ (s = 1) :=
      ⟨fun h => Subtype.ext h, fun h => by rw [h]; rfl⟩
    rw [fixCount_translation]
    simp only [hiff]
  have hval : (∑ s : Subgroup.zpowers g, fixCount (ZMod n) (s : Rot n)) = n := by
    simp only [hterm]
    rw [Finset.sum_ite_eq' Finset.univ (1 : Subgroup.zpowers g) (fun _ => n)]
    rw [if_pos (Finset.mem_univ _)]
  rw [hval] at hsum
  rw [Nat.card_eq_fintype_card (α := (Subgroup.zpowers g : Subgroup (Rot n)))]
  exact hsum.symm

/-- The number of cycles of the rotation by `a` on `ℤ/n` is `gcd n a`. -/
theorem card_orbits_rotation (a : ZMod n) :
    Nat.card (Quotient (MulAction.orbitRel
      (Subgroup.zpowers (Multiplicative.ofAdd a)) (ZMod n))) = Nat.gcd n a.val := by
  have hn : n ≠ 0 := NeZero.ne n
  have hord : Nat.card (Subgroup.zpowers (Multiplicative.ofAdd a)) = n / Nat.gcd n a.val := by
    rw [Nat.card_zpowers, orderOf_ofAdd_eq_addOrderOf]
    conv_lhs => rw [show a = ((a.val : ℕ) : ZMod n) from (ZMod.natCast_rightInverse a).symm]
    exact ZMod.addOrderOf_coe a.val hn
  have hdvd : Nat.gcd n a.val ∣ n := Nat.gcd_dvd_left _ _
  have hkey := card_orbits_mul_card_zpowers (Multiplicative.ofAdd a)
  rw [hord] at hkey
  have hpos : 0 < n / Nat.gcd n a.val := Nat.div_pos (Nat.le_of_dvd (Nat.pos_of_ne_zero hn) hdvd)
    (Nat.pos_of_ne_zero (fun h => hn (Nat.eq_zero_of_gcd_eq_zero_left h)))
  have h2 : n / (n / Nat.gcd n a.val)
      = Nat.card (Quotient (MulAction.orbitRel
          (Subgroup.zpowers (Multiplicative.ofAdd a)) (ZMod n))) :=
    Nat.div_eq_of_eq_mul_left hpos hkey.symm
  rw [← h2, Nat.div_div_self hdvd hn]

/-- **Necklace character formula**: the rotation by `a` fixes exactly `k ^ gcd(n, a)` of the
`k`-colourings of `ℤ/n`. -/
theorem fixCount_necklace (k : ℕ) (a : ZMod n) :
    fixCount (Coloring (ZMod n) k) (Multiplicative.ofAdd a) = k ^ Nat.gcd n a.val := by
  rw [Coloring.fixCount_coloring, card_orbits_rotation]

/-- **Necklace congruence** (a Gauss-type congruence): for every `n ≥ 1` and every number of
colours `k`, `n` divides `∑_{a ∈ ℤ/n} k ^ gcd(n, a)`. -/
theorem necklace_congruence (k : ℕ) :
    n ∣ ∑ a : ZMod n, k ^ Nat.gcd n a.val := by
  classical
  have hdvd := card_group_dvd_sum_fixCount (G := Rot n) (X := Coloring (ZMod n) k)
  have hcard : Fintype.card (Rot n) = n := by
    rw [Fintype.card_eq_nat_card, Nat.card_congr (Multiplicative.toAdd (α := ZMod n)),
      Nat.card_eq_fintype_card, ZMod.card]
  rw [hcard] at hdvd
  have hre : (∑ g : Rot n, fixCount (Coloring (ZMod n) k) g)
      = ∑ a : ZMod n, k ^ Nat.gcd n a.val := by
    refine Fintype.sum_equiv (Multiplicative.toAdd (α := ZMod n)) _ _ ?_
    intro x
    exact fixCount_necklace k (Multiplicative.toAdd x)
  rwa [hre] at hdvd

end Rotation

section Fermat

/-- The necklace sum for a prime modulus splits as `k^p + (p-1)·k`. -/
theorem sum_gcd_prime (p k : ℕ) [NeZero p] (hp : p.Prime) :
    (∑ a : ZMod p, k ^ Nat.gcd p a.val) = (p - 1) * k + k ^ p := by
  classical
  rw [← Finset.sum_erase_add Finset.univ _ (Finset.mem_univ (0 : ZMod p))]
  have hzero : k ^ Nat.gcd p (ZMod.val (0 : ZMod p)) = k ^ p := by
    rw [ZMod.val_zero, Nat.gcd_zero_right]
  have hother : ∀ a ∈ (Finset.univ.erase (0 : ZMod p)),
      k ^ Nat.gcd p a.val = k := by
    intro a ha
    rw [Finset.mem_erase] at ha
    have hval : a.val ≠ 0 := by
      intro h
      apply ha.1
      have hc := ZMod.natCast_rightInverse (n := p) a
      rw [h] at hc
      simpa using hc.symm
    have hlt : a.val < p := ZMod.val_lt a
    have : Nat.gcd p a.val = 1 := by
      rcases (Nat.coprime_or_dvd_of_prime hp a.val) with h | h
      · exact h
      · exact absurd (Nat.le_of_dvd (Nat.pos_of_ne_zero hval) h) (not_le.mpr hlt)
    rw [this, pow_one]
  rw [Finset.sum_congr rfl hother, hzero, Finset.sum_const, smul_eq_mul,
    Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, ZMod.card]

/-- **Fermat's little theorem, proved through the Molien/Burnside machinery.**  Counting
`k`-coloured necklaces of prime length `p` gives `k^p ≡ k (mod p)`. -/
theorem fermat_little_of_burnside (p k : ℕ) (hp : p.Prime) :
    (p : ℤ) ∣ (k : ℤ) ^ p - (k : ℤ) := by
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hdvd := necklace_congruence (n := p) k
  rw [sum_gcd_prime p k hp] at hdvd
  have hz : (p : ℤ) ∣ ((p - 1) * k + k ^ p : ℕ) := Int.natCast_dvd_natCast.mpr hdvd
  have hp1 : (1 : ℕ) ≤ p := hp.one_lt.le
  rw [Nat.cast_add, Nat.cast_mul, Nat.cast_sub hp1, Nat.cast_pow] at hz
  have : ((p : ℤ) - 1) * k + (k : ℤ) ^ p = (k : ℤ) ^ p - k + p * k := by ring
  rw [Nat.cast_one, this] at hz
  exact (dvd_add_right (Dvd.intro _ rfl)).mp (by rwa [add_comm] at hz)

/-- The same statement in `Nat.ModEq` form. -/
theorem fermat_little_modEq (p k : ℕ) (hp : p.Prime) : k ^ p ≡ k [MOD p] := by
  have h := fermat_little_of_burnside p k hp
  have hk : k ≤ k ^ p := Nat.le_self_pow hp.ne_zero k
  refine Nat.ModEq.symm ((Nat.modEq_iff_dvd' hk).mpr ?_)
  have hz : (p : ℤ) ∣ ((k ^ p - k : ℕ) : ℤ) := by
    rwa [Nat.cast_sub hk, Nat.cast_pow]
  exact_mod_cast hz

end Fermat

end D10