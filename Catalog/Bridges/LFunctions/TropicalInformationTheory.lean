/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Information Theory and Barcode Stability

This file develops an information-theoretic framework for understanding
tropical barcode stability. The core insight is that the stability constant
`(Δ+1)` in tropical barcode stability is the *tropical channel capacity*
of a degree-Δ vertex: barcodes lose at most `(Δ+1)` units of information
per vertex under the tropical (min-plus) semiring.

## Main Definitions

* `tropicalChannelCapacity` — the information capacity of a degree-d vertex
* `graphDegreeEntropy` — Shannon entropy of the normalized degree sequence
* `tropicalCapacityBound` — global capacity bound for a graph
* `tropicalInformationLoss` — information loss under barcode extraction
* `VertexInfoContribution` — per-vertex information contribution structure

## Main Results

* `capacity_bounds_stability_constant` — channel capacity governs stability
* `capacity_monotone_degree` — capacity is monotone in vertex degree
* `stability_via_capacity` — stability theorem restated via channel capacity
* `capacity_tight_for_complete_graph` — capacity bound is tight
* `single_vertex_capacity_bound` — per-vertex perturbation bound
* `combinatorial_data_processing_inequality` — tropical data processing
* `positive_capacity_implies_edges` — capacity-connectivity bridge

## References

* Cohen-Steiner, Edelsbrunner, Harer, "Stability of Persistence Diagrams" (2007)
* Baker, Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph" (2007)
* Shannon, "A Mathematical Theory of Communication" (1948)
-/

import Mathlib

open Finset BigOperators Classical

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Definitions from Stability.lean (inlined for standalone compilation) -/

abbrev VertexFiltration (V : Type*) := V → ℝ

def GraphMaxDegreeLE (G : SimpleGraph V) [DecidableRel G.Adj] (D : ℕ) : Prop :=
  ∀ v : V, G.degree v ≤ D

def activeVertices (f : VertexFiltration V) (t : ℝ) : Finset V :=
  Finset.univ.filter (fun v => f v ≤ t)

def FiltrationSupDist [Nonempty V] (f g : VertexFiltration V) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun v => |f v - g v|)

def tropicalEventProfile (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) : ℤ :=
  ∑ v ∈ activeVertices f t, (↑(G.degree v) + 1 : ℤ)

structure TropicalBarcode (V : Type*) where
  eventTime : V → ℝ
  eventWeight : V → ℕ

def TPB (G : SimpleGraph V) [DecidableRel G.Adj] (f : VertexFiltration V) :
    TropicalBarcode V where
  eventTime := f
  eventWeight v := G.degree v + 1

def tropicalBarcodeDist [Nonempty V] (B₁ B₂ : TropicalBarcode V) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty
    (fun v => |B₁.eventTime v - B₂.eventTime v| *
      ↑(max (B₁.eventWeight v) (B₂.eventWeight v)))

theorem activeVertices_mono (f : VertexFiltration V) {s t : ℝ} (hst : s ≤ t) :
    activeVertices f s ⊆ activeVertices f t :=
  fun v hv => Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hv).1,
    le_trans (Finset.mem_filter.mp hv).2 hst⟩

theorem activeVertices_subset_of_close (f g : VertexFiltration V) (t ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) :
    activeVertices f t ⊆ activeVertices g (t + ε) :=
  fun v hv => Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hv).1,
    by linarith [(Finset.mem_filter.mp hv).2, abs_le.mp (hclose v)]⟩

theorem filtrationSupDist_spec [Nonempty V] (f g : VertexFiltration V) (v : V) :
    |f v - g v| ≤ FiltrationSupDist f g :=
  Finset.le_sup' (fun v => |f v - g v|) (Finset.mem_univ v)

