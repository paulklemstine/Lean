/-
# Sabidussi's theorem: Cayley graphs ↔ regular automorphism subgroups

This file formalizes the structural backbone of the research mission
**"Multiplicability of Upho Posets from Vertex-Transitive Graphs"**.

The mission's central conjecture states that, for a vertex–transitive graph `G`,
the finitary upho poset of walks `P(G, v₀)` is *multiplicable* (admits an LCIF
monoid structure whose left-divisibility order recovers the poset order)
**iff** `Aut(G)` contains a regular subgroup, equivalently iff `G` is a Cayley
graph.  The equivalence

> `G` is a Cayley graph  ⟺  `Aut(G)` contains a subgroup acting *regularly*
> (sharply transitively) on the vertices

is the classical theorem of **Sabidussi (1958)**.  It is the load-bearing
group-theoretic half of the conjecture: it is exactly the criterion that
separates the Petersen graph (non-Cayley → no regular subgroup) from its line
graph (Cayley → regular subgroup).  This file gives a self-contained,
`sorry`-free Lean proof of Sabidussi's theorem.

The main objects:
* `IsFreeAction`, `IsRegularAction` : a group action that is free / regular.
* `cayleyGraph` : the Cayley graph of a group with a symmetric connection set.
* `cayleyRep` : the left-regular representation `H →* Aut (Cay H S)`.
* `IsCayleyGraph`, `HasRegularAutSubgroup` : the two sides of Sabidussi.
* `sabidussi` : the main equivalence.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The "regular subgroup" half of the FPZ-refinement is
exactly Sabidussi's theorem.  If we cannot formalize Sabidussi, the whole upho
multiplicability program rests on sand.  Conjecture: it is fully formalizable in
Mathlib using `SimpleGraph.Iso` and `MulAction`.

EXPERIMENT (Experimenter).  We modeled `Aut(G)` as `G ≃g G` (graph self-isos),
which Mathlib already endows with a `Group` and a `MulAction` on vertices.
We built the Cayley graph as `Adj a b := a⁻¹ * b ∈ S`, proved left-translation is
an automorphism, and that the left-regular representation embeds `H` as a regular
subgroup.  The reverse construction (regular subgroup ⇒ Cayley) uses the orbit
bijection `k ↦ k • v₀` as the graph isomorphism.

ANALYSIS (Analyst).  Both directions went through.  The key structural insight is
that a *regular* action is precisely one whose orbit map is a group-equivariant
bijection, so a regular subgroup literally *is* the vertex set with a group law,
and that group law is the Cayley structure.

CRITIQUE (Critic).  The empty graph is a genuine corner case: with `V` empty,
every subgroup acts vacuously "regularly" yet there is no Cayley structure (a
group is nonempty).  We therefore require `[Nonempty V]` in `sabidussi`; both
directions are stated unconditionally where they hold and the corner case is
documented.

SYNTHESIS (PI).  Sabidussi's theorem is now a reusable lemma for the broader
multiplicability program; see `FUTURE_DIRECTIONS.md`.
-/
import Mathlib

open MulAction

universe u

namespace UphoMultiplicability

/-! ## Regular group actions -/

/-- An action is **free** (semiregular) if no nonidentity element fixes a point. -/
def IsFreeAction (G X : Type*) [Group G] [MulAction G X] : Prop :=
  ∀ (g : G) (x : X), g • x = x → g = 1

/-- An action is **regular** (sharply transitive) if it is transitive and free. -/
structure IsRegularAction (G X : Type*) [Group G] [MulAction G X] : Prop where
  pretransitive : IsPretransitive G X
  free : IsFreeAction G X

/-- The orbit map `g ↦ g • x₀` of a regular action is a bijection: this is the
structural heart of regularity — the action is a torsor. -/
theorem IsRegularAction.bijective_smul {G X : Type*} [Group G] [MulAction G X]
    (h : IsRegularAction G X) (x0 : X) :
    Function.Bijective (fun g : G => g • x0) := by
  obtain ⟨ht, hf⟩ := h
  refine ⟨?_, ?_⟩
  · intro a b hab
    simp only at hab
    have hx : (b⁻¹ * a) • x0 = x0 := by
      rw [mul_smul, hab, ← mul_smul, inv_mul_cancel, one_smul]
    have h1 : b⁻¹ * a = 1 := hf _ _ hx
    rw [inv_mul_eq_one] at h1
    exact h1.symm
  · intro y
    obtain ⟨g, hg⟩ := ht.exists_smul_eq x0 y
    exact ⟨g, hg⟩

