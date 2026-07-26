import Mathlib

/-! # Proof-Search Fractal Dimension: a Bridge Between Tree Combinatorics and Similarity Dimension

This file develops a rigorous, self-contained model of the *proof-search fractal
dimension* of a derivation problem, bridging two areas:

* **Combinatorics of rooted trees** — a search space with branching factor `b`
  and a self-similar "successful" sub-branching factor `s ≤ b`; and
* **Real analysis / fractal geometry** — the similarity dimension of the boundary
  Cantor set of successful infinite paths.

## The model

A uniform proof-search space of *branching factor* `b` is the complete `b`-ary
tree.  A derivation problem is *self-similar* when, at every node, exactly `s` of
the `b` available inference steps can be extended to a full proof.  The set of
successful infinite derivation paths is then a self-similar Cantor set inside the
boundary of the `b`-ary tree.  Equipping that boundary with the natural metric
`d(x,y) = b^{-(length of common prefix)}`, the whole boundary has similarity
dimension `1`, and the successful subset has **similarity dimension**

`D(b,s) = log s / log b`.

## Main results

* `succPaths_le_totalPaths`  — successful paths never outnumber candidate paths.
* `dim_scaling`             — the *bridge identity*: the number of successful
                              depth-`n` paths equals `total^{D}` where
                              `total = b^n`.  Combinatorial growth becomes an
                              analytic power law with fractal exponent `D`.
* `dim_codimension_density` — the success *density* decays like `total^{D-1}`;
                              the codimension `1 - D` is the exponential pruning rate.
* `dim_nonneg`, `dim_le_one`, `dim_lt_one_of_lt`, `dim_eq_one_iff`
                            — the dimension lives in `[0,1]`, with `D = 1` exactly
                              when no branch can be pruned (`s = b`) and `D < 1`
                              as soon as one branch fails.
* `dim_strictMono`          — the dimension is strictly increasing in the number
                              of successful branches.
* `nodesExplored_geom`      — an exhaustive search of depth `n` visits
                              `(b^{n+1}-1)/(b-1)` nodes (geometric cost).

## Interpretation

`D` measures how *focused* proof search is.  `D` near `0` means an essentially
unique proof path (search is trivial); `D` near `1` means almost every path
succeeds so pruning is impossible and exhaustive search is forced.  The bridge
identity `succ = total^D` turns the informal slogan "difficulty is fractal" into
an exact power law relating a combinatorial count to an analytic exponent.
-/

namespace ProofSearchFractalDimension

/-- Total number of candidate derivation paths of depth `n` in a search space of
branching factor `b`: the complete `b`-ary tree has `b^n` paths of length `n`. -/
def totalPaths (b n : ℕ) : ℕ := b ^ n

/-- Number of *successful* derivation paths of depth `n` in a self-similar
problem where exactly `s` of the `b` branches at each node extend to a proof. -/
def succPaths (s n : ℕ) : ℕ := s ^ n

/-- The **proof-search fractal dimension** (similarity dimension of the Cantor
set of successful infinite paths inside the boundary of the `b`-ary tree). -/
noncomputable def searchDim (b s : ℕ) : ℝ := Real.log s / Real.log b

/-! ## Section 1 — Combinatorial counts -/

/-- There are exactly `s^n` successful derivation paths of depth `n`. -/
theorem succPaths_eq (s n : ℕ) : succPaths s n = s ^ n := rfl

/-- There are exactly `b^n` candidate paths of depth `n`. -/
theorem totalPaths_eq (b n : ℕ) : totalPaths b n = b ^ n := rfl

/-- Successful paths never outnumber candidate paths. -/
theorem succPaths_le_totalPaths (b s n : ℕ) (hsb : s ≤ b) :
    succPaths s n ≤ totalPaths b n := Nat.pow_le_pow_left hsb n

/-! ## Section 2 — The bridge identity: combinatorial growth is an analytic power law -/

/-- **Bridge identity.**  The number of successful depth-`n` paths equals the
total number of candidate paths raised to the fractal dimension `D`:
`s^n = (b^n) ^ (log s / log b)`.  Exponential combinatorial growth is exactly a
power law whose exponent is the similarity dimension. -/
theorem dim_scaling (b s n : ℕ) (hb : 1 < b) (hs : 1 ≤ s) :
    ((succPaths s n : ℝ)) = ((totalPaths b n : ℝ)) ^ (searchDim b s) := by
  simp only [succPaths, totalPaths, Nat.cast_pow]
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  have hbnpos : (0:ℝ) < (b:ℝ) ^ n := by positivity
  have hlogb : Real.log b ≠ 0 := ne_of_gt (Real.log_pos hbR)
  rw [searchDim, Real.rpow_def_of_pos hbnpos, Real.log_pow,
    show (n : ℝ) * Real.log b * (Real.log s / Real.log b) = n * Real.log s by field_simp,
    Real.exp_nat_mul, Real.exp_log hsR]

