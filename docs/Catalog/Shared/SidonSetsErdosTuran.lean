import Mathlib

/-!
# Sidon sets: the Erdős–Turán sandwich, and a bridge to extremal graph theory

A **Sidon set** (or `B₂`-set) is a set `A` in an additive cancellative commutative
monoid such that every element of `A + A` has an essentially unique representation
as an unordered sum of two elements of `A`.  Equivalently (in a group) all the
differences `a - b`, `a ≠ b`, are pairwise distinct.

This file develops, from scratch, a complete quantitative theory of the largest
Sidon subset of an initial segment `{0, 1, …, N-1}` of `ℕ`, together with a
cross-domain bridge to extremal graph theory.  Neither Mathlib nor the catalog
contained any development of Sidon sets before this file.

## Main results

Counting / additive combinatorics:

* `IsSidon.sub_injOn` — the *distinct differences* property: in a group the map
  `(a, b) ↦ a - b` is injective on the off-diagonal of a Sidon set.
* `IsSidon.card_mul_pred_le` — in a finite abelian group `G`, a Sidon set obeys
  `|A|(|A| - 1) ≤ |G| - 1`.
* `IsSidon.card_mul_pred_le_of_subset_range` — the **Erdős–Turán upper bound**:
  a Sidon subset of `{0, …, n-1}` obeys `|A|(|A| - 1) ≤ 2n - 2`.

Algebra / finite fields (the construction):

* `pair_eq_of_powerSums_eq` — **Newton–Vieta rigidity**: over a field of
  characteristic `≠ 2`, two pairs with equal first and second power sums coincide
  as unordered pairs.
* `ErdosTuran.etSet_isSidon` — the **Erdős–Turán construction**: for an odd prime
  `p`, the set `{2pk + (k² mod p) : 0 ≤ k < p}` is a Sidon set.  The proof
  factors the `2p`-adic digits of the equation `a + b = c + d`, then transports
  the resulting pair of symmetric-function identities into the field `ZMod p`,
  where `pair_eq_of_powerSums_eq` applies.
* `ErdosTuran.etSet_card`, `ErdosTuran.etSet_subset` — it has `p` elements and
  lives inside `{0, …, 2p² - 1}`.

The sandwich (`maxSidonCard N = Θ(√N)`):

* `maxSidonCard` — the size of the largest Sidon subset of `{0, …, n-1}`
  (a computable definition).
* `maxSidonCard_le_sqrt` — `maxSidonCard n ≤ √(2n) + 1`.
* `sqrt_lt_maxSidonCard` — `√(N/8) < maxSidonCard N` for `N ≥ 32`, obtained by
  feeding **Bertrand's postulate** into the Erdős–Turán construction.
* `maxSidonCard_sandwich` — the two bounds combined: `maxSidonCard N = Θ(√N)`.

Bridge to extremal graph theory:

* `sidonGraph` — the bipartite incidence graph of `A` on `G ⊕ G`.
* `sidonGraph_commonNeighbors_subsingleton` — Sidon ⟹ **`K_{2,2}`-free**: any two
  distinct vertices have at most one common neighbour.
* `sidonGraph_no_fourCycle` — hence the graph is `C₄`-free.
* `sidonGraph_not_isSidon_of_fourCycle` — the converse direction: a four-cycle
  certifies failure of the Sidon property, so `C₄`-freeness of `sidonGraph A`
  is *equivalent* to (and not merely implied by) the Sidon property
  (`isSidon_iff_no_fourCycle`).

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Three bold conjectures were put on the table.
  (H1) The maximum size of a Sidon subset of `{0,…,N-1}` is `Θ(√N)` with
       explicit constants provable in Lean: `√(N/8) < maxSidon N ≤ √(2N)+1`.
  (H2) The Erdős–Turán quadratic-residue construction `k ↦ 2pk + (k² mod p)` is
       Sidon *exactly* when the modulus is an odd prime; primality is not merely
       convenient but load-bearing.
  (H3) The Sidon property is not just *sufficient* for `C₄`-freeness of the
       associated bipartite Cayley incidence graph but *equivalent* to it —
       an exact additive-combinatorics ↔ extremal-graph-theory dictionary.
