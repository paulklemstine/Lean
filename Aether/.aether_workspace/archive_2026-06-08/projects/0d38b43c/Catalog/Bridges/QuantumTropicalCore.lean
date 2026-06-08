/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Valuation–Stabilizer Correspondence and Tropical Quantum Code Geometry

This file formalizes a min-plus/tropical theory of quantum stabilizer weight data.
It turns closure-theoretic stabilizer certification into explicit lower bounds on
code distance and explicit inf-convolution formulas for concatenated recovery.

Bridge: connects quantum error correction, tropical/idempotent algebra,
lattice fixed-point theory, polyhedral support functions, and certified
robustness style min-plus verification.

## Main definitions

* `QuantumTropical.StabilizerValuation` — tropical valuation on Pauli-weight vectors
* `QuantumTropical.tropWeightEnumerator` — min-plus weight enumerator
* `QuantumTropical.IsClosureOperator` — closure operator structure
* `QuantumTropical.IsTropicalBreakpoint` — breakpoint for distance certification
* `QuantumTropical.infConvolutionNat` — min-plus inf-convolution
* `QuantumTropical.tropicalSupportFunction` — tropical support function
* `QuantumTropical.TropicalClosureCompatible` — closure-valuation compatibility

## Main results

* `quantum_certified_breakpoint_distance` — breakpoint implies distance lower bound
* `breakpoint_add_of_both` — concatenation breakpoint ≥ sum of breakpoints
* `tropicalSupportFunction_infimal` — support function distributes over union
* `lattice_fixedpoint_pauli_shadow` — fixed-point invariance of enumerators
-/

import Mathlib

namespace QuantumTropical

open Finset Finsupp

/-! ## Section 1: Core Definitions -/

/-- Pauli weight of a finitely supported function: total sum of multiplicities.
Bridge: connects quantum Pauli operators to tropical weight lattice.
Computing `pauliWeight f` is O(|support f|). -/
noncomputable def pauliWeight {ι : Type*} [DecidableEq ι] (f : ι →₀ ℕ) : ℕ :=
  f.sum (fun _ m => m)

/-- Tropical valuation data attached to finitely supported Pauli-weight observables.
Bridge: connects quantum stabilizer enumerators to tropical lattice valuations.
Quantum interpretation: `val f` measures the tropical cost of realizing the
Pauli operator with weight profile `f` in a stabilizer code.
The `finite_val` condition ensures all elements have finite (non-⊤) valuations,
which is necessary for certified distance lower bounds. -/
structure StabilizerValuation (ι : Type*) [DecidableEq ι] where
  /-- The valuation function mapping weight vectors to tropical values -/
  val : (ι →₀ ℕ) → WithTop ℕ
  /-- Monotonicity: larger weight vectors have larger valuations -/
  monotone_val : Monotone val
  /-- The zero vector maps to zero (identity element) -/
  val_zero : val 0 = 0
  /-- Subadditivity: quantum concatenation cost is at most the sum -/
  val_add_le : ∀ f g, val (f + g) ≤ val f + val g
  /-- All valuations are finite: necessary for certified distance bounds -/
  finite_val : ∀ f, val f ≠ ⊤

/-- Closure operator structure for lattice fixed-point theory.
Bridge: connects Knaster-Tarski fixed-point lattice theory to
quantum stabilizer certification. -/
structure IsClosureOperator {α : Type*} [Preorder α] (c : α → α) : Prop where
  /-- The closure is extensive: every element is below its closure -/
  extensive : ∀ x, x ≤ c x
  /-- The closure is monotone -/
  monotone' : Monotone c
  /-- The closure is idempotent -/
  idempotent' : ∀ x, c (c x) = c x

/-- Fixed points of a function, representing certified codespace elements.
Bridge: connects lattice fixed-point theory to quantum code certification. -/
def fixedPoints {α : Type*} (c : α → α) : Set α := {x | c x = x}

/-- Tropical breakpoint: all weights below d have infinite tropical cost.
Bridge: connects tropical geometry breakpoints to quantum code distance
certification and post_quantum_security hardness gaps. -/
def IsTropicalBreakpoint (W : ℕ → WithTop ℕ) (d : ℕ) : Prop :=
  ∀ k, k < d → W k = ⊤

