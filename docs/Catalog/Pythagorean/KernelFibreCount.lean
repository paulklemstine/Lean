import Pythagorean.KernelBlockCount
import Pythagorean.KernelTwoBlocks

/-!
# Fibres of the kernel invariant, falling factorials, and surjection counts

The map `KernelPattern.canon : (Fin n → β) → (Fin n → Fin n)` sends a tuple to its kernel
pattern.  This file computes the size of each fibre and draws the classical consequences.

* `KernelPattern.fibreEquiv` : the fibre of `canon` over a pattern `p` is in bijection with
  the embeddings of the block set of `p` into `β` — choosing a tuple with a prescribed
  equality pattern is exactly choosing distinct values for the blocks;
* `KernelPattern.card_fibre_canon` : hence the fibre has `descFactorial` many elements;
* `KernelPattern.pow_eq_sum_stirling2_descFactorial` : the classical polynomial identity
  `xⁿ = ∑ₖ S(n,k) · x^{(k)}` (falling factorials) in the form
  `(card β)ⁿ = ∑ₖ S(n,k) · (card β)^{(k)}`;
* `KernelPattern.card_surjective_eq` : the number of surjections `Fin n → Fin k` is
  `k! · S(n,k)`.

These bridge the combinatorics of kernel patterns with the enumeration of embeddings
(`Fintype.card_embedding_eq`).
-/

open Finset

namespace KernelPattern

variable {n : ℕ} {β : Type*} [Fintype β] [DecidableEq β]

/-- Every block label of a pattern is a fixed point of the pattern. -/
theorem pattern_fixed {p : Fin n → Fin n} (hp : canon p = p) {a : Fin n}
    (ha : a ∈ univ.image p) : p a = a := by
  obtain ⟨i, -, rfl⟩ := Finset.mem_image.1 ha
  have := canon_canon_apply p i
  rwa [hp] at this

