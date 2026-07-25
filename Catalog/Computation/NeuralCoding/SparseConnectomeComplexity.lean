import Mathlib

/-!
# Sparse Connectome Complexity: Information-Theoretic Bounds on Mind Encoding

This file develops the theory of **weighted connectomes** and their compression limits,
extending the binary connectome model to multi-level synaptic weights. The central
contribution is the **Neural Information Defect (NID)**, a novel measure that quantifies
the irreversible information loss when a connectome's synaptic weight resolution is
reduced through coarse-graining.

## Main Definitions

* `WeightedConnectomeSpace n k`: The space of weighted directed graphs on `n` neurons
  with `k` possible weight levels per synapse.
* `NeuralInfoDefect`: The Neural Information Defect—measuring bits lost when reducing
  from `k` to `m` weight levels.
* `neuronOutDegree`: The out-degree of a neuron in a weighted connectome.
* `IsSparseConnectome`: Predicate for degree-bounded connectomes.
* `MindEncodingSystem`: A system specifying neurons, weight levels, and storage budget.

## Main Results

* `weighted_connectome_card`: Cardinality of `WeightedConnectomeSpace n k` is `k^(n²)`.
* `weighted_encoding_card_bound`: Injective binary encoding requires `k^(n²) ≤ 2^B`.
* `nid_monotone_resolution`: NID is monotone—coarser resolution increases information loss.
* `coarsening_not_injective`: Pointwise coarse-graining is non-injective when `m < k`.
* `resolution_reduction_not_injective`: Any map from finer to coarser space is non-injective.
* `sparse_strict_subspace`: Sparse connectomes form a proper subset when `d < n`.
* `resolution_fidelity_bound`: Faithful encoding requires `k^(n²) ≤ 2^B`.
-/

open Finset Fintype Function BigOperators

noncomputable section

/-! ## Part 1: Weighted Connectome Space -/

/-- A **weighted connectome** on `n` neurons with `k` weight levels assigns to each
ordered pair `(i, j)` of neurons a synaptic weight in `Fin k`. Weight `0` typically
represents "no synapse." -/
abbrev WeightedConnectomeSpace (n k : ℕ) := Fin n → Fin n → Fin k

/-- The cardinality of the weighted connectome space is `k^(n*n)`. -/
theorem weighted_connectome_card (n k : ℕ) :
    Fintype.card (WeightedConnectomeSpace n k) = k ^ (n * n) := by
  simp [Fintype.card_fin, pow_mul]

/-- **Weighted encoding lower bound**: Any injective map from `k`-weighted connectomes
on `n` neurons into binary strings of length `B` requires `k^(n²) ≤ 2^B`. -/
theorem weighted_encoding_card_bound (n k B : ℕ)
    (f : WeightedConnectomeSpace n k → (Fin B → Bool))
    (hf : Injective f) :
    k ^ (n * n) ≤ 2 ^ B := by
  have h1 : Fintype.card (WeightedConnectomeSpace n k) ≤ Fintype.card (Fin B → Bool) :=
    Fintype.card_le_of_injective f hf
  rwa [weighted_connectome_card, Fintype.card_fun, Fintype.card_fin, Fintype.card_bool] at h1

/-! ## Part 2: The Neural Information Defect (NID)

The NID measures the information lost when reducing weight resolution from `k` levels
to `m` levels. We define it using `Nat.log` as the combinatorial log-cardinality gap.
-/

/-- The **Neural Information Defect** (NID): bits of information lost when reducing
from `k` to `m` weight levels across `n²` synaptic positions.

`NID(n, k, m) = n² * (log₂ k - log₂ m)`

This is a novel combinatorial measure introduced in this work. -/
def NeuralInfoDefect (n k m : ℕ) : ℕ :=
  n * n * (Nat.log 2 k - Nat.log 2 m)

/-- The NID is zero when the resolution is unchanged. -/
theorem nid_self (n k : ℕ) : NeuralInfoDefect n k k = 0 := by
  simp [NeuralInfoDefect]

/-- The NID scales quadratically with neuron count. -/
theorem nid_quadratic_scaling (n k m : ℕ) :
    NeuralInfoDefect (2 * n) k m = 4 * NeuralInfoDefect n k m := by
  simp [NeuralInfoDefect]; ring

/-- **NID monotonicity in resolution**: Coarsening further only increases the defect.
If `m₁ ≤ m₂`, then `NID(n, k, m₂) ≤ NID(n, k, m₁)`. -/
theorem nid_monotone_resolution (n k m₁ m₂ : ℕ) (h : m₁ ≤ m₂) :
    NeuralInfoDefect n k m₂ ≤ NeuralInfoDefect n k m₁ := by
  unfold NeuralInfoDefect
  apply Nat.mul_le_mul_left
  apply Nat.sub_le_sub_left
  exact Nat.log_mono_right h

