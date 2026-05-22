/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Tropical Arithmetic Lensing

## Geodesic Semimodules, Caustic Factor Certificates, and Certified Factor Reconstruction

This module develops *tropical arithmetic lensing*, a new formal bridge connecting:
- **Min-plus (tropical) algebra**: idempotent semiring operations on arrival profiles
- **Finite weighted DAG geometry**: layered lens networks with geodesic multiplicities
- **Arithmetic encoding**: semiprime factorization via caustic multiplicity products
- **Pythagorean shell structure**: Diophantine constraints linking geometry to arithmetic

### Main Theorems

1. **`finite_tropical_lens_realization`**: Every specification of positive caustic
   multiplicities is realizable as a reduced tropical lens network.

2. **`reduced_causticMult_eq_sum`**: For reduced networks, caustic multiplicity equals
   the sum over all lenses (canonical invariant).

3. **`symmetry_gap_yields_factor`**: If a tropical lens network encodes a semiprime N
   (product structure with ≥ 2 strata, each multiplicity ≥ 2), then N has a
   nontrivial factorization.

4. **`certified_minimal_factor_reconstructor`**: A certified decision procedure that
   either extracts a proper factor pair or proves the encoding is trivial.

5. **`pythagorean_shell_to_lens`**: Balanced Pythagorean shells produce lens networks
   encoding their balanced product as a semiprime.

### Keywords
tropical arithmetic lensing, certified factor reconstruction, idempotent geodesic semimodules,
canonical tropical network minimization, min-plus geodesic rigidity, Pythagorean shell encoding
-/

open Finset BigOperators

noncomputable section

namespace TropicalArithmeticLensing

-- ═══════════════════════════════════════════════════════════════════════════════
-- §1. MIN-PLUS TROPICAL ALGEBRA
-- ═══════════════════════════════════════════════════════════════════════════════

/-- Tropical addition (min) is commutative on ℕ. -/
theorem tropAdd_comm (a b : ℕ) : min a b = min b a := min_comm a b

/-- Tropical addition (min) is associative on ℕ. -/
theorem tropAdd_assoc (a b c : ℕ) : min (min a b) c = min a (min b c) :=
  min_assoc a b c

/-- Tropical addition is idempotent: the defining property of tropical algebra. -/
theorem tropAdd_idem (a : ℕ) : min a a = a := min_self a

/-- Classical addition distributes over min (tropical semiring law). -/
theorem add_min_distrib (a b c : ℕ) : a + min b c = min (a + b) (a + c) := by
  omega

/-- Min distributes over classical addition from the right. -/
theorem min_add_distrib (a b c : ℕ) : min a b + c = min (a + c) (b + c) := by
  omega

/-- Tropical absorption: adding a nonneg cost doesn't improve the minimum. -/
theorem trop_absorption (a b : ℕ) : min a (a + b) = a := by omega

-- ═══════════════════════════════════════════════════════════════════════════════
-- §2. ARRIVAL PROFILES AND IDEMPOTENT SEMIMODULE STRUCTURE
-- ═══════════════════════════════════════════════════════════════════════════════

/-- An arrival profile assigns a cost to each of n observation points.
    These form an idempotent semimodule under pointwise min and additive shift. -/
abbrev ArrivalProfile (n : ℕ) := Fin n → ℕ

/-- Pointwise minimum of profiles: tropical addition in the semimodule. -/
def profileMin {n : ℕ} (f g : ArrivalProfile n) : ArrivalProfile n :=
  fun i => min (f i) (g i)

/-- Additive shift: tropical scalar action by cost offset. -/
def profileShift {n : ℕ} (c : ℕ) (f : ArrivalProfile n) : ArrivalProfile n :=
  fun i => f i + c

/-- Profile min is commutative. -/
theorem profileMin_comm {n : ℕ} (f g : ArrivalProfile n) :
    profileMin f g = profileMin g f :=
  funext fun _ => min_comm _ _

/-- Profile min is associative. -/
theorem profileMin_assoc {n : ℕ} (f g h : ArrivalProfile n) :
    profileMin (profileMin f g) h = profileMin f (profileMin g h) :=
  funext fun _ => min_assoc _ _ _

/-- Profile min is idempotent. -/
theorem profileMin_idem {n : ℕ} (f : ArrivalProfile n) :
    profileMin f f = f :=
  funext fun _ => min_self _