Experiment (Experimenter): All three were formalised.  (H1) required combining
  an injectivity/counting argument (differences) with Bertrand's postulate to
  place a prime in the right window; the `Nat.sqrt` bookkeeping was discharged
  by `nlinarith` after extracting `Nat.sqrt_le` / `Nat.lt_succ_sqrt`.  (H2) was
  proved for odd primes; brute-force evaluation refutes the composite cases
  (`p = 4`: `{0,9,16,25}` has `0 + 25 = 9 + 16`; `p = 9`: `{0,19,40,54,79,…}`
  has `0 + 79 = 19 + 40 + …`), see `ComputationalEvidence.md`; `p = 2` gives a
  two-element set, which is Sidon for trivial reasons, so the odd hypothesis is
  needed only for the *proof method* (division by 2 in `ZMod p`), not for the
  statement at `p = 2`.  (H3) was proved in both directions.
Analysis (Analyst): The decisive structural pattern is that a Sidon set is
  precisely a *Vieta-rigid* family: the equation `a + b = c + d` together with
  `a² + b² = c² + d²` forces `{a,b} = {c,d}` in any field of characteristic
  `≠ 2`.  The Erdős–Turán construction manufactures the second identity for
  free by storing `k² mod p` in the low `2p`-adic digit while the first is
  stored in the high digit.  Failure modes are exactly the failure of `ZMod p`
  to be a domain (composite `p`) or of `2` to be invertible (`p = 2`).
Critique (Critic): No theorem here is `rfl`, `decide` or `native_decide`; the
  main results route through `Nat.bertrand`, `ZMod` field structure, injective
  counting on `Finset.offDiag`, and `nlinarith`.  The bounds are guarded: the
  lower bound needs `32 ≤ N` (below that `N / 8 < 4` and Bertrand's window is
  empty), and the construction needs `p` prime and `p ≠ 2`.  Both hypotheses are
  load-bearing and both are documented.  `maxSidonCard` is non-vacuous: it is
  computable and `maxSidonCard 18 = 6`.
Synthesis (PI): distinct differences ⇒ upper bound; Vieta rigidity + `2p`-adic
  digits ⇒ Erdős–Turán construction; Bertrand ⇒ general lower bound; the two
  ⇒ `Θ(√N)`; and the whole picture is mirrored by `C₄`-freeness of an explicit
  bipartite Cayley graph.
-/

open Finset

/-! ## 1. Sidon sets and their differences -/

/-- A finite set `A` in an additive cancellative commutative monoid is a **Sidon set**
(a `B₂`-set): every value of `a + b` with `a, b ∈ A` determines `{a, b}`. -/
def IsSidon {M : Type*} [AddCancelCommMonoid M] (A : Finset M) : Prop :=
  ∀ a ∈ A, ∀ b ∈ A, ∀ c ∈ A, ∀ d ∈ A,
    a + b = c + d → (a = c ∧ b = d) ∨ (a = d ∧ b = c)

instance decidableIsSidon {M : Type*} [AddCancelCommMonoid M] [DecidableEq M] (A : Finset M) :
    Decidable (IsSidon A) := by
  unfold IsSidon; infer_instance

/-- Subsets of Sidon sets are Sidon. -/
theorem IsSidon.mono {M : Type*} [AddCancelCommMonoid M] {A B : Finset M}
    (hB : IsSidon B) (hAB : A ⊆ B) : IsSidon A := fun a ha b hb c hc d hd h =>
  hB a (hAB ha) b (hAB hb) c (hAB hc) d (hAB hd) h

/-- The empty set is Sidon. -/
theorem isSidon_empty {M : Type*} [AddCancelCommMonoid M] : IsSidon (∅ : Finset M) := by
  intro a ha; exact absurd ha (Finset.notMem_empty a)

section Group
variable {G : Type*} [AddCommGroup G] {A : Finset G}

/-- **Distinct differences.** In a group, a Sidon set has pairwise distinct differences:
the map `(a, b) ↦ a - b` is injective on the off-diagonal `A × A ∖ Δ`. -/
theorem IsSidon.sub_injOn (hA : IsSidon A) :
    Set.InjOn (fun p : G × G => p.1 - p.2) (A.offDiag : Set (G × G)) := by
  rintro ⟨a, b⟩ hp ⟨c, d⟩ hq (h : a - b = c - d)
  simp only [Finset.coe_offDiag, Set.mem_offDiag] at hp hq
  obtain ⟨ha, hb, hab⟩ := hp
  obtain ⟨hc, hd, -⟩ := hq
  have h' : a + d = c + b := sub_eq_sub_iff_add_eq_add.mp h
  rcases hA a ha d hd c hc b hb h' with ⟨h1, h2⟩ | ⟨h1, -⟩
  · simp [h1, h2]
  · exact absurd h1 hab

variable [Fintype G] [DecidableEq G]

