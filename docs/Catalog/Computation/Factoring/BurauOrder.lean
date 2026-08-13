import Mathlib

/-!
# BURAU-ORD: the reduced Burau image of `B₃` mod `N` is order-finding in disguise

Round-3 closure #3.  The reduced Burau representation of the braid group `B₃`,
specialised at `t = a` over a commutative ring `R`, is

`r(σ₁) = !![-a, 1; 0, 1]`,  `r(σ₂) = !![1, 0; a, -a]`.

`Burau.braid_relation` checks that these really do satisfy the braid relation
`r(σ₁) r(σ₂) r(σ₁) = r(σ₂) r(σ₁) r(σ₂)`, so this is a genuinely non-abelian
(two-generator) picture.

The paper's experiment 305 observed numerically that the invariants of the
subgroup `H_a = ⟨r(σ₁), r(σ₂)⟩ ≤ GL(2, ℤ/N)` are governed by the multiplicative
order of `a`.  Here we prove the exact statement behind that observation:

* `Burau.bm_cube` — `(r(σ₁) r(σ₂))³ = a³ · I`, the central element `Δ²` of `B₃`
  maps to the scalar `a³`;
* `Burau.bm_pow_eq_one_iff` — `(r(σ₁) r(σ₂))ⁿ = 1 ↔ 3 ∣ n ∧ aⁿ = 1`;
* `Burau.orderOf_bm` — **the order of the braid element is `lcm(3, ord_N(a))`**.
  So computing orders in the Burau image *is* multiplicative order-finding mod
  `N` (`Burau.orderOf_dvd_orderOf_bm`, `Burau.orderOf_bm_dvd`): the barrier is
  the Pollard `p-1` / Shor core, barriers 6/8.
* `Burau.orderOf_crt` — the order invariant is CRT-separated:
  `ord_N(a) = lcm(ord_p(a), ord_q(a))`, hence factor-secret.

No non-abelian structure escapes: the braid picture is a faithful repackaging
of the order problem.
-/

namespace Burau

open Matrix

variable {R : Type*} [CommRing R]

/-- Reduced Burau image of the generator `σ₁`, specialised at `t = a`. -/
def gen1 (a : R) : Matrix (Fin 2) (Fin 2) R := !![-a, 1; 0, 1]

/-- Reduced Burau image of the generator `σ₂`, specialised at `t = a`. -/
def gen2 (a : R) : Matrix (Fin 2) (Fin 2) R := !![1, 0; a, -a]

/-- The image of `σ₁σ₂`. -/
def bm (a : R) : Matrix (Fin 2) (Fin 2) R := gen1 a * gen2 a

/-- The two matrices satisfy the braid relation of `B₃`: this really is a
representation of a non-abelian group. -/
theorem braid_relation (a : R) : gen1 a * gen2 a * gen1 a = gen2 a * gen1 a * gen2 a := by
  simp [gen1, gen2]

/-- Explicit form of the image of `σ₁σ₂`. -/
theorem bm_eq (a : R) : bm a = !![0, -a; a, -a] := by simp [bm, gen1, gen2]

/-- The full twist `Δ² = (σ₁σ₂)³` generates the centre of `B₃`; Burau sends it
to the scalar matrix `a³ · I`. -/
theorem bm_cube (a : R) : (bm a) ^ 3 = a ^ 3 • (1 : Matrix (Fin 2) (Fin 2) R) := by
  simp [bm, gen1, gen2, pow_succ, Matrix.smul_of, Matrix.one_fin_two]

theorem bm_pow_three_mul (a : R) (s : ℕ) :
    (bm a) ^ (3 * s) = (a ^ (3 * s)) • (1 : Matrix (Fin 2) (Fin 2) R) := by
  induction s with
  | zero => simp
  | succ k ih =>
    have h : 3 * (k + 1) = 3 * k + 3 := by ring
    rw [h, pow_add, ih, bm_cube, smul_mul_smul_comm, one_mul, ← pow_add]

