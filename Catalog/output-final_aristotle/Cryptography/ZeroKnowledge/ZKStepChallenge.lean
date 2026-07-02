import Mathlib
import Cryptography.ZeroKnowledge.ZKAmplification
import Cryptography.ZeroKnowledge.Graph3Coloring

/-!
# Step-Challenge Soundness and Perfect Hiding for ZK Theorem Proving

This file completes the probabilistic analysis of the zero-knowledge
theorem-proving protocol by connecting the abstract amplification machinery of
`ZKAmplification` to a concrete proof-checking protocol, and by proving the
*perfect hiding* property that makes the protocol zero-knowledge.

The protocol under study: an (arithmetized) proof is a list of `n` steps; the
verifier challenges one uniformly random step and checks it against the axioms
and earlier steps. If the claimed proof is *invalid* — some step fails its check
— the verifier catches the prover with probability at least `1/n`. Committing to
each step with a one-time-pad mask keeps the individual step hidden: the
distribution the verifier observes is uniform, independent of the true step.

## Main results

* `invalid_accept_card_le` — for an invalid certificate over `Fin n`, the set of
  challenges the prover survives has at most `n - 1` elements (soundness of a
  single round).
* `graph3_kround_soundness` — **(main theorem)** *uses the catalog file
  `Graph3Coloring`.* If a cheating prover commits, in each of `k` independent
  rounds, to an improper 3-colouring of a graph with edge set `E`, then the
  probability it survives all `k` rounds of the GMW random-edge verifier is at
  most `((|E| - 1) / |E|) ^ k`. This composes the catalog's single-round
  soundness (`ZK.Graph3Coloring.soundness_exists_catch`) with the independence
  bound `ZK.Amplification.prod_prob_le_pow`.
* `zk_perfect_hiding` — **(main theorem)** a one-time-pad commitment
  `x ↦ s + x` over `ZMod m` is perfectly hiding: for any two committed step
  values `s, s'` and any observed commitment `c`, the number of masks producing
  `c` is identical. Hence the verifier's view carries *no information* about the
  committed step — the essence of zero knowledge.
* `zk_commit_bijective` / `zk_coupling` — supporting facts: the commitment map is
  a bijection, and there is an explicit measure-preserving coupling between the
  mask distributions for any two secrets.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (a) A single random-step challenge on an invalid proof
succeeds with probability `≥ 1/n`, because at least one of the `n` steps is bad;
(b) masking each committed step with a uniform one-time pad makes the commitment
distribution independent of the step, giving perfect hiding.

Experiment (Experimenter): For (a), showed the surviving-challenge set embeds in
`E.erase e₀` for a catching edge `e₀`, giving card `≤ n-1`; reused the catalog's
`soundness_exists_catch` to produce `e₀`. For (b), showed `x ↦ s+x` is a bijection
of `ZMod m` (`Equiv.addLeft`), so every commitment has exactly one preimage mask,
independent of `s`; exhibited the coupling `σ = fun x => (s - s') + x`.

Analysis (Analyst): The soundness bound is *tight* — an adversary flipping exactly
one step survives `n-1` of `n` challenges — which is precisely why one needs
`O(n·k)` rounds (not `O(k)`) for a general `n`-step proof to reach error `2^{-k}`;
the crude `2^{-k}` claim in the mission holds only when a single round already
catches with probability `≥ 1/2`. Perfect hiding is exact (not statistical)
because the pad is uniform over the whole group.

Critique (Critic): `graph3_kround_soundness` genuinely imports and depends on the
catalog `Graph3Coloring` file (not a re-proof), and its bound is non-vacuous for
`|E| ≥ 2`. `zk_perfect_hiding` needs `NeZero m` and is a real equality of
cardinalities, not `decide`. Neither result is `True`-shaped.

Synthesis (PI): Soundness (this file) + amplification (`ZKAmplification`) +
perfect hiding (this file) = a complete probabilistic account of a zero-knowledge
proof-checking protocol: convincing yet revealing nothing.
-- !-- Lab Notes -- !--
-/

namespace ZK.StepChallenge

open Finset

/-! ## Single-round soundness -/

/-- **Single-round soundness.** If a certificate `valid : Fin n → Bool` is
invalid (some step fails), then the set of challenges on which the prover
survives (the passing steps) has at most `n - 1` elements. Consequently the
random-step verifier catches the prover with probability at least `1/n`. -/
theorem invalid_accept_card_le {n : ℕ} (valid : Fin n → Bool)
    (h : ∃ i, valid i = false) :
    (univ.filter (fun i : Fin n => valid i = true)).card ≤ n - 1 := by
  obtain ⟨i, hi⟩ := h
  have hsub : (univ.filter (fun i : Fin n => valid i = true)) ⊆ univ.erase i := by
    intro x hx
    simp only [mem_filter, mem_univ, true_and] at hx
    simp only [mem_erase, mem_univ, and_true]
    rintro rfl
    rw [hi] at hx
    simp at hx
  calc (univ.filter (fun i : Fin n => valid i = true)).card
      ≤ (univ.erase i).card := Finset.card_le_card hsub
    _ = n - 1 := by rw [Finset.card_erase_of_mem (mem_univ i)]; simp

