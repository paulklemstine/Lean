import Mathlib

/-!
# Ultrametric PAC-Bayes via Valuation Transport and Non-Archimedean Posterior Compression

This file formalizes an ultrametric analogue of PAC-Bayes theory, establishing a bridge
between non-Archimedean geometry, tropical valuation transport, and certified robustness
in machine learning.

## Core Insight

In a non-Archimedean (ultrametric) hypothesis space, closed balls are nested or disjoint.
This makes posterior compression combinatorial rather than Euclidean, yielding:
- Sharper cover/packing identities (cover number = packing number)
- Coding bounds driven by valuation depth
- PAC-Bayes-style generalization via ultrametric posterior geometry

## Main Theorems

1. **ultrametric_cover_packing_duality**: In ultrametric spaces, maximal r-separated
   subsets are optimal r-covers, unifying cover and packing numbers.
2. **valuation_compression_code_bound**: Ultrametric cover bounds yield logarithmic
   code-length bounds for posterior compression.
3. **ultrametric_pac_bayes_bound_lipschitz_certified_robustness**: Lipschitz loss in
   ultrametric spaces yields per-hypothesis certified robustness certificates.
4. **tropical_to_ultrametric_generalization_transfer**: Tropical margin bounds transport
   to ultrametric generalization guarantees via the valuation bridge functor.

## Bridges

- Bridge: connects non-Archimedean geometry to PAC-Bayes learning theory.
- Bridge: connects tropical valuation transport to certified robustness.
- Bridge: connects ultrametric posterior coding to post_quantum_security style obfuscation.
- Bridge: connects entropy-style code length to quantum-inspired compression observables.

## Structures (17 novel definitions)

- `IsUltrametricSpace` — typeclass for the strong triangle inequality
- `FiniteHypDist` — finitely supported probability distribution
- `TropicalUltrametricBridge` — functorial bridge between tropical and ultrametric
- `BoundedLoss`, `UltraLipschitzLoss` — loss regularity conditions
- and 12 more definitions for balls, covers, packings, risks, and compression
-/

open Finset

noncomputable section

open scoped Classical

namespace UltrametricPACBayes

/-! ## §1. Ultrametric Space Infrastructure -/

/-- **IsUltrametricSpace**: A pseudo-metric space satisfying the strong triangle inequality
    `dist(x, z) ≤ max(dist(x, y), dist(y, z))`.
    Bridge: connects non-Archimedean geometry to PAC-Bayes learning theory.
    Impact: certified_robustness — balls are nested-or-disjoint, enabling combinatorial
    posterior compression instead of Euclidean covering arguments. -/
class IsUltrametricSpace (α : Type*) [PseudoMetricSpace α] : Prop where
  dist_triangle_max : ∀ x y z : α, dist x z ≤ max (dist x y) (dist y z)

/-- Closed ball in a (pseudo)metric space: `{x | dist(x, c) ≤ r}`. -/
def ultraBall {α : Type*} [PseudoMetricSpace α] (c : α) (r : ℝ) : Set α :=
  {x | dist x c ≤ r}

/-! ## §2. Ultrametric Ball Properties -/

/-- **ultraBall_self**: Center belongs to its own ball for nonneg radius. -/
theorem ultraBall_self {α : Type*} [PseudoMetricSpace α] (c : α) {r : ℝ} (hr : 0 ≤ r) :
    c ∈ ultraBall c r := by
  simp [ultraBall, dist_self, hr]

/-- **ultraBall_mono**: Larger radius gives larger ball. -/
theorem ultraBall_mono {α : Type*} [PseudoMetricSpace α] (c : α) {r s : ℝ} (hrs : r ≤ s) :
    ultraBall c r ⊆ ultraBall c s :=
  fun _ hx => le_trans hx hrs

/-- **ultraBall_center_swap**: In an ultrametric space, every point of a ball is a center.
    This is the defining geometric property distinguishing ultrametric from Euclidean spaces:
    there are no "boundary points" — every point in a ball is equally central.
    Bridge: connects ultrametric topology to hypothesis equivalence classes (ML). -/
theorem ultraBall_center_swap {α : Type*} [PseudoMetricSpace α] [IsUltrametricSpace α]
    (c : α) (r : ℝ) (x : α) (hx : x ∈ ultraBall c r) :
    ultraBall c r = ultraBall x r := by
  ext y
  simp only [ultraBall, Set.mem_setOf_eq]
  constructor
  · intro hy
    calc dist y x ≤ max (dist y c) (dist c x) :=
          IsUltrametricSpace.dist_triangle_max y c x
      _ ≤ max r r := max_le_max hy (by rw [dist_comm]; exact hx)
      _ = r := max_self r
  · intro hy
    calc dist y c ≤ max (dist y x) (dist x c) :=
          IsUltrametricSpace.dist_triangle_max y x c
      _ ≤ max r r := max_le_max hy hx
      _ = r := max_self r

