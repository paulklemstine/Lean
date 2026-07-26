/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# General clique `K_r` appearance thresholds in `G(n, p)`

A **self-contained**, measure-theory-free development of the first-moment method
for the Erdős–Rényi random graph `G(n, p)`, culminating in the **general clique
`K_r` appearance threshold** — generalizing the triangle (`K_3`) results that
already live in the catalog (`Algebra.ErdosRenyi.Concrete` / `.Threshold`) to
arbitrary `r`.

Model.  Vertices are `Fin n`; the *potential edges* are the 2-element subsets of
`Fin n`, i.e. `E = powersetCard 2 univ` (so `|E| = C(n,2)`).  A random graph is a
subset `S ⊆ E`, each edge being present independently with probability `p`; the
probability of obtaining exactly `S` is

      weight E S p = p ^ |S| * (1 - p) ^ |E \ S|.

A copy of `K_r` sits on an `r`-element vertex set `T`; its edge set is
`powersetCard 2 T` (the `C(r,2)` pairs inside `T`), and the copy *appears* when
all those edges are present.

## Main results

* `ErdosRenyiClique.total_mass`        : the weights sum to `1` (a probability law).
* `ErdosRenyiClique.marginal_appearance`: a fixed target `T ⊆ E` is contained in
  the random graph with probability exactly `p ^ |T|`.
* `ErdosRenyiClique.expectedCount_eq`  : linearity of expectation for an indexed
  family of copies — `𝔼[#appearing] = ∑_{i ∈ I} p ^ |f i|`.
* `ErdosRenyiClique.probExists_le_expectedCount` : the **first-moment inequality**
  `ℙ(some copy appears) ≤ 𝔼[#appearing]`.
* `ErdosRenyiClique.expected_cliques`  : `𝔼[#K_r] = C(n,r) · p^{C(r,2)}`
  (for `r = 3`, this is `C(n,3) · p³`, the catalog's triangle count).
* `ErdosRenyiClique.prob_containsClique_le` : `ℙ(G contains a K_r) ≤ C(n,r)·p^{C(r,2)}`.
* `ErdosRenyiClique.subcritical_cliques_vanish` : if `n^r · pₙ^{C(r,2)} → 0` then
  `𝔼[#K_r] → 0`.  The hypothesis `n^r pₙ^{C(r,2)} → 0` is exactly the classical
  threshold scaling `pₙ = o(n^{-2/(r-1)})` written with integer exponents only.
* `ErdosRenyiClique.prob_containsClique_tendsto_zero` : the packaged threshold —
  below the threshold scaling, `ℙ(G(n,pₙ) ⊇ K_r) → 0`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the catalog's triangle threshold (`C(n,3)p³`,
  critical at `p = 1/n`) is the `r = 3` slice of a uniform clique family
  `𝔼[#K_r] = C(n,r) p^{C(r,2)}` with threshold scaling `p = n^{-2/(r-1)}`.  The
  only combinatorial inputs are `|V(K_r)|`-many `r`-sets (`C(n,r)`) and
  `|E(K_r)| = C(r,2)`.
Experiment (Experimenter): modelling edges as the 2-subsets of `Fin n`
  (`powersetCard 2 univ`) and copies of `K_r` as `powersetCard 2 T` for
  `T ∈ powersetCard r univ` turns *both* cardinalities into `Finset.card_powersetCard`
  with no subtype/orientation bookkeeping, and the whole first-moment chain
  (total mass → marginal → linearity → Markov) is pure `Finset` algebra with
  `Finset.prod_add` as the seed (`p + (1-p) = 1`).
Analysis (Analyst): the marginal `ℙ(T ⊆ ·) = p^|T|` is the heart: the bijection
  `S ↦ S \ T` between supersets of `T` and subsets of `E \ T` reduces it to the
  total-mass law on `E \ T`.  Subcriticality is the squeeze
  `0 ≤ C(n,r) pₙ^{C(r,2)} ≤ n^r pₙ^{C(r,2)} → 0` via `C(n,r) ≤ n^r`; since
  `n^r = (n^{2/(r-1)})^{C(r,2)}`, the integer-power hypothesis is exactly the
  fractional threshold `n^{2/(r-1)} pₙ → 0`.
Critique (Critic): only the disappearance (first-moment) direction is proved; the
  appearance direction needs the second-moment variance over overlapping `r`-sets
  and is logged in FUTURE_DIRECTIONS.md.  The development is deliberately
  self-contained (Mathlib only) so it verifies in isolation.
Synthesis (PI): a single indexed first-moment engine yields the appearance
  threshold for every `K_r`; the catalog triangle results are the `r = 3` corollary.
-- !-- Lab Notes -- !--
-/
import Mathlib

open Finset BigOperators Filter Topology

namespace ErdosRenyiClique

variable {α β : Type*} [DecidableEq α]

