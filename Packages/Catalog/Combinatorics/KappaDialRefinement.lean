/-
# Refinements of the κ rate–dial: coprime-scale equidistribution, the valuation ladder,
# and the effective size of a cell sweep

Building on `Combinatorics.KappaRateDial`, this file pushes the "rate dial, not a position
dial" dichotomy in three directions.

1. **A coprime-statistic no-go theorem** (`cellCount_coprime_statistic`, and its
   equidistribution corollary `cellCount_coprime_residue`). The absence of a positional
   signal is not merely a statement about whole period blocks: for *any* modulus `M` coprime
   to the period `L` and *any* statistic `Q` depending only on `v mod M`, the divisibility
   cell and the event `Q` are *exactly independent* over one common period. In particular
   each residue class mod `M` receives exactly `κ(σ)` members of the cell inside `[0, L·M)`.
   A divisibility cell therefore carries *no* information about any coprime-measurable
   observable, uniformly.

2. **The valuation ladder** (`card_valPeriod_eq`). Refining "`p ∣ v`" to "`v_p(v) = e p`"
   produces, over the refined period `∏ p^{e p + 1}`, a cell of size *exactly* `∏ (p - 1)`,
   **independently of the exponents** `e`. Sharpening the resolution of the dial therefore
   changes only the period (the denominator), never the numerator: the rate dial is a pure
   geometric ladder `∏ p^{-e p} (1 - 1/p)`.

3. **Effective sweep size** (`sweep_image_card_le`, `sweepValues_card_eq_iff`). Because the
   prime `2` is a dead coordinate, a sweep over all `2^{|P|}` divisibility cells explores at
   most `2^{|P| - 1}` distinct rate values when `2 ∈ P`; and it attains that maximum exactly
   when the numbers `p - 1` over the odd primes of `P` have pairwise distinct subset
   products. Quantifying the effective number of degrees of freedom of a cell sweep is
   exactly what a max-statistic selection correction needs. The criterion is not vacuous:
   `sweep_collision_3_7_13` exhibits a prime set where it fails.

## Lab notes

`P = {2,3,5,7}`, `L = 210`, all-cleared cell, `M = 11`: each of the 11 residue classes mod
`11` inside `[0, 2310)` contains exactly `48` totatives of `210` — checked by the general
theorem and instantiated in `cellCount_coprime_residue_example`.

Valuation ladder for `p = 3`, `e = 0,1,2`: cells of size `2` inside periods `3, 9, 27`, i.e.
densities `2/3, 2/9, 2/27` — a clean geometric ladder with constant numerator.
-/

import Combinatorics.KappaRateDial

open Finset

namespace KappaDial

/-- Divisibility by a divisor of the modulus only depends on the residue. -/
lemma dvd_iff_dvd_of_mod_eq {a n v w : ℕ} (ha : a ∣ n) (h : v % n = w % n) :
    a ∣ v ↔ a ∣ w := by
  rw [Nat.dvd_iff_mod_eq_zero, Nat.dvd_iff_mod_eq_zero, ← Nat.mod_mod_of_dvd v ha,
    ← Nat.mod_mod_of_dvd w ha, h]

/-! ## 1. Equidistribution across residue classes at any coprime scale -/

/-- Counting a single residue class over one of its periods gives exactly one hit. -/
lemma card_range_residue (M r : ℕ) (hr : r < M) :
    ((range M).filter (fun v => v % M = r)).card = 1 := by
  have h : (range M).filter (fun v => v % M = r) = {r} := by
    ext v
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_singleton]
    constructor
    · rintro ⟨h1, h2⟩; rwa [Nat.mod_eq_of_lt h1] at h2
    · rintro rfl; exact ⟨hr, Nat.mod_eq_of_lt hr⟩
  rw [h]; simp