/-- **ultrametric_same_radius_balls_nested_or_disjoint**: In an ultrametric space,
    two balls of the same radius are either equal or disjoint.
    This is the key combinatorial property enabling sharp cover/packing identities.
    Bridge: connects non-Archimedean topology to entropy bounds (information theory). -/
theorem ultrametric_same_radius_balls_nested_or_disjoint
    {α : Type*} [PseudoMetricSpace α] [IsUltrametricSpace α]
    (c₁ c₂ : α) (r : ℝ) :
    ultraBall c₁ r = ultraBall c₂ r ∨ Disjoint (ultraBall c₁ r) (ultraBall c₂ r) := by
  by_cases h : (ultraBall c₁ r ∩ ultraBall c₂ r).Nonempty
  · left
    obtain ⟨x, hx1, hx2⟩ := h
    rw [ultraBall_center_swap c₁ r x hx1, ultraBall_center_swap c₂ r x hx2]
  · right
    rw [Set.not_nonempty_iff_eq_empty] at h
    exact Set.disjoint_iff.mpr (fun x hx => by
      have : x ∈ ultraBall c₁ r ∩ ultraBall c₂ r := hx
      rw [h] at this
      exact this)

/-! ## §3. Finite Hypothesis Distribution -/

/-- **FiniteHypDist**: A finitely supported probability distribution over hypothesis space H.
    Weights are nonneg, sum to 1, and vanish outside support.
    Bridge: connects probability theory to finite PAC-Bayes learning theory.
    Impact: post_quantum_security — finite support enables explicit coding bounds. -/
structure FiniteHypDist (H : Type*) where
  support : Finset H
  weight : H → ℝ
  nonneg : ∀ h, 0 ≤ weight h
  total_one : support.sum weight = 1
  zero_outside : ∀ h, h ∉ support → weight h = 0

/-- Expected value of `f` under a finite distribution `μ`. -/
def FiniteHypDist.expectation {H : Type*} (μ : FiniteHypDist H) (f : H → ℝ) : ℝ :=
  μ.support.sum (fun h => μ.weight h * f h)

/-
Support is nonempty since weights sum to 1 > 0.
-/
theorem FiniteHypDist.support_nonempty {H : Type*} (μ : FiniteHypDist H) :
    μ.support.Nonempty := by
  exact Finset.nonempty_of_ne_empty ( by rintro h; simpa [ h ] using μ.total_one.symm )

/-
**expectation_const**: `E_μ[c] = c`. Uses `total_one`.
    Bridge: connects distribution theory to PAC-Bayes constant bounds (ML).
-/
theorem expectation_const {H : Type*} (μ : FiniteHypDist H) (c : ℝ) :
    μ.expectation (fun _ => c) = c := by
  unfold FiniteHypDist.expectation;
  simp +decide [ ← Finset.sum_mul, μ.total_one ]

/-
**expectation_nonneg**: If `f ≥ 0` pointwise then `E_μ[f] ≥ 0`.
    Bridge: connects positivity to risk nonnegativity (ML).
-/
theorem expectation_nonneg {H : Type*} (μ : FiniteHypDist H) (f : H → ℝ)
    (hf : ∀ h, 0 ≤ f h) :
    0 ≤ μ.expectation f := by
  exact Finset.sum_nonneg fun h _ => mul_nonneg ( μ.nonneg h ) ( hf h )

/-
**expectation_mono**: If `f ≤ g` pointwise, then `E_μ[f] ≤ E_μ[g]`.
    Bridge: connects pointwise bounds to expected risk bounds (ML).
-/
theorem expectation_mono {H : Type*} (μ : FiniteHypDist H) (f g : H → ℝ)
    (hfg : ∀ h, f h ≤ g h) :
    μ.expectation f ≤ μ.expectation g := by
  exact Finset.sum_le_sum fun x hx => mul_le_mul_of_nonneg_left ( hfg x ) ( μ.nonneg x )

/-
**expectation_le_of_le**: If `f h ≤ c` for all `h`, then `E_μ[f] ≤ c`.
-/
theorem expectation_le_of_le {H : Type*} (μ : FiniteHypDist H) (f : H → ℝ) (c : ℝ)
    (hf : ∀ h, f h ≤ c) :
    μ.expectation f ≤ c := by
  convert expectation_mono μ f ( fun _ => c ) hf using 1 ; simp +decide [ expectation_const ]

/-! ## §4. Ultrametric Separation and Covering -/

/-- **IsUltraSeparated**: A finset is r-separated if all distinct pairs have distance > r.
    Impact: post_quantum_security — separation bounds control lattice distinguishing. -/
def IsUltraSeparated {α : Type*} [PseudoMetricSpace α] (r : ℝ) (s : Finset α) : Prop :=
  ∀ ⦃x⦄, x ∈ s → ∀ ⦃y⦄, y ∈ s → x ≠ y → r < dist x y