/-- **The fibre of the kernel invariant.**  Tuples with kernel pattern `p` are exactly the
injective assignments of values to the blocks of `p`. -/
def fibreEquiv {p : Fin n → Fin n} (hp : canon p = p) :
    {f : Fin n → β // canon f = p} ≃ ({x : Fin n // x ∈ univ.image p} ↪ β) where
  toFun f :=
    ⟨fun x => f.1 x.1, by
      rintro ⟨x, hx⟩ ⟨y, hy⟩ hxy
      have h : canon f.1 x = canon f.1 y := (eq_iff_canon_eq f.1 x y).1 hxy
      rw [f.2, pattern_fixed hp hx, pattern_fixed hp hy] at h
      exact Subtype.ext h⟩
  invFun e :=
    ⟨fun i => e ⟨p i, Finset.mem_image_of_mem p (Finset.mem_univ i)⟩, by
      have hker :
          Ker (fun i => e ⟨p i, Finset.mem_image_of_mem p (Finset.mem_univ i)⟩) = Ker p := by
        rw [ker_eq_iff]
        intro i j
        constructor
        · intro h
          exact congrArg Subtype.val (e.injective h)
        · intro h
          exact congrArg e (Subtype.ext h)
      rw [canon_congr hker, hp]⟩
  left_inv := by
    rintro ⟨f, hf⟩
    apply Subtype.ext
    funext i
    have h : canon f i = p i := by rw [hf]
    show f (p i) = f i
    rw [← h]
    exact apply_canon f i
  right_inv := by
    intro e
    apply Function.Embedding.ext
    rintro ⟨x, hx⟩
    exact congrArg e (Subtype.ext (pattern_fixed hp hx))

/-- **The fibre count.**  There are `(card β)^{(k)}` tuples `Fin n → β` with a prescribed
kernel pattern with `k` blocks, where `x^{(k)}` denotes the falling factorial. -/
theorem card_fibre_canon {p : Fin n → Fin n} (hp : p ∈ Patterns n) :
    ((univ : Finset (Fin n → β)).filter (fun f => canon f = p)).card
      = (Fintype.card β).descFactorial (nblocks p) := by
  have hsub : ((univ : Finset (Fin n → β)).filter (fun f => canon f = p)).card
      = Fintype.card {f : Fin n → β // canon f = p} :=
    (Fintype.card_subtype _).symm
  rw [hsub, Fintype.card_congr (fibreEquiv (β := β) (mem_patterns_iff.1 hp)),
    Fintype.card_embedding_eq, Fintype.card_coe, nblocks]

/-- **The falling-factorial expansion.**  `xⁿ = ∑ₖ S(n,k)·x^{(k)}` for `x = card β`:
classifying tuples by their kernel pattern turns the count of all tuples into a sum of
falling factorials. -/
theorem pow_eq_sum_stirling2_descFactorial (n : ℕ) :
    (Fintype.card β) ^ n
      = ∑ k ∈ range (n + 1), stirling2 n k * (Fintype.card β).descFactorial k := by
  classical
  have h1 : (Fintype.card β) ^ n = (univ : Finset (Fin n → β)).card := by
    rw [Finset.card_univ, Fintype.card_fun, Fintype.card_fin]
  rw [h1, Finset.card_eq_sum_card_fiberwise
      (f := fun f : Fin n → β => canon f) (t := Patterns n) (fun f _ => canon_mem_patterns f),
    Finset.sum_congr rfl (fun p hp => card_fibre_canon (β := β) hp),
    ← Finset.sum_fiberwise_of_maps_to (g := nblocks) (t := range (n + 1))
      (fun p _ => Finset.mem_range.2 (Nat.lt_succ_of_le (nblocks_le p)))
      (fun p => (Fintype.card β).descFactorial (nblocks p))]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [Finset.sum_congr rfl (fun p hp => by
      rw [(Finset.mem_filter.1 hp).2] :
      ∀ p ∈ (Patterns n).filter (fun p => nblocks p = k),
        (Fintype.card β).descFactorial (nblocks p) = (Fintype.card β).descFactorial k),
    Finset.sum_const, smul_eq_mul, stirling2]

/-- A pattern is realised by a tuple over `β` exactly when it has at most `card β` blocks:
the "if" direction, which is what the fibre count gives. -/
theorem exists_canon_eq {p : Fin n → Fin n} (hp : p ∈ Patterns n)
    (hle : nblocks p ≤ Fintype.card β) : ∃ f : Fin n → β, canon f = p := by
  have hpos : 0 < ((univ : Finset (Fin n → β)).filter (fun f => canon f = p)).card := by
    rw [card_fibre_canon hp]
    exact Nat.descFactorial_pos.2 hle
  obtain ⟨f, hf⟩ := Finset.card_pos.1 hpos
  exact ⟨f, (Finset.mem_filter.1 hf).2⟩

/-- Surjectivity of a tuple is a property of its kernel pattern: `f : Fin n → Fin k` is
surjective exactly when its pattern has `k` blocks. -/
theorem surjective_iff_nblocks {k : ℕ} (f : Fin n → Fin k) :
    Function.Surjective f ↔ nblocks (canon f) = k := by
  rw [nblocks, card_image_canon f]
  constructor
  · intro hf
    have : (univ.image f) = univ := by
      refine Finset.eq_univ_iff_forall.2 fun b => ?_
      obtain ⟨i, rfl⟩ := hf b
      exact Finset.mem_image_of_mem f (Finset.mem_univ i)
    rw [this, Finset.card_univ, Fintype.card_fin]
  · intro hcard
    have : (univ.image f) = univ := by
      refine (Finset.card_eq_iff_eq_univ _).1 ?_
      rw [hcard, Fintype.card_fin]
    intro b
    obtain ⟨i, -, hi⟩ := Finset.mem_image.1 (this ▸ Finset.mem_univ b)
    exact ⟨i, hi⟩

/-- **The number of surjections.**  There are `k! · S(n,k)` surjections `Fin n → Fin k`. -/
theorem card_surjective_eq (n k : ℕ) :
    ((univ : Finset (Fin n → Fin k)).filter (fun f => Function.Surjective f)).card
      = Nat.factorial k * stirling2 n k := by
  classical
  set T : Finset (Fin n → Fin n) := (Patterns n).filter (fun p => nblocks p = k) with hT
  have hmaps : ∀ f ∈ (univ : Finset (Fin n → Fin k)).filter (fun f => Function.Surjective f),
      canon f ∈ T := by
    intro f hf
    have hs : Function.Surjective f := (Finset.mem_filter.1 hf).2
    exact Finset.mem_filter.2 ⟨canon_mem_patterns f, (surjective_iff_nblocks f).1 hs⟩
  rw [Finset.card_eq_sum_card_fiberwise hmaps]
  have hfib : ∀ p ∈ T,
      (((univ : Finset (Fin n → Fin k)).filter (fun f => Function.Surjective f)).filter
        (fun f => canon f = p)).card = Nat.factorial k := by
    intro p hp
    obtain ⟨hpat, hbl⟩ := Finset.mem_filter.1 hp
    have hset : (((univ : Finset (Fin n → Fin k)).filter (fun f => Function.Surjective f)).filter
        (fun f => canon f = p)) = (univ : Finset (Fin n → Fin k)).filter (fun f => canon f = p) := by
      ext f
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      constructor
      · rintro ⟨-, h⟩
        exact h
      · intro h
        exact ⟨(surjective_iff_nblocks f).2 (by rw [h, hbl]), h⟩
    rw [hset, card_fibre_canon (β := Fin k) hpat, hbl, Fintype.card_fin,
      Nat.descFactorial_self]
  rw [Finset.sum_congr rfl hfib, Finset.sum_const, smul_eq_mul, hT, ← stirling2, mul_comm]

/-- The number of surjections `Fin n → Fin n` is `n !`: the pattern must be the discrete one. -/
theorem card_surjective_self (n : ℕ) :
    ((univ : Finset (Fin n → Fin n)).filter (fun f => Function.Surjective f)).card
      = Nat.factorial n := by
  rw [card_surjective_eq n n, stirling2_self, mul_one]

/-- Specialising the falling-factorial expansion to `β = Fin m`. -/
theorem pow_eq_sum_stirling2_descFactorial_nat (n m : ℕ) :
    m ^ n = ∑ k ∈ range (n + 1), stirling2 n k * m.descFactorial k := by
  have := pow_eq_sum_stirling2_descFactorial (β := Fin m) n
  simpa using this

end KernelPattern