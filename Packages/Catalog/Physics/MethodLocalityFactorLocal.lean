import Mathlib

/-!
# Method locality: which factoring methods track the factor, and which track the modulus

Round-28 experiment "METHOD-LOCALITY" (fixed prime `p = 4093`, cofactor `q` grown
`2^14 → 2^23`, 9 draws per cell) reported the verdict
**THE-METHODS-ARE-FACTOR-LOCAL**: the observed step counts of Pollard ρ and of ECM
stayed flat (`×1.40` and `×2.16` median spread) while the modulus grew by `2^23`,
whereas the `p`-scaling slopes separated (`ρ ≈ 0.45`, trial division `≈ 1.09` per
`log₂ p`).

This file turns that verdict into theorems, and in doing so *sharpens* it, because
the informal phrase "factor-local" conflates two genuinely different properties:

* **cofactor flatness** — the cost of a run on `N = p·q` does not depend on `q` at
  all; and
* **factor boundedness** — the cost is bounded by a function of `p` alone.

The main results are:

* `rhoSeq_reduce`, `rho_modp_time_eq`, `rho_cofactor_flat` — Pollard ρ is *exactly*
  cofactor flat.  The ρ iteration is a polynomial map, hence commutes with the ring
  map `ZMod N →+* ZMod p`; the mod-`p` collision time of the run performed modulo
  `N` therefore equals the collision time of the run performed modulo `p` itself and
  is literally independent of the cofactor.  The measured `×1.40` spread is method
  luck (different seeds), not cofactor dependence: the theorem gives ratio `1`.
* `rhoTime_le_factor` — that cost is at most `p`: a factor-bounded method.
* `rho_collision_reveals_factor` — a mod-`p` collision that is not a mod-`N`
  collision yields a *proper* divisor of `N` that is a multiple of `p`.
* `trialSteps_eq_of_le`, `trialSteps_le_of_prime_dvd` — ascending trial division is
  factor bounded (`≤ p - 1` for every prime factor `p`), and on the stratum where
  `p` is the least factor its cost is *exactly* `p - 1`: the "definition face",
  slope `1` per `p`, matching the measured `1.09`.
* `trial_not_cofactor_flat` — but trial division is **not** cofactor flat: with the
  factor `p = 4093` held fixed, cost `2` at `q = 3` versus cost `4092` at
  `q = 4093`.  This is the precise sense in which the verdict is right, and
  `trial_locality_dichotomy` states the resulting dichotomy.
* `rho_time_4093`, `rho_beats_trial_at_4093` — the experimental anchor, verified by
  kernel computation: the ρ orbit of `x ↦ x² + 1` from `x₀ = 2` modulo `4093` first
  repeats at step `70` (`√4093 ≈ 64`), i.e. `58×` cheaper than the `4092` trial
  divisions, and `70 ≤ 2√4093`.
* `collTime_succ_eq_self` — a *critique* of the `0.45` slope: the birthday exponent
  is not a worst-case theorem.  For the successor map on `ZMod p` the collision time
  is exactly `p`, so `√p` is a statement about typical maps, not all of them.
* `birthday_prod_le_exp`, `birthday_half_4093` — the honest form of the `√p` law: in
  the uniform model the no-collision probability after `k` draws is at most
  `exp(-k(k-1)/2p)`, which at `p = 4093` is below `1/2` already at `k = 76` — the
  measured `70` sits exactly in this window.
-/

namespace MethodLocality

open Finset

/-! ## 1. A collision-time calculus

Every method in the round-28 plane is a search for a repetition in a sequence of
states.  We measure cost as the first index at which the sequence repeats a value
it has already taken.
-/

variable {β : Type*}

/-- The sequence `s` collides at time `n` if some strictly earlier term equals `s n`. -/
def SeqColl (s : ℕ → β) (n : ℕ) : Prop := ∃ i < n, s i = s n

