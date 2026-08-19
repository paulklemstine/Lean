/-
# A complete characterisation of Fermat–Weber points on a line

`Geometry.FermatWeberMedian` shows that a counting median of an **odd** sample minimises the
total-distance functional `fwCost s t = Σ_{x ∈ s} |t - x|`.  The pending NET-48 experiment adds
a *fourth* seed, making the sample even, so the odd theory no longer applies.  This file
supplies the general theory, for samples of arbitrary size and parity:

    `m` minimises `fwCost s`  ⟺  `m` is **balanced**: at least half of the sample lies weakly
    below `m` and at least half lies weakly above it.

Both directions are proved, together with the convexity of the cost, from which the minimiser
set is an interval — a point for odd samples, a genuine segment for even ones.

## Main results

* `IsBalanced` — the counting condition `#{x > m} ≤ #{x ≤ m}` and `#{x < m} ≤ #{x ≥ m}`.
* `fwCost_le_of_isBalanced` — **sufficiency**, in any linearly ordered abelian group: a balanced
  point minimises the total distance.
* `IsMedian.isBalanced` — the counting median of an odd sample is balanced, so the odd theorem
  of `FermatWeberMedian` is the odd case of this one.
* `isBalanced_of_min` — **necessity**, over `ℝ`: a minimiser is balanced.  The witness is the
  nearest sample point on the heavy side, so the argument is genuinely finitary; no limiting
  argument is used.
* `fwCost_min_iff_isBalanced` — the characterisation.
* `fwCost_convex` — convexity of the cost functional, proved pointwise from the triangle
  inequality.
* `net48_224_isBalanced`, `net48_224_min` — the pending experiment: `224` is balanced, hence
  optimal, for the four-seed sample `{160, 224, 256, y}` for every value `y` of the fourth seed.
* `minimiser_set_convex` — consequently the set of Fermat–Weber points is convex: an interval.
  This is the structural reason why a fourth seed can only *widen* the optimal centre into a
  segment rather than move it.
-/
import Geometry.FermatWeberMedian

namespace Catalog.Geometry.FermatWeberCharacterisation

open Multiset Catalog.Tropical.KneeMedian Catalog.Geometry.FermatWeberMedian

variable {α : Type*} [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]

/-- `m` is *balanced* for the sample `s` when neither side of `m` strictly outweighs the
other: at least as many entries are `≤ m` as are `> m`, and at least as many are `≥ m` as are
`< m`. -/
def IsBalanced (s : Multiset α) (m : α) : Prop :=
  card (s.filter (fun x => ¬ x ≤ m)) ≤ card (s.filter (fun x => x ≤ m)) ∧
    card (s.filter (fun x => ¬ m ≤ x)) ≤ card (s.filter (fun x => m ≤ x))

omit [AddCommGroup α] [IsOrderedAddMonoid α] in
/-- The counting median of an odd sample is balanced. -/
theorem IsMedian.isBalanced {k : ℕ} {s : Multiset α} {m : α} (hcard : card s = 2 * k + 1)
    (h : IsMedian k s m) : IsBalanced s m := by
  constructor
  · have h1 := h.lower
    have h2 := card_filter_add_card_filter_not s (fun x => x ≤ m)
    omega
  · have h1 := h.upper
    have h2 := card_filter_add_card_filter_not s (fun x => m ≤ x)
    omega

