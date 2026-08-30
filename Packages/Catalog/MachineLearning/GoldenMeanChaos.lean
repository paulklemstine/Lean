import Mathlib
import Shared.GraphTheory.FractalTruthMetric
import MachineLearning.CantorCompactness
import MachineLearning.SubshiftLanguage

/-!
# Devaney chaos for the golden-mean subshift

This file is the fifth cycle of the research thread begun in
`Shared.GraphTheory.FractalTruthMetric` and continued in
`MachineLearning.CantorCompactness`.  There the golden-mean subshift `GoldenMean ⊆ Cantor`
(binary streams with no two consecutive `true`s) was shown to be a nonempty compact perfect
shift-invariant subset of the first-disagreement ultrametric space `(Cantor, cantorDist)`.

Here we upgrade the *static* topological picture to a *dynamical* one and prove that the shift
restricted to the golden-mean subshift is **chaotic in the sense of Devaney**:

* periodic points are dense,
* the system is topologically transitive,
* it has sensitive dependence on initial conditions, with the largest possible sensitivity
  constant `1` (the diameter of the space).

The combinatorial engine is a single closure property of the golden-mean language: since the
only forbidden word is `11`, *any* two admissible words can be concatenated with a single
buffer letter `false` in between.  This "gluing with one spacer" is a specification property,
and it is what makes every one of the three Devaney ingredients available.

## Main results

* `cyc_mem_goldenMean`, `cyc_periodic` — the periodic point obtained by repeating
  `w ++ [false]` lies in the subshift and has period `w.length + 1`.
* `goldenMean_periodicPoints_dense` — periodic points of the shift are dense in the subshift.
* `goldenMean_transitive` — for any two subshift points and any precision there is a single
  subshift point whose orbit shadows the first and then the second.
* `goldenMean_sensitive` — sensitive dependence with sensitivity constant `1`.
* `goldenMean_devaney_chaos` — the three properties bundled together.
-/

namespace FractalTruthCompactness

open FractalTruthMetric Metric

/-! ## Iterates of the shift -/

/-- The `m`-th iterate of the shift just reads the stream `m` places later. -/
theorem shift_iterate_apply : ∀ (m : ℕ) (x : Cantor) (k : ℕ), shift^[m] x k = x (k + m)
  | 0, x, k => by simp
  | (m + 1), x, k => by
      rw [Function.iterate_succ_apply, shift_iterate_apply m (shift x) k]
      exact congrArg x (by omega)

/-- The subshift is invariant under all iterates of the shift. -/
theorem mapsTo_shift_iterate_goldenMean (m : ℕ) :
    Set.MapsTo (shift^[m]) GoldenMean GoldenMean := by
  induction m with
  | zero => simpa using Set.mapsTo_id _
  | succ m ih =>
      rw [Function.iterate_succ]
      exact ih.comp mapsTo_shift_goldenMean

/-! ## Coordinatewise reading of admissibility -/

/-- Reading an admissible word coordinatewise: no two adjacent positions both carry `true`. -/
theorem admissible_getD : ∀ {l : List Bool}, Admissible l → ∀ i, i + 1 < l.length →
    ¬(l.getD i false = true ∧ l.getD (i + 1) false = true)
  | [], _, i, hi => by simp at hi
  | [_], _, i, hi => by simp at hi
  | a :: b :: t, h, 0, _ => by
      have h' := List.isChain_cons_cons.mp h
      simpa using h'.1
  | a :: b :: t, h, (i + 1), hi => by
      have h' := List.isChain_cons_cons.mp h
      have hi' : i + 1 < (b :: t).length := by simpa using hi
      simpa using admissible_getD h'.2 i hi'

/-- Left half of a concatenation, read coordinatewise. -/
theorem getD_append_left {l r : List Bool} {k : ℕ} (h : k < l.length) :
    (l ++ r).getD k false = l.getD k false := by
  simp [List.getD_eq_getElem?_getD, List.getElem?_append_left h]

