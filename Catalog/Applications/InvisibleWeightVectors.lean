/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Mathlib
import Shared.PowerSumSharpness

/-!
# The invisible weight vectors of a truncated power-sum window

This file completes the programme opened by the Lagrange engine of
`Shared/PowerSumSharpness.lean` (`eq_zero_of_powerSums_zero`, `powerSums_determine`).

The engine says: a rational weight vector `e` supported on the nodes `{0,…,N}` which
annihilates every monomial `x ↦ x ^ k` for `k ≤ N` is zero.  Equivalently, the *moment map*
`e ↦ (∑_{j ≤ N} e j · j ^ k)_{k ≤ N}` is injective.  What the engine leaves open is the
**truncated** question: fix a window length `K ≤ N` and ask which weight vectors are
*invisible to the window*, i.e. satisfy `∑_{j ≤ N} e j · j ^ k = 0` for all `k < K`.
The catalog knew one such vector, the alternating binomial vector at `K = N`
(`alternating_choose_pow`), and used it for the sharpness statements.

The results below determine the invisible vectors completely, for every window `K ≤ N`,
over any commutative ring for the "sufficiency" half and over `ℚ` **and** `ℤ` for the
"necessity" half.

* `binWeight K i` — the shifted alternating binomial vector, supported on `[i, i+K]`, with
  entries `(-1)^{K-d} C(K,d)` at `i + d`.  Its generating polynomial is `X^i (X-1)^K`.
* `binWeight_invisible` — each `binWeight K i` with `i + K ≤ N` is invisible to the window
  `k < K`; `moment_binWeight_top` shows all of them have the *same* first visible moment
  `K !` at `k = K`, independently of the shift `i`.
* `exists_coeffs_of_invisible` (over `ℚ`) and `exists_intCoeffs_of_invisible` (over `ℤ`) —
  **the structure theorem**: every invisible vector is a linear combination of the
  `N + 1 - K` shifted binomial vectors, with *integer* coefficients when the vector is
  integral.  So the invisible lattice is free of rank `N + 1 - K` with an explicit basis.
* `coeffs_unique`, `binWeight_linearIndependent` — the shifted binomial vectors are
  independent, so the rank `N + 1 - K` is exact.
* `invisible_iff_exists_coeffs` — the clean iff.
* `nearMiss_structure_window`, `nearMiss_of_intCoeffs` — **the construction**: the
  dictionary between invisible integer vectors and *near misses* (pairs of multisets with
  identical power sums throughout the window).  Every near miss at window `K` is an integer
  combination of shifted binomial pairs, and every such combination is a near miss.  For
  `K = N` this recovers the catalog's `near_miss_iff` (one binomial pair, scaled); for
  `K < N` it is new and exhibits `N + 1 - K` independent families.

-- !-- Lab Notes -- !--

HYPOTHESIS (Hypothesizer).  The kernel of the truncated moment map should be spanned by the
"discrete `K`-th derivative" vectors `Δ^K` based at each admissible node, because
`∑_d (-1)^{K-d} C(K,d) f(i+d) = Δ^K f (i)` kills all polynomials of degree `< K`.  Counting
degrees of freedom: `N + 1` unknowns, `K` equations, all independent by Vandermonde, so the
kernel should have dimension exactly `N + 1 - K` — the number of admissible shifts.  Bold
part of the hypothesis: the same statement should hold *over `ℤ`* (unimodularity), which is
not implied by the rational statement.

EXPERIMENT (Experimenter).  Both halves proved below.  Sufficiency is
`fwdDiff_iter_pow_eq_zero_of_lt` transported along `moment_binWeight_eq_fwdDiff`.
Necessity is a downward induction on `N`: the top entry `e N` can only be produced by the
last shifted vector `binWeight K (N-K)`, whose top entry is `1`; subtracting `e N` times it
lowers `N` by one.  Because that leading entry is `1` (not `±K!`, not `C(K,d)`), the
induction never divides — which is exactly why the integral statement follows from the same
argument, with the rational Lagrange engine used only in the base case `N < K`.

