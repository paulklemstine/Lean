import Novelty.ECAFixedVarietyNoDimension

/-!
# Cycle 2: the periodic-point lattice, a working replacement for the dimension

Cycle 1 showed that the fixed-point variety `V(f)` is blind to Wolfram
complexity: the Turing-complete Rule 110 and the null Rule 0 have *identical*
fixed loci.  The natural repair is to replace the single variety `V(f)` by the
whole tower of *temporal* varieties

  `Per_k(f) = { s : f^k(s) = s }`,

the `𝔽₂`-points of the fixed locus of the `k`-fold composite (a polynomial map
of degree `3^k`), i.e. the coefficients of the dynamical zeta function.

## Main results

* `iterate_eq_self_gcd` — a purely dynamical, number-theoretic lemma: the
  return times of a point are closed under `gcd`.
* `periodicSet_inter` — hence the tower is a **lattice under divisibility**:
  `Per_k ∩ Per_l = Per_{gcd(k,l)}`, and `periodicSet_mono_of_dvd` gives the
  order relation.
* `step_bijOn_periodicSet` — the automaton acts bijectively on each `Per_k`.
* `rule0_periodicSet` — the whole tower of the null rule collapses to a point.
* `rule110_two_cycle_mem`, `periodicSet_separates_rule110_rule0` — Rule 110 has a
  genuine `2`-cycle already on the ring of size `4`, so the tower **does**
  separate Rule 110 from Rule 0, unlike the fixed-point variety alone.
* `rule110_periodicSet_two_ncard`, `rule110_periodicSet_not_affine` — that
  temporal variety has `5` points, so it is not an affine subvariety either:
  even the repaired invariant is not a "dimension".
-/

namespace ECAFixedVariety

/-! ### The return-time lattice of an arbitrary self-map -/

/-- Return times are closed under addition of multiples. -/
lemma iterate_mul_eq_self {α : Type*} {f : α → α} {x : α} {k : ℕ} (hk : f^[k] x = x) :
    ∀ m : ℕ, f^[k * m] x = x := by
  intro m
  induction m with
  | zero => simp
  | succ p ih =>
      have : k * (p + 1) = k * p + k := by ring
      rw [this, Function.iterate_add_apply, hk, ih]

/-- **Return times are closed under `gcd`.**  If a point returns after `k` steps
and after `l` steps, it returns after `gcd k l` steps. -/
theorem iterate_eq_self_gcd {α : Type*} {f : α → α} {x : α} :
    ∀ k l : ℕ, f^[k] x = x → f^[l] x = x → f^[Nat.gcd k l] x = x := by
  intro k
  induction k using Nat.strong_induction_on with
  | _ k ih =>
    intro l hk hl
    rcases Nat.eq_zero_or_pos k with rfl | hkpos
    · simpa using hl
    · -- `l = k * (l / k) + l % k`, so the remainder is also a return time
      have hrem : f^[l % k] x = x := by
        have h2 := hl
        rw [← Nat.mod_add_div l k, Function.iterate_add_apply, iterate_mul_eq_self hk] at h2
        exact h2
      have hlt : l % k < k := Nat.mod_lt _ hkpos
      have := ih (l % k) hlt k hrem hk
      rwa [← Nat.gcd_rec] at this

/-! ### The temporal varieties of an elementary cellular automaton -/

/-- `Per_k(rule, n)`: the configurations of temporal period dividing `k`. -/
def periodicSet (rule n k : ℕ) : Set (Cfg n) := {s | (step rule)^[k] s = s}

@[simp] lemma mem_periodicSet_iff {rule n k : ℕ} {s : Cfg n} :
    s ∈ periodicSet rule n k ↔ (step rule)^[k] s = s := Iff.rfl

/-- Temporal periodicity is decidable on a finite ring. -/
instance decidableMemPeriodicSet (rule n k : ℕ) [NeZero n] (s : Cfg n) :
    Decidable (s ∈ periodicSet rule n k) :=
  inferInstanceAs (Decidable ((step rule)^[k] s = s))

/-- The fixed-point variety is the bottom of the tower. -/
lemma periodicSet_one (rule n : ℕ) : periodicSet rule n 1 = fixedSet rule n := by
  ext s
  simp [periodicSet, fixedSet]

/-- The tower is monotone for divisibility. -/
theorem periodicSet_mono_of_dvd {rule n k l : ℕ} (h : k ∣ l) :
    periodicSet rule n k ⊆ periodicSet rule n l := by
  rintro s hs
  obtain ⟨m, rfl⟩ := h
  exact iterate_mul_eq_self hs m

/-- **The temporal varieties form a lattice under divisibility.** -/
theorem periodicSet_inter (rule n k l : ℕ) :
    periodicSet rule n k ∩ periodicSet rule n l = periodicSet rule n (Nat.gcd k l) := by
  ext s
  constructor
  · rintro ⟨hk, hl⟩
    exact iterate_eq_self_gcd k l hk hl
  · intro h
    exact ⟨periodicSet_mono_of_dvd (Nat.gcd_dvd_left k l) h,
      periodicSet_mono_of_dvd (Nat.gcd_dvd_right k l) h⟩

