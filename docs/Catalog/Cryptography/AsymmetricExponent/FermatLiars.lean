import Cryptography.AsymmetricExponent.Core

/-!
# The Euler gap governs `a^(N-1) mod N` completely

For a semiprime `N = p*q` the Fermat exponent `N - 1` is, in each CRT
component, congruent to the *other* prime's Fermat exponent (`Core.lean`).
This file draws the consequence that the whole multiplicative behaviour of
`Q(a) = a^(N-1)` is controlled by a single number, the **Euler gap**

  `g = gcd(p-1, q-1)`.

Main results.

* `AsymmetricExponent.fermatLiar_iff_eulerGap` — for every unit `u` mod `N`,
  `u^(N-1) = 1 ↔ u^g = 1`.  The Fermat test modulo a semiprime *is* the
  `g`-th power test: nothing of `p` or `q` beyond `g` is visible.
* `AsymmetricExponent.card_fermatLiars` — there are exactly `g^2` Fermat liars
  modulo `N` (the experimentally measured "reveal density" count).
* `AsymmetricExponent.exists_fermat_witness` — consequently a semiprime with
  distinct prime factors is never a Carmichael number.
* `AsymmetricExponent.fermatLiar_density_le_half` — the liar density is at most
  `1/2`: `2 * g^2 ≤ (p-1) * (q-1)`.
* `AsymmetricExponent.card_range_pow` — the image of the `(N-1)`-power map has
  size `φ(N)/g²`, and
  `AsymmetricExponent.pow_bijective_iff_eulerGap_one` — the map is bijective iff
  `g = 1`.
* `AsymmetricExponent.liarGroupEquiv` — the liar group is isomorphic to
  `(ℤ/g) × (ℤ/g)`: its isomorphism type depends on the factorisation only
  through `g`.
-/

namespace AsymmetricExponent

open scoped Classical

/-- The **Euler gap** `g = gcd(p-1, q-1)` of a semiprime `N = p*q`. -/
def eulerGap (p q : ℕ) : ℕ := Nat.gcd (p - 1) (q - 1)

/-! ## A gcd criterion for power identities in a finite group -/

/-- In a finite group, `x^n = 1` depends on `n` only through `gcd(n, |G|)`. -/
theorem pow_eq_one_congr_gcd {G : Type*} [Group G] [Fintype G] (x : G) {n m : ℕ}
    (h : Nat.gcd n (Fintype.card G) = Nat.gcd m (Fintype.card G)) :
    x ^ n = 1 ↔ x ^ m = 1 := by
  have hcard : orderOf x ∣ Fintype.card G := orderOf_dvd_card
  constructor
  · intro hx
    have hdvd : orderOf x ∣ Nat.gcd n (Fintype.card G) :=
      Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one hx) hcard
    rw [h] at hdvd
    exact orderOf_dvd_iff_pow_eq_one.mp (hdvd.trans (Nat.gcd_dvd_left _ _))
  · intro hx
    have hdvd : orderOf x ∣ Nat.gcd m (Fintype.card G) :=
      Nat.dvd_gcd (orderOf_dvd_of_pow_eq_one hx) hcard
    rw [← h] at hdvd
    exact orderOf_dvd_iff_pow_eq_one.mp (hdvd.trans (Nat.gcd_dvd_left _ _))

/-! ## Component-wise description of the Fermat test -/

variable {p q : ℕ}

/-- The CRT isomorphism on unit groups. -/
noncomputable def crtUnits (h : Nat.Coprime p q) :
    (ZMod (p * q))ˣ ≃* (ZMod p)ˣ × (ZMod q)ˣ :=
  (Units.mapEquiv (ZMod.chineseRemainder h).toMulEquiv).trans MulEquiv.prodUnits