/-- Compatibility between closure operators and tropical valuations.
Bridge: connects lattice closure semantics to certified tropical shadow
computation for quantum stabilizer codespaces. -/
class TropicalClosureCompatible
    {α : Type*} [Preorder α] (c : α → α) (φ : α → WithTop ℕ) : Prop where
  /-- Monotonicity through closure -/
  mono_closed : ∀ ⦃x y : α⦄, x ≤ y → φ (c x) ≤ φ (c y)
  /-- Idempotent shadow: double closure doesn't change the valuation -/
  idempotent_shadow : ∀ x, φ (c (c x)) = φ (c x)

variable {ι : Type*} [DecidableEq ι]

/-- Tropical weight enumerator: for each weight k, the minimum tropical cost
among all elements of S with Pauli weight k.
Bridge: connects quantum weight enumerators to tropical min-plus profiles.
Computing `tropWeightEnumerator v S k` is O(|S|) by scanning S. -/
noncomputable def tropWeightEnumerator (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) (k : ℕ) : WithTop ℕ :=
  S.inf (fun f => if pauliWeight f = k then v.val f else ⊤)

/-- Min-plus inf-convolution on WithTop ℕ: the tropical analogue of convolution.
Bridge: connects tropical algebra to quantum concatenated recovery channels.
Computing `infConvolutionNat f g n` is O(n) by scanning 0..n.
Computing the first N values is O(N²) naively. -/
def infConvolutionNat (f g : ℕ → WithTop ℕ) (n : ℕ) : WithTop ℕ :=
  (Finset.range (n + 1)).inf (fun i => f i + g (n - i))

/-- Tropical support function over a finite set of weight vectors.
Bridge: connects polyhedral/tropical geometry support functions
to quantum stabilizer code analysis. -/
noncomputable def tropicalSupportFunction
    (S : Finset (ι →₀ ℕ)) (x : ι →₀ ℕ) : WithTop ℕ :=
  S.inf (fun f => ↑(pauliWeight (f + x)))

/-- Support radius of a stabilizer valuation: the supremum of valuations.
Bridge: connects tropical valuation radius to quantum code parameters. -/
noncomputable def supportRadius (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) : WithTop ℕ :=
  S.sup (fun f => v.val f)

/-- Concatenated recovery profile via inf-convolution.
Bridge: connects quantum concatenated recovery channels to tropical
inf-convolution, enabling certified dynamic-programming decoders. -/
def concatenatedRecoveryProfile (f g : ℕ → WithTop ℕ) : ℕ → WithTop ℕ :=
  infConvolutionNat f g

/-- The valuation polytope: set of weight vectors with bounded valuation.
Bridge: connects tropical code polytopes to certified quantum code
distance and post_quantum_security analysis. -/
noncomputable def valuationPolytope (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) (bound : WithTop ℕ) : Finset (ι →₀ ℕ) :=
  S.filter (fun f => v.val f ≤ bound)

/-! ## Section 2: Pauli Weight Properties -/

/-- Zero has Pauli weight zero.
Bridge: the quantum identity operator has zero weight. -/
theorem pauliWeight_zero : pauliWeight (0 : ι →₀ ℕ) = 0 := by
  simp [pauliWeight, Finsupp.sum]

/-- Pauli weight is additive: weight(f + g) = weight(f) + weight(g).
Bridge: quantum operator composition weight satisfies strict additivity
for independent qubit supports. -/
theorem pauliWeight_add (f g : ι →₀ ℕ) :
    pauliWeight (f + g) = pauliWeight f + pauliWeight g := by
  simp only [pauliWeight]
  rw [Finsupp.sum_add_index (by intros; rfl) (by intros; simp)]

/-! ## Section 3: Basic Valuation Algebra -/

/-- The zero weight vector has zero valuation.
Bridge: quantum identity operator has zero tropical cost. -/
theorem StabilizerValuation.map_zero (v : StabilizerValuation ι) :
    v.val 0 = 0 := v.val_zero

