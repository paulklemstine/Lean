import Novelty.ECAFixedVarietyPeriodThree

/-!
# Cycle 5: parity rigidity of Rule 150

Rule 150, `f(l,c,r) = l + c + r`, is the second classical additive automaton and
is placed in Wolfram class 3 (chaotic).  Its fixed-point equations read
`l + r = 0`, i.e. `s_{i-1} = s_{i+1}`: the variety is the space of
**period-two** configurations.  Consequently its dimension is controlled by the
parity of the ring size, and never exceeds `2`:

* `rule150_period_two` — every stationary configuration has spatial period `2`.
* `rule150_fixedSet_of_odd` — for odd `n` the variety is exactly the pair of
  constant configurations `{0, 1}`; so if a dimension exists it equals `1`.
* `rule150_alternating_mem` — for even `n` the alternating configuration
  (the reduction map `ZMod n → ZMod 2`) is a non-constant stationary point, so
  the variety strictly grows.
* `rule150_hasFixedDim_le_two` and `rule150_dim_lt_half` — the dimension is at
  most `2` for every `n`, so this class-3 rule violates the conjectured
  `dim ≥ n/2` for all `n ≥ 5`.

Together with the mod-3 dichotomy of Rules 90 and 45 this exhibits the general
phenomenon: the fixed-point variety of an additive rule is the kernel of a
circulant matrix, and its dimension is a *number-theoretic* function of `n` —
never a Wolfram class.
-/

namespace ECAFixedVariety

/-- Rule 150 is the additive rule `l + c + r`; stationarity says `l + r = 0`. -/
lemma rule150_local_iff : ∀ l c r : ZMod 2, localRuleZ 150 l c r = c ↔ l + r = 0 := by decide

/-- Rule 150 is additive, so its fixed-point locus is a linear subvariety. -/
lemma rule150_isAdditive : IsAdditive 150 := by
  intro l c r l' c' r'
  revert l c r l' c' r'
  decide

/-- **Transfer relation for Rule 150.**  Stationary configurations have spatial
period two. -/
theorem rule150_period_two {n : ℕ} {s : Cfg n} (hs : s ∈ fixedSet 150 n) :
    ∀ i, s (i + 2) = s i := by
  rw [mem_fixedSet_iff] at hs
  have key : ∀ a b : ZMod 2, a + b = 0 → b = a := by decide
  intro i
  have h1 := hs (i + 1)
  rw [show i + 1 - 1 = i from by ring, show i + 1 + 1 = i + 2 from by ring,
    rule150_local_iff] at h1
  exact key _ _ h1

/-- Constant configurations are stationary for Rule 150. -/
lemma rule150_const_mem {n : ℕ} (a : ZMod 2) :
    (fun _ : ZMod n => a) ∈ fixedSet 150 n := by
  rw [mem_fixedSet_iff]
  intro i
  have : ∀ x : ZMod 2, localRuleZ 150 x x x = x := by decide
  exact this a

/-- **Odd rings are rigid.**  For odd `n` the only stationary configurations of
Rule 150 are the two constants. -/
theorem rule150_fixedSet_of_odd {n : ℕ} (hn : ¬ (2 ∣ n)) :
    fixedSet 150 n = {0, 1} := by
  have hn0 : n ≠ 0 := by
    rintro rfl
    exact hn ⟨0, rfl⟩
  haveI : NeZero n := ⟨hn0⟩
  have hcop : Nat.Coprime 2 n := (Nat.Prime.coprime_iff_not_dvd (by norm_num)).2 hn
  ext s
  constructor
  · intro hs
    have hper : ∀ i, s (i + ((2 : ℕ) : ZMod n)) = s i := by
      intro i
      have := rule150_period_two hs i
      simpa using this
    have hconst := constant_of_shift_one (shift_one_of_period_coprime hn0 hcop hper)
    rcases zmod2_eq_zero_or_one (s 0) with h0 | h0
    · left
      funext i
      simpa [h0] using hconst i
    · right
      funext i
      simpa [h0] using hconst i
  · rintro (rfl | rfl)
    · exact rule150_const_mem 0
    · exact rule150_const_mem 1