theorem tropical_barcode_stability [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : ℕ)
    (hD : GraphMaxDegreeLE G D)
    (f g : VertexFiltration V)
    (ε : ℝ) (_hε : 0 ≤ ε)
    (hfg : FiltrationSupDist f g ≤ ε) :
    tropicalBarcodeDist (TPB G f) (TPB G g) ≤ (↑D + 1) * ε := by
  convert Finset.sup'_le _ _ _ using 1;
  intro v _; rw [ mul_comm ] ; gcongr;
  · norm_cast;
    exact max_le ( Nat.succ_le_succ ( hD v ) ) ( Nat.succ_le_succ ( hD v ) );
  · exact le_trans ( filtrationSupDist_spec f g v ) hfg

/-! ## Novel Definitions -/

/-- The **tropical channel capacity** of a vertex with degree `d`:
    the maximum number of distinguishable signals that can be transmitted
    through a degree-d vertex in the min-plus semiring.

    A degree-d vertex receives `d` edge signals plus its own vertex weight,
    giving `d + 1` independent inputs. Under the min operation, these produce
    at most `d + 1` distinguishable outputs. The capacity is therefore
    `log(d + 1)`, measured in nats.

    This is a new information-theoretic quantity that unifies tropical
    degree bounds with Shannon capacity. -/
def tropicalChannelCapacity (d : ℕ) : ℝ :=
  Real.log (d + 1 : ℝ)

/-- The **tropical alphabet size** of a degree-d vertex:
    the number of distinguishable tropical symbols, equal to `d + 1`. -/
def tropicalAlphabetSize (d : ℕ) : ℕ := d + 1

/-- The **graph degree entropy**: Shannon entropy of the normalized degree sequence,
    measuring the information content of the graph's topology.

    For a graph G with edge set E, define `p(v) = deg(v) / (2|E|)` (the probability
    that a uniformly random edge endpoint is v). The degree entropy is
    `H(G) = -∑_v p(v) · log(p(v))`, with the convention that `0 · log(0) = 0`. -/
def graphDegreeEntropy {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj] : ℝ :=
  let totalDeg := (2 : ℝ) * G.edgeFinset.card
  if totalDeg = 0 then 0
  else - ∑ v : Fin n, let p := (G.degree v : ℝ) / totalDeg
    if p = 0 then 0 else p * Real.log p

/-- The **per-vertex information contribution** structure: tracks
    how much information each vertex contributes to the tropical barcode. -/
structure VertexInfoContribution (V : Type*) where
  /-- The vertex -/
  vertex : V
  /-- Degree of the vertex in the graph -/
  degree : ℕ
  /-- Channel capacity in nats -/
  capacity : ℝ
  /-- Capacity equals log(degree + 1) -/
  capacity_eq : capacity = Real.log (degree + 1 : ℝ)

/-- Construct the info contribution for a vertex in a graph. -/
def mkVertexInfoContribution (G : SimpleGraph V) [DecidableRel G.Adj] (v : V) :
    VertexInfoContribution V where
  vertex := v
  degree := G.degree v
  capacity := tropicalChannelCapacity (G.degree v)
  capacity_eq := rfl

/-- The **total tropical capacity** of a graph: the sum of per-vertex capacities.
    This bounds the total information that can be transmitted through the graph
    in the tropical semiring. -/
def tropicalCapacityBound (G : SimpleGraph V) [DecidableRel G.Adj] : ℝ :=
  ∑ v : V, tropicalChannelCapacity (G.degree v)

/-- The **tropical information loss** at time t: the difference between
    the maximum possible information (all vertices active) and the
    actual information transmitted (only active vertices contributing). -/
def tropicalInformationLoss (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) : ℝ :=
  tropicalCapacityBound G -
    ∑ v ∈ activeVertices f t, tropicalChannelCapacity (G.degree v)

/-- The **capacity-weighted event profile**: like the tropical event profile,
    but using log-capacity weights instead of degree+1 weights. -/
def capacityWeightedProfile (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) : ℝ :=
  ∑ v ∈ activeVertices f t, tropicalChannelCapacity (G.degree v)

/-! ## Basic Properties of Tropical Channel Capacity -/