/-- **Coprime-statistic no-go theorem.** Let `Q` be *any* statistic that depends only on `v`
modulo some `M` coprime to the period `L`. Then, over one common period `L · M`, the cell of
a divisibility pattern and the event `Q` are exactly independent: the joint count is the
product of the two individual counts. No coprime-measurable statistic — positional or
otherwise — can detect a divisibility pattern. -/
theorem cellCount_coprime_statistic (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool)
    (M : ℕ) (hM : 0 < M) (hcop : Nat.Coprime (modulus P) M)
    (Q : ℕ → Prop) [DecidablePred Q] (hQ : ∀ v w, v % M = w % M → (Q v ↔ Q w)) :
    ((range (modulus P * M)).filter (fun v => InCell P σ v ∧ Q v)).card
      = kappaRaw P σ * ((range M).filter Q).card := by
  rw [count_mul_coprime (modulus P) M (modulus_pos P hP) hM hcop _ _
      (fun v w hvw => inCell_periodic P σ (fun p hp => dvd_modulus P hp) v w hvw) hQ,
    card_period_eq_kappaRaw P hP σ]

/-- **Coprime-scale equidistribution.** For any modulus `M` coprime to the period `L`, every
residue class mod `M` contains exactly `κ(σ)` members of the cell inside `[0, L·M)`. The
divisibility pattern carries no positional information at any coprime scale. -/
theorem cellCount_coprime_residue (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool)
    (M r : ℕ) (hM : 0 < M) (hr : r < M) (hcop : Nat.Coprime (modulus P) M) :
    ((range (modulus P * M)).filter (fun v => InCell P σ v ∧ v % M = r)).card
      = kappaRaw P σ := by
  rw [cellCount_coprime_statistic P hP σ M hM hcop (fun v => v % M = r)
      (fun v w hvw => by simp only [hvw]),
    card_range_residue M r hr, mul_one]

/-! ## 2. The valuation ladder: exact `p`-adic valuation cells -/

/-- `InValCell P e v` says that `v` has `p`-adic valuation exactly `e p` for every `p ∈ P`. -/
def InValCell (P : Finset ℕ) (e : ℕ → ℕ) (v : ℕ) : Prop :=
  ∀ p ∈ P, p ^ (e p) ∣ v ∧ ¬ p ^ (e p + 1) ∣ v

instance (P : Finset ℕ) (e : ℕ → ℕ) : DecidablePred (InValCell P e) := by
  intro v; unfold InValCell; infer_instance

/-- The refined period `∏_{p ∈ P} p^{e p + 1}` of the valuation cell decomposition. -/
def valPeriod (P : Finset ℕ) (e : ℕ → ℕ) : ℕ := ∏ p ∈ P, p ^ (e p + 1)

lemma valPeriod_pos (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (e : ℕ → ℕ) :
    0 < valPeriod P e :=
  Finset.prod_pos fun p hp => pow_pos (hP p hp).pos _

/-- One prime coordinate of the valuation ladder: among the `p^{e+1}` residues of the
refined period exactly `p - 1` have valuation exactly `e`. -/
lemma card_range_val_cell (p e : ℕ) (hp : p.Prime) :
    ((range (p ^ (e + 1))).filter (fun v => p ^ e ∣ v ∧ ¬ p ^ (e + 1) ∣ v)).card = p - 1 := by
  have hp0 : 0 < p := hp.pos
  have hpe : 0 < p ^ e := pow_pos hp0 e
  have hcard : ((range p).erase 0).card = p - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_range.mpr hp0), Finset.card_range]
  rw [← hcard]
  refine Finset.card_nbij (fun v => v / p ^ e) ?_ ?_ ?_
  · intro v hv
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range, Finset.mem_erase] at hv ⊢
    obtain ⟨hv1, hdvd, hndvd⟩ := hv
    constructor
    · intro h0
      have : v = 0 := by
        obtain ⟨k, rfl⟩ := hdvd
        rw [Nat.mul_div_cancel_left _ hpe] at h0
        simp [h0]
      exact hndvd (this ▸ dvd_zero _)
    · rw [Nat.div_lt_iff_lt_mul hpe, mul_comm]
      calc v < p ^ (e + 1) := hv1
        _ = p ^ e * p := pow_succ p e
  · intro v hv w hw hvw
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range] at hv hw
    obtain ⟨k, rfl⟩ := hv.2.1
    obtain ⟨l, rfl⟩ := hw.2.1
    dsimp only at hvw
    rw [Nat.mul_div_cancel_left _ hpe, Nat.mul_div_cancel_left _ hpe] at hvw
    rw [hvw]
  · intro k hk
    simp only [Finset.mem_coe, Finset.mem_erase, Finset.mem_range] at hk
    obtain ⟨hk0, hkp⟩ := hk
    refine ⟨p ^ e * k, ?_, Nat.mul_div_cancel_left _ hpe⟩
    simp only [Finset.mem_coe, Finset.mem_filter, Finset.mem_range]
    refine ⟨?_, Dvd.intro k rfl, ?_⟩
    · calc p ^ e * k < p ^ e * p := by exact mul_lt_mul_of_pos_left hkp hpe
        _ = p ^ (e + 1) := (pow_succ p e).symm
    · rintro ⟨c, hc⟩
      have : k = p * c := by
        have hpe1 : p ^ (e + 1) = p ^ e * p := by ring
        rw [hpe1, mul_assoc] at hc
        exact Nat.eq_of_mul_eq_mul_left hpe hc
      have hpk : p ∣ k := ⟨c, this⟩
      have := Nat.le_of_dvd (Nat.pos_of_ne_zero hk0) hpk
      omega

