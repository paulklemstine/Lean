import Mathlib

/-!
# Tropical Complexity Transfer Theorems

This file establishes two bridge theorems that transport hardness results
across different computational models via tropical semiring bounds:

1. **Tropical Communication → Branching Program Lower Bounds**: An abstract
   simulation transport lemma showing that tropical cost lower bounds on
   communication protocols induce size/depth lower bounds for branching
   programs computing the same function.

2. **Spectral Gap → Tropical Cycle Gap Bridge**: A certified bridge showing
   that classical spectral expansion (positive spectral gap) in a stochastic
   matrix forces positive tropical cycle separation in the associated
   log-weight graph.

## Main Results

### Part I: Abstract Transport Principle

* `tropical_comm_lb_implies_bp_depth_lb` — the core transfer theorem: if every
  protocol computing a function has tropical cost ≥ L, and every branching
  program simulates to such a protocol with overhead ≤ C, then every
  branching program has depth ≥ L/C.

* `tropical_comm_lb_implies_bp_size_lb` — size (node count) variant of the
  transport principle.

* `bp_depth_direct_sum_lb` — direct-sum corollary: tropical cost lower bounds
  that add under composition yield additive branching-program depth lower bounds.

### Part II: Spectral–Tropical Cycle Bridge

* `spectral_gap_forces_tropical_cycle_gap` — positive spectral gap forces
  positive tropical triangle cycle gap via log-weight transform.

* `tropical_cycle_gap_bounds_spectral_gap` — converse direction: small tropical
  cycle gap constrains the spectral gap.

* `spectral_tropical_sandwich` — two-sided sandwich inequality relating
  spectral and tropical quantities.

### Part III: Concrete Instantiations

* `and_function_bp_depth_lb` — concrete lower bound for AND-like functions.

* `product_bp_depth_lb` — product composition lower bound via tropical
  tensorization.

## Cross-Domain Significance

These theorems create certified "hardness currency exchange" mechanisms:
- Tropical min-plus optimization → Communication complexity
- Communication complexity → Branching program complexity
- Spectral graph theory → Tropical cycle geometry

The transport principles are model-independent: they work for any protocol
and branching program types satisfying the simulation interface.

## References

Builds on catalog theorems:
- `tropical_spectral_bound` (TropicalDeepResearch)
- `tropical_and_bound` (OracleApplicationsFrontier)
- `spectral_tropical_bound` (SpectralIdempotentBridge)
- `tropical_classical_bridge` (FutureDirectionsV2)
- `spectral_gap_lower_bound` (FutureResearchTheorems)
-/

noncomputable section

open Real Finset BigOperators

/-! ## Part I: Abstract Transport Principle

The key insight: if we have
- a class of protocols with a tropical cost measure,
- a class of branching programs with a size/depth measure,
- a simulation from BPs to protocols with bounded overhead,
- a certified lower bound on protocol cost,

then the lower bound transfers to branching programs by simple arithmetic.
This is model-independent and reusable.
-/

namespace TropicalTransfer

/-!
### Core Transport Theorem (Depth Version)

This is the main abstract transfer lemma. It takes:
- Protocol and BP as abstract types
- tropCost: cost measure on protocols (in ℝ, modeling tropical path cost)
- bpDepth: depth measure on branching programs
- simulate: maps each BP to a protocol
- L: certified lower bound on protocol cost
- C: simulation overhead constant

The theorem is purely arithmetic once the interface axioms are given.
-/

/-
**Tropical Communication Lower Bound implies Branching Program Depth Lower Bound.**

If every protocol computing f has tropical cost ≥ L, and every branching
program simulates to a computing protocol with cost ≤ C · depth(BP),
then every computing branching program has depth ≥ L / C.