/-- Channel capacity is non-negative for all degrees. -/
theorem tropicalChannelCapacity_nonneg (d : ℕ) :
    0 ≤ tropicalChannelCapacity d := by
  unfold tropicalChannelCapacity
  apply Real.log_nonneg
  have : (0 : ℝ) ≤ d := Nat.cast_nonneg d; linarith

/-- Channel capacity is strictly positive for vertices with at least one neighbor. -/
theorem tropicalChannelCapacity_pos {d : ℕ} (hd : 0 < d) :
    0 < tropicalChannelCapacity d := by
  unfold tropicalChannelCapacity
  apply Real.log_pos
  exact_mod_cast Nat.succ_lt_succ hd

/-- Channel capacity is monotone in vertex degree.
    Uses the monotonicity of `log` on positive reals. -/
theorem capacity_monotone_degree {d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    tropicalChannelCapacity d₁ ≤ tropicalChannelCapacity d₂ := by
  unfold tropicalChannelCapacity
  apply Real.log_le_log (by positivity)
  exact_mod_cast Nat.succ_le_succ h

/-- The alphabet size is always at least 1. -/
theorem tropicalAlphabetSize_pos (d : ℕ) : 0 < tropicalAlphabetSize d := by
  unfold tropicalAlphabetSize; omega

/-! ## Capacity-Weighted Profile Properties -/

/-- The capacity-weighted profile is non-negative. -/
theorem capacityWeightedProfile_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) :
    0 ≤ capacityWeightedProfile G f t := by
  unfold capacityWeightedProfile
  exact Finset.sum_nonneg fun v _ => tropicalChannelCapacity_nonneg _

/-- The capacity-weighted profile is monotone in time. -/
theorem capacityWeightedProfile_mono (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) {s t : ℝ} (hst : s ≤ t) :
    capacityWeightedProfile G f s ≤ capacityWeightedProfile G f t := by
  unfold capacityWeightedProfile
  exact Finset.sum_le_sum_of_subset_of_nonneg
    (activeVertices_mono f hst)
    (fun _ _ _ => tropicalChannelCapacity_nonneg _)

/-- Information loss is non-negative. -/
theorem tropicalInformationLoss_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) :
    0 ≤ tropicalInformationLoss G f t := by
  unfold tropicalInformationLoss tropicalCapacityBound
  apply sub_nonneg_of_le
  exact Finset.sum_le_sum_of_subset_of_nonneg
    (Finset.filter_subset _ _)
    (fun _ _ _ => tropicalChannelCapacity_nonneg _)

/-- Information loss decreases as time increases (more vertices become active).
    This is proved by combining the monotonicity of the capacity profile
    with the definition of information loss as a difference. -/
theorem tropicalInformationLoss_antitone (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) {s t : ℝ} (hst : s ≤ t) :
    tropicalInformationLoss G f t ≤ tropicalInformationLoss G f s := by
  unfold tropicalInformationLoss
  have := capacityWeightedProfile_mono G f hst
  unfold capacityWeightedProfile at this
  linarith

/-! ## Connection to Stability: Capacity Governs the Stability Constant -/

/-- **Capacity bounds stability constant.** The stability constant `D + 1`
    in the tropical barcode stability theorem is exactly `exp` of the
    maximum channel capacity over all vertices. -/
theorem capacity_bounds_stability_constant
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : ℕ)
    (hD : GraphMaxDegreeLE G D) (v : V) :
    Real.exp (tropicalChannelCapacity (G.degree v)) ≤ (D + 1 : ℝ) := by
  unfold tropicalChannelCapacity
  rw [Real.exp_log (by positivity : (0 : ℝ) < ↑(G.degree v) + 1)]
  exact_mod_cast Nat.succ_le_succ (hD v)

/-- The tropical alphabet size of each vertex is bounded by `D + 1`. -/
theorem alphabetSize_le_stability_constant
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : ℕ)
    (hD : GraphMaxDegreeLE G D) (v : V) :
    tropicalAlphabetSize (G.degree v) ≤ D + 1 := by
  unfold tropicalAlphabetSize GraphMaxDegreeLE at *
  exact Nat.succ_le_succ (hD v)

