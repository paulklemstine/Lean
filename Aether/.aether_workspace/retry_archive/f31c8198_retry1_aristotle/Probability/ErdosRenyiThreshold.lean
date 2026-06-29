/-
  # Threshold phenomena for the Erdős–Rényi random graph `G(n,p)`

  This file develops, from first principles, the *first–moment* and *second–moment*
  machinery underlying the classical threshold theorems for the Erdős–Rényi random
  graph `G(n,p)`, together with faithful statements of the three headline threshold
  results (connectivity, the emergence of the giant component, and the second–moment
  method for subgraph counts).

  ## Design

  We model `G(n,p)` *elementarily* as a finite probability distribution on the type
  of *configurations*.  A configuration is a `Finset α`, where `α` is the finite type
  of *potential edges*; the finset records exactly which edges are present.  Under
  `G(n,p)` each potential edge is included independently with probability `p`, so the
  probability mass of a configuration `s` is

  `mass p s = p ^ |s| * (1 - p) ^ (N - |s|)`,   where `N = |α|`.

  This is a genuine probability distribution: `∑ s, mass p s = 1` (a binomial
  expansion, `ErdosRenyi.total_mass`).  Modelling the law elementarily — rather than
  through `MeasureTheory` — keeps every probability a finite real sum, so the
  independence and linearity computations reduce to clean `Finset` identities.

  ## Dependency structure (no circularity)

  The lemmas are arranged so that each only uses results stated strictly *before* it,
  exactly as required:

  1. `mass_nonneg`, `total_mass`              -- basic facts about the distribution
  2. `prob_contains_subset`                   -- **independence of edge events**
  3. `union_bound`                            -- **standalone union bound**
  4. `expected_count`                         -- **linearity of expectation**
  5. `first_moment_threshold`                 -- uses `union_bound` + `prob_contains_subset`
  6. `prob_eq_zero_le_variance_div_sq`        -- Chebyshev / second–moment inequality
  7. `tendsto_zero_of_variance_bound`         -- analytic squeeze used by ↓
  8. `subgraph_count_pos_whp`                 -- **second–moment method** (uses 6 + 7)

  The two deepest asymptotic results — the sharp connectivity threshold with its
  Poisson `e^{-e^{-c}}` limit, and the birth of the giant component — are stated
  faithfully (`connectivity_threshold`, `giant_component_supercritical`,
  `giant_component_subcritical`).  Their proofs require substantial probabilistic
  machinery (a Poisson limit theorem for the isolated–vertex count and a
  branching–process coupling) that is not currently available in Mathlib; they are
  therefore left as `sorry` and flagged as open formalization targets in the
  "Open questions" section at the end of the file.
-/
import Mathlib

open Finset BigOperators Filter Topology
open scoped Classical

namespace ErdosRenyi

/-! ## 1.  The `G(n,p)` distribution -/

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- The probability mass that `G(n,p)` assigns to the configuration `s : Finset α`
(the set of present edges): the `|s|` present edges each contribute a factor `p`, and
the remaining `N - |s|` absent edges each contribute a factor `1 - p`. -/
noncomputable def mass (p : ℝ) (s : Finset α) : ℝ :=
  p ^ s.card * (1 - p) ^ (Fintype.card α - s.card)

/-- The probability of an event `E`, presented as a finite set of configurations:
the sum of the masses of the configurations in `E`. -/
noncomputable def Prob (p : ℝ) (E : Finset (Finset α)) : ℝ := ∑ s ∈ E, mass p s

omit [DecidableEq α] in
/-- Masses are nonnegative when `p` is a genuine probability. -/
lemma mass_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (s : Finset α) :
    0 ≤ mass p s := by
      exact mul_nonneg ( pow_nonneg hp0 _ ) ( pow_nonneg ( sub_nonneg.2 hp1 ) _ )

omit [DecidableEq α] in
/-- **The model is a probability distribution.**  The total mass is `1`, obtained by
the binomial expansion `∑_{s ⊆ univ} p^{|s|}(1-p)^{N-|s|} = (p + (1-p))^N = 1`. -/
lemma total_mass (p : ℝ) :
    ∑ s ∈ (Finset.univ : Finset (Finset α)), mass p s = 1 := by
  unfold mass
  rw [← Finset.powerset_univ, ← Finset.card_univ (α := α)]
  rw [Finset.sum_pow_mul_eq_add_pow]
  simp

