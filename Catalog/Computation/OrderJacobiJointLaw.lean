import Mathlib

/-!
# The Order × Jacobi Joint Law for Semiprime Moduli

Let `N = p * q` be a semiprime with `p ≠ q` odd primes, and let
`H p := (p - 1) / 2` be the exponent of the index-`2` "half group" of
`(ZMod p)ˣ`.

This file formalises the *joint law* of the pair

  `u ↦ (orderOf u, jacobiSym u N)`   on   `(ZMod N)ˣ`.

Three layers are proved.

## 1. The coupling is exact

`isSquare_iff_orderOf_dvd_half` : a unit of `ZMod p` is a quadratic residue
**iff** its order divides `(p-1)/2`, i.e. iff it lies in the half group.  This
is Euler's criterion recast as a statement about orders; it is an exact
equivalence with no error term (`legendreSym_eq_one_iff_orderOf_dvd_half` is the
Legendre-symbol form).

## 2. The lift to `N = p*q` is *not* exact, and we determine exactly when it is

Writing `L := lcm (H p) (H q)`, the forward implication
"both components are residues → `orderOf u ∣ L`" always holds
(`orderOf_dvd_lcm_half_of_isSquare`).  The converse is **false in general**:
`orderOf_dvd_lcm_half_not_isSquare` exhibits `u = -1` as a counterexample
whenever `p ≡ 3` and `q ≡ 1 (mod 4)`.

The sharp statement is the dichotomy `orderOf_dvd_lcm_half_iff_iff_balanced`:
the converse holds for every unit **iff** the *balanced 2-adic* hypothesis
`v₂(H p) = v₂(H q)` is satisfied (sufficiency:
`isSquare_of_orderOf_dvd_lcm_half`; necessity:
`exists_counterexample_of_unbalanced`).  Since `v₂(H p) = 0` exactly when
`p ≡ 3 (mod 4)`, the only structure visible at this level is a `mod 4` residue
dial.  On that dial the four quadrants are equinumerous: the order class has
exactly `φ(N)/4` elements (`card_half_order_class_three_mod_four`,
`four_mul_card_half_order_class`).  Moreover the Jacobi symbol itself cannot see
the order quadrant: for `p ≡ q ≡ 3 (mod 4)` the two units `1` and `-1` both have
Jacobi symbol `+1` while lying in different order classes
(`jacobi_one_blind_to_order_quadrant`).

## 3. The joint law does not determine the factorisation (barrier)

`jointLaw_35_eq_39` : the *complete* joint law — the multiset of all pairs
`(orderOf b, J(b|N))` over the units — of `N = 35 = 5·7` coincides with that of
`N = 39 = 3·13`, and hence so does every conditional law
(`jointLaw_conditional_eq`, `condOrderSum_eq`).  Since `gcd 35 39 = 1`, no
function of the joint law alone can return a nontrivial factor of `N`
(`no_jointLaw_factorizer`; the abstract form is
`no_factorizer_of_law_collision`).  This is an unconditional, machine-checked
version of the "the law is `N`-determined / circular to exploit" verdict.

Collisions have a structural source: any isomorphism of unit groups preserving
the Jacobi symbol transports the entire joint law
(`jointLaw_eq_of_jacobiPreserving`), because a group isomorphism automatically
preserves element orders.  The joint law is therefore an invariant of the pair
(unit group, quadratic character), which is far coarser than the factorisation.
-/

namespace OrderJacobi

open Finset

/-- The exponent of the index-`2` "half group" of `(ZMod p)ˣ`. -/
def H (p : ℕ) : ℕ := (p - 1) / 2

theorem two_mul_H (p : ℕ) (hp : Odd p) : 2 * H p = p - 1 := by
  obtain ⟨k, hk⟩ := hp
  simp only [H]
  omega

theorem H_pos {p : ℕ} (hp : 3 ≤ p) : 0 < H p := by
  simp only [H]; omega

/-- `H p` is odd exactly when `p ≡ 3 (mod 4)`. -/
theorem H_odd_of_three_mod_four {p : ℕ} (hp : p % 4 = 3) : ¬ (2 ∣ H p) := by
  simp only [H]; omega

theorem two_dvd_H_of_one_mod_four {p : ℕ} (hp : p % 4 = 1) : 2 ∣ H p := by
  simp only [H]; omega

/-! ## 1. The exact QR ↔ order coupling -/

section Prime

variable {p : ℕ} [Fact p.Prime]

/-- Being a square in the field `ZMod p` and being a square in its unit group
are equivalent for a unit. -/
theorem isSquare_val_iff_isSquare_unit (u : (ZMod p)ˣ) :
    IsSquare ((u : ZMod p)) ↔ IsSquare u := by
  constructor
  · rintro ⟨r, hr⟩
    have hr0 : r ≠ 0 := by
      rintro rfl
      simp at hr
    refine ⟨Units.mk0 r hr0, ?_⟩
    ext
    simpa using hr
  · rintro ⟨v, hv⟩
    exact ⟨(v : ZMod p), by rw [hv]; rfl⟩

/-- **Exact QR–order coupling.** A unit of `ZMod p` (`p` an odd prime) is a
quadratic residue if and only if its order divides `(p-1)/2`, i.e. iff it lies
in the half group. -/
theorem isSquare_iff_orderOf_dvd_half (hp : p ≠ 2) (u : (ZMod p)ˣ) :
    IsSquare u ↔ orderOf u ∣ H p := by
  rw [orderOf_dvd_iff_pow_eq_one]
  have h2 := (Fact.out : p.Prime).two_le
  have hodd := (Fact.out : p.Prime).odd_of_ne_two hp
  have hhalf : H p = p / 2 := by obtain ⟨k, hk⟩ := hodd; simp only [H]; omega
  rw [hhalf, ← ZMod.euler_criterion_units]
  constructor
  · rintro ⟨y, rfl⟩; exact ⟨y, by rw [pow_two]⟩
  · rintro ⟨y, rfl⟩; exact ⟨y, by rw [pow_two]⟩