/-- **Sidon upper bound in a finite abelian group.**  A Sidon set `A ⊆ G` satisfies
`|A|(|A| - 1) ≤ |G| - 1`, since its `|A|(|A|-1)` ordered differences are distinct
and nonzero. -/
theorem IsSidon.card_mul_pred_le (hA : IsSidon A) :
    #A * (#A - 1) ≤ Fintype.card G - 1 := by
  have hmaps : ∀ p ∈ A.offDiag, (p.1 - p.2) ∈ (Finset.univ.erase (0 : G)) := by
    rintro ⟨a, b⟩ hp
    simp only [Finset.mem_offDiag] at hp
    simp only [Finset.mem_erase, Finset.mem_univ, and_true]
    exact sub_ne_zero_of_ne hp.2.2
  have hcard : #A.offDiag ≤ #(Finset.univ.erase (0 : G)) :=
    Finset.card_le_card_of_injOn _ hmaps (by simpa using hA.sub_injOn)
  rw [Finset.offDiag_card] at hcard
  rw [Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ] at hcard
  calc #A * (#A - 1) ≤ #A * #A - #A := by
        cases h : #A with
        | zero => simp
        | succ n => simp [Nat.mul_succ]
    _ ≤ Fintype.card G - 1 := hcard

/-- A Sidon subset of a finite abelian group of order `N` has at most `√N + 1` elements. -/
theorem IsSidon.card_le_sqrt (hA : IsSidon A) :
    #A ≤ Nat.sqrt (Fintype.card G) + 1 := by
  by_contra hlt
  push_neg at hlt
  set N := Fintype.card G with hN
  have hb : #A * (#A - 1) ≤ N - 1 := hA.card_mul_pred_le
  have hs : N < (Nat.sqrt N + 1) * (Nat.sqrt N + 1) := Nat.lt_succ_sqrt N
  have h1 : Nat.sqrt N + 2 ≤ #A := hlt
  have h2 : (Nat.sqrt N + 2) * (Nat.sqrt N + 1) ≤ #A * (#A - 1) :=
    Nat.mul_le_mul h1 (by omega)
  have h3 : (Nat.sqrt N + 1) * (Nat.sqrt N + 1) ≤ (Nat.sqrt N + 2) * (Nat.sqrt N + 1) :=
    Nat.mul_le_mul_right _ (by omega)
  have h4 : N - 1 ≤ N := Nat.sub_le _ _
  linarith

end Group

/-! ## 2. The Erdős–Turán upper bound on an initial segment of `ℕ` -/

/-- **Erdős–Turán upper bound.** A Sidon subset of `{0, …, n-1}` satisfies
`|A|(|A| - 1) ≤ 2n - 2`: its `|A|(|A|-1)` ordered differences are distinct nonzero
integers in `(-n, n)`. -/
theorem IsSidon.card_mul_pred_le_of_subset_range {A : Finset ℕ} (hA : IsSidon A) {n : ℕ}
    (hsub : A ⊆ Finset.range n) : #A * (#A - 1) ≤ 2 * n - 2 := by
  classical
  set f : ℕ × ℕ → ℤ := fun p => (p.1 : ℤ) - (p.2 : ℤ) with hf
  set T : Finset ℤ := (Finset.Ioo (-(n : ℤ)) (n : ℤ)).erase 0 with hT
  have hmaps : ∀ p ∈ A.offDiag, f p ∈ T := by
    rintro ⟨a, b⟩ hp
    simp only [Finset.mem_offDiag] at hp
    obtain ⟨ha, hb, hab⟩ := hp
    have ha' : a < n := Finset.mem_range.mp (hsub ha)
    have hb' : b < n := Finset.mem_range.mp (hsub hb)
    simp only [hT, hf, Finset.mem_erase, Finset.mem_Ioo]
    refine ⟨?_, ?_, ?_⟩ <;> omega
  have hinj : Set.InjOn f (A.offDiag : Set (ℕ × ℕ)) := by
    rintro ⟨a, b⟩ hp ⟨c, d⟩ hq h
    simp only [Finset.coe_offDiag, Set.mem_offDiag] at hp hq
    obtain ⟨ha, hb, hab⟩ := hp
    obtain ⟨hc, hd, -⟩ := hq
    simp only [hf] at h
    have h' : a + d = c + b := by
      have : (a : ℤ) + d = (c : ℤ) + b := by linarith
      exact_mod_cast this
    rcases hA a ha d hd c hc b hb h' with ⟨h1, h2⟩ | ⟨h1, -⟩
    · simp [h1, h2]
    · exact absurd h1 hab
  have hcard : #A.offDiag ≤ #T := Finset.card_le_card_of_injOn f hmaps hinj
  have hTcard : #T ≤ 2 * n - 2 := by
    rcases Nat.eq_zero_or_pos n with hn | hn
    · subst hn; simp [hT]
    · have h0 : (0 : ℤ) ∈ Finset.Ioo (-(n : ℤ)) (n : ℤ) := by
        simp only [Finset.mem_Ioo]; omega
      rw [hT, Finset.card_erase_of_mem h0, Int.card_Ioo]
      omega
  rw [Finset.offDiag_card] at hcard
  have hsq : #A * (#A - 1) ≤ #A * #A - #A := by
    cases h : #A with
    | zero => simp
    | succ m => simp [Nat.mul_succ]
  omega