omit [DecidableEq α] in
/-- Probabilities are nonnegative when `p ∈ [0,1]`. -/
lemma Prob_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (E : Finset (Finset α)) :
    0 ≤ Prob p E := by
      exact Finset.sum_nonneg fun s hs => mul_nonneg ( pow_nonneg hp0 _ ) ( pow_nonneg ( sub_nonneg.2 hp1 ) _ )

/-! ## 2.  Independence of edge events

The basic independence statement: the probability that the random graph contains a
*fixed* set `T` of edges is exactly `p^{|T|}`, irrespective of the other edges.  This
is the engine behind every first–moment computation. -/

/-
**Independence of edge events.**  The probability that `G(n,p)` contains every
edge of a fixed set `T` equals `p ^ |T|`.

The event `{s | T ⊆ s}` is in bijection (via `s ↦ s \ T`, with inverse `R ↦ T ∪ R`)
with the subsets `R` of the complementary edge set `Tᶜ`.  Summing the masses,
`∑_{R ⊆ Tᶜ} p^{|T| + |R|}(1-p)^{|Tᶜ| - |R|} = p^{|T|} (p + (1-p))^{|Tᶜ|} = p^{|T|}`.
-/
lemma prob_contains_subset (p : ℝ) (T : Finset α) :
    Prob p (Finset.univ.filter (fun s => T ⊆ s)) = p ^ T.card := by
      have h_reindex_step : ∑ s ∈ Finset.filter (fun s => T ⊆ s) (Finset.univ : Finset (Finset α)), p ^ s.card * (1 - p) ^ (Fintype.card α - s.card) = ∑ R ∈ (Finset.univ : Finset (Finset α)).filter (fun R => R ⊆ Tᶜ), p ^ (T.card + R.card) * (1 - p) ^ ((Fintype.card α - T.card) - R.card) := by
        refine' Finset.sum_bij ( fun s hs => s \ T ) _ _ _ _;
        · simp +contextual [ Finset.subset_iff ];
        · simp +contextual [ Finset.ext_iff ];
          grind;
        · intro R hR; use T ∪ R; simp_all +decide [ Finset.subset_iff ] ;
          grind;
        · simp +decide [ Finset.card_sdiff, tsub_tsub ];
          intro a ha; rw [ Finset.inter_eq_left.mpr ha, add_tsub_cancel_of_le ( Finset.card_le_card ha ) ] ;
      -- Apply the binomial theorem to the sum.
      have h_binom : ∑ R ∈ (Finset.univ : Finset (Finset α)).filter (fun R => R ⊆ Tᶜ), p ^ R.card * (1 - p) ^ ((Fintype.card α - T.card) - R.card) = (p + (1 - p)) ^ (Fintype.card α - T.card) := by
        convert Finset.sum_powerset ( Tᶜ ) fun x => p ^ x.card * ( 1 - p ) ^ ( Fintype.card α - T.card - x.card ) using 1;
        · rcongr R ; aesop;
        · rw [ add_pow ];
          simp +decide [ Finset.card_compl ];
          exact Finset.sum_congr rfl fun i hi => by rw [ Finset.sum_congr rfl fun x hx => by rw [ Finset.mem_powersetCard.mp hx |>.2 ] ] ; simp +decide [ mul_comm, Finset.card_compl ] ;
      convert congr_arg ( fun x : ℝ => p ^ T.card * x ) h_binom using 1;
      · convert h_reindex_step using 1;
        simp +decide only [Finset.mul_sum _ _ _, pow_add, mul_assoc];
      · norm_num

/-! ## 3.  The union bound

A completely general, standalone union bound for the finite model: the probability of
a finite union of events is at most the sum of their probabilities. -/

