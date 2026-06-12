import Mathlib

/-!
# Proof System Collapse Theory: The Abstract Simulation Preorder

This file formalizes an abstract theory of *proof systems* in the style of
Cook–Reckhow, and develops the **simulation preorder** that organizes proof
systems by relative strength.  A proof system over a type `F` of formulas is a
type of `Proof` objects together with a `concl`usion map (which formula a proof
establishes) and a `size` function (the resource cost of a proof).

The provable formulas of a system form a set, and one system **simulates**
another when it proves at least as much.  We show this preorder carries a
lattice structure: the *union* of two systems is their join (least upper bound)
and their *intersection* is their meet (greatest lower bound), both realized by
explicit constructions on proof objects (`Sum` and a conclusion-matched
subtype).  The `singletonSys` construction yields a duality identifying
provability of a single formula with simulation of the corresponding
single-formula system, and the completeness/soundness theorem shows a complete
system simulates every sound system — the maximality phenomenon at the top of
the preorder.

## Key Results

- `simulates_refl`, `simulates_trans`: the simulation preorder.
- `provable_union`, `union_simulates_left/right`, `union_least`:
  the union is the join in the simulation order.
- `provable_inter`, `simulates_inter_left/right`, `inter_greatest`:
  the intersection is the meet in the simulation order.
- `simulates_singleton_iff`: duality between single-formula provability and
  simulation of `singletonSys`.
- `complete_simulates_all_sound`: a complete system simulates every sound one.
-/

namespace ProofSystemCollapse

/-!
-- !-- Lab Notebook -- !--
**Hypothesis.** The intuitive "relative strength" ordering on proof systems
(P is at least as strong as Q if P proves everything Q proves) should be a
genuine bounded lattice whose join/meet are computed by structural operations
on proof objects, not merely on provability sets.

**Result.** Confirmed. `union` (a `Sum` of proofs) realizes the join and `inter`
(a conclusion-matched subtype of pairs) realizes the meet, with full universal
properties. The `singletonSys` duality collapses point-provability to a
simulation statement, and completeness sits at the top of the preorder.

**Insight.** Keeping proofs as honest data (with `concl` and `size`) — rather
than reducing a system to its provability set — is exactly what later allows the
*polynomial* refinement (see `PolynomialSimulation.lean`): the same `Sum`
construction whose join property we prove here also transports the size bounds.

**Failure analysis.** An earlier attempt defined a system as just `Set F`; this
made every theorem a triviality about set inclusion and, fatally, left no room
for proof *sizes*, blocking the quantitative Cook–Reckhow program. Carrying
proof objects costs a little subtype bookkeeping in `inter` but is essential.
-/

/-- An abstract proof system over a type `F` of formulas (à la Cook–Reckhow):
a type of proofs, a `concl`usion function recording which formula each proof
establishes, and a `size` function recording its resource cost. -/
structure ProofSys (F : Type*) where
  /-- The type of proof objects. -/
  Proof : Type*
  /-- The formula a given proof establishes. -/
  concl : Proof → F
  /-- The resource cost (size) of a proof. -/
  size : Proof → ℕ

/-- A formula is **provable** in a system if some proof has it as conclusion. -/
def Provable {F : Type*} (S : ProofSys F) (f : F) : Prop :=
  ∃ p : S.Proof, S.concl p = f

/-- `S` **simulates** `T` when `S` proves every formula `T` proves. This is the
qualitative simulation preorder: `S` is at least as strong as `T`. -/
def Simulates {F : Type*} (S T : ProofSys F) : Prop :=
  ∀ f, Provable T f → Provable S f

-- !-- Reflexivity: a system proves whatever it proves. --!
/-- The simulation relation is reflexive. -/
theorem simulates_refl {F : Type*} (S : ProofSys F) : Simulates S S :=
  fun _ h => h

-- !-- Transitivity: chain the two provability implications. --!
/-- The simulation relation is transitive, so `Simulates` is a preorder. -/
theorem simulates_trans {F : Type*} {S T U : ProofSys F}
    (h₁ : Simulates S T) (h₂ : Simulates T U) : Simulates S U :=
  fun f hf => h₁ f (h₂ f hf)

/-! ## The join: union of proof systems -/

/-- The **union** of two proof systems: a proof is a proof from either system
(`Sum`), with conclusions and sizes inherited componentwise. -/
def union {F : Type*} (S T : ProofSys F) : ProofSys F where
  Proof := S.Proof ⊕ T.Proof
  concl := Sum.elim S.concl T.concl
  size := Sum.elim S.size T.size

