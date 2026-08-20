/-
# Barcode invariants of the prime point cloud: total persistence and the Betti staircase

Building on `PrimePersistentHomology.lean`, where the zero-dimensional barcode of
the prime point cloud `P n = p_n` was shown to be governed by the sequence of
prime gaps, this file extracts two *quantitative* invariants of the barcode and
computes them exactly.

Throughout, `P n = nth Nat.Prime n` places the `n`-th prime on the real line and
the Vietoris–Rips scale parameter is `ε ≥ 0`.

## Main results

* `PrimeBarcode.totalPersistence_telescope` — for any strictly increasing point
  cloud on the line the *total persistence* of the first `n` finite `H₀` bars,
  the sum of the bar lengths, telescopes to `p_n − p_0`.

* `PrimeBarcode.prime_totalPersistence` — specialised to the primes this is the
  identity `total persistence = p_n − 2`: aggregate topological persistence of the
  prime barcode is the `n`-th prime minus two.

* `PrimeBarcode.prime_totalPersistence_sum_gaps` — equivalently the total
  persistence is the sum of the first `n` prime gaps, exhibiting the telescoping
  bridge between topology and the gap sequence.

* `PrimeBarcode.bettiZero_eq` — the **Betti staircase formula**: the number of
  `ε`-connected components among the first `n+1` points equals
  `1 + #{ i < n : gap_i > ε }`, so every downward step of the Betti curve is
  triggered by exactly one prime gap crossing the threshold `ε`.

* `PrimeBarcode.bettiZero_eq_one_iff` — the global-merge criterion: the cloud is a
  single component (`b₀ = 1`) exactly when `ε` dominates every internal gap.

* `PrimeBarcode.prime_bettiZero_eq` — the arithmetic reading of the Betti number
  of the prime cloud as one plus the number of prime gaps exceeding `ε`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer).  Two numerical invariants of the `H₀` barcode should be
computable in closed form from the gap sequence: the *total persistence* (sum of
bar lengths) and the *Betti number* `b₀(ε)` (number of components at scale `ε`).
The first should telescope to `p_n − 2`; the second should be a cumulative count
of gaps exceeding `ε`.

Experiment (Experimenter).  Total persistence is `∑_{i<n} (p_{i+1} − p_i)`, closed
by `Finset.sum_range_sub`.  For the Betti number we defined, for each index `i`,
its *component root* `root ε i = inf { k ≤ i : all gaps on [k,i) are ≤ ε }`, the
smallest index reachable by a chain of small gaps.  The number of components is the
number of distinct roots among `{0,…,n}`, and a root is characterised as an index
`r` with `r = 0` or `gap_{r-1} > ε` — a *component start*.

Analysis (Analyst).  The image of the root map equals the set of starts, and the
starts in `{0,…,n}` are `0` together with the shifted set `{ i+1 : i < n, gap_i > ε }`;
counting gives `b₀ = 1 + #{ i < n : gap_i > ε }`.  The single-component case
`b₀ = 1` is the assertion that no gap exceeds `ε`, i.e. the global merge scale is
the maximal gap.

Critique (Critic).  The root map is the genuine single-linkage component
representative (least index connected by a chain of `≤ ε` edges), not a
definitional restatement, so `bettiZero_eq` is a theorem.  Total persistence is
defined as an honest sum of bar lengths and the telescoping identity is proved,
not assumed.

Synthesis (PI).  The two headline invariants of persistent homology are, for the
primes, *exactly* arithmetic: total persistence is `p_n − 2` and the Betti curve is
the cumulative histogram of prime gaps.
-- !-- end Lab Notes -- !--
-/
import Mathlib
import Catalog.Novelty.PrimePersistentHomology

open scoped Classical

namespace PrimeBarcode

open PrimePH

/-! ### Total persistence -/

/-- The total persistence of the first `n` finite `H₀` bars: the sum of the bar
lengths, i.e. of the consecutive gaps `p_{i+1} − p_i` for `i < n`. -/
noncomputable def totalPersistence (p : ℕ → ℝ) (n : ℕ) : ℝ :=
  ∑ i ∈ Finset.range n, (p (i + 1) - p i)

/-
Total persistence telescopes to the endpoint difference `p_n − p_0`.
-/
theorem totalPersistence_telescope (p : ℕ → ℝ) (n : ℕ) :
    totalPersistence p n = p n - p 0 := by
  convert Finset.sum_range_sub p n

/-
The `0`-th prime, sitting at the origin of the prime cloud, is `2`.
-/
theorem prime_P_zero : P 0 = 2 := by
  -- By definition of `Nat.nth`, we know that `Nat.nth Nat.Prime 0` is the first prime number, which is 2.
  simp [P]

/-
**Total persistence of the prime barcode equals `p_n − 2`.**
-/
theorem prime_totalPersistence (n : ℕ) :
    totalPersistence P n = (Nat.nth Nat.Prime n : ℝ) - 2 := by
  -- Apply the telescoping sum result to rewrite the total persistence.
  rw [totalPersistence_telescope];
  -- By definition of $P$, we know that $P n = Nat.nth Nat.Prime n$.
  simp [P]

/-
Equivalently, the total persistence is the sum of the first `n` prime gaps.
-/
theorem prime_totalPersistence_sum_gaps (n : ℕ) :
    totalPersistence P n = ∑ i ∈ Finset.range n, (TwinPrimeGaps.primeGap i : ℝ) := by
  convert Finset.sum_congr rfl fun i hi => death_scale_eq_primeGap i

/-! ### The Betti number as a component count -/