lemma inValCell_periodic (P : Finset ℕ) (e : ℕ → ℕ) {L : ℕ}
    (hL : ∀ p ∈ P, p ^ (e p + 1) ∣ L) (v w : ℕ) (h : v % L = w % L) :
    InValCell P e v ↔ InValCell P e w := by
  unfold InValCell
  refine forall_congr' fun p => imp_congr_right fun hp => ?_
  have hdL : p ^ (e p + 1) ∣ L := hL p hp
  have hdL' : p ^ (e p) ∣ L := dvd_trans (pow_dvd_pow p (Nat.le_succ _)) hdL
  rw [dvd_iff_dvd_of_mod_eq hdL' h, dvd_iff_dvd_of_mod_eq hdL h]

/-- **The valuation ladder.** Over the refined period `∏ p^{e p + 1}` the exact-valuation
cell has size `∏ (p - 1)`, *independently of the exponents* `e`: refining the resolution of
the divisibility dial changes only the period, never the numerator. -/
theorem card_valPeriod_eq (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (e : ℕ → ℕ) :
    ((range (valPeriod P e)).filter (InValCell P e)).card = ∏ p ∈ P, (p - 1) := by
  classical
  induction P using Finset.induction_on with
  | empty =>
      have h : (range (valPeriod (∅ : Finset ℕ) e)).filter (InValCell ∅ e) = {0} := by
        simp only [valPeriod, Finset.prod_empty]
        rw [Finset.filter_true_of_mem (fun x _ => by intro p hp; simp at hp)]
        rfl
      rw [h]; simp
  | insert q P' hq ih =>
      have hqp : q.Prime := hP q (Finset.mem_insert_self q P')
      have hP' : ∀ p ∈ P', p.Prime := fun p hp => hP p (Finset.mem_insert_of_mem hp)
      have hper : valPeriod (insert q P') e = q ^ (e q + 1) * valPeriod P' e := by
        simp [valPeriod, Finset.prod_insert hq]
      have hcop : Nat.Coprime (q ^ (e q + 1)) (valPeriod P' e) := by
        refine Nat.Coprime.pow_left _ (Nat.Coprime.prod_right fun p hp => ?_)
        exact Nat.Coprime.pow_right _
          ((Nat.coprime_primes hqp (hP' p hp)).mpr (fun h => hq (h ▸ hp)))
      have hsplit : ∀ v, InValCell (insert q P') e v ↔
          ((q ^ (e q) ∣ v ∧ ¬ q ^ (e q + 1) ∣ v) ∧ InValCell P' e v) := by
        intro v; unfold InValCell; simp
      rw [hper, Finset.filter_congr (fun v _ => (hsplit v)),
        count_mul_coprime (q ^ (e q + 1)) (valPeriod P' e) (pow_pos hqp.pos _)
          (valPeriod_pos P' hP' e) hcop _ _
          (fun v w hvw => by
            have hqe : q ^ (e q) ∣ q ^ (e q + 1) := pow_dvd_pow q (Nat.le_succ _)
            rw [dvd_iff_dvd_of_mod_eq hqe hvw, dvd_iff_dvd_of_mod_eq dvd_rfl hvw])
          (fun v w hvw =>
            inValCell_periodic P' e (fun p hp => Finset.dvd_prod_of_mem _ hp) v w hvw),
        card_range_val_cell q (e q) hqp, ih hP', Finset.prod_insert hq]

/-- The numerator of the valuation ladder does not depend on the resolution: two exact
valuation patterns have equal cell sizes over their respective periods. -/
theorem valPeriod_numerator_constant (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (e f : ℕ → ℕ) :
    ((range (valPeriod P e)).filter (InValCell P e)).card
      = ((range (valPeriod P f)).filter (InValCell P f)).card := by
  rw [card_valPeriod_eq P hP e, card_valPeriod_eq P hP f]

/-- The valuation cell at the all-zero exponent pattern is the all-cleared divisibility cell,
so the ladder is anchored at Euler's totient. -/
theorem card_valPeriod_zero (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    ((range (valPeriod P (fun _ => 0))).filter (InValCell P (fun _ => 0))).card
      = Nat.totient (modulus P) := by
  rw [card_valPeriod_eq P hP, ← kappaRaw_all_false_eq_totient P hP, kappaRaw]
  exact Finset.prod_congr rfl fun p _ => by simp

/-! ## 3. Effective size of a cell sweep -/

/-- The multiset of rate values explored by a full sweep over all `2^{|P|}` cells. -/
def sweepValues (P : Finset ℕ) : Finset ℕ :=
  P.powerset.image (fun T => kappaRaw P (fun p => decide (p ∈ T)))

/-- Every cell rate divides the maximal rate `φ(L)`: the sweep explores a sub-family of the
divisor lattice of `Nat.totient L`, never an unconstrained set of values. -/
theorem kappaRaw_dvd_totient (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) (σ : ℕ → Bool) :
    kappaRaw P σ ∣ Nat.totient (modulus P) := by
  rw [← kappaRaw_all_false_eq_totient P hP, kappaRaw, kappaRaw]
  refine Finset.prod_dvd_prod_of_dvd _ _ fun p _ => ?_
  cases h : σ p with
  | true => simp
  | false => simp

/-- The values reachable by a full cell sweep all lie in the divisor set of `φ(L)`. -/
theorem sweepValues_subset_divisors (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime) :
    sweepValues P ⊆ (Nat.totient (modulus P)).divisors := by
  intro x hx
  simp only [sweepValues, Finset.mem_image, Finset.mem_powerset] at hx
  obtain ⟨T, _, rfl⟩ := hx
  refine Nat.mem_divisors.mpr ⟨kappaRaw_dvd_totient P hP _, ?_⟩
  exact (Nat.totient_pos.mpr (modulus_pos P hP)).ne'

/-- Removing the dead coordinate from the cleared set does not change the rate. -/
lemma prod_sub_one_erase_two (P T : Finset ℕ) :
    ∏ p ∈ (P.erase 2) \ T, (p - 1) = ∏ p ∈ P \ T, (p - 1) := by
  classical
  have h : (P.erase 2) \ T = (P \ T).erase 2 := by
    ext x; simp only [Finset.mem_sdiff, Finset.mem_erase]; tauto
  rw [h, Finset.prod_erase _ (by norm_num)]

/-- The sweep values are exactly the subset products of `p - 1` over the odd primes of `P`. -/
theorem sweepValues_eq_odd_image (P : Finset ℕ) :
    sweepValues P = (P.erase 2).powerset.image (fun S => ∏ p ∈ S, (p - 1)) := by
  classical
  apply Finset.Subset.antisymm
  · intro x hx
    simp only [sweepValues, Finset.mem_image, Finset.mem_powerset] at hx ⊢
    obtain ⟨T, hT, rfl⟩ := hx
    exact ⟨(P.erase 2) \ T, Finset.sdiff_subset,
      by rw [prod_sub_one_erase_two, kappaRaw_indicator P T hT]⟩
  · intro x hx
    simp only [sweepValues, Finset.mem_image, Finset.mem_powerset] at hx ⊢
    obtain ⟨S, hS, rfl⟩ := hx
    have hSP : S ⊆ P := hS.trans (Finset.erase_subset 2 P)
    refine ⟨P \ S, Finset.sdiff_subset, ?_⟩
    rw [kappaRaw_indicator P (P \ S) Finset.sdiff_subset, Finset.sdiff_sdiff_eq_self hSP]

/-- **Exact effective sweep dimension.** A cell sweep attains the maximal possible number
`2^{|P \ {2}|}` of distinct rate values precisely when the numbers `p - 1`, over the odd
primes of `P`, have pairwise distinct subset products. -/
theorem sweepValues_card_eq_iff (P : Finset ℕ) :
    (sweepValues P).card = 2 ^ (P.erase 2).card ↔
      Set.InjOn (fun S => ∏ p ∈ S, (p - 1)) ((P.erase 2).powerset : Set (Finset ℕ)) := by
  classical
  rw [sweepValues_eq_odd_image, ← Finset.card_powerset (P.erase 2), Finset.card_image_iff]

/-- **Effective sweep size.** Because `2` is a dead coordinate, the number of distinct rate
values reachable by a sweep over all `2^{|P|}` divisibility cells is at most `2^{|P| - 1}`
whenever `2 ∈ P`: a max-statistic correction over such a sweep must use the *effective*
number of degrees of freedom, which is strictly smaller than the number of cells. -/
theorem sweep_image_card_le (P : Finset ℕ) (h2 : 2 ∈ P) :
    (sweepValues P).card ≤ 2 ^ (P.card - 1) := by
  classical
  calc (sweepValues P).card
      = ((P.erase 2).powerset.image (fun S => ∏ p ∈ S, (p - 1))).card := by
        rw [sweepValues_eq_odd_image]
    _ ≤ (P.erase 2).powerset.card := Finset.card_image_le
    _ = 2 ^ (P.erase 2).card := Finset.card_powerset _
    _ = 2 ^ (P.card - 1) := by rw [Finset.card_erase_of_mem h2]

/-! ## Worked instances -/

section Example

/-- Each residue class mod `11` inside `[0, 2310)` contains exactly `48` integers coprime
to `210`. -/
theorem cellCount_coprime_residue_example (r : ℕ) (hr : r < 11) :
    ((range 2310).filter (fun v => InCell P4 (fun _ => false) v ∧ v % 11 = r)).card = 48 := by
  have hmod : (2310 : ℕ) = modulus P4 * 11 := by rw [modulus_P4]
  have hcop : Nat.Coprime (modulus P4) 11 := by rw [modulus_P4]; decide
  rw [hmod, cellCount_coprime_residue P4 P4_prime _ 11 r (by norm_num) hr hcop,
    kappa_P4_all_false]

/-- The sweep over the sixteen cells of `P = {2,3,5,7}` attains the maximal effective
dimension: exactly `8 = 2^3` distinct rate values. -/
theorem sweep_P4_card : (sweepValues P4).card = 8 := by decide

/-- The criterion of `sweepValues_card_eq_iff` genuinely bites: for `P = {3,7,13}` the
coincidence `(3-1)(7-1) = 13-1` collapses two cells onto the rate `12`, so the sweep reaches
only `7 < 2^3` distinct values. -/
theorem sweep_collision_3_7_13 :
    (sweepValues ({3, 7, 13} : Finset ℕ)).card
      ≠ 2 ^ ((({3, 7, 13} : Finset ℕ)).erase 2).card := by decide

/-- The `3`-adic ladder: exactly two residues of valuation `e` in every period `3^{e+1}`. -/
theorem three_adic_ladder (e : ℕ) :
    ((range (valPeriod {3} (fun _ => e))).filter (InValCell {3} (fun _ => e))).card = 2 := by
  rw [card_valPeriod_eq {3} (by decide) (fun _ => e)]
  decide

end Example

end KappaDial