import Bridges.MolienQSeriesRigidity

/-!
# Conjecture D5: effective (constructive) Molien reconstruction and the peeling recursion

`Catalog/Bridges/MolienQSeriesRigidity.lean` settles Conjecture D: for a finite group `G`
acting on a finite set `X`, the fixed-point q-series and the orbit-counting generating
function determine each other (the converse using only the first `|X| + 1` orbit counts).
That converse is a *uniqueness* statement, obtained from Lagrange interpolation.  This file
upgrades it to two *effective* statements, the content of Conjecture D5 of
`FUTURE_DIRECTIONS.md`:

* **Linear reconstruction** (`fixDensity_reconstruction`).  There is a fixed rational matrix
  `reconCoeff N`, with entries `reconEntry N v n` — the inverse of the Vandermonde/moment
  matrix on the nodes `0,1,…,N`, depending on nothing but `N = |X|` — with
  `ρ_{G,X}(v) = ∑_{n ≤ N} reconEntry N v n · N_{G,X}(n)`.
  So the normalised fixed-point distribution is an explicit *linear* functional of finitely
  many orbit counts, uniformly in the action.

* **Peeling recursion** (`fixDensity_peel`, `fixDensity_zero_eq`).  The densities can also be
  read off one value at a time, from the top down, as limits:
  `ρ_{G,X}(m) = lim_{n→∞} (N_{G,X}(n) − ∑_{v > m} ρ_{G,X}(v)·vⁿ) / mⁿ` for `1 ≤ m ≤ |X|`,
  while `ρ_{G,X}(0)` is fixed by the total mass being `1`.  This is the "positive combinations
  of exponentials are dominated by the largest base" mechanism that the kernel bounds
  (`kernel_le_burnside`, `burnside_le_kernel_add`) exhibit in the top degree, here run in
  every degree.

* **Quantitative peeling and an exact finite algorithm** (`peel_error_bound`,
  `peelEstimate_error`, `fixFiberCard_eq_round_peelEstimate`, `exists_peel_stopping_time`).
  The peeling limit converges geometrically with the explicit rate `((m-1)/m)ⁿ`, and since the
  densities have denominator dividing `|G|`, rounding `|G| · (peeled estimate)` returns the
  fibre cardinality `#{g : |X^g| = m}` *exactly* as soon as `((m-1)/m)ⁿ · 2|G| < 1` — which
  happens for some `n`.  So the limit is genuinely a terminating computation.

Together they turn Conjecture D from a uniqueness theorem into an algorithm.
-/

namespace MolienRigidity

open MulAction Finset Filter Topology

/-! ## Part 1: the moment (Vandermonde) matrix on the nodes `0,1,…,N` -/

section Vandermonde

/-- The moment matrix on the nodes `0,1,…,N`: `momentMatrix N n j = jⁿ`.  It is the transpose
of the Vandermonde matrix of the nodes, so it is invertible. -/
noncomputable def momentMatrix (N : ℕ) : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ :=
  fun n j => (j : ℚ) ^ (n : ℕ)

theorem momentMatrix_transpose (N : ℕ) :
    (momentMatrix N).transpose = Matrix.vandermonde (fun j : Fin (N + 1) => (j : ℚ)) := rfl

