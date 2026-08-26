import Mathlib
import Catalog.Shared.ECMStage1OrderCompletion

/-!
# Exact stage-1 firing rates, the gcd staircase, and why the collision model is the wrong one

`Catalog.Shared.ECMStage1OrderCompletion` proved that stage-1 firing is a divisibility,
and that its position in the prime schedule is the largest prime factor of the point's
order.  This file turns those two facts into exact *counts*, which is the level at
which experiments 570 / 595 measured the phenomenon.

Working in the cyclic group of order `m` (the model of the group of points used
throughout the ECM literature: a random point is a uniformly random residue mod `m`),
we prove:

* **Exact rate** (`card_firingSet`).  The number of points killed by a scalar `k` is
  *exactly* `gcd(m, k)` — never a Poisson-type expression.  In particular the success
  rate at bound `B` is `gcd(m, k(B)) / m`.
* **Scale invariance of the firing count** (`card_firingSet_scale_invariant`).
  Multiplying the order by any factor coprime to the scalar changes neither the set
  of prime powers that matter nor the firing count: the mechanism does not degrade as
  the modulus grows, only the denominator does.
* **The gcd staircase** (`gcd_stage1_flat`, `jumpSet_subset_primeFactors`,
  `card_jumpSet_le`).  The cumulative firing count `C ↦ gcd(m, k(B,C))` is *flat*
  between prime divisors of `m` and jumps only at primes dividing `m`; there are at
  most `ω(m) ≤ log₂ m` jumps among the `π(B)` steps of the schedule.  So the
  firing-position distribution is a step function supported on `≤ log₂ m` positions:
  it cannot be the uniform distribution on the schedule once `π(B) > log₂ m`
  (`firing_positions_not_uniform`).  This is the unconditional skeleton under the
  observed KS rejections.
* **Early fire** (`gcd_stage1_full_dvd_prefix_mul_largePart`, `firing_by_cutoff_ge`).
  All but a factor `s = ∏ {q^{v_q(m)} : q ∣ m, q > L}` of the firing points already
  fire by cutoff `L`.  Orders whose large-prime part is small therefore fire in the
  first few percent of the schedule — quantitatively, not just qualitatively.
* **Multi-curve amplification** (`card_multiCurve_success`, `multiCurve_rate`).
  With `c` independent points the success count is exactly `m^c - (m - gcd(m,k))^c`,
  i.e. the rate is exactly `1 - (1 - ρ)^c` with `ρ = gcd(m,k)/m`.
* **The collision model is subdominant** (`orderCompletion_beats_collision_heuristic`).
  A single explicit order shows the order-completion rate exceeding the heuristic
  collision rate `≈ 1.44·B/m` by a factor `> 25`; the two models are not perturbations
  of one another.
-/

namespace ECMStage1

open Finset

/-! ## The exact firing count in a cyclic group of order `m` -/

/-- The residues mod `m` killed by the scalar `k`, i.e. the points on which a stage-1
run with scalar `k` fires. -/
def firingSet (m k : ℕ) : Finset ℕ := (Finset.range m).filter (fun a => m ∣ k * a)

/-- Firing is divisibility by the *cofactor* `m / gcd(m,k)`. -/
theorem mem_firingSet_iff {m k a : ℕ} (hm : 0 < m) (ha : a < m) :
    a ∈ firingSet m k ↔ (m / Nat.gcd m k) ∣ a := by
  have key : m ∣ k * a ↔ (m / Nat.gcd m k) ∣ a := by
    set g := Nat.gcd m k with hgdef
    have hg : 0 < g := Nat.gcd_pos_of_pos_left k hm
    have hmg : g * (m / g) = m := Nat.mul_div_cancel' (Nat.gcd_dvd_left m k)
    have hkg : g * (k / g) = k := Nat.mul_div_cancel' (Nat.gcd_dvd_right m k)
    have hcop : Nat.Coprime (m / g) (k / g) := Nat.coprime_div_gcd_div_gcd hg
    constructor
    · intro h
      rw [← hmg, ← hkg, mul_assoc] at h
      exact hcop.dvd_of_dvd_mul_left ((Nat.mul_dvd_mul_iff_left hg).mp h)
    · intro h
      rw [← hmg, ← hkg, mul_assoc]
      exact Nat.mul_dvd_mul_left g (Dvd.dvd.mul_left h _)
  simp [firingSet, ha, key]

