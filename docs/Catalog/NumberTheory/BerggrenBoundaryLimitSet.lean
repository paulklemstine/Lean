import Catalog.Geometry.HyperbolicBerggrenGeodesics
import Catalog.NumberTheory.BerggrenStarLines

/-!
# The limit set of the Berggren tree on the ideal boundary

The pictures that motivate this thread show *stars*: families of Berggren nodes marching
out to a single ideal point of the Poincaré half-plane.  `NumberTheory.BerggrenStarLines`
identified two such stars exactly, based at the ideal points `1` and `0`, and
`NumberTheory.BerggrenBoundaryDynamics` showed that a constant Berggren word converges to
one of three tips.  This file answers the complementary global question:

> *which* ideal points are approached by Berggren nodes at all?

The answer is: **all of them**.  The set of accumulation points of the node set
`{ (n + i)/m : (m,n) a Euclid seed }` on the real line contains the entire interval
`[0,1]`, so the "stars'' visible in a finite picture are only the most conspicuous of a
continuum of directions.  The proof is a *dyadic seed* construction: for `K ≥ 1` and any
odd `n < 2^K`, the pair `(2^K, n)` is automatically a Euclid seed (coprimality is free
because `n` is odd, and the parity condition is free because `2^K` is even), and the
odd numerators are `2`-dense in `[0, 2^K]`.

## Main results

* `dyadic_isSeed` : `(2^K, n)` is a Euclid seed for every odd `0 < n < 2^K`, `K ≥ 1`.
* `exists_odd_near` : every real `s ∈ [0, N]` with `N ≥ 4` even has an odd integer
  `0 < n < N` within distance `1`.
* `seed_boundary_dense` : for every `t ∈ [0,1]` and every `ε > 0` there is a Euclid seed
  whose slope is within `ε` of `t` *and* whose height `1/m` is below `ε`.
* `hpoint_boundary_dense` : the same statement phrased for the half-plane point
  `z(m,n) = (n+i)/m`: every boundary point of `[0,1]` is an accumulation point of nodes.
* `seed_slope_dense_large` : consequently every non-degenerate subinterval of
  `(0,1)` contains the slopes of infinitely many nodes — the "stars'' are dense.
-/

namespace BerggrenBoundaryLimitSet

open Real HyperbolicBerggrenGeodesics UpperHalfPlane Filter Topology

/-! ## Part 1. Dyadic seeds -/

/-- **Dyadic seeds are free.**  If `n` is odd and `0 < n < 2 ^ K` with `K ≥ 1`, then
`(2 ^ K, n)` is a Euclid seed: coprimality holds because `n` is odd, and the parity
condition holds because `2 ^ K` is even. -/
theorem dyadic_isSeed (K n : ℕ) (hK : 1 ≤ K) (hodd : n % 2 = 1) (hpos : 0 < n)
    (hlt : n < 2 ^ K) : IsSeed (2 ^ K) n := by
  have hdvd : (2 : ℕ) ∣ 2 ^ K := dvd_pow_self 2 (by omega)
  refine ⟨hpos, hlt, ?_, ?_⟩
  · exact Nat.Coprime.pow_left K ((Nat.Prime.coprime_iff_not_dvd Nat.prime_two).mpr (by omega))
  · omega

/-! ## Part 2. Odd integers are `1`-dense -/

/-- Every real number in `[0, N]`, with `N ≥ 4` even, is within distance `1` of an odd
natural number strictly between `0` and `N`. -/
theorem exists_odd_near (N : ℕ) (hN : 4 ≤ N) (hNeven : N % 2 = 0) (s : ℝ) (hs : 0 ≤ s)
    (hsN : s ≤ N) : ∃ n : ℕ, n % 2 = 1 ∧ 0 < n ∧ n < N ∧ |(n : ℝ) - s| ≤ 1 := by
  have hfl : (⌊s⌋₊ : ℝ) ≤ s := Nat.floor_le hs
  have hfl' : s < (⌊s⌋₊ : ℝ) + 1 := Nat.lt_floor_add_one s
  have hNcast : (((N - 1 : ℕ)) : ℝ) = (N : ℝ) - 1 := by
    have h1 : (1 : ℕ) ≤ N := by omega
    push_cast [Nat.cast_sub h1]
    ring
  by_cases hcase : ⌊s⌋₊ ≤ N - 2
  · by_cases h : ⌊s⌋₊ % 2 = 1
    · refine ⟨⌊s⌋₊, h, by omega, by omega, ?_⟩
      rw [abs_le]
      constructor <;> linarith
    · refine ⟨⌊s⌋₊ + 1, by omega, by omega, by omega, ?_⟩
      push_cast
      rw [abs_le]
      constructor <;> linarith
  · push_neg at hcase
    have hsge : ((N : ℝ) - 1) ≤ s := by
      have h1 : N - 1 ≤ ⌊s⌋₊ := by omega
      have h2 : (((N - 1 : ℕ)) : ℝ) ≤ (⌊s⌋₊ : ℝ) := by exact_mod_cast h1
      rw [hNcast] at h2
      linarith
    refine ⟨N - 1, by omega, by omega, by omega, ?_⟩
    rw [hNcast, abs_le]
    constructor <;> linarith

/-! ## Part 3. Every ideal point of `[0,1]` is approached -/

