import Mathlib

/-!
# The permutation readout of individual orders: exact cycle structure

This file formalises the arithmetic core of the PERMORD experiment
(`33_Permutation_Readout_Asymmetry.md`).  The object under study is the
permutation

  `σ_a : ZMod N → ZMod N`,   `σ_a x = a * x`   (`gcd(a, N) = 1`)

of the *whole ring* `ZMod N`, not just of its unit group.  The unit group only
ever exposes the symmetric datum `ord_N(a) = lcm(ord_p(a), ord_q(a))`; the
permutation of the full ring is strictly finer, because it also acts on the
non-unit strata.

The main structural theorem is the **stratification law**: for `d ∣ N` the
stratum `S_d = {x : gcd(N, x) = d}` is `σ_a`-invariant, has cardinality
`φ(N/d)`, and *every* element of it lies on a cycle of length exactly
`ord_{N/d}(a)`.  Consequently the number of cycles inside `S_d` is
`φ(N/d) / ord_{N/d}(a)` and the total cycle count is the sum of these over the
divisors of `N`.

## Main results

* `Physics.PermReadout.dvd_mul_gcd_iff` — the divisibility core
  `N ∣ m * x ↔ (N / gcd(N,x)) ∣ m`.
* `Physics.PermReadout.modEq_iff_period_dvd` — `a^k x ≡ x (mod N)` iff
  `ord_{N/gcd(N,x)}(a) ∣ k`: the period of `x` is exactly the order of `a`
  modulo the *reduced modulus* `N / gcd(N,x)`.
* `Physics.PermReadout.card_orb` — the cycle through `x` has exactly
  `period N a x` elements.
* `Physics.PermReadout.card_stratum` — `|S_d| = φ(N/d)`.
* `Physics.PermReadout.stratum_card_eq_cycles_mul_period` — `φ(N/d)` is the
  number of cycles in `S_d` times the common cycle length.
* `Physics.PermReadout.cycleCount_eq_sum` — the total number of cycles of
  `σ_a` is `∑_{d ∣ N} φ(N/d) / ord_{N/d}(a)`.
-/

namespace Physics.PermReadout

open Finset

/-! ## The divisibility core -/

