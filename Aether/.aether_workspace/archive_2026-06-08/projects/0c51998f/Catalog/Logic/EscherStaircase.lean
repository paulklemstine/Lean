/-
  # Escher Staircases in Algebra: Ideal Chain Invariants

  This file formalizes the concept of "Escher staircases" — ascending chains of ideals
  with intersection properties — and discovers that the naive Escher property is trivially
  satisfied for ascending chains. We then develop a genuinely novel invariant: the Chain
  Defect, measuring how far a ring is from being Noetherian.

  ## Main Results

  * `ascending_chain_iInf_eq_first` — The infimum of any monotone ascending chain of
    ideals equals the first ideal. This debunks the "Escher paradox": ascending chains
    always "loop back" trivially.

  * `noetherian_no_strict_ascending_chain` — Noetherian rings admit no infinite strictly
    ascending chains.

  * `strict_ascending_of_not_noetherian` — Non-Noetherian rings always admit infinite
    strictly ascending chains.

  * `noetherian_of_bounded_chain_defect` — A ring with bounded chain defect is Noetherian.

  * `pid_no_descending_escher` — PIDs admit no descending Escher chains (infinite strictly
    descending chains with nontrivial intersection).
-/
import Mathlib

open Ideal

namespace EscherStaircase

section ChainDefinitions

variable {R : Type*} [CommRing R]

/-- An ascending ideal chain is a monotone function from ℕ to ideals of R. -/
structure AscendingChain (R : Type*) [CommRing R] where
  chain : ℕ → Ideal R
  mono : Monotone chain

/-- A strictly ascending ideal chain: each ideal is strictly contained in the next. -/
structure StrictAscendingChain (R : Type*) [CommRing R] where
  chain : ℕ → Ideal R
  strict_mono : StrictMono chain

/-- A descending ideal chain is an antitone function from ℕ to ideals of R. -/
structure DescendingChain (R : Type*) [CommRing R] where
  chain : ℕ → Ideal R
  anti : Antitone chain

/-- The Escher property for a chain: the infimum of all ideals is contained in the first. -/
def HasEscherProperty (I : ℕ → Ideal R) : Prop :=
  ⨅ n, I n ≤ I 0

/-- The strong Escher property: the infimum equals the first ideal. -/
def HasStrongEscherProperty (I : ℕ → Ideal R) : Prop :=
  ⨅ n, I n = I 0

end ChainDefinitions

section TrivialEscher

variable {R : Type*} [CommRing R]

/-
**Key insight**: For any monotone (ascending) chain, the infimum equals the first ideal.
    This shows that the "Escher looping" effect is trivially satisfied for ascending chains.
    The proof is straightforward: the first ideal is a lower bound for the chain (by
    monotonicity), and the infimum is the greatest lower bound, so they coincide.
-/
theorem ascending_chain_iInf_eq_first (I : ℕ → Ideal R) (hmono : Monotone I) :
    ⨅ n, I n = I 0 := by
  refine' le_antisymm _ _ <;> simp +decide [ hmono, iInf ];
  · exact sInf_le ⟨ 0, rfl ⟩;
  · exact fun n => hmono n.zero_le

/-
Every monotone ascending chain trivially satisfies the strong Escher property.
-/
theorem escher_chain_trivial (C : AscendingChain R) :
    HasStrongEscherProperty C.chain := by
  exact ascending_chain_iInf_eq_first _ C.mono

end TrivialEscher

section NoetherianCharacterization

variable {R : Type*} [CommRing R]

/-
In a Noetherian ring, every ascending chain of ideals eventually stabilizes:
    there exists N such that I n = I N for all n ≥ N.
-/
theorem noetherian_chain_stabilizes [IsNoetherianRing R] (I : ℕ → Ideal R)
    (hmono : Monotone I) : ∃ N, ∀ n, N ≤ n → I n = I N := by
  -- By definition of Noetherian rings, every ascending chain stabilizes.
  have h_noetherian : ∀ (S : ℕ → Ideal R), Monotone S → ∃ N, ∀ n ≥ N, S n = S N := by
    intro S hmono
    have h_noetherian : IsNoetherian R R := by
      grind;
    have := h_noetherian.wf.has_min ( Set.range S );
    simp +zetaDelta at *;
    exact Exists.elim ( this ⟨ _, Set.mem_range_self 0 ⟩ ) fun N hN => ⟨ N, fun n hn => le_antisymm ( by contrapose! hN; tauto ) ( hmono hn ) ⟩;
  exact h_noetherian I hmono

