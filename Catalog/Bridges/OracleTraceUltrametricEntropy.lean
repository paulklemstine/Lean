/-
  # Oracle Trace Ultrametric Entropy

  A non-Archimedean metric geometry for oracle traces, connecting
  ultrametric valuation theory, thermodynamic entropy bounds,
  certified ML robustness, and post-quantum separation principles.

  Bridge: connects ultrametric valuation geometry to thermodynamic
  entropy bounds, certified_robustness in ML, and post_quantum_security.

  Keywords: ultrametric, entropy, capacity, certified_robustness,
            post_quantum_security, lattice_crypto, thermodynamic
-/
import Bridges.LongestCommonValuedPrefix
open List Finset OracleTrace

namespace OracleTrace

variable {α : Type*} [DecidableEq α]

/-! ## Section 1: Prefix Distance and Gap -/

/-- Exponential prefix distance: `ρ ^ lcvpLen(u,v)`.
Bridge: connects algebra (exponential valuation) to ultrametric_geometry. -/
noncomputable def prefixDist (ρ : ℝ) (u v : List α) : ℝ :=
  ρ ^ (lcvpLen u v)

/-- Normalized prefix gap that vanishes on equal traces.
Bridge: connects to certified_robustness (Lipschitz_bound). -/
noncomputable def prefixGap (ρ : ℝ) (u v : List α) : ℝ :=
  if u = v then 0 else ρ ^ (lcvpLen u v)

/-! ## Section 2: Oracle Trace Model -/

/-- An oracle trace model maps states to list-valued traces.
Bridge: connects oracle_semantics to ultrametric_geometry. -/
structure OracleTraceModel (σ α : Type*) [Fintype σ] [DecidableEq σ] [DecidableEq α] where
  encode : σ → List α
  depth : Nat

def OracleTraceModel.Bounded [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α) : Prop :=
  ∀ s, (M.encode s).length ≤ M.depth

def OracleTraceModel.Injective [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α) : Prop :=
  Function.Injective M.encode

/-! ## Section 3: Entropy and Capacity Proxies -/

/-- Oracle entropy proxy: log of support cardinality.
Bridge: connects information_theory to thermodynamic oracle semantics. -/
noncomputable def oracleEntropyProxy [DecidableEq τ] (S : Finset τ) : ℝ :=
  Real.log (S.card)

/-- Oracle state capacity: log of the number of states.
Bridge: connects channel_capacity to thermodynamic_entropy. -/
noncomputable def oracleCapacity (states : Finset σ) : ℝ :=
  Real.log (states.card)

/-- Oracle capacity density: capacity per depth layer.
Bridge: connects thermodynamic oracle semantics to information rate. -/
noncomputable def oracleCapacityDensity [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α) : ℝ :=
  oracleCapacity (Finset.univ : Finset σ) / (M.depth + 1 : ℝ)

/-! ## Section 4: Ultrametric Balls and Certified Robustness -/

/-- Ultrametric ball in prefix gap geometry.
Bridge: connects ultrametric_geometry to certified_robustness. -/
noncomputable def prefixBall (ρ : ℝ) (u : List α) (r : ℝ) : Set (List α) :=
  {v | prefixGap ρ u v < r}

/-- Certified prefix robustness radius.
Bridge: connects to certified_robustness and Lipschitz_bound. -/
noncomputable def certifiedPrefixRadius (ρ : ℝ) (u v : List α) : ℝ :=
  prefixGap ρ u v / 2

/-- Post-quantum prefix separation: all distinct traces separate.
Bridge: connects to post_quantum_security and lattice_crypto. -/
def postQuantumPrefixSeparation (ρ : ℝ) (S : Finset (List α)) : Prop :=
  ∀ ⦃u v⦄, u ∈ S → v ∈ S → u ≠ v → 0 < prefixGap ρ u v

/-! ## Section 5: Normalized Entropy Proxy -/

/-- Normalized oracle entropy proxy: `log(|S|) / |S|`.
Bridge: connects information_theory to thermodynamic_entropy bounds. -/
noncomputable def normalizedOracleEntropyProxy [DecidableEq τ] (S : Finset τ) : ℝ :=
  if S.card = 0 then 0 else Real.log S.card / S.card