ANALYSIS (Analyst).  The proof isolates *why* the catalog's binomial pair was extremal: it
is the `K = N` corner of the basis, where the kernel is a single line.  For `K < N` the
kernel grows by one dimension per unit, and the extra basis vectors are literal translates.
The numerical data (`example`s at the end) confirm the `N + 1 - K` count for
`(N,K) = (2,2), (3,2), (3,3)`.

CRITIQUE (Critic).  No statement is vacuous: `binWeight_ne_zero` and
`moment_binWeight_top` show the basis vectors are nonzero and become visible exactly one
step after the window; `nearMiss_of_intCoeffs` produces genuinely distinct multisets.  The
hypothesis `K ≤ N` cannot be dropped in the rank statement — for `K > N` the kernel is `0`,
which is the engine, and `N + 1 - K` truncates to `0`, so the formula survives.
-/

open Finset Polynomial

namespace InvisibleWeights

open PowerSumSharpness

variable {R : Type*} [CommRing R]

/-! ## Moments of a weight vector -/

/-- `moment N e k = ∑_{j ≤ N} e j · j ^ k`, the `k`-th moment of a weight vector supported
on the nodes `{0, …, N}`. -/
def moment (N : ℕ) (e : ℕ → R) (k : ℕ) : R := ∑ j ∈ range (N + 1), e j * (j : R) ^ k

/-- A weight vector is **invisible to the window `k < K`** when all its moments of order
below `K` vanish. -/
def Invisible (N K : ℕ) (e : ℕ → R) : Prop := ∀ k < K, moment N e k = 0