theorem pow_eq_one_iff_components (h : Nat.Coprime p q) (u : (ZMod (p * q))ˣ)
    (n : ℕ) :
    u ^ n = 1 ↔ ((crtUnits h u).1 ^ n = 1 ∧ (crtUnits h u).2 ^ n = 1) := by
  constructor
  · intro hu
    have : (crtUnits h) (u ^ n) = 1 := by rw [hu, map_one]
    rw [map_pow] at this
    constructor
    · exact congrArg Prod.fst this
    · exact congrArg Prod.snd this
  · rintro ⟨h1, h2⟩
    have : (crtUnits h) (u ^ n) = 1 := by
      rw [map_pow]
      exact Prod.ext h1 h2
    simpa using (MulEquiv.map_eq_one_iff (crtUnits h)).mp this

/-- **Modulo `p`, the Fermat test for `N` is the `g`-th power test.** -/
theorem component_left_iff [Fact p.Prime] (hq : 0 < q) (x : (ZMod p)ˣ) :
    x ^ (p * q - 1) = 1 ↔ x ^ eulerGap p q = 1 := by
  have hp : p.Prime := Fact.out
  refine pow_eq_one_congr_gcd x ?_
  rw [ZMod.card_units p, gcd_exp_left hp.pos hq, eulerGap, Nat.gcd_comm (q - 1) (p - 1)]
  exact (Nat.gcd_eq_left (Nat.gcd_dvd_left _ _)).symm

/-- **Modulo `q`, the Fermat test for `N` is the `g`-th power test.** -/
theorem component_right_iff [Fact q.Prime] (hp : 0 < p) (y : (ZMod q)ˣ) :
    y ^ (p * q - 1) = 1 ↔ y ^ eulerGap p q = 1 := by
  have hq : q.Prime := Fact.out
  refine pow_eq_one_congr_gcd y ?_
  rw [ZMod.card_units q, gcd_exp_right hp hq.pos, eulerGap]
  exact (Nat.gcd_eq_left (Nat.gcd_dvd_right _ _)).symm

/-- **The Fermat test modulo a semiprime is exactly the Euler-gap test.**
For every unit `u` modulo `N = p*q`,

  `u^(N-1) = 1  ↔  u^{gcd(p-1,q-1)} = 1`.

All the factor dependence of the exponent `N-1` collapses onto the single
number `g = gcd(p-1, q-1)`. -/
theorem fermatLiar_iff_eulerGap [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q)
    (u : (ZMod (p * q))ˣ) :
    u ^ (p * q - 1) = 1 ↔ u ^ eulerGap p q = 1 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  rw [pow_eq_one_iff_components hcop u (p * q - 1),
      pow_eq_one_iff_components hcop u (eulerGap p q),
      component_left_iff hq.pos, component_right_iff hp.pos]

/-! ## Counting the liars -/

theorem card_pow_eq_one_units (r : ℕ) [Fact r.Prime] (n : ℕ) :
    Nat.card {x : (ZMod r)ˣ // x ^ n = 1} = Nat.gcd (r - 1) n := by
  have hcard : Nat.card (ZMod r)ˣ = r - 1 := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units r]
  have h := IsCyclic.card_powMonoidHom_ker (ZMod r)ˣ n
  rw [hcard] at h
  rw [← h]
  exact Nat.card_congr (Equiv.subtypeEquivRight (fun x => by simp [MonoidHom.mem_ker])).symm