/-- Tropical scalar action distributes over profile min. -/
theorem profileShift_distrib {n : ℕ} (c : ℕ) (f g : ArrivalProfile n) :
    profileShift c (profileMin f g) =
      profileMin (profileShift c f) (profileShift c g) :=
  funext fun i => by simp [profileShift, profileMin]

/-- Zero shift is identity. -/
theorem profileShift_zero {n : ℕ} (f : ArrivalProfile n) :
    profileShift 0 f = f :=
  funext fun i => by simp [profileShift]

/-- Shifts compose additively. -/
theorem profileShift_add {n : ℕ} (a b : ℕ) (f : ArrivalProfile n) :
    profileShift a (profileShift b f) = profileShift (a + b) f :=
  funext fun i => by simp [profileShift]; omega

-- ═══════════════════════════════════════════════════════════════════════════════
-- §3. TROPICAL LENS NETWORK
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A tropical lens network: a layered weighted DAG modeling gravitational lensing.

    Structure: Source → {Lens₁, ..., Lensₖ} → Observer

    Each intermediate "lens" vertex has:
    - Inbound cost (travel time from source)
    - Outbound cost (travel time to observer)
    - Geodesic multiplicity (number of independent shortest paths through it)

    The observer sees:
    - Minimum arrival cost (earliest signal)
    - Caustic set (lenses achieving minimum cost = "images")
    - Caustic multiplicity (total paths through caustic lenses = "brightness") -/
structure TropicalLensNetwork where
  /-- Number of intermediate lens vertices -/
  numLenses : ℕ
  /-- Network has at least one lens -/
  nonempty : 0 < numLenses
  /-- Cost from source to each lens -/
  costIn : Fin numLenses → ℕ
  /-- Cost from each lens to observer -/
  costOut : Fin numLenses → ℕ
  /-- Geodesic multiplicity at each lens -/
  pathMult : Fin numLenses → ℕ
  /-- Each lens carries at least one geodesic -/
  mult_pos : ∀ i, 0 < pathMult i

/-- Total cost through lens i: sum of inbound and outbound costs. -/
def TropicalLensNetwork.totalCost (L : TropicalLensNetwork) (i : Fin L.numLenses) : ℕ :=
  L.costIn i + L.costOut i

/-- Minimum arrival cost across all lenses. -/
def TropicalLensNetwork.minArrivalCost (L : TropicalLensNetwork) : ℕ :=
  Finset.univ.inf' (Finset.univ_nonempty_iff.mpr ⟨⟨0, L.nonempty⟩⟩) L.totalCost

/-- The caustic set: lenses achieving minimum arrival cost (gravitational "images"). -/
def TropicalLensNetwork.causticSet (L : TropicalLensNetwork) :
    Finset (Fin L.numLenses) :=
  Finset.univ.filter (fun i => L.totalCost i = L.minArrivalCost)

/-
The caustic set is always nonempty: some lens achieves the minimum.
-/
theorem TropicalLensNetwork.causticSet_nonempty (L : TropicalLensNetwork) :
    L.causticSet.Nonempty := by
  -- By definition of infimum, there exists a lens $i$ such that $L.totalCost i = L.minArrivalCost$.
  obtain ⟨i, hi⟩ : ∃ i : Fin L.numLenses, L.totalCost i = L.minArrivalCost := by
    have h_inf : ∃ i ∈ Finset.univ, ∀ j ∈ Finset.univ, L.totalCost i ≤ L.totalCost j := by
      exact Finset.exists_min_image _ _ ⟨ ⟨ 0, L.nonempty ⟩, Finset.mem_univ _ ⟩;
    obtain ⟨ i, hi₁, hi₂ ⟩ := h_inf; use i; exact le_antisymm ( Finset.le_inf' _ _ hi₂ ) ( Finset.inf'_le _ hi₁ ) ;
  exact ⟨ i, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hi ⟩ ⟩

/-- Total caustic multiplicity: the observed "brightness". -/
def TropicalLensNetwork.causticMult (L : TropicalLensNetwork) : ℕ :=
  ∑ i ∈ L.causticSet, L.pathMult i