-- !-- A union-proof is an `inl`/`inr`; case split both directions. --!
/-- Provability in the union is exactly provability in one of the components. -/
theorem provable_union {F : Type*} (S T : ProofSys F) (f : F) :
    Provable (union S T) f ↔ Provable S f ∨ Provable T f := by
  constructor
  · rintro ⟨p, hp⟩
    cases p with
    | inl a => exact Or.inl ⟨a, hp⟩
    | inr b => exact Or.inr ⟨b, hp⟩
  · rintro (⟨a, ha⟩ | ⟨b, hb⟩)
    · exact ⟨Sum.inl a, ha⟩
    · exact ⟨Sum.inr b, hb⟩

-- !-- The union proves everything the left component proves. --!
/-- The union simulates its left component. -/
theorem union_simulates_left {F : Type*} (S T : ProofSys F) :
    Simulates (union S T) S :=
  fun f hf => (provable_union S T f).2 (Or.inl hf)

-- !-- Symmetric to `union_simulates_left`. --!
/-- The union simulates its right component. -/
theorem union_simulates_right {F : Type*} (S T : ProofSys F) :
    Simulates (union S T) T :=
  fun f hf => (provable_union S T f).2 (Or.inr hf)

-- !-- Anything above both components is above their union (join universal property). --!
/-- The union is the **least** upper bound: any system simulating both `S` and
`T` simulates their union. Together with the two previous results this shows
`union` is the join in the simulation preorder. -/
theorem union_least {F : Type*} {S T U : ProofSys F}
    (hS : Simulates U S) (hT : Simulates U T) : Simulates U (union S T) := by
  intro f hf
  rcases (provable_union S T f).1 hf with h | h
  · exact hS f h
  · exact hT f h

/-! ## The meet: intersection of proof systems -/

