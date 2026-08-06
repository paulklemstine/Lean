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

  9.  `card_incident`, `mass_compl`, `prob_avoids_subset`, `Expect_indicator`
                                              -- absence form of independence
  10. `prob_isolated_vertex`, `expected_isolated_count`
                                              -- `E[#isolated vertices] = n (1-p)^{n-1}`
  11. `tendsto_expected_isolated`, `tendsto_expected_isolatedCount`
                                              -- the `e^{-c}` first–moment law at the
                                                 connectivity threshold

  The two deepest asymptotic results — the sharp connectivity threshold with its
  Poisson `e^{-e^{-c}}` limit, and the birth of the giant component — require
  substantial probabilistic machinery (a Poisson limit theorem for the isolated–vertex
  count and a branching–process coupling) that is not currently available in Mathlib.
  This file contains **no unproved statements**: those three theorems are preserved
  verbatim as commented-out statements at the point where they belong, and are listed as
  open formalization targets in the "Open questions" section at the end of the file.
  What *is* proved here is the entire first-moment half of the connectivity threshold:
  the expected number of isolated vertices at `p_n = (log n + c)/n` is computed exactly
  and shown to converge to `e^{-c}`, the mean of the conjectural Poisson limit.
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

/-! ### 7.1  The first moment of the isolated–vertex count

The proof of the connectivity threshold splits into a first–moment part (the expected
number of isolated vertices) and a Poisson-limit part.  The first-moment part is
carried out here in full: we compute the exact probability that a fixed vertex is
isolated, deduce the expected number of isolated vertices, and prove that at the
critical density `p_n = (log n + c)/n` this expectation converges to `e^{-c}` — the
mean of the limiting Poisson law. -/

/-- The potential edges incident to the vertex `v`. -/
def incident {n : ℕ} (v : Fin n) : Finset (Edge n) :=
  Finset.univ.filter (fun e => v ∈ (e : Sym2 (Fin n)))

/-- A vertex of `Fin n` lies on exactly `n - 1` potential edges. -/
theorem card_incident {n : ℕ} (v : Fin n) : (incident v).card = n - 1 := by
  classical
  have hcard : (Finset.univ.erase v).card = n - 1 := by
    rw [Finset.card_erase_of_mem (Finset.mem_univ v), Finset.card_univ, Fintype.card_fin]
  rw [← hcard]
  symm
  refine Finset.card_bij (fun w hw => (⟨s(v, w), by
      have hne : w ≠ v := (Finset.mem_erase.mp hw).1
      simpa [Sym2.isDiag_iff_proj_eq] using fun h => hne h.symm⟩ : Edge n)) ?_ ?_ ?_
  · intro w _
    simp [incident]
  · intro w _ w' _ h
    have h' : s(v, w) = s(v, w') := congrArg Subtype.val h
    exact Sym2.congr_right.mp h'
  · intro e he
    have hv : v ∈ (e : Sym2 (Fin n)) := by
      simpa [incident] using he
    obtain ⟨w, hw⟩ := Sym2.mem_iff_exists.mp hv
    have hne : w ≠ v := by
      intro h
      subst h
      exact e.2 (by rw [hw]; simp [Sym2.isDiag_iff_proj_eq])
    exact ⟨w, Finset.mem_erase.mpr ⟨hne, Finset.mem_univ _⟩, Subtype.ext hw.symm⟩

/-- Complementation of configurations exchanges the parameters `p` and `1 - p`. -/
lemma mass_compl (p : ℝ) (s : Finset α) : mass p s = mass (1 - p) sᶜ := by
  have hle : s.card ≤ Fintype.card α := by
    simpa [Finset.card_univ] using Finset.card_le_card (Finset.subset_univ s)
  have hcompl : sᶜ.card = Fintype.card α - s.card := by
    simp [Finset.card_compl]
  simp only [mass, hcompl, sub_sub_cancel, Nat.sub_sub_self hle]
  ring