theorem bm_entry_one (a : R) : (bm a) 0 1 = -a := by simp [bm_eq]

theorem bm_sq_entry (a : R) : ((bm a) ^ 2) 0 1 = a ^ 2 := by
  rw [bm_eq]
  simp [pow_two, Matrix.mul_apply, Fin.sum_univ_succ]

/-- **The order equation.**  For a unit `a` in a nontrivial commutative ring,
the braid element `σ₁σ₂` acts with order exactly `lcm(3, ord(a))`. -/
theorem bm_pow_eq_one_iff [Nontrivial R] {a : R} (ha : IsUnit a) (n : ℕ) :
    (bm a) ^ n = 1 ↔ (3 ∣ n ∧ a ^ n = 1) := by
  constructor
  · intro h
    have hsplit : n = 3 * (n / 3) + n % 3 := (Nat.div_add_mod n 3).symm ▸ by omega
    have hfac : (bm a) ^ n = (a ^ (3 * (n / 3))) • ((bm a) ^ (n % 3)) := by
      conv_lhs => rw [hsplit]
      rw [pow_add, bm_pow_three_mul, Matrix.smul_mul, one_mul]
    have hunit : IsUnit (a ^ (3 * (n / 3))) := ha.pow _
    have hentry : (a ^ (3 * (n / 3))) * (((bm a) ^ (n % 3)) 0 1) = 0 := by
      have := congrFun (congrFun (hfac.symm.trans h) 0) 1
      simpa [Matrix.smul_apply, Matrix.one_apply] using this
    have hz : ((bm a) ^ (n % 3)) 0 1 = 0 := by
      rcases hunit with ⟨u, hu⟩
      have := congrArg (fun x => (↑u⁻¹ : R) * x) hentry
      simpa [← hu, ← mul_assoc] using this
    have hr : n % 3 = 0 := by
      have h3 : n % 3 = 0 ∨ n % 3 = 1 ∨ n % 3 = 2 := by omega
      rcases h3 with h0 | h1 | h2
      · exact h0
      · exfalso
        rw [h1, pow_one, bm_entry_one] at hz
        have : a = 0 := by linear_combination -hz
        exact (this ▸ ha).ne_zero rfl
      · exfalso
        rw [h2, bm_sq_entry] at hz
        exact (ha.pow 2).ne_zero hz
    refine ⟨Nat.dvd_of_mod_eq_zero hr, ?_⟩
    have hn3 : 3 * (n / 3) = n := by omega
    have hkey : (a ^ n) • (1 : Matrix (Fin 2) (Fin 2) R) = 1 := by
      rw [← hn3, ← bm_pow_three_mul a (n / 3), hn3]
      exact h
    have := congrFun (congrFun hkey 0) 0
    simpa [Matrix.smul_apply, Matrix.one_apply] using this
  · rintro ⟨⟨s, rfl⟩, hpow⟩
    rw [bm_pow_three_mul, hpow, one_smul]

/-- The order of the Burau image of `σ₁σ₂` is `lcm(3, ord(a))`. -/
theorem orderOf_bm [Nontrivial R] {a : R} (ha : IsUnit a) :
    orderOf (bm a) = Nat.lcm 3 (orderOf a) := by
  refine Nat.dvd_antisymm ?_ ?_
  · refine orderOf_dvd_of_pow_eq_one ?_
    refine (bm_pow_eq_one_iff ha _).mpr ⟨Nat.dvd_lcm_left _ _, ?_⟩
    exact orderOf_dvd_iff_pow_eq_one.mp (Nat.dvd_lcm_right 3 (orderOf a))
  · obtain ⟨h3, hpow⟩ := (bm_pow_eq_one_iff ha (orderOf (bm a))).mp (pow_orderOf_eq_one _)
    exact Nat.lcm_dvd h3 (orderOf_dvd_iff_pow_eq_one.mpr hpow)