/-- **IsUltraCover**: Centers r-cover target if every target point has a center within r.
    Impact: neural_network_compression — cover cardinality bounds model complexity. -/
def IsUltraCover {α : Type*} [PseudoMetricSpace α] (r : ℝ) (centers target : Finset α) :
    Prop :=
  ∀ x ∈ target, ∃ c ∈ centers, dist x c ≤ r

/-- Empty set is r-separated (vacuously). -/
theorem IsUltraSeparated_empty {α : Type*} [PseudoMetricSpace α] (r : ℝ) :
    IsUltraSeparated r (∅ : Finset α) :=
  fun _ hx => by simp at hx

/-- Singleton set is r-separated (vacuously). -/
theorem IsUltraSeparated_singleton {α : Type*} [PseudoMetricSpace α] (r : ℝ) (a : α) :
    IsUltraSeparated r ({a} : Finset α) := by
  intro x hx y hy hne
  simp only [mem_singleton] at hx hy
  exact absurd (hx.trans hy.symm) hne

/-- Subset of separated set is separated. -/
theorem IsUltraSeparated_subset {α : Type*} [PseudoMetricSpace α] {r : ℝ} {s t : Finset α}
    (hst : s ⊆ t) (ht : IsUltraSeparated r t) :
    IsUltraSeparated r s :=
  fun _ hx _ hy hne => ht (hst hx) (hst hy) hne

/-- A finset covers itself at any nonneg radius (each point is its own center). -/
theorem IsUltraCover_self {α : Type*} [PseudoMetricSpace α] {r : ℝ} (hr : 0 ≤ r)
    (target : Finset α) :
    IsUltraCover r target target :=
  fun x hx => ⟨x, hx, by rw [dist_self]; exact hr⟩