/-- **NID monotonicity in source resolution**: Increasing source resolution
increases the defect. If `k₁ ≤ k₂`, then `NID(n, k₁, m) ≤ NID(n, k₂, m)`. -/
theorem nid_monotone_source (n k₁ k₂ m : ℕ) (h : k₁ ≤ k₂) :
    NeuralInfoDefect n k₁ m ≤ NeuralInfoDefect n k₂ m := by
  unfold NeuralInfoDefect
  apply Nat.mul_le_mul_left
  apply Nat.sub_le_sub_right
  exact Nat.log_mono_right h

/-- **NID neuron monotonicity**: More neurons means more information to lose. -/
theorem nid_monotone_neurons (n₁ n₂ k m : ℕ) (h : n₁ ≤ n₂) :
    NeuralInfoDefect n₁ k m ≤ NeuralInfoDefect n₂ k m := by
  unfold NeuralInfoDefect
  apply Nat.mul_le_mul_right
  exact Nat.mul_le_mul h h

/-! ## Part 3: Coarse-Graining Maps and Non-Injectivity -/

/-- A **pointwise coarse-graining** applies the same weight-reduction function
to every synapse independently. -/
def pointwiseCoarseGrain (n : ℕ) (φ : Fin k → Fin m) :
    WeightedConnectomeSpace n k → WeightedConnectomeSpace n m :=
  fun W i j => φ (W i j)

/-- **Coarse-graining is non-injective**: When `m < k` and `n ≥ 1`, any
pointwise coarse-graining is not injective. This is the fundamental
irreversibility of resolution reduction. -/
theorem coarsening_not_injective {n k m : ℕ} (hn : 1 ≤ n) (hm : m < k)
    (φ : Fin k → Fin m) :
    ¬ Injective (pointwiseCoarseGrain n φ) := by
  intro hinj
  have hφ_inj : Injective φ := by
    intro a b hab
    have : pointwiseCoarseGrain n φ (fun _ _ => a) = pointwiseCoarseGrain n φ (fun _ _ => b) := by
      ext i j; simp [pointwiseCoarseGrain, hab]
    have := hinj this
    exact congr_fun (congr_fun this ⟨0, by omega⟩) ⟨0, by omega⟩
  exact absurd (Fintype.card_le_of_injective φ hφ_inj) (by simp [Fintype.card_fin]; omega)

/-- Composing two pointwise coarse-grainings yields a pointwise coarse-graining. -/
theorem coarsegrain_composition (n : ℕ) (φ : Fin k → Fin m) (ψ : Fin m → Fin l) :
    (pointwiseCoarseGrain n ψ) ∘ (pointwiseCoarseGrain n φ) =
    pointwiseCoarseGrain n (ψ ∘ φ) := by
  ext W i j
  simp [pointwiseCoarseGrain]

/-! ## Part 4: Sparse Connectomes -/

/-- The **out-degree** of neuron `i` in a weighted connectome (counting nonzero weights).
Requires `k > 0` so that `(0 : Fin k)` is well-defined. -/
def neuronOutDegree {n : ℕ} {k : ℕ} [NeZero k] (W : WeightedConnectomeSpace n k)
    (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j : Fin n => W i j ≠ 0)).card

/-- A **sparse connectome** has maximum out-degree bounded by `d`. -/
def IsSparseConnectome {n : ℕ} {k : ℕ} [NeZero k] (W : WeightedConnectomeSpace n k)
    (d : ℕ) : Prop :=
  ∀ i : Fin n, neuronOutDegree W i ≤ d

/-- **Full degree bound**: Every connectome is sparse with degree bound `n`. -/
theorem every_connectome_n_sparse {n : ℕ} {k : ℕ} [NeZero k]
    (W : WeightedConnectomeSpace n k) :
    IsSparseConnectome W n := by
  intro i
  unfold neuronOutDegree
  exact (Finset.card_filter_le _ _).trans (by simp)

/-
**Sparse subspace is strict**: When `k ≥ 2` and `d < n`, the set of
`d`-sparse connectomes is a proper subset of all connectomes.
-/
theorem sparse_strict_subspace {n k d : ℕ} [NeZero k] (hk : 2 ≤ k) (hdn : d < n) :
    { W : WeightedConnectomeSpace n k | IsSparseConnectome W d } ⊂ Set.univ := by
  simp +decide [ Set.ssubset_univ_iff, IsSparseConnectome ];
  norm_num [ Set.ext_iff ];
  use fun _ _ => 1, ⟨ 0, by linarith ⟩;
  unfold neuronOutDegree; aesop;

/-! ## Part 5: Resolution Reduction Non-Injectivity -/

/-
**Non-injectivity of resolution reduction**: Any function from a larger
weighted connectome space to a smaller one is non-injective. This is a
fundamental impossibility result for mind uploading at reduced fidelity.
-/
theorem resolution_reduction_not_injective {n k m : ℕ}
    (hn : 1 ≤ n) (hm : 0 < m) (hmk : m < k)
    (f : WeightedConnectomeSpace n k → WeightedConnectomeSpace n m) :
    ¬ Injective f := by
  have h_card : Fintype.card (WeightedConnectomeSpace n k) > Fintype.card (WeightedConnectomeSpace n m) := by
    rw [ weighted_connectome_card, weighted_connectome_card ];
    gcongr;
  exact fun h => h_card.not_ge <| Fintype.card_le_of_injective f h

