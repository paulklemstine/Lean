import Bridges.CRTSplitNoGoAverage

/-!
# The CRT-Split No-Go, Part IX: the average closure time is `Θ(√n)`, and Floyd inherits it

Part VIII proved the *lower* half of the average-case barrier: averaged over all `n ^ n` maps of
an `n`-element set, the first orbit collision happens no earlier than `⌊√n⌋ / 2` steps.  This
file closes the matching *upper* half — Conjecture E of the previous cycle's
`FUTURE_DIRECTIONS.md` — and transfers both halves to the tortoise-and-hare (Floyd) test that
Pollard rho actually runs.

## Main results

* `sum_closureTime_eq_sum_card` — the layer-cake identity
  `∑_f closureTime a f = ∑_{T < n} #{f : collision-free prefix of length T+1}`.
  It is exact: closure times and the birthday counting law of Part VI are the same data.
* `sum_exp_birthday_le` — the analytic core: `∑_{T < n} exp (−T(T+1)/(2n)) ≤ 3 (⌊√n⌋ + 1)`,
  proved by cutting `[0, n)` into `⌊√n⌋ + 1` blocks on which the Gaussian tail of Part VII is
  dominated by the geometric ratio `exp (−1/2)`.
* `average_closureTime_le` — consequently `∑_f closureTime a f ≤ 3 (⌊√n⌋ + 1) · n ^ n`: the
  average first closure time is `O(√n)`.  With `average_closureTime_ge_sqrt` this pins the
  average at `Θ(√n)`, recorded as `average_closureTime_theta` and, on the reduced state space
  of an `N`-explicit iteration, as `average_closureTime_theta_zmod`.
* `closureTime_le_two_mul_floyd` — a tortoise-and-hare match at time `i > 0` forces a collision
  in the prefix of length `2i + 1`, so Floyd's detection time is at least half the first closure
  time; `average_floyd_ge_sqrt` and `average_floyd_zmod` therefore give the `√p / 4` average
  lower bound for the actual Pollard rho loop, not merely for the idealised first closure.

Together with Parts I–IV (a factor of `N = p q` appears *exactly* at an exclusive mod-`p`
closure) this says: on the reduced state space `ZMod p` the generic regime costs `Θ(√p)` on
average — `N^{1/4}` for balanced `N`, exponential in `log N` — and no rho-type variant, Floyd
included, can do better than a constant factor.
-/

namespace CRTSplitNoGo

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Part A: closure times are the layer cake of the birthday counts -/

omit [DecidableEq α] in
/-- The closure time never exceeds the size of the state space (pigeonhole). -/
lemma closureTime_le_card (a : α) (f : α → α) : closureTime a f ≤ Fintype.card α :=
  Nat.sInf_le (not_injPrefix_card f a)

omit [DecidableEq α] in
/-- `closureTime` is characterised by collision-freeness: the prefix of length `T + 1` is
collision-free exactly when the closure time exceeds `T`. -/
lemma injPrefix_iff_lt_closureTime {a : α} {f : α → α} {T : ℕ} :
    InjPrefix f a T ↔ T < closureTime a f := by
  constructor
  · exact lt_closureTime_of_injPrefix
  · intro hT
    by_contra hbad
    have : closureTime a f ≤ T := Nat.sInf_le hbad
    omega