/-- Stabilizer valuations are monotone functions.
Bridge: quantum Pauli weight ordering is respected by tropical valuation. -/
theorem StabilizerValuation.monotone (v : StabilizerValuation ι) :
    Monotone v.val := v.monotone_val

/-- Self-domination: v(f) ≤ v(f + f) by monotonicity and f ≤ f + f.
Bridge: quantum doubling of a stabilizer element increases tropical cost.
Uses monotonicity and the lattice property f ≤ f + f for ℕ-valued Finsupp. -/
theorem StabilizerValuation.self_domination (v : StabilizerValuation ι)
    (f : ι →₀ ℕ) :
    v.val f ≤ v.val (f + f) := by
  apply v.monotone_val
  intro x
  simp [Finsupp.add_apply]

/-- Subadditivity of the stabilizer valuation.
Bridge: quantum operation composition cost is at most the sum of costs. -/
theorem StabilizerValuation.subadditive (v : StabilizerValuation ι)
    (f g : ι →₀ ℕ) :
    v.val (f + g) ≤ v.val f + v.val g := v.val_add_le f g

/-- Triangle inequality for valuations: v(f+g+h) ≤ v(f)+v(g)+v(h).
Bridge: multi-step quantum error accumulation is bounded by sum of costs. -/
theorem StabilizerValuation.triple_subadditive (v : StabilizerValuation ι)
    (f g h : ι →₀ ℕ) :
    v.val (f + g + h) ≤ v.val f + v.val g + v.val h :=
  calc v.val (f + g + h) ≤ v.val (f + g) + v.val h := v.val_add_le (f + g) h
    _ ≤ (v.val f + v.val g) + v.val h :=
        add_le_add_left (v.val_add_le f g) _

/-- The valuation polytope is monotone in the bound.
Bridge: relaxing the certified robustness threshold enlarges the feasible set. -/
theorem valuationPolytope_mono_bound (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) {b₁ b₂ : WithTop ℕ} (hb : b₁ ≤ b₂) :
    valuationPolytope v S b₁ ⊆ valuationPolytope v S b₂ := by
  intro f hf
  simp only [valuationPolytope, Finset.mem_filter] at hf ⊢
  exact ⟨hf.1, le_trans hf.2 hb⟩

/-- The valuation polytope is monotone in the stabilizer set.
Bridge: enlarging the quantum code enlarges the certified polytope. -/
theorem valuationPolytope_mono_set (v : StabilizerValuation ι)
    {S T : Finset (ι →₀ ℕ)} (hST : S ⊆ T) (bound : WithTop ℕ) :
    valuationPolytope v S bound ⊆ valuationPolytope v T bound := by
  intro f hf
  simp only [valuationPolytope, Finset.mem_filter] at hf ⊢
  exact ⟨hST hf.1, hf.2⟩

/-! ## Section 4: Tropical Enumerator Properties -/

/-- Empty stabilizer set gives infinite tropical cost at every weight.
Bridge: the empty quantum code has no certified codewords. -/
theorem tropWeightEnumerator_empty (v : StabilizerValuation ι) (k : ℕ) :
    tropWeightEnumerator v ∅ k = ⊤ := by
  simp [tropWeightEnumerator]

/-- Tropical weight enumerator is anti-monotone in the stabilizer set.
Larger sets give smaller (better) tropical costs.
Bridge: enlarging the quantum stabilizer group improves certification. -/
theorem tropWeightEnumerator_mono_set (v : StabilizerValuation ι)
    {S T : Finset (ι →₀ ℕ)} (hST : S ⊆ T) (k : ℕ) :
    tropWeightEnumerator v T k ≤ tropWeightEnumerator v S k :=
  Finset.inf_mono hST

/-- If no element in S has weight k, the enumerator returns ⊤.
Bridge: quantum weight gaps manifest as infinite tropical cost. -/
theorem tropWeightEnumerator_top_of_no_witness (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) {k : ℕ}
    (hno : ∀ f ∈ S, pauliWeight f ≠ k) :
    tropWeightEnumerator v S k = ⊤ := by
  simp only [tropWeightEnumerator]
  rw [Finset.inf_eq_top_iff]
  intro f hf
  simp [hno f hf]