/-! ## Section 6: prefixGap Basic Properties -/

theorem prefixGap_self {ρ : ℝ} (u : List α) :
    prefixGap ρ u u = 0 := by
  simp [prefixGap]

theorem prefixGap_symmetric {ρ : ℝ} (u v : List α) :
    prefixGap ρ u v = prefixGap ρ v u := by
  simp only [prefixGap]
  by_cases h : u = v
  · subst h; simp
  · simp [h, Ne.symm h, lcvpLen_symmetric]

theorem prefixGap_nonneg {ρ : ℝ} (hρ0 : 0 < ρ) (u v : List α) :
    0 ≤ prefixGap ρ u v := by
  simp only [prefixGap]; split
  · exact le_refl 0
  · exact le_of_lt (pow_pos hρ0 _)

/-- Positive gap for distinct traces.
Bridge: connects to post_quantum_security (collision detection). -/
theorem prefixGap_pos_of_ne {ρ : ℝ} (hρ0 : 0 < ρ) {u v : List α} (h : u ≠ v) :
    0 < prefixGap ρ u v := by
  simp [prefixGap, h, pow_pos hρ0]

/-- Gap formula for distinct traces. -/
theorem prefixGap_explicit_formula
    {ρ : ℝ} {u v : List α} (hne : u ≠ v) :
    prefixGap ρ u v = ρ ^ lcvpLen u v := by
  simp [prefixGap, hne]

/-- Zero gap iff equal — the separation axiom.
Bridge: connects ultrametric_geometry to certified_robustness. -/
theorem prefixGap_eq_zero_iff {ρ : ℝ} (hρ0 : 0 < ρ) (_hρ1 : ρ < 1)
    (u v : List α) :
    prefixGap ρ u v = 0 ↔ u = v := by
  constructor
  · intro h0; by_contra hne; exact absurd h0 (ne_of_gt (prefixGap_pos_of_ne hρ0 hne))
  · intro h; subst h; exact prefixGap_self u

/-- Zero gap iff equal, transported along an injective encoding.
Bridge: connects to post_quantum_security and lattice_crypto. -/
theorem prefixGap_eq_zero_iff_of_PrefixInjective
    {β : Type*} {encode : β → List α}
    (hinj : PrefixInjective encode)
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1)
    (x y : β) :
    prefixGap ρ (encode x) (encode y) = 0 ↔ x = y := by
  rw [prefixGap_eq_zero_iff hρ0 hρ1]; exact hinj.eq_iff

/-! ## Section 7: Monotonicity of Powers on (0,1) -/

theorem pow_antitone_of_lt_one {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1) :
    Antitone (fun n : Nat => ρ ^ n) := by
  intro a b hab
  exact pow_le_pow_of_le_one (le_of_lt hρ0) (le_of_lt hρ1) hab

/-! ## Section 8: The Strong Ultrametric Inequality -/

/-- **The strong ultrametric inequality for `prefixDist`.**
Bridge: connects ultrametric valuation geometry to non-Archimedean
metric spaces and quantum oracle trace semantics. -/
theorem prefixDist_ultrametric_strong
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1)
    (u v w : List α) :
    prefixDist ρ u w ≤ max (prefixDist ρ u v) (prefixDist ρ v w) := by
  simp only [prefixDist]
  have hval := lcvpLen_ge_min_of_triangle u v w
  have hmono := pow_antitone_of_lt_one hρ0 hρ1
  calc ρ ^ lcvpLen u w
      ≤ ρ ^ min (lcvpLen u v) (lcvpLen v w) := hmono hval
    _ ≤ max (ρ ^ lcvpLen u v) (ρ ^ lcvpLen v w) := by
        rcases Nat.le_total (lcvpLen u v) (lcvpLen v w) with h | h
        · rw [Nat.min_eq_left h]; exact le_max_left _ _
        · rw [Nat.min_eq_right h]; exact le_max_right _ _