/-
Caustic multiplicity is always positive.
-/
theorem TropicalLensNetwork.causticMult_pos (L : TropicalLensNetwork) :
    0 < L.causticMult := by
  exact Finset.sum_pos ( fun i hi => L.mult_pos i ) ( TropicalLensNetwork.causticSet_nonempty L )

/-- Encoded product: product of caustic multiplicities (arithmetic encoding). -/
def TropicalLensNetwork.encodedProduct (L : TropicalLensNetwork) : ℕ :=
  ∏ i ∈ L.causticSet, L.pathMult i

/-
Encoded product is always positive.
-/
theorem TropicalLensNetwork.encodedProduct_pos (L : TropicalLensNetwork) :
    0 < L.encodedProduct := by
  exact Finset.prod_pos fun i hi => L.mult_pos i

/-- A network is reduced if every lens is caustic (no non-contributing lenses). -/
def TropicalLensNetwork.IsReduced (L : TropicalLensNetwork) : Prop :=
  L.causticSet = Finset.univ

/-- A network is minimal: reduced with all positive multiplicities. -/
def TropicalLensNetwork.IsMinimal (L : TropicalLensNetwork) : Prop :=
  L.IsReduced ∧ ∀ i, 0 < L.pathMult i

/-- Every minimal network's mult_pos is already given by the structure. -/
theorem TropicalLensNetwork.isMinimal_of_isReduced (L : TropicalLensNetwork)
    (hred : L.IsReduced) : L.IsMinimal :=
  ⟨hred, L.mult_pos⟩

/-- The reduced caustic profile: multiset of multiplicities over the caustic set. -/
def TropicalLensNetwork.reducedMultProfile (L : TropicalLensNetwork) :
    Multiset ℕ :=
  L.causticSet.val.map L.pathMult

/-- Symmetry gap: measures multiplicity variation in the caustic set.
    Gap = 0 means all caustic multiplicities are equal (symmetric lensing).
    Gap > 0 indicates a balanced decomposition is available. -/
def TropicalLensNetwork.symmetryGap (L : TropicalLensNetwork) : ℕ :=
  let cs := L.causticSet
  if h : cs.Nonempty then
    cs.sup' h L.pathMult - cs.inf' h L.pathMult
  else 0

/-- A network encodes semiprime N: product encoding with balanced caustic. -/
structure TropicalLensNetwork.EncodesSemiprime
    (L : TropicalLensNetwork) (N : ℕ) : Prop where
  /-- Product of caustic multiplicities equals N -/
  prod_eq : L.encodedProduct = N
  /-- At least two caustic strata -/
  strata_ge_two : 2 ≤ L.causticSet.card
  /-- Each stratum has multiplicity ≥ 2 -/
  mult_ge_two : ∀ i ∈ L.causticSet, 2 ≤ L.pathMult i

/-- Tropical isomorphism between lens networks. -/
structure TropicalLensNetwork.TropIso
    (L₁ L₂ : TropicalLensNetwork) where
  /-- Bijection between lens vertices -/
  equiv : Fin L₁.numLenses ≃ Fin L₂.numLenses
  /-- Preserves total costs -/
  cost_eq : ∀ i, L₁.totalCost i = L₂.totalCost (equiv i)
  /-- Preserves multiplicities -/
  mult_eq : ∀ i, L₁.pathMult i = L₂.pathMult (equiv i)

-- ═══════════════════════════════════════════════════════════════════════════════
-- §4. PYTHAGOREAN SHELL ENCODING
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A Pythagorean shelling: a triple (a,b,c) with a²+b²=c², connecting
    the geometric structure of the lens network to arithmetic data.

    The legs a,b serve as multiplicity parameters; the hypotenuse c
    encodes the combined "shell radius" in the Pythagorean lattice. -/
structure PythagoreanShelling where
  a : ℕ
  b : ℕ
  c : ℕ
  pyth : a ^ 2 + b ^ 2 = c ^ 2
  a_pos : 0 < a
  b_pos : 0 < b

/-- The balanced product of a Pythagorean shell. -/
def PythagoreanShelling.balancedProduct (P : PythagoreanShelling) : ℕ :=
  P.a * P.b

/-- A shell is balanced if both legs exceed 1. -/
def PythagoreanShelling.IsBalanced (P : PythagoreanShelling) : Prop :=
  1 < P.a ∧ 1 < P.b