/-- Right half of a concatenation, read coordinatewise. -/
theorem getD_append_right (l r : List Bool) (k : ℕ) :
    (l ++ r).getD (l.length + k) false = r.getD k false := by
  simp [List.getD_eq_getElem?_getD, List.getElem?_append_right]

/-! ## Gluing admissible words with one spacer -/

/-- Appending a `false` keeps a word admissible. -/
theorem admissible_append_false : ∀ {l : List Bool}, Admissible l → Admissible (l ++ [false])
  | [], _ => by simpa using admissible_singleton false
  | [a], _ => by
      simp only [List.cons_append, List.nil_append]
      exact List.isChain_cons_cons.mpr ⟨by simp, admissible_singleton false⟩
  | a :: b :: t, h => by
      have h' := List.isChain_cons_cons.mp h
      simp only [List.cons_append]
      exact List.isChain_cons_cons.mpr ⟨h'.1, by
        simpa only [List.cons_append] using admissible_append_false h'.2⟩

/-- **Gluing with one spacer.**  Because `11` is the only forbidden word, any two admissible
words become a single admissible word once a buffer `false` is inserted between them.  This is
the specification property of the golden-mean subshift. -/
theorem admissible_glue : ∀ {l m : List Bool}, Admissible l → Admissible m →
    Admissible (l ++ false :: m)
  | [], _, _, hm => by simpa using admissible_false_cons hm
  | [a], _, _, hm => by
      simp only [List.cons_append, List.nil_append]
      exact List.isChain_cons_cons.mpr ⟨by simp, admissible_false_cons hm⟩
  | a :: b :: t, m, h, hm => by
      have h' := List.isChain_cons_cons.mp h
      simp only [List.cons_append]
      exact List.isChain_cons_cons.mpr ⟨h'.1, by
        simpa only [List.cons_append] using admissible_glue h'.2 hm⟩

/-! ## Periodic points -/

/-- The periodic stream obtained by repeating the word `w ++ [false]` forever.  The extra
`false` is the buffer that guarantees admissibility across the seam. -/
def cyc (w : List Bool) : Cantor := fun n => (w ++ [false]).getD (n % (w.length + 1)) false

theorem cyc_apply (w : List Bool) (n : ℕ) :
    cyc w n = (w ++ [false]).getD (n % (w.length + 1)) false := rfl

/-- The period: `cyc w` is fixed by the `(w.length + 1)`-st iterate of the shift. -/
theorem cyc_periodic (w : List Bool) : shift^[w.length + 1] (cyc w) = cyc w := by
  funext k
  rw [shift_iterate_apply, cyc_apply, cyc_apply, Nat.add_mod_right]

/-- The period is positive, so `cyc w` really is a periodic point. -/
theorem cyc_period_pos (w : List Bool) : 0 < w.length + 1 := Nat.succ_pos _

/-- A repeated admissible word (with buffer) stays in the golden-mean subshift. -/
theorem cyc_mem_goldenMean {w : List Bool} (hw : Admissible w) : cyc w ∈ GoldenMean := by
  set L := w.length + 1 with hL
  have hLpos : 0 < L := Nat.succ_pos _
  have hlen : (w ++ [false]).length = L := by simp [hL]
  have hadm : Admissible (w ++ [false]) := admissible_append_false hw
  intro k hk
  obtain ⟨h1, h2⟩ := hk
  have hmod : k % L < L := Nat.mod_lt _ hLpos
  rcases Nat.lt_or_ge (k % L + 1) L with hlt | hge
  · -- inside the block: adjacency is adjacency in the word
    have hL2 : 2 ≤ L := by omega
    have hone : 1 % L = 1 := Nat.mod_eq_of_lt (by omega)
    have hsucc : (k + 1) % L = k % L + 1 := by
      rw [Nat.add_mod, hone, Nat.mod_eq_of_lt hlt]
    rw [cyc_apply, hsucc] at h2
    rw [cyc_apply] at h1
    exact admissible_getD hadm (k % L) (by omega) ⟨h1, h2⟩
  · -- at the seam: the letter is the buffer `false`
    have hval : k % L = w.length := by omega
    rw [cyc_apply, hval] at h1
    rw [getD_append_singleton rfl] at h1
    exact Bool.false_ne_true h1