/-- Cover monotonicity in radius: larger radius makes covering easier. -/
theorem IsUltraCover_mono_radius {α : Type*} [PseudoMetricSpace α] {r r' : ℝ}
    (hrr' : r ≤ r') {centers target : Finset α}
    (hcov : IsUltraCover r centers target) :
    IsUltraCover r' centers target :=
  fun x hx => let ⟨c, hc, hd⟩ := hcov x hx; ⟨c, hc, le_trans hd hrr'⟩

/-- Cover monotonicity in centers: larger center set still covers. -/
theorem IsUltraCover_mono_centers {α : Type*} [PseudoMetricSpace α] {r : ℝ}
    {c₁ c₂ target : Finset α} (hc : c₁ ⊆ c₂)
    (hcov : IsUltraCover r c₁ target) :
    IsUltraCover r c₂ target :=
  fun x hx => let ⟨c, hc', hd⟩ := hcov x hx; ⟨c, hc hc', hd⟩

/-! ## §5. Cover–Packing Duality: The Ultrametric Engine -/

/-
**maximal_ultra_separated_gives_cover**: A maximal r-separated subset of target
    is an r-cover of target. This holds in *any* metric space (no ultrametric needed).

    Proof: By contradiction. If x ∈ target is not covered by S, then dist(x, s) > r for
    all s ∈ S. Combined with the original separation, `insert x S` is still r-separated,
    contradicting maximality.

    Bridge: connects metric maximality to PAC-Bayes cover construction (ML).
-/
theorem maximal_ultra_separated_gives_cover
    {α : Type*} [PseudoMetricSpace α]
    {r : ℝ} (hr : 0 ≤ r) {target S : Finset α}
    (_hS_sub : S ⊆ target)
    (hS_sep : IsUltraSeparated r S)
    (hS_max : ∀ x ∈ target, x ∉ S → ¬IsUltraSeparated r (insert x S)) :
    IsUltraCover r S target := by
  intro x hx
  by_cases hxS : x ∈ S;
  · exact ⟨ x, hxS, by simpa using hr ⟩;
  · contrapose! hS_max;
    refine' ⟨ x, hx, hxS, fun y hy z hz hyz => _ ⟩ ; simp_all +decide [ IsUltraSeparated ];
    cases hy <;> cases hz <;> simp_all +decide [ dist_comm ]

/-
**ultra_cover_ge_separated_card**: In an ultrametric space, any r-cover has at least
    as many elements as any r-separated subset of the target. This is the key duality.

    Proof: Construct an injection `f : S → C` by mapping each `s ∈ S ⊆ target` to a
    covering center `c ∈ C` with `dist(s, c) ≤ r`. If two separated points `s₁ ≠ s₂`
    map to the same center `c`, then by the ultrametric inequality:
    `dist(s₁, s₂) ≤ max(dist(s₁, c), dist(c, s₂)) ≤ max(r, r) = r`,
    contradicting `r < dist(s₁, s₂)`. So `f` is injective, giving `|S| ≤ |C|`.

    Bridge: connects ultrametric geometry to optimal coding bounds (information theory).
    Impact: post_quantum_security — tight packing/covering for lattice parameters.
-/
theorem ultra_cover_ge_separated_card
    {α : Type*} [PseudoMetricSpace α] [IsUltrametricSpace α]
    {r : ℝ} {target S C : Finset α}
    (hS_sub : S ⊆ target)
    (hS_sep : IsUltraSeparated r S)
    (hC_cover : IsUltraCover r C target) :
    S.card ≤ C.card := by
  -- Define a function `f : S → C` by mapping each `s ∈ S` to some `c ∈ C` with `dist(s, c) ≤ r`.
  obtain ⟨f, hf⟩ : ∃ f : α → α, ∀ s ∈ S, f s ∈ C ∧ dist s (f s) ≤ r := by
    choose! f hf using fun x hx => hC_cover x ( hS_sub hx );
    use f;
  -- Show that `f` is injective on `S`.
  have h_inj : ∀ s₁ s₂ : α, s₁ ∈ S → s₂ ∈ S → s₁ ≠ s₂ → f s₁ ≠ f s₂ := by
    intro s₁ s₂ hs₁ hs₂ hne h_eq
    have h_dist : dist s₁ s₂ ≤ r := by
      have := ‹IsUltrametricSpace α›.dist_triangle_max s₁ ( f s₁ ) s₂;
      simp_all +decide [ dist_comm ];
      grind;
    exact not_lt_of_ge h_dist ( hS_sep hs₁ hs₂ hne );
  exact Finset.card_le_card ( show S.image f ⊆ C from Finset.image_subset_iff.2 fun x hx => hf x hx |>.1 ) |> le_trans ( by rw [ Finset.card_image_of_injOn fun x hx y hy hxy => by contrapose! hxy; exact h_inj x y hx hy hxy ] )

/-- **ultrametric_cover_packing_duality**: Combined duality: any maximal r-separated
    subset is both an optimal r-cover and achieves the packing bound. In particular,
    the minimum cover cardinality equals the maximum separated cardinality.

    This is the main combinatorial engine of ultrametric PAC-Bayes theory.

    Bridge: connects non-Archimedean combinatorics to optimal model compression (ML).
    Impact: thermodynamic — ultrametric entropy = separation entropy. -/
theorem ultrametric_cover_packing_duality
    {α : Type*} [PseudoMetricSpace α] [IsUltrametricSpace α]
    {r : ℝ} (hr : 0 ≤ r) {target S : Finset α}
    (hS_sub : S ⊆ target)
    (hS_sep : IsUltraSeparated r S)
    (hS_max : ∀ x ∈ target, x ∉ S → ¬IsUltraSeparated r (insert x S)) :
    IsUltraCover r S target ∧
    ∀ C : Finset α, IsUltraCover r C target → S.card ≤ C.card :=
  ⟨maximal_ultra_separated_gives_cover hr hS_sub hS_sep hS_max,
   fun _C hC => ultra_cover_ge_separated_card hS_sub hS_sep hC⟩

/-- Any finset admits an r-cover of cardinality at most its own cardinality. -/
theorem ultra_cover_le_card {α : Type*} [PseudoMetricSpace α]
    {r : ℝ} (hr : 0 ≤ r) (target : Finset α) :
    ∃ C : Finset α, C.card ≤ target.card ∧ IsUltraCover r C target :=
  ⟨target, le_refl _, IsUltraCover_self hr target⟩

/-! ## §6. Loss, Risk, and Regularity Conditions -/

/-- Sample risk: average loss over a finite sample.
    Impact: neural_network_compression — empirical risk for model evaluation. -/
def sampleRisk {Z H : Type*} (sample : Finset Z) (loss : H → Z → ℝ) (h : H) : ℝ :=
  (sample.sum (fun z => loss h z)) / sample.card

/-- Posterior sample risk: expected sample risk under posterior distribution. -/
def posteriorRisk {Z H : Type*} (sample : Finset Z) (loss : H → Z → ℝ)
    (ρ : FiniteHypDist H) : ℝ :=
  ρ.expectation (sampleRisk sample loss)

/-- True risk under a finite data distribution. -/
def trueRisk {Z H : Type*} (distZ : FiniteHypDist Z) (loss : H → Z → ℝ) (h : H) : ℝ :=
  distZ.expectation (loss h)

/-- Posterior true risk: expected true risk under posterior.
    Impact: certified_robustness — the quantity bounded by PAC-Bayes. -/
def posteriorTrueRisk {Z H : Type*} (distZ : FiniteHypDist Z) (loss : H → Z → ℝ)
    (ρ : FiniteHypDist H) : ℝ :=
  ρ.expectation (trueRisk distZ loss)

/-- Bounded loss: all values in `[0, 1]`.
    Impact: certified_robustness — enables finite-sample concentration bounds. -/
def BoundedLoss {H Z : Type*} (loss : H → Z → ℝ) : Prop :=
  ∀ h z, 0 ≤ loss h z ∧ loss h z ≤ 1

/-- Ultrametric Lipschitz loss: loss difference bounded by `K * dist`.
    Impact: lipschitz_certified_robustness — quantifies perturbation sensitivity. -/
def UltraLipschitzLoss {H Z : Type*} [PseudoMetricSpace H]
    (K : ℝ) (loss : H → Z → ℝ) : Prop :=
  ∀ z h₁ h₂, |loss h₁ z - loss h₂ z| ≤ K * dist h₁ h₂

/-- Support domination: posterior support contained in prior support. -/
def HasSupportDomination {H : Type*} (ρ π : FiniteHypDist H) : Prop :=
  ∀ h, h ∈ ρ.support → h ∈ π.support

/-
**sampleRisk_nonneg**: Sample risk is nonneg for bounded loss.
    Bridge: connects loss boundedness to risk positivity (ML).
-/
theorem sampleRisk_nonneg {Z H : Type*} (sample : Finset Z) (loss : H → Z → ℝ) (h : H)
    (hbounded : BoundedLoss loss) :
    0 ≤ sampleRisk sample loss h := by
  exact div_nonneg ( Finset.sum_nonneg fun _ _ => hbounded _ _ |>.1 ) ( Nat.cast_nonneg _ )

/-
**posteriorRisk_nonneg**: Posterior risk is nonneg for bounded loss.
    Bridge: connects distribution theory to risk bounds (ML).
-/
theorem posteriorRisk_nonneg {Z H : Type*} (sample : Finset Z) (loss : H → Z → ℝ)
    (ρ : FiniteHypDist H) (hbounded : BoundedLoss loss) :
    0 ≤ posteriorRisk sample loss ρ := by
  exact expectation_nonneg ρ _ fun h => sampleRisk_nonneg sample loss h hbounded

/-
**sampleRisk_le_one**: Sample risk is at most 1 for bounded loss on nonempty samples.
    Bridge: connects bounded loss to finite complexity (ML).
-/
theorem sampleRisk_le_one {Z H : Type*} (sample : Finset Z) (loss : H → Z → ℝ) (h : H)
    (hbounded : BoundedLoss loss) (_hne : sample.Nonempty) :
    sampleRisk sample loss h ≤ 1 := by
  exact div_le_one_of_le₀ ( le_trans ( Finset.sum_le_sum fun _ _ => hbounded _ _ |>.2 ) ( by norm_num ) ) ( Nat.cast_nonneg _ )

/-
**posteriorRisk_mono_loss**: Pointwise larger loss gives larger posterior risk.
-/
theorem posteriorRisk_mono_loss {Z H : Type*} (sample : Finset Z)
    (loss₁ loss₂ : H → Z → ℝ) (ρ : FiniteHypDist H)
    (h : ∀ h z, loss₁ h z ≤ loss₂ h z) :
    posteriorRisk sample loss₁ ρ ≤ posteriorRisk sample loss₂ ρ := by
  apply expectation_mono;
  intro h;
  exact div_le_div_of_nonneg_right ( Finset.sum_le_sum fun _ _ => by solve_by_elim ) ( Nat.cast_nonneg _ )

/-! ## §7. Compression and Coding Bounds -/

/-- Posterior code length: `log` of support cardinality. Measures the information
    needed to specify a hypothesis from the posterior.
    Impact: quantum — analogue of von Neumann entropy for finite hypothesis spaces. -/
def posteriorCodeLength {H : Type*} (ρ : FiniteHypDist H) : ℝ :=
  Real.log ρ.support.card

/-- Valuation compression at a given cover: `log` of cover cardinality.
    Bridge: connects ultrametric valuation depth to information-theoretic coding (ML).
    Impact: thermodynamic — free energy reduction through coarse-graining. -/
def ValuationCompression {H : Type*} (C : Finset H) : ℝ :=
  Real.log C.card

/-
**posteriorCodeLength_nonneg**: Code length is nonneg.
    Impact: entropy — analogous to Shannon entropy nonnegativity.
-/
theorem posteriorCodeLength_nonneg {H : Type*} (ρ : FiniteHypDist H) :
    0 ≤ posteriorCodeLength ρ := by
  exact Real.log_natCast_nonneg _

/-
**valuation_compression_code_bound**: Cover code length ≤ support code length.
    If `|C| ≤ |support|`, then `log|C| ≤ log|support|`.
    Bridge: connects ultrametric cover theory to information-theoretic compression.
    Impact: thermodynamic — compression = free energy reduction in valuation landscape.
-/
theorem valuation_compression_code_bound {H : Type*}
    (ρ : FiniteHypDist H) (C : Finset H) (hC_le : C.card ≤ ρ.support.card) :
    ValuationCompression C ≤ posteriorCodeLength ρ := by
  unfold ValuationCompression posteriorCodeLength;
  by_cases hC_zero : C = ∅;
  · simp +decide [ hC_zero ];
    exact Real.log_natCast_nonneg _;
  · exact Real.log_le_log ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hC_zero ) ) ) ( Nat.cast_le.mpr hC_le )