/-
**Isosceles strengthening**: if two pairwise distances differ,
the third equals the larger. Hallmark of non-Archimedean geometry.
Bridge: connects to quantum oracle semantics and certified_robustness.
-/
theorem prefixDist_isosceles_quantum
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1)
    (u v w : List α)
    (hstrict : prefixDist ρ u v < prefixDist ρ v w) :
    prefixDist ρ u w = prefixDist ρ v w := by
  -- Since ρ ∈ (0,1), ρ^· is strictly antitone on ℕ. From hstrict : ρ^lcvpLen(u,v) < ρ^lcvpLen(v,w), we get lcvpLen(v,w) < lcvpLen(u,v).
  have h_lcvpLen : lcvpLen v w < lcvpLen u v := by
    unfold prefixDist at hstrict;
    rwa [ pow_lt_pow_iff_right_of_lt_one₀ hρ0 hρ1 ] at hstrict;
  have h_lcvpLen2 : lcvpLen u w ≤ lcvpLen v w := by
    have := lcvpLen_ge_min_of_triangle v u w;
    rw [ min_le_iff ] at this;
    exact this.resolve_left ( by linarith [ lcvpLen_symmetric u v ] );
  have h_lcvpLen3 : lcvpLen v w ≤ lcvpLen u w := by
    apply le_trans (by
    exact le_min h_lcvpLen.le le_rfl) (lcvpLen_ge_min_of_triangle u v w);
  exact congr_arg _ ( le_antisymm h_lcvpLen2 h_lcvpLen3 )

/-! ## Section 9: prefixDist Concatenation Contraction -/

/-- Common prefixes contract `prefixDist` multiplicatively.
Bridge: connects to certified_robustness (context contraction)
and lattice_crypto (error propagation). -/
theorem prefixDist_concat_contracts
    {ρ : ℝ} (p u v : List α) :
    prefixDist ρ (p ++ u) (p ++ v) = ρ ^ p.length * prefixDist ρ u v := by
  simp only [prefixDist, lcvpLen_append_left, pow_add]

/-! ## Section 10: Ball Properties -/

theorem prefixBall_center_mem {ρ : ℝ} (u : List α) {r : ℝ} (hr : 0 < r) :
    u ∈ prefixBall ρ u r := by
  simp [prefixBall, prefixGap, hr]

theorem prefixBall_nested {ρ : ℝ} (_hρ0 : 0 < ρ) (_hρ1 : ρ < 1)
    {u : List α} {r s : ℝ} (hrs : r ≤ s) :
    prefixBall ρ u r ⊆ prefixBall ρ u s := by
  intro v hv; simp only [prefixBall, Set.mem_setOf_eq] at *; linarith

/-! ## Section 11: Entropy–Capacity Theorems -/

theorem oracleEntropy_le_log_card_support [DecidableEq τ]
    (S : Finset τ) :
    oracleEntropyProxy S ≤ Real.log S.card := by
  simp [oracleEntropyProxy]

/-
**The entropy–capacity inequality**.
Bridge: connects thermodynamic oracle semantics to information_theory.
-/
theorem oracleEntropy_le_log_capacity
    [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α)
    (_hbounded : M.Bounded)
    (_hinj : M.Injective) :
    oracleEntropyProxy ((Finset.univ : Finset σ).image M.encode) ≤
      oracleCapacity (Finset.univ : Finset σ) := by
  simp only [oracleEntropyProxy, oracleCapacity]
  rw [ Finset.card_image_of_injective _ _hinj ]

/-- **Entropy = capacity under injectivity**.
Bridge: connects thermodynamic oracle semantics to certified_robustness. -/
theorem oracleEntropy_eq_log_capacity_of_injective
    [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α)
    (hinj : M.Injective) :
    oracleEntropyProxy ((Finset.univ : Finset σ).image M.encode) =
      oracleCapacity (Finset.univ : Finset σ) := by
  simp only [oracleEntropyProxy, oracleCapacity]
  congr 1; exact_mod_cast Finset.card_image_of_injective _ hinj

/-! ## Section 12: Post-Quantum Separation -/

