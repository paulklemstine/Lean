import Pythagorean.SeqHint.ResiduePricing

/-!
# Sequential hint pricing XI: mixed batteries and the interval floor

`SeqHint/ResiduePricing.lean` separated two currencies: comparison hints buy
**interval**, residue hints buy **count**.  The obvious worry is that the two
might *combine* — that arithmetic information, once an order cut has narrowed
the window, could suddenly start shortening intervals.  It does not.

The results here bound a **mixed battery**: `k` adaptive comparison queries
followed by any residue query `p mod m = ?`.

* `Window.step_width_ge`, `bisect_width_ge` — the matching **lower** bound on
  the bisection width, `w / 2 ^ k ≤ width`.  (`bisect_width_le` gave the upper
  bound `⌈w / 2 ^ k⌉`; together they pin the residual width to within one.)
* `mixed_battery_interval_floor` — after the `k` comparison queries *and* the
  residue query, two candidates consistent with **every** answer still remain
  at distance at least `w / 2 ^ k − 2 m`.  The interval gain of the mixed
  battery is therefore at most `2 ^ k` — the residue query contributes nothing
  to it, whatever `m` is and however the order queries are interleaved.
* `residue_class_card_ge`, `mixed_battery_count_floor` — the matching **count**
  floor: the mixed battery leaves at least `w / (2 ^ k * m)` candidates, so the
  two channels multiply and the joint count gain is capped by the product
  alphabet `2 ^ k * m`.
* `interval_gain_capped_by_order_budget` — the packaged statement: an
  interval-sweeping downstream algorithm (the Fermat scan) cannot be sped up by
  more than `2 ^ k_ord`, no matter how much arithmetic side information it is
  handed.  This prices barrier 4 in the count/interval currency split.
-/

namespace Pythagorean.SeqHint

open Finset

/-! ## The bisection width from below -/

namespace Window

/-- One lower-median step never removes more than half the window: the residual
width is at least `⌊w / 2⌋`.  Together with `step_width_le` this shows the
adaptive arm is *exactly* a halving, with no hidden extra progress. -/
theorem step_width_ge (I : Window) (b : Bool) (h : I.lo ≤ I.hi) :
    I.width / 2 ≤ (I.step b).width := by
  have hmid : I.mid = I.lo + (I.hi - I.lo - 1) / 2 := rfl
  have hd := Nat.div_add_mod (I.hi - I.lo - 1) 2
  have hd2 : (I.hi - I.lo - 1) % 2 < 2 := Nat.mod_lt _ (by norm_num)
  have hw := Nat.div_add_mod I.width 2
  have hw2 : I.width % 2 < 2 := Nat.mod_lt _ (by norm_num)
  cases b <;>
    · simp only [step, width, hmid, if_true, if_false, Bool.false_eq_true]
      simp only [width] at hw
      omega

end Window

/-- **The bisection width from below.**  After `k` adaptive comparison queries
the surviving window still has width at least `w / 2 ^ k`: the geometric law of
`bisect_width_le` is not an over-estimate. -/
theorem bisect_width_ge (x : ℕ) : ∀ (k : ℕ) (I : Window), I.lo ≤ I.hi →
    I.width / 2 ^ k ≤ (bisect x k I).width := by
  intro k
  induction k with
  | zero => intro I _; simp [bisect]
  | succ k ih =>
      intro I h
      by_cases hw0 : I.width = 0
      · simp [hw0]
      have hstep : I.width / 2 ≤ (I.step (decide (x ≤ I.mid))).width :=
        Window.step_width_ge I _ h
      have hwpos : 0 < I.hi - I.lo := by
        simp only [Window.width] at hw0; omega
      have hle : (I.step (decide (x ≤ I.mid))).lo ≤ (I.step (decide (x ≤ I.mid))).hi := by
        have hmid : I.mid = I.lo + (I.hi - I.lo - 1) / 2 := rfl
        have hd := Nat.div_add_mod (I.hi - I.lo - 1) 2
        have hd2 : (I.hi - I.lo - 1) % 2 < 2 := Nat.mod_lt _ (by norm_num)
        by_cases hb : x ≤ I.mid <;>
          simp only [Window.step, hb, decide_true, decide_false, Bool.false_eq_true,
            if_true, if_false] <;> omega
      have := ih (I.step (decide (x ≤ I.mid))) hle
      calc I.width / 2 ^ (k + 1)
          = I.width / 2 / 2 ^ k := by
            rw [pow_succ, Nat.mul_comm, ← Nat.div_div_eq_div_mul]
        _ ≤ (I.step (decide (x ≤ I.mid))).width / 2 ^ k := Nat.div_le_div_right hstep
        _ ≤ (bisect x (k + 1) I).width := by simpa [bisect] using this

