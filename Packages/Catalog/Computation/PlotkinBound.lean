import Mathlib
import Catalog.Computation.ListHammingBallParity

/-!
# The Plotkin bound over `List Bool`

Cycle 5 of the research thread.  The sphere-packing bound of cycle 1 is vacuous in the
high-distance regime `2 * d > n` (the balls of radius `t = (d-1)/2` are then larger than the
cube).  Plotkin's bound covers exactly that regime, and its proof is a *double count* of the
total pairwise distance of a code — the third distinct proof technique in this development
(after the recursive ball count and the greedy maximality argument).

## Main results

* `hdist_eq_sum_range` — the Hamming distance as a sum over coordinate indices; this is what
  makes the coordinatewise count possible and complements the recursive `zipWith` view used
  in cycle 1.
* `pair_count_coord` — for one coordinate, the number of ordered disagreeing pairs of a code
  is `2 * k * (M - k)` where `k` is the number of codewords carrying a `1` there.
* `total_distance_lower` / `total_distance_upper` — the two sides of the double count.
* `plotkin_bound` — if `n < 2 * d` then `|C| * (2 * d - n) ≤ 2 * d`.
* `plotkin_card_le` — consequently `|C| ≤ 2 * d` whenever `n < 2 * d`, a bound independent
  of the length; and `card_le_one_of_length_lt` — a code with `n < d` has at most one word.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the total pairwise distance `S = ∑_{x,y ∈ C} d(x,y)` is squeezed
between `d · M · (M-1)` (from the minimum distance) and `n · M² / 2` (from the coordinatewise
count), and the squeeze is exactly Plotkin.

Experiment (Experimenter): both bounds formalise directly.  To stay inside `ℕ` we double
everything: `2 * S ≤ n * M ^ 2` avoids the halving, and the per-coordinate inequality
`4 * k * (M - k) ≤ M ^ 2` is `(k - f)² ≥ 0` in disguise, discharged by `nlinarith` after
writing `M = k + f`.

Analysis (Analyst): the coordinate view (`hdist_eq_sum_range`) and the recursive view
(`hdist_cons`) of the same metric are both needed in this development — packing arguments
want the recursion, counting arguments want the coordinates.  Having both indexed by the
*same* definition is what lets cycles 1 and 5 be combined.

Critique (Critic): the bound is stated with truncated subtraction `2 * d - n`, which is
harmless because the hypothesis `n < 2 * d` makes it positive; without that hypothesis the
statement would degenerate to `0 ≤ 2 * d` and say nothing, so the hypothesis is genuinely
load-bearing rather than cosmetic.
-/

namespace ListCode

open Finset