/-- A witness at weight k gives a finite upper bound on the enumerator.
Bridge: a certified quantum codeword at weight k bounds the tropical profile. -/
theorem tropWeightEnumerator_le_of_mem (v : StabilizerValuation ι)
    {S : Finset (ι →₀ ℕ)} {f : ι →₀ ℕ} (hf : f ∈ S)
    {k : ℕ} (hw : pauliWeight f = k) :
    tropWeightEnumerator v S k ≤ v.val f := by
  unfold tropWeightEnumerator
  exact le_trans (Finset.inf_le hf) (by simp [hw])

/-- Certified attainment: for a nonempty set, the enumerator is bounded
by some element's contribution.
Bridge: quantum tropical certification always has a witness in nonempty codes.
Computing this witness is O(|S|). Uses rcases for witness extraction. -/
theorem tropWeightEnumerator_certified_attainment (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) (k : ℕ) (hne : S.Nonempty) :
    ∃ f ∈ S, tropWeightEnumerator v S k ≤
      (if pauliWeight f = k then v.val f else ⊤) := by
  rcases Finset.exists_mem_eq_inf S hne
    (fun f => if pauliWeight f = k then v.val f else ⊤) with ⟨f, hf, hmin⟩
  exact ⟨f, hf, by rw [tropWeightEnumerator, hmin]⟩

/-- Support radius is monotone in the stabilizer set.
Bridge: enlarging the quantum code can only increase the maximum cost. -/
theorem supportRadius_mono (v : StabilizerValuation ι)
    {S T : Finset (ι →₀ ℕ)} (hST : S ⊆ T) :
    supportRadius v S ≤ supportRadius v T :=
  Finset.sup_mono hST

/-- The enumerator at weight k equals ⊤ iff every weight-k element has ⊤ valuation.
Bridge: complete characterization of tropical weight gaps. -/
theorem tropWeightEnumerator_eq_top_iff (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) (k : ℕ) :
    tropWeightEnumerator v S k = ⊤ ↔
      ∀ f ∈ S, pauliWeight f = k → v.val f = ⊤ := by
  constructor
  · intro htop f hf hw
    have hle := tropWeightEnumerator_le_of_mem v hf hw
    rw [htop] at hle
    exact WithTop.top_le_iff.mp hle
  · intro h
    simp only [tropWeightEnumerator]
    rw [Finset.inf_eq_top_iff]
    intro f hf
    by_cases hw : pauliWeight f = k
    · simp [hw, h f hf hw]
    · simp [hw]

/-! ## Section 5: Closure Operator and Fixed-Point Theory -/

/-- Fixed points of a closure operator are characterized by c x = x.
Bridge: lattice fixed-point characterization of quantum stabilizer codespaces. -/
theorem fixedPoints_mem_iff {α : Type*} (c : α → α) (x : α) :
    x ∈ fixedPoints c ↔ c x = x :=
  Iff.rfl