/-- Legendre-symbol form of the coupling. -/
theorem legendreSym_eq_one_iff_orderOf_dvd_half (hp : p ≠ 2) (u : (ZMod p)ˣ) :
    legendreSym p ((u : ZMod p).val : ℤ) = 1 ↔ orderOf u ∣ H p := by
  have hcast : (((u : ZMod p).val : ℤ) : ZMod p) = (u : ZMod p) := by
    push_cast
    simp [ZMod.natCast_val, ZMod.cast_id]
  rw [legendreSym.eq_one_iff p (by rw [hcast]; exact u.ne_zero), hcast,
    isSquare_val_iff_isSquare_unit, isSquare_iff_orderOf_dvd_half hp]

end Prime

/-! ## 2. The semiprime joint law -/

section Semiprime

variable (p q : ℕ) [Fact p.Prime] [Fact q.Prime]

/-- The CRT projection of the unit group of `ZMod (p*q)` onto the unit groups of
the two prime factors. -/
def projPair : (ZMod (p * q))ˣ →* (ZMod p)ˣ × (ZMod q)ˣ :=
  MonoidHom.prod (Units.map (ZMod.castHom (Dvd.intro q rfl) (ZMod p)).toMonoidHom)
    (Units.map (ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)).toMonoidHom)

theorem projPair_injective (h : p.Coprime q) : Function.Injective (projPair p q) := by
  have hring : (RingHom.prod (ZMod.castHom (Dvd.intro q rfl) (ZMod p))
      (ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)) : ZMod (p * q) →+* ZMod p × ZMod q) =
      ((ZMod.chineseRemainder h : ZMod (p * q) ≃+* _) : ZMod (p * q) →+* ZMod p × ZMod q) :=
    Subsingleton.elim _ _
  have hinj : Function.Injective
      (RingHom.prod (ZMod.castHom (Dvd.intro q rfl) (ZMod p))
        (ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)) : ZMod (p * q) →+* ZMod p × ZMod q) := by
    rw [hring]; exact (ZMod.chineseRemainder h).injective
  intro u v huv
  have h1 : (ZMod.castHom (Dvd.intro q rfl) (ZMod p)) (u : ZMod (p * q)) =
      (ZMod.castHom (Dvd.intro q rfl) (ZMod p)) (v : ZMod (p * q)) :=
    congrArg (fun z : (ZMod p)ˣ × (ZMod q)ˣ => (z.1 : ZMod p)) huv
  have h2 : (ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)) (u : ZMod (p * q)) =
      (ZMod.castHom (Dvd.intro_left p rfl) (ZMod q)) (v : ZMod (p * q)) :=
    congrArg (fun z : (ZMod p)ˣ × (ZMod q)ˣ => (z.2 : ZMod q)) huv
  exact Units.ext (hinj (Prod.ext h1 h2))

/-- **Order splits as an lcm.** The order of a unit mod `p*q` is the lcm of the
orders of its two CRT components. -/
theorem orderOf_eq_lcm (h : p.Coprime q) (u : (ZMod (p * q))ˣ) :
    orderOf u = Nat.lcm (orderOf (projPair p q u).1) (orderOf (projPair p q u).2) := by
  rw [← Prod.orderOf, orderOf_injective _ (projPair_injective p q h)]

/-- The CRT projection is a bijection: `(ZMod (p*q))ˣ ≅ (ZMod p)ˣ × (ZMod q)ˣ`. -/
theorem projPair_bijective (h : p.Coprime q) : Function.Bijective (projPair p q) := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  haveI : NeZero q := ⟨(Fact.out : q.Prime).pos.ne'⟩
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero (Fact.out : p.Prime).pos.ne'
    (Fact.out : q.Prime).pos.ne'⟩
  refine (Fintype.bijective_iff_injective_and_card _).2 ⟨projPair_injective p q h, ?_⟩
  rw [Fintype.card_prod, ZMod.card_units_eq_totient, ZMod.card_units_eq_totient,
    ZMod.card_units_eq_totient, Nat.totient_mul h]

/-- **Forward half of the joint law.** If both CRT components are quadratic
residues, then the order of `u` divides `lcm (H p) (H q)`. -/
theorem orderOf_dvd_lcm_half_of_isSquare (h : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2)
    (u : (ZMod (p * q))ˣ) (hup : IsSquare (projPair p q u).1)
    (huq : IsSquare (projPair p q u).2) :
    orderOf u ∣ Nat.lcm (H p) (H q) := by
  rw [orderOf_eq_lcm p q h]
  exact Nat.lcm_dvd
    (((isSquare_iff_orderOf_dvd_half hp _).1 hup).trans (Nat.dvd_lcm_left _ _))
    (((isSquare_iff_orderOf_dvd_half hq _).1 huq).trans (Nat.dvd_lcm_right _ _))

end Semiprime

/-! ### The 2-adic obstruction -/

/-- Arithmetic core: if `a ∣ 2*x`, `a ∣ lcm x y` and `y` is 2-adically no larger
than `x`, then already `a ∣ x`.  This is the exact reason the converse of
`orderOf_dvd_lcm_half_of_isSquare` can fail. -/
theorem dvd_of_dvd_two_mul_of_dvd_lcm {a x y : ℕ} (hx : x ≠ 0) (hy : y ≠ 0)
    (ha : a ∣ 2 * x) (hL : a ∣ Nat.lcm x y)
    (hv : y.factorization 2 ≤ x.factorization 2) : a ∣ x := by
  have key : Nat.gcd (2 * x) (Nat.lcm x y) ∣ x := by
    rw [← Nat.factorization_le_iff_dvd (by positivity) hx,
      Nat.factorization_gcd (by positivity) (Nat.lcm_ne_zero hx hy),
      Nat.factorization_lcm hx hy, Nat.factorization_mul two_ne_zero hx]
    intro r
    simp only [Finsupp.inf_apply, Finsupp.sup_apply, Finsupp.add_apply]
    rcases eq_or_ne r 2 with rfl | hr
    · simp only [Nat.Prime.factorization (by norm_num : Nat.Prime 2), Finsupp.single_eq_same]
      omega
    · have h0 : (Nat.factorization 2) r = 0 := by
        simp [Nat.Prime.factorization (by norm_num : Nat.Prime 2), hr.symm]
      omega
  exact dvd_trans (Nat.dvd_gcd ha hL) key

section Sharp

variable (p q : ℕ) [Fact p.Prime] [Fact q.Prime]