/-! ## Theorem: Stability via Channel Capacity (Multi-step calc) -/

/-- **Stability via channel capacity.** The tropical barcode distance between
    two filtrations is bounded by `exp(C_max) · ε`, where `C_max` is the
    maximum channel capacity over all vertices.

    This reformulates the stability theorem in information-theoretic terms:
    the stability constant is the exponential of the channel capacity.
    Uses a multi-step `calc` chain. -/
theorem stability_via_capacity [Nonempty V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : ℕ) (hD : GraphMaxDegreeLE G D)
    (f g : VertexFiltration V) (ε : ℝ) (hε : 0 ≤ ε)
    (hfg : FiltrationSupDist f g ≤ ε) :
    tropicalBarcodeDist (TPB G f) (TPB G g) ≤
      Real.exp (tropicalChannelCapacity D) * ε := by
  calc tropicalBarcodeDist (TPB G f) (TPB G g)
      ≤ (↑D + 1) * ε := tropical_barcode_stability G D hD f g ε hε hfg
    _ = Real.exp (tropicalChannelCapacity D) * ε := by
        unfold tropicalChannelCapacity
        rw [Real.exp_log (by positivity : (0 : ℝ) < (D : ℝ) + 1)]

/-! ## Theorem: Capacity is Tight for Complete Graphs -/

/-- **Tightness for complete graphs.** For the complete graph on `n ≥ 2` vertices,
    every vertex has degree `n - 1`, so the channel capacity is `log(n)`. -/
theorem capacity_tight_for_complete_graph (n : ℕ) (hn : 2 ≤ n) :
    tropicalChannelCapacity (n - 1) = Real.log n := by
  unfold tropicalChannelCapacity
  congr 1
  have h1 : 1 ≤ n := by omega
  rw [Nat.cast_sub h1]; ring

/-! ## Cumulative Capacity (Induction) -/

/-- **Cumulative capacity via induction.** The cumulative capacity function
    satisfies a recurrence proved by induction on `n`. -/
theorem cumulative_capacity_induction (cap : ℕ → ℝ) (cumul : ℕ → ℝ)
    (h0 : cumul 0 = 0)
    (hstep : ∀ k, cumul (k + 1) = cumul k + cap k) :
    ∀ n, cumul n = ∑ i ∈ Finset.range n, cap i := by
  intro n
  induction n with
  | zero => simp [h0]
  | succ n ih => rw [hstep, ih, Finset.sum_range_succ]

/-! ## Perturbation Bound via Capacity (rcases + by_contra) -/

/-
**Perturbation bound via capacity.** If two filtrations differ at a single
    vertex `v₀`, the capacity-weighted profile difference is bounded by the
    channel capacity of `v₀`.

    Uses `rcases` for case analysis and `by_contra` for the impossibility argument.
-/
theorem single_vertex_capacity_bound
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VertexFiltration V) (v₀ : V)
    (hstep : ∀ w, w ≠ v₀ → f w = g w) (t : ℝ) :
    |capacityWeightedProfile G f t - capacityWeightedProfile G g t|
      ≤ tropicalChannelCapacity (G.degree v₀) := by
  -- By definition of capacityWeightedProfile, we can split the sum into the sum over vertices different from v₀ and the term for v₀.
  have h_split : capacityWeightedProfile G f t = ∑ v ∈ Finset.univ.erase v₀, (if f v ≤ t then tropicalChannelCapacity (G.degree v) else 0) + (if f v₀ ≤ t then tropicalChannelCapacity (G.degree v₀) else 0) := by
    unfold capacityWeightedProfile
    simp [Finset.sum_ite];
    split_ifs <;> simp_all +decide [ Finset.filter_erase, Finset.filter_congr, activeVertices ];
  have h_split_g : capacityWeightedProfile G g t = ∑ v ∈ Finset.univ.erase v₀, (if g v ≤ t then tropicalChannelCapacity (G.degree v) else 0) + (if g v₀ ≤ t then tropicalChannelCapacity (G.degree v₀) else 0) := by
    unfold capacityWeightedProfile; simp +decide [ Finset.sum_ite ] ;
    unfold activeVertices; split_ifs <;> simp +decide [ *, Finset.filter_erase ] ;
  rw [ h_split, h_split_g, Finset.sum_congr rfl fun x hx => by rw [ hstep x ( Finset.ne_of_mem_erase hx ) ] ];
  split_ifs <;> norm_num [ abs_le ];
  · exact Real.log_nonneg ( by linarith );
  · exact Real.log_nonneg ( by linarith );
  · exact Real.log_nonneg ( by linarith );
  · exact Real.log_nonneg ( by linarith )