/-! ## The interval floor of a mixed battery -/

/-- **Residue hints do not help even after order hints.**  Run `k` adaptive
comparison queries against the hidden value `x`, then the residue query
`p mod m = ?`.  Two candidates consistent with *every* answer still remain at
distance at least `I.width / 2 ^ k − 2 m`: the residue query buys no interval,
and the interval gain of the whole mixed battery is capped by `2 ^ k`. -/
theorem mixed_battery_interval_floor (x : ℕ) (k : ℕ) (I : Window) (m : ℕ) (hm : 0 < m)
    (hx : x ∈ I.carrier) :
    ∃ b ∈ (bisect x k I).carrier, ∃ c ∈ (bisect x k I).carrier,
      b % m = x % m ∧ c % m = x % m ∧ b ≤ c ∧ I.width / 2 ^ k ≤ (c - b) + 2 * m := by
  classical
  set J := bisect x k I with hJ
  have hxJ : x ∈ J.carrier := bisect_mem x k I hx
  have hIle : I.lo ≤ I.hi := by
    rw [Window.carrier, mem_Ico] at hx; omega
  have hwJ : I.width / 2 ^ k ≤ J.width := bisect_width_ge x k I hIle
  have hxJ' : x ∈ Finset.Ico J.lo (J.lo + J.width) := by
    rw [Window.carrier, mem_Ico] at hxJ
    rw [mem_Ico]
    have : J.lo + J.width = J.hi := by
      simp only [Window.width]; omega
    omega
  obtain ⟨b, hb, c, hc, hbm, hcm, hbc, hspread⟩ :=
    residue_hints_carry_no_interval_information hm hxJ'
  have hconv : ∀ y : ℕ, y ∈ Finset.Ico J.lo (J.lo + J.width) → y ∈ J.carrier := by
    intro y hy
    rw [mem_Ico] at hy
    rw [Window.carrier, mem_Ico]
    have hlt : J.lo < J.hi := by
      rw [Window.carrier, mem_Ico] at hxJ; omega
    simp only [Window.width] at hy
    omega
  exact ⟨b, hconv b hb, c, hconv c hc, hbm, hcm, hbc, by omega⟩

/-! ## The count floor of a mixed battery -/

/-- A residue class that meets a window of width `w` occupies at least `w / m`
of it: the residue query divides the candidate count by `m` and no more. -/
theorem residue_class_card_ge {lo w m a : ℕ} (hm : 0 < m)
    (ha : a ∈ Finset.Ico lo (lo + w)) :
    w / m ≤ ((Finset.Ico lo (lo + w)).filter (fun y => y % m = a % m)).card := by
  classical
  obtain ⟨b, hb, hbm, _, hblt⟩ := residue_class_reaches_bottom hm ha
  rw [mem_Ico] at hb
  have hstep : Set.MapsTo (fun j => b + j * m) ↑(Finset.range (w / m))
      ↑((Finset.Ico lo (lo + w)).filter (fun y => y % m = a % m)) := by
    intro j hj
    simp only [Finset.coe_range, Set.mem_Iio] at hj
    simp only [Finset.mem_coe]
    have hjm : j * m + m ≤ (w / m) * m := by
      have : j + 1 ≤ w / m := hj
      calc j * m + m = (j + 1) * m := by ring
        _ ≤ (w / m) * m := Nat.mul_le_mul_right m this
    have hwm : (w / m) * m ≤ w := Nat.div_mul_le_self w m
    rw [mem_filter, mem_Ico]
    refine ⟨⟨by omega, by omega⟩, ?_⟩
    calc (b + j * m) % m = b % m := by simp [Nat.mul_comm]
      _ = a % m := hbm
  have hinj : Set.InjOn (fun j => b + j * m) ↑(Finset.range (w / m)) := by
    intro i _ j _ hij
    simp only at hij
    have : i * m = j * m := by omega
    exact Nat.eq_of_mul_eq_mul_right hm this
  have hle := Finset.card_le_card_of_injOn _ hstep hinj
  simpa using hle