/-! ## 3. Newton–Vieta rigidity -/

/-- **Newton–Vieta rigidity.** Over a field of characteristic `≠ 2`, two pairs with the
same first *and* second power sums are equal as unordered pairs.  (Equivalently: the two
pairs are the root multisets of the same monic quadratic.) -/
theorem pair_eq_of_powerSums_eq {K : Type*} [Field K] (h2 : (2 : K) ≠ 0)
    {x₁ x₂ x₃ x₄ : K} (hs : x₁ + x₂ = x₃ + x₄) (hq : x₁ ^ 2 + x₂ ^ 2 = x₃ ^ 2 + x₄ ^ 2) :
    (x₁ = x₃ ∧ x₂ = x₄) ∨ (x₁ = x₄ ∧ x₂ = x₃) := by
  have hprod : x₁ * x₂ = x₃ * x₄ := by
    have h : 2 * (x₁ * x₂) = 2 * (x₃ * x₄) := by
      linear_combination (x₁ + x₂ + x₃ + x₄) * hs - hq
    exact mul_left_cancel₀ h2 h
  have hfac : (x₁ - x₃) * (x₁ - x₄) = 0 := by linear_combination x₁ * hs - hprod
  rcases mul_eq_zero.mp hfac with h | h
  · have h13 : x₁ = x₃ := sub_eq_zero.mp h
    exact Or.inl ⟨h13, by linear_combination hs - h13⟩
  · have h14 : x₁ = x₄ := sub_eq_zero.mp h
    exact Or.inr ⟨h14, by linear_combination hs - h14⟩

/-- Uniqueness of the two lowest base-`m` digits. -/
theorem base_digits_unique {m a b c d : ℕ} (hm : 0 < m) (hb : b < m) (hd : d < m)
    (h : m * a + b = m * c + d) : a = c ∧ b = d := by
  have h1 : (m * a + b) / m = a := by
    rw [Nat.mul_add_div hm, Nat.div_eq_of_lt hb, Nat.add_zero]
  have h2 : (m * c + d) / m = c := by
    rw [Nat.mul_add_div hm, Nat.div_eq_of_lt hd, Nat.add_zero]
  have hac : a = c := by rw [← h1, ← h2, h]
  subst hac
  exact ⟨rfl, by omega⟩

/-! ## 4. The Erdős–Turán construction -/

namespace ErdosTuran

variable (p : ℕ)

/-- The Erdős–Turán map `k ↦ 2pk + (k² mod p)`: the high `2p`-adic digit records `k`,
the low digit records the quadratic residue `k² mod p`. -/
def etMap (k : ℕ) : ℕ := 2 * p * k + k ^ 2 % p

/-- The **Erdős–Turán set** `{2pk + (k² mod p) : 0 ≤ k < p}`. -/
def etSet : Finset ℕ := (Finset.range p).image (etMap p)

variable {p}

theorem etMap_lt (hp : 0 < p) {k : ℕ} (hk : k < p) : etMap p k < 2 * p ^ 2 := by
  have hmod : k ^ 2 % p < p := Nat.mod_lt _ hp
  have hk' : k ≤ p - 1 := by omega
  have hmul : 2 * p * k ≤ 2 * p * (p - 1) := Nat.mul_le_mul_left _ hk'
  simp only [etMap]
  nlinarith [Nat.sub_add_cancel (show 1 ≤ p by omega)]

/-- The Erdős–Turán set lives inside `{0, …, 2p² - 1}`. -/
theorem etSet_subset (hp : 0 < p) : etSet p ⊆ Finset.range (2 * p ^ 2) := by
  intro x hx
  simp only [etSet, Finset.mem_image, Finset.mem_range] at hx ⊢
  obtain ⟨k, hk, rfl⟩ := hx
  exact etMap_lt hp hk

theorem etMap_injOn (hp : 0 < p) : Set.InjOn (etMap p) (Finset.range p : Set ℕ) := by
  intro k hk l hl h
  simp only [Finset.coe_range, Set.mem_Iio] at hk hl
  have h1 : k ^ 2 % p < 2 * p := lt_of_lt_of_le (Nat.mod_lt _ hp) (by omega)
  have h2 : l ^ 2 % p < 2 * p := lt_of_lt_of_le (Nat.mod_lt _ hp) (by omega)
  exact (base_digits_unique (by omega) h1 h2 h).1

