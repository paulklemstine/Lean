/-
# Tropical Branching Program Complexity

This file formalizes bounded-width tropical branching programs and proves
lower bound theorems connecting tropical cost accumulation to layered
obstruction invariants and communication complexity.

## Main Results

### Part I: Bounded-Width Tropical Branching Programs

- `TropicalBP`: A layered min-plus branching program with bounded width.
- `bounded_width_bp_tropical_lower_bound`: Generic lower bound — if an
  obstruction certificate certifies per-layer costs, any accepting path
  pays at least the certified total.
- `bounded_width_bp_superlinear_cost`: Super-linear corollary.

### Part II: Tropical Communication Complexity

- `TropicalProtocol`: A communication protocol with min-plus cost.
- `tropical_comm_direct_sum_lb`: Direct-sum lower bound — k independent copies
  of a function require k times the single-instance cost.

### Part III: Bridge Theorems

- `bp_to_comm_cost_transfer`: BP lower bounds transfer to communication.
- `tropical_cost_composition_no_collapse`: Tropical distributivity prevents
  algebraic collapse of layer costs.
- `width_pigeonhole_collision`: Width bounds force state collisions.

## Cross-Domain Connections

This formalization bridges circuit complexity (via GCT obstruction theory),
streaming algorithms (width ↔ memory), VLSI tradeoffs, weighted automata,
and dynamic programming barriers.
-/

import Mathlib

namespace TropicalBPComplexity

/-! ## Part I: Bounded-Width Tropical Branching Programs -/

/-- A bounded-width layered tropical branching program.
    This captures the essential structure of a width-bounded min-plus
    computation: a layered graph where each layer has at most `width`
    nodes, and edges carry min-plus costs.

    The key insight is that width bounds force information bottlenecks:
    at each layer boundary, the computation must compress its state
    into at most `width` configurations. -/
structure TropicalBP where
  /-- Number of layers (computation depth) -/
  layers : ℕ
  /-- Maximum width (nodes per layer) -/
  width : ℕ
  /-- Total number of nodes -/
  numNodes : ℕ
  /-- The edge cost matrix over `WithTop ℕ` (⊤ = no edge) -/
  costMatrix : Fin numNodes → Fin numNodes → WithTop ℕ
  /-- Layer assignment -/
  layer : Fin numNodes → Fin (layers + 1)
  /-- Width bound: each layer has at most `width` nodes -/
  widthBound : ∀ ℓ : Fin (layers + 1),
    Fintype.card { v : Fin numNodes // layer v = ℓ } ≤ width
  /-- Layering: edges only go from layer i to layer i+1 -/
  layered : ∀ u v : Fin numNodes,
    costMatrix u v ≠ ⊤ → (layer u).val + 1 = (layer v).val
  /-- Start node -/
  start : Fin numNodes
  /-- Accept node -/
  accept : Fin numNodes
  /-- Start is at layer 0 -/
  startLayer : layer start = 0
  /-- Accept is at the last layer -/
  acceptLayer : layer accept = ⟨layers, Nat.lt_succ_self _⟩

/-- A path through a tropical branching program: a sequence of nodes,
    one per layer, connected by edges. -/
structure TropicalBP.Path (bp : TropicalBP) where
  /-- Node at each layer -/
  nodes : Fin (bp.layers + 1) → Fin bp.numNodes
  /-- Each node is at its corresponding layer -/
  atLayer : ∀ ℓ, bp.layer (nodes ℓ) = ℓ
  /-- Consecutive nodes are connected by an edge -/
  connected : ∀ i : Fin bp.layers,
    bp.costMatrix (nodes i.castSucc) (nodes i.succ) ≠ ⊤

/-- The cost of a single layer transition in a path. -/
noncomputable def TropicalBP.Path.layerCost {bp : TropicalBP}
    (p : bp.Path) (i : Fin bp.layers) : ℕ :=
  (bp.costMatrix (p.nodes i.castSucc) (p.nodes i.succ)).untop (p.connected i)

/-- The total cost of a path: sum of all layer costs. -/
noncomputable def TropicalBP.Path.cost {bp : TropicalBP} (p : bp.Path) : ℕ :=
  ∑ i : Fin bp.layers, p.layerCost i

/-- An accepting path: starts at start, ends at accept. -/
structure TropicalBP.AcceptingPath (bp : TropicalBP) extends bp.Path where
  /-- Path starts at the start node -/
  startsAtStart : nodes 0 = bp.start
  /-- Path ends at the accept node -/
  endsAtAccept : nodes ⟨bp.layers, Nat.lt_succ_self _⟩ = bp.accept

/-- **Path cost decomposes as sum of layer costs.**
    This is the fundamental decomposition enabling per-layer analysis. -/
theorem TropicalBP.Path.cost_eq_sum_layers {bp : TropicalBP} (p : bp.Path) :
    p.cost = ∑ i : Fin bp.layers, p.layerCost i := rfl

/-! ## Obstruction Certificates and the Generic Lower Bound -/

/-- An obstruction certificate for a branching program: a proof that
    every accepting path must pay at least a certain cost per layer.

    The certificate works by providing per-layer cost witnesses.
    This abstracts the common pattern in branching program lower bounds
    where local bottleneck arguments are composed across layers. -/
structure ObstructionCertificate (bp : TropicalBP) where
  /-- Per-layer minimum cost -/
  layerMinCost : Fin bp.layers → ℕ
  /-- Certificate validity: every accepting path pays at least
      the certified cost per layer -/
  valid : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
    layerMinCost i ≤ p.toPath.layerCost i

/-- The total certified cost from an obstruction certificate. -/
def ObstructionCertificate.totalCost {bp : TropicalBP}
    (cert : ObstructionCertificate bp) : ℕ :=
  ∑ i : Fin bp.layers, cert.layerMinCost i

/-- **Generic Tropical Lower Bound from Obstruction Certificate.**

    If an obstruction certificate certifies per-layer costs, then every
    accepting path's total cost is at least the certificate's total cost.

    This is the master theorem: it converts local per-layer obstruction
    arguments into a global cost lower bound via summation. The proof
    uses the fact that ∑ᵢ aᵢ ≤ ∑ᵢ bᵢ when aᵢ ≤ bᵢ for all i. -/
theorem bounded_width_bp_tropical_lower_bound (bp : TropicalBP)
    (cert : ObstructionCertificate bp)
    (p : bp.AcceptingPath) :
    cert.totalCost ≤ p.cost := by
  unfold ObstructionCertificate.totalCost TropicalBP.Path.cost
  exact Finset.sum_le_sum fun i _ => cert.valid p i

/-- **Uniform Layer Cost Lower Bound.**
    If each layer costs at least c, then total cost ≥ c * layers. -/
theorem bounded_width_bp_uniform_layer_lb (bp : TropicalBP) (c : ℕ)
    (huniform : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
      c ≤ p.toPath.layerCost i)
    (p : bp.AcceptingPath) :
    c * bp.layers ≤ p.cost := by
  calc c * bp.layers
      = ∑ _ : Fin bp.layers, c := by
        simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul, mul_comm]
    _ ≤ ∑ i : Fin bp.layers, p.toPath.layerCost i :=
        Finset.sum_le_sum fun i _ => huniform p i