/-- **Sufficiency.**  A balanced point minimises the total distance to the sample. -/
theorem fwCost_le_of_isBalanced {s : Multiset α} {m : α} (h : IsBalanced s m) (t : α) :
    fwCost s m ≤ fwCost s t := by
  classical
  rcases le_total m t with hmt | htm
  · -- move to the right: the weight `≤ m` pays, the weight `> m` refunds
    set A := card (s.filter (fun x => x ≤ m)) with hA
    set C := card (s.filter (fun x => ¬ x ≤ m)) with hC
    have hCA : C ≤ A := h.1
    have hpt : ∀ x ∈ s, |m - x| + (if x ≤ m then t - m else -(t - m)) ≤ |t - x| := by
      intro x _
      by_cases hx : x ≤ m
      · rw [if_pos hx, abs_of_nonneg (by simpa using sub_nonneg.mpr hx),
          abs_of_nonneg (by simpa using sub_nonneg.mpr (hx.trans hmt))]
        exact le_of_eq (by abel)
      · rw [if_neg hx]
        push_neg at hx
        rw [abs_of_nonpos (by simpa using sub_nonpos.mpr hx.le)]
        have hrw : -(m - x) + -(t - m) = -(t - x) := by abel
        rw [hrw]
        exact neg_le_abs _
    have hsum := Multiset.sum_map_le_sum_map
      (fun x : α => |m - x| + (if x ≤ m then t - m else -(t - m)))
      (fun x : α => |t - x|) hpt
    rw [Multiset.sum_map_add, sum_map_ite_const] at hsum
    have hmcost : (s.map (fun x : α => |m - x|)).sum = fwCost s m := rfl
    rw [hmcost] at hsum
    have hgain : (0 : α) ≤ A • (t - m) + C • (-(t - m)) := by
      obtain ⟨r, hr⟩ : ∃ r : ℕ, A = C + r := ⟨A - C, by omega⟩
      rw [hr, add_nsmul]
      have hnn : (0 : α) ≤ t - m := sub_nonneg.mpr hmt
      have hr0 : (0 : α) ≤ r • (t - m) := nsmul_nonneg hnn r
      have hCneg : C • (t - m) + C • (-(t - m)) = 0 := by
        rw [← nsmul_add]; simp
      have hrearr : C • (t - m) + r • (t - m) + C • (-(t - m))
          = (C • (t - m) + C • (-(t - m))) + r • (t - m) := by abel
      rw [hrearr, hCneg, zero_add]
      exact hr0
    have hfw : fwCost s t = (s.map (fun x : α => |t - x|)).sum := rfl
    rw [hfw]
    exact le_trans (le_add_of_nonneg_right hgain) hsum
  · set A := card (s.filter (fun x => m ≤ x)) with hA
    set C := card (s.filter (fun x => ¬ m ≤ x)) with hC
    have hCA : C ≤ A := h.2
    have hpt : ∀ x ∈ s, |m - x| + (if m ≤ x then m - t else -(m - t)) ≤ |t - x| := by
      intro x _
      by_cases hx : m ≤ x
      · rw [if_pos hx, abs_of_nonpos (by simpa using sub_nonpos.mpr hx),
          abs_of_nonpos (by simpa using sub_nonpos.mpr (htm.trans hx))]
        exact le_of_eq (by abel)
      · rw [if_neg hx]
        push_neg at hx
        rw [abs_of_nonneg (by simpa using sub_nonneg.mpr hx.le)]
        have hrw : m - x + -(m - t) = t - x := by abel
        rw [hrw]
        exact le_abs_self _
    have hsum := Multiset.sum_map_le_sum_map
      (fun x : α => |m - x| + (if m ≤ x then m - t else -(m - t)))
      (fun x : α => |t - x|) hpt
    rw [Multiset.sum_map_add, sum_map_ite_const] at hsum
    have hmcost : (s.map (fun x : α => |m - x|)).sum = fwCost s m := rfl
    rw [hmcost] at hsum
    have hgain : (0 : α) ≤ A • (m - t) + C • (-(m - t)) := by
      obtain ⟨r, hr⟩ : ∃ r : ℕ, A = C + r := ⟨A - C, by omega⟩
      rw [hr, add_nsmul]
      have hnn : (0 : α) ≤ m - t := sub_nonneg.mpr htm
      have hr0 : (0 : α) ≤ r • (m - t) := nsmul_nonneg hnn r
      have hCneg : C • (m - t) + C • (-(m - t)) = 0 := by
        rw [← nsmul_add]; simp
      have hrearr : C • (m - t) + r • (m - t) + C • (-(m - t))
          = (C • (m - t) + C • (-(m - t))) + r • (m - t) := by abel
      rw [hrearr, hCneg, zero_add]
      exact hr0
    have hfw : fwCost s t = (s.map (fun x : α => |t - x|)).sum := rfl
    rw [hfw]
    exact le_trans (le_add_of_nonneg_right hgain) hsum