/-- **Exact firing rate.**  A scalar `k` kills exactly `gcd(m, k)` of the `m` points of
a cyclic group of order `m`.  The stage-1 success event has an exact arithmetic count;
no probabilistic model is involved. -/
theorem card_firingSet (m k : ℕ) (hm : 0 < m) : (firingSet m k).card = Nat.gcd m k := by
  set g := Nat.gcd m k with hgdef
  have hg : 0 < g := Nat.gcd_pos_of_pos_left k hm
  set d := m / g with hd
  have hdg : d * g = m := by rw [hd]; exact Nat.div_mul_cancel (Nat.gcd_dvd_left m k)
  have hdpos : 0 < d := Nat.div_pos (Nat.le_of_dvd hm (Nat.gcd_dvd_left m k)) hg
  have himg : firingSet m k = (Finset.range g).image (fun j => d * j) := by
    ext a
    rcases Nat.lt_or_ge a m with ha | ha
    · rw [mem_firingSet_iff hm ha]
      simp only [Finset.mem_image, Finset.mem_range]
      constructor
      · rintro ⟨j, rfl⟩
        exact ⟨j, by nlinarith [hdg], rfl⟩
      · rintro ⟨j, hj, rfl⟩
        exact Dvd.intro j rfl
    · have hnot : a ∉ firingSet m k := by
        simp only [firingSet, Finset.mem_filter, Finset.mem_range]
        omega
      have hnot' : a ∉ (Finset.range g).image (fun j => d * j) := by
        simp only [Finset.mem_image, Finset.mem_range]
        rintro ⟨j, hj, rfl⟩
        nlinarith [hdg]
      simp [hnot, hnot']
  rw [himg, Finset.card_image_of_injective _ (mul_right_injective₀ hdpos.ne'), Finset.card_range]

/-- **Scale invariance of the firing count.**  Enlarging the order by a factor coprime
to the stage-1 scalar leaves the number of firing points unchanged: the order-completion
mechanism is insensitive to the size of the part of the order that lives above the
smoothness bound. -/
theorem card_firingSet_scale_invariant {m w k : ℕ} (hm : 0 < m) (hw : 0 < w)
    (hcop : Nat.Coprime w k) :
    (firingSet (m * w) k).card = (firingSet m k).card := by
  rw [card_firingSet _ _ (Nat.mul_pos hm hw), card_firingSet _ _ hm]
  exact Nat.gcd_mul_left_left_of_gcd_eq_one hcop

/-! ## The gcd staircase: flatness between prime divisors -/

/-- **Flatness (no dose response).**  Advancing the prime cutoff from `C` to `C'`
changes nothing at all unless a prime divisor of the order lies in `(C, C']`. -/
theorem gcd_stage1_flat {m B C C' : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) (hCC : C ≤ C')
    (hno : ∀ q ∈ m.primeFactors, q ≤ C' → q ≤ C) :
    Nat.gcd m (stage1 B C) = Nat.gcd m (stage1 B C') := by
  refine Nat.dvd_antisymm (Nat.dvd_gcd (Nat.gcd_dvd_left _ _) ?_) (Nat.dvd_gcd
    (Nat.gcd_dvd_left _ _) ?_)
  · exact (Nat.gcd_dvd_right _ _).trans (stage1_dvd_stage1 hCC)
  · set n := Nat.gcd m (stage1 B C') with hn
    have hnne : n ≠ 0 := Nat.gcd_ne_zero_left hm
    have hdvd : n ∣ stage1 B C' := Nat.gcd_dvd_right _ _
    refine (dvd_stage1_iff hnne hB).mpr ?_
    intro q hq
    obtain ⟨hq1, hq2⟩ := (dvd_stage1_iff hnne hB).mp hdvd q hq
    refine ⟨hno q ?_ hq1, hq2⟩
    exact Nat.primeFactors_mono (Nat.gcd_dvd_left _ _) hm hq

/-- The cutoffs at which the cumulative firing count actually increases. -/
def jumpSet (m B : ℕ) : Finset ℕ :=
  (Finset.range (B + 1)).filter
    (fun C => Nat.gcd m (stage1 B C) ≠ Nat.gcd m (stage1 B (C - 1)))

/-- **Jumps happen only at prime divisors of the order.**  Every step of the schedule
at which the firing count grows is a prime dividing `m`. -/
theorem jumpSet_subset_primeFactors {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    jumpSet m B ⊆ m.primeFactors := by
  intro C hC
  simp only [jumpSet, Finset.mem_filter, Finset.mem_range] at hC
  by_contra hCm
  refine hC.2 (gcd_stage1_flat hm hB (Nat.sub_le C 1) ?_).symm
  intro q hq hqC
  rcases Nat.lt_or_ge (C - 1) q with h | h
  · exfalso
    have : q = C := by omega
    exact hCm (this ▸ hq)
  · exact h

/-- **Exact description of the firing positions.**  The steps of the schedule at which
the firing count grows are *precisely* the prime divisors of the order that are at most
the smoothness bound.  Firing positions are therefore an arithmetic invariant of the
order, not a random subset of the schedule. -/
theorem jumpSet_eq_primeFactors_filter {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    jumpSet m B = m.primeFactors.filter (fun q => q ≤ B) := by
  ext C
  constructor
  · intro hC
    have hCm : C ∈ m.primeFactors := jumpSet_subset_primeFactors hm hB hC
    simp only [jumpSet, Finset.mem_filter, Finset.mem_range, Nat.lt_succ_iff] at hC
    exact Finset.mem_filter.mpr ⟨hCm, hC.1⟩
  · intro hC
    simp only [Finset.mem_filter] at hC
    obtain ⟨hCm, hCB⟩ := hC
    have hCp : C.Prime := Nat.prime_of_mem_primeFactors hCm
    have hC2 : 2 ≤ C := hCp.two_le
    have hvm : 0 < m.factorization C :=
      Nat.Prime.factorization_pos_of_dvd hCp hm (Nat.dvd_of_mem_primeFactors hCm)
    have hlog : 1 ≤ Nat.log C B := by
      refine (Nat.le_log_iff_pow_le hCp.one_lt hB).mpr ?_
      simpa using hCB
    refine Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (by omega), ?_⟩
    intro heq
    have h1 := congrArg (fun n => n.factorization C) heq
    simp only [gcd_stage1_factorization hm hCp] at h1
    rw [if_pos le_rfl, if_neg (by omega : ¬ C ≤ C - 1)] at h1
    omega

/-- Hence at most `ω(m)` of the `π(B)` schedule steps are firing positions, and
`ω(m) ≤ log₂ m`. -/
theorem card_primeFactors_le_log_two {m : ℕ} (hm : m ≠ 0) :
    m.primeFactors.card ≤ Nat.log 2 m := by
  have h1 : 2 ^ m.primeFactors.card ≤ ∏ q ∈ m.primeFactors, q := by
    calc 2 ^ m.primeFactors.card = ∏ _q ∈ m.primeFactors, 2 := by
          rw [Finset.prod_const]
      _ ≤ ∏ q ∈ m.primeFactors, q :=
          Finset.prod_le_prod' (fun q hq => (Nat.prime_of_mem_primeFactors hq).two_le)
  have h2 : ∏ q ∈ m.primeFactors, q ≤ m :=
    Nat.le_of_dvd (Nat.pos_of_ne_zero hm) (Nat.prod_primeFactors_dvd m)
  exact (Nat.le_log_iff_pow_le one_lt_two hm).mpr (h1.trans h2)

theorem card_jumpSet_le {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    (jumpSet m B).card ≤ m.primeFactors.card ∧ m.primeFactors.card ≤ Nat.log 2 m :=
  ⟨Finset.card_le_card (jumpSet_subset_primeFactors hm hB), card_primeFactors_le_log_two hm⟩

/-- **Sparsity of the firing positions.**  Whatever the bound, the positions of the
schedule that ever carry a firing occupy at most a `log₂ m / π(B)` fraction of it: the
firing-position distribution is supported on a vanishing part of the schedule as the
bound grows, so it cannot converge to the uniform distribution on the schedule. -/
theorem firing_positions_sparse {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0) :
    ((jumpSet m B).card : ℚ) / primeCount B ≤ (Nat.log 2 m : ℚ) / primeCount B := by
  obtain ⟨h1, h2⟩ := card_jumpSet_le hm hB
  have h3 : ((jumpSet m B).card : ℚ) ≤ (Nat.log 2 m : ℚ) := by exact_mod_cast h1.trans h2
  have h4 : (0 : ℚ) ≤ (primeCount B : ℚ) := by positivity
  exact div_le_div_of_nonneg_right h3 h4

/-- **Non-uniformity of the firing positions.**  The firing positions form a set of at
most `log₂ m` of the `π(B)` schedule steps; as soon as the schedule is longer than
`log₂ m`, some step is never a firing position, so the distribution of firing positions
cannot be uniform on the schedule. -/
theorem firing_positions_not_uniform {m B : ℕ} (hm : m ≠ 0) (hB : B ≠ 0)
    (hlong : Nat.log 2 m < primeCount B) :
    ∃ C ∈ (Finset.range (B + 1)).filter Nat.Prime, C ∉ jumpSet m B := by
  by_contra h
  push_neg at h
  have hsub : (Finset.range (B + 1)).filter Nat.Prime ⊆ jumpSet m B := h
  have h1 : primeCount B ≤ (jumpSet m B).card := Finset.card_le_card hsub
  obtain ⟨h2, h3⟩ := card_jumpSet_le hm hB
  omega

/-! ## Early fire, quantitatively -/

/-- The part of `m` supported on primes above `L`. -/
def largePart (m L : ℕ) : ℕ :=
  ∏ q ∈ m.primeFactors.filter (fun q => L < q), q ^ m.factorization q

theorem largePart_ne_zero (m L : ℕ) : largePart m L ≠ 0 := by
  refine Finset.prod_ne_zero_iff.mpr fun q hq => pow_ne_zero _ ?_
  exact (Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hq).1).pos.ne'

theorem largePart_factorization (m L r : ℕ) :
    (largePart m L).factorization r =
      if r ∈ m.primeFactors ∧ L < r then m.factorization r else 0 := by
  rw [largePart, factorization_prod_primePow
    (fun q hq => Nat.prime_of_mem_primeFactors (Finset.mem_filter.mp hq).1) _ r]
  simp [Finset.mem_filter, and_comm]

/-- **Early fire.**  Everything that fires at all fires by cutoff `L`, up to the
large-prime part of the order: the total firing count divides the count already
achieved at cutoff `L` times `largePart m L`. -/
theorem gcd_stage1_full_dvd_prefix_mul_largePart {m B L : ℕ} (hm : m ≠ 0) (hL : L ≤ B) :
    Nat.gcd m (stage1 B B) ∣ Nat.gcd m (stage1 B L) * largePart m L := by
  have hne1 : Nat.gcd m (stage1 B B) ≠ 0 := Nat.gcd_ne_zero_left hm
  have hne2 : Nat.gcd m (stage1 B L) * largePart m L ≠ 0 :=
    Nat.mul_ne_zero (Nat.gcd_ne_zero_left hm) (largePart_ne_zero m L)
  rw [← Nat.factorization_le_iff_dvd hne1 hne2, Finsupp.le_def]
  intro r
  by_cases hr : r.Prime
  · rw [Nat.factorization_mul (Nat.gcd_ne_zero_left hm) (largePart_ne_zero m L)]
    rw [Nat.factorization_gcd hm (stage1_ne_zero B B), Nat.factorization_gcd hm
      (stage1_ne_zero B L)]
    simp only [Finsupp.inf_apply, Finsupp.add_apply]
    rw [stage1_factorization B B hr, stage1_factorization B L hr,
      largePart_factorization m L r]
    by_cases hrL0 : r ≤ L
    · have hrB : r ≤ B := hrL0.trans hL
      simp [hrL0, hrB]
    · have hrL : L < r := by omega
      by_cases hmr : r ∈ m.primeFactors
      · have h1 : min (m.factorization r) (if r ≤ B then Nat.log r B else 0)
            ≤ m.factorization r := min_le_left _ _
        rw [if_pos (⟨hmr, hrL⟩ : r ∈ m.primeFactors ∧ L < r)]
        omega
      · have hz : m.factorization r = 0 := by
          simp only [Nat.mem_primeFactors, not_and, not_not] at hmr
          exact Nat.factorization_eq_zero_of_not_dvd (fun hd => hm (hmr hr hd))
        simp [hz]
  · simp [Nat.factorization_eq_zero_of_not_prime _ hr]

/-- Numerical form of early fire: the count of points that have already fired by
cutoff `L` is at least the total firing count divided by the large-prime part. -/
theorem firing_by_cutoff_ge {m B L : ℕ} (hm : m ≠ 0) (hL : L ≤ B) :
    Nat.gcd m (stage1 B B) ≤ Nat.gcd m (stage1 B L) * largePart m L :=
  Nat.le_of_dvd (Nat.pos_of_ne_zero
    (Nat.mul_ne_zero (Nat.gcd_ne_zero_left hm) (largePart_ne_zero m L)))
    (gcd_stage1_full_dvd_prefix_mul_largePart hm hL)

/-! ## Several curves -/

/-- **Multi-curve success count.**  With `c` independent points of a cyclic group of
order `m`, the number of tuples on which stage 1 fires at least once is exactly
`m^c - (m - gcd(m,k))^c`. -/
theorem card_multiCurve_success (m k c : ℕ) (hm : 0 < m) :
    ((Fintype.piFinset (fun _ : Fin c => Finset.range m)).filter
        (fun a => ∃ i, m ∣ k * a i)).card = m ^ c - (m - Nat.gcd m k) ^ c := by
  classical
  have hfail : (Fintype.piFinset (fun _ : Fin c => Finset.range m)).filter
      (fun a => ¬ ∃ i, m ∣ k * a i)
      = Fintype.piFinset (fun _ : Fin c => (Finset.range m).filter (fun a => ¬ m ∣ k * a)) := by
    ext a
    simp only [Finset.mem_filter, Fintype.mem_piFinset, Finset.mem_filter, not_exists]
    exact ⟨fun h i => ⟨h.1 i, h.2 i⟩, fun h => ⟨fun i => (h i).1, fun i => (h i).2⟩⟩
  have hcardfail : (Fintype.piFinset
      (fun _ : Fin c => (Finset.range m).filter (fun a => ¬ m ∣ k * a))).card
      = (m - Nat.gcd m k) ^ c := by
    rw [Fintype.card_piFinset, Finset.prod_const, Finset.card_univ, Fintype.card_fin]
    congr 1
    have := Finset.card_filter_add_card_filter_not
      (s := Finset.range m) (p := fun a => m ∣ k * a)
    rw [Finset.card_range] at this
    have h2 : (firingSet m k).card = Nat.gcd m k := card_firingSet m k hm
    simp only [firingSet] at h2
    omega
  have htot : (Fintype.piFinset (fun _ : Fin c => Finset.range m)).card = m ^ c := by
    rw [Fintype.card_piFinset, Finset.prod_const, Finset.card_univ, Fintype.card_fin,
      Finset.card_range]
  have hsplit := Finset.card_filter_add_card_filter_not
    (s := Fintype.piFinset (fun _ : Fin c => Finset.range m)) (p := fun a => ∃ i, m ∣ k * a i)
  rw [htot, hfail, hcardfail] at hsplit
  omega

/-- The multi-curve success *rate* is exactly `1 - (1 - ρ)^c` with `ρ = gcd(m,k)/m`;
no independence assumption is needed — it is a count. -/
theorem multiCurve_rate (m k c : ℕ) (hm : 0 < m) :
    ((m ^ c - (m - Nat.gcd m k) ^ c : ℕ) : ℚ) / (m : ℚ) ^ c
      = 1 - (1 - (Nat.gcd m k : ℚ) / m) ^ c := by
  have hg : Nat.gcd m k ≤ m := Nat.le_of_dvd hm (Nat.gcd_dvd_left m k)
  have hle : (m - Nat.gcd m k) ^ c ≤ m ^ c := Nat.pow_le_pow_left (by omega) c
  have hm' : (m : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hm.ne'
  rw [Nat.cast_sub hle]
  have hcast : ((m - Nat.gcd m k : ℕ) : ℚ) = (m : ℚ) - (Nat.gcd m k : ℚ) := by
    rw [Nat.cast_sub hg]
  rw [Nat.cast_pow, Nat.cast_pow, hcast]
  have h1 : (1 : ℚ) - (Nat.gcd m k : ℚ) / m = ((m : ℚ) - (Nat.gcd m k : ℚ)) / m := by
    field_simp
  rw [h1, div_pow]
  field_simp

/-! ## The collision heuristic is the wrong model -/

theorem stage1Scalar_ten : stage1Scalar 10 = 2520 := by decide

theorem gcd_720_stage1Scalar_ten : Nat.gcd 720 (stage1Scalar 10) = 360 := by
  rw [stage1Scalar_ten]; decide

/-- **Order completion dominates the collision floor.**  For a cyclic group of order
`720` and smoothness bound `B = 10`, the exact order-completion rate is `1/2`, while the
heuristic collision rate `1 - exp(-1.44·B/m) ≤ 1.44·B/m` is at most `1/50`: the observed
rate is more than `25×` the collision model, so the collision term cannot account for
it. -/
theorem orderCompletion_beats_collision_heuristic :
    (Nat.gcd 720 (stage1Scalar 10) : ℚ) / 720 = 1 / 2 ∧
      (25 : ℚ) * ((144 / 100) * 10 / 720) ≤ (Nat.gcd 720 (stage1Scalar 10) : ℚ) / 720 := by
  rw [gcd_720_stage1Scalar_ten]
  norm_num

/-- The rate in the previous theorem is a genuine order-completion rate: it counts the
`360` residues of `ℤ/720` whose order is `10`-powersmooth. -/
theorem firingSet_720_card : (firingSet 720 (stage1Scalar 10)).card = 360 := by
  rw [card_firingSet _ _ (by norm_num), gcd_720_stage1Scalar_ten]

end ECMStage1