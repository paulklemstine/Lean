import Mathlib

/-!
# Window geometry forces tiny `v` at the left edge (the inclusion artifact)

This file formalises the *mechanical forcing* half of the round-85 resolution of
the "left-edge spike".  The empirical situation is:

* a sieve-type search stores, for each modulus `N`, the residues
  `v N j = j^2 - N` at positions `j` running over the window
  `W N = [isqrt N + 1, 3 * isqrt N]`;
* the *first decile* `D1` of that window is the leading tenth of it, i.e. the
  positions `j` with `10 * (j - isqrt N) ≤ 2 * isqrt N`, equivalently
  `5 * j ≤ 6 * isqrt N`;
* the empirical `D1` hit mass split by `bitlen v` was
  `< 80 : 0`, `80–89 : 85`, `90–95 : 1469`, `≥ 96 : 0`.

The observation that *no* `D1` hit can have `bitlen v ≥ 96` is not statistics:
it is a theorem of exact integer arithmetic about the window.  We prove it here
in the sharp form

`25 * v N j ≤ 11 * (isqrt N)^2`  for every first-decile position,

i.e. `v ≤ 0.44 * s^2 ≤ 0.44 * N`, together with

* the general scale-carrying version with an arbitrary rational edge fraction
  `p/q` (`Spike.residue_le_of_edge_frac`), whose constant `2pq + p^2` degrades
  gracefully as the window prefix grows;
* the bit-length corollary `Spike.size_residue_lt_96` : for `N < 2 ^ 96` every
  first-decile residue satisfies `bitlen v < 96`;
* its contrapositive `Spike.not_first_decile_of_size_ge_96` : any stored hit
  with `bitlen v ≥ 96` is *outside* the first decile — the exclusion is total,
  not statistical;
* sharpness `Spike.residue_edge_sharp` : the constant `11/25` is attained, and
  `Spike.exists_window_size_ge_96` : positions further into the same window do
  carry `bitlen v ≥ 96`, so the bound really is a property of the edge and not
  of the window as a whole;
* the degenerate-exclusion clause `Spike.residue_pos` : residues at window
  positions are strictly positive, so `bitlen` is well defined on them.

Consequence for the statistics: the first decile is a *pure tiny-`v` stratum*.
Any comparison of the first decile against the whole-window `v` distribution is
therefore confounded with magnitude by construction; see
`Catalog/Probability/SpikeBandComposition.lean` for the composition accounting
and `Catalog/Probability/SpikeStratifiedEvidence.lean` for the model-selection
consequence.
-/

namespace Spike

/-- The residue stored at window position `j` for modulus `N`. -/
def residue (N j : ℕ) : ℕ := j ^ 2 - N

/-- The search window: `j ∈ [isqrt N + 1, 3 * isqrt N]`. -/
def inWindow (N j : ℕ) : Prop := Nat.sqrt N + 1 ≤ j ∧ j ≤ 3 * Nat.sqrt N

/-- The first decile of the window: the leading tenth of the `2 * isqrt N`
positions, i.e. `10 * (j - isqrt N) ≤ 2 * isqrt N`. -/
def inFirstDecile (N j : ℕ) : Prop := inWindow N j ∧ 5 * j ≤ 6 * Nat.sqrt N

/-! ### Degenerate exclusion: window residues are positive -/

/-- Every window position lies strictly above `isqrt N`, hence its residue is
positive.  (This is the pre-registered degenerate-exclusion clause: `v = 0`
would mean `N` is a perfect square and the position is `isqrt N` itself, which
the window excludes.) -/
theorem residue_pos {N j : ℕ} (h : inWindow N j) : 0 < residue N j := by
  have hs : N < (Nat.sqrt N + 1) ^ 2 := by
    have := Nat.lt_succ_sqrt N
    simpa [pow_two] using this
  have hj : (Nat.sqrt N + 1) ^ 2 ≤ j ^ 2 := Nat.pow_le_pow_left h.1 2
  have : N < j ^ 2 := lt_of_lt_of_le hs hj
  simpa [residue] using Nat.sub_pos_of_lt this

/-! ### The inclusion bound -/

/-- **Scale-carrying inclusion bound.**  If a position `j` sits within the
fraction `p/q` prefix beyond `isqrt N`, i.e. `q * j ≤ (q + p) * isqrt N`, then
its residue obeys `q^2 * v ≤ (2pq + p^2) * (isqrt N)^2`.

For `p/q = 1/5` (the first decile of a doubling window) this is
`25 * v ≤ 11 * s^2`, i.e. `v ≤ 0.44 * s^2`.  Note the bound is *exact
arithmetic*: no asymptotics, and it scales with `N`. -/
theorem residue_le_of_edge_frac {N j p q : ℕ}
    (hj : q * j ≤ (q + p) * Nat.sqrt N) :
    q ^ 2 * residue N j ≤ (2 * p * q + p ^ 2) * Nat.sqrt N ^ 2 := by
  set s := Nat.sqrt N with hs
  have hsq : s ^ 2 ≤ N := Nat.sqrt_le' N
  have hsquare : (q * j) ^ 2 ≤ ((q + p) * s) ^ 2 := Nat.pow_le_pow_left hj 2
  have hmul : q ^ 2 * j ^ 2 ≤ (2 * p * q + p ^ 2) * s ^ 2 + q ^ 2 * N := by
    calc q ^ 2 * j ^ 2 = (q * j) ^ 2 := by ring
      _ ≤ ((q + p) * s) ^ 2 := hsquare
      _ = (2 * p * q + p ^ 2) * s ^ 2 + q ^ 2 * s ^ 2 := by ring
      _ ≤ (2 * p * q + p ^ 2) * s ^ 2 + q ^ 2 * N :=
          Nat.add_le_add_left (Nat.mul_le_mul le_rfl hsq) _
  have hrw : q ^ 2 * residue N j = q ^ 2 * j ^ 2 - q ^ 2 * N := by
    simp [residue, Nat.mul_sub]
  rw [hrw]
  exact Nat.sub_le_iff_le_add.mpr hmul

