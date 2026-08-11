import Mathlib
import Applications.CellularAutomataVariety.Basic
import Computation.CellularAutomata.ShiftsPolynomialsOrbits

/-!
# Exact fixed-point counts of elementary cellular automata as arithmetic functions

The previous file proved that `16` of the `256` elementary rules — Rule 110 among
them — have exactly one fixed configuration on *every* cyclic lattice.  Those counts
are constant in the lattice size `n`.  This file shows that other rules have
fixed-point counts that are genuinely *arithmetic* functions of `n`, and computes two
of them exactly, for all `n` at once.

## Method: periodic descent

The engine is a descent principle.  If every fixed configuration of a rule is
`d`-periodic and `d ∣ n`, then pulling back along the ring homomorphism
`ZMod n → ZMod d` is a bijection from the fixed configurations of the small lattice
onto those of the big one (`ncard_fixed_eq_of_periodic`).  This reduces an infinite
family of counting problems to a single finite one, which a kernel computation
settles.  Conversely, if the period `d` is a *unit* modulo `n`, then `d`-periodicity
degenerates to constancy (`const_of_periodic_of_isUnit`), which pins the count down
in the coprime case.

## Main results

* `pull`, `pull_isFixed`, `isFixed_of_pull`, `pull_injective`, `exists_pull_of_periodic`:
  the descent dictionary.
* `ncard_fixed_eq_of_periodic`: counts on `ZMod n` and `ZMod d` agree when `d ∣ n` and
  all fixed configurations are `d`-periodic.
* `ncard_fixed_mono_of_dvd`: fixed-point counts are monotone along divisibility, for
  every rule.
* `rule150_fixedPoints_ncard`:  `#V(150, n) = 4` if `n` is even and `2` if `n` is odd.
* `rule90_fixedPoints_ncard`:  `#V(90, n) = 4` if `3 ∣ n` and `1` otherwise.
* `rule90_ncard_ne_rule110_ncard`: the additive rule 90 and the universal rule 110 are
  separated by the fixed-point statistic exactly on the multiples of `3`.

-- !-- Lab Notes -- !--

HYPOTHESIS.  Fixed-point counts of ECAs are not arbitrary functions of `n`; they are
governed by the *period* of the linear recurrence attached to the rule, hence by the
divisibility structure of `n`.

EXPERIMENT.  Rules 90 and 150 have fixed-point sets cut out respectively by the
`GF(2)` Fibonacci recurrence (period `3`) and by two-periodicity (period `2`).
Descent to `ZMod 3` and `ZMod 2` then reduces the count to a finite check:
`#V(90,3) = 4`, `#V(150,2) = 4`, and coprimality collapses the remaining cases.

ANALYSIS.  The resulting counts, `4^[3∣n]` and `2·2^[2∣n]`, are periodic in `n` with
periods `3` and `2` — the Pisano-type periods of the recurrences over `GF(2)`.  Rule
110's count is the constant `1`.  A fixed-point statistic therefore records the
*period of the associated recurrence*, an invariant of the linearisation of the rule,
and not the Wolfram class.

CRITIQUE.  The two finite base computations (`ZMod 2`, `ZMod 3`) are kernel `decide`
calls on genuinely finite sets; all statements quantified over `n` are proved by
descent, never by enumeration, and no theorem below is a definitional triviality.
-/

namespace CAFixedPointCounts

open CellularAutomataVariety CAShiftsPolynomialsOrbits Function

variable {n d : ℕ}

/-! ## 1. Periodic descent -/

/-- Pull a configuration on the small lattice `ZMod d` back to the big lattice
`ZMod n` along the canonical ring homomorphism (`d ∣ n`). -/
def pull (h : d ∣ n) (t : Config d) : Config n := fun i => t (ZMod.castHom h (ZMod d) i)

/-- Being a fixed configuration is a decidable property on a nonempty finite lattice. -/
instance instDecidableIsFixed {m : ℕ} [NeZero m] (g : LocalRule) :
    DecidablePred (fun t : Config m => IsFixed g t) :=
  fun t => decidable_of_iff (step g t = t) Iff.rfl