/-- **Layer cake.**  The total closure time over all maps is the sum of the birthday counts of
Part VI: `∑_f closureTime a f = ∑_{T < n} #{f : InjPrefix f a T}`. -/
theorem sum_closureTime_eq_sum_card (a : α) :
    ∑ f : α → α, closureTime a f
      = ∑ T ∈ Finset.range (Fintype.card α), (injPrefixFinset a T).card := by
  classical
  have hfil : ∀ f : α → α,
      ((Finset.range (Fintype.card α)).filter (fun T => InjPrefix f a T)).card
        = closureTime a f := by
    intro f
    have hset : (Finset.range (Fintype.card α)).filter (fun T => InjPrefix f a T)
        = Finset.range (closureTime a f) := by
      ext T
      simp only [Finset.mem_filter, Finset.mem_range]
      constructor
      · rintro ⟨-, h⟩; exact injPrefix_iff_lt_closureTime.mp h
      · intro h
        exact ⟨lt_of_lt_of_le h (closureTime_le_card a f), injPrefix_iff_lt_closureTime.mpr h⟩
    rw [hset, Finset.card_range]
  calc ∑ f : α → α, closureTime a f
      = ∑ f : α → α,
          ((Finset.range (Fintype.card α)).filter (fun T => InjPrefix f a T)).card := by
        exact Finset.sum_congr rfl (fun f _ => (hfil f).symm)
    _ = ∑ f : α → α, ∑ T ∈ Finset.range (Fintype.card α),
          (if InjPrefix f a T then 1 else 0) := by
        exact Finset.sum_congr rfl (fun f _ => Finset.card_filter _ _)
    _ = ∑ T ∈ Finset.range (Fintype.card α), ∑ f : α → α,
          (if InjPrefix f a T then 1 else 0) := Finset.sum_comm
    _ = ∑ T ∈ Finset.range (Fintype.card α), (injPrefixFinset a T).card := by
        refine Finset.sum_congr rfl (fun T _ => ?_)
        rw [injPrefixFinset, Finset.card_filter]

/-! ## Part B: the analytic core — summing the Gaussian tail -/

