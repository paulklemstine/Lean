import Computation.MixedRadixNumberSystem

/-!
# Mathematics as a Phase Transition: Sharp Thresholds of Monotone Discovery

This file formalizes the qualitative picture that a *monotone* accumulation
process (knowledge, connectivity, resources) does not drift gradually across the
boundary between "impossible" and "possible": once a monotone predicate becomes
true it stays true, so the whole transition is concentrated at a single
**threshold** value.  This is the discrete, order-theoretic skeleton shared by
percolation transitions, giant-component emergence, and the "sudden
reorganizations" of a growing body of mathematics.

We prove, for an arbitrary monotone predicate `P : ℕ → Prop` that is eventually
satisfied:

* `threshold` — the exact critical value (the least `n` with `P n`);
* `subcritical` / `supercritical` — below the threshold the predicate is
  uniformly false, at and above it uniformly true (the transition is *sharp*:
  a single jump, never a gradual slope);
* `threshold_spec` — the combined two-phase description;
* `active_eq_Ici` — the "percolated region" `{n | P n}` is exactly the up-set
  `[threshold, ∞)`;
* `threshold_unique` — sharpness pins the critical value uniquely;
* `threshold_le_iff` / `lt_threshold_iff` — the comparison calculus of the
  critical value.

As a concrete, cross-domain instance we specialize to the *running product of
bases* `radixProd` of the catalog's mixed-radix number systems
(`Catalog/Computation/MixedRadixNumberSystem.lean`).  When the bases are at least
`2`, the running product grows without bound, so *reaching any prescribed
capacity* `T ≤ radixProd b k` is a monotone event with a sharp threshold in the
word length `k`: a positional system crosses from "too small to represent `T`" to
"large enough" at a single, well-defined length.  This links the abstract
phase-transition skeleton to the catalog's positional-number-system theory.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Any process describable by a monotone
  yes/no predicate on a well-ordered timeline should exhibit a *sharp* threshold:
  the set of "successful" times is an up-set, hence an interval `[τ, ∞)`, so all
  of the transition happens at one point.  Gradualness is impossible for monotone
  predicates on `ℕ`.
* **Experiment (Experimenter).**  Formalized the threshold as `Nat.find` of the
  eventual-truth witness.  Sub/supercritical phases follow from
  `Nat.find_min`/`Nat.find_spec` together with monotonicity.  Instantiated the
  skeleton on `MixedRadix.radixProd`, proving monotone growth of the running
  product from the catalog lemma `radixProd_succ` and an unbounded-growth
  estimate `radixProd b k ≥ 2 ^ k` under `b i ≥ 2`.
* **Analysis (Analyst).**  "True and structural."  The only genuinely infinite
  input is the eventual-truth hypothesis; everything else is order theory.  The
  capacity instance shows the abstract theorem is not vacuous: positional systems
  really do undergo a length threshold, and the threshold is computable.
* **Critique (Critic).**  Corner cases: `P 0` true means the threshold is `0`
  and the subcritical phase is empty — still a valid (degenerate) transition, not
  a false claim.  Monotonicity is essential: without it the "active" set need not
  be an interval, and `active_eq_Ici` fails; we therefore keep monotonicity as an
  explicit hypothesis rather than hiding it.
* **Synthesis (PI).**  Sharp thresholds are the order-theoretic invariant behind
  "phase transitions" in discovery: the catalog's number systems inherit one for
  representational capacity, and the same skeleton governs any monotone growth of
  mathematical structure.
-/

namespace PhaseTransition

open MixedRadix

/-! ## 1. The abstract sharp-threshold theorem -/

variable {P : ℕ → Prop} [DecidablePred P]

/-- The **critical value** of a monotone, eventually-true predicate: the least
`n` at which the predicate first holds. -/
noncomputable def threshold (h : ∃ n, P n) : ℕ := Nat.find h

/-- **Supercritical phase.**  At the threshold, and everywhere above it (using
monotonicity), the predicate holds. -/
theorem supercritical (hmono : ∀ n, P n → P (n + 1)) (h : ∃ n, P n)
    {n : ℕ} (hn : threshold h ≤ n) : P n := by
  have hbase : P (threshold h) := Nat.find_spec h
  obtain ⟨k, rfl⟩ := Nat.le.dest hn
  clear hn
  induction k with
  | zero => simpa using hbase
  | succ k ih =>
    have : threshold h + (k + 1) = (threshold h + k) + 1 := by ring
    rw [this]
    exact hmono _ ih

/-- **Subcritical phase.**  Strictly below the threshold the predicate fails
(with no monotonicity needed): the threshold is by definition the *first* success. -/
theorem subcritical (h : ∃ n, P n) {n : ℕ} (hn : n < threshold h) : ¬ P n :=
  Nat.find_min h hn

/-- **Sharp two-phase description.**  A monotone eventually-true predicate is
false below the threshold and true at/above it: the transition is a single jump,
never a gradual slope. -/
theorem threshold_spec (hmono : ∀ n, P n → P (n + 1)) (h : ∃ n, P n) :
    (∀ n < threshold h, ¬ P n) ∧ (∀ n, threshold h ≤ n → P n) :=
  ⟨fun _ hn => subcritical h hn, fun _ hn => supercritical hmono h hn⟩