theorem pull_apply (h : d ∣ n) (t : Config d) (i : ZMod n) :
    pull h t i = t (ZMod.castHom h (ZMod d) i) := rfl

/-- Pullbacks of fixed configurations are fixed: the local rule sees the shifted
indices through a ring homomorphism. -/
theorem pull_isFixed (h : d ∣ n) (g : LocalRule) {t : Config d} (ht : IsFixed g t) :
    IsFixed g (pull h t) := by
  funext i
  have h1 : ZMod.castHom h (ZMod d) (i - 1) = ZMod.castHom h (ZMod d) i - 1 := by
    rw [map_sub, map_one]
  have h2 : ZMod.castHom h (ZMod d) (i + 1) = ZMod.castHom h (ZMod d) i + 1 := by
    rw [map_add, map_one]
  show g (pull h t (i - 1)) (pull h t i) (pull h t (i + 1)) = pull h t i
  simp only [pull_apply, h1, h2]
  exact congrFun ht _

/-- Conversely, if a pullback is fixed then so is the original. -/
theorem isFixed_of_pull (h : d ∣ n) (g : LocalRule) {t : Config d}
    (hf : IsFixed g (pull h t)) : IsFixed g t := by
  funext x
  obtain ⟨i, rfl⟩ := ZMod.castHom_surjective h x
  have hi := congrFun hf i
  have h1 : ZMod.castHom h (ZMod d) (i - 1) = ZMod.castHom h (ZMod d) i - 1 := by
    rw [map_sub, map_one]
  have h2 : ZMod.castHom h (ZMod d) (i + 1) = ZMod.castHom h (ZMod d) i + 1 := by
    rw [map_add, map_one]
  simp only [step, pull_apply, h1, h2] at hi
  exact hi

theorem pull_injective (h : d ∣ n) : Injective (pull h : Config d → Config n) := by
  intro t u htu
  funext x
  obtain ⟨i, rfl⟩ := ZMod.castHom_surjective h x
  exact congrFun htu i

/-- A `d`-periodic configuration is invariant under adding any natural multiple of
`d`. -/
theorem periodic_add_natMul {s : Config n} (hper : ∀ i, s (i + (d : ZMod n)) = s i)
    (k : ℕ) (x : ZMod n) : s (x + (d : ZMod n) * (k : ZMod n)) = s x := by
  induction k generalizing x with
  | zero => simp
  | succ m ih =>
      have e : x + (d : ZMod n) * ((m + 1 : ℕ) : ZMod n)
          = (x + (d : ZMod n) * (m : ZMod n)) + (d : ZMod n) := by push_cast; ring
      rw [e, hper, ih]

/-- **Descent.**  A `d`-periodic configuration on `ZMod n` is the pullback of a
configuration on `ZMod d`. -/
theorem exists_pull_of_periodic [NeZero n] [NeZero d] (h : d ∣ n) {s : Config n}
    (hper : ∀ i, s (i + (d : ZMod n)) = s i) : ∃ t : Config d, s = pull h t := by
  refine ⟨fun x => s ((x.val : ℕ) : ZMod n), ?_⟩
  funext i
  have hcast : ZMod.castHom h (ZMod d) i = ((i.val : ℕ) : ZMod d) := by
    rw [ZMod.castHom_apply, ZMod.natCast_val]
  simp only [pull_apply, hcast, ZMod.val_natCast]
  have hsplit : ((i.val % d : ℕ) : ZMod n) + (d : ZMod n) * ((i.val / d : ℕ) : ZMod n)
      = (i.val : ZMod n) := by
    have : (i.val % d) + d * (i.val / d) = i.val := Nat.mod_add_div _ _
    calc ((i.val % d : ℕ) : ZMod n) + (d : ZMod n) * ((i.val / d : ℕ) : ZMod n)
        = (((i.val % d) + d * (i.val / d) : ℕ) : ZMod n) := by push_cast; ring
      _ = (i.val : ZMod n) := by rw [this]
  have hval : ((i.val : ℕ) : ZMod n) = i := by rw [ZMod.natCast_val, ZMod.cast_id]
  have hfin := periodic_add_natMul hper (i.val / d) ((i.val % d : ℕ) : ZMod n)
  rw [hsplit, hval] at hfin
  exact hfin