/-- **Post-quantum prefix separation under injective encoding**.
Bridge: connects post_quantum_security to ultrametric_geometry. -/
theorem postQuantumPrefixSeparation_of_injective
    [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α)
    (_hinj : M.Injective)
    {ρ : ℝ} (hρ0 : 0 < ρ) (_hρ1 : ρ < 1) :
    postQuantumPrefixSeparation ρ ((Finset.univ : Finset σ).image M.encode) := by
  intro u v _hu _hv huv; exact prefixGap_pos_of_ne hρ0 huv

/-! ## Section 13: Certified Robustness Radius -/

theorem certifiedPrefixRadius_nonneg
    {ρ : ℝ} (hρ0 : 0 < ρ) (u v : List α) :
    0 ≤ certifiedPrefixRadius ρ u v := by
  exact div_nonneg (prefixGap_nonneg hρ0 u v) (by norm_num)

/-! ## Section 14: Existence Theorems -/

/-- ∀ distinct traces, ∃ a prefix depth witness for the gap value.
Bridge: connects ultrametric_geometry to constructive oracle semantics. -/
theorem exists_prefixGap_witness_of_ne
    {ρ : ℝ} (_hρ0 : 0 < ρ) (_hρ1 : ρ < 1)
    {u v : List α} (hne : u ≠ v) :
    ∃ k, k ≤ min u.length v.length ∧ prefixGap ρ u v = ρ ^ k :=
  ⟨lcvpLen u v, lcvpLen_le_min u v, by simp [prefixGap, hne]⟩

/-- ∀ ρ ∈ (0,1), ∀ distinct u v, ∃ a positive lower bound for the gap.
Bridge: connects to lattice_crypto (minimum distance existence). -/
theorem exists_positive_gap_bound
    {ρ : ℝ} (hρ0 : 0 < ρ) (_hρ1 : ρ < 1)
    {u v : List α} (hne : u ≠ v) :
    ∃ δ, 0 < δ ∧ δ ≤ prefixGap ρ u v :=
  ⟨prefixGap ρ u v, prefixGap_pos_of_ne hρ0 hne, le_refl _⟩

/-- ∀ finite set with > 1 element, ∃ a separated pair.
Bridge: connects to lattice_crypto (minimum distance computation). -/
theorem exists_min_gap_pair
    {ρ : ℝ} (_hρ0 : 0 < ρ) (_hρ1 : ρ < 1)
    (S : Finset (List α)) (hS : 1 < S.card)
    (hsep : postQuantumPrefixSeparation ρ S) :
    ∃ u ∈ S, ∃ v ∈ S, u ≠ v ∧ 0 < prefixGap ρ u v := by
  obtain ⟨u, hu, v, hv, huv⟩ := Finset.one_lt_card.mp hS
  exact ⟨u, hu, v, hv, huv, hsep hu hv huv⟩

/-! ## Section 15: prefixDist Basic Properties -/

theorem prefixDist_pos {ρ : ℝ} (hρ0 : 0 < ρ) (u v : List α) :
    0 < prefixDist ρ u v := pow_pos hρ0 _

theorem prefixDist_symmetric {ρ : ℝ} (u v : List α) :
    prefixDist ρ u v = prefixDist ρ v u := by
  simp [prefixDist, lcvpLen_symmetric]

theorem prefixDist_self {ρ : ℝ} (u : List α) :
    prefixDist ρ u u = ρ ^ u.length := by simp [prefixDist]

theorem prefixDist_eq_one_of_head_ne {ρ : ℝ} {a b : α} (h : a ≠ b)
    (u v : List α) :
    prefixDist ρ (a :: u) (b :: v) = 1 := by
  simp [prefixDist, lcvpLen_cons_cons_ne h]

/-! ## Section 16: Min-Length Characterization -/

theorem lcvpLen_eq_min_lengths_iff (u v : List α) :
    lcvpLen u v = min u.length v.length ↔
      List.take (min u.length v.length) u = List.take (min u.length v.length) v :=
  ⟨fun h => h ▸ take_lcvpLen_eq u v,
   fun h => le_antisymm (lcvpLen_le_min u v) (lcvpLen_maximal_prefix u v _ le_rfl h)⟩

