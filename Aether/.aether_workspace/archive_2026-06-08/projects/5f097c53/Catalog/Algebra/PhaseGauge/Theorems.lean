/-
  # Compositional Phase Gauge Systems: Definitions and Theorems

  This module defines and proves the main theorems establishing a compositional theory
  of discrete lattice gauge systems with phase observables.

  ## Main Results

  1. **Product Phase Factorization** (`product_system_phase_eq`):
     The plaquette phase of a product gauge system equals the product of
     component plaquette phases.

  2. **Gauge Invariance of Total Phase** (`totalPhase_gauge_invariant`):
     The total phase (product over all plaquettes) is invariant under
     gauge transformations.

  3. **Partition Function Factorization** (`partitionFunction_prod`):
     The partition function of a product system equals the product of
     partition functions of the components.

  4. **Triangle-Free Plaquette Obstruction** (`triangle_free_no_triangular_plaquettes`):
     Triangle-free interaction graphs cannot support triangular plaquettes,
     connecting extremal graph theory to gauge lattice structure.
-/
import Mathlib

open Finset BigOperators

/-! ## Core Structures -/

/-- A `PhaseGaugeSystem` models a discrete lattice gauge theory with phase observables.
    The key axiom is gauge invariance of plaquette phase observables. -/
structure PhaseGaugeSystem' (G Φ V E P : Type*) [Group G] [CommMonoid Φ] where
  /-- Plaquette phase observable -/
  plaquettePhase : (E → G) → P → Φ
  /-- Vertex gauge transformation action -/
  gaugeAction : (V → G) → (E → G) → (E → G)
  /-- Gauge invariance axiom -/
  gauge_invariant :
    ∀ (γ : V → G) (A : E → G) (p : P),
      plaquettePhase (gaugeAction γ A) p = plaquettePhase A p

/-- A finite gauge system with holonomy, phase map, and gauge action.
    R is a commutative semiring serving as the phase value ring. -/
structure FinGaugeSystem (G R V E P : Type*)
    [Fintype G] [DecidableEq G] [Group G]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P] where
  /-- Holonomy: product of edge labels around a plaquette -/
  holonomy : (E → G) → P → G
  /-- Phase map: converts holonomy to a ring element (Boltzmann weight) -/
  phase : G → R
  /-- Vertex gauge transformation action -/
  gaugeAction : (V → G) → (E → G) → (E → G)
  /-- Holonomy is gauge-invariant -/
  holonomy_gauge_invariant :
    ∀ (γ : V → G) (A : E → G) (p : P),
      holonomy (gaugeAction γ A) p = holonomy A p

namespace FinGaugeSystem

variable {G R V E P : Type*}
  [Fintype G] [DecidableEq G] [Group G]
  [CommSemiring R]
  [Fintype V] [DecidableEq V]
  [Fintype E] [DecidableEq E]
  [Fintype P] [DecidableEq P]

/-- The plaquette phase observable: composition of holonomy and phase map. -/
def plaquettePhase (S : FinGaugeSystem G R V E P) (A : E → G) (p : P) : R :=
  S.phase (S.holonomy A p)

/-- Total phase weight: product of all plaquette phases for a configuration.
    This is the Boltzmann weight of the configuration. -/
noncomputable def totalWeight (S : FinGaugeSystem G R V E P) (A : E → G) : R :=
  ∏ p : P, S.plaquettePhase A p

end FinGaugeSystem

/-- Product of two finite gauge systems on the same lattice.
    The gauge group is `G₁ × G₂` and phases combine multiplicatively. -/