/-- **The count is invariant under descent.**  If `d ∣ n` and every fixed
configuration on `ZMod n` is `d`-periodic, the fixed-point sets on `ZMod n` and on
`ZMod d` have the same cardinality. -/
theorem ncard_fixed_eq_of_periodic [NeZero n] [NeZero d] (h : d ∣ n) (g : LocalRule)
    (hper : ∀ s : Config n, IsFixed g s → ∀ i, s (i + (d : ZMod n)) = s i) :
    {s : Config n | IsFixed g s}.ncard = {t : Config d | IsFixed g t}.ncard := by
  have himg : {s : Config n | IsFixed g s} = pull h '' {t : Config d | IsFixed g t} := by
    ext s
    simp only [Set.mem_setOf_eq, Set.mem_image]
    constructor
    · intro hs
      obtain ⟨t, rfl⟩ := exists_pull_of_periodic h (hper s hs)
      exact ⟨t, isFixed_of_pull h g hs, rfl⟩
    · rintro ⟨t, ht, rfl⟩
      exact pull_isFixed h g ht
  rw [himg, Set.ncard_image_of_injective _ (pull_injective h)]

/-- **Divisibility monotonicity.**  For every rule, the fixed-point count on a lattice
of size `d` is at most the count on any lattice whose size is a multiple of `d`. -/
theorem ncard_fixed_mono_of_dvd [NeZero n] (h : d ∣ n) (g : LocalRule) :
    {t : Config d | IsFixed g t}.ncard ≤ {s : Config n | IsFixed g s}.ncard := by
  exact Set.ncard_le_ncard_of_injOn (pull h) (fun t ht => pull_isFixed h g ht)
    (fun t _ u _ htu => pull_injective h htu) (Set.toFinite _)

/-- If the period `d` is invertible modulo `n`, then `d`-periodicity forces
constancy. -/
theorem const_of_periodic_of_isUnit [NeZero n] {s : Config n}
    (hu : IsUnit ((d : ℕ) : ZMod n)) (hper : ∀ i, s (i + (d : ZMod n)) = s i)
    (i j : ZMod n) : s i = s j := by
  obtain ⟨v, hv⟩ := hu
  set u : ZMod n := (↑v⁻¹ : ZMod n) * (j - i) with hu_def
  have hdu : (d : ZMod n) * u = j - i := by
    rw [hu_def, ← hv, ← mul_assoc]
    simp
  have hk : ((u.val : ℕ) : ZMod n) = u := by rw [ZMod.natCast_val, ZMod.cast_id]
  have := periodic_add_natMul hper u.val i
  rw [hk, hdu] at this
  rw [← this]
  congr 1
  ring

/-! ## 2. Rule 150: the count is `4` on even lattices and `2` on odd ones -/

theorem rule150_fixed_const (c : Cell) : IsFixed (n := n) rule150 (fun _ => c) := by
  funext i
  show c + c + c = c
  have h2 : (2 : Cell) = 0 := by decide
  linear_combination c * h2

theorem rule150_base : {t : Config 2 | IsFixed rule150 t}.ncard = 4 := by
  have hset : {t : Config 2 | IsFixed rule150 t}
      = ↑(Finset.univ.filter (fun t : Config 2 => IsFixed rule150 t)) := by
    ext t; simp
  rw [hset, Set.ncard_coe_finset]
  decide

