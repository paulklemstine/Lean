/-
# Round-11 Closures, Part II: the orbit-count (GROUPOID) identity, via Burnside

Formal companion to the round-11 negative-results synthesis
(`29_Round11_Closures.md`, hypothesis **GROUPOID**).

The paper records the orbit-count ("homotopy cardinality") identity
```
C(b) = 1 + φ(N)/ord_N(b) + (p-1)/ord_p(b) + (q-1)/ord_q(b)
```
for the action of `⟨b⟩` on `ℤ/N`, `N = p·q`, and observes that it re-sums exactly
the data that factoring already requires.  Here it is *proved*, in the
division-free form
```
C(b) · n = n + (p-1)·(n/ord_p b) + (q-1)·(n/ord_q b) + (p-1)(q-1),
n = ord_N(b) = lcm (ord_p b) (ord_q b),
```
where `C(b)` is the honest number of orbits of the cyclic group `⟨b⟩ ≤ (ℤ/N)ˣ`
acting on `ℤ/N` (`Round11.groupoid_orbit_identity`).  Note `φ(N) = (p-1)(q-1)`
and the `(p-1)(q-1)` term is exactly the single free orbit `φ(N)/ord_N(b) · n`
… divided out; see `Round11.groupoid_orbit_identity_totient` for the statement
written with `Nat.totient`.

The bridge to Part I is the observation that the **cycle-index fingerprint is a
fixed-point count**:
```
#{x ∈ ℤ/N : b^k x = x} = gcd (b^k - 1) N = F(k)
```
(`Round11.card_fix_eq_fpr`), so Burnside's lemma turns the orbit count into the
average of the fingerprint over a full period.  This is the precise sense in
which the topological/groupoid re-encoding "re-sums the same sealed data": the
orbit count is a linear functional of the very fingerprint whose Möbius spectrum
Part I showed to be supported at the order scale.
-/
import Mathlib
import Combinatorics.Round11CycleIndexFingerprint

namespace Round11

open Finset MulAction

/-! ## Fixed-point counts -/