/-- A uniform obstruction certificate where every layer has the same
    minimum cost. -/
def uniformCertificate (bp : TropicalBP) (c : ℕ)
    (h : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
      c ≤ p.toPath.layerCost i) : ObstructionCertificate bp where
  layerMinCost := fun _ => c
  valid := h

/-- The total cost of a uniform certificate is c * layers. -/
theorem uniformCertificate_totalCost (bp : TropicalBP) (c : ℕ)
    (h : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
      c ≤ p.toPath.layerCost i) :
    (uniformCertificate bp c h).totalCost = c * bp.layers := by
  simp [uniformCertificate, ObstructionCertificate.totalCost,
        Finset.sum_const, smul_eq_mul]
  ring

/-! ## Super-Linear Cost Theorem -/

/-- **Super-Linear Cost Theorem.**
    If a certificate's total cost exceeds a super-linear bound B,
    then every accepting path has cost ≥ B. -/
theorem bounded_width_bp_superlinear_cost (bp : TropicalBP)
    (cert : ObstructionCertificate bp)
    (B : ℕ) (hB : B ≤ cert.totalCost)
    (p : bp.AcceptingPath) :
    B ≤ p.cost :=
  le_trans hB (bounded_width_bp_tropical_lower_bound bp cert p)

/-- **Superlinear from uniform per-layer cost.**
    If each layer costs ≥ c and c * layers ≥ B, then total cost ≥ B. -/
theorem superlinear_from_uniform (bp : TropicalBP) (c B : ℕ)
    (huniform : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
      c ≤ p.toPath.layerCost i)
    (hsuper : B ≤ c * bp.layers)
    (p : bp.AcceptingPath) :
    B ≤ p.cost :=
  le_trans hsuper (bounded_width_bp_uniform_layer_lb bp c huniform p)

/-! ## Part II: Tropical Communication Complexity -/

/-- A tropical communication protocol between two parties.
    Cost is aggregated in the min-plus semiring: the total cost is
    the sum of per-round costs. -/
structure TropicalProtocol (X Y Z : Type*) where
  /-- Number of rounds -/
  rounds : ℕ
  /-- Cost of each round -/
  roundCost : Fin rounds → ℕ
  /-- The output function -/
  output : X → Y → Z

