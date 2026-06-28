import Mathlib

/-!
# The 1-Wasserstein distance on the discrete line

We formalize the *1-Wasserstein distance* (a.k.a. earth–mover's / Kantorovich
distance with the standard ground metric `d(i,j) = |i - j|`) between finitely
supported probability distributions on the integer line `{0, 1, …, n-1}`.

A distribution is represented as a function `p : ℕ → ℝ` which is nonnegative and
sums to `1` over `range n`.  The cumulative distribution function (CDF) is the
partial sum `cdf p k = ∑_{i ≤ k} p i`, and the 1-Wasserstein distance has the
classical closed form

  `W₁(p, q) = ∑_{k < n} |F_p(k) - F_q(k)|`,

the `L¹`-distance between the two CDFs.  (On the unit-spaced grid this is exactly
`∫ |F_p - F_q|`.)

## Main results

* `W1_nonneg`, `W1_comm`, `W1_self_eq_zero`, `W1_triangle` — `W₁` is a
  pseudometric on distributions.
* `eq_of_W1_zero` — identity of indiscernibles: `W₁(p, q) = 0` forces `p = q`
  on `range n`.  Hence `W₁` is a genuine metric on distributions.
* `kantorovich_le` — the *easy* direction of Kantorovich–Rubinstein duality:
  for every `1`-Lipschitz potential `φ`,
  `𝔼_p[φ] - 𝔼_q[φ] ≤ W₁(p, q)`.
* `kantorovich_duality` — full Kantorovich–Rubinstein duality in 1D: there is an
  *explicit* `1`-Lipschitz potential achieving equality, so
  `W₁(p, q) = max_{φ : Lip₁} (𝔼_p[φ] - 𝔼_q[φ])`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): On the discrete line the only genuinely tractable
route to a *complete* (sorry-free) optimal-transport theory is to avoid the
infimum-over-couplings definition entirely and work with the CDF closed form.
The risk is that the CDF form might only give a *pseudo*metric; the payoff would
be a full Kantorovich–Rubinstein duality with an explicit optimal potential.

EXPERIMENT 1 (metric axioms): nonnegativity, symmetry and the triangle
inequality are immediate from the corresponding facts about `|·|` applied
termwise.  Identity of indiscernibles is the only non-formal step: it requires
recovering the pmf from the CDF via finite differences.

EXPERIMENT 2 (duality): summation by parts (`Finset.sum_range_by_parts`)
rewrites `𝔼_p[φ] - 𝔼_q[φ]` as `-∑ (Δφ)·(F_p - F_q)`; since the total mass is
equal the boundary term vanishes.  The easy inequality follows from
`|Δφ| ≤ 1`.  For the sharp direction we pick `Δφ = -sign(F_p - F_q)`, which is
`1`-Lipschitz and makes every term `|F_p - F_q|`.

OUTCOME: both experiments succeed; the CDF form is a true metric AND attains the
dual optimum, giving a constructive proof of 1D Kantorovich–Rubinstein.
-/

namespace Novelty.OptimalTransport

open Finset

/-- A finitely supported probability distribution on `{0, …, n-1}`. -/
def IsDistr (n : ℕ) (p : ℕ → ℝ) : Prop :=
  (∀ i, 0 ≤ p i) ∧ ∑ i ∈ range n, p i = 1

/-- The cumulative distribution function: `cdf p k = ∑_{i ≤ k} p i`. -/
def cdf (p : ℕ → ℝ) (k : ℕ) : ℝ := ∑ i ∈ range (k + 1), p i

/-- The 1-Wasserstein distance via the `L¹`-distance of CDFs. -/
def W1 (n : ℕ) (p q : ℕ → ℝ) : ℝ := ∑ k ∈ range n, |cdf p k - cdf q k|

/-- A `1`-Lipschitz potential on the integer line. -/
def Lip1 (φ : ℕ → ℝ) : Prop := ∀ k, |φ (k + 1) - φ k| ≤ 1

/-- Expectation of a potential `φ` under a distribution `p` (over `range n`). -/
def expect (n : ℕ) (φ p : ℕ → ℝ) : ℝ := ∑ i ∈ range n, φ i * p i

/-! ### Basic CDF identities -/

/-
The pmf is recovered as a finite difference of partial sums.
-/
lemma pmf_eq_diff (p : ℕ → ℝ) (k : ℕ) :
    p k = cdf p k - ∑ i ∈ range k, p i := by
      unfold cdf;
      rw [ Finset.sum_range_succ, add_sub_cancel_left ]