/-- The left-regular action of a group on itself is regular. -/
theorem leftRegular_isRegular (G : Type*) [Group G] : IsRegularAction G G := by
  refine ⟨inferInstance, ?_⟩
  intro g x hx
  simpa using hx

/-! ## Cayley graphs -/

/-- The **Cayley graph** of a group `H` with connection set `S`, where `S` is
symmetric (`s ∈ S → s⁻¹ ∈ S`) and does not contain the identity (`1 ∉ S`).
Two vertices `a, b` are adjacent iff `a⁻¹ * b ∈ S`. -/
def cayleyGraph (H : Type*) [Group H] (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : H) ∉ S) : SimpleGraph H where
  Adj a b := a⁻¹ * b ∈ S
  symm := by
    intro a b hab
    have : (a⁻¹ * b)⁻¹ ∈ S := hsymm _ hab
    simpa [mul_inv_rev] using this
  loopless := ⟨fun a ha => h1 (by simpa using ha)⟩

/-- Left translation `x ↦ c * x` is an automorphism of the Cayley graph. -/
def cayleyLeftMul (H : Type*) [Group H] (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : H) ∉ S) (c : H) :
    (cayleyGraph H S hsymm h1) ≃g (cayleyGraph H S hsymm h1) where
  toFun := fun x => c * x
  invFun := fun x => c⁻¹ * x
  left_inv := by intro x; simp
  right_inv := by intro x; simp
  map_rel_iff' := by
    intro a b
    show (c * a)⁻¹ * (c * b) ∈ S ↔ a⁻¹ * b ∈ S
    have key : (c * a)⁻¹ * (c * b) = a⁻¹ * b := by group
    rw [key]

/-- The **left-regular representation** `H →* Aut(Cay H S)`. -/
noncomputable def cayleyRep (H : Type*) [Group H] (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : H) ∉ S) :
    H →* ((cayleyGraph H S hsymm h1) ≃g (cayleyGraph H S hsymm h1)) where
  toFun c := cayleyLeftMul H S hsymm h1 c
  map_one' := by apply RelIso.ext; intro x; simp [cayleyLeftMul]
  map_mul' := by intro a b; apply RelIso.ext; intro x; simp [cayleyLeftMul, mul_assoc]

theorem cayleyRep_injective (H : Type*) [Group H] (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S)
    (h1 : (1 : H) ∉ S) : Function.Injective (cayleyRep H S hsymm h1) := by
  intro a b hab
  have := congrArg (fun f => f.toFun 1) hab
  simpa [cayleyRep, cayleyLeftMul] using this

/-
The image of the left-regular representation acts **regularly** on the Cayley
graph's vertices.  (This is the concrete "Cayley ⇒ regular subgroup" direction.)
-/
theorem cayleyRep_range_isRegular (H : Type*) [Group H] (S : Set H)
    (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : H) ∉ S) :
    IsRegularAction (cayleyRep H S hsymm h1).range H := by
  refine' ⟨ _, _ ⟩;
  · refine' ⟨ fun x y => _ ⟩;
    refine' ⟨ ⟨ _, ⟨ y * x⁻¹, rfl ⟩ ⟩, _ ⟩;
    simp +decide [ cayleyRep, cayleyLeftMul ];
  · intro ⟨ k, hk ⟩ x hx;
    obtain ⟨ c, rfl ⟩ := hk;
    simp_all +decide [ cayleyRep, cayleyLeftMul ];
    rfl

/-! ## The two sides of Sabidussi's theorem -/

/-- A simple graph `γ` on `V` is a **Cayley graph** if it is isomorphic to the
Cayley graph of some group with some symmetric, identity-free connection set. -/
def IsCayleyGraph {V : Type u} (γ : SimpleGraph V) : Prop :=
  ∃ (H : Type u) (_ : Group H) (S : Set H) (hsymm : ∀ s ∈ S, s⁻¹ ∈ S) (h1 : (1 : H) ∉ S),
    Nonempty (γ ≃g cayleyGraph H S hsymm h1)

/-- `γ` **has a regular automorphism subgroup** if some subgroup of `Aut(γ)`
acts regularly on the vertices. -/
def HasRegularAutSubgroup {V : Type u} (γ : SimpleGraph V) : Prop :=
  ∃ K : Subgroup (γ ≃g γ), IsRegularAction K V