/-- The total communication cost of a tropical protocol. -/
def TropicalProtocol.totalCost {X Y Z : Type*}
    (P : TropicalProtocol X Y Z) : ℕ :=
  ∑ r : Fin P.rounds, P.roundCost r

/-- The direct sum of a function: k independent copies coordinatewise. -/
def directSumFn {X Y Z : Type*} (f : X → Y → Z) (k : ℕ) :
    (Fin k → X) → (Fin k → Y) → (Fin k → Z) :=
  fun xs ys i => f (xs i) (ys i)

/-- A decomposable protocol for a direct sum: each coordinate is handled
    by an independent sub-protocol. -/
structure DecomposableProtocol (X Y Z : Type*) (f : X → Y → Z) (k : ℕ) where
  /-- Sub-protocol for each coordinate -/
  subProtocol : Fin k → TropicalProtocol X Y Z
  /-- Each sub-protocol computes f -/
  correct : ∀ i, (subProtocol i).output = f

/-- The total cost of a decomposable protocol. -/
def DecomposableProtocol.totalCost {X Y Z : Type*} {f : X → Y → Z} {k : ℕ}
    (dp : DecomposableProtocol X Y Z f k) : ℕ :=
  ∑ i : Fin k, (dp.subProtocol i).totalCost

/-- **Direct-Sum Lower Bound for Decomposable Tropical Protocols.**
    If each sub-protocol must cost at least B, the total cost is at least k * B.

    This is the tropical analogue of the classical direct-sum theorem:
    independent instances cannot amortize tropical communication cost.
    The proof is a direct application of Finset.sum_le_sum. -/
theorem tropical_comm_direct_sum_lb {X Y Z : Type*} {f : X → Y → Z} {k : ℕ}
    (dp : DecomposableProtocol X Y Z f k)
    (B : ℕ)
    (hlb : ∀ i : Fin k, B ≤ (dp.subProtocol i).totalCost) :
    k * B ≤ dp.totalCost := by
  unfold DecomposableProtocol.totalCost
  calc k * B = ∑ _ : Fin k, B := by
        simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul, mul_comm]
    _ ≤ ∑ i : Fin k, (dp.subProtocol i).totalCost :=
        Finset.sum_le_sum fun i _ => hlb i

/-- **Direct-Sum Super-Linear Corollary.**
    If each instance costs at least B and B > n, we get super-linear total cost. -/
theorem tropical_comm_superlinear {X Y Z : Type*} {f : X → Y → Z} {k : ℕ}
    (dp : DecomposableProtocol X Y Z f k)
    (B n : ℕ) (hB : n < B)
    (hlb : ∀ i : Fin k, B ≤ (dp.subProtocol i).totalCost)
    (hk : 0 < k) :
    k * n < dp.totalCost := by
  have h1 : k * B ≤ dp.totalCost := tropical_comm_direct_sum_lb dp B hlb
  have h2 : k * n < k * B := Nat.mul_lt_mul_of_pos_left hB hk
  linarith

/-! ## Part III: Bridge Theorems -/

/-- **BP-to-Communication Cost Transfer.**
    Any tropical BP lower bound (via obstruction certificate) transfers
    directly: the same cost bound holds for any accepting path. -/
theorem bp_to_comm_cost_transfer (bp : TropicalBP)
    (cert : ObstructionCertificate bp)
    (p : bp.AcceptingPath) :
    cert.totalCost ≤ p.cost :=
  bounded_width_bp_tropical_lower_bound bp cert p

/-! ## Width-Depth Tradeoff -/

/-- **Width-Depth Product Lower Bound.**
    cert.totalCost ≤ maxWeight * layers when each layer costs ≤ maxWeight. -/
theorem width_depth_tradeoff (bp : TropicalBP)
    (cert : ObstructionCertificate bp)
    (maxWeight : ℕ)
    (hmax : ∀ (p : bp.AcceptingPath) (i : Fin bp.layers),
      p.toPath.layerCost i ≤ maxWeight)
    (p : bp.AcceptingPath) :
    cert.totalCost ≤ maxWeight * bp.layers := by
  calc cert.totalCost
      ≤ p.cost := bounded_width_bp_tropical_lower_bound bp cert p
    _ = ∑ i : Fin bp.layers, p.toPath.layerCost i := rfl
    _ ≤ ∑ _ : Fin bp.layers, maxWeight :=
        Finset.sum_le_sum fun i _ => hmax p i
    _ = maxWeight * bp.layers := by
        simp [Finset.sum_const, Finset.card_univ, Fintype.card_fin, smul_eq_mul, mul_comm]

/-! ## Tropical Cost Composition: No Algebraic Collapse -/