/-- **Reduction of the modulus.**  Multiples of `x` are killed modulo `N`
exactly when the multiplier is killed modulo the reduced modulus
`N / gcd(N, x)`.  This single fact is what makes the individual orders
`ord_p(a)`, `ord_q(a)` visible as cycle lengths. -/
theorem dvd_mul_gcd_iff {N x m : ℕ} (hN : 0 < N) :
    N ∣ m * x ↔ N / Nat.gcd N x ∣ m := by
  set d := Nat.gcd N x with hd
  have hd0 : 0 < d := Nat.gcd_pos_of_pos_left _ hN
  have hNd : N = d * (N / d) := (Nat.mul_div_cancel' (Nat.gcd_dvd_left N x)).symm
  have hxd : x = d * (x / d) := (Nat.mul_div_cancel' (Nat.gcd_dvd_right N x)).symm
  have hcop : Nat.Coprime (N / d) (x / d) := Nat.coprime_div_gcd_div_gcd hd0
  constructor
  · intro h
    rw [hNd, hxd] at h
    have h2 : (N / d) ∣ m * (x / d) := by
      have h3 : d * (N / d) ∣ d * (m * (x / d)) := by
        calc d * (N / d) ∣ m * (d * (x / d)) := h
          _ = d * (m * (x / d)) := by ring
      exact (mul_dvd_mul_iff_left hd0.ne').mp h3
    exact hcop.dvd_of_dvd_mul_right h2
  · rintro ⟨c, rfl⟩
    refine ⟨c * (x / d), ?_⟩
    calc (N / d * c) * x = (N / d * c) * (d * (x / d)) := by rw [← hxd]
      _ = (d * (N / d)) * (c * (x / d)) := by ring
      _ = N * (c * (x / d)) := by rw [← hNd]

/-! ## The period of a point -/

/-- The cycle length of `x` under `y ↦ a * y` on `ZMod N`: the order of `a`
modulo the reduced modulus `N / gcd(N, x)`. -/
noncomputable def period (N a x : ℕ) : ℕ := orderOf ((a : ZMod (N / Nat.gcd N x)))

/-- **Stratified period law.**  `a^k` fixes `x` modulo `N` precisely when the
order of `a` modulo `N / gcd(N,x)` divides `k`. -/
theorem modEq_iff_period_dvd {N a x k : ℕ} (hN : 0 < N) (hcop : Nat.Coprime a N) :
    a ^ k * x ≡ x [MOD N] ↔ period N a x ∣ k := by
  rcases Nat.eq_zero_or_pos a with rfl | ha0
  · have hN1 : N = 1 := Nat.coprime_zero_left N |>.mp hcop
    subst hN1
    have hp1 : period 1 0 x = 1 := by
      unfold period
      rw [Nat.gcd_one_left, Nat.div_one]
      exact orderOf_eq_one_iff.mpr (Subsingleton.elim _ _)
    simp [hp1, Nat.modEq_one]
  have h1 : 1 ≤ a ^ k := Nat.one_le_pow _ _ ha0
  have hxle : x ≤ a ^ k * x := Nat.le_mul_of_pos_left _ (by omega)
  rw [Nat.ModEq.comm, Nat.modEq_iff_dvd' hxle, ← Nat.sub_one_mul, dvd_mul_gcd_iff hN,
    ← Nat.modEq_iff_dvd' h1]
  unfold period
  rw [orderOf_dvd_iff_pow_eq_one, Nat.ModEq.comm, ← ZMod.natCast_eq_natCast_iff]
  push_cast
  rfl

/-- The period is positive when `a` is invertible. -/
theorem period_pos {N a : ℕ} (hN : 0 < N) (hcop : Nat.Coprime a N) (x : ℕ) :
    0 < period N a x := by
  set M := N / Nat.gcd N x with hM
  have hdvd : M ∣ N := Nat.div_dvd_of_dvd (Nat.gcd_dvd_left N x)
  have hM0 : 0 < M := Nat.pos_of_dvd_of_pos hdvd hN
  haveI : NeZero M := ⟨hM0.ne'⟩
  have hcM : Nat.Coprime a M := Nat.Coprime.coprime_dvd_right hdvd hcop
  obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a M).mpr hcM
  show 0 < orderOf ((a : ZMod M))
  rw [← hu, orderOf_units]
  exact (isOfFinOrder_of_finite u).orderOf_pos

/-- `gcd` is insensitive to reduction mod `N`. -/
theorem gcd_mod_self (N m : ℕ) : Nat.gcd N (m % N) = Nat.gcd N m := by
  conv_rhs => rw [Nat.gcd_rec]
  rw [Nat.gcd_comm]

/-! ## Orbits (cycles) of the permutation -/

section Orbits

variable {N : ℕ} [NeZero N] {a : ℕ}

/-- The stratum label of a point: `gcd(N, x)`. -/
def strat (N : ℕ) [NeZero N] (x : ZMod N) : ℕ := Nat.gcd N x.val

theorem strat_dvd (x : ZMod N) : strat N x ∣ N := Nat.gcd_dvd_left _ _

/-- Fixed points of `a ^ k` in `ZMod N`, read as a congruence between naturals. -/
theorem pow_mul_eq_self_iff_modEq (x : ZMod N) (k : ℕ) :
    ((a : ZMod N) ^ k * x = x) ↔ (a ^ k * x.val ≡ x.val [MOD N]) := by
  rw [← ZMod.natCast_eq_natCast_iff]
  push_cast
  simp [ZMod.natCast_val, ZMod.cast_id]

/-- **The `ZMod`-level stratified period law.**  The point `x` is fixed by `a ^ k`
iff the order of `a` modulo the reduced modulus `N / gcd(N, x)` divides `k`. -/
theorem pow_mul_eq_self_iff (hcop : Nat.Coprime a N) (x : ZMod N) (k : ℕ) :
    (a : ZMod N) ^ k * x = x ↔ period N a x.val ∣ k := by
  rw [pow_mul_eq_self_iff_modEq,
    modEq_iff_period_dvd (Nat.pos_of_ne_zero (NeZero.ne N)) hcop]

/-- Multiplying by a unit does not move a point between strata. -/
theorem strat_pow_mul (hcop : Nat.Coprime a N) (x : ZMod N) (k : ℕ) :
    strat N ((a : ZMod N) ^ k * x) = strat N x := by
  have hval : ((a : ZMod N) ^ k * x).val = (a ^ k * x.val) % N := by
    rw [← Nat.cast_pow, ZMod.val_mul, ZMod.val_natCast, Nat.mod_mul_mod]
  have hck : Nat.Coprime (a ^ k) N := Nat.Coprime.pow_left _ hcop
  unfold strat
  rw [hval, gcd_mod_self, Nat.gcd_comm, hck.gcd_mul_left_cancel _, Nat.gcd_comm]

/-- The period only depends on the stratum. -/
theorem period_eq_of_strat_eq {x y : ZMod N} (h : strat N x = strat N y) :
    period N a x.val = period N a y.val := by
  simp only [period]
  rw [show Nat.gcd N x.val = Nat.gcd N y.val from h]

/-- The cycle (orbit) through `x`. -/
noncomputable def orb (N a : ℕ) [NeZero N] (x : ZMod N) : Finset (ZMod N) :=
  (Finset.range (period N a x.val)).image (fun k => (a : ZMod N) ^ k * x)

theorem mem_orb_iff (hcop : Nat.Coprime a N) (x y : ZMod N) :
    y ∈ orb N a x ↔ ∃ k, (a : ZMod N) ^ k * x = y := by
  constructor
  · intro h
    rw [orb, Finset.mem_image] at h
    obtain ⟨k, -, hk⟩ := h
    exact ⟨k, hk⟩
  · rintro ⟨k, rfl⟩
    set L := period N a x.val with hL
    have hL0 : 0 < L := period_pos (Nat.pos_of_ne_zero (NeZero.ne N)) hcop x.val
    refine Finset.mem_image.mpr ⟨k % L, Finset.mem_range.mpr (Nat.mod_lt _ hL0), ?_⟩
    have hfix : (a : ZMod N) ^ (L * (k / L)) * x = x :=
      (pow_mul_eq_self_iff hcop x _).mpr ⟨k / L, rfl⟩
    calc (a : ZMod N) ^ (k % L) * x
        = (a : ZMod N) ^ (k % L) * ((a : ZMod N) ^ (L * (k / L)) * x) := by rw [hfix]
      _ = (a : ZMod N) ^ (k % L + L * (k / L)) * x := by rw [pow_add]; ring
      _ = (a : ZMod N) ^ k * x := by rw [Nat.mod_add_div]

theorem self_mem_orb (hcop : Nat.Coprime a N) (x : ZMod N) : x ∈ orb N a x :=
  (mem_orb_iff hcop x x).mpr ⟨0, by simp⟩

/-- Every point of a cycle lies in the same stratum as its base point. -/
theorem strat_of_mem_orb (hcop : Nat.Coprime a N) {x y : ZMod N} (hy : y ∈ orb N a x) :
    strat N y = strat N x := by
  obtain ⟨k, rfl⟩ := (mem_orb_iff hcop x y).mp hy
  exact strat_pow_mul hcop x k

/-- **Cycle length = order of `a` modulo the reduced modulus.** -/
theorem card_orb (hcop : Nat.Coprime a N) (x : ZMod N) :
    (orb N a x).card = period N a x.val := by
  set L := period N a x.val with hL
  have hunit : IsUnit ((a : ZMod N)) := (ZMod.isUnit_iff_coprime a N).mpr hcop
  rw [orb, Finset.card_image_of_injOn, Finset.card_range]
  intro i hi j hj hij
  simp only [Finset.coe_range, Set.mem_Iio] at hi hj
  rcases le_total i j with h | h
  · obtain ⟨t, rfl⟩ := Nat.exists_eq_add_of_le h
    have hcancel : (a : ZMod N) ^ t * x = x := by
      refine (hunit.pow i).mul_left_cancel ?_
      calc (a : ZMod N) ^ i * ((a : ZMod N) ^ t * x)
          = (a : ZMod N) ^ (i + t) * x := by rw [pow_add]; ring
        _ = (a : ZMod N) ^ i * x := hij.symm
    have := (pow_mul_eq_self_iff hcop x t).mp hcancel
    have ht : t = 0 := by
      rcases Nat.eq_zero_or_pos t with h0 | h0
      · exact h0
      · exact absurd (Nat.le_of_dvd h0 this) (by omega)
    omega
  · obtain ⟨t, rfl⟩ := Nat.exists_eq_add_of_le h
    have hcancel : (a : ZMod N) ^ t * x = x := by
      refine (hunit.pow j).mul_left_cancel ?_
      calc (a : ZMod N) ^ j * ((a : ZMod N) ^ t * x)
          = (a : ZMod N) ^ (j + t) * x := by rw [pow_add]; ring
        _ = (a : ZMod N) ^ j * x := hij
    have := (pow_mul_eq_self_iff hcop x t).mp hcancel
    have ht : t = 0 := by
      rcases Nat.eq_zero_or_pos t with h0 | h0
      · exact h0
      · exact absurd (Nat.le_of_dvd h0 this) (by omega)
    omega

/-- Cycles are equal or disjoint: the orbit of a point of a cycle is that cycle. -/
theorem orb_eq_of_mem (hcop : Nat.Coprime a N) {x y : ZMod N} (hy : y ∈ orb N a x) :
    orb N a y = orb N a x := by
  obtain ⟨k, rfl⟩ := (mem_orb_iff hcop x y).mp hy
  set L := period N a x.val with hL
  have hL0 : 0 < L := period_pos (Nat.pos_of_ne_zero (NeZero.ne N)) hcop x.val
  have hback : (a : ZMod N) ^ (L * k - k) * ((a : ZMod N) ^ k * x) = x := by
    have hk : k ≤ L * k := Nat.le_mul_of_pos_left _ hL0
    have hfix : (a : ZMod N) ^ (L * k) * x = x :=
      (pow_mul_eq_self_iff hcop x _).mpr ⟨k, rfl⟩
    calc (a : ZMod N) ^ (L * k - k) * ((a : ZMod N) ^ k * x)
          = (a : ZMod N) ^ (L * k - k + k) * x := by rw [pow_add]; ring
      _ = (a : ZMod N) ^ (L * k) * x := by rw [Nat.sub_add_cancel hk]
      _ = x := hfix
  ext z
  rw [mem_orb_iff hcop, mem_orb_iff hcop]
  constructor
  · rintro ⟨m, rfl⟩
    exact ⟨m + k, by rw [pow_add]; ring⟩
  · rintro ⟨m, rfl⟩
    refine ⟨m + (L * k - k), ?_⟩
    calc (a : ZMod N) ^ (m + (L * k - k)) * ((a : ZMod N) ^ k * x)
        = (a : ZMod N) ^ m * ((a : ZMod N) ^ (L * k - k) * ((a : ZMod N) ^ k * x)) := by
          rw [pow_add]; ring
      _ = (a : ZMod N) ^ m * x := by rw [hback]

/-! ## Strata and the exact cycle count -/

/-- The stratum `S_d = {x : gcd(N, x) = d}`. -/
noncomputable def stratum (N : ℕ) [NeZero N] (d : ℕ) : Finset (ZMod N) :=
  Finset.univ.filter (fun x => strat N x = d)

@[simp] theorem mem_stratum {d : ℕ} {x : ZMod N} : x ∈ stratum N d ↔ strat N x = d := by
  simp [stratum]

/-- **Stratum size.**  `|S_d| = φ(N/d)` for every divisor `d` of `N`. -/
theorem card_stratum {d : ℕ} (hd : d ∣ N) :
    (stratum N d).card = Nat.totient (N / d) := by
  rw [Nat.totient_div_of_dvd hd]
  refine Finset.card_bij (fun x _ => x.val) ?_ ?_ ?_
  · intro x hx
    simp only [mem_stratum, strat] at hx
    exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (ZMod.val_lt x), hx⟩
  · intro x _ y _ h
    exact ZMod.val_injective N h
  · intro b hb
    rw [Finset.mem_filter, Finset.mem_range] at hb
    refine ⟨(b : ZMod N), ?_, ?_⟩
    · simp only [mem_stratum, strat, ZMod.val_natCast_of_lt hb.1]
      exact hb.2
    · exact ZMod.val_natCast_of_lt hb.1

/-- Inside a stratum, all cycles have the same length `ord_{N/d}(a)`. -/
theorem period_of_mem_stratum {d : ℕ} {x : ZMod N} (hx : x ∈ stratum N d) :
    period N a x.val = orderOf ((a : ZMod (N / d))) := by
  simp only [mem_stratum, strat] at hx
  subst hx
  rfl

/-- The fibre of the orbit map over a cycle `o` meeting the stratum is `o` itself. -/
theorem fiber_eq_orb (hcop : Nat.Coprime a N) {d : ℕ} {x : ZMod N} (hx : x ∈ stratum N d) :
    (stratum N d).filter (fun y => orb N a y = orb N a x) = orb N a x := by
  ext z
  simp only [Finset.mem_filter, mem_stratum]
  constructor
  · rintro ⟨-, hz⟩
    rw [← hz]
    exact self_mem_orb hcop z
  · intro hz
    have hzx : orb N a z = orb N a x := orb_eq_of_mem hcop hz
    refine ⟨?_, hzx⟩
    rw [strat_of_mem_orb hcop hz]
    exact mem_stratum.mp hx

/-- **Cycle decomposition of a stratum.**  `φ(N/d)` equals the number of cycles inside
`S_d` times the common cycle length `ord_{N/d}(a)`. -/
theorem stratum_card_eq_cycles_mul_period (hcop : Nat.Coprime a N) {d : ℕ} (hd : d ∣ N) :
    Nat.totient (N / d) =
      ((stratum N d).image (fun x => orb N a x)).card * orderOf ((a : ZMod (N / d))) := by
  rw [← card_stratum hd, Finset.card_eq_sum_card_image (fun x => orb N a x)]
  rw [Finset.sum_congr rfl (g := fun _ => orderOf ((a : ZMod (N / d)))) ?_,
    Finset.sum_const, smul_eq_mul]
  intro o ho
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp ho
  rw [fiber_eq_orb hcop hx, card_orb hcop, period_of_mem_stratum hx]

/-- The number of cycles inside the stratum `S_d`. -/
noncomputable def cyclesIn (N a : ℕ) [NeZero N] (d : ℕ) : ℕ :=
  ((stratum N d).image (fun x => orb N a x)).card

/-- The number of cycles inside `S_d` is exactly `φ(N/d) / ord_{N/d}(a)`. -/
theorem cyclesIn_eq (hcop : Nat.Coprime a N) {d : ℕ} (hd : d ∣ N) :
    cyclesIn N a d = Nat.totient (N / d) / orderOf ((a : ZMod (N / d))) := by
  have hdN : (N / d) ∣ N := Nat.div_dvd_of_dvd hd
  have hpos : 0 < orderOf ((a : ZMod (N / d))) := by
    have hN0 : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
    have hM0 : 0 < N / d := Nat.pos_of_dvd_of_pos hdN hN0
    haveI : NeZero (N / d) := ⟨hM0.ne'⟩
    obtain ⟨u, hu⟩ := (ZMod.isUnit_iff_coprime a (N / d)).mpr
      (Nat.Coprime.coprime_dvd_right hdN hcop)
    rw [← hu, orderOf_units]
    exact (isOfFinOrder_of_finite u).orderOf_pos
  rw [stratum_card_eq_cycles_mul_period hcop hd, Nat.mul_div_cancel _ hpos, cyclesIn]

/-- The total number of cycles of `x ↦ a * x` on `ZMod N`. -/
noncomputable def cycleCount (N a : ℕ) [NeZero N] : ℕ :=
  (Finset.univ.image (fun x : ZMod N => orb N a x)).card

/-- **The exact cycle count.**  The permutation `x ↦ a·x` of `ZMod N` has
`∑_{d ∣ N} φ(N/d) / ord_{N/d}(a)` cycles. -/
theorem cycleCount_eq_sum (hcop : Nat.Coprime a N) :
    cycleCount N a = ∑ d ∈ N.divisors, Nat.totient (N / d) / orderOf ((a : ZMod (N / d))) := by
  have hN0 : N ≠ 0 := NeZero.ne N
  have huniv : (Finset.univ : Finset (ZMod N)) = N.divisors.biUnion (fun d => stratum N d) := by
    ext x
    simp only [Finset.mem_univ, true_iff, Finset.mem_biUnion, mem_stratum]
    exact ⟨strat N x, Nat.mem_divisors.mpr ⟨strat_dvd x, hN0⟩, rfl⟩
  have hdisj : (↑N.divisors : Set ℕ).PairwiseDisjoint
      (fun d => (stratum N d).image (fun x => orb N a x)) := by
    intro d _ e _ hde
    refine Finset.disjoint_left.mpr ?_
    intro o hod hoe
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hod
    obtain ⟨y, hy, hxy⟩ := Finset.mem_image.mp hoe
    apply hde
    have hxmem : x ∈ orb N a y := by rw [hxy]; exact self_mem_orb hcop x
    have := strat_of_mem_orb hcop hxmem
    rw [← mem_stratum.mp hx, ← mem_stratum.mp hy, this]
  rw [cycleCount, huniv, Finset.biUnion_image, Finset.card_biUnion hdisj]
  refine Finset.sum_congr rfl (fun d hd => ?_)
  exact cyclesIn_eq hcop (Nat.dvd_of_mem_divisors hd)

/-! ## The cycle spectrum is a complete invariant of the local orders -/

/-- The cycle through the ring element `d`, for `d` a proper divisor of `N`, has
exactly `ord_{N/d}(a)` points. -/
theorem card_orb_at_divisor (hcop : Nat.Coprime a N) {d : ℕ} (hd : d < N) :
    (orb N a ((d : ZMod N))).card = orderOf ((a : ZMod (N / Nat.gcd N d))) := by
  rw [card_orb hcop, ZMod.val_natCast_of_lt hd]
  rfl

/-- **The readout sees exactly the family of local orders.**  Two multipliers
induce the same cycle lengths at every point of `ZMod N` if and only if they
have the same order modulo every divisor of `N`.  Nothing more, nothing less:
the permutation readout is a complete — and completely local — invariant. -/
theorem cycle_lengths_eq_iff_local_orders_eq {b : ℕ} (hcopa : Nat.Coprime a N)
    (hcopb : Nat.Coprime b N) :
    (∀ x : ZMod N, (orb N a x).card = (orb N b x).card) ↔
      (∀ M : ℕ, M ∣ N → orderOf ((a : ZMod M)) = orderOf ((b : ZMod M))) := by
  constructor
  · intro h M hM
    have hN0 : 0 < N := Nat.pos_of_ne_zero (NeZero.ne N)
    have hM0 : 0 < M := Nat.pos_of_dvd_of_pos hM hN0
    rcases eq_or_ne M 1 with rfl | hM1
    · rw [orderOf_eq_one_iff.mpr (Subsingleton.elim _ _),
        orderOf_eq_one_iff.mpr (Subsingleton.elim _ _)]
    set d := N / M with hd
    have hdM : N / d = M := Nat.div_div_self hM hN0.ne'
    have hdN : d < N := Nat.div_lt_self hN0 (by omega)
    have hgcd : Nat.gcd N d = d := Nat.gcd_eq_right (Nat.div_dvd_of_dvd hM)
    have := h ((d : ZMod N))
    rwa [card_orb_at_divisor hcopa hdN, card_orb_at_divisor hcopb hdN, hgcd, hdM] at this
  · intro h x
    rw [card_orb hcopa, card_orb hcopb]
    exact h _ (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left N x.val))

end Orbits

end Physics.PermReadout