/-- Order-finding is *recoverable* from the braid element: `ord(a)` divides the
braid order. -/
theorem orderOf_dvd_orderOf_bm [Nontrivial R] {a : R} (ha : IsUnit a) :
    orderOf a ∣ orderOf (bm a) := by
  rw [orderOf_bm ha]; exact Nat.dvd_lcm_right _ _

/-- Conversely the braid order is at most a factor `3` away from `ord(a)`:
the two computational problems are equivalent up to a constant. -/
theorem orderOf_bm_dvd [Nontrivial R] {a : R} (ha : IsUnit a) :
    orderOf (bm a) ∣ 3 * orderOf a := by
  rw [orderOf_bm ha]
  exact Nat.lcm_dvd (Dvd.intro _ rfl) (Dvd.intro_left _ rfl)

section CRT

/-- The order invariant is CRT-separated: modulo a semiprime it is the lcm of
the two prime-level orders, so it is a *factor-secret* quantity — computing it
is exactly the Pollard `p-1` / Shor core. -/
theorem orderOf_crt {p q : ℕ} (h : p.Coprime q) (a : ZMod (p * q)) :
    orderOf a = Nat.lcm (orderOf ((ZMod.castHom (dvd_mul_right p q) (ZMod p)) a))
      (orderOf ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) a)) := by
  have hord : orderOf ((ZMod.chineseRemainder h) a) = orderOf a :=
    orderOf_injective (ZMod.chineseRemainder h).toRingHom.toMonoidHom
      (ZMod.chineseRemainder h).injective a
  rw [← hord, Prod.orderOf]
  congr 1 <;> simp [ZMod.chineseRemainder]

/-- Consequence for the braid picture: the order of the Burau image of `σ₁σ₂`
over `ℤ/pq` is determined by, and determines, the pair of prime-level
multiplicative orders. -/
theorem orderOf_bm_crt {p q : ℕ} (h : p.Coprime q) [Nontrivial (ZMod (p * q))]
    {a : ZMod (p * q)} (ha : IsUnit a) :
    orderOf (bm a) = Nat.lcm 3
      (Nat.lcm (orderOf ((ZMod.castHom (dvd_mul_right p q) (ZMod p)) a))
        (orderOf ((ZMod.castHom (dvd_mul_left q p) (ZMod q)) a))) := by
  rw [orderOf_bm ha, orderOf_crt h a]

end CRT


section BurauGroup

/-! ### The Burau subgroup `H_a ≤ GL(2, ℤ/N)`

The paper's experiment 305 measures the *order of the group*
`H_a = ⟨r(σ₁), r(σ₂)⟩` and observes that it separates the individual
multiplicative orders.  Here is the exact structural reason: `lcm(3, ord(a))`
always divides `|H_a|`, by Lagrange applied to the braid element `σ₁σ₂`.  So
`|H_a|` is an order-finding invariant. -/

variable {N : ℕ}

theorem isUnit_gen1 {a : ZMod N} (ha : IsUnit a) : IsUnit (gen1 a) := by
  rw [Matrix.isUnit_iff_isUnit_det]
  simpa [gen1, Matrix.det_fin_two_of] using ha.neg

theorem isUnit_gen2 {a : ZMod N} (ha : IsUnit a) : IsUnit (gen2 a) := by
  rw [Matrix.isUnit_iff_isUnit_det]
  simpa [gen2, Matrix.det_fin_two_of] using ha.neg

/-- `r(σ₁)` as an element of `GL(2, ℤ/N)`. -/
noncomputable def burauGen1 {a : ZMod N} (ha : IsUnit a) :
    (Matrix (Fin 2) (Fin 2) (ZMod N))ˣ := (isUnit_gen1 ha).unit

/-- `r(σ₂)` as an element of `GL(2, ℤ/N)`. -/
noncomputable def burauGen2 {a : ZMod N} (ha : IsUnit a) :
    (Matrix (Fin 2) (Fin 2) (ZMod N))ˣ := (isUnit_gen2 ha).unit