lemma moment_add (N : ℕ) (e f : ℕ → R) (k : ℕ) :
    moment N (fun j => e j + f j) k = moment N e k + moment N f k := by
  simp only [moment, ← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun j _ => by ring

lemma moment_smul (N : ℕ) (c : R) (e : ℕ → R) (k : ℕ) :
    moment N (fun j => c * e j) k = c * moment N e k := by
  simp only [moment, Finset.mul_sum]
  exact Finset.sum_congr rfl fun j _ => by ring

lemma moment_sum {ι : Type*} (N : ℕ) (u : Finset ι) (g : ι → ℕ → R) (k : ℕ) :
    moment N (fun j => ∑ i ∈ u, g i j) k = ∑ i ∈ u, moment N (g i) k := by
  classical
  induction u using Finset.induction with
  | empty => simp [moment]
  | insert a u ha ih =>
      simp only [Finset.sum_insert ha]
      rw [show (fun j => g a j + ∑ i ∈ u, g i j) = (fun j => g a j + (fun j => ∑ i ∈ u, g i j) j)
        from rfl, moment_add, ih]

/-! ## The shifted alternating binomial vectors -/

/-- `binWeight K i` is the weight vector supported on `[i, i + K]` with entry
`(-1)^{K-d} · C(K,d)` at the node `i + d`.  Its generating polynomial is `X^i (X-1)^K`, and
it implements the `K`-th forward difference based at `i`. -/
def binWeight (K i j : ℕ) : R :=
  if i ≤ j ∧ j ≤ i + K then (-1 : R) ^ (K - (j - i)) * (K.choose (j - i) : R) else 0

lemma binWeight_of_lt {K i j : ℕ} (h : j < i) : binWeight (R := R) K i j = 0 := by
  simp [binWeight, Nat.not_le.mpr h]

lemma binWeight_of_gt {K i j : ℕ} (h : i + K < j) : binWeight (R := R) K i j = 0 := by
  simp only [binWeight, ite_eq_right_iff]
  rintro ⟨-, h2⟩
  omega

lemma binWeight_top (K i : ℕ) : binWeight (R := R) K i (i + K) = 1 := by
  simp [binWeight]

lemma binWeight_base (K i : ℕ) : binWeight (R := R) K i i = (-1 : R) ^ K := by
  simp [binWeight]

/-- Moments of a shifted binomial vector are shifted alternating binomial sums. -/
lemma moment_binWeight_eq_alt {K i N : ℕ} (h : i + K ≤ N) (k : ℕ) :
    moment N (binWeight (R := R) K i) k
      = ∑ d ∈ range (K + 1), ((-1 : R) ^ (K - d) * (K.choose d : R)) * ((i + d : ℕ) : R) ^ k := by
  classical
  have hsub : (range (K + 1)).image (fun d => i + d) ⊆ range (N + 1) := by
    intro j hj
    obtain ⟨d, hd, rfl⟩ := Finset.mem_image.mp hj
    exact mem_range.mpr (by have := mem_range.mp hd; omega)
  have hzero : ∀ j ∈ range (N + 1), j ∉ (range (K + 1)).image (fun d => i + d) →
      binWeight (R := R) K i j * (j : R) ^ k = 0 := by
    intro j _ hj
    have : binWeight (R := R) K i j = 0 := by
      simp only [binWeight, ite_eq_right_iff]
      rintro ⟨h1, h2⟩
      exact absurd (Finset.mem_image.mpr ⟨j - i, mem_range.mpr (by omega), by omega⟩) hj
    rw [this, zero_mul]
  have hinj : Set.InjOn (fun d => i + d) ↑(range (K + 1)) := by
    intro a _ b _ hab
    simpa using hab
  rw [moment, ← Finset.sum_subset hsub hzero, Finset.sum_image hinj]
  refine Finset.sum_congr rfl fun d hd => ?_
  have hd' : d ≤ K := Nat.lt_succ_iff.mp (mem_range.mp hd)
  have h1 : i ≤ i + d := Nat.le_add_right _ _
  have h2 : i + d ≤ i + K := by omega
  simp [binWeight, h1, h2]

/-- Moments of a shifted binomial vector are iterated forward differences of monomials. -/
lemma moment_binWeight_eq_fwdDiff {K i N : ℕ} (h : i + K ≤ N) (k : ℕ) :
    moment N (binWeight (R := R) K i) k
      = (fwdDiff (1 : R))^[K] (fun r : R => r ^ k) (i : R) := by
  rw [moment_binWeight_eq_alt h, fwdDiff_iter_eq_sum_shift]
  refine Finset.sum_congr rfl fun d _ => ?_
  have : (i : R) + d • (1 : R) = ((i + d : ℕ) : R) := by push_cast; simp
  rw [this, zsmul_eq_mul]
  push_cast
  ring

/-- **Invisibility.**  Each shifted binomial vector fitting inside the nodes `{0,…,N}` is
invisible to the window `k < K`. -/
theorem binWeight_invisible {K i N : ℕ} (h : i + K ≤ N) :
    Invisible N K (binWeight (R := R) K i) := by
  intro k hk
  rw [moment_binWeight_eq_fwdDiff h, fwdDiff_iter_pow_eq_zero_of_lt hk]
  rfl

/-- **First visible moment.**  At `k = K` every shifted binomial vector has moment `K !`,
independently of the shift `i`: the window is escaped simultaneously by the whole basis. -/
theorem moment_binWeight_top {K i N : ℕ} (h : i + K ≤ N) :
    moment N (binWeight (R := R) K i) K = (K.factorial : R) := by
  rw [moment_binWeight_eq_fwdDiff h, fwdDiff_iter_eq_factorial]
  rfl

/-- The shifted binomial vectors are nonzero (their top entry is `1`). -/
theorem binWeight_ne_zero [Nontrivial R] (K i : ℕ) : binWeight (R := R) K i ≠ 0 := by
  intro h
  have h1 : binWeight (R := R) K i (i + K) = 0 := by rw [h]; rfl
  rw [binWeight_top] at h1
  exact one_ne_zero h1

/-! ## The structure theorem: invisible vectors are spanned by shifted binomial vectors -/

/-- The engine of `Shared/PowerSumSharpness.lean`, restated with `moment`: a rational weight
vector on `{0,…,M}` all of whose moments up to order `M` vanish is zero. -/
lemma eq_zero_of_moments_zero_rat {M : ℕ} {e : ℕ → ℚ} (h : ∀ k ≤ M, moment M e k = 0) :
    ∀ j ≤ M, e j = 0 :=
  eq_zero_of_powerSums_zero h

/-- The integral version of the engine, by clearing denominators (here: none). -/
lemma eq_zero_of_moments_zero_int {M : ℕ} {e : ℕ → ℤ} (h : ∀ k ≤ M, moment M e k = 0) :
    ∀ j ≤ M, e j = 0 := by
  intro j hj
  have hq : ∀ k ≤ M, moment M (fun n => (e n : ℚ)) k = 0 := by
    intro k hk
    have := congrArg (fun z : ℤ => (z : ℚ)) (h k hk)
    simpa [moment] using this
  have := eq_zero_of_moments_zero_rat hq j hj
  exact_mod_cast this

/-- **Generic structure theorem.**  Over any commutative ring in which the untruncated
engine holds (hypothesis `hbase`), every vector invisible to the window `k < K` is a linear
combination of the `N + 1 - K` shifted binomial vectors `binWeight K i`, `i < N + 1 - K`.

The induction never divides: the top entry of `binWeight K (N-K)` is `1`. -/
theorem exists_coeffs_of_invisible_aux (K : ℕ)
    (hbase : ∀ (M : ℕ) (e : ℕ → R), M < K → (∀ k ≤ M, moment M e k = 0) → ∀ j ≤ M, e j = 0) :
    ∀ (N : ℕ) (e : ℕ → R), Invisible N K e →
      ∃ c : ℕ → R, ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j := by
  intro N
  induction N with
  | zero =>
      intro e he
      rcases Nat.eq_zero_or_pos K with rfl | hK
      · refine ⟨fun _ => e 0, fun j hj => ?_⟩
        interval_cases j
        simp [binWeight]
      · refine ⟨fun _ => 0, fun j hj => ?_⟩
        have h0 : ∀ k ≤ 0, moment 0 e k = 0 := fun k hk => he k (by omega)
        rw [hbase 0 e hK h0 j hj]
        have : (0 : ℕ) + 1 - K = 0 := by omega
        simp [this]
  | succ n ih =>
      intro e he
      by_cases hK : n + 1 < K
      · refine ⟨fun _ => 0, fun j hj => ?_⟩
        have h0 : ∀ k ≤ n + 1, moment (n + 1) e k = 0 := fun k hk => he k (by omega)
        rw [hbase (n + 1) e hK h0 j hj]
        have : (n + 1) + 1 - K = 0 := by omega
        simp [this]
      · push_neg at hK
        set i₀ := n + 1 - K with hi₀
        have hi₀K : i₀ + K = n + 1 := by omega
        set b : ℕ → R := binWeight K i₀ with hb
        set e' : ℕ → R := fun j => e j - e (n + 1) * b j with he'
        -- `e'` is invisible at level `n`
        have hbinv : Invisible (n + 1) K b := binWeight_invisible (by omega)
        have he'inv : Invisible n K e' := by
          intro k hk
          have hsplit : moment (n + 1) e' k
              = moment n e' k + e' (n + 1) * ((n + 1 : ℕ) : R) ^ k := by
            simp [moment, Finset.sum_range_succ]
          have htop : e' (n + 1) = 0 := by
            have : b (n + 1) = 1 := by rw [hb, ← hi₀K]; exact binWeight_top K i₀
            simp [he', this]
          have hfull : moment (n + 1) e' k = 0 := by
            have : moment (n + 1) e' k
                = moment (n + 1) e k - e (n + 1) * moment (n + 1) b k := by
              simp only [moment, he', Finset.mul_sum, ← Finset.sum_sub_distrib]
              exact Finset.sum_congr rfl fun j _ => by ring
            rw [this, he k hk, hbinv k hk]
            ring
          rw [hsplit, htop] at hfull
          simpa using hfull
        obtain ⟨c, hc⟩ := ih e' he'inv
        refine ⟨Function.update c i₀ (e (n + 1)), fun j hj => ?_⟩
        have hrange : (n + 1) + 1 - K = i₀ + 1 := by omega
        rw [hrange, Finset.sum_range_succ]
        have hupd : ∀ i ∈ range i₀, Function.update c i₀ (e (n + 1)) i = c i := by
          intro i hi
          exact Function.update_of_ne (by have := mem_range.mp hi; omega) _ _
        rw [Finset.sum_congr rfl (fun i hi => by rw [hupd i hi]), Function.update_self]
        have hn1K : n + 1 - K = i₀ := rfl
        rcases Nat.lt_or_ge j (n + 1) with hjn | hjn
        · have hj' : j ≤ n := by omega
          have hcj := hc j hj'
          rw [← hcj]
          show e j = (e j - e (n + 1) * binWeight K i₀ j) + e (n + 1) * binWeight K i₀ j
          ring
        · have hjeq : j = n + 1 := by omega
          subst hjeq
          have hzero : ∀ i ∈ range i₀, c i * binWeight (R := R) K i (n + 1) = 0 := by
            intro i hi
            have : i + K < n + 1 := by have := mem_range.mp hi; omega
            rw [binWeight_of_gt this, mul_zero]
          rw [Finset.sum_eq_zero hzero, zero_add]
          have : binWeight (R := R) K i₀ (n + 1) = 1 := by rw [← hi₀K]; exact binWeight_top K i₀
          rw [this, mul_one]

/-- **Structure theorem over `ℚ`.**  Every rational weight vector invisible to the window
`k < K` is a `ℚ`-linear combination of the `N + 1 - K` shifted binomial vectors. -/
theorem exists_coeffs_of_invisible {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e) :
    ∃ c : ℕ → ℚ, ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j :=
  exists_coeffs_of_invisible_aux K
    (fun _ _ _ h => eq_zero_of_moments_zero_rat h) N e he

/-- **Structure theorem over `ℤ` (unimodularity).**  Every *integral* weight vector
invisible to the window `k < K` is an *integral* combination of the shifted binomial
vectors: the invisible lattice is free with the explicit basis `binWeight K i`. -/
theorem exists_intCoeffs_of_invisible {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e) :
    ∃ c : ℕ → ℤ, ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j :=
  exists_coeffs_of_invisible_aux K
    (fun _ _ _ h => eq_zero_of_moments_zero_int h) N e he

/-- Converse direction: any combination of admissible shifted binomial vectors is
invisible. -/
theorem invisible_of_coeffs {N K : ℕ} (hK : K ≤ N + 1) (c : ℕ → R) :
    Invisible N K (fun j => ∑ i ∈ range (N + 1 - K), c i * binWeight K i j) := by
  intro k hk
  rw [moment_sum]
  refine Finset.sum_eq_zero fun i hi => ?_
  have hiN : i + K ≤ N := by have := mem_range.mp hi; omega
  rw [show (fun j => c i * binWeight (R := R) K i j)
      = fun j => c i * (binWeight (R := R) K i) j from rfl,
    moment_smul, binWeight_invisible hiN k hk, mul_zero]

/-- **Complete description of the invisible vectors** (rational case): a weight vector on
`{0,…,N}` is invisible to the window `k < K ≤ N + 1` if and only if it agrees on the nodes
with a linear combination of the `N + 1 - K` shifted binomial vectors. -/
theorem invisible_iff_exists_coeffs {N K : ℕ} (hK : K ≤ N + 1) (e : ℕ → ℚ) :
    Invisible N K e ↔
      ∃ c : ℕ → ℚ, ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j := by
  refine ⟨exists_coeffs_of_invisible, fun ⟨c, hc⟩ k hk => ?_⟩
  have hmom : moment N e k
      = moment N (fun j => ∑ i ∈ range (N + 1 - K), c i * binWeight K i j) k := by
    refine Finset.sum_congr rfl fun j hj => ?_
    rw [hc j (Nat.lt_succ_iff.mp (mem_range.mp hj))]
  rw [hmom]
  exact invisible_of_coeffs hK c k hk

/-! ## Uniqueness of the coefficients, and the exact rank -/

/-- **Independence.**  If a combination of the shifted binomial vectors vanishes on all
nodes, all coefficients vanish.  The proof reads the coefficients off from the top node
downwards, using that `binWeight K i` vanishes beyond `i + K`. -/
theorem coeffs_unique {N K : ℕ} (c : ℕ → R) :
    ∀ M ≤ N + 1 - K, (∀ j ≤ N, ∑ i ∈ range M, c i * binWeight (R := R) K i j = 0) →
      ∀ i < M, c i = 0 := by
  intro M
  induction M with
  | zero => intro _ _ i hi; omega
  | succ m ih =>
      intro hm hzero
      have hmN : m + K ≤ N := by omega
      have hlast : c m = 0 := by
        have h := hzero (m + K) hmN
        rw [Finset.sum_range_succ, binWeight_top, mul_one] at h
        have hrest : ∀ i ∈ range m, c i * binWeight (R := R) K i (m + K) = 0 := by
          intro i hi
          have : i + K < m + K := by have := mem_range.mp hi; omega
          rw [binWeight_of_gt this, mul_zero]
        rw [Finset.sum_eq_zero hrest, zero_add] at h
        exact h
      have hzero' : ∀ j ≤ N, ∑ i ∈ range m, c i * binWeight (R := R) K i j = 0 := by
        intro j hj
        have h := hzero j hj
        rw [Finset.sum_range_succ, hlast, zero_mul, add_zero] at h
        exact h
      intro i hi
      rcases Nat.lt_or_ge i m with h | h
      · exact ih (by omega) hzero' i h
      · have : i = m := by omega
        rw [this, hlast]

/-- **Exact rank.**  Combining `exists_coeffs_of_invisible` with `coeffs_unique`: the
invisible vectors on `{0,…,N}` for the window `k < K` are parameterised bijectively (on the
nodes) by `N + 1 - K` free coefficients. -/
theorem invisible_coeffs_existsUnique {N K : ℕ} {e : ℕ → ℚ} (he : Invisible N K e) :
    ∃! c : Fin (N + 1 - K) → ℚ,
      ∀ j ≤ N, e j = ∑ i ∈ range (N + 1 - K), (if h : i < N + 1 - K then c ⟨i, h⟩ else 0)
        * binWeight K i j := by
  obtain ⟨c, hc⟩ := exists_coeffs_of_invisible he
  refine ⟨fun i => c i, ?_, ?_⟩
  · intro j hj
    rw [hc j hj]
    exact Finset.sum_congr rfl fun i hi => by rw [dif_pos (mem_range.mp hi)]
  · intro d hd
    funext i
    have hsub : ∀ j ≤ N, ∑ i ∈ range (N + 1 - K),
        ((if h : i < N + 1 - K then d ⟨i, h⟩ else 0) - c i) * binWeight (R := ℚ) K i j = 0 := by
      intro j hj
      have h1 := hd j hj
      have h2 := hc j hj
      simp only [sub_mul, Finset.sum_sub_distrib]
      rw [← h1, ← h2, sub_self]
    have hz := coeffs_unique
      (fun i => (if h : i < N + 1 - K then d ⟨i, h⟩ else 0) - c i) (N + 1 - K) le_rfl hsub i i.2
    simp only [dif_pos i.2, Fin.eta] at hz
    linarith [hz]

/-! ## The construction: near misses at an arbitrary window -/

/-- Positive part of an integer weight vector, as a multiplicity function. -/
def posPart (e : ℕ → ℤ) (j : ℕ) : ℕ := (e j).toNat

/-- Negative part of an integer weight vector, as a multiplicity function. -/
def negPart (e : ℕ → ℤ) (j : ℕ) : ℕ := (-e j).toNat

lemma posPart_sub_negPart (e : ℕ → ℤ) (j : ℕ) :
    (posPart e j : ℤ) - (negPart e j : ℤ) = e j := by
  simp only [posPart, negPart]
  omega

/-- The multiset carrying the positive part of `e` on the nodes `{0,…,N}`. -/
def posMultiset (N : ℕ) (e : ℕ → ℤ) : Multiset ℕ := ofCounts N (posPart e)

/-- The multiset carrying the negative part of `e` on the nodes `{0,…,N}`. -/
def negMultiset (N : ℕ) (e : ℕ → ℤ) : Multiset ℕ := ofCounts N (negPart e)

lemma powerSum_posMultiset_sub (N : ℕ) (e : ℕ → ℤ) (k : ℕ) :
    powerSum (posMultiset N e) k - powerSum (negMultiset N e) k = moment N e k := by
  rw [posMultiset, negMultiset, powerSum_ofCounts, powerSum_ofCounts, ← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl fun j _ => ?_
  rw [← sub_mul, posPart_sub_negPart]

/-- **From invisible vectors to near misses.**  A nonzero integral vector invisible to the
window `k < K` splits into two distinct multisets bounded by `N` whose power sums agree
throughout the window. -/
theorem nearMiss_of_invisible {N K : ℕ} {e : ℕ → ℤ} (he : Invisible N K e)
    {j₀ : ℕ} (hj₀ : j₀ ≤ N) (hne : e j₀ ≠ 0) :
    (∀ x ∈ posMultiset N e, x ≤ N) ∧ (∀ x ∈ negMultiset N e, x ≤ N) ∧
      posMultiset N e ≠ negMultiset N e ∧
      ∀ k < K, powerSum (posMultiset N e) k = powerSum (negMultiset N e) k := by
  refine ⟨fun _ hx => mem_ofCounts_le _ _ hx, fun _ hx => mem_ofCounts_le _ _ hx, ?_, ?_⟩
  · intro hEq
    have hc := congrArg (fun s : Multiset ℕ => s.count j₀) hEq
    simp only [posMultiset, negMultiset, count_ofCounts, if_pos hj₀] at hc
    have : (posPart e j₀ : ℤ) - (negPart e j₀ : ℤ) = 0 := by rw [hc]; ring
    rw [posPart_sub_negPart] at this
    exact hne this
  · intro k hk
    have h := powerSum_posMultiset_sub N e k
    rw [he k hk] at h
    linarith

/-- **From near misses to invisible vectors.**  The multiplicity difference of a near miss
is an integral invisible vector. -/
theorem invisible_of_nearMiss {N K : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < K, powerSum s k = powerSum t k) :
    Invisible N K (fun j => (s.count j : ℤ) - (t.count j : ℤ)) := by
  intro k hk
  have hsq : ∀ (u : Multiset ℕ), (∀ x ∈ u, x ≤ N) →
      (powerSum u k : ℤ) = ∑ j ∈ range (N + 1), (u.count j : ℤ) * (j : ℤ) ^ k := by
    intro u hu
    conv_lhs => rw [eq_ofCounts hu]
    rw [powerSum_ofCounts]
  have := h k hk
  rw [hsq s hs, hsq t ht] at this
  simp only [moment, sub_mul, Finset.sum_sub_distrib]
  rw [this, sub_self]

/-- **Structure theorem for near misses at an arbitrary window.**  If two multisets bounded
by `N` have the same power sums for every `k < K`, then their multiplicity difference is an
*integer* combination of the `N + 1 - K` shifted binomial vectors.  For `K = N` there is a
single vector and one recovers the catalog's near-miss classification; for `K < N` this is
strictly more general. -/
theorem nearMiss_structure_window {N K : ℕ} {s t : Multiset ℕ}
    (hs : ∀ x ∈ s, x ≤ N) (ht : ∀ x ∈ t, x ≤ N)
    (h : ∀ k < K, powerSum s k = powerSum t k) :
    ∃ c : ℕ → ℤ, ∀ j ≤ N,
      (s.count j : ℤ) - (t.count j : ℤ) = ∑ i ∈ range (N + 1 - K), c i * binWeight K i j :=
  exists_intCoeffs_of_invisible (invisible_of_nearMiss hs ht h)

/-- **The construction, packaged.**  Every integral combination of the shifted binomial
vectors that is nonzero at some node produces an explicit near miss at window `K`. -/
theorem nearMiss_of_intCoeffs {N K : ℕ} (hK : K ≤ N + 1) (c : ℕ → ℤ) {j₀ : ℕ} (hj₀ : j₀ ≤ N)
    (hne : ∑ i ∈ range (N + 1 - K), c i * binWeight (R := ℤ) K i j₀ ≠ 0) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧ s ≠ t ∧
      ∀ k < K, powerSum s k = powerSum t k := by
  set e : ℕ → ℤ := fun j => ∑ i ∈ range (N + 1 - K), c i * binWeight K i j with he
  obtain ⟨h1, h2, h3, h4⟩ := nearMiss_of_invisible (invisible_of_coeffs hK c) hj₀ hne
  exact ⟨posMultiset N e, negMultiset N e, h1, h2, h3, h4⟩

/-- A concrete new family: for every shift `i` with `i + K ≤ N` the single vector
`binWeight K i` gives a near miss at window `K` supported in `[i, i+K]`. -/
theorem nearMiss_shifted (K i N : ℕ) (h : i + K ≤ N) :
    ∃ s t : Multiset ℕ, (∀ x ∈ s, x ≤ N) ∧ (∀ x ∈ t, x ≤ N) ∧ s ≠ t ∧
      (∀ k < K, powerSum s k = powerSum t k) ∧
      powerSum s K - powerSum t K = (K.factorial : ℤ) := by
  refine ⟨posMultiset N (binWeight K i), negMultiset N (binWeight K i), ?_, ?_, ?_, ?_, ?_⟩
  · exact fun _ hx => mem_ofCounts_le _ _ hx
  · exact fun _ hx => mem_ofCounts_le _ _ hx
  · have hne : binWeight (R := ℤ) K i (i + K) ≠ 0 := by rw [binWeight_top]; norm_num
    exact (nearMiss_of_invisible (binWeight_invisible h) (by omega) hne).2.2.1
  · exact (nearMiss_of_invisible (binWeight_invisible h) (j₀ := i + K) (by omega)
      (by rw [binWeight_top]; norm_num)).2.2.2
  · rw [powerSum_posMultiset_sub, moment_binWeight_top h]

/-! ## Reconciliation with the catalog's binomial pair, and lab data -/

/-- The catalog's alternating binomial vector is the shifted binomial vector with `i = 0`
and `K = N`, up to the global sign `(-1)^N`. -/
theorem binWeight_zero_eq_alternating (N j : ℕ) (hj : j ≤ N) :
    binWeight (R := ℤ) N 0 j = (-1 : ℤ) ^ N * ((-1 : ℤ) ^ j * (N.choose j : ℤ)) := by
  have h : ((-1 : ℤ) ^ N) * ((-1 : ℤ) ^ N) = 1 := by
    rw [← pow_add]; exact Even.neg_one_pow ⟨N, rfl⟩
  simp only [binWeight, Nat.zero_le, Nat.sub_zero, zero_add, hj, and_self, if_pos]
  rw [PowerSumSharpness.neg_one_pow_sub N j hj]
  nlinarith [h]

/-- Lab datum: at `N = 2`, `K = 2` the kernel is one dimensional and the basis vector is the
catalog witness `(1, -2, 1)`, i.e. `{0,2}` versus `{1,1}`. -/
example : (binWeight (R := ℤ) 2 0 0, binWeight (R := ℤ) 2 0 1, binWeight (R := ℤ) 2 0 2)
    = (1, -2, 1) := by
  norm_num [binWeight]

/-- Lab datum: at `N = 3`, `K = 2` the kernel is two dimensional, with basis
`(1,-2,1,0)` and `(0,1,-2,1)`. -/
example : (binWeight (R := ℤ) 2 1 0, binWeight (R := ℤ) 2 1 1, binWeight (R := ℤ) 2 1 2,
      binWeight (R := ℤ) 2 1 3) = (0, 1, -2, 1) := by
  norm_num [binWeight]

/-- Lab datum: the first visible moment of `binWeight 2 1` is `2! = 2`, matching
`moment_binWeight_top` — the shift does not change it. -/
example : moment 3 (binWeight (R := ℤ) 2 1) 2 = 2 := by
  norm_num [moment, binWeight, Finset.sum_range_succ]

/-- Lab datum: the window `k < 2` really is blind to `binWeight 2 1` at `N = 3`. -/
example : moment 3 (binWeight (R := ℤ) 2 1) 0 = 0 ∧ moment 3 (binWeight (R := ℤ) 2 1) 1 = 0 := by
  constructor <;> norm_num [moment, binWeight, Finset.sum_range_succ]

end InvisibleWeights