/-- Probability that the Erdős–Rényi random subgraph of ground set `E`, with edge
probability `p`, is *exactly* the edge set `S`. -/
def weight (E S : Finset α) (p : ℝ) : ℝ := p ^ S.card * (1 - p) ^ (E \ S).card

/-- Weights are genuine probabilities: nonnegative when `0 ≤ p ≤ 1`. -/
theorem weight_nonneg (E S : Finset α) {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ weight E S p := by
  unfold weight
  apply mul_nonneg <;> apply pow_nonneg
  · exact hp0
  · linarith

/-- The probability law sums to one (binomial theorem via `Finset.prod_add`). -/
theorem total_mass (E : Finset α) (p : ℝ) :
    ∑ S ∈ E.powerset, weight E S p = 1 := by
  unfold weight
  have := Finset.prod_add (fun _ : α => p) (fun _ : α => (1 - p)) E
  simp only [Finset.prod_const] at this
  rw [add_sub_cancel] at this
  simp at this
  rw [← this]

/-
**Marginal appearance probability.** A fixed target `T ⊆ E` is contained in
the random graph with probability exactly `p ^ |T|`.
-/
theorem marginal_appearance (E T : Finset α) (p : ℝ) (hT : T ⊆ E) :
    ∑ S ∈ E.powerset.filter (fun S => T ⊆ S), weight E S p = p ^ T.card := by
  -- Reindex the sum over supersets of `T` (inside `E`) by `R = S \ T`, a bijection onto subsets of `E \ T`.
  have h_sum_bij : ∑ S ∈ (E.powerset.filter (fun S => T ⊆ S)), (weight E S p) = ∑ R ∈ (E \ T).powerset, (weight E (T ∪ R) p) := by
    refine' Finset.sum_bij ( fun S hS => S \ T ) _ _ _ _ <;> simp_all +decide [ Finset.subset_iff ];
    · intro a₁ ha₁ ha₂ a₂ ha₃ ha₄ h; ext x; by_cases hx : x ∈ T <;> simp_all +decide [ Finset.ext_iff ] ;
    · exact fun b hb => ⟨ T ∪ b, ⟨ fun x hx => by aesop, fun x hx => by aesop ⟩, by aesop ⟩;
    · intro a ha₁ ha₂; rw [ Finset.union_eq_right.mpr ha₂ ] ;
  -- Under the reindexing, for `S = T ∪ R` with `R ⊆ E \ T` and `T,R` disjoint: `S.card = T.card + R.card`, and `E \ S = (E \ T) \ R`, so `weight E S p = p^(T.card) * (p^(R.card) * (1-p)^((E\T)\R).card) = p^(T.card) * weight (E \ T) R p`.
  have h_weight_reindex : ∀ R ∈ (E \ T).powerset, weight E (T ∪ R) p = p ^ T.card * weight (E \ T) R p := by
    intro R hR
    have h_card : (T ∪ R).card = T.card + R.card := by
      exact Finset.card_union_of_disjoint ( Finset.disjoint_left.mpr fun x hxT hxR => by have := Finset.mem_sdiff.mp ( Finset.mem_powerset.mp hR hxR ) ; aesop )
    have h_diff : (E \ (T ∪ R)) = (E \ T) \ R := by
      grind
    simp [weight, h_card, h_diff];
    ring;
  rw [ h_sum_bij, Finset.sum_congr rfl h_weight_reindex, ← Finset.mul_sum _ _ _, total_mass, mul_one ]

/-- The expected number of copies in the indexed family `(f i)_{i ∈ I}` that appear
in the random graph (copy `i` appears when `f i ⊆ S`). -/
def expectedCount (E : Finset α) (I : Finset β) (f : β → Finset α) (p : ℝ) : ℝ :=
  ∑ S ∈ E.powerset, weight E S p * ((I.filter (fun i => f i ⊆ S)).card : ℝ)

/-- The probability that *at least one* copy in the family appears. -/
def probExists (E : Finset α) (I : Finset β) (f : β → Finset α) (p : ℝ) : ℝ :=
  ∑ S ∈ E.powerset.filter (fun S => ∃ i ∈ I, f i ⊆ S), weight E S p

/-
**Linearity of expectation.** The expected number of appearing copies equals
`∑_{i ∈ I} p ^ |f i|`.
-/
theorem expectedCount_eq (E : Finset α) (I : Finset β) (f : β → Finset α) (p : ℝ)
    (hf : ∀ i ∈ I, f i ⊆ E) :
    expectedCount E I f p = ∑ i ∈ I, p ^ (f i).card := by
  unfold expectedCount;
  -- Rewrite the count as a sum of indicators: `((I.filter (fun i => f i ⊆ S)).card : ℝ) = ∑ i ∈ I, (if f i ⊆ S then 1 else 0)` (via `Finset.card_filter` then `Nat.cast_sum`).
  have h_count_indicators : ∀ S ∈ E.powerset, ((I.filter (fun i => f i ⊆ S)).card : ℝ) = ∑ i ∈ I, (if f i ⊆ S then 1 else 0) := by
    aesop;
  rw [ Finset.sum_congr rfl fun S hS => by rw [ h_count_indicators S hS, Finset.mul_sum _ _ _ ] ];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ];
  intro i hi; convert marginal_appearance E ( f i ) p ( hf i hi ) using 1; simp +decide [ Finset.sum_ite ] ;

