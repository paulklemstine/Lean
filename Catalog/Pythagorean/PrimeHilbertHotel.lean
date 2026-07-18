import Mathlib
import Pythagorean.FactorialLehmerClassification

/-!
# Hilbert's hotel for prime-indexed sequences

The pointwise topology on the infinite symmetric group only observes finitely many
rooms at a time.  This chapter isolates the exact topological mechanism behind
robust prime rearrangements: every prescribed finite prefix of a permutation can
be completed by a permutation which is eventually the identity.  Consequently,
for every nowhere-zero sequence—including the sequence of primes—the quotient
between the rearranged and original sequences is eventually one.

No asymptotic theorem about primes is needed for this dense core.  The argument is
instead a bridge between finite permutation extension, the pointwise topology,
and convergence of sequences.
-/

namespace PrimeHilbertHotel

open Filter
open scoped Topology

/-- A permutation is asymptotically invisible to a sequence when its termwise
quotient converges to one. -/
def WellBehaved (a : ℕ → ℝ) (σ : Equiv.Perm ℕ) : Prop :=
  Tendsto (fun n => a (σ n) / a n) atTop (𝓝 1)

/-- Algebraic formulation of density for the pointwise topology: every finite
prefix cylinder around every permutation contains a member of `G`. -/
def PrefixDense (G : Set (Equiv.Perm ℕ)) : Prop :=
  ∀ (σ : Equiv.Perm ℕ) (k : ℕ), ∃ τ ∈ G, ∀ n < k, τ n = σ n

/-- An eventually fixed permutation is invisible to every sequence whose terms
are eventually nonzero. -/
theorem wellBehaved_of_eventually_fixed
    (a : ℕ → ℝ) (τ : Equiv.Perm ℕ)
    (ha : ∀ᶠ n in atTop, a n ≠ 0)
    (hτ : ∀ᶠ n in atTop, τ n = n) :
    WellBehaved a τ := by
  exact tendsto_const_nhds.congr' ( by filter_upwards [ ha, hτ ] with n hn hn'; aesop )

/-- Every finite observation of an arbitrary permutation of the rooms extends to
an eventually fixed permutation. -/
theorem exists_eventually_fixed_extension (σ : Equiv.Perm ℕ) (k : ℕ) :
    ∃ τ : Equiv.Perm ℕ,
      (∀ n < k, τ n = σ n) ∧
      (∀ᶠ n in atTop, τ n = n) := by
  -- Let $N$ be a number such that $N > k$ and $N > \max_{n < k} \sigma(n)$.
  obtain ⟨N, hN⟩ : ∃ N, k < N ∧ ∀ n < k, σ n < N := by
    exact ⟨ k + ∑ n ∈ Finset.range k, σ n + 1, by linarith [ Nat.zero_le ( ∑ n ∈ Finset.range k, σ n ) ], fun n hn => by linarith [ Finset.single_le_sum ( fun a _ => Nat.zero_le ( σ a ) ) ( Finset.mem_range.mpr hn ) ] ⟩;
  -- Define a permutation $\tau$ of $\{0, 1, \ldots, N-1\}$ that agrees with $\sigma$ on $\{0, 1, \ldots, k-1\}$.
  obtain ⟨τ, hτ⟩ : ∃ τ : Fin N ≃ Fin N, ∀ i : Fin k, τ (Fin.castLE (by linarith) i) = Fin.castLE (by linarith [hN.right i (Fin.is_lt i)]) (⟨σ i, hN.right i (Fin.is_lt i)⟩) := by
    have h_exists_equiv : ∃ τ : Fin k → Fin N, Function.Injective τ ∧ ∀ i : Fin k, τ i = Fin.castLE (by linarith [hN.right i (Fin.is_lt i)]) (⟨σ i, hN.right i (Fin.is_lt i)⟩) := by
      refine' ⟨ _, _, fun i => rfl ⟩;
      intro i j; aesop;
    obtain ⟨τ, hτ_inj, hτ_eq⟩ := h_exists_equiv
    have h_exists_equiv : ∃ τ' : Fin (N - k) → Fin N, Function.Injective τ' ∧ ∀ i : Fin (N - k), τ' i ∉ Set.range τ := by
      have h_exists_equiv : ∃ τ' : Fin (N - k) → Fin N, Function.Injective τ' ∧ ∀ i : Fin (N - k), τ' i ∉ Set.range τ := by
        have h_card : Finset.card (Finset.univ \ Finset.image τ Finset.univ) = N - k := by
          simp +decide [ Finset.card_sdiff, Finset.card_image_of_injective _ hτ_inj ]
        exact ⟨ fun i => Finset.orderEmbOfFin _ ( by aesop ) i, by aesop_cat, fun i => Finset.mem_sdiff.mp ( Finset.orderEmbOfFin_mem _ ( by aesop ) i ) |>.2 |> fun h => by aesop ⟩;
      exact h_exists_equiv;
    obtain ⟨τ', hτ'_inj, hτ'_range⟩ := h_exists_equiv
    have h_exists_equiv : ∃ τ'' : Fin N ≃ Fin N, ∀ i : Fin k, τ'' (Fin.castLE (by linarith) i) = τ i ∧ ∀ i : Fin (N - k), τ'' (Fin.castLE (by omega) (Fin.natAdd k i)) = τ' i := by
      have h_exists_equiv : ∃ τ'' : Fin N → Fin N, Function.Injective τ'' ∧ ∀ i : Fin k, τ'' (Fin.castLE (by linarith) i) = τ i ∧ ∀ i : Fin (N - k), τ'' (Fin.castLE (by omega) (Fin.natAdd k i)) = τ' i := by
        use fun i => if hi : i.val < k then τ ⟨i.val, hi⟩ else τ' ⟨i.val - k, by
          exact tsub_lt_tsub_iff_right ( le_of_not_gt hi ) |>.2 i.2⟩
        generalize_proofs at *;
        refine' ⟨ _, _ ⟩;
        · intro i j hij;
          grind;
        · grind;
      exact ⟨ Equiv.ofBijective h_exists_equiv.choose ( ⟨ h_exists_equiv.choose_spec.1, Finite.injective_iff_surjective.mp h_exists_equiv.choose_spec.1 ⟩ ), h_exists_equiv.choose_spec.2 ⟩;
    exact ⟨ h_exists_equiv.choose, fun i => by simpa only [ hτ_eq ] using h_exists_equiv.choose_spec i |>.1 ⟩;
  refine' ⟨ Equiv.Perm.viaFintypeEmbedding τ Fin.valEmbedding, _, _ ⟩;
  · intro n hn; specialize hτ ⟨ n, hn ⟩ ; simp_all +decide ;
    convert congr_arg Fin.val hτ using 1;
    convert Equiv.Perm.viaFintypeEmbedding_apply_image _ _ _;
    rfl;
  · exact Filter.eventually_atTop.mpr ⟨ N, fun n hn => Equiv.Perm.viaFintypeEmbedding_apply_notMem_range _ _ <| by aesop ⟩

