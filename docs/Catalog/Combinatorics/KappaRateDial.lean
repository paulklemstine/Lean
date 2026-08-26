/-
# The κ rate–dial: divisibility patterns are a rate dial, not a position dial

This file formalises, for an arbitrary finite set `P` of primes, the *divisibility cell
decomposition* of the integers and proves the two complementary statements that were
isolated empirically in the `κ`-composition layer:

* **Rate dial.** The number of integers in one full period `L = ∏_{p ∈ P} p` lying in the
  cell prescribed by a sign pattern `σ : ℕ → Bool` (`p ∣ v` exactly when `σ p = true`) is
  *exactly* the multiplicative quantity
  `κ(σ) = ∏_{p ∈ P} (if σ p then 1 else p - 1)`  (`card_period_eq_kappaRaw`).
  So the divisibility pattern rescales the *rate* by a completely factorised amount.

* **Not a position dial.** The very same count is *exactly* reproduced in every translated
  period block (`cellCount_block`), so counting over `m` periods is exactly `m · κ(σ)`
  (`cellCount_period_multiple`): the drift in the block index `t` is identically zero, and
  the ratio of two cell rates is independent of the number of periods observed
  (`cellCount_ratio_scale_invariant`) — the law is scale-carrying.

Structural consequences proved here:

* the extremal (all-cleared) cell is exactly the set of totatives, and its rate is
  `Nat.totient L` (`kappaRaw_all_false_eq_totient`, `inCell_all_false_iff_coprime`);
* `κ(σ) ≤ Nat.totient L` for every pattern, with the *sharp* equality criterion
  (`kappaRaw_eq_totient_iff`);
* `1 ≤ κ(σ)` with the dual sharp criterion (`kappaRaw_eq_one_iff`), so the full spread of
  the dial is exactly the factor `Nat.totient L` (`kappa_spread`);
* the prime `2` is a **dead coordinate** of the dial: flipping `σ` at `2` never changes the
  rate (`kappaRaw_flip_two`) — the modulation is carried by the odd primes only;
* the cells tile a period: `∑_{T ⊆ P} κ(σ_T) = L` (`sum_kappaRaw_powerset`).

## Lab notes (experimental data feeding these statements)

For `P = {2,3,5,7}`, `L = 210`:

| pattern (dividing primes) | κ | κ/(L/2^4) |
| --- | --- | --- |
| ∅ (all cleared)      | 48 | 3.657 |
| {2}                  | 48 | 3.657 |
| {7}                  |  8 | 0.610 |
| {2,3,5}              |  6 | 0.457 |
| {2,3,5,7}            |  1 | 0.076 |

The empirical observation that the *top* and *bottom* cells reproduce across independent
samples, while the positional profile stays flat to within measurement noise, is here
upgraded to an exact theorem: the positional profile is *identically* flat, and the top /
bottom cells are `∅` and `P` up to the dead `2`-coordinate.
-/

import Mathlib

open Finset

namespace KappaDial

/-! ## Definitions -/

/-- `InCell P σ v` says that `v` realises the divisibility pattern `σ` on the prime set `P`:
for each `p ∈ P` we have `p ∣ v` exactly when `σ p = true`. -/
def InCell (P : Finset ℕ) (σ : ℕ → Bool) (v : ℕ) : Prop := ∀ p ∈ P, (p ∣ v ↔ σ p = true)

instance (P : Finset ℕ) (σ : ℕ → Bool) : DecidablePred (InCell P σ) := by
  intro v; unfold InCell; infer_instance

/-- The period of the cell decomposition: the (squarefree) product of the primes in `P`. -/
def modulus (P : Finset ℕ) : ℕ := ∏ p ∈ P, p

/-- The raw rate `κ(σ)` of the cell `σ`: the predicted number of representatives per period. -/
def kappaRaw (P : Finset ℕ) (σ : ℕ → Bool) : ℕ := ∏ p ∈ P, (if σ p then 1 else p - 1)

/-- The number of members of the cell `σ` in the window `[a, b)`. -/
def cellCount (P : Finset ℕ) (σ : ℕ → Bool) (a b : ℕ) : ℕ :=
  ((Finset.Ico a b).filter (InCell P σ)).card

/-! ## Elementary properties of the modulus -/