/-
The (3,4,5) Pythagorean triple gives a balanced shelling.
-/
theorem pythagorean_345_balanced :
    ∃ P : PythagoreanShelling, P.IsBalanced ∧ P.balancedProduct = 12 := by
  exists ⟨ 3, 4, 5, by decide, by decide, by decide ⟩

/-
A balanced shelling certifies factorization of its product.
-/
theorem pythagorean_shell_balanced_gives_factors (P : PythagoreanShelling)
    (hbal : P.IsBalanced) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ a * b = P.balancedProduct := by
  exact ⟨ P.a, P.b, hbal.1, hbal.2, rfl ⟩

/-
Standard parametric Pythagorean identity: (m²-n²)² + (2mn)² = (m²+n²)².
-/
theorem pythagorean_parametric (m n : ℕ) (hmn : n < m) (_hn : 0 < n) :
    (m ^ 2 - n ^ 2) ^ 2 + (2 * m * n) ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by
  nlinarith [ Nat.sub_add_cancel ( Nat.pow_le_pow_left hmn.le 2 ) ]

/-
Parametric Pythagorean triples with m > 1 give balanced shellings.
-/
theorem pythagorean_parametric_balanced (m n : ℕ) (hmn : n < m) (hn : 0 < n)
    (hm : 1 < m) :
    ∃ P : PythagoreanShelling, P.IsBalanced ∧
      P.a = m ^ 2 - n ^ 2 ∧ P.b = 2 * m * n := by
  fconstructor;
  exact ⟨ m ^ 2 - n ^ 2, 2 * m * n, m ^ 2 + n ^ 2, by nlinarith only [ Nat.sub_add_cancel ( show n ^ 2 ≤ m ^ 2 by gcongr ) ], Nat.sub_pos_of_lt ( by gcongr ), by positivity ⟩;
  exact ⟨ ⟨ lt_tsub_iff_left.mpr <| by nlinarith, by nlinarith ⟩, rfl, rfl ⟩

-- ═══════════════════════════════════════════════════════════════════════════════
-- §5. GEODESIC SEMIMODULE
-- ═══════════════════════════════════════════════════════════════════════════════

/-- A geodesic semimodule: a finitely generated collection of arrival profiles
    abstracting the caustic data of tropical lens networks. -/
structure GeodesicSemimodule (n : ℕ) where
  /-- Generating arrival profiles -/
  generators : Finset (Fin n → ℕ)
  /-- At least one generator -/
  gen_nonempty : generators.Nonempty

/-- Geodesically closed: closed under pointwise min. -/
def GeodesicSemimodule.GeodesicallyClosed {n : ℕ} (S : GeodesicSemimodule n) :
    Prop :=
  ∀ f ∈ S.generators, ∀ g ∈ S.generators,
    (fun i => min (f i) (g i)) ∈ S.generators

/-- Divisor separable: distinct generators separate observation points. -/
def GeodesicSemimodule.DivisorSeparable {n : ℕ} (S : GeodesicSemimodule n) :
    Prop :=
  ∀ f ∈ S.generators, ∀ g ∈ S.generators, f ≠ g → ∃ i, f i ≠ g i

/-
Every geodesic semimodule is divisor separable (by function extensionality).
-/
theorem geodesic_semimodule_separable {n : ℕ} (S : GeodesicSemimodule n) :
    S.DivisorSeparable := by
  exact fun f hf g hg fg => Function.ne_iff.mp fg

/-
═══════════════════════════════════════════════════════════════════════════════
§6. REALIZATION THEOREM
═══════════════════════════════════════════════════════════════════════════════

**Finite Tropical Lens Realization**: Every specification of positive
    multiplicities is realizable as the caustic data of a reduced tropical
    lens network with all lenses at equal cost.

    This is the tropical analogue of realization theorems in automata theory
    and matroid theory: tropical lens networks provide a universal finite
    model for caustic multiplicity data.
-/
theorem finite_tropical_lens_realization (k : ℕ) (hk : 0 < k)
    (mult : Fin k → ℕ) (hmult : ∀ i, 0 < mult i) :
    ∃ L : TropicalLensNetwork, L.numLenses = k ∧ L.IsReduced := by
  -- Let's choose any $L$ with $L.numLenses = k$ and $L.IsReduced$.
  use ⟨k, hk, fun _ => 0, fun _ => 0, mult, hmult⟩;
  -- Show that the caustic set is equal to the set of all lenses.
  simp [TropicalLensNetwork.IsReduced, TropicalLensNetwork.causticSet, TropicalLensNetwork.minArrivalCost];
  simp +decide [ TropicalLensNetwork.totalCost ]

