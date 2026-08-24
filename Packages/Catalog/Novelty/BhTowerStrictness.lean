import Novelty.BhSetsDifferences

/-!
# The `B_h` tower is strict at every level: the three-point family `{0, 1, h+1}`

`Novelty/BhSetsDifferences.lean` proves that `h`-fold difference rigidity is exactly the
`B_{2h}` condition, and that `B_h` sets are `B_k` for `k ≤ h`.  Both statements would be
vacuous if the tower collapsed.  This file shows it does not: for **every** `h ≥ 1` the
three-element set

  `T h = {0, 1, h + 1} ⊆ ℕ`

is a `B_h` set and is **not** a `B_{h+1}` set — the obstruction being the single
coincidence `(h+1)·1 = 1·(h+1)`, i.e. `h+1` copies of `1` and one copy of `h+1` together
with `h` zeros.  Three points therefore already separate every two consecutive floors of
the tower, and consequently separate `Diff_h` from `Diff_{h+1}` as well.

## Main results

* `triple_sum`, `triple_card`, `triple_ext` — the coordinate calculus for multisets drawn
  from `{0, 1, N}` with `N ≥ 2`: a multiset is determined by its three multiplicities, its
  cardinality is their sum, and its sum is `c₁ + N·c_N`.
* `tripleSet_isBh` — `T h` is a `B_h` set: the multiplicity `c₁` of `1` is at most `h < h+1`,
  so the identity `c₁ + (h+1)·c_{h+1} = c₁' + (h+1)·c_{h+1}'` forces the multiplicities to
  agree, a genuine (if small) `p`-adic style digit argument.
* `tripleSet_not_isBh_succ` — `T h` is not `B_{h+1}`, witnessed explicitly.
* `bh_tower_strict` — hence for every `h ≥ 1` there is a set that is `B_h` but not
  `B_{h+1}`; the antitone chain of `Novelty/BhSetsDifferences.lean` is strictly decreasing.
* `diff_tower_strict` — the same conclusion transported to the difference layers: for every
  `h ≥ 1` there is a set with `h`-fold difference rigidity but not `(h+1)`-fold, i.e.
  avoiding repeated `h`-fold differences is strictly weaker than avoiding repeated
  `(h+1)`-fold differences.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (S1) The `B_h` tower is strict, and strictness should already be
  visible on sets of *bounded size* — one should not need larger and larger sets to
  separate consecutive floors.  (S2) The separating example should be a "digit" example:
  one large element playing the role of a base.
Experiment (Experimenter): direct search over three-element sets found `{0, 1, h+1}`, and
  the two halves were proved.  The failure at level `h+1` is the single relation
  `1 + 1 + ⋯ + 1 = (h+1)`, so the example is as tight as possible: removing any point makes
  the set `B_k` for all `k` (`{0,1}` and `{0,h+1}` are `B_k` for every `k`).
  The greedy Sidon set `{0,1,3}` of the companion file is the case `h = 2` of this family,
  which is why it is Sidon but not `B₃` — an observation first made numerically.
Analysis (Analyst): the mechanism is base-`(h+1)` digit rigidity, exactly as in the
  Erdős–Turán construction of the catalog, but truncated to one digit.  This suggests the
  general principle that `B_h`-ness of digit constructions is controlled by carrying, and
  carrying begins precisely at multiplicity `h+1`.
Critique (Critic): the theorems are guarded by `1 ≤ h`; for `h = 0` the statement is
  meaningless (`B₀` holds for everything, and `B₁` also holds for everything, so no set
  separates the two).  `tripleSet_not_isBh_succ` is a negative statement proved by an
  explicit witness pair, so it cannot be vacuous; `tripleSet_isBh` is not vacuous because
  `T h` has three distinct elements (`h + 1 ≥ 2`).
Synthesis (PI): three points suffice to separate every two consecutive floors of the tower,
  so all the hierarchy statements of the companion files have content.
-/

namespace BhTower

open Finset BhDifference

/-! ## 1. Coordinates for multisets over `{0, 1, N}` -/

variable {N : ℕ}

