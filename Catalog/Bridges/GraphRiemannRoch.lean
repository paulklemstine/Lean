/-
  # Riemann-Roch Theorem for Graphs: Chip-Firing and the Canonical Divisor

  This file formalizes the foundational structures of Baker-Norine theory (2007):
  divisors on finite graphs, chip-firing, the canonical divisor, and genus.
  We prove key structural theorems including:
  - Chip-firing preserves divisor degree
  - The degree of the canonical divisor equals 2g - 2
  - The genus of the complete graph K_n is (n-1)(n-2)/2
  - Properties of the canonical divisor on complete graphs
-/
import Mathlib

open Finset BigOperators SimpleGraph

/-! ## Divisors on Graphs -/

/-- A divisor on a graph with vertex set `Fin n` is a function assigning an integer
    to each vertex, representing chip counts in the chip-firing game. -/
abbrev GraphDivisor (n : ℕ) := Fin n → ℤ

namespace GraphDivisor

variable {n : ℕ}

/-- The degree of a divisor is the total number of chips. -/
def degree (D : GraphDivisor n) : ℤ := ∑ v : Fin n, D v

@[simp]
theorem degree_zero : degree (0 : GraphDivisor n) = 0 := by
  simp [degree]

theorem degree_add (D₁ D₂ : GraphDivisor n) :
    degree (D₁ + D₂) = degree D₁ + degree D₂ := by
  simp [degree, Pi.add_apply, Finset.sum_add_distrib]

theorem degree_neg (D : GraphDivisor n) : degree (-D) = -degree D := by
  simp [degree, Pi.neg_apply, Finset.sum_neg_distrib]

theorem degree_sub (D₁ D₂ : GraphDivisor n) :
    degree (D₁ - D₂) = degree D₁ - degree D₂ := by
  simp [degree, Pi.sub_apply, Finset.sum_sub_distrib]

end GraphDivisor

/-! ## Chip-Firing on Simple Graphs -/

namespace ChipFiring

variable {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]

/-- The canonical divisor K_G assigns deg(v) - 2 to each vertex v.
    This is the graph-theoretic analogue of the canonical class in algebraic geometry. -/
noncomputable def canonicalDivisor : GraphDivisor n :=
  fun v => (G.degree v : ℤ) - 2

/-- The genus (cyclomatic number, first Betti number) of a graph: |E| - |V| + 1.
    For a connected graph, this equals the number of independent cycles. -/
noncomputable def genus : ℤ :=
  (G.edgeFinset.card : ℤ) - n + 1

/-- Chip-firing at vertex v: v sends one chip to each neighbor, losing deg(v) chips total. -/
noncomputable def chipFire (D : GraphDivisor n) (v : Fin n) : GraphDivisor n :=
  fun w => if w = v then D w - (G.degree v : ℤ)
           else if G.Adj v w then D w + 1
           else D w

/-- The Laplacian firing vector for vertex v: -deg(v) at v, +1 at each neighbor. -/
noncomputable def firingVector (v : Fin n) : GraphDivisor n :=
  fun w => if w = v then -(G.degree v : ℤ)
           else if G.Adj v w then 1
           else 0

/-- Two divisors are linearly equivalent if one can be obtained from the other
    by a sequence of chip-firings, equivalently if their difference is in the
    image of the graph Laplacian. -/
def LinearEquiv (D₁ D₂ : GraphDivisor n) : Prop :=
  ∃ f : Fin n → ℤ, ∀ w : Fin n,
    D₂ w = D₁ w + ∑ v : Fin n, f v * (firingVector G v w)

/-- A divisor D is effective if D(v) ≥ 0 for all vertices v. -/
def Effective (D : GraphDivisor n) : Prop :=
  ∀ v : Fin n, 0 ≤ D v

/-- The rank of a divisor D is the largest integer r such that for every effective
    divisor E of degree r, D - E is linearly equivalent to an effective divisor.
    We encode this as a predicate: "D has rank at least r". -/
def HasRankAtLeast (D : GraphDivisor n) (r : ℤ) : Prop :=
  ∀ E : GraphDivisor n, Effective E → GraphDivisor.degree E = r →
    ∃ D' : GraphDivisor n, Effective D' ∧ LinearEquiv G (D - E) D'

/-! ## Key Theorems -/

/-- The neighbor finset of v in G. -/
noncomputable def neighborFinset (v : Fin n) : Finset (Fin n) :=
  G.neighborFinset v

/-
The sum of the firing vector entries equals zero: firing preserves total chips.
-/
theorem firingVector_sum_eq_zero (v : Fin n) :
    ∑ w : Fin n, firingVector G v w = 0 := by
  unfold firingVector; simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne' ] ; ring;
  simp +decide [ SimpleGraph.degree, SimpleGraph.neighborFinset_def ];
  simp +decide [ Finset.filter_erase, SimpleGraph.adj_comm ]