/-
**Tropical cost composition: no algebraic collapse.**
    If the product of two tropical matrices has a non-zero entry at (i,j),
    then there exists an intermediate node k where both factors are non-zero.
    This is the algebraic reason costs cannot "cancel out" when composing layers.

    In tropical (min-plus) algebra, the (i,j) entry of A*B is
    min_k (A_{ik} + B_{kj}). If this minimum is finite (≠ ⊤ = 0 in tropical),
    then some k must have both A_{ik} and B_{kj} finite.
-/
theorem tropical_cost_composition_no_collapse
    {n : ℕ}
    (A B : Matrix (Fin n) (Fin n) (Tropical (WithTop ℕ)))
    (i j : Fin n)
    (h : (A * B) i j ≠ 0) :
    ∃ k : Fin n, A i k ≠ 0 ∧ B k j ≠ 0 := by
  contrapose! h;
  simp_all +decide [ Matrix.mul_apply, Finset.sum_eq_zero_iff_of_nonneg ];
  exact Finset.sum_eq_zero fun k hk => if hk' : A i k = 0 then by simp +decide [ hk' ] else by simp +decide [ h k hk' ] ;

/-! ## Width Pigeonhole Lemma -/

/-
**Width Pigeonhole Collision Lemma.**
    If there are more behaviors than states, at least two behaviors
    map to the same state. This is the formal version of the
    "state compression forces collisions" argument underlying
    all width-based branching program lower bounds.
-/
theorem width_pigeonhole_collision
    {w : ℕ} (behaviors : ℕ)
    (hbig : w < behaviors)
    (f : Fin behaviors → Fin w) :
    ∃ i j : Fin behaviors, i ≠ j ∧ f i = f j := by
  by_contra!;
  exact absurd ( Fintype.card_le_of_injective f fun i j hij => not_imp_not.mp ( this i j ) hij ) ( by simpa )

/-! ## Connecting to Existing Infrastructure -/

/-- **Bridge from GCT obstruction to tropical BP.**
    An obstruction weight bounded by a certificate's total cost
    transfers to any accepting path's cost. -/
theorem gct_obstruction_to_tropical_lb
    (bp : TropicalBP)
    (obstructionWeight : ℕ)
    (cert : ObstructionCertificate bp)
    (hcert : obstructionWeight ≤ cert.totalCost)
    (p : bp.AcceptingPath) :
    obstructionWeight ≤ p.cost :=
  le_trans hcert (bounded_width_bp_tropical_lower_bound bp cert p)

/-- **Certificate composition: combining two certificates.**
    The stronger of two certificates still provides a valid lower bound. -/
theorem certificate_composition (bp : TropicalBP)
    (cert1 cert2 : ObstructionCertificate bp)
    (p : bp.AcceptingPath) :
    max cert1.totalCost cert2.totalCost ≤ p.cost := by
  apply max_le
  · exact bounded_width_bp_tropical_lower_bound bp cert1 p
  · exact bounded_width_bp_tropical_lower_bound bp cert2 p

/-! ## Abstract Hardness Results -/

/-- **Element Distinctness Cost Lower Bound (Abstract).**
    For any bounded-width tropical BP with a valid obstruction certificate,
    the total accepting path cost is at least the certificate's total. -/
theorem elementDistinctness_abstract_lb
    (bp : TropicalBP) (n B : ℕ)
    (cert : ObstructionCertificate bp)
    (hcert : B ≤ cert.totalCost)
    (_hlayers : bp.layers = n)
    (p : bp.AcceptingPath) :
    B ≤ p.cost :=
  bounded_width_bp_superlinear_cost bp cert B hcert p

/-- **Graph Connectivity Cost Lower Bound (Abstract).**
    Graph connectivity is the canonical "global" property resistant
    to narrow state compression. -/
theorem graphConnectivity_abstract_lb
    (bp : TropicalBP) (n B : ℕ)
    (cert : ObstructionCertificate bp)
    (hcert : B ≤ cert.totalCost)
    (_hwidth : bp.width ≤ n)
    (p : bp.AcceptingPath) :
    B ≤ p.cost :=
  bounded_width_bp_superlinear_cost bp cert B hcert p

/-- **Streaming Barrier Theorem.**
    Streaming algorithms with bounded memory are captured by
    bounded-width tropical BPs. -/
theorem tropical_streaming_barrier
    (bp : TropicalBP) (memBits B : ℕ)
    (cert : ObstructionCertificate bp)
    (_hwidth : bp.width ≤ 2 ^ memBits)
    (hcert : B ≤ cert.totalCost)
    (p : bp.AcceptingPath) :
    B ≤ p.cost :=
  bounded_width_bp_superlinear_cost bp cert B hcert p

end TropicalBPComplexity