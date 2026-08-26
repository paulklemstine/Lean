/-
# Cycle 4: every interior saturation location is realisable

The saturation theorem produces a unique interior argmax from a hypothesis on
the *response* (matched signal block, then noise).  The obvious follow-up
question — and the one an experimenter should ask before reading anything into a
measured `B*` — is whether the location of the peak says anything about the
*columns*.

It does not.  The main theorem here, `interior_argmax_realizable`, says: fix any
family of pairwise orthogonal nonzero columns `v_0, …, v_{m-1}` and any interior
window `1 ≤ t < m`.  Then there is a response, namely `y = v_0 + ⋯ + v_{t-1}`,
for which the unit-weight window curve has its unique maximum exactly at `t`.

Consequently a measured saturation location constrains the response only; within
a fixed column family, every interior location is attainable
(`SignDesign.interior_argmax_realizable`, for `±1` designs of strength two).
-/
import Combinatorics.WindowSaturationDesigns

open Finset

namespace WindowSaturation

variable {n m : ℕ}

/-- The unweighted sum of the first `t` columns. -/
def sumCols (v : ℕ → Fin n → ℝ) (t : ℕ) : Fin n → ℝ := fun j => ∑ i ∈ range t, v i j

lemma dot_sumCols (v : ℕ → Fin n → ℝ) (t : ℕ) (k : ℕ) :
    dot (v k) (sumCols v t) = ∑ i ∈ range t, dot (v k) (v i) := by
  simp only [dot, sumCols, Finset.mul_sum]
  rw [Finset.sum_comm]

/-- Against an orthogonal family, the sum of the first `t` columns picks out
exactly the squared norms of those columns. -/
lemma dot_sumCols_of_orth {v : ℕ → Fin n → ℝ}
    (horth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0) {t k : ℕ} (htm : t ≤ m)
    (hkm : k < m) :
    dot (v k) (sumCols v t) = if k < t then dot (v k) (v k) else 0 := by
  rw [dot_sumCols]
  by_cases hk : k < t
  · rw [if_pos hk, Finset.sum_eq_single k]
    · intro i hi hik
      exact horth k hkm i (lt_of_lt_of_le (Finset.mem_range.mp hi) htm) (Ne.symm hik)
    · intro h; exact absurd (Finset.mem_range.mpr hk) h
  · rw [if_neg hk]
    refine Finset.sum_eq_zero fun i hi => ?_
    have him : i < m := lt_of_lt_of_le (Finset.mem_range.mp hi) htm
    have : k ≠ i := by
      intro h; exact hk (h ▸ Finset.mem_range.mp hi)
    exact horth k hkm i him this

lemma dot_sumCols_left (v : ℕ → Fin n → ℝ) (t : ℕ) (u : Fin n → ℝ) :
    dot (sumCols v t) u = ∑ k ∈ range t, dot (v k) u := by
  simp only [dot, sumCols, Finset.sum_mul]
  rw [Finset.sum_comm]

lemma dot_sumCols_self {v : ℕ → Fin n → ℝ}
    (horth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0) {t : ℕ} (htm : t ≤ m) :
    dot (sumCols v t) (sumCols v t) = ∑ i ∈ range t, dot (v i) (v i) := by
  rw [dot_sumCols_left]
  refine Finset.sum_congr rfl fun k hk => ?_
  have hkm : k < m := lt_of_lt_of_le (Finset.mem_range.mp hk) htm
  rw [dot_sumCols_of_orth horth htm hkm, if_pos (Finset.mem_range.mp hk)]

/-- The window model built from an orthogonal column family by taking the sum of
the first `t` columns as response. -/
def prefixResponseModel (v : ℕ → Fin n → ℝ)
    (hpos : ∀ i < m, 0 < dot (v i) (v i))
    (horth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0)
    {t : ℕ} (ht : 1 ≤ t) (htm : t ≤ m) : Model n m where
  v := v
  y := sumCols v t
  self_pos := hpos
  orth := horth
  resp_pos := by
    rw [dot_sumCols_self horth htm]
    refine Finset.sum_pos (fun i hi => hpos i (lt_of_lt_of_le (Finset.mem_range.mp hi) htm)) ?_
    exact Finset.nonempty_range_iff.mpr (by omega)

/-- **Every interior location is realisable.**  For any pairwise orthogonal
family of nonzero columns and any interior window `1 ≤ t < m`, the response
`y = v_0 + ⋯ + v_{t-1}` makes the unit-weight score curve peak exactly at `t`:
the argmax set is `{t}`.  A measured saturation location therefore carries
information about the response only, never about the column family. -/
theorem interior_argmax_realizable (v : ℕ → Fin n → ℝ)
    (hpos : ∀ i < m, 0 < dot (v i) (v i))
    (horth : ∀ i < m, ∀ j < m, i ≠ j → dot (v i) (v j) = 0)
    {t : ℕ} (ht : 1 ≤ t) (htm : t < m) :
    ∀ B ≤ m, B ≠ t →
      (prefixResponseModel v hpos horth ht htm.le).R2 (fun _ => 1) B
        < (prefixResponseModel v hpos horth ht htm.le).R2 (fun _ => 1) t := by
  set M := prefixResponseModel v hpos horth ht htm.le with hM
  have hA : ∀ k < m, M.a k = if k < t then M.s k else 0 := by
    intro k hk
    show dot (v k) (sumCols v t) = if k < t then dot (v k) (v k) else 0
    exact dot_sumCols_of_orth horth htm.le hk
  refine Model.unique_interior_argmax (rho := 1) M htm.le ht ?_ ?_ ?_ ?_
  · intro i hi
    rw [one_mul, hA i (by omega), if_pos hi]
    ring
  · intro i hi
    rw [one_mul, hA i (by omega), if_pos hi]
    exact hpos i (by omega)
  · intro i hti him
    rw [hA i him, if_neg (by omega)]
  · intro i _ _; norm_num

namespace SignDesign

variable (D : SignDesign n m)

/-- Specialisation to `±1` designs of strength two: inside a fixed Hadamard-type
design, every interior saturation location `1 ≤ t < m` occurs for a suitable
response.  So `B*` never identifies the design. -/
theorem interior_argmax_realizable (hn : 0 < n) {t : ℕ} (ht : 1 ≤ t) (htm : t < m) :
    ∀ B ≤ m, B ≠ t →
      (prefixResponseModel D.c (fun i hi => by
          rw [D.dot_self hi]; exact_mod_cast hn)
        (fun i hi k hk hik => D.balanced i hi k hk hik) ht htm.le).R2 (fun _ => 1) B
      < (prefixResponseModel D.c (fun i hi => by
          rw [D.dot_self hi]; exact_mod_cast hn)
        (fun i hi k hk hik => D.balanced i hi k hk hik) ht htm.le).R2 (fun _ => 1) t :=
  WindowSaturation.interior_argmax_realizable D.c _ _ ht htm

end SignDesign

end WindowSaturation