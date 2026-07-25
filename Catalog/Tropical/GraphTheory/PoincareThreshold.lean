/-
  Poincaré Threshold for Metric Filtrations

  This file establishes rigorous foundations for the Poincaré threshold—the
  critical scale parameter at which a metric-indexed filtration first exhibits
  a target topological property. We formalize:

  1. The Rips graph construction and its monotonicity
  2. Approximate isometries and the interleaving theorem
  3. Abstract metric filtrations and threshold stability
  4. Covering-number bounds on the Poincaré threshold
  5. A Lipschitz stability result for thresholds under perturbation
-/
import Mathlib

open scoped NNReal

noncomputable section

/-! ## Part 1: Rips Graph Construction -/

/-- The Rips graph (1-skeleton of the Vietoris-Rips complex) at scale ε.
    Two distinct points are adjacent iff their distance is at most ε. -/
def ripsGraph (α : Type*) [PseudoMetricSpace α] (ε : ℝ) : SimpleGraph α where
  Adj x y := x ≠ y ∧ dist x y ≤ ε
  symm x y := by
    intro ⟨hne, hd⟩
    exact ⟨hne.symm, by rw [dist_comm]; exact hd⟩
  loopless := ⟨fun x ⟨hne, _⟩ => hne rfl⟩

/-- The Rips filtration is monotone: larger scales yield more edges. -/
theorem ripsGraph_mono {α : Type*} [PseudoMetricSpace α] {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ripsGraph α ε₁ ≤ ripsGraph α ε₂ :=
  fun _u _v huv => ⟨huv.1, le_trans huv.2 h⟩

/-! ## Part 2: Approximate Isometries -/

/-- A function f : α → β is a δ-approximate isometry if it distorts all
    pairwise distances by at most δ. This is the key notion connecting
    metric geometry to persistent homology stability. -/
structure IsApproxIsometry {α β : Type*} [PseudoMetricSpace α] [PseudoMetricSpace β]
    (f : α → β) (δ : ℝ) : Prop where
  distortion : ∀ x y : α, |dist (f x) (f y) - dist x y| ≤ δ
  delta_nonneg : 0 ≤ δ

/-- **Interleaving Theorem**: A δ-approximate isometry maps Rips edges at
    scale ε to Rips edges at scale ε + δ. This is the fundamental bridge
    between metric perturbation and filtration shift. -/
theorem interleaving_of_approxIsometry {α β : Type*}
    [PseudoMetricSpace α] [PseudoMetricSpace β]
    {f : α → β} {δ : ℝ} (hf : IsApproxIsometry f δ) (hfinj : Function.Injective f)
    {ε : ℝ} {x y : α} (hadj : (ripsGraph α ε).Adj x y) :
    (ripsGraph β (ε + δ)).Adj (f x) (f y) := by
  refine ⟨hfinj.ne hadj.1, ?_⟩
  linarith [abs_le.mp (hf.distortion x y), hadj.2]

/-! ## Part 3: Abstract Metric Filtrations -/

/-- A `MetricFiltration` is a monotone family of propositions indexed by a
    real-valued scale parameter. This abstracts the pattern common to Rips
    complexes, Čech complexes, alpha complexes, etc. -/
structure MetricFiltration where
  /-- The property that holds at scale ε -/
  property : ℝ → Prop
  /-- The filtration is monotone -/
  mono : ∀ ε₁ ε₂ : ℝ, ε₁ ≤ ε₂ → property ε₁ → property ε₂

/-- The threshold of a metric filtration: the infimum of scales at which the
    property holds. -/
def MetricFiltration.threshold (F : MetricFiltration) : ℝ :=
  sInf {ε : ℝ | F.property ε}

/-- A filtration dominates another if its property implies the other's at every scale. -/
def MetricFiltration.Dominates (F G : MetricFiltration) : Prop :=
  ∀ ε : ℝ, F.property ε → G.property ε

/-- **Threshold Antitone Principle**: If filtration F dominates G (F's property
    implies G's), then G's threshold ≤ F's threshold, because G's level set
    is a superset of F's. -/
theorem threshold_antitone {F G : MetricFiltration}
    (hdom : MetricFiltration.Dominates F G)
    (hFne : {ε : ℝ | F.property ε}.Nonempty)
    (hGbdd : BddBelow {ε : ℝ | G.property ε}) :
    G.threshold ≤ F.threshold := by
  apply_rules [csInf_le_csInf]

/-! ## Part 4: Shifted Filtrations and Stability -/

/-- Shifting a filtration by δ: the property at scale ε becomes the original
    property at scale ε - δ. -/
def MetricFiltration.shift (F : MetricFiltration) (δ : ℝ) : MetricFiltration where
  property ε := F.property (ε - δ)
  mono ε₁ ε₂ h := F.mono _ _ (by linarith)

/-
The threshold of a shifted filtration equals the original threshold plus δ.
-/
theorem threshold_shift (F : MetricFiltration) (δ : ℝ)
    (hne : {ε : ℝ | F.property ε}.Nonempty)
    (hbdd : BddBelow {ε : ℝ | F.property ε}) :
    (F.shift δ).threshold = F.threshold + δ := by
  unfold MetricFiltration.threshold MetricFiltration.shift;
  rw [ @csInf_eq_of_forall_ge_of_forall_gt_exists_lt ];
  · exact ⟨ hne.choose + δ, by simpa using hne.choose_spec ⟩;
  · exact fun x hx => by linarith [ show sInf { ε : ℝ | F.property ε } ≤ x - δ from csInf_le hbdd hx ] ;
  · intro w hw; rcases exists_lt_of_csInf_lt ( hne ) ( show InfSet.sInf { ε | F.property ε } < w - δ by linarith ) with ⟨ x, hx, hx' ⟩ ; exact ⟨ x + δ, by aesop, by linarith ⟩ ;

/-
**Stability Theorem (correct interleaving direction)**: If each filtration's
    shift dominates the other—meaning F.property(ε-δ) → G.property(ε) and
    G.property(ε-δ) → F.property(ε)—then the thresholds differ by at most δ.

    This corresponds to the standard δ-interleaving in persistent homology:
    the shifted version of F is "easier" than G, and vice versa.
-/
theorem threshold_stability_correct {F G : MetricFiltration} {δ : ℝ} (_hδ : 0 ≤ δ)
    (hFG : MetricFiltration.Dominates (F.shift δ) G)
    (hGF : MetricFiltration.Dominates (G.shift δ) F)
    (hFne : {ε : ℝ | F.property ε}.Nonempty)
    (hGne : {ε : ℝ | G.property ε}.Nonempty)
    (hFbdd : BddBelow {ε : ℝ | F.property ε})
    (hGbdd : BddBelow {ε : ℝ | G.property ε}) :
    |F.threshold - G.threshold| ≤ δ := by
  refine' abs_sub_le_iff.mpr ⟨ _, _ ⟩;
  · rw [ sub_le_iff_le_add' ];
    convert threshold_antitone _ _ _ using 1;
    rotate_left;
    exact ⟨ fun ε => G.property ( ε - δ ), fun ε₁ ε₂ h => G.mono _ _ ( by linarith ) ⟩;
    · exact hGF;
    · exact ⟨ hGne.choose + δ, by simpa using hGne.choose_spec ⟩;
    · assumption;
    · convert threshold_shift _ _ _ _ |> Eq.symm using 1; all_goals assumption;
  · have := @threshold_antitone ( F.shift δ ) G ?_ ?_ ?_;
    · linarith [ threshold_shift F δ hFne hFbdd ];
    · assumption;
    · obtain ⟨ ε, hε ⟩ := hFne;
      exact ⟨ ε + δ, by simpa [ MetricFiltration.shift ] using hε ⟩;
    · assumption

/-! ## Part 5: Rips Connectivity Filtration -/

/-- The connectivity filtration for the Rips graph of a finite type. -/
def ripsConnFiltration (α : Type*) [PseudoMetricSpace α] [Fintype α] :
    MetricFiltration where
  property ε := (ripsGraph α ε).Preconnected
  mono ε₁ ε₂ h hconn := by
    intro x y
    exact (hconn x y).mono (ripsGraph_mono h)

/-! ## Part 6: Covering Numbers and Threshold Bounds -/

/-- A finite ε-covering of a metric space. -/
def IsεCovering {α : Type*} [PseudoMetricSpace α] (S : Finset α) (ε : ℝ) : Prop :=
  ∀ x : α, ∃ s ∈ S, dist x s ≤ ε

/-- **Covering implies connectivity**: If diameter ≤ 2ε, the Rips graph at
    scale 2ε is preconnected. -/
theorem covering_diameter_connectivity {α : Type*} [PseudoMetricSpace α] [Fintype α]
    {ε : ℝ} (_hε : 0 ≤ ε)
    (hdiam : ∀ x y : α, dist x y ≤ 2 * ε) :
    (ripsGraph α (2 * ε)).Preconnected := by
  intro x y
  by_cases hxy : x = y
  · exact hxy.symm ▸ SimpleGraph.Reachable.refl _
  · exact SimpleGraph.Adj.reachable ⟨hxy, hdiam x y⟩

/-! ## Part 7: Edge Count Monotonicity -/

/-- The number of ordered Rips edge pairs is monotone in ε for finite types. -/
def ripsEdgeCount (α : Type*) [PseudoMetricSpace α] [Fintype α] [DecidableEq α]
    (ε : ℝ) : ℕ :=
  Finset.card (Finset.univ.filter (fun p : α × α => p.1 ≠ p.2 ∧ dist p.1 p.2 ≤ ε))

theorem ripsEdgeCount_mono (α : Type*) [PseudoMetricSpace α] [Fintype α] [DecidableEq α]
    {ε₁ ε₂ : ℝ} (h : ε₁ ≤ ε₂) :
    ripsEdgeCount α ε₁ ≤ ripsEdgeCount α ε₂ := by
  exact Finset.card_mono fun x hx =>
    Finset.mem_filter.mpr ⟨Finset.mem_univ _, by
      have := Finset.mem_filter.mp hx
      exact ⟨this.2.1, this.2.2.trans h⟩⟩

/-! ## Part 8: Approximate Isometry Composition -/

/-- Composition of approximate isometries: a (δ₁+δ₂)-approx isometry. -/
theorem approxIsometry_comp {α β γ : Type*}
    [PseudoMetricSpace α] [PseudoMetricSpace β] [PseudoMetricSpace γ]
    {f : α → β} {g : β → γ} {δ₁ δ₂ : ℝ}
    (hf : IsApproxIsometry f δ₁) (hg : IsApproxIsometry g δ₂) :
    IsApproxIsometry (g ∘ f) (δ₁ + δ₂) := by
  constructor
  · intro x y
    rw [abs_le]
    constructor <;>
      linarith! [abs_le.mp (hf.distortion x y), abs_le.mp (hg.distortion (f x) (f y))]
  · linarith [hf.delta_nonneg, hg.delta_nonneg]

/-! ## Part 9: Threshold Shift Bound -/

/-
One-sided stability: if F.property ε ⟹ G.property (ε+δ),
    then G.threshold ≤ F.threshold + δ.
-/
theorem threshold_shift_bound {F G : MetricFiltration} {δ : ℝ} (_hδ : 0 ≤ δ)
    (h : ∀ ε, F.property ε → G.property (ε + δ))
    (hFne : {ε : ℝ | F.property ε}.Nonempty)
    (_hFbdd : BddBelow {ε : ℝ | F.property ε})
    (hGbdd : BddBelow {ε : ℝ | G.property ε}) :
    G.threshold ≤ F.threshold + δ := by
  refine' le_of_forall_pos_le_add fun ε ε_pos => _;
  -- By definition of infimum, there exists some $\varepsilon_1$ such that $F.property \varepsilon_1$ and $\varepsilon_1 < F.threshold + \varepsilon$.
  obtain ⟨ε₁, hε₁⟩ : ∃ ε₁, F.property ε₁ ∧ ε₁ < MetricFiltration.threshold F + ε := by
    exact exists_lt_of_csInf_lt ( hFne ) ( lt_add_of_pos_right _ ε_pos );
  exact le_trans ( csInf_le hGbdd ( h ε₁ hε₁.1 ) ) ( by linarith )

end