/-- **Codimension / density law.**  The fraction of candidate paths that succeed
decays like `total^{D-1}`; the codimension `1 - D` is the exponential rate at
which successful paths thin out. -/
theorem dim_codimension_density (b s n : ℕ) (hb : 1 < b) (hs : 1 ≤ s) :
    (((s : ℝ)) / ((b : ℝ))) ^ n = ((totalPaths b n : ℝ)) ^ (searchDim b s - 1) := by
  simp only [totalPaths, Nat.cast_pow]
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  have hbpos : (0:ℝ) < b := by linarith
  have hbnpos : (0:ℝ) < (b:ℝ) ^ n := by positivity
  have hlogb : Real.log b ≠ 0 := ne_of_gt (Real.log_pos hbR)
  rw [searchDim, Real.rpow_def_of_pos hbnpos, Real.log_pow,
    show (n : ℝ) * Real.log b * (Real.log s / Real.log b - 1)
        = n * (Real.log s - Real.log b) by field_simp,
    Real.exp_nat_mul, ← Real.log_div (ne_of_gt hsR) (ne_of_gt hbpos),
    Real.exp_log (by positivity)]

/-! ## Section 3 — The dimension lives on the balanced edge `[0,1]` -/

/-- The fractal dimension is nonnegative. -/
theorem dim_nonneg (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s) : 0 ≤ searchDim b s := by
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsR : (1:ℝ) ≤ s := by exact_mod_cast hs
  exact div_nonneg (Real.log_nonneg hsR) (le_of_lt (Real.log_pos hbR))

/-- The fractal dimension is at most `1`: no derivation problem is harder than the
full unprunable search. -/
theorem dim_le_one (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s) (hsb : s ≤ b) :
    searchDim b s ≤ 1 := by
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsbR : (s:ℝ) ≤ b := by exact_mod_cast hsb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  rw [searchDim, div_le_one (Real.log_pos hbR)]
  exact Real.log_le_log hsR hsbR

/-- If even a single branch can be pruned (`s < b`), the dimension is strictly
below `1` — search is genuinely focused. -/
theorem dim_lt_one_of_lt (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s) (hsb : s < b) :
    searchDim b s < 1 := by
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsbR : (s:ℝ) < b := by exact_mod_cast hsb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  rw [searchDim, div_lt_one (Real.log_pos hbR)]
  exact Real.log_lt_log hsR hsbR

/-- The dimension equals `1` exactly when no branch fails (`s = b`), i.e. the
maximally hard case where exhaustive search cannot be avoided. -/
theorem dim_eq_one_iff (b s : ℕ) (hb : 1 < b) (hs : 1 ≤ s) :
    searchDim b s = 1 ↔ s = b := by
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  have hlogb : Real.log b ≠ 0 := ne_of_gt (Real.log_pos hbR)
  rw [searchDim, div_eq_one_iff_eq hlogb]
  constructor
  · intro h
    have : (s:ℝ) = b :=
      Real.log_injOn_pos (Set.mem_Ioi.2 hsR) (Set.mem_Ioi.2 (by linarith)) h
    exact_mod_cast this
  · intro h; rw [h]

/-- The fractal dimension is strictly increasing in the number of successful
branches: more ways to succeed means a genuinely higher-dimensional search set. -/
theorem dim_strictMono (b s t : ℕ) (hb : 1 < b) (hs : 1 ≤ s) (hst : s < t) :
    searchDim b s < searchDim b t := by
  have hbR : (1:ℝ) < b := by exact_mod_cast hb
  have hsR : (0:ℝ) < s := by exact_mod_cast Nat.lt_of_lt_of_le Nat.zero_lt_one hs
  have hstR : (s:ℝ) < t := by exact_mod_cast hst
  rw [searchDim, searchDim, div_lt_div_iff_of_pos_right (Real.log_pos hbR)]
  exact Real.log_lt_log hsR hstR

/-! ## Section 4 — Exhaustive search cost -/

/-- **Geometric search cost.**  An exhaustive search that expands every node down
to depth `n` visits `∑_{i=0}^{n} b^i` nodes, and this count satisfies the closed
geometric identity `(nodes) * (b - 1) = b^{n+1} - 1`. -/
theorem nodesExplored_geom (b n : ℕ) (hb : 2 ≤ b) :
    (∑ i ∈ Finset.range (n + 1), b ^ i) * (b - 1) = b ^ (n + 1) - 1 := by
  induction n with
  | zero => simp
  | succ k ih =>
    rw [Finset.sum_range_succ, add_mul, ih]
    have hstep : b ^ (k + 1) * (b - 1) = b ^ (k + 1 + 1) - b ^ (k + 1) := by
      rw [Nat.mul_sub, mul_one, ← pow_succ]
    rw [hstep]
    have h1 : 1 ≤ b ^ (k + 1) := Nat.one_le_pow _ _ (by omega)
    have h2 : b ^ (k + 1) ≤ b ^ (k + 1 + 1) := Nat.pow_le_pow_right (by omega) (by omega)
    omega