/-- **Exactly `g^2` Fermat liars.** The number of units `u` modulo `N = p*q`
with `u^(N-1) = 1` is `g^2`, `g = gcd(p-1, q-1)`. -/
theorem card_fermatLiars [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    Nat.card {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} = (eulerGap p q) ^ 2 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  have e1 : {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} ≃
      {v : (ZMod p)ˣ × (ZMod q)ˣ // v.1 ^ (p * q - 1) = 1 ∧ v.2 ^ (p * q - 1) = 1} := by
    refine (Equiv.subtypeEquivRight (fun u => pow_eq_one_iff_components hcop u _)).trans ?_
    exact (crtUnits hcop).toEquiv.subtypeEquiv (fun u => Iff.rfl)
  have e2 := e1.trans (Equiv.subtypeProdEquivProd
    (p := fun x : (ZMod p)ˣ => x ^ (p * q - 1) = 1)
    (q := fun y : (ZMod q)ˣ => y ^ (p * q - 1) = 1))
  rw [Nat.card_congr e2, Nat.card_prod, card_pow_eq_one_units p, card_pow_eq_one_units q,
      Nat.gcd_comm (p - 1) (p * q - 1), Nat.gcd_comm (q - 1) (p * q - 1),
      gcd_exp_left hp.pos hq.pos, gcd_exp_right hp.pos hq.pos, eulerGap,
      Nat.gcd_comm (q - 1) (p - 1), sq]

/-- The liar subgroup, as a subgroup, also has cardinality `g²`. -/
theorem card_liarSubgroup [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    Nat.card ((powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).ker)
      = (eulerGap p q) ^ 2 := by
  rw [← card_fermatLiars hpq]
  exact Nat.card_congr (Equiv.subtypeEquivRight (fun u => by simp [MonoidHom.mem_ker]))

/-! ## Consequences -/

/-- The Euler gap is strictly smaller than one of the two Fermat exponents. -/
theorem eulerGap_lt (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    2 * (eulerGap p q) ^ 2 ≤ (p - 1) * (q - 1) := by
  have hg1 : eulerGap p q ∣ p - 1 := Nat.gcd_dvd_left _ _
  have hg2 : eulerGap p q ∣ q - 1 := Nat.gcd_dvd_right _ _
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hgpos : 0 < eulerGap p q := Nat.gcd_pos_of_pos_left _ (by omega)
  -- in the smaller-prime direction `g ≤ min (p-1) (q-1)`; in the larger one `2g ≤ max`
  rcases lt_or_gt_of_ne hpq with h | h
  · have hle : eulerGap p q ≤ p - 1 := Nat.le_of_dvd (by omega) hg1
    have hne : eulerGap p q ≠ q - 1 := by
      intro hEq
      have : q - 1 ≤ p - 1 := hEq ▸ hle
      omega
    have hlt : eulerGap p q < q - 1 := lt_of_le_of_ne (Nat.le_of_dvd (by omega) hg2) hne
    have h2g : 2 * eulerGap p q ≤ q - 1 := by
      obtain ⟨c, hc⟩ := hg2
      have hc2 : 2 ≤ c := by
        rcases Nat.lt_or_ge c 2 with hc1 | hc1
        · interval_cases c <;> omega
        · exact hc1
      calc 2 * eulerGap p q ≤ c * eulerGap p q := Nat.mul_le_mul_right _ hc2
        _ = q - 1 := by rw [hc]; ring
    calc 2 * (eulerGap p q) ^ 2 = (2 * eulerGap p q) * eulerGap p q := by ring
      _ ≤ (q - 1) * (p - 1) := Nat.mul_le_mul h2g hle
      _ = (p - 1) * (q - 1) := Nat.mul_comm _ _
  · have hle : eulerGap p q ≤ q - 1 := Nat.le_of_dvd (by omega) hg2
    have hne : eulerGap p q ≠ p - 1 := by
      intro hEq
      have : p - 1 ≤ q - 1 := hEq ▸ hle
      omega
    have h2g : 2 * eulerGap p q ≤ p - 1 := by
      obtain ⟨c, hc⟩ := hg1
      have hc2 : 2 ≤ c := by
        rcases Nat.lt_or_ge c 2 with hc1 | hc1
        · interval_cases c <;> omega
        · exact hc1
      calc 2 * eulerGap p q ≤ c * eulerGap p q := Nat.mul_le_mul_right _ hc2
        _ = p - 1 := by rw [hc]; ring
    calc 2 * (eulerGap p q) ^ 2 = (2 * eulerGap p q) * eulerGap p q := by ring
      _ ≤ (p - 1) * (q - 1) := Nat.mul_le_mul h2g hle

theorem card_units_semiprime (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    Nat.card (ZMod (p * q))ˣ = (p - 1) * (q - 1) := by
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.pos.ne' hq.pos.ne'⟩
  rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient, Nat.totient_mul hcop,
      Nat.totient_prime hp, Nat.totient_prime hq]

/-- **At most half of the residues are Fermat liars**, so the Fermat test on a
semiprime with distinct factors succeeds with probability at least `1/2`. -/
theorem fermatLiar_density_le_half [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    2 * Nat.card {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} ≤ Nat.card (ZMod (p * q))ˣ := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  rw [card_fermatLiars hpq, card_units_semiprime hp hq hpq]
  exact eulerGap_lt hp hq hpq

/-- **Image of the Fermat map.** The `(N-1)`-power endomorphism of the unit
group has image of size `φ(N)/g²`: exactly the `g²`-fold collapse caused by the
Euler gap, and nothing else. -/
theorem card_range_pow [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    (eulerGap p q) ^ 2 *
        Nat.card ((powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).range)
      = (p - 1) * (q - 1) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  set f := (powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ) with hf
  have hcard : Nat.card f.ker * Nat.card f.range = Nat.card (ZMod (p * q))ˣ := by
    have h1 : Nat.card f.range = f.ker.index := by
      rw [← Nat.card_congr (QuotientGroup.quotientKerEquivRange f).toEquiv]
      exact (Subgroup.index_eq_card f.ker).symm
    rw [h1, Subgroup.card_mul_index]
  rw [← card_liarSubgroup hpq, hcard, card_units_semiprime hp hq hpq]

/-- **The `(N-1)`-power map on units is a bijection exactly when the Euler gap
is `1`.** -/
theorem pow_bijective_iff_eulerGap_one [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    Function.Bijective (fun u : (ZMod (p * q))ˣ => u ^ (p * q - 1)) ↔ eulerGap p q = 1 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcount := card_fermatLiars (p := p) (q := q) hpq
  constructor
  · intro hbij
    have hsub : Subsingleton {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} := by
      refine ⟨fun x y => ?_⟩
      have : (x : (ZMod (p * q))ˣ) = y := by
        apply hbij.1
        simp only
        rw [x.2, y.2]
      exact Subtype.ext this
    have hne : Nonempty {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} := ⟨⟨1, one_pow _⟩⟩
    have : Nat.card {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} = 1 :=
      Nat.card_eq_one_iff_unique.mpr ⟨hsub, hne⟩
    rw [hcount] at this
    nlinarith [this]
  · intro hg
    rw [hg] at hcount
    have hsub : Subsingleton {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1} :=
      (Nat.card_eq_one_iff_unique.mp (by simpa using hcount)).1
    have hinj : Function.Injective (fun u : (ZMod (p * q))ˣ => u ^ (p * q - 1)) := by
      have : Function.Injective (powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ) := by
        refine (injective_iff_map_eq_one _).mpr (fun a ha => ?_)
        have ha' : a ^ (p * q - 1) = 1 := by simpa using ha
        have := hsub.allEq (⟨a, ha'⟩ : {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1})
          ⟨1, one_pow _⟩
        exact congrArg Subtype.val this
      simpa [powMonoidHom] using this
    exact Finite.injective_iff_bijective.mp hinj

/-- **Structure of the liar group: it depends on `(p, q)` only through `g`.**
The group of Fermat liars modulo `N = p*q` is isomorphic to
`(ℤ/g) × (ℤ/g)`, `g = gcd(p-1, q-1)`.  Two semiprimes with the same Euler gap
have isomorphic Fermat-liar structure, no matter how far apart their factors
are: this is the structural form of factor-blindness. -/
noncomputable def liarGroupEquiv [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    ((powMonoidHom (p * q - 1) : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).ker) ≃*
      Multiplicative (ZMod (eulerGap p q)) × Multiplicative (ZMod (eulerGap p q)) := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).mpr hpq
  set n := p * q - 1 with hn
  set e := crtUnits hcop with he
  set Kp := (powMonoidHom n : (ZMod p)ˣ →* (ZMod p)ˣ).ker with hKp
  set Kq := (powMonoidHom n : (ZMod q)ˣ →* (ZMod q)ˣ).ker with hKq
  have hmap : Subgroup.map e.toMonoidHom
      ((powMonoidHom n : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).ker) = Kp.prod Kq := by
    ext v
    rw [Subgroup.mem_map_equiv]
    simp only [hKp, hKq, MonoidHom.mem_ker, powMonoidHom_apply, Subgroup.mem_prod]
    have hiff := pow_eq_one_iff_components hcop (e.symm v) n
    rw [he] at hiff ⊢
    simpa using hiff
  have step1 : ((powMonoidHom n : (ZMod (p * q))ˣ →* (ZMod (p * q))ˣ).ker) ≃* (Kp.prod Kq) :=
    (e.subgroupMap _).trans (MulEquiv.subgroupCongr hmap)
  have hcardp : Nat.card Kp = eulerGap p q := by
    rw [hKp, IsCyclic.card_powMonoidHom_ker, Nat.card_eq_fintype_card, ZMod.card_units p, hn,
      Nat.gcd_comm, gcd_exp_left hp.pos hq.pos, eulerGap]
    exact Nat.gcd_comm _ _
  have hcardq : Nat.card Kq = eulerGap p q := by
    rw [hKq, IsCyclic.card_powMonoidHom_ker, Nat.card_eq_fintype_card, ZMod.card_units q, hn,
      Nat.gcd_comm, gcd_exp_right hp.pos hq.pos, eulerGap]
  have hcardZ : Nat.card (Multiplicative (ZMod (eulerGap p q))) = eulerGap p q := by
    rw [Nat.card_congr (Multiplicative.toAdd (α := ZMod (eulerGap p q))), Nat.card_zmod]
  have ep : Kp ≃* Multiplicative (ZMod (eulerGap p q)) :=
    mulEquivOfCyclicCardEq (by rw [hcardp, hcardZ])
  have eq' : Kq ≃* Multiplicative (ZMod (eulerGap p q)) :=
    mulEquivOfCyclicCardEq (by rw [hcardq, hcardZ])
  exact step1.trans ((Subgroup.prodEquiv Kp Kq).trans (MulEquiv.prodCongr ep eq'))

/-- **A semiprime with distinct prime factors is never a Carmichael number.**
There is a unit `u` modulo `N = p*q` with `u^(N-1) ≠ 1`. -/
theorem exists_fermat_witness [Fact p.Prime] [Fact q.Prime] (hpq : p ≠ q) :
    ∃ u : (ZMod (p * q))ˣ, u ^ (p * q - 1) ≠ 1 := by
  have hp : p.Prime := Fact.out
  have hq : q.Prime := Fact.out
  by_contra hcon
  push_neg at hcon
  have hall : Nat.card {u : (ZMod (p * q))ˣ // u ^ (p * q - 1) = 1}
      = Nat.card (ZMod (p * q))ˣ :=
    Nat.card_congr (Equiv.subtypeUnivEquiv hcon)
  have hlt := fermatLiar_density_le_half (p := p) (q := q) hpq
  rw [hall, card_units_semiprime hp hq hpq] at hlt
  have hp2 : 2 ≤ p := hp.two_le
  have hq2 : 2 ≤ q := hq.two_le
  have hpos : 0 < (p - 1) * (q - 1) := Nat.mul_pos (by omega) (by omega)
  omega

end AsymmetricExponent