/-- `leftRun p ε i k` says that starting from index `k ≤ i` every consecutive gap
up to `i` is at most `ε`; i.e. `k` reaches `i` by a chain of `≤ ε` edges. -/
def leftRun (p : ℕ → ℝ) (ε : ℝ) (i k : ℕ) : Prop :=
  k ≤ i ∧ ∀ j, k ≤ j → j < i → p (j + 1) - p j ≤ ε

/-- The single-linkage component representative of index `i`: the least index that
reaches `i` through a chain of edges of length `≤ ε`. -/
noncomputable def root (p : ℕ → ℝ) (ε : ℝ) (i : ℕ) : ℕ :=
  sInf {k | leftRun p ε i k}

/-- Every index reaches itself, so the defining set of the root is nonempty. -/
theorem leftRun_self (p : ℕ → ℝ) (ε : ℝ) (i : ℕ) : leftRun p ε i i :=
  ⟨le_rfl, fun _ h1 h2 => absurd h1 (Nat.not_le.mpr h2)⟩

/-
The root of `i` does not exceed `i`.
-/
theorem root_le (p : ℕ → ℝ) (ε : ℝ) (i : ℕ) : root p ε i ≤ i := by
  exact Nat.sInf_le ( leftRun_self p ε i )

/-
The root of `i` indeed reaches `i` through small gaps.
-/
theorem root_leftRun (p : ℕ → ℝ) (ε : ℝ) (i : ℕ) : leftRun p ε i (root p ε i) := by
  exact Nat.sInf_mem ( show ∃ k, leftRun p ε i k from ⟨ i, leftRun_self p ε i ⟩ )

/-
The root is a *component start*: it is either `0` or is preceded by a gap
exceeding `ε`.
-/
theorem root_is_start (p : ℕ → ℝ) (ε : ℝ) (i : ℕ) :
    root p ε i = 0 ∨ ε < p (root p ε i) - p (root p ε i - 1) := by
  -- By definition of `root`, we know that `root p ε i` is the least index `k` such that `leftRun p ε i k`.
  have h_root_def : ∀ k, leftRun p ε i k → root p ε i ≤ k := by
    exact fun k hk => Nat.sInf_le hk;
  have := root_leftRun p ε i; simp_all +decide [ leftRun ] ;
  grind

/-
A start is its own root.
-/
theorem root_eq_self_of_start (p : ℕ → ℝ) (ε : ℝ) {r : ℕ}
    (h : r = 0 ∨ ε < p r - p (r - 1)) : root p ε r = r := by
  refine' le_antisymm ( _ : root p ε r ≤ r ) _;
  · exact root_le p ε r;
  · contrapose! h;
    exact ⟨ by linarith, by have := root_leftRun p ε r; have := this.2 ( r - 1 ) ( by omega ) ( by omega ) ; cases r <;> aesop ⟩

/-- The Betti number `b₀(ε, n)`: the number of `ε`-connected components among the
first `n + 1` points, counted as the number of distinct component roots. -/
noncomputable def bettiZero (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).image (root p ε)).card

/-- The set of component starts among indices `0, …, n`. -/
noncomputable def startsSet (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) : Finset ℕ :=
  (Finset.range (n + 1)).filter (fun r => r = 0 ∨ ε < p r - p (r - 1))

/-
The image of the root map is exactly the set of component starts.
-/
theorem image_root_eq_startsSet (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) :
    (Finset.range (n + 1)).image (root p ε) = startsSet p ε n := by
  ext r; simp [startsSet];
  constructor;
  · rintro ⟨ a, ha, rfl ⟩ ; exact ⟨ le_trans ( root_le p ε a ) ha, root_is_start p ε a ⟩ ;
  · exact fun h => ⟨ r, h.1, root_eq_self_of_start p ε h.2 ⟩

/-
Counting the starts: one component for index `0`, plus one for every internal
gap exceeding `ε`.
-/
theorem startsSet_card (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) :
    (startsSet p ε n).card
      = 1 + ((Finset.range n).filter (fun i => ε < p (i + 1) - p i)).card := by
  rw [ show startsSet p ε n = insert 0 ( Finset.image ( fun i => i + 1 ) ( Finset.filter ( fun i => ε < p ( i + 1 ) - p i ) ( Finset.range n ) ) ) from ?_ ];
  · rw [ Finset.card_insert_of_notMem ] <;> norm_num [ add_comm, Finset.card_image_of_injective, Function.Injective ];
  · ext ( _ | i ) <;> simp +decide [ startsSet ]

/-
**The Betti staircase formula.**  The number of `ε`-components among the first
`n + 1` points equals `1 + #{ i < n : gap_i > ε }`.
-/
theorem bettiZero_eq (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) :
    bettiZero p ε n
      = 1 + ((Finset.range n).filter (fun i => ε < p (i + 1) - p i)).card := by
  rw [ ← startsSet_card, ← image_root_eq_startsSet ];
  rfl

/-
**Global merge criterion.**  The cloud is a single component precisely when
`ε` dominates every internal gap; the global merge scale is the maximal gap.
-/
theorem bettiZero_eq_one_iff (p : ℕ → ℝ) (ε : ℝ) (n : ℕ) :
    bettiZero p ε n = 1 ↔ ∀ i, i < n → p (i + 1) - p i ≤ ε := by
  rw [ bettiZero_eq, add_comm ];
  simp +decide [ Finset.ext_iff ]

/-! ### The prime specialisation -/

/-
The Betti number of the prime cloud at scale `ε` is one plus the number of
prime gaps (among the first `n`) that exceed `ε`.
-/
theorem prime_bettiZero_eq (ε : ℝ) (n : ℕ) :
    bettiZero P ε n
      = 1 + ((Finset.range n).filter
          (fun i => ε < (TwinPrimeGaps.primeGap i : ℝ))).card := by
  convert bettiZero_eq P ε n using 1;
  simp +decide [ death_scale_eq_primeGap ]

end PrimeBarcode