/-
`cdf p (n-1)` is the total mass when `n ≥ 1`.
-/
lemma cdf_last (n : ℕ) (p : ℕ → ℝ) (hn : 1 ≤ n) :
    cdf p (n - 1) = ∑ i ∈ range n, p i := by
      cases n <;> aesop

/-
The increment of a CDF difference is a pmf difference.
-/
lemma cdf_sub_eq (p q : ℕ → ℝ) (k : ℕ) :
    cdf p k - cdf q k = ∑ i ∈ range (k + 1), (p i - q i) := by
      unfold cdf; rw [ Finset.sum_sub_distrib ] ;

/-! ### `W₁` is a pseudometric -/

lemma W1_nonneg (n : ℕ) (p q : ℕ → ℝ) : 0 ≤ W1 n p q := by
  exact Finset.sum_nonneg fun _ _ => abs_nonneg _

lemma W1_comm (n : ℕ) (p q : ℕ → ℝ) : W1 n p q = W1 n q p := by
  exact Finset.sum_congr rfl fun _ _ => abs_sub_comm _ _

lemma W1_self_eq_zero (n : ℕ) (p : ℕ → ℝ) : W1 n p p = 0 := by
  exact Finset.sum_eq_zero fun _ _ => by simp +decide [ cdf ] ;

lemma W1_triangle (n : ℕ) (p q r : ℕ → ℝ) :
    W1 n p r ≤ W1 n p q + W1 n q r := by
      unfold W1; exact le_trans ( Finset.sum_le_sum fun _ _ => abs_sub_le _ _ _ ) ( by rw [ Finset.sum_add_distrib ] ) ;

/-! ### Identity of indiscernibles -/

/-
If `W₁(p,q) = 0` then the CDFs agree on `range n`.
-/
lemma cdf_eq_of_W1_zero (n : ℕ) (p q : ℕ → ℝ) (h : W1 n p q = 0) :
    ∀ k, k < n → cdf p k = cdf q k := by
      contrapose! h;
      exact ne_of_gt <| lt_of_lt_of_le ( abs_pos.mpr <| sub_ne_zero.mpr h.choose_spec.2 ) <| Finset.single_le_sum ( fun x _ => abs_nonneg <| cdf p x - cdf q x ) <| Finset.mem_range.mpr h.choose_spec.1

/-
Partial sums agree on `range n` once the CDFs do.
-/
lemma partialSum_eq_of_W1_zero (n : ℕ) (p q : ℕ → ℝ) (h : W1 n p q = 0) :
    ∀ m, m ≤ n → ∑ i ∈ range m, p i = ∑ i ∈ range m, q i := by
      intro m hm; induction' m with m ih <;> simp_all +decide [ Finset.sum_range_succ ] ;
      have := cdf_eq_of_W1_zero n p q h m hm; simp_all +decide [ Finset.sum_range_succ, cdf ] ;

/-
**Identity of indiscernibles.** `W₁(p,q) = 0` forces the distributions to
agree on their support `range n`.
-/
lemma eq_of_W1_zero (n : ℕ) (p q : ℕ → ℝ) (h : W1 n p q = 0) :
    ∀ k, k < n → p k = q k := by
      intro k hk_lt_n
      have h_cdf_eq : cdf p k = cdf q k := by
        exact cdf_eq_of_W1_zero n p q h k hk_lt_n
      have h_partialSum_eq : ∑ i ∈ Finset.range k, p i = ∑ i ∈ Finset.range k, q i := by
        exact partialSum_eq_of_W1_zero n p q h k hk_lt_n.le
      have h_p_eq_q : p k = q k := by
        unfold cdf at h_cdf_eq; simp_all +decide [ Finset.sum_range_succ ] ;
      exact h_p_eq_q

/-! ### Kantorovich–Rubinstein duality -/