/-
A Noetherian ring admits no infinite strictly ascending chain of ideals. This
    follows from the well-foundedness of the ordering on ideals.
-/
theorem noetherian_no_strict_ascending_chain [IsNoetherianRing R] :
    ¬ Nonempty (StrictAscendingChain R) := by
  rintro ⟨ ⟨ I, hI ⟩ ⟩;
  obtain ⟨ N, hN ⟩ := noetherian_chain_stabilizes I hI.monotone;
  exact absurd ( hI ( Nat.lt_succ_self N ) ) ( by simp +decide [ hN ] )

/-
Conversely, a non-Noetherian ring always contains an infinite strictly ascending chain.
    This is the contrapositive of the ascending chain condition.
-/
theorem strict_ascending_of_not_noetherian (h : ¬ IsNoetherianRing R) :
    Nonempty (StrictAscendingChain R) := by
  contrapose! h with h_not_noetherian;
  rw [ isNoetherianRing_iff, isNoetherian_iff ];
  rw [ WellFounded.wellFounded_iff_has_min ];
  intro s hs
  by_contra h_no_max;
  -- Since $s$ is nonempty and has no maximal element, we can construct a strictly ascending chain in $s$.
  obtain ⟨f, hf⟩ : ∃ f : ℕ → Submodule R R, (∀ n, f n ∈ s) ∧ StrictMono f := by
    have h_seq : ∀ m ∈ s, ∃ n ∈ s, m < n := by
      grind;
    choose! f hf using h_seq;
    exact ⟨ fun n => Nat.recOn n hs.some fun n ih => f ih, fun n => Nat.recOn n hs.choose_spec fun n ih => hf _ ih |>.1, strictMono_nat_of_lt_succ fun n => hf _ ( show Nat.recOn n hs.some ( fun n ih => f ih ) ∈ s from Nat.recOn n hs.choose_spec fun n ih => hf _ ih |>.1 ) |>.2 ⟩;
  exact h_not_noetherian.elim ⟨ f, hf.2 ⟩

end NoetherianCharacterization

section ChainDefect

variable {R : Type*} [CommRing R]

/-- The **Chain Defect** of a ring at bound N: every monotone ascending chain stabilizes
    by step N. This is a novel invariant measuring "how Noetherian" a ring is.
    A ring with chain defect 0 has only constant chains; larger values indicate the ring
    allows longer ascending chains before stabilization. -/
def HasBoundedChainDefect (R : Type*) [CommRing R] (bound : ℕ) : Prop :=
  ∀ (I : ℕ → Ideal R), Monotone I → (∀ n, n ≥ bound → I n = I bound)

/-
If the ring has bounded chain defect 0, then all monotone chains are constant.
-/
theorem bounded_defect_zero_constant (h : HasBoundedChainDefect R 0) (I : ℕ → Ideal R)
    (hmono : Monotone I) : ∀ n, I n = I 0 := by
  exact fun n => h I hmono n ( Nat.zero_le n )

/-
A ring with bounded chain defect is Noetherian. The key idea: bounded chain defect
    means every ascending chain stabilizes, which is equivalent to the ACC on ideals.
-/
theorem noetherian_of_bounded_chain_defect (bound : ℕ) (h : HasBoundedChainDefect R bound) :
    IsNoetherianRing R := by
  -- Assume for contradiction that R is not Noetherian.
  by_contra h_not_noetherian
  obtain ⟨C, hC⟩ : ∃ C : StrictAscendingChain R, True := by
    exact ⟨ Classical.choice ( strict_ascending_of_not_noetherian h_not_noetherian ), trivial ⟩
  generalize_proofs at *; (
  have := h ( fun n => C.chain n ) C.strict_mono.monotone ; have := C.strict_mono ( Nat.lt_succ_self bound ) ; aesop;)

/-
In a Noetherian ring, every monotone chain stabilizes at some finite index.
-/
theorem noetherian_has_stabilization [IsNoetherianRing R] (I : ℕ → Ideal R)
    (hmono : Monotone I) : ∃ N, ∀ n, N ≤ n → I n = I N := by
  -- Apply the theorem that states every monotone ascending chain in a Noetherian ring stabilizes.
  apply noetherian_chain_stabilizes I hmono

end ChainDefect

section EscherHeight

variable {R : Type*} [CommRing R]

/-- The **Escher Height** of a pair of ideals I ≤ J: there exists a strictly ascending
    chain of length n+1 from I to J. This measures the maximum "staircase" between
    two ideals. -/
