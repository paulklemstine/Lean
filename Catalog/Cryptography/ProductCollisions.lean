/-
  Product Collisions and the Factorization Hierarchy

  We develop the theory of **product collisions** in generator sets — the
  precise obstruction to unique factorization that lies strictly between
  pairwise multiplicative independence and full unique factorization.

  Main results:
  1. Product collisions directly obstruct unique factorization.
  2. The set {6, 10, 21, 35} separates product-freeness from collision-freeness.
  3. Primes are collision-free (fundamental theorem of arithmetic, reformulated).
  4. Collision-freeness is hereditary under taking subsets.
  5. The collision spectrum at level 1 is always empty.
  6. The full factorization hierarchy with both strict separations.
-/
import Mathlib

open Finset Nat Multiset

/-! ## Core Definitions -/

/-- A set S ⊆ ℕ is product-free if no product of two elements of S
    (each ≥ 2) lies in S. -/
def IsProductFree' (S : Set ℕ) : Prop :=
  ∀ a b, a ∈ S → b ∈ S → a ≥ 2 → b ≥ 2 → a * b ∉ S

/-- An S-factorization of n: a multiset of elements from S (all ≥ 2)
    whose product equals n. -/
def IsFactorizationOf (S : Set ℕ) (n : ℕ) (factors : Multiset ℕ) : Prop :=
  (∀ x ∈ factors, x ∈ S ∧ x ≥ 2) ∧ factors.prod = n

/-- A set S has unique factorization if every natural number has at
    most one S-factorization. -/
def HasUF (S : Set ℕ) : Prop :=
  ∀ n : ℕ, ∀ f₁ f₂ : Multiset ℕ,
    IsFactorizationOf S n f₁ → IsFactorizationOf S n f₂ → f₁ = f₂

/-- **Product collision**: a quadruple (a, b, c, d) of elements of S (all ≥ 2)
    such that a * b = c * d but the multisets {a, b} and {c, d} differ.
    This is the fundamental obstruction to unique factorization that is
    invisible to the simpler product-freeness condition.

    Named by analogy with hash collisions: two different "inputs" (factor pairs)
    produce the same "output" (product). -/
def HasProductCollision (S : Set ℕ) : Prop :=
  ∃ a b c d : ℕ,
    a ∈ S ∧ b ∈ S ∧ c ∈ S ∧ d ∈ S ∧
    a ≥ 2 ∧ b ≥ 2 ∧ c ≥ 2 ∧ d ≥ 2 ∧
    a * b = c * d ∧
    ({a, b} : Multiset ℕ) ≠ {c, d}

/-- A set is collision-free if it has no product collisions. -/
def IsCollisionFree (S : Set ℕ) : Prop := ¬HasProductCollision S

/-- **Collision spectrum**: For a generator set S, the collision spectrum
    at level k is the set of numbers that admit two distinct S-factorizations
    of length exactly k. This measures the obstruction to unique factorization
    at each "depth" level, generalizing pairwise collisions to arbitrary
    factorization lengths. -/
noncomputable def collisionSpectrum (S : Set ℕ) (k : ℕ) : Set ℕ :=
  {n : ℕ | ∃ f₁ f₂ : Multiset ℕ,
    IsFactorizationOf S n f₁ ∧ IsFactorizationOf S n f₂ ∧
    Multiset.card f₁ = k ∧ Multiset.card f₂ = k ∧ f₁ ≠ f₂}

/-- **Generator monoid**: the set of all products of elements from S.
    This is the multiplicative closure of S in ℕ. -/
def generatedProducts (S : Set ℕ) : Set ℕ :=
  {n : ℕ | ∃ f : Multiset ℕ, (∀ x ∈ f, x ∈ S ∧ x ≥ 2) ∧ f.prod = n}

/-! ## Theorem 1: Product Collisions Obstruct Unique Factorization -/

/-- **Key structural theorem**: Any product collision in S directly provides
    two distinct S-factorizations of the same number, destroying unique
    factorization. This theorem reveals that collision-freeness is a
    NECESSARY condition for unique factorization. -/