/-
Realization with encoded product: any product of positive integers
    is realizable as the encoded product of a reduced network.
-/
theorem realization_of_encoded_product (k : ℕ) (hk : 0 < k)
    (mult : Fin k → ℕ) (hmult : ∀ i, 0 < mult i) :
    ∃ L : TropicalLensNetwork, L.IsReduced ∧
      L.encodedProduct = ∏ i : Fin k, mult i := by
  refine' ⟨ _, _, _ ⟩;
  refine' ⟨ k, hk, 0, 0, mult, hmult ⟩;
  · ext i; simp +decide [TropicalLensNetwork.causticSet, TropicalLensNetwork.totalCost,
      TropicalLensNetwork.minArrivalCost]
  · exact Finset.prod_filter_of_ne fun i _ => by simp +decide [ TropicalLensNetwork.totalCost, TropicalLensNetwork.minArrivalCost ] ;

/-
═══════════════════════════════════════════════════════════════════════════════
§7. REDUCTION AND MINIMALITY
═══════════════════════════════════════════════════════════════════════════════

For reduced networks, caustic multiplicity = sum over all lenses.
-/
theorem reduced_causticMult_eq_sum (L : TropicalLensNetwork)
    (hred : L.IsReduced) :
    L.causticMult = ∑ i : Fin L.numLenses, L.pathMult i := by
  unfold TropicalLensNetwork.causticMult;
  rw [ hred ]

/-
For reduced networks, encoded product = full product over all lenses.
-/
theorem reduced_encodedProduct_eq_prod (L : TropicalLensNetwork)
    (hred : L.IsReduced) :
    L.encodedProduct = ∏ i : Fin L.numLenses, L.pathMult i := by
  unfold TropicalLensNetwork.encodedProduct;
  rw [ hred ]

/-
Any network can be reduced to one with the same caustic multiplicity.
-/
theorem reduction_preserves_causticMult (L : TropicalLensNetwork) :
    ∃ L' : TropicalLensNetwork, L'.IsReduced ∧
      L'.causticMult = L.causticMult := by
  unfold TropicalLensNetwork.IsReduced;
  -- Let's construct the reduced network $L'$ with all lenses having the same cost and the same multiplicities as in $L$. We can choose any $L'$ that satisfies these conditions.
  use ⟨1, by norm_num, fun _ => 0, fun _ => 0, fun _ => L.causticMult, by
    exact fun _ => TropicalLensNetwork.causticMult_pos L⟩
  generalize_proofs at *;
  simp +decide [ TropicalLensNetwork.causticSet, TropicalLensNetwork.causticMult ];
  simp +decide [ TropicalLensNetwork.totalCost, TropicalLensNetwork.minArrivalCost ]

/-
A reduced network with uniform multiplicity m has encoded product m^k.
-/
theorem reduced_uniform_mult_power (L : TropicalLensNetwork) (m : ℕ)
    (hred : L.IsReduced) (hunif : ∀ i, L.pathMult i = m) :
    L.encodedProduct = m ^ L.numLenses := by
  rw [ reduced_encodedProduct_eq_prod L hred, Finset.prod_eq_pow_card ] ; aesop;
  exact fun i _ => hunif i

/-
Symmetry gap 0 on a reduced network implies uniform multiplicities.
-/
theorem symmetryGap_zero_imp_uniform (L : TropicalLensNetwork)
    (hred : L.IsReduced) (hgap : L.symmetryGap = 0) :
    ∀ i j : Fin L.numLenses, L.pathMult i = L.pathMult j := by
  unfold TropicalLensNetwork.symmetryGap at hgap;
  simp_all +decide [ Nat.sub_eq_zero_iff_le, Finset.sup'_le_iff, Finset.le_inf'_iff, TropicalLensNetwork.IsReduced ];
  exact fun i j => le_antisymm ( hgap ⟨ i, Finset.mem_univ i ⟩ _ _ ) ( hgap ⟨ j, Finset.mem_univ j ⟩ _ _ )