theorem rule150_ncard_of_even [NeZero n] (hn : 2 ∣ n) :
    {s : Config n | IsFixed rule150 s}.ncard = 4 := by
  have h2 : NeZero (2 : ℕ) := ⟨by norm_num⟩
  have hper : ∀ s : Config n, IsFixed rule150 s → ∀ i, s (i + ((2 : ℕ) : ZMod n)) = s i := by
    intro s hs i
    have := (rule150_fixed_iff_two_periodic s).mp hs i
    simpa using this
  rw [ncard_fixed_eq_of_periodic hn rule150 hper, rule150_base]

theorem rule150_ncard_of_odd [NeZero n] (hn : ¬ 2 ∣ n) :
    {s : Config n | IsFixed rule150 s}.ncard = 2 := by
  have hunit : IsUnit ((2 : ℕ) : ZMod n) := by
    rw [ZMod.isUnit_iff_coprime]
    exact (Nat.Prime.coprime_iff_not_dvd (by norm_num)).mpr hn
  have hset : {s : Config n | IsFixed rule150 s}
      = {(fun _ => 0 : Config n), (fun _ => 1 : Config n)} := by
    ext s
    simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
    constructor
    · intro hs
      have hper : ∀ i, s (i + ((2 : ℕ) : ZMod n)) = s i := by
        intro i
        have := (rule150_fixed_iff_two_periodic s).mp hs i
        simpa using this
      have hconst : ∀ i j, s i = s j := const_of_periodic_of_isUnit hunit hper
      rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s 0) with h0 | h0
      · left; funext i; rw [hconst i 0, h0]
      · right; funext i; rw [hconst i 0, h0]
    · rintro (rfl | rfl)
      · exact rule150_fixed_const 0
      · exact rule150_fixed_const 1
  rw [hset]
  refine Set.ncard_pair ?_
  intro hcon
  have := congrFun hcon 0
  revert this
  decide

/-- **The rule 150 fixed-point count, for every lattice size.** -/
theorem rule150_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed rule150 s}.ncard = if 2 ∣ n then 4 else 2 := by
  by_cases h : 2 ∣ n
  · rw [if_pos h, rule150_ncard_of_even h]
  · rw [if_neg h, rule150_ncard_of_odd h]

/-! ## 3. Rule 90: the count is `4` on multiples of `3` and `1` otherwise -/

/-- Fixed configurations of rule 90 obey the `GF(2)` Fibonacci recurrence, hence are
`3`-periodic: over `GF(2)` the Fibonacci recurrence has period `3`. -/
theorem rule90_three_periodic {s : Config n} (hs : IsFixed rule90 s) (i : ZMod n) :
    s (i + 3) = s i := by
  have h2 : (2 : Cell) = 0 := by decide
  have hfib := (rule90_fixed_iff_fib s).mp hs
  have e1 := hfib (i + 1)
  have e2 := hfib (i + 2)
  rw [show i + 1 + 1 = i + 2 from by ring, show i + 1 - 1 = i from by ring] at e1
  rw [show i + 2 + 1 = i + 3 from by ring, show i + 2 - 1 = i + 1 from by ring] at e2
  linear_combination e1 + e2 + s (i + 1) * h2

theorem rule90_base : {t : Config 3 | IsFixed rule90 t}.ncard = 4 := by
  have hset : {t : Config 3 | IsFixed rule90 t}
      = ↑(Finset.univ.filter (fun t : Config 3 => IsFixed rule90 t)) := by
    ext t; simp
  rw [hset, Set.ncard_coe_finset]
  decide

theorem rule90_ncard_of_dvd [NeZero n] (hn : 3 ∣ n) :
    {s : Config n | IsFixed rule90 s}.ncard = 4 := by
  have h3 : NeZero (3 : ℕ) := ⟨by norm_num⟩
  have hper : ∀ s : Config n, IsFixed rule90 s → ∀ i, s (i + ((3 : ℕ) : ZMod n)) = s i := by
    intro s hs i
    have := rule90_three_periodic hs i
    simpa using this
  rw [ncard_fixed_eq_of_periodic hn rule90 hper, rule90_base]