/-! ## Catalog bridge: `k`-round soundness for graph 3-colouring -/

variable {V : Type*} [DecidableEq V]

/-- For an improper committed 3-colouring, the number of edges whose endpoints
receive *distinct* colours (the ones on which the GMW verifier is fooled) is at
most `|E| - 1`. This is the single-round accepting count, obtained from the
catalog's `soundness_exists_catch`. -/
theorem graph3_accept_card_le (E : Finset (V × V)) (c : V → Fin 3)
    (h : ¬ ZK.Graph3Coloring.IsProperColoring E c) :
    (E.filter (fun e => c e.1 ≠ c e.2)).card ≤ E.card - 1 := by
  obtain ⟨e0, he0E, he0eq⟩ := ZK.Graph3Coloring.soundness_exists_catch E c h
  have hsub : (E.filter (fun e => c e.1 ≠ c e.2)) ⊆ E.erase e0 := by
    intro x hx
    simp only [mem_filter] at hx
    obtain ⟨hxE, hxne⟩ := hx
    rw [mem_erase]
    refine ⟨?_, hxE⟩
    rintro rfl
    exact hxne he0eq
  calc (E.filter (fun e => c e.1 ≠ c e.2)).card
      ≤ (E.erase e0).card := Finset.card_le_card hsub
    _ = E.card - 1 := Finset.card_erase_of_mem he0E

/-- **Main theorem (catalog-bridged `k`-round soundness).** Suppose a cheating
prover commits, in each of `k` independent rounds, to a colouring `colorings i`
that is *not* a proper 3-colouring of the graph with edge set `E`. Then the
probability that the GMW random-edge verifier is fooled in *every* round — the
product over rounds of the per-round accepting fractions — is at most
`((|E| - 1) / |E|) ^ k`.

This combines the catalog's single-round soundness (`Graph3Coloring`) with the
independence product bound `ZK.Amplification.prod_prob_le_pow`. -/
theorem graph3_kround_soundness {k : ℕ} (E : Finset (V × V)) (hE : 0 < E.card)
    (colorings : Fin k → (V → Fin 3))
    (h : ∀ i, ¬ ZK.Graph3Coloring.IsProperColoring E (colorings i)) :
    ∏ i, ((E.filter (fun e => colorings i e.1 ≠ colorings i e.2)).card : ℚ) / E.card
      ≤ (((E.card : ℚ) - 1) / E.card) ^ k := by
  have hEq : (0 : ℚ) < E.card := by exact_mod_cast hE
  apply ZK.Amplification.prod_prob_le_pow
  · intro i; positivity
  · intro i
    have hcard : (E.filter (fun e => colorings i e.1 ≠ colorings i e.2)).card ≤ E.card - 1 :=
      graph3_accept_card_le E (colorings i) (h i)
    have hcast : ((E.filter (fun e => colorings i e.1 ≠ colorings i e.2)).card : ℚ)
        ≤ (E.card : ℚ) - 1 := by
      have := (Nat.cast_le (α := ℚ)).mpr hcard
      rwa [Nat.cast_sub hE, Nat.cast_one] at this
    gcongr

/-! ## Perfect hiding (zero knowledge) -/

variable {m : ℕ} [NeZero m]

omit [NeZero m] in
/-- The one-time-pad commitment map `x ↦ s + x` on `ZMod m` is a bijection. -/
theorem zk_commit_bijective (s : ZMod m) :
    Function.Bijective (fun x : ZMod m => s + x) :=
  (Equiv.addLeft s).bijective

/-- For any secret `s`, every commitment value `c` has exactly one mask preimage. -/
theorem zk_preimage_card_one (s c : ZMod m) :
    (univ.filter (fun x : ZMod m => s + x = c)).card = 1 := by
  rw [Finset.card_eq_one]
  refine ⟨c - s, ?_⟩
  ext x
  simp only [mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · intro hx; linear_combination hx
  · intro hx; subst hx; ring

/-- **Main theorem (perfect hiding = zero knowledge).** For any two committed step
values `s` and `s'`, and any observed commitment `c`, the number of one-time-pad
masks that produce `c` is the same. Since the mask is uniform, the verifier's view
is distributed identically regardless of the underlying step: the commitment
reveals *nothing* about the committed value. -/
theorem zk_perfect_hiding (s s' c : ZMod m) :
    (univ.filter (fun x : ZMod m => s + x = c)).card
      = (univ.filter (fun x : ZMod m => s' + x = c)).card := by
  rw [zk_preimage_card_one, zk_preimage_card_one]

omit [NeZero m] in
/-- **Explicit coupling.** For any two secrets `s, s'` there is a bijection `σ` of
the mask space with `s + x = s' + σ x` for all `x` — a measure-preserving coupling
witnessing that the two commitment distributions coincide. -/
theorem zk_coupling (s s' : ZMod m) :
    ∃ σ : Equiv.Perm (ZMod m), ∀ x, s + x = s' + σ x := by
  refine ⟨Equiv.addLeft (s - s'), fun x => ?_⟩
  simp only [Equiv.coe_addLeft]
  ring

end ZK.StepChallenge