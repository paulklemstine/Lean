import Bridges.ProofSearchFractalDimension
import Bridges.SubadditiveSequenceBridge

/-! # Proof-Search Entropy: a Bridge to Fekete's Subadditive Theory

Building on the self-similar proof-search model of
`Bridges.ProofSearchFractalDimension`, this file connects the *growth rate* of the
successful-path count to the classical theory of subadditive sequences (Fekete's
lemma), as packaged in `Bridges.SubadditiveSequenceBridge`.

The logarithmic count of successful depth-`n` paths,
`L(n) = log (succPaths s n)`, is (super/sub)additive; its per-depth average
`L(n)/n` converges to the **search entropy** `log s`.  The fractal dimension of
the previous file is then exactly this entropy normalised by the ambient entropy
`log b`:  `D(b,s) = entropy(s) / entropy(b)`.  This exhibits the fractal dimension
as a *relative topological entropy*, tying tree combinatorics, subadditive theory,
and fractal geometry together.

## Main results

* `logSuccCount_subadditive` — `n ↦ log (succPaths s n)` is subadditive
  (indeed additive), established through the catalog's `subadditive_def`.
* `logSuccCount_growth`      — the exact linear law `L(n) = n · log s`.
* `searchDim_eq_entropy_ratio` — the fractal dimension equals the ratio of
  per-depth growth rates: `D = (L(n)/n) / log b` for every depth `n ≥ 1`.
* `searchEntropy_tendsto`    — `L(n)/n → log s`: the search entropy is the limit
  of the measured per-depth growth, matching the Fekete average.
* `fekete_entropy_upper`     — a consequence of the catalog's `subadditive_double`:
  doubling the depth at most doubles the log-count.
-/

namespace ProofSearchEntropyFekete

open ProofSearchFractalDimension

/-- The logarithmic count of successful depth-`n` paths: the "action" whose
per-depth average is the search entropy. -/
noncomputable def logSuccCount (s : ℕ) (n : ℕ) : ℝ := Real.log (succPaths s n)

/-- Exact linear growth law: `log (succPaths s n) = n · log s`. -/
theorem logSuccCount_growth (s n : ℕ) : logSuccCount s n = n * Real.log s := by
  simp only [logSuccCount, succPaths, Nat.cast_pow, Real.log_pow]

/-- The log-count sequence is subadditive — established via the catalog's
`subadditive_def` characterisation.  (It is in fact additive, so subadditivity
holds with equality.) -/
theorem logSuccCount_subadditive (s : ℕ) : Subadditive (logSuccCount s) := by
  rw [SubadditiveSequenceBridge.subadditive_def]
  intro n m
  rw [logSuccCount_growth, logSuccCount_growth, logSuccCount_growth]
  have : ((n + m : ℕ) : ℝ) * Real.log s = n * Real.log s + m * Real.log s := by
    push_cast; ring
  linarith [this]

/-- **Fractal dimension as relative entropy.**  For every positive depth `n`, the
fractal dimension equals the measured per-depth growth rate of the successful-path
count, divided by the ambient growth rate `log b`. -/
theorem searchDim_eq_entropy_ratio (b s n : ℕ) (hn : n ≠ 0) :
    searchDim b s = (logSuccCount s n / n) / Real.log b := by
  rw [logSuccCount_growth, searchDim]
  have hnR : (n : ℝ) ≠ 0 := by exact_mod_cast hn
  field_simp

/-- **Search entropy via Fekete's average.**  The per-depth average of the
log-count converges to the search entropy `log s`, matching the Fekete limit of
the subadditive sequence `logSuccCount`. -/
theorem searchEntropy_tendsto (s : ℕ) :
    Filter.Tendsto (fun n => logSuccCount s n / n) Filter.atTop (nhds (Real.log s)) := by
  apply Filter.Tendsto.congr' _ tendsto_const_nhds
  filter_upwards [Filter.eventually_gt_atTop 0] with n hn
  rw [logSuccCount_growth]
  have hnR : (n : ℝ) ≠ 0 := by positivity
  field_simp

/-- A consequence of the catalog's `subadditive_double`: doubling the search depth
at most doubles the logarithmic count of successful paths. -/
theorem fekete_entropy_upper (s n : ℕ) :
    logSuccCount s (n + n) ≤ logSuccCount s n + logSuccCount s n :=
  SubadditiveSequenceBridge.subadditive_double _ (logSuccCount_subadditive s) n

/-! ## Examples -/

-- The entropy of a `4`-fold-successful search is `log 4`.
example : logSuccCount 4 1 = Real.log 4 := by
  rw [logSuccCount_growth]; simp

-- Dimension as relative entropy at depth `3` for `b = 8, s = 2`.
example : searchDim 8 2 = (logSuccCount 2 3 / 3) / Real.log 8 :=
  searchDim_eq_entropy_ratio 8 2 3 (by norm_num)

#check @searchDim_eq_entropy_ratio
#check @searchEntropy_tendsto

/-!
### Generalization

The linear growth `L(n) = n log s` makes the search entropy an exact quantity, so
Fekete's inequality holds with equality here.  For *non-uniform* self-similar
searches (variable branching per level) the growth becomes genuinely subadditive
and Fekete's limit — no longer a closed form — is the correct definition of search
entropy, and `searchDim = entropy / log b` still holds in the limit.

### Boundary cases

* `s = 0` (no proof exists): `logSuccCount 0 n = log 0 = 0` for the convention
  `log 0 = 0`, and the entropy is `0`; the "dimension" degenerates, matching the
  fact that an unsatisfiable goal has an empty success set.
* `s = 1` (unique proof): entropy `log 1 = 0`, dimension `0` — the boundary of a
  trivially focused search, consistent with `ProofSearchFractalDimension`.
-/

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The similarity dimension `D = log s / log b` of the previous file
should be reinterpretable as a *relative topological entropy*: the growth rate of
successful paths divided by the growth rate of all paths, linking it to the
classical subadditive (Fekete) theory of growth rates.

**Experiment.**  We defined `L(n) = log (succPaths s n)`, proved its exact linear
law, and established its subadditivity by routing through the catalog's
`subadditive_def`.  We then proved (a) `D = (L(n)/n)/log b` for every depth `n ≥ 1`,
(b) the convergence `L(n)/n → log s` (the search entropy), and (c) the doubling
bound via the catalog's `subadditive_double`.

**Analysis.**  The bridge is exact: the fractal dimension is entropy(s)/entropy(b).
Because the uniform model has additive `L`, Fekete's inequality is tight, which is
why the dimension has a closed form.  The genuine content of Fekete's theory
appears only for non-uniform searches, where the entropy is a limit rather than a
ratio — this is the natural next generalization.

**Critique.**  We used `n ≠ 0` where division by depth occurs and relied on the
`log 0 = 0` convention for the `s = 0` boundary, documented above.  The doubling
bound is a strict consequence of the catalog lemma, not a restatement, so the two
files are genuinely composed rather than duplicated.

**Synthesis.**  Fractal dimension of proof search = relative search entropy =
(Fekete growth rate of successful paths)/(growth rate of all paths).  This unifies
the fractal-geometric, combinatorial, and subadditive viewpoints in one identity.
-/

end ProofSearchEntropyFekete