/-- The sum of a multiset drawn from `{0, 1, N}` in terms of its multiplicities. -/
theorem triple_sum (hN : 2 ≤ N) : ∀ s : Multiset ℕ, (∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = N) →
    s.sum = s.count 1 + N * s.count N := by
  intro s
  induction s using Multiset.induction_on with
  | empty => intro _; simp
  | cons a s ih =>
      intro hs
      have ha := hs a (Multiset.mem_cons_self a s)
      have hs' : ∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = N := fun x hx => hs x (Multiset.mem_cons_of_mem hx)
      have hsum := ih hs'
      rcases ha with rfl | rfl | rfl
      · rw [Multiset.sum_cons, Multiset.count_cons_of_ne (by omega),
          Multiset.count_cons_of_ne (by omega), hsum]
        omega
      · rw [Multiset.sum_cons, Multiset.count_cons_self,
          Multiset.count_cons_of_ne (by omega), hsum]
        omega
      · rw [Multiset.sum_cons, Multiset.count_cons_of_ne (by omega),
          Multiset.count_cons_self, hsum]
        rw [Nat.mul_add]
        omega

/-- The cardinality of a multiset drawn from `{0, 1, N}` in terms of its multiplicities. -/
theorem triple_card (hN : 2 ≤ N) : ∀ s : Multiset ℕ, (∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = N) →
    Multiset.card s = s.count 0 + s.count 1 + s.count N := by
  intro s
  induction s using Multiset.induction_on with
  | empty => intro _; simp
  | cons a s ih =>
      intro hs
      have ha := hs a (Multiset.mem_cons_self a s)
      have hs' : ∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = N := fun x hx => hs x (Multiset.mem_cons_of_mem hx)
      have hcard := ih hs'
      rcases ha with rfl | rfl | rfl
      · rw [Multiset.card_cons, Multiset.count_cons_self, Multiset.count_cons_of_ne (by omega),
          Multiset.count_cons_of_ne (by omega), hcard]
        omega
      · rw [Multiset.card_cons, Multiset.count_cons_of_ne (by omega), Multiset.count_cons_self,
          Multiset.count_cons_of_ne (by omega), hcard]
        omega
      · rw [Multiset.card_cons, Multiset.count_cons_of_ne (by omega),
          Multiset.count_cons_of_ne (by omega), Multiset.count_cons_self, hcard]
        omega

/-- Multisets over `{0, 1, N}` are determined by their three multiplicities. -/
theorem triple_ext {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = N) (ht : ∀ x ∈ t, x = 0 ∨ x = 1 ∨ x = N)
    (h0 : s.count 0 = t.count 0) (h1 : s.count 1 = t.count 1)
    (hn : s.count N = t.count N) : s = t := by
  refine Multiset.ext.mpr fun x => ?_
  by_cases hx0 : x = 0
  · rw [hx0]; exact h0
  by_cases hx1 : x = 1
  · rw [hx1]; exact h1
  by_cases hxN : x = N
  · rw [hxN]; exact hn
  · have hxs : x ∉ s := fun hmem => by rcases hs x hmem with h | h | h <;> simp_all
    have hxt : x ∉ t := fun hmem => by rcases ht x hmem with h | h | h <;> simp_all
    rw [Multiset.count_eq_zero_of_notMem hxs, Multiset.count_eq_zero_of_notMem hxt]

/-! ## 2. The separating family -/

/-- The three-point set `{0, 1, h+1}`. -/
def tripleSet (h : ℕ) : Finset ℕ := {0, 1, h + 1}

theorem mem_tripleSet {h x : ℕ} (hx : x ∈ tripleSet h) : x = 0 ∨ x = 1 ∨ x = h + 1 := by
  simpa [tripleSet] using hx

theorem card_tripleSet {h : ℕ} (hh : 1 ≤ h) : #(tripleSet h) = 3 := by
  have hpair : #({1, h + 1} : Finset ℕ) = 2 := by
    rw [Finset.card_insert_of_notMem (by simp; omega), Finset.card_singleton]
  rw [tripleSet, Finset.card_insert_of_notMem (by simp), hpair]