/-- **Dense asymptotic-invisibility theorem.**  For every eventually nonzero real
sequence, the permutations whose rearranged-to-original quotient tends to one
are dense in the pointwise topology. -/
theorem prefixDense_wellBehaved
    (a : ℕ → ℝ) (ha : ∀ᶠ n in atTop, a n ≠ 0) :
    PrefixDense {σ | WellBehaved a σ} := by
  intro σ k
  rcases exists_eventually_fixed_extension σ k with ⟨τ, hprefix, hfixed⟩
  exact ⟨τ, wellBehaved_of_eventually_fixed a τ ha hfixed, hprefix⟩

/-- The dense theorem specializes directly to any prime-valued enumeration,
since primality guarantees that every denominator is nonzero. -/
theorem prefixDense_prime_enumeration
    (p : ℕ → ℕ) (hp : ∀ n, Nat.Prime (p n)) :
    PrefixDense {σ | Tendsto (fun n => (p (σ n) : ℝ) / p n) atTop (𝓝 1)} := by
  apply prefixDense_wellBehaved (fun n => (p n : ℝ))
  filter_upwards [] with n
  exact_mod_cast (hp n).ne_zero

/-- Lehmer codes provide exactly `k!` distinct finite rearrangements, and their
extensions to the infinite hotel remain distinct.  This connects the dense core
to the factorial classification of finite permutations. -/
theorem lehmer_extensions_injective (k : ℕ) :
    Function.Injective (fun c : FactorialLehmerClassification.FactorialCode k =>
      (FactorialLehmerClassification.lehmerEquiv k c).viaFintypeEmbedding
        (Fin.valEmbedding : Fin k ↪ ℕ)) := by
  intro c d hcd
  have h_lehmer : FactorialLehmerClassification.lehmerEquiv k c = FactorialLehmerClassification.lehmerEquiv k d := by
    have h_lehmer : ∀ x : Fin k, ((FactorialLehmerClassification.lehmerEquiv k) c) x = ((FactorialLehmerClassification.lehmerEquiv k) d) x := by
      intro x; have := congr_arg ( fun f => f ( Fin.valEmbedding x ) ) hcd; simp +decide at this;
      simp_all +decide [ Equiv.Perm.viaFintypeEmbedding ];
      replace hcd := Equiv.congr_fun hcd ( Fin.valEmbedding.toEquivRange x ) ; simp_all +decide [ Equiv.Perm.extendDomain ] ;
      exact Fin.ext ( by simpa [ Fin.valEmbedding ] using hcd );
    exact Equiv.ext h_lehmer;
  exact FactorialLehmerClassification.lehmerEquiv_eq_iff k c d |>.1 h_lehmer

-- !-- Lab Notes -- !--
/-
Hypothesis.  Pointwise density should require no prime-number theorem: a finite
partial rearrangement ought to close into finite cycles, leaving the tail fixed.
A stronger claim that random finite permutations preserve index ratios was also
tested and rejected.

Experiment.  Finite prefixes were closed inside the union of their source and
image sets.  On this finite set an injective partial map extends to a bijection;
extending that bijection by the identity gives an infinite permutation.

Analysis.  The surviving statement is sequence-independent.  Eventual fixation
makes the quotient eventually exactly one, so convergence follows for every
sequence with an eventually nonzero denominator.  Primality enters only through
nonvanishing.  Thus density is topological-algebraic rather than a consequence of
prime asymptotics.

Critique.  Density is not a probability and supplies no numerical "exact density"
under a nonexistent canonical uniform measure on the infinite symmetric group.
Uniform permutations of larger and larger finite sets generally move a positive
fraction of indices by macroscopic factors, so that experiment does not support
a typicality claim.  Nor can an infinite ordering be "reversed" by `n ↦ N-n`
without fixing a finite `N`; that proposed counterexample is not a permutation of
all natural numbers.

Synthesis.  The main result proves that asymptotically invisible rearrangements
meet every finite-prefix neighborhood.  A finite-combinatorial extension theorem
provides the dense core, while Lehmer codes quantify its finite layers.
-/
-- !-- Lab Notes -- !--

end PrimeHilbertHotel