/-
**Union bound.**  For a finite index set `A` and events `ev a`, the probability of
the union `⋃ a ∈ A, ev a` (modelled by `A.biUnion ev`) is at most `∑ a ∈ A, Prob (ev a)`.
The proof only uses nonnegativity of the masses: each configuration in the union is
counted at least once on the right.
-/
lemma union_bound {ι : Type*} [DecidableEq ι] {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (A : Finset ι) (ev : ι → Finset (Finset α)) :
    Prob p (A.biUnion ev) ≤ ∑ a ∈ A, Prob p (ev a) := by
      induction' A using Finset.induction with a A ha ih;
      · simp +decide [ Prob ];
      · -- By the properties of the union and the induction hypothesis, we have:
        have h_union : Prob p (ev a ∪ A.biUnion ev) ≤ Prob p (ev a) + Prob p (A.biUnion ev) := by
          unfold Prob;
          rw [ ← Finset.sum_union_inter ];
          exact le_add_of_nonneg_right ( Finset.sum_nonneg fun _ _ => mass_nonneg hp0 hp1 _ );
        simp_all +decide [ Finset.biUnion_insert ];
        linarith

/-! ## 4.  Linearity of expectation and the expected subgraph count -/

/-- Expectation of a real random variable `X` (a function on configurations) under
`G(n,p)`. -/
noncomputable def Expect (p : ℝ) (X : Finset α → ℝ) : ℝ :=
  ∑ s ∈ (Finset.univ : Finset (Finset α)), mass p s * X s

omit [DecidableEq α] in
/-- Linearity of expectation over a finite family. -/
lemma Expect_sum (p : ℝ) {ι : Type*} (A : Finset ι) (f : ι → Finset α → ℝ) :
    Expect p (fun s => ∑ a ∈ A, f a s) = ∑ a ∈ A, Expect p (fun s => f a s) := by
      simp +decide only [Expect];
      rw [ Finset.sum_comm, Finset.sum_congr rfl fun _ _ => Finset.mul_sum _ _ _ ]

/-
The expectation of the indicator of the event "`T` is contained" equals `p^{|T|}`
(the `Expect`/`Prob` translation of `prob_contains_subset`).
-/
lemma Expect_indicator_contains (p : ℝ) (T : Finset α) :
    Expect p (fun s => if T ⊆ s then (1 : ℝ) else 0) = p ^ T.card := by
      convert prob_contains_subset p T using 1;
      simp +decide [ Expect, Prob ];
      rw [ Finset.sum_filter ]

/-- The number of members of the family `𝒯` that are present in the configuration `s`
(i.e. the number of "copies" realised by `s`). -/
noncomputable def count (𝒯 : Finset (Finset α)) (s : Finset α) : ℕ :=
  (𝒯.filter (fun T => T ⊆ s)).card

/-
**Expected count (linearity of expectation).**  For a family `𝒯` of edge sets, the
expected number of members present equals `∑ T ∈ 𝒯, p^{|T|}`.  This is linearity of
expectation (`Expect_sum`) applied to the sum of indicators, together with
`Expect_indicator_contains`.
-/
lemma expected_count (p : ℝ) (𝒯 : Finset (Finset α)) :
    Expect p (fun s => (count 𝒯 s : ℝ)) = ∑ T ∈ 𝒯, p ^ T.card := by
      -- By definition of count, we can rewrite the expectation as a sum over the family 𝒯.
      have h_count_def : ∀ s : Finset α, (count 𝒯 s : ℝ) = ∑ T ∈ 𝒯, (if T ⊆ s then 1 else 0) := by
        simp +decide [ count ];
      convert Expect_sum p 𝒯 ( fun T s => if T ⊆ s then 1 else 0 ) using 1;
      · simp only [ h_count_def ];
      · exact Finset.sum_congr rfl fun x hx => by rw [ Expect_indicator_contains ] ;

/-! ## 5.  The first–moment threshold -/

/-
**First–moment threshold.**  The probability that *some* member of the family `𝒯`
appears is at most the expected count `∑ T ∈ 𝒯, p^{|T|}`.  This is `union_bound`
applied to the events `{s | T ⊆ s}`, evaluated with `prob_contains_subset`.

Consequently, if `∑ T ∈ 𝒯, p^{|T|} → 0` then a.a.s. no copy appears — the standard
first–moment vanishing criterion.
-/
lemma first_moment_threshold {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (𝒯 : Finset (Finset α)) :
    Prob p (𝒯.biUnion (fun T => Finset.univ.filter (fun s => T ⊆ s)))
      ≤ ∑ T ∈ 𝒯, p ^ T.card := by
        convert union_bound hp0 hp1 ( 𝒯.image id ) ( fun T ↦ Finset.univ.filter ( fun s ↦ T ⊆ s ) ) using 1;
        · aesop;
        · simp +decide [ prob_contains_subset ]

/-! ## 6.  The second–moment method

The variance of a random variable and Chebyshev's inequality, specialised to the
key "second–moment" inequality `P(X = 0) ≤ Var X / (E X)²`. -/

/-- Variance of `X` under `G(n,p)`. -/
noncomputable def Variance (p : ℝ) (X : Finset α → ℝ) : ℝ :=
  Expect p (fun s => (X s - Expect p X) ^ 2)

/-- The probability that `X = 0`. -/
noncomputable def probZero (p : ℝ) (X : Finset α → ℝ) : ℝ :=
  ∑ s ∈ (Finset.univ.filter (fun s => X s = 0)), mass p s

/-
**Second–moment inequality (Chebyshev).**  For any `X`,
`P(X = 0) ≤ Var X / (E X)²` (when `E X ≠ 0`).

On the event `{X = 0}` we have `(X - E X)² = (E X)²`, so the variance — a sum of
nonnegative terms — is at least `(E X)² · P(X = 0)`. -/
omit [DecidableEq α] in
lemma prob_eq_zero_le_variance_div_sq {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (X : Finset α → ℝ) (hEX : Expect p X ≠ 0) :
    probZero p X ≤ Variance p X / (Expect p X) ^ 2 := by
      rw [ le_div_iff₀ ( by positivity ) ];
      convert Finset.sum_le_sum_of_subset_of_nonneg _ _ using 1;
      case convert_6 => exact Finset.univ.filter fun s => X s = 0;
      · simp +decide [ probZero ];
        rw [ Finset.sum_mul _ _ _ ] ; exact Finset.sum_congr rfl fun x hx => by rw [ Finset.mem_filter.mp hx |>.2 ] ; ring;
      · infer_instance;
      · exact Finset.subset_univ _;
      · exact fun _ _ _ => mul_nonneg ( mass_nonneg hp0 hp1 _ ) ( sq_nonneg _ )

/-
**Analytic squeeze.**  If a nonnegative sequence `P0 n` is bounded by
`V n / (E n)²`, the means `E n` tend to `+∞`, and the variances satisfy
`V n ≤ C · E n` (i.e. `Var = O(E)`), then `P0 n → 0`.  Indeed
`V n / (E n)² ≤ C / E n → 0`.
-/
lemma tendsto_zero_of_variance_bound (E V P0 : ℕ → ℝ)
    (hP0 : ∀ n, 0 ≤ P0 n) (hbound : ∀ n, P0 n ≤ V n / (E n) ^ 2)
    (hE : Tendsto E atTop atTop) (C : ℝ) (hV : ∀ n, V n ≤ C * E n) :
    Tendsto P0 atTop (𝓝 0) := by
      refine' squeeze_zero ( fun n => hP0 n ) ( fun n => le_trans ( hbound n ) _ ) _;
      use fun n => C / E n;
      · by_cases hn : E n = 0 <;> simp_all +decide [ div_le_iff₀, sq ];
        simpa [ div_mul, hn ] using hV n;
      · exact tendsto_const_nhds.div_atTop hE

/-- **Second–moment method for subgraph counts.**  Consider a family of probability
spaces (indexed by `n`) with potential–edge types `ι n`, edge probabilities `p n`,
and a nonnegative random variable `X n` (e.g. the number of copies of a fixed
subgraph `H`).  If the expected count `E n` tends to `∞` and the variance is
`O(E n)`, then a.a.s. `X n ≠ 0`: the probability of seeing *no* copy tends to `0`.

This is the conjunction of the Chebyshev inequality `prob_eq_zero_le_variance_div_sq`
(applied in each space) with the analytic squeeze `tendsto_zero_of_variance_bound`. -/
theorem subgraph_count_pos_whp
    {ι : ℕ → Type*} [∀ n, Fintype (ι n)] [∀ n, DecidableEq (ι n)]
    (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n) (hp1 : ∀ n, p n ≤ 1)
    (X : ∀ n, Finset (ι n) → ℝ)
    (E V : ℕ → ℝ)
    (hEdef : ∀ n, Expect (p n) (X n) = E n)
    (hVdef : ∀ n, Variance (p n) (X n) = V n)
    (hEne : ∀ n, E n ≠ 0)
    (hElim : Tendsto E atTop atTop) (C : ℝ) (hVO : ∀ n, V n ≤ C * E n) :
    Tendsto (fun n => probZero (p n) (X n)) atTop (𝓝 0) := by
  -- per-space Chebyshev gives the bound; the analytic squeeze finishes the job.
  apply tendsto_zero_of_variance_bound E V (fun n => probZero (p n) (X n)) ?_ ?_ hElim C hVO
  · intro n
    have := Prob_nonneg (p := p n) (hp0 n) (hp1 n)
      (Finset.univ.filter (fun s => X n s = 0))
    simpa [probZero, Prob] using this
  · intro n
    have h := prob_eq_zero_le_variance_div_sq (hp0 n) (hp1 n) (X n) (hEdef n ▸ hEne n)
    rw [hEdef n, hVdef n] at h
    exact h

/-! ## 7.  The connectivity threshold

We now turn to the graph–theoretic threshold theorems.  For these we instantiate the
potential–edge type as the non-loop pairs of vertices on `Fin n`, and turn a
configuration into an honest `SimpleGraph (Fin n)`.

The connectivity theorem below is the sharp threshold:
for `p = (log n + c)/n`, the probability that `G(n,p)` is connected converges to the
Gumbel/Poisson limit `e^{-e^{-c}}`.  The mechanism is that, at this density, the only
obstruction to connectivity is (a.a.s.) the presence of an isolated vertex, and the
number of isolated vertices is asymptotically `Poisson(e^{-c})`. -/

/-- The type of potential edges of the complete graph on `Fin n`: unordered, non-loop
pairs of vertices. -/
abbrev Edge (n : ℕ) : Type := {e : Sym2 (Fin n) // ¬ e.IsDiag}

/-- The simple graph on `Fin n` whose edge set is exactly the configuration `s`. -/
noncomputable def graphOf {n : ℕ} (s : Finset (Edge n)) : SimpleGraph (Fin n) :=
  SimpleGraph.fromEdgeSet ((fun e : Edge n => (e : Sym2 (Fin n))) '' (s : Set (Edge n)))

/-- **Sharp connectivity threshold (Poisson limit).**  For `p_n = (log n + c)/n`, the
probability that `G(n, p_n)` is connected converges to `e^{-e^{-c}}` as `n → ∞`.

*Proof idea.*  Write `D_n` for the event of disconnection.  A disconnected graph either
has an isolated vertex or splits off a component of size `2 ≤ k ≤ n/2`.  A first–moment
computation (`first_moment_threshold`) shows the expected number of small split-off
components of size `≥ 2` tends to `0`, so disconnection is a.a.s. *caused by an isolated
vertex*.  The number `I_n` of isolated vertices has expectation
`n (1-p_n)^{n-1} → e^{-c}`, and by the method of moments `I_n` converges in
distribution to `Poisson(e^{-c})`; hence `P(I_n = 0) → e^{-e^{-c}}`, giving the claimed
limit for connectivity.

The full proof needs a Poisson convergence theorem for the isolated–vertex count,
which is not yet in Mathlib; we record the statement and leave it open. -/
theorem connectivity_threshold (c : ℝ) :
    Tendsto
      (fun n : ℕ => Prob ((Real.log n + c) / n)
        (Finset.univ.filter (fun s : Finset (Edge n) => (graphOf s).Connected)))
      atTop (𝓝 (Real.exp (-(Real.exp (-c))))) := by
  sorry

/-! ## 8.  The giant component

For `p = (1 + ε)/n` with `ε > 0` fixed (the supercritical regime), the largest
connected component has size `Θ(n)` with high probability, whereas for `p = (1 - ε)/n`
(subcritical) every component has size `O(log n)`.  The standard proof couples the
component-exploration process with a Galton–Watson branching process of mean
`np = 1 ± ε`, and uses a first–moment bound on the number of large components. -/

/-- The size of the largest connected component of the configuration `s`
(the maximum, over vertices, of the cardinality of the connected component). -/
noncomputable def largestComponent {n : ℕ} (s : Finset (Edge n)) : ℕ := by
  classical
  exact Finset.sup Finset.univ
    (fun v : Fin n => ((graphOf s).connectedComponentMk v |>.supp).toFinset.card)

/-- **Supercritical giant component.**  For `p = (1 + ε)/n` with `ε > 0`, there is a
constant `β > 0` such that, with probability tending to `1`, the largest component has
size at least `β · n` — i.e. a *giant* component of linear size emerges.

*Proof idea.*  The exploration of a component from a fixed vertex dominates a
`Galton–Watson(Binomial(n-1, p))` process whose mean `np = 1 + ε > 1` is supercritical;
such a process survives with positive probability `ρ = ρ(ε) > 0`.  A second–moment
argument shows the number of vertices in "large" components concentrates around `ρ n`,
producing a unique component of size `Θ(n)`.  The branching-process survival theory and
the concentration step are not yet available in Mathlib. -/
theorem giant_component_supercritical {ε : ℝ} (hε : 0 < ε) :
    ∃ β : ℝ, 0 < β ∧
      Tendsto
        (fun n : ℕ => Prob ((1 + ε) / n)
          (Finset.univ.filter
            (fun s : Finset (Edge n) => (β * n : ℝ) ≤ largestComponent s)))
        atTop (𝓝 1) := by
  sorry

/-- **Subcritical regime: no giant component.**  For `p = (1 - ε)/n` with `0 < ε < 1`,
there is a constant `A` such that, with probability tending to `1`, *every* component
has size at most `A · log n`; in particular the largest component is `O(log n)`.

*Proof idea.*  Now the exploration process is dominated by a *subcritical*
`Galton–Watson` process (mean `np = 1 - ε < 1`), which dies out quickly: the
probability that a fixed vertex lies in a component of size `≥ k` decays exponentially
in `k`.  A first–moment (union) bound (`first_moment_threshold`) over all vertices then
shows no component exceeds `A log n`.  This again rests on quantitative
branching-process tail bounds not yet in Mathlib. -/
theorem giant_component_subcritical {ε : ℝ} (hε : 0 < ε) (hε1 : ε < 1) :
    ∃ A : ℝ, 0 < A ∧
      Tendsto
        (fun n : ℕ => Prob ((1 - ε) / n)
          (Finset.univ.filter
            (fun s : Finset (Edge n) => (largestComponent s : ℝ) ≤ A * Real.log n)))
        atTop (𝓝 1) := by
  sorry

/-! ## Open questions

The following are natural extensions of the results above that remain open *as Lean
formalizations* (the underlying mathematics is classical):

* **Poisson limit for the isolated–vertex count.**  The proof of
  `connectivity_threshold` reduces to showing that the number of isolated vertices of
  `G(n, (log n + c)/n)` converges in distribution to `Poisson(e^{-c})`.  A reusable
  method-of-moments / Stein–Chen Poisson convergence theorem in Mathlib would close
  this gap and many like it.

* **Branching-process coupling.**  Both giant-component statements rest on coupling the
  component-exploration process with a Galton–Watson process and on its survival
  probability `ρ(ε)`.  Formalizing Galton–Watson survival/extinction and the coupling
  inequality would make `giant_component_supercritical` and
  `giant_component_subcritical` provable.

* **Uniqueness of the giant component.**  Beyond mere existence of a `Θ(n)` component,
  one expects a *unique* giant component of size `(ρ + o(1)) n` in the supercritical
  regime; formalizing uniqueness is a further step.

* **Sharp threshold for Hamiltonicity.**  At `p = (log n + log log n + c)/n` the graph
  `G(n,p)` is Hamiltonian with probability `→ e^{-e^{-c}}`.  This is a strictly harder
  threshold than connectivity and would be a flagship target.

* **General subgraph thresholds (Bollobás).**  The threshold for the appearance of a
  fixed graph `H` is `n^{-1/m(H)}`, where `m(H)` is the maximum edge density of a
  subgraph of `H`.  The variance estimate feeding `subgraph_count_pos_whp` should be
  assembled into this general statement.
-/

end ErdosRenyi