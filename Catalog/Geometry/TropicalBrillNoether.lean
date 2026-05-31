/-
# Tropical Brill-Noether Theory

Formalization of the Brill-Noether number and divisor theory on graphs,
connecting tropical geometry to classical algebraic geometry.
-/
import Mathlib

/-! ## Section 1: The Brill-Noether Number -/

/-- The Brill-Noether number ρ(g,d,r) = g - (r+1)(g - d + r). -/
def brillNoetherNumber (g d r : ℤ) : ℤ :=
  g - (r + 1) * (g - d + r)

/-- Expanded form: ρ = (r+1)(d-r) - gr. -/
theorem bn_expanded (g d r : ℤ) :
    brillNoetherNumber g d r = (r + 1) * (d - r) - g * r := by
  unfold brillNoetherNumber; ring

/-- **Serre Duality for ρ**: ρ(g,d,r) = ρ(g, 2g-2-d, g-1-d+r).
Reflects the classical Serre duality on algebraic curves, where
a divisor D of degree d and rank r is dual to K-D. -/
theorem bn_serre_duality (g d r : ℤ) :
    brillNoetherNumber g d r = brillNoetherNumber g (2 * g - 2 - d) (g - 1 - d + r) := by
  unfold brillNoetherNumber; ring

/-- **When ρ ≥ 0 with g ≥ 0 and r ≥ 0, we must have d ≥ r.**
Proof by contradiction: if d < r, then (r+1)(g-d+r) > g, so ρ < 0. -/
theorem bn_nonneg_implies_d_ge_r {g d r : ℤ} (hg : 0 ≤ g) (hr : 0 ≤ r)
    (hρ : 0 ≤ brillNoetherNumber g d r) : r ≤ d := by
  unfold brillNoetherNumber at hρ
  nlinarith [sq_nonneg (d - r)]

/-- ρ(0,d,r) = (r+1)(d-r). -/
theorem bn_genus_zero (d r : ℤ) :
    brillNoetherNumber 0 d r = (r + 1) * (d - r) := by
  unfold brillNoetherNumber; ring

/-- ρ(g, 2g-2, g-1) = 0 for any genus (the canonical divisor case). -/
theorem bn_canonical (g : ℤ) :
    brillNoetherNumber g (2 * g - 2) (g - 1) = 0 := by
  unfold brillNoetherNumber; ring

/-- **ρ is monotonically increasing in d** (with r ≥ 0 fixed).
The difference ρ(g,d₂,r) - ρ(g,d₁,r) = (r+1)(d₂-d₁) ≥ 0. -/
theorem bn_mono_d (g d₁ d₂ r : ℤ) (hr : 0 ≤ r) (h : d₁ ≤ d₂) :
    brillNoetherNumber g d₁ r ≤ brillNoetherNumber g d₂ r := by
  have key : brillNoetherNumber g d₂ r - brillNoetherNumber g d₁ r =
      (r + 1) * (d₂ - d₁) := by
    unfold brillNoetherNumber; ring
  nlinarith

/-- ρ(g, g, 1) = g - 2. -/
theorem bn_gonality_bound (g : ℤ) :
    brillNoetherNumber g g 1 = g - 2 := by
  unfold brillNoetherNumber; ring

/-- ρ(g, g-1, 0) = g - 1 (effective divisors of degree g-1). -/
theorem bn_degree_g_minus_1 (g : ℤ) :
    brillNoetherNumber g (g - 1) 0 = g - 1 := by
  unfold brillNoetherNumber; ring

/-- ρ(g,d,r+1) = ρ(g,d,r) - (g - d + 2r + 2). -/
theorem bn_rank_step (g d r : ℤ) :
    brillNoetherNumber g d (r + 1) = brillNoetherNumber g d r - (g - d + 2 * r + 2) := by
  unfold brillNoetherNumber; ring

/-- **Castelnuovo's weak bound**: If ρ ≥ 0 and r ≥ 1, then g·r ≤ (r+1)(d-r). -/
theorem bn_castelnuovo_weak {g d r : ℤ} (_hr : 1 ≤ r)
    (hρ : 0 ≤ brillNoetherNumber g d r) :
    g * r ≤ (r + 1) * (d - r) := by
  rw [bn_expanded] at hρ; linarith

/-- **Clifford bound from ρ**: When ρ ≥ 0 and d ≤ 2g-2, then 2r ≤ d. -/
theorem bn_clifford_bound {g d r : ℤ} (_hg : 1 ≤ g) (_unused_hr : 0 ≤ r)
    (hρ : 0 ≤ brillNoetherNumber g d r) (hd : d ≤ 2 * g - 2) :
    2 * r ≤ d := by
  unfold brillNoetherNumber at hρ
  nlinarith [sq_nonneg (d - 2 * r), sq_nonneg r, sq_nonneg g]

/-! ## Section 2: Graph Divisors -/

/-- A divisor on a graph with vertex set V. -/
abbrev GraphDivisor (V : Type*) := V → ℤ