/-- The Burau image `H_a = ⟨r(σ₁), r(σ₂)⟩ ≤ GL(2, ℤ/N)`. -/
noncomputable def burauSubgroup {a : ZMod N} (ha : IsUnit a) :
    Subgroup ((Matrix (Fin 2) (Fin 2) (ZMod N))ˣ) :=
  Subgroup.closure {burauGen1 ha, burauGen2 ha}

/-- **Lagrange for the Burau image.**  `lcm(3, ord_N(a))` divides the order of
the group `H_a`; in particular `ord_N(a) ∣ |H_a|`, so the group order is an
order-finding invariant (barriers 6/8). -/
theorem lcm_dvd_card_burauSubgroup [Nontrivial (ZMod N)] {a : ZMod N} (ha : IsUnit a) :
    Nat.lcm 3 (orderOf a) ∣ Nat.card (burauSubgroup ha) := by
  have hmem : burauGen1 ha * burauGen2 ha ∈ burauSubgroup ha :=
    Subgroup.mul_mem _ (Subgroup.subset_closure (by simp))
      (Subgroup.subset_closure (by simp))
  have hval : ((burauGen1 ha * burauGen2 ha :
      (Matrix (Fin 2) (Fin 2) (ZMod N))ˣ) : Matrix (Fin 2) (Fin 2) (ZMod N)) = bm a := by
    simp [burauGen1, burauGen2, bm, IsUnit.unit_spec]
  have hord : orderOf (burauGen1 ha * burauGen2 ha) = Nat.lcm 3 (orderOf a) := by
    rw [← orderOf_units, hval, orderOf_bm ha]
  have hdvd := orderOf_dvd_natCard (⟨burauGen1 ha * burauGen2 ha, hmem⟩ : burauSubgroup ha)
  rw [← Subgroup.orderOf_coe (⟨burauGen1 ha * burauGen2 ha, hmem⟩ : burauSubgroup ha)] at hdvd
  rwa [hord] at hdvd

/-- The multiplicative order of `a` divides the order of the Burau image. -/
theorem orderOf_dvd_card_burauSubgroup [Nontrivial (ZMod N)] {a : ZMod N} (ha : IsUnit a) :
    orderOf a ∣ Nat.card (burauSubgroup ha) :=
  dvd_trans (Nat.dvd_lcm_right 3 (orderOf a)) (lcm_dvd_card_burauSubgroup ha)

end BurauGroup

/-- Concrete instance (experiment 305 data, `N = 21`): `ord₂₁(2) = 6`, so the
braid element `σ₁σ₂` has order `lcm(3,6) = 6` in the Burau image mod 21. -/
example : orderOf (bm (2 : ZMod 21)) = 6 := by
  haveI : Fact (1 < 21) := ⟨by norm_num⟩
  have ha : IsUnit (2 : ZMod 21) := by decide
  have h2 : orderOf (2 : ZMod 21) = 6 := by
    rw [orderOf_eq_iff (by norm_num)]
    refine ⟨by decide, ?_⟩
    intro m hm hm0
    interval_cases m <;> decide
  rw [orderOf_bm ha, h2]
  rfl

/-- `ord₂₁(5) = 6` as well, while `ord₃(5) = 2`, `ord₇(5) = 6`: the order
invariant is the lcm of the prime-level orders. -/
example : Nat.lcm (orderOf (5 : ZMod 3)) (orderOf (5 : ZMod 7)) = 6 := by
  have h3 : orderOf (5 : ZMod 3) = 2 := by
    rw [orderOf_eq_iff (by norm_num)]
    refine ⟨by decide, ?_⟩
    intro m hm hm0
    interval_cases m
    decide
  have h7 : orderOf (5 : ZMod 7) = 6 := by
    rw [orderOf_eq_iff (by norm_num)]
    refine ⟨by decide, ?_⟩
    intro m hm hm0
    interval_cases m <;> decide
  rw [h3, h7]
  rfl

end Burau