def prodGaugeSystem
    {G₁ G₂ R V E P : Type*}
    [Fintype G₁] [DecidableEq G₁] [Group G₁]
    [Fintype G₂] [DecidableEq G₂] [Group G₂]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S₁ : FinGaugeSystem G₁ R V E P)
    (S₂ : FinGaugeSystem G₂ R V E P) :
    FinGaugeSystem (G₁ × G₂) R V E P where
  holonomy A p := (S₁.holonomy (fun e => (A e).1) p, S₂.holonomy (fun e => (A e).2) p)
  phase g := S₁.phase g.1 * S₂.phase g.2
  gaugeAction γ A e := (S₁.gaugeAction (fun v => (γ v).1) (fun e => (A e).1) e,
                         S₂.gaugeAction (fun v => (γ v).2) (fun e => (A e).2) e)
  holonomy_gauge_invariant γ A p := by
    simp only [Prod.mk.injEq]
    exact ⟨S₁.holonomy_gauge_invariant (fun v => (γ v).1) (fun e => (A e).1) p,
           S₂.holonomy_gauge_invariant (fun v => (γ v).2) (fun e => (A e).2) p⟩

/-- The phase partition function: Z = ∑_A ∏_p phase(hol(A, p)).
    This is the statistical mechanical partition function summing
    Boltzmann weights over all gauge configurations. -/
noncomputable def partitionFunction
    {G R V E P : Type*}
    [Fintype G] [DecidableEq G] [Group G]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S : FinGaugeSystem G R V E P) : R :=
  ∑ A : (E → G), S.totalWeight A

/-- Equivalence between functions into a product and pairs of functions. -/
def funProdEquiv' (E G₁ G₂ : Type*) : (E → G₁ × G₂) ≃ (E → G₁) × (E → G₂) where
  toFun f := (fun e => (f e).1, fun e => (f e).2)
  invFun p := fun e => (p.1 e, p.2 e)
  left_inv f := by ext e <;> simp
  right_inv p := by ext <;> simp

/-! ## Theorem 1: Product Phase Factorization -/

/-- **Product Phase Factorization**: The plaquette phase of the product system
    equals the product of the component plaquette phases. -/
theorem product_system_phase_eq
    {G₁ G₂ R V E P : Type*}
    [Fintype G₁] [DecidableEq G₁] [Group G₁]
    [Fintype G₂] [DecidableEq G₂] [Group G₂]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S₁ : FinGaugeSystem G₁ R V E P)
    (S₂ : FinGaugeSystem G₂ R V E P)
    (A₁ : E → G₁) (A₂ : E → G₂) (p : P) :
    (prodGaugeSystem S₁ S₂).plaquettePhase (fun e => (A₁ e, A₂ e)) p
      = S₁.plaquettePhase A₁ p * S₂.plaquettePhase A₂ p := by
  simp [prodGaugeSystem, FinGaugeSystem.plaquettePhase]

/-
**Total Weight Factorization**: The total weight of a product configuration
    factors as a product of component weights.
-/
theorem totalWeight_prod
    {G₁ G₂ R V E P : Type*}
    [Fintype G₁] [DecidableEq G₁] [Group G₁]
    [Fintype G₂] [DecidableEq G₂] [Group G₂]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S₁ : FinGaugeSystem G₁ R V E P)
    (S₂ : FinGaugeSystem G₂ R V E P)
    (A₁ : E → G₁) (A₂ : E → G₂) :
    (prodGaugeSystem S₁ S₂).totalWeight (fun e => (A₁ e, A₂ e))
      = S₁.totalWeight A₁ * S₂.totalWeight A₂ := by
  convert Finset.prod_mul_distrib using 1

/-! ## Theorem 2: Gauge Invariance of Total Phase -/

/-- **Total Phase Gauge Invariance**: The product of plaquette phases over
    all plaquettes is invariant under vertex gauge transformations. -/