/-- A sequence into a finite type must collide. -/
theorem exists_seqColl [Finite β] (s : ℕ → β) : ∃ n, SeqColl s n := by
  obtain ⟨i, j, hij, h⟩ := Finite.exists_ne_map_eq_of_infinite s
  rcases lt_or_gt_of_ne hij with h1 | h1
  · exact ⟨j, i, h1, h⟩
  · exact ⟨i, j, h1, h.symm⟩

/-- **Cost of a search**: the first time the state sequence repeats. -/
noncomputable def collTime (s : ℕ → β) : ℕ := sInf {n | SeqColl s n}

theorem collTime_le {s : ℕ → β} {n : ℕ} (h : SeqColl s n) : collTime s ≤ n := Nat.sInf_le h

theorem collTime_mem [Finite β] (s : ℕ → β) : SeqColl s (collTime s) := by
  have : collTime s ∈ {n | SeqColl s n} := Nat.sInf_mem (exists_seqColl s)
  simpa [Set.mem_setOf_eq] using this

theorem not_seqColl_of_lt_collTime {s : ℕ → β} {n : ℕ} (h : n < collTime s) :
    ¬ SeqColl s n := fun hn => absurd (collTime_le hn) (not_le.mpr h)

/-- Cost is determined by the state sequence alone. -/
theorem collTime_congr {s t : ℕ → β} (h : ∀ n, s n = t n) : collTime s = collTime t := by
  simp [funext h]

theorem collTime_eq {s : ℕ → β} {n : ℕ} [Finite β] (h : SeqColl s n)
    (hmin : ∀ m < n, ¬ SeqColl s m) : collTime s = n :=
  le_antisymm (collTime_le h) (Nat.le_of_not_lt fun hlt => hmin _ hlt (collTime_mem s))

/-- The pigeonhole ceiling: a search in a state space of size `c` costs at most `c`. -/
theorem collTime_le_card [Fintype β] (s : ℕ → β) : collTime s ≤ Fintype.card β := by
  classical
  obtain ⟨i, hi, j, hj, hij, h⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (s := Finset.range (Fintype.card β + 1))
      (t := (Finset.univ : Finset β)) (by simp) (f := s) (fun n _ => Finset.mem_univ _)
  simp only [Finset.mem_range] at hi hj
  rcases lt_or_gt_of_ne hij with h1 | h1
  · exact le_trans (collTime_le ⟨i, h1, h⟩) (by omega)
  · exact le_trans (collTime_le ⟨j, h1, h.symm⟩) (by omega)

/-! ## 2. Pollard ρ is a polynomial map, hence equivariant under reduction -/

/-- One Pollard-ρ step `x ↦ x² + c`, in an arbitrary commutative ring. -/
def rhoStep {R : Type*} [CommRing R] (c x : R) : R := x * x + c

/-- The ρ orbit of the seed `x₀`. -/
def rhoSeq {R : Type*} [CommRing R] (c x0 : R) (n : ℕ) : R := (rhoStep c)^[n] x0

theorem map_rhoStep {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) (c x : R) :
    φ (rhoStep c x) = rhoStep (φ c) (φ x) := by
  simp [rhoStep]

