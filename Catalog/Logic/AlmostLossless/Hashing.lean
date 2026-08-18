import Mathlib

/-!
# Two-universal hash families: the derandomised random codebook

Shannon's random-coding argument draws a codebook uniformly at random.  For
*almost-lossless source coding* the only property of the random codebook that
is ever used is that two fixed distinct source words collide with probability
`≤ 1/|M|`.  That is exactly **2-universality**, and it can be achieved by a
family whose seed is `k` field elements and whose evaluation costs `k`
multiplications — an honest "random number generator" with an explicit
complexity figure, as opposed to an exponentially large random codebook.

## Contents

* `AlmostLossless.TwoUniversal` : the defining counting inequality.
* `AlmostLossless.card_collides_mul_card_le` : union bound over the `|T|(|T|-1)`
  ordered pairs of a typical set `T`, giving
  `#{bad seeds} · |M| ≤ |T.offDiag| · |A|`.
* `AlmostLossless.collisionProb_le` : probability form, `P(bad seed) ≤
  |T.offDiag| / |M|`; the Monte-Carlo failure bound of the scheme.
* `AlmostLossless.exists_perfect_seed` : **derandomisation by the probabilistic
  method** — if `|M| > |T|(|T|-1)` then some seed is injective on the whole
  typical set, so the randomness can be removed entirely.
* `AlmostLossless.twoUniversal_dotHash` : a concrete instance, the inner-product
  family `h_a(x) = ∑ a i * x i` over `ZMod p`, proved 2-universal from the
  fact that a nonzero linear functional on `(ZMod p)^k` has all fibres of the
  same size.
-/

namespace AlmostLossless

open Finset

variable {S A M : Type*}

/-! ## Two-universality -/

/-- A family of hash functions `h : A → S → M`, indexed by a seed `a : A`, is
**2-universal** when any two distinct source words collide for at most a
`1/|M|` fraction of the seeds.  Written multiplicatively to stay in `ℕ`. -/
def TwoUniversal [Fintype A] [DecidableEq A] [Fintype M] [DecidableEq M]
    (h : A → S → M) : Prop :=
  ∀ x y : S, x ≠ y → #{a | h a x = h a y} * Fintype.card M ≤ Fintype.card A

/-- The stronger, *exact* property: for `x ≠ y` precisely a `1/|M|` fraction of
the seeds collide.  All the classical algebraic families satisfy it. -/
def PairwiseIndependent [Fintype A] [DecidableEq A] [Fintype M] [DecidableEq M]
    (h : A → S → M) : Prop :=
  ∀ x y : S, x ≠ y → #{a | h a x = h a y} * Fintype.card M = Fintype.card A

theorem PairwiseIndependent.twoUniversal [Fintype A] [DecidableEq A] [Fintype M]
    [DecidableEq M] {h : A → S → M} (hpi : PairwiseIndependent h) : TwoUniversal h :=
  fun x y hxy => le_of_eq (hpi x y hxy)

/-- The seed `a` is **bad** for the typical set `T`: it confuses two distinct
words of `T`. -/
def CollidesOn [DecidableEq S] [DecidableEq M] (h : A → S → M) (T : Finset S) (a : A) : Prop :=
  ∃ p ∈ T.offDiag, h a p.1 = h a p.2

instance [DecidableEq S] [DecidableEq M] (h : A → S → M) (T : Finset S) (a : A) :
    Decidable (CollidesOn h T a) := by unfold CollidesOn; infer_instance

/-- A good seed hashes the typical set injectively: this is precisely what makes
the decoder's answer unique, hence correct. -/
theorem injOn_of_not_collidesOn [DecidableEq S] [DecidableEq M] {h : A → S → M}
    {T : Finset S} {a : A} (ha : ¬ CollidesOn h T a) :
    ∀ x ∈ T, ∀ y ∈ T, h a x = h a y → x = y := by
  intro x hx y hy hxy
  by_contra hne
  exact ha ⟨(x, y), Finset.mem_offDiag.2 ⟨hx, hy, hne⟩, hxy⟩