lemma modulus_pos (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) : 0 < modulus P :=
  Finset.prod_pos fun p hp => (hP p hp).pos

lemma dvd_modulus (P : Finset ℕ) {p : ℕ} (hp : p ∈ P) : p ∣ modulus P :=
  Finset.dvd_prod_of_mem _ hp

/-! ## Periodicity: the cell predicate only sees `v` modulo the period -/

lemma inCell_periodic (P : Finset ℕ) (σ : ℕ → Bool) {L : ℕ} (hL : ∀ p ∈ P, p ∣ L)
    (v w : ℕ) (h : v % L = w % L) : InCell P σ v ↔ InCell P σ w := by
  unfold InCell
  refine forall_congr' fun p => imp_congr_right fun hp => ?_
  have e : v % p = w % p := by
    rw [← Nat.mod_mod_of_dvd v (hL p hp), ← Nat.mod_mod_of_dvd w (hL p hp), h]
  have hd : p ∣ v ↔ p ∣ w := by
    rw [Nat.dvd_iff_mod_eq_zero, Nat.dvd_iff_mod_eq_zero, e]
  rw [hd]

lemma inCell_add_mul (P : Finset ℕ) (σ : ℕ → Bool) {L : ℕ} (hL : ∀ p ∈ P, p ∣ L)
    (v m : ℕ) : InCell P σ (v + m * L) ↔ InCell P σ v := by
  unfold InCell
  refine forall_congr' fun p => imp_congr_right fun hp => ?_
  have h := hL p hp
  have hd : p ∣ v + m * L ↔ p ∣ v := by
    constructor
    · intro h2
      exact (Nat.dvd_add_right (Dvd.dvd.mul_left h m)).mp (by rwa [Nat.add_comm] at h2)
    · intro h2; exact Nat.dvd_add h2 (Dvd.dvd.mul_left h m)
  rw [hd]

/-! ## The Chinese-remainder counting lemma -/

/-- Counting a conjunction of a `q`-periodic and an `L`-periodic condition over a full
period `q * L` of coprime moduli factorises as a product of the two individual counts. -/
lemma count_mul_coprime (q L : ℕ) (hq : 0 < q) (hL : 0 < L) (h : Nat.Coprime q L)
    (A B : ℕ → Prop) [DecidablePred A] [DecidablePred B]
    (hA : ∀ v w, v % q = w % q → (A v ↔ A w))
    (hB : ∀ v w, v % L = w % L → (B v ↔ B w)) :
    ((range (q * L)).filter (fun v => A v ∧ B v)).card
      = ((range q).filter A).card * ((range L).filter B).card := by
  rw [← Finset.card_product]
  refine Finset.card_nbij (fun v => (v % q, v % L)) ?_ ?_ ?_
  · intro v hv
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range, Finset.mem_product] at hv ⊢
    obtain ⟨_, hA', hB'⟩ := hv
    exact ⟨⟨Nat.mod_lt _ hq, (hA (v % q) v (Nat.mod_mod_of_dvd _ dvd_rfl)).mpr hA'⟩,
      ⟨Nat.mod_lt _ hL, (hB (v % L) v (Nat.mod_mod_of_dvd _ dvd_rfl)).mpr hB'⟩⟩
  · intro v hv w hw hvw
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range] at hv hw
    simp only [Prod.mk.injEq] at hvw
    have hmod : v ≡ w [MOD q * L] :=
      (Nat.modEq_and_modEq_iff_modEq_mul h).mp ⟨hvw.1, hvw.2⟩
    have h1 := Nat.mod_eq_of_lt hv.1
    have h2 := Nat.mod_eq_of_lt hw.1
    unfold Nat.ModEq at hmod
    omega
  · intro x hx
    simp only [Finset.mem_coe, Finset.mem_product, Finset.mem_filter, Finset.mem_range] at hx
    obtain ⟨⟨hx1, hA'⟩, ⟨hx2, hB'⟩⟩ := hx
    obtain ⟨k, hk1, hk2⟩ := Nat.chineseRemainder h x.1 x.2
    have e1 : k % (q * L) % q = x.1 := by
      rw [Nat.mod_mod_of_dvd k ⟨L, rfl⟩, hk1, Nat.mod_eq_of_lt hx1]
    have e2 : k % (q * L) % L = x.2 := by
      rw [Nat.mod_mod_of_dvd k ⟨q, by ring⟩, hk2, Nat.mod_eq_of_lt hx2]
    refine ⟨k % (q * L), ?_, ?_⟩
    · simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range]
      refine ⟨Nat.mod_lt _ (by positivity), ?_, ?_⟩
      · exact (hA _ x.1 (by rw [e1, Nat.mod_eq_of_lt hx1])).mpr hA'
      · exact (hB _ x.2 (by rw [e2, Nat.mod_eq_of_lt hx2])).mpr hB'
    · simp [e1, e2]