/-- The automaton acts bijectively on every temporal variety: on `Per_k` the
inverse of `step` is `step^{k-1}`. -/
theorem step_bijOn_periodicSet (rule n : ℕ) {k : ℕ} (hk : 1 ≤ k) :
    Set.BijOn (step rule) (periodicSet rule n k) (periodicSet rule n k) := by
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  refine ⟨?_, ?_, ?_⟩
  · intro s hs
    have hs' : (step rule)^[m + 1] s = s := hs
    show (step rule)^[m + 1] (step rule s) = step rule s
    rw [← Function.iterate_succ_apply, Function.iterate_succ_apply', hs']
  · intro a ha b hb hab
    have ha' : (step rule)^[m + 1] a = a := ha
    have hb' : (step rule)^[m + 1] b = b := hb
    have hiter : (step rule)^[m] (step rule a) = (step rule)^[m] (step rule b) := by rw [hab]
    rw [← Function.iterate_succ_apply, ← Function.iterate_succ_apply, ha', hb'] at hiter
    exact hiter
  · intro s hs
    have hs' : (step rule)^[m + 1] s = s := hs
    refine ⟨(step rule)^[m] s, ?_, ?_⟩
    · show (step rule)^[m + 1] ((step rule)^[m] s) = (step rule)^[m] s
      rw [← Function.iterate_add_apply, Nat.add_comm, Function.iterate_add_apply, hs']
    · exact (Function.iterate_succ_apply' (step rule) m s).symm.trans hs'

/-! ### The tower collapses for Rule 0 -/

/-- Every temporal variety of the null rule is the single point `0`. -/
theorem rule0_periodicSet {n k : ℕ} (hk : 1 ≤ k) : periodicSet 0 n k = {0} := by
  have hstep : ∀ s : Cfg n, step 0 s = 0 := by
    intro s
    funext i
    exact rule0_localRuleZ _ _ _
  have hiter : ∀ (m : ℕ) (s : Cfg n), (step 0)^[m + 1] s = 0 := by
    intro m
    induction m with
    | zero => intro s; simpa using hstep s
    | succ p ih => intro s; rw [Function.iterate_succ_apply]; exact ih _
  obtain ⟨m, rfl⟩ : ∃ m, k = m + 1 := ⟨k - 1, by omega⟩
  ext s
  rw [Set.mem_singleton_iff]
  constructor
  · intro hs
    exact ((hiter m s).symm.trans hs).symm
  · rintro rfl
    show (step 0)^[m + 1] (0 : Cfg n) = 0
    exact hiter m 0

/-! ### Rule 110 genuinely oscillates -/

/-- An explicit `2`-cycle of Rule 110 on the ring of size `4`: the configuration
`1110`, which Rule 110 maps to `1011` and back. -/
def rule110Cycle : Cfg 4 := fun i => if i = 3 then 0 else 1

lemma rule110Cycle_mem_periodicSet : rule110Cycle ∈ periodicSet 110 4 2 := by
  show (step 110)^[2] rule110Cycle = rule110Cycle
  decide

lemma rule110Cycle_not_fixed : rule110Cycle ∉ fixedSet 110 4 := by
  show ¬ (step 110 rule110Cycle = rule110Cycle)
  decide

/-- **Rule 110 has a genuine oscillation.**  Its temporal variety at level `2`
is strictly larger than its fixed-point variety. -/
theorem rule110_fixedSet_ssubset_periodicSet :
    fixedSet 110 4 ⊂ periodicSet 110 4 2 := by
  constructor
  · rw [← periodicSet_one 110 4]
    exact periodicSet_mono_of_dvd ⟨2, rfl⟩
  · intro hsub
    exact rule110Cycle_not_fixed (hsub rule110Cycle_mem_periodicSet)

/-- **The repaired invariant works.**  Although the fixed-point varieties of
Rule 110 and Rule 0 coincide, their temporal varieties at level `2` differ, so
the tower `k ↦ Per_k` (equivalently the dynamical zeta function) does separate
the Turing-complete rule from the null rule. -/
theorem periodicSet_separates_rule110_rule0 :
    fixedSet 110 4 = fixedSet 0 4 ∧ periodicSet 110 4 2 ≠ periodicSet 0 4 2 := by
  refine ⟨rule110_fixedSet_eq_rule0_fixedSet 4, ?_⟩
  intro h
  have hmem : rule110Cycle ∈ periodicSet 0 4 2 := h ▸ rule110Cycle_mem_periodicSet
  rw [rule0_periodicSet (by norm_num), Set.mem_singleton_iff] at hmem
  have : rule110Cycle 0 = 0 := by rw [hmem]; rfl
  revert this
  decide

/-- The level-`2` temporal variety of Rule 110 on the ring of size `4` has
exactly `5` points: the origin and one `2`-cycle of four configurations. -/
theorem rule110_periodicSet_two_ncard : (periodicSet 110 4 2).ncard = 5 := by
  rw [← Nat.card_coe_set_eq, Nat.card_eq_fintype_card]
  decide

/-- Even the repaired invariant is not a dimension: `5 ∤ 16`, so the temporal
variety of Rule 110 is not an affine subvariety of `𝔸⁴_{𝔽₂}`. -/
theorem rule110_periodicSet_not_affine : ¬ IsAffineSubvariety (periodicSet 110 4 2) := by
  refine not_isAffineSubvariety_of_ncard_not_dvd ?_
  rw [rule110_periodicSet_two_ncard]
  decide

end ECAFixedVariety