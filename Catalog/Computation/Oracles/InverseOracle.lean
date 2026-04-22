import Mathlib

/-! # CatalogBuild.Computation.Oracles.InverseOracle

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 22
-/


/-- An inverse oracle for `f : α → β` maps each output back to the set of all preimages. -/
structure InverseOracle (α β : Type*) where
  func : α → β
  invert : β → Set α
  correct : ∀ y : β, ∀ x : α, x ∈ invert y ↔ func x = y

namespace InverseOracle




/-- Construct the canonical inverse oracle for any function. -/
def canonical (f : α → β) : InverseOracle α β where
  func := f
  invert := fun y => {x | f x = y}
  correct := fun _ _ => Iff.rfl




/-- For a bijective function, the inverse oracle returns singletons. -/
theorem bijective_singleton (f : α → β) (hf : Function.Bijective f) (y : β) :
    ∃! x, x ∈ (canonical f).invert y := by
  obtain ⟨x, hx⟩ := hf.surjective y
  exact ⟨x, hx, fun x' hx' => hf.injective (hx' ▸ hx ▸ rfl)⟩




/-- Composition of inverse oracles: if we can invert `f` and `g`, we can invert `g ∘ f`. -/
def compose (Og : InverseOracle β γ) (Of : InverseOracle α β) :
    InverseOracle α γ where
  func := Og.func ∘ Of.func
  invert := fun z => ⋃ y ∈ Og.invert z, Of.invert y
  correct := fun z x => by
    simp only [Function.comp, Set.mem_iUnion]
    constructor
    · rintro ⟨y, hy_mem, hx_mem⟩
      rw [Of.correct] at hx_mem
      rw [Og.correct] at hy_mem
      rw [hx_mem, hy_mem]
    · intro h
      exact ⟨Of.func x, (Og.correct z (Of.func x)).mpr h, (Of.correct (Of.func x) x).mpr rfl⟩




/-- The identity function has a trivial inverse oracle. -/
def identity : InverseOracle α α where
  func := id
  invert := fun y => {y}
  correct := fun y x => by simp [id]




/-- Composing with identity on the right yields the same oracle (up to function equality). -/
theorem compose_identity (O : InverseOracle α β) :
    ∀ y, (O.compose identity).invert y = O.invert y := by
  intro y
  ext x
  simp only [compose, identity, Set.mem_iUnion, Set.mem_singleton_iff]
  constructor
  · rintro ⟨a, ha, rfl⟩; exact ha
  · intro hx; exact ⟨x, hx, rfl⟩




/-- Pullback of an oracle along a function. -/
def pullback (O : Oracle β) (f : α → β) : Oracle α :=
  ⟨f ⁻¹' O.carrier⟩




/-- Pushforward of an oracle along a function. -/
def pushforward (O : Oracle α) (f : α → β) : Oracle β :=
  ⟨f '' O.carrier⟩

@[simp]



/-- [Section: # CatalogBuild.Computation.Oracles.InverseOracle
Auto-generated from theorem catalog database.
Declarations: 22] -/
theorem mem_pullback (O : Oracle β) (f : α → β) (x : α) :
    x ∈ (O.pullback f).carrier ↔ f x ∈ O.carrier := Iff.rfl

@[simp]



/-- [Section: # CatalogBuild.Computation.Oracles.InverseOracle
Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 22] -/
theorem mem_pushforward (O : Oracle α) (f : α → β) (y : β) :
    y ∈ (O.pushforward f).carrier ↔ ∃ x ∈ O.carrier, f x = y := Set.mem_image f O.carrier y

-- ============================================================
-- Pullback Functoriality
-- ============================================================




/-- Pullback along identity is the identity. -/
theorem pullback_id (O : Oracle α) : O.pullback id = O := by
  ext x; simp [pullback]




/-- Pullback is functorial: `pullback(O, g ∘ f) = pullback(pullback(O, g), f)`. -/
theorem pullback_comp (O : Oracle γ) (g : β → γ) (f : α → β) :
    O.pullback (g ∘ f) = (O.pullback g).pullback f := by
  ext x; simp [pullback]




/-- Pullback commutes with anti. -/
theorem pullback_anti (O : Oracle β) (f : α → β) :
    O.anti.pullback f = (O.pullback f).anti := by
  ext x; simp [pullback, anti]




/-- Pullback commutes with join. -/
theorem pullback_join (O₁ O₂ : Oracle β) (f : α → β) :
    (O₁.join O₂).pullback f = (O₁.pullback f).join (O₂.pullback f) := by
  ext x; simp [pullback, join, Set.mem_union]




/-- Pullback commutes with meet. -/
theorem pullback_meet (O₁ O₂ : Oracle β) (f : α → β) :
    (O₁.meet O₂).pullback f = (O₁.pullback f).meet (O₂.pullback f) := by
  ext x; simp [pullback, meet, Set.mem_inter_iff]




/-- Pushforward after pullback along a surjection recovers the original. -/
theorem pushforward_pullback_surj (O : Oracle β) (f : α → β) (hf : Function.Surjective f) :
    (O.pullback f).pushforward f = O := by
  ext y
  simp [pullback, pushforward]
  constructor
  · rintro ⟨x, hx, rfl⟩; exact hx
  · intro hy
    obtain ⟨x, rfl⟩ := hf y
    exact ⟨x, hy, rfl⟩




/-- An encoding scheme maps queries into ℕ for integer-indexed lookup.
This formalizes the "inverse stereographic projection" idea:
any mathematical domain can be projected onto the natural numbers,
allowing truth lookup by integer index. -/
structure OracleEncoding (α : Type*) where
  encode : α → ℕ
  decode : ℕ → Option α
  decode_encode : ∀ x : α, decode (encode x) = some x

namespace OracleEncoding

variable {α : Type*}




/-- Given an oracle and an encoding, produce a ℕ-indexed oracle (a subset of ℕ). -/
def natOracle (enc : OracleEncoding α) (O : Oracle α) : Set ℕ :=
  {n : ℕ | ∃ x : α, enc.encode x = n ∧ x ∈ O.carrier}




/-- **Lookup Theorem**: The encoding correctly transfers oracle membership. -/
theorem lookup_correct (enc : OracleEncoding α) (O : Oracle α) (x : α) :
    enc.encode x ∈ enc.natOracle O ↔ x ∈ O.carrier := by
  constructor
  · rintro ⟨y, hy_enc, hy_mem⟩
    have h1 : enc.decode (enc.encode x) = some y := by
      rw [← hy_enc, enc.decode_encode]
    have h2 : enc.decode (enc.encode x) = some x := enc.decode_encode x
    have : y = x := by rw [h1] at h2; exact Option.some.inj h2
    rwa [← this]
  · intro hx; exact ⟨x, rfl, hx⟩




/-- Construct an encoding from Mathlib's `Encodable` typeclass. -/
def fromEncodable [Encodable α] : OracleEncoding α where
  encode := Encodable.encode
  decode := Encodable.decode
  decode_encode := Encodable.encodek




/-- Every `Encodable` type admits oracle lookup via integers.
This is the formal statement of the "inverse stereo projection" method:
rational numbers, integers, pairs, lists, polynomials — any countable
mathematical domain can be projected onto ℕ for truth lookup. -/
theorem oracle_integer_lookup [Encodable α] (O : Oracle α) (x : α) :
    Encodable.encode x ∈ OracleEncoding.natOracle OracleEncoding.fromEncodable O ↔
    x ∈ O.carrier :=
  OracleEncoding.lookup_correct _ O x

-- Example: The primality oracle on ℕ, looked up by integer index



/-- The primality oracle: answers "yes" iff the query is prime. -/
def primeOracle : Oracle ℕ := ⟨{n | Nat.Prime n}⟩