theorem totalPhase_gauge_invariant'
    {G Φ V E P : Type*}
    [Fintype P] [Group G] [CommMonoid Φ]
    (S : PhaseGaugeSystem' G Φ V E P)
    (γ : V → G) (A : E → G) :
    (∏ p : P, S.plaquettePhase (S.gaugeAction γ A) p)
      = ∏ p : P, S.plaquettePhase A p := by
  exact Finset.prod_congr rfl fun p _ => S.gauge_invariant γ A p

/-
**Total Weight Gauge Invariance (finite system version)**:
-/
theorem totalWeight_gauge_invariant
    {G R V E P : Type*}
    [Fintype G] [DecidableEq G] [Group G]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S : FinGaugeSystem G R V E P)
    (γ : V → G) (A : E → G) :
    S.totalWeight (S.gaugeAction γ A) = S.totalWeight A := by
  convert Finset.prod_congr rfl fun p _ => ?_;
  exact congr_arg _ ( S.holonomy_gauge_invariant γ A p )

/-! ## Theorem 3: Partition Function Factorization -/

/-
Helper: sum-product factorization for function types into a product.
    ∑_{(A₁,A₂)} f(A₁)·g(A₂) = (∑_{A₁} f(A₁)) · (∑_{A₂} g(A₂))
-/
lemma sum_prod_factorization
    {E G₁ G₂ : Type*} {R : Type*}
    [Fintype E] [Fintype G₁] [Fintype G₂]
    [DecidableEq E] [DecidableEq G₁] [DecidableEq G₂]
    [CommSemiring R]
    (f : (E → G₁) → R) (g : (E → G₂) → R) :
    ∑ A : (E → G₁ × G₂), f (fun e => (A e).1) * g (fun e => (A e).2)
      = (∑ A₁ : (E → G₁), f A₁) * (∑ A₂ : (E → G₂), g A₂) := by
  rw [show (∑ A : (E → G₁ × G₂), f (fun e => (A e).1) * g (fun e => (A e).2)) =
    (∑ p : (E → G₁) × (E → G₂), f p.1 * g p.2) from
    Fintype.sum_equiv (funProdEquiv' E G₁ G₂) _ _ (fun A => by simp [funProdEquiv'])]
  simp [Fintype.sum_prod_type, Finset.mul_sum, Finset.sum_mul]
  rw [Finset.sum_comm]

/-
**Partition Function Factorization**: Z(S₁ × S₂) = Z(S₁) · Z(S₂).
    The partition function of the product system equals the product of the
    component partition functions.
-/
theorem partitionFunction_prod
    {G₁ G₂ R V E P : Type*}
    [Fintype G₁] [DecidableEq G₁] [Group G₁]
    [Fintype G₂] [DecidableEq G₂] [Group G₂]
    [CommSemiring R]
    [Fintype V] [DecidableEq V]
    [Fintype E] [DecidableEq E]
    [Fintype P] [DecidableEq P]
    (S₁ : FinGaugeSystem G₁ R V E P)
    (S₂ : FinGaugeSystem G₂ R V E P) :
    partitionFunction (prodGaugeSystem S₁ S₂)
      = partitionFunction S₁ * partitionFunction S₂ := by
  convert sum_prod_factorization ( fun A₁ => S₁.totalWeight A₁ ) ( fun A₂ => S₂.totalWeight A₂ ) using 1;
  exact Finset.sum_congr rfl fun _ _ => totalWeight_prod S₁ S₂ _ _

/-! ## Theorem 4: Triangle-Free Plaquette Obstruction -/

/-- A plaquette specification: associates each plaquette with three boundary vertices. -/
structure GraphPlaquetteSpec' (n : ℕ) (P : Type*) where
  vertices : P → Fin n × Fin n × Fin n
  distinct : ∀ p, let ⟨a, b, c⟩ := vertices p; a ≠ b ∧ b ≠ c ∧ a ≠ c

/-- A plaquette is triangular if its three boundary vertices are pairwise adjacent. -/
def isTriangularPlaquette' {n : ℕ} {P : Type*}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (spec : GraphPlaquetteSpec' n P) (p : P) : Prop :=
  let ⟨a, b, c⟩ := spec.vertices p
  G.Adj a b ∧ G.Adj b c ∧ G.Adj a c