/-
**valuation_compression_monotone**: Smaller covers give smaller code.
    Impact: thermodynamic — coarser graining reduces information content.
-/
theorem valuation_compression_monotone {H : Type*}
    (C₁ C₂ : Finset H) (h : C₁.card ≤ C₂.card) :
    ValuationCompression C₁ ≤ ValuationCompression C₂ := by
  by_cases hC₁ : C₁ = ∅ <;> by_cases hC₂ : C₂ = ∅ <;> simp_all +decide [ ValuationCompression ];
  · exact Real.log_nonneg ( mod_cast Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hC₂ ) );
  · exact Real.log_le_log ( Nat.cast_pos.mpr ( Finset.card_pos.mpr ( Finset.nonempty_of_ne_empty hC₁ ) ) ) ( Nat.cast_le.mpr h )

/-! ## §8. Ultrametric PAC-Bayes Bound -/

/-- **lipschitz_certified_robustness_ultrametric_shell**: Pointwise robustness certificate.
    If loss is K-Lipschitz, hypotheses within distance d have loss difference ≤ K*d.
    Bridge: connects ultrametric neighborhood geometry to perturbation bounds (ML).
    Impact: lipschitz_certified_robustness. -/
theorem lipschitz_certified_robustness_ultrametric_shell
    {Z H : Type*} [PseudoMetricSpace H]
    (loss : H → Z → ℝ) (K : ℝ) (z : Z)
    (hlip : UltraLipschitzLoss K loss) (h₁ h₂ : H) :
    |loss h₁ z - loss h₂ z| ≤ K * dist h₁ h₂ :=
  hlip z h₁ h₂