/-- **`{0, 1, h+1}` is a `B_h` set.**  The multiplicity of `1` never reaches the base
`h + 1`, so there is no carrying and the multiplicities are pinned down. -/
theorem tripleSet_isBh (h : ℕ) (hh : 1 ≤ h) : IsBh h (tripleSet h) := by
  intro s t hs ht hcs hct hsum
  have hN : 2 ≤ h + 1 := by omega
  have hs' : ∀ x ∈ s, x = 0 ∨ x = 1 ∨ x = h + 1 := fun x hx => mem_tripleSet (hs x hx)
  have ht' : ∀ x ∈ t, x = 0 ∨ x = 1 ∨ x = h + 1 := fun x hx => mem_tripleSet (ht x hx)
  have hsums := triple_sum hN s hs'
  have hsumt := triple_sum hN t ht'
  have hcards := triple_card hN s hs'
  have hcardt := triple_card hN t ht'
  set a := s.count 1 with ha
  set b := s.count (h + 1) with hb
  set a' := t.count 1 with ha'
  set b' := t.count (h + 1) with hb'
  have hkey : a + (h + 1) * b = a' + (h + 1) * b' := by omega
  have hale : a ≤ h := by omega
  have hale' : a' ≤ h := by omega
  have hbb : b = b' := by
    rcases le_total b b' with hle | hle
    · have hsplit : (h + 1) * b' = (h + 1) * b + (h + 1) * (b' - b) := by
        rw [← Nat.mul_add]; congr 1; omega
      rw [hsplit] at hkey
      by_contra hne
      have hpos : 1 ≤ b' - b := by omega
      have : h + 1 ≤ (h + 1) * (b' - b) := Nat.le_mul_of_pos_right _ (by omega)
      omega
    · have hsplit : (h + 1) * b = (h + 1) * b' + (h + 1) * (b - b') := by
        rw [← Nat.mul_add]; congr 1; omega
      rw [hsplit] at hkey
      by_contra hne
      have hpos : 1 ≤ b - b' := by omega
      have : h + 1 ≤ (h + 1) * (b - b') := Nat.le_mul_of_pos_right _ (by omega)
      omega
  have haa : a = a' := by rw [hbb] at hkey; omega
  refine triple_ext hs' ht' ?_ haa hbb
  omega

/-- **`{0, 1, h+1}` is not a `B_{h+1}` set**: `h+1` copies of `1` and one copy of `h+1`
(padded with `h` zeros) have the same sum. -/
theorem tripleSet_not_isBh_succ (h : ℕ) (hh : 1 ≤ h) : ¬ IsBh (h + 1) (tripleSet h) := by
  intro hB
  set s : Multiset ℕ := Multiset.replicate (h + 1) 1 with hsdef
  set t : Multiset ℕ := (h + 1) ::ₘ Multiset.replicate h 0 with htdef
  have hs : ∀ x ∈ s, x ∈ tripleSet h := by
    intro x hx
    rw [Multiset.eq_of_mem_replicate hx]
    simp [tripleSet]
  have ht : ∀ x ∈ t, x ∈ tripleSet h := by
    intro x hx
    rcases Multiset.mem_cons.mp hx with hx | hx
    · rw [hx]; simp [tripleSet]
    · rw [Multiset.eq_of_mem_replicate hx]; simp [tripleSet]
  have hcs : Multiset.card s = h + 1 := by simp [hsdef]
  have hct : Multiset.card t = h + 1 := by simp [htdef]
  have hsum : s.sum = t.sum := by
    simp only [hsdef, htdef, Multiset.sum_replicate, Multiset.sum_cons, smul_eq_mul]
    simp
  have := hB s t hs ht hcs hct hsum
  -- but the multiplicity of `1` differs
  have hc1s : s.count 1 = h + 1 := by simp [hsdef]
  have hc1t : t.count 1 = 0 := by
    rw [htdef, Multiset.count_cons_of_ne (by omega), Multiset.count_replicate]
    simp
  rw [this] at hc1s
  omega

/-- **The `B_h` tower is strict**: for every `h ≥ 1` a set exists that is `B_h` but not
`B_{h+1}`. -/
theorem bh_tower_strict (h : ℕ) (hh : 1 ≤ h) :
    ∃ A : Finset ℕ, IsBh h A ∧ ¬ IsBh (h + 1) A :=
  ⟨tripleSet h, tripleSet_isBh h hh, tripleSet_not_isBh_succ h hh⟩

/-- **The difference tower is strict**: for every `h ≥ 1` a set exists with `h`-fold
difference rigidity but without `(h+1)`-fold difference rigidity.  (Via
`isDiffBh_iff_isBh_two_mul`, this is the statement that `B_{2h} ⊋ B_{2h+2}`.) -/
theorem diff_tower_strict (h : ℕ) (hh : 1 ≤ h) :
    ∃ A : Finset ℕ, IsDiffBh h A ∧ ¬ IsDiffBh (h + 1) A := by
  refine ⟨tripleSet (2 * h), ?_, ?_⟩
  · exact isDiffBh_iff_isBh_two_mul.mpr (tripleSet_isBh (2 * h) (by omega))
  · intro hcon
    have h1 : IsBh (2 * h + 2) (tripleSet (2 * h)) := by
      have := isDiffBh_iff_isBh_two_mul.mp hcon
      have he : 2 * (h + 1) = 2 * h + 2 := by ring
      rwa [he] at this
    exact tripleSet_not_isBh_succ (2 * h) (by omega)
      (h1.antitone (by omega) (by omega))

end BhTower