/-
Conjugation transports a regular automorphism subgroup along a graph
isomorphism.
-/
theorem HasRegularAutSubgroup.of_iso {V W : Type u} {γ : SimpleGraph V} {δ : SimpleGraph W}
    (e : γ ≃g δ) (h : HasRegularAutSubgroup δ) : HasRegularAutSubgroup γ := by
  obtain ⟨ K, hK ⟩ := h;
  refine' ⟨ K.map _, _, _ ⟩;
  refine' { toFun := fun f => e.trans ( f.trans e.symm ), map_one' := _, map_mul' := _ };
  all_goals norm_num [ RelIso.ext_iff ];
  · refine' ⟨ fun x y => _ ⟩;
    obtain ⟨ g, hg ⟩ := hK.pretransitive.exists_smul_eq ( e x ) ( e y );
    use ⟨ e.trans ( g.val.trans e.symm ), Subgroup.mem_map_of_mem _ g.2 ⟩;
    exact e.injective ( by aesop );
  · intro ⟨ f, hf ⟩ v hv;
    obtain ⟨ g, hg, rfl ⟩ := hf;
    have := hK.free ⟨ g, hg ⟩ ( e v ) ?_ <;> simp_all +decide [ RelIso.ext_iff ];
    simpa using congr_arg e hv

/-- **Forward direction**: every Cayley graph has a regular automorphism subgroup. -/
theorem HasRegularAutSubgroup_of_isCayley {V : Type u} {γ : SimpleGraph V}
    (h : IsCayleyGraph γ) : HasRegularAutSubgroup γ := by
  obtain ⟨H, _, S, hsymm, h1, ⟨e⟩⟩ := h
  refine HasRegularAutSubgroup.of_iso e ?_
  exact ⟨(cayleyRep H S hsymm h1).range, cayleyRep_range_isRegular H S hsymm h1⟩

/-
**Reverse direction**: a (nonempty) graph with a regular automorphism subgroup
is a Cayley graph.  The Cayley structure is carried by the regular subgroup
itself, with the orbit bijection `k ↦ k • v₀` as the graph isomorphism.
-/
theorem isCayley_of_hasRegularAutSubgroup {V : Type u} [Nonempty V] {γ : SimpleGraph V}
    (h : HasRegularAutSubgroup γ) : IsCayleyGraph γ := by
  obtain ⟨ K, hK ⟩ := h;
  -- Let $v₀$ be an arbitrary element of $V$.
  obtain ⟨v₀, hv₀⟩ : ∃ v₀ : V, True := by
    exact ⟨ Classical.arbitrary V, trivial ⟩;
  -- Define the connection set $S$ as $\{k \in K \mid \gamma.Adj (k • v₀) v₀\}$.
  set S : Set K := {k : K | γ.Adj (k • v₀) v₀};
  -- We need to show that $S$ is symmetric and does not contain the identity.
  have hS_symm : ∀ s ∈ S, s⁻¹ ∈ S := by
    intro s hs; have := hs.symm; simp_all +decide ;
    have := s⁻¹.1.map_rel_iff.mpr this; aesop;
  have hS_id : (1 : K) ∉ S := by
    simp +zetaDelta at *;
  -- We need to show that the orbit map $k \mapsto k • v₀$ is a graph isomorphism.
  have h_iso : Nonempty (γ ≃g cayleyGraph K S hS_symm hS_id) := by
    refine' ⟨ _, _ ⟩;
    exact ( Equiv.ofBijective ( fun k : K => k • v₀ ) ( hK.bijective_smul v₀ ) ).symm;
    intro a b; simp +decide [ cayleyGraph ] ;
    obtain ⟨ k₁, rfl ⟩ := hK.bijective_smul v₀ |>.2 a; obtain ⟨ k₂, rfl ⟩ := hK.bijective_smul v₀ |>.2 b; simp +decide [ S, SimpleGraph.adj_comm ] ;
    convert ( k₁.1.map_rel_iff.symm ) using 1;
    simp +decide [ Subgroup.smul_def ];
  refine' ⟨ _, _, _, _, _, h_iso ⟩

/-- **Sabidussi's theorem.**  For a nonempty graph `γ`, `γ` is a Cayley graph iff
its automorphism group contains a subgroup acting regularly on the vertices. -/
theorem sabidussi {V : Type u} [Nonempty V] (γ : SimpleGraph V) :
    IsCayleyGraph γ ↔ HasRegularAutSubgroup γ :=
  ⟨HasRegularAutSubgroup_of_isCayley, isCayley_of_hasRegularAutSubgroup⟩

end UphoMultiplicability