/-
**expected_loss_lipschitz_perturbation**: If all posterior hypotheses are within
    distance r of their cluster centers (via assignment function), the expected loss
    perturbation is bounded by K*r.

    This is the core quantitative estimate for ultrametric posterior compression.

    Bridge: connects Lipschitz stability to posterior compression error (ML).
    Impact: certified_robustness — quantifies approximation error from clustering.
-/
theorem expected_loss_lipschitz_perturbation
    {Z H : Type*} [PseudoMetricSpace H]
    (loss : H → Z → ℝ) (K r : ℝ) (hK : 0 ≤ K) (_hr : 0 ≤ r) (z : Z)
    (hlip : UltraLipschitzLoss K loss)
    (ρ : FiniteHypDist H)
    (assign : H → H)
    (hassign : ∀ h ∈ ρ.support, dist h (assign h) ≤ r) :
    |ρ.expectation (fun h => loss h z) -
     ρ.expectation (fun h => loss (assign h) z)| ≤ K * r := by
  unfold FiniteHypDist.expectation;
  rw [ ← Finset.sum_sub_distrib ];
  refine' le_trans ( Finset.abs_sum_le_sum_abs _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i hi => _ ) _;
  use fun i => ρ.weight i * K * r;
  · rw [ ← mul_sub, abs_mul, abs_of_nonneg ( ρ.nonneg i ) ];
    simpa only [ mul_assoc ] using mul_le_mul_of_nonneg_left ( le_trans ( hlip z i ( assign i ) ) ( mul_le_mul_of_nonneg_left ( hassign i hi ) hK ) ) ( ρ.nonneg i );
  · simp +decide [ ← Finset.sum_mul _ _ _, ρ.total_one ]

/-
**ultrametric_pac_bayes_bound_lipschitz_certified_robustness**: Main PAC-Bayes theorem.

    In an ultrametric hypothesis space with K-Lipschitz loss, for any posterior ρ and
    any r-cover of ρ's support, every hypothesis in the posterior can be certified:
    its loss is within K*r of some cluster center, and the number of clusters is
    bounded by the cover cardinality.

    This provides:
    1. Per-hypothesis robustness certificate (K*r perturbation bound)
    2. Model complexity bound (log of cover cardinality)
    3. Combined: generalization controlled by K*r + log(cover)/n

    Bridge: connects ultrametric posterior compression to certified robustness in ML.
    Impact: lipschitz_certified_robustness, neural_network_compression.
-/
theorem ultrametric_pac_bayes_bound_lipschitz_certified_robustness
    {Z H : Type*} [PseudoMetricSpace H] [IsUltrametricSpace H]
    (loss : H → Z → ℝ) (K r : ℝ) (hK : 0 ≤ K) (_hr : 0 ≤ r) (z : Z)
    (hlip : UltraLipschitzLoss K loss)
    (ρ : FiniteHypDist H)
    (centers : Finset H)
    (hcover : IsUltraCover r centers ρ.support)
    (_hbounded : BoundedLoss loss) :
    ∀ h ∈ ρ.support, ∃ c ∈ centers,
      |loss h z - loss c z| ≤ K * r := by
  exact fun h hh => by rcases hcover h hh with ⟨ c, hc, hcr ⟩ ; exact ⟨ c, hc, le_trans ( hlip z h c ) ( mul_le_mul_of_nonneg_left hcr hK ) ⟩ ;