/-- The **intersection** of two proof systems: a proof is a pair of proofs from
each system with matching conclusions; its size is the sum of the two sizes. -/
def inter {F : Type*} (S T : ProofSys F) : ProofSys F where
  Proof := { pq : S.Proof × T.Proof // S.concl pq.1 = T.concl pq.2 }
  concl := fun pq => S.concl pq.val.1
  size := fun pq => S.size pq.val.1 + T.size pq.val.2

-- !-- A matched pair proves `f` in both systems; conversely combine two proofs. --!
/-- Provability in the intersection is exactly joint provability. -/
theorem provable_inter {F : Type*} (S T : ProofSys F) (f : F) :
    Provable (inter S T) f ↔ Provable S f ∧ Provable T f := by
  constructor
  · rintro ⟨⟨⟨p, q⟩, hmatch⟩, hc⟩
    simp only [inter] at hc
    refine ⟨⟨p, hc⟩, ⟨q, ?_⟩⟩
    rw [← hmatch, hc]
  · rintro ⟨⟨p, hp⟩, ⟨q, hq⟩⟩
    refine ⟨⟨(p, q), by rw [hp, hq]⟩, ?_⟩
    simpa [inter] using hp

-- !-- Provability in the meet implies provability in the left component. --!
/-- The left component simulates the intersection. -/
theorem simulates_inter_left {F : Type*} (S T : ProofSys F) :
    Simulates S (inter S T) :=
  fun f hf => ((provable_inter S T f).1 hf).1

-- !-- Symmetric to `simulates_inter_left`. --!
/-- The right component simulates the intersection. -/
theorem simulates_inter_right {F : Type*} (S T : ProofSys F) :
    Simulates T (inter S T) :=
  fun f hf => ((provable_inter S T f).1 hf).2

-- !-- Anything below both components is below their intersection (meet universal property). --!
/-- The intersection is the **greatest** lower bound: if both `S` and `T`
simulate `U`, then so does their intersection. Together with the two previous
results this shows `inter` is the meet in the simulation preorder. -/
theorem inter_greatest {F : Type*} {S T U : ProofSys F}
    (hS : Simulates S U) (hT : Simulates T U) : Simulates (inter S T) U := by
  intro f hf
  exact (provable_inter S T f).2 ⟨hS f hf, hT f hf⟩

/-! ## The singleton system and its duality -/

/-- The **singleton system** for a formula `f`: it has exactly one (trivial)
proof, of conclusion `f` and size `0`. It proves precisely `f`. -/
def singletonSys {F : Type*} (f : F) : ProofSys F where
  Proof := Unit
  concl := fun _ => f
  size := fun _ => 0

-- !-- The only conclusion available is `f`. --!
/-- The singleton system proves exactly its defining formula. -/
theorem provable_singleton {F : Type*} (f g : F) :
    Provable (singletonSys f) g ↔ g = f := by
  constructor
  · rintro ⟨_, h⟩; exact h.symm
  · rintro rfl; exact ⟨(), rfl⟩

-- !-- Simulating the one-formula system is the same as proving that formula. --!
/-- **Duality.** A system simulates the singleton system of `f` iff it proves
`f`. This collapses point-provability to a statement in the simulation
preorder. -/
theorem simulates_singleton_iff {F : Type*} (S : ProofSys F) (f : F) :
    Simulates S (singletonSys f) ↔ Provable S f := by
  constructor
  · intro h
    exact h f ((provable_singleton f f).2 rfl)
  · intro hf g hg
    rw [(provable_singleton f g).1 hg]
    exact hf

/-! ## Soundness, completeness, and maximality -/

/-- A system is **sound** for a validity predicate if it proves only valid
formulas. -/
def Sound {F : Type*} (valid : F → Prop) (S : ProofSys F) : Prop :=
  ∀ f, Provable S f → valid f

/-- A system is **complete** for a validity predicate if it proves every valid
formula. -/
def Complete {F : Type*} (valid : F → Prop) (S : ProofSys F) : Prop :=
  ∀ f, valid f → Provable S f

-- !-- Sound ⇒ valid ⇒ provable in the complete system. --!
/-- **Maximality.** A complete system simulates every sound system: it sits at
the top of the simulation preorder restricted to sound systems. -/
theorem complete_simulates_all_sound {F : Type*} {valid : F → Prop}
    {C S : ProofSys F} (hC : Complete valid C) (hS : Sound valid S) :
    Simulates C S :=
  fun f hf => hC f (hS f hf)

-- !-- Two complete systems prove the same valid formulas, hence simulate each other. --!
/-- Any two complete sound systems are simulation-equivalent (mutually
simulate). This is the **collapse** at the top of the preorder. -/
theorem complete_systems_equivalent {F : Type*} {valid : F → Prop}
    {C D : ProofSys F} (hCc : Complete valid C) (hCs : Sound valid C)
    (hDc : Complete valid D) (hDs : Sound valid D) :
    Simulates C D ∧ Simulates D C :=
  ⟨complete_simulates_all_sound hCc hDs, complete_simulates_all_sound hDc hCs⟩

/-! ## Quantitative refinement: polynomial simulation

The qualitative preorder above forgets *how large* a translated proof is. The
Cook–Reckhow program is fundamentally quantitative: one system **p-simulates**
another when there is a proof translation whose size blowup is bounded by a fixed
polynomial. We use the explicit monomial bound `c * (n + 1) ^ k`, which is a
genuine polynomial in `n` and avoids the `Polynomial`-monotonicity overhead while
remaining closed under the operations we need.
-/

/-!
-- !-- Lab Notebook -- !--
**Hypothesis.** The qualitative `union = join` fact should *lift* to the
quantitative world: the union of two polynomially bounded (`PBounded`) systems is
again polynomially bounded, and `PSimulates` is itself a preorder whose
composition law is exactly polynomial composition.

**Result.** Both confirmed. `psim_trans` composes two monomial bounds into a
single one with exponent `k₁ * k₂` and constant `c₂ * (c₁ + 1) ^ k₂`;
`pbounded_union` merges two bounds by taking `c₁ + c₂` and `max k₁ k₂`.

**Insight.** The decisive algebraic step is `c₁ * m ^ k₁ + 1 ≤ (c₁ + 1) * m ^ k₁`
(valid because `m ≥ 1`), which lets a nested polynomial be re-monomialized.
Monotonicity of `m ↦ m ^ k` in both base and exponent (`Nat.pow_le_pow_*`) does
the rest — no real analysis or `Polynomial` API is required.

**Failure analysis.** Using `Polynomial ℕ` directly stalled on the absence of a
ready monotonicity lemma `a ≤ b → p.eval a ≤ p.eval b`; switching to the explicit
`c * (n + 1) ^ k` form made every bound a routine `nlinarith`/`Nat.pow_le_pow`
argument.
-/

/-- `S` **p-simulates** `T` when there is a translation of `T`-proofs into
`S`-proofs that preserves conclusions and increases size by at most a fixed
polynomial `c * (· + 1) ^ k`. This is the Cook–Reckhow notion of *polynomial
simulation* with an explicit monomial bound. -/
def PSimulates {F : Type*} (S T : ProofSys F) : Prop :=
  ∃ (t : T.Proof → S.Proof) (c k : ℕ),
    (∀ q, S.concl (t q) = T.concl q) ∧
    (∀ q, S.size (t q) ≤ c * (T.size q + 1) ^ k)

-- !-- A size-preserving translation in particular preserves provability. --!
/-- Polynomial simulation refines qualitative simulation. -/
theorem psim_implies_simulates {F : Type*} {S T : ProofSys F}
    (h : PSimulates S T) : Simulates S T := by
  obtain ⟨t, _, _, hconcl, _⟩ := h
  intro f hf
  obtain ⟨q, hq⟩ := hf
  exact ⟨t q, by rw [hconcl q, hq]⟩

-- !-- Identity translation with the linear bound `1 * (n+1)^1 = n+1 ≥ n`. --!
/-- Polynomial simulation is reflexive. -/
theorem psim_refl {F : Type*} (S : ProofSys F) : PSimulates S S := by
  refine ⟨id, 1, 1, fun _ => rfl, fun q => ?_⟩
  simp only [id_eq, pow_one, one_mul]
  exact Nat.le_succ _

-- !-- Compose translations; bound `c₂(c₁ m^{k₁}+1)^{k₂} ≤ c₂(c₁+1)^{k₂} m^{k₁k₂}` via `m ≥ 1`. --!
/-- Polynomial simulation is transitive: monomial bounds compose into a single
monomial bound, so `PSimulates` is a preorder. -/
theorem psim_trans {F : Type*} {S T U : ProofSys F}
    (h₁ : PSimulates S T) (h₂ : PSimulates T U) : PSimulates S U := by
  obtain ⟨ t₁, c₁, k₁, hc₁, hb₁ ⟩ := h₁
  obtain ⟨ t₂, c₂, k₂, hc₂, hb₂ ⟩ := h₂
  use fun q => t₁ (t₂ q), c₁ * (c₂ + 1) ^ k₁, k₂ * k₁;
  refine' ⟨ fun q => by rw [ hc₁, hc₂ ], fun q => le_trans ( hb₁ _ ) _ ⟩;
  refine' le_trans ( Nat.mul_le_mul_left _ ( Nat.pow_le_pow_left ( show T.size ( t₂ q ) + 1 ≤ ( c₂ + 1 ) * ( U.size q + 1 ) ^ k₂ from by linarith [ hb₂ q, pow_pos ( Nat.succ_pos ( U.size q ) ) k₂ ] ) _ ) ) _;
  rw [ mul_pow, pow_mul ] ; ring_nf ; norm_num

/-- A system is **p-bounded** (relative to a formula-size measure `fsize`) when
every provable formula `f` has a proof of size at most `c * (fsize f + 1) ^ k`
for fixed `c, k`. This is the abstract Cook–Reckhow notion of a *polynomially
bounded proof system*. -/
def PBounded {F : Type*} (fsize : F → ℕ) (S : ProofSys F) : Prop :=
  ∃ c k : ℕ, ∀ f, Provable S f →
    ∃ p : S.Proof, S.concl p = f ∧ S.size p ≤ c * (fsize f + 1) ^ k

-- !-- Merge the two bounds with constant `c₁+c₂` and exponent `max k₁ k₂`; sizes carry over the `Sum`. --!
/-- **Closure of p-boundedness under join.** The union of two p-bounded proof
systems is p-bounded. This is the quantitative lift of `provable_union`: the
lattice join preserves polynomial boundedness. -/
theorem pbounded_union {F : Type*} (fsize : F → ℕ) {S T : ProofSys F}
    (hS : PBounded fsize S) (hT : PBounded fsize T) :
    PBounded fsize (union S T) := by
  obtain ⟨c₁, k₁, h₁⟩ := hS
  obtain ⟨c₂, k₂, h₂⟩ := hT
  use c₁ + c₂, Nat.max k₁ k₂
  intro f hf
  simp [union] at hf ⊢
  cases hf;
  rename_i p hp;
  rcases p with ( p | p ) <;> simp_all +decide;
  · exact Or.inl ( by obtain ⟨ q, hq₁, hq₂ ⟩ := h₁ f ⟨ p, hp ⟩ ; exact ⟨ q, hq₁, hq₂.trans ( Nat.mul_le_mul_right _ ( Nat.le_add_right _ _ ) |> le_trans <| Nat.mul_le_mul_left _ ( Nat.pow_le_pow_right ( Nat.succ_pos _ ) ( Nat.le_max_left _ _ ) ) ) ⟩ );
  · exact Or.inr ( by obtain ⟨ q, hq₁, hq₂ ⟩ := h₂ f ⟨ p, hp ⟩ ; exact ⟨ q, hq₁, hq₂.trans ( Nat.mul_le_mul ( by linarith ) ( Nat.pow_le_pow_right ( by linarith ) ( by simp +decide ) ) ) ⟩ )

end ProofSystemCollapse