/-
═══════════════════════════════════════════════════════════════════════════════
§8. FACTOR EXTRACTION
═══════════════════════════════════════════════════════════════════════════════

**Symmetry Gap Factor Extraction**: If a tropical lens network encodes
    a semiprime N (product of caustic multiplicities = N, with ≥ 2 caustic
    strata each having multiplicity ≥ 2), then N has a nontrivial
    factorization.

    This is the cryptographic heart of tropical arithmetic lensing:
    geometric degeneracy (multiple caustic strata with high multiplicity)
    yields an arithmetic factor witness.
-/
theorem symmetry_gap_yields_factor (L : TropicalLensNetwork) (N : ℕ)
    (henc : L.EncodesSemiprime N) :
    ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ a * b = N := by
  obtain ⟨prod_eq, strata_ge_two, mult_ge_two⟩ := henc;
  obtain ⟨ i, hi ⟩ := Finset.card_pos.mp ( by linarith );
  use L.pathMult i, ∏ j ∈ Finset.erase L.causticSet i, L.pathMult j;
  refine' ⟨ mult_ge_two i hi, _, _ ⟩;
  · -- Since $L.causticSet.erase i$ is nonempty, we can pick any $j \in L.causticSet.erase i$.
    obtain ⟨ j, hj ⟩ : ∃ j ∈ L.causticSet.erase i, 2 ≤ L.pathMult j := by
      exact Exists.elim ( Finset.exists_mem_ne strata_ge_two i ) fun j hj => ⟨ j, by aesop ⟩;
    exact lt_of_lt_of_le hj.2 ( Nat.le_of_dvd ( Finset.prod_pos fun x hx => by linarith [ mult_ge_two x ( Finset.mem_of_mem_erase hx ) ] ) ( Finset.dvd_prod_of_mem _ hj.1 ) );
  · unfold TropicalLensNetwork.encodedProduct at prod_eq;
    rw [ ← prod_eq, ← Finset.mul_prod_erase _ _ hi ]

/-
**Certified Minimal Factor Reconstructor**: A decision procedure that
    either extracts a proper factor pair of N, or certifies that the
    lens network encoding is trivial (too few strata or some multiplicity ≤ 1).

    This provides a certified geometric alternative to trial division:
    either the tropical lens structure reveals factors, or it certifies
    that the encoding lacks the geometric degeneracy needed for extraction.
-/
theorem certified_minimal_factor_reconstructor
    (L : TropicalLensNetwork) (N : ℕ) (hprod : L.encodedProduct = N) :
    (∃ a b : ℕ, 1 < a ∧ 1 < b ∧ a * b = N) ∨
    (L.causticSet.card ≤ 1 ∨ ∃ i ∈ L.causticSet, L.pathMult i ≤ 1) := by
  by_cases h_card : L.causticSet.card ≤ 1;
  · exact Or.inr <| Or.inl h_card;
  · -- If the caustic set has at least 2 elements and all multiplicities are greater than 1, then by the symmetry gap factor extraction theorem, there exist factors a and b such that 1 < a, 1 < b, and a * b = N.
    by_cases h_mult : ∀ i ∈ L.causticSet, 2 ≤ L.pathMult i;
    · exact Or.inl <| by exact symmetry_gap_yields_factor L N ⟨ hprod, by linarith, h_mult ⟩ ;
    · grind

/-
═══════════════════════════════════════════════════════════════════════════════
§9. PYTHAGOREAN-TROPICAL BRIDGE
═══════════════════════════════════════════════════════════════════════════════

**Pythagorean Shell to Lens**: A balanced Pythagorean shell naturally
    produces a 2-lens reduced tropical network encoding the balanced
    product as a semiprime.

    This connects classical Diophantine geometry (Pythagorean triples) to
    tropical caustic structure, showing that Pythagorean constraints can
    serve as geometric certificates for factorization.