/-! ## Section 5 — Examples, generalizations, boundaries -/

-- Example: binary search space, one branch always fails (`s = 1`): a unique proof
-- path, dimension `0`.
example : searchDim 2 1 = 0 := by simp [searchDim]

-- Example: full binary tree (`s = b = 2`): every path succeeds, dimension `1`.
example : searchDim 2 2 = 1 := by
  have h : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  simp only [searchDim, Nat.cast_ofNat]
  exact div_self h

-- Example: the bridge identity, instantiated at `b = 3, s = 2, n = 4`:
-- `2^4 = (3^4) ^ (log 2 / log 3)`.
example : ((succPaths 2 4 : ℝ)) = ((totalPaths 3 4 : ℝ)) ^ (searchDim 3 2) :=
  dim_scaling 3 2 4 (by norm_num) (by norm_num)

#check @dim_scaling
#check @dim_codimension_density
#check @dim_eq_one_iff

/-!
### Generalization

The self-similar model assumes a *constant* successful sub-branching factor `s`.
The construction extends to variable branching `sᵢ` at level `i`, where the
successful path count becomes `∏ sᵢ` and the dimension is replaced by the limiting
average `lim (∑ log sᵢ) / (∑ log bᵢ)`.  The bridge identity `succ = total^D`
persists whenever this average converges, linking multiplicative combinatorics to
Besicovitch-type dimension spectra.

### Boundary cases

* `s = 1` (dimension `0`): a rigid, unique proof — the boundary set is a single
  point, whose similarity dimension is genuinely `0`.
* `s = b` (dimension `1`): the whole boundary succeeds; `dim_eq_one_iff` shows
  this is the *only* way to reach dimension `1`, so `D = 1` is a sharp threshold,
  not a generic value.
* `b = 1`: excluded (`hb : 1 < b`) because `log 1 = 0` makes the similarity metric
  degenerate — a "search space" with no genuine branching has no meaningful
  dimension. This is the boundary where the model breaks down.
-/

/-!
-- !-- Lab Notes -- !--

**Hypothesis.**  The informal conjecture states that proof-search difficulty is a
fractal quantity `D(T)` with `D ≈ 1` for typical theorems, `D ≪ 1` for obvious
ones, and `D` controlling proof length.  We hypothesized that this becomes a
*precise* statement for self-similar search spaces, where `D` is the similarity
dimension of the Cantor set of successful paths, `D = log s / log b`.

**Experiment.**  We modelled the search space as a complete `b`-ary tree with a
self-similar successful sub-branching factor `s`.  We proved (a) the exact count
`s^n` of successful depth-`n` paths, (b) the *bridge identity* `s^n = (b^n)^D`
tying combinatorial growth to the analytic exponent `D`, (c) the density/codimension
law `(s/b)^n = (b^n)^{D-1}`, (d) the range `0 ≤ D ≤ 1` with sharp endpoints, and
(e) the geometric exhaustive-search cost.

**Analysis.**  The bridge identity is the heart of the matter: it shows the
"fractal exponent" is not a metaphor but the literal exponent converting the total
count into the successful count.  The endpoints are meaningful: `D = 0` ⇔ unique
proof, `D = 1` ⇔ unprunable search.  The naive reading of the informal conjecture
(`D > 1` for hard theorems) is *false* for a subset of the boundary: a self-similar
subset can never exceed the ambient dimension `1`.  The correct invariant for
"hardness" is the *codimension* `1 - D`: small codimension (D near 1) means slow
pruning and expensive search; large codimension means focused search.

**Critique.**  We guarded every theorem with `1 < b` (genuine branching) and
`1 ≤ s` (at least one proof exists), ruling out the degenerate `log 1 = 0` cases.
`dim_eq_one_iff` prevents the trivial over-claim that generic theorems have `D = 1`:
dimension `1` is a razor-sharp threshold hit only by fully unprunable problems.
The examples exhibit both endpoints concretely.

**Synthesis.**  Proof-search difficulty, for self-similar spaces, is captured
exactly by the similarity dimension `D = log s / log b ∈ [0,1]`, with the bridge
identity `succ = total^D` and codimension `1 - D` as the pruning rate.  This turns
a slogan into theorems and corrects the direction of the informal conjecture.
-/

end ProofSearchFractalDimension