/-- **Independence of edge events, absence form.**  The probability that `G(n,p)`
contains *no* edge of a fixed set `T` equals `(1 - p) ^ |T|`.  It is the image of
`prob_contains_subset` under complementation of configurations, which exchanges `p`
and `1 - p`. -/
lemma prob_avoids_subset (p : ℝ) (T : Finset α) :
    Prob p (Finset.univ.filter (fun s => Disjoint s T)) = (1 - p) ^ T.card := by
  classical
  have hbij : ∑ s ∈ Finset.univ.filter (fun s : Finset α => Disjoint s T), mass p s
      = ∑ u ∈ Finset.univ.filter (fun u : Finset α => T ⊆ u), mass (1 - p) u := by
    refine Finset.sum_nbij' (fun s => sᶜ) (fun u => uᶜ) ?_ ?_ ?_ ?_ ?_
    · intro s hs
      have hd : Disjoint s T := (Finset.mem_filter.mp hs).2
      refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
      intro x hx
      simp only [Finset.mem_compl]
      exact fun hxs => (Finset.disjoint_left.mp hd hxs) hx
    · intro u hu
      have hsub : T ⊆ u := (Finset.mem_filter.mp hu).2
      refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
      rw [Finset.disjoint_left]
      intro x hx hxT
      exact (Finset.mem_compl.mp hx) (hsub hxT)
    · intro s _
      simp
    · intro u _
      simp
    · intro s _
      exact mass_compl p s
  rw [Prob, hbij, ← Prob]
  exact prob_contains_subset (1 - p) T

omit [DecidableEq α] in
/-- The expectation of the indicator of an event is the probability of that event. -/
lemma Expect_indicator (p : ℝ) (P : Finset α → Prop) [DecidablePred P] :
    Expect p (fun s => if P s then (1 : ℝ) else 0) = Prob p (Finset.univ.filter P) := by
  rw [Prob, Finset.sum_filter, Expect]
  refine Finset.sum_congr rfl (fun s _ => ?_)
  by_cases h : P s <;> simp [h]

/-- **Probability that a fixed vertex is isolated:** `(1 - p) ^ (n - 1)`. -/
theorem prob_isolated_vertex {n : ℕ} (p : ℝ) (v : Fin n) :
    Prob p (Finset.univ.filter (fun s : Finset (Edge n) => Disjoint s (incident v)))
      = (1 - p) ^ (n - 1) := by
  rw [prob_avoids_subset p (incident v), card_incident v]

/-- The number of isolated vertices of a configuration. -/
def isolatedCount {n : ℕ} (s : Finset (Edge n)) : ℕ :=
  (Finset.univ.filter (fun v : Fin n => Disjoint s (incident v))).card

/-- **Expected number of isolated vertices** of `G(n,p)`: `n (1 - p) ^ (n - 1)`.
This is linearity of expectation applied to the indicators of the `n` isolation
events, each of probability `(1 - p) ^ (n - 1)` by `prob_isolated_vertex`. -/
theorem expected_isolated_count {n : ℕ} (p : ℝ) :
    Expect p (fun s : Finset (Edge n) => (isolatedCount s : ℝ))
      = n * (1 - p) ^ (n - 1) := by
  classical
  have hsum : ∀ s : Finset (Edge n), (isolatedCount s : ℝ)
      = ∑ v : Fin n, (if Disjoint s (incident v) then (1 : ℝ) else 0) := by
    intro s
    simp [isolatedCount]
  have h1 : Expect p (fun s : Finset (Edge n) => (isolatedCount s : ℝ))
      = ∑ v : Fin n, Expect p (fun s : Finset (Edge n) =>
          (if Disjoint s (incident v) then (1 : ℝ) else 0)) := by
    rw [show (fun s : Finset (Edge n) => (isolatedCount s : ℝ))
        = (fun s : Finset (Edge n) =>
            ∑ v : Fin n, (if Disjoint s (incident v) then (1 : ℝ) else 0)) from funext hsum]
    exact Expect_sum p Finset.univ _
  rw [h1]
  have h2 : ∀ v : Fin n, Expect p (fun s : Finset (Edge n) =>
      (if Disjoint s (incident v) then (1 : ℝ) else 0)) = (1 - p) ^ (n - 1) := by
    intro v
    rw [Expect_indicator p (fun s : Finset (Edge n) => Disjoint s (incident v)),
      prob_isolated_vertex p v]
  rw [Finset.sum_congr rfl (fun v _ => h2 v), Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul]