/-- **Equivariance.**  A ring map intertwines the ρ orbits. -/
theorem map_rhoSeq {R S : Type*} [CommRing R] [CommRing S] (φ : R →+* S) (c x0 : R) (n : ℕ) :
    φ (rhoSeq c x0 n) = rhoSeq (φ c) (φ x0) n := by
  induction n with
  | zero => simp [rhoSeq]
  | succ n ih =>
      simp only [rhoSeq, Function.iterate_succ_apply'] at *
      rw [map_rhoStep, ih]

/-- **The mod-`p` shadow of a mod-`N` run is the mod-`p` run.**  The cofactor never
enters: the reduction of the orbit computed modulo `N` is the orbit computed
modulo `p` from the reduced seed. -/
theorem rhoSeq_reduce {p N : ℕ} [NeZero p] (h : p ∣ N) (c x0 : ℤ) (n : ℕ) :
    (ZMod.castHom h (ZMod p)) (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n)
      = rhoSeq ((c : ZMod p)) ((x0 : ZMod p)) n := by
  rw [map_rhoSeq]
  simp [map_intCast]

/-- The cost of Pollard ρ run modulo `N` when hunting the factor `p`: the first time
the mod-`p` shadow of the orbit repeats. -/
noncomputable def rhoTime (p N : ℕ) [NeZero p] (h : p ∣ N) (c x0 : ℤ) : ℕ :=
  collTime (fun n => (ZMod.castHom h (ZMod p)) (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n))

/-- The intrinsic, modulus-free ρ cost attached to the factor `p` alone. -/
noncomputable def rhoTimeAtFactor (p : ℕ) (c x0 : ℤ) : ℕ :=
  collTime (rhoSeq ((c : ZMod p)) ((x0 : ZMod p)))

/-- **Factor locality of ρ (H1).**  The cost of the mod-`N` run equals the cost of the
mod-`p` run: the modulus has been eliminated from the ledger. -/
theorem rho_time_eq_factor_time {p N : ℕ} [NeZero p] (h : p ∣ N) (c x0 : ℤ) :
    rhoTime p N h c x0 = rhoTimeAtFactor p c x0 :=
  collTime_congr (rhoSeq_reduce h c x0)

/-- **Cofactor flatness, exactly.**  Two runs with the same factor `p` and the same
integer seed, on two arbitrary cofactors, cost the same — flatness ratio `1`, against
the measured median ratio `1.40` over `2^23` of cofactor growth. -/
theorem rho_cofactor_flat {p q q' : ℕ} [NeZero p] (c x0 : ℤ)
    (h : p ∣ p * q) (h' : p ∣ p * q') :
    rhoTime p (p * q) h c x0 = rhoTime p (p * q') h' c x0 := by
  rw [rho_time_eq_factor_time, rho_time_eq_factor_time]

/-- **Factor boundedness of ρ.**  The cost never exceeds `p`, whatever the modulus. -/
theorem rhoTime_le_factor {p N : ℕ} [NeZero p] (h : p ∣ N) (c x0 : ℤ) :
    rhoTime p N h c x0 ≤ p := by
  rw [rho_time_eq_factor_time, rhoTimeAtFactor]
  simpa using collTime_le_card (β := ZMod p) (rhoSeq ((c : ZMod p)) ((x0 : ZMod p)))

/-! ## 3. A mod-`p` collision is a factor -/

/-- **Reveal.**  A pair of states that agree modulo `p` but differ modulo `N` hands
over a proper divisor of `N` divisible by `p`; since `p` is prime the gcd is a
nontrivial factor. -/
theorem factor_revealed {p N a b : ℕ} (hp : 2 ≤ p) (hpN : p ∣ N) (hba : b < a) (haN : a < N)
    (hcong : a ≡ b [MOD p]) :
    p ∣ Nat.gcd (a - b) N ∧ Nat.gcd (a - b) N ∣ N ∧ Nat.gcd (a - b) N < N ∧
      2 ≤ Nat.gcd (a - b) N := by
  have hdvd : p ∣ a - b := (Nat.modEq_iff_dvd' hba.le).mp hcong.symm
  have hg : Nat.gcd (a - b) N ∣ N := Nat.gcd_dvd_right _ _
  have hpos : 0 < a - b := by omega
  have hlt : a - b < N := by omega
  have hpg : p ∣ Nat.gcd (a - b) N := Nat.dvd_gcd hdvd hpN
  have hgpos : 0 < Nat.gcd (a - b) N := Nat.gcd_pos_of_pos_left _ hpos
  refine ⟨hpg, hg, lt_of_le_of_lt (Nat.le_of_dvd hpos (Nat.gcd_dvd_left _ _)) hlt, ?_⟩
  exact le_trans hp (Nat.le_of_dvd hgpos hpg)

/-- The ρ states themselves: a mod-`p` collision of the mod-`N` orbit is a congruence
between the two integer representatives. -/
theorem rho_collision_reveals_factor {p N : ℕ} [NeZero p] [NeZero N] (hp : 2 ≤ p) (h : p ∣ N)
    (c x0 : ℤ) {i n : ℕ}
    (hcoll : (ZMod.castHom h (ZMod p)) (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) i)
      = (ZMod.castHom h (ZMod p)) (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n))
    (hne : (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n).val
      < (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) i).val) :
    p ∣ Nat.gcd ((rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) i).val
        - (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n).val) N := by
  set a := (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) i) with ha
  set b := (rhoSeq ((c : ZMod N)) ((x0 : ZMod N)) n) with hb
  have hcast : ∀ z : ZMod N, (ZMod.castHom h (ZMod p)) z = ((z.val : ℕ) : ZMod p) := by
    intro z
    have hz : ((z.val : ℕ) : ZMod N) = z := ZMod.natCast_rightInverse z
    calc (ZMod.castHom h (ZMod p)) z
        = (ZMod.castHom h (ZMod p)) ((z.val : ℕ) : ZMod N) := by rw [hz]
      _ = ((z.val : ℕ) : ZMod p) := map_natCast _ _
  have hcong : a.val ≡ b.val [MOD p] := by
    have := hcoll
    rw [hcast a, hcast b] at this
    exact (ZMod.natCast_eq_natCast_iff _ _ _).mp this
  have haN : a.val < N := ZMod.val_lt a
  exact (factor_revealed hp h hne haN hcong).1