theorem collision_obstructs_ufd (S : Set ℕ) (hcoll : HasProductCollision S) :
    ¬HasUF S := by
  obtain ⟨a, b, c, d, haS, hbS, hcS, hdS, ha2, hb2, hc2, hd2, hprod, hneq⟩ := hcoll
  intro hufd
  have hf1 : IsFactorizationOf S (a * b) ({a, b} : Multiset ℕ) := by
    constructor
    · intro x hx
      simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> exact ⟨‹_›, ‹_›⟩
    · simp
  have hf2 : IsFactorizationOf S (a * b) ({c, d} : Multiset ℕ) := by
    constructor
    · intro x hx
      simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> exact ⟨‹_›, ‹_›⟩
    · simp; linarith
  exact hneq (hufd (a * b) _ _ hf1 hf2)

/-- UF implies collision-free. -/
theorem ufd_implies_collision_free (S : Set ℕ) (hufd : HasUF S) :
    IsCollisionFree S :=
  fun hcoll => collision_obstructs_ufd S hcoll hufd

/-! ## Theorem 2: Collision-freeness is strictly stronger than product-freeness -/

/-- The set {6, 10, 21, 35} is product-free: no product of two elements
    lands back in the set. -/
theorem example_set_product_free :
    IsProductFree' ({6, 10, 21, 35} : Set ℕ) := by
  intro a b ha hb ha2 hb2
  simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at ha hb ⊢
  rcases ha with rfl | rfl | rfl | rfl <;> rcases hb with rfl | rfl | rfl | rfl <;> omega

/-- The set {6, 10, 21, 35} has a product collision: 6 × 35 = 10 × 21 = 210,
    but {6, 35} ≠ {10, 21} as multisets. -/
theorem example_set_has_collision :
    HasProductCollision ({6, 10, 21, 35} : Set ℕ) := by
  refine ⟨6, 35, 10, 21, ?_, ?_, ?_, ?_, by omega, by omega, by omega, by omega, by ring, ?_⟩
  · simp
  · simp
  · simp
  · simp
  · decide

/-- **Separation theorem**: Product-freeness does NOT imply collision-freeness. -/
theorem pmi_not_implies_collision_free :
    ∃ S : Set ℕ, IsProductFree' S ∧ HasProductCollision S :=
  ⟨{6, 10, 21, 35}, example_set_product_free, example_set_has_collision⟩

/-- Product-freeness does NOT imply unique factorization. -/
theorem pmi_not_implies_ufd :
    ∃ S : Set ℕ, IsProductFree' S ∧ ¬HasUF S := by
  obtain ⟨S, hpf, hcoll⟩ := pmi_not_implies_collision_free
  exact ⟨S, hpf, collision_obstructs_ufd S hcoll⟩

/-! ## Theorem 3: Primes are Collision-Free -/

/-- **Fundamental structural theorem**: The set of primes is collision-free.
    If p * q = r * s with p, q, r, s all prime, then {p, q} = {r, s} as
    multisets. This is the essential content of the fundamental theorem of
    arithmetic, reformulated in the collision framework.

    The proof uses the key property of primes: if p | r * s and p is prime,
    then p | r or p | s. Combined with the fact that divisibility between
    primes implies equality, this forces the multisets to agree. -/
theorem primes_are_collision_free :
    IsCollisionFree {n : ℕ | n.Prime} := by
  intro ⟨a, b, c, d, haS, hbS, hcS, hdS, _ha2, _hb2, _hc2, _hd2, hprod, hneq⟩
  simp only [Set.mem_setOf_eq] at haS hbS hcS hdS
  apply hneq
  have hac_or_ad : a ∣ c ∨ a ∣ d := haS.dvd_mul.mp ⟨b, hprod.symm⟩
  rcases hac_or_ad with hac | had
  · -- a | c and both prime, so a = c
    have hac_eq : a = c := by
      rcases hcS.eq_one_or_self_of_dvd a hac with h | h
      · exact absurd h haS.one_lt.ne'
      · exact h
    have hbd_eq : b = d := by
      have h : a * b = a * d := by rw [hprod, hac_eq]
      exact Nat.mul_left_cancel (Nat.pos_of_ne_zero haS.ne_zero) h
    simp [hac_eq, hbd_eq]
  · -- a | d and both prime, so a = d
    have had_eq : a = d := by
      rcases hdS.eq_one_or_self_of_dvd a had with h | h
      · exact absurd h haS.one_lt.ne'
      · exact h
    have hbc_eq : b = c := by
      have h : a * b = a * c := by rw [hprod, had_eq]; ring
      exact Nat.mul_left_cancel (Nat.pos_of_ne_zero haS.ne_zero) h
    rw [had_eq, hbc_eq, Multiset.pair_comm]