/-! ## Part 6: Mind Encoding System -/

/-- A **mind encoding system** specifies a weight resolution, neuron count,
and digital storage budget. -/
structure MindEncodingSystem where
  neurons : ℕ
  weight_levels : ℕ
  storage_bits : ℕ
  neurons_pos : 0 < neurons
  weights_pos : 0 < weight_levels

/-- An encoding system is **faithful** if it can injectively encode all connectomes. -/
def MindEncodingSystem.isFaithful (S : MindEncodingSystem) : Prop :=
  ∃ f : WeightedConnectomeSpace S.neurons S.weight_levels → (Fin S.storage_bits → Bool),
    Injective f

/-- **Resolution-fidelity theorem**: A faithful encoding requires storage
satisfying `k^(n²) ≤ 2^B`. -/
theorem resolution_fidelity_bound (S : MindEncodingSystem) (hf : S.isFaithful) :
    S.weight_levels ^ (S.neurons * S.neurons) ≤ 2 ^ S.storage_bits := by
  obtain ⟨f, hf⟩ := hf
  exact weighted_encoding_card_bound S.neurons S.weight_levels S.storage_bits f hf

/-- **Weight resolution scaling**: Each doubling of weight levels multiplies
the encoding space. -/
theorem weight_resolution_doubling (n k : ℕ) :
    (2 * k) ^ (n * n) = 2 ^ (n * n) * k ^ (n * n) := by
  rw [mul_pow]

/-! ## Part 7: Coarse-Graining Collision Theorem -/

/-
**Coarse-graining produces collisions**: When mapping from `k^(n²)` elements
to `m^(n²)` elements with `k > m`, some pair of distinct inputs must collide.
-/
theorem coarsegrain_has_collision {n k m : ℕ}
    (hn : 1 ≤ n) (hm : 0 < m) (hmk : m < k)
    (f : WeightedConnectomeSpace n k → WeightedConnectomeSpace n m) :
    ∃ x₁ x₂ : WeightedConnectomeSpace n k, x₁ ≠ x₂ ∧ f x₁ = f x₂ := by
  convert resolution_reduction_not_injective hn hm hmk f;
  simp +decide [ Function.Injective, not_forall ];
  tauto

/-! ## Part 8: Connectome Entropy -/

/-- **Connectome entropy** in bits (log₂ of the space size). -/
def connectomeEntropy (n k : ℕ) : ℕ := n * n * Nat.log 2 k

/-- Entropy is monotone in weight levels. -/
theorem entropy_monotone_weights (n k₁ k₂ : ℕ) (h : k₁ ≤ k₂) :
    connectomeEntropy n k₁ ≤ connectomeEntropy n k₂ := by
  unfold connectomeEntropy
  exact Nat.mul_le_mul_left _ (Nat.log_mono_right h)

/-- Entropy is monotone in neuron count. -/
theorem entropy_monotone_neurons (n₁ n₂ k : ℕ) (h : n₁ ≤ n₂) :
    connectomeEntropy n₁ k ≤ connectomeEntropy n₂ k := by
  unfold connectomeEntropy
  exact Nat.mul_le_mul_right _ (Nat.mul_le_mul h h)

/-! ## Part 9: The Digital Immortality Impossibility -/

/-
**Digital immortality requires unbounded storage**: For any fixed storage budget `B`,
there exists a sufficiently large brain (neuron count `n` and weight levels `k`) such that
no faithful encoding exists.
-/
theorem digital_immortality_impossible (B : ℕ) :
    ∃ n k : ℕ, 0 < n ∧ 0 < k ∧
      ∀ f : WeightedConnectomeSpace n k → (Fin B → Bool), ¬ Injective f := by
  use B + 1, 2;
  refine' ⟨ Nat.succ_pos _, by decide, fun f hf => _ ⟩;
  have := @weighted_encoding_card_bound ( B + 1 ) 2 B f hf;
  exact not_le_of_gt ( pow_lt_pow_right₀ ( by decide ) ( by nlinarith ) ) this

/-! ## Part 10: Handshaking Lemma for Weighted Connectomes -/

/-- The **in-degree** of neuron `j` in a weighted connectome. -/
def neuronInDegree {n : ℕ} {k : ℕ} [NeZero k] (W : WeightedConnectomeSpace n k)
    (j : Fin n) : ℕ :=
  (Finset.univ.filter (fun i : Fin n => W i j ≠ 0)).card

/-
**Total edge count via out-degrees equals total via in-degrees**.
This is a weighted connectome version of the handshaking lemma.
-/
theorem total_degree_equality {n : ℕ} {k : ℕ} [NeZero k]
    (W : WeightedConnectomeSpace n k) :
    ∑ i : Fin n, neuronOutDegree W i = ∑ j : Fin n, neuronInDegree W j := by
  simp +decide only [neuronOutDegree, card_filter, neuronInDegree];
  exact Finset.sum_comm

end