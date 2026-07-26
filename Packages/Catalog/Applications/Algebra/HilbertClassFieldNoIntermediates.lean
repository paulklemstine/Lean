/-
# The Hilbert class field of prime class number has no intermediate fields

Let `K` be a number field with Hilbert class field `H`, the maximal unramified abelian extension
of `K`.  Its defining arithmetic property is the **Artin reciprocity isomorphism**

  `Gal(H/K) ≃ Cl(𝒪_K)`

between the Galois group and the ideal class group of the ring of integers (see
`Catalog.Novelty.HilbertClassFieldReciprocity`, which packages this isomorphism as the load-bearing
hypothesis `e : Gal(H/K) ≃* ClassGroup 𝒪_K` and derives the degree identity `[H:K] = h_K`).

Here we push that interface one structural step further.  Suppose the class number `h_K = p` is a
**prime**.  Then:

* via Artin reciprocity, `Gal(H/K)` is a group of prime order `p`;
* a finite group of prime order has no subgroups other than `⊥` and `⊤` — this is elementary
  subgroup analysis (Lagrange: the order of a subgroup divides `p`, hence is `1` or `p`), recorded
  as `subgroup_eq_bot_or_top_of_prime_card`;
* transporting this through the Galois correspondence
  (`IsGalois.intermediateFieldEquivSubgroup`, an order-reversing isomorphism between intermediate
  fields and subgroups of the Galois group) shows that every intermediate field of `H/K` is either
  `⊥` (i.e. `K`) or `⊤` (i.e. `H`).

The main result is `hilbertClassFieldNoIntermediates`.

## Notes on the argument

* The prime-order subgroup fact is proved from scratch by Lagrange's theorem and primality, rather
  than being imported as a black box, matching item (2) of the specification.
* No appeal is made to any generic "an intermediate field of a degree-prime extension is `⊥` or `⊤`"
  lemma (there is no `intermediate_eq_bot_or_top` in scope); the conclusion is obtained directly
  from the *subgroup* dichotomy transported across the Galois correspondence, avoiding circularity
  (item (3)).
* The Artin reciprocity datum enters only through the group isomorphism `e`, exactly the interface
  established in `Catalog.Novelty.HilbertClassFieldReciprocity` (item (1)).
-/
import Mathlib

open NumberField

/-- **Subgroups of a group of prime order.**  If a group `G` has prime cardinality `p`, then every
subgroup of `G` is either the trivial subgroup `⊥` or the whole group `⊤`.

This is pure subgroup analysis: by Lagrange's theorem the order of any subgroup divides
`Nat.card G = p`, and since `p` is prime this order is `1` (forcing `⊥`) or `p` (forcing `⊤`). -/
theorem subgroup_eq_bot_or_top_of_prime_card
    {G : Type*} [Group G] {p : ℕ} (hp : p.Prime) (hG : Nat.card G = p)
    (S : Subgroup G) : S = ⊥ ∨ S = ⊤ := by
  -- `G` is finite since its cardinality `p` is nonzero.
  have hfin : Finite G := by
    have : Nat.card G ≠ 0 := by rw [hG]; exact hp.ne_zero
    exact Nat.finite_of_card_ne_zero this
  -- Lagrange: `|S|` divides `|G| = p`.
  have hdvd : Nat.card S ∣ Nat.card G := Subgroup.card_subgroup_dvd_card S
  rw [hG] at hdvd
  -- A divisor of a prime is `1` or `p`.
  rcases hp.eq_one_or_self_of_dvd _ hdvd with h1 | hpc
  · exact Or.inl (Subgroup.eq_bot_of_card_le S (le_of_eq h1))
  · exact Or.inr (Subgroup.eq_top_of_card_eq S (by rw [hpc, hG]))

/-- **The Hilbert class field of a number field with prime class number has no proper intermediate
fields.**

Let `K` be a number field and `H/K` a finite Galois extension equipped with the Artin reciprocity
isomorphism `e : Gal(H/K) ≃* Cl(𝒪_K)` characterizing `H` as the Hilbert class field of `K`.  If the
class number of `K` equals a prime `p`, then every intermediate field `L` of `H/K` is either `⊥`
(equal to `K`) or `⊤` (equal to `H`).

The proof: Artin reciprocity gives `Nat.card Gal(H/K) = h_K = p`, so `Gal(H/K)` has prime order;
`subgroup_eq_bot_or_top_of_prime_card` then leaves only `⊥` and `⊤` as subgroups, and the Galois
correspondence `IsGalois.intermediateFieldEquivSubgroup` transports this dichotomy back to
intermediate fields. -/
theorem hilbertClassFieldNoIntermediates
    (K : Type*) [Field K] [NumberField K]
    (H : Type*) [Field H] [Algebra K H] [FiniteDimensional K H] [IsGalois K H]
    (e : (H ≃ₐ[K] H) ≃* ClassGroup (RingOfIntegers K))
    (p : ℕ) (hp : p.Prime) (hclass : classNumber K = p) :
    ∀ L : IntermediateField K H, L = ⊥ ∨ L = ⊤ := by
  -- Step (1): via Artin reciprocity, the Galois group has prime order `p`.
  have hcard : Nat.card (H ≃ₐ[K] H) = p := by
    have h2 : Nat.card (H ≃ₐ[K] H) = Nat.card (ClassGroup (RingOfIntegers K)) :=
      Nat.card_congr e.toEquiv
    have h3 : Nat.card (ClassGroup (RingOfIntegers K)) = classNumber K := by
      rw [Nat.card_eq_fintype_card]; rfl
    rw [h2, h3, hclass]
  intro L
  -- The Galois correspondence: an order-reversing iso `IntermediateField K H ≃o (Subgroup Gal)ᵒᵈ`.
  set φ := IsGalois.intermediateFieldEquivSubgroup (F := K) (E := H)
  -- Step (2): the subgroup `φ L` is `⊥` or `⊤` by prime-order subgroup analysis.
  have hS := subgroup_eq_bot_or_top_of_prime_card hp hcard (OrderDual.ofDual (φ L))
  rcases hS with hbot | htop
  · -- `φ L = ⊥` as a subgroup ⇒ `φ L = ⊤` in the dual `= φ ⊤` ⇒ `L = ⊤`.
    right
    apply φ.injective
    rw [φ.map_top]
    apply OrderDual.ofDual.injective
    rw [hbot]; rfl
  · -- `φ L = ⊤` as a subgroup ⇒ `φ L = ⊥` in the dual `= φ ⊥` ⇒ `L = ⊥`.
    left
    apply φ.injective
    rw [φ.map_bot]
    apply OrderDual.ofDual.injective
    rw [htop]; rfl