theorem rule90_ncard_of_not_dvd [NeZero n] (hn : ¬ 3 ∣ n) :
    {s : Config n | IsFixed rule90 s}.ncard = 1 := by
  have hunit : IsUnit ((3 : ℕ) : ZMod n) := by
    rw [ZMod.isUnit_iff_coprime]
    exact (Nat.Prime.coprime_iff_not_dvd (by norm_num)).mpr hn
  have hset : {s : Config n | IsFixed rule90 s} = {(0 : Config n)} := by
    ext s
    simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
    constructor
    · intro hs
      have hper : ∀ i, s (i + ((3 : ℕ) : ZMod n)) = s i := by
        intro i
        have := rule90_three_periodic hs i
        simpa using this
      have hconst : ∀ i j, s i = s j := const_of_periodic_of_isUnit hunit hper
      have h0 := congrFun hs 0
      simp only [step, rule90] at h0
      rw [hconst (0 - 1) 0, hconst (0 + 1) 0] at h0
      have h2 : (2 : Cell) = 0 := by decide
      have hz : s 0 = 0 := by linear_combination - h0 + s 0 * h2
      funext i
      simpa using (hconst i 0).trans hz
    · rintro rfl
      funext i
      show (0 : Cell) + 0 = 0
      ring
  rw [hset, Set.ncard_singleton]

/-- **The rule 90 fixed-point count, for every lattice size.** -/
theorem rule90_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed rule90 s}.ncard = if 3 ∣ n then 4 else 1 := by
  by_cases h : 3 ∣ n
  · rw [if_pos h, rule90_ncard_of_dvd h]
  · rw [if_neg h, rule90_ncard_of_not_dvd h]

/-! ## 4. Rule 30: the count is `3` on even lattices and `1` on odd ones -/

/-- Rule 30, `g a b c = a + b + c + b*c` over `GF(2)`: Wolfram's chaotic Class-3
example. -/
def rule30 : LocalRule := fun a b c => a + b + c + b * c

theorem numOfRule_rule30 : numOfRule rule30 = 30 := by decide

/-- The fixed-point equation of rule 30, in cleared form. -/
theorem rule30_fixed_relation {s : Config n} (hs : IsFixed rule30 s) (i : ZMod n) :
    s (i - 1) + s (i + 1) + s i * s (i + 1) = 0 := by
  have hi := congrFun hs i
  simp only [step, rule30] at hi
  linear_combination hi