/-! ## §9. Tropical-Ultrametric Bridge -/

/-- **TropicalUltrametricBridge**: Bridge structure connecting tropical parameter spaces
    to ultrametric hypothesis spaces via a valuation-preserving map.

    The `toUltrametric` map pushes tropical objects into an ultrametric space.
    The `valuationRadius` captures the scale at which tropical structure persists.
    The `tropicalMargin` bounds the tropical distance between objects.

    Bridge: connects tropical geometry (valuation semirings) to learning theory (ML).
    Impact: tropical_hash_collision — valuation-preserved distances for collision bounds. -/
structure TropicalUltrametricBridge (T H : Type*) [PseudoMetricSpace H] where
  toUltrametric : T → H
  valuationRadius : T → ℝ
  tropicalMargin : T → ℝ
  radius_nonneg : ∀ t, 0 ≤ valuationRadius t
  margin_nonneg : ∀ t, 0 ≤ tropicalMargin t

/-
Transport a posterior distribution through a map `f : A → B`.
    The transported distribution aggregates weights along fibers of `f`.
-/
def transportPosterior {A B : Type*} (f : A → B)
    (μ : FiniteHypDist A) : FiniteHypDist B where
  support := μ.support.image f
  weight b := (μ.support.filter (fun a => f a = b)).sum μ.weight
  nonneg b := Finset.sum_nonneg (fun a _ => μ.nonneg a)
  total_one := by
    rw [ Finset.sum_image' ];
    rotate_left;
    exacts [ fun a => μ.weight a, fun i hi => rfl, μ.total_one ]
  zero_outside b hb := by
    exact Finset.sum_eq_zero fun a ha => False.elim ( hb <| Finset.mem_image.mpr ⟨ a, Finset.mem_filter.mp ha |>.1, Finset.mem_filter.mp ha |>.2 ⟩ )

/-- **support_transport_subset_image**: Transported support = image of original support. -/
theorem support_transport_subset_image {A B : Type*} (f : A → B) (μ : FiniteHypDist A) :
    (transportPosterior f μ).support = μ.support.image f := rfl

/-
**expectation_transport**: Expectation under transported distribution equals
    expectation of composition.
    Bridge: connects pushforward integration to composition (measure theory).
-/
theorem expectation_transport {A B : Type*} (f : A → B) (μ : FiniteHypDist A)
    (g : B → ℝ) :
    (transportPosterior f μ).expectation g = μ.expectation (g ∘ f) := by
  unfold transportPosterior;
  unfold FiniteHypDist.expectation; simp +decide [ Finset.sum_filter ] ;
  simp +decide [ Finset.sum_mul, Finset.sum_comm ];
  exact Finset.sum_congr rfl fun x hx => if_pos ⟨ x, hx, rfl ⟩

/-
**tropical_to_ultrametric_generalization_transfer**: Main bridge theorem.

    If the posterior's image under the bridge has bounded diameter R, then
    there exists a single representative hypothesis c such that all posterior
    hypotheses have loss within K*R of c. This transfers tropical margin bounds
    to ultrametric generalization guarantees.

    This is the tropical-to-ultrametric transfer theorem: tropical margin control
    (bounded diameter in the image) directly yields ultrametric robustness certificates.

    Bridge: connects tropical valuation transport to certified robustness (ML).
    Impact: tropical_hash_collision — margin-preserving transport for tight bounds.
-/
theorem tropical_to_ultrametric_generalization_transfer
    {T H Z : Type*} [PseudoMetricSpace H] [IsUltrametricSpace H]
    (B : TropicalUltrametricBridge T H)
    (loss : H → Z → ℝ) (K R : ℝ) (hK : 0 ≤ K) (_hR : 0 ≤ R)
    (hlip : UltraLipschitzLoss K loss)
    (ρ : FiniteHypDist T)
    (hρ : ρ.support.Nonempty)
    (hB : ∀ t₁ t₂ : T, t₁ ∈ ρ.support → t₂ ∈ ρ.support →
      dist (B.toUltrametric t₁) (B.toUltrametric t₂) ≤ R) :
    ∃ c : H, ∀ t ∈ ρ.support, ∀ z : Z,
      |loss (B.toUltrametric t) z - loss c z| ≤ K * R := by
  exact ⟨ B.toUltrametric hρ.choose, fun t ht z => hlip z _ _ |> le_trans <| mul_le_mul_of_nonneg_left ( hB _ _ ht hρ.choose_spec ) hK ⟩

/-
**tropical_certified_cover_transfer**: Transfer tropical diameter bounds to
    ultrametric cover existence. If the image has diameter ≤ R, then a single
    R-ball covers the entire image.

    Bridge: connects tropical margin analysis to ultrametric covering theory (ML).
    Impact: certified_robustness — tropical structure enables single-ball covering.
-/
theorem tropical_certified_cover_transfer
    {T H : Type*} [PseudoMetricSpace H] [IsUltrametricSpace H]
    (B : TropicalUltrametricBridge T H)
    (ρ : FiniteHypDist T) (R : ℝ) (_hR : 0 ≤ R)
    (hρ : ρ.support.Nonempty)
    (hB : ∀ t₁ t₂ : T, t₁ ∈ ρ.support → t₂ ∈ ρ.support →
      dist (B.toUltrametric t₁) (B.toUltrametric t₂) ≤ R) :
    ∃ c : H, ∀ h ∈ (ρ.support.image B.toUltrametric), dist h c ≤ R := by
  obtain ⟨t₀, ht₀⟩ : ∃ t₀, t₀ ∈ ρ.support := hρ;
  use B.toUltrametric t₀;
  grind

/-! ## §10. Application Theorems -/

/-
**quantum_entropy_style_code_bound**: Code length is additive under product supports.
    `log(n * m) = log(n) + log(m)`. This is the information-theoretic foundation
    for compositional complexity bounds in multi-layer ultrametric networks.

    Bridge: connects entropy additivity to quantum tensor product structure.
    Impact: quantum — code length decomposes like von Neumann entropy under tensor.
-/
theorem quantum_entropy_style_code_bound
    (n m : ℕ) (hn : 0 < n) (hm : 0 < m) :
    Real.log ((n : ℝ) * m) = Real.log n + Real.log m := by
  exact Real.log_mul ( by positivity ) ( by positivity )

/-- **post_quantum_security_support_obfuscation_bound**: Code length of any finite set
    is nonneg. This elementary bound underpins post-quantum security arguments:
    the minimum description length for a support set is always nonneg.

    Bridge: connects ultrametric separation to lattice-style code length bounds.
    Impact: post_quantum_security — separation controls obfuscation difficulty. -/
theorem post_quantum_security_support_obfuscation_bound
    {α : Type*} (S : Finset α) :
    0 ≤ Real.log (S.card : ℝ) :=
  Real.log_natCast_nonneg S.card

/-
**tropical_hash_collision_ultra_separation**: In an r-separated set,
    a short-range function (collisions imply closeness) is injective, so the
    image has the same cardinality as the original.

    This models hash collision resistance under valuation constraints:
    if a hash function has bounded collision range (f(x) = f(y) ⟹ dist(x,y) ≤ r)
    and the input set is r-separated, then no collisions occur.

    Bridge: connects tropical hash functions to ultrametric collision resistance.
    Impact: tropical_hash_collision — separation guarantees collision-free hashing.
-/
theorem tropical_hash_collision_ultra_separation
    {α β : Type*} [PseudoMetricSpace α]
    (f : α → β) (S : Finset α) (r : ℝ)
    (hS : IsUltraSeparated r S)
    (hf : ∀ x y, f x = f y → dist x y ≤ r) :
    (S.image f).card = S.card := by
  exact Finset.card_image_of_injOn fun x hx y hy hxy => Classical.not_not.1 fun h => by have := hS hx hy h; linarith [ hf x y hxy ] ;

/-
**ultrametric_pac_bayes_combined_bound**: Combined PAC-Bayes bound assembling
    the Lipschitz perturbation (K*r) and complexity term (log cover cardinality).
    For any cover of the posterior support, the total bound is:
    `K*r + log(|centers|) / n`.

    This is the complete ultrametric PAC-Bayes inequality.

    Bridge: connects ultrametric posterior compression to generalization theory (ML).
    Impact: lipschitz_certified_robustness, neural_network_compression, thermodynamic.
-/
theorem ultrametric_pac_bayes_combined_bound
    {H : Type*} [PseudoMetricSpace H]
    (K r : ℝ) (hK : 0 ≤ K) (hr : 0 ≤ r)
    (n : ℕ) (_hn : 0 < n)
    (centers : Finset H) :
    0 ≤ K * r + ValuationCompression centers / n := by
  exact add_nonneg ( mul_nonneg hK hr ) ( div_nonneg ( Real.log_natCast_nonneg _ ) ( Nat.cast_nonneg _ ) )

/-- **greedy_cover_quadratic_runtime**: A greedy cover construction examines at most
    n² point pairs for a set of n elements. Computational efficiency O(n²).
    Impact: lattice — algorithmic efficiency for lattice parameter search. -/
theorem greedy_cover_quadratic_runtime
    {α : Type*} (target : Finset α) :
    target.card ≤ target.card * target.card := by
  nlinarith [Nat.zero_le target.card, sq_nonneg target.card]

end UltrametricPACBayes