/-! ## Necessity, over the reals -/

/-- Exact cost of a step to the right that jumps no sample point. -/
theorem fwCost_step_right {s : Multiset ℝ} {m t : ℝ} (hmt : m ≤ t)
    (hgap : ∀ x ∈ s, m < x → t ≤ x) :
    fwCost s t = fwCost s m
      + ((card (s.filter (fun x => x ≤ m)) : ℝ) - (card (s.filter (fun x => ¬ x ≤ m)) : ℝ))
        * (t - m) := by
  classical
  have hpt : ∀ x ∈ s, |t - x| = |m - x| + (if x ≤ m then t - m else -(t - m)) := by
    intro x hx
    by_cases hxm : x ≤ m
    · rw [if_pos hxm, abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
      ring
    · push_neg at hxm
      have htx : t ≤ x := hgap x hx hxm
      rw [if_neg (not_le.mpr hxm), abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
      ring
  have hmap : (s.map (fun x : ℝ => |t - x|)).sum
      = (s.map (fun x : ℝ => |m - x| + (if x ≤ m then t - m else -(t - m)))).sum := by
    rw [Multiset.map_congr rfl hpt]
  have : fwCost s t = (s.map (fun x : ℝ => |t - x|)).sum := rfl
  rw [this, hmap, Multiset.sum_map_add, sum_map_ite_const]
  have hmcost : (s.map (fun x : ℝ => |m - x|)).sum = fwCost s m := rfl
  rw [hmcost, nsmul_eq_mul, nsmul_eq_mul]
  ring

/-- Exact cost of a step to the left that jumps no sample point. -/
theorem fwCost_step_left {s : Multiset ℝ} {m t : ℝ} (htm : t ≤ m)
    (hgap : ∀ x ∈ s, x < m → x ≤ t) :
    fwCost s t = fwCost s m
      + ((card (s.filter (fun x => m ≤ x)) : ℝ) - (card (s.filter (fun x => ¬ m ≤ x)) : ℝ))
        * (m - t) := by
  classical
  have hpt : ∀ x ∈ s, |t - x| = |m - x| + (if m ≤ x then m - t else -(m - t)) := by
    intro x hx
    by_cases hxm : m ≤ x
    · rw [if_pos hxm, abs_of_nonpos (by linarith), abs_of_nonpos (by linarith)]
      ring
    · push_neg at hxm
      have hxt : x ≤ t := hgap x hx hxm
      rw [if_neg (not_le.mpr hxm), abs_of_nonneg (by linarith), abs_of_nonneg (by linarith)]
      ring
  have hmap : (s.map (fun x : ℝ => |t - x|)).sum
      = (s.map (fun x : ℝ => |m - x| + (if m ≤ x then m - t else -(m - t)))).sum := by
    rw [Multiset.map_congr rfl hpt]
  have : fwCost s t = (s.map (fun x : ℝ => |t - x|)).sum := rfl
  rw [this, hmap, Multiset.sum_map_add, sum_map_ite_const]
  have hmcost : (s.map (fun x : ℝ => |m - x|)).sum = fwCost s m := rfl
  rw [hmcost, nsmul_eq_mul, nsmul_eq_mul]
  ring

/-- **Necessity.**  A minimiser of the total distance is balanced.  The witness step is to the
nearest sample point on the heavier side, so the argument is finitary. -/
theorem isBalanced_of_min {s : Multiset ℝ} {m : ℝ} (hmin : ∀ t, fwCost s m ≤ fwCost s t) :
    IsBalanced s m := by
  classical
  constructor
  · by_contra hcon
    set A := card (s.filter (fun x => x ≤ m)) with hA
    set C := card (s.filter (fun x => ¬ x ≤ m)) with hC
    have hlt : A < C := not_le.mp hcon
    have hCpos : 0 < C := lt_of_le_of_lt (Nat.zero_le A) hlt
    have hne : (s.filter (fun x => ¬ x ≤ m)).toFinset.Nonempty := by
      obtain ⟨y, hy⟩ := Multiset.card_pos_iff_exists_mem.mp hCpos
      exact ⟨y, Multiset.mem_toFinset.mpr hy⟩
    set t := (s.filter (fun x => ¬ x ≤ m)).toFinset.min' hne with ht
    have htmem : t ∈ s.filter (fun x => ¬ x ≤ m) := by
      have := Finset.min'_mem _ hne
      rwa [Multiset.mem_toFinset] at this
    have htgt : m < t := by
      have := (Multiset.mem_filter.mp htmem).2
      exact not_le.mp this
    have hgap : ∀ x ∈ s, m < x → t ≤ x := by
      intro x hx hmx
      have hxmem : x ∈ (s.filter (fun x => ¬ x ≤ m)).toFinset := by
        rw [Multiset.mem_toFinset]
        exact Multiset.mem_filter.mpr ⟨hx, not_le.mpr hmx⟩
      exact Finset.min'_le _ _ hxmem
    have hstep := fwCost_step_right htgt.le hgap
    have hAC : (A : ℝ) - (C : ℝ) < 0 := by
      have : (A : ℝ) < (C : ℝ) := by exact_mod_cast hlt
      linarith
    have hpos : 0 < t - m := by linarith
    have : fwCost s t < fwCost s m := by
      rw [hstep]
      nlinarith
    exact absurd (hmin t) (not_le.mpr this)
  · by_contra hcon
    set A := card (s.filter (fun x => m ≤ x)) with hA
    set C := card (s.filter (fun x => ¬ m ≤ x)) with hC
    have hlt : A < C := not_le.mp hcon
    have hCpos : 0 < C := lt_of_le_of_lt (Nat.zero_le A) hlt
    have hne : (s.filter (fun x => ¬ m ≤ x)).toFinset.Nonempty := by
      obtain ⟨y, hy⟩ := Multiset.card_pos_iff_exists_mem.mp hCpos
      exact ⟨y, Multiset.mem_toFinset.mpr hy⟩
    set t := (s.filter (fun x => ¬ m ≤ x)).toFinset.max' hne with ht
    have htmem : t ∈ s.filter (fun x => ¬ m ≤ x) := by
      have := Finset.max'_mem _ hne
      rwa [Multiset.mem_toFinset] at this
    have htlt : t < m := by
      have := (Multiset.mem_filter.mp htmem).2
      exact not_le.mp this
    have hgap : ∀ x ∈ s, x < m → x ≤ t := by
      intro x hx hxm
      have hxmem : x ∈ (s.filter (fun x => ¬ m ≤ x)).toFinset := by
        rw [Multiset.mem_toFinset]
        exact Multiset.mem_filter.mpr ⟨hx, not_le.mpr hxm⟩
      exact Finset.le_max' _ _ hxmem
    have hstep := fwCost_step_left htlt.le hgap
    have hAC : (A : ℝ) - (C : ℝ) < 0 := by
      have : (A : ℝ) < (C : ℝ) := by exact_mod_cast hlt
      linarith
    have hpos : 0 < m - t := by linarith
    have : fwCost s t < fwCost s m := by
      rw [hstep]
      nlinarith
    exact absurd (hmin t) (not_le.mpr this)

/-- **The characterisation**: over the reals, the Fermat–Weber points of a sample are exactly
its balanced points. -/
theorem fwCost_min_iff_isBalanced {s : Multiset ℝ} {m : ℝ} :
    (∀ t, fwCost s m ≤ fwCost s t) ↔ IsBalanced s m :=
  ⟨isBalanced_of_min, fun h t => fwCost_le_of_isBalanced h t⟩

/-! ## Convexity, and the minimiser set as an interval -/

/-- The total-distance functional is convex. -/
theorem fwCost_convex (s : Multiset ℝ) (a b : ℝ) {l : ℝ} (hl0 : 0 ≤ l) (hl1 : l ≤ 1) :
    fwCost s (l * a + (1 - l) * b) ≤ l * fwCost s a + (1 - l) * fwCost s b := by
  have hpt : ∀ x ∈ s, |l * a + (1 - l) * b - x| ≤ l * |a - x| + (1 - l) * |b - x| := by
    intro x _
    have hrw : l * a + (1 - l) * b - x = l * (a - x) + (1 - l) * (b - x) := by ring
    rw [hrw]
    calc |l * (a - x) + (1 - l) * (b - x)| ≤ |l * (a - x)| + |(1 - l) * (b - x)| :=
          abs_add_le _ _
      _ = l * |a - x| + (1 - l) * |b - x| := by
          rw [abs_mul, abs_mul, abs_of_nonneg hl0, abs_of_nonneg (show (0:ℝ) ≤ 1 - l by linarith)]
  have hsum := Multiset.sum_map_le_sum_map
    (fun x : ℝ => |l * a + (1 - l) * b - x|)
    (fun x : ℝ => l * |a - x| + (1 - l) * |b - x|) hpt
  rw [Multiset.sum_map_add, Multiset.sum_map_mul_left, Multiset.sum_map_mul_left] at hsum
  exact hsum

/-- **The Fermat–Weber set is convex**: if two points both minimise the total distance, so does
every point between them.  For an even sample this is why the optimal centre is a segment. -/
theorem minimiser_set_convex {s : Multiset ℝ} {a b t : ℝ}
    (ha : ∀ u, fwCost s a ≤ fwCost s u) (hb : ∀ u, fwCost s b ≤ fwCost s u)
    (hat : a ≤ t) (htb : t ≤ b) (u : ℝ) : fwCost s t ≤ fwCost s u := by
  rcases eq_or_lt_of_le hat with rfl | halt
  · exact ha u
  · have hab : a < b := lt_of_lt_of_le halt htb
    obtain ⟨l, hl0, hl1, hcomb⟩ : ∃ l : ℝ, 0 ≤ l ∧ l ≤ 1 ∧ l * a + (1 - l) * b = t := by
      have hne' : b - a ≠ 0 := ne_of_gt (by linarith)
      refine ⟨(b - t) / (b - a), div_nonneg (by linarith) (by linarith), ?_, ?_⟩
      · rw [div_le_one (by linarith)]
        linarith
      · field_simp
        ring
    have hcvx := fwCost_convex s a b hl0 hl1
    rw [hcomb] at hcvx
    have hcost : fwCost s a = fwCost s b := le_antisymm (ha b) (hb a)
    rw [hcost] at hcvx
    have hid : l * fwCost s b + (1 - l) * fwCost s b = fwCost s b := by ring
    rw [hid] at hcvx
    exact le_trans hcvx (hb u)

/-! ## Application: the pending fourth 16× seed -/

/-- The 7/8-centre `224` is balanced for the four-seed 16× sample `{160, 224, 256, y}`, for
**every** value `y` of the pending fourth seed: if `y ≤ 224` the low side carries three of the
four entries, otherwise both sides carry two. -/
theorem net48_224_isBalanced (y : ℝ) : IsBalanced ({160, 224, 256, y} : Multiset ℝ) 224 := by
  rcases le_total y 224 with hy | hy <;>
    refine ⟨?_, ?_⟩ <;>
      simp [Multiset.insert_eq_cons, Multiset.filter_cons, Multiset.filter_singleton] <;>
      split_ifs <;> simp_all <;> linarith

/-- Structural form of the fourth-seed prediction: `224` minimises the total distance of the
four-seed sample whatever the fourth seed is.  (`Geometry.KneeFourthSeed` proves the same
statement by an explicit two-triangle-inequality computation; here it is a corollary of the
balance characterisation.) -/
theorem net48_224_min (y t : ℝ) :
    fwCost ({160, 224, 256, y} : Multiset ℝ) 224 ≤ fwCost ({160, 224, 256, y} : Multiset ℝ) t :=
  fwCost_le_of_isBalanced (net48_224_isBalanced y) t

end Catalog.Geometry.FermatWeberCharacterisation