import Mathlib
import Tropical.MusicalDigits.IntervalDistribution

/-!
# The min-plus interval matrix of a digit melody

The corrected methodology asks for interval statistics attached to *clearly specified
pairs of positions*.  Collecting all of them at once for a window of `n` positions gives
a matrix

`intervalMatrix x n i j = trop |x i - x j| ∈ Tropical (WithTop ℕ)`,

an object in the min-plus (tropical) matrix semiring.  The main results are:

* `intervalMatrix_diag` — the diagonal is the tropical unit: a note against itself is a
  unison;
* `intervalMatrix_idempotent` — **the interval matrix is a tropical idempotent**,
  `A ⊙ A = A`.  Equivalently, it is a fixed point of the min-plus Kleene closure: the
  cheapest voice-leading from note `i` to note `j` through an intermediate note is never
  cheaper than the direct interval, and never more expensive either (take the trivial
  detour).  `intervalMatrix_pow` iterates this to all tropical powers;
* `interval_le_chain_sum` / `trop_le_chain_prod` — the same statement for chains of
  arbitrary length, in ordinary and in tropical notation;
* `intervalMatrix_entry_ne_octave` — every entry of a decimal interval matrix is a
  tropical number at most `trop 9`, so the octave value `12` occurs in no entry, at any
  pair of positions and in particular at every pair of positions at temporal distance 12
  (`lag_twelve_entry_ne_octave`).

The temporal structure (which pairs `(i, j)` one looks at) is thus completely separated
from the pitch structure (which values the entries can take).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): pitch intervals of a melody should assemble into a matrix that
is idempotent in the min-plus semiring — i.e. a genuine tropical "distance matrix" equal
to its own Kleene star — while temporal lags only index which entries one samples.

Experiment (Experimenter): `Finset.untrop_sum'` turns a tropical matrix product into a
`Finset.inf`; the two inequalities are the triangle inequality (`≥`) and the trivial
detour `k = i` together with `|x i - x i| = 0` (`≤`).

Analysis (Analyst): idempotency needs both `interval_self` and `interval_triangle`, and
fails for a "signed interval" matrix `x i - x j` (which is not symmetric and has negative
entries in ℤ). The absolute value is exactly what makes the tropical statement true.

Critique (Critic): the entries were embedded into `WithTop ℕ` so that `Tropical` is a
semiring (a top element is needed for the tropical zero); no melody entry is ever `⊤`, so
the embedding adds no content beyond making the algebra available.
-/

namespace TropicalMusicalDigits

open Finset Tropical Matrix

/-! ### Chains of positions -/

/-- Voice-leading through intermediate notes never beats the direct interval: the direct
pitch interval between the first and last note of a chain of positions is at most the sum
of the consecutive intervals along the chain. -/
theorem interval_le_chain_sum (x : ℕ → ℕ) (p : ℕ → ℕ) :
    ∀ m : ℕ, interval x (p 0) (p m) ≤ ∑ t ∈ range m, interval x (p t) (p (t + 1))
  | 0 => by simp [interval_self]
  | (m + 1) => by
      have ih := interval_le_chain_sum x p m
      have htri := interval_triangle x (p 0) (p m) (p (m + 1))
      rw [Finset.sum_range_succ]
      omega

/-- The tropical form of the chain bound: in the min-plus order the direct interval is at
most the tropical product (i.e. the ordinary sum) of the consecutive chain intervals. -/
theorem trop_le_chain_prod (x : ℕ → ℕ) (p : ℕ → ℕ) (m : ℕ) :
    trop (interval x (p 0) (p m))
      ≤ ∏ t ∈ range m, trop (interval x (p t) (p (t + 1))) := by
  have h := interval_le_chain_sum x p m
  have h' := trop_monotone h
  rwa [trop_sum] at h'

/-! ### The interval matrix in the min-plus semiring -/

/-- The min-plus interval matrix of the first `n` notes of a digit melody. -/
noncomputable def intervalMatrix (x : ℕ → ℕ) (n : ℕ) :
    Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ)) :=
  fun i j => trop ((interval x i j : ℕ) : WithTop ℕ)

@[simp] lemma intervalMatrix_apply (x : ℕ → ℕ) (n : ℕ) (i j : Fin n) :
    intervalMatrix x n i j = trop ((interval x i j : ℕ) : WithTop ℕ) := rfl

/-- The diagonal of the interval matrix is the tropical unit `1 = trop 0`: each note
sounds a unison with itself. -/
@[simp] theorem intervalMatrix_diag (x : ℕ → ℕ) (n : ℕ) (i : Fin n) :
    intervalMatrix x n i i = 1 := by
  simp [intervalMatrix, interval_self, ← trop_zero]