/-- In a finite field, `c · x = x` has `#F` solutions if `c = 1` and one otherwise. -/
theorem card_fix_field {F : Type*} [Field F] [Fintype F] [DecidableEq F] (c : F) :
    Fintype.card {x : F // c * x = x} = if c = 1 then Fintype.card F else 1 := by
  split
  · next h => subst h; simp
  · next h =>
      have hiff : ∀ x : F, c * x = x ↔ x = 0 := by
        intro x
        refine ⟨fun hx => ?_, by rintro rfl; simp⟩
        have h0 : (c - 1) * x = 0 := by rw [sub_mul, hx, one_mul, sub_self]
        rcases mul_eq_zero.1 h0 with h1 | h1
        · exact absurd (by linear_combination h1 : c = 1) h
        · exact h1
      rw [Fintype.card_congr (Equiv.subtypeEquivRight hiff)]
      simp

/-- **The fingerprint is a fixed-point count.**  For a semiprime `N = p·q`, the
number of `x ∈ ℤ/N` fixed by multiplication by `b^k` is `gcd (b^k - 1) N`. -/
theorem card_fix_eq_fpr {p q b k : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    Fintype.card {x : ZMod (p * q) // (b : ZMod (p * q)) ^ k * x = x} = fpr b (p * q) k := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  set e := ZMod.chineseRemainder hcop with he
  have key : ∀ x : ZMod (p * q), ((b : ZMod (p * q)) ^ k * x = x) ↔
      (((b : ZMod p) ^ k * (e x).1 = (e x).1) ∧ ((b : ZMod q) ^ k * (e x).2 = (e x).2)) := by
    intro x
    exact ⟨fun h => by simpa [Prod.ext_iff] using congrArg e h,
      fun h => e.injective (by simpa [Prod.ext_iff] using h)⟩
  rw [Fintype.card_congr (Equiv.subtypeEquivRight key)]
  rw [Fintype.card_congr (Equiv.subtypeEquiv e.toEquiv (fun _ => Iff.rfl) :
    {x : ZMod (p * q) //
        ((b : ZMod p) ^ k * (e x).1 = (e x).1) ∧ ((b : ZMod q) ^ k * (e x).2 = (e x).2)}
      ≃ {y : ZMod p × ZMod q //
        ((b : ZMod p) ^ k * y.1 = y.1) ∧ ((b : ZMod q) ^ k * y.2 = y.2)})]
  rw [Fintype.card_congr (Equiv.subtypeProdEquivProd
      (p := fun y : ZMod p => (b : ZMod p) ^ k * y = y)
      (q := fun z : ZMod q => (b : ZMod q) ^ k * z = z)),
    Fintype.card_prod, card_fix_field, card_fix_field, ZMod.card, ZMod.card,
    fpr_eq_indicator hp hq hpq hb k]
  rw [if_congr (orderOf_dvd_iff_pow_eq_one (x := (b : ZMod p)) (n := k)).symm rfl rfl,
    if_congr (orderOf_dvd_iff_pow_eq_one (x := (b : ZMod q)) (n := k)).symm rfl rfl]
  rfl

/-! ## Counting multiples -/

/-- The number of multiples of `d` in `[0, n)` is `n / d` when `d ∣ n`. -/
theorem card_multiples_range (n d : ℕ) (hd : 0 < d) (hdn : d ∣ n) :
    ((range n).filter (fun k => d ∣ k)).card = n / d := by
  obtain ⟨m, rfl⟩ := hdn
  rw [Nat.mul_div_cancel_left _ hd, ← Finset.card_range m]
  apply Finset.card_nbij' (fun k => k / d) (fun j => j * d)
  · intro k hk
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_range, card_range] at hk ⊢
    simp only [coe_range, Set.mem_Iio]
    obtain ⟨t, rfl⟩ := hk.2
    rw [Nat.mul_div_cancel_left _ hd]
    exact lt_of_mul_lt_mul_left hk.1 (Nat.zero_le d)
  · intro j hj
    simp only [coe_range, Set.mem_Iio] at hj
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_range, card_range]
    exact ⟨by nlinarith, ⟨j, by ring⟩⟩
  · intro k hk
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_range] at hk
    obtain ⟨t, rfl⟩ := hk.2
    show d * t / d * d = d * t
    rw [Nat.mul_div_cancel_left _ hd]
    ring
  · intro j _
    show j * d / d = j
    exact Nat.mul_div_cancel _ hd

/-! ## The Burnside average of the fingerprint -/

/-- **The period sum of the fingerprint.**  Purely arithmetic form of the
orbit-count identity: summing `F(k) = p^[dp ∣ k] q^[dq ∣ k]` over one full period
`n = lcm dp dq` gives `n + (p-1)(n/dp) + (q-1)(n/dq) + (p-1)(q-1)`. -/
theorem period_sum_indicator (p q dp dq : ℕ) (hp : 1 ≤ p) (hq : 1 ≤ q)
    (hdp : 0 < dp) (hdq : 0 < dq) :
    ∑ k ∈ range (Nat.lcm dp dq), (if dp ∣ k then p else 1) * (if dq ∣ k then q else 1)
      = Nat.lcm dp dq + (p - 1) * (Nat.lcm dp dq / dp) + (q - 1) * (Nat.lcm dp dq / dq)
        + (p - 1) * (q - 1) := by
  obtain ⟨p', rfl⟩ : ∃ p', p = p' + 1 := ⟨p - 1, by omega⟩
  obtain ⟨q', rfl⟩ : ∃ q', q = q' + 1 := ⟨q - 1, by omega⟩
  set n := Nat.lcm dp dq with hn
  have hn0 : 0 < n := Nat.pos_of_ne_zero (fun h => by
    rw [hn, Nat.lcm_eq_zero_iff] at h; omega)
  have hdpn : dp ∣ n := Nat.dvd_lcm_left _ _
  have hdqn : dq ∣ n := Nat.dvd_lcm_right _ _
  have pointwise : ∀ k, (if dp ∣ k then p' + 1 else 1) * (if dq ∣ k then q' + 1 else 1)
      = 1 + p' * (if dp ∣ k then 1 else 0) + q' * (if dq ∣ k then 1 else 0)
        + p' * q' * (if n ∣ k then 1 else 0) := by
    intro k
    have hiff : (dp ∣ k ∧ dq ∣ k) ↔ n ∣ k := ⟨fun h => Nat.lcm_dvd h.1 h.2,
      fun h => ⟨hdpn.trans h, hdqn.trans h⟩⟩
    by_cases h1 : dp ∣ k <;> by_cases h2 : dq ∣ k <;> simp [h1, h2, hiff.symm] <;> ring
  simp only [pointwise, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    Finset.card_range, smul_eq_mul, mul_one]
  rw [show (∑ k ∈ range n, if dp ∣ k then 1 else 0) = ((range n).filter (fun k => dp ∣ k)).card by
        simp [Finset.sum_boole],
      show (∑ k ∈ range n, if dq ∣ k then 1 else 0) = ((range n).filter (fun k => dq ∣ k)).card by
        simp [Finset.sum_boole],
      show (∑ k ∈ range n, if n ∣ k then 1 else 0) = ((range n).filter (fun k => n ∣ k)).card by
        simp [Finset.sum_boole],
      card_multiples_range n dp hdp hdpn, card_multiples_range n dq hdq hdqn,
      card_multiples_range n n hn0 dvd_rfl, Nat.div_self hn0]
  simp

