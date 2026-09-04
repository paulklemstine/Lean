import Applications.BatchSmoothnessCorrectness

/-!
# Prime-power hits and the smoothness budget

This file formalises the mechanism behind experiment 505
("PRIME-POWER-CARRIES"): among candidates that survive a `B`-smoothness test,
the feature "`p ^ 2 ∣ v` for a small prime `p`" carries information that the
marginal squarefree-hit features ("`p ∣ v`") provably cannot see, and it acts on
the smoothness parameter `u = log x / log B` by an exact shift.

Everything is built on the smoothness predicate of
`Catalog/Applications/BatchSmoothnessCorrectness.lean` (`BatchSmoothness.IsSmooth`,
`BatchSmoothness.primorialUpTo`), which is the decision procedure the batch
pipeline actually runs.

## Main results

* `hitCount_eq_smoothCount` — **exact rescaling.**  For a positive `B`-smooth
  modulus `m`, the number of `B`-smooth `v ≤ x` with `m ∣ v` is *exactly*
  `Ψ_B(x / m)`.  The hit feature is a change of the smoothness budget, not a
  new arithmetic condition.
* `hitCount_primeSq`, `hitCount_two_primeSq` — the `p²`-hit and the joint
  `p²q²`-hit specialisations (inclusion of two prime-power features).
* `gradeCount_eq_sub` — the **graded spectrum**: the number of smooth `v ≤ x`
  with `v_p(v) = j` is `Ψ_B(x / p^j) - Ψ_B(x / p^(j+1))`, so the whole
  valuation profile is a telescoping family of rescaled counts.
* `uParam_eq_of_sq_dvd`, `uParam_hit_le` — the **budget shift**: hitting `p²`
  subtracts exactly `2 log p / log B` from `u`.
* `shift_antitone_in_B` — the **tight-`u` mechanism**: the same prime-power hit
  costs *more* budget at smaller `B`, which is why the feature earns its weight
  precisely in the tight-`u` regime.
* `squarefree_features_blind` — the squarefree-hit vector has infinite fibres of
  unbounded `Ω`: it cannot determine the budget.
* `powHits_separates` — the prime-power feature strictly refines the squarefree
  feature: it separates `v` from `p·v` where the squarefree vector cannot.
* `ordCompl_le_of_sq_dvd` — the mechanism in raw form: a `p²`-hit squeezes the
  cofactor available to the other primes by a factor `p²`.
* `smoothCount_two`, `hitCount_two_four` — the exactly solvable case `B = 2`:
  `Ψ_2(x) = ⌊log₂ x⌋ + 1` and the `4`-hit consumes exactly two units of budget.
-/

namespace PrimePowerBudget

open Finset BatchSmoothness

/-! ## Smoothness, in decidable counting form -/

/-- Decidable form of `B`-smoothness used for counting; on positive inputs it
agrees with `BatchSmoothness.IsSmooth` (`Sm_iff_isSmooth`). -/
def Sm (B v : ℕ) : Prop := ∀ p ∈ v.primeFactors, p ≤ B

instance (B v : ℕ) : Decidable (Sm B v) := by unfold Sm; infer_instance

lemma Sm_iff_isSmooth {B v : ℕ} (hv : v ≠ 0) : Sm B v ↔ IsSmooth B v :=
  (isSmooth_iff_primeFactors hv).symm

/-- Smoothness passes to divisors. -/
lemma Sm_of_dvd {B d n : ℕ} (hdn : d ∣ n) (hn : n ≠ 0) (h : Sm B n) : Sm B d := by
  intro p hp
  have hpp := Nat.prime_of_mem_primeFactors hp
  have hpd := Nat.dvd_of_mem_primeFactors hp
  exact h p (Nat.mem_primeFactors.mpr ⟨hpp, hpd.trans hdn, hn⟩)

/-- Smoothness is multiplicative. -/
lemma Sm_mul {B a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) (h1 : Sm B a) (h2 : Sm B b) :
    Sm B (a * b) := by
  intro p hp
  rw [Nat.primeFactors_mul ha hb, Finset.mem_union] at hp
  exact hp.elim (h1 p) (h2 p)

/-! ## Counting functions -/

/-- `Ψ_B(x)`: the number of `B`-smooth integers in `[1, x]`. -/
def smoothCount (B x : ℕ) : ℕ := ((Finset.Icc 1 x).filter (fun v => Sm B v)).card

/-- The number of `B`-smooth integers in `[1, x]` hit by the modulus `m`. -/
def hitCount (B m x : ℕ) : ℕ :=
  ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ m ∣ v)).card