/-- Blocks of a range: `∑_{T < m K} g (T / m) = m · ∑_{k < K} g k`. -/
lemma sum_range_block (m : ℕ) (hm : 0 < m) (g : ℕ → ℝ) (K : ℕ) :
    ∑ T ∈ Finset.range (m * K), g (T / m) = m * ∑ k ∈ Finset.range K, g k := by
  induction K with
  | zero => simp
  | succ K ih =>
      have hsplit : m * (K + 1) = m * K + m := by ring
      rw [hsplit, Finset.sum_range_add, ih, Finset.sum_range_succ]
      have hblock : ∀ i ∈ Finset.range m, g ((m * K + i) / m) = g K := by
        intro i hi
        have hi' : i < m := Finset.mem_range.mp hi
        have : (m * K + i) / m = K := by
          rw [Nat.mul_add_div hm, Nat.div_eq_of_lt hi', Nat.add_zero]
        rw [this]
      rw [Finset.sum_congr rfl hblock, Finset.sum_const, Finset.card_range, nsmul_eq_mul]
      ring

/-- The geometric ratio used below is `< 1`. -/
lemma exp_neg_half_lt_one : Real.exp (-(1 / 2 : ℝ)) < 1 := by
  have := Real.exp_lt_one_iff.mpr (show (-(1 / 2 : ℝ)) < 0 by norm_num)
  exact this

/-- A numerical bound on the geometric ratio: `exp (−1/2) ≤ 0.61`. -/
lemma exp_neg_half_le : Real.exp (-(1 / 2 : ℝ)) ≤ 0.61 := by
  have hx : (0 : ℝ) < Real.exp (1 / 2 : ℝ) := Real.exp_pos _
  have hsq : Real.exp (1 / 2 : ℝ) * Real.exp (1 / 2 : ℝ) = Real.exp 1 := by
    rw [← Real.exp_add]; norm_num
  have he : (2.7182818283 : ℝ) < Real.exp 1 := by
    have := Real.exp_one_gt_d9
    linarith
  have hlb : (1.6487 : ℝ) ≤ Real.exp (1 / 2 : ℝ) := by nlinarith
  rw [Real.exp_neg]
  rw [inv_le_iff_one_le_mul₀ hx]
  nlinarith

/-- Partial geometric sums with ratio `exp (−1/2)` are bounded by `3`. -/
lemma geom_sum_exp_neg_half_le (K : ℕ) :
    ∑ k ∈ Finset.range K, (Real.exp (-(1 / 2 : ℝ))) ^ k ≤ 3 := by
  set r := Real.exp (-(1 / 2 : ℝ)) with hr
  have hr0 : 0 < r := Real.exp_pos _
  have hr1 : r ≤ 0.61 := exp_neg_half_le
  have hmul := geom_sum_mul r K
  have hrK : 0 < r ^ K := pow_pos hr0 K
  -- `(∑ r^k) (r − 1) = r^K − 1`, hence `(1 − r) ∑ r^k = 1 − r^K ≤ 1`
  have hS : (∑ k ∈ Finset.range K, r ^ k) * (1 - r) = 1 - r ^ K := by
    have : (∑ k ∈ Finset.range K, r ^ k) * (r - 1) = r ^ K - 1 := hmul
    nlinarith [this]
  nlinarith [hS, hrK]

/-- **The Gaussian tail sums to `O(√n)`.**  `∑_{T < n} exp (−T(T+1)/(2n)) ≤ 3 (⌊√n⌋ + 1)`. -/
theorem sum_exp_birthday_le (n : ℕ) (hn : 0 < n) :
    ∑ T ∈ Finset.range n, Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))
      ≤ 3 * ((Nat.sqrt n : ℝ) + 1) := by
  set m := Nat.sqrt n + 1 with hm
  have hm0 : 0 < m := by omega
  have hmn : n < m * m := by
    have := Nat.lt_succ_sqrt' n
    simpa [hm, pow_two, Nat.succ_eq_add_one] using this
  set r := Real.exp (-(1 / 2 : ℝ)) with hr
  have hr0 : 0 < r := Real.exp_pos _
  -- termwise domination by the geometric sequence in the block index
  have hterm : ∀ T ∈ Finset.range n,
      Real.exp (-((T * (T + 1) : ℝ) / (2 * n))) ≤ r ^ (T / m) := by
    intro T _
    set k := T / m with hk
    have hkm' : k * m ≤ T := by
      have := Nat.div_mul_le_self T m
      simpa [hk, Nat.mul_comm] using this
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    -- `T (T+1) ≥ k² m² ≥ k² n ≥ k n`
    have hnat : k * n ≤ T * (T + 1) := by
      have h1 : k * (k * (m * m)) ≤ T * (T + 1) := by
        have hA : k * m ≤ T := hkm'
        have hB : k * m ≤ T + 1 := le_trans hkm' (by omega)
        calc k * (k * (m * m)) = (k * m) * (k * m) := by ring
          _ ≤ T * (T + 1) := Nat.mul_le_mul hA hB
      have h2 : k * (k * n) ≤ k * (k * (m * m)) := by
        exact Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ (le_of_lt hmn))
      have h3 : k * n ≤ k * (k * n) := by
        rcases Nat.eq_zero_or_pos k with hk0 | hk0
        · simp [hk0]
        · calc k * n = 1 * (k * n) := by ring
            _ ≤ k * (k * n) := Nat.mul_le_mul_right _ hk0
      omega
    have hR : (k : ℝ) / 2 ≤ (T * (T + 1) : ℝ) / (2 * n) := by
      rw [div_le_div_iff₀ (by norm_num) (by positivity)]
      have : ((k * n : ℕ) : ℝ) ≤ ((T * (T + 1) : ℕ) : ℝ) := by exact_mod_cast hnat
      push_cast at this
      nlinarith [this]
    calc Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))
        ≤ Real.exp (-((k : ℝ) / 2)) := Real.exp_le_exp.mpr (by linarith)
      _ = r ^ k := by
          rw [hr, ← Real.exp_nat_mul]
          congr 1
          ring
  have hstep1 : ∑ T ∈ Finset.range n, Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))
      ≤ ∑ T ∈ Finset.range n, r ^ (T / m) := Finset.sum_le_sum hterm
  -- extend the range to a whole number of blocks
  have hnmn : n ≤ m * n := by
    calc n = 1 * n := by ring
      _ ≤ m * n := Nat.mul_le_mul_right _ hm0
  have hsub : Finset.range n ⊆ Finset.range (m * n) := by
    intro x hx
    simp only [Finset.mem_range] at hx ⊢
    omega
  have hstep2 : ∑ T ∈ Finset.range n, r ^ (T / m)
      ≤ ∑ T ∈ Finset.range (m * n), r ^ (T / m) :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun T _ _ => le_of_lt (pow_pos hr0 _))
  have hstep3 : ∑ T ∈ Finset.range (m * n), r ^ (T / m)
      = m * ∑ k ∈ Finset.range n, r ^ k := sum_range_block m hm0 (fun k => r ^ k) n
  have hgeom : ∑ k ∈ Finset.range n, r ^ k ≤ 3 := geom_sum_exp_neg_half_le n
  have hmR : (0 : ℝ) ≤ (m : ℝ) := by positivity
  have hmcast : (m : ℝ) = (Nat.sqrt n : ℝ) + 1 := by rw [hm]; push_cast; ring
  calc ∑ T ∈ Finset.range n, Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))
      ≤ ∑ T ∈ Finset.range (m * n), r ^ (T / m) := le_trans hstep1 hstep2
    _ = m * ∑ k ∈ Finset.range n, r ^ k := hstep3
    _ ≤ (m : ℝ) * 3 := mul_le_mul_of_nonneg_left hgeom hmR
    _ = 3 * ((Nat.sqrt n : ℝ) + 1) := by rw [hmcast]; ring