/-- One prime coordinate of the dial: among a full period `q` there is exactly one multiple
of `q` and exactly `q - 1` non-multiples. -/
lemma card_range_dvd_cell (q : ℕ) (hq : 0 < q) (b : Bool) :
    ((range q).filter (fun v => (q ∣ v ↔ b = true))).card = if b then 1 else q - 1 := by
  cases b with
  | true =>
    have h : (range q).filter (fun v => (q ∣ v ↔ (true : Bool) = true)) = {0} := by
      ext v
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton, iff_true]
      constructor
      · rintro ⟨h1, h2⟩; exact Nat.eq_zero_of_dvd_of_lt h2 h1
      · rintro rfl; exact ⟨hq, dvd_zero q⟩
    rw [h]; simp
  | false =>
    have h : (range q).filter (fun v => (q ∣ v ↔ (false : Bool) = true)) = (range q).erase 0 := by
      ext v
      simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_erase, Bool.false_eq_true,
        iff_false]
      constructor
      · rintro ⟨h1, h2⟩; exact ⟨fun hv => h2 (hv ▸ dvd_zero q), h1⟩
      · rintro ⟨h1, h2⟩; exact ⟨h2, fun hv => h1 (Nat.eq_zero_of_dvd_of_lt hv h2)⟩
    rw [h, Finset.card_erase_of_mem (Finset.mem_range.mpr hq), Finset.card_range]
    simp

/-! ## The rate law: exact cell counts over one period -/