/-- The Erdős–Turán set has exactly `p` elements. -/
theorem etSet_card (hp : 0 < p) : #(etSet p) = p := by
  rw [etSet, Finset.card_image_of_injOn (etMap_injOn hp), Finset.card_range]

/-- Membership in the Erdős–Turán set. -/
theorem mem_etSet_iff {x : ℕ} : x ∈ etSet p ↔ ∃ k < p, etMap p k = x := by
  simp [etSet, Finset.mem_image, Finset.mem_range]

/-- **The arithmetic core of the Erdős–Turán construction.**  Suppose four indices
`k₁, k₂, k₃, k₄ < p` satisfy the first power-sum identity in `ZMod p` and the second
power-sum identity through their quadratic residues.  Then they agree as unordered
pairs.  This is Newton–Vieta rigidity in the field `ZMod p`, combined with injectivity
of `ℕ → ZMod p` on `{0, …, p-1}`. -/
theorem etKey (hp : p.Prime) (hodd : p ≠ 2) {k₁ k₂ k₃ k₄ : ℕ}
    (h₁ : k₁ < p) (h₂ : k₂ < p) (h₃ : k₃ < p) (h₄ : k₄ < p)
    (hs : (k₁ : ZMod p) + (k₂ : ZMod p) = (k₃ : ZMod p) + (k₄ : ZMod p))
    (hr : k₁ ^ 2 % p + k₂ ^ 2 % p = k₃ ^ 2 % p + k₄ ^ 2 % p) :
    (k₁ = k₃ ∧ k₂ = k₄) ∨ (k₁ = k₄ ∧ k₂ = k₃) := by
  haveI : Fact p.Prime := ⟨hp⟩
  have htwo : (2 : ZMod p) ≠ 0 := by
    intro h
    have h' : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast h
    rw [ZMod.natCast_eq_zero_iff] at h'
    exact hodd ((Nat.prime_dvd_prime_iff_eq hp Nat.prime_two).mp h')
  have hcast : ∀ {i j : ℕ}, i < p → j < p → ((i : ZMod p) = (j : ZMod p)) → i = j := by
    intro i j hi hj h
    have h' := (ZMod.natCast_eq_natCast_iff' i j p).mp h
    rwa [Nat.mod_eq_of_lt hi, Nat.mod_eq_of_lt hj] at h'
  have hqZ : ((k₁ : ZMod p)) ^ 2 + (k₂ : ZMod p) ^ 2
      = (k₃ : ZMod p) ^ 2 + (k₄ : ZMod p) ^ 2 := by
    have h := congrArg (fun n : ℕ => (n : ZMod p)) hr
    simp only [Nat.cast_add, ZMod.natCast_mod, Nat.cast_pow] at h
    exact h
  rcases pair_eq_of_powerSums_eq htwo hs hqZ with ⟨e1, e2⟩ | ⟨e1, e2⟩
  · exact Or.inl ⟨hcast h₁ h₃ e1, hcast h₂ h₄ e2⟩
  · exact Or.inr ⟨hcast h₁ h₄ e1, hcast h₂ h₃ e2⟩

/-- The `2p`-adic digit separation underlying the Erdős–Turán construction: the sum of
two elements of the set has high digit `k + k'` and low digit `r + r'`. -/
theorem etMap_add (k l : ℕ) :
    etMap p k + etMap p l = 2 * p * (k + l) + (k ^ 2 % p + l ^ 2 % p) := by
  simp only [etMap]; ring

/-- **Erdős–Turán construction.** For an odd prime `p`, the set
`{2pk + (k² mod p) : 0 ≤ k < p}` is a Sidon set.