/-- **Union bound over pairs.**  For a 2-universal family, the number of seeds
that are bad for `T` obeys `#bad · |M| ≤ |T.offDiag| · |A|`, where
`|T.offDiag| = |T|(|T|-1)` is the number of ordered pairs of distinct typical
words. -/
theorem card_collides_mul_card_le [Fintype A] [DecidableEq A] [Fintype M] [DecidableEq M]
    [DecidableEq S] {h : A → S → M} (hu : TwoUniversal h) (T : Finset S) :
    #{a | CollidesOn h T a} * Fintype.card M ≤ T.offDiag.card * Fintype.card A := by
  classical
  have hsub : ({a | CollidesOn h T a} : Finset A) ⊆
      T.offDiag.biUnion (fun p => ({a | h a p.1 = h a p.2} : Finset A)) := by
    intro a ha
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at ha
    obtain ⟨p, hp, hcol⟩ := ha
    exact Finset.mem_biUnion.2 ⟨p, hp, by simp [hcol]⟩
  have h1 : #{a | CollidesOn h T a} ≤ ∑ p ∈ T.offDiag, #{a | h a p.1 = h a p.2} :=
    le_trans (Finset.card_le_card hsub) Finset.card_biUnion_le
  calc #{a | CollidesOn h T a} * Fintype.card M
      ≤ (∑ p ∈ T.offDiag, #{a | h a p.1 = h a p.2}) * Fintype.card M :=
        Nat.mul_le_mul_right _ h1
    _ = ∑ p ∈ T.offDiag, #{a | h a p.1 = h a p.2} * Fintype.card M := by
        rw [Finset.sum_mul]
    _ ≤ ∑ _p ∈ T.offDiag, Fintype.card A := by
        refine Finset.sum_le_sum ?_
        intro p hp
        exact hu p.1 p.2 (Finset.mem_offDiag.1 hp).2.2
    _ = T.offDiag.card * Fintype.card A := by
        rw [Finset.sum_const, smul_eq_mul]

/-- Probability form of the collision bound: a uniformly random seed is bad with
probability at most `|T|(|T|-1)/|M|`.  This is *the* Monte-Carlo failure
probability of the hashing compressor. -/
theorem collisionProb_le [Fintype A] [DecidableEq A] [Nonempty A] [Fintype M] [DecidableEq M]
    [Nonempty M] [DecidableEq S] {h : A → S → M} (hu : TwoUniversal h) (T : Finset S) :
    (#{a | CollidesOn h T a} : ℚ) / (Fintype.card A : ℚ)
      ≤ (T.offDiag.card : ℚ) / (Fintype.card M : ℚ) := by
  have hA : (0 : ℚ) < (Fintype.card A : ℚ) := by exact_mod_cast Fintype.card_pos (α := A)
  rcases Nat.eq_zero_or_pos (Fintype.card M) with hM | hM
  · exfalso
    have : Fintype.card M ≠ 0 := Fintype.card_ne_zero (α := M)
    exact this hM
  have hMQ : (0 : ℚ) < (Fintype.card M : ℚ) := by exact_mod_cast hM
  rw [div_le_div_iff₀ hA hMQ]
  have := card_collides_mul_card_le hu T
  calc (#{a | CollidesOn h T a} : ℚ) * (Fintype.card M : ℚ)
      = ((#{a | CollidesOn h T a} * Fintype.card M : ℕ) : ℚ) := by push_cast; ring
    _ ≤ ((T.offDiag.card * Fintype.card A : ℕ) : ℚ) := by exact_mod_cast this
    _ = (T.offDiag.card : ℚ) * (Fintype.card A : ℚ) := by push_cast; ring

/-- **Derandomisation (probabilistic method).**  If the hash range beats the
number of ordered pairs of typical words then *some* seed is injective on the
whole typical set, and the compressor becomes deterministic with zero failure
probability on `T`. -/
theorem exists_perfect_seed [Fintype A] [DecidableEq A] [Nonempty A] [Fintype M] [DecidableEq M]
    [Nonempty M] [DecidableEq S] {h : A → S → M} (hu : TwoUniversal h) (T : Finset S)
    (hlt : T.offDiag.card < Fintype.card M) :
    ∃ a : A, ∀ x ∈ T, ∀ y ∈ T, h a x = h a y → x = y := by
  classical
  by_contra hcon
  push_neg at hcon
  have hall : ∀ a : A, CollidesOn h T a := by
    intro a
    by_contra hna
    obtain ⟨x, hx, y, hy, hxy, hne⟩ := hcon a
    exact hne (injOn_of_not_collidesOn hna x hx y hy hxy)
  have hcard : #{a | CollidesOn h T a} = Fintype.card A := by
    rw [Finset.filter_true_of_mem (fun a _ => hall a), Finset.card_univ]
  have hb := card_collides_mul_card_le hu T
  rw [hcard] at hb
  have hApos : 0 < Fintype.card A := Fintype.card_pos
  have : Fintype.card A * Fintype.card M < Fintype.card A * Fintype.card M := by
    calc Fintype.card A * Fintype.card M ≤ T.offDiag.card * Fintype.card A := hb
      _ < Fintype.card M * Fintype.card A := by
          exact Nat.mul_lt_mul_of_lt_of_le hlt (le_refl _) hApos
      _ = Fintype.card A * Fintype.card M := Nat.mul_comm _ _
  exact lt_irrefl _ this

/-! ## Expected number of false candidates (decoder work) -/

/-- The number of *other* typical words sharing the hash of `x`: exactly the
number of false candidates a bucketed decoder must sift through. -/
def collisionCount [DecidableEq S] [DecidableEq M] (h : A → S → M) (T : Finset S)
    (a : A) (x : S) : ℕ :=
  #{y ∈ T.erase x | h a y = h a x}

/-- Summed over all seeds, the number of false candidates is at most
`(|T|-1)·|A|/|M|`.  This is the decoder-work analogue of the collision bound. -/
theorem sum_collisionCount_mul_le [Fintype A] [DecidableEq A] [Fintype M] [DecidableEq M]
    [DecidableEq S] {h : A → S → M} (hu : TwoUniversal h) (T : Finset S) (x : S) :
    (∑ a : A, collisionCount h T a x) * Fintype.card M
      ≤ (T.erase x).card * Fintype.card A := by
  classical
  have key : ∑ a : A, collisionCount h T a x
      = ∑ y ∈ T.erase x, #{a | h a y = h a x} := by
    unfold collisionCount
    simp_rw [Finset.card_filter]
    rw [Finset.sum_comm]
  rw [key, Finset.sum_mul]
  calc ∑ y ∈ T.erase x, #{a | h a y = h a x} * Fintype.card M
      ≤ ∑ _y ∈ T.erase x, Fintype.card A := by
        refine Finset.sum_le_sum ?_
        intro y hy
        exact hu y x (Finset.ne_of_mem_erase hy)
    _ = (T.erase x).card * Fintype.card A := by rw [Finset.sum_const, smul_eq_mul]

/-- **Expected decoder work.**  Averaged over the random seed, the number of
false candidates competing with a typical word `x` is at most `(|T|-1)/|M|`.
A bucketed decoder therefore tests `1 + (|T|-1)/|M|` candidates on average,
instead of the `|T|` of a naive linear scan. -/
theorem avg_collisionCount_le [Fintype A] [DecidableEq A] [Nonempty A] [Fintype M]
    [DecidableEq M] [Nonempty M] [DecidableEq S] {h : A → S → M} (hu : TwoUniversal h)
    (T : Finset S) (x : S) :
    (∑ a : A, (collisionCount h T a x : ℚ)) / (Fintype.card A : ℚ)
      ≤ ((T.erase x).card : ℚ) / (Fintype.card M : ℚ) := by
  have hA : (0 : ℚ) < (Fintype.card A : ℚ) := by exact_mod_cast Fintype.card_pos (α := A)
  have hM : (0 : ℚ) < (Fintype.card M : ℚ) := by exact_mod_cast Fintype.card_pos (α := M)
  rw [div_le_div_iff₀ hA hM]
  have h1 := sum_collisionCount_mul_le hu T x
  have h2 : ((∑ a : A, collisionCount h T a x : ℕ) : ℚ) * (Fintype.card M : ℚ)
      ≤ ((T.erase x).card : ℚ) * (Fintype.card A : ℚ) := by
    exact_mod_cast h1
  calc (∑ a : A, (collisionCount h T a x : ℚ)) * (Fintype.card M : ℚ)
      = ((∑ a : A, collisionCount h T a x : ℕ) : ℚ) * (Fintype.card M : ℚ) := by push_cast; ring
    _ ≤ ((T.erase x).card : ℚ) * (Fintype.card A : ℚ) := h2

/-! ## Products of hash families -/

/-- Two independently seeded 2-universal families combine into a 2-universal
family with range the product: this is how a *bucket* hash and a *checksum*
hash are used together. -/
theorem twoUniversal_prod {A₁ A₂ M₁ M₂ : Type*} [Fintype A₁] [DecidableEq A₁]
    [Fintype A₂] [DecidableEq A₂] [Fintype M₁] [DecidableEq M₁] [Fintype M₂] [DecidableEq M₂]
    {h₁ : A₁ → S → M₁} {h₂ : A₂ → S → M₂} (hu₁ : TwoUniversal h₁) (hu₂ : TwoUniversal h₂) :
    TwoUniversal (fun (a : A₁ × A₂) (x : S) => (h₁ a.1 x, h₂ a.2 x)) := by
  classical
  intro x y hxy
  have hfil : #{a : A₁ × A₂ | (h₁ a.1 x, h₂ a.2 x) = (h₁ a.1 y, h₂ a.2 y)}
      = #{a₁ | h₁ a₁ x = h₁ a₁ y} * #{a₂ | h₂ a₂ x = h₂ a₂ y} := by
    rw [← Finset.card_product]
    apply Finset.card_nbij id
    · intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and,
        Prod.mk.injEq, Finset.coe_product, Set.mem_prod, id_eq] at ha ⊢
      exact ⟨ha.1, ha.2⟩
    · intro a _ b _ hab; exact hab
    · intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and,
        Prod.mk.injEq, Finset.coe_product, Set.mem_prod, id_eq] at ha ⊢
      exact ⟨a, ⟨ha.1, ha.2⟩, rfl⟩
  rw [hfil, Fintype.card_prod, Fintype.card_prod]
  calc #{a₁ | h₁ a₁ x = h₁ a₁ y} * #{a₂ | h₂ a₂ x = h₂ a₂ y} * (Fintype.card M₁ * Fintype.card M₂)
      = (#{a₁ | h₁ a₁ x = h₁ a₁ y} * Fintype.card M₁)
          * (#{a₂ | h₂ a₂ x = h₂ a₂ y} * Fintype.card M₂) := by ring
    _ ≤ Fintype.card A₁ * Fintype.card A₂ :=
        Nat.mul_le_mul (hu₁ x y hxy) (hu₂ x y hxy)

/-! ## A concrete 2-universal family: inner products over `ZMod p` -/

section Concrete

variable {p k : ℕ} [Fact p.Prime]

/-- The additive homomorphism `a ↦ ⟨a, z⟩` on `(ZMod p)^k`. -/
def dotHom (z : Fin k → ZMod p) : (Fin k → ZMod p) →+ ZMod p where
  toFun a := ∑ i, a i * z i
  map_zero' := by simp
  map_add' a b := by simp [add_mul, Finset.sum_add_distrib]

/-- The inner-product hash family: the seed is a vector `a ∈ (ZMod p)^k`, the
hash of a source word `x ∈ (ZMod p)^k` is the single field element `⟨a, x⟩`.
Evaluating it costs exactly `k` multiplications and `k-1` additions. -/
def dotHash (p k : ℕ) : (Fin k → ZMod p) → (Fin k → ZMod p) → ZMod p :=
  fun a x => ∑ i, a i * x i

/-- A nonzero linear functional on `(ZMod p)^k` is surjective. -/
theorem surjective_dotHom {z : Fin k → ZMod p} (hz : z ≠ 0) :
    Function.Surjective (dotHom z) := by
  obtain ⟨i₀, hi₀⟩ : ∃ i, z i ≠ 0 := by
    by_contra hc
    push_neg at hc
    exact hz (funext hc)
  intro c
  refine ⟨Pi.single i₀ (c * (z i₀)⁻¹), ?_⟩
  show ∑ i, (Pi.single i₀ (c * (z i₀)⁻¹) : Fin k → ZMod p) i * z i = c
  rw [Finset.sum_eq_single i₀]
  · rw [Pi.single_eq_same]
    field_simp
  · intro b _ hb
    simp [Pi.single_eq_of_ne hb]
  · intro hcon
    exact absurd (Finset.mem_univ i₀) hcon

/-- All fibres of a surjective additive homomorphism between finite abelian
groups have the same size; in particular the kernel has size `|A|/|M|`. -/
theorem card_ker_mul_card_eq {A M : Type*} [AddCommGroup A] [Fintype A] [DecidableEq A]
    [AddCommGroup M] [Fintype M] [DecidableEq M] (f : A →+ M) (hf : Function.Surjective f) :
    #{a | f a = 0} * Fintype.card M = Fintype.card A := by
  have h1 : Fintype.card A = ∑ c : M, #{a | f a = c} := by
    rw [← Finset.card_univ]
    exact Finset.card_eq_sum_card_fiberwise (fun a _ => Finset.mem_univ (f a))
  have h2 : ∀ c : M, #{a | f a = c} = #{a | f a = 0} :=
    fun c => AddMonoidHom.card_fiber_eq_of_mem_range f (hf c) ⟨0, by simp⟩
  rw [h1]
  simp [h2, Finset.sum_const, mul_comm]

/-- **The inner-product family is exactly pairwise independent**: for `x ≠ y`
precisely a `1/p` fraction of the seeds collide. -/
theorem pairwiseIndependent_dotHash : PairwiseIndependent (dotHash p k) := by
  classical
  intro x y hxy
  have hz : x - y ≠ 0 := sub_ne_zero_of_ne hxy
  have hsurj := surjective_dotHom hz
  have hset : #{a : Fin k → ZMod p | dotHash p k a x = dotHash p k a y}
      = #{a : Fin k → ZMod p | dotHom (x - y) a = 0} := by
    apply Finset.card_nbij id
    · intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at ha ⊢
      show dotHom (x - y) a = 0
      have : ∑ i, a i * (x i - y i) = 0 := by
        have hx : ∑ i, a i * x i = ∑ i, a i * y i := ha
        calc ∑ i, a i * (x i - y i) = (∑ i, a i * x i) - ∑ i, a i * y i := by
              rw [← Finset.sum_sub_distrib]; congr 1; ext i; ring
          _ = 0 := by rw [hx, sub_self]
      simpa [dotHom] using this
    · intro a _ b _ hab; exact hab
    · intro a ha
      simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at ha ⊢
      refine ⟨a, ?_, rfl⟩
      have : ∑ i, a i * (x i - y i) = 0 := by simpa [dotHom] using ha
      show dotHash p k a x = dotHash p k a y
      have : (∑ i, a i * x i) - ∑ i, a i * y i = 0 := by
        rw [← this, ← Finset.sum_sub_distrib]; congr 1; ext i; ring
      simpa [dotHash, sub_eq_zero] using this
  rw [hset]
  exact card_ker_mul_card_eq (dotHom (x - y)) hsurj

/-- In particular the inner-product family is 2-universal. -/
theorem twoUniversal_dotHash : TwoUniversal (dotHash p k) :=
  pairwiseIndependent_dotHash.twoUniversal

end Concrete

end AlmostLossless