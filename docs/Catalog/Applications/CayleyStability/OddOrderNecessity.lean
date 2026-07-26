/-
Copyright (c) 2026. All rights reserved.

# Stability of Cayley Digraphs — Odd Order and the Necessity of the Hypotheses

The conjecture under study (Hujdurović–Mitrović–Morris) states that *every
connected, twin-free Cayley digraph of a finite abelian group of odd order is
stable*: the embedding `expectedHom` of `Embedding.lean` is then surjective,
hence an isomorphism `Aut(X ⊗ K₂) ≅ Aut(X) × Aut(K₂)`.

This file isolates the **odd-order** ingredient and demonstrates that the
**odd-order hypothesis cannot be dropped**.  (It is self-contained: it re-states
the small amount of framework from `Embedding.lean` in its own namespace so that
it elaborates independently.)

* `odd_no_involution`: in a finite abelian group of *odd* order there are no
  involutions (`g + g = 0 → g = 0`).  This is precisely the structural feature
  that fails in even order and is the engine of the full theorem.

* The smallest even-order witness `Cay(ℤ/2, {1}) = K₂` is **connected**
  (`S2_conn`) and **twin-free** (`S2_twinFree`) yet **unstable**
  (`expectedHom_not_surjective`): we exhibit an explicit automorphism `tau` of
  the double cover (a swap of two vertices in different layers) that is *not* a
  product permutation, so the expected embedding misses it.

Together these say: every hypothesis of the conjecture except oddness is met by
`K₂`, oddness fails, and stability fails — so oddness is genuinely necessary.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (a) Odd abelian order forbids involutions. (b) The
odd-order hypothesis in the stability conjecture is necessary: there is a
connected twin-free even-order Cayley digraph that is unstable.

Experiment (Experimenter): (a) `addOrderOf g ∣ 2` and `addOrderOf g ∣ |G|`; with
`|G|` odd the only common option is order `1`, i.e. `g = 0`.  (b) Took
`G = ℤ/2`, `S = {1}`.  Its double cover is the perfect matching `2·K₂`; the swap
`tau = swap (0,false) (1,true)` is an automorphism (`tau_mem`, finite check) but
maps the layer `false` inconsistently, so it is not `σ ×ₚ π` — evaluating at
`(0,false)` and `(1,false)` forces `π false = true` and `π false = false`.

Analysis (Analyst): The break is exactly the existence of an involution: in
`ℤ/2` the nonzero element is its own inverse, which is what lets a single
transposition act as a graph automorphism across the two layers.  In odd order
`odd_no_involution` removes this possibility — matching the role oddness plays in
the literature.

Critique (Critic): `expectedHom_not_surjective` is proved by an explicit
witness and an evaluation contradiction (not `decide`-only); `odd_no_involution`
uses real order theory. The witness provably satisfies connectivity and
twin-freeness, so the necessity claim has no hidden loophole.

Synthesis (PI): Necessity of oddness is settled; the positive direction (odd ⇒
stable) is recorded as the central open formalisation target in
`FUTURE_DIRECTIONS.md`.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open Equiv

namespace CayleyStability.Necessity

variable {G : Type*} [AddCommGroup G]

/-! ### Framework (mirroring `Embedding.lean`, kept local for self-containment) -/

/-- Adjacency of the Cayley digraph `Cay(G, S)`: an arc `g → h` iff `h - g ∈ S`. -/
def cayAdj (S : Set G) (g h : G) : Prop := h - g ∈ S

/-- Adjacency of the tensor product `Cay(G, S) ⊗ K₂`. -/
def dcAdj (S : Set G) (p q : G × Bool) : Prop := (q.1 - p.1 ∈ S) ∧ (p.2 ≠ q.2)

/-- Automorphism group of a relation, as a subgroup of permutations. -/
def AutRel {V : Type*} (r : V → V → Prop) : Subgroup (Equiv.Perm V) where
  carrier := {σ | ∀ a b, r (σ a) (σ b) ↔ r a b}
  one_mem' := by intro a b; simp
  mul_mem' := by
    intro σ τ hσ hτ a b
    simp only [Equiv.Perm.coe_mul, Function.comp_apply]
    rw [hσ, hτ]
  inv_mem' := by
    intro σ hσ a b
    have h := hσ (σ⁻¹ a) (σ⁻¹ b)
    simpa using h.symm

lemma prodCongr_mem (S : Set G) (σ : Equiv.Perm G) (π : Equiv.Perm Bool)
    (hσ : σ ∈ AutRel (cayAdj S)) : σ.prodCongr π ∈ AutRel (dcAdj S) := by
  intro a b
  have hkey := hσ a.1 b.1
  simp only [cayAdj] at hkey
  simp only [dcAdj, Equiv.prodCongr_apply, Prod.map_fst, Prod.map_snd]
  rw [hkey]
  exact ⟨fun ⟨h1, h2⟩ => ⟨h1, fun h => h2 (by rw [h])⟩,
         fun ⟨h1, h2⟩ => ⟨h1, fun h => h2 (π.injective h)⟩⟩

/-- The canonical embedding of the expected automorphism group. -/
def expectedHom (S : Set G) :
    (AutRel (cayAdj S)) × (Equiv.Perm Bool) →* (AutRel (dcAdj S)) where
  toFun p := ⟨(p.1 : Equiv.Perm G).prodCongr p.2, prodCongr_mem S _ _ p.1.2⟩
  map_one' := by apply Subtype.ext; ext x <;> simp
  map_mul' a b := by apply Subtype.ext; ext x <;> simp [Subgroup.coe_mul]

