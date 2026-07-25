/-
# Gaussian binomial coefficients and the combinatorics of Grassmann schemes

This file develops the combinatorial backbone underlying the **degree-one triviality
threshold conjecture** for Grassmann schemes `J_q(n,k)` (the association scheme whose
points are the `k`-dimensional subspaces of an `n`-dimensional vector space over the field
with `q` elements).

The number of `k`-subspaces of an `n`-dimensional `𝔽_q`-space is the *Gaussian binomial
coefficient* (a `q`-analogue of `Nat.choose`).  We define it via the `q`-Pascal recurrence
(which avoids any division), and prove the structural identities that are needed to even
*state* the conjecture faithfully:

* `qBinom_one` — at `q = 1` the Gaussian binomial degenerates to the ordinary binomial.
* `qBinom_pos` — every Grassmann scheme `J_q(n,k)` with `k ≤ n` is nonempty.
* `qBinom_one_eq_geom` — the number of *points* `J_q(n,1)` equals `1 + q + ⋯ + q^{n-1}`.
* `qBinom_symm` — the symmetry `[n,k]_q = [n,n-k]_q`.
* `point_hyperplane_duality` — the number of points equals the number of hyperplanes,
  the counting shadow of the *point/dual-point* duality that the conjecture's "point
  indicators and their duals" refers to.
* `qBinom_strictMono_left` — for `q ≥ 2` the schemes grow strictly with the ambient
  dimension `n`, which is what makes the threshold regime `n ≥ 2k+1` "large".

Mathlib (v4.28.0) has no Gaussian binomial coefficient, so the theory is built here from
scratch.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The full conjecture — every Boolean degree-one function on
`J_q(n,k)` is trivial when `n ≥ 2k+1` — is a research-frontier statement (proved only for
`q = 2`, and `q ∈ {3,4,5}, k = 2`).  A faithful Lean attack first needs the *counting*
layer: the Gaussian binomial coefficient and the point/hyperplane duality that defines what
"trivial" means (point indicators and their duals).

Experiment (Experimenter): We define `qBinom` by the `q`-Pascal recurrence
`[n+1,k+1]_q = [n,k]_q + q^{k+1} [n,k+1]_q`, verified computationally to reproduce the
subspace counts (e.g. `[n,2]_3 = 0,0,1,13,130,1210,11011` and `[n,1]_3 = (3^n-1)/2`).
We then prove: the `q=1` degeneration, vanishing above the diagonal, positivity, the
geometric-series value of the point count, the *second* (`q^{n-k}`) Pascal recurrence, the
symmetry `[n,k]_q = [n,n-k]_q`, point/hyperplane duality, and strict growth in `n`.

Analysis (Analyst): The symmetry is the load-bearing identity: it is exactly point/dual
duality at `k = 1`, and is the reason the conjecture's "trivial" family is closed under the
scheme's duality.  Both Pascal recurrences are needed — the defining one and its
`q^{n-k}`-twisted partner — to push the symmetry induction through.

Critique (Critic): None of the headline theorems is `decide`/`rfl`-trivial; each needs
genuine induction.  Positivity requires `q ≥ 1` (false for `q = 0`, where `[n,k]_0` can
vanish) and the strict-growth result requires `q ≥ 2` (`q = 1` gives ordinary binomials,
which are *not* strictly increasing in `n` past the diagonal); both hypotheses are kept and
are load-bearing.

Synthesis (PI): This file is the counting backbone; `FUTURE_DIRECTIONS.md` records the
degree-one triviality conjecture and its refinements as the next targets.
-- !-- Lab Notes -- !--
-/
import Mathlib

namespace GrassmannDegreeOne

open Finset

/-- The Gaussian binomial coefficient `[n,k]_q`, defined by the `q`-Pascal recurrence
`[n+1,k+1]_q = [n,k]_q + q^{k+1}·[n,k+1]_q`.  For a prime power `q` this counts the
`k`-dimensional subspaces of an `n`-dimensional vector space over `𝔽_q`, i.e. the points of
the Grassmann scheme `J_q(n,k)`. -/
def qBinom (q : ℕ) : ℕ → ℕ → ℕ
  | 0,     0       => 1
  | 0,     (_ + 1) => 0
  | (_ + 1), 0     => 1
  | (n + 1), (k + 1) => qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1)

@[simp] lemma qBinom_zero_right (q n : ℕ) : qBinom q n 0 = 1 := by
  cases n <;> rfl

@[simp] lemma qBinom_zero_succ (q k : ℕ) : qBinom q 0 (k + 1) = 0 := rfl

lemma qBinom_succ_succ (q n k : ℕ) :
    qBinom q (n + 1) (k + 1) = qBinom q n k + q ^ (k + 1) * qBinom q n (k + 1) := rfl

/-
Above the diagonal the Gaussian binomial vanishes.
-/
lemma qBinom_eq_zero (q : ℕ) {n k : ℕ} (h : n < k) : qBinom q n k = 0 := by
  induction' n with n ih generalizing k <;> induction' k with k ih';
  · contradiction;
  · cases k <;> tauto;
  · contradiction;
  · grind +suggestions

