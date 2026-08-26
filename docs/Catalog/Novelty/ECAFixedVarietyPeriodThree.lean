import Novelty.ECAFixedVarietyCore

/-!
# Period-three rigidity: the fixed-point variety depends on `n mod 3`

Wolfram's classification assigns a **single** class to a rule, independently of
the ring size `n`.  We show that the fixed-point variety cannot possibly encode
such an `n`-independent invariant, because for two of the most-studied rules —
the additive Rule 90 and the chaotic Rule 45 (both Wolfram class 3) — the
variety is governed by the arithmetic of `n mod 3`:

* `rule90_period_three`, `rule45_period_three` — every stationary configuration
  of Rule 90 or Rule 45 is invariant under the shift by `3`.
* `rule90_fixedSet_eq_zero_of_not_three_dvd` — if `3 ∤ n` then Rule 90 has only
  the zero configuration: dimension `0`.
* `rule90_exists_nonzero_fixed_of_three_dvd` — if `3 ∣ n` (and `n ≠ 0`) the
  variety is strictly bigger: it contains the `3`-periodic wave `011011…`.
* `rule90_hasFixedDim_le_two` — but it never exceeds dimension `2`; in
  particular `rule90_dim_lt_half`, so a class-3 rule violates the predicted
  `dim ≥ n/2` for all `n ≥ 5`.
* `rule45_fixedSet_empty_of_not_three_dvd` — the class-3 Rule 45 has an
  **empty** fixed-point variety when `3 ∤ n`, so no dimension is even definable.
* `rule45_exists_fixed_of_three_dvd` — while for `3 ∣ n` it is non-empty.

The common mechanism is the *transfer relation* of the fixed-point subshift: for
both rules two (resp. three) consecutive stationarity constraints force
`s_{i+3} = s_i`, and when `3` is invertible in `ZMod n` this collapses the whole
configuration to a constant, which the local rule then pins down.
-/

namespace ECAFixedVariety

/-! ### Consequences of shift-by-three invariance -/

/-- If `3` is invertible modulo `n`, shift-by-three invariance upgrades to
shift-by-one invariance: the configuration is constant. -/
lemma shift_one_of_period_three {n : ℕ} (hn : ¬ (3 ∣ n)) {s : Cfg n}
    (h : ∀ i, s (i + 3) = s i) : ∀ i, s (i + 1) = s i := by
  have hn0 : n ≠ 0 := by
    rintro rfl
    exact hn ⟨0, rfl⟩
  have hcop : Nat.Coprime 3 n := (Nat.Prime.coprime_iff_not_dvd (by norm_num)).2 hn
  refine shift_one_of_period_coprime hn0 hcop ?_
  intro i
  have hi := h i
  simpa using hi

/-! ### Rule 90 -/

/-- Rule 90 is the additive rule `l + r`. -/
lemma rule90_local_iff : ∀ l c r : ZMod 2, localRuleZ 90 l c r = c ↔ l + r = c := by decide

/-- Rule 90 is additive, so its fixed-point variety is a linear subvariety. -/
lemma rule90_isAdditive : IsAdditive 90 := by
  intro l c r l' c' r'
  revert l c r l' c' r'
  decide

/-- **Transfer relation for Rule 90.**  Two consecutive stationarity constraints
force the shift-by-three symmetry. -/
lemma rule90_period_three {n : ℕ} {s : Cfg n} (hs : s ∈ fixedSet 90 n) :
    ∀ i, s (i + 3) = s i := by
  rw [mem_fixedSet_iff] at hs
  have key : ∀ a b c d : ZMod 2,
      localRuleZ 90 a b c = b → localRuleZ 90 b c d = c → d = a := by decide
  intro i
  have h1 := hs (i + 1)
  have h2 := hs (i + 2)
  rw [show i + 1 - 1 = i from by ring, show i + 1 + 1 = i + 2 from by ring] at h1
  rw [show i + 2 - 1 = i + 1 from by ring, show i + 2 + 1 = i + 3 from by ring] at h2
  exact key _ _ _ _ h1 h2