/-- **The percolated region is an up-set.**  The set of times at which the
predicate holds is exactly the closed-above interval `[threshold, ∞)`. -/
theorem active_eq_Ici (hmono : ∀ n, P n → P (n + 1)) (h : ∃ n, P n) :
    {n | P n} = Set.Ici (threshold h) := by
  ext n
  constructor
  · intro hPn
    by_contra hlt
    exact subcritical h (lt_of_not_ge hlt) hPn
  · intro hn
    exact supercritical hmono h hn

/-- **Uniqueness of the critical value.**  Any value that separates a uniformly
false phase from a uniformly true phase must be the threshold.  This is the
formal content of "the phase transition happens at a well-defined point." -/
theorem threshold_unique (h : ∃ n, P n) {t : ℕ}
    (hbelow : ∀ n < t, ¬ P n) (hat : P t) : t = threshold h := by
  have h1 : threshold h ≤ t := Nat.find_le hat
  have h2 : ¬ t < threshold h := fun hc => (subcritical h hc) hat
  rcases lt_or_eq_of_le h1 with hlt | heq
  · exact absurd (Nat.find_spec h) (hbelow _ hlt)
  · exact heq.symm

/-- Comparison calculus: the threshold is `≤ m` iff the predicate already holds
at `m`. -/
theorem threshold_le_iff (hmono : ∀ n, P n → P (n + 1)) (h : ∃ n, P n) {m : ℕ} :
    threshold h ≤ m ↔ P m :=
  ⟨fun hm => supercritical hmono h hm, fun hm => Nat.find_le hm⟩

/-- Comparison calculus: `m` is strictly subcritical iff the predicate fails at
`m`. -/
theorem lt_threshold_iff (hmono : ∀ n, P n → P (n + 1)) (h : ∃ n, P n) {m : ℕ} :
    m < threshold h ↔ ¬ P m := by
  rw [← not_le, threshold_le_iff hmono h]

/-! ## 2. Cross-domain instance: representational capacity of mixed-radix systems

The running product `radixProd b k = ∏_{i<k} b i` is the number of length-`k`
words in the mixed-radix system with bases `b`.  With bases at least `2` this
grows past every capacity, so "the system can represent `T` distinct values"
is a monotone, eventually-true event in the word length `k`. -/

/-- The running product of bases is monotone in the word length once every base
is positive: adding a place cannot shrink the capacity.  Proved from the
catalog's `radixProd_succ`. -/
theorem radixProd_mono {b : ℕ → ℕ} (hb : ∀ i, 1 ≤ b i) {k : ℕ} :
    radixProd b k ≤ radixProd b (k + 1) := by
  rw [radixProd_succ]
  calc radixProd b k = radixProd b k * 1 := (mul_one _).symm
    _ ≤ radixProd b k * b k := by
        exact Nat.mul_le_mul_left _ (hb k)

/-- With bases at least `2`, the capacity dominates `2 ^ k`, hence grows without
bound. -/
theorem two_pow_le_radixProd {b : ℕ → ℕ} (hb : ∀ i, 2 ≤ b i) (k : ℕ) :
    2 ^ k ≤ radixProd b k := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [radixProd_succ, pow_succ]
    exact Nat.mul_le_mul ih (hb k)

/-- **Capacity is eventually reached.**  For bases at least `2` and any target
capacity `T`, some word length attains it. -/
theorem capacity_eventually {b : ℕ → ℕ} (hb : ∀ i, 2 ≤ b i) (T : ℕ) :
    ∃ k, T ≤ radixProd b k := by
  refine ⟨T, le_trans ?_ (two_pow_le_radixProd hb T)⟩
  exact Nat.le_of_lt (Nat.lt_two_pow_self)

/-- **Sharp length threshold for representational capacity.**  Reaching a target
capacity `T` in a base-at-least-`2` mixed-radix system is a monotone event in the
word length `k`, hence occurs at a single sharp threshold length: below it the
system is too small to hold `T` values, at and above it the system suffices.
This is the phase-transition skeleton instantiated on the catalog's positional
number systems. -/
theorem capacity_sharp_threshold {b : ℕ → ℕ} (hb : ∀ i, 2 ≤ b i) (T : ℕ) :
    ∃ τ : ℕ, (∀ k < τ, radixProd b k < T) ∧ (∀ k, τ ≤ k → T ≤ radixProd b k) := by
  classical
  have hmono : ∀ k, (fun m => T ≤ radixProd b m) k → (fun m => T ≤ radixProd b m) (k + 1) :=
    fun k hk => le_trans hk (radixProd_mono (fun i => le_trans (by norm_num) (hb i)))
  have hex : ∃ k, (fun m => T ≤ radixProd b m) k := capacity_eventually hb T
  refine ⟨threshold hex, ?_, ?_⟩
  · intro k hk
    exact lt_of_not_ge (subcritical hex hk)
  · intro k hk
    exact supercritical hmono hex hk

end PhaseTransition