/-- **First-decile inclusion bound**: `25 * v ≤ 11 * (isqrt N)^2`, i.e.
`v ≤ 0.44 * s^2`.  This is the `p = 1, q = 5` instance. -/
theorem residue_le_of_first_decile {N j : ℕ} (h : inFirstDecile N j) :
    25 * residue N j ≤ 11 * Nat.sqrt N ^ 2 := by
  have := residue_le_of_edge_frac (N := N) (j := j) (p := 1) (q := 5)
    (by simpa using h.2)
  norm_num at this
  simpa using this

/-- Since `s^2 ≤ N`, the first-decile bound also reads `v ≤ 0.44 * N`. -/
theorem residue_le_of_first_decile' {N j : ℕ} (h : inFirstDecile N j) :
    25 * residue N j ≤ 11 * N :=
  le_trans (residue_le_of_first_decile h)
    (Nat.mul_le_mul_left _ (Nat.sqrt_le' N))

/-! ### Bit-length consequence -/

/-- **The forcing.**  For a 96-bit modulus (`N < 2 ^ 96`) every first-decile
residue has bit length `< 96`; in fact `v < 2 ^ 95`.

Numerically: `v ≤ 0.44 * s^2 < 0.44 * 2^96 = 0.88 * 2^95 < 2^95`.  This is why
the empirical `D1` mass by band was `≥ 96 : 0` — a geometric identity of the
window, not a property of the hit process. -/
theorem size_residue_lt_96 {N j : ℕ} (hN : N < 2 ^ 96) (h : inFirstDecile N j) :
    (residue N j).size < 96 := by
  have h25 : 25 * residue N j ≤ 11 * N := residue_le_of_first_decile' h
  have hlt : residue N j < 2 ^ 95 := by
    by_contra hcon
    push_neg at hcon
    have h1 : 25 * 2 ^ 95 ≤ 25 * residue N j := Nat.mul_le_mul le_rfl hcon
    omega
  have : (residue N j).size ≤ 95 := Nat.size_le.mpr hlt
  omega

/-- Contrapositive form: a stored hit whose residue has bit length `≥ 96`
cannot lie in the first decile.  The exclusion is deterministic. -/
theorem not_first_decile_of_size_ge_96 {N j : ℕ} (hN : N < 2 ^ 96)
    (hsize : 96 ≤ (residue N j).size) : ¬ inFirstDecile N j := by
  intro h
  exact absurd (size_residue_lt_96 hN h) (by omega)

/-! ### Sharpness of the constant and of the localisation -/

/-- The constant `11/25` in the first-decile bound is attained: for
`N = s ^ 2` with `5 ∣ s` and `j` the last first-decile position we get equality
`25 * v = 11 * s ^ 2`. -/
theorem residue_edge_sharp (m : ℕ) (hm : 0 < m) :
    let s := 5 * m
    let N := s ^ 2
    let j := 6 * m
    inFirstDecile N j ∧ 25 * residue N j = 11 * Nat.sqrt N ^ 2 := by
  intro s N j
  have hsqrt : Nat.sqrt N = s := Nat.sqrt_eq' s
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · simp only [hsqrt, s, j]; omega
  · simp only [hsqrt, s, j]; omega
  · simp only [hsqrt, s, j]; omega
  · have hres : residue N j = 11 * m ^ 2 := by
      have h1 : (6 * m) ^ 2 = 25 * m ^ 2 + 11 * m ^ 2 := by ring
      have h2 : ((5 : ℕ) * m) ^ 2 = 25 * m ^ 2 := by ring
      simp only [residue, N, s, j]
      omega
    rw [hres, hsqrt]
    simp only [s]
    ring

/-- The tiny-`v` forcing is a property of the *edge*, not of the window: deeper
in the very same window there are positions whose residue has bit length `≥ 96`
(here `98`).  Hence the `D1` band composition really is induced by the decile
cut. -/
theorem exists_window_size_ge_96 :
    ∃ N j : ℕ, N < 2 ^ 96 ∧ inWindow N j ∧ 96 ≤ (residue N j).size := by
  have hsq : Nat.sqrt (2 ^ 94) = 2 ^ 47 := by
    have h : (2 : ℕ) ^ 94 = (2 ^ 47) ^ 2 := by ring
    rw [h, Nat.sqrt_eq']
  refine ⟨2 ^ 94, 3 * 2 ^ 47, by norm_num, ⟨?_, ?_⟩, ?_⟩
  · rw [hsq]; omega
  · rw [hsq]
  · have hres : residue (2 ^ 94) (3 * 2 ^ 47) = 2 ^ 97 := by
      have h : (3 * 2 ^ 47 : ℕ) ^ 2 = 2 ^ 94 + 2 ^ 97 := by ring
      simp only [residue]
      omega
    rw [hres]
    exact Nat.lt_size.mpr (by norm_num)

end Spike