/-- **Sharp converse under the balanced 2-adic hypothesis.** If `H p` and `H q`
have the same 2-adic valuation then `orderOf u ∣ lcm (H p) (H q)` forces *both*
CRT components to be quadratic residues.  Together with
`orderOf_dvd_lcm_half_of_isSquare` this is an exact joint law. -/
theorem isSquare_of_orderOf_dvd_lcm_half (h : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2)
    (hbal : (H q).factorization 2 = (H p).factorization 2)
    (u : (ZMod (p * q))ˣ) (hu : orderOf u ∣ Nat.lcm (H p) (H q)) :
    IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2 := by
  have hp3 : 3 ≤ p := by
    have := (Fact.out : p.Prime).two_le
    omega
  have hq3 : 3 ≤ q := by
    have := (Fact.out : q.Prime).two_le
    omega
  have hHp : H p ≠ 0 := (H_pos hp3).ne'
  have hHq : H q ≠ 0 := (H_pos hq3).ne'
  have hcardp : orderOf (projPair p q u).1 ∣ 2 * H p := by
    have hcard : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units_eq_totient p ▸
      (Nat.totient_prime (Fact.out : p.Prime))
    rw [two_mul_H p ((Fact.out : p.Prime).odd_of_ne_two hp), ← hcard]
    exact orderOf_dvd_card
  have hcardq : orderOf (projPair p q u).2 ∣ 2 * H q := by
    have hcard : Fintype.card (ZMod q)ˣ = q - 1 := ZMod.card_units_eq_totient q ▸
      (Nat.totient_prime (Fact.out : q.Prime))
    rw [two_mul_H q ((Fact.out : q.Prime).odd_of_ne_two hq), ← hcard]
    exact orderOf_dvd_card
  rw [orderOf_eq_lcm p q h] at hu
  have hup : orderOf (projPair p q u).1 ∣ Nat.lcm (H p) (H q) :=
    (Nat.dvd_lcm_left _ _).trans hu
  have huq : orderOf (projPair p q u).2 ∣ Nat.lcm (H p) (H q) :=
    (Nat.dvd_lcm_right _ _).trans hu
  refine ⟨(isSquare_iff_orderOf_dvd_half hp _).2 ?_, (isSquare_iff_orderOf_dvd_half hq _).2 ?_⟩
  · exact dvd_of_dvd_two_mul_of_dvd_lcm hHp hHq hcardp hup (le_of_eq hbal)
  · exact dvd_of_dvd_two_mul_of_dvd_lcm hHq hHp hcardq
      (by rwa [Nat.lcm_comm] at huq) (le_of_eq hbal.symm)

/-- The image of `-1` under the CRT projection is `(-1, -1)`. -/
theorem projPair_neg_one :
    projPair p q (-1) = (-1, -1) := by
  ext <;> simp [projPair]

/-- **The balanced hypothesis is necessary.** If `p ≡ 3 (mod 4)` and
`q ≡ 1 (mod 4)` (so `v₂ (H p) = 0 < v₂ (H q)`) then `u = -1` has order dividing
`lcm (H p) (H q)` while its component at `p` is a quadratic *non*-residue: the
converse of `orderOf_dvd_lcm_half_of_isSquare` fails. -/
theorem orderOf_dvd_lcm_half_not_isSquare (hp3 : p % 4 = 3) (hq1 : q % 4 = 1) :
    ∃ u : (ZMod (p * q))ˣ, orderOf u ∣ Nat.lcm (H p) (H q) ∧
      ¬ IsSquare (projPair p q u).1 := by
  refine ⟨-1, ?_, ?_⟩
  · have h2 : orderOf (-1 : (ZMod (p * q))ˣ) ∣ 2 :=
      orderOf_dvd_of_pow_eq_one (by rw [neg_one_sq])
    exact h2.trans ((two_dvd_H_of_one_mod_four hq1).trans (Nat.dvd_lcm_right _ _))
  · rw [projPair_neg_one]
    simp only
    rw [← isSquare_val_iff_isSquare_unit]
    simpa using (ZMod.exists_sq_eq_neg_one_iff (p := p)).not.2 (by simp [hp3])

/-! ### Necessity of the 2-adic balance, in general -/

/-- In a finite cyclic group there is an element of every order dividing the
cardinality. -/
theorem exists_orderOf_eq_of_dvd_card {G : Type*} [Group G] [Finite G] [IsCyclic G] {d : ℕ}
    (hd : d ∣ Nat.card G) : ∃ x : G, orderOf x = d := by
  obtain ⟨g, hg⟩ := isCyclic_iff_exists_orderOf_eq_natCard.mp (inferInstance : IsCyclic G)
  have hn : 0 < Nat.card G := Nat.card_pos
  refine ⟨g ^ (Nat.card G / d), ?_⟩
  rw [orderOf_pow, hg, Nat.gcd_eq_right (Nat.div_dvd_of_dvd hd), Nat.div_div_self hd hn.ne']

/-- If `m` is 2-adically larger than `H p`, then `(ZMod p)ˣ` contains a quadratic
non-residue whose order nevertheless divides `m`. -/
theorem exists_nonsquare_orderOf_dvd (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) {m : ℕ}
    (hm : m ≠ 0) (hlt : (H p).factorization 2 < m.factorization 2) :
    ∃ x : (ZMod p)ˣ, orderOf x ∣ m ∧ ¬ IsSquare x := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  have hp3 : 3 ≤ p := by have := (Fact.out : p.Prime).two_le; omega
  have hHp : H p ≠ 0 := (H_pos hp3).ne'
  set s := (H p).factorization 2 with hs
  have hcard : Nat.card (ZMod p)ˣ = 2 * H p := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
      Nat.totient_prime (Fact.out : p.Prime), two_mul_H p ((Fact.out : p.Prime).odd_of_ne_two hp)]
  have hdvd_card : (2 : ℕ) ^ (s + 1) ∣ Nat.card (ZMod p)ˣ := by
    rw [hcard, pow_succ, mul_comm ((2:ℕ) ^ s) 2]
    exact Nat.mul_dvd_mul_left 2 (Nat.ordProj_dvd (H p) 2)
  obtain ⟨x, hx⟩ := exists_orderOf_eq_of_dvd_card hdvd_card
  refine ⟨x, ?_, ?_⟩
  · rw [hx]
    exact (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hm).2 (by omega)
  · intro hsq
    have hdvd : (2 : ℕ) ^ (s + 1) ∣ H p := hx ▸ (isSquare_iff_orderOf_dvd_half hp x).1 hsq
    have := (Nat.Prime.pow_dvd_iff_le_factorization Nat.prime_two hHp).1 hdvd
    omega