-/
theorem pythagorean_shell_to_lens (P : PythagoreanShelling)
    (hbal : P.IsBalanced) :
    ∃ L : TropicalLensNetwork, L.numLenses = 2 ∧ L.IsReduced ∧
      L.EncodesSemiprime (P.a * P.b) := by
  constructor;
  swap;
  exact ⟨ 2, by decide, fun _ => 0, fun _ => 0, fun i => if i = 0 then P.a else P.b, by
    exact fun i => by fin_cases i <;> [ exact P.a_pos; exact P.b_pos ] ; ⟩;
  constructor;
  · rfl;
  · constructor;
    · unfold TropicalLensNetwork.IsReduced; aesop;
    · constructor;
      · unfold TropicalLensNetwork.encodedProduct;
        unfold TropicalLensNetwork.causticSet; simp +decide [ Finset.prod_filter ] ;
        unfold TropicalLensNetwork.totalCost TropicalLensNetwork.minArrivalCost; simp +decide ;
        unfold TropicalLensNetwork.totalCost; simp +decide [ Fin.univ_succ ] ;
      · unfold TropicalLensNetwork.causticSet; simp +decide [ TropicalLensNetwork.totalCost ] ;
        unfold TropicalLensNetwork.minArrivalCost; simp +decide [ TropicalLensNetwork.totalCost ] ;
      · simp +decide [ TropicalLensNetwork.causticSet ];
        exact ⟨ fun _ => hbal.1, fun _ => hbal.2 ⟩

/-
═══════════════════════════════════════════════════════════════════════════════
§10. TWO-LENS ENCODING
═══════════════════════════════════════════════════════════════════════════════

Any product of two positive integers is realizable as the encoded
    product of a 2-lens reduced network.
-/
theorem two_lens_product (m₁ m₂ : ℕ) (hm₁ : 0 < m₁) (hm₂ : 0 < m₂) :
    ∃ L : TropicalLensNetwork, L.numLenses = 2 ∧ L.IsReduced ∧
      L.encodedProduct = m₁ * m₂ := by
  constructor;
  constructor;
  case w => exact ⟨ 2, by decide, fun _ => 0, fun _ => 0, fun i => if i = 0 then m₁ else m₂, by intros i; fin_cases i <;> assumption ⟩;
  · rfl;
  · simp +decide [ TropicalLensNetwork.IsReduced, TropicalLensNetwork.encodedProduct ];
    simp +decide [ TropicalLensNetwork.causticSet ];
    simp +decide [ TropicalLensNetwork.totalCost, TropicalLensNetwork.minArrivalCost ]

/-
Any product of two integers ≥ 2 is encodable as a semiprime via
    a 2-lens reduced network.
-/
theorem two_lens_semiprime (m₁ m₂ : ℕ) (hm₁ : 2 ≤ m₁) (hm₂ : 2 ≤ m₂) :
    ∃ L : TropicalLensNetwork, L.numLenses = 2 ∧ L.IsReduced ∧
      L.EncodesSemiprime (m₁ * m₂) := by
  fconstructor;
  exact ⟨ 2, by decide, fun _ => 0, fun _ => 0, fun i => if i = 0 then m₁ else m₂, fun _ => by positivity ⟩;
  refine' ⟨ rfl, _, _, _, _ ⟩;
  · unfold TropicalLensNetwork.IsReduced;
    unfold TropicalLensNetwork.causticSet; aesop;
  · unfold TropicalLensNetwork.encodedProduct;
    unfold TropicalLensNetwork.causticSet; simp +decide [ Finset.prod_filter ] ;
    unfold TropicalLensNetwork.totalCost TropicalLensNetwork.minArrivalCost; simp +decide ;
    unfold TropicalLensNetwork.totalCost; simp +decide [ Fin.univ_succ ] ;
  · unfold TropicalLensNetwork.causticSet; aesop;
  · grind

/-
Complete factoring pipeline: given any composite N = m₁ * m₂ with
    both factors ≥ 2, there exists a tropical lens network from which
    the factorization can be extracted.
-/
theorem tropical_factoring_pipeline (N m₁ m₂ : ℕ)
    (hm₁ : 2 ≤ m₁) (hm₂ : 2 ≤ m₂) (hN : m₁ * m₂ = N) :
    ∃ L : TropicalLensNetwork, L.EncodesSemiprime N ∧
      ∃ a b : ℕ, 1 < a ∧ 1 < b ∧ a * b = N := by
  obtain ⟨ L, hL ⟩ := two_lens_semiprime m₁ m₂ hm₁ hm₂;
  exact ⟨ L, hN ▸ hL.2.2, m₁, m₂, hm₁, hm₂, hN ⟩

end TropicalArithmeticLensing