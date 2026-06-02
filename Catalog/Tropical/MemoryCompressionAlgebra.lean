/-
# Tropical Memory Compression Algebra

This module develops the theory connecting memory-as-compression to tropical algebra.
The central insight: the *information loss* of a memory system can be quantified
via a tropical valuation on the congruence lattice, and this valuation is monotone
under memory morphisms.

## Main Results

1. **Cascade Product**: Parallel composition of memory systems with universal property.
2. **Tropical Capacity Bound**: Cascade capacity satisfies tropical subadditivity.
3. **Tropical Image Monotonicity**: Post-composition can only shrink reachable sets.
4. **Memory Spectrum**: Novel definition measuring reachable states at each depth.
5. **Idempotent Stabilization**: Repeated input eventually reaches idempotent states.
-/
import Mathlib

open scoped Classical
open FreeMonoid

/-! ## Memory System Foundations -/

/-- A `MemorySystem` over alphabet `α` with state space `S` is a monoid homomorphism
    from the free monoid on `α` (experience streams) to `S` (compressed states). -/
structure MemorySystem (α : Type*) (S : Type*) [Monoid S] [Fintype S] where
  encode : FreeMonoid α →* S

namespace MemorySystem

variable {α : Type*} {S : Type*} [Monoid S] [Fintype S]

/-- The information loss congruence: two streams are identified iff they map
    to the same state. -/
def infoLossCon (mem : MemorySystem α S) : Con (FreeMonoid α) :=
  Con.ker mem.encode

/-- A memory system is lossy if its encoding is not injective. -/
def IsLossy (mem : MemorySystem α S) : Prop :=
  ¬Function.Injective mem.encode

end MemorySystem

/-! ## Cascade Product of Memory Systems -/

section CascadeProduct

/-- The **cascade product** of two memory systems running in parallel. -/
def cascadeProduct {α S T : Type*} [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) :
    MemorySystem α (S × T) where
  encode := MonoidHom.prod mem₁.encode mem₂.encode

/-- The cascade product identifies two words iff BOTH systems identify them. -/
theorem cascade_con_iff {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T)
    (x y : FreeMonoid α) :
    (cascadeProduct mem₁ mem₂).infoLossCon x y ↔
    mem₁.infoLossCon x y ∧ mem₂.infoLossCon x y := by
  simp only [cascadeProduct, MemorySystem.infoLossCon, Con.ker_rel,
    MonoidHom.prod_apply, Prod.mk.injEq]

/-- The cascade product refines the left component. -/
theorem cascade_refines_left {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) :
    (cascadeProduct mem₁ mem₂).infoLossCon ≤ mem₁.infoLossCon := by
  intro x y h
  exact ((cascade_con_iff mem₁ mem₂ x y).mp h).1

/-- The cascade product refines the right component. -/
theorem cascade_refines_right {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) :
    (cascadeProduct mem₁ mem₂).infoLossCon ≤ mem₂.infoLossCon := by
  intro x y h
  exact ((cascade_con_iff mem₁ mem₂ x y).mp h).2

/-- **Cascade Universality**: The cascade product is the coarsest memory system
    that refines both components. -/
theorem cascade_universal {α S T U : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T] [Monoid U] [Fintype U]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T)
    (mem₃ : MemorySystem α U)
    (h₁ : mem₃.infoLossCon ≤ mem₁.infoLossCon)
    (h₂ : mem₃.infoLossCon ≤ mem₂.infoLossCon) :
    mem₃.infoLossCon ≤ (cascadeProduct mem₁ mem₂).infoLossCon := by
  intro x y h
  exact (cascade_con_iff mem₁ mem₂ x y).mpr ⟨h₁ h, h₂ h⟩

end CascadeProduct

/-! ## Memory Compression Theorem -/

section Compression