/-- The alternating configuration, i.e. the reduction map `ZMod n → ZMod 2`,
available when `n` is even. -/
def alternating {n : ℕ} (h : 2 ∣ n) : Cfg n := fun i => ZMod.castHom h (ZMod 2) i

/-- **Even rings are not rigid.**  For even `n` the alternating configuration is
a non-constant stationary point of Rule 150. -/
theorem rule150_alternating_mem {n : ℕ} (h : 2 ∣ n) :
    alternating h ∈ fixedSet 150 n := by
  rw [mem_fixedSet_iff]
  intro i
  have e1 : ZMod.castHom h (ZMod 2) (i - 1) = ZMod.castHom h (ZMod 2) i - 1 := by
    rw [map_sub, map_one]
  have e2 : ZMod.castHom h (ZMod 2) (i + 1) = ZMod.castHom h (ZMod 2) i + 1 := by
    rw [map_add, map_one]
  have key : ∀ x : ZMod 2, localRuleZ 150 (x - 1) x (x + 1) = x := by decide
  simp only [alternating, e1, e2]
  exact key _

/-- The alternating configuration really is non-constant: it separates the cells
`0` and `1`. -/
theorem rule150_alternating_ne_const {n : ℕ} (h : 2 ∣ n) :
    alternating h 0 ≠ alternating h 1 := by
  simp only [alternating, map_zero, map_one]
  decide

/-- Rule 150 is seed-rigid: a stationary configuration vanishing at the cells
`0` and `1` vanishes identically. -/
theorem rule150_eq_zero_of_two_zeros {n : ℕ} [NeZero n] {s : Cfg n}
    (hs : s ∈ fixedSet 150 n) (h0 : s 0 = 0) (h1 : s 1 = 0) : s = 0 := by
  have hper := rule150_period_two hs
  have key : ∀ k : ℕ, s ((k : ℕ) : ZMod n) = 0 ∧ s (((k + 1 : ℕ) : ℕ) : ZMod n) = 0 := by
    intro k
    induction k with
    | zero => simpa using ⟨h0, h1⟩
    | succ m ih =>
        obtain ⟨hm, hm1⟩ := ih
        refine ⟨by simpa using hm1, ?_⟩
        have e : ((m + 1 + 1 : ℕ) : ZMod n) = ((m : ℕ) : ZMod n) + 2 := by push_cast; ring
        rw [e, hper, hm]
  funext i
  show s i = 0
  have hi : ((i.val : ℕ) : ZMod n) = i := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hk := (key i.val).1
  rwa [hi] at hk

/-- **Dimension cap for Rule 150.**  Its fixed-point variety has dimension at
most `2`, for every ring size. -/
theorem rule150_hasFixedDim_le_two {n d : ℕ} [NeZero n] (h : HasFixedDim 150 n d) : d ≤ 2 :=
  hasFixedDim_le_two_of_seed_rigid
    (fun _ hs hz ho => rule150_eq_zero_of_two_zeros hs hz ho) h

/-- Rule 150 (Wolfram class 3) violates the conjectured bound `dim ≥ n/2`. -/
theorem rule150_dim_lt_half {n d : ℕ} [NeZero n] (hn : 5 ≤ n) (h : HasFixedDim 150 n d) :
    2 * d < n := by
  have := rule150_hasFixedDim_le_two h
  omega

/-- On an odd ring the dimension of the Rule 150 variety, if defined, is exactly
`1`: the variety has two points. -/
theorem rule150_dim_eq_one_of_odd {n d : ℕ} [NeZero n] (hodd : ¬ (2 ∣ n))
    (h : HasFixedDim 150 n d) : d = 1 := by
  have hcard := card_fixedSet_of_hasFixedDim h
  rw [rule150_fixedSet_of_odd hodd] at hcard
  have hne : (0 : Cfg n) ≠ 1 := by
    intro hc
    have h0 : (0 : ZMod 2) = 1 := congrFun hc 0
    exact absurd h0 (by decide)
  rw [Nat.card_coe_set_eq, Set.ncard_pair hne] at hcard
  have h2 : (2 : ℕ) ^ 1 = 2 ^ d := by simpa using hcard
  exact (Nat.pow_right_injective (le_refl 2) h2).symm

end ECAFixedVariety