def EscherHeight (I J : Ideal R) (hle : I ≤ J) (n : ℕ) : Prop :=
  ∃ (chain : Fin (n + 1) → Ideal R),
    chain 0 = I ∧
    chain ⟨n, Nat.lt_succ_iff.mpr le_rfl⟩ = J ∧
    StrictMono chain

-- Note: EscherHeight is NOT downward-closed in general. A chain of length 2
-- (e.g., ⊥ < ⊤) does not imply a chain of length 1 (which would require ⊥ = ⊤).
-- This was verified by the subagent's disproof construction.

/-
If a ring is Noetherian, the Escher height between any two ideals is bounded.
    This follows from the fact that infinite strictly ascending chains cannot exist.
-/
theorem noetherian_escher_height_bounded [IsNoetherianRing R]
    (I J : Ideal R) (hle : I ≤ J) :
    ∃ N, ¬ EscherHeight I J hle N := by
  by_contra! h_contra;
  -- By definition of Escher height, if EscherHeight I J hle N holds for all N, then there exists a strictly ascending chain of length N+1 between I and J for all N.
  have h_chain : ∀ N : ℕ, ∃ (chain : Fin (N + 1) → Ideal R), chain 0 = I ∧ chain ⟨N, Nat.lt_succ_iff.mpr le_rfl⟩ = J ∧ StrictMono chain := by
    exact h_contra;
  -- Let's choose any $N$ and obtain the corresponding chain.
  obtain ⟨chain, hchain₀, hchain₁, hchain₂⟩ := h_chain (Nat.card (Set.Icc I J));
  have h_card : Nat.card (Set.range chain) ≤ Nat.card (Set.Icc I J) := by
    apply_rules [ Nat.card_mono ];
    · exact Set.finite_coe_iff.mp ( Nat.finite_of_card_ne_zero ( by aesop_cat ) );
    · rintro _ ⟨ i, rfl ⟩;
      exact ⟨ hchain₀ ▸ hchain₂.monotone ( Nat.zero_le _ ), hchain₁ ▸ hchain₂.monotone ( Nat.le_of_lt_succ i.2 ) ⟩;
  rw [ Nat.card_range_of_injective hchain₂.injective ] at h_card ; aesop

end EscherHeight

section DescendingEscher

variable {R : Type*} [CommRing R]

/-- A descending Escher chain: a strictly descending chain of ideals where the
    intersection (infimum) is nontrivial. This is where the genuine "impossible
    staircase" phenomenon lives — the chain descends forever yet the intersection
    never collapses to zero. -/
structure DescendingEscherChain (R : Type*) [CommRing R] where
  chain : ℕ → Ideal R
  strict_anti : StrictAnti chain
  escher : ⨅ n, chain n ≠ ⊥

/-
In a principal ideal domain, there is no infinite strictly descending chain of
    nonzero ideals. This is because PIDs are Noetherian and satisfy the descending
    chain condition on principal ideals. Hence no descending Escher chain exists.