/-- `probExists` is nonnegative when `0 ≤ p ≤ 1`. -/
theorem probExists_nonneg (E : Finset α) (I : Finset β) (f : β → Finset α) {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) : 0 ≤ probExists E I f p := by
  unfold probExists
  exact Finset.sum_nonneg (fun S _ => weight_nonneg E S hp0 hp1)

/-
**First-moment inequality.** The probability that some copy appears is at most
the expected number of appearing copies.
-/
theorem probExists_le_expectedCount (E : Finset α) (I : Finset β) (f : β → Finset α)
    {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    probExists E I f p ≤ expectedCount E I f p := by
  refine' le_trans _ ( Finset.sum_le_sum_of_subset_of_nonneg _ _ );
  refine' Finset.sum_le_sum fun S hS => _;
  · exact le_mul_of_one_le_right ( weight_nonneg E S hp0 hp1 ) ( mod_cast Finset.card_pos.mpr ⟨ Classical.choose ( Finset.mem_filter.mp hS |>.2 ), Finset.mem_filter.mpr ⟨ Classical.choose_spec ( Finset.mem_filter.mp hS |>.2 ) |>.1, Classical.choose_spec ( Finset.mem_filter.mp hS |>.2 ) |>.2 ⟩ ⟩ );
  · exact Finset.filter_subset _ _;
  · exact fun _ _ _ => mul_nonneg ( weight_nonneg _ _ hp0 hp1 ) ( Nat.cast_nonneg _ )

/-! ### The general clique `K_r` threshold -/

variable {n : ℕ}

/-- The potential edges of the complete graph on `Fin n`: the 2-element subsets. -/
abbrev edgeSet (n : ℕ) : Finset (Finset (Fin n)) := Finset.univ.powersetCard 2

/-- The edge set spanned by a vertex set `T` (the 2-subsets inside `T`). -/
abbrev cliqueEdges (T : Finset (Fin n)) : Finset (Finset (Fin n)) := T.powersetCard 2

/-
**Expected number of `K_r` cliques.**  In `G(n,p)` the expected number of
complete subgraphs on `r` vertices is `C(n,r) · p^{C(r,2)}`.  For `r = 3` this is
`C(n,3) · p³`, the catalog's triangle count.
-/
theorem expected_cliques (p : ℝ) (r : ℕ) :
    expectedCount (edgeSet n) (Finset.univ.powersetCard r) cliqueEdges p
      = (n.choose r : ℝ) * p ^ (r.choose 2) := by
  rw [ expectedCount_eq ];
  · rw [ Finset.sum_eq_card_nsmul ] <;> aesop;
  · exact fun i hi => Finset.powersetCard_mono <| Finset.subset_univ i

/-- **First-moment inequality for cliques.** The probability that `G(n,p)` contains
at least one `K_r` is at most the expected number of `K_r`'s, `C(n,r)·p^{C(r,2)}`. -/
theorem prob_containsClique_le (p : ℝ) (r : ℕ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    probExists (edgeSet n) (Finset.univ.powersetCard r) cliqueEdges p
      ≤ (n.choose r : ℝ) * p ^ (r.choose 2) := by
  rw [← expected_cliques p r]
  exact probExists_le_expectedCount _ _ _ hp0 hp1

/-
**Subcritical cliques (below threshold).** If `n^r · pₙ^{C(r,2)} → 0` then the
expected number of `K_r`'s, `C(n,r) · pₙ^{C(r,2)}`, tends to `0`.  Combined with
`prob_containsClique_le`, `G(n, pₙ)` is `K_r`-free with high probability.  For
`r = 3` (with `n^3 pₙ^3 = (n pₙ)^3`) this is the catalog's
`subcritical_triangles_vanish`.
-/
theorem subcritical_cliques_vanish (r : ℕ) (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n)
    (h : Tendsto (fun n : ℕ => (n : ℝ) ^ r * p n ^ (r.choose 2)) atTop (𝓝 0)) :
    Tendsto (fun n => (n.choose r : ℝ) * (p n) ^ (r.choose 2)) atTop (𝓝 0) := by
  refine' squeeze_zero_norm' _ h;
  filter_upwards [ Filter.eventually_gt_atTop r ] with n hn using by rw [ Real.norm_of_nonneg ( mul_nonneg ( Nat.cast_nonneg _ ) ( pow_nonneg ( hp0 _ ) _ ) ) ] ; exact mul_le_mul_of_nonneg_right ( mod_cast Nat.choose_le_pow _ _ ) ( pow_nonneg ( hp0 _ ) _ ) ;

/-
**Supercritical cliques (above threshold).** If `n^r · pₙ^{C(r,2)} → ∞` then the
expected number of `K_r`'s, `C(n,r) · pₙ^{C(r,2)}`, tends to `∞`.  This is the
expectation half of the `K_r` appearance threshold above the scaling
`pₙ = ω(n^{-2/(r-1)})`, generalizing the catalog's `supercritical_triangles_blowup`.
-/
theorem supercritical_cliques_blowup (r : ℕ) (p : ℕ → ℝ) (hp0 : ∀ n, 0 ≤ p n)
    (h : Tendsto (fun n : ℕ => (n : ℝ) ^ r * p n ^ (r.choose 2)) atTop atTop) :
    Tendsto (fun n => (n.choose r : ℝ) * (p n) ^ (r.choose 2)) atTop atTop := by
  -- Use `Filter.tendsto_atTop_mono'` to lower-bound `(n.choose r : ℝ) * (p n)^(r.choose 2)` by `((n:ℝ)^r * (p n)^(r.choose 2)) / (2^r * r !)`, which tends to `∞` because `h` tends to `atTop` and dividing by the positive constant `2^r * r!` preserves `atTop` (`Filter.Tendsto.atTop_div_const`).
  have h_lower_bound : ∀ᶠ n in Filter.atTop, (Nat.choose n r : ℝ) * (p n) ^ (Nat.choose r 2) ≥ ((n : ℝ) ^ r * (p n) ^ (Nat.choose r 2)) / (2 ^ r * Nat.factorial r) := by
    refine' Filter.eventually_atTop.mpr ⟨ 2 * r, fun n hn => _ ⟩;
    -- For `n ≥ 2*r`, `(n : ℝ)/2 ≤ ((n + 1 - r : ℕ) : ℝ)` (since `2*(n+1-r) = 2n+2-2r ≥ n` when `n ≥ 2r-2`; here `n ≥ 2r`, and `n+1-r` is ordinary subtraction as `n ≥ r`).
    have h_ineq : ((n + 1 - r : ℕ) : ℝ) ≥ (n : ℝ) / 2 := by
      rw [ ge_iff_le, div_le_iff₀ ] <;> norm_cast ; omega;
    -- By `Nat.pow_le_choose r n : ((n + 1 - r : ℕ)^r : ℝ) / r ! ≤ (n.choose r : ℝ)`.
    have h_pow_le_choose : ((n + 1 - r : ℕ) : ℝ) ^ r / (Nat.factorial r : ℝ) ≤ (Nat.choose n r : ℝ) := by
      exact_mod_cast Nat.pow_le_choose r n
    refine le_trans ?_ ( mul_le_mul_of_nonneg_right h_pow_le_choose <| pow_nonneg ( hp0 n ) _ );
    convert mul_le_mul_of_nonneg_right ( pow_le_pow_left₀ ( by positivity ) h_ineq r ) ( show 0 ≤ p n ^ r.choose 2 / ( r.factorial : ℝ ) by exact div_nonneg ( pow_nonneg ( hp0 n ) _ ) ( Nat.cast_nonneg _ ) ) using 1 ; ring;
    · norm_num;
    · ring;
  exact Filter.tendsto_atTop_mono' _ h_lower_bound ( h.atTop_div_const ( by positivity ) )

/-- **Packaged clique threshold (disappearance).** Below the threshold scaling
`n^r · pₙ^{C(r,2)} → 0` (i.e. `pₙ = o(n^{-2/(r-1)})`), with `0 ≤ pₙ ≤ 1`, the
probability that `G(n, pₙ)` contains any `K_r` tends to `0`. -/
theorem prob_containsClique_tendsto_zero (r : ℕ) (p : ℕ → ℝ)
    (hp0 : ∀ n, 0 ≤ p n) (hp1 : ∀ n, p n ≤ 1)
    (h : Tendsto (fun n : ℕ => (n : ℝ) ^ r * p n ^ (r.choose 2)) atTop (𝓝 0)) :
    Tendsto (fun n : ℕ =>
        probExists (edgeSet n) (Finset.univ.powersetCard r) cliqueEdges (p n))
      atTop (𝓝 0) := by
  apply squeeze_zero
  · intro m
    exact probExists_nonneg _ _ _ (hp0 m) (hp1 m)
  · intro m
    exact prob_containsClique_le (p m) r (hp0 m) (hp1 m)
  · exact subcritical_cliques_vanish r p hp0 h

end ErdosRenyiClique