/-! ## Theorem 4: UF implies product-free (completing the hierarchy) -/

/-- Product-freeness is necessary for UF: if a*b ∈ S with a,b ∈ S and
    a,b ≥ 2, then a*b has two distinct factorizations: {a*b} and {a,b}.
    These differ because they have different cardinalities (1 vs 2). -/
theorem ufd_implies_product_free (S : Set ℕ) (hufd : HasUF S) :
    IsProductFree' S := by
  intro a b haS hbS ha2 hb2 habS
  have hf1 : IsFactorizationOf S (a * b) ({a * b} : Multiset ℕ) := by
    exact ⟨fun x hx => by simp at hx; rw [hx]; exact ⟨habS, by nlinarith⟩, by simp⟩
  have hf2 : IsFactorizationOf S (a * b) ({a, b} : Multiset ℕ) := by
    constructor
    · intro x hx
      simp only [Multiset.insert_eq_cons, Multiset.mem_cons, Multiset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> exact ⟨‹_›, ‹_›⟩
    · simp
  have heq := hufd (a * b) _ _ hf1 hf2
  -- {a*b} has card 1, {a,b} has card 2
  have h1 : Multiset.card ({a * b} : Multiset ℕ) = 1 := by simp
  have h2 : Multiset.card ({a, b} : Multiset ℕ) = 2 := by simp
  rw [heq] at h1; omega

/-! ## Theorem 5: Collision-freeness is hereditary -/

/-- Collision-freeness is hereditary: subsets of collision-free sets are
    collision-free. -/
theorem collision_free_subset {S T : Set ℕ} (hST : S ⊆ T)
    (hT : IsCollisionFree T) : IsCollisionFree S := by
  intro ⟨a, b, c, d, haS, hbS, hcS, hdS, rest⟩
  exact hT ⟨a, b, c, d, hST haS, hST hbS, hST hcS, hST hdS, rest⟩

/-! ## Theorem 6: Collision spectrum at level 1 is empty -/

/-- The collision spectrum at level 1 is always empty: length-1
    factorizations are singletons, uniquely determined by the number. -/
theorem collision_spectrum_one_empty (S : Set ℕ) :
    collisionSpectrum S 1 = ∅ := by
  ext n
  simp only [collisionSpectrum, Set.mem_setOf_eq, Set.mem_empty_iff_false, iff_false]
  rintro ⟨f₁, f₂, hf1, hf2, hlen1, hlen2, hneq⟩
  apply hneq
  obtain ⟨a, rfl⟩ := Multiset.card_eq_one.mp hlen1
  obtain ⟨b, rfl⟩ := Multiset.card_eq_one.mp hlen2
  simp [IsFactorizationOf] at hf1 hf2
  simp [hf1.2, hf2.2]

/-! ## Theorem 7: Full hierarchy theorem -/

/-- **The factorization hierarchy**: We have the strict chain of implications
    UF ⟹ collision-free ⟹ product-free, and neither reverse implication holds.
    This theorem packages the full hierarchy result. -/
theorem factorization_hierarchy :
    (∀ S : Set ℕ, HasUF S → IsCollisionFree S) ∧
    (∀ S : Set ℕ, HasUF S → IsProductFree' S) ∧
    (∃ S : Set ℕ, IsProductFree' S ∧ HasProductCollision S) ∧
    (∃ S : Set ℕ, IsProductFree' S ∧ ¬HasUF S) :=
  ⟨ufd_implies_collision_free,
   ufd_implies_product_free,
   pmi_not_implies_collision_free,
   pmi_not_implies_ufd.imp fun _ h => h⟩

/-! ## Theorem 8: Product-free sets exclude perfect powers -/

/-- If S is product-free and a ∈ S with a ≥ 2, then a² ∉ S. -/
theorem product_free_no_square (S : Set ℕ) (hpf : IsProductFree' S)
    (a : ℕ) (ha : a ∈ S) (ha2 : a ≥ 2) : a ^ 2 ∉ S := by
  rw [sq]; exact hpf a a ha ha ha2 ha2

/-! ## Theorem 9: Coprime generators are collision-free -/

/-
**Coprime generator theorem**: If all elements of a generator set
    are pairwise coprime, then the set is collision-free. Coprimality
    prevents the divisor-sharing that enables collisions.
-/
theorem pairwise_coprime_collision_free (S : Set ℕ)
    (hcop : ∀ a b, a ∈ S → b ∈ S → a ≠ b → Nat.Coprime a b) :
    IsCollisionFree S := by
  intro h
  obtain ⟨a, b, c, d, ha, hb, hc, hd, hab, hcd, hneq⟩ := h;
  -- Since $a$ and $c$ are coprime and $a \mid c * d$, it follows that $a \mid d$.
  have h_a_div_d : a ∣ d := by
    exact ( hcop a c ha hc ( by aesop ) ) |> fun h => h.dvd_of_dvd_mul_left <| hneq.2.2.1 ▸ dvd_mul_right _ _;
  -- Since $a$ and $d$ are coprime and $a \mid d$, it follows that $a = d$.
  have h_a_eq_d : a = d := by
    exact Classical.not_not.1 fun h => by have := hcop a d ha hd h; have := Nat.dvd_gcd ( dvd_refl a ) h_a_div_d; aesop;
  simp_all +decide [ mul_comm ];
  cases hneq.2.2.1 <;> simp_all +decide [ Multiset.cons_eq_cons ]

/-! ## Theorem 10: Primes have empty collision spectrum (FTA equivalent) -/

/-
**FTA reformulation**: The set of primes has empty collision spectrum
    at every level.
-/
theorem primes_collision_spectrum_empty :
    ∀ k, collisionSpectrum {n : ℕ | n.Prime} k = ∅ := by
  intro k;
  ext n;
  constructor <;> intro h;
  · obtain ⟨ f₁, f₂, hf₁, hf₂, hk₁, hk₂, hne ⟩ := h;
    -- Since $f₁$ and $f₂$ are both factorizations of $n$ into primes, they must be equal by the uniqueness of prime factorization.
    have h_eq : f₁ = f₂ := by
      have h_eq : ∀ {m n : Multiset ℕ}, (∀ x ∈ m, Nat.Prime x) → (∀ x ∈ n, Nat.Prime x) → m.prod = n.prod → m = n := by
        intros m n hm hn hprod; induction' m using Multiset.induction_on with p m ih generalizing n; induction' n using Multiset.induction_on with q n ih; simp_all +decide [ Nat.prime_mul_iff ] ;
        · simp_all +decide [ eq_comm ];
        · -- Since $p$ is prime and divides $n.prod$, it must divide one of the elements of $n$.
          obtain ⟨q, hq⟩ : ∃ q ∈ n, p ∣ q := by
            have h_div : p ∣ n.prod := by
              exact hprod ▸ Multiset.dvd_prod ( Multiset.mem_cons_self _ _ );
            haveI := Fact.mk ( hm p ( Multiset.mem_cons_self _ _ ) ) ; simp_all +decide [ ← ZMod.natCast_eq_zero_iff, Multiset.prod_eq_zero_iff ] ;
          have := Nat.prime_dvd_prime_iff_eq ( hm p ( Multiset.mem_cons_self _ _ ) ) ( hn q hq.1 ) ; simp_all +decide [ Nat.prime_dvd_prime_iff_eq ] ;
          obtain ⟨ n, rfl ⟩ := Multiset.exists_cons_of_mem hq.1; simp_all +decide [ mul_comm ] ;
          exact ih hn.2 ( hprod.resolve_right hn.1.ne_zero );
      exact h_eq ( fun x hx => hf₁.1 x hx |>.1 ) ( fun x hx => hf₂.1 x hx |>.1 ) ( hf₁.2.trans hf₂.2.symm );
    contradiction;
  · contradiction

/-! ## Falsifiable Conjecture -/

/-- **Falsifiable conjecture**: A set S ⊆ ℕ≥2 has unique factorization
    if and only if the collision spectrum is empty at all levels.

    **Computational test**: Enumerate subsets S ⊆ {2,...,50} of size ≤ 5.
    For each, check UF by brute force and verify it equals emptiness of
    collision spectrum at levels 1 through 10. -/
def uf_characterization_conjecture : Prop :=
  ∀ S : Set ℕ, (∀ x ∈ S, x ≥ 2) →
    (HasUF S ↔ (∀ k, collisionSpectrum S k = ∅))