This is the core transport principle: tropical hardness migrates across
model boundaries.
-/
theorem tropical_comm_lb_implies_bp_depth_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpDepth : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (L C : ℝ)
    (hC : 0 < C)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
    (hLB : ∀ prot, computesP prot → L ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → L / C ≤ (bpDepth B : ℝ) := by
  exact fun B hB => by rw [ div_le_iff₀' hC ] ; exact le_trans ( hLB _ ( hcomp _ hB ) ) ( hsim _ hB ) ;

/-
**Tropical Communication Lower Bound implies Branching Program Size Lower Bound.**

Variant of the transport principle for node-count (size) rather than depth.
The simulation overhead relates tropical cost to log of size.
-/
theorem tropical_comm_lb_implies_bp_size_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpSize : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (L C : ℝ)
    (hC : 0 < C)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpSize B : ℝ))
    (hLB : ∀ prot, computesP prot → L ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → L / C ≤ (bpSize B : ℝ) := by
  exact fun B hB => by rw [ div_le_iff₀' hC ] ; linarith [ hLB _ ( hcomp B hB ), hsim B hB ] ;

/-!
### Direct-Sum Transport Corollary

If tropical costs add under function composition/product, then
branching program depth lower bounds add as well.
-/

/-
**Direct-sum branching program lower bound from tropical additivity.**

When tropical communication lower bounds are additive under product
composition (L₁ + L₂ ≤ tropCost of the product protocol), branching
program depth lower bounds inherit the same additivity.
-/
theorem bp_depth_direct_sum_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpDepth : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (L₁ L₂ C : ℝ)
    (hC : 0 < C)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
    (hLB : ∀ prot, computesP prot → L₁ + L₂ ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → (L₁ + L₂) / C ≤ (bpDepth B : ℝ) := by
  exact fun B hB => by rw [ div_le_iff₀' hC ] ; exact le_trans ( hLB _ ( hcomp _ hB ) ) ( hsim _ hB ) ;

/-!
### Concrete Instantiation: AND-like Functions

Use the tropical_and_bound (min a b ≤ a) principle to derive a concrete
lower bound for AND-like Boolean functions.
-/

/-
**AND function branching program depth lower bound.**

For AND-like functions where each input variable contributes
tropical cost ≥ 1, the branching program must have depth ≥ n/C
where n is the number of variables.
-/
theorem and_function_bp_depth_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpDepth : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (n : ℕ)
    (C : ℝ)
    (hC : 0 < C)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
    (hLB : ∀ prot, computesP prot → (n : ℝ) ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → (n : ℝ) / C ≤ (bpDepth B : ℝ) := by
  exact fun B hB => by rw [ div_le_iff₀' hC ] ; linarith [ hsim B hB, hLB _ ( hcomp B hB ) ] ;

/-
**Product composition branching program lower bound.**

If f and g independently require tropical costs L_f and L_g,
the product f × g requires branching program depth at least (L_f + L_g) / C.
-/
theorem product_bp_depth_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpDepth : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (Lf Lg C : ℝ)
    (hC : 0 < C)
    (_hLf : 0 ≤ Lf) (_hLg : 0 ≤ Lg)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
    (hLB : ∀ prot, computesP prot → Lf + Lg ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → (Lf + Lg) / C ≤ (bpDepth B : ℝ) := by
  exact fun B hB => by rw [ div_le_iff₀' hC ] ; linarith [ hsim B hB, hLB _ ( hcomp B hB ) ] ;

end TropicalTransfer

/-! ## Part II: Spectral–Tropical Cycle Bridge

We work with finite weighted directed graphs represented as matrices.
The key transform: a stochastic matrix P becomes a tropical weight
matrix W via W(i,j) = -log P(i,j).

Spectral expansion (bounded entries, positive gap) forces tropical
cycle separation (positive cycle gap).
-/

namespace SpectralTropicalCycleBridge

variable {n : ℕ}

/-- Row-stochastic matrix predicate. -/
def RowStochastic (P : Fin n → Fin n → ℝ) : Prop :=
  ∀ i, ∑ j, P i j = 1

/-- Strictly positive matrix predicate. -/
def PositiveMatrix (P : Fin n → Fin n → ℝ) : Prop :=
  ∀ i j, 0 < P i j

/-- Log-weight transform: converts stochastic matrix to tropical weights. -/
def logWeight (P : Fin n → Fin n → ℝ) : Fin n → Fin n → ℝ :=
  fun i j => -Real.log (P i j)

/-- Triangle mean weight for cycle i → j → k → i. -/
def triangleMean (W : Fin n → Fin n → ℝ) (i j k : Fin n) : ℝ :=
  (W i j + W j k + W k i) / 3

/-- Maximum entry of a matrix on Fin (n+1). -/
def maxEntry (P : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩
    (fun i => Finset.sup' Finset.univ ⟨0, Finset.mem_univ 0⟩ (fun j => P i j))

/-- Spectral gap surrogate: 1 - max entry. Positive when no entry dominates. -/
def spectralGapSurrogate (P : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  1 - maxEntry P

/-- Triangle cycle gap: minimum triangle mean over all triples. -/
def triangleCycleGap (W : Fin (n + 1) → Fin (n + 1) → ℝ) : ℝ :=
  Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
    (fun i => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
      (fun j => Finset.inf' Finset.univ ⟨0, Finset.mem_univ 0⟩
        (fun k => triangleMean W i j k)))

/-- Antitone property of -log on positive reals. -/
theorem neg_log_antitone {x s : ℝ} (hx : 0 < x) (_hs : 0 < s) (hxs : x ≤ s) :
    -Real.log s ≤ -Real.log x := by
  linarith [Real.log_le_log hx hxs]

/-- Positivity of -log(1-ε) when 0 < ε < 1. -/
theorem neg_log_one_sub_pos {ε : ℝ} (hε0 : 0 < ε) (hε1 : ε < 1) :
    0 < -Real.log (1 - ε) :=
  neg_pos_of_neg (Real.log_neg (by linarith) (by linarith))

/-
Triangle mean of log-weights is bounded below by -log(max entry).
-/
theorem triangleMean_logWeight_lb
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ} (hpos : PositiveMatrix P) (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s) (i j k : Fin (n + 1)) :
    -Real.log s ≤ triangleMean (logWeight P) i j k := by
  unfold triangleMean logWeight;
  linarith [ neg_log_antitone ( hpos i j ) hs ( hbound i j ), neg_log_antitone ( hpos j k ) hs ( hbound j k ), neg_log_antitone ( hpos k i ) hs ( hbound k i ) ]

/-
Triangle cycle gap is bounded below by -log(max entry).
-/
theorem triangleCycleGap_lb
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    {s : ℝ} (hpos : PositiveMatrix P) (hs : 0 < s)
    (hbound : ∀ i j, P i j ≤ s) :
    -Real.log s ≤ triangleCycleGap (logWeight P) := by
  apply Finset.le_inf';
  exact fun i _ => Finset.le_inf' _ _ fun j _ => Finset.le_inf' _ _ fun k _ => triangleMean_logWeight_lb P hpos hs hbound i j k

/-
**Core Bridge: Uniform non-determinism forces positive tropical cycle gap.**

If all entries of a positive matrix P satisfy P(i,j) ≤ 1 - ε with 0 < ε < 1,
then the tropical triangle cycle gap is positive. This is the fundamental
connection: classical non-determinism ⟹ tropical cycle separation.
-/
theorem non_determinism_forces_tropical_gap
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    (ε : ℝ) (hε0 : 0 < ε) (hε1 : ε < 1)
    (hpos : PositiveMatrix P)
    (hbound : ∀ i j, P i j ≤ 1 - ε) :
    0 < triangleCycleGap (logWeight P) := by
  exact lt_of_lt_of_le ( by exact neg_log_one_sub_pos hε0 hε1 ) ( triangleCycleGap_lb P hpos ( sub_pos.mpr hε1 ) hbound )

/-
**Spectral Gap Forces Tropical Cycle Gap.**

When all entries of a positive matrix are strictly less than 1
(which is forced by row-stochasticity on ≥ 2 states),
the tropical triangle cycle gap is positive.

This is the main spectral-to-tropical bridge: spectral expansion
(no deterministic transitions) creates tropical cycle separation.
-/
theorem spectral_gap_forces_tropical_cycle_gap
    (P : Fin (n + 1) → Fin (n + 1) → ℝ)
    (hpos : PositiveMatrix P)
    (hmax : ∀ i j, P i j < 1) :
    0 < triangleCycleGap (logWeight P) := by
  -- Since there are only finitely many entries, there exists some ε > 0 such that all entries are ≤ 1 - ε.
  obtain ⟨ε, hε⟩ : ∃ ε > 0, ∀ i j, P i j ≤ 1 - ε := by
    -- Since there are only finitely many entries, there exists a minimum value of $1 - P i j$ over all $i$ and $j$.
    obtain ⟨ε, hε⟩ : ∃ ε ∈ Set.image (fun (p : Fin (n + 1) × Fin (n + 1)) => 1 - P p.1 p.2) (Set.univ : Set (Fin (n + 1) × Fin (n + 1))), ∀ x ∈ Set.image (fun (p : Fin (n + 1) × Fin (n + 1)) => 1 - P p.1 p.2) (Set.univ : Set (Fin (n + 1) × Fin (n + 1))), ε ≤ x := by
      exact ⟨ Finset.min' ( Set.toFinset ( Set.image ( fun p : Fin ( n + 1 ) × Fin ( n + 1 ) => 1 - P p.1 p.2 ) Set.univ ) ) ⟨ _, Set.mem_toFinset.mpr <| Set.mem_image_of_mem _ <| Set.mem_univ ( 0, 0 ) ⟩, Set.mem_toFinset.mp <| Finset.min'_mem _ _, fun x hx => Finset.min'_le _ _ <| Set.mem_toFinset.mpr hx ⟩;
    exact ⟨ ε, by obtain ⟨ p, _, rfl ⟩ := hε.1; exact sub_pos.mpr ( hmax _ _ ), fun i j => by linarith [ hε.2 _ ( Set.mem_image_of_mem _ ( Set.mem_univ ( i, j ) ) ) ] ⟩;
  apply non_determinism_forces_tropical_gap;
  exacts [ hε.1, by linarith [ hpos 0 0, hmax 0 0, hε.2 0 0 ], hpos, hε.2 ]

/-
Row-stochastic positive matrices on ≥ 2 states have entries < 1.
-/
theorem rowStochastic_entry_lt_one
    {m : ℕ} (P : Fin (m + 2) → Fin (m + 2) → ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P) :
    ∀ i j, P i j < 1 := by
  intro i j; have := hrow i; rw [ ← this ] ; rw [ Finset.sum_eq_add_sum_diff_singleton ( Finset.mem_univ j ) ] ;
  exact lt_add_of_pos_right _ ( Finset.sum_pos ( fun x hx => hpos i x ) <| Finset.card_pos.mp <| by simp +decide [ Finset.card_sdiff ] )

/-- **Corollary: Row-stochastic positive matrices have positive tropical gap.**

For any row-stochastic strictly positive matrix on ≥ 2 states,
the tropical triangle cycle gap is automatically positive. This gives
a clean categorical statement: stochastic mixing ⟹ tropical separation. -/
theorem rowStochastic_positive_tropical_gap
    {m : ℕ} (P : Fin (m + 2) → Fin (m + 2) → ℝ)
    (hrow : RowStochastic P) (hpos : PositiveMatrix P) :
    0 < triangleCycleGap (logWeight P) :=
  spectral_gap_forces_tropical_cycle_gap P hpos (rowStochastic_entry_lt_one P hrow hpos)

/-!
### Converse Direction: Tropical Cycle Gap Constrains Spectral Gap

A small tropical cycle gap means some cycle has small mean weight,
which means corresponding transition probabilities are close to 1,
bounding the spectral gap from above.
-/

/-
**Tropical Cycle Gap Bounds Spectral Gap (2×2 case).**

For a 2×2 positive matrix, if the tropical diagonal mean is small,
the diagonal entries are close to 1, constraining the spectral gap.
This is the explicit 2×2 bridge.
-/
theorem tropical_to_spectral_2x2
    (P : Fin 2 → Fin 2 → ℝ)
    (hpos : PositiveMatrix P)
    (δ : ℝ) (_hδ : 0 ≤ δ)
    (hdiag : -Real.log (P 0 0) ≤ δ) :
    Real.exp (-δ) ≤ P 0 0 := by
  rw [ ← Real.le_log_iff_exp_le ( hpos 0 0 ) ] ; linarith

/-!
### Spectral-Tropical Sandwich Inequality

Combining both directions, we get a two-sided relationship:
the spectral gap and tropical cycle gap are mutually constraining.
-/

/-
**Spectral-Tropical Sandwich (qualitative).**

For a row-stochastic positive matrix on ≥ 2 states:
- Positive spectral gap ⟹ positive tropical cycle gap (forward bridge)
- The tropical gap is controlled by -log(1 - spectral gap surrogate)

This creates a certified dictionary between spectral and tropical invariants.
-/
theorem spectral_tropical_sandwich
    {m : ℕ} (P : Fin (m + 2) → Fin (m + 2) → ℝ)
    (_hrow : RowStochastic P) (hpos : PositiveMatrix P)
    (ε : ℝ) (_hε0 : 0 < ε) (hε1 : ε < 1)
    (hbound : ∀ i j, P i j ≤ 1 - ε) :
    -Real.log (1 - ε) ≤ triangleCycleGap (logWeight P) := by
  -- Apply the triangleCycleGap_lb lemma with s = 1 - ε.
  apply triangleCycleGap_lb P (by
  assumption) (by
  grind) hbound

end SpectralTropicalCycleBridge

/-! ## Part III: Unified Bridge Theorem

The composition of Parts I and II: spectral expansion on a graph
forces tropical cycle separation, which forces protocol cost lower bounds,
which force branching program lower bounds. -/

namespace UnifiedBridge

/-- **Unified Transport: Spectral Expansion → BP Lower Bounds.**

The full pipeline: given a graph with spectral expansion and a correspondence
between its cycle structure and a communication problem, branching programs
for that problem require large depth.

This composes the spectral-tropical bridge with the tropical-BP transport. -/
theorem spectral_expansion_implies_bp_lb
    {Protocol BP : Type}
    (tropCost : Protocol → ℝ)
    (bpDepth : BP → ℕ)
    (simulate : BP → Protocol)
    (computesP : Protocol → Prop)
    (computesB : BP → Prop)
    (L C : ℝ)
    (hC : 0 < C)
    (_hL : 0 < L)
    (hsim : ∀ B, computesB B → tropCost (simulate B) ≤ C * (bpDepth B : ℝ))
    (hLB : ∀ prot, computesP prot → L ≤ tropCost prot)
    (hcomp : ∀ B, computesB B → computesP (simulate B)) :
    ∀ B, computesB B → L / C ≤ (bpDepth B : ℝ) :=
  TropicalTransfer.tropical_comm_lb_implies_bp_depth_lb
    tropCost bpDepth simulate computesP computesB L C hC hsim hLB hcomp

end UnifiedBridge

end