/-- **The limit set of the Berggren tree contains all of `[0,1]`.**  For every
`t ∈ [0,1]` and every `ε > 0` there is a Euclid seed `(m,n)` whose slope `n/m` is within
`ε` of `t` and whose height `1/m` is smaller than `ε`; that is, the half-plane node
`z(m,n)` is `ε`-close to the ideal point `t`. -/
theorem seed_boundary_dense (t : ℝ) (ht : 0 ≤ t) (ht1 : t ≤ 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ m n : ℕ, IsSeed m n ∧ |(n : ℝ) / m - t| < ε ∧ (1 : ℝ) / m < ε := by
  obtain ⟨M, hM⟩ := exists_nat_gt (2 / ε)
  set K : ℕ := M + 2 with hKdef
  set N : ℕ := 2 ^ K with hNdef
  have hNge : 4 ≤ N := by
    have : (2 : ℕ) ^ 2 ≤ 2 ^ K := Nat.pow_le_pow_right (by norm_num) (by omega)
    simpa [hNdef] using this
  have hNeven : N % 2 = 0 := by
    have : (2 : ℕ) ∣ 2 ^ K := dvd_pow_self 2 (by omega)
    omega
  have hMN : (M : ℝ) < (N : ℝ) := by
    have h1 : M < 2 ^ M := Nat.lt_two_pow_self
    have h2 : (2 : ℕ) ^ M ≤ 2 ^ K := Nat.pow_le_pow_right (by norm_num) (by omega)
    have : M < N := lt_of_lt_of_le h1 (by simpa [hNdef] using h2)
    exact_mod_cast this
  have hNposR : (0 : ℝ) < (N : ℝ) := by
    have : 0 < N := by omega
    exact_mod_cast this
  have hbig : (2 : ℝ) / ε < (N : ℝ) := lt_trans hM hMN
  have hsmall : (1 : ℝ) / (N : ℝ) < ε := by
    rw [div_lt_iff₀ hNposR]
    have h2 : (2 : ℝ) < (N : ℝ) * ε := by
      have := (div_lt_iff₀ hε).mp hbig
      linarith
    linarith
  obtain ⟨n, hodd, hnpos, hnlt, hnear⟩ :=
    exists_odd_near N hNge hNeven (t * N) (by positivity) (by nlinarith)
  refine ⟨N, n, dyadic_isSeed K n (by omega) hodd hnpos hnlt, ?_, ?_⟩
  · have hrw : (n : ℝ) / (N : ℝ) - t = ((n : ℝ) - t * (N : ℝ)) / (N : ℝ) := by
      field_simp
    rw [hrw, abs_div, abs_of_pos hNposR]
    calc |(n : ℝ) - t * (N : ℝ)| / (N : ℝ) ≤ 1 / (N : ℝ) := by gcongr
      _ < ε := hsmall
  · exact hsmall

/-- The same statement in half-plane language: for every ideal point `t ∈ [0,1]` and every
`ε > 0` there is a Berggren node `z(m,n) = (n+i)/m` whose real part is within `ε` of `t`
and whose imaginary part is below `ε`.  Every point of `[0,1]` is therefore an
accumulation point of the node set on the ideal boundary. -/
theorem hpoint_boundary_dense (t : ℝ) (ht : 0 ≤ t) (ht1 : t ≤ 1) {ε : ℝ} (hε : 0 < ε) :
    ∃ (m n : ℕ) (hm : 0 < m), IsSeed m n ∧
      |(hpoint m n hm).re - t| < ε ∧ (hpoint m n hm).im < ε := by
  obtain ⟨m, n, hseed, h1, h2⟩ := seed_boundary_dense t ht ht1 hε
  have hm : 0 < m := lt_trans hseed.pos hseed.lt
  exact ⟨m, n, hm, hseed, by simpa [hpoint_re] using h1, by simpa [hpoint_im] using h2⟩

/-- **The slopes of Berggren nodes are dense in `[0,1]`, with unbounded denominators.**
Given any target `t` and any bound `B`, some seed with `m > B` has slope within `ε` of `t`;
hence every non-degenerate subinterval of `[0,1]` carries infinitely many nodes. -/
theorem seed_slope_dense_large (t : ℝ) (ht : 0 ≤ t) (ht1 : t ≤ 1) {ε : ℝ} (hε : 0 < ε)
    (B : ℕ) : ∃ m n : ℕ, IsSeed m n ∧ B < m ∧ |(n : ℝ) / m - t| < ε := by
  set δ : ℝ := min ε (1 / (B + 1)) with hδ
  have hδpos : 0 < δ := lt_min hε (by positivity)
  obtain ⟨m, n, hseed, h1, h2⟩ := seed_boundary_dense t ht ht1 hδpos
  have hm : 0 < m := lt_trans hseed.pos hseed.lt
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  refine ⟨m, n, hseed, ?_, lt_of_lt_of_le h1 (min_le_left _ _)⟩
  have hb : (1 : ℝ) / m < 1 / (B + 1) := lt_of_lt_of_le h2 (min_le_right _ _)
  have : ((B : ℝ) + 1) < (m : ℝ) := by
    have hB : (0 : ℝ) < (B : ℝ) + 1 := by positivity
    rw [div_lt_div_iff₀ hmR hB] at hb
    linarith
  have hBm : (B : ℝ) < (m : ℝ) := by linarith
  exact_mod_cast hBm

end BerggrenBoundaryLimitSet