/-! ## The order of `b` modulo a semiprime -/

/-- `ord_N(b) = lcm (ord_p b) (ord_q b)` for `N = p·q` — the CRT decomposition of
the order. -/
theorem orderOf_semiprime {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    orderOf (b : ZMod (p * q)) = Nat.lcm (ordAt b p) (ordAt b q) := by
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
  have hcop : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  set e := ZMod.chineseRemainder hcop with he
  have hmap : e (b : ZMod (p * q)) = ((b : ZMod p), (b : ZMod q)) := by
    simp [Prod.ext_iff]
  have := orderOf_injective (e : ZMod (p * q) →+* ZMod p × ZMod q).toMonoidHom
    e.injective (b : ZMod (p * q))
  rw [show ((e : ZMod (p * q) →+* ZMod p × ZMod q).toMonoidHom (b : ZMod (p * q)))
      = ((b : ZMod p), (b : ZMod q)) from hmap] at this
  rw [← this, Prod.orderOf]
  rfl

/-! ## GROUPOID: the orbit count -/

/-- **The GROUPOID orbit-count identity, division-free.**  Let `N = p·q` be a
semiprime, `b` coprime to `N`, `u` the corresponding unit, and let `C` be the
number of orbits of the cyclic group `⟨u⟩` acting on `ℤ/N`.  Then with
`n = ord_N(b) = lcm (ord_p b) (ord_q b)`,
```
C · n = n + (p-1)·(n / ord_p b) + (q-1)·(n / ord_q b) + (p-1)(q-1).
```
Dividing by `n` this is `C = 1 + (p-1)/ord_p b + (q-1)/ord_q b + φ(N)/ord_N b`,
the identity of the paper. -/
theorem groupoid_orbit_identity {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hcop : Nat.Coprime b (p * q)) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    Nat.card (Quotient (orbitRel (Subgroup.zpowers (ZMod.unitOfCoprime b hcop)) (ZMod (p * q))))
        * Nat.lcm (ordAt b p) (ordAt b q)
      = Nat.lcm (ordAt b p) (ordAt b q)
        + (p - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b p)
        + (q - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b q)
        + (p - 1) * (q - 1) := by
  classical
  haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
  have hbp : ¬ p ∣ b := by
    intro h
    have : p ∣ Nat.gcd b (p * q) := Nat.dvd_gcd h (Dvd.intro q rfl)
    rw [hcop] at this
    exact Nat.Prime.one_lt hp |>.ne' (Nat.dvd_one.1 this)
  have hbq : ¬ q ∣ b := by
    intro h
    have : q ∣ Nat.gcd b (p * q) := Nat.dvd_gcd h (Dvd.intro_left p rfl)
    rw [hcop] at this
    exact Nat.Prime.one_lt hq |>.ne' (Nat.dvd_one.1 this)
  set u := ZMod.unitOfCoprime b hcop with hu
  have hfin : IsOfFinOrder u := isOfFinOrder_of_finite u
  have hcoe : ((u : (ZMod (p * q))ˣ) : ZMod (p * q)) = (b : ZMod (p * q)) :=
    ZMod.coe_unitOfCoprime b hcop
  have horder : orderOf u = Nat.lcm (ordAt b p) (ordAt b q) := by
    rw [← orderOf_units, hcoe, orderOf_semiprime hp hq hpq]
  haveI : Fintype (Quotient (orbitRel (↥(Subgroup.zpowers u)) (ZMod (p * q)))) :=
    Fintype.ofFinite _
  -- Burnside's lemma
  have hburn := MulAction.sum_card_fixedBy_eq_card_orbits_mul_card_group
    (↥(Subgroup.zpowers u)) (ZMod (p * q))
  -- the sum of fixed-point counts is the period sum of the fingerprint
  have hsum : ∑ a : ↥(Subgroup.zpowers u), Fintype.card (fixedBy (ZMod (p * q)) a)
      = ∑ k ∈ range (orderOf u), fpr b (p * q) k := by
    rw [← Equiv.sum_comp (finEquivZPowers hfin)
      (fun a => Fintype.card (fixedBy (ZMod (p * q)) a)),
      ← Fin.sum_univ_eq_sum_range (fun k => fpr b (p * q) k) (orderOf u)]
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [finEquivZPowers_apply hfin]
    rw [← card_fix_eq_fpr (k := (i : ℕ)) hp hq hpq hb]
    refine Fintype.card_congr (Equiv.subtypeEquivRight (fun x => ?_))
    show ((⟨u ^ (i : ℕ), _⟩ : Subgroup.zpowers u) • x = x) ↔ _
    simp [Units.smul_def, hu, ZMod.coe_unitOfCoprime]
  -- evaluate the period sum
  have hperiod : ∑ k ∈ range (orderOf u), fpr b (p * q) k
      = Nat.lcm (ordAt b p) (ordAt b q)
        + (p - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b p)
        + (q - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b q)
        + (p - 1) * (q - 1) := by
    have hcongr : ∀ k ∈ range (Nat.lcm (ordAt b p) (ordAt b q)), fpr b (p * q) k
        = (if ordAt b p ∣ k then p else 1) * (if ordAt b q ∣ k then q else 1) :=
      fun k _ => fpr_eq_indicator hp hq hpq hb k
    rw [horder, Finset.sum_congr rfl hcongr]
    exact period_sum_indicator p q (ordAt b p) (ordAt b q) hp.pos hq.pos
      (ordAt_pos hp hbp) (ordAt_pos hq hbq)
  rw [hsum, hperiod, Fintype.card_zpowers, horder] at hburn
  rw [Nat.card_eq_fintype_card]
  exact hburn.symm

/-- **The topological re-encoding leaks nothing (balanced case).**  When the two
local orders agree, `ord_p b = ord_q b = d`, the orbit count collapses to
`C · d = d + N - 1`: it is a function of `N` and `ord_N(b) = d` **alone**, and is
therefore independent of the factorization of `N`.  Burnside re-sums the same
sealed data — this is the exact sense in which GROUPOID is closed. -/
theorem groupoid_balanced_no_leak {p q b d : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hcop : Nat.Coprime b (p * q))
    (hdp : ordAt b p = d) (hdq : ordAt b q = d) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    Nat.card (Quotient (orbitRel (Subgroup.zpowers (ZMod.unitOfCoprime b hcop))
        (ZMod (p * q)))) * d = d + (p * q - 1) := by
  have hd0 : 0 < d := by
    rw [← hdp]
    refine ordAt_pos hp (fun hdvd => ?_)
    have : p ∣ Nat.gcd b (p * q) := Nat.dvd_gcd hdvd (Dvd.intro q rfl)
    rw [hcop] at this
    exact hp.one_lt.ne' (Nat.dvd_one.1 this)
  have hmain := groupoid_orbit_identity hp hq hpq hb hcop
  rw [hdp, hdq, Nat.lcm_self, Nat.div_self hd0, mul_one, mul_one] at hmain
  rw [hmain]
  obtain ⟨p', rfl⟩ : ∃ p', p = p' + 1 := ⟨p - 1, by have := hp.two_le; omega⟩
  obtain ⟨q', rfl⟩ : ∃ q', q = q' + 1 := ⟨q - 1, by have := hq.two_le; omega⟩
  have : (p' + 1) * (q' + 1) = p' * q' + p' + q' + 1 := by ring
  simp only [Nat.add_sub_cancel, this]
  omega

/-- Arithmetic rearrangement: the orbit-count identity is an **affine hint** in
`p` and `q` with coefficients `n/d_p - 1` and `n/d_q - 1`. -/
theorem affine_rearrange {C n A B p q : ℕ} (hp : 1 ≤ p) (hq : 1 ≤ q)
    (h : C * n = n + (p - 1) * A + (q - 1) * B + (p - 1) * (q - 1)) :
    ((A : ℤ) - 1) * p + ((B : ℤ) - 1) * q
      = (C : ℤ) * n - n + A + B - (p : ℤ) * q - 1 := by
  obtain ⟨p', rfl⟩ : ∃ p', p = p' + 1 := ⟨p - 1, by omega⟩
  obtain ⟨q', rfl⟩ : ∃ q', q = q' + 1 := ⟨q - 1, by omega⟩
  simp only [Nat.add_sub_cancel] at h
  have hZ : (C : ℤ) * n = (n : ℤ) + p' * A + q' * B + p' * q' := by exact_mod_cast h
  push_cast
  linarith [hZ]

/-- **The orbit count is an affine hint.**  Combining the GROUPOID identity with
`(p-1)(q-1) = N - p - q + 1` turns the orbit count `C` into the observation
```
(n/d_p - 1)·p + (n/d_q - 1)·q = C·n - n + n/d_p + n/d_q - N - 1 .
```
With `Round11.weighted_sum_prod_inversion` this pins the factorization to at most
two candidates — *unless* both coefficients vanish, which is exactly the balanced
case `d_p = d_q` of `Round11.groupoid_balanced_no_leak`.  So the topological
re-encoding is a factoring oracle precisely when it is not computable without the
factorization. -/
theorem groupoid_affine_hint {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hcop : Nat.Coprime b (p * q)) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    (((Nat.lcm (ordAt b p) (ordAt b q) / ordAt b p : ℕ) : ℤ) - 1) * (p : ℤ)
        + (((Nat.lcm (ordAt b p) (ordAt b q) / ordAt b q : ℕ) : ℤ) - 1) * (q : ℤ)
      = (Nat.card (Quotient (orbitRel (Subgroup.zpowers (ZMod.unitOfCoprime b hcop))
            (ZMod (p * q)))) : ℤ) * (Nat.lcm (ordAt b p) (ordAt b q) : ℤ)
        - (Nat.lcm (ordAt b p) (ordAt b q) : ℤ)
        + ((Nat.lcm (ordAt b p) (ordAt b q) / ordAt b p : ℕ) : ℤ)
        + ((Nat.lcm (ordAt b p) (ordAt b q) / ordAt b q : ℕ) : ℤ)
        - (p : ℤ) * (q : ℤ) - 1 :=
  affine_rearrange hp.pos hq.pos (groupoid_orbit_identity hp hq hpq hb hcop)

/-- The same identity with Euler's totient in place of `(p-1)(q-1)`. -/
theorem groupoid_orbit_identity_totient {p q b : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≠ q)
    (hb : 1 ≤ b) (hcop : Nat.Coprime b (p * q)) :
    haveI : NeZero (p * q) := ⟨Nat.mul_ne_zero hp.ne_zero hq.ne_zero⟩
    Nat.card (Quotient (orbitRel (Subgroup.zpowers (ZMod.unitOfCoprime b hcop)) (ZMod (p * q))))
        * Nat.lcm (ordAt b p) (ordAt b q)
      = Nat.lcm (ordAt b p) (ordAt b q)
        + (p - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b p)
        + (q - 1) * (Nat.lcm (ordAt b p) (ordAt b q) / ordAt b q)
        + Nat.totient (p * q) := by
  have hcopn : Nat.Coprime p q := (Nat.coprime_primes hp hq).2 hpq
  have : Nat.totient (p * q) = (p - 1) * (q - 1) := by
    rw [Nat.totient_mul hcopn, Nat.totient_prime hp, Nat.totient_prime hq]
  rw [this]
  exact groupoid_orbit_identity hp hq hpq hb hcop

end Round11