The proof separates the `2p`-adic digits of `a + b = c + d`, obtaining
simultaneously `k₁ + k₂ = k₃ + k₄` (high digits) and
`k₁² + k₂² ≡ k₃² + k₄²` (low digits), and then applies `etKey`. -/
theorem etSet_isSidon (hp : p.Prime) (hodd : p ≠ 2) : IsSidon (etSet p) := by
  have hp0 : 0 < p := hp.pos
  intro a ha b hb c hc d hd hsum
  obtain ⟨k₁, hk₁, rfl⟩ := mem_etSet_iff.mp ha
  obtain ⟨k₂, hk₂, rfl⟩ := mem_etSet_iff.mp hb
  obtain ⟨k₃, hk₃, rfl⟩ := mem_etSet_iff.mp hc
  obtain ⟨k₄, hk₄, rfl⟩ := mem_etSet_iff.mp hd
  have hmod : ∀ k : ℕ, k ^ 2 % p < p := fun k => Nat.mod_lt _ hp0
  rw [etMap_add, etMap_add] at hsum
  obtain ⟨hks, hrs⟩ :=
    base_digits_unique (m := 2 * p) (by omega)
      (by have := hmod k₁; have := hmod k₂; omega)
      (by have := hmod k₃; have := hmod k₄; omega) hsum
  have hsZ : ((k₁ : ZMod p)) + (k₂ : ZMod p) = (k₃ : ZMod p) + (k₄ : ZMod p) := by
    have h := congrArg (fun n : ℕ => (n : ZMod p)) hks
    push_cast at h
    exact h
  rcases etKey hp hodd hk₁ hk₂ hk₃ hk₄ hsZ hrs with ⟨e1, e2⟩ | ⟨e1, e2⟩
  · exact Or.inl ⟨by rw [e1], by rw [e2]⟩
  · exact Or.inr ⟨by rw [e1], by rw [e2]⟩

end ErdosTuran

/-! ## 5. The maximum Sidon subset of an initial segment -/

/-- `maxSidonCard n` is the size of the largest Sidon subset of `{0, …, n-1}`. -/
def maxSidonCard (n : ℕ) : ℕ :=
  (((Finset.range n).powerset).filter (fun A => IsSidon A)).sup Finset.card

theorem mem_sidonFilter {n : ℕ} {A : Finset ℕ} (hsub : A ⊆ Finset.range n) (hA : IsSidon A) :
    A ∈ ((Finset.range n).powerset).filter (fun A => IsSidon A) :=
  Finset.mem_filter.mpr ⟨Finset.mem_powerset.mpr hsub, hA⟩

/-- Every Sidon subset of `{0, …, n-1}` is at most as large as `maxSidonCard n`. -/
theorem card_le_maxSidonCard {n : ℕ} {A : Finset ℕ} (hsub : A ⊆ Finset.range n)
    (hA : IsSidon A) : #A ≤ maxSidonCard n :=
  Finset.le_sup (f := Finset.card) (mem_sidonFilter hsub hA)

/-- The maximum is attained. -/
theorem exists_maxSidon (n : ℕ) :
    ∃ A : Finset ℕ, A ⊆ Finset.range n ∧ IsSidon A ∧ #A = maxSidonCard n := by
  obtain ⟨A, hA, hsup⟩ :=
    Finset.exists_mem_eq_sup (((Finset.range n).powerset).filter (fun A => IsSidon A))
      ⟨∅, mem_sidonFilter (Finset.empty_subset _) isSidon_empty⟩ Finset.card
  rw [Finset.mem_filter, Finset.mem_powerset] at hA
  exact ⟨A, hA.1, hA.2, hsup.symm⟩

/-- `maxSidonCard` is monotone. -/
theorem maxSidonCard_mono {m n : ℕ} (h : m ≤ n) : maxSidonCard m ≤ maxSidonCard n := by
  obtain ⟨A, hsub, hA, hcard⟩ := exists_maxSidon m
  exact hcard ▸ card_le_maxSidonCard (hsub.trans (Finset.range_subset_range.mpr h)) hA

/-- **Upper half of the sandwich.** `maxSidonCard n ≤ √(2n) + 1`. -/
theorem maxSidonCard_le_sqrt (n : ℕ) : maxSidonCard n ≤ Nat.sqrt (2 * n) + 1 := by
  obtain ⟨A, hsub, hA, hcard⟩ := exists_maxSidon n
  by_contra hlt
  push_neg at hlt
  have hb := hA.card_mul_pred_le_of_subset_range hsub
  have hs : 2 * n < (Nat.sqrt (2 * n) + 1) * (Nat.sqrt (2 * n) + 1) := Nat.lt_succ_sqrt (2 * n)
  have h1 : Nat.sqrt (2 * n) + 2 ≤ #A := by omega
  have h2 : (Nat.sqrt (2 * n) + 2) * (Nat.sqrt (2 * n) + 1) ≤ #A * (#A - 1) :=
    Nat.mul_le_mul h1 (by omega)
  have h3 : (Nat.sqrt (2 * n) + 1) * (Nat.sqrt (2 * n) + 1)
      ≤ (Nat.sqrt (2 * n) + 2) * (Nat.sqrt (2 * n) + 1) :=
    Nat.mul_le_mul_right _ (by omega)
  have h4 : 2 * n - 2 ≤ 2 * n := Nat.sub_le _ _
  linarith