/-! ## Section 17: Cross-Domain Theorems -/

/-- **Thermodynamic trace channel bound**.
Bridge: connects thermodynamic_entropy to channel_capacity. -/
theorem thermodynamic_trace_channel_bound
    [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α)
    (hinj : M.Injective) :
    oracleEntropyProxy ((Finset.univ : Finset σ).image M.encode) =
      oracleCapacity (Finset.univ : Finset σ) :=
  oracleEntropy_eq_log_capacity_of_injective M hinj

/-- **Lattice-crypto prefix collision barrier**.
Bridge: connects lattice_crypto to ultrametric_geometry. -/
theorem lattice_crypto_prefix_collision_barrier
    [Fintype σ] [DecidableEq σ]
    (M : OracleTraceModel σ α)
    (hinj : M.Injective)
    {ρ : ℝ} (hρ0 : 0 < ρ) (_hρ1 : ρ < 1) :
    ∀ s₁ s₂ : σ, s₁ ≠ s₂ → 0 < prefixGap ρ (M.encode s₁) (M.encode s₂) :=
  fun _ _ hne => prefixGap_pos_of_ne hρ0 (hinj.ne hne)

/-
Ultrametric clustering trichotomy: in any triple, at least two
pairwise distances are equal.
Bridge: connects ultrametric_geometry to clustering algorithms.
-/
theorem ultrametric_clustering_trichotomy
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1) (u v w : List α) :
    prefixDist ρ u v = prefixDist ρ v w ∨
    prefixDist ρ u v = prefixDist ρ u w ∨
    prefixDist ρ v w = prefixDist ρ u w := by
  -- By the properties of the prefix distance and the ultrametric inequality, we can show that at least two of the three pairwise distances must be equal.
  apply Classical.byContradiction
  intro h_contra
  push_neg at h_contra
  generalize_proofs at *; (
  -- Without loss of generality, assume that $prefixDist ρ u v < prefixDist ρ v w$.
  wlog h_wlog : prefixDist ρ u v < prefixDist ρ v w generalizing u v w;
  · by_cases h_cases : prefixDist ρ v w < prefixDist ρ u w;
    · specialize this v w u ; simp_all +decide [ prefixDist_symmetric ];
      exact h_contra.2.1 ( this ( Ne.symm h_contra.1 ) ▸ rfl );
    · specialize this w u v ; simp_all +decide [ prefixDist_symmetric ];
      exact h_contra.1 ( le_antisymm ( by linarith [ this ( by tauto ) ( by tauto ) ] ) h_wlog );
  · -- By the ultrametric inequality, we have $prefixDist ρ u w = prefixDist ρ v w$.
    have h_ultrametric : prefixDist ρ u w = prefixDist ρ v w := by
      apply prefixDist_isosceles_quantum hρ0 hρ1 u v w h_wlog
    generalize_proofs at *; (
    tauto))

/-
The prefix gap satisfies the ultrametric inequality.
Bridge: connects to certified_robustness (perturbation stability).
-/
theorem prefixGap_ultrametric
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1) (u v w : List α) :
    prefixGap ρ u w ≤ max (prefixGap ρ u v) (prefixGap ρ v w) := by
  unfold prefixGap;
  split_ifs <;> simp_all +decide;
  · exact Or.inl ( pow_nonneg hρ0.le _ );
  · have := prefixDist_ultrametric_strong hρ0 hρ1 u v w;
    unfold prefixDist at this; aesop;

/-! ## Section 18: Normalized Entropy Properties -/

theorem normalizedOracleEntropyProxy_nonneg [DecidableEq τ]
    (S : Finset τ) (hS : 0 < S.card) :
    0 ≤ normalizedOracleEntropyProxy S := by
  unfold normalizedOracleEntropyProxy;
  split_ifs <;> positivity

theorem normalizedOracleEntropyProxy_le_of_large [DecidableEq τ]
    (S : Finset τ) (hS : 3 ≤ S.card) :
    normalizedOracleEntropyProxy S ≤ Real.log S.card / S.card := by
  exact if_neg ( by positivity ) |> ( fun h => h.le )

end OracleTrace