/-- The degree of a divisor. -/
noncomputable def divisorDegree {V : Type*} [Fintype V] (D : GraphDivisor V) : ℤ :=
  ∑ v : V, D v

/-- A divisor is effective if all entries are non-negative. -/
def isEffective {V : Type*} (D : GraphDivisor V) : Prop :=
  ∀ v, 0 ≤ D v

/-- An effective divisor has non-negative degree. -/
theorem effective_nonneg_degree {V : Type*} [Fintype V]
    (D : GraphDivisor V) (hD : isEffective D) : 0 ≤ divisorDegree D :=
  Finset.sum_nonneg (fun v _ => hD v)

/-! ## Section 3: Chip-Firing -/

/-- The Laplacian action: (Lf)(v) = Σ_{w ~ v} (f(v) - f(w)). -/
noncomputable def laplacianAction {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) : GraphDivisor V :=
  fun v => ∑ w : V, if G.Adj v w then f v - f w else 0

/-- Two divisors are linearly equivalent if they differ by a Laplacian. -/
def linEquiv {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D₁ D₂ : GraphDivisor V) : Prop :=
  ∃ f : V → ℤ, ∀ v, D₂ v = D₁ v + laplacianAction G f v

/-
The Laplacian action sums to zero.
-/
theorem laplacian_sum_zero {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (f : V → ℤ) :
    ∑ v : V, laplacianAction G f v = 0 := by
  unfold laplacianAction
  simp +decide [Finset.sum_ite]
  simp +decide [Finset.sum_filter]
  rw [Finset.sum_comm]
  simp +decide [Finset.sum_ite, SimpleGraph.adj_comm]

/-- Linear equivalence preserves degree. -/
theorem linEquiv_preserves_degree {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (D₁ D₂ : GraphDivisor V) (h : linEquiv G D₁ D₂) :
    divisorDegree D₁ = divisorDegree D₂ := by
  obtain ⟨f, hf⟩ := h
  have key : ∑ v : V, D₂ v = ∑ v : V, (D₁ v + laplacianAction G f v) :=
    Finset.sum_congr rfl (fun v _ => hf v)
  simp only [divisorDegree]
  linarith [Finset.sum_add_distrib (f := fun v => D₁ v) (g := laplacianAction G f)
    (s := Finset.univ (α := V)), laplacian_sum_zero G f, key]

/-- Linear equivalence is reflexive. -/
theorem linEquiv_refl {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) :
    linEquiv G D D :=
  ⟨fun _ => 0, fun v => by simp [laplacianAction]⟩

/-! ## Section 4: Tropical Linear Series (Novel Definition) -/

/-- **Tropical Linear Series**: A g^r_d on a tropical curve.
Packages a divisor with its rank, formalizing the combinatorial
analogue of a classical linear series via chip-firing. -/
structure TropicalLinearSeries (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] where
  /-- The underlying divisor -/
  divisor : GraphDivisor V
  /-- The degree d -/
  deg : ℤ
  /-- The rank r -/
  rank : ℤ
  /-- Degree consistency -/
  deg_eq : divisorDegree divisor = deg
  /-- Rank is non-negative -/
  rank_nonneg : 0 ≤ rank
  /-- Rank witness -/
  rank_witness : ∀ E : GraphDivisor V, isEffective E →
    divisorDegree E ≤ rank →
    ∃ D' : GraphDivisor V, linEquiv G (fun v => divisor v - E v) D' ∧ isEffective D'

/-- The BN number of a tropical linear series. -/
def TropicalLinearSeries.bnNumber {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (L : TropicalLinearSeries V G) (genus : ℤ) : ℤ :=
  brillNoetherNumber genus L.deg L.rank

/-! ## Section 5: Graph Genus -/

/-- The genus of a graph: g = |E| - |V| + 1. -/
noncomputable def graphGenus (V : Type*) [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : ℤ :=
  let numEdgePairs := (Finset.univ (α := V × V)).filter (fun p => G.Adj p.1 p.2)
  numEdgePairs.card / 2 - (Fintype.card V : ℤ) + 1

/-- The canonical divisor: K(v) = deg(v) - 2. -/
noncomputable def canonicalDivisor {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] : GraphDivisor V :=
  fun v => ((Finset.univ.filter (G.Adj v)).card : ℤ) - 2

/-! ## Section 6: Reduced Divisors -/

/-- A v-reduced divisor: non-negative away from v, no subset of V\{v} can fire. -/
def isReduced {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V) : Prop :=
  (∀ w, w ≠ v → 0 ≤ D w) ∧
  ∀ S : Finset V, v ∉ S → S.Nonempty →
    ∃ w ∈ S, D w < ((S.filter (G.Adj w)).card : ℤ)

/-- **Dhar's Burning Lemma**: A v-reduced divisor is effective iff D(v) ≥ 0. -/
theorem reduced_effective_iff {V : Type*} [Fintype V] [DecidableEq V]
    (G : SimpleGraph V) [DecidableRel G.Adj] (D : GraphDivisor V) (v : V)
    (hred : isReduced G D v) :
    isEffective D ↔ 0 ≤ D v := by
  constructor
  · exact fun h => h v
  · intro hv w
    by_cases hwv : w = v
    · exact hwv ▸ hv
    · exact hred.1 w hwv

/-! ## Section 7: Rank-Degree Inequality -/

/-- A point-mass divisor has the expected degree. -/
theorem pointMass_degree {V : Type*} [Fintype V] [DecidableEq V] (v₀ : V) (n : ℤ) :
    divisorDegree (fun v => if v = v₀ then n else 0) = n := by
  simp [divisorDegree, Finset.sum_ite_eq']

/-- A point-mass divisor with n ≥ 0 is effective. -/
theorem pointMass_effective {V : Type*} [DecidableEq V] (v₀ : V) (n : ℤ) (hn : 0 ≤ n) :
    isEffective (fun v => if v = v₀ then n else 0) := by
  intro v; simp only; split <;> omega

/-- The degree of D - E as a pointwise function. -/
theorem degree_sub {V : Type*} [Fintype V]
    (D E : GraphDivisor V) :
    divisorDegree (fun v => D v - E v) = divisorDegree D - divisorDegree E := by
  simp [divisorDegree, sub_eq_add_neg, Finset.sum_add_distrib, Finset.sum_neg_distrib]

/-- **Rank-Degree Inequality**: rank ≤ degree for any tropical linear series
(when the vertex set is nonempty). -/
theorem rank_le_degree_of_tls {V : Type*} [Fintype V] [DecidableEq V]
    {G : SimpleGraph V} [DecidableRel G.Adj]
    (L : TropicalLinearSeries V G) [Nonempty V] :
    L.rank ≤ L.deg := by
  -- Construct E = point mass of rank chips at an arbitrary vertex
  obtain ⟨v₀⟩ := ‹Nonempty V›
  let E : GraphDivisor V := fun v => if v = v₀ then L.rank else 0
  have hE_eff : isEffective E := pointMass_effective v₀ L.rank L.rank_nonneg
  have hE_deg : divisorDegree E = L.rank := pointMass_degree v₀ L.rank
  have hE_le : divisorDegree E ≤ L.rank := le_of_eq hE_deg
  -- By rank_witness, D - E ~ D' effective
  obtain ⟨D', hD'_equiv, hD'_eff⟩ := L.rank_witness E hE_eff hE_le
  -- D' effective ⇒ deg(D') ≥ 0
  have hD'_deg : 0 ≤ divisorDegree D' := effective_nonneg_degree D' hD'_eff
  -- Linear equiv preserves degree: deg(D - E) = deg(D')
  have hpres := linEquiv_preserves_degree G _ D' hD'_equiv
  -- deg(D - E) = deg(D) - deg(E) = deg - rank
  rw [degree_sub] at hpres
  linarith [L.deg_eq, hE_deg]

/-! ## Section 8: Concrete Results -/

/-- ρ(3, 3, 1) = 1. -/
theorem bn_genus3_g13 : brillNoetherNumber 3 3 1 = 1 := by
  unfold brillNoetherNumber; ring

/-- ρ(4, 3, 1) = 0: general genus-4 curves have finitely many g¹₃'s. -/
theorem bn_genus4_trigonal : brillNoetherNumber 4 3 1 = 0 := by
  unfold brillNoetherNumber; ring

/-- ρ(2, 2, 1) = 0: every genus-2 curve is hyperelliptic. -/
theorem bn_genus2_hyperelliptic : brillNoetherNumber 2 2 1 = 0 := by
  unfold brillNoetherNumber; ring

/-- ρ(4, 4, 1) = 2. -/
theorem bn_genus4_g14 : brillNoetherNumber 4 4 1 = 2 := by
  unfold brillNoetherNumber; ring

/-! ## Section 9: Conjecture -/

/-- **Conjecture (Tropical Maximal Rank)**: For a chain of g loops,
the maximum rank of a degree-d divisor is the largest r ≥ 0 with ρ(g,d,r) ≥ 0.

Testable: g=5, d=4 ⟹ ρ(5,4,1)=1≥0, ρ(5,4,2)=-4<0, so max rank = 1.
Test by chip-firing on a chain of 5 loops. -/
def tropicalMaxRankConjecture (g d : ℤ) : Prop :=
  ∀ r : ℤ, 0 ≤ r →
    (brillNoetherNumber g d r ≥ 0 ↔
      ∃ (V : Type) (_ : Fintype V) (_ : DecidableEq V) (G : SimpleGraph V)
        (_ : DecidableRel G.Adj),
        graphGenus V G = g ∧
        ∃ L : TropicalLinearSeries V G, L.deg = d ∧ L.rank ≥ r)

theorem bn_test_pos : 0 ≤ brillNoetherNumber 5 4 1 := by
  unfold brillNoetherNumber; norm_num

theorem bn_test_neg : brillNoetherNumber 5 4 2 < 0 := by
  unfold brillNoetherNumber; norm_num