/-- Any memory system over ≥ 2 symbols must be lossy (pigeonhole). -/
theorem memory_must_be_lossy (α : Type*) [Fintype α] (hα : 2 ≤ Fintype.card α)
    (S : Type*) [Monoid S] [Fintype S]
    (mem : MemorySystem α S) : mem.IsLossy := by
  intro h_inj
  have : Infinite (FreeMonoid α) := by
    obtain ⟨a, _, _⟩ := Fintype.one_lt_card_iff.mp hα
    exact Infinite.of_injective (fun n => List.replicate n a)
      fun m n hmn => by simpa using congr_arg List.length hmn
  exact this.not_finite (Finite.of_injective _ h_inj)

end Compression

/-! ## Tropical Image Monotonicity -/

section TropicalMonotonicity

/-- The image of a memory system's encoder as a finset. -/
noncomputable def memoryImage {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) : Finset S :=
  Finset.univ.filter (fun s => ∃ w : FreeMonoid α, mem.encode w = s)

/-
**Tropical Monotonicity**: Post-composition can only shrink the reachable set.
    In tropical log-terms: v(f ∘ φ) ≤ v(φ) where v = log|image|.
-/
theorem tropical_image_monotone {α S T : Type*}
    [Monoid S] [Fintype S] [DecidableEq S]
    [Monoid T] [Fintype T] [DecidableEq T]
    (mem₁ : MemorySystem α S) (f : S →* T)
    (mem₂ : MemorySystem α T)
    (h_comm : f.comp mem₁.encode = mem₂.encode) :
    (memoryImage mem₂).card ≤ (memoryImage mem₁).card := by
  -- By definition of memoryImage, we have
  have h_image_eq : memoryImage mem₂ = Finset.image f (memoryImage mem₁) := by
    ext; simp [memoryImage, h_comm];
    simp +decide only [← h_comm, MonoidHom.comp_apply];
  exact h_image_eq ▸ Finset.card_image_le

/-- The identity state is always in the image. -/
theorem one_mem_memoryImage {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) : (1 : S) ∈ memoryImage mem := by
  simp only [memoryImage, Finset.mem_filter, Finset.mem_univ, true_and]
  exact ⟨1, mem.encode.map_one⟩

/-- The image is nonempty. -/
theorem memoryImage_nonempty {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) : (memoryImage mem).Nonempty :=
  ⟨1, one_mem_memoryImage mem⟩

end TropicalMonotonicity

/-! ## Cascade Capacity Bounds -/

section CascadeCapacity

/-
**Cascade Capacity Upper Bound** (tropical subadditivity):
    |image(φ₁ × φ₂)| ≤ |image(φ₁)| * |image(φ₂)|.
    In tropical log-terms: log|R₁₂| ≤ log|R₁| + log|R₂|.
-/
theorem cascade_capacity_bound {α S T : Type*}
    [Monoid S] [Fintype S] [DecidableEq S]
    [Monoid T] [Fintype T] [DecidableEq T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) :
    (memoryImage (cascadeProduct mem₁ mem₂)).card ≤
    (memoryImage mem₁).card * (memoryImage mem₂).card := by
  -- The image of the cascade product is a subset of the product of the images of mem₁ and mem₂.
  have h_subset : memoryImage (cascadeProduct mem₁ mem₂) ⊆ (memoryImage mem₁ ×ˢ memoryImage mem₂).image (fun p => (p.1, p.2)) := by
    unfold memoryImage;
    simp +decide [ Finset.subset_iff, cascadeProduct ];
  exact le_trans ( Finset.card_le_card h_subset ) ( Finset.card_image_le.trans ( by rw [ Finset.card_product ] ) )

/-
**Cascade Capacity Lower Bound**: The cascade remembers at least as much
    as the left component.
-/
theorem cascade_capacity_ge_left {α S T : Type*}
    [Monoid S] [Fintype S] [DecidableEq S]
    [Monoid T] [Fintype T] [DecidableEq T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) :
    (memoryImage mem₁).card ≤ (memoryImage (cascadeProduct mem₁ mem₂)).card := by
  have h_proj : (memoryImage mem₁) = (memoryImage (cascadeProduct mem₁ mem₂)).image (fun p : S × T => p.1) := by
    ext; simp [memoryImage];
    exact ⟨ fun ⟨ w, hw ⟩ => ⟨ w, hw ⟩, fun ⟨ w, hw ⟩ => ⟨ w, hw ⟩ ⟩;
  exact h_proj ▸ Finset.card_image_le