@[simp] lemma qBinom_self (q n : ℕ) : qBinom q n n = 1 := by
  induction' n with n ih;
  · rfl;
  · convert qBinom_succ_succ q n n using 1;
    rw [ ih, qBinom_eq_zero ] <;> norm_num

/-
At `q = 1` the Gaussian binomial coefficient is the ordinary binomial coefficient.
-/
theorem qBinom_one (n k : ℕ) : qBinom 1 n k = Nat.choose n k := by
  induction' n with n ih generalizing k;
  · cases k <;> aesop;
  · cases k <;> simp_all +arith +decide [ Nat.choose_succ_succ, qBinom_succ_succ ]

/-
Every Grassmann scheme `J_q(n,k)` with `k ≤ n` is nonempty (the count is positive).  The
hypothesis `1 ≤ q` is not needed: with the `q`-Pascal recurrence the count stays positive
even in the degenerate case `q = 0`.
-/
theorem qBinom_pos (q : ℕ) {n k : ℕ} (h : k ≤ n) : 0 < qBinom q n k := by
  induction' n with n ih generalizing k <;> induction' k with k ihk <;> simp_all +decide [ qBinom ]

/-
The number of *points* of the projective geometry, `[n,1]_q`, is the geometric sum
`1 + q + ⋯ + q^{n-1}`.
-/
theorem qBinom_one_eq_geom (q n : ℕ) : qBinom q n 1 = ∑ i ∈ range n, q ^ i := by
  induction' n with n ih <;> simp_all +decide [ Finset.sum_range_succ ];
  convert qBinom_succ_succ q n 0 using 1 ; simp +arith +decide [ * ];
  nlinarith [ geom_sum_mul_neg ( q : ℤ ) n ]

/-
The *second* (`q^{n-k}`-twisted) `q`-Pascal recurrence.  Together with the defining one
this drives the symmetry of the Gaussian binomial.
-/
theorem qBinom_succ_left (q : ℕ) {n k : ℕ} (h : k ≤ n) :
    qBinom q (n + 1) (k + 1) = q ^ (n - k) * qBinom q n k + qBinom q n (k + 1) := by
  induction' n with n ih generalizing k;
  · aesop;
  · cases h <;> simp_all +decide [ Nat.succ_sub, pow_succ', mul_assoc, qBinom_succ_succ ];
    · exact ⟨ qBinom_eq_zero _ ( Nat.lt_succ_self _ ), Or.inr <| Or.inr <| qBinom_eq_zero _ ( Nat.lt_succ_of_lt <| Nat.lt_succ_self _ ) ⟩;
    · rcases k with ( _ | k ) <;> simp_all +decide [ pow_succ', mul_assoc, mul_comm, qBinom_succ_succ ];
      · rw [ qBinom_one_eq_geom ];
        nlinarith [ geom_sum_mul_neg ( q : ℤ ) n ];
      · grind

/-
Symmetry of the Gaussian binomial coefficient: `[n,k]_q = [n,n-k]_q`.
-/
theorem qBinom_symm (q : ℕ) {n k : ℕ} (h : k ≤ n) :
    qBinom q n k = qBinom q n (n - k) := by
  -- Prove qBinom q n k = qBinom q n (n-k) for k ≤ n by induction on n.
  induction' n with n ih generalizing k;
  · aesop;
  · rcases k with ( _ | k );
    · aesop;
    · rcases h with ( _ | h ) <;> simp_all +decide [ Nat.succ_sub_succ ];
      convert qBinom_succ_left q ( by linarith : k ≤ n ) using 1;
      convert qBinom_succ_succ q n ( n - k - 1 ) using 1;
      · rw [ Nat.sub_add_cancel ( Nat.sub_pos_of_lt h ) ];
      · grind +splitIndPred

/-
**Point–hyperplane duality.**  In the projective geometry over `𝔽_q` of dimension
`n-1`, the number of points equals the number of hyperplanes.  This is the counting shadow
of the duality that turns *point indicators* into *dual indicators* in the degree-one
triviality conjecture.
-/
theorem point_hyperplane_duality (q : ℕ) {n : ℕ} (hn : 1 ≤ n) :
    qBinom q n 1 = qBinom q n (n - 1) := by
  exact qBinom_symm q hn

/-
For `q ≥ 2` the Grassmann schemes grow strictly with the ambient dimension: there are
strictly more `k`-subspaces of an `(n+1)`-space than of an `n`-space (`1 ≤ k ≤ n`).  This is
what makes the threshold regime `n ≥ 2k+1` a regime of *large* schemes.
-/
theorem qBinom_strictMono_left (q : ℕ) (hq : 2 ≤ q) {n k : ℕ}
    (hk : 1 ≤ k) (hkn : k ≤ n) :
    qBinom q n k < qBinom q (n + 1) k := by
  -- We proceed by induction on $k$.
  induction' k with k ih generalizing n;
  · contradiction;
  · exact lt_add_of_pos_of_le ( qBinom_pos q ( by linarith ) ) ( Nat.le_mul_of_pos_left _ ( by positivity ) )

end GrassmannDegreeOne