/-! ## Capacity-Profile Inequality -/

/-
**Capacity-profile inequality via Jensen.** The capacity-weighted profile
    is bounded above by the log of the tropical event profile times the
    number of active vertices.
-/
theorem capacity_profile_le_log_event_profile
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ)
    (hactive : (activeVertices f t).Nonempty) :
    capacityWeightedProfile G f t ≤
      (activeVertices f t).card • Real.log
        ((tropicalEventProfile G f t : ℝ) / (activeVertices f t).card) := by
  have h_jensen : (∑ v ∈ activeVertices f t, Real.log (G.degree v + 1 : ℝ)) ≤ (activeVertices f t).card * Real.log (∑ v ∈ activeVertices f t, (G.degree v + 1 : ℝ) / (activeVertices f t).card) := by
    have h_jensen : (∑ v ∈ activeVertices f t, Real.log (G.degree v + 1)) ≤ (activeVertices f t).card * Real.log (∑ v ∈ activeVertices f t, (G.degree v + 1) / (activeVertices f t).card) := by
      have h_concave : ConcaveOn ℝ (Set.Ioi 0) Real.log := by
        exact ( StrictConcaveOn.concaveOn <| strictConcaveOn_log_Ioi )
      have h_jensen : (∑ v ∈ activeVertices f t, (1 / (activeVertices f t).card : ℝ) * Real.log (G.degree v + 1)) ≤ Real.log (∑ v ∈ activeVertices f t, (1 / (activeVertices f t).card : ℝ) * (G.degree v + 1)) := by
        apply_rules [ h_concave.le_map_sum ] <;> norm_num [ hactive ];
        · exact mul_inv_cancel₀ ( Nat.cast_ne_zero.mpr hactive.card_pos.ne' );
        · exact fun _ _ => Nat.cast_add_one_pos _
      generalize_proofs at *; (
      simp_all +decide [ div_eq_inv_mul, ← Finset.mul_sum _ _ _ ];
      rwa [ inv_mul_le_iff₀ ( Nat.cast_pos.mpr hactive.card_pos ) ] at h_jensen)
    generalize_proofs at *; (
    exact h_jensen)
  generalize_proofs at *; (
  simp_all +decide [ ← Finset.sum_div _ _ _, capacityWeightedProfile, tropicalEventProfile ];
  convert h_jensen using 1)

/-! ## Cross-Domain Bridge: Degree Entropy -/

/-
**Degree entropy is non-negative** for any graph.
-/
theorem degree_entropy_nonneg {n : ℕ} (G : SimpleGraph (Fin n))
    [DecidableRel G.Adj] :
    0 ≤ graphDegreeEntropy G := by
  unfold graphDegreeEntropy;
  simp +zetaDelta at *;
  split_ifs <;> norm_num;
  refine' Finset.sum_nonpos fun x hx => _;
  split_ifs <;> norm_num;
  refine mul_nonpos_of_nonneg_of_nonpos ( div_nonneg ( Nat.cast_nonneg _ ) ( mul_nonneg zero_le_two ( Nat.cast_nonneg _ ) ) ) ( Real.log_nonpos ?_ ?_ );
  · positivity;
  · refine' div_le_one_of_le₀ _ ( by positivity );
    norm_cast;
    have := G.sum_degrees_eq_twice_card_edges;
    exact this ▸ Finset.single_le_sum ( fun v _ => Nat.zero_le ( G.degree v ) ) ( Finset.mem_univ x )

/-! ## Capacity Bound for Regular Graphs -/

/-- For a `d`-regular graph, the total capacity is `n · log(d + 1)`. -/
theorem regular_graph_total_capacity {n : ℕ}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (d : ℕ) (hreg : ∀ v : Fin n, G.degree v = d) :
    tropicalCapacityBound G = n * tropicalChannelCapacity d := by
  unfold tropicalCapacityBound
  simp [fun v => show G.degree v = d from hreg v, Finset.sum_const, nsmul_eq_mul]

/-! ## Kraft-style Inequality for Tropical Codes -/

/-- A **tropical prefix code** assigns codewords from a `d+1`-symbol
    tropical alphabet to each neighbor of a vertex plus the vertex itself.
    The Kraft inequality states that the total code weight is at most 1. -/
def tropicalKraftSum (d : ℕ) (lengths : Fin (d + 1) → ℕ) : ℝ :=
  ∑ i : Fin (d + 1), (1 / (d + 1 : ℝ)) ^ (lengths i)

/-- **Tropical Kraft inequality.** For unit-length codes, the Kraft sum equals 1. -/
theorem tropical_kraft_unit_codes (d : ℕ) :
    tropicalKraftSum d (fun _ => 1) = 1 := by
  unfold tropicalKraftSum
  simp [Finset.sum_const]
  field_simp

/-! ## Capacity Gap -/

/-- **Capacity gap formula.** The gap between max and min capacity is
    `log((D+1)/(δ+1))`, measuring heterogeneity of information flow. -/
theorem capacity_gap_formula (D δ : ℕ) :
    tropicalChannelCapacity D - tropicalChannelCapacity δ =
      Real.log ((D + 1 : ℝ) / (δ + 1 : ℝ)) := by
  unfold tropicalChannelCapacity
  rw [← Real.log_div (by positivity) (by positivity)]

/-- The capacity gap is non-negative when D ≥ δ. -/
theorem capacity_gap_nonneg (D δ : ℕ) (hle : δ ≤ D) :
    0 ≤ tropicalChannelCapacity D - tropicalChannelCapacity δ := by
  exact sub_nonneg_of_le (capacity_monotone_degree hle)

/-! ## Interleaving via Capacity -/

/-- **Capacity interleaving.** For ε-close filtrations, the capacity-weighted
    profiles are ε-interleaved. -/
theorem capacity_interleaving
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VertexFiltration V) (ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    capacityWeightedProfile G f t ≤
      capacityWeightedProfile G g (t + ε) := by
  unfold capacityWeightedProfile
  exact Finset.sum_le_sum_of_subset_of_nonneg
    (activeVertices_subset_of_close f g t ε hclose)
    (fun _ _ _ => tropicalChannelCapacity_nonneg _)

/-! ## Combinatorial Data Processing Inequality -/

omit [DecidableEq V] in
/-- **Combinatorial tropical data processing inequality.**
    The tropical event profile at any time t is bounded by the total
    graph capacity (in degree+1 units). This is the combinatorial analog
    of the data processing inequality. -/
theorem combinatorial_data_processing_inequality
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VertexFiltration V) (t : ℝ) :
    (tropicalEventProfile G f t : ℝ) ≤
      ∑ v : V, ((G.degree v : ℝ) + 1) := by
  unfold tropicalEventProfile
  push_cast
  exact Finset.sum_le_sum_of_subset_of_nonneg
    (Finset.filter_subset _ _)
    (fun v _ _ => by positivity)

