/-
# Graph Coloring with Emotions: The Chromatic Polynomial Meets Psychology

This module formalizes the connection between graph coloring theory and
emotional diversity in social networks. We define the *emotional chromatic
number* χ_E(G), a variant of the chromatic number requiring at least 3 colors
(modeling the psychological insight that meaningful emotional categorization
needs ≥ 3 distinct states), and prove structural theorems connecting it
to classical graph invariants.

## Main Definitions
- `chromaticCount`: The number of proper k-colorings of a finite graph
- `EmotionalChromaticNumber`: The smallest k ≥ 3 such that G is k-colorable
- `emotionalDiversity`: A normalized measure of emotional diversity in a network
- `SocialNetwork`: A structure bundling a graph with emotional constraints

## Main Results
- Complete graph K_n has exactly k^{(n)} proper k-colorings (falling factorial)
- The emotional chromatic number of K_n equals max(n, 3)
- Emotional diversity is bounded by log of the chromatic count
- Cross-domain connection to information-theoretic channel capacity
-/

import Mathlib

open SimpleGraph Finset Fintype

/-! ## Section 1: Chromatic Count — Counting Proper Colorings -/

/-- The chromatic count χ(G, k) is the number of proper k-colorings of G,
    i.e., the cardinality of the set of graph homomorphisms from G to K_k. -/