/-! ## Part C: the average closure time is `Θ(√n)` -/

/-- **Conjecture E, upper half.**  Averaged over all `n ^ n` maps of an `n`-element set, the
first orbit collision happens after at most `3 (⌊√n⌋ + 1)` steps.  So the birthday exponent
`1/2` is an upper bound for the average as well as a lower bound. -/
theorem average_closureTime_le (a : α) (hn : 0 < Fintype.card α) :
    ∑ f : α → α, (closureTime a f : ℝ)
      ≤ 3 * ((Nat.sqrt (Fintype.card α) : ℝ) + 1)
          * ((Fintype.card α : ℝ) ^ (Fintype.card α)) := by
  classical
  set n := Fintype.card α with hn'
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hlayer : ∑ f : α → α, (closureTime a f : ℝ)
      = ∑ T ∈ Finset.range n, ((injPrefixFinset a T).card : ℝ) := by
    have := sum_closureTime_eq_sum_card a
    have hcast : ((∑ f : α → α, closureTime a f : ℕ) : ℝ)
        = ((∑ T ∈ Finset.range n, (injPrefixFinset a T).card : ℕ) : ℝ) := by
      exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) this
    push_cast at hcast
    exact hcast
  have hbound : ∑ T ∈ Finset.range n, ((injPrefixFinset a T).card : ℝ)
      ≤ ∑ T ∈ Finset.range n,
          Real.exp (-((T * (T + 1) : ℝ) / (2 * n))) * (n : ℝ) ^ n := by
    refine Finset.sum_le_sum (fun T hT => ?_)
    exact card_injPrefix_le_exp a T (Finset.mem_range.mp hT)
  have hfactor : ∑ T ∈ Finset.range n,
      Real.exp (-((T * (T + 1) : ℝ) / (2 * n))) * (n : ℝ) ^ n
      = (∑ T ∈ Finset.range n, Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))) * (n : ℝ) ^ n := by
    rw [← Finset.sum_mul]
  have hnn : (0 : ℝ) ≤ (n : ℝ) ^ n := by positivity
  calc ∑ f : α → α, (closureTime a f : ℝ)
      = ∑ T ∈ Finset.range n, ((injPrefixFinset a T).card : ℝ) := hlayer
    _ ≤ (∑ T ∈ Finset.range n, Real.exp (-((T * (T + 1) : ℝ) / (2 * n)))) * (n : ℝ) ^ n := by
        rw [← hfactor]; exact hbound
    _ ≤ (3 * ((Nat.sqrt n : ℝ) + 1)) * (n : ℝ) ^ n :=
        mul_le_mul_of_nonneg_right (sum_exp_birthday_le n hn) hnn

/-- **The average first closure time is `Θ(√n)`.**  Both halves together: the average is between
`⌊√n⌋ / 2` and `3 (⌊√n⌋ + 1)`. -/
theorem average_closureTime_theta (a : α) (hn : 0 < Fintype.card α) :
    (Nat.sqrt (Fintype.card α) : ℝ) * ((Fintype.card α : ℝ) ^ (Fintype.card α) / 2)
        ≤ ∑ f : α → α, (closureTime a f : ℝ) ∧
      ∑ f : α → α, (closureTime a f : ℝ)
        ≤ 3 * ((Nat.sqrt (Fintype.card α) : ℝ) + 1)
            * ((Fintype.card α : ℝ) ^ (Fintype.card α)) :=
  ⟨average_closureTime_ge_sqrt a, average_closureTime_le a hn⟩