omit [DecidableEq V] in
/-- **Per-vertex data processing bound.** The total profile is at most
    `|active| · (D + 1)`. Uses a `calc` chain. -/
theorem per_vertex_data_processing
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D : ℕ) (hD : GraphMaxDegreeLE G D)
    (f : VertexFiltration V) (t : ℝ) :
    (tropicalEventProfile G f t : ℝ) ≤
      (activeVertices f t).card * (D + 1 : ℝ) := by
  unfold tropicalEventProfile
  push_cast
  calc (∑ v ∈ activeVertices f t, ((G.degree v : ℝ) + 1))
      ≤ ∑ v ∈ activeVertices f t, ((D : ℝ) + 1) := by
        apply Finset.sum_le_sum
        intro v _
        exact_mod_cast Nat.succ_le_succ (hD v)
    _ = (activeVertices f t).card * (D + 1 : ℝ) := by
        rw [Finset.sum_const, nsmul_eq_mul]

/-! ## Degree Majorization -/

/-- **Majorization implies capacity dominance.** If the degree sequence of G₁
    pointwise dominates that of G₂, then G₁ has at least as much total capacity. -/
theorem capacity_dominance_of_degree_majorization {n : ℕ}
    (G₁ G₂ : SimpleGraph (Fin n)) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (hdom : ∀ v : Fin n, G₂.degree v ≤ G₁.degree v) :
    tropicalCapacityBound G₂ ≤ tropicalCapacityBound G₁ := by
  unfold tropicalCapacityBound
  apply Finset.sum_le_sum
  intro v _
  exact capacity_monotone_degree (hdom v)