/-! ## 4. The birthday exponent is not a worst case

Critique of the measured slope `0.45`: a state-space search *can* cost the full `p`.
-/

theorem succ_iterate {p : ℕ} (x0 : ZMod p) (n : ℕ) :
    (fun x : ZMod p => x + 1)^[n] x0 = x0 + (n : ZMod p) := by
  induction n with
  | zero => simp
  | succ n ih => rw [Function.iterate_succ_apply', ih]; push_cast; ring

/-- **Worst-case locality without the birthday gain.**  The orbit of the successor
map on `ZMod p` visits every residue before repeating: the cost is exactly `p`, not
`√p`.  So the `0.45` exponent is a statement about typical quadratic maps, never a
theorem about all state maps of the same state space. -/
theorem collTime_succ_eq_self {p : ℕ} (hp : 0 < p) (x0 : ZMod p) :
    collTime (fun n : ℕ => (fun x : ZMod p => x + 1)^[n] x0) = p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  refine collTime_eq ⟨0, hp, ?_⟩ ?_
  · simp [succ_iterate]
  · rintro m hm ⟨i, him, hEq⟩
    simp only [succ_iterate] at hEq
    have h2 : ((i : ℕ) : ZMod p) = ((m : ℕ) : ZMod p) := add_left_cancel hEq
    have := (ZMod.natCast_eq_natCast_iff' i m p).mp h2
    rw [Nat.mod_eq_of_lt (by omega), Nat.mod_eq_of_lt (by omega)] at this
    omega

/-! ## 5. The birthday law in its honest (probabilistic) form -/

theorem sum_range_real (k : ℕ) : (∑ i ∈ Finset.range k, (i : ℝ)) = (k * (k - 1)) / 2 := by
  induction k with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, ih]; push_cast; ring

/-- **Birthday bound.**  In the uniform model the probability that `k ≤ p` successive
states are pairwise distinct is `∏_{i<k}(1 - i/p) ≤ exp(-k(k-1)/2p)`; the search
therefore succeeds by `k ≍ √p` steps, which is the content of the `0.45` slope. -/
theorem birthday_prod_le_exp {p k : ℕ} (hp : 0 < p) (hk : k ≤ p) :
    (∏ i ∈ Finset.range k, (1 - (i : ℝ) / p)) ≤ Real.exp (-((k : ℝ) * (k - 1)) / (2 * p)) := by
  have hpR : (0 : ℝ) < p := by exact_mod_cast hp
  have hstep : ∀ i ∈ Finset.range k, (1 - (i : ℝ) / p) ≤ Real.exp (-((i : ℝ) / p)) := by
    intro i _
    have := Real.add_one_le_exp (-((i : ℝ) / p))
    linarith
  have hnonneg : ∀ i ∈ Finset.range k, (0 : ℝ) ≤ 1 - (i : ℝ) / p := by
    intro i hi
    simp only [Finset.mem_range] at hi
    have : (i : ℝ) ≤ p := by exact_mod_cast (le_of_lt (lt_of_lt_of_le hi hk))
    rw [sub_nonneg, div_le_one hpR]
    exact this
  calc (∏ i ∈ Finset.range k, (1 - (i : ℝ) / p))
      ≤ ∏ i ∈ Finset.range k, Real.exp (-((i : ℝ) / p)) := Finset.prod_le_prod hnonneg hstep
    _ = Real.exp (∑ i ∈ Finset.range k, (-((i : ℝ) / p))) := by rw [Real.exp_sum]
    _ = Real.exp (-((k : ℝ) * (k - 1)) / (2 * p)) := by
        congr 1
        rw [Finset.sum_neg_distrib, ← Finset.sum_div, sum_range_real]
        field_simp

/-- **The experimental window at the anchor prime.**  At `p = 4093` the uniform-model
survival probability is already below `1/2` at `k = 76`; the measured ρ time was
`70`. -/
theorem birthday_half_4093 : (∏ i ∈ Finset.range 76, (1 - (i : ℝ) / 4093)) ≤ 1 / 2 := by
  refine (birthday_prod_le_exp (p := 4093) (k := 76) (by norm_num) (by norm_num)).trans ?_
  have hlog : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have h2 : ((1 : ℝ) / 2) = Real.exp (-Real.log 2) := by
    rw [Real.exp_neg, Real.exp_log (by norm_num : (0:ℝ) < 2)]
    norm_num
  rw [h2]
  apply Real.exp_le_exp.mpr
  norm_num
  linarith

/-! ## 6. Trial division: the definition face -/

/-- Number of trial divisors `2, 3, …, minFac N` inspected by ascending trial
division before `N` gives up its least factor. -/
def trialSteps (N : ℕ) : ℕ := N.minFac - 1

/-- The inspected candidates below the least factor all fail — the cost really is the
count of tested divisors. -/
theorem trial_tests_fail {N d : ℕ} (hd : 2 ≤ d) (hlt : d < N.minFac) : ¬ d ∣ N := by
  intro hdvd
  have := Nat.minFac_le_of_dvd hd hdvd
  omega

theorem trialSteps_eq_card (N : ℕ) : trialSteps N = (Finset.Icc 2 N.minFac).card := by
  rcases Nat.lt_or_ge N.minFac 2 with h | h
  · interval_cases hm : N.minFac <;> simp [trialSteps, hm]
  · rw [Nat.card_Icc]
    simp [trialSteps]

theorem minFac_semiprime {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    (p * q).minFac = p := by
  have hple := hp.two_le
  have hqle := hq.two_le
  have hle : (p * q).minFac ≤ p := Nat.minFac_le_of_dvd hple ⟨q, rfl⟩
  have hdvd : (p * q).minFac ∣ p * q := Nat.minFac_dvd _
  have hne : p * q ≠ 1 := by nlinarith
  have hprime : (p * q).minFac.Prime := Nat.minFac_prime hne
  rcases (Nat.Prime.dvd_mul hprime).mp hdvd with h | h
  · exact (Nat.prime_dvd_prime_iff_eq hprime hp).mp h
  · have := (Nat.prime_dvd_prime_iff_eq hprime hq).mp h
    omega

/-- **The definition face.**  On the stratum where the hunted prime is the least
factor, trial division costs exactly `p - 1`: slope `1` per `p`, the measured
`1.09`. -/
theorem trialSteps_eq_of_le {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q) :
    trialSteps (p * q) = p - 1 := by
  rw [trialSteps, minFac_semiprime hp hq hpq]

/-- **Factor boundedness of trial division.**  For *any* prime factor `p` of `N`, the
cost is at most `p - 1`. -/
theorem trialSteps_le_of_prime_dvd {N p : ℕ} (hp : p.Prime) (hpN : p ∣ N) :
    trialSteps N ≤ p - 1 := by
  have := Nat.minFac_le_of_dvd hp.two_le hpN
  simp [trialSteps]
  omega

/-- **Exact linear law.**  Cost ratios across two least-factor strata are exactly the
ratios of the factors: no sub-linear gain is available to trial division. -/
theorem trial_linear_law {p q p' q' : ℕ} (hp : p.Prime) (hq : q.Prime) (hpq : p ≤ q)
    (hp' : p'.Prime) (hq' : q'.Prime) (hpq' : p' ≤ q') :
    (p' - 1) * trialSteps (p * q) = (p - 1) * trialSteps (p' * q') := by
  rw [trialSteps_eq_of_le hp hq hpq, trialSteps_eq_of_le hp' hq' hpq', Nat.mul_comm]

/-- **Trial division is not cofactor flat.**  Holding the hunted factor at
`p = 4093`, the cost of trial division on `p·q` is `2` for `q = 3` and `4092` for
`q = 4093`: the cofactor, not the factor, decides.  Contrast `rho_cofactor_flat`. -/
theorem trial_not_cofactor_flat :
    trialSteps (4093 * 3) = 2 ∧ trialSteps (4093 * 4093) = 4092 ∧
      trialSteps (4093 * 3) ≠ trialSteps (4093 * 4093) := by
  have h3 : Nat.Prime 3 := by norm_num
  have h4093 : Nat.Prime 4093 := by norm_num
  have e1 : trialSteps (4093 * 3) = 2 := by
    rw [Nat.mul_comm]
    exact trialSteps_eq_of_le h3 h4093 (by norm_num)
  have e2 : trialSteps (4093 * 4093) = 4092 :=
    trialSteps_eq_of_le h4093 h4093 le_rfl
  exact ⟨e1, e2, by omega⟩

/-! ## 7. The anchor: ρ at `p = 4093`, verified by kernel computation -/

set_option maxRecDepth 100000 in
/-- The first 70 states of the ρ orbit of `x ↦ x² + 1` from `x₀ = 2` modulo `4093`
are pairwise distinct. -/
theorem rho_4093_nodup :
    ((List.range 70).map (fun n => rhoSeq (1 : ZMod 4093) 2 n)).Nodup := by
  decide

set_option maxRecDepth 100000 in
/-- …and state `70` repeats state `53`. -/
theorem rho_4093_collide : rhoSeq (1 : ZMod 4093) 2 53 = rhoSeq (1 : ZMod 4093) 2 70 := by
  decide

/-- **Measured ρ cost at the anchor prime**: exactly `70` steps (`√4093 ≈ 64`). -/
theorem rho_time_4093 : rhoTimeAtFactor 4093 1 2 = 70 := by
  have hseq : ∀ n : ℕ, rhoSeq ((1 : ℤ) : ZMod 4093) ((2 : ℤ) : ZMod 4093) n
      = rhoSeq (1 : ZMod 4093) 2 n := by
    intro n; norm_num
  rw [rhoTimeAtFactor, collTime_congr hseq]
  refine collTime_eq ⟨53, by norm_num, rho_4093_collide⟩ ?_
  rintro m hm ⟨i, him, hEq⟩
  have := List.inj_on_of_nodup_map rho_4093_nodup
    (x := i) (List.mem_range.mpr (by omega)) (y := m) (List.mem_range.mpr (by omega)) hEq
  omega

/-- The measured cost sits inside the birthday window `2√p`. -/
theorem rho_time_4093_in_birthday_window : rhoTimeAtFactor 4093 1 2 ≤ 2 * Nat.sqrt 4093 := by
  rw [rho_time_4093]
  norm_num [Nat.sqrt]

/-- **Cross-method separation at the anchor.**  Against the same factor `4093`, ρ
finishes in `70` steps while trial division needs `4092`: a `58×` gap, and the gap
is a factor-local statement — it does not move with the cofactor. -/
theorem rho_beats_trial_at_4093 {q : ℕ} (hq : Nat.Prime q) (hq' : 4093 ≤ q) :
    58 * rhoTimeAtFactor 4093 1 2 ≤ trialSteps (4093 * q) := by
  rw [rho_time_4093, trialSteps_eq_of_le (by norm_num) hq hq']
  norm_num

/-! ## 8. The locality dichotomy -/

/-- A cost model is *factor bounded* if some function of the hunted prime alone
dominates the cost, for every modulus. -/
def FactorBounded (cost : ℕ → ℕ → ℕ) : Prop :=
  ∃ g : ℕ → ℕ, ∀ N p : ℕ, p.Prime → p ∣ N → cost N p ≤ g p

/-- A cost model is *cofactor flat* if the cost on `p·q` is independent of `q`. -/
def CofactorFlat (cost : ℕ → ℕ → ℕ) : Prop :=
  ∀ p q q' : ℕ, 0 < q → 0 < q' → cost (p * q) p = cost (p * q') p

/-- Trial division, presented as a cost model. -/
def trialCost (N : ℕ) (_p : ℕ) : ℕ := trialSteps N

/-- Pollard ρ with seed `x₀ = 2`, constant `c = 1`, presented as a cost model: by
`rho_time_eq_factor_time` the modulus argument is inert. -/
noncomputable def rhoCost (_N : ℕ) (p : ℕ) : ℕ := rhoTimeAtFactor p 1 2

theorem rho_factorBounded : FactorBounded rhoCost := by
  refine ⟨id, fun N p hp _ => ?_⟩
  haveI : NeZero p := ⟨hp.pos.ne'⟩
  simpa [rhoCost, rhoTimeAtFactor] using
    collTime_le_card (β := ZMod p) (rhoSeq (((1 : ℤ) : ZMod p)) (((2 : ℤ) : ZMod p)))

theorem rho_cofactorFlat : CofactorFlat rhoCost := fun _ _ _ _ _ => rfl

theorem trial_factorBounded : FactorBounded trialCost :=
  ⟨fun p => p - 1, fun _ _ hp hpN => trialSteps_le_of_prime_dvd hp hpN⟩

theorem trial_not_cofactorFlat : ¬ CofactorFlat trialCost := by
  intro h
  have := h 4093 3 4093 (by norm_num) (by norm_num)
  obtain ⟨e1, e2, _⟩ := trial_not_cofactor_flat
  rw [trialCost, trialCost, e1, e2] at this
  omega

/-- **THE-METHODS-ARE-FACTOR-LOCAL, sharpened.**  Both methods are factor bounded, but
only ρ is cofactor flat: ρ's ledger sees the factor `p` and nothing else, while trial
division's cost is decided by whichever factor of the modulus happens to be smallest.
This is the precise content of the round-28 verdict. -/
theorem locality_dichotomy :
    (FactorBounded rhoCost ∧ CofactorFlat rhoCost) ∧
      (FactorBounded trialCost ∧ ¬ CofactorFlat trialCost) :=
  ⟨⟨rho_factorBounded, rho_cofactorFlat⟩, ⟨trial_factorBounded, trial_not_cofactorFlat⟩⟩

end MethodLocality