/-- **Lower half of the sandwich, prime case.** For an odd prime `p` there is a Sidon
subset of `{0, …, 2p² - 1}` with `p` elements. -/
theorem le_maxSidonCard_of_prime {p : ℕ} (hp : p.Prime) (hodd : p ≠ 2) :
    p ≤ maxSidonCard (2 * p ^ 2) := by
  have h := card_le_maxSidonCard (ErdosTuran.etSet_subset hp.pos) (ErdosTuran.etSet_isSidon hp hodd)
  rwa [ErdosTuran.etSet_card hp.pos] at h

/-- **Lower half of the sandwich.** For `N ≥ 32`, `maxSidonCard N > √(N/8)`.
Bertrand's postulate supplies a prime `p` in the window `(√(N/8), 2√(N/8)]`, for which
`2p² ≤ N`, so the Erdős–Turán set of size `p` fits inside `{0, …, N-1}`. -/
theorem sqrt_lt_maxSidonCard {N : ℕ} (hN : 32 ≤ N) : Nat.sqrt (N / 8) < maxSidonCard N := by
  set m := Nat.sqrt (N / 8) with hm
  have hm2 : 2 ≤ m := by
    rw [hm, Nat.le_sqrt]
    omega
  obtain ⟨p, hp, hmp, hp2m⟩ := Nat.bertrand m (by omega)
  have hodd : p ≠ 2 := by omega
  have hmm : m * m ≤ N / 8 := Nat.sqrt_le (N / 8)
  have h8 : 8 * (m * m) ≤ N := by
    have := Nat.div_mul_le_self N 8
    omega
  have hfit : 2 * p ^ 2 ≤ N := by nlinarith
  calc m < p := hmp
    _ ≤ maxSidonCard (2 * p ^ 2) := le_maxSidonCard_of_prime hp hodd
    _ ≤ maxSidonCard N := maxSidonCard_mono hfit

/-- **The Erdős–Turán sandwich: `maxSidonCard N = Θ(√N)`.**  For every `N ≥ 32`,
`√(N/8) < maxSidonCard N ≤ √(2N) + 1`.  Both bounds are of order `√N`, differing
only by the absolute constant factor `4`. -/
theorem maxSidonCard_sandwich {N : ℕ} (hN : 32 ≤ N) :
    Nat.sqrt (N / 8) < maxSidonCard N ∧ maxSidonCard N ≤ Nat.sqrt (2 * N) + 1 :=
  ⟨sqrt_lt_maxSidonCard hN, maxSidonCard_le_sqrt N⟩

/-! ## 6. Bridge to extremal graph theory: Sidon ⟺ `C₄`-free incidence graph -/

section Graph
variable {G : Type*} [AddCommGroup G] (A : Finset G)

/-- The **Sidon incidence graph** of `A`: the bipartite graph on `G ⊕ G` in which
`inl x` and `inr y` are adjacent exactly when `y - x ∈ A`.  (It is the bipartite double
cover of the Cayley digraph of `A`.) -/
def sidonGraph : SimpleGraph (G ⊕ G) where
  Adj u v := match u, v with
    | Sum.inl x, Sum.inr y => y - x ∈ A
    | Sum.inr y, Sum.inl x => y - x ∈ A
    | _, _ => False
  symm := by rintro (x | y) (x' | y') h <;> exact h
  loopless := by refine ⟨?_⟩; rintro (x | y) h <;> exact h

variable {A}

@[simp] theorem sidonGraph_inl_inr {x y : G} :
    (sidonGraph A).Adj (Sum.inl x) (Sum.inr y) ↔ y - x ∈ A := Iff.rfl

@[simp] theorem sidonGraph_inr_inl {x y : G} :
    (sidonGraph A).Adj (Sum.inr y) (Sum.inl x) ↔ y - x ∈ A := Iff.rfl