/-- The Hamming distance written as a sum over coordinate positions. -/
theorem hdist_eq_sum_range {n : ℕ} {x y : List Bool} (hx : x.length = n) (hy : y.length = n) :
    hdist x y = ∑ j ∈ Finset.range n,
      (if x.getD j false = y.getD j false then 0 else 1) := by
  induction x generalizing y n with
  | nil =>
    have hn : n = 0 := by simpa using hx.symm
    subst hn; simp
  | cons a t ih =>
    cases y with
    | nil =>
      rw [List.length_nil] at hy
      rw [List.length_cons] at hx
      omega
    | cons b u =>
      obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨t.length, by simpa using hx.symm⟩
      simp only [List.length_cons, Nat.add_right_cancel_iff] at hx hy
      rw [hdist_cons, ih hx hy, Finset.sum_range_succ']
      simp [Nat.add_comm]

/-- **Coordinatewise pair count.**  For a fixed coordinate, the number of ordered pairs of
codewords disagreeing there is `2 * k * f`, where `k` and `f` count the codewords carrying
`1` resp. `0`. -/
theorem pair_count_coord (C : Finset (List Bool)) (c : List Bool → Bool) :
    ∑ x ∈ C, ∑ y ∈ C, (if c x = c y then 0 else 1)
      = 2 * (C.filter (fun x => c x = true)).card * (C.filter (fun x => c x = false)).card := by
  classical
  set T := C.filter (fun x => c x = true) with hTdef
  set F := C.filter (fun x => c x = false) with hFdef
  have hsplit : ∀ (g : List Bool → ℕ), ∑ x ∈ C, g x = ∑ x ∈ T, g x + ∑ x ∈ F, g x := by
    intro g
    rw [hTdef, hFdef, ← Finset.sum_filter_add_sum_filter_not C (fun x => c x = true)]
    congr 1
    apply Finset.sum_congr _ (fun _ _ => rfl)
    apply Finset.filter_congr
    intro x _
    cases hcx : c x <;> simp
  have hTm : ∀ x ∈ T, c x = true := fun x hx => (Finset.mem_filter.mp hx).2
  have hFm : ∀ x ∈ F, c x = false := fun x hx => (Finset.mem_filter.mp hx).2
  have hinner : ∀ x ∈ C, (∑ y ∈ C, (if c x = c y then 0 else 1))
      = if c x = true then F.card else T.card := by
    intro x _
    rw [hsplit (fun y => if c x = c y then 0 else 1)]
    by_cases hcx : c x = true
    · rw [if_pos hcx]
      have e1 : ∑ y ∈ T, (if c x = c y then 0 else 1) = 0 :=
        Finset.sum_eq_zero (fun y hy => by rw [hcx, hTm y hy]; simp)
      have e2 : ∑ y ∈ F, (if c x = c y then 0 else 1) = ∑ _y ∈ F, 1 :=
        Finset.sum_congr rfl (fun y hy => by rw [hcx, hFm y hy]; simp)
      rw [e1, e2]; simp
    · have hcx' : c x = false := by cases h : c x <;> simp_all
      rw [if_neg hcx]
      have e1 : ∑ y ∈ T, (if c x = c y then 0 else 1) = ∑ _y ∈ T, 1 :=
        Finset.sum_congr rfl (fun y hy => by rw [hcx', hTm y hy]; simp)
      have e2 : ∑ y ∈ F, (if c x = c y then 0 else 1) = 0 :=
        Finset.sum_eq_zero (fun y hy => by rw [hcx', hFm y hy]; simp)
      rw [e1, e2]; simp
  rw [Finset.sum_congr rfl hinner, hsplit (fun x => if c x = true then F.card else T.card)]
  have g1 : ∑ x ∈ T, (if c x = true then F.card else T.card) = ∑ _x ∈ T, F.card :=
    Finset.sum_congr rfl (fun x hx => by rw [if_pos (hTm x hx)])
  have g2 : ∑ x ∈ F, (if c x = true then F.card else T.card) = ∑ _x ∈ F, T.card :=
    Finset.sum_congr rfl (fun x hx => by rw [if_neg (by rw [hFm x hx]; simp)])
  rw [g1, g2, Finset.sum_const, Finset.sum_const, smul_eq_mul, smul_eq_mul]
  ring

/-- The two parts of a coordinate split exhaust the code. -/
lemma card_filter_add_card_filter (C : Finset (List Bool)) (c : List Bool → Bool) :
    (C.filter (fun x => c x = true)).card + (C.filter (fun x => c x = false)).card = C.card := by
  classical
  have heq : C.filter (fun x => c x = false) = C.filter (fun x => ¬ (c x = true)) := by
    apply Finset.filter_congr
    intro x _
    cases hcx : c x <;> simp
  rw [heq]
  exact Finset.card_filter_add_card_filter_not (fun x => c x = true)

/-- **Upper half of the double count.**  Twice the total pairwise distance is at most
`n · |C|²`. -/
theorem total_distance_upper {n : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n) :
    2 * ∑ x ∈ C, ∑ y ∈ C, hdist x y ≤ n * C.card ^ 2 := by
  classical
  have hrew : ∀ x ∈ C, ∀ y ∈ C, hdist x y
      = ∑ j ∈ Finset.range n, (if x.getD j false = y.getD j false then 0 else 1) := by
    intro x hx y hy
    exact hdist_eq_sum_range (mem_words.mp (hC hx)) (mem_words.mp (hC hy))
  have hstep : ∑ x ∈ C, ∑ y ∈ C, hdist x y
      = ∑ j ∈ Finset.range n, ∑ x ∈ C, ∑ y ∈ C,
          (if x.getD j false = y.getD j false then 0 else 1) := by
    have h1 : ∑ x ∈ C, ∑ y ∈ C, hdist x y
        = ∑ x ∈ C, ∑ y ∈ C, ∑ j ∈ Finset.range n,
            (if x.getD j false = y.getD j false then 0 else 1) :=
      Finset.sum_congr rfl (fun x hx => Finset.sum_congr rfl (fun y hy => hrew x hx y hy))
    have h2 : ∀ x : List Bool, ∑ y ∈ C, ∑ j ∈ Finset.range n,
        (if x.getD j false = y.getD j false then 0 else 1)
        = ∑ j ∈ Finset.range n, ∑ y ∈ C,
            (if x.getD j false = y.getD j false then 0 else 1) :=
      fun x => Finset.sum_comm
    rw [h1, Finset.sum_congr rfl (fun x _ => h2 x), Finset.sum_comm]
  rw [hstep, Finset.mul_sum]
  have hterm : ∀ j ∈ Finset.range n,
      2 * (∑ x ∈ C, ∑ y ∈ C, (if x.getD j false = y.getD j false then 0 else 1))
        ≤ C.card ^ 2 := by
    intro j _
    rw [pair_count_coord C (fun x => x.getD j false)]
    have hsum := card_filter_add_card_filter C (fun x => x.getD j false)
    set k := (C.filter (fun x => x.getD j false = true)).card
    set f := (C.filter (fun x => x.getD j false = false)).card
    have key : 4 * k * f ≤ (k + f) ^ 2 := by
      have hz : (0 : ℤ) ≤ ((k : ℤ) - (f : ℤ)) ^ 2 := sq_nonneg _
      have h2 : (4 * (k : ℤ) * (f : ℤ)) ≤ ((k : ℤ) + (f : ℤ)) ^ 2 := by nlinarith
      exact_mod_cast h2
    calc 2 * (2 * k * f) = 4 * k * f := by ring
      _ ≤ (k + f) ^ 2 := key
      _ = C.card ^ 2 := by rw [hsum]
  calc ∑ j ∈ Finset.range n,
        2 * (∑ x ∈ C, ∑ y ∈ C, (if x.getD j false = y.getD j false then 0 else 1))
      ≤ ∑ _j ∈ Finset.range n, C.card ^ 2 := Finset.sum_le_sum hterm
    _ = n * C.card ^ 2 := by simp [Finset.sum_const]

/-- **Lower half of the double count.**  The total pairwise distance is at least
`d · |C| · (|C| - 1)`. -/
theorem total_distance_lower {d : ℕ} {C : Finset (List Bool)} (hmin : MinDist C d) :
    d * C.card * (C.card - 1) ≤ ∑ x ∈ C, ∑ y ∈ C, hdist x y := by
  classical
  have hx : ∀ x ∈ C, d * (C.card - 1) ≤ ∑ y ∈ C, hdist x y := by
    intro x hx
    have hsub : ∑ y ∈ C.erase x, hdist x y ≤ ∑ y ∈ C, hdist x y :=
      Finset.sum_le_sum_of_subset (Finset.erase_subset _ _)
    have hlow : ∑ _y ∈ C.erase x, d ≤ ∑ y ∈ C.erase x, hdist x y := by
      refine Finset.sum_le_sum (fun y hy => ?_)
      have hyC : y ∈ C := Finset.mem_of_mem_erase hy
      have hne : x ≠ y := fun h => (Finset.ne_of_mem_erase hy) h.symm
      exact hmin x hx y hyC hne
    have hcard : (C.erase x).card = C.card - 1 := Finset.card_erase_of_mem hx
    rw [Finset.sum_const, hcard, smul_eq_mul, mul_comm] at hlow
    omega
  calc d * C.card * (C.card - 1) = ∑ _x ∈ C, d * (C.card - 1) := by
        rw [Finset.sum_const, smul_eq_mul]; ring
    _ ≤ ∑ x ∈ C, ∑ y ∈ C, hdist x y := Finset.sum_le_sum hx

/-- **Plotkin bound.**  In the high-distance regime `n < 2 * d`, a binary code of length `n`
with minimum distance `d` satisfies `|C| · (2 * d - n) ≤ 2 * d`. -/
theorem plotkin_bound {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C d) (hnd : n < 2 * d) :
    C.card * (2 * d - n) ≤ 2 * d := by
  classical
  rcases Nat.eq_zero_or_pos C.card with h0 | hpos
  · simp [h0]
  obtain ⟨m, hm⟩ : ∃ m, C.card = m + 1 := ⟨C.card - 1, by omega⟩
  have hup := total_distance_upper hC
  have hlow := total_distance_lower (d := d) hmin
  -- combine: 2 * d * M * (M - 1) ≤ n * M ^ 2
  have hcomb : 2 * (d * C.card * (C.card - 1)) ≤ n * C.card ^ 2 := by omega
  rw [hm] at hcomb
  simp only [Nat.add_sub_cancel] at hcomb
  -- cancel one factor of M = m + 1
  have hcancel : 2 * d * m ≤ n * (m + 1) := by
    have h' : (2 * d * m) * (m + 1) ≤ (n * (m + 1)) * (m + 1) := by ring_nf; ring_nf at hcomb; omega
    exact Nat.le_of_mul_le_mul_right h' (by omega)
  -- finish
  set a := 2 * d - n with ha
  have hd2 : 2 * d = n + a := by omega
  have ham : a * m ≤ n := by nlinarith [hcancel, hd2]
  rw [hm]
  calc (m + 1) * a = a * m + a := by ring
    _ ≤ n + a := by omega
    _ = 2 * d := hd2.symm

/-- A convenient consequence: in the high-distance regime the code size is bounded by an
absolute constant, independent of the length. -/
theorem plotkin_card_le {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C d) (hnd : n < 2 * d) : C.card ≤ 2 * d := by
  have h := plotkin_bound hC hmin hnd
  have hpos : 1 ≤ 2 * d - n := by omega
  calc C.card = C.card * 1 := (mul_one _).symm
    _ ≤ C.card * (2 * d - n) := Nat.mul_le_mul_left _ hpos
    _ ≤ 2 * d := h

/-- If the minimum distance exceeds the length, the code has at most one word: a genuinely
degenerate corner of the Plotkin regime. -/
theorem card_le_one_of_length_lt {n d : ℕ} {C : Finset (List Bool)} (hC : C ⊆ words n)
    (hmin : MinDist C d) (hnd : n < d) : C.card ≤ 1 := by
  by_contra hlt
  push_neg at hlt
  obtain ⟨x, hx, y, hy, hxy⟩ := Finset.one_lt_card.mp hlt
  have hxl : x.length = n := mem_words.mp (hC hx)
  have hle : hdist x y ≤ n := by rw [← hxl]; exact hdist_le_length x y
  have := hmin x hx y hy hxy
  omega

end ListCode