end CascadeCapacity

/-! ## Idempotent Stabilization

In a finite monoid, every element has a power that is idempotent.
For memory systems, this means repeated input eventually stabilizes.
-/

section IdempotentStabilization

/-
In a finite monoid, some positive power of any element is idempotent:
    s^(2n) = s^n. This follows from the pigeonhole principle on the sequence
    s, s², s³, ... in a finite set.
-/
theorem exists_idempotent_power (S : Type*) [Monoid S] [Fintype S]
    (s : S) : ∃ n : ℕ, 0 < n ∧ s ^ (2 * n) = s ^ n := by
  -- By the pigeonhole principle, since S is finite, the sequence s^1, s^2, ... must eventually repeat.
  have h_pigeonhole : ∃ i j, i < j ∧ s ^ i = s ^ j := by
    by_contra h_no_repeat;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h_no_repeat ⟨ j, i, hi, hij.symm ⟩ ) ( not_lt.1 fun hj => h_no_repeat ⟨ i, j, hj, hij ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ );
  obtain ⟨ i, j, hij, h ⟩ := h_pigeonhole; use ( j - i ) * ( j - i + i ) ; simp_all +decide [ ← pow_add, two_mul, add_assoc, le_of_lt hij ] ;
  have h_exp : ∀ k ≥ i, s ^ (k + (j - i)) = s ^ k := by
    intro k hk; induction hk <;> simp_all +decide [ pow_add, Nat.succ_add, le_of_lt ] ;
  refine' ⟨ pos_of_gt hij, _ ⟩
  have h_exp : ∀ k ≥ i, s ^ (k + (j - i) * (j - i + i)) = s ^ k := by
    intro k hk; induction' j - i + i with k hk ih <;> simp_all +decide [ Nat.mul_succ, ← add_assoc ] ;
    rw [ h_exp _ ( by nlinarith [ Nat.sub_pos_of_lt hij ] ), hk ];
  convert h_exp ( ( j - i ) * j ) ( by nlinarith [ Nat.sub_add_cancel hij.le ] ) using 1 ; ring;
  rw [ show ( j - i ) * j * 2 = ( j - i ) * j + ( j - i ) * i + ( j - i ) ^ 2 by nlinarith [ Nat.sub_add_cancel hij.le ] ]

/-- **Memory Idempotent Stabilization**: For any input symbol a, repeating it
    enough times produces an idempotent memory state. -/
theorem memory_idempotent_stabilization {α S : Type*}
    [Monoid S] [Fintype S]
    (mem : MemorySystem α S) (a : α) :
    ∃ n : ℕ, 0 < n ∧
    mem.encode (FreeMonoid.of a ^ (2 * n)) =
    mem.encode (FreeMonoid.of a ^ n) := by
  obtain ⟨n, hn, hid⟩ := exists_idempotent_power S (mem.encode (FreeMonoid.of a))
  exact ⟨n, hn, by rwa [map_pow, map_pow]⟩

end IdempotentStabilization

/-! ## Novel Definition: Memory Spectrum

The **memory spectrum** of a memory system φ is the function
  spectrum(k) = |{φ(w) : |w| ≤ k}|
counting how many distinct states are reachable by words of length at most k.
-/

section MemorySpectrum

/-- The cumulative memory spectrum: states reachable by words of length ≤ k. -/
noncomputable def cumulativeSpectrum {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) (k : ℕ) : Finset S :=
  Finset.univ.filter (fun s => ∃ w : FreeMonoid α, List.length w ≤ k ∧ mem.encode w = s)

/-- The cumulative spectrum is monotonically non-decreasing. -/
theorem cumulativeSpectrum_mono {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) {j k : ℕ} (hjk : j ≤ k) :
    cumulativeSpectrum mem j ⊆ cumulativeSpectrum mem k := by
  intro s hs
  simp only [cumulativeSpectrum, Finset.mem_filter] at hs ⊢
  obtain ⟨hs_univ, w, hw_len, hw_enc⟩ := hs
  exact ⟨hs_univ, w, le_trans hw_len hjk, hw_enc⟩