/-- **Rigidity for `3 ∤ n`.**  Rule 90 then fixes only the zero configuration. -/
theorem rule90_fixedSet_eq_zero_of_not_three_dvd {n : ℕ} (hn : ¬ (3 ∣ n)) :
    fixedSet 90 n = {0} := by
  ext s
  rw [Set.mem_singleton_iff]
  constructor
  · intro hs
    have hshift := shift_one_of_period_three hn (rule90_period_three hs)
    rw [mem_fixedSet_iff] at hs
    funext i
    show s i = 0
    have hprev : s i = s (i - 1) := by
      have := hshift (i - 1)
      rwa [show i - 1 + 1 = i from by ring] at this
    have hnext : s (i + 1) = s i := hshift i
    have h := hs i
    rw [rule90_local_iff, hnext, ← hprev] at h
    -- `s i + s i = s i` forces `s i = 0`
    have : ∀ x : ZMod 2, x + x = x → x = 0 := by decide
    exact this _ h
  · rintro rfl
    rw [mem_fixedSet_iff]
    intro i
    simp [show localRuleZ 90 0 0 0 = 0 from by decide]

/-- The `3`-periodic wave `…011011…`, defined through the ring map
`ZMod n → ZMod 3` available when `3 ∣ n`. -/
def wave3 {n : ℕ} (h : 3 ∣ n) : Cfg n :=
  fun i => if ZMod.castHom h (ZMod 3) i = 0 then 0 else 1

/-- **Non-rigidity for `3 ∣ n`.**  Rule 90 then has a non-zero stationary
configuration, so its variety jumps in dimension. -/
theorem rule90_exists_nonzero_fixed_of_three_dvd {n : ℕ} (h : 3 ∣ n) :
    ∃ s ∈ fixedSet 90 n, s ≠ 0 := by
  refine ⟨wave3 h, ?_, ?_⟩
  · rw [mem_fixedSet_iff]
    intro i
    have key : ∀ x : ZMod 3,
        localRuleZ 90 (if x - 1 = 0 then 0 else 1) (if x = 0 then 0 else 1)
          (if x + 1 = 0 then 0 else 1) = (if x = 0 then 0 else 1) := by decide
    have e1 : ZMod.castHom h (ZMod 3) (i - 1) = ZMod.castHom h (ZMod 3) i - 1 := by
      rw [map_sub, map_one]
    have e2 : ZMod.castHom h (ZMod 3) (i + 1) = ZMod.castHom h (ZMod 3) i + 1 := by
      rw [map_add, map_one]
    simp only [wave3, e1, e2]
    exact key _
  · intro hzero
    have h1 : wave3 h 1 = 0 := by rw [hzero]; rfl
    rw [wave3] at h1
    simp only [map_one] at h1
    revert h1
    norm_num

/-- Two stationary Rule-90 configurations agreeing at cells `0` and `1` agree
everywhere: the variety embeds into the plane of "initial conditions". -/
lemma rule90_eq_zero_of_two_zeros {n : ℕ} [NeZero n] {s : Cfg n}
    (hs : s ∈ fixedSet 90 n) (h0 : s 0 = 0) (h1 : s 1 = 0) : s = 0 := by
  rw [mem_fixedSet_iff] at hs
  have key : ∀ k : ℕ, s ((k : ℕ) : ZMod n) = 0 ∧ s (((k + 1 : ℕ) : ℕ) : ZMod n) = 0 := by
    intro k
    induction k with
    | zero => simpa using ⟨h0, h1⟩
    | succ m ih =>
        obtain ⟨hm, hm1⟩ := ih
        refine ⟨by simpa using hm1, ?_⟩
        have hcon := hs (((m + 1 : ℕ) : ZMod n))
        rw [rule90_local_iff] at hcon
        have e1 : ((m + 1 : ℕ) : ZMod n) - 1 = ((m : ℕ) : ZMod n) := by push_cast; ring
        have e2 : ((m + 1 : ℕ) : ZMod n) + 1 = ((m + 2 : ℕ) : ZMod n) := by push_cast; ring
        rw [e1, e2, hm, hm1] at hcon
        have : ((m + 1 + 1 : ℕ) : ZMod n) = ((m + 2 : ℕ) : ZMod n) := by push_cast; ring
        rw [this]
        simpa using hcon
  funext i
  show s i = 0
  have : ((i.val : ℕ) : ZMod n) = i := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hk := (key i.val).1
  rwa [this] at hk

/-- **Dimension cap for Rule 90.**  Whatever `n` is, the fixed-point variety of
Rule 90 has dimension at most `2`. -/
theorem rule90_hasFixedDim_le_two {n d : ℕ} [NeZero n] (h : HasFixedDim 90 n d) : d ≤ 2 :=
  hasFixedDim_le_two_of_seed_rigid
    (fun _ hs h0 h1 => rule90_eq_zero_of_two_zeros hs h0 h1) h