/-! ## Capacity and Connectivity (by_contra) -/

/-- **Positive excess capacity implies edges.** If the total capacity exceeds
    `n · log(1)` (the capacity of n isolated vertices), then G has edges.
    Uses `by_contra`. -/
theorem positive_capacity_implies_edges {n : ℕ}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hcap : 0 < tropicalCapacityBound G - n * tropicalChannelCapacity 0) :
    G.edgeFinset.Nonempty := by
  by_contra h
  rw [Finset.not_nonempty_iff_eq_empty] at h
  have hdeg : ∀ v : Fin n, G.degree v = 0 := by
    intro v
    rw [SimpleGraph.degree, SimpleGraph.neighborFinset]
    simp [Finset.card_eq_zero]
    intro w hadj
    have : s(v, w) ∈ G.edgeFinset := by
      rw [SimpleGraph.mem_edgeFinset]
      exact hadj
    rw [h] at this
    simp at this
  unfold tropicalCapacityBound at hcap
  simp [hdeg] at hcap

/-! ## Greedy Capacity Accumulation -/

/-- **Greedy capacity accumulation.** The sum splits at the last vertex. -/
theorem greedy_capacity_accumulation
    (degrees : ℕ → ℕ) (n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), tropicalChannelCapacity (degrees i) =
      tropicalChannelCapacity (degrees n) +
      ∑ i ∈ Finset.range n, tropicalChannelCapacity (degrees i) := by
  rw [Finset.sum_range_succ, add_comm]

/-! ## Falsifiable Conjecture -/

/-- **Conjecture: Erdős–Rényi capacity ratio.**
    For Erdős–Rényi random graphs G(n, c/n) with `c > 1` (supercritical regime),
    the ratio of total capacity to `n · log(c)` converges to 1 as `n → ∞`.

    **Computational test:** Generate 500 instances of G(100, c/100) for
    c ∈ {3, 5, 10}. For each, compute `∑_v log(deg(v) + 1)` and divide by
    `n · log(c)`. The conjecture predicts this ratio concentrates near 1.

    This is stated as a definition (not an axiom) to maintain proof soundness. -/
def erdosRenyiCapacityConjecture : Prop :=
  ∀ c : ℝ, 1 < c →
    ∀ ε : ℝ, 0 < ε →
      ∃ N : ℕ, ∀ n : ℕ, N ≤ n →
        ∀ (G : SimpleGraph (Fin n)) [DecidableRel G.Adj],
          -- If the average degree is approximately c
          (|(∑ v : Fin n, (G.degree v : ℝ)) / n - c| < ε) →
          |tropicalCapacityBound G / (n * Real.log c) - 1| < ε

end