/-
The spectrum at depth 0 contains exactly the identity.
-/
theorem spectrum_zero_eq {α S : Type*} [Monoid S] [Fintype S] [DecidableEq S]
    (mem : MemorySystem α S) :
    cumulativeSpectrum mem 0 = {1} := by
  ext s
  simp [cumulativeSpectrum];
  exact ⟨ fun h => h.symm.trans ( mem.encode.map_one ), fun h => h.symm ▸ mem.encode.map_one ⟩

/-- The spectrum card is monotone. -/
theorem spectrum_card_mono {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) {j k : ℕ} (hjk : j ≤ k) :
    (cumulativeSpectrum mem j).card ≤ (cumulativeSpectrum mem k).card :=
  Finset.card_le_card (cumulativeSpectrum_mono mem hjk)

/-- The spectrum is bounded by |S|. -/
theorem spectrum_bounded {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) (k : ℕ) :
    (cumulativeSpectrum mem k).card ≤ Fintype.card S :=
  Finset.card_le_univ _

end MemorySpectrum

/-! ## The Trivial and Free Memory Systems -/

section Extremal

/-- The **trivial memory** maps everything to unit — total amnesia. -/
def trivialMemory (α : Type*) : MemorySystem α Unit where
  encode :=
    { toFun := fun _ => ()
      map_one' := rfl
      map_mul' := fun _ _ => rfl }

/-- The trivial memory identifies everything. -/
theorem trivial_identifies_all (α : Type*) (x y : FreeMonoid α) :
    (trivialMemory α).infoLossCon x y := by
  show () = ()
  rfl

end Extremal

/-! ## Congruence-State Duality -/

section Duality

/-- Two words are congruent iff they encode to the same state. -/
theorem congruence_iff_same_state {α S : Type*} [Monoid S] [Fintype S]
    (mem : MemorySystem α S) (x y : FreeMonoid α) :
    mem.infoLossCon x y ↔ mem.encode x = mem.encode y :=
  Con.ker_rel _

/-- Memory morphism: a monoid hom f : S →* T commuting with encoders. -/
structure MemoryMorphism {α : Type*}
    {S : Type*} [Monoid S] [Fintype S]
    {T : Type*} [Monoid T] [Fintype T]
    (mem₁ : MemorySystem α S) (mem₂ : MemorySystem α T) where
  map : S →* T
  commutes : map.comp mem₁.encode = mem₂.encode

/-- A memory morphism implies the target forgets at least as much. -/
theorem morphism_increases_forgetting {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    {mem₁ : MemorySystem α S} {mem₂ : MemorySystem α T}
    (f : MemoryMorphism mem₁ mem₂) :
    mem₁.infoLossCon ≤ mem₂.infoLossCon := by
  intro x y hxy
  rw [congruence_iff_same_state] at hxy ⊢
  have : f.map (mem₁.encode x) = f.map (mem₁.encode y) := congr_arg f.map hxy
  rwa [← MonoidHom.comp_apply, ← MonoidHom.comp_apply, f.commutes] at this

end Duality

/-! ## Composition Monotonicity -/

section CompositionMonotonicity

/-- Post-composition with any monoid hom can only increase information loss. -/
theorem info_loss_monotone_compose {α S T : Type*}
    [Monoid S] [Fintype S] [Monoid T] [Fintype T]
    (mem : MemorySystem α S) (f : S →* T) :
    mem.infoLossCon ≤
    (MemorySystem.mk (f.comp mem.encode) : MemorySystem α T).infoLossCon := by
  intro x y hxy
  show f (mem.encode x) = f (mem.encode y)
  exact congr_arg f hxy

end CompositionMonotonicity

/-! ## Conjecture: Tropical Spectral Gap

**Conjecture**: For a memory system φ : FreeMonoid α →* S where |α| = k ≥ 2 and |S| = m,
the memory spectrum stabilizes by depth m - 1. That is, cumulativeSpectrum φ (m-1) =
memoryImage φ.

**Test**: Construct a concrete memory system with k=2, m=4 over ℤ/4ℤ. The spectrum
should stabilize by depth 3.
-/