/-- A class-3 rule that badly violates the predicted `dim ≥ n/2`: Rule 90 has
dimension `≤ 2` while `n` grows. -/
theorem rule90_dim_lt_half {n d : ℕ} [NeZero n] (hn : 5 ≤ n) (h : HasFixedDim 90 n d) :
    2 * d < n := by
  have := rule90_hasFixedDim_le_two h
  omega

/-! ### Rule 45 -/

/-- **Transfer relation for Rule 45.**  Three consecutive stationarity
constraints force the shift-by-three symmetry. -/
lemma rule45_period_three {n : ℕ} {s : Cfg n} (hs : s ∈ fixedSet 45 n) :
    ∀ i, s (i + 3) = s i := by
  rw [mem_fixedSet_iff] at hs
  have key : ∀ a b c d e : ZMod 2, localRuleZ 45 a b c = b → localRuleZ 45 b c d = c →
      localRuleZ 45 c d e = d → d = a := by decide
  intro i
  have h1 := hs (i + 1)
  have h2 := hs (i + 2)
  have h3 := hs (i + 3)
  rw [show i + 1 - 1 = i from by ring, show i + 1 + 1 = i + 2 from by ring] at h1
  rw [show i + 2 - 1 = i + 1 from by ring, show i + 2 + 1 = i + 3 from by ring] at h2
  rw [show i + 3 - 1 = i + 2 from by ring] at h3
  exact key _ _ _ _ _ h1 h2 h3

/-- **The class-3 Rule 45 has an empty fixed-point variety when `3 ∤ n`.**
Its "dimension" is therefore not merely small, it is undefined. -/
theorem rule45_fixedSet_empty_of_not_three_dvd {n : ℕ} (hn : ¬ (3 ∣ n)) :
    fixedSet 45 n = ∅ := by
  ext s
  simp only [Set.mem_empty_iff_false, iff_false]
  intro hs
  have hshift := shift_one_of_period_three hn (rule45_period_three hs)
  rw [mem_fixedSet_iff] at hs
  have hprev : s 0 = s (0 - 1) := by
    have := hshift (0 - 1)
    rwa [show (0 : ZMod n) - 1 + 1 = 0 from by ring] at this
  have hnext : s (0 + 1) = s 0 := hshift 0
  have h := hs 0
  rw [hnext, ← hprev] at h
  have : ∀ x : ZMod 2, localRuleZ 45 x x x ≠ x := by decide
  exact this _ h

/-- The `3`-periodic pulse train `…100100…`. -/
def pulse3 {n : ℕ} (h : 3 ∣ n) : Cfg n :=
  fun i => if ZMod.castHom h (ZMod 3) i = 0 then 1 else 0

/-- **For `3 ∣ n` the Rule 45 variety is non-empty**: it contains the pulse
train of period `3`. -/
theorem rule45_exists_fixed_of_three_dvd {n : ℕ} (h : 3 ∣ n) :
    pulse3 h ∈ fixedSet 45 n := by
  rw [mem_fixedSet_iff]
  intro i
  have key : ∀ x : ZMod 3,
      localRuleZ 45 (if x - 1 = 0 then 1 else 0) (if x = 0 then 1 else 0)
        (if x + 1 = 0 then 1 else 0) = (if x = 0 then 1 else 0) := by decide
  have e1 : ZMod.castHom h (ZMod 3) (i - 1) = ZMod.castHom h (ZMod 3) i - 1 := by
    rw [map_sub, map_one]
  have e2 : ZMod.castHom h (ZMod 3) (i + 1) = ZMod.castHom h (ZMod 3) i + 1 := by
    rw [map_add, map_one]
  simp only [pulse3, e1, e2]
  exact key _

/-- **Arithmetic obstruction.**  For Rule 45 the very *existence* of a
stationary configuration depends on `n mod 3`, whereas Wolfram's class of a rule
does not depend on `n` at all. -/
theorem rule45_fixedSet_nonempty_iff_three_dvd (n : ℕ) :
    (fixedSet 45 n).Nonempty ↔ 3 ∣ n := by
  constructor
  · intro ⟨s, hs⟩
    by_contra hn
    rw [rule45_fixedSet_empty_of_not_three_dvd hn] at hs
    exact hs
  · intro h
    exact ⟨pulse3 h, rule45_exists_fixed_of_three_dvd h⟩

end ECAFixedVariety