/-
**Triangle-Free Plaquette Obstruction**: Triangle-free interaction graphs
    cannot support triangular plaquettes.
-/
theorem triangle_free_no_triangular_plaquettes'
    {n : ℕ} {P : Type*}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3)
    (spec : GraphPlaquetteSpec' n P) :
    ∀ p : P, ¬ isTriangularPlaquette' G spec p := by
  by_contra! h_contra;
  obtain ⟨ p, hp ⟩ := h_contra; specialize hG { spec.vertices p |>.1, spec.vertices p |>.2.1, spec.vertices p |>.2.2 } ; simp_all +decide [ SimpleGraph.isClique_iff, SimpleGraph.isNClique_iff ] ;
  simp_all +decide [ isTriangularPlaquette' ];
  grind +suggestions

/-
**Mantel Bound**: Triangle-free graphs have at most n²/4 edges.
-/
theorem mantel_bound_limits_plaquettes'
    {n : ℕ}
    (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]
    (hG : G.CliqueFree 3) :
    4 * G.edgeFinset.card ≤ n ^ 2 := by
  -- By the properties of the graph, we know that the sum of the degrees of all vertices is at most $n^2 / 2$.
  have h_sum_degrees : ∑ v : Fin n, G.degree v ≤ n^2 / 2 := by
    -- Since G is triangle-free, for any edge (u, v), the degree of u plus the degree of v is at most n.
    have h_deg_sum : ∀ u v : Fin n, G.Adj u v → G.degree u + G.degree v ≤ n := by
      intro u v huv; have := hG ( { u, v } ∪ { u } ) ; simp_all +decide [ Set.Pairwise ] ;
      -- Since $G$ is triangle-free, the neighborhoods of $u$ and $v$ are disjoint.
      have h_disjoint : Disjoint (G.neighborFinset u) (G.neighborFinset v) := by
        simp_all +decide [ SimpleGraph.isNClique_iff, Finset.disjoint_left ];
        intro w huw hvw; specialize hG { u, v, w } ; simp_all +decide [ SimpleGraph.isNClique_iff ] ;
        rw [ Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] at hG <;> aesop;
      have := Finset.card_le_univ ( G.neighborFinset u ∪ G.neighborFinset v ) ; simp_all +decide [ Finset.disjoint_iff_inter_eq_empty ] ;
    -- By summing over all edges, we get $\sum_{(u,v) \in E} (d(u) + d(v)) \leq n|E|$.
    have h_sum_deg : ∑ u : Fin n, ∑ v ∈ G.neighborFinset u, (G.degree u + G.degree v) ≤ n * (∑ u : Fin n, G.degree u) := by
      rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun u hu => le_trans ( Finset.sum_le_sum fun v hv => h_deg_sum u v <| by aesop ) <| by simp +decide [ mul_comm ] ;
    -- By the Handshaking Lemma, we know that $\sum_{u \in V} \sum_{v \in N(u)} (d(u) + d(v)) = 2 \sum_{u \in V} d(u)^2$.
    have h_handshake : ∑ u : Fin n, ∑ v ∈ G.neighborFinset u, (G.degree u + G.degree v) = 2 * ∑ u : Fin n, G.degree u ^ 2 := by
      simp +decide [ Finset.sum_add_distrib, pow_two, mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
      simp +decide [ two_mul, Finset.sum_add_distrib, SimpleGraph.degree, SimpleGraph.neighborFinset ];
      simp +decide [ SimpleGraph.neighborSet, Finset.sum_filter ];
      rw [ Finset.sum_comm ];
      simp +decide [ SimpleGraph.adj_comm, Finset.sum_ite ];
    -- By Cauchy-Schwarz inequality, we know that $\sum_{u \in V} d(u)^2 \geq \frac{(\sum_{u \in V} d(u))^2}{n}$.
    have h_cauchy_schwarz : ∑ u : Fin n, G.degree u ^ 2 ≥ (∑ u : Fin n, G.degree u) ^ 2 / n := by
      have h_cauchy_schwarz : ∀ (x : Fin n → ℝ), (∑ i, x i) ^ 2 ≤ n * ∑ i, x i ^ 2 := by
        intro x; have := ( Finset.univ.sum_le_sum fun i _ => mul_self_nonneg ( x i - ( ∑ i : Fin n, x i ) / n ) ) ; by_cases hn : n = 0 <;> simp_all +decide [ sub_sq, mul_div_cancel₀ ] ;
        · aesop;
        · simp_all +decide [ add_mul, sub_mul, mul_sub ];
          case _ => simp_all +decide only [← sum_mul, ← sq, ← Finset.mul_sum _ _ _] ; nlinarith [ mul_div_cancel₀ ( ( ∑ i, x i ) : ℝ ) ( Nat.cast_ne_zero.mpr hn ) ] ;
      exact Nat.div_le_of_le_mul <| by rw [ ← @Nat.cast_le ℝ ] ; push_cast; simpa [ mul_comm ] using h_cauchy_schwarz fun u => G.degree u;
    rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.mul_div_assoc ];
    rw [ Nat.div_le_iff_le_mul_add_pred ] at h_cauchy_schwarz <;> norm_num at * ; nlinarith [ Nat.div_add_mod ( ( n + 1 + 1 ) ^ 2 ) 2, Nat.mod_lt ( ( n + 1 + 1 ) ^ 2 ) two_pos ] ;
  linarith [ Nat.div_mul_le_self ( n ^ 2 ) 2, SimpleGraph.sum_degrees_eq_twice_card_edges G ]

/-! ## Theorem 5: Gauge-Invariant Observable Structure -/

/-- A gauge-invariant observable. -/
structure GaugeInvariantObservable' (G Φ V E : Type*) [Group G] [CommMonoid Φ] where
  obs : (E → G) → Φ
  act : (V → G) → (E → G) → (E → G)
  invariant : ∀ (γ : V → G) (A : E → G), obs (act γ A) = obs A

/-- The total phase defines a gauge-invariant observable. -/
noncomputable def totalPhaseObservable'
    {G Φ V E P : Type*}
    [Fintype P] [Group G] [CommMonoid Φ]
    (S : PhaseGaugeSystem' G Φ V E P) :
    GaugeInvariantObservable' G Φ V E where
  obs A := ∏ p : P, S.plaquettePhase A p
  act := S.gaugeAction
  invariant γ A := totalPhase_gauge_invariant' S γ A

/-! ## Profinite Approximation -/

/-- A profinite phase approximation: an inverse system of finite gauge groups. -/
structure ProfinitePhaseApproximation' (ι : Type*) [Preorder ι] where
  G : ι → Type*
  instGroup : ∀ i, Group (G i)
  proj : ∀ {i j : ι}, i ≤ j → G j →* G i
  compat : ∀ {i j k : ι} (hij : i ≤ j) (hjk : j ≤ k),
    (proj hij).comp (proj hjk) = proj (le_trans hij hjk)

/-- **Profinite Level Compatibility**: Phase observables at different levels
    are compatible through the inverse system projections. -/
theorem profinite_phase_compatibility'
    {ι : Type*} [Preorder ι]
    (sys : ProfinitePhaseApproximation' ι)
    {Φ : Type*} [CommMonoid Φ]
    (χ : ∀ i, letI := sys.instGroup i; (sys.G i) →* Φ)
    (hcompat : ∀ {i j : ι} (hij : i ≤ j) (g : sys.G j),
      χ i (sys.proj hij g) = χ j g)
    {i j : ι} (hij : i ≤ j) (g : sys.G j) :
    χ i (sys.proj hij g) = χ j g :=
  hcompat hij g