/-! ### The odd-order structural ingredient -/

/-- **Odd order forbids involutions.**  In a finite abelian group of odd order,
the only solution of `g + g = 0` is `g = 0`.  This is the structural property
that underlies the odd-order stability theorem. -/
theorem odd_no_involution [Fintype G] (hodd : Odd (Fintype.card G)) (g : G)
    (h : g + g = 0) : g = 0 := by
  have h2 : (2 : ℕ) • g = 0 := by simpa [two_nsmul] using h
  have hdvd : addOrderOf g ∣ 2 := addOrderOf_dvd_of_nsmul_eq_zero h2
  have hcard : addOrderOf g ∣ Fintype.card G := addOrderOf_dvd_card
  rcases (Nat.dvd_prime Nat.prime_two).mp hdvd with h1 | h2'
  · exact AddMonoid.addOrderOf_eq_one_iff.mp h1
  · exfalso
    have : (2 : ℕ) ∣ Fintype.card G := h2' ▸ hcard
    rcases hodd with ⟨k, hk⟩; omega

/-! ### Connectivity and twin-freeness of a digraph -/

/-- A digraph is (weakly) connected if any two vertices are joined by a path in
the underlying undirected reachability relation. -/
def DigConn (S : Set G) : Prop :=
  ∀ u v, Relation.ReflTransGen (fun a b => cayAdj S a b ∨ cayAdj S b a) u v

/-- A digraph is twin-free if no two distinct vertices have identical in- and
out-neighbourhoods. -/
def TwinFree (S : Set G) : Prop :=
  ∀ u v, (∀ w, (cayAdj S u w ↔ cayAdj S v w) ∧ (cayAdj S w u ↔ cayAdj S w v)) → u = v

/-! ### The even-order counterexample `Cay(ℤ/2, {1}) = K₂` -/

/-- Connection set of the directed edge `K₂` over `ℤ/2`. -/
abbrev S2 : Set (ZMod 2) := {1}

lemma cayAdj_S2 (a b : ZMod 2) : cayAdj S2 a b ↔ b - a = 1 := by
  simp [cayAdj, S2, Set.mem_singleton_iff]

/-- `K₂ = Cay(ℤ/2, {1})` is connected. -/
theorem S2_conn : DigConn S2 := by
  intro u v
  have e01 : cayAdj S2 0 1 := (cayAdj_S2 0 1).mpr (by decide)
  have e10 : cayAdj S2 1 0 := (cayAdj_S2 1 0).mpr (by decide)
  fin_cases u <;> fin_cases v
  · exact Relation.ReflTransGen.refl
  · exact Relation.ReflTransGen.single (Or.inl e01)
  · exact Relation.ReflTransGen.single (Or.inl e10)
  · exact Relation.ReflTransGen.refl

/-- `K₂ = Cay(ℤ/2, {1})` is twin-free. -/
theorem S2_twinFree : TwinFree S2 := by
  have dec : ∀ u v : ZMod 2, (((0 : ZMod 2) - u = 1) ↔ ((0 : ZMod 2) - v = 1)) → u = v := by
    decide
  intro u v h
  have h0 := (h 0).1
  rw [cayAdj_S2, cayAdj_S2] at h0
  exact dec u v h0

/-- An explicit automorphism of the double cover of `K₂`: it swaps the two
vertices `(0, false)` and `(1, true)`, which lie in different layers.  It is
*not* of product form `σ ×ₚ π`, witnessing instability. -/
def tau : Equiv.Perm (ZMod 2 × Bool) := Equiv.swap ((0 : ZMod 2), false) ((1 : ZMod 2), true)

/-- `tau` really is an automorphism of the double cover `Cay(ℤ/2,{1}) ⊗ K₂`. -/
theorem tau_mem : tau ∈ AutRel (dcAdj S2) := by
  intro a b
  obtain ⟨a1, a2⟩ := a; obtain ⟨b1, b2⟩ := b
  fin_cases a1 <;> fin_cases b1 <;> cases a2 <;> cases b2 <;>
    simp [tau, dcAdj, S2, Equiv.swap_apply_def]

/-- **Necessity of the odd-order hypothesis.**  The expected-automorphism
embedding for the even-order digraph `K₂ = Cay(ℤ/2, {1})` is *not* surjective:
`tau` is an automorphism of the double cover outside its image.  Hence `K₂` —
which is connected (`S2_conn`) and twin-free (`S2_twinFree`) of even order — is
**unstable**, so the conjecture genuinely requires odd order. -/
theorem expectedHom_not_surjective : ¬ Function.Surjective (expectedHom S2) := by
  intro hsurj
  obtain ⟨x, hx⟩ := hsurj ⟨tau, tau_mem⟩
  have hval : (x.1 : Equiv.Perm (ZMod 2)).prodCongr x.2 = tau := by
    have := congrArg Subtype.val hx; simpa [expectedHom] using this
  have e1 := congrArg (fun f => (f (0, false)).2) hval
  have e2 := congrArg (fun f => (f (1, false)).2) hval
  simp only [Equiv.prodCongr_apply, Prod.map_snd, tau, Equiv.swap_apply_def] at e1 e2
  rw [e2] at e1
  simp at e1

end CayleyStability.Necessity