/-- **Necessity of the balance hypothesis, general form.** If `H p` and `H q`
have different 2-adic valuations there is a unit whose order divides
`lcm (H p) (H q)` but which is not a residue at both primes. -/
theorem exists_counterexample_of_unbalanced (h : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2)
    (hne : (H p).factorization 2 ≠ (H q).factorization 2) :
    ∃ u : (ZMod (p * q))ˣ, orderOf u ∣ Nat.lcm (H p) (H q) ∧
      ¬ (IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2) := by
  have hp3 : 3 ≤ p := by have := (Fact.out : p.Prime).two_le; omega
  have hq3 : 3 ≤ q := by have := (Fact.out : q.Prime).two_le; omega
  have hHp : H p ≠ 0 := (H_pos hp3).ne'
  have hHq : H q ≠ 0 := (H_pos hq3).ne'
  rcases lt_or_gt_of_ne hne with hlt | hlt
  · obtain ⟨x, hxdvd, hxns⟩ := exists_nonsquare_orderOf_dvd p hp hHq hlt
    obtain ⟨u, hu⟩ := (projPair_bijective p q h).surjective (x, 1)
    refine ⟨u, ?_, ?_⟩
    · rw [orderOf_eq_lcm p q h, hu]
      simpa using hxdvd.trans (Nat.dvd_lcm_right _ _)
    · rw [hu]
      exact fun hc => hxns hc.1
  · obtain ⟨y, hydvd, hyns⟩ := exists_nonsquare_orderOf_dvd q hq hHp hlt
    obtain ⟨u, hu⟩ := (projPair_bijective p q h).surjective (1, y)
    refine ⟨u, ?_, ?_⟩
    · rw [orderOf_eq_lcm p q h, hu]
      simpa using hydvd.trans (Nat.dvd_lcm_left _ _)
    · rw [hu]
      exact fun hc => hyns hc.2

/-- **The exact dichotomy.** The order test `orderOf u ∣ lcm (H p) (H q)` is
equivalent to "both CRT components are quadratic residues" for *every* unit if
and only if `H p` and `H q` have the same 2-adic valuation.  Together with
`H_odd_of_three_mod_four` this says the joint law is governed by a single
2-adic (equivalently, `mod 4`-type) dial and nothing else. -/
theorem orderOf_dvd_lcm_half_iff_iff_balanced (h : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2) :
    (∀ u : (ZMod (p * q))ˣ, orderOf u ∣ Nat.lcm (H p) (H q) ↔
        (IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2)) ↔
      (H p).factorization 2 = (H q).factorization 2 := by
  constructor
  · intro hall
    by_contra hne
    obtain ⟨u, hord, hbad⟩ := exists_counterexample_of_unbalanced p q h hp hq hne
    exact hbad ((hall u).1 hord)
  · intro hbal u
    refine ⟨fun hu => isSquare_of_orderOf_dvd_lcm_half p q h hp hq hbal.symm u hu, ?_⟩
    rintro ⟨h1, h2⟩
    exact orderOf_dvd_lcm_half_of_isSquare p q h hp hq u h1 h2

omit [Fact (Nat.Prime p)] [Fact (Nat.Prime q)] in
/-- **The Jacobi symbol is blind to the order quadrant.** For `p ≡ q ≡ 3 (mod 4)`
the units `1` and `-1` both have Jacobi symbol `+1`, yet `orderOf 1 ∣ L` while
`orderOf (-1) ∤ L`, where `L = lcm (H p) (H q)`.  Hence the value of the Jacobi
symbol carries strictly less information than the order class. -/
theorem jacobi_one_blind_to_order_quadrant (hp3 : p % 4 = 3) (hq3 : q % 4 = 3) :
    jacobiSym 1 (p * q) = 1 ∧ jacobiSym (-1) (p * q) = 1 ∧
      orderOf (1 : (ZMod (p * q))ˣ) ∣ Nat.lcm (H p) (H q) ∧
      ¬ (orderOf (-1 : (ZMod (p * q))ˣ) ∣ Nat.lcm (H p) (H q)) := by
  have hpodd : Odd p := by refine Nat.odd_iff.2 ?_; omega
  have hqodd : Odd q := by refine Nat.odd_iff.2 ?_; omega
  have hNodd : Odd (p * q) := hpodd.mul hqodd
  have hN4 : (p * q) % 4 = 1 := by
    rw [Nat.mul_mod, hp3, hq3]
  have hNgt : 2 < p * q := by
    have h1 : 3 ≤ p := by omega
    have h2 : 3 ≤ q := by omega
    calc 2 < 3 * 3 := by norm_num
      _ ≤ p * q := Nat.mul_le_mul h1 h2
  haveI : Fact (2 < p * q) := ⟨hNgt⟩
  have hnotdvd : ¬ (2 ∣ Nat.lcm (H p) (H q)) := by
    intro hdvd
    have hmul : Nat.lcm (H p) (H q) ∣ H p * H q := Nat.lcm_dvd_mul _ _
    rcases (Nat.Prime.dvd_mul Nat.prime_two).1 (hdvd.trans hmul) with h | h
    · exact H_odd_of_three_mod_four hp3 h
    · exact H_odd_of_three_mod_four hq3 h
  refine ⟨jacobiSym.one_left _, ?_, by simp, ?_⟩
  · rw [jacobiSym.at_neg_one hNodd, ZMod.χ₄_nat_one_mod_four hN4]
  · have hord : orderOf (-1 : (ZMod (p * q))ˣ) = 2 := by
      refine orderOf_eq_prime (by rw [neg_one_sq]) ?_
      intro hcon
      exact ZMod.neg_one_ne_one (n := p * q) (by simpa using congrArg (Units.val) hcon)
    rw [hord]
    exact hnotdvd

/-! ### Counting the quadrants -/