/-- The nodes `0,1,…,N`, viewed in `ℚ`, are pairwise distinct. -/
theorem node_injective (N : ℕ) : Function.Injective (fun j : Fin (N + 1) => (j : ℚ)) := by
  intro a b hab
  have hab' : ((a : ℕ) : ℚ) = ((b : ℕ) : ℚ) := hab
  exact Fin.ext (by exact_mod_cast hab')

theorem momentMatrix_det_ne_zero (N : ℕ) : (momentMatrix N).det ≠ 0 := by
  rw [← Matrix.det_transpose, momentMatrix_transpose]
  exact Matrix.det_vandermonde_ne_zero_iff.mpr (node_injective N)

/-- The **reconstruction coefficients**: the inverse of the moment matrix on `0,1,…,N`.
They depend only on `N`. -/
noncomputable def reconCoeff (N : ℕ) : Matrix (Fin (N + 1)) (Fin (N + 1)) ℚ :=
  (momentMatrix N)⁻¹

/-- **Explicit inversion of the moment map.**  Any weight vector supported on the nodes
`0,1,…,N` is recovered from its first `N+1` weighted power sums by the fixed linear
transformation `reconCoeff N`. -/
theorem weight_eq_recon (N : ℕ) (w : Fin (N + 1) → ℚ) (i : Fin (N + 1)) :
    w i = ∑ n : Fin (N + 1), reconCoeff N i n * ∑ j : Fin (N + 1), w j * (j : ℚ) ^ (n : ℕ) := by
  have hmv : (momentMatrix N).mulVec w
      = fun n : Fin (N + 1) => ∑ j : Fin (N + 1), w j * (j : ℚ) ^ (n : ℕ) := by
    funext n
    simp only [Matrix.mulVec, dotProduct, momentMatrix]
    exact Finset.sum_congr rfl fun j _ => mul_comm _ _
  have hinv : (reconCoeff N).mulVec ((momentMatrix N).mulVec w) = w := by
    rw [Matrix.mulVec_mulVec, reconCoeff,
      Matrix.nonsing_inv_mul _ (Ne.isUnit (momentMatrix_det_ne_zero N)), Matrix.one_mulVec]
  have := congrFun hinv i
  rw [hmv] at this
  rw [← this]
  simp only [Matrix.mulVec, dotProduct]

end Vandermonde

/-! ## Part 2: effective reconstruction of the fixed-point density from orbit counts -/

section Effective

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

theorem card_group_pos : (0 : ℚ) < (Fintype.card G : ℚ) := by
  have : 0 < Fintype.card G := Fintype.card_pos_iff.mpr (One.instNonempty (α := G))
  exact_mod_cast this

omit [Fintype G] in
/-- The fixed-point counts of `G` on `X` all lie in `{0,1,…,|X|}`. -/
theorem fixCount_mem_range (g : G) : fixCount G X g ∈ Finset.range (Nat.card X + 1) := by
  have := fixCount_le G X g
  simp only [Finset.mem_range]
  omega

/-- Burnside in normalised, node-indexed form: the `n`-th orbit count is the `n`-th moment of
the density supported on the nodes `0,1,…,|X|`. -/
theorem orbitCount_eq_moment (n : ℕ) :
    (orbitCount G X n : ℚ)
      = ∑ v ∈ Finset.range (Nat.card X + 1), fixDensity G X v * (v : ℚ) ^ n :=
  (sum_fixDensity_pow G X _ (fixCount_mem_range G X) n).symm

/-- **Effective form of Conjecture D.**  The normalised fixed-point distribution is an explicit
linear functional of the first `|X| + 1` orbit counts, with coefficients `reconEntry |X|`
depending only on `|X|` — not on the group, the action, or even on `|G|`. -/
theorem fixDensity_reconstruction_fin (v : Fin (Nat.card X + 1)) :
    fixDensity G X v
      = ∑ n : Fin (Nat.card X + 1),
          reconCoeff (Nat.card X) v n * (orbitCount G X (n : ℕ) : ℚ) := by
  have hmom : ∀ n : Fin (Nat.card X + 1),
      (∑ j : Fin (Nat.card X + 1), fixDensity G X (j : ℕ) * (j : ℚ) ^ (n : ℕ))
        = (orbitCount G X (n : ℕ) : ℚ) := by
    intro n
    rw [orbitCount_eq_moment G X (n : ℕ), Fin.sum_univ_eq_sum_range
      (fun j => fixDensity G X j * (j : ℚ) ^ (n : ℕ))]
  have := weight_eq_recon (Nat.card X) (fun j : Fin (Nat.card X + 1) => fixDensity G X (j : ℕ)) v
  simpa only [hmom] using this

/-- `ℕ`-indexed version of the reconstruction coefficients (zero outside the range). -/
noncomputable def reconEntry (N v n : ℕ) : ℚ :=
  if hv : v < N + 1 then if hn : n < N + 1 then reconCoeff N ⟨v, hv⟩ ⟨n, hn⟩ else 0 else 0

/-- **Effective form of Conjecture D, `ℕ`-indexed.**  For every admissible value `v`,
`ρ_{G,X}(v) = ∑_{n ≤ |X|} reconEntry |X| v n · N_{G,X}(n)`, an explicit universal linear
formula for the fixed-point density in terms of finitely many orbit counts. -/
theorem fixDensity_reconstruction (v : ℕ) (hv : v ≤ Nat.card X) :
    fixDensity G X v
      = ∑ n ∈ Finset.range (Nat.card X + 1),
          reconEntry (Nat.card X) v n * (orbitCount G X n : ℚ) := by
  have hv' : v < Nat.card X + 1 := by omega
  have hfin := fixDensity_reconstruction_fin G X ⟨v, hv'⟩
  rw [Fin.sum_univ_eq_sum_range
    (fun n => reconEntry (Nat.card X) v n * (orbitCount G X n : ℚ)) (Nat.card X + 1) |>.symm]
  rw [hfin]
  refine Finset.sum_congr rfl fun n _ => ?_
  rw [reconEntry, dif_pos hv', dif_pos n.isLt]

/-- The zeroth orbit count is `1`: there is exactly one orbit of empty tuples. -/
theorem orbitCount_zero : orbitCount G X 0 = 1 := by
  have h := burnside_moment_rat G X 0
  simp only [pow_zero, Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_one] at h
  have hG := card_group_pos G
  have h1 : (orbitCount G X 0 : ℚ) = 1 := by
    field_simp at h
    exact_mod_cast h
  exact_mod_cast h1

/-- The fixed-point density is a probability distribution on `{0,1,…,|X|}`. -/
theorem sum_fixDensity_eq_one :
    ∑ v ∈ Finset.range (Nat.card X + 1), fixDensity G X v = 1 := by
  have h := orbitCount_eq_moment G X 0
  rw [orbitCount_zero G X] at h
  simpa using h.symm

/-- The mass at `0` is determined by the remaining masses. -/
theorem fixDensity_zero_eq :
    fixDensity G X 0 = 1 - ∑ v ∈ Finset.Icc 1 (Nat.card X), fixDensity G X v := by
  have hsplit : Finset.range (Nat.card X + 1)
      = insert 0 (Finset.Icc 1 (Nat.card X)) := by
    ext v; simp only [Finset.mem_range, Finset.mem_insert, Finset.mem_Icc]; omega
  have hnot : (0 : ℕ) ∉ Finset.Icc 1 (Nat.card X) := by simp
  have h := sum_fixDensity_eq_one G X
  rw [hsplit, Finset.sum_insert hnot] at h
  linarith

end Effective

/-! ## Part 3: the peeling recursion -/

section Peeling

/-- **Peeling step (analytic core).**  For any weights supported on `{0,1,…,m}` with `m ≥ 1`,
dividing the moment `∑_{v ≤ m} w(v) vⁿ` by `mⁿ` isolates the top weight in the limit: all the
lower nodes contribute geometrically decaying terms `(v/m)ⁿ`. -/
theorem peel_tendsto (m : ℕ) (hm : 1 ≤ m) (w : ℕ → ℝ) :
    Tendsto (fun n => (∑ v ∈ Finset.range (m + 1), w v * (v : ℝ) ^ n) / (m : ℝ) ^ n)
      atTop (nhds (w m)) := by
  have hmpos : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hrw : ∀ n : ℕ, (∑ v ∈ Finset.range (m + 1), w v * (v : ℝ) ^ n) / (m : ℝ) ^ n
      = (∑ v ∈ Finset.range m, w v * ((v : ℝ) / (m : ℝ)) ^ n) + w m := by
    intro n
    rw [Finset.sum_range_succ, add_div, Finset.sum_div]
    have h1 : ∀ v ∈ Finset.range m, w v * (v : ℝ) ^ n / (m : ℝ) ^ n
        = w v * ((v : ℝ) / (m : ℝ)) ^ n := by
      intro v _
      rw [div_pow]; ring
    rw [Finset.sum_congr rfl h1]
    congr 1
    rw [mul_div_assoc, div_self (by positivity), mul_one]
  simp only [hrw]
  have hzero : Tendsto (fun n => ∑ v ∈ Finset.range m, w v * ((v : ℝ) / (m : ℝ)) ^ n)
      atTop (nhds 0) := by
    have : Tendsto (fun n => ∑ v ∈ Finset.range m, w v * ((v : ℝ) / (m : ℝ)) ^ n)
        atTop (nhds (∑ _v ∈ Finset.range m, (0 : ℝ))) := by
      refine tendsto_finset_sum _ fun v hv => ?_
      have hvm : (v : ℝ) / (m : ℝ) < 1 := by
        rw [div_lt_one hmpos]
        exact_mod_cast Finset.mem_range.mp hv
      have hv0 : (0 : ℝ) ≤ (v : ℝ) / (m : ℝ) := by positivity
      have := (tendsto_pow_atTop_nhds_zero_of_lt_one hv0 hvm).const_mul (w v)
      simpa using this
    simpa using this
  simpa using hzero.add (tendsto_const_nhds (x := w m))

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

/-- Splitting the moment sum at a threshold `m ≤ |X|`. -/
theorem orbitCount_sub_high (m : ℕ) (hmX : m ≤ Nat.card X) (n : ℕ) :
    (orbitCount G X n : ℚ) - ∑ v ∈ Finset.Ioc m (Nat.card X), fixDensity G X v * (v : ℚ) ^ n
      = ∑ v ∈ Finset.range (m + 1), fixDensity G X v * (v : ℚ) ^ n := by
  have hunion : Finset.range (Nat.card X + 1)
      = Finset.range (m + 1) ∪ Finset.Ioc m (Nat.card X) := by
    ext v
    simp only [Finset.mem_range, Finset.mem_union, Finset.mem_Ioc]
    omega
  have hdisj : Disjoint (Finset.range (m + 1)) (Finset.Ioc m (Nat.card X)) := by
    rw [Finset.disjoint_left]
    intro v hv hv'
    simp only [Finset.mem_range] at hv
    simp only [Finset.mem_Ioc] at hv'
    omega
  have h := orbitCount_eq_moment G X n
  rw [hunion, Finset.sum_union hdisj] at h
  rw [h]
  ring

/-- **The peeling recursion (Conjecture D5).**  For every `1 ≤ m ≤ |X|`, the density at `m` is
recovered as a limit from the orbit counts and the already-known densities at the larger
values.  Together with `fixDensity_zero_eq` (which fixes the mass at `0` from the total mass
`1`) this is a downward algorithm reconstructing the whole fixed-point distribution — and hence
the fixed-point q-series, up to the normalisation that `normalisation_necessary` shows is
unavoidable — from the orbit-counting generating function. -/
theorem fixDensity_peel (m : ℕ) (hm : 1 ≤ m) (hmX : m ≤ Nat.card X) :
    Tendsto (fun n => ((orbitCount G X n : ℝ)
        - ∑ v ∈ Finset.Ioc m (Nat.card X), (fixDensity G X v : ℝ) * (v : ℝ) ^ n) / (m : ℝ) ^ n)
      atTop (nhds ((fixDensity G X m : ℚ) : ℝ)) := by
  have hcast : ∀ n : ℕ, ((orbitCount G X n : ℝ)
      - ∑ v ∈ Finset.Ioc m (Nat.card X), (fixDensity G X v : ℝ) * (v : ℝ) ^ n)
      = ∑ v ∈ Finset.range (m + 1), ((fixDensity G X v : ℚ) : ℝ) * (v : ℝ) ^ n := by
    intro n
    have h := orbitCount_sub_high G X m hmX n
    have := congrArg (fun q : ℚ => (q : ℝ)) h
    push_cast at this
    exact this
  simp only [hcast]
  exact peel_tendsto m hm (fun v => ((fixDensity G X v : ℚ) : ℝ))

/-- **The top peeling step is the kernel proportion.**  Specialising `fixDensity_peel` at
`m = |X|` (where there is nothing above to subtract) recovers, in limit form, the kernel
asymptotics of `kernel_le_burnside` / `burnside_le_kernel_add`. -/
theorem kernel_density_limit (hX : 1 ≤ Nat.card X) :
    Tendsto (fun n => (orbitCount G X n : ℝ) / (Nat.card X : ℝ) ^ n)
      atTop (nhds ((kernelCard G X : ℚ) / (Fintype.card G : ℚ) : ℚ)) := by
  have h := fixDensity_peel G X (Nat.card X) hX le_rfl
  simp only [Finset.Ioc_self, Finset.sum_empty, sub_zero] at h
  rwa [fixDensity_card_eq G X] at h

end Peeling

/-! ## Part 5: quantitative peeling — an exact finite reconstruction algorithm -/

section Quantitative

/-- **Explicit error bound for one peeling step.**  For nonnegative weights on `{0,…,m}` whose
lower part has total mass at most `1`, the `n`-th peeled quotient approximates the top weight
with geometric error `((m-1)/m)ⁿ`. -/
theorem peel_error_bound (m : ℕ) (hm : 1 ≤ m) (w : ℕ → ℚ) (hw : ∀ v, 0 ≤ w v)
    (hsum : ∑ v ∈ Finset.range m, w v ≤ 1) (n : ℕ) :
    |(∑ v ∈ Finset.range (m + 1), w v * (v : ℚ) ^ n) / (m : ℚ) ^ n - w m|
      ≤ (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
  have hmpos : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hdiff : (∑ v ∈ Finset.range (m + 1), w v * (v : ℚ) ^ n) / (m : ℚ) ^ n - w m
      = ∑ v ∈ Finset.range m, w v * ((v : ℚ) / (m : ℚ)) ^ n := by
    rw [Finset.sum_range_succ, add_div, Finset.sum_div]
    have h1 : ∀ v ∈ Finset.range m, w v * (v : ℚ) ^ n / (m : ℚ) ^ n
        = w v * ((v : ℚ) / (m : ℚ)) ^ n := fun v _ => by rw [div_pow]; ring
    rw [Finset.sum_congr rfl h1, mul_div_assoc, div_self (by positivity), mul_one]
    ring
  have hratio : ∀ v ∈ Finset.range m, w v * ((v : ℚ) / (m : ℚ)) ^ n
      ≤ w v * (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
    intro v hv
    have hvm : (v : ℚ) ≤ (m : ℚ) - 1 := by
      have : (v : ℕ) + 1 ≤ m := Finset.mem_range.mp hv
      have : ((v : ℕ) : ℚ) + 1 ≤ (m : ℚ) := by exact_mod_cast this
      linarith
    have h0 : (0 : ℚ) ≤ (v : ℚ) / (m : ℚ) := by positivity
    have hle : (v : ℚ) / (m : ℚ) ≤ ((m : ℚ) - 1) / (m : ℚ) := by
      gcongr
    exact mul_le_mul_of_nonneg_left (pow_le_pow_left₀ h0 hle n) (hw v)
  have hnonneg : (0 : ℚ) ≤ ∑ v ∈ Finset.range m, w v * ((v : ℚ) / (m : ℚ)) ^ n :=
    Finset.sum_nonneg fun v _ =>
      mul_nonneg (hw v) (pow_nonneg (by positivity) n)
  have hbnd : (0 : ℚ) ≤ (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
    have h1m : (1 : ℚ) ≤ (m : ℚ) := by exact_mod_cast hm
    exact pow_nonneg (div_nonneg (by linarith) (le_of_lt hmpos)) n
  have hupper : ∑ v ∈ Finset.range m, w v * ((v : ℚ) / (m : ℚ)) ^ n
      ≤ (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
    calc ∑ v ∈ Finset.range m, w v * ((v : ℚ) / (m : ℚ)) ^ n
        ≤ ∑ v ∈ Finset.range m, w v * (((m : ℚ) - 1) / (m : ℚ)) ^ n :=
          Finset.sum_le_sum hratio
      _ = (∑ v ∈ Finset.range m, w v) * (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
          rw [← Finset.sum_mul]
      _ ≤ 1 * (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
          exact mul_le_mul_of_nonneg_right hsum hbnd
      _ = (((m : ℚ) - 1) / (m : ℚ)) ^ n := one_mul _
  rw [hdiff, abs_le]
  exact ⟨by linarith, hupper⟩

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]

omit [Finite X] in
theorem fixDensity_nonneg (v : ℕ) : 0 ≤ fixDensity G X v := by
  unfold fixDensity
  positivity

/-- Partial masses of a probability distribution are at most `1`. -/
theorem sum_fixDensity_range_le_one (m : ℕ) (hm : m ≤ Nat.card X + 1) :
    ∑ v ∈ Finset.range m, fixDensity G X v ≤ 1 := by
  rw [← sum_fixDensity_eq_one G X]
  refine Finset.sum_le_sum_of_subset_of_nonneg ?_ fun v _ _ => fixDensity_nonneg G X v
  intro v hv
  simp only [Finset.mem_range] at hv ⊢
  omega

/-- The `n`-th peeled estimate of the density at `m`: the orbit count with the contributions of
the larger values removed, rescaled by `mⁿ`. -/
noncomputable def peelEstimate (m n : ℕ) : ℚ :=
  ((orbitCount G X n : ℚ)
    - ∑ v ∈ Finset.Ioc m (Nat.card X), fixDensity G X v * (v : ℚ) ^ n) / (m : ℚ) ^ n

/-- **Quantitative peeling (Conjecture D7, error bound).**  The peeling limit converges
geometrically, with the completely explicit rate `((m-1)/m)ⁿ`. -/
theorem peelEstimate_error (m : ℕ) (hm : 1 ≤ m) (hmX : m ≤ Nat.card X) (n : ℕ) :
    |peelEstimate G X m n - fixDensity G X m| ≤ (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
  rw [peelEstimate, orbitCount_sub_high G X m hmX n]
  exact peel_error_bound m hm (fixDensity G X) (fixDensity_nonneg G X)
    (sum_fixDensity_range_le_one G X m (by omega)) n

/-- **Exact finite reconstruction (Conjecture D7, algorithmic form).**  Once the geometric error
falls below `1/(2|G|)`, rounding the rescaled peeled estimate returns the fibre cardinality
`#{g : |X^g| = m}` *exactly*: the limit becomes a terminating computation, because the densities
have denominator dividing `|G|`. -/
theorem fixFiberCard_eq_round_peelEstimate (m : ℕ) (hm : 1 ≤ m) (hmX : m ≤ Nat.card X) (n : ℕ)
    (hn : (((m : ℚ) - 1) / (m : ℚ)) ^ n * (2 * (Fintype.card G : ℚ)) < 1) :
    (fixFiberCard G X m : ℤ) = round ((Fintype.card G : ℚ) * peelEstimate G X m n) := by
  have hGpos := card_group_pos G
  have herr := peelEstimate_error G X m hm hmX n
  have hscale : |(Fintype.card G : ℚ) * peelEstimate G X m n - (fixFiberCard G X m : ℚ)|
      < 1 / 2 := by
    have hfd : (Fintype.card G : ℚ) * fixDensity G X m = (fixFiberCard G X m : ℚ) := by
      rw [fixDensity]
      field_simp
    have : |(Fintype.card G : ℚ) * peelEstimate G X m n
        - (Fintype.card G : ℚ) * fixDensity G X m|
        ≤ (Fintype.card G : ℚ) * (((m : ℚ) - 1) / (m : ℚ)) ^ n := by
      rw [← mul_sub, abs_mul, abs_of_pos hGpos]
      exact mul_le_mul_of_nonneg_left herr (le_of_lt hGpos)
    rw [hfd] at this
    nlinarith [this]
  have h1 : (Fintype.card G : ℚ) * peelEstimate G X m n - 1 / 2 < (fixFiberCard G X m : ℚ) := by
    have := (abs_lt.mp hscale).2; linarith
  have h2 : ((fixFiberCard G X m : ℚ)) < (Fintype.card G : ℚ) * peelEstimate G X m n + 1 / 2 := by
    have := (abs_lt.mp hscale).1; linarith
  rw [round_eq, eq_comm, Int.floor_eq_iff]
  constructor <;> push_cast <;> linarith

/-- **The stopping rule always triggers.**  For `m ≥ 2` there is an explicit `n` at which
`fixFiberCard_eq_round_peelEstimate` applies, so the whole distribution — and hence the
fixed-point q-series up to the unavoidable normalisation — is computed from finitely many orbit
counts.  (For `m = 1` the error term is `0ⁿ`, so `n = 1` already works.) -/
theorem exists_peel_stopping_time (m : ℕ) (hm : 1 ≤ m) :
    ∃ n, (((m : ℚ) - 1) / (m : ℚ)) ^ n * (2 * (Fintype.card G : ℚ)) < 1 := by
  have hGpos := card_group_pos G
  have hmpos : (0 : ℚ) < (m : ℚ) := by exact_mod_cast hm
  have hlt : ((m : ℚ) - 1) / (m : ℚ) < 1 := by
    rw [div_lt_one hmpos]; linarith
  obtain ⟨n, hn⟩ := exists_pow_lt_of_lt_one
    (x := 1 / (2 * (Fintype.card G : ℚ))) (y := ((m : ℚ) - 1) / (m : ℚ)) (by positivity) hlt
  refine ⟨n, ?_⟩
  rw [lt_div_iff₀ (by positivity)] at hn
  linarith

end Quantitative

/-! ## Part 4: consequences — a second proof of the converse, and a separation criterion -/

section Consequences

variable (G : Type*) [Group G] [Fintype G] (X : Type*) [MulAction G X] [Finite X]
variable (H : Type*) [Group H] [Fintype H] (Y : Type*) [MulAction H Y] [Finite Y]

/-- **Reconstruction implies rigidity.**  A second, constructive proof of the converse
direction of Conjecture D for actions on sets of equal size: equal orbit counts in the first
`|X| + 1` degrees force equal densities, because both sides are the *same* explicit linear
functional of those counts. -/
theorem fixDensity_eq_of_orbitCount_eq_recon (hXY : Nat.card X = Nat.card Y)
    (h : ∀ n ≤ Nat.card X, orbitCount G X n = orbitCount H Y n) :
    ∀ v, fixDensity G X v = fixDensity H Y v := by
  intro v
  by_cases hv : v ≤ Nat.card X
  · have hG := fixDensity_reconstruction G X v hv
    have hH := fixDensity_reconstruction H Y v (hXY ▸ hv)
    rw [← hXY] at hH
    rw [hG, hH]
    refine Finset.sum_congr rfl fun n hn => ?_
    rw [h n (by simpa [Nat.lt_succ_iff] using Finset.mem_range.mp hn)]
  · have h1 : fixDensity G X v = 0 := by
      have hemp : ((Finset.univ : Finset G).filter fun g => fixCount G X g = v) = ∅ :=
        Finset.filter_eq_empty_iff.mpr fun g _ hg => by
          have := fixCount_le G X g; omega
      simp [fixDensity, fixFiberCard, hemp]
    have h2 : fixDensity H Y v = 0 := by
      have hemp : ((Finset.univ : Finset H).filter fun h => fixCount H Y h = v) = ∅ :=
        Finset.filter_eq_empty_iff.mpr fun g _ hg => by
          have := fixCount_le H Y g; omega
      simp [fixDensity, fixFiberCard, hemp]
    rw [h1, h2]

/-- **Quantitative separation.**  If two actions have different densities at some value, the
orbit counts must already differ in one of the first `|X| + 1` degrees; the reconstruction
formula turns this into a bound on where to look. -/
theorem separation_of_fixDensity_ne (hXY : Nat.card X = Nat.card Y) {v : ℕ}
    (hne : fixDensity G X v ≠ fixDensity H Y v) :
    ∃ n ≤ Nat.card X, orbitCount G X n ≠ orbitCount H Y n := by
  by_contra hcon
  push_neg at hcon
  exact hne (fixDensity_eq_of_orbitCount_eq_recon G X H Y hXY hcon v)

end Consequences

end MolienRigidity