/-
Summation by parts: with equal total mass the boundary term vanishes.
-/
lemma expect_sub_eq (n : ℕ) (φ p q : ℕ → ℝ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    expect n φ p - expect n φ q
      = - ∑ i ∈ range (n - 1), (φ (i + 1) - φ i) * (cdf p i - cdf q i) := by
  convert Finset.sum_range_by_parts ( φ ) ( fun i => p i - q i ) n using 1;
  · simp +decide [ expect, mul_sub ];
  · simp_all +decide [ Finset.sum_sub_distrib, cdf_sub_eq ]

/-
With equal total mass the last CDF term of `W₁` drops out.
-/
lemma W1_eq_sum_pred (n : ℕ) (p q : ℕ → ℝ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    W1 n p q = ∑ i ∈ range (n - 1), |cdf p i - cdf q i| := by
      rcases n <;> simp_all +decide [ Finset.sum_range_succ, W1, cdf ]

/-
**Easy direction of Kantorovich–Rubinstein duality.**
-/
lemma kantorovich_le (n : ℕ) (φ p q : ℕ → ℝ) (hφ : Lip1 φ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    expect n φ p - expect n φ q ≤ W1 n p q := by
      rw [ expect_sub_eq n φ p q hpq, W1_eq_sum_pred n p q hpq ];
      exact le_trans ( neg_le_abs _ ) ( Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i hi => by rw [ abs_mul ] ; exact mul_le_of_le_one_left ( abs_nonneg _ ) ( hφ i ) )

/-- The explicit optimal potential: its increments are `-sign(F_p - F_q)`. -/
noncomputable def potential (n : ℕ) (p q : ℕ → ℝ) : ℕ → ℝ
  | 0 => 0
  | (k + 1) =>
      potential n p q k - (if k < n - 1 then Real.sign (cdf p k - cdf q k) else 0)

lemma potential_lip1 (n : ℕ) (p q : ℕ → ℝ) : Lip1 (potential n p q) := by
  intro k;
  rw [ potential ];
  split_ifs <;> norm_num [ Real.sign ];
  split_ifs <;> norm_num

lemma potential_increment (n : ℕ) (p q : ℕ → ℝ) (k : ℕ) (hk : k < n - 1) :
    potential n p q (k + 1) - potential n p q k
      = - Real.sign (cdf p k - cdf q k) := by
        rw [ potential ] ; aesop;

/-
**Sharp direction:** the explicit potential attains `W₁`.
-/
lemma kantorovich_attained (n : ℕ) (p q : ℕ → ℝ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    expect n (potential n p q) p - expect n (potential n p q) q = W1 n p q := by
  convert expect_sub_eq n ( potential n p q ) p q hpq using 1;
  convert W1_eq_sum_pred n p q hpq using 1;
  rw [ ← Finset.sum_neg_distrib ] ; refine' Finset.sum_congr rfl fun i hi => _ ; rw [ potential_increment n p q i ( Finset.mem_range.mp hi ) ] ; rw [ Real.sign ] ; split_ifs <;> cases abs_cases ( cdf p i - cdf q i ) <;> simp +decide [ * ] <;> linarith;

/-
**Kantorovich–Rubinstein duality (1D, discrete).** The 1-Wasserstein
distance equals the supremum — attained by an explicit potential — of
`𝔼_p[φ] - 𝔼_q[φ]` over `1`-Lipschitz potentials `φ`.
-/
theorem kantorovich_duality (n : ℕ) (p q : ℕ → ℝ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    (∃ φ, Lip1 φ ∧ expect n φ p - expect n φ q = W1 n p q) ∧
      (∀ φ, Lip1 φ → expect n φ p - expect n φ q ≤ W1 n p q) := by
        exact ⟨ ⟨ _, potential_lip1 n p q, kantorovich_attained n p q hpq ⟩, fun φ hφ => kantorovich_le n φ p q hφ hpq ⟩

/-! ### Corollaries: means and the Dirac isometry

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer, cycle 2): the dual bound `kantorovich_le` should
immediately yield that `W₁` dominates the difference of *means*, because the
identity map `k ↦ k` is `1`-Lipschitz; and `W₁` should *restrict* to the ground
metric on Dirac masses, i.e. `W₁(δ_a, δ_b) = |a - b|`.

EXPERIMENT 3 (mean bound): apply `kantorovich_le` with `φ = (↑·)` once in each
order (using `W1_comm`) and combine via `abs_le`.

EXPERIMENT 4 (Dirac isometry): the CDF of a Dirac mass `δ_a` is the step
function `k ↦ [a ≤ k]`, so `|F_{δ_a} - F_{δ_b}|` is the indicator of the
half-open interval between `a` and `b`; summing counts exactly `|a - b|` grid
points, all of which lie in `range n` because `a, b < n`.

OUTCOME: both corollaries go through, confirming `W₁` is a faithful extension of
the ground metric `d(a,b) = |a-b|` and a genuine refinement of mean comparison. -/

/-- The mean (first moment) of a distribution. -/
def mean (n : ℕ) (p : ℕ → ℝ) : ℝ := ∑ i ∈ range n, (i : ℝ) * p i

/-
The identity potential `k ↦ k` is `1`-Lipschitz.
-/
lemma id_lip1 : Lip1 (fun k => (k : ℝ)) := by
  exact fun k => by norm_num;

/-
`mean` is the expectation of the identity potential.
-/
lemma mean_eq_expect (n : ℕ) (p : ℕ → ℝ) :
    mean n p = expect n (fun k => (k : ℝ)) p := rfl

/-
**`W₁` dominates the difference of means.** A direct dual corollary: the
first moments of two distributions cannot differ by more than `W₁`.
-/
lemma abs_mean_sub_le_W1 (n : ℕ) (p q : ℕ → ℝ)
    (hpq : ∑ i ∈ range n, p i = ∑ i ∈ range n, q i) :
    |mean n p - mean n q| ≤ W1 n p q := by
      -- Use the identity `mean n p = expect n (fun k => (k : ℝ)) p` to rewrite the goal in terms of expectations.
      have h_mean_expect : mean n p = expect n (fun k => (k : ℝ)) p ∧ mean n q = expect n (fun k => (k : ℝ)) q := by
        exact ⟨ rfl, rfl ⟩;
      refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩ <;> linarith [ kantorovich_le n ( fun k : ℕ => ( k : ℝ ) ) p q id_lip1 hpq, kantorovich_le n ( fun k : ℕ => ( k : ℝ ) ) q p id_lip1 hpq.symm, W1_comm n p q ] ;

/-- A Dirac mass concentrated at `a`. -/
def dirac (a : ℕ) (i : ℕ) : ℝ := if i = a then 1 else 0

/-
The CDF of a Dirac mass is the unit step at `a`.
-/
lemma cdf_dirac (a k : ℕ) : cdf (dirac a) k = if a ≤ k then 1 else 0 := by
  unfold cdf dirac;
  simp +zetaDelta at *

/-
**Dirac isometry.** `W₁` restricted to Dirac masses recovers the ground
metric `d(a, b) = |a - b|`; hence `W₁` is a faithful extension of `d`.
-/
theorem W1_dirac (n a b : ℕ) (ha : a < n) (hb : b < n) :
    W1 n (dirac a) (dirac b) = |(a : ℝ) - (b : ℝ)| := by
      -- The sum in W1 is the number of grid points between min a b and max a b, both included.
      have h_card : ∑ k ∈ Finset.range n, |(if a ≤ k then 1 else 0 : ℝ) - (if b ≤ k then 1 else 0 : ℝ)| = Finset.card (Finset.Ico (min a b) (max a b)) := by
        have h_card : ∑ k ∈ Finset.range n, |(if a ≤ k then 1 else 0 : ℝ) - (if b ≤ k then 1 else 0 : ℝ)| = ∑ k ∈ Finset.Ico (min a b) (max a b), (1 : ℝ) := by
          rw [ ← Finset.sum_subset ( Finset.subset_iff.mpr _ ) ];
          congr! 1;
          · grind +splitIndPred;
          · grind;
          · grind;
        aesop;
      convert h_card using 1;
      · unfold W1 cdf dirac; norm_num;
      · cases le_total a b <;> simp +decide [ *, abs_of_nonneg, abs_of_nonpos ]

/-! ### Primal side: transport plans (couplings)

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer, cycle 3): the CDF distance `W₁` should also be a lower
bound for the cost of *every* transport plan (coupling) with the ground metric
`d(i,j) = |i-j|`.  Together with the dual theorem this pins `W₁` as the genuine
optimal-transport value (`W₁ = min cost = max dual`).

EXPERIMENT 5: decompose the ground metric `|i-j| = ∑_k |[i≤k] - [j≤k]|` (this is
exactly the Dirac isometry `W1_dirac` rewritten through `cdf_dirac`), substitute,
swap the order of summation, and apply the triangle inequality `|∑| ≤ ∑|·|`
termwise; the marginal constraints collapse the inner sum to `cdf p k - cdf q k`.

OUTCOME: the primal lower bound holds, completing the primal/dual picture for the
1D discrete Wasserstein distance. -/

/-- A **transport plan** (coupling) between `p` and `q` on `range n`: a
nonnegative matrix whose row sums are `p` and column sums are `q`. -/
def IsCoupling (n : ℕ) (p q : ℕ → ℝ) (π : ℕ → ℕ → ℝ) : Prop :=
  (∀ i j, 0 ≤ π i j) ∧
  (∀ i, ∑ j ∈ range n, π i j = p i) ∧
  (∀ j, ∑ i ∈ range n, π i j = q j)

/-- The transport cost of a plan under the ground metric `d(i,j) = |i - j|`. -/
def transportCost (n : ℕ) (π : ℕ → ℕ → ℝ) : ℝ :=
  ∑ i ∈ range n, ∑ j ∈ range n, |(i : ℝ) - (j : ℝ)| * π i j

/-
The ground metric decomposes as a sum of step-function discrepancies; this is
the Dirac isometry `W1_dirac` read through `cdf_dirac`.
-/
lemma ground_metric_decomp (n i j : ℕ) (hi : i < n) (hj : j < n) :
    |(i : ℝ) - (j : ℝ)|
      = ∑ k ∈ range n,
          |(if i ≤ k then (1 : ℝ) else 0) - (if j ≤ k then (1 : ℝ) else 0)| := by
  convert W1_dirac n i j hi hj |> Eq.symm using 1;
  exact Finset.sum_congr rfl fun x hx => by rw [ cdf_dirac, cdf_dirac ] ;

/-
**Primal Kantorovich bound.** Every transport plan costs at least `W₁`.
-/
theorem W1_le_transportCost (n : ℕ) (p q : ℕ → ℝ) (π : ℕ → ℕ → ℝ)
    (hπ : IsCoupling n p q π) :
    W1 n p q ≤ transportCost n π := by
      obtain ⟨h_nonneg, h_row, h_col⟩ := hπ;
      -- By Fubini's theorem, we can interchange the order of summation.
      have h_fubini : ∑ k ∈ Finset.range n, |cdf p k - cdf q k| ≤ ∑ k ∈ Finset.range n, ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, |(if i ≤ k then (1 : ℝ) else 0) - (if j ≤ k then (1 : ℝ) else 0)| * π i j := by
        -- Evaluate the inner signed sum to cdf difference.
        have h_inner : ∀ k < n, ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, ((if i ≤ k then (1 : ℝ) else 0) - (if j ≤ k then (1 : ℝ) else 0)) * π i j = cdf p k - cdf q k := by
          intro k hk; simp +decide [ sub_mul, Finset.sum_sub_distrib, h_row, cdf ] ;
          simp +decide [ ← Finset.sum_filter, Finset.sum_range_succ' ];
          rw [ Finset.sum_comm ];
          rw [ show ( Finset.filter ( fun x => x ≤ k ) ( Finset.range n ) ) = Finset.range ( k + 1 ) from Finset.ext fun x => by simp +decide ; omega ] ; simp +decide [ Finset.sum_range_succ', h_col ] ;
        refine' Finset.sum_le_sum fun k hk => _;
        rw [ ← h_inner k ( Finset.mem_range.mp hk ) ];
        exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i hi => Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j hj => by rw [ abs_mul, abs_of_nonneg ( h_nonneg i j ) ] );
      -- By Fubini's theorem, we can interchange the order of summation in the right-hand side.
      have h_fubini_rhs : ∑ k ∈ Finset.range n, ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, |(if i ≤ k then (1 : ℝ) else 0) - (if j ≤ k then (1 : ℝ) else 0)| * π i j = ∑ i ∈ Finset.range n, ∑ j ∈ Finset.range n, ∑ k ∈ Finset.range n, |(if i ≤ k then (1 : ℝ) else 0) - (if j ≤ k then (1 : ℝ) else 0)| * π i j := by
        exact Finset.sum_comm.trans ( Finset.sum_congr rfl fun _ _ => Finset.sum_comm );
      convert h_fubini.trans_eq h_fubini_rhs using 1;
      exact Finset.sum_congr rfl fun i hi => Finset.sum_congr rfl fun j hj => by rw [ ground_metric_decomp n i j ( Finset.mem_range.mp hi ) ( Finset.mem_range.mp hj ) ] ; rw [ Finset.sum_mul ] ;

end Novelty.OptimalTransport