/-- Every fixed configuration of rule 30 is two-periodic. -/
theorem rule30_two_periodic {s : Config n} (hs : IsFixed rule30 s) (i : ZMod n) :
    s (i + 2) = s i := by
  have h2 : (2 : Cell) = 0 := by decide
  have e1 := rule30_fixed_relation hs (i + 1)
  rw [show i + 1 - 1 = i from by ring, show i + 1 + 1 = i + 2 from by ring] at e1
  rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s (i + 1)) with h | h
  · rw [h] at e1
    linear_combination e1 - s i * h2
  · -- `s (i+1) = 1` forces both `s i` and `s (i+2)` to vanish
    have hi0 : s i = 0 := by
      rw [h] at e1
      linear_combination e1 - s (i + 2) * h2
    have e2 := rule30_fixed_relation hs (i + 2)
    rw [show i + 2 - 1 = i + 1 from by ring, show i + 2 + 1 = i + 3 from by ring] at e2
    rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s (i + 2)) with h' | h'
    · rw [h', hi0]
    · exfalso
      rw [h, h'] at e2
      have : (1 : Cell) = 0 := by linear_combination e2 - s (i + 3) * h2
      revert this
      decide

theorem rule30_base : {t : Config 2 | IsFixed rule30 t}.ncard = 3 := by
  have hset : {t : Config 2 | IsFixed rule30 t}
      = ↑(Finset.univ.filter (fun t : Config 2 => IsFixed rule30 t)) := by
    ext t; simp
  rw [hset, Set.ncard_coe_finset]
  decide

theorem rule30_ncard_of_even [NeZero n] (hn : 2 ∣ n) :
    {s : Config n | IsFixed rule30 s}.ncard = 3 := by
  have h2 : NeZero (2 : ℕ) := ⟨by norm_num⟩
  have hper : ∀ s : Config n, IsFixed rule30 s → ∀ i, s (i + ((2 : ℕ) : ZMod n)) = s i := by
    intro s hs i
    have := rule30_two_periodic hs i
    simpa using this
  rw [ncard_fixed_eq_of_periodic hn rule30 hper, rule30_base]

theorem rule30_ncard_of_odd [NeZero n] (hn : ¬ 2 ∣ n) :
    {s : Config n | IsFixed rule30 s}.ncard = 1 := by
  have hunit : IsUnit ((2 : ℕ) : ZMod n) := by
    rw [ZMod.isUnit_iff_coprime]
    exact (Nat.Prime.coprime_iff_not_dvd (by norm_num)).mpr hn
  have hset : {s : Config n | IsFixed rule30 s} = {(0 : Config n)} := by
    ext s
    simp only [Set.mem_setOf_eq, Set.mem_singleton_iff]
    constructor
    · intro hs
      have hper : ∀ i, s (i + ((2 : ℕ) : ZMod n)) = s i := by
        intro i
        have := rule30_two_periodic hs i
        simpa using this
      have hconst : ∀ i j, s i = s j := const_of_periodic_of_isUnit hunit hper
      have h0 := rule30_fixed_relation hs 0
      rw [hconst (0 - 1) 0, hconst (0 + 1) 0] at h0
      have h2 : (2 : Cell) = 0 := by decide
      have hsq : s 0 * s 0 = s 0 := by
        rcases (by decide : ∀ c : Cell, c = 0 ∨ c = 1) (s 0) with hc | hc <;> rw [hc] <;> ring
      have hz : s 0 = 0 := by linear_combination h0 - hsq - s 0 * h2
      funext i
      simpa using (hconst i 0).trans hz
    · rintro rfl
      funext i
      show (0 : Cell) + 0 + 0 + 0 * 0 = 0
      ring
  rw [hset, Set.ncard_singleton]

/-- **The rule 30 fixed-point count, for every lattice size.**  Rule 30 is Wolfram's
chaotic Class-3 example, yet its fixed-point statistic is as tame as that of the
additive rules. -/
theorem rule30_fixedPoints_ncard [NeZero n] :
    {s : Config n | IsFixed rule30 s}.ncard = if 2 ∣ n then 3 else 1 := by
  by_cases h : 2 ∣ n
  · rw [if_pos h, rule30_ncard_of_even h]
  · rw [if_neg h, rule30_ncard_of_odd h]

/-! ## 5. Comparing rules through the fixed-point statistic -/

/-- The additive rule 90 and the universal rule 110 are distinguished by their
fixed-point counts exactly on the multiples of `3`: elsewhere both counts equal `1`.
So the statistic separates a Class-3 rule from a Class-4 rule only for `3 ∣ n`, and
never separates rule 110 from the fifteen other rules of the census. -/
theorem rule90_ncard_ne_rule110_ncard [NeZero n] :
    ({s : Config n | IsFixed rule90 s}.ncard ≠ {s : Config n | IsFixed rule110 s}.ncard)
      ↔ 3 ∣ n := by
  rw [rule110_fixedPoints_ncard, rule90_fixedPoints_ncard]
  by_cases h : 3 ∣ n
  · simp [h]
  · simp [h]

/-- Rule 150 always has at least as many fixed configurations as rule 110, with strict
inequality for every lattice size: `2 ≤ #V(150,n)` while `#V(110,n) = 1`. -/
theorem rule110_ncard_lt_rule150_ncard [NeZero n] :
    {s : Config n | IsFixed rule110 s}.ncard < {s : Config n | IsFixed rule150 s}.ncard := by
  rw [rule110_fixedPoints_ncard, rule150_fixedPoints_ncard]
  by_cases h : 2 ∣ n <;> simp [h]

end CAFixedPointCounts