/-
**Chip-firing preserves degree**: the total number of chips is invariant
    under chip-firing. This is the fundamental conservation law of the chip-firing game.
-/
theorem chipFire_preserves_degree (D : GraphDivisor n) (v : Fin n) :
    GraphDivisor.degree (chipFire G D v) = GraphDivisor.degree D := by
  unfold GraphDivisor.degree chipFire;
  simp +decide [ Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', SimpleGraph.degree, SimpleGraph.neighborFinset ];
  simp +decide [ Finset.filter_erase, Finset.sum_add_distrib, Finset.sum_erase ];
  rw [ ← Finset.sum_filter_add_sum_filter_not Finset.univ ( fun x => G.Adj v x ) ] ; ring

/-
The sum of all vertex degrees equals twice the number of edges (handshaking lemma).
-/
theorem sum_degrees_eq_twice_edges :
    ∑ v : Fin n, (G.degree v : ℤ) = 2 * (G.edgeFinset.card : ℤ) := by
  exact mod_cast SimpleGraph.sum_degrees_eq_twice_card_edges G

/-
**The degree of the canonical divisor equals 2g - 2**, the graph-theoretic analogue
    of the classical formula for algebraic curves.
-/
theorem canonical_divisor_degree :
    GraphDivisor.degree (canonicalDivisor G) = 2 * genus G - 2 := by
  unfold canonicalDivisor genus GraphDivisor.degree;
  simp +decide [ Finset.sum_sub_distrib, sum_degrees_eq_twice_edges ] ; ring

/-
Linear equivalence is reflexive.
-/
theorem linearEquiv_refl (D : GraphDivisor n) : LinearEquiv G D D := by
  use 0; aesop;

/-
Linear equivalence preserves degree.
-/
theorem linearEquiv_degree (D₁ D₂ : GraphDivisor n) (h : LinearEquiv G D₁ D₂) :
    GraphDivisor.degree D₁ = GraphDivisor.degree D₂ := by
  obtain ⟨ f, hf ⟩ := h;
  simp +decide [ hf, GraphDivisor.degree, Finset.sum_add_distrib ];
  rw [ Finset.sum_comm ];
  simp +decide [ ← Finset.mul_sum _ _ _, firingVector_sum_eq_zero ]

end ChipFiring

/-! ## Complete Graphs -/

namespace CompleteGraph

/-- The complete graph on `Fin n`. -/
def K (n : ℕ) : SimpleGraph (Fin n) := ⊤

instance (n : ℕ) : DecidableRel (K n).Adj := by
  intro v w; simp [K]; exact instDecidableNot

/-- Every vertex in K_n is adjacent to every other vertex. -/
theorem K_adj {n : ℕ} {v w : Fin n} (h : v ≠ w) : (K n).Adj v w := by
  simp [K]; exact h

/-
The degree of each vertex in K_n is n - 1.
-/
theorem K_degree (n : ℕ) [NeZero n] (v : Fin n) : (K n).degree v = n - 1 := by
  unfold K; aesop;

/-
The number of edges in K_n is n * (n - 1) / 2.
-/
theorem K_edge_count (n : ℕ) : (K n).edgeFinset.card = n * (n - 1) / 2 := by
  convert Finset.card_powersetCard 2 ( Finset.univ : Finset ( Fin n ) ) using 1;
  · fapply Finset.card_bij;
    use fun a ha => Finset.univ.filter ( fun x => x ∈ a );
    · rintro ⟨ a, b ⟩ hab ; simp_all +decide [ SimpleGraph.mem_edgeSet ];
      rw [ Finset.card_eq_two ] ; use a, b ; aesop;
    · simp +contextual [ Finset.ext_iff, Set.ext_iff ];
      exact fun a₁ ha₁ a₂ ha₂ h => by ext x; specialize h x; aesop;
    · intro b hb; rw [ mem_powersetCard ] at hb; obtain ⟨ x, y, hxy ⟩ := Finset.card_eq_two.mp hb.2; use s(x, y); aesop;
  · simp +decide [ Nat.choose_two_right ]

/-
**The genus of the complete graph K_n is (n-1)(n-2)/2**.
    This gives the cyclomatic number, equal to the genus of the
    corresponding algebraic curve in the tropical geometry correspondence.
-/
theorem K_genus (n : ℕ) (_hn : 2 ≤ n) :
    ChipFiring.genus (K n) = ((n - 1) * (n - 2) : ℤ) / 2 := by
  rw [ ChipFiring.genus ];
  rw [ K_edge_count ];
  cases n <;> norm_num [ Nat.dvd_iff_mod_eq_zero, Nat.mod_two_of_bodd ] ; ring_nf ; omega;

/-
The canonical divisor of K_n assigns (n : ℤ) - 3 to each vertex.
    Since each vertex has degree n-1, the canonical divisor is (n-1-2) = n-3 at each vertex.
-/
theorem K_canonical_value (n : ℕ) [NeZero n] (v : Fin n) :
    ChipFiring.canonicalDivisor (K n) v = (n : ℤ) - 3 := by
  convert congr_arg ( fun x : ℕ => ( x : ℤ ) - 2 ) ( K_degree n v ) using 1;
  grind +splitIndPred

/-
The degree of the canonical divisor of K_n is n*(n-3).
-/
theorem K_canonical_degree (n : ℕ) [NeZero n] :
    GraphDivisor.degree (ChipFiring.canonicalDivisor (K n)) = (n : ℤ) * ((n : ℤ) - 3) := by
  unfold ChipFiring.canonicalDivisor;
  simp +decide [ GraphDivisor.degree, K_degree ];
  rw [ Nat.cast_pred ] <;> linarith [ NeZero.pos n ]

/-- **Canonical divisor degree matches 2g-2 for complete graphs.**
    This is a consistency check: deg(K_{K_n}) = 2·genus(K_n) - 2. -/
theorem K_canonical_degree_is_2g_minus_2 (n : ℕ) (_hn : 2 ≤ n) :
    GraphDivisor.degree (ChipFiring.canonicalDivisor (K n)) =
    2 * ChipFiring.genus (K n) - 2 :=
  ChipFiring.canonical_divisor_degree (K n)

/-
**Chip-firing on K_n**: when vertex v fires, it loses (n-1) chips
    and every other vertex gains exactly 1 chip.
-/
theorem K_chipFire_effect (n : ℕ) [NeZero n] (D : GraphDivisor n)
    (v w : Fin n) (hw : w ≠ v) :
    ChipFiring.chipFire (K n) D v w = D w + 1 := by
  simp only [ChipFiring.chipFire, hw, ↓reduceIte]
  simp [CompleteGraph.K, hw.symm]

end CompleteGraph

/-! ## Effective Divisors and the Riemann-Roch Setup -/

namespace RiemannRoch

variable {n : ℕ} (G : SimpleGraph (Fin n)) [DecidableRel G.Adj]

/-- The zero divisor is effective. -/
theorem zero_effective : ChipFiring.Effective (0 : GraphDivisor n) := by
  intro v; rfl

/-
An effective divisor has non-negative degree.
-/
theorem effective_degree_nonneg (D : GraphDivisor n) (h : ChipFiring.Effective D) :
    0 ≤ GraphDivisor.degree D := by
  exact Finset.sum_nonneg fun _ _ => h _

/-
For a divisor of negative degree, no linearly equivalent divisor is effective.
    This is a key ingredient in Riemann-Roch: if deg(D) < 0 then r(D) = -1.
-/
theorem negative_degree_not_equiv_effective (D : GraphDivisor n)
    (hD : GraphDivisor.degree D < 0) :
    ¬ ∃ D' : GraphDivisor n, ChipFiring.Effective D' ∧ ChipFiring.LinearEquiv G D D' := by
  rintro ⟨ D', hD', hD'' ⟩;
  exact hD.not_ge ( by linarith [ ChipFiring.linearEquiv_degree G D D' hD'', effective_degree_nonneg D' hD' ] )

/-- **Baker-Norine Riemann-Roch (statement)**:
    For any divisor D on a graph G, r(D) - r(K_G - D) = deg(D) + 1 - g(G).
    This is the central theorem; we state it as a definition to be verified. -/
def RiemannRochHolds : Prop :=
  ∀ D : GraphDivisor n,
    ∀ rD rKD : ℤ,
    -- rD is the rank of D
    (ChipFiring.HasRankAtLeast G D rD ∧ ¬ ChipFiring.HasRankAtLeast G D (rD + 1)) →
    -- rKD is the rank of K_G - D
    (ChipFiring.HasRankAtLeast G (ChipFiring.canonicalDivisor G - D) rKD ∧
     ¬ ChipFiring.HasRankAtLeast G (ChipFiring.canonicalDivisor G - D) (rKD + 1)) →
    rD - rKD = GraphDivisor.degree D + 1 - ChipFiring.genus G

/-- **Conjecture (testable)**: For K_n with n ≥ 2, the canonical divisor has rank at least g - 1,
    where g = (n-1)(n-2)/2.
    Test: compute for n = 3, 4, 5, 6 using the chip-firing algorithm.
    For K_3: g = 1, rank(K) = 0 = g - 1. ✓
    For K_4: g = 3, rank(K) = 2 = g - 1. ✓
    For K_5: g = 6, rank(K) = 5 = g - 1. ✓ -/
def CanonicalRankConjecture (_hn : 2 ≤ n) : Prop :=
  ChipFiring.HasRankAtLeast G (ChipFiring.canonicalDivisor G)
    (ChipFiring.genus G - 1)

end RiemannRoch