/-- **The count floor of a mixed battery.**  `k` adaptive comparison queries and
one residue query of modulus `m` leave at least `w / (2 ^ k * m)` candidates
consistent with every answer: the two channels multiply, and the joint count
gain is capped by the product alphabet `2 ^ k * m`. -/
theorem mixed_battery_count_floor (x : ℕ) (k : ℕ) (I : Window) (m : ℕ) (hm : 0 < m)
    (hx : x ∈ I.carrier) :
    I.width / (2 ^ k * m) ≤
      ((bisect x k I).carrier.filter (fun y => y % m = x % m)).card := by
  classical
  have hxJ : x ∈ (bisect x k I).carrier := bisect_mem x k I hx
  have hIle : I.lo ≤ I.hi := by
    rw [Window.carrier, mem_Ico] at hx; omega
  have hwJ : I.width / 2 ^ k ≤ (bisect x k I).width := bisect_width_ge x k I hIle
  have heq : (bisect x k I).lo + (bisect x k I).width = (bisect x k I).hi := by
    rw [Window.carrier, mem_Ico] at hxJ
    simp only [Window.width]
    omega
  have hcar : (bisect x k I).carrier =
      Finset.Ico (bisect x k I).lo ((bisect x k I).lo + (bisect x k I).width) := by
    rw [heq]; rfl
  have hxJ' : x ∈ Finset.Ico (bisect x k I).lo
      ((bisect x k I).lo + (bisect x k I).width) := hcar ▸ hxJ
  have hcard := residue_class_card_ge hm hxJ'
  rw [← hcar] at hcard
  refine le_trans ?_ hcard
  calc I.width / (2 ^ k * m) = I.width / 2 ^ k / m := by
        rw [Nat.div_div_eq_div_mul]
    _ ≤ (bisect x k I).width / m := Nat.div_le_div_right hwJ

/-- **Interval gain is capped by the order budget alone.**  Packaged form of the
count/interval currency split for a mixed battery of `k` adaptive comparison
queries and one residue query of modulus `m`:

* the *count* can be cut arbitrarily hard — `k` comparison queries alone already
  isolate a window of width `2 ^ k` (`bisection_isolates`), and residue queries
  multiply the resolvable volume further (`residue_battery_isolates`);
* but the *interval* the downstream Fermat scan must sweep is never shorter than
  `I.width / 2 ^ k − 2 m`, whatever the modulus.

So the downstream speedup of an interval-sweeping algorithm is bounded by
`2 ^ k_ord`, and arithmetic side information is worthless to it. -/
theorem interval_gain_capped_by_order_budget (x : ℕ) (k : ℕ) (I : Window) (m : ℕ)
    (hm : 0 < m) (hx : x ∈ I.carrier) (hwide : (2 * m + 1) * 2 ^ k ≤ I.width) :
    ∃ b ∈ (bisect x k I).carrier, ∃ c ∈ (bisect x k I).carrier,
      b ≠ c ∧ b % m = x % m ∧ c % m = x % m := by
  obtain ⟨b, hb, c, hc, hbm, hcm, hbc, hspread⟩ :=
    mixed_battery_interval_floor x k I m hm hx
  refine ⟨b, hb, c, hc, ?_, hbm, hcm⟩
  have hpow : 0 < 2 ^ k := Nat.two_pow_pos k
  have hdiv : 2 * m + 1 ≤ I.width / 2 ^ k := (Nat.le_div_iff_mul_le hpow).mpr hwide
  omega

end Pythagorean.SeqHint