/-- On its first `w.length` letters, the periodic point `cyc w` reads exactly `w`. -/
theorem agreeTo_cyc_extend (w : List Bool) : AgreeTo w.length (cyc w) (extend w) := by
  intro k hk
  have hk' : k < w.length + 1 := by omega
  rw [cyc_apply, Nat.mod_eq_of_lt hk', extend, getD_append_left hk]

/-- Hence the length-`w.length` prefix of `cyc w` is `w` itself. -/
theorem prefixOf_cyc (w : List Bool) : prefixOf w.length (cyc w) = w := by
  rw [(prefixOf_eq_iff_agreeTo _ _ _).mpr (agreeTo_cyc_extend w)]
  exact prefixOf_extend w

/-- **Periodic points are dense in the golden-mean subshift.**  Every subshift point is
approximated to any precision by a genuinely periodic subshift point. -/
theorem goldenMean_periodicPoints_dense {x : Cantor} (hx : x ∈ GoldenMean) {ε : ℝ}
    (hε : 0 < ε) :
    ∃ y ∈ GoldenMean, (∃ p, 0 < p ∧ shift^[p] y = y) ∧ dist x y < ε := by
  obtain ⟨n, hn⟩ := exists_two_zpow_lt hε
  set w := prefixOf n x with hw
  have hwlen : w.length = n := length_prefixOf n x
  have hwadm : Admissible w := ((mem_goldenWords n w).mp (prefixOf_mem_goldenWords n hx)).2
  refine ⟨cyc w, cyc_mem_goldenMean hwadm, ⟨w.length + 1, cyc_period_pos w, cyc_periodic w⟩, ?_⟩
  refine lt_of_le_of_lt ((dist_le_iff_prefixOf_eq n x (cyc w)).mpr ?_) hn
  rw [← hw, ← hwlen, prefixOf_cyc]

/-! ## Topological transitivity -/

/-- Shifting past the left factor of a padded concatenation returns the right factor. -/
theorem shift_iterate_extend_glue (v w : List Bool) :
    shift^[v.length + 1] (extend (v ++ false :: w)) = extend w := by
  funext k
  rw [shift_iterate_apply]
  show (v ++ false :: w).getD (k + (v.length + 1)) false = w.getD k false
  have hk : k + (v.length + 1) = v.length + (k + 1) := by omega
  rw [hk, getD_append_right]
  rfl

/-- The prefix of a padded word only sees the left factor. -/
theorem prefixOf_extend_append (v r : List Bool) :
    prefixOf v.length (extend (v ++ r)) = v := by
  have : AgreeTo v.length (extend (v ++ r)) (extend v) := by
    intro k hk
    exact getD_append_left hk
  rw [(prefixOf_eq_iff_agreeTo _ _ _).mpr this]
  exact prefixOf_extend v

/-- **Topological transitivity of the golden-mean shift.**  Given any two subshift points and
any precision `2⁻ⁿ`, there is a single subshift point `z` whose orbit first shadows `x` and
then, after `n + 1` steps, shadows `y`.  Equivalently, any two nonempty relatively open subsets
of the subshift are linked by some iterate of the shift. -/
theorem goldenMean_transitive {x y : Cantor} (hx : x ∈ GoldenMean) (hy : y ∈ GoldenMean)
    (n : ℕ) :
    ∃ z ∈ GoldenMean, dist x z ≤ (2 : ℝ) ^ (-(n : ℤ)) ∧
      dist y (shift^[n + 1] z) ≤ (2 : ℝ) ^ (-(n : ℤ)) := by
  set v := prefixOf n x with hv
  set w := prefixOf n y with hwdef
  have hvlen : v.length = n := length_prefixOf n x
  have hwlen : w.length = n := length_prefixOf n y
  have hvadm : Admissible v := ((mem_goldenWords n v).mp (prefixOf_mem_goldenWords n hx)).2
  have hwadm : Admissible w := ((mem_goldenWords n w).mp (prefixOf_mem_goldenWords n hy)).2
  refine ⟨extend (v ++ false :: w), extend_mem_goldenMean _ (admissible_glue hvadm hwadm), ?_, ?_⟩
  · rw [dist_le_iff_prefixOf_eq, ← hv, ← hvlen, prefixOf_extend_append]
  · have hshift : shift^[n + 1] (extend (v ++ false :: w)) = extend w := by
      rw [← hvlen]; exact shift_iterate_extend_glue v w
    rw [dist_le_iff_prefixOf_eq, hshift, ← hwdef, ← hwlen, prefixOf_extend]

/-! ## Sensitive dependence on initial conditions -/

/-- The distance between two streams that already differ in coordinate `0` is exactly `1`. -/
theorem dist_eq_one_of_ne_zero {x y : Cantor} (h : x 0 ≠ y 0) : dist x y = 1 := by
  have hxy : x ≠ y := fun he => h (by rw [he])
  have hfd : firstDiff x y = 0 := by
    by_contra hne
    have : AgreeTo (firstDiff x y) x y := agreeTo_firstDiff x y
    exact h (this 0 (Nat.pos_of_ne_zero hne))
  rw [dist_eq, cantorDist, if_neg hxy, hfd]
  norm_num

/-- **Sensitive dependence on initial conditions**, with the maximal possible sensitivity
constant `1`.  Arbitrarily close to any subshift point there is another subshift point whose
orbit becomes maximally distant — the two streams eventually disagree in their very first
coordinate. -/
theorem goldenMean_sensitive {x : Cantor} (hx : x ∈ GoldenMean) {ε : ℝ} (hε : 0 < ε) :
    ∃ y ∈ GoldenMean, dist x y < ε ∧ ∃ m, dist (shift^[m] x) (shift^[m] y) = 1 := by
  obtain ⟨y, hy, hyx, hd⟩ := goldenMean_perfect hx hε
  have hne : x ≠ y := fun h => hyx h.symm
  obtain ⟨k, hk⟩ := exists_diff_of_ne hne
  refine ⟨y, hy, hd, k, ?_⟩
  refine dist_eq_one_of_ne_zero ?_
  rw [shift_iterate_apply, shift_iterate_apply]
  simpa using hk

/-! ## Devaney chaos -/

/-- **The golden-mean subshift is chaotic in the sense of Devaney.**  All three defining
properties hold simultaneously for the shift restricted to `GoldenMean`: density of periodic
points, topological transitivity, and sensitive dependence on initial conditions.  Together
with `isCompact_goldenMean` and `goldenMean_perfect` this identifies the golden-mean subshift
as a compact perfect chaotic attractor of maximal sensitivity constant. -/
theorem goldenMean_devaney_chaos :
    (∀ x ∈ GoldenMean, ∀ ε > 0, ∃ y ∈ GoldenMean,
        (∃ p, 0 < p ∧ shift^[p] y = y) ∧ dist x y < ε) ∧
    (∀ x ∈ GoldenMean, ∀ y ∈ GoldenMean, ∀ n : ℕ, ∃ z ∈ GoldenMean,
        dist x z ≤ (2 : ℝ) ^ (-(n : ℤ)) ∧ dist y (shift^[n + 1] z) ≤ (2 : ℝ) ^ (-(n : ℤ))) ∧
    (∀ x ∈ GoldenMean, ∀ ε > 0, ∃ y ∈ GoldenMean,
        dist x y < ε ∧ ∃ m, dist (shift^[m] x) (shift^[m] y) = 1) :=
  ⟨fun _ hx _ hε => goldenMean_periodicPoints_dense hx hε,
   fun _ hx _ hy n => goldenMean_transitive hx hy n,
   fun _ hx _ hε => goldenMean_sensitive hx hε⟩

end FractalTruthCompactness