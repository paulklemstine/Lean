/-
# Impossibility Theory: Transfer, Composition, and Spectral Analysis

This file develops a systematic theory of impossibility phenomena through
the lens of equivariant tasks on group actions. We establish:

1. **Transfer Principle**: Impossibility transfers along surjective homomorphisms.
2. **Product Composition**: Independent impossibilities compose.
3. **Impossibility Spectrum**: Novel definition measuring which subgroups witness impossibility.
4. **Spectral Upward Closure**: The spectrum is an upper set in the subgroup lattice.
5. **Equivariant Bijectivity**: Equivariant self-maps on free transitive actions are bijections.

## Key Insight

Classical impossibility theorems (quintic unsolvability, angle trisection,
Arrow's theorem) all arise from the same structural phenomenon: a group
acts freely, preventing the existence of equivariant selections.
-/

import Mathlib

open MulAction Function Set

/-! ## Section 1: Equivariant Tasks -/

/-- An equivariant task for a group `G` acting on `X` and `Y`. -/
structure ImpTask (G X Y : Type*) [Group G] [MulAction G X] [MulAction G Y] where
  admissible : X → Set Y
  equiv_admissible : ∀ (g : G) (x : X) (y : Y),
    y ∈ admissible x ↔ g • y ∈ admissible (g • x)

/-- A task is solvable if an equivariant function picks admissible outputs. -/
def ImpTask.Solvable {G X Y : Type*} [Group G] [MulAction G X] [MulAction G Y]
    (T : ImpTask G X Y) : Prop :=
  ∃ f : X → Y, (∀ x, f x ∈ T.admissible x) ∧ (∀ (g : G) (x : X), f (g • x) = g • f x)

/-! ## Section 2: The Impossibility Spectrum (Novel Definition) -/

/-- The **impossibility spectrum** of a group action: the set of nontrivial subgroups H ≤ G
such that H has no fixed points on X. This captures "how much symmetry suffices for
impossibility" — a larger spectrum means the impossibility is more robust. -/
def ImpossibilitySpectrum (G X : Type*) [Group G] [MulAction G X] : Set (Subgroup G) :=
  { H : Subgroup G | H ≠ ⊥ ∧ fixedPoints H X = ∅ }

/-! ## Section 3: Core Impossibility Lemma -/

/-
**No equivariant constant map on free nontrivial actions.**
If G acts freely on X with a nontrivial element, no equivariant map X → X is constant.
-/
theorem no_equivariant_constant
    {G X : Type*} [Group G] [MulAction G X]
    (hfree : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ¬ ∃ (f : X → X) (c : X),
      (∀ (g : G) (x : X), f (g • x) = g • f x) ∧ (∀ x, f x = c) := by
  obtain ⟨ g, hg ⟩ := hne;
  by_contra h_contra
  obtain ⟨f, c, hf_equiv, hf_const⟩ := h_contra
  have hfixed : ∀ g : G, g • c = c := by
    intro g
    have := hf_equiv g c
    simp [hf_const] at this
    exact this.symm;
  exact hfree g hg c ( hfixed g )

/-! ## Section 4: Transfer Principle -/

/-
**Transfer Principle for Impossibility.** If `G` acts freely on `X` with
a nontrivial element, and `φ : H →* G` is surjective, then no `H`-equivariant
map (via `φ`) can be constant either.

The key insight: surjectivity of φ means every g ∈ G is hit, so the freeness
constraint on G is fully inherited by H's action through φ.
-/
theorem impossibility_transfer
    {G H X : Type*} [Group G] [Group H] [MulAction G X]
    (φ : H →* G) (hφ : Surjective φ)
    (hfree : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    ¬ ∃ (f : X → X) (c : X),
      (∀ (h : H) (x : X), f (φ h • x) = φ h • f x) ∧
      (∀ x, f x = c) := by
  contrapose! hfree;
  obtain ⟨ f, c, hf, hc ⟩ := hfree; obtain ⟨ g, hg ⟩ := hne; use φ ( Classical.choose ( hφ g ) ), by
    rw [ Classical.choose_spec ( hφ g ) ] ; exact hg; ; use c; (
  simpa [ hc ] using hf ( Classical.choose ( hφ g ) ) c |> Eq.symm;);

/-! ## Section 5: Product Composition -/

/-- The product action of G × H on X × Y. -/
instance prodSMul' {G H X Y : Type*} [SMul G X] [SMul H Y] : SMul (G × H) (X × Y) where
  smul gh xy := (gh.1 • xy.1, gh.2 • xy.2)

@[simp] lemma prod_smul_fst' {G H X Y : Type*} [SMul G X] [SMul H Y]
    (gh : G × H) (xy : X × Y) : (gh • xy).1 = gh.1 • xy.1 := rfl

@[simp] lemma prod_smul_snd' {G H X Y : Type*} [SMul G X] [SMul H Y]
    (gh : G × H) (xy : X × Y) : (gh • xy).2 = gh.2 • xy.2 := rfl

instance prodMulAction' {G H X Y : Type*} [Group G] [Group H]
    [MulAction G X] [MulAction H Y] : MulAction (G × H) (X × Y) where
  one_smul xy := by ext <;> simp
  mul_smul gh₁ gh₂ xy := by ext <;> simp [mul_smul]

/-
**Product Freeness**: If G acts freely on X and H acts freely on Y,
then G × H acts freely on X × Y.
-/
theorem free_prod_of_free
    {G H X Y : Type*} [Group G] [Group H] [MulAction G X] [MulAction H Y]
    (hfreeG : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hfreeH : ∀ h : H, h ≠ 1 → ∀ y : Y, h • y ≠ y) :
    ∀ (gh : G × H), gh ≠ 1 → ∀ (xy : X × Y), gh • xy ≠ xy := by
  simp_all +decide [ Prod.ext_iff ];
  grind +ring

/-
**Product Impossibility**: If G acts freely and nontrivially on X,
and H acts freely and nontrivially on Y, then no equivariant constant
map exists on X × Y under the product action of G × H.
-/
theorem product_impossibility
    {G H X Y : Type*} [Group G] [Group H]
    [MulAction G X] [MulAction H Y]
    [Nonempty X] [Nonempty Y]
    (hfreeG : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hfreeH : ∀ h : H, h ≠ 1 → ∀ y : Y, h • y ≠ y)
    (hneG : ∃ g : G, g ≠ 1)
    (hneH : ∃ h : H, h ≠ 1) :
    ¬ ∃ (f : X × Y → X × Y) (c : X × Y),
      (∀ (gh : G × H) (xy : X × Y), f (gh • xy) = gh • f xy) ∧
      (∀ xy, f xy = c) := by
  convert no_equivariant_constant _ _ using 1;
  · exact free_prod_of_free hfreeG hfreeH;
  · obtain ⟨ g, hg ⟩ := hneG; exact ⟨ ⟨ g, 1 ⟩, by simpa using hg ⟩ ;

/-! ## Section 6: Stabilizer Characterization -/

/-
**Stabilizer Triviality Characterizes Freeness at a point.**
-/
theorem stabilizer_trivial_iff_free_at
    {G X : Type*} [Group G] [MulAction G X] (x : X) :
    stabilizer G x = ⊥ ↔ ∀ g : G, g • x = x → g = 1 := by
  simp +decide [ Subgroup.eq_bot_iff_forall ]

/-
**Free iff all stabilizers trivial.**
-/
theorem free_iff_all_stabilizers_trivial
    {G X : Type*} [Group G] [MulAction G X] :
    (∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x) ↔
    (∀ x : X, stabilizer G x = ⊥) := by
  simp +decide [ Subgroup.eq_bot_iff_forall ];
  exact ⟨ fun h x g hg => Classical.not_not.1 fun hg' => h g hg' x hg, fun h g hg x hx => hg ( h x g hx ) ⟩

/-! ## Section 7: Spectrum Properties -/

/-
**Spectrum Upward Closure**: If H is in the impossibility spectrum
and H ≤ K, then K is in the spectrum. The impossibility spectrum is
an upper set in the subgroup lattice.
-/
theorem spectrum_upward_closed
    {G X : Type*} [Group G] [MulAction G X]
    {H K : Subgroup G} (hHK : H ≤ K) (hH : H ∈ ImpossibilitySpectrum G X) :
    K ∈ ImpossibilitySpectrum G X := by
  constructor;
  · cases hH ; aesop;
  · refine' Set.eq_empty_iff_forall_notMem.2 fun x hx => _;
    exact hH.2.subset ( show x ∈ MulAction.fixedPoints H X from fun h => hx ⟨ h, hHK h.2 ⟩ )

/-
**Full group is in spectrum when action is free and nontrivial.**
-/
theorem spectrum_contains_top_of_free_nontrivial
    {G X : Type*} [Group G] [MulAction G X]
    (hfree : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1) :
    (⊤ : Subgroup G) ∈ ImpossibilitySpectrum G X := by
  constructor;
  · simp +decide [ Subgroup.eq_bot_iff_forall ];
    exact hne;
  · simp +decide [ Set.ext_iff, MulAction.fixedPoints ];
    exact fun x => ⟨ hne.choose, hfree _ hne.choose_spec _ ⟩

/-! ## Section 8: Equivariant Bijectivity -/

/-
**Equivariant Bijectivity**: On a free transitive action of a nontrivial group,
every equivariant self-map is a bijection. Equivariant maps preserve structure
so perfectly that they cannot collapse — they must be permutations.

Proof: Injectivity: if f(x) = f(y) and g • x = y, then g • f(x) = f(y) = f(x),
so g = 1, hence x = y. Surjectivity: for any y, pick g with g • f(x₀) = y,
then f(g • x₀) = y.
-/
theorem equivariant_bijective_of_free_transitive
    {G X : Type*} [Group G] [MulAction G X]
    (hfree : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (htrans : ∀ x y : X, ∃ g : G, g • x = y)
    (f : X → X) (hf : ∀ (g : G) (x : X), f (g • x) = g • f x) :
    Bijective f := by
  constructor <;> intro x;
  · intro y hxy
    obtain ⟨g, hg⟩ : ∃ g : G, g • x = y := htrans x y
    have hg' : g • f x = f x := by
      grind;
    grind +suggestions;
  · cases' htrans ( f x ) x with g hg;
    exact ⟨ _, by rw [ hf, hg ] ⟩

/-! ## Section 9: No Equivariant Orbit Section -/

/-
**No equivariant orbit section**: On a free transitive action with nontrivial group,
there is no function that simultaneously: picks a representative from each orbit,
is constant on orbits, and is equivariant. The three requirements are mutually
contradictory — this is the abstract form of all classical impossibilities.
-/
theorem no_equivariant_orbit_section
    {G X : Type*} [Group G] [MulAction G X] [Nonempty X]
    (hfree : ∀ g : G, g ≠ 1 → ∀ x : X, g • x ≠ x)
    (hne : ∃ g : G, g ≠ 1)
    (htrans : ∀ x y : X, ∃ g : G, g • x = y) :
    ¬ ∃ s : X → X, (∀ x : X, ∃ g : G, g • s x = x) ∧
      (∀ x y : X, (∃ g : G, g • x = y) → s x = s y) ∧
      (∀ (g : G) (x : X), s (g • x) = g • s x) := by
  simp +zetaDelta at *;
  intro s hs hs'; obtain ⟨ g, hg ⟩ := hne; use g, Classical.arbitrary X; specialize hs' ( Classical.arbitrary X ) g; simp_all +decide ;
  exact fun h => hfree g hg _ h.symm

/-! ## Section 10: Cyclic Group Instantiation -/

/-
**Cyclic group acts freely on itself**: ZMod n (n ≥ 2) with additive action
acts freely. This is the simplest nontrivial instance of the impossibility phenomenon.
-/
theorem zmod_add_free {n : ℕ} (hn : 2 ≤ n) :
    ∀ g : ZMod n, g ≠ 0 → ∀ x : ZMod n, g + x ≠ x := by
  grind +locals

/-! ## Verification -/

#check @no_equivariant_constant
#check @impossibility_transfer
#check @product_impossibility
#check @spectrum_upward_closed
#check @equivariant_bijective_of_free_transitive
#check @no_equivariant_orbit_section