/-! ### 7.2  The `e^{-c}` limit of the expected isolated–vertex count -/

/-- `log² x / x → 0`. -/
theorem log_sq_div_tendsto : Tendsto (fun x : ℝ => (Real.log x) ^ 2 / x) atTop (𝓝 0) := by
  have h := (_root_.isLittleO_log_rpow_rpow_atTop (r := 2) (s := 1)
    (by norm_num)).tendsto_div_nhds_zero
  refine h.congr' ?_
  filter_upwards [eventually_gt_atTop (0 : ℝ)] with x _
  simp [Real.rpow_one]

/-- Upper bound `log (1 - a) ≤ -a`. -/
theorem log_one_sub_le {a : ℝ} (ha : a < 1) : Real.log (1 - a) ≤ -a := by
  have h : Real.log (1 - a) ≤ (1 - a) - 1 := Real.log_le_sub_one_of_pos (by linarith)
  linarith

/-- Quadratic lower bound `-a - 2a² ≤ log (1 - a)` for `a ≤ 1/2`. -/
theorem le_log_one_sub {a : ℝ} (ha : a ≤ 1 / 2) :
    -a - 2 * a ^ 2 ≤ Real.log (1 - a) := by
  have hpos : (0 : ℝ) < 1 - a := by linarith
  have h : Real.log (1 / (1 - a)) ≤ 1 / (1 - a) - 1 :=
    Real.log_le_sub_one_of_pos (by positivity)
  rw [Real.log_div one_ne_zero (ne_of_gt hpos), Real.log_one, zero_sub] at h
  have hb : 1 / (1 - a) - 1 = a / (1 - a) := by
    field_simp
    ring
  rw [hb] at h
  have h2 : a / (1 - a) ≤ a + 2 * a ^ 2 := by
    rw [div_le_iff₀ hpos]
    nlinarith
  linarith