/-- The interval matrix is symmetric: intervals are unordered. -/
theorem intervalMatrix_transpose (x : ℕ → ℕ) (n : ℕ) :
    (intervalMatrix x n)ᵀ = intervalMatrix x n := by
  ext i j
  simp [Matrix.transpose_apply, intervalMatrix, interval_comm x j i]

/-- **Tropical idempotency of the interval matrix.**  In the min-plus matrix semiring the
interval matrix satisfies `A ⊙ A = A`; equivalently it is a fixed point of the tropical
Kleene closure.  Musically: the cheapest two-step voice-leading between two notes costs
exactly the direct interval. -/
theorem intervalMatrix_idempotent (x : ℕ → ℕ) (n : ℕ) :
    intervalMatrix x n * intervalMatrix x n = intervalMatrix x n := by
  ext i j
  apply untrop_injective
  rw [Matrix.mul_apply, Finset.untrop_sum']
  have hterm : ∀ k : Fin n,
      (untrop ∘ fun k => intervalMatrix x n i k * intervalMatrix x n k j) k
        = ((interval x i k : ℕ) : WithTop ℕ) + ((interval x k j : ℕ) : WithTop ℕ) := by
    intro k; simp [intervalMatrix, untrop_mul]
  refine le_antisymm ?_ ?_
  · calc (univ.inf fun k => untrop ((fun k => intervalMatrix x n i k * intervalMatrix x n k j) k))
        ≤ ((interval x i i : ℕ) : WithTop ℕ) + ((interval x i j : ℕ) : WithTop ℕ) := by
          have := Finset.inf_le
            (f := (untrop ∘ fun k => intervalMatrix x n i k * intervalMatrix x n k j))
            (mem_univ i)
          rw [hterm i] at this
          exact this
      _ = untrop (intervalMatrix x n i j) := by simp [intervalMatrix, interval_self]
  · refine Finset.le_inf fun k _ => ?_
    rw [hterm k]
    have htri := interval_triangle x i k j
    simp only [intervalMatrix, untrop_trop]
    exact_mod_cast WithTop.coe_le_coe.2 htri

/-- All positive tropical powers of the interval matrix agree with it: chains of any
length are governed by the direct intervals. -/
theorem intervalMatrix_pow (x : ℕ → ℕ) (n : ℕ) :
    ∀ m : ℕ, intervalMatrix x n ^ (m + 1) = intervalMatrix x n
  | 0 => pow_one _
  | (m + 1) => by
      rw [pow_succ, intervalMatrix_pow x n m, intervalMatrix_idempotent]

/-! ### Pitch bounds on the entries -/

/-- Every entry of the interval matrix of a decimal melody is at most nine semitones. -/
theorem intervalMatrix_entry_le_nine {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n : ℕ)
    (i j : Fin n) : intervalMatrix x n i j ≤ trop ((9 : ℕ) : WithTop ℕ) := by
  have h9 : interval x i j ≤ 9 := by
    have h1 := hx i
    have h2 := hx j
    simp only [interval, Nat.dist]
    omega
  simpa [intervalMatrix] using
    (trop_monotone (show ((interval x i j : ℕ) : WithTop ℕ) ≤ ((9 : ℕ) : WithTop ℕ) from
      by exact_mod_cast WithTop.coe_le_coe.2 h9))

/-- No entry of a decimal interval matrix is the octave `trop 12`: the twelve-semitone
value is unattainable for *every* pair of positions. -/
theorem intervalMatrix_entry_ne_octave {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n : ℕ)
    (i j : Fin n) : intervalMatrix x n i j ≠ trop ((12 : ℕ) : WithTop ℕ) := by
  intro hcon
  have h1 := hx i
  have h2 := hx j
  have : ((interval x i j : ℕ) : WithTop ℕ) = ((12 : ℕ) : WithTop ℕ) := by
    simpa [intervalMatrix] using congrArg untrop hcon
  have h12 : interval x i j = 12 := by exact_mod_cast this
  simp only [interval, Nat.dist] at h12
  omega

/-- The specialization to temporal lag twelve: for the pair of positions `(i, i+12)`
inside a window, the matrix entry is a unison-to-major-sixth interval and never an
octave.  Temporal distance `12` and pitch distance `12` are different quantities. -/
theorem lag_twelve_entry_ne_octave {x : ℕ → ℕ} (hx : IsDigitMelody 10 x) (n : ℕ)
    (i j : Fin n) (hij : (j : ℕ) = (i : ℕ) + 12) :
    intervalMatrix x n i j = trop ((lagInterval x 12 i : ℕ) : WithTop ℕ) ∧
      intervalMatrix x n i j ≠ trop ((12 : ℕ) : WithTop ℕ) := by
  refine ⟨?_, intervalMatrix_entry_ne_octave hx n i j⟩
  simp [intervalMatrix, lagInterval, interval, hij]

end TropicalMusicalDigits