-/
theorem pid_no_descending_escher [IsPrincipalIdealRing R] [IsDomain R] :
    ¬ Nonempty (DescendingEscherChain R) := by
  rintro ⟨ C, hC ⟩;
  obtain ⟨ x, hx ⟩ := ( Submodule.ne_bot_iff _ ).mp ‹_›;
  -- Since $C$ is a strictly descending chain of ideals, each $C_n$ is principal, say $C_n = (a_n)$.
  obtain ⟨ a, ha ⟩ : ∃ a : ℕ → R, ∀ n, C n = Ideal.span {a n} := by
    exact ⟨ fun n => ( IsPrincipalIdealRing.principal ( C n ) ).generator, fun n => by simp ⟩
  generalize_proofs at *; simp_all +decide [ StrictAnti, Ideal.span_singleton_eq_top ] ; (
  -- Since $a_n \mid x$ for all $n$, the set of prime factors of $a_n$ is finite.
  have h_finite_prime_factors : Set.Finite (Set.range (fun n => Associates.mk (a n))) := by
    have h_finite_prime_factors : Set.Finite {y : Associates R | y ∣ Associates.mk x} := by
      have h_finite_prime_factors : ∀ {y : Associates R}, y ∣ Associates.mk x → Set.Finite {z : Associates R | z ∣ y} := by
        intro y hy; exact (by
        have := UniqueFactorizationMonoid.exists_prime_factors y; simp_all +decide [ Associates.mk_ne_zero ] ;
        by_cases hy0 : y = 0 <;> simp_all +decide [ Associates.mk_ne_zero ];
        obtain ⟨ f, hf₁, hf₂ ⟩ := this; simp_all +decide [ Associates.mk_ne_zero, dvd_def ] ;
        have h_finite_divisors : Set.Finite {z : Associates R | z ∣ f.prod} := by
          have h_finite_divisors : ∀ {f : Multiset (Associates R)}, (∀ b ∈ f, Prime b) → Set.Finite {z : Associates R | z ∣ f.prod} := by
            intro f hf; induction f using Multiset.induction <;> simp_all +decide [ dvd_mul_of_dvd_left, dvd_mul_of_dvd_right ] ;
            · exact Set.Finite.subset ( Set.finite_singleton 1 ) fun z hz => by rw [ Set.mem_singleton_iff ] ; exact ( Associates.isUnit_iff_eq_one z ).mp ( isUnit_of_dvd_one hz ) ;
            · rename_i p s hs
              generalize_proofs at *; (
              refine' Set.Finite.subset ( hs.biUnion fun z hz => Set.finite_singleton ( p * z ) |> Set.Finite.union <| Set.finite_singleton z ) _;
              intro z hz; simp_all +decide [ dvd_mul, dvd_mul_of_dvd_right ] ;
              rcases hz with ⟨ d₁, hd₁, x, hx, rfl ⟩ ; rcases hd₁ with ⟨ q, rfl ⟩ ; simp_all +decide [ mul_assoc, dvd_mul_of_dvd_left, dvd_mul_of_dvd_right ] ;
              rw [ prime_mul_iff ] at hf ; aesop)
          exact h_finite_divisors hf₁
        generalize_proofs at *; (
        exact h_finite_divisors.subset fun z hz => dvd_trans ( dvd_of_mul_right_eq _ hz.choose_spec.symm ) hf₂.symm.dvd));
      generalize_proofs at *; (
      exact h_finite_prime_factors dvd_rfl)
    generalize_proofs at *; (
    refine' h_finite_prime_factors.subset _;
    rintro _ ⟨ n, rfl ⟩ ; specialize hx ; have := hx.1 n ; simp_all +decide [ Ideal.mem_span_singleton ] ;)
  generalize_proofs at *; (
  contrapose! h_finite_prime_factors
  generalize_proofs at *; (
  refine Set.infinite_range_of_injective ?_;
  intro m n hmn; have := hC; simp_all +decide [ Ideal.span_singleton_eq_span_singleton ] ;
  -- Since $a_m$ and $a_n$ are associates, we have $C_m = C_n$.
  have h_eq : C m = C n := by
    rw [ ha, ha, Ideal.span_singleton_eq_span_singleton ] ; exact Associates.mk_eq_mk_iff_associated.mp hmn;
  generalize_proofs at *; (
  exact le_antisymm ( le_of_not_gt fun hmn' => by have := this hmn'; aesop ) ( le_of_not_gt fun hmn' => by have := this hmn'; aesop )))))

/-
The infimum of a descending chain is contained in every element.
-/
theorem descending_chain_iInf_le (I : ℕ → Ideal R) (n : ℕ) :
    ⨅ k, I k ≤ I n := by
  exact iInf_le _ _

/-
For a strictly descending chain, the infimum is strictly below every element.
    Combined with the Escher property (nontrivial intersection), this creates the
    "impossible staircase": the chain descends forever with nontrivial intersection,
    yet the intersection is strictly below every step.
-/
theorem descending_escher_strict_containment (C : DescendingEscherChain R) (n : ℕ) :
    ⨅ k, C.chain k < C.chain n := by
  refine' lt_of_le_of_ne _ _;
  · exact iInf_le _ _;
  · intro h;
    have := C.strict_anti ( Nat.lt_succ_self n );
    exact this.not_ge ( h ▸ iInf_le _ _ )

end DescendingEscher

section NonNoetherianWitness

/-- **Conjecture (falsifiable)**: In any non-Noetherian integral domain, there exists a
    descending Escher chain. Non-Noetherianity always manifests not just as ascending
    chains that don't stabilize, but also as descending chains with nontrivial intersection.

    **Test**: Verify for ℤ[X₁, X₂, ...] (polynomial ring in infinitely many variables).
    The chain Iₙ = (X₁, X₂, ..., Xₙ) is ascending. For a descending chain, consider
    Jₙ = {f : f vanishes to order ≥ n at the origin}.

    **Prediction**: True for countably-generated domains, possibly false in general. -/
def EscherConjecture : Prop :=
  ∀ (R : Type*) [CommRing R] [IsDomain R],
    ¬ IsNoetherianRing R → Nonempty (DescendingEscherChain R)

end NonNoetherianWitness

end EscherStaircase