/-- **The `e^{-c}` law for the expected isolated–vertex count.**  At the critical
density `p_n = (log n + c)/n` the quantity `n (1 - p_n)^{n-1}` converges to `e^{-c}`.
This is the first moment underlying the Poisson limit in the connectivity threshold. -/
theorem tendsto_expected_isolated (c : ℝ) :
    Tendsto (fun n : ℕ => (n : ℝ) * (1 - (Real.log n + c) / n) ^ (n - 1)) atTop
      (𝓝 (Real.exp (-c))) := by
  set t : ℕ → ℝ := fun n => Real.log n + c with ht
  set a : ℕ → ℝ := fun n => t n / n with ha
  have hlogdiv : Tendsto (fun n : ℕ => Real.log n / n) atTop (𝓝 0) :=
    (Real.isLittleO_log_id_atTop.tendsto_div_nhds_zero).comp tendsto_natCast_atTop_atTop
  have hcdiv : Tendsto (fun n : ℕ => c / n) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat c
  have haz : Tendsto a atTop (𝓝 0) := by
    have h : Tendsto (fun n : ℕ => Real.log n / n + c / n) atTop (𝓝 (0 + 0)) := hlogdiv.add hcdiv
    rw [zero_add] at h
    exact h.congr (fun n => by simp [ha, ht, add_div])
  have hsq : Tendsto (fun n : ℕ => (t n) ^ 2 / n) atTop (𝓝 0) := by
    have h1 : Tendsto (fun n : ℕ => (Real.log n) ^ 2 / n) atTop (𝓝 0) :=
      log_sq_div_tendsto.comp tendsto_natCast_atTop_atTop
    have h2 : Tendsto (fun n : ℕ => 2 * c * (Real.log n / n)) atTop (𝓝 (2 * c * 0)) :=
      hlogdiv.const_mul _
    have h3 : Tendsto (fun n : ℕ => c ^ 2 / n) atTop (𝓝 0) :=
      tendsto_const_div_atTop_nhds_zero_nat (c ^ 2)
    have h := (h1.add h2).add h3
    rw [mul_zero, add_zero, add_zero] at h
    refine h.congr (fun n => ?_)
    rcases eq_or_ne (n : ℝ) 0 with h0 | h0
    · simp [ht, h0]
    · field_simp [ht]
      ring
  have hlogtop : Tendsto (fun n : ℕ => Real.log n) atTop atTop :=
    Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop
  have hgood : ∀ᶠ n : ℕ in atTop, 1 ≤ n ∧ 0 < a n ∧ a n ≤ 1 / 2 := by
    filter_upwards [eventually_ge_atTop 1, hlogtop.eventually_ge_atTop (-c + 1),
      haz.eventually (eventually_abs_sub_lt 0 (by norm_num : (0:ℝ) < 1/2))] with n hn hlog hab
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn
    refine ⟨hn, ?_, ?_⟩
    · have htpos : 0 < t n := by rw [ht]; simp only; linarith
      exact div_pos htpos hn0
    · have : |a n| < 1 / 2 := by simpa using hab
      exact (abs_lt.mp this).2.le
  set E : ℕ → ℝ := fun n => Real.log n + ((n - 1 : ℕ) : ℝ) * Real.log (1 - a n) with hE
  have hEtendsto : Tendsto E atTop (𝓝 (-c)) := by
    have hupper : Tendsto (fun n : ℕ => -c + a n) atTop (𝓝 (-c)) := by
      simpa using haz.const_add (-c)
    have hlower : Tendsto (fun n : ℕ => (-c + a n) - 2 * ((t n) ^ 2 / n)) atTop (𝓝 (-c)) := by
      have h := (haz.const_add (-c)).sub (hsq.const_mul 2)
      simpa using h
    refine tendsto_of_tendsto_of_tendsto_of_le_of_le' hlower hupper ?_ ?_
    · filter_upwards [hgood] with n hn
      obtain ⟨hn1, hapos, hale⟩ := hn
      have hn0 : (0 : ℝ) < n := by exact_mod_cast hn1
      have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
        have h1 : (1 : ℕ) ≤ n := hn1
        push_cast [Nat.cast_sub h1]
        ring
      have hnn1 : (0 : ℝ) ≤ (n : ℝ) - 1 := by
        have : (1 : ℝ) ≤ n := by exact_mod_cast hn1
        linarith
      have hloglb : -a n - 2 * (a n) ^ 2 ≤ Real.log (1 - a n) := le_log_one_sub hale
      have hmul : ((n : ℝ) - 1) * (-a n - 2 * (a n) ^ 2)
          ≤ ((n : ℝ) - 1) * Real.log (1 - a n) := mul_le_mul_of_nonneg_left hloglb hnn1
      have hid1 : ((n : ℝ) - 1) * a n = t n - a n := by
        rw [ha]; field_simp
      have hid2 : ((n : ℝ) - 1) * (a n) ^ 2 ≤ (t n) ^ 2 / n := by
        have hdiff : (t n) ^ 2 / (n : ℝ) - ((n : ℝ) - 1) * (a n) ^ 2
            = (t n) ^ 2 / (n : ℝ) ^ 2 := by
          rw [ha]; field_simp; ring
        nlinarith [sq_nonneg (t n), sq_nonneg ((n : ℝ)), div_nonneg (sq_nonneg (t n))
          (sq_nonneg ((n : ℝ)))]
      have hlogn : Real.log n = t n - c := by rw [ht]; ring
      simp only [hE]
      rw [hcast]
      nlinarith [hmul, hid1, hid2, hlogn]
    · filter_upwards [hgood] with n hn
      obtain ⟨hn1, hapos, hale⟩ := hn
      have hn0 : (0 : ℝ) < n := by exact_mod_cast hn1
      have hcast : ((n - 1 : ℕ) : ℝ) = (n : ℝ) - 1 := by
        have h1 : (1 : ℕ) ≤ n := hn1
        push_cast [Nat.cast_sub h1]
        ring
      have hnn1 : (0 : ℝ) ≤ (n : ℝ) - 1 := by
        have : (1 : ℝ) ≤ n := by exact_mod_cast hn1
        linarith
      have hlogub : Real.log (1 - a n) ≤ -a n := log_one_sub_le (by linarith)
      have hmul : ((n : ℝ) - 1) * Real.log (1 - a n) ≤ ((n : ℝ) - 1) * (-a n) :=
        mul_le_mul_of_nonneg_left hlogub hnn1
      have hid1 : ((n : ℝ) - 1) * a n = t n - a n := by
        rw [ha]; field_simp
      have hlogn : Real.log n = t n - c := by rw [ht]; ring
      simp only [hE]
      rw [hcast]
      nlinarith [hmul, hid1, hlogn]
  have hcongr : (fun n : ℕ => (n : ℝ) * (1 - (Real.log n + c) / n) ^ (n - 1))
      =ᶠ[atTop] fun n => Real.exp (E n) := by
    filter_upwards [hgood] with n hn
    obtain ⟨hn1, hapos, hale⟩ := hn
    have hn0 : (0 : ℝ) < n := by exact_mod_cast hn1
    have hpos : (0 : ℝ) < 1 - a n := by linarith
    have h1 : (1 - a n) ^ (n - 1) = Real.exp (((n - 1 : ℕ) : ℝ) * Real.log (1 - a n)) := by
      rw [← Real.log_pow, Real.exp_log (by positivity)]
    have h2 : (n : ℝ) = Real.exp (Real.log n) := (Real.exp_log hn0).symm
    simp only [hE]
    rw [Real.exp_add, ← h1, ← h2]
  exact ((Real.continuous_exp.tendsto (-c)).comp hEtendsto).congr' hcongr.symm