/-- **Exact rescaling.**  For a positive `B`-smooth modulus `m`, the smooth
values hit by `m` are in bijection (`v ↦ v / m`) with *all* smooth values up to
`x / m`.  Hence a divisibility feature is exactly a shift of the smoothness
budget: `hitCount B m x = Ψ_B(x / m)`. -/
theorem hitCount_eq_smoothCount (B m x : ℕ) (hm : 0 < m) (hmB : Sm B m) :
    hitCount B m x = smoothCount B (x / m) := by
  unfold hitCount smoothCount
  refine Finset.card_bij' (fun v _ => v / m) (fun w _ => m * w) ?_ ?_ ?_ ?_
  · intro v hv
    simp only [Finset.mem_filter, Finset.mem_Icc] at hv ⊢
    obtain ⟨⟨hv1, hvx⟩, hsm, hdvd⟩ := hv
    refine ⟨⟨(Nat.one_le_div_iff hm).2 (Nat.le_of_dvd (by omega) hdvd),
      Nat.div_le_div_right hvx⟩, ?_⟩
    exact Sm_of_dvd (Nat.div_dvd_of_dvd hdvd) (by omega) hsm
  · intro w hw
    simp only [Finset.mem_filter, Finset.mem_Icc] at hw ⊢
    obtain ⟨⟨hw1, hwx⟩, hsm⟩ := hw
    have hmw : m * w ≤ x := by
      rw [Nat.mul_comm]
      exact (Nat.le_div_iff_mul_le hm).1 hwx
    exact ⟨⟨Nat.one_le_iff_ne_zero.2 (Nat.mul_ne_zero hm.ne' (by omega)), hmw⟩,
      Sm_mul hm.ne' (by omega) hmB hsm, Dvd.intro w rfl⟩
  · intro v hv
    simp only [Finset.mem_filter] at hv
    exact Nat.mul_div_cancel' hv.2.2
  · intro w _
    exact Nat.mul_div_cancel_left w hm

/-- The `p²`-hit count of experiment 505: smooth values divisible by the square
of a factor-base prime are counted by `Ψ_B` at the rescaled bound `x / p²`. -/
theorem hitCount_primeSq {B p : ℕ} (x : ℕ) (hp : p.Prime) (hpB : p ≤ B) :
    hitCount B (p ^ 2) x = smoothCount B (x / p ^ 2) := by
  refine hitCount_eq_smoothCount B _ x (pow_pos hp.pos 2) ?_
  intro q hq
  have : q = p := by
    have := Nat.prime_of_mem_primeFactors hq
    exact (Nat.prime_dvd_prime_iff_eq this hp).1
      (this.dvd_of_dvd_pow (Nat.dvd_of_mem_primeFactors hq))
  omega

/-- Two prime-power features fire together exactly as often as a single feature
with modulus `(p q)²`: the hit events are not independent, they compose
multiplicatively. -/
theorem hitCount_two_primeSq {B p q : ℕ} (x : ℕ) (hp : p.Prime) (hq : q.Prime)
    (hpq : p ≠ q) (hpB : p ≤ B) (hqB : q ≤ B) :
    ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ p ^ 2 ∣ v ∧ q ^ 2 ∣ v)).card
      = smoothCount B (x / (p ^ 2 * q ^ 2)) := by
  have hcop : Nat.Coprime (p ^ 2) (q ^ 2) :=
    Nat.Coprime.pow _ _ ((Nat.coprime_primes hp hq).2 hpq)
  have hset : ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ p ^ 2 ∣ v ∧ q ^ 2 ∣ v))
      = ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ (p ^ 2 * q ^ 2) ∣ v)) := by
    apply Finset.filter_congr
    intro v _
    constructor
    · rintro ⟨hs, h1, h2⟩; exact ⟨hs, Nat.Coprime.mul_dvd_of_dvd_of_dvd hcop h1 h2⟩
    · rintro ⟨hs, h⟩
      exact ⟨hs, (dvd_mul_right (p ^ 2) (q ^ 2)).trans h, (dvd_mul_left (q ^ 2) (p ^ 2)).trans h⟩
  rw [hset]
  refine hitCount_eq_smoothCount B _ x (Nat.mul_pos (pow_pos hp.pos 2) (pow_pos hq.pos 2)) ?_
  refine Sm_mul (pow_pos hp.pos 2).ne' (pow_pos hq.pos 2).ne' ?_ ?_ <;>
  · intro r hr
    have hrp := Nat.prime_of_mem_primeFactors hr
    have := hrp.dvd_of_dvd_pow (Nat.dvd_of_mem_primeFactors hr)
    first
      | (have : r = p := (Nat.prime_dvd_prime_iff_eq hrp hp).1 this; omega)
      | (have : r = q := (Nat.prime_dvd_prime_iff_eq hrp hq).1 this; omega)