/-- **The κ composition law.** Over one full period the cell of a divisibility pattern `σ`
contains exactly `κ(σ) = ∏_{p ∈ P} (if σ p then 1 else p - 1)` residues. -/
theorem card_period_eq_kappaRaw (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    ((range (modulus P)).filter (InCell P σ)).card = kappaRaw P σ := by
  classical
  induction P using Finset.induction_on with
  | empty =>
      have h : (range (modulus (∅ : Finset ℕ))).filter (InCell ∅ σ) = {0} := by
        simp only [modulus, Finset.prod_empty]
        rw [Finset.filter_true_of_mem (fun x _ => by intro p hp; simp at hp)]
        rfl
      rw [h]; simp [kappaRaw]
  | insert q P' hq ih =>
      have hqp : q.Prime := hP q (Finset.mem_insert_self q P')
      have hP' : ∀ p ∈ P', p.Prime := fun p hp => hP p (Finset.mem_insert_of_mem hp)
      have hmod : modulus (insert q P') = q * modulus P' := by
        simp [modulus, Finset.prod_insert hq]
      have hcop : Nat.Coprime q (modulus P') :=
        Nat.Coprime.prod_right fun p hp =>
          (Nat.coprime_primes hqp (hP' p hp)).mpr (fun h => hq (h ▸ hp))
      have hL'pos : 0 < modulus P' := modulus_pos P' hP'
      have hfilter : ∀ v, InCell (insert q P') σ v ↔ ((q ∣ v ↔ σ q = true) ∧ InCell P' σ v) := by
        intro v; unfold InCell; simp
      rw [hmod, Finset.filter_congr (fun v _ => (hfilter v)),
        count_mul_coprime q (modulus P') hqp.pos hL'pos hcop _ _
          (fun v w hvw => by
            have hd : q ∣ v ↔ q ∣ w := by
              rw [Nat.dvd_iff_mod_eq_zero, Nat.dvd_iff_mod_eq_zero, hvw]
            rw [hd])
          (fun v w hvw =>
            inCell_periodic P' σ (fun p hp => Finset.dvd_prod_of_mem _ hp) v w hvw),
        card_range_dvd_cell q hqp.pos (σ q), ih hP']
      simp [kappaRaw, Finset.prod_insert hq]

lemma cellCount_zero_modulus (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    cellCount P σ 0 (modulus P) = kappaRaw P σ := by
  rw [← card_period_eq_kappaRaw P hP σ, cellCount, Finset.range_eq_Ico]

/-! ## The positional law: exact flatness in the block index -/

lemma cellCount_split (P : Finset ℕ) (σ : ℕ → Bool) (a b c : ℕ) (hab : a ≤ b) (hbc : b ≤ c) :
    cellCount P σ a c = cellCount P σ a b + cellCount P σ b c := by
  unfold cellCount
  rw [← Finset.Ico_union_Ico_eq_Ico hab hbc, Finset.filter_union,
    Finset.card_union_of_disjoint]
  exact Finset.disjoint_filter_filter (Finset.Ico_disjoint_Ico_consecutive a b c)

/-- **Exact positional flatness.** Every translated period block carries exactly the same
number of members of the cell: the profile in the block index has *zero* drift. -/
theorem cellCount_block (P : Finset ℕ) (σ : ℕ → Bool) {L : ℕ} (hL : ∀ p ∈ P, p ∣ L) (m : ℕ) :
    cellCount P σ (m * L) (m * L + L) = cellCount P σ 0 L := by
  unfold cellCount
  refine Finset.card_nbij' (fun v => v - m * L) (fun v => v + m * L) ?_ ?_ ?_ ?_
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hv ⊢
    obtain ⟨⟨h1, h2⟩, h3⟩ := hv
    refine ⟨⟨Nat.zero_le _, by omega⟩, ?_⟩
    have e : v - m * L + m * L = v := by omega
    rw [← inCell_add_mul P σ hL (v - m * L) m, e]; exact h3
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hv ⊢
    obtain ⟨⟨h1, h2⟩, h3⟩ := hv
    exact ⟨⟨by omega, by omega⟩, (inCell_add_mul P σ hL v m).mpr h3⟩
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hv
    dsimp only
    omega
  · intro v hv
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_Ico] at hv
    dsimp only
    omega

/-- **Scale-carrying rate law.** Counting the cell over `m` whole periods gives exactly
`m · κ(σ)`: the rate transfers unchanged across scales, with no positional correction. -/
theorem cellCount_period_multiple (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool)
    (m : ℕ) : cellCount P σ 0 (m * modulus P) = m * kappaRaw P σ := by
  induction m with
  | zero => simp [cellCount]
  | succ n ih =>
      have hle1 : 0 ≤ n * modulus P := Nat.zero_le _
      have hle2 : n * modulus P ≤ (n + 1) * modulus P := by
        exact Nat.mul_le_mul_right _ (by omega)
      rw [cellCount_split P σ 0 (n * modulus P) ((n + 1) * modulus P) hle1 hle2, ih]
      have e : (n + 1) * modulus P = n * modulus P + modulus P := by ring
      rw [e, cellCount_block P σ (fun p hp => dvd_modulus P hp) n,
        cellCount_zero_modulus P hP σ]
      ring

/-- The ratio of two cell rates is *independent of the observation window* (any whole number
of periods): the composition layer is scale-carrying. -/
theorem cellCount_ratio_scale_invariant (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime)
    (σ τ : ℕ → Bool) (m : ℕ) :
    cellCount P σ 0 (m * modulus P) * kappaRaw P τ
      = cellCount P τ 0 (m * modulus P) * kappaRaw P σ := by
  rw [cellCount_period_multiple P hP σ m, cellCount_period_multiple P hP τ m]
  ring

/-! ## Structure of the dial: extremes, totatives, and the dead 2-coordinate -/

lemma one_le_kappa_term {p : ℕ} (hp : p.Prime) (b : Bool) : 1 ≤ (if b then 1 else p - 1) := by
  have := hp.two_le
  cases b with
  | true => simp
  | false => simp only [Bool.false_eq_true, if_false]; omega

lemma kappa_term_le {p : ℕ} (hp : p.Prime) (b : Bool) : (if b then 1 else p - 1) ≤ p - 1 := by
  have := hp.two_le
  cases b with
  | true => simp only [if_true]; omega
  | false => simp

/-- The all-cleared cell consists exactly of the residues coprime to the period. -/
theorem inCell_all_false_iff_coprime (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (v : ℕ) :
    InCell P (fun _ => false) v ↔ Nat.Coprime v (modulus P) := by
  unfold InCell modulus
  constructor
  · intro h
    refine Nat.Coprime.prod_right fun p hp => ?_
    exact ((Nat.Prime.coprime_iff_not_dvd (hP p hp)).mpr (by simpa using (h p hp))).symm
  · intro h p hp
    simp only [Bool.false_eq_true, iff_false]
    intro hdvd
    have hcop : Nat.Coprime v p :=
      Nat.Coprime.coprime_dvd_right (Finset.dvd_prod_of_mem _ hp) h
    have : p ∣ Nat.gcd v p := Nat.dvd_gcd hdvd dvd_rfl
    rw [hcop] at this
    exact Nat.Prime.one_lt (hP p hp) |>.ne' (Nat.le_antisymm (Nat.le_of_dvd one_pos this)
      (hP p hp).one_lt.le) |>.elim
  
/-- The maximal rate is Euler's totient of the period. -/
theorem kappaRaw_all_false_eq_totient (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    kappaRaw P (fun _ => false) = Nat.totient (modulus P) := by
  classical
  induction P using Finset.induction_on with
  | empty => simp [kappaRaw, modulus]
  | insert q P' hq ih =>
      have hqp : q.Prime := hP q (Finset.mem_insert_self q P')
      have hP' : ∀ p ∈ P', p.Prime := fun p hp => hP p (Finset.mem_insert_of_mem hp)
      have hcop : Nat.Coprime q (modulus P') :=
        Nat.Coprime.prod_right fun p hp =>
          (Nat.coprime_primes hqp (hP' p hp)).mpr (fun h => hq (h ▸ hp))
      have hmod : modulus (insert q P') = q * modulus P' := by
        simp [modulus, Finset.prod_insert hq]
      rw [kappaRaw, Finset.prod_insert hq, hmod, Nat.totient_mul hcop, Nat.totient_prime hqp,
        ← kappaRaw, ih hP']
      simp

/-- Every cell rate is at most the totient of the period. -/
theorem kappaRaw_le_totient (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    kappaRaw P σ ≤ Nat.totient (modulus P) := by
  rw [← kappaRaw_all_false_eq_totient P hP]
  refine Finset.prod_le_prod' fun p hp => ?_
  simpa using kappa_term_le (hP p hp) (σ p)

/-- Every cell is nonempty per period: the rate is at least one. -/
theorem one_le_kappaRaw (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    1 ≤ kappaRaw P σ := by
  rw [kappaRaw]
  exact Finset.one_le_prod' fun p hp => one_le_kappa_term (hP p hp) (σ p)

/-- **The 2-coordinate of the dial is dead**: flipping the pattern at the prime `2` never
changes the rate, because `2 - 1 = 1`. All modulation is carried by the odd primes. -/
theorem kappaRaw_flip_two (P : Finset ℕ) (σ : ℕ → Bool) (b : Bool) :
    kappaRaw P (fun p => if p = 2 then b else σ p) = kappaRaw P σ := by
  classical
  unfold kappaRaw
  refine Finset.prod_congr rfl fun p hp => ?_
  by_cases h : p = 2
  · subst h
    cases b <;> cases hσ : σ 2 <;> simp
  · simp [h]

/-- Sharp criterion for attaining the maximal rate. -/
theorem kappaRaw_eq_totient_iff (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    kappaRaw P σ = Nat.totient (modulus P) ↔ ∀ p ∈ P, p ≠ 2 → σ p = false := by
  rw [← kappaRaw_all_false_eq_totient P hP]
  constructor
  · intro heq p hp hp2
    by_contra hne
    have hst : σ p = true := by
      cases hb : σ p with
      | true => rfl
      | false => exact absurd hb hne
    have hlt : kappaRaw P σ < kappaRaw P (fun _ => false) := by
      unfold kappaRaw
      refine Finset.prod_lt_prod (fun i hi => one_le_kappa_term (hP i hi) (σ i))
        (fun i hi => by simpa using kappa_term_le (hP i hi) (σ i)) ⟨p, hp, ?_⟩
      have := (hP p hp).two_le
      have hp3 : 3 ≤ p := by
        rcases Nat.lt_or_ge p 3 with h | h
        · omega
        · exact h
      simp only [hst, if_pos, Bool.false_eq_true, if_false]
      omega
    omega
  · intro h
    unfold kappaRaw
    refine Finset.prod_congr rfl fun p hp => ?_
    by_cases hp2 : p = 2
    · subst hp2
      cases hb : σ 2 <;> simp
    · rw [h p hp hp2]

/-- Sharp criterion for attaining the minimal rate. -/
theorem kappaRaw_eq_one_iff (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    kappaRaw P σ = 1 ↔ ∀ p ∈ P, p ≠ 2 → σ p = true := by
  constructor
  · intro heq p hp hp2
    by_contra hne
    have hsf : σ p = false := by
      cases hb : σ p with
      | true => exact absurd hb hne
      | false => rfl
    have hp3 : 3 ≤ p := by
      have := (hP p hp).two_le
      rcases Nat.lt_or_ge p 3 with h | h
      · omega
      · exact h
    have hdvd : (if σ p then 1 else p - 1) ∣ kappaRaw P σ :=
      Finset.dvd_prod_of_mem _ hp
    rw [heq] at hdvd
    have : p - 1 ≤ 1 := Nat.le_of_dvd one_pos (by simpa [hsf] using hdvd)
    omega
  · intro h
    unfold kappaRaw
    rw [Finset.prod_eq_one]
    intro p hp
    by_cases hp2 : p = 2
    · subst hp2; cases hb : σ 2 <;> simp
    · rw [h p hp hp2]; simp

/-- **The spread of the dial.** The largest cell rate divided by the smallest is exactly
`Nat.totient L`, and both extremes are attained. -/
theorem kappa_spread (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    kappaRaw P (fun _ => true) = 1 ∧
    kappaRaw P (fun _ => false) = Nat.totient (modulus P) ∧
    ∀ σ : ℕ → Bool, 1 ≤ kappaRaw P σ ∧ kappaRaw P σ ≤ Nat.totient (modulus P) := by
  refine ⟨(kappaRaw_eq_one_iff P hP _).mpr (fun p _ _ => rfl),
    kappaRaw_all_false_eq_totient P hP,
    fun σ => ⟨one_le_kappaRaw P hP σ, kappaRaw_le_totient P hP σ⟩⟩

/-! ## Closure: the cells tile a period -/

/-- The rate of the cell indexed by the set `T ⊆ P` of primes required to divide `v` is the
product of `p - 1` over the *cleared* primes `P \ T`. -/
lemma kappaRaw_indicator (P T : Finset ℕ) (hT : T ⊆ P) :
    kappaRaw P (fun p => decide (p ∈ T)) = ∏ p ∈ P \ T, (p - 1) := by
  classical
  rw [kappaRaw, ← Finset.prod_filter_mul_prod_filter_not P (fun p => p ∈ T)]
  have h1 : P.filter (fun p => p ∈ T) = T := by
    ext x; simp only [Finset.mem_filter]
    exact ⟨fun h => h.2, fun h => ⟨hT h, h⟩⟩
  have h2 : P.filter (fun p => ¬ p ∈ T) = P \ T := by
    ext x; simp [Finset.mem_sdiff]
  rw [h1, h2]
  have e1 : ∏ x ∈ T, (if decide (x ∈ T) then 1 else x - 1) = 1 :=
    Finset.prod_eq_one (fun x hx => by simp [hx])
  have e2 : ∏ x ∈ P \ T, (if decide (x ∈ T) then 1 else x - 1) = ∏ x ∈ P \ T, (x - 1) :=
    Finset.prod_congr rfl (fun x hx => by simp [(Finset.mem_sdiff.mp hx).2])
  rw [e1, e2, one_mul]

/-- The cell rates over all `2^{|P|}` divisibility patterns sum to the period: the cells
form an exact partition of one period. -/
theorem sum_kappaRaw_powerset (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    ∑ T ∈ P.powerset, kappaRaw P (fun p => decide (p ∈ T)) = modulus P := by
  classical
  have key : ∀ T ∈ P.powerset,
      kappaRaw P (fun p => decide (p ∈ T)) = (∏ i ∈ T, (1 : ℕ)) * ∏ i ∈ P \ T, (i - 1) := by
    intro T hT
    rw [Finset.prod_const_one, one_mul, kappaRaw_indicator P T (Finset.mem_powerset.mp hT)]
  rw [Finset.sum_congr rfl key, ← Finset.prod_add]
  unfold modulus
  refine Finset.prod_congr rfl fun p hp => ?_
  have := (hP p hp).two_le
  omega

/-! ## The dichotomy theorem -/

/-- **Divisibility is a rate dial, not a position dial.**

For any finite set `P` of primes with period `L`:
1. *(no positional signal)* every period block, at every offset `m`, contains exactly the
   same number of cell members, and counting over `m` periods is exactly `m · κ(σ)` —
   the positional profile is identically flat with zero drift;
2. *(a genuine rate signal)* as soon as `P` contains an odd prime, the rate `κ` really does
   vary between cells, by the full factor `Nat.totient L ≥ 2`.
-/
theorem rate_dial_not_position_dial (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime)
    (hodd : ∃ p ∈ P, p ≠ 2) :
    (∀ (σ : ℕ → Bool) (m : ℕ),
        cellCount P σ (m * modulus P) (m * modulus P + modulus P) = cellCount P σ 0 (modulus P)) ∧
    (∀ (σ : ℕ → Bool) (m : ℕ), cellCount P σ 0 (m * modulus P) = m * kappaRaw P σ) ∧
    (2 ≤ Nat.totient (modulus P) ∧
      kappaRaw P (fun _ => false) = Nat.totient (modulus P) * kappaRaw P (fun _ => true)) := by
  refine ⟨fun σ m => cellCount_block P σ (fun p hp => dvd_modulus P hp) m,
    fun σ m => cellCount_period_multiple P hP σ m, ?_, ?_⟩
  · obtain ⟨p, hp, hp2⟩ := hodd
    have hp3 : 3 ≤ p := by
      have := (hP p hp).two_le
      rcases Nat.lt_or_ge p 3 with h | h
      · omega
      · exact h
    have hdvd : (p - 1) ∣ kappaRaw P (fun _ => false) := by
      have := Finset.dvd_prod_of_mem (fun p => if (false : Bool) then 1 else p - 1) hp
      simpa [kappaRaw] using this
    have hpos : 0 < kappaRaw P (fun _ => false) := one_le_kappaRaw P hP _
    have : p - 1 ≤ kappaRaw P (fun _ => false) := Nat.le_of_dvd hpos hdvd
    rw [kappaRaw_all_false_eq_totient P hP] at this
    omega
  · rw [(kappaRaw_eq_one_iff P hP (fun _ => true)).mpr (fun p _ _ => rfl),
      kappaRaw_all_false_eq_totient P hP, mul_one]

/-! ## Worked instance: `P = {2,3,5,7}`, `L = 210` -/

section Example

/-- The prime set of the worked example. -/
def P4 : Finset ℕ := {2, 3, 5, 7}

lemma P4_prime : ∀ p ∈ P4, p.Prime := by decide

lemma modulus_P4 : modulus P4 = 210 := by decide

/-- The all-cleared (top) cell of the worked example has rate `48 = φ(210)`. -/
theorem kappa_P4_all_false : kappaRaw P4 (fun _ => false) = 48 := by decide

/-- The cell `2 ∣ v ∧ 3 ∣ v ∧ 5 ∣ v ∧ 7 ∤ v` has rate `6`. -/
theorem kappa_P4_top : kappaRaw P4 (fun p => decide (p ≠ 7)) = 6 := by decide

/-- The all-dividing (bottom) cell has rate `1`. -/
theorem kappa_P4_all_true : kappaRaw P4 (fun _ => true) = 1 := by decide

/-- The dead 2-coordinate, concretely: switching the parity requirement changes nothing. -/
theorem kappa_P4_dead_two : kappaRaw P4 (fun p => decide (p = 2)) = 48 := by decide

/-- The exact count of the all-cleared cell in `[0, 2100)` is `480`, an instance of the
scale-carrying rate law. -/
theorem cellCount_P4_ten_periods :
    cellCount P4 (fun _ => false) 0 2100 = 480 := by
  have h : (2100 : ℕ) = 10 * modulus P4 := by rw [modulus_P4]
  rw [h, cellCount_period_multiple P4 P4_prime _ 10, kappa_P4_all_false]

end Example

end KappaDial