/-- **First-moment form of the connectivity threshold.**  At the critical density
`p_n = (log n + c)/n`, the expected number of isolated vertices of `G(n, p_n)`
converges to `e^{-c}`.  This is the exact first moment whose Poisson upgrade
`P(no isolated vertex) → e^{-e^{-c}}` is the connectivity threshold. -/
theorem tendsto_expected_isolatedCount (c : ℝ) :
    Tendsto (fun n : ℕ => Expect ((Real.log n + c) / n)
        (fun s : Finset (Edge n) => (isolatedCount s : ℝ))) atTop (𝓝 (Real.exp (-c))) := by
  refine (tendsto_expected_isolated c).congr (fun n => ?_)
  rw [expected_isolated_count]

-- The following classical theorem is *stated* but not proved here: its proof needs a
-- Poisson convergence theorem (method of moments / Stein–Chen) for the isolated–vertex
-- count, which is not available in Mathlib.  Rather than leave an unproved `sorry` in the
-- development, the statement is preserved verbatim as a comment and recorded in the
-- "Open questions" section below; the first–moment half of its proof is available above
-- as `tendsto_expected_isolatedCount`.
/-
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
-/

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

-- The two giant-component theorems below are likewise *stated* but not proved: they rest
-- on Galton–Watson survival theory and an exploration-process coupling, neither of which
-- is available in Mathlib.  Their statements are preserved verbatim as comments and listed
-- in the "Open questions" section.
/-
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
-/

/-
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
-/

/-! ## Open questions

The following are natural extensions of the results above that remain open *as Lean
formalizations* (the underlying mathematics is classical):

* **Poisson limit for the isolated–vertex count.**  The commented-out statement
  `connectivity_threshold` reduces to showing that the number of isolated vertices of
  `G(n, (log n + c)/n)` converges in distribution to `Poisson(e^{-c})`.  Its *first
  moment* is proved above (`tendsto_expected_isolatedCount`: the expectation converges
  to `e^{-c}`); what is missing is the method-of-moments / Stein–Chen upgrade from the
  moments to the distributional limit.

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