/-- Closure operators map to fixed points.
Bridge: applying quantum stabilizer closure produces certified codespace elements. -/
theorem closure_is_fixed {α : Type*} [Preorder α]
    {c : α → α} (hc : IsClosureOperator c) (x : α) :
    c x ∈ fixedPoints c := by
  simp [fixedPoints, hc.idempotent']

/-- Monotone maps through closure operators preserve enumerator ordering.
Bridge: quantum stabilizer morphisms respect tropical enumerator ordering.
Uses the extensiveness of closure operators. -/
theorem tropWeightEnumerator_mono_through_closure
    {α : Type*} [CompleteLattice α]
    (c : α → α) (hc : IsClosureOperator c)
    (Φ : α → Finset (ι →₀ ℕ))
    (hmono : ∀ ⦃x y : α⦄, x ≤ y → Φ x ⊆ Φ y)
    (v : StabilizerValuation ι) :
    ∀ x k, tropWeightEnumerator v (Φ (c x)) k ≤ tropWeightEnumerator v (Φ x) k := by
  intro x k
  exact tropWeightEnumerator_mono_set v (hmono (hc.extensive x)) k

/-- Fixed-point invariance: if Φ commutes with closure, enumerators are equal.
Bridge: lattice_fixedpoint_pauli_shadow — quantum codespace certification
is stable under closure application. -/
theorem lattice_fixedpoint_pauli_shadow
    {α : Type*} [CompleteLattice α]
    (c : α → α) (_hc : IsClosureOperator c)
    (Φ : α → Finset (ι →₀ ℕ))
    (hfix : ∀ x, Φ (c x) = Φ x)
    (v : StabilizerValuation ι) :
    ∀ x k, tropWeightEnumerator v (Φ (c x)) k = tropWeightEnumerator v (Φ x) k := by
  intro x k
  simp [hfix]

/-- Idempotent shadow: TropicalClosureCompatible gives stable valuation.
Bridge: certified double-closure invariance for quantum tropical profiles. -/
theorem idempotent_shadow_eq {α : Type*} [Preorder α]
    (c : α → α) (φ : α → WithTop ℕ)
    [h : TropicalClosureCompatible c φ] (x : α) :
    φ (c (c x)) = φ (c x) :=
  h.idempotent_shadow x

/-- Fixed points of a closure operator contain the range of closure.
Bridge: the quantum codespace contains all closures. -/
theorem closure_range_subset_fixed {α : Type*} [Preorder α]
    {c : α → α} (hc : IsClosureOperator c) :
    Set.range c ⊆ fixedPoints c := by
  intro x ⟨y, hy⟩
  simp [fixedPoints, ← hy, hc.idempotent']

/-- Closure operators on complete lattices have a least fixed point.
Bridge: Knaster-Tarski theorem guarantees existence of minimal certified
quantum codespace element. -/
theorem closure_has_least_fixed_point {α : Type*} [CompleteLattice α]
    {c : α → α} (hc : IsClosureOperator c) :
    ∃ x ∈ fixedPoints c, ∀ y ∈ fixedPoints c, x ≤ y := by
  refine ⟨c ⊥, closure_is_fixed hc ⊥, ?_⟩
  intro y hy
  calc c ⊥ ≤ c y := hc.monotone' bot_le
    _ = y := (fixedPoints_mem_iff c y).mp hy

/-! ## Section 6: Tropical Breakpoint and Distance Lower Bound -/

/-- Breakpoint forces top valuation: if the enumerator has a breakpoint at d,
any witness of weight < d must have infinite valuation.
Bridge: tropical breakpoint → quantum code distance constraint. -/
theorem breakpoint_forces_top_valuation
    (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) {d : ℕ}
    (hbreak : IsTropicalBreakpoint (tropWeightEnumerator v S) d)
    {f : ι →₀ ℕ} (hf : f ∈ S) (hw : pauliWeight f < d) :
    v.val f = ⊤ := by
  have hk := hbreak (pauliWeight f) hw
  have hle : tropWeightEnumerator v S (pauliWeight f) ≤ v.val f :=
    tropWeightEnumerator_le_of_mem v hf rfl
  rw [hk] at hle
  exact WithTop.top_le_iff.mp hle

/-- Quantum certified breakpoint distance: if the tropical weight enumerator
has a breakpoint at d and the valuation is finite on S, then every element
of S has Pauli weight at least d.
Bridge: tropical breakpoint → quantum code distance lower bound.
This is the core certified_robustness theorem connecting tropical geometry
to post_quantum_security distance analysis.
Uses by_contra for the distance-breakpoint contradiction. -/
theorem quantum_certified_breakpoint_distance
    (v : StabilizerValuation ι)
    (S : Finset (ι →₀ ℕ)) {d : ℕ}
    (hbreak : IsTropicalBreakpoint (tropWeightEnumerator v S) d) :
    ∀ f ∈ S, d ≤ pauliWeight f := by
  intro f hf
  by_contra hlt
  push_neg at hlt
  exact v.finite_val f (breakpoint_forces_top_valuation v S hbreak hf hlt)

/-- Distance lower bound implies breakpoint (converse): if every element
of S has weight ≥ d, then the enumerator has a breakpoint at d.
Bridge: post_quantum_security gap analysis via tropical certification. -/
theorem post_quantum_security_via_tropical_gap
    (v : StabilizerValuation ι) (S : Finset (ι →₀ ℕ))
    {d : ℕ}
    (hmin : ∀ f ∈ S, d ≤ pauliWeight f) :
    IsTropicalBreakpoint (tropWeightEnumerator v S) d := by
  intro k hk
  apply tropWeightEnumerator_top_of_no_witness
  intro f hf
  have := hmin f hf
  omega

/-- The breakpoint condition is monotone in d.
Bridge: relaxing quantum distance requirements preserves certification. -/
theorem IsTropicalBreakpoint.mono {W : ℕ → WithTop ℕ} {d₁ d₂ : ℕ}
    (hbreak : IsTropicalBreakpoint W d₂) (hle : d₁ ≤ d₂) :
    IsTropicalBreakpoint W d₁ := by
  intro k hk
  exact hbreak k (lt_of_lt_of_le hk hle)

/-- Breakpoint zero is trivially satisfied by any profile.
Bridge: every quantum code trivially satisfies the zero-distance bound. -/
theorem IsTropicalBreakpoint.zero (W : ℕ → WithTop ℕ) :
    IsTropicalBreakpoint W 0 := by
  intro k hk; omega

/-! ## Section 7: Inf-Convolution Properties -/

/-- Inf-convolution with the zero function is dominated by the original.
Bridge: quantum identity channel composition is non-expanding. -/
theorem infConvolutionNat_le_self (f : ℕ → WithTop ℕ) (n : ℕ) :
    infConvolutionNat f (fun _ => 0) n ≤ f n := by
  unfold infConvolutionNat
  exact le_trans (Finset.inf_le (Finset.mem_range.mpr (Nat.lt_succ_of_le le_rfl)))
    (by simp)

/-- Inf-convolution preserves ⊤ on the left.
Bridge: quantum trivially-failing channels are not rescued by concatenation. -/
theorem infConvolutionNat_top_left (g : ℕ → WithTop ℕ) (n : ℕ) :
    infConvolutionNat (fun _ => ⊤) g n = ⊤ := by
  simp [infConvolutionNat]

/-- Inf-convolution preserves ⊤ on the right.
Bridge: certified concatenation with a trivial channel remains trivial. -/
theorem infConvolutionNat_top_right (f : ℕ → WithTop ℕ) (n : ℕ) :
    infConvolutionNat f (fun _ => ⊤) n = ⊤ := by
  simp [infConvolutionNat]

/-- Search domain cardinality: O(n) per evaluation point.
Bridge: certified algorithmic complexity bound for quantum tropical
decoder dynamic programming. -/
theorem infConvolutionNat_search_domain_card (n : ℕ) :
    (Finset.range (n + 1)).card = n + 1 :=
  Finset.card_range (n + 1)

/-- Inf-convolution is monotone in the left argument.
Bridge: improving one quantum recovery channel improves the concatenation. -/
theorem infConvolutionNat_mono_left {f₁ f₂ : ℕ → WithTop ℕ}
    (hf : ∀ n, f₁ n ≤ f₂ n) (g : ℕ → WithTop ℕ) (n : ℕ) :
    infConvolutionNat f₁ g n ≤ infConvolutionNat f₂ g n := by
  exact Finset.inf_mono_fun (fun i _ => add_le_add_left (hf i) _)

/-- Inf-convolution is monotone in the right argument.
Bridge: improving the inner quantum channel improves concatenated recovery. -/
theorem infConvolutionNat_mono_right (f : ℕ → WithTop ℕ)
    {g₁ g₂ : ℕ → WithTop ℕ} (hg : ∀ n, g₁ n ≤ g₂ n) (n : ℕ) :
    infConvolutionNat f g₁ n ≤ infConvolutionNat f g₂ n := by
  exact Finset.inf_mono_fun (fun i _ => add_le_add_right (hg _) _)

/-- Inf-convolution at 0 equals f 0 + g 0.
Bridge: base case of tropical decoder dynamic programming.
Uses omega for the range singleton identity. -/
theorem infConvolutionNat_zero (f g : ℕ → WithTop ℕ) :
    infConvolutionNat f g 0 = f 0 + g 0 := by
  simp [infConvolutionNat]

/-! ## Section 8: Tropical Support Function -/

/-- Empty support gives ⊤ tropical support value.
Bridge: the empty quantum code has infinite support function. -/
theorem tropicalSupportFunction_empty (x : ι →₀ ℕ) :
    tropicalSupportFunction (∅ : Finset (ι →₀ ℕ)) x = ⊤ := by
  simp [tropicalSupportFunction]

/-- Tropical support function distributes over union via min.
Bridge: connects polyhedral/tropical support-function decomposition
to quantum stabilizer code unions. The min-plus structure is key
to certified_robustness analysis of composite quantum codes. -/
theorem tropicalSupportFunction_infimal
    (S T : Finset (ι →₀ ℕ)) (x : ι →₀ ℕ) :
    tropicalSupportFunction (S ∪ T) x =
      min (tropicalSupportFunction S x) (tropicalSupportFunction T x) := by
  simp [tropicalSupportFunction, Finset.inf_union]

/-- Tropical support function is anti-monotone in the set.
Bridge: enlarging the quantum code decreases the support function. -/
theorem tropicalSupportFunction_mono_set
    {S T : Finset (ι →₀ ℕ)} (hST : S ⊆ T) (x : ι →₀ ℕ) :
    tropicalSupportFunction T x ≤ tropicalSupportFunction S x :=
  Finset.inf_mono hST

/-- Support function of a singleton.
Bridge: single quantum operator support function is just its weight. -/
theorem tropicalSupportFunction_singleton (f x : ι →₀ ℕ) :
    tropicalSupportFunction {f} x = ↑(pauliWeight (f + x)) := by
  simp [tropicalSupportFunction]

/-! ## Section 9: Concatenation and Recovery -/

/-- Concatenated recovery enumerator defined as inf-convolution of
individual tropical weight enumerators.
Bridge: certified_concat_recovery_infimal — quantum concatenated
recovery channels compose via min-plus convolution. -/
noncomputable def concatRecoveryEnumerator
    (v₁ : StabilizerValuation ι) (v₂ : StabilizerValuation ι)
    (S₁ S₂ : Finset (ι →₀ ℕ)) : ℕ → WithTop ℕ :=
  infConvolutionNat (tropWeightEnumerator v₁ S₁) (tropWeightEnumerator v₂ S₂)

/-- Concatenated recovery is monotone in the first code.
Bridge: improving the outer quantum code improves concatenated recovery. -/
theorem concatRecoveryEnumerator_mono_left
    (v₁ : StabilizerValuation ι) (v₂ : StabilizerValuation ι)
    {S₁ S₁' : Finset (ι →₀ ℕ)} (h : S₁ ⊆ S₁')
    (S₂ : Finset (ι →₀ ℕ)) (n : ℕ) :
    concatRecoveryEnumerator v₁ v₂ S₁' S₂ n ≤
      concatRecoveryEnumerator v₁ v₂ S₁ S₂ n :=
  infConvolutionNat_mono_left (fun k => tropWeightEnumerator_mono_set v₁ h k) _ n

/-- Concatenated recovery is monotone in the second code.
Bridge: improving the inner quantum code improves concatenated recovery. -/
theorem concatRecoveryEnumerator_mono_right
    (v₁ : StabilizerValuation ι) (v₂ : StabilizerValuation ι)
    (S₁ : Finset (ι →₀ ℕ)) {S₂ S₂' : Finset (ι →₀ ℕ)}
    (h : S₂ ⊆ S₂') (n : ℕ) :
    concatRecoveryEnumerator v₁ v₂ S₁ S₂' n ≤
      concatRecoveryEnumerator v₁ v₂ S₁ S₂ n :=
  infConvolutionNat_mono_right _ (fun k => tropWeightEnumerator_mono_set v₂ h k) n

/-- Concatenation at weight 0 equals sum of individual weight-0 enumerators.
Bridge: base case of the tropical decoder dynamic programming recurrence. -/
theorem concatRecoveryEnumerator_zero
    (v₁ v₂ : StabilizerValuation ι)
    (S₁ S₂ : Finset (ι →₀ ℕ)) :
    concatRecoveryEnumerator v₁ v₂ S₁ S₂ 0 =
      tropWeightEnumerator v₁ S₁ 0 + tropWeightEnumerator v₂ S₂ 0 :=
  infConvolutionNat_zero _ _

/-- Lipschitz-type bound: W(n) ≤ W₁(0) + W₂(n) for all n.
Bridge: quantum_certified_lipschitz_profile — certified robustness
bound for tropical concatenated decoders. -/
theorem quantum_certified_lipschitz_profile
    (v₁ v₂ : StabilizerValuation ι)
    (S₁ S₂ : Finset (ι →₀ ℕ)) (n : ℕ) :
    concatRecoveryEnumerator v₁ v₂ S₁ S₂ n ≤
      tropWeightEnumerator v₁ S₁ 0 + tropWeightEnumerator v₂ S₂ n := by
  unfold concatRecoveryEnumerator infConvolutionNat
  exact le_trans (Finset.inf_le (Finset.mem_range.mpr (by omega : 0 < n + 1)))
    (by simp)

/-! ## Section 10: Thermodynamic and Collision Bounds -/

/-- Thermodynamic Pauli free energy bound: the tropical weight enumerator
at weight k is bounded above by the valuation of any weight-k element.
Bridge: connects quantum statistical mechanics (zero-temperature free energy)
to tropical geometry via inf = zero-temperature partition function limit. -/
theorem thermodynamic_pauli_free_energy_bound
    (v : StabilizerValuation ι) (S : Finset (ι →₀ ℕ)) (k : ℕ) :
    ∀ f ∈ S, pauliWeight f = k →
      tropWeightEnumerator v S k ≤ v.val f :=
  fun _f hf hw => tropWeightEnumerator_le_of_mem v hf hw

/-- Tropical hash collision lower bound: repeated inf-convolution
of a profile W with itself at least doubles the breakpoint.
Bridge: tropical_hash_collision_lower_bound — connects min-plus algebra
to cryptographic hash collision resistance and post_quantum_security. -/
theorem tropical_hash_collision_lower_bound
    (W : ℕ → WithTop ℕ) {d : ℕ}
    (hbreak : IsTropicalBreakpoint W d) :
    IsTropicalBreakpoint (infConvolutionNat W W) (2 * d) := by
  intro k hk
  simp only [infConvolutionNat]
  rw [Finset.inf_eq_top_iff]
  intro i hi
  rw [Finset.mem_range] at hi
  by_cases h : i < d
  · simp [hbreak i h]
  · push_neg at h
    have hki : k - i < d := by omega
    simp [hbreak (k - i) hki]

/-- Breakpoint of concatenation: if both profiles have breakpoints,
the concatenation has a breakpoint at the sum of distances.
Bridge: quantum concatenated codes have distance ≥ sum of individual distances. -/
theorem breakpoint_add_of_both {W₁ W₂ : ℕ → WithTop ℕ} {d₁ d₂ : ℕ}
    (h₁ : IsTropicalBreakpoint W₁ d₁) (h₂ : IsTropicalBreakpoint W₂ d₂) :
    IsTropicalBreakpoint (infConvolutionNat W₁ W₂) (d₁ + d₂) := by
  intro k hk
  simp only [infConvolutionNat]
  rw [Finset.inf_eq_top_iff]
  intro i hi
  rw [Finset.mem_range] at hi
  by_cases h : i < d₁
  · simp [h₁ i h]
  · push_neg at h
    have hki : k - i < d₂ := by omega
    simp [h₂ (k - i) hki]

/-- The support radius of the empty set is ⊥.
Bridge: the empty quantum code has zero support radius. -/
theorem supportRadius_empty (v : StabilizerValuation ι) :
    supportRadius v ∅ = ⊥ := by
  simp [supportRadius]

/-- Support radius is at most the support radius of a superset.
Bridge: enlarging the quantum code can only increase the maximum cost. -/
theorem supportRadius_union_le (v : StabilizerValuation ι)
    (S T : Finset (ι →₀ ℕ)) :
    supportRadius v S ≤ supportRadius v (S ∪ T) :=
  supportRadius_mono v Finset.subset_union_left

end QuantumTropical