/-- The kernel of squaring on `(ZMod p)ˣ` is `{1, -1}`, of size `2`. -/
theorem card_sq_ker (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    Nat.card ((powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).ker) = 2 := by
  have hp2 := (Fact.out : p.Prime).two_le
  have hne : (1 : (ZMod p)ˣ) ≠ -1 := by
    intro hcon
    have h2 : (2 : ZMod p) = 0 := by
      have hv := congrArg Units.val hcon
      simp at hv
      linear_combination hv
    have hd : (p : ℕ) ∣ 2 := (ZMod.natCast_eq_zero_iff 2 p).1 (by exact_mod_cast h2)
    have := Nat.le_of_dvd (by norm_num) hd
    omega
  have hset : (((powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).ker) : Set (ZMod p)ˣ) = {1, -1} := by
    ext u
    simp only [SetLike.mem_coe, MonoidHom.mem_ker, powMonoidHom_apply, Set.mem_insert_iff,
      Set.mem_singleton_iff]
    constructor
    · intro h
      have hv : ((u : ZMod p)) ^ 2 = 1 := by
        rw [← Units.val_pow_eq_pow_val, h, Units.val_one]
      have h0 : ((u : ZMod p) - 1) * ((u : ZMod p) + 1) = 0 := by linear_combination hv
      rcases mul_eq_zero.1 h0 with h1 | h1
      · left
        have hu1 : (u : ZMod p) = 1 := by linear_combination h1
        exact Units.ext (by simpa using hu1)
      · right
        have hu1 : (u : ZMod p) = -1 := by linear_combination h1
        exact Units.ext (by simpa using hu1)
    · rintro (rfl | rfl) <;> simp
  have h1 : Nat.card ((powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).ker)
      = Nat.card (({1, -1} : Set (ZMod p)ˣ)) := by rw [← hset]; rfl
  rw [h1, Nat.card_coe_set_eq, Set.ncard_pair hne]

/-- **The half group has exactly `H p` elements.** Equivalently, exactly half of
the units mod `p` are quadratic residues. -/
theorem card_squares (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    Nat.card {u : (ZMod p)ˣ // IsSquare u} = H p := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).pos.ne'⟩
  have hp2 := (Fact.out : p.Prime).two_le
  have hrange : ∀ u : (ZMod p)ˣ, IsSquare u ↔ u ∈ (powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).range := by
    intro u
    constructor
    · rintro ⟨v, rfl⟩
      exact ⟨v, by simp [powMonoidHom, sq]⟩
    · rintro ⟨v, hv⟩
      exact ⟨v, by rw [← hv]; simp [powMonoidHom, sq]⟩
  have hcard : Nat.card {u : (ZMod p)ˣ // IsSquare u}
      = Nat.card ((powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).range) :=
    Nat.card_congr (Equiv.subtypeEquivRight hrange)
  have hquot : Nat.card ((ZMod p)ˣ ⧸ (powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).ker)
      = Nat.card ((powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).range) :=
    Nat.card_congr (QuotientGroup.quotientKerEquivRange _).toEquiv
  have hsplit := Subgroup.card_eq_card_quotient_mul_card_subgroup
    (powMonoidHom 2 : (ZMod p)ˣ →* (ZMod p)ˣ).ker
  rw [hquot, card_sq_ker p hp] at hsplit
  have hG : Nat.card (ZMod p)ˣ = 2 * H p := by
    rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient,
      Nat.totient_prime (Fact.out : p.Prime), two_mul_H p ((Fact.out : p.Prime).odd_of_ne_two hp)]
  rw [hG] at hsplit
  omega

/-- **Exactness on the `p ≡ q ≡ 3 (mod 4)` dial.** Here the 2-adic balance
hypothesis holds automatically, so the order test `orderOf u ∣ lcm (H p) (H q)`
is *equivalent* to both CRT components being quadratic residues. -/
theorem orderOf_dvd_lcm_half_iff_three_mod_four (h : p.Coprime q) (hp3 : p % 4 = 3)
    (hq3 : q % 4 = 3) (u : (ZMod (p * q))ˣ) :
    orderOf u ∣ Nat.lcm (H p) (H q) ↔
      (IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2) := by
  have hp2 : p ≠ 2 := by omega
  have hq2 : q ≠ 2 := by omega
  have hbal : (H q).factorization 2 = (H p).factorization 2 := by
    rw [Nat.factorization_eq_zero_of_not_dvd (H_odd_of_three_mod_four hq3),
      Nat.factorization_eq_zero_of_not_dvd (H_odd_of_three_mod_four hp3)]
  refine ⟨fun hu => isSquare_of_orderOf_dvd_lcm_half p q h hp2 hq2 hbal u hu, ?_⟩
  rintro ⟨h1, h2⟩
  exact orderOf_dvd_lcm_half_of_isSquare p q h hp2 hq2 u h1 h2

/-- The unit group of a semiprime has exactly `4 * (H p * H q)` elements: the
four Jacobi/order quadrants are the four cosets cut out by the two half
groups. -/
theorem card_units_semiprime (hcop : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2) :
    Fintype.card (ZMod (p * q))ˣ = 4 * (H p * H q) := by
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero (Fact.out : p.Prime).pos.ne'
    (Fact.out : q.Prime).pos.ne'⟩
  have hp3 : 3 ≤ p := by have := (Fact.out : p.Prime).two_le; omega
  have hq3 : 3 ≤ q := by have := (Fact.out : q.Prime).two_le; omega
  have hHp := two_mul_H p ((Fact.out : p.Prime).odd_of_ne_two hp)
  have hHq := two_mul_H q ((Fact.out : q.Prime).odd_of_ne_two hq)
  rw [ZMod.card_units_eq_totient, Nat.totient_mul hcop,
    Nat.totient_prime (Fact.out : p.Prime), Nat.totient_prime (Fact.out : q.Prime)]
  have h1 : p - 1 = 2 * H p := hHp.symm
  have h2 : q - 1 = 2 * H q := hHq.symm
  rw [h1, h2]
  ring


/-- **The both-residue quadrant has exactly `H p * H q` elements**, i.e. exactly
one quarter of `(ZMod (p*q))ˣ` (compare `card_units_semiprime`). -/
theorem card_both_squares (h : p.Coprime q) (hp : p ≠ 2) (hq : q ≠ 2) :
    Nat.card {u : (ZMod (p * q))ˣ //
      IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2} = H p * H q := by
  have e1 : {u : (ZMod (p * q))ˣ //
        IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2} ≃
      {v : (ZMod p)ˣ × (ZMod q)ˣ // IsSquare v.1 ∧ IsSquare v.2} :=
    Equiv.subtypeEquiv (Equiv.ofBijective _ (projPair_bijective p q h)) (fun _ => Iff.rfl)
  rw [Nat.card_congr e1, Nat.card_congr Equiv.subtypeProdEquivProd, Nat.card_prod,
    card_squares p hp, card_squares q hq]

/-- **Quantitative joint law on the `3 mod 4` dial.** For `p ≡ q ≡ 3 (mod 4)`
the set of units whose order divides `lcm (H p) (H q)` has exactly `H p * H q`
elements — one quarter of the unit group.  So the order test and the Jacobi
symbol cut the group into four equinumerous quadrants and nothing finer. -/
theorem card_half_order_class_three_mod_four (h : p.Coprime q) (hp3 : p % 4 = 3)
    (hq3 : q % 4 = 3) :
    Nat.card {u : (ZMod (p * q))ˣ // orderOf u ∣ Nat.lcm (H p) (H q)} = H p * H q := by
  have hp : p ≠ 2 := by omega
  have hq : q ≠ 2 := by omega
  have e : {u : (ZMod (p * q))ˣ // orderOf u ∣ Nat.lcm (H p) (H q)} ≃
      {u : (ZMod (p * q))ˣ // IsSquare (projPair p q u).1 ∧ IsSquare (projPair p q u).2} :=
    Equiv.subtypeEquivRight (fun u => orderOf_dvd_lcm_half_iff_three_mod_four p q h hp3 hq3 u)
  rw [Nat.card_congr e, card_both_squares p q h hp hq]

/-- The order class is exactly a quarter of the unit group. -/
theorem four_mul_card_half_order_class (h : p.Coprime q) (hp3 : p % 4 = 3) (hq3 : q % 4 = 3) :
    4 * Nat.card {u : (ZMod (p * q))ˣ // orderOf u ∣ Nat.lcm (H p) (H q)} =
      Nat.card (ZMod (p * q))ˣ := by
  have hp : p ≠ 2 := by omega
  have hq : q ≠ 2 := by omega
  rw [card_half_order_class_three_mod_four p q h hp3 hq3, Nat.card_eq_fintype_card,
    card_units_semiprime p q h hp hq]

end Sharp

/-! ## 3. The joint law does not determine the factorisation -/

section Barrier

/-- A computable multiplicative order of `b` modulo `N` (the least `k ≥ 1` with
`b ^ k ≡ 1`, or `0` if there is none). -/
def ordIn (N b : ℕ) : ℕ := (((Finset.Icc 1 N).filter (fun k => b ^ k % N = 1)).min).getD 0

/-- A computable quadratic-residue symbol, via Euler's criterion. -/
def qrSym (p b : ℕ) : ℤ := if b ^ ((p - 1) / 2) % p = 1 then 1 else -1

theorem pow_mod_eq_one_iff {N b k : ℕ} (hN : 1 < N) :
    b ^ k % N = 1 ↔ ((b : ZMod N)) ^ k = 1 := by
  rw [← Nat.cast_pow, show ((1 : ZMod N)) = ((1 : ℕ) : ZMod N) by push_cast; ring,
    ZMod.natCast_eq_natCast_iff' (b ^ k) 1 N, Nat.one_mod_eq_one.2 (by omega)]

/-- `ordIn` computes the true multiplicative order. -/
theorem ordIn_eq_orderOf {N b : ℕ} (hN : 1 < N) (hb : Nat.Coprime b N) :
    ordIn N b = orderOf ((b : ZMod N)) := by
  haveI : NeZero N := ⟨by omega⟩
  set d := orderOf ((b : ZMod N)) with hd
  have hunit : IsUnit ((b : ZMod N)) := (ZMod.isUnit_iff_coprime b N).2 hb
  have hdu : d = orderOf hunit.unit := by rw [hd, ← orderOf_units, hunit.unit_spec]
  have hdpos : 0 < d := by rw [hdu]; exact orderOf_pos _
  have hdle : d ≤ N := by
    have h1 : orderOf hunit.unit ∣ Fintype.card (ZMod N)ˣ := orderOf_dvd_card
    have h2 : Fintype.card (ZMod N)ˣ = N.totient := ZMod.card_units_eq_totient N
    have h3 := Nat.le_of_dvd Fintype.card_pos h1
    calc d = orderOf hunit.unit := hdu
      _ ≤ Fintype.card (ZMod N)ˣ := h3
      _ = N.totient := h2
      _ ≤ N := Nat.totient_le N
  set S := (Finset.Icc 1 N).filter (fun k => b ^ k % N = 1) with hS
  have hdS : d ∈ S := by
    simp only [hS, Finset.mem_filter, Finset.mem_Icc]
    exact ⟨⟨hdpos, hdle⟩, (pow_mod_eq_one_iff hN).2 (pow_orderOf_eq_one _)⟩
  have hmin : S.min = (d : WithTop ℕ) := by
    refine le_antisymm (Finset.min_le hdS) (Finset.le_min ?_)
    intro k hk
    simp only [hS, Finset.mem_filter, Finset.mem_Icc] at hk
    have hk1 : 0 < k := hk.1.1
    have hpow : ((b : ZMod N)) ^ k = 1 := (pow_mod_eq_one_iff hN).1 hk.2
    exact WithTop.coe_le_coe.2 (Nat.le_of_dvd hk1 (orderOf_dvd_of_pow_eq_one hpow))
  simp [ordIn, ← hS, hmin]
  rfl

/-- `qrSym` computes the Legendre symbol. -/
theorem qrSym_eq_legendreSym {p : ℕ} [Fact p.Prime] (hp : p ≠ 2) {b : ℕ} (hb : ¬ (p ∣ b)) :
    qrSym p b = legendreSym p b := by
  have h2 := (Fact.out : p.Prime).two_le
  have hodd := (Fact.out : p.Prime).odd_of_ne_two hp
  have hcast : ((b : ℤ) : ZMod p) = ((b : ℕ) : ZMod p) := by push_cast; ring
  have hne0 : ((b : ℕ) : ZMod p) ≠ 0 := by
    simpa [ZMod.natCast_eq_zero_iff] using hb
  have hne : ((b : ℤ) : ZMod p) ≠ 0 := by rw [hcast]; exact hne0
  have hhalf : (p - 1) / 2 = p / 2 := by obtain ⟨k, hk⟩ := hodd; omega
  have hiff : b ^ ((p - 1) / 2) % p = 1 ↔ legendreSym p b = 1 := by
    rw [legendreSym.eq_one_iff p hne, hcast, ZMod.euler_criterion p hne0, ← hhalf,
      pow_mod_eq_one_iff (by omega : 1 < p)]
  by_cases hc : b ^ ((p - 1) / 2) % p = 1
  · rw [qrSym, if_pos hc, hiff.1 hc]
  · rw [qrSym, if_neg hc]
    rcases legendreSym.eq_one_or_neg_one p hne with h | h
    · exact absurd (hiff.2 h) hc
    · rw [h]

/-- **The joint law of `N`**: the multiset of pairs `(order, Jacobi symbol)`
taken over all units mod `N`.  This is the complete statistic studied by the
CONDORDER experiment; every conditional law `ord | J = ±1` is a function of it. -/
noncomputable def jointLaw (N : ℕ) : Multiset (ℕ × ℤ) :=
  (((Finset.range N).filter (fun b => Nat.Coprime b N)).val).map
    (fun b : ℕ => (orderOf ((b : ZMod N)), jacobiSym (b : ℤ) N))

/-- The joint law indexed by the unit group instead of by residues. -/
noncomputable def jointLawU (N : ℕ) [NeZero N] : Multiset (ℕ × ℤ) :=
  (Finset.univ : Finset (ZMod N)ˣ).val.map
    (fun u : (ZMod N)ˣ => (orderOf u, jacobiSym ((u.val.val : ℕ) : ℤ) N))

/-- The two presentations of the joint law agree. -/
theorem jointLawU_eq_jointLaw (N : ℕ) [NeZero N] : jointLawU N = jointLaw N := by
  classical
  set phi : (ZMod N)ˣ → ℕ := fun u => (u : ZMod N).val with hphi
  have hinj : Function.Injective phi := by
    intro u v huv
    exact Units.ext (ZMod.val_injective N huv)
  have himg : (Finset.univ : Finset (ZMod N)ˣ).image phi
      = (Finset.range N).filter (fun b => Nat.Coprime b N) := by
    ext b
    simp only [Finset.mem_image, Finset.mem_univ, true_and, Finset.mem_filter, Finset.mem_range]
    constructor
    · rintro ⟨u, rfl⟩
      exact ⟨ZMod.val_lt _, ZMod.val_coe_unit_coprime u⟩
    · rintro ⟨hlt, hcop⟩
      refine ⟨ZMod.unitOfCoprime b hcop, ?_⟩
      simp [hphi, ZMod.coe_unitOfCoprime, ZMod.val_natCast_of_lt hlt]
  have hval : ((Finset.univ : Finset (ZMod N)ˣ).image phi).val
      = (Finset.univ : Finset (ZMod N)ˣ).val.map phi :=
    Finset.image_val_of_injOn (fun a _ b _ h => hinj h)
  have hfun : ∀ u : (ZMod N)ˣ,
      (fun u : (ZMod N)ˣ => (orderOf u, jacobiSym ((u.val.val : ℕ) : ℤ) N)) u
        = ((fun b : ℕ => (orderOf ((b : ZMod N)), jacobiSym (b : ℤ) N)) ∘ phi) u := by
    intro u
    simp only [Function.comp_apply, hphi]
    rw [ZMod.natCast_zmod_val, orderOf_units]
  calc jointLawU N
      = (Finset.univ : Finset (ZMod N)ˣ).val.map
          (fun u : (ZMod N)ˣ => (orderOf u, jacobiSym ((u.val.val : ℕ) : ℤ) N)) := rfl
    _ = (Finset.univ : Finset (ZMod N)ˣ).val.map
          ((fun b : ℕ => (orderOf ((b : ZMod N)), jacobiSym (b : ℤ) N)) ∘ phi) :=
        Multiset.map_congr rfl (fun u _ => hfun u)
    _ = ((Finset.univ : Finset (ZMod N)ˣ).val.map phi).map
          (fun b : ℕ => (orderOf ((b : ZMod N)), jacobiSym (b : ℤ) N)) :=
        (Multiset.map_map _ _ _).symm
    _ = (((Finset.univ : Finset (ZMod N)ˣ).image phi).val).map
          (fun b : ℕ => (orderOf ((b : ZMod N)), jacobiSym (b : ℤ) N)) := by rw [hval]
    _ = jointLaw N := by rw [himg]; rfl

/-- **Structural source of joint-law collisions.** Any isomorphism of unit groups
that preserves the Jacobi symbol transports the whole joint law.  Group orders
are automatically preserved by an isomorphism, so the joint law is really an
invariant of the pair (unit group, quadratic character) — an object with far
fewer degrees of freedom than the factorisation. -/
theorem jointLaw_eq_of_jacobiPreserving {N₁ N₂ : ℕ} [NeZero N₁] [NeZero N₂]
    (e : (ZMod N₁)ˣ ≃* (ZMod N₂)ˣ)
    (he : ∀ u : (ZMod N₁)ˣ, jacobiSym (((e u).val.val : ℕ) : ℤ) N₂
      = jacobiSym ((u.val.val : ℕ) : ℤ) N₁) :
    jointLaw N₂ = jointLaw N₁ := by
  classical
  have hstep : ∀ u : (ZMod N₁)ˣ,
      ((fun v : (ZMod N₂)ˣ => (orderOf v, jacobiSym ((v.val.val : ℕ) : ℤ) N₂)) ∘ e) u
        = (fun u : (ZMod N₁)ˣ => (orderOf u, jacobiSym ((u.val.val : ℕ) : ℤ) N₁)) u := by
    intro u
    simp only [Function.comp_apply]
    have hord : orderOf (e u) = orderOf u := orderOf_injective e.toMonoidHom e.injective u
    rw [he u, hord]
  have huniv : (Finset.univ : Finset (ZMod N₁)ˣ).map e.toEquiv.toEmbedding
      = (Finset.univ : Finset (ZMod N₂)ˣ) := Finset.map_univ_equiv e.toEquiv
  rw [← jointLawU_eq_jointLaw N₁, ← jointLawU_eq_jointLaw N₂]
  calc jointLawU N₂
      = (Finset.univ : Finset (ZMod N₂)ˣ).val.map
          (fun v : (ZMod N₂)ˣ => (orderOf v, jacobiSym ((v.val.val : ℕ) : ℤ) N₂)) := rfl
    _ = (((Finset.univ : Finset (ZMod N₁)ˣ).map e.toEquiv.toEmbedding).val).map
          (fun v : (ZMod N₂)ˣ => (orderOf v, jacobiSym ((v.val.val : ℕ) : ℤ) N₂)) := by
        rw [huniv]
    _ = ((Finset.univ : Finset (ZMod N₁)ˣ).val.map e).map
          (fun v : (ZMod N₂)ˣ => (orderOf v, jacobiSym ((v.val.val : ℕ) : ℤ) N₂)) := by
        rw [Finset.map_val]; rfl
    _ = (Finset.univ : Finset (ZMod N₁)ˣ).val.map
          ((fun v : (ZMod N₂)ˣ => (orderOf v, jacobiSym ((v.val.val : ℕ) : ℤ) N₂)) ∘ e) :=
        Multiset.map_map _ _ _
    _ = jointLawU N₁ := Multiset.map_congr rfl (fun u _ => hstep u)

/-- The computable presentation of the joint law of `N = p*q`. -/
def jointLawComp (p q : ℕ) : Multiset (ℕ × ℤ) :=
  (((Finset.range (p * q)).filter (fun b => Nat.Coprime b (p * q))).val).map
    (fun b : ℕ => (ordIn (p * q) b, qrSym p b * qrSym q b))

theorem jointLaw_eq_comp (p q : ℕ) [Fact p.Prime] [Fact q.Prime] (hp : p ≠ 2) (hq : q ≠ 2) :
    jointLaw (p * q) = jointLawComp p q := by
  have hp2 := (Fact.out : p.Prime).two_le
  have hq2 := (Fact.out : q.Prime).two_le
  have hN : 1 < p * q := by nlinarith
  simp only [jointLaw, jointLawComp]
  refine Multiset.map_congr rfl ?_
  intro b hb
  simp only [Finset.mem_val, Finset.mem_filter, Finset.mem_range] at hb
  obtain ⟨-, hcop⟩ := hb
  have hbp : ¬ (p ∣ b) := by
    intro hdvd
    have hd : p ∣ Nat.gcd b (p * q) := Nat.dvd_gcd hdvd ⟨q, rfl⟩
    rw [hcop] at hd
    have := Nat.dvd_one.mp hd
    omega
  have hbq : ¬ (q ∣ b) := by
    intro hdvd
    have hd : q ∣ Nat.gcd b (p * q) := Nat.dvd_gcd hdvd ⟨p, mul_comm p q⟩
    rw [hcop] at hd
    have := Nat.dvd_one.mp hd
    omega
  have hjac : jacobiSym b (p * q) = qrSym p b * qrSym q b := by
    rw [qrSym_eq_legendreSym hp hbp, qrSym_eq_legendreSym hq hbq,
      jacobiSym.legendreSym.to_jacobiSym, jacobiSym.legendreSym.to_jacobiSym,
      ← jacobiSym.mul_right]
  rw [ordIn_eq_orderOf hN hcop, hjac]

set_option maxRecDepth 40000 in
/-- **Two different semiprimes with the same joint law.**  `35 = 5·7` and
`39 = 3·13` have *identical* order × Jacobi joint laws. -/
theorem jointLaw_35_eq_39 : jointLaw 35 = jointLaw 39 := by
  haveI : Fact (Nat.Prime 5) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  haveI : Fact (Nat.Prime 13) := ⟨by norm_num⟩
  have h1 : jointLaw 35 = jointLawComp 5 7 := by
    have h : (35 : ℕ) = 5 * 7 := by norm_num
    rw [h]
    exact jointLaw_eq_comp 5 7 (by norm_num) (by norm_num)
  have h2 : jointLaw 39 = jointLawComp 3 13 := by
    have h : (39 : ℕ) = 3 * 13 := by norm_num
    rw [h]
    exact jointLaw_eq_comp 3 13 (by norm_num) (by norm_num)
  rw [h1, h2]
  decide

/-- Every conditional law `ord | J = e` agrees for `35` and `39` as well. -/
theorem jointLaw_conditional_eq (e : ℤ) :
    (jointLaw 35).filter (fun x => x.2 = e) = (jointLaw 39).filter (fun x => x.2 = e) := by
  rw [jointLaw_35_eq_39]

/-- In particular the conditional order sums (hence the conditional means
`E[ord | J = ±1]`) agree for `35` and `39`. -/
theorem condOrderSum_eq (e : ℤ) :
    (((jointLaw 35).filter (fun x => x.2 = e)).map Prod.fst).sum =
      (((jointLaw 39).filter (fun x => x.2 = e)).map Prod.fst).sum := by
  rw [jointLaw_conditional_eq]

/-- **Abstract barrier.** If two coprime moduli have the same joint law, then no
function of the joint law alone can return a nontrivial factor of the modulus:
it would have to return the same number for both, and that number divides both
moduli, hence divides `1`. -/
theorem no_factorizer_of_law_collision {N₁ N₂ : ℕ} (hlaw : jointLaw N₁ = jointLaw N₂)
    (hcop : Nat.Coprime N₁ N₂) (F : Multiset (ℕ × ℤ) → ℕ)
    (hgt : 1 < F (jointLaw N₁)) (h₁ : F (jointLaw N₁) ∣ N₁) (h₂ : F (jointLaw N₂) ∣ N₂) :
    False := by
  rw [← hlaw] at h₂
  have hg : F (jointLaw N₁) ∣ Nat.gcd N₁ N₂ := Nat.dvd_gcd h₁ h₂
  rw [hcop] at hg
  have := Nat.dvd_one.mp hg
  omega

/-- **Barrier, concrete form.** No function of the joint law alone can output a
nontrivial factor of the modulus: it would have to return the same number for
`35` and for `39`, and `gcd 35 39 = 1`. -/
theorem no_jointLaw_factorizer (F : Multiset (ℕ × ℤ) → ℕ) :
    ¬ (∀ N ∈ ({35, 39} : Finset ℕ), 1 < F (jointLaw N) ∧ F (jointLaw N) ∣ N) := by
  intro h
  obtain ⟨hgt, h35⟩ := h 35 (by decide)
  obtain ⟨-, h39⟩ := h 39 (by decide)
  exact no_factorizer_of_law_collision jointLaw_35_eq_39 (by norm_num) F hgt h35 h39

end Barrier

end OrderJacobi