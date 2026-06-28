/-
# The classical (`q → 1`) limit of the Grassmann scheme

The Grassmann scheme `J_q(n,k)` degenerates, as `q → 1`, to the **Johnson scheme** `J(n,k)`
of `k`-subsets of an `n`-set: the Gaussian binomial coefficient `[n,k]_q` becomes the
ordinary binomial coefficient `Nat.choose n k` (this is `GrassmannDegreeOne.qBinom_one`).

The degree-one triviality phenomenon is *also* known classically on the Johnson scheme, so
the `q = 1` specialization is the natural sanity check / boundary of the conjecture.  This
file transports three structural facts about ordinary binomial coefficients — proved in the
catalog file `Catalog.Novelty.Binomial` — through the `q = 1` degeneration, obtaining:

* `qBinom_one_unimodal_bound` — unimodality: `[n,k]₁ ≤ [n, n/2]₁` (the central scheme is the
  biggest), the `q = 1` shadow of Gaussian-binomial unimodality;
* `qBinom_one_mono_ambient` — the scheme grows with the ambient dimension `n` (the `q = 1`
  shadow of `GrassmannDegreeOne.qBinom_strictMono_left`);
* `qBinom_one_total_mass` — the total number of faces of all dimensions is `2^n`.

Each result is obtained by rewriting `[n,k]₁` to `Nat.choose n k` and invoking the
corresponding catalog theorem, so the file genuinely *uses* and *extends* the catalog.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The degree-one triviality conjecture should specialize cleanly at
`q = 1` to the (classically understood) Johnson scheme.  If the `q`-binomial machinery in
`GrassmannDegreeOne` is correct, then *every* classical binomial identity must be recoverable
as its `q = 1` slice, and the catalog's binomial lemmas should drop straight in.

Experiment (Experimenter): We import `Catalog.Novelty.Binomial` and feed `qBinom_one` into
its three results (`choose_le_middle`, `choose_mono_n`, `sum_range_choose_eq`).  The total-mass
statement needs a `Finset.sum_congr` to rewrite the summand `[n,k]₁ ↦ choose n k` pointwise
before the catalog lemma applies.

Analysis (Analyst): All three transports succeed, confirming the `q = 1` degeneration is
faithful.  The unimodality bound is the conceptual link to the threshold `n ≥ 2k+1`: that
regime forces `k` to stay strictly below the central index `n/2`, the part of the row where
the scheme is still growing — exactly where "few" degree-one functions can exist.

Critique (Critic): None of these is a renaming: each rewrites through a nontrivial
identification (`qBinom 1 = choose`) and then applies a genuine combinatorial lemma; the
total-mass proof additionally needs a pointwise sum rewrite.  The catalog dependency is real
(remove the import and the file fails to compile).

Synthesis (PI): The `q = 1` slice is consistent with the conjecture; the open content lives
strictly at `q ≥ 2`, recorded in `FUTURE_DIRECTIONS.md`.
-- !-- Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.GrassmannDegreeOne
import Catalog.Novelty.Binomial

namespace GrassmannClassicalLimit

open GrassmannDegreeOne Finset

/-- **Unimodality at `q = 1`.**  In the classical limit, the central Grassmann scheme
`J_1(n, ⌊n/2⌋)` is the largest: `[n,k]₁ ≤ [n, n/2]₁` for every `k`.  This is the `q = 1`
shadow of Gaussian-binomial unimodality, and the reason the threshold `n ≥ 2k+1` (which keeps
`k` below `n/2`) lands in the growing part of the row. -/
theorem qBinom_one_unimodal_bound (n k : ℕ) :
    qBinom 1 n k ≤ qBinom 1 n (n / 2) := by
  rw [qBinom_one, qBinom_one]
  exact Catalog.Novelty.Binomial.choose_le_middle n k

/-- **Ambient monotonicity at `q = 1`.**  Enlarging the ambient dimension never decreases the
number of `k`-faces: `[n,k]₁ ≤ [m,k]₁` whenever `n ≤ m`.  This is the `q = 1` shadow of the
strict growth `GrassmannDegreeOne.qBinom_strictMono_left` available for `q ≥ 2`. -/
theorem qBinom_one_mono_ambient {n m : ℕ} (k : ℕ) (h : n ≤ m) :
    qBinom 1 n k ≤ qBinom 1 m k := by
  rw [qBinom_one, qBinom_one]
  exact Catalog.Novelty.Binomial.choose_mono_n k h

/-- **Total mass at `q = 1`.**  Summing the Grassmann counts over all face dimensions
`k = 0, …, n` gives `2 ^ n`: the classical limit of the Grassmann poset is the Boolean
lattice on `n` elements. -/
theorem qBinom_one_total_mass (n : ℕ) :
    ∑ k ∈ range (n + 1), qBinom 1 n k = 2 ^ n := by
  rw [Finset.sum_congr rfl (fun k _ => qBinom_one n k)]
  exact Catalog.Novelty.Binomial.sum_range_choose_eq n

end GrassmannClassicalLimit