/-! ## The graded valuation spectrum -/

/-- The `p`-adic grading of the smooth pool: smooth `v ≤ x` with `v_p(v) = j`.
Its cardinality telescopes the rescaled counts. -/
theorem gradeCount_eq_sub {B p : ℕ} (x j : ℕ) (hp : p.Prime) (hpB : p ≤ B) :
    ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ v.factorization p = j)).card
      = smoothCount B (x / p ^ j) - smoothCount B (x / p ^ (j + 1)) := by
  classical
  set S : ℕ → Finset ℕ := fun k => (Finset.Icc 1 x).filter (fun v => Sm B v ∧ p ^ k ∣ v) with hS
  have hSm : ∀ k, Sm B (p ^ k) := by
    intro k q hq
    have hqp := Nat.prime_of_mem_primeFactors hq
    have : q = p := (Nat.prime_dvd_prime_iff_eq hqp hp).1
      (hqp.dvd_of_dvd_pow (Nat.dvd_of_mem_primeFactors hq))
    omega
  have hcard : ∀ k, (S k).card = smoothCount B (x / p ^ k) := by
    intro k
    exact hitCount_eq_smoothCount B (p ^ k) x (pow_pos hp.pos k) (hSm k)
  have hmemS : ∀ k v, v ∈ S k ↔ ((1 ≤ v ∧ v ≤ x) ∧ Sm B v ∧ k ≤ v.factorization p) := by
    intro k v
    simp only [hS, Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨h1, h2⟩, hsm, hdvd⟩
      exact ⟨⟨h1, h2⟩, hsm,
        (Nat.Prime.pow_dvd_iff_le_factorization hp (by omega)).1 hdvd⟩
    · rintro ⟨⟨h1, h2⟩, hsm, hle⟩
      exact ⟨⟨h1, h2⟩, hsm,
        (Nat.Prime.pow_dvd_iff_le_factorization hp (by omega)).2 hle⟩
  have hsub : S (j + 1) ⊆ S j := by
    intro v hv
    rw [hmemS] at hv ⊢
    exact ⟨hv.1, hv.2.1, by omega⟩
  have hdiff : ((Finset.Icc 1 x).filter (fun v => Sm B v ∧ v.factorization p = j))
      = S j \ S (j + 1) := by
    ext v
    rw [Finset.mem_sdiff, hmemS, hmemS]
    simp only [Finset.mem_filter, Finset.mem_Icc]
    constructor
    · rintro ⟨⟨hv1, hvx⟩, hsm, hval⟩
      exact ⟨⟨⟨hv1, hvx⟩, hsm, by omega⟩, fun h => by have := h.2.2; omega⟩
    · rintro ⟨⟨⟨hv1, hvx⟩, hsm, hle⟩, hnot⟩
      refine ⟨⟨hv1, hvx⟩, hsm, ?_⟩
      by_contra hne
      exact hnot ⟨⟨hv1, hvx⟩, hsm, by omega⟩
  rw [hdiff, Finset.card_sdiff_of_subset hsub, hcard, hcard]

/-- A prime-power feature is a *strict* restriction: for `m ≥ 2` there is always
a smooth value it misses (namely `1`), so hit counts are strictly below the
smooth count. -/
theorem hitCount_lt_smoothCount {B m x : ℕ} (hm : 2 ≤ m) (hx : 1 ≤ x) :
    hitCount B m x < smoothCount B x := by
  unfold hitCount smoothCount
  apply Finset.card_lt_card
  constructor
  · intro v hv
    simp only [Finset.mem_filter] at hv ⊢
    exact ⟨hv.1, hv.2.1⟩
  · intro hcon
    have h1 : (1 : ℕ) ∈ (Finset.Icc 1 x).filter (fun v => Sm B v) := by
      simp [Nat.primeFactors_one, Sm]
      omega
    have := hcon h1
    simp only [Finset.mem_filter] at this
    have : m ∣ 1 := this.2.2
    have := Nat.le_of_dvd one_pos this
    omega

/-- Enlarging the factor base can only enlarge a hit set. -/
theorem hitCount_mono_in_B {B B' m x : ℕ} (h : B ≤ B') :
    hitCount B m x ≤ hitCount B' m x := by
  unfold hitCount
  apply Finset.card_le_card
  intro v hv
  simp only [Finset.mem_filter] at hv ⊢
  exact ⟨hv.1, fun p hp => le_trans (hv.2.1 p hp) h, hv.2.2⟩

/-! ## The budget shift on the `u`-parameter -/

/-- The smoothness parameter `u = log x / log B`. -/
noncomputable def uParam (B x : ℕ) : ℝ := Real.log x / Real.log B

/-- **Exact budget shift.**  A `p²`-hit splits the `u`-parameter into the
`u`-parameter of the cofactor plus exactly `2 log p / log B`. -/
theorem uParam_eq_of_sq_dvd {B p v : ℕ} (hp : 0 < p) (hv : 0 < v) (hdvd : p ^ 2 ∣ v) :
    uParam B v = uParam B (v / p ^ 2) + 2 * Real.log p / Real.log B := by
  obtain ⟨w, rfl⟩ := hdvd
  have hp2 : (0 : ℕ) < p ^ 2 := by positivity
  have hw : 0 < w := by
    rcases Nat.eq_zero_or_pos w with h | h
    · simp [h] at hv
    · exact h
  rw [Nat.mul_div_cancel_left w hp2]
  unfold uParam
  have hne1 : ((p ^ 2 : ℕ) : ℝ) ≠ 0 := by
    exact_mod_cast hp2.ne'
  have hne2 : ((w : ℕ) : ℝ) ≠ 0 := by exact_mod_cast hw.ne'
  rw [Nat.cast_mul, Real.log_mul hne1 hne2, Nat.cast_pow, Real.log_pow]
  push_cast
  ring

/-- **Budget squeeze.**  Passing to the `p²`-hit sub-pool costs at least
`2 log p / log B` of smoothness budget: the rescaled bound `x / p²` has strictly
smaller `u`. -/
theorem uParam_hit_le {B p x : ℕ} (hB : 1 < B) (hp : 0 < p) (hx : p ^ 2 ≤ x) :
    uParam B (x / p ^ 2) ≤ uParam B x - 2 * Real.log p / Real.log B := by
  have hlogB : 0 < Real.log B := Real.log_pos (by exact_mod_cast hB)
  have hp2 : (0 : ℕ) < p ^ 2 := pow_pos hp 2
  have hxp : 1 ≤ x / p ^ 2 := (Nat.one_le_div_iff hp2).2 hx
  have hcast : ((x / p ^ 2 : ℕ) : ℝ) ≤ (x : ℝ) / ((p : ℝ) ^ 2) := by
    have := Nat.cast_div_le (α := ℝ) (m := x) (n := p ^ 2)
    simpa using this
  have hpos : (0 : ℝ) < ((x / p ^ 2 : ℕ) : ℝ) := by exact_mod_cast hxp
  have hp' : (0 : ℝ) < (p : ℝ) := by exact_mod_cast hp
  have hx0 : (0 : ℝ) < (x : ℝ) := by
    have : (0 : ℕ) < x := lt_of_lt_of_le hp2 hx
    exact_mod_cast this
  have hlog : Real.log ((x / p ^ 2 : ℕ) : ℝ) ≤ Real.log x - 2 * Real.log p := by
    refine (Real.log_le_log hpos hcast).trans ?_
    rw [Real.log_div hx0.ne' (by positivity), Real.log_pow]
    push_cast
    linarith
  unfold uParam
  calc Real.log ((x / p ^ 2 : ℕ) : ℝ) / Real.log B
      ≤ (Real.log x - 2 * Real.log p) / Real.log B := by gcongr
    _ = Real.log x / Real.log B - 2 * Real.log p / Real.log B := by ring

/-- **The tight-`u` mechanism.**  The budget cost of one prime-power hit is
antitone in the smoothness bound: at a *smaller* `B` the same `p²`-hit eats a
larger share of the budget.  This is exactly why the prime-power feature carries
signal in the tight-`u` regime and is invisible at large `B`. -/
theorem shift_antitone_in_B {p B B' : ℕ} (hB : 1 < B) (hBB' : B ≤ B') (hp : 1 ≤ p) :
    2 * Real.log p / Real.log B' ≤ 2 * Real.log p / Real.log B := by
  have hlogB : 0 < Real.log B := Real.log_pos (by exact_mod_cast hB)
  have hlogB' : Real.log B ≤ Real.log B' := by
    apply Real.log_le_log (by positivity)
    exact_mod_cast hBB'
  have hnum : 0 ≤ 2 * Real.log p := by
    have : (1 : ℝ) ≤ (p : ℝ) := by exact_mod_cast hp
    have := Real.log_nonneg this
    linarith
  exact div_le_div_of_nonneg_left hnum hlogB hlogB'

/-! ## What the squarefree features can and cannot see -/

/-- The marginal squarefree-hit feature vector: which factor-base primes divide
`v`. -/
def sqfHits (B v : ℕ) : Finset ℕ := (Nat.primesBelow (B + 1)).filter (fun p => p ∣ v)

/-- The prime-power hit feature vector: which factor-base primes divide `v` to
order at least two. -/
def powHits (B v : ℕ) : Finset ℕ := (Nat.primesBelow (B + 1)).filter (fun p => p ^ 2 ∣ v)

/-- `Ω(v)`, the number of prime factors of `v` with multiplicity: the discrete
smoothness budget. -/
def bigOmega (v : ℕ) : ℕ := v.primeFactorsList.length

lemma bigOmega_mul_pow {v p : ℕ} (k : ℕ) (hv : v ≠ 0) (hp : p.Prime) :
    bigOmega (v * p ^ k) = bigOmega v + k := by
  unfold bigOmega
  have hpk : p ^ k ≠ 0 := pow_ne_zero _ hp.ne_zero
  rw [(Nat.perm_primeFactorsList_mul hv hpk).length_eq, List.length_append,
    hp.primeFactorsList_pow, List.length_replicate]

/-- **The squarefree features are blind to the budget.**  Multiplying by any
power of a prime that already divides `v` leaves the entire squarefree-hit
vector unchanged, while `Ω` — the smoothness budget — grows without bound.  So
the fibres of the squarefree feature map contain values of arbitrarily different
budget: no function of the squarefree hits can recover it. -/
theorem squarefree_features_blind {B p v : ℕ} (k : ℕ) (hp : p.Prime) (hv : v ≠ 0)
    (hpv : p ∣ v) :
    sqfHits B (v * p ^ k) = sqfHits B v ∧ bigOmega (v * p ^ k) = bigOmega v + k := by
  refine ⟨?_, bigOmega_mul_pow k hv hp⟩
  ext q
  simp only [sqfHits, Finset.mem_filter, and_congr_right_iff]
  intro hq
  have hqp : q.Prime := Nat.prime_of_mem_primesBelow hq
  constructor
  · intro h
    rcases (Nat.Prime.dvd_mul hqp).1 h with h1 | h2
    · exact h1
    · have : q = p := (Nat.prime_dvd_prime_iff_eq hqp hp).1 (hqp.dvd_of_dvd_pow h2)
      exact this ▸ hpv
  · intro h
    exact h.trans (dvd_mul_right v (p ^ k))

/-- **The prime-power feature strictly refines the squarefree feature.**  If `p`
divides `v` exactly once, then `v` and `p·v` have *identical* squarefree-hit
vectors, yet the prime-power vector separates them.  This is the structure the
marginal hit features cannot see. -/
theorem powHits_separates {B p v : ℕ} (hp : p.Prime) (hpB : p ≤ B) (hv : v ≠ 0)
    (hpv : p ∣ v) (hns : ¬ p ^ 2 ∣ v) :
    sqfHits B (v * p) = sqfHits B v ∧ p ∈ powHits B (v * p) ∧ p ∉ powHits B v := by
  have hmem : p ∈ Nat.primesBelow (B + 1) := Nat.mem_primesBelow.2 ⟨by omega, hp⟩
  refine ⟨?_, ?_, ?_⟩
  · have := (squarefree_features_blind (B := B) 1 hp hv hpv).1
    simpa using this
  · simp only [powHits, Finset.mem_filter]
    refine ⟨hmem, ?_⟩
    obtain ⟨w, rfl⟩ := hpv
    exact ⟨w, by ring⟩
  · simp only [powHits, Finset.mem_filter, not_and]
    exact fun _ => hns

/-- **Budget consumption, in raw form.**  If `p² ∣ v ≤ x`, the part of `v`
coprime to `p` — the room left for all the other factor-base primes — is at most
`x / p²`.  The prime-power hit really does eat the budget. -/
theorem ordCompl_le_of_sq_dvd {p v x : ℕ} (hp : p.Prime) (hv : 0 < v) (hvx : v ≤ x)
    (h : p ^ 2 ∣ v) : ordCompl[p] v ≤ x / p ^ 2 := by
  have h2 : 2 ≤ v.factorization p :=
    (Nat.Prime.pow_dvd_iff_le_factorization hp hv.ne').1 h
  have hpow : p ^ 2 ≤ p ^ (v.factorization p) := Nat.pow_le_pow_right hp.pos h2
  have hstep : v / p ^ (v.factorization p) ≤ v / p ^ 2 :=
    Nat.div_le_div_left hpow (pow_pos hp.pos 2)
  exact hstep.trans (Nat.div_le_div_right hvx)

/-! ## The exactly solvable case `B = 2` -/

/-- For `B = 2` the smooth pool is the set of powers of two, so
`Ψ_2(x) = ⌊log₂ x⌋ + 1`. -/
theorem smoothCount_two {x : ℕ} (hx : 1 ≤ x) : smoothCount 2 x = Nat.log 2 x + 1 := by
  classical
  have hset : ((Finset.Icc 1 x).filter (fun v => Sm 2 v))
      = (Finset.range (Nat.log 2 x + 1)).image (fun j => 2 ^ j) := by
    ext v
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_image, Finset.mem_range]
    constructor
    · rintro ⟨⟨hv1, hvx⟩, hsm⟩
      have hv0 : v ≠ 0 := by omega
      have hall : ∀ q : ℕ, q.Prime → q ∣ v → q = 2 := by
        intro q hq hqv
        have : q ≤ 2 := hsm q (Nat.mem_primeFactors.2 ⟨hq, hqv, hv0⟩)
        have := hq.two_le
        omega
      have hveq : v = 2 ^ v.primeFactorsList.length :=
        Nat.eq_prime_pow_of_unique_prime_dvd hv0 (fun {q} hq hqv => hall q hq hqv)
      refine ⟨v.primeFactorsList.length, ?_, hveq.symm⟩
      have hle : (2 : ℕ) ^ v.primeFactorsList.length ≤ x := by rw [← hveq]; exact hvx
      have := (Nat.le_log_iff_pow_le (b := 2) (by norm_num) (by omega)).2 hle
      omega
    · rintro ⟨j, hj, rfl⟩
      have hjx : (2 : ℕ) ^ j ≤ x :=
        (Nat.le_log_iff_pow_le (b := 2) (by norm_num) (by omega)).1 (by omega)
      refine ⟨⟨Nat.one_le_two_pow, hjx⟩, ?_⟩
      intro q hq
      have hqp := Nat.prime_of_mem_primeFactors hq
      have : q = 2 := (Nat.prime_dvd_prime_iff_eq hqp Nat.prime_two).1
        (hqp.dvd_of_dvd_pow (Nat.dvd_of_mem_primeFactors hq))
      omega
  unfold smoothCount
  rw [hset, Finset.card_image_of_injective _ (fun a b hab => Nat.pow_right_injective le_rfl hab),
    Finset.card_range]

/-- **The budget law, exactly.**  In the solvable case `B = 2`, hitting `4 = 2²`
consumes precisely two units of the (base-two) budget:
`hit(4) = Ψ_2(x) - 2`, i.e. the hit fraction is exactly `(u - 1) / (u + 1)`
with `u = ⌊log₂ x⌋`.  This is the sharp form of `uParam_hit_le`. -/
theorem hitCount_two_four {x : ℕ} (hx : 4 ≤ x) : hitCount 2 4 x + 2 = smoothCount 2 x := by
  have h4 : (4 : ℕ) = 2 ^ 2 := by norm_num
  have hhit : hitCount 2 4 x = smoothCount 2 (x / 4) := by
    rw [h4]
    exact hitCount_primeSq x Nat.prime_two le_rfl
  have hdiv : 1 ≤ x / 4 := (Nat.one_le_div_iff (by norm_num)).2 hx
  rw [hhit, smoothCount_two hdiv, smoothCount_two (by omega)]
  have hlog : Nat.log 2 (x / 4) + 2 = Nat.log 2 x := by
    have hx4 : x / 4 = x / 2 ^ 2 := by norm_num
    have h1 : Nat.log 2 (x / 2 ^ 2) = Nat.log 2 x - 2 := Nat.log_div_base_pow 2 x 2
    have h2 : 2 ≤ Nat.log 2 x :=
      (Nat.le_log_iff_pow_le (b := 2) (by norm_num) (by omega)).2 (by omega)
    rw [hx4, h1]
    omega
  omega

end PrimePowerBudget