/-- **The reduced state space: `Θ(√p)`.**  On `ZMod p`, the state space of the mod-`p` reduction
of any `N`-explicit iteration (Fact 2), the average first cycle closure time — by Parts I–IV the
only factor-revealing event — lies between `√p / 2` and `3 (√p + 1)`.  For a balanced semiprime
`N = p q` this is `Θ(N^{1/4})`: exponential in `log N`, and *sharp*, so the rho exponent cannot
be improved within the generic regime. -/
theorem average_closureTime_theta_zmod (p : ℕ) [NeZero p] :
    (Nat.sqrt p : ℝ) * ((p : ℝ) ^ p / 2)
        ≤ ∑ f : ZMod p → ZMod p, (closureTime (0 : ZMod p) f : ℝ) ∧
      ∑ f : ZMod p → ZMod p, (closureTime (0 : ZMod p) f : ℝ)
        ≤ 3 * ((Nat.sqrt p : ℝ) + 1) * ((p : ℝ) ^ p) := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have hp : 0 < p := Nat.pos_of_ne_zero (NeZero.ne p)
  have h := average_closureTime_theta (0 : ZMod p) (by rw [hcard]; exact hp)
  rw [hcard] at h
  exact h

/-! ## Part D: the tortoise-and-hare test inherits the barrier -/

omit [Fintype α] [DecidableEq α] in
/-- **A Floyd match is a collision.**  If the hare meets the tortoise at time `i > 0`, i.e.
`f^[i] a = f^[2i] a`, then the orbit prefix of length `2i + 1` already collides, so the first
closure time is at most `2 i`. -/
theorem closureTime_le_two_mul_floyd (a : α) (f : α → α) (i : ℕ) (hi : 0 < i)
    (hmatch : orb f a i = orb f a (2 * i)) : closureTime a f ≤ 2 * i := by
  refine Nat.sInf_le ?_
  intro hinj
  have := hinj i (by omega) (2 * i) (by omega) hmatch
  omega

/-- **The average-case barrier for Pollard rho itself.**  Let `ftime` assign to every map a
tortoise-and-hare match time (any `i > 0` with `f^[i] a = f^[2i] a` — in particular the first
such `i`, which is what the Pollard rho loop returns).  Then the average of `ftime` over all
`n ^ n` maps is at least `⌊√n⌋ / 4`.  Cycle detection cannot beat the birthday exponent even by
using the hare. -/
theorem average_floyd_ge_sqrt (a : α) (ftime : (α → α) → ℕ)
    (hpos : ∀ f, 0 < ftime f)
    (hmatch : ∀ f, orb f a (ftime f) = orb f a (2 * ftime f)) :
    (Nat.sqrt (Fintype.card α) : ℝ) * ((Fintype.card α : ℝ) ^ (Fintype.card α) / 4)
      ≤ ∑ f : α → α, (ftime f : ℝ) := by
  classical
  set n := Fintype.card α with hn
  have hhalf : ∑ f : α → α, (closureTime a f : ℝ) ≤ 2 * ∑ f : α → α, (ftime f : ℝ) := by
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum (fun f _ => ?_)
    have := closureTime_le_two_mul_floyd a f (ftime f) (hpos f) (hmatch f)
    have hcast : ((closureTime a f : ℕ) : ℝ) ≤ ((2 * ftime f : ℕ) : ℝ) := by exact_mod_cast this
    push_cast at hcast
    linarith
  have hlow := average_closureTime_ge_sqrt (α := α) a
  rw [← hn] at hlow
  linarith

/-- **Pollard rho on the reduced state space.**  Any tortoise-and-hare cycle detector on
`ZMod p` needs, on average over all maps, at least `√p / 4` steps — `N^{1/4}` up to a constant
for a balanced semiprime `N = p q`. -/
theorem average_floyd_zmod (p : ℕ) [NeZero p] (ftime : (ZMod p → ZMod p) → ℕ)
    (hpos : ∀ f, 0 < ftime f)
    (hmatch : ∀ f, orb f (0 : ZMod p) (ftime f) = orb f (0 : ZMod p) (2 * ftime f)) :
    (Nat.sqrt p : ℝ) * ((p : ℝ) ^ p / 4) ≤ ∑ f : ZMod p → ZMod p, (ftime f : ℝ) := by
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have := average_floyd_ge_sqrt (0 : ZMod p) ftime hpos hmatch
  rwa [hcard] at this

end CRTSplitNoGo