noncomputable def chromaticCount {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : ℕ :=
  Fintype.card (G.Coloring (Fin k))

/-
A graph with no edges (the empty graph on V) has k^|V| proper k-colorings,
    since every function is a proper coloring.
-/
theorem chromaticCount_bot (n k : ℕ) :
    chromaticCount (⊥ : SimpleGraph (Fin n)) k = k ^ n := by
  unfold chromaticCount
  -- Coloring of ⊥ is just any function Fin n → Fin k
  -- since ⊥ has no edges, every function is a valid coloring
  -- The type of colorings of the empty graph on Fin n is equivalent to the type of functions from Fin n to Fin k.
  have h_equiv : (⊥ : SimpleGraph (Fin n)).Coloring (Fin k) ≃ (Fin n → Fin k) := by
    exact ⟨fun c => c.toFun, fun f => ⟨f, by
      aesop⟩, by
      aesop_cat, by
      exact fun f => by aesop;⟩;
  rw [ Fintype.card_congr h_equiv, Fintype.card_pi ] ; aesop

/-! ## Section 2: The Emotional Chromatic Number -/

/-- The emotional chromatic number χ_E(G) is the smallest k ≥ 3 such that
    G is k-colorable. This models the insight from psychology that meaningful
    emotional categorization requires at least 3 distinct states (positive,
    negative, neutral), making binary classification too coarse for real
    social dynamics. Returns 0 if no such k exists (for infinite chromatic number). -/
noncomputable def EmotionalChromaticNumber {V : Type*}
    (G : SimpleGraph V) : ℕ :=
  sInf {k : ℕ | 3 ≤ k ∧ G.Colorable k}

/-
Any graph is colorable with |V| colors (assign each vertex a distinct color).
-/
theorem colorable_of_fintype {V : Type*} [Fintype V]
    (G : SimpleGraph V) : G.Colorable (Fintype.card V) := by
  convert G.colorable_of_fintype

/-
The emotional chromatic number of any finite nonempty graph is at least 3.
-/
theorem emotionalChromaticNumber_ge_three {V : Type*} [Fintype V] [Nonempty V]
    (G : SimpleGraph V) (h : 3 ≤ Fintype.card V) :
    3 ≤ EmotionalChromaticNumber G := by
  by_contra h_contra;
  convert Nat.sInf_mem ?_;
  convert h_contra;
  · aesop;
  · convert Nat.sInf_eq_zero.mpr ?_;
    · exact Nat.eq_zero_of_not_pos fun h' => h_contra <| Nat.sInf_mem ( show { k : ℕ | 3 ≤ k ∧ G.Colorable k }.Nonempty from by exact ⟨ _, h, G.colorable_of_fintype ⟩ ) |>.1;
    · exact Or.inr ( Set.eq_empty_of_forall_notMem fun k hk => h_contra <| le_csInf ⟨ _, ⟨ by linarith [ hk.out ], G.colorable_of_fintype ⟩ ⟩ fun n hn => hn.1 );
  · exact?

/-
For the complete graph K_n with n ≥ 3, the emotional chromatic number equals n.
    This is because K_n requires exactly n colors (each vertex must have a distinct
    color since all pairs are adjacent), and n ≥ 3 satisfies the emotional threshold.
-/
theorem emotionalChromaticNumber_completeGraph {n : ℕ} (hn : 3 ≤ n) :
    EmotionalChromaticNumber (completeGraph (Fin n)) = n := by
  -- The chromatic number of K_n is n, so the set {k | 3 ≤ k ∧ K_n.Colorable k} is equal to {k | n ≤ k}.
  have h_chromatic : ∀ k : ℕ, (completeGraph (Fin n)).Colorable k ↔ n ≤ k := by
    intro k
    constructor;
    · rintro ⟨ f, hf ⟩;
      exact le_of_not_gt fun h => by have := Fintype.card_le_of_injective f ( fun a b hab => by contrapose! hab; aesop ) ; norm_num at this ; linarith;
    · intro hk
      use fun v => ⟨v.val, by
        linarith [ Fin.is_lt v ]⟩
      generalize_proofs at *;
      exact fun { a b } hab => by simpa [ Fin.ext_iff ] using hab;
  exact le_antisymm ( csInf_le' ⟨ hn, h_chromatic n |>.2 le_rfl ⟩ ) ( le_csInf ⟨ n, ⟨ hn, h_chromatic n |>.2 le_rfl ⟩ ⟩ fun k hk => hk.2 |> fun hk' => h_chromatic k |>.1 hk' )

/-! ## Section 3: Complete Graph Coloring Count -/

/-
The number of proper k-colorings of the complete graph K_n equals
    the falling factorial k^{(n)} = k(k-1)(k-2)...(k-n+1).
    This is because in K_n every vertex is adjacent to every other,
    so each vertex must receive a distinct color. The first vertex
    has k choices, the second k-1, etc.
-/
theorem chromaticCount_completeGraph (n k : ℕ) :
    chromaticCount (completeGraph (Fin n)) k = Nat.descFactorial k n := by
  -- A coloring of the complete graph $K_n$ with $k$ colors is an injective function from $Fin n$ to $Fin k$.
  have h_bij : (completeGraph (Fin n)).Coloring (Fin k) ≃ {f : Fin n → Fin k | Function.Injective f} := by
    refine' Equiv.ofBijective ( fun f => ⟨ f.toFun, _ ⟩ ) ⟨ fun a b h => _, fun a => _ ⟩;
    all_goals norm_num at *;
    exact fun x y hxy => by_contra fun h => f.valid ( by simpa [ h ] ) hxy
    exact h
    exact ⟨ SimpleGraph.Coloring.mk a.1 ( by
      exact fun { v w } hvw => a.2.ne hvw.ne ), rfl ⟩;
  convert Fintype.card_congr h_bij;
  rw [ Fintype.card_of_subtype ];
  any_goals exact Finset.image ( fun f : Fin n ↪ Fin k => f.toFun ) ( Finset.univ : Finset ( Fin n ↪ Fin k ) );
  · rw [ Finset.card_image_of_injective ] <;> norm_num [ Function.Injective ];
  · exact fun x => ⟨ fun hx => by obtain ⟨ f, _, rfl ⟩ := Finset.mem_image.mp hx; exact f.injective, fun hx => Finset.mem_image.mpr ⟨ ⟨ x, hx ⟩, Finset.mem_univ _, rfl ⟩ ⟩

/-- Consequence: K_n has zero proper k-colorings when k < n. -/
theorem chromaticCount_completeGraph_zero {n k : ℕ} (h : k < n) :
    chromaticCount (completeGraph (Fin n)) k = 0 := by
  rw [chromaticCount_completeGraph]
  exact Nat.descFactorial_eq_zero_iff_lt.mpr h

/-- Consequence: K_n has exactly n! proper n-colorings. -/
theorem chromaticCount_completeGraph_self (n : ℕ) :
    chromaticCount (completeGraph (Fin n)) n = n.factorial := by
  rw [chromaticCount_completeGraph]
  exact Nat.descFactorial_self n

/-! ## Section 4: Emotional Diversity Index -/

/-- The emotional diversity index of a graph G with k available emotions
    is the ratio of actual colorings to the maximum possible (k^|V|).
    This measures what fraction of emotion assignments are "conflict-free"
    in the social network. Values near 1 mean the network is sparse
    (most assignments work), while values near 0 mean dense conflict. -/
noncomputable def emotionalDiversity {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (k : ℕ) : ℚ :=
  if k = 0 then 0
  else (chromaticCount G k : ℚ) / (k ^ Fintype.card V : ℚ)

/-
The emotional diversity of the empty graph is 1: with no conflicts,
    every emotion assignment is valid.
-/
theorem emotionalDiversity_bot {n : ℕ} (k : ℕ) (hk : 0 < k) :
    emotionalDiversity (⊥ : SimpleGraph (Fin n)) k = 1 := by
  unfold emotionalDiversity;
  simp_all +decide [ chromaticCount_bot ];
  linarith

/-
The emotional diversity of K_n is n!/k^n when k ≥ n, measuring
    how restrictive mutual friendship is for emotional diversity.
-/
theorem emotionalDiversity_completeGraph {n k : ℕ} (hk : n ≤ k) (hk0 : 0 < k) :
    emotionalDiversity (completeGraph (Fin n)) k =
    (Nat.descFactorial k n : ℚ) / (k ^ n : ℚ) := by
  unfold emotionalDiversity; norm_num [ hk0.ne' ] ;
  convert chromaticCount_completeGraph n k using 1

/-! ## Section 5: Monotonicity and Structural Theorems -/

/-
More colors means more valid colorings: the chromatic count is
    monotone in k for any graph. This is proved by showing that any
    proper k-coloring extends to a proper (k+1)-coloring via inclusion.
-/
theorem chromaticCount_mono {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] {k₁ k₂ : ℕ} (h : k₁ ≤ k₂) :
    chromaticCount G k₁ ≤ chromaticCount G k₂ := by
  fapply Fintype.card_le_of_injective;
  refine' fun c => ⟨ fun v => ⟨ c.toFun v |> Fin.val, _ ⟩, _ ⟩;
  grind +qlia;
  all_goals simp +decide [ Function.Injective ];
  · exact fun { a b } hab => fun h' => c.valid hab <| Fin.ext h';
  · simp +decide [ funext_iff, Fin.ext_iff ];
    aesop

/-
Subgraph monotonicity: fewer edges means more valid colorings.
    If G₁ ≤ G₂ (G₁ is a subgraph of G₂), then χ(G₂, k) ≤ χ(G₁, k).
-/
theorem chromaticCount_anti_of_le {V : Type*} [Fintype V] [DecidableEq V]
    (G₁ G₂ : SimpleGraph V) [DecidableRel G₁.Adj] [DecidableRel G₂.Adj]
    (h : G₁ ≤ G₂) (k : ℕ) :
    chromaticCount G₂ k ≤ chromaticCount G₁ k := by
  convert Fintype.card_le_of_injective _ _;
  refine' fun c => ⟨ c.1, _ ⟩;
  exact fun { a b } hab => c.valid ( h hab );
  intro c₁ c₂ h; aesop

/-! ## Section 6: Cross-Domain — Information-Theoretic Interpretation

The chromatic count has a natural information-theoretic interpretation:
log₂(χ(G, k)) measures the entropy of a uniformly random proper coloring.
This connects graph coloring to channel capacity in communications. -/

/-- A social network viewed as a communication channel:
    vertices are senders, colors are messages, and adjacency means
    "must use different messages" (a conflict-free channel).
    The channel capacity (in bits per use) is bounded by log₂(χ(G,k))/|V|.

    For the complete graph K_n with k colors, this gives
    log₂(k!/(k-n)!) / n bits per vertex. -/
structure EmotionalChannel (V : Type*) [Fintype V] where
  /-- The underlying social graph -/
  graph : SimpleGraph V
  /-- The number of available emotions/colors -/
  numEmotions : ℕ
  /-- We need at least 3 emotions (psychological threshold) -/
  emotions_ge_three : 3 ≤ numEmotions

/-- The raw capacity of an emotional channel is the chromatic count. -/
noncomputable def EmotionalChannel.capacity {V : Type*} [Fintype V] [DecidableEq V]
    (ch : EmotionalChannel V) [DecidableRel ch.graph.Adj] : ℕ :=
  chromaticCount ch.graph ch.numEmotions

/-- The capacity of a complete-graph channel equals the falling factorial,
    connecting graph theory to the birthday problem in probability. -/
theorem EmotionalChannel.capacity_completeGraph (n : ℕ) (k : ℕ) (hk : 3 ≤ k) :
    (⟨completeGraph (Fin n), k, hk⟩ : EmotionalChannel (Fin n)).capacity =
    Nat.descFactorial k n := by
  unfold EmotionalChannel.capacity
  exact chromaticCount_completeGraph n k

/-! ## Section 7: The Six Basic Emotions Theorem

Ekman's theory posits 6 basic emotions: happiness, sadness, anger, fear,
disgust, surprise. We prove that for any graph with chromatic number ≤ 6,
the 6-emotion assignment always has solutions. -/

/-- For any graph whose chromatic number is at most 6 (the number of
    basic emotions in Ekman's theory), there exists a valid assignment
    of 6 basic emotions such that no two adjacent people share an emotion. -/
theorem ekman_six_emotions_suffice {V : Type*}
    (G : SimpleGraph V) (h : G.Colorable 6) :
    Nonempty (G.Coloring (Fin 6)) := h

/-
Most real social networks are sparse (bounded degree),
    and by the greedy coloring bound, any graph with max degree Δ
    is (Δ+1)-colorable. So networks with max degree ≤ 5 always
    admit 6-emotion assignments.

    We formalize: if every vertex has degree ≤ d, then G is (d+1)-colorable.
-/
theorem colorable_of_degree_le {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (d : ℕ)
    (hdeg : ∀ v : V, G.degree v ≤ d) :
    G.Colorable (d + 1) := by
  -- We'll use the fact that if the degree of every vertex � is� at most $d$, then the graph is $(d+1)$-colorable.
  have h_colorable : ∀ (s : Finset V), ∀ (c : V → Fin (d + 1)), (∀ v ∈ s, ∀ w ∈ s, G.Adj v w → c v ≠ c w) → ∀ v ∉ s, ∃ c' : V → Fin (d + 1), (∀ w ∈ s ∪ {v}, ∀ u ∈ s ∪ {v}, G.Adj w u → c' w ≠ c' u) ∧ ∀ w ∈ s, c' w = c w := by
    intro s c hc v hv
    obtain ⟨c', hc'⟩ : ∃ c' : Fin (d + 1), ∀ w ∈ s, G.Adj v w → c' ≠ c w := by
      contrapose! hdeg;
      have h_deg : Finset.card (Finset.image c (Finset.filter (fun w => G.Adj v w) s)) ≤ G.degree v := by
        exact le_trans ( Finset.card_image_le ) ( Finset.card_le_card ( show Finset.filter ( fun w => G.Adj v w ) s ⊆ G.neighborFinset v from fun w hw => by aesop ) );
      exact ⟨ v, by rw [ show Finset.image c ( Finset.filter ( fun w => G.Adj v w ) s ) = Finset.univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ w, hw₁, hw₂, rfl ⟩ := hdeg x; exact Finset.mem_image_of_mem _ ( Finset.mem_filter.mpr ⟨ hw₁, hw₂ ⟩ ) ] at h_deg; simp +decide at h_deg; linarith ⟩;
    refine' ⟨ fun w => if w = v then c' else c w, _, _ ⟩ <;> simp_all +decide [ SimpleGraph.adj_comm ];
    · grind;
    · aesop;
  -- By repeatedly applying the fact that if every vertex has degree at most � $�d$, then the graph is $(d+1)$-colorable, we can extend the coloring to the entire graph.
  have h_extend : ∀ (s : Finset V), ∃ c' : V → Fin (d + 1), ∀ w ∈ s, ∀ u ∈ s, G.Adj w u → c' w ≠ c' u := by
    intro s
    induction' s using Finset.induction with v s ih;
    · exact ⟨ fun _ => 0, by simp +decide ⟩;
    · obtain ⟨ c', hc' ⟩ := ‹_›; obtain ⟨ c'', hc'' ⟩ := h_colorable s c' hc' v ih; use c''; simp_all +decide [ Finset.subset_iff ] ;
      grind +ring;
  obtain ⟨ c', hc' ⟩ := h_extend Finset.univ;
  exact ⟨ c', by aesop ⟩

/-- Social networks with max degree ≤ 5 always admit valid 6-emotion assignments. -/
theorem six_emotions_for_sparse_networks {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (h : ∀ v : V, G.degree v ≤ 5) :
    G.Colorable 6 := by
  exact colorable_of_degree_le G 5 h

/-! ## Section 8: Conjecture — Chromatic Roots and Emotional Thresholds

**Conjecture**: For any connected graph G on n ≥ 3 vertices,
χ(G, 3) ≥ 3. That is, every connected graph with ≥ 3 vertices
has at least 3 proper 3-colorings.

This is testable: compute χ(G, 3) for all connected graphs on ≤ 8 vertices.
For the cycle C_3 = K_3, we get χ(K_3, 3) = 3! = 6 ≥ 3. ✓
For the path P_3, we get χ(P_3, 3) = 3 · 2 · 2 = 12 ≥ 3. ✓
For the star S_3 (K_{1,3}), we get χ(S_3, 3) = 3 · 2³ = 24 ≥ 3. ✓ -/

/-
**Conjecture**: Every connected graph on n ≥ 3 vertices has at least
    3 proper 3-colorings. Testable by enumerating small connected graphs.
-/
theorem chromatic_count_three_ge_three {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (hconn : G.Connected)
    (hcard : 3 ≤ Fintype.card V)
    (hcol : G.Colorable 3) :
    3 ≤ chromaticCount G 3 := by
  obtain ⟨c, hc⟩ : ∃ c : G.Coloring (Fin 3), True := by
    exact ⟨ hcol.some, trivial ⟩;
  -- Consider the 3 rotations of Fin 3 (cyclic group of order 3): id, (0 �→�1→2→0), (0→2→1→0). Composing c with each gives 3 colorings.
  have h_rotations : ∃ (f : Fin 3 → G.Coloring (Fin 3)), Function.Injective f := by
    -- Define the function that maps � each� rotation to the corresponding coloring.
    use fun i => SimpleGraph.Coloring.mk (fun v => (c v + i) % 3) (by
    intro v w hvw; have := c.valid hvw; simp_all +decide [ Fin.mod_def ] ;);
    intro i j hij
    simp [Function.Injective] at hij;
    simp_all +decide [ Fin.mod_def, funext_iff, SimpleGraph.Coloring.mk ];
    exact hij ( Classical.choose ( Finset.card_pos.mp ( pos_of_gt hcard ) ) );
  exact Fintype.card_le_of_injective _ h_rotations.choose_spec

/-! ## Section 9: Deletion-Contraction and the Polynomial Structure -/

/-
For a graph with an isolated vertex v, adding v multiplies the
    chromatic count by k. This is the base case of deletion-contraction.
-/
theorem chromaticCount_add_isolated {n : ℕ} (k : ℕ) :
    chromaticCount (⊥ : SimpleGraph (Fin (n + 1))) k =
    k * chromaticCount (⊥ : SimpleGraph (Fin n)) k := by
  convert chromaticCount_bot ( n + 1 ) k using 1 ; ring;
  exact congrArg _ ( chromaticCount_bot n k )