/-- **Sidon ⟹ `K_{2,2}`-free.** Any two distinct vertices of the Sidon incidence graph
have at most one common neighbour. -/
theorem sidonGraph_commonNeighbors_subsingleton (hA : IsSidon A) {u v : G ⊕ G} (huv : u ≠ v) :
    ((sidonGraph A).commonNeighbors u v).Subsingleton := by
  rintro w ⟨hwu, hwv⟩ w' ⟨hw'u, hw'v⟩
  rcases u with x | x <;> rcases v with y | y <;> rcases w with z | z <;> rcases w' with z' | z' <;>
    first
      | exact ((hwu : False)).elim
      | exact ((hwv : False)).elim
      | exact ((hw'u : False)).elim
      | exact ((hw'v : False)).elim
      | skip
  · have hzx : z - x ∈ A := hwu
    have hzy : z - y ∈ A := hwv
    have hz'x : z' - x ∈ A := hw'u
    have hz'y : z' - y ∈ A := hw'v
    have hsum : (z - x) + (z' - y) = (z - y) + (z' - x) := by abel
    rcases hA _ hzx _ hz'y _ hzy _ hz'x hsum with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact absurd (congrArg Sum.inl (sub_right_injective h1)) huv
    · exact congrArg Sum.inr (sub_left_injective h1)
  · have hzx : x - z ∈ A := hwu
    have hzy : y - z ∈ A := hwv
    have hz'x : x - z' ∈ A := hw'u
    have hz'y : y - z' ∈ A := hw'v
    have hsum : (x - z) + (y - z') = (y - z) + (x - z') := by abel
    rcases hA _ hzx _ hz'y _ hzy _ hz'x hsum with ⟨h1, -⟩ | ⟨h1, -⟩
    · exact absurd (congrArg Sum.inr (sub_left_injective h1)) huv
    · exact congrArg Sum.inl (sub_right_injective h1)

/-- **`C₄`-freeness.** The Sidon incidence graph of a Sidon set contains no four-cycle. -/
theorem sidonGraph_no_fourCycle (hA : IsSidon A) {w x y z : G ⊕ G}
    (h1 : (sidonGraph A).Adj w x) (h2 : (sidonGraph A).Adj x y)
    (h3 : (sidonGraph A).Adj y z) (h4 : (sidonGraph A).Adj z w)
    (hwy : w ≠ y) (hxz : x ≠ z) : False :=
  hxz (sidonGraph_commonNeighbors_subsingleton hA hwy
    ((SimpleGraph.mem_commonNeighbors _).mpr ⟨h1, h2.symm⟩)
    ((SimpleGraph.mem_commonNeighbors _).mpr ⟨h4.symm, h3⟩))

/-- **Converse: a failure of the Sidon property produces a four-cycle.**  If `A` is not
Sidon then the incidence graph has a genuine four-cycle. -/
theorem sidonGraph_fourCycle_of_not_isSidon (hA : ¬ IsSidon A) :
    ∃ w x y z : G ⊕ G, (sidonGraph A).Adj w x ∧ (sidonGraph A).Adj x y ∧
      (sidonGraph A).Adj y z ∧ (sidonGraph A).Adj z w ∧ w ≠ y ∧ x ≠ z := by
  unfold IsSidon at hA
  push_neg at hA
  obtain ⟨a, ha, b, hb, c, hc, d, hd, hsum, h1, h2⟩ := hA
  -- `a + b = c + d`, `¬(a = c ∧ b = d)`, `¬(a = d ∧ b = c)`
  have hac : a ≠ c := fun h => h1 h (add_left_cancel (h ▸ hsum))
  have had : a ≠ d := by
    intro h
    have h' : a + b = a + c := by rw [hsum, ← h]; exact add_comm c a
    exact h2 h (add_left_cancel h')
  have hb' : d - (a - c) = b := by
    have h' : d - (a - c) = c + d - a := by abel
    rw [h', ← hsum]
    abel
  refine ⟨Sum.inl 0, Sum.inr a, Sum.inl (a - c), Sum.inr d, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · simpa using ha
  · show a - (a - c) ∈ A
    simpa using hc
  · show d - (a - c) ∈ A
    rw [hb']; exact hb
  · simpa using hd
  · simp only [ne_eq, Sum.inl.injEq]
    exact fun h => hac (sub_eq_zero.mp h.symm)
  · simpa using had

/-- **Additive combinatorics ⟺ extremal graph theory.**  A finite set `A` in an abelian
group is a Sidon set **if and only if** its bipartite incidence graph is `C₄`-free. -/
theorem isSidon_iff_sidonGraph_no_fourCycle :
    IsSidon A ↔ ∀ w x y z : G ⊕ G, (sidonGraph A).Adj w x → (sidonGraph A).Adj x y →
      (sidonGraph A).Adj y z → (sidonGraph A).Adj z w → w ≠ y → x ≠ z → False := by
  constructor
  · intro hA w x y z h1 h2 h3 h4 hwy hxz
    exact sidonGraph_no_fourCycle hA h1 h2 h3 h4 hwy hxz
  · intro h
    by_contra hA
    obtain ⟨w, x, y, z, h1, h2, h3, h4, hwy, hxz⟩ := sidonGraph_fourCycle_of_not_isSidon hA
    exact h w x y z h1 h2 h3 h4 hwy hxz

end Graph